SPRITE_OFF_SCREEN:
		STZ $3490,x
		STZ $3350,x
		LDA !RAM_ScreenMode
		LSR A
		LDA $3250,x
		BCC .HorizontalLevel

		.VerticalLevel
		BEQ .VertY
		DEC A : BEQ .VertY
		LDA $3220,x
		CMP #$F0 : BCS .VertY			; Can be up to 16px off the screen on the left
		INC $3350,x

		.VertY
		LDA $3240,x
		XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		CLC : ADC #$0060			;\ Used to be add 0x0040 compare to 0x0140
		CMP #$01C0				;/
		SEP #$20
		ROL A
		AND #$01
		STA $3490,x
		BRA .GoodY

<<<<<<< Updated upstream
=======
; input: void
; output: void
	APPLY_SPEED:
		LDA !SpriteStasis,x : BEQ .Process		;\
		RTL						; | return if stasis
		.Process					;/
		LDA !SpriteBlocked,x : STA $F4			; backup collision
	;	LDA !SpriteWater,x				;\ backup water flags (if no movement occurs, they stick to the next frame)
	;	AND #$60 : STA $0F				;/

		.VectorX					;\
		LDA !SpriteVectorTimeX,x : BEQ ..clear		; | check X vector
		DEC !SpriteVectorTimeX,x			; |
		BRA ..apply					;/
		..clear						;\
		STZ !SpriteVectorX,x				; | reset X vector
		STZ !SpriteVectorAccX,x				; |
		BRA ..done					;/
		..apply						;\
		LDA !SpriteXSpeed,x : PHA			; |
		LDA !SpriteVectorX,x : STA !SpriteXSpeed,x	; |
		CLC : ADC !SpriteVectorAccX,x			; | apply X vector
		STA !SpriteVectorX,x				; |
		JSL .X						; |
		PLA : STA !SpriteXSpeed,x			; |
		..done						;/

		.VectorY					;\
		LDA !SpriteVectorTimeY,x : BEQ ..clear		; | check Y vector
		DEC !SpriteVectorTimeY,x			; |
		BRA ..apply					;/
		..clear						;\
		STZ !SpriteVectorY,x				; | reset Y vector
		STZ !SpriteVectorAccY,x				; |
		BRA ..done					;/
		..apply						;\
		LDA !SpriteYSpeed,x : PHA			; |
		LDA !SpriteVectorY,x : STA !SpriteYSpeed,x	; |
		CLC : ADC !SpriteVectorAccY,x			; | apply Y vector
		STA !SpriteVectorY,x				; |
		JSL .Y						; |
		PLA : STA !SpriteYSpeed,x			; |
		..done						;/



		.SpeedY						;\ move Y
		%UpdateY()					;/
		LDA !SpriteFallSpeed,x				;\
		LSR #2 : STA $00				; |
		EOR #$FF : STA $01				; | gravity + fall speed checks + land/water check
		LDA !SpriteYSpeed,x				; |
		LDY !SpriteWater,x : BEQ ..land			;/
		LDY !SpriteFloat,x : BEQ ..land			; > if float = 0, ignore water resistance
		..water						;\
		CLC : ADC !SpriteFloat,x			; |
		BPL ++						; |
		CMP $01 : BCS +					; | fall speed checks under water
		LDA $01 : BRA +					; |
	++	CMP $00 : BCC +					; |
		LDA $00 : BRA +					;/
		..land						;\
		CLC : ADC !SpriteGravity,x			; |
		BMI +						; | fall speed checks on land
		CMP !SpriteFallSpeed,x : BCC +			; |
		LDA !SpriteFallSpeed,x				; |
	+	STA !SpriteYSpeed,x				;/

		.SpeedX						;\
		LDA !SpriteXSpeed,x : PHA			; | water check
		LDY !SpriteWater,x : BEQ ..update		;/
		LDY !SpriteFloat,x : BEQ ..update		; > if free swim is set (float = 0), sprite ignores water resistance
		..water						;\
		ASL A						; |
		ROR !SpriteXSpeed,x				; |
		LDA !SpriteXSpeed,x : STA $00			; |
		ASL A						; | 75% X speed in water
		ROR $00						; |
		LDA !SpriteXSpeed,x				; |
		CLC : ADC $00					; |
		STA !SpriteXSpeed,x				;/
		..update					;\ apply X speed
		%UpdateX()					;/
		PLA : STA !SpriteXSpeed,x			; restore

		JMP SPRITE_INTERACTION


		.X
		LDA !SpriteStasis,x : BNE ..return
		..ignorestasis
		%UpdateX()
		..return
		RTL
>>>>>>> Stashed changes

		.HorizontalLevel
		XBA
		BIT !CameraBoxU+1 : BPL .GoodX
		LDA $3470,x
		AND #$04 : BNE .GoodX
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC #$0060
		CMP #$01C0
		SEP #$20
		ROL A
		AND #$01
		STA $3350,x

		.GoodX
		LDA $6BF4
		AND #$03
		ASL A
		TAY
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		BIT !CameraBoxU : BMI .NoBoxY
		CMP !CameraBoxU : BCC .NoBoxY
		SBC #$00E0
		BMI .GoodY
		CMP !CameraBoxD : BCC .GoodY

		.NoBoxY
		CMP !LevelHeight : BCS .OutOfBoundsY

<<<<<<< Updated upstream
		STA $00
		LDA $1C
		CLC : ADC.w InitSpriteEngine_min_y_range,y
		CMP $00 : BPL .OutOfBoundsY
		LDA $1C
		CLC : ADC.w InitSpriteEngine_max_y_range,y
		CMP $00 : BPL .GoodY


;		SEC : SBC $1C
;		BPL +
;		EOR #$FFFF
;		LDY #$00
;		BRA ++
;	+	LDY #$02
;	++	CMP.w .YBounds,y
;		SEP #$20
;		BCC .GoodY

		.OutOfBoundsY
		SEP #$20
		INC $3490,x
=======
	SPRITE_INTERACTION:
		.ContactTurn
		BIT !SpriteTweaker2,x : BVS .Return
		LDA !SpriteDisSprite,x : BNE .Return
		LDA !SpriteTweaker6,x
		AND #$20 : BEQ ..done
		JSL GetSpriteClippingE8

		LDA !SpriteTweaker3,x				;\
		AND #$01 : BNE ..process			; |
		TXA						; | unless "process interaction every frame" is set...
		EOR $14						; | ...only process when sprite index = frame counter (lowest bits only)
		LSR A : BCS ..done				;/

		..process
		LDX #$0F
	-	CPX !SpriteIndex : BEQ ..done
		LDA !SpriteStatus,x
		CMP #$08 : BEQ +
		CMP #$09 : BNE ..next
	+	BIT !SpriteTweaker2,x : BVS ..next
		LDA !SpriteDisSprite,x : BNE ..next
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC ..next

		LDA !SpriteTweaker6,x				;\ check if touched sprite should also turn
		AND #$20 : STA $00				;/
		REP #$20					;\
		LDA $E4						; |
		LSR A						; |
		ADC $E0						; |
		STA $E0						; |
		LDA $EC						; | get turn directions
		LSR A						; |
		ADC $E8						; |
		CMP $E0						; |
		SEP #$20					; |
		LDA #$00					; |
		BCC $01 : INC A					;/
		LDY $00 : BEQ +					;\ turn touched sprite
		STA !SpriteDir,x				;/
	+	LDX !SpriteIndex				;\ turn sprite
		EOR #$01 : STA !SpriteDir,x			;/
		BRA ..done					; > done
		..next
		DEX : BPL -
		..done
>>>>>>> Stashed changes

		.GoodY
		SEP #$20
		LDA $3350,x
		ORA $3490,x
		BEQ .Return
		LDA !SpriteTweaker4,x
		AND #$04 : BNE .Return

		LDA $3230,x
		CMP #$08 : BCC .Kill
		LDY $33F0,x
		CPY #$FF : BEQ .Kill
		PHX
		TYX
		LDA $418A00,x			;\ 0xEE means don't respawn ever
		CMP #$EE : BEQ +		;/
		LDA #$00			;\ Respawn
		STA $418A00,x			;/
	+	PLX

<<<<<<< Updated upstream
		.Kill
		STZ $3230,x

		.Return
=======
		.Return
		; flow into OBJECT_INTERACTION



; $00 - max X coord of level
; $02 - max Y coord of level
; $04 - scratch, used to calculate map16 index
;	during block processing, $04 is the sprite to spawn from a block
;	during block processing, $05 is a multiplayer flag for spawning multiple items from blocks
; $06 - 24-bit pointer to map16 acts like table 00
; $09 - 24-bit pointer to map16 acts like table 40
; $0C - map16 acts like
; $0E - layer (0 = layer 1, 80 = layer 2)
; $0F - collision this frame
;	01 - right
;	02 - left
;	04 - down
;	08 - up
;	10 - 
;	20 - 
;	40 - 
;	80 - touching layer 2 flag
;
; $0A and $0C also used during liquid splash processing
; $0A - size flag
; $0C - loop counter for block search
;
; $F0 - previous X coord of sprite
; $F2 - previous Y coord of sprite
; $F4 - previous collision status (read only)
; $F5 - horizontal pushout value (8-bit)
; $F6 - vertical pushout value (16-bit)
; $F8 - slope data pointer (24-bit)
; $FB - constructing liquid contact points
;	01 - right
;	02 - left
;	04 - down
;	08 - up
;	10 - lava flag
; $FC - used during liquid splash processing (keeps track of sprite X / x offset per block)
; $FE - used during liquid splash processing (keeps track of sprite Y / y offset per block)


	OBJECT_INTERACTION:

STZ $7FFF
		BIT !SpriteTweaker1,x : BMI .Phase		;\
		LDA !SpritePhaseTimer,x : BEQ .Process		; |
		DEC !SpritePhaseTimer,x				; | return if object interaction is disabled
		.Phase						; |
		STZ !SpriteBlocked,x				; |
		RTL						;/

		.Process
		PHB : PHK : PLB					; bank wrapper start
		LDA #$F0 : STA $00				;\
		LDA !Map16Width					; | max X coord
		DEC A : STA $01					;/
		REP #$20					;\
		LDA !Map16ActsLike+0 : STA $06			; |
		LDA !Map16ActsLike+1 : STA $07			; | 24-bit pointers to map16 acts like tables
		LDA !Map16ActsLike40+0 : STA $09		; |
		LDA !Map16ActsLike40+1 : STA $0A		;/
		LDA !LevelHeight				;\
		SEC : SBC #$0010				; | max Y coord
		STA $02						; |
		SEP #$20					;/



		STZ !SpriteBlocked,x				; clear collision reg
		STZ !SpriteSlope,x				; clear slope
		STZ $0E						; layer (0 = layer 1, 80 = layer 2)
		STZ $0F						; clear collision (this frame)
		STZ $FB						; clear liquid (this frame)
		STZ !CurrentLayer				; layer 1
		JSR .InteractLayer
		LDA !SpriteExtraCollision,x : TSB $0F
		STZ !SpriteExtraCollision,x


		.Ground
		LDA $0F
		AND #$04 : BEQ ..done
		AND $F4 : BEQ ..done				; skip on landing frame, so sprites can read their landing Y speed
		LDA !SpriteYSpeed,x : BMI ..done
		CMP #$10 : BCC ..done
		LDA #$10 : STA !SpriteYSpeed,x
		..done

		.Ledge
		LDA $F4						;\
		AND #$04 : BEQ ..done				; | check for ledge
		AND $0F : BNE ..done				;/
		BIT !SpriteTweaker6,x				;\ check ledge behavior
		BVS ..restoreX					;/
		BPL ..done					; 00 = ignore ledge
		LDA !SpriteTweaker5,x				;\
		AND #$F8 : STA !SpriteYSpeed,x			; | 80 = jump
		BRA ..restoreY					;/
		..restoreX					;\
		BMI ..noturn					; |
		LDA !SpriteDir,x				; | 40 = turn
		EOR #$01 : STA !SpriteDir,x			; |
		..noturn					;/
		LDA $F0 : STA !SpriteXLo,x			;\
		LDA $F1 : STA !SpriteXHi,x			; |
		STZ !SpriteXSpeed,x				; |
		..restoreY					; | C0 = stop, but don't turn
		LDA $F2 : STA !SpriteYLo,x			; |
		LDA $F3 : STA !SpriteYHi,x			; |
		..done						;/

		.Wall
		LDA $0F						;\ check for wall
		AND #$03 : BEQ ..done				;/
		LDA !SpriteTweaker6,x				; check wall behavior
		LSR A : BCS ..restoreX				; 01 / 03 = turn away
		LSR A : BCC ..collide				; 00 = just collide
		LSR A : BCS ..jump				; > if 04 bit is set, can "jump" even in midair, effectively climbing
		LDA $0F						;\
		AND #$04 : BEQ ..collide			; |
		..jump						; | 02 = jump
		LDA !SpriteTweaker5,x				; | (must be on ground to be able to jump, unless climb is enabled)
		AND #$F8 : STA !SpriteYSpeed,x			; |
		BRA ..collide					;/
		..restoreX					;\
		LSR A : BCC ..noinvert				; |
		LDA !SpriteXSpeed,x				; | 03 = turn + invert speed
		EOR #$FF : INC A				; |
		STA !SpriteXSpeed,x				;/
		..noinvert					;\
		LDA $0F						; |
		AND #$03					; | 01 = turn but don't change speed
		DEC A						; |
		EOR #$01 : STA !SpriteDir,x			;/
		..collide					;\
		LDA !SpriteXLo,x				; |
		AND #$F0					; |
		ORA #$0F					; |
		SEC : SBC $F5					; | horizontal pushout
		STA !SpriteXLo,x				; |
		LDA !SpriteXHi,x				; |
		SBC #$00					; |
		STA !SpriteXHi,x				; |
		..done						;/

		.UpdateReg
		LDA $0F : STA !SpriteBlocked,x			; update collision reg
		LDA !BuoyancySettings : BNE .LiquidSplash	; no liquids if bouyancy is off

		.Return
		PLB
		RTL


	.LiquidSplash
		LDA $FB
		BIT #$10 : BEQ ..checksplash			; if no lava, handle splash
		LDA !SpriteTweaker1,x				;\
		LSR A : BCC ..sinkinlava			; | if sprite can survive lava, handle splash
		..surviveinlava					; |
		BRA ..checksplash				;/
		..sinkinlava					;\ if sprite can't survive in lava, it sinks
		LDA #$05 : STA !SpriteStatus,x			;/ (but it can still make a splash)

