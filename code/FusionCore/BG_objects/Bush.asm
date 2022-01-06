
	Bush:
		LDX $00						; X = BG object index

		LDA !BG_object_Timer,x				;\
		AND #$00FF					; | see which code to run
		STA.l !BigRAM					; > save this here for interaction check
		BNE .HandleAnimation				;/

		JSR CheckInteract : BCC .Return			;\
		SEP #$20					; |
		LDA #$0F : STA !BG_object_Timer,x		; | start animation if something touches the bush
		REP #$20					; |
		.Return						; |
		RTS						;/


		.HandleAnimation				;\
		..spawnparticle					; | check for particle spawn conditions
		JSR CheckInteract : BCC ..particledone		;/
		AND #$00FF					;\
		ASL #2						; |
		CMP #$0200					; | X speed of particle
		BCC $03 : ORA #$FC00				; |
		STA $04						;/
		LDA !BG_object_X,x : STA $00			;\
		LDA !BG_object_Y,x : STA $02			; |
		PHX						; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
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
		AND #$00FF					; | get pointer to tile data
		ASL A						; |
		TAX						; |
		LDA.l .TilePointer,x : STA $00			; |
		PLX						;/

		STZ $0E						; palette included in tile table
		JMP TileUpdate


		.TilePointer
		dw .Bush0
		dw .Bush1
		dw .Bush2
		dw .Bush3
		dw .Bush4
		dw .Bush5
		dw .Bush6
		dw .Bush7
		dw .Bush8
		dw .Bush9
		dw .BushA
		dw .BushB
		dw .BushC
		dw .BushD
		dw .BushE
		dw .BushF


		.Bush0
		.Bush1
		.Bush2
		.Bush3
		dw $3400,$3401,$3402,$3403
		dw $3410,$3411,$3412,$3413
		.Bush4
		.Bush5
		.Bush6
		.Bush7
		dw $3404,$3405,$3406,$3407
		dw $3414,$3415,$3416,$3417
		.Bush8
		.Bush9
		.BushA
		.BushB
		dw $3408,$3409,$340A,$340B
		dw $3418,$3419,$341A,$341B
		.BushC
		.BushD
		.BushE
		.BushF
		dw $3404,$3405,$3406,$3407
		dw $3414,$3415,$3416,$3417






