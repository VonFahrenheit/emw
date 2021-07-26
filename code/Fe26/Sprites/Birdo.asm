Birdo:

	namespace Birdo

	!BirdoHP		= $BE,x

	!BirdoStartX		= $3280,x

	!BirdoJumpTimer		= $3290,x
	!BirdoAttackTimer	= $32A0,x

	!BirdoInvincTimer	= $32B0,x
	!BirdoPhase		= $32C0,x
	!BirdoMouthTimer	= $32D0,x
	!BirdoHurtTimer		= $32F0,x



	INIT:
		PHB : PHK : PLB			; > Start of bank wrapper

		LDA #$FF : STA !BirdoJumpTimer
		LDA #$40 : STA !BirdoAttackTimer

		LDA $3220,x : STA !BirdoStartX

		LDA !Difficulty
		AND #$03
		CLC : ADC #$03
		ASL A
		STA !BirdoHP

	.Return	PLB				; > End of bank wrapper
		RTL				; > End INIT routine


	MAIN:
		PHB : PHK : PLB
		LDA !BirdoHP
		BEQ .Dead
		BPL .Alive

	.Dead	LDA !BirdoPhase
		CMP #$01 : BNE ..Main

		..Init
		LDA $3320,x
		DEC A
		EOR #$0F
		STA $AE,x
		LDA #$C0 : STA $9E,x
		LDA #$02 : STA !BirdoPhase

		..Main
		BIT $9E,x
		BMI +
		BVS ++
	+	INC $9E,x
		INC $9E,X
	++	JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
		JSL SPRITE_OFF_SCREEN

		INC !BirdoHurtTimer
		STZ !BirdoInvincTimer

		JMP ANIMATION


	.Alive	DEC !BirdoJumpTimer			;\
		LDA !BirdoMouthTimer			; | AI timers
		ORA !BirdoHurtTimer			; |
		BNE $03 : DEC !BirdoAttackTimer		;/

		LDA !BirdoInvincTimer
		BEQ $03 : DEC !BirdoInvincTimer

		LDA !BirdoHurtTimer
		CMP #$01 : BNE +
		LDA #$40 : STA !BirdoInvincTimer
		+

		LDA !BirdoPhase : BEQ .Intro

	.Main

		BRA .Return


	.Intro
		LDA $3330,x
		AND #$04 : BEQ .Return
		INC !BirdoPhase

		.Return


	PHYSICS:
		JSL SUB_HORZ_POS
		TYA : STA $3320,x

		LDA $3330,x				;\ Can't gain Xspeed in midair
		AND #$04 : BEQ .NoMove			;/
		LDA #$10 : STA $9E,x

		LDA !BirdoJumpTimer : BNE .NoJump	;\
		LDA !RNG				; |
		AND #$0F				; |
		ASL #4					; |
		STA !BirdoJumpTimer			; | Handle jump
		LDA #$D0 : STA $9E,x			; |
		STZ $AE,x				; |
		BRA .NoMove				; |
		.NoJump					;/

		LDA $14					;\
		AND #$3F : BNE .NoMove			; |
		LDY #$0C				; |
		LDA $3220,x				; | Start walking toward start X every 64 frames
		CMP !BirdoStartX			; |
		BCC $02 : LDY #$F4			; |
		STY $AE,x				;/
		.NoMove


		LDA !BirdoHurtTimer : BNE .NoSpeed	; Don't move during hurt timer
		JSL !SpriteApplySpeed
		.NoSpeed


		LDA !BirdoPhase				;\ skip straight to animation during intro phase
		BNE $03 : JMP ANIMATION			;/


		LDA !BirdoAttackTimer : BNE .NoShoot
		LDA !RNG
		LSR #2
		STA $00
		ASL A
		CLC : ADC $00
		CLC : ADC #$40
		STA !BirdoAttackTimer
		LDA #$10 : STA !BirdoMouthTimer
		LDA #$20 : STA !SPC1

		JSL !GetSpriteSlot
		BMI .NoShoot
		JSL SPRITE_A_SPRITE_B_COORDS
		LDA $3210,x
		SEC : SBC #$10
		STA $3210,y
		LDA $3240,x
		SBC #$00
		STA $3240,y
		LDA #$1A
		TYX
		STA !NewSpriteNum,x
		LDA #$3E : STA $3200,x
		LDA #$08 : STA $3230,x
		JSL $07F7D2
		JSL $0187A7
		LDA #$08 : STA !ExtraBits,x
		LDY !SpriteIndex
		LDA $3320,y : STA $3320,x
		DEC A
		EOR #$FF
		EOR #$20
		STA $AE,x
		LDA #$01 : STA $BE,x			; Set fly flag
		LDA #$FF : STA $32A0,x			; life timer for egg
		TYX

		.NoShoot



	INTERACTION:

		LDA $3220,x
		CLC : ADC #$02
		STA $04
		LDA $3250,x
		ADC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$08
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$0C : STA $06
		LDA #$18 : STA $07

		LDA !BirdoHurtTimer
		ORA !BirdoInvincTimer
		BNE .NoDamage

		JSL P2Attack
		BCC .NoAttack
		JSR Hurt
		.NoAttack

		LDY #$0F				;\
	-	LDA !NewSpriteNum,y			; |
		CMP #$1A : BNE +			; |
		LDA $3230,y				; | Look for eggs
		CMP #$0B : BEQ ++			; |
		CMP #$09 : BNE +			; |
		LDA $3330,y				; |
		AND #$04 : BNE +			;/
	++	TYX					;\
		JSL !GetSpriteClipping00		; |
		TXY					; |
		LDX !SpriteIndex			; |
		JSL !CheckContact			; |
		BCC +					; |
		JSR Hurt				; | Process interaction
		DEC !BirdoHP				; > Egg deals 2 damage
		LDA #$02 : STA $3230,y			; |
		LDA #$E0 : STA $309E,y			; |
		LDA $30AE,y				; |
		JSR LakituLovers_Idle_Halve		; |
		EOR #$FF				; |
		STA $30AE,y				; |
	+	DEY : BPL -				;/
		.NoDamage


		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00
		JSR Interact
		PLA
	.P2	LSR A : BCC .NoContact
		LDY #$80
		JSR Interact
		.NoContact





	ANIMATION:

		LDA !BirdoHurtTimer : BEQ +
		LDA $14
		AND #$07 : BRA ++
	+	LDA $3330,x
		AND #$04 : BEQ +
		LDA $14
		AND #$0F
	++	BNE +
		LDA !SpriteAnimIndex
		EOR #$01
		STA !SpriteAnimIndex
		+




	GRAPHICS:

		LDA !BirdoInvincTimer
		AND #$02 : BNE .Return

		LDY #$24				; YXPPCCCT for head and body
		LDA !BirdoHurtTimer : BEQ +
		LDA $14
		AND #$02 : BEQ +
		LDY #$36
	+	STY $0F


		LDY !BirdoMouthTimer			;\
		BEQ $02 : LDY #$01			; | Write head tile
		LDA .HeadTile,y : STA !BigRAM+$05	;/
		LDA #$35 : STA !BigRAM+$0A		;\
		LDA $0F					; | Write YXPPCCCT
		STA !BigRAM+$02				; |
		STA !BigRAM+$06				;/
		REP #$20				;\
		LDA #$F000 : STA !BigRAM+$03		; |
		STZ !BigRAM+$07				; | Coordinates
		LDA #$E702				; |
		CPY #$01				; |
		BNE $01 : INC A				; |
		STA !BigRAM+$0B				; |
		LDA #$000C : STA !BigRAM+$00		;/
		LDA.w #!BigRAM : STA $04		; > Tilemap location
		SEP #$20				; A 8-bit
		LDA #$0C : STA !BigRAM+$0D		;\
		LDY !SpriteAnimIndex			; | Bow tile and body tile
		LDA .BodyTile,y : STA !BigRAM+$09	;/

		LDA !BirdoHurtTimer : BEQ +		;\
		LDA #$06 : STA !BigRAM+$05		; | If hurt timer is set, use 2-tile tilemap
		STZ !BirdoMouthTimer			; | (also clear mouth timer and update head tile)
		LDA #$08 : STA !BigRAM+$00		; |
		+					;/

		JSL LOAD_PSUEDO_DYNAMIC


		.Return
		PLB
		RTL

	; !BigRAM:
	; $00-$01:	header
	; $02-$05:	head
	; $06-$09:	body
	; $0A-$0D:	bow


	.HeadTile
	db $02,$00

	.BodyTile
	db $08,$0A

	Interact:
		LDA !P2Blocked-$80,y
		AND #$04 : BNE .Side
		LDA !P2YSpeed-$80,y
		SEC : SBC $9E,x
		BMI .Side
		CMP #$10 : BCC .Side

		.Top
		JSL P2Bounce
		LDA #$02 : STA !SPC1
		RTS

		.Side
		LDA !BirdoHurtTimer : BNE .Return
		TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
	.Return	RTS


	Hurt:	LDA #$20 : STA !BirdoHurtTimer
		LDA #$02 : STA !SPC1
		LDA #$28 : STA !SPC4
		DEC !BirdoHP
		RTS


	Egg:
		.MAIN
		PHB : PHK : PLB

		LDA $32A0,x : BEQ +
		DEC $32A0,x : BNE +
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		PLB
		RTL
		+


		LDA $3230,x
		CMP #$0A : BNE +
		LDA #$09 : STA $3230,x
	+	CMP #$09 : BEQ .Go
		CMP #$08 : BNE .Graphics


		LDA $BE,x : BNE .Fly
		JSL !SpriteApplySpeed
	.Go	LDA $3330,x
		AND #$04 : BEQ .Inter
		LDA $AE,x
		JSR LakituLovers_Idle_Halve
		STA $AE,x
		BPL $03 : EOR #$FF : INC A
		CMP #$04 : BCC .Inter
		STZ $AE,x
		BRA .Inter


	.Fly	JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08


	.Inter	JSL !GetSpriteClipping04
		JSL P2Attack
		BCC +
		LDA #$02 : STA !SPC1
		LDA #$09 : STA $3230,x

	+	SEC : JSL !PlayerClipping
		BCC .Graphics
		LSR A : BCC ..P2
	..P1	PHA
		LDY #$00
		JSR .Interact
		PLA
	..P2	LSR A : BCC .Graphics
		LDY #$80
		JSR .Interact



		.Graphics
		REP #$20
		LDA.w #.EggTM : STA $04
		SEP #$20
		JSL LOAD_TILEMAP

	.Return	PLB
	.INIT	RTL

		.Interact
		LDA $BE,x : BNE +
		LDA !P2Character-$80,y			; Check for Mario
		BNE ..R
		BIT $15 : BVC ..R
		LDA #$0B : STA $3230,x
	..R	RTS



	+	LDA !P2Blocked-$80,y
		AND #$04 : BNE ..Side
		LDA !P2YSpeed-$80,y
		SEC : SBC $9E,x
		BMI ..Side
		CMP #$10 : BCC ..Side

	..Top	JSL P2Bounce
		LDA #$13 : STA !SPC1
		LDA $AE,x
		JSR LakituLovers_Idle_Halve
		STA $AE,x
		STZ $BE,x				; Clear fly flag
		RTS

	..Side	TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
		RTS



	.EggTM
	dw $0004
	db $34,$00,$00,$0E


	namespace off





