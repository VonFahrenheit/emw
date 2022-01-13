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
		LDA !MarioAnim
		JSL $0086DF
		dw $CC68			; 00, normal
		dw $D129			; 01, power down
		dw $D147			; 02, mushroom up
		dw $D15F			; 03, cape up
		dw $D16F			; 04, flower up
		dw $D197			; 05, horizontal pipe + door
		dw $D203			; 06, vertical pipe
		dw $D287			; 07, cannon pipe
		dw $C7FD			; 08, yoshi wings
		dw $D0B6			; 09, death
		dw $C870			; 0A, enter castle aniimation
		dw $C5B5			; 0B, freeze
		dw $C6E7			; 0C, destroy castle animation
		dw $C592			; 0D, freeze
	warnpc $00C5B5



; -- Mario upgrades --

	; throw fireball
	org $00D081
	;	JML Mario_Fireball		; org: CMP #$03 : BNE $28 ($00D0AD)
		CMP #$03 : BNE $28

	; code that checks air/ground
	org $00D5F2
	;	JML Mario_AirHook		; org: LDA !MarioInAir : BEQ $03 (otherwise JMPs to $00D682)
		LDA !MarioInAir : BEQ $03

	; cap jump height index
	org $00D637
		JSL Mario_JumpHeight		; org: LSR #2 : AND #$FE

	; prevent flight
	org $00D674
		BRA $05				;\
		NOP #2				; | org: BNE $05 : LDA #$50 : STA $749F
		STZ $749F			;/

	; uncap speed boost
	org $00D742
		JML Mario_SpeedBoost		;\ org: LDA.b !MarioXSpeed : SEC : SBC $D535,y
		NOP #2				;/


	; ability to float
	org $00D8E9
		JML Mario_Cape1			; org: CMP #$02 : BNE $3B ($00D928)

	; draw cape
	org $00E3FD
		JML Mario_Cape2			; org: CMP #$02 : BNE $57 (careful with repointing! target gone!)

	org $00EA0D
	;	JSL Mario_HandyGlove		; org: LDA !MarioBlocked : AND #$03
		LDA !MarioBlocked
		AND #$03


	; first 2 bytes for big Mario, then 2 for small Mario, last 2 are unused
	org $00FE96
		db $00,$08,$00,$08,$FF,$FF	; X lo
	org $00FE9C
		db $00,$00,$00,$00,$FF,$FF	; X hi
	org $00FEA2
		db $08,$08,$10,$10,$FF,$FF	; Y

	org $00FEC4
	;	JSL Mario_TacticalFire		; org: LDA #$30 : STA !Ex_YSpeed,x
	;	NOP
		LDA #$30 : STA !Ex_YSpeed,x
	org $00FED1
		LDA !MarioPowerUp
		BNE $02 : INY #2
		BRA 6
		NOP #6
	warnpc $00FEDF

	org $01AA33
		JML Mario_Bounce		; hijack the main mario bounce on enemy code (stomp)




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

	org $00FEA8
	;	JML Mario_FireballCheck		; fusion core fireball check fix
	;	NOP
		NOP #5

	org $00FEB6
		db $36				; Fireball SFX

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
		LDA #$0000 : STA $2116
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


	org $00D0B6
	MarioDead:
		STZ $19
		LDA #$3E : STA !MarioImg
		STZ !MarioXSpeed
		JSR $DC2D
		JSR $D92E
		LDA $14
		LSR #2
		AND #$01
		STA !MarioDirection
		RTS
	warnpc $00D11D



	org $00F5B7
	MarioHurt:
		LDA !MarioAnim : BNE .Return
		LDA !CurrentMario : BEQ .Return
		JSL !HurtPlayers
		.Return
		RTL
	warnpc $00F5F3


	org $028758
		BRA +				;\ org: LDA $6DB3 : ASL A
		NOP #2				;/
	org $028777
		+



	org $02A129
		LDA #$02 : STA $3230,x		;\ Sprites get knocked out by fireballs
		BRA $06 : NOP #6		;/

	org $03B69B
		STA $09
		PLX
		RTL

; -- smoke fix --
	org $00FE4A
		PHX				;\
		JSL CORE_SMOKE_AT_FEET		; | org LDA $13 : AND #$03 : ORA !MarioInAir : ORA $81
		PLX				; |
		RTS				; |
		NOP				;/



