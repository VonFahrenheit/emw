

	namespace CaptainWarrior

	!Phase		= !BossData+0
	!HP		= !BossData+1
	!Attack		= !BossData+2
	!AttackTimer	= !BossData+3

	!InvincTimer	= $3420,x
	!AttackMemory	= $6DF5,x		; < Technically an OW sprite table, but who cares


	INIT:
		PHB : PHK : PLB			; > Always do this. Just... do it.
		JSL $138030			;\
		BCS +				; |
		LDA #!VRAMbank			; |
		PHA : PLB			; |
		REP #$20			; |
		LDA #$001E			; |
		STA !CGRAMtable+$00,y		; |
		STA !CGRAMtable+$06,y		; | Upload palette
		LDA.w #BodyPal			; |
		STA !CGRAMtable+$02,y		; |
		LDA.w #AxePal			; |
		STA !CGRAMtable+$08,y		; |
		SEP #$20			; |
		LDA.b #BodyPal>>16		; |
		STA !CGRAMtable+$04,y		; |
		STA !CGRAMtable+$0A,y		; |
		LDA #$E1			; |
		STA !CGRAMtable+$05,y		; |
		LDA #$C1			; |
		STA !CGRAMtable+$0B,y		; |
	+	PHK : PLB			;/
		LDX !SpriteIndex		; > Restore sprite index
		LDA #$01 : STA $3320,x		; > Face left

		LDA #$04
		STA $3330,x
		LDA !Difficulty
		AND #$03
		TAY
		LDA.w .BaseHP,y
		STA !HP
		STZ !BossData+0
		STZ !BossData+2
		STZ !BossData+3
		STZ !BossData+4
		STZ !BossData+5
		STZ !BossData+6
		LDA #$C0 : STA !ClaimedGFX

		LDA !ExtraBits,x
		AND #$04
		BNE .Return

		STZ $3230+$00 : STZ $3230+$01
		STZ $3230+$02 : STZ $3230+$03
		STZ $3230+$04 : STZ $3230+$05
		STZ $3230+$06 : STZ $3230+$07
		STZ $3230+$08 : STZ $3230+$09
		STZ $3230+$0A : STZ $3230+$0B
		STZ $3230+$0C : STZ $3230+$0D
		LDA #$08 : STA $3230,x

		.Return
		PLB
		RTL

		.BaseHP
		db $05,$05,$07


	MAIN:
		PHB : PHK : PLB
		STZ $3280,x
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE LOCK_SPRITE
		LDA !Phase
		ASL A
		TAX
		JMP (.PhasePtr,x)

		.PhasePtr
		dw Intro			; 0
		dw Battle			; 1
		dw Defeated			; 2
		.End


	LOCK_SPRITE:
		JMP Battle_Graphics

	Intro:
		LDX !SpriteIndex
		LDA !ExtraBits,x
		AND #$04
		BEQ .Normal
		LDA !Phase
		BMI +
		ORA #$80 : STA !Phase
		LDA.b #Body_Idle0
		STA $0C
		LDA.b #Body_Idle0>>8
		STA $0D
		LDA.b #Axe_Idle
		STA $0E
		LDA.b #Axe_Idle>>8
		STA $0F
		JSR UPDATE_GFX
		PLB
		RTL

	+	JSR SUB_HORZ_POS
		TYA : STA $3320,x
		STZ !SpriteAnimTimer
		JMP Battle_Graphics


		.Normal
		LDA !Phase
		BMI .Main
		ORA #$80 : STA !Phase
		LDA #$80 : STA !SPC3

		.Main
		LDA $1A
		BNE .Return
		LDA $1B
		CMP #$14
		BNE .Return
		LDA #$01 : STA !Phase
		LDA #$03 : STA !MsgTrigger

		.Return
		JMP Battle_Graphics


	Battle:
		LDA !Phase
		BMI .Main
		ORA #$80 : STA !Phase
		LDA #$37 : STA !SPC3		; > Battle theme
		LDA #$02 : STA !AnimToggle	; > Minimalist NMI
		LDA.b #Body_Idle0		;\
		STA $0C				; |
		LDA.b #Body_Idle0>>8		; |
		STA $0D				; |
		LDA.b #Axe_Chop1init		; | Upload first half of chop1 axe frame
		STA $0E				; |
		LDA.b #Axe_Chop1init>>8		; |
		STA $0F				; |
		JSR UPDATE_GFX			;/
		PLB
		RTL

		.Main
		LDA !HP				;\
		BEQ +				; |
		BPL .Minion1			; | Check for HP underflow
	+	LDA #$02 : STA !Phase		; |
		JMP Defeated			;/

		.Minion1
		LDX !BossData+5
		BEQ +
		DEX
		LDA $3230,x
		BEQ ++
		BRA .Minion2
	+	LDX #$0C
	-	DEX
		LDA $3230,x
		BNE -
	++	JSR Spawn
		LDA !RNG			;\
		EOR #$01			; | Make sure both don't spawn at the same spot
		STA !RNG			;/
		INX
		STX !BossData+5

		.Minion2
		LDA !Difficulty			;\
		AND #$03			; | Only allow 1 minion on easy
		BEQ .Boss			;/
		LDX !BossData+6
		BEQ +
		DEX
		LDA $3230,x
		BEQ ++
		BRA .Boss
	+	LDX #$0C
	-	DEX
		LDA $3230,x
		BNE -
	++	JSR Spawn
		INX
		STX !BossData+6

		.Boss
		LDX !SpriteIndex
		LDA !AttackTimer
		BEQ .UpdateAttack
		DEC !AttackTimer
		BRA .HandleAttack

		.UpdateAttack
		LDA !Attack
		AND #$7F : TAY
		LDA .NextAttack,y
		CMP #$FF : BEQ .RandomizeAttack
		STA !Attack
		AND #$7F : TAY
		LDA .AttackTime,y
		STA !AttackTimer
		BRA .HandleAttack

		.RandomizeAttack
		LDA !RNG
		AND #$07
		TAY
	-	LDA .RandomAttack,y
		CMP !AttackMemory		;\
		BNE +				; |
		DEY				; | Randomness control
		BPL -				; |
		LDY #$07			; |
		BRA -				;/
	+	STA !Attack
		STA !AttackMemory
		TAY
		LDA .AttackTime,y
		STA !AttackTimer


		.HandleAttack
		LDA !Attack
		ASL A
		TAX
		JSR (.AttackPtr,x)
		JSL $01802A			; Apply speed

		JSR Interaction1		; > Destroys all graphics
		JSR Interaction2		; > Freezes


		.Graphics
		; $3280,x forces GFX update if negative.
		; Otherwise it will only be updated when naturally switching frames.

		LDA !SpriteAnimIndex
		ASL #3
		TAY
		LDA.w Anim+0,y : STA $04
		LDA.w Anim+1,y : STA $05
		LDA !SpriteAnimTimer
		INC A
		CMP.w Anim+6,y
		BNE +
		LDA.w Anim+7,y
		STA !SpriteAnimIndex
		ASL #3
		TAY
		LDA.w Anim+0,y : STA $04
		LDA.w Anim+1,y : STA $05
		LDA.w Anim+2,y : STA $0C
		LDA.w Anim+3,y : STA $0D
		LDA.w Anim+4,y : STA $0E
		LDA.w Anim+5,y : STA $0F
		JSR UPDATE_GFX
		LDA #$00
	+	STA !SpriteAnimTimer

		BIT $3280,x
		BPL +
		LDA !SpriteAnimIndex
		ASL #3
		TAY
		LDA.w Anim+2,y : STA $0C
		LDA.w Anim+3,y : STA $0D
		LDA.w Anim+4,y : STA $0E
		LDA.w Anim+5,y : STA $0F
		JSR UPDATE_GFX
	+	LDA !InvincTimer
		BEQ .Draw
		LDA $14
		AND #$06
		BNE .Draw
		PLB
		RTL

		.Draw
		JSR LOAD_TILEMAP
		PLB
		RTL


		.AttackPtr
		dw PrepChop			; 00
		dw Chop				; 01
		dw Jump				; 02
		dw HurricaneJump		; 03
		dw Hurricane			; 04
		dw Stuck			; 05
		dw HurtGround			; 06
		dw HurtAir			; 07

		.NextAttack
		db $01,$FF,$FF,$04		; 00-03
		db $05,$02,$FF,$86		; 04-07

		.AttackTime
		db $60,$22,$7F,$20		; 00-03
		db $7F,$7F,$3F,$7F		; 04-07

		.RandomAttack
		db $00,$00,$00			; 3/8 chance to prepare chop
		db $02,$02			; 2/8 chance to jump
		db $03,$03,$03			; 3/8 chance to hurricane jump



	PrepChop:
		LDX !SpriteIndex
		LDA !Attack
		BMI .Main
		ORA #$80 : STA !Attack
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA #$04 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x

		.Main
		LDY $3320,x
		LDA !SpriteAnimIndex
		CMP #$05 : BEQ .Landing
		CMP #$07 : BEQ .Landing

		.Hop
		LDA .WalkSpeed+$00,y
		STA $AE,x
		LDA !SpriteAnimTimer
		CMP #$0B
		BNE .NoLanding
		LDA #$F0 : STA $9E,x
		BRA .NoLanding

		.Landing
		LDA .WalkSpeed+$02,y
		STA $AE,x
		LDA $3330,x
		AND #$04
		BEQ .NoLanding
		LDA #$FE : STA !SpriteAnimTimer
		.NoLanding

		LDA !AttackTimer
		BEQ .StartChop

		.P1Detection
		LDA #$00
		JSR HITBOX
		JSL $03B664
		JSL $03B72B
		BCS .StartChop

		.P2Detection
		JSR P2Clipping
		JSL $03B72B
		BCS .StartChop
		RTS

		.StartChop
		LDA #$01 : STA !Attack
		LDA #$22 : STA !AttackTimer
		LDA #$08 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		BRA Chop

		.WalkSpeed
		db $14,$EC
		db $0E,$F2

	Chop:
		LDX !SpriteIndex
		STZ $AE,x
		LDY #$01
		LDA !AttackTimer
		CMP #$22-$05
		BCS .Hitbox
		INY
		CMP #$22-$09
		BCS .Hitbox
		INY
		CMP #$22-$0E
		BCS .Hitbox
		RTS

		.Hitbox
		TYA
		JSR HITBOX
		JSL $03B664
		JSL $03B72B
		BCC .P2
		JSL $00F5B7

		.P2
		JSR P2Clipping
		JSL $03B72B
		BCC .Return
		LDA !P2Invinc
		BNE .Return
		JSR HurtP2

		.Return
		RTS

	Jump:
		LDX !SpriteIndex
		BIT !Attack
		BMI +
		LDA #$80 : TSB !Attack
		LDA #$00
		LDY $3250,x
		CPY #$13
		BEQ ++
		CPY #$15
		BEQ $05
		BIT $3220,x
		BPL $01 : INC A
	++	STA $3320,x
		TAY
		LDA .JumpSpeed,y
		STA $AE,x
		LDA #$C0
		STA $9E,x
		LDA #$10 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		RTS

	+	LDA $3330,x
		AND #$04
		BEQ .Return
		STZ !AttackTimer
		STZ $AE,x

		.Return
		RTS

		.JumpSpeed
		db $20,$E0

	HurricaneJump:
		LDX !SpriteIndex
		LDA !Attack
		BMI .Main
		ORA #$80 : STA !Attack
		LDA #$11 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		LDA #$B0 : STA $9E,x
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA .Speed,y
		STA $AE,x

		.Main
		DEC $9E,x
		RTS

		.Speed
		db $08,$F8

	Hurricane:
		LDX !SpriteIndex
		LDA !Attack
		BMI .Main
		ORA #$80 : STA !Attack
		LDA #$0C : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x

		.Main
		LDY $3320,x
		LDA .Speed,y
		STA $AE,x
		LDA $3330,x
		AND #$04
		BEQ .Return
		STZ !AttackTimer
		LDA #$0F : STA !ShakeTimer
		LDA #$09 : STA !SPC4
		JSR RockDebris

		.Return
		RTS

		.Speed
		db $14,$EC


	Stuck:
		LDX !SpriteIndex
		LDA !Attack
		BMI .Main
		ORA #$80 : STA !Attack
		LDA #$12 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x

		.Main
		STZ $AE,x
		RTS


	HurtGround:
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		CMP #$14
		BEQ .Main
		LDA #$14 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x

		.Main
		BIT !Attack
		BMI .Bounce
		LDY $3320,x
		LDA .HurtSpeed,y
		STA $AE,x
		RTS

		.Bounce
		LDA $3330,x
		AND #$04
		BEQ .Return
		STZ $AE,x

		.Return
		RTS

		.HurtSpeed
		db $F8,$08


	HurtAir:
		LDX !SpriteIndex
		LDA !Attack
		BMI .Main
		ORA #$80 : STA !Attack
		LDA #$15 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		BIT $9E,x
		BPL .Main
		STZ $9E,x

		.Main
		LDA $3330,x
		AND #$04
		BEQ .Return
		STZ !AttackTimer
		LDA $AE,x
		JSR Halve
		STA $AE,x
		LDA #$E0 : STA $9E,x

		.Return
		RTS


	Defeated:
		LDX !SpriteIndex
		LDA !Phase
		BMI .Main
		ORA #$80 : STA !Phase
		LDA #$01 : STA !AnimToggle	; > Standard NMI without animations
		LDA #$80 : STA !SPC3
		LDA #$60 : STA $32D0,x
		LDA $3330,x
		AND #$04
		BNE +
		LDA #$15 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
	+	STZ !Attack

		.Main
		LDA !Attack
		CMP #$02
		BNE .Wait
		LDA $3250,x
		CMP #$15
		BNE .OnScreen
		LDA $3220,x
		CMP #$40
		BCC .OnScreen
		STZ $3230,x

		.OnScreen
		LDA $3330,x
		AND #$04
		BEQ .Physics
		BRA .Jump

		.Wait
		LDA $3330,x
		AND #$04
		BEQ .Air
		LDA #$16 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		STZ $AE,x

		.Air
		LDA $32D0,x
		BNE .Physics
		LDA !Attack
		BEQ .Talk
		LDA #$02 : STA !Attack
		LDA #$10 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		DEC $3280,x
		STZ $3320,x

		.Jump
		LDA #$40 : STA $AE,x
		LDA #$B0 : STA $9E,x
		BRA .Physics

		.Talk
		LDA #$01 : STA !Attack
		LDA #$06 : STA !MsgTrigger

		.Physics
		JSL $01802A			; Apply speed
		JMP Battle_Graphics


	Halve:
		BMI .Negative
		LSR A
		RTS

		.Negative
		EOR #$FF
		LSR A
		EOR #$FF
		RTS

	Spawn:
		LDA !RNG
		AND #$03
		BIT $94				;\
		BPL +				; |
		AND #$01			; | Don't spawn right next to players
		BRA ++				; |
	+	ORA #$02			; |
		++				;/

		TAY

		LDA .MinionTable+$00,y
		STA $3220,x
		LDA .MinionTable+$04,y
		STA $3250,x
		LDA .MinionTable+$08,y
		STA $3210,x
		LDA .MinionTable+$0C,y
		STA $3240,x
		LDA #$02 : STA !NewSpriteNum,x
		LDA #$36 : STA $3200,x
		LDA #$08 : STA $3230,x
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$88 : STA !ExtraBits,x	;/
		STZ !ClaimedGFX
		LDA #$01 : STA !SpriteAnimIndex
		LDA .MinionTable+$10,y
		STA $3320,x
		LDA .MinionTable+$14,y
		STA $AE,x
		LDA .MinionTable+$18,y
		STA $9E,x
		LDA #$20 : STA !RexAI
		LDA .MinionTable+$1C,y
		STA !RexMovementFlags
		LDA !Difficulty
		AND #$03 : CMP #$02
		BNE .EasyNormal
		LDA #$60 : STA !RexAI
		LDA .MinionTable+$20,y
		STA !RexMovementFlags

		.EasyNormal
		RTS

		.MinionTable
		db $EC,$EC,$04,$04		; $00, Xlo
		db $13,$13,$15,$15		; $04, Xhi
		db $70,$50,$70,$50		; $08, Ylo
		db $01,$01,$01,$01		; $0C, Yhi
		db $00,$00,$01,$01		; $10, Direction
		db $00,$14,$00,$EC		; $14, X speed
		db $00,$E0,$00,$E0		; $18, Y speed
		db $00,$08,$00,$08		; $1C, Rex movement flags (Easy/Normal)
		db $00,$48,$00,$48		; $20, Rex movement flags (Insane)
		; Each column represent a spawn point.

	Interaction1:
		LDA !Attack
		AND #$7F
		CMP #$04
		BNE .BodyHitbox
		LDA !SpriteAnimIndex
		SEC : SBC #$0C
		CLC : ADC #$05
		JSR HITBOX
		JSL $03B664
		JSL $03B72B
		BCS .HurtP1
		RTS

		.BodyHitbox
		LDA !MarioAnim
		BEQ $01 : RTS
		LDA #$04
		JSR HITBOX
		JSL $03B664
		JSL $03B72B
		BCS .Contact
		RTS

		.HurtP1
		SEP #$20
		LDA !Attack
		AND #$7F
		CMP #$06 : BEQ +
		CMP #$07 : BEQ +
		JSL $00F5B7
	+	RTS

		.Contact
		LDA $3240,x
		XBA
		LDA $3210,x
		REP #$20
		STA $00
		SEC : SBC $96
		BMI .HurtP1
		CMP #$0028
		SEP #$20
		BCC .HurtP1

		BIT !MarioYSpeed		;\ No stomping with upwards speed
		BPL $01 : RTS			;/
		JSL $01AA33			; Give Mario some bounce
		JSL $01AB99+$05			; Display contact GFX (ignore offscreen check)
		LDA !InvincTimer
		BEQ .HurtBoss
		LDA #$02 : STA !SPC1		; > Spin jump on spiky enemy sound
		RTS

		.HurtBoss
		LDA !Difficulty
		AND #$03 : TAY
		LDA InvincTime,y
		STA !InvincTimer
		LDA #$28 : STA !SPC4		; > OW! sound
		LDA !Attack : AND #$7F
		CMP #$02 : BEQ +
		CMP #$03 : BEQ +
		LDA #$06 : STA !Attack
		LDA #$0F : STA !AttackTimer
		BRA .EndContact
	+	LDA #$07 : STA !Attack
		LDA #$7F : STA !AttackTimer

		.EndContact
		DEC !HP
		LDA !HP
		BEQ .Die
		BMI .Die
		RTS

		.Die
		LDA #$02 : STA !Phase
		RTS


	Interaction2:
		LDA !Attack
		AND #$7F
		CMP #$04
		BNE .BodyHitbox
		LDA !SpriteAnimIndex
		SEC : SBC #$0C
		CLC : ADC #$05
		JSR HITBOX
		JSR P2Clipping
		JSL $03B72B
		BCS .HurtP2
		RTS

		.BodyHitbox
		LDA #$04
		JSR HITBOX
		JSR P2Clipping
		JSL $03B72B
		BCS .Contact
		RTS

		.HurtP2
		SEP #$20
		LDA !P2Invinc
		BNE +
		LDA !Attack
		AND #$7F
		CMP #$06 : BEQ +
		CMP #$07 : BEQ +
		JSR HurtP2
	+	RTS

		.Contact
		LDA $3240,x
		XBA
		LDA $3210,x
		REP #$20
		STA $00
		SEC : SBC !P2YPosLo
		BMI .HurtP2
		CMP #$0028
		SEP #$20
		BCC .HurtP2

		BIT !P2YSpeed			;\ No stomping with upwards speed
		BPL $01 : RTS			;/
		JSR P2Bounce			; > Bounce player 2
		JSR P2ContactGFX		; > Display contact GFX
		LDA !InvincTimer
		BEQ .HurtBoss
		LDA #$02 : STA !SPC1		; > Spin jump on spiky enemy sound
		RTS

		.HurtBoss
		LDA !Difficulty
		AND #$03 : TAY
		LDA InvincTime,y
		STA !InvincTimer
		LDA #$28 : STA !SPC4		; > OW! sound
		LDA !Attack : AND #$7F
		CMP #$02 : BEQ +
		CMP #$03 : BEQ +
		LDA #$06 : STA !Attack
		LDA #$0F : STA !AttackTimer
		BRA .EndContact
	+	LDA #$07 : STA !Attack
		LDA #$7F : STA !AttackTimer

		.EndContact
		DEC !HP
		LDA !HP
		BEQ .Die
		BMI .Die
		RTS

		.Die
		LDA #$02 : STA !Phase
		RTS

		InvincTime:
		db $3F,$4F,$6F


	RockDebris:
		; First rock
		JSL $02A9DE			;\ Get sprite slot
		BPL $01 : RTS			;/

		STZ $01
		LDA $3320,x
		BEQ +
		LDA #$EC : STA $00
		DEC $01
		BRA ++
		+
		LDA #$10 : STA $00
		++

		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y			; | Set Xpos
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y			;/
		LDA $3210,x			;\
		CLC : ADC #$08			; |
		STA $3210,y			; | 8px below (back up in scratch RAM to save processing)
		STA $06				; |
		LDA $3240,x			; |
		ADC #$00			; |
		STA $3240,y			; |
		STA $07				;/
		LDA #$07			;\  > Custom sprite number
		TYX				; | > X = new sprite index
		STA !NewSpriteNum,x		; |
		LDA #$36			; | > Acts like
		STA $3200,x			; |
		LDA #$08			; | > MAIN routine
		STA $3230,x			; |
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08			; |
		STA !ExtraBits,x		;/
		LDA #$5F : STA $32D0,x		; > Life timer
		LDA #$E0 : STA $33D0,x		; > GFX tile
		LDA #$C8 : STA $9E,x		; > Y speed
		LDA #$C0 : STA $BE,x		; > Behaviour
		LDA #$FF			;\
		STA $32E0,x			; | Don't interact
		STA $35F0,x			;/
		LDA #$F8 : STA $AE,x		;\
		LDA #$29 : STA $33C0,x		; |
		LDA #$01 : STA $3410,x		; | Projectile settings
		LDA #$03 : STA $33E0,x		; |
		LDA #$08 : STA $3310,x		;/
		LDX !SpriteIndex		; > X = sprite index

		; Second rock
		JSL $02A9DE			;\ Get sprite slot
		BPL $01 : RTS			;/

		STZ $01
		LDA $3320,x
		BEQ +
		LDA #$F4 : STA $00
		DEC $01
		BRA ++
		+
		LDA #$18 : STA $00
		++

		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y			; | Nearby Xpos
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y			;/
		LDA $06 : STA $3210,y		;\ Spawn at backed-up Ypos
		LDA $07 : STA $3240,y		;/
		LDA #$07			;\  > Custom sprite number
		TYX				; | > X = new sprite index
		STA !NewSpriteNum,x		; |
		LDA #$36			; | > Acts like
		STA $3200,x			; |
		LDA #$08			; | > MAIN routine
		STA $3230,x			; |
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08			; |
		STA !ExtraBits,x		;/
		LDA #$5F : STA $32D0,x		; > Life timer
		LDA #$E0 : STA $33D0,x		; > GFX tile
		LDA #$01 : STA $3340,x		; > Start at a different frame
		LDA #$C8 : STA $9E,x		; > Y speed
		LDA #$C0 : STA $BE,x		; > Behaviour
		LDA #$FF			;\
		STA $32E0,x			; | Don't interact
		STA $35F0,x			;/
		LDA #$08 : STA $AE,x		;\
		LDA #$29 : STA $33C0,x		; |
		LDA #$01 : STA $3410,x		; | Projectile settings
		LDA #$03 : STA $33E0,x		; |
		LDA #$08 : STA $3310,x		;/
		LDX !SpriteIndex		; > X = sprite index

		.Return
		RTS

		.XDisp1
		db $00,$10
		.XDisp2
		db $10,$00


	HITBOX:
		STA $04
		ASL A
		CLC : ADC $04
		ASL #2
		LDY $3320,x
		BEQ $03 : CLC : ADC #$06
		TAY
		LDA $3220,x
		CLC : ADC.w .Data+0,y
		STA $04
		LDA $3250,x
		ADC.w .Data+1,y
		STA $0A
		LDA $3210,x
		CLC : ADC.w .Data+2,y
		STA $05
		LDA $3240,x
		ADC.w .Data+3,y
		STA $0B
		LDA .Data+4,y : STA $06
		LDA .Data+5,y : STA $07
		RTS

	.Data
		.SightRight		; 00
		dw $0000,$FFE0
		db $30,$30
		.SightLeft
		dw $FFE0,$FFE0
		db $30,$30

		.ChopRight1		; 01
		dw $FFF0,$FFE0
		db $10,$10
		.ChopLeft1
		dw $0008,$FFE0
		db $10,$10
		.ChopRight2		; 02
		dw $FFF0,$FFE8
		db $40,$28
		.ChopLeft2
		dw $FFE0,$FFE8
		db $40,$28
		.ChopRight3		; 03
		dw $0010,$FFE0
		db $10,$20
		.ChopLeft3
		dw $FFF0,$FFE0
		db $10,$20

		.BodyRight		; 04
		dw $FFF8,$FFE4
		db $18,$30
		.BodyLeft
		dw $FFF8,$FFE4
		db $18,$30

		.HurricaneRight0	; 05
		dw $FFF8,$FFF0
		db $2F,$1F
		.HurricaneLeft0
		dw $FFE8,$FFF0
		db $2F,$1F
		.HurricaneRight1	; 06
		dw $FFF8,$FFE0
		db $27,$2F
		.HurricaneLeft1
		dw $FFE8,$FFE0
		db $27,$2F
		.HurricaneRight2	; 07
		dw $FFE8,$FFE8
		db $2F,$27
		.HurricaneLeft2
		dw $FFF8,$FFE8
		db $2F,$27
		.HurricaneRight3	; 08
		dw $FFF8,$FFF0
		db $1F,$2F
		.HurricaneLeft3
		dw $FFF8,$FFF0
		db $1F,$2F




	; Captain Warrior anim format:
	; - Tilemap	(2 bytes)
	; - Body dynamo	(2 bytes)
	; - Axe dynamo	(2 bytes)
	; - Frame count	(1 byte)
	; - Next anim	(1 byte)

	Anim:
		.Idle0			; 00
		dw Tilemaps_Idle0
		dw Body_Idle0
		dw Axe_Idle
		db $0C,$01
		.Idle1			; 01
		dw Tilemaps_Idle1
		dw Body_Idle1
		dw Axe_Idle
		db $0C,$02
		.Idle2			; 02
		dw Tilemaps_Idle0
		dw Body_Idle0
		dw Axe_Idle
		db $0C,$03
		.Idle3			; 03
		dw Tilemaps_Idle2
		dw Body_Idle2
		dw Axe_Idle
		db $0C,$00

		.PrepChop0		; 04
		dw Tilemaps_PrepChop
		dw Body_PrepChop0
		dw Axe_PrepChop0
		db $0C,$05
		.PrepChop1		; 05
		dw Tilemaps_PrepChop
		dw Body_PrepChop1
		dw Axe_PrepChop1
		db $FF,$06
		.PrepChop2		; 06
		dw Tilemaps_PrepChop
		dw Body_PrepChop0
		dw Axe_PrepChop0
		db $0C,$07
		.PrepChop3		; 07
		dw Tilemaps_PrepChop
		dw Body_PrepChop2
		dw Axe_PrepChop2
		db $FF,$04

		.Chop0			; 08
		dw Tilemaps_Chop0
		dw Body_Chop0
		dw Axe_Chop0
		db $05,$09
		.Chop1			; 09
		dw Tilemaps_Chop1
		dw Body_Chop1
		dw Axe_Chop1
		db $04,$0A
		.Chop2			; 0A
		dw Tilemaps_Chop2
		dw Body_Chop2
		dw Axe_Chop2
		db $05,$0B
		.Chop3			; 0B
		dw Tilemaps_Chop3
		dw Body_Chop3
		dw Axe_Chop3
		db $14,$00

		.Hurricane0		; 0C
		dw Tilemaps_Hurricane0
		dw Body_Hurricane0
		dw Axe_Hurricane0
		db $04,$0D
		.Hurricane1		; 0D
		dw Tilemaps_Hurricane1
		dw Body_Hurricane1
		dw Axe_Hurricane1
		db $04,$0E
		.Hurricane2		; 0E
		dw Tilemaps_Hurricane2
		dw Body_Hurricane2
		dw Axe_Hurricane2
		db $04,$0F
		.Hurricane3		; 0F
		dw Tilemaps_Hurricane3
		dw Body_Hurricane3
		dw Axe_Hurricane3
		db $04,$0C

		.Jump			; 10
		dw Tilemaps_Jump
		dw Body_Jump
		dw Axe_Jump
		db $03,$10

		.HurricaneJump		; 11
		dw Tilemaps_HurricaneJump
		dw Body_HurricaneJump
		dw Axe_HurricaneJump
		db $03,$11

		.Stuck0			; 12
		dw Tilemaps_Stuck
		dw Body_Stuck0
		dw Axe_Stuck0
		db $0C,$13
		.Stuck1			; 13
		dw Tilemaps_Stuck
		dw Body_Stuck1
		dw Axe_Stuck1
		db $18,$12

		.Hurt0			; 14
		dw Tilemaps_Hurt0
		dw Body_Hurt0
		dw Axe_Hurt
		db $FF,$14
		.Hurt1			; 15
		dw Tilemaps_Hurt1
		dw Body_Hurt1
		dw Axe_HurricaneJump
		db $FF,$15

		.Defeated		; 16
		dw Tilemaps_Defeated
		dw Body_Defeated
		dw Axe_Defeated
		db $FF,$16

		.Channel		; 17
		dw Tilemaps_Channel
		dw Body_Channel
		dw Axe_Channel
		db $FF,$17


	Tilemaps:
		.Idle0
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F8,$F0,$C8	; Axe
		db $28,$00,$F0,$C9
		db $28,$F8,$F8,$D8
		db $28,$00,$F8,$D9
		.Idle1
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F8,$F0,$C8	; Axe
		db $28,$00,$F0,$C9
		db $28,$F8,$F8,$D8
		db $28,$00,$F8,$D9
		.Idle2
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F8,$F1,$C8	; Axe
		db $28,$00,$F1,$C9
		db $28,$F8,$F9,$D8
		db $28,$00,$F9,$D9

		.PrepChop
		dw $0028
		db $2C,$F8,$E8,$C0	; Body
		db $2C,$00,$E8,$C1
		db $2C,$F8,$F0,$D0
		db $2C,$00,$F0,$D1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F8,$E0,$C8	; Axe
		db $28,$00,$E0,$C9
		db $28,$F8,$F0,$E8
		db $28,$00,$F0,$E9

		.Chop0
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$08,$E0,$C2
		db $2C,$F8,$F0,$E0
		db $2C,$08,$F0,$E2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6
		db $28,$F8,$E8,$C8	; Axe
		db $28,$08,$E8,$CA
		db $28,$F8,$F8,$E8
		db $28,$08,$F8,$EA
		.Chop1
		dw $0044
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$00,$00,$C4
		db $28,$08,$E8,$C8	; Dynamic axe
		db $28,$08,$F0,$D8
		db $28,$08,$00,$CA
		db $29,$D8,$E8,$8A	; Psuedo-dynamic axe
		db $29,$E8,$E8,$8C
		db $29,$F8,$E8,$8E
		db $29,$D8,$F0,$9A
		db $29,$E8,$F0,$9C
		db $29,$F8,$F0,$9E
		db $29,$D8,$00,$BA
		db $29,$E8,$00,$BC
		db $29,$F8,$00,$BE
		.Chop2
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$08,$E0,$C2
		db $2C,$F8,$F0,$E0
		db $2C,$08,$F0,$E2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6
		db $28,$E8,$E8,$C8	; Axe
		db $28,$F8,$E8,$CA
		db $28,$E8,$F8,$E8
		db $28,$F8,$F8,$EA
		.Chop3
		dw $0020
		db $28,$F3,$F0,$C8	; Axe
		db $28,$F3,$F8,$D8
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$08,$E0,$C2
		db $2C,$F8,$F0,$E0
		db $2C,$08,$F0,$E2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6

		.Jump
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$00,$E1,$C8	; Axe
		db $28,$08,$E1,$C9
		db $28,$00,$E9,$D8
		db $28,$08,$E9,$D9

		.HurricaneJump
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$08,$E0,$C2
		db $2C,$F8,$F0,$E0
		db $2C,$08,$F0,$E2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6
		db $28,$09,$EE,$C8	; Axe
		db $28,$11,$EE,$C9
		db $28,$09,$F6,$D8
		db $28,$11,$F6,$D9

		.Hurricane0		; Axe connects at top-right
		dw $0020
		db $2C,$F8,$F0,$C0	; Body
		db $2C,$08,$F0,$C2
		db $2C,$F8,$00,$E0
		db $2C,$08,$00,$E2
		db $28,$08,$F0,$C8	; Axe
		db $28,$18,$F0,$CA
		db $28,$08,$00,$E8
		db $28,$18,$00,$EA
		.Hurricane1		; Axe connects at top-left
		dw $0024
		db $2C,$F8,$F0,$C0	; Body
		db $2C,$08,$F0,$C2
		db $2C,$F8,$00,$E0
		db $2C,$08,$00,$E2
		db $28,$F8,$E0,$C8	; Axe
		db $28,$08,$E0,$CA
		db $28,$10,$E0,$CB
		db $28,$F8,$F0,$E8
		db $28,$10,$F0,$EB
		.Hurricane2		; Axe connects at bottom-left
		dw $0028
		db $2C,$F8,$F0,$C0	; Body
		db $2C,$08,$F0,$C2
		db $2C,$F8,$00,$E0
		db $2C,$08,$00,$E2
		db $28,$E8,$E8,$C8	; Axe
		db $28,$F8,$E8,$CA
		db $28,$00,$E8,$CB
		db $28,$E8,$F8,$E8
		db $28,$E8,$00,$EC
		db $28,$F8,$00,$EE
		.Hurricane3		; Axe connects at bottom-right
		dw $0024
		db $2C,$F8,$F0,$C0	; Body
		db $2C,$08,$F0,$C2
		db $2C,$F8,$00,$E0
		db $2C,$08,$00,$E2
		db $28,$F0,$00,$C8	; Axe
		db $28,$08,$00,$CB
		db $28,$F0,$10,$E8
		db $28,$00,$10,$EA
		db $28,$08,$10,$EB

		.Stuck
		dw $0024
		db $2C,$F8,$E8,$C0	; Body
		db $2C,$00,$E8,$C1
		db $2C,$F8,$F0,$D0
		db $2C,$00,$F0,$D1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F0,$F8,$C8	; Axe
		db $28,$F0,$00,$D8
		db $28,$00,$00,$DA

		.Hurt0
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$05,$E0,$C8	; Axe
		db $28,$0D,$E0,$C9
		db $28,$05,$E8,$D8
		db $28,$0D,$E8,$D9

		.Hurt1
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$08,$E0,$C2
		db $2C,$F8,$F0,$E0
		db $2C,$08,$F0,$E2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6
		db $28,$08,$EF,$C8	; Axe
		db $28,$10,$EF,$C9
		db $28,$08,$F7,$D8
		db $28,$10,$F7,$D9

		.Defeated
		dw $0028
		db $2C,$F8,$E8,$C0	; Body
		db $2C,$08,$E8,$C2
		db $2C,$F8,$F0,$D0
		db $2C,$08,$F0,$D2
		db $2C,$F8,$00,$C4
		db $2C,$08,$00,$C6
		db $28,$F7,$F8,$C8	; Axe
		db $28,$FF,$F8,$C9
		db $28,$F7,$00,$D8
		db $28,$FF,$00,$D9

		.Channel
		dw $0028
		db $2C,$F8,$E0,$C0	; Body
		db $2C,$00,$E0,$C1
		db $2C,$F8,$F0,$E0
		db $2C,$00,$F0,$E1
		db $2C,$F8,$00,$C4
		db $2C,$00,$00,$C5
		db $28,$F0,$F0,$C8	; Axe
		db $28,$00,$F0,$CA
		db $28,$F0,$F8,$D8
		db $28,$00,$F8,$DA


	; Dynamo tables, copied into VR2 upload table.
	macro Dynamo(Tiles, Address, DestVRAM)
		dw <Tiles>*$20
		dl <Address>
		dw <DestVRAM>*$10+$5000			; < move everything to $0C0-$0FF area
	endmacro

	Body:
		.Idle0
		dw ..End-..Start
		..Start
		%Dynamo(3, $338000, $1C0)
		%Dynamo(3, $338200, $1D0)
		%Dynamo(3, $338400, $1E0)
		%Dynamo(3, $338600, $1F0)
		%Dynamo(3, $338800, $1C4)
		%Dynamo(3, $338A00, $1D4)
		..End
		.Idle1
		dw ..End-..Start
		..Start
		%Dynamo(3, $338060, $1C0)
		%Dynamo(3, $338260, $1D0)
		%Dynamo(3, $338460, $1E0)
		%Dynamo(3, $338660, $1F0)
		%Dynamo(3, $338860, $1C4)
		%Dynamo(3, $338A60, $1D4)
		..End
		.Idle2
		dw ..End-..Start
		..Start
		%Dynamo(3, $3380C0, $1C0)
		%Dynamo(3, $3382C0, $1D0)
		%Dynamo(3, $3384C0, $1E0)
		%Dynamo(3, $3386C0, $1F0)
		%Dynamo(3, $3388C0, $1C4)
		%Dynamo(3, $338AC0, $1D4)
		..End

		.PrepChop0
		dw ..End-..Start
		..Start
		%Dynamo(3, $3394C0, $1C0)
		%Dynamo(3, $3396C0, $1D0)
		%Dynamo(3, $3398C0, $1E0)
		%Dynamo(3, $339AC0, $1C4)
		%Dynamo(3, $339CC0, $1D4)
		..End
		.PrepChop1
		dw ..End-..Start
		..Start
		%Dynamo(3, $339520, $1C0)
		%Dynamo(3, $339720, $1D0)
		%Dynamo(3, $339920, $1E0)
		%Dynamo(3, $339B20, $1C4)
		%Dynamo(3, $339D20, $1D4)
		..End
		.PrepChop2
		dw ..End-..Start
		..Start
		%Dynamo(3, $339580, $1C0)
		%Dynamo(3, $339780, $1D0)
		%Dynamo(3, $339980, $1E0)
		%Dynamo(3, $339B80, $1C4)
		%Dynamo(3, $339D80, $1D4)
		..End

		.Chop0
		dw ..End-..Start
		..Start
		%Dynamo(4, $339E00, $1C0)
		%Dynamo(4, $33A000, $1D0)
		%Dynamo(4, $33A200, $1E0)
		%Dynamo(4, $33A400, $1F0)
		%Dynamo(4, $33A600, $1C4)
		%Dynamo(4, $33A800, $1D4)
		..End
		.Chop1
		dw ..End-..Start
		..Start
		%Dynamo(3, $339E80, $1C0)
		%Dynamo(3, $33A080, $1D0)
		%Dynamo(3, $33A280, $1E0)
		%Dynamo(3, $33A480, $1F0)
		%Dynamo(2, $33A6C0, $1C4)
		%Dynamo(2, $33A8C0, $1D4)
		..End
		.Chop2
		dw ..End-..Start
		..Start
		%Dynamo(4, $339F00, $1C0)
		%Dynamo(4, $33A100, $1D0)
		%Dynamo(4, $33A300, $1E0)
		%Dynamo(4, $33A500, $1F0)
		%Dynamo(4, $33A700, $1C4)
		%Dynamo(4, $33A900, $1D4)
		..End
		.Chop3
		dw ..End-..Start
		..Start
		%Dynamo(4, $339F80, $1C0)
		%Dynamo(4, $33A180, $1D0)
		%Dynamo(4, $33A380, $1E0)
		%Dynamo(4, $33A580, $1F0)
		%Dynamo(4, $33A780, $1C4)
		%Dynamo(4, $33A980, $1D4)
		..End

		.Jump
		dw ..End-..Start
		..Start
		%Dynamo(3, $338120, $1C0)
		%Dynamo(3, $338320, $1D0)
		%Dynamo(3, $338520, $1E0)
		%Dynamo(3, $338720, $1F0)
		%Dynamo(3, $338920, $1C4)
		%Dynamo(3, $338B20, $1D4)
		..End

		.HurricaneJump
		dw ..End-..Start
		..Start
		%Dynamo(4, $338180, $1C0)
		%Dynamo(4, $338380, $1D0)
		%Dynamo(4, $338580, $1E0)
		%Dynamo(4, $338780, $1F0)
		%Dynamo(4, $338980, $1C4)
		%Dynamo(4, $338B80, $1D4)
		..End

		.Hurricane0
		dw ..End-..Start
		..Start
		%Dynamo(4, $338C00, $1C0)
		%Dynamo(4, $338E00, $1D0)
		%Dynamo(4, $339000, $1E0)
		%Dynamo(4, $339200, $1F0)
		..End
		.Hurricane1
		dw ..End-..Start
		..Start
		%Dynamo(4, $338C80, $1C0)
		%Dynamo(4, $338E80, $1D0)
		%Dynamo(4, $339080, $1E0)
		%Dynamo(4, $339280, $1F0)
		..End
		.Hurricane2
		dw ..End-..Start
		..Start
		%Dynamo(4, $338D00, $1C0)
		%Dynamo(4, $338F00, $1D0)
		%Dynamo(4, $339100, $1E0)
		%Dynamo(4, $339300, $1F0)
		..End
		.Hurricane3
		dw ..End-..Start
		..Start
		%Dynamo(4, $338D80, $1C0)
		%Dynamo(4, $338F80, $1D0)
		%Dynamo(4, $339180, $1E0)
		%Dynamo(4, $339380, $1F0)
		..End

		.Stuck0
		dw ..End-..Start
		..Start
		%Dynamo(3, $339400, $1C0)
		%Dynamo(3, $339600, $1D0)
		%Dynamo(3, $339800, $1E0)
		%Dynamo(3, $339A00, $1C4)
		%Dynamo(3, $339C00, $1D4)
		..End
		.Stuck1
		dw ..End-..Start
		..Start
		%Dynamo(3, $339460, $1C0)
		%Dynamo(3, $339660, $1D0)
		%Dynamo(3, $339860, $1E0)
		%Dynamo(3, $339A60, $1C4)
		%Dynamo(3, $339C60, $1D4)
		..End

		.Hurt0
		dw ..End-..Start
		..Start
		%Dynamo(3, $33AA00, $1C0)
		%Dynamo(3, $33AC00, $1D0)
		%Dynamo(3, $33AE00, $1E0)
		%Dynamo(3, $33B000, $1F0)
		%Dynamo(3, $33B200, $1C4)
		%Dynamo(3, $33B400, $1D4)
		..End
		.Hurt1
		dw ..End-..Start
		..Start
		%Dynamo(4, $33AA60, $1C0)
		%Dynamo(4, $33AC60, $1D0)
		%Dynamo(4, $33AE60, $1E0)
		%Dynamo(4, $33B060, $1F0)
		%Dynamo(4, $33B260, $1C4)
		%Dynamo(4, $33B460, $1D4)
		..End

		.Defeated
		dw ..End-..Start
		..Start
		%Dynamo(4, $33ACE0, $1C0)
		%Dynamo(4, $33AEE0, $1D0)
		%Dynamo(4, $33B0E0, $1E0)
		%Dynamo(4, $33B2E0, $1C4)
		%Dynamo(4, $33B4E0, $1D4)
		..End

		.Channel
		dw ..End-..Start
		..Start
		%Dynamo(3, $33AB80, $1C0)
		%Dynamo(3, $33AD80, $1D0)
		%Dynamo(3, $33AF80, $1E0)
		%Dynamo(3, $33B180, $1F0)
		%Dynamo(3, $33B380, $1C4)
		%Dynamo(3, $33B580, $1D4)
		..End


	Axe:
		.Idle
		dw ..End-..Start
		..Start
		%Dynamo(4, $33B600, $1C8)
		%Dynamo(4, $33B800, $1D8)
		%Dynamo(4, $33BA00, $1E8)
		%Dynamo(4, $33BC00, $1F8)
		..End

		.PrepChop0
		dw ..End-..Start
		..Start
		%Dynamo(3, $33BC60, $1C8)
		%Dynamo(3, $33BE60, $1D8)
		%Dynamo(3, $33C060, $1E8)
		%Dynamo(3, $33C260, $1F8)
		..End
		.PrepChop1
		dw ..End-..Start
		..Start
		%Dynamo(3, $33C200, $1C8)
		%Dynamo(3, $33C400, $1D8)
		%Dynamo(3, $33C600, $1E8)
		%Dynamo(3, $33C800, $1F8)
		..End
		.PrepChop2
		dw ..End-..Start
		..Start
		%Dynamo(3, $33C460, $1C8)
		%Dynamo(3, $33C660, $1D8)
		%Dynamo(3, $33C860, $1E8)
		%Dynamo(3, $33CA60, $1F8)
		..End

		.Chop0
		dw ..End-..Start
		..Start
		%Dynamo(4, $33CF00, $1C8)
		%Dynamo(4, $33D100, $1D8)
		%Dynamo(4, $33D300, $1E8)
		%Dynamo(4, $33D500, $1F8)
		..End

		.Chop1init
		dw ..End-..Start
		..Start
		%Dynamo(6, $33CC00, $28A)
		%Dynamo(6, $33CE00, $29A)
		%Dynamo(6, $33D000, $2AA)
		%Dynamo(6, $33D200, $2BA)
		%Dynamo(6, $33D400, $2CA)
		%Dynamo(2, $33CA00, $2E0)
		%Dynamo(2, $33CC00, $2F0)
		%Dynamo(2, $33D860, $2E2)
		%Dynamo(2, $33CC00, $2F2)
		%Dynamo(2, $33DA60, $2E4)
		%Dynamo(2, $33CC00, $2F4)
		..End

		.Chop1
		dw ..End-..Start
		..Start
		%Dynamo(2, $33CCC0, $1C8)
		%Dynamo(2, $33CEC0, $1D8)
		%Dynamo(2, $33D0C0, $1E8)
		%Dynamo(2, $33D2C0, $1CA)
		%Dynamo(2, $33D4C0, $1DA)
		..End
		.Chop2
		dw ..End-..Start
		..Start
		%Dynamo(4, $33CD80, $1C8)
		%Dynamo(4, $33CF80, $1D8)
		%Dynamo(4, $33D180, $1E8)
		%Dynamo(4, $33D380, $1F8)
		..End
		.Chop3
		dw ..End-..Start
		..Start
		%Dynamo(2, $33D6A0, $1C8)
		%Dynamo(2, $33D8A0, $1D8)
		%Dynamo(2, $33DAA0, $1E8)
		..End

		.Jump
		dw ..End-..Start
		..Start
		%Dynamo(3, $33BC00, $1C8)
		%Dynamo(3, $33BE00, $1D8)
		%Dynamo(3, $33C000, $1E8)
		..End

		.HurricaneJump
		dw ..End-..Start
		..Start
		%Dynamo(3, $33B680, $1C8)
		%Dynamo(3, $33B880, $1D8)
		%Dynamo(3, $33BA80, $1E8)
		..End

		.Hurricane0
		dw ..End-..Start
		..Start
		%Dynamo(4, $33B6E0, $1C8)
		%Dynamo(4, $33B8E0, $1D8)
		%Dynamo(4, $33BAE0, $1E8)
		%Dynamo(4, $33BCE0, $1F8)
		..End
		.Hurricane1
		dw ..End-..Start
		..Start
		%Dynamo(5, $33B760, $1C8)
		%Dynamo(5, $33B960, $1D8)
		%Dynamo(5, $33BB60, $1E8)
		%Dynamo(5, $33BD60, $1F8)
		..End
		.Hurricane2
		dw ..End-..Start
		..Start
		%Dynamo(5, $33BEC0, $1C8)
		%Dynamo(5, $33C0C0, $1D8)
		%Dynamo(2, $33C2C0, $1E8)
		%Dynamo(2, $33C4C0, $1F8)
		%Dynamo(4, $33C4C0, $1EC)	; Duplicated to fit in
		%Dynamo(4, $33C6C0, $1FC)
		..End
		.Hurricane3
		dw ..End-..Start
		..Start
		%Dynamo(5, $33BF60, $1C8)
		%Dynamo(5, $33C160, $1D8)
		%Dynamo(5, $33C360, $1E8)
		%Dynamo(5, $33C560, $1F8)
		..End

		.Stuck0
		dw ..End-..Start
		..Start
		%Dynamo(2, $33C780, $1C8)
		%Dynamo(4, $33C980, $1D8)
		%Dynamo(4, $33CB80, $1E8)
		..End
		.Stuck1
		dw ..End-..Start
		..Start
		%Dynamo(2, $33C900, $1C8)
		%Dynamo(4, $33CB00, $1D8)
		%Dynamo(4, $33CD00, $1E8)
		..End

		.Hurt
		dw ..End-..Start
		..Start
		%Dynamo(3, $33D600, $1C8)
		%Dynamo(3, $33D800, $1D8)
		%Dynamo(3, $33DA00, $1E8)
		..End

		.Defeated
		dw ..End-..Start
		..Start
		%Dynamo(3, $33D780, $1C8)
		%Dynamo(3, $33D980, $1D8)
		%Dynamo(3, $33DB80, $1E8)
		..End

		.Channel
		dw ..End-..Start
		..Start
		%Dynamo(4, $33D700, $1C8)
		%Dynamo(4, $33D900, $1D8)
		%Dynamo(4, $33DB00, $1E8)
		..End


	BodyPal:
		dw $7FFF,$0000
		dw $05F9,$16BA
		dw $175C,$013C
		dw $025F,$26DF
		dw $14C7,$256D
		dw $3634,$4ED8
		dw $635C,$0000
		dw $0000
	AxePal:
		dw $7FFF,$0000
		dw $252B,$35AE
		dw $4E74,$5AD7
		dw $6F7B,$08CB
		dw $0D31,$0575
		dw $0DB8,$05F9
		dw $15FA,$16BA
		dw $175C


; Main GFX start at $338000.
; Axe GFX start at $33B600.

	UPDATE_GFX:
		JSL !GetVRAM
		REP #$30
		LDA ($0C) : STA $00
		LDY #$0000
		INC $0C
		INC $0C
	-	LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$00,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$02,x
		INY
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$03,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$05,x
		INY #2
		CPY $00
		BEQ +
		TXA
		CLC : ADC #$0007
		TAX
		BRA -

	+	TXA
		CLC : ADC #$0007
		TAX
		LDA ($0E) : STA $00
		LDY #$0000
		INC $0E
		INC $0E
	-	LDA ($0E),y
		STA !VRAMbase+!VRAMtable+$00,x
		INY #2
		LDA ($0E),y
		STA !VRAMbase+!VRAMtable+$02,x
		INY
		LDA ($0E),y
		STA !VRAMbase+!VRAMtable+$03,x
		INY #2
		LDA ($0E),y
		STA !VRAMbase+!VRAMtable+$05,x
		INY #2
		CPY $00
		BEQ +
		TXA
		CLC : ADC #$0007
		TAX
		BRA -

		+
		SEP #$30
		LDX !SpriteIndex
		RTS



	namespace off