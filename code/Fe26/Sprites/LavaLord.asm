LavaLord:

	namespace LavaLord

	!LavaLordPhase		= !BossData+0
	!LavaLordHP		= !BossData+1

	!LavaLordRNG1		= !BossData+2		; make sure boss has access to 4 RNG values every frame
	!LavaLordRNG2		= !BossData+3
	!LavaLordRNG3		= !BossData+4
	!LavaLordRNG4		= !BossData+5

	!LavaLordEnrageTimer	= !BossData+6


	!LavaLordDesiredX	= $BE,x
	!LavaLordAttack		= $3280,x
	!LavaLordAttackTimer	= $3290,x
	!LavaLordExtraIndex	= $32A0,x		; used for safe zone
	!LavaLordTarget		= $32B0,x		; used for Flamestrike

	!LavaLordFloatHeight	= $32C0,x		; boss will attempt to float at this height

	!LavaLordStunTimer	= $32D0,x




	INIT:
		PHB : PHK : PLB
		LDA $3210,x : STA !LavaLordFloatHeight	; remember spawn height
		LDA !MultiPlayer : STA $00
		LDA !Difficulty
		AND #$03
		TAY
		LDA Data_HP,y
		LDY $00
		BEQ $01 : ASL A				; HP is doubled on multiplayer
		STA !LavaLordHP


		PLB
		RTL


	Data:
		.HP
		db $0C,$10,$14,$14




	MAIN:
		PHB : PHK : PLB

		LDA $14
		AND #$3F : BNE .NoIncrement		; enrage timer goes up every 64 frames
		LDA !LavaLordEnrageTimer
		CMP #$B4 : BEQ .NoIncrement		; caps at 180 seconds
		INC !LavaLordEnrageTimer
		.NoIncrement




		LDA !LavaLordAttackTimer : BNE +
		STZ !LavaLordAttack

	LDA !RNG
	AND #$03
	STA !LavaLordAttack
	CMP #$03 : BNE ++
	LDA !RNG
	AND #$80 : STA !LavaLordTarget
	++


	LDA #$80 : STA !LavaLordAttackTimer

		BRA ++
	+	DEC !LavaLordAttackTimer
		++


		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ ATTACK
		JMP GRAPHICS



	PathingTable:
		db $00,$FF
		db $02,$FD
		db $04,$FB
		db $06,$F9
		db $08,$F7
		db $0A,$F5
		db $0C,$F3
		db $0E,$F1



	ATTACK:
		PEA PHYSICS-1
		LDA !LavaLordAttack
		ASL A
		CMP.b #.Nothing-.Ptr : BCS .Safe
		PHX
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Nothing
		dw Fireball
		dw SummonFlame
		dw Flamestrike
		dw ReturnFromFlameStrike
		dw WallOfFlame
		dw FireBarrage
		dw Eruption
		dw Enrage
		dw Desperation
		dw JumpBack

		.Nothing
		PLX

	; calculation for safe zone goes here
	; boss will target the closest safe tile

	.Safe	PHX
		LDX #$0F
	-	STZ $00,x				; mark all 16 tiles as safe
		DEX : BPL -
		LDY #$00

	..check	LDA !P2Status-$80,y : BNE ..ignore
		LDA !P2XPosLo-$80,y
		LSR #3
		INC A
		LSR A
		SEC : SBC #$02
		BPL $02 : LDA #$00			;\
		CMP #$0B				; | value must be between 0x00 and 0x0B
		BCC $02 : LDA #$0B			;/
		TAX
		INC $00,x
		INC $01,x
		INC $02,x
		INC $03,x
		INC $04,x

		..ignore
		CPY #$80 : BEQ ..calc
		LDY #$80 : BRA ..check

	..calc	PLX
		STZ !LavaLordExtraIndex			; get ready for loop
		LDA $3220,x
		LSR #4
		TAY

	-	TYA
		LDY !LavaLordExtraIndex
		CPY #$10 : BNE ..in			; stay here if there somehow is no safe zone
		LDA $3220,x
		BRA +

	..in	INC !LavaLordExtraIndex
		CLC : ADC PathingTable,y
		BPL $02 : LDA #$00			;\
		CMP #$0F				; | value must be 0x00-0x0F range
		BCC $02 : LDA #$0F			;/
		TAY
		LDA $3000,y : BNE -

		TYA
		ASL #4
	+	STA !LavaLordDesiredX

	.End	RTS




	; scatter shot: all projectiles cluster toward the same target

	Fireball:
		PLX
		LDA !LavaLordAttackTimer
		CMP #$10 : BNE ATTACK_Safe		; Attack happens at t = 0x10 to make time for animation backswing

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
		LDA #$07				;\  > Custom sprite number
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
		LDA #$FF				;\ Life timer
		STA $32D0,x				;/
		LDA #$E0				;\ Graphic tile
		STA $33D0,x				;/
		LDA #$01 : STA $35D0,x			; > Spin type
		LDA #$01 : STA $3410,x			; > Hard prop
		LDA #$38 : STA $33C0,x			; > YXPPCCCT

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
		LDY !LavaLordTarget
		LDA !P2XPosLo-$80,y : STA !LavaLordDesiredX	; Lava Lord goes for the target player


		LDA !LavaLordAttackTimer
		CMP #$20 : BEQ .Go
		BCS .Return
		BNE .Fall

	.Go	LDA #$20 : STA $9E,x				; Start falling
		LDA !LavaLordAttack
		ORA #$80
		STA !LavaLordAttack


	.Fall	LDA $3330,x
		AND #$04 : BNE .Impact
		LDA $3240,x : BEQ +
		STZ !LavaLordAttack
		LDA #$FF : STA !LavaLordAttackTimer
		RTS

	+	LDA #$1F : STA !LavaLordAttackTimer
		RTS

	.Impact	STZ $9E,x
		LDA !ShakeTimer : BNE .Return
		LDA #$1F : STA !ShakeTimer

	.Return	RTS


	ReturnFromFlameStrike:
		PLX
		RTS


	WallOfFlame:
		PLX
		RTS


	FireBarrage:
		PLX
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

		LDY #$00
		LDA !LavaLordAttack
		AND #$7F
		CMP #$03
		BNE $01 : INY

	-	LDA $3250,x
		CMP !P2XPosHi : BEQ .SameScreen
		BPL .dec
		BMI .inc

		.SameScreen
		LDA !LavaLordDesiredX
		CMP $3220,x : BEQ .Good
		BMI .dec
	.inc	LDA $AE,x : BMI +
		CMP #$20 : BCS .Write
	+	INC $AE,x
		BRA .Write
	.dec	LDA $AE,x : BPL +
		CMP #$E1 : BCC .Write
	+	DEC $AE,x
		BRA .Write

	.Good	LDA $AE,x : BEQ .Write
		BPL ..dec
	..inc	INC $AE,x : BRA .Write
	..dec	DEC $AE,x


	.Write	BIT !LavaLordAttack : BPL .Float
		STZ $AE,x
		BRA .Fall


	.Float	LDA $3240,x : BNE .Up
		LDA $3210,x
		CMP !LavaLordFloatHeight
		BEQ .Ok
		BCC .Down
	.Up	LDA #$E0 : STA $9E,x
		BRA .Fall
	.Down	LDA #$20 : STA $9E,x
		BRA .Fall
	.Ok	STZ $9E,x


	.Fall	DEY : BPL -
		JSL !SpriteApplySpeed


		.Return




	INTERACTION:

	GRAPHICS:

		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_TILEMAP_Long



		.Return
		LDA $14					;\
		AND #$03				; | store this at the end of each frame
		TAY					; |
		LDA !RNG : STA !LavaLordRNG1,y		;/

		PLB
		RTL



	.Tilemap
	dw $0004
	db $21,$00,$00,$80



	namespace off