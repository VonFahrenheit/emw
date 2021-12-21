

	!Temp = 0
	%def_anim(Rex_Walk, 4)
	%def_anim(Rex_Small, 2)
	%def_anim(Rex_Hurt, 1)
	%def_anim(Rex_Dead, 1)


	!RexChase		= $3280
	!RexConga		= $3290
	!RexDensity		= $32A0		; 0 = normal rex, 1 = dense rex


Rex:

	namespace Rex

	INIT:
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		RTL

	Dense_INIT:
		LDA #!palset_generic_lightblue : JSL LoadPalset
		LDX $0F
		LDA !Palset_status,x
		LDX !SpriteIndex
		ASL A
		STA $33C0,x
		INC !RexDensity,x
		LDA #$0C : STA !ExtraBits,x
		BRA INIT

	Dense_MAIN:
		LDA !SpriteYSpeed,x : BMI .NormalGravity
		CMP #$40 : BCC .NormalGravity
		LDA #$02 : STA !SpriteGravityTimer,x		;\ -2 gravity when falling faster than 0x40
		LDA #$FF : STA !SpriteGravityMod,x		;/
		.NormalGravity
		LDA #$60 : STA !SpriteFallSpeed,x

	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN
		LDA $9D : BEQ .Process
		JMP GRAPHICS

		.Process
		LDA $3230,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA $BE,x : BNE .Graphics
		LDA #$02 : STA $BE,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

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
		STZ $3230,x						; |
		PLB							; |
		RTL							;/

		.Spawn
		LDA #$01 : STA $3230,y					;\
		JSL SPRITE_A_SPRITE_B_COORDS				; |
		TXA : STA $3290,y					; | spawn hidden yoshi coin
		LDA !ExtraProp2,x					; |
		ORA #$80						; |
		STA !ExtraProp1,y					;/
		LDA #$04 : STA $33C0,x					; set palette
		LDA #$01 : STA !ExtraProp1,x				; bandit bag
		LDA !ExtraProp2,x					;\
		AND #$C0						; | bandit hat
		ORA #$05						; |
		STA !ExtraProp2,x					;/
		LDA !SpriteTweaker4,x					;\
		ORA #$04						; | bandit can't despawn
		STA !SpriteTweaker4,x					;/
		LDA $33F0,x : TAX					;\
		LDA #$EE : STA !SpriteLoadStatus,x			; | bandit can't respawn
		LDX !SpriteIndex					; |
		.NotGolden						;/

		LDA $33C0,x						;\
		AND #$0E						; |
		CMP #$04 : BNE .NotGlitter				; | only spawn one yoshi coin
		JSL MakeGlitter						; |
		.NotGlitter						;/



		.Alert
		LDA !RexChase,x : BNE ..nochase
		LDY #$00
		LDA !RexDensity,x : BNE ..1				; this sight box for dense rex
		LDA !ExtraProp1,x					;\ chase if carrying sword
		CMP #$05 : BEQ ..chase					;/
		CMP #$01 : BNE ..nochase				;\
		LDA !ExtraProp2,x					; | reverse chase is carrying sack and bandit bandana
		AND #$3F						; |
		CMP #$05 : BNE ..nochase				;/
		..chase
		LDA !ExtraProp1,x
		CMP #$05 : BNE ..1
		LDA !ExtraBits,x
		AND #$04 : BEQ ..0
		..1
		INY
		..0
		LDA !SpriteXLo,x
		SEC : SBC DATA_SightX,y
		STA $04
		LDA !SpriteXHi,x
		SBC #$00
		STA $0A
		LDA !SpriteYLo,x
		SEC : SBC #$30
		STA $05
		LDA !SpriteYHi,x
		SBC #$00
		STA $0B
		LDA DATA_SightW,y : STA $06
		LDA #$40 : STA $07
		SEC : JSL !PlayerClipping : BCC ..nochase
		LDA #$01 : STA !RexChase,x
		LDA #$1E : STA !SPC4					; chase SFX

		LDA !ExtraBits,x					;\ clear extra bit
		AND.b #$04^$FF : STA !ExtraBits,x			;/

		LDA !ExtraProp1,x
		CMP #$01 : BNE ..nochase
		INC !RexChase,x						; reverse chase flag if bandit
		LDA #$26 : STA !SPC4					; flee SFX
		..nochase


		.Speed
		LDA $3330,x
		AND #$08 : BEQ +
		STA !SpriteYSpeed,x
		+


		.HandleGroundYSpeed
		LDA !RexChase,x
		CMP #$02 : BCS ..done
		LDA $3330,x
		AND #$04 : BEQ ..done
		LDA !SpriteYSpeed,x : BMI ..alive
		CMP #$50 : BCC ..alive
		CMP #$60 : BCC ..hurt
		..kill
		LDA #$01 : STA $BE,x
		..hurt
		STZ !SpriteYSpeed,x
		JMP INTERACTION_Body_contact
		..alive
		LDA #$10 : STA !SpriteYSpeed,x
		..done


		LDA !SpriteAnimIndex
		CMP #!Rex_Hurt : BCC ..nothurt
	-	JMP ..nochase
		..nothurt
		LDA !RexChase,x : BEQ -
		CMP #$01 : BEQ ..normal
		CMP #$03 : BEQ ..normal
		..reverse
		JSL SUB_HORZ_POS
		TYA
		EOR #$01 : STA $3320,x
		LDA $33C0,x
		CMP #$04 : BEQ ..goldrun
		LDA #$01 : BRA +
		..goldrun
		LDA #$02 : BRA +
		..normal
		LDA !RexDensity,x : BEQ ..canturn			; dense rex does not chase player
		LDA $3330,x
		AND #$03 : BEQ +
		LDA $3320,x
		EOR #$01 : STA $3320,x
		STZ !SpriteXSpeed,x
		LDA #$00 : BRA +
		..canturn
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA !Difficulty
		AND #$03
	+	ASL A
		ADC $3320,x
		TAY
		LDA !SpriteXSpeed,x
		EOR DATA_XSpeed+4,y : BPL ..nosmoke
		LDA $3330,x
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
		LDA !SpriteAnimIndex
		CMP #!Rex_Walk_over : BCS ..nospeed
		LDA !SpriteAnimTimer
		INC A
		CMP #$0F
		BCC $02 : LDA #$0F
		STA !SpriteAnimTimer
		BRA ..nospeed
		..nochase

		LDA $3330,x
		AND #$04 : BEQ ..nospeed
		STZ !SpriteXSpeed,x
		JSL GroundSpeed
		LDA !SpriteAnimIndex
		CMP #!Rex_Hurt : BCS ..nospeed
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDY $3320,x
		LDA $BE,x
		BEQ $02 : INY #2
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA $3220,x : PHA
		LDA $3250,x : PHA
		LDA $3330,x
		AND #$04 : PHA

		LDA !RexDensity,x : BNE ..noconga
		LDA !RexConga,x
		AND $14 : BEQ ..noconga
		LDA !SpriteYSpeed,x : PHA
		BMI +
		STZ !SpriteYSpeed,x
	+	JSL !SpriteApplySpeed
		PLA : STA !SpriteYSpeed,x
		..noconga
		JSL !SpriteApplySpeed
		PLA : BEQ ..checkwall
		LDA $3330,x
		AND #$04 : BNE ..checkwall
		LDA !RexDensity,x : BEQ +		;\
		PLA					; | dense rex never turns at ledges
		PLA					; | (but it always jumps)
		BRA ++					;/
		LDA $BE,x : BEQ ..turn
	+	LDA !RexChase,x
		CMP #$02 : BCS ..turn
		..checkwall
		LDA $3330,x
		AND #$03 : BEQ ..noturn
		..turn
		PLA : STA $3250,x
		PLA : STA $3220,x
		LDA !RexChase,x				;\
		CMP #$02 : BCC +			; | golden bandit escape maneuver (jump)
	++	LDA #$C0 : STA !SpriteYSpeed,x		; |
		+					;/
		LDA $3330,x
		AND #$03 : BEQ ..fullrestore		; don't restore Y coordinate when hitting wall
		LDA !RexChase,x : BNE ..noturn+2	; when chasing, rex will not flip
		PLA : PLA				;\
		STZ !SpriteXSpeed,x			; | just flip here (touching wall)
		BRA ..flip				;/
		..fullrestore
		PLA : STA $3240,x
		PLA : STA $3210,x
		LDA !RexChase,x : BNE ..turndone	; does not flip when chasing
		..flip
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BRA ..turndone
		..noturn
		PLA : PLA : PLA : PLA
		..turndone



	INTERACTION:
		LDA !SpriteAnimIndex
		CMP #!Rex_Dead : BEQ .Done
		JSL !GetSpriteClipping04

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		LDA $BE,x : BEQ ..hurt
	..kill	LDA #$02 : STA $3230,x
		BRA ..inc
	..hurt	LDA #!Rex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	..inc	INC $BE,x
		STZ $3330,x
		BRA .Done
		..nocontact

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		..contact
		LDA $BE,x : BEQ ..hurt
	..kill	LDA #!Rex_Dead : BRA ..set
	..hurt	LDA #!Rex_Hurt
	..set	STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		INC $BE,x
		BRA .Done
		..nocontact

		.Fireball
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA $BE,x : BEQ ..hurt
	..kill	LDA #$02 : STA $3230,x
		BRA ..inc
	..hurt	LDA #!Rex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	..inc	INC $BE,x
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		STZ $3330,x
		..nocontact

		.Done


	AI:
		STZ !RexConga,x

		LDA !RexChase,x : BEQ .Done
		.CongaBrain
		LDA !SpriteXLo,x
		SEC : SBC #$08
		STA $04
		LDA !SpriteXHi,x
		SBC #$00
		STA $0A
		LDA !SpriteYLo,x
		SEC : SBC #$18
		STA $05
		LDA !SpriteYHi,x
		SBC #$00
		STA $0B
		LDA #$20
		STA $06
		STA $07
		LDX #$0F

		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !NewSpriteNum,x
		CMP #$02 : BNE ..next
		LDA $3230,x
		CMP #$08 : BNE ..next
		LDA !RexChase,x : BEQ ..next
		LDA !RexConga,x : BNE ..next
		JSL !GetSpriteClipping00
		JSL !CheckContact : BCC ..next

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
		STA $33C0,x
		..nochange

		LDA $BE,x : BEQ .Anim

		LDA !SpriteAnimIndex
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


		LDA !ExtraProp2,x
		AND #$3F : BEQ .NoDropHat
		LDY !SpriteAnimIndex
		CPY.b #!Rex_Dead : BEQ +

		CMP #$09 : BEQ .NoDropHat
		LDY $3230,x
		CPY #$02 : BEQ +
		CPY #$04 : BEQ +
		CMP #$05 : BEQ .NoDropHat
		CMP #$06 : BNE +
		LDA !ExtraProp2,x
		AND #$C0
		ORA #$09
		STA !ExtraProp2,x
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
		LDA !ExtraBits,x
		AND #$04 : BEQ .HandleUpdate
		LDA !SpriteAnimIndex
		CMP #!Rex_Walk_over : BCS .HandleUpdate
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.HandleUpdate
		LDA !RexDensity,x : BEQ ..notdense
		LDA $3330,x
		AND #$04 : BNE ..notdense
		LDY $BE,x
		CPY #$02 : BCS ..notdense
		LDA ANIM_JumpFrame,y : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..notdense
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y
		CMP #$FF : BNE ..ok
		STZ $3230,x
		PLB
		RTL

	..ok	STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer


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
		LDA !SpriteAnimIndex
		AND #$03
		ASL A
		ADC $00
		TAY
		REP #$20
		LDA ANIM_BagPtr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_p1
		REP #$20
		LDA $04
		CLC : ADC $08
		STA $04
		LDA ($04)
		SEP #$20
		BMI .BagDone
		JSL LOAD_PSUEDO_DYNAMIC_p0
		.BagDone
		PLA : STA !SpriteProp,x
		PLA : STA !SpriteTile,x
		.NoBag


	; draw hat
		LDA !ExtraProp2,x
		AND #$3F : BEQ .NoHat
		ASL A
		TAY
		LDA !SpriteTile,x : PHA
		LDA !SpriteProp,x : PHA

		LDA !SpriteYLo,x : PHA
		LDA !SpriteYHi,x : PHA
		LDA !SpriteAnimIndex
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
		AND #$3F
		DEC A
		ASL #2
		TAY
		CMP.b #ANIM_HatPtr_End-ANIM_HatPtr
		BCC $02 : LDA #$00
		STA $00
		LDA !SpriteAnimIndex
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
		LDA !SpriteAnimIndex
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
		LDA $04
		CLC : ADC $08
		STA $04
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
	; small
		dw .TM_Small00 : db $07,!Rex_Small+1
		dw .TM_Small01 : db $07,!Rex_Small+0
	; hurt
		dw .TM_Hurt00 : db $10,!Rex_Small+0
	; dead
		dw .TM_Dead00 : db $20,$FF


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


	.JumpFrame
		db !Rex_Walk+1
		db !Rex_Small+1



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
		AND #$3F						; |
		DEC A							; |
		ASL A							; |
		PHA							; |
		ASL A							; | hat index + pointer
		TAY							; |
		REP #$20						; |
		LDA.w ANIM_HatPtr,y : STA $04				; |
		PLY							; |
		LDA.w ANIM_HatIndex,y : JSL LoadGFXIndex		;/

		LDA !ExtraProp2,x					;\
		AND #$3F^$FF						; | clear hat
		STA !ExtraProp2,x					;/

		STZ $00
		LDA #$18 : STA $01
		LDY $3320,x
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
		LDA $33C0,x
		CMP #$04 : BEQ .Return
		LDA .Count-1,y : BEQ .Return
		STA $08
	.Again	STZ $00
		STZ $01
		CLC : LDA .Items-1,y
		JSL SpawnSprite
		CPY #$FF : BEQ .Return
		LDA #$08 : STA $3230,y
		LDA #$20			;\
		STA $32E0,y			; | prevent dropped item from interacting for a bit
		STA $35F0,y			;/
		LDA #$D0 : STA.w $9E,y
		PHX
		LDA $3320,x : TAX
		EOR $08
		AND #$01
		STA $3320,y
		TAX
		LDA .XSpeed,x : STA.w $AE,y
		PLX
		DEC $08
		LDY $08 : BNE .Again

		LDA !ExtraProp2,x
		AND #$3F
		CMP #$05 : BNE ..nobandit
		LDY #$0F
	-	PHY
		STZ $00
		STZ $01
		LDA !RNGtable,y
		AND #$1F
		SBC #$10
		STA $02
		LDA #$E8 : STA $03
		STZ $04
		LDA #$18 : STA $05
		STZ $06
		STZ $07
		LDA.b #!prt_tinycoin : JSL SpawnParticle
		PLY
		DEY : BPL -
		..nobandit


		RTS


	.Items	db $21,$74,$00,$00,$00,$00
	.Count	db $02,$01,$00,$00,$00,$00

	.XSpeed	db $10,$F0



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

		.SightX
		db $80,$50	; subtracted: knight, bandit
		.SightW
		db $FF,$A0	; width: knight, bandit

		.Pal
		db $00,$08,$00,$08	; knight turns red, assassin turns red, otherwise no change


	namespace off


