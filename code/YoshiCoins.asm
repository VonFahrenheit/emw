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

; if sublevel number is $FFFF, the Yoshi Coin does not exist


	YoshiCoins:
		STA $00				; 00 = INIT, 01 = MAIN
		PHA
		REP #$30
		LDA !Translevel : JSR .Run
		SEP #$20
		PLA : STA $00
		REP #$30
		LDA !MegaLevelID : JSR .Run
		SEP #$30
		RTS

		.Run
		AND #$00FF : BEQ ..fail		; fail if 0
		TAX				; X = level table index
		STA $0E				;\
		ASL #2				; |
		ADC $0E				; | x25
		STA $0E				; |
		ASL #2				; |
		ADC $0E				;/
		TAY				; Y = yoshi coin table index
		SEP #$20			; A 8-bit
		LDA !LevelTable1,x		; get coin status
		DEC $00 : BNE .INIT		; INIT
		JMP .MAIN			; MAIN
		..fail
		RTS

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
		SEP #$20
		RTS


		.MAIN
		STX $0E
		STY $0C
		LSR A
		BCS .Main2
		PHA
		JSR GetPointer : BCS +
		REP #$20
		CMP #$0025
		SEP #$20
		BNE +
		LDX $0E
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
		JSR GetPointer : BCS +
		REP #$20
		CMP #$0025
		SEP #$20
		BNE +
		LDX $0E
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
		JSR GetPointer : BCS +
		REP #$20
		CMP #$0025
		SEP #$20
		BNE +
		LDX $0E
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
		JSR GetPointer : BCS +
		REP #$20
		CMP #$0025
		SEP #$20
		BNE +
		LDX $0E
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
		JSR GetPointer : BCS +
		REP #$20
		CMP #$0025
		SEP #$20
		BNE +
		LDX $0E
		LDA !LevelTable1,x
		ORA #$10
		STA !LevelTable1,x
		+
		PLA

		.Return
		RTS


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

		LDA Data+$0,y				;\
		ASL #4					; | X position
		STA $02					;/
		XBA					;\
		AND #$00FF : TAX			; |
		LDA #$0000				; |
		CPX #$0000 : BEQ +			; | offset from X screen
	-	CLC : ADC !LevelHeight			; |
		DEX : BNE -				; |
		+					;/
		STA $00					;\
		LDA Data+$0,y				; | X part of index
		AND #$000F : TSB $00			;/
		LDA Data+$1,y				;\
		AND #$FFF0				; | add Y part of position
		CLC : ADC $00				;/
		TAX					;\
		SEP #$20				; |
		LDA $41C800,x : XBA			; | load map16 number
		LDA $40C800,x				; |
		REP #$20				;/
		PLP
		CLC
		RTS

		.NoCoin
		PLP
		SEC
		RTS


print "Yoshi Coin data at $", pc, "."
incsrc "level_data/YoshiCoinTable.asm"





