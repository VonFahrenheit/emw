;
; Rex tables:
; $BE	- How many hits the Rex has taken
; $3280 - Rex AI bits
; $3290 - Xpos of wall being climbed
; $32B0 - Dynamic tile or turn around at ledge flag
; $32D0 - Throw hammer timer
; $3310	- Animation timer
; $3340 - Movement flags
; $33D0	- Animation index
; $33E0 - Chase timer
; $35D0 - Slam (used by brute on insane)

; Shaman differences:
; $3290 - Equipped mask
; $32D0 - Cast timer

; Adept:
; $3290 - Desired X coordinate (lo)
; $32A0 - Desired X coordinate (hi)
; $32B0 - Desired Y coordinate (lo)
; $32C0 - Desired Y coordinate (hi)
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

	!BigRAM			= $6080


	!RexAI			= $3280,x
	!RexWallX		= $3290,x
	!RexHammer		= $32A0,x
	!RexMovementFlags	= $3340,x
	!RexChase		= $33E0,x

	!AggroRexIdle		= $00
	!AggroRexWalk		= $02
	!AggroRexRoar		= $0A
	!AggroRexCharge		= $0B
	!AggroRexJump		= $13
	!AggroRexClimb		= $14
	!AggroRexGetup		= $16

	!ShamanMask		= $3290,x
	!ShamanCast		= $32D0,x

	!AdeptFlyTimer		= $32D0,x
	!AdeptSequence		= $35E0,x


;===========;
;REX MODULES;
;===========;

AGGROREX:
.INIT		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04			;\
		BEQ +				; |
		LDA !RexMovementFlags		; | Enable ambush if extra bit is set
		ORA #$02			; |
		STA !RexMovementFlags		;/
	+	LDA #$E4
		STA !RexAI
		LDA #$04
		STA $3330,x
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA #!AggroRexWalk
		STA !SpriteAnimIndex
		LDA $3450,x
		AND.b #$1F^$FF
		ORA #$0D
		STA $3450,x
		LDA $3440,x
		AND.b #$0F^$FF
		STA $3440,x


		STZ $00
		STZ $01
		STZ $02
		STZ $03
		LDY #$00
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ +
		CMP #$08 : BNE ++
	+	LDA !NewSpriteNum,x
		CMP #$04 : BNE ++
		LDA !ClaimedGFX
		STA $3000,y
		INY

	++	DEX : BPL -
		DEY
		CPY #$04 : BCC +
	--	LDX !SpriteIndex
		STZ $3230,x
		PLB
		RTL

	+	LDA #$C0
	-	CMP $00 : BEQ +
		CMP $01 : BEQ +
		CMP $02 : BEQ +
		CMP $03 : BNE ++
	+	CLC : ADC #$04
		CMP #$D0
		BNE -
		BRA --

	++	LDX !SpriteIndex
		STA !ClaimedGFX

		JSR .UpdateGFX

		PLB

.MAIN		PHB : PHK : PLB
		JSR REX_BEHAVIOUR

		LDA $32F0,x
		BEQ +
		LDA $3230,x
		CMP #$02
		BEQ +
		LDA #$02
		STA $3230,x
		LDA #$F0
		STA $9E,x
		+

		LDA $35D0,x
		BEQ .NoSlam
		LDA #$11 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JMP ++
		.NoSlam

		LDA !RexMovementFlags
		AND #$02
		BEQ +
		LDA !SpriteAnimIndex
		CMP #!AggroRexIdle+2
		BCS $03 : JMP ++
		CMP #$17
		BNE $03 : JMP ++
		LDA #!AggroRexIdle
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JMP ++
	+	LDA !RexChase
		BEQ +
		LDA #!AggroRexRoar
		CMP !SpriteAnimIndex
		BNE $03 : JMP ++
		STA !SpriteAnimIndex
		JMP ++
	+	BIT !RexMovementFlags
		BPL +
		LDA !SpriteAnimIndex
		CMP #!AggroRexClimb
		BEQ ++
		CMP #!AggroRexClimb+1
		BEQ ++
		CMP #$18
		BEQ ++
		LDA #!AggroRexClimb
		STA !SpriteAnimIndex
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
		LDA #!AggroRexGetup
		STA !SpriteAnimIndex
		BRA ++
	.Jump	LDA !Difficulty
		AND #$03
		CMP #$02 : BNE .NormalJump
		LDA #$0D : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++

		.NormalJump
		LDA #!AggroRexJump
		STA !SpriteAnimIndex
		BRA ++
	+	BIT !RexMovementFlags
		BVC +
		LDA !SpriteAnimIndex
		CMP #!AggroRexCharge
		BEQ ++
		BCC $04 : CMP #!AggroRexCharge+$08 : BCC ++
		LDA #!AggroRexCharge
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
	+	LDA !SpriteAnimIndex
		CMP #!AggroRexWalk
		BEQ ++
		BCC +
		CMP #!AggroRexWalk+$08
		BCC ++
	+	LDA #!AggroRexWalk
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	++	LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w .ANIM_IDLE+2,y
		BNE +
		LDA.w .ANIM_IDLE+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
	+	STA !SpriteAnimTimer

		LDA !SpriteAnimIndex
		CMP !AggroRexTile
		STA !AggroRexTile
		BEQ .SameFrame
		JSR .UpdateGFX
		.SameFrame

		REP #$20
		LDA .ANIM_IDLE+0,y
		CMP #$6000 : BCC .24
	.32	LDA !SpriteAnimIndex
		AND #$00FF
		CMP #$0004 : BEQ .32U1
		CMP #$0008 : BEQ .32U1
		CMP #$000C : BEQ .32U1
		CMP #$000E : BEQ .32U1
		CMP #$0010 : BEQ .32U1
		CMP #$0012 : BEQ .32U1
		CMP #$000D : BEQ .32U1
		CMP #$0011 : BEQ .32U2
	++	LDA.w #.TM32 : BRA +
	.32U1	LDA.w #.TM32U1 : BRA +
	.32U2	LDA.w #.TM32U2 : BRA +
	.24	LDA.w #.TM24
	+	STA $04
		SEP #$20

		JSR LOAD_PSUEDO_DYNAMIC
		PLB
		RTL


	.UpdateGFX
		LDA !ClaimedGFX : STA $08
		JSL !GetVRAM
		PHB
		LDA #!VRAMbank
		PHA
		REP #$20
		LDA .ANIM_IDLE+0,y
		PLB
		STA $02				; < $02 = Base value
		ROL #4
		AND #$0007
		INC A
		XBA
		LSR #3
		STA $00				; < $00 = Size

		LDA $02
		LSR #2
		XBA
		AND #$0007
		STA $06				; < $06 = Number of upload loops

		LDA $08
		AND #$00FF
		ASL #4
		ORA #$6000
		STA $08				; < $08 = Base dest

		LDA $02
		AND #$03FF
		ASL #5
		CLC : ADC #$9008

	-	STA $02				;\ Source address
		STA !VRAMtable+$02,x		;/
		LDA #$3434			;\ Source bank
		STA !VRAMtable+$04,x		;/
		LDA $08				;\ Dest VRAM
		STA !VRAMtable+$05,x		;/
		CLC : ADC #$0100		;\ Update for next loop
		STA $08				;/
		LDA $00				;\ Upload size
		STA !VRAMtable+$00,x		;/
		TXA				;\
		CLC : ADC #$0007		; | Get next index
		TAX				;/
		LDA $02				;\ Calculate next source address
		CLC : ADC #$0200		;/
		DEC $06 : BPL -			; > Loop

		SEP #$20
		PLB
		LDX !SpriteIndex

		RTS


	.TM24
	dw $0010
	db $2C,$00,$F0,$00
	db $2C,$08,$F0,$01
	db $2C,$00,$00,$20
	db $2C,$08,$00,$21

	.TM24X
	dw $0010
	db $2C,$F8,$F0,$00
	db $2C,$00,$F0,$01
	db $2C,$F8,$00,$20
	db $2C,$00,$00,$21

	.TM32
	dw $0010
	db $2C,$F8,$F0,$00
	db $2C,$08,$F0,$02
	db $2C,$F8,$00,$20
	db $2C,$08,$00,$22

	.TM32U1			; 4, 8, C, E, 10, 12
	dw $0010
	db $2C,$F8,$EF,$00
	db $2C,$08,$EF,$02
	db $2C,$F8,$FF,$20
	db $2C,$08,$FF,$22

	.TM32U2			; D, 11
	dw $0010
	db $2C,$F8,$EE,$00
	db $2C,$08,$EE,$02
	db $2C,$F8,$FE,$20
	db $2C,$08,$FE,$22

	.ANIM_IDLE
		dw $6C04 : db $FF,$01		; 00
		dw $6C00 : db $08,$17		; 01
	.ANIM_WALK
		dw $6C04 : db $08,$03		; 02
		dw $6C08 : db $08,$04		; 03
		dw $6C0C : db $08,$05		; 04
		dw $6C08 : db $08,$06		; 05
		dw $6C04 : db $08,$07		; 06
		dw $6C40 : db $08,$08		; 07
		dw $6C44 : db $08,$09		; 08
		dw $6C40 : db $08,$02		; 09
	.ANIM_ROAR
		dw $6C48 : db $FF,$0B		; 0A
	.ANIM_CHARGE
		dw $6C4C : db $05,$0C		; 0B
		dw $6C80 : db $05,$0D		; 0C
		dw $6C84 : db $05,$0E		; 0D
		dw $6C80 : db $05,$0F		; 0E
		dw $6C4C : db $05,$10		; 0F
		dw $6C88 : db $05,$11		; 10
		dw $6C8C : db $05,$12		; 11
		dw $6C88 : db $05,$0B		; 12
	.ANIM_JUMP
		dw $6CC0 : db $FF,$13		; 13
	.ANIM_CLIMB
		dw $4CC4 : db $0A,$15		; 14
		dw $4CC7 : db $0A,$18		; 15
	.ANIM_GETUP
		dw $6D00 : db $FF,$16		; 16
	.EXTRA_ANIM
		dw $6D04 : db $C0,$00		; 17
		dw $4CCA : db $0A,$14		; 18



