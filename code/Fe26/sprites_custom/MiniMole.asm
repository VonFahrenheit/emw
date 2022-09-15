

	!MiniMoleState		= $BE
	!MiniMoleSineTimer	= $3280
	!MiniMoleSineHi		= $3290
	!MiniMoleBaseY		= $32A0
	!MiniMolePlayerCling	= $32B0
	!MiniMoleTimer		= $32D0

	!MiniMoleRNG		= $3400
	!MiniMolePrevRNG	= $3410

	!MiniMoleClingOffsetX	= $3420
	!MiniMoleClingOffsetY	= $3430



MiniMole:

	namespace MiniMole

	INIT:
		TXA
		ASL #3 : STA !MiniMoleSineTimer,x

		.SetState
		LDA !MiniMoleState,x : BNE ..done		;\
		LDA #$40 : STA !MiniMoleTimer,x			; |
		LDA !SpriteYLo,x
		ORA #$08 : STA !SpriteYLo,x
		LDA !ExtraBits,x				; | extra bit clear to walk, set to burrow
		AND #$04 : BEQ ..done				; | (if sprite was spawned by another, ignore extra bit selection)
		INC !MiniMoleState,x				; |
		LDA #$03 : STA !SpriteAnimIndex,x		; |
		..done						;/

		.Return
		RTL


	MAIN:
		PHB : PHK : PLB

		LDA !SpriteStatus,x
		CMP #$08 : BEQ .UpdateSine
		LDA #$05 : STA !SpriteAnimIndex,x
		JMP GRAPHICS


		.UpdateSine
		LDA !MiniMoleSineTimer,x
		CLC : ADC #$08
		STA !MiniMoleSineTimer,x
		BNE ..done
		LDA !MiniMoleSineHi,x
		EOR #$01 : STA !MiniMoleSineHi,x
		..done


	PHYSICS:
		PEA .Return-1
		LDA !MiniMoleState,x
		ASL A
		CMP.b #.StatePtr_end-.StatePtr
		BCC $02 : LDA #$00
		TAX
		JMP (.StatePtr,x)

		.StatePtr
		dw .Hide
		dw .Walk
		dw .Fly
		dw .Cling
		..end


	.Hide
		LDX !SpriteIndex
		LDA !MiniMoleTimer,x : BEQ ..look
		CMP #$01 : BNE ..return
		..jumpout
		LDA #$D0 : STA !SpriteYSpeed,x
		LDA #$02 : STA !SpriteAnimIndex,x
		INC !MiniMoleState,x
		RTS
		..look
		LDA #$17 : JSL GetSpriteClippingE8_A
		JSL PlayerContact : BCC ..return
		LDA #$40 : STA !MiniMoleTimer,x
		..return
		RTS


	.Walk
		LDX !SpriteIndex
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..move
		LDA !SpriteAnimIndex,x
		CMP #$03 : BCS ..walk
		LDA #$03 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..walk
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..move
		JSL APPLY_SPEED
		RTS


	.Fly
		LDX !SpriteIndex
		LDA #$FF : STA !SpriteTweaker4,x		; all resistances
		REP #$30
		LDA !MiniMoleSineTimer,x
		AND #$00FF
		ASL A
		TAX
		LDA.l !TrigTable,x				; read trig value
		LSR #3
		SEP #$30
		LDX !SpriteIndex
		LDY !MiniMoleSineHi,x
		BEQ $03 : EOR #$FF : INC A
		CLC : ADC !MiniMoleBaseY,x
		STA !SpriteYSpeed,x
		LDY !SpriteDir,x
		LDA DATA_XSpeed+2,y : STA !SpriteXSpeed,x
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		RTS


	.Cling
		LDX !SpriteIndex
		LDA #$02 : STA !SpriteAnimIndex,x
		LDA #$FF : STA !SpriteTweaker4,x		; all resistances
		LDY !MiniMolePlayerCling,x			;\
		LDA !P2XPosLo-$80,y				; |
		CLC : ADC !MiniMoleClingOffsetX,x		; |
		STA !SpriteXLo,x				; |
		LDA !P2XPosHi-$80,y				; |
		ADC #$00					; |
		STA !SpriteXHi,x				; | sprite position
		LDA !P2YPosLo-$80,y				; |
		CLC : ADC !MiniMoleClingOffsetY,x		; |
		STA !SpriteYLo,x				; |
		LDA !P2YPosHi-$80,y				; |
		ADC #$00					; |
		STA !SpriteYHi,x				;/

		..crawl						;\
		LDA !RNG : STA $00				; |
		TXA						; | rotate rng value to make sure different mini moles can crawl differently
		AND #$07					; |
	-	ROR $00						; |
		DEC A : BPL -					;/
		LDA $00						;\
		BIT #$01 : BNE +				; |
		AND #$02					; |
		DEC A						; |
		CLC : ADC !MiniMoleClingOffsetX,x		; | crawl x
		BPL $02 : LDA #$00				; |
		CMP #$08					; |
		BCC $02 : LDA #$08				; |
		STA !MiniMoleClingOffsetX,x			;/
	+	LDA $00 : LSR #2				;\
		BIT #$01 : BNE +				; |
		AND #$02					; |
		DEC A						; |
		CLC : ADC !MiniMoleClingOffsetY,x		; | crawl y
		BPL $02 : LDA #$00				; |
		CMP #$08					; |
		BCC $02 : LDA #$08				; |
		STA !MiniMoleClingOffsetY,x			; |
		+						;/

		TXA						;\
		CLC : ADC $14					; | generate a troll input every 16 frames
		AND #$0F : BEQ ..trollinput			;/
		..checkinput					;\
		TYA						; |
		CLC : ROL #2					; |
		LDA $6DA6,y					; | player can use inputs to shake mini mole
		ORA $6DA8,y					; |
		BNE ..shake					; |
		..return					; |
		RTS						;/
		..shake						;\
		INC !SpriteHP,x					; |
		LDY !Difficulty					; |
		LDA !SpriteHP,x					; | once sufficiently shaken, mini mole dies
		CMP DATA_ClingHP,y : BCC ..return		; |
		JSR Die						; |
		RTS						;/
		..trollinput					;\
		LDA !RNGtable+$00,x				; |
		AND #$CF : STA !P2ExtraInput1-$80,y		; | generate troll inputs
		LDA !RNGtable+$10,x				; |
		AND #$C0 : STA !P2ExtraInput3-$80,y		; |
		RTS						;/


		.Return



	INTERACTION:
		LDA !MiniMoleState,x : BEQ .NoContact
		CMP #$03 : BEQ .NoContact

		.CheckContact
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCC ..body
		..die
		JSR Die
		..body
		JSL PlayerContact : BCC .NoContact
		LSR A
		LDA #$03 : STA !MiniMoleState,x
		BCS .NoContact
		LDA #$80 : STA !MiniMolePlayerCling,x
		.NoContact


	GRAPHICS:
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM

		.Draw
		LDA !MiniMoleState,x
		CMP #$03 : BEQ ..p3
		..p2
		JSL LOAD_PSUEDO_DYNAMIC_p2
		PLB
		RTL
		..p3
		JSL LOAD_PSUEDO_DYNAMIC_p3
		PLB
		RTL


	Die:
		LDA #$02 : STA !SpriteStatus,x			; die
		LDY !MiniMolePlayerCling,x			;\
		LDA #$00					; | release player input
		STA !P2ExtraInput1-$80,y			; |
		STA !P2ExtraInput3-$80,y			;/
		RTS						; return


	ANIM:
		; hide
		dw .Hide00	: db $08,$01	; 00
		dw .Hide01	: db $08,$00	; 01
		; jump
		dw .Jump	: db $FF,$02	; 02
		; walk
		dw .Walk00	: db $08,$04	; 03
		dw .Walk01	: db $08,$03	; 04
		; dead
		dw .Dead	: db $FF,$05	; 05


		.Hide00
		dw $0004
		db $30,$04,$00,$10

		.Hide01
		dw $0004
		db $30,$04,$00,$11

		.Jump
		dw $0004
		db $30,$04,$00,$12

		.Walk00
		dw $0004
		db $30,$04,$00,$13

		.Walk01
		dw $0004
		db $30,$04,$00,$14

		.Dead
		dw $0004
		db $B0,$04,$00,$12



	DATA:
		.XSpeed
		db $08,$F8
		db $10,$F0

		.ClingHP
		db $0A,$0F,$14




	namespace off





