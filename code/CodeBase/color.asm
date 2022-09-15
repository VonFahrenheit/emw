;=============;
; COLOR CODES ;
;=============;

; these codes will convert colors between RGB and HSL format
; RGB colors are stored at $6703 (like normal) and HSL colors are stored at !PaletteHSL
; the HSL section is 1KB long, with the first 768 bytes holding HSL mirrors of the RGB palette
; the last 256 bytes is scratch RAM / cache for processing HSL colors without overwriting stuff
;
; input:
;	A = color balance (00-1F between palette and cache, used in mixers only)
;	X = color index (00-FF for colors 00-FF, 100-2FF to index HSL cache and HSL buffer)
;	Y = number of colors to convert (00 or 100+ will convert entire 256 color palette)
;	8-bit and 16-bit modes are both accepted
;
; output:
;	for RGB to HSL, color is written to !PaletteHSL
;	for HSL to RGB, color is written to buffer at !PaletteHSL+$900 (also uploaded to CGRAM if _Upload version is used)
;	for RGB mixer, colors are written to buffer at !PaletteHSL+$900 (also uploaded to CGRAM if _Upload version is used)
;	for HSL mixer, colors from !PaletteHSL and !PaletteHSL+$300 are mixed and written to !PaletteHSL+$600
;
; scratch RAM use:
;	$00 = R
;	$02 = G
;	$04 = B
;	$06 = D
;	$08 = scratch
;	$0A = H + scratch
;	$0C = S + scratch
;	$0E = L
;
; HSL format:
;	3 bytes per color
;	$00 H: 0-239 with R pole at 0/240, G pole at 80, B pole at 160
;	$01 S: 0-63
;	$02 L: 0-63
;

	!color1		= $F0
	!color2		= $F2
	!color3		= $F4
	!colorloop	= $F6
	!colormix	= $F8	; uses 4 bytes

	RGBtoHSL:
		PHP
		REP #$30
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		DEY
		STY !colorloop


; during the process, Y will index the RGB palette and X will index the HSL palette

		STX $00
		TXA
		ASL A
		TAY
		ADC $00
		TAX
		TYA
		AND #$01FF
		TAY


		TSC
		AND #$FF00
		CMP #$3700 : BEQ .SA1_go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTL

	.SA1
		PHP
		REP #$30
		LDX $00
		LDY $02
		..go
		PHB : PHK : PLB

		..loop
		CPY #$01FE			;\
		BCC $03 : LDY #$01FE		; | cap overflow
		CPX #$08FD			; |
		BCC $03 : LDX #$08FD		;/

		LDA $6703,y			;\
		AND #$001F			; | R
		STA $00				;/
		LDA $6703,y			;\
		LSR #5				; | G
		AND #$001F			; |
		STA $02				;/
		LDA $6703,y			;\
		XBA				; |
		LSR #2				; | B
		AND #$001F			; |
		STA $04				;/

		PHY
		TYA
		ASL #3
		XBA
		AND #$000F
		TAY
		LDA !LightList,y
		AND #$00FF
		CMP #$0001 : BNE ++
		LDA #$0100
		CMP !LightR : BNE +
		CMP !LightG : BNE +
		CMP !LightB : BEQ ++
	+	JSR ApplyLight
	++	JSR .Convert
		PLY

		SEP #$20
		LDA $0A : STA !PaletteHSL,x
		LDA $0C : STA !PaletteHSL+1,x
		LDA $0E : STA !PaletteHSL+2,x
		REP #$20

		INY #2
		INX #3
		DEC !colorloop : BPL ..loop

		PLB
		PLP
		RTL




