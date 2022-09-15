;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Mario


;=================;
;MARIO ADJUSTMENTS;
;=================;

; Look at $00E45D for actual OAM access
;
; 8x8 tile is loaded from $00DFDA ("Mario8x8Tiles" in all.log) indexed by $06
; $06 is loaded from $00DF1A ("TileExpansion?" in all.log)
;
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
; -- Mario SA-1 repair --

	org $00C593
	RTS : RTS	; patch out mario code
	;	LDA !MarioAnim : JSL $0086DF
	;	dw $CC68			; 00, normal
	;	dw $D129			; 01, power down
	;	dw $D147			; 02, mushroom up
	;	dw $D15F			; 03, cape up
	;	dw $D16F			; 04, flower up
	;	dw $D197			; 05, horizontal pipe + door
	;	dw $D203			; 06, vertical pipe
	;	dw $D287			; 07, cannon pipe
	;	dw $C7FD			; 08, yoshi wings
	;	dw $D0B6			; 09, death
	;	dw $C870			; 0A, enter castle aniimation
	;	dw $C5B5			; 0B, freeze
	;	dw $C6E7			; 0C, destroy castle animation
	;	dw $C592			; 0D, freeze
	warnpc $00C5B5



; -- Mario upgrades --


	; cap jump height index
	org $00D637
	;	JSL Mario_JumpHeight		; org: LSR #2 : AND #$FE

	; prevent flight
	org $00D674
	;	BRA $05				;\
	;	NOP #2				; | org: BNE $05 : LDA #$50 : STA $749F
	;	STZ $749F			;/

	; uncap speed boost
	org $00D742
	;	JML Mario_SpeedBoost		;\ org: LDA.b !MarioXSpeed : SEC : SBC $D535,y
	;	NOP #2				;/


	; ability to float
	org $00D8E9
	;	JML Mario_Cape1			; org: CMP #$02 : BNE $3B ($00D928)

	; draw cape
	org $00E3FD
	;	JML Mario_Cape2			; org: CMP #$02 : BNE $57 (careful with repointing! target gone!)


	; first 2 bytes for big Mario, then 2 for small Mario, last 2 are unused
	org $00FE96
	;	db $00,$08,$00,$08,$FF,$FF	; X lo
	org $00FE9C
	;	db $00,$00,$00,$00,$FF,$FF	; X hi
	org $00FEA2
	;	db $08,$08,$10,$10,$FF,$FF	; Y

	org $00FED1
	;	LDA !MarioPowerUp
	;	BNE $02 : INY #2
	;	BRA 6
	;	NOP #6
	warnpc $00FEDF




; -- Misc Mario edits --
	org $00CD33				; patch out FAIL init code
		BRA $01 : NOP			; org: JSR $E92B (mario collision)

	org $00CFEE
		LDA #$02			;\ org: LDY $19 : LDA $DC78,y (number of walking frames, lock to 3 in all forms)
		BRA $01 : NOP			;/


	org $00D748
		BEQ +				; org: BEQ $21 ($00D76B), don't apply friction when mario is at target speed
	org $00D7A4
		+

	org $00DC7C					; frame count table for mario's walk/run, indexed by abs(Xspeed) / 8
		db $0A,$08,$06,$04,$03,$02,$02,$02	; replace last two bytes (originally $01) with $02 to work with 30FPS mode
		db $0A,$08,$06,$04,$03,$02,$02,$02	; same here

	org $00CD36
		BRA $01 : NOP			; patch out JSR to $00F595 (mario screen border interaction)


	org $00DFDA
		db $00,$02,$FF,$FF,$00,$02,$18,$FF
		db $00,$02,$1A,$1B,$00,$02,$19,$FF
		db $00,$02,$0E,$0F,$00,$02,$1E,$1F
		db $00,$02,$0A,$0B,$00,$02,$1C,$1D
		db $00,$02,$0C,$0D,$00,$02,$06,$FF
		db $00,$02,$02,$FF,$04,$07,$FF,$FF
		db $FF,$FF
	warnpc $00E00C


	org $00A269
		BRA +				; Org: LDA $6DD5 : BEQ $02 : BPL $19
		NOP #3
	org $00A270
		+
	org $00A281
		NOP #3				; Org: INC $7DE9

	org $00A333
	;	LDA #$0000 : STA $2116
	org $00A34D
	;	LDA !MarioGFX1			; > Org: LDA #$6000
	org $00A368
	;	NOP : CPX #$06
	org $00A36D
	;	LDA !MarioGFX2			; > Org: LDA #$6100
	org $00A388
	;	NOP : CPX #$06

	org $00CDFC				; Disable L/R scroll
	;	BRA $4B				; Org: BNE $4B

	org $00D093				; Disable automatic spin jump fireball
	;	RTS				;\ Org: BEQ $18
	;	NOP				;/


	org $00E98F
		BEQ $10				; disable side exit for Mario (Source: BEQ $10)

; --Remap Mario tiles--


	; remove mario's vanilla OAM code
	org $00953F
		BRA $02 : NOP #2
	org $009860
		BRA $02 : NOP #2
	org $00A2D8
		BRA $02 : NOP #2
	org $01C9E3
		BRA $02 : NOP #2
	org $02D732
		BRA $02 : NOP #2
	org $02D746
		BRA $02 : NOP #2
	org $0485CF
		BRA $02 : NOP #2
	org $0CA7B4
		BRA $02 : NOP #2
	org $00E2BD
		RTL
	MarioCapeY:
	db $00					; standing still
	db $03,$03,$03,$03,$03,$03		; walking/running
	db $08,$08,$08,$08			; falling
	warnpc $00E45D
