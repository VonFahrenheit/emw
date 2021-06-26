;=============;
;PLUMBER CARRY
;=============;


;;; CARRY ITEM CODE ;;;

	PLUMBER_CARRY:
		PHB : PHK : PLB
		DEX
		BIT $6DA3 : BVC .Throw
		JMP .Carry
	.Throw	STZ !P2Carry
		STZ !P2PickUp
		LDA $6DA3					;\
		AND #$0C : BEQ .Forward				; | kick if up/down are not held
		CMP #$0C : BEQ .Forward				;/
		LDY !P2Direction				; Y = index to tables
		CMP #$04 : BEQ .Drop

	.KickUp	LDA !P2XSpeed					;\
		CLC : ADC !P2VectorX				; | give item X speed
		STA !SpriteXSpeed,x				;/
		LDA #$08 : STA !P2KickTimer			; kick pose
		LDA #$03 : STA !SPC1				; kick sfx
		LDA .CarryOffsetX+0,y				;\
		LDY #$FC					; | contact GFX
		JSL CORE_ContactGFX_Long			;/
		LDA #$90					; item Y speed = -0x70
		BRA +						; go to shared code

	.Forward
		LDA !P2XSpeed					;\
		CLC : ADC !P2VectorX				; |
		STA !SpriteXSpeed,x				; | sprite speed = player speed (including vector)
		LDA !P2YSpeed					; |
		CLC : ADC !P2VectorY				; |
		STA !SpriteYSpeed,x				;/
		LDA #$08 : STA !P2KickTimer			; kick pose
		LDA #$03 : STA !SPC1				; kick sfx
		BRA ++						; go to shared code

	.Drop	LDA !P2XSpeed					;\
		CLC : ADC !P2VectorX				; | give item X speed
		CLC : ADC .ItemSpeed,y				; |
		STA !SpriteXSpeed,x				;/
		LDA #$08					; item Y speed = 8
	+	STA !SpriteYSpeed,x				; set Y speed
		LDA #$08					;\
		STA $32E0,x					; | item can't interact with players for 8 frames
		STA $35F0,x					;/
	++	LDA #$09 : STA $3230,x				; throw sprite (state = 09)
		STZ !SpriteStasis,x				; clear stasis from sprite
		PLB
		RTL

	.Carry	STZ $3400,x					; clear item's kill count
		LDA $3230,x					;\
		CMP #$0B : BEQ +				; |
		STZ !P2Carry					; | drop item if its state changes
		STZ !P2PickUp					; |
		PLB						; |
		RTL						;/

	+	LDA !CurrentPlayer				;\
		INC A						; | set shell owner
		STA $34F0,x					;/
		LDA #$02					;\
		STA !SpriteStasis,x				; | item can't move or interact with players
		STA $32E0,x					; |
		STA $35F0,x					;/
		LDY !P2Direction				;\
		LDA !P2XPosLo					; |
		CLC : ADC.w .CarryOffsetX+0,y			; |
		STA $3220,x					; | set item X coordinate
		LDA !P2XPosHi					; |
		ADC.w .CarryOffsetX+2,y				; |
		STA $3250,x					;/
		LDY #$00					;\
		LDA !P2HP					; |
		CMP #$01 : BEQ .Low				; | get height index
		LDA !P2Ducking : BNE .Low			; |
		LDA !P2PickUp : BEQ .High			; |
	.Low	INY						;/
	.High	LDA !P2YPosLo					;\
		SEC : SBC.w .CarryOffsetY,y			; |
		STA $3210,x					; | set item Y coordinate
		LDA !P2YPosHi					; |
		SBC #$00					; |
		STA $3240,x					;/
		STZ !P2KickTimer				; > clear kick image
		PLB
		RTL


		.CarryOffsetX
		db $F6,$0A
		db $FF,$00

		.CarryOffsetY
		db $04,$02

		.ItemSpeed
		db $F0,$10			; speed for dropping item with no kick






