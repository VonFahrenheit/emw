;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Mario

; --Build 1.2--
;
<<<<<<< Updated upstream
;	Code:
;	LDY $19
;	LDA $73E0
;	CMP #$3D
;	BCS $03 : ADC $DF16,y
;	TAY
;	LDA $DF1A,y
;	STA $06
;	[...]
;	LDX $06
;	LDA $00DFDA,x			; 0x80-0xFF = skip tile


	pushpc

; -- Mario upgrades --

	; throw fireball
	org $00D081
		JML Mario_Fireball		; org: CMP #$03 : BNE $28 ($00D0AD)

	; code that checks air/ground
	org $00D5F2
		JML Mario_AirHook		; org: LDA !MarioAir : BEQ $03 (otherwise JMPs to $00D682)

	; prevent flight
	org $00D674
		BRA $05				;\
		NOP #2				; | org: BNE $05 : LDA #$50 : STA $749F
		STZ $749F			;/

	; ability to float
	org $00D8E9
		JML Mario_Cape1			; org: CMP #$02 : BNE $3B ($00D928)

	; draw cape
	org $00E3FD
		JML Mario_Cape2			; org: CMP #$02 : BNE $57 (careful with repointing! target gone!)

	org $00EA0D
		JSL Mario_HandyGlove		; org: LDA !MarioBlocked : AND #$03


	; first 2 bytes for big Mario, then 2 for small Mario, last 2 are unused
	org $00FE96
		db $00,$08,$00,$08,$FF,$FF	; X lo
	org $00FE9C
		db $00,$00,$00,$00,$FF,$FF	; X hi
	org $00FEA2
		db $08,$08,$10,$10,$FF,$FF	; Y

	org $00FEC4
		JSL Mario_TacticalFire		; org: LDA #$30 : STA !ExSpriteYSpeed,x
		NOP
	org $00FED1
		LDA !MarioPowerUp
		BNE $02 : INY #2
		BRA 6
		NOP #6
	warnpc $00FEDF

	org $01AA33
		JML Mario_Bounce		; hijack the main mario bounce on enemy code (stomp)

; -- Misc Mario edits --

	org $00FEA8
		JML Mario_FireballCheck		; fusion core fireball check fix
		NOP
=======

	MAINCODE:


	LDA $16
	AND #$20 : BEQ +
	LDA !MarioUpgrades
	EOR #$FF : STA !MarioUpgrades
	+
>>>>>>> Stashed changes

	org $00FEB6
		db $36				; Fireball SFX

<<<<<<< Updated upstream
	org $0086A3
	; OBSOLETE DUE TO VR3
	;	JSL Mario_Controls		; > org: BPL $03 : LDX $6DB3
	;	NOP

	org $00D995
		JML Mario_FastSwim		;\ org: LDA $748F : BEQ $51 ($00D9EB)
		NOP				;/

	org $00DA9F
		JML Mario_FastSwim_2		;\ org $748F : BEQ $01 ($00DAA5)
		NOP				;/

	org $00DC2D
		JML Mario_Stasis		; > org: LDA $7D : STA $8A
=======

		LDA !P2Init : BNE .Main

		.Init
		INC !P2Init
		REP #$30
		LDY.w #!File_PlayerObjects : JSL GetFileAddress
		LDA.w #ANIM_TinyFlameDynamo : JSL CORE_GENERATE_RAMCODE_24bit
>>>>>>> Stashed changes

	org $00E3A6
		JML Mario_ExternalAnim		; > org: LDA $73E0 : CMP #$3D
		NOP

		.Main

<<<<<<< Updated upstream
	org $00A21B
		JSL Mario_Pause1		; > Org: LDA $16 : AND #$10

	org $00A226
		JSL Mario_Pause2		; > Org: LDA $71 : CMP #$09

	org $00A25B
		JSL Mario_Pause3		; > Org: LDA $15 : AND #$20
	org $00A269
		BRA +				; Org: LDA $6DD5 : BEQ $02 : BPL $19
		NOP #3
	org $00A270
		+
	org $00A281
		NOP #3				; Org: INC $7DE9

	org $00A300
		JML Mario_GFX			; > Org: REP #$20 : LDX #$02
	org $00A309
		JML Mario_Palette		;\ Org: LDY #$86 : STY $2121
		NOP				;/
	org $00A333
		JML Mario_GFXextra		;\ Org: LDA [Address of tile 7F] : STA $2116
		NOP #2				;/
	org $00A34D
		LDA !MarioGFX1			; > Org: LDA #$6000
	org $00A368
		NOP : CPX #$06
	org $00A36D
		LDA !MarioGFX2			; > Org: LDA #$6100
	org $00A388
		NOP : CPX #$06

	org $00CDFC				; Disable L/R scroll
		BRA $4B				; Org: BNE $4B

	org $00D093				; Disable automatic spin jump fireball
		RTS				;\ Org: BEQ $18
		NOP				;/


	org $00E31E
		JSL Mario_PaletteData		;\ Org: LDA $E2A2,y : STA $6D82
		NOP #2				;/

	org $00EA45
		JML Mario_ExtraWater		; org: LDA !WaterLevel : BNE $15 ($00EA5E)

	org $00EAA9
		JSL Mario_ExtraCollision	;\ org: STZ $77 : STZ $73E1
		NOP				;/

	org $028752				; Make big Mario break bricks and small Mario do nothing
		JML Mario_Brick			; Org: LDA $04 : CMP #$07

	org $028773				; Don't give Mario Y speed just because a brick is broken
		JSL Mario_Brick_YSpeed		; Org: LDA #$D0 : STA $7D

	org $02A129
		LDA #$02 : STA $3230,x		;\ Sprites get knocked out by fireballs
		BRA $06 : NOP #6		;/

	org $03B69B
		JML MarioHurtbox		; Org: STA $09 : PLX : RTL


; --Remap Mario tiles--

	org $00CF74
		JSL MarioTileRemap_Fire		; org: LDA #$3F : LDY !MarioAir

	org $00E2B2				; Mario's base OAM index
		db $00				; org: $10

	org $00E3D2				; property
		JML MarioTileRemap_Prop
		dl CORE_PlayerClipping		; $00E3D6 is a psuedo-vector!
		NOP #2
		STA !OAM+$113-$18,y
		STA !OAM+$0FB-$18,y
		STA !OAM+$0FF-$18,y
	org $00E3EC
		STA !OAM+$10B-$18,y
	org $00E448
	MarioCapeReturn:
		JSR $F636			;\
		PLB				; | prevent SMW's attempted priority remap
		RTL				; | org: LDX $73F9 : JSR $E45D
		NOP				;/

	MarioCapeY:
	db $00					; standing still
	db $03,$03,$03,$03,$03,$03		; walking/running
	db $08,$08,$08,$08			; falling
	warnpc $00E45D
=======
		.Freeze
		LDA $9D : BEQ ..done
		LDA !P2MarioFinale : BNE +
		DEC !P2AnimTimer
		JMP ANIMATION_CheckPlayer
	+	JMP .FlameStar_spawnparticle
		..done

>>>>>>> Stashed changes

		.AutoAnim
		LDA !P2Anim
		REP #$30
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$00,y
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y : BCC ..sameanim
		..newanim
		LDA ANIM+$03,y : STA !P2Anim
		CMP #!Mar_Walk : BCC ..rate0
		CMP #!Mar_Walk_over : BCS ..rate0
		LDA !IceLevel : BEQ +
	..rate4	LDA #$04 : BRA ..sameanim			; use a special super fast rate on icy ground
	+	LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BPL $03 : EOR #$FF : INC A
		CMP #$13 : BCC ..rate0
		CMP #$15 : BCC ..rate1
		CMP #$20 : BCC ..rate2
	..rate3	LDA #$03 : BRA ..sameanim
	..rate2	LDA #$02 : BRA ..sameanim
	..rate1	LDA #$01 : BRA ..sameanim
	..rate0	LDA #$00
		..sameanim
		STA !P2AnimTimer
		SEP #$30

	org $00E468				; tile number
		JSL MarioTileRemap		;\ org: STA $6302,y : LDX $05
		NOP				;/
	org $00E482
		JSL MarioTileRemap_Coords	; org: STA !OAM+$101,y : REP #$20
		BRA 23				;\ skip this code
		NOP #23				;/
	warnpc $00E49F



	org $00E4AC				; hi table
		dw !OAMhi+$40-$6


	org $00F699
		JSL MarioTileRemap_Expand	;\ org: LDA #$0A : STA $6D84
		NOP				;/
	pullpc


	Mario:
		LDA $19					;\
		BEQ $02 : LDA #$01			; | HP
		STA !P2HP				;/

		JSR MarioAnimations			; $00E2BD, transcribed and modified

		REP #$20				;\
		LDA !MarioXPos : STA $D1		; | copy of $00A2F3
		LDA !MarioYPos : STA $D3		; |
		SEP #$20				;/

		STZ !P2Gravity				; no extra gravity for Mario
		LDA #$46 : STA !P2FallSpeed		; Mario's fall speed is 0x46
		REP #$20
		STZ !P2ExtraInput1
		STZ !P2ExtraInput3
		SEP #$20
<<<<<<< Updated upstream
		STZ !P2Character
		LDA $7497 : STA !P2Invinc		; > Copy Mario's invincibility timer
		LDA !MarioDirection : STA !P2Direction	; > Copy direction flag
		LDA !MarioBlocked : STA !P2Blocked	; > Copy collision flags
		LDA $75					;\
		BEQ $02 : LDA #$40			; | Copy Mario's water flag
		LDY !MarioClimbing			; > Add climb flag
		BEQ $01 : INC A				; |
		STA !P2Water				;/
		STZ !P2XSpeed				;\
		STZ !P2YSpeed				; |
		REP #$20				; |
		LDA !MarioXPosLo : STA !P2XPosLo	; |
		LDA !MarioYPosLo			; |
		CLC : ADC #$0010			; |
		STA !P2YPosLo				; |
		SEP #$20				; |
		LDA !P2VectorBlocked : TSB !P2Blocked	; > extra collision variable for mario vectors
		STZ !P2VectorBlocked			; |
		JSR CORE_UPDATE_SPEED			; | Apply vector speeds (already includes a stasis check)
		REP #$20				; |
		LDA !P2XPosLo : STA !MarioXPosLo	; |
		LDA !P2YPosLo				; |
		SEC : SBC #$0010			; \
		BPL +					;  | Make sure Mario's Y coordinate is accurate
		CMP #$FF00 : BCS +			;  |
		LDA #$FF00				;  > can't go higher than -1 screen
	+	STA !MarioYPosLo			; /
		SEP #$20				;/
		LDA !P2Blocked : STA !P2VectorBlocked	;\
		LSR A : BCC $0B				; |
		BIT !P2VectorX : BMI $06		; |
		STZ !P2VectorX : STZ !P2VectorTimeX	; |
		LSR A : BCC $0B				; |
		BIT !P2VectorX : BPL $06		; |
		STZ !P2VectorX : STZ !P2VectorTimeX	; | Prevent Mario from vectoring into walls
		LSR A : BCC $0B				; |
		BIT !P2VectorY : BMI $06		; |
		STZ !P2VectorY : STZ !P2VectorTimeY	; |
		LSR A : BCC $0B				; |
		BIT !P2VectorY : BPL $06		; |
		STZ !P2VectorY : STZ !P2VectorTimeY	;/
		LDA !MarioXSpeed : STA !P2XSpeed	;\ Copy speeds
		LDA !MarioYSpeed : STA !P2YSpeed	;/

		LDA !P2FireFlash
		BEQ $03 : DEC !P2FireFlash

		LDA !MarioBlocked
		AND #$03 : BEQ +
		STZ !MarioClimb				; clear this if mario touches no walls
		+
=======
		RTL

		.KnockedOut
		JSL CORE_KNOCKED_OUT : BCC .Fall
		LDA #$02 : STA !P2Status
		RTL

		.Fall
		LDA #!Mar_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_CheckPlayer

		.Process
		REP #$20					;\
		LDA !P2Hitbox1IndexMem				; |
		ORA !P2Hitbox2IndexMem				; | merge hitboxes
		STA !P2Hitbox1IndexMem				; |
		STA !P2Hitbox2IndexMem				; |
		SEP #$20					;/

	; timers
		LDA !P2KickTimer
		BEQ $03 : DEC !P2KickTimer
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2PickUp
		BEQ $03 : DEC !P2PickUp
		LDA !P2TurnTimer
		BEQ $03 : DEC !P2TurnTimer
		LDA !P2FireTimer
		BEQ $03 : DEC !P2FireTimer
		LDA !P2RolloutTimer
		BEQ $03 : DEC !P2RolloutTimer
		LDA !P2RolloutStomp
		BEQ $03 : DEC !P2RolloutStomp
		LDA !P2WallKickLockInput
		BEQ $03 : DEC !P2WallKickLockInput


		.MarioFinale
		LDA !P2MarioFinale : BEQ ..done
		STZ $15
		STZ $16
		STZ $17
		STZ $18
		STZ !P2XSpeed
		STZ !P2YSpeed
		DEC !P2MarioFinale : BNE ..done
		STZ !P2FlameStar
		STZ !P2FireCharge
		..done


		.FlameStar
		LDX !P2FlameStar : BNE ..process
	-	JMP ..done

		..process
		LDA $14
		AND #$03 : BNE ..timerdone
		DEC !P2FlameStar
		..timerdone
		LDA !MarioUpgrades
		AND #$01
		INC A : STA !P2FireCharge
		LDA !P2MarioFinale : BNE ..spawnparticle
		CPX #$40 : BCS ..spawnparticle
		LDA $14
		LSR A : BCS -
		CPX #$20 : BCS ..spawnparticle
		LSR A : BCS -

		..spawnparticle
		REP #$20
		LDA !RNG
		AND #$000F
		SBC #$0008
		STA $00
		LDA $14
		AND #$001F
		EOR #$0010
		TAX
		LDA !RNGtable,x
		AND #$001F
		SBC #$0010
		STA $02
		PHB
		JSL GetParticleIndex
		PLB
		LDA !P2X
		ADC $00
		STA !41_Particle_X,x
		LDA !P2Y
		ADC $02
		STA !41_Particle_Y,x
		LDA #$0000
		STA !41_Particle_XSpeed,x
		STA !41_Particle_XAcc,x
		STA !41_Particle_YAcc,x
		LDA #$FE00 : STA !41_Particle_YSpeed,x
		LDA #$F400 : STA !41_Particle_Tile,x
		SEP #$20
		LDA !CurrentPlayer
		BEQ $02 : LDA #$20
		ORA #!P1Tile4
		BIT !RNG
		BPL $02 : ORA #$10
		STA !41_Particle_Tile,x
		LDA.b #!prt_basic : STA !41_Particle_Type,x
		LDA #$10 : STA !41_Particle_Timer,x
		LDA #$00 : STA !41_Particle_Layer,x
		SEP #$30
		..done

		LDA $9D : BEQ +
		DEC !P2AnimTimer
		JMP ANIMATION_CheckPlayer
		+


		LDA !P2HurtTimer : BEQ +
		DEC !P2HurtTimer
		BRA ++
	+	LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2ShrinkTimer
		BEQ $03 : DEC !P2ShrinkTimer
		++
>>>>>>> Stashed changes

		RTS