REX:
.INIT		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04			;\
		BEQ +				; | No movement if extra bit is set
		LDA #$08			; |
	+	ORA #$20			;/
		STA !RexAI
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA !GFX_status+$03 : STA !ClaimedGFX
		LDA #$01
		STA !SpriteAnimIndex
		PLB

.MAIN		PHB : PHK : PLB
		JSR REX_BEHAVIOUR

		LDA $BE,x
		BEQ ++
		DEC A
		BEQ +
		LDA #$0C
		STA !SpriteAnimIndex
		BRA ++
	+	LDA $34D0,x
		BEQ +
		LDA #$09
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
		JSR LOAD_PSUEDO_DYNAMIC_Rex
		PLB
		RTL

	.AnimIdle
		dw .TM_Idle00 : db $FF,$00	; 00
	.AnimWalk
		dw .TM_Walk00 : db $08,$02	; 01
		dw .TM_Walk01 : db $08,$03	; 02
		dw .TM_Walk02 : db $08,$04	; 03
		dw .TM_Walk01 : db $08,$05	; 04
		dw .TM_Walk00 : db $08,$06	; 05
		dw .TM_Walk03 : db $08,$07	; 06
		dw .TM_Walk04 : db $08,$08	; 07
		dw .TM_Walk03 : db $08,$01	; 08
	.AnimHurt
		dw .TM_Hurt00 : db $FF,$09	; 09
	.AnimSmush
		dw .TM_Smush00 : db $07,$0B	; 0A
		dw .TM_Smush01 : db $07,$0A	; 0B
	.AnimDead
		dw .TM_Dead00 : db $FF,$0C	; 0C

incsrc "SpriteGFX/Rex.tilemap.asm"


HAMMERREX:
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
		LDA !GFX_status+$04 : STA !ClaimedGFX
		LDA #$01
		STA !SpriteAnimIndex
		PLB

.MAIN		PHB : PHK : PLB
		LDA !SpriteAnimIndex
		CMP #$0D
		BCC .NoStun
		JSR REX_BEHAVIOUR_DontTurn
		LDA $34D0,x
		BNE +
		LDA !SpriteAnimIndex
		BRA ++
.NoStun		JSR REX_BEHAVIOUR

	+	LDA $BE,x
		BNE +
		LDA !RexAI
		AND #$08
		BEQ ++
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA !SpriteAnimIndex
		CMP #$01
		BCC ++
		CMP #$09
		BCS ++
		LDA #$00
		STA !SpriteAnimIndex
		BRA ++
	+	DEC A
		BEQ +
		LDA #$0C
		STA !SpriteAnimIndex
		BRA ++
	+	LDA $34D0,x
		BEQ +
		LDA #$09
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
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimIdle+2,y
		BNE +
		LDA.w .AnimIdle+3,y
		STA !SpriteAnimIndex
		CMP #$0E
		BNE ++
		JSR REX_HAMMER_Prep
		LDA !SpriteAnimIndex
	++	ASL #2
		TAY
		LDA.w .AnimIdle+0,y
		STA $04
		LDA.w .AnimIdle+1,y
		STA $05
		LDA #$00
	+	STA !SpriteAnimTimer
		JSR LOAD_PSUEDO_DYNAMIC_Rex
		PLB
		RTL

.HammerDelay	db $24,$24,$18


	.AnimIdle
		dw .TM_Idle00 : db $20,$00	; 00
	.AnimWalk
		dw .TM_Walk00 : db $08,$02	; 01
		dw .TM_Walk01 : db $08,$03	; 02
		dw .TM_Walk02 : db $08,$04	; 03
		dw .TM_Walk01 : db $08,$05	; 04
		dw .TM_Walk00 : db $08,$06	; 05
		dw .TM_Walk03 : db $08,$07	; 06
		dw .TM_Walk04 : db $08,$08	; 07
		dw .TM_Walk03 : db $08,$01	; 08
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
		dw .TM_Throw00 : db $20,$01	; 0E

incsrc "SpriteGFX/HammerRex.tilemap.asm"




NOVICESHAMAN:
.INIT		PHB : PHK : PLB
		LDA #$30			;\ Turn + Shaman
		STA !RexAI			;/
		LDA #$10			;\ Equip mask
		STA !RexMovementFlags		;/
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA #$01
		STA !SpriteAnimIndex
		LDA !RNG			;\
		AND #$03			; | Equip random mask
		STA !ShamanMask			;/
		PLB

.MAIN		PHB : PHK : PLB
		LDA !RexMovementFlags
		AND #$08
		ORA $32F0,x
		BNE .Walk
		LDA $3230,x
		CMP #$02
		BEQ .Walk

		LDA !Difficulty
		AND #$03
		TAY
		LDA !ShamanCast
		CMP SHAMAN_CAST_CastTime,y
		BCC .Stop
		LDA !SpriteAnimIndex
		CMP #$0C
		BNE .Walk

		.Stop
		LDA !RexAI
		ORA #$08
		STA !RexAI
		STZ $AE,x
		BRA .GetMain

		.Walk
		LDA !RexAI
		AND.b #$08^$FF
		STA !RexAI

.GetMain	JSR REX_BEHAVIOUR

		LDA $32F0,x
		BEQ +
		LDA #$0C
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA $3230,x
		CMP #$02 : BEQ +
		LDA #$02 : STA $3230,x
		STZ $9E,x
		+

		LDA $BE,x			;\
		BEQ +				; |
		LDA !RexMovementFlags		; | Check for mask
		AND #$10			; |
		BEQ +				;/
		JSR DROP_MASK			; > Drop mask subroutine
		LDA #$0C			;\
		STA !SpriteAnimIndex		; |
		LDA !Difficulty			; | Hurt animation
		AND #$03			; |
		ASL #3				; |
		STA !SpriteAnimTimer		;/
		+

		LDA !SpriteAnimIndex		;\
		STA $00				; | Get index (and save copy in scratch RAM)
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
		LDA.w .AnimIdle+0,y		;\ Get static tilemap pointer
		STA $06				;/
		LDA ($06)			;\ Header at !BigRAM
		STA !BigRAM+$00			;/
		INC $06				;\ Increment pointer past header
		INC $06				;/
		STA $02				; > $02 = header (byte count)
		LDA #!BigRAM+$02 : STA $04	; > $04 = tilemap pointer

		LDA $00				;\
		AND #$00FF			; | Check for spell animation
		CMP #$0009 : BCC .NoSpell	; |
		CMP #$000C : BCS .NoSpell	;/

		SEP #$20			; > A 8-bit
		LDA #$27			;\
		STA !BigRAM+$02			; | Spell prop
		STA !BigRAM+$06			; |
		STA !BigRAM+$0A			;/
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
		STA !BigRAM+$05			; |
		LDA .SpellTile2,y		; | Spell tiles
		STA !BigRAM+$09			; |
		LDA .SpellTile3,y		; |
		STA !BigRAM+$0D			;/
		REP #$20			; > A 16-bit
		LDA #!BigRAM+$0E : STA $04	; > $04 = tilemap pointer (past spell)
		LDA !BigRAM+$00			;\
		CLC : ADC #$000C		; | Increase tile count
		STA !BigRAM+$00			;/

	.NoSpell
		LDA !RexMovementFlags
		AND #$0010
		BNE .DrawMask

		LDA !BigRAM+$00			;\
		SEC : SBC #$0004		; | Decrement header
		STA !BigRAM+$00			;/
		BRA .NoMask

	.DrawMask
		LDA .MaskTM00+$00
		STA ($04)
		INC $04
		INC $04
		LDA .MaskTM00+$02
		STA ($04)
		LDA $00
		AND #$00FF
		CMP #$0003 : BEQ $05
		CMP #$0007 : BNE $05
		LDA ($04)
		DEC A
		STA ($04)
		INC $04
		LDA !ShamanMask
		TAY
		LDA .MaskTile,y
		STA ($04)
		INC $04


	.NoMask
		LDY $02				; > Y = tile count
	-	LDA ($06),y			;\
		STA ($04),y			; | Upload body tilemap
		DEY #2				; |
		BPL -				;/
		LDA #!BigRAM : STA $04		; > $04 = true tilemap pointer
		SEP #$20			; > A 8-bit
		JSR LOAD_TILEMAP		; > Upload tilemap
		PLB
		RTL


	.AnimIdle
		dw .IdleTM00 : db $FF,$00	; 00

	.AnimWalk
		dw .WalkTM00 : db $08,$02	; 01
		dw .WalkTM01 : db $08,$03	; 02
		dw .WalkTM02 : db $08,$04	; 03
		dw .WalkTM01 : db $08,$05	; 04
		dw .WalkTM00 : db $08,$06	; 05
		dw .WalkTM03 : db $08,$07	; 06
		dw .WalkTM04 : db $08,$08	; 07
		dw .WalkTM03 : db $08,$01	; 08

	.AnimCast
		dw .CastTM00 : db $06,$0A	; 09
		dw .CastTM01 : db $06,$0B	; 0A
		dw .CastTM02 : db $06,$09	; 0B

	.AnimHurt
		dw .HurtTM00 : db $1F,$01	; 0C, timer hardcoded


