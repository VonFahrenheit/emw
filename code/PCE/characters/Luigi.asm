;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Luigi

<<<<<<< Updated upstream
; --Build 0.6--
=======
; --Build 1.1--
>>>>>>> Stashed changes
;


	!Lui_Idle	= $00
	!Lui_Walk	= $01
	!Lui_LookUp	= $04
	!Lui_Crouch	= $05
	!Lui_Jump	= $06
	!Lui_Slide	= $08
	!Lui_FaceBack	= $09
	!Lui_FaceFront	= $0A
	!Lui_Kick	= $0B
	!Lui_Run	= $0C
	!Lui_LongJump	= $0F
	!Lui_Turn	= $10
	!Lui_Victory	= $11
	!Lui_Swim	= $12
	!Lui_Climb	= $15
	!Lui_Hammer	= $1A
	!Lui_Cutscene	= $1D
	!Lui_Balloon	= $24
	!Lui_Spin	= $25
	!Lui_Flutter	= $2D
	!Lui_Hurt	= $30
	!Lui_Shrink	= $31
	!Lui_Dead	= $32



	MAINCODE:
<<<<<<< Updated upstream
		PHB : PHK : PLB
		LDA #$01 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
=======

	LDA $16
	AND #$20 : BEQ +
	LDA !LuigiUpgrades
	EOR #$FF : STA !LuigiUpgrades
	+
>>>>>>> Stashed changes

		LDA !P2Init : BNE .Main

		.Init
<<<<<<< Updated upstream
		PHP
		LDA.b #!VRAMbank : PHA
		REP #$30
		LDY.w #!File_Kadaal
		JSL !GetFileAddress
		JSL !GetVRAM
		PLB
		LDA #$00DA*$20
		CLC : ADC !FileAddress
		STA !VRAMtable+$02,x
		CLC : ADC #$0200
		STA !VRAMtable+$09,x
		LDA !FileAddress+2
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA #$0020
		CLC : ADC.w #((!P2Tile8-$20)*$10)+$6000
		STA !VRAMtable+$05,x
		CLC : ADC #$0100
		STA !VRAMtable+$0C,x
		LDA #$0040
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		PHK : PLB
		PLP
		INC !P2Init

		.Main

=======
		INC !P2Init
		REP #$30
		LDY.w #!File_PlayerObjects : JSL GetFileAddress
		LDA.w #ANIM_LightningEffectDynamo : JSL CORE_GENERATE_RAMCODE_24bit
		REP #$30
		LDA.w #ANIM_SpinEffectDynamo : JSL CORE_GENERATE_RAMCODE_24bit

		.Main

		.Freeze
		LDA $9D : BEQ ..done
		DEC !P2AnimTimer
		JMP ANIMATION_CheckPlayer
		..done


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
		CMP #!Lui_Walk : BCC ..rate0
		CMP #!Lui_Walk_over : BCS ..rate0
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

>>>>>>> Stashed changes


		LDA !P2Status : BEQ .Process
		CMP #$02 : BEQ .SnapToP1
		CMP #$03 : BNE .KnockedOut

		.Snapped
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

		.KnockedOut
<<<<<<< Updated upstream
		JSR CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
=======
		JSL CORE_KNOCKED_OUT : BCC .Fall
>>>>>>> Stashed changes
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
<<<<<<< Updated upstream
		BIT !P2YSpeed : BMI +
		LDA $14
		LSR #3
		AND #$01
		STA !P2Direction
	+	STZ !P2Carry
		LDA #!Lui_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_HandleUpdate
		PLB
		RTS

		.SnapToP1
		REP #$20
		LDA !P2XPosLo
		CMP $94 : BCS +
		ADC #$0004
		BRA ++
	+	SBC #$0004
	++	STA !P2XPosLo
		SEC : SBC $94
		BPL $03 : EOR #$FFFF
		CMP #$0008
		BCC $03 : INC !P2Status
		SEP #$20

		.Return
		PLB
		RTS



		.Process
		LDA !P2MaxHP				;\
		CMP !P2HP				; | enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform : BEQ ++		;\
		CMP !P2SpritePlatform : BEQ +		; | platform code
	++	STA !P2PrevPlatform			; |
		+					;/


		LDA !P2Kick
		BEQ $03 : DEC !P2Kick
=======
		LDA #!Lui_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_CheckPlayer


		.Process

	; merge L into A
		LDA $17
		AND #$20
		ASL #2
		TSB $17
		LDA $18
		AND #$20
		ASL #2
		TSB $18


	; timers
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2PickUp
		BEQ $03 : DEC !P2PickUp
		LDA !P2TurnTimer
		BEQ $03 : DEC !P2TurnTimer
		LDA !P2FireTimer
		BEQ $03 : DEC !P2FireTimer
		LDA !P2KickTimer
		BEQ $03 : DEC !P2KickTimer


		.JumpCharge
		; upgrade check here
		LDA !P2Blocked					;\
		AND $15						; | charge when holding down while grounded
		AND #$04 : BEQ ..notcharging			;/
		LDA !P2WaterRun : BNE ..notcharging		; can't charge while running on water
		..charging					;\
		LDA !P2JumpCharge				; |
		CMP #$80 : BEQ ..done				; |
		BCS $02 : ADC #$03				; |
		DEC A						; | go towards 0x80 while crouching
		BPL +						; |
		BIT !P2JumpCharge : BMI +			; |
		LDX #$0A : STX !SPC4				; > full charge sfx
	+	STA !P2JumpCharge				; |
		BRA ..done					;/
		..notcharging					;\
		LDA !P2JumpCharge : BPL ..clear			; | negative: +1 until hitting 0
		INC !P2JumpCharge				; |
		BRA ..done					;/
		..clear						;\
		STZ !P2JumpCharge				; | positive: clear
		..done						;/


		.Statue
		LDA !P2Statue : BEQ ..done
		DEC !P2Statue : BNE ..done
		JSL CORE_SMOKE_PUFF
		LDA #$0C : STA !SPC1				; transform back sfx
		..done


		.SpinAttack
		LDA !P2SpinAttack : BEQ ..clear
		DEC !P2SpinAttack : BNE ..done
		..clear
		STZ !P2Cyclone
		..done

>>>>>>> Stashed changes
		LDA !P2HurtTimer : BEQ +
		DEC !P2HurtTimer
		BRA ++
	+	LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		++
<<<<<<< Updated upstream
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2PickUp
		BEQ $03 : DEC !P2PickUp
		LDA !P2TurnTimer
		BEQ $03 : DEC !P2TurnTimer
		LDA !P2SpinAttack
		BEQ $03 : DEC !P2SpinAttack
		LDA !P2FireTimer
		BEQ $03 : DEC !P2FireTimer
		LDA !P2FireLife
		BEQ $03 : DEC !P2FireLife
=======
>>>>>>> Stashed changes




<<<<<<< Updated upstream
		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+

=======
>>>>>>> Stashed changes

	PIPE:
		JSR CORE_PIPE
		BCC $03 : JMP ANIMATION_HandleUpdate


; SMB2 reference:
;	max speed		0x25 (oscillates between 0x24 and 0x26)
;	acceleration		0x02
;	friction		0x03
;	release gravity		0x02
;	hold gravity		0x01
;	max fall speed		0x39
;	standing jump speed	0xD6
;	running jump speed	0xD0
;	charge jump speed	0xC9



	CONTROLS:
<<<<<<< Updated upstream
		JSR CORE_COYOTE_TIME
		PEA.w PHYSICS-1
=======
		JSL CORE_COYOTE_TIME				; coyote time

		PEA.w PHYSICS-1					; RTS address

		.Hurt
		LDA !P2HurtTimer : BEQ ..done			;\
		LDY #$02					; |
		LDA #$00					; | hurt animation
		JSL CORE_ACCEL_X_8Bit				; |
		RTS						; |
		..done						;/
>>>>>>> Stashed changes


		LDA !P2FireTimer
		ORA !P2SpinAttack
		BNE .NoFireStart
		BIT $6DA7 : BVC .NoFireStart
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x
		CMP #$02+!CustomOffset : BEQ .NoFireStart
		DEX : BPL -
		LDA #!Lui_Hammer : STA !P2Anim
		STZ !P2AnimTimer
		LDA #$18 : STA !P2FireTimer
		.NoFireStart

		.LightningJump
		LDA !P2LightningJump : BEQ ..done
		DEC !P2LightningJump : BEQ ..end
		LDA !P2LightningCounter
		INC A
		CMP #$0C
		BCC $02 : LDA #$00
		STA !P2LightningCounter
		LSR A : BCS ..noparticle
		JSR .SpawnLightningParticle
		..noparticle
		BIT $15 : BMI ..go
		DEC !P2LightningJump : BEQ ..end
		..go
		LDA #$01 : STA !P2Invinc
		STZ !P2FlashPal
		STZ !P2XSpeed
		RTS
		..end
		LDA #$C0 : STA !P2YSpeed
		LDA #$0C
		STA !P2SpinAttack
		STA !P2Cyclone
		LDA #!Lui_SpinEnd_over-1 : STA !P2Anim
		STZ !P2AnimTimer
		REP #$20
		LDA !P2Y : PHA
		SEC : SBC #$0020
		STA !P2Y
		STZ !P2Hitbox1IndexMem1
		STZ !P2Hitbox2IndexMem1
		JSR .SpawnSparkleStorm_nodust
		PLA : STA !P2Y
		SEP #$20
		RTS
		..done



<<<<<<< Updated upstream
		LDA !P2FireTimer
		CMP #$0C : BNE .NoFire
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x : BEQ +
		DEX : BPL -
		BRA .NoFire
	+	LDA #$02+!CustomOffset : STA !Ex_Num,x
		LDY !P2Direction
		LDA .FireballXSpeed,y : STA !Ex_XSpeed,x
		LDA !P2XPosLo
		CLC : ADC .FireballXDisp,y
		STA !Ex_XLo,x
		LDA !P2XPosHi
		ADC .FireballXDisp+2,y
		STA !Ex_XHi,x
		LDY !P2HP
		DEY
		BEQ $02 : LDY #$01
		LDA !P2YPosLo
		CLC : ADC .FireballYDisp,y
		STA !Ex_YLo,x
		LDA !P2YPosHi
		ADC .FireballYDisp+2,y
		STA !Ex_YHi,x
		STZ !Ex_Data1,x
		STZ !Ex_Data2,x
		STZ !Ex_Data3,x
		STX !P2FireIndex
		LDA #$40 : STA !P2FireLife
		.NoFire


		LDA !P2FireLife : BNE .FireAlive
		LDX !P2FireIndex
		LDA !Ex_Num,x
		CMP #$02+!CustomOffset : BNE .FireAlive
		LDA #$01+!SmokeOffset : STA !Ex_Num,x
		LDA #$17 : STA !Ex_Data1,x
		.FireAlive


		LDA !P2Anim					;\
		CMP #!Lui_Spin+5 : BEQ .SpinEnd			; |
		CMP #!Lui_Spin+6 : BEQ .SpinEnd			; | check for spin endlag
		CMP #!Lui_Spin+7 : BNE .CheckSpin		; |
		.SpinEndHitbox					; |
		LDA !P2Direction : PHA
		STZ !P2Direction
		REP #$20
		LDA !CurrentPlayer
		AND #$00FF
		PHP
		LDA #$32E0
		PLP
		BEQ $03 : LDA #$35F0
		STA $0E
		PHA
		LDA !P2YPosLo
		SEC : SBC #$0014
		STA $01
		STA $08
		LDA !P2XPosLo
		SEC : SBC #$000C
		STA $07
		SEP #$20
		STA $00
		LDA #$14 : STA $02
		LDA #$24 : STA $03
		JSR Kadaal_HITBOX_GetClipping
		LDA $00
		CLC : ADC #$14
		STA $00
		BCC $02 : INC $08
		INC !P2Direction
		PLA : STA $0E
		PLA : STA $0F
		JSR Kadaal_HITBOX_GetClipping
		PLA : STA !P2Direction
		.SpinEnd					; |
		LDA #$01 : STA !P2Invinc			; > invulnerable during spin finisher
		LDA $6DA7					; > can buffer jump from end lag of spin
		AND #$80					; |
		TSB !P2Buffer					; |
		LDA #$07 : TRB $6DA3				; |
		LDA #$80 : TSB $6DA3				; |
		JMP .Friction_Skid				;/
		.CheckSpin
		LDA !P2FireTimer : BNE .NotSpinning		; can't start spin during fireball animation
		LDA !P2SpinAttack : BNE .Spinning
		BIT $6DA9 : BPL .NotSpinning
		LDA #$30 : STA !P2SpinAttack
		LDA #!Lui_Spin : STA !P2Anim
		STZ !P2IndexMem1				;\ reset index mem
		STZ !P2IndexMem2				;/
		STZ !P2AnimTimer
		.Spinning
		LDA !P2SpinAttack				;\
		CMP #$30 : BCS +				; |
		BIT $6DA9 : BPL +				; > can end spin at will
		LDA #$01 : STA !P2SpinAttack			;\ end spin
		BRA .NotSpinning				;/
	+	CMP #$08 : BCS +				;\ invincible during last 8 frames of spin (before finisher, which is also invincible)
		LDA #$01 : STA !P2Invinc			;/
	+	STZ !P2Carry					; can't carry something while spinning
		LDA !P2SpinUsed : BNE +				; can only gain height from spin once per jump
		BIT $6DA5 : BPL +
		LDA !P2YSpeed : BPL ..dec
		CMP #$F4 : BCC ..set
	..dec	SEC : SBC #$03
	..set	STA !P2YSpeed
	+	LDA #$04 : TRB $6DA3
		LDA #$80 : TSB $6DA3
		JMP .Drift
		.NotSpinning
		STZ !P2IndexMem1				;\ reset index mem
		STZ !P2IndexMem2				;/






		BIT !P2Water : BPL .Drift			;\
		LDA !P2Blocked					; | when crouching on ground, go to friction (ignore input)
		AND #$04 : BNE .Friction			;/

		.Drift
		LDA $6DA3					;\
		AND #$03					; |
		TAX						; |
		LDA !P2FireTimer : BNE .NoTurn			; > can't turn during fireball attack
		LDA .Direction,x : BMI .NoTurn			; |
		CMP !P2Direction				; | set direction when only 1 direction is held
		STA !P2Direction				; | (also set turn timer)
		BEQ .NoTurn					; |
		LDA #$08 : STA !P2TurnTimer			; |
		STZ !P2PickUp					; > clear pick up
		.NoTurn						;/

		BIT $6DA3 : BVC +				;\ increment index while running
		INX #4						;/
		LDA !P2Dashing					;\
		CMP #$40 : BNE +				; | max speed check
		INX #4						;/
	+	LDA.w .XSpeed,x					;\
		BEQ .Friction					; | determine target speed
		BPL .Right					;/

	.Left	BIT !P2XSpeed : BPL .Friction_L
		CMP !P2XSpeed : BEQ .SpeedSet
		LDA !P2Blocked
		AND #$04 : BEQ .AirControl
		BRA .GroundControl

	.Right	BIT !P2XSpeed : BMI .Friction_R
		CMP !P2XSpeed : BEQ .SpeedSet
		LDA !P2Blocked
		AND #$04 : BEQ .AirControl
	.GroundControl
		LDA !P2XSpeed
		BCC .Friction_L+4
		BRA .Friction_R+4
	.AirControl
		LDA !P2XSpeed
		BCC .Friction_L+3
		BRA .Friction_R+3

	.Friction
		LDA !P2Blocked
		AND #$04 : BNE ..Skid
		LDA !P2XSpeed : BRA .SpeedSet