<<<<<<< Updated upstream
		.HandyGlove
		PHB : PHK : PLB
		PHX
		LDA !MarioUpgrades
		AND #$02 : BEQ +
		LDA !MarioBlocked
		AND #$04 : BEQ ..Check
	+
	-	JMP ..R


		..Check
		LDA !CurrentMario : BEQ -
		LDX #$00
		CMP #$01 : BEQ ..P1
	..P2	LDX #$80
	..P1	LDA !MarioClimb : BEQ ..Init
		JMP ..Main

		..Init
		LDA !MarioYSpeed : BMI -
		LDY !MarioDirection
		LDA !MarioXPosLo
		AND #$0F
		CMP.w ..X,y : BNE -
		LDA !MarioYPosLo
		AND #$0F
		CMP #$08 : BCC -
		CMP #$0C : BCS -
		LDA.w ..Bit,y
		AND $15 : BEQ -

		PHX
		LDA !MarioDirection
		ASL A
		TAY
		REP #$30
		LDA.w ..Offset,y
		CLC : ADC !MarioXPosLo
		AND #$FFF0
		STA $98						; store this
		TAX
		LDA !MarioYPosLo
		SEC : SBC #$0008
		AND #$FFF0
		TAY
		SEP #$20
		JSL !GetMap16
		PLX
		CMP #$0103 : BCC +
		CMP #$016E : BCC -


	+	PHX
		REP #$30
		LDX $98
		LDA !MarioYPosLo
		CLC : ADC #$0008
		AND #$FFF0
		TAY
		SEP #$20
		JSL !GetMap16
		PLX
		CMP #$0103 : BCC ..R
		CMP #$016E : BCS ..R
		LDA !MarioYPosLo
		SEC : SBC #$0008
		AND #$FFF0
		DEC #2
		LDY !MarioPowerUp
		BEQ $02 : DEC #2
		STA !MarioYPosLo
		SEP #$20
		LDA #$30 : STA !MarioClimb			; also used as PP bits for Mario's tiles
		BRA ..Stick

		..Main
		LDY !MarioDirection
		LDA.w ..Bit,y
		AND $15 : BNE ..Stick
		STZ !MarioClimb
	..Stick	LDY !MarioDirection
		STZ !MarioYSpeed
		LDA #$02
		STA !P2Stasis-$80,x
		STA !P2ExternalAnimTimer-$80,x
		STZ !P2ExternalAnim-$80,x
		STZ !MarioSpinJump

		BIT $16 : BPL ..R
		LDA #$C0 : STA !MarioYSpeed
		STZ !P2Stasis-$80,x
		STZ !MarioClimb
		LDA #$2B : STA !SPC1				; jump SFX

	..R	SEP #$20
		PLX
		PLB
		LDA !MarioBlocked				;\ overwritten code
		AND #$03					;/
		RTL						; return
=======
		.FireCharge
		LDA !MarioUpgrades				;\
		AND #$01					; |
		INC A						; | cap mario's fire charges based on upgrade
		CMP !P2FireCharge : BCS ..done			; |
		STA !P2FireCharge				; |
		..done						;/


		.DashBoots
		LDA !MarioUpgrades				;\
		AND #$10					; |
		ASL A						; | dash timer minimum of 32 with dash boots
		CMP !P2Dashing : BCC ..done			; |
		STA !P2Dashing					; |
		..done						;/
>>>>>>> Stashed changes


	..Offset
	dw $FFF8,$0018

	..X
	db $0D,$02

	..Bit
	db $02,$01


		.Bounce
		LDA !MarioClimbing : BNE ..return
		LDA #$D0
		BIT $15
		BPL $02 : LDA #$A8
		STA !MarioYSpeed
		..return
		LDA !MarioFireCharge : BNE +			; check if mario has a fire charge
		LDA #$01 : STA !MarioFireCharge			;\
		LDA !CurrentMario : BEQ +			; |
		PHY						; |
		LDY #$00					; |
		CMP #$01 : BEQ ++				; | if he doesn't, give him one and make him flash white
		LDY #$80					; |
	++	LDA #$14 : STA !P2FireFlash-$80,y		; |
		PLY						; |
		+						;/

<<<<<<< Updated upstream
		RTL


		.Cape1
		LDA !MarioUpgrades
		AND #$04 : BEQ ..Fall
		LDA !CurrentMario : BEQ ..Fall			;\
		LDY #$00					; |
		CMP #$01 : BEQ ..P1				; | can't float during flare drill
	..P2	LDY #$80					; |
	..P1	LDA !P2FlareDrill-$80,y : BNE ..Fall		;/
	..Float	JML $00D8ED
	..Fall	JML $00D928
=======
		.WallKickInput
		LDA !P2WallKickLockInput : BEQ ..done		;\
		LDA !P2WallKickDir : TRB $15			; | force d-pad to press away from wall after wall kick
		EOR #$03 : TSB $15				; |
		..done						;/


	; air/ground split
		LDA !P2InAir : BEQ .Ground

		.Air
		LDA !P2RolloutStomp : BEQ ..nostomproll		;\ allow aerial rollout after stomping an enemy
		BIT $16 : BVS +					;/
		LDA !P2RolloutBuffer				;\
		CMP #$07 : BCS ..nostomproll			; | allow buffered aerial rollout
		CMP #$03 : BCC ..nostomproll			; |
	+	JMP .TriggerRollout				;/
		..nostomproll
		LDA #$03 : STA !P2RolloutTimer
		LDA !P2YSpeed : BPL +
		LDA !P2RolloutStomp : BNE ++
		LDA #$00
	+	CMP #$20
		BCS $02 : LDA #$20
		STA !P2RolloutSpeed
	++	LDA !P2RolloutBuffer
		BMI +
		BEQ ..maybebufferroll
		DEC !P2RolloutBuffer
	+	JMP .SharedMoves
		..maybebufferroll
		BIT $16 : BVC +
		LDA #$06 : STA !P2RolloutBuffer
	+	JMP .SharedMoves


		.Ground
		STZ !P2KillCount
		STZ !P2SpinJump
		STZ !P2Crush
		LDA $15
		AND #$04
		STA !P2Ducking : BEQ ..updateslide
		..startslide
		LDA !P2Anim
		CMP #!Mar_Rollout : BCC +
		CMP #!Mar_Rollout_over : BCC ..setslide
	+	LDA !P2Slope : BNE ..setslide
		LDA !P2FlameDash : BNE ..setslide			; can slide out of flame dash
		..updateslide
		LDA !P2Sliding : BEQ .Rollout
		LDA $15
		AND #$07
		CMP #$04 : BCS ..checkspeed
		AND #$03 : BEQ ..checkspeed
		LDA #$00 : BRA ..setslide
		..checkspeed
		LDA !P2XSpeed : BNE ..setslide
		LDA !P2Slope
		..setslide
		STA !P2Sliding

		.Rollout
		LDA !MarioUpgrades : BPL .NoRollout			; check upgrade
		LDA !P2RolloutBuffer
		BEQ ..inputroll
		BMI .NoRollout						; can't roll -> roll
		CMP #$03 : BCC .NoRollout				; can't roll if mistimed by more than 3 frames
		LDA #$40 : TSB $16					; force roll if buffered
		..inputroll
		LDA !P2RolloutTimer : BEQ .NoRollout
		BIT $16 : BVC .NoRollout

		.TriggerRollout
		LDA $15
		AND #$03
		DEC A
		EOR #$01
		CMP !P2Dir : BNE .NoRollout
		TAY
		LDA !P2RolloutSpeed
		CPY #$01
		BEQ $03 : EOR #$FF : INC A
		CMP #$00 : BPL ..right
		..left
		BIT !P2XSpeed : BPL ..go
		CMP !P2XSpeed : BCS ..speeddone
		BRA ..go
		..right
		BIT !P2XSpeed : BMI ..go
		CMP !P2XSpeed : BCC ..speeddone
		..go
		LDY #$1F
		..speeddone
		JSL CORE_ACCEL_X_8Bit
		LDA !P2WallKickLockInput : BNE ..nobounce
		LDA !P2RolloutSpeed
		LSR A
		ADC #$18
		EOR #$FF : INC A
		STA !P2YSpeed
		..nobounce
		LDA #$FF : STA !P2RolloutBuffer
		BRA .SharedMoves
		.NoRollout
		STZ !P2RolloutBuffer



	.SharedMoves
		LDA !P2Sliding					;\ enforce crouch when sliding
		BEQ $03 : STA !P2Ducking			;/


	; fireball
		.Fire
		LDA !P2YSpeed : BMI ..canthrow			;\
		BIT !P2RolloutBuffer : BMI ..done		; | can cancel dive into fireball, but NOT rollout
		..canthrow					;/
		LDA $18						;\ input with R
		AND #$10 : BEQ ..done				;/
		LDA !P2FlameStar : BNE ..process		;\
		LDA !P2FireCharge : BEQ ..done			; | must have a fire charge or be in flame star
		DEC !P2FireCharge				;/
		..process
		LDA #$0A : STA !P2FireTimer
		LDA #$80 : TRB !P2RolloutBuffer			; end rollout animation
		JSR ThrowFireball
		..done

>>>>>>> Stashed changes

		.Water
		BIT !P2Water : BVC ..done			;\
		..main						; |
		STZ !P2FlameDash				; |
		STZ !P2RolloutBuffer				; |
		STZ !P2Gravity					; | while in water, replace the rest of CONTROLS and all of PHYSICS with PLUMBER_SWIM
		STZ !P2Dashing					; |
		STZ !P2SpinUsed					; |
		JSL CORE_PLUMBER_SWIM				; |
		JMP SPRITE_INTERACTION				; |
		..done						;/

<<<<<<< Updated upstream
		.Cape2
		LDA !MarioUpgrades
		AND #$04 : BEQ ..No
	..Yes	JML $00E401
	..No	JML MarioCapeReturn


		.Fireball
	BRA ..Fire
;		CMP #$03 : BEQ ..Fire
;		LDA !MarioUpgrades
;		AND #$40 : BNE ..Fire
	..No	JML $00D0AD
	..Fire	LDA !MarioFireCharge : BEQ ..No			; only allow if mario has a fire charge
		JML $00D085


		.TacticalFire
		STZ !MarioFireCharge				; consume mario's fire charge
		LDA !MarioUpgrades
		AND #$08 : BEQ ..30
		LDA $15
		AND #$08 : BEQ ..30
	..C0	LDA #$C0 : STA !Ex_YSpeed,x
		RTL
	..30	LDA #$30 : STA !Ex_YSpeed,x
		RTL

=======
		LDA #$0A : STA !P2FastSwim			;


	; wall kick
		.WallKick
		LDA !MarioUpgrades				;\ upgrade check
		AND #$02 : BEQ ..done				;/
		LDA !P2Blocked					;\
		BIT #$04 : BEQ ..checkbounce			; | if on ground, free inputs and end
		STZ !P2WallKickLockInput			; |
		BRA ..done					;/
		..checkbounce					;\ must touch a wall
		AND #$03 : BEQ ..done				;/
		STA !P2WallKickDir				; set dir (will be used for joypad lock)
		LDA $15						;\
		AND #$03					; |
		CMP !P2WallKickDir : BNE ..done			; | trigger wall kick by holding towards wall and pressing B
		BIT !P2CoyoteTime : BMI +			; |
		BIT $16 : BPL ..done				;/
	+	TRB $15						;\
		EOR #$03 : TAY					; | lock joypad away from wall
		TSB $15						;/
		LDA DATA_WallKickSpeed,y : STA !P2XSpeed	; set X speed
		LDA #$B3 : STA !P2YSpeed			; set Y speed
		LDA #$10 : STA !P2WallKickLockInput		; lock joypad for 16 frames
		LDA #$03 : STA !P2RolloutStomp			; allow rollout for 3 frames
		LDA #$30 : STA !P2RolloutSpeed			; rollout speed if used
		..done


	; flame dash
		.FlameDashStart
		LDA !P2FlameDash : BNE ..done			; can't cancel flame dash into flame dash
		LDA !P2YSpeed : BMI ..candash			;\
		LDA !P2RolloutBuffer : BMI ..done		; | can cancel dive into flame dash, but NOT rollout
		..candash					;/
		LDA !MarioUpgrades				; requires upgrade
		AND $18						;\ activated with L
		AND #$20 : BEQ ..done				;/
		STZ !P2FlameDashDown				; reset down flag
		STZ !P2FlameDashPlus				; reset bonus speed flag
		LDA !P2FlameStar : BNE ..trigger		;\
		LDA !P2FireCharge : BEQ ..done			; | costs a fire charge, unless in flame star
		DEC !P2FireCharge				;/
		..trigger
		LDA #$20 : STA !P2FlameDash			; flame dash timer
		LDA !MarioUpgrades				;\
		AND $15						; |
		AND #$04 : BEQ ..forward			; |
		LDA !P2InAir : BEQ ..forward			; |
		..down						; | downwards flame dash
		STA !P2FlameDashDown				; |
		STZ !P2XSpeed					; |
		LDA !P2FallSpeed				; |
		BRA ..set					;/
		..forward					;\ forwards flame dash
		BIT !P2YSpeed : BMI ..done			;/
		..set						;\
		STA !P2YSpeed					; | set y speed
		..done						;/

		.FlameDashRun
		LDA !P2FlameDash : BEQ ..done
		DEC !P2FlameDash
		LDA #$80 : TRB !P2RolloutBuffer			; end rollout
		LDA #$70 : STA !P2Dashing
		LDA #$50 : STA !P2FlashPal
		LDA #$01 : STA !P2Invinc
		LDA !P2FlameDashDown : BEQ ..forward		;\
		..down						; |
		LDA !P2InAir : BNE ..drop			; | flame dash down into ground -> end
		LDA !P2Slope : BNE ..transition			; |
		..end						; |
		STZ !P2FlameDash : BRA ..done			;/
		..transition					;\
		ROL #2						; |
		AND #$01 : TAX					; |
		INX						; | flame dash down into slope -> forward
		EOR #$01 : STA !P2Dir				; | (go down slope)
		STZ !P2FlameDashDown				; |
		LDA DATA_FlameDashSpeed,x : STA !P2XSpeed	; |
		LDA #$04 : STA !P2FlameDashPlus			; > bonus speed
		BRA ..done					;/
		..drop						;\
		LDA !P2FallSpeed : STA !P2YSpeed		; | dash down in midair
		LDA #$00 : BRA ..accel				;/
		..forward					;\
		LDA !P2Slope : BEQ ..keepspeed			; |
		EOR !P2XSpeed					; | lose bonus speed if running up a slope
		BPL ..keepspeed					; |
		STZ !P2FlameDashPlus				; |
		..keepspeed					;/
		LDA $15
		AND #$03 : BNE ..index
		..usedir
		LDA !P2Dir
		EOR #$01
		INC A
		..index
		ORA !P2FlameDashPlus : TAX
		LDA DATA_FlameDashSpeed,x
		..accel
		LDY #$10
		JSL CORE_ACCEL_X_8Bit
		..done


	; mario finale
		.MarioFinale
		LDA !P2MarioFinale : BNE ..main
		..init
		LDA !P2FlameStar : BEQ ..done
		BIT $18 : BVC ..done
		LDA #$20
		STA !P2MarioFinale
		STA $9D
		BRA ..done
		..main
		JSR ThrowFireball
		LDA #!MarFinale_Num : STA !Ex_Num,x
		LDA !RNG : STA !Ex_Data1,x
		STZ !Ex_Data2,x
		STZ !Ex_Data3,x
		..done



	; flame star charge
		.FlameStarCharge
		LDA $15						;\
		AND #$0F					; | must stand still
		ORA !P2FlameStarUsed : BEQ ..checkupgrade	; | can only use once
		JMP ..clearcharge				;/
		..checkupgrade					;\
		LDA !MarioUpgrades				; | must hold upgrade and hold X
		AND #$40 : BEQ ..clearcharge			; |
		CMP $17 : BNE ..clearcharge			;/
		LDA !P2FlameStarCharge : BNE +			;\ check for X press (not hold) when starting
		BIT $18 : BVC ..done				;/
	+	CMP #$3C : BCS ..trigger			; end after charging for 1 full second
		INC !P2FlameStarCharge				; increment timer
		PHB						;\
		JSL GetParticleIndex				; |
		PLB						; |
		LDA !P2X : STA !41_Particle_X,x			; |
		LDA !P2FlameStarCharge				; |
		AND #$00FF					; |
		LSR #2						; |
		SEC : SBC #$0020				; |
		CLC : ADC !P2Y					; |
		STA !41_Particle_Y,x				; |
		LDA #$0000					; |
		STA !41_Particle_XSpeed,x			; |
		STA !41_Particle_YSpeed,x			; |
		STA !41_Particle_XAcc,x				; | display star item
		STA !41_Particle_YAcc,x				; |
		SEP #$20					; |
		LDA !CurrentPlayer				; |
		BEQ $02 : LDA #!P2TileOffset			; |
		CLC : ADC #!P1Tile3				; |
		STA !41_Particle_Tile,x				; |
		LDA #$F4 : STA !41_Particle_Prop,x		; |
		LDA #$02 : STA !41_Particle_Layer,x		; |
		LDA.b #!prt_basic : STA !41_Particle_Type,x	; |
		LDA #$02 : STA !41_Particle_Timer,x		; |
		SEP #$30					; |
		BRA ..done					;/
		..trigger					;
		LDA #$96 : STA !P2FlameStar			; timer = 2.5 * 4 seconds (10 seconds)
		INC !P2FlameStarUsed				; can't use ultimate again
		..clearcharge
		STZ !P2FlameStarCharge
		..done




	; main jump code
		.Jump
		LDA $15						;\
		AND #$80					; | clear jump buffer unless jump is held
		EOR #$80 : TRB !P2Buffer			;/
		LDA !P2Buffer					;\ apply jump buffer
		AND #$80 : TSB $16				;/
		LDA $16						;\ check B + A
		ORA $18 : BPL .JumpDone				;/
		LDA !P2Climbing : BNE .TriggerJump		;\
		LDA !P2CoyoteTime				; |
		BMI +						; | must be on ground or have coyote time
		BNE .TriggerJump				; | or be climbing
	+	LDA !P2InAir : BNE .JumpDone			;/

		.TriggerJump
		STZ !P2Buffer					; clear input buffer on jumping
		STZ !P2FlameStarCharge				; interrupt flame star charge
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		LSR #3
		CMP #$07
		BCC $02 : LDA #$07
		BIT $18 : BMI ..spinjump
		..normaljump
		LDX #$2B : STX !SPC1				; jump SFX
		BRA ..finishjump
		..spinjump
		ORA #$08
		INC !P2SpinJump
		INC !P2Crush
		STZ !P2Ducking
		LDX #$04 : STX !SPC4				; spin jump sfx
		..finishjump
		TAX
		LDA DATA_JumpHeight,x : STA !P2YSpeed		; update y speed
		LDA !P2Sliding					;\
		STZ !P2Sliding					; | clear slide, and also clear duck if jumping out of a slide
		BEQ $03 : STZ !P2Ducking			;/
		LDA !P2Dashing
		CMP #$70 : BCC .JumpDone
		LDA.b #!Mar_LongJump : STA !P2Anim		;\ long jump anim
		STZ !P2AnimTimer				;/
		.JumpDone




	; horizontal movement
	.HorizontalMovement
		LDA #$FF : STA $04				; default: dash timer -1