; Tilemaps are always 4 bytes larger because of the mask.

	.IdleTM00
		dw $000C
		db $27,$00,$F0,$00+$60
		db $27,$00,$00,$20+$60

	.WalkTM00
		dw $000C
		db $27,$00,$F0,$00+$60
		db $27,$00,$00,$20+$60
	.WalkTM01
		dw $000C
		db $27,$00,$F0,$00+$60
		db $27,$00,$00,$02+$60
	.WalkTM02
		dw $000C
		db $27,$00,$EF,$00+$60
		db $27,$00,$FF,$04+$60
	.WalkTM03
		dw $000C
		db $27,$00,$F0,$00+$60
		db $27,$00,$00,$22+$60
	.WalkTM04
		dw $000C
		db $27,$00,$EF,$00+$60
		db $27,$00,$FF,$24+$60

	.HurtTM00
		dw $000C
		db $27,$00,$F0,$43+$60
		db $27,$00,$00,$63+$60

	.CastTM00
		dw $0014
		db $27,$F4,$F8,$A5
		db $27,$00,$F0,$0A+$60
		db $27,$00,$00,$2A+$60
		db $27,$08,$00,$2B+$60

	.CastTM01
		dw $0014
		db $27,$F4,$F8,$A7
		db $27,$00,$F0,$0D+$60
		db $27,$00,$00,$2D+$60
		db $27,$08,$00,$2E+$60

	.CastTM02
		dw $0014
		db $27,$F4,$F8,$A9
		db $27,$00,$F0,$40+$60
		db $27,$00,$00,$60+$60
		db $27,$08,$00,$61+$60

	.MaskTM00
		db $27,$FF,$F2,$FF
	.MaskTile
		db $66,$68,$86,$88

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
		db $AB,$AB,$AB,$AB
		db $AB,$AB,$AB,$AB
		db $AD,$AD,$AD,$AD
		db $AD,$AD,$AD,$AD
	.SpellTile2
		db $AB,$AB,$AD,$AD
		db $AD,$AD,$AD,$AD
		db $AD,$AD,$AB,$AB
		db $AB,$AB,$AB,$AB
	.SpellTile3
		db $AD,$AD,$AD,$AD
		db $AB,$AB,$AB,$AB
		db $AB,$AB,$AB,$AB
		db $AD,$AD,$AD,$AD



ADEPTSHAMAN:
.INIT		PHB : PHK : PLB
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		LDA #$04 : STA $BE,x		; > HP = 4
		LDA #$FF : STA $34C0,x		; > Disable circle cast
		STZ $3390,x			;\ Clear casting status
		STZ $33C0,x			;/
		STZ !RexAI			; > Reset AI
		JSL !GetVRAM
		REP #$20

		LDA #$0032
		STA !VRAMbase+!VRAMtable+$04,x
		STA !VRAMbase+!VRAMtable+$0B,x
		LDA !RNG
		AND #$0003
		XBA
		LSR #2
		CLC : ADC #$B008
		STA !VRAMbase+!VRAMtable+$02,x
		CLC : ADC #$0200
		STA !VRAMbase+!VRAMtable+$09,x
		LDA #$6E80
		STA !VRAMbase+!VRAMtable+$05,x
		LDA #$6F80
		STA !VRAMbase+!VRAMtable+$0C,x
		LDA #$0040
		STA !VRAMbase+!VRAMtable+$00,x
		STA !VRAMbase+!VRAMtable+$07,x

		SEP #$20
		LDX !SpriteIndex
		PLB

	; AI:
	; CCt---PP
	; C = Cast stage
	; t = target player
	; P = Phase


.MAIN		PHB : PHK : PLB
		PEI ($D8)			;\
		PEI ($DA)			; | Backup sprite pointers
		PEI ($DE)			;/
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
		JSL $01802A			; > Update speed

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
		LDA.w .AnimIdle+4,y
		BEQ ++
		STA $0C
		SEP #$20
		LDA $3340,x
		CMP !SpriteAnimIndex
		BEQ +
		PHY
		JSR UPDATE_GFX
		PLY
		+

		REP #$20			; > A 16-bit
	++	LDA $32E0,x			;\
		ORA $35F0,x			; |
		AND #$00FF : BEQ +		; |
		LDA $14				; |
		AND #$0002 : BNE +		; | Invulnerability flash
		SEP #$20			; |
		PLB				; |
		RTL				;/

	+	LDA.w .AnimIdle+0,y		;\ Get static tilemap pointer
		STA $06				;/
		LDA ($06)			;\ Header at !BigRAM
		STA !BigRAM+$00			;/
		INC $06				;\ Increment pointer past header
		INC $06				;/
		STA $02				; > $02 = header (byte count)
		LDA $BE,x			;\
		AND #$00FF			; |
		CMP #$0004			; |
		BEQ +				; |
		LDA $02				; | Ignore mask if adept has taken damage
		SEC : SBC #$0004		; |
		STA $02				; |
		STA !BigRAM+$00			; |
		LDA $06				; |
		CLC : ADC #$0004		; |
		STA $06				; |
		+				;/
		LDA #!BigRAM+$02 : STA $04	; > $04 = tilemap pointer

		LDA $34C0-1,x
		CMP #$FF00 : BCS .NoSpell
		SEP #$20
		JSR .CircleCast_GetCoords
		REP #$20
		LDA $0E
		AND #$00FF
		ASL #2
		CLC : ADC !BigRAM
		STA !BigRAM
		.NoSpell

	.DrawTiles
		SEP #$20
		LDA #$FF : STA $01		;\ Hi bytes are always AND #$FFxx : ORA #$00yy
		STZ $09				;/

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
	++	LDA #$F1 : STA $00		;\ AND #$FFF1 : ORA #$0008
		LDA #$08 : STA $08		;/
		BRA .EndFlash

		.NoFlash
		LDA #$FF : STA $00		;\ AND #$FFFF : ORA #$0000
		STZ $08				;/
		.EndFlash

		LDA !RexAI
		AND #$03
		CMP #$02 : BNE .NoDeath
		LDA !RexChase
		AND #$C0
		CMP #$C0 : BEQ .NoDeath
		LDA $3330,x
		AND #$04 : BEQ .NoDeath

		LDA #$27			;\
		STA !BigRAM+$02			; | Spell prop
		STA !BigRAM+$06			; |
		STA !BigRAM+$0A			;/
		LDA $14				;\
		LSR A				; | Spell tilemap is indexed by frame counter
		AND #$0F			; |
		TAY				;/
		LDA NOVICESHAMAN_SpellPart1X,y	;\
		DEC #2				; |
		STA !BigRAM+$03			; |
		LDA NOVICESHAMAN_SpellPart2X,y	; | Spell X-coords
		DEC #2				; |
		STA !BigRAM+$07			; |
		LDA NOVICESHAMAN_SpellPart3X,y	; |
		DEC #2				; |
		STA !BigRAM+$0B			;/
		LDA NOVICESHAMAN_SpellPart1Y,y	;\
		STA !BigRAM+$04			; |
		LDA NOVICESHAMAN_SpellPart2Y,y	; | Spell Y-coords
		STA !BigRAM+$08			; |
		LDA NOVICESHAMAN_SpellPart3Y,y	; |
		STA !BigRAM+$0C			;/
		LDA NOVICESHAMAN_SpellTile1,y	;\
		STA !BigRAM+$05			; |
		LDA NOVICESHAMAN_SpellTile2,y	; | Spell tiles
		STA !BigRAM+$09			; |
		LDA NOVICESHAMAN_SpellTile3,y	; |
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

		LDY $02				; > Y = tile count
	-	LDA ($06),y			;\
		AND $00				; \ Account for attack flash
		ORA $08				; /
		STA ($04),y			; |
		DEY #2				; |
		LDA ($06),y			; | Upload body tilemap
		STA ($04),y			; |
		DEY #2				; |
		BPL -				;/
		LDA #!BigRAM : STA $04		; > $04 = true tilemap pointer
		SEP #$20			; > A 8-bit
		LDA !SpriteAnimIndex		;\ Currently loaded frame
		STA $3340,x			;/
		JSR LOAD_TILEMAP		; > Upload tilemap
		PLB
		RTL


	.PhasePtr
		dw .StatueMode
		dw .ChaseMode
		dw .DeathMode


	.StatueMode
		LDX !SpriteIndex
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

	.Return
		RTS


	.TakeFlight
		SEP #$20
		LDA #$0A : STA !RexChase
		LDA #$1A : STA !AdeptFlyTimer
		LDA #$03 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		LDA $3210,x
		SEC : SBC #$50
		STA $32B0,x
		LDA $3240,x
		SBC #$00
		STA $32C0,x

		INC !RexAI

	.ChaseMode
		LDX !SpriteIndex

		LDA $BE,x
		BPL .NoReggedHit
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
		STZ $33C0,x			;/
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
		AND #$F0			; | Set mask palette
		ORA #$0A			; |
		STA $33C0,y			;/
		LDA #$E8 : STA $33D0,y		; > Set mask tile
	+	JMP .NoContact

		..2
		JSR ADEPT_ROUTE_2
		BRA -

		.NoReggedHit
		LDA !P1Dead
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
		LDA $32E0,x
		BNE .NoContact
		LDA #$0C : STA $32E0,x
		LDA $3210,x
		SEC : SBC $96
		BCC .HurtMario
		LDA !MarioYSpeed
		CMP #$10 : BMI .HurtMario
