

	namespace KingKing


; --Defines--

;	!Phase		= !BossData+0
;	!HP		= !BossData+1
;	!Attack		= !BossData+2
;	!AttackTimer	= !BossData+3
;	!BossIndex	= !BossData+4
;	!ScepterIndex	= !BossData+5
;	!BlinkTimer	= !BossData+6		; Timer until boss blinks

;	!HoldingScepter	= $BE,x			; If set, scepter will not be displayed on Kingking's sprite.
;	!TrueDirection	= $3280,x
;	!DeathFlag	= $32A0,x
;	!DeathTimer	= $32B0,x
;	!StunTimer	= $32D0,x
;	!PrevDirection	= $33E0,x
;	!XSpeedIndex	= $3410,x
;	!InvincTimer	= $3420,x
;	!HeadTimer	= $34A0,x		; !SpriteAnimTimer is for body
;	!HeadAnim	= $34C0,x		; !SpriteAnimIndex is for body

;	!AttackMemory	= $6DF5			; < Technically an OW sprite table, but who cares
;	!PreviousFrame	= $6DF6
;	!WalkStep	= $6DF7			; Used to pace back and forth
;	!IdleAttack	= $6DF8			; 0 for nothing, 1 for fire, 2 for stomp
;	!EnrageTimer	= $6DF9



	!Phase			= $BE
	!HP			= $3280
	!Attack			= $3290
	!AttackTimer		= $32A0
	!ScepterIndex		= $32B0
	!BlinkTimer		= $32C0
	!StunTimer		= $32D0

	!WalkDirection		= $34E0

	!HoldingScepter		= $3500
	!InvincTimer		= $3510
	!HeadAnim		= $3520
	!HeadTimer		= $3530

	!AttackMem		= $3540
	!PrevFrame		= $3550
	!WalkStep		= $3560
	!IdleAttack		= $3570
	!EnrageTimer		= $3580



; --Scepter defines--

	!ScepterStatus		= $3280
	!BossIndex		= !ScepterIndex
	!ScepterHitbox		= $3290
	!ScepterSFXTimer	= $32A0





	!Temp = 0
	%def_anim(KK_Idle, 1)
	%def_anim(KK_Walk, 8)
	%def_anim(KK_WalkBack, 6)
	%def_anim(KK_Fire, 1)
	%def_anim(KK_Throw, 3)
	%def_anim(KK_Squat, 1)
	%def_anim(KK_Jump, 1)
	%def_anim(KK_Charge, 6)


	!Temp = 0
	%def_anim(KK_Head_Normal, 1)
	%def_anim(KK_Head_Bop, 1)
	%def_anim(KK_Head_Roar, 1)
	%def_anim(KK_Head_Spit, 1)
	%def_anim(KK_Head_Charge, 1)
	%def_anim(KK_Head_PrepFire, 1)
	%def_anim(KK_Head_Fire, 1)
	%def_anim(KK_Head_Hurt, 1)
	%def_anim(KK_Head_Stomped, 1)
	%def_anim(KK_Head_EyesUp, 1)
	%def_anim(KK_Head_EyesDown, 1)
	%def_anim(KK_Head_Blink, 3)

	!Temp = 0
	%def_anim(KK_Scepter_Spin, 3)
	%def_anim(KK_Scepter_Idle, 1)
	%def_anim(KK_Scepter_Dunk, 2)
	%def_anim(KK_Scepter_Fall, 1)
	%def_anim(KK_Scepter_Fire, 1)


;
; Rework plan:
;	- look over doc and make sure everything is done




	INIT:
		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04 : BEQ KINGKING_INIT
		PLB
		RTL




	MAIN:
		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04 : BNE .Scepter
		JMP KINGKING_MAIN

		.Scepter
		JMP SCEPTER



	KINGKING:
	.INIT
		LDA #$04 : STA $3330,x
		LDA !Difficulty					;\
		AND #$03 : TAY					; | set base HP
		LDA.w DATA_BaseHP,y : STA !HP,x			;/
		LDA #$01 : STA !Phase,x				; enter main phase
		JSL SUB_HORZ_POS				;\ face players
		TYA : STA $3320,x				;/
		TXA						;\
		ASL A						; |
		TAX						; |
		REP #$20					; |
		LDA #$FFFF					; | claim all dynamic tiles
		STA !DynamicList,x				; |
		STA !DynamicTile				; |
		SEP #$20					; |
		LDX !SpriteIndex				;/

		REP #$20					;\
		LDA #$01C0					; |
		LDY #$00					; |
	-	STA !DynamicMatrix,y				; |
		INC #2						; |
		INY #2						; | use these tiles as dynamic matrix
		CPY #$10 : BNE -				; |
		LDA #$01E0					; |
	-	STA !DynamicMatrix,y				; |
		INC #2						; |
		INY #2						; |
		CPY #$20 : BCC -				;/

		LDA.w #.RockDynamo : STA $0C			;\
		SEP #$20					; | load rock particles
		LDY.b #!File_Sprite_BG_1			; |
		CLC : JSL !UpdateFromFile			;/

		LDA #!palset_special_kingking_blue
		JSL LoadPalset
		LDA !GFX_status+$180+!palset_special_kingking_blue
		ASL A
		STA $33C0,x
		REP #$30
		AND #$000E
		ASL #4
		ORA #$0100
		TAX
		LDA.w #!PalsetData : STA $00
		LDA.w #!PalsetData>>8 : STA $01
		LDA #$000F : STA $0E
		LDY.w #!palset_special_kingking_red*$20
	-	LDA [$00],y : STA !PaletteCacheRGB,x
		INY #2
		INX #2
		DEC $0E : BPL -
		SEP #$30
		LDX !SpriteIndex

		.FindScepter
		LDY #$0F					;\
		..loop						; |
		LDA !NewSpriteNum,y				; |
		CMP !NewSpriteNum,x : BNE ..next		; |
		LDA !ExtraBits,y				; |
		AND #$04 : BEQ ..next				; | find scepter
		TYA : STA !ScepterIndex,x			; |
		TXA : STA !BossIndex,y				; |
		BRA ..done					; |
		..next						; |
		DEY : BPL ..loop				; |
		..done						;/
		STZ !HoldingScepter,x				; grab scepter
		LDA #$FF : STA !PrevFrame,x			; always update GFX on frame 1


	.MAIN
		LDY !ScepterIndex,x
		LDA !Phase,x : STA.w !Phase,y
		ASL A
		TAX
		JSR (.PhasePtr,x)
		PLB
		RTL

		.PhasePtr
		dw LOCK_SPRITE			; 0
		dw Intro			; 1
		dw Battle			; 2
		dw Transform			; 3
		dw Battle			; 4
		dw Death			; 5



		.RockDynamo
		dw ..end-..start
		..start
		%FileDyn(4, $07A, $7FC0)
		..end



	DATA:
		.BaseHP
		db $08,$0C,$10

		.DelayTable
		db $3C,$28,$1E,$0F

	; index:
	; dir + Attack_SpeedIndex,[attack] + difficulty&3 * 8
	; if attack = 0 and phase = 4, attack index = 6


		.XSpeed
		db $10,$F0				; Idle		;\
		db $20,$E0				; Jump		; | EASY
		db $30,$D0				; Charge	; |
		db $10,$F0				; Idle, phase 2	;/

		db $10,$F0				; Idle		;\
		db $20,$E0				; Jump		; | NORMAL
		db $38,$C8				; Charge	; |
		db $10,$F0				; Idle, phase 2	;/

		db $10,$F0				; Idle		;\
		db $20,$E0				; Jump		; | INSANE
		db $40,$C0				; Charge	; |
		db $10,$F0				; Idle, phase 2	;/


		.EnrageBox
		dw $FFA0,$FFC0 : db $C0,$FF


		.BaseHorz
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000



	LOCK_SPRITE:
		JMP GRAPHICS


	Intro:
		LDX !SpriteIndex				; X = sprite index
		LDA !Phase,x : BMI .Main
		.Init
		ORA #$80 : STA !Phase,x
		LDA #$10 : STA !StunTimer,x
		.Main
		LDA !StunTimer,x
		CMP #$80 : BNE .NoMsg
		LDY #$00 : STY !MsgTrigger
		.NoMsg
		LDA !StunTimer,x : BEQ .Next
		.Return
		JMP GRAPHICS

		.Next
		LDA #$02 : STA !Phase,x				; next phase
		LDA #!KK_Walk : STA !SpriteAnimIndex		;\ anim
		STZ !SpriteAnimTimer				;/
		LDA #$02 : STA $3E				; mode 2
		PHB						;\
		LDA #$40					; |
		PHA : PLB					; |
		REP #$20					; |
		LDX #$3E					; | set up offset-per-tile mirror
		LDA #$2000					; |
		ORA $1C						; |
	-	STA $F000,x					; |
		STZ $F040,x					; |
		DEX #2 : BPL -					;/
		JSL !GetVRAM					;\
		LDA.w #$0040 : STA.w !VRAMtable+0,x		; |
		LDA.w #DATA_BaseHorz : STA.w !VRAMtable+2,x	; |
		LDA.w #DATA_BaseHorz>>8 : STA.w !VRAMtable+3,x	; | clear horizontal offset data
		LDA.w #$5000 : STA.w !VRAMtable+5,x		; |
		SEP #$20					; |
		PLB						;/
		JSR UPDATE_MODE2				; > initialize vertical offset data
		JMP GRAPHICS					; go to graphics


	Transform:
		JSR UPDATE_MODE2				; update wave
		LDX !SpriteIndex				; X = sprite index
		DEC !SpriteAnimTimer				;\ prevent animation
		INC !HeadTimer,x				;/
		STZ !InvincTimer,x				; make visible
		STZ !EnrageTimer,x				; wipe rage
		LDA !Phase,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Phase,x				; | init
		LDA #$3F : STA !StunTimer,x			; |
		.Main						;/
		LDA $14						;\
		AND #$02					; |
		DEC A						; | shake
		CLC : ADC !SpriteXLo,x				; |
		STA !SpriteXLo,x				;/
		LDA !StunTimer,x : BEQ .End			;\
		STA $00						; |
		LDA $33C0,x					; |
		ASL #3						; |
		ORA #$80					; |
		INC A						; | fade into red palette
		TAX						; |
		LDY #$0F					; |
		LDA $00						; |
		LSR A						; |
		JSL !MixRGB					;/
		LDX !SpriteIndex				; X = sprite index
		JMP GRAPHICS					; go to GRAPHICS
		.End
		INC !Phase,x					; next phase
		LDA #!KK_Head_Roar : STA !HeadAnim,x		;\
		LDA #$10 : STA !HeadTimer,x			; | roar SFX + head anim
		LDA #$25 : STA !SPC1				;/
		.Return
		JMP GRAPHICS


	Death:
		JSR UPDATE_MODE2				; update wave
		LDX !SpriteIndex				; X = sprite index
		LDA !Phase,x : BMI .Main
		.Init
		ORA #$80 : STA !Phase,x
		STA !SPC3					; > fade music

		.Main

		.NoUpdate
		LDX !SpriteIndex
		JMP GRAPHICS