=======
		LDA !P2WaterRun : BNE .Ground
		LDA !P2InAir : BNE .Air

		.Ground
		STZ !P2SpinUsed
		STZ !P2YoshiFlutter

		.Crouch
		LDA !P2WaterRun : BEQ ..nowaterrun
		LDA #$00 : BRA +
		..nowaterrun
		LDA $15
		AND #$04
	+	STA !P2Ducking : BEQ ..updateslide
		..startslide
		LDA !P2Slope : BNE ..setslide
		..updateslide
		LDA !P2Sliding : BEQ ..done
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
		..done
		BRA .SharedMoves


		.Air

		.YoshiFlutter
		; upgrade check here
		BIT !P2Water : BVS ..done
		LDA !P2Statue
		ORA !P2SpinAttack
		BNE ..done
		LDX !P2YoshiFlutter : BNE ..checkinput
		..checkspeed
		LDA !P2YSpeed : BMI ..done
		..checkinput
		CPX.b #DATA_YoshiFlutter_end-DATA_YoshiFlutter : BCS ..clear
		LDA $15
		AND #$88
		CMP #$88 : BEQ ..fluttering
		CPX #$00 : BEQ ..done
		..clear
		LDA.b #DATA_YoshiFlutter_end-DATA_YoshiFlutter : STA !P2YoshiFlutter
		BRA ..done
		..fluttering
		CPX #$00 : BNE ..nosfx
		LDA #$09 : STA !SPC1				; yoshi flutter sfx
		..nosfx
		INC !P2YoshiFlutter
		LDA DATA_YoshiFlutter,x : STA !P2YSpeed
		BPL ..done
		LDA $14
		AND #$03 : BNE ..done
		JSR .SpawnYoshiFlutterSmoke
		..done


		.WallRun
		LDA !P2WallRun : BEQ ..done
		LDA !P2YSpeed : BPL ..clear
		LDA !P2Blocked
		BIT #$08 : BNE ..clear
		AND $15
		AND #$03 : BEQ ..clear
		..main
		TAX
		BIT $16 : BPL ..done
		LDA #$E0
		CMP !P2YSpeed
		BCS $03 : STA !P2YSpeed
		LDA DATA_WallJumpSpeed-1,x : STA !P2XSpeed
		LDA #$2B : STA !SPC1				; jump SFX
		..clear
		STZ !P2WallRun
		..done



	.SharedMoves
		LDA !P2Sliding					;\ enforce crouch when sliding
		BEQ $03 : STA !P2Ducking			;/

		.Statue
		LDA !P2Statue : BNE ..main
		LDA $15
		AND #$04 : BEQ ..done
		BIT $16 : BVC ..done
		..init
		LDA #$80 : STA !P2Statue
		JSL CORE_SMOKE_PUFF
		LDA #$0F : STA !SPC1				; transform sfx
		..main
		LDA !P2Slope : STA !P2Sliding
		LDA !P2Statue
		CMP #$60 : BCC ..canexit
		LDA #$04 : TSB $15
		..canexit
		LDA $15
		AND #$04 : BEQ ..clear
		..move
		LDA !P2Statue
		CMP #$40
		BCC $02 : LDA #$01
		STA !P2Invinc
		JSL CORE_SMOKE_AT_FEET
		JMP .Friction
		..clear
		JSL CORE_SMOKE_PUFF
		LDA #$0C : STA !SPC1				; transform back sfx
		STZ !P2Statue
		STZ !P2Invinc
		..done


		.FireStart
	;	LDA !P2TouchingItem : BNE ..done
		LDA !P2FireTimer				;\
		ORA !P2SpinAttack				; |
		ORA !P2Climbing					; |
		BNE ..done					; |
		LDA $18						; |
		AND #$10 : BEQ ..done				; |
		LDX.b #!Ex_Amount-1				; |
	-	LDA !Ex_Num,x					; | start fireball throw
		CMP #!LuiFireball_Num : BEQ ..done		; |
		DEX : BPL -					; |
		LDA #!Lui_Hammer : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		LDA #$18 : STA !P2FireTimer			; |
		STZ !P2Sliding					; |
		..done						;/

		.FireThrow
		LDA !P2FireTimer				;\
		CMP #$0C : BNE ..done				; |
		%Ex_Index_X_fast()				; |
		LDA #!LuiFireball_Num : STA !Ex_Num,x		; |
		LDY !P2Direction				; |
		LDA DATA_FireballXSpeed,y : STA !Ex_XSpeed,x	; |
		LDA !P2XPosLo					; |
		CLC : ADC DATA_FireballXDisp,y			; |
		STA !Ex_XLo,x					; |
		LDA !P2XPosHi					; |
		ADC DATA_FireballXDisp+2,y			; |
		STA !Ex_XHi,x					; |
		LDY #$00					; |
		LDA !P2HP					; | throw fireball at the correct time in the animation
		CMP #$05					; |
		BCC $02 : LDY #$01				; |
		LDA !P2YPosLo					; |
		CLC : ADC DATA_FireballYDisp,y			; |
		STA !Ex_YLo,x					; |
		LDA !P2YPosHi					; |
		ADC DATA_FireballYDisp+2,y			; |
		STA !Ex_YHi,x					; |
		STZ !Ex_Data1,x					; |
		STX !P2FireIndex				; |
		JSL RegisterProjectile				; |
		..done						;/


		.Water
		BIT !P2Water : BVC ..done			;\
		..main						; |
		PLA : PLA					; > kill RTS
		STZ !P2Gravity					; |
		STZ !P2Dashing					; | while in water, replace the rest of CONTROLS and all of PHYSICS with PLUMBER_SWIM
		STZ !P2SpinUsed					; |
		JSL CORE_PLUMBER_SWIM				; |
		JMP SPRITE_INTERACTION				; |
		..done						;/

		LDA #$0A : STA !P2FastSwim			;


		.StartWallRun
		; upgrade check here
		LDA !P2WallRun : BNE ..done			; can't start wall run during wall run
		LDA $15						;\ must hold up
	;	BIT #$08 : BEQ ..done				;/
		AND !P2Blocked					;\ must hold towards a wall luigi is touching
		AND #$03 : BEQ ..done				;/
		TAX						;\
		LDA !P2XSpeed					; | check X speed thresholds
		CMP DATA_WallRunThreshold-1,x : BCC ..done	; |
		CMP DATA_WallRunThreshold+1,x : BCS ..done	;/
		CMP #$00					;\
		BPL $03 : EOR #$FF : INC A			; | X speed
		STA $00						;/
		LDA !P2InAir : BEQ ..allow			; always allow while on ground
		LDA !P2WaterRun : BNE ..allow			; always allow from water run
		..midairstart					;\
		LDA !P2YSpeed : BPL ..done			; |
		EOR #$FF : INC A				; | when starting a wall run in midair, use lesser of X and Y speeds
		CMP $00 : BCS ..allow				; |
		STA $00						;/
		..allow
		LDA $00
		LSR A : ADC $00
		BPL $02 : LDA #$7F
		EOR #$FF : INC A
		BIT !P2YSpeed : BPL ..write
		CMP !P2YSpeed : BCS ..set
		..write
		STA !P2YSpeed
		..set
		STA !P2WallRun
		STZ !P2FireTimer
		STZ !P2SpinAttack
		..done
>>>>>>> Stashed changes

		..Skid
		LDY #$00
		BIT !P2Water
		BPL $01 : INY
		LDA $14
		AND .SlideFriction,y : BNE .SpeedDone
		LDA !P2XSpeed : BEQ .SpeedSet
		CMP #$FF : BEQ ..0
		CMP #$01 : BNE ..Not0
	..0	LDA #$00 : BRA .SpeedSet

	..Not0	BPL ..L
	..R	LDA !P2XSpeed : INC #2 : BRA .SpeedSet
	..L	LDA !P2XSpeed : DEC #2

		.SpeedSet
		JSR CORE_SET_XSPEED
		.SpeedDone

<<<<<<< Updated upstream
		LDA !P2Blocked
		AND #$04 : BEQ .Air

		.Ground
		STZ !P2SpinUsed					; regain spin
		LDA #$80 : TRB !P2Water
		LDA $6DA3
		AND #$04
		BEQ $02 : LDA #$80
		TSB !P2Water

	; jump check here
		JSR .JumpCheck
=======
		.Spin
		LDA !P2Anim					;\
		CMP #!Lui_SpinEnd : BCC ..init			; | check for spin ending
		CMP #!Lui_SpinEnd_over : BCS ..init		; |
		CMP #!Lui_SpinEnd_over-2 : BCC ..end		; |
		..invinc					; |
		LDA #$01 : STA !P2Invinc			; > invulnerable during spin finisher
		..end						; |
		LDA $16						; > can buffer jump from end lag of spin
		AND #$80 : TSB !P2Buffer			; |
		LDA #$80 : TSB $15				; |
		LDA !P2InAir : BEQ ..friction			; |
		JMP .HorizontalMovement_handleinput		; |
		..friction					; |
		LDA #$07 : TRB $15				; |
		JMP .Friction					;/

		..init
		LDA !P2SpinAttack : BNE ..spinning
		LDA !P2FireTimer : BNE +
		BIT $18 : BMI ..startspin
	+	JMP ..done

		..startspin
		LDA #$04 : STA !SPC4				; spin sfx
		STZ !P2Sliding
		STZ !P2Ducking
		LDA #$10 : STA !P2SpinAttack			; 0x30 for long spin
		LDA !P2InAir : BEQ ..ground
		LDA !P2WaterRun : BNE ..ground
		..air
		INC !P2SpinUsed
		LDA !P2SpinUsed
		CMP #$01 : BNE ..ground
		LDA !P2YSpeed : BPL ..bounce
		CMP #$E0 : BCC ..nobounce
		..bounce
		LDA #$E0 : STA !P2YSpeed
		..nobounce
		JSL CORE_DOUBLE_JUMP_SMOKE
		..ground
		STZ !P2Climbing					; drop from climb
		BRA ..nocyclone					; can't start cyclone on first frame
>>>>>>> Stashed changes

		..spinning
	; upgrade check here
		CMP #$18 : BNE ..nofinisher			;\
		LDX #!Lui_SpinEnd : STX !P2Anim			; | cyclone finisher
		STZ !P2AnimTimer				; |
		..nofinisher					;/

		LDX !P2SpinUsed					;\ must be on first spin
		CPX #$02 : BCS ..nocyclone			;/
		BIT $18 : BPL ..nocyclone			; must press spin
		LDX #$04 : STX !SPC4				; spin sfx
		INC !P2Cyclone					; +1 mash input
		INC A						; +1 to timer
		LDX !P2Cyclone					;\
		CPX #$02					; |
		BCC ..firstpress				; | on +2 input, turn into cyclone
		BNE ..cyclone					; |
		ADC #$34 : STA !P2SpinAttack			;/
		..cyclone					;\
		LDA !P2YSpeed : BPL +				; |
		CMP #$F0 : BCC ..nocyclone			; | mash to rise during cyclone
	+	SEC : SBC #$08					; |
		STA !P2YSpeed					; |
		..nocyclone					;/
		JSL CORE_SMOKE_AT_FEET
		STZ !P2Carry					; can't carry something while spinning
		LDA #$04 : TRB $15				;\ not allowed to hold down, forced to hold B
		LDA #$80 : TSB $15				;/
		BRA .Jump					; go here
		..firstpress
		ADC #$03 : STA !P2SpinAttack			; extra +3 timer on first input
		..done