; this code will convert RGB to HSL
	.Convert
		LDA $00
		CMP $02 : BCC .G
		CMP $04 : BCC .B
	.R	LDA $02
		CMP $04 : BCC .RBG
	.RGB	LDA $00				;\
		SEC : SBC $04			; |
		BRA +				; | get D (R greatest)
	.RBG	LDA $00				; |
		SEC : SBC $02			; |
	+	STA $06				;/
		LDA $02 : STA $08
		LDA $04 : STA $0A
		LDA #$0000
		BRA .LoadEquation

	.G	LDA $02
		CMP $04 : BCC .B
		LDA $00
		CMP $04 : BCC .GBR
	.GRB	LDA $02				;\
		SEC : SBC $04			; |
		BRA +				; | get D (G greatest)
	.GBR	LDA $02				; |
		SEC : SBC $00			; |
	+	STA $06				;/
		LDA $04 : STA $08
		LDA $00 : STA $0A
		LDA #$0050
		BRA .LoadEquation

	.B	LDA $00
		CMP $02 : BCC .BGR
	.BRG	LDA $04				;\
		SEC : SBC $02			; |
		BRA +				; | get D (B greatest)
	.BGR	LDA $04				; |
		SEC : SBC $00			; |
	+	STA $06				;/
		LDA $00 : STA $08
		LDA $02 : STA $0A
		LDA #$00A0

	.LoadEquation
		STA $0C
		SEP #$20
		STZ $2250
		REP #$20
		LDA $08
		SEC : SBC $0A
		STA $2251
		LDA #$0028 : STA $2253
		BRA $00 : NOP
		LDA $2306 : STA $2251
		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $06 : STA $2253
		NOP
		LDA $0C
		CLC : ADC $2306
		BPL $04 : CLC : ADC #$00F0
		CMP #$00F0
		BCC $03 : SBC #$00F0
		STA $0A				; H get!

	.SortColors
		LDA $00
		CMP $02 : BCC ..NotR
		CMP $04 : BCC ..NotR
		STA !color1			; greatest color = R
		LDA $02
		CMP $04 : BCC ..RBG
	..RGB	STA !color2
		LDA $04 : STA !color3
		BRA .ColorsDone
	..RBG	STA !color3
		LDA $04 : STA !color2
		BRA .ColorsDone

	..NotR	LDA $02
		CMP $04 : BCC ..NotG
		STA !color1
		LDA $00
		CMP $04 : BCC ..GBR
	..GRB	STA !color2
		LDA $04 : STA !color3
		BRA .ColorsDone
	..GBR	STA !color3
		LDA $04 : STA !color2
		BRA .ColorsDone

	..NotG	LDA $04 : STA !color1
		LDA $00
		CMP $02 : BCC ..BGR
	..BRG	STA !color2
		LDA $02 : STA !color3
		BRA .ColorsDone
	..BGR	STA !color3
		LDA $02 : STA !color2

	.ColorsDone
		LDA !color1
		CLC : ADC !color3
	;	LSR A
		STA $0E				; L get!

		SEP #$20
		STZ $2250
		REP #$20
		LDA $06 : STA $2251
		LDA #$003F : STA $2253
		BRA $00 : NOP
		LDA $2306 : STA $2251
		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $0E
		ASL A
		SEC : SBC #$003F
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$003F
		EOR #$FFFF : INC A
		STA $2253
		BRA $00 : NOP
		LDA $2306
		ASL A
		STA $0C				; S get!

		RTS


	HSLtoRGB:
		PHP
		REP #$30
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		TYA
		ASL A
		DEY
		STY !colorloop
		STA !colormix					; save this for CGRAM upload
		STX !colormix+2					; save this for CGRAM upload