; $00 = 16-bit resting speed (during .Friction), 16-bit max speed index (during .Move)
; $02 = 8-bit accel index
; $03 = scrach
; $04 = added to dash timer

		LDA !P2InAir : BEQ ..ground			; check air/ground
		LDA !P2Dashing					;\
		CMP #$70 : BNE ..handleinput			; |
		LDA !P2XSpeed					; |
		ROL #2						; |
		AND #$01					; | keep p speed in midair if holding forward
		INC A						; | (only if p speed is full)
		AND $15 : BEQ ..handleinput			; |
		STZ $04						; |
		BRA ..handleinput				;/
		..ground
		LDA !P2Ducking					;\
		ORA !P2Sliding					; | can't walk/run on ground while crouching or sliding
		BNE .Friction					;/
		..handleinput
		LDA $15
		AND #$03 : BNE .Move


		.Friction
		LDA !P2InAir : BEQ $03 : JMP .DashTimer		; no friction in midair
		LDA !P2Slope
		CLC : ADC #$04
		ASL A : TAX
		LDA !P2Sliding
		REP #$30
		BEQ ..stand
		..slide
		LDA DATA_SlidingSpeed,x : BRA +
		..stand
		LDA DATA_RestingSpeed,x
	+	STA $00
		BNE ..special
		BIT !P2XSpeedFraction : BPL ..accleft		;\ if resting speed is 0, just read current speed dir
		BRA ..accright					;/
		..special					;\
		BPL ..right					; |
		..left						; |
		BIT !P2XSpeedFraction : BPL ..accleft		; |
		CMP !P2XSpeedFraction : BCS ..accright		; |
		..accleft					; |
		TXA : ASL A					; |
		BRA ..acc					; | more complicated calculation if resting speed != 0
		..right						; |
		BIT !P2XSpeedFraction : BMI ..accright		; |
		CMP !P2XSpeedFraction : BCC ..accleft		; |
		..accright					; |
		TXA						; |
		INC A						; |
		ASL A						; |
		..acc						;/
		TAY
		LDA !IceLevel
		AND #$00FF : BEQ +
		LDA DATA_Friction_ice,y : BRA ++
	+	LDA DATA_Friction,y
	++	TAY
		LDA $00 : BRA .UpdateSpeed

		.Move
		AND #$01 : STA $00				;\ $00 = dir index (*1), 16-bit
		STZ $01						;/
		ASL A : STA $02					; $02 = dir index (*2)
		LDA #$00					; base index = 0x00
		LDX !P2Dashing					;\
		CPX #$70 : BCC +				; | p-speed index = 0x04
		LDA #$04					; |
		BRA ++						;/
	+	BIT $15 : BVC ++				;\ running (but not p-speed) index = 0x02
		LDA #$02					;/
	++	TSB $00						; $00 = speed + dir index
		LDA !P2Slope					;\
		CLC : ADC #$04					; |
		STA $03						; | add slope * 6
		ASL A : ADC $03					; | $00 = full speed index
		ASL A : ADC $00					; |
		STA $00						;/
		LDA $15						;\
		AND #$03 : BEQ ..notturning			; |
		DEC A						; |
		EOR #$01 : STA !P2Direction			; > update mario direction
		EOR #$01					; |
		ROR #2						; | get turn offset
		EOR !P2XSpeed : BPL ..notturning		; |
		..turning					; |
		LDA #$24					; |
		CLC : ADC $02					; |
		STA $02						; |
		..notturning					;/
		LDA !P2Slope					;\
		CLC : ADC #$04					; |
		ASL #2						; |
		ADC $02						; | A = slope*8 + dir*4 + run button*2
		BIT $15						; |
		BVC $01 : INC A					; |
		ASL A						;/
		LDX !P2InAir : BNE ..noice			;\ check if on icy surface
		LDX !IceLevel : BEQ ..noice			;/
		..ice						;\
		TAX						; | ice accel value
		REP #$30					; |
		LDY DATA_XAccel_ice,x : BRA ..acc		;/
		..noice						;\ on normal ground or in midair, index = slope*4 + dir*2
		TAX						;/
		REP #$30					;\ get normal accel value
		LDY DATA_XAccel,x				;/
		..acc
		LDX $00
		LDA DATA_MaxXSpeed-1,x
		AND #$FF00

		.UpdateSpeed
		JSL CORE_ACCEL_X_16Bit
		SEP #$30


		.DashTimer
		BIT $15 : BVC ..apply
		LDA !P2XSpeed
		CMP #$23 : BCC ..apply
		CMP #$DD+1 : BCS ..apply
		..inctimer
		LDA !P2Dashing
		LDX !P2Anim					;\ keep p speed in long jump pose so mario can do a turning p jump
		CPX.b #!Mar_LongJump : BEQ +			;/
		LDX !P2InAir : BNE ..apply			; dash timer can't increment in midair
	+	LDX #$02 : STX $04				; dash timer +2
		..apply
		LDA !P2InAir : BEQ ..timer
		LDA !P2CoyoteTime
		BMI ..timer
		BNE ..notimer
		..timer
		LDA $04						;\
		CLC : ADC !P2Dashing				; |
		BPL $02 : LDA #$00				; | update dash timer (-1 or +2)
		CMP #$70					; |
		BCC $02 : LDA #$70				; |
		STA !P2Dashing					;/
		..notimer




	PHYSICS:
		.Gravity
		BIT !P2Water : BVS ..done			; don't update gravity in water
		LDA #$46 : STA !P2FallSpeed
		LDA #$06 : STA !P2Gravity
		LDA $15
		ORA $17
		BPL ..done
		LSR !P2Gravity
		..done
>>>>>>> Stashed changes

		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		..done

<<<<<<< Updated upstream
		.AirHook
		JSR .Coyote
		LDA !P2CoyoteTime-$80,x
		BEQ ..Normal
		BPL ..Ground

		..Normal
		LDA !MarioAir : BEQ ..Ground

		LDA !MarioUpgrades				;\ upgrade check
		AND #$10 : BEQ ..NoFlareSpin			;/
		LDA !MarioSpinJump : BNE ..NoFlareSpin		;\
		BIT $18 : BPL ..NoFlareSpin			; |
		LDA #$E0 : STA !MarioYSpeed			; | flare spin
		LDA #$01 : STA !MarioSpinJump			; |
		LDA #$04 : STA !SPC4				;/
		..NoFlareSpin

		LDA !MarioUpgrades				;\ upgrade check
		AND #$20 : BEQ ..NoFlareDrill			;/
		LDA !P2FlareDrill-$80,x : BNE ..NoFlareDrill
		LDA !MarioSpinJump : BEQ ..NoFlareDrill		;\
		LDA !MarioYSpeed : BPL ..NoFlareDrill		; |
		LDA $16						; | flare drill
		AND #$04 : BEQ ..NoFlareDrill			; |
		LDA #$01 : STA !P2FlareDrill-$80,x		; |
		..NoFlareDrill					;/
		LDA !MarioSpinJump				;\ clear flare drill when spin jump ends
		BNE $03 : STZ !P2FlareDrill-$80,x		;/
		LDA !P2FlareDrill-$80,x				;\ flare drill descent
		BEQ $04 : LDA #$60 : STA !MarioYSpeed		;/


		JML $00D682					; air

		..Ground
		STZ !P2FlareDrill-$80,x
		JML $00D5F9					; ground




		.Coyote
		LDA !CurrentMario
		LDX #$00
		CMP #$02
		BNE $02 : LDX #$80
		LDA !MarioAir : BEQ ..Ground

		..Air
		LDA !P2CoyoteTime-$80,x
		BEQ ..Jump
		BPL ..Timer
	..Jump	LDA $16
		AND #$80 : BEQ ..Timer
		ORA #$03 : STA !P2CoyoteTime-$80,x
		RTS

		..Ground
		LDA !P2CoyoteTime-$80,x : BMI ..Buffer
		LDA #$03 : STA !P2CoyoteTime-$80,x
		RTS

		..Buffer
		AND #$80 : TSB $16
	..Clear	STZ !P2CoyoteTime-$80,x
		RTS

		..Timer
		LDA !P2CoyoteTime-$80,x
		DEC A
		CMP #$7F : BEQ ..Clear
		CMP #$FF : BEQ ..Clear
		STA !P2CoyoteTime-$80,x
		RTS




		.FastSwim
		PHA					;\
		PHX					; |
		LDX #$00				; |
		LDA !CurrentMario : BEQ ..R		; |
		CMP #$01 : BEQ ..P1			; |
	..P2	LDX #$80				; | if Mario holds B for 10 frames or more he can
	..P1	BIT $15 : BMI ..B			; | swim fast even without an item
		LDA #$0A : STA !P2DashTimerR1-$80,x	; |
	..B	LDA !P2DashTimerR1-$80,x : BNE ..Slow	; |
		INC !P2DashTimerR2-$80,x		; > extra animation timer
		LDA !P2DashTimerR2-$80,x		; |
		AND #$0F				; |
		STA $7496				; > Mario animation timer
		PLX					; |
		PLA					; |
		BRA .00D99A				;/

	..Slow	DEC !P2DashTimerR1-$80,x
	..R	PLX
		PLA
		LDA $748F : BEQ .00D9EB

	.00D99A	JML $00D99A
	.00D9EB	JML $00D9EB

=======
		.Collision
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BEQ ..done
		ROL #2
		AND #$01
		INC A
		AND !P2Blocked : BEQ ..done
		STZ !P2XSpeed
		..done
>>>>>>> Stashed changes

		.FastSwim_2
		LDY $748F : BNE .00DAA4			;\
		PHA					; |
		LDA !CurrentMario : BEQ +		; |
		LDX #$00				; |
		CMP #$01 : BEQ ..P1			; | don't flail arms during fast swim
	..P2	LDX #$80				; |
	..P1	LDA !P2DashTimerR1-$80,x : BNE +	; |
		PLA					; |
	.00DAA4	JML $00DAA4				;/

	+	PLA					;\ animate arms as usual if there's no object or fast swim
	.00DAA5	JML $00DAA5				;/



		.Stasis
		LDA !CurrentMario : BEQ +		; > If there's no Mario, just go on as usual
		CMP #$02 : BEQ ++			; > Branch if P2 is controlling Mario
		LDA !P2Stasis-$80 : BEQ +		; > Check for P1 stasis
	-	JML $00DC77				; > Don't apply Mario speed
	++	LDA !P2Stasis : BNE -			; > Check for P2 stasis
	+	LDA $7D : STA $8A			;\ Return as normal
		JML $00DC31				;/

