@includefrom sa1.asm

;============;
;INTRODUCTION;
;============;

; -- VRAM Table Format --
;
; For each upload:
;	- Data Size		2 bytes
;	- Data Source		3 bytes
;	- Dest VRAM		2 bytes
;
; VRAM upload table starts at VRAMtable.
; Upload stops when an upload block of 0x0000 bytes is encountered.
; That is, the table should end with a 0x0000 word, kind of like HDMA.
; Slot allocation is handled automatically.

; -- CGRAM Table Format --
;
; For each upload:
;	- Data size		2 bytes
;	- Data source		3 bytes
;	- Dest CGRAM		1 byte
;
; CGRAM upload table starts at VRAMtable+$100.
; Just like the VRAM table, uploads stop upon encountering a block of size of zero.

; -- GFX Scaling Function --
;
; GFX scaling adds 16-bit scaling registers for up to 32 blocks of VRAM.
; The scaling registers start at !VRAMtable+$200.
; The format works like this:
;	- Block base		2 bytes
;	- Block width		1 byte
;	- Block height		1 byte
;	- X scale factor	2 bytes
;	- Y scale factor	2 bytes
;
; Block base: b----ppp tttttttt
;	b is bit format. Handles 2bb GFX when set (default is 4bpp).
;	p is VRAM page.
;	t is the tile number of the top left 8x8 tile of the block.
; Block width and height is the size of the block in pixels.
; The scaling factors work like the mode 7 scaling registers: they are divided by 256 before they are applied.
; The default size is 0x01.00, which multiplies by 1 and leaves the GFX untouched.
; Remember that the lo byte is still in hex. 0x00.80 is half of 0x01.00.
; Scaling the GFX up too much will simply cut it off.
; The unused space of the 16x16 tiles occupied by the updated GFX is cleared out to avoid garbage.

; -- GFX Rotation Function --
;
; GFX rotation adds two 16 bit registers for rotating graphics.
; Rotation registers start at !VRAMtable+$300.
; The registers are:
;	- Rotation properties	2 bytes
;	- Rotation center	2 bytes
;
; Rotation properties: -------A aaaaaaaa
;	A is hi bit of angle.
;	a is lo byte of angle. All rotations are done clockwise.
; Rotation center is the point the GFX rotate around. Added to Block Base.
; Rotation blocks are defined by the same registers as the scaling blocks.


;======;
;MACROS;
;======;

macro loadOAM0index(tiles)
	LDA !OAM0index
	TAY
	CLC : ADC #$04*<tiles>
	STA !OAM0index
	BCC ?NoOverflow
	INC !OAM0index+1
	?NoOverflow:
endmacro

macro loadOAM1index(tiles)
	LDA !OAM1index
	TAY
	CLC : ADC #$04*<tiles>
	STA !OAM1index
	BCC ?NoOverflow
	INC !OAM1index+1
	?NoOverflow:
endmacro

macro loadOAM2index(tiles)
	LDA !OAM2index
	TAY
	CLC : ADC #$04*<tiles>
	STA !OAM2index
	BCC ?NoOverflow
	INC !OAM2index+1
	?NoOverflow:
endmacro

macro loadOAM3index(tiles)
	LDA !OAM3index
	TAY
	CLC : ADC #$04*<tiles>
	STA !OAM3index
	BCC ?NoOverflow
	INC !OAM3index+1
	?NoOverflow:
endmacro


macro setspriteindex(index)
	LDA $14C8+<index>
	BEQ ?Shared
	LDA $7FAB0F+<index>
	AND #$08
	BNE ?Custom
	LDX.b $9D+<index>
	LDA.l TileCount_Vanilla,x
	ASL #2
	BRA ?Shared
	?Custom:
	LDA $7FAB9D+<index>
	TAX
	LDA.l TileCount_Custom,x
	ASL #2
	?Shared:
	CLC : ADC $15E9+<index>
	STA $15EA+<index>
endmacro

macro minorOAMremap1(address)
	org <address>
	autoclean JSL OAM_handler_minor1
	NOP #2
endmacro


macro minorOAMremap2(address)
	org <address>
	autoclean JSL OAM_handler_minor2
	NOP #2
endmacro


;=============;
;OAM REMAPPING;
;=============;

