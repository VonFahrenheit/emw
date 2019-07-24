EliteKoopa:

	namespace EliteKoopa



	!EliteAI	= $BE,x
			; -dikmmff
			; d - shell drill
			; i - pick up items
			; k - knockback on touch
			; mm - movement mode:
			;	00 - no movement
			;	01 - patrol
			;	10 - advance
			;	11 - chase (also enables jumping at ledges and wall jumping)
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
	!CounterTimer	= $32F0,x	; when this is non-zero, sprite can not counter (auto-decrements)
	!ShellTimer	= $33E0,x	; when this is non-zero, sprite will slide in shell if chase is enabled

	!DrillState	= $3340,x
			; 00 - no drill
			; 01 - jumping towards player
			; 80 - drilling down





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
		AND #$0C : BNE .NoPatrol		;\ set turn timer if patrol is enabled
		LDA #$80 : STA !TurnTimer		;/



		.NoPatrol


		PLB
		RTL




	DATA:
		.Pal
		db $0A,$08,$06,$04

		.AI
		db $14,$03,$68,$3E

		.XSpeed
		db $18,$E8		; patrol
		db $10,$F0		; patrol EASY
		db $1C,$E4		; run
		db $24,$DC		; run INSANE
		db $30,$D0		; shell dash
		db $40,$C0		; shell dash INSANE

		.FireSpeed
		db $40,$C0		;
		db $30,$D0		; EASY



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
		LDA !ShellTimer					;\ decrement shell timer
		BEQ $03 : DEC !ShellTimer			;/

		LDA !EliteAI
		AND #$03 : BNE .Fire
		JMP .NoFire

		.Fire
		LSR A : BCC .FlameCounter
		PHA
		LDA !FireTimer : BNE +
		LDA #$30 : STA !FireTimer
		LDY $3320,x
		LDA !Difficulty
		AND #$03
		BNE $02 : INY #2
		LDA DATA_FireSpeed,y : STA $04
		STZ $05
		JSR Fire
	+	PLA : BEQ .NoFire

		.FlameCounter
		LDA !CounterTimer : BNE .NoFire
		LDY #$06 : JSR CounterSight
		BCC .NoFire
		LDA #$40 : STA !CounterTimer
		JSR SetAim
		LDY #$00
		LDA !Difficulty
		AND #$03
		BNE $02 : INY #2
		LDA DATA_FireSpeed,y
		JSL AIM_SHOT_Long
		LDA $06 : STA $05
		JSR Fire
		.NoFire


		BIT !EliteAI : BVC .NoDrill			; > check for drill attack
		LDA !SpriteAnimIndex				;\ can't drill during stun
		CMP #$09 : BEQ .NoDrill				;/
		LDA !DrillState					;\
		BEQ .CheckStart					; | check for state
		BPL .CheckDown					;/
		LDA $3330,x					;\
		AND #$04 : BEQ .NoDrill				; |
		STZ !DrillState					; |
		LDA #$09 : STA !SPC4				; | impact code
		LDA #$18 : STA !ShakeTimer			; |
		LDA #$09 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer				; |
		BRA .NoDrill					;/

		.CheckDown
		LDA $3330,x					;\
		AND #$04 : BEQ +				; |
		STZ !DrillState					; |
		BRA .NoDrill					; |
	+	JSL SUB_HORZ_POS_Long				; |
		TYA : STA $3320,x				; |
		BIT $9E,x : BMI .NoDrill			; | look for players below
		LDY #$12 : JSR CounterSight			; |
		BCC .NoDrill					; |
		LDA #$80 : STA !DrillState			; |
		LDA #$05 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer				; |
		BRA .NoDrill					;/

		.CheckStart
		LDA $3330,x					;\
		AND #$04 : BEQ .NoDrill				; |
		LDY #$0C : JSR CounterSight			; | check for nearby players
		BCC .NoDrill					; |
		LDA #$B0 : STA $9E,x				; |
		LDA #$01 : STA !DrillState			;/
		.NoDrill


		LDA !EliteAI
		AND #$20 : BNE $03 : JMP .NoItems
		LDA !Item
		BMI .Trajectory
		BNE .Carry

		.Search
		JSL !GetSpriteClipping04
		LDY #$0F
	-	LDA $3230,y
		CMP #$09 : BCC +
		PHX
		TYX
		JSL !GetSpriteClipping00
		TXY
		PLX
		JSL !CheckContact
		BCC +
		TYA
		INC A
		STA !Item
		BRA .Carry_Go

	+	DEY : BPL -
		BRA .NoItems

		.Carry
		DEC A
		TAY
	..Go	LDA #$02 : STA $34E0,y
		JSL SPRITE_A_SPRITE_B_COORDS_Long
		LDY #$18 : JSR CounterSight
		BCC .NoItems
		JSR SetAim
		LDA #$40
		JSL AIM_SHOT_Long
		LDA $04 : STA !ItemSpeedX
		LDA $06 : STA !ItemSpeedY
		LDA !Item
		ORA #$80
		STA !Item

		.Trajectory
		PHX
		LDA !Item
		AND #$7F
		DEC A
		TAY
		LDA !ItemSpeedX : STA $30AE,y
		LDA !ItemSpeedY : STA $309E,y
		TYX
		STZ $34E0,x
		JSL !SpriteApplySpeed
		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC $04 : JSL !HurtPlayers
		PLX
		TXY
		LDA $3330,x : BEQ .NoItems
		LDA #$00
		STA $309E,y
		STA $30AE,y
		STZ !Item

		.NoItems





		LDA !EliteAI				;\
		AND #$0C				; | this sight box only applies for patrollers
		CMP #$04 : BNE .NoSight			;/
		LDY #$00 : JSR CounterSight

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
		AND #$0C				; | reset turn timer if patrol is enabled
		CMP #$04 : BNE .NoTurn			; |
		LDA #$80 : STA !TurnTimer		;/
		.NoTurn

		LDA !SpriteAnimIndex			;\ can't move during stun
		CMP #$09 : BNE $03 : JMP .Frctn		;/
		LDA !DrillState : BPL +			;\
		LDA #$40 : STA $9E,x			; | set Y speed and use friction during drill
		BRA .Frctn				;/
	+	LDY $3320,x				; Y = speed index
		LDA !EliteAI				;\
		AND #$0C : BEQ .Camp			; | check movement type
		CMP #$0C : BNE .Move			;/
		LDA $3330,x				;\ can't turn in midair when chasing
		AND #$04 : BEQ +			;/
		LDA !TurnTimer : BNE .Frctn		; > friction while turning
		JSL SUB_HORZ_POS_Long			;\
		TYA					; |
		CMP $3320,x :  BEQ +			; |
		LDA #$80 : STA !ShellTimer		; |
		LDA #$08 : STA !TurnTimer		; |
		LDA #$04 : STA !SpriteAnimIndex		; | chase clause
		STZ !SpriteAnimTimer			; |
		BRA .Frctn				; > apply friction
	+	LDA !Difficulty				; |
		AND #$03				; |
		CMP #$02				; |
		BNE $02 : INY #2			; |
		LDA !ShellTimer : BNE .NoShll		; |
		INY #4					; |
		LDA !SpriteAnimIndex			; |
		CMP #$05 : BCC +			; | animation setup
		CMP #$09 : BCC .NoShll			; |
	+	LDA #$05 : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer			; |
	.NoShll	LDA DATA_XSpeed+4,y			; |
		BRA .X					;/

	.Camp	JSL SUB_HORZ_POS_Long			;\
		TYA : STA $3320,x			; | face player if no movement is enabled
		BRA .Frctn				;/

	.Move	LDA !TackleReady : BNE .Frctn		; grind to a halt when ready to tackle
		LDA !SpriteAnimIndex			;\
		CMP #$04 : BNE .Speed			; | friction during turn animation
	.Frctn	JSR Friction				; |
		BRA .Write				;/

	.Speed	LDY $3320,x				;\
		LDA !Difficulty				; |
		AND #$03				; | higher index on EASY, based on direction
		BNE $02 : INY #2			; |
		LDA DATA_XSpeed,y			; |
	.X	JSR SetSpeed				;/
	.Write	LDA $3330,x				;\ backup ground flag
		AND #$04 : PHA				;/
		JSL !SpriteApplySpeed			; > apply speed
		PLA : BEQ .NoSpeed			;\
		EOR $3330,x				; |
		AND #$04				; |
		BEQ .NoSpeed				; |
		LDA !EliteAI				; | jump at ledges during chase
		AND #$0C				; |
		CMP #$0C : BNE .NoSpeed			; |
		LDA #$B0 : STA $9E,x			; |
		LDA #$80 : STA !ShellTimer		;/
		.NoSpeed





	Graphics:
		LDA !SpriteAnimIndex
		CMP #$05 : BCC .NoShell
		CMP #$08 : BCS .NoShell
		LDA !ShellTimer : BEQ .NoShell
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoShell



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
		LSR #4
		TAY
		LDA $AE,x
		SEC : SBC .Table,y
		STA $AE,x
	.Return	RTS

	.Table	db $01,$02,$03,$04
		db $05,$06,$07,$08
		db $F8,$F9,$FA,$FB
		db $FC,$FD,$FE,$FF

	SetSpeed:
		SEC : SBC $AE,x
		BEQ .Return
		LSR #4
		TAY
		LDA $AE,x
		CLC : ADC Friction_Table,y
		STA $AE,x
	.Return	RTS


	Fire:
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		LDA #$01
		LDY #$01
		JSL SpawnExSprite_Long
		RTS

	CounterSight:
		LDA $3220,x
		CLC : ADC .Table+0,y
		STA $04
		LDA $3250,x
		ADC .Table+1,y
		STA $0A
		LDA $3210,x
		CLC : ADC .Table+2,y
		STA $05
		LDA $3240,x
		ADC .Table+3,y
		STA $0B
		LDA .Table+4,y : STA $06
		LDA .Table+5,y : STA $07
		SEC : JSL !PlayerClipping
		RTS


	.Table
	.Patrol
	dw -$0020,-$0080 : db $50,$FF	; 00

	.Fire
	dw -$0050,-$0050 : db $B0,$B0	; 06

	.ShellDrill
	dw -$0038,-$0020 : db $80,$FF	; 0C

	.DrillDown
	dw -$0008,$0010 : db $20,$FF	; 12

	.ThrowItem
	dw -$0078,-$0078 : db $FF,$FF	; 18



	SetAim:
		PHX
		LDY #$00
		LSR A
		BCS $02 : LDY #$80
		LDA $3220,x
		SEC : SBC !P2XPosLo-$80,y
		STA $00
		LDA $3250,x
		SBC !P2XPosHi-$80,y
		STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80,y
		LDX !P2Character-$80,y : BNE +
		CLC : ADC #$0010			; 16px offset for Mario
	+	STA $02
		SEP #$20
		PLX
		RTS




	ANIM:
	.Walk
	dw .IdleTM	: db $08,$01		; 00
	dw .WalkTM00	: db $08,$02		; 01
	dw .IdleTM	: db $08,$03		; 02
	dw .WalkTM01	: db $08,$00		; 03

	.Turn
	dw .TurnTM	: db $08,$00		; 04

	.Shell
	dw .ShellTM00	: db $04,$06		; 05
	dw .ShellTM01	: db $04,$07		; 06
	dw .ShellTM02	: db $04,$08		; 07
	dw .ShellTM03	: db $04,$05		; 08

	.TemporaryDuck
	dw .ShellTM00	: db $18,$00		; 09



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

	.ShellTM00
	dw $0004
	db $20,$00,$00,$A4

	.ShellTM01
	dw $0004
	db $20,$00,$00,$A6

	.ShellTM02
	dw $0004
	db $60,$00,$00,$A4

	.ShellTM03
	dw $0004
	db $20,$00,$00,$A8


	namespace off









