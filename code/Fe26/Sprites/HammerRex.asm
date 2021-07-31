

	!Temp = 0
	%def_anim(HammerRex_Walk, 4)
	%def_anim(HammerRex_Throw, 3)


HammerRex:

	namespace HammerRex

	INIT:
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		RTL



	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN
		LDA $9D : BEQ .Process
		JMP GRAPHICS

		.Process
		LDA $BE,x : BNE .Transform
		LDA $3230,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA #$02 : STA $BE,x

		.Transform
		JSR DropHat
		LDA #$02 : STA !NewSpriteNum,x
		LDA #!Rex_Hurt : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !ExtraProp1,x
		LDA !ExtraProp2,x
		AND #$C0
		STA !ExtraProp2,x
		INX						; process this sprite again

		.Return
		PLB
		RTL


	PHYSICS:
		.ThrowHammer
		LDA $32D0,x : BNE ..nothrow			;\
		LDA.l !Difficulty				; |
		AND #$03					; |
		TAY						; |
		LDA !RNG					; | wait a random number of frames
		LSR #2						; |
		CLC : ADC #$23					; |
		CLC : ADC.w DATA_ThrowDelay,y			; |
		STA $32D0,x					;/
		LDA #!HammerRex_Throw : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA $3320,x				;/
		..nothrow

		.Speed
		STZ !SpriteXSpeed,x
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDA !SpriteAnimIndex
		CMP #!HammerRex_Throw : BCS ..nospeed
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed
		LDA $3220,x : PHA
		LDA $3250,x : PHA
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA $3330,x
		AND #$04 : PHA
		JSL !SpriteApplySpeed
		PLA : BEQ ..checkwall
		LDA $3330,x
		AND #$04 : BEQ ..turn
		..checkwall
		LDA $3330,x
		AND #$03 : BEQ ..noturn
		..turn
		PLA : STA $3240,x
		PLA : STA $3210,x
		PLA : STA $3250,x
		PLA : STA $3220,x
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BRA ..turndone
		..noturn
		PLA : PLA : PLA : PLA
		..turndone


	INTERACTION:
		JSL !GetSpriteClipping04

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA #$01 : STA $BE,x
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		STZ $3330,x
		..nocontact

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		LDA #$01 : STA $BE,x
		..nocontact

		.Fireball
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA #$01 : STA $BE,x
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		STZ $3330,x
		..nocontact


	GRAPHICS:
		LDA !ExtraBits,x
		AND #$04 : BEQ .HandleUpdate
		LDA !SpriteAnimIndex
		CMP #!HammerRex_Walk_over : BCS .HandleUpdate
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.HandleUpdate
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		CPY.b #(!HammerRex_Throw+1)*4 : BNE .NoThrow
		PHY
		JSR ThrowHammer
		PLY
		.NoThrow
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer

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
		LDA $33C0,x : PHA
		LDA #$06 : STA $33C0,x
		JSL LOAD_PSUEDO_DYNAMIC
		PLA : STA $33C0,x
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
		db $32,$00,$F0,$00
		db $32,$00,$00,$20
		db $32,$08,$00,$21
		db $32,$06,$E8,$06
	.TM_Walk01
		dw $0010
		db $32,$00,$EF,$00
		db $32,$00,$FF,$23
		db $32,$08,$FF,$24
		db $32,$06,$E7,$06
	.TM_Walk02
		dw $0010
		db $32,$00,$EF,$00
		db $32,$00,$FF,$26
		db $32,$08,$FF,$27
		db $32,$06,$E7,$06

	.TM_Throw00
		dw $0010
		db $32,$00,$F0,$00
		db $32,$00,$00,$20
		db $32,$08,$00,$21
		db $32,$06,$E8,$06
	.TM_Throw01
		dw $0010
		db $32,$F8,$F0,$0A
		db $32,$F8,$00,$29
		db $32,$00,$00,$2A
		db $32,$00,$E7,$06
	.TM_Throw02
		dw $0014
		db $32,$F8,$F0,$0C
		db $32,$00,$F0,$0D
		db $32,$F8,$00,$2C
		db $32,$00,$00,$2D
		db $32,$00,$EA,$06


	.TM_Hammer
		dw $0004		; should be uploaded before rex during prep00 tilemap
		db $32,$06,$FA,$08	; hammer tile, should be drawn with palette set to blue $06

	.TM_SlashLine
		dw $000C		; should be uploaded before rex during throw00 tilemap
		db $3A,$F8,$F8,$4B	; 16x16
		db $2A,$08,$F8,$4D	; 8x8
		db $2A,$10,$F8,$4E	; 8x8




	DropHat:

		REP #$20
		LDA.w ANIM_TM_Walk00+$0F
		AND #$00FF
		LDY $3320,x
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
		JSL !GetParticleIndex					; |
		LDA $04 : STA !Particle_XSpeed,x			; |
		LDA #$FD80 : STA !Particle_YSpeed,x			; |
		STZ !Particle_XAcc,x					; |
		PLB							; |
		SEP #$20						; |
		LDY !SpriteIndex					; |
		LDA $3220,y						; |
		CLC : ADC $00						; |
		STA !41_Particle_XLo,x					; |
		LDA $3250,y						; |
		ADC $01							; |
		STA !41_Particle_XHi,x					; |
		LDA $3210,y						; |
		CLC : ADC $02						; | spawn particle
		STA !41_Particle_YLo,x					; |
		LDA $3240,y						; |
		ADC $03							; |
		STA !41_Particle_YHi,x					; |
		LDA !SpriteTile,y					; |
		CLC : ADC #$06						; |
		STA !41_Particle_Tile,x					; |
		LDA $3320,y						; |
		BEQ $02 : LDA #$40					; |
		EOR #$40						; |
		ORA #$30						; |
		ORA !SpriteProp,y					; |
		ORA $33C0,y						; |
		STA !41_Particle_Prop,x					; |
		LDA #!prt_spritepart : STA !41_Particle_Type,x		; |
		LDA #$02 : STA !41_Particle_Layer,x			; |
		LDA #$FF : STA !41_Particle_Timer,x			; |
		LDA #$18 : STA !41_Particle_YAcc,x			;/
		SEP #$10
		TYX
		RTS



	ThrowHammer:
		LDY $3320,x					;\
		LDA DATA_HammerX,y : STA $00			; | $00 = 16-bit Xdisp of hammer
		LDA DATA_HammerX+2,y : STA $01			;/
		%Ex_Index_Y()					; Y = fusion index
		LDA #$04+!ExtendedOffset : STA !Ex_Num,y	; hammer num
		LDA $14						;\
		LSR A						; |
		LDA $3320,x					; |
		BEQ $02 : LDA #$40				; | rotation
		EOR #$40					; |
		BCC $02 : ORA #$80				; |
		STA !Ex_Data3,y					;/
		LDA $3220,x					;\
		CLC : ADC $00					; |
		STA !Ex_XLo,y					; | Xpos
		LDA $3250,x					; |
		ADC $01						; |
		STA !Ex_XHi,y					;/
		LDA $3210,x					;\
		SEC : SBC #$01					; |
		STA !Ex_YLo,y					; | Ypos
		LDA $3240,x					; |
		SBC #$00					; |
		STA !Ex_YHi,y					;/

		LDA !Difficulty
		AND #$03 : BNE .FlexArc

	; fixed arc on easy
		.FixedArc
		PHY
		LDA !RNG
		AND #$80 : TAY
		JSL SUB_HORZ_POS_Target
		TYA : STA $3320,x
		LDA DATA_EasyThrowX,y
		PLY
		STA !Ex_XSpeed,y
		LDA #$D0 : STA !Ex_YSpeed,y
		RTS

	; free arc on insane
		.FlexArc
		LDA !RNG,x					;\
		AND #$80					; |
		ORA.b #!P2YPosLo-$80				; | target a random player
		STA $00						; |
		LDA.b #!P2Base>>8 : STA $01			;/
		LDA $3240,x : XBA				;\
		LDA $3210,x					; |
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
		LDA $3250,x					;\
		XBA						; |
		LDA $3220,x					; |
		REP #$20					; |
		SEC : SBC ($00)					; | Xspeed
		LSR #2						; |
		SEP #$20					; |
		EOR #$FF					; |
		INC A						; |
		STA !Ex_XSpeed,y				;/

		ROL #2
		AND #$01
		STA $3320,x

	; limit arc on normal
		LDA !Difficulty
		AND #$03
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
		db $00,$FF

		.EasyThrowX
		db $18,$E8

		.ThrowDelay
		db $3F,$37,$2F


	namespace off





