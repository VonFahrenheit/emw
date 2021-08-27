



	!WizrexHP		= $BE		; counts down upon taking damage
	!WizrexState		= $3280		; 0 = statue, 1 = main, 2 = death
	!WizrexTargetXLo	= $3290		;\
	!WizrexTargetXHi	= $32A0		; | target coordinates
	!WizrexTargetYLo	= $32B0		; |
	!WizrexTargetYHi	= $32C0		;/
	!WizrexFlyTimer		= $32D0		; generic timer

	!WizrexCircleStatus	= $3500		; number of orbs left
	!WizrexPrevAttack	= $3510
	!WizrexMovement		= $3520		; index to movement pointer (80 bit is init/main flag, 40 is used for flash)
	!WizrexMask		= $3530		; 0 = has mask, 1 = has no mask
	!WizrexTargetPlayer	= $3540
	!WizrexAttackTimer	= $3550
	!WizrexInvincTimer	= $3560



	!Temp = 0
	%def_anim(Wizrex_Idle, 3)
	%def_anim(Wizrex_Cast, 2)
	%def_anim(Wizrex_Rise, 2)
	%def_anim(Wizrex_StartHover, 1)
	%def_anim(Wizrex_Hover, 3)
	%def_anim(Wizrex_FDash, 3)
	%def_anim(Wizrex_BDash, 3)
	%def_anim(Wizrex_Grind, 3)
	%def_anim(Wizrex_GrindCast, 1)


