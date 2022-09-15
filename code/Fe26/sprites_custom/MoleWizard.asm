
	!MoleWizardState	= $BE

	!MoleWizardInvinc	= $3280
	!MoleWizardTimer	= $32D0


MoleWizard:

	namespace MoleWizard

	MAIN:
		PHB : PHK : PLB
		LDA !SpriteStatus,x
		CMP #$08 : BEQ .Process
		JMP GRAPHICS

		.Process
		%decreg(!MoleWizardInvinc)

	PHYSICS:
		PEA .HandleMovement-1					; > return address
		LDA !MoleWizardState,x					;\
		ASL A							; |
		CMP.b #.StatePtr_end-.StatePtr				; | execute pointer
		BCC $02 : LDA #$00					; |
		TAX							; |
		JMP (.StatePtr,x)					;/

		.StatePtr
		dw .Teleport
		dw .FindGround
		dw .JumpOut
		dw .Attack
		dw .Sink
		dw .Illusion
		..end


	.Teleport
		LDX !SpriteIndex
		STZ !SpriteBlocked,x
		LDA !RNG
		AND #$80 : TAY
		LDA !P2XPosLo-$80,y
		SEC : SBC #$40
		STA !SpriteXLo,x
		LDA !P2XPosHi-$80,y
		SBC #$00
		STA !SpriteXHi,x
		LDA !P2YPosLo-$80,y : STA !SpriteYLo,x
		LDA !P2YPosHi-$80,y : STA !SpriteYHi,x

		LDA !RNG
		AND #$40 : BEQ +
		LDA !SpriteXLo,x
		EOR #$80 : STA !SpriteXLo,x
		BMI +
		INC !SpriteXHi,x
		+

		LDY !Difficulty
		LDA DATA_Wait,y : STA !MoleWizardTimer,x
		INC !MoleWizardState,x
		; flow

	.FindGround
		LDX !SpriteIndex
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CLC : ADC #$0010
		STA $00
		CMP !LevelHeight
		SEP #$20
		BCC ..fall
		..rewarp
		STZ !MoleWizardState,x
		..return
		RTS
		..fall
		LDA !MoleWizardTimer,x : BNE ..return
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..return
		INC !MoleWizardState,x
		LDA $00 : STA !SpriteYLo,x
		LDA $01 : STA !SpriteYHi,x
		; flow

	.JumpOut
		LDX !SpriteIndex
		LDA !MoleWizardState,x : BMI ..main
		..init
		ORA #$80 : STA !MoleWizardState,x
		LDA #$01 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$10 : STA !SpritePhaseTimer,x
		LDA #$C8 : STA !SpriteYSpeed,x
		RTS
		..main
		LDA !SpriteYSpeed,x : BMI ..fall
		LDA #$08 : STA !SpriteAnimIndex,x
		..fall
		LDA !SpriteBlocked,x
		AND #$04 : BNE ..land
		LDY !Difficulty
		LDA DATA_AttackWait,y : STA !MoleWizardTimer,x
		RTS
		..land
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		STZ !SpriteAnimIndex,x
		LDA !MoleWizardTimer,x : BNE ..return
		LDA #$03 : STA !MoleWizardState,x
		..return
		RTS


	.Attack
		LDX !SpriteIndex
		LDA !MoleWizardTimer,x : BNE ..return
		LDA !MoleWizardState,x : BMI ..main
		..init
		ORA #$80 : STA !MoleWizardState,x
		LDA #$05 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..main
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		LDA !SpriteAnimIndex,x : BEQ ..nextstate
		CMP #$06 : BNE ..return
		LDA !SpriteAnimTimer,x : BNE ..return

		LDY !SpriteDir,x					;\
		LDA DATA_ProjectileX,y : STA $00			; |
		STZ $01							; |
		LDA DATA_ProjectileXSpeed,y : STA $02			; | spawn mini mole
		STZ $03							; |
		SEC							; |
		LDA #$0C : JSL SpawnSprite : BMI ..return		;/
		LDA #$02 : STA.w !MiniMoleState,y			; mini mole state
		LDA #$02 : STA !SpriteAnimIndex,y			; mini mole anim
		LDA !SpriteYHi,x : XBA					;\
		LDA !SpriteYLo,x					; |
		REP #$20						; |
		SEC : SBC !P2YPosLo-$80					; |
		CMP #$FFE0 : BCS ..done					; |
		CMP #$0020 : BCC ..done					; |
		SEP #$20						; |
		BMI ..down						; |
		..up							; | aim
		LDA #$F0 : BRA ..sety					; |
		..down							; |
		LDA #$10						; |
		..sety							; |
		STA !MiniMoleBaseY,y					; |
		..done							; |
		SEP #$20						; |
		..return						; |
		RTS							;/

		..nextstate
		LDA #$04 : STA !MoleWizardState,x
		LDA #$01 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$60 : STA !MoleWizardTimer,x
		RTS


	.Sink
		LDX !SpriteIndex
		LDA !MoleWizardTimer,x : BEQ ..reset
		LDA #$04 : STA !SpriteYSpeed,x
		LDA #$10 : STA !SpritePhaseTimer,x
		RTS
		..reset
		STZ !MoleWizardState,x
		RTS


	.Illusion
		LDX !SpriteIndex
		LDA !MoleWizardState,x : BMI ..main
		..init
		ORA #$80 : STA !MoleWizardState,x
		LDA #$09 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..main
		STZ !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		LDA !MoleWizardTimer,x : BNE ..return
		STZ !MoleWizardState,x
		..return
		RTS


	.HandleMovement
		JSL APPLY_SPEED



	INTERACTION:
		JSL GetSpriteClippingE8

		LDA !MoleWizardInvinc,x : BNE .NoContact		; no contact while invincible
		LDA !MoleWizardState,x					;\
		AND #$7F						; | no contact when warping
		CMP #$02						; |
		BCC .NoContact						;/
		BEQ +							;\
		CMP #$04 : BCS .NoContact				; | only interact while on the ground
	+	LDA !SpriteBlocked,x					; |
		AND #$04 : BEQ .NoContact				;/

		.Process
		JSL InteractAttacks : BCC ..bodycheck
		INC !SpriteHP,x
		LDY !Difficulty
		LDA !SpriteHP,x
		CMP DATA_HP,y : BCC ..fade
		LDA #$02 : STA !SpriteStatus,x
		BRA .NoContact
		..bodycheck
		JSL PlayerContact : BCC .NoContact
		..illusion
		LDA #$05 : STA !MoleWizardState,x
		LDA #$20 : STA !MoleWizardTimer,x
		..fade
		STZ !SpriteXSpeed,x
		LDY !Difficulty
		LDA DATA_IFrames,y : STA !MoleWizardInvinc,x
		.NoContact


	GRAPHICS:
		LDA !SpriteStatus,x
		CMP #$02 : BNE .Anim
		LDA #$0D : STA !SpriteAnimIndex,x

		.Anim
		LDA !MoleWizardInvinc,x					;\ blink while invulnerable
		AND #$02 : BNE .Return					;/
		LDA !MoleWizardState,x					;\ don't draw while warping
		CMP #$02 : BCC .Return					;/

		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM

		.Draw
		LDA !SpritePhaseTimer,x : BNE ..p1
		..p2
		JSL LOAD_PSUEDO_DYNAMIC_p2
		PLB
		RTL

		..p1
		LDA $64 : PHA
		STZ $64
		JSL LOAD_PSUEDO_DYNAMIC_p1
		PLA : STA $64

		.Return
		PLB
	INIT:
		RTL


	ANIM:
		; idle
		dw .IdleTM		: db $FF,$00	; 00

		; spin
		dw .SpinTM00		: db $04,$02	; 01
		dw .SpinTM01		: db $04,$03	; 02
		dw .SpinTM00_X		: db $04,$04	; 03
		dw .SpinTM02		: db $04,$01	; 04

		; attack
		dw .AttackTM00		: db $10,$06	; 05
		dw .AttackTM01		: db $04,$07	; 06
		dw .AttackTM02		: db $0C,$00	; 07

		; fall
		dw .FallTM		: db $FF,$08	; 08

		; illusion
		dw .IllusionTM00	: db $01,$0A	; 09
		dw .IllusionTM01	: db $01,$0B	; 0A
		dw .IllusionTM02	: db $01,$0C	; 0B
		dw .IllusionTM03	: db $01,$09	; 0C

		; dead
		dw .DeadTM		: db $FF,$0D	; 0D


	.IdleTM
		dw $0008
		db $22,$00,$F8,$00
		db $22,$00,$00,$10

	.SpinTM00
		dw $0008
		db $02,$00,$F8,$00
		db $02,$00,$00,$10
		..X
		dw $0008
		db $42,$00,$F8,$00
		db $42,$00,$00,$10
	.SpinTM01
		dw $0008
		db $02,$00,$F8,$02
		db $02,$00,$00,$12
	.SpinTM02
		dw $0008
		db $02,$00,$F8,$04
		db $02,$00,$00,$14

	.AttackTM00
		dw $0008
		db $22,$00,$F8,$06
		db $22,$00,$00,$16
	.AttackTM01
		dw $000C
		db $22,$00,$F8,$09
		db $22,$00,$00,$19
		db $22,$F8,$00,$18
	.AttackTM02
		dw $000C
		db $22,$00,$F8,$0C
		db $22,$00,$00,$1C
		db $22,$F8,$00,$1B

	.FallTM
		dw $0008
		db $22,$00,$F8,$0E
		db $22,$00,$00,$1E

	.IllusionTM00
		dw $0008
		db $22,$06,$F8,$00
		db $22,$06,$00,$10
	.IllusionTM01
		dw $0008
		db $22,$0C,$F8,$00
		db $22,$0C,$00,$10
	.IllusionTM02
		dw $0008
		db $22,$FA,$F8,$00
		db $22,$FA,$00,$10
	.IllusionTM03
		dw $0008
		db $22,$F4,$F8,$00
		db $22,$F4,$00,$10

	.DeadTM
		dw $0008
		db $A2,$00,$F8,$1E
		db $A2,$00,$00,$0E




	DATA:
		.ProjectileX
		db $10,$F8
		.ProjectileXSpeed
		db $10,$F0

		.HP
		db $02,$02,$04

		.IFrames
		db $21,$41,$41

		.Wait
		db $80,$60,$40
		.AttackWait
		db $20,$10,$08


	namespace off