pullpc



	MAINCODE:
		STZ !P2Character
		LDA #$08					;\
		CLC : ADC !PlayerBonusHP			; | max HP
		STA !P2MaxHP					;/

		LDA !P2Status : BEQ .Process
		CMP #$01 : BEQ .KnockedOut

		.Snap
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		RTL

		.KnockedOut
		JSL CORE_KNOCKED_OUT
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		RTL

		.Fall
		BIT !P2YSpeed : BMI +
		LDA $14
		LSR #3
		AND #$01
		STA !P2Direction
	+	STZ !P2Carry
		STZ !P2Invinc
		LDA #!Mar_Dead : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_HandleUpdate

		.Process
		LDA !P2MaxHP					;\
		CMP !P2HP					; | enforce max HP
		BCS $03 : STA !P2HP				;/
		REP #$20					;\
		LDA !P2Hitbox1IndexMem				; |
		ORA !P2Hitbox2IndexMem				; | merge hitboxes
		STA !P2Hitbox1IndexMem				; |
		STA !P2Hitbox2IndexMem				; |
		SEP #$20					;/

		LDA !P2KickTimer
		BEQ $03 : DEC !P2KickTimer
		LDA !P2HurtTimer : BEQ +
		DEC !P2HurtTimer
		BRA ++
	+	LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2ShrinkTimer
		BEQ $03 : DEC !P2ShrinkTimer
		++
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2PickUp
		BEQ $03 : DEC !P2PickUp
		LDA !P2TurnTimer
		BEQ $03 : DEC !P2TurnTimer
		LDA !P2FireTimer
		BEQ $03 : DEC !P2FireTimer


		LDA !P2ShrinkTimer : BEQ ..noshrink
		JMP ANIMATION
		..noshrink


		LDA #$46 : STA !P2FallSpeed
		LDA #$06 : STA !P2Gravity

		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		..done




	PIPE:
		JSL CORE_PIPE : BCC CONTROLS
		JMP ANIMATION


	CONTROLS:
		JSL CORE_COYOTE_TIME				; coyote time

		.Hurt
		LDA !P2HurtTimer : BEQ ..done			;\
		LDY #$02					; |
		LDA #$00					; | hurt animation
		JSL CORE_ACCEL_X_8Bit				; |
		JMP PHYSICS					; |
		..done						;/



		.GroundUpdate
		LDA !P2InAir : BNE ..done
		STZ !P2SpinJump
		STZ !P2Crush
		LDA $15
		AND #$04
		STA !P2Ducking : BEQ ..updateslide
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

		LDA !P2Sliding
		BEQ $03 : STA !P2Ducking



		.Gravity
		LDA $15
		ORA $17 : BPL ..done
		LSR !P2Gravity
		..done

		.Jump
		LDA $15						;\
		AND #$80					; | clear jump buffer unless jump is held
		EOR #$80					; |
		TRB !P2Buffer					;/
		LDA !P2Buffer					;\
		AND #$80					; | apply jump buffer
		TSB $16						;/
		LDA $16						;\ check B + A
		ORA $18 : BPL ..done				;/
		LDA !P2Climbing : BNE ..calcheight		;\
		LDA !P2CoyoteTime				; |
		BMI +						; | must be on ground or have coyote time
		BNE ..calcheight				; | or be climbing
	+	LDA !P2InAir : BNE ..done			;/

		..calcheight
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
		CMP #$70 : BCC ..done
		LDA.b #!Mar_LongJump : STA !P2Anim		;\ long jump anim
		STZ !P2AnimTimer				;/
		..done


		.HorizontalMovement
		LDA #$FF : STA $04				; default: dash timer -1
		PHB						;\ wrap to bank 0x00
		LDA #$00 : PHA : PLB				;/

		LDA !P2XSpeed : BEQ ..notblocked
		LDA !P2Blocked
		AND #$03 : BEQ ..notblocked
		STZ !P2XSpeed
		JMP ..done
		..notblocked

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
		LDA !P2Ducking : BNE ..friction			; can't walk/run on ground while crouching

		..handleinput
		LDA $15
		AND #$03 : BEQ ..friction
		CMP #$03 : BNE ..move

		..friction
		LDA !P2InAir : BNE ..nofriction
		LDA #$00					; slope index
		LSR A : TAX
		LDA !IceLevel : BEQ +
		REP #$30
		LDY.w $D309+2,x : BRA ++
	+	REP #$30
		LDY.w $D2CD+2,x
	++	LDA !P2Sliding
		AND #$00FF : BEQ ..applyfriction
		LDA !P2Slope
		CLC : ADC #$0004
		AND #$00FF
		ASL A
		TAX
		LDA.l ..slidespeed,x : BEQ ..applyfriction
	; if sliding on flat ground, apply friction
	; if current speed is greater than slope speed, keep current speed
		BMI ..slideleft
		..slideright
		BIT !P2XSpeedFraction : BMI ..applyfriction
		CMP !P2XSpeedFraction : BCS ..applyfriction
		BRA ..slidekeepdashtimer
		..slideleft
		BIT !P2XSpeedFraction : BPL ..applyfriction
		CMP !P2XSpeedFraction : BCC ..applyfriction

		..slidekeepdashtimer
		STZ $04
		BRA ..nofriction

		..applyfriction
		JSL CORE_ACCEL_X_16Bit
		..nofriction
		JMP ..done

		..slidespeed
		dw $E000,$D000,$D400,$D800,$0000,$2800,$2C00,$3000,$2000

		..dir
		db $01,$00	; right, left

		..move
		TAX
		LDA.l ..dir-1,x : STA !P2Direction

		; accel index
		LDA #$00
		BIT $15
		BVC $01 : INC A
		ASL A
		ORA #$00	; slope index
		STA $00
		STZ $01

		; max speed index
		LDA #$00	; this is NOT slope index, we just start at 0x00
		BIT $15 : BVC ..calcindex
		INC A
		LDY !P2XSpeed
		CPY #$23 : BCC ..calcindex
		CPY #$DD+1 : BCS ..calcindex
		INC A
		..inctimer
		LDY !P2Dashing
		LDX !P2Anim			;\ keep p speed in long jump pose so mario can do a turning p jump
		CPX.b #!Mar_LongJump : BEQ ++	;/
		LDX !P2InAir : BNE +		; dash timer can't increment in midair
	++	LDX #$02 : STX $04		; dash timer +2
	+	CPY #$70 : BCC ..calcindex
		INC A
		..calcindex
		ASL A
		ORA !P2Direction
		ORA #$00	; slope index
		STA $02		; max speed index
		STZ $03
		TAX
		LDA !P2XSpeed
		EOR.w $D535,x : BPL ..updatespeed

		..turning
		LDA $00
		CLC : ADC #$90
		STA $00

		..updatespeed
		LDA !IceLevel : BEQ +
		LDA !P2InAir : BNE +
		REP #$30
		LDX $00
		LDY.w $D43D+4,x : BRA ++
	+	REP #$30
		LDX $00
		LDY.w $D345+4,x
	++	LDX $02
		LDA.w $D535-1,x
		AND #$FF00
		JSL CORE_ACCEL_X_16Bit
		..done

		SEP #$30			; all regs 8-bit

		LDA !P2InAir : BEQ ..timer
		LDA !P2CoyoteTime
		BMI ..timer
		BNE ..notimer
		..timer
		LDA $04				;\
		CLC : ADC !P2Dashing		; |
		BPL $02 : LDA #$00		; | update dash timer (-1 or +2)
		CMP #$70			; |
		BCC $02 : LDA #$70		; |
		STA !P2Dashing			;/
		..notimer

		PLB				; bank wrapper end

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



		.Fire
		LDA !P2TouchingItem : BNE ..done
		LDA !P2FireCharge : BEQ ..done
		BIT $16 : BVC ..done
		DEC !P2FireCharge
		LDA #$0A : STA !P2FireTimer

		%Ex_Index_X_fast()
		STZ $00
		LDA !P2HP
		CMP #$05 : BCC +
		LDA #$08 : STA $00
		+
		LDA $15
		AND #$03 : BEQ ..dir
		CMP #$03 : BNE ..index
		..dir
		LDA !P2Direction
		EOR #$01
		INC A
		..index
		TAY
		LDA !P2XPosLo
		CLC : ADC ..firex-1,y
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
		LDA ..firespeed-1,y : STA !Ex_XSpeed,x
		STZ !Ex_YSpeed,x
		BRA ..done

		..firex
		db $08,$00
		..firespeed
		db $30,$D0
		..done



	PHYSICS:




	SPRITE_INTERACTION:
		JSL CORE_SPRITE_INTERACTION


	UPDATE_SPEED:
		JSL CORE_UPDATE_SPEED


	; CARRY ITEM CODE
	; (this has to be run after speed update to sync sprite image)
		LDX !P2Carry : BEQ .NoCarry
		JSL CORE_CARRY		
		.NoCarry


	OBJECTS:
		REP #$30
		LDA !P2HP					;\
		AND #$00FF					; |
		CMP #$0005 : BCS +				; | always use crouch clipping for small mario
		LDA.w #ANIM_ClippingCrouch			; |
		BRA ++						;/
	+	LDA !P2Anim					;\
		AND #$00FF					; | get index to anim table
		ASL #3						; |
		TAY						;/
		LDA ANIM+$06,y					;
	++	JSL CORE_COLLISION				; pointer to clipping


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
		LDA #!Mar_FaceFront : STA !P2Anim		; |
		JMP .HandleUpdate				; |
		.NoPipe						;/


	; hurt check
		LDA !P2HurtTimer : BEQ .NoHurt
		LDA !P2Anim
		CMP #!Mar_Hurt : BEQ +
		CMP #!Mar_Hurt+1 : BEQ +
		LDA #!Mar_Hurt
	--	STA !P2Anim
		STZ !P2AnimTimer
	-
	+	JMP .HandleUpdate
		.NoHurt

	; shrink check
		LDA !P2ShrinkTimer : BEQ .NoShrink
		LDA !P2Anim
		CMP #!Mar_Shrink : BEQ -
		CMP #!Mar_Shrink+1 : BEQ -
	+	LDA #!Mar_Shrink : BRA --
		.NoShrink


	; climb check
		LDA !P2Climbing : BEQ .NoClimb
		LDA !P2Anim
		CMP #!Mar_Climb : BCC +
		CMP #!Mar_Climb_over : BCC ++
	+	LDA #!Mar_Climb : STA !P2Anim
		STZ !P2AnimTimer
	++	LDA $15
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
		LDA #!Mar_Slide : BRA ++			; > use slide animation if Mario has enough speed
	+	LDA #!Mar_Crouch
	++	STA !P2Anim					; | crouch
		JMP .HandleUpdate				; |
		.NoCrouch					;/

		LDA !P2KickTimer : BEQ .NoKick			;\
		LDA #!Mar_Kick : STA !P2Anim			; |
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
		LDA !P2SlantPipe : BEQ ..noslant
		LDA #$70 : STA !P2Dashing
		LDA.b #!Mar_LongJump : STA !P2Anim
		STZ !P2AnimTimer
		JMP .HandleUpdate
		..noslant
		LDA !P2FireTimer : BNE .FastSwim_set		; midair throw fire pose
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
		CMP #!Mar_SwimSlow+1 : BCC +			;\ don't cancel the swim strike
		CMP #!Mar_SwimSlow_over : BCC ++		;/
	+	CMP #!Mar_SwimFast : BCC ..set
		CMP #!Mar_SwimFast_over : BCC ++
		..set
		LDA #!Mar_SwimFast
		BRA +++

	.SlowSwim
		LDA !P2Anim
		CMP #!Mar_SwimSlow : BCC +
		CMP #!Mar_SwimSlow_over : BCC ++
	+	LDA #!Mar_SwimSlow
	+++	STA !P2Anim
		STZ !P2AnimTimer
	++	JMP .HandleUpdate
		.NoWater



		LDA !P2SpinJump : BEQ .NoSpinJump
		LDA !P2Anim
		CMP.b #!Mar_Spin : BCC +
		CMP.b #!Mar_Spin_over : BCC +++
	+	LDA.b #!Mar_Spin : BRA ++
		.NoSpinJump


		LDA !P2Carry : BNE .CarryJump			; > carry jump check
		LDA !P2Anim					;\
		CMP.b #!Mar_LongJump : BNE .NormalJump		; | long jump frame during running jump
		JMP .HandleUpdate				;/

		.NormalJump
		LDA #!Mar_Jump					;\
		BIT !P2YSpeed : BMI $01 : INC A			; | determine rising/falling frame
		STA !P2Anim					; |
		JMP .HandleUpdate				;/

		.CarryJump
		LDA #!Mar_Walk+2				;\
	-
	++	STA !P2Anim					; | third frame of walk animation
		STZ !P2AnimTimer				; |
	+++	JMP .HandleUpdate				;/

		.Ground
		LDA !P2FireTimer : BEQ ..nofire			;\
		LDA #!Mar_Fire : BRA -				; | fire pose
		..nofire					;/
		LDA !P2XSpeed					;\
		ORA !P2VectorX					; | check for horizonal movement
		BNE .Move					;/

		LDA $15						;\
		AND #$08 : BEQ .Stand				; | look up frame when up is held
		LDA #!Mar_LookUp : STA !P2Anim			; |
		JMP .HandleUpdate				;/
	.Stand	STZ !P2Anim					;\ standing frame when X speed is 0
		BRA .HandleUpdate				;/

		.Move
		STA $00						;\
		LDA $15						; |
		AND #$03 : BEQ .NoTurn				; |
		CMP #$03 : BEQ .NoTurn				; | turn frame when holding against Xspeed direction
		DEC A						; |
		ROR #2						; |
		EOR $00 : BMI .Turn				;/

	.NoTurn	LDA !P2Dashing					;\ determine walk/run animation
		CMP #$70 : BEQ .Run				;/
	.Walk	LDA !P2Anim					;\
		CMP #!Mar_Walk : BCC +				; |
		CMP #!Mar_Walk_over : BCC .HandleUpdate		; | walk animation
	+	LDA #!Mar_Walk : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Run
		LDA !P2Anim					;\
		CMP #!Mar_Run : BCC +				; |
		CMP #!Mar_Run_over : BCC .HandleUpdate		; | run animation
	+	LDA #!Mar_Run : STA !P2Anim			; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Turn
		JSL CORE_SMOKE_AT_FEET
		LDA #!Mar_Turn : STA !P2Anim			; turn frame
		LDA !P2Carry : BEQ .HandleUpdate		;\
		DEC A						; |
		TAX						; | set carried item coordinate
		LDA !P2XPosLo : STA !SpriteXLo,x		; |
		LDA !P2XPosHi : STA !SpriteXHi,x		;/



	.HandleUpdate
		LDA !P2Anim
		REP #$30
		AND #$00FF
		STA $02						; temp anim
		ASL #3
		TAY
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y : BCC .NoUpdate
		LDA ANIM+$03,y : STA !P2Anim
		REP #$20
		AND #$00FF
		ASL #3
		TAY
		SEP #$20
		LDA !P2Anim
		CMP #!Mar_Walk : BCC ..rate0
		CMP #!Mar_Walk_over : BCS ..rate0
		LDA !IceLevel : BEQ +
	..rate4	LDA #$04 : BRA .SetUpdate			; use a special super fast rate on icy ground
		+
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
		REP #$20
		LDA ANIM+$00,y : STA $0E
		SEP #$20
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
		BRA GRAPHICS

		.ThisOne
		REP #$20
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
		ASL #3						; |
		TAY						; |
		BRA .ReplaceAnim				;/
		.CarryAddress					;\
		CLC : ADC #$0800				; | carrying offset
		.NoCarryAddress					;/

		STA $02						; $00 = address
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

		.Flash
		LDA !P2Invinc : BEQ .DrawTiles
		LSR #3 : TAX
		LDA.l $00E292,x
		AND !P2Invinc : BEQ .FireFlash

		.DrawTiles
		REP #$20
		LDA $0E : STA $04
		LDA !P2ShrinkTimer			;\
		AND #$0012 : BNE .Big			; | conditions for small mario tilemap
		LDY !P2HP				; |
		CPY #$05 : BCS .Big			;/
		LDA $04					;\
		CLC : ADC ($04)				; | small mario tilemap
		INC #2					; |
		STA $04					;/

		.Big
		SEP #$20
		JSL CORE_LOAD_TILEMAP


	; fire flash code
		.FireFlash
		SEP #$30
		INC !P2FireFlash
		LDA !P2FireCharge : BEQ ..noglow
		LDA !P2FlashPal
		AND #$1F : BEQ ..glow
		STA !P2FireFlash
		BRA ..noglow
	; write to colors 2, 3, 8 and A
		..glow
		LDA !CurrentPlayer
		BEQ $02 : LDA #$20
		TAX
		REP #$20
		LDA.l CORE_FLASHPAL_Color+4
		STA !PaletteCacheRGB+$104,x
		STA !PaletteCacheRGB+$106,x
		STA !PaletteCacheRGB+$110,x
		STA !PaletteCacheRGB+$114,x
		SEP #$20
		TXA
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$02
		LDA !P2FireFlash
		AND #$3F
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		PHA
		PHX
		JSL MixRGB_Upload
		PLX
		LDA $01,s
		INX #6
		LDY #$01
		PHX
		JSL MixRGB_Upload
		PLX
		PLA
		INX #2
		LDY #$01
		JSL MixRGB_Upload
		..noglow


	OUTPUT_HURTBOX:
		LDA !P2Anim : PHA
		LDA !P2HP
		CMP #$05 : BCS +
		LDA #!Mar_Crouch : STA !P2Anim
	+	REP #$30
		LDA.w #ANIM
		JSL CORE_OUTPUT_HURTBOX
		PLA : STA !P2Anim
		RTL







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	MARIO SUBROUTINES	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; $00D2BD (read from routine at $00D663) holds jump heights (index should be capped at 0x0E)
; $00D535 (read from routine at $00D742) holds speed cap values





