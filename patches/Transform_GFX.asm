;==========================;
;GFX TRANSFORMATION ROUTINE;
;==========================;
;
;	clear carry to clear buffer
;	set carry to maintain buffer (used for multi-stage render)
;
;	output:
;	- if image was scaled but not rotated, it is output in !GFX_buffer+$800 (!V_buffer+$1000)
;	- if image was rotated, it is output in !GFX_buffer
;	- if image was rotated with fixed size set, it is output in !GFX_buffer+$200 (!V_buffer+$400)
;
;
;	scaling:
;	0-127 uses the growth function, scaling from x1 at 0 to x2 at 127
;	128-255 uses the shrink function, scaling from /1 at 255 to /2 at 128
;
;	rotation method:
;		- calculate shear X as -tan(v/2)
;		- calculate shear Y as sin(v)
;		- apply shear X by shifting pixel rows horizontally based on vertical position
;		- apply shear Y by shifting pixel columns vertically based on horizontal position
;		- apply shear X again
;		- for angles greater than 90 degrees but smaller than 270 degrees, flat rotation is added as step 4
;
;
;	Full input:
;	- store pointer to image cache in !BigRAM+$00
;	- store input image dimensions to !BigRAM+$02 and !BigRAM+$04 (w, h)
;	- load A with mode, then call this
;	  srritcmm
;	  s - scale: 0 = no scaling, 1 = scale
;	  rr - rotate: 00 = no rotation, 01 = rotation with fixed size, 10 = rotation with resize, 11 = invalid
;	  mm - multistage render
;		for scaling: 00 = 1 stage, 01 = 2 stages, 10 = 4 stages, 11 = 8 stages
;		for rotation: 00 = 1 stage, 01 = 2 stages (X1+Y, X2+flat), 10 = 3 stages (X1+Y, X2, flat) 11 = 4 stages
;		for mixed operation:
;			00 = 1 stage
;			01 = 2 stages (scale, rotate)
;			10 = 4 stages (scale, scale, X1+Y, X2+flat)
;			11 = 8 stages (scale, scale, scale, scale, X1, Y, X2, flat)
;	  i - init flag: if using multistage rendering, this must be set on the first call
;			 on subsequent calls, this must be clear, however
;			 if mm bits are clear, this bit does not matter
;	  t - triangle rendering: if set, a triangle graphic will be rendered (overwrites other modes)
;	  c - convert: if set, input linear GFX will be converted to planar format (overwrites other modes)
;	- if scaling is set, store the following:
;		- X scaling to !BigRAM+$06
;		- Y scaling to !BigRAM+$08
;		- center X to !BigRAM+$0A
;		- center Y to !BigRAM+$0C
;	- if rotation is set, store angle to !BigRAM+$0E
;	- if scaling is not used, h is ignored and does not have to be stored to !BigRAM+$04
;	- note that maximum output dimensions are 64 pixels
;	- for scaling up or rotating, 32px is the maximum input image size
;	- for scaling down, input images as large as 64x64px can be used (this is the largest possible input size)
;	- triangle rendering is very different from the other ones:
;		- the only input required is a 24-bit pointer to the input row
;		- input row is expected to be a 128px row of linear 4bpp pixels
;		- output triangle is 128x128px and takes up all 8KB of transformation memory (cache is overwritten)


	!Source		= $80		;\ input for all operations
	!InputW		= $82		;/
	!InputH		= $84		;\
	!ScaleX		= $86		; |
	!ScaleY		= $88		; | scaling input
	!CenterX	= $8A		; |
	!CenterY	= $8C		;/
	!Angle		= $8E		; rotation input

	!SizeFactorX	= $90		;\
	!SizeFactorY	= $92		; | used for scaling
	!SizeMemX	= $94		; |
	!SizeMemY	= $96		;/
	!ShearX		= $98		;\ used for rotation
	!ShearY		= $9A		;/

	!Scale		= $9C		; 0 = no scale, 1 = scale
	!Rotate		= $9E		; 0 = no rotate, 1 = rotate
	!Stages		= $A0		; mm bits, see input manual above

	!TempSize	= $A2		;\
	!BitCheck	= $A4		; |
	!ByteCount	= $A6		; | used during rotation calculations
	!PixelShift	= $A8		; |
	!IndexScratch	= $AA		;/

	!OutputW	= $A2		;\
	; bit check
	; byte count
	!OutputH	= $A8		; | used during scaling calculations
	; index scratch
	!StartX		= $AC		; |
	!StartY		= $AE		;/
	!BufferW	= $B0		; keeps track of buffer width during scaling
	!InputY		= $B2		; keeps track of which row we're on (input side)
	!OutputY	= $B4		; same but output side

	!TempPtr1	= $B6		; 24-bit, keeps track of column size during Y shear
	!TempPtr2	= $B9		;\ 16-bit code pointers during Y shear
	!TempPtr3	= $BB		;/

	!PointA		= $B0		; used for flat 90/270
	!PointB		= $B2
	!PointC		= $B4
	!PointD		= $B6
	!pxA		= $B8
	!pxB		= $BA
	!pxC		= $BC
	!OutputX	= $BE		; keeps track of X position during flat 90/270 (also used for scale multistage)


	!PixelsRendered	= $BA		; used during scaling
	!RenderSize	= $BC		; used during scaling
	!MultiStage	= $BE		; number of total stages, set at init, sometimes overwritten during final stage





; to perform multistage rendering, I need to back up certain, but not all, registers
; to multistage render rotation, I need to:
;	- backup !ShearX, !ShearY, and !InputW
;	- jump to the proper place (X1, Y, X2, flat) depending on which stage I'm on
; to multistage render scaling, I need to:
;	- backup $80-$97 and $A2-$B9 (basically all regs)
; additionally, !Scale, !Rotate, and !Stages always need to be backed up
;




;
; routine manual
;	- main call: sets up which transformations will be applied and in how many steps
;	- main rotate
;		- determine rotation type (flat, Paeth, Paeth + flat)
;		- flat rotation rotates the image by 90, 180, or 270 degrees
;		- Paeth rotation rotates the image by less than 90 degrees
;		- rotated image is output in !GFX_buffer+0 at doubled size in both dimensions
;		- if fixed size is set, image is output in !GFX_buffer+$200 (!V_buffer+$400)
;	- main scale
;		- determine output dimensions
;		- if scaling is x2 or /2, go to fast version
;		- if scaling is anything else, go to calculation
;		- scaled image is outpu in !GFX_buffer+$800 (!V_buffer+$1000)
;	- if image will be both scaled and rotated, source pointer is set to !V_buffer+$1000 and main rotate is called
;



;	!Stages:
;		- lo byte set to 0-3 depending on mm bits from input
;		- hi byte set to 80 if i bit is set
;		- when init flag is set, mode + mm bits determine what to overwrite lo byte with (number of stages)
;		- when lo byte is nonzero and init flag is clear, cached value + mm bits determine where to pick up
;		- when a multistage image is done, hi byte is set to 0xCC signaling that no backup should be made
;		- hi byte is never backed up, meaning that the init bit is always cleared
;		- lo byte is decremented by 1 and cached



;
; to render triangle GFX:
; - we need a 128px scanline that will be successively scaled down, forming a triangle
; - it is 128px tall, with the top scanline being 0px wide and the bottom being 128px wide
; - let's start by trying to just scale it down, though I'll have to remove the limiter for this
; - ratio for each render line is:
;	n/128, where n is the scanline number, counting from the top
;	the top scanline is therefor left blank, as no pixels will qualify for rendering
; - outline will have to be manually drawn on scanlines that skip it
; - additionally, render lines must be adjusted horizontally for the correct angle to be achieved
; - horizontal offset is equal to 64 minus half the render line's output width:
;	64 - n/2
;




