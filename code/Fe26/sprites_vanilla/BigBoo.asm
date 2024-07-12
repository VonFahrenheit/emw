


	!Temp = 0
	%def_anim(BigBoo_Hands_Hide, 1)
	%def_anim(BigBoo_Hands_Open, 5)
	%def_anim(BigBoo_Hands_Wide, 1)
	%def_anim(BigBoo_Hands_Chase, 4)
	%def_anim(BigBoo_Hands_Chill, 1)

	!Temp = 0
	%def_anim(BigBoo_Eyes_Neutral, 1)
	%def_anim(BigBoo_Eyes_Angry, 1)

	!Temp = 0
	%def_anim(BigBoo_Mouth_Happy, 1)
	%def_anim(BigBoo_Mouth_Grump, 1)
	%def_anim(BigBoo_Mouth_Angry, 1)

	!Temp = 0
	%def_anim(BigBoo_Body_Forward, 1)
	%def_anim(BigBoo_Body_Turning, 2)



	!BigBooHandsAnim	= $3500
	!BigBooEyesAnim		= $3510
	!BigBooMouthAnim	= $3520
	!BigBooBodyAnim		= $3530

	!BigBooFaceOffset	= $3540
	!BigBooRageTimer	= $3550
	!BigBooHandsTimer	= $3560


	INIT:
		RTS

	MAIN:


	.HandleFacing
		JSL SUB_HORZ_POS
		CPY !P2Dir-$80 : BNE ..rage
		..resetrage
		LDA #$18 : STA !BigBooRageTimer,x
		STZ !BigBooHandsTimer,x
		BRA ..handlesprite
		..rage
		LDA !BigBooRageTimer,x : BEQ ..handlesprite
		DEC !BigBooRageTimer,x
		..handlesprite
		TYA
		CMP !SpriteDir,x : BEQ ..face
		..turning
		INC !BigBooFaceOffset,x
		LDA !BigBooFaceOffset,x
		CMP #$11 : BNE ..done
		..turn
		TYA : STA !SpriteDir,x
		LDA #$0B : STA !BigBooFaceOffset,x
		..face
		LDA !BigBooFaceOffset,x : BEQ ..done
		DEC !BigBooFaceOffset,x
		STZ !BigBooHandsTimer,x
		..done


		INC !BigBooHandsTimer,x



		.AnimUpdate

		LDY !BigBooRageTimer,x
		LDA .EyesTable,y : STA !BigBooEyesAnim,x
		LDA .MouthTable,y : STA !BigBooMouthAnim,x
		CPY #$00 : BEQ +
		LDA .HandsTable,y : BRA ++

	+	LDA !BigBooHandsTimer,x
		LSR #3
		AND #$03
		CLC : ADC #!BigBoo_Hands_Chase
	++	STA !BigBooHandsAnim,x
	





		LDA #!BigBoo_Body_Forward
		LDY !BigBooFaceOffset,x : BEQ ..setbody
		CPY #$08 : BCC ..slightturn
		..fullturn
		LDA #!BigBoo_Body_Turning+1 : BRA ..setbody
		..slightturn
		LDA #!BigBoo_Body_Turning+0
		..setbody
		STA !BigBooBodyAnim,x




	.Draw
		LDA !SpriteXLo,x : STA $E0
		LDA !SpriteXHi,x : STA $E1
		LDA !BigBooFaceOffset,x
		LDY !SpriteDir,x
		BNE $03 : EOR #$FF : INC A
		STA $00
		CLC : ADC !SpriteXLo,x
		STA $E2
		LDA #$00
		BIT $00
		BPL $02 : LDA #$FF
		ADC !SpriteXHi,x
		STA $E3




		REP #$20
		LDA !BigBooHandsAnim,x
		AND #$00FF
		ASL A : TAY
		PHY
		LDA .HandsTilemapPtr_hiprio,y : STA $04

		LDY !BigBooHandsAnim,x
		CPY #!BigBoo_Hands_Chase : BCC +
		CPY #!BigBoo_Hands_Chase_over : BCC ++
	+	LDA #$0000 : BRA +++
	++	LDA !BigBooFaceOffset,x
		AND #$00FF
		LSR #2
		CMP #$0003
		BCC $03 : LDA #$0003
		LDY !SpriteDir,x
		BNE $04 : EOR #$FFFF : INC A
	+++	CLC : ADC $E2
		SEP #$20
		STA !SpriteXLo,x
		XBA : STA !SpriteXHi,x
		JSL LOAD_PSUEDO_DYNAMIC


		LDA $E2 : STA !SpriteXLo,x
		LDA $E3 : STA !SpriteXHi,x
		REP #$20
		LDA !BigBooEyesAnim,x
		AND #$00FF
		ASL A : TAY
		LDA .EyesTilemapPtr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		REP #$20
		LDA !BigBooMouthAnim,x
		AND #$00FF
		ASL A : TAY
		LDA .MouthTilemapPtr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		REP #$20
		LDA !BigBooBodyAnim,x
		AND #$00FF
		ASL A : TAY
		LDA .BodyTilemapPtr,y : STA $04
		SEP #$20
		LDA $E0 : STA !SpriteXLo,x
		LDA $E1 : STA !SpriteXHi,x
		JSL LOAD_PSUEDO_DYNAMIC

		LDA $E0 : STA !SpriteXLo,x
		LDA $E1 : STA !SpriteXHi,x
		PLY
		REP #$20
		LDA .HandsTilemapPtr_loprio,y : BEQ +
		STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		+

		RTS



	.HandsTable
	db !BigBoo_Hands_Wide
	rep 8 : db !BigBoo_Hands_Open+4
	rep 6 : db !BigBoo_Hands_Open+3
	rep 4 : db !BigBoo_Hands_Open+2
	rep 2 : db !BigBoo_Hands_Open+1
	rep 2 : db !BigBoo_Hands_Open+0
	rep 2 : db !BigBoo_Hands_Hide

	.EyesTable
	db !BigBoo_Eyes_Angry
	rep 8 : db !BigBoo_Eyes_Angry
	rep 6 : db !BigBoo_Eyes_Neutral
	rep 4 : db !BigBoo_Eyes_Neutral
	rep 2 : db !BigBoo_Eyes_Neutral
	rep 2 : db !BigBoo_Eyes_Neutral
	rep 2 : db !BigBoo_Eyes_Neutral

	.MouthTable
	db !BigBoo_Mouth_Angry
	rep 8 : db !BigBoo_Mouth_Grump
	rep 6 : db !BigBoo_Mouth_Grump
	rep 4 : db !BigBoo_Mouth_Grump
	rep 2 : db !BigBoo_Mouth_Grump
	rep 2 : db !BigBoo_Mouth_Happy
	rep 2 : db !BigBoo_Mouth_Happy





	.HandsTilemapPtr
	..hiprio
		dw .HandsHide
		dw .HandsOpen1
		dw .HandsOpen2
		dw .HandsOpen3
		dw .HandsOpen4
		dw .HandsOpen5
		dw .HandsWide
		dw .HandsChase1
		dw .HandsChase2
		dw .HandsChase3
		dw .HandsChase4
		dw .HandsChill
	..loprio
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw .HandBackWide
		dw .HandBack1
		dw .HandBack2
		dw .HandBack3
		dw .HandBack4
		dw .HandBackChill

	.EyesTilemapPtr
		dw .EyesNeutral
		dw .EyesAngry

	.MouthTilemapPtr
		dw .MouthHappy
		dw .MouthGrump
		dw .MouthAngry

	.BodyTilemapPtr
		dw .BodyForward
		dw .BodyTurningSlight
		dw .BodyTurningFull


	; hand tilemaps

		.HandsHide
		dw ..end-..start
		..start
		db $42,$E7,$FE,$0E
		db $02,$F9,$FE,$0E
		..end

		.HandsOpen1
		dw ..end-..start
		..start
		db $42,$E7,$FF,$0E
		db $02,$F9,$FF,$0E
		..end

		.HandsOpen2
		dw ..end-..start
		..start
		db $42,$E7,$00,$0E
		db $02,$F9,$00,$0E
		..end

		.HandsOpen3
		dw ..end-..start
		..start
		db $42,$E7,$01,$0E
		db $02,$F9,$01,$0E
		..end

		.HandsOpen4
		dw ..end-..start
		..start
		db $42,$E7,$02,$0E
		db $02,$F9,$02,$0E
		..end

		.HandsOpen5
		dw ..end-..start
		..start
		db $42,$E6,$03,$0E
		db $02,$FA,$03,$0E
		..end

		.HandsWide
		.HandsChase1
		dw ..end-..start
		..start
		db $42,$08,$00,$0E
		..end
		.HandsChase2
		dw ..end-..start
		..start
		db $42,$08,$FF,$0E
		..end
		.HandsChase3
		dw ..end-..start
		..start
		db $42,$08,$FE,$0E
		..end
		.HandsChase4
		dw ..end-..start
		..start
		db $42,$08,$FF,$0E
		..end

		.HandsChill
		dw ..end-..start
		..start
		db $C2,$08,$10,$0E
		..end

		.HandBackWide
		dw ..end-..start
		..start
		db $02,$E5,$00,$0E
		..end

		.HandBack1
		dw ..end-..start
		..start
		db $02,$E3,$00,$0E
		..end
		.HandBack2
		dw ..end-..start
		..start
		db $02,$E3,$01,$0E
		..end
		.HandBack3
		dw ..end-..start
		..start
		db $02,$E3,$02,$0E
		..end
		.HandBack4
		dw ..end-..start
		..start
		db $02,$E3,$01,$0E
		..end

		.HandBackChill
		dw ..end-..start
		..start
		db $82,$E5,$10,$0E
		..end



	; eye tilemaps

		.EyesAngry
		dw ..end-..start
		..start
		db $02,$F0,$FA,$20
		..end

		.EyesNeutral
		dw ..end-..start
		..start
		db $02,$F0,$FA,$22
		..end


	; mouth tilemaps

		.MouthHappy
		dw ..end-..start
		..start
		db $82,$F0,$0A,$26
		..end

		.MouthGrump
		dw ..end-..start
		..start
		db $02,$F0,$0A,$26
		..end

		.MouthAngry
		dw ..end-..start
		..start
		db $02,$F0,$0A,$24
		..end


	; body tilemaps

		.BodyForward
		dw ..end-..start
		..start
		db $02,$E8,$E8,$00
		db $02,$F8,$E8,$02
		db $02,$08,$E8,$04
		db $02,$18,$E8,$06
		db $02,$E8,$F8,$08
		db $02,$F8,$F8,$09
		db $02,$08,$F8,$0A
		db $02,$18,$F8,$0C
		db $82,$E8,$08,$08
		db $82,$F8,$08,$09
		db $02,$08,$08,$28
		db $02,$18,$08,$2A
		db $82,$E8,$18,$00
		db $82,$F8,$18,$02
		db $02,$08,$18,$2C
		db $02,$18,$18,$2E
		..end


		; tiles drawn back -> front
		; this prevents cutoff on the tiles that overlap
		; which they do, because it saves some gfx space
		.BodyTurningSlight
		dw ..end-..start
		..start
		db $02,$18,$E8,$06
		db $02,$08,$E8,$04
		db $02,$F9,$E8,$02
		db $02,$E9,$E8,$00
		db $02,$18,$F8,$0C
		db $02,$08,$F8,$0A
		db $02,$F9,$F8,$09
		db $02,$E9,$F8,$08
		db $02,$16,$08,$2A
		db $02,$06,$08,$28
		db $82,$F9,$08,$09
		db $82,$E9,$08,$08
		db $02,$16,$18,$2E
		db $02,$06,$18,$2C
		db $82,$F9,$18,$02
		db $82,$E9,$18,$00
		..end


		; tiles drawn back -> front
		; this prevents cutoff on the tiles that overlap
		; which they do, because it saves some gfx space
		.BodyTurningFull
		dw ..end-..start
		..start
		db $02,$18,$E8,$06
		db $02,$08,$E8,$04
		db $02,$FA,$E8,$02
		db $02,$EA,$E8,$00
		db $02,$18,$F8,$0C
		db $02,$08,$F8,$0A
		db $02,$FA,$F8,$09
		db $02,$EA,$F8,$08
		db $82,$18,$08,$0C
		db $82,$08,$08,$0A
		db $82,$FA,$08,$09
		db $82,$EA,$08,$08
		db $82,$18,$18,$06
		db $82,$08,$18,$04
		db $82,$FA,$18,$02
		db $82,$EA,$18,$00
		..end


