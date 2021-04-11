

	namespace CaptainWarrior

	!Phase		= !BossData+0
	!HP		= !BossData+1
	!Attack		= !BossData+2
	!AttackTimer	= !BossData+3

	!InvincTimer	= $3420,x
	!AttackMemory	= $6DF5,x		; < Technically an OW sprite table, but who cares


	INIT:
		PHB : PHK : PLB			; > Always do this. Just... do it.
		JSL !GetCGRAM			;\
		BCS +				; |
		LDA.b #!VRAMbank		; |
		PHA : PLB			; |
		REP #$20			; |
		LDA #$001E			; |
		STA.w !CGRAMtable+$00,y		; |
		STA.w !CGRAMtable+$06,y		; | Upload palette
		LDA.w #BodyPal			; |
		STA.w !CGRAMtable+$02,y		; |
		LDA.w #AxePal			; |
		STA.w !CGRAMtable+$08,y		; |
		SEP #$20			; |
		LDA.b #BodyPal>>16		; |
		STA.w !CGRAMtable+$04,y		; |
		STA.w !CGRAMtable+$0A,y		; |
		LDA #$E1			; |
		STA.w !CGRAMtable+$05,y		; |
		LDA #$F1			; |
		STA.w !CGRAMtable+$0B,y		; |
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
		LDA #$80 : STA !SpriteTile,x
		LDA #$01 : STA !SpriteProp,x

		LDA !ExtraBits,x
		AND #$04
		BNE .Return

		REP #$20
		STZ $3230+$00 : STZ $3230+$02
		STZ $3230+$04 : STZ $3230+$06
		STZ $3230+$08 : STZ $3230+$0A
		STZ $3230+$0C : STZ $3230+$0E
		SEP #$20
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
		LDA !Phase : BMI +
		ORA #$80 : STA !Phase
		LDA.b #Body_Idle0 : STA $0C	;\
		LDA.b #Body_Idle0>>8 : STA $0D	; |
		LDA.b #Axe_Idle : STA $0E	; | idle GFX
		LDA.b #Axe_Idle>>8 : STA $0F	; |
		JSR UPDATE_GFX			;/
		PLB
		RTL

	+	JSL SUB_HORZ_POS_Long
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
		LDA !P2Status-$80 : BNE +
		LDA !P2Character-$80
		CMP #$03 : BEQ ++
	+	LDA !P2Status : BNE +
		LDA !P2Character
		CMP #$03 : BEQ ++
	+	LDA #$03 : STA !MsgTrigger
		BRA .Return

	++	LDA #$07 : STA !MsgTrigger	; Special dialogue with Leeway


		.Return
		JMP Battle_Graphics


	Battle:
		LDA !Phase : BMI .Main
		ORA #$80 : STA !Phase
		LDA #$37 : STA !SPC3			; > battle theme
		LDA.b #Body_Idle0 : STA $0C		;\
		LDA.b #Body_Idle0>>8 : STA $0D		; |
		STZ $0E					; | upload idle body GFX
		STZ $0F					; |
		JSR UPDATE_GFX				;/

		LDA !GFX_Dynamic : PHA			;\
		LDA #$00 : STA !GFX_Dynamic		; |
		REP #$30				; |
		LDY.w #!File_CaptainWarrior_Axe		; | load big axe frame
		LDA.w #Axe_Chop1init : STA $0C		; |
		JSL !UpdateFromFile			; |
		SEP #$30				; |
		PLA : STA !GFX_Dynamic			;/
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

		JSR Interaction


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

		BIT $3280,x : BPL +
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
		JSL LOAD_TILEMAP_Long
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
		JSL SUB_HORZ_POS_Long
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
		SEC : JSL !PlayerClipping
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
		SEC : JSL !PlayerClipping
		BCC .Return
		JSL !HurtPlayers

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
		JSL SUB_HORZ_POS_Long
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
		CMP $5D : BNE .OnScreen
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
		BIT !P2XPosLo-$80 : BPL +	;\
		BIT !P2XPosLo : BPL +		; |
		AND #$01			; | Don't spawn right next to players if it can be helped
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
		LDA #$05 : STA !ExtraProp1,x
		LDA #$08 : STA !ExtraProp2,x

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

	Interaction:
		LDA !Attack
		AND #$7F
		CMP #$04
		BNE .BodyHitbox
		LDA !SpriteAnimIndex
		SEC : SBC #$0C
		CLC : ADC #$05
		JSR HITBOX
		SEC : JSL !PlayerClipping
		BCC .Return
		PHA
		LDA !Attack
		AND #$7F
		CMP #$06 : BEQ .ReturnP
		CMP #$07 : BEQ .ReturnP
		PLA
		JSL !HurtPlayers

		.Return
		RTS

		.ReturnP
		PLA
		RTS

		.BodyHitbox
		LDA #$04
		JSR HITBOX
		SEC : JSL !PlayerClipping
		BCC .Return

		.Contact
		STA $0F
		LDY #$00
		LSR $0F
		BCS .Process
	-	LDY #$80
		LSR $0F
		BCC .Return

		.Process
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80,y
		BMI .HurtPlayer16
		CMP #$0018
		SEP #$20
		BCC .HurtPlayer
		LDA !P2YSpeed-$80,y : BMI -
		JSL P2Bounce_Long
		LDA !InvincTimer : BEQ .HurtBoss
		LDA #$02 : STA !SPC1		; > Spin jump on spiky enemy sound
		RTS

