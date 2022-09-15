
	!TrayStatus	= $BE
	!PlayerCargo	= $3280
	!TotemCount	= $3290
	!TempTotem	= $32A0


GoombaSlave:

	namespace GoombaSlave

; !TrayStatus	Tray status
;		C--iiiii
;		C - cover
;		i - index of carried sprite + 1
;
; !PlayerCargo	player cargo flag
;

; extra bit = 0
;	no cover
;	can carry another sprite if it's placed 1 tile above
;	extra prop 1 = totem count (number of goombas stacked on top of this one, only the top goomba will have a tray)
;	extra prop 2 = 0 = top goomba has a tray, top goomba has no tray

; extra bit = 1
;	cover
;	extra prop 1 = custom bit of hidden sprite
;	extra prop 2 = sprite num of hidden sprite





	INIT:
		.SetCover
		LDA !ExtraBits,x					;\ check mode
		AND #$04 : BEQ ..done					;/
		LDA #$80 : STA !TrayStatus,x				; enable cover
		RTL
		..done

		LDA !ExtraProp1,x					;\
		CMP #$0F						; | totem count
		BCC $02 : LDA #$0F					; |
		STA !TotemCount,x					;/
		INC A : STA !SpriteHP,x					; HP


	; look for a sprite on top of this one
		.Totem
		LDY #$0F
		..loop
		LDA !SpriteXLo,x					;\ must have same X coord
		CMP !SpriteXLo,y : BNE ..next				;/
		LDA !SpriteYLo,x					;\
		SEC : SBC #$10						; | must be exactly 0x10 px above
		CMP !SpriteYLo,y : BEQ ..carry				;/
		..next
		DEY : BPL ..loop
		RTL
		..carry
		TYA
		INC A
		ORA #$40 : STA !TrayStatus,x				; set tray value
		LDA !SpriteTweaker6,x					;\ disable contact turn
		AND.b #$10^$FF : STA !SpriteTweaker6,x			;/
		RTL



	MAIN:
		PHB : PHK : PLB

		LDA !SpriteStatus,x
		CMP #$08 : BEQ .Process
		CMP #$02 : BEQ .Tumble
		JMP GRAPHICS

		.Tumble
		LDA !GFX_Goomba_tile : STA !SpriteTile,x
		LDA !GFX_Goomba_prop : STA !SpriteProp,x
		JSL DRAW_SIMPLE_0
		PLB
		RTL


		.Process


	PHYSICS:
		.Speed
		LDY !SpriteDir,x					;\
		LDA !SpriteAnimIndex,x					; |
		CMP #$04						; | x speed (walk slower with cargo)
		BCC $02 : INY #2					; |
		LDA.w DATA_XSpeed,y : STA !SpriteXSpeed,x		;/
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..move
		JSL GroundSpeed
		..move
		JSL APPLY_SPEED						; > apply speed


		.CheckCargo
		LDA !TrayStatus,x : BMI ..done				; can't carry if cover is on
		AND #$1F : BEQ ..done					;\ get cargo index
		DEC A : TAY						;/
		LDA !SpriteStatus,y					;\
		CMP #$01 : BEQ +					; | state must be 01 or 08+
		CMP #$08 : BCC ..letgo					;/
	+	LDA.w !SpriteYSpeed,y : BPL ..carry			; let carried sprite jump off with upwards speed
		..letgo							;\
		STZ !TrayStatus,x					; | release cargo
		BRA ..done						;/
		..carry
		LDA !SpriteDir,x : STA !SpriteDir,y			; face same direction
		LDA #$10 : STA.w !SpriteYSpeed,y			; down speed
		LDA #$02 : STA !SpriteStasis,y				; carried sprite has stasis
		LDA !SpriteDeltaX,x : STA !SpriteDeltaX,y		;\ also inherit delta
		LDA !SpriteDeltaY,x : STA !SpriteDeltaY,y		;/
		LDA !SpriteXLo,x : STA !SpriteXLo,y			;\
		LDA !SpriteXHi,x : STA !SpriteXHi,y			; |
		LDA !SpriteYLo,x					; |
		SEC : SBC #$0C						; | coords of carried sprite
		STA !SpriteYLo,y					; |
		LDA !SpriteYHi,x					; |
		SBC #$00						; |
		STA !SpriteYHi,y					;/
		..done							;



	INTERACTION:
		.Cover
		BIT !TrayStatus,x : BPL ..done				; see if cover exists
		REP #$20						;\ get cover hitbox
		LDA.w #DATA_HitboxCover : JSL LOAD_HITBOX		;/
		JSL P2Attack : BCS ..losecover				; check for hitbox contact
		JSL PlayerContact : BCC ..done				;\ bounce on cover
		JSL BouncePlayers					;/
		..losecover
		JSR DropTray						; drop cover
		LDA #$02 : STA !SPC1					; contact SFX
		STZ $00							;\
		LDA #$F0 : STA $01					; |
		CLC							; |
		LDA !ExtraProp1,x					; | spawn revealed sprite
		BEQ $01 : SEC						; |
		LDA !ExtraProp2,x					; |
		JSL SpawnSprite_NoSpeed					; |
		CPY #$FF : BEQ ..done					;/
		LDA #$20						;\
		STA !SpriteDisP1,y					; | don't let sprite be insta-gibbed
		STA !SpriteDisP2,y					;/
		STA !SpriteStasis,y					; hold in place
		TYA							;\
		INC A : STA !TrayStatus,x				; | carry sprite
		..done							;/


		.TotemAdjust
		STZ $2250						;\
		REP #$20						; |
		LDA !TotemCount,x					; |
		AND #$00FF : STA $2251					; |
		LDA #$000E : STA $2253					; |
		SEP #$20						; |
		LDA !SpriteYHi,x : PHA					; | adjust Y coord for totem
		LDA !SpriteYLo,x : PHA					; |
		SEC : SBC $2306						; |
		STA !SpriteYLo,x					; |
		LDA !SpriteYHi,x					; |
		SBC $2307						; |
		STA !SpriteYHi,x					;/

		LDA $2306 : PHA						; back up multiplication result


		.Tray
		STZ !PlayerCargo,x					; reset player cargo flags
		LDA !TotemCount,x					;\
		REP #$20						; |
		BNE ..totem						; |
		LDA.w #DATA_HitboxTray : BRA ..load			; |
		..totem							; | platform box
		LDA.w #DATA_HitboxTotemTray				; |
		..load							; |
		JSL LOAD_HITBOX						; |
		LDA #$04 : JSL OutputPlatformBox			;/
		JSL PlayerContact : BCC ..done				;\
		LSR A : BCC ..p2					; |
		..p1							; |
		XBA							; |
		LDA !P2YSpeed-$80 : BMI +				; |
		LDA !P2BlockedLayer-$80					; |
		AND #$04 : BNE +					; |
		LDA #$01 : STA !PlayerCargo,x				; | process player cargo
	+	XBA							; |
		..p2							; |
		LSR A : BCC ..done					; |
		LDA !P2YSpeed : BMI ..done				; |
		LDA !P2BlockedLayer					; |
		AND #$04 : BNE ..done					; |
		LDA !PlayerCargo,x					; |
		ORA #$02 : STA !PlayerCargo,x				; |
		..done							;/


		.Body
		JSL GetSpriteClippingE8					; get goomba body hitbox
		PLA							;\
		CLC : ADC $EE						; | adjust hitbox for totem
		STA $EE							;/
		JSL InteractAttacks : BCS ..hurt			; killed by any attack
		JSL PlayerContact : STA $00				;\
		LDA !PlayerCargo,x : TRB $00				; | only interact with players that are NOT carried
		LDA $00 : BNE ..interact				;/
		JMP ..done						;
		..interact
		LDY !StarTimer : BNE ..hurt				; hurt if touching a player with star power
		JSL HurtPlayers						;
		JMP ..done
		..hurt							;
		LDA !TotemCount,x : BEQ ..kill				; check for totem
		REP #$20						;\
		LDA $E2							; |
		CLC : ADC $E6						; |
		SEC : SBC $EA						; |
		SEP #$20						; |
		CMP $EE							; | calculate how many totem segments are hit
		BCC $02 : LDA $EE					; |
		LDY #$00						; > number of segments to dislodge
	-	INY							; |
		CMP #$0E : BCC ..breaktotem				; |
		SBC #$0E : BRA -					;/
		..breaktotem
		TYA : STA !TempTotem,x					; how many segments are dislodged (loop counter)
		LDA !RNG : STA $E0					;\
		LDA !SpriteXSpeed,x					; |
		CMP #$80 : ROR A					; |
		STA $E1							; |
		STZ $00							; |
		STZ $01							; | particle settings
		LDA #$D8 : STA $03					; |
		STZ $04							; |
		LDA #$30 : STA $05					; |
		LDA !GFX_Goomba_tile : STA $06				; |
		LDA !GFX_Goomba_prop					; |
		ORA #$F8 : STA $07					;/
	-	LDA !TotemCount,x : BEQ ..kill				; > die if all segments are dislodged
		LDA $E0							;\
		ROR $E0							; |
		AND #$18						; | reroll x speed
		SBC #$0C						; |
		ADC $E1							; |
		STA $02							;/
		LDA.b #!prt_basic : JSL SpawnParticle			; spawn particle
		DEC !TotemCount,x					; > 1 damage for each segment lost
		DEC !TempTotem,x : BEQ ..done				;\
		LDA $01							; |
		CLC : ADC #$0E						; | loop over entire totem
		STA $01							; |
		BRA -							;/
		..kill
		PLA : STA !SpriteYLo,x					;\ restore totem offset
		PLA : STA !SpriteYHi,x					;/
		LDA #$02 : STA !SpriteStatus,x				; state = fall
		JSR DropTray						; drop the tray itself
		JMP MAIN_Tumble						; go to tumble
		..done



	GRAPHICS:
		.DrawTray
		LDA !GFX_Tray_tile : STA !SpriteTile,x
		LDA !GFX_Tray_prop : STA !SpriteProp,x
		LDA !TotemCount,x : BNE ..light				; always light with totem
		LDA !TrayStatus,x
		REP #$20
		BMI ..full
		BNE ..heavy
		LDY !PlayerCargo,x : BNE ..heavy
		..light
		REP #$20
		LDA.w #ANIM_TrayLight : BRA ..draw
		..heavy
		LDA.w #ANIM_TrayHeavy : BRA ..draw
		..full
		LDA.w #ANIM_TrayFull
		..draw
		STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		PLA : STA !SpriteYLo,x					;\ restore totem offset
		PLA : STA !SpriteYHi,x					;/


		.ChangeAnim
		LDA !SpriteAnimIndex,x					;\ get c from comparison
		CMP #$04						;/
		LDA !TotemCount,x : BNE ..goomba			; always light with totem
		LDA !TrayStatus,x
		ORA !PlayerCargo,x
		BNE ..slave
		..goomba
		BCC ..done
		LDA #$00 : BRA ..setanim
		..slave
		BCS ..done
		LDA #$04
		..setanim
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..done


		.AnimateDraw
		REP #$20
		LDA.w #ANIM : JSL UPDATE_ANIM
		LDA !SpriteAnimIndex,x
		CMP #$04 : BCS ..slave
		..goomba
		LDA !GFX_Goomba_tile : STA !SpriteTile,x
		LDA !GFX_Goomba_prop : BRA ..draw
		..slave
		LDA !GFX_GoombaSlave_tile : STA !SpriteTile,x
		LDA !GFX_GoombaSlave_prop
		..draw
		STA !SpriteProp,x
		LDA !TotemCount,x : BNE ..totem
		..normal
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
		RTL

		..totem
		STA $00
		LDA !SpriteYHi,x : PHA
		LDA !SpriteYLo,x : PHA

		LDA $00
	-	PHA
		PEI ($04)
		JSL LOAD_PSUEDO_DYNAMIC
		PLA : STA $04
		PLA : STA $05
		LDA !SpriteYLo,x
		SEC : SBC #$0E
		STA !SpriteYLo,x
		LDA !SpriteYHi,x
		SBC #$00
		STA !SpriteYHi,x
		PLA : STA $00
		DEC A : BPL -

		PLA : STA !SpriteYLo,x
		PLA : STA !SpriteYHi,x
		PLB
		RTL



	DropTray:
		LDA #$F8 : STA $00					;\
		LDA #$F4 : STA $01					; |
		LDA !SpriteXSpeed,x					; |
		CMP #$80 : ROR A					; |
		STA $02							; |
		LDA #$D8 : STA $03					; |
		STZ $04							; |
		LDA #$18 : STA $05					; |
		LDA !GFX_Tray_tile					; | set up parameters for particles
		LDY !SpriteStatus,x					; |
		CPY #$02 : BNE +					; |
		CLC : ADC #$04						; |
		STZ $01							; |
	+	STA $06							; |
		LDA !GFX_Tray_prop					; |
		ORA #$F8 : STA $07					;/
		LDA.b #!prt_basic : JSL SpawnParticle			; spawn particle 1
		LDA #$08 : STA $00					;\
		INC $06							; | spawn particle 2
		INC $06							; |
		LDA.b #!prt_basic : JSL SpawnParticle			;/
		RTS




	DATA:
		.XSpeed
		db $10,$F0
		db $08,$F8

		.HitboxCover
		dw $FFFA,$FFF0 : db $1C,$0E

		.HitboxTray
		dw $FFFA,$0003 : db $1C,$08

		.HitboxTotemTray
		dw $FFFA,$FFFD : db $1C,$08


	ANIM:
	; walk
		dw .Walk00 : db $08,$01		; 00
		dw .Walk01 : db $08,$02		; 01
		dw .Walk00 : db $08,$03		; 02
		dw .Walk02 : db $08,$00		; 03
	; carry
		dw .Carry00 : db $0C,$05	; 04
		dw .Carry01 : db $0C,$04	; 05


		; goomba GFX
		.Walk00
		dw $0004
		db $22,$00,$00,$02

		.Walk01
		dw $0004
		db $22,$00,$00,$04

		.Walk02
		dw $0004
		db $22,$00,$00,$06


		; slave GFX
		.Carry00
		dw $0008
		db $22,$FC,$00,$00
		db $22,$04,$00,$01

		.Carry01
		dw $0008
		db $22,$FC,$00,$03
		db $22,$04,$00,$04


		; tray GFX
		.TrayLight
		dw $0008
		db $22,$F8,$FD,$04
		db $22,$08,$FD,$06

		.TrayHeavy
		dw $0008
		db $22,$F8,$03,$04
		db $22,$08,$03,$06

		.TrayFull
		dw $0010
		db $22,$F8,$F3,$00
		db $22,$08,$F3,$02
		db $22,$F8,$03,$04
		db $22,$08,$03,$06




	namespace off





