CoinGolem:

	namespace CoinGolem



	!CoinGolemEye		= $BE,x			;\ used for dynamic uploads
	!CoinGolemPrevEye	= $3290,x		;/

	!CoinGolemHP		= $3280,x
	!CoinGolemTimer		= $32D0,x
	!CoinGolemHurtTimer	= $3360,x

	!CoinGolemTurnDir	= $32A0,x
	!CoinGolemTurn		= $32B0,x
	!CoinGolemHeight	= $32C0,x


	!CoinGolemAttack1	= $3340,x
	!CoinGolemAttack2	= $35D0,x
	!CoinGolemDead		= $35E0,x



	!YoshiCoinGFX		= $30F8A8



	MAIN:
		LDA !GameMode
		CMP #$14 : BEQ $01 : RTL

		PHB : PHK : PLB
		LDA !ExtraBits,x : BMI .Main

		.Init
		ORA #$80 : STA !ExtraBits,x
		LDA !MultiPlayer
		STA $00
		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_HP,y
		LDY $00
		BEQ $01 : ASL A
		STA !CoinGolemHP
		JSR ResetModel

		.Main
		JSL SPRITE_OFF_SCREEN_Long
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS


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


	PHYSICS:
		LDA !CoinGolemHP : BMI .Dead		;\
		BNE .Alive				; |
	.Dead	LDA !CoinGolemDead : BNE +		; |
		LDA #$01 : STA !CoinGolemDead		; |
		LDA #$02 : STA $3230,x			; | death check
		STZ !CoinGolemHurtTimer			; |
		LDA #$00				; |
		STA !3D_Distance+$30			; | head disappears on death so it can drop
		STA !3D_Distance+$31			; |
		LDA #$01				; |
		STA !3D_Extra+$30			;/

		JSL !GetSpriteSlot			;\
		LDA !3D_X+$30 : STA $3220,y		; |
		LDA !3D_X+$31 : STA $3250,y		; |
		LDA !3D_Y+$30 : STA $3210,y		; |
		LDA !3D_Y+$31 : STA $3240,y		; |
		LDA #$22 : STA !NewSpriteNum,y		; |
		LDA #$36 : STA $3200,y			; |
		LDA #$08 : STA $3230,y			; | drop the head as a Yoshi Coin upon death
		PHX					; |
		TYX					; |
		JSL $07F7D2				; | > Reset sprite tables
		JSL $0187A7				; | > Reset custom sprite tables
		LDA #$08 : STA !ExtraBits,x		; |
		LDA #$D0 : STA $9E,x			; |
		STZ $AE,x				; |
		PLX					;/
		STZ !CoinGolemEye			; > Reset eye tile so dropped coin won't look weird

	+	JMP GRAPHICS				; just go to graphics if sprite is dead

		.Alive
		PEA .Return-1				; > set return address
		LDA !CoinGolemTimer : BEQ .Process	;\ don't do animations if stunned
		RTS					;/

		.Process
		PHX					; push sprite index
		LDA !SpriteAnimIndex			;\
		AND #$3F				; |
		ASL A					; |
		CMP.b #.End-.Ptr			; | check for illegal states
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
		LDA !SpriteAnimIndex : BMI ..main
		ORA #$80
		STA !SpriteAnimIndex
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
		LDA #$C0 : STA !SpriteAnimIndex

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
		LDA #$02 : STA !CoinGolemHurtTimer
		LDA $00 : BNE ..r
		STZ $AE,x
		JSL !SpriteApplySpeed
		LDA $3330,x
		AND #$04 : BEQ ..r
		LDA #$09 : STA !SPC4				; sfx
		LDA #$1F : STA !ShakeTimer
		LDA #$02 : STA !SpriteAnimIndex
		LDA #$10 : STA !CoinGolemTimer			; pause a bit when landing
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
		LDA $3330,x			;\
		AND #$04			; | suspend animation if in midair
		BNE $01 : RTS			;/


		JSR ..Sight
		BCC ..main
		LDA !RNG
		AND #$04
		ORA #$03
		CMP !CoinGolemAttack1 : BNE +	; can't use the same attack more than twice in a row
		CMP !CoinGolemAttack2 : BNE +
		EOR #$04
	+	STA !SpriteAnimIndex
		XBA
		LDA !CoinGolemAttack1 : STA !CoinGolemAttack2
		XBA : STA !CoinGolemAttack1
		CMP #$03
		BNE $01 : INC A
		ASL #2
		AND #$18
		STA !SpriteAnimTimer
		RTS

		..main

		LDY $3320,x
		LDA DATA_TurnRotation,y : STA $00

		DEC !SpriteAnimTimer		; full body rotation around Y axis
		LDA !SpriteAnimTimer
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

		LDA !SpriteAnimTimer		; hip movements
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

		LDA !SpriteAnimTimer		; torso up/down
		LSR #2
		EOR #$04
		AND #$07
		SEC : SBC #$04
		BPL $02 : EOR #$FF
		CLC : ADC #$11
		STA !CoinGolemHeight


		RTS


	; sight-box
	..Sight
		LDY $3320,x
		LDA $3220,x
		SEC : SBC DATA_SightX,y
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$80
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$40 : STA $06
		LDA #$FF : STA $07
		SEC : JSL !PlayerClipping
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
		LDA $3320,x : STA !CoinGolemTurnDir
		LDA $3330,x
		AND #$04 : BEQ ..r
		LDA !SpriteAnimIndex : BMI ..Main		; reset model at the start of the jump animation
		ORA #$80 : STA !SpriteAnimIndex
		JSR ResetModel

		..Main
		LDY #$00
		JSR SquatJumpAnim
		DEC !CoinGolemHeight
		DEC !SpriteAnimTimer
		LDA !SpriteAnimTimer : BNE ..r
		LDA #$04 : STA !SpriteAnimIndex
		LDA #$10 : STA !SpriteAnimTimer
	..r	RTS



	.Jump
		PLX
		JSR TargetEye
		LDA $3330,x
		AND #$04 : BEQ +
		LDA !3D_AngleV+$40
		CMP #$30 : BNE ++
		LDA #$C0 : STA $9E,x
		LDA #$08 : STA !SPC4				; jump SFX
		BRA +

	++	LDY #$01
		JSR SquatJumpAnim
		INC !CoinGolemHeight
		INC !CoinGolemHeight

	+	DEC !SpriteAnimTimer
		LDA !SpriteAnimTimer : BNE ..r
		LDA #$05 : STA !SpriteAnimIndex
	..r	RTS



	.Freefall
		PLX
		JSR TargetEye
		LDA $3330,x
		AND #$04 : BNE ..Ground
		JSR .Run_Sight
		BCC ..r
		LDA #$06 : STA !SpriteAnimIndex
		LDA #$18 : STA !SpriteAnimTimer			; slam when in sight
		RTS


		..Ground
		LDA #$02 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JSR ResetModel
		JSR .Run_Sight
		BCC ..r
		LDA #$03 : STA !SpriteAnimIndex
		LDA #$10 : STA !SpriteAnimTimer
	..r	RTS



	; sprite timer is supposed to be 0x18
	.Slam
		PLX
		LDA #$08 : STA !CoinGolemEye
		BIT !SpriteAnimIndex
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
		LDA $3330,x
		AND #$04 : BNE ..land
		LDA !SpriteAnimTimer : BEQ ..r

		LDA !3D_AngleYZ
		SEC : SBC #$0E
		STA !3D_AngleYZ

		LDA !3D_AngleV+$80
		CLC : ADC #$0B
		STA !3D_AngleV+$80
		LDA !3D_AngleV+$A0
		CLC : ADC #$0B
		STA !3D_AngleV+$A0

	+	DEC !SpriteAnimTimer
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..r
		LDA !SpriteAnimIndex
		ORA #$80
		STA !SpriteAnimIndex
	..r	RTS

		..land
		LDA !SpriteAnimIndex
		ORA #$40
		STA !SpriteAnimIndex
		LDA #$09 : STA !SPC4
		LDA #$0F : STA !ShakeTimer
		LDA #$0F : STA !CoinGolemTimer
		RTS

		..landed
		JMP .Freefall_Ground


	.Backswing
		PLX
		LDA $3320,x : STA !CoinGolemTurnDir
		LDA #$08 : STA !CoinGolemEye
		LDA !SpriteAnimIndex : BMI ..Main
		ORA #$80 : STA !SpriteAnimIndex
		LDY $3320,x
		LDA DATA_XSpeed,y : STA $AE,x
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

		DEC !SpriteAnimTimer
		LDA !SpriteAnimTimer : BNE ..r
		LDA #$08 : STA !SpriteAnimIndex
		LDA #$18 : STA !SpriteAnimTimer
	..r	RTS




	.Punch
		PLX

		LDA !SpriteAnimTimer
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


	+	DEC !SpriteAnimTimer
		LDA !SpriteAnimTimer : BNE ..r
		LDA #$02 : STA !SpriteAnimIndex
		JSR ResetModel
	..r	RTS




	.Turn
		PLX
		LDY !CoinGolemTurnDir
		LDA !3D_AngleXZ : STA $00
		CLC : ADC DATA_TurnSpeed,y
		STA !3D_AngleXZ
		EOR $00 : BPL +
		LDA $3320,x
		EOR #$01
		STA $3320,x
	+	DEC !CoinGolemTurn : BNE ..r
		LDA #$02 : STA !SpriteAnimIndex
		PHX
		JMP .Run
	..r	RTS


	.Return
		LDY $3320,x
		LDA !CoinGolemTimer : BNE INTERACTION	; no movement if timer is set
		LDA !SpriteAnimIndex			;\
		AND #$3F				; | states that have friction
		BEQ INTERACTION				; > 0 does not move at all
		CMP #$03 : BEQ .Friction		; |
		CMP #$07 : BCS .Friction		;/
		CMP #$06 : BNE +			;\
		LDA $3330,x				; | Slam has friction if on the ground
		AND #$04 : BEQ .NoTurn			; |
		BRA .Friction				;/
	+	CMP #$01 : BEQ .CheckTurn		;\ states that can turn
		CMP #$02 : BNE .NoTurn			;/

		.CheckTurn				;\
		JSL SUB_HORZ_POS_Long			; |
		TYA					; |
		CMP $3320,x : BEQ .NoTurn		; |
		LDA #$09 : STA !SpriteAnimIndex		; |
		LDY $3320,x				; | handle turning around
		LDA !3D_AngleXZ				; |
		EOR DATA_TurnRotation,y			; |
		BPL $03 : EOR #$FF : INC A		; |
		LSR A					; |
		STA !CoinGolemTurn			; |
		TYA : STA !CoinGolemTurnDir		; |
		BRA .Turning				;/

		.Friction
		LDY !CoinGolemTurnDir			;\
		LDA !SpriteAnimIndex			; \
		AND #$3F				;  | extra friction during landing slam
		CMP #$06				;  |
		BNE $02 : INY #2			; /
		LDA $AE,x : BEQ .Turning		; |
		STA $00					; |
		CLC : ADC DATA_Friction,y		; | apply friction
		STA $AE,x				; |
		EOR $00					; |
		BPL .Turning				; |
		STZ $AE,x				; |
		BRA .Turning				;/

		.NoTurn
		LDA DATA_XSpeed,y : STA $AE,x		; set X speed
		.Turning

		JSL !SpriteApplySpeed






	INTERACTION:




	GRAPHICS:


	LDA $3220,x : STA.l !3D_X+0
	LDA $3250,x : STA.l !3D_X+1
	LDA $3210,x
	SEC : SBC !CoinGolemHeight
	STA.l !3D_Y+0
	LDA $3240,x
	SBC #$00
	STA.l !3D_Y+1

		LDY.b #ANIM_Start-ANIM-1
	-	LDA ANIM,y : STA !3D_TilemapCache,y
		DEY : BPL -
		REP #$20
		LDA.w #!3D_TilemapCache : STA.l !3D_TilemapPointer
		SEP #$20
		LDA !GFX_status+$15
		STA !3D_TilemapCache+(ANIM_YoshiCoin-ANIM)+$9
		STA !3D_TilemapCache+(ANIM_YoshiCoin40-ANIM)+$9
		INC #2
		STA !3D_TilemapCache+(ANIM_YoshiCoin-ANIM)+$5
		STA !3D_TilemapCache+(ANIM_YoshiCoin40-ANIM)+$5
		INC #2
		STA !3D_TilemapCache+(ANIM_DarkCoin-ANIM)+$5

	LDA !CoinGolemDead : BNE +
		LDY $3320,x
		LDA DATA_HeadTile,y : STA !3D_Extra+$30
	+

		PHX
		LDA $3320,x
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


	JSL Rotate

		LDA !SpriteAnimIndex
		AND #$3F : BEQ +
		JSR Hitbox
		+

		LDY !BigRAM			; tilemap size determines loop count
	-	LDA !BigRAM+4,y			;\
		SEC : SBC !CoinGolemHeight	; | apply height
		STA !BigRAM+4,y			;/
		LDA !BigRAM+2,y			;\
		AND #$40 : BEQ +		; |
		LDA !BigRAM+3,y			; | ignore xflip for xcoord
		EOR #$FF			; |
		STA !BigRAM+3,y			;/
	+	DEY #4 : BPL -			; loop



		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20

		LDA $3320,x : PHA
		LDA #$01 : STA $3320,x


		LDA !CoinGolemHurtTimer
		AND #$04 : BNE +
		JSL LOAD_TILEMAP_Long
		+

		PLA : STA $3320,x


		LDA !CoinGolemEye				;\
		CMP !CoinGolemPrevEye : BEQ .Return		; |
		ASL A						; |
		TAY						; |
		REP #$20					; |
		LDA !GFX_status+$15				; | update eye tile
		AND #$00FF					; |
		STA $02						; |
		LDA Dynamo,y : STA $0C				; |
		SEC : JSL !UpdateGFX				; |
		SEP #$20					;/



		.Return
		LDA !CoinGolemEye : STA !CoinGolemPrevEye
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
		db $24,$00,$00,$4C

		.DarkCoin
		dw $0004
		db $25,$00,$00,$04

		.YoshiCoin
		dw $0008
		db $25,$00,$00,$02
		db $25,$00,$F0,$00

		.YoshiCoin40
		dw $0008
		db $65,$00,$00,$02
		db $65,$00,$F0,$00



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


