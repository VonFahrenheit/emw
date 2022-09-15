

ShieldBearer:

	namespace ShieldBearer


	!Temp = 0
	%def_anim(Shield_Idle, 1)
	%def_anim(Shield_Bonk, 13)
	%def_anim(Shield_Stagger, 4)




; extra bit will make this a back shield

	!ShieldSprite	= $BE		; index of sprite that shield is attached to
	!ShieldNum	= $3280		; sprite num of sprite that shield is attached to
	!ShieldExtra	= $3290		; extra bits of sprite that shield is attached to

	INIT:
		PHB : PHK : PLB

		JSR GetHitbox
		LDX #$0F
	-	CPX !SpriteIndex : BEQ +
		LDA !SpriteNum,x
		CMP #$2E : BEQ +
		LDA !SpriteStatus,x : BEQ +
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC +
		TXA
		LDX !SpriteIndex
		STA !ShieldSprite,x
		TAY
		LDA !SpriteNum,y : STA !ShieldNum,x
		LDA !ExtraBits,y
		AND #$08 : STA !ShieldExtra,x
		PLB
		RTL

	+	DEX : BPL -
		LDX !SpriteIndex
	.Despawn
		STZ !SpriteStatus,x
		LDA !SpriteID,x : TAX
		LDA #$00 : STA !SpriteLoadStatus,x
		LDX !SpriteIndex
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		LDA !SpriteStatus,x
		CMP #$08 : BEQ .CheckSprite
		CMP #$02 : BNE +
		LDA !SpriteID,x : TAX
		LDA #$00 : STA !SpriteLoadStatus,x
		LDX !SpriteIndex
	+	JMP .Graphics


	.CheckSprite
		LDY !ShieldSprite,x				; Y = attachment index
		LDA !SpriteNum,y				;\ has to match num
		CMP !ShieldNum,x : BNE .Kill			;/
		LDA !ExtraBits,y				;\
		AND #$08					; | has to match extra bit
		CMP !ShieldExtra,x : BNE .Kill			;/
		LDA !SpriteStatus,y : BEQ .Kill			; 00 = kill
		CMP #$08 : BEQ .Process				; 08 = normal
		CMP #$04 : BEQ .Kill				; 04 = kill
		CMP #$09 : BCS .Kill				; 09+ = kill
		JSR Attach					; otherwise, attach and wait
		JMP .Graphics

	.Kill	LDA #$02 : STA !SpriteStatus,x
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
		LDA !SpriteAnimIndex,x : BNE ..nocontact	; | stagger and contact effect when hit
		LDA #!Shield_Stagger : STA !SpriteAnimIndex,x	; |
		STZ !SpriteAnimTimer,x				; |
		..nocontact					;/

		PLA : STA !P2Hitbox2Shield			;\
		PLA : STA !P2Hitbox1Shield			; | restore p2 shield status
		PLA : STA !P2Hitbox2Shield-$80			; |
		PLA : STA !P2Hitbox1Shield-$80			;/



	.PlayerContact
		LDY !SpriteDir,x				;\ platform box
		LDA DATA_Wall,y : JSL OutputPlatformBox		;/
		LDA $EA						;\
		SEC : SBC #$06					; |
		STA $EA						; |
		BCS $02 : DEC $EB				; | extend hitbox 6px up
		LDA $EF						; |
		CLC : ADC #$06					; |
		STA $EF						;/
		JSL PlayerContact : BCC ..nocontact		;\
		LDY !SpriteDir,x				; |
		LSR A : BCC ..p2				; |
	..p1	PHA						; |
		LDY #$00 : JSR Interact				; | interact with players
		PLA						; |
	..p2	LSR A : BCC ..nocontact				; |
		LDY #$80 : JSR Interact				; |
		..nocontact					;/


	.SpriteContact
		LDX #$0F
		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !SpriteStatus,x
		CMP #$09 : BEQ ..thisone
		CMP #$0A : BNE ..next
		..thisone
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next
		LDA #$02 :  STA !SPC1
		LDY !SpriteIndex
		LDA !SpriteDir,y : STA !SpriteDir,x
		TAY
		LDA DATA_Force,y : STA !SpriteXSpeed,x
		LDY !SpriteIndex
		JSL SpriteContactGFX
		..next
		DEX : BPL ..loop
		LDX !SpriteIndex


	.Graphics
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
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
		LDA !SpriteXLo,y : STA $00
		LDA !SpriteXHi,y : STA $01
		LDA !SpriteYLo,y
		SEC : SBC $0F
		STA !SpriteYLo,x
		LDA !SpriteYHi,y
		SBC #$00
		STA !SpriteYHi,x
		LDA !SpriteDir,y				;\ flip direction if extra bit is set
		EOR $0E : STA !SpriteDir,x			;/
		TAY
		LDA $00
		CLC : ADC .Offset,y
		STA !SpriteXLo,x
		LDA $01
		ADC .Offset+2,y
		STA !SpriteXHi,x
		RTS

	.Offset
	db $18,$E8
	db $00,$FF



	GetHitbox:
		LDA !SpriteAnimIndex,x
		ASL #2 : TAY
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20
		LDY #$03
		LDA ($04),y
		LDY !SpriteDir,x : BNE +
		EOR #$FF : INC A
	+	STA $00
		STZ $01
		CMP #$00
		BPL $02 : DEC $01

		LDA !SpriteXLo,x
		CLC : ADC $00
		STA $E8
		LDA !SpriteXHi,x
		ADC $01
		STA $E9
		LDA !SpriteYLo,x
		SEC : SBC #$08
		STA $EA
		LDA !SpriteYHi,x
		SBC #$00
		STA $EB
		LDA #$10 : STA $EC : STZ $ED
		LDA #$1C : STA $EE : STZ $EF

		JSL OutputShieldBox

		RTS


	Interact:
		LDA !P2Blocked-$80,y
		AND #$04 : BNE .Side
		REP #$20
		LDA $EA
		CMP !P2YPosLo-$80,y
		SEP #$20
		BCC .Side

		.Top
		LDA !P2YSpeed-$80,y : BMI .Return
		JSL P2Bounce
		LDA #$02 : STA !SPC1
		.Return
		RTS

		.Side
		LDA !SpriteAnimIndex,x : BNE .NoBonk
		INC !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		.NoBonk

		CMP #!Shield_Bonk+4 : BCC .Return
		CMP #!Shield_Bonk+10 : BCS .Return
		LDA !SpriteDir,x : TAX
		LDA DATA_Force+2,x : STA !P2VectorX-$80,y
		LDA DATA_Acc,x : STA !P2VectorAccX-$80,y
		LDA #$10 : STA !P2VectorTimeX-$80,y
		LDA !P2XSpeed-$80,y
		CMP DATA_ClampMin,x : BCC .NoPush
		CMP DATA_ClampMax,x : BCS .NoPush
		LDA #$00 : STA !P2XSpeed-$80,y
		.NoPush

		LDX !SpriteIndex
		RTS



	namespace off





