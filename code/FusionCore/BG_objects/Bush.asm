
	Bush:
		LDX $00						; X = BG object index

		LDA !BG_object_Timer,x				;\
		AND #$00FF					; | see which code to run
		STA.l !BigRAM					; > save this here for interaction check
		BNE .HandleAnimation				;/

		JSR CheckMovement : BCC .Return			;\
		SEP #$20					; |
		LDA #$0F : STA !BG_object_Timer,x		; | start animation if something touches the bush
		REP #$20					; |
		.Return						; |
		RTS						;/


		.HandleAnimation				;\
		..spawnparticle					; | check for particle spawn conditions
		JSR CheckMovement : BCC ..particledone		;/
		AND #$00FF					;\
		ASL #2						; |
		CMP #$0200					; | X speed of particle
		BCC $03 : ORA #$FC00				; |
		STA $04						;/
		LDA !BG_object_X,x : STA $00			;\
		LDA !BG_object_Y,x : STA $02			; |
		PHX						; |
		JSL GetParticleIndex				; > (returns with 16-bit A)
		LDA #$00FF : STA !Particle_Timer,x		; |
		LDA #$0008 : STA !Particle_YAcc,x		; |
		LDA.l !RNG					; |
		LSR #3						; |
		AND #$001F					; |
		CLC : ADC $00					; |
		STA !Particle_XLo,x				; |
		LDA $02 : STA !Particle_YLo,x			; |
		LDA.l !RNG					; | spawn leaf particle
		AND #$001F					; |
		ASL #3						; |
		SBC #$0080					; |
		CLC : ADC $04					; |
		STA !Particle_XSpeed,x				; |
		LDA.l !RNG					; |
		AND #$00FF					; |
		ORA #$FF00					; |
		STA !Particle_YSpeed,x				; |
		LDA.w #!prt_leaf : STA !Particle_Type,x		; |
		LDA.l !RNG					; |
		AND #$0040					; |
		ORA #$F000					; |
		STA !Particle_Tile,x				; |
		PLX						; |
		..particledone					; |
		..noparticles					;/


		LDA !VRAMbase+!TileUpdateTable			;\
		CMP #$00E0 : BCC .Valid				; | check if animation can be done
		RTS						;/

		.Valid						;\
		DEC !BG_object_Timer,x				; |
		PHX						; |
		LDA !BG_object_Timer,x				; |
		AND #$00FF : TAX				; |
		LDA.l .TileIndex,x				; | tile information
		AND #$00FF : TAX				; |
		LDA !BG_status,x				; |
		AND #$00FF					; |
		ORA #$3700					; > base prop
		STA $0E						; |
		LDA.w #.BushTilemap : STA $00			; |
		PLX						;/

		JMP TileUpdate


		.TileIndex
		db !GFX_BushFrame1_offset
		db !GFX_BushFrame1_offset
		db !GFX_BushFrame1_offset
		db !GFX_BushFrame1_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame3_offset
		db !GFX_BushFrame3_offset
		db !GFX_BushFrame3_offset
		db !GFX_BushFrame3_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset
		db !GFX_BushFrame2_offset


		.BushTilemap
		db $00,$01,$02,$03
		db $04,$05,$06,$07






