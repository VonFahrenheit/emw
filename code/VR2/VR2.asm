header
sa1rom

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

;=======;
;DEFINES;
;=======;

	incsrc "Defines.asm"

;======;
;MACROS;
;======;

macro loadOAMindex()
	LDA !OAMindex
	TAY
	CLC : ADC #$04
	STA !OAMindex
	BCC ?NoOverflow
	INC !OAMindexhi
	?NoOverflow:
endmacro

macro loadOAMindex2()
	LDA !OAMindex
	TAY
	CLC : ADC #$08
	STA !OAMindex
	BCC ?NoOverflow
	INC !OAMindexhi
	?NoOverflow:
endmacro

macro loadOAMindex4()
	LDA !OAMindex
	TAY
	CLC : ADC #$10
	STA !OAMindex
	BCC ?NoOverflow
	INC !OAMindexhi
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
	JSL OAM_handler_minor1
	NOP #2
endmacro


macro minorOAMremap2(address)
	org <address>
	JSL OAM_handler_minor2
	NOP #2
endmacro



;=============;
;OAM REMAPPING;
;=============;

; --Remap sprites--

	org $0180D2
		JML OAM_handler				;\ Source: PHX : TXA : LDX $1692
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
	RETURN:
		JML OAM_handler_extG			;\ Source: LDY $A153,x : STY $0F
		NOP					;/
		.extG
	org $02A362
		JML OAM_handler_ext01special		;\ Source: LDY $A153,x : CPY #$08
		NOP					;/
		.ext01special
	org $02A367
		JML OAM_handler_ext01			;\ Source: BCC $03 : LDY $9FA3,x
		NOP					;/
		.ext01
	org $02A180
		JML OAM_handler_ext02			;\ Source: LDY $A153,x : LDA $14
		NOP					;/
		.ext02
	org $02A235
	;	JML OAM_handler_ext03			;\ Source: LDY $A153,x : LDA $1765,x
	;	NOP #2					;/
	NOP #3
	LDA $7765,x
		.ext03
	org $02A31A
	;	JML OAM_handler_ext04			;\ Source: LDY $A153,x : LDA $1765,x
	;	NOP #2					;/
	NOP #3
	LDA $7765,x
		.ext04
	org $02A03B
		JML OAM_handler_ext05			;\ Source : LDY $9FA3,x : JSR $A1A7
		NOP #2					;/
	org $02A1A4
		JML OAM_handler_ext05			;\ Source : LDY $A153,x : LDA $1747,x
		NOP #2					;/
		.ext05
	org $029E9D
	;	JML OAM_handler_ext07			;\ Source: LDY $A153,x : LDA $171F,x
	;	NOP #2					;/
	NOP #3
	LDA $771F,x
		.ext07
	org $029E5F
	;	JML OAM_handler_ext08			; Source: LDY $A153,x : PLA
	NOP #3
	PLA
		.ext08
	org $029B51
		JML OAM_handler_ext0C			;\ Source: LDY $A153,x : LDA $171F,x
		NOP #2					;/
		.ext0C
	org $02A287
	;	JML OAM_handler_ext0D			;\ Source: LDY $A153,x : LDA $00
	;	NOP					;/
	NOP #3
	LDA $00
		.ext0D
	org $029C41
	;	JML OAM_handler_ext0F			;\ Source: LDY $A153,x : LDA $176F,x
	;	NOP #2					;/
	NOP #3
	LDA $776F,x
		.ext0F
	org $029C8B
	;	JML OAM_handler_ext10			;\ Source: LDY $A153,x : LDA #$34
	;	NOP					;/
	NOP #3
	LDA #$34
		.ext10
	org $029F76
	;	JML OAM_handler_ext11			;\ Source: LDY $A153,x : LDA #$04
	;	NOP					;/
	NOP #3
	LDA #$04
		.ext11
	;org $029F46
	;	JML OAM_handler_ext12			;\ Source: LDY $A153,x : LDA $0200,y
	;	NOP #2					;/
	org $029F40
	TAX
	LDA $9EEA,x
	STA $00
	LDX $75E9
	LDA !OAM,y
		.ext12

; --Remap smoke sprites--

	org $02999F
		JML OAM_handler_smokeG			;\ Source: LDY $96BC,x : LDA $17C8,x
		NOP #2					;/
		.smokeG
	org $029701
		JML OAM_handler_smoke01special		;\ Source: LDY $96BC,x : LDA $17C8,x
		NOP #2					;/
		.smoke01special
	org $02974A
		JML OAM_handler_smoke01
		NOP #2
		.smoke01
	org $0297B2
		JML OAM_handler_smoke02			;\ Source: LDY #$F0 : LDA $17C8,x
		NOP					;/
		.smoke02
	org $029936
		JML OAM_handler_smoke03l		;\ Source: LDY $96BC,x : LDA #$F0
		NOP					;/
		.smoke03l
	org $02996F
		JML OAM_handler_smoke03h		; > Source: LDA $77C8,x : SEC
		.smoke03h

