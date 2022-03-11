

SHOW_HEARTS:
		REP #$30				;\
		LDA !P2MaxHP				; |
		AND #$00FF				; |
		EOR #$FFFF : INC A			; |
		CLC : ADC !P2XPosLo			; |
		SEC : SBC $1A				; | on-screen coords
		CLC : ADC #$0008			; |
		STA $00					; |
		LDA !P2YPosLo				; |
		SEC : SBC $1C				; |
		SEC : SBC #$0018			; |
		STA $02					;/
		LDA !OAMindex_p3 : TAX			;\
		LDA !P2HP				; |
		CLC : ADC !P2TempHP			; | get HP values
		AND #$00FF : STA $0C			; |
		LDA !P2MaxHP				; |
		AND #$00FF : STA $0E			;/

		.Loop
		LDA $0C : BNE ..fillin			;\
		LDA #$3066 : BRA ..draw			; |
		..fillin				; |
		CMP #$0004 : BCC ..fraction		; |
		LDA #$3077 : BRA ..draw			; |
		..fraction				; | get tile num
		TAY					; |
		LDA .Tiles,y				; |
		AND #$00FF				; |
		ORA #$3000				; |
		..draw					; |
		STA !OAM_p3+$002,x			;/
		LDA $00 : STA !OAM_p3+$000,x		;\
		CLC : ADC #$0008			; |
		STA $00					; | coords
		SEP #$20				; | (also update X)
		LDA $02 : STA !OAM_p3+$001,x		; |
		REP #$20				;/
		TXA					;\
		LSR #2 : TAX				; | hi byte
		LDA $01					; |
		AND #$0001 : STA !OAMhi_p3,x		;/
		INX					;\
		TXA					; |
		ASL #2 : TAX				; |
		LDA $0C					; |
		SEC : SBC #$0004			; |
		BPL $03 : LDA #$0000			; | loop
		STA $0C					; |
		LDA $0E					; |
		SEC : SBC #$0004			; |
		STA $0E					; |
		BEQ .End				; |
		BPL .Loop				;/

		.End
		TXA : STA !OAMindex_p3			;\ update OAM index
		SEP #$30				;/
		RTL					; return

		.Tiles
		db $66,$67,$75,$76










