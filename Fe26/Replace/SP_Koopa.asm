

pushpc
org $018575
	JSL AutoKick		; > Source: JSL $01ACF9

org $018952
	JML BlueKicker		;\ Source: $3420,x : BEQ $5D ($018952)
	NOP			;/

org $018BEC
	JML KoopaGFX		; > Source: LDA $33D0,x : LSR A ($018BEC)

org $019A22
	db $A6,$A4,$A8,$A4

org $019A2A
	JML ShellGFX
warnpc $019A4D

org $0196F2
	JSL ExtraBitFix		; > Source: STA $3200,y : TYX

org $019808
	JML OAMfix		;\ Source: LDY $33B0,x : BNE $02 ($01980F) : LDA #$08
	NOP #3			;/

org $0199C4
	JSL CoinOwnerFix	;\ Source: LDY #$00 : LDA $78A7
	NOP			;/

org $01A082			; Mario carrying stuff routine
	JSL MariosShell		;\ Source: LDA #$0A : STA $3230,x
	NOP			;/
org $01AA9F			; Kick shell routine
	JSL MariosShell		;\ Source: LDA #$0A : STA $3230,x
	NOP			;/
pullpc




		!KoopaFrame	=	$35D0,x
		!KoopaWing	=	$35E0,x


	OAMfix:
		LDY $3230,x			;\ Only show different frame when carried
		CPY #$0B : BNE .NoTilt		;/
		LDA #$08			; > Special frame is 8

		.NoTilt
		LDY $33B0,x			; > Y = OAM index
		JML $01980F			; > Return


	MariosShell:
		STZ $34F0,x			; > Mario owns this shell
		LDA #$0A : STA $3230,x		; > Original code
		RTL				; > Return


	CoinOwnerFix:
		LDY #$00			; > Original code (prevent shatter?)
		LDA $78A7			; > Tile number check
		CMP #$1A : BEQ .Complicated	;\
		CMP #$1B : BEQ .Coin		; |
		CMP #$1C : BEQ .Coin		; |
		CMP #$22 : BEQ .Star2		; | These values can spawn a coin
		CMP #$23 : BEQ .Coin		; |
		CMP #$24 : BEQ .Coin		; |
		CMP #$2D : BEQ .StarBlock	;/
		BRA .Return			; > Return for any other value

		.Complicated
		LDA $9A				;\
		LSR #4				; |
		BEQ .Star2			; |
		CMP #$03 : BEQ .Star2		; | Spawns a star2 at these locations
		CMP #$06 : BEQ .Star2		; |
		CMP #$09 : BEQ .Star2		; |
		CMP #$0C : BEQ .Star2		; |
		CMP #$0F : BEQ .Star2		;/
		BRA .Return			; > Otherwise return

		.Star2
		LDA $7490 : BEQ .Coin		;\ If Mario doesn't have a star, this is just a coin
		BRA .Return			;/

		.StarBlock
		LDA $6DC0 : BEQ .Return		; > If Mario hasn't collected 30 coins, this is just a coin

		.Coin
		LDA $34F0,x : STA !CoinOwner	; > Set coin owner

		.Return
		LDA $78A7			;\ Reload value and return
		RTL				;/


		; 1A (star2, 1-up, or vine)
		; 1B (multiple coins)
		; 1C (one coin)
		; 22 (star2)
		; 23 (multiple coins)
		; 24 (one coin)
		; 2D (star block)



	ExtraBitFix:
		STA $3200,y			; > Original code, store sprite number
		LDA !ExtraBits,x		;\
		AND #$04			; |
		ORA !ExtraBits,y		; | Carry over extra bit to next sprite
		STA !ExtraBits,y		; |
		TYX				;/
		RTL				; > Return


	AutoKick:
		PHA				; > Push A
		LDA !ExtraBits,x		;\ Check extra bit
		AND #$04 : BNE .KickCheck	;/
		LDA $3200,x
		CMP #$04 : BCC .Return
		CMP #$0D : BCS .Return
		PLA
		LDA #$00
		RTL


		.KickCheck
		LDA $3200,x
		CMP #$04 : BEQ .KickRight
		CMP #$05 : BEQ .KickLeft
		CMP #$07 : BEQ .KickHoming


		.Return
		PLA				; > Pull A
		JML $01ACF9			; > Original code

		.KickRight
		LDA #$32			;\ Speed = 0x32
		BRA .Kick			;/

		.KickHoming
		JSR SUB_HORZ_POS		;\ Go towards a player
		TYA : BEQ .KickRight		;/

		.KickLeft
		LDA #$CE			; > Speed = 0xCE

		.Kick
		STA $AE,x			; > Store speed
		LDA #$0A : STA $3230,x		; > State = kicked
		BRA .Return			; > Return




	; 3420 is kick shell timer
	BlueKicker:
		LDA $3200,x
		CMP #$02 : BNE .Return
		LDA !ExtraBits,x
		AND #$04
		BEQ .Return
		LDA $3420,x : BEQ .0189B4
		CMP #$03 : BCS .018957

		LDA !P2Status-$80 : BNE +
		LDA !P2YPosLo-$80
		CLC : ADC #$18
		STA $00
		LDA !P2YPosHi-$80
		ADC #$00
		STA $01
		LDA $3210,x
		CMP $00
		LDA $3240,x
		SBC $01
		BCS +
		JSR SUB_HORZ_POS
		TYA
		CMP $3320,x : BEQ .018957

	+	LDA !P2Status : BNE +
		LDA !P2YPosLo
		CLC : ADC #$10
		STA $00
		LDA !P2YPosHi
		ADC #$00
		STA $01
		LDA $3210,x
		CMP $00
		LDA $3240,x
		SBC $01
		BCS +
		JSR SUB_HORZ_POS_2
		TYA
		CMP $3320,x : BEQ .018957
	+	INC $3420,x			; > Pause timer
		BRA .018957

		.Return
		LDA $3420,x
		BEQ .0189B4
