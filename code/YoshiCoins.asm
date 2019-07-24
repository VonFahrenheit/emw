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
	LDA !Translevel		;\
	PHA			; < Backup translevel
	ASL #2			; | Multiply by 5 (bytes/coin)
	CLC : ADC !Translevel	;/
	STA $0E			;\
	ASL #2			; | Multiply by 5 (coins/level)
	CLC : ADC $0E		;/
	TAY
	LDX !Translevel
	LDA $40400B,x
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
	LDA $40400B,x
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
	LDA $40400B,x
	ORA #$01
	STA $40400B,x
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
	LDA $40400B,x
	ORA #$02
	STA $40400B,x
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
	LDA $40400B,x
	ORA #$04
	STA $40400B,x
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
	LDA $40400B,x
	ORA #$08
	STA $40400B,x
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
	LDA $40400B,x
	ORA #$10
	STA $40400B,x
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
	LDA $40400B,x
	SEP #$20
	JMP .MAIN


DestroyCoin:
	PHA
	PHP
	LDA #$02 : STA $9C
	REP #$20
	LDA Data+$3,y : BMI .Return
	AND #$01FF
	CMP !Level : BNE .Return
	LDA Data+$0,y
	ASL #4
	STA $9A
	LDA Data+$1,y
	AND #$FFF0
	STA $98
	PHY
	PHA
	PEI ($9A)
	PHP
	SEP #$30
	JSL $00BEB0
	PLP
	PLA : STA $9A
	PLA
	CLC : ADC #$0010
	STA $98
	PHP
	SEP #$30
	JSL $00BEB0
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

Data:
.000
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.001
%YC(80, 12, $001)
%YC(203, 20, $001)
%YC(226, 6, $001)
%YC(29, 150, $026)
%YC(4, 139, $026)

.002
%YC(7, 3, $0202)		; Mega level 1 (lowest bit of M equals 2)
%YC(37, 17, $027)
%YC(107, 3, $027)
%YC(150, 20, $002)
%YC(179, 4, $027)

.003
%YC(80, 17, $003)
%YC(158, 13, $003)
%YC(213, 12, $003)
%YC(264, 13, $003)
%YC(295, 23, $003)

.004
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.005
%YC(60, 13, $005)
%YC(194, 6, $02A)
%YC(248, 2, $02A)
%YC(84, 19, $02B)
%YC(25, 41, $02C)

.006
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.007
%YC(319, 7, $007)
%YC(231, 3, $007)
%YC(89, 2, $007)
%YC(71, 7, $028)
%YC(105, 20, $028)

.008
%YC(134, 10, $008)
%YC(17, 2, $008)
%YC(2, 388, $029)
%YC(28, 251, $029)
%YC(3, 234, $029)

.009
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.00A
%YC(26, 12, $00A)
%YC(91, 5, $00A)
%YC(49, 24, $030)
%YC(108, 23, $030)
%YC(154, 3, $030)

.00B
%YC(126, 14, $00B)
%YC(171, 20, $00B)
%YC(297, 19, $00B)
%YC(327, 19, $00B)
%YC(380, 16, $00B)

.00C
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.00D
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.00E
%YC(3, 380, $00E)
%YC(19, 333, $00E)
%YC(29, 289, $00E)
%YC(28, 35, $00E)
%YC(28, 58, $00E)

.00F
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.010
%YC(19, 36, $010)
%YC(34, 3, $010)
%YC(98, 2, $010)
%YC(121, 5, $010)
%YC(157, 38, $010)

.011
%YC(103, 23, $011)
%YC(126, 6, $011)
%YC(250, 26, $011)
%YC(321, 2, $011)
%YC(392, 19, $011)

.012
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.013
%YC(55, 14, $013)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.014
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.015
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.016
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.017
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.018
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.019
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01A
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01B
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01C
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01D
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01E
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.01F
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.020
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.021
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.022
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.023
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.024
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.101
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.102
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.103
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.104
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.105
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.106
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.107
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.108
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.109
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10A
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10B
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10C
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10D
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10E
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.10F
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.110
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.111
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.112
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.113
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.114
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.115
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.116
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.117
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.118
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.119
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11A
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11B
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11C
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11D
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11E
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.11F
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.120
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.121
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.122
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.123
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.124
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.125
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.126
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.127
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.128
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.129
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12A
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12B
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12C
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12D
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12E
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.12F
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.130
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.131
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.132
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.133
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.134
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.135
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.136
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.137
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.138
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.139
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.13A	; Mega level 2
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)
%YC(0, 0, $FFFF)

.13B	; Mega level 1
%YC(50, 12, $02E)
%YC(99, 7, $02E)
%YC(362, 22, $02E)
%YC(50, 17, $02F)
%YC(207, 3, $02F)








