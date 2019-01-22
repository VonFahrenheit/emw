;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	$00:		sprite Xpos within screen
;	$02:		sprite Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		tile Xpos within screen
;	$08:		tilemap size
;	$0A:		player-based tile offset
;	$0B:		player-based palette offset
;	$0C:		copy of xflip flag from tilemap
;	$0E:		0xFFFF if tile is x-flipped, otherwise 0x0000

; $0A/$0B are based on Player 2, so they are subtracted for Player 1

LOAD_TILEMAP:	STZ !P2TilesUsed
		LDA !P2Pipe : BNE .LoPrio
		LDA !P2SlantPipe
		CMP #$12 : BCC .HiPrio
	.LoPrio	LDA #$10 : STA !P2TilesUsed

		.HiPrio
		STZ $0A			;\
		LDA #$0C : STA $0B	; |
		LDA !CurrentPlayer	; | Set up tile/palette offsets for player
		BNE +			; |
		LDA #$20 : STA $0A	; |
		LDA #$0E : STA $0B	;/
	+	REP #$20
		LDA !P2XPosLo
		SEC : SBC $1A
		STA $00
		LDA !P2YPosLo
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		LDA $04
		INC #2
		STA $04
		STZ $0C
		LDA !P2Direction
		LSR A
		BCC +
		LDA #$0040
		STA $0C
	+	SEP #$20
		LDX #$00
		LDA !CurrentPlayer	;\
		EOR #$01		; |
		INC A			; | Mario is prioritized for lo OAM location
		CMP !CurrentMario	; |
		BEQ +			;/
		LDA !CurrentPlayer	;\
		BNE +			; | P1 gets the spot at the end of the $6200 block
		LDA #$80		; | P2 gets the spot at the start of the $6300 block
		SEC : SBC $08		; |
		TAX			;/
	+	LDY #$00

.Loop		LDA ($04),y
		EOR $0C
		SEC : SBC !P2TilesUsed
		SEC : SBC $0B		; Subtract player palette offset
		STA !OAM+$83,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodX		STA $06			; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodY		SEP #$20
		STA !OAM+$81,x
		LDA $06
		STA !OAM+$80,x
		INY
		LDA ($04),y
		BMI +
		SEC : SBC $0A		; Subtract player offset unless it's Leeway's slashy thing
	+	STA !OAM+$82,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$20,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		INX #4
		TXA
		SEC : SBC #$80
		STA !P2TilesUsed
		RTS