<<<<<<< Updated upstream

		.ExternalAnim
		LDA !CurrentMario : BEQ ..NoExternal
		DEC A
		CLC : ROL #2
		TAX
		LDA !P2ExternalAnimTimer-$80,x		;\
		BEQ ..ClearExternal			; |
		DEC A					; |
		STA !P2ExternalAnimTimer-$80,x		; | Enforce external animations for Mario
		LDA !P2ExternalAnim-$80,x		; |
		STA !MarioImg				; |
		LDA !P2Anim-$80,x : STA $73DF		; > enforce cape too
		BRA ..NoExternal			;/

		..ClearExternal
		STZ !P2ExternalAnim-$80,x		; Clear once timer runs out
		STZ !P2Anim-$80,x

		..NoExternal
		LDA !MarioImg				;\
		CMP #$3D				; | Overwritten code + return
		JML $00E3AB				;/



		.GFX
		LDA !GameMode				;\ Not on the realm select menu
		CMP #$0F : BCC ..NoMario		;/
		LDA !Characters				;\
		AND #$F0 : BEQ ..Mario1			; |
		LDA !MultiPlayer			; | See if anyone is playing Mario
		BEQ ..NoMario				; |
		LDA !Characters				; |
		AND #$0F : BNE ..NoMario		;/

		..Mario2
		LDA #$20 : STA !MarioTileOffset		; > Tile offset for P2 Mario
		LDA #$02 : STA !MarioPropOffset		; > Prop offset for P2 Mario
		REP #$20				;\
		LDX #$02				; |
		LDA #$6200 : STA !MarioGFX1		; | Set Mario's VRAM address to P2
		LDA #$6300 : STA !MarioGFX2		; |
		JML $00A304				;/

		..Mario1
		STZ !MarioTileOffset			; > Tile offset for P1 Mario
		STZ !MarioPropOffset			; > Prop offset for P1 Mario
		REP #$20				;\
		LDX #$02				; |
		LDA #$6000 : STA !MarioGFX1		; | Execute Mario DMA as normal
		LDA #$6100 : STA !MarioGFX2		; |
		JML $00A304				;/

		..NoMario
		JML $00A38F				; > Ignore the whole Mario DMA routine


		.GFXextra
		LDA #$6070
		CLC : ADC !MarioGFX1			;\ Recalculate position
		SEC : SBC #$6000			;/
		STA $2116				; > Store VRAM address
		JML $00A33C


		.FireballCheck
		STZ $00					; number of fireballs currently in play
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x
		CMP.b #$05+!ExtendedOffset
		BNE $02 : INC $00
		DEX : BPL -
		LDA $00
		CMP #$02 : BCS ..nope			; only allow 2 fireballs at once
	..spawn	LDX.b #!Ex_Amount-1			;\
	-	LDA !Ex_Num,x : BEQ ..go		; | look for a free slot
		DEX : BPL -				;/
	..nope	JML $00FEB4				; return without spawning a fireball
	..go	JML $00FEB5				; spawn a fireball


=======
		.Carry
		LDX !P2Carry : BEQ ..done
		JSL CORE_CARRY		
		..done


	OBJECTS:
		REP #$30
		LDA !P2HP					;\
		AND #$00FF					; | always use crouch clipping for small mario
		CMP #$0005 : BCS +				; |
		LDA.w #ANIM_ClippingCrouch : BRA ++		;/
	+	LDA !P2Anim					;\
		AND #$00FF					; | get index to anim table
		ASL #3						; |
		TAY						;/
		LDA ANIM+$06,y					;
	++	JSL CORE_COLLISION				; pointer to clipping
>>>>>>> Stashed changes

		.Controls
		PHP
		LDA !CurrentMario : BEQ +
		DEC A
		CLC : ROR #2
		TAY
		REP #$20
		LDA !P2ExtraInput1-$80,y
		ORA !P2ExtraInput3-$80,y
		SEP #$20
		BEQ +
		LDA !P2ExtraInput1-$80,y			;\
		BEQ $02 : STA $15				; |
		LDA !P2ExtraInput2-$80,y			; |
		BEQ $02 : STA $16				; | Input overwrite
		LDA !P2ExtraInput3-$80,y			; |
		BEQ $02 : STA $17				; |
		LDA !P2ExtraInput4-$80,y			; |
		BEQ $02 : STA $18				;/
		PLP
		PLA : PLA : PLA
		JML $0086C6

	+	PLP
		BPL ..Return					; > Not sure what this actually does but it's in the source code
		LDX #$00					;\
		LDA !MultiPlayer				; |
		BEQ ..Return					; | Allow P2 to control Mario
		LDA !Characters					; |
		AND #$0F : BNE ..Return				; |
		INX						;/

		..Return
		RTL


		.Palette
		LDA !MarioPropOffset				;\
		AND #$00FF					; |
		ASL #3						; | Make sure Mario palette is uploaded to the right place
		CLC : ADC #$0086				; |
		TAY : STY $2121					; |
		JML $00A30E					;/

<<<<<<< Updated upstream

		.PaletteData
	;	LDA.w #!MarioPalData : STA $6D82		; Mario's palette is in I-RAM
	;	LDA !MarioPalOverride
	;	AND #$00FF : BNE ..override

	;	PEI ($00)
	;	PHY

		SEP #$20
		LDY #$00
	;	LDA !MarioUpgrades				;\
	;	AND #$40					; | always use fire palette with flower DNA
	;	BEQ $02 : LDY.b #!palset_mario_fire		;/
		LDA !MarioFireCharge				;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire		;/
	;	LDA $19						;\
	;	CMP #$03					; | fire palette if mario has fire flower
	;	BNE $02 : LDY.b #!palset_mario_fire		;/


		LDA !MarioFireCharge				;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire		;/
		LDA !CurrentMario : BNE $03 : JMP ..NoUpdate
		DEC A
		TAX
		PHX
	;	TYA : STA !Palset8,x

		LDA !P2FireFlash-$80,x : BNE +
		CPY.b #!palset_mario_fire : BEQ $03 : JMP ..NoGlow
		+

		PHY
		TXY
		BEQ $02 : LDY #$80
		LDA !P2FireFlash-$80,y : BEQ +
		PHX
		PHA
		LDA #$01 : STA !P2LockPalset-$80,y
		CPX #$00
		BEQ $02 : LDX #$20
		REP #$20
		LDA #$7FFF
		STA.l !PaletteHSL+$904+$100,x
		STA.l !PaletteHSL+$906+$100,x
		STA.l !PaletteHSL+$908+$100,x
		STA.l !PaletteHSL+$90A+$100,x
		STA.l !PaletteHSL+$90C+$100,x
		STA.l !PaletteHSL+$90E+$100,x
		STA.l !PaletteHSL+$910+$100,x
		STA.l !PaletteHSL+$912+$100,x
		STA.l !PaletteHSL+$914+$100,x
		STA.l !PaletteHSL+$916+$100,x
		STA.l !PaletteHSL+$918+$100,x
		STA.l !PaletteHSL+$91A+$100,x
		STA.l !PaletteHSL+$91C+$100,x
		STA.l !PaletteHSL+$91E+$100,x
		SEP #$20
		LDA $02,s
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$0E
		PLA
		CMP #$10 : BCC ++
		SBC #$10
		ASL #3
		BRA +++
	++	ASL A
		EOR #$1F
	+++	JSL !MixRGB_Upload
		PLX
		PLY
		JMP ..NoGlow

		+
		LDA #$00 : STA !P2LockPalset-$80,y
		PLY
		LDA !Palset8,x
		AND #$7F : BEQ +
		STZ !Palset8,x
		+
		CPY #$09 : BNE ..NoGlow

	; write to colors 2, 3, 8 and A
		..Glow
		CPX #$00
		BEQ $02 : LDX #$20
		LDA #$1F
		STA !PaletteHSL+$904+$100,x
		STA !PaletteHSL+$906+$100,x
		STA !PaletteHSL+$910+$100,x
		STA !PaletteHSL+$914+$100,x
		TXA
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$02
		LDA $14
		AND #$3F
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		PHA
		PHX
		JSL !MixRGB_Upload
		PLX
		LDA $01,s
		INX #6
		LDY #$01
		PHX
		JSL !MixRGB_Upload
		PLX
		PLA
		INX #2
		LDY #$01
		JSL !MixRGB_Upload

		..NoGlow
		PLX
		..NoUpdate
=======
	ATTACK:
		LDA !P2FlameDash : BNE .FlameDash
		LDA !P2Sliding : BNE .Slide

		.NoHitbox
		STZ !P2Hitbox1IndexMem1
		STZ !P2Hitbox1IndexMem2
		STZ !P2Hitbox2IndexMem1
		STZ !P2Hitbox2IndexMem2
		BRA .AttacksDone

		.FlameDash
		REP #$20
		LDA.w #DATA_FlameDashHitbox : JSL CORE_ATTACK_LoadHitbox
		LDA !P2FlameDashDown : BEQ .AttacksDone
		LDA #$10 : STA !P2Hitbox1XSpeed
		LDA !P2FallSpeed : STA !P2Hitbox1YSpeed
		BRA .AttacksDone

		.Slide
		REP #$20
		LDA.w #DATA_SlideHitbox : JSL CORE_ATTACK_LoadHitbox

		.AttacksDone
		REP #$20					;\
		LDA !P2Hitbox1IndexMem				; |
		ORA !P2Hitbox2IndexMem				; | merge hitboxes
		STA !P2Hitbox1IndexMem				; |
		STA !P2Hitbox2IndexMem				; |
		SEP #$20					;/



	ANIMATION:
		.External
		LDA !P2ExternalAnimTimer : BEQ ..clear		;\
		DEC !P2ExternalAnimTimer			; |
		LDA !P2ExternalAnim : STA !P2Anim		; | enforce external animations
		DEC !P2AnimTimer				; |
		JMP .CheckPlayer				;/
		..clear
		STZ !P2ExternalAnim				; clear external animation when timer hits 0

	; pipe check
		.Pipe
		LDA !P2Pipe : BEQ ..done			;\
		BMI ..vert					; |
		..horz						; |
		JMP .Walk					; | pipe animations
		..vert						; |
		LDA #!Mar_FaceFront : JMP .SetAnim		; |
		..done						;/

	; entrance check
		.Entrance
		LDA !P2Entrance : BEQ ..done			;\ animate on timer 1-20
		CMP #$21 : BCS ..done				;/
		CMP #$10 : BCC ..handleanim			;\
		CMP #$18 : BCC ..half				; |
		..full						; |
		LDA $14						; |
		BRA ..finish					; |
		..half						; |
		LDA $14						; |
		LSR A : BCC ..handleanim			; | spawn smoke
		..finish					; |
		AND #$01					; |
		BEQ $02 : LDA #$40				; |
		SBC #$20					; |
		STA !P2XSpeed					; |
		JSL CORE_DASH_SMOKE				; |
		..handleanim					;/
		STZ !P2XSpeed					; zero x speed
		LDA !P2Anim					;\
		CMP #!Mar_Victory : BCC ..set			; |
		CMP #!Mar_Victory_over : BCS ..set		; |
		JMP .GoToDraw					; | set animation
		..set						; |
		LDA #!Mar_Victory : BRA .SetAnim		; |
		..done						;/

	; hurt check
		.Hurt
		LDA !P2HurtTimer : BEQ ..done
		LDA !P2Anim
		CMP #!Mar_Hurt : BEQ .GoToDraw
		CMP #!Mar_Hurt+1 : BEQ .GoToDraw
		LDA #!Mar_Hurt : BRA .SetAnim
		..done

	; shrink check
		.Shrink
		LDA !P2ShrinkTimer : BEQ ..done
		LDA !P2Anim
		CMP #!Mar_Shrink : BEQ .GoToDraw
		CMP #!Mar_Shrink+1 : BEQ .GoToDraw
		LDA #!Mar_Shrink : BRA .SetAnim
		..done

	; rollout check
		.Rollout
		LDA !P2RolloutBuffer : BPL ..done
		BIT !P2YSpeed : BPL ..rolling
		..rising
		LDA #!Mar_RolloutStart : BRA .SetAnim
		..rolling
		LDA !P2Anim
		CMP #!Mar_Rollout : BCC +
		CMP #!Mar_Rollout_over : BCC .GoToDraw
	+	LDA #!Mar_Rollout : BRA .SetAnim
		..done

	; climb check
		.Climb
		LDA !P2Climbing : BEQ .OtherMovements
		LDA !P2Anim
		CMP #!Mar_Climb : BCC ..startclimb
		CMP #!Mar_Climb_over : BCC ..climbing
		..startclimb
		LDA #!Mar_Climb : STA !P2Anim
		STZ !P2AnimTimer
		..climbing
		LDA $15
		AND #$0F : BNE .GoToDraw
		STZ !P2AnimTimer
		JMP .CheckPlayer

	; branch assist
		.SetAnim
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw
		JMP .CheckPlayer

	; second block
		.OtherMovements

	; crouch/slide
		.Crouch
		LDA !P2Ducking : BNE ..smoke			;\ use crouch when crouching or just after picking up an item
		LDA !P2PickUp : BEQ ..done			;/
		..smoke						;\ friction smoke when crouching
		JSL CORE_SMOKE_AT_FEET				;/
		LDA !P2Carry : BNE ..crouch			;\
		LDA !P2Sliding : BEQ ..crouch			; |
		..slide						; |
		LDA #!Mar_Slide : BRA .SetAnim			; | determine whether crouch or slide anim should be used
		..crouch					; |
		LDA #!Mar_Crouch : BRA .SetAnim			; |
		..done						;/

	; ultimate charge
		.FlameStarCharge
		LDA !P2FlameStarCharge : BEQ ..done
		LDA #!Mar_FlameStar : BRA .SetAnim
		..done

	; mario finale
		.MarioFinale
		LDA !P2MarioFinale : BEQ ..done
		CMP #$20 : BNE ..fire
		LDA #!Mar_Cutscene+2 : BRA .SetAnim
		..fire
		LDA #!Mar_Hammer+2 : BRA .SetAnim
		..done

	; kick
		.Kick
		LDA !P2KickTimer : BEQ ..done			;\
		LDA #!Mar_Kick : BRA .SetAnim			; | kick
		..done						;/

	; special animation when turning with item
		.CarryTurn
		LDA !P2Carry : BEQ ..done			;\
		LDA !P2TurnTimer : BEQ ..done			; | turn if turn timer is set and item is held
		JMP .Turn					; |
		..done						;/

	; ground/air split
		LDA !P2InAir : BNE .Air				; determine air/ground status

	; ground only animations
		.Ground
		LDA !P2FireTimer : BEQ ..nofire			;\
		LDA #!Mar_Fire : BRA .SetAnim2			; | fire pose
		..nofire					;/
		LDA !P2XSpeed					;\
		ORA !P2VectorX					; | check for horizonal movement
		BNE .Move					;/

	; standing still on ground
		.Stand
		LDA $15						;\
		AND #$08 : BEQ ..idle				; | look up frame when up is held
		..lookup					; |
		LDA #!Mar_LookUp : BRA .SetAnim2		;/
		..idle						;\ otherwise use idle frame when X speed is 0
		LDA #$00					;/

	; branch assist 2
		.SetAnim2
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw2
		JMP .CheckPlayer

	; moving on ground
		.Move
		STA $00						;\
		LDA $15						; |
		AND #$03 : BEQ ..noturn				; | turn frame when holding against Xspeed direction
		DEC A						; |
		ROR #2						; |
		EOR $00 : BMI .Turn				;/
		..noturn
		LDA !P2Dashing					;\ determine walk/run animation
		CMP #$70 : BEQ .Run				;/

		.Walk
		LDA !P2Anim					;\
		CMP #!Mar_Walk : BCC ..set			; |
		CMP #!Mar_Walk_over : BCC .GoToDraw2		; | walk animation
		..set						; |
		LDA #!Mar_Walk : BRA .SetAnim2			;/

		.Run
		LDA !P2Anim					;\
		CMP #!Mar_Run : BCC ..set			; |
		CMP #!Mar_Run_over : BCC .GoToDraw2		; | run animation
		..set						; |
		LDA #!Mar_Run : BRA .SetAnim2			;/

		.Turn
		JSL CORE_SMOKE_AT_FEET
		LDA #!Mar_Turn : STA !P2Anim			; turn frame
		LDA !P2Carry : BEQ .GoToDraw2			;\
		DEC A : TAX					; | udpate carried item coordinate
		LDA !P2XPosLo : STA !SpriteXLo,x		; |
		LDA !P2XPosHi : STA !SpriteXHi,x		;/
		JMP .CheckPlayer

	; air only animations
		.Air
		LDA !P2SlantPipe : BEQ ..noslant
		LDA #$70 : STA !P2Dashing
		LDA.b #!Mar_LongJump : BRA .SetAnim3
		..noslant
		LDA !P2Blocked					;\
		BIT #$04 : BNE ..nowallkick			; |
		AND $15						; | eligible for wall kick -> turn pose
		AND #$03 : BEQ ..nowallkick			; |
		LDA #!Mar_WallKick : BRA .SetAnim3		; |
		..nowallkick					;/
		LDA !P2FireTimer : BNE .FastSwim_set		; midair throw fire pose
		BIT !P2Water : BVC .NoWater
		LDA !P2Carry : BNE .FastSwim
		LDA !P2FastSwim : BNE .SlowSwim

		.FastSwim
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		LSR #4
		DEC A
		BPL $02 : LDA #$00
		CLC : ADC !P2AnimTimer
		CMP #$07
		BCC $02 : LDA #$07
		STA !P2AnimTimer
		LDA !P2Anim
		LDX !P2Carry : BNE ..fast			; force fast swim when holding an item
		CMP #!Mar_SwimSlow+1 : BCC ..fast		;\ let the swim stroke finish
		CMP #!Mar_SwimSlow_over : BCC .CheckPlayer	;/
		..fast
		CMP #!Mar_SwimFast : BCC ..set
		CMP #!Mar_SwimFast_over : BCC .CheckPlayer
		..set
		LDA #!Mar_SwimFast : BRA .SetAnim3

		.SlowSwim
		LDA !P2Anim
		CMP #!Mar_SwimSlow : BCC ..set
		CMP #!Mar_SwimSlow_over : BCC .CheckPlayer
		..set
		LDA #!Mar_SwimSlow

	; branch assist 3
		.SetAnim3
		STA !P2Anim
		STZ !P2AnimTimer
		BRA .CheckPlayer

		.NoWater

	; spin jump
		.SpinJump
		LDA !P2SpinJump : BEQ ..done
		LDA !P2Anim
		CMP #!Mar_Spin : BCC ..set
		CMP #!Mar_Spin_over : BCC .CheckPlayer
		..set
		LDA #!Mar_Spin : BRA .SetAnim3
		..done

	; jumps
		.Jump
		LDA !P2Carry : BNE ..carry			; > carry jump check
		LDA !P2Anim					;\ long jump frame has priority
		CMP #!Mar_LongJump : BEQ .CheckPlayer		;/
		LDA #!Mar_Jump					;\
		BIT !P2YSpeed : BMI $01 : INC A			; | determine rising/falling frame
		BRA .SetAnim3					;/
		..carry						;\ lock to third frame of walk animation if holding item
		LDA #!Mar_Walk+2 : BRA .SetAnim3		;/
