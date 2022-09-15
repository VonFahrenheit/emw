


	; if sprite is placed on the ground, it won't move
	INIT:
		STZ !SpriteXSpeed,x
		LDA #$20 : STA !SpriteYSpeed,x
		JSL APPLY_SPEED
		LDA !SpriteBlocked,x
		AND #$04 : BEQ .Return
		INC $3280,x					; can't move flag
		.Return
		RTS



	MAIN:

	.Physics
		LDA $32D0,x : BEQ ..normal
		CMP #$01 : BNE ..rise
		JSL SUB_HORZ_POS
		TYA
		LDY !SpriteNum,x
		CPY #$76
		BNE $02 : EOR #$01				; star goes away from player, mushrooms go toward
		STA !SpriteDir,x
		..rise
		STZ !SpriteXSpeed,x
		LDA #$FC : STA !SpriteYSpeed,x
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		BRA ..done
		..normal
		LDA !SpriteNum,x
		CMP #$76 : BNE ..speed
		..star
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..speed
		LDA !SpriteTweaker5,x
		AND #$F8 : STA !SpriteYSpeed,x
		..speed
		LDA $3280,x : BNE ..move			; check "can't move" flag
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..move
		JSL APPLY_SPEED
		..done


	.Interaction
		LDA $32D0,x : BEQ ..process			; no interaction during emerge animation
		..fail
		JMP ..nocontact
		..process
		JSL GetSpriteClippingE8

		LDY.b #!Ex_Amount-1				;\
	-	LDA !Ex_Num,y					; |
		AND #$7F					; |
		CMP.b #!QuestionBlock_Num : BCC +		; |
		CMP.b #!BlockHitbox_Num+1 : BCS +		; |
		LDA !Ex_XLo,y : STA $E0				; |
		LDA !Ex_XHi,y : STA $E1				; |
		LDA !Ex_YLo,y : STA $E2				; | block bounce
		LDA !Ex_YHi,y : STA $E3				; |
		LDA #$08					; |
		STA $E4 : STZ $E5				; |
		STA $E6 : STZ $E7				; |
		JSL CheckContact : BCC +			; |
		LDA #$C0 : STA !SpriteYSpeed,x			; > bounce speed
		STZ $3280,x					; > can move again
		BRA ++						; |
	+	DEY : BPL -					; |
		++						;/

		LDA !SpriteDisP1,x : BNE ..fail			; only used with shop object
		JSL P2Attack : BCS ..eat
		JSL PlayerContact : BCC ..fail
		..getindex
		LDY #$00
		LSR A
		BCS $02 : LDY #$80
		..eat
		TYA
		AND #$80 : TAY
		STZ !SpriteStatus,x				; despawn

		LDA !SpriteNum,x
		CMP #$74 : BEQ ..redmushroom
		CMP #$76 : BEQ ..star
		CMP #$77 : BEQ ..greenmushroom
		CMP #$78 : BEQ ..goldmushroom


		..redmushroom
		LDA !P2TempHP-$80,y : BNE ..noheal		; no healing with temp HP
		LDA !P2HP					;\
		CLC : ADC #$04					; |
		CMP !P2MaxHP-$80,y : BCC +			; | heal 1 heart
		LDA !P2MaxHP-$80,y				; |
	+	STA !P2HP-$80,y					;/
		..noheal
		LDA #$0A : STA !SPC1				; mushroom SFX
		LDA #$14 : STA !P2FlashPal-$80,y		; white flash pal
		RTS

		..star
		LDA #$0A : STA !SPC1				; mushroom SFX
		LDA #$FF : STA !StarTimer			; star power
		RTS

		..goldmushroom
		LDA #$0A : STA !SPC1				; mushroom SFX
		PHY						;\
		REP #$20					; |
		STZ $00						; |
		STZ $04						; | spawn particle
		SEP #$20					; |
		LDA.b #!prt_text100 : JSL SpawnParticle		; |
		PLY						;/
		TYA : ROL A					; current player (0 or 1)
		PHX						;\
		REP #$10					; |
		LDX $0E						; | particle owner
		STA !41_Particle_Tile,x				; |
		SEP #$10					; |
		PLX						;/
		LDA #$B4 : BRA +				; gold flash pal
		..greenmushroom
		LDA #$0D : STA !SPC1				; cape sfx
		LDA #$04					;\
		CMP !P2TempHP-$80,y : BCC ..fullheal		; | give temp hp
		STA !P2TempHP-$80,y				;/
		LDA #$74					; green flash pal
	+	STA !P2FlashPal-$80,y				; set flash pal
		..fullheal
		LDA !P2MaxHP-$80,y : STA !P2HP-$80,y		; hp = max hp
		LDA !SpriteXSpeed,x : BNE ..nomem		; no item mem if moving version
		LDA !HeaderItemMem				;\
		CMP #$03 : BCS ..nomem				; |
		JSL GetItemMem					; |
		REP #$10					; |
		LDY $00						; | set item mem
		LDA $02						; |
		ORA !ItemMem0,y					; |
		STA !ItemMem0,y					; |
		SEP #$10					; |
		..nomem						;/
		RTS
		..nocontact


	.Graphics
		LDA $32D0,x
		CMP #$34 : BCS ..done
		LDA !SpriteNum,x
		CMP #$76 : BEQ ..star

		..mushroom
		REP #$20
		LDA.w #ANIM_Mushroom : STA $04
		SEP #$20
		JSL LOAD_TILEMAP_COLOR
		RTS

		..star
		LDA $14
		AND #$03 : TAY
		LDA DATA_StarPal,y : STA !SpriteOAMProp,x
		JSL DRAW_SIMPLE_0
		..done
		RTS

	ANIM:
		.Mushroom
		dw $0004
		db $22,$00,$00,$40


	DATA:
	.XSpeed
		db $10,$F0

	.StarPal
		db $04,$06,$04,$0C