; --Remap bounce sprites--

	org $02922D
		JML OAM_handler_bounce			;\ Source: LDY $91ED,x : LDA $16A1,x
		NOP #2					;/
		.bounce

; --Remap score sprites--

	org $02AE9B
		JML OAM_handler_score			;\ Source: LDY $AD9E,x : BIT $0D9B
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
		JML UploadGFX				; SEI : PHP : REP #$30
	org $0081AF
		BRA $01 : NOP				; STZ $420C
	org $008217
		JSR $A395				; Skip past LM's bullshit
	org $008289
		BRA $04 : NOP #4			; LDY $0D9F : STY $420C

	org $0082A4
		JML NMI					;\ Source: STZ $2111 : STZ $2111
		NOP #2					;/

	;org $0082B6
	;	BRA $04 : NOP #4			; LDA $0D9F : STA $420C

	org $0082BC
		JML ReturnNMI				; REP #$30 : PLB : PLY

	org $00838F
		JML IRQ
	org $0083B2
		JML ReturnNMI				; REP #$30 : PLB : PLY
	org $008293
		db $D6					; IRQ scanline


	org $00A2EE
	;	JML CREATE_RAM_CODE			;\ Source: STA $1C : JMP $8494
	;	NOP					;/
		STA $1C
		JMP $8494

	org $00A390
		-
	org $00A395
		LDY !AnimToggle
		BEQ -
		RTS
	org $00A601
		JSR $A395				; Skip past LM's bullshit


	org $02A207
		TAX					; index fix (Y now returns with OAM index)
		STZ !OAMhi,x				; Org: TAY : LDA #$00 : STA $6420,y : LDX $75E9 : RTS
		LDX $75E9
		RTS
		RTS
		RTS


	incsrc "optimize_2132_store.asm"


;===========;
;CUSTOM CODE;
;===========;
;freecode

org $129000
print "VR2 inserted at $", pc, "."


ReturnNMI:	REP #$30
		PLD					;\
		PLB					; |
		PLY					; | Restore everything
		PLX					; | (including DP!)
		PLA					; |
		PLP					;/
		RTI					; > Return from interrupt

;=============;
;NMI EXPANSION;
;=============;
NMI:

		LDA !GameMode
		CMP #$0E : BNE .NotMenu
		LDA $6D9D : STA $212C		;\ Main screen and window designation
		STA $212E			;/
		LDA $6D9E : STA $212D		;\ Sub screen and window designation
		STA $212F			;/
		BRA .SpecialLevel
		.NotMenu

		LDA $6D9B : BNE .SpecialLevel
		LDA $6D9D : STA $212C		;\ Main screen and window designation
		STA $212E			;/
		LDA $6D9E : STA $212D		;\ Sub screen and window designation
		STA $212F			;/

		LDA $22 : STA $2111		;\ Layer 3 Hscroll
		LDA $23 : STA $2111		;/
		LDA $24 : STA $2112		;\ Layer 3 Vscroll
		LDA $25 : STA $2112		;/
		LDA $3E : STA $2105		; > Screen mode
		LDA $40 : STA $2131		;\ Color math settings
		LDA $44 : STA $2130		;/
		JML $0082B0			; > Return

.SpecialLevel	STZ $2111
		STZ $2111
		STZ $2112
		STZ $2112
		JML $0082B0			; > Return

;=============;
;IRQ EXPANSION;
;=============;
IRQ:
		PHD				; > Push direct page
		LDA #$42 : XBA			;\ DP = 0x420B
		LDA #$0B : TCD			;/
		LDA #$80 : STA $2100		; > Enable f-blank
		STZ $2115			;\
		REP #$20			; |
		LDA #$5000			; |
		STA $2116			; |
		LDA #$1800			; |
		STA $F5				; |
		LDA #$6EF9			; |
		STA $F7				; | Upload status bar tilemap
		LDX #$00			; |
		STX $F9				; |
		LDA #$0020			; |
		STA $FA				; |
		LDX #$01			; |
		STX $00				;/
		LDX #$80			;\
		STX $2115			; |
		LDA #$5000			; |
		STA $2116			; |
		LDA #$1900			; |
		STA $F5				; |
		LDA.w #.StatusProp		; | Upload status bar YXPCCCTT
		STA $F7				; |
		LDX.b #.StatusProp>>16		; |
		STX $F9				; |
		LDA #$0020			; |
		STA $FA				; |
		LDX #$01			; |
		STX $00				;/
		LDA #$2202			;\
		STA $F5				; |
		LDA.w #.StatusPal		; |
		STA $F7				; |
		LDX.b #.StatusPal>>16		; |
		STX $F9				; | Upload status bar palette
		LDA #$0016			; |
		STA $FA				; |
		LDX #$01			; |
		STX $2121			; |
		LDX #$01			; |
		STX $00				;/
		LDA #$2100 : TCD		; > Direct page = 0x2100
		SEP #$20			; > A 8 bit
		STZ $11				;\ Layer 3 Hscroll
		STZ $11				;/
		LDA !GameMode			;\
		CMP #$14			; |
		BEQ .Level			; | Only display status bar during level game mode
		STZ $12				; |
		STZ $12				; |
		BRA .Shared			;/