>>>>>>> Stashed changes

		..override
		RTL

<<<<<<< Updated upstream

		.ExtraCollision
		STZ $73E1					; overwritten code
		LDX #$00
		LDA !CurrentMario : BEQ ..return
		CMP #$01 : BEQ ..p1
	..p2	LDX #$80
	..p1	LDA !P2ExtraBlock-$80,x
		AND #$7F : STA !MarioBlocked
		EOR !P2ExtraBlock-$80,x
		STA !P2ExtraBlock-$80,x
..return	RTL





	; $73FA was cleared literally just before this routine was called

		.ExtraWater
		LDA !WaterLevel : BNE ..WaterLevel

		LDX #$00				;\
		LDA !CurrentMario : BEQ ..NoMario	; |
		CMP #$01 : BEQ ..P1			; |
	..P2	LDX #$80				; |
	..P1	LDA !P2ExtraBlock-$80,x : BPL ..NoMario	; | apply external water reg to Mario, then clear it
		AND #$7F				; |
		STA !P2ExtraBlock-$80,x			; |
		BRA ..Water				; |
		..NoMario				;/

		LDA !MarioExtraWaterJump : BNE ..CanJump

		LDA !3DWater : BEQ ..NoWater		;\
		LDA !IceLevel : BNE ..NoWater		; |
		REP #$20				; |
		LDA !MarioYPosLo			; | check for (nonfrozen) 3D water
		CLC : ADC #$0018			; > Mario offset
		BPL $03 : LDA #$0000			; > can't be out of bounds
		SEC : SBC !Level+2			; |
		SEP #$20				; |
		BCC ..NoWater				;/
		XBA : BNE ..Water
		XBA
		CMP #$10 : BCS ..Water			; Mario can jump out when in the top tile of the water

		..CanJump
		LDA #$00 : STA !MarioExtraWaterJump
		LDA !MarioUnderWater : BEQ ..Water	; water splash animation
		LDA #$FC				;\
		CMP !MarioYSpeed			; | I don't know what this does but smw does it
		BMI $02 : STA !MarioYSpeed		;/
		LDA #$01
		STA $73FA				; allow jump
		STA !MarioUnderWater
		TSB $8A					; as far as I can tell, these bits work like this:
		LDA #$02 : TRB $8A			; 0 - no swim, no jump
							; 1 - jump, no swim
							; 2 - entering water (?)
							; 3 - swim, no jump
		JML $00EA49

..Water		LDA #$03 : TSB $8A
..NoWater	JML $00EA49				; shared return
..WaterLevel	JML $00EA5E




		.Brick
		LDA !ProcessingSprites : BNE ..NotMario
		LDA $04
		CMP #$07 : BNE ..028756
		LDA $19 : BNE ..Break
..Bounce	REP #$20
		LDA $98 : STA $0C
		LDA $9A : STA $0A
		SEP #$20
		STZ $00
		LDA #$01 : STA $7C			;\ (0x07 is spinning turn block)
		LDA #$0C : STA $9C			; | Normal turn block code
		LDY #$00				;/
		JSR CORE_GENERATE_BLOCK
		JML $028788
..Break		JML $028758

..NotMario	LDA $04					;\ Overwritten code
		CMP #$07				;/
..028756	JML $028756				; > Return

..YSpeed	LDA !ProcessingSprites : BNE ..Return
		BIT !MarioYSpeed : BMI ..Return
		LDA #$D0 : STA !MarioYSpeed
..Return	RTL



; Multiplayer, Mario 0: $6DA6 OR $6DA7
; Multiplayer, Mario 1: $16 OR $6DA7
; Multiplayer, Mario 2: $16 OR $6DA6
; Singleplayer, Mario 0: $6DA6
; Singleplayer, Mario 1: $16

		.Pause1
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI $02 : BNE +				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		LDA #$00				; |
		RTL					; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer
		BEQ $03 : LDA $6DA6
		ORA $16
		BRA +

	..PCE	LDA !MultiPlayer
		BEQ $03 : LDA $6DA7
	-	ORA $6DA6
	+	AND #$10
		RTL

	..M2	LDA $16
		BRA -

=======
	; unpack
	.CheckPlayer
		LDA !MultiPlayer : BEQ ..thisone	; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ ..thisone
		..otherone
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$30
		JMP GRAPHICS
		..thisone
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3 : TAY


	.ReplaceAnim
		REP #$30
		TYA						;\ $02 = current working anim index
		LSR #3 : STA $02				;/
		LDA ANIM+$00,y : STA $0E
		LDA ANIM+$04,y : STA $04			;\ get source address (within file)
		AND #$0FFC : ASL #3				;/
		SEP #$10
		LDY !P2Carry : BEQ .NoCarryAddress		; no carry offset if not carrying
		LDY $02						;\ these always use the normal address, even when carrying an object
		LDX CARRY_ADDRESS,y : BMI .NoCarryAddress	;/
		LDX CARRY_POSE,y				;\
		CPX #$FF : BEQ .CarryAddress			; |
		REP #$10					; |
		STX $02						; | carry pose replacement
		TXA						; |
		ASL #3 : TAY					; |
		BRA .ReplaceAnim				;/
		.CarryAddress					;\
		CLC : ADC #$0800				; | carrying offset
		.NoCarryAddress					;/

		STA $02						; $02 = address
		LDY.b #!File_Mario : JSL GetFileAddress		; get address of file



		LDY #$00					; Y = big format
		LDA !P2ShrinkTimer				;\ shrink anim check
		AND #$0012 : BNE .BigAddress			;/
		LDX !P2HP					;\ always use big address if mario has more than a full heart
		CPX #$05 : BCS .BigAddress			;/
		.SmallAddress					;\
		LDA $02 : STA $00				; |
		AND #$01E0					; |
		STA $02						; > x tile
		LDA $00						; |
		AND #$7E00					; | recalculate address for small mario
		LSR #2						; | (keep x tile offset, multiply y tile offset by 0.75, add starting offset)
		STA $00						; |
		ASL A						; |
		ADC $00						; |
		ORA $02						; |
		ADC #$4800					; > starting offset of small mario
		DEY						; > Y = small format
		STA $02						; > store offset within file
		.BigAddress					;/


		LDA $04+1 : JSL CORE_GENERATE_RAMCODE_16bit	; compile RAM code


		LDA !P2Anim : STA !P2Anim2


	GRAPHICS:
		SEP #$30
		JSL CORE_FLASHPAL
		LDA !P2Status : BNE .DrawTiles
		LDA !P2HurtTimer : BNE .DrawTiles
>>>>>>> Stashed changes

; returning with carry clear will pause
; returning with carry set will not pause

		.Pause2
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI ..No				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		BEQ ..No				; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer : BEQ ..M
		LDA !P2Status
		ORA !P2Pipe
		BEQ ..Yes

	..M	LDA !MarioAnim
		CMP #$09
		RTL

	..PCE	LDA !MultiPlayer : BEQ +
		LDA !P2Status
		ORA !P2Pipe
		BEQ ..Yes
	+	LDA !P2Status-$80
		ORA !P2Pipe-$80
		BEQ ..Yes

	..No	SEC
		RTL

	..M2	LDA !P2Status-$80
		ORA !P2Pipe-$80
		BNE ..M

	..Yes	CLC
		RTL


		.Pause3
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI $02 : BNE +				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		LDA #$00				; |
		RTL					; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer : BEQ +
		LDA $6DA3
	+	ORA $15
	-	AND #$20
		RTL

	..PCE	LDA !MultiPlayer
		BEQ $03 : LDA $6DA3
		ORA $6DA2
		BRA -

	..M2	LDA !MultiPlayer
		BEQ $03 : LDA $6DA2
		ORA $15
		BRA -


; $00E2BD - $00E4B8 + the JSR at $00F636 - $00F69E
MarioAnimations:
		PHB								;\ wrapper to bank 0x00
		LDA #$00 : PHA : PLB						;/
		LDA !MarioImg : PHA						; push this

		LDA !P2ExternalAnimTimer : BEQ .ClearExternal			;\
		DEC !P2ExternalAnimTimer					; | enforce external animations for Mario
		LDA !P2ExternalAnim : STA !MarioImg				; |
		LDA !P2Anim : STA !CapeImg					; > enforce cape too
		BRA .NoOverride							;/
		.ClearExternal
		STZ !P2ExternalAnim						; clear once timer runs out
		STZ !P2Anim
		.NoOverride

		LDA #$05							;\
		CMP !MarioWallWalk : BCS +					; |
		LDA !MarioWallWalk						; |
		LDY $19 : BEQ ++						; |
		CPX #$13 : BNE +++						; | mario's screen-relative Xpos
	++	EOR #$01							; |
	+++	LSR A								; |
	+	REP #$20							; |
		LDA !MarioXPos							; |
		SBC $1A								; | (yep, no SEC)
		REP #$20							; |
		STA $7E								; |
		LDX !MarioClimb : BEQ ..NoClimb					; |
		LDA !MarioDirection						; |
		AND #$00FF							; |
		ASL A								; |
		TAX								; | climb offset code
		LDA.l .ClimbOffsets,x						; |
		CLC : ADC $7E							; |
		STA $7E								; |
		..NoClimb							;/


		LDA $788B							;\
		AND #$00FF							; > offset caused by shaking camera
		CLC : ADC !MarioYPos						; |


		; $00E34F reference
	;	LDY $19								; |
	;	CPY #$01							; |
	;	LDY #$01							; |
	;	LDX !MarioImg							; |
	;	BCS $02 : DEC A : DEY						; | mario's screen-relative Ypos
	;	CPX #$0A							; |
	;	BCS $03 : CPY $73DB						; > bop up and down while walking/running
	;	SBC $1C								; | (frames 00-09)
	;	CPX #$1C							; |
	;	BNE $03 : ADC #$0001						; |

		DEC A
		LDX !MarioImg : BEQ +
		CPX #$1C : BEQ ..D1
		CPX #$0A : BCS +
		LDY $19
		BNE $01 : INX
		CPX #$02 : BEQ ..U1
		CPX #$06 : BEQ ..U1
		CPX #$09 : BNE +
	..U1	DEC #2
	..D1	INC A
	+	SEC : SBC $1C

		STA $0E								; |

		LDA !DizzyEffect						;\
		AND #$00FF : BEQ ..NoDizzy					; |
		LDA !MarioXPos							; |
		SEC : SBC $1A							; |
		AND #$00FF							; |
		LSR #3								; |
		ASL A								; |
		TAX								; > adjust mario during dizzy effect
		LDA $40A040,x							; |
		AND #$1FFF							; |
		SEC : SBC $1C							; |
		EOR #$FFFF : INC A						; |
		CLC : ADC $0E							; |
		STA $0E								; |
		..NoDizzy							;/

		LDA $0E								;\
		LDY !Level+1 : BNE ..NoDown					; |
		LDY !Level							; |
		CPY #$25 : BNE ..NoDown						; |
		LDY !Level+4 : BEQ ..NoDown					; |
		REP #$20							; |
		STA $0E								; |
		LDA $6DF6							; > move down with screen on upgrade menu
		AND #$00FF							; |
		CLC : ADC $0E							; |
		CMP #$00F0							; |
		BCC $03 : LDA #$00F0						; |
		SEP #$20							; |
		..NoDown							; |
		STA $80								;/

		SEP #$20							;\
		LDA !MarioFlashTimer : BEQ .GFX					; |
		LSR #3								; |
		TAY								; |
		LDA $E292,y							; | figure out if mario should be drawn (flash logic)
		AND !MarioFlashTimer						; |
		ORA $9D								; |
		ORA $73FB							; |
		BNE .GFX							;/
		PLA : STA !MarioImg						;\
		PLB								; | return
		RTS								;/


; -info-
; $00	16-bit	index to table with X/Y disp, 2 bytes for each (facing left + facing right), only lo byte is used
; $02	16-bit	index to table with tile numbers (values 0x80+ are skipped), only lo byte is used
; $04	8-bit	collection of size bits for mario's tiles
; $05	8-bit	YXPPCCCT
; $06	16-bit	which tile we're on (starts at 0 and counts up)
; $08	16-bit	copy of !CapeImg, with hi byte cleared
; $0A	16-bit	used for VRAM transfer
; $0C	16-bit	used for VRAM transfer (should be 0 if cape is not used)
; $0E	16-bit	used as scratch by cape

