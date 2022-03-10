

pushpc
org $01C6A1
	JML Gold		; Source: CMP #$76 : BNE $0D ($01C6B2)
org $01C616
	db $04,$08,$04,$08	; fix star palettes
org $01C6C9
	BRA $01 : NOP		; ORA $33C0,x

	org $01C538
	GivePowerup:
		STZ $3230,x					; despawn sprite
		LDY #$0A : STY !SPC1				;\ powerup SFX
		LDY #$0B : STY !SPC4				;/
		CMP #$76 : BEQ .Star				; star
		CMP #$78 : BEQ .GoldShroom			; gold shroom
		CMP #$7F : BEQ .GoldShroom			; winged gold shroom

		.Mushroom					;\
		PHX						; |
		LDA !CurrentMario : BEQ ..return		; |
		DEC A						; |
		LSR A						; |
		ROR A						; |
		TAX						; | flash white + heal
		LDA #$14 : STA !P2FlashPal-$80,x		; |
		LDA !P2TempHP-$80,x : BNE ..return		; > no heal with temp HP up
		LDA !P2HP-$80,x					; |
		CLC : ADC #$04					; |
		CMP !P2MaxHP-$80,x : BCC +			; |
		LDA !P2MaxHP-$80,x				; |
	+	STA !P2HP-$80,x					; |
		..return					; |
		PLX						; |
		RTS						;/

		.Star						;\ set star timer
		LDA #$FF : STA !StarTimer			;/
		PHX						;\
		LDA !CurrentMario : BEQ ..return		; |
		DEC A						; |
		LSR A						; |
		ROR A						; | flash white
		TAX						; |
		LDA #$14 : STA !P2FlashPal-$80,x		; |
		..return					; |
		PLX						; |
		RTS						;/

		.GoldShroom					;\

		REP #$20
		STZ $00
		STZ $04
		SEP #$20
		LDA.w #!prt_text100 : JSL SpawnParticle

		STZ !SPC1					; | no sfx
		STZ !SPC4					;/
		LDA !StoryFlags+$02				;\
		AND #$02 : BNE ..nomsg				; |
		ORA #$02 : STA !StoryFlags+$02			; |
		REP #$20					; | first time that a gold shroom is collected, a message is displayed
		LDA.w #!MSG_FirstGoldShroom : STA !MsgTrigger	; |
		SEP #$20					; |
		..nomsg						;/
		PHX						;\
		LDA !SpriteXSpeed,x : BNE ..nomem		; > don't use index mem if moving
		LDA !HeaderItemMem				; |
		CMP #$03 : BCS ..nomem				; |
		JSL GetItemMem					; |
		REP #$10					; |
		LDX $00						; | set item mem
		LDA $02						; |
		ORA !ItemMem0,x					; |
		STA !ItemMem0,x					; |
		SEP #$10					; |
		..nomem						;/
		LDA !CurrentMario : BEQ ..return		;\
		DEC A						; |
		TAX						; |
		LDA !P1CoinIncrease,x				; |
		CLC : ADC #$64					; |
		STA !P1CoinIncrease,x				; |
		LDA !CurrentMario				; |
		DEC A						; | 100 coins + full heal + flash gold
		LSR A						; |
		ROR A						; |
		TAX						; |
		LDA !P2MaxHP-$80,x : STA !P2HP-$80,x		; |
		LDA #$B4 : STA !P2FlashPal-$80,x		; |
		..return					; |
		PLX						; |
		RTS						;/


	warnpc $01C609
pullpc




	Gold:
		CMP #$78 : BEQ .GoldShroom
		CMP #$7F : BEQ .GoldShroom
		CMP #$76 : BEQ .Star

		.NoFlash
		JML $01C6B2

		.Star
		LDA $14
		AND #$02
		ORA #$04
		ORA $64
		STA !OAM+$103,y
		BRA .Flash

		.GoldShroom
		LDA !ExtraBits,x : BMI ..main
		..init
		ORA #$80 : STA !ExtraBits,x
		PEI ($00)
		LDA $33F0,x
		CMP #$FF : BEQ ..success
		JSL GetItemMem : BNE ..alreadyeaten
		..success
		PLA : STA $00
		PLA : STA $01
		BRA ..main
		..alreadyeaten
		PLA : PLA
		STZ $3230,x
		LDA #$F0 : STA $01
		..main
		LDA #$04
		ORA $64
		STA !OAM+$103,y

		.Flash
		PEI ($00)
		PHY
		JSL MakeGlitter
		PLY
		PLA
		STA $00
		STA !OAM+$100,y
		PLA
		STA $01
		STA !OAM+$101,y
		STZ $33C0,x
		JML $01C6D1

