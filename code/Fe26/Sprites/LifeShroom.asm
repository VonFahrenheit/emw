
LifeShroom:
	namespace LifeShroom




	INIT:
		JSL GetItemMem : BNE .Fail

		.Success
		LDA $00 : STA $3500,x			;\
		LDA $01 : STA $3510,x			; | store item mem data (index + bit)
		LDA $02 : STA $3520,x			;/

		REP #$30
		LDA #$0000
		LDY #$0000
		JSL !GetMap16Sprite
		LDX !SpriteIndex
		CMP #$0022 : BEQ ..hide
		CMP #$0117 : BEQ ..hide
		CMP #$011F : BEQ ..hide
		CMP #$0126 : BEQ ..hide
		..nothidden
		SEP #$20
		DEC $BE,x				; -1 = don't move
		RTL
		..hide
		SEP #$20
		INC $BE,x				; 1 = hidden
		RTL

		.Fail
		STZ $3230,x
		RTL

	DATA:
		.XSpeed
		db $10,$F0



	MAIN:
		PHB : PHK : PLB


	HIDE:
		LDA $BE,x
		BMI .Done
		BEQ .Done
		REP #$30
		LDA #$0000
		LDY #$0000
		JSL !GetMap16Sprite
		LDX !SpriteIndex
		CMP #$0025 : BEQ .EatSprite
		CMP #$0132 : BEQ .EatSprite
		.Return
		SEP #$20
		PLB
		RTL

		.EatSprite
		SEP #$20
		STZ $BE,x
		LDA #$34 : STA $32D0,x
		JSL !GetSpriteClipping04
		LDX #$0F
		.Loop
		LDA $3230,x
		CMP #$08 : BNE .Next
		LDA !ExtraBits,x
		AND #$08 : BNE .Next
		LDA $3200,x
		CMP #$74 : BEQ .Kill
		CMP #$78 : BNE .Next
		.Kill
		STZ $3230,x
		LDY !SpriteIndex
		JSL SPRITE_A_SPRITE_B_COORDS
		.Next
		DEX : BPL .Loop
		LDX !SpriteIndex
		.Done


	PHYSICS:
		BIT $BE,x : BMI .Done
		LDA $32D0,x : BEQ .NoRise
		LDA #$FC : STA !SpriteYSpeed,x
		STZ !SpriteXSpeed,x
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
		LDA $32D0,x
		CMP #$01 : BNE .Done
		STZ !SpriteYSpeed,x
		BRA .Done

		.NoRise
		LDA $3330,x
		BIT #$04 : BEQ .YDone
		STZ !SpriteYSpeed,x
		.YDone

		AND #$03 : BEQ .NoTurn
		LDA $3320,x
		EOR #$01 : STA $3320,x
		.NoTurn
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		.Move
		JSL !SpriteApplySpeed
		.Done


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
		LDA !P2MaxHP-$80,y : STA !P2HP-$80,y		; full heal
		LDA #$04 : STA !P2TempHP-$80,y			; +1 temp heart
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
		db $22,$00,$FF,$40



	namespace off

