

CoinGolem:

	namespace CoinGolem



	!CoinGolemEye		= $BE			;\ used for dynamic uploads
	!CoinGolemPrevEye	= $3280			;/


	!CoinGolemTurnDir	= $3290
	!CoinGolemTurn		= $32A0
	!CoinGolemHeight	= $32B0



	!CoinGolemHurtTimer	= $3400
	!CoinGolemAttack1	= $3410
	!CoinGolemAttack2	= $3420
	!CoinGolemDead		= $3430



	MAIN:
		LDA !GameMode
		CMP #$14 : BEQ $01 : RTL

		PHB : PHK : PLB
		LDA !ExtraBits,x : BMI .Main

		.Init
		ORA #$80 : STA !ExtraBits,x
		LDA !MultiPlayer : STA $00
		LDY !Difficulty
		LDA DATA_HP,y
		LDY $00
		BEQ $01 : ASL A
		STA !SpriteHP,x
		JSR ResetModel

		.Main

		%decreg(!CoinGolemHurtTimer)



	PHYSICS:
		LDA !SpriteHP,x				;\
		BMI .Dead				; |
		BNE .Alive				; |
	.Dead	LDA !CoinGolemDead,x : BNE +		; |
		LDA #$01 : STA !CoinGolemDead,x		; |
		LDA #$02 : STA !SpriteStatus,x		; | death check
		STZ !CoinGolemHurtTimer,x		; |
		LDA #$00				; |
		STA !3D_Distance+$30			; | head disappears on death so it can drop
		STA !3D_Distance+$31			; |
		LDA #$01				; |
		STA !3D_Extra+$30			;/

		STZ $00					;\
		STZ $01					; |
		SEC : LDA #$22				; |
		JSL SpawnSprite				; |
		CPY #$FF : BEQ +			; |
		LDA !3D_X+$30 : STA !SpriteXLo,y	; |
		LDA !3D_X+$31 : STA !SpriteXHi,y	; | spawn yoshi coin
		LDA !3D_Y+$30 : STA !SpriteYLo,y	; |
		LDA !3D_Y+$31 : STA !SpriteYHi,y	; |
		LDA #$08 : STA !SpriteStatus,y		; |
		LDA #$08 : STA !ExtraBits,y		; |
		LDA #$D0 : STA.w !SpriteYSpeed,y	; |
		LDA #$00 : STA.w !SpriteXSpeed,y	;/
		STZ !CoinGolemEye,x			; > Reset eye tile so dropped coin won't look weird

	+	JMP GRAPHICS				; just go to graphics if sprite is dead

		.Alive
		PEA .Return-1				; > set return address
		LDA $32D0,x : BEQ .Process		;\ don't do animations if stunned
		RTS					;/

		.Process
		PHX					; push sprite index
		LDA !SpriteAnimIndex,x			;\
		AND #$3F				; |
		ASL A					; | check for illegal states
		CMP.b #.End-.Ptr			; |
		BCC $02 : LDA #$00			; |
		TAX					;/
		JMP (.Ptr,x)				; > execute pointer

		.Ptr
		dw .Idle	; 00
		dw .Unused	; 01
		dw .Run		; 02
		dw .Squat	; 03
		dw .Jump	; 04
		dw .Freefall	; 05
		dw .Slam	; 06
		dw .Backswing	; 07
		dw .Punch	; 08
		dw .Turn	; 09
		.End

	.Idle
		PLX
		JSR TargetEye
		LDA !SpriteAnimIndex,x : BMI ..main
		ORA #$80
		STA !SpriteAnimIndex,x
		LDX #$B0
		LDY #$0A
	-	LDA ..AngleH,y : STA !3D_AngleH,x
		LDA ..AngleV,y : STA !3D_AngleV,x
		DEY
		TXA
		SEC : SBC #$10
		BEQ +
		TAX
		BRA -

	+	LDX !SpriteIndex
		LDA #$00 : STA !3D_AngleXZ

		..main
		AND #$40 : BNE ..unravel
		JSR .Run_Sight
		BCC ..r
		LDA #$C0 : STA !SpriteAnimIndex,x

		..unravel
		PHB
		LDA.b #!3D_Base>>16
		PHA : PLB
		LDX #$B0
		LDY #$01
		STZ $00
	-	LDA.w !3D_AngleH,x
		CMP.l ANIM_Start+0,x
		BEQ $05 : INC.w !3D_AngleH,x : STY $00
		LDA.w !3D_AngleV,x
		CMP.l ANIM_Start+1,x
		BEQ $05 : INC.w !3D_AngleV,x : STY $00

		TXA
		BEQ +
		SEC : SBC #$10
		TAX
		BRA -

	+	PLB
		LDX !SpriteIndex
		LDA #$02 : STA !CoinGolemHurtTimer,x
		LDA $00 : BNE ..r
		STZ !SpriteXSpeed,x
		JSL APPLY_SPEED
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..r
		LDA #$09 : STA !SPC4				; sfx
		LDA #$1F : STA !ShakeTimer
		LDA #$02 : STA !SpriteAnimIndex,x
		LDA #$10 : STA $32D0,x				; pause a bit when landing
	..r	RTS

		..AngleH
		db $00,$00,$40,$00	; 00-03 (10-40)
		db $00,$00,$00,$00	; 04-07 (50-80)
		db $00,$00,$00		; 08-0A	(90-B0)

		..AngleV
		db $C0,$C0,$20,$00	; 00-03 (10-40)
		db $00,$00,$00,$C0	; 04-07 (50-80)
		db $00,$C0,$00		; 08-0A	(90-B0)


	.Unused
		PLX
		RTS

	.Run
		PLX
		JSR TargetEye
		LDA !SpriteBlocked,x			;\
		AND #$04			; | suspend animation if in midair
		BNE $01 : RTS			;/


		JSR ..Sight
		BCC ..main
		LDA !RNG
		AND #$04
		ORA #$03
		CMP !CoinGolemAttack1,x : BNE +	; can't use the same attack more than twice in a row
		CMP !CoinGolemAttack2,x : BNE +
		EOR #$04
	+	STA !SpriteAnimIndex,x
		XBA
		LDA !CoinGolemAttack1,x : STA !CoinGolemAttack2,x
		XBA : STA !CoinGolemAttack1,x
		CMP #$03
		BNE $01 : INC A
		ASL #2
		AND #$18
		STA !SpriteAnimTimer,x
		RTS

		..main

		LDY !SpriteDir,x
		LDA DATA_TurnRotation,y : STA $00

		DEC !SpriteAnimTimer,x		; full body rotation around Y axis
		LDA !SpriteAnimTimer,x
		CLC : ADC #$20
		EOR #$FF
		ASL #2
		LSR #2
		CMP #$20
		BCS $02 : EOR #$3F
		PHA
		CLC : ADC #$A0			; arm movements
		EOR $00
		STA !3D_AngleXZ
		PLA
		ASL A
		PHA
		EOR #$FF
		CLC : ADC #$60
		STA !3D_AngleV+$40
		PLA
		CLC : ADC #$A0
		STA !3D_AngleV+$60

		LDA !SpriteAnimTimer,x		; hip movements
		ASL #2
		BPL $02 : EOR #$FF
		SEC : SBC #$40
		STA.l !3D_AngleV+$80
		EOR #$FF
		STA.l !3D_AngleV+$A0

		LDA.l !3D_AngleV+$80		; knees
		JSR ..Knee
		STA.l !3D_AngleV+$90
		LDA.l !3D_AngleV+$A0
		JSR ..Knee
		STA.l !3D_AngleV+$B0

		LDA !SpriteAnimTimer,x		; torso up/down
		LSR #2
		EOR #$04
		AND #$07
		SEC : SBC #$04
		BPL $02 : EOR #$FF
		CLC : ADC #$11
		STA !CoinGolemHeight,x


		RTS


	; sight-box
	..Sight
		LDY !SpriteDir,x
		LDA !SpriteXLo,x
		SEC : SBC DATA_SightX,y
		STA $E8
		LDA !SpriteXHi,x
		SBC #$00
		STA $E9
		LDA !SpriteYLo,x
		SEC : SBC #$40
		STA $EA
		LDA !SpriteYHi,x
		SBC #$00
		STA $EB
		LDA #$40 : STA $EC : STZ $ED
		LDA #$C0 : STA $EE : STZ $EF
		JSL PlayerContact
	..r	RTS


		..Knee
		EOR #$FF
		CLC : ADC #$40
		LSR A
		CLC : ADC #$F0
		PHP
		BPL $03 : EOR #$FF : INC A
		ASL A
		EOR #$7F
		ORA #$80
		PLP
		BPL $03 : EOR #$FF : INC A
		INC A
		DEC A
		BMI $03 : LDA #$00 : RTS
		CMP #$C0
		BCS $02 : LDA #$C0
		RTS

