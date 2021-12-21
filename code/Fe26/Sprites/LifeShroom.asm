
LifeShroom:
	namespace LifeShroom




	INIT:
		JSL GetItemMem : BNE .Fail

		.Success
		LDA $00 : STA $3500,x			;\
		LDA $01 : STA $3510,x			; | store item mem data (index + bit)
		LDA $02 : STA $3520,x			;/
		RTL

		.Fail
		STZ $3230,x
		RTL


	MAIN:
		PHB : PHK : PLB

	INTERACTION:
		JSL !GetSpriteClipping04

		.BodyContact
		SEC : JSL !PlayerClipping
		BCC ..nocontact
		LDY #$00
		LSR A
		BCS $02 : LDY #$80
		JSR Heal
		..nocontact

		.Done


	GRAPHICS:
		REP #$20
		LDA.w #ANIM_TM : STA $04
		SEP #$20
		JSL LOAD_TILEMAP_COLOR
		PLB
		RTL



	Heal:
		JSL CheckInteract : BNE .Return
		LDA !P2MaxHP-$80,y
		INC A
		STA !P2HP-$80,y
		LDA #$01 : STA !P2TempHP-$80,y
		LDA #$74 : STA !P2FlashPal-$80,y
		STZ $3230,x

		LDA $3500,x : STA $00
		LDA $3510,x : STA $01
		LDA $3520,x : STA $02
		LDA $33F0,x
		CMP #$FF : BEQ .NoIndex
		LDA #$EE : STA !SpriteLoadStatus,x
		.NoIndex
		LDA !HeaderItemMem
		CMP #$03 : BCS .NoMem
		REP #$10
		LDX $00
		LDA $02
		ORA !ItemMem0,x
		STA !ItemMem0,x
		SEP #$10
		.NoMem
		LDX !SpriteIndex

		LDA #$0D : STA !SPC1


		.Return
		RTS

	ANIM:
	.TM
		dw $0004
		db $22,$00,$00,$40



	namespace off

