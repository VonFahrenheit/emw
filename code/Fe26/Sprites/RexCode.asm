;
; Rex tables:
; $BE	- How many hits the Rex has taken
; $3280 - Rex AI bits
; $3290 - Xpos of wall being climbed
; $32B0 - Dynamic tile or turn around at ledge flag
; $32D0 - Throw hammer timer
; $32F0 - Death timer
; $3310	- Animation timer
; $3340 - Movement flags
; $33D0	- Animation index
; $33E0 - Chase timer
; $35D0 - i frames

; Shaman differences:
; $3290 - Equipped mask
; $32D0 - Cast timer

; Adept:
; $3290 - Desired X coordinate (lo)
; $32A0 - Desired X coordinate (hi)
; $32B0 - Desired Y coordinate (lo)
; $35A0 - Desired Y coordinate (hi)	(extra prop 1)
; $32D0 - Fly timer
; $3340 - Loaded frame
; $35D0 - Intended attack option
; $35E0 - Dash dance (each nybble equals index+1, if this is clear then no dash dance)
; $BE has a different format:
;	hhhhHHHH
;	hhhh are hit flags:
;	0x80 bit toggles hit (0 = no hit, 1 = hit)
;	0x40 bit toggles player (0 = P1, 1 = P2)
;	0x20 and 0x10 bits determine hit type
;	00 = basic attack
;	01 = stomp
;	10 = projectile (currently unused)
;	11 = mystic spell (currently unused)
;	HHHH is HP



; Rex AI bits:
;		CcTSMBHJ
;		C is climb enable
;		c is chase enable
;		T is turn enable (turns at ledges rather than walking off)
;		S is shaman flag.
;		M is move disable
;		B is brute enable
;		H is hammer enable
;		J is jump enable (jumps at ledges rather than walking off)

; Movement flags:
;		CccmKuAJ
;		C is climb flag.
;		cc are chase flags. Hi bit toggles chase, lo bit toggles which player to chase (0 = P1, 1 = P2)
;		m is carrying mushroom flag. If shaman flag is set in AI, this bit toggles mask instead.
;		K is knockback flag. While set, Xspeed will not update. Cleared upon touching the ground or a wall.
;		u is getup flag.
;		A is ambush flag.
;		J is jump flag.

; GFX addresses:
;	Rex		- $308008
;	Villager Rex	- $308C08
;	Hammer Rex	- $309808
;	Aggro Rex	- $349008
;	Novice Shaman	- $30C408
;	Goomba Slave	- $30D408
;	Happy Slime	- $30DA08
;
;	Kingking	- $318000
;
;	Adept Shaman	- $32B808


	!RexAI			= $3280,x
	!RexAIY			= $3280,y
	!RexWallX		= $3290,x
	!RexHammer		= $32A0,x
	!RexMovementFlags	= $3340,x
	!RexChase		= $33E0,x

	!AggroRexIFrames	= $35D0,x


	!AggroRexIdle		= $00
	!AggroRexWalk		= $03
	!AggroRexRoar		= $07
	!AggroRexCharge		= $09
	!AggroRexJump		= $11
	!AggroRexClimb		= $12

	!ShamanMask		= $3290,x
	!ShamanCast		= $32D0,x

	!AdeptFlyTimer		= $32D0,x
	!AdeptSequence		= $35E0,x


;===========;
;REX MODULES;
;===========;

AggroRex:
.INIT		PHB : PHK : PLB
		LDA #!AggroRexWalk		;\ Walk animation
		STA !SpriteAnimIndex		;/
		LDA !ExtraBits,x
		AND #$04 : BEQ +		;\
		LDA #$FE : STA !SpriteAnimTimer	; > reset animation
		LDA !RexMovementFlags		; | Enable ambush if extra bit is set
		ORA #$02			; |
		STA !RexMovementFlags		;/
		LDA $3220,x			;\
		CLC : ADC #$08			; |
		STA $3220,x			; | Start half a tile to the right
		LDA $3250,x			; |
		ADC #$00			; |
		STA $3250,x			;/
		STZ !SpriteAnimIndex		;\ Start at idle animation
		INC !AggroRexTile		;/

	+	LDA #$E4
		STA !RexAI
		LDA #$04
		STA $3330,x
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA $3440,x
		AND.b #$0F^$FF
		STA $3440,x


		LDA #$03 : JSL !GetDynamicTile
		BCS +
		STZ $3230,x
		PLB
		RTL

	+	TYA
		ORA #$40
		STA !ClaimedGFX
		TXA
		STA !DynamicTile+0,y
		STA !DynamicTile+1,y
		STA !DynamicTile+2,y
		STA !DynamicTile+3,y
		PLB


.MAIN		PHB : PHK : PLB
		JSR REX_BEHAVIOUR

		LDA $32F0,x : BEQ +
		LDA $3230,x
		CMP #$02 : BEQ .Hurt
		LDA #$02 : STA $3230,x
		LDA #$F0 : STA $9E,x
		+

		LDA $34D0,x : BEQ +		; hurt frame
	.Hurt	LDA #$15 : STA !SpriteAnimIndex
		JMP ++
		+

		LDA !RexMovementFlags
		AND #$02
		BEQ +
		LDA !SpriteAnimIndex
		CMP #!AggroRexIdle+3
		BCS $03 : JMP ++
		LDA #!AggroRexIdle
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	-	JMP ++
	+	LDA !RexChase
		BEQ +
		LDA #!AggroRexRoar+1
		CMP !SpriteAnimIndex : BEQ -
		DEC A
		CMP !SpriteAnimIndex
		BNE $03 : JMP ++
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JMP ++
	+	BIT !RexMovementFlags
		BPL +
		LDA !SpriteAnimIndex
		CMP #!AggroRexClimb : BCS ++
		LDA #!AggroRexClimb : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	+	LDA $3330,x
		AND #$04
		BNE +
		LDA $9E,x
		BPL .Jump
		LDA !RexMovementFlags
		AND #$04
		BEQ .Jump
		LDA #!AggroRexClimb+1 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	.Jump	;LDA !Difficulty
		;AND #$03
		;CMP #$02 : BNE .NormalJump
		;LDA #$0D : STA !SpriteAnimIndex
		;STZ !SpriteAnimTimer
		;BRA ++

		.NormalJump
		LDA #!AggroRexJump : STA !SpriteAnimIndex
		BRA ++
	+	BIT !RexMovementFlags
		BVC +
		LDA !SpriteAnimIndex
		CMP #!AggroRexCharge : BEQ ++
		BCC $04 : CMP #!AggroRexCharge+$08 : BCC ++
		LDA #!AggroRexCharge : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	+	LDA !SpriteAnimIndex
		CMP #!AggroRexWalk
		BEQ ++
		BCC +
		CMP #!AggroRexWalk+$08 : BCC ++
	+	LDA #!AggroRexWalk : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	++	LDA !SpriteAnimIndex
		STA $00
		ASL A
		CLC : ADC $00
		ASL A
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w .ANIM_IDLE+4,y : BNE +
		LDA.w .ANIM_IDLE+5,y : STA !SpriteAnimIndex
		STA $00
		ASL A
		CLC : ADC $00
		ASL A
		TAY
		LDA #$00
	+	STA !SpriteAnimTimer

		LDA !SpriteAnimIndex
		CMP #!AggroRexClimb : BNE .NoHold
		PHA
		LDA #$02 : STA !SpriteStasis,x
		PLA
		.NoHold
		CMP !AggroRexTile
		STA !AggroRexTile
		BEQ .SameFrame
		REP #$20
		LDA.w .ANIM_IDLE+2,y : STA $0C
		SEP #$20
		PHY
		LDY.b #!File_AggroRex
		JSL !UpdateFromFile
		PLY
		.SameFrame

		REP #$20
		LDA.w .ANIM_IDLE+0,y : STA $04
		SEP #$20

		LDA $34D0,x : BNE .Draw		; no flash during hit stun
		LDA !AggroRexIFrames
		AND #$02 : BNE .Return
	.Draw
		JSR LOAD_CLAIMED

	.Return
		PLB
		RTL



	.TM32X
	dw $0010
	db $30,$00,$F0,$00
	db $30,$10,$F0,$02
	db $30,$00,$00,$04
	db $30,$10,$00,$06

	.TM32X2			; roar
	dw $0010
	db $30,$F0,$F0,$00
	db $30,$00,$F0,$02
	db $30,$F0,$00,$04
	db $30,$00,$00,$06

	.TM32			; 14, 15
	dw $0010
	db $30,$F8,$F0,$00
	db $30,$08,$F0,$02
	db $30,$F8,$00,$04
	db $30,$08,$00,$06

	.TM32U1			; 4, 8, C, E, 10, 12
	dw $0010
	db $30,$F8,$EF,$00
	db $30,$08,$EF,$02
	db $30,$F8,$FF,$04
	db $30,$08,$FF,$06

	.TM32U2			; D, 11
	dw $0010
	db $30,$F8,$EE,$00
	db $30,$08,$EE,$02
	db $30,$F8,$FE,$04
	db $30,$08,$FE,$06

	.ANIM_IDLE
		dw .TM32,.IdleDyn00 : db $FF,$01	; 00
		dw .TM32,.IdleDyn01 : db $08,$02	; 01
		dw .TM32,.IdleDyn02 : db $C0,$00	; 02
	.ANIM_WALK
		dw .TM32,.WalkDyn00 : db $10,$04	; 03
		dw .TM32U1,.WalkDyn01 : db $10,$05	; 04
		dw .TM32,.WalkDyn00 : db $10,$06	; 05
		dw .TM32U1,.WalkDyn02 : db $10,$03	; 06
	.ANIM_ROAR
		dw .TM32,.RoarDyn00 : db $08,$08	; 07
		dw .TM32X2,.RoarDyn01 : db $FF,$08	; 08
	.ANIM_RUN
		dw .TM32,.RunDyn00 : db $05,$0A		; 09
		dw .TM32U1,.RunDyn01 : db $05,$0B	; 0A
		dw .TM32U2,.RunDyn02 : db $05,$0C	; 0B
		dw .TM32U1,.RunDyn01 : db $05,$0D	; 0C
		dw .TM32,.RunDyn00 : db $05,$0E		; 0D
		dw .TM32U1,.RunDyn03 : db $05,$0F	; 0E
		dw .TM32U2,.RunDyn04 : db $05,$10	; 0F
		dw .TM32U1,.RunDyn03 : db $05,$09	; 10
	.ANIM_JUMP
		dw .TM32,.RunDyn02 : db $FF,$11		; 11
	.ANIM_CLIMB
		dw .TM32X,.ClimbDyn00 : db $08,$13	; 12
		dw .TM32X,.ClimbDyn01 : db $08,$14	; 13
		dw .TM32X,.ClimbDyn02 : db $08,$12	; 14
	.ANIM_HURT
		dw .TM32,.HurtDyn : db $FF,$15		; 15




macro AggroDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20
	dw <DestVRAM>*$10+$6000
endmacro

	.WalkDyn00
	.IdleDyn00
		dw ..end-..start
		..start
		%AggroDyn(4, $004, $00)
		%AggroDyn(4, $014, $10)
		%AggroDyn(4, $024, $04)
		%AggroDyn(4, $034, $14)
		..end
	.IdleDyn01
		dw ..end-..start
		..start
		%AggroDyn(4, $000, $00)
		%AggroDyn(4, $010, $10)
		%AggroDyn(4, $020, $04)
		%AggroDyn(4, $030, $14)
		..end
	.IdleDyn02
		dw ..end-..start
		..start
		%AggroDyn(4, $0C4, $00)
		%AggroDyn(4, $0D4, $10)
		%AggroDyn(4, $0E4, $04)
		%AggroDyn(4, $0F4, $14)
		..end

	.WalkDyn01
		dw ..end-..start
		..start
		%AggroDyn(4, $008, $00)
		%AggroDyn(4, $018, $10)
		%AggroDyn(4, $028, $04)
		%AggroDyn(4, $038, $14)
		..end
	.WalkDyn02
		dw ..end-..start
		..start
		%AggroDyn(4, $00C, $00)
		%AggroDyn(4, $01C, $10)
		%AggroDyn(4, $02C, $04)
		%AggroDyn(4, $03C, $14)
		..end

	.RoarDyn01
		dw ..end-..start
		..start
		%AggroDyn(4, $040, $00)
		%AggroDyn(4, $050, $10)
		%AggroDyn(4, $060, $04)
		%AggroDyn(4, $070, $14)
		..end

	.RoarDyn00
	.RunDyn00
		dw ..end-..start
		..start
		%AggroDyn(4, $044, $00)
		%AggroDyn(4, $054, $10)
		%AggroDyn(4, $064, $04)
		%AggroDyn(4, $074, $14)
		..end
	.RunDyn01
		dw ..end-..start
		..start
		%AggroDyn(4, $048, $00)
		%AggroDyn(4, $058, $10)
		%AggroDyn(4, $068, $04)
		%AggroDyn(4, $078, $14)
		..end
	.RunDyn02
		dw ..end-..start
		..start
		%AggroDyn(4, $04C, $00)
		%AggroDyn(4, $05C, $10)
		%AggroDyn(4, $06C, $04)
		%AggroDyn(4, $07C, $14)
		..end
	.RunDyn03
		dw ..end-..start
		..start
		%AggroDyn(4, $080, $00)
		%AggroDyn(4, $090, $10)
		%AggroDyn(4, $0A0, $04)
		%AggroDyn(4, $0B0, $14)
		..end
	.RunDyn04
		dw ..end-..start
		..start
		%AggroDyn(4, $084, $00)
		%AggroDyn(4, $094, $10)
		%AggroDyn(4, $0A4, $04)
		%AggroDyn(4, $0B4, $14)
		..end

	.ClimbDyn00
		dw ..end-..start
		..start
		%AggroDyn(4, $088, $00)
		%AggroDyn(4, $098, $10)
		%AggroDyn(4, $0A8, $04)
		%AggroDyn(4, $0B8, $14)
		..end
	.ClimbDyn01
		dw ..end-..start
		..start
		%AggroDyn(4, $08C, $00)
		%AggroDyn(4, $09C, $10)
		%AggroDyn(4, $0AC, $04)
		%AggroDyn(4, $0BC, $14)
		..end
	.ClimbDyn02
		dw ..end-..start
		..start
		%AggroDyn(4, $0C0, $00)
		%AggroDyn(4, $0D0, $10)
		%AggroDyn(4, $0E0, $04)
		%AggroDyn(4, $0F0, $14)
		..end

	.HurtDyn
		dw ..end-..start
		..start
		%AggroDyn(4, $0C8, $00)
		%AggroDyn(4, $0D8, $10)
		%AggroDyn(4, $0E8, $04)
		%AggroDyn(4, $0F8, $14)
		..end


DropHat:
		LDA !ExtraProp2,x
		AND #$3F : BNE .Drop
		RTS

		.Drop
		PHA
		LDA !ExtraProp2,x
		AND #$C0
		STA !ExtraProp2,x
		PLA
		DEC A
		ASL A
		TAY
		LDA Rex_HatPtr,y : STA $04
		LDA Rex_HatPtr+1,y : STA $05
		LDY #$01
		LDA ($04),y : PHA		; push GFX status
		LDY #$05
		LDA ($04),y : PHA		; push tile
		DEY
		STZ $03
		LDA ($04),y : STA $02		; ydisp
		BPL $02 : DEC $03
		DEY
		STZ $01
		STZ $0F				;\
		LDA $3320,x			; |
		BNE $02 : DEC $0F		; |
		LDA ($04),y			; | xdisp
		EOR $0F				; |
		STA $00				; |
		BPL $02 : DEC $01		;/
		DEY
		LDA ($04),y : PHA		; push palette
		LDY $3320,x
		LDA .XSpeed,y : STA $04		; xspeed
		LDA #$F0 : STA $05		; yspeed
		LDA .Palset,y : PHA		; push YXPPCCCT
		LDA #$06
		LDY #$01
		JSR SpawnExSprite

		PLA : STA $0F			; pull and write YXPPCCCT
		PLA
		AND #$0E
		ORA $0F
		STA !Ex_Palset,y

		PLA : STA $0F			; pull tile number within file
		PLA				; pull
		PHX
		TAX
		LDA !GFX_status,x
		BPL +
		XBA
		LDA !Ex_Palset,y		; t bit
		INC A
		STA !Ex_Palset,y
		XBA
	+	AND #$70
		ASL A
		STA $0E
		LDA !GFX_status,x
		AND #$0F
		ORA $0E
		CLC : ADC $0F
		AND #$EF
		STA !Ex_Data1,y			; tile number
		LDA #$43 : STA !Ex_Data3,y	; set gravity = 3 + tile size = 16x16
		PLX
		RTS

	.XSpeed	db $10,$F0
	.Palset	db $70,$30


DropItem:
		LDA !ExtraProp1,x : BNE .Drop
	.Return	RTS

		.Drop
		STZ !ExtraProp1,x
		TAY
		LDA $33C0,x
		CMP #$04 : BEQ .Return
		LDA .Count-1,y : BEQ .Return
		STA $08
	.Again	STZ $00
		STZ $01
		CLC : LDA .Items-1,y
		JSR SpawnSprite
		CPY #$FF : BEQ .Return
		LDA #$08 : STA $3230,y
		LDA #$20			;\
		STA $32E0,y			; | prevent dropped item from interacting for a bit
		STA $35F0,y			;/
		LDA #$D0 : STA.w $9E,y
		PHX
		LDA $3320,x : TAX
		EOR $08
		AND #$01
		STA $3320,y
		TAX
		LDA .XSpeed,x : STA.w $AE,y
		PLX
		DEC $08
		LDY $08 : BNE .Again
		RTS


	.Items	db $21,$74,$00,$00,$00
	.Count	db $02,$01,$00,$00,$00

	.XSpeed	db $10,$F0

