

Elevator:

	namespace Elevator


	!Direction	= $BE,x			; 00 = no, 01 = down, FF = up
	!Players	= $3280,x


	MAIN:
		PHB : PHK : PLB

	Graphics:
		REP #$20
		LDA.w #Tilemap_Basic32 : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

	Physics:
		STZ !SpriteXSpeed,x
		STZ !SpriteYSpeed,x
		LDA !Direction : BEQ .NoMove
		BMI .MoveUp
		.MoveDown
		LDA #$30 : STA !SpriteYSpeed,x
		BRA .NoMove
		.MoveUp
		LDA #$D0 : STA !SpriteYSpeed,x
		.NoMove
		JSL !SpriteApplySpeed

	Interaction:
		STZ !Direction
		LDA $3220,x
		SEC : SBC #$08
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$20 : STA $06
		LDA #$08 : STA $07
		LDA #$04 : JSL OutputPlatformBox

		LDA $3210,x				; move control box up
		SEC : SBC #$05
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA $07
		CLC : ADC #$05
		STA $07
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

		PLB
	INIT:
		RTL


	Tilemap:
		.Basic32
		dw $0008
		db $32,$F8,$00,$00
		db $32,$08,$00,$02


	Interact:
		TYA
		ASL A
		ROL A
		AND #$01
		TAX
		LDA $6DA2,x
		LDX !SpriteIndex
		AND #$0C : BEQ .NoInput
		CMP #$0C : BEQ .NoInput
		EOR #$0C
		SBC #$05
		STA !Direction

		.NoInput
		RTS





	namespace off









