;===============;
; PHYSICS CODES ;
;===============;



; input: void
; output: void
	APPLY_SPEED:
		LDA !SpriteStasis,x : BEQ .Process		;\
		RTL						; | return if stasis
		.Process					;/
		LDA !SpriteXLo,x : STA $F0			;\
		LDA !SpriteXHi,x : STA $F1			; | backup coords
		LDA !SpriteYLo,x : STA $F2			; |
		LDA !SpriteYHi,x : STA $F3			;/
		LDA !SpriteBlocked,x : STA $F4			; backup collision
		LDA !SpriteWater,x : STA $0F			; backup water flags (if no movement occurs, they stick to the next frame)


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

		LDA !SpriteXLo,x				;\
		SEC : SBC $F0					; |
		STA !SpriteDeltaX,x				; | get delta
		LDA !SpriteYLo,x				; |
		SEC : SBC $F2					; |
		STA !SpriteDeltaY,x				;/

		JMP SPRITE_INTERACTION


		.X
		LDA !SpriteStasis,x : BNE ..return
		..ignorestasis
		%UpdateX()
		..return
		RTL

		.Y
		LDA !SpriteStasis,x : BNE ..return
		..ignorestasis
		%UpdateY()
		..return
		RTL



	SPRITE_INTERACTION:
		.ContactTurn
		BIT !SpriteTweaker2,x : BVS .Return
		LDA !SpriteDisSprite,x : BNE .Return
		JSL GetSpriteClippingE8

		LDA !SpriteTweaker6,x
		AND #$20 : BEQ ..done

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
;	10 - lava flag
;	20 - water horizontal (can be kept from previous frame if delta X = 0)
;	40 - water vertical (can be kept from previous frame if delta Y = 0)
;	80 - touching layer 2 flag
;
; $F0 - previous X coord of sprite
; $F2 - previous Y coord of sprite
; $F4 - previous collision status (read only)
; $F5 - horizontal pushout value (8-bit)
; $F6 - vertical pushout value (16-bit)
; $F8 - slope data pointer (24-bit)



	OBJECT_INTERACTION:
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



		STZ !SpriteBlocked,x				; clear collision
		STZ !SpriteSlope,x				; clear slope
		STZ $0E						; layer (0 = layer 1, 80 = layer 2)
		LDY !SpriteDeltaY,x				;\
		BEQ $04 : LDA #$40 : TRB $0F			; | wipe water flags from working reg if moving in a relevant direction
		LDY !SpriteDeltaX,x				; |
		BEQ $04 : LDA #$20 : TRB $0F			;/


		STZ !CurrentLayer
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
		LDA !SpriteTweaker6,x				;\ check wall behavior
		LSR A : BCS ..restoreX				;/
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
		LDY !BuoyancySettings : BEQ .Return		; no water if bouyancy is off

		.WaterSplash
		AND #$60 : BEQ ..exitwater			;\
		..enterwater					; |
		LDY !SpriteWater,x : BNE .ReturnWater		; |
		BRA ..splash					; |
		..exitwater					; | check for splash conditions
		LDY !SpriteWater,x : BEQ .ReturnWater		; |
		..splash					; |
		STA !SpriteWater,x				; > update water status
		LDA !BuoyancySettings : BEQ ..done		; |
		LDA !SpriteTweaker1,x				; |
		AND #$02 : BNE ..done				;/
		REP #$20					;\
		STZ $00						; |
		STZ $02						; |
		STZ $04						; | spawn splash
		LDA #$F000 : STA $06				; |
		SEP #$20					; |
		LDA.b #!prt_watersplash : JSL SpawnParticle	;/
		..done

		.Return
		PLB
		RTL

		.ReturnWater
		STA !SpriteWater,x
		PLB
		RTL



	.InteractLayer
		LDA $0E : BEQ ..go				;\
		..layer2					; |
		LDA !BuoyancySettings				; | return if trying to interact with layer 2 while it's disabled
		ORA !SpriteTweaker1,x				; |
		AND #$40 : BNE .SideCollision_return		;/
		..go						;\
		LDY #$02					; |
		BIT !SpriteDeltaY,x				; | get tile for vertical interaction
		BPL $01 : INY					; |
		JSR .GetTile					;/
		BCS ..noliquids					;\
		LDY !BuoyancySettings : BEQ ..noliquids		; > no liquids if buoyancy is off
		CMP #$04 : BCS ..lava				; |
		..water						; |
		LDA #$40 : BRA +				; | mark water/lava
		..lava						; |
		LDA #$10					; |
	+	TSB $0F						; |
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
		LDA !SpriteDeltaX,x : BEQ ..return		; return if no X movement
		ASL A						;\
		ROL A						; | get tile for horizontal interaction
	+	AND #$01 : TAY					; |
		JSR .GetTile					;/
		BCS ..noliquids					;\
		LDY !BuoyancySettings : BEQ ..noliquids		; > no liquids if buoyancy is off
		CMP #$04 : BCS ..lava				; |
		..water						; |
		LDA #$20 : BRA +				; | mark water/lava
		..lava						; |
		LDA #$10					; |
	+	TSB $0F						; |
		..noliquids					;/
		LDA $0D : BEQ ..return				; ignore tiles on page 0
		LDA $0C						;\
		CMP #$11 : BCC ..return				; | only interact with tiles 0x0111-0x016D
		CMP #$6E : BCS ..return				;/
		TYA						;\
		INC A						; | set block status
		ORA $0E						; |
		TSB $0F						;/

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
		LDA $04						; |
		AND #$00FF					; | check for 3D water
		CMP #$0002					; |
		LDA #$0020					; |
		BCC $01 : ASL A					; |
		TSB $0F						; |
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
	+	LDA #$10 : TSB $0F				; set lava flag
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
		RTS




