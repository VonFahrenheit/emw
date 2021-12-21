;
; Data format per Yoshi Coin:
; [xX] [Xy] [YY] [-s] [sS]
;
; Normal levels have 5 coins, Mega Levels have 10.
; Still haven't figured out how to do Exploration Levels.
;
; X and Y are expected to be 3-digit hexadecimal numbers (but they can be entered as decimal too).
; They point to the tile coordinates of the coin.
macro YC(X, Y, SubLevel)
	db <X>&$0FF
	db <X>&$F00>>8|(<Y>&$00F<<4)
	db <Y>&$FF0>>4
	dw <SubLevel>
endmacro

; Format for sublevel number:
; NMMMMMMS ssssssss
; N is nonexistent flag; if this bit is set, the Yoshi Coin does not exist
; M is mega level number;
;	This is only set for the first coin and causes the level to load from an additional slot.
;	A value of 0 means that it's not a mega level
;	Otherwise the value will be used to count backwards from the maximum number and use that slot.
;	Value of 1 will use level 0x13B, Value of 2 will use level 0x13A, 3 will use 0x139, etc.
; S is hi bit of sublevel number
; s is lo byte of sublevel number


YoshiCoins:
	STA $00
	REP #$30
	LDA !Translevel			;\
	PHA				; < Backup translevel
	ASL #2				; | Multiply by 5 (bytes/coin)
	CLC : ADC !Translevel		;/
	STA $0E				;\
	ASL #2				; | Multiply by 5 (coins/level)
	CLC : ADC $0E			;/
	TAY
	LDX !Translevel
	LDA !LevelTable1,x
	SEP #$20
	DEC $00 : BNE .INIT
	JMP .MAIN

	.INIT
	LSR A : BCC .Init2
	JSR DestroyCoin

	.Init2
	INY #5
	LSR A : BCC .Init3
	JSR DestroyCoin

	.Init3
	INY #5
	LSR A : BCC .Init4
	JSR DestroyCoin

	.Init4
	INY #5
	LSR A : BCC .Init5
	JSR DestroyCoin

	.Init5
	INY #5
	LSR A : BCC .End
	JSR DestroyCoin

	.End
	REP #$20
	TYA
	SEC : SBC #$0019
	TAY
	LDA Data+$3,y : BMI +
	AND #$7E00 : BNE .MegaInit
+	PLA : STA !Translevel
	SEP #$20
	RTS

	.MegaInit
	XBA
	LSR A
	SEC : SBC #$0060
	EOR #$FFFF
	INC A
	STA !Translevel
	TAX
	STA $0C
	ASL #2
	CLC : ADC $0C
	STA $0C
	ASL #2
	CLC : ADC $0C
	STA $0C
	TAY
	LDA !LevelTable1,x
	SEP #$20
	JMP .INIT


	.MAIN
	STY $0C
	LSR A
	BCS .Main2
	PHA
	JSR GetPointer
	BCS +
	LDA [$05]
	XBA
	DEC $07
	LDA [$05]
	REP #$20
	CMP #$0025
	SEP #$20
	BNE +
	LDX !Translevel
	LDA !LevelTable1,x
	ORA #$01
	STA !LevelTable1,x
	+
	PLA

	.Main2
	LSR A
	BCS .Main3
	PHA
	REP #$20
	LDA $0C
	CLC : ADC #$0005
	TAY
	SEP #$20
	JSR GetPointer
	BCS +
	LDA [$05]
	XBA
	DEC $07
	LDA [$05]
	REP #$20
	CMP #$0025
	SEP #$20
	BNE +
	LDX !Translevel
	LDA !LevelTable1,x
	ORA #$02
	STA !LevelTable1,x
	+
	PLA

	.Main3
	LSR A
	BCS .Main4
	PHA
	REP #$20
	LDA $0C
	CLC : ADC #$000A
	TAY
	SEP #$20
	JSR GetPointer
	BCS +
	LDA [$05]
	XBA
	DEC $07
	LDA [$05]
	REP #$20
	CMP #$0025
	SEP #$20
	BNE +
	LDX !Translevel
	LDA !LevelTable1,x
	ORA #$04
	STA !LevelTable1,x
	+
	PLA

	.Main4
	LSR A
	BCS .Main5
	PHA
	REP #$20
	LDA $0C
	CLC : ADC #$000F
	TAY
	SEP #$20
	JSR GetPointer
	BCS +
	LDA [$05]
	XBA
	DEC $07
	LDA [$05]
	REP #$20
	CMP #$0025
	SEP #$20
	BNE +
	LDX !Translevel
	LDA !LevelTable1,x
	ORA #$08
	STA !LevelTable1,x
	+
	PLA


	.Main5
	LSR A
	BCS .Return
	PHA
	REP #$20
	LDA $0C
	CLC : ADC #$0014
	TAY
	SEP #$20
	JSR GetPointer
	BCS +
	LDA [$05]
	XBA
	DEC $07
	LDA [$05]
	REP #$20
	CMP #$0025
	SEP #$20
	BNE +
	LDX !Translevel
	LDA !LevelTable1,x
	ORA #$10
	STA !LevelTable1,x
	+
	PLA

	.Return
	LDY $0C
	REP #$20
	LDA Data+$3,y
	BMI +
	AND #$7E00
	BNE .MegaMain
