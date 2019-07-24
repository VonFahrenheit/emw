TarCreeper:

	namespace TarCreeper
	!TarCreeperHands	= $34E608
	!TarCreeperBody		= $34B808

	!TarCreeperGrabStatus	= $3280,x
	!TarCreeperHandL	= $3290,x
	!TarCreeperHandR	= $32A0,x
	!TarCreeperAttack	= $32B0,x
	!TarCreeperPrevDyn	= $3340,x
	!TarCreeperPrevBlock	= $33C0,x
	!TarCreeperLedgeMemLo	= $35D0,x
	!TarCreeperLedgeMemHi	= $35E0,x


	; Increments during arm stretch.
	; Highets 2 bits determine hand state:
	; 00 - fist going forward			00
	; 01 - fist returning				40
	; 10 - open grabby hand				80
	; 11 - grabbed player (SPECIAL BEHAVIOUR!!!)	C0
	; Low nybble determines stretch.		0F 



	INIT:
		PHB : PHK : PLB
		LDA #$FF : STA !TarCreeperLedgeMemHi

		LDA #$FF
		STA $00
		STA $01
		LDY #$00
		LDX #$0F
	-	CPX !SpriteIndex : BEQ ++
		LDA $3230,x
		CMP #$02 : BEQ +
		CMP #$08 : BNE ++
	+	LDA !NewSpriteNum,x
		CMP #$09 : BNE ++
		LDA !ClaimedGFX
		STA $3000,y
		INY

	++	DEX : BPL -
		CPY #$02 : BCC +
	--	LDX !SpriteIndex
		STZ $3230,x
		PLB
		RTL

	+	LDA #$00
	-	CMP $00 : BEQ +
		CMP $01 : BNE ++
	+	CLC : ADC #$06
		CMP #$0C
		BNE -
		BRA --

	++	LDX !SpriteIndex
		STA !ClaimedGFX
		CMP #$00 : BNE +
		JSL !GetVRAM
		REP #$20
		LDA #$0FFF : STA.l !VRAMbase+!VRAMtable+$00,x			; 0x1000 bugs out!?
		LDA.w #!TarCreeperHands : STA.l !VRAMbase+!VRAMtable+$02,x
		LDA.w #!TarCreeperHands>>8 : STA.l !VRAMbase+!VRAMtable+$03,x
		LDA #$7800 : STA.l !VRAMbase+!VRAMtable+$05,x
		SEP #$20
		LDX !SpriteIndex
	+	PLB


	MAIN:
		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE $03 : JMP AI
		JMP GRAPHICS

	DATA:
		.XSpeed
		db $10,$F0


	; Arm register format:
	;	yxrssaaa
	;	y = y flip
	;	x = x flip
	;	r = rotate 90 degrees
	;	s = state
	;	  00 = open
	;	  01 = fist
	;	  10 = little palm
	;	  11 = big palm
	;	a = arm angle

		.Hands
		dw .OpenHand
		dw .Fist
		dw .LittlePalm
		dw .BigPalm
		dw .OpenHandRotate
		dw .FistRotate
		dw .LittlePalmRotate
		dw .BigPalmRotate

		.Arms
		dw .BendDown
		dw .BendForward
		dw .BendUpForward
		dw .BendUp
		dw .StraightUpForward
		dw .StraightUp
		dw .BendUpBack
		dw .BendBack

		.OpenHand
		dw $0004
		db $ED,$00,$00,$80
		.OpenHandRotate
		dw $0004
		db $6D,$00,$00,$82
		.Fist
		dw $0004
		db $6D,$00,$00,$A0
		.FistRotate
		dw $0004
		db $6D,$00,$00,$A2
		.LittlePalm
		dw $0008
		db $6D,$04,$F4,$DE
		db $6D,$04,$FC,$EE
		.LittlePalmRotate
		dw $0008
		db $6D,$F8,$02,$86
		db $6D,$00,$02,$87
		.BigPalm
		dw $000C
		db $6D,$E8,$00,$89
		db $6D,$F8,$00,$8B
		db $6D,$00,$00,$8C
		.BigPalmRotate
		dw $000C
		db $6D,$00,$E8,$8E
		db $6D,$00,$F8,$AE
		db $6D,$00,$00,$BE

		; Arm tilemaps end with X/Y displacements for hand tiles
		.BendDown
		dw $0004
		db $AD,$00,$00,$C4
		db $0C,$0B
		.BendForward
		dw $0008
		db $AD,$00,$FE,$C0
		db $AD,$08,$FE,$C1
		db $16,$F9
		.BendUpForward
		dw $0004
		db $2D,$00,$F3,$C4
		db $0C,$EA
		.BendUp
		dw $0004
		db $2D,$00,$EF,$C4
		db $0C,$E6
		.StraightUpForward
		dw $0004
		db $2D,$01,$ED,$A4
		db $01,$E4
		.StraightUp
		dw $0004
		db $2D,$01,$E9,$A4
		db $01,$E0
		.BendUpBack
		dw $0004
		db $6D,$10,$EF,$C4
		db $F0,$E6
		.BendBack
		dw $0008
		db $6D,$10,$F6,$C0
		db $6D,$18,$F6,$C1
		db $DA,$FA

		; X disp, Y disp, Width, Height, 2 empty bytes (0xFFFF)
		.PalmBox
		dw $FFE8,$0000 : db $28,$0C : dw $FFFF		; ---  horz
		dw $0004,$0000 : db $0C,$28 : dw $FFFF		; --r  vert
		dw $0000,$0000 : db $28,$0C : dw $FFFF		; -x-  horz
		dw $0000,$0000 : db $0C,$28 : dw $FFFF		; -xr  vert
		dw $FFE8,$0004 : db $28,$0C : dw $FFFF		; y--  horz
		dw $0004,$FFE8 : db $0C,$28 : dw $FFFF		; y-r  vert
		dw $0000,$0004 : db $28,$0C : dw $FFFF		; yx-  horz
		dw $0000,$FFE8 : db $0C,$28 : dw $FFFF		; yxr  vert


		.VectorX
		db $20,$E0					; > Punch
		db $40,$C0					; > Push

		.GrabNext
		db $FF,$00,$80,$EE				; nothing, 1, 2, special

		.HandQuadrant
		db $02,$03,$05,$07				; left, right, topleft, topright

.HandL		db $38,$00,$1C,$00,$38,$38,$38,$1C,$5C,$1C
.HandR		db $00,$38,$00,$1C,$38,$5C,$1C,$38,$38,$1C
.UpSide		db $00,$00,$01,$01,$FF,$00,$01,$01,$00,$FF




; Scratch RAM usage for hand position AI:
;
; $00-$01:	Sprite Xpos
; $02-$03:	Sprite Ypos
; $04:		Accumulating angle values
; $05:		Backup for Y
; $06-$07:	dX during calculation
; $08-$09:	dY during calculation
; $0A-$0F:	-------

	AI:
		LDA $32D0,x					;\
		BEQ .NotDead					; | No AI when dead
		CMP #$01 : BNE .KeepBurning			; |
		STZ $3230,x					; > Delete sprite when it's finished burning
		.KeepBurning					; |
		JMP PHYSICS					; |
		.NotDead					;/

		LDA !ExtraBits,x				;\ Check for extra bit
		AND #$04 : BEQ .NoLedgeCalc			;/
		LDA $3250,x : STA $01 : XBA			;\
		LDA $3220,x : STA $00				; |
		LDY !TarCreeperAttack : BNE ++			; > Don't turn around during attack
		REP #$20					; |
		SEC : SBC !P2XPosLo-$80				; |
		BPL $03 : EOR #$FFFF				; |
		STA $02						; |
		LDA $00						; |
		SEC : SBC !P2XPosLo				; | Face the player that is furthest away
		BPL $03 : EOR #$FFFF				; | if extra bit is set
		CMP $02						; |
		SEP #$20					; |
		BCS .TargetP2					; |
.TargetP1	JSR SUB_HORZ_POS_1				; |
		BRA +						; |