; -- sprite edits --
	org $01A847				; star kill code
		JSL StarKill			; org: JSL $01AB6F

	org $01A8F2				; slide kill code
		JSL StarKill			;\
		RTS				; | org: JSR $A728 : JSR $A847
		NOP				;/

	org $01A92C				; patch out yoshi check to let mario bounce properly from spin jump
		BRA $03 : NOP #3		; org: LDA $787A : BEQ $04 ($01A935)


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



	org $00E2B2				; Mario's base OAM index
		db $00				; org: $10

	org $00E3D2				; property
	;	JML MarioTileRemap_Prop
		BRA $05 : NOP #2
	org $00E3D6				; property
		dl CORE_PlayerClipping		; $00E3D6 is a psuedo-vector!
		PLA
		JML $00E3DB
	;	NOP #2
	;	STA !OAM+$113-$18,y
	;	STA !OAM+$0FB-$18,y
	;	STA !OAM+$0FF-$18,y
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


	org $00E482
	;	JSL MarioTileRemap_Coords	; org: STA !OAM+$101,y : REP #$20
		NOP #4
		BRA 23				;\ skip this code
		NOP #23				;/
	warnpc $00E49F



	org $00E4AC				; hi table
		dw !OAMhi+$40-$6


	pullpc



	Mario:
		LDA #$08					;\
		CLC : ADC !PlayerBonusHP			; | max HP
		STA !P2MaxHP					;/

		LDA !P2HP					;\
		CMP !P2MaxHP					; | enforce max HP
		BCC $03 : LDA !P2MaxHP				; |
		STA !P2HP					;/

		LDX #$00					;\
		LDA !P2HP					; |
		CMP #$05 : BCC +				; | set powerup status (really just size)
		LDX #$01					; |
	+	STX $19						;/


		.Controls
		LDA !P2Entrance : BEQ +
		LDA #$FF : BRA ++
	+	LDA !P2HurtTimer : BEQ ..normal
		LDA #$0F
	++	TRB $15
		TRB $6DA3
		STZ $16
		STZ $17
		STZ $18
		STZ $6DA5
		STZ $6DA7
		STZ $6DA9
		LDA !MarioXSpeed
		BEQ ..done
		BPL +
		INC #2
	+	DEC A
		STA !MarioXSpeed
		BRA ..done

		..normal
		LDA $17						;\
		AND #$80 : TSB $15				; |
		LDA $6DA5					; | merge button A into button B
		AND #$80 : TSB $6DA3				; |
		LDA $6DA9					; |
		AND #$80 : TSB $6DA7				;/
		LDA !CurrentPlayer : BNE ..done			;\
		LDA $6DA5					; | the curious case of player 1
		AND #$80 : TSB $6DA2				; |
		..done						;/


		LDA !P2HurtTimer
		BEQ $03 : DEC !P2HurtTimer
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc


		STZ $73DE					; clear "mario looking up" flag

		LDA $9D : BNE .NoTimers				; unless $9D is set, decement mario's timers
		LDX #$13					;\
	-	LDA $7495,x					; | auto-decrement $7496-$74A8
		BEQ $03 : DEC $7495,x				; | (note the BNE, $7495 is not decremented here)
		DEX : BNE -					;/
		.NoTimers

	;	LDA !MarioAnim : BNE .Anim			; > check animation/status
	;	LDA $16						;\
	;	AND #$20 : BEQ .NoBox				; |
	;	PHB						; |
	;	LDA #$02					; | process item box swap
	;	PHA : PLB					; |
	;	JSL $028008					; |
	;	PLB						; |
	;	BRA .NoBox					;/
	LDA !MarioAnim : BEQ .NoBox
	CMP #$09 : BNE .Anim				;\ drop carried item upon death
	STZ !P2Carry					;/

	.Anim	JSR RunMario					; > animation/status codes
		.NoBox						;


		STZ !P2Hitbox1IndexMem1				;\
		STZ !P2Hitbox1IndexMem2				; | clear this stuff from riposte
		STZ !P2Hitbox2IndexMem1				; |
		STZ !P2Hitbox2IndexMem2				;/


		PHK : PLB

		LDA #$FF : STA !P2SlopeSpeed			; disable standard slope speed limit

		REP #$20					;\
		LDA !MarioXPos : STA $D1			; | copy of $00A2F3
		LDA !MarioYPos : STA $D3			; |
		SEP #$20					;/

		LDA !MarioAnim : BEQ .MAIN			; execute MAIN if anim = 0
		REP #$20					;\
		LDA !MarioXPosLo : STA !P2XPosLo		; |
		LDA !MarioYPosLo				; |
		CLC : ADC #$0010				; | otherwise pass coords + dir and go to GFX
		STA !P2YPosLo					; |
		SEP #$20					; |
		LDA !MarioDirection : STA !P2Direction		; |
		JMP .End					;/


		.MAIN
		LDA !MarioYSpeed : BPL .NoBonk			;\
		LDA !MarioBlocked				; |
		AND #$08 : BEQ .NoBonk				; | mario y speed = 0 when bonking
		STZ !MarioYSpeed				; |
		.NoBonk						;/

		STZ !MarioSlope					; reset mario slope status long
		STZ $73EE					; reset mario slope status simple


	;	LDA !MarioSpinJump : STA !P2Crush		; pass spin jump
		LDA !MarioPickUp : STA !P2PickUp		; pass pickup timer
		LDA !MarioTurnTimer : STA !P2TurnTimer		; pass turn timer
		LDA !MarioKickTimer : STA !P2KickTimer		; pass kick timer
		LDA !MarioDucking : STA !P2Ducking		; pass duck flag
		LDA !MarioInAir					;\
		BEQ $02 : LDA #$04				; | pass midair flag
		STA !P2InAir					;/
		LDA !MarioFlashTimer : STA !P2Invinc		; pass invinc timer
		LDA #$46 : STA !P2FallSpeed			; mario's fall speed is 0x46
		STZ !P2Gravity					; mario has his own gravity code
		REP #$20					;\
		STZ !P2ExtraInput1				; | clear extra input
		STZ !P2ExtraInput3				; |
		SEP #$20					;/
		STZ !P2Character				; > char = mario
		LDA !MarioFlashTimer : STA !P2Invinc		; > pass mario's invincibility timer
		LDA !MarioDirection : STA !P2Direction		; > pass direction flag
		LDA !MarioBlocked : STA !P2Blocked		; > pass collision flags
	;	LDA !MarioWater : STA !P2Water			; > pass mario's water status
		LDA !MarioClimbing : STA !P2Climbing		; > pass climb flag
		LDA !MarioXFraction : STA !P2XFraction		;\ pass position fraction bits
		LDA !MarioYFraction : STA !P2YFraction		;/
		REP #$20					; A 16-bit
		LDA !MarioXSpeed-1 : STA !P2XSpeed-1		;\ pass speeds
		LDA !MarioYSpeed-1 : STA !P2YSpeed-1		;/
		LDA !MarioXPosLo : STA !P2XPosLo		;\
		LDA !MarioYPosLo				; |
		CLC : ADC #$0010				; | pass coords
		STA !P2YPosLo					; |
		SEP #$20					;/


		.SlantPipe
		LDA !P2SlantPipe : BEQ ..done
		DEC !P2SlantPipe : BNE ..process
		STZ !MarioBehind
		BRA ..done
		..process
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		LDA #$70 : STA !MarioDashTimer
		LDA #$0C : STA !MarioInAir
		..done


		JSL CORE_UPDATE_SPEED				; > apply speeds (already includes a stasis check)
		JSL CORE_SCREEN_BORDER				; > screen border


		LDA !P2Pipe					;\
		AND #$0F : BEQ .GetCollision			; |
		LDA #$04 : TSB !P2Blocked			; | skip collision during pipe animation
		LDA !P2Pipe : BMI +				; > don't set vertical pipe offset
		LDA !P2YPosLo					; |
		BIT #$01 : BEQ +				; |
		AND #$F0					; |
		ORA #$0E					; | also set horz pipe offset
		SEC : SBC #$10					; |
		STA !P2YPosLo					; |
		BCS +						; |
		DEC !P2YPosHi					; |
		BRA +						; |
		.GetCollision					;/
		LDA !P2Ducking : BNE .Small			;\
		LDA $19 : BEQ .Small				; |
		.Big						; |
		REP #$20					; |
		LDA.w #.ClippingBig				; | layer clipping
		BRA .Collision					; |
		.Small						; |
		REP #$20					; |
		LDA.w #.ClippingSmall				; |
		.Collision					;/
		JSL CORE_COLLISION				; interact with layer
	+	JSL CORE_PIPE					; pipe code

		JSL !GetP1Clipping				;\
		LDA $00 : STA !P2Hurtbox+0			; |
		LDA $08 : STA !P2Hurtbox+1			; |
		LDA $01 : STA !P2Hurtbox+2			; | output mario hurtbox
		LDA $09 : STA !P2Hurtbox+3			; |
		LDA $02 : STA !P2Hurtbox+4			; |
		LDA $03 : STA !P2Hurtbox+5			;/

		STZ !MarioBehind				; no
		LDA !P2Pipe : BEQ .NoPipe			;\ mario behind everything in pipe
		LDX #$02 : STX !MarioBehind			;/
		BIT #$80 : BEQ .HorzPipe			; see if sideways or vertical pipe
		.VertPipe					;\
		LDA #$0F : STA !MarioImg			; |
		REP #$20					; |
		LDA !P2XSpeed-1 : STA !MarioXSpeed-1		; |
		LDA !P2YSpeed-1 : STA !MarioYSpeed-1		; | for vertical pipe, set image, return coords/speeds, then end
		LDA !P2XPosLo : STA !MarioXPosLo		; |
		LDA !P2YPosLo					; |
		SEC : SBC #$0010				; |
		STA !MarioYPosLo				; |
		SEP #$20					; |
		JMP .PhysicsDone				;/
		.HorzPipe					;\
		BIT #$40 : BEQ ..l				; |
	..r	LDA #$01 : BRA ..w				; |
	..l	LDA #$02					; | for horizontal pipe, force input and let the engine handle the rest
	..w	STA $15						; |
		BRA .NoCarry					; |
		.NoPipe						;/


		JSL CORE_SPRITE_INTERACTION			;\ interact with sprite state 09
		LDX !P2Carry : BEQ .NoCarry			;/
		JSL CORE_PLUMBER_CARRY				; carry items
		.NoCarry
		LDA !P2PickUp : STA !MarioPickUp		; return pickup timer
		LDA !P2KickTimer : STA !MarioKickTimer		; return kick timer
		LDA !P2Carry : STA $748F			; return carry item flag (this is not passed and it shouldn't be since it's handled by PCE)


		LDA !P2Slope : BEQ .NoSlope			;\
		BPL $03 : EOR #$FF : INC A			; |
		STA $00						; |
		LDA !MarioAnimTimer				; | mario anim timer on slopes
		CMP $00 : BCS .NoSlope				; |
		STZ !MarioAnimTimer				; |
		.NoSlope					;/

		LDA !P2Status : BEQ .NoKill			;\
		LDA #$09 : STA !MarioAnim			; | mario kill status
		.NoKill						;/

		LDA !P2Blocked					;\
		AND #$04					; |
		ORA !MarioInAir					; | mario air status
		BNE .AirDone					; |
		LDA #$24 : STA !MarioInAir			; |
		.AirDone					;/


		LDA !P2Blocked : STA !MarioBlocked		; return collision status
		AND #$04 : BNE .Ground				;
		.Air						;\
		LDA !P2Carry : BNE ..noflip			; > can't flip while carrying something
		LDA !P2SpinFlip : BEQ ..noflip			; |
		DEC !P2SpinFlip					; |
		BIT $17 : BPL ..nospin				; |
		LDA #$01 : STA !MarioSpinJump			; | can switch to spin jump during first 3 frames of jump (use held input to work with buffer)
		LDA #$04 : STA !SPC4				; > spin jump SFX
		STZ !P2SpinFlip					; |
		..nospin					; |
		..noflip					; |
		BRA .GroundDone					;/
		.Ground						;\
		STZ !MarioInAir					; |
		STZ !MarioSpinJump				; | clear these regs on ground
		STZ !P2HangFromLedge				; |
		STZ !MarioClimbing				; |
		STZ !MarioKillCount				;/
		LDA #$03 : STA !P2SpinFlip			; > 3 frames to flip jump type
		LDA !P2Buffer					;\
		AND #$80 : TSB $16				; | buffer jump from landing
		TRB !P2Buffer					;/
		LDA !P2Carry : BNE .NoSlide			; > can't slide while holding item
		LDA !P2Slope : BNE .Slope			;\
		LDA !P2XSpeed : BNE .GroundDone			; |
		.NoSlide					; | cancel slide when mario stops, but only if he's on flat ground
		STZ $73ED					; |
		BRA .GroundDone					;/
	.Slope	LDA $6DA3					;\
		AND #$04 : BEQ .GroundDone			; | set mario sliding pose
		LDA #$1C : STA $73ED				; |
		.GroundDone					;/
		LDA !MarioBlocked				;\
		AND #$03 : BEQ .NoWall				; |
		DEC A						; |
		LSR A						; | clear mario's X speed when bonking a wall
		ROR A						; |
		EOR !P2XSpeed : BMI .NoWall			; |
		STZ !P2XSpeed					; |
		.NoWall						;/


	; water stuff
		LDA !P2Water					;\
		AND #$10					; | return water flag
		STA !MarioWater					;/
		BNE $03 : JMP .NoWater				; branch past if no water
		LDA !P2Carry : BNE .FastSwim			;\ see which swim animation should be used
		LDA !P2FastSwim : BNE .SlowSwim			;/
		.FastSwim					;\
		LDA !P2XSpeed					; |
		BPL $03 : EOR #$FF : INC A			; |
		LSR #4						; |
		DEC A						; | fast swim animation rate
		BPL $02 : LDA #$00				; |
		CLC : ADC !P2AnimTimer				; |
		CMP #$07					; |
		BCC $02 : LDA #$07				; |
		STA !P2AnimTimer				;/
		LDA !P2Anim					;\
		CMP #!Mar_SwimSlow+1 : BCC +			; | if currently in slow swim animation, only enter fast swim animation from during frame 1
		CMP #!Mar_SwimSlow_over : BCC .HandleUpdate	;/
	+	CMP #!Mar_SwimFast : BCC +			;\
		CMP #!Mar_SwimFast_over : BCC .HandleUpdate	; | set fast swim animation
	+	LDA #!Mar_SwimFast : BRA ++			;/
		.SlowSwim					;\
		LDA !P2Anim					; |
		CMP #!Mar_SwimSlow_over : BCC .HandleUpdate	; | slow swim animation
		LDA #!Mar_SwimSlow				; |
	++	STA !P2Anim					; |
		STZ !P2AnimTimer				;/
		.HandleUpdate
		LDA !MarioFireTimer : BEQ +			;\ always use pose 0x18 when throwing a fireball
		LDA #$18 : BRA ++				;/
	+	LDA !P2Anim					;\
		ASL #2						; |
		TAX						; |
		LDA !P2AnimTimer				; |
		INC A						; |
		STA !P2AnimTimer				; |
		CMP .SwimGFX+2,x : BNE +			; | swim animations
		LDA .SwimGFX+3,x : STA !P2Anim			; |
		ASL #2						; |
		TAX						; |
		STZ !P2AnimTimer				; |
	+	LDA !P2Carry					; |
		BEQ $01 : INX					; |
		LDA .SwimGFX,x					; |
	++	STA !MarioImg					;/
		STZ !MarioSpinJump				; clear spin jump
		STZ !MarioDashTimer				; clear dash
		JSL CORE_PLUMBER_SWIM				; swim physics
		.NoWater
		LDA !P2Ducking : STA !MarioDucking		; return duck flag
		LDA !P2Direction : STA !MarioDirection		; return direction

		STZ $73DD

		LDA !P2XFraction : STA !MarioXFraction		;\ return position fraction bits
		LDA !P2YFraction : STA !MarioYFraction		;/
		REP #$20					; A 16-bit
		LDA !P2XSpeed-1 : STA !MarioXSpeed-1		;\ return speeds
		LDA !P2YSpeed-1 : STA !MarioYSpeed-1		;/
		LDA !P2XPosLo : STA !MarioXPosLo		;\
		LDA !P2YPosLo					; |
		SEC : SBC #$0010				; | return coords
		STA !MarioYPosLo				; |
		SEP #$20					;/


	; climb stuff
		LDA !MarioClimbing : BNE .NoClimbInit		;\
		LDA !P2Climbing : BEQ .NoClimbInit		; | initial climb direction
		LDA !MarioDirection : STA !P2ClimbDirection	; |
		.NoClimbInit					;/

		LDA !P2Climbing : STA !MarioClimbing		; return climb flag
		BEQ .NoClimb					; branch past if not climbing
		STZ !MarioSpinJump				;\ clear crouch and spin jump
		STZ !MarioDucking				;/
		BIT $6DA7 : BPL .NoJump				;\
		LDA #$B0 : STA !MarioYSpeed			; |
		LDA #$0B : STA !MarioInAir			; | jump from climb
		LDA #$2B : STA !SPC1				; > jump SFX
		STZ !MarioClimbing				; |
		LDA !P2ClimbDirection : STA !MarioDirection	; |
		BRA .NoClimb					;/
		.NoJump						;\
		LDA #$15 : STA !MarioImg			; |
		LDA $6DA3					; |
		AND #$0F : BEQ .Stationary			; |
		AND #$03 : BEQ +				; |
		CMP #$03 : BEQ +				; | mario direction while climbing
		DEC A						; |
		STA !P2ClimbDirection				; |
	+	LDA $14						; |
		LSR #3						; |
		AND #$01 : STA !MarioDirection			;/
		.Stationary					;\
		JMP .PhysicsDone				; | done
		.NoClimb					;/

		LDA !P2FireCharge : BNE $03			;\
	-	JMP .NoFire					; | if mario has a fire charge and presses Y, consume the fire charge to throw a fireball
		BIT $16 : BVC -					; |
		LDA !P2TouchingItem : BNE -			; > picking up items has priority over fireball
		STZ !P2FireCharge				;/
		LDA.b #!MarioFlashPal&$E0|$10 : STA !P2FlashPal	; flash
		LDA #$36 : STA !SPC4				; fireball SFX
		LDA #$0A : STA !MarioFireTimer			; mario throw fireball timer
		%Ex_Index_X_fast()				;\ spawn fireball
		LDA #$05+!ExtendedOffset : STA !Ex_Num,x	;/
		LDA $15						;\
		AND #$03 : BEQ +				; |
		DEC A						; |
		CMP #$02 : BNE ++				; | index to tables (use input instead of dir, unless there is no input)
	+	LDA !P2Direction				; |
		EOR #$01					; |
	++	TAY						;/
		LDA .FireSpeed,y : STA !Ex_XSpeed,x		; fireball X speed
		LDA !MarioUpgrades				;\
		AND $15						; |
		AND #$08 : BEQ +				; | apply tactical fire (do you even see this bit placement?!)
		LDA #$FC : BRA ++				; |
	+	LDA #$01					; |
	++	STA !Ex_YSpeed,x				;/
		LDA !P2XPosLo					;\
		CLC : ADC .FireX,y				; |
		STA !Ex_XLo,x					; | fireball xpos depends on direction
		LDA !P2XPosHi					; |
		ADC #$00					; |
		STA !Ex_XHi,x					;/
		LDY $19						;\
		LDA !P2YPosLo					; |
		SEC : SBC .FireY,y				; |
		STA !Ex_YLo,x					; | fireball ypos depends on powerup/size
		LDA !P2YPosHi					; |
		SBC #$00					; |
		STA !Ex_YHi,x					;/
		STZ !Ex_Data1,x					;\
		STZ !Ex_Data2,x					; | clear excess data
		STZ !Ex_Data3,x					; |
		.NoFire						;/


		PHB						; push bank
		LDA #$00 : PHA : PLB				; bank = 00
		LDA !MarioWater : BNE .CallReturn		; none of this while in water
		PHK : PEA .CallReturn-1				; RTL address
		PEA $84CF-1					; RTS address: point to an RTL
		PEA $D7E4-1					; Y speed influence address


		LDA !P2CoyoteTime : BMI ..normal		;\
		AND #$7F : BEQ ..normal				; | check for coyote time
		LDA !MarioInAir : BEQ ..normal			;/
		INC !MarioDashTimer				; during coyote time, mario's dash timer does not decrement
		LDA $16						;\
		ORA $18						; | let mario jump out of coyote time
		BPL ..normal					; |
		JML $00D5F9					;/
		..normal					;\ normal controls routine
		JML $00D5F2					;/

		.CallReturn					; return here
		LDA !MarioXSpeed : STA !P2XSpeed		;\ pass speeds back again
		LDA !MarioYSpeed : STA !P2YSpeed		;/


		LDA !MarioWater : BEQ +
		LDA !MarioInAir : BNE ++
	+	JSL $00CEB1					; mario image update code
	++	PLB						; restore bank


		JSL CORE_COYOTE_TIME

		.PhysicsDone
		LDA !MarioBlocked
		AND #$03 : BEQ +
		STZ !P2HangFromLedge				; clear this if mario touches no walls
		+


		.End
		LDX !P2Carry : BEQ +
		DEX
		LDA !MarioImg
		LDY #$00
		CMP #$25 : BEQ ++
		CMP #$44 : BEQ ++
		CMP #$0F : BEQ ++
		CMP #$45 : BNE +
	++	CPY !MarioTurnTimer : BCC ++
		STY !MarioTurnTimer
		STY !P2TurnTimer
	++	LDA !P2XPosLo : STA $3220,x
		LDA !P2XPosHi : STA $3250,x
		+


		JSR MarioGraphics				; $00E2BD, transcribed and modified, this code will draw mario and load his GFX


		STZ $7402					; clear "mario on note block" flag

		RTS









	.FireSpeed
	db $03,$FD			; indexed by input (reversed dir if no input)
	.FireX
	db $08,$00			; added, indexed by input (reversed dir if no input)
	.FireY
	db $00,$08,$08,$08		; subtracted, indexed by $19


	.ClippingSmall
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $06,$06,$0A,$0A		; R/L/R/L
	db $10,$10,$00,$08		; D/D/U/C

	.ClippingBig
	; X
	db $0E,$01,$0E,$01		; R/L/R/L
	db $04,$0B,$08,$08		; D/D/U/C
	; Y
	db $FF,$FF,$0A,$0A		; R/L/R/L
	db $10,$10,$F8,$02		; D/D/U/C