; far back: 161
; far front: 33



	.Squat
		PLX
		JSR TargetEye
		LDA !SpriteDir,x : STA !CoinGolemTurnDir,x
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..r
		LDA !SpriteAnimIndex,x : BMI ..Main		; reset model at the start of the jump animation
		ORA #$80 : STA !SpriteAnimIndex,x
		JSR ResetModel

		..Main
		LDY #$00
		JSR SquatJumpAnim
		DEC !CoinGolemHeight,x
		DEC !SpriteAnimTimer,x
		LDA !SpriteAnimTimer,x : BNE ..r
		LDA #$04 : STA !SpriteAnimIndex,x
		LDA #$10 : STA !SpriteAnimTimer,x
	..r	RTS



	.Jump
		PLX
		JSR TargetEye
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		LDA !3D_AngleV+$40
		CMP #$30 : BNE ++
		LDA #$C0 : STA !SpriteYSpeed,x
		LDA #$08 : STA !SPC4				; jump SFX
		BRA +

	++	LDY #$01
		JSR SquatJumpAnim
		INC !CoinGolemHeight,x
		INC !CoinGolemHeight,x

	+	DEC !SpriteAnimTimer,x
		LDA !SpriteAnimTimer,x : BNE ..r
		LDA #$05 : STA !SpriteAnimIndex,x
	..r	RTS



	.Freefall
		PLX
		JSR TargetEye
		LDA !SpriteBlocked,x
		AND #$04 : BNE ..Ground
		JSR .Run_Sight
		BCC ..r
		LDA #$06 : STA !SpriteAnimIndex,x
		LDA #$18 : STA !SpriteAnimTimer,x		; slam when in sight
		RTS


		..Ground
		LDA #$02 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		JSR ResetModel
		JSR .Run_Sight
		BCC ..r
		LDA #$03 : STA !SpriteAnimIndex,x
		LDA #$10 : STA !SpriteAnimTimer,x
	..r	RTS



	; sprite timer is supposed to be 0x18
	.Slam
		PLX
		LDA #$08 : STA !CoinGolemEye,x
		BIT !SpriteAnimIndex,x
		BVS ..landed
		BMI ..down

		..up
		LDA !3D_AngleYZ
		CLC : ADC #$03
		STA !3D_AngleYZ
		LDA !3D_AngleV+$80
		SEC : SBC #$03
		STA !3D_AngleV+$80
		LDA !3D_AngleV+$A0
		SEC : SBC #$03
		STA !3D_AngleV+$A0
		BRA +

		..down
		LDA !SpriteBlocked,x
		AND #$04 : BNE ..land
		LDA !SpriteAnimTimer,x : BEQ ..r

		LDA !3D_AngleYZ
		SEC : SBC #$0E
		STA !3D_AngleYZ

		LDA !3D_AngleV+$80
		CLC : ADC #$0B
		STA !3D_AngleV+$80
		LDA !3D_AngleV+$A0
		CLC : ADC #$0B
		STA !3D_AngleV+$A0

	+	DEC !SpriteAnimTimer,x
		LDA !SpriteAnimTimer,x
		CMP #$08 : BNE ..r
		LDA !SpriteAnimIndex,x
		ORA #$80
		STA !SpriteAnimIndex,x
	..r	RTS

		..land
		LDA !SpriteAnimIndex,x
		ORA #$40
		STA !SpriteAnimIndex,x
		LDA #$09 : STA !SPC4
		LDA #$0F : STA !ShakeTimer
		LDA #$0F : STA $32D0,x
		RTS

		..landed
		JMP .Freefall_Ground


	.Backswing
		PLX
		LDA !SpriteDir,x : STA !CoinGolemTurnDir,x
		LDA #$08 : STA !CoinGolemEye,x
		LDA !SpriteAnimIndex,x : BMI ..Main
		ORA #$80 : STA !SpriteAnimIndex,x
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		JSR ResetModel
		LDA #$00 : STA !3D_AngleV+$10
		LDA !3D_AngleV+$80
		CLC : ADC #$20
		STA !3D_AngleV+$80

		..Main
		LDA !3D_AngleH+$40
		SEC : SBC #$03
		STA !3D_AngleH+$40
		LDA !3D_AngleV+$40
		SEC : SBC #$02
		STA !3D_AngleV+$40

		LDA !3D_AngleV+$50
		INC #2
		STA !3D_AngleV+$50


		LDA !3D_AngleXZ
		CLC : ADC #$02
		STA !3D_AngleXZ

		DEC !SpriteAnimTimer,x
		LDA !SpriteAnimTimer,x : BNE ..r
		LDA #$08 : STA !SpriteAnimIndex,x
		LDA #$18 : STA !SpriteAnimTimer,x
	..r	RTS




	.Punch
		PLX

		LDA !SpriteAnimTimer,x
		CMP #$10 : BCC +
		LDA !3D_AngleXZ
		SEC : SBC #$06
		STA !3D_AngleXZ


		LDA !3D_AngleV+$10
		CLC : ADC #$06
		STA !3D_AngleV+$10
		LDA !3D_AngleV+$20
		CLC : ADC #$06
		STA !3D_AngleV+$20
		LDA !3D_AngleV+$30
		CLC : ADC #$06
		STA !3D_AngleV+$30

		LDA !3D_AngleV+$60
		SEC : SBC #$0E
		STA !3D_AngleV+$60
		LDA !3D_AngleH+$60
		CLC : ADC #$08
		STA !3D_AngleH+$60


		LDA !3D_AngleH+$40
		CLC : ADC #$0A
		STA !3D_AngleH+$40
		LDA !3D_AngleV+$40
		CLC : ADC #$06
		STA !3D_AngleV+$40
		LDA !3D_AngleV+$50
		SEC : SBC #$06
		STA !3D_AngleV+$50

		LDA !3D_AngleV+$80
		SEC : SBC #$0C
		STA !3D_AngleV+$80


	+	DEC !SpriteAnimTimer,x
		LDA !SpriteAnimTimer,x : BNE ..r
		LDA #$02 : STA !SpriteAnimIndex,x
		JSR ResetModel
	..r	RTS




	.Turn
		PLX
		LDY !CoinGolemTurnDir,x
		LDA !3D_AngleXZ : STA $00
		CLC : ADC DATA_TurnSpeed,y
		STA !3D_AngleXZ
		EOR $00 : BPL +
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
	+	DEC !CoinGolemTurn,x : BNE ..r
		LDA #$02 : STA !SpriteAnimIndex,x
		PHX
		JMP .Run
	..r	RTS


	.Return
		LDY !SpriteDir,x
		LDA $32D0,x : BNE INTERACTION			; no movement if timer is set
		LDA !SpriteAnimIndex,x				;\
		AND #$3F					; | states that have friction
		BEQ INTERACTION					; > 0 does not move at all
		CMP #$03 : BEQ .Friction			; |
		CMP #$07 : BCS .Friction			;/
		CMP #$06 : BNE +				;\
		LDA !SpriteBlocked,x				; | slam has friction if on the ground
		AND #$04 : BEQ .NoTurn				; |
		BRA .Friction					;/
	+	CMP #$01 : BEQ .CheckTurn			;\ states that can turn
		CMP #$02 : BNE .NoTurn				;/

		.CheckTurn					;\
		JSL SUB_HORZ_POS				; |
		TYA						; |
		CMP !SpriteDir,x : BEQ .NoTurn			; |
		LDA #$09 : STA !SpriteAnimIndex,x			; |
		LDY !SpriteDir,x				; | handle turning around
		LDA !3D_AngleXZ					; |
		EOR DATA_TurnRotation,y				; |
		BPL $03 : EOR #$FF : INC A			; |
		LSR A						; |
		STA !CoinGolemTurn,x				; |
		TYA : STA !CoinGolemTurnDir,x			; |
		BRA .Turning					;/

		.Friction
		LDY !CoinGolemTurnDir,x				;\
		LDA !SpriteAnimIndex,x				; \
		AND #$3F					;  | extra friction during landing slam
		CMP #$06					;  |
		BNE $02 : INY #2				; /
		LDA !SpriteXSpeed,x : BEQ .Turning		; |
		STA $00						; |
		CLC : ADC DATA_Friction,y			; | apply friction
		STA !SpriteXSpeed,x				; |
		EOR $00						; |
		BPL .Turning					; |
		STZ !SpriteXSpeed,x				; |
		BRA .Turning					;/

		.NoTurn
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x		; set X speed
		.Turning

		JSL APPLY_SPEED






	INTERACTION:




	GRAPHICS:


		LDA !SpriteXLo,x : STA.l !3D_X+0
		LDA !SpriteXHi,x : STA.l !3D_X+1
		LDA !SpriteYLo,x
		SEC : SBC !CoinGolemHeight,x
		STA.l !3D_Y+0
		LDA !SpriteYHi,x
		SBC #$00
		STA.l !3D_Y+1

		LDY.b #ANIM_Start-ANIM-1
	-	LDA ANIM,y : STA !3D_TilemapCache,y
		DEY : BPL -
		REP #$20
		LDA.w #!3D_TilemapCache : STA.l !3D_TilemapPointer
		SEP #$20
	;	LDA !GFX_status+$8B
	; correct this???
	;	STA !3D_TilemapCache+(ANIM_YoshiCoin-ANIM)+$9
	;	STA !3D_TilemapCache+(ANIM_YoshiCoin40-ANIM)+$9
	;	INC #2
	;	STA !3D_TilemapCache+(ANIM_YoshiCoin-ANIM)+$5
	;	STA !3D_TilemapCache+(ANIM_YoshiCoin40-ANIM)+$5
	;	INC #2
	;	STA !3D_TilemapCache+(ANIM_DarkCoin-ANIM)+$5

	LDA !CoinGolemDead,x : BNE +
		LDY !SpriteDir,x
		LDA DATA_HeadTile,y : STA !3D_Extra+$30
	+

		PHX
		LDA !SpriteDir,x
		LDY #$00
		LDX DATA_Dark,y : STX $00
		INY
	-	LDX DATA_Dark,y
		STA !3D_Extra,x
		EOR #$01
		LDX DATA_Dark+5,y
		STA !3D_Extra,x
		EOR #$01
		INY
		DEC $00 : BPL -
		PLX


		LDA #$00 : JSL Update3DCluster

		LDA !SpriteAnimIndex,x
		AND #$3F : BEQ +
		JSR Hitbox
		+

		LDY !BigRAM			; tilemap size determines loop count
	-	LDA !BigRAM+4,y			;\
		SEC : SBC !CoinGolemHeight,x	; | apply height
		STA !BigRAM+4,y			;/
		LDA !BigRAM+2,y			; neutralize xflip
		AND #$40 : BEQ +
		LDA !BigRAM+3,y
		EOR #$FF
		STA !BigRAM+3,y
	+	DEY #4 : BPL -			; loop



		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20

		LDA !SpriteDir,x : PHA
		LDA #$01 : STA !SpriteDir,x


		LDA !CoinGolemHurtTimer,x
		AND #$04 : BNE +
		JSL LOAD_TILEMAP
		+

		PLA : STA !SpriteDir,x


		; if coin golem's eye should change, we copy it from one place in VRAM to another
		LDA !CoinGolemEye,x
		CMP !CoinGolemPrevEye,x : BEQ .Return
		TAY
		LDA !SpriteTile,x : STA $00
		LDA !SpriteProp,x : STA $01
		JSL GetVRAM : BCS .Return
		REP #$20
		LDA EyeTile,y
		AND #$00FF
		CLC : ADC $00
		ASL #4
		ORA #$E000					; address get (with download set)
		STA !VRAMbase+!VRAMtable+$05,x
		LDA $00
		CLC : ADC #$0011
		ASL #4
		ORA #$6000
		STA !VRAMbase+!VRAMtable+$0C,x			; upload address
		LDA.w #!BigRAM					;\
		STA !VRAMbase+!VRAMtable+$02,x			; | use !BigRAM as buffer
		STA !VRAMbase+!VRAMtable+$09,x			;/
		LDA #$0020					;\
		STA !VRAMbase+!VRAMtable+$00,x			; | upload size = 1 8x8 tile
		STA !VRAMbase+!VRAMtable+$07,x			;/
		SEP #$20
		LDA #$00					;\
		STA !VRAMbase+!VRAMtable+$04,x			; | bank = 00
		STA !VRAMbase+!VRAMtable+$0B,x			;/


		LDX !SpriteIndex


		.Return
		PLB
	INIT:
		RTL




	SquatJumpAnim:
		LDA !3D_AngleV+$40				; arms
		CLC : ADC .Offset,y
		STA !3D_AngleV+$40
		LDA !3D_AngleV+$60
		CLC : ADC .Offset,y
		STA !3D_AngleV+$60
		LDA !3D_AngleH+$50
		CLC : ADC .Offset+4,y
		STA !3D_AngleH+$50
		LDA !3D_AngleH+$70
		CLC : ADC .Offset+4,y
		STA !3D_AngleH+$70

		LDA !3D_AngleV+$80				; legs
		CLC : ADC .Offset+2,y
		STA !3D_AngleV+$80
		LDA !3D_AngleH+$80
		SEC : SBC .Offset+2,y
		STA !3D_AngleH+$80
		LDA !3D_AngleV+$A0
		CLC : ADC .Offset+2,y
		STA !3D_AngleV+$A0
		LDA !3D_AngleH+$A0
		CLC : ADC .Offset+2,y
		STA !3D_AngleH+$A0
		RTS


		.Offset
		db $FC,$10
		db $02,$FA
		db $02,$FE




	ANIM:

		.Ptr
		dw !3D_TilemapCache+(ANIM_Coin-ANIM)
		dw !3D_TilemapCache+(ANIM_DarkCoin-ANIM)
		dw !3D_TilemapCache+(ANIM_YoshiCoin-ANIM)
		dw !3D_TilemapCache+(ANIM_YoshiCoin40-ANIM)

		.Coin
		dw $0004
		db $24,$00,$00,$45

		.DarkCoin
		dw $8C04
		db $24,$00,$00,$04

		.YoshiCoin
		dw $8C08
		db $24,$00,$00,$02
		db $24,$00,$F0,$00

		.YoshiCoin40
		dw $8C08
		db $64,$00,$00,$02
		db $64,$00,$F0,$00



	.Start

		; core (index 00)
		db $00,$18,$00		; angles
		dw $0000		; distance
		dw $0000,$0000,$0080	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $00,$00		; tilemap data

		; left shoulder (index 10)
		db $D2,$10,$00		; angles
		dw $11E3		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $00,$00		; tilemap data

		; right shoulder (index 20)
		db $AE,$10,$00		; angles
		dw $11E3		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $01,$00		; tilemap data

		; head (index 30)
		db $C0,$10,$00		; angles
		dw $1400		; distance
		dw $0000,$0000,$0000	; XYZ
		dw $0000		; attachment
		db $FF			; slot taken
		db $02,$00		; tilemap data

		; left arm 1 (index 40)
		db $5E,$00,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $0010
		db $FF
		db $00,$00		; tilemap data

		; left arm 2 (index 50)
		db $F0,$20,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $0040
		db $FF
		db $00,$00		; tilemap data

		; right arm 1 (index 60)
		db $A6,$00,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $0020
		db $FF
		db $01,$00		; tilemap data

		; right arm 2 (index 70)
		db $DE,$20,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $0060
		db $FF
		db $01,$00		; tilemap data

		; left leg 1 (index 80)
		db $20,$08,$00
		dw $0A00
		dw $0000,$0000,$0000
		dw $0000
		db $FF
		db $00,$00		; tilemap data

		; left leg 2 (index 90)
		db $1C,$E8,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $0080
		db $FF
		db $00,$00		; tilemap data

		; right leg 1 (index A0)
		db $60,$08,$00
		dw $0A00
		dw $0000,$0000,$0000
		dw $0000
		db $FF
		db $01,$00		; tilemap data

		; right leg 2 (index B0)
		db $E4,$E8,$00
		dw $0E00
		dw $0000,$0000,$0000
		dw $00A0
		db $FF
		db $01,$00		; tilemap data
	.End