.Level		LDA #$27 : STA $12		;\ Layer 3 Vscroll
		LDA #$FF : STA $12		;/
.Shared		LDA #$04 : STA $2C		; > Main screen designation
		STZ $24				;\ Disable windowing
		STZ $2E				;/
		STZ $30				;\ Color math settings
		STZ $31				;/
		STZ $21				;\
		STZ $22				; | Color 0 to black
		STZ $22				;/
		LDA #$09 : STA $05		; > GFX mode 1 + Layer 3 priority
		BIT $4212 : BVC $FB		;\ Wait for h-blank and restore brightness
		LDA $6DAE : STA $00		;/
		REP #$30			;\
		PLD				; |
		PLB				; |
		PLY				; | Return from interrupt
		PLX				; |
		PLA				; |
		PLP				; |
		RTI				;/


.StatusProp	db $28,$24,$24,$24,$24		; P1 coins
		db $20,$20,$20,$20,$20,$20	; P1 hearts
		db $28,$28,$28,$28,$28		;\ Yoshi coins
		db $28,$28,$28,$28,$28		;/
		db $20,$20,$20,$20,$20,$20	; P2 hearts
		db $28,$24,$24,$24,$24

.StatusPal	dw $0000,$0CFB,$2FEB		; Palette 0
		dw $0000,$0000,$7AAB,$7FFF	; Palette 1
		dw $0000,$0000,$1E9B,$3B7F	; Palette 2


;===============;
;CREATE RAM CODE;
;===============;

	!LoadSize	= !VRAMtable+$FC
	!LoadIndex	= !VRAMtable+$FE

	!MaxUpload1	= $0400				; Maximum amount of data to be uploaded in one frame
	!MaxUpload2	= $0600