Rex:
.INIT		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04 : BEQ +		;\
		LDA #$08			; | no movement if extra bit is set
	+	ORA #$20			;/
		STA !RexAI
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA #$01 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		LDA !ExtraProp1,x		;\ check golden bandit mode
		CMP #$FF : BEQ .GoldenBandit	;/
		CMP #$05 : BNE +		;\
		LDA !ExtraProp2,x		; |
		AND #$3F			; | if rex is a knight (sword + helmet)
		CMP #$08 : BNE +		; | enable chase
		LDA !RexAI			; |
		ORA #$40			; |
		STA !RexAI			;/
	+	JMP .NotGolden


		.GoldenBandit
		LDA $33C0,x			;\
		AND #$0E			; | only spawn one yoshi coin
		CMP #$04 : BEQ .NotGolden	;/
		JSL !GetSpriteSlot		;\
		BMI .Fail			; |
		JSR SPRITE_A_SPRITE_B_COORDS	; |
		PHX				; |
		TYX				; |
		LDA #$22 : STA !NewSpriteNum,x	; |
		LDA #$36 : STA $3200,x		; |
		LDA #$08 : STA !ExtraBits,x	; |
		JSL !ResetSprite		; | spawn yoshi coin (hidden)
		JSL !ResetSpriteExtra		; |
		LDA #$01 : STA $3230,x		; |
		PLA				; |
		STA $3290,x			; |
		TAY				; |
		LDA !ExtraProp2,y		; |
		ORA #$80			; |
		STA !ExtraProp1,x		; |
		TYX				;/
		LDA $33C0,x			;\
		AND #$F1			; |
		ORA #$04			; |
		STA $33C0,x			; |
		LDA #$01 : STA !ExtraProp1,x	; | golden bandit config
		LDA !ExtraProp2,x		; |
		AND #$C0			; |
		ORA #$05			; |
		STA !ExtraProp2,x		; |
		BRA .NotGolden			;/
		LDA !SpriteTweaker4,x		;\
		ORA #$04			; | prevent from despawning off-screen
		STA !SpriteTweaker4,x		;/
		.Fail
		STZ $3230,x
		.NotGolden

		PLB
		RTL

.MAIN		PHB : PHK : PLB

		JSR REX_BEHAVIOUR

		LDA $33C0,x			; glitter code for golden bandit
		CMP #$04 : BNE .NoGlitter
		JSR MakeGlitter
		.NoGlitter

		LDA $3230,x
		CMP #$02 : BEQ .Drop
		CMP #$04 : BNE .NoFireDrop
	.Drop	JSR DropHat
		JSR DropItem
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA $9E,x : BPL .NoFireDrop
		LDA #$01
		STA $34D0,x
		STA $BE,x
		.NoFireDrop
		LDA $BE,x : BEQ ++
		DEC A
		BEQ +
		LDA #$0C : STA !SpriteAnimIndex
		BRA ++
	+	LDA $34D0,x : BEQ +
		JSR DropHat
		JSR DropItem
	.Hurt	LDA #$09
		STA !SpriteAnimIndex
		BRA ++
	+	LDA !SpriteAnimIndex
		CMP #$0A
		BEQ ++
		CMP #$0B
		BEQ ++
		STZ !SpriteAnimTimer
		LDA #$0A
		STA !SpriteAnimIndex
	++	LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .AnimIdle+0,y
		STA $04
		LDA.w .AnimIdle+1,y
		STA $05
		LDA !RexAI			;\
		AND #$08			; | No animation while standing still
		BNE ++				;/
		BIT !RexMovementFlags
		BVC .RegularSpeed

		.IncreasedSpeed
		LDA $14
		LSR A
		BCC .RegularSpeed
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimIdle+2,y
		BEQ .NewAnim
		INC A
		CMP.w .AnimIdle+2,y
		BEQ .NewAnim
		BRA +

		.RegularSpeed
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimIdle+2,y
		BNE +

		.NewAnim
		LDA.w .AnimIdle+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .AnimIdle+0,y
		STA $04
		LDA.w .AnimIdle+1,y
		STA $05
	++	LDA #$00
	+	STA !SpriteAnimTimer

		LDA $33C0,x : PHA
		STZ $06
		LDA !SpriteAnimIndex
		CMP #$09 : BCC .Items
		JSR AddTilemap
		STZ $33C0,x
		BRA .Write

	.Items	STZ $33C0,x
		LDA !ExtraProp2,x			;\
		AND #$0F : BEQ +			; |
		PEI ($04)				; |
		DEC A					; |
		ASL A					; |
		CMP.b #.HatPtr_End-.HatPtr		; |
		BCC $02 : LDA #$00			; | add hat tilemap
		TAY					; |
		LDA .HatPtr,y : STA $04			; |
		LDA .HatPtr+1,y : STA $05		; |
		JSR AddTilemap				; |
		PLA : STA $04				; |
		PLA : STA $05				;/
	+	PLA : STA $33C0,x : PHA			; restore palette but keep on stack
		JSR AddTilemap				; head tilemap
		REP #$20				;\
		LDA $04					; |
		CLC : ADC #$0004			; | legs tilemap
		STA $04					; |
		SEP #$20				; |
		JSR AddTilemap				;/
		STZ $33C0,x
		LDA !ExtraProp1,x : BEQ .Write		;\
		PEI ($04)				; |
		DEC A					; |
		ASL #3					; |
		CMP.b #.BagPtr_End-.BagPtr		; |
		BCC $02 : LDA #$00			; | add bag tilemap
		STA $00					; |
		LDA !SpriteAnimIndex			; |
		AND #$06				; |
		CLC : ADC $00				; |
		TAY					; |
		LDA .BagPtr,y : STA $04			; |
		LDA .BagPtr+1,y : STA $05		; |
		JSR AddTilemap				; |
		PLA : STA $04				; |
		PLA : STA $05				;/
	.Write	REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		STZ !SpriteTile,x
		STZ !SpriteProp,x
		JSR LOAD_PSUEDO_DYNAMIC			; load complete tilemap
		PLA : STA $33C0,x


		LDA $33C0,x : STA $0C
		LDA !ExtraProp1,x : BEQ +
		LDX #$04
		CMP #$04
		BNE $02 : LDX #$08
		STX $0F
		LDA $0E
		SEC : SBC #$04
		TAY
		LDX !OAMindex
	-	LDA !OAM+$100,y : STA !OAM+$000,x
		LDA !OAM+$101,y : STA !OAM+$001,x
		LDA !OAM+$102,y : STA !OAM+$002,x
		LDA !OAM+$103,y
		AND #$F1
		ORA $0C
		STA !OAM+$003,x
		LDA #$F0 : STA !OAM+$101,y
		PHX
		PHY
		TXA
		LSR #2
		TAX
		TYA
		LSR #2
		TAY
		LDA !OAMhi+$40,y : STA !OAMhi+$00,x
		PLY
		PLX
		INX #4
		LDA $0F
		SEC : SBC #$04 : BEQ ++
		STA $0F
		INY #4
		BRA -
	++	STX !OAMindex
		LDX !SpriteIndex
		+

		PLB
		RTL

	.AnimIdle
		dw .TM_Idle00 : db $FF,$00	; 00
	.AnimWalk
		dw .TM_Walk00 : db $10,$03	; 01
		dw .TM_Walk01 : db $08,$03	; 02 CUT
		dw .TM_Walk02 : db $10,$05	; 03
		dw .TM_Walk01 : db $08,$05	; 04 CUT
		dw .TM_Walk00 : db $10,$07	; 05
		dw .TM_Walk03 : db $08,$07	; 06 CUT
		dw .TM_Walk04 : db $10,$01	; 07
		dw .TM_Walk03 : db $08,$01	; 08 CUT
	.AnimHurt
		dw .TM_Hurt00 : db $FF,$09	; 09
	.AnimSmush
		dw .TM_Smush00 : db $07,$0B	; 0A
		dw .TM_Smush01 : db $07,$0A	; 0B
	.AnimDead
		dw .TM_Dead00 : db $FF,$0C	; 0C


	; special format: hi byte of header contains GFX status index

	.TM_Idle00
	.TM_Walk00
		db $04,$4A
		db $30,$00,$F0,$00
		db $08,$6C		; if bag is held, add 1 to GFX index
		db $30,$00,$00,$00
		db $30,$08,$00,$01
	.TM_Walk02
		db $04,$4A
		db $30,$00,$F0,$00
		db $08,$6C		; if bag is held, add 1 to GFX index
		db $30,$00,$00,$03
		db $30,$08,$00,$04
	.TM_Walk04
		db $04,$4A
		db $30,$00,$F0,$00
		db $08,$6C		; if bag is held, add 1 to GFX index
		db $30,$00,$00,$06
		db $30,$08,$00,$07

	.TM_Walk01
	;	%TM24x32($00, $00, $03, $20)
	.TM_Walk03
	;	%TM24x32($00, $00, $09, $20)

	.TM_Hurt00
		db $08,$6E
		db $30,$00,$F0,$00
		db $30,$00,$00,$02

	.TM_Smush00
		db $04,$6E
		db $30,$00,$00,$05
	.TM_Smush01
		db $04,$6E
		db $30,$00,$00,$07

	.TM_Dead00
		db $04,$6E
		db $30,$00,$00,$09

	.HatPtr
		dw .Hat1			; 00
		dw .Hat2			; 01
		dw .Hat3			; 02
		dw .Hat4			; 03
		dw .Hat5			; 04
		dw .Hat6			; 05
		dw .Hat7			; 06
		dw .Helmet			; 07
		dw .HammerHelmet		; special one used for hammer rex, should always go at the end of the list (safe to add stuff before it)
	..End

	.BagPtr
		dw .Bag1,.Bag1_tilt1,.Bag1,.Bag1_tilt2
		dw .Bag2,.Bag2_tilt1,.Bag2,.Bag2_tilt2
		dw .Bag3,.Bag3_tilt1,.Bag3,.Bag3_tilt2
		dw .Bag4,.Bag4_tilt1,.Bag4,.Bag4_tilt2
		dw .Sword,.Sword_tilt1,.Sword,.Sword_tilt2
	..End

		.Hat1
		db $04,$94
		db $3A,$03,$E8,$00
		.Hat2
		db $04,$95
		db $38,$04,$E9,$00
		.Hat3
		db $04,$96
		db $38,$05,$E8,$00
		.Hat4
		db $04,$97
		db $38,$04,$EC,$00
		.Hat5
		db $04,$98
		db $36,$04,$F0,$00
		.Hat6
		db $08,$99
		db $36,$05,$E4,$00
		db $38,$FD,$F7,$02
		.Hat7
		db $04,$9A
		db $36,$06,$EE,$00
		.Helmet
		db $04,$9B
		db $36,$04,$EB,$00

		.HammerHelmet
		db $04,$82
		db $3A,$06,$E8,$06


		.Bag1
		db $08,$9C
		db $10,$07,$00,$00
		db $36,$0A,$FB,$01
		..tilt1
		db $08,$9C
		db $10,$08,$00,$00
		db $36,$0B,$FB,$01
		..tilt2
		db $08,$9C
		db $10,$06,$00,$00
		db $36,$09,$FB,$01

		.Bag2
		..tilt1
		db $08,$9D
		db $18,$07,$FE,$00
		db $38,$0E,$F7,$01
		..tilt2
		db $08,$9D
		db $18,$08,$FE,$00
		db $38,$0F,$F7,$01

		.Bag3
		..tilt1
		..tilt2
		db $08,$9E
		db $10,$08,$FD,$00
		db $36,$09,$F8,$01

		.Bag4
		..tilt1
		..tilt2
		db $08,$9F
		db $10,$03,$FE,$00
		db $36,$F9,$FB,$01

		.Sword
		db $08,$A0
		db $36,$FF,$F8,$00
		db $16,$0D,$00,$02
		..tilt1
		db $08,$A0
		db $36,$00,$F8,$00
		db $16,$0D,$00,$12
		..tilt2
		db $08,$A0
		db $36,$FF,$F8,$00
		db $16,$0B,$00,$12



HammerRex:
.INIT		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04			;\
		BEQ +				; | No movement if extra bit is set
		LDA #$08			; |
	+	ORA #$22			;/
		STA !RexAI
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA #$01
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA !ExtraProp2,x
		AND #$C0
		ORA.b #(Rex_HatPtr_End-Rex_HatPtr)/2
		STA !ExtraProp2,x
		PLB
		RTL

.MAIN		PHB : PHK : PLB
		LDA !SpriteAnimIndex
		CMP #$0D
		BCC .NoStun

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE .NoStun			; prevent revenge hammer bug
		JSR REX_BEHAVIOUR_DontTurn
		STZ $AE,x
		JSL !SpriteApplySpeed
		LDA $34D0,x : BNE +
		JMP ++
.NoStun		JSR REX_BEHAVIOUR

	+	LDA $3230,x
		CMP #$02 : BEQ .Drop
		CMP #$04 : BNE .NoFireDrop
	.Drop	JSR DropHat
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA $9E,x : BPL .NoFireDrop
		LDA #$01
		STA $34D0,x
		STA $BE,x
		.NoFireDrop
		LDA $BE,x : BNE +
		LDA !RexAI
		AND #$08 : BEQ ++
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA !SpriteAnimIndex
		CMP #$01 : BCC ++
		CMP #$09 : BCS ++
		LDA #$00 : STA !SpriteAnimIndex
		BRA ++
	+	PHA
		JSR DropHat
		PLA
		DEC A
		BEQ +
		LDA #$0C : STA !SpriteAnimIndex
		BRA ++
	+	LDA $34D0,x : BEQ +
		LDA #$09 : STA !SpriteAnimIndex
		BRA ++
	+	LDA !SpriteAnimIndex
		CMP #$0A : BEQ ++
		CMP #$0B : BEQ ++
		STZ !SpriteAnimTimer
		LDA #$0A : STA !SpriteAnimIndex
	++	LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .AnimIdle+0,y : STA $04
		LDA.w .AnimIdle+1,y : STA $05
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimIdle+2,y : BNE +
		LDA.w .AnimIdle+3,y : STA !SpriteAnimIndex
		CMP #$0E : BNE ++
		JSR REX_HAMMER_Prep
		LDA !SpriteAnimIndex
	++	ASL #2
		TAY
		LDA.w .AnimIdle+0,y : STA $04
		LDA.w .AnimIdle+1,y : STA $05
		LDA #$00
	+	STA !SpriteAnimTimer


		STZ $33C0,x
		STZ $06
		JSR AddTilemap
		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		STZ !SpriteTile,x
		STZ !SpriteProp,x
		JSR LOAD_PSUEDO_DYNAMIC

		LDA !SpriteAnimIndex
		CMP #$0E : BNE .Return
		REP #$20
		LDA.w #.TM_SlashLine : STA $04
		SEP #$20
		JSR LOAD_TILEMAP_HiPrio

		.Return
		PLB
		RTL

.HammerDelay	db $24,$24,$18


	.AnimIdle
		dw .TM_Idle00 : db $20,$00	; 00
	.AnimWalk
		dw .TM_Walk00 : db $10,$03	; 01
		dw .TM_Walk01 : db $08,$03	; 02 CUT
		dw .TM_Walk02 : db $10,$05	; 03
		dw .TM_Walk01 : db $08,$05	; 04 CUT
		dw .TM_Walk00 : db $10,$07	; 05
		dw .TM_Walk03 : db $08,$07	; 06 CUT
		dw .TM_Walk04 : db $10,$01	; 07
		dw .TM_Walk03 : db $08,$01	; 08 CUT
	.AnimHurt
		dw .TM_Hurt00 : db $FF,$09	; 09
	.AnimSmush
		dw .TM_Smush00 : db $07,$0B	; 0A
		dw .TM_Smush01 : db $07,$0A	; 0B
	.AnimDead
		dw .TM_Dead00 : db $FF,$0C	; 0C
	.AnimPrep
		dw .TM_Prep00 : db $20,$0E	; 0D
	.AnimThrow
		dw .TM_Throw00 : db $08,$0F	; 0E
		dw .TM_Throw01 : db $20,$01	; 0F



	.TM_Idle00
	.TM_Walk00
		db $10,$82
		db $3A,$00,$F0,$00
		db $3A,$00,$00,$20
		db $3A,$08,$00,$21
		db $3A,$06,$E8,$06
	.TM_Walk01
	;	%TM24x32($00, $00, $03, $20)
	.TM_Walk02
		db $10,$82
		db $3A,$00,$F0,$00
		db $3A,$00,$00,$23
		db $3A,$08,$00,$24
		db $3A,$06,$E8,$06
	.TM_Walk03
	;	%TM24x32($00, $00, $09, $20)
	.TM_Walk04
		db $10,$82
		db $3A,$00,$F0,$00
		db $3A,$00,$00,$26
		db $3A,$08,$00,$27
		db $3A,$06,$E8,$06

	.TM_Hurt00
		db $08,$6E
		db $3A,$00,$F0,$00
		db $3A,$00,$00,$02

	.TM_Smush00
		db $04,$6E
		db $3A,$00,$00,$05
	.TM_Smush01
		db $04,$6E
		db $3A,$00,$00,$07

	.TM_Dead00
		db $04,$6E
		db $3A,$00,$00,$09

	.TM_Prep00
		db $14,$82
		db $36,$06,$FA,$08	; hammer tile
		db $3A,$00,$F0,$00
		db $3A,$00,$00,$20
		db $3A,$08,$00,$21
		db $3A,$06,$E8,$06

	.TM_Throw00
		db $10,$82
		db $3A,$F8,$F0,$0A
		db $3A,$F8,$00,$29
		db $3A,$00,$00,$2A
		db $3A,$00,$E7,$06
	.TM_Throw01
		db $14,$82
		db $3A,$F8,$F0,$0C
		db $3A,$00,$F0,$0D
		db $3A,$F8,$00,$2C
		db $3A,$00,$00,$2D
		db $3A,$00,$EA,$06


	.TM_SlashLine
		dw $000C		; should be uploaded to hi prio OAM during throw00 tilemap
		db $36,$F8,$F8,$4B	; 16x16
		db $06,$08,$F8,$4D	; 8x8
		db $06,$10,$F8,$4E	; 8x8



; $BE: state
; $3280: target player
; $3290: original Ypos (lo)
; $32A0: original Ypos (hi)
; $32D0: timer before able to swoop again

FlyingRex:
.INIT		PHB : PHK : PLB
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		STZ $3280,x			; just in case
		LDA !Difficulty
		AND #$03 : TAY
		LDA $3210,x
		CLC : ADC .SwoopDisp,y
		STA $3290,x			; save adjusted Ypos
		LDA $3240,x
		ADC #$00
		STA $32A0,x

		LDA #$10 : JSL LoadPalset
		LDA !GFX_status+$190
		ASL A
		STA $33C0,x
		PLB
		RTL

