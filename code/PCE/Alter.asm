;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Alter

; --Build 0.1--
;


; have an orb floating around Alter, representing her current element
; Y/X is attack spell
; A is utility spell
; L is movement spell
;
; mana bar goes up to 120 (0x78)
; mana naturally regenerates 1 every 4 frames
; when a spell is cast, regeneration is paused for 1 second (0x3C frames)
; if Alter lacks mana for the spell she is trying to cast, that spell is cast anyway, but she enters "mana lock"
; during mana lock, her mana bar is red, showing that she can not cast
; mana lock ends when mana reaches the cost of the spell that triggered it
;
;
; how to make:
; - levitate: very easy, just stop her gravity and let her move with L/R/U/D
; - telekinesis: have some checks for different enemies to make sure there's no jank, but just using stasis should work
; - launch: use the vector registers, with an extra check in Alter's code that damages the object on impact
; - time walk: try pausing the game and have Alter's code running at the same time, make sure she can't interact
; - stasis: just using the stasis register + decrementing the animation timer for custom sprites should be enough
;	    use platform interaction for sprite hit by stasis
; - destroy: really just a big hitbox
; - create: the familiar should be able to fit into Alter's data
; - transmute: have a check for sprite type, then transform into a coin if valid, otherwise... maybe deal damage?
;
; Omega Rune:
; when omega rune is activated, Alter gets all her orbs at the same time
; in this state, she has unlimited mana and can use all spells of the same button at the same time:
; - attack: explosion that launches enemies
; - utility: still the same, otherwise it would just be obnoxious
; - movement: time stops while floating (familiar is permanently summoned during omega rune)




	MAINCODE:
		PHB : PHK : PLB
		LDA #$04 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
		LDA !P2Status : BEQ .Process
		STZ !P2Invinc
		CMP #$02 : BEQ .SnapToP1
		CMP #$03 : BNE .KnockedOut

		.Snapped			; State 03
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

		.KnockedOut
		REP #$20
		LDA !P2YPosLo
		CLC : ADC #$0004
		STA !P2YPosLo
		SEC : SBC $1C
		CMP #$0180
		SEP #$20
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		LDA #$41 : STA !P2Anim
		STZ !P2AnimTimer
	;	JMP ANIMATION_HandleUpdate
	JMP GRAPHICS


		.SnapToP1
		REP #$20
		LDA !P2XPosLo
		CMP $94
		BCS +
		ADC #$0004
		BRA ++
	+	SBC #$0004
	++	STA !P2XPosLo
		SEC : SBC $94
		BPL $03 : EOR #$FFFF
		CMP #$0008
		BCS +
		INC !P2Status
	+	SEP #$20

		.Return
		PLB
		RTS

		.Process
		LDA !P2MaxHP				;\
		CMP !P2HP				; | Enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform				;\
		BEQ ++					; |
		CMP !P2SpritePlatform : BEQ +		; | Account for platforms
	++	STA !P2PrevPlatform			; |
		+					;/


		LDA !P2StasisSpell : BEQ .NoStasis
		DEC A
		TAX
		LDA $34E0,x : BNE .NoStasis
		STZ !P2StasisSpell
		.NoStasis


		LDA !P2LaunchTimer : BEQ .NoLaunch
		LDA !P2Launch
		AND #$7F : BEQ .NoLaunch
		DEC A
		TAX
		LDA $3330,x
		AND #$03
		BEQ ++
		JSR Damage
		LDA #$01 : STA !P2LaunchTimer
		BRA +

	++	STZ $34E0,x
		LDY #$00
		BIT !P2Launch
		BPL $01 : INY
		LDA Launch_Speed,y
		STA $AE,x
		STZ $9E,x
		JSL !SpriteApplySpeed
		LDA #$02 : STA $34E0,x
	+	DEC !P2LaunchTimer
		BNE .NoLaunch
		STZ !P2Launch
		.NoLaunch

		LDA !P2FamiliarXLo
		ORA !P2FamiliarXHi
		ORA !P2FamiliarYLo
		ORA !P2FamiliarYHi
		BEQ .NoFamiliar

		REP #$20
		LDA !P2XPosLo
		CMP !P2FamiliarXLo
		BCC .L
	.R	INC !P2FamiliarXLo
		BRA $03
	.L	DEC !P2FamiliarXLo
		LDA !P2YPosLo
		SEC : SBC #$0020
		CMP !P2FamiliarYLo
		BCC .U
	.D	INC !P2FamiliarYLo
		BRA $03
	.U	DEC !P2FamiliarYLo
		SEP #$20

		LDA !P2Blocked
		AND #$04 : BEQ .NoFamiliar
		LDA #$01 : STA !P2DoubleJump
		.NoFamiliar

		LDA !P2ManaTimer : BEQ +
		DEC !P2ManaTimer
		BRA ++

	+	LDA !P2Mana
		CMP #$78 : BEQ ++
		LDA $14
		AND #$03 : BNE ++
		INC !P2Mana
	++	LDA !P2Mana
		CMP !P2ManaLock : BCC +
		STZ !P2ManaLock
		+




	PIPE:
		JSR CORE_PIPE
		BCC CONTROLS
		LDA #$04 : TRB $6DA3
	;	JMP ANIMATION_HandleUpdate
	JMP GRAPHICS


	CONTROLS:
		PEA.w PHYSICS-1

		LDA $6DA9
		AND #$10 : BEQ .NoSwap
		LDA !P2Element
		INC A
		CMP #$03
		BNE $02 : LDA #$00
		STA !P2Element
		LDA !P2Telekinesis : BEQ +
		STZ !P2Telekinesis
		STA !P2StasisSpell
		DEC A
		TAX
		LDA #$40 : STA $34E0,x
		BRA .NoSwap
	+	LDA !P2StasisSpell : BEQ .NoSwap
		DEC A
		TAX
		JSR Transmute_Success
		.NoSwap


		LDA !P2ManaLock : BNE .EndTelekinesis
		BIT $6DA5 : BPL .EndTelekinesis
		LDA !P2Telekinesis : BEQ .NoTelekinesis
		DEC A
		TAX
		LDA #$02
		STA $34E0,x
		STA !P2Stasis
		LDA $6DA3
		AND #$03
		TAY
		LDA $3220,x
		CLC : ADC .TelekinesisOffset,y
		STA $3220,x
		LDA $3250,x
		ADC .TelekinesisOffset_hi,y
		STA $3250,x
		LDA $6DA3
		LSR #2
		AND #$03
		TAY
		LDA $3210,x
		CLC : ADC .TelekinesisOffset,y
		STA $3210,x
		LDA $3240,x
		ADC .TelekinesisOffset_hi,y
		STA $3240,x
		LDA #$01 : JSR SpendMana
		RTS

		.EndTelekinesis
		STZ !P2Telekinesis
		.NoTelekinesis


		LDA !P2ManaLock : BNE .NoLevitate
		LDA !P2Element : BNE .NoLevitate
		LDA $6DA5
		AND #$20 : BEQ .NoLevitate
		LDA $6DA3
		AND #$03
		TAY
		LDA .AllRangeXSpeed,y : STA !P2XSpeed
		LDA .AllRangeYSpeed,y : STA !P2YSpeed
		LDA #$01 : JSR SpendMana
		RTS
		.NoLevitate
		



		LDA $6DA3
		AND #$03
		TAX
		LDA .Dir,x
		BMI $03 : STA !P2Direction
		LDA .XSpeed,x : STA !P2XSpeed
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BNE .Ground

		.Air
		LDA !P2DoubleJump : BEQ +		; double jump
		BIT $6DA7 : BPL +
		STZ !P2DoubleJump
		BRA .Jump
	+	BIT $6DA3 : BMI .NoJump
		LDA !P2YSpeed : BPL .NoJump
		STZ !P2YSpeed
		BRA .NoJump

		.Ground
		BIT $6DA7 : BPL .NoJump
	.Jump	LDA #$A0 : STA !P2YSpeed
		.NoJump

		RTS


		.XSpeed
		db $00,$28,$D8,$00

		.Dir
		db $FF,$01,$00,$FF

		.TelekinesisOffset
		db $00,$01,$FF,$00
	..hi	db $00,$00,$FF,$00


		.AllRangeXSpeed
		db $00,$20,$E0,$00
	;	db $00,$17,$E9,$00
	;	db $00,$17,$E9,$00
	;	db $00,$20,$E0,$00

		.AllRangeYSpeed
		db $00,$00,$00,$00
	;	db $20,$17,$17,$20
	;	db $E0,$E9,$E9,$E0
	;	db $00,$00,$00,$00



	PHYSICS:




	ATTACKS:
