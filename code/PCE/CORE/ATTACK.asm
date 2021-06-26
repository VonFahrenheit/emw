ATTACK:

	.Setup
		LDA !CurrentPlayer				;\
		REP #$20					; | check p1/p2
		BNE .P2						;/
	.P1	LDA #$32E0 : STA $0E				;\
		SEP #$20					; | P1 pointer
		RTL						;/
	.P2	LDA #$35F0 : STA $0E				;\
		SEP #$20					; | P2 pointer
		RTL						;/

	.Combo
		JSL .Setup					; get pointer to "don't interact" flag
		LDA !P2Hitbox1IndexMem1				;\
		ORA !P2Hitbox2IndexMem1				; |
		STA $00						; |
		LDY #$00					; |
		LDA #$00					; |
	-	LSR $00 : BCC +					; |
		STA ($0E),y					; |
	+	INY						; |
		CPY #$08 : BNE -				; | clear "don't interact" timers for sprites marked in index mem
		LDA !P2Hitbox1IndexMem2				; |
		ORA !P2Hitbox2IndexMem2				; |
		STA $00						; |
		LDA #$00					; |
	-	LSR $00 : BCC +					; |
		STA ($0E),y					; |
	+	INY						; |
		CPY #$10 : BNE -				;/
		STZ !P2Hitbox1IndexMem1				;\
		STZ !P2Hitbox1IndexMem2				; | clear index mem for combo
		STZ !P2Hitbox2IndexMem1				; |
		STZ !P2Hitbox2IndexMem2				;/
		RTL



	.Main
		TXY
		LDA #$10 : STA ($0E),y				; prevent interaction
	..mem	LDY !P2ActiveHitbox				;\
		LDA.l CORE_BITS,x				; |
		CPX #$08					; |
		BCC $01 : INY					; | mark contact
		ORA !P2Hitbox1IndexMem1,y			; |
		STA !P2Hitbox1IndexMem1,y			; |
		RTL						;/


	.LoadHitbox
		STA $00						; pointer

		..Hitbox1
		LDY #$02					;\
		LDA ($00),y					; | hitbox 1 Y
		CLC : ADC !P2YPos				; |
		STA !P2Hitbox1Y					;/
		LDY #$04					;\
		LDA ($00),y : STA !P2Hitbox1W			; | hitbox 1 W + H
		AND #$00FF					; |
		STA $02						;/
		LDY #$00					;\
		LDA ($00),y					; |
		LDX !P2Direction : BNE +			; |
		EOR #$FFFF					; | hitbox 1 X
		CLC : ADC #$0010				; |
		SEC : SBC $02					; |
	+	CLC : ADC !P2XPos				; |
		STA !P2Hitbox1X					;/
		LDY #$06					;\
		LDA ($00),y					; |
		CPX #$00 : BNE +				; | hitbox 1 output speed
		EOR #$00FF					; |
	+	STA !P2Hitbox1XSpeed				;/

		LDY #$08					;\
		LDA ($00),y					; | check for second hitbox
		AND #$00FF : BNE ..Hitbox2			;/
		STA !P2Hitbox2W					; clear hitbox 2
		SEP #$20					;\ return
		RTL						;/

		..Hitbox2
		LDY #$0A					;\
		LDA ($00),y					; | hitbox 2 Y
		CLC : ADC !P2YPos				; |
		STA !P2Hitbox2Y					;/
		LDY #$0C					;\
		LDA ($00),y : STA !P2Hitbox2W			; | hitbox 2 W + H
		AND #$00FF					; |
		STA $02						;/
		LDY #$08					;\
		LDA ($00),y					; |
		LDX !P2Direction : BNE +			; |
		EOR #$FFFF					; | hitbox 2 X
		CLC : ADC #$0010				; |
		SEC : SBC $02					; |
	+	CLC : ADC !P2XPos				; |
		STA !P2Hitbox2X					;/
		LDY #$0E					;\
		LDA ($00),y					; |
		CPX #$00 : BNE +				; | hitbox 2 output speed
		EOR #$00FF					; |
	+	STA !P2Hitbox2XSpeed				;/

	.Return	SEP #$20					; A 8-bit
		RTL						; return


	.ActivateHitbox1					;\
		REP #$20					; |
		LDA !P2Hitbox1XSpeed : STA !P2HitboxOutputX	; |
		LDA !P2Hitbox1Y					; |
		STA $01						; |
		STA $08						; |
		LDA !P2Hitbox1W : STA $02			; | prepare hitbox 1 for contact check
		LDA !P2Hitbox1X					; |
		SEP #$20					; |
		STA $00						; |
		XBA : STA $08					; |
		STZ !P2ActiveHitbox				; |
		RTL						;/

	.ActivateHitbox2					;\
		REP #$20					; |
		LDA !P2Hitbox2XSpeed : STA !P2HitboxOutputX	; |
		LDA !P2Hitbox2Y					; |
		STA $01						; |
		STA $08						; |
		LDA !P2Hitbox2W : STA $02			; | prepare hitbox 2 for contact check
		LDA !P2Hitbox2X					; |
		SEP #$20					; |
		STA $00						; |
		XBA : STA $08					; |
		LDA #$0A : STA !P2ActiveHitbox			; |
		RTL						;/