<<<<<<< Updated upstream
		.Air
		LDA !P2CoyoteTime
		BMI +
		BEQ +
		JSR .JumpCheck
	+	LDA #$39 : STA !P2FallSpeed		; fall speed is 0x39
		BIT !P2YSpeed : BMI .Done
		LDA $6DA3
		AND #$04 : BEQ .Done
		LDA !P2YSpeed
		CMP #$18
		BCS $02 : LDA #$18
		INC A
		STA !P2YSpeed
		LDA #$50 : STA !P2FallSpeed		; fast fall speed is 0x50

		.Done

		RTS


		.JumpCheck
		LDA $6DA3				;\
		AND #$80				; | clear jump buffer unless jump is held
		EOR #$80				; |
		TRB !P2Buffer				;/
		LDA !P2Buffer				;\
		AND #$80				; | apply jump buffer
		TSB $6DA7				;/

		BIT $6DA7 : BPL .Return			; no jump unless jump is pressed
		LDA !P2Anim				;\
		CMP #!Lui_Spin : BCC .Jump		; | can't jump during spin animation
		CMP #!Lui_Spin+8 : BCC .Return		;/
=======



>>>>>>> Stashed changes

	; main jump code
		.Jump
<<<<<<< Updated upstream
		LDA #$80 : TRB !P2Buffer		; clear jump from buffer when jump goes through
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BPL $03 : EOR #$FF : INC A
		CMP #$28
		BCC $02 : LDA #$28
		LSR A
		EOR #$FF : INC A
		CLC : ADC #$C0
		BIT !P2Water : BPL +			;\ reduced jump speed while crouching
		CLC : ADC #$10				;/
	+	STA !P2YSpeed
		LDA #$2B : STA !SPC1			; jump SFX
		.Return
		RTS


		.FireballXSpeed
		db $FE,$02
=======
		LDA $15						;\
		AND #$80					; | clear jump buffer unless jump is held
		EOR #$80 : TRB !P2Buffer			;/
		LDA !P2Buffer					;\
		AND #$80					; | apply jump buffer
		TSB $16						;/
		BIT $16 : BMI ..wanttojump			;\ no jump unless jump is pressed
		JMP .JumpDone					;/
		..wanttojump
		LDA !P2Cyclone					;\ can't jump during cyclone
		CMP #$02 : BCS .JumpDone			;/
		LDA !P2Climbing : BNE .TriggerJump		;\
		LDA !P2CoyoteTime				; |
		BMI +						; | must be on ground or have coyote time
		BNE .TriggerJump				; | or be climbing
	+	LDA !P2InAir : BNE .JumpDone			;/

		.TriggerJump
		LDA #$80 : TRB !P2Buffer			; clear jump from buffer when jump goes through
		STZ !P2Climbing
		LDA !P2JumpCharge : BPL ..normaljump
		STZ !P2JumpCharge				; reset jump charge
		; upgrade check here
		LDA $15
		AND #$08 : BEQ ..chargejump
		..lightningjump
		LDA #$10 : STA !P2LightningJump			; lightning jump lasts for 16 frames
		STZ !P2LightningCounter				; reset lightning frame counter
		JSR .SpawnSparkleStorm
		JSR .SpawnLightningParticle
		LDA #$18 : BRA +				; thunder sfx
		..chargejump
		LDA #$08					; spring sfx
	+	STA !SPC4
		LDA #$80 : BRA ..setjump
		..normaljump
		LDA #$2B : STA !SPC1				; jump SFX
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BPL $03 : EOR #$FF : INC A
		LSR #3
		CMP #$05
		BCC $02 : LDA #$05
		TAX
		LDA DATA_JumpHeight,x
		..setjump
		STA !P2YSpeed
		STZ !P2SpinAttack				; clear spin attack
		LDA !P2Sliding : BEQ +
		STZ !P2Sliding					; clear slide when jumping
		LDA #$04 : TRB $15				; clear crouch when jumping out of slide
	+	LDA $15						;\ reset crouch status
		AND #$04 : STA !P2Ducking			;/
		.JumpDone


>>>>>>> Stashed changes


	; horizontal movement
	.HorizontalMovement
		LDA #$FF : STA $04				; default: dash timer -1

; $00 = 16-bit resting speed (during .Friction), 16-bit max speed index (during .Move)
; $02 = 8-bit accel index
; $03 = scrach
; $04 = added to dash timer

<<<<<<< Updated upstream
		.XSpeed
		db $00,$14,$EC,$00
		db $00,$20,$E0,$00
		db $00,$30,$D0,$00

		.SlideFriction
		db $01,$03
=======
		LDA !P2InAir : BEQ ..ground			; check air/ground
		LDA !P2Dashing					;\
		CMP #$70 : BNE ..handleinput			; |
		..keepdash					; | keep p speed in midair if it's full
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
		LDA !P2WaterRun : BNE ..ok			; friction during water run
		LDA !P2InAir : BEQ ..ok				;\ no friction in midair
		JMP .DashTimer					;/
		..ok
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
	++	LDY !P2Sliding-1				;\
		CPY #$0100 : BCC +				; |
		LDY !P2Slope-1					; | 25% friction when sliding on flat ground
		CPY #$0100 : BCS +				; |
		LSR #2						; |
	+	TAY						;/
		LDA $00 : JMP .UpdateSpeed

		.Move
		LDA $15
		AND #$01 : STA $00				;\ $00 = dir index (*1), 16-bit
		STZ $01						;/
		ASL A : STA $02					; $02 = dir index (*2)
		LDA !P2SpinAttack : BEQ ..nospin		;\
		LDA #$02 : STA $04				; | p-speed during spin
		BRA ..pspeed					;/
		..nospin
		LDA #$00					; base index = 0x00
		LDX !P2Dashing					;\
		CPX #$70 : BCC ..checkrun			; | p-speed index = 0x04
		..pspeed					; |
		LDA #$04 : BRA ..setindex			;/
		..checkrun
		BIT $15 : BVC ..setindex			;\ running (but not p-speed) index = 0x02
		LDA #$02					;/
		..setindex
		TSB $00						; $00 = speed + dir index
		LDA !P2Slope					;\
		CLC : ADC #$04					; |
		STA $03						; | add slope * 6
		ASL A : ADC $03					; | $00 = full speed index
		ASL A : ADC $00					; |
		STA $00						;/
		LDA $15						;\
		AND #$03 : BEQ ..notturning			; |
		DEC A						; |
		EOR #$01 : STA !P2Direction			; > update direction
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
		LDA !P2InAir
		AND #$00FF : BEQ ..ground
		..air
		LDY #$0200					; air accel is always 0x0200
		..ground
		LDA DATA_MaxXSpeed-1,x
		AND #$FF00


		.UpdateSpeed
		JSL CORE_ACCEL_X_16Bit
		SEP #$30

>>>>>>> Stashed changes

		.DashTimer
		BIT $15 : BVC ..apply
		LDA !P2XSpeed
		CMP #$23 : BCC ..apply
		CMP #$DD+1 : BCS ..apply
		..inctimer
		LDY !P2Dashing
		LDX !P2Anim					;\ keep p speed in long jump pose so mario can do a turning p jump
		CPX.b #!Lui_LongJump : BEQ +			;/
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

<<<<<<< Updated upstream
		.CarryOffsetX
		db $F6,$0A
		db $FF,$00

		.CarryOffsetY
		db $04,$02

		.ItemSpeed
		db $F0,$10			; speed for dropping item with no kick
=======
		RTS



	.SpawnSparkleStorm
		PHP
		LDY #$0F*2 : BRA ..loop
		..nodust
		PHP
		LDY #$07*2
		..loop
		PHB
		JSL GetParticleIndex
		PLB
		LDA ..particletype,y : STA !41_Particle_Type,x
		LDA !P2X
		CLC : ADC ..particlex,y
		STA !41_Particle_X,x
		LDA !P2Y
		CLC : ADC ..particley,y
		STA !41_Particle_Y,x
		LDA !RNGtable,y
		AND #$00F0
		ADC ..particlexspeed,y
		STA !41_Particle_XSpeed,x
		LDA !RNGtable,y
		AND #$000F
		ASL #4
		ADC ..particleyspeed,y
		STA !41_Particle_YSpeed,x
		LDA #$0000
		STA !41_Particle_XAcc,x
		STA !41_Particle_YAcc,x
		LDA #$F65A : STA !41_Particle_Tile,x
		DEY : BPL ..loop
		PLP
		RTS

		..particlex
		dw $0000,$0000,$0008,$0008
		dw $0000,$0000,$0008,$0008
		dw $0000,$0000,$0008,$0008
		dw $0000,$0000,$0008,$0008
		..particley
		dw $0014,$0014,$0014,$0014
		dw $0014,$0014,$0014,$0014
		dw $000C,$000C,$000C,$000C
		dw $000C,$000C,$000C,$000C
		..particlexspeed
		dw $FE00,$FE20,$FE40,$FE60
		dw $00A0,$00C0,$00E0,$0100
		dw $FF20,$FF40,$FF60,$FF80
		dw $FF80,$FFA0,$FFC0,$FFE0
		..particleyspeed
		dw $FE00,$FE20,$FE40,$FE60
		dw $FE60,$FE40,$FE20,$FE00
		dw $FE80,$FEA0,$FEC0,$FEE0
		dw $FEE0,$FEC0,$FEA0,$FE80
		..particletype
		dw !prt_flash,!prt_flash,!prt_flash,!prt_flash
		dw !prt_flash,!prt_flash,!prt_flash,!prt_flash
		dw !prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8
		dw !prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8



	.SpawnLightningParticle
		PHP
		PHB
		JSL GetParticleIndex
		PLB
		SEP #$20
		LDA.b #!prt_basic : STA !41_Particle_Type,x
		LDA !P2LightningCounter
		AND #$02
		CLC : ADC.b #!P1Tile3
		STA !41_Particle_Tile,x
		LDA #$30 : STA !41_Particle_Prop,x
		LDA !P2LightningJump
		INC A : STA !41_Particle_Timer,x
		LDA #$02 : STA !41_Particle_Layer,x
		LDA #$00
		STA !41_Particle_XAcc,x
		STA !41_Particle_YAcc,x
		REP #$30
		LDA !P2XPosLo : STA !41_Particle_X,x
		LDA !P2YPosLo : STA !41_Particle_Y,x
		LDA #$0000
		STA !41_Particle_XSpeed,x
		STA !41_Particle_YSpeed,x
		LDY.w #!File_PlayerObjects : JSL GetFileAddress
		LDA !P2LightningCounter
		AND #$000E : TAY
		LDA ..dynamotable,y : JSL CORE_GENERATE_RAMCODE_24bit


		PLP
		RTS

		..dynamotable
		dw .LightningDynamo1
		dw .LightningDynamo2
		dw .LightningDynamo3
		dw .LightningDynamo4
		dw .LightningDynamo5
		dw .LightningDynamo6

		.LightningDynamo1
		db ..end-..start
		..start
		%Dyn24Bit(2, $000, !P1Tile5)
		%Dyn24Bit(2, $010, !P1Tile5+$10)
		..end
		.LightningDynamo2
		db ..end-..start
		..start
		%Dyn24Bit(2, $020, !P1Tile6)
		%Dyn24Bit(2, $030, !P1Tile6+$10)
		..end
		.LightningDynamo3
		db ..end-..start
		..start
		%Dyn24Bit(2, $002, !P1Tile5)
		%Dyn24Bit(2, $012, !P1Tile5+$10)
		..end
		.LightningDynamo4
		db ..end-..start
		..start
		%Dyn24Bit(2, $000, !P1Tile6)
		%Dyn24Bit(2, $010, !P1Tile6+$10)
		..end
		.LightningDynamo5
		db ..end-..start
		..start
		%Dyn24Bit(2, $020, !P1Tile5)
		%Dyn24Bit(2, $030, !P1Tile5+$10)
		..end
		.LightningDynamo6
		db ..end-..start
		..start
		%Dyn24Bit(2, $002, !P1Tile6)
		%Dyn24Bit(2, $012, !P1Tile6+$10)
		..end


	.SpawnYoshiFlutterSmoke
		PHP
		PHB
		JSL GetParticleIndex
		PLB
		REP #$30
		LDA !RNG
		AND #$0007
		ADC !P2X
		STA !41_Particle_X,x
		LDA !P2Y
		CLC : ADC #$0008
		STA !41_Particle_Y,x
		LDA #$0100 : STA !41_Particle_YSpeed,x
		LDA #$0000 : STA !41_Particle_XSpeed,x
		SEP #$20
		LDA.b #!prt_smoke8x8 : STA !41_Particle_Type,x
		LDA #$F8 : STA !41_Particle_YAcc,x
		LDA #$00 : STA !41_Particle_XAcc,x
		PLP
		RTS


>>>>>>> Stashed changes



	PHYSICS:
<<<<<<< Updated upstream
		LDA !P2XSpeed : BEQ +
		LDA !P2Blocked
		AND #$03 : BEQ +
		CMP #$03 : BEQ +
		DEC A
		ROR #2
		EOR !P2XSpeed : BMI +
		STZ !P2XSpeed
		+
=======
		.Gravity
		BIT !P2Water : BVS ..done			; don't update in water
		LDA !P2LightningJump : BNE ..nogravity		; no gravity during lightning jump
		LDA !P2Statue : BEQ ..nostatue			; check statue
		..statue					;\
		LDY #$50					; |
		LDA #$08					; | statue has gravity 8 and fall speed 0x50
		BRA ..set					; |
		..nostatue					;/

		LDA !P2WallRun : BEQ ..nowallrun		; check wall run
		..wallrun					;\
		LDA #$01					; |
		LDX !P2Anim					; |
		CPX #!Lui_WallRun : BCC ..set			; | during wall run, gravity is 0 at the start and 1 during the main part
		CPX #!Lui_WallRun+3 : BCS ..set			; |
		..nogravity					; |
		LDA #$00 : BRA ..set				; |
		..nowallrun					;/

		LDY #$39					; fall speed when holding B = 0x39
		LDA #$03					; base gravity when ascending: 3
		BIT !P2YSpeed					;\ base gravity when descending: 1
		BMI $02 : LDA #$01				;/
		BIT $15 : BMI ..set				;\
		INC #2						; | if not holding B, increase gravity by 2 and set fall speed to 0x46
		LDY #$46					;/
		..set
		STA !P2Gravity					; store gravity
		STY !P2FallSpeed				; store fall speed
		CMP #$01 : BNE ..done				;\
		BIT !P2YSpeed : BMI ..done			; | clear crouch if flutter starts
		STZ !P2Ducking					;/
		..done
>>>>>>> Stashed changes


<<<<<<< Updated upstream
		.Ground
		STZ !P2KillCount
		LDA !P2Blocked
		AND #$03 : BNE ..clear			; kill dash timer if running into a wall
		BIT !P2Water : BMI ..dec		; decrement dash when crouching
		BIT $6DA3 : BVC ..dec			; decrement dash if not holding Y
		LDA $6DA3				;\
		AND #$03 : BEQ ..dec			; |
		CMP #$03 : BEQ ..dec			; |
		DEC A					; |
		LSR A					; | check d-pad
		ROR A					; |
		EOR !P2XSpeed : BPL ..maintain		; |
	..clear	STZ !P2Dashing				; > clear dash when turning around on the ground
		BRA ..maintain				;/
	..dec	LDA !P2Dashing				;\ decrement
		BEQ $03 : DEC !P2Dashing		;/
		..maintain				; 
		LDA !P2XSpeed				;\
		CLC : ADC !P2VectorX			; |
		BPL $03 : EOR #$FF : INC A		; | if speed is greater than 32, increment dash timer
		CMP #$20				; |
		BCC $03 : INC !P2Dashing		;/
		LDA !P2Dashing				;\
		CMP #$40				; | cap dash timer at 64
		BCC $02 : LDA #$40			; |
		STA !P2Dashing				;/
		BRA .Done				; 

		.Air

=======
		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		LDA #$40 : STA !P2XSpeed
		LDA #$70 : STA !P2Dashing
		LDA #$C0 : STA !P2YSpeed
		..done


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

		LDA !P2InAir : BEQ .Ground

		.Air
		BRA .Done

		.Ground
		STZ !P2KillCount

		.Done



	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


<<<<<<< Updated upstream
	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA #$01				; gravity when holding B is 1
		BIT $6DA3				;\ gravity when not holding B is 2
		BMI $02 : LDA #$02			;/
		BIT !P2YSpeed				;\ increase gravity by 1 while ascending
		BPL $01 : INC A				;/
		STA !P2Gravity				; store gravity
		CMP #$02 : BEQ +
		BIT !P2YSpeed : BMI +
		LDA #$80 : TRB !P2Water			; clear crouch if flutter starts
		+


		LDA !P2Platform : BEQ .Main
		AND #$0F
		TAX
		LDA $9E,x : STA !P2YSpeed
		LDA $3260,x : STA !P2YFraction
		LDA !P2Blocked : PHA
		LDA !P2XSpeed : PHA
		LDA !P2XFraction : PHA
		BIT !P2Platform
		BVC .Horizontal

		.Vertical
		STZ !P2XSpeed
		BRA .Platform

		.Horizontal
		LDA $AE,x : STA !P2XSpeed
		LDA $3270,x : STA !P2XFraction

		.Platform
		JSR CORE_UPDATE_SPEED
		PLA : STA !P2XFraction
		PLA : STA !P2XSpeed
		PLA : TSB !P2Blocked
		STZ !P2YSpeed

		.Main
		JSR CORE_UPDATE_SPEED
		LDA !P2Platform
		ORA !P2SpritePlatform
		BEQ +
		LDA #$04 : TSB !P2Blocked
		+



	; CARRY ITEM CODE
	; (this has to be run after speed update to sync sprite image)

		LDA !P2Carry : BNE $03
	-	JMP .NoCarry
		DEC A
		TAX

		BIT $6DA3 : BVS .Carry
	.Throw	STZ !P2Carry
		STZ !P2PickUp
		LDA $6DA3					;\
		AND #$0C : BEQ -				; | kick if up/down are not held
		CMP #$0C : BEQ -				;/
		LDY !P2Direction				; Y = index to tables
		CMP #$04 : BEQ .Drop

	.KickUp	LDA #$90 : STA $9E,x				;\
		LDA !P2XSpeed					; | give item X/Y speed
		CLC : ADC !P2VectorX				; |
		STA $AE,x					;/
		LDA #$08 : STA !P2Kick				; kick pose
		LDA #$03 : STA !SPC1				; kick sound
		LDA CONTROLS_CarryOffsetX+0,y			;\
		LDY #$FC					; | contact GFX
		JSR CORE_ContactGFX				;/
		BRA +						; go to shared code

	.Drop	LDA !P2XSpeed					;\
		CLC : ADC !P2VectorX				; | give item X speed
		CLC : ADC CONTROLS_ItemSpeed,y			; |
		STA $AE,x					;/
	+	LDA #$08					;\
		STA $32E0,x					; | item can't interact with players for 8 frames
		STA $35F0,x					;/
		STZ !SpriteStasis,x				; clear stasis from sprite
		BRA .NoCarry

	.Carry	STZ $3400,x					; clear item's kill count
		LDA $3230,x					;\
		CMP #$09 : BEQ +				; | drop item if its state changes
		STZ !P2Carry					; |
		BRA .NoCarry					;/
	+	LDA !CurrentPlayer				;\
		INC A						; | set shell owner
		STA $34F0,x					;/
		LDA #$02					;\
		STA !SpriteStasis,x				; | item can't move or interact with players
		STA $32E0,x					; |
		STA $35F0,x					;/
		LDY !P2Direction				;\
		LDA !P2XPosLo					; |
		CLC : ADC.w CONTROLS_CarryOffsetX+0,y		; |
		STA $3220,x					; | set item X coordinate
		LDA !P2XPosHi					; |
		ADC.w CONTROLS_CarryOffsetX+2,y			; |
		STA $3250,x					;/
		LDY #$00					;\
		LDA !P2HP					; |
		CMP #$01 : BEQ .Low				; | get height index
		BIT !P2Water : BMI .Low				; |
		LDA !P2PickUp : BEQ .High			; |
	.Low	INY						;/
	.High	LDA !P2YPosLo					;\
		SEC : SBC.w CONTROLS_CarryOffsetY,y		; |
		STA $3210,x					; | set item Y coordinate
		LDA !P2YPosHi					; |
		SBC #$00					; |
		STA $3240,x					;/
		STZ !P2Kick					; > clear kick image
		.NoCarry
=======
	UPDATE_SPEED:
		JSL CORE_UPDATE_SPEED

		.Carry
		LDX !P2Carry : BEQ ..done
		JSL CORE_CARRY		
		..done
>>>>>>> Stashed changes

		




	OBJECTS:
		LDA !P2InAir : PHA
		REP #$30
<<<<<<< Updated upstream
		LDA !P2HP				;\
		AND #$00FF				; |
		CMP #$0001 : BNE +			; | always use crouch clipping for small luigi
		LDA.w #ANIM_ClippingCrouch		; |
		BRA ++					;/
	+	LDA !P2Anim				;\
		AND #$00FF				; | get index to anim table
		ASL #3					; |
		TAY					;/
		LDA ANIM+$06,y				;\
	++	STA $F0					; |
		CLC : ADC #$0004			; | Pointers to clipping
		STA $F2					; |
		CLC : ADC #$0004			; |
		STA $F4					;/
		SEP #$30
		JSR CORE_LAYER_INTERACTION
		PLA
		EOR !P2Blocked
		AND #$04 : BEQ .NoLand
=======
		LDA !P2HP					;\
		AND #$00FF					; |
		CMP #$0005 : BCS +				; | always use crouch clipping for small luigi
		LDA.w #ANIM_ClippingCrouch			; |
		BRA ++						;/
	+	LDA !P2Anim					;\
		AND #$00FF					; | get index to anim table
		ASL #3						; |
		TAY						;/
		LDA ANIM+$06,y					;
	++	JSL CORE_COLLISION				; pointer to clipping


		.Climbing
		LDA !P2Climbing : BEQ ..done
		STZ !P2SpinAttack
		STZ !P2FireTimer
		STZ !P2SpinUsed
		LDA !P2Anim
		CMP #!Lui_SpinEnd : BCC ..done
		CMP #!Lui_SpinEnd_over : BCS ..done
		STZ !P2Anim
		..done


		.Landing
		PLA : BEQ ..done
		CMP !P2InAir : BEQ ..done
		LDA !P2Statue : BEQ ..done
		LDA #$01 : STA !SPC1				; bonk SFX
		..done

>>>>>>> Stashed changes

		.WaterRun
		STZ !P2WaterRun
		LDA !P2Statue : BNE ..done
		LDA !P2XSpeed
		CLC : ADC #$20
		CMP #$40 : BCC ..done
		LDA !P2Water
		AND #$44
		CMP #$04 : BNE ..done
		TSB !P2Blocked
		STA !P2WaterRun
		STZ !P2Ducking					; end crouch
		LDA $14
		AND #$07 : BNE ..done
		LDY #$04
		JSL CORE_SET_SPLASH_Main
		..done



		JSR CORE_CLIMB_GROUND


	SCREEN_BORDER:
		JSR CORE_SCREEN_BORDER


	ATTACK:
		LDA !P2Anim
		CMP #!Lui_SpinEnd_over-1 : BEQ .SpinFinisher
		LDA !P2LightningJump : BNE .LightningJump
		LDA !P2Sliding : BNE .Slide

		.NoHitbox
		STZ !P2Hitbox1IndexMem1
		STZ !P2Hitbox1IndexMem2
		STZ !P2Hitbox2IndexMem1
		STZ !P2Hitbox2IndexMem2
		BRA .AttacksDone

		.SpinFinisher
		REP #$20
		LDA.w #DATA_SpinHitbox : JSL CORE_ATTACK_LoadHitbox
		BRA .AttacksDone

		.LightningJump
		REP #$20
		LDA.w #DATA_LightningJumpHitbox : JSL CORE_ATTACK_LoadHitbox
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
<<<<<<< Updated upstream
		LDA !P2ExternalAnimTimer			;\
		BEQ .ClearExternal				; |
		DEC !P2ExternalAnimTimer			; | enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
=======
		.External
		LDA !P2ExternalAnimTimer : BEQ ..clear		;\
		DEC !P2ExternalAnimTimer			; |
		LDA !P2ExternalAnim : STA !P2Anim		; | enforce external animations
>>>>>>> Stashed changes
		DEC !P2AnimTimer				; |
		JMP .CheckPlayer				;/
		..clear
		STZ !P2ExternalAnim				; clear external animation when timer hits 0

<<<<<<< Updated upstream
		LDA !P2Anim
		CMP #!Lui_Shrink : BEQ +
		LDA !P2HurtTimer : BEQ .NoHurt
		LDA !P2Anim
		CMP #!Lui_Hurt : BEQ +
		LDA #!Lui_Hurt : STA !P2Anim
		STZ !P2AnimTimer
	-
	+	JMP .HandleUpdate
		.NoHurt

		LDA !P2FireTimer : BNE -
=======

	; pipe check
		.Pipe
		LDA !P2Pipe					;\
		BEQ ..done					; |
		BMI ..vert					; |
		..horz						; | pipe animations
		JMP .Walk					; |
		..vert						; |
		LDA #!Lui_FaceFront : JMP .SetAnim		; |
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
		CMP #!Lui_Victory : BCC ..set			; |
		CMP #!Lui_Victory_over : BCS ..set		; |
		JMP .GoToDraw					; | set animation
		..set						; |
		LDA #!Lui_Victory : BRA .SetAnim		; |
		..done						;/


	; hurt check
		.Hurt
		LDA !P2HurtTimer : BEQ ..done
		LDA !P2Anim
		CMP #!Lui_Hurt : BEQ .GoToDraw
		CMP #!Lui_Hurt+1 : BEQ .GoToDraw
		LDA #!Lui_Hurt : BRA .SetAnim
		..done

	; shrink check
		.Shrink
		LDA !P2ShrinkTimer : BEQ ..done
		CMP #$10 : BCC ..set				; lock to first frame when half the time is up
		LDA !P2Anim
		CMP #!Lui_Shrink : BCC ..set
		CMP #!Lui_Shrink_over : BCC .GoToDraw
		..set
		LDA #!Lui_Shrink : BRA .SetAnim
		..done