; during the process, Y will index the RGB palette and X will index the HSL palette

		STX $00
		TXA
		ASL A
		TAY
		ADC $00
		TAX
		TYA
		AND #$01FF
		TAY


		TSC
		AND #$FF00
		CMP #$3700 : BEQ .SA1_go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTL

	.SA1
		PHP
		REP #$30
		LDX $00
		LDY $02
		..go
		PHB : PHK : PLB

		LDA #$0080 : TSB !ProcessLight			; SA-1 writing to !ShaderInput

		..loop
		CPY #$01FE					;\
		BCC $03 : LDY #$01FE				; | cap overflow
		CPX #$08FD					; |
		BCC $03 : LDX #$08FD				;/

		LDA !PaletteHSL,x				;\
		AND #$00FF					; | H
		STA $0A						;/
		LDA !PaletteHSL+1,x				;\
		AND #$00FF					; | S
		STA $0C						;/
		LDA !PaletteHSL+2,x				;\
		AND #$00FF					; | L
		STA $0E						;/

		JSR .Convert
		PHY
		TYA
		ASL #3
		XBA
		AND #$000F
		TAY
		LDA !LightList-1,y : BPL ++
		LDA #$0100
		CMP !LightR : BNE +
		CMP !LightG : BNE +
		CMP !LightB : BEQ ++
	+	JSR ApplyLight
	++	PLY

		PHX
		TYX
		LDA $04						;\
		ASL #5						; |
		ORA $02						; | assemble RGB
		ASL #5						; |
		ORA $00						; |
		STA !PaletteBuffer,x				;/
		STA !PaletteCacheRGB,x				;/
		STA !ShaderInput,x
		PLX

		INY #2
		INX #3
		DEC !colorloop : BPL ..loop

		LDA #$0080 : TRB !ProcessLight			; SA-1 no longer writing to !ShaderInput


		SEP #$30
		JSL GetCGRAM
		LDA.b #!VRAMbank
		PHA : PLB
		LDA.b #!PaletteHSL>>16 : STA !CGRAMtable+$04,y	; bank (VRAM bank)
		LDA.l !colormix+2 : STA !CGRAMtable+$05,y	; dest CGRAM
		REP #$20
		AND #$00FF
		PHA
		ASL A
		ADC.w #!PaletteBuffer
		STA !CGRAMtable+$02,y				; source address
		LDA.l !colormix : STA !CGRAMtable+$00,y		; upload size
		PLA
		LSR #4
		TAX
		LDA.l !colormix
		LSR #5
		STA $00
		SEP #$20
		LDA #$01
	-	STA.w !ShaderRowDisable,x
		INX
		DEC $00 : BPL -

		..return
		PLB
		PLP
		RTL



; this code will convert HSL to RGB
	.Convert
		SEP #$20
		STZ $2250
		REP #$20
		LDA $0E
		ASL A
		SEC : SBC #$003F
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$003F
		EOR #$FFFF : INC A
		STA $2251
		LDA $0C : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #7
		STA !color1			; strongest color

; formula here is:
; (63 - pos(2L - 63)) x S / 128



		; get H / 20, but fractions
		; so 256 x H / 20

		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $0A
		XBA
		LSR A
		STA $2251
		LDA #$0028 : STA $2253
		BRA $00 : NOP
		LDA $2306
		ASL A
		AND #$01FF
		SEC : SBC #$0100
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$0100
		EOR #$FFFF : INC A
		STA $2251
		SEP #$20
		STZ $2250
		REP #$20
		LDA !color1 : STA $2253
		BRA $00 : NOP
		LDA $2307 : STA !color2		; middle color