macro Eye(tile)
	dl !YoshiCoinGFX+(<tile>*$20)
endmacro


	Dynamo:
		dw .Normal		; 00
		dw .ForwardDown		; 01
		dw .Down		; 02
		dw .BackDown		; 03
		dw .Back		; 04
		dw .BackUp		; 05
		dw .Up			; 06
		dw .ForwardUp		; 07
		dw .Angry		; 08
		dw .Troll		; 09
		dw .Dishonest		; 0A


		.Normal
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($11)
		dw $7110
		..End

		.ForwardDown
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($6)
		dw $7110
		..End

		.Down
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($7)
		dw $7110
		..End

		.BackDown
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($8)
		dw $7110
		..End

		.Back
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($9)
		dw $7110
		..End

		.BackUp
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($A)
		dw $7110
		..End

		.Up
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($B)
		dw $7110
		..End

		.ForwardUp
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($C)
		dw $7110
		..End

		.Angry
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($D)
		dw $7110
		..End

		.Troll
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($E)
		dw $7110
		..End

		.Dishonest
		dw ..End-..Start
		..Start
		dw $0020
		%Eye($F)
		dw $7110
		..End


	ResetModel:
		LDA !CoinGolemTimer : BNE .Return
		PHX
		LDX #$00
	-	LDA.w ANIM_Start,x : STA.l !3D_Base,x
		INX
		CPX.b #ANIM_End-ANIM_Start : BNE -
		PLX
		LDA #$14 : STA !CoinGolemHeight
		LDY $3320,x : BEQ .Return
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
	.Win	LDA #$09 : STA !CoinGolemEye
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
		JSL ADEPT_ROUTE_GetNode_Long
		LDA .Index,y
		BIT $0F
		BPL $02 : ORA #$04
		BIT $07
		BPL $02 : ORA #$08
		LDY $3320,x
		BNE $02 : EOR #$04
		TAY
		LDA .Eye,y : STA !CoinGolemEye
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
		STA $04
		STA $09
		SEC : SBC.w !3D_X+$10
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC #$000C
		STA $06
		LDA.w !3D_Y+$10
		CMP.w !3D_Y+$20
		BCC $03 : LDA.w !3D_Y+$20
		CLC : ADC #$0004
		SEP #$20
		STA $05
		XBA : STA $0B
		XBA
		SEC : SBC.w !3D_Y+$00
		BPL $02 : EOR #$FF
		CLC : ADC #$0C
		STA $07
		PLB
		SEC : JSL !PlayerClipping
		BCC $04 : JSL !HurtPlayers
		JSL P2Attack_Long
		BCC .NoHurt
		JSR HurtGolem
		.NoHurt


		LDA !SpriteAnimIndex
		AND #$3F
		CMP #$06 : BEQ .YES		; 6 is actually the index lol
		CMP #$08 : BNE .NO
		LDA #$06
		LDY #$00
		BRA .GO				; big hand during punch
	.NO	LDA #$00
	.YES	LDY $3320,x
	.GO	LDX .HitIndex,y
		TAY
		REP #$20
		LDA !3D_X,x
		CLC : ADC .HitTable+0,y
		STA $04
		STA $09
		LDA .HitTable+4,y : STA $06
		LDA !3D_Y,x
		CLC : ADC .HitTable+2,y
		SEP #$20
		STA $05
		XBA : STA $0B
		LDX !SpriteIndex
		SEC : JSL !PlayerClipping
		BCC .NoHand
		JSL !HurtPlayers
		LDA !SpriteAnimIndex
		AND #$3F
		CMP #$06 : BEQ .Hit
		CMP #$08 : BNE .NoHand
	.Hit	LDA #$09 : STA !SPC4
		LDA #$0F : STA !ShakeTimer
		.NoHand


		REP #$20
		LDA !3D_X+$30
		STA $04
		STA $09
		LDA !3D_Y+$30
		SEC : SBC #$0010
		SEP #$20
		STA $05
		XBA : STA $0B
		LDA #$10 : STA $06
		LDA #$10 : STA $07
		JSL P2Attack_Long
		BCC $03 : JSR HurtGolem
		SEC : JSL !PlayerClipping
		BCC .NoContact
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
		LDA !CoinGolemHurtTimer : BNE .Return
		LDA #$80 : STA !CoinGolemHurtTimer
		LDA #$28 : STA !SPC4
		DEC !CoinGolemHP
	.Return	RTS


	Interact:
		LDA !P2YSpeed-$80,y
		CMP $9E,x : BCS .Return
		JSL P2Bounce_Long
		LDA #$02 : STA !SPC1		; SFX
		BRA HurtGolem
	.Return	RTS




	; call to view a hitbox stored in $04-$07, $0A-$0B (standard SMW format)
	ViewHitbox:

		LDA $04 : STA $00
		LDA $0A : STA $01
		LDA $05 : STA $02
		LDA $0B : STA $03
		LDA $06 : STA $0C
		LDA $07 : STA $0E
		STZ $0D
		STZ $0F

		REP #$20
		LDA $00
		SEC : SBC $1A
		CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		SEP #$20
		RTL

	.GoodX	STA $00
		CLC : ADC $0C
		SEC : SBC #$0010
		STA $0C
		LDA $02
		SEC : SBC $1C
		CMP #$00D8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		SEP #$20
		RTL

	.GoodY	STA $02
		CLC : ADC $0E
		SEC : SBC #$0010
		STA $0E

		SEP #$20
		LDA $00
		STA !OAM+$00
		STA !OAM+$08
		LDA $0C
		STA !OAM+$04
		STA !OAM+$0C
		LDA $02
		STA !OAM+$01
		STA !OAM+$05
		LDA $0E
		STA !OAM+$09
		STA !OAM+$0D
		LDA #$24
		STA !OAM+$03
		STA !OAM+$07
		STA !OAM+$0B
		STA !OAM+$0F
		LDA #$84
		STA !OAM+$02
		STA !OAM+$06
		STA !OAM+$0A
		STA !OAM+$0E
		LDA #$02
		STA !OAMhi+$00
		STA !OAMhi+$01
		STA !OAMhi+$02
		STA !OAMhi+$03
		RTL


	; $00-$01: parent X position (16-bit)
	; $02-$03: parent Y position (16-bit)
	; $04-$05: parent Z position (16-bit)
	; $06-$07: calculating X position (16-bit)
	; $08-$09: calculating Y position (16-bit)
	; $0A-$0B: calculating Z position (16-bit)

	; Each parent position is pushed on the stack, then loaded into $06-$0B


