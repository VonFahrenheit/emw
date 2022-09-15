
	!RipState		= $BE
	!RipTarget		= $3280
	!RipYoshiCoin		= $3290
	!RipDifficulty		= $32A0
	!RipTimer		= $32B0

	INIT:
		LDA !Difficulty : STA !RipDifficulty,x			; difficulty setting
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ .Return					; | read extra bit
		.Gold							;/
		INC !RipDifficulty,x					; +1 difficulty index
		LDA #$04 : STA !SpriteOAMProp,x				; yellow palset
		LDA #$EF : STA !SpriteTweaker4,x			; all resistances except star
		LDA !YoshiCoinCount : STA !RipYoshiCoin,x		; track yoshi coins
		.Return							;
		RTS							; return


	MAIN:
		LDA !SpriteStatus,x					;\
		CMP #$08 : BEQ .Timers					; | check state
		JMP .Graphics						;/


	.Timers
		LDA !ExtraBits,x					;\
		AND #$04 : BNE ..done					; | decrement sleep timer unless golden (never falls asleep)
		%decreg(!RipTimer)					; |
		..done							;/


	.Physics
		LDA !RipState,x : BNE ..chase				; check state

		..sleep							;\
		LDA !SpriteAnimIndex,x					; |
		CMP #$01 : BNE +					; |
		LDA !SpriteAnimTimer,x : BNE +				; |
		LDY !SpriteDir,x					; | snore z
		LDA DATA_SnoreX,y : STA $00				; |
		STZ $01							; |
		LDA #$F0 : STA $07					; |
		LDA.b #!prt_snorez : JSL SpawnParticle			;/
	+	STZ !SpriteFloat,x					;\
		LDA $14							; |
		AND #$03 : BNE +					; | slow down while asleep
		INC !SpriteFloat,x					; |
		JSL AccelerateX_Friction1				;/
	+	LDA !ExtraBits,x					;\ check extra bit
		AND #$04 : BEQ ..normalsleep				;/
		..goldsleep						;\
		LDA !P1CoinIncrease : BNE ..chasep1			; | golden rip:
		LDA !P2CoinIncrease : BNE ..chasep2			; | look for coins being collected
		LDA !YoshiCoinCount					; |
		CMP !RipYoshiCoin,x : BEQ ..move			;/
		LDA !RNG						;\
		AND #$80 : BRA ..settarget				; |
		..chasep1						; | start chasing
		LDA #$00 : BRA ..settarget				; |
		..chasep2						; |
		LDA #$80 : BRA ..settarget				;/
		..normalsleep						;\
		REP #$20						; |
		LDA.w #DATA_SleepSight : JSL LOAD_HITBOX		; | normal rip:
		JSL PlayerContact : BCC ..move				; | look for nearby players
		LSR A							; |
		LDA #$00						; |
		BCS $02 : LDA #$80					;/
		..settarget						;\
		STA !RipTarget,x					; |
		INC !RipState,x						; | set target player and update anim
		LDA #$02 : STA !SpriteAnimIndex,x			; |
		STZ !SpriteAnimTimer,x					;/

		..chase							;\
		STZ !SpriteFloat,x					; > free swim
		REP #$20						; |
		LDA.w #DATA_ChaseSight : JSL LOAD_HITBOX		; | maintain wake timer as long as a player is nearby
		JSL PlayerContact : BCC ..outofsight			; |
		LDA #$78 : STA !RipTimer,x				; |
		..outofsight						;/
		LDA !RipTimer,x : BNE ..stillchasing			;\
		STZ !RipState,x						; | fall asleep if wake timer runs out
		STZ !SpriteAnimIndex,x					; |
		BRA ..move						;/
		..stillchasing						;\
		LDY !RipTarget,x : JSL SUB_HORZ_POS_Target		; > face target
		TYA : STA !SpriteDir,x					; |
		LDY !RipDifficulty,x					; |
		LDA DATA_Speed,y : STA $0F				; | update speeds
		LDY !RipTarget,x					; |
		JSL TARGET_PLAYER_Main					; |
		LDA $04 : JSL AccelerateX_Unlimit1			; |
		LDA $06 : JSL AccelerateY_Unlimit1			; |
		..move							;/
		JSL APPLY_SPEED						;\ move
		..done							;/


	.Interaction
		JSL GetSpriteClippingE8					;\
		LDA !ExtraBits,x					; |
		AND #$04 : BNE ..noattack				; |
		JSL InteractAttacks : BCC ..noattack			; | die from attacks
		LDA #$02 : STA !SpriteStatus,x				; |
		LDA #$04 : STA !SpriteAnimIndex,x			; |
		BRA .Graphics						;/
		..noattack						;\
		JSL SpriteAttack_NoKnockback				; | attack with no knockback
		..nocontact						;/


	.Graphics
		LDA !ExtraBits,x					;\
		AND #$04 : BEQ ..draw					; | golden rip: glitter
		JSL MakeGlitter						; |
		..draw							;/
		REP #$20						;\
		LDA.w #ANIM : JSL UPDATE_ANIM				; | animate + draw
		JSL LOAD_PSUEDO_DYNAMIC					;/
		RTS							; return




	DATA:
	.SleepSight
		dw $FFD0,$FFD0 : db $70,$70

	.ChaseSight
		dw $FF80,$FF80 : db $FF,$FF

	.Speed
		db $10,$18,$20,$28			; indexed by difficulty, +1 for gold

	.SnoreX
		db $06,$04


	ANIM:
	dw .Sleep0	: db $40,$01	; 00
	dw .Sleep1	: db $28,$00	; 01
	dw .Chase0	: db $06,$03	; 02
	dw .Chase1	: db $06,$02	; 03
	dw .Dead	: db $FF,$04	; 04

	.Sleep0
	dw $0004
	db $22,$00,$00,$00
	.Sleep1
	dw $0004
	db $22,$00,$00,$02
	.Chase0
	dw $0004
	db $22,$00,$00,$04
	.Chase1
	dw $0004
	db $22,$00,$00,$06
	.Dead
	dw $0004
	db $A2,$00,$00,$04

