;===================;
;GFX SCALING ROUTINE;
;===================;
;
;	input:
;
;	A:		stages of render (0->1 stage, 1->2 stages, 2->4 stages, 3->8 stages)
;	$3000:		24-bit pointer to graphics file
;	$3003:		8-bit source width (MAX 32px)
;	$3004:		8-bit source height (MAX 32px)
;	$3005:		8-bit width scaling
;	$3006:		8-bit height scaling
;	$3007:		8-bit center X \ image scales with this point as the center
;	$3008:		8-bit center Y /
;			if higest bit is set, that coordinate is used as an absolute starting coordinate
;			for example, 0xA0 will start at px 0x20
;
;	clear carry to clear buffer
;	set carry to maintain buffer (used for multi-stage render)
;
;	output:
;	- !GFX_buffer:	scaled GFX render
;	- $00:		starting X coord
;	- $02:		starting Y coord
;	- $04:		output height


;	scaling:
;	0-127 uses the growth function, scaling from x1 at 0 to x2 at 127
;	128-255 uses the shrink function, scaling from /1 at 255 to /2 at 128



	!InputX		= $20	; target pixel on source file (X)
	!InputY		= $22	; target pixel on source file (Y)
	!OutputX	= $24	; target pixel on output file (X)
	!OutputY	= $26	; target pixel on output file (Y)

	!InputWidth	= $28
	!InputHeight	= $2A

	!OutputWidth	= $2C	; calculated based on scale
	!OutputHeight	= $2E	; calculated based on scale

	!ScaleX		= $30
	!ScaleY		= $32

	!SizeFactorX	= $34	; 16-bit, set at init
	!SizeFactorY	= $36	; 16-bit, set at init

	!SizeMemX	= $38	; 16-bit, used to determine when to skip/add pixels
	!SizeMemY	= $3A	; 16-bit, used to determine when to skip/add rows

	!StartX		= $3C	; 16-bit, set at init, left border of output image
	!StartY		= $3E	; 16-bit, left for output

	!PixelCount	= $40	; 16-bit, number of input pixels to render

	!Y1		= $1C	;\ 16-bit used to make index calculations more efficient
	!Y2		= $1E	;/


	!Bits		= $42	; 4 bytes, used to transfer data to buffer

	!PrevOutputX	= $46	;\ 16-bit, used to calculate new output Y index
	!PrevOutputY	= $48	;/



	!ScaleBackup	= !GFX_buffer+$900	; 64 bytes, backup of all regs for multi-stage render



;	method:
;		- divide [256] x [source dimension] / [output dimension], save as size factor
;		- go through source GFX px by px, left -> right, top -> bottom
;		- for each left -> right step, add size factor X to size memory X
;		- IF GROWTH, add a pixel if size memory X overflows
;		- IF SHRINK, add 256 instead, then skip this pixel unless size memory X equals size factor X or more
;		- for each top - > bottom step, add size factor Y to size memory Y
;		- IF GROWTH, copy previous row if size memory Y overflows
;		- IF SHRINK, add 256 instead, then skip this row unless size memory Y equals size factor Y or more


; Source GFX:
;  P1   P2   P1   P2   P1   P2   P1   P2
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 00-07
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 08-0F
;  P3   P4   P3   P4   P3   P4   P3   P4
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 10-17
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 18-1F