; $7E	16-bit	mario xpos relative to screen
; $80	16-bit	mario ypos relative to screen

; compared to original:
; $05 was remapped to $00
; $06 was remapped to $02


	.GFX
		LDX #$00							;\
		LDA !MarioBehind						; |
		CMP #$02							; |
		BCS $02 : LDX #$02						; | !BigRAM+0: which index to use (_p0 or _p1)
		LDA $7499 : BEQ +						; | !BigRAM+2: how much to add to X (0x000 or 0x200)
		LDA !MarioImg							; |
		CMP #$0F : BEQ ++						; |
		CMP #$45 : BNE +						; |
	++	LDX #$00							; |
	+	REP #$20							; |
		LDA.l !OAMindex_index,x : STA !BigRAM+0				; |
		LDA.l !OAMindex_offset,x : STA !BigRAM+2			;/
		STZ $00								;\
		STZ $02								; |
		STZ $06								; |
		LDA !CapeImg							; | set up scratch
		AND #$00FF							; |
		STA $08								; |
		STZ $0C								;/
		LDX !MarioImg							; X = mario image
		SEP #$20

		; i believe these are used to determine the size of mario's tiles
		LDA #$C8							;\
		CPX #$43							; | if mario is a big balloon, $04 = 0xE8
		BNE $02 : LDA #$E8						; | otherwise, $04 = 0xC8
		STA $04								;/
		LDA $DCEC,x							;\
		ORA !MarioDirection						; | write $00 based on indexed table + direction
		TAY								; | this will index the X/Y coord table
		LDA $DD32,y : STA $00						;/
		TXA								;\
		CMP #$3D : BCS +						; |
		LDY $19								; > if !MarioImg <= 0x3D, add a value indexed by powerup status
		ADC $DF16,y							; | Y = that sum
	+	TAY								;/
		LDA $DF1A,y : STA $02						;\
		LDA $E00C,y : STA $0A						; | use Y to set up $02 and $0A
		LDA $E0CC,y : STA $0B						;/
		LDA $3E								;\
		AND #$07							; | Y = current screen mode
		TAY								;/

		LDA $64								;\
		LDX !MarioBehind						; | get PP bits
		BEQ $03 : LDA $E2B9,x						;/
		LDX !MarioDirection						;\ get X bit
		ORA $E18C,x							;/
		CLC : ADC !MarioPropOffset					; > add player palette offset
		ORA !MarioClimb							; > add extra priority during ledge hang
		CPY #$02							;\ clear lowest P bit during mode2
		BNE $02 : AND #$EF						;/
		STA $05								; store YXPPCCCT in scratch

		REP #$30							;\
		LDX !BigRAM+0							; |
		LDA !OAMindex_p1,x						; | index to _p1 or _p2
		CLC : ADC !BigRAM+2						; |
		TAX								; |
		SEP #$20							;/
		LDA !MarioImg							;\
		CMP #$25 : BEQ .BehindCape					; |
		CMP #$44 : BNE .NotBehindCape					; | frames 0x25 and 0x45 are drawn behind the cape
		.BehindCape							; |
		LDA #$F0 : STA !OAM_p1+$001,x					; > hide this tile
		INX #4								; |
		.NotBehindCape							;/

		JSR .Draw
		JSR .Draw
		JSR .Draw
		JSR .Draw

		LDA !MarioUpgrades
		AND #$04 : BNE $03 : JMP .Finish


	; cape code
		LDA !MarioSpinJump : BEQ .NoCapeRemap
		BIT !MarioYSpeed : BMI .AscendingCape

	.DescendingCape
		LDA $19 : BNE .NoCapeRemap
		LDA !MarioImg : BEQ +
		CMP #$0F : BEQ ..45
	..44	LDA #$44 : BRA $02
	..45	LDA #$45
	+	STA !MarioImg
		BEQ ..c_07
	..c_09	LDA #$09 : BRA .W
	..c_07	LDA #$07 : BRA .W

	.AscendingCape
		LDA $19 : BEQ +
		LDA !MarioImg : BEQ +
		CMP #$44 : BEQ ..25
	..0F	LDA #$0F : BRA $02
	..25	LDA #$25
		STA !MarioImg
	+	LDA !MarioImg : BEQ .W
		LDA #$0B
	.W	STA !CapeImg
		.NoCapeRemap

		LDA $19 : BNE +
		LDY $08
		REP #$20
		LDA $E448+6,y							; | ("MarioCapeY")
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $80
		STA $80
		SEP #$20
		+

		LDA #$00 : XBA							; clear B
		LDA #$2C : STA $02
		LDA #$FF : STA $04
		LDA !MarioImg : TAY
		LDA $E18E,y : TAY
		LDA $E1D5,y : STA $0C
		CMP #$04 : BCS .DrawCape
		LDA !CapeImg
		ASL #2
		ORA $0C
		TAY
		LDA $E23A,y : STA $0C
		LDA $E266,y
		BRA +

	.DrawCape
		LDA !MarioImg : TAY
		LDA $E1D6,y
	+	ORA !MarioDirection
		TAY
		LDA $E21A,y : STA $00
		LDA !MarioImg							;\
		CMP #$25 : BEQ +						; |
		CMP #$44 : BNE ++						; |
	+	PHX								; |
		REP #$20							; |
		LDX !BigRAM+0							; |
		LDA !OAMindex_p1,x						; | for mario images 0x25 and 0x44 cape is drawn in front
		CLC : ADC !BigRAM+2						; |
		TAX								; |
		SEP #$20							; |
		JSR .Draw							; |
		PLX								; |
		BRA .Finish							;/

	++	JSR .Draw							; draw cape (normally behind mario)

	.Finish
		REP #$20							;\
		TXA								; |
		SEC : SBC !BigRAM+2						; | store new OAM index
		LDX !BigRAM+0							; |
		STA !OAMindex_p1,x						;/
		SEP #$10
	; HIJACK: mario sprite sheet expansion
	; this code is for uploading GFX from sources other than the main file at $7E2000
	; should be merged into the above code for efficiency
		LDA !MarioClimb : BEQ .NormalVRAM
		REP #$20
		LDA !MarioPowerUp-1
		AND #$FF00
		BEQ $03 : LDA #$0080
		CLC : ADC #$7D00+$C00
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		SEC : SBC #$01C0
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
		BRA .c_VRAM

	.NormalVRAM
		LDX #$00
		LDA $09
		ORA #$0800
		CMP $09
		BEQ $01 : CLC
		AND #$F700
		ROR A
		LSR A
		ADC #$2000
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		LDX #$00
		LDA $0A
		ORA #$0800
		CMP $0A
		BEQ $01 : CLC
		AND #$F700
		ROR A
		LSR A
		ADC #$2000
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
	.c_VRAM	LDA $0B
		AND #$FF00
		LSR #3
		ADC #$2000
		STA $6D89
		CLC : ADC #$0200
		STA $6D93
		LDA $0C
		AND #$FF00
		LSR #3
		ADC #$2000
		STA $6D99

		; fire flash code
		SEP #$30
<<<<<<< Updated upstream
		LDY #$00
		LDA !MarioFireCharge							;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire					;/
		LDA !CurrentMario : BNE $03 : JMP ..NoUpdate
		LDA !P2FireFlash : BNE +
		CPY.b #!palset_mario_fire : BEQ $03 : JMP ..NoGlow
		+

		PHY
		TXY
		BEQ $02 : LDY #$80
		LDA !P2FireFlash : BEQ +
		PHX
		PHA
		LDA #$01 : STA !P2LockPalset
		CPX #$00
		BEQ $02 : LDX #$20
=======
		INC !P2FireFlash
		LDY !P2FireCharge : BEQ ..noglow	; Y = number of fire charges
		LDA !P2FlashPal
		AND #$1F : BEQ ..glow
		STA !P2FireFlash
		BRA ..noglow
		; glow: write to colors 2, 3, 8 and A
		..glow
		LDA !CurrentPlayer
		BEQ $02 : LDA #$20
		TAX
>>>>>>> Stashed changes
		REP #$20
		LDA #$7FFF
		STA.l !PaletteHSL+$904+$100,x
		STA.l !PaletteHSL+$906+$100,x
		STA.l !PaletteHSL+$908+$100,x
		STA.l !PaletteHSL+$90A+$100,x
		STA.l !PaletteHSL+$90C+$100,x
		STA.l !PaletteHSL+$90E+$100,x
		STA.l !PaletteHSL+$910+$100,x
		STA.l !PaletteHSL+$912+$100,x
		STA.l !PaletteHSL+$914+$100,x
		STA.l !PaletteHSL+$916+$100,x
		STA.l !PaletteHSL+$918+$100,x
		STA.l !PaletteHSL+$91A+$100,x
		STA.l !PaletteHSL+$91C+$100,x
		STA.l !PaletteHSL+$91E+$100,x
		SEP #$20
		LDA $02,s
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$0E
		PLA
		CMP #$10 : BCC ++
		SBC #$10
		ASL #3
		BRA +++
	++	ASL A
		EOR #$1F
	+++	JSL !MixRGB_Upload
		PLX
		PLY
		JMP ..NoGlow

		+
		LDA #$00 : STA !P2LockPalset
		PLY
		LDA !Palset8,x
		AND #$7F : BEQ +
		STZ !Palset8,x
		+
		CPY #$09 : BNE ..NoGlow

	; write to colors 2, 3, 8 and A
		..Glow
		CPX #$00
		BEQ $02 : LDX #$20
		LDA #$1F
		STA !PaletteHSL+$904+$100,x
		STA !PaletteHSL+$906+$100,x
		STA !PaletteHSL+$910+$100,x
		STA !PaletteHSL+$914+$100,x
		TXA
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
<<<<<<< Updated upstream
		LDY #$02
		LDA $14
=======
		LDA !P2FireFlash
		CPY #$02 : BCC ..singlecharge
		..doublecharge
		ASL A
		AND #$3F
		CMP #$10 : BCC +
		CMP #$30 : BCC ..singlecharge
		CLC
	+	ADC #$20
		..singlecharge
>>>>>>> Stashed changes
		AND #$3F
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		PHA
		PHX
<<<<<<< Updated upstream
		JSL !MixRGB_Upload
		PLX
=======
		LDY #$02
		JSL MixRGB_Upload
		PLA
		CLC : ADC #$06
		TAX
>>>>>>> Stashed changes
		LDA $01,s
		PHX
<<<<<<< Updated upstream
		JSL !MixRGB_Upload
=======
		LDY #$01
		JSL MixRGB_Upload
>>>>>>> Stashed changes
		PLX
		PLA
		INX #2
		LDY #$01
		JSL !MixRGB_Upload

		..NoGlow
		..NoUpdate

	.Return	PLA : STA !MarioImg						;\
		PLB								; | return
		RTS								;/


		.Draw
		LSR !MarioMaskBits : BCS .Fail					; if tile is masked, skip it

		LDY $02								;\ if tile doesn't exist, skip it
		LDA $DFDA,y : BMI .Fail						;/
		CLC : ADC !MarioTileOffset					; add player offset
		STA !OAM_p1+$002,x						; store tile num

		LDA $05 : STA !OAM_p1+$003,x					; store YXPPCCCT
		LDA !MarioImg							;\
		CMP #$43 : BNE .NoFlip						; |
		LDA $06								; |
		CMP #$04 : BNE .NoFlip						; | unless mario is big balloon, xflip the 5th tile
		LDA !OAM_p1+$003,x						; |
		EOR #$40							; |
		STA !OAM_p1+$003,x						; |
		.NoFlip								;/

		LDA $0C								;\
		CMP #$2C : BNE .NotCapeY					; |
		REP #$20							; | special cape check Y
		LDA $80								; |
		CLC : ADC #$0010						; > add 16px
		BRA +								;/

		.NotCapeY							;\
		LDY $00								; |
		REP #$20							; |
		LDA $80								; |
		CLC : ADC $DE32,y						; |
	+	PHA								; | see if tile is on-screen vertically
		CLC : ADC #$0010						; |
		CMP #$0100							; |
		PLA								; |
		SEP #$20							; |
		BCS .Fail							;/
		STA !OAM_p1+$001,x						; > store Y coord

		LDA $0C								;\
		CMP #$2C : BNE .NotCapeX					; |
		REP #$20							; | special cape check X
		LDA $7E								; |
		BRA +								;/

	.Fail	INC $00								;\ increment coord index
		INC $00								;/
		INC $02								; increment tile index
		INC $06								; increment tile counter
		ASL $04								; always shift this
		RTS

		.NotCapeX							;\
		LDY $00								; |
		REP #$20							; |
		LDA $7E								; |
		CLC : ADC $DD4E,y						; | see if tile is on-screen horizontally
	+	PHA								; |
		CLC : ADC #$0080						; |
		CMP #$0200							; |
		PLA								; |
		SEP #$20							; |
		BCS .Fail							;/
		STA !OAM_p1+$000,x						; > store X coord
		XBA								;\ swap
		LSR A								;/

		.WriteHi							;\
		PHX								; |
		PHP								; |
		REP #$20							; |
		TXA								; |
		LSR #2								; |
		TAX								; |
		SEP #$20							; | write OAM hi byte
		ASL $04								; |
		ROL A								; |
		PLP								; |
		ROL A								; |
		AND #$03							; |
		STA !OAMhi_p1+$00,x						; |
		PLX								;/
		INX #4								; increment OAM index
		INC $00								;\ increment coord index
		INC $00								;/
		INC $02								; increment tile index
		INC $06								; increment tile counter
		RTS


	.ClimbOffsets
	dw $FFFD,$0004



MarioTileRemap:	CLC : ADC !MarioTileOffset		; > add player offset
		STA !OAM+$102-$18,y			; original code
		LDX $05					; original code
		RTL					; > return

.Prop		CLC : ADC !MarioPropOffset		; > add player palette offset
		ORA !MarioClimb
		PHA
		LDA $3E
		AND #$07
		CMP #$02 : BNE +			; priority works differently in mode 2
		PLA
		AND #$EF
		BRA ++
	+	PLA
	++	STA !OAM+$103-$18,y			;\
		STA !OAM+$107-$18,y			; | original code
		STA !OAM+$10F-$18,y			;/
		JML $00E3DB				; > return