LDA !P2Mana : STA !P1Coins

		PEA.w SPRITE_INTERACTION-1
		LDA !P2ManaLock : BNE .NoL		; can't cast during mana lock


		LDA $6DA7
		ORA $6DA9
		AND #$40 : BEQ .NoX
		LDA !P2Element
		BNE $03 : JMP Launch
		DEC A
		BNE $03 : JMP TimeAttack
		DEC A
		BNE $03 : JMP Destroy
		.NoX

		BIT $6DA9 : BPL .NoA
		LDA !P2Element
		BNE $03 : JMP Telekinesis
		DEC A
		BNE $03 : JMP Stasis
		DEC A
		BNE $03 : JMP Transmute
		.NoA

		LDA $6DA9
		AND #$20 : BEQ .NoL
		LDA !P2Element
		BNE $03 : JMP Levitate
		DEC A
		BNE $03 : JMP TimeWalk
		DEC A
		BNE $03 : JMP Create
		.NoL

		RTS




	Launch:
		LDA !P2Telekinesis : BEQ +
		DEC A
		TAX
		STZ !P2Telekinesis
		BRA .Success

	+	JSR Hitbox
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ ++
		CMP #$08 : BCC +
	++	JSL !GetSpriteClipping04
		JSL !CheckContact
		BCC +

		JSR .Success

	+	DEX : BPL -
		RTS

		.Success
		LDA #$14 : JSR SpendMana
		LDY !P2Direction
		LDA .Speed,y
		STA $AE,x
		LDA #$02 : STA $34E0,x
		TXA
		CPY #$00
		BEQ $02 : ORA #$80
		INC A
		STA !P2Launch
		LDA #$30 : STA !P2LaunchTimer
		RTS

		.Speed
		db $D0,$30


	TimeAttack:
		RTS

	Destroy:
		LDA #$14 : JSR SpendMana
		JSR Hitbox
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ ++
		CMP #$08 : BCC +
	++	JSL !GetSpriteClipping04
		JSL !CheckContact
		BCC +
		JSR Damage
	+	DEX : BPL -
		RTS

	Telekinesis:
		JSR Hitbox
		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		JSL !GetSpriteClipping04
		JSL !CheckContact
		BCC +
		STX !P2Telekinesis
		INC !P2Telekinesis
		LDA #$02 : STA $34E0,x			; set stasis for sprite
	+	DEX : BPL -
		RTS


	Stasis:
		LDA #$14 : JSR SpendMana
		JSR Hitbox
		LDX #$0F
	-	LDA $3230,x : BEQ +
		JSL !GetSpriteClipping04
		JSL !CheckContact
		BCC +
		LDY !P2StasisSpell : BEQ ++
		DEY
		LDA #$00 : STA $34E0,y
	++	LDA #$40 : STA $34E0,x
		STX !P2StasisSpell
		INC !P2StasisSpell
	+	DEX : BPL -
		RTS


	Transmute:
		JSR Hitbox
		LDX #$0F
	-	LDA $3230,x : BEQ +
		LDA $3460,x
		AND #$10 : BNE +			; fireball killing must be enabled
		JSL !GetSpriteClipping04
		JSL !CheckContact
		BCC +
		JSR .Success
	+	DEX : BPL -
		RTS

		.Success
		LDA #$14 : JSR SpendMana
		LDA #$21 : STA $3200,x
		STZ $35C0,x
		LDA #$01 : STA $3230,x
		LDA $3590,x
		AND.b #$0C^$FF
		STA $3590,x
		JSL $07F7D2			; | > Reset sprite tables
		RTS


	Levitate:
		RTS
	TimeWalk:
		RTS
	Create:
		LDA #$3C : JSR SpendMana
		REP #$20
		LDA !P2XPosLo : STA !P2FamiliarXLo
		LDA !P2YPosLo : STA !P2FamiliarYLo
		SEP #$20
		RTS



	Hitbox:
		REP #$20
		LDA #$5050 : STA $02
		LDA !P2XPosLo
		SEC : SBC #$0020
		STA $00
		STA $07
		LDA !P2YPosLo
		SEC : SBC #$0020
		SEP #$20
		STA $01
		XBA : STA $09
		RTS



