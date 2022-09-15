

	!MontyMoleState		= $BE


	INIT:
		.InitialAnim
		LDA !SpriteNum,x
		CMP #$4D : BEQ ..done
		LDA #$01 : STA !SpriteAnimIndex,x
		..done

		RTS


	MAIN:
		LDA !SpriteStatus,x
		CMP #$08 : BEQ .Process
		JMP GRAPHICS
		.Process


	PHYSICS:
		PEA .Return-1
		LDA !MontyMoleState,x
		ASL A
		CMP.b #.StatePtr_end-.StatePtr
		BCC $02 : LDA #$00
		TAX
		JMP (.StatePtr,x)

		.StatePtr
		dw .Hidden
		dw .DigOut
		dw .JumpOut
		dw .Chase
		..end


	.Hidden
		LDX !SpriteIndex
		LDA #$1D : JSL GetSpriteClippingE8_A
		JSL PlayerContact : BCC ..return
		INC !MontyMoleState,x
		LDY #$20
		LDA !ExtraBits,x
		AND #$04
		BEQ $02 : LDY #$C0
		TYA : STA $32D0,x
		..return
		RTS

	.DigOut
		LDX !SpriteIndex
		LDA !SpriteAnimTimer,x
		AND #$08
		BEQ $02 : LDA #$01
		STA !SpriteDir,x
		LDA $32D0,x : BNE ..return
		INC !MontyMoleState,x
		LDA #$C0 : STA !SpriteYSpeed,x
		LDA #$02 : STA !SpriteAnimIndex,x
		LDA !SpriteNum,x
		CMP #$4D : BNE ..fromwall
		..fromground
		JSL SpawnBrickPieces_Half
		..return
		RTS
		..fromwall
		REP #$30
		LDA #$0000
		LDY #$0000
		JSL GetMap16_Sprite
		CMP #$0111 : BCC ..spawnparticles
		CMP #$016E : BCS ..spawnparticles
		..breakblock
		SEP #$20
		LDA !SpriteXLo,x : STA $9A
		LDA !SpriteXHi,x : STA $9B
		LDA !SpriteYLo,x : STA $98
		LDA !SpriteYHi,x : STA $99
		REP #$20
		LDA #$0025 : JSL ChangeMap16
		SEP #$20
		LDX !SpriteIndex
		..spawnparticles
		SEP #$20
		JSL SpawnBrickPieces
		RTS

	.JumpOut
		LDX !SpriteIndex
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..return
		INC !MontyMoleState,x
		LDA #$03 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..return
		JSL APPLY_SPEED
		RTS

	.Chase
		LDX !SpriteIndex
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		LDA DATA_XSpeed,y : JSL AccelerateX
		LDA !SpriteXSpeed,x
		CMP #$F0 : BCS ..smoke
		CMP #$10 : BCS ..move
		..smoke
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..move
		JSL FrictionSmoke
		..move
		JSL APPLY_SPEED
		RTS


	.Return



	INTERACTION:
		LDA !MontyMoleState,x
		CMP #$02 : BCC .NoContact
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS .Die
		JSL P2Standard : BEQ .NoContact
		.Die
		LDA #$02 : STA !SpriteStatus,x
		.NoContact


	GRAPHICS:
		LDA !SpriteStatus,x
		CMP #$02 : BNE .Draw
		LDA #$05 : STA !SpriteAnimIndex,x

		.Draw
		LDA !MontyMoleState,x : BEQ .Return
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC

		.Return
		RTS



	DATA:
	.XSpeed
		db $18,$E8


	ANIM:
		dw .GroundDirt	: db $FF,$00	; 00
		dw .WallDirt	: db $FF,$01	; 01
		dw .Jump	: db $FF,$02	; 02

		dw .Walk00	: db $06,$04	; 03
		dw .Walk01	: db $06,$03	; 04

		dw .Dead	: db $FF,$05	; 05

	.Walk00
	dw $0004
	db $22,$00,$00,$00

	.Walk01
	dw $0004
	db $22,$00,$00,$02

	.Jump
	dw $0004
	db $22,$00,$00,$04

	.WallDirt
	dw $0004
	db $22,$00,$00,$06

	.GroundDirt
	dw $0008
	db $20,$00,$08,$08
	db $20,$08,$08,$18

	.Dead
	dw $0004
	db $A2,$00,$00,$04