; factor:
; 1 - pos((H / 40) mod2 - 1)
;
; 256 - pos((H / 40) mod 512 - 256)
		LDA $0E
	;	ASL A
		SEC : SBC !color1
		LSR A
		STA !color3			; weakest color
		CLC : ADC !color1		;\ complete strongest color
		STA !color1			;/
		LDA !color3			;\
		CLC : ADC !color2		; | complete middle color
		STA !color2			;/

		LDA $0A
		CMP #$0028 : BCC .RGB
		CMP #$0050 : BCC .GRB
		CMP #$0078 : BCC .GBR
		CMP #$00A0 : BCC .BGR
		CMP #$00C8 : BCC .BRG

	.RBG	LDA !color1 : STA $00
		LDA !color2 : STA $04
		LDA !color3 : STA $02
		RTS

	.RGB	LDA !color1 : STA $00
		LDA !color2 : STA $02
		LDA !color3 : STA $04
		RTS

	.GRB	LDA !color1 : STA $02
		LDA !color2 : STA $00
		LDA !color3 : STA $04
		RTS

	.GBR	LDA !color1 : STA $02
		LDA !color2 : STA $04
		LDA !color3 : STA $00
		RTS

	.BGR	LDA !color1 : STA $04
		LDA !color2 : STA $02
		LDA !color3 : STA $00
		RTS

	.BRG	LDA !color1 : STA $04
		LDA !color2 : STA $00
		LDA !color3 : STA $02
		RTS


	MixRGB:
		PHP
		REP #$30
		AND #$00FF
		CMP #$0020
		BCC $03 : LDA #$0020
		STA !colormix
		LDA #$0020
		SEC : SBC !colormix
		STA !colormix+2
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		DEY
		STY !colorloop

; during the process, only X is required for indexing

		TXA
		ASL A
		TAX

		TSC
		AND #$FF00
		CMP #$3700 : BEQ .SA1_go
		STX $00
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTL

	.SA1
		PHP
		REP #$30
		LDX $00
		..go
		PHB : PHK : PLB

		SEP #$20					;\ prepare multiplication
		STZ $2250					;/
		LDA #$80 : TSB !ProcessLight			; SA-1 writing to !ShaderInput
		REP #$20					; A 16-bit

		..loop
		CPX #$01FE					;\ cap overflow
		BCC $03 : LDX #$01FE				;/

		LDA $6703,x					;\
		AND #$001F					; |
		STA $2251					; | B
		LDA !colormix : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306 : STA $00				;/
		LDA $6703,x					;\
		LSR #5						; |
		AND #$001F					; |
		STA $2251					; | G
		LDA !colormix : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306 : STA $02				;/
		LDA $6703,x					;\
		XBA						; |
		LSR #2						; |
		AND #$001F					; | R
		STA $2251					; |
		LDA !colormix : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306 : STA $04				;/

		LDA !PaletteCacheRGB,x				;\
		AND #$001F					; |
		STA $2251					; |
		LDA !colormix+2 : STA $2253			; |
		BRA $00 : NOP					; | mix B
		LDA $2306					; |
		CLC : ADC $00					; |
		LSR #5						; |
		STA $00						;/
		LDA !PaletteCacheRGB,x				;\
		LSR #5						; |
		AND #$001F					; |
		STA $2251					; |
		LDA !colormix+2 : STA $2253			; | mix G
		BRA $00 : NOP					; |
		LDA $2306					; |
		CLC : ADC $02					; |
		LSR #5						; |
		STA $02						;/
		LDA !PaletteCacheRGB,x				;\
		XBA						; |
		LSR #2						; |
		AND #$001F					; |
		STA $2251					; | mix R
		LDA !colormix+2 : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306					; |
		CLC : ADC $04					;/

		AND #$03E0					;\
		ORA $02						; |
		ASL #5						; | assemble and store mixed color
		ORA $00						; |
		STA !PaletteBuffer,x				;/
		STA !ShaderInput,x

		INX #2
		DEC !colorloop : BMI ..return
		JMP ..loop

		..return
		LDA #$0080 : TRB !ProcessLight			; SA-1 no longer writing to !ShaderInput

		PLB
		PLP
		RTL



	.Upload
		PHB : PHK : PLB
		PHP
		REP #$10
		PHX
		PHY
		JSL MixRGB

		REP #$20
		PLA
		ASL A
		STA !colormix
		PLA : STA !colormix+2

		SEP #$30
		JSL GetCGRAM
		LDA.b #!VRAMbank
		PHA : PLB
		LDA.b #!PaletteHSL>>16 : STA !CGRAMtable+$04,y	; bank (VRAM bank)
		LDA.l !colormix+2 : STA !CGRAMtable+$05,y	; dest CGRAM
		REP #$20
		AND #$00FF
		PHA
		ASL A
		ADC.w #!PaletteBuffer
		STA !CGRAMtable+$02,y				; source address
		LDA.l !colormix : STA !CGRAMtable+$00,y		; upload size
		PLA
		LSR #4
		TAX
		LDA.l !colormix
		LSR #5
		STA $00
		SEP #$20
		LDA #$01
	-	STA.w !ShaderRowDisable,x
		INX
		DEC $00 : BPL -

		PLP
		PLB
		RTL


	MixHSL:
		PHP
		REP #$30
		AND #$00FF
		STA !colormix
		LDA #$00FF
		SEC : SBC !colormix
		STA !colormix+2
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		DEY
		STY !colorloop

