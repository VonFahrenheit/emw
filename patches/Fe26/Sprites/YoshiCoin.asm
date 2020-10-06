YoshiCoin:

	namespace YoshiCoin

; !ExtraProp1:	rb--iiii
;		r - rex: if set, yoshi coin will first activate when the rex it is placed on takes a hit
;		b - block: if set, yoshi coin will replace the mushroom/flower that spawns from the block it is placed on
;		i - yoshi coin ID
; $BE:		which translevel this coin indexes (used for levels with 10 yoshi coins)
; $3280:	which index this coin has (1, 2, 4, 8, or 10)
; $3290:	index of carrier rex
; $32D0:	timer to prevent player interaction, used for drop


	INIT:
		PHB : PHK : PLB
		BIT !ExtraProp1,x : BPL .NoRex		; check rex flag
		JSL !GetSpriteClipping04		; load yoshi coin clipping
		LDY #$0F				;\
	-	LDA $3230,y : BEQ +			; |
		LDA !ExtraBits,y			; | search for a rex
		AND #$08 : BEQ +			; |
		LDA !NewSpriteNum,y			; |
		CMP #$02 : BNE +			;/
		PHY					;\
		PHX					; |
		TYX					; |
		JSL !GetSpriteClipping00		; | check for contact
		PLX					; |
		JSL !CheckContact			; |
		PLY					; |
		BCC +					;/
		TYA : STA $3290,x			;\ store rex number, then go on to check ID
		BRA .NoRex				;/

	+	DEY : BPL -				;\
		STZ $3230,x				; | loop, but despawn if no rex are found
		PLB					; |
		RTL					;/
		.NoRex


		LDA !ExtraProp1,x
		AND #$0F
		CMP #$0A : BCS .GoCoin_2		; ID 10+ is never allowed
		CMP #$05 : BCS .5to9			; branch for 0-4 or 5-9
	.0to4
		TAY					;\ which bit coin has
		LDA .Index,y : STA $3280,x		;/
		PHX					;\
		LDX !Translevel				; | if coin is already collected, become a normal coin
		AND $40400B,x : BNE .GoCoin		;/
		TXA					;\
		PLX					; |
		STA $BE,x				; | otherwise store translevel index and return
		PLB					; |
		RTL					;/

	.5to9
		TAY					;\
		LDA .Index-5,y : STA $3280,x		; | which bit coin has
		STA $00					;/ (store backup in scratch RAM)
		PHX					;\
		LDX !Translevel				; | if this level only has 5 yoshi coins, become a normal coin
		LDA $188000,x : BEQ .GoCoin		;/
		TAX					;\
		LDA $40400B,x				; | if coin is already collected, become a normal coin
		AND $00 : BNE .GoCoin			;/
		TXA					;\
		PLX					; |
		STA $BE,x				; | otherwise store translevel index and return
		PLB					; |
		RTL					;/


	.GoCoin	PLX
	..2	LDA !ExtraProp1,x			;\ rex/block version just despawns instead
		AND #$C0 : BNE .Despawn			;/
		LDA #$21 : STA $3200,x			; become a normal coin if this Yoshi Coin is already taken
		LDA #$08 : STA $3230,x
		LDA !ExtraBits,x
		AND.b #$08^$FF
		STA !ExtraBits,x
		JSL $07F7D2				; | > Reset sprite tables
		PLB
		RTL

	.Despawn
		STZ $3230,x
		PLB
		RTL

		.Index
		db $01,$02,$04,$08,$10


	MAIN:
		PHB : PHK : PLB
		BIT !ExtraProp1,x : BPL .NoRex		; check rex flag
		LDY $3290,x				;\
		LDA $3210,y : STA $3210,x		; |
		LDA $3220,y : STA $3220,x		; |
		LDA $3240,y : STA $3240,x		; |
		LDA $3250,y : STA $3250,x		; | wait for rex to be hit
		LDA #$04 : STA $33C0,y			; |
		LDA $3230,y				; |
		CMP #$08 : BNE .Drop			; |
		LDA.w $BE,y : BNE .Drop			; |
		PLB					; |
		RTL					;/
	.Drop	LDA !ExtraProp1,x			;\
		AND #$0F				; |
		STA !ExtraProp1,x			; |
		LDA #$E0 : STA $9E,x			; | drop
		STZ $AE,x				; |
		LDA #$40 : STA $32D0,x			; |
		.NoRex					;/

		BIT !ExtraProp1,x : BVC .NoBlock	; check block flag
		JSL !GetSpriteClipping04		; load yoshi coin hitbox
		LDY #$0F				;\
	-	LDA $3230,y : BEQ +			; |
		LDA $3200,y				; | look for mushroom/flower
		CMP #$74 : BEQ ++			; |
		CMP #$75 : BNE +			;/
	++	PHY					;\
		PHX					; |
		TYX					; |
		JSL !GetSpriteClipping00		; | check for contact
		PLX					; |
		JSL !CheckContact			; |
		PLY					; |
		BCC +					;/
		LDA #$00 : STA $3230,y			;\
		LDA #$40 : STA $32D0,x			; |
		LDA #$D0 : STA $9E,x			; |
		STZ $AE,x				; | replace powerup sprite
		LDA !ExtraProp1,x			; |
		AND #$0F				; |
		STA !ExtraProp1,x			; |
		BRA .NoBlock				;/
	+	DEY : BPL -				;\
		PLB					; | wait for powerup sprite
		RTL					;/
		.NoBlock


		LDA $3330,x
		AND #$04 : PHA
		LDA $9E,x : PHA
		STZ $AE,x				; no horizontal speed please!
		JSL !SpriteApplySpeed			; apply speed with gravity
		PLA : STA $00
		PLA : BNE .SpeedDone
		EOR $3330,x
		AND #$04 : BEQ .SpeedDone
		LDA $3330,x
		AND #$04 : BEQ .SpeedDone
		LDA $00 : BMI .SpeedDone
		CMP #$08 : BCC .SpeedDone
		LSR A
		EOR #$FF
		STA $9E,x
		.SpeedDone


		LDA $32D0,x : BNE .NoContact		; no player interaction during drop
		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC .NoContact
		PHA
		STZ $3230,x
		JSR Glitter
		LDA #$1C : STA !SPC1
		LDA !YoshiCoinCount
		INC A
		STA !YoshiCoinCount
		LDY $3280,x
		PHX
		LDA $BE,x : TAX
		TYA
		ORA $40400B,x
		STA $40400B,x
		PLX
		PLA
		LSR A : BCC .P2
	.P1	LDA !P1CoinIncrease
		CLC : ADC #$C8
		STA !P1CoinIncrease
		BRA .NoContact
	.P2	LDA !P2CoinIncrease
		CLC : ADC #$C8
		STA !P1CoinIncrease
		.NoContact


		REP #$20
		LDA.w #ANIM : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_Long
		PLB
		RTL



	ANIM:
		dw $0008
		db $70,$00,$F3,$00
		db $70,$00,$03,$02


	Glitter:
		LDY.b #!Ex_Amount-1				; Set up loop

.Loop		LDA !Ex_Num,y					;\
		BEQ .Spawn					; | Find empty smoke sprite slot
		DEY						; |
		BPL .Loop					;/
.Return		RTS

.Spawn		LDA #$05+!SmokeOffset : STA !Ex_Num,y		; Smoke sprite to spawn
		LDA #$10 : STA !Ex_Data1,y			; Show glitter sprite for 16 frames
		LDA $3220,x : STA !Ex_XLo,y			; Spawn at sprite X
		LDA $3210,x					;\
		SEC : SBC #$05					; | Spawn at sprite Y - 5 pixels
		STA !Ex_YLo,y					;/
		RTS


	namespace off





