

	GoombaRoll:
	pushpc
	org $018B11					; code that runs when sprite 0-13 is on the ground
		JML .Main				; org: LDA $88F0,y : LSR A
		.Return

	org $0197D5
		LDA (!SpriteNum_ptr)			;\ check sprite num
		CMP #$0F : BNE .NotGoomba		;/
		.Goomba
		JML .GoombaStunned
		.NotGoomba
		LDA !SpriteXSpeed,x : BPL +		;\
		EOR #$FF : INC A			; |
		LSR A					; |
		EOR #$FF : INC A			; | optimize halve X speed code
		BRA ++					; |
	+	LSR A					; |
	++	STA !SpriteXSpeed,x			;/
		LDA !SpriteYSpeed,x : PHA		;\
		JSR $9A04				; > "SetSomeYSpeed??" in all.log
		PLA					; |
		LSR #2					; |
		TAY					; | sprite Y speed when hitting ground
		LDA $97AF,y				; |
		LDY $3330,x : BMI .RTS			; |
		STA !SpriteYSpeed,x			;/
	.RTS	RTS					; return
	warnpc $019806
	pullpc
	.Main
		CPY #$0F : BNE .Restore
		LDA !SpriteSlope,x : BEQ .Restore
		LDA #$09 : STA $3230,x			; goomba goes to state 09 on slopes
		JML $018BC3				; go to GFX routine
	.Restore
		LDA $88F0,y
		LSR A
		JML .Return


	.GoombaStunned
		LDA !SpriteSlope,x : BEQ .NoSlope
		ASL A
		ROL A
		AND #$01
		TAX
		LDA.l .XSpeed,x
		LDX !SpriteIndex
		CMP !SpriteXSpeed,x : BEQ ..speeddone
		CMP #$00 : BPL ..right
	..left	BIT !SpriteXSpeed,x : BPL ..dec
		CMP !SpriteXSpeed,x : BCC ..dec
		BRA ..inc
	..right	BIT !SpriteXSpeed,x : BMI ..inc
		CMP !SpriteXSpeed,x : BCC ..inc
	..inc	INC !SpriteXSpeed,x : BRA ..speeddone
	..dec	DEC !SpriteXSpeed,x

		..speeddone
		LDA !SpriteXSpeed,x
		ASL A
		ROL A
		EOR #$01
		AND #$01
		STA $3320,x
	..R	JML .RTS

		.NoSlope
		LDA !SpriteXSpeed,x : BPL +		;\
		EOR #$FF : INC A			; |
		LSR A					; |
		EOR #$FF : INC A			; | optimize halve X speed code
		BRA ++					; |
	+	LSR A					; |
	++	STA !SpriteXSpeed,x			;/
		LDA !SpriteYSpeed,x			; load Y speed
		LDY $3330,x : BMI +			;\ "SetSomeYSpeed??" in all.log, clear Yspeed unless touching layer 2 ceiling
		STZ !SpriteYSpeed,x			;/
	+	LSR #2					;\
		CLC : ADC #$13				; |
		TAY					; | goomba Y speed when hitting ground
		LDA $97AF,y				; |
		LDY $3330,x : BMI ..R			; |
		STA !SpriteYSpeed,x			;/
	..R	JML .RTS


		.XSpeed
		db $20,$E0