.MAIN		PHB : PHK : PLB

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ $03 : JMP .DrawSprite

	.Physics
		LDA !ExtraBits,x
		AND #$04 : BEQ .Moving
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		JMP .NoSpeed

	.Moving
		LDA $32D0,x : BNE .NotSeen
		LDA $BE,x : BNE .NotSeen
		LDY $3320,x
		LDA $3220,x
		CLC : ADC .SightX,y
		STA $04
		LDA $3250,x
		ADC .SightX+2,y
		STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$20 : STA $06
		LDA #$FF : STA $07
		SEC : JSL !PlayerClipping
		BCC .NotSeen
		CMP #$02 : BCC +
		LDA #$80 : STA $3280,x			; target player 2
	+	LDA #$01 : STA $BE,x
		LDA #$3F : STA $32D0,x
		LDA #$02 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$26 : STA !SPC4		; swooper SFX
		.NotSeen

		LDA $BE,x : BEQ .Forward
		CMP #$01 : BEQ .Swoop

		.Rise
		LDA $3210,x
		CMP $3290,x
		LDA $3240,x
		SBC $32A0,x
		BCS +
		STZ $BE,x
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$30 : STA $32D0,x
	+	LDA !Difficulty
		AND #$03 : TAY
		LDA .SwoopSpeed,y
		EOR #$FF
		BRA .Acc

		.Swoop
		LDY $3280,x : BNE +
		JSR SUB_VERT_POS_1
		BRA ++
	+	JSR SUB_VERT_POS_2
	++	CPY #$00 : BEQ +
		LDA #$02 : STA $BE,x
		BRA .Rise
	+	LDA !Difficulty
		AND #$03 : TAY
		LDA .SwoopSpeed,y
		BRA .Acc

		.Forward
		LDA #$00
	.Acc	JSR AccelerateY
		LDY $3320,x
		LDA .XSpeed,y : STA $AE,x

		.Move
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
		.NoSpeed

		JSL !GetSpriteClipping04
		JSR P2Attack
		BCC .NoHitbox
		JSR .Interact_nospin
		BRA ++
		.NoHitbox

		SEC : JSL !PlayerClipping
		BCC .Graphics
		LSR A : BCC .P2Int
	.P1Int	PHA
		LDY #$00
		JSR .Interact
		PLA
		LSR A : BCC +
	.P2Int	LDY #$80
		JSR .Interact
	+	LDA !NewSpriteNum,x
		CMP #$02 : BNE .Graphics
	++	PLB
		JMP Rex_INIT

	.Graphics
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .ANIM_FLY+$02,y : BNE .WriteTimer
		LDA .ANIM_FLY+$03,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

	.WriteTimer
		STA !SpriteAnimTimer

	.DrawSprite
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA .ANIM_FLY,y : STA $04
		SEP #$20
		JSR LOAD_PSUEDO_DYNAMIC
		PLB
		RTL

	.ANIM_FLY
		dw .FlyTM00 : db $02,$01	; 00
		dw .FlyTM01 : db $02,$00	; 01
	.ANIM_SWOOP
		dw .SwoopTM00 : db $02,$03	; 02
		dw .SwoopTM01 : db $02,$02	; 03


	.FlyTM00
		dw $0010
		db $30,$F8,$F0,$00
		db $30,$08,$F0,$02
		db $30,$F8,$00,$20
		db $30,$08,$00,$22
	.FlyTM01
		dw $0010
		db $30,$F8,$F0,$04
		db $30,$08,$F0,$06
		db $30,$F8,$00,$24
		db $30,$08,$00,$26
	.SwoopTM00
		dw $0010
		db $30,$F8,$F0,$08
		db $30,$08,$F0,$0A
		db $30,$F8,$00,$28
		db $30,$08,$00,$2A
	.SwoopTM01
		dw $0010
		db $30,$F8,$F0,$0C
		db $30,$08,$F0,$0E
		db $30,$F8,$00,$2C
		db $30,$08,$00,$2E

	.XSpeed
		db $10,$F0
	.SwoopSpeed
		db $18,$28,$38,$48
	.SwoopDisp
		db $08,$18,$2F,$4F
	.SightX
		db $00,$E0
		db $00,$FF

	.Interact
		LDA $7490 : BEQ ..nostar
		JMP SPRITE_STAR

		..nostar
		LDA !P2YPosLo-$80,y
		CMP $05
		LDA !P2YPosHi-$80,y
		SBC $0B
		BCC ..stomp
		LDA !P2Blocked-$80,y
		AND #$04 : BNE +
		LDA !P2YSpeed-$80,y
	+	SEC : SBC $9E,x
		BMI ..hurtplayer
		CMP #$10 : BCS ..stomp

		..hurtplayer
		TYA
		ASL A
		ROL A
		INC A
		JSL !HurtPlayers
		RTS

		..stomp
		JSR StompSound
		JSR P2Bounce
		LDA !P2Character-$80,y : BNE ..nospin
		LDA !MarioSpinJump : BEQ ..nospin
		JMP REX_SPINKILL
		..nospin
		LDA #$08 : STA !ExtraBits,x
		LDA #$02 : STA !NewSpriteNum,x
		LDA #$08 : STA $3230,x
		LDA #$01 : STA $BE,x
		LDA #$0A : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$0C
		STA !SpriteStasis,x
		JSR REX_BEHAVIOUR_SmushRex
		STZ $34D0,x
		JMP DontInteract




NoviceShaman:
.INIT		PHB : PHK : PLB
		LDA !ExtraBits,x		;\
		AND #$04			; | Disable movement if extra bit is set
		ASL A				; | Always enable turn + shaman bits
		ORA #$30			; |
		STA !RexAI			;/
		LDA #$10			;\ Equip mask
		STA !RexMovementFlags		;/

		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA #$01 : STA !SpriteAnimIndex
		LDA !RNG			;\
		ADC !SpriteIndex		; |
		AND #$07			; | Equip random mask
		STA !ShamanMask			;/
		LDA !Difficulty
		AND #$03 : TAY
		LDA SHAMAN_CAST_CastTime,y : STA !ShamanCast
		PLB
		RTL

.MAIN		PHB : PHK : PLB
		LDA !RexMovementFlags		;\
		AND #$08			; | If knockback flag or death timer is set, enable movement
		ORA $32F0,x			; |
		BNE .Walk			;/
		LDA $3230,x			;\
		CMP #$02			; | If status = knocked out, enable movement
		BEQ .Walk			;/

		LDA !Difficulty
		AND #$03 : TAY
		LDA !ShamanCast
		CMP SHAMAN_CAST_CastTime,y : BCC .Stop

		LDA !SpriteAnimIndex		;\ Always stop during frame 0x0C
		CMP #$0C : BEQ .Stop		;/
		LDA !ExtraBits,x		;\
		AND #$04 : BEQ .Walk		; | Aim if extra bit is set
		JSR SUB_HORZ_POS		; |
		STZ !SpriteAnimIndex		; > Reset animation
		TYA : STA $3320,x		;/

		.Stop
		LDA !RexAI
		ORA #$08
		STA !RexAI
		STZ $AE,x
		BRA .GetMain

		.Walk
		LDA !ExtraBits,x		;\ extra safety check
		AND #$04 : BNE .Stop		;/
		LDA !RexAI
		AND.b #$08^$FF
		STA !RexAI

.GetMain	LDA $3450,x : PHA
		JSR REX_BEHAVIOUR
		PLA : STA $3450,x
		LDA $3230,x
		CMP #$02 : BNE .NotKnockedOut
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		LDA $BE,x : BEQ .HurtF
		CMP #$02 : BCS .NotKnockedOut
	.HurtF	LDA #$01 : STA $34D0,x
		JSR REX_BEHAVIOUR_HurtRexFire
		STZ $34D0,x
		LDA $BE,x
		CMP #$02 : BEQ .NotKnockedOut
		LDA #$08 : STA $3230,x
		.NotKnockedOut

		LDA $32F0,x : BEQ +
		LDA #$0C : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA $3230,x
		CMP #$02 : BEQ +
		LDA #$02 : STA $3230,x
		STZ $9E,x
		+

		LDA $BE,x : BEQ +		;\
		LDA !RexMovementFlags		; | check for mask
		AND #$10 : BEQ +		;/
	++	JSR DROP_MASK			; > drop mask subroutine
		LDA #$0C			;\
		STA !SpriteAnimIndex		; |
		LDA !Difficulty			; | hurt animation
		AND #$03			; |
		ASL #3				; |
		STA !SpriteAnimTimer		;/
		+

		LDA !SpriteAnimIndex		;\
		ASL #2				; |
		TAY				;/
		LDA !SpriteAnimTimer		;\
		INC A				; |
		CMP.w .AnimIdle+2,y		; |
		BNE +				; |
		LDA.w .AnimIdle+3,y		; | Update animation
		STA !SpriteAnimIndex		; |
		ASL #2				; |
		TAY				; |
		LDA #$00			; |
	+	STA !SpriteAnimTimer		;/


		REP #$20			; > A 16-bit

		STZ $06				; initialize tilemap load

		LDA !SpriteAnimIndex
		AND #$00FF
		CMP #$0009 : BCC .NoSpell
		CMP #$000C : BCS .NoSpell
		SEP #$20
		STZ $00
		STZ $01
		LDA !SpriteProp,x
		AND #$01
		ORA #$0A
		STA $02
		STZ $03
		REP #$20
		LDA.w #.SpellTM : JSL LakituLovers_TilemapToRAM_Long
		SEP #$20
		PHY				; 
		LDA $14				;\
		LSR A				; | Spell tilemap is indexed by frame counter
		AND #$0F			; |
		TAY				;/
		LDA .SpellPart1X,y		;\
		STA !BigRAM+$03			; |
		LDA .SpellPart2X,y		; | Spell X-coords
		STA !BigRAM+$07			; |
		LDA .SpellPart3X,y		; |
		STA !BigRAM+$0B			;/
		LDA .SpellPart1Y,y		;\
		STA !BigRAM+$04			; |
		LDA .SpellPart2Y,y		; | Spell Y-coords
		STA !BigRAM+$08			; |
		LDA .SpellPart3Y,y		; |
		STA !BigRAM+$0C			;/
		LDA .SpellTile1,y		;\
		CLC : ADC !SpriteTile,x		; |
		STA !BigRAM+$05			; |
		LDA .SpellTile2,y		; | Spell tiles
		CLC : ADC !SpriteTile,x		; |
		STA !BigRAM+$09			; |
		LDA .SpellTile3,y		; |
		CLC : ADC !SpriteTile,x		; |
		STA !BigRAM+$0D			;/
		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL LOAD_TILEMAP_HiPrio_Long
		STZ $06
		PLY				;
		.NoSpell


		SEP #$20
		LDA $BE,x : BNE .NoMask
		STZ $00
		STZ $01
		PHY
		LDY !SpriteAnimIndex
		CPY #$03 : BEQ .Up1
		CPY #$07 : BNE +
	.Up1	DEC $01
	+	CPY #$09 : BCC +
		CPY #$0C : BCS +
		LDA .MaskX-9,y : STA $00
		LDA .MaskY-9,y : STA $01
	+	LDA !SpriteProp,x
		AND #$01
		ORA #$04
		STA $02
		LDY !ShamanMask
		LDA .MaskTile,y
		CLC : ADC !SpriteTile,x
		STA $03
		REP #$20
		LDA.w #.MaskTM00 : JSL LakituLovers_TilemapToRAM_Long
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL LOAD_TILEMAP_HiPrio_Long
		STZ $06
		PLY
		.NoMask

		STZ $00
		STZ $01
		LDA !SpriteProp,x
		AND #$01
		ORA #$0A
		STA $02
		LDA !SpriteTile,x : STA $03
		REP #$20
		LDA.w .AnimIdle+0,y : JSL LakituLovers_TilemapToRAM_Long

		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20

		JSR LOAD_TILEMAP		; > Upload tilemap
		PLB
		RTL


	.AnimIdle
		dw .IdleTM00 : db $FF,$00	; 00

	.AnimWalk
		dw .WalkTM00 : db $08,$03	; 01
		dw .IdleTM00 : db $08,$03	; REDACTED
		dw .WalkTM01 : db $08,$05	; 03
		dw .IdleTM00 : db $08,$05	; REDACTED
		dw .WalkTM00 : db $08,$07	; 05
		dw .IdleTM00 : db $08,$07	; REDACTED
		dw .WalkTM02 : db $08,$01	; 07
		dw .IdleTM00 : db $08,$01	; REDACTED

	.AnimCast
		dw .CastTM00 : db $06,$0A	; 09
		dw .CastTM01 : db $06,$0B	; 0A
		dw .CastTM02 : db $06,$09	; 0B

	.AnimHurt
		dw .HurtTM00 : db $1F,$01	; 0C, timer hardcoded


; Tilemaps are always 4 bytes larger because of the mask.

	.IdleTM00
		dw $0008
		db $30,$00,$F0,$00
		db $30,$00,$00,$20

	.WalkTM00
		dw $0008
		db $30,$00,$F0,$00
		db $30,$00,$00,$20
	.WalkTM01
		dw $0008
		db $30,$00,$EF,$00
		db $30,$00,$FF,$02
	.WalkTM02
		dw $0008
		db $30,$00,$EF,$00
		db $30,$00,$FF,$22

	.HurtTM00
		dw $0008
		db $30,$00,$F0,$43
		db $30,$00,$00,$63

	.CastTM00
		dw $0014
		db $30,$EF,$F8,$45
		db $30,$FA,$F0,$0A
		db $30,$02,$F0,$0B
		db $30,$FA,$00,$2A
		db $30,$02,$00,$2B

	.CastTM01
		dw $0014
		db $30,$EF,$F8,$47
		db $30,$FA,$F0,$0D
		db $30,$02,$F0,$0E
		db $30,$FA,$00,$2D
		db $30,$02,$00,$2E

	.CastTM02
		dw $0014
		db $30,$EF,$F8,$49
		db $30,$FA,$F0,$40
		db $30,$02,$F0,$41
		db $30,$FA,$00,$60
		db $30,$02,$00,$61

	.MaskTM00
		dw $0004
		db $30,$FC,$F3,$00
	.MaskX
		db $FB,$FB,$FC
	.MaskY
		db $01,$00,$00
	.MaskTile
		db $04,$06,$08,$24
		db $24,$26,$28,$28

	.SpellTM
		dw $000C
		db $30,$00,$00,$00
		db $30,$00,$00,$00
		db $30,$00,$00,$00

	.SpellPart1X
		db $F8,$F7,$F8,$F9		; 00-03
		db $F8,$F7,$F8,$F9		; 04-07
		db $F8,$F7,$F8,$F9		; 08-0B
		db $F8,$F7,$F8,$F9		; 0C-0F
	.SpellPart2X
		db $02,$03,$02,$01
		db $02,$03,$02,$01
		db $02,$03,$02,$01
		db $02,$03,$02,$01
	.SpellPart3X
		db $0C,$0D,$0C,$0B
		db $0C,$0D,$0C,$0B
		db $0C,$0D,$0C,$0B
		db $0C,$0D,$0C,$0B
	.SpellPart1Y
		db $08,$07,$06,$05
		db $04,$03,$02,$01
		db $00,$FF,$FE,$FD
		db $FC,$FB,$FA,$F9
	.SpellPart2Y
		db $02,$01,$00,$FF
		db $FE,$FD,$FC,$FB
		db $FA,$F9,$08,$07
		db $06,$05,$04,$03
	.SpellPart3Y
		db $FC,$FB,$FA,$F9
		db $08,$07,$06,$05
		db $04,$03,$02,$01
		db $00,$FF,$FE,$FD
	.SpellTile1
		db $4B,$4B,$4B,$4B
		db $4B,$4B,$4B,$4B
		db $4D,$4D,$4D,$4D
		db $4D,$4D,$4D,$4D
	.SpellTile2
		db $4B,$4B,$4D,$4D
		db $4D,$4D,$4D,$4D
		db $4D,$4D,$4B,$4B
		db $4B,$4B,$4B,$4B
	.SpellTile3
		db $4D,$4D,$4D,$4D
		db $4B,$4B,$4B,$4B
		db $4B,$4B,$4B,$4B
		db $4D,$4D,$4D,$4D




	!AdeptCast	= $34F0,x		; changed from $33C0
	!AnimIdle	= #$00
	!AnimHover	= #$03
	!AnimCast	= #$06
	!AnimAfterCast	= #$08
	!AnimFDash	= #$0A
	!AnimBDash	= #$0D
	!AnimGrind	= #$10


AdeptShaman:
.INIT		PHB : PHK : PLB
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA #$04 : STA $BE,x		; > HP = 4
		LDA #$FF : STA $34C0,x		; > Disable circle cast
		STZ $3390,x			;\ Clear casting status
		STZ !AdeptCast			;/
		STZ !RexAI			; > Reset AI
		STZ $32E0,x
		STZ $35F0,x

		LDA !ExtraBits,x
		AND #$04 : BEQ .No3D
		JSR Mask3D_Init
		.No3D



		STZ !ClaimedGFX				;\
		LDY #$0F				; |
	-	CPY !SpriteIndex : BEQ +		; |
		LDA $3230,y : BEQ +			; |
		LDA !ExtraBits,y			; | adjust GFX allocation
		AND #$08 : BEQ +			; |
		LDA !NewSpriteNum,y			; |
		CMP !NewSpriteNum,x : BNE +		; |
		LDA #$08 : STA !ClaimedGFX		; |
	+	DEY : BPL -				;/


		LDA !ClaimedGFX
		ASL #4
		STA $00
		STZ $01


		LDY.b #!File_Wizrex
		JSL !GetFileAddress
		JSL !GetVRAM
		LDA.b #!VRAMbank
		PHA : PLB
		REP #$20
		LDA !FileAddress+2
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		LDA.l !RNG
		ADC.l !SpriteIndex
		AND #$0003
		XBA
		LSR #2
		CLC : ADC !FileAddress
		STA !VRAMtable+$02,x
		CLC : ADC #$0200
		STA !VRAMtable+$09,x
		LDA #$7E60
		CLC : ADC $00
		STA !VRAMtable+$05,x
		LDA #$7F60
		CLC : ADC $00
		STA !VRAMtable+$0C,x
		LDA #$0040
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x

	;	JSL !GetCGRAM
	;	LDA #$001E : STA !CGRAMtable+$00,x
	;	LDA.w #.Pal : STA !CGRAMtable+$02,x
		SEP #$20
	;	LDA.b #.Pal>>16 : STA !CGRAMtable+$04,x
	;	LDA #$D1 : STA !CGRAMtable+$05,x
		PLB


		LDX !SpriteIndex
		LDA #$11 : JSL LoadPalset
		LDA !GFX_status+$191
		ASL A
		STA $33C0,x
		RTL


	; AI:
	; CCt---PP
	; C = Cast stage
	; t = target player
	; P = Phase