CREATE_RAM_CODE:

		STA $1C					; > Overwritten code
		PHP
		SEP #$30
		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | Have the SA-1 generate code
		LDA.b #.SA1>>16 : STA $3182		; |
		JSR $1E80				;/
		PLP
		JML $008494				; > "Return"


		.SA1
		PHP
		PHB
		REP #$20
		STZ $00					; > $00 = code written flag
		LDA !RAMcode_flag : STA $02
		STZ !RAMcode_flag			; > Disable RAM code
		SEP #$30
		LDA.b #!VRAMbank			;\ Bank $40
		PHA : PLB				;/
		REP #$30				; > All regs 16-bit
		LDY.w #!MaxUpload1			;\
		LDA !AnimToggle				; |
		AND #$00FF				; | Determine maximum transfer size
		CMP #$0002				; |
		BNE $03 : LDY.w #!MaxUpload2		; |
		TYA : STA.w !LoadSize			;/
		LDY.w !LoadIndex			; > Y = index to VRAM table
		LDX.w !RAMcode_Offset			; > X = index to RAM code

	.LoopFull
		LDA !VRAMtable+$00,y			;\
		BNE .Write				; |
	.Loop	TYA					; |
		CLC : ADC #$0007			; | Search for transfer data
		TAY					; |
		CMP #$00F8 : BCC .LoopFull		; |
		STZ.w !LoadIndex			; |
		JMP .End				;/

	.Write	STA $41800B,x				; > Upload size
		PHA
		INC $00					; > Code has been written
		LDA #$00A9				; LDA #$00XX
		STA $418000,x				;\
		STA $418005,x				; | In these spots
		STA $41800A,x				; |
		STA $41800F,x				;/
		LDA #$0285 : STA $418003,x		; STA $02
		LDA #$0485 : STA $418008,x		; STA $04
		LDA #$0585 : STA $41800D,x		; STA $05
		LDA #$168D : STA $418012,x		;\ STA $2116 : LDA #XXXX
		LDA #$A921 : STA $418014,x		;/
		LDA #$0085 : STA $418018,x		; STA $00
		PLA
		SEC : SBC.w !LoadSize			;\
		BPL .Final				; | Update upload sum
		EOR #$FFFF : INC A			; |
		STA.w !LoadSize				;/
		LDA #$0000 : STA.w !VRAMtable+$00,y	; > Clear this entry
		LDA !VRAMtable+$02,y : STA $418001,x	; > Source
		LDA !VRAMtable+$04,y			;\
		AND #$00FF				; | Bank
		STA $418006,x				;/
		LDA !VRAMtable+$05,y : STA $418010,x	; > VRAM destination
		BPL +					; > Determine transfer direction
		LDA #$3981 : STA $418016,x		; > DMA mode
		LDA #$39AD : STA $41801A,x		;\
		LDA #$8C21 : STA $41801C,x		; | LDA $2139 : STY $420B
		LDA #$420B : STA $41801E,x		;/
		TXA					;\
		CLC : ADC #$0020			; | Update index and loop
		TAX					; |
		JMP .Loop				;/

	+	LDA #$1881 : STA $418016,x		; > DMA mode
		LDA #$8C8C : STA $41801A,x		;\ STY $420B
		LDA #$420B : STA $41801B,x		;/
		TXA					;\
		CLC : ADC #$001D			; | Update index and loop
		TAX					; |
		JMP .Loop				;/


	.Final	BNE +					;\ Increment index if necessary
		INY #7					;/
	+	STY.w !LoadIndex			; Next index
		STA !VRAMtable+$00,y			; Next upload = remaining data
		LDA.w !LoadSize : STA $41800B,x		; Current upload = max data
		LDA.w !VRAMtable+$02,y : STA $418001,x	;\
		LDA.w !VRAMtable+$04,y			; | Upload source
		AND #$00FF				; |
		STA $418006,x				;/
		LDA.w !LoadSize				;\
		CLC : ADC.w !VRAMtable+$02,y		; | Next upload source
		STA.w !VRAMtable+$02,y			;/
		LDA.w !VRAMtable+$05,y : STA $418010,x	; Current dest VRAM
		LDA.w !LoadSize				;\
		LSR A					; | Next dest VRAM
		CLC : ADC !VRAMtable+$05,y		; |
		STA !VRAMtable+$05,y			;/
		BPL +					; > Determine transfer direction
		LDA #$3981 : STA $418016,x		; > DMA mode
		LDA #$39AD : STA $41801A,x		;\
		LDA #$8C21 : STA $41801C,x		; | LDA $2139 : STY $420B
		LDA #$420B : STA $41801E,x		;/
		TXA
		CLC : ADC #$0020
		TAX
		BRA .End

	+	LDA #$1881 : STA $418016,x		; > DMA mode
		LDA #$8C8C : STA $41801A,x		;\ STY $420B
		LDA #$420B : STA $41801B,x		;/
		TXA
		CLC : ADC #$001D
		TAX

	.End	LDA #$6B6B : STA $418000,x
		STX.w !RAMcode_Offset
		PLB
		LDA #$1234				;\
		LDY $00					; | Always enable RAM code if a routine was just created
		BNE $02 : LDA $02			; | Otherwise, restore the previous flag
		STA !RAMcode_flag			;/
		PLP
		RTL



;===================;
;VRAM UPLOAD ROUTINE;
;===================;


UploadGFX:	SEI
		PHP
		REP #$30
		PHA
		PHX
		PHY
		PHB
		PHD
		PEA !VRAMbank*$100			;\ Bank $00
		PLB					;/ With VRAM bank on stack

		LDA #$0000 : STA $7FC7FE		; > Clear special table flag

		LDA !GameMode				;\
		AND #$00FF				; |
		CMP #$000E : BNE .NotMenu		; | Dynamic upload for menu
		PLB					; |
		JSR Upload_Shorthand			; |
		JMP ReturnToNMI				;/
		.NotMenu


		LDA $3000+!AnimToggle
		AND #$00FF
		CMP #$0002
		BEQ +
		LDA.w #!MaxUpload1
		STA $00CC
		BRA ++
		+
		LDA.w #!MaxUpload2
		STA $00CC
		++

		LDA #$4300 : TCD			; Direct page = 0x4300
		SEP #$30				; A and index 8 bit
		LDA $4210
		LDA #$80
		STA $2100
		STZ $420C

	; Because DP = 0x4300, the following is true:
	; $00 = $4300
	; $02 = $4302
	; $04 = $4304
	; $05 = $4305

		LDA $6D9B
		BNE +
		LDA #$80				;\
		STA $2115				; |
		REP #$20				; |
		LDA #$5000				; |
		STA $2116				; |
		LDA #$1801				; |
		STA $00					; |
		LDA.w #$0020				; | Upload top row of dynamic BG3
		STA $02					; |
		LDX #$00				; |
		STX $04					; |
		LDA #$0040				; |
		STA $05					; |
		LDY #$01				; |
		STY $420B				;/
		LDA #$2202				;\
		STA $00					; |
		LDA.w #$00A0				; |
		STA $02					; |
		LDA #$0016				; | Upload color
		STA $05					; |
		STY $2121				; |
		STY $420B				;/
		SEP #$20				; > A 8 bit
		+

		STZ !OAMindex				;\ Clear OAM index at every NMI
		STZ !OAMindexhi				;/