; load A with amount of mana to spend, then JSR here

	SpendMana:
		STA $00
		CMP !P2Mana : BCC .Ok

	.Lock	STZ !P2Mana
		LDA #$78 : STA !P2ManaTimer
		LDA $00 : STA !P2ManaLock
		RTS

	.Ok	LDA !P2Mana
		SEC : SBC $00
		STA !P2Mana
		LDA #$3C : STA !P2ManaTimer
		RTS



	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA !P2Platform
		BEQ .Main
		AND #$0F
		TAX
		LDA $9E,x : STA !P2YSpeed
		LDA $3260,x : STA !P2YFraction
		LDA !P2Blocked : PHA
		LDA !P2XSpeed : PHA
		LDA !P2XFraction : PHA
		BIT !P2Platform
		BVC .Horizontal

		.Vertical
		STZ !P2XSpeed
		BRA .Platform

		.Horizontal
		LDA $AE,x : STA !P2XSpeed
		LDA $3270,x : STA !P2XFraction

		.Platform
		JSR CORE_UPDATE_SPEED
		PLA : STA !P2XFraction
		PLA : STA !P2XSpeed
		PLA : TSB !P2Blocked
		STZ !P2YSpeed

		.Main
		BIT !P2Water : BVC +
		LDA !P2YSpeed : BMI +
		CMP #$28 : BCC +
		LDA #$28 : STA !P2YSpeed
	+	JSR CORE_UPDATE_SPEED
		LDA !P2Platform : BEQ +
		LDA #$04 : TSB !P2Blocked
	+	BIT !P2Water : BVC +
		LDA !P2Blocked
		AND #$04 : BNE +
		DEC !P2YSpeed
		+



	OBJECTS:
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y				;\
		STA $F0					; |
		CLC : ADC #$0004			; | Pointers to clipping
		STA $F2					; |
		CLC : ADC #$0004			; |
		STA $F4					;/
		SEP #$30
		JSR CORE_LAYER_INTERACTION
		.End

		JSR CORE_CLIMB_GROUND

	SCREEN_BORDER:
		JSR CORE_SCREEN_BORDER

	ANIMATION:


	GRAPHICS:
		REP #$20
		LDA .Tilemap+0 : STA !BigRAM+0
		LDA .Tilemap+2 : STA !BigRAM+2
		LDA .Tilemap+4 : STA !BigRAM+4
		LDA.w #!BigRAM : STA $04
		SEP #$20

		LDA !P2Element
		INC A
		ASL A
		TSB !BigRAM+2

		REP #$20
		LDA !P2FamiliarXLo
		ORA !P2FamiliarYLo
		BEQ +
		LDA !BigRAM
		CLC : ADC #$0004
		STA !BigRAM
		LDA !P2FamiliarXLo
		SEC : SBC !P2XPosLo
		STA !BigRAM+7
		LDA !P2FamiliarYLo
		SEC : SBC !P2YPosLo
		STA !BigRAM+8
		SEP #$20
		LDA #$06 : STA !BigRAM+6
		LDA #$C8 : STA !BigRAM+9

	+	SEP #$20
		JSR CORE_LOAD_TILEMAP


		PLB
		RTS


	.Tilemap
	dw $0004
	db $30,$00,$FF,$84


	ANIM:
		dw GRAPHICS_Tilemap : db $FF,$00
		dw .Dyn
		dw .Clipping

	.Dyn
	dw $FFFF




	.Clipping
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size




	Damage:
		LDA $3590,x
		AND #$08
		BEQ .LoBlock

		.HiBlock
		LDY $35C0,x
		LDA HIT_TABLE+$100,y
		BRA .AnyBlock

		.LoBlock
		LDY $3200,x
		LDA HIT_TABLE,y

		.AnyBlock
		ASL A : TAY
		PEA .End-1
		REP #$20
		LDA HIT_Ptr+0,y
		DEC A
		PHA
		SEP #$20
		RTS

		.End
		RTS


	HIT_Ptr:
	dw HIT_00
	dw HIT_01
	dw HIT_02
	dw HIT_03
	dw HIT_04
	dw HIT_05
	dw HIT_06
	dw HIT_07
	dw HIT_08
	dw HIT_09
	dw HIT_0A
	dw HIT_0B
	dw HIT_0C
	dw HIT_0D
	dw HIT_0E
	dw HIT_0F
	dw HIT_10
	dw HIT_11
	dw HIT_12
	dw HIT_13
	dw HIT_14
	dw HIT_15
	dw HIT_16
	dw HIT_17
	dw HIT_18
	dw HIT_19
	dw HIT_1A
	dw HIT_1B	; < Captain Warrior
	dw HIT_1C
	dw HIT_1D


	HIT_00:
		RTS

	HIT_01:
		; Knock out always
		JMP KNOCKOUT

	HIT_02:
		; Knock out of shell, send shell flying
		LDA $3230,x
		CMP #$02 : BEQ .Knockback
		CMP #$08 : BEQ .Standard
		CMP #$09 : BEQ .Knockback
		CMP #$0A : BNE HIT_00
		LDA $3200,x			;\
		CMP #$07 : BNE .Knockback	; | Shiny shell is immune to attacks
		LDA #$02 : STA !SPC1		; |
		RTS				;/

		.Knockback
		JSR CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		JMP KNOCKBACK

		.Standard
		LDA $3200,x
		CMP #$08
		BCS .Stun

		JSL $02A9DE			; Get new sprite number into Y
		BMI .Stun			; If there are no empty slots, don't spawn

		LDA $3200,x
		SEC : SBC #$04
		STA $3200,y			; Store sprite number for new sprite
		LDA #$08 : STA $3230,y		; > Status: normal
		LDA $3220,x			;\
		STA $3220,y			; |
		LDA $3250,x			; |
		STA $3250,y			; | Set positions
		LDA $3210,x			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		STA $3240,y			;/
		PHX				;\
		TYX				; | Reset tables for new sprite
		JSL $07F7D2			; |
		PLX				;/
		LDA #$10			;\
		STA $32B0,y			; | Some sprite tables that SMW normally sets
		STA $32D0,y			; |
		LDA #$01 : STA $3310,y		;/


		LDA CORE_BITS,y
		CPY #$08
		BCS +
		TSB !P2IndexMem1
		BRA ++
		+
		TSB !P2IndexMem2
		++

		LDA #$10 : STA $3300,y		; > Temporarily disable player interaction
		LDA $3430,x			;\ Copy "is in water" flag from sprite
		STA $3430,y			;/
		LDA #$02 : STA $32D0,y		;\ Some sprite tables
		LDA #$01 : STA $30BE,y		;/

		PHX
		LDA !P2Direction
		EOR #$01
		STA $3320,y
		TAX				; X = new sprite direction
		LDA CORE_KOOPA_XSPEED,x		; Load X speed table indexed by direction
		STA $30AE,y			; Store to new sprite X speed
		PLX

		.Stun
		LDA #$09 : STA $3230,x		; > Stun sprite
		LDA $3200,x			;\
		CMP #$08			; | Check if sprite is a Koopa
		BCC .DontStun			;/
		LDA #$FF : STA $32D0,x		; > Stun if not

		.DontStun
		RTS


	HIT_03:
		; Knock back and clip wings
		LDA $3230,x
		CMP #$08
		BNE HIT_02_DontStun
		LDA $3200,x			; Load sprite sprite number
		SEC : SBC #$08			; Subtract base number of Parakoopa sprite numbers
		TAY
		LDA CORE_PARAKOOPACOLOR,y	; Load new sprite number
		STA $3200,x			; Set new sprite number
		LDA #$01 : STA $3230,x		; > Initialize sprite
		JSR CORE_ATTACK_Main
		JMP KNOCKBACK

	HIT_04:
		; Knock back and stun
		LDA $3230,x
		CMP #$08
		BEQ .Main
		CMP #$09
		BNE HIT_07

		.Main
		JSR CORE_ATTACK_Main
		LDA $3200,x
		CMP #$40
		BEQ .ParaBomb
		LDA #$09			;\
		STA $3230,x			; | Regular Bobomb code (stuns it)
		BRA .Shared			;/

		.ParaBomb
		LDA #$0D : STA $3200,x		; > Sprite = Bobomb
		LDA #$01 : STA $3230,x		; > Initialize sprite
		JSL $07F7D2			; > Reset sprite tables

		.Shared
		JMP KNOCKBACK

	HIT_05:
		; Knock back and stun
		LDA $3230,x
		CMP #$08
		BEQ .Main
		CMP #$09
		BNE HIT_07

		.Main
		JSR CORE_ATTACK_Main
		LDA #$09 : STA $3230,x
		LDA #$FF : STA $32D0,x
		JMP KNOCKBACK

	HIT_06:
		; Knock back, stun, and clip wings
		LDA $3230,x
		CMP #$08
		BNE HIT_07
		LDA #$0F : STA $3200,x		; Set new sprite number
		JSL $07F7D2			; Reset sprite tables
		BRA HIT_05_Main			; Handle like normal

	HIT_07:
		; Do nothing
		RTS

	HIT_08:
		; Knock out always
	HIT_09:
		; Knock out always
	HIT_0A:
		; Knock out always
		JMP KNOCKOUT

	HIT_0B:
		; Collect
		JMP CORE_INT_0B+3		; skip LDX $7695 to avoid index confusion

	HIT_0C:
		; Knock out if at same depth
		LDA $3410,x			;\ Don't process interaction while sprite is behind scenery
		BNE HIT_0D			;/
		JMP KNOCKOUT

	HIT_0D:
		; Do nothing
		RTS

	HIT_0E:
		; Collapse
		LDA $32C0,x
		BNE .Return
		LDA #$01 : STA $32C0,x
		LDA #$FF : STA $32D0,x
		LDA #$07 : STA !SPC1
		LDY !P2Direction
		JMP KNOCKBACK_GFX

		.Return
		RTS


	HIT_0F:
		; Do nothing
		RTS

	HIT_10:
		; Stun and damage
		JSR CORE_ATTACK_Main
		STZ $3420,x			; Reset unknown sprite table
		LDA $BE,x			;\
		CMP #$03			; |
		BEQ HIT_0F			;/> Return if sprite is still recovering from a stomp
		INC $32B0,x			; Increment sprite stomp count
		LDA $32B0,x
		CMP #$03
		BEQ .Kill
		LDA #$03 : STA $BE,x		; Stun sprite
		LDA #$03 : STA $32D0,x		; Set sprite stunned timer to 3 frames
		STZ $3310,x			; Reset follow player timer
		LDY !P2Direction
		JMP KNOCKBACK_GFX

		.Kill
		JMP KNOCKOUT


	HIT_11:
		; Do nothing
		RTS

	HIT_12:
		; Knock out if emerged
		LDA $BE,x			;\
		BEQ .Return			; | Only interact if sprite has emerged from the ground
		LDA $32D0,x			; |
		BEQ .Process			;/

		.Return
		RTS

		.Process
		JMP KNOCKOUT


	HIT_13:
		; Knock back and damage
		LDA $3200,x
		CMP #$6E
		BEQ .Large

		.Small
		JMP KNOCKOUT

		.Large
		LDA #$6F : STA $3200,x		; Sprite num
		LDA #$01 : STA $3230,x		; Init sprite
		JSL $07F7D2			; Reset sprite tables
		LDA #$02 : STA $BE,x		; Action: fire breath up
		JMP KNOCKBACK


	HIT_14:
		; Do nothing
		RTS

	HIT_15:
		; Knock back and damage
		LDY $BE,x
		LDA $3280,x
		AND #$04
		BNE .Aggro
		CPY #$01
		BNE +
		LDA #$20 : STA $32F0,x
		JMP KNOCKOUT
	+	LDA #$04 : STA $34D0,x		; Half smush timer
		BRA .Shared

		.Return
		RTS

		.Aggro
		LDA $35B0,x : BNE .Return
		LDA #$40 : STA $35B0,x
		LDA $33E0,x
		BEQ .NoRoar
		LDA #$01 : STA $33E0,x

		.NoRoar
		CPY #$02
		BNE .Shared
		LDA #$20 : STA $32F0,x
		JMP KNOCKOUT

		.Shared
		INC $BE,x
		JSR CORE_ATTACK_Main
		LDA $3340,x			;\
		ORA #$0D			; | Set jump, getup, and knockback flags
		STA $3340,x			;/
		LDA $3330,x			;\
		AND.b #$04^$FF			; | Put sprite in midair
		STA $3330,x			;/
		LDA $3280,x			;\
		AND.b #$08^$FF			; | Clear movement disable
		STA $3280,x			;/
		BIT $3280,x			;\
		BVC .NoChase			; |
		BIT $3340,x			; |
		BVS .NoChase			; | Aggro off of being punched
		LDA !CurrentPlayer		; |
		CLC : ROL #4			; |
		ORA #$40			; |
		ORA $3340,x			; |
		STA $3340,x			;/

		.NoChase
		STZ $32A0,x			; > Disable hammer
		JMP KNOCKBACK



	HIT_16:
		; Do nothing
	HIT_17:
		; Do nothing
		RTS

	HIT_18:
		; Knock back without doing damage
		LDA !P2Direction
		EOR #$01
		STA $3320,x
		JMP KNOCKBACK


	HIT_19:
		; Do nothing
		RTS

	HIT_1A:
		; Collect
		JMP CORE_INT_1A+$03

	HIT_1B:
		LDA !BossData+0
		CMP #$81 : BNE .Return
		LDA !BossData+2
		AND #$7F
		CMP #$04 : BEQ .Return
		LDA $3420,x
		BNE .Return
		LDA !Difficulty
		AND #$03 : TAY
		LDA .InvincTime,y
		STA $3420,x
		LDA #$28 : STA !SPC4		; > OW! sound
		LDY !P2Direction
		LDA .XSpeed,y
		STA $AE,x
		LDA #$07 : STA !BossData+2
		LDA #$7F : STA !BossData+3
		DEC !BossData+1

		.Return
		RTS

		.InvincTime
		db $4F,$5F,$7F

		.XSpeed
		db $F0,$10

	HIT_1C:
		LDA $3280,x
		AND #$03
		CMP #$01 : BNE HIT_19
		LDA $BE,x
		AND #$0F
		ORA #$C0
		STA $BE,x
		JMP CORE_ATTACK_Main

	HIT_1D:
		LDA #$3F : STA $3360,x		; > Set hurt timer
		LDA #$28 : STA !SPC4		; > OW! sound
		STZ $32D0,x			; > Reset main timer
		DEC $3280,x			; > Deal damage
		LDA CORE_BITS,x
		CPX #$08
		BCS +
		TSB !P2IndexMem1
		RTS
		+
		TSB !P2IndexMem2

		.Return
		RTS


	KNOCKOUT:
		LDA #$02 : STA $3230,x
		LDA #$D8 : STA $9E,x
		LDA #$02 : STA !SPC1
		LDY !P2Direction
		LDA .XSpeed,y
		STA $AE,x
		RTS

	.XSpeed
	db $F0,$10


	KNOCKBACK:
		LDA #$E8 : STA $9E,x
		LDY !P2Direction
		LDA KNOCKOUT_XSpeed,y
		STA $AE,x
		LDA !P2Kick : BEQ .GFX			;\
		TXY					; | spin has increased i-frames
		LDA #$20 : STA ($0E),y			;/

		.GFX
		LDA #$02 : STA !SPC1
		RTS