; order is: R, L, D, U

	SpriteObjectClippingX:
		db $0E,$01,$08,$08	; clipping 0
		db $0E,$01,$07,$07	; clipping 1
		db $07,$07,$07,$07	; clipping 2
		db $0E,$01,$08,$08	; clipping 3
		db $10,$00,$08,$08	; clipping 4
		db $0D,$02,$08,$08	; clipping 5
		db $0B,$04,$08,$08	; clipping 6
		db $1F,$01,$10,$10	; clipping 7
		db $0F,$00,$08,$08	; clipping 8
		db $10,$00,$08,$08	; clipping 9
		db $0D,$02,$08,$08	; clipping A
		db $0E,$01,$08,$08	; clipping B
		db $0D,$02,$08,$08	; clipping C
		db $10,$00,$08,$08	; clipping D
		db $1F,$00,$10,$10	; clipping E
		db $08,$08,$08,$10	; clipping F

	SpriteObjectClippingY:
		db $08,$08,$10,$01	; clipping 0
		db $12,$12,$20,$02	; clipping 1
		db $07,$07,$07,$07	; clipping 2
		db $10,$10,$20,$0B	; clipping 3
		db $12,$12,$20,$02	; clipping 4
		db $18,$18,$20,$10	; clipping 5
		db $04,$04,$08,$00	; clipping 6
		db $10,$10,$1F,$01	; clipping 7
		db $08,$08,$0F,$00	; clipping 8
		db $08,$08,$10,$00	; clipping 9
		db $48,$48,$50,$42	; clipping A
		db $04,$04,$08,$00	; clipping B
		db $00,$00,$00,$00	; clipping C
		db $08,$08,$10,$00	; clipping D
		db $08,$08,$10,$00	; clipping E
		db $04,$01,$02,$04	; clipping F





	ITEM_PHYSICS:

		.Move
		JSL APPLY_SPEED				; move
		LDA !SpriteBlocked,x			;\
		AND #$04 : BEQ ..done			; | find landing frame
		AND $F4 : BNE ..ground			;/
		LDA !SpriteXSpeed,x			;\
		CMP #$80				; |
		ROR A : STA !SpriteXSpeed,x		; |
		LDA !SpriteYSpeed,x			; |
		CMP #$20				; | bounce
		BPL $02 : LDA #$00			; > BCC can cause a bug
		LSR A					; |
		EOR #$FF : INC A			; |
		STA !SpriteYSpeed,x			;/
		BRA ..done
		..ground
		JSL AccelerateX_Friction2
		..done

		.Wall
		LDA !SpriteBlocked,x
		AND #$03 : BEQ ..done
		LDA !SpriteXSpeed,x
		CMP #$80
		ROR A
		EOR #$FF : INC A
		STA !SpriteXSpeed,x
		..done

		RTL


	ITEM_INTERACT_OBJECT:
		PHX
		LDA !ShellOwner,x : STA !CurrentPlayer
		REP #$20
		LDA $0C
		SEC : SBC #$0117
		SEP #$20
		BMI .Fail
		ASL A
		CMP.b #.Ptr_end-.Ptr : BCS .Fail
		TAX
		JSR (.Ptr,x)

		.Fail
		SEP #$30
		PLX
		RTS


		.Ptr
		dw .Brick_mushroom		; 117
		dw .Brick_lifemushroom		; 118
		dw .Brick_star			; 119
		dw .Brick_variable		; 11A
		dw .Brick_multiplecoins		; 11B
		dw .Brick_coin			; 11C
		dw .Brick_pow			; 11D
		dw .Brick			; 11E
		dw .Block_mushroom		; 11F
		dw .Block_lifemushroom		; 120
		dw .Block_star			; 121
		dw .Block_star2			; 122
		dw .Block_multiplecoins		; 123
		dw .Block_coin			; 124
		dw .Block_variable		; 125
		dw .Block_goldmushroom		; 126
		dw .Block_greenshell		; 127
		dw .Block_greenshell		; 128
		..end



		.Brick
		REP #$20
		LDA #$0025 : JSL ChangeMap16
		SEP #$20
		LDX !SpriteIndex
		JSL SpawnBrickPieces
		RTS
		..mushroom
		LDA #$74 : BRA ..useblock
		..lifemushroom
		LDA #$77 : BRA ..useblock
		..goldmushroom
		LDA #$78 : BRA ..useblock
		..star2
		LDA !StarTimer : BEQ ..coin
		..star
		LDA #$76 : BRA ..useblock
		..variable
		LDA $9A
		LSR #4 : TAY
		LDA ..varitemdata,y : BEQ ..star2
		CMP #$01 : BEQ ..goldmushroom
		..vine
		LDA #$79 : BRA ..useblock
		..multiplecoins
		LDA !CoinTimer : BEQ ..multicoinstart
		CMP #$01 : BNE ..multicoin
		STZ !CoinTimer
		BRA ..coin
		..multicoinstart
		LDA #$FF : STA !CoinTimer
		..multicoin
		LDA #$0B : BRA +
		..coin
		LDA #$0D
	+	STA $9C
		LDA.b #!Brick_Num : JSL CORE_BOUNCE_SPRITE_Long
		JSL CORE_SPAWN_COIN_Long
		RTS
		..pow
		LDA #$3E

		..useblock
		STA $04
		LDA #$0D : STA $9C
		LDA.b #!Brick_Num : BRA .BounceSprite


		..varitemdata
		db $00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00

		.BounceSprite
		JSL CORE_BOUNCE_SPRITE_Long

		.SpawnSprite
		STZ $05
		JSL CORE_SPAWN_OBJECT_Long
		RTS


		.Block
		..mushroom
		LDA #$74 : BRA ..useblock
		..lifemushroom
		LDA #$77 : BRA ..useblock
		..goldmushroom
		LDA #$78 : BRA ..useblock
		..star2
		LDA !StarTimer : BEQ ..coin
		..star
		LDA #$76 : BRA ..useblock
		..multiplecoins
		LDA !CoinTimer : BEQ ..multicoinstart
		CMP #$01 : BNE ..multicoin
		STZ !CoinTimer
		BRA ..coin
		..multicoinstart
		LDA #$FF : STA !CoinTimer
		..multicoin
		LDA #$0B : BRA +
		..coin
		LDA #$0D
	+	STA $9C
		LDA.b #!QuestionBlock_Num : JSL CORE_BOUNCE_SPRITE_Long
		JSL CORE_SPAWN_COIN_Long
		RTS

		..variable
		LDA $9A
		AND #$30 : BEQ ..key
		CMP #$10 : BEQ ..wingblock
		CMP #$20 : BNE ..greenshell
		..balloon
		LDA #$7D : BRA ..useblock
		..key
		LDA #$80 : BRA ..useblock
		..wingblock
		LDA #$84 : BRA ..useblock
		..greenshell
		LDA #$04 : BRA ..useblock

		..useblock
		STA $04
		LDA #$0D : STA $9C
		LDA.b #!QuestionBlock_Num : BRA .BounceSprite




	SpawnBrickPieces:
		STZ $00
		STZ $01
		LDA #$F8 : STA $02
		LDA #$B0 : STA $03
		LDA #$F0 : STA $07
		LDA.b #!prt_brickpiece : JSL SpawnParticle
		LDA #$08
		STA $00
		STA $02
		LDA.b #!prt_brickpiece : JSL SpawnParticle
		LDA #$D0 : STA $03
		LDA #$08 : STA $01
		LDA.b #!prt_brickpiece : JSL SpawnParticle
		STZ $00
		LDA #$F8 : STA $02
		LDA.b #!prt_brickpiece : JMP SpawnParticle

		.Half
		STZ $00
		LDA #$08 : STA $01
		LDA #$F8 : STA $02
		LDA #$B0 : STA $03
		LDA #$F0 : STA $07
		LDA.b #!prt_brickpiece : JSL SpawnParticle
		LDA #$08
		STA $00
		STA $02
		LDA.b #!prt_brickpiece : JMP SpawnParticle



;=======================;
; GENERIC SUPPORT CODES ;
;=======================;

; input: void (for _Target, Y = player index)
; output:
;	A = sprite X - player X
;	Y = 0 if player on the left, 1 if player on the right
	SUB_HORZ_POS:
		LDA !P2Status-$80 : BNE .P2
.P1		LDY #$00
		LDA !SpriteXHi,x : XBA
		LDA !SpriteXLo,x
		REP #$20
		SEC : SBC !P2XPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTL
.P2		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status : BNE .P1
		LDY #$00
		LDA !SpriteXHi,x : XBA
		LDA !SpriteXLo,x
		REP #$20
		SEC : SBC !P2XPosLo
		SEP #$20
		BPL .Set
		RTL

		.Target
		LDA !P2Status-$80,y : BEQ ..go
		TYA
		EOR #$80
		TAY
	..go	LDA !SpriteXHi,x : XBA
		LDA !SpriteXLo,x
		REP #$20
		SEC : SBC !P2XPosLo-$80,y
		SEP #$20
		BPL ..1
	..0	LDY #$00
		RTL
	..1	LDY #$01
		RTL


; input: void (for _Target, A = offset and Y = player index)
; output:
;	A = sprite Y - player Y
;	Y = 0 if player below, 1 if player above
	SUB_VERT_POS:
		LDA !P2Status-$80 : BNE .P2
.P1		LDY #$00
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		SEC : SBC !P2YPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTL
.P2		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status : BNE .P1
		LDY #$00
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		SEC : SBC !P2YPosLo
		SEP #$20
		BPL .Set
		RTL

		.Target
		STA $00
		STZ $01
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
		RTL
	..1	LDY #$01
		RTL


; input: void
; output: void
	GroundSpeed:
		LDA !SpriteSlope,x
		BPL $03 : EOR #$FF : INC A
		TAX
		LDA.l .SlopeSpeed,x
		LDX !SpriteIndex
		STA !SpriteYSpeed,x
		RTL

		.SlopeSpeed
		db $00,$10,$10,$20,$40


; input: A = target X speed
; output: void
	AccelerateX:
		CMP #$00 : BMI .GoLeft
		.GoRight
		INC !SpriteXSpeed,x
		INC !SpriteXSpeed,x
		BMI .Return
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
	.Return	RTL


	.Friction
	.Friction1
		LDA !SpriteXSpeed,x : BEQ ..0
		BPL ..dec
	..inc	INC !SpriteXSpeed,x
		RTL
	..dec	DEC !SpriteXSpeed,x
		RTL
	..0	STZ !SpriteXSpeed,x
		RTL

	.Friction2
		LDA !SpriteXSpeed,x : BEQ .Friction1_0
		BPL ..dec
	..inc	CMP #$FF : BEQ .Friction1_0
		INC !SpriteXSpeed,x
		INC !SpriteXSpeed,x
		RTL
	..dec	CMP #$01 : BEQ .Friction1_0
		DEC !SpriteXSpeed,x
		DEC !SpriteXSpeed,x
		RTL


	.Unlimit
	.Unlimit1
		CMP !SpriteXSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..left					; see if target is left/right
		..right						;\
		BIT !SpriteXSpeed,x : BMI ..inc			; |
		CMP !SpriteXSpeed,x : BCC ..dec			; | accel: target right
	..inc	INC !SpriteXSpeed,x				; |
		RTL						;/
		..left						;\
		BIT !SpriteXSpeed,x : BPL ..dec			; |
		CMP !SpriteXSpeed,x : BCS ..inc			; | accel: target left
	..dec	DEC !SpriteXSpeed,x				; |
		RTL						;/

	.Unlimit2
		CMP !SpriteXSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..left					; see if target is left/right
		..right						;\
		BIT !SpriteXSpeed,x : BMI ..inc			; |
		CMP !SpriteXSpeed,x : BCC ..dec			; | accel: target right
	..inc	INC !SpriteXSpeed,x				; |
		INC !SpriteXSpeed,x				; |
		RTL						;/
		..left						;\
		BIT !SpriteXSpeed,x : BPL ..dec			; |
		CMP !SpriteXSpeed,x : BCS ..inc			; | accel: target left
	..dec	DEC !SpriteXSpeed,x				; |
		DEC !SpriteXSpeed,x				; |
		RTL						;/




