;============;
;INIT ROUTINE;
;============;

print "INIT ",pc

INITCODE:	PHB
		PHK
		PLB
		JSR START_SUB				; Handle sprite while offscreen
		JSR WHICH_COIN				; Figure out which coin this is
		STY $C2,x				; Store coin number
		PHX					; Push sprite index
		LDX $13BF				; X = translevel number
		LDA $7FA30B,x				; Get Yoshicoins table
		PLX					; X = sprite index
		AND BitTable,y				; Get bit
		BEQ .Return				; Return if Coin is not collected
		STZ $14C8,x				; If it is, erase this sprite..
		LDA #$02				;\
		STA $9C					; | ..and the yoshicoin
		LDY #$01				; |
		BRA GENERATE_BLOCK			;/

.Return		PLB
		RTL

GENERATE_BLOCK:	LDA $98					;\
		PHA					; |
		LDA $99					; |
		PHA					; | Preserve Mario's block values
		LDA $9A					; |
		PHA					; |
		LDA $9B					; |
		PHA					;/

.Loop		PHY					; Push loop count
		LDA $E4,x
		CLC : ADC #$08
		AND #$F0
		STA $9A
		LDA $14E0,x
		ADC #$00
		STA $9B
		LDA $14D4,x
		XBA
		LDA $D8,x
		AND #$F0
		REP #$20
		CLC : ADC $00
		STA $98
		PEI ($00)
		SEP #$20
		JSL $00BEB0				; Generate the block
		REP #$20
		PLA
		CLC : ADC #$0010
		STA $00
		SEP #$20
		PLY					; Pop loop count
		DEY					; Decrement this
		BPL .Loop				; Loop

.Return		PLA					;\
		STA $9B					; |
		PLA					; |
		STA $9A					; | Restore Mario's block values
		PLA					; |
		STA $99					; |
		PLA					; |
		STA $98					;/
		PLB
		RTL

BitTable:	db $01,$02,$04,$08,$10,$20,$40,$80	; All the bit values in hex (only the first 5 are used)

WHICH_COIN:	REP #$30
		LDA #$0008
		LDY #$0008
		JSL $938008
		LDX $15E9
		LDA [$05]
		XBA
		INC $07
		LDA [$05]
		BNE .Coin5
		XBA
		CMP #$2E
		BEQ .Coin24
		CMP #$2D
		BNE .Coin5

.Coin13		LDA #$08
		STA $00
		STZ $01
		LDA $7FAB10,x
		AND #$04
		LSR A
		TAY
		RTS

.Coin24		LDA #$F8
		STA $00
		LDA #$FF
		STA $01
		LDA $7FAB10,x
		AND #$04
		LSR A
		INC A
		TAY
		RTS

.Coin5		LDA #$18
		STA $00
		STZ $01
		LDY #$04
		RTS


print "MAIN ",pc

MAINCODE:	PHB
		PHK
		PLB
		PHX : PHX

		LDA $C2,x
		ASL A
		TAX
		REP #$30

		LDA #$0008
		LDY.w .Coords,x
		LDX $15E9
		JSL $938008
		PLX
		LDA [$05]
		CMP #$2E
		BNE .Collected
		INC $07
		LDA [$05]
		BNE .Collected
		PLX
		PLB
		RTL

.Collected	STZ $14C8,x
		LDY $C2,x				; Load index
		LDX $13BF
		LDA $7FA30B,x
		ORA BitTable,y				; Set indexed bit
		STA $7FA30B,x
		PLX
		PLB
		RTL

.Coords		dw $0018,$0008,$0018,$0008,$0028

;==============;
;SUB_OFF_SCREEN;
;==============;
START_SUB:		STZ $03
			LDA $15A0,x
			ORA $186C,x
			BEQ RETURN_35
			LDA $5B
			AND #$01
			BNE VERTICAL_LEVEL
			LDA $D8,x
			CLC
			ADC #$50
			LDA $14D4,x
			ADC #$00
			CMP #$02
			BPL ERASE_SPRITE
			LDA $167A,x
			AND #$04
			BNE RETURN_35
			LDA $13
			AND #$01
			ORA $03
			STA $01
			TAY
  			LDA $1A
			CLC
			ADC SPR_T14,y
			ROL $00
			CMP $E4,x
			PHP
			LDA $1B
			LSR $00
			ADC SPR_T15,y
			PLP
			SBC $14E0,x
			STA $00
			LSR $01
			BCC SPR_L31
			EOR #$80
			STA $00
SPR_L31:		LDA $00
			BPL RETURN_35
ERASE_SPRITE:		LDA $14C8,x
			CMP #$08
			BCC KILL_SPRITE
			LDY $161A,x
			CPY #$FF
			BEQ KILL_SPRITE
			LDA #$00
			STA $1938,y
KILL_SPRITE:		LDA #$00
			STA $14C8,x
			STA $7FAB10,x
RETURN_35:		RTS

VERTICAL_LEVEL:		LDA $167A,x
			AND #$04
			BNE RETURN_35
			LDA $13
			LSR A
			BCS RETURN_35
			LDA $E4,x
			CMP #$00
			LDA $14E0,x
			SBC #$00
			CMP #$02
			BCS ERASE_SPRITE
			LDA $13
			LSR A
			AND #$01
			STA $01
			TAY
			LDA $1C
			CLC
			ADC SPR_T12,y
			ROL $00
			CMP $D8,x
			PHP
			LDA $001D
			LSR $00
			ADC SPR_T13,y
			PLP
			SBC $14D4,x
			STA $00
			LDY $01
			BEQ SPR_L38
			EOR #$80
  			STA $00
SPR_L38:		LDA $00
			BPL RETURN_35
			BMI ERASE_SPRITE


SPR_T12:		db $40,$B0
SPR_T13:		db $01,$FF
SPR_T14:		db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
			db $30,$C0,$A0,$80,$A0,$40,$60,$B0
SPR_T15:		db $01,$FF,$01,$FF,$01,$FF,$01,$FF
			db $01,$FF,$01,$FF,$01,$00,$01,$FF