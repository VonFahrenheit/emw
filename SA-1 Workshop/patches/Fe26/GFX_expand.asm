;
; This patch adds GFX options to vanilla sprites.
;


	Pal8Remap:
	pushpc

	org $019F48
		JML .Monty		; Org: STA !OAM+$103,y : TYA
	.ReturnMonty

	org $01B359
		JML .Platforms		; Org: LDA $64 : ORA $33C0,x
		NOP
	.ReturnPlatforms

	org $02901D
		JML .Brick		; Org: STA !OAM+$103,y : LDX $7698
		NOP #2
	.ReturnBrick

	org $029246
		JML .Bounce		; Org: LDA $7901,x : ORA $64
		NOP
	.ReturnBounce


	pullpc
	.Monty
		XBA
		LDA $3200,x
		CMP #$4D : BEQ ..Mole
		CMP #$4E : BNE ..NotMole

		..Mole
		XBA
		AND.b #$0E^$FF
		ORA !GFX_status+$09
		XBA

		..NotMole
		XBA
		STA !OAM+$103,y
		TYA
		JML .ReturnMonty

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




	GrowingVine:
	pushpc
	org $01C197
		JML .Main			; < Source: LDY $33B0,x : LDA $14
		NOP
	pullpc
	.Main
		LDY $33B0,x
		LDA $14
		LSR #4
		LDA #$AC
		BCC $02 : LDA #$AE
		CLC : ADC !GFX_status+$02
		BCC .SP2

		.SP4
		CLC : ADC #$C0			;\
		PHA				; |
		LDA !OAM+$103,y			; | Move to SP4
		ORA #$01			; |
		STA !OAM+$103,y			; |
		PLA				;/

		.SP2

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
		LDY $33B0,x
		LDA !OAM+$102-4,y
		CLC : ADC !GFX_status+$02
		BCC .SP2

		.SP4
		CLC : ADC #$C0
		STA !OAM+$102-4,y
		LDA !GFX_status+$02
		CLC : ADC #$C0
		STA $00
		CLC : ADC !OAM+$106-4,y
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

		.SP2
		STA !OAM+$102-4,y
		LDA !OAM+$106-4,y
		CLC : ADC !GFX_status+$02
		STA !OAM+$106-4,y
		LDA !OAM+$10A-4,y
		CLC : ADC !GFX_status+$02
		STA !OAM+$10A-4,y
		LDA !OAM+$10E-4,y
		CLC : ADC !GFX_status+$02
		STA !OAM+$10E-4,y
		LDA !OAM+$112-4,y
		CLC : ADC !GFX_status+$02
		STA !OAM+$112-4,y
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



