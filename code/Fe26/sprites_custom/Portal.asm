



	!PortalSpriteNum	= $3280		; spawned sprite number
	!PortalExtraBits	= $3290		; spawned sprite extra bits
	!PortalDelay		= $32A0		; amount to wait before spawning a new sprite
	!PortalTimer		= $32D0		; upon hitting 0, a sprite is spawned and this is set to !PortalWait

	!PortalIndexMem		= $3400		; index of spawned sprite
	!PortalLeniency		= $3410		; portal can not sink in lava so this is fine to use
							; this is set upon spawn and if this runs out, the portal disappears
	!PortalLoadIndex	= $3420		; (vectors are unused) keeps track of eaten sprite's index to load table
	!PortalSpawnState	= $3430		; used to set some sprites to state 0x09
	!PortalProp1		= $3440
	!PortalProp2		= $3450


Portal:

	namespace Portal

	DESPAWN:
		PHX							;\
		LDA !PortalLoadIndex,x : TAX				; | mark eaten sprite for respawn
		LDA #$00 : STA !SpriteLoadStatus,x			; |
		PLX							;/
		RTL							; return right away to prevent a bastard sprite


	INIT:
		LDA !ExtraBits,x					;\
		BIT #$20 : BNE .Main					; | extra bit 0x20 used for portal init
		ORA #$20 : STA !ExtraBits,x				;/
		LDA #$0F : STA !PortalLeniency,x				; a sprite must be eaten within 15 frames
		LDA !ExtraProp1,x					;\ default wait time is 255 frames (4.25 seconds)
		DEC A : STA !PortalDelay,x				;/

		.Main
		LDA !PortalLeniency,x : BNE .Search
		STZ !SpriteStatus,x					; kill portal if timer runs out before eating a sprite
		RTL

	.Search
		JSL GetSpriteClippingE8
		LDX #$0F
		..loop
		CPX !SpriteIndex : BEQ ..next
		LDA !SpriteStatus,x 
		CMP #$08 : BCC ..next
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next

		..eat
		TXY
		TYA
		ASL A
		TAX
		LDA !DynamicList,x					;\ dynamic sprites spawn in state 01
		ORA !DynamicList+1,x : BNE ..init			;/
		LDA !SpriteStatus,y
		CMP #$08 : BNE ..setstate
		..init
		LDA #$01
		..setstate
		LDX !SpriteIndex
		STA !PortalSpawnState,x					; state of sprite
		LDA #$00 : STA !SpriteStatus,y				; remove eaten sprite
		LDA !SpriteID,y : STA !PortalLoadIndex,x		; remember eaten sprite's load index
		LDA !SpriteNum,y : STA !PortalSpriteNum,x		;\
		LDA !ExtraProp1,y : STA !PortalProp1,x			; | store data
		LDA !ExtraProp2,y : STA !PortalProp2,x			; |
		LDA !ExtraBits,y : STA !PortalExtraBits,x		;/
		LDA !PortalDelay,x					;\
		LSR A							; | first spawn at half delay
		STA !PortalTimer,x					;/
		RTL

		..next
		DEX : BPL ..loop
		LDX !SpriteIndex
		LDA #$01 : STA !SpriteStatus,x				; < reset init state until a sprite is eaten
		RTL


	MAIN:
		PHB : PHK : PLB

		LDA !SpriteXLo,x : PHA
		LDA !SpriteXHi,x : PHA
		LDA !SpriteYLo,x : PHA
		LDA !SpriteYHi,x : PHA

		LDA !PortalDelay,x
		DEC A : STA $00

		LDA !PortalTimer,x
		CMP $00 : BEQ +
		CMP #$20 : BCS +
		ADC !RNG
		STA $0F
		AND #$0F
		ASL A
		SBC #$0F
		STA $02
		ADC #$04
		STA $00
		LDA $0F
		AND #$F0
		LSR #3
		SBC #$0F
		STA $01
		STA $03
		STZ $04
		LDA #$D0 : STA $05
		LDA #$30 : STA $07
		LDA.b #!prt_smoke8x8 : JSL SpawnParticle
		+


		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_p1

		PLA : STA !SpriteYHi,x
		PLA : STA !SpriteYLo,x
		PLA : STA !SpriteXHi,x
		PLA : STA !SpriteXLo,x


		LDA !ExtraBits,x					;\ if extra bit is set, spawn endlessly
		AND #$04 : BNE .Main					;/
		LDY !PortalIndexMem,x : BEQ .Main			;\
		DEY							; |
		LDA !SpriteStatus,y					; | if extra bit is clear, check spawned sprite
		CMP #$08 : BCC .SpriteDied				; |
		LDA !SpriteNum,y					; |
		CMP !PortalSpriteNum,x : BNE .SpriteDied		;/
		LDA !PortalDelay,x : STA !PortalTimer,x			;\ if sprite is still alive, reset timer and return
		BRA .Return						;/

	.SpriteDied
		STZ !PortalIndexMem,x					; if sprite type has changed, portal is allowed to spawn a new one
									; this prevents a bug where a portal can become locked by an independent sprite spawning in its index mem slot

	.Main
		LDA !PortalTimer,x : BNE .Return
		LDY #$0F
		..loop
		LDA !SpriteStatus,y : BEQ ..thisone
		DEY : BPL ..loop
		PLB
		RTL

		..thisone
		JSL SPRITE_A_SPRITE_B_COORDS				;\
		LDA !PortalSpriteNum,x : STA !SpriteNum,y		; |
		LDA !PortalExtraBits,x : STA !ExtraBits,y		; |
		LDA #$01 : STA !SpriteStatus,y				; |
		TYX							; | spawn sprite from portal
		JSL !ResetSprite					; |
		LDA !ExtraBits,x					; |
		AND.b #!CustomBit : BEQ .Vanilla			; |
		JSL SetSpriteTables					; |
		.Vanilla						;/

		TXA
		TXY
		LDX !SpriteIndex
		INC A
		STA !PortalIndexMem,x					; remember spawned sprite index
		LDA !PortalSpawnState,x : STA !SpriteStatus,y		; set spawned sprite status
		LDA !PortalDelay,x : STA !PortalTimer,x			; reset timer

		JSL BigPuff



	.Return
		PLB
		RTL



	.Tilemap
		dw $0010
		db $32,$F8,$F0,$00
		db $F2,$08,$F0,$02
		db $F2,$08,$00,$00
		db $32,$F8,$00,$02



	namespace off




