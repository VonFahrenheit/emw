Elevator:

	namespace Elevator


	!Direction	= $BE,x			; 00 = no, 01 = down, FF = up
	!Players	= $3280,x


	MAIN:
		PHB : PHK : PLB

	Interaction:
		STZ !Direction
		JSL $01B44F
		JSL !GetSpriteClipping04
		LDA $05
		CLC : ADC #$04
		STA $05
		LDA $0B
		ADC #$00
		STA $0B
		SEC : JSL !PlayerClipping
		STA !Players
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


	Physics:
		LDA !Direction : BEQ .NoMove
		BMI .MoveUp

		.MoveDown
		LDA #$08 : STA $00
		STZ $01
		BRA .Move

		.MoveUp
		LDA #$F8 : STA $00
		LDA #$FF : STA $01

		.Move
		LDA $3210,x
		CLC : ADC $00
		STA $3210,x
		LDA $3240,x
		ADC $01
		STA $3240,x
		LDA !Players
		LSR A
		BCC .P2
		PHA
	.P1	LDY #$00
		JSR Move
		PLA
	.P2	LSR A
		BCC .NoMove
		LDY #$80
		JSR Move
		.NoMove



	Graphics:
		REP #$20
		LDA.w #Tilemap_Basic32 : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_Long
		PLB
	INIT:
		RTL


	Tilemap:

	.Basic32
	dw $0008
	db $34,$F8,$00,$00
	db $34,$08,$00,$02



	Move:
		LDA !P2Character-$80,y
		REP #$20
		BEQ .Mario
	.PCE	LDA !P2YPosLo-$80,y
		CLC : ADC $00
		STA !P2YPosLo-$80,y
		SEP #$20
		RTS

	.Mario	LDA $96
		CLC : ADC $00
		STA $96
		SEP #$20
		RTS



	Interact:
		LDA $15
		AND #$08 : BEQ +
		LDA #$FF : STA !Direction
	+	LDA $15
		AND #$04 : BEQ +
		LDA #$01 : STA !Direction
		+

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