.018957		JML $018957
.0189B4		JML $0189B4



	KoopaGFX:
		LDA $3200,x
		CMP #$04 : BCC .NotKoopa	;\ Sprites 0x04-0x0C are koopas
		CMP #$0D : BCC .Koopa		;/

		.NotKoopa
		LDA $33D0,x
		LSR A
		JML $018BF0

		.Koopa
		LDA $33D0,x
		EOR #$01
		LSR A
		LDA $3210,x : PHA
		SBC #$0F
		STA $3210,x
		LDA $3240,x : PHA
		SBC #$00
		STA $3240,x

		JSR .Main
		LDA $0F
		BEQ $03 : JMP .BodyDone

		LDA $33D0,x : BEQ .stand_f
		CMP #$01 : BEQ .walk_f

		.turn_f
		LDA #$C6
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA #$E6
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$106,y
		LDA !KoopaFrame			;\
		AND #$0F			; |
		CMP #$02 : BNE $03 : JMP +	; |
		ASL #4				; | Store frame
		ORA #$02			; |
		STA !KoopaFrame			;/
		JMP +

		.stand_f
		LDA #$C0
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA #$E0
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$106,y
		LDA !KoopaFrame			;\
		AND #$0F : BEQ +		; |
		ASL #4				; | Store frame
		STA !KoopaFrame			;/
		LDA #$FF
		BRA +

		.walk_f
		LDA !KoopaFrame
		AND #$F2
		CMP #$10 : BEQ .walk_alt
		CMP #$02 : BEQ .walk_alt
		LDA #$C2
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA #$E2
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$106,y
		LDA !KoopaFrame			;\
		AND #$0F			; |
		CMP #$01 : BEQ +		; |
		ASL #4				; | Store frame
		ORA #$01			; |
		STA !KoopaFrame			;/
		LDA #$FF
		BRA +

		.walk_alt
		LDA #$C4
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA #$E4
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$106,y
		LDA !KoopaFrame			;\
		AND #$0F			; |
		CMP #$03 : BEQ +		; |
		ASL #4				; | Store frame
		ORA #$03			; |
		STA !KoopaFrame			;/
		LDA #$FF

	+	BPL +				;\
		LDA !KoopaWing			; |
		INC A				; | Cycle between wing frames
		CMP #$04			; |
		BNE $02 : LDA #$00		; |
		STA !KoopaWing			;/


	+	LDA $01
		STA !OAM+$101,y
		CLC : ADC #$10
		STA !OAM+$105,y
		LDA $00
		STA !OAM+$100,y
		STA !OAM+$104,y

		JSR .Prop
		STA !OAM+$103,y
		STA !OAM+$107,y
		JSR .HiTable
		STA !OAMhi+$40,y
		STA !OAMhi+$41,y
		LDA $3490,x : BEQ .BodyDone
		PHX
		LSR A : BCC +
		PHA
		LDA #$01 : STA !OAMhi+$40,y
		TYA
		ASL #2
		TAX
		LDA #$80 : STA !OAM+$100,x
		PLA
	+	LSR A : BCC +
		LDA #$01 : STA !OAMhi+$40,y
		TYA
		ASL #2
		TAX
		LDA #$80 : STA !OAM+$104,x
	+	PLX

		.BodyDone
		PLA : STA $3240,x
		PLA : STA $3210,x
		LDA $3200,x
		CMP #$08 : BCS $03 : JMP .Done

		.Wings
		LDY #$00
		LDA $3330,x
		AND #$04
		BNE +
		LDY !KoopaWing
	+	STY $02
		LDA $3490,x : BNE .Done
		LDA $3220,x : STA $00
		LDA $3250,x : STA $04
		LDA $3210,x : STA $01
		LDA $33D0,x
		LSR A
		BCS $02 : INC $01
		LDY $33B0,x
		PHX
		LDA $3320,x
		BEQ $02 : LDA #$04
		CLC : ADC $02
		TAX
		LDA $00
		CLC : ADC.l .WingXlo,x
		STA $00
		LDA $04
		ADC.l .WingXhi,x
		PHA
		LDA $00
		SEC : SBC $1A
		STA !OAM+$100,y
		PLA
		SBC $1B
		BNE +
		LDA $01
		SEC : SBC $1C
		CLC : ADC.l .WingY,x
		STA !OAM+$101,y
		LDA.l .WingTile,x
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA !OAM+$107,y			;\ Same prop as koopa
		STA !OAM+$103,y			;/
		TYA
		LSR #2
		TAY
		LDA #$02
		STA !OAMhi+$40,y
	+	PLX

		.Done
		JML $018C13

	.WingXlo
		db $F7,$F8,$02,$F8,$09,$08,$FE,$08
	.WingXhi
		db $FF,$FF,$00,$FF,$00,$00,$FF,$00
	.WingY
		db $F9,$FB,$FB,$FB,$F9,$FB,$FB,$FB
	.WingTile
		db $AA,$AC,$AE,$AC,$AA,$AC,$AE,$AC


		.Main
		STZ $0F		; flag that shows if sprite should be drawn
		STZ $3490,x
		STZ $3350,x
		LDA $3220,x
		CMP $1A
		LDA $3250,x
		SBC $1B
		BEQ $03 : INC $3350,x
		LDA $3250,x
		XBA
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC #$0040
		CMP #$0180
		SEP #$20
		ROL A
		AND #$01
		STA $3380,x
		BEQ .OnScreen
		INC $0F

		.OnScreen
		LDY #$00
		LDA $3230,x
		CMP #$09 : BCS +
		LDA $34B0,x
		AND #$20
		BEQ $01 : INY
	-
	+	LDA $3210,x
		CLC : ADC #$20
		PHP
		CMP $1C
		ROL $00
		PLP
		LDA $3240,x
		ADC #$00
		LSR $00
		SBC $1D
		BEQ +
		LDA $3490,x
		ORA $A363,y
		STA $3490,x
	+	DEY
		BPL -

		LDA $3490,x
		BEQ $02 : INC $0F

		LDA $3220,x
		SEC : SBC $1A
		STA $00
		LDA $3210,x
		SEC : SBC $1C
		STA $01

		LDA $3320,x : STA $02
		LDA $33B0,x
		CLC : ADC #$04
		TAY
		RTS


		.Prop
		LDA $3320,x
		LSR A
		PHP
		LDA #$00
		BIT !GFX_status+$01
		BPL $02 : LDA #$01
		PLP
		EOR $33C0,x
		BCS $02 : ORA #$40
		ORA $64
		XBA
		LDA $3410,x : BEQ +		; ignore hi priority bit if behind scenery flag is set
		XBA
		AND #$DF
		RTS
	+	XBA
		RTS


		.HiTable
		TYA
		LSR #2
		TAY
		LDA #$02
		ORA $3350,x
		RTS


	ShellGFX:
		LDA $33D0,x
		EOR #$01
		LSR A
		LDA $3210,x : PHA
		SBC #$0F
		STA $3210,x
		LDA $3240,x : PHA
		SBC #$00
		STA $3240,x
		JSR KoopaGFX_Main
		LDA $0F : BNE .Done

		LDA $00 : STA !OAM+$100,y
		LDA $01
		CLC : ADC #$10
		STA !OAM+$101,y
		JSR KoopaGFX_Prop
		STA !OAM+$103,y

		PHX
		LDA $14
		LSR #2
		AND #$03
		TAX
		LDA.w $9A22,x
		CLC : ADC !GFX_status+$01
		CLC : ADC !GFX_status+$01
		STA !OAM+$102,y
		LDA.w $9A26,x
		EOR !OAM+$103,y
		STA !OAM+$103,y
		PLX

		JSR KoopaGFX_HiTable
		STA !OAMhi+$40,y

		.Done
		PLA : STA $3240,x
		PLA : STA $3210,x
		JML $019A4D