; $00E2BD - $00E4B8 + the JSR at $00F636 - $00F69E
; MarioGraphics:
		; LDA !MultiPlayer : BEQ .ThisOne			; animate at 60fps on single player
		; LDA $14
		; AND #$01
		; CMP !CurrentPlayer : BEQ .ThisOne
		; .OtherOne
		; LDA !P2Entrance
		; REP #$30
		; BEQ ..backup
		; LDA.w #ANIM_16x32TM : BRA ..loadbackup
		; ..backup
		; LDA !P2BackupTilemap
		; ..loadbackup
		; STA $0E
		; JMP GRAPHICS
		; .ThisOne
		; LDA !P2ExternalAnimTimer : BNE ..external	;\
		; STZ !P2ExternalAnim				; | check for external anim
		; BRA ..noexternal				;/
		; ..external					;\
		; DEC !P2ExternalAnimTimer			; |
		; REP #$30					; | enforce external anim while external anim timer is set
		; LDA !P2ExternalAnim : BRA .Vanilla_load		; |
		; ..noexternal					;/


		; .OverrideAnim
		; LDA !P2HP : BEQ ..dead
		; LDA !P2HurtTimer : BEQ ..nohurt
		; ..hurt
		; LDA #$2F : STA !MarioAnimTimer
		; LDA !P2HurtTimer
		; CMP #$0C : BCC ..react
		; ..anticipate
		; REP #$30
		; LDY.w #$47*4 : BRA +
		; ..react
		; REP #$30
		; LDY.w #$48*4 : BRA +
		; ..nohurt
		; LDA !P2ShrinkTimer : BEQ ..noshrink
		; REP #$30
		; AND #$0002
		; BEQ $03 : LDA #$003D*4
		; TAY
		; BRA +
		; ..noshrink
		; LDA !P2HangFromLedge : BEQ ..nohang
		; REP #$30
		; LDY.w #$49*4 : BRA +
		; ..dead
		; STZ !P2ShrinkTimer				; clear shrink timer if mario is dead
		; LDA #$3E : STA !MarioImg			; dead img
		; BRA .Vanilla
		; ..nohang


		; .Vanilla
		; REP #$30
		; LDA !MarioImg
		; ..load
		; AND #$00FF
		; ASL #2
		; TAY
	; +
	; -	LDA.w ANIM+0,y : BNE +
		; LDY #$0000 : BRA -
	; +	STA $0E
		; LDA.w ANIM+2,y : STA $04
		; BEQ GRAPHICS


		; .UpdateGFX
		; SEP #$10
		; LDY.b #!File_Mario : JSL GetFileAddress	; get file address


		; LDY #$00					; Y = big format
		; LDA $04						;\
		; AND #$0FFC : ASL #3				; | get source tile bits
		; STA $02						;/
		; LDA !P2ShrinkTimer				;\ shrink anim check
		; AND #$0012 : BNE .BigAddress			;/
		; LDX !P2HP					;\ big address if mario has more than a full heart
		; CPX #$05 : BCS .BigAddress			;/
		; LDA $02 : STA $00				;\
		; AND #$01E0					; |
		; STA $02						; > x tile
		; LDA $00						; |
		; AND #$7E00					; | recalculate address for small mario
		; LSR #2						; | (keep x tile offset, multiply y tile offset by 0.75, add starting offset)
		; STA $00						; |
		; ASL A						; |
		; CLC : ADC $00					; |
		; ORA $02						; |
		; CLC : ADC #$4800				; > offset of small mario
		; DEY						; > Y = small format
		; STA $02						; |
		; .BigAddress					;/


		; LDA $02						; store offset within file
		; LDA $04+1 : JSL CORE_GENERATE_RAMCODE_16bit	; compile RAM code


		; LDA !P2Anim : STA !P2Anim2


	; GRAPHICS:
		; SEP #$30
		; JSL CORE_FLASHPAL
		; LDA !P2Status : BNE .DrawTiles
		; LDA !P2HurtTimer : BNE .DrawTiles

		; .Flash
		; LDA !P2Invinc : BEQ .DrawTiles
		; LSR #3 : TAX
		; LDA.l $00E292,x
		; AND !P2Invinc : BEQ .FireFlash

		; .DrawTiles
		; REP #$20
		; LDA $0E : STA !P2BackupTilemap
		; BEQ .FireFlash
		; STA $04

		; LDA !P2ShrinkTimer			;\
		; AND #$0012 : BNE .Big			; | conditions for small mario tilemap
		; LDY !P2HP				; |
		; CPY #$05 : BCS .Big			;/
		; LDA $04					;\
		; CLC : ADC ($04)				; | small mario tilemap
		; INC #2					; |
		; STA $04					;/

		; .Big
		; SEP #$20
		; JSL CORE_LOAD_TILEMAP


	; ; fire flash code
		; .FireFlash
		; SEP #$30
		; INC !P2FireFlash
		; LDA !P2FireCharge : BEQ ..noglow
		; LDA !P2FlashPal
		; AND #$1F : BEQ ..glow
		; STA !P2FireFlash
		; BRA ..noglow
	; ; write to colors 2, 3, 8 and A
		; ..glow
		; LDA !CurrentPlayer
		; BEQ $02 : LDA #$20
		; TAX
		; REP #$20
		; LDA.l CORE_FLASHPAL_Color+4
		; STA !PaletteCacheRGB+$104,x
		; STA !PaletteCacheRGB+$106,x
		; STA !PaletteCacheRGB+$110,x
		; STA !PaletteCacheRGB+$114,x
		; SEP #$20
		; TXA
		; BEQ $02 : LDA #$10
		; CLC : ADC #$82
		; TAX
		; LDY #$02
		; LDA !P2FireFlash
		; AND #$3F
		; SEC : SBC #$20
		; BPL $03 : EOR #$FF : INC A
		; PHA
		; PHX
		; JSL MixRGB_Upload
		; PLX
		; LDA $01,s
		; INX #6
		; LDY #$01
		; PHX
		; JSL MixRGB_Upload
		; PLX
		; PLA
		; INX #2
		; LDY #$01
		; JSL MixRGB_Upload
		; ..noglow

		; .Return								;\ return
		; RTS								;/





