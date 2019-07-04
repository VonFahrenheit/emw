EliteKoopa:

	namespace EliteKoopa



	!EliteAI	= $BE,x
			; cdikp-ff
			; c - chase
			; d - shell drill
			; i - pick up items
			; k - knockback on touch
			; p - patrol-guard
			; ff - fire mode:
			;	00 - no fire
			;	01 - throw fireballs at range
			;	10 - counter with fireballs
			;	11 - throw fireballs at range and counter with fireballs



	!TurnTimer	= $3280,x

	!TackleReady	= $3290,x
			; if this is non-zero, sprite is getting ready to tackle
			; it is set to zero if a player leaves the sight-box
			; if a player jumps when this is non-zero, the sprite will also jump


	!Item		= $32A0,x
			; t--iiiii
			; t - thrown flag (set means the item has been yeeted, clear means it is held)
			; iiiii - index of item + 1

	!ItemSpeedX	= $32B0,x
	!ItemSpeedY	= $32C0,x	; this one is also !ClaimedGFX, but this sprite doesn't use that


	!FireTimer	= $32D0,x	; when this hits 0, sprite will throw a fireball if lowest bit of AI is set





	Green_INIT:
		LDY #$00 : BRA INIT
	Red_INIT:
		LDY #$01 : BRA INIT
	Blue_INIT:
		LDY #$02 : BRA INIT
	Yellow_INIT:
		LDY #$03

	INIT:
		PHB : PHK : PLB
		LDA.w DATA_Pal,y
		ORA $3460,x
		STA $3460,x
		LDA.w DATA_AI,y : STA !EliteAI

		AND #$08 : BEQ .NoPatrol		;\ set turn timer if patrol is enabled
		LDA #$80 : STA !TurnTimer		;/



		.NoPatrol


		PLB
		RTL




	DATA:
		.Pal
		db $0A,$08,$06,$04

		.AI
		db $18,$03,$60,$B2

		.XSpeed
		db $18,$E8		; patrol
		db $10,$F0		; patrol EASY
		db $20,$E0		; run
		db $28,$D8		; run INSANE



	Green_MAIN:
	Red_MAIN:
	Blue_MAIN:
	Yellow_MAIN:
	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN_Long
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D : BEQ .Process
		JMP Graphics


		.Process
		LDA !EliteAI
		AND #$03 : BEQ .NoFire
		LSR A : BCC .FlameCounter
		PHA
		LDA !FireTimer : BNE +
		LDA #$40 : STA !FireTimer
		JSR Fire
	+	PLA : BEQ .NoFire

		.FlameCounter
		LDA $3220,x
		SEC : SBC #$50
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$50
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$B0
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .NoFire
		JSR Fire

		.NoFire




		LDA !EliteAI				;\ this sight box only applies for patrollers
		AND #$08 : BEQ .NoSight			;/
		LDA $3220,x				;\
		SEC : SBC #$20				; |
		STA $04					; |
		LDA $3250,x				; |
		SBC #$00				; |
		STA $0A					; | set up 80x256 sight box around sprite
		LDA $3210,x				; |
		SEC : SBC #$80				; |
		STA $05					; |
		LDA $3240,x				; |
		SBC #$00				; |
		STA $0B					; |
		LDA #$50 : STA $06			; |
		LDA #$FF : STA $07			;/
		SEC : JSL !PlayerClipping		;\ check for players
		BCC .NoSight				;/

		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x

		LDA !TackleReady : BEQ +
		DEC !TackleReady : BNE ++

	; start tackle code here

	+	LDA #$40 : STA !TackleReady
	++	STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA !MultiPlayer : BEQ +
		LDA $6DA6
	+	ORA $6DA7
		BPL .SightDone
		LDA $3330,x
		AND #$04 : BEQ +
		LDA !P2YSpeed-$80
		BIT !P2YSpeed : BPL +
		CMP !P2YSpeed
		BCC $03 : LDA !P2YSpeed
	+	TAY
		BMI $02 : LDA #$00
		STA $9E,x
		BRA .SightDone

		.NoSight
		STZ !TackleReady			; clear this timer
		.SightDone


		LDA !TackleReady : BNE .NoTurn		; don't process this during a staredown
		LDA !TurnTimer : BEQ .NoTurn		;\
		CMP #$04 : BNE +			; |
		STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer			; | the last 4 frames on the timer use the turn animation
	+	DEC !TurnTimer : BNE .NoTurn		; |
		LDA $3320,x				; |
		EOR #$01				; |
		STA $3320,x				;/
		LDA !EliteAI				;\
		AND #$08 : BEQ .NoTurn			; | reset turn timer if patrol is enabled
		LDA #$80 : STA !TurnTimer		;/
		.NoTurn


		LDA !TackleReady : BNE .Frctn		; grind to a halt when ready to tackle
		LDA !SpriteAnimIndex			;\
		CMP #$04 : BNE .Speed			; | friction during turn animation
	.Frctn	JSR Friction				; |
		BRA .Write				;/

	.Speed	LDY $3320,x				;\
		LDA !Difficulty				; |
		AND #$03				; | higher index on EASY, based on direction
		BNE $02 : INY #2			; |
		LDA DATA_XSpeed,y : STA $AE,x		;/
	.Write	JSL !SpriteApplySpeed			; > apply speed
		.NoSpeed





	Graphics:



		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		LDA ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		STZ $06						; initialize RAM transfer
		LDA $3460,x					;\ palette
		AND #$0E : STA $02				;/
		LDA !GFX_status+$01				;\
		ASL A						; | tile offset
		STA $03						;/
		BCC $02 : INC $02				; > add 1 to property if tile offset > 0x7F
		REP #$20					;\
		STZ $00						; |
		LDA.w ANIM+0,y : JSR LakituLovers_TilemapToRAM	; | transfer tilemap to RAM
		LDA.w #!BigRAM : STA $04			; |
		SEP #$20					;/

		JSL LOAD_TILEMAP_Long				; load tilemap

		PLB
		RTL



	Friction:
		LDA $AE,x : BEQ .Return
		BPL .Dec
	.Inc	INC $AE,x : RTS
	.Dec	DEC $AE,x
	.Return	RTS




	Fire:

		RTS





	ANIM:
	.Walk
	dw .IdleTM	: db $08,$01		; 00
	dw .WalkTM00	: db $08,$02		; 01
	dw .IdleTM	: db $08,$03		; 02
	dw .WalkTM01	: db $08,$00		; 03

	dw .TurnTM	: db $08,$00		; 04


	.IdleTM
	dw $0008
	db $20,$00,$F0,$C0
	db $20,$00,$00,$E0

	.WalkTM00
	dw $0008
	db $20,$00,$F1,$C2
	db $20,$00,$01,$E2

	.WalkTM01
	dw $0008
	db $20,$00,$F1,$C4
	db $20,$00,$01,$E4

	.TurnTM
	dw $0008
	db $20,$00,$F0,$C6
	db $20,$00,$00,$E6


	namespace off









