
Chest:
	namespace Chest



	INIT:
		JSL GetItemMem : BNE .Fail

		.Success
		LDA !ExtraProp1,x : BNE +		;\ default number of coins: 20 (dec)
		LDA #20					;/
	+	CMP #$DF+1 : BCC +			;\ if number is too big, get a random number
		LDA !RNG				;/
	+	CMP #$DF				;\
		BCC $02 : LDA #$DF			; | cap at 223
		STA !ExtraProp1,x			;/
		LDA #$09 : STA $3230,x			; go into state 09
		LDA $00 : STA $3500,x			;\
		LDA $01 : STA $3510,x			; | store item mem data (index + bit)
		LDA $02 : STA $3520,x			;/
		RTL

		.Fail
		STZ $3230,x
		RTL

	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		CMP #$0B : BEQ +
		LDA #$09 : STA $3230,x
		BRA INTERACTION
		+
		JSR Open_Mem

	INTERACTION:
		LDA !P2Invinc-$80 : PHA
		LDA !P2Invinc : PHA
		LDA #$01
		STA !P2Invinc-$80
		STA !P2Invinc


		LDA $3290,x : BNE .Done
		LDA $3230,x
		CMP #$09 : BNE .Done

		.Interact
		JSL !GetSpriteClipping04

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		JSR Open
		BRA .Done
		..nocontact

		.Fireball
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		JSR Open
		..nocontact

		.Done
		PLA : STA !P2Invinc
		PLA : STA !P2Invinc-$80


; input:
;	A = particle num
;	$00 = X offset (8-bit signed)
;	$01 = Y offset (8-bit signed)
;	$02 = X speed (sprite format)
;	$03 = Y speed (sprite format)
;	$04 = X acc
;	$05 = Y acc
;	$06 = tile
;	$07 = prop (S-PPCCCT, S is size bit, PP is mirrored to top 2 bits for layer prio + OAM prio)
; output:
;	$0E = index to spawned particle
;	mirrors the PP bits of $07 to the upper 2 bits, but the rest of $00-$07 remain
	PHYSICS:
		LDA $3290,x : BNE .SpawnCoins

		.BreakMaybe
		LDA $3330,x
		BIT #$08 : BNE .Break
		AND #$03 : BEQ .Done
		LDA $3280,x
		CLC : ADC #$21
		CMP #$42 : BCC .Done

		.Break
		JSR Open
		LDA $3280,x
		AND #$80
		EOR #$80
		BEQ $02 : LDA #$10
		SEC : SBC #$08
		STA $00
		STZ $01
		LDA #$30 : STA $07
		LDA.b #!prt_contact : JSL SpawnParticle
		LDA #$02 : STA !SPC1

		.SpawnCoins
		LDA !ExtraProp1,x : BEQ .Done
		DEC !ExtraProp1,x
		LDA #$04
		STA $00
		STA $01
		LDA !RNG
		AND #$0F
		SBC #$08
		ADC !SpriteXSpeed,x
		STA $02
		LDA #$E0 : STA $03
		STZ $04
		LDA #$18 : STA $05
		STZ $06
		STZ $07
		LDA.b #!prt_tinycoin : JSL SpawnParticle
		.Done

		LDA !SpriteXSpeed,x : STA $3280,x


	GRAPHICS:
		LDA $3290,x : BEQ .Closed
		.Open
		LDA $3360,x : BNE ..exist
		..despawn
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		LDA $33F0,x : TAX
		LDA #$EE : STA !SpriteLoadStatus,x
		LDX !SpriteIndex
		PLB
		RTL
		..exist
		CMP #$20 : BCS ..noflash
		AND #$02 : BNE .Done
		..noflash
		REP #$20
		LDA.w #ANIM_OpenTM : BRA .Draw
		.Closed
		REP #$20
		LDA.w #ANIM_ClosedTM
		.Draw
		STA $04
		SEP #$20
		JSL SETUP_CARRIED
		JSL DRAW_CARRIED

		.Done

		PLB
		RTL


	ANIM:
	.OpenTM
		dw $0004
		db $02,$00,$00,$02

	.ClosedTM
		dw $0004
		db $02,$00,$00,$00



	Open:
		INC $3290,x				; set open state
		LDA !ExtraProp1,x			;\
		CLC : ADC #$20				; | start despawn timer
		STA $3360,x				;/


		.Mem
		LDA $3500,x : STA $00			;\
		LDA $3510,x : STA $01			; |
		LDA $3520,x : STA $02			; |
		LDA !HeaderItemMem			; |
		CMP #$03 : BCS ..nomem			; |
		REP #$10				; |
		LDX $00					; | mark item mem
		LDA $02					; |
		ORA !ItemMem0,x				; |
		STA !ItemMem0,x				; |
		SEP #$10				; |
		..nomem					; |
		LDX !SpriteIndex			;/

		RTS



	namespace off

