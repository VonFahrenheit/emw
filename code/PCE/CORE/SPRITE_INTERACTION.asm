

SPRITE_INTERACTION:
		STZ !P2TouchingItem			; clear this flag
		LDA !P2Climbing : BEQ .Process
		RTL

		.Process
		REP #$20				;\
		LDA !P2HurtboxX : STA $E0		; |
		LDA !P2HurtboxY : STA $E2		; |
		LDA !P2HurtboxW				; | read player hurtbox
		AND #$00FF : STA $E4			; |
		LDA !P2HurtboxH				; |
		AND #$00FF : STA $E6			; |
		SEP #$20				;/
		LDX #$0F				; > loop over all sprites

		.Loop
		STZ $0F					;
		LDA !SpriteStatus,x			;
		CMP #$09 : BEQ ..interact		;
		CMP #$0A : BNE ..next			;
		..interact
		LDA !CurrentPlayer : BNE +		;\
		LDA !SpriteDisP1,x : BNE ..next		; | loop if sprite has player interaction disabled
		BRA ++					; |
	+	LDA !SpriteDisP2,x : BNE ..next		;/
	++	CPX #$08 : BCS ..8F			;\
	..07	LDA !P2Hitbox1IndexMem1			; |
		ORA !P2Hitbox2IndexMem1			; |
		BRA ..readbits				; | check index memory
	..8F	LDA !P2Hitbox1IndexMem2			; |
		ORA !P2Hitbox2IndexMem2			; |
		..readbits				; |
		AND.l BITS,x : BNE ..next		;/
		JSL GetSpriteClippingE8			;\
		REP #$20				; |
		DEC $EA					; |
		DEC $EA					; | check contact
		INC $EE					; |
		INC $EE					; |
		SEP #$20				; |
		JSL CheckContact : BCC ..next		;/

		LDA !P2Carry : BNE .Return		; have to check for each sprite to avoid a bug where 2 items are touched on the same frame
		INC !P2TouchingItem			; this flag prevents attacks
		LDA !SpriteStatus,x			;\
		CMP #$0A : BNE ..canbecarried		; |
		LDA !SpriteTweaker3,x			; | is status = A (kicked) and kicked carry is disabled, sprite can't be picked up
		AND #$10 : BNE ..next			; |
		..canbecarried				;/
		LDA !SpriteBlocked,x
		AND #$04 : BNE +
		REP #$20
		LDA $EA
		CMP $E2
		SEP #$20
		BCS +
		BIT $15 : BVS ..carry
	+	BIT $16 : BVC ..next
		..carry
		TXA
		INC A : STA !P2Carry
		LDA #$08 : STA !P2PickUp
		LDA #$0B : STA !SpriteStatus,x		; sprite status = carried ($0B)
		..next
		DEX : BMI .Return
		JMP .Loop

		.Return
		RTL					; > return

