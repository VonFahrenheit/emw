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
		LDA #$0004 : STA !BigRAM+0	; |
		LDA !GFX_status+$09		; |
		AND #$00FF			; |
		ORA #$0040			; | Graphics
		STA !BigRAM+2			; |
		LDA #$8600 : STA !BigRAM+4	; |
		LDA #!BigRAM : STA $04		; |
		SEP #$20			; |
		JSL LOAD_TILEMAP_Long		;/

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



	namespace off