;			   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			|
;	LO NYBBLE	   |YY0|YY1|YY2|YY3|YY4|YY5|YY6|YY7|YY8|YY9|YYA|YYB|YYC|YYD|YYE|YYF|	HI NYBBLE	|
;	--->		   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			V

HIT_TABLE:		db $01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$00,$05	;| 00X
			db $06,$02,$00,$07,$07,$08,$08,$00,$08,$00,$00,$07,$09,$07,$0A,$0A	;| 01X
			db $07,$0B,$0C,$0C,$0C,$0C,$07,$07,$07,$00,$07,$07,$00,$00,$07,$0D	;| 02X
			db $0E,$0E,$0E,$07,$07,$00,$00,$07,$07,$07,$07,$07,$07,$07,$0D,$06	;| 03X
			db $04,$0F,$0F,$0F,$07,$00,$10,$00,$07,$0F,$11,$0A,$00,$12,$12,$01	;| 04X
			db $01,$0A,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$0F,$0F,$0F,$0F,$00	;| 05X
			db $00,$0F,$0F,$0F,$00,$07,$07,$07,$07,$00,$00,$00,$00,$00,$13,$13	;| 06X
			db $00,$01,$01,$01,$1A,$1A,$1A,$1A,$1A,$00,$00,$11,$00,$00,$00,$00	;| 07X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 08X
			db $00,$10,$10,$10,$10,$10,$00,$10,$10,$07,$07,$0A,$0F,$00,$07,$14	;| 09X
			db $00,$07,$02,$00,$07,$07,$07,$00,$07,$07,$07,$15,$00,$00,$07,$16	;| 0AX
			db $07,$00,$07,$07,$07,$00,$07,$17,$17,$00,$0F,$0F,$00,$01,$0A,$18	;| 0BX
			db $0F,$00,$07,$07,$0F,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$07,$02	;| 0DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0FX

			db $00,$01,$15,$15,$15,$15,$1C,$07,$1B,$00,$00,$1D,$00,$00,$00,$00	;| 10X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 11X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 12X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 13X
			db $19,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 14X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 15X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 16X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 17X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 18X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 19X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1AX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1BX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1FX


namespace off