; For each tile:
;
;	Row 0:	byte $00,$01,$10,$11
;	Row 1:	byte $02,$03,$12,$13
;	Row 2:	byte $04,$05,$14,$15
;	Row 3:	byte $06,$07,$16,$17
;	Row 4:	byte $08,$09,$18,$19
;	Row 5:	byte $0A,$0B,$1A,$1B
;	Row 6:	byte $0C,$0D,$1C,$1D
;	Row 7:	byte $0E,$0F,$1E,$1F


;	Offset format:
;		d-12--ss ssssssss
;		d is direction. 0 = horizontal, 1 = vertical. Only used in mode 4.
;		1 applies offset to BG1.
;		2 applies offset to BG2.
;		s is value to add to offset.
;
;	Wave motion format:
;		vh-----T tttttttt
;		v is vertical direction. 0 = up, 1 = down.
;		h is horizontal direction. 0 = left, 1 = up.
;		T is hi bit of timer. Counts down.
;		t is lo byte of timer. Counts down.
;
;	Mirror format:
;	0x0000	64 B	Offset data, 2 bytes/column.
;	0x0040	64 B	Wave motion data, 2 bytes/column.


	Battle:
		JSR UPDATE_MODE2				; update wave
		LDX !SpriteIndex				; X = sprite index

		%decreg(!InvincTimer)


		.Blink						;\
		LDA !BlinkTimer,x : BNE ..process		; |
		LDA !RNG					; | wait 2-4 seconds in-between blinks
		AND #$78					; |
		CLC : ADC #$78					; |
		STA !BlinkTimer,x				;/
		..process					;\
		DEC !BlinkTimer : BNE ..done			; |
		LDA !HeadAnim : BNE ..done			; | blink when timer hits zero (unless already in animation)
		LDA #!KK_Head_Blink : STA !HeadAnim		; |
		LDA #$04 : STA !HeadTimer			; |
		..done						;/

		.Enrage						;\
		LDA !EnrageTimer,x				; |
		BMI ..done					; |
		BEQ ..nodec					; |
		DEC !EnrageTimer,x				; | enrage check
		..nodec						; |
		REP #$20					; |
		LDA.w #DATA_EnrageBox : JSL LOAD_HITBOX		; |
		SEP #$20					; |
		SEC : JSL !PlayerClipping : BCS ..done		;/
		LDA !EnrageTimer,x : BMI ..done			;\
		INC !EnrageTimer,x				; | increment enrage timer until it hits 128
		INC !EnrageTimer,x				;/
		..done

		.HP						;\
		LDA !HP,x					; |
		BMI ..die					; |
		BNE ..alive					; |
		..die						; | die when HP < 1
		LDA #$05 : STA !Phase,x				; |
		LDA #$FF : STA !StunTimer,x			; |
		JMP GRAPHICS					; |
		..alive						;/

		.Stun						;\
		LDA !InvincTimer,x				; |
		CMP #$20 : BCC ..move				; | go to interaction if stunned by attack
		INC !StunTimer,x				; | (!InvincTimer > 0x20)
		DEC !SpriteAnimTimer				; |
		JMP INTERACTION					; |
		..move						;/


		.GetAttack					;\
		LDA $3330,x					; |
		AND #$04 : BNE ..ground				; | just keep goin in midair
	-	JMP Attack					; |
		..ground					;/
		LDA !StunTimer,x : BNE -			;\
		LDA !AttackTimer,x : BEQ ..process		; | decrement attack timer if boss isn't stunned
		DEC !AttackTimer,x				;/
		BNE -						;\ if timer is not yet 0, execute attack code
		..process					;/

		LDA !Phase,x					;\
		AND #$7F					; | no enrage in phase 1
		CMP #$02 : BEQ ..norage				;/
		LDA !EnrageTimer,x : BPL ..norage		;\ enrage attack
		LDA #$05 : BRA ..setattack			;/
		..norage

		LDA !RNG					;\
		AND #$0F					; |
		CMP #$04 : BCS ..noscepter			; |
		LDY !ScepterIndex,x				; |
		LDA !ScepterStatus,y				; | 25% chance to use scepter (but not during enrage)
		CMP #$05 : BNE ..scepter			; |
		LDA #$03 : BRA ..setattack			; |
		..scepter					; |
		LDA #$04 : BRA ..setattack			;/
		..noscepter					;\ random attack num
		AND #$03					;/
		..setattack					;\
		CMP !AttackMem,x : BNE ..fresh			; |
		INC #2						; | don't allow the same attack twice in a row
		AND #$03					; |
		..fresh						;/
		STA !Attack,x					;\ set attack + attack mem
		STA !AttackMem,x				;/
		TAY						;\ set attack timer
		LDA.w Attack_Timer,y : STA !AttackTimer,x	;/


	Attack:
		PEA UpdateSpeed-1				;\
		LDA !Attack,x					; |
		ASL A						; | execute pointer
		TAX						; |
		JMP (.Ptr,x)					;/

		.Ptr
		dw Idle						; idle, long
		dw Idle						; idle, short
		dw Jump						; jump
		dw Charge					; charge
		dw Throw					; ultimate scepter attack
		dw FireBreath					; fire breath

		.Timer
		db $80						; idle, long
		db $40						; idle, short
		db $04						; jump
		db $80						; charge
		db $FF						; ultimate scepter attack
		db $FF						; fire breath

		.SpeedIndex
		db $00
		db $00
		db $02
		db $04
		db $00
		db $00



	Idle:
		LDX !SpriteIndex				; X = sprite index
		LDA $3330,x					;\
		AND #$04 : BNE .Process				; | wait for boss to land
		RTS						; |
		.Process					;/
		LDA !Attack,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Attack,x			; |
		LDA !SpriteXLo,x				; |
		ROL #2						; |
		AND #$01					; |
		STA !WalkDirection,x				; | init dir (charge instead if unable to face player)
		STA $3320,x					; |
		JSL SUB_HORZ_POS				; |
		TYA						; |
		CMP !WalkDirection,x : BEQ .Ok			; |
		LDA #$03 : STA !Attack,x			; |
		LDA.w Attack_Timer+3 : STA !AttackTimer,x	; |
		JMP Charge					;/
		.Ok						;\
		LDA #!KK_Walk : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; | init anim
		STZ !WalkStep,x					; |
		.Main						;/
		LDA !StunTimer,x : BNE .Wait			; wait while stun timer is set
		STZ !IdleAttack,x				;\
		LDA !WalkStep,x					; |
		CMP #$04 : BCC +				; | reset !WalkStep upon hitting 0x04
		STZ !AttackTimer,x				; |
		STZ !WalkStep,x					; |
		RTS						;/

	+	INC !AttackTimer,x				;\
		LDA !StunTimer,x : BEQ +			; | pause attack timer and animation while stun timer is set
		.Wait						; |
		DEC !SpriteAnimTimer				;/
	+	LDA !SpriteAnimTimer : BNE .NoUpdate		;/
		LDA !SpriteAnimIndex				;\
		CMP #!KK_Walk+3 : BEQ .Stomp1			; |
		CMP #!KK_Walk+7 : BEQ .Stomp2			; | update at these frames
		CMP #!KK_WalkBack+2 : BEQ .Fire			; |
		CMP #!KK_Walk+0 : BEQ .Fire			;/
		.NoUpdate					;\
		LDA !WalkStep,x					; |
		CMP #$03 : BCC .Return				; |
		LDA !IdleAttack,x : BNE .Return			; | go to fireball when !WalkStep hits 0x03, but only if set to fire
		JMP Fireball					; |
		.Return						; |
		RTS						;/

		.Fire						;\
		LDA $3320,x					; | must be walking backwards
		CMP !WalkDirection,x : BEQ .Return		;/
		INC !WalkStep,x					;\
		JSR Wait : STA !HeadTimer,x			; |
		LDA #!KK_Head_Spit : STA !HeadAnim,x		; | start fire attack
		INC !SpriteAnimTimer				; |
		BRA Fireball					;/

		.Stomp1						;\
		LDA !Attack,x					; |
		AND #$7F					; | start stomp 1
		CMP #$01 : BNE Stomp				; |
		LDA #$02 : STA !WalkStep,x			; > (becomes 0x03 since it's incremented by the stomp)
		LDA #!KK_WalkBack+2 : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				;/
		.Stomp2						;\ start stomp 2
		PEA.w Stomp-1					;/ (shared code)
		LDA !WalkDirection,x				;\
		EOR #$01					; | turn around
		STA !WalkDirection,x				;/
		RTS



	Stomp:
		INC !WalkStep,x					; +1 step
		INC !IdleAttack,x				; current attack is stomp
		JSR Wait					;\ half wait timer
		JSR RockDebris
		LSR !StunTimer,x				;/
		INC !SpriteAnimTimer				; delay animation
		LDA #$09 : STA !SPC4				; stomp SFX
		LDA $3320,x					;\
		PHP						; |
		LDA !SpriteXLo,x				; |
		LSR #3						; |
		ASL A						; |
		TAX						; |
		CPX #$04					; |
		BCS $02 : LDX #$04				; | start wave
		CPX #$38					; |
		BCC $02 : LDX #$38				; |
		LDA #$FF : STA $40F040,x			; |
		LDA #$01					; |
		PLP						; |
		BNE $02 : LDA #$41				; |
		STA $40F041,x					;/
		LDX !SpriteIndex				; X = sprite index
		RTS						; return


	Fireball:
		LDA !Difficulty					;\
		AND #$03 : TAY					; |
		CPY #$02 : BEQ .Insane				; |
		LDA !Phase,x					; | difficulty data
		AND #$7F : CMP #$04				; |
		BNE $01 : INY					; |
		LDA.w DATA_DelayTable,y				;/

		.EasyNormal					;\
		LDY !Phase,x					; |
		CPY #$04 : BEQ ..battle2			; |
		CPY #$84 : BNE ..battle1			; |
		..battle2					; |
		SEC : SBC !StunTimer,x				; | single spit during phase 1, double spit during phase 2
		BRA .DoubleSpit					; | (always random targets when 1 fireball)
		..battle1					; |
		CMP !StunTimer,x : BNE .Return			; |
		LDA !RNG					; |
		AND #$80 : TAY					; |
		BRA .Target					;/

		.Insane						;\
		LDA !Phase,x					; |
		AND #$7F : CMP #$04				; |
		BNE $01 : INY					; | check double spit
		LDA.w DATA_DelayTable,y				; |
		SEC : SBC !StunTimer,x				; |
		CPY #$03 : BCC .DoubleSpit			;/
		CMP #$00 : BEQ .Target1				;\
		CMP #$04 : BEQ .Target2				; |
		CMP #$08 : BEQ .Target1				; | x4 spit on insane phase 2
		CMP #$0C : BEQ .Target2				; |
		RTS						;/

		.DoubleSpit					;\
		CMP #$00 : BEQ .Target1				; | first one targets p1, second targets p2
		CMP #$04 : BEQ .Target2				;/
		.Return						;\ return
		RTS						;/

		.Target1					;\ target p1
		LDY #$00 : BRA .Target				;/

		.Target2					;\ target p2
		LDY #$80					;/

		.Target						;\
		LDA !P2Status-$80,y : BEQ .Spawn		; |
		TYA						; | make sure target is alive
		EOR #$80					; |
		TAY						;/

		.Spawn						;\
		LDA #$17 : STA !SPC4				; > fire spit SFX
		LDA !P2XPosLo-$80,y : STA $00			; | player x pos
		LDA !P2XPosHi-$80,y : STA $01			;/

		LDA !SpriteXHi,x : XBA				;\
		LDA !SpriteXLo,x				; |
		REP #$20					; |
		SEC : SBC $00					; | calculate projectile X speed
		EOR #$FFFF : INC A				; |
		LSR #2						; |
		SEP #$20					; |
		STA $02						;/
		LDA #$B0 : STA $03				; Y speed = -0x50
		LDY $3320,x					;\ X offset based on direction
		LDA .XOffset,y : STA $00			;/
		LDA #$E5 : STA $01				; Y offset = -27
		SEC : LDA #$07					;\
		JSL SpawnSprite					; | spawn custom sprite 0x07
		CPY #$FF : BEQ .Fail				;/

		LDA #$08 : STA $3230,y

	; projectile settings
		LDA #$80 : STA !ProjectileType,y
		LDA #$20 : STA !ProjectileAnimType,y
		LDA #$00
		STA !ProjectileAnimFrames,y
		STA !ProjectileAnimTime,y
		STA !ProjectileTimer,y
		LDA #$03 : STA !ProjectileGravity,y
		LDA #$E0 : STA !SpriteTile,y
		LDA #$00 : STA !SpriteProp,y
		LDA.w !SpriteXSpeed,y
		LSR A
		AND #$40
		ORA #$10
		ORA $33C0,x
		STA $33C0,y

		.Fail
		RTS


		.XOffset
		db $06,$FA




	Jump:
		LDX !SpriteIndex				; X = sprite index
		LDA !Attack,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Attack,x			; |
		JSR Wait					; |
		LDA #!KK_Squat : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; |
		LDA #!KK_Head_EyesUp : STA !HeadAnim,x		; > look up
		LDA !StunTimer,x				; |
		INC A						; |
		STA !HeadTimer,x				; |
		LDA #$A0 : STA !SpriteYSpeed,x			; |
		LDA !SpriteXLo,x				; | init anim + speed + dir
		ROL #2						; |
		AND #$01					; |
		STA $3320,x					; |
		STA !WalkDirection,x				; |
		STZ $3330,x					; |
		JMP SquatSmoke
		.Return1					; |
		RTS						; |
		.Main						;/
		LDA !StunTimer,x : BNE .Return1			; wait for squat to finish
		LDA !SpriteAnimIndex
		CMP #!KK_Jump : BEQ ..animdone
		LDA #!KK_Jump : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer				; | jump anim
		LDA #!KK_Head_Roar : STA !HeadAnim,x		; |
		LDA #$40 : STA !HeadTimer,x			;/
		JSR JumpSmoke
		..animdone
		LDA !Difficulty					;\
		AND #$03 : BEQ .Process				; |
		LDA !Phase,x					; |
		AND #$7F					; |
		CMP #$04 : BNE .Process				; | dunk check?
		LDA !SpriteYSpeed,x				; |
		CMP #$BE : BNE .Process				; |
		LDY $3320,x					; |
		LDA .Offset,y : STA $00				;/
		LDY !ScepterIndex,x				;\
		LDA #$02 : STA !ScepterStatus,y			; |
		LDA #$38 : STA !StunTimer,y			; |
		LDA #$08 : STA.w !SpriteYSpeed,y		; |
		LDA #!KK_Scepter_Dunk : STA !SpriteAnimIndexY	; |
		LDA #$00 : STA !SpriteAnimTimerY		; |
		LDA !SpriteXLo,x				; |
		CLC : ADC $00					; |
		STA !SpriteXLo,y				; |
		LDA !SpriteXHi,x : STA !SpriteXHi,y		; | dunk
		LDA !SpriteYLo,x				; |
		SEC : SBC #$14					; |
		STA !SpriteYLo,y				; |
		LDA !SpriteYHi,x				; |
		SBC #$00					; |
		STA !SpriteYHi,y				; |
		LDA !SpriteXSpeed,x : STA.w !SpriteXSpeed,y	; |
		LDA $3320,x : STA $3320,y			; |
		INC !HoldingScepter,x				;/

		.Process					;\
		LDA $3330,x					; | wait for sprite to land
		AND #$04 : BNE .Ground				;/
		LDA !SpriteYSpeed,x : BPL .DownEye		;\
		CMP #$E0 : BCC .UpEye				; |
		.DownEye					; | eye movement
		LDA #!KK_Head_EyesDown : STA !HeadAnim,x	; |
		.UpEye						;/
		LDA $3330,x					;\
		AND #$03 : BEQ .Return				; |
		LDA !WalkDirection,x				; | in case boss jumps into a wall...
		EOR #$01					; |
		STA !WalkDirection,x				; |
		LDA #$09 : STA !SPC4				;/> stomp SFX
		.Return
		RTS

		.Ground						;\
		LDA #$09 : STA !SPC4				; > stomp SFX
		JSR RockDebris
		JSR JumpSmoke
		JSR Wait					; |
		LDA !SpriteXLo,x				; |
		LSR #3						; |
		ASL A						; |
		TAX						; | landing code
		LDA #$FF					; |
		STA $40F040,x					; |
		STA $40F042,x					; |
		LDA #$01 : STA $40F041,x			; |
		LDA #$41 : STA $40F043,x			; |
		LDX !SpriteIndex				;/
		LDA #!KK_Squat : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer				; | reset animation
		LDA #!KK_Head_Normal+1 : STA !HeadAnim,x	; | (with head bop)
		LDA #$06 : STA !HeadTimer,x			;/
		STZ !AttackTimer,x
		RTS

		.Offset
		db $1C,$E4


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
		RTS

		.XDisp
		db $0C,$F4
		db $04,$FC

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




	SquatSmoke:
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

		.Particle3
		db $FC			; X disp
		db $0C			; Y disp
		db $F0			; X speed
		db $F8			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle4
		db $0C			; X disp
		db $0C			; Y disp
		db $10			; X speed
		db $F8			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle5
		db $FC			; X disp
		db $0C			; Y disp
		db $F8			; X speed
		db $F0			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle6
		db $0C			; X disp
		db $0C			; Y disp
		db $08			; X speed
		db $F0			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop


	JumpSmoke:
		LDX #$07						;\
	-	LDA .Particle1,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle2,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
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
		LDX #$07						;\
	-	LDA .Particle7,x : STA $00,x				; |
		DEX : BPL -						; |
		LDX !SpriteIndex					; |
		LDY $3320,x						; | spawn particle
		LDA .XDisp,y						; |
		CLC : ADC $00						; |
		STA $00							; |
		LDA #!prt_smoke8x8 : JSL SpawnParticle			;/
		LDX #$07						;\
	-	LDA .Particle8,x : STA $00,x				; |
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
		db $E8			; X speed
		db $FC			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle2
		db $0C			; X disp
		db $0C			; Y disp
		db $18			; X speed
		db $FC			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle3
		db $FC			; X disp
		db $0C			; Y disp
		db $E8			; X speed
		db $F4			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle4
		db $0C			; X disp
		db $0C			; Y disp
		db $18			; X speed
		db $F4			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle5
		db $FC			; X disp
		db $0C			; Y disp
		db $F0			; X speed
		db $F8			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle6
		db $0C			; X disp
		db $0C			; Y disp
		db $10			; X speed
		db $F8			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle7
		db $FC			; X disp
		db $0C			; Y disp
		db $F8			; X speed
		db $F0			; Y speed
		db $08			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop
		.Particle8
		db $0C			; X disp
		db $0C			; Y disp
		db $08			; X speed
		db $F0			; Y speed
		db $F8			; X acc
		db $08			; Y acc
		db $00			; tile
		db $F0			; prop



	Charge:
		LDX !SpriteIndex				; X = sprite index
		LDA !Attack,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Attack,x			; |
		LDA #!KK_Charge : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; | init anim + dir
		LDA #!KK_Head_Charge : STA !HeadAnim,x		; |
		LDA #$40 : STA !HeadTimer,x			; |
		JSL SUB_HORZ_POS				; |
		TYA : STA !WalkDirection,x			; |
		JSR Wait					; |
		.Main						;/

		JSR .Dust
		LDA !StunTimer,x				;\ delay head timer while stunned
		BEQ $03 : INC !HeadTimer,x			;/

		LDA !AttackTimer,x : BNE .KeepAnim		;\
		STZ !SpriteAnimIndex				; | reset anim when attack ends
		STZ !HeadAnim,x					; |
		.KeepAnim					;/
		LDA $3330,x					;\
		AND #$03 : BEQ .Process				; |
		LDA !WalkDirection,x				; |
		EOR #$01					; |
		STA !WalkDirection,x				; |
		STA $3320,x					; | check for wall collision
		LDA #$C8 : STA !SpriteYSpeed,x			; | (+anim)
		LDA #!KK_Jump : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; |
		LDA #!KK_Head_Roar : STA !HeadAnim,x		; |
		LDA #$30 : STA !HeadTimer,x			;/
		STZ !Attack,x					;\
		STZ !AttackTimer,x				; | end attack after bonk
		RTS						;/

		.Process					;\
		LDA !AttackTimer,x				; | facing
		CMP #$02 : BCC .Return				; |
		LDA !WalkDirection,x : STA $3320,x		;/

		.Return						;\ return
		RTS						;/


		.Dust
		LDA !SpriteAnimIndex
		CMP #!KK_Charge+2 : BEQ ..spawn
		CMP #!KK_Charge+5 : BNE ..return
		..spawn
		LDY $3320,x
		LDA ..xoffset,y : STA $00
		LDA #$0C : STA $01
		LDA !RNG
		AND #$0F
		SBC #$08
		ADC ..xspeed,y
		STA $02
		LDA !RNG
		LSR #4
		ORA #$F0
		STA $03
		STZ $04
		STZ $05
		LDA #$F0 : STA $07
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		..return
		RTS


		..xoffset
		db $08,$F8

		..xspeed
		db $F0,$10




	Throw:
		LDX !SpriteIndex				; X = sprite index
		LDA !Attack,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Attack,x			; |
		LDA #$90 : STA !StunTimer,x			; |
		LDA #!KK_Throw : STA !SpriteAnimIndex		; | init anim + dir
		STZ !SpriteAnimTimer				; |
		LDA #!KK_Head_Roar : STA !HeadAnim		; |
		LDA #$19 : STA !HeadTimer,x			; |
		LDA #$25 : STA !SPC1				; > roar SFX
		LDA !SpriteXLo,x				; |
		ROL #2						; |
		AND #$01					; |
		STA !WalkDirection,x				; |
		STA $3320,x					; |
		.Main						;/

		LDA !StunTimer,x : BNE .Process			;\
		STZ !AttackTimer,x				; | end when stun runs out
		RTS						;/

		.Process					;\
		LDA !SpriteAnimIndex				; |
		CMP #!KK_Throw : BNE .Return			; | throw at transition between frames
		LDA !SpriteAnimTimer				; |
		CMP #$0B : BNE .Return				;/
		INC !HoldingScepter,x				; drop scepter
		LDY !ScepterIndex,x				;\
		LDA !SpriteYLo,x				; |
		SEC : SBC #$18					; |
		STA !SpriteYLo,y				; |
		LDA !SpriteXLo,x : STA $00			; |
		LDA !SpriteYHi,x : STA !SpriteYHi,y		; |
		LDA !SpriteXHi,x : STA !SpriteXHi,y		; |
		LDA $3320,x : STA $3320,y			; | coords + dir of scepter
		TAY						; |
		LDA .XSpeed+0,y : STA $02			; > keep for later
		LDA .XSpeed+2,y : STA $03			; > keep for later
		LDA.w .Offset,y					; |
		CLC : ADC $00					; |
		XBA						; |
		LDY !ScepterIndex,x				; |
		XBA : STA !SpriteXLo,y				;/
		LDA #$00					;\
		STA !SpriteAnimIndexY				; | spin animation
		STA !SpriteAnimTimerY				;/

		LDA !Difficulty					;\
		AND #$03					; |
		CMP #$02 : BNE .Boomerang			; | arc bounce on insane only
		LDA !Phase,x					; |
		AND #$7F					; |
		CMP #$04 : BEQ .ArcBounce			;/

		.Boomerang					;\
		LDA $02 : STA.w !SpriteXSpeed,y			; |
		LDA #$E8 : STA.w !SpriteYSpeed,y		; | boomerang throw
		LDA #$01 : STA !ScepterStatus,y			; |
		LDA #$7C : STA !StunTimer,y			;/

		.Return
		RTS

		.ArcBounce					;\
		LDA $03 : STA.w !SpriteXSpeed,y			; |
		LDA #$B0 : STA.w !SpriteYSpeed,y		; | ULTIMATE throw
		LDA #$04 : STA !ScepterStatus,y			; |
		LDA #$D0 : STA !StunTimer,y			; |
		LDA #$E8 : STA !StunTimer,x			;/
		RTS

		.XSpeed
		db $40,$C0
		db $18,$E8

		.Offset
		db $14,$EC


	FireBreath:
		LDX !SpriteIndex				; X = sprite index
		LDA !Attack,x : BMI .Main			;\
		.Init						; |
		ORA #$80 : STA !Attack,x			; |
		LDA #$50 : STA !StunTimer,x			; |
		LDA #!KK_Squat : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; | init anim + dir
		STZ !HeadAnim,x					; |
		JSL SUB_HORZ_POS				; |
		TYA : STA $3320,x				; |
		.Main						;/
		LDA !StunTimer,x : BEQ .End			;\
		SEC : SBC #$10
		BPL $02 : LDA #$00
		ASL A
		STA !EnrageTimer,x

		LDA !StunTimer,x
		CMP #$08 : BEQ .Squat				; | do things at these times
		CMP #$38 : BEQ .BigFire				; |
		CMP #$48 : BEQ .PrepFire			;/
		.Return
		RTS

		.End
		STZ !AttackTimer,x
		STZ !EnrageTimer,x
		RTS

		.Squat
		LDA #!KK_Squat : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !HeadAnim,x
		RTS

		.BigFire
		LDA #$17 : STA !SPC4				; fire SFX
		LDA #!KK_Head_Fire : STA !HeadAnim,x
		LDY !ScepterIndex,x
		LDA $3320,x : STA $3320,y
		LDA !SpriteYLo,x
		SEC : SBC #$04
		STA !SpriteYLo,y
		LDA !SpriteYHi,x : STA !SpriteYHi,y
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA !SpriteXHi,y
		TYX
		LDY $3320,x
		LDA .XSpeed,y : STA !SpriteXSpeed,x
		LDA .Offset,y
		CLC : ADC $00
		STA !SpriteXLo,x
		LDA #!KK_Scepter_Fire : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDX !SpriteIndex
		LDY !ScepterIndex,x
		LDA #$05 : STA !ScepterStatus,y
		LDA #$FF : STA !StunTimer,y
		RTS

		.PrepFire
		LDA #!KK_Fire : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #!KK_Head_PrepFire : STA !HeadAnim,x
		LDA !StunTimer,x : STA !HeadTimer,x
		RTS

		.XSpeed
		db $20,$E0

		.Offset
		db $32,$CE



	UpdateSpeed:
		LDA !StunTimer,x : BNE INTERACTION		; no movement while stunned
		LDA !Attack,x
		AND #$7F
		CMP #$05 : BNE .NoThrow
		STZ !SpriteXSpeed,x : BRA .Move
		.NoThrow

		LDA !Phase,x
		AND #$7F
		CMP #$04 : BNE .NoFast
		LDA !Attack,x
		AND #$7F
		CMP #$02 : BCS .NoFast
		LDA #$06 : BRA .SetAttack
		.NoFast

		LDA !Attack,x
		AND #$7F
		TAY
		LDA Attack_SpeedIndex,y

		.SetAttack
		STA $00

		LDA !Difficulty
		AND #$03
		ASL #3
		ADC $00
		ADC !WalkDirection,x
		TAY
		LDA.w DATA_XSpeed,y : STA !SpriteXSpeed,x

		.Move
		JSL !SpriteApplySpeed


	INTERACTION:
		JSR GRAPHICS					; do graphics first

		.Head
		REP #$20					;\
		LDA.w #HITBOX_Head : JSL LOAD_HITBOX		; |
		LDA $04						; |
		CLC : ADC !BigRAM+0				; |
		STA $04						; |
		LDA $0A						; |
		ADC !BigRAM+1					; | head hitbox
		STA $0A						; |
		LDA $05						; |
		CLC : ADC !BigRAM+2				; |
		STA $05						; |
		LDA $0B						; |
		ADC !BigRAM+3					; |
		STA $0B						;/
		JSL FireballContact_Destroy			; fireballs break upon touching Kingking
		BCS ..hurt					; ...but also hurt him if hitting the head

		JSL P2Standard : BCC ..nobodycontact		;\
		BEQ ..nobodycontact				; |
		JSR .HurtBoss					; | player body x boss head interaction
		LDA !SpriteAnimIndex				;\ check for fire anim
		CMP #!KK_Fire : BEQ ..nocontact			;/
		LDA #!KK_Head_Stomped : STA !HeadAnim,x		; |
		LDA #$0C : STA !HeadTimer,x			; |
		BRA ..nocontact					; |
		..nobodycontact					;/
		JSL P2Attack : BCC ..noattackcontact		;\
		..hurt						; |
		JSR .HurtBoss					; | player attack x boss head interaction
		LDA !SpriteAnimIndex				;\ check for fire anim
		CMP #!KK_Fire : BEQ ..nocontact			;/
		LDA #!KK_Head_Hurt : STA !HeadAnim,x		; |
		LDA #$0C : STA !HeadTimer,x			; |
		..noattackcontact				;/
		..nocontact

		.Body
		LDA !SpriteAnimIndex				;\
		CMP #!KK_Squat : BEQ ..squat			; |
		CMP #!KK_Fire : BEQ ..crouching			; |
		..standing					; |
		LDY #$00 : BRA ..loadhitbox			; |
		..squat						; | body hitbox
		LDY #$02 : BRA ..loadhitbox			; |
		..crouching					; |
		LDY #$04					; |
		..loadhitbox					; |
		REP #$20					; |
		LDA HITBOX,y : JSL LOAD_HITBOX			;/
		JSL FireballContact_Destroy			; fireballs break upon touching Kingking
		JSL P2Hurt					; hurt on contact
		..nocontact

		STZ $00						;\
		LDY #$00 : JSR .CheckWave			; | wave interaction
		LDY #$80 : JSR .CheckWave			; |
		LDA $00 : JSL !HurtPlayers			;/
		LDX !SpriteIndex				; X = sprite index
		RTS


		.HurtBoss
		LDA !InvincTimer,x : BEQ ..hurt			; check invinc timer
		LDA #$02 : STA !SPC1				; contact SFX
		RTS						; return
		..hurt						;\
		LDA !Attack,x					; |
		AND #$7F					; |
		CMP #$02 : BEQ ..noclear			; |
		CMP #$04 : BCS ..noclear			; |
		STZ !AttackTimer,x				; |
		..noclear					; |
		DEC !HP,x					; |
		LDA #$30 : STA !InvincTimer,x			; |
		LDA #$28 : STA !SPC4				; > hurt boss SFX
		LDA !Difficulty					; |
		AND #$03 : TAY					; | transform when at half HP
		LDA.w DATA_BaseHP,y				; |
		LSR A						; |
		CMP !HP,x : BNE ..return			; |
		LDA #$03 : STA !Phase,x				;/
		..return					;\ return
		RTS						;/


		.CheckWave					;\
		LDA !P2Blocked-$80,y				; |
		AND #$04 : BEQ ..return				; |
		LDA !P2Status-$80,y : BNE ..return		; |
		LDA !P2XPosLo-$80,y				; |
		LSR #3						; |
		ASL A						; |
		TAX						; |
		REP #$20					; | see if player touches a wave
		LDA $40F03E,x					; |
		ORA $40F040,x					; |
		ORA $40F042,x					; |
		AND #$81FF					; |
		SEP #$20					; |
		BMI ..return					; |
		BEQ ..return					;/
		..mark						;\
		LDA #$01					; |
		CPY #$80					; | mark contact
		BNE $02 : LDA #$02				; |
		TSB $00						;/
		..return					;\ return
		RTS						;/



	HITBOX:
		dw .BodyStanding
		dw .BodySquatting
		dw .BodyCrouching


		.BodyStanding
		dw $FFF8,$FFF0 : db $18,$20

		.BodySquatting
		dw $FFF8,$FFF8 : db $18,$18

		.BodyCrouching
		dw $FFF8,$0000 : db $18,$10

		.Head
		dw $0004,$FFF4 : db $18,$1C



