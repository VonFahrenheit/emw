



CaptainWarrior:

	namespace CaptainWarrior

	!Temp = 0
	%def_anim(CW_Idle, 4)
	%def_anim(CW_Prep, 4)
	%def_anim(CW_Chop, 4)
	%def_anim(CW_Jump, 1)
	%def_anim(CW_SpinJump, 1)
	%def_anim(CW_Spin, 4)
	%def_anim(CW_Stuck, 2)
	%def_anim(CW_Channel, 1)
	%def_anim(CW_Hurt, 2)
	%def_anim(CW_Defeat, 1)


	!CW_HP			= $BE

	!CW_Phase		= $3280
	!CW_Attack		= $3290
	!CW_AttackMemory	= $32A0
	!CW_InvincTimer		= $32B0
	!CW_PrevAnim		= $32C0

	!CW_AttackTimer		= $32D0

	!CW_Minion1		= $3500
	!CW_Minion2		= $3510





	INIT:
		PHB : PHK : PLB						; bank wrapper start

		REP #$20						;\
		STZ $3230+$00 : STZ $3230+$02				; |
		STZ $3230+$04 : STZ $3230+$06				; |
		STZ $3230+$08 : STZ $3230+$0A				; | despawn all other sprites
		STZ $3230+$0C : STZ $3230+$0E				; |
		SEP #$20						; |
		LDA #$08 : STA $3230,x					;/ > go to MAIN

		STZ !DynamicList+$00					;\
		STZ !DynamicList+$02					; |
		STZ !DynamicList+$04					; |
		STZ !DynamicList+$06					; |
		STZ !DynamicList+$08					; |
		STZ !DynamicList+$0A					; |
		STZ !DynamicList+$0C					; |
		STZ !DynamicList+$0E					; | clear dynamic list
		STZ !DynamicList+$10					; |
		STZ !DynamicList+$12					; |
		STZ !DynamicList+$14					; |
		STZ !DynamicList+$16					; |
		STZ !DynamicList+$18					; |
		STZ !DynamicList+$1A					; |
		STZ !DynamicList+$1C					; |
		STZ !DynamicList+$1E					;/
		STZ !DynamicTile					; clear dynamic tile claims

		REP #$20
		LDA.w #.RockDynamo : STA $0C
		SEP #$20
		LDY.b #!File_Sprite_BG_1
		CLC : JSL !UpdateFromFile




		JSL !GetCGRAM						;\
		LDA.b #!VRAMbank					; |
		PHA : PLB						; |
		REP #$20						; |
		LDA #$001E						; |
		STA.w !CGRAMtable+$00,y					; |
		STA.w !CGRAMtable+$06,y					; |
		LDA.w #BodyPal : STA.w !CGRAMtable+$02,y		; | palette to CGRAM
		LDA.w #AxePal : STA.w !CGRAMtable+$08,y			; |
		SEP #$20						; |
		LDA.b #BodyPal>>16					; |
		STA.w !CGRAMtable+$04,y					; |
		STA.w !CGRAMtable+$0A,y					; |
		LDA #$C1 : STA.w !CGRAMtable+$05,y			; |
		LDA #$D1 : STA.w !CGRAMtable+$0B,y			; |
		PHK : PLB						;/
		LDX #$1D						;\
	-	LDA.w BodyPal,x : STA !ShaderInput+($C1*2),x		; | palette to shader input
		LDA.w AxePal,x : STA !ShaderInput+($D1*2),x		; |
		DEX : BPL -						;/
		LDA #$01						;\
		STA !ShaderRowDisable+$C				; | shader protection
		STA !ShaderRowDisable+$D				;/

		LDX !SpriteIndex					; X = sprite index
		LDA #$0D : JSL GET_SQUARE : BCS +			;\
		STZ $3230,x						; |
		PLB							; | get dynamic tiles
		RTL							; |
		+							;/

		JSL SUB_HORZ_POS					;\ face players
		TYA : STA $3320,x					;/
		LDA #$04 : STA $3330,x					; start on ground
		LDA !Difficulty						;\
		AND #$03						; | HP
		TAY							; |
		LDA.w DATA_BaseHP,y : STA !CW_HP,x			;/

		LDA !ExtraBits,x					;\ return if NPC mode
		AND #$04 : BNE .Return					;/

		.Return
		PLB							; bank wrapper end
		RTL							; return


		.RockDynamo
		dw ..end-..start
		..start
		%FileDyn(4, $07A, $7FC0)
		..end



	MAIN:
		PHB : PHK : PLB						; bank wrapper start


