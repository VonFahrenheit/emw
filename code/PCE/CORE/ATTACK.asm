

ATTACK:

	.Setup
		LDA !CurrentPlayer				;\
		REP #$20					; | check p1/p2
		BNE .P2						;/
	.P1	LDA.w #!SpriteDisP1 : STA $0E			;\
		SEP #$20					; | P1 pointer
		RTL						;/
	.P2	LDA.w #!SpriteDisP2 : STA $0E			;\
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
		LDY !P2ActiveHitbox				;\
		LDA !P2Hitbox1DisTimer,y			; | prevent interaction
		TXY						; |
		STA ($0E),y					;/
	..mem	LDY !P2ActiveHitbox				;\
		LDA.l CORE_BITS,x				; |
		CPX #$08					; |
		BCC $01 : INY					; | mark contact
		ORA !P2Hitbox1IndexMem1,y			; |
		STA !P2Hitbox1IndexMem1,y			; |
		RTL						;/


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
		LDA !P2Hitbox1Y					; |
		STA $01						; |
		STA $08						; |
		LDA !P2Hitbox1W : STA $02			; | prepare hitbox 1 for contact check
		LDA !P2Hitbox1X					; |
		SEP #$20					; |
		STA $00						; |
		XBA : STA $08					; |
		STZ !P2ActiveHitbox				; > index = hitbox 1
		BRA .CheckShield

	.ActivateHitbox2					;\
		REP #$20					; |
		LDA !P2Hitbox2Y					; |
		STA $01						; |
		STA $08						; |
		LDA !P2Hitbox2W : STA $02			; | prepare hitbox 2 for contact check
		LDA !P2Hitbox2X					; |
		SEP #$20					; |
		STA $00						; |
		XBA : STA $08					; |
		LDA.b #!P2Hitbox2Offset : STA !P2ActiveHitbox	; > index = hitbox 2

	.CheckShield
		LDA !ShieldExists : BEQ ..return		; return if no shields exist
		LDX #$5A					; loop index
		REP #$20					; A 16-bit
	..loop	LDA !ShieldW,x : BEQ ..next			;\
		STA $06						; |
		LDA !ShieldY,x : STA $0A			; |
		XBA : STA $04					; |
		LDA !ShieldX,x					; |
		SEP #$20					; | check for shield contact
		STA $04						; |
		XBA : STA $0A					; |
		JSL !CheckContact				; |
		REP #$20					; |
		BCC ..next					;/

		SEP #$20					;\
		LDY !P2ActiveHitbox				; | mark shield contact and return
		LDA #$01 : STA !P2Hitbox1Shield,y		; |
		RTL						;/

	..next	TXA						;\
		SEC : SBC #$0006				; | loop
		TAX						; |
		BCS ..loop					;/
		SEP #$20					; A 8-bit

		..return
		RTL						; return