;================;
;GRAPHICS ROUTINE;
;================;
; Method:
; - Update frame
; - Put body tilemap pointer in RAM ($0E)
; - Put head offsets in RAM $06-$07
; - Put scepter tilemap pointer in RAM ($08)
; - Load dynamo if this is a new frame
; - Update head by reverting to 0 once the timer hits 0
; - Put head tilemap pointer in RAM ($04)
; - Load head tilemap into !BigRAM using the offsets in $06-$07
; - If scepter is held, add its tilemap to !BigRAM, increasing header by 8
; - Add body tilemap to !BigRAM
;



	GRAPHICS:

	; update 32x32 fireball
		.Fireball32x32
		REP #$20
		LDA #$0007*4 : STA !BigRAM+0			; size of dynamo (4 uploads)
		LDA #$0080
		STA !BigRAM+$00+2
		STA !BigRAM+$07+2
		STA !BigRAM+$0E+2
		STA !BigRAM+$15+2

		LDA !SD_Fireball32x32
		AND #$00C0 : BEQ ..7E
		CMP #$0040 : BEQ ..7F
		CMP #$0080 : BEQ ..40
	..41	LDA #$0041 : BRA ..addr
	..40	LDA #$0040 : BRA ..addr
	..7F	LDA #$007F : BRA ..addr
	..7E	LDA #$007E
	..addr	STA !BigRAM+$04+2
		STA !BigRAM+$0B+2
		STA !BigRAM+$12+2
		STA !BigRAM+$19+2
		LDA $14
		LSR A
		AND #$000F
		EOR #$000F
		XBA
		ASL A
		STA $00
		LDA !SD_Fireball32x32
		AND #$003F
		XBA
		ASL #2
		ADC $00
		STA !BigRAM+$02+2
		CLC : ADC #$0080
		STA !BigRAM+$09+2
		CLC : ADC #$0080
		STA !BigRAM+$10+2
		CLC : ADC #$0080
		STA !BigRAM+$17+2
		LDA #$6A00 : STA !BigRAM+$05+2
		LDA #$6B00 : STA !BigRAM+$0C+2
		LDA #$6C00 : STA !BigRAM+$13+2
		LDA #$6D00 : STA !BigRAM+$1A+2
		LDA #!BigRAM : STA $0C
		SEP #$20
		CLC : JSL !UpdateGFX


	; update 16x16 fireball
		.Fireball16x16
		REP #$20
		LDA #$0007*4 : STA !BigRAM+0			; size of dynamo (4 uploads)
		LDA #$0040
		STA !BigRAM+$00+2
		STA !BigRAM+$07+2

		LDA !SD_EnemyFireball16x16
		AND #$00C0 : BEQ ..7E
		CMP #$0040 : BEQ ..7F
		CMP #$0080 : BEQ ..40
	..41	LDA #$0041 : BRA ..addr
	..40	LDA #$0040 : BRA ..addr
	..7F	LDA #$007F : BRA ..addr
	..7E	LDA #$007E
	..addr	STA !BigRAM+$04+2
		STA !BigRAM+$0B+2
		LDA $14
		AND #$000F
		EOR #$000F
		XBA
		LSR A
		STA $00
		LDA !SD_EnemyFireball16x16
		AND #$003F
		XBA
		ASL #2
		ADC $00
		STA !BigRAM+$02+2
		CLC : ADC #$0040
		STA !BigRAM+$09+2
		LDA #$6E00 : STA !BigRAM+$05+2
		LDA #$6F00 : STA !BigRAM+$0C+2
		LDA #!BigRAM : STA $0C
		SEP #$20
		CLC : JSL !UpdateGFX



		LDX !SpriteIndex				; X = sprite index
		STZ !SpriteTile,x				;\ nope
		STZ !SpriteProp,x				;/
		JSL SETUP_SQUARE				; get tile nums

		.HandleUpdate
		REP #$30					; all regs 16-bit
		LDA !SpriteAnimIndex				;\
		AND #$00FF					; |
		STA $00						; |
		ASL #2						; | index = frame * 10 (0x0A)
		CLC : ADC $00					; |
		ASL A						; |
		TAY						;/
		SEP #$20					;\
		LDA !SpriteAnimTimer				; |
		INC A						; | update frame
		CMP.w ANIM+2,y : BNE ..sameanim			; |
		LDA #$FF : STA !SpriteAnimTimer			; |
		LDA.w ANIM+3,y : STA !SpriteAnimIndex		;/
		..newanim					;\
		CMP #!KK_Charge+2 : BEQ ..stompsfx		; |
		CMP #!KK_Charge+5 : BNE ..nosfx			; | stomp SFX on some charge frames
		..stompsfx					; |
		LDA #$09 : STA !SPC4				; |
		BRA .HandleUpdate				; > get new index
		..nosfx						;/
		CMP #!KK_Walk+3 : BEQ ..bop			;\
		CMP #!KK_Walk+7 : BNE .HandleUpdate		; | bop head at these frames
		..bop						;/
		LDA !HeadAnim,x : BEQ ..setbop			;\
		CMP #!KK_Head_Hurt : BEQ .HandleUpdate		; |
		CMP #!KK_Head_Stomped : BEQ .HandleUpdate	; | bop animation can't cancel hurt animations
		..setbop					; |
		LDA #!KK_Head_Bop : STA !HeadAnim,x		; |
		LDA #$0D : STA !HeadTimer,x			;/
		BRA .HandleUpdate				; > get new index

		..sameanim
		STA !SpriteAnimTimer				; > update animation timer


	; draw head
		REP #$20					;\
		LDA.w ANIM+8,y					; > push head offsets
		PHY						; > push Y
		SEP #$10					; > index 8-bit
		STA $00						; |
		AND #$00FF					; |
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		LDY $3320,x					; |
		BNE $03 : EOR #$FFFF				; |
		STA !BigRAM+0					; |
		LDA $01						; | head offsets (output in !BigRAM and !BigRAM+2)
		AND #$00FF					; |
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		STA !BigRAM+2					;/
		SEP #$30					; all regs 8-bit
		LDA !SpriteXLo,x : PHA				;\
		CLC : ADC !BigRAM+0				; |
		STA !SpriteXLo,x				; |
		LDA !SpriteXHi,x : PHA				; |
		ADC !BigRAM+1					; |
		STA !SpriteXHi,x				; | push and update sprite coords
		LDA !SpriteYLo,x : PHA				; |
		CLC : ADC !BigRAM+2				; |
		STA !SpriteYLo,x				; |
		LDA !SpriteYHi,x : PHA				; |
		ADC !BigRAM+3					; |
		STA !SpriteYHi,x				;/
		LDA !HeadAnim,x : STA $00			;\
		ASL A						; |
		ADC $00						; |
		TAY						; |
		LDA !HeadTimer,x				; |
		BEQ $03 : DEC !HeadTimer,x			; |
		CMP #$01 : BNE .SameHead			; | head anim
		LDA #$08 : STA !HeadTimer,x			; |
		LDA.w ANIM_HeadPtr+2,y : STA !HeadAnim,x	; |
		STA $00						; |
		ASL A						; |
		ADC $00						; |
		TAY						; |
		.SameHead					;/
		LDA !InvincTimer,x : BEQ ..draw			;\
		AND #$06 : BEQ .NoJaw				; | invinc flash (head)
		..draw						;/
		REP #$20					;\
		LDA.w ANIM_HeadPtr+0,y : STA $04		; | draw head
		SEP #$30					; |
		JSL LOAD_TILEMAP_COLOR_p1			;/
		LDA !HeadAnim,x					;\
		CMP #!KK_Head_Spit : BNE .NoJaw			; |
		REP #$20					; |
		LDA.w #ANIM_Spit_jaw : STA $04			; | hi prio jaw
		SEP #$20					; |
		JSL LOAD_TILEMAP_COLOR_p3			; |
		.NoJaw						;/
		PLA : STA !SpriteYHi,x				;\
		PLA : STA !SpriteYLo,x				; | restore sprite coords
		PLA : STA !SpriteXHi,x				; |
		PLA : STA !SpriteXLo,x				;/
		REP #$30					; all regs 16-bit
		PLY						; pull Y


	; draw scepter
		.Scepter
		LDA !InvincTimer,x				;\
		AND #$00FF : BEQ ..draw				; | invinc flash (scepter)
		AND #$0006 : BEQ .NoScepter			; |
		..draw						;/
		LDA !HoldingScepter,x				;\
		AND #$00FF : BNE .NoScepter			; |
		LDA.w ANIM+4,y : STA $04			; |
		PHY						; |
		SEP #$30					; | draw scepter
		JSL LOAD_TILEMAP_COLOR_p1			; |
		REP #$30					; |
		PLY						; |
		.NoScepter					;/


	; draw body
		.Body
		LDA.w ANIM+0,y : STA $04			; tilemap pointer
		LDA.w ANIM+6,y : STA $0C			; dynamo pointer
		SEP #$30					; > all regs 16 bit
		LDA !SpriteAnimIndex				;\
		CMP !PrevFrame,x				; |
		STA !PrevFrame,x				; | load dynamo if this frame isn't loaded
		BEQ +						; |
		LDY.b #!File_Kingking				; |
		JSL LOAD_SQUARE_DYNAMO				;/
	+	LDA !InvincTimer,x : BEQ ..draw			;\
		AND #$06 : BEQ .Return				; | invinc flash (body)
		..draw						;/
		JSL LOAD_DYNAMIC_p1				; draw body
		.Return						;\ return
		RTS						;/