.TargetP2	JSR SUB_HORZ_POS_2				; |
	+	TYA : STA $3320,x				;/
	++	STZ $03						;\
		LDA $3320,x					; |
		ASL #4						; |
		SEC : SBC #$08					; |
		STA $02						; |
		BPL $02 : DEC $03				; |
		LDA $00						; | Assume there's a ledge if extra bit is set
		SEC : SBC $02					; |
		STA !TarCreeperLedgeMemLo			; |
		LDA $01						; |
		SBC $03						; |
		STA !TarCreeperLedgeMemHi			; |
		.NoLedgeCalc					;/

		LDA !TarCreeperGrabStatus			;\
		AND.b #$20^$FF					; | Clear this bit (notes big palm range)
		STA !TarCreeperGrabStatus			;/
		LDA !TarCreeperHandL				;\
		AND #$38					; |
		CMP #$18 : BEQ .NoAttack			; | No attack while hands are up
		LDA !TarCreeperHandR				; |
		AND #$38					; |
		CMP #$18 : BEQ .NoAttack			;/
		JSR SUB_HORZ_POS				;\
		TYA						; |
		CMP $3320,x					; |
		BEQ .Attack					; | Only attack if facing at least one player
		JSR SUB_HORZ_POS_2				; |
		TYA						; |
		CMP $3320,x					; |
		BNE .NoAttack					;/
	.Attack	BIT !TarCreeperGrabStatus : BVS .NoAttack	; > Only one attack at a time
		LDA !TarCreeperGrabStatus			;\
		BPL .NoAttack					; | Make one attack as soon as someone enters range
		ORA #$40					; |
		STA !TarCreeperGrabStatus			;/
		LDA !RNG					;\ Randomly decide between punch and grab
		LSR A : BCS .Grab				;/
	.Punch	LDA #$01 : STA !TarCreeperAttack		;\
		LDA #$13 : STA !SpriteAnimIndex			; | Execute punch
		STZ !SpriteAnimTimer				; |
		JMP .NoHands					;/
	.Grab	LDA !TarCreeperLedgeMemHi			;\ Only grab if there's a ledge
		BMI .Punch					;/
	.Ledge	LDA #$80 : STA !TarCreeperAttack		;\
		LDA #$1D : STA !SpriteAnimIndex			; | Execute grab
		STZ !SpriteAnimTimer				; |
		JMP .NoHands					;/
		.NoAttack

		STZ !TarCreeperHandL				;\ Start at 0
		STZ !TarCreeperHandR				;/
		LDA !TarCreeperAttack				;\ Only move hands when attack is not taking place
		BEQ .ProcessHands				;/
		JMP .NoHands					; >

		.ProcessHands
		LDA !TarCreeperGrabStatus
		AND.b #$80^$FF
		STA !TarCreeperGrabStatus

		STZ $2250					; > Enable multiplication
		LDY #$00					; > Y starts at 0x00
		LDA $3220,x : STA $00				;\
		LDA $3250,x : STA $01				; |
		LDA $3240,x : XBA				; | $00 = sprite X (16-bit)
		LDA $3210,x					; | $02 = sprite Y (16-bit)
		REP #$20					; |
		STA $02						;/
		STZ $04						;\ $04 = 0x01
		INC $04						;/ $05 = 0x00

	-	SEC : SBC !P2YPosLo-$80,y			; > Subtract player Y
		STA $08						; > $08 = dY
		LDA !P2Status-$80,y				;\ Don't care about dead players
		AND #$00FF : BEQ $03 : JMP .End			;/
		TYA						;\
		CLC						; |
		XBA : ROL #2					; |
		INC A						; |
		STA $0E						; |
		LDA !CurrentMario				; | Account for Mario's natural displacement
		AND #$00FF					; |
		CMP $0E						; |
		BNE +						; |
		LDA $08						; |
		SEC : SBC #$0010				; |
		STA $08						;/
	+	LDA $00
		SEC : SBC !P2XPosLo-$80,y
		PHP
		STY $05						;\ Switch Y
		LDY #$00					;/
		PLP
		BPL .PosX
		EOR #$FFFF : INC A
		INY
	.PosX	STA $06						; > $06 = dX
		CMP #$0050 : BCS .End				; > Must be within 0x50 xpx to matter
		CMP #$0038 : BCS .Small
		LDA !TarCreeperGrabStatus			;\
		ORA #$0020					; | Note that someone is within big palm range
		STA !TarCreeperGrabStatus			;/
	.Small	LDA $08
		BPL .PosY
		EOR #$FFFF : INC A
	.PosY	CMP #$0060 : BCS .End				; > Must be within 0x60 ypx to matter
		BIT $08 : BPL .Calc				;\
		CMP #$0020 : BCS .End				; > Ignore if more than 0x20 ypx below
	--	SEP #$20					; | Ignore angle if player is below tar creeper
		LDA DATA_HandQuadrant,y				; |
		BRA +						;/

	.Calc	CMP #$0020 : BCC --				; > Must be at least 0x20 px above
		CMP $06						;\
		SEP #$20					; | Check angle to player
		BCC $02 : INY #2				; |
		LDA.w DATA_HandQuadrant,y			;/
	+	BIT $05 : BPL +					; > The first one doesn't have to be multiplied
		STA $2251					;\
		STZ $2252					; |
		LDA $04 : STA $2253				; |
		STZ $2254					; | Multiply primes
		NOP						; |
		BRA $00						; |
		LDA $2306					; |
	+	STA $04						;/

		LDY $05						;\
		LDA !P2Blocked-$80,y				; | Only attack players that are on the ground
		AND #$04 : BEQ .End				;/
		LDA !TarCreeperGrabStatus			;\
		ORA #$80					; | Note that someone is in attack range
		STA !TarCreeperGrabStatus			;/

		.End
		SEP #$20
		LDY $05 : BMI .SetHands
		LDA !MultiPlayer : BEQ .SetHands
		LDY #$80
		REP #$20
		LDA $02
		JMP -

		.SetHands
		LDA $04
		CMP #$02 : BEQ .Left
		CMP #$04 : BEQ .Left
		CMP #$03 : BEQ .Right
		CMP #$09 : BEQ .Right
		CMP #$05 : BEQ .TopLeft
		CMP #$19 : BEQ .TopLeft
		CMP #$07 : BEQ .TopRight
		CMP #$31 : BEQ .TopRight
		CMP #$06 : BEQ .Sides
		CMP #$0A : BEQ .CornerLeft
		CMP #$0E : BEQ .SplitLeft
		CMP #$0F : BEQ .SplitRight
		CMP #$15 : BEQ .CornerRight
		CMP #$23 : BEQ .Up
		JMP .NoHands

.Left		LDY #$00 : BRA .Done
.Right		LDY #$01 : BRA .Done
.TopLeft	LDY #$02 : BRA .Done
.TopRight	LDY #$03 : BRA .Done
.Sides		LDY #$04 : BRA .Done
.CornerLeft	LDY #$05 : BRA .Done
.SplitLeft	LDY #$06 : BRA .Done
.SplitRight	LDY #$07 : BRA .Done
.CornerRight	LDY #$08 : BRA .Done
.Up		LDY #$09

		.Done
		LDA DATA_HandL,y : STA !TarCreeperHandL		;\ Store hand values based on prime product
		LDA DATA_HandR,y : STA !TarCreeperHandR		;/
		LDA !TarCreeperGrabStatus			;\
		AND #$20					; |
		BNE .BigPalm					; |
		LDA !TarCreeperHandL				; |
		BEQ +						; |
		AND.b #$08^$FF					; |
		EOR #$20					; | Set hands to small if no one is close enough
		STA !TarCreeperHandL				; |
	+	LDA !TarCreeperHandR				; |
		BEQ .BigPalm					; |
		AND.b #$08^$FF					; |
		EOR #$20					; |
		STA !TarCreeperHandR				; |
		.BigPalm					;/

		LDA !ExtraBits,x
		AND #$04 : BEQ .NoHands				; No special animation if extra bit is clear
		LDA DATA_UpSide,y
		BMI .IdleAnim
		BEQ .SideAnim

		.UpAnim
		LDA !SpriteAnimIndex
		CMP #$0D : BCC +
		CMP #$10 : BCC .NoHands
	+	LDA #$0D : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .NoHands

		.IdleAnim
		LDA !SpriteAnimIndex
		CMP #$08 : BCC .NoHands
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .NoHands

		.SideAnim
		LDA !SpriteAnimIndex
		CMP #$10 : BCC +
		CMP #$13 : BCC .NoHands
	+	LDA #$10 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		.NoHands

		LDA !TarCreeperGrabStatus			;\
		BMI .StillInRange				; |
		AND.b #$40^$FF					; | Allow another attack after someone leaves range
		STA !TarCreeperGrabStatus			; |
		.StillInRange					;/



	PHYSICS:

		LDA !SpriteAnimIndex
		CMP #$25 : BCS .NoFireball
		JSR HITBOX_BODY
		JSR FireballContact
		BCC .NoFireball

		LDA #$0F : STA $776F+$08,y		;\ Destroy fireball
		LDA #$01 : STA $770B+$08,y		;/
		LDA #$FF : STA $32D0,x			; > Set death timer
		LDA #$25 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !TarCreeperHandL
		STZ !TarCreeperHandR
		STZ !TarCreeperAttack
		STZ !TarCreeperGrabStatus
		.NoFireball

		LDA !SpriteAnimIndex
		CMP #$19 : BEQ .Attack
		CMP #$23 : BEQ .Attack
		CMP #$24 : BEQ .Attack
		CMP #$27 : BNE +					;\ Death check
		LDA #$83 : STA !TarCreeperHandL : STA !TarCreeperHandR	;/

	-
	+	JMP .NoAttack
