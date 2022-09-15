

Elevator:

	namespace Elevator


	!ElevatorDirection	= $BE			; 00 = no, 01 = down, FF = up
	!ElevatorPlayers	= $3280


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
		LDA !ElevatorDirection,x : BEQ .NoMove
		BMI .MoveUp
		.MoveDown
		LDA #$30 : STA !SpriteYSpeed,x
		BRA .NoMove
		.MoveUp
		LDA #$D0 : STA !SpriteYSpeed,x
		.NoMove
		JSL APPLY_SPEED

	Interaction:
		STZ !ElevatorDirection,x
		REP #$20
		LDA.w #PlatformHitbox : JSL LOAD_HITBOX
		LDA #$04 : JSL OutputPlatformBox

		REP #$20
		LDA.w #ControlHitbox : JSL LOAD_HITBOX

		JSL PlayerContact : STA !ElevatorPlayers,x
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


	PlatformHitbox:
		dw $FFF8,$0000 : db $20,$08

	ControlHitbox:
		dw $FFF8,$FFFB : db $20,$08

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
		STA !ElevatorDirection,x

		.NoInput
		RTS





	namespace off









