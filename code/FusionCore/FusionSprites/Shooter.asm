
	Shooter:
		LDX !SpriteIndex
		LDA !Ex_Num,x : BMI .Main

		.Init
		ORA #$80 : STA !Ex_Num,x			; set main
		LDA !Ex_XLo,x					;\
		SEC : SBC #$02					; |
		STA $E8						; |
		LDA !Ex_XHi,x					; |
		SBC #$00					; |
		STA $E9						; |
		LDA !Ex_YLo,x					; | absorption box
		SEC : SBC #$02					; |
		STA $EA						; |
		LDA !Ex_YHi,x					; |
		SBC #$00					; |
		STA $EB						; |
		LDA #$14					; |
		STA $EC : STZ $ED				; |
		STA $EE : STZ $EF				;/
		LDX #$0F					;\
	-	LDA !SpriteStatus,x : BEQ +			; |
		JSL GetSpriteClippingE0				; | check for material to shoot
		JSL CheckContact : BCS .Eat			; |
	+	DEX : BPL -					;/
		LDX !SpriteIndex				;\
		LDA #$1C : STA !Ex_Data3,x			; | default to bullet bill if nothing is inserted
		STZ !Ex_XFraction,x				; |
		BRA +						;/

		.Eat
		STZ !SpriteStatus,x				;\
		TXY						; |
		LDX !SpriteIndex				; | set extra bits, then set sprite num
		LDA !ExtraBits,y : STA !Ex_XFraction,x		; |
		LDA !SpriteNum,y : STA !Ex_Data3,x		;/
	+	LDA #$60 : STA !Ex_Data1,x			; init timer

		.Main
		LDA !Ex_Data1,x : BEQ .Shoot			;\
		DEC !Ex_Data1,x					; |
		.Return						; | wait for timer
		SEP #$20					; |
		RTS						;/

		.Shoot
		LDA !Ex_XLo,x : STA $00				;\
		CMP $1A						; |
		LDA !Ex_XHi,x : STA $01				; |
		SBC $1B : BNE .Return				; | on-screen test
		LDA !Ex_YLo,x : STA $02				; |
		CMP $1C						; |
		LDA !Ex_YHi,x : STA $03				; |
		SBC $1D : BNE .Return				;/

		REP #$20					;\
		STZ $04						; |
		LDA $00						; |
		SEC : SBC !P2XPosLo-$80				; |
		BPL $06 : EOR #$FFFF : INC A : INC $04		; |
		CMP #$0011 : BCC .Return			; | player proximity test
		STA $06						; |
		LDA $00						; |
		SEC : SBC !P2XPosLo				; |
		BPL $06 : EOR #$FFFF : INC A : INC $05		; |
		CMP #$0011 : BCC .Return			;/
		CMP $06						;\
		LDY $04						; |
		BCC $02 : LDY $05				; |
		LDA .SmokeX,y					; | x coord of smoke
		AND #$00FF					; |
		CLC : ADC $00					; |
		SEC : SBC #$0010				; |
		STA $00						;/

		STY $0F						; $0F = direction index
		DEC $02						; $02 = Y - 1

		PHB						;\
		JSL GetParticleIndex				; |
		LDA $00 : STA !Particle_X,x			; |
		LDA $02 : STA !Particle_Y,x			; |
		SEP #$20					; | spawn smoke
		LDA.b #!prt_smoke16x16 : STA !Particle_Type,x	; |
		LDA #$17 : STA !Particle_Timer,x		; |
		PLB						; |
		SEP #$30					;/

		LDX !SpriteIndex				; restore ex index
		LDA #$09 : STA !SPC4				; bullet bill shoot SFX
		LDA #$60 : STA !Ex_Data1,x			; reset timer
		LDY #$0F					;\
	-	LDA !SpriteStatus,y : BEQ ..spawn		; | get sprite num
		DEY : BPL -					; |
		RTS						;/

		..spawn						;\
		LDA #$01 : STA !SpriteStatus,y			; |
		LDA !Ex_XLo,x : STA !SpriteXLo,y		; |
		LDA !Ex_XHi,x : STA !SpriteXHi,y		; | sprite coords, status, num, and extra bits
		LDA $02 : STA !SpriteYLo,y			; |
		LDA $03 : STA !SpriteYHi,y			; |
		LDA !Ex_Data3,x : STA !SpriteNum,y		; |
		LDA !Ex_XFraction,x : STA !ExtraBits,y		;/

		LDA $0F : PHA					; push direction
		TYX						;\ reset sprite
		JSL !InitSpriteTables				;/
		PLA : STA !SpriteDir,x				; direction
		TAY						;\
		LDA .XSpeed,y : STA !SpriteVectorX,x		; | x vector
		LDA .XAcc,y : STA !SpriteVectorAccX,x		;/
		LDA #$08					;\
		STA !SpritePhaseTimer,x				; | phase + interaction disable
		STA !SpriteDisSprite,x				;/

		LDX !SpriteIndex				; restore ex index
		RTS						; return

		.XSpeed
		db $D0,$30
		.XAcc
		db $01,$FF
		.SmokeX
		db $04,$1C