; format:
; - !MarioImg value when not holding object
; - !MarioImg value when holding object
; - frame count
; - next frame

	.SwimGFX
	db $16,$17			; 00
	db $FF,!Mar_SwimSlow
	db $16,$17			; 01
	db $08,!Mar_SwimSlow+2
	db $18,$19			; 02
	db $08,!Mar_SwimSlow+3
	db $1A,$1B			; 03
	db $08,!Mar_SwimSlow

	db $17,$17			; 04
	db $08,!Mar_SwimFast+1
	db $19,$19			; 05
	db $08,!Mar_SwimFast+2
	db $1B,$1B			; 06
	db $08,!Mar_SwimFast



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	MARIO SUBROUTINES	;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		.JumpHeight
		LSR #2						;\ original code
		AND #$FE					;/
		CMP #$0E					;\ cap at 14
		BCC $02 : LDA #$0E				;/
		RTL						; return

		.SpeedBoost
		LDA !MarioInAir : BNE ..uncap
		..capspeed
		LDA !MarioXSpeed
		SEC : SBC $D535,y
		JML $00D748
		..uncap
		LDA !MarioXSpeed
		SEC : SBC $D535,y
		BEQ ..return
		EOR $D535,y : BMI ..capspeed
		..return
		JML $00D7A2





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


		.Cape2
		LDA !MarioUpgrades
		AND #$04 : BEQ ..No
	..Yes	JML $00E401
	..No	JML MarioCapeReturn


		.Bounce
		LDA !MarioClimbing : BNE ..return
		LDA #$D0
		BIT $15
		BPL $02 : LDA #$A8
		STA !MarioYSpeed
		..return

		PHY						;\
		LDA !CurrentMario : BEQ +			; |
		DEC A						; | index to mario regs
		LSR A						; |
		ROR A						; |
		TAY						;/
		LDA !P2FireCharge-$80,y : BNE ++		; check if mario has a fire charge
		LDA #$01 : STA !P2FireCharge-$80,y		;\
		LDA #!MarioFlashPal : STA !P2FlashPal-$80,y	; | if he doesn't, give him one and make him flash white
	++	PLY						; |
	+	RTL						;/