; macro MarDyn(TileCount, TileNumber)
	; dw <TileNumber><<2|(<TileCount><<12)
; endmacro


	; !IdleDyn	= %MarDyn(2, $000)
	; !WalkDyn00	= %MarDyn(2, $002)
	; !WalkDyn01	= %MarDyn(2, $004)

	; !LookUpDyn	= %MarDyn(2, $006)

	; !CrouchDyn	= %MarDyn(2, $008)

	; !RiseDyn	= %MarDyn(2, $00A)
	; !FallDyn	= %MarDyn(2, $00C)

	; !SlideDyn	= %MarDyn(2, $00E)

	; !CarryIdleDyn	= %MarDyn(2, $040)
	; !CarryWalkDyn00	= %MarDyn(2, $042)
	; !CarryWalkDyn01	= %MarDyn(2, $044)
	; !CarryLookUpDyn	= %MarDyn(2, $046)
	; !CarryCrouchDyn	= %MarDyn(2, $048)

	; !FaceBackDyn	= %MarDyn(2, $08E)

	; !FaceFrontDyn	= %MarDyn(2, $08C)

	; !KickDyn	= %MarDyn(2, $04E)

	; !RunDyn00	= %MarDyn(3, $080)
	; !RunDyn01	= %MarDyn(3, $083)
	; !RunDyn02	= %MarDyn(3, $086)

	; !LongJumpDyn	= %MarDyn(3, $089)

	; !TurnDyn	= %MarDyn(2, $04C)

	; !VictoryDyn	= %MarDyn(2, $04A)

	; !SwimDyn00	= %MarDyn(3, $0C0)
	; !SwimDyn01	= %MarDyn(3, $0C3)
	; !SwimDyn02	= %MarDyn(3, $0C6)
	; !SwimFastDyn00	= %MarDyn(3, $100)
	; !SwimFastDyn01	= %MarDyn(3, $103)
	; !SwimFastDyn02	= %MarDyn(3, $106)

	; !ClimbDyn	= %MarDyn(2, $10B)

	; !HammerDyn00	= %MarDyn(2, $140)
	; !HammerDyn01	= %MarDyn(2, $142)
	; !HammerDyn02	= %MarDyn(2, $144)

	; !CutsceneDyn00	= %MarDyn(2, $146)
	; !CutsceneDyn01	= %MarDyn(2, $148)
	; !CutsceneDyn02	= %MarDyn(2, $14A)
	; !CutsceneDyn03	= %MarDyn(2, $14C)
	; !CutsceneDyn04	= %MarDyn(2, $14E)
	; !CutsceneDyn05	= %MarDyn(2, $180)
	; !CutsceneDyn06	= %MarDyn(2, $182)

	; !BalloonDyn	= %MarDyn(4, $184)

	; !SpinDyn00	= %MarDyn(2, $1C0)
	; !SpinDyn01	= %MarDyn(4, $1C2)
	; !SpinDyn02	= %MarDyn(2, $1C6)
	; !SpinDyn03	= %MarDyn(4, $1C8)
	; !SpinDyn04	= %MarDyn(2, $1CC)
	; !SpinDyn05	= %MarDyn(2, $1CE)
	; !SpinDyn06	= %MarDyn(4, $200)

	; !FlutterDyn00	= %MarDyn(2, $204)
	; !FlutterDyn01	= %MarDyn(2, $206)
	; !FlutterDyn02	= %MarDyn(2, $208)

	; !HurtDyn00	= %MarDyn(2, $1C4)
	; !HurtDyn01	= %MarDyn(3, $188)
	; !ShrinkDyn	= %MarDyn(2, $18B)
	; !DeadDyn	= %MarDyn(2, $18E)

	; !FireThrowDyn	= %MarDyn(2, $1C0)

	; !HangDyn	= %MarDyn(2, $1C2)



	; ANIM:
		; ; VANILLA STUFF
		; dw .16x32TM : !IdleDyn		; 00
		; dw .16x32TM : !WalkDyn00	; 01
		; dw .16x32TM : !WalkDyn01	; 02
		; dw .16x32TM : !LookUpDyn	; 03
		; dw .24x32TM : !RunDyn00		; 04
		; dw .24x32TM : !RunDyn01		; 05
		; dw .24x32TM : !RunDyn02		; 06
		; dw .16x32TM : !CarryIdleDyn	; 07
		; dw .16x32TM : !CarryWalkDyn00	; 08
		; dw .16x32TM : !CarryWalkDyn01	; 09
		; dw .16x32TM : !CarryLookUpDyn	; 0A
		; dw .16x32TM : !RiseDyn		; 0B
		; dw .24x32TM : !LongJumpDyn	; 0C
		; dw .16x32TM : !TurnDyn		; 0D
		; dw .16x32TM : !KickDyn		; 0E
		; dw .16x32TM : !FaceFrontDyn	; 0F
		; dw $0000,$0000			; 10
		; dw $0000,$0000			; 11
		; dw $0000,$0000			; 12
		; dw $0000,$0000			; 13
		; dw $0000,$0000			; 14
		; dw .16x32TM : !ClimbDyn		; 15
		; dw .24x32TM : !SwimDyn00	; 16
		; dw .24x32TM : !SwimFastDyn00	; 17
		; dw .24x32TM : !SwimDyn01	; 18
		; dw .24x32TM : !SwimFastDyn01	; 19
		; dw .24x32TM : !SwimDyn02	; 1A
		; dw .24x32TM : !SwimFastDyn02	; 1B
		; dw .16x32TM : !SlideDyn		; 1C
		; dw .16x32TM : !CarryCrouchDyn	; 1D
		; dw $0000,$0000			; 1E
		; dw $0000,$0000			; 1F
		; dw $0000,$0000			; 20
		; dw $0000,$0000			; 21
		; dw $0000,$0000			; 22
		; dw $0000,$0000			; 23
		; dw .16x32TM : !FallDyn		; 24
		; dw .16x32TM : !FaceBackDyn	; 25
		; dw .16x32TM : !VictoryDyn	; 26
		; dw $0000,$0000			; 27
		; dw $0000,$0000			; 28
		; dw $0000,$0000			; 29
		; dw $0000,$0000			; 2A
		; dw $0000,$0000			; 2B
		; dw $0000,$0000			; 2C
		; dw $0000,$0000			; 2D
		; dw $0000,$0000			; 2E
		; dw $0000,$0000			; 2F
		; dw .16x32TM : !CutsceneDyn03	; 30 (exploded 1)
		; dw .16x32TM : !CutsceneDyn04	; 31 (exploded 2)
		; dw .16x32TM : !CutsceneDyn02	; 32 (action pose)
		; dw .16x32TM : !CutsceneDyn00	; 33 (looking off 1)
		; dw .16x32TM : !CutsceneDyn01	; 34 (looking off 2)
		; dw .16x32TM : !HammerDyn00	; 35
		; dw .16x32TM : !HammerDyn01	; 36
		; dw .16x32TM : !HammerDyn02	; 37
		; dw $0000,$0000			; 38
		; dw $0000,$0000			; 39
		; dw .16x32TM : !HammerDyn02	; 3A
		; dw .16x32TM : !HammerDyn02	; 3B
		; dw .16x32TM : !CrouchDyn	; 3C
		; dw .16x32TM : !ShrinkDyn	; 3D
		; dw .16x32TM : !DeadDyn		; 3E
		; dw .16x32TM : !FireThrowDyn	; 3F
		; dw $0000,$0000			; 40
		; dw $0000,$0000			; 41
		; dw .32x32TM : !BalloonDyn	; 42
		; dw .32x32TM : !BalloonDyn	; 43
		; dw .16x32TM : !FaceBackDyn	; 44
		; dw .16x32TM : !FaceFrontDyn	; 45
		; dw .16x32TM : !IdleDyn		; 46

		; ; CUSTOM STUFF
		; dw .16x32TM : !HurtDyn00	; 47
		; dw .24x32TM : !HurtDyn01	; 48
		; dw .16x32TM : !HangDyn		; 49







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
	db $FF,$FF				; hurt
	db $FF,$FF				; shrink
	db $FF					; dead



