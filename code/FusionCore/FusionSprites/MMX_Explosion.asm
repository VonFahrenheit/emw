
	print "MMX Explosion inserted at $", pc
	MMX_Explosion:
		LDX $75E9

		PHB : PHK : PLB

		INC !Ex_Data1,x


		LDA !Ex_XLo,x
		SEC : SBC $1A
		STA $00
		LDA !Ex_YLo,x
		SEC : SBC $1C
		STA $01
		LDA !Ex_Data1,x
		LSR #2
		CMP #$09 : BCS .Kill
		ASL A
		TAY
		REP #$20
		LDA.w .Tilemap,y : STA $02
		LDA ($02) : STA $0E
		INC $02
		SEP #$20
		LDA #$02 : STA $0D
		JSL !SpriteHUD
		PLB
		RTS

		.Kill
		STZ !Ex_Num,x
		PLB
		RTS


		.Tilemap
		dw ..frame2
		dw ..frame1
		dw ..frame2
		dw ..frame3
		dw ..frame4
		dw ..frame5
		dw ..frame6
		dw ..frame7
		dw ..frame8

		..frame1
		db $10
		db $00,$08,$90,$3F
		db $10,$08,$90,$7F
		db $00,$18,$B0,$3F
		db $10,$18,$B0,$7F
		..frame2
		db $08
		db $00,$10,$A2,$3F
		db $10,$10,$A2,$7F
		..frame3
		db $10
		db $00,$08,$94,$3F
		db $10,$08,$94,$7F
		db $00,$18,$B4,$3F
		db $10,$18,$B4,$7F
		..frame4
		db $10
		db $00,$08,$96,$3F
		db $10,$08,$96,$7F
		db $00,$18,$B6,$3F
		db $10,$18,$B6,$7F
		..frame5
		db $10
		db $00,$08,$98,$3F
		db $10,$08,$98,$7F
		db $00,$18,$B8,$3F
		db $10,$18,$B8,$7F
		..frame6
		db $10
		db $00,$00,$8A,$3F
		db $10,$00,$8A,$7F
		db $00,$10,$AA,$3F
		db $10,$10,$AA,$7F
		..frame7
		db $10
		db $00,$00,$8C,$3F
		db $10,$00,$8C,$7F
		db $00,$10,$AC,$3F
		db $10,$10,$AC,$7F
		..frame8
		db $10
		db $00,$00,$8E,$3F
		db $10,$00,$8E,$7F
		db $00,$10,$AE,$3F
		db $10,$10,$AE,$7F