; --Remap player tiles--

	org $00E3D2					; Property
		STA $0303-$18,y
		STA $0307-$18,y
		STA $030F-$18,y
		STA $0313-$18,y
		STA $02FB-$18,y
		STA $02FF-$18,y
	org $00E3EC
		STA $030B-$18,y
	org $00E469					; Tile number
		dw $0302-$18
	org $00E483					; Ypos
		dw $0301-$18
	org $00E49B					; Xpos
		dw $0300-$18
	org $00E4AC					; Hi table
		dw $0460-$6

; --Remap Yoshi's tongue--

	org $01F469
		db $0C					; Put at the very start of OAM

; --Remap sprites--

	org $0180A4
	RETURN:
	;	autoclean JML OAM_handler		;\ Source: STZ $18DF : LDX #$0B
	;	NOP					;/
	STZ $78DF
	LDX #$0B

		.sprite
		STX $15E9
	;	JSR $80E5				; > Source: JSR $80D2

	JSR $80D2

		JSR $8127
		DEX
		BPL RETURN_sprite

	org $0180D2
		autoclean JML OAM_handler		;\ Source: PHX : TXA : LDX $1692
		NOP					;/


; --Remap minor extended sprites--

	%minorOAMremap1($028CFF)			;\
	%minorOAMremap1($028D8B)			; |
	%minorOAMremap1($028E20)			; |
	%minorOAMremap2($028E94)			; | Remap minor extended sprite indexes
	%minorOAMremap1($028EE1)			; |
	%minorOAMremap1($028F4D)			; |
	%minorOAMremap1($028FDD)			;/

; --Remap extended sprites--

	org $029D10
		autoclean JML OAM_handler_extG		;\ Source: LDY $A153,x : STY $0F
		NOP					;/
		.extG
	org $02A362
		autoclean JML OAM_handler_ext01		;\ Source: LDY $A153,x : CPY #$08
		NOP					;/
		.ext01
	org $02A180
		autoclean JML OAM_handler_ext02		;\ Source: LDY $A153,x : LDA $14
		NOP					;/
		.ext02
	org $02A235
		autoclean JML OAM_handler_ext03		;\ Source: LDY $A153,x : LDA $1765,x
		NOP #2					;/
		.ext03
	org $02A31A
		autoclean JML OAM_handler_ext04		;\ Source: LDY $A153,x : LDA $1765,x
		NOP #2					;/
		.ext04
	org $02A03B
		autoclean JML OAM_handler_ext05		;\ Source : LDY $9FA3,x : JSR $A1A7
		NOP #2					;/
	org $02A1A4
		autoclean JML OAM_handler_ext05		;\ Source : LDY $A153,x : LDA $1747,x
		NOP #2					;/
		.ext05
	org $029E9D
		autoclean JML OAM_handler_ext07		;\ Source: LDY $A153,x : LDA $171F,x
		NOP #2					;/
		.ext07
	org $029E5F
		autoclean JML OAM_handler_ext08		; Source: LDY $A153,x : PLA
		.ext08
	org $029B51
		autoclean JML OAM_handler_ext0B		;\ Source: LDY $A153,x : LDA $171F,x
		NOP #2					;/
		.ext0B
	org $02A287
		autoclean JML OAM_handler_ext0D		;\ Source: LDY $A153,x : LDA $00
		NOP					;/
		.ext0D
	org $029C41
		autoclean JML OAM_handler_ext0F		;\ Source: LDY $A153,x : LDA $176F,x
		NOP #2					;/
		.ext0F
	org $029C8B
		autoclean JML OAM_handler_ext10		;\ Source: LDY $A153,x : LDA #$34
		NOP					;/
		.ext10
	org $029F76
		autoclean JML OAM_handler_ext11		;\ Source: LDY $A153,x : LDA #$04
		NOP					;/
		.ext11
	org $029F46
		autoclean JML OAM_handler_ext12		;\ Source: LDY $A153,x : LDA $0200,y
		NOP #2					;/
		.ext12