.Start		REP #$20				; > A 16 bit
		LDY #$80				; Word writes
		STY $2115


;	LDY $3000+!AnimToggle
;	CPY #$02
;	BNE +

;	LDA $14			;\
;	LSR A			; |
;	BCC +			; | Frame counter has updated now, so use alternate bit
;	JMP ++			; |
;	+			;/



; Plan:
;	- Read index
;	- Upload data
;	- Subtract 7 from index
;	- Loop if positive (index only goes to 0x77 so it will always work)
;
;	LDA #$1801 : STA $00		;\
;	LDY #$01			; | 12 cycles for setup
;	LDX !P2DynamoNumber		; |
;	BMI +				;/
;
;-	LDA !P2DynamoSource,x : STA $02	;\
;	LDA !P2DynamoBank,x : STA $04	; |
;	LDA !P2DynamoSize,x : STA $05	; |
;	LDA !P2DynamoDest,x : STA $2116	; |
;	STY $420B			; | 43 cycles per upload
;	TXA				; | (final upload is 40 cycles)
;	SEC : SBC #$0007		; |
;	BMI +				; |
;	TAX				; |
;	BRA -				; |
;	+				;/


		LDA !RAMcode_flag
		CMP #$1234
		BNE ++

		LDA #$1801 : STA $00			;\ Set up
		LDY #$01				;/
		JSL $418000				; > Run RAM code
		STZ !RAMcode_flag
		LDA #$0000 : STA.l !RAMcode_Offset

	++	JMP .VRAMtransfer

.LevelMode	STA $00CA				; > Preserve
		AND #$3FFF : STA $05			; > Upload size
		LDA #$0000 : STA.w !VRAMtable+0,y	; > Clear slot
		LDA.w !VRAMtable+2,y : STA $02		;\ Source
		LDA.w !VRAMtable+3,y : STA $03		;/
		LDA.w !VRAMtable+5,y : STA.l $002116	; > Dest VRAM
		SEP #$20				;\
		LDA $00CB				; |
		AND #$80				; |
		ASL A					; | Set VRAM increment based on direction
		ROL A					; |
		ORA #$80				; |
		STA $00C9				; > Back this up
		STA.l $002115				;/
		REP #$20				;\
		LDA $00CA				; | Determine RLE
		AND #$4000 : BEQ +			;/
		LDA #$1809 : STA $00			;\
		SEP #$20				; |
		LDA $00C9				; |
		AND #$7F				; |
		STA.l $002115				; |
		LDA #$01 : STA.l $00420B		; |
		LDA $00C9 : STA.l $002115		; | Upload RLE
		LDA #$19 : STA $01			; |
		REP #$20				; |
		LDA.w !VRAMtable+5,y : STA.l $002116	; |
		LDA.w !VRAMtable+2,y			; |
		INC A					; |
		STA $02					; |
		BRA ++					;/

	+	LDA #$1801 : STA $00			;\ Upload non-RLE
	++	LDA #$0001 : STA.l $00420B		;/

		SEP #$20				;\
		LDA #$80 : STA.l $002115		; | Restore VRAM increment
		REP #$20				;/
		BRA ++					; > Loop


.VRAMtransfer	LDA $00CC				; Load variable upload cap
		PLB					; Set VRAM bank
		STA.w !LoadSize				; Store cap
		LDX.w !LoadIndex
.Loop		LDA.l VRAM_Index,x : TAY
		LDA.w !VRAMtable+0,y			;\
		CMP #$4000 : BCC $03 : JMP .LevelMode	; > Special case
		CMP #$0000 : BNE .Go			; |
		INX					; |
		CPX #$24				; | End upload after checking entire table
		BNE .Loop				; |
		STZ.w !LoadIndex			; |
		JMP UPLOAD_CGRAM			;/
.Go		STA $05					; > 4305 = data size
		SEC : SBC.w !LoadSize			;\ Limit data per frame
		BPL .FinalBatch				;/
		EOR #$FFFF : INC A			;\ Update data cap remaining
		STA !LoadSize				;/
		LDA.w #$0000				;\ Clear slot
		STA.w !VRAMtable+0,y			;/
		LDA.w !VRAMtable+2,y			;\
		STA $02					; | Source data
		LDA.w !VRAMtable+3,y			; |
		STA $03					;/
		LDA.w !VRAMtable+5,y			;\ Dest VRAM
		STA.l $002116				;/
		XBA					;\
		AND #$0080				; |
		BEQ +					; |
		LDA $002139				; | Transfer direction (+dummy read)
		LDA #$3981				; |
	+	ORA #$1801				; |
		STA $00					;/
		LDA #$0001 : STA $00420B		; > Transfer data ($420C is 0 anyway)
	++	INX					;\
		CPX #$24				; |
		BNE .Loop				; | Loop, end at upload index = 0x24
		STZ.w !LoadIndex			; |
		BRA UPLOAD_CGRAM			;/