.Attack		STZ $0F
		LDA !TarCreeperAttack
		BEQ -
		AND #$C0 : BNE $03 : JMP .FistForward
		CMP #$40 : BEQ .FistReturn
		CMP #$80 : BEQ .GrabForward

		.GrabSuccess
		LDA !TarCreeperAttack
		DEC A
		CMP #$C6 : BEQ +
		STA !TarCreeperAttack
		JMP .NoAttack
	+	LDA !TarCreeperGrabStatus
		AND #$03 : TAY
		LDA !TarCreeperGrabStatus
		AND.b #$03^$FF
		STA !TarCreeperGrabStatus
		LDA DATA_GrabNext,y
		CMP #$FF : BEQ ++
		CMP #$EE : BNE .OnePlayer
		STA $0F
		LDA #$00

		.OnePlayer
		TAY
		JSR CheckMario
		BNE ..NotMario
		STZ !MarioXSpeed
		STZ !MarioYSpeed
		..NotMario
		LDA #$00
		STA !P2XSpeed-$80,y
		STA !P2YSpeed-$80,y
		LDA #$30 : STA !P2VectorTimeX-$80,y
		LDA $3220,x : CMP !TarCreeperLedgeMemLo	;\ Check direction to ledge
		LDA $3250,x : SBC !TarCreeperLedgeMemHi	;/
		BCC .PushRight

		.PushLeft
		LDA #$C0 : STA !P2VectorX-$80,y
		LDA #$01 : STA !P2VectorAccX-$80,y
		BRA ++

		.PushRight
		LDA #$40 : STA !P2VectorX-$80,y
		LDA #$FF : STA !P2VectorAccX-$80,y
		BRA ++

		.GrabForward
		LDA !TarCreeperAttack
		INC A
		CMP #$90 : BNE +
		INC !SpriteAnimIndex
		LDA #$CE : BRA +

		.FistReturn
		LDA !TarCreeperAttack
		DEC A
		CMP #$44 : BNE +
	++	LDA $0F					;\
		CMP #$EE : BNE .NotBoth			; | 2 player grab loop
		STZ $0F					; |
		LDA #$80 : BRA .OnePlayer		;/

		.NotBoth
		STZ !TarCreeperAttack			;\
		STZ !SpriteAnimIndex			; | Reset attack and animation
		STZ !SpriteAnimTimer			;/
		BRA .NoAttack

		.FistForward
		LDA !TarCreeperAttack
		INC A
		CMP #$10 : BNE +
		LDA #$4E
	+	STA !TarCreeperAttack
		.NoAttack


		STZ $AE,x				; > No base speed
		LDA $32D0,x : BNE .NoWalk		; > Don't walk while dying
		LDA !ExtraBits,x			;\ Don't walk if extra bit is set
		AND #$04 : BNE .NoWalk			;/
		LDA !TarCreeperAttack : BNE .NoWalk	; > Don't walk during attack
		LDA !SpriteAnimIndex			;\
		CMP #$1A : BCC .Walk			; | Don't walk during uppercut
		CMP #$1D : BCC .NoWalk			;/

		.Walk					;\
		LDY $3320,x				; |
		LDA.w DATA_XSpeed,y			; | Apply walk speed
		STA $AE,x				; |
		.NoWalk					;/

		LDA $3330,x : STA !TarCreeperPrevBlock
		JSL !SpriteApplySpeed

		LDA $3330,x
		EOR !TarCreeperPrevBlock
		AND #$04
		BEQ .NoLedge
		LDA $3220,x : STA !TarCreeperLedgeMemLo	;\ Remember location of ledge
		LDA $3250,x : STA !TarCreeperLedgeMemHi	;/
		LDA $AE,x
		EOR #$FF : INC A
		STA $AE,x
		STZ $9E,x
		JSL !SpriteApplySpeed
		BRA .Turn
		.NoLedge

		LDA $3330,x
		AND #$03
		BEQ .NoTurn

		.Turn
		LDA $3320,x
		EOR #$01
		STA $3320,x
		.NoTurn




	INTERACTION:


	; Since Mario uses the vector regs now, I can just use the player regs for hitboxes

		LDA !TarCreeperAttack
		BEQ .NoFist
		AND #$C0 : BEQ .PunchForward
		CMP #$80 : BEQ .GrabbyHand
		BRA .NoFist

		.GrabbyHand
		LDA !SpriteAnimIndex			;\ No hitbox during windup
		CMP #$23 : BCC .NoFist			;/
		JSR HITBOX_BIG_GRABBY
		SEC : JSL !PlayerClipping
		BCC .NoFist
		LSR A : BCC +
		LDA !TarCreeperGrabStatus
		ORA #$01
		STA !TarCreeperGrabStatus
		BRA .NoFist
	+	LSR A : BCC .NoFist
		LDA !TarCreeperGrabStatus
		ORA #$02
		STA !TarCreeperGrabStatus

		.PunchForward
		LDA !SpriteAnimIndex			;\ No hitbox during windup
		CMP #$18 : BCC .NoFist			;/
		JSR HITBOX_BIG_FIST
		SEC : JSL !PlayerClipping
		BCC .NoFist
		PHA
		JSR KnockBack
		PLA
		JSL !HurtPlayers
		.NoFist


		LDA !TarCreeperGrabStatus
		AND #$03 : BEQ .NoGrab
		PHA
		JSR HITBOX_BIG_GRABBY
		LDY #$00
		LDA $01,s
		LSR A : BCC .P2Grab

	-	LDA #$02 : STA !P2Stasis-$80,y
		TYA
		JSR CheckMario
		BNE +
		LDA $04
		CLC : ADC #$10
		STA !MarioXPosLo
		LDA $0A
		ADC #$00
		STA !MarioXPosHi
		LDA $05 : STA !MarioYPosLo
		LDA $0B : STA !MarioYPosHi
		BRA .P2Grab
	+	LDA $04
		CLC : ADC #$10
		STA !P2XPosLo-$80,y
		LDA $0A
		ADC #$00
		STA !P2XPosHi-$80,y
		LDA $05
		CLC : ADC #$10
		STA !P2YPosLo-$80,y
		LDA $0B
		ADC #$00
		STA !P2YPosHi-$80,y

		.P2Grab
		TYA : BMI .NoGrab				; > Grab is done if Y is negative
		PLA
		AND #$02 : BEQ .NoGrab
		LDY #$80
		BRA -
		.NoGrab


		LDA !SpriteAnimIndex
		CMP #$1C : BNE .NoUppercut
		LDA !SpriteAnimTimer
		CMP #$04 : BCS .NoUppercut
		JSR HITBOX_UPPERCUT
		SEC : JSL !PlayerClipping
		BCC .NoUppercut
		PHA
		JSR KnockBack
		PLA
		JSL !HurtPlayers
		.NoUppercut


	GRAPHICS:

		LDA $32D0,x				;\
		BEQ .NotDead				; |
		CMP #$60 : BCS .ProcessAnim		; |
		LDA !SpriteAnimIndex			; | Special animation rules for death
		CMP #$2B				; |
		BCS .ProcessAnim			; |
		LDA #$2B : STA !SpriteAnimIndex		; |
		BRA .ProcessAnim			; |
		.NotDead				;/


		LDA $AE,x				;\
		BEQ .ProcessAnim			; |
		LDA !SpriteAnimIndex			; |
		CMP #$08 : BCC +			; | Apply walk animation if there is X speed
		CMP #$0D : BCC .ProcessAnim		; |
	+	LDA #$08 : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer			;/


		.ProcessAnim
		STZ $01
		LDA !SpriteAnimIndex
		STA $00
		REP #$30				; > Index must be 16 bit this entire time!
		AND #$00FF
		ASL #2
		CLC : ADC $00
		ASL A
		TAY
		SEP #$20				; > A 8 bit
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		STZ $01
		LDA.w ANIM+3,y
		STA !SpriteAnimIndex
		STA $00
		REP #$20				; > A 16 bit
		AND #$00FF
		ASL #2
		CLC : ADC $00
		ASL A
		TAY
		SEP #$20
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer			; > Update animation timer
		TYA : PHA				; > Push 8 bit Y
		CMP !TarCreeperPrevDyn			;\
		REP #$20				; |
		BEQ .NoDynamo				; |
		LDA.w ANIM+4,y				; | Update GFX (A is always 16 bit after this)
		STA $0C					; |
		LDA !ClaimedGFX				; \ Include claimed GFX
		AND #$00FF : STA $02			; /
		PHY					; |
		SEC : JSL !UpdateGFX			; |
		PLY					;/
		.NoDynamo

		LDA.w ANIM+0,y : STA $04		; > Body tilemap
		LDA $3320,x
		AND #$00FF
		BEQ .ArmsRight				; > Check sprite direction

		.ArmsLeft
		STZ $08					; > Base X flip (left)
		LDA #$40FF : STA $0A			; > Extra X flip for arms (left)
		LDA.w ANIM+6,y				;\
		EOR #$00FF				; |
		STA $0E					; | Shoulder coords (left)
		LDA.w ANIM+8,y				; |
		EOR #$00FF				; |
		STA $0C					;/
		BRA .AllArms

		.ArmsRight
		STZ $08					; > Base X flip (right)
		STZ $0A					; > Extra X flip for arms (right)
		LDA.w ANIM+6,y : STA $0C		;\ Shoulder coords (right)
		LDA.w ANIM+8,y : STA $0E		;/


		.AllArms
		LDA ($04) : STA !BigRAM+0
		INC $04
		INC $04
		SEP #$30				; > All regs 8 bit
		LDA !ClaimedGFX : STA $00		; > $00 = claim offset
		PLA : STA !TarCreeperPrevDyn		; > Store dynamo for next frame
		LDX #$00
		LDY #$00


	-	LDA ($04),y				;\
		STA !BigRAM+2,x				; |
		LSR A : PHP				; > Save lowest bit
		INY					; |
		LDA ($04),y				; |
		STA !BigRAM+3,x				; |
		INY					; |
		LDA ($04),y				; | Copy body tilemap to !BigRAM
		STA !BigRAM+4,x				; |
		INY					; |
		LDA ($04),y				; |
		PLP : BCS .Static			; |
		ADC $00					; > Add claim offset
	.Static	STA !BigRAM+5,x				; |
		INX #4					; |
		INY					; |
		CPX !BigRAM+0				; |
		BCC -					;/

		PHX		
		LDX !SpriteIndex
		LDA !SpriteAnimIndex			;\
		CMP #$13 : BCS $03 : JMP .Arms		; | Don't draw normal arms during attack
		CMP #$19 : BEQ .Stretch			; | Stretch arm during frames 0x19 and 0x23-0x24
		CMP #$23 : BEQ .Stretch			; |
		CMP #$24 : BEQ .Stretch			;/
		CMP #$25 : BCC +			;\
		CMP #$2B : BCS +			; | Show arms during initial death animation
		JMP .Arms				; |
	+	JMP .NoStretch				;/

		.Stretch
		LDA !TarCreeperAttack			;\
		AND #$0F				; | Take attack counter times 8
		ASL #3					;/
		BIT !TarCreeperAttack			;\
		BVS +					; |
		ASL A					; | Times 16 when going out
		CMP #$80				; |
		BCC $02 : LDA #$70			;/
	+	STA $00

		LDY #$00				; > Grab
		LDA !TarCreeperAttack
		AND #$C0 : CMP #$C0
		BEQ .GrabSuccess

		LDY #$10				; > No grab
		LDA !BigRAM+$03
		SEC : SBC $00
		STA !BigRAM+$03
		LDA !BigRAM+$07
		SEC : SBC $00
		STA !BigRAM+$07
		LDA !BigRAM+$0B
		SEC : SBC $00
		STA !BigRAM+$0B
		LDA !BigRAM+$0F
		SEC : SBC $00
		STA !BigRAM+$0F

		.GrabSuccess
		LDX #$00				; > Tiles to add to tilemap
		LDA $00					; > Amount of pixels that hand has moved
		CMP #$10 : BCC .2back			;
		CMP #$18 : BCC .1back			;
		CMP #$28 : BCC .0arm
		CMP #$48 : BCC .1forward
		CMP #$58 : BCC .2forward
		CMP #$68 : BCC .3forward
		CMP #$78 : BCC .4forward
		BRA .5forward
