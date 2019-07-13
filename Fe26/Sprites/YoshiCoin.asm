YoshiCoin:

	namespace YoshiCoin

	; $BE:	which Yoshi Coin this is (should be set when this sprite is spawned)


	MAIN:
		PHB : PHK : PLB

		LDA $BE,x
		PHX
		LDX !Translevel
		AND $40400B,x
		BEQ .Ok
		PLX
		LDA #$21 : STA $3200,x			; become a normal coin if this Yoshi Coin is already taken
		LDA #$08 : STA $3230,x
		LDA !ExtraBits,x
		AND.b #$08^$FF
		STA !ExtraBits,x
		JSL $07F7D2				; | > Reset sprite tables
		PLB
		RTL

	.Ok	PLX



		LDA $3330,x
		AND #$04 : PHA
		LDA $9E,x : PHA
		JSL !SpriteApplySpeed		; Apply speed with gravity
		PLA : STA $00
		PLA : BNE .ok
		EOR $3330,x
		AND #$04 : BEQ .ok
		LDA $3330,x
		AND #$04 : BEQ .ok
		LDA $00 : BMI .ok
		CMP #$08 : BCC .ok
		LSR A
		EOR #$FF
		STA $9E,x
		.ok


		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC .NoContact
		PHA
		STZ $3230,x
		JSR Glitter
		LDA #$1C : STA !SPC1
		LDA !YoshiCoinCount
		INC A
		STA !YoshiCoinCount
		LDA $BE,x
		PHX
		LDX !Translevel
		ORA $40400B,x
		STA $40400B,x
		PLX
		PLA
		LSR A : BCC .P2
	.P1	LDA !P1CoinIncrease
		CLC : ADC #$C8
		STA !P1CoinIncrease
		BRA .NoContact
	.P2	LDA !P2CoinIncrease
		CLC : ADC #$C8
		STA !P1CoinIncrease
		.NoContact

		LDA !GFX_status+$15 : STA !ClaimedGFX



		REP #$20
		LDA.w #ANIM : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_Long
		PLB
	INIT:
		RTL



	ANIM:
		dw $0008
		db $65,$00,$F3,$00
		db $65,$00,$03,$02


	Glitter:
		LDY #$03			; Set up loop

.Loop		LDA $77C0,y			;\
		BEQ .Spawn			; | Find empty smoke sprite slot
		DEY				; |
		BPL .Loop			;/
.Return		RTS

.Spawn		LDA #$05 : STA $77C0,y		; Smoke sprite to spawn
		LDA #$10 : STA $77CC,y		; Show glitter sprite for 16 frames
		LDA $3220,x : STA $77C8,y	; Spawn at sprite X
		LDA $3210,x			;\
		SEC : SBC #$05			; | Spawn at sprite Y - 8 pixels
		STA $77C4,y			;/
		RTS


	namespace off