.HurtAdept	JSL !BouncePlayer
		JSL !ContactGFX
		JSR REX_POINTS
		LDA #$FF : STA $34C0,x		;\
		LDA !RexAI			; |
		AND.b #$C0^$FF			; | Cancel magic and attacks
		STA !RexAI			; |
		STZ $35D0,x			;/
		STZ $3390,x			;\ Despawn spell particles
		STZ $33C0,x			;/
		DEC $BE,x
		LDA $BE,x : BEQ .KillAdept
		CMP #$03 : BNE .GetRoute
		JSR DROP_MASK_Spawn
		LDA $33C0,y			;\
		AND #$F0			; | Set mask palette
		ORA #$0A			; |
		STA $33C0,y			;/
		LDA #$E8 : STA $33D0,y		; > Set mask tile
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


		LDA !AdeptFlyTimer
		BNE ..KeepFlying

		LDA !AdeptSequence
		BEQ +
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
		LDA #$0A : STA !SpriteAnimIndex
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
		STA $32C0,x
		JMP ..HandleAttack
	+	LDA !P2XPosLo-$80 : STA $3290,x
		LDA !P2XPosHi-$80 : STA $32A0,x
		LDA !P2YPosLo-$80
		SEC : SBC #$50
		STA $32B0,x
		LDA !P2YPosHi
		SBC #$00
		STA $32C0,x
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
		STA $32C0,x
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
		STA $32C0,x

		..HandleAttack
		LDA $34C0,x
		CMP #$FF : BNE ..Spell
		LDA !RexChase
		AND #$1F
		CMP #$09 : BCS ..NoSpell
		LDA $14 : BEQ ..ExecuteAttack
		CMP #$D2 : BNE ..NoSpell

		..ChooseAttack
		JSR SPRAY_CHECK
		BCC ..NoSpray
		LDA #$03 : STA $35D0,x
		BRA ..NoSpell

		..NoSpray
		LDA !RNG
		AND #$01
		INC A
		STA $35D0,x
		BRA ..NoSpell

		..ExecuteAttack
		LDA !RexAI			;\
		AND.b #$20^$FF			; |
		STA $00				; |
		LDA !RNG			; | Target random player
		AND #$20			; |
		ORA $00				; |
		STA !RexAI			;/
		LDA $35D0,x
		STZ $35D0,x
		DEC A
		BEQ ..Grind
		CMP #$01 : BEQ ..SpellSet

		..Spray
		LDA #$0C : STA !RexChase
		LDA #$40 : STA !AdeptFlyTimer
		LDA #$13 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ..NoSpell

		..Grind
		LDA #$0B : STA !RexChase
		LDA #$30 : STA !AdeptFlyTimer
		LDA #$10 : STA $9E,x
		LDA #$07 : STA !SpriteAnimIndex
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
		LDA $3330,x
		AND #$04 : BNE ..Ground
		LDA !SpriteAnimIndex
		CMP #$07 : BEQ ..Return
		CMP #$08 : BEQ ..Return
		LDA #$07 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
..Return	RTS

		..Ground
		STZ $9E,x
		STZ $AE,x
		BIT !RexChase
		BMI +
		LDA #$80 : STA !RexChase
		LDA !SpriteAnimIndex
		CMP #$03 : BCC +
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

	+	BVS +
		LDA $14
		AND #$07
		BNE ..Return
		INC !RexChase
		LDA !RexChase
		AND #$0F : BNE ..Return
		LDA #$C0 : STA !RexChase

	+	STZ !SpriteAnimTimer
		LDA $14
		AND #$07
		BNE ..Return
		LDA !RexChase
		CMP #$D0 : BNE ..Petrify
		RTS

..Petrify	INC A
		STA !RexChase

		AND #$1F
		STA $00
		STZ $01
		STZ $2250
		REP #$20
		LDY #$1E