; -6000
; /16
; -100

; reverse:
; +100
; x16
; +6000

; ignore the +6000 in the math and just have that as the base VRAM address


	EyeTile:
		db $16		; 00: normal
		db $06		; 01: forward-down
		db $07		; 02: down
		db $08		; 03: back-down
		db $09		; 04: back
		db $0A		; 05: back-up
		db $0B		; 06: up
		db $0C		; 07: forward-up
		db $0D		; 08: angry
		db $0E		; 09: troll
		db $0F		; 0A: dishonest



	ResetModel:
		LDA $32D0,x : BNE .Return
		PHX
		LDX #$00
	-	LDA.w ANIM_Start,x : STA.l !3D_Base,x
		INX
		CPX.b #ANIM_End-ANIM_Start : BNE -
		PLX
		LDA #$14 : STA !CoinGolemHeight,x
		LDY !SpriteDir,x : BEQ .Return
		LDA #-$18 : STA !3D_AngleXZ
	.Return	RTS


	TargetEye:
		LDA !3D_X+$30 : STA $00	
		LDA !3D_X+$31 : STA $01
		LDA !3D_Y+$30 : STA $02
		LDA !3D_Y+$31 : STA $03
		LDA !P2Status-$80 : BEQ .Go
		LDA !P2Status : BNE .Win
		REP #$20
		STZ $08
		BRA .P2
	.Win	LDA #$09 : STA !CoinGolemEye,x
		RTS

	.Go	REP #$20
		LDA $00
		SEC : SBC !P2XPosLo-$80
		STA $04
		BPL $03 : EOR #$FFFF
		STA $08
		LDA $02
		SEC : SBC !P2YPosLo-$80
		STA $06
		BPL $03 : EOR #$FFFF
		CLC : ADC $08
		STA $08

	.P2	LDA $00
		SEC : SBC !P2XPosLo
		STA $0A
		BPL $03 : EOR #$FFFF
		STA $0E
		LDA $02
		SEC : SBC !P2YPosLo
		STA $0C
		BPL $03 : EOR #$FFFF
		CLC : ADC $0E
		CMP $08 : BCC .1
	.2	LDA $0A : STA $04
		LDA $0C : STA $06

	.1	LDY #$01 : STY $2250
		LDA $06
		BPL $03 : EOR #$FFFF
		STA $2251
		LDA $04 : STA $0E			; back this up
		BPL $03 : EOR #$FFFF
		STA $2253
		PEA .NodeDone-1
		.GetNode
		CMP #$0000 : BEQ .Node0		; > Don't divide by 0 (assume Y/0 equals infinity)
		PHA				; > Preserve "X"
		LDA $2306			;\
		AND #$00FF			; | Get quotient
		XBA				; |
		STA $04				;/
		LDA $2308			;\
		XBA				; |
		AND #$FF00			; | Calculate hexadecimals
		STA $2251			; |
		PLA : STA $2253			; |
		BRA $00				;/
		LSR A				;\
		CMP $2308			; | Round up/down
		LDA $2306			; |
		BCS $01 : INC A			;/
		AND #$00FF
		ORA $04
		CMP #$0812 : BCS .Node0		;\
		CMP #$026A : BCS .Node1		; |
		CMP #$0148 : BCS .Node2		; | Determine node based on Y/X
		CMP #$00C8 : BCS .Node3		; |
		CMP #$006A : BCS .Node4		; |
		CMP #$0020 : BCS .Node5		;/
