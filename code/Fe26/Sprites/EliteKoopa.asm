EliteKoopa:

	namespace EliteKoopa



	!BaseNumber	= $23		; sprite number of first elite koopa (assumes they will follow in order)



	!EliteAI	= $BE,x
			; -dikmmfj
			; d - shell drill
			; i - pick up items
			; k - knockback on touch
			; mm - movement mode:
			;	00 - no movement
			;	01 - patrol
			;	10 - advance
			;	11 - chase (also enables jumping at ledges and wall jumping)
			; f - fire
			; j - special jump attack



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
	!ItemSpeedY	= $35A0,x



	!JumpTimer	= $3340,x	; when non-zero, sprite has reduced gravity (used for yellow special)


	!FireTimer	= $32D0,x	; when this hits 0, sprite will throw a fireball if lowest bit of AI is set
	!KickTimer	= $32F0,x	; when this is non-zero, sprite will use its kick frame
	!ShellTimer	= $33E0,x	; when this is zero, sprite will slide in shell if chase is enabled

	!DrillState	= $3340,x
			; 00 - no drill
			; 01 - jumping towards player
			; 80 - drilling down

	!TackleTimer	= $35D0,x
	!SuperArmor	= $35E0,x	; goes up to 0x3C, or 0x78 on multiplayer, drops by 0x3C when the sprite is hit
					; sprite will only take damage if hit when this is 0


	!PrevAnim	= $35B0,x


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
		AND #$0C				;\
		CMP #$04 : BNE .NoPatrol		; | set turn timer if patrol is enabled
		LDA #$80 : STA !TurnTimer		;/
		.NoPatrol

		JSL SUB_HORZ_POS_Long			;\ face a player
		TYA : STA $3320,x			;/
		LDA #$3C : STA !SuperArmor		; > start with one charge of super armor

		LDA #$03 : JSL !GetDynamicTile
		BCC .Erase
		TYA
		ORA #$40
		STA !ClaimedGFX
		TXA
		STA !DynamicTile+0,y
		STA !DynamicTile+1,y
		STA !DynamicTile+2,y
		STA !DynamicTile+3,y

		.Return
		PLB
		RTL

		.Erase
		STZ $3230,x
		PLB
		RTL



	DATA:
		.Pal
		db $0A,$08,$06,$04

		.AI
		db $14,$02,$68,$3D

		.XSpeed
		db $18,$E8		; patrol
		db $10,$F0		; patrol EASY
		db $1C,$E4		; run
		db $24,$DC		; run INSANE
		db $30,$D0		; shell dash
		db $40,$C0		; shell dash INSANE

		.FireSpeed
		db $40,$C0		; NORMAL/INSANE
		db $28,$D8		; EASY

		.YellowFireRate
		db $10,$0C,$08


		.SuperArmor
		db $3C,$78		; single player, multiplayer


	Green_MAIN:
	Red_MAIN:
	Blue_MAIN:
	Yellow_MAIN:
	MAIN:
		PHB : PHK : PLB
		LDA !SpriteAnimIndex : STA !PrevAnim
		JSL SPRITE_OFF_SCREEN_Long
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D : BEQ .Process
		JMP Graphics


		.Process
		LDA !ShellTimer					;\ decrement shell timer
		BEQ $03 : DEC !ShellTimer			;/
		LDA !TackleTimer : BEQ +			;\
		DEC !TackleTimer				; |
		BNE +						; | decrement tackle timer
		LDA #$0A : STA !SpriteAnimIndex			; |
		LDA #$20 : STA !SpriteAnimTimer			;/
		+


		LDA !MultiPlayer				;\
		TAY						; |
		LDA DATA_SuperArmor,y				; | increment super armor timer
		CMP !SuperArmor : BEQ +				; |
		INC !SuperArmor					; |
		+						;/


		LDA !FireTimer : BNE .NoFire
		LDA !EliteAI
		AND #$03 : BEQ .NoFire

		.Fire
		LSR A : BCC .NormalFire
		LDA !JumpTimer : BEQ .NoFire
		CMP #$30 : BCS .NoFire
		LDA #$10 : STA !SpriteAnimIndex
		LDA #$0C : STA !SpriteAnimTimer
		BRA .Aim

		.NormalFire
		LDA #$10 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.CheckAim
		LDY #$06 : JSR CounterSight
		BCC .NoAim

		.Aim
		JSR SetAim
		LDY #$00
		LDA !Difficulty
		AND #$03
		BNE $02 : INY #2
		LDA DATA_FireSpeed,y
		JSL AIM_SHOT_Long
		LDA $06 : STA $05
		JSR Fire
		BRA .NoFire

		.NoAim
		LDY $3320,x
		LDA !Difficulty
		AND #$03
		BNE $02 : INY #2
		LDA DATA_FireSpeed,y : STA $04
		STZ $05
		JSR Fire
		.NoFire




		LDA !EliteAI					; check for special yellow attack
		LSR A : BCC .NoSpecialJump
		LDA !JumpTimer : BEQ +
		DEC !JumpTimer
		DEC $9E,x
		DEC $9E,x
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x
		+

		LDA $3330,x
		AND #$04 : BEQ .NoSpecialJump
		LDA !RNG
		CLC : ADC !SpriteIndex
		AND #$3F : BNE .NoSpecialJump
		LDY #$0C : JSR CounterSight
		BCC .NoSpecialJump
		LDA #$40 : STA !JumpTimer
		LDA #$D0 : STA $9E,x
		STZ $3330,x
		LDA #$05 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JSL SUB_HORZ_POS_Long
		LDA DATA_XSpeed+2,y : STA $AE,x
		.NoSpecialJump




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
		BRA .Face					;/

		.CheckDown
		LDA $3330,x					;\
		AND #$04 : BEQ +				; |
	.Face	STZ !DrillState					; |
		JSL SUB_HORZ_POS_Long				; |
		TYA : STA $3320,x				; |
		BRA .NoDrill					; |
	+	DEC $9E,x					; > lower gravity
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
		LDA #$C0 : STA $9E,x				; | start jump if a player is found
		LDA #$01 : STA !DrillState			; |
		JSL SUB_HORZ_POS_Long				; |
		TYA : STA $3320,x				;/
		.NoDrill

		LDA !Item
		BPL $03 : JMP .Trajectory
		BNE .Carry

		.Search
		JSL !GetSpriteClipping04
		LDY #$0F
	-	CPY !SpriteIndex : BEQ +
		LDA $3230,y
		CMP #$09 : BEQ ++
		CMP #$0A : BNE +
	++	PHX
		TYX
		JSL !GetSpriteClipping00
		JSL !CheckContact
		TXY
		PLX
		BCC +
		LDA !EliteAI
		AND #$20 : BNE .Grab
		LDA $3230,y					;\
		CMP #$09 : BEQ .Grab_r				; |
		LDA $3320,y					; |
		AND #$01					; |
		STA $3320,y					; |
		LDA $30AE,y					; |
		EOR #$FF					; |
		STA $30AE,y					; |
		LDA #$D0 : STA $309E,y				; | if this elite can't grab objects,
		LDA #$02 : STA !SPC1				; | the thrown item is bounced off
		LDA #$18 : STA !KickTimer			; |
		LDA $34F0,y					; | and the shell's owner scores a hit on the sprite
		BEQ $02 : LDA #$80				; |
		TAY						; |
		PEA.w .NoItems-1				; |
		JMP Interact_HurtSprite_Main			;/

	.Grab	TYA
		INC A
		STA !Item
		BRA .Carry_Go

	+	DEY : BPL -
	..r	JMP .NoItems

		.Carry
		DEC A
		TAY
	..Go	LDA $3230,y
		CMP #$0B : BCS ..drop
		CMP #$09 : BCS ..ok
	..drop	STZ !Item
		JMP .NoItems
	..ok	LDA #$02 : STA $34E0,y
		LDA $3320,x
		ASL A
		CLC : ADC $3320,x
		ASL #3
		SEC : SBC #$0C
		STA $00
		STZ $01
		BPL $02 : DEC $01
		LDA $3220,x
		SEC : SBC $00
		STA $3220,y
		LDA $3250,x
		SBC $01
		STA $3250,y
		LDA $3210,x
		SEC : SBC #$04
		STA $3210,y
		LDA $3240,x
		SBC #$00
		STA $3240,y
		LDY #$18 : JSR CounterSight
		BCC .NoItems
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x
		JSR SetAim
		LDA #$40
		JSL AIM_SHOT_Long
		LDA $04 : STA !ItemSpeedX
		LDA $06 : STA !ItemSpeedY
		LDA !Item
		ORA #$80
		STA !Item
		AND #$7F
		DEC A
		TAY
		LDA #$00 : STA $34E0,y
		LDA #$0A : STA $3230,y
		LDA #$18 : STA !KickTimer
		BRA .Trajectory_ok

		.Trajectory
		LDA !Item
		AND #$7F
		DEC A
		TAY
		LDA $3230,y
		CMP #$0A : BEQ ..ok
	..drop	STZ !Item
		BRA .NoItems
	..ok	LDA !ItemSpeedX : STA $30AE,y
		LDA !ItemSpeedY : STA $309E,y
		LDA $3330,y : BEQ .NoItems
		LDA #$00
		STA $309E,y
		STA $30AE,y
		LDA #$09 : STA $3230,y
		LDA #$09 : STA !SPC4
		LDA #$0F : STA !ShakeTimer
		STZ !Item
		.NoItems





		LDA !EliteAI				;\
		AND #$0C				; | this sight box only applies for patrollers
		CMP #$04 : BNE .NoSight			;/
		LDY #$00 : JSR CounterSight
		BCC .NoSight
		LDA !TackleTimer : BNE .SightDone

		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x

		LDA !TackleReady : BEQ +
		DEC !TackleReady : BNE ++

		LDA #$30 : STA !TackleTimer		; tackle for 48 frames
		LDA #$0D
		BRA +++

	+	LDA #$40 : STA !TackleReady
	++	LDA !TackleTimer : BNE .SightDone
		LDA !SpriteAnimIndex
		CMP #$0B : BEQ .NoReadyAnim
		LDA #$0A
	+++	STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoReadyAnim

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


		LDA !EliteAI
		LSR A : BCC .NotJumping
		LDA !JumpTimer : BEQ .NotJumping
		JMP .Write
		.NotJumping


		LDA !TackleTimer : BNE .Tackle		; tackle speed
		LDA !TackleReady : BNE .NoTurn		; don't process this during a staredown

		LDA $3330,x				;\
		AND #$03 : BEQ .Ok			; |
		LDA #$01 : STA !SPC1			; | always turn upon hitting a wall
		STZ $AE,x				; |
		LDA #$04 : STA !TurnTimer		; |
		BRA .Turn				;/
	.Ok	LDA !TurnTimer : BEQ .NoTurn		;\
		CMP #$04 : BNE +			; |
	.Turn	STA !SpriteAnimIndex			; |
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


		LDA !SpriteAnimIndex			;\ can't move during stun / ready
		CMP #$0B : BEQ .FJ
		CMP #$0A : BEQ .FJ			; |
		CMP #$09 : BNE $03			; |
	.FJ	JMP .Frctn				;/
		LDA !DrillState				;\
		BEQ +					; |
		BMI ++					; | speed during drill jump
	.Tackle	LDA $3330,x				;\
		AND #$03 : BEQ .NoBonk			; |
		LDA $AE,x				; |
		EOR #$FF				; |
		STA $AE,x				; | bonk code
		LDA #$E0 : STA $9E,x			; |
		LDA #$0A : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer			; |
		STZ !TackleTimer
		JMP .Frctn				;/

		.NoBonk
		LDY $3320,x				; |
		INY #4					; |
		JMP .Speed_Diff				;/
	++	LDA #$40 : STA $9E,x			;\ set Y speed and use friction during drill
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
	..Diff	LDA !Difficulty				; |
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
		LDA #$80 : STA !ShellTimer		; |
		LDA #$0D : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer			;/
		.NoSpeed



	Interaction:
		JSL !GetSpriteClipping04

		.Attack
		JSL P2Attack_Long
		BCC .NoAttack
		LSR A : BCC ..P2
	..P1	PHA
		LDA $32E0,x : BNE +
		LDY #$00 : JSR Interact_HurtSprite_Main
	+	PLA
	..P2	LSR A : BCC .NoAttack
		LDA $35F0,x : BNE .NoAttack
		LDY #$80 : JSR Interact_HurtSprite_Main
		.NoAttack

		.Contact
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC ..P2
	..P1	PHA
		LDA $32E0,x : BNE +
		LDY #$00 : JSR Interact
	+	PLA
		LSR A : BCC .NoContact
	..P2	LDA $35F0,x : BNE .NoContact
		LDY #$80 : JSR Interact
		.NoContact




	Graphics:
		LDA !SpriteAnimIndex
		CMP #$05 : BCC .NoShell
		CMP #$08 : BCS .NoShell
		LDA !JumpTimer : BNE .NoShell
		LDA !ShellTimer : BEQ .NoShell
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoShell


		LDA !KickTimer : BEQ .NoKick
		LDA #$0C : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoKick

		LDA !Item
		BEQ .NoItem
		BMI .NoItem
		LDA !SpriteAnimIndex
		CMP #$04 : BCS .NoItem
		ADC #$11
		STA !SpriteAnimIndex
		.NoItem

		LDA !SpriteAnimIndex
		CMP #$0D : BCC .NoTackle
		CMP #$10 : BCS .NoTackle
		LDA !TackleTimer : BNE .NoTackle
		LDA $3330,x
		AND #$04 : BEQ .NoTackle
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoTackle


		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #3
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		LDA.w ANIM+3,y
		STA !SpriteAnimIndex
		ASL #3
		TAY
		CPY #$20 : BCS .0
		LDA !NewSpriteNum,x
		CMP #!BaseNumber+3 : BNE .0
		LDA !ShellTimer
		CMP #$20 : BCS .0
		LDA #$03 : BRA .SameAnim
	.0	LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA !SpriteAnimIndex
		CMP !PrevAnim : BEQ .NoUpdate
		LDA ANIM+5,y
		ASL #2
		CLC : ADC !NewSpriteNum,x
		SEC : SBC #!BaseNumber
		PHY
		TAY
		LDA ANIM_PlumeTable,y
		PLY
		STA $00
		LDA.w ANIM+4,y : JSR GetDynamo
		PHY
		LDY.b #!File_EliteKoopa
		JSL !UpdateFromFile
		PLY

		.NoUpdate
		STZ $06						; initialize RAM transfer
		LDA $3460,x					;\
		AND #$0E					; | palette
		STA $02						;/
		CPY #$28 : BCC .Dynamic
		CPY #$50 : BCS .Dynamic
		LDA !GFX_Koopa
		ASL A
		AND #$E0
		STA $03
		BCC $02 : INC $02
		LDA !GFX_Koopa
		AND #$0F : TSB $03
		REP #$20
		STZ $00
		LDA.w ANIM+0,y : JSR LakituLovers_TilemapToRAM
		LDA.w #!BigRAM : STA $04
		SEP #$20

		LDA !SpriteAnimIndex
		CMP #$11 : BCC ..p1
	..p2	JSL LOAD_TILEMAP_p2_Long
		PLB
		RTL

	..p1	JSL LOAD_TILEMAP_p1_Long
		PLB
		RTL

		.Dynamic
		STZ $03

		REP #$20					;\
		STZ $00						; |
		LDA.w ANIM+0,y : JSR LakituLovers_TilemapToRAM	; |
		SEP #$20					; |
		LDA ANIM+5,y					; |
		PHY						; |
		ASL #2						; |
		CLC : ADC !NewSpriteNum,x			; |
		SEC : SBC #!BaseNumber				; |
		TAY						; |
		LDA ANIM_PlumeOffsetX,y : STA $00		; | transfer tilemap to RAM
		LDA ANIM_PlumeOffsetY,y : STA $01		; |
		PLY						; |
		LDA.w ANIM+6,y					; |
		CLC : ADC $00					; |
		STA $00						; |
		LDA.w ANIM+7,y					; |
		CLC : ADC $01					; |
		STA $01						; |
		REP #$20					; |
		LDA.w #ANIM_PlumeTM				; |
		JSR LakituLovers_TilemapToRAM			; |
		LDA.w #!BigRAM : STA $04			; |
		SEP #$20					;/

		LDA !SpriteAnimIndex
		CMP #$11 : BCC ..p1
	..p2	JSL LOAD_CLAIMED_p2_Long
		PLB
		RTL

	..p1	JSL LOAD_CLAIMED_p1_Long			; load tilemap
		.Return
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
		LDA !EliteAI
		LSR A
		LDA #$40
		BCC +
		LDA !Difficulty
		AND #$03 : TAY
		LDA DATA_YellowFireRate,y

	+	STA !FireTimer
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		LDA #$01
		LDY #$01
		JSL SpawnExSprite_Long
		RTS

	CounterSight:
		CPY #$06 : BNE .NoEasy
		LDA !Difficulty
		AND #$03 : BNE .NoEasy
		LDY #$1E
		.NoEasy

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
	dw -$0028,-$0020 : db $60,$FF	; 0C

	.DrillDown
	dw -$0008,$0020 : db $20,$FF	; 12

	.ThrowItem
	dw -$0048,-$0078 : db $A0,$FF	; 18

	.FireEasy
	dw -$0050,-$0040 : db $B0,$90	; used instead of 0x06 if difficulty is set to easy



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
		CLC : ADC #$0008			; 16px offset for Mario
	+	STA $02
		SEP #$20
		PLX
		RTS



	Interact:
		LDA #$06 : STA $00
		STZ $01
		LDA !P2Character-$80,y
		BNE +
		LDA #$0A : STA $00
	+	LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80,y
		BPL $03 : LDA #$0000
		CMP $00
		SEP #$20
		BCS .SpriteBelow
		LDA $9E,x : BPL .SpriteAbove
		LDA !P2YSpeed-$80,y : BPL .SpriteBelow

	.SpriteAbove
		TYA
		CLC
		ROL #2
		INC A
		JSL !HurtPlayers
		LDA !NewSpriteNum,x
		CMP #!BaseNumber+3 : BNE .Return
		LDA #$18 : STA !TackleTimer
		LDA #$0D : STA !SpriteAnimIndex
	.Return	RTS

	.SpriteBelow
		LDA !P2YSpeed-$80,y : BPL .HurtSprite
		CMP #$F0 : BCC .Return

	.HurtSprite
		JSL P2Bounce_Long
	..Main	LDA #$10 : JSL DontInteract_Long
		LDA !FireTimer : BEQ +
		LDA #$40 : STA !FireTimer			; reset fire timer
		+
		LDA !SuperArmor
		CMP #$3C : BCC ..Hurt
		SBC #$3C
		BPL $02 : LDA #$00
		STA !SuperArmor
		LDA #$02 : STA !SPC1
		STZ !SpriteAnimTimer
		LDA !NewSpriteNum,x
		CMP #!BaseNumber+1 : BNE +
		LDA #$15
		BRA ++
	+	LDA #$0B
	++	STA !SpriteAnimIndex
		RTS

	..Hurt	LDA !NewSpriteNum,x
		SEC : SBC #!BaseNumber
		CLC : ADC #$04
		STA $3200,x
		LDA #$09 : STA $3230,x
		LDA !ExtraBits,x
		AND.b #$08^$FF
		STA !ExtraBits,x
		JSL !ResetSprite			; | > Reset sprite tables
		LDA #$02 : STA $32D0,x			; spawn shelless koopa
		RTS


	; creates a dynamo of tile A in !BigRAM and sets $0C to point to it
	; load A with starting tile of koopa frame
	; load Y with plume tile
	; then call this
	GetDynamo:
		REP #$20
		AND #$00FF
		ASL #5
		STA !BigRAM+$04
		CLC : ADC #$0200
		STA !BigRAM+$0B

		LDA $00
		AND #$00FF
		ASL #5
		STA !BigRAM+$12
		CLC : ADC #$0200
		STA !BigRAM+$19

		LDA #$001C : STA !BigRAM+$00
		LDA.w #!BigRAM : STA $0C

		LDA #$00C0
		STA !BigRAM+$02
		STA !BigRAM+$09
		LDA #$0040
		STA !BigRAM+$10
		STA !BigRAM+$17

		LDA #$6000 : STA !BigRAM+$07
		LDA #$6100 : STA !BigRAM+$0E
		LDA #$6060 : STA !BigRAM+$15
		LDA #$6160 : STA !BigRAM+$1C

		SEP #$20
		STZ !BigRAM+$06
		STZ !BigRAM+$0D
		STZ !BigRAM+$14
		STZ !BigRAM+$1B

		RTS