.2back		LDA #$16 : STA !BigRAM+$17,y : INX
.1back		LDA #$06 : STA !BigRAM+$13,y : INX
		BRA .0arm
.5forward	LDA #$B6 : STA !BigRAM+$13,y : INX
.4forward	LDA #$C6 : STA !BigRAM+$1F,y : INX
.3forward	LDA #$D6 : STA !BigRAM+$1B,y : INX
.2forward	LDA #$E6 : STA !BigRAM+$17,y : INX
.1forward	LDA #$F6 : STA !BigRAM+$13,y : INX
.0arm		TXA : BEQ .NoStretch
		ASL #2
		TAX
		CLC : ADC !BigRAM
		STA !BigRAM

		CPY #$10
		BEQ +
	-	LDA #$2D : STA !BigRAM+$12-4,x
		LDA #$FC : STA !BigRAM+$14-4,x
		LDA #$84 : STA !BigRAM+$15-4,x
		DEX #4
		BNE -
		BRA .NoStretch
		+
	-	LDA #$2D : STA !BigRAM+$22-4,x
		LDA #$FC : STA !BigRAM+$24-4,x
		LDA #$84 : STA !BigRAM+$25-4,x
		DEX #4
		BNE -


		.NoStretch
		PLA					;\ Draw body without caring for arms
		JMP .ArmsDone				;/

		.Arms
		LDA !TarCreeperHandL

		.SecondArmLoop
		PLX


		STA $00					; > Full data at $00
		AND #$C0				;\ Hand XY bits at $01
		STA $01					;/


		LDA $00					;\
		AND #$07				; | Use aaa bits to index arm data
		ASL A					; |
		TAY					;/

		REP #$20
		LDA.w DATA_Arms,y
		STA $04
		LDA ($04)
		CLC : ADC !BigRAM+0			;\ Increase header at !BigRAM
		STA !BigRAM+0				;/
		INC $04
		INC $04
		SEP #$20
		LDY #$00

	-	LDA ($04),y				;\
		EOR $08					; |
		STA !BigRAM+2,x				; |
		INY					; |
		LDA ($04),y				; |
		BIT !BigRAM+2,x
		BVC $02 : EOR #$FF
		CLC : ADC $0C				;  > Add shoulder X disp
		BIT !BigRAM+2,x				; |
		BVC $02 : EOR #$FF			; |
		STA !BigRAM+3,x				; | Add arm tilemap to !BigRAM

	LDA !BigRAM+2,x
	EOR $0B
	STA !BigRAM+2,x

		INY					; |
		LDA ($04),y				; |
		CLC : ADC $0D				;  > Add shoulder Y disp
		STA !BigRAM+4,x				; |
		INY					; |
		LDA ($04),y				; |
		STA !BigRAM+5,x				; |
		INY					; |
		INX #4					; |
		CPX !BigRAM+0				; |
		BCC -					;/

		LDA ($04),y				;\
		BIT $08					; |
		BVC $02 : EOR #$FF			; |
		CLC : ADC $0C				; |
		STA $0C					; | Add arm disp to shoulder disp in scratch RAM
		INY					; |
		LDA ($04),y				; |
		CLC : ADC $0D				; |
		STA $0D					;/


		LDA $00					;\
		AND #$38				; | Use rss bits to index hand data
		LSR #2					; |
		TAY					;/

		REP #$20
		LDA.w DATA_Hands,y
		STA $04
		LDA ($04)
		CLC : ADC !BigRAM+0			;\ Increase header at !BigRAM
		STA !BigRAM+0				;/
		INC $04
		INC $04
		SEP #$20
		LDY #$00
		PHX

	-	LDA ($04),y				;\
		EOR $01					; | Add flip bits and store prop
		EOR $08					; |
	EOR $0B
		STA !BigRAM+2,x				;/
		INY
		LDA ($04),y

		BIT $08					;\
		BVC +					; |
		BIT $01					; |
		BVS ++					; |
		BRA +++
	+	BIT $01					; | Special hand X flip
		BVS +++					; |
	++	EOR #$FF				;/
		+++

	;	BIT !BigRAM+2,x
	;	BVC $02 : EOR #$FF
		CLC : ADC $0C				; > Add arm X disp
		BIT !BigRAM+2,x				;\ Handle X flip
		BVC $02 : EOR #$FF			;/
	EOR $0A
		STA !BigRAM+3,x				; > Store to tilemap
		INY
		LDA ($04),y
		BIT !BigRAM+2,x				;\ Y flip function for vertical palms
		BPL $02 : EOR #$FF			;/
		CLC : ADC $0D				; > Add arm Y disp
		STA !BigRAM+4,x
		INY
		LDA ($04),y
		STA !BigRAM+5,x
		INY
		INX #4
		CPX !BigRAM+0
		BCC -

		LDA $09 : BNE .ArmsDone

		LDA $08					;\
		EOR #$40				; | Base X flip for second arm
		STA $08					;/
		INC $09					; > Increment arm counter
		LDA $0E : STA $0C			;\ Get next set of shoulder coords
		LDA $0F : STA $0D			;/
		PHX					;\ (X is pulled after the jump)
		LDX !SpriteIndex			; | Get data for second arm and repeat
		LDA !TarCreeperHandR			; |
		JMP .SecondArmLoop			;/


		.ArmsDone
		LDA.b #!BigRAM : STA $04		;\ Tilemap is at !BigRAM
		LDA.b #!BigRAM>>8 : STA $05		;/
		LDX !SpriteIndex
		JSR LOAD_TILEMAP



		LDA !TarCreeperAttack			;\
		AND #$C0 : CMP #$C0			; | Check for hi prio hand
		BEQ .HiPrioHand				; |
		JMP INTERACTION_2			;/

		.HiPrioHand
		LDA !TarCreeperAttack			;\
		AND #$0F				; |
		ASL #3					; |
		STA $0A					; |
		STZ $0B					; |
		REP #$20				; |
		LDA $00					; | Get x position of hand based on attack counter
		LDY $3320,x : BEQ +			; |
		SEC : SBC $0A				; |
		BRA ++					; |
	+	CLC : ADC $0A				; |
	++	STA $00					;/
		TSC : STA $0A				; > Stack pointer backup in case enough slots aren't found
		SEP #$20

		LDX #$00				; > OAM index
		LDY #$03				; > Loop counter
		LDA #$F0				; > Y pos to search for
	-	CMP.w !OAM+$001,x			;\
		BNE +					; |
		PHX					; |
		DEY					; | Look for 4 empty slots in the lo half of OAM
		BMI ++					; |
	+	INX #4					; |
		BNE -					; |
		JMP .PrioHandEnd			; |
		++					;/
		PLX
		LDA #$10 : STA $08


		LDY #$00
	-	LDA.w ANIM_HiPrioHandTM,y
		EOR $0C
		STA !OAM+$003,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA.w ANIM_HiPrioHandTM,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		PLX
		INY #3
		SEP #$20
		CPY $08
		BNE -
		BRA .PrioHandEnd