.Node6		LDY #$06 : SEP #$20 : RTS	; Vastly dominant X
.Node5		LDY #$05 : SEP #$20 : RTS	; Greatly dominant X
.Node4		LDY #$04 : SEP #$20 : RTS	; Slightly dominant X
.Node3		LDY #$03 : SEP #$20 : RTS	; Equal X and Y
.Node2		LDY #$02 : SEP #$20 : RTS	; Slightly dominant Y
.Node1		LDY #$01 : SEP #$20 : RTS	; Greatly dominant Y
.Node0		LDY #$00 : SEP #$20 : RTS	; Vastly dominant Y
		.NodeDone
		LDA .Index,y
		BIT $0F
		BPL $02 : ORA #$04
		BIT $07
		BPL $02 : ORA #$08
		LDY !SpriteDir,x
		BNE $02 : EOR #$04
		TAY
		LDA .Eye,y : STA !CoinGolemEye,x
	.Return	RTS

	.Index	db $00,$00			; vastly to greatly dominant y
		db $01,$01,$01			; slightly dominant y to slightly dominant x
		db $02,$02			; greatly to vastly dominant x

	.Eye	db $06,$07,$00,$FF		; top right quadrant
		db $06,$05,$04,$FF		; top left quadrant
		db $02,$01,$00,$FF		; bottom right quadrant
		db $02,$03,$04,$FF		; bottom left quadrant


	Hitbox:
		PHB
		LDA.b #!3D_Base>>16
		PHA : PLB
		REP #$20
		LDA.w !3D_X+$20
		CLC : ADC #$0004
		STA $E8
		SEC : SBC.w !3D_X+$10
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC #$000C
		STA $EC
		LDA.w !3D_Y+$10
		CMP.w !3D_Y+$20
		BCC $03 : LDA.w !3D_Y+$20
		CLC : ADC #$0004
		STA $EA
		SEC : SBC.w !3D_Y+$00
		BPL $02 : EOR #$FFFF
		CLC : ADC #$000C
		STA $EE
		SEP #$20
		PLB
		LDA #$08 : JSL SpriteAttack	; attack with 8 knockback
		JSL P2Attack : BCC .NoHurt
		JSR HurtGolem
		.NoHurt


		LDA !SpriteAnimIndex,x
		AND #$3F
		CMP #$06 : BEQ .YES		; 6 is actually the index lol
		CMP #$08 : BNE .NO
		LDA #$06
		LDY #$00
		BRA .GO				; big hand during punch
	.NO	LDA #$00
	.YES	LDY !SpriteDir,x
	.GO	LDX .HitIndex,y
		TAY
		REP #$20
		LDA !3D_X,x
		CLC : ADC .HitTable+0,y
		STA $E8
		LDA .HitTable+4,y
		AND #$00FF : STA $EC
		LDA .HitTable+5,y
		AND #$00FF : STA $EE
		LDA !3D_Y,x
		CLC : ADC .HitTable+2,y
		STA $EA
		SEP #$20
		LDX !SpriteIndex
		LDY #$04 : STY !dmg		; 1 full heart of damage
		LDA #$10 : JSL SpriteAttack	; attack with 16 knockback
		LDA !SpriteAnimIndex,x
		AND #$3F
		CMP #$06 : BEQ .Hit
		CMP #$08 : BNE .NoHand
	.Hit	LDA #$09 : STA !SPC4
		LDA #$0F : STA !ShakeTimer
		.NoHand


		REP #$20
		LDA !3D_X+$30 : STA $E8
		LDA !3D_Y+$30
		SEC : SBC #$0010
		STA $EA
		LDA #$0010
		STA $EC
		STA $EE
		SEP #$20
		JSL P2Attack
		BCC $03 : JSR HurtGolem
		JSL PlayerContact : BCC .NoContact
		LSR A : BCC .p2
	.p1	PHA
		LDY #$00 : JSR Interact
		PLA
	.p2	LSR A : BCC .NoContact
		LDY #$80 : JSR Interact
		.NoContact


		RTS



	.HitIndex
	db $50,$70			; index

	.HitTable
	dw $0002,$0002 : db $0C,$0C	; hitbox small
	dw $FFFC,$FFFC : db $18,$18	; hitbox large

	; for the hand hitbox:
	; direction is used to determine index (only front hand is used)
	; if anim&3F=6, then hitbox is bigger



	HurtGolem:
		LDA !CoinGolemHurtTimer,x : BNE .Return
		LDA #$80 : STA !CoinGolemHurtTimer,x
		LDA #$28 : STA !SPC4
		DEC !SpriteHP,x
	.Return	RTS


	Interact:
		LDA !P2YSpeed-$80,y
		CMP !SpriteYSpeed,x : BCS .Return
		JSL P2Bounce
		LDA #$02 : STA !SPC1		; SFX
		BRA HurtGolem
	.Return	RTS





	DATA:
		.XSpeed
		db $20,$E0

		.Friction
		db -$01,$01
		db -$04,$04

		.TurnRotation
		db $FF,$00

		.TurnSpeed
		db -$04,$04

		.HP
		db $02,$02,$04

		.AttackTime
		db $60,$50,$40

		.SightX
		db $00,$40

		.HeadTile
		db $03,$02

		.Dark
		db $04					; number of indexes
		db $20,$60,$70,$A0,$B0			; index list
		db $10,$40,$50,$80,$90			; index list




	namespace off