..ColorLoop	LDA .Pal+1,y			; > +1 instead of an additional XBA
		LSR #2
		AND #$001F
		STA $2251
		LDA #$0010
		SEC : SBC $00
		STA $2253
		NOP : BRA $00
		LDA $2306 : STA $02		; > Temp blue
		LDA .StatuePal+1,y		; > +1 instead of an additional XBA
		LSR #2
		AND #$001F
		STA $2251
		LDA $00 : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $02			; > Blue * 16
		ASL #6				; > Get into proper bit position
		AND #$7C00			;\ Store blue bits
		STA $02				;/

		LDA .Pal,y
		LSR #5
		AND #$001F
		STA $2251
		LDA #$0010
		SEC : SBC $00
		STA $2253
		NOP : BRA $00
		LDA $2306 : STA $04		; > Temp green
		LDA .StatuePal,y
		LSR #5
		AND #$001F
		STA $2251
		LDA $00 : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $04			; > Green * 16
		ASL A				; > Get into proper bit position
		AND #$03E0			;\ Store into memory (fused with blue)
		TSB $02				;/

		LDA .Pal,y
		AND #$001F
		STA $2251
		LDA #$0010
		SEC : SBC $00
		STA $2253
		NOP : BRA $00
		LDA $2306 : STA $04		; > Temp red
		LDA .StatuePal,y
		AND #$001F
		STA $2251
		LDA $00 : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $04			; > Red * 16
		LSR #4				; > Get into proper bit position
		ORA $02
		STA $6703+$1A2,y		; Color 0xD1
		DEY #2
		BMI $03 : JMP ..ColorLoop

		JSL $138030			;\ Get index to CGRAM table
		BCS +				;/
		PHB				;\
		PEA !VRAMbank*$100+!VRAMbank	; | Hopefully this bank wrapper works
		PLB : PLB			;/
		LDA #$001E			;\ Upload size
		STA !CGRAMtable+$00,y		;/
		LDA #$6703+$1A2			;\ Source
		STA !CGRAMtable+$02,y		;/
		LDA #$D100			;\ Dest CGRAM + bank byte (0x00)
		STA !CGRAMtable+$04,y		;/
		PLB
	+	SEP #$20
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
		LDA #$06 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$26 : STA !SPC4
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
		LDA #$07 : STA !SpriteAnimIndex
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
		CMP #$10 : BCC ++
		CMP #$13 : BCC +++
	++	LDA #$10 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA +++
	+	LDA !SpriteAnimIndex
		CMP #$10 : BCC +++
		CMP #$13 : BCS +++
		LDA #$09 : STA !SpriteAnimIndex
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
		LDA $32C0,x : STA $03		;/
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
		LDA #$03 : STA !SpriteAnimIndex
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
		SBC $32C0,x
		BPL ..Ascend
		LDA $9E,x : BMI +
		LDA #$08 : STA !RexChase
		STZ !AdeptFlyTimer
		LDA #$0A : STA !SpriteAnimIndex
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
		BIT !RexChase : BMI ..Accel
		LDA !RexChase
		ORA #$80
		STA !RexChase
		LDA !SpriteAnimIndex
		CMP #$16 : BCS +
		LDA #$16 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$2D : STA !SPC1
	+	JSR SUB_HORZ_POS
		TYA
		STA $3320,x

		..Accel
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
		LDA #$13 : STA !SpriteAnimIndex
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
		BPL $02 : LDY #$13
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
		STA $33C0,x
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
		ORA $33C0,x : STA $33C0,x
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
		LDA $33C0,x : STA $01		;/
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
		ORA #$0027			; |
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
		LDA #$AB00			;\ Get medium tile
		BRA ..WriteTile			;/

		..Tile1
		LDA #$AD00			; > Get small tile

		..WriteTile
		STA $0C				; > Save tile
		LDA .SpellCircle+$12,y		;\
		AND #$00FF			; | Write Ycoord + tile to tilemap
		ORA $0C				; |
		STA ($04)			;/
		INC $04				;\ Increment pointer
		INC $04				;/
		SEP #$20			; > A 8-bit

	++	DEX				;\ Loop
		BPL -				;/
		LDX !SpriteIndex		; > Restore X
		RTS

		..Bits
		db $01,$02,$04,$08,$10,$20,$40,$80

	; $34C0: Timer
	; $3390: Status 1
	; $33C0: Status 2
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
		db $A5,$A7,$A9		; 00-17
		db $A5,$A7,$A9		; 18-2F
		db $A5,$A7,$A9		; 30-47


	.AnimIdle
		dw .IdleTM00 : db $08,$01	; 00
		dw .IdleDyn00
		dw .IdleTM01 : db $08,$02	; 01
		dw .IdleDyn01
		dw .IdleTM02 : db $08,$00	; 02
		dw .IdleDyn02
	.AnimExtend
		dw .ExtendTM00 : db $08,$04	; 03
		dw .ExtendDyn00
		dw .ExtendTM01 : db $08,$05	; 04
		dw .ExtendDyn01
		dw .ExtendTM02 : db $08,$06	; 05
		dw .ExtendDyn02
	.AnimRising
		dw .FlapTM00 : db $04,$07	; 06
		dw .FlapDyn00
		dw .RisingTM00 : db $02,$08	; 07
		dw .RisingDyn00
		dw .RisingTM01 : db $02,$07	; 08
		dw .RisingDyn01
	.AnimHover
		dw .HoverTM00 : db $03,$0A	; 09
		dw .HoverDyn00
		dw .HoverTM01 : db $03,$0B	; 0A
		dw .HoverDyn01
		dw .HoverTM02 : db $03,$09	; 0B
		dw .HoverDyn02
	.AnimFlap
		dw .ExtendTM02 : db $08,$0D	; 0C
		dw .ExtendDyn02
		dw .FlapTM00 : db $06,$0E	; 0D
		dw .FlapDyn00
		dw .RisingTM00 : db $04,$0F	; 0E
		dw .RisingDyn00
		dw .ExtendTM01 : db $08,$09	; 0F
		dw .ExtendDyn01
	.AnimFDash
		dw .FDashTM : db $06,$11	; 10
		dw .FDashDyn00
		dw .FDashTM : db $06,$12	; 11
		dw .FDashDyn01
		dw .FDashTM : db $06,$10	; 12
		dw .FDashDyn02
	.AnimBDash
		dw .BDashTM : db $06,$14	; 13
		dw .BDashDyn00
		dw .BDashTM : db $06,$15	; 14
		dw .BDashDyn01
		dw .BDashTM : db $06,$13	; 15
		dw .BDashDyn02
	.AnimGrind
		dw .GrindTM00 : db $03,$17	; 16
		dw .FDashDyn00
		dw .GrindTM01 : db $03,$18	; 17
		dw $0000
		dw .GrindTM02 : db $03,$19	; 18
		dw .FDashDyn01
		dw .GrindTM03 : db $03,$1A	; 19
		dw $0000
		dw .GrindTM04 : db $03,$1B	; 1A
		dw .FDashDyn02
		dw .GrindTM05 : db $03,$16	; 1B
		dw $0000


	.IdleTM00
		dw $0014
		db $2A,$FE,$F0,$E8
		db $2A,$FC,$F0,$C8
		db $2A,$04,$F0,$C9
		db $2A,$FC,$00,$CB
		db $2A,$04,$00,$CC
	.IdleTM01
		dw $0014
		db $2A,$FE,$F0,$E8
		db $2A,$FC,$F0,$C8
		db $2A,$04,$F0,$C9
		db $2A,$FC,$00,$CB
		db $2A,$04,$00,$CC
	.IdleTM02
		dw $0014
		db $2A,$FE,$F0,$E8
		db $2A,$FC,$F0,$C8
		db $2A,$04,$F0,$C9
		db $2A,$FC,$00,$CB
		db $2A,$04,$00,$CC

	.ExtendTM00
		dw $0014
		db $2A,$FE,$F2,$E8
		db $2A,$FC,$F0,$CA
		db $2A,$04,$F0,$CB
		db $2A,$FC,$00,$EA
		db $2A,$04,$00,$EB
	.ExtendTM01
		dw $0014
		db $2A,$00,$F0,$E8
		db $2A,$F8,$F0,$CA
		db $2A,$08,$F0,$CC
		db $2A,$F8,$00,$EA
		db $2A,$08,$00,$EC
	.ExtendTM02
		dw $001C
		db $2A,$FF,$F0,$E8
		db $2A,$00,$F0,$CC
		db $2A,$F0,$F8,$DA
		db $2A,$10,$F8,$DE
		db $2A,$F0,$00,$EA
		db $2A,$00,$00,$EC
		db $2A,$10,$00,$EE

	.FlapTM00
		dw $001C
		db $2A,$0B-$C,$F0,$E8
		db $2A,$00-$C,$F0,$CA
		db $2A,$10-$C,$F0,$CC
		db $2A,$18-$C,$F0,$CD
		db $2A,$00-$C,$00,$EA
		db $2A,$10-$C,$00,$EC
		db $2A,$18-$C,$00,$ED
	.RisingTM00
		dw $001C
		db $2A,$0C-$C,$F1,$E8
		db $2A,$00-$C,$F0,$CA
		db $2A,$10-$C,$F0,$CC
		db $2A,$18-$C,$F0,$CD
		db $2A,$00-$C,$00,$EA
		db $2A,$10-$C,$00,$EC
		db $2A,$18-$C,$00,$ED
	.RisingTM01
		dw $001C
		db $2A,$0C-$C,$F1,$E8
		db $2A,$00-$C,$F0,$CA
		db $2A,$10-$C,$F0,$CC
		db $2A,$18-$C,$F0,$CD
		db $2A,$00-$C,$00,$EA
		db $2A,$10-$C,$00,$EC
		db $2A,$18-$C,$00,$ED

	.HoverTM00
		dw $0020
		db $2A,$00,$F0,$E8
		db $2A,$00,$EF,$C8
		db $2A,$F0,$F8,$CA
		db $2A,$00,$F8,$CC
		db $2A,$10,$F8,$CE
		db $2A,$F0,$00,$DA
		db $2A,$00,$00,$DC
		db $2A,$10,$00,$DE
	.HoverTM01
		dw $0020
		db $2A,$00,$F0,$E8
		db $2A,$00,$EF,$C8
		db $2A,$F0,$F8,$CA
		db $2A,$00,$F8,$CC
		db $2A,$10,$F8,$CE
		db $2A,$F0,$00,$DA
		db $2A,$00,$00,$DC
		db $2A,$10,$00,$DE
	.HoverTM02
		dw $0020
		db $2A,$00,$F0,$E8
		db $2A,$00,$EF,$C8
		db $2A,$F0,$F8,$CA
		db $2A,$00,$F8,$CC
		db $2A,$10,$F8,$CE
		db $2A,$F0,$00,$DA
		db $2A,$00,$00,$DC
		db $2A,$10,$00,$DE

	.FDashTM
		dw $0018
		db $2A,$FB,$F2,$E8
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED

	.BDashTM
		dw $001C
		db $2A,$03,$F2,$E8
		db $2A,$F4,$F8,$DA
		db $2A,$FC,$F0,$CB
		db $2A,$0C,$F0,$CD
		db $2A,$F4,$00,$EA
		db $2A,$FC,$00,$EB
		db $2A,$0C,$00,$ED

	.GrindTM00
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A5
		db $27,$0C+$0C,$FC-$06,$AD	; 3
		db $27,$0C+$06,$FC+$00,$AB	; 1
						; 5
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED
	.GrindTM01
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A5
		db $27,$0C+$10,$FC-$08,$AD	; 4
		db $27,$0C+$0C,$FC+$00,$AB	; 2
						; 6
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED
	.GrindTM02
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A7
						; 5
		db $27,$0C+$12,$FC+$00,$AD	; 3
		db $27,$0C+$04,$FC+$02,$AB	; 1
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED
	.GrindTM03
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A7
						; 6
		db $27,$0C+$18,$FC+$00,$AD	; 4
		db $27,$0C+$08,$FC+$04,$AB	; 2
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED
	.GrindTM04
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A9
		db $27,$0C+$04,$FC-$02,$AB	; 1
						; 5
		db $27,$0C+$0C,$FC+$06,$AD	; 3
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED
	.GrindTM05
		dw $0024
		db $2A,$FB,$F2,$E8
		db $27,$0C,$FC,$A9
		db $27,$0C+$08,$FC-$04,$AB	; 2
						; 6
		db $27,$0C+$10,$FC+$08,$AD	; 4
		db $2A,$F4,$F0,$CA
		db $2A,$04,$F0,$CC
		db $2A,$F4,$00,$EA
		db $2A,$04,$00,$EC
		db $2A,$0C,$00,$ED


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
	dl <SourceTile>*$20+$32B008
	dw <DestVRAM>*$10+$5000			; < Move everything to $0C0-$0FF area
