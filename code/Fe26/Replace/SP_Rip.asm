

	pushpc
	org $02C05C
		JML GoldenRip		;\ org: JSR $D4FA : LDA $0F
	NormalRip:
		LDA #$60		; followed by sight box code, which i overwrite to increase co-op compatibility
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .Return
		BRA .Enrage
	warnpc $02C072
	org $02C072
		.Enrage
	org $02C07B
		.Return
	org $02C08A
		JSL ChasingRip		; org: LDA $13 : AND #$01
	pullpc
	GoldenRip:
		LDA !ExtraBits,x
		AND #$04 : BNE .Golden

		.Normal
		LDA $3220,x
		SEC : SBC #$30
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$30
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		JML NormalRip

		.Golden
		LDA !ExtraBits,x : BMI ..main
		..init
		ORA #$80 : STA !ExtraBits,x	; set main / skip subsequent inits
		LDA !P1Coins : STA $35A0,x	; coin memory 1
		LDA !P2Coins : STA $35B0,x	; coin memory 2
		LDA $33C0,x			;\
		AND #$F1			; | palette = yellow
		ORA #$04			; |
		STA $33C0,x			;/
		LDA !SpriteTweaker3,x		;\
		ORA #$30			; |
		STA !SpriteTweaker3,x		; | disable kill methods
		LDA !SpriteTweaker4,x		; |
		ORA #$06			; | > process while offscreen
		STA !SpriteTweaker4,x		;/
		..main
		LDA #$02			;\
		STA $32E0,x			; | don't interact with players
		STA $35F0,x			;/
		JSR .Power
		LDA $35A0,x
		CMP !P1Coins : BNE .Rage
		LDA $35B0,x
		CMP !P2Coins : BEQ .Calm
	.Rage	LDA #$FF : STA $33F0,x		; golden can not respawn after waking up
		JML NormalRip_Enrage
	.Calm	JML NormalRip_Return

		.Power
		JSR MakeGlitter			; spawn glitter
		JSL !GetSpriteClipping04	;\ destroy fireballs upon contact
		JMP FireballContact_Destroy	;/

	ChasingRip:
		LDA !ExtraBits,x
		AND #$04 : BEQ .Return
		JSR GoldenRip_Power
		LDA $AE,x : PHA			;\
		LDA $9E,x : PHA			; |
		LDA !Difficulty			; |
		AND #$03			; |
		INC A				; |
		CMP #$03			; |
		BCC $02 : LDA #$03		; | double Y speed
		STA $0E				; | X speed increase depends on difficulty
		LDA $14				; |
		AND #$03			; |
		CMP $14 : BCS .Both		; |
	.JustY	STZ $AE,x			; |
	.Both	JSL !SpriteApplySpeed		; |
		PLA : STA $9E,x			;/
		PLA : STA $AE,x
	.Return	LDA $13
		AND #$01
		RTL