.HurtPlayer16	SEP #$20
.HurtPlayer	LDA !InvincTimer : BNE -
		TYA
		CLC
		ROL #2
		INC A
		JSL !HurtPlayers
		BRA -

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
		BEQ .Die
		BPL -
	.Die	LDA #$02 : STA !Phase
		JMP -


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
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F8,$F0,$C8	; Axe
		db $3F,$00,$F0,$C9
		db $3F,$F8,$F8,$D8
		db $3F,$00,$F8,$D9
		.Idle1
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F8,$F0,$C8	; Axe
		db $3F,$00,$F0,$C9
		db $3F,$F8,$F8,$D8
		db $3F,$00,$F8,$D9
		.Idle2
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F8,$F1,$C8	; Axe
		db $3F,$00,$F1,$C9
		db $3F,$F8,$F9,$D8
		db $3F,$00,$F9,$D9

		.PrepChop
		dw $0028
		db $3D,$F8,$E8,$C0	; Body
		db $3D,$00,$E8,$C1
		db $3D,$F8,$F0,$D0
		db $3D,$00,$F0,$D1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F8,$E0,$C8	; Axe
		db $3F,$00,$E0,$C9
		db $3F,$F8,$F0,$E8
		db $3F,$00,$F0,$E9

		.Chop0
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$08,$E0,$C2
		db $3D,$F8,$F0,$E0
		db $3D,$08,$F0,$E2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6
		db $3F,$F8,$E8,$C8	; Axe
		db $3F,$08,$E8,$CA
		db $3F,$F8,$F8,$E8
		db $3F,$08,$F8,$EA
		.Chop1
		dw $0044
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$00,$00,$C4
		db $3F,$08,$E8,$C8	; Dynamic axe
		db $3F,$08,$F0,$D8
		db $3F,$08,$00,$CA
		db $3F,$D8,$E8,$7A	; Psuedo-dynamic axe
		db $3F,$E8,$E8,$7C
		db $3F,$F8,$E8,$7E
		db $3F,$D8,$F0,$8A
		db $3F,$E8,$F0,$8C
		db $3F,$F8,$F0,$8E
		db $3F,$D8,$00,$AA
		db $3F,$E8,$00,$AC
		db $3F,$F8,$00,$AE

		.Chop2
		dw $0030
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$08,$E0,$C2
		db $3D,$F8,$F0,$E0
		db $3D,$08,$F0,$E2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6
		db $3F,$E8,$E8,$C8	; Axe
		db $3F,$F8,$E8,$CA
		db $3F,$E8,$F8,$E8
		db $3F,$F8,$F8,$EA
		db $3F,$E8,$00,$CC
		db $3F,$F8,$00,$CE
		.Chop3
		dw $0020
		db $3F,$F3,$F0,$C8	; Axe
		db $3F,$F3,$F8,$D8
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$08,$E0,$C2
		db $3D,$F8,$F0,$E0
		db $3D,$08,$F0,$E2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6

		.Jump
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$00,$E1,$C8	; Axe
		db $3F,$08,$E1,$C9
		db $3F,$00,$E9,$D8
		db $3F,$08,$E9,$D9

		.HurricaneJump
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$08,$E0,$C2
		db $3D,$F8,$F0,$E0
		db $3D,$08,$F0,$E2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6
		db $3F,$09,$EE,$C8	; Axe
		db $3F,$11,$EE,$C9
		db $3F,$09,$F6,$D8
		db $3F,$11,$F6,$D9

		.Hurricane0		; Axe connects at top-right
		dw $0020
		db $3D,$F8,$F0,$C0	; Body
		db $3D,$08,$F0,$C2
		db $3D,$F8,$00,$E0
		db $3D,$08,$00,$E2
		db $3F,$08,$F0,$C8	; Axe
		db $3F,$18,$F0,$CA
		db $3F,$08,$00,$E8
		db $3F,$18,$00,$EA
		.Hurricane1		; Axe connects at top-left
		dw $0024
		db $3D,$F8,$F0,$C0	; Body
		db $3D,$08,$F0,$C2
		db $3D,$F8,$00,$E0
		db $3D,$08,$00,$E2
		db $3F,$F8,$E0,$C8	; Axe
		db $3F,$08,$E0,$CA
		db $3F,$10,$E0,$CB
		db $3F,$F8,$F0,$E8
		db $3F,$10,$F0,$EB
		.Hurricane2		; Axe connects at bottom-left
		dw $0028
		db $3D,$F8,$F0,$C0	; Body
		db $3D,$08,$F0,$C2
		db $3D,$F8,$00,$E0
		db $3D,$08,$00,$E2
		db $3F,$E8,$E8,$C8	; Axe
		db $3F,$F8,$E8,$CA
		db $3F,$00,$E8,$CB
		db $3F,$E8,$F8,$E8
		db $3F,$E8,$00,$EC
		db $3F,$F8,$00,$EE
		.Hurricane3		; Axe connects at bottom-right
		dw $0024
		db $3D,$F8,$F0,$C0	; Body
		db $3D,$08,$F0,$C2
		db $3D,$F8,$00,$E0
		db $3D,$08,$00,$E2
		db $3F,$F0,$00,$C8	; Axe
		db $3F,$08,$00,$CB
		db $3F,$F0,$10,$E8
		db $3F,$00,$10,$EA
		db $3F,$08,$10,$EB

		.Stuck
		dw $0024
		db $3D,$F8,$E8,$C0	; Body
		db $3D,$00,$E8,$C1
		db $3D,$F8,$F0,$D0
		db $3D,$00,$F0,$D1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F0,$F8,$C8	; Axe
		db $3F,$F0,$00,$D8
		db $3F,$00,$00,$DA

		.Hurt0
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$05,$E0,$C8	; Axe
		db $3F,$0D,$E0,$C9
		db $3F,$05,$E8,$D8
		db $3F,$0D,$E8,$D9
		.Hurt1
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$08,$E0,$C2
		db $3D,$F8,$F0,$E0
		db $3D,$08,$F0,$E2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6
		db $3F,$08,$EF,$C8	; Axe
		db $3F,$10,$EF,$C9
		db $3F,$08,$F7,$D8
		db $3F,$10,$F7,$D9

		.Defeated
		dw $0028
		db $3D,$F8,$E8,$C0	; Body
		db $3D,$08,$E8,$C2
		db $3D,$F8,$F0,$D0
		db $3D,$08,$F0,$D2
		db $3D,$F8,$00,$C4
		db $3D,$08,$00,$C6
		db $3F,$F7,$F8,$C8	; Axe
		db $3F,$FF,$F8,$C9
		db $3F,$F7,$00,$D8
		db $3F,$FF,$00,$D9

		.Channel
		dw $0028
		db $3D,$F8,$E0,$C0	; Body
		db $3D,$00,$E0,$C1
		db $3D,$F8,$F0,$E0
		db $3D,$00,$F0,$E1
		db $3D,$F8,$00,$C4
		db $3D,$00,$00,$C5
		db $3F,$F0,$F0,$C8	; Axe
		db $3F,$00,$F0,$CA
		db $3F,$F0,$F8,$D8
		db $3F,$00,$F8,$DA