endmacro

	.IdleDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $008, $1C8)
	%AdeptDyn(3, $018, $1D8)
	%AdeptDyn(3, $020, $1CB)
	%AdeptDyn(3, $030, $1DB)
	..End
	.IdleDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $008, $1C8)
	%AdeptDyn(3, $018, $1D8)
	%AdeptDyn(3, $023, $1CB)
	%AdeptDyn(3, $033, $1DB)
	..End
	.IdleDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $008, $1C8)
	%AdeptDyn(3, $018, $1D8)
	%AdeptDyn(3, $026, $1CB)
	%AdeptDyn(3, $036, $1DB)
	..End

	.ExtendDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(3, $00B, $1CA)
	%AdeptDyn(3, $01B, $1DA)
	%AdeptDyn(3, $02B, $1EA)
	%AdeptDyn(3, $03B, $1FA)
	..End
	.ExtendDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(4, $040, $1CA)
	%AdeptDyn(4, $050, $1DA)
	%AdeptDyn(4, $060, $1EA)
	%AdeptDyn(4, $070, $1FA)
	..End
	.ExtendDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(2, $04C, $1CC)
	%AdeptDyn(6, $05A, $1DA)
	%AdeptDyn(6, $06A, $1EA)
	%AdeptDyn(6, $07A, $1FA)
	..End

	.FlapDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $044, $1CA)
	%AdeptDyn(5, $054, $1DA)
	%AdeptDyn(5, $064, $1EA)
	%AdeptDyn(5, $074, $1FA)
	..End
	.RisingDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $080, $1CA)
	%AdeptDyn(5, $090, $1DA)
	%AdeptDyn(5, $0A0, $1EA)
	%AdeptDyn(5, $0B0, $1FA)
	..End
	.RisingDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $085, $1CA)
	%AdeptDyn(5, $095, $1DA)
	%AdeptDyn(5, $0A5, $1EA)
	%AdeptDyn(5, $0B5, $1FA)
	..End

	.HoverDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(2, $02E, $1C8)
	%AdeptDyn(2, $03E, $1D8)
	%AdeptDyn(6, $08A, $1CA)
	%AdeptDyn(6, $09A, $1DA)
	%AdeptDyn(6, $0AA, $1EA)
	..End
	.HoverDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(6, $0BA, $1CA)
	%AdeptDyn(6, $0CA, $1DA)
	%AdeptDyn(6, $0DA, $1EA)
	..End
	.HoverDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(6, $0EA, $1CA)
	%AdeptDyn(6, $0FA, $1DA)
	%AdeptDyn(6, $10A, $1EA)
	..End

	.FDashDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(4, $0C5, $1CA)
	%AdeptDyn(4, $0D5, $1DA)
	%AdeptDyn(5, $0E5, $1EA)
	%AdeptDyn(5, $0F5, $1FA)
	..End
	.FDashDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $125, $1EA)
	%AdeptDyn(5, $135, $1FA)
	..End
	.FDashDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $165, $1EA)
	%AdeptDyn(5, $175, $1FA)
	..End

	.BDashDyn00
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $0C0, $1CA)
	%AdeptDyn(5, $0D0, $1DA)
	%AdeptDyn(5, $0E0, $1EA)
	%AdeptDyn(5, $0F0, $1FA)
	..End
	.BDashDyn01
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $120, $1EA)
	%AdeptDyn(5, $130, $1FA)
	..End
	.BDashDyn02
	dw ..End-..Start
	..Start
	%AdeptDyn(5, $160, $1EA)
	%AdeptDyn(5, $170, $1FA)
	..End



;=================;
;REX HELP ROUTINES;
;=================;

REX_BEHAVIOUR:	JSR SPRITE_OFF_SCREEN

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


		LDA $BE,x
		BNE .NoHammer
		LDA !RexAI
		AND #$02
		BEQ .NoHammer
		JSR REX_HAMMER
		LDA !SpriteAnimIndex
		CMP #$0D
		BCC .NoHammer
		BNE .NoHammer
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		JMP .DontTurn
		.NoHammer

		LDA $35D0,x			;\ Decrement slam timer
		BEQ $03 : DEC $35D0,x		;/

		BIT !RexAI
		BVC .Chasing
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

		LDA !RexChase
		BNE .Chasing
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
		TYA				; |
		LDA .ChaseFlags-1,y		; |
		ORA !RexMovementFlags		; |
		STA !RexMovementFlags		; |
		LDA #$25			; \ Roar
		STA !SPC1			; /
		LDA #$1F			; |
		STA !RexChase			;/
		.Chasing

		LDA !RexAI
		LSR A
		BCC .NoJumping
		LDA !RexMovementFlags
		LSR A
		BCS .NoJumping
		LDA $3330,x
		AND #$04
		BNE .NoJumping
		LDA #$C0			;\
		STA $9E,x			; |
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

		LDA $3330,x			;\
		AND #$04			; | Use committed jump arcs
		BEQ .NoFollow			;/
		LDA $14				;\
		AND #$0F			; |
		BNE .NoFollow			; |
		BIT !RexMovementFlags		; |
		BVC .NoFollow			; |
		LDA !RexMovementFlags		; |
		AND #$20			; | Follow target player
		BEQ +				; |
		JSR SUB_HORZ_POS_2		; |
		BRA ++				; |
	+	JSR SUB_HORZ_POS		; |
	++	TYA				; |
		STA $3320,x			; |
		.NoFollow			;/

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
		LDA.w .XSpeed,y
		STA $AE,x
		LDA $3330,x
		AND #$04
		BEQ +

		LDA !RexMovementFlags
		AND #$02
		BEQ +
		PEA .Freeze-1
		JMP REX_AMBUSH
		+

		LDA !RexChase			;\ Don't move during chase init
		BNE .Freeze			;/
	+	STZ $00				; Clear slope data
		LDA $34D0,x			;\
		ORA $35D0,x			; | Don't move while this is set
		BNE .Freeze			;/
		LDA !RexAI
		AND #$02
		BEQ .NoFreeze
		LDA !SpriteAnimIndex		;\
		CMP #$0D			; |
		BEQ .Freeze			; | Don't move while preparing to throw hammer
		CMP #$0E			; |
		BEQ .Freeze			;/
.NoFreeze	LDA $3370,x			;\
		BEQ .ApplySpeed			; | YSpeed is always 0x10 on slopes
		LDA #$10 : STA $9E,x		;/
.ApplySpeed	BIT !RexMovementFlags		;\
		BPL +				; | YSpeed is always 0xF0 while climbing
		LDA #$F0			; |
		STA $9E,x			;/
	+	LDA $3330,x
		AND #$08
		BEQ +
		LDA #$10
		STA $9E,x
	+	JSL $01802A			; > Apply speed