SCALE_GFX:	PHB : PHK : PLB

		STA $0C						; > put multi-render flag in $0C
		STZ $0E						;\ put carry in lowest bit of $0E
		ROL $0E						;/

		PHP
		SEP #$20
		TSC
		XBA
		CMP #$37 : BNE .SNES
		JSL .SA1
		PLP
		PLB
		RTL

		.SNES
		JSR .Call
		PLP
		PLB
		RTL


		.Call
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JMP $1E80


		.SA1
		PHP : SEP #$30					;
		PHD						;
		PHB : PHK : PLB					; bank wrapper

		LDY #$02
		LDX #$01

	.SizeLoop
		SEP #$20
		LDA #$00
		STA.w !BigRAM+!ScaleX+1,y
		STA.w !BigRAM+!InputWidth+1,y
		LDA $03,x : STA.w !BigRAM+!InputWidth,y

		LDA $05,x
		STA.w !BigRAM+!ScaleX,y
		BPL .GrowInit

	.ShrinkInit
		LDA #$01 : STA $2250				; division
		LDA $03,x : STA $2252				;\ source X * 256
		STZ $2251					;/
		REP #$20					;\
		LDA $05,x					; |
		AND #$00FF					; |
		EOR #$00FF					; |
		INC A						; | divide by number derived from factor
		ASL A						; | (scales from 258-512)
		CLC : ADC #$0100				; | you can't divide by 1, not that you'd want to
		STA $2253					;/
		STA.w !BigRAM+!SizeFactorX,y			; set size factor (scales 258-512)
		BRA $00
		LDA $2306
		AND #$00FF
		BRA .SetSize


	.GrowInit
		STZ $2250					; multiplication
		LDA $03,x : STA $2251				;\ source X
		STZ $2252					;/
		REP #$20					;\
		LDA $05,x					; |
		AND #$00FF					; |
		INC A						; |
		ASL A						; |
		CLC : ADC #$0100				; | multiply by number derived from factor
		STA $2253					;/ (scales from 258-512)
		SEC : SBC #$0100				;\ set size factor (scales 2-256)
		STA.w !BigRAM+!SizeFactorX,y			;/
		BRA $00						;
		LDA $2307					; get upper byte
		AND #$00FF


	.SetSize
		STA.w !BigRAM+!OutputWidth,y
		STA $2251

		SEP #$20					;\
		STZ $2250					; |
		REP #$20					; |
		LDA $07,x					; |
		AND #$00FF					; |
		CMP #$0080 : BCC +				; |
		AND #$007F					; \
		STA.w !BigRAM+!OutputX,y			;  | absolute coordinate clause
		BRA ++						; /
	+	STA $2253					; | set starting coords based on center
		NOP						; |
		BRA $00						; |
		LDA $2306					; |
		LSR #6						; |
		STA.w !BigRAM+!OutputX,y			; |
		LDA $07,x					; |
		AND #$00FF					; |
		SEC : SBC.w !BigRAM+!OutputX,y			; |
		STA.w !BigRAM+!OutputX,y			;/
	++	CLC : ADC.w !BigRAM+!OutputWidth,y		;\ update outer border location
		STA.w !BigRAM+!OutputWidth,y			;/
		DEY #2
		DEX : BMI .SizeDone				; do for X and Y
		JMP .SizeLoop

	.SizeDone
		SEP #$20

		LDA.b #!GFX_buffer>>16 : PHA : PLB		; switch bank
		REP #$30					; all regs 16 bit


		LDA $0E						;\
		AND #$0001					; | check continue flag
		PHP						; |
		LDA.w #!BigRAM : TCD				; > DP = !BigRAM
		PLP : BNE .Cont					;/


		LDA.l !GraphicsLoc+1				;\
		STA !GFX0+1					; |
		STA !GFX1+1					; | Store pointers (hi+bank)
		STA !GFX2+1					; |
		STA !GFX3+1					; |
		STA !GFX4+1					;/
		LDA.l !GraphicsLoc				;\ Base pointer (lo+hi)
		STA !GFX0					;/
		INC A						;\ Base + $01
		STA !GFX1					;/
		CLC : ADC #$000F				;\ Base + $10
		STA !GFX2					;/
		INC A						;\ Base + $11
		STA !GFX3					;/
		LDA #$8080 : STA $00				;\
		LDA #$4040 : STA $02				; |
		LDA #$2020 : STA $04				; |
		LDA #$1010 : STA $06				; | copy depth bits to RAM
		LDA #$0808 : STA $08				; | (16-bit format)
		LDA #$0404 : STA $0A				; |
		LDA #$0202 : STA $0C				; |
		LDA #$0101 : STA $0E				;/
		LDX.w #$07FE					;\
	-	STZ.w !GFX_buffer,x				; | clear buffer
		DEX #2 : BPL -					;/
		LDA !OutputX : STA !StartX			; update left border position
		LDA !OutputY : STA !StartY			; update upper border position
		STZ !InputX					;\ start pulling from 0;0
		STZ !InputY					;/
		STZ !SizeMemX					;\ clear size memory
		STZ !SizeMemY					;/
		BRA .Shared

	.Cont	LDX #$0048					;\
	-	LDA.w !ScaleBackup,x : STA $00,x		; | restore regs
		DEX #2 : BPL -					;/
	.Shared	SEP #$20					;\
		LDA #$00 : STA.l $2250				; |
		REP #$20					; |
		LDA !InputWidth : STA.l $2251			; |
		LDA !InputHeight : STA.l $2253			; |
		NOP						; |
		BRA $00						; |
		LDA.l $00300C					; | calculate pixel count based on stages of render
		AND #$0003					; |
		TAX						; |
		LDA.l $2306					; |
		CPX #$0000 : BEQ .1				; |
		CPX #$0001 : BEQ .2				; |
		CPX #$0002 : BEQ .4				; |
	.8	LSR A						; |
	.4	LSR A						; |
	.2	LSR A						;/
	.1	STA !PixelCount					; store pixel count



		LDA !InputWidth
		CMP #$0020 : BNE +
		LDA !InputHeight
		CMP #$0020 : BNE +
		LDA !ScaleX
		CMP #$007F : BNE +
		LDA !ScaleY
		CMP #$007F : BNE +
		JSR Quick32to64
		JMP .Return
		+



		LDA !ScaleY-1 : BPL .Loop			;\ start loop if not shrinking
		LDA #$0100 : STA !SizeMemY			; |
		JMP .NextRow					;/ otherwise always skip the first row


	.Loop	LDA !InputX					;\
		AND #$0007					; | X = X coord within tile (x2)
		ASL A						; |
		TAX						;/
		BNE ..SameY1
		LDA !InputX					;\
		AND #$00F8					; | for each extra tile horizontally, add 32 to Y
		ASL #2						; |
		STA !Y1						;/
		LDA !InputY					;\
		LSR #3						; |
		XBA						; | for each extra tile vertically, add 512 to Y
		ASL A						; |
		TSB !Y1						;/
		LDA !InputY					;\
		AND #$0007					; | for each row within tile, add 2 to Y
		ASL A						; |
		TSB !Y1						;/
		..SameY1

		LDY !Y1						; Y = !Y1


		LDA !OutputX
		AND #$0007
		CMP !PrevOutputX : BCC ..NewY2
		LDA !OutputY
		CMP !PrevOutputY : BEQ ..SameY2
	..NewY2	JSR RecalcOutputY
		..SameY2


		DEC !PixelCount : BPL $03 : JMP .Return		; check for end of render
								; after recalc to work with multi-stage render

		LDA !ScaleX-1 : BPL .NoShrink

	.Shrink
		LDA !SizeMemX
		CLC : ADC #$0100
		CMP !SizeFactorX : BCC +
		SBC !SizeFactorX
		STA !SizeMemX
		BRA .NoShrink

	+	STA !SizeMemX
		JMP .NextPixel

	.NoShrink
		LDA [!GFX0],y					;\ d0/d1 bits
		AND $00,x					;/
		STA !Bits+0					; 
		LDA [!GFX2],y					;\ d2/d3 bits
		AND $00,x					;/
		STA !Bits+2					; 

	.GenerateOutput
		LDA !OutputX					;\
		AND #$0007					; | X = x coord within tile (x2)
		STA !PrevOutputX
		ASL A						; |
		TAX						;/
		LDY !Y2						; Y = !Y2
		SEP #$20					; A 8 bit
		LDA !Bits+0 : BEQ +				;\
		LDA $00,x					; | d0 bit
		ORA.w !GFX_buffer+$00,y				; |
		STA.w !GFX_buffer+$00,y				;/
	+	LDA !Bits+1 : BEQ +				;\
		LDA $00,x					; | d1 bit
		ORA.w !GFX_buffer+$01,y				; |
		STA.w !GFX_buffer+$01,y				;/
	+	LDA !Bits+2 : BEQ +				;\
		LDA $00,x					; | d2 bit
		ORA.w !GFX_buffer+$10,y				; |
		STA.w !GFX_buffer+$10,y				;/
	+	LDA !Bits+3 : BEQ +				;\
		LDA $00,x					; | d3 bit
		ORA.w !GFX_buffer+$11,y				; |
		STA.w !GFX_buffer+$11,y				;/
		+

	.UpdateOutput
		REP #$20
		LDA !OutputX
		INC A
		CMP !OutputWidth : BNE ..XLoop
	-	LDA !OutputY
		INC A
		CMP !OutputHeight : BNE $03 : JMP .Return
	..YLoop	STA !OutputY
		DEC A : STA !PrevOutputY			; store backup here
		LDA !ScaleY-1 : BMI ++				; never copy a row when set to shrink

		LDA !SizeMemY
		CLC : ADC !SizeFactorY
		CMP #$0100 : BCC +
		SBC #$0100
		SEC : SBC !SizeFactorY
		STA !SizeMemY
		LDA !OutputWidth : STA !Bits+0


	--	LDA !OutputY
		AND #$0007 : BNE ..Copy
		CLC : ADC #$0008
		CMP !OutputHeight : BCS ++
		LDA.w !GFX_buffer+$000,y			;\
		STA.w !GFX_buffer+$0F2,y			; | copy bottom row to top of next tile
		LDA.w !GFX_buffer+$010,y			; |
		STA.w !GFX_buffer+$102,y			;/
		BRA ..SeeX

	..Copy	LDA.w !GFX_buffer+$00,y				;\
		STA.w !GFX_buffer+$02,y				; | copy row of 8x8 tile
		LDA.w !GFX_buffer+$10,y				; |
		STA.w !GFX_buffer+$12,y				;/

	..SeeX	LDA !Bits+0
		SEC : SBC #$0008
		BEQ -
		BMI -
		STA !Bits+0
		TYA
		SEC : SBC #$0020
		TAY
		BRA --

	+	STA !SizeMemY
	++	STA !SizeMemX
		LDA !StartX : STA !OutputX
		BRA .NextPixel

	..XLoop	STA !OutputX
		CMP !OutputWidth : BEQ .NextPixel		; never copy a pixel past max width

		AND #$0007 : BNE ..SameY2			;\
		JSR RecalcOutputY				; | recalc output Y if wrapping to new tile
		LDY !Y2						; |
		..SameY2					;/

		LDA !ScaleX-1 : BMI .NextPixel			; never copy a pixel when set to shrink
		LDA !SizeMemX					;\
		CLC : ADC !SizeFactorX				; |
		CMP #$0100 : BCC +				; | add size factor
		SBC #$0100					; | when at 256, reset memory and loop once
		SEC : SBC !SizeFactorX				; |
		STA !SizeMemX					;/
		JMP .GenerateOutput				; > copy pixel

	+	STA !SizeMemX


	.NextPixel
		REP #$20
		LDA !InputX
		INC A
		CMP !InputWidth : BNE .NextRow_XLoop

	.NextRow
		LDA !InputY
		INC A
		CMP !InputHeight : BEQ .Return
	..YLoop	STA !InputY

		LDA !StartX					;\
		CMP !OutputX : BEQ ..ok				; | account for fraction system inaccuracies
		STA !OutputX					; |
		..ok						;/


		LDA !ScaleY-1 : BPL ++				; never skip a row when set to grow
		LDA !SizeMemY
		CLC : ADC #$0100
		CMP !SizeFactorY : BCC +
		SBC !SizeFactorY
		STA !SizeMemY
		BRA ++						; draw row when enough have been skipped

	+	STA !SizeMemY
		BRA .NextRow					; skip row

	++	STZ !SizeMemX
		LDA #$0000
	..XLoop	STA !InputX
		JMP .Loop


	.Return	LDX #$0048					;\
	-	LDA $00,x : STA.w !ScaleBackup,x		; | backup all regs for multi-stage render
		DEX #2 : BPL -					;/
		PLB						;\
		LDX !StartX					; |
		LDY !StartY					; |
		LDA !OutputHeight				; |
		PLD						; | restore regs and save starting coordinates
		STX $00						; | also store output height
		STY $02						; |
		STA $04						; |
		PLP						;/
		RTL						; > return



	RecalcOutputY:
		LDA !OutputX					;\
		AND #$00F8					; | for each extra tile horizontally, add 32 to Y
		ASL #2						; |
		STA !Y2						;/
		LDA !OutputY					;\
		LSR #3						; | for each extra tile vertically, add 256 to Y
		XBA						; | (output has smaller resolution)
		TSB !Y2						;/
		LDA !OutputY					;\
		AND #$0007					; | for each row within tile, add 2 to Y
		ASL A						; |
		TSB !Y2						;/
		RTS



	Quick32to64:

	.RowLoop

		LDX !InputX
		LDA.l InputIndex,x : TAY		; get input index from table
		STY !InputY
		LDA.l OutputIndex,x : STA !OutputY	; get output index from table

		JSR .GetInput				;\
		LDY !OutputY				; | tile 0;Y
		JSR .GenerateOutput			;/
		LDA !InputY				;\
		CLC : ADC #$0020			; |
		TAY					; |
		JSR .GetInput				; | tile 1;Y
		LDA !OutputY				; |
		CLC : ADC #$0040			; |
		TAY					; |
		JSR .GenerateOutput			;/
		LDA !InputY				;\
		CLC : ADC #$0040			; |
		TAY					; |
		JSR .GetInput				; | tile 2;Y
		LDA !OutputY				; |
		CLC : ADC #$0080			; |
		TAY					; |
		JSR .GenerateOutput			;/
		LDA !InputY				;\
		CLC : ADC #$0060			; |
		TAY					; |
		JSR .GetInput				; | tile 3;Y
		LDA !OutputY				; |
		CLC : ADC #$00C0			; |
		TAY					; |
		JSR .GenerateOutput			;/

		LDA !InputX
		INC #2
		CMP #$0040 : BEQ .Done
		STA !InputX
		LDA !PixelCount
		SEC : SBC #$0020
		STA !PixelCount : BNE .RowLoop


	.Done
		RTS




	.GetInput
		LDA [!GFX0],y
		AND #$00FF
		ASL A
		TAX
		LDA.l QuickTable,x : STA $00
		LDA [!GFX1],y
		AND #$00FF
		ASL A
		TAX
		LDA.l QuickTable,x : STA $02
		LDA [!GFX2],y
		AND #$00FF
		ASL A
		TAX
		LDA.l QuickTable,x : STA $04
		LDA [!GFX3],y
		AND #$00FF
		ASL A
		TAX
		LDA.l QuickTable,x : STA $06
		RTS


	.GenerateOutput
		SEP #$20
		LDA $00 : STA.w !GFX_buffer+$20,y : STA.w !GFX_buffer+$22,y
		LDA $01 : STA.w !GFX_buffer+$00,y : STA.w !GFX_buffer+$02,y
		LDA $02 : STA.w !GFX_buffer+$21,y : STA.w !GFX_buffer+$23,y
		LDA $03 : STA.w !GFX_buffer+$01,y : STA.w !GFX_buffer+$03,y
		LDA $04 : STA.w !GFX_buffer+$30,y : STA.w !GFX_buffer+$32,y
		LDA $05 : STA.w !GFX_buffer+$10,y : STA.w !GFX_buffer+$12,y
		LDA $06 : STA.w !GFX_buffer+$31,y : STA.w !GFX_buffer+$33,y
		LDA $07 : STA.w !GFX_buffer+$11,y : STA.w !GFX_buffer+$13,y
		REP #$20
		RTS



	InputIndex:
		dw $0000,$0002,$0004,$0006		;\ tile 0;0
		dw $0008,$000A,$000C,$000E		;/
		dw $0200,$0202,$0204,$0206		;\ tile 0;1
		dw $0208,$020A,$020C,$020E		;/
		dw $0400,$0402,$0404,$0406		;\ tile 0;2
		dw $0408,$040A,$040C,$040E		;/
		dw $0600,$0602,$0604,$0606		;\ tile 0;3
		dw $0608,$060A,$060C,$060E		;/


	OutputIndex:
		dw $0000,$0004,$0008,$000C
		dw $0100,$0104,$0108,$010C
		dw $0200,$0204,$0208,$020C
		dw $0300,$0304,$0308,$030C
		dw $0400,$0404,$0408,$040C
		dw $0500,$0504,$0508,$050C
		dw $0600,$0604,$0608,$060C
		dw $0700,$0704,$0708,$070C



	; each bit should be copied 1 step to the right
	; ...shifting all bits starting at that spot 1 step right to make room
	; for example, 0x80 becomes 0xC0
	; 0xC0 is more complex:
	;	1100 0000
	; we copy the first (highest) bit like this:
	;	1110 0000
	; then the second (now in the 0x20 spot) like this:
	;	1111 0000


	QuickTable:
		dw $0000,$0003,$000C,$000F		; 00-03
		dw $0030,$0033,$003C,$003F		; 04-07
		dw $00C0,$00C3,$00CC,$00CF		; 08-0B
		dw $00F0,$00F3,$00FC,$00FF		; 0C-0F
		dw $0300,$0303,$030C,$030F		; 10-13
		dw $0330,$0333,$033C,$033F		; 14-17
		dw $03C0,$03C3,$03CC,$03CF		; 18-1B
		dw $03F0,$03F3,$03FC,$03FF		; 1C-1F
		dw $0C00,$0C03,$0C0C,$0C0F		; 20-23
		dw $0C30,$0C33,$0C3C,$0C3F		; 24-27
		dw $0CC0,$0CC3,$0CCC,$0CCF		; 28-2B
		dw $0CF0,$0CF3,$0CFC,$0CFF		; 2C-2F
		dw $0F00,$0F03,$0F0C,$0F0F		; 30-33
		dw $0F30,$0F33,$0F3C,$0F3F		; 34-37
		dw $0FC0,$0FC3,$0FCC,$0FCF		; 38-3B
		dw $0FF0,$0FF3,$0FFC,$0FFF		; 3C-3F
		dw $3000,$3003,$300C,$300F		; 40-43
		dw $3030,$3033,$303C,$303F		; 44-47
		dw $30C0,$30C3,$30CC,$30CF		; 48-4B
		dw $30F0,$30F3,$30FC,$30FF		; 4C-4F
		dw $3300,$3303,$330C,$330F		; 50-53
		dw $3330,$3333,$333C,$333F		; 54-57
		dw $33C0,$33C3,$33CC,$33CF		; 58-5B
		dw $33F0,$33F3,$33FC,$33FF		; 5C-5F
		dw $3C00,$3C03,$3C0C,$3C0F		; 60-63
		dw $3C30,$3C33,$3C3C,$3C3F		; 64-67
		dw $3CC0,$3CC3,$3CCC,$3CCF		; 68-6B
		dw $3CF0,$3CF3,$3CFC,$3CFF		; 6C-6F
		dw $3F00,$3F03,$3F0C,$3F0F		; 70-73
		dw $3F30,$3F33,$3F3C,$3F3F		; 74-77
		dw $3FC0,$3FC3,$3FCC,$3FCF		; 78-7B
		dw $3FF0,$3FF3,$3FFC,$3FFF		; 7C-7F
		dw $C000,$C003,$C00C,$C00F		; 80-83
		dw $C030,$C033,$C03C,$C03F		; 84-87
		dw $C0C0,$C0C3,$C0CC,$C0CF		; 88-8B
		dw $C0F0,$C0F3,$C0FC,$C0FF		; 8C-8F
		dw $C300,$C303,$C30C,$C30F		; 90-93
		dw $C330,$C333,$C33C,$C33F		; 94-97
		dw $C3C0,$C3C3,$C3CC,$C3CF		; 98-9B
		dw $C3F0,$C3F3,$C3FC,$C3FF		; 9C-9F
		dw $CC00,$CC03,$CC0C,$CC0F		; A0-A3
		dw $CC30,$CC33,$CC3C,$CC3F		; A4-A7
		dw $CCC0,$CCC3,$CCCC,$CCCF		; A8-AB
		dw $CCF0,$CCF3,$CCFC,$CCFF		; AC-AF
		dw $CF00,$CF03,$CF0C,$CF0F		; B0-B3
		dw $CF30,$CF33,$CF3C,$CF3F		; B4-B7
		dw $CFC0,$CFC3,$CFCC,$CFCF		; B8-BB
		dw $CFF0,$CFF3,$CFFC,$CFFF		; BC-BF
		dw $F000,$F003,$F00C,$F00F		; C0-C3
		dw $F030,$F033,$F03C,$F03F		; C4-C7
		dw $F0C0,$F0C3,$F0CC,$F0CF		; C8-CB
		dw $F0F0,$F0F3,$F0FC,$F0FF		; CC-CF
		dw $F300,$F303,$F30C,$F30F		; D0-D3
		dw $F330,$F333,$F33C,$F33F		; D4-D7
		dw $F3C0,$F3C3,$F3CC,$F3CF		; D8-DB
		dw $F3F0,$F3F3,$F3FC,$F3FF		; DC-DF
		dw $FC00,$FC03,$FC0C,$FC0F		; E0-E3
		dw $FC30,$FC33,$FC3C,$FC3F		; E4-E7
		dw $FCC0,$FCC3,$FCCC,$FCCF		; E8-EB
		dw $FCF0,$FCF3,$FCFC,$FCFF		; EC-EF
		dw $FF00,$FF03,$FF0C,$FF0F		; F0-F3
		dw $FF30,$FF33,$FF3C,$FF3F		; F4-F7
		dw $FFC0,$FFC3,$FFCC,$FFCF		; F8-FB
		dw $FFF0,$FFF3,$FFFC,$FFFF		; FC-FF





