Sign:

	namespace Sign

	INIT:
		PHB : PHK : PLB			; > Start of bank wrapper
		STZ $3320,x
		PLB				; > End of bank wrapper
		RTL				; > End INIT routine


	MAIN:
		PHB : PHK : PLB

		REP #$20			;\
		LDA.w #.Tilemap : STA $04	; | tilemap
		SEP #$20			; |
		JSL LOAD_PSUEDO_DYNAMIC		;/

		LDA $3220,x
		SEC : SBC #$08
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$08
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$20
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .Return
		LSR A : BCC +
		PHA
		LDA !P2Blocked-$80
		AND #$04 : BEQ ++
		LDA $6DA6
		AND #$08 : BEQ ++
		BRA .Talk
	++	PLA
	+	LSR A : BCC .Return
		LDA !P2Blocked
		AND #$04 : BEQ .Return
		LDA $6DA7
		AND #$08 : BNE .Talk2

		.Return
		PLB
		RTL

	.Talk	PLA
	.Talk2	LDA !ExtraBits,x
		AND #$04
		LSR #2
		INC A
		STA !MsgTrigger
		PLB
		RTL

	.Tilemap
		dw $0004
		db $72,$00,$FF,$00


	namespace off