; during the process, only X is required for indexing

		TXA
		STA $00
		ASL A
		CLC : ADC $00
		TAX

		TSC
		AND #$FF00
		CMP #$3700 : BEQ .SA1_go
		STX $00
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTL

	.SA1
		PHP
		REP #$30
		LDX $00
		..go
		PHB : PHK : PLB
		SEP #$20					;\
		STZ $2250					; | prepare multiplication
		REP #$20					;/

; 00 -> 20	+20 / m
; 00 -> 68	-10 / m
; 70 -> 68	-8 / m
;
;
;
; $00	hue 1
; $02	hue 2
; $08	hue 1 - hue 2
; $0A	hue 2 - hue 1
; $0E	|hue 2 - hue 1|

	.Loop	CPX #$02FD					;\ cap overflow
		BCC $03 : LDX #$02FD				;/
		LDA !PaletteHSL,x
		AND #$00FF
		STA $0A
		LDA !PaletteHSL+$300,x
		AND #$00FF
		SEC : SBC $0A
		STA $0C
		BMI .Calc
		CMP #$0078 : BCC .Calc

	.CClock	LDA #$00F0
		SEC : SBC $0C
		EOR #$FFFF : INC A

	.Calc	STA $2251
		LDA !colormix+2 : STA $2253			; amount to add is based on 32-m
		NOP : BRA $00
		LDA $2306 : BPL +
		EOR #$FFFF : INC A
		XBA : AND #$00FF
		EOR #$FFFF : INC A
		BRA ++
	+	XBA : AND #$00FF
	++	CLC : ADC $0A
		BPL $04 : CLC : ADC #$00F0
	-	CMP #$00F0 : BCC +
		SBC #$00F0 : BRA -
	+	STA $0A


		LDA !PaletteHSL+1,x				;\
		AND #$00FF					; |
		STA $2251					; |
		LDA !colormix : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306 : STA $0C				; |
		LDA !PaletteHSL+$301,x				; |
		AND #$00FF					; | calculate S as m*S1 + (32-m)*S2
		STA $2251					; |
		LDA !colormix+2 : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306					; |
		CLC : ADC $0C					; |
		XBA : AND #$00FF				; |
		STA $0C						;/
		LDA !PaletteHSL+2,x				;\
		AND #$00FF					; |
		STA $2251					; |
		LDA !colormix : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306 : STA $0E				; |
		LDA !PaletteHSL+$302,x				; |
		AND #$00FF					; | calculate L as m*L1 + (32-m)*L2
		STA $2251					; |
		LDA !colormix+2 : STA $2253			; |
		BRA $00 : NOP					; |
		LDA $2306					; |
		CLC : ADC $0E					; |
		XBA : AND #$00FF				; |
		STA $0E						;/

		SEP #$20					;\
		LDA $0A : STA !PaletteHSL+$600,x		; |
		LDA $0C : STA !PaletteHSL+$601,x		; | assemble HSL
		LDA $0E : STA !PaletteHSL+$602,x		; |
		REP #$20					;/

		INX #3
		DEC !colorloop : BMI $03 : JMP .Loop

		PLB
		PLP
		RTL


	.Upload
		PHB : PHK : PLB
		PHP
		PHX
		PHY
		JSL MixHSL
		PLY
		PLX
		REP #$30
		TXA
		AND #$00FF
		ORA #$0200					; HSL mix output buffer
		TAX
		JSL HSLtoRGB
		PLP
		PLB
		RTL