.FinalBatch	BNE +					;\ Increment index if necessary
		INX					;/
	+	STA.w !VRAMtable+0,y			; Next upload = remaining data
		LDA.w !LoadSize				;\ Current upload = max data
		STA $05					;/
		LDA.w !VRAMtable+2,y			;\
		STA $02					; | Current upload source
		LDA.w !VRAMtable+3,y			; |
		STA $03					;/
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
		STA $00					;/
		LDA #$0001 : STA $00420B		; > Upload
		STX !LoadIndex				; > Queue remaining data
	.End


UPLOAD_CGRAM:	LDA #$2202				;\ Parameters and destination of DMA
		STA $00					;/
		LDX #$00

.Loop		LDA.l CG_Index,x : TAY
		LDA.w !CGRAMtable+0,y			;\ End upload at an 0x0000 word
		BEQ ReturnToNMI				;/
		STA $05					;\
		LDA.w #$0000				; | Set data size and clear slot
		STA.w !CGRAMtable+0,y			;/
		LDA.w !CGRAMtable+2,y			;\
		STA $02					; | Source address
		LDA.w !CGRAMtable+3,y			; |
		STA $03					;/
		SEP #$20				;\
		LDA.w !CGRAMtable+5,y			; | Set dest CGRAM
		STA.l $002121				; |
		REP #$20				;/
		LDA #$0001 : STA $00420B		; > Upload data
		INX
		CPX #$2A
		BNE .Loop

ReturnToNMI:	REP #$20				; > A 16-bit
		LDA #$3000 : TCD			; > DP = $3000
		SEP #$30				; > All registers 8 bit
		LDA #$00 : PHA : PLB			; > Set bank
		LDA !AnimToggle
		CMP #$02
		BEQ MinimalistNMI

		.StandardNMI
		LDA $6D9F : STA $420C			; > Enable HDMA
		JML $008179				; > Return to NMI routine

MinimalistNMI:
		LDA $6D9F : STA $420C			; > Enable HDMA

		LDA !CurrentMario : BEQ .Skip
		DEC A
		AND $14
		BEQ .MarioDMA				; Update Mario every other frame
	.Skip	REP #$20
		JMP ++

		.MarioDMA
		REP #$20
		LDX #$02
		LDY $6D84
		BEQ +
		LDY #$86 : STY $2121
		LDA #$2200 : STA $4310
		LDA $6D82 : STA $4312
		LDY #$00 : STY $4314
		LDA #$0014 : STA $4315
		STX $420B
	+	LDY #$80 : STY $2115
		LDA #$1801 : STA $4310
		LDA #$6070 : STA $2116
		LDA $6D99 : STA $4312
		LDY #$7E : STY $4314
		LDA #$0020 : STA $4315
		STX $420B
		LDA #$6000 : STA $2116
		LDX #$00
	-	LDA $6D85,x : STA $4312
		LDA #$0040 : STA $4315
		LDY #$02 : STY $420B
		INX #2
		CPX #$06 : BCC -
		LDA #$6100 : STA $2116
		LDX #$00
	-	LDA $6D8F,x : STA $4312
		LDA #$0040 : STA $4315
		LDY #$02 : STY $420B
		INX #2
		CPX #$06 : BCC -
		++

	.MenuHook

		STZ $4300				;\
		STZ $2102				; |
		LDA #$0004 : STA $4301			; | Update OAM
		LDA #$0062 : STA $4303			; |
		LDA #$0220 : STA $4305			; |
		LDY #$01 : STY $420B			;/
		SEP #$20				; > A 8 bit
		LDA #$80 : STA $2103			;\ OAM priority
		LDA $3F : STA $2102			;/



		LDA $4218
		AND #$F0
		STA $6DA4
		TAY
		EOR $6DAC
		AND $6DA4
		STA $6DA8
		STY $6DAC

		LDA $4219
		STA $6DA2
		TAY
		EOR $6DAA
		AND $6DA2
		STA $6DA6
		STY $6DAA

		LDA $421A
		AND #$F0
		STA $6DA5
		TAY
		EOR $6DAD
		AND $6DA5
		STA $6DA9
		STY $6DAD

		LDA $421B
		STA $6DA3
		TAY
		EOR $6DAB
		AND $6DA3
		STA $6DA7
		STY $6DAB

		LDA $6DA4
		AND #$C0
		ORA $6DA2
		STA $15
		LDA $6DA4
		STA $17
		LDA $6DA8
		AND #$40
		ORA $6DA6
		STA $16
		LDA $6DA8
		STA $18


		REP #$10
		TSX : TXY
		LDX #$2112 : TXS
		LDA $24 : PHA				;\
		LDA $25 : STA $01,s			; | BG3
		LDA $22 : PHA				; |
		LDA $23 : STA $01,s			;/
		LDA $20 : PHA				;\
		LDA $21 : STA $01,s			; | BG2
		LDA $1E : PHA				; |
		LDA $1F : STA $01,s			;/
		LDA $1C : PHA				;\
		LDA $1D : STA $01,s			; | BG1
		LDA $1A : PHA				; |
		LDA $1B : STA $01,s			;/
		TYX : TXS
		SEP #$10

		LDA $3E : STA $2105			; > Screen mode
		LDA $6D9D : STA $212C			;\ Main screen and window designation
		STA $212E				;/
		LDA $6D9E : STA $212D			;\ Sub screen and window designation
		STA $212F				;/
		LDA $40 : STA $2131			;\ Color math settings
		LDA $44 : STA $2130			;/
		LDA $41 : STA $2123			;\
		LDA $42 : STA $2124			; | Window settings
		LDA $43 : STA $2125			;/


		LDY #$D6
		LDA $4211
		STY $4209
		STZ $420A
		STZ $11
		LDA #$A1 : STA $4200
		LDA $6DAE : STA $2100
		INC $10					; Start next frame
		REP #$30				; > All regs 16 bit
		PLD					;\
		PLB					; |
		PLY					; | Restore everything
		PLX					; | (including DP!)
		PLA					; |
		PLP					;/
		RTI					; > Return from interrupt