.GoodX		STA $06
		INY
		LDA.w ANIM_HiPrioHandTM,y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		PLX
		INY #2
		SEP #$20
		CPY $08
		BNE -
		BRA .PrioHandEnd

.GoodY		SEP #$20
		STA !OAM+$001,x
		LDA $06
		STA !OAM+$000,x
		INY
		LDA.w ANIM_HiPrioHandTM,y
		STA !OAM+$002,x
		INY
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$00,x
		CPY $08
		BEQ .PrioHandEnd
		PLX
		JMP -

.PrioHandEnd	LDX !SpriteIndex			; > Restore sprite index
		LDA $0B : XBA				;\ Restore stack pointer
		LDA $0A : TCS				;/





	INTERACTION_2:

		LDA !SpriteAnimIndex
		CMP #$13 : BCC .Arms
		CMP #$25 : BCS $03 : JMP .NoArms
		CMP #$2B : BCC $03 : JMP .NoArms

		.Arms
		LDA !TarCreeperHandR
		AND #$18
		CMP #$18
		BEQ .R
		PLA					; > Pop index to avoid stack overflow
		BRA .NoR

		.R
		LDA !TarCreeperHandR			;\
		JSR HITBOX_BIGPALM			; | See if right hand is touching a player
		SEC : JSL !PlayerClipping		;/
		PLY					; > Pop index to avoid stack overflow
		BCC .NoR				; > No interaction if no one touches the hand
		TAY
		LDA !TarCreeperHandR
		AND #$20 : BNE .BumpRight

		.PlatformRight
		PEA.w .NoR-1
		JMP .Platform

		.BumpRight
		JSR .Bump
		.NoR


		LDA !TarCreeperHandL
		AND #$18
		CMP #$18
		BEQ .L
		PLA					; > Pop index to avoid stack overflow
		BRA .NoArms

		.L
		LDA !TarCreeperHandL			;\
		JSR HITBOX_BIGPALM			; | See if right hand is touching a player
		SEC : JSL !PlayerClipping		;/
		PLY					; > Pop index to avoid stack overflow
		BCC .NoArms				; > No interaction if no one touches the hand
		TAY
		LDA !TarCreeperHandL
		AND #$20 : BNE .BumpLeft

		.PlatformLeft
		PEA.w .NoArms-1
		JMP .Platform

		.BumpLeft
		JSR .Bump

		.NoArms
		PLB
		RTL



		.Platform
		TYA
		LSR A : BCC ..P2
	..P1	PHA
		LDY #$00 : JSR ..Main
		PLA
	..P2	LSR A : BCC ..Return
		LDY #$80 : JSR ..Main
		RTS

		..Main
		TYA
		JSR CheckMario
		BNE ..PCE
		..Mario
		BIT !MarioYSpeed : BMI ..Return
		STZ !MarioYSpeed
		LDA #$03 : STA $7471
		LDA $05
		SEC : SBC #$1E
		STA $96
		LDA $0B
		SBC #$00
		STA $97
		BRA +
		..PCE
		LDA !P2YSpeed-$80,y : BMI ..Return
		LDA #$00 : STA !P2YSpeed-$80,y
		TXA : STA !P2SpritePlatform-$80,y
		LDA $05
		SEC : SBC #$0E
		STA !P2YPosLo-$80,y
		LDA $0B
		SBC #$00
		STA !P2YPosHi-$80,y
	+	LDA $AE,x : STA !P2VectorX-$80,y
		..Return
		RTS


		.Bump
		TYA
		LSR A : BCC ..P2
	..P1	PHA
		LDY #$00 : JSR ..Main
		PLA
	..P2	LSR A : BCC ..Return
		LDY #$80 : JSR ..Main
		RTS

		..Main
		TYA
		JSR CheckMario
		BNE ..PCE
		..Mario
		STZ !MarioXSpeed
		BRA +
		..PCE
		LDA #$00 : STA !P2XSpeed-$80,y
	+	PHY
		TYA : BMI ..Bump2
	..Bump1	PEA.w ..End-1 : JMP SUB_HORZ_POS_1
	..Bump2	JSR SUB_HORZ_POS_2
	..End	LDA DATA_VectorX+2,y
		PLY
		STA !P2VectorX-$80,y
		..Return
		RTS


	ANIM:
	.AnimIdle

		; 4 5 1 2
		; 3 2 1 5

		dw .IdleTM00 : db $08,$01		; 00
		dw .IdleDyn00
		db $08,$F8,$F4,$F6
		dw .IdleTM01 : db $08,$02		; 01
		dw .IdleDyn01
		db $0B,$F4,$F5,$F4
		dw .IdleTM02 : db $08,$03		; 02
		dw .IdleDyn02
		db $0A,$F0,$F4,$F2
		dw .IdleTM03 : db $08,$04		; 03
		dw .IdleDyn03
		db $0D,$F2,$F7,$F3
		dw .IdleTM04 : db $08,$05		; 04
		dw .IdleDyn04
		db $0B,$F4,$F5,$F4
		dw .IdleTM03 : db $08,$06		; 05
		dw .IdleDyn03
		db $0D,$F2,$F7,$F3
		dw .IdleTM02 : db $08,$07		; 06
		dw .IdleDyn02
		db $0A,$F0,$F4,$F2
		dw .IdleTM01 : db $08,$00		; 07
		dw .IdleDyn01
		db $0B,$F4,$F5,$F4


	.AnimAdvance

		; 1 2 3 4 5

		dw .IdleTM02 : db $06,$09		; 08
		dw .IdleDyn02
		db $0A,$F0,$F4,$F2
		dw .IdleTM03 : db $06,$0A		; 09
		dw .IdleDyn03
		db $0D,$F2,$F7,$F3
		dw .IdleTM04 : db $04,$0B		; 0A
		dw .IdleDyn04
		db $0B,$F4,$F5,$F4
		dw .IdleTM00 : db $04,$0C		; 0B
		dw .IdleDyn00
		db $08,$F6,$F4,$F6
		dw .IdleTM01 : db $04,$08		; 0C
		dw .IdleDyn01
		db $0B,$F4,$F5,$F4


	.AnimBlockUp

		; 6 7 8

		dw .BlockUpTM00 : db $08,$0E		; 0D
		dw .BlockUpDyn00
		db $0C,$F8,$00,$F6
		dw .BlockUpTM01 : db $08,$0F		; 0E
		dw .BlockUpDyn01
		db $0C,$FA,$00,$F8
		dw .BlockUpTM02 : db $08,$0D		; 0F
		dw .BlockUpDyn02
		db $0C,$F9,$00,$F7


	.AnimBlockSide

		; 13 14 15

		dw .BlockSideTM00 : db $08,$11		; 10
		dw .BlockSideDyn00
		db $0A,$F8,$F4,$F2
		dw .BlockSideTM01 : db $08,$12		; 11
		dw .BlockSideDyn01
		db $0A,$FA,$F4,$F4
		dw .BlockSideTM02 : db $08,$10		; 12
		dw .BlockSideDyn02
		db $0A,$F9,$F4,$F3


	.AnimAttack

		; 9 10 11 12

		dw .AttackTM00 : db $04,$14		; 13	Have the arm spin around to the back over these
		dw .AttackDyn00
		db $FF,$FF,$FF,$FF
		dw .AttackTM01 : db $04,$15		; 14
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .AttackTM02 : db $04,$16		; 15
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .AttackTM03 : db $04,$17		; 16
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .AttackTM04 : db $06,$18		; 17
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .AttackTM05 : db $08,$19		; 18
		dw .AttackDyn02
		db $FF,$FF,$FF,$FF
		dw .AttackTM06 : db $FF,$00		; 19
		dw .AttackDyn03
		db $FF,$FF,$FF,$FF

	.AnimUppercut

		dw .UppercutTM00 : db $08,$1B		; 1A
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .UppercutTM01 : db $08,$1C		; 1B
		dw .AttackDyn02
		db $FF,$FF,$FF,$FF
		dw .UppercutTM02 : db $10,$00		; 1C
		dw .IdleDyn01
		db $FF,$FF,$FF,$FF

	.AnimGrabby

		dw .GrabbyTM00 : db $06,$1E		; 1D
		dw .AttackDyn00
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM01 : db $06,$1F		; 1E
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM02 : db $06,$20		; 1F
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM03 : db $06,$21		; 20
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM04 : db $09,$22		; 21
		dw .AttackDyn01
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM05 : db $0C,$23		; 22
		dw .AttackDyn02
		db $FF,$FF,$FF,$FF
		dw .GrabbyTM06 : db $FF,$00		; 23
		dw .AttackDyn03
		db $FF,$FF,$FF,$FF
		dw .GrabbyGrabTM : db $20,$00		; 24
		dw .AttackDyn03
		db $FF,$FF,$FF,$FF

	.AnimDeath

		dw .IdleTM02 : db $08,$26		; 25
		dw .DeathDyn00
		db $0A,$F0,$F6,$F0
		dw .IdleTM02 : db $08,$27		; 26
		dw .DeathDyn01
		db $0A,$EF,$F6,$EF

		dw .DeathTM00 : db $03,$28		; 27
		dw .DeathDyn02
		db $0A,$F1,$F6,$F0
		dw .DeathTM00 : db $03,$29		; 28
		dw .DeathDyn03
		db $0B,$F1,$F5,$F0
		dw .DeathTM00 : db $03,$2A		; 29
		dw .DeathDyn04
		db $0C,$F0,$F4,$F1
		dw .DeathTM00 : db $03,$27		; 2A
		dw .DeathDyn05
		db $0B,$F0,$F5,$F1

		dw .DeathTM00 : db $06,$2C		; 2B
		dw .DeathDyn06
		db $FF,$FF,$FF,$FF
		dw .DeathTM01 : db $06,$2D		; 2C
		dw .DeathDyn07
		db $FF,$FF,$FF,$FF
		dw .DeathTM02 : db $06,$2E		; 2D (needs a 16x8 chunk from the hands file)
		dw .DeathDyn08
		db $FF,$FF,$FF,$FF
		dw .DeathTM03 : db $06,$2F		; 2E (non-dynamic)
		dw $0000
		db $FF,$FF,$FF,$FF
		dw .DeathTM04 : db $06,$30		; 2F (non-dynamic)
		dw $0000
		db $FF,$FF,$FF,$FF
		dw .DeathTM05 : db $FF,$30		; 30 (non-dynamic)
		dw $0000
		db $FF,$FF,$FF,$FF


	.IdleTM00
		dw $0018
		db $2C,$FC,$E0,$C0
		db $2C,$04,$E0,$C1
		db $2C,$FC,$F0,$E0
		db $2C,$04,$F0,$E1
		db $2C,$FC,$00,$C3
		db $2C,$04,$00,$C4

	.IdleTM01
		dw $0018
		db $2C,$FC,$E0,$C0
		db $2C,$04,$E0,$C1
		db $2C,$FC,$F0,$E0
		db $2C,$04,$F0,$E1
		db $2C,$FC,$00,$C3
		db $2C,$04,$00,$C4

	.IdleTM02
		dw $000C
		db $2C,$00,$E0,$C0
		db $2C,$00,$F0,$E0
		db $2C,$00,$00,$C2

	.IdleTM03
		dw $000C
		db $2C,$00,$E0,$C0
		db $2C,$00,$F0,$E0
		db $2C,$00,$00,$C2

	.IdleTM04
		dw $000C
		db $2C,$00,$E0,$C0
		db $2C,$00,$F0,$E0
		db $2C,$00,$00,$C2


	.BlockUpTM00
		dw $0010
		db $2C,$00,$E8,$C0
		db $2C,$08,$E8,$C1
		db $2C,$08,$F8,$E0
		db $2C,$00,$00,$E2

	.BlockUpTM01
		dw $0010
		db $2C,$00,$E8,$C0
		db $2C,$08,$E8,$C1
		db $2C,$08,$F8,$E0
		db $2C,$00,$00,$E2

	.BlockUpTM02
		dw $0010
		db $2C,$00,$E8,$C0
		db $2C,$08,$E8,$C1
		db $2C,$08,$F8,$E0
		db $2C,$00,$00,$E2

	.BlockSideTM00
		dw $0014
		db $2C,$F0,$E8,$C0
		db $2C,$00,$E8,$C2
		db $2C,$00,$F8,$E0
		db $2C,$F8,$00,$E2
		db $2C,$00,$00,$E3

	.BlockSideTM01
		dw $0014
		db $2C,$F0,$E8,$C0
		db $2C,$00,$E8,$C2
		db $2C,$00,$F8,$E0
		db $2C,$F8,$00,$E2
		db $2C,$00,$00,$E3

	.BlockSideTM02
		dw $0014
		db $2C,$F0,$E8,$C0
		db $2C,$00,$E8,$C2
		db $2C,$00,$F8,$E0
		db $2C,$F8,$00,$E2
		db $2C,$00,$00,$E3


	.AttackTM00
		dw $0020
		db $2C,$00,$E8,$C0
		db $2C,$08,$E8,$C1
		db $2C,$08,$F8,$E0
		db $2C,$00,$00,$E2
		db $2C,$08,$00,$E3
		db $2D,$E9,$E9,$80
		db $AD,$F8,$EE,$C0
		db $AD,$00,$EE,$C1


	.AttackTM01
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$F3,$E2,$A0
		db $AD,$00,$E6,$C4


	.AttackTM02
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$05,$E0,$A0
		db $AD,$0A,$E4,$A4


	.AttackTM03
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$15,$E2,$A0
		db $2D,$12,$EE,$C4


	.AttackTM04
		dw $001C
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$25,$EE,$A0
		db $2D,$18,$EE,$C0
		db $2D,$20,$EE,$C1


	.AttackTM05
		dw $0028
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $AD,$1E,$01,$AA
		db $AD,$2E,$01,$AC
		db $AD,$1E,$F1,$CA
		db $AD,$2E,$F1,$CC
		db $2D,$18,$EE,$C0
		db $2D,$20,$EE,$C1


	.AttackTM06
		dw $0020
		db $AD,$1E,$01,$AA		; Hand goes first on this frame
		db $AD,$2E,$01,$AC
		db $AD,$1E,$F1,$CA
		db $AD,$2E,$F1,$CC
		db $2C,$E8,$F0,$C0		; < body
		db $2C,$F8,$F0,$C2
		db $2C,$00,$F8,$E0
		db $2C,$00,$00,$E2

	.GrabbyTM00
		dw $0020
		db $2C,$00,$E8,$C0
		db $2C,$08,$E8,$C1
		db $2C,$08,$F8,$E0
		db $2C,$00,$00,$E2
		db $2C,$08,$00,$E3
		db $2D,$EA,$EF,$82
		db $AD,$F8,$EE,$C0
		db $AD,$00,$EE,$C1

	.GrabbyTM01
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$F3,$E4,$82
		db $AD,$00,$E6,$C4

	.GrabbyTM02
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$00,$DC,$80
		db $AD,$0A,$E4,$A4

	.GrabbyTM03
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$15,$E2,$80
		db $2D,$12,$EE,$C4

	.GrabbyTM04
		dw $001C
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$23,$F3,$80
		db $2D,$18,$EE,$C0
		db $2D,$20,$EE,$C1

	.GrabbyTM05
		dw $0028
		db $2C,$00,$F0,$C0	; < body
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $2D,$1E,$E9,$A6	; < hand
		db $2D,$2E,$E9,$A8
		db $2D,$1E,$F9,$C6
		db $2D,$2E,$F9,$C8
		db $2D,$18,$EE,$C0	; < arm
		db $2D,$20,$EE,$C1

	.GrabbyTM06
		dw $0020
		db $2D,$1E,$E9,$A6		; Hand goes first on this frame
		db $2D,$2E,$E9,$A8
		db $2D,$1E,$F9,$C6
		db $2D,$2E,$F9,$C8
		db $2C,$E8,$F0,$C0		; < body
		db $2C,$F8,$F0,$C2
		db $2C,$00,$F8,$E0
		db $2C,$00,$00,$E2

	.GrabbyGrabTM
		dw $0010			; < Hand is uploaded to lo OAM block for this frame
		db $2C,$E8,$F0,$C0		; < body
		db $2C,$F8,$F0,$C2
		db $2C,$00,$F8,$E0
		db $2C,$00,$00,$E2

	.HiPrioHandTM
		db $2D,$1E,$E9,$AA
		db $2D,$2E,$E9,$AC
		db $2D,$1E,$F9,$CA
		db $2D,$2E,$F9,$CC


	.UppercutTM00
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $ED,$0C,$FA,$A2
		db $2D,$00,$F2,$C4

	.UppercutTM01
		dw $0018
		db $2C,$00,$F0,$C0
		db $2C,$08,$F0,$C1
		db $2C,$00,$00,$E0
		db $2C,$08,$00,$E1
		db $ED,$0A,$FC,$A2
		db $2D,$02,$F4,$C4

	.UppercutTM02
		dw $0020
		db $2C,$FC,$E0,$C0
		db $2C,$04,$E0,$C1
		db $2C,$FC,$F0,$E0
		db $2C,$04,$F0,$E1
		db $2C,$FC,$00,$C3
		db $2C,$04,$00,$C4
		db $ED,$04,$D0,$A2
		db $2D,$02,$DC,$A4

	.DeathTM00
		dw $0010
		db $2C,$00,$D0,$C0
		db $2C,$00,$E0,$E0
		db $2C,$00,$F0,$C2
		db $2C,$00,$00,$E2
	.DeathTM01
		dw $0010
		db $2C,$00,$D8,$C0
		db $2C,$00,$E8,$E0
		db $2C,$00,$F8,$C2
		db $2C,$00,$08,$E2
	.DeathTM02
		dw $000C
		db $2C,$00,$F8,$C2
		db $2C,$00,$E8,$C0
		db $2D,$00,$00,$E0
	.DeathTM03
		dw $000C
		db $2D,$00,$08,$E8
		db $2D,$00,$F8,$E6
		db $2D,$00,$E8,$E4
	.DeathTM04
		dw $0004
		db $2D,$00,$00,$EA
	.DeathTM05
		dw $0004
		db $2D,$00,$00,$EC