macro MarDyn(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro


	ANIM:
	.Idle0
	dw .16x32TM : db $00,!Mar_Idle
	%MarDyn(2, $000)
	dw .ClippingStandard

	.Walk
	dw .16x32TM : db $06,!Mar_Walk+1
	%MarDyn(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Walk+2
	%MarDyn(2, $002)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Walk
	%MarDyn(2, $004)
	dw .ClippingStandard

	.Run
	dw .24x32TM : db $02,!Mar_Run+1
	%MarDyn(3, $080)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Mar_Run+2
	%MarDyn(3, $083)
	dw .ClippingStandard
	dw .24x32TM : db $02,!Mar_Run
	%MarDyn(3, $086)
	dw .ClippingStandard

	.LookUp
	dw .16x32TM : db $FF,!Mar_LookUp
	%MarDyn(2, $006)
	dw .ClippingStandard

	.Crouch
	dw .16x32TM : db $FF,!Mar_Crouch
	%MarDyn(2, $008)
	dw .ClippingCrouch

	.Jump
	dw .16x32TM : db $FF,!Mar_Jump
	%MarDyn(2, $00A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Jump+1
	%MarDyn(2, $00C)
	dw .ClippingStandard

	.Slide
	dw .16x32TM : db $FF,!Mar_Slide
	%MarDyn(2, $00E)
	dw .ClippingCrouch

	.FaceBack
	dw .16x32TM : db $FF,!Mar_FaceBack
	%MarDyn(2, $08E)
	dw .ClippingStandard

	.FaceFront
	dw .16x32TM : db $FF,!Mar_FaceFront
	%MarDyn(2, $08C)
	dw .ClippingStandard

	.Kick
	dw .16x32TM : db $08,!Mar_Idle
	%MarDyn(2, $04E)
	dw .ClippingStandard

	.LongJump
	dw .24x32TM : db $FF,!Mar_LongJump
	%MarDyn(3, $089)
	dw .ClippingStandard

	.Turn
	dw .16x32TM : db $FF,!Mar_Turn
	%MarDyn(2, $04C)
	dw .ClippingStandard

	.Victory
	dw .16x32TM : db $FF,!Mar_Victory
	%MarDyn(2, $04A)
	dw .ClippingStandard

	.SwimSlow
	dw .24x32TM : db $FF,!Mar_SwimSlow
	%MarDyn(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+2
	%MarDyn(3, $0C0)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+3
	%MarDyn(3, $0C3)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimSlow+0
	%MarDyn(3, $0C6)
	dw .ClippingStandard

	.SwimFast
	dw .24x32TM : db $08,!Mar_SwimFast+1
	%MarDyn(3, $100)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimFast+2
	%MarDyn(3, $103)
	dw .ClippingStandard
	dw .24x32TM : db $08,!Mar_SwimFast
	%MarDyn(3, $106)
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $08,!Mar_Climb+1
	%MarDyn(2, $10B)
	dw .ClippingStandard
	dw .16x32TMX : db $08,!Mar_Climb
	%MarDyn(2, $10B)
	dw .ClippingStandard

	.Hammer
	dw .16x32TM : db $06,!Mar_Hammer+1
	%MarDyn(2, $140)
	dw .ClippingStandard
	dw .16x32TM : db $06,!Mar_Hammer+2
	%MarDyn(2, $142)
	dw .ClippingStandard
	dw .16x32TM : db $0C,!Mar_Idle
	%MarDyn(2, $144)
	dw .ClippingStandard

	.Cutscene
	dw .16x32TM : db $FF,!Mar_Cutscene
	%MarDyn(2, $146)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+1
	%MarDyn(2, $148)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+2
	%MarDyn(2, $14A)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+3
	%MarDyn(2, $14C)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+4
	%MarDyn(2, $14E)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+5
	%MarDyn(2, $180)
	dw .ClippingStandard
	dw .16x32TM : db $FF,!Mar_Cutscene+6
	%MarDyn(2, $182)
	dw .ClippingStandard

	.Balloon
	dw .32x32TM : db $FF,!Mar_Balloon
	%MarDyn(4, $184)
	dw .ClippingStandard

	.Spin
	dw .16x32TM : db $02,!Mar_Spin+1
	%MarDyn(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Mar_Spin+2
	%MarDyn(4, $08C)
	dw .ClippingStandard
	dw .16x32TMX : db $02,!Mar_Spin+3
	%MarDyn(2, $000)
	dw .ClippingStandard
	dw .16x32TM : db $02,!Mar_Spin
	%MarDyn(4, $08E)
	dw .ClippingStandard

	.Fire
	dw .16x32TM : db $FF,!Mar_Fire
	%MarDyn(2, $1C0)
	dw .ClippingStandard

	.Hang
	dw .16x32TM : db $FF,!Mar_Hang
	%MarDyn(2, $1C2)
	dw .ClippingStandard

	.Hurt
	dw .16x32TM : db $04,!Mar_Hurt+1
	%MarDyn(2, $1C4)
	dw .ClippingCrouch
	dw .24x32TM : db $0F,!Mar_Idle
	%MarDyn(3, $188)
	dw .ClippingCrouch

	.Shrink
	dw .16x32TM : db $04,!Mar_Shrink+1
	%MarDyn(2, $18B)
	dw .ClippingCrouch
	dw .16x32TM : db $04,!Mar_Shrink+0
	%MarDyn(2, $000)
	dw .ClippingCrouch

	.Dead
	dw .16x32TM : db $FF,!Mar_Dead
	%MarDyn(2, $18E)
	dw .ClippingStandard



	.16x32TM
	dw $0008			; big mario
	db $20,$00,$F0,!P1Tile1
	db $20,$00,$00,!P1Tile3
	dw $0008			; small mario
	db $20,$00,$F8,!P1Tile1
	db $20,$00,$00,!P1Tile3
	.16x32TMX
	dw $0008			; big mario
	db $60,$00,$F0,!P1Tile1
	db $60,$00,$00,!P1Tile3
	dw $0008			; small mario
	db $60,$00,$F8,!P1Tile1
	db $60,$00,$00,!P1Tile3


	.24x32TM
	dw $0010			; big mario
	db $20,$00,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile1+1
	db $20,$00,$00,!P1Tile3
	db $20,$08,$00,!P1Tile3+1
	dw $0010			; small mario
	db $20,$00,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile1+1
	db $20,$00,$00,!P1Tile3
	db $20,$08,$00,!P1Tile3+1


	.32x32TM
	dw $0010			; big mario
	db $20,$F8,$F0,!P1Tile1
	db $20,$08,$F0,!P1Tile2
	db $20,$F8,$00,!P1Tile3
	db $20,$08,$00,!P1Tile4
	dw $0010			; small mario
	db $20,$F8,$F8,!P1Tile1
	db $20,$08,$F8,!P1Tile2
	db $20,$F8,$00,!P1Tile3
	db $20,$08,$00,!P1Tile4



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







namespace off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


