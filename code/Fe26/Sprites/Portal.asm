

Portal:

	namespace Portal

	!PortalMode		= $C2,x			; number of allowed spawned sprites
	!PortalSpriteNum	= $3280,x		; spawned sprite number
	!PortalCustomSpriteNum	= $3290,x		; spawned sprite custom number
	!PortalExtraBits	= $32A0,x		; spawned sprite extra bits
	!PortalDelay		= $32B0,x		; amount to wait before spawning a new sprite
	!PortalTimer		= $32D0,x		; upon hitting 0, a sprite is spawned and this is set to !PortalWait
	!PortalIndexMem		= $32C0,x		; index of spawned sprite
	!PortalLeniency		= $32F0,x		; portal can not sink in lava so this is fine to use
							; this is set upon spawn and if this runs out, the portal disappears
	!PortalLoadIndex	= !SpriteVectorX,x	; (vectors are unused) keeps track of eaten sprite's index to load table
	!PortalSpawnState	= $35A0,x		; used to set some sprites to state 0x09
	!PortalProp1		= $35B0,x
	!PortalProp2		= $35D0,x


	INIT:
		PHB : PHK : PLB
		LDA !ExtraBits,x : BMI .Main
		ORA #$80 : STA !ExtraBits,x
		LDA #$0F : STA !PortalLeniency				; a sprite must be eaten within 15 frames
		LDA !ExtraProp1,x					;\
		DEC A							; | default wait time is 255 frames (4.25 seconds)
		STA !PortalDelay					;/

		.Main
		LDA !PortalLeniency : BNE .Search
		STZ $3230,x						; kill portal if timer runs out before eating a sprite
		PLB
		RTL

		.Search
		JSL !GetSpriteClipping04
		LDX #$0F
	-	CPX !SpriteIndex : BEQ .Next
		LDA $3230,x 
		CMP #$08 : BCC .Next
		JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC .Next

	.Eat	TXY
		LDX !SpriteIndex
		LDA $3230,y
		CMP #$08
		BNE $02 : LDA #$01
		STA !PortalSpawnState					; state of sprite
		LDA #$00 : STA $3230,y					; remove eaten sprite
		LDA $33F0,y : STA !PortalLoadIndex			; remember eaten sprite's load index
		LDA $3200,y : STA !PortalSpriteNum			;\
		LDA !NewSpriteNum,y : STA !PortalCustomSpriteNum	; |
		LDA !ExtraProp1,y : STA !PortalProp1			; | store data
		LDA !ExtraProp2,y : STA !PortalProp2			; |
		LDA !ExtraBits,y : STA !PortalExtraBits			;/
		LDA !PortalDelay					;\
		LSR A							; | first spawn at half delay
		STA !PortalTimer					;/
		BRA MAIN+3

	.Next	DEX : BPL -
		LDX !SpriteIndex
		LDA #$01 : STA $3230,x					; < reset init state until a sprite is eaten
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB

		JSL SPRITE_OFF_SCREEN					; off screen check
		LDA $3230,x : BNE .StillActive				; see if portal despawned
		PHX							;\
		LDA !PortalLoadIndex : TAX				; | mark eaten sprite for respawn
		LDA #$00 : STA $418A00,x				; |
		PLX							;/
		PLB
		RTL							; return right away to prevent a bastard sprite
		.StillActive

		LDA !SpriteXLo,x : PHA
		LDA !SpriteXHi,x : PHA
		LDA !SpriteYLo,x : PHA
		LDA !SpriteYHi,x : PHA

		LDA !PortalDelay
		DEC A : STA $00

		LDA !PortalTimer
		CMP $00 : BEQ +
		CMP #$20 : BCS +
		AND #$0F
		TAY
		REP #$20
		LDA .Offset+0,y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		SEP #$20
		CLC : ADC !SpriteYLo,x
		STA !SpriteYLo,x
		XBA
		ADC !SpriteYHi,x
		STA !SpriteYHi,x
		REP #$20
		LDA .Offset+4,y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		SEP #$20
		CLC : ADC !SpriteXLo,x
		STA !SpriteXLo,x
		XBA
		ADC !SpriteXHi,x
		STA !SpriteXHi,x
		+


		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_p0

		PLA : STA !SpriteYHi,x
		PLA : STA !SpriteYLo,x
		PLA : STA !SpriteXHi,x
		PLA : STA !SpriteXLo,x


		LDA !ExtraBits,x					;\ if extra bit is set, spawn endlessly
		AND #$04 : BNE .Main					;/
		LDY !PortalIndexMem : BEQ .Main				;\
		DEY							; |
		LDA $3230,y						; |
		CMP #$08 : BCC .SpriteDied				; | if extra bit is clear, check spawned sprite
		LDA $3200,y						; |
		CMP !PortalSpriteNum : BNE .SpriteDied			; |
		LDA !NewSpriteNum,y					; |
		CMP !PortalCustomSpriteNum : BNE .SpriteDied		;/
		LDA !PortalDelay : STA !PortalTimer			;\ if sprite is still alive, reset timer and return
		BRA .Return						;/

	.SpriteDied
		STZ !PortalIndexMem					; if sprite type has changed, portal is allowed to spawn a new one
									; this prevents a bug where a portal can become locked by an independent sprite spawning in its index mem slot

	.Main
		LDA !PortalTimer : BNE .Return
		JSL !GetSpriteSlot
		BMI .Return
		JSL SPRITE_A_SPRITE_B_COORDS				;\
		LDA !PortalSpriteNum : STA $3200,y			; |
		LDA !PortalCustomSpriteNum : STA !NewSpriteNum,y	; |
		LDA !PortalExtraBits : STA !ExtraBits,y			; |
		LDA #$01 : STA $3230,y					; |
		TYX							; | spawn sprite from portal
		JSL !ResetSprite					; |
		LDA !ExtraBits,x					; |
		AND #$08 : BEQ .Vanilla					; |
		JSL !ResetSpriteExtra					; |
		.Vanilla						;/

		TXA
		TXY
		LDX !SpriteIndex
		INC A
		STA !PortalIndexMem					; remember spawned sprite index
		LDA !PortalSpawnState : STA $3230,y			; set spawned sprite status
		LDA !PortalDelay : STA !PortalTimer			; reset timer



	.Return
		PLB
		RTL



	.Tilemap
		dw $0010
		db $32,$08,$F0,$20
		db $72,$F8,$F0,$20
		db $B2,$08,$00,$20
		db $F2,$F8,$00,$20

	.Offset
		db $F0,$10
		db $F5,$0B
	..cos	db $00,$00
		db $0B,$F5
		db $10,$F0
		db $0B,$F5
		db $00,$00
		db $F5,$0B
	..ext	db $F0,$10		; extended area for cosine
		db $F5,$0B





	namespace off