.MAIN		PHB : PHK : PLB
		PEI ($D8)			;\
		PEI ($DA)			; | Backup sprite pointers
		PEI ($DE)			;/

		LDA !GFX_status+$83
		STA $00
		AND #$70
		ASL A
		STA !BigRAM+$7B
		LDA $00
		AND #$0F
		TSB !BigRAM+$7B
		LDA $00
		ASL A
		ROL A
		AND #$01
		STA !BigRAM+$7C
		STZ !BigRAM+$7D
		STZ !BigRAM+$7A
		LDA !BigRAM+$7B : STA !SpriteTile,x
		LDA !BigRAM+$7C : STA !SpriteProp,x

		LDA !RexAI
		AND #$03
		ASL A
		CMP.b #.StatueMode-.PhasePtr
		BCC $02 : LDA #$02
		TAX
		JSR (.PhasePtr,x)
		REP #$20			;\
		PLA : STA $DE			; |
		PLA : STA $DA			; | Restore sprite pointers
		PLA : STA $D8			; |
		SEP #$20			;/


		LDA !ExtraBits,x
		AND #$04 : BEQ .Shaman

		LDA #$20
		STA $32E0,x
		STA $35F0,x

		JSR Mask3D

		INC $9E,x
		INC $9E,x
		INC $9E,x
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$8

		REP #$20
		JMP .DrawSpell



	.Shaman
		JSL !SpriteApplySpeed		; > Update speed

		LDA !SpriteAnimIndex		;\
		STA $00				; | Get index (and save copy in scratch RAM)
		ASL A				; |
		STA $02				; |
		ASL A				; |
		CLC : ADC $02			; |
		TAY				;/
		LDA !SpriteAnimTimer		;\
		INC A				; |
		CMP.w .AnimIdle+2,y		; |
		BNE +				; |
		LDA.w .AnimIdle+3,y		; | Update animation
		STA !SpriteAnimIndex		; |
		ASL A				; |
		STA $02				; |
		ASL A				; |
		CLC : ADC $02			; |
		TAY				; |
		LDA #$00			; |
	+	STA !SpriteAnimTimer		;/

		REP #$20
		LDA.w .AnimIdle+4,y : BEQ ++
		STA $0C
		SEP #$20
		LDA $3340,x
		CMP !SpriteAnimIndex : BEQ +
		PHY

		LDA !GFX_Dynamic : PHA
		LDA !ClaimedGFX : STA !GFX_Dynamic
		LDY.b #!File_Wizrex
		JSL !UpdateFromFile		; load dynamo / update GFX
		PLA : STA !GFX_Dynamic

		PLY
		+

		REP #$20			; > A 16-bit
	++	LDA $32E0,x			;\
		ORA $35F0,x			; |
		AND #$00FF : BEQ .Draw		; |
		LDA $14				; |
		AND #$0002 : BNE .Draw		; | Invulnerability flash
		SEP #$20			; |
		PLB				; |
		RTL				;/

	.Draw
		LDA !SpriteAnimIndex		;\ Currently loaded frame
		STA $3340,x			;/
		STZ $00
		STZ $02
		STZ $06
		LDA.w .AnimIdle+0,y : STA $04	; get static tilemap pointer

		CPY.b #$10*6 : BCC .NoGrind	;\
		LDA $04 : JSL LakituLovers_TilemapToRAM_Long
		LDA !SpriteAnimIndex
		AND #$00FF
		SEC : SBC #$0006
		CMP #$000D : BCC +
		SBC #$0003
	+	STA $0E
		ASL A
		ADC $0E
		ASL A
		TAY
		LDA.w .AnimIdle+0,y : STA $04	;/
		.NoGrind





		LDA $BE,x
		AND #$00FF
		CMP #$0004 : BNE .NoMask
		STZ $00
		LDA !ClaimedGFX
		AND #$00FF
		XBA
		ORA #$0004
		STA $02
		LDA $04 : JSL LakituLovers_TilemapToRAM_Long	; mask
		LDA $04
		CLC : ADC #$0004		; already incremented by 2 during transcription
		STA $04
		BRA .DrawBody

		.NoMask
		LDA $04
		CLC : ADC #$0006
		STA $04

		.DrawBody
		PHP
		SEP #$30
		LDA $33C0,x : STA $02

		LDA !RexAI			;\
		AND #$0F			; |
		CMP #$02 : BNE +		; |
		LDA !RexChase			; |
		AND #$C0			; | Handle death flash
		CMP #$C0 : BEQ .NoFlash		; |
		LDA $14				; |
		AND #$02 : BNE ++		; |
		BRA .NoFlash			;/
	+	LDA $34C0,x			;\ No flash during circle cast
		CMP #$FF : BNE .NoFlash		;/
		LDA $35D0,x : BEQ .NoFlash	;\ Only flash when preparing spray or grind
		CMP #$02 : BEQ .NoFlash		;/
		LDA $14				;\
		CMP #$E2 : BCC .NoFlash		; | Only flash between 0xE2 < t < 0xF2
		CMP #$F2 : BCS .NoFlash		;/
	++	LDA #$0A : STA $02		;/
		.NoFlash
		LDA !ClaimedGFX : STA $03
		REP #$20
		LDA $04 : JSL LakituLovers_TilemapToRAM_Long
		LDA.w #!BigRAM : STA $04

		SEP #$20			; |
		JSR LOAD_TILEMAP		; |
		PLP				;/



		.DrawSpell
		LDA $34C0-1,x
		CMP #$FF00 : BCS .NoSpell
		LDA #!BigRAM+$02 : STA $04	; > $04 = tilemap pointer
		SEP #$20
		JSR .CircleCast_GetCoords
		REP #$20
		LDA $0E
		AND #$00FF
		ASL #2
		STA !BigRAM
		LDA.w #!BigRAM : STA $04
		PHP
		SEP #$30
		JSR LOAD_TILEMAP_HiPrio
		PLP
		.NoSpell
		SEP #$30

		PLB
		RTL


	.DrawTiles
		LDA !RexAI
		AND #$03
		CMP #$02 : BEQ $03
	-	JMP .NoDeath
		LDA !RexChase
		AND #$C0
		CMP #$C0 : BEQ -
		LDA $3330,x
		AND #$04 : BEQ .NoDeath

		LDA #$2D			;\
		STA !BigRAM+$02			; | Spell prop
		STA !BigRAM+$06			; |
		STA !BigRAM+$0A			;/
		LDA $14				;\
		LSR A				; | Spell tilemap is indexed by frame counter
		AND #$0F			; |
		TAY				;/
		LDA NoviceShaman_SpellPart1X,y	;\
		DEC #2				; |
		STA !BigRAM+$03			; |
		LDA NoviceShaman_SpellPart2X,y	; | Spell X-coords
		DEC #2				; |
		STA !BigRAM+$07			; |
		LDA NoviceShaman_SpellPart3X,y	; |
		DEC #2				; |
		STA !BigRAM+$0B			;/
		LDA NoviceShaman_SpellPart1Y,y	;\
		STA !BigRAM+$04			; |
		LDA NoviceShaman_SpellPart2Y,y	; | Spell Y-coords
		STA !BigRAM+$08			; |
		LDA NoviceShaman_SpellPart3Y,y	; |
		STA !BigRAM+$0C			;/
		LDA NoviceShaman_SpellTile1,y	;\
		STA !BigRAM+$05			; |
		LDA NoviceShaman_SpellTile2,y	; | Spell tiles
		STA !BigRAM+$09			; |
		LDA NoviceShaman_SpellTile3,y	; |
		STA !BigRAM+$0D			;/
		REP #$20			; > A 16-bit
		LDA $04				;\
		CLC : ADC #$000C		; | Update tilemap pointer
		STA $04				;/
		LDA !BigRAM+$00			;\
		CLC : ADC #$000C		; | Increase tile count
		STA !BigRAM+$00			;/
		.NoDeath
		REP #$20

		LDA !ClaimedGFX
		AND #$00FF
		XBA
		STA $0A

		JSR LOAD_TILEMAP_HiPrio		; > Upload tilemap
		PLB
		RTL



	.PhasePtr
		dw .StatueMode
		dw .ChaseMode
		dw .DeathMode


	.StatueMode
		LDX !SpriteIndex
		LDA !ExtraBits,x
		AND #$04 : BNE .TakeFlight
		LDA $3250,x
		XBA
		LDA $3220,x
		REP #$20
		STA $00
		SEC : SBC !P2XPosLo-$80
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0040
		BCC .TakeFlight
		LDA $00
		SEC : SBC !P2XPosLo
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0040
		BCC .TakeFlight
		SEP #$20
	.Return	RTS


	.TakeFlight
		SEP #$20

		LDA #$0A : STA !RexChase
		LDA #$0A : STA !AdeptFlyTimer
		LDA !AnimCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		LDA $3210,x
		SEC : SBC #$50
		STA $32B0,x
		LDA $3240,x
		SBC #$00
		STA $35A0,x

		INC !RexAI

	.ChaseMode
		LDX !SpriteIndex
		LDA !ExtraBits,x
		AND #$04 : BEQ $03 : JMP .NoContact	; mask can't get hit
		LDA $BE,x : BPL .NoReggedHit
		LSR #4
		AND #$03
		BIT $BE,x
		BVS ..2

		..1
		JSR ADEPT_ROUTE_1
	-	LDA #$FF : STA $34C0,x		;\
		LDA !RexAI			; |
		AND.b #$C0^$FF			; | Cancel magic and attacks
		STA !RexAI			; |
		STZ $35D0,x			;/
		STZ $3390,x			;\ Despawn spell particles
		STZ !AdeptCast			;/
		LDA $BE,x
		AND #$0F
		DEC A
		STA $BE,x
		BNE +
		JMP .KillAdept
	+	LDA #$0C
		STA $32E0,x
		LDA $BE,x
		CMP #$03 : BNE +
		JSR DROP_MASK_Spawn
		LDA $33C0,y			;\
		AND #$F0			; | set mask palette
		ORA #$05			; |
		STA $33C0,y			;/
		LDA #$E6			;\
		CLC : ADC !ClaimedGFX		; | set mask tile
		STA $33D0,y			;/
	+	JMP .NoContact

		..2
		JSR ADEPT_ROUTE_2
		BRA -

		.NoReggedHit
		LDA !P1Dead
		ORA !MarioAnim
		BEQ $03 : JMP .NoContact
		JSL $03B664			; > Get Mario clipping
		LDA $3210,x
		SEC : SBC #$10
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA $3220,x
		SEC : SBC #$02
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA #$14 : STA $06
		LDA #$20 : STA $07
		JSL $03B72B			; > Check for contact
		BCC .NoContact

		LDA $7490
		BEQ $03 : JMP SPRITE_STAR
		LDA $32E0,x : BNE .NoContact
		LDA #$0C : STA $32E0,x
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC #$0010
		CMP $96
		SEP #$20
		BCC .HurtMario
.HurtAdept	JSL !BouncePlayer
		JSL !ContactGFX
		LDY #$00 : JSR StompSound
		LDA #$FF : STA $34C0,x		;\
		LDA !RexAI			; |
		AND.b #$C0^$FF			; | Cancel magic and attacks
		STA !RexAI			; |
		STZ $35D0,x			;/
		STZ $3390,x			;\ Despawn spell particles
		STZ !AdeptCast			;/
		DEC $BE,x
		LDA $BE,x : BEQ .KillAdept
		CMP #$03 : BNE .GetRoute
		JSR DROP_MASK_Spawn
		LDA $33C0,y			;\
		AND #$F0			; | Set mask palette
		ORA #$05			; |
		STA $33C0,y			;/
		LDA #$E6 : STA $33D0,y		; > Set mask tile
.GetRoute	PEA .NoContact-1
		LDA #$01 : JMP ADEPT_ROUTE_1	; > Dodge stomp

.KillAdept	INC !RexAI
		STZ !RexChase
		RTS

.HurtMario	LDA $7497
		ORA $787A
		BNE .NoContact
		JSL $00F5B7			; Hurt Mario
		.NoContact


		LDA !AdeptFlyTimer : BNE ..KeepFlying

		LDA !AdeptSequence : BEQ +
		AND #$0F
		DEC A
		STA !RexChase
		LDA !AdeptSequence
		LSR #4
		STA !AdeptSequence
		JMP ..NoSpell

	+	LDA #$08
		CMP !RexChase : BEQ ..KeepFlying
		STA !RexChase
		LDA !AnimAfterCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..KeepFlying

		LDA !RexChase
		CMP #$08 : BEQ $03 : JMP ..NoSpell

	LDA $35D0,x : BEQ ..NormCoords
	CMP #$02 : BNE ..FeintCoords
	..NormCoords
		LDA !RexAI
		AND #$20
		BEQ +
		LDA !P2XPosLo : STA $3290,x
		LDA !P2XPosHi : STA $32A0,x
		LDA !P2YPosLo
		SEC : SBC #$50
		STA $32B0,x
		LDA !P2YPosHi
		SBC #$00
		STA $35A0,x
		JMP ..HandleAttack
	+	LDA !P2XPosLo-$80 : STA $3290,x
		LDA !P2XPosHi-$80 : STA $32A0,x
		LDA !P2YPosLo-$80
		SEC : SBC #$50
		STA $32B0,x
		LDA !P2YPosHi
		SBC #$00
		STA $35A0,x
		BRA ..HandleAttack
	..FeintCoords
		LDA $AE,x
		BPL +
		LDA #$30 : STA $00
		STZ $01
		BRA ++
	+	LDA #$D0 : STA $00
		LDA #$FF : STA $01
	++	LDA !RexAI
		AND #$20
		BEQ +
		LDA !P2XPosLo
		SEC : SBC $00
		STA $3290,x
		LDA !P2XPosHi
		SBC $01
		STA $32A0,x
		LDA !P2YPosLo
		SEC : SBC #$40
		STA $32B0,x
		LDA !P2YPosHi
		SBC #$00
		STA $35A0,x
		BRA ..HandleAttack
	+	LDA !P2XPosLo-$80
		SEC : SBC $00
		STA $3290,x
		LDA !P2XPosHi-$80
		SBC $01
		STA $32A0,x
		LDA !P2YPosLo-$80
		SEC : SBC #$40
		STA $32B0,x
		LDA !P2YPosHi-$80
		SBC #$00
		STA $35A0,x

		..HandleAttack
		LDA $34C0,x
		CMP #$FF : BNE ..Spell
		LDA !RexChase
		AND #$1F
		CMP #$09 : BCS ..NoSpell
		LDA $14 : BEQ ..ExecuteAttack
	;	CMP #$D2 : BNE ..NoSpell

		..ChooseAttack
		JSR SPRAY_CHECK
		BCC ..NoSpray
		LDA #$03 : STA $35D0,x
		BRA ..NoSpell

		..NoSpray
		LDA !RNG
		ADC !SpriteIndex
		AND #$01
		INC A
		STA $35D0,x
		BRA ..NoSpell

		..ExecuteAttack
		LDA !RexAI			;\
		AND.b #$20^$FF			; |
		STA $00				; |
		LDA !RNG			; | Target random player
		ADC !SpriteIndex		; |
		AND #$20			; |
		ORA $00				; |
		STA !RexAI			;/
		LDA $35D0,x
		STZ $35D0,x
		DEC A
		BEQ ..Grind
		CMP #$01 : BEQ ..SpellSet

	..MaskSpecial

		..Spray
		LDA #$0C : STA !RexChase
		LDA #$40 : STA !AdeptFlyTimer
		LDA !AnimCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ..NoSpell

		..Grind
		LDA !ExtraBits,x
		AND #$04 : BNE ..MaskSpecial		; mask can't grind :(
		LDA #$0B : STA !RexChase
		LDA #$30 : STA !AdeptFlyTimer
		LDA #$10 : STA $9E,x
		LDA !AnimAfterCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ..NoSpell

		..SpellSet
		STZ $34C0,x
		..Spell
		JSR .CircleCast
		..NoSpell


		LDA !RexChase
		AND #$1F
		ASL A
		CMP.b #.N-.MovePtr
		BCS .DeathMode_Return
		TAX
		JMP (.MovePtr,x)


; !RexChase:
; is--tttt
; i is init flag
; s is stage (0 = flash, 1 = petrify)
	.DeathMode
		LDX !SpriteIndex
		TXY
		LDA $33F0,x : TAX
		LDA #$EE : STA.l $418A00,x
		TYX
		JSR SPRITE_OFF_SCREEN

	..Stay	LDA $3330,x
		AND #$04 : BNE ..Ground
		LDA !SpriteAnimIndex
		CMP !AnimAfterCast : BEQ ..Return
		CMP !AnimAfterCast+1 : BEQ ..Return
		LDA !AnimAfterCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
..Return	RTS

		..Ground
		STZ $9E,x
		STZ $AE,x
		BIT !RexChase : BMI +
		LDA #$80 : STA !RexChase
		LDA !SpriteAnimIndex
		CMP !AnimIdle+3 : BCC +
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

	+	BVS +
		LDA $14
		AND #$07 : BNE ..Return

		INC !RexChase
		LDA !RexChase
		AND #$0F : BNE ..Return
		LDA #$C0 : STA !RexChase

	+	STZ !SpriteAnimTimer
		LDA $14
		AND #$07 : BNE ..Return
		LDA !RexChase
		CMP #$D0 : BNE ..Petrify
		RTS

