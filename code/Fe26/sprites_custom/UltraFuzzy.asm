

UltraFuzzy:

	namespace UltraFuzzy

	MAIN:
		PHB : PHK : PLB

		INC $3280,x
		REP #$30
		LDA $3280,x
		AND #$00FF
		ASL #2
		CMP #$0200
		PHP
		AND #$01FF
		TAX
		LDA.l !TrigTable,x
		LSR #4
		PLP
		BCC $04 : EOR #$FFFF : INC A
		SEP #$30
		LDX !SpriteIndex
		STA !SpriteYSpeed,x
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x

		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y

		JSL GetSpriteClippingE8
		JSL ThrownItemContact : BCS .Die
		JSL FireballContact_Destroy : BCS .Die
		JSL P2Attack : BCS .Touch
		JSL PlayerContact : BCC .NoContact
		.Touch
		LDA !StarTimer : BNE .Die

		LDA #$0F
		STA !P2Stasis-$80
		STA !P2Stasis
		STZ !Level+2
		LDA #$04 : STA !Level+3
		LDA #$F3 : STA $6DB0

		LDA #$3F : STA !SPC4			; dizzy sfx

		.P1Dizzy
		LDA !P2Status-$80 : BNE ..done
		LDA.b #!DizzyStar_Num : JSL SpawnExSprite_NoSpeed
		LDA #$40 : STA !Ex_Data1,y
		LDA #$FF : STA !Ex_Data2,y
		LDA #$F0 : STA !Ex_Data3,y
		..done

		.P2Dizzy
		LDA !P2Status : BNE ..done
		LDA.b #!DizzyStar_Num : JSL SpawnExSprite_NoSpeed
		LDA #$80 : STA !Ex_Data1,y
		LDA #$FF : STA !Ex_Data2,y
		LDA #$F0 : STA !Ex_Data3,y
		..done

		.Die
		LDA #$04 : STA !SpriteStatus,x

		.NoContact

		.Graphics
		REP #$20
		LDA.w #ANIM_Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

	.Return
		PLB
	INIT:
		RTL


	DATA:
	.XSpeed
		db $08,$F8

	ANIM:
	.Tilemap
		dw $0010
		db $32,$F8,$F8,$00
		db $32,$08,$F8,$02
		db $32,$F8,$08,$04
		db $32,$08,$08,$06



	namespace off