Wizrex:

	namespace Wizrex

	INIT:

		LDA #$07 : JSL GET_SQUARE : BCS .Process	;\
		STZ $3230,x					; | get dynamic tiles
		RTL						; |
		.Process					;/

		PHB : PHK : PLB					; bank wrapper start
		LDA #$04 : STA !WizrexHP,x			; HP = 4
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA $3320,x				;/
		LDA !ExtraBits,x				;\
		AND #$04 : BEQ .No3D				; |
		JSR Mask3D_Init					; | init 3D mask
		PLB						; |
		RTL						; |
		.No3D						;/

		LDA !RNG					;\
		AND #$03					; |
		ASL A						; |
		TAY						; |
		REP #$20					; | get mask dynamo
		LDA.w ANIM_MaskTable,y : STA $0C		; |
		SEP #$20					; |
		LDY.b #!File_Wizrex				; |
		JSL LOAD_SQUARE_DYNAMO				;/

		LDX !SpriteIndex				;\
		LDA #!palset_special_wizrex : JSL LoadPalset	; |
		LDA !Palset_status+!palset_special_wizrex	; | get palset
		ASL A						; |
		STA $33C0,x					;/


	; get palette data
		STZ $2250					; set up multiplication
		PHB
		LDA.b #!PaletteBuffer>>16
		PHA : PLB
		REP #$30
		LDX.w #(!palset_special_wizrex)*$20
		LDA !Palset_status+!palset_special_wizrex
		AND #$00FF
		ORA #$0008
		XBA
		LSR #3
		TAY

		LDA #$000E : STA $0E

	-	LDA $3F8002,x : STA $04				; $04 = full color
		AND #$001F
		STA.l $2251
		LDA #$0058 : STA.l $2253
		NOP : BRA $00
		LDA.l $2306 : STA $00				; R

		LDA $04
		LSR #5
		STA $04
		AND #$001F
		STA.l $2251
		LDA #$00B0 : STA.l $2253
		NOP : BRA $00
		LDA.l $2306 : STA $02				; G

		LDA $04
		LSR #5
		AND #$001F
		STA.l $2251
		LDA #$001C : STA.l $2253
		NOP : BRA $00
		LDA.l $2306					; B

		CLC : ADC $00
		CLC : ADC $02
		XBA
		AND #$00FF
		CMP #$001F
		BCC $03 : LDA #$001F

		PHX
		ASL A
		TAX
		LDA.l .ColorCorrection,x
		PLX

		STA $04
		ASL #5
		ORA $04
		ASL #5
		ORA $04

		STA.w !PaletteCacheRGB+$02,y
		INX #2
		INY #2
		DEC $0E : BMI $03 : JMP -


		PLB
		SEP #$30
		LDX !SpriteIndex


		PLB						; bank wrapper end
		RTL						; return


		.ColorCorrection
		dw $0000,$0000,$0001,$0001,$0002,$0002,$0003,$0003	; 00-07
		dw $0004,$0006,$0007,$0009,$000A,$000C,$000D,$000F	; 08-0F
		dw $0010,$0011,$0012,$0013,$0014,$0015,$0016,$0017	; 10-17
		dw $0018,$0019,$001A,$001B,$001C,$001D,$001E,$001F	; 18-1F



	MAIN:
		PHB : PHK : PLB					; bank wrapper start

		%decreg(!WizrexAttackTimer)
		%decreg(!WizrexInvincTimer)

		LDA !ExtraBits,x				;\ check for mask
		AND #$04 : BNE .Mask				;/

		LDA !WizrexState,x				;\
		ASL A						; |
		CMP.b #.PhasePtr_end-.PhasePtr			; | main state code
		BCC $02 : LDA #$00				; |
		TAX						; |
		JSR (.PhasePtr,x)				;/
		JSL !SpriteApplySpeed				; speed
		BRA GRAPHICS					; go to graphics

		.Mask						;\
		LDA #$20					; |
		STA $32E0,x					; |
		STA $35F0,x					; | big mask code
		JSR Chase					; |
		JSR Mask3D					; |
		JSL !SpriteApplySpeed-$10			; |
		JSL !SpriteApplySpeed-$8			;/
		PLB
		RTL


	.PhasePtr
		dw Statue	; 00
		dw Chase	; 01
		dw Death	; 02
		..end




	GRAPHICS:

		LDA !WizrexState,x
		CMP #$02 : BNE .NotDead
		LDA !WizrexFlyTimer,x : BPL .NotDead
		AND #$02 : BEQ .NoSet
		LDA #$0A : STA $33C0,x
	.NoSet	STZ !WizrexInvincTimer,x
		.NotDead


		JSL SETUP_SQUARE				; set up dynamic draw
		LDA !SpriteAnimIndex				;\
		ASL A						; |
		STA $00						; | get index (and save copy in scratch RAM)
		ASL A						; |
		CLC : ADC $00					; |
		TAY						;/
		LDA !SpriteAnimTimer				;\
		INC A						; | standard increment timer code
		CMP.w ANIM+4,y : BNE .SameAnim			;/
		.NewAnim					;\
		LDA.w ANIM+5,y : STA !SpriteAnimIndex		; |
		ASL A						; |
		STA $00						; | new anim
		ASL A						; |
		CLC : ADC $00					; |
		TAY						; |
		LDA #$00					;/
		.SameAnim					;\ set timer
		STA !SpriteAnimTimer				;/
		LDA $3340,x					;\ see if this dynamo is already loaded
		CMP !SpriteAnimIndex : BEQ .DynamoDone		;/
		REP #$20					;\
		LDA.w ANIM+2,y : STA $0C			; |
		SEP #$20					; |
		BEQ .DynamoDone					; | load dynamo, if there is one
		PHY						; |
		LDY.b #!File_Wizrex				; |
		JSL LOAD_SQUARE_DYNAMO				; |
		PLY						;/
		.DynamoDone					;\
		LDA !WizrexInvincTimer,x			; | invulnerability flash
		AND #$02 : BNE .Return				;/


	.Draw
		LDA !SpriteAnimIndex : STA $3340,x		; currently loaded dynamo
		LDA !WizrexCircleStatus,x : BMI .NoCircle	;\
		LDA !WizrexMovement,x				; |
		AND #$9F					; | draw circle spell
		CMP #$86 : BNE .NoCircle			; |
		JSR .CircleCast					; |
		.NoCircle					;/
		LDA !SpriteAnimIndex				;\
		CMP #!Wizrex_Grind : BCC .NoGrind		; |
		REP #$20					; |
		LDA.w ANIM+0,y : STA $04			; |
		SEP #$20					; |
		JSL LOAD_PSUEDO_DYNAMIC_p3			; | draw grind overlay
		LDY.b #(!Wizrex_FDash)*6			; |
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_GrindCast : BNE .NoGrind		; |
		LDY.b #(!Wizrex_Cast)*6				; |
		.NoGrind					;/
		LDA !WizrexMask,x : BNE .MaskDone		;\
		REP #$20					; |
		LDA.w ANIM+0,y : STA $04			; |
		SEP #$20					; |
		PHY						; |
		LDA !WizrexHP,x					; | draw mask
		CMP #$04 : BEQ ..nodrop				; |
		JSR DropMask					; > drop mask if HP != 4
		..nodrop					; |
		JSL LOAD_DYNAMIC				; |
		PLY						; |
		.MaskDone					;/
		REP #$20					;\
		LDA.w ANIM+0,y					; |
		CLC : ADC #$0006				; | draw body
		STA $04						; |
		SEP #$20					; |
		JSL LOAD_DYNAMIC				;/

		.Return
		LDA !Palset_status+!palset_special_wizrex	;\
		ASL A						; | default to wizrex palset
		STA $33C0,x					;/

		PLB						; bank wrapper end
		RTL						; return


	.CircleCast
		PHY						; preserve ANIM index
		STZ !BigRAM+0					;\ reset tilemap size
		STZ !BigRAM+1					;/
		LDA #$49 : STA $00				; base orb tile

		LDA !WizrexCircleStatus,x : STA $06		; $06 = number of orbs
		LDA !WizrexAttackTimer,x			;\
		LSR #2						; |
	-	CMP #$03 : BCC +				; | big orb tile
		SBC #$03 : BRA -				; |
	+	TAY						; |
		LDA ..bigorbtile,y : STA $03			;/
		LDA !Difficulty					;\
		AND #$03					; | difficulty index
		TAY						;/
		LDA ..orbangle,y : STA $02			; angle index offset
		LDA ..orbcount,y : STA $01			; number of orbs
		SEC : SBC !WizrexCircleStatus,x			;\ orbs to skip
		STA $04						;/
		STZ $05						; orbs drawn
		LDA !WizrexAttackTimer,x			; base angle index
		LDX #$00					; X = output tilemap index
	-	CMP #$48 : BCC +				;\
		SBC #$48					; |
		INC $00						; | get angle index + tile
		INC $00						; |
		BRA -						; |
	+	TAY						;/

		LDA $05						;\ skip orbs that don't exist
		CMP $04 : BCC ..next				;/
		LDA $06 : BEQ ..big				; > last orb is always big
		LDA $00						;\
		CMP #$4F : BCS ..next				; |
		CMP #$49 : BNE ..small				; |
		..big						; |
		LDA $03						; |
		..small						; |
		STA !BigRAM+5,x					; |
		LDA #$3B : STA !BigRAM+2,x			; |
		LDA .SpellCircle,y : STA !BigRAM+3,x		; |
		LDA .SpellCircle+$12,y : STA !BigRAM+4,x	; | add spell orb to tilemap
		LDA !BigRAM+0					; |
		CLC : ADC #$04					; |
		STA !BigRAM+0					; |
		INX #4						; |
		..next						; |
		INC $05						; |
		TYA						; |
		CLC : ADC $02					; |
		TAY						; |
		DEC $01 : BPL -					;/

		LDX !SpriteIndex				;\
		LDA $3320,x : PHA				; |
		STZ $3320,x					; |
		REP #$20					; | draw tilemap
		LDA.w #!BigRAM : STA $04			; |
		SEP #$20					; |
		JSL LOAD_PSUEDO_DYNAMIC				; |
		PLA : STA $3320,x				;/
		PLY						; restore ANIM index
		RTS						; return

		..orbcount
		db $03,$05,$07

		..orbangle
		db $12,$0C,$09

		..bigorbtile
		db $45,$47,$49



	; Angle 0 = straight right
	; for Y coordinate (cosine), add $12 to index (wrapping at $48)
	; i... uh, accidentally reversed these as sine is typically Y and cosine X
	.SpellCircle
		db $E0,$E0,$E0,$E1	; 0
		db $E2,$E3,$E4,$E6	; 
		db $E7,$E9,$EB,$EE	;
		db $F0,$F2,$F5,$F8	;
		db $FA,$FD		; 
		db $00,$03,$06,$08	; 90
		db $0B,$0E,$10,$12	;
		db $15,$17,$19,$1A	;
		db $1C,$1D,$1E,$1F	;
		db $20,$20		;
		db $20,$20,$20,$1F	; 180
		db $1E,$1D,$1C,$1A	;
		db $19,$17,$15,$12	;
		db $10,$0E,$0B,$08	;
		db $06,$03		;
		db $00,$FD,$FA,$F8	; 270
		db $F5,$F2,$F0,$EE	;
		db $EB,$E9,$E7,$E6	;
		db $E4,$E3,$E2,$E1	;
		db $E0,$E0		;
		db $E0,$E0,$E0,$E1	; extended cosine area
		db $E2,$E3,$E4,$E6	; ---
		db $E7,$E9,$EB,$EE	; ---
		db $F0,$F2,$F5,$F8	; ---
		db $FA,$FD		; ---




	Statue:
		LDX !SpriteIndex				; X = sprite index
		LDA $3250,x : XBA				;\
		LDA $3220,x					; |
		REP #$20					; |
		STA $00						; |
		SEC : SBC !P2XPosLo-$80				; |
		CLC : ADC #$0040				; | see if either player is within 4 tiles horizontally
		CMP #$0080 : BCC .TakeFlight			; |
		LDA $00						; |
		SEC : SBC !P2XPosLo				; |
		BPL $04 : EOR #$FFFF : INC A			; |
		CLC : ADC #$0040				; |
		CMP #$0080 : BCC .TakeFlight			;/
		SEP #$20					; A 8-bit
	.Return	RTS						; return

	.TakeFlight
		SEP #$20					; A 8-bit
		LDA #$01 : STA !WizrexMovement,x		; movement: jump
		LDA #$08 : STA !WizrexFlyTimer,x		; fly timer: 8 frames
		LDA #!Wizrex_Cast : STA !SpriteAnimIndex	;\ cast anim
		STZ !SpriteAnimTimer				;/
		LDA !SpriteXLo,x : STA !WizrexTargetXLo,x	;\
		LDA !SpriteXHi,x : STA !WizrexTargetXHi,x	; |
		LDA !SpriteYLo,x				; |
		SEC : SBC #$50					; | target coords
		STA !WizrexTargetYLo,x				; |
		LDA !SpriteYHi,x				; |
		SBC #$00					; |
		STA !WizrexTargetYHi,x				;/
		INC !WizrexState,x				; chase state
		; flow into chase


	Chase:
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexHP,x					;\
		BEQ .Die					; |
		BPL .Alive					; |
		.Die						; | die if HP < 1
		LDA #$FF : STA !WizrexFlyTimer,x		; |
		LDA #$02 : STA !WizrexState,x			; |
		JMP Death					;/
		.Alive

	INTERACTION:
		LDA !WizrexInvincTimer,x : BNE GET_MOVEMENT	; no interaction during invinc
		LDA !ExtraBits,x				;\ no interaction for mask mode
		AND #$04 : BNE GET_MOVEMENT			;/

		LDA !SpriteXLo,x				;\
		SEC : SBC #$02					; |
		STA $04						; |
		LDA !SpriteXHi,x				; |
		SBC #$00					; |
		STA $0A						; |
		LDA !SpriteYLo,x				; | hitbox
		SEC : SBC #$02					; |
		STA $05						; |
		LDA !SpriteYHi,x				; |
		SBC #$00					; |
		STA $0B						; |
		LDA #$14 : STA $06				; |
		LDA #$12 : STA $07				;/

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		JSR Hurt
		..nocontact

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		JSR Hurt
		..nocontact

		.Fireball
		JSL FireballContact_Destroy : BCC ..nocontact
		LDA $00 : STA !SpriteXSpeed,x
		LDA #$E8 : STA !SpriteYSpeed,x
		JSR Hurt
		..nocontact

	GET_MOVEMENT:
		LDA !WizrexMovement,x
		AND #$1F
		ASL A
		CMP.b #Movement_Ptr_end-Movement_Ptr
		BCS Hurt_Return
		TAX
		JMP (Movement_Ptr,x)



	Hurt:
		DEC !WizrexHP,x					; damage
		LDA #$80 : STA !WizrexInvincTimer,x		; invinc
		LDA #$26 : STA !SPC4				; swoop SFX

		LDA #$07 : STA !WizrexMovement,x		; move

		.Return
		RTS						; return


	Death:
		LDX !SpriteIndex				; X = sprite index
		LDA $3330,x					;\
		AND #$04 : BEQ .AnimDone			; |
		.Land						; |
		LDA !SpriteAnimIndex				; | go to idle anim upon landing
		CMP #!Wizrex_Idle_over : BCC .Stand		; |
		STZ !SpriteAnimIndex				; |
		STZ !SpriteAnimTimer				;/
		.Stand						;\
		STZ !SpriteXSpeed,x				; |
		STZ !SpriteYSpeed,x				; |
		LDA !WizrexFlyTimer,x				; |
		BEQ .Freeze					; |
		BMI .AnimDone					; |
		CMP #$40 : BCS .Slow1				; |
		.Slow2						; |
		LDA $14						; | handle slowing anim rate
		AND #$03 : BNE .Freeze				; |
		BRA .AnimDone					; |
		.Slow1						; |
		LDA $14						; |
		LSR A : BCC .AnimDone				; |
		.Freeze						; |
		DEC !SpriteAnimTimer				; |
		.AnimDone					;/

		LDA !WizrexFlyTimer,x : BMI .Half		;\
		CMP #$40 : BCC .NoParticle			; |
		.Quarter					; | particle spawn rate
		LSR A : BCC .NoParticle				; |
		.Half						; |
		LSR A : BCC .NoParticle				;/
		STZ $00						;\
		STZ $01						; |
		LDA !RNG					; |
	-	CMP #$48 : BCC +				; |
		SBC #$48 : BRA -				; |
	+	TAY						; |
		LDA GRAPHICS_SpellCircle+$12,y			; |
		BMI $01 : LSR A					; > halve downwards speed
		STA $03						; |
		LDA GRAPHICS_SpellCircle,y : STA $02		; | spawn particle
		LSR #2						; |
		CMP #$20					; |
		BCC $02 : ORA #$C0				; |
		EOR #$FF : INC A				; |
		STA $04						; |
		LDA #$F0 : STA $05				; |
		STZ $07						; |
		LDA #!prt_basic : JSL SpawnParticle		;/
		LDA !SpriteProp,x				;\
		ORA #$0A					; |
		XBA						; |
		LDA !SpriteTile,x				; |
		CLC : ADC #$5F					; |
		REP #$10					; | particle tile + prop
		LDX $00						; |
		STA !41_Particle_Tile,x				; |
		XBA : STA !41_Particle_Prop,x			; |
		SEP #$10					; |
		LDX !SpriteIndex				; |
		.NoParticle					;/

		LDA !WizrexFlyTimer,x : BMI .Return		;\
		LSR #2						; |
		XBA						; |
		LDA !Palset_status+!palset_special_wizrex	; |
		ORA #$08					; |
		ASL #4						; | blend RGB palset
		TAX						; |
		INX						; |
		LDY #$0F					; |
		XBA						; |
		JSL !MixRGB					; |
		LDX !SpriteIndex				;/

		.Return						;\ return
		RTS						;/




	Movement:
	.Ptr
		dw .Hover			; 0
		dw .Jump			; 1
		dw .Grind			; 2
		dw .GrindBlast			; 3
		dw .SpraySetup			; 4
		dw .Spray			; 5
		dw .Circle			; 6
		dw .Hurt			; 7
		..end

	.Hover
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA !RNG					; |
		AND #$80					; |
		STA !WizrexTargetPlayer,x			; | init target player + attack timer
		LDA !RNG					; |
		AND #$3F					; |
		ORA #$40					; |
		STA !WizrexAttackTimer,x			; |
		..main						;/
		LDA !WizrexAttackTimer,x : BNE ..noattack	; get new attack when timer runs out

		LDA !ExtraBits,x				;\
		AND #$04 : BEQ ..caster				; |
		..mask						; |
		LDA !RNG					; | attack for mask
		AND #$02					; |
		ORA #$04					; |
		STA !WizrexMovement,x				; |
		RTS						;/

		..caster					;\
		LDA !RNG					; |
	-	CMP #$06 : BCC +				; |
		SBC #$06 : BRA -				; |
	+	AND #$06					; |
		INC #2						; |
		CMP !WizrexPrevAttack,x : BNE +			; | attack for caster
		INC #2						; |
		CMP #$08					; |
		BCC $02 : LDA #$02				; |
	+	STA !WizrexMovement,x				; |
		STA !WizrexPrevAttack,x				; |
		RTS						;/

		..noattack
		LDY !WizrexTargetPlayer,x			; target player
		LDA !P2XPosLo-$80,y : STA !WizrexTargetXLo,x	;\ target X
		LDA !P2XPosHi-$80,y : STA !WizrexTargetXHi,x	;/

		..anim						;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_Cast : BEQ ..animdone		; | these animations can't be cancelled
		CMP #!Wizrex_Cast+1 : BEQ ..animdone		; |
		CMP #!Wizrex_StartHover : BEQ ..animdone	; |
		CMP #!Wizrex_GrindCast : BEQ ..animdone		;/
		LDA !SpriteXSpeed,x				;\
		CLC : ADC #$20					; | if moving fast, use dash anim
		CMP #$40 : BCC ..hoveranim			;/
		..dashanim					;\
		LDA !SpriteXSpeed,x				; |
		ROL #2						; | see if fdash or bdash
		AND #$01					; |
		CMP $3320,x : BEQ ..fdashanim			;/
		..bdashanim					;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_BDash : BCC +			; |
		CMP #!Wizrex_BDash_over : BCC ..animdone	; | bdash anim
	+	LDA #!Wizrex_BDash : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		BRA ..animdone					;/
		..fdashanim					;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_FDash : BCC +			; |
		CMP #!Wizrex_FDash_over : BCC ..animdone	; | fdash anim
	+	LDA #!Wizrex_FDash : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		BRA ..animdone					;/
		..hoveranim					;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_Hover : BCC +			; |
		CMP #!Wizrex_Hover_over : BCC ..animdone	; | hover anim
	+	LDA #!Wizrex_Hover : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		..animdone					;/

		LDY !WizrexTargetPlayer,x			;\
		REP #$20					; |
		LDA !P2YPosLo-$80,y				; |
		SEC : SBC #$0040				; | target Y
		SEP #$20					; |
		STA !WizrexTargetYLo,x				; |
		XBA : STA !WizrexTargetYHi,x			;/
		LDY #$00					;\
		LDA !SpriteYLo,x				; |
		CMP !WizrexTargetYLo,x				; |
		LDA !SpriteYHi,x				; | Y speed
		SBC !WizrexTargetYHi,x				; |
		BCC $01 : INY					; |
		LDA DATA_HoverY,y : JSL AccelerateY		;/

		..move						;\
		LDY !WizrexTargetPlayer,x			; | facing dir
		JSL SUB_HORZ_POS_Target				; |
		TYA : STA $3320,x				;/

		LDA !WizrexTargetXLo,x : STA $00		;\ accel setup
		LDA !WizrexTargetXHi,x : STA $01		;/
		LDA !SpriteXHi,x : XBA				;\
		LDA !SpriteXLo,x				; |
		LDY #$00					; |
		REP #$20					; |
		SEC : SBC $00					; |
		BMI $01 : INY					; |
		CLC : ADC #$0020				; |
		CMP #$0040					; | X speed
		SEP #$20					; |
		BCS ..accelx					; |
		..frictionx					; |
		LDA !WizrexMovement,x				; |
		AND #$1F					; |
		CMP #$04 : BEQ ..accelx				; > no friction during spray setup
		JSL AccelerateX_Friction2			; |
		BRA ..accelxdone				; |
		..accelx					; |
		LDA DATA_HoverX,y : JSL AccelerateX_Unlimit1	; |
		..accelxdone					;/

		LDA #$FD : STA !SpriteGravityMod,x		;\ negate gravity
		LDA #$01 : STA !SpriteGravityTimer,x		;/
		LDA #$02 : STA !SpritePhaseTimer,x		; no collision

		RTS						; return





	.Jump
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BPL ..init		;\
		..main						; |
		LDA $3210,x					; |
		CMP !WizrexTargetYLo,x				; |
		LDA $3240,x					; |
		SBC !WizrexTargetYHi,x				; |
		BPL ..ascend					; | main code
		LDA !SpriteYSpeed,x : BMI +			; |
		STZ !WizrexMovement,x				; |
		STZ !WizrexFlyTimer,x				; |
		LDA #!Wizrex_StartHover : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		RTS						;/
		..init						;\
		STZ !SpriteYSpeed,x				; |
		LDY !WizrexFlyTimer,x				; |
		CPY #$01 : BNE ..return				; |
		ORA #$80 : STA !WizrexMovement,x		; | init code
		..ascend					; |
		LDA #$C0 : STA !SpriteYSpeed,x			; |
	+	LDA #$02 : STA !WizrexFlyTimer,x		; |
		..return					;/
		RTS						; return




	.Grind
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; | init target player
		LDA !RNG					; |
		AND #$80					; |
		STA !WizrexTargetPlayer,x			;/
		TAY						;\
		JSL SUB_HORZ_POS_Target				; | init speeds
		LDA DATA_GrindSpeed+0,y : STA !SpriteXSpeed,x	; |
		STZ !SpriteYSpeed,x				;/
		LDA #!Wizrex_Rise : STA !SpriteAnimIndex	;\
		STZ !SpriteAnimTimer				; | init anim
		..main						;/


		LDA !SpriteAnimIndex				;\
		CMP #!Wizrex_Grind : BCC ..noparticles		; |
		CMP #!Wizrex_Grind_over : BCS ..noparticles	; | spawn particles while in grind anim
		LDA $14						; |
		LSR A : BCC ..noparticles			;/
		LDA ANIM_GrindTM00+3				;\
		LDY $3320,x					; |
		BNE $02 : EOR #$FF				; | particle Xdisp
		CLC : ADC #$04					; |
		STA $00						;/
		LDA ANIM_GrindTM00+4				;\
		CLC : ADC #$04					; | particle Ydisp
		STA $01						;/
		LDA !RNG					;\
	-	CMP #$48 : BCC +				; |
		SBC #$48 : BRA -				; |
	+	TAY						; | particle Yspeed
		LDA GRAPHICS_SpellCircle+$12,y			; |
		BMI $01 : LSR A					; > halve downwards speed
		CLC : ADC !SpriteYSpeed,x			; |
		STA $03						;/
		LDA GRAPHICS_SpellCircle,y			;\
		CLC : ADC !SpriteXSpeed,x			; | particle X speed
		STA $02						;/
		LSR #2						;\
		CMP #$20					; |
		BCC $02 : ORA #$C0				; | particle X acc
		EOR #$FF : INC A				; |
		STA $04						;/
		LDA #$F0 : STA $05				; particle Y acc
		LDA !SpriteTile,x				;\
		CLC : ADC #$5F					; | particle tile
		STA $06						;/
		LDA !SpriteProp,x				;\
		ORA #$2A					; | particle prop
		STA $07						;/
		LDA #!prt_basic : JSL SpawnParticle		;\ spawn particle
		..noparticles					;/


		LDA $3330,x					;\ return while in midair
		AND #$04 : BEQ ..return				;/
		STZ !SpriteYSpeed,x				;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_Grind : BCC +			; |
		CMP #!Wizrex_Grind_over : BCC ..animdone	; | change to grind anim on the ground
	+	LDA #!Wizrex_Grind : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		..animdone					;/

		LDY $3320,x					;\
		LDA !SpriteXLo,x				; |
		CLC : ADC DATA_GrindVisionX,y			; |
		STA $04						; |
		LDA !SpriteXHi,x				; |
		ADC DATA_GrindVisionX+2,y			; |
		STA $0A						; |
		LDA !SpriteYLo,x				; | go to grind blast when player within trigger box
		SEC : SBC #$40					; |
		STA $05						; |
		LDA !SpriteYHi,x				; |
		SBC #$00					; |
		STA $0B						; |
		LDA #$40 : STA $06				; |
		LDA #$50 : STA $07				; |
		SEC : JSL !PlayerClipping : BCS ..blast		;/

		LDY !WizrexTargetPlayer,x			;\
		JSL SUB_HORZ_POS_Target				; |
		TYA						; | go to grind blast when target passes sprite
		CMP $3320,x : BEQ ..accel			; |
		..blast						; |
		LDA #$03 : STA !WizrexMovement,x		;/

		..accel						;\ accelerate
		LDA DATA_GrindSpeed+2,y : JSL AccelerateX	;/
		LDA $14						;\
		AND #$03 : BNE ..return				; |
		LDA DATA_DustOffset,y : STA $00			; | spawn dust every 4 frames while moving on the ground
		LDA #$0C : STA $01				; |
		LDA #$03+!SmokeOffset : JSL SpawnExSprite_NoSpeed
		..return					;\ return
		RTS						;/



	.GrindBlast
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA #!Wizrex_GrindCast : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; | init
		LDY $3320,x					; |
		LDA DATA_GrindSpeed+4,y : STA !SpriteXSpeed,x	; |
		LDA #$30 : STA !WizrexFlyTimer,x		; |
		LDA #$0C : STA !SpriteYSpeed,x			; |
		..main						;/
		LDA !WizrexFlyTimer,x : BNE ..go		;\
		STZ !WizrexMovement,x				; | go into hover and return when timer runs out
		RTS						;/
		..go						;\ accelerate up
		LDA #$D0 : JSL AccelerateY			;/
		LDA #$FD : STA !SpriteGravityMod,x		;\ negate gravity
		LDA #$01 : STA !SpriteGravityTimer,x		;/

		LDY !WizrexFlyTimer,x				;\
		CPY #$28 : BEQ ..shoot				; |
		LDA !Difficulty					; |
		AND #$03 : BEQ ..return				; |
		CPY #$25 : BEQ ..startanim			; | shoot values
		CPY #$1D : BEQ ..shoot				; |
		CMP #$02 : BNE ..return				; |
		CPY #$1A : BEQ ..startanim			; |
		CPY #$12 : BEQ ..shoot				; |
		..return					;/
		RTS						; return

		..startanim					;\
		LDA #!Wizrex_GrindCast : STA !SpriteAnimIndex	; | start cast anim
		STZ !SpriteAnimTimer				; |
		RTS						;/

		..shoot						;\
		STZ $00						; |
		STZ $01						; |
		LDY $3320,x					; | shoot projectile
		LDA DATA_GrindSpeed+2,y : STA $02		; |
		STZ $03						; |
		JMP CAST					;/



	.SpraySetup
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA !RNG					; | init
		AND #$80 : STA !WizrexTargetPlayer,x		; |
		BRA ..move					; > always move on first frame
		..main						;/
		LDA !WizrexTargetXLo,x : STA $00		;\
		LDA !WizrexTargetXHi,x : STA $01		; |
		LDA !SpriteXHi,x : XBA				; |
		LDA !SpriteXLo,x				; |
		REP #$20					; | move until wizrex is within 8px of target
		SEC : SBC $00					; |
		CLC : ADC #$0008				; |
		CMP #$0010					; |
		SEP #$20					; |
		BCS ..move					;/
		LDA #$05 : STA !WizrexMovement,x		;\ start spray
		RTS						;/

		..move						;\
		LDY !WizrexTargetPlayer,x			; |
		JSL SUB_HORZ_POS_Target				; |
		LDA !WizrexTargetPlayer,x : TAX			; |
		LDA DATA_SprayOffset,y				; |
		CLC : ADC !P2XPosLo-$80,x			; | get target X
		XBA						; |
		LDA DATA_SprayOffset+2,y			; |
		ADC !P2XPosHi-$80,x				; |
		LDX !SpriteIndex				; |
		STA !WizrexTargetXHi,x				; |
		XBA : STA !WizrexTargetXLo,x			;/
		LDY !WizrexTargetPlayer,x			;\ move + anim
		JMP .Hover_anim					;/


	.Spray
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA !SpriteXSpeed,x : BPL ..pos			; |
		EOR #$FF					; |
		LSR A						; |
		EOR #$FF					; |
		BRA ..w						; | init speed + anim + timer
	..pos	LSR A						; |
	..w	STA !SpriteXSpeed,x				; |
		..speeddone					; |
		LDA #!Wizrex_Rise : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		LDA #$40 : STA !WizrexFlyTimer,x		; |
		..main						;/

		LDA !WizrexFlyTimer,x : BNE ..go		;\
		STZ !WizrexMovement,x				; | go back to hover when timer is up
		RTS						; |
		..go						;/

		LDA #$08 : JSL AccelerateY			; Y speed
		LDA #$FD : STA !SpriteGravityMod,x		;\ negate gravity
		LDA #$01 : STA !SpriteGravityTimer,x		;/

		LDY !WizrexTargetPlayer,x			;\
		JSL SUB_HORZ_POS_Target				; |
		LDA !WizrexTargetPlayer,x : TAX			; |
		LDA DATA_SprayOffset,y				; |
		CLC : ADC !P2XPosLo-$80,x			; |
		XBA						; | get target X
		LDA DATA_SprayOffset+2,y			; |
		ADC !P2XPosHi-$80,x				; |
		LDX !SpriteIndex				; |
		STA !WizrexTargetXHi,x				; |
		XBA : STA !WizrexTargetXLo,x			;/
		LDY !WizrexTargetPlayer,x			;\ move without anim
		JSR .Hover_move					;/

		LDA !Difficulty					;\
		AND #$03 : BEQ ..easy				; |
		CMP #$01 : BEQ ..normal				; |
		..insane					; | insane cast
		LDA $14						; |
		AND #$07 : BEQ ..cast				; |
		..return					; |
		RTS						;/
		..normal					;\
		LDA $14						; |
	-	CMP #$0C					; |
		BCC ..return					; | normal cast
		SBC #$0C					; |
		BEQ ..cast					; |
		BRA -						;/
		..easy						;\
		LDA $14						; | easy cast
		AND #$0F : BNE ..return				;/

		..cast						;\
		LDA !RNG					; |
		ADC !SpriteIndex				; | $00 = random number -10 to 0F
		AND #$1F					; |
		SBC #$10					; |
		STA $00						;/
		LDY $3320,x					;\
		LDA DATA_GrindSpeed+2,y : BPL +			; |
		EOR #$FF					; |
		LSR A						; |
		CLC : ADC $00					; | halve speed, + $00 in same direction
		EOR #$FF					; |
		BRA ++						; |
	+	LSR A						; |
		CLC : ADC $00					; |
	++	STA $02						;/
		LDA #$20					;\
		SEC : SBC $00					; | Y speed = 32 - $00
		STA $03						;/
		STZ $00						;\ no offset
		STZ $01						;/
		JMP CAST					; spawn



	.Circle
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA #$D8-1 : STA !WizrexAttackTimer,x		; |
		LDA !Difficulty					; |
		AND #$03					; |
		TAY						; |
		LDA GRAPHICS_CircleCast_orbcount,y		; |
		STA !WizrexCircleStatus,x			; | init timer + orb count + target
		LDA !RNG					; |
		AND #$80					; |
		STA !WizrexTargetPlayer,x			; |
		TAY						; |
		LDA !P2Status-$80,y : BEQ ..main		; |
		TYA						; |
		EOR #$80					; |
		STA !WizrexTargetPlayer,x			; |
		..main						;/


		LDA !SpriteAnimIndex				;\
		CMP #!Wizrex_GrindCast : BEQ ..firedone		; | check anim
		CMP #!Wizrex_Cast+1 : BNE ..checkfire		; |
		LDA !SpriteAnimTimer : BNE ..checkfire		;/
		..release					;\
		STZ $00						; |
		LDA !ExtraBits,x				; |
		AND #$04					; |
		BEQ $02 : LDA #$E0				; | fire projectile
		STA $01						; |
		JSR CAST_Target					; |
		BRA ..firedone					; |
		..checkfire					;/
		LDA !Difficulty					;\
		AND #$03					; | cast offset index
		TAY						;/
		STZ $2250					;\
		LDA ..spellangle,y : STA $2251			; |
		STZ $2252					; |
		LDA !WizrexCircleStatus,x			; | setup cast check
		INC A						; |
		STA $2253					; |
		STZ $2254					;/
		LDA !WizrexAttackTimer,x			;\ only cast on final lap
		CMP #$48 : BCS ..firedone			;/
		SEC : SBC $2306					;\
		CLC : ADC #$12					; |
		CMP #$48					; | fire at angle $12 (straight up)
		BCC $02 : SBC #$48				; |
		CMP #$00 : BNE ..firedone			;/
		..fire						;\ decrement orb count
		DEC !WizrexCircleStatus,x			;/
		LDA !ExtraBits,x				;\ mask mode: fire right away
		AND #$04 : BNE ..release			;/
		LDA #!Wizrex_GrindCast : STA !SpriteAnimIndex	;\
		LDA ..animtimer,y : STA !SpriteAnimTimer	; | start cast anim
		..firedone					;/

		LDA !WizrexCircleStatus,x : BMI ..end		; end if no more orbs
		LDA !WizrexAttackTimer,x : BNE ..move		; move is attack timer is set
		LDA #$47 : STA !WizrexAttackTimer,x		; reset timer to full circle
		BRA ..move					; go to move
		..end						;\
		LDA !SpriteAnimIndex				; |
		CMP #!Wizrex_GrindCast : BEQ ..move		; | go back to hover unless in casting anim
		STZ !WizrexMovement,x				; |
		..return					; |
		RTS						;/
		..move						;\ full hover move + anim
		JMP .Hover_noattack				;/


		..spellangle
		db $12,$0C,$09

		..animtimer
		db $FF,$01,$03



	.Hurt
		LDX !SpriteIndex				; X = sprite index
		LDA !WizrexMovement,x : BMI ..main		;\
		..init						; |
		ORA #$80 : STA !WizrexMovement,x		; |
		LDA #$20 : STA !WizrexFlyTimer,x		; |
		LDA #!Wizrex_Rise : STA !SpriteAnimIndex	; |
		STZ !SpriteAnimTimer				; |
		LDA !P2XPosLo-$80 : STA $00			; |
		LDA !P2XPosHi-$80 : STA $01			; |
		LDA !P2XPosLo : STA $02				; |
		LDA !P2XPosHi : STA $03				; |
		LDA !SpriteXHi,x : XBA				; |
		LDA !SpriteXLo,x				; |
		REP #$20					; | init timer + anim + target player
		STA $04						; |
		SEC : SBC $00					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		STA $00						; |
		LDA $04						; |
		SEC : SBC $02					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		CMP $02						; |
		SEP #$20					; |
		LDY #$00					; |
		BCC $02 : LDY #$80				; |
		TYA : STA !WizrexTargetPlayer,x			; |
		..main						;/
		LDA !WizrexFlyTimer,x : BNE ..go		;\
		STZ !WizrexMovement,x				; | cancel into hover when timer runs out
		RTS						; |
		..go						;/
		LDY !WizrexTargetPlayer,x			;\
		JSL SUB_HORZ_POS_Target				; | accelerate sideways + facing
		TYA : STA $3320,x				; |
		LDA DATA_EscapeSpeed,y : JSL AccelerateX	;/
		LDA #$F0 : JSL AccelerateY			; accelerate up
		LDA #$FD : STA !SpriteGravityMod,x		;\ negate gravity
		LDA #$01 : STA !SpriteGravityTimer,x		;/
		RTS						; return





	ANIM:
	; idle
		dw .IdleTM00,.IdleDyn00 : db $08,!Wizrex_Idle+1
		dw .IdleTM01,.IdleDyn01 : db $08,!Wizrex_Idle+2
		dw .IdleTM02,.IdleDyn02 : db $08,!Wizrex_Idle+0
	; cast
		dw .CastTM00,.CastDyn00 : db $08,!Wizrex_Cast+1
		dw .CastTM01,.CastDyn01 : db $06,!Wizrex_Rise
	; rise
		dw .RiseTM00,.RiseDyn00 : db $04,!Wizrex_Rise+1
		dw .RiseTM01,.RiseDyn01 : db $04,!Wizrex_Rise+0
	; start hover
		dw .CastTM00,.CastDyn00 : db $08,!Wizrex_Hover
	; hover
		dw .HoverTM00,.HoverDyn00 : db $03,!Wizrex_Hover+1
		dw .HoverTM01,.HoverDyn01 : db $03,!Wizrex_Hover+2
		dw .HoverTM02,.HoverDyn02 : db $03,!Wizrex_Hover+0
	; forward dash
		dw .FDashTM00,.DashDyn00 : db $06,!Wizrex_FDash+1
		dw .FDashTM01,.DashDyn01 : db $06,!Wizrex_FDash+2
		dw .FDashTM02,.DashDyn02 : db $06,!Wizrex_FDash+0
	; back dash
		dw .BDashTM00,.DashDyn00 : db $06,!Wizrex_BDash+1
		dw .BDashTM01,.DashDyn01 : db $06,!Wizrex_BDash+2
		dw .BDashTM02,.DashDyn02 : db $06,!Wizrex_BDash+0
	; grind
		dw .GrindTM00,.DashDyn00 : db $03,!Wizrex_Grind+1
		dw .GrindTM01,.DashDyn01 : db $03,!Wizrex_Grind+2
		dw .GrindTM02,.DashDyn02 : db $03,!Wizrex_Grind+0
	; grind cast
		dw .GrindCastTM00,.CastDyn00 : db $08,!Wizrex_Cast+1



	.IdleTM00
	.IdleTM01
	.IdleTM02
		dw $0004
		db $3B,$FC,$F0,$07
		dw $0010
		db $32,$FC,$F0,$00
		db $32,$04,$F0,$01
		db $32,$FC,$00,$02
		db $32,$04,$00,$03

	.CastTM00
		dw $0004
		db $3B,$FC,$F4,$07
		dw $0018
		db $32,$F4,$F0,$00
		db $32,$04,$F0,$01
		db $32,$0C,$F0,$02
		db $32,$F4,$00,$03
		db $32,$04,$00,$04
		db $32,$0C,$00,$05
	.CastTM01
		dw $0004
		db $3B,$F6,$F8,$07
		dw $0018
		db $32,$F4,$F0,$00
		db $32,$04,$F0,$01
		db $32,$0C,$F0,$02
		db $32,$F4,$00,$03
		db $32,$04,$00,$04
		db $32,$0C,$00,$05

	.RiseTM00
	.RiseTM01
		dw $0004
		db $3B,$F7,$F3,$07
		dw $0010
		db $32,$F8,$F0,$00
		db $32,$08,$F0,$01
		db $32,$F8,$00,$02
		db $32,$08,$00,$03

	.HoverTM00
	.HoverTM01
	.HoverTM02
		dw $0004
		db $3B,$FE,$F3,$07
		dw $001C
		db $32,$00,$F0,$00
		db $32,$F0,$F8,$01
		db $32,$00,$F8,$02
		db $32,$10,$F8,$03
		db $32,$F0,$00,$04
		db $32,$00,$00,$05
		db $32,$10,$00,$06

	.FDashTM00
	.FDashTM01
	.FDashTM02
		dw $0004
		db $3B,$FE,$F0,$07
		dw $001C
		db $32,$00,$F0,$00
		db $72,$F0,$F8,$01
		db $72,$00,$F8,$02
		db $72,$08,$F8,$03
		db $72,$F0,$00,$04
		db $72,$00,$00,$05
		db $72,$08,$00,$06

	.BDashTM00
	.BDashTM01
	.BDashTM02
		dw $0004
		db $3B,$FE,$F0,$07
		dw $001C
		db $32,$00,$F0,$00
		db $32,$F0,$F8,$01
		db $32,$00,$F8,$02
		db $32,$08,$F8,$03
		db $32,$F0,$00,$04
		db $32,$00,$00,$05
		db $32,$08,$00,$06


	; these should use GFX index 0x83 (conjurex)
	; upload them to hi prio OAM before loading the FDash tilemap
	.GrindTM00
		dw $0004
		db $3B,$0C,$FC,$45
	.GrindTM01
		dw $0004
		db $3B,$0C,$FC,$47
	.GrindTM02
		dw $0004
		db $3B,$0C,$FC,$49


	.GrindCastTM00
		dw $0004
		db $3B,$FC,$EC,$49



	.IdleDyn00
	dw ..End-..Start
	..Start
	%SquareDyn($000)
	%SquareDyn($001)
	%SquareDyn($020)
	%SquareDyn($021)
	..End
	.IdleDyn01
	dw ..End-..Start
	..Start
	%SquareDyn($000)
	%SquareDyn($001)
	%SquareDyn($003)
	%SquareDyn($004)
	..End
	.IdleDyn02
	dw ..End-..Start
	..Start
	%SquareDyn($000)
	%SquareDyn($001)
	%SquareDyn($023)
	%SquareDyn($024)
	..End


	.CastDyn00
	dw ..End-..Start
	..Start
	%SquareDyn($006)
	%SquareDyn($008)
	%SquareDyn($009)
	%SquareDyn($026)
	%SquareDyn($028)
	%SquareDyn($029)
	..End
	.CastDyn01
	dw ..End-..Start
	..Start
	%SquareDyn($00B)
	%SquareDyn($00D)
	%SquareDyn($00E)
	%SquareDyn($02B)
	%SquareDyn($02D)
	%SquareDyn($02E)
	..End


	.RiseDyn00
	dw ..End-..Start
	..Start
	%SquareDyn($040)
	%SquareDyn($042)
	%SquareDyn($060)
	%SquareDyn($062)
	..End
	.RiseDyn01
	dw ..End-..Start
	..Start
	%SquareDyn($080)
	%SquareDyn($082)
	%SquareDyn($0A0)
	%SquareDyn($0A2)
	..End


	.HoverDyn00
	dw ..End-..Start
	..Start
	%SquareDyn($0E0)
	%SquareDyn($044)
	%SquareDyn($046)
	%SquareDyn($048)
	%SquareDyn($054)
	%SquareDyn($056)
	%SquareDyn($058)
	..End
	.HoverDyn01
	dw ..End-..Start
	..Start
	%SquareDyn($0E2)
	%SquareDyn($074)
	%SquareDyn($076)
	%SquareDyn($078)
	%SquareDyn($084)
	%SquareDyn($086)
	%SquareDyn($088)
	..End
	.HoverDyn02
	dw ..End-..Start
	..Start
	%SquareDyn($0E4)
	%SquareDyn($0A4)
	%SquareDyn($0A6)
	%SquareDyn($0A8)
	%SquareDyn($0B4)
	%SquareDyn($0B6)
	%SquareDyn($0B8)
	..End


	.DashDyn00
	dw ..End-..Start
	..Start
	%SquareDyn($0E0)
	%SquareDyn($04A)
	%SquareDyn($04C)
	%SquareDyn($04D)
	%SquareDyn($05A)
	%SquareDyn($05C)
	%SquareDyn($05D)
	..End
	.DashDyn01
	dw ..End-..Start
	..Start
	%SquareDyn($0E2)
	%SquareDyn($07A)
	%SquareDyn($07C)
	%SquareDyn($07D)
	%SquareDyn($08A)
	%SquareDyn($08C)
	%SquareDyn($08D)
	..End
	.DashDyn02
	dw ..End-..Start
	..Start
	%SquareDyn($0E4)
	%SquareDyn($0AA)
	%SquareDyn($0AC)
	%SquareDyn($0AD)
	%SquareDyn($0BA)
	%SquareDyn($0BC)
	%SquareDyn($0BD)
	..End




	.MaskTable
		dw .Mask00
		dw .Mask01
		dw .Mask02
		dw .Mask03

	.Mask00
	dw ..End-..Start
	..Start
	%SquareSkipTiles(7)
	%SquareDyn($0E8)
	..End
	.Mask01
	dw ..End-..Start
	..Start
	%SquareSkipTiles(7)
	%SquareDyn($0EA)
	..End
	.Mask02
	dw ..End-..Start
	..Start
	%SquareSkipTiles(7)
	%SquareDyn($0EC)
	..End
	.Mask03
	dw ..End-..Start
	..Start
	%SquareSkipTiles(7)
	%SquareDyn($0EE)
	..End



	DropMask:
		LDA #$01 : STA !WizrexMask,x
		LDY $3320,x
		STZ $00
		LDA #$18 : STA $01
		LDA DATA_MaskXSpeed,y : STA $02
		LDA #$E8 : STA $03
		LDA #$35 : STA !BigRAM+2

		LDY #$02
		JSL SpawnSpriteTile
		LDY #$07
		LDA.w $F0,y
		REP #$10
		LDX $00
		STA !41_Particle_Tile,x
		LDA !41_Particle_Prop,x
		AND #$0E^$FF
		ORA #$08
		ORA !DynamicProp,y
		STA !41_Particle_Prop,x
		SEP #$10
		LDX !SpriteIndex
		RTS


	DATA:

	.HoverX
		db $40,$C0
	.HoverY
		db $10,$F0

	.GrindSpeed
		db $E0,$20
		db $40,$C0
		db $10,$F0

	.DustOffset
		db $F4,$14

	.GrindVisionX
		db $00,$D0
		db $00,$FF

	.SprayOffset
		db $E0,$20
		db $FF,$00

	.MaskXSpeed
		db $F8,$08

	.EscapeSpeed
		db $D0,$30




	Mask3D:
		LDA $3220,x : STA.l !3D_X+0
		LDA $3250,x : STA.l !3D_X+1
		LDA $3210,x : STA.l !3D_Y+0
		LDA $3240,x : STA.l !3D_Y+1

		PHB
		LDA.b #!3D_Base>>16 : PHA : PLB
		INC.w !3D_AngleXZ+$10
		INC.w !3D_AngleXZ+$20
		INC.w !3D_AngleXZ+$30
		INC.w !3D_AngleXZ+$40

		LDA $14
		LSR #2
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		CLC : ADC #$20
		STA.w !3D_Distance+$11
		STA.w !3D_Distance+$21
		STA.w !3D_Distance+$31
		STA.w !3D_Distance+$41


		LDA $14
		AND #$01 : BNE +
		INC.w !3D_AngleXY+$10
		INC.w !3D_AngleXY+$20
		INC.w !3D_AngleXY+$30
		INC.w !3D_AngleXY+$40
		+
		PLB


		LDY.b #.Start-.Ptr-1
	-	LDA .Ptr,y : STA !3D_TilemapCache,y
		DEY : BPL -
		REP #$20
		LDA.w #!3D_TilemapCache : STA.l !3D_TilemapPointer
		SEP #$20

		JSR .GFX

		LDA !WizrexCircleStatus,x : BMI .NoCircle	;\
		LDA !WizrexMovement,x				; |
		AND #$9F					; | draw circle spell
		CMP #$86 : BNE .NoCircle			; |
		JSR GRAPHICS_CircleCast				; |
		.NoCircle					;/

		LDA $3320,x : JSL !Update3DCluster

		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS

	; DO NOTE flow into GFX here! we need to call GFX before updating the 3D cluster and loading tilemap

		.GFX
		PHP

		SEP #$20
		LDA !SpriteXSpeed,x
		ASL A
		ROL A
		AND #$01
		CMP $3320,x : BEQ ..calc
		REP #$20
		BRA ..idle

	..calc	LDA !SpriteXSpeed,x
		BPL $03 : EOR #$FF : INC A
		REP #$20
		AND #$00FF
		CMP #$0010 : BCC ..dash
	..dash	LDA #$0000 : STA !3D_Extra+$00
		LDA.w #.BigMaskDynDash : BRA ..set
	..idle	LDA $3320,x : STA !3D_Extra+$00
		LDA.w #.BigMaskDynIdle
	..set	STA $0C
		LDY.b #!File_Wizrex
		JSL LOAD_SQUARE_DYNAMO
		PLP
		RTS


		.Init
		PHX
		LDX #$00
	-	LDA.w .Start,x : STA.l !3D_Base,x
		INX
		CPX.b #.End-.Start : BCC -
		PLX

		REP #$20
		LDA.w #.BigMaskDynInit : STA $0C
		SEP #$20
		LDY.b #!File_Wizrex
		JSL LOAD_SQUARE_DYNAMO
		RTS


		.BigMaskDynInit
		dw ..End-..Start
		..Start
		%SquareSkipTiles(4)
		%SquareDyn($0E8)
		%SquareDyn($0EA)
		%SquareDyn($0EC)
		%SquareDyn($0EE)
		..End

		.BigMaskDynIdle
		dw ..End-..Start
		..Start
		%SquareDyn($100)
		%SquareDyn($102)
		%SquareDyn($120)
		%SquareDyn($122)
		..End

		.BigMaskDynDash
		dw ..End-..Start
		..Start
		%SquareDyn($104)
		%SquareDyn($106)
		%SquareDyn($124)
		%SquareDyn($126)
		..End


		.Ptr
		dw !3D_TilemapCache+(.BigMask-.Ptr)
		dw !3D_TilemapCache+(.BigMaskX-.Ptr)
		dw !3D_TilemapCache+(.Mask1-.Ptr)
		dw !3D_TilemapCache+(.Mask2-.Ptr)
		dw !3D_TilemapCache+(.Mask3-.Ptr)
		dw !3D_TilemapCache+(.Mask4-.Ptr)

		.BigMask
		dw $0010
		db $39,$F8,$F8,$00
		db $39,$08,$F8,$01
		db $39,$F8,$08,$02
		db $39,$08,$08,$03
		.BigMaskX
		dw $0010
		db $79,$F8,$F8,$00
		db $79,$08,$F8,$01
		db $79,$F8,$08,$02
		db $79,$08,$08,$03
		.Mask1
		dw $0004
		db $35,$00,$00,$04
		.Mask2
		dw $0004
		db $35,$00,$00,$05
		.Mask3
		dw $0004
		db $35,$00,$00,$06
		.Mask4
		dw $0004
		db $35,$00,$00,$07



	.Start
		; core mask (index 00)
		db $00,$00,$F0		; angles (some around X axis to tilt masks... makes it look better)
		dw $0000		; distance
		dw $0000,$0000,$0080	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $00,$00		; tilemap data

		; mask 1 (index 10)
		db $00,$00,$00		; angles
		dw $2000		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $02,$00		; tilemap data

		; mask 2 (index 20)
		db $00,$40,$00		; angles
		dw $2000		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $03,$00		; tilemap data

		; mask 3 (index 30)
		db $00,$80,$00		; angles
		dw $2000		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $04,$00		; tilemap data

		; mask 4 (index 40)
		db $00,$C0,$00		; angles
		dw $2000		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $05,$00		; tilemap data
	.End






	CAST:
		LDA #$10 : STA !SPC1				; cast SFX
		SEC : LDA #$07					;\ spawn custom sprite 0x07
		JSL SpawnSprite					;/
		CPY #$FF : BEQ .Return
		LDA #$08 : STA $3230,y				; state = 8
		LDA !SpriteTile,x				;\
		CLC : ADC #$45					; | tile options
		STA !SpriteTile,y				; |
		LDA !SpriteProp,x : STA !SpriteProp,y		;/
		LDA.w !SpriteXSpeed,y				;\
		LSR A						; |
		AND #$40					; | prop options
		ORA #$3A					; |
		STA $33C0,y					;/
		LDA #$00 : STA !ProjectileType,y		; type 0 with no collision
		LDA #$32 : STA !ProjectileAnimType,y		; end particle pattern, OAM prio 3
		LDA #$03*2 : STA !ProjectileAnimFrames,y	; 3 anim frames (16x16)
		LDA #$06 : STA !ProjectileAnimTime,y		; 6 frames per anim frame
		LDA #$00 : STA !ProjectileGravity,y		; no gravity
		LDA #$40 : STA !ProjectileTimer,y		; timer = 64 frames
		LDA #!prt_basic : STA !ProjectilePrtNum,y	; particle type = basic
		LDA !SpriteProp,x				;\
		ORA #$2A					; |
		STA !ProjectilePrtProp,y			; | particle settings
		LDA !SpriteTile,x				; |
		CLC : ADC #$5F					; |
		STA !ProjectilePrtTile,y			;/

		.Return
		RTS


	.Target
		PEI ($00)

		LDA $01 : STA $02
		STZ $03
		BPL $02 : DEC $03
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CLC : ADC $02
		LDY !WizrexTargetPlayer,x
		SEC : SBC !P2YLo-$80,y
		STA $02
		LDA $00
		SEC : SBC !P2XLo-$80,y
		STA $00

		SEP #$20
		LDA #$30 : JSL AIM_SHOT
		LDA $04 : STA $02
		LDA $06 : STA $03

		PLA : STA $00
		PLA : STA $01
		JMP CAST



	namespace off