>>>>>>> Stashed changes

	; statue check
		.Statue
		LDA !P2Statue : BEQ ..done
		LDA #!Lui_Statue : BRA .SetAnim
		..done

<<<<<<< Updated upstream
		LDA !P2Anim
		CMP #!Lui_Spin+8 : BCS .NoSpin
		CMP #!Lui_Spin+4 : BCS -
		LDX !P2SpinAttack : BEQ .NoSpin
		CPX #$01 : BNE .Spinning
		STX !P2SpinUsed					; spin is used
		LDA #!Lui_Spin+4 : BRA ++
=======
	; fire check
		LDA !P2FireTimer : BNE .GoToDraw
>>>>>>> Stashed changes

	; spin check
		.Spinning
<<<<<<< Updated upstream
		CMP #!Lui_Spin : BCC +
		CMP #!Lui_Spin+4 : BCC -
	+	LDA #!Lui_Spin
	++	STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoSpin



		BIT !P2Water : BMI .Crouch			;\
		LDA !P2PickUp : BEQ .NoCrouch			; > force crouch image timer
	.Crouch	LDA !P2Carry : BNE +				; > can't slide while carrying something
		LDA !P2Blocked					; |
		AND #$04 : BEQ +				; > can't slide in midair
		LDA !P2XSpeed					; |
		CLC : ADC !P2VectorX				; |
		BPL $03 : EOR #$FF : INC A			; |
		CMP #$10 : BCC +				; |
		LDA #!Lui_Slide : STA !P2Anim			; > use slide animation if luigi has enough speed
		JMP .HandleUpdate				; |
	+	LDA #!Lui_Crouch : STA !P2Anim			; | crouch
		JMP .HandleUpdate				; |
		.NoCrouch					;/

		LDA !P2Kick : BEQ .NoKick			;\
		LDA #!Lui_Kick : STA !P2Anim			; |
		STZ !P2AnimTimer				; | kick
		JMP .HandleUpdate				; |
		.NoKick						;/


		LDA !P2Carry : BEQ +				;\
		LDA !P2TurnTimer : BEQ +			; | turn if turn timer is set and item is held
		JMP .Turn					; |
		+						;/

		LDA !P2Blocked					;\ determine air/ground status
		AND #$04 : BNE .Ground				;/

		.Air
		BIT !P2YSpeed : BMI .NoFlutter			; no flutter while ascending
		BIT $6DA3 : BPL .NoFlutter			; no flutter without holding B
	.Flutter
		LDA !P2Anim					;\
		CMP #!Lui_Flutter : BCC +			; |
		CMP #!Lui_Flutter+3 : BCC ++			; |
	+	LDA #!Lui_Flutter : STA !P2Anim			; | flutter animation
		STZ !P2AnimTimer				; |
	++	JMP .HandleUpdate				; |
		.NoFlutter					;/

		LDA !P2Carry : BNE .CarryJump			; > carry jump check
		LDA !P2Dashing					;\
		CMP #$40 : BNE .NormalJump			; | long jump frame during running jump
		LDA #!Lui_LongJump : STA !P2Anim		; |
		JMP .HandleUpdate				;/

		.NormalJump
		LDA #!Lui_Jump					;\
		BIT !P2YSpeed : BMI $01 : INC A			; | determine rising/falling frame
		STA !P2Anim					; |
		JMP .HandleUpdate				;/

		.CarryJump
		LDA #!Lui_Walk+2 : STA !P2Anim			;\
		STZ !P2AnimTimer				; | third frame of walk animation
		JMP .HandleUpdate				;/
=======
		LDA !P2SpinAttack : BEQ ..done
		LDA !P2Cyclone
		CMP #$02 : BCS .GoToDraw
		LDA !P2Anim
		CMP #!Lui_Spin : BCC ..set
		CMP #!Lui_Spin_over : BCC .GoToDraw
		..set
		LDA #!Lui_Spin : BRA .SetAnim
		..done

	; climb check
		.Climb
		LDA !P2Climbing : BEQ .OtherMovements
		LDA !P2Anim
		CMP #!Lui_Climb : BCC ..startclimb
		CMP #!Lui_Climb_over : BCC ..climbing
		..startclimb
		LDA #!Lui_Climb : STA !P2Anim
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
		LDA #!Lui_Slide : BRA .SetAnim			; | determine whether crouch or slide anim should be used
		..crouch					; |
		LDA #!Lui_Crouch : BRA .SetAnim			; |
		..done						;/

	; kick
		.Kick
		LDA !P2KickTimer : BEQ ..done			;\
		LDA #!Lui_Kick : BRA .SetAnim			; | kick
		..done						;/


	; special animation when turning with item
		.CarryTurn
		LDA !P2Carry : BEQ ..done			;\
		LDA !P2TurnTimer : BEQ ..done			; | turn if turn timer is set and item is held
		JMP .Turn					; |
		..done						;/

	; ground/air split
		LDA !P2InAir : BNE .Air				; determine air/ground status
>>>>>>> Stashed changes

	; ground only animations
		.Ground
		LDA !P2XSpeed					;\
		ORA !P2VectorX					; | check for horizonal movement
		BNE .Move					;/

<<<<<<< Updated upstream
		LDA $6DA3					;\
		AND #$08 : BEQ .Stand				; | look up frame when up is held
		LDA #!Lui_LookUp : STA !P2Anim			; |
		JMP .HandleUpdate				;/
	.Stand	STZ !P2Anim					;\ standing frame when X speed is 0
		BRA .HandleUpdate				;/
=======
	; standing still on ground
		.Stand
		LDA $15						;\
		AND #$08 : BEQ ..idle				; | look up frame when up is held
		..lookup					; |
		LDA #!Lui_LookUp : BRA .SetAnim2		;/
		..idle						;\ otherwise use idle frame when X speed is 0
		LDA #$00					;/

	; branch assist 2
		.SetAnim2
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw2
		JMP .CheckPlayer
>>>>>>> Stashed changes

	; moving on ground
		.Move
		STA $00						;\
<<<<<<< Updated upstream
		LDA $6DA3					; |
		AND #$03 : BEQ .NoTurn				; |
		CMP #$03 : BEQ .NoTurn				; | turn frame when holding against Xspeed direction
=======
		LDA $15						; |
		AND #$03 : BEQ ..noturn				; | turn frame when holding against Xspeed direction
>>>>>>> Stashed changes
		DEC A						; |
		ROR #2						; |
		EOR $00 : BMI .Turn				;/
		..noturn
		LDA !P2Dashing					;\ determine walk/run animation
		CMP #$70 : BEQ .Run				;/

<<<<<<< Updated upstream
	.NoTurn	LDA !P2Dashing					;\ determine walk/run animation
		CMP #$40 : BEQ .Run				;/
	.Walk	LDA !P2Anim					;\
		CMP #!Lui_Walk : BCC +				; |
		CMP #!Lui_Walk+3 : BCC .HandleUpdate		; | walk animation
	+	LDA #!Lui_Walk : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/
=======
		.Walk
		LDA !P2Anim					;\
		CMP #!Lui_Walk : BCC ..set			; |
		CMP #!Lui_Walk_over : BCC .GoToDraw2		; | walk animation
		..set						; |
		LDA #!Lui_Walk : BRA .SetAnim2			;/
>>>>>>> Stashed changes

		.Run
		LDA !P2Anim					;\
<<<<<<< Updated upstream
		CMP #!Lui_Run : BCC +				; |
		CMP #!Lui_Run+3 : BCC .HandleUpdate		; | run animation
	+	LDA #!Lui_Run : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/
=======
		CMP #!Lui_Run : BCC ..set			; |
		CMP #!Lui_Run_over : BCC .GoToDraw2		; | run animation
		..set						; |
		LDA #!Lui_Run : BRA .SetAnim2			;/
>>>>>>> Stashed changes

		.Turn
		LDA #!Lui_Turn : STA !P2Anim			; turn frame
<<<<<<< Updated upstream
		LDA !P2Carry : BEQ .HandleUpdate		;\
		DEC A						; |
		TAX						; | set carried item coordinate
		LDA !P2XPosLo : STA $3220,x			; |
		LDA !P2XPosHi : STA $3250,x			;/
=======
		LDA !P2Carry : BEQ .GoToDraw2			;\
		DEC A : TAX					; | udpate carried item coordinate
		LDA !P2XPosLo : STA !SpriteXLo,x		; |
		LDA !P2XPosHi : STA !SpriteXHi,x		;/
		BRA .GoToDraw2
>>>>>>> Stashed changes

	; air only animations
		.Air
		LDA !P2SlantPipe : BEQ ..noslant
		LDA #$70 : STA !P2Dashing
		LDA.b #!Lui_LongJump : BRA .SetAnim3
		..noslant

		.LightningJump
		LDA !P2LightningJump : BEQ ..done
		LDA #!Lui_LightningJump : BRA .SetAnim3
		..done

<<<<<<< Updated upstream

		.HandleUpdate
		LDA !P2Anim
		REP #$30
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y : BNE .NoUpdate
		LDA ANIM+$03,y : STA !P2Anim
		REP #$20
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$20
		LDA !P2Anim
		CMP #!Lui_Walk : BCC ..rate0
		CMP #!Lui_Walk+3 : BCS ..rate0
=======
		.WallRun
		LDA !P2WallRun : BEQ ..done
		LDA !P2Anim
		CMP #!Lui_WallRun : BCC ..set
		CMP #!Lui_WallRun_over : BCC .GoToDraw3
		..set
		LDA #!Lui_WallRun : BRA .SetAnim3
		..done

		LDA !P2FireTimer : BNE .FastSwim_set		; midair throw fire pose
		BIT !P2Water : BVC .NoWater
		LDA !P2Carry : BNE .FastSwim
		LDA !P2FastSwim : BNE .SlowSwim

		.FastSwim
>>>>>>> Stashed changes
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
<<<<<<< Updated upstream
		CMP #$13 : BCC ..rate0
		CMP #$15 : BCC ..rate1
		CMP #$20 : BCC ..rate2
	..rate3	LDA #$03 : BRA .NoUpdate
	..rate2	LDA #$02 : BRA .NoUpdate
	..rate1	LDA #$01 : BRA .NoUpdate
	..rate0	LDA #$00

		.NoUpdate
		STA !P2AnimTimer
		LDA !MultiPlayer : BEQ .ThisOne		; animate at 60fps on single player
		LDA !CurrentPlayer : BEQ +
		LDA $14
		LSR A
		BCS .ThisOne
		BRA .OtherOne
	+	LDA $14
		LSR A : BCC .ThisOne

		.OtherOne
=======
		LSR #4
		DEC A
		BPL $02 : LDA #$00
		CLC : ADC !P2AnimTimer
		CMP #$07
		BCC $02 : LDA #$07
		STA !P2AnimTimer
		LDA !P2Anim
		LDX !P2Carry : BNE ..fast			; force fast swim when holding an item
		CMP #!Lui_SwimSlow+1 : BCC ..fast		;\ let the swim stroke finish
		CMP #!Lui_SwimSlow_over : BCC .CheckPlayer	;/
		..fast
		CMP #!Lui_SwimFast : BCC ..set
		CMP #!Lui_SwimFast_over : BCC .CheckPlayer
		..set
		LDA #!Lui_SwimFast : BRA .SetAnim3

		.SlowSwim
		LDA !P2Anim
		CMP #!Lui_SwimSlow : BCC ..set
		CMP #!Lui_SwimSlow_over : BCC .CheckPlayer
		..set
		LDA #!Lui_SwimSlow

	; branch assist 3
		.SetAnim3
		STA !P2Anim
		STZ !P2AnimTimer
		.GoToDraw3
		BRA .CheckPlayer

		.NoWater

	; jumps
		.Jump
		LDA !P2Anim					;\ long jump frame has priority
		CMP #!Lui_LongJump : BEQ .CheckPlayer		;/

		BIT $15 : BPL ..noflutter
		LDX !P2YoshiFlutter : BEQ ..checkspeed
		CPX.b #DATA_YoshiFlutter_end-DATA_YoshiFlutter-1 : BNE ..flutter
		..checkspeed
		BIT !P2YSpeed : BMI ..rise
		..flutter					;\
		CMP #!Lui_Flutter : BCC ..setflutter		; |
		CMP #!Lui_Flutter_over : BCC .CheckPlayer	; | flutter animation
		..setflutter					; |
		LDA #!Lui_Flutter : BRA .SetAnim3		;/
		..noflutter					;\
		BIT !P2YSpeed : BMI ..rise			; | fall animation
		..fall						; |
		LDX !P2WaterRun : BNE ..flutter			; > water run
		LDA #!Lui_Jump+1 : BRA .SetAnim3		;/
		..rise						;\ rise animation
		LDA #!Lui_Jump : BRA .SetAnim3			;/



	; unpack
	.CheckPlayer
		LDA !MultiPlayer : BEQ ..thisone	; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ ..thisone
		..otherone
>>>>>>> Stashed changes
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3 : TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$30
		JMP GRAPHICS
<<<<<<< Updated upstream

		.ThisOne
		REP #$30
		LDA ANIM+$04,y : STA $04
