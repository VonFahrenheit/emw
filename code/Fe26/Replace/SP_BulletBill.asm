


	pushpc
	org $0184DD
	BulletBillInit:
		JSL BulletBillTarget
		STA $BE,x
		LDA #$10 : STA $32D0,x
		RTS
	warnpc $0184E9
	pullpc
	BulletBillTarget:
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		STZ $0E
		STA $00
		SEC : SBC !P2XPosLo-$80
		BPL $06 : EOR #$FFFF : INC A : INC $0E
		STA $02
		LDA $00
		SEC : SBC !P2XPosLo
		BPL $06 : EOR #$FFFF : INC A : INC $0F
		CMP $02
		SEP #$20
		BCC .TargetP2
	.TargetP1
		LDA $0E
		EOR #$01
		RTL
	.TargetP2
		LDA $0F
		EOR #$01
		RTL



