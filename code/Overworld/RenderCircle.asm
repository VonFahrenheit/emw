

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




	!CircleTable	= $3200
	!CircleTable1	= !CircleTable+$000
	!CircleTable2	= !CircleTable+$200



	RenderCircle:
		LDA !CircleTimer
		AND #$00001
		BEQ $03 : LDA.w #(!CircleTable2)-(!CircleTable1)
		STA $0C
		CLC : ADC #$00E0*2
		STA $0E
		LDA !CircleRadius : BEQ .FillAll
		CMP #$0169 : BCC .Render

		.FullClear
		LDA #$FF00
		..write
		LDX $0C
		..loop
		STA !CircleTable,x
		INX #2
		CPX $0E : BCC ..loop
		RTS

		.FillAll
		LDA #$00FF : BRA .FullClear_write


		.Render
		LDA !CircleCenterX : STA $00


		.FillTop
		LDX $0C
		LDA !CircleCenterY
		SEC : SBC !CircleRadius
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
		SEC : SBC !CircleRadius			; | X = index to circle part
		BPL $05 : STA $02 : LDA #$0000		; | $02 = offset to starting y
		ASL A					; |
		ADC $0C					; |
		TAX					;/
		STZ $2250				; prepare multiplication
		LDA !CircleRadius			;\
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
		JSL !GetRoot				; | (17-bit input number, don't mind n flag)
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
		CMP !CircleRadius : BEQ ..done		;/
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
		RTS



		.Cutscene
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
		RTS