Upload_Shorthand:
		SEP #$30
		LDA #$80 : STA.l $002115
		REP #$20
		LDA #$4300 : TCD
		LDA #$1801 : STA $00
		LDX #$00
	.Loop	LDA.l VRAM_Index,x				;\
		TAY						; |
		LDA.w !VRAMtable+0,y : BEQ .Next		; |
		STA $05						; |
		LDA #$0000 : STA.w !VRAMtable+0,y		; |
		LDA.w !VRAMtable+2,y : STA $02			; | upload VRAM table
		LDA.w !VRAMtable+3,y : STA $03			; |
		LDA.w !VRAMtable+5,y : STA.l $002116		; |
		LDA #$0001 : STA.l $00420B			; |
	.Next	INX						; |
		CPX #$24 : BNE .Loop				;/

	.CG	LDA.w !CGRAMtable+0 : BEQ .Done			;\
		STA $05						; |
		STZ.w !CGRAMtable+0				; |
		LDA #$2202 : STA $00				; |
		LDA.w !CGRAMtable+2 : STA $02			; | upload first slot from CGRAM table
		LDA.w !CGRAMtable+3 : STA $03			; |
		SEP #$20					; |
		LDA.w !CGRAMtable+5 : STA.l $002121		; |
		LDA #$01 : STA.l $00420B			;/

	.Done	RTS



VRAM:
.Index		db $00,$07,$0E,$15,$1C,$23,$2A,$31
		db $38,$3F,$46,$4D,$54,$5B,$62,$69
		db $70,$77,$7E,$85,$8C,$93,$9A,$A1
		db $A8,$AF,$B6,$BD,$C4,$CB,$D2,$D9
		db $E0,$E7,$EE,$F5

CG:
.Index		db $00,$06,$0C,$12,$18,$1E,$24,$2A
		db $30,$36,$3C,$42,$48,$4E,$54,$5A
		db $60,$66,$6C,$72,$78,$7E,$84,$8A
		db $90,$96,$9C,$A2,$A8,$AE,$B4,$BA
		db $C0,$C6,$CC,$D2,$D8,$DE,$E4,$EA
		db $F0,$F6


;===========;
;OAM HANDLER;
;===========;
OAM_handler:	PHX : TXY				; > Use Y as sprite index
		CPY #$0F				;\ Check for highest sprite
		BNE .NotHighest				;/
		LDA !P2TilesUsed			;\ Highest sprite always gets index after P2
		BRA .Write				;/
.NotHighest	LDA $3230+1,x : BNE .Valid		;\
		INX					; |
		CPX #$0F : BNE .NotHighest		; |
.Highest	LDA !P2TilesUsed			; |
		BRA .Write				; | Cycle through sprites to find the lowest one above this one