; input: A = target Y speed
; output: void
	AccelerateY:
		CMP #$00 : BMI .GoUp
		.GoDown
		INC !SpriteYSpeed,x
		INC !SpriteYSpeed,x
		BMI .Return
		CMP !SpriteYSpeed,x : BCC .Limit
		RTL
		.GoUp
		DEC !SpriteYSpeed,x
		DEC !SpriteYSpeed,x
		BPL .Return
		CMP !SpriteYSpeed,x : BCS .Limit
		RTL
		.Limit
		STA !SpriteYSpeed,x
	.Return	RTL


	.Friction
	.Friction1
		LDA !SpriteYSpeed,x : BEQ ..0
		BPL ..dec
	..inc	INC !SpriteYSpeed,x
		RTL
	..dec	DEC !SpriteYSpeed,x
		RTL
	..0	STZ !SpriteYSpeed,x
		RTL


	.Unlimit
	.Unlimit1
		CMP !SpriteYSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..up					; see if target is up/down
		..down						;\
		BIT !SpriteYSpeed,x : BMI ..inc			; |
		CMP !SpriteYSpeed,x : BCC ..dec			; | accel: target down
	..inc	INC !SpriteYSpeed,x				; |
		RTL						;/
		..up						;\
		BIT !SpriteYSpeed,x : BPL ..dec			; |
		CMP !SpriteYSpeed,x : BCS ..inc			; | accel: target up
	..dec	DEC !SpriteYSpeed,x				; |
		RTL						;/


; input: void
; output: void
	MakeGlitter:
		TXA
		CLC : ADC $14
		AND #$0F : BNE .Return

		LDA !RNG					;\
		AND #$0F					; |
		ASL A						; | roll x offset
		SBC #$0C					; |
		STA $00						;/
		LDA !RNG					;\
		LSR #3						; |
		AND #$17					; | roll y offset
		SBC #$04					; |
		STA $01						;/
		LDA #$F0 : STA $07				; max prio
		LDA.b #!prt_sparklesmall : JSL SpawnParticle_NoSpeedAcc	; spawn small sparkle particle

		.Return
		RTL



; input: void
; output:
;	A = memory bit (0 if not marked)
;	Z = 0 if not marked, 1 if marked
;	$00 = index to item memory table (16-bit), only if valid index
;	$02 = which bit was checked (8-bit), only if valid index

; note: the !LevelWidth variable is NOT how many screens there can be in this mode, just how many are used
;	this is NOT a problem, future!Eric
;	it just means less of the table is used, but everything will still be mapped properly

	GetItemMem:
		LDA !HeaderItemMem				;\ return if invalid index
		CMP #$03 : BCC .Search				;/
		LDA #$00					;\ return with null output
		RTL						;/

		.Search
		PHX						; push X
		STA $00						; $00 = index (will be converted to 00 or 80)
		LSR A : STA $01					; $01 = -------I (hi bit of index)
		STZ $2250					;\
		REP #$20					; |
		LDA !SpriteYHi,x				; | y screen * level width
		AND #$00FF : STA $2251				; |
		LDA !LevelWidth					; |
		AND #$00FF : STA $2253				;/
		SEP #$20					;\
		LDA !SpriteXHi,x				; | + x screen
		CLC : ADC $2306					;/
		ASL A						; * 2
		BIT !SpriteXLo,x				;\ +1 on right half
		BPL $01 : INC A					;/
		ASL A						;\ get highest bit from index
		LSR $00						;/
		ROR A : STA $00					; $00 = iSSSSSSx

		LDA !SpriteXLo,x				;\
		AND #$70					; |
		LSR #4						; | get bit (reverse order because of course it is)
		TAX						; |
		LDA.l .Bits,x : STA $02				;/
		REP #$10					;\
		LDX $00						; | read item memory bit
		AND !ItemMem0,x					; |
		SEP #$10					;/

		.Return
		PLX						; pull X
		CMP #$00					; z
		RTL						; return

		.Bits
		db $80,$40,$20,$10,$08,$04,$02,$01




; input: sprite hurtbox loaded in $E8 slot
; output:
;	C set if contact, C clear if no contact
;	Y = thrown item sprite index
	ThrownItemContact:
		LDA !SpriteIFrames,x : BNE .Fail		; no contact during i-frames
		BIT !SpriteTweaker4,x : BVC .Process		; check for projectile immunity
		.Fail
		CLC						;\ return with no contact
		RTL						;/

		.Process
		LDX #$0F					; loop over all sprites

		.Loop
		CPX !SpriteIndex : BEQ .Next			; don't interact with self
		LDA !SpriteStatus,x				;\ search for sprites in state 0x0A
		CMP #$0A : BNE .Next				;/
		BIT !SpriteTweaker2,x : BVS .Next		;\ ignore sprites that don't interact with other sprites
		LDA !SpriteDisSprite,x : BNE .Next		;/
		JSL GetSpriteClippingE0
		JSL CheckContact : BCC .Next
		TXY
		BRA .Return

		.Next
		DEX : BPL .Loop
		CLC

		.Return
		LDX !SpriteIndex				; reload sprite index
		BCC ..done					;\
		LDA !SpriteTweaker4,x				; |
		AND #$02 : BEQ ..done				; | if there is contact, apply knockback unless sprite is immune
		LDA.w !SpriteXSpeed,y : STA !SpriteXSpeed,x	; |
		LDA.w !SpriteYSpeed,y : STA !SpriteYSpeed,x	;/

		..done
		RTL



