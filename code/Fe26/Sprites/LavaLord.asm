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
	!LavaLordTarget		= $32B0,x		; used for targeting one player throughout an attack

	!LavaLordFloatHeight	= $32C0,x		; boss will attempt to float at this height

	!LavaLordStunTimer	= $32D0,x


	!AttackMemory		= $6DF5			; < Technically an OW sprite table, but who cares
	!PreviousFrame		= $6DF6
	!PalFrame		= $6DF7			;
	!PalTimer		= $6DF8			;
	!PalSpeed		= $6DF9			; amount of steps to advance palette rotation each frame

	!ExtrasLoaded		= $6DFA			; used to load scaled up GFX
	!LavaLordAura		= $6DFB			; when non-zero, aura image will be displayed
	!BGFraction		= $6DFC			; used for aura display
	!AuraFraction		= $6DFD			; used for aura display



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

		LDA #$FF : STA !PreviousFrame
		STZ !AttackMemory
		STZ !ExtrasLoaded
		STZ !PalFrame
		STZ !LavaLordAura
		LDA #$20 : STA !BGFraction		; full BG color
		STZ !AuraFraction			; no aura color


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
		LDA !ExtraBits,x : BMI .Skip			;\
		.UploadRing					; |
		ORA #$80 : STA !ExtraBits,x			; |
		LDA.b #ANIM_InitDyn : STA $0C			; | load ring GFX
		LDA.b #ANIM_InitDyn>>8 : STA $0D		; |
		CLC : JSL !UpdateGFX				; |
		.Skip						;/


		LDA $14						;\
		LSR : BCC .DontLoad				; |
		LDA !ExtrasLoaded				; |
		CMP #$06 : BCS .DontLoad			; | render and load scaled-up GFX
		JSR ScaleUp					; |
		INC !ExtrasLoaded				; |
		.DontLoad					;/



		LDA $3230,x					;\
		SEC : SBC #$08					; |
		ORA $9D						; | pause/glitch check
		BEQ .Main					; |
		JMP GRAPHICS					; |
		.Main						;/


		LDA $14
		AND #$3F : BNE .NoIncrement			; enrage timer goes up every 64 frames
		LDA !LavaLordEnrageTimer
		CMP #$B4 : BEQ .NoIncrement			; caps at 180 seconds
		INC !LavaLordEnrageTimer
		.NoIncrement




		LDA !LavaLordAura : BEQ .AuraDown		; > check aura direction
		LDA !BGFraction : BEQ .AuraUp			;\
	.BGDown	DEC A						; |
		STA !BGFraction					; |
		BRA .Update					; | fade BG out then aura in
	.AuraUp	LDA !AuraFraction				; |
		CMP #$20 : BEQ $01 : INC A			; |
		STA !AuraFraction				; |
		BRA .Update					;/

	.AuraDown						;\
		LDA !AuraFraction : BEQ .BGUp			; |
		DEC A						; |
		STA !AuraFraction				; | fade aura out then BG in
		BRA .Update					; |
	.BGUp	LDA !BGFraction					; |
		CMP #$20 : BEQ $01 : INC A			; |
		STA !BGFraction					;/

		.Update						;\
		LDA !BGFraction					; |
		LDY #$00 : JSR FadeBG				; |
		LDA !BGFraction					; | update palette for BG and aura GFX
		LDY #$10 : JSR FadeBG				; |
		LDA !AuraFraction				; |
		LDY #$F0 : JSR FadeBG				; |
		.AuraDone					;/



		LDA $3250,x					;\
		CMP !LavaLordScreen : BNE .OffScreen		; |
		LDA !LavaLordForceMove				; | forced movement
		CMP #$02					; |
		BCC $03 : DEC !LavaLordForceMove		; |
		.OffScreen					;/

		LDA !LavaLordAttackTimer : BEQ .NewAttack
		JMP .GotAttack

	.NewAttack
		LDA !RNG					;\
		AND #$03					; |
		STA $00						; |
		LDA !AttackMemory				; |
		AND #$0F					; |
		STA $01						; |
		LDA !AttackMemory				; | roll an attack
		LSR #4						; | ...but never the same more than twice in a row
		CMP $01 : BNE .Ok				; |
		CMP $00 : BNE .Ok				; |
		LDA $00						; |
		INC A						; |
		AND #$03					; |
		BRA .Atk					;/

	.Ok	LDA $00						;\
	.Atk	STA !LavaLordAttack				; |
		LDA !RNG					; \ random target
		AND #$80 : STA !LavaLordTarget			; /
		LDA #$80 : STA !LavaLordAttackTimer		; > attack timer
		LDA !AttackMemory				; | attack memory
		ASL #4						; |
		ORA !LavaLordAttack				; |
		STA !AttackMemory				;/
		CMP #$03 : BNE ATTACK
		STZ $AE,x
		LDA !RNG					;\
		AND #$7F					; | random attack time for Flamestrike
		ORA #$80					; |
		STA !LavaLordAttackTimer			;/
		BRA ATTACK

	.GotAttack
		DEC !LavaLordAttackTimer




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
	+	CPY #$10 : BNE ATTACK_Return		; Attack happens at t = 0x10 to make time for backswing

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

	.Spawn	JSL SPRITE_A_SPRITE_B_COORDS
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
		SEC : SBC #$30				; |
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

		LDA !AttackMemory
		AND #$F0
		CMP #$20 : BNE .NoAura

		LDA !LavaLordAura : BEQ +
		LDA !MultiPlayer : BEQ .t
		LDA !RNG
		AND #$80
	.t	STA !LavaLordTarget
	+	LDA #$01 : STA !LavaLordAura
		LDA !LavaLordAttackTimer : STA !ShakeTimer
		.NoAura



		LDA !SpriteAnimIndex
		CMP #$0E : BCS +
		LDA #$0E : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$03 : STA.l !3D_Base+$480+$2E4
		+


	;	JSR DefaultMovement


		LDA !LavaLordAttackTimer : BEQ +
		LDY !LavaLordAura : BEQ .Wave

	.Volley	AND #$0F : BNE .R
		LDY !LavaLordTarget
		LDA !P2XPosLo-$80,y : STA $00
		LDA !P2XPosHi-$80,y : STA $01

		LDY #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ .SpawnVolley
		DEY : BPL -
		RTS

		.SpawnVolley
		LDA #$09+!ExtendedOffset : STA !Ex_Num,y	; spawn flames that target players
		LDA #$26 : STA !Ex_Data2,y
		LDA #$20 : STA !Ex_YSpeed,y
		LDA #$00 : STA !Ex_XSpeed,y
		LDA $1C
		SEC : SBC #$10
		STA !Ex_YLo,y
		LDA $1D
		SBC #$00
		STA !Ex_YHi,y
		LDA $00 : STA !Ex_XLo,y
		LDA $01 : STA !Ex_XHi,y
		RTS

	.Wave	CMP #$40 : BEQ .SpawnWave
	.R	RTS
	+	STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !LavaLordAura
		LDA #$10 : STA.l !3D_Base+$480+$2E4
		RTS

		.SpawnWave
		LDA $3220,x : PHA
		LDA $3250,x : PHA
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA #$14 : STA $3220,x
		LDA !LavaLordScreen : STA $3250,x
		LDA $1C
		SEC : SBC #$10
		STA $3210,x
		LDA $1D
		SBC #$00
		STA $3240,x
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		STZ $04					; no X speed
		LDA #$18 : STA $05			; falling Y speed
		LDA #$86				; type 6, pattern X+16, Y+0 (we'll double Xpos later)
		LDY #$06				; spawn 6 ExSprites
		JSL SpawnExSprite

		LDY #!Ex_Amount-1
	-	LDA !Ex_Num,y
		AND #$7F
		CMP #$09+!ExtendedOffset : BNE +
		LDA !Ex_Data2,y
		CMP #$FF : BNE +
		LDA #$32 : STA !Ex_Data2,y		; set life timer
		LDA !Ex_XLo,y				; double the gap here
		ASL A
		STA !Ex_XLo,y
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
	.Reset	LDA #$04 : STA !LavaLordAttack
		LDA #$01 : STA !PalSpeed			; reset palette rotation speed
		LDA #$10 : STA.l !3D_Base+$480+$2E4		; reset particle spawn rate
		JMP ReturnFromFlameStrike_Hook


	+	CPY $01 : BNE +
		LDA #$02 : STA.l !3D_Base+$480+$2E4		; speed up particle spawn rate
	+	CPY $00 : BNE +
		LDA #$10 : STA !PalSpeed			; speed up palette rotation
	+	CPY #$20
		BNE $03 : JMP .Go
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
		RTS

	.Target	LDY !LavaLordTarget

		LDA !LavaLordScreen				;\
		STA $0B						; |
		STA $0D						; | limits
		LDA #$10 : STA $0A				; |
		LDA #$E0 : STA $0C				;/
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		STA $0E						;\
		LDA !P2XSpeed-$80,y				; |
		AND #$00FF					; |
		LSR A						; | take speed and screen borders into account
		CMP #$0040					; |
		BCC $03 : EOR #$FFFF				; |
		EOR #$FFFF					; |
		CLC : ADC !P2XPosLo-$80,y			; |
		BPL $03 : LDA #$0000				; |
		CMP $0A						; |
		BCS $02 : LDA $0A				; |
		CMP $0C						; |
		BCC $02 : LDA $0C				; |
		CMP $0E						;/

		SEP #$20
		LDA #$00
		BCS $01 : INC A
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
		ROL #2						;\
		AND #$01					; | direction based on speed
		STA $3320,x					;/
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
		JMP .Reset

	+	LDA #$1F : STA !LavaLordAttackTimer
	.Return	RTS

	.Impact	STZ $9E,x
		LDA !ShakeTimer : BNE .Return
		LDA #$1F : STA !ShakeTimer

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

		LDA #$29				;\  > custom sprite number (Flame Pillar)
		TYX					; | > X = new sprite index
		STA !NewSpriteNum,x			; |
		LDA #$36				; | > acts like
		STA $3200,x				; |
		LDA #$08				; | > MAIN routine
		STA $3230,x				; |
		JSL $07F7D2				; | > reset sprite tables
		JSL $0187A7				; | > reset custom sprite tables
		LDA #$08				; |
		STA !ExtraBits,x			;/
		PLA : STA $01				;\ restore coord offsets
		PLA : STA $00				;/
		SEC : SBC #$10
		BPL $03 : EOR #$FF : INC A		;\ initial wait = distance to boss in pixels
		STA $32A0,x				;/
		CLC : ADC #$40				;\ life timer = initial wait + 0x40
		STA $32D0,x				;/
		LDA #$02 : STA $32B0,x			; speed
		LDA #$30 : STA $3290,x			; max height
		LDA #$10 : STA $35D0,x			; delay 1
		STZ $35E0,x				; delay 2


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
		LDA #$33 : STA !AttackMemory	; can't flamestrike twice in a row
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
		LDY #!Ex_Amount-1
	-	LDA !Ex_Num,y
		AND #$7F
		CMP #$09+!ExtendedOffset : BNE +
		LDA !Ex_Data2,y			;\
		CMP #$01 : BNE ++		; |
		CLC : ADC #!ExtendedOffset	; > add offset
		STA !Ex_Num,y			; | transform to smoke puff on last frame
		LDA #$0F : STA !Ex_Data2,y	; |
		BRA +				;/

	++	AND #$04
		ASL A
		CLC : ADC #$27
		ORA #$C0
		STA !Ex_Data1,y
		LDA #$25 : STA !Ex_Data3,y
	+	DEY : BPL -
	;;;;;;;;;;;;;;;;;;;;;;;


		PHX
		LDX #$00
		LDA !PalFrame
		ASL A
		TAY
		REP #$20

	.Loop	LDA $68A7,y : STA $0E		;\
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
		LDA $68A7,y : STA $0E		;\
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
		STA.w !CGRAMtable+4,y
		REP #$20
		LDA #$F000				; address
		STA.w !CGRAMtable+2,y
		LDA #$000C				; size of color data
		STA.w !CGRAMtable+0,y
		SEP #$20
		LDA #$D3 : STA.w !CGRAMtable+$5,y	; dest color
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

	.Draw	LDA !BGFraction : BNE +
		JSL LOAD_TILEMAP_p2

		LDA.b #ANIM_AuraTM : STA $04
		LDA.b #ANIM_AuraTM>>8 : STA $05

	+	JSL LOAD_TILEMAP



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
	db $39,$00,$00,$60

	.RingTM01
	dw $0004
	db $39,$00,$00,$62

	.RingTM02
	dw $0004
	db $39,$00,$00,$64

	.RingTM00V
	dw $0004
	db $B9,$00,$00,$60

	.RingTM01V
	dw $0004
	db $B9,$00,$00,$62

	.RingTM02V
	dw $0004
	db $B9,$00,$00,$64


	.FireballProp
	db $36,$36,$F6,$F6

	.FireballX
	db $10,$10,$F0,$F0

	.FireballTile
	db $E0,$E2,$E0,$E2




	.IdleTM
	dw $0018
	db $3B,$F8,$F0,$00
	db $3B,$08,$F0,$02
	db $3B,$F8,$00,$20
	db $3B,$08,$00,$22
	db $3B,$F8,$10,$40
	db $3B,$08,$10,$42

	.HoverTM
	dw $0024
	db $3B,$F4,$F0,$00
	db $3B,$04,$F0,$02
	db $3B,$0C,$F0,$03
	db $3B,$F4,$00,$20
	db $3B,$04,$00,$22
	db $3B,$0C,$00,$23
	db $3B,$F4,$08,$30
	db $3B,$04,$08,$32
	db $3B,$0C,$08,$33

	.StrikeTM
	dw $0018
	db $3B,$FC,$F0,$00
	db $3B,$04,$F0,$01
	db $3B,$FC,$00,$20
	db $3B,$04,$00,$21
	db $3B,$FC,$10,$40
	db $3B,$04,$10,$41

	.TossTM00
	dw $0020
	db $36,$10,$F0,$E0
	db $3B,$00,$F0,$02
	db $3B,$10,$F0,$04
	db $3B,$F0,$00,$20
	db $3B,$00,$00,$22
	db $3B,$10,$00,$24
	db $3B,$F0,$10,$40
	db $3B,$00,$10,$42
	.TossTM01
	dw $0010
	db $3B,$FC,$F0,$00
	db $3B,$04,$F0,$01
	db $3B,$04,$00,$21
	db $3B,$04,$10,$41

	.ChannelTM
	dw $001C
	db $3B,$F0,$F0,$00
	db $3B,$00,$F0,$02
	db $3B,$10,$F0,$04
	db $3B,$F8,$00,$21
	db $3B,$08,$00,$23
	db $3B,$F8,$10,$41
	db $3B,$08,$10,$43


	.AuraTM
	dw $0058
	db $3F,$D8,$D8,$C0	; left arm
	db $3F,$E8,$D8,$C2
	db $3F,$D8,$E8,$E0
	db $3F,$E8,$E8,$E2
	db $3F,$E8,$F8,$CC	; left armpit
	db $3F,$F8,$D8,$C4	; head
	db $3F,$08,$D8,$C6
	db $3F,$F8,$E8,$E4
	db $3F,$08,$E8,$E6
	db $3F,$18,$D8,$C8	; right arm
	db $3F,$28,$D8,$CA
	db $3F,$18,$E8,$E8
	db $3F,$28,$E8,$EA
	db $3F,$18,$F8,$EC	; right armpit
	db $3F,$F8,$F8,$84	; upper body
	db $3F,$08,$F8,$86
	db $3F,$F8,$08,$A4
	db $3F,$08,$08,$A6
	db $3F,$F8,$18,$88	; lower body
	db $3F,$08,$18,$8A
	db $3F,$F8,$28,$A8
	db $3F,$08,$28,$AA



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
		JSL SUB_HORZ_POS
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

		JSL SUB_HORZ_POS
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


