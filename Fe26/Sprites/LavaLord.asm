LavaLord:


; to do:
;	- ring is off for first frame of toss
;	- toss frame order
;	- particle control
;	- AI: attack selection
;	- phase 2






; GFX = $369808


	namespace LavaLord

	!LavaLordPhase		= !BossData+0		; 0 = phase 1
							; 1 = transition to phase 2
							; 2 = phase 2
							; 3 = desperation attack

	!LavaLordHP		= !BossData+1

	!LavaLordRNG1		= !BossData+2		; make sure boss has access to 4 RNG values every frame
	!LavaLordRNG2		= !BossData+3
	!LavaLordRNG3		= !BossData+4
	!LavaLordRNG4		= !BossData+5

	!LavaLordEnrageTimer	= !BossData+6


	!LavaLordScreen		= $BE,x			; yeah, really
	!LavaLordAttack		= $3280,x
	!LavaLordAttackTimer	= $3290,x
	!LavaLordForceMove	= $32A0,x		; set when inside danger zone or offscreen
	!LavaLordTarget		= $32B0,x		; used for Flamestrike

	!LavaLordFloatHeight	= $32C0,x		; boss will attempt to float at this height

	!LavaLordStunTimer	= $32D0,x


	!AttackMemory		= $6DF5			; < Technically an OW sprite table, but who cares
	!PreviousFrame		= $6DF6
	!PalFrame		= $6DF7			;
	!PalTimer		= $6DF8			;
	!PalSpeed		= $6DF9			; amount of steps to advance palette rotation each frame
	!LavaLordPrevAttack	= $6DFA			; lo nybble previous, hi nybble one before that



macro LavaLordDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+$369808
	dw <DestVRAM>*$10+$6000
endmacro


	INIT:
		PHB : PHK : PLB
		STZ !LavaLordPhase
		LDA $3210,x : STA !LavaLordFloatHeight	; remember spawn height
		LDA $3250,x : STA !LavaLordScreen	; remember spawn screen (X)
		LDA !MultiPlayer : PHP
		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_HP,y
		PLP : BEQ $01 : ASL A			; HP is doubled on multiplayer
		STA !LavaLordHP

		LDA #$01 : STA !PalSpeed		; base speed of 1/frame


;	LDA #$02 : STA !LavaLordPhase


		PLB
		RTL


	DATA:
		.HP
		db $0C,$10,$14,$14

		.XSpeed
		db $20,$E0
		db $30,$D0

		.XAcc
		db $04,$FC
		db $08,$F8

		.WarpCoords
		db $30,$C0
		db $40,$D0

		.WarpDestination
		db $E0,$20				; lo byte
		db $FF,$01				; added to hi byte

		.FlameStrikeDelay
		db $40,$38,$30,$28			; frames before drop (-20)
		db $50,$48,$40,$38			; frames for particle animation

		.FlameStrikeX
		db $F0,$E8,$E0,$D0
		db $FF,$FF,$FF,$FF

		.FlameStrikeCount
		db $02,$03,$04,$06


	MAIN:
		LDA !GameMode
		CMP #$14 : BEQ .Yes
		RTL

		.Yes
		PHB : PHK : PLB

		LDA !ExtraBits,x : BMI .Skip

		.UploadRing
		ORA #$80 : STA !ExtraBits,x
		LDA.b #ANIM_InitDyn : STA $0C
		LDA.b #ANIM_InitDyn>>8 : STA $0D
		CLC : JSL !UpdateGFX
		.Skip


		LDA $14
		AND #$3F : BNE .NoIncrement		; enrage timer goes up every 64 frames
		LDA !LavaLordEnrageTimer
		CMP #$B4 : BEQ .NoIncrement		; caps at 180 seconds
		INC !LavaLordEnrageTimer
		.NoIncrement


		LDA $3250,x
		CMP !LavaLordScreen : BNE .OffScreen
		LDA !LavaLordForceMove
		CMP #$02
		BCC $03 : DEC !LavaLordForceMove
		.OffScreen


		LDA !LavaLordAttackTimer : BNE +++
		STZ !LavaLordAttack

	LDA !RNG
	AND #$03

BRA +					; temporary skip to test out exsprite version

	CMP #$02 : BNE +		;\
	STZ $00				; |
	LDY #$0F			; |
-	LDA $3230,y			; |
	CMP #$08 : BNE ++		; |
	LDA $3200,y			; |
	CMP #$1D : BNE ++		; | reroll summon flame if there are 2 or more on-screen already
	INC $00				; |
++	DEY : BPL -			; |
	LDA #$02			; |
	LDY $00				; |
	CPY #$03 : BCC +		; |
	LDA #$01			; |
	BIT !RNG			; |
	BPL $02 : INC #2		;/