; tilemap, frame count, next frame
; source tile, plume index, plume X, plume Y

	ANIM:
	.Walk
	dw .IdleTM	: db $08,$01		; 00
	db $00,$00	: db $03,$F0
	dw .WalkTM	: db $08,$02		; 01
	db $20,$01	: db $03,$EE
	dw .IdleTM	: db $08,$03		; 02
	db $00,$00	: db $03,$F0
	dw .WalkTM	: db $08,$00		; 03
	db $06,$01	: db $03,$EE

	.Turn
	dw .IdleTM	: db $08,$00		; 04
	db $66,$00	: db $00,$F0

	.Shell
	dw .ShellTM00	: db $04,$06		; 05
	db $00,$FF	: db $00,$F0
	dw .ShellTM01	: db $04,$07		; 06
	db $00,$FF	: db $00,$F0
	dw .ShellTM02	: db $04,$08		; 07
	db $00,$FF	: db $00,$F0
	dw .ShellTM03	: db $04,$05		; 08
	db $00,$FF	: db $00,$F0

	.TemporaryDuck
	dw .ShellTM00	: db $18,$00		; 09
	db $00,$FF	: db $00,$F0

	.Ready
	dw .IdleTM	: db $40,$00		; 0A
	db $26,$00	: db $FF,$F4

	.Guard
	dw .IdleTM	: db $18,$00		; 0B
	db $80,$00	: db $00,$F0

	.Kick
	dw .IdleTM	: db $02,$0A		; 0C
	db $40,$00	: db $03,$F0

	.TackleNormal
	dw .IdleTM	: db $04,$0E		; 0D
	db $60,$02	: db $03,$F0
	dw .IdleTM	: db $04,$0F		; 0E
	db $60,$03	: db $03,$F0
	dw .IdleTM	: db $04,$0D		; 0F
	db $60,$04	: db $03,$F0

	.Throw
	dw .IdleTM	: db $10,$0A		; 10
	db $46,$00	: db $FC,$F3

	.Carry
	dw .IdleTM	: db $08,$12		; 11
	db $A0,$00	: db $03,$F0
	dw .WalkTM	: db $08,$13		; 12
	db $A6,$01	: db $03,$EE
	dw .IdleTM	: db $08,$14		; 13
	db $A0,$00	: db $03,$F0
	dw .WalkTM	: db $08,$11		; 14
	db $06,$01	: db $03,$EE

	.GuardRed
	dw .IdleTM	: db $18,$0A		; 15
	db $80,$00	: db $00,$F0


	.IdleTM
	dw $0010
	db $30,$F8,$F0,$00
	db $30,$00,$F0,$01
	db $30,$F8,$00,$03
	db $30,$00,$00,$04

	.WalkTM
	dw $0010
	db $30,$F8,$EE,$00
	db $30,$00,$EE,$01
	db $30,$F8,$FE,$03
	db $30,$00,$FE,$04

	.ShellTM00
	dw $0004
	db $30,$00,$00,$A4

	.ShellTM01
	dw $0004
	db $30,$00,$00,$A6

	.ShellTM02
	dw $0004
	db $70,$00,$00,$A4

	.ShellTM03
	dw $0004
	db $30,$00,$00,$A8

	.PlumeTM
	dw $0004
	db $30,$00,$00,$06



	; green, red, blue, yellow

	.PlumeTable
	db $0C,$6C,$4C,$6E	; walk frame 0
	db $0E,$6C,$4E,$8C	; walk frame 1
	db $2C,$6C,$4C,$8E	; special frame 0
	db $2E,$6C,$4E,$AC	; special frame 1
	db $0E,$6C,$4E,$AE	; special frame 2

	.PlumeOffsetX
	db $00,$FD,$FA,$00
	db $00,$FC,$FA,$00
	db $00,$FD,$FA,$00
	db $00,$FC,$FA,$00
	db $00,$FC,$FA,$00

	.PlumeOffsetY
	db $00,$F7,$FE,$00
	db $00,$F8,$FE,$00
	db $00,$F7,$FE,$00
	db $00,$F8,$FE,$00
	db $00,$F8,$FE,$00

	namespace off