;
;
; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; 	cccssss-
; 	-ccccccc
; 	tttttttt
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; tttttttt:	tile number (shift left 4 then add VRAM offset)
;
;


	macro CompDyn(TileCount, TileNumber, Dest)
		db (<TileCount>*2)|((<TileNumber>&$07)<<5)
		db <TileNumber>>>3
		db <Dest>
	endmacro

	; Dynamo tables, copied into VR2 upload table.
	macro Dynamo(Tiles, TileNumber, DestVRAM)
		dw <Tiles>*$20
		dl <TileNumber>*$20
		dw <DestVRAM>*$10
	endmacro

	Body:
		.Idle0
		db ..End-..Start
		..Start
		%CompDyn(3, $000, $00)
		%CompDyn(3, $010, $10)
		%CompDyn(3, $020, $20)
		%CompDyn(3, $030, $30)
		%CompDyn(3, $040, $04)
		%CompDyn(3, $050, $14)
		..End
		.Idle1
		db ..End-..Start
		..Start
		%CompDyn(3, $003, $00)
		%CompDyn(3, $013, $10)
		%CompDyn(3, $023, $20)
		%CompDyn(3, $033, $30)
		%CompDyn(3, $043, $04)
		%CompDyn(3, $053, $14)
		..End
		.Idle2
		db ..End-..Start
		..Start
		%CompDyn(3, $006, $00)
		%CompDyn(3, $016, $10)
		%CompDyn(3, $026, $20)
		%CompDyn(3, $036, $30)
		%CompDyn(3, $046, $04)
		%CompDyn(3, $056, $14)
		..End

		.PrepChop0
		db ..End-..Start
		..Start
		%CompDyn(3, $0A6, $00)
		%CompDyn(3, $0B6, $10)
		%CompDyn(3, $0C6, $20)
		%CompDyn(3, $0D6, $04)
		%CompDyn(3, $0E6, $14)
		..End
		.PrepChop1
		db ..End-..Start
		..Start
		%CompDyn(3, $0A9, $00)
		%CompDyn(3, $0B9, $10)
		%CompDyn(3, $0C9, $20)
		%CompDyn(3, $0D9, $04)
		%CompDyn(3, $0E9, $14)
		..End
		.PrepChop2
		db ..End-..Start
		..Start
		%CompDyn(3, $0AC, $00)
		%CompDyn(3, $0BC, $10)
		%CompDyn(3, $0CC, $20)
		%CompDyn(3, $0DC, $04)
		%CompDyn(3, $0EC, $14)
		..End

		.Chop0
		db ..End-..Start
		..Start
		%CompDyn(4, $0F0, $00)
		%CompDyn(4, $100, $10)
		%CompDyn(4, $110, $20)
		%CompDyn(4, $120, $30)
		%CompDyn(4, $130, $04)
		%CompDyn(4, $140, $14)
		..End
		.Chop1
		db ..End-..Start
		..Start
		%CompDyn(3, $0F4, $00)
		%CompDyn(3, $104, $10)
		%CompDyn(3, $114, $20)
		%CompDyn(3, $124, $30)
		%CompDyn(2, $134, $04)
		%CompDyn(2, $144, $14)
		..End
		.Chop2
		db ..End-..Start
		..Start
		%CompDyn(4, $0F8, $00)
		%CompDyn(4, $108, $10)
		%CompDyn(4, $118, $20)
		%CompDyn(4, $128, $30)
		%CompDyn(4, $138, $04)
		%CompDyn(4, $148, $14)
		..End
		.Chop3
		db ..End-..Start
		..Start
		%CompDyn(4, $0FC, $00)
		%CompDyn(4, $10C, $10)
		%CompDyn(4, $11C, $20)
		%CompDyn(4, $12C, $30)
		%CompDyn(4, $13C, $04)
		%CompDyn(4, $14C, $14)
		..End

		.Jump
		db ..End-..Start
		..Start
		%CompDyn(3, $009, $00)
		%CompDyn(3, $019, $10)
		%CompDyn(3, $029, $20)
		%CompDyn(3, $039, $30)
		%CompDyn(3, $049, $04)
		%CompDyn(3, $059, $14)
		..End

		.HurricaneJump
		db ..End-..Start
		..Start
		%CompDyn(4, $00C, $00)
		%CompDyn(4, $01C, $10)
		%CompDyn(4, $02C, $20)
		%CompDyn(4, $03C, $30)
		%CompDyn(4, $04C, $04)
		%CompDyn(4, $05C, $14)
		..End

		.Hurricane0
		db ..End-..Start
		..Start
		%CompDyn(4, $060, $00)
		%CompDyn(4, $070, $10)
		%CompDyn(4, $080, $20)
		%CompDyn(4, $090, $30)
		..End
		.Hurricane1
		db ..End-..Start
		..Start
		%CompDyn(4, $064, $00)
		%CompDyn(4, $074, $10)
		%CompDyn(4, $084, $20)
		%CompDyn(4, $094, $30)
		..End
		.Hurricane2
		db ..End-..Start
		..Start
		%CompDyn(4, $068, $00)
		%CompDyn(4, $078, $10)
		%CompDyn(4, $088, $20)
		%CompDyn(4, $098, $30)
		..End
		.Hurricane3
		db ..End-..Start
		..Start
		%CompDyn(4, $06C, $00)
		%CompDyn(4, $07C, $10)
		%CompDyn(4, $08C, $20)
		%CompDyn(4, $09C, $30)
		..End

		.Stuck0
		db ..End-..Start
		..Start
		%CompDyn(3, $0A0, $00)
		%CompDyn(3, $0B0, $10)
		%CompDyn(3, $0C0, $20)
		%CompDyn(3, $0D0, $04)
		%CompDyn(3, $0E0, $14)
		..End
		.Stuck1
		db ..End-..Start
		..Start
		%CompDyn(3, $0A3, $00)
		%CompDyn(3, $0B3, $10)
		%CompDyn(3, $0C3, $20)
		%CompDyn(3, $0D3, $04)
		%CompDyn(3, $0E3, $14)
		..End

		.Hurt0
		db ..End-..Start
		..Start
		%CompDyn(3, $150, $00)
		%CompDyn(3, $160, $10)
		%CompDyn(3, $170, $20)
		%CompDyn(3, $180, $30)
		%CompDyn(3, $190, $04)
		%CompDyn(3, $1A0, $14)
		..End
		.Hurt1
		db ..End-..Start
		..Start
		%CompDyn(4, $153, $00)
		%CompDyn(4, $163, $10)
		%CompDyn(4, $173, $20)
		%CompDyn(4, $183, $30)
		%CompDyn(4, $193, $04)
		%CompDyn(4, $1A3, $14)
		..End

		.Defeated
		db ..End-..Start
		..Start
		%CompDyn(4, $167, $00)
		%CompDyn(4, $177, $10)
		%CompDyn(4, $187, $20)
		%CompDyn(4, $197, $04)
		%CompDyn(4, $1A7, $14)
		..End

		.Channel
		db ..End-..Start
		..Start
		%CompDyn(3, $15C, $00)
		%CompDyn(3, $16C, $10)
		%CompDyn(3, $17C, $20)
		%CompDyn(3, $18C, $30)
		%CompDyn(3, $19C, $04)
		%CompDyn(3, $1AC, $14)
		..End


	Axe:
		.Idle
		db ..End-..Start
		..Start
		%CompDyn(4, $000, $08)
		%CompDyn(4, $010, $18)
		%CompDyn(4, $020, $28)
		%CompDyn(4, $030, $38)
		..End

		.PrepChop0
		db ..End-..Start
		..Start
		%CompDyn(3, $033, $08)
		%CompDyn(3, $043, $18)
		%CompDyn(3, $053, $28)
		%CompDyn(3, $063, $38)
		..End
		.PrepChop1
		db ..End-..Start
		..Start
		%CompDyn(3, $060, $08)
		%CompDyn(3, $070, $18)
		%CompDyn(3, $080, $28)
		%CompDyn(3, $090, $38)
		..End
		.PrepChop2
		db ..End-..Start
		..Start
		%CompDyn(3, $073, $08)
		%CompDyn(3, $083, $18)
		%CompDyn(3, $093, $28)
		%CompDyn(3, $0A3, $38)
		..End

		.Chop0
		db ..End-..Start
		..Start
		%CompDyn(4, $0C8, $08)
		%CompDyn(4, $0D8, $18)
		%CompDyn(4, $0E8, $28)
		%CompDyn(4, $0F8, $38)
		..End

		.Chop1init
		dw ..End-..Start		; this one has to remain dw, all others should be db tho
		..Start
		%Dynamo(6, $0B0, $77A)		; this one should remain decompressed
		%Dynamo(6, $0C0, $78A)
		%Dynamo(6, $0D0, $79A)
		%Dynamo(6, $0E0, $7AA)
		%Dynamo(6, $0F0, $7BA)
		..End

		.Chop1
		db ..End-..Start
		..Start
		%CompDyn(2, $0B6, $08)
		%CompDyn(2, $0C6, $18)
		%CompDyn(2, $0D6, $28)
		%CompDyn(2, $0E6, $0A)
		%CompDyn(2, $0F6, $1A)
		..End
		.Chop2
		db ..End-..Start
		..Start
		%CompDyn(4, $0BC, $08)
		%CompDyn(4, $0CC, $18)
		%CompDyn(4, $0DC, $28)
		%CompDyn(4, $0EC, $38)
		%CompDyn(4, $0EC, $0C)	; duplicated source to fit in with tilemap
		%CompDyn(4, $0FC, $1C)
		..End
		.Chop3
		db ..End-..Start
		..Start
		%CompDyn(2, $105, $08)
		%CompDyn(2, $115, $18)
		%CompDyn(2, $125, $28)
		..End

		.Jump
		db ..End-..Start
		..Start
		%CompDyn(3, $030, $08)
		%CompDyn(3, $040, $18)
		%CompDyn(3, $050, $28)
		..End

		.HurricaneJump
		db ..End-..Start
		..Start
		%CompDyn(3, $004, $08)
		%CompDyn(3, $014, $18)
		%CompDyn(3, $024, $28)
		..End

		.Hurricane0
		db ..End-..Start
		..Start
		%CompDyn(4, $007, $08)
		%CompDyn(4, $017, $18)
		%CompDyn(4, $027, $28)
		%CompDyn(4, $037, $38)
		..End
		.Hurricane1
		db ..End-..Start
		..Start
		%CompDyn(5, $00B, $08)
		%CompDyn(5, $01B, $18)
		%CompDyn(5, $02B, $28)
		%CompDyn(5, $03B, $38)
		..End
		.Hurricane2
		db ..End-..Start
		..Start
		%CompDyn(5, $046, $08)
		%CompDyn(5, $056, $18)
		%CompDyn(2, $066, $28)
		%CompDyn(2, $076, $38)
		%CompDyn(4, $076, $2C)	; duplicated source to fit in with tilemap
		%CompDyn(4, $086, $3C)
		..End
		.Hurricane3
		db ..End-..Start
		..Start
		%CompDyn(5, $04B, $08)
		%CompDyn(5, $05B, $18)
		%CompDyn(5, $06B, $28)
		%CompDyn(5, $07B, $38)
		..End

		.Stuck0
		db ..End-..Start
		..Start
		%CompDyn(2, $08C, $08)
		%CompDyn(4, $09C, $18)
		%CompDyn(4, $0AC, $28)
		..End
		.Stuck1
		db ..End-..Start
		..Start
		%CompDyn(2, $098, $08)
		%CompDyn(4, $0A8, $18)
		%CompDyn(4, $0B8, $28)
		..End

		.Hurt
		db ..End-..Start
		..Start
		%CompDyn(3, $100, $08)
		%CompDyn(3, $110, $18)
		%CompDyn(3, $120, $28)
		..End

		.Defeated
		db ..End-..Start
		..Start
		%CompDyn(3, $10C, $08)
		%CompDyn(3, $11C, $18)
		%CompDyn(3, $12C, $28)
		..End

		.Channel
		db ..End-..Start
		..Start
		%CompDyn(4, $108, $08)
		%CompDyn(4, $118, $18)
		%CompDyn(4, $128, $28)
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
		REP #$30
		LDY.w #!File_CaptainWarrior
		JSL !DecompFromFile
		LDA $0E : STA $0C
		LDY.w #!File_CaptainWarrior_Axe
		JSL !DecompFromFile
		SEP #$30
		LDX !SpriteIndex
		RTS



	namespace off