; debug: frame control
;	LDA $3280,x : STA !SpriteAnimIndex
;	STZ !SpriteAnimTimer
;	LDA $16
;	LSR #2
;	AND #$03 : BEQ +
;	CMP #$03 : BEQ +
;	CMP #$01
;	BEQ $02 : LDA #$FF
;	CLC : ADC !SpriteAnimIndex
;	BMI ++
;	CMP #!Temp : BCC +++
;	LDA #$00
;	BRA +++
;++	LDA #!Temp-1
;+++	STA $3280,x
;+	JMP GRAPHICS




		LDA $3230,x						;\
		SEC : SBC #$08						; | lock
		ORA $9D							; |
		BNE LOCK_SPRITE						;/

		%decreg(!CW_InvincTimer)

		LDA !CW_Phase,x						;\
		ASL A							; |
		CMP.b #.PhasePtr_end-.PhasePtr				; | execute pointer
		BCC $02 : LDA #$00					; |
		TAX							; |
		JMP (.PhasePtr,x)					;/

		.PhasePtr
		dw Intro			; 0
		dw Battle			; 1
		dw Defeated			; 2
		..end


	LOCK_SPRITE:
		JMP GRAPHICS

	Intro:
		LDX !SpriteIndex					; X = sprite index
		LDA !ExtraBits,x					;\ check mode
		AND #$04 : BEQ .Normal					;/

		.NPC							;\
		JSL SUB_HORZ_POS					; |
		TYA : STA $3320,x					; | NPC mode code
		STZ !SpriteAnimTimer					; |
		JMP GRAPHICS						;/

		.Normal							;\
		LDA !CW_Phase,x : BMI ..main				; |
		..init							; | normal mode init
		ORA #$80 : STA !CW_Phase,x				; |
		LDA #$80 : STA !SPC3					; |
		..main							;/
		LDA $1A : BNE .Return					;\
		LDA $1B							; | start at camera = 0x1400
		CMP #$14 : BNE .Return					;/
	STZ !EnableHScroll
		LDA #$01 : STA !CW_Phase,x				; next phase
		LDA !P2Status-$80 : BNE +				;\
		LDA !P2Character-$80					; |
		CMP #$03 : BEQ ..leeway					; |
	+	LDA !P2Status : BNE +					; | normal dialogue
		LDA !P2Character					; |
		CMP #$03 : BEQ ..leeway					; |
	+	REP #$20						; |
		LDA.w #!MSG_CaptainWarrior_Fight1_Intro			; |
		STA !MsgTrigger						; |
		SEP #$20						; |
		BRA .Return						;/

		..leeway						;\
		REP #$20						; |
		LDA.w #!MSG_CaptainWarrior_Fight1_Leeway		; | leeway dialogue
		STA !MsgTrigger						; |
		SEP #$20						;/


		.Return							;\ jump to GRAPHICS
		JMP GRAPHICS						;/


	Battle:
		LDX !SpriteIndex					; X = sprite index
		LDA !MsgTrigger
		ORA !MsgTrigger+1 : BEQ .Process
		JMP GRAPHICS
		.Process


		LDA !CW_Phase,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Phase,x				; | battle init
		LDA #$37 : STA !SPC3					; |
		JMP GRAPHICS						;/

		.Main
		LDA !CW_HP,x						;\
		BEQ ..dead						; |
		BPL ..alive						; | defeated if HP < 1
		..dead							; |
		LDA #$02 : STA !CW_Phase,x				; |
		STZ $3330,x						; > remove collision
		JMP Defeated						;/
		..alive


		.Minion1						;\
		LDA !CW_Minion1,x : BEQ ..init				; |
		TAX							; |
		DEX							; |
		LDA $3230,x : BEQ ..spawn				; |
		BRA .Minion2						; | check status of minion 1
		..init							; |
		LDX #$10						; |
	-	DEX							; |
		LDA $3230,x : BNE -					; |
		..spawn							;/
		JSR Spawn						; spawn
		LDA !RNG						;\
		EOR #$01						; | make sure both don't spawn at the same spot
		STA !RNG						;/
		INX							;\
		TXA							; | save index + 1
		LDX !SpriteIndex					; |
		STA !CW_Minion1,x					;/

		.Minion2
		LDA !Difficulty						;\
		AND #$03						; | only spawn the second minion on insane
		CMP #$02 : BNE .Boss					;/
		LDX !SpriteIndex					;\
		LDA !CW_Minion2,x : BEQ ..init				; |
		TAX							; |
		DEX							; |
		LDA $3230,x : BEQ ..spawn				; |
		BRA .Boss						; | check status of minion 2
		..init							; |
		LDX #$10						; |
	-	DEX							; |
		LDA $3230,x : BNE -					; |
		..spawn							;/
		JSR Spawn						; spawn
		INX							;\
		TXA							; | save index + 1
		LDX !SpriteIndex					; |
		STA !CW_Minion2,x					;/


		.Boss
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_AttackTimer,x : BNE .HandleAttack

		.UpdateAttack						;\
		LDA !CW_Attack,x					; |
		AND #$7F : TAY						; |
		LDA DATA_NextAttack,y					; |
		CMP #$FF : BEQ .RandomizeAttack				; | get attack (non-random)
		STA !CW_Attack,x					; |
		AND #$7F : TAY						; |
		LDA DATA_AttackTime,y : STA !CW_AttackTimer,x		; |
		BRA .HandleAttack					;/

		.RandomizeAttack					;\
		LDA !RNG						; |
		AND #$07						; |
		TAY							; |
	-	LDA DATA_RandomAttack,y					; |
		CMP !CW_AttackMemory,x : BNE +				; |
		DEY : BPL -						; | get random attack (can't do same twice in a row)
		LDY #$07						; |
		BRA -							; |
	+	STA !CW_Attack,x					; |
		STA !CW_AttackMemory,x					; |
		TAY							; |
		LDA DATA_AttackTime,y : STA !CW_AttackTimer,x		;/

		.HandleAttack						;\
		LDA !CW_Attack,x					; |
		ASL A							; | execute attack pointer
		TAX							; |
		JSR (DATA_AttackPtr,x)					;/
		JSL !SpriteApplySpeed					; apply speed



	INTERACTION:
		REP #$20
		LDA !CW_Attack,x
		AND #$007F
		ASL A
		TAY
		LDA DATA_BodyHitbox,y : JSL LOAD_HITBOX

		.Attack
		LDA !CW_InvincTimer,x : BNE ..nocontact
		JSL P2Attack : BCC ..nocontact
		LDA !P2Hitbox1XSpeed-$80,y
		JSR Halve
		STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		JSR Hurt
		BRA .Done
		..nocontact

		.Body
		LDA !CW_Attack,x
		AND #$7F
		CMP #$06 : BEQ ..nocontact
		CMP #$07 : BEQ ..nocontact
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		LDA !CW_InvincTimer,x : BEQ ..hurt
		LDA #$02 : STA !SPC1
		BRA .Done
		..hurt
		LDA !SpriteYSpeed,x : BPL +
		STZ !SpriteYSpeed,x
	+	JSR Hurt
		..nocontact

		.Fireball
		LDA !CW_InvincTimer,x : BNE .Done
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		JSR Hurt
		..nocontact

		.Done



	GRAPHICS:
		LDA !MsgTrigger						;\
		ORA !MsgTrigger+1					; |
		BEQ +							; | freeze animation while text box is open
		DEC !SpriteAnimTimer					; |
		+							;/


		LDA !SpriteAnimIndex : STA $00				;\
		ASL A							; |
		ADC $00							; |
		ASL A							; | increment and check attack timer
		TAY							; |
		LDA !SpriteAnimTimer					; |
		INC A							; |
		CMP.w ANIM+4,y : BNE .SameAnim				;/
		.NewAnim						;\
		LDA.w ANIM+5,y : STA !SpriteAnimIndex			; |
		STA $00							; |
		ASL A							; | get new anim
		ADC $00							; |
		ASL A							; |
		TAY							; |
		LDA #$00						;/
		.SameAnim						;\
		STA !SpriteAnimTimer					; |
		REP #$20						; | get tilemap
		LDA.w ANIM+0,y : STA $04				; |
		SEP #$20						;/
		LDA !SpriteAnimIndex					;\
		CMP !CW_PrevAnim,x					; |
		STA !CW_PrevAnim,x					; |
		BEQ .SkipUpload						; |
		REP #$20						; | update GFX if new anim
		LDA.w ANIM+2,y : STA $0C				; |
		SEP #$20						; |
		LDY.b #!File_CaptainWarrior				; |
		JSL LOAD_SQUARE_DYNAMO					;/
		.SkipUpload						;\
		LDA !CW_InvincTimer,x : BEQ .Draw			; | draw check
		AND #$06 : BNE .Draw					;/
		PLB							; bank wrapper end
		RTL							; return

		.Draw							;\
		JSL SETUP_SQUARE					; | draw dynamic
		JSL LOAD_DYNAMIC					;/
		PLB							; bank wrapper end
		RTL							; return


	Hurt:
		LDA #$28 : STA !SPC4					; hurt SFX
		DEC !CW_HP,x						; -1 HP
		LDA !Difficulty						;\
		AND #$03						; | invinc time
		TAY							; |
		LDA DATA_InvincTime,y : STA !CW_InvincTimer,x		;/
		LDA $3330,x						;\ check air/ground
		AND #$04 : BEQ .Air					;/
		.Ground							;\
		LDA #$3F : STA !CW_AttackTimer,x			; | ground
		LDA #$06 : BRA .W					;/
		.Air							;\
		LDA #$7F : STA !CW_AttackTimer,x			; | air
		LDA #$07						;/
	.W	STA !CW_Attack,x					; set attack/hurt state
		RTS							; return


	DATA:
		.AttackPtr
		dw PrepChop			; 00
		dw Chop				; 01
		dw Jump				; 02
		dw HurricaneJump		; 03
		dw Hurricane			; 04
		dw Stuck			; 05
		dw HurtGround			; 06
		dw HurtAir			; 07

		.BodyHitbox
		dw HITBOX_Body			; 00
		dw HITBOX_Body			; 01
		dw HITBOX_Body			; 02
		dw HITBOX_Body			; 03
		dw HITBOX_BodySpin		; 04
		dw HITBOX_BodyStuck		; 05
		dw HITBOX_Body			; 06
		dw HITBOX_Body			; 07

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

		.BaseHP
		db $05,$05,$07			; EASY, NORMAL, INSANE

		.InvincTime
		db $3F,$4F,$6F

		.HopSpeed
		db $14,$EC

		.WalkSpeed
		db $0E,$F2

		.JumpSpeed
		db $20,$E0

		.HurricaneJumpSpeed
		db $08,$F8

		.HurricaneSpeed
		db $14,$EC

		.HurtSpeed
		db $F8,$08


	PrepChop:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; |
		JSL SUB_HORZ_POS					; | init facing + anim
		TYA : STA $3320,x					; |
		LDA #!CW_Prep : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		.Main							;/
		LDY $3320,x						; Y = facing dir
		LDA !SpriteAnimIndex					;\
		CMP #!CW_Prep+1 : BEQ .Hop				; | check for landing on these frames
		CMP #!CW_Prep+3 : BEQ .Hop				;/
		.Walk							;\
		LDA DATA_WalkSpeed,y : STA !SpriteXSpeed,x		; |
		LDA !SpriteAnimTimer					; | hop speed
		CMP #$07 : BNE .NoLanding				; |
		LDA #$F0 : STA !SpriteYSpeed,x				; |
		BRA .NoLanding						;/
		.Hop							;\
		LDA DATA_HopSpeed,y : STA !SpriteXSpeed,x		; |
		LDA $3330,x						; | ground speed
		AND #$04 : BEQ .NoLanding				; |
		LDA #$FE : STA !SpriteAnimTimer				; |
		.NoLanding						;/

		LDA !CW_AttackTimer,x					;\ start chop when timer = 1
		CMP #$01 : BEQ .StartChop				;/

		REP #$20						;\
		LDA.w #HITBOX_Sight : JSL LOAD_HITBOX			; | start chop if either player is within sight box
		SEC : JSL !PlayerClipping : BCS .StartChop		;/
		RTS							; return

		.StartChop						;\
		LDA #$01 : STA !CW_Attack,x				; |
		LDA #$22 : STA !CW_AttackTimer,x			; | go to chop
		LDA #!CW_Chop : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					;/
		LDA #$3D : STA !SPC4					; slash SFX


	Chop:
		LDX !SpriteIndex					; X = sprite index

		JSR .Dust


		STZ !SpriteXSpeed,x					; X speed = 0
		LDA !SpriteAnimIndex					;\
		CMP #!CW_Chop+3 : BCS .Return				; | must be in chop animation
		CMP #!CW_Chop+1 : BCC .Return				;/
		SBC #!CW_Chop+1						;\
		ASL A							; |
		TAY							; | get hitbox
		REP #$20						; |
		LDA .HitboxTable,y : JSL LOAD_HITBOX			;/
		SEC : JSL !PlayerClipping : BCC .Return			;\ hurt players on contact
		JSL !HurtPlayers					;/

		.Return
		RTS							; return

		.HitboxTable
		dw HITBOX_Chop0
		dw HITBOX_Chop1

		.Dust
		LDA !SpriteAnimIndex
		SEC : SBC #!CW_Chop
		CMP #$03 : BCS ..return
		ASL A
		ADC $3320,x
		TAY
		LDA ..xoffset,y : STA $00
		LDA #$0C : STA $01
		LDA !RNG
		AND #$0F
		SBC #$08
		ADC ..xspeed,y
		STA $02
		EOR #$FF : INC A
		STA $04
		LDA !RNG
		LSR #4
		ORA ..yspeed,y
		STA $03
		EOR #$FF : INC A
		STA $05
		LDA #$F0 : STA $07
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		..return
		RTS
		..xoffset
		db $F8,$08
		db $08,$F8
		db $14,$EC
		..xspeed
		db $10,$F0
		db $10,$F0
		db $10,$F0
		..yspeed
		db $F8,$F8
		db $F8,$F8
		db $F0,$F0





	Jump:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; |
		LDA #$00						; |
		LDY $3250,x						; |
		CPY #$14 : BCC ..right					; |
		CPY #$15 : BCS ..left					; |
		BIT $3220,x : BPL ..right				; |
		..left							; | init dir + speed + anim
		INC A							; |
		..right							; |
		STA $3320,x						; |
		TAY							; |
		LDA DATA_JumpSpeed,y : STA !SpriteXSpeed,x		; |
		LDA #$C0 : STA !SpriteYSpeed,x				; |
		LDA #!CW_Jump : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		JMP JumpSmoke						; > init jump smoke
		.Main							;\
		LDA $3330,x						; |
		AND #$04 : BEQ .Return					; | landing speed
		STZ !CW_AttackTimer,x					; |
		STZ !SpriteXSpeed,x					;/
		.Return
		RTS							; return


	HurricaneJump:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; |
		LDA #!CW_SpinJump : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer					; | init speed + anim
		LDA #$B0 : STA !SpriteYSpeed,x				; |
		JSL SUB_HORZ_POS					; |
		TYA : STA $3320,x					; |
		LDA DATA_HurricaneJumpSpeed,y : STA !SpriteXSpeed,x	; |
		JSR JumpSmoke						; > init jump smoke
		.Main							;/
		DEC !SpriteYSpeed,x					; lower gravity
		RTS							; return


	Hurricane:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; | init anim
		LDA #!CW_Spin : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		.Main							;/
		LDY $3320,x						;\ X speed while descending
		LDA DATA_HurricaneSpeed,y : STA !SpriteXSpeed,x		;/
		LDA !SpriteAnimIndex					;\
		SEC : SBC #!CW_Spin					; |
		ASL A							; |
		TAY							; |
		REP #$20						; | hitbox + hurt
		LDA .HitboxTable,y : JSL LOAD_HITBOX			; |
		SEC : JSL !PlayerClipping : BCC ..nocontact		; |
		JSL !HurtPlayers					; |
		..nocontact						;/
		LDA $3330,x						;\
		AND #$04 : BEQ .Return					; |
		STZ !CW_AttackTimer,x					; | landing code
		LDA #$0F : STA !ShakeTimer				; |
		LDA #$09 : STA !SPC4					; | > dunk SFX
		JSR RockDebris						;/

		.Return
		RTS							; return

		.HitboxTable
		dw HITBOX_Hurricane0
		dw HITBOX_Hurricane1
		dw HITBOX_Hurricane2
		dw HITBOX_Hurricane3




	Stuck:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; | init anim
		LDA #!CW_Stuck : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		.Main							;/
		STZ !SpriteXSpeed,x					; X speed = 0
		RTS							; return


	HurtGround:
		LDX !SpriteIndex					; X = sprite index
		LDA !SpriteAnimIndex					;\
		CMP #!CW_Hurt : BEQ .Main				; |
		.Init							; | init anim
		LDA #!CW_Hurt : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		.Main							;/
		LDA $3330,x						;\ return if in midair
		AND #$04 : BEQ .Return					;/
		LDA !SpriteXSpeed,x : BEQ .Return			; return if X speed = 0
		JSL AccelerateX_Friction1				;\
		LDA $14							; |
		AND #$03 : BNE .Return					; | friction + smoke
		STZ $00							; |
		LDA #$0C : STA $01					; |
		LDA #!SmokeOffset+$03 : JSL SpawnExSprite		;/

		.Return
		RTS							; return


	HurtAir:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Attack,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Attack,x				; | anim
		LDA #!CW_Hurt+1 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		.Main							;/
		LDA $3330,x						;\
		AND #$04 : BEQ .Return					; |
		STZ !CW_AttackTimer,x					; |
		LDA !SpriteXSpeed,x					; | bounce on ground
		JSR Halve						; |
		STA !SpriteXSpeed,x					; |
		LDA #$E0 : STA !SpriteYSpeed,x				;/

		.Return
		RTS							; return


	Defeated:
		LDX !SpriteIndex					; X = sprite index
		LDA !CW_Phase,x : BMI .Main				;\
		.Init							; |
		ORA #$80 : STA !CW_Phase,x				; |
		LDA #$80 : STA !SPC3					; |
		LDA #$60 : STA !CW_AttackTimer,x			; |
		LDA $3330,x						; | init anim + music
		AND #$04 : BNE +					; |
		STZ !SpriteXSpeed,x					; > no knockback here
		LDA #!CW_Hurt+1 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
	+	STZ !CW_Attack,x					; |
		.Main							;/
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BEQ +
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		JMP GRAPHICS
		+


		LDA !CW_Attack,x					;\
		CMP #$02 : BNE .Wait					; |
		LDA $3250,x						; |
		CMP $5D : BNE .OnScreen					; |
		LDA $3220,x						; |
		CMP #$40 : BCC .OnScreen				; | jump away after speech is done
		STZ $3230,x						; |
		.OnScreen						; |
		LDA $3330,x						; |
		AND #$04 : BEQ .Physics					; |
		BRA .Jump						;/

		.Wait							;\
		LDA $3330,x						; |
		AND #$04 : BEQ .Air					; | defeat anim + no speed on ground
		LDA #!CW_Defeat : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		STZ !SpriteXSpeed,x					;/

		.Air							;\
		LDA !CW_AttackTimer,x : BNE .Physics			; |
		LDA !CW_Attack,x : BEQ .Talk				; |
		LDA #$02 : STA !CW_Attack,x				; | maintain jump
		LDA #!CW_Jump : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer					; |
		STZ $3320,x						;/

		.Jump							;\
		LDA #$40 : STA !SpriteXSpeed,x				; | start jump
		LDA #$B0 : STA !SpriteYSpeed,x				; |
		BRA .Physics						;/

		.Talk							;\
		LDA #$01 : STA !CW_Attack,x				; |
		REP #$20						; | defeat dialogue
		LDA.w #!MSG_CaptainWarrior_Fight1_Defeated		; |
		STA !MsgTrigger						; |
		SEP #$20						;/
		JMP GRAPHICS

		.Physics
		JSL !SpriteApplySpeed					; apply speed
		JMP GRAPHICS						; go to graphics


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
		SEC : LDA #$02
		JSL SpawnSprite : BPL .Process
		RTS
		.Process

		LDA !RNG						;\
		AND #$03						; |
		BIT !P2XPosLo-$80 : BPL +				; |
		BIT !P2XPosLo : BPL +					; | get RNG
		AND #$01						; | (don't spawn right next to players if it can be helped)
		BRA ++							; |
	+	ORA #$02						; |
		++							;/
		TYX							;\ index
		TAY							;/
		LDA .MinionTable+$00,y : STA !SpriteXLo,x		;\
		LDA .MinionTable+$04,y : STA !SpriteXHi,x		; | coords
		LDA .MinionTable+$08,y : STA !SpriteYLo,x		; |
		LDA .MinionTable+$0C,y : STA !SpriteYHi,x		;/
		LDA .MinionTable+$10,y : STA $3320,x			; dir
		LDA .MinionTable+$14,y : STA !SpriteXSpeed,x		; X speed
		LDA .MinionTable+$18,y : STA !SpriteYSpeed,x		; Y speed

		LDA #$08 : STA !ExtraProp2,x				; give rex a helmet
		LDA !Difficulty						;\
		AND #$03 : BEQ .Easy					; |
		.NormalInsane						; | unless on easy, also give rex a sword so it can chase
		LDA #$05 : STA !ExtraProp1,x				; |
		.Easy							;/
		RTS							; return

		.MinionTable
		db $EC,$EC,$04,$04		; $00, Xlo
		db $13,$13,$15,$15		; $04, Xhi
		db $70,$50,$70,$50		; $08, Ylo
		db $01,$01,$01,$01		; $0C, Yhi
		db $00,$00,$01,$01		; $10, Direction
		db $00,$14,$00,$EC		; $14, X speed
		db $00,$E0,$00,$E0		; $18, Y speed
		; Each column represent a spawn point.




	RockDebris:
		LDX #$07						;\
	-	LDA .Particle1,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_anim_add : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle2,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_anim_add : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle3,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle4,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle5,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle6,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		RTS

		.XDisp
		db $0C,$F4

		.Particle1
		db $FC			; X disp
		db $0C			; Y disp
		db $F8			; X speed
		db $E0			; Y speed
		db $00			; X acc
		db $18			; Y acc
		db $FC			; tile
		db $37			; prop
		.Particle2
		db $0C			; X disp
		db $0C			; Y disp
		db $08			; X speed
		db $E0			; Y speed
		db $00			; X acc
		db $18			; Y acc
		db $FC			; tile
		db $37			; prop
		.Particle3
		db $FC			; X disp
		db $0C			; Y disp
		db $F0			; X speed
		db $F8			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop
		.Particle4
		db $0C			; X disp
		db $0C			; Y disp
		db $10			; X speed
		db $F8			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop
		.Particle5
		db $FC			; X disp
		db $0C			; Y disp
		db $F8			; X speed
		db $F0			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop
		.Particle6
		db $0C			; X disp
		db $0C			; Y disp
		db $08			; X speed
		db $F0			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop



	JumpSmoke:
		LDX #$07
	-	LDA .Particle1,x : STA $00,x
		DEX : BPL -
		LDX !SpriteIndex
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		LDX #$07
	-	LDA .Particle2,x : STA $00,x
		DEX : BPL -
		LDX !SpriteIndex
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		RTS

		.Particle1
		db $FC			; X disp
		db $0C			; Y disp
		db $F8			; X speed
		db $FC			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop

		.Particle2
		db $0C			; X disp
		db $0C			; Y disp
		db $08			; X speed
		db $FC			; Y speed
		db $00			; X acc
		db $00			; Y acc
		db $00			; tile
		db $30			; prop


	HITBOX:
	.Body
		dw $FFFC,$FFE4
		db $18,$2C
	.BodySpin
		dw $FFFC,$FFF4
		db $18,$18
	.BodyStuck
		dw $FFFC,$FFEC
		db $18,$24


	.Sight
		dw $FFDF,$FFE0
		db $30,$30
	.Chop0
		dw $FFDA,$FFE8
		db $3C,$28
	.Chop1
		dw $FFE7,$FFE8
		db $20,$28


	.Hurricane0
		dw $FFF8,$FFF0
		db $2F,$21
	.Hurricane1
		dw $FFF8,$FFE0
		db $27,$33
	.Hurricane2
		dw $FFE8,$FFEA
		db $2F,$27
	.Hurricane3
		dw $FFF0,$FFF0
		db $27,$2F



	; Captain Warrior anim format:
	; - Tilemap	(2 bytes)
	; - Body dynamo	(2 bytes)
	; - Axe dynamo	(2 bytes)
	; - Frame count	(1 byte)
	; - Next anim	(1 byte)


	ANIM:
	; idle
		dw .IdleTM00,.IdleDyn00 : db $0C,!CW_Idle+1
		dw .IdleTM01,.IdleDyn01 : db $0C,!CW_Idle+2
		dw .IdleTM00,.IdleDyn00 : db $0C,!CW_Idle+3
		dw .IdleTM02,.IdleDyn02 : db $0C,!CW_Idle+0

	; prep chop
		dw .PrepTM00,.PrepDyn00 : db $08,!CW_Prep+1
		dw .PrepTM01,.PrepDyn01 : db $FF,!CW_Prep+2
		dw .PrepTM00,.PrepDyn00 : db $08,!CW_Prep+3
		dw .PrepTM02,.PrepDyn02 : db $FF,!CW_Prep+0

	; chop
		dw .ChopTM00,.ChopDyn00 : db $05,!CW_Chop+1
		dw .ChopTM01,.ChopDyn01 : db $04,!CW_Chop+2
		dw .ChopTM02,.ChopDyn02 : db $05,!CW_Chop+3
		dw .ChopTM03,.ChopDyn03 : db $14,!CW_Idle

	; jump
		dw .JumpTM00,.JumpDyn00 : db $FF,!CW_Jump

	; spin jump
		dw .SpinJumpTM00,.SpinJumpDyn00 : db $FF,!CW_SpinJump

	; spin
		dw .SpinTM00,.SpinDyn00 : db $04,!CW_Spin+1
		dw .SpinTM01,.SpinDyn01 : db $04,!CW_Spin+2
		dw .SpinTM02,.SpinDyn02 : db $04,!CW_Spin+3
		dw .SpinTM03,.SpinDyn03 : db $04,!CW_Spin+0

	; stuck
		dw .StuckTM00,.StuckDyn00 : db $0C,!CW_Stuck+1
		dw .StuckTM01,.StuckDyn01 : db $18,!CW_Stuck+0

	; channel
		dw .ChannelTM00,.ChannelDyn00 : db $FF,!CW_Channel

	; hurt
		dw .HurtTM00,.HurtDyn00 : db $FF,!CW_Hurt+0
		dw .HurtTM01,.HurtDyn01 : db $FF,!CW_Hurt+1

	; defeat
		dw .DefeatTM00,.DefeatDyn00 : db $FF,!CW_Defeat





	; tilemaps
		.IdleTM00
		.IdleTM01
		dw $0028
		db $39,$FC,$E0,$00	; body
		db $39,$04,$E0,$01
		db $39,$FC,$F0,$02
		db $39,$04,$F0,$03
		db $39,$FC,$00,$04
		db $39,$04,$00,$05
		db $3B,$FC,$F0,$06	; axe
		db $3B,$04,$F0,$07
		db $3B,$FC,$F8,$08
		db $3B,$04,$F8,$09

		.IdleTM02
		dw $0028
		db $39,$FC,$E0,$00	; body
		db $39,$04,$E0,$01
		db $39,$FC,$F0,$02
		db $39,$04,$F0,$03
		db $39,$FC,$00,$04
		db $39,$04,$00,$05
		db $3B,$FC,$F1,$06	; axe
		db $3B,$04,$F1,$07
		db $3B,$FC,$F9,$08
		db $3B,$04,$F9,$09

		.PrepTM00
		.PrepTM02
		dw $0028
		db $39,$FC,$E8,$00	; body
		db $39,$04,$E8,$01
		db $39,$FC,$F0,$02
		db $39,$04,$F0,$03
		db $39,$FC,$00,$04
		db $39,$04,$00,$05
		db $3B,$FC,$E0,$06	; axe
		db $3B,$04,$E0,$07
		db $3B,$FC,$F0,$08
		db $3B,$04,$F0,$09
		.PrepTM01
		dw $0028
		db $39,$F9,$E8,$00	; body
		db $39,$01,$E8,$01
		db $39,$F9,$F0,$02
		db $39,$01,$F0,$03
		db $39,$F9,$00,$04
		db $39,$01,$00,$05
		db $3B,$F9,$E0,$06	; axe
		db $3B,$01,$E0,$07
		db $3B,$F9,$F0,$08
		db $3B,$01,$F0,$09

		.ChopTM00
		dw $0028
		db $39,$F7,$E0,$00	; body
		db $39,$07,$E0,$01
		db $39,$F7,$F0,$02
		db $39,$07,$F0,$03
		db $39,$F7,$00,$04
		db $39,$07,$00,$05
		db $3B,$F7,$E8,$06	; axe
		db $3B,$07,$E8,$07
		db $3B,$F7,$F8,$08
		db $3B,$07,$F8,$09
		.ChopTM01
		dw $0038
		db $39,$F7,$E0,$00	; body
		db $39,$07,$E0,$01
		db $39,$F7,$F0,$02
		db $39,$07,$F0,$03
		db $39,$07,$00,$04
		db $3B,$E7,$E8,$05	; axe
		db $3B,$D7,$F0,$06
		db $3B,$E7,$F0,$07
		db $3B,$F7,$F0,$08
		db $3B,$07,$F0,$09
		db $3B,$D7,$00,$0A
		db $3B,$E7,$00,$0B
		db $3B,$F7,$00,$0C
		db $3B,$07,$00,$0D
		.ChopTM02
		dw $0030
		db $39,$F7,$E0,$00	; body
		db $39,$07,$E0,$01
		db $39,$F7,$F0,$02
		db $39,$07,$F0,$03
		db $39,$F7,$00,$04
		db $39,$07,$00,$05
		db $3B,$E7,$E8,$06	; axe
		db $3B,$F7,$E8,$07
		db $3B,$E7,$F0,$08
		db $3B,$F7,$F0,$09
		db $3B,$E7,$00,$0A
		db $3B,$F7,$00,$0B
		.ChopTM03
		dw $0020
		db $39,$F7,$E0,$00	; body
		db $39,$07,$E0,$01
		db $39,$F7,$F0,$02
		db $39,$07,$F0,$03
		db $39,$F7,$00,$04
		db $39,$07,$00,$05
		db $3B,$F2,$F0,$06	; axe
		db $3B,$F2,$F8,$07

		.JumpTM00
		dw $0028
		db $39,$F9,$E0,$00	; body
		db $39,$01,$E0,$01
		db $39,$F9,$F0,$02
		db $39,$01,$F0,$03
		db $39,$F9,$00,$04
		db $39,$01,$00,$05
		db $3B,$01,$E1,$06	; axe
		db $3B,$09,$E1,$07
		db $3B,$01,$E9,$08
		db $3B,$09,$E9,$09

		.SpinJumpTM00
		dw $0028
		db $39,$F8,$E0,$00	; body
		db $39,$08,$E0,$01
		db $39,$F8,$F0,$02
		db $39,$08,$F0,$03
		db $39,$F8,$00,$04
		db $39,$08,$00,$05
		db $3B,$09,$EE,$06	; axe
		db $3B,$11,$EE,$07
		db $3B,$09,$F6,$08
		db $3B,$11,$F6,$09

		.SpinTM00		; axe connects on top
		dw $0020
		db $39,$F8,$F0,$00	; body
		db $39,$08,$F0,$01
		db $39,$F8,$00,$02
		db $39,$08,$00,$03
		db $3B,$08,$F0,$04	; axe
		db $3B,$18,$F0,$05
		db $3B,$18,$00,$06
		db $3B,$08,$00,$07
		.SpinTM01		; axe connects on left side
		dw $0024
		db $39,$F8,$F0,$00	; body
		db $39,$08,$F0,$01
		db $39,$F8,$00,$02
		db $39,$08,$00,$03
		db $3B,$F8,$F0,$04	; axe
		db $3B,$F8,$E0,$05
		db $3B,$08,$E0,$06
		db $3B,$10,$E0,$07
		db $3B,$10,$F0,$08
		.SpinTM02		; axe connects on bottom
		dw $0028
		db $39,$F8,$F0,$00	; body
		db $39,$08,$F0,$01
		db $39,$F8,$00,$02
		db $39,$08,$00,$03
		db $3B,$F8,$00,$04	; axe
		db $3B,$E8,$00,$05
		db $3B,$E8,$F0,$06
		db $3B,$E8,$E8,$07
		db $3B,$F8,$F8,$08
		db $3B,$00,$F8,$09
		.SpinTM03		; axe connects on right side
		dw $0024
		db $39,$F8,$F0,$00	; body
		db $39,$08,$F0,$01
		db $39,$F8,$00,$02
		db $39,$08,$00,$03
		db $3B,$08,$00,$04	; axe
		db $3B,$08,$10,$05
		db $3B,$F8,$10,$06
		db $3B,$F0,$10,$07
		db $3B,$F0,$00,$08

		.StuckTM00
		.StuckTM01
		dw $0024
		db $39,$F8,$E8,$00	; body
		db $39,$00,$E8,$01
		db $39,$F8,$F0,$02
		db $39,$00,$F0,$03
		db $39,$F8,$00,$04
		db $39,$00,$00,$05
		db $3B,$F0,$F8,$06	; axe
		db $3B,$F0,$00,$07
		db $3B,$00,$00,$08

		.ChannelTM00
		dw $0028
		db $39,$F8,$E0,$00	; body
		db $39,$00,$E0,$01
		db $39,$F8,$F0,$02
		db $39,$00,$F0,$03
		db $39,$F8,$00,$04
		db $39,$00,$00,$05
		db $3B,$F0,$F0,$06	; axe
		db $3B,$00,$F0,$07
		db $3B,$F0,$F8,$08
		db $3B,$00,$F8,$09

		.HurtTM00
		dw $0028
		db $39,$F8,$E0,$00	; body
		db $39,$00,$E0,$01
		db $39,$F8,$F0,$02
		db $39,$00,$F0,$03
		db $39,$F8,$00,$04
		db $39,$00,$00,$05
		db $3B,$05,$E0,$06	; axe
		db $3B,$0D,$E0,$07
		db $3B,$05,$E8,$08
		db $3B,$0D,$E8,$09
		.HurtTM01
		dw $0028
		db $3B,$08,$EF,$06	; axe
		db $3B,$10,$EF,$07
		db $3B,$08,$F7,$08
		db $3B,$10,$F7,$09
		db $39,$F8,$E0,$00	; body
		db $39,$08,$E0,$01
		db $39,$F8,$F0,$02
		db $39,$08,$F0,$03
		db $39,$F8,$00,$04
		db $39,$08,$00,$05

		.DefeatTM00
		dw $0028
		db $39,$F8,$E8,$00	; body
		db $39,$08,$E8,$01
		db $39,$F8,$F0,$02
		db $39,$08,$F0,$03
		db $39,$F8,$00,$04
		db $39,$08,$00,$05
		db $3B,$F7,$F8,$06	; axe
		db $3B,$FF,$F8,$07
		db $3B,$F7,$00,$08
		db $3B,$FF,$00,$09



	; dynamos
		.IdleDyn00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($001)
		%SquareDyn($020)
		%SquareDyn($021)
		%SquareDyn($040)
		%SquareDyn($041)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($000)
		%SquareDyn($001)
		%SquareDyn($010)
		%SquareDyn($011)
		..end
		.IdleDyn01
		dw ..end-..start
		..start
		%SquareDyn($003)
		%SquareDyn($004)
		%SquareDyn($023)
		%SquareDyn($024)
		%SquareDyn($043)
		%SquareDyn($044)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($000)
		%SquareDyn($001)
		%SquareDyn($010)
		%SquareDyn($011)
		..end
		.IdleDyn02
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($007)
		%SquareDyn($026)
		%SquareDyn($027)
		%SquareDyn($046)
		%SquareDyn($047)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($000)
		%SquareDyn($001)
		%SquareDyn($010)
		%SquareDyn($011)
		..end

		.PrepDyn00
		dw ..end-..start
		..start
		%SquareDyn($0A6)
		%SquareDyn($0A7)
		%SquareDyn($0B6)
		%SquareDyn($0B7)
		%SquareDyn($0D6)
		%SquareDyn($0D7)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($033)
		%SquareDyn($034)
		%SquareDyn($053)
		%SquareDyn($054)
		..end
		.PrepDyn01
		dw ..end-..start
		..start
		%SquareDyn($0A9)
		%SquareDyn($0AA)
		%SquareDyn($0B9)
		%SquareDyn($0BA)
		%SquareDyn($0D9)
		%SquareDyn($0DA)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($060)
		%SquareDyn($061)
		%SquareDyn($080)
		%SquareDyn($081)
		..end
		.PrepDyn02
		dw ..end-..start
		..start
		%SquareDyn($0AC)
		%SquareDyn($0AD)
		%SquareDyn($0BC)
		%SquareDyn($0BD)
		%SquareDyn($0DC)
		%SquareDyn($0DD)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($073)
		%SquareDyn($074)
		%SquareDyn($093)
		%SquareDyn($094)
		..end

		.ChopDyn00
		dw ..end-..start
		..start
		%SquareDyn($0F0)
		%SquareDyn($0F2)
		%SquareDyn($110)
		%SquareDyn($112)
		%SquareDyn($130)
		%SquareDyn($132)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($0C8)
		%SquareDyn($0CA)
		%SquareDyn($0E8)
		%SquareDyn($0EA)
		..end
		.ChopDyn01
		dw ..end-..start
		..start
		%SquareDyn($0F4)
		%SquareDyn($0F6)
		%SquareDyn($114)
		%SquareDyn($116)
		%SquareDyn($136)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($0B2)
		%SquareDyn($0C0)
		%SquareDyn($0C2)
		%SquareDyn($0C4)
		%SquareDyn($0C6)
		%SquareDyn($0E0)
		%SquareDyn($0E2)
		%SquareDyn($0E4)
		%SquareDyn($0E6)
		..end
		.ChopDyn02
		dw ..end-..start
		..start
		%SquareDyn($0F8)
		%SquareDyn($0FA)
		%SquareDyn($118)
		%SquareDyn($11A)
		%SquareDyn($138)
		%SquareDyn($13A)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($0BC)
		%SquareDyn($0BE)
		%SquareDyn($0CC)
		%SquareDyn($0CE)
		%SquareDyn($0EC)
		%SquareDyn($0EE)
		..end
		.ChopDyn03
		dw ..end-..start
		..start
		%SquareDyn($0FC)
		%SquareDyn($0FE)
		%SquareDyn($11C)
		%SquareDyn($11E)
		%SquareDyn($13C)
		%SquareDyn($13E)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($105)
		%SquareDyn($115)
		..end

		.JumpDyn00
		dw ..end-..start
		..start
		%SquareDyn($009)
		%SquareDyn($00A)
		%SquareDyn($029)
		%SquareDyn($02A)
		%SquareDyn($049)
		%SquareDyn($04A)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($030)
		%SquareDyn($031)
		%SquareDyn($040)
		%SquareDyn($041)
		..end

		.SpinJumpDyn00
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($00E)
		%SquareDyn($02C)
		%SquareDyn($02E)
		%SquareDyn($04C)
		%SquareDyn($04E)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($004)
		%SquareDyn($005)
		%SquareDyn($014)
		%SquareDyn($015)
		..end

		.SpinDyn00
		dw ..end-..start
		..start
		%SquareDyn($060)
		%SquareDyn($062)
		%SquareDyn($080)
		%SquareDyn($082)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($007)
		%SquareDyn($009)
		%SquareDyn($029)
		..end
		.SpinDyn01
		dw ..end-..start
		..start
		%SquareDyn($064)
		%SquareDyn($066)
		%SquareDyn($084)
		%SquareDyn($086)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($02B)
		%SquareDyn($00B)
		%SquareDyn($00D)
		%SquareDyn($00E)
		%SquareDyn($02E)
		..end
		.SpinDyn02
		dw ..end-..start
		..start
		%SquareDyn($068)
		%SquareDyn($06A)
		%SquareDyn($088)
		%SquareDyn($08A)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($078)
		%SquareDyn($076)
		%SquareDyn($056)
		%SquareDyn($046)
		%SquareDyn($048)
		%SquareDyn($049)
		..end
		.SpinDyn03
		dw ..end-..start
		..start
		%SquareDyn($06C)
		%SquareDyn($06E)
		%SquareDyn($08C)
		%SquareDyn($08E)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($04E)
		%SquareDyn($06E)
		%SquareDyn($06C)
		%SquareDyn($06B)
		%SquareDyn($04B)
		..end

		.StuckDyn00
		dw ..end-..start
		..start
		%SquareDyn($0A0)
		%SquareDyn($0A1)
		%SquareDyn($0B0)
		%SquareDyn($0B1)
		%SquareDyn($0D0)
		%SquareDyn($0D1)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($08C)
		%SquareDyn($09C)
		%SquareDyn($09E)
		..end
		.StuckDyn01
		dw ..end-..start
		..start
		%SquareDyn($0A3)
		%SquareDyn($0A4)
		%SquareDyn($0B3)
		%SquareDyn($0B4)
		%SquareDyn($0D3)
		%SquareDyn($0D4)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($098)
		%SquareDyn($0A8)
		%SquareDyn($0AA)
		..end

		.ChannelDyn00
		dw ..end-..start
		..start
		%SquareDyn($15C)
		%SquareDyn($15D)
		%SquareDyn($17C)
		%SquareDyn($17D)
		%SquareDyn($19C)
		%SquareDyn($19D)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($108)
		%SquareDyn($10A)
		%SquareDyn($118)
		%SquareDyn($11A)
		..end

		.HurtDyn00
		dw ..end-..start
		..start
		%SquareDyn($150)
		%SquareDyn($151)
		%SquareDyn($170)
		%SquareDyn($171)
		%SquareDyn($190)
		%SquareDyn($191)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($100)
		%SquareDyn($101)
		%SquareDyn($110)
		%SquareDyn($111)
		..end
		.HurtDyn01
		dw ..end-..start
		..start
		%SquareDyn($153)
		%SquareDyn($155)
		%SquareDyn($173)
		%SquareDyn($175)
		%SquareDyn($193)
		%SquareDyn($195)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($004)
		%SquareDyn($005)
		%SquareDyn($014)
		%SquareDyn($015)
		..end

		.DefeatDyn00
		dw ..end-..start
		..start
		%SquareDyn($167)
		%SquareDyn($169)
		%SquareDyn($177)
		%SquareDyn($179)
		%SquareDyn($197)
		%SquareDyn($199)
		%SquareFile(!File_CaptainWarrior_Axe)
		%SquareDyn($10C)
		%SquareDyn($10D)
		%SquareDyn($11C)
		%SquareDyn($11D)
		..end



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




	namespace off