.Coords		PHY					; preserve

		XBA
		LDA !CurrentMario : BNE +		;\ don't draw mario if he's not in play
		LDA #$F0 : BRA ..WriteY			;/
	+	XBA

		CPY #$10 : BNE ..NoCape			;\
		LDY !MarioPowerUp : BNE ..NoCape	; |
		LDY $73DF				; | adjust Mario's cape when small
		CLC : ADC.w MarioCapeY,y		; |
		..NoCape				;/

		STA $0E					;\
		LDA !DizzyEffect : BEQ ..NoDizzy	; |
		REP #$20				; |
		LDA $94					; |
		SEC : SBC $1A				; |
		AND #$00FF				; |
		LSR #3					; |
		ASL A					; |
		PHX					; | adjust mario during dizzy effect
		TAX					; |
		LDA $40A040,x				; |
		AND #$1FFF				; |
		SEC : SBC $1C				; |
		PLX					; |
		EOR #$FFFF : INC A			; |
		CLC : ADC $0E				; |
		SEP #$20				; |
		STA $0E					; |
		..NoDizzy				; |
		LDA $0E					;/

		LDY !Level+1 : BNE ..NoDown		;\
		LDY !Level				; |
		CPY #$25 : BNE ..NoDown			; |
		LDY !Level+4 : BEQ ..NoDown		; |
		REP #$20				; |
		STA $0E					; |
		LDA $6DF6				; | move down with screen on upgrade menu
		AND #$00FF				; |
		CLC : ADC $0E				; |
		CMP #$00F0				; |
		BCC $03 : LDA #$00F0			; |
		SEP #$20				; |
		..NoDown				;/

		..WriteY
		PLY					;\ write Ypos
		STA !OAM+$101-$18,y			;/

		REP #$20				;\
		LDA $7E					; |
		CLC : ADC $DD4E,x			; |
		STA $0E					; |
		LDX !MarioClimb : BEQ ..NoClimb		; \
		LDA !MarioDirection			;  |
		AND #$00FF				;  |
		ASL A					;  |
		TAX					;  | climb offset code
		LDA.l ..ClimbOffsets,x			;  |
		CLC : ADC $0E				;  |
		STA $0E					;  |
		..NoClimb				; /
		CLC : ADC #$0080			; |
		CMP #$0200				; | SMW X coord code
		LDA $0E					; |
		SEP #$20				; |
		BCS $05					; |
		STA !OAM+$100-$18,y			; |
		XBA					; |
		LSR A					;/

		RTL					; > return


	..ClimbOffsets
	dw $FFFD,$0004



.Fire		LDA !MarioPowerUp : BEQ ..07		;\
	..3F	LDA #$3F				; |
		LDY !MarioAir				; |
		RTL					; | different pose for throwing fireball when small
	..07	LDA #$07				; |
		LDY !MarioAir				; |
		RTL					;/

.Expand		LDA #$0A : STA $6D84			; overwritten code, number of 8x8 tiles to upload for mario
		LDA !MarioClimb : BEQ ..R

		REP #$20
		LDA !MarioPowerUp-1
		AND #$FF00
		BEQ $03 : LDA #$0080
		CLC : ADC #$7D00+$C00
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		SEC : SBC #$01C0
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
		SEP #$20

	..R	RTL




	; Mario's physics routine seems to be at $00DC2D


MarioHurtbox:	PHA
		LDX #$00
		LDA !CurrentMario
		CMP #$01 : BEQ +
		LDX #$80
	+	LDA $00 : STA !P2Hurtbox-$80+0,x
		LDA $08 : STA !P2Hurtbox-$80+1,x
		LDA $01 : STA !P2Hurtbox-$80+2,x
		LDA $02 : STA !P2Hurtbox-$80+4,x
		LDA $03 : STA !P2Hurtbox-$80+5,x
		PLA
		STA $09
		STA !P2Hurtbox-$80+3,x
		PLX
		RTL



macro CommentOut()


<<<<<<< Updated upstream
;=====================;
; TRANSCRIBED $00C47E ;
;=====================;
MarioMain:
		STZ $78
	; this feature was scrapped during vanilla
	;	LDA $73CB : BPL +
	;	JSL $01C580
	;	STZ $73CB
	;	+

	; keyhole logic
	; BEQ to BRA to $00C4F8

.CODE_00C4F8	LDA $73FB : BEQ .ProcessMario
		JMP .CODE_00C58F

.ProcessMario
.CODE_00C500	LDA $9D : BNE .CODE_00C569
		INC $14				; oh gosh
		LDX #$13			;\
	-	LDA $7495,x			; | auto-decrement $7496-$74A8
		BEQ $03 : DEC $7495,x		; | (note the BNE, $7495 is not decremented)
		DEX : BNE -			;/
		LDA $14
		AND #$03 : BNE .CODE_00C569
		LDA $7495 : BEQ .CODE_00C533	; something related to score count
		; useless score code here??
.CODE_00C533	LDY $74AD			;\
		CPY $74AE			; |
		BCS $03 : LDY $74AE		; |
		LDA $6DDA : BMI +		; |
		CPY #$01 : BNE +		; | POW (blue and silver) timer + music
		LDY $790C : BNE +		; |
		STA !SPC3			; |
	+	CMP #$FF : BEQ .CODE_00C55C	; |
		CPY #$1E : BNE .CODE_00C55C	; |
		LDA #$24 : STA !SPC4		;/
.CODE_00C55C	LDX #$06			;\
	-	LDA $74A8,x			; | auto-decrement $74A9-$74AE
		BEQ $03 : DEC $74A8,x		; | (same as above: $74A8 is not decremented)
		DEX : BNE -			;/
.CODE_00C569	JSR .MARIO_ANIM			; this seems to be the main part of mario's code
		LDA $16				;\ if mario is not pressing select on this frame, skip the item box drop thing
		AND #$20 : BEQ .CODE_00C58F	;/
		; unused debug code here (BRAd past)
.CODE_00C585	PHB				;\
		LDA #$02			; |
		PHA : PLB			; | process item box swap
		JSL $028008			; |
		PLB				;/
.CODE_00C58F	STZ $7402			; clear "mario on note block" flag
		RTS				; return


.MARIO_ANIM	LDA !MarioAnim
		JSL $0086DF

		.ANIM_ptr
		dw .Normal			; 00
		dw .PowerDown			; 01
		dw .MushroomGet			; 02
		dw .CapeGet			; 03
		dw .FlowerGet			; 04
		dw .HorizontalPipe		; 05
		dw .VerticalPipe		; 06
		dw .SlantPipe			; 07
		dw .YoshiWings			; 08
		dw .Death			; 09
		dw .EnterCastle			; 0A
		dw .Freeze			; 0B
		dw .RandomMovement		; 0C
		dw .Door			; 0D





;
; MARIO MAIN START
;

.Normal		; a bunch of debug code at the start
.CODE_00CCBB	LDA $7493			; end level?
		BEQ $03 : JMP .CODE_00C915
		JSR .CODE_00CDDD		; unknown
		LDA $9D : BNE .CODE_00CCDF

		STZ $73E8
		STZ $73DE
		LDA !MarioStunTimer : BEQ .CODE_00CCE0
		DEC !MarioStunTimer
		STZ !MarioXSpeed
		LDA #$0F : STA !MarioImg
.CODE_00CCDF	RTS

.CODE_00CCE0	; special level code
.CODE_00CD24	LDA !MarioYSpeed : BPL +	;\
		LDA !MarioBlocked		; |
		AND #$08 : BEQ +		; | mario y speed = 0 when bonking
		STZ !MarioYSpeed		; |
		+				;/

		JSR .CODE_00DC2D		; > mario X + Y speed
		JSR .CODE_00E92B		; > mario collision
		JSR .CODE_00F595		; > mario screen border interaction

		STZ $73DD
		LDY $73F3 : BNE .CODE_00CD95
		LDA $78BE : BEQ +
		LDA #$1F : STA $8B
	+	LDA !MarioClimbing : BNE .CODE_00CD72
		LDA $748F
		; yoshi check
		BNE .CODE_00CD79
		LDA $8B
		AND #$1B
		CMP #$1B
		BNE .CODE_00CD79
		LDA $15
		AND #$0C : BEQ .CODE_00CD72
		LDY $72 : BNE .CODE_00CD72
		LDA $8B
		AND #$04 : BEQ .CODE_00CD79
.CODE_00CD72	LDA $8B : STA !MarioClimbing
		JMP .CODE_00DB17		; mario climb handler

.CODE_00CD79	LDA !MarioUnderWater : BEQ .CODE_00CD82
		JSR .CODE_00D988		; mario swim handler
		; BRA to next yoshi check
		RTS

.CODE_00CD82	JSR .CODE_00D5F2		; > controls, includes jump/spin jump
		JSR .CODE_00D062		; > shoot fireball routine
		JSR .CODE_00D7E4		; > handle flight + jump Y speed influence
		JSL .CODE_00CEB1		; > set cape image
		; yoshi check
		RTS

.CODE_00CD95	LDA #$42			;\
		LDX $19				; |
		BEQ $02 : LDA #$43		; |
		DEY				; | mario pose during level end
		BEQ $05 : STY $73F3 : LDA #$0F	; |
		STA !MarioImg			; |
		RTS				;/

;
; MARIO MAIN SUB
;

.CODE_00DC2D	LDA !MarioYSpeed : STA $8A
		LDA $73E3 : BEQ +		; wall run stuff
		LSR A
		LDA !MarioXSpeed
		BCC $03 : EOR #$FF : INC A
		STA !MarioYSpeed
	+	LDX #$00 : JSR .MarioSpeed
		LDX #$02 : JSR .MarioSpeed
		LDA $8A : STA !MarioYSpeed
		RTS

		.MarioSpeed
		LDA !MarioXSpeed,x
		ASL #4
		CLC : ADC $73DA,x
		STA $73DA,x
		REP #$20
		PHP
		LDA !MarioXSpeed,x
		LSR #4
		AND #$000F
		CMP #$0008
		BCC $03 : ORA #$FFF0
		PLP
		ADC !MarioXPos,x
		STA !MarioXPos,x
		SEP #$20
=======
	ThrowFireball:
		%Ex_Index_X_fast()

		.YOffset
		STZ $00
		LDA !P2HP
		CMP #$05 : BCC ..done
		LDA #$08 : STA $00
		..done

		.Direction
		LDA $15
		AND #$03 : BNE ..index
		..dir
		LDA !P2Direction
		EOR #$01
		INC A
		..index
		TAY

		.SpawnFireball
		LDA !P2XPosLo
		CLC : ADC DATA_FireX-1,y
		STA !Ex_XLo,x
		LDA !P2XPosHi
		ADC #$00
		STA !Ex_XHi,x
		LDA !P2YPosLo
		SEC : SBC $00
		STA !Ex_YLo,x
		LDA !P2YPosHi
		SBC #$00
		STA !Ex_YHi,x
		LDA #!MarFireball_Num : STA !Ex_Num,x
		LDA DATA_FireSpeed-1,y : STA !Ex_XSpeed,x
		LDA #$36 : STA !SPC4				; fire sfx
		LDA !P2MarioFinale : BNE ..tacticalfire		; finale = tactical X speed
		LDA !MarioUpgrades				;\
		AND $15						; | tactical fire upgrade check
		AND #$08 : BEQ ..normalfire			;/
		..tacticalfire					;\
		LDA !Ex_XSpeed,x				; | tactical fire clause
		CMP #$80 : ROR !Ex_XSpeed,x			; |
		LDA #$C0					;/
		..normalfire					;\ set fire y speed
		STA !Ex_YSpeed,x				;/
		JSL RegisterProjectile
>>>>>>> Stashed changes
		RTS



<<<<<<< Updated upstream
;
; OTHER ANIMS
;



; anim 0B
.Freeze		STZ $73DE
		STZ $73ED
		LDA $7493 : BEQ .CODE_00C5CE	; end level timer
		JSL $0CAB13
		LDA !GameMode
		CMP #$14 : BEQ .CODE_00C5D1
		JMP .CODE_00C95B

.CODE_00C5CE	STZ !HDMA
.CODE_00C5D1	LDA #$01 : STA $7B88
		LDA #$07 : STA $7928
		JSR .NoButtons
		JMP .CODE_00CD24


.RandomMovement	JSR .NoButtons
		STZ $73DE
		JSR





.CODE_00DC2D
.CODE_00E92B
.CODE_00F595




.NoButtons	STZ $15
		STZ $16
		STZ $17
		STZ $18
		RTS





endmacro