; ANIM format:
; - tilemap pointer
; - frame count
; - next frame
; - scepter tilemap
; - dynamo pointer
; - head offset (added to X/Y of head)
; Each entry is 10 bytes


	ANIM:
	; idle
		dw .48x40TM : db $FF,!KK_Idle
		dw .ScepterIdle
		dw .IdleDyn
		db $FC,$E1

	; walk
		dw .48x40TM : db $11,!KK_Walk+1
		dw .ScepterIdle
		dw .IdleDyn
		db $FC,$E1
		dw .40x40TM : db $09,!KK_Walk+2
		dw .ScepterWalk1
		dw .WalkDyn1
		db $F5,$E2
		dw .40x40TM : db $07,!KK_Walk+3
		dw .ScepterWalk2
		dw .WalkDyn2
		db $F5,$E0
		dw .48x40TM : db $07,!KK_Walk+4
		dw .ScepterWalk3
		dw .WalkDyn3
		db $F8,$DF
		dw .48x40TM : db $11,!KK_Walk+5
		dw .ScepterWalk4
		dw .WalkDyn4
		db $FA,$E1
		dw .48x40TM : db $09,!KK_Walk+6
		dw .ScepterWalk5
		dw .WalkDyn5
		db $FC,$E0
		dw .48x40TM : db $07,!KK_Walk+7
		dw .ScepterWalk6
		dw .WalkDyn6
		db $FE,$DF
		dw .48x40TM : db $07,!KK_WalkBack
		dw .ScepterWalk7
		dw .WalkDyn7
		db $F9,$E0

	; walk back
		dw .48x40TM : db $11,!KK_WalkBack+1
		dw .ScepterIdle
		dw .IdleDyn
		db $FC,$E1
		dw .48x40TM : db $07,!KK_WalkBack+2
		dw .ScepterWalk6
		dw .WalkDyn6
		db $FE,$DF
		dw .48x40TM : db $09,!KK_WalkBack+3
		dw .ScepterWalk5
		dw .WalkDyn5
		db $FC,$E0
		dw .48x40TM : db $11,!KK_WalkBack+4
		dw .ScepterWalk4
		dw .WalkDyn4
		db $FA,$E1
		dw .40x40TM : db $07,!KK_WalkBack+5
		dw .ScepterWalk2
		dw .WalkDyn2
		db $F5,$E0
		dw .40x40TM : db $09,!KK_Walk+0
		dw .ScepterWalk1
		dw .WalkDyn1
		db $F5,$E2

	; fire
		dw .32x32TM : db $FF,!KK_Fire
		dw .ScepterFire
		dw .FireDyn
		db $E0,$00

	; throw
		dw .48x40TM : db $0D,!KK_Throw+1
		dw .ScepterWalk6
		dw .WalkDyn6
		db $FE,$DF
		dw .48x48TM : db $07,!KK_Throw+2
		dw .ScepterThrow
		dw .ThrowDyn1
		db $F8,$E0
		dw .48x48TM : db $FF,!KK_Throw+2
		dw .ScepterThrow
		dw .ThrowDyn2
		db $FC,$E1

	; squat
		dw .40x32TM : db $40,!KK_Idle
		dw .ScepterSquat
		dw .SquatDyn
		db $F1,$E7

	; jump
		dw .40x40TM : db $FF,!KK_Jump
		dw .ScepterJump
		dw .JumpDyn
		db $F5,$E1

	; charge
		dw .48x40TM : db $06,!KK_Charge+1
		dw .ScepterIdle
		dw .IdleDyn
		db $FC,$E1
		dw .40x40TM : db $04,!KK_Charge+2
		dw .ScepterWalk1
		dw .WalkDyn1
		db $F5,$E2
		dw .40x40TM : db $04,!KK_Charge+3
		dw .ScepterWalk2
		dw .WalkDyn2
		db $F5,$E0
	;	dw .48x40TM : db $04,!KK_Charge+4
	;	dw .ScepterWalk3
	;	dw .WalkDyn3
	;	db $F8,$DF
		dw .48x40TM : db $06,!KK_Charge+4
		dw .ScepterWalk4
		dw .WalkDyn4
		db $FA,$E1
		dw .48x40TM : db $04,!KK_Charge+5
		dw .ScepterWalk5
		dw .WalkDyn5
		db $FC,$E0
		dw .48x40TM : db $04,!KK_Charge+0
		dw .ScepterWalk6
		dw .WalkDyn6
		db $FE,$DF
	;	dw .48x40TM : db $04,!KK_Charge+0
	;	dw .ScepterWalk7
	;	dw .WalkDyn7
	;	db $F9,$E0



	; dynamic body tilemaps
		.48x40TM
		dw $0024
		db $32,$F0,$E8,$00
		db $32,$00,$E8,$01
		db $32,$10,$E8,$02
		db $32,$F0,$F8,$03
		db $32,$00,$F8,$04
		db $32,$10,$F8,$05
		db $32,$F0,$00,$06
		db $32,$00,$00,$07
		db $32,$10,$00,$08

		.40x40TM
		dw $0024
		db $32,$F0,$E8,$00
		db $32,$00,$E8,$01
		db $32,$08,$E8,$02
		db $32,$F0,$F8,$03
		db $32,$00,$F8,$04
		db $32,$08,$F8,$05
		db $32,$F0,$00,$06
		db $32,$00,$00,$07
		db $32,$08,$00,$08

		.48x48TM
		dw $0024
		db $32,$F0,$E0,$00
		db $32,$00,$E0,$01
		db $32,$10,$E0,$02
		db $32,$F0,$F0,$03
		db $32,$00,$F0,$04
		db $32,$10,$F0,$05
		db $32,$F0,$00,$06
		db $32,$00,$00,$07
		db $32,$10,$00,$08

		.32x32TM
		dw $0010
		db $32,$F8,$F0,$00
		db $32,$08,$F0,$01
		db $32,$F8,$00,$02
		db $32,$08,$00,$03

		.40x32TM
		dw $0018
		db $32,$F0,$F0,$00
		db $32,$00,$F0,$01
		db $32,$08,$F0,$02
		db $32,$F0,$00,$03
		db $32,$00,$00,$04
		db $32,$08,$00,$05




	; head anim table
	.HeadPtr
		dw .Normal : db !KK_Head_Normal
		dw .Bop : db !KK_Head_Normal
		dw .Roar : db !KK_Head_Normal
		dw .Spit : db !KK_Head_Normal
		dw .Charge : db !KK_Head_Normal
		dw .Prepfire : db !KK_Head_Normal
		dw .Fire : db !KK_Head_Normal
		dw .Hurt : db !KK_Head_Normal
		dw .Stomped : db !KK_Head_Hurt
		dw .EyesUp : db !KK_Head_Normal
		dw .EyesDown : db !KK_Head_Normal
		dw .EyesHalfClosed : db !KK_Head_Blink+1
		dw .EyesClosed : db !KK_Head_Blink+2
		dw .EyesHalfClosed : db !KK_Head_Normal


	; head tilemaps
		.Normal
		dw $0014
		db $33,$F8,$F0,$80
		db $33,$08,$F0,$82
		db $33,$F8,$00,$A0
		db $33,$08,$00,$A2
		db $32,$0B,$E4,$AC

		.Bop
		dw $0014
		db $33,$F8,$F0,$84
		db $33,$08,$F0,$86
		db $33,$F8,$00,$A4
		db $33,$08,$00,$A6
		db $32,$0E,$E1,$AC

		.Roar
		dw $0014
		db $33,$F8,$F0,$40
		db $33,$08,$F0,$42
		db $33,$F8,$00,$60
		db $33,$08,$00,$62
		db $32,$0B,$E4,$AC

		.Spit
		dw $0014
		db $33,$F8,$F0,$40
		db $33,$08,$F0,$42
		db $33,$F8,$00,$44
		db $33,$08,$00,$64
		db $32,$0B,$E4,$AC
		..jaw
		dw $0008
		db $33,$F8,$00,$6C
		db $33,$08,$00,$6E

		.Charge
		dw $0028
		db $33,$EC,$EE,$06
		db $33,$F4,$EE,$07
		db $33,$04,$EE,$09
		db $33,$EC,$F6,$16
		db $33,$F4,$F6,$17
		db $33,$04,$F6,$19
		db $33,$EC,$06,$36
		db $33,$F4,$06,$37
		db $33,$04,$06,$39
		db $32,$FE,$E7,$AC

		.Prepfire
		dw $0014
		db $33,$F8,$F0,$88
		db $33,$08,$F0,$8A
		db $33,$F8,$00,$A8
		db $33,$08,$00,$AA
		db $32,$0B,$E2,$AE

		.Fire
		dw $0014
		db $33,$F8,$F0,$8C
		db $33,$08,$F0,$8E
		db $33,$F8,$00,$AC
		db $33,$08,$00,$AE
		db $32,$0B,$E4,$AC

		.Hurt
		dw $001C
		db $33,$F8,$EA,$0B
		db $33,$08,$EA,$0D
		db $33,$F8,$F2,$1B
		db $33,$08,$F2,$1D
		db $33,$F8,$02,$3B
		db $33,$08,$02,$3D
		db $32,$09,$DB,$AE

		.Stomped
		dw $001C
		db $33,$F4,$F8,$56
		db $33,$FC,$F8,$57
		db $33,$0C,$F8,$59
		db $33,$F4,$00,$66
		db $33,$FC,$00,$67
		db $33,$0C,$00,$69
		db $32,$09,$EE,$AE

		.EyesHalfClosed
		dw $0018
		db $33,$00,$F0,$00
		db $33,$08,$F0,$01
		db $33,$F8,$F0,$80
		db $33,$F8,$00,$A0
		db $33,$08,$00,$A2
		db $32,$0B,$E4,$AC

		.EyesClosed
		dw $0018
		db $33,$00,$F0,$03
		db $33,$08,$F0,$04
		db $33,$F8,$F0,$80
		db $33,$F8,$00,$A0
		db $33,$08,$00,$A2
		db $32,$0B,$E4,$AC

		.EyesUp
		dw $0018
		db $33,$00,$F0,$20
		db $33,$08,$F0,$21
		db $33,$F8,$F0,$80
		db $33,$F8,$00,$A0
		db $33,$08,$00,$A2
		db $32,$0B,$E4,$AC

		.EyesDown
		dw $0014
		db $33,$F8,$F0,$40
		db $33,$08,$F0,$24
		db $33,$F8,$00,$60
		db $33,$08,$00,$62
		db $32,$0B,$E4,$AC




	; scepter tilemaps
	.ScepterIdle
		dw $0008
		db $32,$E7,$F2,$C5
		db $32,$EF,$F2,$C6

	.ScepterWalk1
		dw $0008
		db $32,$E1,$F2,$C5
		db $32,$E9,$F2,$C6

	.ScepterWalk2
		dw $0008
		db $32,$E0,$F3,$A5
		db $32,$E8,$F3,$A6

	.ScepterWalk3
		dw $0008
		db $32,$E9,$E4,$AA
		db $32,$E9,$EC,$BA

	.ScepterWalk4
		dw $0008
		db $32,$E6,$F1,$C5
		db $32,$EE,$F1,$C6

	.ScepterWalk5
		dw $0008
		db $32,$E7,$EF,$C5
		db $32,$EF,$EF,$C6

	.ScepterWalk6
		dw $0008
		db $32,$E7,$F2,$A5
		db $32,$EF,$F2,$A6

	.ScepterWalk7
		dw $0008
		db $32,$E8,$E1,$AA
		db $32,$E8,$E9,$BA

	.ScepterFire
		dw $0008
		db $32,$E3,$08,$A5
		db $32,$EB,$08,$A6

	.ScepterThrow
		dw $0008
		db $32,$E8,$D1,$AA
		db $32,$E8,$D9,$BA

	.ScepterSquat
		dw $0008
		db $32,$E4,$F8,$C5
		db $32,$E4,$F8,$C5

	.ScepterJump
		dw $0008
		db $32,$E1,$F1,$C5
		db $32,$E9,$F1,$C6



		.IdleDyn
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($002)
		%SquareDyn($004)
		%SquareDyn($020)
		%SquareDyn($022)
		%SquareDyn($024)
		%SquareDyn($030)
		%SquareDyn($032)
		%SquareDyn($034)
		..end

		.WalkDyn1
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($008)
		%SquareDyn($009)
		%SquareDyn($026)
		%SquareDyn($028)
		%SquareDyn($029)
		%SquareDyn($036)
		%SquareDyn($038)
		%SquareDyn($039)
		..end

		.WalkDyn2
		dw ..end-..start
		..start
		%SquareDyn($00B)
		%SquareDyn($00D)
		%SquareDyn($00E)
		%SquareDyn($02B)
		%SquareDyn($02D)
		%SquareDyn($02E)
		%SquareDyn($03B)
		%SquareDyn($03D)
		%SquareDyn($03E)
		..end

		.WalkDyn3
		dw ..end-..start
		..start
		%SquareDyn($050)
		%SquareDyn($052)
		%SquareDyn($054)
		%SquareDyn($070)
		%SquareDyn($072)
		%SquareDyn($074)
		%SquareDyn($080)
		%SquareDyn($082)
		%SquareDyn($084)
		..end

		.WalkDyn4
		dw ..end-..start
		..start
		%SquareDyn($056)
		%SquareDyn($058)
		%SquareDyn($05A)
		%SquareDyn($076)
		%SquareDyn($078)
		%SquareDyn($07A)
		%SquareDyn($086)
		%SquareDyn($088)
		%SquareDyn($08A)
		..end

		.WalkDyn5
		dw ..end-..start
		..start
		%SquareDyn($0A0)
		%SquareDyn($0A2)
		%SquareDyn($0A4)
		%SquareDyn($0C0)
		%SquareDyn($0C2)
		%SquareDyn($0C4)
		%SquareDyn($0D0)
		%SquareDyn($0D2)
		%SquareDyn($0D4)
		..end

		.WalkDyn6
		dw ..end-..start
		..start
		%SquareDyn($0A6)
		%SquareDyn($0A8)
		%SquareDyn($0AA)
		%SquareDyn($0C6)
		%SquareDyn($0C8)
		%SquareDyn($0CA)
		%SquareDyn($0D6)
		%SquareDyn($0D8)
		%SquareDyn($0DA)
		..end

		.WalkDyn7
		dw ..end-..start
		..start
		%SquareDyn($0F0)
		%SquareDyn($0F2)
		%SquareDyn($0F4)
		%SquareDyn($110)
		%SquareDyn($112)
		%SquareDyn($114)
		%SquareDyn($120)
		%SquareDyn($122)
		%SquareDyn($124)
		..end

		.FireDyn
		dw ..end-..start
		..start
		%SquareDyn($05C)
		%SquareDyn($05E)
		%SquareDyn($07C)
		%SquareDyn($07E)
		..end

		.ThrowDyn1
		dw ..end-..start
		..start
		%SquareDyn($140)
		%SquareDyn($142)
		%SquareDyn($144)
		%SquareDyn($160)
		%SquareDyn($162)
		%SquareDyn($164)
		%SquareDyn($180)
		%SquareDyn($182)
		%SquareDyn($184)
		..end

		.ThrowDyn2
		dw ..end-..start
		..start
		%SquareDyn($146)
		%SquareDyn($148)
		%SquareDyn($14A)
		%SquareDyn($166)
		%SquareDyn($168)
		%SquareDyn($16A)
		%SquareDyn($186)
		%SquareDyn($188)
		%SquareDyn($18A)
		..end

		.SquatDyn
		dw ..end-..start
		..start
		%SquareDyn($0FB)
		%SquareDyn($0FD)
		%SquareDyn($0FE)
		%SquareDyn($11B)
		%SquareDyn($11D)
		%SquareDyn($11E)
		..end

		.JumpDyn
		dw ..end-..start
		..start
		%SquareDyn($0F6)
		%SquareDyn($0F8)
		%SquareDyn($0F9)
		%SquareDyn($116)
		%SquareDyn($118)
		%SquareDyn($119)
		%SquareDyn($126)
		%SquareDyn($128)
		%SquareDyn($129)
		..end