TRANSFORM_GFX:	PHX
		PHY
		PHP
		REP #$30
		STZ.w !BigRAM-$80+!Scale		;\
		STZ.w !BigRAM-$80+!Rotate		; | clear these
		STZ.w !BigRAM-$80+!Stages		;/
		SEP #$20
		PHA
		AND #$03 : STA.w !BigRAM-$80+!Stages	; set stages
		PLA
		ASL A : ROL.w !BigRAM-$80+!Scale	; rotate highest bit into scale enable
		ASL A : ROL.w !BigRAM-$80+!Rotate	;\ rotate rr bits into rotate enable
		ASL A : ROL.w !BigRAM-$80+!Rotate	;/
		ASL A : ROR.w !BigRAM-$80+!Stages+1	; rotate i bit into highest bit of !Stages
		AND #$C0 : BEQ .NoSpecial		;\
		BPL .NoTriangle				; |
		LDA #$FF				; |
		STA.w !BigRAM-$80+!Stages		; | triangle rendering
		STA.w !BigRAM-$80+!Stages+1		; |
		BRA .NoSpecial				; |
		.NoTriangle				;/
		CMP #$40 : BCC .NoSpecial		;\
		LDA #$EE				; |
		STA.w !BigRAM-$80+!Stages		; | format conversion
		STA.w !BigRAM-$80+!Stages+1		; |
		.NoSpecial				;/
		REP #$20

		TSC					;\
		AND #$FF00				; |
		CMP #$3700 : BNE .SNES			; | SA-1 code

	print pc
		JSL .Main				; |
	print pc
		PLP					; |
		PLY					; |
		PLX					; |
		RTL					;/

		.SNES					;\
		LDA.w #.Main : STA $3180		; |
		LDA.w #.Main>>8 : STA $3181		; |
		SEP #$30				; | SNES code
		JSR $1E80				; |
		PLP					; |
		PLY					; |
		PLX					; |
		RTL					;/


		.Main
		PHD
		PHB : PHK : PLB
		SEP #$20
		STZ $2250				; set multiplication
		REP #$30
		LDA.w #!BigRAM-$80 : TCD		; DP = !BigRAM-$80 (to use with $80+ area)

		LDA !Stages				;\
		CMP #$FFFF : BNE .NotTriangle		; |
		JSR RenderTriangle			; | if triangle flag was set, render triangle and return
		PLB					; |
		PLD					; |
		RTL					; |
		.NotTriangle				;/
		CMP #$EEEE : BNE .Normal		;\
		JSR LinearToPlanar			; |
		PLB					; | if convert bit was set, convert image to planar format and return
		PLD					; |
		RTL					;/

		.Normal
		LDA !Stages				;\ i flag goes to init multistage render
		BMI .Init				;/
		BEQ .SingleStage			; if mm bits are clear, proceed normally
		PEA .Return-1				;\ set return address and handle multistage render
		JMP MultiStage				;/


	; if scaling is clear, stages are: 1, 2, 3, 4	(rotate)
	; if scaling is set, stages are: 1, 2, 4, 8	(scale or mixed mode)


		.Init
		AND #$00FF : BEQ .SingleStage		; check for input error of i=1, mm=00
		TRB !Stages				; > clear lo byte of stages
		LDX !Scale : BEQ +
		TAX
		LDA.w StageCount,x
		AND #$00FF
	+	INC A
		TSB !Stages				; set stage count without clearing init
		STA !MultiStage				; set total number of stages
		JMP MultiStage				; go to multistage handler


		.SingleStage
		STZ !MultiStage
		LDA !Scale : BEQ .ClearBuffer
		JSR SCALE
		LDA.w #!V_buffer+$1000 : STA !Source	; repoint source
		LDA !BufferW				;\
		CMP #$0040				; | maximum input width for rotation is 32px
		BNE $01 : LSR A				; |
		STA !InputW				;/

		LDA !Stages
		AND #$00FF : BEQ .CheckR		; if multistage is off, rotate as well
		BRA .Return				; otherwise return for now


		.ClearBuffer
		PEA $6040				; banks
		PLB					; set bank $40
		LDX #$07FE				;\
	-	STZ.w !GFX_buffer+$800,x		; | clear work space
		DEX #2 : BPL -				;/
		PLB					; set bank to virtual buffer area

		.CheckR
		LDA !Rotate : BEQ .Return
		JSR ROTATE

		.Return
		REP #$30
		LDA !Stages				;\
		CMP #$CC00 : BCS +			; > hi byte = 0xCC signals that multistage image is done
		AND #$00FF : BEQ +			; |
		PHA					; > push this
		PEA $4040				; |
		PLB : PLB				; | backup regs at !RenderingCache during multistage rendering
		LDX #$003E				; |
	-	LDA $80,x : STA.w !RenderingCache,x	; |
		DEX #2 : BPL -				;/
		PLA					;\
		DEC A 					; | decrement stages and overwrite cache
		STA.w !RenderingCache-$80+!Stages	;/ (this will be used with mm to determine where to pick up)

	+	PLB
		PLD
		RTL



	MultiStage:
		PEA $4040				;\
		PLB : PLB				; |
		LDX #$003E				; | restore regs from cache
	-	LDA.w !RenderingCache,x : STA $80,x	; |
		DEX #2 : BPL -				;/

	; !MultiStage + mode determine what the stages are, !Stages determines which one to go to

		LDA !Scale : BNE .NoRotate

	; multistage, rotate only
	; 2 + 2 - X1 + Y
	; 2 + 1 - X2 + flat
	; 3 + 3 - X1 + Y
	; 3 + 2 - X2
	; 3 + 1 - flat
	; 4 + 4 - X1
	; 4 + 3 - Y
	; 4 + 2 - X2
	; 4 + 1 - flat


		LDA !MultiStage
		CMP #$0002 : BEQ .4Stage		; same as second half of 4-stage mixed mode render
		CMP #$0004 : BEQ .8Stage		; same as second half of 8-stage mixed mode render

	.Three	LDA !Stages
		CMP #$0003 : BEQ .RotateHalf1
		CMP #$0002 : BEQ .X2
		CMP #$0001 : BEQ .Flat
		RTS

		.NoRotate
		LDA !Rotate : BNE .MixedMode
	.Scale	JMP SCALE				; scale only is super simple, just go here

		.MixedMode

	; mixed mode
	; 2 + 2 - scale
	; 2 + 1 - rotate full
	; 4 + 4 - scale
	; 4 + 3 - scale
	; 4 + 2 - X1 + Y
	; 4 + 1 - X2 + flat
	; 8 + 8 - scale
	; 8 + 7 - scale
	; 8 + 6 - scale
	; 8 + 5 - scale
	; 8 + 4 - X1
	; 8 + 3 - Y
	; 8 + 2 - X2
	; 8 + 1 - flat


		LDA !MultiStage
		LSR A
		SEC : SBC !Stages
		BCC .Scale				; first half of mixed mode is scaling


	.MixedRotate
		LDA !MultiStage
		CMP #$0002 : BEQ .RotateFull
		CMP #$0004 : BEQ .4Stage

	.8Stage	LDA !Stages
		CMP #$0004 : BEQ .X1
		CMP #$0003 : BEQ .Y
		CMP #$0002 : BEQ .X2
		CMP #$0001 : BEQ .Flat
	.Return	RTS

	.4Stage	LDA !Stages
		CMP #$0002 : BEQ .RotateHalf1
		CMP #$0001 : BEQ .RotateHalf2
		RTS

	.Y	JMP ROTATE_Y			; perform Y shear

	.X2	JMP ROTATE_X2			; perform X shear 2

	.RotateFull
		JMP ROTATE


	.RotateHalf1
		LDA !Angle			;\ check for flat angles
		AND #$007F : BEQ .Return	;/
		LDA !Angle
		CMP #$0180 : BCS +		; v > 270 -> go
		CMP #$0080 : BCC +		; v < 90 -> go
		SBC #$0080			;\ subtract 90, go if it's now below 90
		CMP #$0080 : BCC +		;/
		SBC #$0080			; if it's not, it was in the 180-270 range, so we subtract 90 again
	+	JSR ROTATE_Init			;\
		JSR ROTATE_X1			; | initialize rotation regs and perform X1 + Y shear
		JMP ROTATE_Y			;/

	.RotateHalf2
		JSR ROTATE_X2
	.Flat	LDA !Angle : BEQ .F0		; v = 0 just moves to buffer
		CMP #$0080			;\ v = 90 uses flat 90
		BEQ .F90			;/
		BCC .Return			; v < 90 has no flat rotation
		CMP #$0180			;\ v = 270 uses flat 270
		BEQ .F90			;/
		BCS .Return			; v > 270 has no flat rotation
		CMP #$0100 : BEQ .F180		; v = 180 uses flat 180
		BCS .Add180			; 270 < v < 180 adds flat 180
	.Add90	JMP Flat90_Add			; 180 < v < 90 adds flat 90
	.Add180	JMP Flat180_Add
	.F0	JMP Flat0
	.F90	JMP Flat90
	.F180	JMP Flat180


	.X1	LDA !Angle			;\ check for flat angles
		AND #$007F : BEQ .Return	;/
		LDA !Angle
		CMP #$0180 : BCS +		; v > 270 -> go
		CMP #$0080 : BCC +		; v < 90 -> go
		SBC #$0080			;\ subtract 90, go if it's now below 90
		CMP #$0080 : BCC +		;/
		SBC #$0080			; if it's not, it was in the 180-270 range, so we subtract 90 again
	+	JSR ROTATE_Init			;\ initialize rotation regs and perform X shear 1
		JMP ROTATE_X1			;/







	StageCount:
		db $00,$01,$03,$07	; incremented by 1 when read





	ROTATE:

; 000-000	flat0
; 001-07F	Paeth
; 080-080	flat90
; 081-0FF	Paeth -80 + flat90
; 100-100	flat180
; 101-17F	Paeth -100 + flat180
; 180-180	flat270
; 181-1FF	Paeth



		LDA !Angle : BEQ .F0
		CMP #$0080 : BEQ .F90
		CMP #$0100 : BEQ .F180
		CMP #$0180 : BNE .Paeth
	.F90	JMP Flat90
	.F180	JMP Flat180
	.F0	JMP Flat0

	.Paeth	CMP #$0180 : BCC +
		BRA .Calc

	+	CMP #$0100 : BCC +
		SBC #$0100
		JSR .Calc
		JMP Flat180_Add

	+	CMP #$0080 : BCC .Calc
		SBC #$0080
		JSR .Calc
		JMP Flat90_Add


	.Calc
		JSR .Init				; initialize rotation regs
		JSR .X1					; X shear 1
		JSR .Y					; Y shear
		JSR .X2					; X shear 2

		LDA !Angle				;\
		CMP #$0080 : BCC .Mark			; | mark that image has finished rendering
		CMP #$0180 : BCC .Return		; |
	.Mark	LDA #$CCCC : STA !Stages		;/

	.Return
		RTS


	.Init
		PHK : PLB
		STA !IndexScratch			; store this value but don't overwrite !Angle
		CLC : ADC #$0080			; table starts at -90 degrees so add 90 degrees here
		AND #$00FF				; get tangent within 90 degrees of 0
		LSR A					;\
		ASL A					; | shear X = -(v/2)
		TAX					; |
		LDA.w tan,x : STA !ShearX		;/
		LDA !IndexScratch			;\ > use angle set by main routine
		TAY					; |
		AND #$00FF				; | get sin table index
		ASL A					; |
		TAX					;/
		LDA.l !TrigTable,x			;\
		CPY #$0100 : BCS +			; | shear Y = -sin(v)
		EOR #$FFFF : INC A			; | (hi bit of angle inverts sin result)
	+	STA !ShearY				;/
		RTS



	.X1

		PHK : PLB
		LDA !InputW				;\
		STA $2251				; | square input width to get byte count
		STA $2253				;/
		LSR A					;\ buffer starting X coordinate at !TempSize
		STA !TempSize				;/


		LDA $2306 : STA !ByteCount		; > input image byte count
		LDA !Source				;\
		SEC : SBC.w #!V_cache			; | Y = index to input image
		TAY					;/
		CLC : ADC !ByteCount			;\ value that Y will stop at
		STA !TempPtr1				;/

		PEA $6040				; banks
		PLB					; set bank $40
		LDX #$07FE				;\
	-	STZ.w !GFX_buffer,x			; | clear output buffer (but not work space)
		DEX #2 : BPL -				;/
		PLB					; set bank to virtual buffer area

		LDA !InputW				;\
		LSR A					; | starting shear value for transformation 1
		STA !PixelShift				;/ (halved since image is still small)


		LDX #$0000
		LDA !InputW
		CMP #$0008 : BEQ +
		LDX #$0002
		CMP #$0010 : BEQ +
		LDX #$0004
	+	LDA.l .bulkptr,x : STA !TempPtr2


; DO NOT WORRY ABOUT NEGATIVE INDEX HERE!!
; because the transfer is aimed at offset w^2+(w/2) in the buffer, the negative offset will not cause problems!

macro bulkrow(px)
	LDA.w !V_cache+<px>,y
	STA.w !V_buffer+<px>,x