; Start processing from index 0 and go all the way up
; The core has to be the first (lowest index) object of each cluster.
; Only the core has a true X/Y/Z coordinate.
; When an attachment is processed, its X/Y/Z coordinates are stored based on the parent's X/Y/Z coordinates.
; Therefore, each attachment must be processed after its parent.




	Rotate:
		PHB				;\
		PLA : STA.l !3D_BankCache	; | bank on stack and in cache
		PHA				;/
		PHX
		PHP
		STZ $2250
		LDA.b #!3D_Base>>16
		PHA : PLB
		REP #$30



		LDX #$0000
		LDY #$0000

	-	LDA.w !3D_Slot,y
		AND #$00FF : BEQ .Next
		TYA
		CMP.w !3D_Attachment,y : BEQ .Core
		LDX.w !3D_Attachment,y
		JSR .Calc
		BRA .Next

		.Core
		PHY
		LDA.w !3D_X,y : PHA
		LDA.w !3D_Y,y : PHA
		LDA.w !3D_Z,y : PHA


		.Next
		TYA
		CLC : ADC #$0010
		TAY
		CPY #$0400 : BCC -


		.TranscribeTilemap
		PLA : STA $04
		PLA : STA $02
		PLA : STA $00
		PLX
		LDA.w !3D_AngleXY,x : BNE +		;\ skip rotation if no angles are set
		LDA.w !3D_AngleXZ,x : BEQ ++		;/
	+	JSR Transform				; rotate around axes
	++

		STZ $0C
		LDX #$0000
		LDY #$0000
		STZ.w !3D_AssemblyCache			; how many objects will be added to tilemap
	-	LDA.w !3D_Slot,y : BEQ +

		LDA.w !3D_X,y
		SEC : SBC $00
		STA.w !3D_AssemblyCache+$02,x
		LDA.w !3D_Y,y
		SEC : SBC $02
		STA.w !3D_AssemblyCache+$03,x
		LDA.w !3D_Z,y
		AND #$00FF
		STA.w !3D_AssemblyCache+$04,x
		LDA.w !3D_Extra,y : STA.w !3D_AssemblyCache+$06,x
		INX #8
		STX.w !3D_AssemblyCache			; increment header
		INC $0C					; increment object count

	+	TYA
		CLC : ADC #$0010
		TAY
		CPY #$0400 : BCC -


	; now all objects are in !3D_AssemblyCache
	; first 2 bytes is header
	; X is written to X+0
	; Y is written to X+1
	; Z is written to X+2
	; X+3 is clear (nonzero signals that this has been taken)
	; X+4 and X+5 is tilemap data

	; Sort by Z value and transcribe to tilemap from highest to lowest


	; $0B = highest Z found so far
	; $0C = how many objects there are
	; $0D = how many objects have been transcribed
	; $0E = index of currently highest Z

		LDX #$0000
		LDY #$0000
		SEP #$20
		STZ $0B
		STZ $06						; for tilemap assembly

	-	LDA.w !3D_AssemblyCache+$05,y : BNE +
		LDA.w !3D_AssemblyCache+$04,y
		CMP $0B : BCC +
		STA $0B
		STY $0E

	+	INY #8
		CPY.w !3D_Base+$400 : BNE -

	.Z	LDY $0E
		REP #$20
		LDA.w !3D_AssemblyCache+$02,y : STA $00		; X/Y offset
		STZ $02						; tile/prop data
		PHY
		LDA.w !3D_AssemblyCache+$06,y
		AND #$00FF
		ASL A
		TAY
		LDA.w !3D_TilemapPointer : STA $08
		SEP #$20
		PHB
		LDA.w !3D_BankCache : PHA : PLB
		REP #$20
		LDA ($08),y
		JSL LakituLovers_TilemapToRAM_Long
		PLB
		PLY
		SEP #$20
		STZ $0B
		INX #4
		LDA #$FF : STA.w !3D_AssemblyCache+$05,y
		LDY #$0000
		INC $0D
		LDA $0D
		CMP $0C : BNE -



		.Return
		PLP
		PLX
		PLB
		RTL




		.Calc
		LDA.w !3D_X,x : STA $00			;\
		LDA.w !3D_Y,x : STA $02			; | parent coordinates
		LDA.w !3D_Z,x : STA $04			;/

		PHY
		PHP
		SEP #$20
		STZ $0D
		STZ $0E
		STZ $0F
	-	STY $08
		LDX.w !3D_Attachment,y
		CPX $08 : BEQ +

		STX $08					;\
		LDY.w !3D_Attachment,x			; | don't apply core rotation yet
		CPY $08 : BEQ +				;/

		LDA.w !3D_AngleH,x
		CLC : ADC $0E
		STA $0E
		LDA.w !3D_AngleV,x
		CLC : ADC $0F
		STA $0F
		TXY
		BRA -

	+	PLP
		PLY