;==============================;
;UPDATE OFFSET-PER-TILE ROUTINE;
;==============================;
UPDATE_MODE2:	PHB						;\
		JSL !GetVRAM					; |
		LDA #$40					; |
		PHA : PLB					; |
		REP #$20					; | update offsets
		LDA.w #$0040 : STA.w !VRAMtable+0,x		; |
		LDA.w #$F000 : STA.w !VRAMtable+2,x		; |
		LDA.w #$40F0 : STA.w !VRAMtable+3,x		; |
		LDA.w #$5020 : STA.w !VRAMtable+5,x		; |
		SEP #$20					;/

	; wave motion code
		REP #$30
		STZ $F07C
		STZ $F07E

		LDX #$0038

		.Loop
		LDA $F040,x
		AND #$01FF^$FFFF
		STA $00
		LDA $F040,x
		AND #$01FF : BEQ .Next				; no motion if timer is zero
		DEC A						;\
		ORA $00						; | decrement timer
		STA $F040,x					;/
		BPL .Up

		.Down
		LDA $F000,x
		AND #$01FF
		CMP $1C : BEQ .Set
		DEC $F000,x : BRA .Next

		.Set
		STZ $F040,x : BRA .Next

		.Up
		INC $F000,x
		INC $F000,x
		LDA $F000,x
		AND #$01FF
		SEC : SBC $1C
		CMP #$0006
		BEQ .Side
		CMP #$000A : BCC .Next
		LDA $F040,x
		ORA #$8000
		STA $F040,x

		.Next
		DEX #2 : BPL .Loop
		SEP #$30
		PLB
		RTS


		.Side
		BIT $00 : BVC .Left

		.Right
		CPX #$0038 : BEQ .Next
		LDA #$41FF : STA $F042,x
		LDA $1C
		INC #2
		ORA #$2000
		STA $F002,x : BRA .Next

		.Left
		CPX #$0004 : BCC .Next
		LDA #$01FF : STA $F03E,x
		BRA .Next



