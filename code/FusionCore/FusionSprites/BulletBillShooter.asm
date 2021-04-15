

	; bullet bill shooter rewrite
	pushpc
	org $02B466
	BulletBillShooter:
		LDA !Ex_Data1,x : BEQ .Run
	.r	RTS

		.Run
		LDA #$60 : STA !Ex_Data1,x
		LDA !Ex_YLo,x				;\
		CMP $1C					; |
		LDA !Ex_YHi,x				; |
		SBC $1D					; |
		BNE .r					; | on-screen test
		LDA !Ex_XLo,x				; |
		CMP $1A					; |
		LDA !Ex_XHi,x				; |
		SBC $1B					; |
		BNE .r					;/
		JSL Ex_GetIndex_Y			; Y = index for smoke puff
		LDA !Ex_XHi,x : XBA			;\
		LDA !Ex_XLo,x				; |
		REP #$20				; |
		STZ $0E					; > clear $0E and $0F
		PHA					; | 0 = shoot left, 1 = shoot right
		SEC : SBC !P2XPosLo-$80			; |
		BPL $06 : EOR #$FFFF : INC A : INC $0E	; | see if either player is too close
		STA $00					; |
		CMP #$0011 : BCS .checkp2		; |
	.rPLA	PLA					; |
	.rSEP	SEP #$20				; |
		RTS					; |
		.checkp2				; |
		PLA					; |
		SEC : SBC !P2XPosLo			; |
		BPL $06 : EOR #$FFFF : INC A : INC $0F	; |
		CMP #$0011 : BCC .rSEP			;/
		CMP $00					;\
		SEP #$20				; | smoke left or right?
		BCC .shootp2				;/
		.shootp1				;\
		LDA $0E					; | P1 dir
		ASL A					; |
		BRA +					;/
		.shootp2				;\
		LDA $0F					; | P2 dir
		ASL A					;/
	+	STA $00					; > set dir
		LDA #$01+!SmokeOffset : STA !Ex_Num,y	;\
		LDA !Ex_YLo,x : STA !Ex_YLo,y		; |
		LDA !Ex_YHi,x : STA !Ex_YHi,y		; |
		LDA !Ex_XHi,x : XBA			; |
		LDA !Ex_XLo,x				; |
		REP #$20				; |
		PHX					; | spawn smoke
		LDX $00					; |
		CLC : ADC .XDisp,x			; |
		PLX					; |
		SEP #$20				; |
		STA !Ex_XLo,y				; |
		XBA : STA !Ex_XHi,y			; |
		LDA #$1B : STA !Ex_Data1,y		;/
		JSL !GetSpriteSlot			;\ see if bullet can spawn
		BMI .r2					;/
		LDA #$09 : STA !SPC4			; bullet bill shoot SFX
		JSL .ShootBill				; moved to other bank so this fits
	.r2	RTS

		.XDisp
		dw $FFF4,$000C
	warnpc $02B51A
	pullpc

		.ShootBill
		LDA #$1C : STA $3200,y			;\
		LDA #$01 : STA $3230,y			; |
		LDA #$00 : STA !ExtraBits,y		; |
		PHX					; |
		TYX					; |
		JSL !InitSpriteTables			; |
		TXY					; |
		PLX					; | spawn bullet
		LDA !Ex_XLo,x : STA $3220,y		; |
		LDA !Ex_XHi,x : STA $3250,y		; |
		LDA !Ex_YLo,x				; |
		SEC : SBC #$01				; |
		STA $3210,y				; |
		LDA !Ex_YHi,x				; |
		SBC #$00				; |
		STA $3240,y				;/
		RTL					; return