.Freeze		BIT !RexMovementFlags		;\
		BPL +				; | Lock Xpos during climb
		LDA !RexWallX			; |
		STA $3220,x			;/
	+	PLA : STA $01			; > Store last frame's collision flags
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
		JSL $01802A			;/
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

		LDA $7490
		BEQ .NoStar
		JMP SPRITE_STAR
.NoStar		LDA $32E0,x : BNE -
		LDA #$08
		STA $32E0,x
		LDA !MarioYSpeed
		BMI .HurtMario
		CMP #$10
		BCC .HurtMario

.HurtRex	LDA !RexAI			;\
		AND #$04			; |
		BEQ +				; |
		LDA !Difficulty			; |
		AND #$03			; |
		CMP #$02 : BNE +		; | Perform slam on insane if brute
		LDA !RexMovementFlags		; |
		LSR A				; |
		BCC +				; |
		LDA #$10 : STA $35D0,x		; |
		STA $7887			; |
		LDA #$09 : STA !SPC4		; |
		LDA #$80 : STA !MarioYSpeed	; |
		BRA .HurtMario			;/

	+	STZ $32D0,x
		JSR REX_POINTS			; Give points
		JSL $01AA33			; Give Mario some bounce
		JSL $01AB99			; Display contact GFX
		LDA $740D
		ORA $787A
		BEQ .NoSpinKill
		LDA !RexAI			;\
		AND #$04			; |
		BEQ +				; |
		LDA !Difficulty			; | Brutes can only be spin-killed on easy
		AND #$03			; |
		BNE .NoSpinKill			;/
	+	JMP REX_SPINKILL

.HurtMario	LDA $7497
		ORA $787A
		BNE .NoContact
		JSR SUB_HORZ_POS
		TYA
		STA $3320,x
		JSL $00F5B7			; Hurt Mario
		RTS

.NoSpinKill	INC $BE,x
		LDA !RexAI			;\
		AND.b #$08^$FF			; | Enable movement after rex is hit
		STA !RexAI			;/

		AND #$04
		BEQ .NoBrute
		LDA $BE,x
		CMP #$03
		BCS .Kill
		LDA #$20
		STA !SPC1
		LDA #$0C
		STA $34D0,x
.NoContact	RTS

.NoBrute	LDA $BE,x
		CMP #$02
		BCC .SmushRex
.Kill		LDA #$20
		STA $32F0,x
		RTS
.SmushRex	LDA #$0C
		STA $34D0,x
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

.ChaseFlags	db $00,$20,$20



REX_POINTS:	PHY
		LDA $7697
		INC $7697
		TAY
		CPY #$07
		BCS .NoSound
		LDA !RexAI
		AND #$04
		BNE .NoSound
		LDA.w .StarSounds,y
		STA !SPC1
.NoSound	TYA
		INC A
		CMP #$08
		BCC .NoReset
		LDA #$08
.NoReset	JSL $02ACE5
		PLY
		RTS

.StarSounds	db $13,$14,$15,$16,$17,$18,$19


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
		LSR #2				; |
		CLC : ADC #$23			; |
		CLC : ADC.w .ThrowDelay,y	; |
		STA $32D0,x			;/
		LDA #$0D
		STA !SpriteAnimIndex
		RTS
.Prep		LDA $BE,x
		BNE .Return
		LDY #$EE
		JSR REX_HORZ_POS
		LDA $06
		BNE +
		LDY #$12
	+	STY $00
		LDY #$07
	-	LDA $770B,y
		BEQ .Throw
		DEY
		BPL -
.Return		RTS

.ThrowDelay	db $4F,$3F,$27			; EASY, NORMAL, INSANE

.Throw		LDA #$04			;\ Extended sprite number
		STA $770B,y			;/
		LDA #$00 : STA $776F,y		; > Default state (hammer belongs to enemy)
		PHY				;\
		LDA $3320,x			; |
		TAY				; |
		LDA $3220,x			; |
		CLC				; |
		ADC.w .X1,y			; |
		PLY				; | Xpos
		STA $771F,y			; |
		PHY				; |
		LDA $3320,x			; |
		TAY				; |
		LDA $3250,x			; |
		ADC.w .X2,y			; |
		PLY				; |
		STA $7733,y			;/
		LDA $3210,x			;\
		SEC : SBC #$09			; |
		STA $7715,y			; | Ypos
		LDA $3240,x			; |
		SBC #$00			; |
		STA $7729,y			;/
		LDA $3240,x			;\
		XBA				; |
		LDA $3210,x			; |
		REP #$20			; |
		SEC : SBC !P2YPosLo-$80		; |
		LSR #2				; |
		SEP #$20			; | Yspeed
		EOR #$FF			; |
		INC A				; |
		CLC : ADC #$C8			; |
		CMP #$C0			; |
		BCS +				; |
		LDA #$C0			; |
	+	STA $773D,y			;/
		LDA $3250,x			;\
		XBA				; |
		LDA $3220,x			; |
		REP #$20			; |
		SEC : SBC !P2XPosLo-$80		; | Xspeed
		LSR #2				; |
		SEP #$20			; |
		EOR #$FF			; |
		INC A				; |
		STA $7747,y			;/
		RTS				; > Return
.X1		db $04,$FE
.X2		db $00,$FF


SHAMAN_CAST:	LDA !Difficulty			;\
		AND #$03			; | Y = difficulty index
		TAY				;/
		LDA !ShamanCast
		BEQ .Fire
		CMP .CastTime,y
		BCC .Cast
		LDA !SpriteAnimIndex
		CMP #$09 : BCC .Return
		CMP #$0C : BCS .Return
		LDA #$01
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
.Return		RTS

.Fire		LDA !RNG			;\
		LSR #2				; | Wait a random number of frames
		CLC : ADC #$94			; |
		STA !ShamanCast			;/
		LDA #$01 : STA !SpriteAnimIndex	;\ Reset animation
		STZ !SpriteAnimTimer		;/
		BRA .Spawn

.Cast		LDA #$09			;\
		CMP !SpriteAnimIndex		; | Start cast animation
		BCC .Return			; |
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
		PHX
		TYX
		LDA #$07 : STA !NewSpriteNum,x	;\  > Custom sprite number
		LDA #$36 : STA $3200,x		; | > Sprite number
		LDA #$08 : STA $3230,x		; | > Sprite status
		JSL $07F7D2			; | \ Clear tables
		JSL $0187A7			; | /
		LDA #$08 : STA !ExtraBits,x	;/  > Custom sprite flag
		LDA #$A5 : STA $33D0,x		; > Base tile
		LDA #$08			;\ Don't interact with sprites for 8 frames
		STA $3300,y			;/
		LDA #$3C : STA $32D0,y		; > Life timer (1 sec)
		LDA #$82 : STA $BE,x		; > Behaviour (line + anim)
		LDA #$03 : STA $33E0,x		; > Number of frames (3)
		LDA #$05 : STA $3310,x		; > Animation frequency
		STX $00
		PLX
		LDY $3320,x			;\
		LDA DROP_MASK_MaskProp,y	; |
		PHA				; |
		LDA .CastXSpeed,y		; |
		LDY $00				; | Get projectile prop + speed
		STA $30AE,y			; |
		PLA				; |
		STA $33C0,y			; |
		LDA #$01 : STA $3410,y		;/

		RTS

.CastTime	db $40,$30,$20			; EASY, NORMAL, INSANE
.CastXSpeed	db $20,$E0			; Right, left


DROP_MASK:	LDA !RexMovementFlags		;\
		AND.b #$10^$FF			; | Drop mask
		STA !RexMovementFlags		;/

		LDA !RNG			;\
		LSR #2				; | Reset spell cast
		CLC : ADC #$94			; |
		STA !ShamanCast			;/

.Spawn		JSL $02A9DE			;\ Get sprite slot
		BMI .Return			;/

		LDA $3220,x			;\
		STA $3220,y			; | Same Xpos
		LDA $3250,x			; |
		STA $3250,y			;/
		LDA $3210,x			;\
		SEC : SBC #$0E			; |
		STA $3210,y			; | Spawn 0x0E px above
		LDA $3240,x			; |
		SBC #$00			; |
		STA $3240,y			;/
		LDA !ShamanMask
		TAX
		LDA NOVICESHAMAN_MaskTile,x
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
		PLA				;\ GFX tile
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
		PLY				; | Set direction, Xspeed, and property
		STA $33C0,y			; |
		LDA #$01 : STA $3410,y		; |
		STA $30AE,y			; |
		LDA $3320,x			; |
		STA $3320,y			;/