;============;
;WAIT ROUTINE;
;============;
Wait:		LDA !Difficulty
		AND #$03
		TAY
		LDA !Phase,x
		AND #$7F
		CMP #$04
		BNE $01 : INY
		LDA DATA_DelayTable,y : STA !StunTimer,x
		RTS








	SCEPTER:
	namespace off
	namespace Scepter
	MAIN:
		%decreg(!ScepterSFXTimer)

		LDA !StunTimer,x : BNE .Process			;\
		STZ !SpriteYSpeed,x				; |
		STZ !SpriteXSpeed,x				; | hide scepter off-screen unless it's used for an attack
		LDA #!KK_Scepter_Dunk : STA !SpriteAnimIndex	; |
		LDA #$02 : STA !SpriteXHi,x			; |
		STZ !ScepterStatus,x				;/
		LDA !Phase,x					;\
		AND #$7F					; |
		CMP #$05 : BEQ .Process				; | boss grabs the scepter unless he's dead
		LDY !BossIndex,x				; |
		LDA #$00 : STA.w !HoldingScepter,y		;/
		.Process					;\
		LDA !ScepterStatus,x				; |
		ASL A						; | execute status pointer
		TAX						; |
		JSR (StatPtr,x)					;/


	INTERACTION:
		LDA !ScepterHitbox,x : BEQ GRAPHICS		;\
		ASL A						; |
		TAY						; |
		REP #$20					; | hurt players upon contact
		LDA HITBOX-2,y : JSL LOAD_HITBOX		; |
		SEC : JSL !PlayerClipping : BCC GRAPHICS	; |
		JSL !HurtPlayers				;/


	GRAPHICS:
		LDY !BossIndex,x
		LDA $33C0,y : STA $33C0,x
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE +
		LDA.w ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		LDA #$00
	+	STA !SpriteAnimTimer
		JSL LOAD_TILEMAP_COLOR_p3
		PLB
		RTL


	StatPtr:
		dw .MaintainSpeed		; 00
		dw .Boomerang			; 01
		dw .Dunk			; 02
		dw .Fall			; 03
		dw .ArcBounce			; 04
		dw .FireBlast			; 05


		.MaintainSpeed
		LDX !SpriteIndex				; X = sprite index
		STZ !ScepterHitbox,x				; no hitbox


		.Move						;\
		JSL !SpriteApplySpeed-$10			; | move
		JSL !SpriteApplySpeed-$08			;/
		RTS						; return


		.Boomerang
		LDX !SpriteIndex				; X = sprite index
		LDA #$01 : STA !ScepterHitbox,x			; wide hitbox
		LDA !ScepterSFXTimer,x : BNE ..nosfx		;\
		LDA #$08 : STA !ScepterSFXTimer,x		; | slice SFX
		LDA #$3C : STA !SPC4				; |
		..nosfx						;/
		LDY $3320,x					;\
		LDA !SpriteXSpeed,x				; | X acceleration
		CLC : ADC ..xacc,y				; |
		STA !SpriteXSpeed,x				;/
		LDY !BossIndex,x				;\
		LDA !SpriteYLo,x				; |
		CLC : ADC #$10					; |
		CMP !SpriteYLo,y : BCC ..down			; | gravitate to boss' hand
		..up						; |
		DEC !SpriteYSpeed,x : BRA .Move			; |
		..down						; |
		INC !SpriteYSpeed,x : BRA .Move			;/

		..xacc
		db $FF,$01




		.ArcBounce
		JSR .Dunk					; include dunk code
		INC !StunTimer,x				;\
		LDY !BossIndex,x				; |
		LDA !SpriteXLo,x				; |
		SEC : SBC !SpriteXLo,y				; |
		CMP #$14 : BCC ..end				; | always keep going until caught by boss
		CMP #$EC : BCC ..keepgoing			; |
		..end						; |
		STZ !StunTimer,x				; |
		LDA #$10 : STA !StunTimer,y			; > boss takes 16 frames to catch scepter
		..keepgoing					;/
		LDA !SpriteYSpeed,x : BMI ..animdone		;\
		LDA !SpriteAnimIndex				; |
		CMP #!KK_Scepter_Spin+2 : BNE ..animdone	; |
		LDA !SpriteAnimTimer				; | animation (transition at image 2, frame 2)
		CMP #$02 : BNE ..animdone			; |
		LDA #!KK_Scepter_Dunk : STA !SpriteAnimIndex	; |
		LDA #$06 : STA !SpriteAnimTimer			; |
		..animdone					;/
		JSR .SetHitbox					; set hitbox
		LDA !SpriteYSpeed,x : BPL ..eyesdone		;\
		LDY !BossIndex,x				; |
		LDA !HeadAnim,y					; |
		CMP #!KK_Head_Hurt : BEQ ..eyesdone		; | have Kingking follow the scepter with his eyes
		CMP #!KK_Head_Stomped : BEQ ..eyesdone		; |
		LDA #!KK_Head_EyesUp : STA !HeadAnim,y		; |
		LDA #$08 : STA !HeadTimer,y			;/
		..eyesdone					;\
		LDA $3330,x					; |
		AND #$03 : BEQ ..return				; |
		LDA !SpriteXSpeed,x				; |
		EOR #$FF : INC A				; | turn around at walls
		STA !SpriteXSpeed,x				; |
		LDA $3320,x					; |
		EOR #$01					; |
		STA $3320,x					;/
		..return					;\ return
		RTS						;/


		.Dunk
		LDX !SpriteIndex				; X = sprite index
		JSR .SetHitbox					; set hitbox
		JSL !SpriteApplySpeed				; move
		LDA $3330,x					;\ check for ground contact
		AND #$04 : BEQ ..return				;/
		LDA #$C8					;\
		LDY !ScepterStatus,x				; |
		CPY #$04					; | bounce speed
		BNE $02 : LDA #$B0				; |
		STA !SpriteYSpeed,x				;/
		LDA !SpriteXLo,x				;\
		LSR #3						; |
		ASL A						; |
		TAX						; |
		LDA #$FF					; |
		STA $40F040,x					; |
		STA $40F042,x					; | generate waves
		LDA #$01 : STA $40F041,x			; |
		LDA #$41 : STA $40F043,x			; |
		LDX !SpriteIndex				; |
		LDA #$09 : STA !SPC4				; |

		LDA $3320,x : PHA
		ORA #$02
		STA $3320,x
		JSR KingKing_RockDebris
		PLA : STA $3320,x

		STZ !SpriteAnimIndex				; |
		STZ !SpriteAnimTimer				;/
		..return					;\ return
		RTS						;/


		.FireBlast
		LDX !SpriteIndex				; X = sprite index
		LDA #$03 : STA !ScepterHitbox,x			; fireblast hitbox
		LDA #$E8 : STA !SpriteYSpeed,x			; Y speed -24
		JSL !SpriteApplySpeed				; move
		LDA $3330,x					;\ check for wall contact
		AND #$03 : BNE ..explode			;/
		RTS						; return

		..explode
		STZ !StunTimer,x
		LDA !Difficulty
		AND #$03 : TAY
		LDA ..count,y
		..loop
		PHA
		STZ $00
		STZ $01
		ASL A
		STA $02
		JSL SUB_HORZ_POS
		TYA
		CLC : ADC $02
		TAY
		LDA ..xspeed,y : STA $02
		LDA #$C0 : STA $03
		SEC : LDA #$07					;
		JSL SpawnSprite					; spawn
		PLA
		CPY #$FF : BEQ ..fail				; return if fail
		TAX


		LDA #$08 : STA $3230,y
		LDA #$10 : STA !SpritePhaseTimer,y
		LDA #$80 : STA !ProjectileType,y
		LDA #$10 : STA !ProjectileAnimType,y
		LDA #$00
		STA !ProjectileAnimFrames,y
		STA !ProjectileAnimTime,y
		STA !ProjectileTimer,y
		LDA #$03 : STA !ProjectileGravity,y
		LDA #$E0 : STA !SpriteTile,y
		LDA #$00 : STA !SpriteProp,y
		LDA.w !SpriteXSpeed,y
		LSR A
		AND #$40
		ORA #$10
		PHX
		LDX !SpriteIndex
		ORA $33C0,x
		STA $33C0,y
		PLA
		DEC A : BMI ..fail
		BRA ..loop
		..done
		LDX !SpriteIndex
		..fail
		RTS

		..xspeed
		db $20,$E0
		db $10,$F0
		db $18,$E8
		db $08,$F8


		..count
		db $01,$02,$03



		.Fall
		LDX !SpriteIndex				; X = sprite index
		STZ !ScepterHitbox,x				; no hitbox
		LDA !SpriteYSpeed,x : BMI ..down		;\ acceclerate down until at speed 0x40
		CMP #$40 : BCS ..move				;/
		..down						;\
		INC !SpriteYSpeed,x				; | accelerate down
		INC !SpriteYSpeed,x				;/
		..move						;\
		JSL !SpriteApplySpeed-$10			; | move
		JSL !SpriteApplySpeed-$08			;/
		RTS						; return


		.SetHitbox					;\
		LDY !SpriteAnimIndex				; | set hitbox based on animation frame
		LDA ..table,y : STA !ScepterHitbox,x		;/
		RTS						; return

		..table
		db $01
		db $01
		db $01
		db $02
		db $01
		db $02
		db $00
		db $03
		db $03




	ANIM:
	; spin
		dw .SpinTM00 : db $03,!KK_Scepter_Spin+1
		dw .SpinTM01 : db $03,!KK_Scepter_Spin+2
		dw .SpinTM02 : db $03,!KK_Scepter_Spin+0
	; idle
		dw .IdleTM00 : db $FF,!KK_Scepter_Idle
	; dunk
		dw .DunkTM00 : db $10,!KK_Scepter_Dunk+1
		dw .DunkTM01 : db $FF,!KK_Scepter_Dunk+1
	; fall
		dw .FallTM00 : db $FF,!KK_Scepter_Fall
	; fire blast
		dw .FireTM00 : db $FF,!KK_Scepter_Fire


		.SpinTM00
		dw $0008
		db $32,$FC,$00,$E4
		db $32,$04,$00,$E5
		.SpinTM01
		dw $0008
		db $32,$FC,$00,$E7
		db $32,$04,$00,$E8
		.SpinTM02
		dw $0008
		db $32,$FC,$00,$EA
		db $32,$04,$00,$EB

		.IdleTM00
		dw $0008
		db $32,$00,$00,$A8
		db $32,$00,$08,$B8

		.DunkTM00
		dw $0008
		db $B2,$FC,$00,$C5
		db $B2,$04,$00,$C6
		.DunkTM01
		dw $0008
		db $B2,$00,$08,$AA
		db $B2,$00,$00,$BA

		.FallTM00
		dw $0008
		db $32,$E8,$00,$AA
		db $32,$E8,$08,$BA

		.FireTM00
		dw $0010
		db $32,$F8,$F8,$A0
		db $32,$08,$F8,$A2
		db $32,$F8,$08,$C0
		db $32,$08,$08,$C2



	HITBOX:
		dw .Wide			; 01
		dw .Tall			; 02
		dw .FireBlast			; 03

	.Wide
		dw $0002,$0002 : db $14,$0C

	.Tall
		dw $0002,$0002 : db $0C,$14

	.FireBlast
		dw $0004,$0004 : db $18,$18


	namespace off

