=======
;=====================;
;	D A T A       ;
;=====================;



	; Anim format:
	; dw $TTTT : db $tt,$NN
	; dw $DDDD
	; dw $CCCC
	; TTTT is tilemap pointer.
	; tt is frame count.
	; NN is next anim.
	; DDDD is dynamo pointer.
	; CCCC is clipping pointer.


	; 0x00 if the pose has a carry variant, 0xFF if it doesn't
	CARRY_ADDRESS:
	db $00					; idle
	db $00,$00,$00				; walk
	db $00,$00,$00				; run
	db $00					; lookup
	db $00					; crouch
	db $00,$00				; jump
	db $FF					; slide
	db $FF					; face back
	db $FF					; face front
	db $FF					; kick
	db $00					; long jump
	db $00					; turn
	db $FF					; victory
	db $FF,$FF,$FF,$FF			; swim slow
	db $FF,$FF,$FF				; swim fast
	db $FF,$FF				; climb
	db $FF,$FF,$FF				; hammer / throw
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF		; cutscene frames
	db $FF					; balloon
	db $FF,$FF,$FF,$FF			; spin
	db $FF					; fire
	db $FF					; hang
	db $FF					; rollout start
	db $FF,$FF,$FF,$FF			; rollout
	db $FF					; wall kick
	db $FF					; flame star
	db $FF,$FF				; hurt
	db $FF,$FF				; shrink
	db $FF					; dead

	; which pose to replace the pose (index) with if mario is carrying something, 0xFF if there is no replacement
	CARRY_POSE:
	db $FF					; idle
	db $FF,$FF,$FF				; walk
	db !Mar_Walk+0,!Mar_Walk+1,!Mar_Walk+2	; run
	db $FF					; lookup
	db $FF					; crouch
	db !Mar_Walk+2,!Mar_Walk+1		; jump
	db $FF					; slide
	db $FF					; face back
	db $FF					; face front
	db $FF					; kick
	db !Mar_Walk+2				; long jump
	db $FF					; turn
	db $FF					; victory
	db $FF,$FF,$FF,$FF			; swim slow
	db $FF,$FF,$FF				; swim fast
	db $FF,$FF				; climb
	db $FF,$FF,$FF				; hammer / throw
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF		; cutscene frames
	db $FF					; balloon
	db $FF,$FF,$FF,$FF			; spin
	db $FF					; fire
	db $FF					; hang
	db $FF					; rollout start
	db $FF,$FF,$FF,$FF			; rollout
	db $FF					; wall kick
	db $FF					; flame star
	db $FF,$FF				; hurt
	db $FF,$FF				; shrink
	db $FF					; dead




	ANIM:
	.Idle0
	dw .16x32TM : db $00,!Mar_Idle
	%Dyn16Bit(2, $000)
	dw .ClippingStandard

	.Walk
	dw .16x32TM : db $06,!Mar_Walk+1
	%Dyn16Bit(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Walk+2
	%Dyn16Bit(2, $002)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Walk
	%Dyn16Bit(2, $004)
	dw .ClippingStandard

	.Run
	dw .24x32TM : db $02,!Mar_Run+1
	%Dyn16Bit(3, $080)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Mar_Run+2
	%Dyn16Bit(3, $083)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Mar_Run
	%Dyn16Bit(3, $086)
	dw .ClippingStandard

	.LookUp
	dw .16x32TM : db $FF,!Mar_LookUp
	%Dyn16Bit(2, $006)
	dw .ClippingStandard

	.Crouch
	dw .16x32TM : db $FF,!Mar_Crouch
	%Dyn16Bit(2, $008)
	dw .ClippingCrouch

	.Jump
	dw .16x32TM : db $FF,!Mar_Jump
	%Dyn16Bit(2, $00A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Jump+1
	%Dyn16Bit(2, $00C)
	dw .ClippingStandard

	.Slide
	dw .16x32TM : db $FF,!Mar_Slide
	%Dyn16Bit(2, $00E)
	dw .ClippingCrouch

	.FaceBack
	dw .16x32TM : db $FF,!Mar_FaceBack
	%Dyn16Bit(2, $08E)
	dw .ClippingStandard

	.FaceFront
	dw .16x32TM : db $FF,!Mar_FaceFront
	%Dyn16Bit(2, $08C)
	dw .ClippingStandard

	.Kick
	dw .16x32TM : db $08,!Mar_Idle
	%Dyn16Bit(2, $04E)
	dw .ClippingStandard

	.LongJump
	dw .24x32TM : db $FF,!Mar_LongJump
	%Dyn16Bit(3, $089)
	dw .ClippingStandard

	.Turn
	dw .16x32TM : db $FF,!Mar_Turn
	%Dyn16Bit(2, $04C)
	dw .ClippingStandard

	.Victory
	dw .16x32TM : db $FF,!Mar_Victory
	%Dyn16Bit(2, $04A)
	dw .ClippingStandard

	.SwimSlow
	dw .24x32TM : db $FF,!Mar_SwimSlow
	%Dyn16Bit(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+2
	%Dyn16Bit(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+3
	%Dyn16Bit(3, $0C3)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+0
	%Dyn16Bit(3, $0C6)
	dw .ClippingStandard

	.SwimFast
	dw .24x32TM : db $08,!Mar_SwimFast+1
	%Dyn16Bit(3, $100)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimFast+2
	%Dyn16Bit(3, $103)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimFast
	%Dyn16Bit(3, $106)
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $08,!Mar_Climb+1
	%Dyn16Bit(2, $10B)
	dw .ClippingStandard
	dw .16x32TMX : db $08,!Mar_Climb
	%Dyn16Bit(2, $10B)
	dw .ClippingStandard

	.Hammer
	dw .16x32TM : db $06,!Mar_Hammer+1
	%Dyn16Bit(2, $140)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Hammer+2
	%Dyn16Bit(2, $142)
	dw .ClippingStandard
	dw .16x32TM : db $0C,!Mar_Idle
	%Dyn16Bit(2, $144)
	dw .ClippingStandard

	.Cutscene
	dw .16x32TM : db $FF,!Mar_Cutscene
	%Dyn16Bit(2, $146)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+1
	%Dyn16Bit(2, $148)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+2
	%Dyn16Bit(2, $14A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+3
	%Dyn16Bit(2, $14C)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+4
	%Dyn16Bit(2, $14E)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+5
	%Dyn16Bit(2, $180)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+6
	%Dyn16Bit(2, $182)
	dw .ClippingStandard

	.Balloon
	dw .32x32TM : db $FF,!Mar_Balloon
	%Dyn16Bit(4, $184)
	dw .ClippingStandard

	.Spin
	dw .16x32TM : db $02,!Mar_Spin+1
	%Dyn16Bit(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Mar_Spin+2
	%Dyn16Bit(4, $08C)
	dw .ClippingStandard
	dw .16x32TMX : db $02,!Mar_Spin+3
	%Dyn16Bit(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Mar_Spin
	%Dyn16Bit(4, $08E)
	dw .ClippingStandard

	.Fire
	dw .16x32TM : db $FF,!Mar_Fire
	%Dyn16Bit(2, $1C0)
	dw .ClippingStandard

	.Hang
	dw .16x32TM : db $FF,!Mar_Hang
	%Dyn16Bit(2, $1C2)
	dw .ClippingStandard


	.RolloutStart
	dw .24x32TM : db $FF,!Mar_RolloutStart
	%Dyn16Bit(3, $1CD)
	dw .ClippingStandard

	.Rollout1
	dw .RolloutTM : db $02,!Mar_Rollout+1
	%Dyn16Bit(3, $1C7)
	dw .ClippingCrouch
	.Rollout2
	dw .RolloutTM : db $02,!Mar_Rollout+2
	%Dyn16Bit(3, $1CA)
	dw .ClippingCrouch
	.Rollout3
	dw .RolloutTM_flip : db $02,!Mar_Rollout+3
	%Dyn16Bit(3, $1C7)
	dw .ClippingCrouch
	.Rollout4
	dw .RolloutTM_flip : db $02,!Mar_Rollout+0
	%Dyn16Bit(3, $1CA)
	dw .ClippingCrouch

	.WallKick
	dw .16x32TMX : db $FF,!Mar_WallKick
	%Dyn16Bit(2, $04C)
	dw .ClippingStandard

	.FlameStar
	dw .16x32TM : db $FF,!Mar_FlameStar
	%Dyn16Bit(2, $0CE)
	dw .ClippingStandard

	.Hurt
	dw .16x32TM : db $04,!Mar_Hurt+1
	%Dyn16Bit(2, $1C4)
	dw .ClippingCrouch
	dw .24x32TM : db $0F,!Mar_Idle
	%Dyn16Bit(3, $188)
	dw .ClippingCrouch

	.Shrink
	dw .16x32TM : db $04,!Mar_Shrink+1
	%Dyn16Bit(2, $18B)
	dw .ClippingCrouch
	dw .16x32TM : db $04,!Mar_Shrink+0
	%Dyn16Bit(2, $000)
	dw .ClippingCrouch

	.Dead
	dw .16x32TM : db $FF,!Mar_Dead
	%Dyn16Bit(2, $18E)
	dw .ClippingStandard



	.RolloutTM
	dw $0010			; big mario
	db $20,$FC,$F0,!P1Tile1
	db $20,$04,$F0,!P1Tile1+1
	db $20,$FC,$00,!P1Tile5
	db $20,$04,$00,!P1Tile5+1
	dw $0010			; small mario
	db $20,$FC,$F8,!P1Tile1
	db $20,$04,$F8,!P1Tile1+1
	db $20,$FC,$00,!P1Tile1+$10
	db $20,$04,$00,!P1Tile1+$11
	..flip
	dw $0010			; big mario
	db $E0,$04,$08,!P1Tile1
	db $E0,$FC,$08,!P1Tile1+1
	db $E0,$04,$F8,!P1Tile5
	db $E0,$FC,$F8,!P1Tile5+1
	dw $0010			; small mario
	db $E0,$04,$04,!P1Tile1
	db $E0,$FC,$04,!P1Tile1+1
	db $E0,$04,$FC,!P1Tile1+$10
	db $E0,$FC,$FC,!P1Tile1+$11



	.16x32TM
	dw $0008			; big mario
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile5
	dw $0008			; small mario
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile1+$10
	.16x32TMX
	dw $0008			; big mario
	db $60,$00,$F0,!P1Tile1
	db $60,$00,$00,!P1Tile5
	dw $0008			; small mario
	db $60,$00,$F8,!P1Tile1
	db $60,$00,$00,!P1Tile1+$10


	.24x32TM
	dw $0010			; big mario
	db $20,$00,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile1+1
	db $20,$00,$00,!P1Tile5
	db $20,$08,$00,!P1Tile5+1
	dw $0010			; small mario
	db $20,$00,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile1+1
	db $20,$00,$00,!P1Tile1+$10
	db $20,$08,$00,!P1Tile1+$11


	.32x32TM
	dw $0010			; big mario
	db $20,$F8,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile2
	db $20,$F8,$00,!P1Tile5
	db $20,$08,$00,!P1Tile6
	dw $0010			; small mario
	db $20,$F8,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile2
	db $20,$F8,$00,!P1Tile1+$10
	db $20,$08,$00,!P1Tile2+$10


	.TinyFlameDynamo
	db ..end-..start
	..start
	%Dyn24Bit(3, $026, !P1Tile3)
	%Dyn24Bit(3, $036, !P1Tile3+$10)
	..end



	.ClippingStandard
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $0002,$FFF6			; X/Y
	db $0C,$1A			; W/H


	.ClippingCrouch
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $06,$06,$0A,$0A		; R/L/R/L
	db $10,$10,$00,$08		; D/D/U/C
	; hurtbox
	dw $0001,$0004			; X/Y
	db $0C,$0C			; W/H



.End
print "  Anim data: $", hex(.End-ANIM), " bytes"


; vanilla collision parameters:
;	x + 2
;	w = 0x0C
;	small
;	y + 0x14
;	h = 0x0C
;	big
;	y + 0x06
;	h = 0x1A



	DATA:
	; all values have 3 added to them compared to all.log
	; this is to maintain the same jump height despite gravity being applied earlier
	.JumpHeight
	..normal
	db $B3,$B1,$AE,$AC,$A9,$A7,$A4,$A2
	..spin
	db $B9,$B7,$B5,$B3,$B1,$AE,$AC,$A9
>>>>>>> Stashed changes

	.WallKickSpeed
	db $00,$20,$E0,$00

	.FlameDashSpeed
	db $00,$40,$C0,$00
	db $00,$50,$B0,$00		; with boost

	.FlameDashHitbox
	dw $0000,$FFF2 : db $14,$1E	; X/Y + W/H
	db $40,$E8			; speeds
	db $12				; timer
	db $05				; hitstun
	db $00,$38			; SFX
	db $00

	.SlideHitbox
	dw $0008,$0008 : db $08,$0C	; X/Y + W/H
	db $10,$C8			; speeds
	db $20				; timer
	db $04				; hitstun
	db $02,$00			; SFX




	.FireX
	db $08,$00
	.FireSpeed
	db $30,$D0


	; indexed by slope*2
	.RestingSpeed
	dw $E000	; supersteep left
	dw $F000	; steep slope left
	dw $0000	; normal slope left
	dw $0000	; gradual slope left
	dw $0000	; flat ground
	dw $0000	; gradual slope right
	dw $0000	; normal slope right
	dw $1000	; steep slope right
	dw $2000	; supersteep right

	; indexed by slope*2
	.SlidingSpeed
	dw $C000	; supersteep left
	dw $D000	; steep slope left
	dw $D400	; normal slope left
	dw $D800	; gradual slope left
	dw $0000	; flat ground
	dw $2800	; gradual slope right
	dw $2C00	; normal slope right
	dw $3000	; steep slope right
	dw $4000	; supersteep right

	; accel left, accel right
	.Friction
	dw $0400,$0100		; supersteep left
	dw $0200,$0040		; steep slope left
	dw $0180,$00C0		; normal slope left
	dw $0100,$0100		; gradual slope left
	dw $0100,$0100		; flat ground
	dw $0100,$0100		; gradual slope right
	dw $00C0,$0180		; normal slope right
	dw $0040,$0200		; steep slope right
	dw $0100,$0400		; supersteep right
	..ice
	dw $0200,$0080		; supersteep left
	dw $0080,$0020		; steep slope left
	dw $0040,$0020		; normal slope left
	dw $0020,$0020		; gradual slope left
	dw $0020,$0020		; flat ground
	dw $0020,$0020		; gradual slope right
	dw $0020,$0040		; normal slope right
	dw $0020,$0080		; steep slope right
	dw $0080,$0200		; supersteep right

	; walking left, running left, walking right, running right
	.XAccel
	dw $0400,$0400,$0300,$0300	; supersteep left
	dw $0180,$0180,$0100,$0100	; steep slope left
	dw $0180,$0180,$0140,$0140	; normal slope left
	dw $0180,$0180,$0180,$0180	; gradual slope left
	dw $0180,$0180,$0180,$0180	; flat ground
	dw $0180,$0180,$0180,$0180	; gradual slope right
	dw $0140,$0140,$0180,$0180	; normal slope right
	dw $0100,$0100,$0180,$0180	; steep slope right
	dw $0300,$0300,$0400,$0400	; supersteep right
	..turning
	dw $0300,$0600,$0300,$0600	; supersteep left, turning
	dw $0300,$0600,$0200,$0400	; steep slope left, turning
	dw $02C0,$0580,$0240,$0480	; normal slope left, turning
	dw $0280,$0500,$0280,$0500	; gradual slope left, turning
	dw $0280,$0500,$0280,$0500	; flat ground, turning
	dw $0280,$0500,$0280,$0500	; gradual slope right, turning
	dw $0240,$0480,$02C0,$0580	; normal slope right, turning
	dw $0200,$0400,$0300,$0600	; steep slope right, turning
	dw $0300,$0600,$0300,$0600	; supersteep right, turning

	..ice
	dw $0400,$0400,$0200,$0300	; supersteep left
	dw $0180,$0180,$0080,$0100	; steep slope left
	dw $0180,$0180,$0080,$0140	; normal slope left
	dw $0080,$0180,$0080,$0180	; gradual slope left
	dw $0080,$0180,$0080,$0180	; flat ground
	dw $0080,$0180,$0080,$0180	; gradual slope right
	dw $0080,$0140,$0180,$0180	; normal slope right
	dw $0080,$0100,$0180,$0180	; steep slope right
	dw $0200,$0300,$0400,$0400	; supersteep right
	..iceturning
	dw $0300,$0300,$0300,$0300	; supersteep left, turning
	dw $0300,$0300,$0040,$0200	; steep slope left, turning
	dw $0080,$02C0,$0040,$0240	; normal slope left, turning
	dw $0040,$0280,$0040,$0280	; gradual slope left, turning
	dw $0040,$0280,$0040,$0280	; flat ground, turning
	dw $0040,$0280,$0040,$0280	; gradual slope right, turning
	dw $0040,$0240,$0080,$02C0	; normal slope right, turning
	dw $0040,$0200,$0300,$0300	; steep slope right, turning
	dw $0300,$0300,$0300,$0300	; supersteep right, turning




; order is:
;	+00: walking left
;	+01: walking right
;	+02: running left (holding Y)
;	+03: running right (holding Y)
;	+04: P-speed left
;	+05: P-speed right
	.MaxXSpeed
	db $DC,$F0,$DC,$F8,$D0,$FC	; supersteep left
	db $DC,$10,$DC,$1C,$D0,$28	; steep slope left
	db $E8,$12,$DC,$20,$D0,$2C	; normal slope left
	db $EC,$14,$DC,$24,$D0,$30	; gradual slope left
	db $EC,$14,$DC,$24,$D0,$30	; flat ground
	db $EC,$14,$DC,$24,$D0,$30	; gradual slope right
	db $EE,$18,$E0,$24,$D4,$30	; normal slope right
	db $F0,$24,$E4,$24,$D8,$30	; steep slope right
	db $10,$24,$08,$24,$04,$30	; supersteep right


; vanilla documentation

; D2CD: friction
;	indexed by (slope index / 2)
;	each slope type has 4 bytes (2 * 16-bit speed values)
;	first value is when moving too fast right, second value is when moving too fast left

; D309: friction on ice
;	same format as normal friction

; D345: X accel
;	indexed by (turning * 90) + (dir * 4) + (run button * 2) + slope index
;	each slope type has 8 bytes (4 * 16-bit speed values)
;	+00: walking left
;	+02: running left (holding Y)
;	+04: walking right
;	+06: running right (holding Y)

; D43D: X accel on ice
;	same format as normal accel

; D535: max X speed
;	indexed by dir + (run status index * 2) + slope index
;	run status index
;		0 if walking
;		1 if running
;		2 if running faster than 0x23
;		3 if P-speed (!P2Dashing = 0x70)
;	each slope type has 8 bytes (8 * 8-bit speed values)
;	+00: walking left
;	+01: walking right
;	+02: running left (holding Y)
;	+03: running right (holding Y)
;	+04: running left 2 (holding Y + moving faster than 0xDD)
;	+05: running right 2 (holding Y + faster than 0x23)
;	+06: P-speed left
;	+07: P-speed right

; D5BD: slope slide max speed
;	indexed by (slope index / 8)
;	holds 8-bit values

; D5C9: slope speed cap
;	indexed by (slope index / 4) + (dir * 2)
;	holds 16-bit values





namespace off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


