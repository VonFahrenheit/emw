MiniMole:

	namespace MiniMole

	!MiniMoleState		= $BE,x
	!MiniMoleSineTimer	= $3280,x
	!MiniMoleSineHi		= $3290,x
	!MiniMoleBaseY		= $32A0,x
	!MiniMolePlayerCling	= $32B0,x
	!MiniMoleTimer		= $32D0,x
	!MiniMoleClingHP	= $33C0,x
	!MiniMoleRNG		= $33D0,x
	!MiniMolePrevRNG	= $35E0,x



	INIT:
		PHB : PHK : PLB
		LDA !GFX_status+$0E : STA !ClaimedGFX
		LDA #$40 : STA !MiniMoleTimer
		TXA
		ASL #3
		STA !MiniMoleSineTimer
		STZ !MiniMoleClingHP
		PLB


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN_Long
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS

	DATA:
		.XSpeed
		db $08,$F8
		db $10,$F0

		.ClingHP
		db $0A,$0F,$14

		.ClingX
		db $F8,$FC,$00,$04
		db $F8,$FC,$00,$04
		db $F8,$FC,$00,$04
		db $F8,$FC,$00,$04

		.ClingY
		db $00,$00,$00,$00
		db $04,$04,$04,$04
		db $08,$08,$08,$08
		db $0C,$0C,$0C,$0C

	PHYSICS:

		LDA !MiniMoleSineTimer
		CLC : ADC #$08
		STA !MiniMoleSineTimer
		BNE +
		LDA !MiniMoleSineHi
		EOR #$01
		STA !MiniMoleSineHi
	+	PEA .Return-1
		LDA !MiniMoleState
		AND #$3F
		ASL A
		CMP.b #.Ground-.StatePtr
		BCC $01 : RTS
		TAX
		JMP (.StatePtr,x)

		.StatePtr
		dw .Ground
		dw .Walk
		dw .Fly
		dw .Cling

		.Ground
		LDX !SpriteIndex
		BIT !MiniMoleState
		BMI +
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		PHA
		SEC : SBC !P2XPosLo-$80
		BPL $03 : EOR #$FFFF
		CMP #$0080
		PLA
		BCC +++
		SEC : SBC !P2XPosLo
		BPL $03 : EOR #$FFFF
		CMP #$0080 : BCS ++
	+++	SEP #$20
		LDA #$80 : STA !MiniMoleState
	++	SEP #$20
		INC !MiniMoleTimer

	+	LDA !MiniMoleTimer
		BNE ++
		BIT !MiniMoleState
		BVS ..Air
		..Ground
		LDA #$D0 : STA $9E,x
		LDA #$C0 : STA !MiniMoleState
		..Air
		LDA $9E,x
		BPL +
		JSL !SpriteApplySpeed-$10
		INC $9E,x
		INC $9E,x
	++	RTS
	+	DEC $9E,x
		LDA $3330,x
		AND #$04
		BEQ ..Return
		LDA #$01 : STA !MiniMoleState
		..Return
		JSL !SpriteApplySpeed
		RTS

		.Walk
		LDX !SpriteIndex
		DEC $9E,x
		LDA $3330,x
		AND #$03
		BEQ +
		LDA $3320,x
		EOR #$01
		STA $3320,x
	+	LDY $3320,x
		LDA DATA_XSpeed,y
		STA $AE,x
		..Return
		JSL !SpriteApplySpeed
		RTS

		.Fly
		LDX !SpriteIndex
		LDA $3480,x
		ORA #$98
		STA $3480,x
		REP #$30
		LDA !MiniMoleSineTimer
		AND #$00FF
		ASL A
		TAX
		LDA.l $07F7DB,x
		LSR #3
		SEP #$30
		LDX !SpriteIndex
		LDY !MiniMoleSineHi
		BEQ $03 : EOR #$FF : INC A
		CLC : ADC !MiniMoleBaseY
		STA $9E,x
		LDY $3320,x
		LDA DATA_XSpeed+2,y
		STA $AE,x
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
		RTS

		.Cling
		LDX !SpriteIndex
		LDA $3480,x
		ORA #$98
		STA $3480,x
		LDY !MiniMolePlayerCling
		LDA !P2XPosLo-$80,y : STA $3220,x
		LDA !P2XPosHi-$80,y : STA $3250,x
		LDA !P2YPosLo-$80,y : STA $3210,x
		LDA !P2YPosHi-$80,y : STA $3240,x
		LDA $14					;\
		CLC : ADC !SpriteIndex			; | Only mess with input once every 16 frames
		AND #$0F : BEQ ..Troll			; |
		CMP #$01 : BNE ..CheckInput		;/
		RTS

		..Troll					;\
		LDA !RNG				; |
		AND #$0F				; |
		STA $00					; |
		LDA !MiniMolePrevRNG			; |
		AND #$C0				; | Generate troll input
		AND !RNG				; |
		ORA $00					; |
		STA !P2ExtraInput1-$80,y		; |
		STA !P2ExtraInput2-$80,y		; |
		RTS					;/

		..CheckInput
		TYA
		CLC : ROL #2
		LDA $6DA6,y
		ORA $6DA8,y
		BEQ ..Return
		INC !MiniMoleClingHP
		LDA #$00
		STA $6DA6,y
		STA $6DA8,y
		LDA !Difficulty
		AND #$03
		TAY
		LDA !MiniMoleClingHP
		CMP DATA_ClingHP,y
		BCC ..Return
		LDA #$02 : STA $3230,x

		..Return
		RTS



		.Return



	INTERACTION:

		LDA !MiniMoleState
		AND #$3F
		CMP #$01 : BEQ .CheckContact
		CMP #$02 : BNE .NoContact

		.CheckContact
		LDA $3220,x : STA $04
		LDA $3250,x : STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$08
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A
		LDA #$03 : STA !MiniMoleState
		BCS .NoContact
		LDA #$80 : STA !MiniMolePlayerCling
		.NoContact


	GRAPHICS:

		LDA !MiniMoleState
		AND #$3F : BNE $03 : JMP .Ground
		CMP #$01 : BNE $03 : JMP .Walk
		CMP #$02 : BNE $03 : JMP .Fly
		CMP #$03 : BEQ $03 : JMP .Return

		.Cling
		LDA !MiniMoleSineTimer		;\
		AND #$48			; | Update internal RNG
		BNE +				; |
		LDA !RNG : STA !MiniMoleRNG	;/
	+	STZ $0D				;\
		STZ $0F				; |
		LDA DATA_ClingX,x		; |
		STA $0C				; | $0C-$0F is displacement
		BPL $02 : DEC $0D		; |
		LDA DATA_ClingY,x		; |
		STA $0E				;/
		LDA !MiniMoleRNG		;\
		AND #$0F			; |
		STA $08				; |
		LDA !MiniMoleRNG		; | $08-$0B is RNG values
		LSR #4				; |
		STA $0A				; |
		STZ $09				; |
		STZ $0B				;/
		LDY !MiniMolePlayerCling	;\
		LDA !P2Character-$80,y		; |
		BEQ +				; |
		REP #$20			; | Account for Mario's natural displacement
		LDA $0E				; |
		SEC : SBC #$0010		; |
		STA $0E				; |
		SEP #$20			;/

	+	LDY !OAMindex
		LDA !OAM+$001,y
		CMP #$F0 : BEQ +
		JMP .Return

	+	LDA $3210,x : STA $00
		LDA $3240,x : STA $01
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC $08
		CLC : ADC $0C
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF8 : BCC ..Return
	..GoodX	STA $02
		LDA $00
		SEC : SBC $1C
		CLC : ADC $0A
		CLC : ADC $0E
		CMP #$00E8 : BCC ..GoodY
		CMP #$FFF8 : BCC ..Return
	..GoodY	SEP #$20
		STA !OAM+$001,y
		LDA $02 : STA !OAM+$000,y
		LDA $14
		LSR #2
		AND #$01
		CLC : ADC #$02
		ORA #$30
		CLC : ADC !ClaimedGFX
		STA !OAM+$002,y
		LDA #$29 : STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		LDA $03
		AND #$01
		STA !OAMhi+$00,y
		LDA !OAMindex
		CLC : ADC #$04
		STA !OAMindex

		..Return
		SEP #$20
		BRA .Return

		.Fly
		LDA #$02
		BRA .ProcessAnim

		.Walk
		LDA $14
		LSR #3
		AND #$01
		CLC : ADC #$03
		BRA .ProcessAnim

		.Ground
		BIT !MiniMoleState : BVS .Fly
		LDA $14
		LSR #3
		AND #$01

		.ProcessAnim
		STA !SpriteAnimIndex
		REP #$20				;\
		LDA #$0004 : STA !BigRAM+$00		; |
		LDA #$0029 : STA !BigRAM+$02		; |
		LDA #$3008 : STA !BigRAM+$04		; |
		LDA.w #!BigRAM : STA $04		; | Generate tilemap
		SEP #$20				; |
		LDA !SpriteAnimIndex			; |
		TSB !BigRAM+$05				;/
		JSL LOAD_PSUEDO_DYNAMIC_Long		; > Load tilemap into $6300 block
		LDA $33B0,x				;\
		LSR #2					; |
		TAY					; | Set tile size to 8x8
		LDA !OAMhi+$40,y			; |
		AND.b #$02^$FF				; |
		STA !OAMhi+$40,y			;/

		.Return
		LDA !RNG : STA !MiniMolePrevRNG
		PLB
		RTL



	namespace off





