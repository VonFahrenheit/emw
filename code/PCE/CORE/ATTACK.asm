ATTACK:

	.Setup
		REP #$20			;\
		LDA #$32E0 : STA $0E		; |
		LDA !CurrentPlayer		; | $0E = interaction pointer
		AND #$00FF : BEQ +		; |
		LDA #$35F0 : STA $0E		; |
	+	SEP #$20			;/
		RTS


<<<<<<< Updated upstream
	.Main
		TXY
		LDA #$10 : STA ($0E),y		; prevent interaction
		LDA CORE_BITS,x			;\
		CPX #$08			; |
		BCS +				; | mark sprite as hit
		TSB !P2IndexMem1		; |
		BRA ++				; |
	+	TSB !P2IndexMem2		;/
	++	RTS
=======

; input: A = 16-bit pointer to hitbox data
	.LoadHitbox
		STA $00						; pointer

		..Hitbox1
		LDY.b #!P2HitboxYOffset				;\
		LDA ($00),y					; | hitbox 1 Y
		CLC : ADC !P2YPos				; |
		STA !P2Hitbox1Y					;/
		LDY.b #!P2HitboxWOffset				;\
		LDA ($00),y : STA !P2Hitbox1W			; | hitbox 1 W + H
		AND #$00FF					; |
		STA $02						;/
		LDY.b #!P2HitboxXOffset				;\
		LDA ($00),y					; |
		LDX !P2Direction : BNE +			; |
		EOR #$FFFF					; | hitbox 1 X
		CLC : ADC #$0010				; |
		SEC : SBC $02					; |
	+	CLC : ADC !P2XPos				; |
		STA !P2Hitbox1X					;/
		LDY.b #!P2HitboxXSpeedOffset			;\
		LDA ($00),y					; |
		CPX #$00 : BNE +				; | hitbox 1 output speed
		EOR #$00FF					; |
	+	STA !P2Hitbox1XSpeed				;/
		LDY.b #!P2HitboxDisOffset			;\ hitbox 1 interaction disable timer + hitstun
		LDA ($00),y : STA !P2Hitbox1DisTimer		;/
		LDY.b #!P2HitboxSFX1Offset			;\ hitbox 1 SFX 1 + SFX 2
		LDA ($00),y : STA !P2Hitbox1SFX1		;/

		LDY.b #!P2Hitbox2Offset-3			;\ > 2 index mem bytes are not pre-loaded
		LDA ($00),y					; | check for second hitbox
		AND #$00FF : BNE ..Hitbox2			;/
		STA !P2Hitbox2W					; clear hitbox 2
		SEP #$20					;\ return
		RTL						;/

		..Hitbox2
		LDY.b #!P2Hitbox2Offset+!P2HitboxYOffset-3	;\
		LDA ($00),y					; | hitbox 2 Y
		CLC : ADC !P2YPos				; |
		STA !P2Hitbox2Y					;/
		LDY.b #!P2Hitbox2Offset+!P2HitboxWOffset-3	;\
		LDA ($00),y : STA !P2Hitbox2W			; | hitbox 2 W + H
		AND #$00FF					; |
		STA $02						;/
		LDY.b #!P2Hitbox2Offset+!P2HitboxXOffset-3	;\
		LDA ($00),y					; |
		LDX !P2Direction : BNE +			; |
		EOR #$FFFF					; | hitbox 2 X
		CLC : ADC #$0010				; |
		SEC : SBC $02					; |
	+	CLC : ADC !P2XPos				; |
		STA !P2Hitbox2X					;/
		LDY.b #!P2Hitbox2Offset+!P2HitboxXSpeedOffset-3	;\
		LDA ($00),y					; |
		CPX #$00 : BNE +				; | hitbox 2 output speed
		EOR #$00FF					; |
	+	STA !P2Hitbox2XSpeed				;/
		LDY.b #!P2Hitbox2Offset+!P2HitboxDisOffset-3	;\ hitbox 2 interaction disable timer + hitstun
		LDA ($00),y : STA !P2Hitbox2DisTimer		;/
		LDY.b #!P2Hitbox2Offset+!P2HitboxSFX1Offset-3	;\ hitbox 2 SFX 1 + 2
		LDA ($00),y : STA !P2Hitbox2SFX1		;/

	.Return	SEP #$20					; A 8-bit
		RTL						; return


	.ActivateHitbox1					;\
		REP #$20					; |
		LDA !P2Hitbox1X : STA $E0			; |
		LDA !P2Hitbox1Y : STA $E2			; |
		LDA !P2Hitbox1W					; | prepare hitbox 1 for contact check
		AND #$00FF : STA $E4				; |
		LDA !P2Hitbox1H					; |
		AND #$00FF : STA $E6				; |
		SEP #$20					;/
		STZ !P2ActiveHitbox				; > index = hitbox 1
		BRA .CheckShield

	.ActivateHitbox2					;\
		REP #$20					; |
		LDA !P2Hitbox2X : STA $E0			; |
		LDA !P2Hitbox2Y : STA $E2			; |
		LDA !P2Hitbox2W					; | prepare hitbox 1 for contact check
		AND #$00FF : STA $E4				; |
		LDA !P2Hitbox2H					; |
		AND #$00FF : STA $E6				; |
		SEP #$20					;/
		LDA.b #!P2Hitbox2Offset : STA !P2ActiveHitbox	; > index = hitbox 2

	.CheckShield
		LDY !P2ActiveHitbox				;\ reset shield contact
		LDA #$00 : STA !P2Hitbox1Shield,y		;/
		LDA !ShieldExists : BEQ ..return		; return if no shields exist
		LDX #$5A					; loop index
		REP #$20					; A 16-bit

		..loop
		LDA !ShieldW,x : BEQ ..next			;\ > this checks both W and H
		AND #$00FF : STA $EC				; |
		LDA !ShieldH,x					; |
		AND #$00FF : STA $EE				; |
		LDA !ShieldX,x : STA $E8			; | check for shield contact
		LDA !ShieldY,x : STA $EA			; |
		SEP #$20					; |
		JSL CheckContact				; |
		REP #$20					; |
		BCC ..next					;/

		SEP #$20					;\
		LDY !P2ActiveHitbox				; | mark shield contact and return
		LDA #$01 : STA !P2Hitbox1Shield,y		; |
		RTL						;/

		..next						;\
		TXA						; |
		SEC : SBC #$0006				; | loop
		TAX						; |
		BCS ..loop					;/
		SEP #$20					; A 8-bit

		..return
		RTL						; return














>>>>>>> Stashed changes