.Return		RTS

.XSpeed		db $10,$F0

.MaskProp	db $67,$27


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

.Spray		LDA $3220,x : STA $3220,y
		LDA $3250,x : STA $3250,y
		LDA $3210,x : STA $3210,y
		LDA $3240,x : STA $3240,y
		JSR .SetMode
		LDA !RNG
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
.SetMode	PHX
		TYX
		LDA #$07 : STA !NewSpriteNum,x	;\  > Custom sprite number
		LDA #$36 : STA $3200,x		; | > Sprite number
		LDA #$08 : STA $3230,x		; | > Sprite status
		JSL $07F7D2			; | \ Clear tables
		JSL $0187A7			; | /
		LDA #$08 : STA !ExtraBits,x	;/  > Custom sprite flag
		LDA #$FF : STA $32D0,x		; > Life timer (max)
		LDA #$A5 : STA $33D0,x		; > Base tile
		LDA #$82 : STA $BE,x		; > Behaviour (line + anim)
		LDA #$03 : STA $33E0,x		; > Number of frames (3)
		LDA #$05 : STA $3310,x		; > Animation frequency
		STX $00
		PLX
		LDY $3320,x			;\
		LDA DROP_MASK_MaskProp,y	; |
		STA $01				; |
		LDA .XSpeed,y			; |
		LDY $00				; | Get projectile prop + Xspeed
		STA $30AE,y			; |
		LDA $01 : STA $33C0,y		; |
		LDA #$01 : STA $3410,y		;/

.Return		RTS

.XSpeed		db $40,$C0


SPRAY_CHECK:	LDY $3320,x
		LDA $3220,x
		CLC : ADC .XDisp,y
		STA $00
		LDA $3250,x
		ADC .XDisp+2,y
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		LDA !RexAI
		AND #$20
		REP #$20
		BNE .P2

.P1		LDA !MarioXSpeed-1
		AND #$FF00
		BPL $03 : ORA #$00FF
		XBA
		CLC : ADC !P2XPosLo-$80
		SEC : SBC $00
		BCC .NoContact
		CMP #$0028
		BCS .NoContact
		LDA !P2YPosLo-$80
		SEC : SBC $02
		BCC .NoContact
		CMP #$0080
		BCS .NoContact
		BRA .Contact

.P2		LDA !P2XSpeed-1
		AND #$FF00
		BPL $03 : ORA #$00FF
		XBA
		CLC : ADC !P2XPosLo
		SEC : SBC $00
		BCC .NoContact
		CMP #$0028
		BCS .NoContact
		LDA !P2YPosLo
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
		STZ $2250		; > Enable multiplication
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
		JSR GET_ROOT		; (handles 17-bit numbers)
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


ADEPT_ROUTE:
.1		STZ $2250			; > Enable multiplication
		STA $0F				; > Store hit type (0 = hit, 1 = stomp)
		LDA $3220,x : STA $00		;\
		LDA $3250,x : STA $01		; | Sprite coords
		LDA $3210,x : STA $02		; |
		LDA $3240,x : STA $03		;/
		LDA #$0B : STA !AdeptFlyTimer
		REP #$20
		LDA !MarioXSpeed-1
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
		LDA #$3096 : STA $06
		LDA !MarioYSpeed-1
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

.GetNode	PHA				; > Preserve X
		LDA $2306			;\
		CMP #$0100 : BCS .Node0		; > Edge case check for node 0 (K < 256)
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







; Load unsigned 17-bit number in A + carry, then JSR here.
; A returns in same mode as before (PHP : PLP)
; A holds square root of input number.
GET_ROOT:	PHX
		PHP
		REP #$30
		BCS .010000
		CMP #$4000 : BCS .4000
		CMP #$1000 : BCS .1000
		CMP #$0400 : BCS .0400
		CMP #$0100 : BCS .0100
		ASL A
		TAX
		LDA.w .Table,x
		PLP
		PLX
		RTS

.010000		ROR A
		LSR A
.4000		XBA
		AND #$00FE
		ASL A
		TAX
		LDA.w .Table,x
		ASL #4
		PLP
		PLX
		BCC +
		ASL A
	+	RTS

.1000		XBA
		ROL #2
		AND #$00FE
		ASL A
		TAX
		LDA.w .Table,x
		ASL #3
		PLP
		PLX
		RTS

.0400		LSR #3
		AND #$FFFE
		TAX
		LDA.w .Table,x
		ASL #2
		PLP
		PLX
		RTS

.0100		LSR A
		AND #$FFFE
		TAX
		LDA.w .Table,x
		ASL A
		PLP
		PLX
		RTS

; Shifted 8 bits left to account for "hexadecimals"
.Table		dw $0000,$0100,$016A,$01BB,$0200,$023C,$0273,$02A5	; 00-07
		dw $02D4,$0300,$032A,$0351,$0377,$039B,$03BE,$03DF	; 08-0F
		dw $0400,$0420,$043E,$045C,$0479,$0495,$04B1,$04CC	; 10-17
		dw $04E6,$0500,$0519,$0532,$054B,$0563,$057A,$0591	; 18-1F
		dw $05A8,$05BF,$05D5,$05EB,$0600,$0615,$062A,$063F	; 20-27
		dw $0653,$0667,$067B,$068F,$06A2,$06B5,$06C8,$06DB	; 28-2F
		dw $06EE,$0700,$0712,$0724,$0736,$0748,$0759,$076B	; 30-37
		dw $077C,$078D,$079E,$07AE,$07BF,$07CF,$07E0,$07F0	; 38-3F
		dw $0800,$0810,$0820,$082F,$083F,$084E,$085E,$086D	; 40-47
		dw $087C,$088B,$089A,$08A9,$08B8,$08C6,$08D5,$08E3	; 48-4F
		dw $08F2,$0900,$090E,$091C,$092A,$0938,$0946,$0954	; 50-57
		dw $0961,$096F,$097D,$098A,$0997,$09A5,$09B2,$09BF	; 58-5F
		dw $09CC,$09D9,$09E6,$09F3,$0A00,$0A0D,$0A19,$0A26	; 60-67
		dw $0A33,$0A3F,$0A4C,$0A58,$0A64,$0A71,$0A7D,$0A89	; 68-6F
		dw $0A95,$0AA1,$0AAD,$0AB9,$0AC5,$0AD1,$0ADD,$0AE9	; 70-77
		dw $0AF4,$0B00,$0B0C,$0B17,$0B23,$0B2E,$0B3A,$0B45	; 78-7F
		dw $0B50,$0B5C,$0B67,$0B72,$0B7D,$0B88,$0B93,$0B9E	; 80-87
		dw $0BA9,$0BB4,$0BBF,$0BCA,$0BD5,$0BE0,$0BEB,$0BF5	; 88-8F
		dw $0C00,$0C0B,$0C15,$0C20,$0C2A,$0C35,$0C3F,$0C4A	; 90-97
		dw $0C54,$0C5F,$0C69,$0C73,$0C7D,$0C88,$0C92,$0C9C	; 98-9F
		dw $0CA6,$0CB0,$0CBA,$0CC4,$0CCE,$0CD8,$0CE2,$0CEC	; A0-A7
		dw $0CF6,$0D00,$0D0A,$0D14,$0D1D,$0D27,$0D31,$0D3B	; A8-AF
		dw $0D44,$0D4E,$0D57,$0D61,$0D6B,$0D74,$0D7E,$0D87	; B0-B7
		dw $0D91,$0D9A,$0DA3,$0DAD,$0DB6,$0DBF,$0DC9,$0DD2	; B8-BF
		dw $0DDB,$0DE4,$0DEE,$0DF7,$0E00,$0E09,$0E12,$0E1B	; C0-C7
		dw $0E24,$0E2D,$0E36,$0E3F,$0E48,$0E51,$0E5A,$0E63	; C8-CF
		dw $0E6C,$0E75,$0E7E,$0E87,$0E8F,$0E98,$0EA1,$0EAA	; D0-D7
		dw $0EB2,$0EBB,$0EC4,$0ECC,$0ED5,$0EDE,$0EE6,$0EEF	; D8-DF
		dw $0EF7,$0F00,$0F09,$0F11,$0F1A,$0F22,$0F2A,$0F33	; E0-E7
		dw $0F3B,$0F44,$0F4C,$0F54,$0F5D,$0F65,$0F6D,$0F76	; E8-EF
		dw $0F7E,$0F86,$0F8E,$0F97,$0F9F,$0FA7,$0FAF,$0FB7	; F0-F7
		dw $0FBF,$0FC8,$0FD0,$0FD8,$0FE0,$0FE8,$0FF0,$0FF8	; F8-FF

