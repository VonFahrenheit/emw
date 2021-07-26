;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Luigi

; --Build 0.9--
;


	MAINCODE:
		PHB : PHK : PLB
		LDA #$01 : STA !P2Character
		LDA #$02 : STA !P2MaxHP

		LDA !P2Init : BNE .Main

		.Init
		PHP
		LDA.b #!VRAMbank : PHA
		REP #$30
		LDY.w #!File_Kadaal
		JSL !GetFileAddress
		JSL !GetVRAM
		PLB
		LDA #$0140*$20
		CLC : ADC !FileAddress
		STA !VRAMtable+$02,x
		CLC : ADC #$0200
		STA !VRAMtable+$09,x
		LDA !FileAddress+2
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA !CurrentPlayer
		AND #$00FF
		BEQ $03 : LDA #$0200
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



		LDA !P2Status : BEQ .Process
		CMP #$01 : BEQ .KnockedOut

		.Snap
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

		.KnockedOut
		JSL CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		BIT !P2YSpeed : BMI +
		LDA $14
		LSR #3
		AND #$01
		STA !P2Direction
	+	STZ !P2Carry
		STZ !P2Invinc
		LDA #!Lui_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_HandleUpdate


		.Process
		LDA !P2MaxHP				;\
		CMP !P2HP				; | enforce max HP
		BCS $03 : STA !P2HP			;/

		LDA !P2KickTimer
		BEQ $03 : DEC !P2KickTimer
		LDA !P2HurtTimer : BEQ +
		DEC !P2HurtTimer
		BRA ++
	+	LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		++
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




		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+


	PIPE:
		JSL CORE_PIPE : BCC CONTROLS
		JMP ANIMATION


