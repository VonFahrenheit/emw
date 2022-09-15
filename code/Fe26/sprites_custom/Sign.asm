

Sign:

	namespace Sign

	INIT:
		PHB : PHK : PLB					; > start of bank wrapper
		STZ $3320,x
		PLB						; > end of bank wrapper
		RTL						; > end INIT routine


	MAIN:
		PHB : PHK : PLB

		REP #$20					;\
		LDA.w #.Tilemap : STA $04			; | tilemap
		SEP #$20					; |
		JSL LOAD_PSUEDO_DYNAMIC				;/

		REP #$20
		LDA.w #.Hitbox : JSL LOAD_HITBOX
		JSL PlayerContact : BCC .Return
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
		LDA #$80 : STA !MsgTrigger+1
		PLB
		RTL

	.Tilemap
		dw $0004
		db $72,$00,$FF,$00

	.Hitbox
		dw $FFF8,$FFF8 : db $20,$20


	namespace off





