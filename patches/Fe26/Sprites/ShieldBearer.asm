ShieldBearer:

	namespace ShieldBearer


; extra bit will make this a back shield

	!ShieldSprite	= $BE,x		; index of sprite that shield is attached to


	INIT:
		PHB : PHK : PLB

		JSR GetHitbox
		LDX #$0F
	-	CPX !SpriteIndex : BEQ +
		LDA !NewSpriteNum,x
		CMP #$2E : BEQ +
		LDA $3230,x : BEQ +
		JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC +
		TXA
		LDX !SpriteIndex
		STA !ShieldSprite
		PLB
		RTL

	+	DEX : BPL -
		LDX !SpriteIndex
	.Despawn
		STZ $3230,x
		LDA $33F0,x : TAX
		LDA #$00 : STA $418A00,x
		LDX !SpriteIndex
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ .CheckSprite
		JMP .Graphics

	.CheckSprite
		LDY !ShieldSprite
		LDA $3230,y : BEQ INIT_Despawn		; 00 = despawn
		CMP #$08 : BEQ .Process			; 08 = normal
		CMP #$04 : BEQ .Kill			; 04 = kill
		CMP #$09 : BCS .Kill			; 09+ = kill
		JSR Attach				; otherwise, attach and wait
		JMP .Graphics

	.Kill	LDA #$02 : STA $3230,x
		JMP .Graphics

	.Process
		JSR Attach
		JSR GetHitbox
		JSL FireballContact_Destroy_Long

	.PlayerContact
		SEC : JSL !PlayerClipping
		BCC ..NoContact
		LDY $3320,x
		LSR A : BCC ..P2
	..P1	PHA
		LDA #$00
		LDY #$00
		JSR Interact
		PLA
	..P2	LSR A : BCC ..NoContact
		LDA #$00
		LDY #$80
		JSR Interact
		..NoContact

	.AttackContact
		JSL P2Attack_Long
		BCC ..NoAttack
		LDY $3320,x
		LSR A : BCC ..P2
	..P1	PHA
		LDA #$02
		LDY #$00
		JSR Interact
		PLA
	..P2	LSR A : BCC ..NoAttack
		LDA #$02
		LDY #$80
		JSR Interact
		..NoAttack

	.SpriteContact
		LDX #$0F
	-	CPX !SpriteIndex : BEQ +
		LDA $3230,x
		CMP #$09 : BEQ ++
		CMP #$0A : BNE +
	++	JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC +
		LDA #$02 :  STA !SPC1
		LDY !SpriteIndex
		LDA $3320,y : STA $3320,x
		TAY
		LDA Interact_Force+2,y : STA $AE,x
		LDY !SpriteIndex
		JSL SpriteContactGFX_Long
	+	DEX : BPL -
		..NoSprite
		LDX !SpriteIndex


	.Graphics
		LDA.b #.TM : STA $04
		LDA.b #.TM>>8 : STA $05
		JSL LOAD_PSUEDO_DYNAMIC_Long


		PLB
		RTL


	.TM
	dw $0008
	db $30,$00,$F8,$00
	db $30,$00,$08,$02


	Attach:
	; 00 +0
	; 01 +1
	; 02 +0
	; 03 -1


; 2 - t
; if t = 2, t = 0
		LDA $14
		LSR #4
		AND #$03
		SEC : SBC #$02
		EOR #$FF : INC A
		CMP #$02
		BNE $02 : LDA #$00
		CLC : ADC #$08
		STA $0F

		STZ $0E
		LDA !ExtraBits,x
		AND #$04
		BEQ $02 : INC $0E

		LDA.w $AE,y : STA $AE,x
		LDA $3220,y : STA $00
		LDA $3250,y : STA $01
		LDA $3210,y
		SEC : SBC $0F
		STA $3210,x
		LDA $3240,y
		SBC #$00
		STA $3240,x
		LDA $3320,y
		EOR $0E				; flip direction if extra bit is set
		STA $3320,x
		TAY
		LDA $00
		CLC : ADC .Offset,y
		STA $3220,x
		LDA $01
		ADC .Offset+2,y
		STA $3250,x
		RTS

	.Offset
	db $18,$E8
	db $00,$FF


	Interact:
		PHY
		ORA $3320,x
		TAY
		CPY #$02 : BCS +
		PHY
		TXY
		JSL SpriteContactGFX_Long
		LDA #$02 : STA !SPC1
		PLY
	+	LDA .Force,y
		CLC : ADC $AE,x
		PLY
		STA !P2VectorX-$80,y
		LDA #$10 : STA !P2VectorTimeX-$80,y
		LDA #$00 : STA !P2VectorAccX-$80,y
		LDA !P2Character-$80,y : BNE .PCE

	.Mario
		STZ !MarioXSpeed
		LDA !MarioBlocked
		AND #$04 : BNE .Return
		LDA #$B8 : STA !MarioYSpeed
	.Return	RTS

	.PCE
		LDA #$00 : STA !P2XSpeed-$80,y
		LDA !P2Blocked-$80,y
		AND #$04 : BNE .Return
		LDA #$B8 : STA !P2YSpeed-$80,y
		RTS


	.Force
	db $10,$F0
	db $40,$C0


	GetHitbox:
		LDA $3220,x : STA $04
		LDA $3250,x : STA $0A
		LDA $3210,x
		SEC : SBC #$08
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$10 : STA $06
		LDA #$1C : STA $07
		RTS


	namespace off