; in SMB2:
;	- Luigi's max speed is 0x25 (average of 0x24 and 0x26)
;	- his acceleration is 0x02
;	- his frition is 0x03 (yes, it's as retarded as it sounds)
;	- his maximum fall speed is 0x39
;	- his gravity is 0x02
;	- holding B sets his gravity to 0x01
;	- his initial jump speed is 0xD6 from standstill
;	- his highest running jump speed is 0xD0
;	- his high jump speed is 0xC9



	CONTROLS:
		JSL CORE_COYOTE_TIME				; coyote time

		PEA.w PHYSICS-1					; RTS address

		LDA !P2HurtTimer : BEQ .NoHurt			;\
		LDA !P2XSpeed : BEQ +				; |
		BPL ++						; |
		INC !P2XSpeed : BRA +				; | hurt animation
	++	DEC !P2XSpeed					; |
	+	RTS						; |
		.NoHurt						;/




	BRA .NoFireStart

		LDA !P2FireTimer				;\
		ORA !P2SpinAttack				; |
		ORA !P2Climbing					; |
		BNE .NoFireStart				; |
		BIT $6DA7 : BVC .NoFireStart			; |
		LDX.b #!Ex_Amount-1				; |
	-	LDA !Ex_Num,x					; | start fireball throw
		CMP #$02+!CustomOffset : BEQ .NoFireStart	; |
		DEX : BPL -					; |
		LDA #!Lui_Hammer : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		LDA #$18 : STA !P2FireTimer			; |
		STZ !P2Sliding					; |
		.NoFireStart					;/

		LDA !P2FireTimer				;\
		CMP #$0C : BNE .NoFire				; |
		%Ex_Index_X_fast()				; |
		LDA #$02+!CustomOffset : STA !Ex_Num,x		; |
		LDY !P2Direction				; |
		LDA .FireballXSpeed,y : STA !Ex_XSpeed,x	; |
		LDA !P2XPosLo					; |
		CLC : ADC .FireballXDisp,y			; |
		STA !Ex_XLo,x					; |
		LDA !P2XPosHi					; |
		ADC .FireballXDisp+2,y				; |
		STA !Ex_XHi,x					; |
		LDY !P2HP					; | throw fireball at the correct time in the animation
		DEY						; |
		BEQ $02 : LDY #$01				; |
		LDA !P2YPosLo					; |
		CLC : ADC .FireballYDisp,y			; |
		STA !Ex_YLo,x					; |
		LDA !P2YPosHi					; |
		ADC .FireballYDisp+2,y				; |
		STA !Ex_YHi,x					; |
		STZ !Ex_Data1,x					; |
		STZ !Ex_Data2,x					; |
		STZ !Ex_Data3,x					; |
		STX !P2FireIndex				; |
		LDA #$40 : STA !P2FireLife			; |
		.NoFire						;/

		LDA !P2FireLife : BNE .FireAlive		;\
		LDX !P2FireIndex				; |
		LDA !Ex_Num,x					; |
		CMP #$02+!CustomOffset : BNE .FireAlive		; | keep track of fireball life
		LDA #$01+!SmokeOffset : STA !Ex_Num,x		; |
		LDA #$17 : STA !Ex_Data1,x			; |
		.FireAlive					;/


		LDA !P2Anim					;\
		CMP #!Lui_SpinEnd : BCC .CheckSpin		; | check for spin ending
		CMP #!Lui_SpinEnd_over : BCS .CheckSpin		; |
		CMP #!Lui_SpinEnd_over-1 : BNE .SpinEnd		; |
		.SpinEndHitbox					; |
		JSL CORE_ATTACK_Setup				; |
		REP #$20					; |
		LDA.w #.SpinHitbox : JSL CORE_ATTACK_LoadHitbox	; |
		JSL CORE_ATTACK_ActivateHitbox1			; |
		JSR Kadaal_HITBOX_GetClipping			; |
		JSL CORE_ATTACK_ActivateHitbox2			; |
		JSR Kadaal_HITBOX_GetClipping			; |
		.SpinEnd					; |
		LDA #$01 : STA !P2Invinc			; > invulnerable during spin finisher
		LDA $6DA7					; > can buffer jump from end lag of spin
		AND #$80					; |
		TSB !P2Buffer					; |
		LDA #$07 : TRB $6DA3				; |
		LDA #$80 : TSB $6DA3				; |
		LDA !P2Water					; |
		AND #$10 : BEQ $03 : JMP .WaterCode		; |
		JMP .Friction_Skid				;/
		.CheckSpin
		LDA !P2FireTimer : BNE .NotSpinning		; can't start spin during fireball animation
		LDA !P2SpinAttack : BNE .Spinning
		BIT $6DA9 : BPL .NotSpinning
		LDA #$30 : STA !P2SpinAttack
		LDA #!Lui_Spin : STA !P2Anim
		STZ !P2Hitbox1IndexMem1				;\
		STZ !P2Hitbox1IndexMem2				; | clear index mem
		STZ !P2Hitbox2IndexMem1				; |
		STZ !P2Hitbox2IndexMem2				;/
		STZ !P2AnimTimer
		STZ !P2Climbing					; drop from climb
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
		LDA !P2Water					; |
		AND #$10 : BNE .WaterCode			; |
		JMP .Drift
		.NotSpinning
		STZ !P2Hitbox1IndexMem1				;\
		STZ !P2Hitbox1IndexMem2				; | clear index mem
		STZ !P2Hitbox2IndexMem1				; |
		STZ !P2Hitbox2IndexMem2				;/



		LDA !P2Water					;\
		AND #$10 : BEQ .NoWater				; |
		.WaterCode					; |
		PLA : PLA					; > kill RTS
		STZ !P2Gravity					; |
		STZ !P2Dashing					; | while in water, replace the rest of CONTROLS and all of PHYSICS with PLUMBER_SWIM
		STZ !P2SpinUsed					; |
		JSL CORE_PLUMBER_SWIM				; |
		JMP SPRITE_INTERACTION				; |
		.NoWater					; |
		LDA #$0A : STA !P2FastSwim			;/





		LDA !P2Ducking : BEQ .Drift			;\
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
		BMI .Left					;/

	.Right	BIT !P2XSpeed : BMI .Friction_R
		CMP !P2XSpeed : BEQ .SpeedSet
		LDA !P2InAir : BNE .AirControl
		BRA .GroundControl
	.Left	BIT !P2XSpeed : BPL .Friction_L
		CMP !P2XSpeed : BEQ .SpeedSet
		LDA !P2InAir : BNE .AirControl
	.GroundControl
		LDA !P2XSpeed
		BCC .Friction_L+4
		BRA .Friction_R+4
	.AirControl
		LDA !P2XSpeed
		BCC .Friction_L+3
		BRA .Friction_R+3

	.Friction
		LDA !P2Slope : BEQ +				; > skip this check if no slope
		CMP #$FC : BEQ .SpeedDone			;\
		CMP #$FD : BEQ .SpeedDone			; | no friction on steep to supersteep slopes
		CMP #$04 : BEQ .SpeedDone			; |
		CMP #$03 : BEQ .SpeedDone			;/
		LDA !P2Sliding : BNE .SpeedDone			; > no friction when sliding on any slope
	+	LDA !P2Blocked
		AND #$04 : BNE ..Skid
		LDA !P2XSpeed : BRA .SpeedSet

		..Skid
		LDY #$00
		LDA !P2Ducking
		BEQ $01 : INY
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
		JSL CORE_SET_XSPEED
		.SpeedDone

		LDA !P2Blocked
		AND #$04 : BNE .Ground
		JMP .Air

		.Ground
		STZ !P2SpinUsed					; regain spin

		LDA !P2Slope					;\
		CLC : ADC #$04					; |
		ASL A						; |
		TAX						; |
		STZ $00						; | set up slope index
		STZ $01						; |
		CPX #$08 : BCS +				; |
		DEC $00						; |
		DEC $01						;/
	+	LDA $6DA3					;\
		AND #$07					; | end slide on walk
		CMP #$04 : BCS +				; |
		CMP #$00 : BNE .EndSlide			;/
	+	CPX #$08 : BEQ +				; > can't start slide on flat ground
		LDA !P2Sliding : BNE +				;\
		LDA $6DA3					; |
		AND #$04 : BEQ .NotSliding			; | start slide
		STA !P2Sliding					; |
		STA !P2Ducking					;/
	+	REP #$20					;\
		LDA .SlideAcc,x					; |
		CLC : ADC !P2XSpeedFraction			; |
		EOR $00						; |
		CMP .SlideSpeed,x : BPL ++			; | slide speed
		LDA .SlideAcc,x					; |
		EOR $00						; |
		CLC : ADC !P2XSpeedFraction			; |
		STA !P2XSpeedFraction				; |
		BRA ++						;/
		.EndSlide					;\
		STZ !P2Sliding					; | end slide
		STZ !P2Ducking					;/
		.NotSliding					;\
		LDA !P2Slope : BEQ .NoSlope			; |
		REP #$20					; |
		LDA .SlopeAcc,x					; |
		CLC : ADC !P2XSpeedFraction			; |
		EOR $00						; |
		CMP .SlopeSpeedDescending,x : BPL +		; |
		LDA .SlopeAcc,x					; |
		EOR $00						; |
		CLC : ADC !P2XSpeedFraction			; |
		STA !P2XSpeedFraction				; | slope speed when not sliding
	+	LDA .SlopeSpeedAscending,x : BEQ ++		; |
		LDA !P2XSpeedFraction				; |
		EOR $00						; |
		BPL ++						; |
		CMP .SlopeSpeedAscending,x : BCS ++		; |
		LDA .SlopeSpeedAscending,x			; |
		EOR $00						; |
		STA !P2XSpeedFraction				; |
	++	SEP #$20					;/
		.NoSlope

		LDA !P2Sliding : BNE +				;
	-	LDA $6DA3
		AND #$04
	+	STA !P2Ducking
		LDA !P2Sliding : BEQ .SlideDone
		LDA !P2XSpeed : BNE .SlideDone
		LDA !P2Slope : BNE .SlideDone
		STZ !P2Sliding
		BRA -
		.SlideDone


	; jump check here
		JSR .JumpCheck


		.Air
		LDA !P2Climbing : BNE ++
		LDA !P2CoyoteTime
		BMI +
		BEQ +
	++	JSR .JumpCheck
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
		CMP #!Lui_Spin_over : BCC .Return	;/

		.Jump
		LDA #$80 : TRB !P2Buffer		; clear jump from buffer when jump goes through
		STZ !P2Climbing
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BPL $03 : EOR #$FF : INC A
		CMP #$28
		BCC $02 : LDA #$28
		LSR A
		EOR #$FF : INC A
		CLC : ADC #$C0
		LDY !P2Sliding : BNE +			; crouch ignored while sliding
		LDY !P2Ducking : BEQ +			;\ reduced jump speed while crouching
		CLC : ADC #$10				;/
	+	STA !P2YSpeed				; set Y speed
		LDA !P2Sliding : BEQ +
		STZ !P2Sliding				; clear slide when jumping
		LDA #$04 : TRB $6DA3			; clear crouch when jumping out of slide
	+	LDA #$2B : STA !SPC1			; jump SFX
		LDA $6DA3				;\
		AND #$04				; | reset ducking status
		STA !P2Ducking				;/
		.Return
		RTS


		.FireballXSpeed
		db $FE,$02

		.FireballXDisp
		db $00,$08
		db $00,$00

		.FireballYDisp
		db $00,$FB				; small, big
		db $00,$FF


		.XSpeed
		db $00,$14,$EC,$00
		db $00,$20,$E0,$00
		db $00,$30,$D0,$00

		.SlideFriction
		db $01,$03

		.Direction
		db $FF,$01,$00,$FF


		; speed to add when sliding on slope
		.SlideAcc
		dw $0380,$0280,$0180,$0180
		dw $0000
		dw $0180,$0180,$0280,$0380

		; threshold for .SlideAcc to stop pushing
		.SlideSpeed
		dw $2000,$3000,$2800,$2000
		dw $0000
		dw $2000,$2800,$3000,$2000

		; speed to add when standing on slope
		.SlopeAcc
		dw $0280,$0080,$0000,$0000
		dw $0000
		dw $0000,$0000,$0080,$0280

		; threshold for .SlopeAcc to stop pushing
		.SlopeSpeedDescending
		dw $2000,$1000,$0000,$0000
		dw $0000
		dw $0000,$0000,$1000,$2000

		; max speed while ascending slope
		.SlopeSpeedAscending
		dw $F000,$E000,$0000,$0000
		dw $0000
		dw $0000,$0000,$E000,$F000


		.SpinHitbox
		dw $0008,$FFF4 : db $14,$24	; X/Y + W/H
		db $10,$D8			; speeds
		db $10				; timer
		db $04				; hitstun
		db $02,$00			; SFX
		dw $FFF4,$FFF4 : db $14,$24	; X/Y + W/H
		db $F0,$D8			; speeds
		db $10				; timer
		db $04				; hitstun
		db $02,$00			; SFX



	PHYSICS:
		LDA !P2XSpeed : BEQ +
		LDA !P2Blocked
		AND #$03 : BEQ ++
		CMP #$03 : BEQ ++
		DEC A
		ROR #2
		EOR !P2XSpeed : BMI ++
		STZ !P2XSpeed
		BRA ++
	+	LDA !P2Slope : BNE ++
		STZ !P2Sliding
		++

		LDA !P2Blocked
		AND #$04 : BEQ .Air

		.Ground
		STZ !P2KillCount
		LDA !P2Blocked
		AND #$03 : BNE ..clear			; kill dash timer if running into a wall
		LDY !P2Ducking : BNE ..dec		; decrement dash when crouching
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
		BPL $03 : EOR #$FF : INC A		; | if |speed| is greater than 32, increment dash timer
		CMP #$20				; |
		BCC $03 : INC !P2Dashing		;/
		LDA !P2Dashing				;\
		CMP #$40				; | cap dash timer at 64
		BCC $02 : LDA #$40			; |
		STA !P2Dashing				;/
		BRA .Done				; 

		.Air


		.Done



	SPRITE_INTERACTION:
		JSL CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSL CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		ORA !P2Water
		BNE +

		LDA #$01				; gravity when holding B is 1
		BIT $6DA3				;\ gravity when not holding B is 2
		BMI $02 : LDA #$02			;/
		BIT !P2YSpeed				;\ increase gravity by 1 while ascending
		BPL $01 : INC A				;/
		STA !P2Gravity				; store gravity
		CMP #$02 : BEQ +
		BIT !P2YSpeed : BMI +
		STZ !P2Ducking				; clear crouch if flutter starts
		+

		JSL CORE_UPDATE_SPEED
		LDA !P2Platform
		ORA !P2SpritePlatform
		BEQ +
		LDA #$04 : TSB !P2Blocked
		+



	; CARRY ITEM CODE
	; (this has to be run after speed update to sync sprite image)


		LDX !P2Carry : BEQ .NoCarry
		JSL CORE_PLUMBER_CARRY		
		.NoCarry



	OBJECTS:
		LDA !P2Blocked : PHA
		REP #$30
		LDA !P2HP				;\
		AND #$00FF				; |
		CMP #$0001 : BNE +			; | always use crouch clipping for small luigi
		LDA.w #ANIM_ClippingCrouch		; |
		BRA ++					;/
	+	LDA !P2Anim				;\
		AND #$00FF				; | get index to anim table
		ASL #3					; |
		TAY					;/
		LDA ANIM+$06,y				;
	++	JSL CORE_COLLISION			; pointer to clipping

		LDA !P2Climbing : BEQ +
		STZ !P2SpinAttack
		STZ !P2FireTimer
		STZ !P2SpinUsed
		LDA !P2Anim
		CMP #!Lui_SpinEnd : BCC +
		CMP #!Lui_SpinEnd_over : BCS +
		STZ !P2Anim
		+



		PLA
		EOR !P2Blocked
		AND #$04 : BEQ .NoLand

		.Land

		.NoLand


	SCREEN_BORDER:
		JSL CORE_SCREEN_BORDER


	ANIMATION:
		LDA !P2ExternalAnimTimer : BEQ .ClearExternal	;\
		DEC !P2ExternalAnimTimer			; |
		LDA !P2ExternalAnim : STA !P2Anim		; | enforce external animations
		DEC !P2AnimTimer				; |
		JMP .HandleUpdate				;/

		.ClearExternal
		STZ !P2ExternalAnim				; clear external animation when timer hits 0


	; pipe check
		LDA !P2Pipe : BEQ .NoPipe			;\
		BMI .VertPipe					; |
		.HorzPipe					; |
		JMP .Walk					; | pipe animations
		.VertPipe					; |
		LDA #!Lui_FaceFront : STA !P2Anim		; |
		JMP .HandleUpdate				; |
		.NoPipe						;/


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


		LDA !P2Anim
		CMP #!Lui_SpinEnd_over : BCS .NoSpin
		CMP #!Lui_SpinEnd : BCS -
		LDX !P2SpinAttack : BEQ .NoSpin
		CPX #$01 : BNE .Spinning
		STX !P2SpinUsed					; spin is used
		LDA #!Lui_Spin+4 : BRA ++

		.Spinning
		CMP #!Lui_Spin : BCC +
		CMP #!Lui_Spin_over : BCC -
	+	LDA #!Lui_Spin
	++	STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		.NoSpin



	; climb check
		LDA !P2Climbing : BEQ .NoClimb
		LDA !P2Anim
		CMP #!Lui_Climb : BCC +
		CMP #!Lui_Climb_over : BCC ++
	+	LDA #!Lui_Climb : STA !P2Anim
		STZ !P2AnimTimer
	++	LDA $6DA3
		AND #$0F : BNE +
		STZ !P2AnimTimer
	+	JMP .HandleUpdate
		.NoClimb


		LDA !P2Ducking : BNE .Crouch			;\
		LDA !P2PickUp : BEQ .NoCrouch			; > force crouch image timer
	.Crouch
		JSL CORE_SMOKE_AT_FEET

		LDA !P2Carry : BNE +				; > can't slide while carrying something
		LDA !P2Sliding : BEQ +				; > can only slide on slope
		;LDA !P2Blocked					; |
		;AND #$04 : BEQ +				; > can't slide in midair
		;LDA !P2XSpeed					; |
		;CLC : ADC !P2VectorX				; |
		;BPL $03 : EOR #$FF : INC A			; |
		;CMP #$10 : BCC +				; |
		LDA #!Lui_Slide : STA !P2Anim			; > use slide animation if luigi has enough speed
		JMP .HandleUpdate				; |
	+	LDA #!Lui_Crouch : STA !P2Anim			; | crouch
		JMP .HandleUpdate				; |
		.NoCrouch					;/

		LDA !P2KickTimer : BEQ .NoKick			;\
		LDA #!Lui_Kick : STA !P2Anim			; |
		STZ !P2AnimTimer				; | kick
		JMP .HandleUpdate				; |
		.NoKick						;/


		LDA !P2Carry : BEQ +				;\
		LDA !P2TurnTimer : BEQ +			; | turn if turn timer is set and item is held
		JMP .Turn					; |
		+						;/

		LDA !P2InAir : BNE .Air				;\ determine air/ground status
		JMP .Ground					;/

		.Air
		LDA !P2Water
		AND #$10 : BEQ .NoWater
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
		LDX !P2Carry : BNE +
		CMP #!Lui_SwimSlow+1 : BCC +			;\ don't cancel the swim strike
		CMP #!Lui_SwimSlow_over : BCC ++		;/
	+	CMP #!Lui_SwimFast : BCC +
		CMP #!Lui_SwimFast_over : BCC ++
	+	LDA #!Lui_SwimFast
		BRA +++

	.SlowSwim
		LDA !P2Anim
		CMP #!Lui_SwimSlow : BCC +
		CMP #!Lui_SwimSlow_over : BCC ++
	+	LDA #!Lui_SwimSlow
	+++	STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoWater


		BIT !P2YSpeed : BMI .NoFlutter			; no flutter while ascending
		BIT $6DA3 : BPL .NoFlutter			; no flutter without holding B
	.Flutter
		LDA !P2Anim					;\
		CMP #!Lui_Flutter : BCC +			; |
		CMP #!Lui_Flutter_over : BCC ++			; |
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

		.Ground
		LDA !P2XSpeed					;\
		ORA !P2VectorX					; | check for horizonal movement
		BNE .Move					;/

		LDA $6DA3					;\
		AND #$08 : BEQ .Stand				; | look up frame when up is held
		LDA #!Lui_LookUp : STA !P2Anim			; |
		JMP .HandleUpdate				;/
	.Stand	STZ !P2Anim					;\ standing frame when X speed is 0
		BRA .HandleUpdate				;/

		.Move
		STA $00						;\
		LDA $6DA3					; |
		AND #$03 : BEQ .NoTurn				; |
		CMP #$03 : BEQ .NoTurn				; | turn frame when holding against Xspeed direction
		DEC A						; |
		ROR #2						; |
		EOR $00 : BMI .Turn				;/

	.NoTurn	LDA !P2Dashing					;\ determine walk/run animation
		CMP #$40 : BEQ .Run				;/
	.Walk	LDA !P2Anim					;\
		CMP #!Lui_Walk : BCC +				; |
		CMP #!Lui_Walk_over : BCC .HandleUpdate		; | walk animation
	+	LDA #!Lui_Walk : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Run
		LDA !P2Carry : BEQ $03 : JMP .Flutter		; flutter for running with item
		LDA !P2Anim					;\
		CMP #!Lui_Run : BCC +				; |
		CMP #!Lui_Run_over : BCC .HandleUpdate		; | run animation
	+	LDA #!Lui_Run : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Turn
		JSL CORE_SMOKE_AT_FEET
		LDA #!Lui_Turn : STA !P2Anim			; turn frame
		LDA !P2Carry : BEQ .HandleUpdate		;\
		DEC A						; |
		TAX						; | set carried item coordinate
		LDA !P2XPosLo : STA $3220,x			; |
		LDA !P2XPosHi : STA $3250,x			;/




		.HandleUpdate
		LDA !P2Anim
		REP #$30
		AND #$00FF
		STA $02						; temp anim
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
		CMP #!Lui_Walk_over : BCS ..rate0
		LDA !P2XSpeed
		CLC : ADC !P2VectorX
		BPL $03 : EOR #$FF : INC A
		CMP #$13 : BCC ..rate0
		CMP #$15 : BCC ..rate1
		CMP #$20 : BCC ..rate2
	..rate3	LDA #$03 : BRA .SetUpdate
	..rate2	LDA #$02 : BRA .SetUpdate
	..rate1	LDA #$01 : BRA .SetUpdate
	..rate0	LDA #$00

		.SetUpdate
		.NoUpdate
		STA !P2AnimTimer


	.ReplaceAnim
		LDA !MultiPlayer : BEQ .ThisOne		; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ .ThisOne

		.OtherOne
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y : STA $0E
		SEP #$30
		JMP GRAPHICS

		.ThisOne
		REP #$30
		LDA ANIM+$04,y : STA $04



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


		LDY.w #!File_Luigi				;\ get address
		JSL !GetFileAddress				;/
		SEP #$10					; index 8 bit
		LDA !FileAddress+2				;\
		STA !BigRAM+$06					; |
		STA !BigRAM+$0D					; |
		STA !BigRAM+$14					; |
		STA !BigRAM+$1B					;/

		LDA ($04)					;\
		AND #$0FFC					; | get source tile bits
		ASL #3						;/
		LDY !P2Carry : BEQ .NoCarryAddress		; no carry offset if not carrying
		LDY $02						;\ these always use the normal address, even when carrying an object
		LDX CARRY_ADDRESS,y : BMI .NoCarryAddress	;/
		LDX CARRY_POSE,y				;\
		CPX #$FF : BEQ .CarryAddress			; |
		REP #$10					; |
		STX $02						; |
		TXA						; | carry pose replacement
		ASL #3						; |
		TAY						; |
		SEP #$20					; |
		JMP .ReplaceAnim				;/
		.CarryAddress					;\
		CLC : ADC #$0800				; | carrying offset
		.NoCarryAddress					;/





		LDY !P2Anim					;\ hurt animation always uses big luigi address
		CPY #!Lui_Hurt : BEQ .BigAddress		;/

		LDY !P2HP					;\
		CPY #$02 : BCS .BigAddress			; |
		STA $00						; |
		AND #$01E0					; |
		STA $02						; X tile
		LDA $00						; |
		AND #$7E00					; | recalculate address for small Luigi
		LSR #2						; |
		STA $00						; |
		ASL A						; |
		CLC : ADC $00					; |
		ORA $02						; |
		CLC : ADC #$4800				; > this is gonna have to change later to make room for more animations...
		.BigAddress					;/

		CLC : ADC !FileAddress				;\
		STA !BigRAM+$04					; |
		CLC : ADC #$0200				; | source address
		STA !BigRAM+$0B					; | (add 0x800 while carrying)
		CLC : ADC #$0200				; | (multiply by .75 and add 0x3800 for small Luigi)
		STA !BigRAM+$12					; |
		CLC : ADC #$0200				; |
		STA !BigRAM+$19					;/

		LDA.w #(!P2Tile1*$10)|$6000			;\ $6200
		STA !BigRAM+$07					;/
		LDA.w #(!P2Tile1*$10)|$6100			;\ $6300
		STA !BigRAM+$0E					;/
		LDA.w #(!P2Tile3*$10)|$6000			;\ $6240
		STA !BigRAM+$15					;/
		LDA.w #(!P2Tile3*$10)|$6100			;\ $6340
		STA !BigRAM+$1C					;/


		LDY !P2Anim
		CPY #!Lui_Hurt : BEQ .BigFormat
		LDY !P2HP
		CPY #$02 : BCS .BigFormat
		LDA !BigRAM+$12 : STA !BigRAM+$19		; 3 -> 4
		LDA !BigRAM+$0B : STA !BigRAM+$12		; 2 -> 3
		.BigFormat


		INC $04						;\
		LDA ($04)					; |
		AND #$00F0					; |
		ASL A						; | upload size
		STA !BigRAM+$02					; |
		STA !BigRAM+$09					; |
		STA !BigRAM+$10					; |
		STA !BigRAM+$17					;/

		LDA #$001C : STA !BigRAM+$00			; header


		LDA.w #!BigRAM
		JSL CORE_GENERATE_RAMCODE
		LDA !P2Anim : STA !P2Anim2


	GRAPHICS:
		LDA !P2Status : BNE .DrawTiles
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2Anim
		CMP.b #!Lui_SpinEnd : BCC +
		CMP.b #!Lui_SpinEnd_over : BCC .DrawTiles

	+	LDA !P2Invinc
		CMP #$02 : BCC .DrawTiles
		AND #$06 : BEQ OUTPUT_HURTBOX

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

	.Big	SEP #$20
		JSL CORE_LOAD_TILEMAP


	OUTPUT_HURTBOX:
		REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLB
		RTS




	; Anim format:
	; dw $TTTT : db $tt,$NN
	; dw $DDDD
	; dw $CCCC
	; TTTT is tilemap pointer.
	; tt is frame count.
	; NN is next anim.
	; DDDD is dynamo pointer.
	; CCCC is clipping pointer.



	CARRY_ADDRESS:
	db $00					; idle
	db $00,$00,$00				; walk
	db $00					; lookup
	db $00					; crouch
	db $00,$00				; jump
	db $FF					; slide
	db $FF					; face back
	db $FF					; face front
	db $FF					; kick
	db $00,$00,$00				; run
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
	db $FF					; hurt
	db $FF					; shrink
	db $FF					; dead

	CARRY_POSE:
	db $FF					; idle
	db $FF,$FF,$FF				; walk
	db $FF					; lookup
	db $FF					; crouch
	db !Lui_Walk+2,!Lui_Walk+1		; jump
	db $FF					; slide
	db $FF					; face back
	db $FF					; face front
	db $FF					; kick
	db !Lui_Walk+0,!Lui_Walk+1,!Lui_Walk+2	; run
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
	db $FF					; hurt
	db $FF					; shrink
	db $FF					; dead





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

	.SwimSlow
	dw .24x32TM : db $FF,!Lui_SwimSlow	; 12
	dw .SwimDyn00
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+2	; 13
	dw .SwimDyn00
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+3	; 14
	dw .SwimDyn01
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimSlow+0	;
	dw .SwimDyn02
	dw .ClippingStandard

	.SwimFast
	dw .24x32TM : db $08,!Lui_SwimFast+1	;
	dw .SwimFastDyn00
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimFast+2	;
	dw .SwimFastDyn01
	dw .ClippingStandard
	dw .24x32TM : db $08,!Lui_SwimFast	;
	dw .SwimFastDyn02
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $08,!Lui_Climb+1	; 17
	dw .ClimbDyn
	dw .ClippingStandard
	dw .16x32TMX : db $08,!Lui_Climb	; 18
	dw .ClimbDyn
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

	.SpinEnd
	dw .32x32TM : db $04,!Lui_SpinEnd+1	; 29
	dw .SpinDyn03
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_SpinEnd+2	; 2A
	dw .SpinDyn04
	dw .ClippingStandard
	dw .16x32TM : db $04,!Lui_SpinEnd+3	; 2B
	dw .SpinDyn05
	dw .ClippingStandard
	dw .32x32TM : db $0C,!Lui_Idle		; 2C
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
	dw .ClippingCrouch
	.Shrink
	dw .16x32TM : db $10,!Lui_Idle		; 31
	dw .ShrinkDyn
	dw .ClippingCrouch

	.Dead
	dw .16x32TM : db $FF,!Lui_Dead		; 32
	dw .DeadDyn
	dw .ClippingStandard




	.16x32TM
	dw $0008			; big Luigi
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	dw $0008			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	.16x32TMX
	dw $0008			; big Luigi
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile3
	dw $0008			; small Luigi
	db $6E,$00,$F8,!P2Tile1
	db $6E,$00,$00,!P2Tile3


	.24x32TM
	dw $0010			; big Luigi
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1
	dw $0010			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1


	.32x32TM
	dw $0010			; big Luigi
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
	db $6E,$08,$F0,!P2Tile1
	db $6E,$F8,$F0,!P2Tile2
	db $6E,$08,$00,!P2Tile3
	db $6E,$F8,$00,!P2Tile4
	dw $0010			; small Luigi
	db $6E,$08,$F8,!P2Tile1
	db $6E,$F8,$F8,!P2Tile2
	db $6E,$08,$00,!P2Tile3
	db $6E,$F8,$00,!P2Tile4

	.SpinTM00
	dw $0010			; big Luigi
	db $2E,$0A,$FF,!P2Tile8
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $EE,$F6,$F5,!P2Tile8
	dw $0010			; small Luigi
	db $2E,$0A,$03,!P2Tile8
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $EE,$F6,$F8,!P2Tile8

	.SpinTM01
	dw $0010			; big Luigi
	db $6E,$F6,$FF,!P2Tile8
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $AE,$0A,$F5,!P2Tile8
	dw $0010			; small Luigi
	db $6E,$F6,$03,!P2Tile8
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	db $AE,$0A,$F8,!P2Tile8


macro LuiDyn(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro


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
	.SwimFastDyn00	%LuiDyn(3, $100)
	.SwimFastDyn01	%LuiDyn(3, $103)
	.SwimFastDyn02	%LuiDyn(3, $106)

;	.ClimbFrontDyn	%LuiDyn(2, $0C9)
;	.ClimbFrontTDyn	%LuiDyn(3, $0CB)
;	.ClimbBackTDyn	%LuiDyn(2, $109)
;	.ClimbBackDyn	%LuiDyn(2, $10B)
;	.ClimbPunchDyn	%LuiDyn(3, $10D)

	.ClimbDyn	%LuiDyn(2, $10B)


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
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C
	; hurtbox
	dw $0001,$FFF8			; X/Y
	db $0D,$17			; W/H


	.ClippingCrouch
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $06,$06,$0A,$0A		; R/L/R/L
	db $10,$10,$00,$08		; D/D/U/C
	; hurtbox
	dw $0001,$0000			; X/Y
	db $0D,$0F			; W/H


.End
print "  Anim data: $", hex(.End-ANIM), " bytes"
print "  - sequence data: $", hex(.16x32TM-ANIM), " bytes (", dec((.16x32TM-ANIM)*100/(.End-ANIM)), "%)"
print "  - tilemap data:  $", hex(.IdleDyn-.16x32TM), " bytes (", dec((.IdleDyn-.16x32TM)*100/(.End-ANIM)), "%)"
print "  - dynamo data:   $", hex(.ClippingStandard-.IdleDyn), " bytes (", dec((.ClippingStandard-.IdleDyn)*100/(.End-ANIM)), "%)"
print "  - clipping data: $", hex(.End-.ClippingStandard), " bytes (", dec((.End-.ClippingStandard)*100/(.End-ANIM)), "%)"


namespace off