..Petrify	INC A
		STA !RexChase

		AND #$1F
		STA $00
		STZ $01

		PHX
		REP #$30
		LDA !GFX_status+$191
		AND #$0007
		ORA #$0008
		ASL #4
		INC A
		ASL A
		TAX
		PHA
		LDY #$0000
	-	LDA .StatuePal,y : STA !PaletteHSL+$900,x
		INX #2
		INY #2
		CPY #$001E : BCC -

		LDA !GFX_status+$191
		AND #$0007
		ORA #$0008
		ASL #2
		INC A
		TAX
		LDY #$000F
		LDA $00
		JSL !MixRGB

		PLA : STA $00
		JSL !GetCGRAM : BCS +
		PHB				;\
		PEA !VRAMbank*$100+!VRAMbank	; | Hopefully this bank wrapper works
		PLB : PLB			;/
		LDA #$001E : STA !CGRAMtable+$00,y
		LDA $00
		CLC : ADC.w #!PaletteHSL+$900
		STA !CGRAMtable+$02,y
		LDA $00
		LSR A
		XBA
		ORA #$0040
		STA !CGRAMtable+$04,y
		PLB
	+	SEP #$30
		PLX
		RTS




	.MovePtr
		dw .N				;\
		dw .NE				; |
		dw .E				; |
		dw .SE				; | 0-7 are dash-dance directions
		dw .S				; |
		dw .SW				; |
		dw .W				; |
		dw .NW				;/
		dw .Hover			; 8
		dw .Swoop			; 9
		dw .Jump			; A
		dw .Grind			; B
		dw .Spray			; C


	.N
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		LDA !AnimCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$26 : STA !SPC4		; swooper SFX
	+	LDA.b #$40^$FF+1
		STA $9E,x
		STZ $AE,x
		RTS

	.NE
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA.b #$2D^$FF+1
		STA $9E,x
		LDA #$2D
		STA $AE,x
		RTS

	.E
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA #$40
		STA $AE,x
		STZ $9E,x
		RTS

	.SE
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA #$2D
		STA $9E,x
		STA $AE,x
		RTS

	.S
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		LDA !AnimAfterCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$26 : STA !SPC4
	+	LDA #$40
		STA $9E,x
		STZ $AE,x
		RTS

	.SW
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA #$2D
		STA $9E,x
		LDA.b #$2D^$FF+1
		STA $AE,x
		RTS

	.W
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA.b #$40^$FF+1
		STA $AE,x
		STZ $9E,x
		RTS

	.NW
		LDX !SpriteIndex
		LDA !RexChase
		BMI +
		ORA #$80 : STA !RexChase
		LDA #$08 : STA !AdeptFlyTimer
		JSR .DashDirection
	+	LDA.b #$2D^$FF+1
		STA $9E,x
		STA $AE,x
		RTS


	.Hover
		LDX !SpriteIndex
		LDA $AE,x
		BPL $03 : EOR #$FF : INC A
		CMP #$20 : BCC +
		LDA !SpriteAnimIndex
		CMP !AnimFDash : BCC ++			;\
		CMP !AnimFDash+3 : BCC +++		; | adjusted
	++	LDA !AnimFDash : STA !SpriteAnimIndex	;/
		STZ !SpriteAnimTimer
		BRA +++
	+	LDA !SpriteAnimIndex
		CMP !AnimHover : BCC +++		;\
		CMP !AnimHover+3 : BCC +++		; | adjusted
		LDA !AnimHover : STA !SpriteAnimIndex	;/
		STZ !SpriteAnimTimer
		+++


		LDA !RexAI
		AND #$20
		BEQ +
		JSR SUB_HORZ_POS_2
		BRA ++
	+	JSR SUB_HORZ_POS
	++	TYA
		STA $3320,x

		LDA $3290,x : STA $00		;\ Desired X coord
		LDA $32A0,x : STA $01		;/
		LDA $32B0,x : STA $02		;\ Desired Y coord
		LDA $35A0,x : STA $03		;/
		LDA $3210,x : STA $04		;\ Current Y coord
		LDA $3240,x : STA $05		;/
		LDA $3250,x			;\
		XBA				; |
		LDA $3220,x			; | Distance to desired X
		REP #$20			; |
		SEC : SBC $00			; |
		STA $00				;/
		LDA $04				;\
		SEC : SBC $02			; | Distance to desired Y
		STA $02				;/
;		BMI +
;		CMP #$0080 : BCS ..Swoop
;	+	CMP #$FF80 : BCS ..Jump
		CMP #$0000
		BPL $04 : EOR #$FFFF : INC A
		LDY #$00
		CMP #$000C : BCC ..UpDown
		INY

		..UpDown
		SEP #$20
		LDA ..UpDownSpeed,y
		EOR $03
		STA $0F
		LDA $14
		LSR #4
		AND #$07
		TAY
		LDA ..YSine,y
		CLC : ADC $0F
		STA $9E,x


		REP #$20
		LDA $00
		BPL $04 : EOR #$FFFF : INC A
		LDY #$00
		CMP #$000C : BCC ..LeftRight
		INY
		CMP #$0060 : BCC ..LeftRight
		INY

		..LeftRight
		SEP #$20
		LDA ..LeftRightSpeed,y
		EOR $01
		STA $0F
		LDA $AE,x
		CMP $0F
		BEQ ..NoLeftRight
		BPL +
		INC #2
	+	DEC A
		STA $AE,x
		..NoLeftRight
		RTS

		..Swoop
		SEP #$20
		LDA #$09 : STA !RexChase
		LDA #$FF : STA !AdeptFlyTimer
		RTS

		..Jump
		SEP #$20
		LDA !AnimCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$0A : STA !RexChase
		LDA #$FF : STA !AdeptFlyTimer
		RTS

		..UpDownSpeed
		db $00,$F0

		..LeftRightSpeed
		db $00,$E8,$C8

		..YSine
		db $F8,$F8,$FC,$04,$08,$08,$04,$FC

	.Swoop
		; Make adept keep going until it reaches the target

		LDX !SpriteIndex
		RTS

	.Jump
		; Make sure this doesn't end until adept is at least 4 tiles above target

		LDX !SpriteIndex
		LDA !RexChase : BPL ..ShowOff
		LDA $3210,x
		CMP $32B0,x
		LDA $3240,x
		SBC $35A0,x
		BPL ..Ascend
		LDA $9E,x : BMI +
		LDA #$08 : STA !RexChase
		STZ !AdeptFlyTimer
		LDA !AnimCast : STA !SpriteAnimIndex		; adjusted to cast
		STZ !SpriteAnimTimer
		RTS

		..ShowOff
		LDY !AdeptFlyTimer
		CPY #$01 : BNE ..Return
		ORA #$80 : STA !RexChase

		..Ascend
		LDA #$C0 : STA $9E,x
	+	LDA #$02 : STA !AdeptFlyTimer

		..Return
		RTS

	.Grind
		LDX !SpriteIndex
		BIT !RexChase : BVS ..Ascend

		..Grind
		BIT !RexChase : BMI ..Accel
		LDA $3330,x
		AND #$04
		BNE ..Ground
		INC !AdeptFlyTimer

		..Return
		RTS

		..Ascend
		LDA !Difficulty
		AND #$03 : BEQ ..NoExtraShot
		CMP #$02 : BNE +
		LDA !AdeptFlyTimer
		CMP #$0A : BEQ ..ExtraShot
	+	LDA !AdeptFlyTimer
		CMP #$14 : BNE ..NoExtraShot

		..ExtraShot
		LDA #$10 : STA !SPC1
		LDA #$00 : JSR QUICK_CAST

		..NoExtraShot
		LDA $9E,x
		SEC : SBC #$04
		STA $9E,x
		LDA $AE,x
		BEQ ..Return
		BPL +
		INC $AE,x
		RTS
	+	DEC $AE,x
		RTS

		..Ground
		LDA !RexChase : BMI ..Accel
		ORA #$80
		STA !RexChase
		LDA !SpriteAnimIndex
		CMP !AnimGrind : BCS +			; -6
		LDA !AnimGrind : STA !SpriteAnimIndex	; -6
		STZ !SpriteAnimTimer
		LDA #$2D : STA !SPC1
	+	JSR SUB_HORZ_POS
		TYA
		STA $3320,x

		..Accel
		STZ $9E,x
		LDA !AdeptFlyTimer
		CMP #$01 : BEQ ..TargetFound
		LDA $3320,x
		ASL A
		TAY
		LDA $3210,x : STA $00
		LDA $3240,x : STA $01
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		CLC : ADC ..X,y
		CMP !P2XPosLo-$80 : BCS ..NoTarget
		CLC : ADC #$0020
		CMP !P2XPosLo-$80 : BCC ..NoTarget
		LDA $00
		SEC : SBC #$0030
		CMP !P2YPosLo-$80 : BCS ..NoTarget
		CLC : ADC #$0050
		CMP !P2YPosLo-$80 : BCC ..NoTarget
		SEP #$20

		..TargetFound
		LDA !RexChase
		ORA #$40
		STA !RexChase
		LDA #$20 : STA !AdeptFlyTimer
		LDA !AnimCast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$E8 : STA $9E,x
		LDA $AE,x
		BPL +
		EOR #$FF
		LSR A
		EOR #$FF
		STA $AE,x
		BRA ++
	+	LSR A
		STA $AE,x
	++	LDA #$10 : STA !SPC1
		LDA #$00 : JSR QUICK_CAST
		RTS

		..NoTarget
		SEP #$20
		LDA $3320,x : BEQ +
		LDA $AE,x
		DEC #2 : BPL ++
		CMP #$B0
		BCS $02 : LDA #$B0
	++	STA $AE,x
		RTS

	+	LDA $AE,x
		INC #2 : BMI +
		CMP #$50
		BCC $02 : LDA #$50
	+	STA $AE,x
		RTS

		..X
		dw $0010,$FFD0
		..X2
		db $08,$F8


	.Spray
		LDX !SpriteIndex
		LDA !RexChase
		BMI ..Main
		ORA #$80 : STA !RexChase
		LDA $9E,x
		BPL +
		EOR #$FF
		LSR A
		EOR #$FF
		BRA ++
	+	LSR A
	++	STA $9E,x
		LDA $AE,x
		BPL +
		EOR #$FF
		LSR A
		EOR #$FF
		BRA ++
	+	LSR A
	++	STA $AE,x

		..Main
		LDA $AE,x
		BEQ ..Y
		BPL +
		INC $AE,x
		BRA ..Y
	+	DEC $AE,x

		..Y
		LDA $9E,x
		CMP #$08
		BEQ ++
		BMI +
		DEC A
		BRA ++
	+	INC A
	++	SEC : SBC #$03
		STA $9E,x

		..CheckTimer
		LDA !Difficulty
		AND #$03 : BEQ ..Easy
		CMP #$01 : BEQ ..Normal

		..Insane
		LDA $14
		AND #$07 : BEQ ..Cast
		RTS

		..Normal
		LDA $14
	-	CMP #$0C
		BCC ..Return
		SBC #$0C
		BEQ ..Cast
		BRA -

		..Return
		RTS

		..Easy
		LDA $14
		AND #$0F : BNE ..Return

		..Cast
		LDA #$10 : STA !SPC1
		LDA #$03 : JMP QUICK_CAST


	.DashDirection
		LDA #$26 : STA !SPC4
		LDY #$10
		LDA $3320,x
		ROR #2
		EOR $AE,x
		BPL $02 : LDY #$0D	; -6
		TYA : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS


	.CircleCast
		LDA !Difficulty
		AND #$03
		TAY
		LDA #$01 : STA $2250
		LDA .SpellTable,y
		STA $2253
		LDA .SpellTable+3,y
		STA $0F

		LDY $34C0,x
		TYA
		INC A
		CMP #$48
		BNE $02 : LDA #$00
		STA $34C0,x

		STY $2251
		STZ $2252
		STZ $2254
		NOP
		BRA $00
		LDA $2308
		BNE ..Return

		LDY $2306
		LDA !RexAI
		AND #$C0
		BEQ ..InitMedium
		CMP #$80
		BCC ..Small
		BEQ ..InitMedium

		..Fire				; Clear both bits, fire projectile
		LDA ..Bits,y
		EOR #$FF
		AND $3390,x : STA $3390,x
		STA !AdeptCast
		PHY				;\
		LDA #$FF			; |
		STA $01				; |
		STA $03				; |
		LDY $34C0,x			; |
		LDA .SpellCircle+$12		; |
		STA $02				; |
		BMI $02 : STZ $03		; |
		TYA				; | Store coordinates in scratch RAM
		CLC : ADC #$12			; |
		TAY				; |
		LDA .SpellCircle		; |
		STA $00				; |
		BMI $02 : STZ $01		; |
		PLY				;/
		CPY $0F : BNE +			;\
		LDA #$FF : STA $34C0,x		; |
		LDA !RexAI			; | Disable circle cast and clear casting memory
		AND #$C0^$FF			; |
		STA !RexAI			;/

	+	LDA #$10 : STA !SPC1

		LDA !RexAI
		CLC : AND #$20
		ROL #4
		INC A
		JSR QUICK_CAST

		..Return
		RTS

		..Small				; Clear lo bit, set hi bit
		LDA ..Bits,y
		EOR #$FF
		AND $3390,x : STA $3390,x
		LDA ..Bits,y
		ORA !AdeptCast : STA !AdeptCast
		CPY $0F : BNE ..Return		;\
		LDA !RexAI			; |
		AND #$3F			; | Advance casting memory
		ORA #$80			; |
		STA !RexAI			;/
		RTS

		..InitMedium			; Set lo bit
		LDA ..Bits,y
		ORA $3390,x : STA $3390,x
		CPY $0F : BNE ..Return		;\
		LDA !RexAI			; | Set lo bit of casting memory
		ORA #$40			; |
		STA !RexAI			;/
		RTS



		..GetCoords
		STZ $0E				; > No tile written by default

		LDA !Difficulty			;\
		AND #$03			; | Y = Difficulty
		TAY				;/
		STZ $2250			; > Enable multiplication
		LDA .SpellTable,y		;\
		STA $2251			; | Multiplicand (0x48/projectile cap)
		STZ $2252			;/
		LDA $3390,x : STA $00		;\ Cast status
		LDA !AdeptCast : STA $01	;/
		LDA $34C0,x : STA $0F		; > Timer
		LSR #3				;\
		TAX				; | Determine large spell tile
		LDA .SpellTile,x		; |
		STZ $08				; |
		STA $09				;/
		LDX .SpellTable+3,y		; > Number of projectiles

	-	LDA ..Bits,x			;\
		AND $00 : STA $0C		; | Status of projectile
		LDA ..Bits,x			; |
		AND $01 : STA $0D		;/
		BNE +				;\ See if projectile exists
		LDA $0C : BEQ ++		;/
	+	STX $2253			;\ Multiplier (projectile ID)
		STZ $2254			;/
		INC $0E				;\ > Increment tiles written
		LDA $0F				; |
		SEC : SBC $2306			; | Index = t-(ID*MAX/0x48)
		BPL $03 : CLC : ADC #$48	; |
		TAY				;/
		REP #$20			; > A 16-bit
		LDA .SpellCircle-$01,y		;\
		AND #$FF00			; | Write prop + Xcoord to tilemap
		ORA #$003A			; |
		ORA !BigRAM+$7C			; > add status offset
		STA ($04)			;/
		PHX				;\
		LDX !SpriteIndex		; |
		LDA $3320,x			; |
		LSR A				; |
		BCS +				; | Account for Xflip
		LDA ($04)			; |
		EOR #$0040			; |
		STA ($04)			; |
		+				; |
		PLX				;/
		INC $04				;\ Increment pointer
		INC $04				;/
		LDA $0C				;\
		CMP #$0100 : BCC ..Tile1	; | Determine which tile should be used
		AND #$00FF : BEQ ..Tile2	;/

		..Tile3
		LDA $08
		BRA ..WriteTile

		..Tile2
		LDA #$4B00			;\ Get medium tile
		BRA ..WriteTile			;/

		..Tile1
		LDA #$4D00			; > Get small tile

		..WriteTile
		AND #$FF00
		CLC : ADC !BigRAM+$7A
		STA $0C				; > Save tile
		LDA .SpellCircle+$12,y		;\
		AND #$00FF			; | Write Ycoord + tile to tilemap
		ORA $0C				; |
		STA ($04)			;/
		INC $04				;\ Increment pointer
		INC $04				;/
		SEP #$20			; > A 8-bit

	++	DEX				;\ Loop
		BMI $03 : JMP -				;/
		LDX !SpriteIndex		; > Restore X
		RTS

		..Bits
		db $01,$02,$04,$08,$10,$20,$40,$80

	; $34C0: Timer
	; $3390: Status 1
	; !AdeptCast: Status 2
	; Cast timer loops at $48 ($47 -> $00). $FF = no cast.
	; Cast status:
	; 1: 12345678
	; 2: 12345678
	; Bit usage:
	;	00 - no orb
	;	01 - small orb
	;	10 - medium orb
	;	11 - big orb

	; Angle 0 = straight right
	; For Y coordinate (cosine), add $12 to index (wrapping at $48)


	.SpellCircle
		db $20,$20,$20,$1F	; 0-15
		db $1E,$1D,$1C,$1A	; 20-35
		db $19,$17,$15,$12	; 40-55
		db $10,$0E,$0B,$08	; 60-75
		db $06,$03		; 80-85
		db $00,$FD,$FA,$F8	; 90-105
		db $F5,$F2,$F0,$EE	; 110-125
		db $EB,$E9,$E7,$E6	; 130-145
		db $E4,$E3,$E2,$E1	; 150-165
		db $E0,$E0		; 170-175
		db $E0,$E0,$E0,$E1	; 180-195
		db $E2,$E3,$E4,$E6	; 200-215
		db $E7,$E9,$EB,$EE	; 220-235
		db $F0,$F2,$F5,$F8	; 240-255
		db $FA,$FD		; 260-265
		db $00,$03,$06,$08	; 270-285
		db $0B,$0E,$10,$12	; 290-305
		db $15,$17,$19,$1A	; 310-325
		db $1C,$1D,$1E,$1F	; 330-345
		db $20,$20		; 350-355
		db $20,$20,$20,$1F	; Extended cosine area
		db $1E,$1D,$1C,$1A	; -
		db $19,$17,$15,$12	; -
		db $10,$0E,$0B,$08	; -
		db $06,$03		; -

	.SpellTable
		db $12,$0C,$09		; Easy, Normal, Insane
		db $03,$05,$07

	.SpellTile
		db $45,$47,$49		; 00-17
		db $45,$47,$49		; 18-2F
		db $45,$47,$49		; 30-47


	.AnimIdle
		dw .IdleTM : db $08,$01		; 00
		dw .IdleDyn00
		dw .IdleTM : db $08,$02		; 01
		dw .IdleDyn01
		dw .IdleTM : db $08,$00		; 02
		dw .IdleDyn02
	.AnimHover
		dw .HoverTM : db $03,$04	; 03
		dw .HoverDyn00
		dw .HoverTM : db $03,$05	; 04
		dw .HoverDyn01
		dw .HoverTM : db $03,$03	; 05
		dw .HoverDyn02
	.AnimCast
		dw .CastTM : db $08,$07		; 06
		dw .CastDyn00
		dw .CastTM : db $06,$08		; 07
		dw .CastDyn01
		dw .AfterCastTM : db $04,$09	; 08
		dw .AfterCastDyn00
		dw .AfterCastTM : db $08,$08	; 09
		dw .AfterCastDyn01
	.AnimFDash
		dw .FDashTM : db $06,$0B	; 0A
		dw .DashDyn00
		dw .FDashTM : db $06,$0C	; 0B
		dw .DashDyn01
		dw .FDashTM : db $06,$0A	; 0C
		dw .DashDyn02
	.AnimBDash
		dw .BDashTM : db $06,$0E	; 0D
		dw .DashDyn00
		dw .BDashTM : db $06,$0F	; 0E
		dw .DashDyn01
		dw .BDashTM : db $06,$10	; 0F
		dw .DashDyn02
	.AnimGrind
		dw .GrindTM00 : db $03,$11	; 10
		dw .DashDyn00
		dw .GrindTM01 : db $03,$12	; 11
		dw $0000
		dw .GrindTM02 : db $03,$13	; 12
		dw .DashDyn01
		dw .GrindTM03 : db $03,$14	; 13
		dw $0000
		dw .GrindTM04 : db $03,$15	; 14
		dw .DashDyn02
		dw .GrindTM05 : db $03,$10	; 15
		dw $0000


	.IdleTM
		dw $0004
		db $31,$FE,$F0,$E6
		dw $0010
		db $31,$FC,$F0,$C0
		db $31,$04,$F0,$C1
		db $31,$FC,$00,$E0
		db $31,$04,$00,$E1

	.CastTM
		dw $0004
		db $31,$00,$F0,$E6
		dw $0018
		db $31,$F4,$F0,$C0
		db $31,$04,$F0,$C2
		db $31,$0C,$F0,$C3
		db $31,$F4,$00,$E0
		db $31,$04,$00,$E2
		db $31,$0C,$00,$E3

	.AfterCastTM
		dw $0004
		db $31,$FE,$F0,$E6
		dw $0010
		db $31,$F8,$F0,$C0
		db $31,$08,$F0,$C2
		db $31,$F8,$00,$E0
		db $31,$08,$00,$E2

	.HoverTM
		dw $0004
		db $31,$FE,$F0,$E6
		dw $001C
		db $31,$00,$F0,$C6
		db $31,$F0,$F8,$C0
		db $31,$00,$F8,$C2
		db $31,$10,$F8,$C4
		db $31,$F0,$00,$D0
		db $31,$00,$00,$D2
		db $31,$10,$00,$D4

	.FDashTM
		dw $0004
		db $31,$FE,$F0,$E6
		dw $001C
		db $31,$00,$F0,$C6
		db $71,$F0,$F8,$C0
		db $71,$00,$F8,$C2
		db $71,$08,$F8,$C3
		db $71,$F0,$00,$D0
		db $71,$00,$00,$D2
		db $71,$08,$00,$D3

	.BDashTM
		dw $0004
		db $31,$FE,$F0,$E6
		dw $001C
		db $31,$00,$F0,$C6
		db $31,$F0,$F8,$C0
		db $31,$00,$F8,$C2
		db $31,$08,$F8,$C3
		db $31,$F0,$00,$D0
		db $31,$00,$00,$D2
		db $31,$08,$00,$D3


	; these should use GFX index 0x83 (conjurex)
	; upload them to hi prio OAM before loading the FDash tilemap
	.GrindTM00
		db $0C,$83
		db $3C,$0C,$FC,$45
		db $3C,$0C+$0C,$FC-$06,$4D	; 3
		db $3C,$0C+$06,$FC+$00,$4B	; 1
						; 5
	.GrindTM01
		db $0C,$83
		db $3C,$0C,$FC,$45
		db $3C,$0C+$10,$FC-$08,$4D	; 4
		db $3C,$0C+$0C,$FC+$00,$4B	; 2
						; 6
	.GrindTM02
		db $0C,$83
		db $3C,$0C,$FC,$47
						; 5
		db $3C,$0C+$12,$FC+$00,$4D	; 3
		db $3C,$0C+$04,$FC+$02,$4B	; 1
	.GrindTM03
		db $0C,$83
		db $3C,$0C,$FC,$47
						; 6
		db $3C,$0C+$18,$FC+$00,$4D	; 4
		db $3C,$0C+$08,$FC+$04,$4B	; 2
	.GrindTM04
		db $0C,$83
		db $3C,$0C,$FC,$49
		db $3C,$0C+$04,$FC-$02,$4B	; 1
						; 5
		db $3C,$0C+$0C,$FC+$06,$4D	; 3
	.GrindTM05
		db $0C,$83
		db $3C,$0C,$FC,$49
		db $3C,$0C+$08,$FC-$04,$4B	; 2
						; 6
		db $3C,$0C+$10,$FC+$08,$4D	; 4



	.AngryMask
		dw $0004
		db $3A,$00,$00,$E8-8


	.Pal
	dw $7FFF,$0000,$1831,$2057,$1C7E,$3C86,$60E9,$7D2B
	dw $1984,$2A87,$114C,$1DB2,$2635,$0000,$0000

	.AltPal
	dw $7FFF,$0000,$28A0,$30E1,$4961,$0016,$00BB,$013C
	dw $4498,$653B,$416B,$49EF,$62B5,$0000,$0000

	.StatuePal
	dw $6319,$0000,$1CE7,$294A,$39CE,$1CE7,$294A,$39CE
	dw $318C,$4E73,$1084,$14A5,$2108,$0000,$0000