; $00E2BD - $00E4B8 + the JSR at $00F636 - $00F69E
MarioGraphics:
		LDA !MultiPlayer : BEQ .ThisOne			; animate at 60fps on single player
		LDA $14
		AND #$01
		CMP !CurrentPlayer : BEQ .ThisOne
		.OtherOne
		LDA !P2Entrance
		REP #$30
		BEQ ..backup
		LDA.w #ANIM_16x32TM : BRA ..loadbackup
		..backup
		LDA !P2BackupTilemap
		..loadbackup
		STA $0E
		JMP GRAPHICS
		.ThisOne
		LDA !P2ExternalAnimTimer : BNE ..external	;\
		STZ !P2ExternalAnim				; | check for external anim
		BRA ..noexternal				;/
		..external					;\
		DEC !P2ExternalAnimTimer			; |
		REP #$30					; | enforce external anim while external anim timer is set
		LDA !P2ExternalAnim : BRA .Vanilla_load		; |
		..noexternal					;/


		LDA !P2HurtTimer : BEQ .NoHurt
		LDA !P2HP : BNE .Hurt
		STZ !P2ShrinkTimer
		LDA #$3E : STA !MarioImg
		BRA .Vanilla
		.Hurt
		LDA #$2F : STA !MarioAnimTimer
		LDA !P2HurtTimer
		CMP #$0C : BCC ..react
		..anticipate
		REP #$30
		LDA.w #ANIM_16x32TM : STA $0E
		LDA.w #ANIM_HurtDyn00 : BRA ++
		..react
		REP #$30
		LDA.w #ANIM_24x32TM : STA $0E
		LDA.w #ANIM_HurtDyn01 : BRA ++
		.NoHurt
		LDA !P2HangFromLedge : BEQ .NoHang
		REP #$30
		LDA.w #ANIM_16x32TM : STA $0E
		LDA.w #ANIM_HangDyn : BRA ++
		.NoHang


		.Vanilla
		REP #$30
		LDA !MarioImg
		..load
		AND #$00FF
		ASL #2
		TAY
	-	LDA.w ANIM+0,y : BNE +
		LDY #$0000 : BRA -
	+	STA $0E
		LDA.w ANIM+2,y
	++	STA $04
		BNE .UpdateGFX
		JMP GRAPHICS


		.UpdateGFX
		LDY.w #!File_Mario				;\ get address
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

		LDY !P2HurtTimer : BNE .BigAddress		; hurt animation always uses big mario address
		LDY !P2ShrinkTimer : BNE .BigAddress		; shrink animation always uses big mario address

		LDY !P2HP					;\
		CPY #$05 : BCS .BigAddress			; |
		STA $00						; |
		AND #$01E0					; |
		STA $02						; X tile
		LDA $00						; |
		AND #$7E00					; | recalculate address for small mario
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
		CLC : ADC #$0200				; | (multiply by .75 and add 0x3800 for small ario)
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


		LDY !P2HurtTimer : BNE .BigFormat		;\
		LDY !P2HP					; | conditions for big format
		CPY #$05 : BCS .BigFormat			; |
		LDY !P2ShrinkTimer : BNE .BigFormat		;/
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
		SEP #$30
		JSL CORE_FLASHPAL
		LDA !P2Status : BNE .DrawTiles
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2Invinc
		CMP #$02 : BCC .DrawTiles
		AND #$06 : BEQ .FireFlash

		.DrawTiles
		REP #$20
		LDA $0E : STA !P2BackupTilemap
		BEQ .FireFlash
		STA $04
		LDY !P2HurtTimer : BNE .Big		;\
		LDY !P2ShrinkTimer : BNE .Big		; | conditions for big mario tilemap
		LDY !P2HP				; |
		CPY #$05 : BCS .Big			;/
		CLC : ADC ($04)				;\
		INC #2					; | small mario tilemap
		STA $04					;/

	.Big	SEP #$20
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
		..noglow

		.Return								;\ return
		RTS								;/





	ANIM:
		; VANILLA STUFF
		dw .16x32TM,.IdleDyn		; 00
		dw .16x32TM,.WalkDyn00		; 01
		dw .16x32TM,.WalkDyn01		; 02
		dw .16x32TM,.LookUpDyn		; 03
		dw .24x32TM,.RunDyn00		; 04
		dw .24x32TM,.RunDyn01		; 05
		dw .24x32TM,.RunDyn02		; 06
		dw .16x32TM,.CarryIdleDyn	; 07
		dw .16x32TM,.CarryWalkDyn00	; 08
		dw .16x32TM,.CarryWalkDyn01	; 09
		dw .16x32TM,.CarryLookUpDyn	; 0A
		dw .16x32TM,.RiseDyn		; 0B
		dw .24x32TM,.LongJumpDyn	; 0C
		dw .16x32TM,.TurnDyn		; 0D
		dw .16x32TM,.KickDyn		; 0E
		dw .16x32TM,.FaceFrontDyn	; 0F
		dw $0000,$0000			; 10
		dw $0000,$0000			; 11
		dw $0000,$0000			; 12
		dw $0000,$0000			; 13
		dw $0000,$0000			; 14
		dw .16x32TM,.ClimbDyn		; 15
		dw .24x32TM,.SwimDyn00		; 16
		dw .24x32TM,.SwimFastDyn00	; 17
		dw .24x32TM,.SwimDyn01		; 18
		dw .24x32TM,.SwimFastDyn01	; 19
		dw .24x32TM,.SwimDyn02		; 1A
		dw .24x32TM,.SwimFastDyn02	; 1B
		dw .16x32TM,.SlideDyn		; 1C
		dw .16x32TM,.CarryCrouchDyn	; 1D
		dw $0000,$0000			; 1E
		dw $0000,$0000			; 1F
		dw $0000,$0000			; 20
		dw $0000,$0000			; 21
		dw $0000,$0000			; 22
		dw $0000,$0000			; 23
		dw .16x32TM,.FallDyn		; 24
		dw .16x32TM,.FaceBackDyn	; 25
		dw .16x32TM,.VictoryDyn		; 26
		dw $0000,$0000			; 27
		dw $0000,$0000			; 28
		dw $0000,$0000			; 29
		dw $0000,$0000			; 2A
		dw $0000,$0000			; 2B
		dw $0000,$0000			; 2C
		dw $0000,$0000			; 2D
		dw $0000,$0000			; 2E
		dw $0000,$0000			; 2F
		dw .16x32TM,.CutsceneDyn03	; 30 (exploded 1)
		dw .16x32TM,.CutsceneDyn04	; 31 (exploded 2)
		dw .16x32TM,.CutsceneDyn02	; 32 (action pose)
		dw .16x32TM,.CutsceneDyn00	; 33 (looking off 1)
		dw .16x32TM,.CutsceneDyn01	; 34 (looking off 2)
		dw .16x32TM,.HammerDyn00	; 35
		dw .16x32TM,.HammerDyn01	; 36
		dw .16x32TM,.HammerDyn02	; 37
		dw $0000,$0000			; 38
		dw $0000,$0000			; 39
		dw .16x32TM,.HammerDyn02	; 3A
		dw .16x32TM,.HammerDyn02	; 3B
		dw .16x32TM,.CrouchDyn		; 3C
		dw .16x32TM,.ShrinkDyn		; 3D
		dw .16x32TM,.DeadDyn		; 3E
		dw .16x32TM,.FireThrowDyn	; 3F
		dw $0000,$0000			; 40
		dw $0000,$0000			; 41
		dw .32x32TM,.BalloonDyn		; 42
		dw .32x32TM,.BalloonDyn		; 43
		dw .16x32TM,.FaceBackDyn	; 44
		dw .16x32TM,.FaceFrontDyn	; 45
		dw .16x32TM,.IdleDyn		; 46

		; CUSTOM STUFF
		dw .16x32TM,.HurtDyn00		; 47
		dw .24x32TM,.HurtDyn01		; 48
		dw .16x32TM,.HangDyn		; 49




	.16x32TM
	dw $0008			; big mario
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	dw $0008			; small mario
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	.16x32TMX
	dw $0008			; big mario
	db $6E,$00,$F0,!P2Tile1
	db $6E,$00,$00,!P2Tile3
	dw $0008			; small mario
	db $6E,$00,$F8,!P2Tile1
	db $6E,$00,$00,!P2Tile3


	.24x32TM
	dw $0010			; big mario
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1
	dw $0010			; small mario
	db $2E,$00,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1


	.32x32TM
	dw $0010			; big mario
	db $2E,$F8,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4
	dw $0010			; small mario
	db $2E,$F8,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4


