

BigMax:



	namespace BigMax



	!LoadedTile	= $3280,x		; tile being loaded
	!SubTile	= $3290,x		; number of 8x8 tiles that have been rendered
						; highest bit toggles which side to display (0 = left, 1 = right)
	!Size		= $32A0,x
	!Phase		= $32B0,x		; determines behavior and hitbox size
	!StunTimer	= $32D0,x		;

	!FireTimer	= $32F0,x
	!HP		= $3340,x

	!Super		= $BE,x			; super move flag, different for each phase

	!ExtraTimer	= $33E0,x		; used for stuff

	!WallBreak	= $35B0,x		; used for breaking the wall on the right side

	!LoadStatus	= $35E0,x		; used to render extra frames


	!EatStatus	= $6DF5			; not indexed, so it can be used whenever
						; ep--iiii
						; e - eating (0 = not eating, 1 = eating)
						; p - player (0 = sprite, 1 = player)
						; i - index (player 0-1 or sprite 0-F)



	INIT:
		PHB : PHK : PLB

		LDA #$02 : STA !SpriteAnimIndex
		LDA #$C0 : STA $9E,x
		LDA #$10 : STA $AE,x

		LDA #$80 : STA !Size

		LDA #$04 : STA !HP

		PLB
		RTL


	Data:
		.XSpeed
		db $10,$F0			; phase 1
		db $18,$E8,$30,$D0		; phase 2
		db $20,$E0			; phase 5 dash


		.Size
		db $80,$C0,$00,$0F,$7F		; note that during phase 4 he keeps growing

		.HP
		db $04,$04,$04,$10,$10		; indexed by phase


		.EatOffsetX
		dw $FFF0,$FFF0

		.EatOffsetY
		dw $FFF8,$FFD8


		.Phase2Fire
		db $6F,$5F,$4F



	MAIN:
		PHB : PHK : PLB

		LDA !Level+2
		CMP #$10 : BNE .Nope
		LDA !GameMode
		CMP #$14 : BEQ .Process
	.Nope	PLB
		RTL
		.Process

		LDA !LoadStatus
		CMP #$10 : BEQ .NoLoad
		AND #$08
		LSR A
		TAY
		LDA #$40 : STA $02			; source bank
		REP #$20
		LDA Anim_InitData+0,y : STA $00
		LDA Anim_InitData+2,y : PHA		; push starting VRAM
		SEP #$20
		LDA #$20
		STA $03
		STA $04
		LDA !Size
		STA $05
		STA $06
		LDA #$20 : STA $07
		LDA #$40 : STA $08
		LDA #$03				; 8-stage render
		CLC					;\
		LDA !LoadStatus				; | check for first step
		AND #$07 : BEQ $01 : SEC		;/
		PHA					; push step counter
		JSL !TransformGFX			; render
		PLA : STA $00				; pull step counter into $00
		JSL !GetVRAM				;\
		LDA.b #!VRAMbank			; |
		PHA : PLB				; |
		STA.w !VRAMtable+$04,x			; |
		REP #$20				; |
		LDA $00					; |
		AND #$0007				; |
		XBA					; |
		STA $0C					; | upload 1 row every frame
		CLC : ADC.w #!GFX_buffer		; |
		STA.w !VRAMtable+$02,x			; |
		PLA					; > pull starting VRAM
		CLC : ADC $0C				; |
		STA.w !VRAMtable+$05,x			; |
		LDA #$0100 : STA.w !VRAMtable+$00,x	;/
		SEP #$20
		PHK : PLB				; restore bank
		LDX !SpriteIndex			; restore sprite index
		INC !LoadStatus
	.Lock	JMP Graphics_DontRender
		.NoLoad


		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE .Lock


		LDA !ExtraTimer
		BEQ $03 : DEC !ExtraTimer



	Movement:
		PEA Interaction-1
		LDA !Phase
		ASL A
		TAX
		JMP (.PhasePtr,x)



		.PhasePtr
		dw .Phase1
		dw .Phase2
		dw .Phase3
		dw .Phase4
		dw .Phase5
		.PhasePtrEnd


	.Phase1
		LDX !SpriteIndex

		LDA !Super : BEQ ..NoBounce
		LDA !SpriteAnimIndex
		CMP #$01 : BNE +
		RTS

	+	LDA !FireTimer : BNE ..Bounce
		STZ !Super
		BRA ..NoBounce

		..Bounce
		LDA $3330,x
		AND #$03 : BEQ +
		LDA $AE,x
		EOR #$FF : INC A
		STA $AE,x
		LDA $3320,x
		EOR #$01
		STA $3320,x

	+	LDA $3330,x
		AND #$0C : BEQ +
		LDA $9E,x
		EOR #$FF : INC A
		STA $9E,x
	+	JMP ..Speed
		..NoBounce


		LDA $3330,x					;\
		AND #$08 : BEQ ..NoCeiling			; | ceiling collision
		LDA #$10 : STA $9E,x				; |
		..NoCeiling					;/



		LDA $3330,x					;\
		AND #$03 : BEQ ..NoWall				; |
		LDA $3320,x					; |
		EOR #$01					; |
		STA $3320,x					; | jump off of walls
		TAY						; |
		LDA Data_XSpeed+0,y : STA $AE,x			; |
		LDA #$C0 : STA $9E,x				; |
		LDA #$0A : STA !SpriteAnimIndex			; |
		LDA $3330,x					; |
		AND.b #$04^$FF					; |
		STA $3330,x					; |
		..NoWall					;/


		LDA $3330,x
		AND #$04 : BNE ..Ground
		JMP ..Air

		..Ground
		LDA !Phase					;\ no super in phase 4
		CMP #$03 : BEQ ..NoSuper			;/
		LDA !RNG : BNE ..NoSuper			; start super if RNG = 0
		LDA #$01 : STA !Super				;\ start super
		LDA #$FF : STA !FireTimer			;/
		LDA $3220,x : STA $00				;\
		LDA $3250,x : STA $01				; |
		LDA $3240,x : XBA				; |
		LDA $3210,x					; |
		REP #$20					; |
		CLC : ADC #$0020				; |
		SEC : SBC !P2YPosLo-$80				; |
		STA $02						; | super speeds
		LDA $00						; |
		SEC : SBC !P2XPosLo-$80				; |
		STA $00						; |
		SEP #$20					; |
		LDA #$40 : JSL AIM_SHOT				; |
		LDA $04 : STA $AE,x				; |
		LDA $06 : STA $9E,x				;/
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA $3320,x				;/
		LDA #$FD : STA $3500,x				;\ no gravity during super
		LDA #$BF : STA $3510,x				;/
		LDA #$01 : STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer				; |
		LDA #$C0 : STA !LoadedTile			; | roar animation into jump
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					;/
		LDA #$25 : STA !SPC1				; > roar SFX
		JMP ..Speed
		..NoSuper



		LDA !Phase : BEQ ..Run

		..Walk
		LDA !SpriteAnimIndex				;\
		CMP #$0B : BCS +				; |
		LDA #$0B : STA !SpriteAnimIndex			; | play walk animation
		STZ !SpriteAnimTimer				; |
		LDA #$08 : STA !LoadedTile			; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
	+	BRA ++						;/

		..Run
		LDA !SpriteAnimIndex				;\
		CMP #$02 : BCC +				; |
		CMP #$0A : BCC ++				; | play run animation
	+	LDA #$02 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer				; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
		++						;/


		STZ $9E,x					; no Y speed on ground
		LDA !RNG					;\
		AND #$3F : BNE +				; |
		LDA #$FF : STA !FireTimer			; |
		JSL SUB_HORZ_POS				; | randomly jump
		TYA						; |
		STA $3320,x					; |
		LDA #$C0 : STA $9E,x				; |
		LDA #$0A : STA !SpriteAnimIndex			;/
	+	LDY $3320,x					;\ run speed
		LDA Data_XSpeed+0,y : STA $AE,x			;/
		BRA ..Speed

		..Air
		LDA !FireTimer
		CMP #$EC : BEQ ..fire
		CMP #$E8 : BEQ ..fire
		CMP #$E4 : BEQ ..fire
		CMP #$E0 : BNE ..Speed

	..fire	JSR Fireball
		LDA $9E,x
		SEC : SBC #$10
		STA $9E,x

		..Speed
		JSL !SpriteApplySpeed
		RTS


	.Phase2
		LDX !SpriteIndex


		LDA !FireTimer : BEQ ..NoFire
		CMP #$3C : BEQ ..fire
		CMP #$38 : BEQ ..fire
		CMP #$34 : BEQ ..fire
		CMP #$30 : BEQ ..fire
		RTS

	..fire	JSR Fireball
		LDA $309E,y
		EOR #$FF
		STA $309E,y
		RTS
		..NoFire


		LDA !SpriteAnimIndex				;\
		CMP #$02 : BCC +				; |
		CMP #$0A : BCC ++				; | play run animation
	+	LDA #$02 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer				; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
		++						;/


		LDA !Super : BNE ..NoFireball			;\
		LDA !RNG					; |
		AND #$7F : BNE ..NoFireball			; |
		LDA #$01 : STA !SpriteAnimIndex			; | start fireball attack
		STZ !SpriteAnimTimer				; |
		LDA #$04 : STA !LoadedTile			; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
		LDA !Difficulty					; |
		AND #$03					; |
		TAY						; |
		LDA Data_Phase2Fire,y : STA !FireTimer		; |
		LDA #$25 : STA !SPC1				; > roar SFX
		..NoFireball					;/



		LDA $3330,x
		AND #$03 : BEQ +
		LDA $3320,x
		EOR #$01
		STA $3320,x
		LDA !Super : BEQ ..RollSuper
		STZ !Super
		BRA +

	..RollSuper
		LDA !RNG
		AND #$01
		STA !Super
	+	LDY $3320,x
		LDA !Super : BEQ ..X
		INY #2
	..X	LDA Data_XSpeed+2,y : STA $AE,x

		LDA $3330,x
		AND #$04 : BEQ ..Air
		STZ $9E,x

		LDA !Super : BEQ ..Air
		INC A
		CMP #$06 : BEQ ..F
		STA !Super
		BRA ..Air

	..F	LDA #$01 : STA !Super
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar


		..Air

		JSL !SpriteApplySpeed
		RTS



	.Phase3
		LDX !SpriteIndex
		JSR Reinforcements



		LDA $3330,x
		AND #$03 : BEQ ..NoWall
		STZ $AE,x
		LDA $3330,x
		AND #$04 : BEQ ..NoWall
		LDA $3320,x
		EOR #$01
		STA $3320,x
		..NoWall



		LDA $3330,x
		AND #$04 : BEQ ..Air
		STZ $9E,x
		LDA !SpriteAnimIndex				;\
		CMP #$0B : BCS +				; |
		LDA #$0B : STA !SpriteAnimIndex			; | play walk animation
		STZ !SpriteAnimTimer				; |
		LDA #$08 : STA !LoadedTile			; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
		+						;/


		LDY $3320,x					;\ run speed
		LDA Data_XSpeed+0,y : STA $AE,x			;/
		LDA !ExtraTimer : BNE ..Speed			;\
		JSL SUB_HORZ_POS				; |
		TYA : STA $3320,x				; |
		LDA #$A0 : STA $9E,x				; |
		LDA $3220,x					; | start jump
		EOR #$FF					; |
		LSR A						; |
		SEC : SBC #$40					; |
		STA $AE,x					; |
		LDA #$01 : STA !Super				;/
		LDA #$25 : STA !SPC1				; > roar SFX


		..Air
		LDA #$0A : STA !SpriteAnimIndex

		LDA !FireTimer : BEQ ..NoZote
		CMP #$01 : BNE +
		STZ $AE,x
		LDA #$30 : STA $9E,x
		BRA ..NoZote

	+	AND #$07 : BNE +
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		STZ $03
		LDY #$01
		LDA #$00
		JSL SpawnExSprite_NoSpeed

	+	LDY $3320,x
		LDA Data_XSpeed+4,y : STA $AE,x
		STZ $9E,x
		BRA ..Speed

		..NoZote
		LDY $3320,x
		LDA $9E,x : BMI ..Speed
		LDA !Super : BEQ ..Speed
		JSL SUB_HORZ_POS
		TYA
		CMP $3320,x : BEQ ..Speed
		STA $3320,x
		STZ !Super
		LDA #$11 : STA !FireTimer



		..Speed
		LDA $3330,x
		AND #$04 : PHA
		JSL !SpriteApplySpeed
		PLA : BNE ..R
		EOR $3330,x
		AND #$04 : BEQ ..R

		LDA !RNG
		LSR #2
		ORA #$40
		STA !ExtraTimer

		LDA !RNG
		AND #$01
		STA $3320,x

		LDA $3220,x
		SEC : SBC #$14
		STA $00
		LDA $3250,x
		SBC #$00
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar
		LDA $3220,x
		CLC : ADC #$14
		STA $00
		LDA $3250,x
		ADC #$00
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar

	..R	RTS





	.Phase4
		LDX !SpriteIndex
		JSR Reinforcements
		JMP .Phase1



	.Phase5
		LDX !SpriteIndex
		JSR Reinforcements

		LDY #$0F
	-	LDA $3230,y
		CMP #$08 : BNE +
		LDA !ExtraBits,y
		AND #$08 : BEQ +
		LDA !NewSpriteNum,y
		CMP #$1E : BNE +
		LDA $3210,y
		CMP #$50 : BEQ +
		INC A
		STA $3210,y : BNE +
		LDA $3240,y
		INC A
		STA $3240,y
	+	DEY : BPL -




		LDA !EatStatus : BPL ..NoEat
		CMP #$C0 : BCC ..Sprite


	..Sprite
		AND #$0F					;
		PHA						; push this for Y later

		LDA #$14 : STA $00				;\
		LDA !SpriteAnimIndex				; |
		ASL #2						; |
		TAY						; | account for animation update
		LDA !SpriteAnimTimer				; |
		INC A						; |
		CMP Anim+2,y					; |
		BNE $02 : DEC $00				;/
		LDA !SpriteAnimIndex				;\
		SEC : SBC $00					; | check animation
		BPL $04 : PLA : JMP ..NoSpeed			;/
		CMP #$02 : BCC +				;\
		PLY						; |
		LDA #$00 : STA $3230,y				; |
		CPY !SpriteIndex : BCC ..lower			; | erase target sprite
		LDA $33B0,y					; | (and account for animation order)
		TAY						; |
		LDA #$F0 : STA !OAM+$101,y			; |
	..lower	STZ !EatStatus					; |
		BRA ..NoEat					;/
	+	ASL A						;\ index for offset table
		TAY						;/
		REP #$20					; A 16-bit
		LDA $3320,x					;\
		AND #$0001					; |
		DEC A						; |
		STA $00						; | flip X offset depending on facing
		LDA Data_EatOffsetX,y				; |
		EOR $00						; |
		STA $00						;/
		LDA Data_EatOffsetY,y : STA $02			; Y offset
		SEP #$20					; A 8-bit
		PLY						; get index
		LDA #$02 : STA $34E0,y				; stun grabbed sprite
		JSL SPRITE_A_SPRITE_B_ADD			; move grabbed sprite
		JMP ..NoSpeed
		..NoEat



		LDA !Super : BNE ..NoRoll			;\
		LDA !ExtraTimer : BNE ..NoRoll			; |
		LDA !RNG					; |
		AND #$0F					; |
		TAY						; |
		LDA ..AttackTable,y				; | roll phase 5 attack
		STA !Super					; |
		LDA !RNG					; |
		AND #$30					; |
		ORA #$40					; |
		STA !ExtraTimer					; |
		..NoRoll					;/

		LDA $14
		AND #$03 : BEQ ..Wall
		JMP ..WallDone

		..Wall
		LDA !WallBreak
		CMP #$08 : BEQ ..WallDone
		CMP #$00 : BNE ..Brk1
	..Brk4	LDA $3220,x
		CMP #$D8 : BCC ..WallDone
		LDA #$01 : STA $99
		LDA #$70 : JSR BreakWall
		LDA #$60 : JSR BreakWall
		LDA #$50 : JSR BreakWall
		LDA #$40 : JSR BreakWall
		INC !WallBreak

		JSL !GetSpriteSlot : BMI ..WallDone
		LDA #$1E : STA !NewSpriteNum,y
		LDA #$36 : STA $3200,y
		LDA $3250,x : STA $3250,y
		LDA #$F8 : STA $3220,y
		LDA #$B0 : STA $3210,y
		LDA #$00 : STA $3240,y
		TYX
		JSL $07F7D2
		JSL $0187A7
		LDA #$08
		STA !ExtraBits,x
		STA $3230,x
		LDA #$02 : STA !SpriteAnimIndex
		LDA #$08 : STA $3450,x				; tweaker 2 (sprite clipping)
		LDX !SpriteIndex
		LDA #$01 : STA !EnableHScroll
		BRA ..WallDone

	..Brk1	TAY
		LDA ..WallDataHi-1,y : STA $99
		LDA ..WallData-1,y : JSR BreakWall
		INC !WallBreak
		..WallDone

		LDA $3330,x					;\
		AND #$03 : BEQ ..NoWall				; |
		DEC A						; | turn at walls
		AND #$01					; |
		EOR #$01					; |
		STA $3320,x					; |
		..NoWall					;/

		LDA !Super					;\
		ASL A						; |
		CMP.b #..AttackPtr_end-..AttackPtr		; | index for attack in phase 5
		BCC $02 : LDA #$00				; |
		TAX						;/
		JSR (..AttackPtr,x)				; go to pointer

		JSL !SpriteApplySpeed
		..NoSpeed

		LDA $3330,x					;\
		AND #$04 : BEQ ..Air				; | cap down speed on ground
		STZ $9E,x					; |
		..Air						;/

		RTS


		..AttackPtr
		dw ..Idle		; 0
		dw ..Volley		; 1
		dw ..Dash		; 2
		dw ..Zote		; 3
		dw ..Wave		; 4
		dw ..Roar		; 5
		...end


		..AttackTable
		db $01,$01,$01,$01	; volley, 25%
		db $02,$02,$03,$03	; dash, 12.5%
		db $03,$04,$04,$04	; zote, 18.75%, wave 18.75%
		db $05,$05,$05,$05	; roar, 25%


		..WallData					; index this -1
		db $30,$20,$10,$00,$F0,$E0,$D0

		..WallDataHi
		db $01,$01,$01,$01,$00,$00,$00



		..Idle
		LDX !SpriteIndex
		LDY $3320,x					;\ walk speed
		LDA Data_XSpeed+0,y : STA $AE,x			;/
		LDA !SpriteAnimIndex				;\
		CMP #$0B : BCS +				; |
		LDA #$0B : STA !SpriteAnimIndex			; | play walk animation
		STZ !SpriteAnimTimer				; |
		LDA #$08 : STA !LoadedTile			; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
	+	RTS						;/



		..Volley
		LDX !SpriteIndex
		LDA !Super : BMI ...main
		ORA #$80 : STA !Super
		LDA #$0A : STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer				; | jump animation
		STZ !SubTile					;/
		LDA $3330,x
		AND #$04 : BEQ ...main
		LDA #$C0 : STA $9E,x
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		RTS

	...main
		LDA $14
		AND #$07 : BNE +
		JSR Fireball
		LDA $3210,y
		SEC : SBC #$20
		STA $3210,y
		LDA $9E,x
		SEC : SBC #$04
		STA $9E,x
	+	LDA $3330,x
		AND #$04 : BEQ ...r
		STZ !Super
	...r	RTS



		..Dash
		LDX !SpriteIndex
		LDA !SpriteAnimIndex				;\
		CMP #$02 : BCC +				; |
		CMP #$0A : BCC ++				; | play run animation
	+	LDA #$02 : STA !SpriteAnimIndex			; |
		STZ !SpriteAnimTimer				; |
		LDA !SubTile					; |
		AND #$80					; |
		STA !SubTile					; |
		++						;/

		INC !ExtraTimer
		LDA $3330,x
		AND #$03 : BEQ +
		STZ !Super

	+	LDY $3320,x
		LDA Data_XSpeed+6,y : STA $AE,x
		LDA $14
		AND #$07 : BNE +
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar
		LDA #$30 : STA $32D0,y			; life timer
		LDA #$30 : STA $3290,y			; max height
	+	RTS



		..Zote
		LDX !SpriteIndex
		LDA !Super : BMI ...main
		ORA #$80 : STA !Super
		LDA #$0A : STA !SpriteAnimIndex
		LDA $3330,x
		AND #$04 : BEQ ...main
		LDA #$C0 : STA $9E,x
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA Data_XSpeed+6,y : STA $AE,x
		RTS

	...main
		LDA $3330,x
		AND #$04 : BEQ +
		LDA #$04 : STA !Super
	+	RTS



		..Wave
		LDX !SpriteIndex
		LDA !Super : BMI ...main
		ORA #$80 : STA !Super
		LDA #$18 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$FF : STA !LoadedTile
		LDA !SubTile
		AND #$80
		EOR #$80
		STA !SubTile
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA $3220,x
		CLC : ADC ...offset+0,y
		STA $00
		LDA $3250,x
		ADC ...offset+2,y
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar
		LDA #$30 : STA $32D0,y			; life timer
		LDA #$30 : STA $3290,y			; max height
		RTS

	...main
		STZ $AE,x
		LDA !ShakeTimer
		ORA #$04
		STA !ShakeTimer


		STZ $0F
		LDY #$0F
	-	LDA $3230,y
		CMP #$08 : BNE +
		LDA !ExtraBits,y
		AND #$08 : BEQ +
		LDA !NewSpriteNum,y
		CMP #$29 : BNE +
		LDA $3280,y
		CMP #$08 : BCS +
		CMP #$06 : BCC +
		LDA $32B0,y : BMI +
		LDA $3250,y : STA $01
		LDA $3220,y : STA $00
		INC $0F
	+	DEY : BPL -

		LDA $0F : BEQ +
		LDY $3320,x
		LDA $00
		CLC : ADC ...offset+0,y
		STA $00
		LDA $01
		ADC ...offset+2,y
		CMP #$02 : BCC ++
		STZ !Super
		STZ !SpriteAnimIndex
	++	STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		JSR SpawnFlamePillar
		LDA #$30 : STA $32D0,y			; life timer
		LDA #$30 : STA $3290,y			; max height
	+	RTS


		...offset
		db $10,$F0
		db $00,$FF




		..Roar
		LDX !SpriteIndex
		LDA !Super : BMI ...main
		ORA #$80 : STA !Super
		LDA #$01 : STA !SpriteAnimIndex			;\ roar animation
		STZ !SpriteAnimTimer				;/
		STZ !SubTile					; reset animation to load next frame
		LDA #$25 : STA !SPC1				; > roar SFX
		STZ $AE,x

	...main
		LDA !ExtraTimer : BNE +
		STZ !Super
		RTS

	+	AND #$07 : BNE +
		JSR Fireball
		LDA $309E,y
		EOR #$FF
		STA $309E,y
		LDA $3210,y
		SEC : SBC #$20
		STA $3210,y
	+	RTS






	Interaction:
		LDA !StunTimer : BEQ .Process
		JMP Graphics

		.Process
		LDA !Phase					;\
		ASL A						; |
		TAY						; | set up hitbox pointer and index
		LDA Hitbox+0,y : STA $0E			; |
		LDA Hitbox+1,y : STA $0F			; |
		LDY #$00					;/
		LDA ($0E),y					;\
		INY						; |
		CLC : ADC $3220,x				; |
		STA $04						; | hitbox X pos
		LDA ($0E),y					; |
		ADC $3250,x					; |
		STA $0A						; |
		INY						;/
		LDA ($0E),y					;\
		INY						; |
		CLC : ADC $3210,x				; |
		STA $05						; | hitbox Y pos
		LDA ($0E),y					; |
		ADC $3240,x					; |
		STA $0B						;/
		INY						;\
		LDA ($0E),y : STA $06				; | hitbox dimensions
		INY						; |
		LDA ($0E),y : STA $07				;/



		LDA !Phase					;\
		CMP #$04 : BNE .NoEat				; |
		LDA !SpriteAnimIndex				; | look for eating disqualifiers
		CMP #$13 : BCS .NoEat				; | (Big Max side)
		BIT !EatStatus : BMI .NoEat			;/
		LDX #$0F					; > set up loop
	-	CPX !SpriteIndex : BEQ +			;\
		LDA $3230,x					; | look for living sprites (but not Big Max)
		CMP #$08 : BNE +				;/
		LDA !ExtraBits,x				;\ can only eat vanilla sprites
		AND #$08 : BNE +				;/
		JSL !GetSpriteClipping00			;\
		JSL !CheckContact				; | check for contact
		BCC +						;/
		TXA						;\
		ORA #$80					; | mark eat target and end loop
		STA !EatStatus					;/
		LDX !SpriteIndex				; restore sprite index
		LDA #$13 : STA !SpriteAnimIndex			;\
		LDA #$FF : STA !SpriteAnimTimer			; |
		LDA !SubTile					; | grab animation
		AND #$80					; |
		STA !SubTile					; |
		LDA #$FF : STA !LoadedTile			;/
		BRA .NoEat					; end loop

	+	DEX : BPL -					; > loop
		LDX !SpriteIndex				;\ restore sprite index
		.NoEat						;/


		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00 : JSR Interact
		PLA
	.P2	LSR A : BCC .NoContact
		LDY #$80 : JSR Interact
		.NoContact



	Graphics:
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP Anim+2,y : BNE .Same

	.New	LDA Anim+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA Anim+3,y
		ASL #2
		TAY

		LDA Anim+1,y : BEQ .Frame

		LDA !Phase
		CMP #$03 : BCC +
		LDA #$04 : BRA .Store
	+	LDA #$4C : BRA .Store			; always render first frame of charge/walk during roar/jump
							; which one depends on phase

	.Frame	LDA Anim+0,y
	.Store	STA !LoadedTile
		LDA !SubTile
		AND #$80
		EOR #$80
		STA !SubTile
		LDA #$00

	.Same	STA !SpriteAnimTimer

		LDA !SubTile
		AND #$7F : BNE .Cont

		REP #$20
		LDA !LoadedTile
		AND #$00FF
		CMP #$00FF
		BNE $03 : LDA #$0100
		ASL #5
		CLC : ADC #$2000
		STA $00
		SEP #$20
		CLC						; clear buffer
		BRA .Render

	.Cont	CMP #$10 : BNE $03 : JMP .DontRender
		REP #$20
		AND #$00FF
		XBA
		LSR A
		CLC : ADC #$2000
		STA $00
		LDA !LoadedTile
		AND #$00FF
		CMP #$00FF
		BNE $03 : LDA #$0100
		ASL #5
		CLC : ADC $00
		STA $00
		SEP #$20
		SEC						; dont clear buffer

	.Render	LDA #$40 : STA $02				;\ > source bank
		LDA #$20					; |
		STA $03						; |
		STA $04						; | render input data
		LDA !Size					; | (carry must not be changed here)
		STA $05						; |
		STA $06						; |
		LDA #$20 : STA $07				; |
		LDA #$40 : STA $08				;/
		LDA #$03					; 8-stage
		JSL !TransformGFX				; render
		LDX !SpriteIndex				; restore sprite index
		LDA !SubTile : STA $0E				;\
		JSL !GetVRAM					; |
		LDA.b #!GFX_buffer>>16				; |
		STA.l !VRAMbase+!VRAMtable+$04,x		; |
		REP #$20					; |
		LDA $0E						; |
		AND #$007F					; |
		XBA						; |
		LSR A						; |
		STA $0C						; | upload 1 row every frame
		CLC : ADC.w #!GFX_buffer			; |
		STA.l !VRAMbase+!VRAMtable+$02,x		; |
		LDA $0E						; |
		AND #$0080					; |
		ORA #$7000					; |
		CLC : ADC $0C					; |
		STA.l !VRAMbase+!VRAMtable+$05,x		; |
		LDA #$0100					; |
		STA.l !VRAMbase+!VRAMtable+$00,x		;/

		SEP #$20
		LDX !SpriteIndex

		LDA $0E						;\
		CLC : ADC #$02					; | increment sub tile
		STA !SubTile					;/


	.DontRender
		LDA !StunTimer
		AND #$02 : BNE .DontDraw
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA Anim+1,y : BNE .TileOffset
		LDA !SubTile
		AND #$80
		EOR #$80
		LSR #4

	.TileOffset
		STA $03
		STZ $02
		STZ $06
		REP #$20

		LDA !Phase
		AND #$00FF : BEQ .Phase1
		CMP #$0001 : BNE +
	.Phase2	LDA !SpriteAnimIndex				;\
		AND #$00FF					; | not during roar on phase 2
		DEC A : BEQ +					;/
		LDA #$0300 : BRA +
	.Phase1	LDA #$0100
	+	STA $00
		LDA.w #Anim_TM : JSL LakituLovers_TilemapToRAM_Long

		LDA !Phase
		AND #$00FF : BNE +
		LDA !Super
		AND #$00FF : BEQ +
		LDA !FireTimer
		AND #$0008
		ASL #3
		STA $02
		STZ $00
		LDA.w #Anim_AuraTM : JSL LakituLovers_TilemapToRAM_Long
		+


		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL LOAD_TILEMAP


	.DontDraw
		PLB
		RTL




	Anim:
	.Idle
	db $04,$00,$FF,$00		; 00
	.Roar
	db $48,$80,$40,$00		; 01
	.Charge
	db $4C,$00,$08,$03		; 02
	db $80,$00,$08,$04		; 03
	db $84,$00,$08,$05		; 04
	db $80,$00,$08,$06		; 05
	db $4C,$00,$08,$07		; 06
	db $88,$00,$08,$08		; 07
	db $8C,$00,$08,$09		; 08
	db $88,$00,$08,$02		; 09
	.Jump
	db $C0,$88,$FF,$0A		; 0A
	.Walk
	db $04,$00,$08,$0C		; 0B
	db $08,$00,$08,$0D		; 0C
	db $0C,$00,$08,$0E		; 0D
	db $08,$00,$08,$0F		; 0E
	db $04,$00,$08,$10		; 0F
	db $40,$00,$08,$11		; 10
	db $44,$00,$08,$12		; 11
	db $40,$00,$08,$0B		; 12
	.Grab
	db $04,$00,$08,$14		; 13
	db $FF,$00,$10,$15		; 14 (tile 0xFF means 0x100)
	db $48,$80,$28,$16		; 15
	db $00,$00,$10,$17		; 16
	db $04,$00,$10,$0B		; 17
	.Wave
	db $FF,$00,$08,$18		; 18



	.TM
	dw $0040
	db $39,$E8,$D0,$00
	db $39,$F8,$D0,$02
	db $39,$08,$D0,$04
	db $39,$18,$D0,$06
	db $39,$E8,$E0,$20
	db $39,$F8,$E0,$22
	db $39,$08,$E0,$24
	db $39,$18,$E0,$26
	db $39,$E8,$F0,$40
	db $39,$F8,$F0,$42
	db $39,$08,$F0,$44
	db $39,$18,$F0,$46
	db $39,$E8,$00,$60
	db $39,$F8,$00,$62
	db $39,$08,$00,$64
	db $39,$18,$00,$66

	.AuraTM
	dw $0010
	db $34,$F8,$F8,$A4
	db $34,$08,$F8,$A6
	db $B4,$F8,$08,$A4
	db $B4,$08,$08,$A6




	.InitData
	dw $9008+$900			; roar
	dw $7800
	dw $9008+$1800			; jump
	dw $7880



	Hitbox:
	dw .16
	dw .24
	dw .32
	dw .48
	dw .64

	.16
	dw $0002,$0002
	db $0C,$0C

	.24
	dw -$0002,-$0006
	db $14,$14

	.32
	dw -$0006,-$000E
	db $1C,$1C

	.48
	dw -$000E,-$0016
	db $2C,$2C

	.64
	dw -$0016,-$001E
	db $3C,$3C


	Interact:

		LDA !Phase : BNE .NotPhase1
		LDA !Super : BNE .HurtPlayer
		.NotPhase1


		LDA !P2Blocked-$80,y
		AND #$04 : BNE .HurtPlayer



		LDA !P2YSpeed-$80,y : BPL .PDown

	.PUp	BIT $9E,x : BPL .HurtPlayer
		BRA +

	.PDown	BIT $9E,x : BMI .HurtSprite
	+	CMP $9E,x : BCC .HurtPlayer


		.HurtSprite
		JSL P2Bounce
		LDA #$10
		STA !StunTimer
		JSL DontInteract

		LDA !Phase
		CMP #$03 : BNE .NoGrow
		LDA !Size
		CLC : ADC #$03
		STA !Size
		STZ !LoadStatus					; re-render extra frames
		.NoGrow


		DEC !HP : BPL .Return
		LDA !Phase
		INC A
		CMP #$05 : BNE +
		LDA #$02 : STA $3230,x
		STZ $AE,x
		STZ $9E,x
		JMP Death

	+	STA !Phase
		TAY
		LDA Data_Size,y : STA !Size
		LDA Data_HP,y : STA !HP
		STZ !LoadStatus					; re-render extra frames
		STZ !FireTimer					;\ clear attacks
		STZ !Super					;/
		CPY #$02 : BNE .Return
		JSR BreakBlocks
	.Return	RTS


		.HurtPlayer
		TYA
		CLC
		ROL A
		INC A
		JSL !HurtPlayers
		RTS


	BreakBlocks:
		PHB : LDA #$02
		PHA : PLB
		LDA #$01 : PHA
		LDA $3250,x : STA $9B
		LDA #$30 : STA $9A

	.Loop	LDA #$C0 : STA $98
		STZ $99
		LDA #$02 : STA $9C
		JSL $00BEB0
		LDA #$00 : JSL $028663
		LDA $9A
		CLC : ADC #$10
		STA $9A
		LDA #$02 : STA $9C
		JSL $00BEB0
		LDA #$00 : JSL $028663

		PLA
		CMP #$00 : BEQ .End
		DEC A
		PHA
		LDA $9A
		CLC : ADC #$70
		STA $9A
		BRA .Loop

	.End	PLB
		LDX !SpriteIndex
		RTS


	BreakWall:
		STA $98
		LDA #$F0 : STA $9A
		STZ $9B
		LDA #$02 : STA $9C
		JSL $00BEB0
	;	LDA #$03 : JSL QUICK_CAST_Long
		LDA #$84 : STA $33D0,y				; > graphic tile
		LDA #$01 : STA $3410,y				; > hard prop
		LDA #$1C : STA $33C0,y				; > YXPPCCCT
		LDA #$00 : STA $30BE,y
		LDA #$10 : STA $30AE,y
		LDA !RNG
		LSR #4
		EOR #$FF
		STA $309E,y
		LDA #$00 : STA $35D0,y
		LDA #$01 : STA $3320,y				; face correctly

		LDA $9A : STA $3220,y
		LDA $9B : STA $3250,y
		LDA $98 : STA $3210,y
		LDA $99 : STA $3240,y



	.Return	RTS



	Fireball:
	;	LDA #$03 : JSL QUICK_CAST_Long
		LDA #$E0 : STA $33D0,y				; > graphic tile
		LDA #$01 : STA $35D0,y				; > spin type
		LDA #$01 : STA $3410,y				; > hard prop
		LDA #$36 : STA $33C0,y				; > YXPPCCCT
		RTS



	SpawnFlamePillar:
		JSL !GetSpriteSlot
		BPL .Spawn
		RTS

		.Spawn
		LDA $00 : STA $3220,y
		LDA $01 : STA $3250,y
		LDA $02 : STA $3210,y
		LDA $03 : STA $3240,y
		TYX
		LDA #$29 : STA !NewSpriteNum,x
		LDA #$36 : STA $3200,x
		LDA #$08 : STA $3230,x
		JSL $07F7D2
		JSL $0187A7
		LDA #$08 : STA !ExtraBits,x
		LDA #$08 : STA $32A0,x			; initial wait
		LDA #$20 : STA $32D0,x			; life timer
		LDA #$03 : STA $32B0,x			; speed
		LDA #$18 : STA $3290,x			; max height
		LDA #$08 : STA $35D0,x			; peak wait
		STZ $35E0,x				; bottom wait
		TXY
		LDX !SpriteIndex
		RTS


	Reinforcements:
		LDA $14 : BNE .NoSpawn
		JSL !GetSpriteSlot
		BMI .NoSpawn

		LDA #$38
		BIT !P2XPosLo-$80
		BMI $03 : CLC : ADC #$80
		STA $3220,y
		LDA $3250,y : STA $3250,y
		LDA #$B0 : STA $3210,y
		LDA #$00 : STA $3240,y
		LDA !RNG
		AND #$03
		STA $3200,y
		LDA #$08 : STA $3230,y
		TYX
		STZ !ExtraBits,x
		JSL $07F7D2
		LDX !SpriteIndex
		.NoSpawn
		RTS


	Death:
		LDA $3220,x
		SEC : SBC #$18
		STA $00
		LDA $3250,x
		SBC #$00
		STA $01
		LDA $3210,x
		SEC : SBC #$30
		STA $02
		LDA $3240,x
		SBC #$00
		STA $03

		LDA !SubTile
		AND #$80
		LSR #5
		STA $04


		LDY #$03

	-	LDA #$09
		STA !Ex_Num+0,y
		STA !Ex_Num+4,y
		LDA #$40
		STA !Ex_Data2+0,y
		STA !Ex_Data2+4,y
		LDA #$29
		STA !Ex_Data3+0,y
		STA !Ex_Data3+4,y
		LDA $00 : STA !Ex_XLo+0,y : STA !Ex_XLo+4,y
		LDA $01 : STA !Ex_XHi+0,y : STA !Ex_XHi+4,y
		LDA $02 : STA !Ex_YLo+0,y
		CLC : ADC #$10
		STA !Ex_YLo+4,y
		LDA $03 : STA !Ex_YHi+0,y
		ADC #$00
		STA !Ex_YHi+4,y
		LDA $04 : STA !Ex_Data1+0,y
		CLC : ADC #$10
		STA !Ex_Data1+4,y
		INC $04
		LDA .XSpeed,y
		STA !Ex_XSpeed+0,y
		STA !Ex_XSpeed+4,y

		LDA #$E0 : STA !Ex_YSpeed+0,y
		LDA #$E8 : STA !Ex_YSpeed+4,y



		LDA $00
		CLC : ADC #$10
		STA $00
		LDA $01
		ADC #$00
		STA $01
		DEY : BPL -

		RTS

		.XSpeed
		db $10,$18,$F8,$F0




	namespace off





