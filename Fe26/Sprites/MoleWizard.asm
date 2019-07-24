MoleWizard:

	namespace MoleWizard


	!MoleWizardState	= $BE,x
	!MoleWizardHP		= $3280,x
	!MoleWizardTimer	= $32D0,x
	!MoleWizardHurtTimer	= $3360,x


	INIT:
		PHB : PHK : PLB
		LDA !GFX_status+$0E : STA !ClaimedGFX
		LDA #$40 : STA !MoleWizardTimer
		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_HP,y
		STA !MoleWizardHP
		PLB


	MAIN:
		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS

	DATA:
		.XSpeed
		db $10,$F0

		.HP
		db $02,$02,$04

		.AttackTime
		db $60,$50,$40

	PHYSICS:
		LDA !MoleWizardHP : BMI .Dead		;\
		BNE .Alive				; |
	.Dead	LDA #$02 : STA $3230,x			; | Death check
		STZ !MoleWizardHurtTimer		; |
		JMP GRAPHICS				; |
		.Alive					;/

		PEA .Return-1				; > Set return address
		LDA !MoleWizardState			;\
		AND #$3F				; |
		ASL A					; | Check for illegal states to avoid potential crashes
		CMP.b #.JumpOut-.StatePtr		; |
		BCC $01 : RTS				;/
		TAX					;\ Execute state
		JMP (.StatePtr,x)			;/

		.StatePtr
		dw .JumpOut
		dw .Attack
		dw .Warp
		dw .Sink

		.JumpOut
		LDX !SpriteIndex
		LDA !MoleWizardTimer			;\ Wait while timer is set
		BNE ..Return				;/
		BIT !MoleWizardState			;\ See if mole has already jumped
		BVS ..Air				;/
		..Ground				;\
		LDA #$C8 : STA $9E,x			; | Start jump
		LDA #$40 : STA !MoleWizardState		; |
		JSR Shatter				; |
		LDA $3210,x				; |
		CLC : ADC #$18				; |
		STA $3210,x				; |
		LDA $3240,x				; |
		ADC #$00				; |
		STA $3240,x				; |
		RTS					;/
		..Air					;\
		LDA $3330,x				; |
		AND #$04 : BEQ ..Return			; | Enter attack state
		LDA #$01 : STA !MoleWizardState		; |
		LDA !Difficulty				; |
		AND #$03				; |
		TAY					; |
		LDA DATA_AttackTime,y			; |
		STA !MoleWizardTimer			;/
		JSR SUB_HORZ_POS			;\ Face a player
		TYA : STA $3320,x			;/
		..Return
		RTS


		.Attack
		LDX !SpriteIndex
		LDA !MoleWizardTimer : BEQ ..Done
		CMP #$30 : BNE ..Return
		JMP Fire
		..Done
		LDA #$02 : STA !MoleWizardState
		..Return
		RTS


		.Warp
		LDX !SpriteIndex
		BIT !MoleWizardState
		BVS ..Air
		..Ground
		LDA #$D8 : STA $9E,x
		LDA #$42 : STA !MoleWizardState
		RTS
		..Air
		LDA $3330,x
		AND #$04 : BEQ ..Return
		LDA #$03 : STA !MoleWizardState
		LDA #$08 : STA !MoleWizardTimer
		JSR Shatter
		..Return
		RTS


		.Sink
		LDX !SpriteIndex
		LDA !MoleWizardTimer
		BNE ..Return
		STZ !MoleWizardState				; > Cycle state
		LDA #$40 : STA !MoleWizardTimer			; > Set wait timer
		LDA !RNG					;\
		AND #$80					; |
		TAY						; |
		BPL +						; |
		LDA !MultiPlayer : BEQ ++			; |
	+	LDA !P2Status-$80,y				; |
		BEQ +						; |
	++	TYA						; |
		EOR #$80					; |
		TAY						; |
	+	LDA !P2XPosLo-$80,y : STA $3220,x		; | Teleport to a random player
		LDA !P2XPosHi-$80,y : STA $3250,x		; |
		LDA !P2YPosLo-$80,y : STA $3210,x		; |
		LDA !P2YPosHi-$80,y : STA $3240,x		;/
		RTS

		..Return
		LDA #$40 : STA $9E,x
		JSL !SpriteApplySpeed-$10
		PLA : PLA
		BRA INTERACTION



		.Return
		JSL !SpriteApplySpeed



	INTERACTION:

		LDA !MoleWizardHurtTimer : BNE ++	;\
		LDA !MoleWizardState			; | No interaction while hurt
		BPL +					;/
	++
	-	LDA $3460,x				;\
		ORA #$30				; |
		STA $3460,x				; |
		LDA $3470,x				; |
		ORA #$02				; | Use different properties while uninteractive
		STA $3470,x				; |
		LDA $3480,x				; |
		ORA #$08				; |
		STA $3480,x				; |
		LDA #$02				; |
		STA $32E0,x				; |
		STA $3300,x				; |
		STA $35F0,x				; |
		BRA .NoContact				;/

	+	AND #$3F				;\
		CMP #$01 : BEQ +			; | No interaction while underground
		CMP #$03 : BEQ -			; |
		LDA !MoleWizardTimer			; |
		BNE -					;/

	+	LDA $3460,x
		AND.b #$30^$FF
		STA $3460,x
		LDA $3470,x
		AND.b #$02^$FF
		STA $3470,x
		LDA $3480,x
		AND.b #$08^$FF
		STA $3480,x
		LDA $3220,x : STA $04
		LDA $3250,x : STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$10
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .NoContact
	.P1	LSR A : BCC .P2
		PHA
		LDY #$00
		JSR Contact
		PLA
	.P2	LSR A : BCC .NoContact
		LDY #$80
		JSR Contact
		.NoContact


	GRAPHICS:
		LDA !MoleWizardHurtTimer		;\ Blink while hurt
		AND #$02 : BNE .Return			;/
		LDA !MoleWizardState
		AND #$3F
		BNE .NoInvis
		LDA !MoleWizardTimer
		BNE .Return
		BRA .Spin

		.NoInvis
		CMP #$02 : BEQ .Jump
		CMP #$03 : BEQ .Sink
		LDA !MoleWizardTimer
		CMP #$40 : BCS +
		CMP #$30 : BCS ++
		CMP #$20 : BCS +++
		CMP #$18 : BCC +
		LDA #$06 : BRA .ProcessAnim
	+++	LDA #$05 : BRA .ProcessAnim
	++	LDA #$04 : BRA .ProcessAnim
	+	LDA #$00 : BRA .ProcessAnim

		.Spin
		LDA $9E,x : BPL +
		CMP #$F0 : BCC .Sink
	+	LDA $14
		LSR #3
		AND #$03
		BRA .ProcessAnim

		.Sink
		LDA #$08
		BRA .ProcessAnim

		.Jump
		LDA #$07

		.ProcessAnim
		STA !SpriteAnimIndex
		ASL A
		TAY
		LDA ANIM,y : STA $04
		LDA ANIM+1,y : STA $05
		JSR LOAD_PSUEDO_DYNAMIC

		.Return
		PLB
		RTL


	ANIM:
		dw .IdleTM		; 00
		dw .SpinTM00		; 01
		dw .SpinTM01		; 02
		dw .SpinTM02		; 03
		dw .AttackTM00		; 04
		dw .AttackTM01		; 05
		dw .AttackTM02		; 06
		dw .JumpTM		; 07
		dw .SinkTM		; 08


	.IdleTM
		dw $0008
		db $29,$00,$F8,$00
		db $29,$00,$00,$10

	.SpinTM00
		dw $0008
		db $29,$00,$F8,$02
		db $29,$00,$00,$12
	.SpinTM01
		dw $0008
		db $69,$00,$F8,$00
		db $69,$00,$00,$10
	.SpinTM02
		dw $0008
		db $29,$00,$F8,$04
		db $29,$00,$00,$14

	.AttackTM00
		dw $0008
		db $29,$00,$F8,$06
		db $29,$00,$00,$16
	.AttackTM01
		dw $000C
		db $29,$00,$F8,$0C
		db $29,$00,$00,$1C
		db $29,$F8,$00,$1B
	.AttackTM02
		dw $000C
		db $29,$00,$F8,$09
		db $29,$00,$00,$19
		db $29,$F8,$00,$18

	.JumpTM
		dw $0008
		db $29,$00,$F8,$0E
		db $29,$00,$00,$1E

	.SinkTM
		dw $0008
		db $19,$00,$F8,$02
		db $19,$00,$00,$12


	Contact:
		LDA #$01 : STA !P2SenkuSmash-$80,y
		LDA !P2Blocked-$80,y
		AND #$04
		BNE .Nope
		LDA !P2YSpeed-$80,y
		BMI .Nope
		LDA #$C2 : STA !MoleWizardState
		STZ !MoleWizardTimer
		JMP P2Bounce

		.Nope
		RTS


	Shatter:
		REP #$20
		STZ $00
		LDA #$0008 : STA $02
		LDA #$0014 : STA $04
		SEP #$20
		STZ $7C
		STZ $9C
		LDY #$01
		JSL !GenerateBlock
		RTS

	Fire:
		JSL $02A9DE
		BMI .Return
		JSR SPRITE_A_SPRITE_B_COORDS		; same position
		PHY
		PHX
		TYX
		LDA #$0C : STA !NewSpriteNum,x
		LDA #$36 : STA $3200,x
		LDA #$08 : STA $3230,x
		JSL $07F7D2
		JSL $0187A7
		STZ $33C0,x
		LDA #$08 : STA !ExtraBits,x
		LDA #$02 : STA $BE,x

		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
	-	REP #$20
		SEC : SBC !P2YPosLo-$80,y
		BMI +
		CMP #$0020 : BCC +
		SEP #$20
		LDA #$F0
		BRA ++
	+	CMP #$FFE0 : BCS .Straight
		SEP #$20
		LDA #$10
	++	STA $32A0,x
		BRA .Aimed

		.Straight
		SEP #$20
		CPY #$80
		BEQ .Aimed
		LDY #$80
		BRA -

		.Aimed
		PLX
		PLY
		LDA $3320,x : STA $3320,y

		.Return
		RTS




	namespace off