; splash flowchart:
; - check current submerge
;	-> full
;		- if prev not full, splash at last point (prioritize U -> L/R -> D)
;		- if prev full, no splash
;	-> partial
;		- if prev 0, splash at first point (prioritize D -> L/R -> U)
;		- if prev partial, run a speed check based on size
;		- if prev full, splash at last point (prioritize U -> L/R -> D)
;	-> 0
;		- if prev 0, no splash
;		- if prev not 0, splash at last point (prioritize U -> L/R -> D)
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; STILL NEEDS
;	- whether to check for air or liquid during block search
;	- how to handle exceptions (no surface found)
;	- how to handle seekless points (auto-1-block)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		..checksplash
		LDA !SpriteTweaker1,x				;\ check if splash is enabled
		AND #$02 : BNE ..done				;/
		LDA !SpriteTweaker4,x				;\ Y = sprite size
		AND #$07 : TAY					;/
		CMP #$05					;\
		BCS $02 : LDA #$00				; | initial size flag: 0-4 -> small, 5-7 -> big
		STA $0A						;/
		LDA $FB : BEQ ..liquid0				; if no liquid contact, go to 0
		AND #$0F					;\ if fully submerged, go to full
		CMP #$0F : BEQ ..liquidfull			;/

		..liquidpartial					; otherwise flow into partial
		LDA !SpriteWater,x				;\
		AND #$0F : BEQ ..partialtransitionsplash	; | going into partial from full or 0
		CMP #$0F : BEQ ..partialtransitionsplash	;/
		LDA !SpriteDeltaX,x				;\
		BPL $03 : EOR #$FF : INC A			; | compare movement to thresholds (indexed by size)
		CMP .SplashThresholdSmall,y : BCC ..done	; |
		CMP .SplashThresholdLarge,y : BCS ..bigsplash	;/
		..smallsplash
		STZ $0A : BRA ..movementsplash
		..bigsplash
		INC $0A
		..movementsplash
		LDA #$0F					; flow into inverted partial (make splash at any point not in liquid, usually U)

		; see this is actually really smart
		; if going 0 -> partial, $FB is taken raw and a splash will be made at the first point to submerge
		; if going full -> partial, $FB is inverted and a splash will be made at the first point to emerge
		..partialtransitionsplash
		EOR $FB : BRA ..pointsplash
		; make splash at point (prioritize based on what's in or NOT in $FB depending on change)

		..liquidfull
		LDA !SpriteWater,x
		AND #$0F
		EOR #$0F : BEQ ..done
		BRA ..pointsplash
		; make splash at point (prioritize based on what's NOT in !SpriteWater)

		..liquid0
		LDA !SpriteWater,x
		AND #$0F : BNE ..pointsplash
		; make splash at point (prioritize based on what's in !SpriteWater)

		..done
		LDA $FB : STA !SpriteWater,x
		PLB
		RTL


		; input: A = points eligible for splash
		; method is to take a point and find the first liquid/non-liquid tile border between that point on a straight line towards the sprite's center
		; so for R, search left, for L, search right, and so on
		; for small sprites (use a lookup table indexed by object clipping) just go to the first border instead of searching
		..pointsplash
STZ $7FFF
		XBA
		LDA !SpriteTweaker1,x
		AND #$0F*4 : TAY
		XBA
		BIT #$04 : BNE ..d
		BIT #$08 : BNE ..u				; a little inefficient for the sake of point priority
		LSR A : BCS ..r					;
		BRA ..l
	..u	INY
	..d	INY
	..l	INY
	..r	LDA .CollisionLookup,y				; do something with this

		; search version
		LDA !SpriteXLo,x : STA $9A
		LDA !SpriteXHi,x : STA $9A+1
		LDA !SpriteYLo,x : STA $98
		LDA !SpriteYHi,x : STA $98+1
		REP #$20
		LDA SpriteObjectClippingX,y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $9A
		STA $9A
		LDA SpriteObjectClippingY,y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $98
		STA $98
		TYA						;\
		AND #$0003					; | Y = direction index (dir * 2)
		ASL A : TAY					;/
		LDA .DirectionOffsetX,y : STA $FC		;\ direction offsets
		LDA .DirectionOffsetY,y : STA $FE		;/
		LDA #$0003 : STA $0C				; max number of tiles that can be checked

		..search
		JSL GetMap16_Tile				; will accept 16-bit A input
		CMP #$0005+1 : BCC ..foundborder
		LDA $9A
		CLC : ADC $FC
		STA $9A
		LDA $98
		CLC : ADC $FE
		STA $98
		; need a way to break this loop if no border is found within 3 tiles or so
		DEC $0C : BNE ..search
		SEP #$20
		JMP ..done

		..foundborder
		; $00 - particle num
		; $02 - particle x speed
		; $04 - particle y speed
		; $98 - particle Y coord
		; $9A - particle X coord
		LDA !RNG
		AND #$000F
		ASL #4
		SBC #$007F
		STA $00
		LDA !RNG
		AND #$000F
		SEC : SBC #$0008				; repeating this is faster
		CLC : ADC $9A
		STA $9A
		LDA !RNG
		AND #$00F0
		ORA #$FE00
		STA $02
		LDA !SpriteTweaker4-1,x
		AND #$0700 : STA $04
		LDA $FB
		ORA !SpriteWater,x
		AND #$0010 : BEQ ..water
		..lava
		INC $04
		..water
		PHB
		PHX
		JSL GetParticleIndex
		LDA.w #!prt_splash : STA !Particle_Type,x
		LDA $9A : STA !Particle_X,x
		LDA $98 : STA !Particle_Y,x
		STZ !Particle_XAcc,x
		LDA #$0018 : STA !Particle_YAcc,x
		LDA $00 : STA !Particle_XSpeed,x
		LDA $02 : STA !Particle_YSpeed,x
		LDA $04 : STA !Particle_Tile,x
		STZ !Particle_Layer,x
		LDA #$000F : STA !Particle_Timer,x

		..splashdone
		SEP #$30
		PLX
		PLB

		JMP ..done








	; delta threshold for generating splashes, indexed by size
	.SplashThresholdSmall
		db $FF,$03,$02,$02,$01,$01,$01,$01

	.SplashThresholdLarge
		db $FF,$FF,$05,$05,$04,$03,$02,$01


	; which points require searching
	; 0 = always take first tile border
	; 1 = search for liquid border
	.CollisionLookup
		db $00,$00,$00,$00					; 0
		db $00,$00,$00,$00					; 1
		db $00,$00,$00,$00					; 2
		db $00,$00,$00,$00					; 3
		db $00,$00,$00,$00					; 4
		db $00,$00,$00,$00					; 5
		db $00,$00,$00,$00					; 6
		db $00,$00,$00,$00					; 7
		db $00,$00,$00,$00					; 8
		db $00,$00,$00,$00					; 9
		db $00,$00,$00,$00					; A
		db $00,$00,$00,$00					; B
		db $00,$00,$00,$00					; C
		db $00,$00,$00,$00					; D
		db $00,$00,$00,$00					; E
		db $00,$00,$00,$00					; F



	.DirectionOffsetY
		dw $0000,$0000
	.DirectionOffsetX
		dw $FFF0,$0010,$0000,$0000



	.InteractionBits
		db $01,$02,$04,$08




	.InteractLayer
		LDA $0E : BEQ ..go				;\
		..layer2					; |
		LDA !BuoyancySettings				; | return if trying to interact with layer 2 while it's disabled
		ORA !SpriteTweaker1,x				; |
		AND #$40 : BEQ ..go				; |
		RTS						;/
		..go						;\
		LDY #$02					; |
		BIT !SpriteDeltaY,x				; | get tile for vertical interaction
		BPL $01 : INY					; |
		JSR .GetTile					;/
		BCS ..noliquids					;\
		CMP #$04					; |
		LDA !BuoyancySettings : BEQ ..noliquids		; > no liquids if buoyancy is off
		LDA .InteractionBits,y				; |
		BCC ..water					; | mark water/lava
		..lava						; |
		ORA #$10					; |
		..water						; |
		STA $FB						; |
		..noliquids					;/
		JSR .InteractVert				; interact with tile



		LDA !SpriteStatus,x				;\
		CMP #$09 : BEQ .UnStuck				; | check if sprite should use unstuck code
		CMP #$0A : BNE .SideCollision			;/
		.UnStuck					;\
		LDA !SpriteXSpeed,x : BNE .SideCollision	; | unstuck code (alternate left/right interaction)
		; also branch if turning around??
		LDA $14 : BRA +					;/

		.SideCollision
		LDA !SpriteDeltaX,x : BEQ ..done		; done if no X movement
		ASL A						;\
		ROL A						; | get tile for horizontal interaction
	+	AND #$01 : TAY					; |
		JSR .GetTile					;/
		BCS ..noliquids					;\
		CMP #$04					; |
		LDA !BuoyancySettings : BEQ ..noliquids		; > no liquids if buoyancy is off
		TYA : INC A					; |
		BCC ..water					; | mark water/lava
		..lava						; |
		ORA #$10					; |
		..water						; |
		TSB $FB						; |
		..noliquids					;/
		LDA $0D : BEQ ..done				; ignore tiles on page 0
		LDA $0C						;\
		CMP #$11 : BCC ..done				; | only interact with tiles 0x0111-0x016D
		CMP #$6E : BCS ..done				;/
		TYA						;\
		INC A						; | set block status
		ORA $0E						; |
		TSB $0F						;/
		..done


		; extra liquid checks here
		; check all 4 points here, except the 0-2 that have already been checked
		.LiquidChecks
	LDA $F5 : PHA
	LDA $F7 : PHA
		..checkvert
		LDA !SpriteDeltaY,x : BMI ..checkdown
		..checkup
		LDY #$03 : JSR .GetTile : BCS ..nextvert
		CMP #$04
		LDA #$08
		BCC $02 : ORA #$10
		TSB $FB
		..nextvert
		LDA !SpriteDeltaY,x : BEQ ..checkdown
		BPL ..checkhorz
		..checkdown
		LDY #$02 : JSR .GetTile : BCS ..checkhorz
		CMP #$04
		LDA #$04
		BCC $02 : ORA #$10
		TSB $FB

		..checkhorz
		LDA !SpriteDeltaX,x : BMI ..checkright
		..checkleft
		LDA !SpriteTweaker1,x
		LDY #$01 : JSR .GetTile : BCS ..nexthorz
		CMP #$04
		LDA #$02
		BCC $02 : ORA #$10
		TSB $FB
		..nexthorz
		LDA !SpriteDeltaY,x : BEQ ..checkright
		BPL ..done
		..checkright
		LDY #$00 : JSR .GetTile : BCS ..done
		CMP #$04
		LDA #$01
		BCC $02 : ORA #$10
		TSB $FB
		..done
	PLA : STA $F7
	PLA : STA $F5


		LDA !SpriteStatus,x				;\
		CMP #$0A : BNE ..return				; | interact with tile if kicked
		JSR ITEM_INTERACT_OBJECT			;/

		..return
		RTS



	.GetTile
		PHY						; push Y
		STY $04						;\
		LDA !SpriteTweaker1,x				; |
		AND #$0F*4					; | Y = index to coords
		CLC : ADC $04					; |
		TAY						;/

		BIT #$02 : BNE ..vert				; check direction
		..horz						;\
		LSR A						; |
		LDA SpriteObjectClippingX,y			; | horizontal pushout value
		BCC $01 : DEC A					; |
		STA $F5						; |
		BRA ..process					;/
		..vert						;\
		LDA SpriteObjectClippingY,y : STA $F6		; | vertical pushout value
		STZ $F7						;/

		..process					;
		PHX						; push X

		LDA !SpriteXLo,x : STA $9A			;\
		LDA !SpriteXHi,x : STA $9B			; | sprite coords
		LDA !SpriteYLo,x : STA $98			; |
		LDA !SpriteYHi,x : STA $99			;/

		REP #$30					; all regs 16-bit
		LDA SpriteObjectClippingY,y			;\
		AND #$00FF					; |
		CLC : ADC $98					; |
		BPL +						; | Y coord of point (snap to within bounds)
		LDA #$0000 : BRA ++				; |
	+	CMP $02 : BCC ++				; |
		LDA $02						; |
	++	STA $98						;/

		LDA !3DWater					;\
		AND #$00FF : BEQ +				; |
		LDA $98						; |
		CMP !Level+2 : BCC +				; |
		LDA $04						; | check for 3D water (x is free here)
		AND #$00FF : TAX				; |
		LDA .InteractionBits,x				; |
		AND #$00FF : TSB $FB				; > liquid contact
		+						;/

		LDA SpriteObjectClippingX,y			;\
		AND #$00FF					; |
		CLC : ADC $9A					; |
		BPL +						; | X coord of point (snap to within bounds)
		LDA #$0000 : BRA ++				; |
	+	CMP $00 : BCC ++				; |
		LDA $00						; |
	++	STA $9A						;/

		STZ $2250					;\
		XBA						; | x screen * level height = based address of column
		AND #$00FF : STA $2251				; |
		LDA !LevelHeight : STA $2253			;/
		LDA $9A						;\
		LSR #4						; |
		AND #$000F : STA $04				; | position within column
		LDA $98						; |
		AND #$FFF0					; |
		ORA $04						;/
		CLC : ADC $2306					; add to get full index
		TAX						;\
		SEP #$20					; |
		LDA $41C800,x : XBA				; |
		LDA $40C800,x					; |
		REP #$20					; |
		ASL A : TAY					; | get acts like
		BMI ..40					; |
	..00	LDA [$06],y : BRA ..store			; |
	..40	LDA [$09],y					; |
		..store						; |
		STA $0C						;/
		CMP #$0005+1					; > water/lava check (maintain C)

		SEP #$30					; all regs 8-bit
		PLX						; restore X
		PLY						; restore Y
		RTS						; return


	.InteractVert
		LDA $0D : BEQ .Floor_return			; return if page 0
		LDA $0C						; A = lo byte of acts like
		CPY #$02 : BEQ .Floor				; check whether floor/ceiling should be checked

		.Ceiling
		CMP #$11 : BCC .Floor_return			;\
		CMP #$6E : BCC ..interact			; | check for ceiling tiles
		CMP $7430 : BCC .Floor_return			; |
		CMP $7431 : BCS .Floor_return			;/
		..interact					;\
		LDA $98						; |
		AND #$F0					; |
		ORA #$0F					; |
		SEC : SBC $F6					; | push sprite below ceiling
		STA !SpriteYLo,x				; |
		LDA $99						; |
		SBC $F7						; |
		STA !SpriteYHi,x				;/
		LDA #$08 : TSB $0F				; set ceiling collision

		LDA !SpriteStatus,x				;\
		CMP #$09 : BCC .Floor_return			; | interact with tiles if thrown/kicked
		CMP #$0B : BCS .Floor_return			; |
		JMP ITEM_INTERACT_OBJECT			;/


		.Floor
		LDA $0C						;\
		CMP #$59 : BCC ..checksolid			; |
		CMP #$5C : BCS ..checksolid			; | check for lava/mud
		LDY !HeaderTileset				; |
		CPY #$0E : BEQ +				; |
		CPY #$03 : BNE ..checksolid			;/
	+	LDA #$30 : TSB $0F				; set lava flag
		..return
		RTS						; return

		..platform
		LDA $98
		AND #$0F
		CMP #$05 : BCS ..return
		..solid
		LDA !SpriteStatus,x
		CMP #$02 : BEQ ..return
		CMP #$05 : BEQ ..return
		CMP #$0B : BEQ ..return
		LDA $98						;\
		AND #$F0					; |
		SEC : SBC $F6					; |
		STA !SpriteYLo,x				; | push sprite on top of floor tile
		LDA $99						; |
		SBC $F7						; |
		STA !SpriteYHi,x				;/
		LDA #$04 : TSB $0F				; set floor collision
		RTS

		..checksolid
		CMP #$11 : BCC ..platform			; 0x100-0x110 = platform tile
		CMP #$6E : BCC ..solid				; 0x111-0x16D = solid
		CMP #$D8 : BCS ..slopeassist			; 0x1D8-0x1FF = slope assist tile

		..slope						; 0x16E-0x1D7 = check slope
		LDY #$32 : STY $F8				;\
		LDY #$E6 : STY $F9				; | $F8 = 24-bit pointer to slope coordinate table ($00E632)
		STZ $FA						;/
		SEC : SBC #$6E					;\
		TAY						; |
		PHX						; |
		LDA [$82],y : TAX				; | set sprite slope type
		LDA.l $00E53D,x					; |
		TXY						; > preserve in Y
		PLX						; |
		STA !SpriteSlope,x				;/
		TYA						;\ get index to pushout value
		ASL #4 : STA $05				;/
		BCC $02 : INC $F1				; index +256
		LDA $98						;\
		AND #$0F : STA $04				; |
		LDA $9A						; | Y = index to [$F0]
		AND #$0F : ORA $05				; |
		TAY						;/
		LDA [$F8],y					;\ check for invalid slope
		CMP #$10 : BEQ ..return				;/
		BCS ..slopeassist				; check for slope assist
		LDA $04						;\
		CMP #$0C : BCS +				; |
		CMP [$F8],y : BCC ..return			; |
	+	REP #$20					; |
		LDA [$F8],y					; | get vertical pushup value (+1)
		AND #$00FF					; |
		EOR #$FFFF					; |
		CLC : ADC $F6					; |
		STA $F6						; |
		SEP #$20					;/
		LDA !SpriteSlope,x				;\
		CMP #$04 : BEQ ..supersteep			; |
		CMP #$FC : BNE ++				; |
		..supersteep					; | slope interaction
		EOR !SpriteDeltaX,x : BPL +			; |
		LDA !SpriteDeltaX,x : BEQ +			; |
		LDA !SpriteDir,x				; |
		EOR #$01 : STA !SpriteDir,x			;/
	+	JSL $03C1CA					; sprite interact with supersteep slope tile, needs further research
	++	JMP ..solid

		..slopeassist
		LDA $98
		AND #$0F
		CMP #$05 : BCS ..return2
		INC A : STA $04
		LDA !SpriteStatus,x
		CMP #$02 : BEQ ..return2
		CMP #$05 : BEQ ..return2
		CMP #$0B : BEQ ..return2
		LDA !SpriteYLo,x
		SEC : SBC $04
		STA !SpriteYLo,x
		LDA !SpriteYHi,x
		SBC #$00
		STA !SpriteYHi,x
		PLA : PLA
		JMP .InteractLayer_go

		..return2
>>>>>>> Stashed changes
		RTS


;.YBounds	dw $00E0,$01C0			; above, below

.Long		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		PLB
		RTL


StompSound:	PHY
		LDA !P2Character-$80,y : BEQ .Mario

.PCE		LDA !P2KillCount-$80,y
		CMP #$07 : BCS .Shared
		INC A
		STA !P2KillCount-$80,y
		DEC A
		BRA .Shared

.Mario		LDA $7697
		CMP #$07 : BCS .Shared
		INC $7697

.Shared		TAY
		CPY #$07
		BCC $02 : LDY #$07
		LDA.w .StarSounds,y : STA !SPC1
.NoSound	PLY
		RTS

.StarSounds	db $13,$14,$15,$16,$17,$18,$19


SPRITE_STAR:	LDA #$02 : STA $3230,x
		LDA #$D0 : STA $3200,x
		JSR SUB_HORZ_POS
		LDA.w .StarXSpeed,y : STA $AE,x
		LDA $78D2
		CMP #$08 : BCS +
		INC A
		STA $78D2
	+	TAY
		CPY #$07
		BCC $02 : LDY #$07
		LDA.w StompSound_StarSounds,y : STA !SPC1
.Return		RTS
.StarXSpeed	db $F0,$10

.Long		JSR SPRITE_STAR
		RTL


SPRITE_SPINKILL:
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		PHY
		JSL $07FC3B
		PLY
		LDA #$08 : STA !SPC1
		RTS

.Long		JSR SPRITE_SPINKILL
		RTL


SUB_HORZ_POS:	LDA !P2Status-$80 : BNE .2
.1		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTS
.2		LDA !MultiPlayer : BEQ .1
		LDA !P2Status : BNE .1
		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo
		SEP #$20
		BPL .Set
		RTS

.Long		JSR SUB_HORZ_POS
		RTL
.Long1		JSR SUB_HORZ_POS_1
		RTL
.Long2		JSR SUB_HORZ_POS_2
		RTL

SUB_VERT_POS:	LDA !P2Status-$80 : BNE .2
.1		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTS
.2		LDA !MultiPlayer : BEQ .1
		LDA !P2Status : BNE .1
		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo
		SEP #$20
		BPL .Set
		RTS

<<<<<<< Updated upstream
.Long		JSR SUB_VERT_POS
=======
		.Target
		STA $00
		STZ $01
		LDA $00
		BPL $02 : DEC $01
		LDA !P2Status-$80,y : BEQ ..go
		TYA
		EOR #$80
		TAY
	..go	LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CLC : ADC $00
		SEC : SBC !P2YPosLo-$80,y
		SEP #$20
		BPL ..1
	..0	LDY #$00
>>>>>>> Stashed changes
		RTL
.Long1		JSR SUB_VERT_POS_1
		RTL
<<<<<<< Updated upstream
.Long2		JSR SUB_VERT_POS_2
=======


; input: void
; output: void
	ShakeX:
		TXY
		LDA $14
		AND #$03 : TAX
		LDA.l .Offset_lo,x
		CLC : ADC !SpriteXLo,y
		STA !SpriteXLo,y
		LDA.l .Offset_hi,x
		ADC !SpriteXHi,y
		STA !SpriteXHi,y
		TYX
		RTL

		.Offset
		..lo
		db $01,$00,$FF,$00
		..hi
		db $00,$00,$FF,$00


; input: void
; output: void
	GroundSpeed:
		LDA !SpriteSlope,x
		BPL $03 : EOR #$FF : INC A
		TAX
		LDA.l .SlopeSpeed,x
		LDX !SpriteIndex
		STA !SpriteYSpeed,x
>>>>>>> Stashed changes
		RTL



AccelerateX:
		CMP #$00
		BMI .GoLeft
.GoRight	INC $AE,x
		INC $AE,x
		BMI .Return
<<<<<<< Updated upstream
		CMP $AE,x : BCC .Store
		RTS
=======
		CMP !SpriteXSpeed,x : BCC .Limit
		RTL
		.GoLeft
		DEC !SpriteXSpeed,x
		DEC !SpriteXSpeed,x
		BPL .Return
		CMP !SpriteXSpeed,x : BCS .Limit
		RTL
		.Limit
		STA !SpriteXSpeed,x
		.Return
		RTL
>>>>>>> Stashed changes

.GoLeft		DEC $AE,x
		DEC $AE,x
		BPL .Return
		CMP $AE,x : BCS .Store
		RTS

.Store		STA $AE,x
.Return		RTS

.Long		JSR AccelerateX
		RTL

AccelerateY:
		CMP #$00
		BMI .GoUp
.GoDown		INC $9E,x
		INC $9E,x
		BMI .Return
		CMP $9E,x : BCC .Store
		RTS

.GoUp		DEC $9E,x
		DEC $9E,x
		BPL .Return
		CMP $9E,x : BCS .Store
		RTS

.Store		STA $9E,x
.Return		RTS

.Long		JSR AccelerateY
		RTL


;==========================;
;SPRITE A SPRITE B ROUTINES;
;==========================;
; These deal with common functions used when X = sprite A index and Y = sprite B index
SPRITE_A_SPRITE_B:

.COORDS		LDA $3220,x : STA $3220,y	;\
		LDA $3250,x : STA $3250,y	; | copy coordinates
		LDA $3210,x : STA $3210,y	; |
		LDA $3240,x : STA $3240,y	;/
		RTS

..Long		JSR .COORDS
		RTL

.ADD		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y			; | copy coordinates and add $00-$03
		LDA $3210,x			; |
		CLC : ADC $02			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		ADC $03				; |
		STA $3240,y			;/
		RTS

..Long		JSR .ADD
		RTL



;=========================;
;PLAYER 2 CLIPPING ROUTINE;
;=========================;
P2Clipping:	LDA !P2XPosLo			;\
		CLC : ADC #$02			; |
		STA $00				; |
		LDA !P2XPosHi			; |
		ADC #$00			; |
		STA $08				; |
		LDA !P2YPosLo : STA $01		; | Kadaal's clipping
		LDA !P2YPosHi : STA $09		; |
		LDA #$0C : STA $02		; |
		LDA #$10 : STA $03		;/
		RTS

<<<<<<< Updated upstream
.Long		JSR P2Clipping
=======
		.Return
		LDX !SpriteIndex				; reload sprite index
		BCC ..done					;\
		LDA !SpriteTweaker4,x				; |
		AND #$08 : BEQ ..done				; | if there is contact, apply knockback unless sprite is immune
		LDA.w !SpriteXSpeed,y : STA !SpriteXSpeed,x	; |
		LDA.w !SpriteYSpeed,y : STA !SpriteYSpeed,x	;/

		..done
>>>>>>> Stashed changes
		RTL


;============================;
;PLAYER ATTACK HITBOX ROUTINE;
;============================;
; Load sprite hitbox into $04-$07 and $0A-$0B, then call this
;	returns with carry set if there was contact
;	sets index mem for player
;	returns with lowest bit of A set for player 1, and second lowest bit set for player 2
P2Attack:	STZ $0F
	.Main	LDA #$00 : PHA
		PHY
		LDY #$00
	.Loop	LDA !P2Status-$80,y : BEQ .ReadIndex
		JMP .Next

		.ReadIndex
		CPX #$08 : BCC ..07
	..8F	LDA !P2IndexMem2-$80,y
		BRA ..Index
	..07	LDA !P2IndexMem1-$80,y
	..Index	AND .ContactBits,x
		BEQ ..Ok
		CLC : BRA .Next
		..Ok

		REP #$20			;\
		LDA !P2Hitbox-$80+4,y		; |
		STA $02				; | See if there is a hitbox
		SEP #$20			; |
		BEQ .Next			;/
		LDA !P2Hitbox-$80+0,y : STA $00	;\
		LDA !P2Hitbox-$80+1,y : STA $08	; |
		LDA !P2Hitbox-$80+2,y : STA $01	; | See if sprite touches hitbox
		LDA !P2Hitbox-$80+3,y : STA $09	; |
		LDA $0F : PHA			; |
		PHY				; |
		JSL !Contact16			; |
		PLY				; |
		PLA : STA $0F			; |
		BCC .Next			;/


		TYA				;\
		CLC : ROL #2			; |
		INC A				; | Mark contact
		ORA $02,s			; |
		STA $02,s			;/

<<<<<<< Updated upstream

		LDA !P2Character-$80,y
		CMP #$03 : BNE +
		LDA #$08 : STA !P2ComboDash-$80,y
		LDA #$00 : JSR DontInteract
		+
=======
; normal version just checks for contact
; _Destroy version will also destroy the fireball that touches the sprite (only 1 per frame, there is no way that this can cause problems, future Eric, i know what you're thinking!)
; input: sprite hurtbox loaded in $E8 slot
; output:
;	C set if contact, C clear if no contact
;	Y = fireball fusion index
;	$00: fireball X speed (converted to sprite format, but halved)
	FireballContact:
		LDA !SpriteIFrames,x : BNE .Fail		; no contact during i-frames
		BIT !SpriteTweaker4,x : BVC .Process		; check for projectile immunity
		.Fail
		CLC
		RTL

		.Process
		LDY !PProjectile_Index
		..loop
		DEY : BMI .Fail
		PHY
		LDA !PProjectile_List,y : TAY
		LDA !Ex_XLo,y : STA $E0
		LDA !Ex_XHi,y : STA $E1
		LDA !Ex_YLo,y : STA $E2
		LDA !Ex_YHi,y : STA $E3
		LDA #$08
		STA $E4 : STZ $E5
		STA $E6 : STZ $E7
		JSL CheckContact
		PLY
		BCC ..loop
		BRA .Return


	.Destroy
		LDA !SpriteIFrames,x : BNE .Fail		; no contact during i-frames
		LDY !PProjectile_Index

		..loop
		DEY : BMI .Fail
		PHY
		LDA !PProjectile_List,y : TAY
		LDA !Ex_XLo,y : STA $E0
		LDA !Ex_XHi,y : STA $E1
		LDA !Ex_YLo,y : STA $E2
		LDA !Ex_YHi,y : STA $E3
		LDA #$08
		STA $E4 : STZ $E5
		STA $E6 : STZ $E7
		JSL CheckContact
		PLY
		BCC ..loop

	.Puff
		LDA !PProjectile_List,y : TAY
		STZ $00						; X speed output: default to 0
		LDA !Ex_Num,y					;\
		AND #$7F					; |
		CMP #!QuestionBlock_Num : BEQ ..done		; | blocks don't puff or output X speed
		CMP #!Brick_Num : BEQ ..done			; |
		CMP #!BlockHitbox_Num : BEQ ..done		;/
		LDA #!TurnToPrt_Num : STA !Ex_Num,y		;\
		LDA.b #!prt_smoke16x16 : STA !Ex_Data1,y	; |
		LDA #$F0 : STA !Ex_Data3,y			; | turn to smoke puff (max prio)
		LDA !Ex_XSpeed,y				; |
		CMP #$80 : ROR A				; |
		STA $00						; > fireball X speed output (halved)
		LDA #$00					; |
		STA !Ex_XSpeed,y				; |
		STA !Ex_YSpeed,y				;/
		LDA #$01 : STA !SPC1				; SFX
		PHX						;\
		TYX : JSL RemoveProjectile			; | remove projectile if it was puffed
		PLX						;/
		..done
		; flow into .Return

	.Return
		LDA !Ex_Num,y					;\
		AND #$7F					; |
		CMP #!QuestionBlock_Num : BEQ ..block		; |
		CMP #!Brick_Num : BEQ ..block			; | kick SFX when hit by a block
		CMP #!BlockHitbox_Num : BNE ..notblock		; |
		..block						; |
		LDA #$03 : STA !SPC1				; |
		..notblock					;/

		LDA !SpriteTweaker4,x				;\
		AND #$48 : BNE ..done				; | apply knockback unless sprite is immune
		LDA $00 : STA !SpriteXSpeed,x			; | (to knockback or projectiles)
		LDA #$E8 : STA !SpriteYSpeed,x			;/

		..done
		SEC						; set C
		RTL						; return

>>>>>>> Stashed changes


		JSR P2HitContactGFX


		.WriteIndex
		LDA .ContactBits,x
		CPX #$08 : BCC ..07
	..8F	ORA !P2IndexMem2-$80,y
		STA !P2IndexMem2-$80,y
		BRA ..Ok
	..07	ORA !P2IndexMem1-$80,y
		STA !P2IndexMem1-$80,y
		..Ok

		LDA $0F : BEQ .Next
		LDA !P2Direction-$80,y
		DEC A
		EOR #$30
		STA $AE,x
		LDA #$F0 : STA $9E,x

		.Next
		CPY #$80 : BEQ .Return
		LDY #$80 : JMP .Loop

		.Return
		PLY
		PLA				;\
		SEC				; |
		BNE $01 : CLC			; | (carry is always set if Y[0x80] = 0x80)
		RTS				;/

<<<<<<< Updated upstream
=======
		.NoSpeed
		STZ $02
		STZ $03
		JMP SpawnSprite

		.SpriteSpeed
		LDA !SpriteXSpeed,x : STA $02
		LDA !SpriteYSpeed,x : STA $03
		JMP SpawnSprite


; input:
;	A = !Ex_Num
;	$00 = X offset (8-bit signed)
;	$01 = Y offset (8-bit signed)
;	$02 = X speed
;	$03 = Y speed
; output: Y = ExSprite index
	SpawnExSprite:
		.Main
		STA $08					; store ExSprite num

		LDA $01 : STA $04			;\
		STZ $05					; |
		BPL $02 : DEC $05			; | 16-bit offsets
		LDA $00					; |
		STZ $01					; |
		BPL $02 : DEC $01			;/

		%Ex_Index_Y()				; Y = index

		LDA $08 : STA !Ex_Num,y			; ExSprite number
		LDA #$00				;\
		STA !Ex_Data1,y				; | clear misc regs
		STA !Ex_Data2,y				; |
		STA !Ex_Data3,y				;/

		LDA $02 : STA !Ex_XSpeed,y		; X speed
		LDA $03 : STA !Ex_YSpeed,y		; Y speed
		LDA !SpriteXLo,x			;\
		CLC : ADC $00				; |
		STA !Ex_XLo,y				; | Xpos
		LDA !SpriteXHi,x			; |
		ADC $01					; |
		STA !Ex_XHi,y				;/
		LDA !SpriteYLo,x			;\
		CLC : ADC $04				; |
		STA !Ex_YLo,y				; | Ypos
		LDA !SpriteYHi,x			; |
		ADC $05					; |
		STA !Ex_YHi,y				;/

		RTL					; return

	.SpriteSpeed					;\
		LDA !SpriteXSpeed,x : STA $02		; | inherit sprite speeds
		LDA !SpriteYSpeed,x : STA $03		; |
		JMP .Main				;/

	.NoSpeed					;\
		STZ $02					; | spawn without speed
		STZ $03					; |
		JMP .Main				;/




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
;
;	_NoSpeed version zeroes $02-$03
;	_NoAcc version zeroes $04-$05
;	_NoSpeedAcc version zeroes $02-$05
;
; output:
;	$0E = index to spawned particle
;	mirrors the PP bits of $07 to the upper 2 bits, but the rest of $00-$07 remain unchanged
	SpawnParticle:
		PHX						; push X
		STA $0F						; $0F = particle num
		LDA $07						;\
		ROL #3						; | $0E = size bit
		AND #$02					; |
		STA $0E						;/
		LDA #$C0 : TRB $07				;\
		LDA $07						; |
		AND #$30					; | mirror PP bits
		ASL #2						; |
		TSB $07						;/
		LDA $01 : STA $08				;\
		STZ $09						; |
		BPL $02 : DEC $09				; |
		CLC : ADC !SpriteYLo,x				; | $08 = 16-bit Ypos
		STA $08						; |
		LDA !SpriteYHi,x				; |
		ADC $09						; |
		STA $09						;/
		LDA $00						;\
		STZ $0B						; |
		BPL $02 : DEC $0B				; |
		CLC : ADC !SpriteXLo,x				; | $00 = 16-bit Xpos
		STA $0A						; |
		LDA !SpriteXHi,x				; |
		ADC $0B						; |
		STA $0B						;/

		PHB						; push bank
		JSL GetParticleIndex				; X = 16-bit particle index, bank = $41
		LDA $0A : STA !Particle_XLo,x			;\ particle coords
		LDA $08 : STA !Particle_YLo,x			;/
		LDA $06 : STA !Particle_Tile,x			; particle tile/prop
		LDA $02						;\
		AND #$00FF					; |
		ASL #4						; | particle X speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_XSpeed,x				;/
		LDA $03						;\
		AND #$00FF					; |
		ASL #4						; | particle Y speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_YSpeed,x				;/
		SEP #$20					; A 8-bit
		LDA $04 : STA !Particle_XAcc,x			;\ particle acc
		LDA $05 : STA !Particle_YAcc,x			;/
		LDA $0E : STA !Particle_Layer,x			; particle size bit
		LDA $0F : STA !Particle_Type,x			; particle num

		STX $0E						; save this index
		PLB						; restore bank
		SEP #$30					; all regs 8-bit
		PLX						; restore X
		RTL						; return
>>>>>>> Stashed changes

.Long		PHB : PHK : PLB
		JSR P2Attack
		PLB
		RTL

.KnockBack	LDA #$01 : STA $0F
		JMP P2Attack_Main

..Long		PHB : PHK : PLB
		JSR .KnockBack
		PLB
		RTL


.ContactBits	db $01,$02,$04,$08,$10,$20,$40,$80
		db $01,$02,$04,$08,$10,$20,$40,$80


;===============;
;GLITTER ROUTINE;
;===============;
MakeGlitter:
		TXA
		CLC : ADC $14
		AND #$0F : BNE .Return
		LDY.b #!Ex_Amount-1
	-	LDA !Ex_Num,y : BNE +
		LDA #$04 : STA !Ex_Num,y
		LDA !RNG
		AND #$0F
		ASL A
		SEC : SBC #$10
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3210,x
		STA !Ex_YLo,y
		LDA $3240,x
		ADC $00
		STA !Ex_YHi,y
		LDA !RNG
		LSR #3
		AND #$17
		SEC : SBC #$08
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3220,x
		STA !Ex_XLo,y
		LDA $3250,x
		ADC $00
		STA !Ex_XHi,y
		LDA #$1F : STA !Ex_Data1,y
		BRA .Return
	+	DEY : BPL -
	.Return	RTS

<<<<<<< Updated upstream
.Long		JSR MakeGlitter
		RTL
=======
; input: void
; output:
;	all regs return in 8-bit
;	NOTE: distances are only calculated if both players are alive and active
;	Y = index of closest player
;	$04 = 16-bit x+y distance of P1
;	$06 = 16-bit x+y distance of P2
	CLOSEST_PLAYER:
		LDY #$00				; default to P1
		LDA !P2Status : BNE .Return
		LDA !P2Status-$80 : BNE .P2		; if only P2 is alive, go with P2
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYLo,x : STA $02
		LDA !SpriteYHi,x : STA $03

		REP #$20
		LDA !P2X-$80
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		STA $04
		LDA !P2Y-$80
		SEC : SBC $02
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC $04
		STA $04

		LDA !P2X
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		STA $06
		LDA !P2Y
		SEC : SBC $02
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC $06
		STA $06
		CMP $04
		SEP #$20
		BCS .Return

		.P2
		LDY #$80

		.Return
		RTL

>>>>>>> Stashed changes


;==========================;
;SPRITE CONTACT GFX ROUTINE;
;==========================;
;
; displays contact GFX on the point between two sprites (X and Y)
;
SpriteContactGFX:
		PHX
		LDA $3220,x
		CLC : ADC $3220,y
		STA $00
		LDA $3250,x
		ADC $3250,y
		STA $01
		LDA $3210,x
		CLC : ADC $3210,y
		STA $02
		LDA $3240,x
		ADC $3240,y
		STA $03
		REP #$20
		LDA $00
		LSR A
		STA $00
		SEC : SBC $1A
		CMP #$0100 : BCS .Nope
		LDA $02
		LSR A
		STA $02
		SEC : SBC $1C
		CMP #$00E0 : BCS .Nope
		SEP #$20
		LDX #!Ex_Amount-1

	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; smoke type
		LDA $00 : STA !Ex_XLo,x			; smoke X
		LDA $02 : STA !Ex_YLo,x			; smoke Y
		LDA #$08 : STA !Ex_Data1,x		; smoke timer

	.Nope	SEP #$20
		PLX
		RTS


	.Long	JSR SpriteContactGFX
		RTL


;============================;
;PLAYER 2 CONTACT GFX ROUTINE;
;============================;
P2ContactGFX:	PHX
		LDA !P2Offscreen : BNE .Return
		LDX #!Ex_Amount-1

<<<<<<< Updated upstream
	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; > Smoke type
		LDA !P2XPosLo-$80,y			;\
		CLC : ADC #$08				; | Smoke Xpos
		STA !Ex_XLo,x				;/
		LDA !P2YPosLo-$80,y			;\
		CLC : ADC #$08				; | Smoke Ypos
		STA !Ex_YLo,x				;/
		LDA #$08 : STA !Ex_Data1,x		; > Smoke timer

		.Return
=======
; input: sprite hurtbox in $E8 slot
; output:
;	C clear = no contact, C set = contact
;	Y = index to hitbox (00, 0F, 80 or 8F)
; notes:
;	normal version will not apply knockback
;	_Knockback version will apply knockback
	P2Attack:
		.Main
		LDA !SpriteIFrames,x : BNE .NoContact
		BIT !SpriteTweaker4,x : BMI .NoContact			; check for melee attack immunity

		LDY #$00

	.CheckHitbox
		LDA !SpriteTweaker3,x					;\
		AND #$01 : BNE ..process				; |
		TXA							; | unless "process interaction every frame" is set...
		EOR $14							; | ...only process when sprite index = frame counter (lowest bits only)
		LSR A : BCS .NoContact					;/

		..process
		LDA !P2Hitbox1Shield-$80,y : BNE .Hitbox2		; no hit if a shield blocks the way
		LDA !P2Hitbox1W-$80,y
		ORA !P2Hitbox1H-$80,y
		BEQ .Hitbox2

		CPX #$08 : BCS ..8F
	..07	LDA !P2Hitbox1IndexMem1-$80,y : BRA ..index
	..8F	LDA !P2Hitbox1IndexMem2-$80,y
	..index	AND.l .ContactBits,x : BNE .Hitbox2

		REP #$20						;\
		LDA !P2Hitbox1W-$80,y					; |
		AND #$00FF						; |
		CLC : ADC !P2Hitbox1X-$80,y				; |
		CMP $E8 : BMI ..nocontact				; |
		LDA $E8							; |
		CLC : ADC $EC						; |
		CMP !P2Hitbox1X-$80,y : BMI ..nocontact			; |
		LDA !P2Hitbox1H-$80,y					; |
		AND #$00FF						; | check for hitbox contact
		CLC : ADC !P2Hitbox1Y-$80,y				; |
		CMP $EA : BMI ..nocontact				; |
		LDA $EA							; |
		CLC : ADC $EE						; |
		CMP !P2Hitbox1Y-$80,y					; |
		SEP #$20						; |
		BPL .YesContact						; |
		..nocontact						; |
		SEP #$20						;/

		.Hitbox2
		CPY #$81 : BCS .NoContact				; if we just checked player 2 hitbox 2, return with no contact
		CPY.b #!P2Hitbox2Offset : BEQ .Player2			; if we just checked player 1 hitbox 1, go to player 2
		TYA							;\
		CLC : ADC.b #!P2Hitbox2Offset				; | add hitbox 2 offset, then loop
		TAY : BRA .CheckHitbox					;/

		.NoContact
		CLC
		RTL

	.Player2
		LDA !MultiPlayer : BEQ .NoContact			; in singleplayer, return with no contact instead of checking player 2
		LDY #$80 : BRA .CheckHitbox				; get ready to check player 2 hitbox 1, then loop

	.YesContact
		LDA !P2Hitbox1X-$80,y : STA $E0				;\
		LDA !P2Hitbox1Y-$80,y : STA $E2				; | copy hitbox here
		LDA !P2Hitbox1W-$80,y : STA $E4				; | (only done on a hit)
		LDA !P2Hitbox1H-$80,y : STA $E6				;/
		LDA !P2Hitbox1Hitstun-$80,y : STA $0C
		PHY
		CPX #$08
		BCC $01 : INY
		LDA.l .ContactBits,x
		ORA !P2Hitbox1IndexMem1-$80,y
		STA !P2Hitbox1IndexMem1-$80,y
		LDA !SpriteTweaker3,x					;\ skip gfx if ghost mode
		AND #$08 : BNE ..settimer				;/ (this needs 2 checks)
		LDA $0C
		CMP #$06 : BCC ..small
		TYA
		AND #$80 : TAY
		LDA !P2Character-$80,y
		CMP #$02 : BNE ..gosmall
		JSL P2BigContactGFX
		BRA ..settimer
		..small
		TYA
		AND #$80 : TAY
		..gosmall
		JSL P2HitContactGFX
		..settimer
		PLY
		LDA !P2Hitbox1DisTimer-$80,y : JSL DontInteract		; interaction disable

		.Knockback						;\
		LDA !SpriteTweaker4,x					; |
		AND #$08 : BNE ..done					; | apply knockback unless sprite is immune to it
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x	; |
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x	; |
		..done							;/

		.Hitstrun
		LDA !SpriteTweaker3,x					;\ check for ghost mode (ignores hitstun, gfx and sfx)
		AND #$08 : BNE .Return					;/
		LDA !P2Hitbox1Hitstun-$80,y : STA $9D			; hitstun

		.SFX1							;\
		LDA !P2Hitbox1SFX1-$80,y : BEQ ..done			; | SFX 1
		STA !SPC1						; |
		..done							;/

		.SFX2							;\
		LDA !P2Hitbox1SFX2-$80,y : BEQ ..done			; | SFX 2
		STA !SPC4						; |
		..done							;/

		.Return
		SEC							; mark contact
		RTL							; return


		.ContactBits
		db $01,$02,$04,$08,$10,$20,$40,$80
		db $01,$02,$04,$08,$10,$20,$40,$80




; input: Y = player index
; output: void
	P2ContactGFX:
		PHX							; preserve X
		PHB							; |
		JSL GetParticleIndex					; | get particle index
		LDA.w #!prt_contact : STA !Particle_Type,x		; > particle num
		LDA #$F000 : STA !Particle_Tile,x			; > particle prop
		PLB							; |
		LDA !P2XPosLo-$80,y : STA !41_Particle_X,x		;\
		LDA !P2YPosLo-$80,y					; | coords
		CLC : ADC #$0008					; |
		STA !41_Particle_Y,x					;/
		LDA #$0000						;\
		STA !41_Particle_XSpeed,x				; |
		STA !41_Particle_YSpeed,x				; | clear speed + acc
		STA !41_Particle_XAcc,x					; |
		STA !41_Particle_YAcc,x					;/
		SEP #$30						; all regs 8-bit
		PLX							; restore X
		RTL							; return



; input: clipping boxes loaded in both slots
; output: void
	P2HitContactGFX:
		PHX							; preserve X
		PHB							;
		JSL GetParticleIndex					; get particle index
		PLB							;
		CLC							;\
		LDA !P2Hitbox1W-$80,y					; |
		AND #$00FF						; |
		ADC $EC							; |
		LSR A							; | x position
		SBC #$0008						; |
		ADC !P2Hitbox1X-$80,y					; |
		ADC $E8							; |
		LSR A							; |
		STA !41_Particle_X,x					;/
		CLC							;\
		LDA !P2Hitbox1H-$80,y					; |
		AND #$00FF						; |
		ADC $EE							; |
		LSR A							; | y position
		SBC #$0008						; |
		ADC !P2Hitbox1Y-$80,y					; |
		ADC $EA							; |
		LSR A							; |
		STA !41_Particle_Y,x					;/
		LDA #$0000						;\
		STA !41_Particle_XSpeed,x				; |
		STA !41_Particle_YSpeed,x				; | clear speed + acc
		STA !41_Particle_XAcc,x					; |
		STA !41_Particle_YAcc,x					;/
		LDA #$F000 : STA !41_Particle_Tile,x			; prop
		LDA.w #!prt_contact : STA !41_Particle_Type,x		; particle num
		SEP #$30						; all regs 8-bit
		PLX							; restore X
		RTL							; return


; input:
;	Y = player index
;	clipping boxes loaded in both slots
; output: void
	P2BigContactGFX:
		PHX
		PHB
		JSL GetParticleIndex
		LDA.w #!prt_contactbig : STA !Particle_Type,x
		TYA
		BEQ $03 : LDA.w #$0200+!P2TileOffset			; set lowest c bit
		CLC : ADC.w #!P1Tile7
		ORA #$F000
		STA !Particle_Tile,x
		SEP #$20
		LDA #$02 : STA !Particle_Layer,x
		PLB

		REP #$20
		LDA $E8
		CLC : ADC !P2Hitbox1X-$80,y
		LSR A
		STA $0C
		LDA $EA
		CLC : ADC !P2Hitbox1Y-$80,y
		LSR A
		SEC : SBC #$000E
		STA !41_Particle_YLo,x
		LDA $0C : STA !41_Particle_XLo,x
		LDA !P2Direction-$80,y
		AND #$00FF
		BEQ $03 : LDA #$0040
		STA !41_Particle_XSpeed,x
		SEP #$30
>>>>>>> Stashed changes
		PLX
		RTS

.Long		JSR P2ContactGFX
		RTL


<<<<<<< Updated upstream
;=======================;
;HIT CONTACT GFX ROUTINE;
;=======================;
P2HitContactGFX:
=======
; input: Y = player index
; output: void
	P2Bounce:
		LDA #$00 : STA !P2SpecialUsed-$80,y		; refund air special
		PHX						; preserve X
		LDX !P2Character-$80,y : BEQ .Mario		; X = player character
		CPX #$01 : BEQ .Luigi
		CPX #$02 : BEQ .Kadaal
		CPX #$03 : BNE .ReadInput

		.Leeway
		LDA !P2Anim-$80,y
		CMP #!Lee_DoubleJump : BCC .ReadInput
		CMP #!Lee_DoubleJump_over : BCS .ReadInput
		LDA #!Lee_Jump : STA !P2Anim-$80,y
		BRA .ReadInput

		.Kadaal
		LDA #$07 : STA !P2JumpLag-$80,y			; show this frame for a bit
		BRA .ReadInput

		.Luigi
		LDA #$00 : STA !P2YoshiFlutter-$80,y
		BRA .ReadInput

		.Mario						;\
		LDA !P2RolloutBuffer-$80,y : BMI ..endrollout	; |
		..canrollout					; |
		LDA #$04 : STA !P2RolloutStomp-$80,y		; | mario rollout code
		BRA ..rolloutdone				; |
		..endrollout					; |
		LDA #$00 : STA !P2RolloutBuffer-$80,y		; |
		..rolloutdone					;/
		..firecharge					;\
		LDA !P2FireCharge-$80,y				; |
		CMP #$02 : BCS .ReadInput			; | give mario a fire charge (max 2)
		INC A : STA !P2FireCharge-$80,y			; | (mario code caps this number, don't worry)
		LDA #!MarioFlashPal : STA !P2FlashPal-$80,y	;/
		CPY #$80 : BEQ ..p2				;\
	..p1	LDA $6DA4 : BMI .ReadInput_B			; | mario can bounce with A button
		BRA .ReadInput					; |
	..p2	LDA $6DA5 : BMI .ReadInput_B			;/

		.ReadInput
		CPY #$80 : BEQ ..p2				;\
	..p1	LDA $6DA2 : BRA ..read				; |
	..p2	LDA $6DA3					; | read input
	..read	BMI ..B						; |
		LDA.l .BounceSpeed,x : BRA ..comp		; |
	..B	LDA.l .BounceSpeedB,x				;/
	..comp	LDX !P2YSpeed-$80,y : BPL ..set			; > X = player Y speed, always bounce if player is moving down
		CMP !P2YSpeed-$80,y : BCS ..end			;\ otherwise only bounce if player would gain speed from it
	..set	STA !P2YSpeed-$80,y				;/
	..end	JSL P2ContactGFX				; include contact GFX
		PLX						; restore X
		RTL						; return

		.BounceSpeed
		db $D0,$D0,$C8,$C8,$00,$00	; Mario, Luigi, Kadaal, Leeway, Alter, Peach
		.BounceSpeedB
		db $A8,$A8,$A8,$A8,$00,$00	; Mario, Luigi, Kadaal, Leeway, Alter, Peach (when holding B)


; input: A = contact bits
; output: void
; sets kick timer for players
	P2Kick:
>>>>>>> Stashed changes
		PHX
		LDX #!Ex_Amount-1

	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
<<<<<<< Updated upstream
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x
		LDA $0F : PHA
		LDA $02
		LSR A
		CLC : ADC $00
		STA $0F
		LDA $06
		LSR A
=======
		RTL

		.KickSpeed
		db $E0,$20





; input: A = number of frames to not interact
; output: void
	IFrames:
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
		STA !SpriteIFrames,x

		.SetIndexMem
		LDA.l CORE_BITS,x
		CPX #$08 : BCS ..8F
	..07	TSB !P2Hitbox1IndexMem1-$80
		TSB !P2Hitbox2IndexMem1-$80
		TSB !P2Hitbox1IndexMem1
		TSB !P2Hitbox2IndexMem1
		RTL
	..8F	TSB !P2Hitbox1IndexMem2-$80
		TSB !P2Hitbox2IndexMem2-$80
		TSB !P2Hitbox1IndexMem2
		TSB !P2Hitbox2IndexMem2
		RTL


; input:
;	A = number of frames to not interact
;	Y = player index
; output: void
	DontInteract:
		CPY #$80 : BCS .P2
	.P1	STA !SpriteDisP1,x
		RTL
	.P2	STA !SpriteDisP2,x
		RTL

; input: Y = player index
; output: A = interaction disable timer
	CheckInteract:
		CPY #$80 : BCS .P2
	.P1	LDA !SpriteDisP1,x
		RTL
	.P2	LDA !SpriteDisP2,x
		RTL


; input:
;	sprite clipping loaded in $E8 slot
;	!dmg = potential contact damage
; output:
;	C = clear if no contact, C = set if contact
;	A = $00 (instant BEQ will trigger if sprite was not hurt, instant BNE will trigger if it was)
;	$00 = how many times sprite was hurt
;	$01 = player contact bits (0 = no, 1 = p1, 2 = p2, 3 = both)
;	$02 = player hurt bits (same format as above)
; note: if "can be jumped on" = 0, crush state will not crush the sprite
	P2Standard:
		STZ $00
		STZ $01
		STZ $02
		BIT !SpriteTweaker2,x : BMI .Return

		LDA !SpriteTweaker3,x				;\
		AND #$01 : BNE .Process				; |
		TXA						; | unless "process interaction every frame" is set...
		EOR $14						; | ...only process when sprite index = frame counter (lowest bits only)
		LSR A : BCS .Return				;/

		.Process
		JSL PlayerContact : BCC .NoContact
		STA $01
		LSR A : BCC .P2

		.P1
		PHA
		LDA !SpriteDisP1,x : BEQ ..int
		LDA #$01 : TRB $01
		BRA ..next
	..int	LDY #$00 : JSR .PlayerContact
	..next	PLA

		.P2
		LSR A : BCC .Return
		LDA !SpriteDisP2,x : BEQ ..int
		LDA #$02 : TRB $01
		BRA .Return
	..int	LDY #$80 : JSR .PlayerContact

		.Return
		CLC
		LDA $01 : BEQ .NoContact
		SEC

		.NoContact
		STZ !dmg				; make sure damage value is always used up (AFTER both damage calls)
		LDA $00
		RTL


	.PlayerContact
		LDA !StarTimer : BEQ .NoStar		; check for star
		LDA !SpriteTweaker4,x			;\ check for star immunity
		AND #$20 : BNE .NoStar			;/
		JSL SPRITE_STAR
		INC $00
		RTS
		.NoStar

		REP #$20
		LDA $EA
		SEC : SBC #$0004
		CMP !P2YPosLo-$80,y
		SEP #$20	
		BCC .HurtPlayer

		BIT !SpriteTweaker3,x : BVC .Bounce	;\ spiky surface: hurt player unless they have the crush property
		LDA !P2Crush-$80,y : BEQ .HurtPlayer	;/
		LDA #$02 : STA !SPC1
		BRA .Bounce_nosfx

		.Bounce
		JSL StompSound
		..nosfx
		LDA #$08 : JSL DontInteract		; interaction disable when stomping sprite: 8 frames
		INC $00
		JSL P2Bounce

		LDA !SpriteYSpeed,x : BPL ..done	;\ reset sprite Y speed if it's moving up when stomped
		STZ !SpriteYSpeed,x			;/
		..done

		RTS

		.HurtPlayer
		LDA !dmg : BMI ..done			; negative damage = can't hurt player
		LDA #$0F : JSL DontInteract		; interaction disable when hurt by sprite: 15 frames
		LDA !dmg : PHA				;\
		TYA					; |
		CLC : ROL #2				; |
		INC A					; | hurt (make sure damage value is applied to both players!)
		TSB $02					; |
		JSL HurtPlayers				; |
		PLA : STA !dmg				;/
		..done
		RTS



; input:
;	sprite clipping loaded in $E8 slot
;	A = horizontal knockback for players (_NoKnockback version skips this and just has no knockback instead)
; output:
;	hurts players that touch the sprite, but only if interaction timers are clear
;	C = clear if no contact, C = set if contact
	SpriteAttack:
		LDY !SpriteDir,x : BEQ .Right
		.Left
		EOR #$FF : INC A
		.Right
		STA $00
		JSL PlayerContact : BCC .NoContact
		STA $01
		LSR A : BCC .P2

		.P1
		PHA
		LDA !P2Invinc-$80
		ORA !StarTimer
		BNE ..nope
		LDA !SpriteDisP1,x : BEQ ..int
		..nope
		LDA #$01 : TRB $01
		BRA ..next
		..int
		LDY #$00
		LDA #$0F : JSL DontInteract
		LDA $00 : STA !P2VectorX-$80
		LDA #$0F : STA !P2VectorTimeX-$80
		..next
		PLA

		.P2
		LSR A : BCC .Return
		LDA !P2Invinc
		ORA !StarTimer
		BNE ..nope
		LDA !SpriteDisP2,x : BEQ ..int
		..nope
		LDA #$02 : TRB $01
		BRA .Return
		..int
		LDY #$80
		LDA #$0F : JSL DontInteract
		LDA $00 : STA !P2VectorX
		LDA #$0F : STA !P2VectorTimeX

		.Return
		LDA $01 : BEQ .NoContact
		JSL HurtPlayers

		.NoContact
		STZ !dmg				; make sure damage value is always used up
		RTL

	.NoKnockback
		LDA #$00 : BRA .Right


;==========================;
; SPRITE INTERACTION CODES ;
;==========================;
; for these, X = sprite A index and Y = sprite B index

	SPRITE_A_SPRITE_B:

; input: void
; output: void
		.COORDS
		LDA !SpriteXLo,x : STA !SpriteXLo,y	;\
		LDA !SpriteXHi,x : STA !SpriteXHi,y	; | copy coordinates
		LDA !SpriteYLo,x : STA !SpriteYLo,y	; |
		LDA !SpriteYHi,x : STA !SpriteYHi,y	;/
		RTL

; input:
;	$00 = 16-bit X offset
;	$02 = 16-bit Y offset
; output: void
		.ADD
		LDA !SpriteXLo,x			;\
		CLC : ADC $00				; |
		STA !SpriteXLo,y			; |
		LDA !SpriteXHi,x			; |
		ADC $01					; |
		STA !SpriteXHi,y			; | copy coordinates and add $00-$03
		LDA !SpriteYLo,x			; |
		CLC : ADC $02				; |
		STA !SpriteYLo,y			; |
		LDA !SpriteYHi,x			; |
		ADC $03					; |
		STA !SpriteYHi,y			;/
		RTL


; displays contact GFX on the point between two sprites (X and Y)
; input: void
; output: void
	SpriteContactGFX:
		PHY
		LDA !SpriteXLo,y
		SEC : SBC !SpriteXLo,x
		STA $00
		LDA !SpriteYLo,y
		SEC : SBC !SpriteYLo,x
		STA $01
		REP #$20
		STZ $02
		STZ $04
		STZ $06
		SEP #$20
		LDA.b #!prt_contact : JSL SpawnParticle	
		PLY
		RTL



;===============;
; TILEMAP CODES ;
;===============;
; input:
;	A = 16-bit pointer to ANIM table (4-byte wide)
;	X = sprite index
; output:
;	updates !SpriteAnimIndex and !SpriteAnimTimer
;	z = 0 (BNE trigger) if anim did not change
;	z = 1 (BEQ trigger) if anim did change
	AUTO_ANIM:
		STA $00					; $00 = pointer to ANIM+0 (tilemap pointer)
		INC #2 : STA $02			; $02 = pointer to ANIM+2 (timer value)
		INC A : STA $04				; $04 = pointer to ANIM+3 (next anim)
		SEP #$20				;\
		LDA !SpriteAnimIndex,x			; |
		ASL #2 : TAY				; | get index, increment timer, compare to threshold time
		LDA !SpriteAnimTimer,x			; |
		INC A					; |
		CMP ($02),y : BNE .SameAnim		;/

		.NewAnim				;\
		LDA ($04),y : STA !SpriteAnimIndex,x	; | update anim and reset timer
		LDA #$00				;/

		.SameAnim				;\ write timer
		STA !SpriteAnimTimer,x			;/
		RTL					; return

; input:
;	A = 16-bit pointer to ANIM table (4-byte wide)
;	X = sprite index
; output:
;	Y = index to ANIM table (after update)
;	$04 = 16-bit tilemap pointer
	UNPACK_ANIM:
		STA $04					;\
		LDA !SpriteAnimIndex,x			; |
		REP #$10				; |
		AND #$00FF				; | get tilemap pointer
		ASL #2 : TAY				; |
		LDA ($04),y : STA $04			; |
		SEP #$30				;/
		RTL


; sprites with inlined functions:
; - aggro rex
; - captain warrior
; - conjurex
; - elite koopa
; - hammer rex
; - happy slime
; - kingking
; - komposite koopa
; - lakitu lovers
; - lava lord
; - mini mech
; - monkey
; - npc
; - plant head
; - rex
; - tar creeper
; - thif
; - wizrex



; input:
;	A = 16-bit pointer to ANIM table (6-byte wide)
;	X = sprite index
; output:
;	updates !SpriteAnimIndex and !SpriteAnimTimer
;	z = 0 (BNE trigger) if anim did not change
;	z = 1 (BEQ trigger) if anim did change
; notes:
;	the sprite itself is responsible for determining when a new frame is loaded
;	this is because this routine is just one way that the animation can change
;	if the sprite changes animations due to performing an action, this routine would not know
;	because of this, the sprite has to handle that itself
	AUTO_ANIM_SQUARE:
		STA $00					; $00 = pointer to ANIM+0 (tilemap pointer)
		CLC : ADC #$0004			;\ $02 = pointer to ANIM+4 (timer value)
		STA $02					;/
		INC A : STA $04				; $04 = pointer to ANIM+5 (next anim)
		SEP #$20				;\
		LDA !SpriteAnimIndex,x			; |
		ASL A : ADC !SpriteAnimIndex,x		; |
		REP #$20				; |
		AND #$00FF				; | get index, increment timer, compare to threshold time
		ASL A : TAY				; |
		SEP #$20				; |
		LDA !SpriteAnimTimer,x			; |
		INC A					; |
		CMP ($02),y : BNE .SameAnim		;/

		.NewAnim				;\
		LDA ($04),y : STA !SpriteAnimIndex,x	; | update anim and reset timer
		LDA #$00				;/

		.SameAnim				;\ write timer
		STA !SpriteAnimTimer,x			;/
		RTL					; return


; input:
;	A = 16-bit pointer to ANIM table (6-byte wide)
;	X = sprite index
; output:
;	$04 = 16-bit tilemap pointer
;	$0C = 16-bit square dynamo pointer
	UNPACK_ANIM_SQUARE:
		STA $0C					;\
		SEP #$20				; |
		LDA !SpriteAnimIndex,x			; |
		ASL A : ADC !SpriteAnimIndex,x		; | get tilemap pointer
		REP #$30				; |
		AND #$00FF				; |
		ASL A : TAY				; |
		LDA ($0C),y : STA $04			;/
		INY #2					;\
		LDA ($0C),y : STA $0C			; | get dynamo pointer
		SEP #$30				;/
		RTL







; the following routines can be used by sprites to load an OAM tilemap
;
; global tilemap format:
;	2-byte header: number of bytes to load (equal to 4 times the number of tiles to load)
;	for each tile
;		prop
;		X (inverted based on xflip)
;		Y
;		tile num
;
;	for LOAD_TILEMAP, prop has the following format:
;		YXSPCCCT
;		everything is exactly what you'd expect, except S which is the size bit, and P which is shifted left (prio = 0 or 2, but never 1 or 3)
;	tile num is written as is
;
;	for LOAD_TILEMAP_COLOR, prop is this:
;		YXPP--ST
;		CCC bits come from sprite's !SpriteOAMProp,x
;
;	for LOAD_PSUEDO_DYNAMIC (yes i spelled that wrong when i was a teenager, get over it), prop has the following format:
;		YXPP--Sc
;		C bits are unused since those are instead read from !SpriteOAMProp,x
;		T bit is unused since it is read from !SpriteProp,x
;		S is size bit
;		c if set, --S bits are used as CCC and lower P bit is used as S, !SpriteOAMProp,x is ignored
;	tile num is added to !SpriteTile,x and stored to OAM
;
;	for LOAD_DYNAMIC, prop has the same format as for LOAD_PSUEDO_DYNAMIC, but the T bit comes from the dynamic tile's allocation, loaded by SETUP_SQUARE
;	tile num is used as an index to $F0 to find the appropriate dynamic tile, rather than being written directly to OAM
;
;	priority can be specified by appending _p0, _p1, _p2, or _p3 to the subroutine call
;	if no priority is specified, sprites that are not carried will default to _p2
;	sprites that are carried will use either _p2 or _p3 depending on the carrying player's animation
;
;	DRAW_SIMPLE: draws tile 0 (PSUEDO_DYNAMIC) as a 16x16 tile with no offset, prio 1 (sprite) and prio 2 (PP bits)
;		_0	draws tile 0
;		_2	draws tile 2
;		_4	draws tile 4
;		_6	draws tile 6
;		_8	draws tile 8
;		_A	draws tile A
;		_C	draws tile C
;		_E	draws tile E
;	DRAW_SIMPLE can not specify sprite-sprite priority, instead always using the default version of LOAD_PSUEDO_DYNAMIC
;


; recode all to use this memory format:
;
; $00		sprite screen-relative Xpos
; $02		sprite screen-relative Ypos
; $04		tilemap pointer
; $06		temp: prop or tile screen-relative Xpos
; $08		tilemap byte count
; $0A		tile size bit
; $0C		-X--CCCT (applied as EOR, unused by static loader)
; $0E		x-flip EOR mask (0x0000 or 0xFFFF)
;
; !BigRAM+$7C	(PSUEDO_DYNAMIC only) tile offset
; !BigRAM+$7D	----
; !BigRAM+$7E	16-bit upper boundary of OAM mirror index




; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_TILEMAP:
		LDA !SpriteStatus,x			;\
		CMP #$0B : BNE .p2			; |
		.Carried				; |
		TXA					; |
		INC A					; |
		CMP !P2Carry-$80 : BNE ..player2	; | allow automatic carry priority unless priority is specified
		..player1				; |
		LDY #$00 : BRA ..handleprio		; |
		..player2				; |
		LDY #$80				; |
		..handleprio				; |
		JSL GET_CARRIED_PRIO : BNE .p3		;/

	.p2	LDA #$04 : BRA .Shared			; default to prio 2 if not specified
	.p0	LDA #$00 : BRA .Shared
	.p1	LDA #$02 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04)
		INC $04
		INC $04
>>>>>>> Stashed changes
		CLC : ADC $04
		CLC : ADC $0F
		ROR A
		STA !Ex_XLo,x

		LDA $03
		LSR A
		CLC : ADC $01
		STA $0F
		LDA $07
<<<<<<< Updated upstream
		LSR A
		CLC : ADC $05
		CLC : ADC $0F
		ROR A
		SEC : SBC #$08
		STA !Ex_YLo,x
=======
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
	.End	RTS



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_TILEMAP_COLOR:
		LDA !SpriteStatus,x			;\
		CMP #$0B : BNE .p2			; |
		.Carried				; |
		TXA					; |
		INC A					; |
		CMP !P2Carry-$80 : BNE ..player2	; | allow automatic carry priority unless priority is specified
		..player1				; |
		LDY #$00 : BRA ..handleprio		; |
		..player2				; |
		LDY #$80				; |
		..handleprio				; |
		JSL GET_CARRIED_PRIO : BNE .p3		;/

	.p2	LDA #$04 : BRA .Shared			; default to prio 2 if not specified
	.p1	LDA #$02 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04)
		INC $04
		INC $04
		CLC : ADC $04
		STA $08
		STZ $0C
		STZ $0E
		LDA !SpriteDir,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
		DEC $0E
	+	LDA !SpriteOAMProp,x
		AND #$000E : TSB $0C
		LDY $04
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTL
>>>>>>> Stashed changes

		LDA #$08 : STA !Ex_Data1,x
		PLA : STA $0F
		PLX
		RTS

.Long		JSR P2HitContactGFX
		RTL



;=======================;
;PLAYER 2 BOUNCE ROUTINE;
;=======================;
P2Bounce:
		TYA : JSR CheckMario
		BNE .PCE
		JSL !BouncePlayer
		JSL !ContactGFX+5
		RTS

		.PCE
		PHX				; preserve sprite index
		TYA
		CLC : ROL #2
		TAX
		LDA #$D0			;\
		BIT $6DA2,x			; | Set Y speed
		BPL $02 : LDA #$A8		; |
		PLX				; |
		STA !P2YSpeed-$80,y		;/
		LDA #$00			;\
		STA !P2SenkuUsed-$80,y		;/ Reset air Senku
		JMP P2ContactGFX

.Long		JSR P2Bounce
		RTL

<<<<<<< Updated upstream

;==============;
;UPDATE PALETTE;
;==============;
; always use long version!
LoadPalset:
.Long
		STA $0F
		LDA.l !LoadPalset : STA $00
		LDA.l !LoadPalset+1 : STA $01
		LDA.l !LoadPalset+2 : STA $02
		LDA $0F
		JML [$3000]


;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	This routine can be used by sprites to load a raw OAM tilemap.
;
;	$00:		sprite Xpos within screen
;	$02:		sprite Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		tile Xpos within screen (only for static loader, for pseudo-dynamic, this is the tile size bit)
;	$08:		tilemap size
;	$0A:		graphics claim offset (only for pseudo-dynamic, for static loader this is the tile size bit)
;	$0C:		copy of xflip flag from tilemap
;	$0E:		0xFFFF is tile is x-flipped, otherwise 0x0000
;
; returns with index to next OAM tile in $0E (static) or last written tile (psuedo-dynamic)

macro OAMhook(index)
	if <index> == 2
	.HiPrio
	endif
	.p<index>
		LDA.b #<index>*2
		BRA .Shared

	..Long
	if <index> == 1
	.Long
	elseif <index> == 2
	.HiPrio_Long
	endif
		JSR .p<index>
		RTL
endmacro

LOAD_TILEMAP:
; default to prio 1 if not specified
; !BigRAM+$7C is used by rex!

		%OAMhook(1)
		%OAMhook(2)
		%OAMhook(0)
		%OAMhook(3)

	.Shared
=======
; input: void
;	NOTE: _Main version requires input Y = tilemap index (0, 2, 4, 6, 8, A, etc)
; output: void
	DRAW_SIMPLE:
	.0	LDY #$00 : BRA .Main
	.2	LDY #$02 : BRA .Main
	.4	LDY #$04 : BRA .Main
	.6	LDY #$06 : BRA .Main
	.8	LDY #$08 : BRA .Main
	.A	LDY #$0A : BRA .Main
	.C	LDY #$0C : BRA .Main
	.E	LDY #$0E
		.Main
		PHB : PHK : PLB
		REP #$20
		LDA.w .Ptr,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		PLB
		RTL

		.Ptr
		dw .TM0
		dw .TM2
		dw .TM4
		dw .TM6
		dw .TM8
		dw .TMA
		dw .TMC
		dw .TME

		.TM0
		dw $0004
		db $22,$00,$00,$00
		.TM2
		dw $0004
		db $22,$00,$00,$02
		.TM4
		dw $0004
		db $22,$00,$00,$04
		.TM6
		dw $0004
		db $22,$00,$00,$06
		.TM8
		dw $0004
		db $22,$00,$00,$08
		.TMA
		dw $0004
		db $22,$00,$00,$0A
		.TMC
		dw $0004
		db $22,$00,$00,$0C
		.TME
		dw $0004
		db $22,$00,$00,$0E


; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_PSUEDO_DYNAMIC:
		LDA !SpriteStatus,x			;\
		CMP #$0B : BNE .p2			; |
		.Carried				; |
		TXA					; |
		INC A					; |
		CMP !P2Carry-$80 : BNE ..player2	; | allow automatic carry priority unless priority is specified
		..player1				; |
		LDY #$00 : BRA ..handleprio		; |
		..player2				; |
		LDY #$80				; |
		..handleprio				; |
		JSL GET_CARRIED_PRIO : BNE .p3		;/

	.p2	LDA #$04 : BRA .Shared			; default to prio 2 if not specified
	.p1	LDA #$02 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
>>>>>>> Stashed changes
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
	+	LDY #$00
		REP #$30
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTS


.Loop		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				;\
		AND #$10				; |
		ASL A					; |
		STA $0A					; | YXPPCCCT
		LDA ($04),y				; | (lower P bit is shifted 1 bit left)
		AND.b #$20^$FF				; |
		ORA $0A					; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/

		PHA
		LDA ($04),y				;\
		AND #$20				; | tile size bit
		BEQ $02 : LDA #$02			; |
		STA $0A					;/
		STZ $0B					;\ n flag trigger
		BEQ $02 : DEC $0B			;/
		PLA

		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INY
.BadCoord	INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

.GoodX		STA $06					; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

.GoodY		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA ($04),y : STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
.End		RTS



<<<<<<< Updated upstream
LOAD_PSUEDO_DYNAMIC:
; default to prio 1 if not specified
; !BigRAM+$7C is used by rex!
=======
; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_DYNAMIC:
		LDA !SpriteStatus,x			;\
		CMP #$0B : BNE .p2			; |
		.Carried				; |
		TXA					; |
		INC A					; |
		CMP !P2Carry-$80 : BNE ..player2	; | allow automatic carry priority unless priority is specified
		..player1				; |
		LDY #$00 : BRA ..handleprio		; |
		..player2				; |
		LDY #$80				; |
		..handleprio				; |
		JSL GET_CARRIED_PRIO : BNE .p3		;/

	.p2	LDA #$04 : BRA .Shared
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06
>>>>>>> Stashed changes

		%OAMhook(1)
		%OAMhook(2)
		%OAMhook(0)
		%OAMhook(3)


	.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
	+	LDY #$00
		SEP #$20
		LDA !SpriteTile,x : STA $0A		; dynamic tile
		LDA !SpriteProp,x			;\
		ORA $33C0,x				; | add RAM palette
		TSB $0C					;/
		REP #$30
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTS

.Loop		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y
		AND.b #$30^$FF
		EOR $0C
		ORA $64
		STA !OAM_p0+$003,x
		LDA ($04),y
		AND #$20
		LSR #4 : STA $06			; tile size bit
		BEQ $02 : LDA #$80
		STA $07					; n flag trigger for 16-bit mode (n = 0 -> small tile, n = 1 -> big tile)
		REP #$20
		STZ $0E
		LDA !OAM_p0+$003,x
		AND #$0040 : BEQ +
		LDA #$FFFF : STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $06 : BMI +
		BIT $0E : BPL +
		CLC : ADC #$0008			; add 8 to x-flipped 8x8 tile
	+	CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INY
.BadCoord	INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

.GoodX		PHA					; push 16-bit tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		PLA					; get this off the stack
		BRA .BadCoord

.GoodY		SEP #$20
		STA !OAM_p0+$001,x
		PLA : STA !OAM_p0+$000,x		; lo byte of tile xpos
		PLA : STA $07				; hi byte of tile xpos
		INY
		LDA ($04),y
		CLC : ADC $0A
		STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07					; hi byte of tile xpos
		AND #$01
		ORA $06					; tile size bit
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
.End		RTS



<<<<<<< Updated upstream
; This routine should be used with dynamic sprites that use the GFX claim system
LOAD_CLAIMED:
	.p1	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p1
		PLA : STA !SpriteTile,x
		RTS
	..Long
	.Long
		JSR .p1
=======
; input: void
; output:
;	A = 0 (BEQ trigger) if prio 2 should be used
;	A = 1 (BNE trigger) if prio 3 should be used
	GET_CARRIED_PRIO:
		.HandlePrio
		LDA !P2Character-$80,y : BEQ ..mario
		CMP #$01 : BEQ ..luigi
		CMP #$03 : BNE ..prio2
		..leeway
		PHX
		REP #$30
		LDA !P2Anim-$80,y
		AND #$00FF
		ASL #3 : TAX
		LDA.l Leeway_SWORD+$05,x
		SEP #$30
		PLX
		CMP #$00 : BEQ ..prio3
		BRA ..prio2
		..luigi
		LDA !P2Anim-$80,y
		CMP #!Lui_Turn : BNE ..prio2
		..prio3
		LDA #$01
		RTL
		..mario
		LDA !P2Anim-$80,y
		CMP #!Mar_Turn : BEQ ..prio3
		..prio2
		LDA #$00
>>>>>>> Stashed changes
		RTL


	.p0	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p0
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p0
		RTL


	.p2	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p2
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p2
		RTL


	.p3	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p3
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p3
		RTL



CheckMario:	CLC : ROL #2
		INC A
		CMP !CurrentMario
		RTS

.Long		JSR CheckMario
		RTL

FireballContact:
		LDY #!Ex_Amount-1
	-	JSR .Main
		BCS .Return
		DEY : BPL -
.ReturnC	CLC
.Return		RTS

.Main		LDA !Ex_Num,y
		AND #$7F
		CMP #$05+!ExtendedOffset : BEQ .Check	; check mario fireball
		CMP #$02+!CustomOffset : BNE .ReturnC	; check luigi fireball
	.Check	LDA !Ex_YLo,y : STA $01
		LDA !Ex_XLo,y : STA $00
		LDA !Ex_YHi,y : STA $09
		LDA !Ex_XHi,y : STA $08
		LDA #$08
		STA $02
		STA $03
		PHY
		JSL !CheckContact
		PLY
		RTS

.Long		JSR FireballContact
		RTL

.Destroy	LDY #!Ex_Amount-1
	-	JSR .Main
		BCC +
		LDA #$0F : STA !Ex_Data2,y
		LDA #$01+!ExtendedOffset : STA !Ex_Num,y
		LDA #$01 : STA !SPC1
	+	DEY : BPL -
		RTS

..Long		JSR .Destroy
		RTL


; Call this to see if player is in a state that crushes sprite

CheckCrush:
		LDA !P2Character-$80,y
		BNE .Nope
		LDA !MarioSpinJump : BEQ .Nope

		.Yep
		SEC
		RTS

		.Nope
		CLC
		RTS

.Long		JSR CheckCrush
		RTL

;======================;
;DON'T INTERACT ROUTINE;
;======================;
DontInteract:
		CPY #$80 : BEQ .P2
	.P1	STA $32E0,x
		RTS
	.P2	STA $35F0,x
		RTS

.Long		JSR DontInteract
		RTL


;============;
;SPAWN SPRITE;
;============;
; A:	sprite num
; C:	0 = vanilla, 1 = custom
; $00:	Xdisp
; $01:	Ydisp
; if Y returns as 0xFF, sprite could not be spawned!

	SpawnSprite:
		STA $0E
		STZ $0F
		BCC $02 : INC $0F
		LDY #$0F
	-	LDA $3230,y : BEQ .Spawn
		DEY : BPL -
		RTS

	.Spawn
		LDA $00
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3220,x
		STA $3220,y
		LDA $02
		ADC $3250,x
		STA $3250,y
		LDA $01
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3210,x
		STA $3210,y
		LDA $02
		ADC $3240,x
		STA $3240,y
		LDA $0F : BNE .Custom

	.Vanilla
		LDA $0E : STA $3200,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		STZ !ExtraBits,x
		STZ !NewSpriteNum,x
		JSL !ResetSprite		; | > Reset sprite tables
		PLX
		PLY
		RTS

	.Custom
		LDA $0E : STA !NewSpriteNum,y
		LDA #$08 : STA !ExtraBits,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		JSL !ResetSprite		; | > Reset sprite tables
		PLX
		PLY
		RTS

	.Long	JSR SpawnSprite
		RTL





;======================;
;SPAWN EXSPRITE ROUTINE;
;======================;
; extended
; LOAD Y WITH NUMBER OF EXSPRITES TO SPAWN, LOAD A WITH TYPE/PATTERN, LOAD $00-$03 WITH OFFSET!
; THEN CALL THE FUNCTION TO SPAWN THEM!
;
; You can call it normally to spawn with speed based on $04/$05
; Add _SpriteSpeed to use sprite's speeds
; Add _NoSpeed to spawn without speed
; All versions have a _Long version as well that comes with a bank wrapper
;
; Writes this to scratch RAM:
; $00-$03: offset
; $04-$05: speeds
; $06-$07: input data
; $08-$09: ExSprite number/timer
; $0A-$0B: -----
; $0C-$0F: pattern data

	SpawnExSprite:
		STY $06
		STA $07
		BRA .Shared
	.Long	PHB : PHK : PLB
		JSR SpawnExSprite
		PLB
		RTL

	.SpriteSpeed
		STY $06
		STA $07
		LDA $AE,x : STA $04
		LDA $9E,x : STA $05
		LDA $07
		BRA .Shared
	..Long	PHB : PHK : PLB
		JSR .SpriteSpeed
		PLB
		RTL

	.NoSpeed
		STZ $04
		STZ $05
		BRA SpawnExSprite
	..Long	PHB : PHK : PLB
		JSR .NoSpeed
		PLB
		RTL
		


	.Shared
		AND #$0F
		TAY
		LDA.w .Type,y
		CLC : ADC #!ExtendedOffset
		STA $08
		LDA.w .Time,y : STA $09
		STZ $0D
		STZ $0F
		LDA $07
		AND #$C0
		CLC : ROL #3
		TAY
		LDA.w .PatternX,y : STA $0C
		BPL $02 : DEC $0D
		LDA $07
		AND #$30
		LSR #4
		TAY
		LDA.w .PatternY,y : STA $0E
		BPL $02 : DEC $0F

	-	%Ex_Index_Y()

		.Yes
		LDA $08 : STA !Ex_Num,y		; ExSprite number
		LDA $09 : STA !Ex_Data2,y	; Unknown, probably a timer
		LDA $04 : STA !Ex_XSpeed,y	;\ Speed
		LDA $05 : STA !Ex_YSpeed,y	;/
		TDC : STA !Ex_Data3,y		; Special prop

		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA !Ex_XLo,y			; | X position
		LDA $3250,x			; |
		ADC $01				; |
		STA !Ex_XHi,y			;/
		LDA $3210,x			;\
		CLC : ADC $02			; |
		STA !Ex_YLo,y			; | Y position
		LDA $3240,x			; |
		ADC $03				; |
		STA !Ex_YHi,y			;/

		LDA $00
		CLC : ADC $0C
		STA $00
		LDA $01
		ADC $0D
		STA $01
		LDA $02
		CLC : ADC $0E
		STA $02
		LDA $03
		ADC $0F
		STA $03

		DEC $06 : BNE -			; Spawn until done

		RTS


		.PatternX			; Indexed by highest 2 bits
		db $00,$08,$10,$F0

		.PatternY			; Indexed by 0x30 bits
		db $00,$08,$10,$F0


		.Type
		db $01,$02,$03,$04
		db $06,$07,$09,$0A
		db $0B,$0C,$0D,$0E
		db $0F,$10,$11,$12

		.Time
		db $0F,$FF,$FF,$FF
		db $FF,$1F,$FF,$FF
		db $FF,$FF,$FF,$FF
		db $1F,$1F,$FF,$FF

; X0	-	puff of smoke
; X1	-	Reznor fireball
; X2	-	tiny flame
; X3	-	hammer
; X4	-	bone
; X5	-	lava splash
; X6	-	Malleable Extended Sprite
; X7	-	coin from coin cloud
; X8	-	piranha fireball
; X9	-	volcano lotus' fire
; XA	-	baseball
; XB	-	Wiggler's flower
; XC	-	trail of smoke
; XD	-	spin jump star
; XE	-	Yoshi's fireball
; XF	-	water bubble















