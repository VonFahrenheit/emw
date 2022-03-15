

; negative: &$7F = displayed health value
; positive: timer
; 0x00 = 


; ssvvvvvv
;	ss = state
;		00 = not showing, but tracking current hearts
;		01 = showing, counting towards current hearts
;		02 = showing, locked and counting up to 0 (negative countdown), lower s bit can be used as part of v
;	vvvvvv = value (timer or HP value)


SHOW_HEARTS:

		.HandleTimer
		LDA !P2Entrance				;\ wait for entrance
		CMP #$20 : BCS ..return			;/
		LDA !P2HP				;\
		CLC : ADC !P2TempHP			; | full heart value
		STA $00					;/
		BIT !P2ShowHP				;\
		BMI ..lockcountdown			; | check state
		BVS ..moving				;/
		..tracking				;\
		CMP !P2ShowHP : BEQ ..return		; |
		LDA #$40 : TSB !P2ShowHP		; | track changes in HP
		..return				; |
		RTL					;/
		..moving				;\
		LDA $14					; |
		AND #$03 : BNE ..done			; |
		LDA !P2ShowHP				; |
		AND #$3F				; |
		CMP $00					; |
		BEQ ..lock				; |
		BCC ..inc				; | update moving heart counter
		..dec					; |
		DEC A : BRA ..updatemove		; |
		..inc					; |
		INC A					; |
		..updatemove				; |
		ORA #$40 : STA !P2ShowHP		; |
		BRA ..done				;/
		..lock					;\
		LDA $00 : BNE +				; |
		LDA #$C4 : BRA ++			; | lock lingering counter
	+	LDA #$88				; | (normally 2 seconds, but 1 second upon death)
	++	STA !P2ShowHP				; |
		BRA ..done				;/
		..lockcountdown				;\
		INC !P2ShowHP : BNE ..done		; |
		STA !P2ShowHP				; | timer for locked counter
		RTL					; |
		..done					;/


		.Setup
		PHB : PHK : PLB
		REP #$30				;\
		LDA !P2MaxHP				; |
		AND #$00FF				; |
		EOR #$FFFF : INC A			; | on-screen X coord
		CLC : ADC !P2XPosLo			; |
		SEC : SBC $1A				; |
		CLC : ADC #$0008			; |
		STA $00					;/
		LDA !P2YPosLo				;\
		SEC : SBC $1C				; | on-screen Y
		SEC : SBC #$0018			; |
		CMP #$00E0 : BCC +			; |
		CMP #$FFF8 : BCS +			; |
		SEP #$30
		PLB
		RTL

	+	STA $02					;/
		LDA !OAMindex_p3 : TAX			;\
		BIT !P2ShowHP-1 : BMI +			; |
		LDA !P2ShowHP : BRA ++			; |
	+	LDA !P2HP				; | get HP values
		CLC : ADC !P2TempHP			; |
	++	AND #$003F : STA $0C			; |
		LDA !P2MaxHP				; |
		AND #$00FF : STA $0E			;/


		.Loop
		LDA $0C : BNE ..fillin			;\
		LDA #$3066 : BRA ..draw			; |
		..fillin				; |
		CMP #$0004 : BCC ..fraction		; |
		LDA #$3077 : BRA ..draw			; |
		..fraction				; |
		TAY					; | get tile num
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
		TXA : STA !OAMindex_p3			; update OAM index
		SEP #$30				;
		PLB					;
		RTL					; return

		.Tiles
		db $66,$67,$75,$76










