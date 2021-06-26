TerrainPlatform:

	namespace TerrainPlatform


	!MovementType	= $BE,x
	!MovementDiffX	= $3280,x
	!MovementDiffY	= $3290,x

	!PlatformTiles	= $32A0,x		; how many tiles the platform uses

	!MarioMoveX	= $32B0,x		; number of pixels to move Mario horizontally


	INIT:
		PHB : PHK : PLB

		LDA !ExtraProp1,x : STA !SpriteAnimIndex


		LDA #$01 : STA $3320,x

		LDA $3220,x
		LSR #4
		AND #$03
		STA !MovementType
		CMP #$03 : BNE .NotCircle
		LDA #$1F : STA $AE,x
		.NotCircle

		LDA !ExtraBits,x
		AND #$04 : BEQ +
		LDA #$02 : BRA ++		; start in reverse order if extra bit is set

	+	LDA #$01
	++	STA !MovementDiffX
		STA !MovementDiffY



		PLB
		RTL



	MAIN:
		PHB : PHK : PLB
		LDA !MovementType : BNE .moving
		JSL SPRITE_OFF_SCREEN
		BRA Physics

		.moving
		LDA $3250,x : XBA		; moving platforms have a larger non-despawn window
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CMP #$0200 : BCC .ok
		CMP #$FF00 : BCS .ok
		SEP #$20
		STZ $3230,x
		PHX
		LDY $33F0,x
		TYX
		TDC : STA $418A00,x		; allow sprite to be reloaded
		PLX
		PLB
		RTL

	.ok	SEP #$20


	Physics:

		PEA.w Speed-1
		PHX
		LDA !MovementType
		ASL A
		TAX
		JMP (.Ptr,x)


		.Ptr
		dw Stationary		; X = 0
		dw Horizontal		; X = 1
		dw Vertical		; X = 2
		dw Circle		; X = 3

	DATA:
	.SpeedLimit
		db $20,$E0		; high speed limit
		db $14,$EC		; low speed limit
		db $20,$E0		; repeat of high


	Stationary:
		PLX
		RTS


	Horizontal:
		PLX
	.Main	LDA $14
		LSR A : BCC .Return
		LDA !ExtraBits,x
		AND #$04
		LSR A
		TAY
		LDA $AE,x
		CLC : ADC !MovementDiffX
		STA $AE,x
		CMP DATA_SpeedLimit+0,y : BEQ .Invert
		CMP DATA_SpeedLimit+1,y : BEQ .Invert
	.Return	RTS

	.Invert	LDA !MovementDiffX
		EOR #$FF
		INC A
		STA !MovementDiffX
		RTS


	Vertical:
		PLX
	.Main	LDA $14
		LSR A : BCC .Return
		LDA !ExtraBits,x
		AND #$04
		LSR A
		TAY
		LDA $9E,x
		CLC : ADC !MovementDiffY
		STA $9E,x
		CMP DATA_SpeedLimit+2,y : BEQ .Invert
		CMP DATA_SpeedLimit+3,y : BEQ .Invert
	.Return	RTS

	.Invert	LDA !MovementDiffY
		EOR #$FF
		INC A
		STA !MovementDiffY
		RTS


	Circle:
		PLX
		JSR Horizontal_Main
		BRA Vertical_Main


	Speed:
		LDA $3220,x : PHA
		JSL $01801A
		JSL $018022
		PLA
		SEC : SBC $3220,x		; YEAH BAYBEEEE
		EOR #$FF : INC A
		STA !MarioMoveX


	Interaction:

		JSL $01B44F


		JSL !GetSpriteClipping04
		LDA $05
		CLC : ADC #$04
		STA $05
		LDA $0B
		ADC #$00
		STA $0B
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00
		JSR Interact
		PLA
	.P2	LSR A : BCC .NoContact
		LDY #$80
		JSR Interact

		.NoContact
		LDY #$0F
		PHX
	-	CPY !SpriteIndex : BEQ ++
		TYX
		PHY
		JSL !GetSpriteClipping00
		INC $03				; sprites have a taller hitbox for the purposes of this
		INC $03
		JSL !CheckContact
		BCC +
		JSR SpriteInteract
	+	PLY
	++	DEY : BPL -
		PLX





	Graphics:

		LDA $3210,x : STA $0E
		LDA $3240,x : STA $0F

		LDA !SpriteAnimIndex
		ASL A
		CMP.b #.Shape_End-.Shape
		BCC $02 : LDA #$00
		TAY

		LDA !SpriteTile,x : STA $03
		LDA !SpriteProp,x : STA $02

		REP #$20
		STZ $00
		STZ $06
		LDA.w .Shape,y : JSR LakituLovers_TilemapToRAM

		LDA.w #!BigRAM : STA $04
		SEP #$20
		LDA ($04) : STA !PlatformTiles

		JSL LOAD_TILEMAP
		PLB
		RTL




	.Shape
	dw .Tall
	dw .Basic48
	dw .Basic32		; this one assumes just 2 tiles are loaded
	..End


	.Tall
	dw $0020
	db $34,$F0,$00,$06
	db $34,$00,$00,$08
	db $34,$10,$00,$0A
	db $34,$10,$10,$0C
	db $74,$EF,$20,$0C
	db $34,$10,$30,$0C
	db $74,$EF,$40,$0C
	db $34,$10,$50,$0C

	.Basic48
	dw $000C
	db $34,$F0,$00,$06
	db $34,$00,$00,$08
	db $74,$EF,$00,$06

	.Basic32
	dw $0008
	db $34,$F8,$00,$00
	db $34,$08,$00,$02





	Interact:
		LDA !P2Character-$80,y : BEQ .Nope

		LDA !P2YSpeed-$80,y
		CLC : ADC !P2VectorY-$80,y
		CMP $9E,x : BMI .Nope

		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC #$000B			; player must be at least 11px above sprite
		CMP !P2YPosLo-$80,y
		SEP #$20
		BCC .Nope

		TXA
		INC A
		STA !P2SpritePlatform-$80,y
		LDA $AE,x : STA !P2VectorX-$80,y
		LDA $9E,x : STA !P2VectorY-$80,y
		LDA #$01
		STA !P2VectorTimeX-$80,y
		STA !P2VectorTimeY-$80,y
		LDA #$00
		STA !P2VectorAccX-$80,y
		STA !P2VectorAccY-$80,y

		LDA $05
		SEC : SBC #$0F
		STA !P2YPosLo-$80,y
		LDA $0B
		SBC #$00
		STA !P2YPosHi-$80,y
	.Nope	RTS



	SpriteInteract:
		LDA $3230,x
		CMP #$08 : BNE .Nope
		LDA $9E,x : BMI .Nope
		LDA $05
		CLC : ADC $07
		STA $0C
		LDA $0B
		ADC #$00
		STA $0D
		LDA $01
		CLC : ADC $03
		STA $0E
		LDA $09
		ADC #$00
		XBA
		LDA $0E
		REP #$20
		CMP $0C
		SEP #$20
		BCS .Nope
		LDA #$04 : STA $3580,x		; set extra collision
		LDA $05				; sprite Y position
		SEC : SBC #$0F
		STA $3210,x
		LDA $0B
		SBC #$00
		STA $3240,x

		LDY !SpriteIndex		; vectors
		LDA $309E,y
		CLC : ADC #$10
		STA $3520,x
		LDA $30AE,y : STA $3530,x
		LDA #$02
		STA $3560,x
		STA $3570,x



	.Nope	RTS




	namespace off









