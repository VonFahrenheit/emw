;
; This patch adds GFX options to vanilla sprites.
;



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









