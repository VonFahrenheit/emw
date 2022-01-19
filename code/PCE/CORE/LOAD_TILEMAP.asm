;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	$00:		player Xpos within screen
;	$02:		player Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		tile Xpos within screen
;	$08:		tilemap size
;	$0A:		player-based tile offset
;	$0B:		player-based palette offset
;	$0C:		copy of xflip flag from player direction
;	$0E:		0xFFFF if tilemap is x-flipped, otherwise 0x0000

; $0A/$0B are based on Player 2, so they are subtracted for Player 1

LOAD_TILEMAP:	STZ !BigRAM+$7E				; this reg ACTUALLY controls priority bits during this routine!
							; at the end, it's set to the number of bytes written to OAM

		REP #$20				;
		LDA !DizzyEffect			;\ check dizzy effect
		AND #$00FF : BEQ .NoDizzy		;/
		LDA !P2YPosLo : PHA			;\
		LDA !P2XPosLo				; |
		SEC : SBC $1A				; |
		AND #$00FF				; |
		LSR #3					; |
		ASL A					; |
		TAX					; | adjust height during dizzy effect
		LDA !DecompBuffer+$1040,x		; |
		AND #$01FF				; |
		CMP #$0100				; > handle negative
		BCC $03 : ORA #$FE00			; |
		SEC : SBC $1C				; |
		EOR #$FFFF : INC A			; |
		CLC : ADC !P2YPosLo			; |
		STA !P2YPosLo				; |
		JSL .NoSink				; |
		BRA .DoneSpecial			; |
		.NoDizzy				;/



		LDA !Level				; go down with screen in tinker room
		CMP #$0025 : BNE .NoSink
		LDY !Level+4 : BEQ .NoSink
		LDA !P2YPosLo : PHA
		LDA $6DF6
		AND #$00FF
		CLC : ADC !P2YPosLo
		STA !P2YPosLo
		JSL .NoSink
	.DoneSpecial
		REP #$20
		PLA : STA !P2YPosLo
		SEP #$20
		RTL


	.NoSink	SEP #$20



		LDA !P2Entrance : BEQ .NoMax		;\
		.MaxPrio				; | max prio during entrance animation
		LDY #$F0 : BRA +			; |
		.NoMax					;/


		LDA !P2Pipe : BNE .LoPrio
		LDA !P2SlantPipe
		CMP #$12 : BCC .HiPrio
	.LoPrio	LDY #$10
		LDA $3E
		AND #$07
		CMP #$02 : BNE +
		LDY #$20				; priority is different in mode 2
	+	STY !BigRAM+$7E

		.HiPrio
		STZ $0A					;\
		LDA #$0C : STA $0B			; |
		LDA !CurrentPlayer			; | set up tile/palette offsets for player
		BNE +					; |
		LDA #$20 : STA $0A			; |
		LDA #$0E : STA $0B			;/
	+	REP #$30
		LDA !P2Entrance
		AND #$00FF : BEQ ..entrancedone
		SEC : SBC #$0021
		BPL +
		JSR .EntranceSmoke
		LDA #$0000
	+	ASL #3
		LDY !P2Direction-1
		CPY #$0100 : BCC +
		..entrancedone
		EOR #$FFFF
		SEC
	+	ADC !P2XPosLo
		SEC : SBC $1A
		STA $00
		LDA !P2Entrance
		AND #$00FF
		SEC : SBC #$0021
		BPL $03 : LDA #$0000
		ASL #2
		EOR #$FFFF
		SEC : ADC !P2YPosLo
		SEC : SBC $1C
		STA $02

		LDA ($04)
		AND #$00FF
		STA $08
		INC $04
		INC $04
		STZ $0C
		STZ $0E
		LDA !P2Direction
		LSR A : BCC +
		LDA #$0040 : STA $0C
		DEC $0E
	+	LDA !OAMindex_p1 : TAX
		LDY #$0000
		SEP #$20


		.Loop
		LDA ($04),y
		AND #$01
		BEQ $02 : LDA #$80
		STA !BigRAM+$7F
		LDA ($04),y
		AND #$FE
		EOR $0C
		SEC : SBC !BigRAM+$7E
		SEC : SBC $0B				; subtract player palette offset
		STA !OAM_p1+$003,x
		REP #$20
		INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		BIT $0E : BPL +
		INC A					; add 1 for pixel perfect mirroring
		BIT !BigRAM+$7F-1 : BPL +
		CLC : ADC #$0008
	+	CLC : ADC $00
		CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY #3
		SEP #$20
		CPY $08 : BCC .Loop
		BRA .End

		.GoodX
		STA $06					; save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		INY #2
		SEP #$20
		CPY $08 : BCS .End
		JMP .Loop

		.GoodY
		SEP #$20
		STA !OAM_p1+$001,x
		LDA $06 : STA !OAM_p1+$000,x
		INY
		LDA ($04),y
		CMP #$40 : BCS +
		SEC : SBC $0A				; subtract player offset unless it's Leeway's slashy thing
	+	STA !OAM_p1+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		BIT !BigRAM+$7F : BMI $02 : ORA #$02
		STA !OAMhi_p1+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
		JMP .Loop

		.End
		TXA
		REP #$20
		SEC : SBC !OAMindex_p1
		SEP #$20
		STA !BigRAM+$7E
		REP #$20
		TXA : STA !OAMindex_p1
		SEP #$30
		RTL



	.EntranceSmoke
		PHP
		PEI ($04)
		PEI ($06)
		PEI ($08)
		PEI ($0A)
		PEI ($0C)
		PEI ($0E)
		SEP #$30
		LDA !P2Entrance
		CMP #$10 : BCC ..done
		CMP #$18 : BCC ..half
		..full
		LDA $14
		BRA ..finish
		..half
		LDA $14
		LSR A : BCC ..done
		..finish
		AND #$01
		BEQ $02 : LDA #$40
		SBC #$20
		STA !P2XSpeed
		JSL CORE_DASH_SMOKE
		..done
		STZ !P2XSpeed
		LDX !P2Character
		LDA.l ..anim,x : STA !P2ExternalAnim
		LDA #$02 : STA !P2ExternalAnimTimer
		REP #$20
		PLA : STA $0E
		PLA : STA $0C
		PLA : STA $0A
		PLA : STA $08
		PLA : STA $06
		PLA : STA $04
		PLP
		RTS

		..anim
		db $26
		db !Lui_Victory
		db !Kad_Victory
		db !Lee_Victory
		db $00
		db $00