; --Remap smoke sprites--

	org $02999F
		autoclean JML OAM_handler_smokeG	;\ Source: LDY $96BC,x : LDA $17C8,x
		NOP #2					;/
		.smokeG
	org $029701
		autoclean JML OAM_handler_smoke01	;\ Source: LDY $96BC,x : LDA $17C8,x
		NOP #2					;/
		.smoke01
	org $0297B2
		autoclean JML OAM_handler_smoke02	;\ Source: LDY #$F0 : LDA $17C8,x
		NOP					;/
		.smoke02
	org $029936
		autoclean JML OAM_handler_smoke03l	;\ Source: LDY $96BC,x : LDA #$F0
		NOP					;/
		.smoke03l
	org $029967
		autoclean JML OAM_handler_smoke03h	;\ Source: LDY $96BC,x : BRA $03 [$02996F]
		NOP					;/
	org $02996F
		.smoke03h

; --Remap bounce sprites--

	org $02922D
		autoclean JML OAM_handler_bounce	;\ Source: LDY $91ED,x : LDA $16A1,x
		NOP #2					;/
		.bounce

; --Remap score sprites--

	org $02AE9B
		autoclean JML OAM_handler_score		;\ Source: LDY $AD9E,x : BIT $0D9B
		NOP #2					;/
		.score



;=======;
;HIJACKS;
;=======;