+	STA $00
	LDA !LavaLordPrevAttack
	AND #$0F
	STA $01
	LDA !LavaLordPrevAttack
	LSR #4
	CMP $01 : BNE .Ok
	CMP $00 : BNE .Ok
	LDA $00
	INC A
	AND #$03
	BRA .Atk

.Ok	LDA $00					;\
.Atk	STA !LavaLordAttack			; |
	LDA !LavaLordPrevAttack			; | attack memory
	ASL #4					; |
	ORA !LavaLordAttack			; |
	STA !LavaLordPrevAttack			;/
	CMP #$03 : BNE ++
	LDA !RNG
	AND #$80 : STA !LavaLordTarget
	STZ $AE,x
	++


	LDA #$80 : STA !LavaLordAttackTimer

		BRA ++
	+++	DEC !LavaLordAttackTimer
		++




		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ ATTACK
		JMP GRAPHICS





	ATTACK:
		PEA PHYSICS-1
		LDA !LavaLordAttack
		ASL A
		CMP.b #.Nothing-.Ptr : BCS .Return
		PHX
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Nothing			; 0
		dw Fireball			; 1
		dw SummonFlame			; 2
		dw Flamestrike			; 3
		dw ReturnFromFlameStrike	; 4 (only used in phase 2)
		dw WallOfFlame			; 5
		dw FireBarrage			; 6
		dw Eruption			; 7
		dw Enrage			; 8
		dw Desperation			; 9
		dw JumpBack			; A



		.Nothing
		PLX
		JSR DefaultMovement
	.Return	RTS




	; scatter shot: all projectiles cluster toward the same target

	Fireball:
		PLX
		JSR DefaultMovement
		LDY !LavaLordAttackTimer
		CPY #$30 : BNE +
		LDA #$09 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	+	CPY #$10 : BNE ATTACK_Return		; Attack happens at t = 0x10 to make time for animation backswing

	.Shoot	LDA !Difficulty
		AND #$03
		TAY
		LDA .ProjectileCount,y
		TAY
	.Loop	PHY
		JSL !GetSpriteSlot
		BPL .Spawn
		PLY
		RTS

	.Spawn	JSL SPRITE_A_SPRITE_B_COORDS_Long
		LDA $3320,x : PHA			; push dir
		LDA #$07				;\  > Custom sprite number
		TYX					; | > X = new sprite index
		STA !NewSpriteNum,x			; |
		LDA #$36				; | > Acts like
		STA $3200,x				; |
		LDA #$08				; | > MAIN routine
		STA $3230,x				; |
		JSL $07F7D2				; | > Reset sprite tables
		JSL $0187A7				; | > Reset custom sprite tables
		PLA : STA $3320,x			; > dir for new sprite
		LDA #$08				; |
		STA !ExtraBits,x			;/
		LDA #$FF				;\ Life timer
		STA $32D0,x				;/
		LDA #$E0				;\ Graphic tile
		STA $33D0,x				;/
		LDA #$01 : STA $35D0,x			; > Spin type
		LDA #$01 : STA $3410,x			; > Hard prop
		LDA #$36 : STA $33C0,x			; > YXPPCCCT

		LDA !RNG				;\
		AND #$80				; |
		TAY					; |
		LDA $3220,x				; |
		SEC : SBC !P2XPosLo-$80,y		; |
		STA $00					; |
		LDA $3250,x				; |
		SBC !P2XPosHi-$80,y			; |
		STA $01					; | aim shot
		LDA $3240,x : XBA			; |
		LDA $3210,x				; |
		REP #$20				; |
		SEC : SBC !P2YPosLo-$80,y		; |
		STA $02					; |
		SEP #$20				; |
		LDA #$30				; |
		JSL AIM_SHOT_Long			;/

		PLY					; Y = loop index
		LDA !LavaLordRNG1,y			;\
		PHA					; |
		AND #$1F				; |
		SEC : SBC #$10				; |
		CLC : ADC $04				; |
		STA $AE,x				; | apply random speed modifier
		PLA					; |
		LSR #5					; |
		SEC : SBC #$10				; |
		CLC : ADC $06				; |
		STA $9E,x				;/

		LDA $3220,x				;\
		CLC : ADC .OffsetLo+0,y			; |
		STA $3220,x				; |
		LDA $3250,x				; |
		ADC .OffsetHi+0,y			; |
		STA $3250,x				; | apply offset
		LDA $3210,x				; |
		CLC : ADC .OffsetLo+2,y			; |
		STA $3210,x				; |
		LDA $3240,x				; |
		ADC .OffsetHi+2,y			; |
		STA $3240,x				;/

		LDX !SpriteIndex			; Restore X
		DEY : BMI .Done				; Loop until done
		JMP .Loop

	.Done	RTS



	.ProjectileCount
		db $00,$01,$03,$03	; number of loops, so it spawns 1 more than it says in the table

	.OffsetLo			; +0 for X, +2 for Y
		db $00,$08,$00,$F8
		db $00,$08
	.OffsetHi
		db $00,$00,$00,$FF	; +0 for X, +2 for Y
		db $00,$00


	SummonFlame:
		PLX

		STZ $9E,x
		STZ $AE,x

		LDA !SpriteAnimIndex
		CMP #$0E : BCS +
		LDA #$0E : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$03 : STA.l !3D_Base+$480+$2E4
		+


	;	JSR DefaultMovement


		LDA !LavaLordAttackTimer : BEQ +
		CMP #$20 : BEQ .Spawn
		RTS
	+	STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$10 : STA.l !3D_Base+$480+$2E4
		RTS

		.Spawn
		LDA $3220,x : PHA
		LDA $3250,x : PHA
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA #$14 : STA $3220,x
		LDA !LavaLordScreen : STA $3250,x
		LDA $1C : STA $3210,x
		LDA $1D : STA $3240,x
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		STZ $04					; no X speed
		LDA #$10 : STA $05			; falling Y speed
		LDA #$86				; type 6, pattern X+16, Y+0 (we'll double Xpos later)
		LDY #$06				; spawn 6 ExSprites
		JSL SpawnExSprite_Long

		LDY #$07
	-	LDA !ExSpriteNum,y
		CMP #$09 : BNE +
		LDA !ExSpriteTimer,y
		CMP #$FF : BNE +
		LDA #$44 : STA !ExSpriteTimer,y		; set life timer
		LDA !ExSpriteXPosLo,y			; double the gap here
		ASL A
		STA !ExSpriteXPosLo,y
	+	DEY : BPL -


		PLA : STA $3240,x
		PLA : STA $3210,x
		PLA : STA $3250,x
		PLA : STA $3220,x


		RTS




		LDA !LavaLordAttackTimer
		CMP #$20 : BNE .Return

		LDY #$01				;\
		LDA !Difficulty				; |
		AND #$03 : BNE +			; | spawn from a random direction on EASY
		LDA !RNG				; |
		LSR A : BCC +				; |
		DEY					;/

	+
	-	PHY
		JSL !GetSpriteSlot
		BMI .ReturnY
		LDA #$1D : STA $3200,y
		TYX
		JSL $07F7D2				; | > Reset sprite tables
		LDA #$01 : STA $3230,x
		PLY
		LDA .CoordsLo,y : STA $3220,x
		LDA .CoordsHi,y : STA $3250,x
		LDA #$E0 : STA $3210,x
		STZ $3240,x
		LDA .Speed,y : STA $AE,x
		LDA #$C0 : STA $9E,x
		LDX !SpriteIndex
		LDA !Difficulty				;\ only one flame on EASY
		AND #$03 : BEQ .Return			;/
		DEY : BPL -

		.Return
		RTS

		.ReturnY
		PLY
		RTS

		.CoordsLo
		db $E0,$10

		.CoordsHi
		db $FF,$01

		.Speed
		db $30,$D0


	Flamestrike:
		PLX
		LDA.l !Difficulty
		AND #$03
		TAY
		LDA DATA_FlameStrikeDelay+0,y : STA $00
		LDA DATA_FlameStrikeDelay+4,y : STA $01
		LDY !LavaLordAttackTimer : BNE +
		LDA #$04 : STA !LavaLordAttack
		JMP ReturnFromFlameStrike_Hook


	+	CPY $01 : BNE +
		LDA #$02 : STA.l !3D_Base+$480+$2E4		; speed up particle spawn rate
	+	CPY $00 : BNE +
		LDA #$10 : STA !PalSpeed			; speed up palette rotation
	+	CPY #$20
		BEQ .Go
		BCS .Hover
		JMP .Fall


	.Hover	LDA !SpriteAnimIndex
		CMP #$03 : BCC +
		CMP #$06 : BCC ++
	+	LDA #$03 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		++

		LDA $3210,x
		CMP !LavaLordFloatHeight : BCC .GoodHeight
		LDA $9E,x
		SEC : SBC #$04
		STA $9E,x
		BRA .Rise

	.GoodHeight
		STZ $9E,x
	.Rise	LDA.l !Difficulty
		AND #$03
		TAY
		LDA !LavaLordAttackTimer
		CMP DATA_FlameStrikeDelay+0,y : BCS .Target
		STZ $AE,x
		BRA .Return

	.Target	LDY !LavaLordTarget
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		CMP !P2XPosLo-$80,y
		SEP #$20
		LDA #$00
		BCC $01 : INC A
		STA $3320,x
		TAY
		LDA DATA_XSpeed+2,y : BPL ..R
	..L	LDA $AE,x
		CLC : ADC DATA_XAcc+2,y
		BPL .Ok
		CMP DATA_XSpeed+2,y : BCS .Ok
		BRA .MaxSpd

	..R	LDA $AE,x
		CLC : ADC DATA_XAcc+2,y
		BMI .Ok
		CMP DATA_XSpeed+2,y : BCC .Ok
	.MaxSpd	LDA DATA_XSpeed+2,y
	.Ok	STA $AE,x
		RTS


	.Go	LDA #$40 : STA $9E,x				; start falling
		STZ $AE,x					; no Xspeed
		LDA !LavaLordAttack
		ORA #$80
		STA !LavaLordAttack
		LDA #$06  : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer


	.Fall	LDA $3330,x
		AND #$04 : BNE .Impact
		LDA $3240,x : BEQ +
		STZ !LavaLordAttack
		LDA #$FF : STA !LavaLordAttackTimer
	.Return	RTS

	+	LDA #$1F : STA !LavaLordAttackTimer
		RTS

	.Impact	STZ $9E,x
		LDA !ShakeTimer : BNE .Return
		LDA #$1F : STA !ShakeTimer
		LDA #$01 : STA !PalSpeed			; reset palette rotation speed
		LDA #$10 : STA.l !3D_Base+$480+$2E4		; reset particle spawn rate

		LDA.l !Difficulty
		AND #$03
		TAY
		LDA DATA_FlameStrikeX+0,y : STA $00
		LDA DATA_FlameStrikeX+4,y : STA $01
		LDA DATA_FlameStrikeCount,y



	.Loop	PHA
		JSL !GetSpriteSlot
		BPL .Spawn
		PLA
		RTS

	.Spawn	LDA $3210,x : STA $3210,y		;\ copy Y coords
		LDA $3240,x : STA $3240,y		;/
		LDA $3220,x				;\
		CLC : ADC $00				; |
		STA $3220,y				; |
		LDA $3250,x				; |
		ADC $01					; |
		STA $3250,y				; | get X coords
		LDA $00					; |
		CLC : ADC #$10				; |
		PHA					; |
		LDA $01					; |
		ADC #$00				; |
		PHA					;/

		LDA #$29				;\  > Custom sprite number
		TYX					; | > X = new sprite index
		STA !NewSpriteNum,x			; |
		LDA #$36				; | > Acts like
		STA $3200,x				; |
		LDA #$08				; | > MAIN routine
		STA $3230,x				; |
		JSL $07F7D2				; | > Reset sprite tables
		JSL $0187A7				; | > Reset custom sprite tables
		LDA #$08				; |
		STA !ExtraBits,x			;/
		LDA #$40				;\ Life timer
		STA $32D0,x				;/

		PLA : STA $01
		PLA : STA $00

		LDX !SpriteIndex

		PLA
		DEC A : BPL .Loop


		RTS


	ReturnFromFlameStrike:
		PLX

	.Hook	LDA !LavaLordAttack : BMI .Main

		.Init
		ORA #$80
		STA !LavaLordAttack
		LDA $3220,x
		LSR #4
		TAY
		LDA .XSpeed,y : STA $AE,x
		LDA #$D0 : STA $9E,x
		LDA #$20 : STA !LavaLordAttackTimer
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.Main
		LDA !LavaLordAttackTimer : BNE .Process
		LDA $AE,x				;\
		AND.b #$03^$FF				; | prevent speed underflow glitch
		STA $AE,x				;/
		LDA #$33 : STA !LavaLordPrevAttack	; can't flamestrike twice in a row
		RTS

		.Process
		LDA !LavaLordPhase
		AND #$7F
		BNE .Return
		DEC $9E,x				;\ very low gravity for float
		DEC $9E,x				;/

	.Return	RTS


		.XSpeed
		db $06,$00,-$06,-$0C,-$12,-$18,-$1E,-$24
		db $24,$1E,$18,$12,$0C,$06,$00,-$06


	WallOfFlame:
		PLX
		JSR DefaultMovement
		RTS


	FireBarrage:
		PLX
		JSR DefaultMovement
		LDA !LavaLordAttackTimer
		CMP #$40 : BEQ .Fire
		CMP #$20 : BEQ .Fire
		RTS

	.Fire	JMP Fireball_Shoot


	Eruption:
		PLX
		RTS


	Enrage:
		PLX
		RTS


	Desperation:
		PLX
		RTS


	JumpBack:
		PLX
		RTS





	PHYSICS:

		LDA !LavaLordStunTimer : BNE .Return

		JSL !SpriteApplySpeed
		.Return





	INTERACTION:

	GRAPHICS:



	;;;;;;;;;;;;;;;;;;;;;;
	; ExSprite animation ;
	;;;;;;;;;;;;;;;;;;;;;;
		LDY #$07
	-	LDA !ExSpriteNum,y
		CMP #$09 : BNE +
		LDA !ExSpriteTimer,y		;\
		CMP #$01 : BNE ++		; |
		STA !ExSpriteNum,y		; | transform to smoke puff on last frame
		LDA #$0F : STA !ExSpriteTimer,y	; |
		BRA +				;/

	++	AND #$04
		ASL A
		CLC : ADC #$27
		ORA #$80
		STA !ExSpriteMisc,y
		LDA #$25 : STA !ExSpriteBehindBG1,y
	+	DEY : BPL -
	;;;;;;;;;;;;;;;;;;;;;;;


		PHX
		LDX #$00
		LDA !PalFrame
		ASL A
		TAY
		REP #$20

	.Loop	LDA $6847,y : STA $0E		;\
		AND #$001F			; |
		STA $00				; |
		LDA $0E				; |
		LSR #5				; |
		AND #$001F			; | first color
		STA $04				; |
		LDA $0E				; |
		XBA				; |
		LSR #2				; |
		AND #$001F			; |
		STA $08				;/

		INY #2
		CPY #$16 : BNE $02 : LDY #$00	; number of bytes for full palette, this should be larger than upload
		LDA $6847,y : STA $0E		;\
		AND #$001F			; |
		STA $02				; |
		LDA $0E				; |
		LSR #5				; |
		AND #$001F			; | second color
		STA $06				; |
		LDA $0E				; |
		XBA				; |
		LSR #2				; |
		AND #$001F			; |
		STA $0A				;/

		PHX
		LDX #$08			; 8 because we're doing 3 colors with 2 bytes each (0xC-0x4)
		STZ $2250
	-	LDA $00,x : STA $2251
		LDA !PalTimer
		AND #$00FF
		STA $2253
		NOP
		BRA $00
		LDA $2306
		LSR #4
		STA $00,x
		LDA $02,x : STA $2251
		LDA #$0010
		SEC : SBC !PalTimer
		AND #$001F
		STA $2253
		NOP
		BRA $00
		LDA $2306
		LSR #4
		CLC : ADC $00,x
		STA $00,x
		DEX #4 : BPL -
		PLX

		LDA $08
		ASL #5
		ORA $04
		ASL #5
		ORA $00
		STA $40F000,x				; compile mixed color data into RAM

		INX #2
		CPX #$0C : BEQ .Done			; number of bytes for color data
		JMP .Loop
	.Done	SEP #$20


		LDA !PalTimer
		CLC : ADC !PalSpeed
		CMP #$11 : BCC +			; number of frames it takes to rotate 1 step, +1
		LDA !PalFrame
		DEC A : BPL ++
		LDA #$0A				; number of steps per rotation, -1 (distinct from data size)
	++	STA !PalFrame
		LDA #$00
	+	STA !PalTimer


		JSL !GetCGRAM
		PHB
		LDA.b #!VRAMbank
		PHA : PLB
		LDA #$40				; bank
		STA.w !CGRAMtable+$4,y
		STA.w !CGRAMtable+$A,y
		REP #$20
		LDA #$F000				; address
		STA.w !CGRAMtable+$2,y
		STA.w !CGRAMtable+$8,y
		LDA #$000C				; size of color data
		STA.w !CGRAMtable+$0,y
		STA.w !CGRAMtable+$6,y
		SEP #$20
		LDA #$A3 : STA.w !CGRAMtable+$5,y	; dest color 1
		LDA #$E1 : STA.w !CGRAMtable+$B,y	; dest color 2
		PLB
		PLX


		LDA !SpriteAnimIndex
		ASL A
		STA $00
		ASL #2
		CLC : ADC $00
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP ANIM+2,y : BNE .Same
		LDA ANIM+3,y : STA !SpriteAnimIndex
		ASL A
		STA $00
		ASL #2
		CLC : ADC $00
		TAY
		LDA #$00

	.Same	STA !SpriteAnimTimer
		TYA
		CMP !PreviousFrame
		STA !PreviousFrame
		BEQ .NoUpdate
		LDA ANIM+4,y : STA $0C
		LDA ANIM+5,y : STA $0D
		BEQ .NoUpdate				; value of 00 means no dynamo
		CLC : JSL !UpdateGFX
		LDY !PreviousFrame
		.NoUpdate




		REP #$20
		LDA ANIM+8,y : STA $00
		STZ $02
		STZ $06
		LDA ANIM+6,y : BEQ .NoRing
	.Ring	JSL LakituLovers_TilemapToRAM_Long
	.NoRing	STZ $00
		LDA ANIM+0,y : JSL LakituLovers_TilemapToRAM_Long
		LDA.w #!BigRAM : STA $04
		SEP #$20
		CPY #$5A : BCC .Draw
		CPY #$6E+1 : BCS .Draw


	; fireball spin animation

	.Fire	LDA $14
		LSR #2
		AND #$03
		TAY
		LDA ANIM_FireballProp,y : STA !BigRAM+$06
		LDA ANIM_FireballX,y : STA !BigRAM+$07
		LDA ANIM_FireballTile,y : STA !BigRAM+$09

	.Draw	JSL LOAD_TILEMAP_Long



		.Return
		LDA $14					;\
		AND #$03				; | store this at the end of each frame
		TAY					; |
		LDA !RNG : STA !LavaLordRNG1,y		;/

		PLB
		RTL




	ANIM:
		dw .IdleTM : db $09,$01			; 00
		dw .IdleDyn00
		dw .RingTM00 : db $00,$0C
		dw .IdleTM : db $09,$02			; 01
		dw .IdleDyn01
		dw .RingTM01 : db $00,$0C
		dw .IdleTM : db $09,$00			; 02
		dw .IdleDyn02
		dw .RingTM02 : db $00,$0C

		dw .HoverTM : db $09,$04		; 03
		dw .HoverDyn00
		dw .RingTM00V : db $00,$F0
		dw .HoverTM : db $09,$05		; 04
		dw .HoverDyn01
		dw .RingTM01V : db $00,$F0
		dw .HoverTM : db $09,$03		; 05
		dw .HoverDyn02
		dw .RingTM02V : db $00,$F0

		dw .StrikeTM : db $04,$07		; 06
		dw .StrikeDyn00
		dw $0000,$0000
		dw .StrikeTM : db $04,$08		; 07
		dw .StrikeDyn01
		dw $0000,$0000
		dw .StrikeTM : db $04,$06		; 08
		dw .StrikeDyn02
		dw $0000,$0000

		dw .TossTM00 : db $0B,$0A		; 09
		dw .TossDyn00
		dw .RingTM00 : db $00,$0C
		dw .TossTM00 : db $0B,$0B		; 0A
		dw .TossDyn00
		dw .RingTM01 : db $00,$0C
		dw .TossTM00 : db $0B,$0C		; 0B
		dw .TossDyn00
		dw .RingTM02 : db $00,$0C
		dw .IdleTM : db $04,$0D			; 0C
		dw .TossDyn01
		dw .RingTM01 : db $00,$0E
		dw .TossTM01 : db $08,$00		; 0D
		dw .TossDyn02
		dw .RingTM00 : db $06,$10

		dw .ChannelTM : db $04,$0F		; 0E
		dw .ChannelDyn00
		dw .RingTM00 : db $00,$0C
		dw .ChannelTM : db $04,$10		; 0F
		dw .ChannelDyn01
		dw .RingTM01 : db $00,$0C
		dw .ChannelTM : db $04,$11		; 10
		dw .ChannelDyn00
		dw .RingTM02 : db $00,$0C
		dw .ChannelTM : db $04,$12		; 11
		dw .ChannelDyn01
		dw .RingTM00 : db $00,$0C
		dw .ChannelTM : db $04,$13		; 12
		dw .ChannelDyn00
		dw .RingTM01 : db $00,$0C
		dw .ChannelTM : db $04,$0E		; 13
		dw .ChannelDyn01
		dw .RingTM02 : db $00,$0C



	.RingTM00
	dw $0004
	db $29,$00,$00,$60

	.RingTM01
	dw $0004
	db $29,$00,$00,$62

	.RingTM02
	dw $0004
	db $29,$00,$00,$64

	.RingTM00V
	dw $0004
	db $A9,$00,$00,$60

	.RingTM01V
	dw $0004
	db $A9,$00,$00,$62

	.RingTM02V
	dw $0004
	db $A9,$00,$00,$64


	.FireballProp
	db $36,$36,$F6,$F6

	.FireballX
	db $10,$10,$F0,$F0

	.FireballTile
	db $E0,$E2,$E0,$E2




	.IdleTM
	dw $0018
	db $25,$F8,$F0,$00
	db $25,$08,$F0,$02
	db $25,$F8,$00,$20
	db $25,$08,$00,$22
	db $25,$F8,$10,$40
	db $25,$08,$10,$42

	.HoverTM
	dw $0024
	db $25,$F4,$F0,$00
	db $25,$04,$F0,$02
	db $25,$0C,$F0,$03
	db $25,$F4,$00,$20
	db $25,$04,$00,$22
	db $25,$0C,$00,$23
	db $25,$F4,$08,$30
	db $25,$04,$08,$32
	db $25,$0C,$08,$33

	.StrikeTM
	dw $0018
	db $25,$FC,$F0,$00
	db $25,$04,$F0,$01
	db $25,$FC,$00,$20
	db $25,$04,$00,$21
	db $25,$FC,$10,$40
	db $25,$04,$10,$41

	.TossTM00
	dw $0020
	db $36,$10,$F0,$E0
	db $25,$00,$F0,$02
	db $25,$10,$F0,$04
	db $25,$F0,$00,$20
	db $25,$00,$00,$22
	db $25,$10,$00,$24
	db $25,$F0,$10,$40
	db $25,$00,$10,$42
	.TossTM01
	dw $0010
	db $25,$FC,$F0,$00
	db $25,$04,$F0,$01
	db $25,$04,$00,$21
	db $25,$04,$10,$41

	.ChannelTM
	dw $001C
	db $25,$F0,$F0,$00
	db $25,$00,$F0,$02
	db $25,$10,$F0,$04
	db $25,$F8,$00,$21
	db $25,$08,$00,$23
	db $25,$F8,$10,$41
	db $25,$08,$10,$43



	.InitDyn
	dw ..End-..Start
	..Start
	%LavaLordDyn(2, $08E, $160)
	%LavaLordDyn(2, $09E, $170)
	%LavaLordDyn(2, $0AE, $162)
	%LavaLordDyn(2, $0BE, $172)
	%LavaLordDyn(2, $0A4, $164)
	%LavaLordDyn(2, $0B4, $174)
	..End


	.IdleDyn00
	dw ..End-..Start
	..Start
	%LavaLordDyn(4, $004, $100)
	%LavaLordDyn(4, $014, $110)
	%LavaLordDyn(4, $024, $120)
	%LavaLordDyn(4, $034, $130)
	%LavaLordDyn(4, $044, $140)
	%LavaLordDyn(4, $054, $150)
	..End
	.IdleDyn01
	dw ..End-..Start
	..Start
	%LavaLordDyn(4, $008, $100)
	%LavaLordDyn(4, $018, $110)
	%LavaLordDyn(4, $028, $120)
	%LavaLordDyn(4, $038, $130)
	%LavaLordDyn(4, $048, $140)
	%LavaLordDyn(4, $058, $150)
	..End
	.IdleDyn02
	dw ..End-..Start
	..Start
	%LavaLordDyn(4, $000, $100)
	%LavaLordDyn(4, $010, $110)
	%LavaLordDyn(4, $020, $120)
	%LavaLordDyn(4, $030, $130)
	%LavaLordDyn(4, $040, $140)
	%LavaLordDyn(4, $050, $150)
	..End


	.HoverDyn00
	dw ..End-..Start
	..Start
	%LavaLordDyn(5, $120, $100)
	%LavaLordDyn(5, $130, $110)
	%LavaLordDyn(5, $140, $120)
	%LavaLordDyn(5, $150, $130)
	%LavaLordDyn(5, $160, $140)
	..End
	.HoverDyn01
	dw ..End-..Start
	..Start
	%LavaLordDyn(5, $125, $100)
	%LavaLordDyn(5, $135, $110)
	%LavaLordDyn(5, $145, $120)
	%LavaLordDyn(5, $155, $130)
	%LavaLordDyn(5, $165, $140)
	..End
	.HoverDyn02
	dw ..End-..Start
	..Start
	%LavaLordDyn(5, $12A, $100)
	%LavaLordDyn(5, $13A, $110)
	%LavaLordDyn(5, $14A, $120)
	%LavaLordDyn(5, $15A, $130)
	%LavaLordDyn(5, $16A, $140)
	..End


	.StrikeDyn00
	dw ..End-..Start
	..Start
	%LavaLordDyn(3, $0C6, $100)
	%LavaLordDyn(3, $0D6, $110)
	%LavaLordDyn(3, $0E6, $120)
	%LavaLordDyn(3, $0F6, $130)
	%LavaLordDyn(3, $106, $140)
	%LavaLordDyn(3, $116, $150)
	..End
	.StrikeDyn01
	dw ..End-..Start
	..Start
	%LavaLordDyn(3, $0C9, $100)
	%LavaLordDyn(3, $0D9, $110)
	%LavaLordDyn(3, $0E9, $120)
	%LavaLordDyn(3, $0F9, $130)
	%LavaLordDyn(3, $109, $140)
	%LavaLordDyn(3, $119, $150)
	..End
	.StrikeDyn02
	dw ..End-..Start
	..Start
	%LavaLordDyn(3, $0CC, $100)
	%LavaLordDyn(3, $0DC, $110)
	%LavaLordDyn(3, $0EC, $120)
	%LavaLordDyn(3, $0FC, $130)
	%LavaLordDyn(3, $10C, $140)
	%LavaLordDyn(3, $11C, $150)
	..End


	.TossDyn00
	dw ..End-..Start
	..Start
	%LavaLordDyn(4, $062, $102)
	%LavaLordDyn(4, $072, $112)
	%LavaLordDyn(6, $080, $120)
	%LavaLordDyn(6, $090, $130)
	%LavaLordDyn(4, $0A0, $140)
	%LavaLordDyn(4, $0B0, $150)
	..End
	.TossDyn01
	dw ..End-..Start
	..Start
	%LavaLordDyn(4, $00C, $100)
	%LavaLordDyn(4, $01C, $110)
	%LavaLordDyn(4, $02C, $120)
	%LavaLordDyn(4, $03C, $130)
	%LavaLordDyn(4, $04C, $140)
	%LavaLordDyn(4, $05C, $150)
	..End
	.TossDyn02
	dw ..End-..Start
	..Start
	%LavaLordDyn(3, $066, $100)
	%LavaLordDyn(3, $076, $110)
	%LavaLordDyn(2, $087, $121)
	%LavaLordDyn(2, $097, $131)
	%LavaLordDyn(2, $0A7, $141)
	%LavaLordDyn(2, $0B7, $151)
	..End


	.ChannelDyn00
	dw ..End-..Start
	..Start
	%LavaLordDyn(6, $069, $100)
	%LavaLordDyn(6, $079, $110)
	%LavaLordDyn(4, $08A, $121)
	%LavaLordDyn(4, $09A, $131)
	%LavaLordDyn(4, $0AA, $141)
	%LavaLordDyn(4, $0BA, $151)
	..End
	.ChannelDyn01
	dw ..End-..Start
	..Start
	%LavaLordDyn(6, $0C0, $100)
	%LavaLordDyn(6, $0D0, $110)
	%LavaLordDyn(4, $0E1, $121)
	%LavaLordDyn(4, $0F1, $131)
	%LavaLordDyn(4, $101, $141)
	%LavaLordDyn(4, $111, $151)
	..End



	Palette:
		dw $0011,$0417,$001D,$04DF,$15BF,$12FF,$1FFF,$035F




	DefaultMovement:
		LDA !SpriteAnimIndex
		CMP #$03 : BCC +
		CMP #$09 : BCS +
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		+



		LDA !LavaLordStunTimer : BEQ .Process
		RTS


	.Process
		LDA !LavaLordPhase
		AND #$7F : BEQ .Float
		JMP .Ground


		.Float
		LDA $3250,x
		CMP !LavaLordScreen : BEQ ..move

		JMP ScreenWrap






	..move	LDA $3220,x : STA $08
		LDA $3250,x : STA $09
		REP #$20
		STZ $00
		STZ $02
		STZ $04
		STZ $06
		PHX
		LDX #$00
		LDY #$00
	-	LDA !P2Status-$80,y
		AND #$00FF : BNE ..next
		LDA !P2XPosLo-$80,y
		SEC : SBC #$0020
		STA $00,x
		CLC : ADC #$0050
		STA $04,x
		INX #2

	..next	CPY #$80 : BEQ ..check
		LDY #$80 : BRA -

	..check	LDY #$00
		LDA $08
		LDX #$02
	-	CMP $00,x : BCC ..no
		CMP $04,x : BCS ..no
		INY
	..no	DEX #2 : BPL -

		PLX
		SEP #$20


		TYA : BNE ..force
		LDA !LavaLordForceMove
		CMP #$01 : BNE ..end
		STZ !LavaLordForceMove
		BRA ..end

	..force	LDA !LavaLordForceMove : BNE +
		LDA !RNG				; pick random direciton
		AND #$01 : STA $3320,x			;
	+	LDA #$10 : STA !LavaLordForceMove	; if within at least one danger zone

	..end	LDA !LavaLordForceMove : BEQ ..drift

		LDY $3320,x
		LDA $AE,x
		CMP DATA_XSpeed,y : BEQ ..Y
		CLC : ADC DATA_XAcc,y
		STA $AE,x
		BRA ..Y


	..drift	PHX
		PHP
		REP #$30
		LDA $14
		ASL A
		AND #$01FE
		TAX
		LDA.l !TrigTable,x
		LSR #4
		PLP
		PLX
		SEC : SBC #$0A
		AND.b #$03^$FF
		STA $AE,x
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x

	..Y	LDA $3240,x
		BMI ..down
		BNE ..up
		LDA $3210,x
		CMP !LavaLordFloatHeight
		LDA $9E,x
		BCC +
		SEC : SBC #$04
		BPL ++
		CMP #$F0 : BCS ++
	..up	LDA #$F0 : BRA ++

	+	DEC #2
		CMP #$10 : BCC ++
	..down	LDA #$10
	++	STA $9E,x

		RTS


		.Ground

		LDA $3330,x
		AND #$04 : BEQ .Air
		STZ $9E,x
		.Air

		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x

		STZ $AE,x


		RTS


	ScreenWrap:
		LDA !LavaLordForceMove
		CMP #$20 : BEQ .Main

		.Init
		LDA #$20 : STA !LavaLordForceMove
		LDA $3220,x
		ROL #2
		AND #$01
		STA $3320,x

		.Main
		STZ $9E,x
		LDY $3320,x
		LDA $AE,x
		CMP DATA_XSpeed,y : BEQ +
		CLC : ADC DATA_XAcc,y
		STA $AE,x

	+	LDA $3220,x
		CMP DATA_WarpCoords+0,y : BCC .Return
		CMP DATA_WarpCoords+2,y : BCS .Return
		LDA DATA_WarpDestination+0,y : STA $3220,x
		LDA !LavaLordScreen
		CLC : ADC DATA_WarpDestination+2,y
		STA $3250,x

	.Return	RTS




	namespace off