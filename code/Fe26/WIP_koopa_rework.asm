











ShellessKoopa_INIT:
KickerKoopa_INIT:
		RTL

ShellessKoopa_MAIN:
		PHB : PHK : PLB

		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL !SpriteApplySpeed				; speed + terrain physics
		JSL !GetSpriteClipping04
		JSL AttackKnockout				; melee + projectiles -> state 02
		JSL P2Standard
		JSL SpriteSpriteInteraction

		.ShellInteraction
		LDA $3330,x
		AND #$04 : BNE ..sight
		..body
		JSL !GetSpriteClipping04 : BRA ..go
		..sight
		REP #$10
		LDY.w #DATA_SightBox : JSL LoadHitbox
		..go
		LDY #$0F
		..loop
		LDA $3230,y
		CMP #$09 : BNE ..next
		LDA !ExtraBits,y
		AND #$08 : BNE ..next
		LDA $3200,y
		CMP #$04 : BCC ..next
		CMP #$08 : BCS ..next
		PHX
		TYX : JSL !GetSpriteClipping00
		PLX
		JSL !Contact16 : BCC ..next
		LDA $3330,x
		AND #$04 : BNE ..jump
		..merge
		LDA #$08 : STA $3230,y
		LDA #$40 : STA $32D0,y
		STZ $3230,x
		BRA ..done
		..jump
		LDA #$E0 : STA !SpriteYSpeed,x
		BRA ..done
		..next
		DEY : BPL ..loop
		..done

	; animations


	; graphics
		REP #$20
		LDA.w #ANIM_Shelless : JSL HandleAnimation

		PLB
		RTL



KickerKoopa_MAIN:
		PHB : PHK : PLB

		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSL !SpriteApplySpeed				; speed + terrain physics
		JSL !GetSpriteClipping04
		JSL AttackKnockout				; melee + projectiles -> state 02
		JSL P2Standard

		; only run this if not currently preparing to kick something
		JSL SpriteSpriteInteraction

	; shell interaction

		; kick

	; animations


	; graphics
		REP #$20
		LDA.w #ANIM_Kicker : JSL HandleAnimation

		PLB
		RTL





	DATA:
		.XSpeed
		db $10,$F0
		.SightBox
		dw $FFE8,$0000 : db $10,$10


	ANIM_Shelless:
		dw GEN_Tile00 : db $08,$01	; 00
		dw GEN_Tile02 : db $08,$00	; 01
		dw GEN_Tile04 : db $04,$03	; 02
		dw GEN_Tile06 : db $04,$02	; 03

	ANIM_Kicker:
		dw GEN_Tile00 : db $08,$01	; 00
		dw GEN_Tile02 : db $08,$00	; 01
		dw GEN_Tile04 : db $FF,$02	; 02
		dw GEN_Tile06 : db $20,$00	; 03


	GEN:
		.Tile00
		dw $0004
		db $02,$00,$00,$00

		.Tile02
		dw $0004
		db $02,$00,$00,$02

		.Tile04
		dw $0004
		db $02,$00,$00,$04

		.Tile06
		dw $0004
		db $02,$00,$00,$06




;==============;
; NEW ROUTINES ;
;==============;

	HandleAnimation:
		STA $04					; pointer to tilemap
		INC #2 : STA $00			; pointer to timer
		INC A : STA $02				; pointer to next anim index

		SEP #$20				;\
		LDA !SpriteAnimIndex			; |
		ASL #2 : TAY				; | check timer
		LDA !SpriteAnimTimer			; |
		INC A					; |
		CMP ($00),y : BNE .ThisOne		;/

		.NewAnim				;\
		LDA ($02),y : STA !SpriteAnimIndex	; |
		ASL #2 : TAY				; |
		REP #$20				; | get new anim
		LDA ($04),y : STA $04			; |
		SEP #$20				; |
		LDA #$00				;/

		.ThisOne				;\ update timer
		STA !SpriteAnimTimer			;/
		REP #$20				;\
		LDA ($04),y : STA $04			; | load tilemap
		SEP #$20				; |
		JML LOAD_PSUEDO_DYNAMIC			;/


	AttackKnockout:
		.Melee
		JSL P2Attack : BCS .Knockout
		..done

		.ExProjectiles
		JSL FireballContact_Destroy : BCC ..done
		CLC
		BIT !SpriteTweaker4,x : BVS ..done
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$D8 : STA !SpriteYSpeed,x
		BRA .Knockout
		..done
		RTL

		.Knockout
		LDA #$02 : STA $3230,x
		SEC
		RTL


	SpriteSpriteInteraction:
		LDA !Tweaker3,x				;\ if tweaker bit is set, process every frame
		AND #$01 : BNE .Process			;/
		TXA					;\
		AND !Tweaker3,x				; | otherwise, process every other frame
		AND #$01 : BEQ .Return			;/

		.Process				;\ loop through every sprite
		LDY #$0F				;/
		..loop					;\ don't interact with itself
		CPY !SpriteIndex : BEQ ..next		;/
		LDA $3230,y				;\
		CMP #$08 : BCC ..next			; | only interact with sprites in states 8 and 9
		CMP #$0A : BCS ..next			;/
		PHX					;\
		TYX : JSL !GetSpriteClipping00		; |
		PLX
		JSL !Contact16 : BCC ..next

		..next
		DEY : BPL ..loop

		.Return
		RTL



; tweaker	1	->	always process
;		0	->	process if [frame & index & 1] = 1

; frame
; index












