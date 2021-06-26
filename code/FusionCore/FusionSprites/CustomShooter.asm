
	print "Custom Shooter inserted at $", pc
	CustomShooter:
		LDX $75E9					;\
		LDA !Ex_XLo,x					; |
		SEC : SBC #$02					; |
		STA $00						; |
		LDA !Ex_XHi,x					; |
		SBC #$00					; |
		STA $08						; |
		LDA !Ex_YLo,x					; | absorption box
		SEC : SBC #$02					; |
		STA $01						; |
		LDA !Ex_YHi,x					; |
		SBC #$00					; |
		STA $09						; |
		LDA #$14					; |
		STA $02						; |
		STA $03						;/

		LDX #$0F					;\
	-	LDA $3230,x : BEQ +				; |
		JSL !GetSpriteClipping04			; | check for material to shoot
		JSL !CheckContact				; |
		BCS .Init					; |
	+	DEX : BPL -					;/
		LDX $75E9					;\
		LDA #$1C : STA !Ex_Data3,x			; | default to bullet bill if nothing is inserted
		STZ !Ex_XFraction,x				; |
		BRA +						;/

	.Init	STZ $3230,x					;\
		TXY						; |
		LDX $75E9					; | set extra bits, then check custom/vanilla
		LDA !ExtraBits,y : STA !Ex_XFraction,x		; |
		AND #$08 : BNE .Custom				;/

		.Vanilla
		LDA $3200,y : STA !Ex_Data3,x			;\ vanilla sprite num
		BRA +						;/

		.Custom
		LDA !NewSpriteNum,y : STA !Ex_Data3,x		; custom sprite num
	+	LDA.b #$01+!ShooterOffset : STA !Ex_Num,x	;\
		LDA #$60 : STA !Ex_Data1,x			; | transform into shooter
		RTS						;/