macro AdeptDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20
	dw <DestVRAM>*$10+$6000
endmacro



	.IdleDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $000, $1C0)
	%AdeptDyn(3, $010, $1D0)
	%AdeptDyn(3, $020, $1E0)
	%AdeptDyn(3, $030, $1F0)
	..End
	.IdleDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $000, $1C0)
	%AdeptDyn(3, $010, $1D0)
	%AdeptDyn(3, $003, $1E0)
	%AdeptDyn(3, $013, $1F0)
	..End
	.IdleDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $000, $1C0)
	%AdeptDyn(3, $010, $1D0)
	%AdeptDyn(3, $023, $1E0)
	%AdeptDyn(3, $033, $1F0)
	..End


	.CastDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $006, $1C0)
	%AdeptDyn(5, $016, $1D0)
	%AdeptDyn(5, $026, $1E0)
	%AdeptDyn(5, $036, $1F0)
	..End
	.CastDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $00B, $1C0)
	%AdeptDyn(5, $01B, $1D0)
	%AdeptDyn(5, $02B, $1E0)
	%AdeptDyn(5, $03B, $1F0)
	..End


	.AfterCastDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(4, $040, $1C0)
	%AdeptDyn(4, $050, $1D0)
	%AdeptDyn(4, $060, $1E0)
	%AdeptDyn(4, $070, $1F0)
	..End
	.AfterCastDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(4, $080, $1C0)
	%AdeptDyn(4, $090, $1D0)
	%AdeptDyn(4, $0A0, $1E0)
	%AdeptDyn(4, $0B0, $1F0)
	..End


	.HoverDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(6, $044, $1C0)
	%AdeptDyn(6, $054, $1D0)
	%AdeptDyn(6, $064, $1E0)
	%AdeptDyn(2, $0C0, $1C6)
	%AdeptDyn(2, $0D0, $1D6)
	..End
	.HoverDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(6, $04A, $1C0)
	%AdeptDyn(6, $05A, $1D0)
	%AdeptDyn(6, $06A, $1E0)
	%AdeptDyn(2, $0C2, $1C6)
	%AdeptDyn(2, $0D2, $1D6)
	..End
	.HoverDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(6, $074, $1C0)
	%AdeptDyn(6, $084, $1D0)
	%AdeptDyn(6, $094, $1E0)
	%AdeptDyn(2, $0D4, $1C6)
	%AdeptDyn(2, $0D6, $1D6)
	..End


	.DashDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $07A, $1C0)
	%AdeptDyn(5, $08A, $1D0)
	%AdeptDyn(5, $09A, $1E0)
	%AdeptDyn(2, $0C0, $1C6)
	%AdeptDyn(2, $0D0, $1D6)
	..End
	.DashDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $0A4, $1C0)
	%AdeptDyn(5, $0B4, $1D0)
	%AdeptDyn(5, $0C4, $1E0)
	%AdeptDyn(2, $0C2, $1C6)
	%AdeptDyn(2, $0D2, $1D6)
	..End
	.DashDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $0A9, $1C0)
	%AdeptDyn(5, $0B9, $1D0)
	%AdeptDyn(5, $0C9, $1E0)
	%AdeptDyn(2, $0D4, $1C6)
	%AdeptDyn(2, $0D6, $1D6)
	..End



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

		LDA $3320,x : JSL !Update3DCluster

		REP #$20
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSR LOAD_TILEMAP
		RTS

	; DO NOTE flow into GFX here! we need to call GFX before updating the 3D cluster and loading tilemap

		.GFX
		PHP

		SEP #$20
		LDA $AE,x
		ASL A
		ROL A
		AND #$01
		CMP $3320,x : BEQ ..calc
		REP #$20
		BRA ..idle

	..calc	LDA $AE,x
		BPL $03 : EOR #$FF : INC A
		REP #$20
		AND #$00FF
		CMP #$0010 : BCC ..dash
	..dash	LDA #$0000 : STA !3D_Extra+$00
		LDA.w #.BigMaskDynDash : BRA ..set
	..idle	LDA $3320,x : STA !3D_Extra+$00
		LDA.w #.BigMaskDynIdle
	..set	STA $0C
		CLC : JSL !UpdateGFX
		PLP
		RTS

		.Init
		PHX
		LDX #$00
	-	LDA.w .Start,x : STA.l !3D_Base,x
		INX
		CPX.b #.End-.Start : BCC -

		PLX
		JSR .GFX

		RTS


		.BigMaskDynIdle
		dw ..End-..Start
		..Start
		%AdeptDyn(4, $100, $1C0)	;\
		%AdeptDyn(4, $110, $1D0)	; | big mask
		%AdeptDyn(4, $120, $1C4)	; |
		%AdeptDyn(4, $130, $1D4)	;/
		%AdeptDyn(8, $0E0, $1E0)	;\ small masks
		%AdeptDyn(8, $0F0, $1F0)	;/
		..End

		.BigMaskDynDash
		dw ..End-..Start
		..Start
		%AdeptDyn(4, $104, $1C0)	;\
		%AdeptDyn(4, $114, $1D0)	; | big mask
		%AdeptDyn(4, $124, $1C4)	; |
		%AdeptDyn(4, $134, $1D4)	;/
	;	%AdeptDyn(8, $0E0, $1E0)	;\ small masks
	;	%AdeptDyn(8, $0F0, $1F0)	;/
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
		db $39,$F8,$F8,$C0
		db $39,$08,$F8,$C2
		db $39,$F8,$08,$C4
		db $39,$08,$08,$C6
		.BigMaskX
		dw $0010
		db $79,$F8,$F8,$C0
		db $79,$08,$F8,$C2
		db $79,$F8,$08,$C4
		db $79,$08,$08,$C6
		.Mask1
		dw $0004
		db $35,$00,$00,$E0
		.Mask2
		dw $0004
		db $35,$00,$00,$E2
		.Mask3
		dw $0004
		db $35,$00,$00,$E4
		.Mask4
		dw $0004
		db $35,$00,$00,$E6



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


;=================;
;REX HELP ROUTINES;
;=================;
; special code... that is really not that great
; i should have planned this better from the start
AddTilemap:	PHX
		REP #$20
		LDA ($04)
		XBA
		SEP #$20
		CMP #$6C : BNE +
		LDY !ExtraProp1,x : BEQ +
		INC A				; add 1 to GFX index if item is held
	+	TAX
		LDA !GFX_status,x
		AND #$70
		ASL A
		STA $03
		LDA !GFX_status,x
		AND #$0F
		TSB $03
		LDA !GFX_status,x
		ASL A
		ROL A
		AND #$01
		STA $02
		PLX
		LDA $33C0,x
		AND #$0E
		TSB $02
		LDA #$00			; special directional offset
		LDY $BE,x : BEQ +
		LDY $3320,x : BNE +
		LDA #$04
	+	STA $00
		STZ $01
		LDA !SpriteAnimIndex
		CMP #$03 : BEQ +
		CMP #$07 : BNE ++
	+	DEC $01
	++	REP #$20
		LDA $04

		PHY
		PHX
		PHP
		SEP #$10
		REP #$20
		LDX $06 : BNE .NotInit
		STZ !BigRAM+0
		.NotInit
		STA $04
		LDY #$00
		LDA ($04)
		AND #$00FF			; tilemap can not be larger than 256 bytes
		STA $08
		CLC : ADC !BigRAM+0
		STA !BigRAM+0
		INC $04
		LDA ($04)			; > get hi byte of header (GFX status to add)
		INC $04
		SEP #$20

	.Loop	LDA ($04),y			;\
		EOR $02				; | Prop
		STA !BigRAM+2,x			; |
		INY				;/
		LDA ($04),y			;\
		CLC : ADC $00			; | X
		STA !BigRAM+3,x			; |
		INY				;/
		LDA ($04),y			;\
		CLC : ADC $01			; | Y
		STA !BigRAM+4,x			; |
		INY				;/
		LDA ($04),y			;\
		CLC : ADC $03			; | Tile
		STA !BigRAM+5,x			; |
		INY				;/
		INX #4
		CPY $08 : BCC .Loop
		STX $06

		PLP
		PLX
		PLY

		SEP #$20

		RTS


REX_BEHAVIOUR:
		LDA !AggroRexIFrames		;\ Decrement timer
		BEQ $03 : DEC !AggroRexIFrames	;/

		LDA $33C0,x			;\
		AND #$0E			; | golden bandit does not despawn
		CMP #$04 : BEQ .NoDespawn	;/
		JSR SPRITE_OFF_SCREEN
		.NoDespawn

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE .Return
		LDA $32F0,x			; Load death timer
		BEQ .Process
		STA $3390,x
		DEC A
		BNE .Return
		STZ $3230,x
.Return		RTS

.Process	LDA !RexAI
		AND #$10
		BEQ .NoCast
		JSR SHAMAN_CAST
		.NoCast


		LDA $BE,x : BNE .NoHammer
		LDA !RexAI
		AND #$02 : BEQ .NoHammer
		JSR REX_HAMMER
		LDA !SpriteAnimIndex
		CMP #$0D
		BCC .NoHammer
		BNE .NoHammer
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		JMP .DontTurn
		.NoHammer

		BIT !RexAI : BVC .Chasing
		LDA !RexChase			;\ Skip if chase timer is clear
		BEQ .NoChaseInit		;/
		JSR SUB_HORZ_POS		;\
		TYA				; | Rex faces player
		STA $3320,x			;/
		DEC !RexChase			; > Decrement chase timer
		LDA !RexChase			;\
		BNE .NoChaseInit		; |
		LDA !RexMovementFlags		; | Set chase flag when the timer reaches zero
		ORA #$40			; |
		STA !RexMovementFlags		;/
		.NoChaseInit

		LDA !RexChase : BNE .Chasing
		LDA !RexMovementFlags		;\
		AND #$42			; |
		BEQ +				; |
		LDA !RexAI			; \
		AND.b #$20^$FF			;  | Disable turn and enable jump
		ORA #$01			;  |
		STA !RexAI			; /
		BRA .Chasing			; |
	+	JSR REX_SIGHT			; | Look for players
		BCC .Chasing			; |
		TAY				; |
		LDA .ChaseFlags-1,y		; |
		ORA !RexMovementFlags		; |
		STA !RexMovementFlags		; |
		LDA #$25			; \ Roar
		STA !SPC1			; /
		LDA #$1F			; |
		STA !RexChase			;/
		.Chasing

		LDA !RexAI
		LSR A : BCC .NoJumping
		LDA !RexMovementFlags
		LSR A : BCS .NoJumping
		LDA $3330,x
		AND #$04 : BNE .NoJumping

		LDA !RexMovementFlags		;\
		AND #$60			; |
		CMP #$40 : BCC +		; |
		AND #$20			; |
		ASL #2				; |
		TAY				; | Drop if chasing someone down a ledge
		LDA $3210,x			; |
		CMP !P2YPosLo-$80,y		; |
		LDA $3240,x			; |
		SBC !P2YPosHi-$80,y		; |
		LDA #$00			; |
		BCC .Drop			;/

	+	LDA #$C0			;\
	.Drop	STA $9E,x			; |
		LDA !RexMovementFlags		; | Initiate jump
		ORA #$01			; |
		STA !RexMovementFlags		;/
		.NoJumping

		LDA $3330,x : PHA		; > Preserve last frame's collision flags
		AND #$04			;\
		BEQ +				; |
		LDA !RexMovementFlags		; | Clear jump and getup flags when touching the ground
		AND.b #$05^$FF			; |
		STA !RexMovementFlags		; |
		+				;/

		BIT !RexMovementFlags		;\
		BPL +				; |
		LDA $3330,x			; |
		AND #$03			; |
		BNE +				; | Update climb status
		LDA !RexMovementFlags		; |
		ORA #$04			; |
		AND.b #$80^$FF			; |
		STA !RexMovementFlags		; |
		LDA #$E0			; |
		STA $9E,x			; |
		+				;/

		LDA $3330,x					;\
		AND #$04					; | Use committed jump arcs
		BEQ .NoFollow					;/
		TXA						;\
		CLC : ADC $14					; | see if it's time to turn
		AND #$0F : BNE .NoFollow			;/
		BIT !RexMovementFlags : BVC .NoFollow		; > see if chase is on
		LDA $3240,x : XBA				;\
		LDA $3210,x					; |
		REP #$20					; |
		STA $0E						; |
		STZ $02						; |
		LDA !MultiPlayer				; |
		AND #$00FF : BEQ +				; | calculate vertical distance to players
		LDA $0E						; |
		SEC : SBC !P2YPosLo				; |
		STA $02						; |
	+	LDA $0E						; |
		SEC : SBC !P2YPosLo-$80				; |
		STA $00						; |
		SEP #$20					;/
		LDA !RexMovementFlags				;\
		AND #$20 : BEQ +				; |
		BIT $03 : BMI .Flw2				; |
		LDA $02						; |
		CMP #$40 : BCS .NoFollow			; |
	.Flw2	JSR SUB_HORZ_POS_2				; |
		BRA ++						; | follow target player
	+	BIT $01 : BMI .Flw1				; |
		LDA $00						; |
		CMP #$40 : BCS .NoFollow			; |
	.Flw1	JSR SUB_HORZ_POS				; |
	++	TYA						; |
		STA $3320,x					; |
		.NoFollow					;/

		LDY $3320,x
		BIT !RexMovementFlags
		BVC +
		LDA !Difficulty
		AND #$03
		ASL A
		CLC : ADC $3320,x
		TAY
		INY #4
		BRA .Slow
	+	LDA $BE,x
		BEQ .Slow
		INY #2
