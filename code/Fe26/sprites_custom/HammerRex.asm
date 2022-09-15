

	!Temp = 0
	%def_anim(HammerRex_Walk, 4)
	%def_anim(HammerRex_Throw, 3)


	!HammerTimer		= $32D0



HammerRex:

	namespace HammerRex

	INIT:
		PHB : PHK : PLB
		LDY !Difficulty
		LDA .Delay,y : STA !HammerTimer,x		; wait before throwing first hammer
		PLB
		RTL

		.Delay
		db $5A,$3C,$3C


	MAIN:
		PHB : PHK : PLB
		LDA !SpriteHP,x : BNE .Transform
		LDA !SpriteStatus,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA #$02 : STA !SpriteHP,x

		.Transform
		JSR DropHat
		LDA #$02 : STA !SpriteNum,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		STZ !ExtraProp1,x
		STZ !ExtraProp2,x
		INX						; process this sprite again

		.Return
		PLB
		RTL


	PHYSICS:
		.ThrowHammer
		LDA !HammerTimer,x : BNE ..nothrow		;\
		LDY !Difficulty					; |
		LDA !RNG					; |
		LSR #2						; | wait a random number of frames (decreases on higher difficulties)
		CLC : ADC #$23					; |
		CLC : ADC.w DATA_ThrowDelay,y			; |
		STA !HammerTimer,x				;/
		LDA #!HammerRex_Throw : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA !SpriteDir,x				;/
		..nothrow

		.Speed
		STZ !SpriteXSpeed,x
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDA !SpriteAnimIndex,x
		CMP #!HammerRex_Throw : BCS ..nospeed
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed
		JSL APPLY_SPEED


	INTERACTION:
		JSL GetSpriteClippingE8

		.Attacks
		JSL InteractAttacks : BCS .HurtSprite

		.Body
		JSL P2Standard
		BCC .Done
		BEQ .Done

		.HurtSprite
		LDA #$01 : STA !SpriteHP,x
		STZ !SpriteBlocked,x

		.Done


	GRAPHICS:
		LDA !ExtraBits,x
		AND #$04 : BEQ .HandleUpdate
		LDA !SpriteAnimIndex,x
		CMP #!HammerRex_Walk_over : BCS .HandleUpdate
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
		LDA.w ANIM+3,y : STA !SpriteAnimIndex,x
		ASL #2
		TAY
		CPY.b #(!HammerRex_Throw+1)*4 : BNE .NoThrow
		PHY
		JSR ThrowHammer
		PLY
		.NoThrow
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer,x

		CPY.b #!HammerRex_Throw*4 : BEQ .Hammer
		CPY.b #(!HammerRex_Throw+1)*4 : BNE .Draw

		.Throw
		PHY
		LDA.b #ANIM_TM_SlashLine : STA $04
		LDA.b #ANIM_TM_SlashLine>>8 : STA $05
		JSL LOAD_TILEMAP
		PLY
		BRA .Draw

		.Hammer
		PHY
		LDA.b #ANIM_TM_Hammer : STA $04
		LDA.b #ANIM_TM_Hammer>>8 : STA $05
		LDA !SpriteOAMProp,x : PHA
		LDA #$06 : STA !SpriteOAMProp,x
		JSL LOAD_PSUEDO_DYNAMIC
		PLA : STA !SpriteOAMProp,x
		PLY

		.Draw
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL


	ANIM:
	; walk
		dw .TM_Walk00 : db $10,!HammerRex_Walk+1
		dw .TM_Walk01 : db $10,!HammerRex_Walk+2
		dw .TM_Walk00 : db $10,!HammerRex_Walk+3
		dw .TM_Walk02 : db $10,!HammerRex_Walk+0
	; throw
		dw .TM_Throw00 : db $20,!HammerRex_Throw+1
		dw .TM_Throw01 : db $08,!HammerRex_Throw+2
		dw .TM_Throw02 : db $20,!HammerRex_Walk



	.TM_Walk00
		dw $0010
		db $22,$00,$F0,$00
		db $22,$00,$00,$20
		db $22,$08,$00,$21
		db $22,$06,$E8,$06
	.TM_Walk01
		dw $0010
		db $22,$00,$EF,$00
		db $22,$00,$FF,$23
		db $22,$08,$FF,$24
		db $22,$06,$E7,$06
	.TM_Walk02
		dw $0010
		db $22,$00,$EF,$00
		db $22,$00,$FF,$26
		db $22,$08,$FF,$27
		db $22,$06,$E7,$06

	.TM_Throw00
		dw $0010
		db $22,$00,$F0,$00
		db $22,$00,$00,$20
		db $22,$08,$00,$21
		db $22,$06,$E8,$06
	.TM_Throw01
		dw $0010
		db $22,$F8,$F0,$0A
		db $22,$F8,$00,$29
		db $22,$00,$00,$2A
		db $22,$00,$E7,$06
	.TM_Throw02
		dw $0014
		db $22,$F8,$F0,$0C
		db $22,$00,$F0,$0D
		db $22,$F8,$00,$2C
		db $22,$00,$00,$2D
		db $22,$00,$EA,$06


	.TM_Hammer
		dw $0004		; should be uploaded before rex during prep00 tilemap
		db $22,$08,$F6,$08	; hammer tile, should be drawn with palette set to blue $06

	.TM_SlashLine
		dw $000C		; should be uploaded before rex during throw00 tilemap
		db $3A,$F8,$F8,$4B	; 16x16
		db $2A,$08,$F8,$4D	; 8x8
		db $2A,$10,$F8,$4E	; 8x8




	DropHat:
		REP #$20
		LDA.w ANIM_TM_Walk00+$0F
		AND #$00FF
		LDY !SpriteDir,x
		BNE $03 : EOR #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		STA $00
		LDA.w ANIM_TM_Walk00+$10
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		STA $02
		SEP #$20
		; Y = dir
		LDA DATA_HatXSpeed,y : STA $04
		LDA DATA_HatXSpeed+2,y : STA $05

		PHB							;\
		JSL GetParticleIndex					; |
		LDA $04 : STA !Particle_XSpeed,x			; |
		LDA #$FD80 : STA !Particle_YSpeed,x			; |
		STZ !Particle_XAcc,x					; |
		PLB							; |
		SEP #$20						; |
		LDY !SpriteIndex					; |
		LDA !SpriteXLo,y					; |
		CLC : ADC $00						; |
		STA !41_Particle_XLo,x					; |
		LDA !SpriteXHi,y					; |
		ADC $01							; |
		STA !41_Particle_XHi,x					; |
		LDA !SpriteYLo,y					; |
		CLC : ADC $02						; | spawn particle
		STA !41_Particle_YLo,x					; |
		LDA !SpriteYHi,y					; |
		ADC $03							; |
		STA !41_Particle_YHi,x					; |
		LDA !SpriteTile,y					; |
		CLC : ADC #$06						; |
		STA !41_Particle_Tile,x					; |
		LDA !SpriteDir,y					; |
		BEQ $02 : LDA #$40					; |
		EOR #$40						; |
		ORA #$30						; |
		ORA !SpriteProp,y					; |
		ORA !SpriteOAMProp,y					; |
		STA !41_Particle_Prop,x					; |
		LDA #!prt_spritepart : STA !41_Particle_Type,x		; |
		LDA #$02 : STA !41_Particle_Layer,x			; |
		LDA #$FF : STA !41_Particle_Timer,x			; |
		LDA #$18 : STA !41_Particle_YAcc,x			;/
		SEP #$10
		TYX
		RTS



	ThrowHammer:
		LDY !SpriteDir,x				;\
		LDA DATA_HammerX,y : STA $00			; | spawn hammer
		LDA #$FF : STA $01				; |
		LDA.b #!Hammer_Num : JSL SpawnExSprite		;/

		LDA !Difficulty : BNE .FlexArc

	; fixed arc on easy
		.FixedArc
		PHY
		LDA !RNG
		AND #$80 : TAY
		JSL SUB_HORZ_POS_Target
		TYA : STA !SpriteDir,x
		LDA DATA_EasyThrowXSpeed,y
		PLY
		STA !Ex_XSpeed,y
		LDA #$D0 : STA !Ex_YSpeed,y
		.Fail
		RTS

	; free arc on insane
		.FlexArc
		LDA !RNGtable,x					;\
		AND #$80					; |
		ORA.b #!P2YPosLo-$80				; | target a random player
		STA $00						; |
		LDA.b #!P2Base>>8 : STA $01			;/
		LDA !SpriteYHi,x : XBA				;\
		LDA !SpriteYLo,x				; |
		REP #$20					; |
		SEC : SBC ($00)					; |
		LSR #2						; |
		SEP #$20					; | Yspeed
		EOR #$FF					; |
		INC A						; |
		CLC : ADC #$C8					; |
		CMP #$C0					; |
		BCS +						; |
		LDA #$C0					; |
	+	STA !Ex_YSpeed,y				;/
		LDA $00						;\
		SEC : SBC.b #(!P2YPosLo)-(!P2XPosLo)		; | update pointer
		STA $00						;/
		LDA !SpriteXHi,x				;\
		XBA						; |
		LDA !SpriteXLo,x				; |
		REP #$20					; |
		SEC : SBC ($00)					; | Xspeed
		LSR #2						; |
		SEP #$20					; |
		EOR #$FF					; |
		INC A						; |
		STA !Ex_XSpeed,y				;/

		ROL #2
		AND #$01 : STA !SpriteDir,x

	; limited flex arc on normal
		LDA !Difficulty
		CMP #$02 : BEQ .Return
		.LimitArc
		LDA #$D0 : STA !Ex_YSpeed,y
		LDA !Ex_XSpeed,y : BMI ..neg
		..pos
		CMP #$14 : BCS +
		LDA #$14 : BRA ++
	+	CMP #$30 : BCC .Return
		LDA #$30
	++	STA !Ex_XSpeed,y
		RTS
		..neg
		CMP #$EC : BCC +
		LDA #$EC : BRA ++
	+	CMP #$D0 : BCS .Return
		LDA #$D0
	++	STA !Ex_XSpeed,y
		.Return
		RTS						; return



	DATA:
		.XSpeed
		db $08,$F8

		.HatXSpeed
		db $80,$80
		db $FF,$01

		.HammerX
		db $0C,$F4

		.EasyThrowXSpeed
		db $18,$E8

		.ThrowDelay
		db $3F,$37,$2F


	namespace off





