;
; interacts with both players and sprites
; extra byte 1:
;	0: interacts with both players and sprites
;	1: disable sprite interaction
;	2: disable player interaction
;	3: disable all interaction



Block:

	namespace Block

	INIT:
		LDA #$01 : STA !SpriteDir,x			; proper facing
		DEC !SpriteYLo,x				;\
		LDA !SpriteYLo,x				; | move one pixel up
		CMP #$FF					; |
		BNE $03 : DEC !SpriteYHi,x			;/
		; flow into MAIN

	MAIN:
		PHB : PHK : PLB

	.GetClipping
		JSL GetSpriteClippingE8
		LDA !ExtraBits,x
		AND #$04 : BEQ ..done
		..twotiles
		REP #$20
		LDA $E8
		SEC : SBC #$0010
		STA $E8
		LDA $EC
		CLC : ADC #$0010
		STA $EC
		SEP #$20
		..done

	.InteractSprites
		LDA !ExtraProp1,x
		AND #$01 : BNE ..done
		LDX #$0F
		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !SpriteStatus,x
		CMP #$08 : BCC ..next
		CMP #$0B : BCS ..next
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next
		LDY !SpriteIndex
		LDA !SpriteYLo,y
		CMP !SpriteYLo,x
		LDA !SpriteYHi,y
		SBC !SpriteYHi,x
		BCS ..down

		..up
		BIT !SpriteYSpeed,x : BPL ..side
		LDA #$08 : STA !SpriteExtraCollision,x
		STZ !SpriteYSpeed,x
		BRA ..side

		..down
		BIT !SpriteYSpeed,x : BMI ..side
		LDA #$04 : STA !SpriteExtraCollision,x
		STZ !SpriteYSpeed,x

		..side
		LDA !SpriteXLo,y
		CMP !SpriteXLo,x
		LDA !SpriteXHi,y
		SBC !SpriteXHi,x
		BCS ..right

		..left
		BIT !SpriteYSpeed,x : BPL ..next
		LDA #$02 : STA !SpriteExtraCollision,x
		STZ !SpriteYSpeed,x
		BRA ..next

		..right
		BIT !SpriteYSpeed,x : BMI ..next
		LDA #$01 : STA !SpriteExtraCollision,x
		STZ !SpriteYSpeed,x

		..next
		DEX : BPL ..loop
		LDX !SpriteIndex
		..done


	.PlayerInteraction
		LDA !ExtraProp1,x
		AND #$02 : BNE ..done
		LDA #$0F : JSL OutputPlatformBox
		..done

	.Graphics
		LDA !ExtraBits,x
		AND #$04
		REP #$20
		BNE ..twotiles
		..onetile
		LDA.w #.TM1 : BRA ..draw
		..twotiles
		LDA.w #.TM2
		..draw
		STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL


	.TM1
	dw $0004
	db $32,$00,$00,$00

	.TM2
	dw $0008
	db $32,$F0,$00,$00
	db $32,$00,$00,$00

	namespace off