; support routine
; $00: R
; $02: G
; $04: B
	ApplyLight:
		STZ $2250
		LDA !LightR : STA $2251
		LDA $00 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $00
		LDA !LightG : STA $2251
		LDA $02 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $02
		LDA !LightB : STA $2251
		LDA $04 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $04
		RTS



; input:
;	$00 = 16-bit R value
;	$02 = 16-bit G value
;	$04 = 16-bit B value
; output: shifts !LightR/G/B towards input values by 1 step
	FadeLight:
		LDA !LightR
		CMP $00 : BEQ .RDone
		BCC .Rp
	.Rm	DEC #2
	.Rp	INC A
		STA !LightR
	.RDone
		LDA !LightG
		CMP $02 : BEQ .GDone
		BCC .Gp
	.Gm	DEC #2
	.Gp	INC A
		STA !LightG
	.GDone
		LDA !LightB
		CMP $04 : BEQ .BDone
		BCC .Bp
	.Bm	DEC #2
	.Bp	INC A
		STA !LightB
	.BDone
		RTL



;===============;
; PALSET LOADER ;
;===============;
; input: A = palset to load
; output: $0F = index of loaded palset (same as input A)
	LoadPalset:
		PHB : PHK : PLB
		PHX							; push X
		STA $0F							; store palset to load in $0F
		TAX							;\ if palset is already loaded, return
		LDA !Palset_status,x : BNE .Return			;/
		.PortraitColors						;\
		LDA #$FF						; |
		STA $00							; |
		STA $01							; |
		LDA $400000+!MsgPortrait : BEQ ..done			; |
		LDA !MsgPal						; | don't let portrait colors be overwritten
		LSR #4							; |
		AND #$07						; |
		STA $00							; |
		INC A : STA $01						; |
		..done							;/

		LDX !PalsetStart					;\
	-	CPX $00 : BEQ +
		CPX $01 : BEQ +
		LDA !Palset8,x						; |
		CMP #$80 : BEQ +					; |
		AND #$7F						; | if palset is about to be loaded this frame, return
		CMP $0F : BEQ .Return					; | (probably not necessary, just in case there's an error somewhere)
	+	DEX : BPL -						;/
		PLX							; pull X
		LDY !PalsetStart					;\
	.Loop	LDA !Palset8,y						; |
		CMP #$80 : BEQ .Load					; | look for a free row in A-F
	.Next	DEY							; |
		CPY #$02 : BCS .Loop					;/
		PLB
		RTL							; if none are found, return

	.Load	LDA $0F : STA $00					;\
		STZ $01							; | set palset to load here
		ORA #$80						; |
		STA !Palset8,y						;/
		PHX							;\
		XBA : LDA #$00						;\ clear B
		XBA							;/
		AND #$7F						; |
		TAX							; | mark palset as loaded
		TYA : STA !Palset_status,x				; |
		LDA $0F : PHA						; |
		TYX							;\ disable this for 1 operation
		LDA #$01 : STA !ShaderRowDisable+8,x			;/
		JSL UpdatePalset					; > update
		PLA : STA $0F						; |
	.Return	PLX							;/
		PLB
		RTL							; return


	UpdatePalset:
		REP #$30
		STY $08								;\
		JSL GetCGRAM							; | get CGRAM table index
		TYX								;/

		LDY $08								;\
		LDA $00								; |
		XBA								; | address for palset
		LSR #3								; |
		CLC : ADC.w #!PalsetData+2-$20					;/
		STA $00								; also copy palette to RAM mirror
		LDA.w #!PalsetData>>16 : STA $02				;\
		PHX								; |
		PHY								; |
		TYA								; |
		ORA #$0008							; | set up pointer or whatever
		ASL #4								; | (ORA #$0008 is for targeting palettes 8-F)
		INC A								; |
		ASL A								; |
		TAX								; |
		STA $04								;/
		LDA #$0080 : TSB !ProcessLight					; SA-1 currently writing to !PaletteRGB
		LDY #$0000							; index
		LDA #$0100							;\
		CMP !LightR : BNE .PreShade					; | see if preshading is required
		CMP !LightG : BNE .PreShade					; |
		CMP !LightB : BNE .PreShade					;/

	.Raw
		..loop
		LDA [$00],y
		STA !PaletteRGB,x						;\
		STA !ShaderInput,x						; |
		INX #2								; | update palette in RAM
		INY #2								; |
		CPY #$001E : BCC ..loop						;/ > loop
		LDA #$0080 : TRB !ProcessLight					; SA-1 no longer writing to !PaletteRGB
		PLY								;\
		PLX								; | source address
		LDA $04								; |
		CLC : ADC.w #!PaletteRGB					;/
		STA !VRAMbase+!CGRAMtable+$02,x					; store source address
		LDA #$001E : STA !VRAMbase+!CGRAMtable+$00,x			; upload size
		SEP #$30							; A 8-bit
		LDA.b #!PaletteRGB>>16 : STA !VRAMbase+!CGRAMtable+$04,x	; source bank
		TYA								;\
		ORA #$08							; |
		ASL #4								; | dest CGRAM
		INC A								; |
		STA !VRAMbase+!CGRAMtable+$05,x					;/
		RTL								; return

	.PreShade
		PEI ($04)							; preserve
		STZ $2250							; multiplication
		LDA !LightR : STA $04						;\
		LDA !LightG : STA $06						; | DP speedup
		LDA !LightB : STA $08						;/
		..loop
		LDA [$00],y : STA $0E						; > get source color
		STA !ShaderInput,x						; > shader input
		AND #$001F							;\
		STA $2251							; |
		LDA $04 : STA $2253						; |
		NOP : BRA $00							; | shade R
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						; |
		STA $0A								;/
		LDA $0E								;\
		LSR #5								; |
		STA $0E								; |
		AND #$001F							; |
		STA $2251							; |
		LDA $06 : STA $2253						; | shade G
		NOP : BRA $00							; |
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						; |
		STA $0C								;/
		LDA $0E								;\
		LSR #5								; |
		AND #$001F							; |
		STA $2251							; |
		LDA $08 : STA $2253						; | shade B
		NOP : BRA $00							; |
		LDA $2307							; |
		CMP #$0020							; |
		BCC $03 : LDA #$001F						;/
		ASL #5								;\
		ORA $0C								; |
		ASL #5								; |
		ORA $0A								; | assemble color and write to palette
		STA !PaletteRGB,x						; |
		STA !PaletteBuffer,x						; |
		INX #2								; |
		INY #2								;/
		CPY #$001E : BCS ..return					;\ loop
		JMP ..loop							;/

		..return
		LDA #$0080 : TRB !ProcessLight					; SA-1 no longer writing to !PaletteRGB
		PLA								;\ > pull from $04
		PLY								; | source address
		PLX								; |
		CLC : ADC.w #!PaletteBuffer					;/
		STA !VRAMbase+!CGRAMtable+$02,x					; store source address
		LDA #$001E : STA !VRAMbase+!CGRAMtable+$00,x			; upload size
		SEP #$30							; A 8-bit
		LDA.b #!PaletteBuffer>>16 : STA !VRAMbase+!CGRAMtable+$04,x	; source bank
		TYA								;\
		ORA #$08							; |
		ASL #4								; | dest CGRAM
		INC A								; |
		STA !VRAMbase+!CGRAMtable+$05,x					;/
		RTL								; return