; process:
;
; z = d * cos(v)
; r = d * sin(v)
; x = r * cos(h)
; y = r * sin(h)
;
; add offsets to parent coordinates to get attachment coordinates



		LDA.w !3D_AngleV,y
		CLC : ADC $0F
		PHA
		CLC : ADC #$0040
		JSR Trig
		STA.l $2251
		LDA.w !3D_Distance,y : STA.l $2253
		NOP : BRA $00
		LDA.l $2307 : STA $08
		LDA.l $2306
		AND #$00FF
		CMP #$0080
		BCC $02 : INC $08			; distance on XY plane
		PLA
		JSR Trig
		STA.l $2251
		LDA.w !3D_Distance,y : STA.l $2253
		NOP : BRA $00
		LDA.l $2308 : STA $0A
		LDA.l $2306
		BPL $02 : INC $0A			; Z coordinate

		LDA.w !3D_AngleH,y
		CLC : ADC $0E
		PHA
		CLC : ADC #$0040
		JSR Trig
		STA.l $2251
		LDA $08 : STA.l $2253
		NOP : BRA $00
		LDA.l $2308 : STA $06
		LDA.l $2306
		BPL $02 : INC $06			; X coordinate

		PLA
		JSR Trig
		STA.l $2251
		LDA $08 : STA.l $2253
		NOP : BRA $00
		LDA.l $2308 : STA $08
		LDA.l $2306
		BPL $02 : INC $08			; Y coordinate

		LDA $06
		CLC : ADC $00
		STA.w !3D_X,y
		LDA $08
		CLC : ADC $02
		STA.w !3D_Y,y
		LDA $0A
		CLC : ADC $04
		STA.w !3D_Z,y
		RTS


	Trig:
		PHX
		ASL #2
		AND #$03FF
		CMP #$0200
		PHP
		AND #$01FF
		TAX
		LDA.l !TrigTable,x
		PLP
		BCC $04 : EOR #$FFFF : INC A
		PLX
		RTS


	Control:
		PHP
		SEP #$20
		LDA $15
		LSR A : BCS .XZcl
		LSR A : BCS .XZco
		LSR A : BCS .YZcl
		LSR A : BCS .YZco
		LDA $17
		ASL #3 : BCS .XYco
		ASL A : BCS .XYcl
		BRA +

	.YZcl	INC.w !3D_AngleYZ,x : BRA +
	.YZco	DEC.w !3D_AngleYZ,x : BRA +
	.XZcl	INC.w !3D_AngleXZ,x : BRA +
	.XZco	DEC.w !3D_AngleXZ,x : BRA +
	.XYcl	INC.w !3D_AngleXY,x : BRA +
	.XYco	DEC.w !3D_AngleXY,x
		+
		PLP
		RTS


	Transform:

		LDY #$0000

	-	STY $0E
		CPX $0E : BEQ .Next
		LDA.w !3D_X,y
		SEC : SBC $00
		STA.w !3D_X,y
		LDA.w !3D_Y,y
		SEC : SBC $02
		STA.w !3D_Y,y
		LDA.w !3D_Z,y
		SEC : SBC $04
		STA.w !3D_Z,y
		LDA.w !3D_AngleXY,x			;\
		AND #$00FF				; | rotation around z axis
		BEQ $03 : JSR .CalcXY			;/
		LDA.w !3D_AngleYZ,x			;\
		AND #$00FF				; | rotation around x axis
		BEQ $03 : JSR .CalcYZ			;/
		LDA.w !3D_AngleXZ,x			;\
		AND #$00FF				; | rotation around y axis
		BEQ $03 : JSR .CalcXZ			;/
		LDA.w !3D_X,y
		CLC : ADC $00
		STA.w !3D_X,y
		LDA.w !3D_Y,y
		CLC : ADC $02
		STA.w !3D_Y,y
		LDA.w !3D_Z,y
		CLC : ADC $04
		STA.w !3D_Z,y

		.Next
		TYA
		CLC : ADC #$0010
		TAY
		CPY #$0400 : BNE -
		RTS


		.CalcXY
		LDA.w !3D_X,y
		STA.w !3D_Cache1
		STA.w !3D_Cache3
		LDA.w !3D_Y,y
		STA.w !3D_Cache4
		EOR #$FFFF
		INC A
		STA.w !3D_Cache2
		LDA.w !3D_AngleXY,x : STA.w !3D_Cache5
		JSR .Calc
		LDA.w !3D_Cache7 : STA.w !3D_X,y
		LDA.w !3D_Cache8 : STA.w !3D_Y,y
		RTS

		.CalcXZ
		LDA.w !3D_X,y
		STA.w !3D_Cache1
		EOR #$FFFF
		INC A
		STA.w !3D_Cache3
		LDA.w !3D_Z,y
		STA.w !3D_Cache2
		STA.w !3D_Cache4
		LDA.w !3D_AngleXZ,x : STA.w !3D_Cache5
		JSR .Calc
		LDA.w !3D_Cache7 : STA.w !3D_X,y
		LDA.w !3D_Cache8 : STA.w !3D_Z,y
		RTS

		.CalcYZ
		LDA.w !3D_Y,y
		STA.w !3D_Cache1
		STA.w !3D_Cache3
		LDA.w !3D_Z,y
		STA.w !3D_Cache4
		EOR #$FFFF
		INC A
		STA.w !3D_Cache2
		LDA.w !3D_AngleYZ,x : STA.w !3D_Cache5
		JSR .Calc
		LDA.w !3D_Cache7 : STA.w !3D_Y,y
		LDA.w !3D_Cache8 : STA.w !3D_Z,y
		RTS