=======
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
		LDA ANIM+$04,y : STA $04			; get dynamo word
		SEP #$10
		LDY !P2Anim
		CPY #!Lui_WallRun : BCC ..nowallrun
		CPY #!Lui_WallRun_over : BCS ..nowallrun
		..wallrun
		LDA !SD_LuigiWallRun-1				;\
		AND #$FC00					; |
		CLC						; |
		LDY !P2Carry					; |
		BEQ $03 : ADC #$0600				; | wall run GFX source address
		LDY !P2HP					; |
		CPY #$04+1					; |
		BCS $03 : ADC #$0C00				; |
		STA !FileAddress				;/
		LDA !SD_LuigiWallRun				;\
		AND #$0003 : TAX				; |
		LDA.l CORE_SD_BANK,x : STA !FileAddress+2	; | wall run animation
		BRA ..24bit					; |
		..nowallrun					;/
		CPY #!Lui_Statue : BNE ..16bit			; check for statue
		..statue					;\ address of statue
		LDY.b #!File_PlayerObjects : JSL GetFileAddress	;/
		..24bit						;\
		LDA $04 : JSL CORE_GENERATE_RAMCODE_24bit	; | load 24-bit dynamo
		BRA .UpdateAnim2				;/

		..16bit
		AND #$0FFC : ASL #3				; source address (within file)
		LDY !P2Carry : BEQ .NoCarryAddress		; no carry offset if not carrying
		LDY $02						;\ these always use the normal address, even when carrying an object
		LDX CARRY_ADDRESS,y : BMI .NoCarryAddress	;/
		LDX CARRY_POSE,y				;\
		CPX #$FF : BEQ .CarryAddress			; |
		REP #$10					; |
		STX $02						; | carry pose replacement
		TXA						; |
		ASL #3 : TAY					; |
		JMP .ReplaceAnim				;/
		.CarryAddress					;\
		CLC : ADC #$0800				; | carrying offset
		.NoCarryAddress					;/

		STA $02						; $02 = address
		LDY.b #!File_Luigi : JSL GetFileAddress		; get address of file




		LDY #$00					; Y = big format
		LDA !P2ShrinkTimer				;\ shrink anim check
		AND #$0012 : BNE .BigAddress			;/
		LDX !P2HP					;\ always use big address if luigi has more than a full heart
		CPX #$05 : BCS .BigAddress			;/
		.SmallAddress					;\
		LDA $02 : STA $00				; |
		AND #$01E0					; |
		STA $02						; > x tile
		LDA $00						; |
		AND #$7E00					; | recalculate address for small luigi
		LSR #2						; | (keep x tile offset, multiply y tile offset by 0.75, add starting offset)
		STA $00						; |
		ASL A						; |
		ADC $00						; |
		ORA $02						; |
		ADC #$4800					; > starting offset of small luigi
		DEY						; > Y = small format
		STA $02						; > store offset within file
		.BigAddress					;/


		LDA $04+1 : JSL CORE_GENERATE_RAMCODE_16bit	; compile RAM code


		.UpdateAnim2
		LDA !P2Anim : STA !P2Anim2
>>>>>>> Stashed changes



;	tiles:		4 bits
;	source tile:	10 bits
;	bank:		predefined
;	dest VRAM:	5 bits
;
; -------d dddd----
; -------t ttt-----
; -sssssss sss-----
;
; format:
;   \20        \10
; 32109876 54321098 76543210
; ddddd--t tttsssss sssss---
;
; calculate dest:
;	LDA Dyn+2
;	AND #$00F8
;	ASL A
;	STA !BigRAM+5
;
; calculate source:
;	LDA Dyn+0
;	AND #$1FF8
;	ASL #2
;	STA !BigRAM+2
;
; calculate size:
;	LDA Dyn+1
;	AND #$01E0
;	STA !BigRAM+0
;
;
;
; Luigi format:
; ttttssss ssssss--
;
; calculate source:
;	LDA Dyn+0
;	AND #$0FFC
;	ASL #3
;	STA !BigRAM+2
;
; calculate size:
;	LDA Dyn+1
;	AND #$00F0
;	ASL A
;	STA !BigRAM+0


		LDY.w #!File_Luigi			;\ get address
		JSL !GetFileAddress			;/
		SEP #$10				; index 8 bit
		LDA !FileAddress+2			;\
		STA !BigRAM+$06				; |
		STA !BigRAM+$0D				; |
		STA !BigRAM+$14				; |
		STA !BigRAM+$1B				;/

		LDA ($04)				;\
		AND #$0FFC				; | get source tile bits
		ASL #3					;/

		LDY !P2Carry : BEQ .NoCarryAddress	;\
		CLC : ADC #$0800			; | carrying offset
		.NoCarryAddress				;/


		LDY !P2Anim
		CPY #!Lui_Hurt : BEQ .BigAddress
		LDY !P2HP				;\
		CPY #$02 : BCS .BigAddress		; |
		STA $00					; |
		AND #$01E0				; |
		STA $02					; X tile
		LDA $00					; |
		AND #$7E00				; | recalculate address for small Luigi
		LSR #2					; |
		STA $00					; |
		ASL A					; |
		CLC : ADC $00				; |
		ORA $02					; |
		CLC : ADC #$4800			; > this is gonna have to change later to make room for more animations...
		.BigAddress				;/

		CLC : ADC !FileAddress			;\
		STA !BigRAM+$04				; |
		CLC : ADC #$0200			; | source address
		STA !BigRAM+$0B				; | (add 0x800 while carrying)
		CLC : ADC #$0200			; | (multiply by .75 and add 0x3800 for small Luigi)
		STA !BigRAM+$12				; |
		CLC : ADC #$0200			; |
		STA !BigRAM+$19				;/

		LDA.w #(!P2Tile1*$10)|$6000		;\ $6200
		STA !BigRAM+$07				;/
		LDA.w #(!P2Tile1*$10)|$6100		;\ $6300
		STA !BigRAM+$0E				;/
		LDA.w #(!P2Tile3*$10)|$6000		;\ $6240
		STA !BigRAM+$15				;/
		LDA.w #(!P2Tile3*$10)|$6100		;\ $6340
		STA !BigRAM+$1C				;/


		LDY !P2Anim
		CPY #!Lui_Hurt : BEQ .BigFormat
		LDY !P2HP
		CPY #$02 : BCS .BigFormat
		LDA !BigRAM+$12 : STA !BigRAM+$19	; 3 -> 4
		LDA !BigRAM+$0B : STA !BigRAM+$12	; 2 -> 3
		.BigFormat


		INC $04					;\
		LDA ($04)				; |
		AND #$00F0				; |
		ASL A					; | upload size
		STA !BigRAM+$02				; |
		STA !BigRAM+$09				; |
		STA !BigRAM+$10				; |
		STA !BigRAM+$17				;/

		LDA #$001C : STA !BigRAM+$00		; header


		LDA.w #!BigRAM
		JSR CORE_GENERATE_RAMCODE
		LDA !P2Anim
		STA !P2Anim2


	GRAPHICS:
		LDA !P2Status : BNE .DrawTiles
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2Invinc : BEQ .DrawTiles
		AND #$02 : BEQ .DrawTiles
		PLB
		RTS

		.DrawTiles
		REP #$20
		LDA $0E : STA $04
		LDY !P2Anim
		CPY #!Lui_Hurt : BEQ .Big
		LDY !P2HP
		CPY #$02 : BCS .Big
		CLC : ADC ($04)				;\
		INC #2					; | small Luigi tilemap
		STA $04					;/

<<<<<<< Updated upstream
	.Big	SEP #$20
		JSR CORE_LOAD_TILEMAP
		PLB
		RTS
=======
		.Big
		SEP #$20
		JSL CORE_LOAD_TILEMAP


	; jump charge flash code
		.JumpCharge
		LDA !P2JumpCharge : BPL ..done
		LDA $14
		AND #$1F
		SEC : SBC #$10
		BPL $03 : EOR #$FF : INC A
		STA !P2FlashPal
		..done



	OUTPUT_HURTBOX:
		LDA !P2Anim : PHA
		LDA !P2HP
		CMP #$05 : BCS +
		LDA #!Lui_Crouch : STA !P2Anim
	+	REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLA : STA !P2Anim
		RTL
>>>>>>> Stashed changes




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


<<<<<<< Updated upstream
	ANIM:
	.Idle0
	dw .16x32TM : db $00,!Lui_Idle		; 00
	dw .IdleDyn
	dw .ClippingStandard

	.Walk
	dw .16x32TM : db $06,!Lui_Walk+1	; 01
	dw .IdleDyn
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Walk+2	; 02
	dw .WalkDyn00
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Walk		; 03
	dw .WalkDyn01
	dw .ClippingStandard

	.LookUp
	dw .16x32TM : db $FF,!Lui_LookUp	; 04
	dw .LookUpDyn
	dw .ClippingStandard

	.Crouch
	dw .16x32TM : db $FF,!Lui_Crouch	; 05
	dw .CrouchDyn
	dw .ClippingCrouch

	.Jump
	dw .16x32TM : db $FF,!Lui_Jump		; 06
	dw .RiseDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Jump+1	; 07
	dw .FallDyn
	dw .ClippingStandard

	.Slide
	dw .16x32TM : db $FF,!Lui_Slide		; 08
	dw .SlideDyn
	dw .ClippingCrouch

	.FaceBack
	dw .16x32TM : db $FF,!Lui_FaceBack	; 09
	dw .FaceBackDyn
	dw .ClippingStandard

	.FaceFront
	dw .16x32TM : db $FF,!Lui_FaceFront	; 0A
	dw .FaceFrontDyn
	dw .ClippingStandard

	.Kick
	dw .16x32TM : db $08,!Lui_Idle		; 0B
	dw .KickDyn
	dw .ClippingStandard

	.Run
	dw .24x32TM : db $02,!Lui_Run+1		; 0C
	dw .RunDyn00
	dw .ClippingStandard
	dw .24x32TM : db $02,!Lui_Run+2		; 0D
	dw .RunDyn01
	dw .ClippingStandard
	dw .24x32TM : db $02,!Lui_Run		; 0E
	dw .RunDyn02
	dw .ClippingStandard

	.LongJump
	dw .24x32TM : db $FF,!Lui_LongJump	; 0F
	dw .LongJumpDyn
	dw .ClippingStandard

	.Turn
	dw .16x32TM : db $FF,!Lui_Turn		; 10
	dw .TurnDyn
	dw .ClippingStandard

	.Victory
	dw .16x32TM : db $FF,!Lui_Victory	; 11
	dw .VictoryDyn
	dw .ClippingStandard

	.Swim
	dw .24x32TM : db $FF,!Lui_Swim		; 12
	dw .SwimDyn00
	dw .ClippingStandard
	dw .24x32TM : db $04,!Lui_Swim+2	; 13
	dw .SwimDyn01
	dw .ClippingStandard
	dw .24x32TM : db $04,!Lui_Swim		; 14
	dw .SwimDyn02
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $FF,!Lui_Climb		; 15
	dw .ClimbFrontDyn
	dw .ClippingStandard
	dw .24x32TM : db $FF,!Lui_Climb+1	; 16
	dw .ClimbFrontTDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Climb+2	; 17
	dw .ClimbBackTDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Climb+3	; 18
	dw .ClimbBackDyn
	dw .ClippingStandard
	dw .24x32TM : db $FF,!Lui_Climb+4	; 19
	dw .ClimbPunchDyn
	dw .ClippingStandard

	.Hammer
	dw .16x32TM : db $06,!Lui_Hammer+1	; 1A
	dw .HammerDyn00
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Hammer+2	; 1B
	dw .HammerDyn01
	dw .ClippingStandard
	dw .16x32TM : db $0C,!Lui_Idle		; 1C
	dw .HammerDyn02
	dw .ClippingStandard

	.Cutscene
	dw .16x32TM : db $FF,!Lui_Cutscene	; 1D
	dw .CutsceneDyn00
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+1	; 1E
	dw .CutsceneDyn01
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+2	; 1F
	dw .CutsceneDyn02
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+3	; 20
	dw .CutsceneDyn03
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+4	; 21
	dw .CutsceneDyn04
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+5	; 22
	dw .CutsceneDyn05
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+6	; 23
	dw .CutsceneDyn06
	dw .ClippingStandard

	.Balloon
	dw .32x32TM : db $FF,!Lui_Balloon	; 24
	dw .BalloonDyn
	dw .ClippingStandard

	.Spin
	dw .SpinTM00 : db $02,!Lui_Spin+1	; 25
	dw .SpinDyn00
	dw .ClippingStandard
	dw .32x32TM : db $02,!Lui_Spin+2	; 26
	dw .SpinDyn01
	dw .ClippingStandard
	dw .SpinTM01 : db $02,!Lui_Spin+3	; 27
	dw .SpinDyn02
	dw .ClippingStandard
	dw .Reverse32x32TM : db $02,!Lui_Spin	; 28
	dw .SpinDyn01
	dw .ClippingStandard
	dw .32x32TM : db $04,!Lui_Spin+5	; 29
	dw .SpinDyn03
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_Spin+6	; 2A
	dw .SpinDyn04
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_Spin+7	; 2B
	dw .SpinDyn05
	dw .ClippingStandard
	dw .32x32TM : db $0C,!Lui_Idle+8	; 2C
	dw .SpinDyn06
	dw .ClippingStandard

	.Flutter
	dw .16x32TM : db $02,!Lui_Flutter+1	; 2D
	dw .FlutterDyn00
	dw .ClippingStandard
	dw .16x32TM : db $02,!Lui_Flutter+2	; 2E
	dw .FlutterDyn01
	dw .ClippingStandard
	dw .16x32TM : db $02,!Lui_Flutter	; 2F
	dw .FlutterDyn02
	dw .ClippingStandard

	.Hurt
	dw .16x32TM : db $0F,!Lui_Shrink	; 30
	dw .HurtDyn