.Valid		STX $00					;/ (this becomes the highest one if there's no one higher)


	; Y = sprite index
	; X = index for lowest higher sprite -1
	;	(sprite to read from)



		LDA $3590+1,x				;\
		AND #$08				; |
		BEQ .Vanilla				; |
		LDA $35C0+1,x				; | Handle custom sprite
	CMP #$12 : BNE +
	LDA $3590+1,x
	AND #$04					; EXCEPTION FOR CUSTOM SPRITE 0x12!!
	EOR #$04
	BEQ +
	LDA #$10
	+
		TAX					; |
		LDA.l TileCount_Custom,x		; |
		ASL #2					; |
.Calc		LDX $00					; |
		CLC : ADC $33B0+1,x			; |
		BRA .Write				;/
.Vanilla	LDA $3200+1,x				;\
		TAX					; |
		LDA.l TileCount_Vanilla,x		; |
		ASL #2					; | Handle vanilla sprite
		LDX $00					; |
		CLC : ADC $33B0+1,x			; |
.Write		PLX					; |
		STA $33B0,x				;/
		JML $0180E5				; > Return



; --Minor extended sprite routines--

.minor1		%loadOAMindex()
		LDA $7808,x
		RTL
.minor2		%loadOAMindex()
		LDA $77FC,x
		RTL

; --Extended sprite routines--

.extG		%loadOAMindex()
		STY $0F
		JML RETURN_extG
.ext01special	%loadOAMindex()
		CPY #$08
		JML RETURN_ext01special
.ext01		BCC +
		%loadOAMindex()
	+	JML RETURN_ext01
.ext02		%loadOAMindex()
		LDA $14
		JML RETURN_ext02
.ext03		%loadOAMindex()
		LDA $7765,x
		JML RETURN_ext03
.ext04		%loadOAMindex()
		LDA $7765,x
		JML RETURN_ext04
.ext05		%loadOAMindex()				;\
		LDA $7747,x				; | A lot of objects borrow this routine
		JML RETURN_ext05			;/
.ext07		%loadOAMindex()
		LDA $771F,x
		JML RETURN_ext07
.ext08		%loadOAMindex()
		PLA
		JML RETURN_ext08
.ext0C		%loadOAMindex()
		LDA $771F,x
		JML RETURN_ext0C
.ext0D		%loadOAMindex()
		LDA $00
		JML RETURN_ext0D
.ext0F		%loadOAMindex()
		LDA $776F,x
		JML RETURN_ext0F
.ext10		%loadOAMindex()
		LDA #$34
		JML RETURN_ext10
.ext11		%loadOAMindex()
		LDA #$04
		JML RETURN_ext11
.ext12		%loadOAMindex()
		LDA !OAM,y
		JML RETURN_ext12

; --Smoke sprite routines--

.smokeG		%loadOAMindex()
		LDA $77C8,x
		JML RETURN_smokeG
.smoke01special	%loadOAMindex()
		LDA $77C8,x
		JML RETURN_smoke01special
.smoke01	%loadOAMindex()
		LDA $77C8,x
		JML RETURN_smoke01
.smoke02	%loadOAMindex()
		LDA $77C8,x
		JML RETURN_smoke02
.smoke03l	%loadOAMindex()
		LDA #$F0
		JML RETURN_smoke03l
.smoke03h	%loadOAMindex()
		LDA $77C8,x
		SEC
		JML RETURN_smoke03h

; --Bounce sprite routine--

.bounce		%loadOAMindex()
		LDA $76A1,x
		JML RETURN_bounce

; --Score sprite routine--

.score		PHA
		%loadOAMindex2()
		PLA
		BIT $6D9B
		JML RETURN_score


TileCount:

		;   X0  X1  X2  X3  X4  X5  X6  X7  X8  X9  XA  XB  XC  XD  XE  XF

.Vanilla	db $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$01	; 0X
		db $03,$01,$00,$01,$01,$01,$01,$01,$01,$00,$02,$01,$01,$01,$0F,$03	; 1X
		db $03,$02,$02,$02,$02,$02,$05,$01,$14,$12,$01,$0A,$01,$00,$01,$04	; 2X
		db $03,$02,$02,$01,$01,$04,$00,$01,$01,$01,$04,$04,$04,$01,$01,$02	; 3X
		db $02,$02,$02,$03,$03,$02,$05,$01,$01,$02,$01,$02,$01,$02,$02,$05	; 4X
		db $05,$01,$03,$01,$10,$05,$05,$05,$05,$05,$05,$03,$05,$05,$09,$09	; 5X
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

.Custom		db $01,$06,$04,$05,$04,$08,$10,$01,$11,$10,$04,$03,$01,$04,$04,$02	; 0X
		db $15,$01,$01,$02,$02,$01,$03,$03,$09,$03,$01,$04,$02,$02,$08,$03	; 1X
		db $08,$0D,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 2X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 3X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 4X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 5X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 6X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 7X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 8X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 9X
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; AX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; BX
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


End:
print "VR2 is $", hex(End-ReturnNMI), " bytes long."
print "VR2 ends at $", pc, "."

;=========;
;DMA REMAP;
;=========;
incsrc "DMA_Remap.asm"