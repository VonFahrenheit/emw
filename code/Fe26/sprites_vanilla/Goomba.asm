

	MAIN:
		LDA !SpriteStatus,x
		CMP #$02 : BEQ .Dead
		CMP #$08 : BEQ .Active
		CMP #$09 : BEQ .Stunned
		CMP #$0A : BEQ .GoStun
		CMP #$0B : BEQ +
		RTS

	.Dead
		LDA !SpriteXSpeed,x				;\
		ROL #2						; | face forward
		AND #$01 : STA !SpriteDir,x			;/
	+	JMP .Animation

	.GoStun
		LDA #$09 : STA !SpriteStatus,x

	.Stunned
		JSL APPLY_SPEED					; move
		LDA !SpriteBlocked,x				;\
		AND #$04 : BEQ ..done				; | find landing frame
		AND $F4 : BNE ..ground				;/
		LDA !SpriteXSpeed,x				;\
		CMP #$80					; |
		ROR A : STA !SpriteXSpeed,x			; |
		LDA !SpriteYSpeed,x				; |
		CMP #$20					; | bounce
		BPL $02 : LDA #$00				; > BCC can cause a bug
		LSR A						; |
		EOR #$FF : INC A				; |
		STA !SpriteYSpeed,x				;/
		BRA .Interaction
		..ground
		LDA !SpriteSlope,x				;\
		CLC : ADC #$04					; | slope accel
		TAY						; |
		LDA DATA_RollSpeed,y : JSL AccelerateX_Unlimit2	;/
		LDA !SpriteXSpeed,x				;\
		ROL #2						; | face forward
		AND #$01 : STA !SpriteDir,x			;/
		..done
		BRA .Interaction

	.Active
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED
		LDA !SpriteSlope,x : BEQ ..done
		LDA #$09 : STA !SpriteStatus,x
		..done

	.Interaction
		JSL GetSpriteClippingE8
		JSL P2Attack : BCS ..stun
		JSL ThrownItemContact : BCS ..die
		JSL FireballContact_Destroy : BCC ..nofire
		..die
		LDA #$02 : STA !SpriteStatus,x
		BRA .Animation
		..nofire

		LDA !SpriteStatus,x
		CMP #$08 : BNE ..nocontact
		JSL P2Standard : BEQ ..nocontact
		..stun
		LDA #$09 : STA !SpriteStatus,x
		..nocontact

	.Animation
		LDA !SpriteSlope,x : BNE ..spinning
		LDA !SpriteStatus,x
		CMP #$02 : BEQ ..spinning
		CMP #$09 : BEQ ..stunned
		CMP #$0B : BEQ ..stuck

		..walking
		LDA !SpriteAnimIndex,x
		CMP #$04 : BCC ..done
		LDA #$00 : BRA ..update

		..stunned
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..spinning
		LDA !SpriteXSpeed,x : BNE ..spinning
		..stuck
		LDA !SpriteAnimIndex,x
		CMP #$04 : BCC +
		CMP #$06 : BCC ..done
	+	LDA #$04 : BRA ..update

		..spinning
		LDA #$06

		..update
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		..done




	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC
	INIT:
		RTS


	DATA:
	.XSpeed
		db $08,$F8

	.RollSpeed
		db $E0,$D0,$E0,$E0,$00,$20,$20,$30,$20


	ANIM:
		dw .Walk0	: db $08,$01	; 00
		dw .Walk1	: db $08,$02	; 01
		dw .Walk0	: db $08,$03	; 02
		dw .Walk2	: db $08,$00	; 03
		dw .Stuck0	: db $04,$05	; 04
		dw .Stuck1	: db $04,$04	; 05
		dw .Rolling	: db $FF,$06	; 06

		.Walk0
		dw $0004
		db $22,$00,$00,$02

		.Walk1
		dw $0004
		db $22,$00,$00,$04

		.Walk2
		dw $0004
		db $22,$00,$00,$06

		.Rolling
		dw $0004
		db $22,$00,$00,$00

		.Stuck0
		dw $0004
		db $A2,$00,$00,$02

		.Stuck1
		dw $0004
		db $A2,$00,$00,$04


