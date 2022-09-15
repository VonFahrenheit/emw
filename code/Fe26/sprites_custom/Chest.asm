
Chest:
	namespace Chest


; $BE		spew coin timer
; $3280		which player owns the coins (0 = p1, 80 = p2)
; $3290		state (0 = closed, 1 = open)



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
		LDA $00 : STA $3500,x			;\
		LDA $01 : STA $3510,x			; | store item mem data (index + bit)
		LDA $02 : STA $3520,x			;/
		RTL

		.Fail
		STZ !SpriteStatus,x
		RTL


	MAIN:
		PHB : PHK : PLB

		%decreg($BE)

		LDA !SpriteStatus,x
		CMP #$0B : BNE INTERACTION
		JSR Open_Mem
		BRA +


	INTERACTION:
		LDA #$09 : STA !SpriteStatus,x

	+	LDA $3290,x : BNE .Done
		LDA !SpriteStatus,x
		CMP #$09 : BNE .Done

		JSL GetSpriteClippingE8
		JSL P2Attack : BCS .Break
		JSL FireballContact_Destroy : BCC .Done
		.Break
		JSR Open

		.Done



	PHYSICS:
		JSL ITEM_PHYSICS
		LDA !SpriteBlocked,x
		AND #$04 : BEQ .NoSmoke
		LDA !SpriteXSpeed,x : BEQ .NoSmoke
		JSL FrictionSmoke
		.NoSmoke


		LDA $3290,x : BNE .SpawnCoins

		.BreakMaybe
		LDA !SpriteBlocked,x
		BIT #$0B : BEQ .Done

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
		LDA $BE,x : BNE ..exist
		..despawn
		LDA #$04 : STA !SpriteStatus,x
		LDA #$1F : STA $32D0,x
		LDA !SpriteID,x : TAX
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
		STA $BE,x				;/

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

