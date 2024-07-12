
; see Boo code file for more information
	!BooBlockTimer1	= $3500		; timer used when turning into a block
	!BooBlockTimer2	= $3510		; timer used when turning into a ghost

	INIT:
	MAIN:
		.Timer1
		LDA !BooBlockTimer1,x : BEQ ..done
		DEC !BooBlockTimer1,x
		..done
		.Timer2
		LDA !BooBlockTimer2,x : BEQ ..done
		DEC !BooBlockTimer2,x
		..done

		LDA !SpriteAnimIndex,x : BEQ .BlockForm
		LDA !BooBlockTimer2,x : BNE .BlockForm

	.BooForm
		LDA #$10 : STA !BooBlockTimer1,x			; 16 frames to turn into a block after being seen in ghost form
		LDA !GFX_Boo_tile : STA !SpriteTile,x
		LDA !GFX_Boo_prop : STA !SpriteProp,x
		JMP Boo_MAIN

	.BlockForm
		JSL AccelerateX_Friction1				;\
		JSL AccelerateY_Friction1				; | simply physics, maintain some momentum
		JSL APPLY_SPEED_X					; |
		JSL APPLY_SPEED_Y					;/

		LDA #$06 : JSL GetSpriteClippingE8_A			;\ act as platform
		LDA #$0F : JSL OutputPlatformBox			;/
		STZ $00							; clear sight flags

		.CheckP1
		JSL SUB_HORZ_POS_P1					;\
		CPY !P2Dir-$80 : BNE ..done				; | P1 looking at sprite?
		INC $00							;/
		..done

		.CheckP2
		JSL SUB_HORZ_POS_P2					;\
		CPY !P2Dir : BNE ..done					; | P2 looking at sprite?
		LDA #$02 : TSB $00					;/
		..done

		.CheckActivation
		LDA !Players						;\ if any living player is looking at sprite, it stays in block form
		AND $00 : BNE ..solid					;/
		LDA #$14 : JSL GetSpriteClippingE8_A			;\ if any player is within vertical sight box, sprite stays in block form
		JSL PlayerContact : BCC ..activate			;/
		..solid
		STZ !SpriteAnimIndex,x					; if seen, reset block form
		BRA ..done
		..activate
		LDA !SpriteAnimIndex,x : BNE ..done			;\
		LDA #$10 : STA !BooBlockTimer2,x			; | 16 frames to turn into a ghost after leaving block form
		LDA #$02 : STA !SpriteAnimIndex,x			;/
		..done

	.Graphics
		LDA !BooBlockTimer1,x
		ORA !BooBlockTimer2,x
		BEQ ..solid
		..pseudo
		JSL DRAW_SIMPLE_0
		RTS
		..solid
		JSL DRAW_SIMPLE_2
		RTS
