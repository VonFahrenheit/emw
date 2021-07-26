SpinySpecial:

	namespace SpinySpecial

	INIT:
		PHB : PHK : PLB
		LDA $3220,x : STA $3280,x		;\ Backup spawn coords
		LDA $3210,x : STA $3290,x		;/


		LDA !ExtraBits,x			;\
		AND #$04 : BEQ .NormalSpiny		; | If extra bit is set, this is not a normal spiny
		LDA #$36 : STA $3200,x			; | (it's a rolling one!)
		.NormalSpiny				;/

		LDA #$80 : STA $3300,x			; > Stay stationary for 128 frames

		PLB
		RTL

	MAIN:
		PHB : LDA #$01
		PHA : PLB
		LDA $3300,x : BEQ .FallNormal		;\
		LDA $3280,x : STA $3220,x		; | Enforce spawn coords if timer is set
		LDA $3290,x : STA $3210,x		;/
		STZ $9E,x				; > Also clear acceleration buildup

		.FallNormal
		LDA !ExtraBits,x
		AND #$04 : BNE Special
		PHK : PEA.w .ReturnLong-1		; RTL address
		PEA.w $8021-1				; RTS -> RTL
		JML $018C18				; > Falling spiny code

		.ReturnLong
		LDA $3200,x				;\
		CMP #$13 : BNE .Return			; |
		LDA !ExtraBits,x			; | Clear custom bit upon landing
		AND.b #$0C^$FF				; |
		STA !ExtraBits,x			;/

		.Return
		PLB
		RTL


	Special:
		PHK : PLB
		JSL SPRITE_OFF_SCREEN
		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00
		JSR .Interact
		PLA
	.P2	LSR A : BCC .NoContact
		LDY #$80
		PEA.w .NoContact-1

		.Interact
	;	JSL CheckCrush_Long : BCC ..Hurt
		LDA #$02 : STA !SPC1
		JSL P2Bounce
		RTS

	..Hurt	TYA
		CLC
		ROL #2
		INC A
		JSL !HurtPlayers
		RTS

		.NoContact
		LDA $3300,x : BEQ .Bouncing

		.Charging
		LDY $32A0,x : BNE .GFX			; If this is set, don't do charge effects
		AND #$0F : BNE .GFX
		LDA !RNG
		AND #$0E
		TAY
		REP #$20
		LDA #$0003
		STA $00
		STA $02
		LDA.w .StarSpeed,y : STA $04
		SEP #$20
		LDA #$0D
		LDY #$01
		JSL SpawnExSprite
		LDA #$10 : STA !SPC1			; VROOM sound
		BRA .GFX

		.Bouncing
		LDA $9E,x : BMI .NoBounce
		LDA $3330,x
		AND #$04 : BEQ .NoBounce
		LDA $AE,x : BNE .Roll
		JSL SUB_HORZ_POS
		LDA .XSpeed,y : STA $AE,x
	.Roll	LDA $9E,x
		LSR A
		EOR #$FF
		CMP #$F0 : BCC .Bounce
		LDA #$10
	.Bounce	STA $9E,x
		.NoBounce

		LDA $3330,x
		AND #$03 : BEQ .NoWall
		LDA $AE,x
		EOR #$FF : INC A
		STA $AE,x
		.NoWall

		DEC $9E,x
		JSL !SpriteApplySpeed

		.GFX
		REP #$20
		LDA $14
		AND #$0004
		BEQ $03 : LDA #$0006
		CLC : ADC.w #.TM0
		STA $04
		SEP #$20
		JSL LOAD_TILEMAP

		PLB
		RTL



	.TM0
	dw $0004
	db $39,$00,$00,$84

	.TM1
	dw $0004
	db $39,$00,$00,$86

	.XSpeed
	db $20,$E0

	.StarSpeed
	db $16,$16
	db $20,$00
	db $16,$E9
	db $00,$E0
	db $E9,$E9
	db $E0,$00
	db $E9,$16
	db $00,$20


	namespace off





