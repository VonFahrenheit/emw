ShieldBearer:

	namespace ShieldBearer


	!Temp = 0
	%def_anim(Shield_Idle, 1)
	%def_anim(Shield_Bonk, 13)
	%def_anim(Shield_Stagger, 4)




; extra bit will make this a back shield

	!ShieldSprite	= $BE,x		; index of sprite that shield is attached to
	!ShieldNum1	= $3280,x	; sprite num of sprite that shield is attached to
	!ShieldNum2	= $3290,x	; custom sprite num of sprite that shield is attached to


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
		TAY
		LDA $3200,y : STA !ShieldNum1
		LDA !NewSpriteNum,y : STA !ShieldNum2
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
		LDY !ShieldSprite			; Y = attachment index
		LDA $3200,y				;\ has to match num 1
		CMP !ShieldNum1 : BNE .Kill		;/
		LDA !NewSpriteNum,y			;\ has to match num 2
		CMP !ShieldNum2 : BNE .Kill		;/
		LDA $3230,y : BEQ .Kill			; 00 = kill
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
		JSL FireballContact_Destroy


	.AttackContact
		LDA !P2Hitbox1Shield-$80 : PHA			;\
		LDA !P2Hitbox2Shield-$80 : PHA			; | preserve p2 shield status
		LDA !P2Hitbox1Shield : PHA			; |
		LDA !P2Hitbox2Shield : PHA			;/
		STZ !P2Hitbox1Shield-$80			;\
		STZ !P2Hitbox2Shield-$80			; | ignore shield status
		STZ !P2Hitbox1Shield				; |
		STZ !P2Hitbox2Shield				;/

		JSL P2Attack : BCC ..nocontact			;\
		JSL P2HitContactGFX				; |
		LDA #$02 : STA !SPC1				; |
		LDA !SpriteAnimIndex : BNE ..nocontact		; | stagger and contact effect when hit
		LDA #!Shield_Stagger : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		..nocontact					;/

		PLA : STA !P2Hitbox2Shield			;\
		PLA : STA !P2Hitbox1Shield			; | restore p2 shield status
		PLA : STA !P2Hitbox2Shield-$80			; |
		PLA : STA !P2Hitbox1Shield-$80			;/



	.PlayerContact
		LDY $3320,x					;\ platform box
		LDA DATA_Wall,y : JSL OutputPlatformBox		;/
		LDA $05						;\
		SEC : SBC #$06					; |
		STA $05						; |
		BCS $02 : DEC $0B				; | extend hitbox 6px up
		LDA $07						; |
		CLC : ADC #$06					; |
		STA $07						;/
		SEC : JSL !PlayerClipping : BCC ..nocontact	;\
		LDY $3320,x					; |
		LSR A : BCC ..p2				; |
	..p1	PHA						; |
		LDY #$00 : JSR Interact				; | interact with players
		PLA						; |
	..p2	LSR A : BCC ..nocontact				; |
		LDY #$80 : JSR Interact				; |
		..nocontact					;/


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
		LDA DATA_Force,y : STA !SpriteXSpeed,x
		LDY !SpriteIndex
		JSL SpriteContactGFX
	+	DEX : BPL -
		..NoSprite
		LDX !SpriteIndex


	.Graphics
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
		RTL



	DATA:
		.Force
		db $40,$C0
		db $20,$E0

		.Acc
		db $FE,$02

		.ClampMin
		db $80,$00
		.ClampMax
		db $FF,$80

		.Wall
		db $02,$01




	ANIM:
	; idle
		dw .IdleTM : db $FF,!Shield_Idle
	; bonk
		dw .BonkBack1 : db $02,!Shield_Bonk+1
		dw .BonkBack2 : db $03,!Shield_Bonk+2
		dw .BonkBack3 : db $03,!Shield_Bonk+3
		dw .BonkBack4 : db $09,!Shield_Bonk+4
		dw .BonkBack2 : db $01,!Shield_Bonk+5
		dw .BonkBack1 : db $01,!Shield_Bonk+6
		dw .BonkFront1 : db $01,!Shield_Bonk+7
		dw .BonkFront2 : db $01,!Shield_Bonk+8
		dw .BonkFront3 : db $01,!Shield_Bonk+9
		dw .BonkFront4 : db $03,!Shield_Bonk+10
		dw .BonkFront3 : db $02,!Shield_Bonk+11
		dw .BonkFront2 : db $02,!Shield_Bonk+12
		dw .BonkFront1 : db $03,!Shield_Idle
	; stagger
		dw .BonkBack4 : db $02,!Shield_Stagger+1
		dw .BonkBack3 : db $02,!Shield_Stagger+2
		dw .BonkBack2 : db $02,!Shield_Stagger+3
		dw .BonkBack1 : db $02,!Shield_Idle


	.IdleTM
		dw $0008
		db $32,$00,$F8,$00
		db $32,$00,$08,$02


	.BonkBack1
		dw $0008
		db $32,$01,$F8,$00
		db $32,$01,$08,$02
	.BonkBack2
		dw $0008
		db $32,$02,$F8,$00
		db $32,$02,$08,$02
	.BonkBack3
		dw $0008
		db $32,$03,$F8,$00
		db $32,$03,$08,$02
	.BonkBack4
		dw $0008
		db $32,$04,$F8,$00
		db $32,$04,$08,$02

	.BonkFront1
		dw $0008
		db $32,$FF,$F8,$00
		db $32,$FF,$08,$02
	.BonkFront2
		dw $0008
		db $32,$FE,$F8,$00
		db $32,$FE,$08,$02
	.BonkFront3
		dw $0008
		db $32,$FD,$F8,$00
		db $32,$FD,$08,$02
	.BonkFront4
		dw $0008
		db $32,$FC,$F8,$00
		db $32,$FC,$08,$02





	; 00 +0
	; 01 +1
	; 02 +0
	; 03 -1
	; 2 - t
	; if t = 2, t = 0
	Attach:
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

		LDA.w !SpriteXSpeed,y : STA !SpriteXSpeed,x
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



	GetHitbox:
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		LDY #$03
		LDA ($04),y
		LDY $3320,x : BNE +
		EOR #$FF : INC A
	+	STA $00
		STZ $01
		CMP #$00
		BPL $02 : DEC $01

		LDA $3220,x
		CLC : ADC $00
		STA $04
		LDA $3250,x
		ADC $01
		STA $0A
		LDA $3210,x
		SEC : SBC #$08
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$10 : STA $06
		LDA #$1C : STA $07

		JSL OutputShieldBox

		RTS


	Interact:
		LDA !P2Blocked-$80,y
		AND #$04 : BNE .Side
		LDA $0B : XBA
		LDA $05
		REP #$20
		CMP !P2YPosLo-$80,y
		SEP #$20
		BCC .Side

		.Top
		LDA !P2YSpeed-$80,y : BMI .Return
		JSL P2Bounce
		LDA #$02 : STA !SPC1
	.Return	RTS

		.Side
		LDA !SpriteAnimIndex : BNE .NoBonk
		INC !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoBonk

		CMP #!Shield_Bonk+4 : BCC .Return
		CMP #!Shield_Bonk+10 : BCS .Return
		LDA $3320,x : TAX
		LDA DATA_Force+2,x : STA !P2VectorX-$80,y
		LDA DATA_Acc,x : STA !P2VectorAccX-$80,y
		LDA #$10 : STA !P2VectorTimeX-$80,y
		LDA !P2XSpeed-$80,y
		CMP DATA_ClampMin,x : BCC .NoPush
		CMP DATA_ClampMax,x : BCS .NoPush
		LDA #$00 : STA !P2XSpeed-$80,y
		LDA !P2Character-$80,y : BNE .NoPush
		STZ !MarioXSpeed
		.NoPush

		LDX !SpriteIndex
		RTS



	namespace off





