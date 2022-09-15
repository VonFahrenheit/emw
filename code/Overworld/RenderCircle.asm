

; variables:
;	cx	center x
;	cy	center y
;	r	radius

; lines above circle:
;	cy - r (neg -> 0)
;
; lines below circle:
;	0xE0 - cy - r (neg -> 0)


; scratch
; $00	cx
; $02	current y within circle (starts at -r)
; $04	r^2 lo word
; $06	sqrt(r^2 - y^2)
; $08	(0xFF - cx)^2
; $0A	r^2 hi word
; $0C	cutoff for index (lowest)
; $0E	cutoff for index (highest)




; problems for morning eric:
;	- the "skip middle" case works only if the renderer goes from non-0xFF00 -> 0xFF00, if it starts at 0xFF00 it can't know how far forward to jump
;	- is this related to the errors with the really big circle centered on the middle of the screen even tho it works around camera borders?
;	- i need a better way of detecting whether a line is valid or not


	RenderCircle:
		PHB : PHK : PLB
		PHP
		REP #$30

		; calculate radius^1.5
		.InitCalc
		LDA !CircleForceCenter
		STZ !CircleForceCenter
		BEQ ..calccenter
		LDA #$0080 : STA !CircleCenterX
		LDA #$0078 : STA !CircleCenterY
		BRA ..process
		..calccenter
		LDA !P1MapX
		CLC : ADC #$0008
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA !CircleCenterX
		LDA !P1MapY
		CLC : ADC #$0008
		SEC : SBC $1C
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA !CircleCenterY
		..process
		LDA !CircleRadius
		BPL $03 : LDA #$0000
		CMP #$0030
		BCC $03 : LDA #$0030
		STA !CircleRadius
		STZ $2250
		STA $2251
		CLC : JSL GetRoot : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !CircleRadiusInternal
		..done

		LDA !CircleTimer
		AND #$0001
		BEQ $03 : LDA.w #(!CircleTable2)-(!CircleTable1)
		STA $0C
		CLC : ADC #$00E0*2
		STA $0E
		LDA !CircleRadiusInternal : BEQ .FillAll
		CMP #$0169 : BCC .Render

		.FullClear
		LDA #$FF00
		..write
		LDX $0C
		..loop
		STA !CircleTable,x
		INX #2
		CPX $0E : BCC ..loop
		PLP
		PLB
		RTL

		.FillAll
		LDA #$00FF : BRA .FullClear_write


		.Render
		LDA !CircleCenterX : STA $00


		.FillTop
		LDX $0C
		LDA !CircleCenterY
		SEC : SBC !CircleRadiusInternal
		BEQ ..done
		BMI ..done
		CMP #$00E0
		BCC $03 : LDA #$00E0
		ASL A
		ADC $0C
		TAX
		LDA #$00FF : BRA +
		..loop
		STA !CircleTable,x
	+	DEX #2 : BMI ..done
		CPX $0C : BCS ..loop
		..done


		.CalculateCircle
		STZ $02					;\
		LDA !CircleCenterY			; |
		SEC : SBC !CircleRadiusInternal		; | X = index to circle part
		BPL $05 : STA $02 : LDA #$0000		; | $02 = offset to starting y
		ASL A					; |
		ADC $0C					; |
		TAX					;/
		STZ $2250				; prepare multiplication
		LDA !CircleRadiusInternal		;\
		STA $2251				; |
		STA $2253				; |
		EOR #$FFFF : INC A			; | calculate 32-bit r^2 and -r (added to starting y offset)
		SEC : SBC $02				; |
		STA $02					; |
		LDA $2306 : STA $04			; |
		LDA $2308 : STA $0A			;/

		..loop					;\
		LDA $02					; | no negative check since this reg uses signed data so -y * -y = +y^2
		STA $2251				; | calculate 32-bit y^2
		STA $2253				;/
		LDA $04					;\
		SEC : SBC $2306				; |
		STA $06					; |
		LDA $0A					; |
		SBC $2308				; |
		CLC					; |
		BEQ $01 : SEC				; |
		LDA $06					; | $06 = 17-bit sqrt(r^2 - y^2)
		JSL GetRoot				; | (17-bit input number, don't mind n flag)
		XBA					; |
		PHP					; |
		AND #$00FF				; |
		BCC $03 : ORA #$0100			; > C bit
		PLP					; |
		BPL $01 : INC A				; |
		STA $06					;/
		LDA $00					;\
		SEC : SBC $06				; |
		BPL $03 : LDA #$0000			; | L = cx - sqrt(r^2 - y^2)
		CMP #$00FF				; |
		BCC $03 : LDA #$00FF			; |
		STA !CircleTable+0,x			;/
		LDA $00					;\
		CLC : ADC $06				; |
		BPL $03 : LDA #$0000			; | R = cx - sqrt(r^2 - y^2)
		CMP #$00FF				; |
		BCC $03 : LDA #$00FF			; |
		STA !CircleTable+1,x			;/
		INX #2					; index+2
		LDA $02					;\ done if entire circle is rendered
		CMP !CircleRadiusInternal : BEQ ..done	;/
		INC $02					; y+1
		CPX $0E : BCC ..loop			;\ otherwise, render until bottom of screen is reached
		..done					;/


		.FillBottom				;\
		LDA #$00FF				; |
		..loop					; | full window for the rest of the screen
		STA !CircleTable,x			; |
		INX #2					; |
		CPX $0E : BCC ..loop			;/

		.Return
		PLP
		PLB
		RTL



		.Cutscene
		REP #$30
		LDA !Cutscene
		AND #$00FF : BEQ ..dec

		..inc
		LDA !CutsceneSmoothness
		CMP #$001F : BEQ ..render
		INC !CutsceneSmoothness
		BRA ..render

		..dec
		LDA !CutsceneSmoothness : BEQ ..return
		DEC !CutsceneSmoothness

		..render
		ASL A
		STA $00
		LDA !CircleTimer
		AND #$0001
		BEQ $03 : LDA #$0200
		CLC : ADC #$3200
		STA $0C
		CLC : ADC #$00DF*2
		SEC : SBC $00
		STA $0E
		LDY $00
		LDA #$00FF
	-	STA ($0C),y
		STA ($0E),y
		DEY #2 : BPL -

		..return
		RTL







