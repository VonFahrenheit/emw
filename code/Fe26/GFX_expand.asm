;
; This patch adds GFX options to vanilla sprites.
;


	Pal8Remap:

	pushpc
	org $019F48
		JML .Generic		; Org: STA !OAM+$103,y : TYA
	.ReturnMonty

	org $01B359
		JML .Platforms		; Org: LDA $64 : ORA $33C0,x
		NOP
	.ReturnPlatforms

	org $01C65C			; Org: STA $6303,y : TXA
		JML .Coin
	.ReturnCoin

	org $02901D
		JML .Brick		; Org: STA !OAM+$103,y : LDX $7698
		NOP #2
	.ReturnBrick

	org $029246
		JML .Bounce		; Org: LDA $7901,x : ORA $64
		NOP
	.ReturnBounce

	org $07F790
		JSL .Tweaker		; Org: LDA $07F3FE,x

	org $07F7B3
		JSL .Tweaker		; Org: LDA $07F3FE,x

	pullpc
	.Generic
		XBA
		LDA $3200,x
		CMP #$4D : BEQ ..Mole
		CMP #$4E : BEQ ..Mole
		CMP #$0F : BEQ ..Goomba
		CMP #$10 : BEQ ..Goomba
		CMP #$21 : BNE ..NotSpecial

		..Coin



		XBA
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		BRA ..Done

		..Goomba
		LDA !OAM+$102,y
		CLC : ADC !GFX_status+$10
		CLC : ADC !GFX_status+$10
		STA !OAM+$102,y
		BIT !GFX_status+$10 : BPL ..NotSpecial
		XBA
		EOR #$01
		BRA ..Done

		..Mole
		XBA
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		BIT !GFX_status+$12
		BPL $02 : EOR #$01
		XBA
		LDA !OAM+$102,y
		CLC : ADC !GFX_status+$12
		CLC : ADC !GFX_status+$12
		STA !OAM+$102,y

		..NotSpecial
		XBA
	..Done	STA !OAM+$103,y
		TYA
		JML .ReturnMonty


	.Coin
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		STA $6303,y
		TXA
		JML .ReturnCoin



	.Platforms
		LDA $64
		ORA $33C0,x
		PHA
		AND #$0E : BEQ ..8
		PLA
		JML .ReturnPlatforms

	..8	PLA
		ORA !GFX_status+$09
		JML .ReturnPlatforms


	.Brick
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		STA !OAM+$003,y
		LDX $7698
		JML .ReturnBrick

	.Bounce
		LDA $7901,x
		ORA $64
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		JML .ReturnBounce


	.Tweaker
		LDA $07F3FE,x
		PHA
		AND #$0E : BEQ ..8
		PLA
		RTL

	..8	PLA
		ORA !GFX_status+$09
		RTL



	GrowingVine:
	pushpc
	org $01C197
		JML .Main			; < Source: LDY $33B0,x : LDA $14
		NOP
	pullpc
	.Main
		LDY $33B0,x

		LDA !OAM+$103,y
		AND.b #$10^$FF
		ORA #$20			; priority = 2
		STA $0F

		LDA !GFX_status+$02
		CMP #$2A : BCC .Page1
		CMP #$AA : BCS .Page1

		.Page2
		INC $0F				; move to page 2

		.Page1
		LDA $0F : STA !OAM+$103,y
		LDA $14
		LSR #4
		LDA #$AC
		BCC $02 : LDA #$AE
		CLC : ADC !GFX_status+$02
		CLC : ADC !GFX_status+$02
		JML $01C1A3



	JumpingPiranhaPlant:
	pushpc
	org $019DE1
		BRA $03				;\ Source: TYA : CLC : ADC #$08 : TAY (causes bugs)
		NOP #3				;/

	org $02E118
		JML .Main			; < Source: PLA : STA $3240,x
	.Return
	pullpc
	.Main
		LDA !GFX_status+$02
		ASL A
		STA $00
		LDY $33B0,x

		LDA !OAM+$102-4,y
		CLC : ADC $00
		STA !OAM+$102-4,y
		LDA !OAM+$106-4,y
		CLC : ADC $00
		STA !OAM+$106-4,y
		LDA !OAM+$10A-4,y
		CLC : ADC $00
		STA !OAM+$10A-4,y
		LDA !OAM+$10E-4,y
		CLC : ADC $00
		STA !OAM+$10E-4,y
		LDA !OAM+$112-4,y
		CLC : ADC $00
		STA !OAM+$112-4,y

		LDA !GFX_status+$02
		CMP #$2A : BCC .Page1
		CMP #$AA : BCC .Page2

		.Page1
		PLA : STA $3240,x
		JML .Return

		.Page2
		LDA !OAM+$103-4,y
		ORA #$01
		STA !OAM+$103-4,y
		LDA !OAM+$107-4,y
		ORA #$01
		STA !OAM+$107-4,y
		LDA !OAM+$10B-4,y
		ORA #$01
		STA !OAM+$10B-4,y
		LDA !OAM+$10F-4,y
		ORA #$01
		STA !OAM+$10F-4,y
		LDA !OAM+$113-4,y
		ORA #$01
		STA !OAM+$113-4,y
		PLA : STA $3240,x
		JML .Return


	VolcanoLotusFire:
	pushpc
	org $029B99
		JML .Main		; Org: STA !OAM+$002,y : TYA
	.Return
	pullpc
	.Main
		CLC : ADC !GFX_status+$0A
		CLC : ADC !GFX_status+$0A
		STA !OAM+$002,y
		BIT !GFX_status+$0A : BPL +
		LDA !OAM+$003,y
		EOR #$01
		STA !OAM+$003,y
	+	TYA
		JML .Return


	GoombaWings:
	pushpc
	org $018E2E
		JML .Main		; Org: STA !OAM+$102,y : PHY
	.Return
	org $018E36
		LDA #$02		; Org: LDA $8DDF,x
		NOP
	pullpc
	.Main
		JSR Wing
		STA !OAM+$102,y
		PHY
		JML .Return


		Wing:
		CMP #$C0 : BCC .Closed
		LDA #$AA
		RTS
	.Closed	LDA #$AC
		RTS


	pushpc
	org $019E10
		db $F7,$F7,$09,$09	; wing x disp
	org $019E1C
		db $AC,$AA,$AC,$AA	; wing tiles
		db $46,$46,$06,$06	; wing prop
		db $02,$02,$02,$02	; wing size
	pullpc