macro MarDyn(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro


	.IdleDyn	%MarDyn(2, $000)
	.WalkDyn00	%MarDyn(2, $002)
	.WalkDyn01	%MarDyn(2, $004)

	.LookUpDyn	%MarDyn(2, $006)

	.CrouchDyn	%MarDyn(2, $008)

	.RiseDyn	%MarDyn(2, $00A)
	.FallDyn	%MarDyn(2, $00C)

	.SlideDyn	%MarDyn(2, $00E)

	.CarryIdleDyn	%MarDyn(2, $040)
	.CarryWalkDyn00	%MarDyn(2, $042)
	.CarryWalkDyn01	%MarDyn(2, $044)
	.CarryLookUpDyn	%MarDyn(2, $046)
	.CarryCrouchDyn	%MarDyn(2, $048)

	.FaceBackDyn	%MarDyn(2, $08E)

	.FaceFrontDyn	%MarDyn(2, $08C)

	.KickDyn	%MarDyn(2, $04E)

	.RunDyn00	%MarDyn(3, $080)
	.RunDyn01	%MarDyn(3, $083)
	.RunDyn02	%MarDyn(3, $086)

	.LongJumpDyn	%MarDyn(3, $089)

	.TurnDyn	%MarDyn(2, $04C)

	.VictoryDyn	%MarDyn(2, $04A)

	.SwimDyn00	%MarDyn(3, $0C0)
	.SwimDyn01	%MarDyn(3, $0C3)
	.SwimDyn02	%MarDyn(3, $0C6)
	.SwimFastDyn00	%MarDyn(3, $100)
	.SwimFastDyn01	%MarDyn(3, $103)
	.SwimFastDyn02	%MarDyn(3, $106)

	.ClimbDyn	%MarDyn(2, $10B)

	.HammerDyn00	%MarDyn(2, $140)
	.HammerDyn01	%MarDyn(2, $142)
	.HammerDyn02	%MarDyn(2, $144)

	.CutsceneDyn00	%MarDyn(2, $146)
	.CutsceneDyn01	%MarDyn(2, $148)
	.CutsceneDyn02	%MarDyn(2, $14A)
	.CutsceneDyn03	%MarDyn(2, $14C)
	.CutsceneDyn04	%MarDyn(2, $14E)
	.CutsceneDyn05	%MarDyn(2, $180)
	.CutsceneDyn06	%MarDyn(2, $182)

	.BalloonDyn	%MarDyn(4, $184)

	.SpinDyn00	%MarDyn(2, $1C0)
	.SpinDyn01	%MarDyn(4, $1C2)
	.SpinDyn02	%MarDyn(2, $1C6)
	.SpinDyn03	%MarDyn(4, $1C8)
	.SpinDyn04	%MarDyn(2, $1CC)
	.SpinDyn05	%MarDyn(2, $1CE)
	.SpinDyn06	%MarDyn(4, $200)

	.FlutterDyn00	%MarDyn(2, $204)
	.FlutterDyn01	%MarDyn(2, $206)
	.FlutterDyn02	%MarDyn(2, $208)

	.HurtDyn00	%MarDyn(2, $1C4)
	.HurtDyn01	%MarDyn(3, $188)
	.ShrinkDyn	%MarDyn(2, $18B)
	.DeadDyn	%MarDyn(2, $18E)

	.FireThrowDyn	%MarDyn(2, $1C0)

	.HangDyn	%MarDyn(2, $1C2)




	StarKill:
		LDY #$00
		LDA $94
		SEC : SBC $3220,x
		LDA $95
		SBC $3250,x
		BPL $01 : INY
		STZ $01

		PHX
		TYX
		LDA.l .Xdisp,x : STA $00
		BPL $02 : DEC $01
		LDA $78D2
		CMP #$07
		BCC $03 : INC $78D2
		TAX
		LDA.l CORE_STOMPSOUND_TABLE,x : STA !SPC1
		PLX

		%Ex_Index_Y()
		LDA #$02+!SmokeOffset : STA !Ex_Num,y	; > Smoke type
		LDA $94					;\
		CLC : ADC $00				; | Smoke Xpos lo
		STA !Ex_XLo,y				;/
		LDA $95					;\
		ADC $01					; | Smoke Xpos hi
		STA !Ex_XHi,y				;/
		LDA $96					;\
		CLC : ADC #$10				; | Smoke Ypos lo
		STA !Ex_YLo,y				;/
		LDA $97					;\
		ADC #$00				; | Smoke Ypos hi
		STA !Ex_YHi,y				;/
		LDA #$08 : STA !Ex_Data1,y		; > Smoke timer
		LDA #$02 : STA $3230,x
		LDA #$E8 : STA !SpriteYSpeed,x
		LDA !MarioXSpeed : STA !SpriteXSpeed,x
		RTL

		.Xdisp
		db $F6,$0A





macro CommentOut()
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
	..P1	LDA !P2HangFromLedge : BEQ ..Init
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
		LDA #$30 : STA !P2HangFromLedge			; also used as PP bits for Mario's tiles
		BRA ..Stick

		..Main
		LDY !MarioDirection
		LDA.w ..Bit,y
		AND $15 : BNE ..Stick
		STZ !P2HangFromLedge
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
		STZ !P2HangFromLedge
		LDA #$2B : STA !SPC1				; jump SFX

	..R	SEP #$20
		PLX
		PLB
		LDA !MarioBlocked				;\ overwritten code
		AND #$03					;/
		RTL						; return


	..Offset
	dw $FFF8,$0018

	..X
	db $0D,$02

	..Bit
	db $02,$01



		.Fireball
	BRA ..Fire
;		CMP #$03 : BEQ ..Fire
;		LDA !MarioUpgrades
;		AND #$40 : BNE ..Fire
	..No	JML $00D0AD
	..Fire	LDA !P2FireCharge : BEQ ..No			; only allow if mario has a fire charge
		JML $00D085


		.TacticalFire
		STZ !P2FireCharge				; consume mario's fire charge
		LDA !MarioUpgrades
		AND #$08 : BEQ ..30
		LDA $15
		AND #$08 : BEQ ..30
	..C0	LDA #$C0 : STA !Ex_YSpeed,x
		RTL
	..30	LDA #$30 : STA !Ex_YSpeed,x
		RTL



		.AirHook
		JSR .Coyote
		LDA !P2CoyoteTime-$80,x
		BEQ ..Normal
		BMI ..Normal

		..Ground
		STZ !P2FlareDrill-$80,x
		JML $00D5F9					; ground


		..Normal
		LDA !MarioInAir : BEQ ..Ground
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




		.Coyote
		LDA !CurrentMario
		LDX #$00
		CMP #$02
		BNE $02 : LDX #$80
		LDA !MarioInAir : BEQ ..Ground

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


		.ExternalAnim
		LDA !CurrentMario : BEQ ..NoExternal
		DEC A
		CLC : ROL #2
		TAX
		LDA !P2ExternalAnimTimer-$80,x			;\
		BEQ ..ClearExternal				; |
		DEC A						; |
		STA !P2ExternalAnimTimer-$80,x			; | Enforce external animations for Mario
		LDA !P2ExternalAnim-$80,x			; |
		STA !MarioImg					; |
		LDA !P2ExternalCapeAnim-$80,x : STA $73DF	; > enforce cape too
		BRA ..NoExternal				;/

		..ClearExternal
		STZ !P2ExternalAnim-$80,x		; Clear once timer runs out
		STZ !P2ExternalCapeAnim-$80,x

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
		LDA !P2FireCharge				;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire		;/
	;	LDA $19						;\
	;	CMP #$03					; | fire palette if mario has fire flower
	;	BNE $02 : LDY.b #!palset_mario_fire		;/


		LDA !P2FireCharge				;\ fire palette if mario has palette charge
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

		..override
		RTL


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
		LDA !MarioWater : BEQ ..Water		; water splash animation
		LDA #$FC				;\
		CMP !MarioYSpeed			; | I don't know what this does but smw does it
		BMI $02 : STA !MarioYSpeed		;/
		LDA #$01
		STA $73FA				; allow jump
		STA !MarioWater
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
		JSL CORE_GENERATE_BLOCK
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
		BEQ $03 : DEC $7495,x		; | (note the BNE, $7495 is not decremented here)
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
	-	LDA $74A8,x			; | auto-decrement $74A9-$74AE (only notable ones are $74AD and $74AE, the P switch timers)
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
		dw .Normal			; 00 - MAIN
		dw .PowerDown			; 01 - shorten
		dw .MushroomGet			; 02 - shorten
		dw .CapeGet			; 03 (irrelevant)
		dw .FlowerGet			; 04 - shorten
		dw .HorizontalPipe		; 05
		dw .VerticalPipe		; 06
		dw .SlantPipe			; 07
		dw .YoshiWings			; 08 (irrelevant)
		dw .Death			; 09
		dw .EnterCastle			; 0A (irrelevant)
		dw .Freeze			; 0B
		dw .RandomMovement		; 0C (irrelevant)
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
		LDY !MarioInAir : BNE .CODE_00CD72
		LDA $8B
		AND #$04 : BEQ .CODE_00CD79
.CODE_00CD72	LDA $8B : STA !MarioClimbing
		JMP .CODE_00DB17		; mario climb handler

.CODE_00CD79	LDA !MarioWater : BEQ .CODE_00CD82
		JSR .CODE_00D988		; mario swim handler
		; BRA to next yoshi check
		RTS

.CODE_00CD82	JSR .CODE_00D5F2		; > controls, includes jump/spin jump
		JSR .CODE_00D062		; > shoot fireball + cape spin routine
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
		RTS



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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


macro CringeOut()


; transcription of mario collision code
; oddity:
; - $8A-$8F is used as scratch RAM during this code


; needed:
;	- get interaction point
;		- get tile num then acts like setting for that interaction point
;		- decode meaning of tile
;		- update player status


; 00E92B

		; 00EAA6
		STZ $73E5			; mario only, animation timer index based on touched material
		STZ !P2Blocked			; clear blocked status
		STZ $73E1			;\ mario has TWO slope registers! (first one might only be used for flight)
		STZ $73EE			;/
		STZ $8A				;\ used as scratch here for whatever reason
		STZ $8B				;/
		STZ $740E			; layer 2 touched flag

		LDA !MarioPhaseFlag : BEQ .Main
		; JSR to platform code 00EE1D
		BRA .End

		; 00E938
		.Main
		LDA $73EF : STA $8D		;\ bits for interacting with BG1/BG2
		STZ $73EF			;/

		LDA !MarioInAir : STA $8F		; some mario air status
		LDA $5B : BPL .Layer2Done

		.InteractLayer2
		AND #$82			;\ NOTE: bits 01 and 02 should probably be scrapped (always 0)
		STA $8E				;/
		LDA #$01 : STA $7933		; > processing layer 2
		REP #$20			;\
		LDA !P2XPosLo : PHA		; |
		CLC : ADC $26			; |
		STA !P2XPosLo			; | push and adjust coords
		LDA !P2YPosLo : PHA		; |
		CLC : ADC $28			; |
		STA !P2YPosLo			; |
		SEP #$20			;/
		JSR .InteractLayer		; main call
		REP #$20			;\
		PLA : STA !P2YPosLo		; | restore coords
		PLA : STA !P2XPosLo		; |
		SEP #$20			;/
		.Layer2Done


		.InteractLayer1
		ASL $73EF			; no idea
		LDA $5B				;\
		AND #$41			; | NOTE: bits 01 and 02 should always be 0
		STA $8E				;/ (bit 40 is "interact with layer 1" flag)
		ASL A : BMI .Layer1Done		; if bit 40 was set, do not interact with layer 1
		STZ $7933			; > processing layer 1
		ASL $8D				; no idea, match $73EF?
		JSR .InteractLayer		; main call
		.Layer1Done

		; scrapped side exit check


		; 00E9A1
		.End
		LDA $7E
		CMP #$F0 : BCS .00EA08
		LDA !P2Blocked
		AND #$03 : BNE .NoWall
		REP #$20
		LDY #$00
		LDA $7462
		CLC : ADC #$00E8
		CMP !P2XPosLo
		BEQ .00E9C8
		BMI .00E9C8
		INY
		LDA !P2XPosLo
		SEC : SBC #$0008
		CMP $7462
	.00E9C8	SEP #$20
		BEQ .NoWall
		BPL .NoWall
		LDA !EnableHScroll : BNE .00E9F6
		LDA #$80 : TSB !MarioBlocked
		REP #$20
		LDA !BG1XSpeed
		LSR #4
		SEP #$20
		STA $00
		SEC : SBC !P2XSpeed
		EOR $E90E,y			; some table in bank 00
		BMI .00E9F6
		LDA $00 : STA !P2XSpeed		; speed override
		LDA $744E : STA !P2XFraction	; update fraction bits
	.00E9F6	LDA $E90A,y : TSB !P2Blocked

		.NoWall
		LDA !P2Blocked
		AND #$1C
		CMP #$1C : BNE .00EA0D
		LDA $7471 : BNE .00EA0D		; mario on solid sprite
	.00EA08	JSR .00F629			; kill mario, then clear his controller regs
		BRA .00EA32

		.00EA0D
		LDA !P2Blocked
		AND #$03 : BEQ .StillNoWall
		AND #$02 : TAY
		REP #$20
		LDA !P2XPosLo
		CLC : ADC $E90D,y
		STA !P2XPosLo
		SEP #$20
		LDA !P2Blocked : BMI .StillNoWall
		LDA #$03 : STA $73E5		; unknown
		LDA !P2XSpeed
		EOR $E90D,y : BPL .StillNoWall
		STZ !P2XSpeed
		.StillNoWall

		LDA !MarioBehind
		CMP #$01 : BNE .00EA42
		LDA $8B : BNE .00EA42
		STZ !MarioBehind
	.00EA42	STZ $73FA			; CAN JUMP OUT OF WATER FLAG
		LDA !WaterLevel : BNE .WaterLevel
		LSR $8A : BCC .00EAA3
		LDA !MarioWater : BNE .00EA65
		LDA !P2YSpeed : BMI .00EA65
		LSR $8A : BCC .00EAA5
		JSR .00FDA5			; generate water splash code
		STZ !P2YSpeed
		.WaterLevel
		LDA #$01 : STA !MarioWater
	-	JMP .00FD08			; generate bubble code

		.00EA65
		LSR $8A : BCS .WaterLevel
		LDA !MarioWater : BEQ .00EAA5
		LDA #$FC
		CMP !P2YSpeed
		BMI $03 : STA !P2YSpeed
		INC $73FA			; CAN JUMP OUT OF WATER FLAG
		LDA $6DA3
		AND #$88
		CMP #$88 : BNE -
		LDA $6DA5 : BPL .NoSpin
		INC A
		STA !MarioSpinJump
		LDA #$04 : STA !SPC4		; spin jump SFX
	.NoSpin	LDA !P2Blocked
		AND #$08 : BNE -
		JSR .00FDA5			; generate water splash code
		LDA #$0B : STA !MarioInAir		; unknown, mario air status
		LDA #$AA : STA !P2YSpeed	; jump out of water
	.00EAA3	STZ !MarioWater
	.00EAA5	RTS






		.InteractLayer
		LDA !P2YPosLo
		AND #$0F
		STA $90
		LDA !MarioWallWalk : BNE .WallWalking
		JMP .Normal

		.WallWalking
		AND #$01
		TAY
		LDA !P2XSpeed
		SEC : SBC $EAB9,y
		EOR $EAB9,y
		BMI .EndWallWalk
		LDA !MarioInAir
		ORA $748F			; special mario carry flag
		ORA !MarioDucking
		BNE .EndWallWalk
		LDA !MarioWallWalk
		CMP #$06 : BCS .Perpendicular
		LDX $90
		CPX #$08 : BCC .ReturnWallWalk
		CMP #$04 : BCS .CancelWallWalk
		ORA #$04
		STA !MarioWallWalk
	-	LDA !P2XPosLo
		AND #$F0
		ORA #$08
		STA !P2XPosLo
		RTS

		.Perpendicular
		LDX #$60
		TYA
		BEQ $02 : LDX #$66
		JSR .00EFE8			; unknown
		LDA $19 : BNE .Big
	.Small	INX #2
		BRA +
	.Big	JSR .00EFE8			; unknown
	+	JSR .CheckBlock			; unknown
		BNE -
		LDA #$02 : TRB !MarioWallWalk
		RTS

		.00EB42
		LDA !MarioWallWalk
		AND #$01
		TAY

		.EndWallWalk
		LDA $EABB,y : STA !P2XSpeed
		TYA
		ASL A
		TAY
		REP #$20
		LDA !P2XPosLo
		CLC : ADC $EABD,y
		STA !P2XPosLo
		LDA #$0008
		LDY $19
		BEQ $03 : LDA #$0010
		CLC : ADC !P2YPosLo
		STA !P2YPosLo
		SEP #$20
		LDA #$24 : STA !MarioInAir
		LDA #$E0 : STA !P2YSpeed
		.CancelWallWalk
		STZ !MarioWallWalk
		.ReturnWallWalk
		RTS



		; 00EB77
		.Normal
		LDX #$00			;\
		LDA $19 : BEQ +			; |
		LDA !MarioDucking		; |
		BNE $02 : LDX #$18		; | index for big mario = 18
	+	LDA !P2XPosLo			; |
		AND #$0F			; |
		TAY				; |
		CLC : ADC #$08			; |
		AND #$0F			; |
		STA $92				; | calculate position within block
		STZ $93				; |
		CPY #$08 : BCC +		; |
		TXA				; |
		ADC #$0B			; | checking left/right depends on mario's position within block, not his speed
		TAX				; | it checks the tile he could overlap with horizontally
		INC $93				; | if mario should check left, add C to index
	+	LDA $90				; |
		CLC : ADC $E8A4,x		; |
		AND #$0F			; |
		STA $91				;/

		; 00EBAF
		JSR .CheckBlock			; first check: mario's core
		BEQ .NotCrushed			; if this is touched, mario fucking dies
		CPY #$11 : BCC .00EC24
		CPY #$6E : BCC .00EBC9
		TYA
		JSL $00F04D			; which tiles that are solid (but not able to crush mario) OUTSIDE of the 111-16E range
		BCC .00EC24
		LDA #$01 : TSB $8A
		BRA .00EC24

		.00EBC9
		INX #4				; skip side checks
		TYA				;\
		LDY #$00			; |
		CMP #$1E : BEQ .00EBDA		; | if tile was NOT 11E (brick) or 152 (invisible solid block), set index to 2
		CMP #$52 : BEQ .00EBDA		; | index = 2 will set collision to 11, killing mario by setting the M/crush flag
		LDY #$02			;/
	.00EBDA	JMP .00EC6F			; go to set flag





		; 00EBDD
		.NotCrushed
		CPY #$9C : BNE +
		LDA !HeaderTileset
		CMP #$01 : BEQ .00EC06
	+	CPY #$20 : BEQ .00EC01
		CPY #$1F : BEQ .00EBFD
		LDA !PSwitchTimer : BEQ .00EC21
		CPY #$28 : BEQ .00EC01
		CPY #$27 : BNE .00EC21
	.00EBFD	LDA $19 : BNE .00EC24
	.00EC01	LDA !P2XPosLo			; 00F443
		CLC : ADC #$04
		AND #$0F
		CMP #$08 : BCS .00EC24
	.00EC06	LDA $8F : BNE .00EC24
		LDA $6DA7
		AND #$08 : BEQ .00EC24		; door?
		LDA #$0F : STA !SPC4		; door sfx
		LDA $741A			;\
		INC A				; | increment room counter, but cap it at 255
		BNE $01 : DEC A			; | (no wrap)
		STA $741A			;/
		LDA #$0F : STA !GameMode	; load level
		LDA #$0D : STA !MarioAnim	; enter door animation
		; clear buttons
		BRA .00EC24

		.00EC21
		JSR .CheckCollectible		; contact collectible
	.00EC24	JSR .CheckBlock			;
		BEQ .00EC35
		CPY #$11 : BCC .00EC3A
		CPY #$6E : BCS .00EC3A
		INX #2
		BRA .00EC4E

		.00EC35
		LDA #$10
		JSR .CheckMidway
	.00EC3A	JSR .CheckBlock
		BNE .00EC46
		LDA #$08
		JSR .CheckMidway
		BRA .00EC8A

		.00EC46
		CPY #$11 : BCC .00EC8A
		CPY #$6E : BCS .00EC8A
	.00EC4E	LDA !MarioDirection
		CMP $93 : BEQ .00EC5F		; if different direction...
		JSR .00F3C4			; pipe check
		PHX
		JSR .CheckCarryable
		LDY $7693			; map16 num
		PLX
	.00EC5F	LDA #$03 : STA $73E5		; SOME MARIO ANIMATION TIMER
		LDY $93
		LDA !P2XPosLo
		AND #$0F
		CMP $E911,y : BEQ .00EC8A
	.00EC6F	LDA $7402 : BEQ .00EC7B		; BOUNCING ON NOTE BLOCK TIMER
		LDA $7693			; map16 num
		CMP #$52 : BEQ .00EC8A
	.00EC7B	LDA $E90A,y : TSB !P2Blocked
		AND #$03
		TAY
		LDA $7693			; map16 num
		JSL $00F127			; tileset-based hurt code
		; INSERT: generic hurt codes for tileset-based hazards
	.00EC8A	JSR .CheckBlock
		BNE .00ECB1
		LDA #$02
		JSR .00F2C2
		LDY !P2YSpeed : BPL .00ECA3
		LDA $7693
		CMP #$21 : BCC .00ECA3
		CMP #$25 : BCC .00ECA6
	.00ECA3	JMP .00ED4A

		.00ECA6
		SEC : SBC #$04
		LDY #$00
		JSL $00F17F
		BRA .00ED0D

		.00ECB1
		CPY #$11 : BCC .00ECA3
		CPY #$6E : BCC .00ECFA
		CPY #$D8 : BCC .00ECDA
		REP #$20
		LDA $98
		CLC : ADC #$0010
		STA $98
		JSR .00F461			; alt form of check tile
		BEQ .00ECF8
		CPY #$6E : BCC .00ED4A
		CPY #$D8 : BCS .00ED4A
		LDA $91
		SBC #$0F
		STA $91
	.00ECDA	TYA
		SEC : SBC #$6E
		TAY
		REP #$20
		LDA [$82],y
		AND #$00FF
		ASL #4
		SEP #$20
		ORA $92
		REP #$10
		TAY
		LDA $E632,y
		SEP #$20
		BMI .00ED0F
	.00ECF8	BRA .00ED4A

		.00ECFA
		LDA #$02
		JSR .00F3E9			; vertical pipe check
		TYA
		LDY #$00
		JSL $00F127			; tileset-based hurt code
		; INSERT: generic tileset-based hurt code
		LDA $7693
		CMP #$1E : BEQ .00ED3B
	.00ED0D	LDA #$F0
		CLC : ADC $91
		BPL .00ED4A
		CMP #$F9 : BCS .00ED28
		LDY !MarioInAir : BNE .00ED28
		LDA !P2Blocked
		AND #$FC
		ORA #$09
		STA !P2Blocked
		STZ !P2XSpeed
		BRA .00ED3B

		.00ED28
		LDY !MarioInAir : BEQ .00ED37
		EOR #$FF
		CLC : ADC !P2YPosLo
		STA !P2YPosLo
		BCC $03 : INC !P2YPosHi
	.00ED37	LDA #$08 : TSB !P2Blocked
	.00ED3B	LDA !P2YSpeed : BPL .00ED4A
		STZ !P2YSpeed
		LDA !SPC1 : BNE .00ED4A
		INC A
		STA !SPC1			; bonk SFX, but only if no other SFX has been set this frame
	.00ED4A	JSR .CheckBlock
		BNE .00ED52
		JMP .00EDDB

		.00ED52
		CPY #$6E : BCS .00ED5E
		LDA #$03
		JSR .00F3E9			; vertical pipe check
		JMP .00EDF7			; ???

		.00ED5E
		CPY #$D8 : BCC .00ED86
		CPY #$FB : BCC .00ED69
		JMP .00F629			; kill mario, then clear his controller regs

		.00ED69
		REP #$20
		LDA !P2XPosLo
		SEC : SBC #$0010
		STA $98
		JSR .00F461			; alt form of check tile
		BEQ .00EDE9
		CPY #$6E : BCC .00EDE9
		CPY #$D8 : BCS .00EDE9
		LDA $90
		ADC #$10
		STA $90
	.00ED86	LDA !HeaderTileset
		CMP #$03 : BEQ .00ED91
		CMP #$0E : BNE .00ED95
	.00ED91	CPY #$D2 : BCS .00EDE9
	.00ED95	TYA
		SEC : SBC #$6E
		TAY
		LDA [$82],y
		PHA
		REP #$20
		AND #$00FF
		ASL #4
		SEP #$20
		ORA $92
		PHX
		REP #$10
		TAX
		LDA $90
		SEC : SBC $E632,x
		BPL $03 : INC $73EF		; layer was touched this frame?
		SEP #$10
		PLX
		PLY
		CMP $E51C,y : BCS .00EDE9
		STA $91
		STZ $90
		JSR .00F005			; wall walk triangle interaction
		; INSERT: wall walk triangle code
		CPY #$1C : BCC .00EDD5
		LDA #$08 : STA $74A1		; SOME MARIO TURNING AROUND TIMER
		JMP .00EED1

		.00EDD5
		JSR .00EFBC			; conveyor code ???
		JMP .00EE85			; switch palace code ???

		.00EDDB
		CPY #$05 : BNE .00EDE4
		JSR .00F629			; kill mario, then clear his controller regs
		BRA .00EDE2

		.00EDE4
		LDA #$04
		JSR .00F2C2			; collectible check
	.00EDE9	JSR .CheckBlock
		BNE .00EDF3
		JSR .00F309			; collectible check
		BRA .00EE1D			; go to platform code?

		.00EDF3
		CPY #$6E : BCS .00EE1D
		LDA !P2YSpeed : BMI .00EE39
		LDA !HeaderTileset
		CMP #$03 : BEQ .00EE06
		CMP #$0E : BNE .00EE11
	.00EE06	LDY $7693			; map16 num
		CPY #$59 : BCC .00EE11
		CPY #$5C : BCC .00EE1D
	.00EE11	LDA $90
		AND #$0F
		STZ $90
		CMP #$08
		STA $91
		BCC .00EE3A

	; platform code??
	.00EE1D	LDA $7471 : BEQ .00EE2D
		LDA !P2YSpeed : BMI .00EE2D
		STZ $8E
		LDY #$20
		JMP .00EEE1

		.00EE2D
		LDA !P2Blocked
		AND #$04
		ORA !MarioInAir
		BNE .00EE39
		LDA #$24 : STA !MarioInAir
	.00EE39	RTS

		.00EE3A
		LDY $7693
		LDA !HeaderTileset
		CMP #$02 : BEQ +
		CMP #$08 : BNE .00EE57
	+	TYA
		SEC : SBC #$0C
		CMP #$02 : BCS .00EE57
		ASL A
		TAX
		JSR .00EFCD			; conveyor code ???
		BRA .00EE83

		.00EE57
		JSR .CheckCarryable		;
		LDY #$03
		LDA $7693
		CMP #$1E : BNE .NotBrick
		LDX $8F : BEQ .00EE83
		; SEE IF BRICK CAN BE DESTROYED HERE
		LDA #$21
		JSL $00F17F			; ??? destroy brick ???
		BRA .00EE1D			; to platform code?
		.NotBrick

		CMP #$32 : BNE .NotBrownBlock
		STZ $7909			; signal that a brown block has been touched and the eater sprite can start
		.NotBrownBlock

		JSL $00F120			; tileset-based hurt code
		; INSERT: generic tileset-based hazard code
	.00EE83	LDY #$20
		LDA !P2YSpeed : BPL +
		LDA $8D
		CMP #$02 : BCC .00EE39
		; scrapped switch palace check

		; 00EED1
	+	INC $73EF			; layer touched this frame?
		LDA !P2YPosLo
		SEC : SBC $91
		STA !P2YPosLo
		LDA !P2YPosHi
		SBC $90
		STA !P2YPosHi
		LDA $E53D,y : BNE .00EEEF
		LDX $73ED : BEQ .00EF05		; mario pose when sliding or whatever
		LDX !P2XSpeed : BEQ .00EF02
	.00EEEF	STA $73EE			; mario slope
		LDA $6DA3
		AND #$04 : BEQ .NoSlide
		LDA !MarioSpinJump
		ORA $73ED
		BNE .NoSlide
		LDX #$1C : STX $73ED
		.NoSlide

		LDX $E4B9,y : STX $73E1		; special slope value???
		CPY #$1C : BCS .00EF38
		LDA !P2XSpeed : BEQ .00EF31
		LDA $E53D,y : BEQ .00EF31
		EOR !P2XSpeed : BPL .00EF31
		STX $73E5			; some mario animation timer
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		CMP #$28 : BCC .00EF2F
		LDA $E4FB,y
		BRA .00EF60

		.00EF2F
		LDY #$20
	.00EF31	LDA !P2YSpeed
		CMP $E4DA,y
		BCC $03 : LDA $E4DA,y
		LDX $8E : BPL .00EF60
		INC $740E			; layer 2 touched this frame
		PHA
		REP #$20
		LDA $77BE			; special layer 2 X/Y delta
		AND #$FF00
		BPL $03 : ORA #$00FF
		XBA
		EOR #$FFFF : INC A
		CLC : ADC !P2XPosLo
		STA !P2XPosLo
		SEP #$20
		PLA
		CLC : ADC #$28
	.00EF60	STA !P2YSpeed
		TAX
		BPL $03 : INC $73EF		; layer touched this frame?
	;	STZ $78B5			; unused cage flag
		STZ !MarioInAir
		STZ !MarioClimbing		;
		STZ $7406			; mario springboard timer
		STZ !MarioSpinJump
		LDA #$04 : TSB !P2Blocked
		; scrapped flying with cape check
		; scrapped yoshi check
		STZ $7697
		RTS




		.00EFE8
		JSR .CheckBlock
		BNE $03 : JMP .00F309
		CPY #$11 : BCC +
		CPY #$6E : BCS +
		TYA
		LDY #$00
		JSL $00F160			; ???
		PLA
		PLA
		JMP .00EB42
	+	RTS




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; contact collectibles
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		.CheckCollectible
		TYA
		SEC : SBC #$6F
		CMP #$04 : BCS .NotInvisMushroom
		CMP $7421 : BEQ .CorrectInvisMushroom
		INC A
		CMP $7421 : BEQ .00F2BF
		LDA $7421
		CMP #$04 : BCS .00F2BF
		LDA #$FF
		.CorrectInvisMushroom
		INC A
		STA $7421
		CMP #$04 : BNE .00F2BF
		PHX
		JSL $03C2D9			; spawn mushroom
		; ignore saving that this was found
		PLX
	.00F2BF	RTS
		.NotInvisMushroom

		LDA #$01
	.00F2C2	CPY #$06 : BCS .CheckMidway
		TSB $8A
		RTS


		; 00F2C9
		.CheckMidway
		CPY #$38 : BNE .NotMidway
		LDA #$02 : STA $9C
		JSL $00BEB0
		; INSERT: spawn glitter
		; scrapped $73CD check (LM repurposes it)
		LDA #$01 : STA $73CE		; checkpoint get!
		; INSERT: checkpoint code here
		; INSERT: generic HP up code
		LDA $19
		BNE $02 : INC $19
		LDA #$05 : STA !SPC1
		RTS
		.NotMidway

		CPY #$06 : BCS .00F2FC
		CPY #$07 : BCC .00F309
		CPY #$1D : BCS .00F309
		ORA #$80
	.00F2FC	CMP #$01 : BNE .00F302
	.00F302	ORA #$18
		TSB $8B
		LDA $93 : STA $8C
	-	RTS

		.00F309
		CPY #$2F : BCS .00F311
		CPY #$2A : BCS .NotMoon
	.00F311	CPY #$6E : BNE -
		; scrapped score sprite code
		; scrapped moon counter increment
		PHX
		LDA !Translevel
		LSR #3
		TAY
		LDA !Translevel
		AND #$07
		TAX
		LDA $05B35B,x
		ORA $7FEE,y
		STA $7FEE,y
		PLX
		; INSERT: erase tile
		.NotMoon

		LDA !PSwitchTimer : BEQ .00F376
		CPY #$2D
		BEQ .00F33F
		BCC .00F376
		; INSERT: yoshi coin code
	.00F376	RTS


	; 00F267
	.CheckCarryable	; block that mario can pick up (0x012E)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; pipe codes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		.00F3C4
		CPY #$3F : BNE .00F376
		LDY $8F : BEQ .00F3CF
		LDY $7693
		RTS

		.00F3CF
		PHX
		TAX
		LDA !P2XPosLo
		TXY
		BEQ $03 : EOR #$FF : INC A
		AND #$0F			; 16 screen limit?
		ASL A
		CLC : ADC #$20
		LDY #$05
		BRA .00F40A

		.00F3E9
		XBA
		TYA
		SEC : SBC #$37
		CMP #$02 : BCS .00F442
		TAY
		LDA $92
		SBC $F3E3,y
		CMP #$05 : BCS .00F43F
		PHX
		XBA
		TAX
		LDA #$20
		LDY #$06

	.00F40A	STA $88
		LDA $6DA3
		AND $F3E5,x : BEQ .00F43E	; must hold towards pipe
		STA $9D				; lock animations
		AND #$01
		STA !P2Direction
		STX $89
		TXA
		LSR A
		TAX : BNE .00F430
		LDA $748F : BEQ .00F430
		LDA !MarioDirection
		EOR #$01
		STA !MarioDirection
		LDA #$08 : STA $7499
	.00F430	INX
		STX $7479
		STY !MarioAnim
		STZ $15
		STZ $16
		STZ $17
		STZ $18
		LDA #$04 : STA !SPC1
	.00F43E	PLX
	.00F43F	LDY $7693
	.00F442	RTS






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; read map16 codes
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


		; 00F44D
		.CheckBlock
		INX #2
		REP #$20
		LDA !P2XPosLo
		CLC : ADC $E830,x
		STA $9A
		LDA !P2YPosLo
		CLC : ADC $E89C,x
		STA $98
		.00F461
	;	JSR .00F465
	;	RTS

		.00F465
		SEP #$20
	;	STZ $7423			; switch palace reg
		PHX
		LDA $8E : BPL .00F472
		JMP .CollisionOff

		.00F472
	;	BNE .00F4A6			; never vertical!
		REP #$20
		LDA $98
		CMP !LevelHeight
		SEP #$20
		BCS .00F4A0
		AND #$F0
		STA $00
		LDX $9B
		CPX $5D : BCS .00F4A0
		LDA $9A
		LSR #4
		ORA $00
		CLC : ADC $00BA60,x		; SWITCH THESE TO SA-1 RAM
		STA $00
		LDA $99
		ADC $00BA9C,x			; SWITCH THESE TO SA-1 RAM
		BRA .ReadBlock


		.00F4A0
		PLX
		LDY #$25			; air block outside of bounds
	.00F4A3	LDA #$00
		RTS

	;	.00F4A6
		; vertical level code
		; SCRAPPED!

		.ReadBlock
		STA $01
		LDA #$40 : STA $02
		LDA [$00] : STA $7693
		INC $02
		PLX
		LDA [$00]			; TODO: add acts like setting here
		JSL $00F545			; decode block, i suppose...
		LDY $7693
		CMP #$00
		RTS

		.00F4E7
		PLX
		LDY #$25			; air, baby!
		BRA .00F4A3

		; 00F4EC
		.CollisionOff
		; scrapped vertical level check
		REP #$20
		LDA $98
		CMP !LevelHeight
		SEP #$20
		BCS .00F4E7
		AND #$F0
		STA $00
		LDX $9B
		CPX #$10 : BCS .00F4E7		; limited to screen 0x10?
		LDA $9A
		LSR #4
		ORA $00
		CLC : ADC $00BA70,x		; SWITCH THESE TO SA-1 RAM
		STA $00
		LDA $99
		ADC $00BAAC,x			; SWITCH THESE TO SA-1 RAM
		BRA .ReadBlock


endmacro








namespace off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