; input:
;	cache1 = coordinate 1
;	cache2 = coordinate 2
;	cache3 = coordinate 3
;	cache4 = coordinate 4
;	cache5 = angle
;
; output:
;	cache7 = coordinate 1
;	cache8 = coordinate 2


		.Calc
		LDA.w !3D_Cache5
		PHA
		CLC : ADC #$0040
		JSR Trig
		STA.w !3D_Cache6			; cache2 = cos(a)
		PLA
		JSR Trig
		STA.w !3D_Cache5			; cache1 = sin(a)

		LDA.w !3D_Cache6 : STA.l $2251
		LDA.w !3D_Cache1 : STA.l $2253
		NOP : BRA $00
		LDA.l $2307 : STA $06
		LDA.l $2306
		AND #$00FF
		CMP #$0080
		BCC $02 : INC $06			; $06 = product 1
		LDA.w !3D_Cache5 : STA.l $2251
		LDA.w !3D_Cache2 : STA.l $2253
		NOP : BRA $00
		LDA.l $2307 : STA $08
		LDA.l $2306
		AND #$00FF
		CMP #$0080
		BCC $02 : INC $08			; $08 = product 2
		LDA $06
		CLC : ADC $08
		STA.w !3D_Cache7			; cache7 = coordinate 1 (X or Y)

		LDA.w !3D_Cache5 : STA.l $2251
		LDA.w !3D_Cache3 : STA.l $2253
		NOP : BRA $00
		LDA.l $2307 : STA $06
		LDA.l $2306
		AND #$00FF
		CMP #$0080
		BCC $02 : INC $06			; $06 = product 3
		LDA.w !3D_Cache6 : STA.l $2251
		LDA.w !3D_Cache4 : STA.l $2253
		NOP : BRA $00
		LDA.l $2307 : STA $08
		LDA.l $2306
		AND #$00FF
		CMP #$0080
		BCC $02 : INC $08			; $08 = product 4
		LDA $06
		CLC : ADC $08
		STA.w !3D_Cache8			; cache8 = coordinate 2 (Y or Z)

		RTS



	namespace off