endmacro


	.BulkLoop
		LDA !PixelShift : STA.l $2251		;\
		LDA !ShearX : STA.l $2253		; |
		NOP : BRA $00				; |
		LDA.l $2306				; |
		CLC : ADC #$0080			; > round number
		XBA					; |
		AND #$00FF				; | number of pixels to shift row (signed)
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		STA !IndexScratch			;/

		TYA					;\
		ASL A					; |
		CLC : ADC !ByteCount			; | update buffer index to accomodate X shear
		CLC : ADC !TempSize			; | X = 2Y + w^2 + w/2 + ShearX
		CLC : ADC !IndexScratch			; |
		TAX					;/



		PEI (!TempPtr2)
		RTS


	.bulkptr
		dw .bulkrow8-1
		dw .bulkrow16-1
		dw .bulkrow32-1



	.bulkrow8
		%bulkrow(0)
		%bulkrow(2)
		%bulkrow(4)
		%bulkrow(6)
		JMP .nextbulk

	.bulkrow16
		%bulkrow($0)
		%bulkrow($2)
		%bulkrow($4)
		%bulkrow($6)
		%bulkrow($8)
		%bulkrow($A)
		%bulkrow($C)
		%bulkrow($E)
		JMP .nextbulk

	.bulkrow32
		%bulkrow($00)
		%bulkrow($02)
		%bulkrow($04)
		%bulkrow($06)
		%bulkrow($08)
		%bulkrow($0A)
		%bulkrow($0C)
		%bulkrow($0E)
		%bulkrow($10)
		%bulkrow($12)
		%bulkrow($14)
		%bulkrow($16)
		%bulkrow($18)
		%bulkrow($1A)
		%bulkrow($1C)
		%bulkrow($1E)

	.nextbulk
		TYA
		CLC : ADC !InputW
		TAY
		CPY !TempPtr1 : BCS .X1Done		; check for entire image being copied
		DEC !PixelShift				; decrement pixel shifter
		JMP .BulkLoop				; go to next row

	.X1Done

		RTS



	.Y

		PEA $6060
		PLB : PLB

		LDA !InputW : STA !PixelShift		; starting Y shear distance
		ASL A					;\ buffer width (we need this since we're moving columns)
		STA !TempSize				;/
		ASL !ByteCount				;\ $06 = buffer size (rather than input size)
		ASL !ByteCount				;/




		LDY #$0000
		LDX #$0000
		LDA !InputW
		CMP #$0008 : BEQ +
		LDX #$0004
		CMP #$0010 : BEQ +
		LDX #$0008
	+	LDA !ShearY
		BMI $02 : INX #2
		LDA.l .ColumnPtr,x : STA !IndexScratch
		TXA					;\
		EOR #$0002				; | this address will replace halfway through
		TAX					; |
		LDA.l .ColumnPtr,x : STA !TempPtr3	;/
		LDA.l .SizePtr,x : STA !TempPtr1
		LDA.w #.SizePtr>>16 : STA !TempPtr1+2




	.LoopY
		LDA !PixelShift : STA.l $2251
		LDA !ShearY : STA.l $2253

	LDA [!TempPtr1],y			;\
	AND #$00FF				; |
	SEC : SBC !InputW			; |
	EOR #$FFFF : INC A			; |
	STA !TempPtr2				; |
	ASL A					; |
	ADC !TempPtr2				; | push code address
	ASL A					; | offset by 6(w-h)
	ADC !IndexScratch			; |
	PHA					;/

		LDA.l $2306
		CLC : ADC #$0080
		XBA
		AND #$00FF				; number of pixels to shift column
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |

		STA.l $2251				;\
		LDA !InputW				; |
		ASL A					; |
		STA.l $2253				; | X = (amount to shift * size * 2) + x800 + column
		TYA					; |
		ORA #$0800				; |
		CLC					; |
		ADC.l $2306				; |
		TAX					;/


		SEP #$20

	RTS


macro pxcolumn(px, size)
	LDA.w !V_buffer+(<size>*<size>)+(<px>*<size>*2),y
	STA.w !V_buffer+$800+(<size>*<size>)+(<px>*<size>*2),x
endmacro

; remember to always add $800 to X during index calculation
; the address offset is reduced by $800 to allow for "negative" indexing, so pixel columns can be shifted up as well


	.ColumnPtr
		dw .Column8Up-1		; 0
		dw .Column8Down-1	; 2
		dw .Column16Up-1	; 4
		dw .Column16Down-1	; 6
		dw .Column32Up-1	; 8
		dw .Column32Down-1	; A
	.SizePtr
		dw YShear8		; 0
		dw YShear8		; 2
		dw YShear16		; 4
		dw YShear16		; 6
		dw YShear32		; 8
		dw YShear32		; A

	.Column8Up
	..8	%pxcolumn(0, 8)				;\
	..7	%pxcolumn(1, 8)				; |
		%pxcolumn(2, 8)				; |
	..5	%pxcolumn(3, 8)				; | move 8px column up
		%pxcolumn(4, 8)				; |
	..3	%pxcolumn(5, 8)				; |
		%pxcolumn(6, 8)				; |
	..1	%pxcolumn(7, 8)				;/
		JMP .NextColumn				; go to next column

	.Column8Down
	..8	%pxcolumn(7, 8)				;\
	..7	%pxcolumn(6, 8)				; |
		%pxcolumn(5, 8)				; |
	..5	%pxcolumn(4, 8)				; | move 8px column down
		%pxcolumn(3, 8)				; |
	..3	%pxcolumn(2, 8)				; |
		%pxcolumn(1, 8)				; |
	..1	%pxcolumn(0, 8)				;/
		JMP .NextColumn				; go to next column

	.Column16Up
	..10	%pxcolumn($0, 16)			;\
	..F	%pxcolumn($1, 16)			; |
		%pxcolumn($2, 16)			; |
	..D	%pxcolumn($3, 16)			; |
		%pxcolumn($4, 16)			; |
	..B	%pxcolumn($5, 16)			; |
		%pxcolumn($6, 16)			; |
	..9	%pxcolumn($7, 16)			; | move 16px column up
		%pxcolumn($8, 16)			; |
	..7	%pxcolumn($9, 16)			; |
		%pxcolumn($A, 16)			; |
	..5	%pxcolumn($B, 16)			; |
		%pxcolumn($C, 16)			; |
	..3	%pxcolumn($D, 16)			; |
		%pxcolumn($E, 16)			; |
	..1	%pxcolumn($F, 16)			;/
		JMP .NextColumn				; go to next column

	.Column16Down
	..10	%pxcolumn($F, 16)			;\
	..F	%pxcolumn($E, 16)			; |
		%pxcolumn($D, 16)			; |
	..D	%pxcolumn($C, 16)			; |
		%pxcolumn($B, 16)			; |
	..B	%pxcolumn($A, 16)			; |
		%pxcolumn($9, 16)			; |
	..9	%pxcolumn($8, 16)			; | move 16px column down
		%pxcolumn($7, 16)			; |
	..7	%pxcolumn($6, 16)			; |
		%pxcolumn($5, 16)			; |
	..5	%pxcolumn($4, 16)			; |
		%pxcolumn($3, 16)			; |
	..3	%pxcolumn($2, 16)			; |
		%pxcolumn($1, 16)			; |
	..1	%pxcolumn($0, 16)			;/
		JMP .NextColumn				; go to next column

	.Column32Up
	..20	%pxcolumn($00, 32)			;\
	..1F	%pxcolumn($01, 32)			; |
		%pxcolumn($02, 32)			; |
	..1D	%pxcolumn($03, 32)			; |
		%pxcolumn($04, 32)			; |
	..1B	%pxcolumn($05, 32)			; |
		%pxcolumn($06, 32)			; |
	..19	%pxcolumn($07, 32)			; |
		%pxcolumn($08, 32)			; |
	..17	%pxcolumn($09, 32)			; |
		%pxcolumn($0A, 32)			; |
	..15	%pxcolumn($0B, 32)			; |
		%pxcolumn($0C, 32)			; |
	..13	%pxcolumn($0D, 32)			; |
		%pxcolumn($0E, 32)			; | move 32px column up
	..11	%pxcolumn($0F, 32)			; |
		%pxcolumn($10, 32)			; |
	..F	%pxcolumn($11, 32)			; |
		%pxcolumn($12, 32)			; |
	..D	%pxcolumn($13, 32)			; |
		%pxcolumn($14, 32)			; |
	..B	%pxcolumn($15, 32)			; |
		%pxcolumn($16, 32)			; |
	..9	%pxcolumn($17, 32)			; |
		%pxcolumn($18, 32)			; |
	..7	%pxcolumn($19, 32)			; |
		%pxcolumn($1A, 32)			; |
	..5	%pxcolumn($1B, 32)			; |
		%pxcolumn($1C, 32)			; |
	..3	%pxcolumn($1D, 32)			; |
		%pxcolumn($1E, 32)			; |
	..1	%pxcolumn($1F, 32)			;/
		JMP .NextColumn				; go to next column

	.Column32Down
	..20	%pxcolumn($1F, 32)			;\
	..1F	%pxcolumn($1E, 32)			; |
		%pxcolumn($1D, 32)			; |
	..1D	%pxcolumn($1C, 32)			; |
		%pxcolumn($1B, 32)			; |
	..1B	%pxcolumn($1A, 32)			; |
		%pxcolumn($19, 32)			; |
	..19	%pxcolumn($18, 32)			; |
		%pxcolumn($17, 32)			; |
	..17	%pxcolumn($16, 32)			; |
		%pxcolumn($15, 32)			; |
	..15	%pxcolumn($14, 32)			; |
		%pxcolumn($13, 32)			; |
	..13	%pxcolumn($12, 32)			; | move 32px column down
		%pxcolumn($11, 32)			; |
	..11	%pxcolumn($10, 32)			; |
		%pxcolumn($0F, 32)			; |
	..F	%pxcolumn($0E, 32)			; |
		%pxcolumn($0D, 32)			; |
	..D	%pxcolumn($0C, 32)			; |
		%pxcolumn($0B, 32)			; |
	..B	%pxcolumn($0A, 32)			; |
		%pxcolumn($09, 32)			; |
	..9	%pxcolumn($08, 32)			; |
		%pxcolumn($07, 32)			; |
	..7	%pxcolumn($06, 32)			; |
		%pxcolumn($05, 32)			; |
	..5	%pxcolumn($04, 32)			; |
		%pxcolumn($03, 32)			; |
	..3	%pxcolumn($02, 32)			; |
		%pxcolumn($01, 32)			; |
	..1	%pxcolumn($00, 32)			;/

	.NextColumn
		REP #$20
		INY
		CPY !TempSize : BEQ .YShearDone
		LDA !PixelShift : BNE +			;\ swap to secondary pointer halfway through
		LDA !TempPtr3 : STA !IndexScratch	;/
	+	DEC !PixelShift				; decrement pixel shifter
		JMP .LoopY

	.YShearDone

		RTS



	.X2

		PEA $6040				;\
		PLB					; |
		LDX #$07FE				; | clear output buffer
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				; |
		PLB					;/



	; I need to clear the output buffer before doing the final X shear
	; otherwise the image will be duplicated in some parts

	; now, finally, we have to X shear the entire buffer to push the rows back together
	; this will put the final, rotated, image in !GFX_buffer
	; the final size is 4w^2 bytes
	; (but loading just w^2 bytes from !GFX_buffer+w^2+(w/2) will work for roundish objects)

	; this time we have to actually be careful with empty bytes to avoid overflowing the buffer
	; because of this we can only transfer 1 byte per cycle
	; to make this faster, we're going to partially unroll the loop, moving 1 row at a time





	; check for fixed size here
		LDA !Rotate
		AND #$0001 : BEQ .Resize
		JMP FixedSize
		.Resize


macro pxrow(px)
	LDA.w !V_buffer+$1000+<px>,y
	BEQ ?Empty
	STA.w !V_buffer-$800+<px>,x
	?Empty:
endmacro


		LDA !InputW				;\
		STA.l $2251				; | calculate size of top 8th
		STA.l $2253				;/
		STA !IndexScratch			;\
		ASL A					; |
		ADC !IndexScratch			; | calculate pixel shift (.75w)
		LSR #2					; |
		STA !PixelShift				;/
		LDA.l $2306				;\
		LSR A					; | skip top 8th
		TAY					;/
		SEC : SBC !ByteCount			;\
		EOR #$FFFF : INC A			; | skip bottom 8th
		STA !ByteCount				;/



	.LoopX2	LDA !PixelShift : STA.l $2251		;\
		LDA !ShearX : STA.l $2253		; |
		NOP : BRA $00				; |
		LDA.l $2306				; |
		CLC : ADC #$0080			; > round number
		XBA					; |
		AND #$00FF				; | number of pixels to shift row (signed)
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		STA !IndexScratch			;/
		TYA					;\
		CLC : ADC #$0800			; | X = Y + 0x800 + shear offset
		CLC : ADC !IndexScratch			; |
		TAX					;/

		SEP #$20
		LDA !InputW
		CMP #$08 : BEQ .Row8
		CMP #$10 : BEQ +
		JMP .Row32
	+	JMP .Row16

	.Row8
		%pxrow($0)				;\
		%pxrow($1)				; |
		%pxrow($2)				; |
		%pxrow($3)				; |
		%pxrow($4)				; |
		%pxrow($5)				; |
		%pxrow($6)				; |
		%pxrow($7)				; |
		%pxrow($8)				; | copy a 16px row
		%pxrow($9)				; | (full buffer to make sure the whole image is transformed)
		%pxrow($A)				; |
		%pxrow($B)				; |
		%pxrow($C)				; |
		%pxrow($D)				; |
		%pxrow($E)				; |
		%pxrow($F)				;/
		JMP .NextRow

	.Row16
		%pxrow($00)				;\
		%pxrow($01)				; |
		%pxrow($02)				; |
		%pxrow($03)				; |
		%pxrow($04)				; |
		%pxrow($05)				; |
		%pxrow($06)				; |
		%pxrow($07)				; |
		%pxrow($08)				; |
		%pxrow($09)				; |
		%pxrow($0A)				; |
		%pxrow($0B)				; |
		%pxrow($0C)				; |
		%pxrow($0D)				; |
		%pxrow($0E)				; |
		%pxrow($0F)				; | copy a 32px row
		%pxrow($10)				; |
		%pxrow($11)				; |
		%pxrow($12)				; |
		%pxrow($13)				; |
		%pxrow($14)				; |
		%pxrow($15)				; |
		%pxrow($16)				; |
		%pxrow($17)				; |
		%pxrow($18)				; |
		%pxrow($19)				; |
		%pxrow($1A)				; |
		%pxrow($1B)				; |
		%pxrow($1C)				; |
		%pxrow($1D)				; |
		%pxrow($1E)				; |
		%pxrow($1F)				;/
		JMP .NextRow

	.Row32
		%pxrow($00)				;\
		%pxrow($01)				; |
		%pxrow($02)				; |
		%pxrow($03)				; |
		%pxrow($04)				; |
		%pxrow($05)				; |
		%pxrow($06)				; |
		%pxrow($07)				; |
		%pxrow($08)				; |
		%pxrow($09)				; |
		%pxrow($0A)				; |
		%pxrow($0B)				; |
		%pxrow($0C)				; |
		%pxrow($0D)				; |
		%pxrow($0E)				; |
		%pxrow($0F)				; |
		%pxrow($10)				; |
		%pxrow($11)				; |
		%pxrow($12)				; |
		%pxrow($13)				; |
		%pxrow($14)				; | copy a 64px row
		%pxrow($15)				; |
		%pxrow($16)				; |
		%pxrow($17)				; |
		%pxrow($18)				; |
		%pxrow($19)				; |
		%pxrow($1A)				; |
		%pxrow($1B)				; |
		%pxrow($1C)				; |
		%pxrow($1D)				; |
		%pxrow($1E)				; |
		%pxrow($1F)				; |
		%pxrow($20)				; |
		%pxrow($21)				; |
		%pxrow($22)				; |
		%pxrow($23)				; |
		%pxrow($24)				; |
		%pxrow($25)				; |
		%pxrow($26)				; |
		%pxrow($27)				; |
		%pxrow($28)				; |
		%pxrow($29)				; |
		%pxrow($2A)				; |
		%pxrow($2B)				; |
		%pxrow($2C)				; |
		%pxrow($2D)				; |
		%pxrow($2E)				; |
		%pxrow($2F)				; |
		%pxrow($30)				; |
		%pxrow($31)				; |
		%pxrow($32)				; |
		%pxrow($33)				; |
		%pxrow($34)				; |
		%pxrow($35)				; |
		%pxrow($36)				; |
		%pxrow($37)				; |
		%pxrow($38)				; |
		%pxrow($39)				; |
		%pxrow($3A)				; |
		%pxrow($3B)				; |
		%pxrow($3C)				; |
		%pxrow($3D)				; |
		%pxrow($3E)				; |
		%pxrow($3F)				;/


	.NextRow
		REP #$20
		TYA
		CLC : ADC !TempSize
		CMP !ByteCount : BEQ .ImageDone
		TAY
		DEC !PixelShift				; decrement pixel shifter
		JMP .LoopX2


	.ImageDone

		RTS


	FixedSize:

		LDX #$0000
		LDA !InputW
		STA.l $2251
		STA.l $2253
		LSR A
		STA !PixelShift				; start at 50% since we're copying 50% up and down
		STA !TempSize
		LDA.l $2306 : STA !ByteCount


	.Loop	LDA !PixelShift : STA.l $2251		;\
		LDA !ShearX : STA.l $2253		; |
		NOP : BRA $00				; |
		LDA.l $2306				; |
		CLC : ADC #$0080			; > round number
		XBA					; |
		AND #$00FF				; | number of pixels to shift row (signed)
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		STA !IndexScratch			;/
		TXA					;\
		ASL A					; |
		ADC !ByteCount				; | calculate Y
		ADC !TempSize				; |
		SEC : SBC !IndexScratch			; |
		TAY					;/


macro fixedrow(px)
	LDA.w !V_buffer+<px>+$1000,y
	STA.w !V_buffer+<px>,x
endmacro



		LDA !InputW
		CMP #$0008 : BEQ .Row8
		CMP #$0010 : BEQ +
		JMP .Row32
	+	JMP .Row16

	.Row8
		%fixedrow(0)				;\
		%fixedrow(2)				; |
		%fixedrow(4)				; |
		%fixedrow(6)				;/
		JMP .NextRow

	.Row16
		%fixedrow($0)				;\
		%fixedrow($2)				; |
		%fixedrow($4)				; |
		%fixedrow($6)				; |
		%fixedrow($8)				; |
		%fixedrow($A)				; |
		%fixedrow($C)				; |
		%fixedrow($E)				;/
		JMP .NextRow

	.Row32
		%fixedrow($00)				;\
		%fixedrow($02)				; |
		%fixedrow($04)				; |
		%fixedrow($06)				; |
		%fixedrow($08)				; |
		%fixedrow($0A)				; |
		%fixedrow($0C)				; |
		%fixedrow($0E)				; |
		%fixedrow($10)				; |
		%fixedrow($12)				; |
		%fixedrow($14)				; |
		%fixedrow($16)				; |
		%fixedrow($18)				; |
		%fixedrow($1A)				; |
		%fixedrow($1C)				; |
		%fixedrow($1E)				;/




	.NextRow
		TXA
		CLC : ADC !InputW
		CMP !ByteCount : BCS .ImageDone
		TAX
		DEC !PixelShift				; decrement pixel shifter
		JMP .Loop


	.ImageDone

		LSR !InputW

		RTS






YShear8:	db $01,$03,$05,$07,$08,$08,$08,$08,$08,$08,$08,$08,$07,$05,$03,$01

YShear16:	db $01,$03,$05,$07,$09,$0B,$0D,$0F,$10,$10,$10,$10,$10,$10,$10,$10
		db $10,$10,$10,$10,$10,$10,$10,$10,$0F,$0D,$0B,$09,$07,$05,$03,$01

YShear32:	db $01,$03,$05,$07,$09,$0B,$0D,$0F,$11,$13,$15,$17,$19,$1B,$1D,$1F
		db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
		db $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
		db $1F,$1D,$1B,$19,$17,$15,$13,$11,$0F,$0D,$0B,$09,$07,$05,$03,$01


tan:	dw $FF00,$FF07,$FF0D,$FF13,$FF18,$FF1E,$FF24,$FF29,$FF2E,$FF34,$FF39,$FF3E,$FF43,$FF47,$FF4C,$FF51	; -45
	dw $FF55,$FF5A,$FF5E,$FF63,$FF67,$FF6B,$FF6F,$FF74,$FF78,$FF7C,$FF80,$FF84,$FF87,$FF8B,$FF8F,$FF93
	dw $FF96,$FF9A,$FF9E,$FFA1,$FFA5,$FFA8,$FFAC,$FFAF,$FFB3,$FFB6,$FFBA,$FFBD,$FFC0,$FFC4,$FFC7,$FFCA
	dw $FFCE,$FFD1,$FFD4,$FFD7,$FFDB,$FFDE,$FFE1,$FFE4,$FFE7,$FFEA,$FFEE,$FFF1,$FFF4,$FFF7,$FFFA,$FFFD
	dw $0000,$0003,$0006,$0009,$000C,$000F,$0012,$0016,$0019,$001C,$001F,$0022,$0025,$0029,$002C,$002F	;00.00
	dw $0032,$0036,$0039,$003C,$0040,$0043,$0046,$004A,$004D,$0051,$0054,$0058,$005B,$005F,$0062,$0066	;11.25
	dw $006A,$006D,$0071,$0075,$0079,$007C,$0080,$0084,$0088,$008C,$0091,$0095,$0099,$009D,$00A2,$00A6	;22.50
	dw $00AB,$00AF,$00B4,$00B9,$00BD,$00C2,$00C7,$00CC,$00D2,$00D7,$00DC,$00E2,$00E8,$00ED,$00F3,$00F9	;33.75 






	Flat0:

		LDA !InputW
		STA.l $2251
		STA.l $2253
		LDA !Source
		SEC : SBC.w #!V_cache
		TAY
		LDA.l $2306 : STA !ByteCount
		CLC : ADC.w #!V_cache
		STA !IndexScratch

		LDA !Rotate
		AND #$0001 : BNE .Fixed

	.Resize
		PEA $6040				;\
		PLB					; |
		LDX #$07FE				; | clear output buffer
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				; |
		PLB					;/

		LDA !InputW
		DEC A
		STA !BitCheck
		INC A
		CLC : ADC !ByteCount
		TAX

	-	LDA.w !V_cache,y : STA.w !V_buffer,x	;\
		INX #2					; |
		INY #2					; |
		CPY !IndexScratch : BCS .Done		; |
		TYA					; | transfer with double size
		AND !BitCheck : BNE -			; |
		TXA					; |
		CLC : ADC !InputW			; |
		TAX					; |
		BRA -					;/

	.Fixed
		PEA $6060
		PLB : PLB
		LDX #$0000				;\
	-	LDA.w !V_cache,y : STA !V_buffer,x	; |
		INY #2					; | just copy to buffer
		INX #2					; |
		CPX !ByteCount : BNE -			;/

	.Done
		LDA #$CCCC : STA !Stages		; mark that image is finished rendering
		RTS





; normal version takes the coordinates of all input pixels, inverts them, and assembles them in output image
; output image is same byte size as input image but centered in buffer and doubled in size format

	Flat180:
		PEA $6040				;\
		PLB					; |
		LDX #$07FE				; | clear output buffer
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				; |
		PLB					;/



		LDA !InputW
		STA.l $2251
		STA.l $2253
		LSR A
		STA !TempSize

		LDA !Rotate
		AND #$0001 : BEQ .Resize

	.FixedSize
		LDA.l $2306
		TAY
		DEY
		LDX #$0000
		SEP #$20
	-	LDA (!Source),y : STA.w !V_buffer,x
		INX
		DEY : BPL -
		RTS


	.Resize
		LDA !InputW
		ASL A
		SEC : SBC !TempSize
		STA !TempSize				; bit check complement
		LDA !InputW
		ASL A
		DEC A
		STA !BitCheck				; bit check

		LDA.l $2306
		TAY
		DEY					; Y = input buffer
		ASL A
		ADC !InputW
		LSR A
		TAX					; X = buffer index

		SEP #$20
	-	LDA (!Source),y : STA !V_buffer,x	; copy pixel to inverse offset
		DEY : BMI .Done				; decrement input index
		INX					; increment buffer index
		TXA					;\
		AND !BitCheck				; | check for end of row
		CMP !TempSize : BNE -			;/
		REP #$20
		TXA					;\
		CLC : ADC !InputW			; | go to next row
		TAX					; |
		SEP #$20				; |
		BRA -					;/

	.Done
		LDA #$CC : STA !Stages+1		; mark that image is finished rendering
		RTS





	; add version inverts the coordinates of all pixels in the output image
	; don't worry about fixed size here, just set the buffer up beforehand
	; (if fixed size is set, image in buffer should already be the right size)

	.Add	PEA $6060
		PLB : PLB
		LDA !InputW
		ASL A
		STA.l $2251
		STA.l $2253
		LDY #$0000				; Y = start of buffer
		BRA $00
		LDA.l $2306
		TAX
		DEX					; X = end of buffer -1
		LSR A
		STA !ByteCount				; end loop at half buffer

		SEP #$20

	-	LDA.w !V_buffer,y : XBA
		LDA.w !V_buffer,x : STA.w !V_buffer,y
		XBA : STA.w !V_buffer,x
		INY
		DEX
		CPY !ByteCount : BNE -

		LDA #$CC : STA !Stages+1		; mark that image is finished rendering
		RTS



	Flat90:
		PEA $6040				;\
		PLB					; |
		LDX #$07FE				; | clear output buffer
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				; |
		PLB					;/


		LDA !InputW
		STA.l $2251
		STA.l $2253
		DEC A
		STA !BitCheck
		LDA !Source
		SEC : SBC.w #!V_cache
		TAY
		LDA.l $2306 : STA !ByteCount
		CLC : ADC.w #!V_cache
		STA !IndexScratch
		LDA !InputW
		LSR A
		STA !TempSize


		LDA !Rotate
		AND #$0001 : BEQ .Resize
		LDX #$0000

	-	LDA.w !V_cache,y : STA.w !V_buffer,x
		INY #2
		INX #2
		CPX !ByteCount : BCC -
		BRA .Fixed


		.Resize
	--	TYA
		ASL A
		CLC : ADC !ByteCount
		CLC : ADC !TempSize
		TAX

	-	LDA.w !V_cache,y : STA.w !V_buffer,x
		INY #2
		INX #2
		CPY !IndexScratch : BCS .Add
		TYA
		AND !BitCheck : BNE -
		BRA --


	.Add	PEA $6060
		PLB : PLB
		ASL !InputW
	.Fixed	LDA !InputW
		STA.l $2251
		STA.l $2253
		DEC A
		STA !TempSize
		STA !BitCheck				; useful for calculating B and D
		STZ !PixelShift
		LDA.l $2306
		DEC A
		STA !ByteCount				; useful for finding C


	--	LDA !InputW : STA.l $2251
		LDA !PixelShift : STA.l $2253
		STZ !OutputX
		CLC
		NOP
		ADC.l $2306
		STA !PointA				; A = XW + X
		EOR !BitCheck
		STA !PointB				; B is mirrored from A

		LDA !ByteCount
		SEC : SBC !PointA
		STA !PointC				; C = W^2 - A
		EOR !BitCheck
		STA !PointD				; D is mirrored from C


	-	SEP #$20
		LDY !PointA				;\
		LDA.w !V_buffer,y : STA !pxA		; |
		LDY !PointB				; |
		LDA.w !V_buffer,y : STA !pxB		; | copy A, B, and C, then get ready to load D
		LDY !PointC				; |
		LDA.w !V_buffer,y : STA !pxC		; |
		LDY !PointD				;/
		LDA !Angle+1 : BNE .270deg		; see if going clockwise or counterclockwise

	.90deg	LDA.w !V_buffer,y			;\
		LDY !PointA				; |
		STA.w !V_buffer,y			; |
		LDY !PointB				; |
		LDA !pxA : STA.w !V_buffer,y		; | clockwise: A -> B, B -> C, C -> D, D -> A
		LDY !PointC				; |
		LDA !pxB : STA.w !V_buffer,y		; |
		LDY !PointD				; |
		LDA !pxC : STA.w !V_buffer,y		;/
		BRA .NextPx				; next pixel

	.270deg	LDA.w !V_buffer,y			;\
		LDY !PointC				; |
		STA.w !V_buffer,y			; |
		LDY !PointB				; |
		LDA !pxC : STA.w !V_buffer,y		; | counterclockwise: A -> D, B -> A, C -> B, D -> C
		LDY !PointA				; |
		LDA !pxB : STA.w !V_buffer,y		; |
		LDY !PointD				; |
		LDA !pxA : STA.w !V_buffer,y		;/


	.NextPx	REP #$20
		INC !OutputX
		LDA !OutputX
		CMP !TempSize : BEQ .NextRow


		INC !PointA
		LDA !PointB
		CLC : ADC !InputW
		STA !PointB
		DEC !PointC
		LDA !PointD
		SEC : SBC !InputW
		STA !PointD
		BRA -

	.NextRow
		LDA !TempSize
		DEC #2
		BMI .Done
		BEQ .Done
		STA !TempSize
		INC !PixelShift
		JMP --

	.Done
		LDA #$CCCC : STA !Stages		; mark that image is finished rendering
		RTS






;	growth width = ((!ScaleX + 1) * 2 + 256) * !InputW / 256
;	shrink width = !ScaleX * !InputW / 256
;
; output image width is:
;	- growth: 2W
;	- shrink: W
;	- half:	W/2
;
; !StartX = Xc - (outputW * Xc)/bufferW
; !StartY = Yc - (outputH * Yc)/bufferH		<- buffer is always square-shaped
;
; ADD FAST VERSIONS FOR X2 AND /2!


	SCALE:
		PHK : PLB

		STZ !PixelsRendered

		LDA !Stages
		BEQ .Init
		BMI .Init

		JMP .Main			; skip init code on subsequent multistage render stages




		.Init
		LDA !InputW : STA $2251
		LDA !ScaleX
		AND #$00FF
		STA !ScaleX
		CMP #$0080 : BCS .CalcX

	.GrowX	INC A
		ASL A
		ADC #$0100
	.CalcX	STA $2253
		LDA !ScaleX
		CMP #$0080
		BCC $03 : EOR #$00FF
		INC A
		ASL A
		STA !SizeFactorX
		LDA $2307 : STA !OutputW

		LDA !ScaleX
		CMP #$0080
		BCC .X2
		BNE .X1

	.Half	LDA !InputW
		LSR A
		BRA .BufferW

	.X1	LDA !InputW
		BRA .BufferW

	.X2	LDA !InputW
		ASL A

	.BufferW
		STA !BufferW




		LDA !InputH : STA $2251
		LDA !ScaleY
		AND #$00FF
		STA !ScaleY
		CMP #$0080 : BCS .CalcY

	.GrowY	INC
		ASL A
		ADC #$0100
	.CalcY	STA $2253
		LDA !ScaleY
		CMP #$0080
		BCC $03 : EOR #$00FF
		INC A
		ASL A
		STA !SizeFactorY
		LDA $2307 : STA !OutputH


		SEP #$10				; index 8 bit
		LDA !InputW : STA $2251			;\
		LDA !InputH : STA $2253			; |
		LDX #$01				; | calculate input image size
		BRA $00					; |
		LDA $2306 : STA !ByteCount		;/
		STA !RenderSize				; > set here for single stage render
		STX $2250				; > set division
		STA $2251				;\
		LDA !MultiStage : BEQ +			; |
		LDY !Rotate				; | > half as many scaling stages during mixed mode
		BEQ $01 : LSR A				; |
		STA $2253				; | calculate number of input pixels to process for each stage
		NOP					; |
		BRA $00					; |
		LDA $2306 : STA !RenderSize		;/
	+	LDX #$00 : STX $2250			; > set multiplication


		LDA !OutputW : STA $2251		;\
		LDA !CenterX : STA $2253		; |
		LDX #$01				; | calculate outputW * Xc
		BRA $00					; |
		LDA $2306				;/
		STX $2250				; > set division
		STA $2251				;\
		LDA !BufferW : STA $2253		; |
		LDX #$00				; | divide by bufferW and subtract from Xc
		LDA !CenterX				; |
		SEC : SBC $2306				;/
		STA !StartX				; starting X coordinate index offset
		STX $2250				; > set multiplication

		LDA !OutputH : STA $2251		;\
		LDA !CenterY : STA $2253		; |
		LDX #$01				; | calculate outputH * Yc
		BRA $00					; |
		LDA $2306				;/
		STX $2250				; > set division
		STA $2251				;\
		LDA !BufferW : STA $2253		; |
		LDX #$00				; | divide by bufferW and subtract from Yc
		LDA !CenterY				; |
		SEC : SBC $2306				;/
		STX $2250				; > set multiplication
		STA $2251				;\
		LDA !BufferW : STA $2253		; |
		NOP					; | multiply by bufferW to get index
		REP #$30				; > all regs 16 bit
		LDA $2306				;/
		STA !StartY				; starting Y coordinate index offset


		PEA $6040				;\
		PLB					; |
		LDX #$07FE				; | clear output buffer
	-	STZ.w !GFX_buffer+$800,x		; |
		DEX #2 : BPL -				; |
		PLB					;/



		LDA !StartX				;\
		CLC : ADC !StartY			; | X = index to top-left corner of output image
		TAX					;/
		LDA !Source				;\
		SEC : SBC.w #!V_cache			; | Y = index to image in cache
		TAY					;/
		STZ !InputY				;\ start at the top of both images
		STZ !OutputY				;/
		LDA !InputW				;\
		DEC A					; | set up input image bit check
		STA !BitCheck				;/

		STZ !SizeMemX
		STZ !SizeMemY

		SEP #$20				;\
		LDA !ScaleX : BPL +			; |
		STA !SizeFactorX			; | simple scale factor for shrink
	+	LDA !ScaleY : BPL +			; |
		STA !SizeFactorY			; |
		+					;/




	.Main
		SEP #$20				; A 8 bit because we can only transfer 1 pixel at a time

		LDA !ScaleX				;\ if X/Y scaling are different, use robust version
		CMP !ScaleY : BNE .Calc			;/
		CMP #$7F : BEQ .Double			;\
		CMP #$80 : BNE .Calc			; | if both are x2, quickly double
		JMP FastHalf				; | if both are /2, quickly halve
	.Double	JMP FastX2				; |
		.Calc					;/


	.LoopY	STZ !SizeMemX
		BIT !ScaleY : BPL .LoopX		; never skip growth rows
		LDA !SizeFactorY			;\
		CLC : ADC !SizeMemY			; |
		STA !SizeMemY				; |
		BCS .LoopX				; | skip shrink row unless overflow is hit
		REP #$20				; |
		TYA					; |
		CLC : ADC !InputW			; |
		TAY					;/
		DEC !OutputY				; offset vertical render position when skipping a row
		JMP .NextRow				; go to next row


	.LoopX	LDA !SizeFactorX
		CLC : ADC !SizeMemX
		STA !SizeMemX
		BCS .OverflowX
		BIT !ScaleX : BMI .Next			; shrink pixels are only copied with overflow
		BRA .Copy				; growth pixels are always copied


	.OverflowX
		BIT !ScaleX : BMI .Copy			; copy pixel for shrink (when overflow is hit)
		LDA.w !V_cache,y : STA.w !V_buffer+$1000,x	;\ growth overflow duplicates the pixel
		INX					;/

	.Copy	LDA.w !V_cache,y : STA.w !V_buffer+$1000,x
		INX

	.Next	INY

		TYA
		AND !BitCheck : BNE .LoopX


		BIT !ScaleY : BMI .NextRow
		LDA !SizeFactorY
		CLC : ADC !SizeMemY
		STA !SizeMemY
		BCC .NextRow

	.DuplicateRow
		PHY
		REP #$20
		LDA !BufferW
		DEC A
		EOR #$FFFF
		STA !IndexScratch
		TXA
		DEC A					; > check for x2 size exception
		AND !IndexScratch			;\ X = start of finished row
		TAX					;/
		CLC : ADC !BufferW			;\ Y = start of next row
		TAY					;/
		STA !IndexScratch			; (store number as loop breaker)


	-	LDA.w !V_buffer+$1000,x : STA.w !V_buffer+$1000,y	;\
		INX #2					; | copy row
		INY #2					; |
		CPX !IndexScratch : BNE -		;/

		INC !OutputY				; increment output Y coordinate

		PLY


	.NextRow
		REP #$20

		LDA !PixelsRendered			;\
		CLC : ADC !InputW			; | if enough pixels have been rendered, end here
		STA !PixelsRendered			; |
		CMP !RenderSize : BCS .Done		;/


		INC !OutputY				; increment output Y coordinate
		LDA !OutputY : STA.l $2251		;\ start calculating new buffer index
		LDA !BufferW : STA.l $2253		;/

		INC !InputY				;\
		LDA !InputY				; | increment input Y coordinate and check for end
		CMP !InputH : BEQ .Done			;/

		LDA.l $2306				;\
		CLC : ADC !StartY			; | X = new buffer index
		CLC : ADC !StartX			; |
		TAX					;/
		SEP #$20				;\ loop, yo!
		JMP .LoopY				;/


	.Done
		REP #$30
		LDA !PixelsRendered			;\
		CMP !ByteCount : BCC .Return		; | if all pixels have been rendered and rotate is disabled,
		LDA !Rotate : BNE .Return		; | mark that image has finished rendering
	.Mark	LDA #$CCCC : STA !Stages		;/
	.Return	RTS




; for circle shape:
;	- !ScaleY is the "circle percentage", where FF is circle and 0 is square
;	- use row as an index to size table
;		- if !InputY = 8, multiply by 8 then add 7
;		- if !InputY = 16, multiply by 4 then add 3
;		- if !InputY = 32, multiply by 2, then add 1
;		- if !InputY = 64, use as a straight index
;
;	- size table entry is called f
;	- to do gradual circle shaping:
;		!OutputW = (!ScaleY * !InputW * f/128 + (256 - !ScaleY) * !InputW) / 256
;		!SizeFactorX = (!ScaleY * 2 * f + 256 * (256 - !ScaleY)) / 256
;
;	- !StartX = (!InputW - !OutputW)/2
;	- always start !SizeMemX at !InputW rather than 0 on a new row (otherwise no rows will be full)
;
;
;
;
;

; SizeTable:
; db $16,$26,$31,$3A,$41,$47,$4D,$52
; db $56,$5B,$5E,$62,$65,$68,$6B,$6D
; db $6F,$72,$74,$75,$77,$78,$7A,$7B
; db $7C,$7D,$7E,$7E,$7F,$7F,$80,$80
; db $80,$80,$7F,$7F,$7E,$7E,$7D,$7C
; db $7B,$7A,$78,$77,$75,$74,$72,$6F
; db $6D,$6B,$68,$65,$62,$5E,$5B,$56
; db $52,$4D,$47,$41,$3A,$31,$26,$16



macro BulkX2(px, size)
	LDA.w !V_cache+<px>,y
	STA.w !V_buffer+$1000+(<px>*2),x
	STA.w !V_buffer+$1000+(<px>*2)+1,x
	STA.w !V_buffer+$1000+(<size>*2)+(<px>*2),x
	STA.w !V_buffer+$1000+(<size>*2)+(<px>*2)+1,x
endmacro




	FastX2:
		LDA !RenderSize				;\
		ASL #2					; | render size is based on output index here
		STA !PixelsRendered			;/
		LDA !Source				;\
		SEC : SBC.w #!V_cache			; | Y = index to image in cache
		TAY					;/
		LDX #$0000				; X = index to work area
		LDA !InputW				;
		CMP #$0008 : BEQ .8to16			; 8: 8 to 16
		CMP #$0010 : BEQ +			; 16: 16 to 32
		JMP .32to64				; any other value: 32 to 64
	+	JMP .16to32


	.8to16
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkX2(0, 8)				;\
		%BulkX2(1, 8)				; |
		%BulkX2(2, 8)				; |
		%BulkX2(3, 8)				; | duplicate pixels
		%BulkX2(4, 8)				; |
		%BulkX2(5, 8)				; |
		%BulkX2(6, 8)				; |
		%BulkX2(7, 8)				;/
		REP #$20				; 16-bit index
		TYA					;\
		CLC : ADC #$0008			; | down 1 row in 8px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0020			; | down 2 rows in 16px output image
		TAX					;/
		CPX #$0100 : BCS ..Done			; loop until 256 (16x16) px have been written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark images as finished rendering
	..Break	RTS


	.16to32
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkX2($0, 16)				;\
		%BulkX2($1, 16)				; |
		%BulkX2($2, 16)				; |
		%BulkX2($3, 16)				; |
		%BulkX2($4, 16)				; |
		%BulkX2($5, 16)				; |
		%BulkX2($6, 16)				; |
		%BulkX2($7, 16)				; |
		%BulkX2($8, 16)				; |
		%BulkX2($9, 16)				; |
		%BulkX2($A, 16)				; |
		%BulkX2($B, 16)				; |
		%BulkX2($C, 16)				; |
		%BulkX2($D, 16)				; |
		%BulkX2($E, 16)				; |
		%BulkX2($F, 16)				;/
		REP #$20
		TYA					;\
		CLC : ADC #$0010			; | down 1 row in 16px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0040			; | down 2 rows in 32px output image
		TAX					;/
		CPX #$0400 : BCS ..Done			; loop until 1024 (32x32) px have been written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark images as finished rendering
	..Break	RTS


	.32to64
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkX2($00, 32)			;\
		%BulkX2($01, 32)			; |
		%BulkX2($02, 32)			; |
		%BulkX2($03, 32)			; |
		%BulkX2($04, 32)			; |
		%BulkX2($05, 32)			; |
		%BulkX2($06, 32)			; |
		%BulkX2($07, 32)			; |
		%BulkX2($08, 32)			; |
		%BulkX2($09, 32)			; |
		%BulkX2($0A, 32)			; |
		%BulkX2($0B, 32)			; |
		%BulkX2($0C, 32)			; |
		%BulkX2($0D, 32)			; |
		%BulkX2($0E, 32)			; |
		%BulkX2($0F, 32)			; |
		%BulkX2($10, 32)			; |
		%BulkX2($11, 32)			; |
		%BulkX2($12, 32)			; |
		%BulkX2($13, 32)			; |
		%BulkX2($14, 32)			; |
		%BulkX2($15, 32)			; |
		%BulkX2($16, 32)			; |
		%BulkX2($17, 32)			; |
		%BulkX2($18, 32)			; |
		%BulkX2($19, 32)			; |
		%BulkX2($1A, 32)			; |
		%BulkX2($1B, 32)			; |
		%BulkX2($1C, 32)			; |
		%BulkX2($1D, 32)			; |
		%BulkX2($1E, 32)			; |
		%BulkX2($1F, 32)			;/
		REP #$20				; 16-bit index
		TYA					;\
		CLC : ADC #$0020			; | down 1 row in 32px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0080			; | down 2 rows in 64px output image
		TAX					;/
		CPX #$1000 : BCS ..Done			; loop until 4096 (64x64) px have been written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark images as finished rendering
	..Break	RTS


macro BulkHalf(px, size)
	LDA.w !V_cache+(<size>*2)+(<px>*2)+1	; add size*2 to skip first row of input
	STA.w !V_buffer+<px>,x
endmacro


	FastHalf:
		LDA !RenderSize				;\
		LSR #2					; | render size is based on output index here
		STA !PixelsRendered			;/
		LDA !Source				;\
		SEC : SBC.w #!V_cache			; | Y = index to image in cache
		TAY					;/
		LDX #$0000				; X = index to work area
		LDA !InputW				;
		CMP #$0008 : BEQ .8to4			; 8: 8 to 4
		CMP #$0010 : BEQ .w16		; 16: 16 to 8
		CMP #$0020 : BEQ .w32		; 32: 32 to 16
	.w64	JMP .64to32				; any other value: 64 to 32
	.w32	JMP .32to16
	.w16	JMP .16to8


	.8to4
	..Loop	SEP #$20					; 1 pixel at a time
		LDA.w !V_cache+1,y : STA !V_buffer+$12,x	;\
		LDA.w !V_cache+3,y : STA !V_buffer+$13,x	; | special case for 8to4 since 4x4 isn't a tile size
		LDA.w !V_cache+5,y : STA !V_buffer+$14,x	; |
		LDA.w !V_cache+7,y : STA !V_buffer+$15,x	;/
		REP #$20					; 16-bit index (Y)
		TYA					;\
		CLC : ADC #$0010			; | down 2 rows in 8px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0008			; | down 1 row in 8px output image
		TAX					;/
		CPX #$0020 : BCC ..Loop			; loop until 16 (4x4) px are written (8x4 in index)
		RTS

	; note that 8to4 does not support multistage rendering



	.16to8
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkHalf(0, 8)				;\
		%BulkHalf(1, 8)				; |
		%BulkHalf(2, 8)				; |
		%BulkHalf(3, 8)				; | shred pixels
		%BulkHalf(4, 8)				; |
		%BulkHalf(5, 8)				; |
		%BulkHalf(6, 8)				; |
		%BulkHalf(7, 8)				;/
		REP #$20				; 16-bit index
		TYA					;\
		CLC : ADC #$0020			; | down 2 rows in 16px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0008			; | down 1 row in 8px output image
		TAX					;/
		CPX #$0040 : BCS ..Done			; loop until 64 (8x8) px are written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark image as finished rendering
	..Break	RTS


	.32to16
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkHalf($0, 16)			;\
		%BulkHalf($1, 16)			; |
		%BulkHalf($2, 16)			; |
		%BulkHalf($3, 16)			; |
		%BulkHalf($4, 16)			; |
		%BulkHalf($5, 16)			; |
		%BulkHalf($6, 16)			; |
		%BulkHalf($7, 16)			; | shred pixels
		%BulkHalf($8, 16)			; |
		%BulkHalf($9, 16)			; |
		%BulkHalf($A, 16)			; |
		%BulkHalf($B, 16)			; |
		%BulkHalf($C, 16)			; |
		%BulkHalf($D, 16)			; |
		%BulkHalf($E, 16)			; |
		%BulkHalf($F, 16)			;/
		REP #$20				; 16-bit index
		TYA					;\
		CLC : ADC #$0040			; | down 2 rows in 32px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0010			; | down 1 row in 16px output image
		TAX					;/
		CPX #$0100 : BCS ..Done			; loop until 256 (16x16) px are written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark image as finished rendering
	..Break	RTS


	.64to32
	..Loop	SEP #$20				; 1 pixel at a time
		%BulkHalf($00, 32)			;\
		%BulkHalf($01, 32)			; |
		%BulkHalf($02, 32)			; |
		%BulkHalf($03, 32)			; |
		%BulkHalf($04, 32)			; |
		%BulkHalf($05, 32)			; |
		%BulkHalf($06, 32)			; |
		%BulkHalf($07, 32)			; |
		%BulkHalf($08, 32)			; |
		%BulkHalf($09, 32)			; |
		%BulkHalf($0A, 32)			; |
		%BulkHalf($0B, 32)			; |
		%BulkHalf($0C, 32)			; |
		%BulkHalf($0D, 32)			; |
		%BulkHalf($0E, 32)			; |
		%BulkHalf($0F, 32)			; | shred pixels
		%BulkHalf($10, 32)			; |
		%BulkHalf($11, 32)			; |
		%BulkHalf($12, 32)			; |
		%BulkHalf($13, 32)			; |
		%BulkHalf($14, 32)			; |
		%BulkHalf($15, 32)			; |
		%BulkHalf($16, 32)			; |
		%BulkHalf($17, 32)			; |
		%BulkHalf($18, 32)			; |
		%BulkHalf($19, 32)			; |
		%BulkHalf($1A, 32)			; |
		%BulkHalf($1B, 32)			; |
		%BulkHalf($1C, 32)			; |
		%BulkHalf($1D, 32)			; |
		%BulkHalf($1E, 32)			; |
		%BulkHalf($1F, 32)			;/
		REP #$20				; 16-bit index
		TYA					;\
		CLC : ADC #$0080			; | down 2 rows in 64px input image
		TAY					;/
		TXA					;\
		CLC : ADC #$0020			; | down 1 row in 32px output image
		TAX					;/
		CPX #$0400 : BCS ..Done			; loop until 1024 (32x32) px are written
		CPX !RenderSize : BCS ..Break		; multistage check
		JMP ..Loop				; loop
	..Done	LDA #$CCCC : STA !Stages		; mark image as finished rendering
	..Break	RTS





; point [!Source], 24-bit, to input image
; expected format is a row of 128px in 4bpp linear

	RenderTriangle:
		PEA $6040				;\
		PLB					; |
		LDX #$1FFE				; | clear all 8KB of transformation memory
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				;/

	PLB

		LDY #$007E				;\
	-	LDA [!Source],y				; | copy input image into work area
		STA.w !V_buffer+$3F80,y		; |
		DEY #2 : BPL -				;/



	;PLB					; bank = virtual VRAM area of buffer


	; source is always read from !V_buffer+$3F80


		LDA #$00FE : STA !SizeFactorX		;\ reset size memory
		STZ !SizeMemX				;/
		LDA #$0080 : STA !InputW		; input width
		DEC A					;\
		EOR #$FFFF				; | reverse bit check for output index
		STA !BitCheck				;/


		LDY #$0000
		LDX #$3F00


	.Loop	LDA !SizeFactorX : STA.l $2251		;\
		LDA !InputW : STA.l $2253		; |
		STX !IndexScratch			; |
		LDA !InputW				; | calculate X displacement
		SEC : SBC.l $2307			; | X0 = (!InputW - !OutputW) / 2
		LSR A					; |
		CLC : ADC !IndexScratch			; |
		TAX					;/

		SEP #$20
	.NextPx	LDA !SizeMemX
		CLC : ADC !SizeFactorX
		STA !SizeMemX
		BCC .Skip

		LDA.w !V_buffer+$3F80,y : STA.w !V_buffer,x
		INX

	.Skip	INY
		CPY !InputW : BCC .NextPx



	.NextRow
		REP #$20
		LDY #$0000
		TXA
		AND !BitCheck
		SEC : SBC !InputW
		TAX
		BCC .Done

		DEC !SizeFactorX
		DEC !SizeFactorX
		STZ !SizeMemX
		BRA .Loop

	.Done
		RTS



	LinearToPlanar:
		LDX #$0000
		LDY #$0000
		SEP #$20
		STZ $2250
		LDA.b #!V_cache>>16 : PHA
		REP #$20
		LDA !InputW
		STA $2251
		STA $2253
		NOP : BRA $00
		LDA $2306 : STA !ByteCount
		PLB


		LDA !InputW
		CMP #$0008 : BEQ .Loop8
		CMP #$0010 : BEQ .Loop16
		CMP #$0020 : BEQ .Jump32
		CMP #$0040 : BEQ .Jump64
		RTS

	.Jump32	JMP .Loop32
	.Jump64	JMP .Loop64

	.Loop8
		LDA (!Source),y : STA $C0		;\
		INY #2					; |
		LDA (!Source),y : STA $C2		; |
		INY #2					; | get row of pixels
		LDA (!Source),y : STA $C4		; |
		INY #2					; |
		LDA (!Source),y : STA $C6		; |
		INY #2					;/

		STZ $E0					;\ clear buffer
		STZ $E2					;/

		PHX
		LDX #$0007
		SEP #$20

	-	LDA $C0,x				;\
		LSR A : ROR $E0				; | rotate bits in
		LSR A : ROR $E1				; | (rightmost pixel goes first and ends up in lowest bits)
		LSR A : ROR $E2				; | (this is how the SNES format works)
		LSR A : ROR $E3				;/
		DEX : BPL -
		REP #$20
		PLX

		LDA $E0 : STA.l !GFX_buffer+$00,x	;\ copy to output
		LDA $E2 : STA.l !GFX_buffer+$10,x	;/

		CPY !ByteCount : BCS .Done		; check if tile is done
		INX #2					;\ if not, then loop
		BRA .Loop8				;/

	.Done
		RTS


	.Loop16
		LDA (!Source),y : STA $C0		;\
		INY #2					; |
		LDA (!Source),y : STA $C2		; |
		INY #2					; | get row of pixels for tile 1
		LDA (!Source),y : STA $C4		; |
		INY #2					; |
		LDA (!Source),y : STA $C6		; |
		INY #2					;/
		LDA (!Source),y : STA $C8		;\
		INY #2					; |
		LDA (!Source),y : STA $CA		; |
		INY #2					; | get row of pixels for tile 2
		LDA (!Source),y : STA $CC		; |
		INY #2					; |
		LDA (!Source),y : STA $CE		; |
		INY #2					;/

		STZ $E0					;\
		STZ $E2					; | clear buffer
		STZ $E4					; |
		STZ $E6					;/

		PHX
		LDX #$0007
		SEP #$20

	-	LDA $C0,x				;\
		LSR A : ROR $E0				; |
		LSR A : ROR $E1				; | rotate bits in for tile 1
		LSR A : ROR $E2				; |
		LSR A : ROR $E3				;/
		LDA $C8,x				;\
		LSR A : ROR $E4				; |
		LSR A : ROR $E5				; | rotate bits in for tile 2
		LSR A : ROR $E6				; |
		LSR A : ROR $E7				;/
		DEX : BPL -
		REP #$20
		PLX

		LDA $E0 : STA.l !GFX_buffer+$00,x	;\
		LDA $E2 : STA.l !GFX_buffer+$10,x	; | copy to output
		LDA $E4 : STA.l !GFX_buffer+$20,x	; |
		LDA $E6 : STA.l !GFX_buffer+$30,x	;/

		CPY !ByteCount : BCS .Done
		INX #2
		CPX #$0010 : BNE +
		LDX #$0040
	+	JMP .Loop16


	.Loop32
		LDA (!Source),y : STA $C0		;\
		INY #2					; |
		LDA (!Source),y : STA $C2		; |
		INY #2					; | get row of pixels for tile 1
		LDA (!Source),y : STA $C4		; |
		INY #2					; |
		LDA (!Source),y : STA $C6		; |
		INY #2					;/
		LDA (!Source),y : STA $C8		;\
		INY #2					; |
		LDA (!Source),y : STA $CA		; |
		INY #2					; | get row of pixels for tile 2
		LDA (!Source),y : STA $CC		; |
		INY #2					; |
		LDA (!Source),y : STA $CE		; |
		INY #2					;/
		LDA (!Source),y : STA $D0		;\
		INY #2					; |
		LDA (!Source),y : STA $D2		; |
		INY #2					; | get row of pixels for tile 3
		LDA (!Source),y : STA $D4		; |
		INY #2					; |
		LDA (!Source),y : STA $D6		; |
		INY #2					;/
		LDA (!Source),y : STA $D8		;\
		INY #2					; |
		LDA (!Source),y : STA $DA		; |
		INY #2					; | get row of pixels for tile 4
		LDA (!Source),y : STA $DC		; |
		INY #2					; |
		LDA (!Source),y : STA $DE		; |
		INY #2					;/

		STZ $E0					;\
		STZ $E2					; |
		STZ $E4					; |
		STZ $E6					; | clear buffer
		STZ $E8					; |
		STZ $EA					; |
		STZ $EC					; |
		STZ $EE					;/

		PHX
		LDX #$0007
		SEP #$20

	-	LDA $C0,x				;\
		LSR A : ROR $E0				; |
		LSR A : ROR $E1				; | rotate bits in for tile 1
		LSR A : ROR $E2				; |
		LSR A : ROR $E3				;/
		LDA $C8,x				;\
		LSR A : ROR $E4				; |
		LSR A : ROR $E5				; | rotate bits in for tile 2
		LSR A : ROR $E6				; |
		LSR A : ROR $E7				;/
		LDA $D0,x				;\
		LSR A : ROR $E8				; |
		LSR A : ROR $E9				; | rotate bits in for tile 3
		LSR A : ROR $EA				; |
		LSR A : ROR $EB				;/
		LDA $D8,x				;\
		LSR A : ROR $EC				; |
		LSR A : ROR $ED				; | rotate bits in for tile 4
		LSR A : ROR $EE				; |
		LSR A : ROR $EF				;/
		DEX : BPL -
		REP #$20
		PLX

		LDA $E0 : STA.l !GFX_buffer+$00,x	;\
		LDA $E2 : STA.l !GFX_buffer+$10,x	; |
		LDA $E4 : STA.l !GFX_buffer+$20,x	; |
		LDA $E6 : STA.l !GFX_buffer+$30,x	; | copy to output
		LDA $E8 : STA.l !GFX_buffer+$40,x	; |
		LDA $EA : STA.l !GFX_buffer+$50,x	; |
		LDA $EC : STA.l !GFX_buffer+$60,x	; |
		LDA $EE : STA.l !GFX_buffer+$70,x	;/

		CPY !ByteCount : BCS ..Done
		INX #2
		TXA
		AND #$000F : BNE +
		TXA
		CLC : ADC #$0070
		TAX
	+	JMP .Loop32

	..Done	RTS


	.Loop64
		LDA (!Source),y : STA $C0		;\
		INY #2					; |
		LDA (!Source),y : STA $C2		; |
		INY #2					; | get row of pixels for tile 1
		LDA (!Source),y : STA $C4		; |
		INY #2					; |
		LDA (!Source),y : STA $C6		; |
		INY #2					;/
		LDA (!Source),y : STA $C8		;\
		INY #2					; |
		LDA (!Source),y : STA $CA		; |
		INY #2					; | get row of pixels for tile 2
		LDA (!Source),y : STA $CC		; |
		INY #2					; |
		LDA (!Source),y : STA $CE		; |
		INY #2					;/
		LDA (!Source),y : STA $D0		;\
		INY #2					; |
		LDA (!Source),y : STA $D2		; |
		INY #2					; | get row of pixels for tile 3
		LDA (!Source),y : STA $D4		; |
		INY #2					; |
		LDA (!Source),y : STA $D6		; |
		INY #2					;/
		LDA (!Source),y : STA $D8		;\
		INY #2					; |
		LDA (!Source),y : STA $DA		; |
		INY #2					; | get row of pixels for tile 4
		LDA (!Source),y : STA $DC		; |
		INY #2					; |
		LDA (!Source),y : STA $DE		; |
		INY #2					;/
		STZ $E0					;\
		STZ $E2					; |
		STZ $E4					; |
		STZ $E6					; | clear buffer for pass 1
		STZ $E8					; |
		STZ $EA					; |
		STZ $EC					; |
		STZ $EE					;/
		PHX					;\
		LDX #$0007				; | setup pass 1
		SEP #$20				;/
	-	LDA $C0,x				;\
		LSR A : ROR $E0				; |
		LSR A : ROR $E1				; | rotate bits in for tile 1
		LSR A : ROR $E2				; |
		LSR A : ROR $E3				;/
		LDA $C8,x				;\
		LSR A : ROR $E4				; |
		LSR A : ROR $E5				; | rotate bits in for tile 2
		LSR A : ROR $E6				; |
		LSR A : ROR $E7				;/
		LDA $D0,x				;\
		LSR A : ROR $E8				; |
		LSR A : ROR $E9				; | rotate bits in for tile 3
		LSR A : ROR $EA				; |
		LSR A : ROR $EB				;/
		LDA $D8,x				;\
		LSR A : ROR $EC				; |
		LSR A : ROR $ED				; | rotate bits in for tile 4
		LSR A : ROR $EE				; |
		LSR A : ROR $EF				;/
		DEX : BPL -				;\
		REP #$20				; | loop pass 1
		PLX					;/
		LDA $E0 : STA.l !GFX_buffer+$00,x	;\
		LDA $E2 : STA.l !GFX_buffer+$10,x	; |
		LDA $E4 : STA.l !GFX_buffer+$20,x	; |
		LDA $E6 : STA.l !GFX_buffer+$30,x	; | output for tiles 1-4
		LDA $E8 : STA.l !GFX_buffer+$40,x	; |
		LDA $EA : STA.l !GFX_buffer+$50,x	; |
		LDA $EC : STA.l !GFX_buffer+$60,x	; |
		LDA $EE : STA.l !GFX_buffer+$70,x	;/

		LDA (!Source),y : STA $C0		;\
		INY #2					; |
		LDA (!Source),y : STA $C2		; |
		INY #2					; | get row of pixels for tile 5
		LDA (!Source),y : STA $C4		; |
		INY #2					; |
		LDA (!Source),y : STA $C6		; |
		INY #2					;/
		LDA (!Source),y : STA $C8		;\
		INY #2					; |
		LDA (!Source),y : STA $CA		; |
		INY #2					; | get row of pixels for tile 6
		LDA (!Source),y : STA $CC		; |
		INY #2					; |
		LDA (!Source),y : STA $CE		; |
		INY #2					;/
		LDA (!Source),y : STA $D0		;\
		INY #2					; |
		LDA (!Source),y : STA $D2		; |
		INY #2					; | get row of pixels for tile 7
		LDA (!Source),y : STA $D4		; |
		INY #2					; |
		LDA (!Source),y : STA $D6		; |
		INY #2					;/
		LDA (!Source),y : STA $D8		;\
		INY #2					; |
		LDA (!Source),y : STA $DA		; |
		INY #2					; | get row of pixels for tile 8
		LDA (!Source),y : STA $DC		; |
		INY #2					; |
		LDA (!Source),y : STA $DE		; |
		INY #2					;/
		STZ $E0					;\
		STZ $E2					; |
		STZ $E4					; |
		STZ $E6					; | clear buffer for pass 2
		STZ $E8					; |
		STZ $EA					; |
		STZ $EC					; |
		STZ $EE					;/
		PHX					;\
		LDX #$0007				; | setup pass 2
		SEP #$20				;/
	-	LDA $C0,x				;\
		LSR A : ROR $E0				; |
		LSR A : ROR $E1				; | rotate bits in for tile 5
		LSR A : ROR $E2				; |
		LSR A : ROR $E3				;/
		LDA $C8,x				;\
		LSR A : ROR $E4				; |
		LSR A : ROR $E5				; | rotate bits in for tile 6
		LSR A : ROR $E6				; |
		LSR A : ROR $E7				;/
		LDA $D0,x				;\
		LSR A : ROR $E8				; |
		LSR A : ROR $E9				; | rotate bits in for tile 7
		LSR A : ROR $EA				; |
		LSR A : ROR $EB				;/
		LDA $D8,x				;\
		LSR A : ROR $EC				; |
		LSR A : ROR $ED				; | rotate bits in for tile 8
		LSR A : ROR $EE				; |
		LSR A : ROR $EF				;/
		DEX : BPL -				;\
		REP #$20				; | loop pass 2
		PLX					;/
		LDA $E0 : STA.l !GFX_buffer+$80,x	;\
		LDA $E2 : STA.l !GFX_buffer+$90,x	; |
		LDA $E4 : STA.l !GFX_buffer+$A0,x	; |
		LDA $E6 : STA.l !GFX_buffer+$B0,x	; | output for tiles 5-8
		LDA $E8 : STA.l !GFX_buffer+$C0,x	; |
		LDA $EA : STA.l !GFX_buffer+$D0,x	; |
		LDA $EC : STA.l !GFX_buffer+$E0,x	; |
		LDA $EE : STA.l !GFX_buffer+$F0,x	;/

		CPY !ByteCount : BCS ..Done
		INX #2
		TXA
		AND #$000F : BNE +
		TXA
		CLC : ADC #$00F0
		TAX
	+	JMP .Loop64

	..Done	RTS







