


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
		LDA !ExtraProp1,x
		AND #$0F
		CMP #$0A : BCS .GoCoin_2			; ID 10+ is never allowed
		CMP #$05 : BCS .5to9				; branch for 0-4 or 5-9
	.0to4
		TAY						;\ which bit coin has
		LDA .Index,y : STA $3280,x			;/
		PHX						;\
		LDX !Translevel					; | if coin is already collected, become a normal coin
		AND !LevelTable1,x : BNE .GoCoin		;/
		TXA						;\
		PLX						; |
		STA $BE,x					; | otherwise store translevel index and return
		PLB						; |
		RTL						;/

	.5to9
		TAY						;\
		LDA .Index-5,y : STA $3280,x			; | which bit coin has
		STA $00						;/ (store backup in scratch RAM)
		PHX						;\
		LDX !Translevel					; | if this level only has 5 yoshi coins, become a normal coin
		LDA $188000,x : BEQ .GoCoin			;/
		TAX						;\
		LDA !LevelTable1,x				; | if coin is already collected, become a normal coin
		AND $00 : BNE .GoCoin				;/
		TXA						;\
		PLX						; |
		STA $BE,x					; | otherwise store translevel index and return
		PLB						; |
		RTL						;/


	.GoCoin	PLX
	..2	LDA !ExtraProp1,x				;\ rex/block version just despawns instead
		AND #$C0 : BNE .Despawn				;/
		LDA #$21 : STA $3200,x				; become a normal coin if this Yoshi Coin is already taken
		LDA #$08 : STA $3230,x
		STZ !ExtraBits,x
		LDA $33F0,x : PHA
		JSL !ResetSprite				; | > Reset sprite tables
		PLA : STA $33F0,x
		PLB
		RTL

	.Despawn
		STZ $3230,x
		PLB
		RTL

		.Index
		db $01,$02,$04,$08,$10


	MAIN:
		JSL INIT					; make sure despawn conditions are checked every frame
		PHB : PHK : PLB
		BIT !ExtraProp1,x : BPL .NoRex			; check rex flag
		LDY $3290,x					;\
		LDA !NewSpriteNum,y
		CMP #$02 : BNE .Drop
		LDA $3210,y : STA $3210,x			; |
		LDA $3220,y : STA $3220,x			; |
		LDA $3240,y : STA $3240,x			; |
		LDA $3250,y : STA $3250,x			; | wait for rex to be hit
	;	LDA #$04 : STA $33C0,y				; |
		LDA $3230,y					; |
		CMP #$08 : BNE .Drop				; |
		LDA.w $BE,y : BEQ .Return			; |
		LDA !SpriteXLo,y : STA !SpriteXLo,x
		LDA !SpriteXHi,y : STA !SpriteXHi,x
		LDA !SpriteYLo,y
		SEC : SBC #$10
		STA !SpriteYLo,x
		LDA !SpriteYHi,y
		SBC #$00
		STA !SpriteYHi,x
		JMP .NoContact

		.Return
		PLB						; |
		RTL						;/
	.Drop	LDA !ExtraProp1,x				;\
		AND #$0F					; |
		STA !ExtraProp1,x				; |
		LDA #$E0 : STA !SpriteYSpeed,x			; | drop
		STZ !SpriteXSpeed,x				; |
		LDA #$40 : STA $32D0,x				; |
		.NoRex						;/


		BIT !ExtraProp1,x : BVC .NoBlock		; check block flag
		REP #$30
		LDA #$0000
		LDY #$0000
		JSL !GetMap16Sprite
		CMP #$0025
		SEP #$30
		BEQ .Emerge

		.CheckPowerup
		JSL !GetSpriteClipping04			; load yoshi coin hitbox
		LDY #$0F					;\
	-	LDA $3230,y : BEQ .Next				; |
		LDA $3200,y					; | look for mushroom/flower
		CMP #$74 : BEQ ++				; |
		CMP #$75 : BNE .Next				;/
	++	PHY						;\
		PHX						; |
		TYX						; |
		JSL !GetSpriteClipping00			; | check for contact
		PLX						; |
		JSL !CheckContact				; |
		PLY						; |
		BCS +						;/
	.Next	DEY : BPL -					;\
		PLB						; | wait for powerup sprite
		RTL						;/

	+	LDA #$00 : STA $3230,y				;\
		.Emerge						; > emerge from broken block
		LDA #$40 : STA $32D0,x				; |
		LDA #$D0 : STA !SpriteYSpeed,x			; |
		STZ !SpriteXSpeed,x				; | replace powerup sprite
		LDA !ExtraProp1,x				; |
		AND #$0F					; |
		STA !ExtraProp1,x				;/
		.NoBlock


		LDA $3330,x
		AND #$04 : PHA
		LDA !SpriteYSpeed,x : PHA
		STZ !SpriteXSpeed,x				; no horizontal speed please!
		JSL !SpriteApplySpeed				; apply speed with gravity
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
		STA !SpriteYSpeed,x
		.SpeedDone


		LDA $32D0,x					;\
		ORA !SpriteDisP1,x				; | no player interaction during drop
		ORA !SpriteDisP2,x				; | (or when disabled externally)
		BNE .NoContact					;/
		JSL !GetSpriteClipping04			; get yoshi coin hitbox
		SEC : JSL !PlayerClipping : BCS .Collected	; check for player body contact
		JSL P2Attack : BCC .NoContact			; check for player hitbox contact
		.Collected
		PHA
		JSR Glitter
		PLA
		AND #$02
		BEQ $02 : LDA #$80
		STA $04
		.ParticleShared
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYLo,x : STA $02
		LDA !SpriteYHi,x : STA $03
		LDA #$1C : STA !SPC1
		REP #$20
		LDA !YoshiCoinCount
		INC A
		STA !YoshiCoinCount
		SEP #$20
		LDY $3280,x
		LDA $BE,x : TAX
		TYA
		ORA !LevelTable1,x
		STA !LevelTable1,x
		JSR SpawnGlitterRing
		LDX !SpriteIndex
		STZ $3230,x
		.NoContact

		REP #$20
		LDA.w #ANIM : STA $04
		SEP #$20
		STZ $3320,x
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
		RTL



	!CoinSpinTime = $3F

	SpawnGlitterRing:
		PHB
		REP #$20
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$08 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$10 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$18 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$20 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$28 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$30 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$38 : STA !Particle_XAcc,x
		LDA $04 : STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		PLB
		SEP #$30
		RTS



	ANIM:
		dw $0008
		db $72,$00,$F3,$00
		db $72,$00,$03,$02


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