macro TarCreeperDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+!TarCreeperBody
	dw <DestVRAM>*$10+$6000
endmacro

		.IdleDyn00
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $006, $0C0)
		%TarCreeperDyn(3, $016, $0D0)
		%TarCreeperDyn(3, $026, $0E0)
		%TarCreeperDyn(3, $036, $0F0)
		%TarCreeperDyn(3, $046, $0C3)
		%TarCreeperDyn(3, $056, $0D3)
		..End
		.IdleDyn01
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $009, $0C0)
		%TarCreeperDyn(3, $019, $0D0)
		%TarCreeperDyn(3, $029, $0E0)
		%TarCreeperDyn(3, $039, $0F0)
		%TarCreeperDyn(3, $049, $0C3)
		%TarCreeperDyn(3, $059, $0D3)
		..End
		.IdleDyn02
		dw ..End-..Start
		..Start
		%TarCreeperDyn(2, $000, $0C0)
		%TarCreeperDyn(2, $010, $0D0)
		%TarCreeperDyn(2, $020, $0E0)
		%TarCreeperDyn(2, $030, $0F0)
		%TarCreeperDyn(2, $040, $0C2)
		%TarCreeperDyn(2, $050, $0D2)
		..End
		.IdleDyn03
		dw ..End-..Start
		..Start
		%TarCreeperDyn(2, $002, $0C0)
		%TarCreeperDyn(2, $012, $0D0)
		%TarCreeperDyn(2, $022, $0E0)
		%TarCreeperDyn(2, $032, $0F0)
		%TarCreeperDyn(2, $042, $0C2)
		%TarCreeperDyn(2, $052, $0D2)
		..End
		.IdleDyn04
		dw ..End-..Start
		..Start
		%TarCreeperDyn(2, $004, $0C0)
		%TarCreeperDyn(2, $014, $0D0)
		%TarCreeperDyn(2, $024, $0E0)
		%TarCreeperDyn(2, $034, $0F0)
		%TarCreeperDyn(2, $044, $0C2)
		%TarCreeperDyn(2, $054, $0D2)
		..End


		.BlockUpDyn00
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $060, $0C0)
		%TarCreeperDyn(3, $070, $0D0)
		%TarCreeperDyn(2, $081, $0E0)
		%TarCreeperDyn(2, $091, $0F0)
		%TarCreeperDyn(2, $090, $0E2)
		%TarCreeperDyn(2, $0A0, $0F2)
		..End
		.BlockUpDyn01
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $063, $0C0)
		%TarCreeperDyn(3, $073, $0D0)
		%TarCreeperDyn(2, $084, $0E0)
		%TarCreeperDyn(2, $094, $0F0)
		%TarCreeperDyn(2, $093, $0E2)
		%TarCreeperDyn(2, $0A3, $0F2)
		..End
		.BlockUpDyn02
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $066, $0C0)
		%TarCreeperDyn(3, $076, $0D0)
		%TarCreeperDyn(2, $087, $0E0)
		%TarCreeperDyn(2, $097, $0F0)
		%TarCreeperDyn(2, $096, $0E2)
		%TarCreeperDyn(2, $0A6, $0F2)
		..End


		.BlockSideDyn00
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $00C, $0C0)
		%TarCreeperDyn(4, $01C, $0D0)
		%TarCreeperDyn(2, $02E, $0E0)
		%TarCreeperDyn(2, $03E, $0F0)
		%TarCreeperDyn(3, $03D, $0E2)
		%TarCreeperDyn(3, $04D, $0F2)
		..End
		.BlockSideDyn01
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $05C, $0C0)
		%TarCreeperDyn(4, $06C, $0D0)
		%TarCreeperDyn(2, $07E, $0E0)
		%TarCreeperDyn(2, $08E, $0F0)
		%TarCreeperDyn(3, $08D, $0E2)
		%TarCreeperDyn(3, $09D, $0F2)
		..End
		.BlockSideDyn02
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $0AC, $0C0)
		%TarCreeperDyn(4, $0BC, $0D0)
		%TarCreeperDyn(2, $0CE, $0E0)
		%TarCreeperDyn(2, $0DE, $0F0)
		%TarCreeperDyn(3, $0DD, $0E2)
		%TarCreeperDyn(3, $0ED, $0F2)
		..End


		.AttackDyn00
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $069, $0C0)
		%TarCreeperDyn(3, $079, $0D0)
		%TarCreeperDyn(2, $08A, $0E0)
		%TarCreeperDyn(2, $09A, $0F0)
		%TarCreeperDyn(3, $099, $0E2)
		%TarCreeperDyn(3, $0A9, $0F2)
		..End
		.AttackDyn01
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $0B0, $0C0)
		%TarCreeperDyn(3, $0C0, $0D0)
		%TarCreeperDyn(3, $0D0, $0E0)
		%TarCreeperDyn(3, $0E0, $0F0)
		..End
		.AttackDyn02
		dw ..End-..Start
		..Start
		%TarCreeperDyn(3, $0B3, $0C0)
		%TarCreeperDyn(3, $0C3, $0D0)
		%TarCreeperDyn(3, $0D3, $0E0)
		%TarCreeperDyn(3, $0E3, $0F0)
		..End
		.AttackDyn03
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $0B6, $0C0)
		%TarCreeperDyn(4, $0C6, $0D0)
		%TarCreeperDyn(2, $0C9, $0E0)
		%TarCreeperDyn(2, $0D9, $0F0)
		%TarCreeperDyn(2, $0D9, $0E2)
		%TarCreeperDyn(2, $0E9, $0F2)
		..End

	.DeathDyn00
		dw ..End-..Start
		..Start
		%TarCreeperDyn(2, $0F0, $0C0)
		%TarCreeperDyn(2, $100, $0D0)
		%TarCreeperDyn(2, $110, $0E0)
		%TarCreeperDyn(2, $120, $0F0)
		%TarCreeperDyn(2, $130, $0C2)
		%TarCreeperDyn(2, $140, $0D2)
		..End
	.DeathDyn01
		dw ..End-..Start
		..Start
		%TarCreeperDyn(2, $0F2, $0C0)
		%TarCreeperDyn(2, $102, $0D0)
		%TarCreeperDyn(2, $112, $0E0)
		%TarCreeperDyn(2, $122, $0F0)
		%TarCreeperDyn(2, $132, $0C2)
		%TarCreeperDyn(2, $142, $0D2)
		..End
	.DeathDyn02
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $0F4, $0C0)
		%TarCreeperDyn(4, $104, $0D0)
		%TarCreeperDyn(4, $114, $0E0)
		%TarCreeperDyn(4, $124, $0F0)
		..End
	.DeathDyn03
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $0F8, $0C0)
		%TarCreeperDyn(4, $108, $0D0)
		%TarCreeperDyn(4, $118, $0E0)
		%TarCreeperDyn(4, $128, $0F0)
		..End
	.DeathDyn04
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $134, $0C0)
		%TarCreeperDyn(4, $144, $0D0)
		%TarCreeperDyn(4, $154, $0E0)
		%TarCreeperDyn(4, $164, $0F0)
		..End
	.DeathDyn05
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $138, $0C0)
		%TarCreeperDyn(4, $148, $0D0)
		%TarCreeperDyn(4, $158, $0E0)
		%TarCreeperDyn(4, $168, $0F0)
		..End
	.DeathDyn06
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $0FC, $0C0)
		%TarCreeperDyn(4, $10C, $0D0)
		%TarCreeperDyn(4, $11C, $0E0)
		%TarCreeperDyn(4, $12C, $0F0)
		..End
	.DeathDyn07
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $13C, $0C0)
		%TarCreeperDyn(4, $14C, $0D0)
		%TarCreeperDyn(4, $15C, $0E0)
		%TarCreeperDyn(4, $16C, $0F0)
		..End
	.DeathDyn08
		dw ..End-..Start
		..Start
		%TarCreeperDyn(4, $150, $0C0)
		%TarCreeperDyn(4, $160, $0D0)
		..End


	HITBOX:
		.BODY
		LDA $3220,x				;\
		SEC : SBC #$02				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		SBC #$00				; |
		STA $0A					;/
		LDA #$14 : STA $06			; > Hitbox width
		LDA $3210,x				;\
		SEC : SBC #$30				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		SBC #$00				; |
		STA $0B					;/
		LDA #$40 : STA $07			; > Hitbox height
		RTS


		.UPPERCUT
		LDA $3250,x : XBA			;\ Load Xpos (16-bit)
		LDA $3220,x				;/
		REP #$20				; > A 16-bit
		CLC : ADC #$0004			;\
		LDY $3320,x				; | +0x4 for right, -0x14 for left
		BEQ $04 : SEC : SBC #$0010		;/
		SEP #$20				; > A 8-bit
		STA $04					;\ Store Xpos
		XBA : STA $0A				;/
		LDA $3210,x				;\
		SEC : SBC #$30				; |
		STA $05					; | Hitbox Ypos
		LDA $3240,x				; |
		SBC #$00				; |
		STA $0B					;/
		LDA #$16 : STA $06			;\ Hitbox size ($10x$42)
		LDA #$42 : STA $07			;/
		RTS


		.BIGPALM
		STA $01
		AND #$E0
		LSR #2
		STA $00
		LDA $03,s : TAY
		LDA !BigRAM+2,y
		AND #$40
		LDY $3320,x
		BEQ $02 : EOR #$40
		BIT $01
		BVC $02 : EOR #$40
		LSR #2
		EOR $00
		TAY
		REP #$20				; > A 16 bit
		LDA DATA_PalmBox+0,y : STA $00		;\ Hitbox offsets
		LDA DATA_PalmBox+2,y : STA $02		;/
		LDA DATA_PalmBox+4,y : STA $06		; > Hitbox size
		SEP #$20				; > A 8 bit

		LDA $03,s : TAY				; > Restore index to hand tilemap
		LDA $3220,x				;\
		CLC : ADC $00				; |
		STA $00					; |
		LDA $3250,x				; |
		ADC $01					; |
		STA $01					; | 16-bit coords at $00-$03
		LDA $3210,x				; | (sprite coords + hitbox offsets)
		CLC : ADC $02				; |
		STA $02					; |
		LDA $3240,x				; |
		ADC $03					; |
		STA $03					;/
		STZ $0D					;\ Clear high bits of arm offsets
		STZ $0F					;/
		LDA !BigRAM+3,y				;\
		STA $0C					; | X offset
		BPL $02 : DEC $0D			;/
		LDA !BigRAM+4,y				;\
		STA $0E					; | Y offset
		BPL $02 : DEC $0F			;/
		REP #$20				; > A 16 bit
		LDA !BigRAM+2,y				;\
		AND #$0040 : BEQ +			; |
		LDA $0C					; | Take tile x flip into account
		EOR #$FFFF				; |
		STA $0C					;/
	+	LDA $3320,x				;\
		AND #$00FF : BNE +			; |
		LDA $0C					; | Take sprite x flip into account
		EOR #$FFFF				; |
		STA $0C					;/
	+	LDA $00					;\ sprite X + hand X + hitbox X
		CLC : ADC $0C				;/
		STA $04					; > Lo byte at $04
		STA $09					; > Hi byte at $0A
		LDA $02					;\ sprite Y + hand Y + hitbox Y
		CLC : ADC $0E				;/
		SEP #$20				; > A 8 bit
		STA $05					; > Lo byte at $05
		XBA : STA $0B				; > Hi byte at $0B
		RTS


		.BIG_FIST				; Add attack displacement
		LDA #$08 : STA $00
		BRA +

		.BIG_GRABBY				; Pretty much same hitbox as fist but higher
		STZ $00
		+

		STZ $01
		LDA $3220,x : STA $02			;\ 16-bit sprite x position
		LDA $3250,x : STA $03			;/
		BIT !TarCreeperAttack			; > Check if going back
		REP #$20				; > A 16-bit
		LDA !TarCreeperAttack			;\ Get stretch bits
		AND #$000F				;/
		BVC +					;\
		ASL #3					; | Get stretch value going in
		BRA ++					;/
	+	CMP #$0008				;\
		BCC $03 : LDA #$0007			; | Get stretch value going out
		ASL #4					;/
	++	SEC : SBC #$001E			; > Base subtract
		LDY $3320,x : BEQ +			; > Determine sprite direction
		EOR #$FFFF				; > Reverse when facing right
		BRA ++
	+	SEC : SBC #$001E			; > Base subtract
	++	CLC : ADC $02				;\
		SEP #$20				; | Store X coordinate of hitbox
		STA $04					; |
		XBA : STA $0A				;/
		LDA $3240,x : XBA			;\
		LDA $3210,x				; |
		REP #$20				; |
		CLC : ADC $00				; | Sore Y coordinate of hitbox
		CLC : ADC #$FFE9			; |
		SEP #$20				; |
		STA $05					; |
		XBA : STA $0B				;/
		LDA #$28 : STA $06			;\ Store hitbox dimensions
		LDA #$1C : STA $07			;/
		RTS					; > Return


	KnockBack:
		LSR A : BCC +
		LDY !P2Invinc-$80 : BNE +
		LDY $3320,x
		PHA
		STZ !P2XSpeed-$80
		LDA !CurrentMario
		CMP #$01 : BNE ++
		STZ !MarioXSpeed
	++	LDA DATA_VectorX,y : STA !P2VectorX-$80
		LDA #$18 : STA !P2VectorTimeX-$80
		PLA
	+	LSR A : BCC +
		LDY !P2Invinc : BNE +
		LDY $3320,x
		STZ !P2XSpeed
		LDA !CurrentMario
		CMP #$02 : BNE ++
		STZ !MarioXSpeed
	++	LDA DATA_VectorX,y : STA !P2VectorX
		LDA #$18 : STA !P2VectorTimeX
	+	RTS



	namespace off