=======
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
	db $FF,$FF,$FF,$FF			; spin end
	db $00,$00,$00				; flutter
	db $FF,$FF,$FF,$FF,$FF,$FF		; wall run
	db $FF					; statue
	db $FF					; lightning jump
	db $FF,$FF				; hurt
	db $FF,$FF				; shrink
	db $FF					; dead

	; which pose to replace the pose (index) with if luigi is carrying something, 0xFF if there is no replacement
	CARRY_POSE:
	db $FF					; idle
	db $FF,$FF,$FF				; walk
	db !Lui_Walk+0,!Lui_Walk+1,!Lui_Walk+2	; run
	db $FF					; lookup
	db $FF					; crouch
	db !Lui_Walk+2,!Lui_Walk+1		; jump
	db $FF					; slide
	db $FF					; face back
	db $FF					; face front
	db $FF					; kick
	db !Lui_Walk+2				; long jump
	db $FF					; turn
	db $FF					; victory
	db $FF,$FF,$FF,$FF			; swim slow
	db $FF,$FF,$FF				; swim fast
	db $FF,$FF				; climb
	db $FF,$FF,$FF				; hammer / throw
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF		; cutscene frames
	db $FF					; balloon
	db $FF,$FF,$FF,$FF			; spin
	db $FF,$FF,$FF,$FF			; spin end
	db !Lui_Walk+0,!Lui_Walk+1,!Lui_Walk+2	; flutter
	db $FF,$FF,$FF,$FF,$FF,$FF		; wall run
	db $FF					; statue
	db $FF					; lightning jump
	db $FF,$FF				; hurt
	db $FF,$FF				; shrink
	db $FF					; dead




	ANIM:
	.Idle0
	dw .16x32TM : db $00,!Lui_Idle
	%Dyn16Bit(2, $000)
	dw .ClippingStandard

	.Walk
	dw .16x32TM : db $06,!Lui_Walk+1
	%Dyn16Bit(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Walk+2
	%Dyn16Bit(2, $002)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Walk
	%Dyn16Bit(2, $004)
	dw .ClippingStandard

	.Run
	dw .24x32TM : db $02,!Lui_Run+1
	%Dyn16Bit(3, $080)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Lui_Run+2
	%Dyn16Bit(3, $083)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Lui_Run
	%Dyn16Bit(3, $086)
	dw .ClippingStandard

	.LookUp
	dw .16x32TM : db $FF,!Lui_LookUp
	%Dyn16Bit(2, $006)
	dw .ClippingStandard

	.Crouch
	dw .16x32TM : db $FF,!Lui_Crouch
	%Dyn16Bit(2, $008)
	dw .ClippingCrouch

	.Jump
	dw .16x32TM : db $FF,!Lui_Jump
	%Dyn16Bit(2, $00A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Jump+1
	%Dyn16Bit(2, $00C)
	dw .ClippingStandard

	.Slide
	dw .16x32TM : db $FF,!Lui_Slide
	%Dyn16Bit(2, $00E)
	dw .ClippingCrouch

	.FaceBack
	dw .16x32TM : db $FF,!Lui_FaceBack
	%Dyn16Bit(2, $08E)
	dw .ClippingStandard

	.FaceFront
	dw .16x32TM : db $FF,!Lui_FaceFront
	%Dyn16Bit(2, $08C)
	dw .ClippingStandard

	.Kick
	dw .16x32TM : db $08,!Lui_Idle
	%Dyn16Bit(2, $04E)
	dw .ClippingStandard

	.LongJump
	dw .24x32TM : db $FF,!Lui_LongJump
	%Dyn16Bit(3, $089)
	dw .ClippingStandard

	.Turn
	dw .16x32TM : db $FF,!Lui_Turn
	%Dyn16Bit(2, $04C)
	dw .ClippingStandard

	.Victory
	dw .16x32TM : db $FF,!Lui_Victory
	%Dyn16Bit(2, $04A)
	dw .ClippingStandard

	.SwimSlow
	dw .24x32TM : db $FF,!Lui_SwimSlow
	%Dyn16Bit(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+2
	%Dyn16Bit(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+3
	%Dyn16Bit(3, $0C3)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+0
	%Dyn16Bit(3, $0C6)
	dw .ClippingStandard

	.SwimFast
	dw .24x32TM : db $08,!Lui_SwimFast+1
	%Dyn16Bit(3, $100)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimFast+2
	%Dyn16Bit(3, $103)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimFast
	%Dyn16Bit(3, $106)
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $08,!Lui_Climb+1
	%Dyn16Bit(2, $10B)
	dw .ClippingStandard
	dw .16x32TMX : db $08,!Lui_Climb
	%Dyn16Bit(2, $10B)
	dw .ClippingStandard

	.Hammer
	dw .16x32TM : db $06,!Lui_Hammer+1
	%Dyn16Bit(2, $140)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Lui_Hammer+2
	%Dyn16Bit(2, $142)
	dw .ClippingStandard
	dw .16x32TM : db $0C,!Lui_Idle
	%Dyn16Bit(2, $144)
	dw .ClippingStandard

	.Cutscene
	dw .16x32TM : db $FF,!Lui_Cutscene
	%Dyn16Bit(2, $146)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+1
	%Dyn16Bit(2, $148)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+2
	%Dyn16Bit(2, $14A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+3
	%Dyn16Bit(2, $14C)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+4
	%Dyn16Bit(2, $14E)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+5
	%Dyn16Bit(2, $180)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Lui_Cutscene+6
	%Dyn16Bit(2, $182)
	dw .ClippingStandard

	.Balloon
	dw .32x32TM : db $FF,!Lui_Balloon
	%Dyn16Bit(4, $184)
	dw .ClippingStandard

	.Spin
	dw .SpinTM00 : db $02,!Lui_Spin+1
	%Dyn16Bit(2, $1C0)
	dw .ClippingStandard
	dw .32x32TM : db $02,!Lui_Spin+2
	%Dyn16Bit(4, $1C2)
	dw .ClippingStandard
	dw .SpinTM01 : db $02,!Lui_Spin+3
	%Dyn16Bit(2, $1C6)
	dw .ClippingStandard
	dw .Reverse32x32TM : db $02,!Lui_Spin
	%Dyn16Bit(4, $1C2)
	dw .ClippingStandard

	.SpinEnd
	dw .32x32TM : db $04,!Lui_SpinEnd+1
	%Dyn16Bit(4, $1C8)
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_SpinEnd+2
	%Dyn16Bit(2, $1CC)
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_SpinEnd+3
	%Dyn16Bit(2, $1CE)
	dw .ClippingStandard
	dw .32x32TM : db $0C,!Lui_Idle
	%Dyn16Bit(4, $200)
	dw .ClippingStandard

	.Flutter
	dw .16x32TM : db $02,!Lui_Flutter+1
	%Dyn16Bit(2, $204)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Lui_Flutter+2
	%Dyn16Bit(2, $206)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Lui_Flutter
	%Dyn16Bit(2, $208)
	dw .ClippingStandard

	.WallRun
	dw .WallRunTM : db $04,!Lui_WallRun+1
	dw .WallRunDynamo0
	dw .ClippingStandard
	dw .WallRunTM : db $04,!Lui_WallRun+2
	dw .WallRunDynamo1
	dw .ClippingStandard
	dw .WallRunTM : db $04,!Lui_WallRun+3
	dw .WallRunDynamo2
	dw .ClippingStandard
	dw .WallRunTM : db $02,!Lui_WallRun+4
	dw .WallRunDynamo3
	dw .ClippingStandard
	dw .WallRunTM : db $02,!Lui_WallRun+5
	dw .WallRunDynamo4
	dw .ClippingStandard
	dw .WallRunTM : db $02,!Lui_WallRun+3
	dw .WallRunDynamo5
	dw .ClippingStandard

	.Statue
	dw .StatueTM : db $FF,!Lui_Statue
	dw .StatueDynamo
	dw .ClippingStandard

	.LightningJump
	dw .16x32TM : db $FF,!Lui_LightningJump
	%Dyn16Bit(2, $20E)
	dw .ClippingStandard

	.Hurt
	dw .16x32TM : db $04,!Lui_Hurt+1
	%Dyn16Bit(2, $188)
	dw .ClippingCrouch
	dw .16x32TM : db $0F,!Lui_Idle
	%Dyn16Bit(2, $18A)
>>>>>>> Stashed changes
	dw .ClippingCrouch
	.Shrink
<<<<<<< Updated upstream
	dw .16x32TM : db $10,!Lui_Idle		; 31
	dw .ShrinkDyn
	dw .ClippingCrouch

	.Dead
	dw .16x32TM : db $FF,!Lui_Dead		; 32
	dw .DeadDyn
=======
	dw .16x32TM : db $04,!Lui_Shrink+1
	%Dyn16Bit(2, $18C)
	dw .ClippingCrouch
	dw .16x32TM : db $04,!Lui_Shrink+0
	%Dyn16Bit(2, $000)
	dw .ClippingCrouch

	.Dead
	dw .16x32TM : db $FF,!Lui_Dead
	%Dyn16Bit(2, $18E)
>>>>>>> Stashed changes
	dw .ClippingStandard




	.16x32TM
	dw $0008			; big Luigi
<<<<<<< Updated upstream
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	dw $0008			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
=======
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile5
	dw $0008			; small Luigi
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile1+$10
	.16x32TMX
	dw $0008			; big Luigi
	db $60,$00,$F0,!P1Tile1
	db $60,$00,$00,!P1Tile5
	dw $0008			; small Luigi
	db $60,$00,$F8,!P1Tile1
	db $60,$00,$00,!P1Tile1+$10
>>>>>>> Stashed changes


	.24x32TM
	dw $0010			; big Luigi
<<<<<<< Updated upstream
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1
	dw $0010			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1
=======
	db $20,$00,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile1+1
	db $20,$00,$00,!P1Tile5
	db $20,$08,$00,!P1Tile5+1
	dw $0010			; small Luigi
	db $20,$00,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile1+1
	db $20,$00,$00,!P1Tile1+$10
	db $20,$08,$00,!P1Tile1+$11
>>>>>>> Stashed changes


	.32x32TM
	dw $0010			; big Luigi
<<<<<<< Updated upstream
	db $2E,$F8,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4
	dw $0010			; small Luigi
	db $2E,$F8,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4

	.Reverse32x32TM
	dw $0010			; big Luigi
	db $6E,$F8,$F0,!P2Tile1
	db $6E,$08,$F0,!P2Tile2
	db $6E,$F8,$00,!P2Tile3
	db $6E,$08,$00,!P2Tile4
	dw $0010			; small Luigi
	db $6E,$F8,$F8,!P2Tile1
	db $6E,$08,$F8,!P2Tile2
	db $6E,$F8,$00,!P2Tile3
	db $6E,$08,$00,!P2Tile4

	.SpinTM00
	dw $0010			; big Luigi
	db $2E,$0A,$FF,!P2Tile8
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $EE,$0A,$F5,!P2Tile8
	dw $0010			; small Luigi
	db $2E,$0A,$03,!P2Tile8
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $EE,$0A,$F8,!P2Tile8

	.SpinTM01
	dw $0010			; big Luigi
	db $6E,$0A,$FF,!P2Tile8
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $AE,$0A,$F5,!P2Tile8
	dw $0010			; small Luigi
	db $6E,$0A,$03,!P2Tile8
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $AE,$0A,$F8,!P2Tile8


macro LuiDyn(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro
=======
	db $20,$F8,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile2
	db $20,$F8,$00,!P1Tile5
	db $20,$08,$00,!P1Tile6
	dw $0010			; small Luigi
	db $20,$F8,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile2
	db $20,$F8,$00,!P1Tile1+$10
	db $20,$08,$00,!P1Tile2+$10

	.Reverse32x32TM
	dw $0010			; big Luigi
	db $60,$08,$F0,!P1Tile1
	db $60,$F8,$F0,!P1Tile2
	db $60,$08,$00,!P1Tile5
	db $60,$F8,$00,!P1Tile6
	dw $0010			; small Luigi
	db $60,$08,$F8,!P1Tile1
	db $60,$F8,$F8,!P1Tile2
	db $60,$08,$00,!P1Tile1+$10
	db $60,$F8,$00,!P1Tile2+$10

	.WallRunTM
	dw $0010			; big Luigi
	db $20,$00,$F0,!P1Tile1
	db $20,$10,$F0,!P1Tile2
	db $20,$00,$00,!P1Tile5
	db $20,$10,$00,!P1Tile6
	dw $0010			; small Luigi
	db $20,$00,$F0,!P1Tile1
	db $20,$10,$F0,!P1Tile2
	db $20,$00,$00,!P1Tile1+$10
	db $20,$10,$00,!P1Tile2+$10

	.StatueTM
	dw $0008			; big Luigi
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile5
	dw $0008			; small Luigi
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile5

	.SpinTM00
	dw $0010			; big Luigi
	db $20,$0A,$FF,!P1Tile8
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile5
	db $E0,$F6,$F5,!P1Tile8
	dw $0010			; small Luigi
	db $20,$0A,$03,!P1Tile8
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile1+$10
	db $E0,$F6,$F8,!P1Tile8

	.SpinTM01
	dw $0010			; big Luigi
	db $60,$F6,$FF,!P1Tile8
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile5
	db $A0,$0A,$F5,!P1Tile8
	dw $0010			; small Luigi
	db $60,$F6,$03,!P1Tile8
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile1+$10
	db $A0,$0A,$F8,!P1Tile8


	.WallRunDynamo0
	db ..end-..start
	..start
	%Dyn24Bit(4, $000, !P1Tile1)
	%Dyn24Bit(4, $004, !P1Tile1+$10)
	%Dyn24Bit(4, $008, !P1Tile5)
	%Dyn24Bit(4, $00C, !P1Tile5+$10)
	..end
	.WallRunDynamo1
	db ..end-..start
	..start
	%Dyn24Bit(4, $010, !P1Tile1)
	%Dyn24Bit(4, $014, !P1Tile1+$10)
	%Dyn24Bit(4, $018, !P1Tile5)
	%Dyn24Bit(4, $01C, !P1Tile5+$10)
	..end
	.WallRunDynamo2
	db ..end-..start
	..start
	%Dyn24Bit(4, $020, !P1Tile1)
	%Dyn24Bit(4, $024, !P1Tile1+$10)
	%Dyn24Bit(4, $028, !P1Tile5)
	%Dyn24Bit(4, $02C, !P1Tile5+$10)
	..end
	.WallRunDynamo3
	db ..end-..start
	..start
	%Dyn24Bit(4, $0C0, !P1Tile1)
	%Dyn24Bit(4, $0C4, !P1Tile1+$10)
	%Dyn24Bit(4, $0C8, !P1Tile5)
	%Dyn24Bit(4, $0CC, !P1Tile5+$10)
	..end
	.WallRunDynamo4
	db ..end-..start
	..start
	%Dyn24Bit(4, $0D0, !P1Tile1)
	%Dyn24Bit(4, $0D4, !P1Tile1+$10)
	%Dyn24Bit(4, $0D8, !P1Tile5)
	%Dyn24Bit(4, $0DC, !P1Tile5+$10)
	..end
	.WallRunDynamo5
	db ..end-..start
	..start
	%Dyn24Bit(4, $0E0, !P1Tile1)
	%Dyn24Bit(4, $0E4, !P1Tile1+$10)
	%Dyn24Bit(4, $0E8, !P1Tile5)
	%Dyn24Bit(4, $0EC, !P1Tile5+$10)
	..end

	.StatueDynamo
	db ..end-..start
	..start
	%Dyn24Bit(2, $004, !P1Tile1)
	%Dyn24Bit(2, $014, !P1Tile1+$10)
	%Dyn24Bit(2, $024, !P1Tile5)
	%Dyn24Bit(2, $034, !P1Tile5+$10)
	..end

	.LightningEffectDynamo
	db ..end-..start
	..start
	%Dyn24Bit(2, $000, !P1Tile3)
	%Dyn24Bit(2, $010, !P1Tile3+$10)
	%Dyn24Bit(2, $020, !P1Tile4)
	%Dyn24Bit(2, $030, !P1Tile4+$10)
	..end

	.SpinEffectDynamo
	db ..end-..start
	..start
	%Dyn24Bit(2, $006, !P1Tile8)
	%Dyn24Bit(2, $016, !P1Tile8+$10)
	..end




>>>>>>> Stashed changes


	.IdleDyn	%LuiDyn(2, $000)
	.WalkDyn00	%LuiDyn(2, $002)
	.WalkDyn01	%LuiDyn(2, $004)

	.LookUpDyn	%LuiDyn(2, $006)

	.CrouchDyn	%LuiDyn(2, $008)

	.RiseDyn	%LuiDyn(2, $00A)
	.FallDyn	%LuiDyn(2, $00C)

	.SlideDyn	%LuiDyn(2, $00E)

	.CarryIdleDyn	%LuiDyn(2, $040)
	.CarryWalkDyn00	%LuiDyn(2, $042)
	.CarryWalkDyn01	%LuiDyn(2, $044)
	.CarryLookUpDyn	%LuiDyn(2, $046)
	.CarryCrouchDyn	%LuiDyn(2, $048)

	.FaceBackDyn	%LuiDyn(2, $08E)

	.FaceFrontDyn	%LuiDyn(2, $08C)

	.KickDyn	%LuiDyn(2, $04E)

	.RunDyn00	%LuiDyn(3, $080)
	.RunDyn01	%LuiDyn(3, $083)
	.RunDyn02	%LuiDyn(3, $086)

	.LongJumpDyn	%LuiDyn(3, $089)

	.TurnDyn	%LuiDyn(2, $04C)

	.VictoryDyn	%LuiDyn(2, $04A)

	.SwimDyn00	%LuiDyn(3, $0C0)
	.SwimDyn01	%LuiDyn(3, $0C3)
	.SwimDyn02	%LuiDyn(3, $0C6)
	.SwimCarryDyn00	%LuiDyn(3, $100)
	.SwimCarryDyn01	%LuiDyn(3, $103)
	.SwimCarryDyn02	%LuiDyn(3, $106)

	.ClimbFrontDyn	%LuiDyn(2, $0C9)
	.ClimbFrontTDyn	%LuiDyn(3, $0CB)
	.ClimbBackTDyn	%LuiDyn(2, $109)
	.ClimbBackDyn	%LuiDyn(2, $10B)
	.ClimbPunchDyn	%LuiDyn(3, $10D)

	.HammerDyn00	%LuiDyn(2, $140)
	.HammerDyn01	%LuiDyn(2, $142)
	.HammerDyn02	%LuiDyn(2, $144)

	.CutsceneDyn00	%LuiDyn(2, $146)
	.CutsceneDyn01	%LuiDyn(2, $148)
	.CutsceneDyn02	%LuiDyn(2, $14A)
	.CutsceneDyn03	%LuiDyn(2, $14C)
	.CutsceneDyn04	%LuiDyn(2, $14E)
	.CutsceneDyn05	%LuiDyn(2, $180)
	.CutsceneDyn06	%LuiDyn(2, $182)

	.BalloonDyn	%LuiDyn(4, $184)

	.SpinDyn00	%LuiDyn(2, $1C0)
	.SpinDyn01	%LuiDyn(4, $1C2)
	.SpinDyn02	%LuiDyn(2, $1C6)
	.SpinDyn03	%LuiDyn(4, $1C8)
	.SpinDyn04	%LuiDyn(2, $1CC)
	.SpinDyn05	%LuiDyn(2, $1CE)
	.SpinDyn06	%LuiDyn(4, $200)

	.FlutterDyn00	%LuiDyn(2, $204)
	.FlutterDyn01	%LuiDyn(2, $206)
	.FlutterDyn02	%LuiDyn(2, $208)

	.HurtDyn	%LuiDyn(2, $188)
	.ShrinkDyn	%LuiDyn(2, $18A)
	.DeadDyn	%LuiDyn(2, $18C)



	.ClippingStandard
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $10,$10,$05,$05		; < Size

	.ClippingCrouch
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size



.End
print "  Anim data: $", hex(.End-ANIM), " bytes"
<<<<<<< Updated upstream
print "  - sequence data: $", hex(.16x32TM-ANIM), " bytes (", dec((.16x32TM-ANIM)*100/(.End-ANIM)), "%)"
print "  - tilemap data:  $", hex(.IdleDyn-.16x32TM), " bytes (", dec((.IdleDyn-.16x32TM)*100/(.End-ANIM)), "%)"
print "  - dynamo data:   $", hex(.ClippingStandard-.IdleDyn), " bytes (", dec((.ClippingStandard-.IdleDyn)*100/(.End-ANIM)), "%)"
print "  - clipping data: $", hex(.End-.ClippingStandard), " bytes (", dec((.End-.ClippingStandard)*100/(.End-ANIM)), "%)"
=======


	DATA:


		.JumpHeight
		db $B0,$AE,$AC,$A9,$A5,$9F		; +2, +2, +3, +4, +5


		.FireballXSpeed
		db $E0,$20

		.FireballXDisp
		db $00,$08
		db $00,$00

		.FireballYDisp
		db $00,$FB				; small, big
		db $00,$FF


		.SpinHitbox
		dw $0008,$FFF4 : db $14,$24	; X/Y + W/H
		db $10,$D8			; speeds
		db $20				; timer
		db $04				; hitstun
		db $02,$00			; SFX
		dw $FFF4,$FFF4 : db $14,$24	; X/Y + W/H
		db $F0,$D8			; speeds
		db $20				; timer
		db $04				; hitstun
		db $02,$00			; SFX

		.LightningJumpHitbox
		dw $0008,$FFF4 : db $08,$24	; X/Y + W/H
		db $08,$A0			; speeds
		db $20				; timer
		db $04				; hitstun
		db $02,$00			; SFX
		dw $0000,$FFF4 : db $08,$24	; X/Y + W/H
		db $F8,$A0			; speeds
		db $20				; timer
		db $04				; hitstun
		db $02,$00			; SFX

		.SlideHitbox
		dw $0008,$0008 : db $08,$0C	; X/Y + W/H
		db $10,$C8			; speeds
		db $20				; timer
		db $04				; hitstun
		db $02,$00			; SFX


		.YoshiFlutter
		db $08
		db $07,$06,$05,$04,$03,$02,$01,$00
		db $FF,$FE,$FD,$FC,$FB,$FA,$F9,$F8
		db $F7,$F6,$F5,$F4,$F3,$F2,$F1,$F0
		db $EF,$EE,$ED,$EC,$EB,$EA,$E9,$E8
		db $E7,$E6,$E5,$E4,$E3,$E2,$E1,$E0
		..end




		.WallRunThreshold
		db $20,$80			; minimum right, minimum left
		db $7F,$E0			; maximum right, maximum left

		.WallJumpSpeed
		db $E0,$20

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
	dw $00C0,$00C0		; gradual slope left
	dw $00C0,$00C0		; flat ground
	dw $00C0,$00C0		; gradual slope right
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
	dw $0200,$0200,$0100,$0100	; steep slope left
	dw $01C0,$01C0,$0140,$0140	; normal slope left
	dw $0180,$0180,$0180,$0180	; gradual slope left
	dw $0180,$0180,$0180,$0180	; flat ground
	dw $0180,$0180,$0180,$0180	; gradual slope right
	dw $0140,$0140,$01C0,$01C0	; normal slope right
	dw $0100,$0100,$0200,$0200	; steep slope right
	dw $0300,$0300,$0400,$0400	; supersteep right
	..turning
	dw $0200,$0400,$0200,$0400	; supersteep left, turning
	dw $0180,$0280,$0080,$0180	; steep slope left, turning
	dw $0140,$0240,$00C0,$01C0	; normal slope left, turning
	dw $0100,$0200,$0100,$0200	; gradual slope left, turning
	dw $0100,$0200,$0100,$0200	; flat ground, turning
	dw $0100,$0200,$0100,$0200	; gradual slope right, turning
	dw $00C0,$01C0,$0140,$0240	; normal slope right, turning
	db $0080,$0180,$0180,$0280	; steep slope right, turning
	dw $0200,$0400,$0200,$0400	; supersteep right, turning

	..ice
	dw $0400,$0400,$0200,$0300	; supersteep left
	dw $0300,$0300,$0080,$0080	; steep slope left
	dw $0200,$0200,$00C0,$0100	; normal slope left
	dw $0050,$0130,$0050,$0130	; gradual slope left
	dw $0050,$0130,$0050,$0130	; flat ground
	dw $0050,$0130,$0050,$0130	; gradual slope right
	dw $00C0,$0100,$0200,$0200	; normal slope right
	dw $0080,$0080,$0300,$0300	; steep slope right
	dw $0200,$0300,$0400,$0400	; supersteep right
	..iceturning
	dw $0300,$0300,$0300,$0300	; supersteep left, turning
	dw $0180,$0280,$0080,$0180	; steep slope left, turning
	dw $0180,$0240,$0050,$01C0	; normal slope left, turning
	dw $0050,$01B0,$0050,$01B0	; gradual slope left, turning
	dw $0050,$01B0,$0050,$01B0	; flat ground, turning
	dw $0050,$01B0,$0050,$01B0	; gradual slope right, turning
	dw $0060,$01C0,$0180,$0240	; normal slope right, turning
	db $0080,$0180,$0180,$0280	; steep slope right, turning
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
	db $DC,$10,$DC,$18,$D4,$28	; steep slope left
	db $E8,$12,$DC,$20,$D4,$28	; normal slope left
	db $EC,$14,$DC,$24,$D4,$2C	; gradual slope left
	db $EC,$14,$DC,$24,$D4,$2C	; flat ground
	db $EC,$14,$DC,$24,$D4,$2C	; gradual slope right
	db $EE,$18,$E0,$24,$D8,$2C	; normal slope right
	db $F0,$24,$E8,$24,$D8,$2C	; steep slope right
	db $10,$24,$08,$24,$04,$30	; supersteep right



>>>>>>> Stashed changes


namespace off