.Slow		LDA !RexAI			;\
		ORA !RexMovementFlags		; | If movement is disabled, don't move
		AND #$08			; |
		BNE +				;/


		BIT !RexMovementFlags		;\
		BVC .NormalSpeed		; | Use normal speed unless chasing and on the ground
		LDA $3330,x			; |
		AND #$04 : BEQ .NormalSpeed	;/
		PEA.w .SpeedReturn-1		;\
		LDA.w REX_BEHAVIOUR_XSpeed,y	; | Accelerate
		JMP AccelerateX			;/

.NormalSpeed	LDA.w .XSpeed,y
		STA $AE,x
.SpeedReturn	LDA $3330,x
		AND #$04
		BEQ +

		LDA !RexMovementFlags
		AND #$02
		BEQ +
		PEA .Freeze-1
		JMP REX_AMBUSH
		+

		LDA !RexChase			;\
		BEQ +				; | Don't move during chase init
		STZ $9E,x			; |
		LDA #$04 : STA $3330,x
		BRA .Freeze			;/

	+	STZ $00				; Clear slope data
		LDA $34D0,x			;\ Don't move while this is set
		BNE .Freeze			;/
		LDA !RexAI
		AND #$02
		BEQ .NoFreeze
		LDA !SpriteAnimIndex		;\
		CMP #$0D : BEQ .Fall		; |
		CMP #$0E : BNE .NoFreeze	; | only apply Y speed while preparing to throw hammer
.Fall		STZ $AE,x			; |
		BRA .ApplySpeed			;/
.NoFreeze	LDA $3370,x			;\
		BEQ .ApplySpeed			; | YSpeed is always 0x10 on slopes
		LDA #$10 : STA $9E,x		;/
.ApplySpeed	BIT !RexMovementFlags : BPL +	;\
		PHX				; |
		LDA !Difficulty			; |
		AND #$03 : TAX			; | Yspeed is based on difficulty
		LDA .ClimbSpeed,x		; |
		PLX				; |
		STA $9E,x			;/
	+	LDA $3330,x
		AND #$08
		BEQ +
		LDA #$10
		STA $9E,x
	+	JSL !SpriteApplySpeed		; > Apply speed
.Freeze		BIT !RexMovementFlags		;\
		BPL +				; | Lock Xpos during climb
		LDA !RexWallX			; |
		STA $3220,x			;/
	+	PLA : STA $01			; > Store last frame's collision flags
		LDA !RexAI			;\ Don't turn if movement is disabled
		AND #$08 : BNE .DontTurn	;/
		LDA $3330,x			;\
		AND #$03			; |
		BEQ +				; | Always turn at walls, unless climbing is enabled
		BIT !RexAI			; |
		BPL .Turn			; |
		JMP .ClimbInit			;/
	+	LDA !RexAI			;\
		AND #$20			; | Don't turn if AI doesn't allow it
		BEQ .DontTurn			;/
		LDA $3330,x			;\
		AND #$04			; |
		BNE .DontTurn			; | Turn around at the first frame in midair
		LDA $01				; |
		AND #$04			; |
		BEQ .DontTurn			;/
.Turn		LDA $3320,x			;\
		EOR #$01			; | Turn around
		STA $3320,x			;/
		INC $32B0,x			; > Set ledge flag
		LDY $3320,x			;\
		LDA.w .XSpeed+2,y		; |
		STA $AE,x			; | Revert speed application
		STZ $9E,x			; |
		JSL !SpriteApplySpeed		;/
.DontTurn	LDA $3330,x			;\
		AND #$0F			; |
		BEQ .NoTouch			; |
		LDA !RexMovementFlags		; | Clear knockback flag when touching something
		AND.b #$08^$FF			; |
		STA !RexMovementFlags		;/
.NoTouch	JSL $018032			; Interact with other sprites
		JSL $01A7DC			; Check for Mario contact
		BCS $01				;\ Return if no contact
	-	RTS				;/

		LDA $7490 : BEQ .NoStar
		JMP SPRITE_STAR
.NoStar		LDA $32E0,x : BNE -
		LDA #$08 : STA $32E0,x
		LDA !MarioYSpeed
		BMI .HurtMario
		CMP #$10
		BCC .HurtMario

.HurtRex	STZ $32D0,x
		LDY #$00 : JSR StompSound	; Play sound
		JSL $01AA33			; Give Mario some bounce
		JSL $01AB99			; Display contact GFX
		LDA $740D
		ORA $787A
		BEQ .NoSpinKill
		LDA !RexAI			;\
		AND #$04			; |
		BEQ +				; | Brutes can only be spin-killed on easy
		LDA !Difficulty			; |
		AND #$03			; |
		BNE .NoSpinKill			;/
	+	JMP REX_SPINKILL

.HurtMario	LDA $7497 : BNE .NoContact
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		JSL $00F5B7			; Hurt Mario
		RTS

.NoSpinKill	LDA !AggroRexIFrames : BEQ +	; > No damage during I-frames
		LDA #$02 : STA !SPC1
		BRA ++

	+	LDA !RexAI			;\
		AND #$04 : BEQ .HurtRexFire	; | Brutes get some I-frames
		LDA #$40 : STA !AggroRexIFrames	;/
		LDA #$20 : STA !SPC1		; > Ow! sound
.HurtRexFire	STZ $32D0,x
		INC $BE,x			; > 1 damage from jump
		LDA #$18 : STA $34D0,x		; Hit stun
	++	LDA !RexAI			;\
		AND.b #$08^$FF			; | Enable movement after rex is hit
		STA !RexAI			;/
		AND #$04
		BEQ .NoBrute
		LDA $BE,x
		CMP #$03
		BCS .Kill
.NoContact	RTS

.NoBrute	LDA $BE,x
		CMP #$02
		BCC .SmushRex
.Kill		LDA #$20
		STA $32F0,x
		RTS
.SmushRex	LDA #$0C : STA $34D0,x
		STZ $3450,x
		STZ $32D0,x
		RTS

.ClimbInit	LDA $3330,x
		AND #$08
		BEQ +
		LDA $3320,x
		EOR #$01
		STA $3320,x
		TAY
		LDA.w .XSpeed,y
		STA $AE,x
		JMP .DontTurn
	+	LDA $3210,x			;\
		SEC : SBC #$08			; |
		SEC : SBC !P2YPosLo-$80		; | Don't jump until at a proper height
		LDA $3240,x			; |
		SBC !P2YPosHi-$80		; |
		BPL ++				;/
		LDA $3220,x
		SEC : SBC !P2XPosLo-$80
		LDA $3250,x
		SBC !P2XPosHi-$80
		PHP
		LDA $3320,x
		BNE .WallLeft
.WallRight	PLP
		BMI +
		BIT !RexMovementFlags
		BVC +
		LDA $3320,x
		EOR #$01
		STA $3320,x
		JMP REX_WALLJUMP
	+	LDA #$20
		STA $AE,x
		BRA ++
.WallLeft	PLP
		BPL +
		BIT !RexMovementFlags
		BVC +
		LDA $3320,x
		EOR #$01
		STA $3320,x
		JMP REX_WALLJUMP
	+	LDA #$E0
		STA $AE,x
	++	LDA !RexMovementFlags
		ORA #$80
		STA !RexMovementFlags
		LDA $3220,x
		STA !RexWallX
		JMP .DontTurn

.XSpeed		db $08,$F8			; Walking
		db $10,$F0			; Walking, injured
		db $18,$E8			; Charging, easy
		db $1C,$E4			; Charging, normal
		db $20,$E0			; Charging, insane

.ChaseFlags	db $00,$00,$20,$00

.ClimbSpeed	db $E8,$DC,$D0,$D0		; indexed by difficulty&3


REX_SPINKILL:	LDA #$04
		STA $3230,x
		LDA #$1F
		STA $32D0,x
		JSL $07FC3B
		LDA #$08
		STA !SPC1
		RTS


REX_HORZ_POS:	STZ $06
		LDA !P2XPosLo-$80
		SEC : SBC $3220,x
		LDA !P2XPosHi-$80
		SBC $3250,x
		BPL .Return
		INC $06
.Return		RTS



REX_AMBUSH:	STZ $0B				; > Reset direction
		LDA $3220,x : STA $0C		;\
		LDA $3250,x : STA $0D		; | Copy positions to scratch RAM
		LDA $3210,x : STA $0E		; |
		LDA $3240,x : STA $0F		;/
		LDA !P2Status-$80
		BNE .P2
.P1		REP #$20
		LDA !P2YPosLo-$80
		CLC : ADC #$0028
		CMP $0E
		BCC .P2_16
		LDA !P2XPosLo-$80
		SEC : SBC $0C
		BPL $05 : EOR #$FFFF : INC $0B
		CMP #$0038
		BCS .P2_16
		PLA				; > Pop return address
		SEP #$20			; > A 8 bit
		LDY $0B
		LDA.w .XSpeed,y
		STA $AE,x
		LDA #$D8
		STA $9E,x
		LDA #$25
		STA !SPC1
		LDA !RexMovementFlags		;\
		ORA #$41			; | End ambush and chase P1
		AND.b #$22^$FF			; |
		STA !RexMovementFlags		;/
		JMP REX_BEHAVIOUR_ApplySpeed
.P2_16		SEP #$20
.P2		LDA !P2Status
		CMP #$02
		BEQ .Return

		LDA !P2YPosLo
		CLC : ADC #$28
		SEC : SBC $0E
		LDA !P2YPosHi
		SBC $0F
		BCC .Return16
		REP #$20
		LDA !P2XPosLo
		SEC : SBC $0C
		BPL $05 : EOR #$FFFF : INC $0B
		CMP #$0038
		BCS .Return16
		PLA
		SEP #$20
		LDY $0B
		LDA.w .XSpeed,y
		STA $AE,x
		LDA #$D8
		STA $9E,x
		LDA #$25
		STA !SPC1
		LDA !RexMovementFlags		;\
		ORA #$61			; | End ambush and chase P2
		AND.b #$02^$FF			; |
		STA !RexMovementFlags		;/
		JMP REX_BEHAVIOUR_ApplySpeed
.Return16	SEP #$20
.Return		RTS

.XSpeed		db $40,$C0


; If the result is carry = 0, then neither player was seen.
; If carry = 1 and A = 0, P1 was seen.
; If carry = 1 and A = 1, P2 was seen.
;
REX_SIGHT:	LDA #$7F			;\ Sight box width
		STA $06				;/
		LDA #$20			;\ Sight box height
		STA $07				;/
		LDA $3220,x			;\
		STA $04				; |
		LDA $3250,x			; |
		STA $0A				; |
		LDA $3210,x			; | Sight box coords
		SEC : SBC #$18			; |
		STA $05				; |
		LDA $3240,x			; |
		SBC #$00			; |
		STA $0B				;/
		LDA $3320,x			;\
		BEQ +				; |
		LDA $04				; |
		SEC : SBC #$80			; | Move sightbox 0x80 pixels left if facing left
		STA $04				; |
		BCS $02 : DEC $0A		;/
	+	SEC : JSL !PlayerClipping	; > Check for contact with players
		RTS
.Return		CLC
		RTS


REX_WALLJUMP:	LDA #$B0
		STA $9E,x
		LDA $3330,x
		AND.b #$03^$FF
		STA $3330,x
		LDA $AE,x
		BPL .Left
.Right		LDA #$20
		STA $AE,x
		JMP REX_BEHAVIOUR_DontTurn
.Left		LDA #$E0
		STA $AE,x
		JMP REX_BEHAVIOUR_DontTurn


REX_HAMMER:	LDA $32D0,x
		BNE .Return
		LDA $BE,x
		BNE .Return
		LDA.l !Difficulty		;\
		AND #$03			; |
		TAY				; |
		LDA !RNG			; | Wait a random number of frames
		ADC !SpriteIndex		; |
		LSR #2				; |
		CLC : ADC #$23			; |
		CLC : ADC.w .ThrowDelay,y	; |
		STA $32D0,x			;/
		LDA #$0D : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		RTS
.Prep		LDA $BE,x
		BNE .Return
		LDY #$EE
		JSR REX_HORZ_POS
		LDA $06
		BNE +
		LDY #$12
	+	STY $00
		LDY #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ .Throw
		DEY : BPL -
.Return		RTS

.ThrowDelay	db $4F,$3F,$27			; EASY, NORMAL, INSANE

.Throw		LDA #$04+!ExtendedOffset	;\ Extended sprite number
		STA !Ex_Num,y			;/
		LDA $14				;\
		LSR A				; |
		LDA $3320,x			; | default state (hammer belongs to enemy) + direction
		BEQ $02 : LDA #$40		; | +50% chance to spawn half a rotation ahead
		EOR #$40			; |
		BCC $02 : ORA #$80		; |
		STA !Ex_Data3,y			;/
		PHY				;\
		LDA $3320,x			; |
		TAY				; |
		LDA $3220,x			; |
		CLC				; |
		ADC.w .X1,y			; |
		PLY				; | Xpos
		STA !Ex_XLo,y			; |
		PHY				; |
		LDA $3320,x			; |
		TAY				; |
		LDA $3250,x			; |
		ADC.w .X2,y			; |
		PLY				; |
		STA !Ex_XHi,y			;/
		LDA $3210,x			;\
		SEC : SBC #$01			; |
		STA !Ex_YLo,y			; | Ypos
		LDA $3240,x			; |
		SBC #$00			; |
		STA !Ex_YHi,y			;/
		LDA !RNG			;\
		ADC !SpriteIndex		; |
		AND #$80			; |
		ORA.b #!P2YPosLo-$80		; | Target a random player
		STA $00				; |
		LDA.b #!P2Base>>8 : STA $01	;/
		LDA $3240,x			;\
		XBA				; |
		LDA $3210,x			; |
		REP #$20			; |
		SEC : SBC ($00)			; |
		LSR #2				; |
		SEP #$20			; | Yspeed
		EOR #$FF			; |
		INC A				; |
		CLC : ADC #$C8			; |
		CMP #$C0			; |
		BCS +				; |
		LDA #$C0			; |
	+	STA !Ex_YSpeed,y		;/
		LDA $00				;\
		SEC : SBC #$04			; | Update pointer
		STA $00				;/
		LDA $3250,x			;\
		XBA				; |
		LDA $3220,x			; |
		REP #$20			; |
		SEC : SBC ($00)			; | Xspeed
		LSR #2				; |
		SEP #$20			; |
		EOR #$FF			; |
		INC A				; |
		STA !Ex_XSpeed,y		;/
		RTS				; > Return
.X1		db $0C,$F4
.X2		db $00,$FF


SHAMAN_CAST:	LDA !Difficulty			;\
		AND #$03			; | Y = difficulty index
		TAY				;/
		LDA !ShamanCast : BEQ .Fire
		CMP .CastTime,y : BCC .Cast
		LDA !SpriteAnimIndex
		CMP #$09 : BCC .Return
		CMP #$0C : BCS .Return
		LDA #$01
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
.Return		RTS

.Fire		LDA !RNG			;\
		ADC !SpriteIndex		; |
		LSR #2				; | Wait a random number of frames
		CLC : ADC #$94			; |
		STA !ShamanCast			;/
		LDA #$01 : STA !SpriteAnimIndex	;\ Reset animation
		STZ !SpriteAnimTimer		;/
		BRA .Spawn

.Cast		LDA #$09			;\
		CMP !SpriteAnimIndex		; |
		BCC .Return			; | Start cast animation
		BEQ .Return			; |
		STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer		;/
		RTS


.Spawn		JSL $02A9DE
		BMI .Return

		LDA $3320,x
		BNE .Left

.Right		LDA $3220,x			;\
		CLC : ADC #$10			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		ADC #$00			; |
		STA $3250,y			; |
		BRA .Shared			; | Xpos = 12px in front (4px overlap)
.Left		LDA $3220,x			; |
		SEC : SBC #$10			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		SBC #$00			; |
		STA $3250,y			;/
.Shared		LDA $3210,x			;\
		SEC : SBC #$0C			; |
		STA $3210,y			; | Ypos = 8px above
		LDA $3240,x			; |
		SBC #$00			; |
		STA $3240,y			;/
		LDA !SpriteTile,x : STA !SpriteTile,y
		LDA !SpriteProp,x : STA !SpriteProp,y
		PHX
		TYX
		LDA #$07 : STA !NewSpriteNum,x	;\  > Custom sprite number
		LDA #$36 : STA $3200,x		; | > Sprite number
		LDA #$08 : STA $3230,x		; | > Sprite status
		JSL $07F7D2			; | \ Clear tables
		JSL $0187A7			; | /
		LDA #$08 : STA !ExtraBits,x	;/  > Custom sprite flag
		LDA #$08			;\ Don't interact with sprites for 8 frames
		STA $3300,y			;/
		LDA #$3C : STA $32D0,y		; > Life timer (1 sec)
		LDA #$82 : STA $BE,x		; > Behaviour (line + anim)
		LDA #$03 : STA $33E0,x		; > Number of frames (3)
		LDA #$05 : STA $3310,x		; > Animation frequency
		STX $00
		PLX
		LDA #$45			;\
		CLC : ADC !SpriteTile,x		; | Base tile
		STA $33D0,y			;/
		LDY $3320,x			;\
		LDA DROP_MASK_MaskProp,y	; |
		AND #$F0
		ORA #$0A
		ORA !SpriteProp,x		; |
		PHA				; |
		LDA .CastXSpeed,y		; |
		LDY $00				; | Get projectile prop + speed
		STA $30AE,y			; |
		PLA				; |
		STA $33C0,y			; |
		LDA #$01 : STA $3410,y		;/

.Return2	RTS

.CastTime	db $40,$30,$20			; EASY, NORMAL, INSANE
.CastXSpeed	db $20,$E0			; Right, left


DROP_MASK:	LDA !RexMovementFlags		;\
		AND.b #$10^$FF			; | Drop mask
		STA !RexMovementFlags		;/

		LDA !RNG			;\
		ADC !SpriteIndex		; |
		LSR #2				; | Reset spell cast
		CLC : ADC #$94			; |
		STA !ShamanCast			;/