; Things that SMW wants to do during v-blank (NMI) are as follows:
; - Read $4210
; - Update music ports ($2140-$2143)
; - Set f-blank
; - Disable HDMA (?)
; - Update windowing regs ($2123-$2125, $2130)
; - Update CGADSUB ($2131)
; - Set BG mode ($2105)
; - Run $00A488 (dynamic palette routine)
; - Draw status bar
; - Run $0087AD (level loader)
; - Update GFX depending on $143A (because of "MARIO START !"
; - Run $00A390 (SMW's dynamic sprite routine)
; - Run $00A436 (uploads "MARIO START !" if approperiate)
; - Run $00A300 (Mario GFX DMA)
; - Run $0085D2 (stripe image loader)
; - Run $008449 (OAM upload)
; - Run $008650 (controller update)
; - Update layer positions ($210D-$2110)
; - Enable IRQ ($4209-$420A, $4211)
; - Set $4200
; - Set brightness ($2100)
; - Enable HDMA
;
; I can probably kill SMW's dynamic sprites, as well as the dynamic blocks...
;


	org $00816A					; Start of NMI routine
		autoclean JML UploadGFX			; SEI : PHP : REP #$30
	org $0081AF
		BRA $01 : NOP				; STZ $420C
	org $008217
		JSR $A395				; Skip past LM's bullshit
	org $008289
		BRA $04 : NOP #4			; LDY $0D9F : STY $420C
	org $0082B6
		BRA $04 : NOP #4			; LDA $0D9F : STA $420C
	org $0082BC
		autoclean JML ReturnNMI			; REP #$30 : PLB : PLY
	org $0083B2
		autoclean JML ReturnNMI			; REP #$30 : PLB : PLY
	org $00A390
		-
	org $00A395
		LDY !AnimToggle
		BEQ -
		RTS
	org $00A601
		JSR $A395				; Skip past LM's bullshit


;===========;
;CUSTOM CODE;
;===========;
freecode
ReturnNMI:	REP #$30
		PLD					;\
		PLB					; |
		PLY					; | Restore everything
		PLX					; | (including DP!)
		PLA					; |
		PLP					;/
		RTI					; > Return from interrupt


;===================;
;VRAM UPLOAD ROUTINE;
;===================;

	!LoadSize	= !VRAMtable+$FC
	!LoadIndex	= !VRAMtable+$FE

	!MaxUpload	= $0800				; Maximum amount of data to be uploaded in one frame

UploadGFX:	SEI
		PHP
		REP #$30
		PHA
		PHX
		PHY
		PHB
		PHD : LDA #$420B : TCD			; Direct page = 0x420B
		SEP #$30				; A and index 8 bit
		LDA #$80				;\ Bank 80
		PHA : PLB				;/
		LDA $4210
		LDA #$80
		STA $2100
		LDA #$01 : STA $420D			; Enable FastROM
		LDA $6D9F : STA $420C			; Enable HDMA

	; Because DP = 0x420B, the following is true:
	; $00 = $420B
	; $F5 = $4300
	; $F7 = $4302
	; $F9 = $4304
	; $FA = $4305

		LDA $6D9B
		BNE +
		LDA #$80				;\
		STA $2115				; |
		REP #$20				; |
		LDA #$5000				; |
		STA $2116				; |
		LDA #$1801				; |
		STA $F5					; |
		LDA #$A5C0				; | Upload top row of dynamic BG3
		STA $F7					; |
		LDX #$7F				; |
		STX $F9					; |
		LDA #$0040				; |
		STA $FA					; |
		LDY #$01				; |
		STY $00					;/
		LDA #$2202				;\
		STA $F5					; |
		LDA #$A5AA				; |
		STA $F7					; |
		LDA #$0016				; | Upload color
		STA $FA					; |
		STY $2121				; |
		STY $00					;/
		SEP #$20				; > A 8 bit
		+

		STZ !OAMindex				;\ Clear OAM index at every NMI
		STZ !OAMindexhi				;/
		LDA !GameMode				;\
		CMP #$14				; |
		BEQ .Start				; |
		CMP #$13				; | Upload GFX during level load, level, and title screen
		BEQ .Start				; |
		CMP #$07				; |
		BEQ .Start				;/
		JMP ReturnToNMI

.Start		REP #$20				; > A 16 bit
		LDY #$80				; Word writes
		STY $2115
		LDY #!VRAMbank : PHY : PLB		; Set VRAM bank
		LDA.w #!MaxUpload
		STA.w !LoadSize
		LDX.w !LoadIndex

.Loop		LDA.l .Index,x : TAY
		LDA.w !VRAMtable+0,y			;\
		BNE .Go					; |
		INX					; |
		CPX #$24				; | End upload after checking entire table
		BNE .Loop				; |
		STZ.w !LoadIndex			; |
		JMP UPLOAD_CGRAM			;/
.Go		STA $FA					; > 4305 = data size
		SEC : SBC.w !LoadSize			;\ Limit data per frame
		BPL .FinalBatch				;/
		EOR #$FFFF : INC A			;\ Update data cap remaining
		STA !LoadSize				;/
		LDA.w #$0000				;\ Clear slot
		STA.w !VRAMtable+0,y			;/
		LDA.w !VRAMtable+2,y			;\
		STA $F7					; | Source data
		LDA.w !VRAMtable+3,y			; |
		STA $F8					;/
		LDA.w !VRAMtable+5,y			;\ Dest VRAM
		STA.l $002116				;/
		XBA					;\
		AND #$0080				; |
		BEQ +					; |
		LDA $002139				; | Transfer direction (+dummy read)
		LDA #$3981				; |
	+	ORA #$1801				; |
		STA $F5					;/
		LDY #$01 : STY $00			; > Transfer data
		INX					;\
		CPX #$24				; |
		BNE .Loop				; | Loop, end at upload index = 0x24
		STZ.w !LoadIndex			; |
		BRA UPLOAD_CGRAM			;/

.FinalBatch	BNE +					;\ Increment index if necessary
		INX					;/
	+	STA.w !VRAMtable+0,y			; Next upload = remaining data
		LDA.w !LoadSize				;\ Current upload = max data
		STA $FA					;/
		LDA.w !VRAMtable+2,y			;\
		STA $F7					; | Current upload source
		LDA.w !VRAMtable+3,y			; |
		STA $F8					;/
		LDA.w !LoadSize				;\
		CLC : ADC.w !VRAMtable+2,y		; | Next upload source
		STA.w !VRAMtable+2,y			;/
		LDA.w !VRAMtable+5,y			;\ Current dest VRAM
		STA.l $002116				;/
		LDA.w !LoadSize				;\
		LSR A					; | Next dest VRAM
		CLC : ADC.w !VRAMtable+5,y		; |
		STA.w !VRAMtable+5,y			;/
		XBA					;\
		AND.w #$0080				; | Transfer direction
		ORA #$1801				; |
		STA $F5					;/
		LDY #$01 : STY $00			; > Upload
		STX !LoadIndex				; > Queue remaining data
.End		BRA UPLOAD_CGRAM

.Index		db $00,$07,$0E,$15,$1C,$23,$2A,$31
		db $38,$3F,$46,$4D,$54,$5B,$62,$69
		db $70,$77,$7E,$85,$8C,$93,$9A,$A1
		db $A8,$AF,$B6,$BD,$C4,$CB,$D2,$D9
		db $E0,$E7,$EE,$F5


UPLOAD_CGRAM:	LDA #$2202				;\ Parameters and destination of DMA
		STA $F5					;/
		LDX #$00

.Loop		LDA.l .Index,x : TAY
		LDA.w !CGRAMtable+0,y			;\ End upload at an 0x0000 word
		BEQ ReturnToNMI				;/
		STA $FA					;\
		LDA.w #$0000				; | Set data size and clear slot
		STA.w !CGRAMtable+0,y			;/
		LDA.w !CGRAMtable+2,y			;\
		STA $F7					; | Source address
		LDA.w !CGRAMtable+3,y			; |
		STA $F8					;/
		SEP #$20				;\
		LDA.w !CGRAMtable+5,y			; | Set dest CGRAM
		STA.l $002121				; |
		REP #$20				;/
		LDY #$01 : STY $00			; > Upload data
		INX
		CPX #$2A
		BNE .Loop
		BRA ReturnToNMI				; > Loop

.Index		db $00,$06,$0C,$12,$18,$1E,$24,$2A
		db $30,$36,$3C,$42,$48,$4E,$54,$5A
		db $60,$66,$6C,$72,$78,$7E,$84,$8A
		db $90,$96,$9C,$A2,$A8,$AE,$B4,$BA
		db $C0,$C6,$CC,$D2,$D8,$DE,$E4,$EA
		db $F0,$F6

ReturnToNMI:	REP #$20				; > A 16-bit
		LDA #$0000 : TCD			; > DP = $0000
		SEP #$30				; > All registers 8 bit
		LDA #$80 : PHA : PLB			; > Set FastROM bank
		JML $008179				; > Return to NMI routine with FastROM enabled


ToggleAnimation:
	;	LDA !AnimToggle
	;	BNE .Disabled

		.Enabled
		REP #$20
		LDY #$80
		JML $00A394

		.Disabled
		JML $00A435


;===========;
;OAM HANDLER;
;===========;
OAM_handler:	LDA $1692				;\
		CMP #$10				; | Only use the dynamic alotter if sprite header is set to 0x10
		BNE .SMW_alotter			;/
.Dynamic	PHX : TXY				; > Use Y as sprite index
		CPY #$0B				;\ Check for highest sprite
		BNE .NotHighest				;/
		LDA !P2TilesUsed			;\ Highest sprite always gets index after P2
		BRA .Write				;/
.NotHighest	LDA $7FAB11,x				;\
		AND #$08				; |
		BEQ .Vanilla				; |
		LDA $7FAB9F,x				; | Handle custom sprite
		TAX					; |
		LDA.l TileCount_Custom,x		; |
		ASL #2					; |
		CLC : ADC $15EB,y			; |
		STA $15EA,y				;/
		PLX					; > Restore sprite index
		JML $0180E5				; > Return
.Vanilla	LDX $009F,y				;\
		LDA.l TileCount_Vanilla,x		; |
		ASL #2					; | Handle vanilla sprite
		CLC : ADC $15EB,y			; |
.Write		STA $15EA,y				;/
.Return		PLX					; > Restore sprite index
		JML $0180E5				; > Return

.SMW_alotter	PHX					;\
		TXA					; | Overwritten code
		LDX $1692				;/
		JML $0180D7				; > Return


	;	LDA #$00				;\ Highest sprite always gets index 0x00
	;	STA $15EA				;/
	;	%setspriteindex($1)			;\
	;	%setspriteindex($2)			; |
	;	%setspriteindex($3)			; |
	;	%setspriteindex($4)			; |
	;	%setspriteindex($5)			; | Distribute OAM
	;	%setspriteindex($6)			; |
	;	%setspriteindex($7)			; |
	;	%setspriteindex($8)			; |
	;	%setspriteindex($9)			; |
	;	%setspriteindex($A)			; |
	;	%setspriteindex($B)			;/
	;	STZ $18DF				; > Overwritten code
	;	LDX #$0B				;\ Execute main sprite loop
	;	JML RETURN_sprite			;/


; --Minor extended sprite routines--

.minor1		%loadOAMindex()
		LDA $1808,x
		RTL
.minor2		%loadOAMindex()
		LDA $17FC,x
		RTL

; --Extended sprite routines--

.extG		%loadOAMindex()
		STY $0F
		JML RETURN_extG
.ext01		%loadOAMindex()
		CPY #$08
		JML RETURN_ext01
.ext02		%loadOAMindex()
		LDA $14
		JML RETURN_ext02
.ext03		%loadOAMindex()
		LDA $1765,x
		JML RETURN_ext03
.ext04		%loadOAMindex()
		LDA $1765,x
		JML RETURN_ext04
.ext05		CPX #$08				;\
		BCS +					; |
		LDY !OAMindex				; | Handle non-fireballs
		LDA $1747,x				; |
		JML RETURN_ext05			;/
	+	%loadOAMindex()				;\
		LDA $1747,x				; | Handle fireballs
		JML RETURN_ext05			;/
.ext07		%loadOAMindex()
		LDA $171F,x
		JML RETURN_ext07
.ext08		%loadOAMindex()
		PLA
		JML RETURN_ext08
.ext0B		%loadOAMindex()
		LDA $171F,x
		JML RETURN_ext0B
.ext0D		%loadOAMindex()
		LDA $00
		JML RETURN_ext0D
.ext0F		%loadOAMindex()
		LDA $176F,x
		JML RETURN_ext0F
.ext10		%loadOAMindex()
		LDA #$34
		JML RETURN_ext10
.ext11		%loadOAMindex()
		LDA #$04
		JML RETURN_ext11
.ext12		%loadOAMindex()
		LDA $0200,y
		JML RETURN_ext12

; --Smoke sprite routines--

.smokeG		%loadOAMindex()
		LDA $17C8,x
		JML RETURN_smokeG
.smoke01	%loadOAMindex()
		LDA $17C8,x
		JML RETURN_smoke01
.smoke02	%loadOAMindex4()
		LDA $17C8,x
		JML RETURN_smoke02
.smoke03l	%loadOAMindex()
		LDA #$F0
		JML RETURN_smoke03l
.smoke03h	%loadOAMindex()
		JML RETURN_smoke03h

; --Bounce sprite routine--

.bounce		%loadOAMindex()
		LDA $16A1,x
		JML RETURN_bounce

; --Score sprite routine--

.score		PHA
		%loadOAMindex2()
		PLA
		BIT $0D9B
		JML RETURN_score


TileCount:

		;   X0  X1  X2  X3  X4  X5  X6  X7  X8  X9  XA  XB  XC  XD  XE  XF

.Vanilla	db $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$01	; 0X
		db $03,$01,$00,$01,$01,$01,$01,$01,$01,$00,$02,$01,$01,$01,$0F,$03	; 1X
		db $03,$02,$02,$02,$02,$02,$05,$01,$14,$12,$01,$0A,$01,$00,$01,$04	; 2X
		db $03,$02,$02,$01,$01,$04,$00,$01,$01,$01,$04,$04,$04,$01,$01,$02	; 3X
		db $02,$02,$02,$03,$03,$02,$05,$01,$01,$02,$01,$02,$01,$01,$01,$03	; 4X
		db $03,$01,$03,$01,$10,$05,$05,$05,$05,$05,$05,$03,$05,$05,$09,$09	; 5X
		db $02,$04,$03,$05,$05,$05,$05,$04,$01,$00,$02,$05,$05,$00,$04,$04	; 6X
		db $05,$04,$04,$04,$01,$01,$01,$01,$01,$01,$00,$03,$08,$01,$03,$03	; 7X
		db $01,$01,$12,$03,$03,$00,$07,$03,$00,$00,$04,$02,$00,$08,$00,$04	; 8X
		db $10,$05,$05,$05,$05,$05,$05,$05,$05,$04,$03,$04,$04,$06,$06,$10	; 9X
		db $00,$0C,$04,$06,$04,$01,$04,$01,$04,$06,$04,$02,$05,$05,$08,$01	; AX
		db $06,$01,$01,$02,$04,$01,$01,$03,$03,$01,$03,$04,$03,$02,$01,$04	; BX
		db $03,$05,$01,$06,$10,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00	; CX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$03,$03,$00,$03	; DX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; EX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; FX

; TODO: Figure out how bobomb (0x0D) explosions are handled

		;   X0  X1  X2  X3  X4  X5  X6  X7  X8  X9  XA  XB  XC  XD  XE  XF

.Custom		db $02,$00,$00,$00,$00,$01,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00	; 0X
		db $10,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04	; 2X
		db $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 3X
		db $05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 4X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 5X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 6X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 7X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 8X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 9X
		db $00,$00,$00,$00,$00,$00,$00,$27,$01,$06,$10,$04,$04,$05,$08,$08	; AX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00	; BX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; CX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; DX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; EX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; FX


;=================;
;SPRITE BG HANDLER;
;=================;
;
; MANUAL:
;
;	- BG settings: [FOOOOWWW][RRRRrrrr][vhssssss][YXPPVHSS]
;		- F: frame rate. 0 is 60 FPS, 1 is 30 FPS.
;		- O: OAM order. Decides when the sprite BG is uploaded. See below for details.
;		- W: wrapping settings. See below for details.
;		- R: vertical BG resolution. Resolution formula is: ([RRRR]+1)*32
;		- r: horizontal BG resolution. Resolution formula is ([rrrr]+1)*32
;		- v: inverts vertical scrolling value obtained from scrolling algorithm. See below for details.
;		- h: inverts horizontal scrolling value obtained from scrolling algorithm. See below for details.
;		- s: scrolling algorithm. See below for details.
;		- Y: inverts Ydisp of tilemap and bit 7 of YXPPCCCT bytes.
;		- X: inverts Xdisp of tilemap and bit 6 of YXPPCCCT bytes.
;		- P: priority settings. Written to YXPPCCCT bytes.
;		- V: vertical wrap. Makes the BG wrap from top to bottom and vice versa. See below for details.
;		- H: horizontal wrap. Makes the BG wrap from left to right and vice versa. See below for details.
;		- S: layer scroll settings. Makes the BG scroll with layers 1-4.
;
;	- BG format: [XXXXXXXX][YYYYYYYY][TTTTTTTT][YXyxCCCT]
;		- Byte 0: xdisp. Determines the horizontal position of each individual tile.
;		- Byte 1: ydisp. Determines the vertical position of each individual tile.
;		- Byte 2: tile number.
;		- Byte 3: properties.
;			- Y: vertically flips the tile.
;			- X: horizontally flips the tile.
;			- y: hi bit of vertical position of each individual tile.
;			- x: hi bit of horizontal position of each individual tile.
;			- C: palette index minus 8. 0 uses palette 8, 1 uses palette 9 and so on.
;			- T: hi bit of tile number.
;
;	Several BGs can be active at once.
;	Limiting factors are tile count and processing cost.
;	Sprite-to-sprite priority is decided by OAM order and as such BG data has to be laid out hi priority to lo priority.
;	
;
; FRAMERATE:
;
;	Sprite BGs have a very large processing cost. Using several at once is too much for the processor and so
;	a 30 FPS mode has been included. 30 FPS mode only updates the screen every two frames and essentially gives you
;	twice the processing power for VR2 routines at the cost of animation smoothness.
;	This mode can be useful for levels that have a lot going on but is only recommended as a last resort.
;
; SCROLLING:
;
;	The patch comes bundled with a few scrolling algorithms, but leaves room for customized ones as well.
;	Sprite BG settings can be written with levelASM and macros for this are included for non-programmers.
;	Offscreen tiles take no OAM space. What is considered offscreen is determined by the wrapping setting bits.
;	The values are:
;		000:
;		001:
;		010:
;		011:
;		100:
;		101:
;		110:
;		111:
;
; TILE PRIORITY:
;
;	The first byte of BG settings affects sprite-to-sprite priority by uploading the sprite BG at different times.
;	In vanilla SMW, OAM is written in the order:
;		1 Player
;		2 Sprites
;		3 Minor extended sprites
;		4 Bounce sprites
;		5 Smoke sprites
;		6 Score sprites
;		7 Extended sprites
;		8 Coin sprites
;
;	This order can be changed by VR2 and determines sprite priority.
;	The value of the O bits is how many of these are handled before the sprite BG is uploaded.
;	Therefore, 0 is the highest priority and 15 is the lowest priority.
;	Values 9-15 are originally identical but can be made to matter with custom sprite types.

SPRITE_BG:
;
; Scratch RAM:
; 00+01:	pointer to BG data
; 08:		horizontal scrolling from algorithm
; 09:		vertical scrolling from algorithm
; 0A:		temporary hi bit of xpos
; 0B:		temporary YXPPCCCT
; 0C:		YXPP bits from BG settings


;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	This routine can be used by sprites to load a raw OAM tilemap.
;	To use it, do:
;		PHB
;		LDA.b #Tilemap
;		STA $04
;		LDA.b #Tilemap>>8
;		STA $05
;		LDA.b #Tilemap>>16
;		PHA : PLB
;		JSL LOAD_TILEMAP
;		PLB
;
;	$00:		sprite Xpos within screen
;	$02:		sprite Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		pointer to hi tilemap
;	$08:		copy of next byte in hi tilemap
;	$0A:		tile Xpos within screen
;	$0C:		pointer to [hi OAM table] + [OAM index]/4
;	$0E:		x-flip flag (0x0000 = xflip, 0xFFFF = no xflip)

	!HiIndex	= $7FC774			; 12 bytes

LOAD_TILEMAP:	PHX					; Push sprite index
		PHP					; Push processor
		LDY #$02				; Base index = 0x02 to skip past tilemap header
		LDA $157C,x				;\
		BEQ $02 : LDA #$FF			; | Set x-flip flag
		STA $0E					; |
		STA $0F					;/
		LDA $E4,x				;\
		STA $00					; | Store 16-bit xpos to scratch RAM
		LDA $14E0,x				; |
		STA $01					;/
		LDA $15EA,x				;\
		STA $0C					; | Store 16-bit OAM index to scratch RAM
		LDA !HiIndex,x				; |
		STA $0D					;/
		LDA $14D4,x				;\
		XBA					; |
		LDA $D8,x				; |
		REP #$30				; |
		SEC : SBC $1C				; | Calculate sprite's coordinates within the screen
		STA $02					; |
		LDA $00					; |
		SEC : SBC $1A				; |
		STA $00					;/
		LDA $0C					;\
		TAX					; |
		LSR #2					; | Set up hi OAM pointer
		CLC : ADC #!OAMhi			; |
		STA $0C					;/
		CLC : ADC $04				;\ Calculate hi tilemap location
		STA $06					;/
.Loop		LDA ($06)				;\
		AND #$0002				; | Copy tile size
		STA $08					;/
		LDA ($04),y				;\
		AND #$00FF				; |
		BIT $0E					; |
		BMI $04 : EOR #$FFFF : INC A		; |
		CLC : ADC $00				; |
		BIT $0E					; | Calculate xpos based on coords, disp, size, and xflip
		BMI +					; |
		LSR $08					; |
		LSR $08					; |
		BCC +					; |
		SEC : SBC #$0008			;/
	+	CMP #$0100				;\
		BCC +					; | Only draw tile if -17 < X < 256
		CMP #$FFF0				; |
		BCS +					;/
		INC $06					;\
		INC $0C					; |
		INY #4					; | Loop
		TYA					; |
		CMP ($04)				; |
		BNE .Loop				;/
		PLB					;\
		PLP					; | Return if loop fails
		PLX					; |
		RTL					;/
	+	STA $0A					; Store 16-bit tile xpos within screen
		INY					;\
		LDA ($04),y				; |
		AND #$00FF				; |
		CLC : ADC $02				; | Only draw tile if -17 < Y < 232
		CMP #$00E8				; |
		BCC +					; |
		CMP #$FFF0				; |
		BCS +					;/
		INC $06					;\
		INC $0C					; |
		INY #3					; | Loop
		TYA					; |
		CMP ($04)				; |
		BNE .Loop				;/
		PLB					;\
		PLP					; | Return if loop fails
		PLX					; |
		RTL					;/
	+	SEP #$20				; A 8 bit
		STA !OAM+$01,x				; Store Ydisp
		LDA $0A					;Read Xdisp
		STA !OAM+$00,x				;\ Store Xdisp
		INY					;/
		LDA ($04),y				; Read tile
		STA !OAM+$02,x				;\ Store tile
		INY					;/
		LDA ($04),y				;\
		BIT $0E					; |
		BMI $02 : EOR #$40			; | Calculate and store prop
		STA !OAM+$03,x				; |
		INY					;/
		LDA $0B					;\
		EOR ($06)				; | Store hi byte
		STA ($0C)				;/
		REP #$20				;\
		INC $06					; |
		INC $0C					; | Loop
		TYA					; |
		CMP ($04)				; |
		BEQ .Return				;/
		JMP .Loop
.Return		PLP					; Restore processor
		PLX					; Restore sprite index
		RTL					; Return


;=========;
;DMA REMAP;
;=========;
incsrc "DMA_Remap.asm"