ScaleUp:

	; A = 0 -> left arm + head
	; A = 1 -> right arm
	; A = 2 -> upper body
	; A = 3 -> lower body
	; A = 4 -> left arm pit
	; A = 5 -> right arm pit
	; no ring included

		PHX
		TAX
		LDA .Index,x : TAX
		LDA .Data+0,x : STA $00
		LDA .Data+1,x : STA $01
		LDA .Data+2,x : STA $02
		LDA .Data+3,x : STA $03
		LDA .Data+4,x : STA $04
		PHX
		LDA #$7F
		STA $05
		STA $06
		STZ $07
		STZ $08
		LDA #$00			; 1 stage
		CLC : JSL !TransformGFX
		JSL !GetVRAM
		TXY
		PLX
		PHB : LDA.b #!VRAMbank
		PHA : PLB
		LDA.b #!GFX_buffer>>16
		STA.w !VRAMtable+$04,y
		STA.w !VRAMtable+$0B,y
		STA.w !VRAMtable+$12,y
		STA.w !VRAMtable+$19,y
		REP #$20
		LDA.w #!GFX_buffer : STA.w !VRAMtable+$02,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$09,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$10,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$17,y
		LDA.l .Data+5,x : STA.w !VRAMtable+$05,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$0C,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$13,y
		CLC : ADC #$0100
		STA.w !VRAMtable+$1A,y
		LDA.l .Data+7,x
		STA.w !VRAMtable+$00,y
		STA.w !VRAMtable+$07,y
		CPX #$24 : BCS +
		STA.w !VRAMtable+$0E,y
		STA.w !VRAMtable+$15,y
	+	PLB
		SEP #$20
		PLX
		RTS



	.Index
		db $00,$09,$12,$1B,$24,$2D


	; format:
	; - source address
	; - dimension X, dimension Y
	; - dest VRAM, upload size

	.Data
		dl $369808+$0D20
		db $20,$10
		dw $7C00,$0100
		dl $369808+$0DA0
		db $10,$10
		dw $7C80,$0080
		dl $369808+$1160
		db $10,$10
		dw $7840,$0080
		dl $369808+$1560
		db $10,$10
		dw $7880,$0080
		dl $369808+$1140
		db $08,$08
		dw $7CC0,$0040
		dl $369808+$11A0
		db $08,$08
		dw $7EC0,$0040



	; call this with A set to the fraction (0 = black, 20 = full color)
	; Y is starting color (always affects a full row from there)

	; uses $40F100 as a buffer
	; $00:	16-bit fraction value
	; $02:	16-bit currently loaded color
	; $04:	16-bit color construction
	; $0D:	8-bit target color
	; $0E:	16-bit loop counter


	FadeBG:
		PHB
		PHX
		PHP
		SEP #$20
		STA $00
		STZ $01
		STY $0D
		STZ.w $2250		; set multiplication
		REP #$30
		LDA $0D
		AND #$00FF
		ASL A
		TAX			; X = palette index



		LDA #$000F : STA $0E	; loop counter

	.Loop	LDA.w $6703,x
		STA $02
		AND #$001F
		STA.w $2251
		LDA $00 : STA.w $2253	; I already cleared $01
		BRA $00
		NOP
		LDA.w $2306
		LSR #5
		STA $04

		LDA $02
		LSR #5
		STA $02
		AND #$001F
		STA.w $2251
		LDA $00 : STA $2253
		BRA $00
		NOP
		LDA.w $2306
		AND #$03E0		; just clear the lowest 5 bits, this is already shifted properly
		TSB $04			; ...so we add it here

		LDA $02
		LSR #5
		STA.w $2251
		LDA $00 : STA $2253
		BRA $00
		NOP
		LDA.w $2306
		AND #$03E0
		ASL #5
		ORA $04
		STA.l $40F100,x		; transfer new color to buffer

		INX #2
		DEC $0E : BPL .Loop

		STX $08
		SEP #$30
		JSL !GetCGRAM
		LDA.b #!VRAMbank
		PHA : PLB
		STA.w !CGRAMtable+$04,y
		LDA $0D : STA.w !CGRAMtable+$05,y
		REP #$20
		LDA $08
		SEC : SBC #$0020
		CLC : ADC #$F100
		STA.w !CGRAMtable+$02,y
		LDA #$0020 : STA.w !CGRAMtable+$00,y
		PLP
		PLX
		PLB
		RTS



	namespace off