.Spawn		JSL $02A9DE			;\ Get sprite slot
		BMI SHAMAN_CAST_Return2		;/

		JSR SPRITE_A_SPRITE_B_COORDS	; Ypos is overwritten later anyway
		LDA $3210,x			;\
		SEC : SBC #$0E			; |
		STA $3210,y			; | Spawn 0x0E px above
		LDA $3240,x			; |
		SBC #$00			; |
		STA $3240,y			;/

		LDA !SpriteTile,x : STA !SpriteTile,y
		LDA !SpriteProp,x : STA !SpriteProp,y

		LDA !ShamanMask
		TAX
		LDA NoviceShaman_MaskTile,x
		PHY
		PHA
		LDA #$07			;\  > Custom sprite number
		TYX				; | > X = new sprite index
		STA !NewSpriteNum,x		; |
		LDA #$36			; | > Acts like
		STA $3200,x			; |
		LDA #$08			; | > MAIN routine
		STA $3230,x			; |
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08			; |
		STA !ExtraBits,x		;/
		LDA #$5F			;\ Life timer
		STA $32D0,x			;/
		PLA				;\
		CLC : ADC !SpriteTile,x		; | GFX tile
		STA $33D0,x			;/
		LDA #$E0			;\ Set some Y speed
		STA $9E,x			;/
		LDA #$FF			;\
		STA $32E0,x			; | Don't interact
		STA $35F0,x			;/
		LDA #$40			;\ Behaviour
		STA $BE,x			;/
		LDX !SpriteIndex		;\ > X = shaman index
		LDY $3320,x			; |
		LDA .XSpeed,y			; |
		XBA				; |
		LDA .MaskProp,y			; |
		ORA !SpriteProp,x		; |
		PLY				; | Set direction, Xspeed, and property
		STA $33C0,y			; |
		LDA #$01 : STA $3410,y		; |
		STA $30AE,y			; |
		LDA $3320,x			; |
		STA $3320,y			;/

.Return		RTS

.XSpeed		db $10,$F0

.MaskProp	db $74,$34


; Load A before JSR:
;	0 - shoot forward
;	1 - target P1
;	2 - target P2
;	3 - spray cast
QUICK_CAST:	PHA
		JSL $02A9DE			;\ Get sprite slot
		BMI DROP_MASK_Return		;/
		PLA
		BNE $03 : JMP .Forward
		CMP #$01 : BNE $03 : JMP .P1
		CMP #$02 : BEQ .P2
		CMP #$03 : BNE DROP_MASK_Return

.Spray		JSR SPRITE_A_SPRITE_B_COORDS	; Same position
		JSR .SetMode
		LDA !RNG
		ADC !SpriteIndex
		AND #$1F
		SBC #$10
		STA $00
		LDA $30AE,y
		BPL +
		ORA #$20
		SEC : SBC $00
		BRA ++
	+	LSR A
		ADC $00
	++	STA $30AE,y
		LDA #$20
		SEC : SBC $00
		STA $309E,y
		LDA #$40 : STA $32D0,y
		RTS

.P2		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y : PHA		; |
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y : PHA		; | Determine projectile spawn coordinates
		LDA $3210,x			; |
		CLC : ADC $02			; |
		STA $3210,y : PHA		; |
		LDA $3240,x			; |
		ADC $03				; |
		STA $3240,y : PHA		;/
		JSR .SetMode

		PLA : STA $03
		PLA : STA $02
		PLA : STA $01
		PLA : STA $00

		REP #$20
		LDA $00
		SEC : SBC !P2XPosLo
		STA $00
		LDA $02
		SEC : SBC !P2YPosLo
		STA $02
		SEP #$20
		BRA .FinishAim

.P1		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y : PHA		; |
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y : PHA		; | Determine projectile spawn coordinates
		LDA $3210,x			; |
		CLC : ADC $02			; |
		STA $3210,y : PHA		; |
		LDA $3240,x			; |
		ADC $03				; |
		STA $3240,y : PHA		;/
		JSR .SetMode

		PLA : STA $03
		PLA : STA $02
		PLA : STA $01
		PLA : STA $00

		REP #$20
		LDA $00
		SEC : SBC !P2XPosLo-$80
		STA $00
		LDA $02
		SEC : SBC !P2YPosLo-$80
		STA $02
		SEP #$20

.FinishAim	PHY
		LDA #$30
		JSR AIM_SHOT
		PLY
		LDA $04 : STA $30AE,y
		LDA $06 : STA $309E,y
		RTS

.Forward	LDA $3320,x			;\ Determine direction
		BNE .Left			;/
.Right		LDA $3220,x			;\
		CLC : ADC #$0C			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		ADC #$00			; |
		STA $3250,y			; |
		BRA .Shared			; | Xpos = 12px in front (4px overlap)
.Left		LDA $3220,x			; |
		SEC : SBC #$0C			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		SBC #$00			; |
		STA $3250,y			;/
.Shared		LDA $3210,x			;\
		SEC : SBC #$08			; |
		STA $3210,y			; | Ypos = 8px above
		LDA $3240,x			; |
		SBC #$00			; |
		STA $3240,y			;/
.SetMode	LDA !SpriteTile,x : STA !SpriteTile,y
		LDA !SpriteProp,x : STA !SpriteProp,y
		PHX
		TYX
		LDA #$07 : STA !NewSpriteNum,x	;\  > Custom sprite number
		LDA #$36 : STA $3200,x		; | > Sprite number
		LDA #$08 : STA $3230,x		; | > Sprite status
		JSL $07F7D2			; | \ Clear tables
		JSL $0187A7			; | /
		LDA #$08 : STA !ExtraBits,x	;/  > Custom sprite flag
		LDA #$FF : STA $32D0,x		; > Life timer (max)
		LDA #$45			;\
		CLC : ADC !SpriteTile,x		; | Base tile
		STA $33D0,x			;/
		LDA #$82 : STA $BE,x		; > Behaviour (line + anim)
		LDA #$03 : STA $33E0,x		; > Number of frames (3)
		LDA #$05 : STA $3310,x		; > Animation frequency
		STX $00
		PLX
		LDY $3320,x			;\
		LDA DROP_MASK_MaskProp,y	; |
		AND #$F0
		ORA #$0A
		ORA !SpriteProp,x		; |
		STA $01				; |
		LDA .XSpeed,y			; |
		LDY $00				; | Get projectile prop + Xspeed
		STA $30AE,y			; |
		LDA $01 : STA $33C0,y		; |
		LDA #$01 : STA $3410,y		;/

.Return		RTS

.XSpeed		db $40,$C0

.Long		PHB : PHK : PLB
		JSR QUICK_CAST
		PLB
		RTL


SPRAY_CHECK:	LDY $3320,x
		LDA $3220,x
		CLC : ADC .XDisp,y
		STA $00
		LDA $3250,x
		ADC .XDisp+2,y
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		LDY #$00			; > P1 index
		LDA !RexAI
		AND #$20
		REP #$20
		BEQ .P1
.P2		LDY #$80			; > P2 index
.P1		LDA !P2XSpeed-$80-1,y
		AND #$FF00
		BPL $03 : ORA #$00FF
		XBA
		CLC : ADC !P2XPosLo-$80,y
		SEC : SBC $00
		BCC .NoContact
		CMP #$0028
		BCS .NoContact
		LDA !P2YPosLo-$80,y
		SEC : SBC $02
		BCC .NoContact
		CMP #$0080
		BCS .NoContact
.Contact	SEP #$21			; > Also sets carry
		RTS

.NoContact	SEP #$20
		CLC
		RTS

.XDisp		db $18,$C0
		db $00,$FF



; help routine for AIM_SHOT
; load A with speed, then call this
; output is X speed in $04 and Y speed in $06
; assumption is that sprite coordinates should go to player coordinates
; will target a random living player
; if target player is already determined and indexed in Y, store speed to $0F and call TARGET_PLAYER_Main instead
; long versions exist for both versions

TARGET_PLAYER:	STA $0F
		LDY #$00
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status-$80 : BNE .P2
		LDA !P2Status : BNE .P1
		LDA !RNG
		AND #$80
		TAY
		BRA .P1

	.P2	LDY #$80

	.P1
	.Main	LDA $3220,x
		SEC : SBC !P2XPosLo-$80,y
		STA $00
		LDA $3250,x
		SBC !P2XPosHi-$80,y
		STA $01
		LDA $3210,x
		SEC : SBC !P2YPosLo-$80,y
		STA $02
		LDA $3240,x
		SBC !P2YPosHi-$80,y
		STA $03
		BRA AIM_SHOT_Main

	..Long	PHB : PHK : PLB
		JSR .Main
		PLB
		RTL

	.Long	PHB : PHK : PLB
		JSR TARGET_PLAYER
		PLB
		RTL


; Set $00 to source X - target X (dx)
; Set $02 to source Y - target Y (dy)
; Load |speed| in A.
; Returns with X speed in $04 and Y speed in $06.

; s = sqrt(dx^2 + dy^2)
;
; dx/x = s/0x40
;
; x = 0x40*dx/s
; y = 0x40*dy/s

; dx and dy are actually 15-bit.

AIM_SHOT:	STA $0F
	.Main	STZ $2250		; > Enable multiplication
		REP #$20
		STZ $0D			; > No shifts yet
		LDA $00
		BPL .Pos_dx
		EOR #$FFFF
		INC A
.Pos_dx		STA $04			; $04 = |dx| (unscaled)

		LDA $02
		BPL .Pos_dy
		EOR #$FFFF
		INC A
.Pos_dy		STA $06			; $06 = |dy| (unscaled)
		LDY #$01		;\
		CMP $04			; | Load the largest of the two
		BCS $03 : LDA $04 : DEY	;/ > Y = 1, Y is bigger; Y = 0, X is bigger
		CMP #$0100 : BCC .0100	;\
		CMP #$0200 : BCC .0200	; |
		CMP #$0400 : BCC .0400	; |
		CMP #$0800 : BCC .0800	; |
		CMP #$1000 : BCC .1000	; |
		CMP #$2000 : BCC .2000	; | Downscale it
.4000		LSR A : INC $0D		; |
.2000		LSR A : INC $0D		; |
.1000		LSR A : INC $0D		; |
.0800		LSR A : INC $0D		; |
.0400		LSR A : INC $0D		; |
.0200		LSR A : INC $0D		; |
.0100		STA $08			;/
		LDA $06			;\
		CMP $04			; | Load the smaller of the two
		BCC $02 : LDA $04	;/

.Loop		DEC $0D : BMI .Scaled	;\ Downscale the other number
		LSR A : BRA .Loop	;/
.Scaled		CPY #$01 : BEQ .BigY	; > Determine which number is biggest
.BigX		STA $2251		;\
		STZ $2253		; |
		NOP			; | Calculate Y^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate X^2
		NOP			; |
		BRA .Shared		;/

.BigY		STA $2251		;\
		STA $2253		; |
		NOP			; | Calculate X^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate Y^2
		NOP			; |
		BRA .Shared		;/

.Shared		LDA $2306
		CLC : ADC $0A
		JSL !GetRoot		; (handles 17-bit numbers)
		ROR A
		LSR #7
		STA $0A			; > $0A = distance
		LDA $0F
		AND #$00FF
		STA $2251
		LDA $04 : STA $2253
		NOP
		BRA $00
		LDA $2306
		STA $04			; > $04 = v*|dx|
		LDA $06 : STA $2253
		NOP
		BRA $00
		LDA $2306		; > A = v*|dy|
		LDY #$01 : STY $2250	; > Enable division
		STA $2251
		LDA $0A
		STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $02 : BMI +
		EOR #$00FF
		INC A
	+	STA $06			; > $06 = y
		LDA $04 : STA $2251
		LDA $0A : STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $00 : BMI +
		EOR #$00FF
		INC A
	+	STA $04			; > $04 = x
		SEP #$20
		RTS

	.Long	PHB : PHK : PLB		; Wrapper for other banks
		JSR AIM_SHOT
		PLB
		RTL


ADEPT_ROUTE:
.1		STZ $2250			; > Enable multiplication
		STA $0F				; > Store hit type (0 = hit, 1 = stomp)
		LDA $3220,x : STA $00		;\
		LDA $3250,x : STA $01		; | Sprite coords
		LDA $3210,x : STA $02		; |
		LDA $3240,x : STA $03		;/
		LDA #$0B : STA !AdeptFlyTimer
		REP #$20
		LDA !P2XSpeed-$80-1
		BPL .PosX1
.NegX1		XBA
		LSR #4
		ORA #$FFF0
		BRA .CalcX1
.PosX1		XBA
		LSR #4
		AND #$000F
.CalcX1		STA $2251			; > Multiplicand (speed/16)
		LDA #$003C			;\ Multiplier (60, one second)
		STA $2253			;/
		LDA !P2XPosLo-$80		;\
		CLC : ADC $2306			; | Save player x disp - sprite X pos
		SEC : SBC $00			; |
		STA $00				;/

		SEP #$20
		LDA $0F : BEQ .AttackDodge1
.StompDodge	BIT $01
		BPL .DodgeLeft
.DodgeRight	LDA #$06 : STA !RexChase
		LDA #$87 : STA !AdeptSequence
		RTS
.DodgeLeft	LDA #$02 : STA !RexChase
		LDA #$23 : STA !AdeptSequence
		RTS

.2		STZ $2250			; > Enable multiplication
		STA $0F				; > Store hit type (0 = hit, 1 = stomp)
		LDA $3220,x : STA $00		;\
		LDA $3250,x : STA $01		; | Sprite coords
		LDA $3210,x : STA $02		; |
		LDA $3240,x : STA $03		;/
		LDA #$0B : STA !AdeptFlyTimer
		REP #$20
		LDA !P2XSpeed-1
		BPL .PosX2
.NegX2		XBA
		LSR #4
		ORA #$FFF0
		BRA .CalcX2
.PosX2		XBA
		LSR #4
		AND #$000F
.CalcX2		STA $2251			; > Multiplicand (speed/16)
		LDA #$003C			;\ Multiplier (60, one second)
		STA $2253			;/
		LDA !P2XPosLo			;\
		CLC : ADC $2306			; | Save player x disp - sprite X pos
		SEC : SBC $00			; |
		STA $00				;/

		SEP #$20
		LDA $0F : BNE .StompDodge
		REP #$20
		LDA #!P2YPosLo : STA $06
		LDA !P2YSpeed-1
		BRA .GetY

.AttackDodge1	REP #$20
		LDA #!P2YPosLo-$80 : STA $06
		LDA !P2YSpeed-$80-1
.GetY		CLC : ADC #$5A00		; > Account for gravity (kind of)
		BMI .NegY
		CMP #$5A00
		BCC .PosY
		LDA #$4000			; > Cap speed at 0x40
.PosY		XBA
		LSR #4
		AND #$000F
		BRA .CalcY
.NegY		XBA
		LSR #4
		ORA #$FFF0
.CalcY		STA $2251			; > Multiplicand (speed/16)
		LDA #$003C
		STA $2253
		LDA ($06)			;\ Get player y disp
		CLC : ADC $2306			;/
		LDY #$01 : STY $2250		; > Set division
		SEC : SBC $02			; > Subtract sprite Y pos
		BMI .UpperQuadrant		;\ Determine upper/lower
		JMP .LowerQuadrant		;/


	.UpperQuadrant
		EOR #$FFFF			;\
		INC A				; | Dividend = |Y|
		STA $2251			;/
		LDA $00
		BPL .UR
.UL		EOR #$FFFF			;\
		INC A				; | Divisor = |X|
		STA $2253			;/
		JSR .GetNode
	BEQ .S
	CPY #$01 : BEQ .SESS
	CPY #$02 : BEQ .SES
	CPY #$03 : BEQ .SE
	CPY #$04 : BEQ .SEE
	CPY #$05 : BEQ .SEEE

.E		LDA #$02 : LDY #$33
		BRA .End
.SEEE		LDA #$03 : LDY #$33
		BRA .End
.SEE		LDA #$02 : LDY #$44
		BRA .End
.SE		LDA #$03 : LDY #$44
		BRA .End
.SES		LDA #$04 : LDY #$44
		BRA .End
.SESS		LDA #$03 : LDY #$55
		BRA .End
.S		LDA #$04 : LDY #$55
		BRA .End


.UR		STA $2253			; > Divisor = X
		JSR .GetNode
	BEQ .S
	CPY #$01 : BEQ .SWSS
	CPY #$02 : BEQ .SWS
	CPY #$03 : BEQ .SW
	CPY #$04 : BEQ .SWW
	CPY #$05 : BEQ .SWWW

.W		LDA #$06 : LDY #$77
		BRA .End
.SWWW		LDA #$05 : LDY #$77
		BRA .End
.SWW		LDA #$06 : LDY #$66
		BRA .End
.SW		LDA #$05 : LDY #$66
		BRA .End
.SWS		LDA #$04 : LDY #$66
		BRA .End
.SWSS		LDA #$05 : LDY #$55


.End		STA !RexChase
		TYA : STA !AdeptSequence
		RTS


	.LowerQuadrant
		STA $2251			; > Dividend = Y
		LDA $00
		BPL .DR
.DL		EOR #$FFFF			;\
		INC A				; | Divisor = |X|
		STA $2253			;/
		JSR .GetNode
	BEQ .N
	CPY #$01 : BEQ .NENN
	CPY #$02 : BEQ .NEN
	CPY #$03 : BEQ .NE
	CPY #$04 : BEQ .NEE
	CPY #$05 : BEQ .NEEE
	JMP .E

.NEEE		LDA #$01 : LDY #$33
		BRA .End
.NEE		LDA #$02 : LDY #$22
		BRA .End
.NE		LDA #$01 : LDY #$22
		BRA .End
.NEN		LDA #$00 : LDY #$22
		BRA .End
.NENN		LDA #$01 : LDY #$11
		BRA .End
.N		LDA #$00 : LDY #$11
		BRA .End

.DR		STA $2253			; > Divisor = X
		JSR .GetNode
	BEQ .N
	CPY #$01 : BEQ .NWNN
	CPY #$02 : BEQ .NWN
	CPY #$03 : BEQ .NW
	CPY #$04 : BEQ .NWW
	CPY #$05 : BEQ .NWWW
	JMP .W

.NWNN		LDA #$07 : LDY #$11
		BRA .End
.NWN		LDA #$00 : LDY #$88
		JMP .End
.NW		LDA #$07 : LDY #$88
		JMP .End
.NWW		LDA #$06 : LDY #$88
		JMP .End
.NWWW		LDA #$07 : LDY #$77
		JMP .End

.GetNode	CMP #$0000 : BEQ .Node0		; > Don't divide by 0 (assume Y/0 equals infinity)
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



.GetNode_Long	PHB : PHK : PLB
		JSR .GetNode
		PLB
		RTL

