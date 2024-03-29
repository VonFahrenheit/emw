

	!Temp = 0
	%def_anim(Rex_Walk, 4)
	%def_anim(Rex_Flutter, 4)
	%def_anim(Rex_Small, 2)
	%def_anim(Rex_Hurt, 1)
	%def_anim(Rex_Dead, 1)


	!RexChase		= $3400
	!RexConga		= $3410
	!RexDensity		= $3420		; 0 = normal rex, 1 = dense rex
	!RexTarget		= $3430		; 0 = P1, 80 = P2


Rex:

	namespace Rex

	INIT:
		RTL

	Dense_INIT:
		INC !RexDensity,x
		LDA #$0C : STA !ExtraBits,x
		LDA !ExtraProp1,x : BEQ INIT
		DEC A : STA !SpriteDir,x
		STZ !ExtraProp1,x
		RTL

	Dense_MAIN:
		LDA #$60 : STA !SpriteFallSpeed,x		; max fall speed = 0x60
		LDA !SpriteHP,x : BNE MAIN
		LDA !SpriteWater,x : BNE MAIN
		LDA #$02 : STA !SpriteGravity,x
		LDA !SpriteYSpeed,x : BMI MAIN
		DEC !SpriteGravity,x				; gravity mod moving down: -2

		LDA $14
		LSR A : BCC +
		JSL AccelerateX_Friction1
	+	JSL AccelerateX_Friction1


	MAIN:
		PHB : PHK : PLB
		LDA !SpriteStatus,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA !SpriteHP,x : BNE .Graphics
		LDA #$02 : STA !SpriteHP,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		.Graphics
		JMP GRAPHICS


		.Return
		PLB
		RTL


	PHYSICS:
		LDA !ExtraProp1,x					;\ check golden bandit mode
		CMP #$FF : BNE .NotGolden				;/

		.TurnGold
		SEC : LDA #$22						;\
		JSL SpawnSprite						; |
		CPY #$FF : BNE .Spawn					; | try to spawn a yoshi coin
		STZ !SpriteStatus,x					; |
		PLB							; |
		RTL							;/

		.Spawn
		LDA #$01 : STA !SpriteStatus,y				;\
		JSL SPRITE_A_SPRITE_B_COORDS				; |
		TXA : STA $3290,y					; | spawn hidden yoshi coin
		LDA !ExtraProp2,x					; |
		ORA #$80						; |
		STA !ExtraProp1,y					;/
		LDA #$04 : STA !SpriteOAMProp,x				; set palette
		LDA #$01 : STA !ExtraProp1,x				; bandit bag
		LDA #$05 : STA !ExtraProp2,x				; bandit hat
		LDA !SpriteTweaker3,x					;\ bandit can't despawn
		ORA #$80 : STA !SpriteTweaker3,x			;/
		LDA !SpriteID,x : TAX					;\
		LDA #$EE : STA !SpriteLoadStatus,x			; | bandit can't respawn
		LDX !SpriteIndex					; |
		.NotGolden						;/

		LDA !SpriteOAMProp,x					;\
		AND #$0E						; |
		CMP #$04 : BNE .NotGlitter				; | only spawn one yoshi coin
		JSL MakeGlitter						; |
		.NotGlitter						;/



		.Alert
		LDA !RexChase,x : BEQ ..checkchase
		JMP ..nochase
		..checkchase
		LDY #$00
		LDA !RexDensity,x : BNE ..shortsight			; this sight box for dense rex
		LDA !ExtraProp1,x					;\ chase if carrying sword
		CMP #$05 : BEQ ..chase					;/
		CMP #$01 : BNE ..nochase				;\
		LDA !ExtraProp2,x					; | reverse chase is carrying sack and bandit bandana
		CMP #$05 : BNE ..nochase				;/
		..chase							;\
		LDA !ExtraProp1,x					; |
		CMP #$05 : BNE ..shortsight				; |
		LDA !ExtraBits,x					; |
		AND #$04 : BEQ ..longsight				; | sight box
		..shortsight						; |
		LDA #$1D : BRA +					; |
		..longsight						; |
		LDA #$1C						; |
	+	JSL GetSpriteClippingE8_A				;/
		JSL PlayerContact : BCC ..nochase
		DEC A
		ROR #2
		AND #$80 : STA !RexTarget,x				; remember which player was seen
		LDA #$01 : STA !RexChase,x
		LDA #$82 : STA !SpriteTweaker6,x			; soldier behavior
		LDA !SpriteHP,x : BNE ..nosfx
		LDA #$1E : STA !SPC4					; chase SFX
		..nosfx

		LDA !ExtraBits,x					;\ clear extra bit
		AND.b #$04^$FF : STA !ExtraBits,x			;/

		LDA !ExtraProp1,x
		CMP #$01 : BNE ..nochase
		INC !RexChase,x						; reverse chase flag if bandit
		LDA #$86 : STA !SpriteTweaker6,x			; bandit behvaior
		LDA #$26 : STA !SPC4					; flee SFX
		..nochase


		.CeilingBonk
		LDA !SpriteBlocked,x
		AND #$08 : BEQ ..done
		STA !SpriteYSpeed,x
		..done


		.HandleGroundYSpeed
		LDA !RexChase,x						;\ don't update y speed when chasing
		CMP #$02 : BCS ..done					;/
		LDA !SpriteBlocked,x					;\ don't update y speed in midair
		AND #$04 : BEQ ..done					;/
		LDA !SpriteYSpeed,x : BMI ..alive			;\
		CMP #$41 : BCC ..alive					; | don't update speed if in these thresholds
		CMP #$50 : BCC ..hurt					;/
		..kill							;\ dead
		LDA #$01 : STA !SpriteHP,x				;/
		..hurt							;\
		STZ !SpriteYSpeed,x					; | freeze
		JMP INTERACTION_HurtSprite				;/
		..alive							;\
		JSL GroundSpeed						; | default y speed on ground
		..done							;/


		LDA !SpriteAnimIndex,x
		CMP #!Rex_Hurt : BCC ..nothurt
	-	JMP ..nochase
		..nothurt
		LDA !RexChase,x : BEQ -
		CMP #$01 : BEQ ..normal
		CMP #$03 : BEQ ..normal
		..reverse
		JSL SUB_HORZ_POS
		TYA
		EOR #$01 : STA !SpriteDir,x
		LDA !SpriteOAMProp,x
		CMP #$04 : BEQ ..goldrun
		LDA #$01 : BRA +
		..goldrun
		LDA #$02 : BRA +
		..normal
		LDA !RexDensity,x : BEQ ..canturn			; dense rex does not chase player
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..nochase
		..denseaccel
		LDA !SpriteHP,x
		EOR #$01
		ASL A
		BRA +
		..canturn
		LDY !RexTarget,x : JSL SUB_HORZ_POS_Target
		TYA : STA !SpriteDir,x
		LDA !Difficulty
	+	ASL A
		ADC !SpriteDir,x
		TAY
		LDA !SpriteXSpeed,x
		EOR DATA_XSpeed+4,y : BPL ..nosmoke
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..nosmoke
		LDA $14
		AND #$03 : BNE ..nosmoke
		PHY
		LDA #$04 : STA $00
		LDA #$0C : STA $01
		LDA DATA_SmokeXSpeed,y : STA $02
		STZ $03
		STZ $04
		STZ $05
		LDA #$30 : STA $07
		LDA #!prt_smoke8x8 : JSL SpawnParticle
		PLY
		..nosmoke
		LDA DATA_XSpeed+4,y : JSL AccelerateX
		LDA !SpriteAnimIndex,x
		CMP #!Rex_Walk_over : BCS ..nospeed
		LDA !SpriteAnimTimer,x
		INC A
		CMP #$0F
		BCC $02 : LDA #$0F
		STA !SpriteAnimTimer,x
		BRA ..nospeed
		..nochase
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..nospeed
		STZ !SpriteXSpeed,x
		JSL GroundSpeed
		LDA !SpriteAnimIndex,x
		CMP #!Rex_Hurt : BCS ..nospeed
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDY !SpriteDir,x
		LDA !SpriteHP,x
		BEQ $02 : INY #2
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed



		.HandleSpeed
		LDA !RexConga,x						;\
		AND $14 : BEQ ..noconga					; |
		LDA !SpriteYSpeed,x : PHA				; |
		BMI +							; | conga
		STZ !SpriteYSpeed,x					; |
	+	JSL APPLY_SPEED						; |
		PLA : STA !SpriteYSpeed,x				; |
		..noconga						;/

		JSL APPLY_SPEED



	INTERACTION:
		LDA !SpriteAnimIndex,x
		CMP #!Rex_Dead : BEQ .Done
		JSL GetSpriteClippingE8

		.Attacks
		JSL InteractAttacks : BCS .HurtSprite

		.Body
		JSL P2Standard
		BCC .Done
		BEQ .Done

		LDA !SpriteHP,x : BEQ .HurtSprite
		STZ !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		LDA #!Rex_Dead : BRA +

		.HurtSprite
		LDA !SpriteHP,x : BEQ ..hurt
		..kill
		LDA #$02 : STA !SpriteStatus,x
		BRA ..inc
		..hurt
		LDA #!Rex_Hurt
	+	STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..inc
		INC !SpriteHP,x
		STZ !SpriteBlocked,x
		LDA #$10 : STA !SpriteDisSprite,x

		.Done


	AI:
		STZ !RexConga,x
		LDA !RexDensity,x : BNE .Done

		LDA !RexChase,x : BEQ .Done
		.CongaBrain
		LDA #$02 : JSL GetSpriteClippingE8_A
		LDX #$0F

		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !SpriteNum,x
		CMP #$02 : BNE ..next
		LDA !SpriteStatus,x
		CMP #$08 : BNE ..next
		LDA !RexChase,x : BEQ ..next
		LDA !RexConga,x : BNE ..next
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next

		..conga
		LDX !SpriteIndex
		LDA #$01 : STA !RexConga,x
		BRA .Done

		..next
		DEX : BPL ..loop
		LDX !SpriteIndex

		.Done




	GRAPHICS:
		.Palette
		LDA !RexDensity,x : BNE ..nochange
		LDY !RexChase,x
		LDA DATA_Pal,y : BEQ ..nochange
		STA !SpriteOAMProp,x
		..nochange

		LDA !SpriteHP,x : BEQ .Anim

		LDA !SpriteAnimIndex,x
		CMP #!Rex_Hurt : BNE .NoHurt
		LDA !ExtraProp1,x
		CMP #$05 : BNE .NoSword
		INC !ExtraProp1,x
		BRA .NoSword
		.NoHurt
		LDA !ExtraProp1,x
		CMP #$06 : BNE .NoSword
		INC !ExtraProp1,x
		.NoSword

		LDA !ExtraProp1,x : BEQ .NoDrop
		CMP #$05 : BCS .NoDrop
		JSR DropItem
		.NoDrop


		LDA !ExtraProp2,x : BEQ .NoDropHat
		LDY !SpriteAnimIndex,x
		CPY.b #!Rex_Dead : BEQ +

		CMP #$09 : BEQ .NoDropHat
		LDY !SpriteStatus,x
		CPY #$02 : BEQ +
		CPY #$04 : BEQ +
		CMP #$05 : BEQ .NoDropHat
		CMP #$06 : BNE +
		LDA #$09 : STA !ExtraProp2,x
		BRA .NoDropHat
	+	JSR DropHat
		.NoDropHat




		LDA !ExtraBits,x					;\
		AND #$04^$FF						; | clear extra bit so sprite can move again
		STA !ExtraBits,x					;/
		STZ !SpriteTweaker2,x					; clear tweaker 2 to make hurtbox smaller
		REP #$20
		LDA.w #!GFX_RexSmall_offset : JSL LoadGFXIndex
		BRA .HandleUpdate

		.Anim
		LDA !RexDensity,x : BEQ ..notdense
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..flutter
		..walk
		LDA !SpriteAnimIndex,x
		CMP #!Rex_Walk_over : BCC ..notdense
		LDA #!Rex_Walk : BRA ++
		..flutter
		LDA !SpriteYSpeed,x : BPL +
		LDA #!Rex_Walk+1 : BRA ++
	+	LDA !SpriteAnimIndex,x
		CMP #!Rex_Flutter : BCC +
		CMP #!Rex_Flutter_over : BCC ..notdense
	+	LDA.b #!Rex_Flutter
	++	STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..notdense


		LDA !ExtraBits,x
		AND #$04 : BEQ .HandleUpdate
		LDA !SpriteAnimIndex,x
		CMP #!Rex_Walk_over : BCS .HandleUpdate
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		.HandleUpdate
		LDA !SpriteAnimIndex,x
		ASL #2
		TAY
		LDA !SpriteAnimTimer,x
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y
		CMP #$FF : BNE ..ok
		STZ !SpriteStatus,x
		PLB
		RTL

	..ok	STA !SpriteAnimIndex,x
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer,x


	; draw bag
		LDA !ExtraProp1,x : BEQ .NoBag
		ASL A
		TAY
		LDA !SpriteTile,x : PHA
		LDA !SpriteProp,x : PHA
		REP #$20
		LDA ANIM_BagIndex-2,y : JSL LoadGFXIndex
		LDA !ExtraProp1,x
		DEC A
		ASL #3
		TAY
		CMP.b #ANIM_BagPtr_End-ANIM_BagPtr
		BCC $02 : LDA #$00
		STA $00
		LDA !SpriteAnimIndex,x
		AND #$03
		ASL A
		ADC $00
		TAY
		REP #$20
		LDA ANIM_BagPtr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_p2
		REP #$20
		LDA $08 : STA $04
		LDA ($04)
		SEP #$20
		BMI .BagDone
		JSL LOAD_PSUEDO_DYNAMIC_p1
		.BagDone
		PLA : STA !SpriteProp,x
		PLA : STA !SpriteTile,x
		.NoBag


	; draw hat
		LDA !ExtraProp2,x : BEQ .NoHat
		ASL A : TAY
		LDA !SpriteTile,x : PHA
		LDA !SpriteProp,x : PHA

		LDA !SpriteYLo,x : PHA
		LDA !SpriteYHi,x : PHA
		LDA !SpriteAnimIndex,x
		CMP.b #!Rex_Small : BCC +
		CMP.b #!Rex_Small_over : BCS +
		LDA !SpriteYLo,x
		CLC : ADC #$10
		STA !SpriteYLo,x
		LDA !SpriteYHi,x
		ADC #$00
		STA !SpriteYHi,x
		+

		REP #$20
		LDA ANIM_HatIndex-2,y : JSL LoadGFXIndex
		LDA !ExtraProp2,x
		DEC A
		ASL #2
		TAY
		CMP.b #ANIM_HatPtr_End-ANIM_HatPtr
		BCC $02 : LDA #$00
		STA $00
		LDA !SpriteAnimIndex,x
		AND #$01
		ASL A
		ADC $00
		TAY
		REP #$20
		LDA ANIM_HatPtr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLA : STA !SpriteYHi,x
		PLA : STA !SpriteYLo,x

		PLA : STA !SpriteProp,x
		PLA : STA !SpriteTile,x
		.NoHat


	; draw head
		LDA !SpriteAnimIndex,x
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC


	; draw legs
		REP #$20
		LDA.w #!GFX_RexLegs1_offset
		LDY !ExtraProp1,x
		BEQ $02 : INC #2
		JSL LoadGFXIndex
		REP #$20
		LDA $08 : STA $04
		LDA ($04)
		SEP #$20
		BMI .Return
		JSL LOAD_PSUEDO_DYNAMIC

		.Return
		PLB
		RTL


	ANIM:
	; walk
		dw .TM_Walk00 : db $10,!Rex_Walk+1
		dw .TM_Walk01 : db $10,!Rex_Walk+2
		dw .TM_Walk00 : db $10,!Rex_Walk+3
		dw .TM_Walk02 : db $10,!Rex_Walk+0
	; flutter
		dw .TM_Flutter00 : db $02,!Rex_Flutter+1
		dw .TM_Flutter01 : db $02,!Rex_Flutter+2
		dw .TM_Flutter00 : db $02,!Rex_Flutter+3
		dw .TM_Flutter02 : db $02,!Rex_Flutter+0
	; small
		dw .TM_Small00 : db $07,!Rex_Small+1
		dw .TM_Small01 : db $07,!Rex_Small+0
	; hurt
		dw .TM_Hurt00 : db $10,!Rex_Small+0
	; dead
		dw .TM_Dead00 : db $20,$FF

	.TM_Flutter00
	.TM_Walk00
		dw $0004
		db $22,$00,$F0,$00
		dw $0008
		db $22,$00,$00,$00
		db $22,$08,$00,$01
	.TM_Walk01
		dw $0004
		db $22,$00,$EF,$00
		dw $0008
		db $22,$00,$FF,$03
		db $22,$08,$FF,$04
	.TM_Walk02
		dw $0004
		db $22,$00,$EF,$00
		dw $0008
		db $22,$00,$FF,$06
		db $22,$08,$FF,$07

	.TM_Flutter01
		dw $0004
		db $22,$00,$F0,$00
		dw $0008
		db $22,$00,$00,$03
		db $22,$08,$00,$04
	.TM_Flutter02
		dw $0004
		db $22,$00,$F0,$00
		dw $0008
		db $22,$00,$00,$06
		db $22,$08,$00,$07

	.TM_Hurt00
		dw $0008
		db $22,$00,$F0,$00
		db $22,$00,$00,$02
		dw $FFFF

	.TM_Small00
		dw $0004
		db $22,$00,$00,$05
		dw $FFFF
	.TM_Small01
		dw $0004
		db $22,$00,$00,$07
		dw $FFFF

	.TM_Dead00
		dw $0004
		db $22,$00,$00,$09
		dw $FFFF



	; format: GFX index, ccc bits
	.HatIndex
		dw !GFX_RexHat1_offset				; 01
		dw !GFX_RexHat2_offset				; 02
		dw !GFX_RexHat3_offset				; 03
		dw !GFX_RexHat4_offset				; 04
		dw !GFX_RexHat5_offset				; 05
		dw !GFX_RexHat6_offset				; 06
		dw !GFX_RexHat7_offset				; 07
		dw !GFX_RexHelmet_offset			; 08
		dw !GFX_RexHat6_offset				; 09

	; format: GFX index, ccc bits
	.BagIndex
		dw !GFX_RexBag1_offset				; 01
		dw !GFX_RexBag2_offset				; 02
		dw !GFX_RexBag3_offset				; 03
		dw !GFX_RexBag4_offset				; 04
		dw !GFX_RexSword_offset				; 05
		dw !GFX_RexSword_offset				; 06
		dw !GFX_RexSword_offset				; 07

	.HatPtr
		dw .Hat1,.Hat1_tilt				; 01
		dw .Hat2,.Hat2_tilt				; 02
		dw .Hat3,.Hat3_tilt				; 03
		dw .Hat4,.Hat4_tilt				; 04
		dw .Hat5,.Hat5_tilt				; 05
		dw .Hat6,.Hat6_tilt				; 06
		dw .Hat7,.Hat7_tilt				; 07
		dw .Helmet,.Helmet_tilt				; 08
		dw .SmallHat,.SmallHat_tilt			; 09
		..End

	.BagPtr
		dw .Bag1,.Bag1_tilt1,.Bag1,.Bag1_tilt2		; 01
		dw .Bag2,.Bag2_tilt1,.Bag2,.Bag2_tilt2		; 02
		dw .Bag3,.Bag3_tilt1,.Bag3,.Bag3_tilt2		; 03
		dw .Bag4,.Bag4_tilt1,.Bag4,.Bag4_tilt2		; 04
		dw .Sword,.Sword_tilt1,.Sword,.Sword_tilt2	; 05
		dw .SwordHurt,.SwordHurt_tilt1,.SwordHurt,.SwordHurt_tilt2	; 06
		dw .SwordSmall,.SwordSmall_tilt1,.SwordSmall,.SwordSmall_tilt2	; 07
		..End

		.Hat1		; green robin hood hat
		dw $0004
		db $1B,$03,$E8,$00
		..tilt
		dw $0004
		db $1B,$03,$E7,$00

		.Hat2		; red hat with bow
		dw $0004
		db $19,$04,$E9,$00
		..tilt
		dw $0004
		db $19,$04,$E8,$00

		.Hat3		; straw hat
		dw $0004
		db $19,$05,$E8,$00
		..tilt
		dw $0004
		db $19,$05,$E7,$00

		.Hat4		; fez
		dw $0004
		db $19,$04,$EC,$00
		..tilt
		dw $0004
		db $19,$04,$EB,$00

		.Hat5		; bandit bandana
		dw $0004
		db $17,$04,$F0,$00
		..tilt
		dw $0004
		db $17,$04,$EF,$00

		.Hat6		; top hat and mustache
		dw $0008
		db $17,$05,$E4,$00
		db $19,$FD,$F7,$02
		..tilt
		dw $0008
		db $17,$05,$E3,$00
		db $19,$FD,$F6,$02

		.Hat7		; sports bandana
		dw $0004
		db $17,$06,$EE,$00
		..tilt
		dw $0004
		db $17,$06,$ED,$00

		.Helmet		; ...helmet
		dw $0004
		db $17,$04,$EB,$00
		..tilt
		dw $0004
		db $17,$04,$EA,$00

		.SmallHat	; top hat and mustache (small version)
		dw $0008
		db $17,$05,$E7,$00
		db $19,$FD,$F5,$02
		..tilt
		dw $0008
		db $17,$05,$E6,$00
		db $19,$FD,$F4,$02



		.Bag1		; coin bag
		dw $0004
		db $20,$07,$00,$00
		dw $0004
		db $15,$0A,$FB,$01
		..tilt1
		dw $0004
		db $20,$08,$FF,$00
		dw $0004
		db $15,$0B,$FA,$01
		..tilt2
		dw $0004
		db $20,$06,$FF,$00
		dw $0004
		db $15,$09,$FA,$01

		.Bag2		; mushroom bindle
		dw $0004
		db $20,$07,$FE,$00
		dw $0004
		db $19,$0E,$F7,$01
		..tilt1
		dw $0004
		db $20,$07,$FD,$00
		dw $0004
		db $19,$0E,$F6,$01
		..tilt2
		dw $0004
		db $20,$08,$FD,$00
		dw $0004
		db $19,$0F,$F6,$01

		.Bag3		; backpack
		dw $0004
		db $20,$08,$FD,$00
		dw $0004
		db $17,$09,$F8,$01
		..tilt1
		..tilt2
		dw $0004
		db $20,$08,$FC,$00
		dw $0004
		db $17,$09,$F7,$01


		.Bag4		; box
		dw $0008
		db $20,$03,$FE,$00
		db $17,$F9,$FB,$01
		dw $FFFF
		..tilt1
		..tilt2
		dw $0008
		db $20,$03,$FD,$00
		db $17,$F9,$FA,$01
		dw $FFFF

		.Sword		; ...sword
		dw $0008
		db $16,$FF,$F8,$00
		db $20,$0D,$00,$02
		dw $FFFF
		..tilt1
		dw $0008
		db $16,$00,$F7,$00
		db $20,$0D,$FF,$12
		dw $FFFF
		..tilt2
		dw $0008
		db $16,$FF,$F7,$00
		db $20,$0B,$FF,$12
		dw $FFFF

		.SwordHurt	; ...sword
		..tilt1
		..tilt2
		dw $0008
		db $16,$01,$FA,$00
		db $20,$0D,$00,$02
		dw $FFFF

		.SwordSmall	; ...sword
		dw $0008
		db $16,$01,$00,$00
		db $20,$0F,$08,$02
		dw $FFFF
		..tilt1
		dw $0008
		db $16,$00,$FF,$00
		db $20,$0D,$07,$12
		dw $FFFF
		..tilt2
		dw $0008
		db $16,$FF,$FF,$00
		db $20,$0B,$07,$12
		dw $FFFF


	DropHat:
		LDA !SpriteTile,x : PHA					;\ push index stuff
		LDA !SpriteProp,x : PHA					;/

		LDA !ExtraProp2,x					;\
		DEC A							; |
		ASL A							; |
		PHA							; |
		ASL A							; | hat index + pointer
		TAY							; |
		REP #$20						; |
		LDA.w ANIM_HatPtr,y : STA $04				; |
		PLY							; |
		LDA.w ANIM_HatIndex,y : JSL LoadGFXIndex		;/

		STZ !ExtraProp2,x					; clear hat

		STZ $00
		LDA #$18 : STA $01
		LDY !SpriteDir,x
		LDA DATA_HatXSpeed,y : STA $02
		LDA #$E8 : STA $03
		LDY #$02
		JSL SpawnSpriteTile

		PLA : STA !SpriteProp,x					;\ restore index stuff
		PLA : STA !SpriteTile,x					;/
		RTS


	DropItem:
		LDA !ExtraProp1,x : BNE .Drop
	.Return	RTS

		.Drop
		STZ !ExtraProp1,x
		TAY
		LDA !SpriteOAMProp,x
		CMP #$04 : BEQ .Return
		CPY #$01 : BEQ .TinyCoins
		CPY #$02 : BNE .Return

		.Mushroom
		STZ $00
		STZ $01
		CLC : LDA #$74
		JSL SpawnSprite
		CPY #$FF : BEQ .Return
		LDA #$08 : STA !SpriteStatus,y
		LDA #$20						;\
		STA !SpriteDisP1,y					; | prevent dropped item from interacting for a bit
		STA !SpriteDisP2,y					;/
		LDA #$D0 : STA.w !SpriteYSpeed,y
		PHX
		LDA !SpriteDir,x : TAX
		EOR $08
		AND #$01 : STA !SpriteDir,y
		TAX
		LDA .XSpeed,x : STA.w !SpriteXSpeed,y
		PLX
		RTS

		.TinyCoins
		LDA !ExtraProp2,x					;\
		CMP #$05 : BEQ ..16					; |
		..2							; |
		LDY #$01 : BRA ..loop					; |
		..16							; | bandit has 9-16 coins, others have 2
		LDA !RNG						; |
		AND #$07						; |
		ORA #$08						; |
		TAY							;/
		..loop
		PHY
		STZ $00
		STZ $01
		LDA !RNGtable,y
		AND #$1F
		SBC #$10
		STA $02
		LDA #$E0 : STA $03
		STZ $04
		LDA #$18 : STA $05
		STZ $06
		STZ $07
		LDA.b #!prt_tinycoin : JSL SpawnParticle
		PLY
		DEY : BPL ..loop
		RTS

		.XSpeed
		db $10,$F0



	DATA:
		.XSpeed
		db $08,$F8	; walk big
		db $10,$F0	; walk small
		db $10,$F0	; knight EASY
		db $18,$E8	; knight NORMAL
		db $20,$E0	; knight INSANE

		.SmokeXSpeed
		db $F8,$08
		db $F4,$0C
		db $F0,$10

		.HatXSpeed
		db $F8,$08

		.Pal
		db $00,$08,$00,$08	; knight turns red, assassin turns red, otherwise no change


	namespace off