+	PLA : STA !Translevel
	SEP #$20
	RTS

	.MegaMain
	XBA
	LSR A
	SEC : SBC #$0060
	EOR #$FFFF
	INC A
	STA !Translevel
	TAX
	STA $0C
	ASL #2
	CLC : ADC $0C
	STA $0C
	ASL #2
	CLC : ADC $0C
	STA $0C
	TAY
	LDA !LevelTable1,x
	SEP #$20
	JMP .MAIN


	DestroyCoin:
		PHA
		PHP
		REP #$20
		LDA Data+$3,y : BMI .Return
		AND #$01FF
		CMP !Level : BNE .Return
		LDA Data+$0,y
		ASL #4
		STA $9A
		LDA Data+$1,y
		AND #$FFF0 : STA $98
		PHY
		PHP
		SEP #$10
		LDA #$0025 : JSL !ChangeMap16			; top tile to empty space (0x025)
		LDA $98
		CLC : ADC #$0010
		STA $98
		LDA #$002B : JSL !ChangeMap16			; bottom tile to normal coin (0x02B)
		PLP
		PLY
		.Return
		PLP
		PLA
		RTS

; Returning with clear carry means coin exists on this sublevel
; Returning with set carry means coin does not exist on this sublevel
GetPointer:
	PHP
	REP #$30
	LDA Data+$3,y : BMI .NoCoin
	AND #$01FF
	CMP !Level : BNE .NoCoin

	LDA Data+$0,y
	ASL #4
	STA $02

	LDA Data+$1,y
	AND #$FFF0
	STA $00

	SEP #$30
	LDA $00
	AND #$F0
	STA $06
	LDA $02
	LSR #4
	ORA $06
	PHA
	LDA !RAM_ScreenMode
	LSR A
	BCC .Horizontal

	.Vertical
	PLA
	LDX $01
	CLC : ADC.l $00BA80,x
	STA $05
	LDA.l $00BABC,x
	ADC $03
	STA $06
	BRA .Shared

	.Horizontal
	PLA
	LDX $03
	CLC : ADC.l $006CB6,x
	STA $05
	LDA.l $006CD6,x
	ADC $01
	STA $06

	.Shared
	LDA #$41
	STA $07
	PLP
	CLC
	RTS

	.NoCoin
	PLP
	SEC
	RTS


print "Yoshi Coin data at $", pc, "."
incsrc "level_data/YoshiCoinTable.asm"