; normal version just checks for contact
; _Destroy version will also destroy the fireball that touches the sprite (only 1 per frame, there is no way that this can cause problems, future Eric, i know what you're thinking!)
; input: sprite hurtbox loaded in $E8 slot
; output:
;	C set if contact, C clear if no contact
;	Y = fireball fusion index
;	$00: fireball X speed (converted to sprite format, but halved)
	FireballContact:
		LDA !SpriteIFrames,x : BNE .Fail		; no contact during i-frames
		BIT !SpriteTweaker4,x : BVS .Fail		; check for projectile immunity
		LDY #!Ex_Amount-1
	-	JSR .Main : BCS .Return
		DEY : BPL -
		.Fail
		CLC
		RTL

	.Destroy
		LDA !SpriteIFrames,x : BNE .Fail		; no contact during i-frames
		LDY #!Ex_Amount-1
	-	JSR .Main : BCS ..puff
		DEY : BPL -
		CLC
		RTL
		..puff
		STZ $00						; X speed output: default to 0
		LDA !Ex_Num,y					;\
		AND #$7F					; |
		CMP #!QuestionBlock_Num : BEQ .Return		; | blocks don't puff
		CMP #!Brick_Num : BEQ .Return			; |
		CMP #!BlockHitbox_Num : BEQ .Return		;/
		LDA #!TurnToPrt_Num : STA !Ex_Num,y		;\
		LDA.b #!prt_smoke16x16 : STA !Ex_Data1,y	; |
		LDA #$F0 : STA !Ex_Data3,y			; | turn to smoke puff (max prio)
		LDA !Ex_XSpeed,y : STA $00			; > fireball X speed output
		LDA #$00					; |
		STA !Ex_XSpeed,y				; |
		STA !Ex_YSpeed,y				;/
		LDA #$01 : STA !SPC1				; SFX
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
		AND #$42 : BNE ..done				; |
		LDA $00						; |
		LSR A						; | apply knockback unless sprite is immune (to knockback or projectiles)
		CMP #$40					; |
		BCC $02 : ORA #$80				; |
		STA !SpriteXSpeed,x				; |
		LDA #$E8 : STA !SpriteYSpeed,x			;/

		..done
		SEC						; set C
		RTL						; return


	; main JSR
		.Main
		LDA !Ex_Num,y
		AND #$7F
		CMP #!QuestionBlock_Num : BEQ ..check		; check ?-block
		CMP #!Brick_Num : BEQ ..check			; check brick
		CMP #!BlockHitbox_Num : BEQ ..check		; check block hitbox
		CMP #!MarFireball_Num : BEQ ..check		; check mario fireball
		CMP #!LuiFireball_Num : BNE ..returnc		; check luigi fireball
		..check
		LDA !Ex_XLo,y : STA $E0
		LDA !Ex_XHi,y : STA $E1
		LDA !Ex_YLo,y : STA $E2
		LDA !Ex_YHi,y : STA $E3
		LDA #$08
		STA $E4 : STZ $E5
		STA $E6 : STZ $E7
		PHY
		JSL CheckContact
		PLY
		RTS
		..returnc
		CLC
		RTS



; input: A = 16-bit pointer to hitbox data (hitbox based on facing left)
; output: hitbox loaded in $E8 slot (_E0 version loads in $E0 slot)
	LOAD_HITBOX:
	.E8
		REP #$30				; all regs 16-bit
		TAY					; Y = index to hitbox data
		SEP #$20				;\
		LDA !SpriteXLo,x : STA $E8		; |
		LDA !SpriteXHi,x : STA $E9		; | get sprite coords
		LDA !SpriteYHi,x : XBA			; |
		LDA !SpriteYLo,x			; |
		REP #$20				;/
		CLC : ADC $0002,y			;\ Y coord
		STA $EA					;/

		LDA $0004,y : STA $EE-1			; H (hi byte of size in $EE)
		AND #$00FF : STA $EC			; W, 16-bit

		LDA $0000,y				; read X offset
		SEP #$10				; index 8-bit
		LDY !SpriteDir,x : BNE ..left		; check direction
		..right					;\
		EOR #$FFFF				; |
		CLC : ADC #$0010			; | facing left adjustment
		SEC : SBC $EC				; |
		..left					;/
		CLC : ADC $E8				;\ add sprite Xpos and store
		STA $E8					;/
		SEP #$20				;\ clear hi byte of height
		STZ $EF					;/
		RTL					; return

	.E0
		REP #$30				; all regs 16-bit
		TAY					; Y = index to hitbox data
		SEP #$20				;\
		LDA !SpriteXLo,x : STA $E0		; |
		LDA !SpriteXHi,x : STA $E1		; | get sprite coords
		LDA !SpriteYHi,x : XBA			; |
		LDA !SpriteYLo,x			; |
		REP #$20				;/
		CLC : ADC $0002,y			;\ Y coord
		STA $E2					;/

		LDA $0004,y : STA $E6-1			; H (hi byte of size in $EE)
		AND #$00FF : STA $E4			; W, 16-bit

		LDA $0000,y				; read X offset
		SEP #$10				; index 8-bit
		LDY !SpriteDir,x : BNE ..left		; check direction
		..right					;\
		EOR #$FFFF				; |
		CLC : ADC #$0010			; | facing left adjustment
		SEC : SBC $E4				; |
		..left					;/
		CLC : ADC $E0				;\ add sprite Xpos and store
		STA $E0					;/
		SEP #$20				;\ clear hi byte of height
		STZ $E7					;/
		RTL					; return

; debug: display hitbox
;	PEI ($04)
;	PEI ($06)
;	PEI ($0A)
;	LDA !SpriteDir,x : PHA
;	LDA #$01 : STA !SpriteDir,x
;	LDA !SpriteXLo,x : PHA
;	LDA !SpriteXHi,x : PHA
;	LDA !SpriteYLo,x : PHA
;	LDA !SpriteYHi,x : PHA
;	LDA $04 : STA !SpriteXLo,x
;	LDA $0A : STA !SpriteXHi,x
;	LDA $05 : STA !SpriteYLo,x
;	LDA $0B : STA !SpriteYHi,x
;	REP #$20
;	LDA #$0010 : STA !BigRAM+$00
;	STZ !BigRAM+$03
;	STZ !BigRAM+$07
;	STZ !BigRAM+$0B
;	STZ !BigRAM+$0F
;	LDA #!BigRAM : STA $04
;	SEP #$20
;	LDA #$32
;	STA !BigRAM+$02
;	STA !BigRAM+$06
;	STA !BigRAM+$0A
;	STA !BigRAM+$0E
;	LDA #$6E
;	STA !BigRAM+$05
;	STA !BigRAM+$09
;	STA !BigRAM+$0D
;	STA !BigRAM+$11
;	LDA $06
;	SEC : SBC #$10
;	STA !BigRAM+$07
;	STA !BigRAM+$0F
;	LDA $07
;	SEC : SBC #$10
;	STA !BigRAM+$0C
;	STA !BigRAM+$10
;	JSL LOAD_TILEMAP_p3
;	PLA : STA !SpriteYHi,x
;	PLA : STA !SpriteYLo,x
;	PLA : STA !SpriteXHi,x
;	PLA : STA !SpriteXLo,x
;	PLA : STA !SpriteDir,x
;	REP #$20
;	PLA : STA $0A
;	PLA : STA $06
;	PLA : STA $04
;	SEP #$20
;	RTL




; input: hitbox loaded in E8 slot
; output: void
	OutputShieldBox:
		PHB
		LDA.b #!ShieldData>>16
		PHA : PLB
		TXA
		STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA $E8 : STA.w !ShieldXLo,y
		LDA $E9 : STA.w !ShieldXHi,y
		LDA $EA : STA.w !ShieldYLo,y
		LDA $EB : STA.w !ShieldYHi,y
		LDA $EC : STA.w !ShieldW,y
		LDA $EE : STA.w !ShieldH,y
		INC.w !ShieldExists
		PLB
		RTL



; input:
;	A = collision points to interact with (01 = right, 02 = left, 04 = down, 08 = up, 10 = center/crush point)
;	sprite clipping loaded in $E8 slot
; output: void
	OutputPlatformBox:
		PHX					; push X
		STA $00					; preserve status
		STZ $2250				;\
		STX $2251				; |
		STZ $2252				; | calculate platform data index
		LDA.b #!PlatformByteCount : STA $2253	; |
		STZ $2254				;/
		LDA !SpriteDeltaY,x : XBA		;\ sprite delta
		LDA !SpriteDeltaX,x			;/
		TXY					; Y = sprite index
		LDX $2306				; X = platform data index
		STA !PlatformDeltaX,x			;\ platform delta
		XBA : STA !PlatformDeltaY,x		;/
		TYA : STA !PlatformSprite,x		; platform sprite index
		LDA $00 : STA !PlatformStatus,x		; set status
		REP #$20				;\
		LDA $E8 : STA !PlatformXLeft,x		; |
		CLC : ADC $EC				; |
		STA !PlatformXRight,x			; | platform edges
		LDA $EA : STA !PlatformYUp,x		; |
		CLC : ADC $EE				; |
		STA !PlatformYDown,x			; |
		SEP #$20				;/
		LDA #$01 : STA !PlatformExists		; mark that players have to check for platform contact next frame
		PLX					; restore X
		RTL					; return


; input:
;	A = sprite num
;	C = custom bit
;	$00 = Xdisp (8-bit signed)
;	$01 = Ydisp (8-bit signed)
;	$02 = Xspeed
;	$03 = Yspeed
; output: Y = sprite index of spawned sprite (if Y = 0xFF, a sprite could not be spawned)
	SpawnSprite:
		STA $0E
		STZ $0F
		BCC $02 : INC $0F
		LDY #$0F
	.Loop	LDA !SpriteStatus,y : BEQ .Spawn
		DEY : BPL .Loop
		RTL

		.Spawn
		PEI ($02)
		LDA $00
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC !SpriteXLo,x
		STA !SpriteXLo,y
		LDA $02
		ADC !SpriteXHi,x
		STA !SpriteXHi,y
		LDA $01
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC !SpriteYLo,x
		STA !SpriteYLo,y
		LDA $02
		ADC !SpriteYHi,x
		STA !SpriteYHi,y
		LDA $0E : STA !SpriteNum,y
		LDA #$01 : STA !SpriteStatus,y
		LDA $0F : BNE .Custom
		.Vanilla
		LDA #$00 : BRA .Finish
		.Custom
		LDA #$08
		.Finish
		STA !ExtraBits,y
		PHY
		PHX
		TYX
		JSL !ResetSprite		; reset sprite tables
		PLX
		PLY
		PLA : STA.w !SpriteXSpeed,y
		PLA : STA.w !SpriteYSpeed,y
		RTL

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
; output: Y = number of spawned ExSprite
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
		PHX					;\
		TAX					; |
		LDA.l .Ex_Data1,x : STA !Ex_Data1,y	; | load special values
		LDA.l .Ex_Data2,x : STA !Ex_Data2,y	; |
		LDA.l .Ex_Data3,x : STA !Ex_Data3,y	; |
		PLX					;/

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


		.Ex_Data1
		db $00					; 00 empty
		db $00					; 01 mario fireball
		db $00					; 02 luigi fireball
		db $00					; 03 RESERVED
		db $00					; 04 RESERVED
		db $00					; 05 RESERVED
		db $00					; 06 RESERVED
		db $00					; 07 RESERVED
		db $00					; 08 malleable extended sprite
		db $00					; 09 hammer
		db $00					; 0A bone
		db $00					; 0B baseball
		db $00					; 0C small fireball
		db $00					; 0D big fireball
		db $00					; 0E tiny flame
		db $00					; 0F volcano lotus fire
		db $10					; 10 glitter
		db $00					; 11 question block
		db $00					; 12 brick
		db $00					; 13 block hitbox
		db $00					; 14 coin from block
		db $00					; 15 shooter
		db $00					; 16 torpedo arm
		db $00					; 17 dizzy star
		db $00					; 18 explosion
		db $00					; 19 turn to particle

		.Ex_Data2
		db $00					; 00 empty
		db $00					; 01 mario fireball
		db $00					; 02 luigi fireball
		db $00					; 03 RESERVED
		db $00					; 04 RESERVED
		db $00					; 05 RESERVED
		db $00					; 06 RESERVED
		db $00					; 07 RESERVED
		db $00					; 08 malleable extended sprite
		db $00					; 09 hammer
		db $00					; 0A bone
		db $00					; 0B baseball
		db $00					; 0C small fireball
		db $00					; 0D big fireball
		db $00					; 0E tiny flame
		db $00					; 0F volcano lotus fire
		db $00					; 10 glitter
		db $00					; 11 question block
		db $00					; 12 brick
		db $00					; 13 block hitbox
		db $00					; 14 coin from block
		db $00					; 15 shooter
		db $00					; 16 torpedo arm
		db $00					; 17 dizzy star
		db $00					; 18 explosion
		db $00					; 19 turn to particle

		.Ex_Data3
		db $00					; 00 empty
		db $00					; 01 mario fireball
		db $00					; 02 luigi fireball
		db $00					; 03 RESERVED
		db $00					; 04 RESERVED
		db $00					; 05 RESERVED
		db $00					; 06 RESERVED
		db $00					; 07 RESERVED
		db $00					; 08 malleable extended sprite
		db $00					; 09 hammer
		db $00					; 0A bone
		db $00					; 0B baseball
		db $00					; 0C small fireball
		db $00					; 0D big fireball
		db $00					; 0E tiny flame
		db $00					; 0F volcano lotus fire
		db $00					; 10 glitter
		db $00					; 11 question block
		db $00					; 12 brick
		db $00					; 13 block hitbox
		db $00					; 14 coin from block
		db $00					; 15 shooter
		db $00					; 16 torpedo arm
		db $00					; 17 dizzy star
		db $00					; 18 explosion
		db $00					; 19 turn to particle





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

	.NoSpeed
		STZ $02
		STZ $03
		JMP SpawnParticle

	.NoAcc
		STZ $04
		STZ $05
		JMP SpawnParticle

	.NoSpeedAcc
		STZ $02
		STZ $03
		STZ $04
		STZ $05
		JMP SpawnParticle


; input:
;	Y = index to pointer
;	$00 - X acc
;	$01 - Y acc
;	$02 - X speed (sprite format)
;	$03 - Y speed (sprite format)
;	$04 - pointer to tilemap
; output: $0E = index to spawned particle
	SpawnSpriteTile:
		PHX						; push X
		STY $0E						;\ $0E = 16-bit index to tilemap
		STZ $0F						;/
		LDA !SpriteTile,x : STA $06			; $06 = sprite tile offset lo
		LDA !SpriteProp,x				;\
		ORA !SpriteOAMProp,x				; | $07 = ----CCCT
		STA $07						;/
		LDA !SpriteXLo,x : STA $08			;\ $08 = 16-bit Xpos
		LDA !SpriteXHi,x : STA $09			;/
		LDA !SpriteYLo,x : STA $0A			;\ $0A = 16-bit Ypos
		LDA !SpriteYHi,x : STA $0B			;/
		STZ $0C						;\
		LDA !SpriteDir,x				; | $0C = flip bits for X coord
		BNE $02 : DEC $0C				;/

		PHB						; push bank
		JSL GetParticleIndex				; get particle index

		LDA $00 : STA !Particle_XAcc,x			; particle X acc
		STA !Particle_YAcc-1,x				; write particle Y acc with hi byte

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

		PLB						; restore bank
		LDY $0E						; Y = index to tilemap
		LDA ($04),y					;\
		BIT #$0001 : BEQ +				; |
		SEP #$20					; |
		AND #$EE					; |
		BIT $0C						; |
		BPL $02 : EOR #$40				; |
		LSR $07						; | static particle prop
		BCC $01 : INC A					; |
		ORA #$20					; |
		REP #$20					; |
		STA !41_Particle_Prop,x				; |
		LDA ($04),y					; |
		AND #$0010					; |
		BEQ $03 : LDA #$0002				; |
		BRA ++						;/
	+	LDA ($04),y					;\
		AND #$00F0					; |
		BIT $0C-1					; | dynamic particle prop
		BPL $03 : EOR #$0040				; |
		ORA $07						; |
		STA !41_Particle_Prop,x				;/
		LDA ($04),y					;\
		AND #$0002					; | particle size bit
	++	STA !41_Particle_Layer,x			;/
		INY						;\
		LDA ($04),y					; |
		EOR $0C						; |
		AND #$00FF					; | particle Xpos
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $08					; |
		STA !41_Particle_XLo,x				;/
		INY						;\
		LDA ($04),y					; |
		AND #$00FF					; |
		CMP #$0080					; | particle Ypos
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $0A					; |
		STA !41_Particle_YLo,x				;/
		INY						;\
		SEP #$20					; |
		LDA ($04),y					; | particle tile
		CLC : ADC $06					; |
		STA !41_Particle_Tile,x				;/

		LDA #$FF : STA !41_Particle_Timer,x		; particle timer
		LDA #!prt_spritepart : STA !41_Particle_Type,x	; particle type

		STX $0E						; $0E = index to spawned particle
		SEP #$30					; all regs 8-bit
		PLX						; restore X
		RTL						; return



; input: void
; output: void
	BigPuff:
		PHB : PHK : PLB
		LDY #$07
	-	LDA .SmokeX,y : STA $00
		LDA .SmokeY,y : STA $01
		LDA .SmokeXSpeed,y : STA $02
		LDA .SmokeYSpeed,y : STA $03
		STZ $04
		STZ $05
		LDA #$30 : STA $07
		PHY
		LDA.b #!prt_smoke16x16 : JSL SpawnParticle
		PLY
		DEY : BPL -
		PLB
		RTL

		.SmokeX
		db $08,$06
		.SmokeY
		db $00,$FA
		db $F8,$FA
		db $00,$06
		; extended cosine area
		db $08,$06

		.SmokeXSpeed
		db $10,$0C
		.SmokeYSpeed
		db $00,$FC
		db $F0,$F4
		db $00,$0C
		; extended cosine area
		db $10,$0C



; input: void
; output: void
	FrictionSmoke:
		TXA							;\
		EOR $14							; | spawn every 4 frames, order depends on sprite index
		AND #$03 : BNE .Return					;/
		LDA #$08						;\
		BIT !SpriteXSpeed,x					; | x offset
		BPL $02 : LDA #$00					; |
		STA $00							;/
		LDA #$0C : STA $01					; y offset
		LDA #$F0 : STA $07					; prio
		LDA.b #!prt_smoke8x8 : JSL SpawnParticle_NoSpeedAcc	; spawn 8x8 smoke puff
		.Return							;\ return
		RTL							;/



; input: A = GFX index
; output: !SpriteProp and !SpriteTile updated
	LoadGFXIndex:
		PHX
		REP #$30
		TAX
		LDA !GFX_status,x
		SEP #$30
		PLX
		STA !SpriteTile,x
		XBA : STA !SpriteProp,x
		RTL





; input:
; (targeting a player automatically)
;	A = speed
; (_Main: target player is already determined)
;	Y = target player index
;	$0F = speed
; output:
;	$04 = X speed
;	$06 = Y speed
	TARGET_PLAYER:
		STA $0F					; store speed
		LDY #$00				;\ if singleplayer, always target player 1
		LDA !MultiPlayer : BEQ .P1		;/
		LDA !P2Status-$80 : BNE .P2		; if player 1 is dead, target player 2
		LDA !P2Status : BNE .P1			; if player 2 is dead, target player 1
		LDA !RNG				;\
		AND #$80 : TAY				; | if both are alive, target a random player
		BRA .P1					;/
	.P2	LDY #$80
		.Main
	.P1	LDA !SpriteXLo,x			;\
		SEC : SBC !P2XPosLo-$80,y		; |
		STA $00					; | DX
		LDA !SpriteXHi,x			; |
		SBC !P2XPosHi-$80,y			; |
		STA $01					;/
		LDA !SpriteYLo,x			;\
		SEC : SBC !P2YPosLo-$80,y		; |
		STA $02					; | DY
		LDA !SpriteYHi,x			; |
		SBC !P2YPosHi-$80,y			; |
		STA $03					;/
		BRA AIM_SHOT_Main			; go to main code


; input:
;	A = speed
;	$00 = source X - target X
;	$02 = source Y - target Y
; output:
;	$04 = X speed
;	$06 = Y speed
;
; s = sqrt(dx^2 + dy^2)
;
; dx/x = s/0x40
;
; x = 0x40*dx/s
; y = 0x40*dy/s
;
; dx and dy are actually 15-bit.
	AIM_SHOT:
		STA $0F
	.Main	STZ $2250		; > Enable multiplication
		REP #$20
		STZ $0D			; > No shifts yet
		LDA $00
		BPL .Pos_dx
		EOR #$FFFF : INC A
.Pos_dx		STA $04			; $04 = |dx| (unscaled)

		LDA $02
		BPL .Pos_dy
		EOR #$FFFF
		INC A
.Pos_dy		STA $06			; $06 = |dy| (unscaled)
		LDY #$01		;\
		CMP $04			; | Load the largest of the two
		BCS $03 : LDA $04 : DEY	;/ > Y = 1, Y is bigger; Y = 0, X is bigger
		CMP #$0100 : BCC .0100	;\
		CMP #$0200 : BCC .0200	; |
		CMP #$0400 : BCC .0400	; |
		CMP #$0800 : BCC .0800	; |
		CMP #$1000 : BCC .1000	; |
		CMP #$2000 : BCC .2000	; | Downscale it
.4000		LSR A : INC $0D		; |
.2000		LSR A : INC $0D		; |
.1000		LSR A : INC $0D		; |
.0800		LSR A : INC $0D		; |
.0400		LSR A : INC $0D		; |
.0200		LSR A : INC $0D		; |
.0100		STA $08			;/
		LDA $06			;\
		CMP $04			; | Load the smaller of the two
		BCC $02 : LDA $04	;/

.Loop		DEC $0D : BMI .Scaled	;\ Downscale the other number
		LSR A : BRA .Loop	;/
.Scaled		CPY #$01 : BEQ .BigY	; > Determine which number is biggest
.BigX		STA $2251		;\
		STZ $2253		; |
		NOP			; | Calculate Y^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate X^2
		NOP			; |
		BRA .Shared		;/

.BigY		STA $2251		;\
		STA $2253		; |
		NOP			; | Calculate X^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate Y^2
		NOP			; |
		BRA .Shared		;/

.Shared		LDA $2306
		CLC : ADC $0A
		JSL GetRoot		; (handles 17-bit numbers)
		ROR A
		LSR #7
		STA $0A			; > $0A = distance
		LDA $0F
		AND #$00FF
		STA $2251
		LDA $04 : STA $2253
		NOP
		BRA $00
		LDA $2306
		STA $04			; > $04 = v*|dx|
		LDA $06 : STA $2253
		NOP
		BRA $00
		LDA $2306		; > A = v*|dy|
		LDY #$01 : STY $2250	; > Enable division
		STA $2251
		LDA $0A
		STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $02 : BMI +
		EOR #$00FF
		INC A
	+	STA $06			; > $06 = y
		LDA $04 : STA $2251
		LDA $0A : STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $00 : BMI +
		EOR #$00FF
		INC A
	+	STA $04			; > $04 = x
		SEP #$20
		RTL




;==========================;
; PLAYER INTERACTION CODES ;
;==========================;
; most of these require input Y = 0x00 for player 1 or 0x80 for player 2
; the sprite itself is responsible for making sure that player exists before calling a routine


; input: Y = player index
; output: void
	StompSound:
		PHX
		LDA !P2KillCount-$80,y
		CMP #$07 : BCS .Shared
		INC A
		STA !P2KillCount-$80,y
		DEC A
		.Shared
		TAX
		CPX #$06
		BCC $02 : LDX #$06
		LDA.l .StarSounds,x : STA !SPC1
		.NoSound
		PLX
		RTL

		.StarSounds
		db $13,$14,$15,$16,$17,$18,$19

; input: Y = player index
; output: void
	SPRITE_STAR:
		PHX
		LDA #$02 : STA !SpriteStatus,x
		LDA #$E8 : STA !SpriteYSpeed,x
		LDA !P2XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA $78D2
		CMP #$08 : BCS +
		INC A : STA $78D2
	+	TAX
		CPX #$06
		BCC $02 : LDX #$06
		LDA.l StompSound_StarSounds,x : STA !SPC1
		PLX
		RTL





; input: void
; output:
;	C clear = no contact, C set = contact
;	runs P2Attack, FireballContact_Destroy and ThrownItemContact
; notes:
;	most sprites can simply call this routine to handle most of its attack interaction
;	generally, this should be called followed by "damage sprite" code, and then P2Standard
	InteractAttacks:
		JSL P2Attack : BCS .Return
		JSL FireballContact_Destroy : BCS .Return
		JMP ThrownItemContact
		.Return
		RTL



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
		CMP $E8 : BCC ..nocontact				; |
		LDA $E8							; |
		CLC : ADC $EC						; |
		CMP !P2Hitbox1X-$80,y : BCC ..nocontact			; |
		LDA !P2Hitbox1H-$80,y					; |
		AND #$00FF						; | check for hitbox contact
		CLC : ADC !P2Hitbox1Y-$80,y				; |
		CMP $EA : BCC ..nocontact				; |
		LDA $EA							; |
		CLC : ADC $EE						; |
		CMP !P2Hitbox1Y-$80,y					; |
		SEP #$20						; |
		BCS .YesContact						; |
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
		AND #$08 : BNE ..nocombo				;/ (this needs 2 checks)
		LDA $0C
		CMP #$06 : BCC ..small
		TYA
		AND #$80 : TAY
		LDA !P2Character-$80,y
		CMP #$02 : BNE ..gosmall
		JSL P2BigContactGFX
		BRA ..nocombo
		..small
		TYA
		AND #$80 : TAY
		..gosmall
		JSL P2HitContactGFX
		LDA !P2Character-$80,y
		CMP #$03 : BNE ..nocombo
		LDA #$08 : STA !P2ComboDash-$80,y
		..nocombo
		PLY
		LDA !P2Hitbox1DisTimer-$80,y : JSL DontInteract		; interaction disable

		.Knockback						;\
		LDA !SpriteTweaker4,x					; |
		AND #$02 : BNE ..done					; | apply knockback unless sprite is immune to it
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
		BEQ $03 : LDA #$0220				; set lowest c bit as well as add 0x20 to tile num
		CLC : ADC.w #!P2Tile7-$20
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
		PLX
		RTL



; input: A = player contact bits
; output: void
	BouncePlayers:
		.P1
		LSR A : BCC ..done
		PHA
		JSL P2Bounce
		PLA
		..done

		.P2
		LSR A : BCS P2Bounce
		RTL


; input: Y = player index
; output: void
	P2Bounce:
		LDA #$00 : STA !P2SpecialUsed-$80,y		; refund special
		PHX						; preserve X
		LDX !P2Character-$80,y : BNE .ReadInput		; X = player character
		.Mario						;\
		LDA !P2FireCharge-$80,y : BNE .ReadInput	; |
		INC A						; | mario fire flash code
		STA !P2FireCharge-$80,y				; |
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
		PHX
		.P1
		LSR A : BCC .P2
		LDX !P2Direction-$80
		LDY !P2Character-$80
		CPY #$02 : BCS .Kick
		LDY #$08 : STY !P2KickTimer-$80
		BRA .Kick

		.P2
		LSR A : BCC .ReturnX
		LDX !P2Direction
		LDY !P2Character
		CPY #$02 : BCS .Kick
		LDY #$08 : STY !P2KickTimer
		.Kick
		LDA.l .KickSpeed,x
		PLX
		STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x

		.Return
		RTL

		.ReturnX
		PLX
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
; note: if "can be jumped on" = 0, crush state will not crush the sprite
	P2Standard:
		STZ $00
		STZ $01
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
		AND #$10 : BNE .NoStar			;/
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

		.Bounce
		LDA #$08 : JSL DontInteract		; interaction disable when stomping sprite: 8 frames
		INC $00
		JSL P2Bounce
	;	LDA !SpriteTweaker4,x			;\
	;	AND #$04 : BNE .NoCrush			; | check for crush property unless sprite is immune to it
	;	LDA !P2Crush-$80,y : BNE .Crush		;/
	;	.NoCrush
		JSL StompSound

		LDA !SpriteYSpeed,x : BPL ..done	;\ reset sprite Y speed if it's moving up when stomped
		STZ !SpriteYSpeed,x			;/
		..done

		RTS

		.HurtPlayer
		LDA !dmg : BMI ..done			; negative damage = can't hurt player
		LDA #$0F : JSL DontInteract		; interaction disable when hurt by sprite: 15 frames
		LDA !dmg : PHA				;\
		TYA					; |
		CLC : ROL #2				; | hurt (make sure damage value is applied to both players!)
		INC A					; |
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
;	Y = index to ANIM table (after update)
;	$04 = 16-bit tilemap pointer
	UPDATE_ANIM:
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
		LDA ($04),y : STA !SpriteAnimIndex,x	; | update anim, get new index, reset timer
		ASL #2 : TAY				; |
		LDA #$00				;/

		.SameAnim				;\ write timer
		STA !SpriteAnimTimer,x			;/
		REP #$20				;\
		LDA ($00),y : STA $04			; | output tilemap pointer
		SEP #$20				;/
		RTL					; return


; input:
;	A = 16-bit pointer to ANIM table (6-byte wide)
;	X = sprite index
; output:
;	updates !SpriteAnimIndex and !SpriteAnimTimer
;	$04 = 16-bit tilemap pointer
;	$0C = 16-bit square dynamo pointer
; notes:
;	the sprite itself is responsible for determining when a new frame is loaded
;	this is because this routine is just one way that the animation can change
;	if the sprite changes animations due to performing an action, this routine would not know
;	because of this, the sprite has to handle that itself
	UPDATE_ANIM_SQUARE:
		STA $00					; $00 = pointer to ANIM+0 (tilemap pointer)
		INC #2 : STA $0C			; $0C = pointer to ANIM+2 (dynamo pointer)
		INC #2 : STA $02			; $02 = pointer to ANIM+4 (timer value)
		INC A : STA $04				; $04 = pointer to ANIM+5 (next anim)
		SEP #$20				;\
		LDA !SpriteAnimIndex,x			; |
		ASL #2 : TAY				; | get index, increment timer, compare to threshold time
		LDA !SpriteAnimTimer,x			; |
		INC A					; |
		CMP ($02),y : BNE .SameAnim		;/

		.NewAnim				;\
		LDA ($04),y : STA !SpriteAnimIndex,x	; | update anim, get new index, reset timer
		ASL #2 : TAY				; |
		LDA #$00				;/

		.SameAnim				;\ write timer
		STA !SpriteAnimTimer,x			;/
		REP #$20				;\
		LDA ($00),y : STA $04			; | output tilemap pointer and square dynamo pointer
		LDA ($0C),y : STA $0C			; |
		SEP #$20				;/
		RTL					; return



; these routines can be used by sprites to load an OAM tilemap
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
;	for carryable items, DRAW_CARRIED can be used to detect whether _p1 or _p2 should be used based on the carrying player's animation
;
;	DRAW_SIMPLE: draws tile 0 (PSUEDO_DYNAMIC) as a 16x16 tile with no offset, prio 1 (sprite) and prio 2 (PP bits)
;		_0	draws tile 0
;		_2	draws tile 2
;		_4	draws tile 4
;		_6	draws tile 6
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
	.p2	LDA #$04 : BRA .Shared
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
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
	+	LDY $04
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

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA $0000,y				;\
		AND #$20				; |
		STA $0A					; | YXP-CCCT
		LDA $0000,y				; | (lower P bit is size bit)
		AND.b #$10^$FF				; |
		ORA $0A					; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/

		LDA $0000,y				;\
		AND #$10				; | tile size bit
		BEQ $02 : LDA #$02			; |
		STA $0A					;/
		STZ $0B					;\ n flag trigger
		BEQ $02 : DEC $0B			;/

		REP #$20
		INY

		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC
		BIT $0E
		BPL $01 : SEC
		ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

		.GoodX
		STA $06					; temp tile xpos
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA $0000,y : STA !OAM_p0+$002,x
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
	.End	RTS



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_TILEMAP_COLOR:
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p2	LDA #$04 : BRA .Shared
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

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA $0000,y				;\
		AND #$02 : STA $0A			; |
		STZ $0B					;\ n flag trigger (for size bit)
		BEQ $02 : DEC $0B			;/
		LDA $0000,y				; | YXPP--ST
		AND.b #$0E^$FF				; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/


		REP #$20
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC
		BIT $0E
		BPL $01 : SEC
		ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

		.GoodX
		STA $06					; temp tile xpos
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA $0000,y : STA !OAM_p0+$002,x
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
	.End	RTS



	SETUP_CARRIED:
		LDA !SpriteStatus,x
		CMP #$0B : BNE .HandleDir_nodir
		TXA
		INC A
		CMP !P2Carry-$80 : BNE .P2
	.P1	LDY #$00 : BRA .HandlePrio
	.P2	LDY #$80

		.HandlePrio
		LDA !P2Character-$80,y : BEQ ..mario
		CMP #$01 : BNE ..prio1
		..luigi
		LDA !P2Anim-$80,y
		CMP #!Lui_Turn : BNE ..prio1
		..prio2
		LDA #$01
		RTL
		..mario
		LDA !P2Anim-$80,y
		CMP #!Mar_Turn : BEQ ..prio2
		..prio1

		.HandleDir
		LDA !SpriteStatus,x
		CMP #$0B : BNE ..nodir
		LDA !P2Character-$80,y
		CMP #$02 : BEQ ..reverse
		..normal
		LDA !P2Direction-$80,y
		EOR #$01 : BRA ..setdir
		..reverse
		LDA !P2Direction-$80,y
		..setdir
		STA !SpriteDir,x
		..nodir
		LDA #$00
		RTL


	DRAW_CARRIED:
		BEQ .Prio2
		.Prio3
		JMP LOAD_PSUEDO_DYNAMIC_p3
		.Prio2
		JMP LOAD_PSUEDO_DYNAMIC_p2


; input: void
; output: void
	DRAW_SIMPLE:
	.0	LDY #$00 : BRA .Main
	.2	LDY #$02 : BRA .Main
	.4	LDY #$04 : BRA .Main
	.6	LDY #$06
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


; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_PSUEDO_DYNAMIC:
	.p2	LDA #$04 : BRA .Shared
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
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
		LDA !SpriteProp,x			;\
		ORA !SpriteOAMProp,x			; | prop base
		AND #$00FF				; |
		STA $0C					;/
		STZ $0E
		LDA !SpriteDir,x
		LSR A : BCS +
		LDA #$0040 : TSB $0C
		DEC $0E
	+	LDY $04
		LDA !SpriteTile,x			;\
		AND #$00FF				; | dynamic tile
		STA !BigRAM+$7C				;/
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

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA $0000,y				; read prop byte
		BIT #$01 : BEQ ..dynamicprop		; check which format this is

		..staticprop				;\
		AND #$FE				; > only clear c bit
		STA $07					; |
		EOR $0C					; | get static prop
		AND #$E1				; > get XY, flip X, get T bit
		STA $06					; |
		LDA $07					; |
		AND #$0E				; > get CCC bits
		ORA $64					; > add global PP bits
		ORA $06					; |
		STA !OAM_p0+$003,x			;/
		LDA $07					;\
		AND #$10				; | get size bit
		BEQ $02 : LDA #$02			; |
		BRA ..propdone				;/

		..dynamicprop				;\
		AND #$F0				; |
		EOR $0C					; | get dynamic prop
		ORA $64					; |
		STA !OAM_p0+$003,x			;/
		LDA $0000,y				;\ S bit
		AND #$02				;/

		..propdone
		STA $0A					; write S bit
		BEQ $02 : LDA #$80			;\ n flag trigger
		STA $0B					;/

		REP #$20
		INY

		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC
		BIT $0E
		BPL $01 : SEC
		ADC $00
		BIT $0A : BMI +
		BIT $0E : BPL +
		CLC : ADC #$0008			; add 8 to x-flipped 8x8 tile
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .L
		RTS

		.GoodX
		STA $06					; $06 = 16-bit tile xpos
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		BRA .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x		; lo byte of tile xpos
		INY
		LDA $0000,y
		CLC : ADC !BigRAM+$7C
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
		ORA $0A					; tile size bit
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
	LOAD_DYNAMIC:
	.p2	LDA #$04 : BRA .Shared
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
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
		LDA !SpriteOAMProp,x
		AND #$000E
		STA $0C
		STZ $0E
		LDA !SpriteDir,x
		LSR A : BCS +
		LDA #$0040 : TSB $0C
		DEC $0E
	+	LDY $04
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

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA $0000,y				; read prop byte
		BIT #$01 : BEQ ..dynamicprop		; check which format this is

		..staticprop				;\
		AND #$FE				; > only clear c bit
		STA $07					; |
		EOR $0C					; | get static prop
		AND #$E1				; > get XY, flip X, get T bit
		STA $06					; |
		LDA $07					; |
		AND #$0E				; > get CCC bits
		ORA $64					; > add global PP bits
		ORA $06					; |
		STA !OAM_p0+$003,x			;/
		LDA $07					;\
		AND #$10				; | get size bit
		BEQ $02 : LDA #$02			; |
		BRA ..propdone				;/

		..dynamicprop				;\
		AND #$F0				; |
		EOR $0C					; | get dynamic prop
		ORA $64					; |
		STA !OAM_p0+$003,x			;/
		LDA $0000,y				;\ S bit
		AND #$02				;/

		..propdone
		STA $0A					; write S bit
		BEQ $02 : LDA #$80			;\ n flag trigger
		STA $0B					;/

		REP #$20
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC
		BIT $0E
		BPL $01 : SEC
		ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .L
		RTS

		.GoodX
		STA $06					; tile xpos
		INY
		LDA $0000,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		STA !OAM_p0+$001,x
		LDA #$0000				; clear B
		SEP #$20
		LDA $06 : STA !OAM_p0+$000,x
		INY
		PHX
		LDA $0000,y : TAX			; X hi has to be clear
		LDA !DynamicProp,x : STA $06		; -------T flip for dynamic tile
		LDA $F0,x
		PLX
		STA !OAM_p0+$002,x			; tile num
		LDA !OAM_p0+$003,x
		EOR $06
		STA !OAM_p0+$003,x
		PHX
		INY
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
	.End	RTS







;=====================;
; SQUARE DYNAMO CODES ;
;=====================;
;
; draw dynamic procedure:
;	- LOAD_SQUARE_DYNAMO to load the square dynamo (this step can be skipped if there is no dynamo update this frame)
;	- SETUP_SQUARE to get the table for which dynamic tile to use for each sprite tile (this is not included in LOAD_DYNAMIC since that would be a waste for sprites that combine tilemaps)
;	- LOAD_DYNAMIC to draw to OAM
;




; this routine generates a tile table in $F0-$FF (lo byte) and !DynamicProp (hi byte)
; this table is indexed by the sprite's tile numbers, and the read byte is used as a replacement
; NOTE:
;	dynamic sprites have to use tile numbers in the $00-$0F range
;	this number is which of its claimed tiles to use, not the actual OAM tile
;	$00 is the first claimed tile, $01 is the second claimed tile, and so on
;	most sprites don't use more than a few dynamic tiles, but theoretically one could use up to 0xF for a full 128x64 size
; this routine should never mess with $04 since that is used so often in OAM routines


; input: X = sprite index
; output: $F0 = dynamic tile use table
	SETUP_SQUARE:
		PHX
		PHP
		SEP #$30
		TXA
		ASL A : TAX
		REP #$20
		LDA !DynamicList,x : STA $00
		LDY #$00						; starting dynamic tile number
		LDX #$00						; starting tile number

		.Loop							;\
		STY $F0,x						; |
		LSR $00							; | dynamic tile nums for all 16 possible tiles
		BCC $01 : INX						; |
		INY #2							; |
		CPY #$20 : BCC .Loop					;/

		.Complete
		SEP #$20						;\
		LDX #$0F						; |
		..loop							; |
		LDY $F0,x						; | get full tile numbers from matrix
		LDA !DynamicMatrix+0,y : STA $F0,x			; |
		LDA !DynamicMatrix+1,y : STA !DynamicProp,x		; |
		DEX : BPL ..loop					;/
		PLP
		PLX
		RTL





; RAM use:
; $00	current bit being checked
; $02	accumulating tiles this sprite will claim
; $0E	how many tiles are left to check
;
; input:
;	A = number of tiles to claim
;	X = sprite number
; output:
;	$00 = bits representing which tiles this sprite claimed
;	C clear if there weren't enough free tiles (sprite should not spawn), C set if tiles were claimed without problems
	GET_SQUARE:
		PHX							; push sprite index
		REP #$20						; A 16-bit
		AND #$000F						;\ number of tiles to check
		STA $0E							;/
		LDA #$0001 : STA $02					; starting bit
		STZ $00							; starting accumulation
		LDX #$0F						; starting loop counter (number of bits to check)

	.Loop	LDA !DynamicTile					;\
		AND $02 : BEQ .TakeOne					; | see if this tile is free
		ASL $02							; |
	.Loop2	DEX : BPL .Loop						;/
		.Fail							;\
		SEP #$20						; |
		PLX							; | if there aren't enough free tiles, fail and return
		CLC							; |
		RTL							;/

		.TakeOne						;\
		LDA $02 : TSB $00					; | if tile is free, prelim mark it as used and loop
		ASL $02							; |
		DEC $0E : BPL .Loop2					;/

		.Success						;\
		LDA $00 : TSB !DynamicTile				; |
		LDA $01,s						; |
		AND #$00FF						; |
		ASL A							; |
		TAX							; | if there were enough free tiles, mark the claimed ones as used and return
		LDA $00 : STA !DynamicList,x				; |
		SEP #$20						; |
		PLX							; |
		SEC							; |
		RTL							;/


; RAM use:
; $00	remaining tiles to use
; $02	size of square dynamo
; $0C	pointer to square dynamo
;
; input:
;	X = sprite index
;	Y = ID of file to load from (call _Main to ignore input Y, use with first input setting file or hardcoding address)
;	$0C = pointer to square dynamo
; output: void
	LOAD_SQUARE_DYNAMO:
		JSL GetFileAddress					; get file address

		.Main							;\
		PHX							; |
		PHP							; |
		REP #$30						; | push stuff and get index to !DynamicList
		TXA							; |
		ASL A							; |
		TAX							;/
		LDA !DynamicList,x : STA $00				; $00 = which dynamic tiles are in use
		LDX #$0000						; X = square table index
		LDA ($0C) : BEQ .Return					; if size = 0, return
		INC $0C							;\
		INC $0C							; | $02 = ending index
		CLC : ADC $0C						; | Y = addr,y index
		STA $02							; |
		LDY $0C							;/

		.Loop							;\ return if at end of dynamo
		CPY $02 : BCS .Return					;/
		LDA $0000,y : BPL .LoadTile				; check tile
		INY #2							; Y+2 for command
		CMP #$C000 : BCC .GetFile				; check file address update
		CMP #$E000 : BCC .SkipTiles				; check tile skip


		.SuperDynamicAddress					;\
		PHX							; | SD index
		AND #$00FF : TAX					;/
		LDA !SD_status-1,x					;\
		AND #$FC00						; | get address
		STA !FileAddress					;/
		LDA !SD_status,x					;\
		AND #$0003 : TAX					; | get bank
		LDA.l .SD_bank,x : STA !FileAddress+2			;/
		PLX							;\ loop
		BRA .Loop						;/

		.SD_bank
		db $7E,$7F,$40,$41

		.Return							;\
		PLP							; | pull stuff
		PLX							;/
		RTL							; return

		.SkipTiles						;\
		AND #$000F : BEQ .Loop					; |
		PHA							; |
		STX $0C							; | add skip count * 4 to X
		ASL #2							; |
		ADC $0C							; |
		TAX							;/
		PLA							;\
	-	LSR $00							; | shift $00 once per skip count
		DEC A : BEQ .Loop					; |
		BRA -							;/

		.GetFile						;\
		PHY							; |
		AND #$7FFF : TAY					; | get file address
		JSL GetFileAddress					; |
		PLY							; |
		JMP .Loop						;/

		.LoadTile						;\ see if tile is in use
	..loop	LSR $00 : BCC ..nextone					;/
		..thisone						;\ source bank
		LDA !FileAddress+1 : STA !VRAMbase+!SquareTable+1,x	;/
		LDA $0000,y						;\
		CLC : ADC !FileAddress+0				; | source address
		STA !VRAMbase+!SquareTable+0,x				;/
		INC !DynamicCount					; 1 more tile in use
		INY #2							; increment index
		INX #4							;\ increment output index and return if at end
		CPX #$0040 : BCS .Return				;/
		JMP .Loop						; loop
		..nextone						;\
		INX #4							; | otherwise loop until all tiles have been checked
		CPX #$0040 : BCC ..loop					;/

		PLP							;\ pull stuff
		PLX							;/
		RTL							; return





