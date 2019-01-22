

	namespace KingKing


; --Defines--

	!Phase		= !BossData+0
	!HP		= !BossData+1
	!Attack		= !BossData+2
	!AttackTimer	= !BossData+3
	!BossIndex	= !BossData+4
	!ScepterIndex	= !BossData+5
	!SomeScratch	= !BossData+6

	!Combo		= $C2,x			; 12------
	!TrueDirection	= $1504,x
	!DeathFlag	= $151C,x
	!DeathTimer	= $1528,x
	!StunTimer	= $1540,x
	!PrevDirection	= $160E,x
	!XSpeedIndex	= $1632,x
	!InvincTimer	= $163E,x
	!HeadTimer	= $187B,x		; !SpriteAnimTimer is for body
	!HeadAnim	= $1FD6,x		; !SpriteAnimIndex is for body

	!AttackMemory	= $0DF5,x		; < Technically an OW sprite table, but who cares


; --Scepter defines--

	!Stat		= $C2,x
	!ScepterStat	= $00C2,y
	!ScepterTimer	= $1540,y		; Should equal stun timer, but with Y rather than X


		PLX
		LDA $7FAB10,x
		AND #$04
		BNE SCEPTER
		JMP KINGKING

	SCEPTER:
		LDA !StunTimer
		BNE +
		STZ $AA,x
		STZ $B6,x
		LDA #$05
		STA !SpriteAnimIndex
		LDA #$02
		STA $14E0,x
		STZ !Stat
		+
		LDA $C2,x
		ASL A
		TAX
		JSR (.StatPtr,x)

		LDA !SpriteAnimIndex
		CMP #$05
		BCC .Interaction
		JMP .Graphics

		.Interaction
		LDA $E4,x			;\
		SEC : SBC #$10			; |
		STA $04				; | X displacement
		LDA $14E0,x			; |
		SBC #$00			; |
		STA $0A				;/
		LDA #$20			;\ Width
		STA $06				;/
		LDA $D8,x			;\
		SEC : SBC #$08			; |
		STA $05				; | Y displacement
		LDA $14D4,x			; |
		SBC #$00			; |
		STA $0B				;/
		LDA #$20			;\ Height
		STA $07				;/

		LDA !P2Status
		BNE $03 : JSR .P2
		JSL $83B664
		JSL $83B72B
		BCC .Graphics
		JSL $80F5B7

		.Graphics
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .Anim+0,y
		STA $04
		LDA.w .Anim+1,y
		STA $05
		LDA !SpriteAnimTimer
		INC A
		CMP.w .Anim+2,y
		BNE +
		LDA.w .Anim+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .Anim+0,y
		STA $04
		LDA.w .Anim+1,y
		STA $05
		LDA #$00
	+	STA !SpriteAnimTimer
		JMP LOAD_TILEMAP


		.StatPtr
		dw .MaintainSpeed
		dw .Boomerang
		dw .Dunk
		dw .Fall


		.MaintainSpeed
		LDX !SpriteIndex
		JSL $81801A
		JSL $818022
		RTS


		.Boomerang
		LDX !SpriteIndex
		LDA $1588,x
		AND #$03
		BEQ +
		LDA $B6,x
		EOR #$FF : INC A
		STA $B6,x
		LDY !BossIndex
		LDA $00E4,y : STA $00
		LDA $14E0,y : STA $01
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		LSR #2
		SEP #$20
		EOR #$FF : INC A
		SEC : SBC #$20
		STA $AA,x
		LDA #$05 : STA !SpriteAnimIndex
		LDA #$09 : STA !SPC4
		LDA !Stat
		ORA #$80
		STA !Stat
		+
		BIT !Stat
		BMI +
		STZ $AA,x
		+
		JSL $81802A
		BIT !Stat
		BPL +
		LDY !BossIndex
		LDA $00E4,y : STA $00
		LDA $14E0,y : STA $01
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0008
		SEP #$20
		BCS +
		STZ $AA,x
		STZ $B6,x
		STZ !Stat
		STZ !StunTimer
		LDA #$02
		STA $14E0,x
		+
		RTS


		.Dunk
		LDX !SpriteIndex
		LDA $AA,x : PHA
		JSL $81802A
		PLY
		LDA $1588,x
		AND #$04
		BEQ +
		TYA
		EOR #$FF
		INC A
		STA $AA,x
		LDA $E4,x
		LSR #3
		ASL A
		TAY
		PHB
		LDA #$7F
		PHA : PLB
		LDA #$FF : STA $A140,y
		STA $A142,y
		LDA #$01 : STA $A141,y
		LDA #$41 : STA $A143,y
		PLB
		LDA #$09 : STA !SPC4
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		+
		RTS


		.Fall
		LDX !SpriteIndex
		BIT !Stat
		BMI +
		LDY.w .Fall00
		INY
	-	LDA.w .Fall00,y
		STA $1892,y
		DEY
		BPL -
		LDA !Stat
		ORA #$80
		STA !Stat
		+
		INC $1892+$03
		INC $1892+$07
		DEC $1892+$0B
		LDA $AA,x
		BMI +
		CMP #$40
		BCS ++
		+
		INC $AA,x
		INC $AA,x
		++
		JSL $81801A
		JSL $818022
		RTS


		.P2
		LDA !P2Invinc : BNE +
		JSR P2Clipping
		JSL $83B72B
		BCC +
		JSR HurtP2
		+
		RTS


	.Anim
	.AnimSpin
		dw .Spin00 : db $03,$01		; 00
		dw .Spin01 : db $03,$02		; 01
		dw .Spin02 : db $03,$03		; 02
		dw .Spin03 : db $03,$04		; 03
		dw .Spin04 : db $03,$00		; 04
	.AnimIdle
		dw .Idle00 : db $FF,$05		; 05
	.AnimDunk
		dw .Dunk00 : db $10,$07		; 06
		dw .Dunk01 : db $FF,$07		; 07
	.AnimFall
		dw $1892 : db $FF,$08		; 08

	.Spin00
		dw $000C
		db $47,$08,$F8,$40
		db $47,$10,$F8,$41
		db $47,$08,$00,$50
	.Spin01
		dw $0010
		db $47,$F0,$F8,$43
		db $47,$F8,$F8,$44
		db $47,$F0,$00,$53
		db $47,$F8,$00,$54
	.Spin02
		dw $0010
		db $47,$F0,$08,$46
		db $47,$F8,$08,$47
		db $47,$F0,$10,$56
		db $47,$F8,$10,$57
	.Spin03
		dw $0010
		db $47,$00,$08,$49
		db $47,$08,$08,$4A
		db $47,$00,$10,$59
		db $47,$08,$10,$5A
	.Spin04
		dw $000C
		db $47,$08,$00,$3E
		db $47,$10,$00,$5E
		db $47,$10,$08,$6E

	.Idle00
		dw $0008
		db $47,$00,$00,$03
		db $47,$00,$08,$13

	.Dunk00
		dw $0008
		db $07,$00,$00,$28
		db $07,$08,$00,$29
	.Dunk01
		dw $0008
		db $47,$00,$00,$0D
		db $47,$00,$08,$1D

	.Fall00
		dw $000C
		db $47,$00,$00,$3C
		db $47,$00,$08,$4C
		db $47,$F8,$E0,$05


	KINGKING:
		LDA $7FAB10,x
		BMI .Main
		ORA #$80
		STA $7FAB10,x
		LDA #$04			;\ Stand on the ground
		STA $1588,x			;/
		LDA !Difficulty			;\
		AND #$03			; |
		TAY				; | Set base HP
		LDA.w .BaseHP,y			; |
		STA !HP				;/
		LDA #$01			;\ Initialize boss
		STA !Phase			;/
		STZ !BossData+2			;\
		STZ !BossData+3			; |
		STZ !BossData+4			; | Wipe boss data
		STZ !BossData+5			; |
		STZ !BossData+6			;/
		LDA #$80			;\ VRAM location of graphics (0x7800)
		STA !ClaimedGFX			;/
		LDX #$0B			;\
	-	LDA $7FAB9E,x			; |
		CMP #$10			; |
		BNE +				; |
		LDA $7FAB10,x			; |
		AND #$04			; | Find scepter
		BEQ +				; |
		STX !ScepterIndex		; |
		BRA ++				; |
	+	DEX				; |
		BPL -				; |
	++	LDX !SpriteIndex		;/
		STX !BossIndex			; > Save boss index
		LDA #$01 : STA !AnimToggle

		.Main
		LDA $14C8,x
		SEC : SBC #$08
		ORA $9D
		BNE LOCK_SPRITE
		LDA !DeathTimer			;\
		BEQ +				; | Handle death timer
		DEC !DeathTimer			; |
		+				;/
		LDA !Phase
		ASL A
		TAX
		JMP (.PhasePtr,x)

		.PhasePtr
		dw LOCK_SPRITE			; 0
		dw Intro			; 1
		dw Battle			; 2
		dw Transform			; 3
		dw Battle			; 4
		dw Death			; 5

	.BaseHP
	db $08,$0C,$10

	.DelayTable
	db $3C,$28,$1E,$0F

	.XSpeed
	db $F0,$10				; Idle		;\
	db $E0,$20				; Jump		; | EASY
	db $D0,$30				; Charge	; |
	db $E8,$18				; Idle, phase 2	;/
	db $F0,$10				; Idle		;\
	db $E0,$20				; Jump		; | NORMAL
	db $C8,$38				; Charge	; |
	db $E8,$18				; Idle, phase 2	;/
	db $F0,$10				; Idle		;\
	db $E0,$20				; Jump		; | INSANE
	db $C0,$40				; Charge	; |
	db $E8,$18				; Idle, phase 2	;/




	LOCK_SPRITE:
		JMP Graphics


	Intro:
		LDX !SpriteIndex
		LDA !StunTimer
		BNE .Return
		BIT !Phase
		BMI .Main
		LDA #$FF
		STA !StunTimer
		LDA #$80
		TSB !Phase
		JMP Graphics

		.Main
;	LDA #$01
;	STA !MsgTrigger
		INC !Phase
		LDA #$06
		STA !SpriteAnimIndex
		LDA #$02			;\
		STA $3E				; |
		PHB				; |
		LDA #$7F			; |
		PHA : PLB			; |
		REP #$20			; |
		LDX #$3E			; | Enable mode 2 and set up offset-per-tile mirror
		LDA #$2000			; |
		ORA $1C				; |
	-	STA $A100,x			; |
		STZ $A140,x			; |
		DEX #2				; |
		BPL -				;/
		JSL !GetVRAM			;\
		LDA.w #$0040			; |
		STA.w !VRAMtable+0,x		; |
		LDA.w #.BaseHorz		; |
		STA.w !VRAMtable+2,x		; |
		LDA.w #.BaseHorz>>8		; | Clear horizontal offset data
		STA.w !VRAMtable+3,x		; |
		LDA.w #$5300			; |
		STA.w !VRAMtable+5,x		; |
		SEP #$20			; |
		PLB				;/
		JSR UPDATE_MODE2		; > Initialize vertical offset data

		.Return
		JMP Graphics

		.BaseHorz
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000
		dw $2000,$2000,$2000,$2000


	Transform:
		JSR UPDATE_MODE2
		LDX !SpriteIndex
		STZ !InvincTimer		; Make visible
		LDA !StunTimer
		BNE .Return
		LDA !Phase
		BPL .Main
		LDA #$3C
		STA !StunTimer
		LDA #$80
		TRB !Phase
		JMP Graphics

		.Main
		INC !Phase			; Increment phase

		.Return
		JMP Graphics

	Death:
		JSR UPDATE_MODE2
		BIT !Phase
		BMI .Main

		.Init
		LDX !ScepterIndex
		LDA #$08 : STA !SpriteAnimIndex
		LDA #$03 : STA !Stat
		LDA #$C0 : STA $AA,x
		LDA #$00 : STA $B6,x
		LDA #$80 : STA !StunTimer
		TXY					; > Y = scepter index
		LDX !SpriteIndex			; > X = sprite index
		LDA $E4,x				;\
		STA $00E4,y				; |
		LDA $14E0,x				; |
		STA $14E0,y				; |
		LDA $D8,x				; |
		SEC : SBC #$20				; | Set up scepter for death animation
		STA $00D8,y				; |
		LDA $14D4,x				; |
		SBC #$00				; |
		STA $14D4,y				; |
		LDA $157C,x				; |
		STA $157C,y				;/
		LDA #$01 : STA !Phase			;\ Make sure graphics are loaded
		JSR Graphics				;/

		LDX #$1F
	-	LDA.w .Colors,x
		STA $7FA180,x
		DEX
		BPL -
		LDA #$85 : STA !Phase
		STA !SPC3

		.Main
		LDA $14
		AND #$03
		BNE .NoUpdate
		PHB
		LDA #$7F
		PHA : PLB
		LDX #$1E
		REP #$20
	-	LDA $A180,x
		STA $00
		AND #$7C00
		BEQ +
		SEC : SBC #$0400
	+	STA $02
		LDA $00
		AND #$03E0
		BEQ +
		SEC : SBC #$0020
	+	STA $04
		LDA $00
		AND #$001F
		BEQ +
		DEC A
	+	ORA $02
		ORA $04
		STA $A180,x
		DEX #2
		BPL -
		LDX #$00
	-	LDA !CGRAMtable,x
		BEQ +
		TXA
		CLC : ADC #$0006
		TAX
		BRA -
	+	LDA #$0020
		STA !CGRAMtable+0,x
		LDA #$A180
		STA !CGRAMtable+2,x
		LDA #$7FA1
		STA !CGRAMtable+3,x
		SEP #$20
		LDA #$C0
		STA !CGRAMtable+5,x
		PLB

		.NoUpdate
		LDX !SpriteIndex
		LDA !DeathTimer
		BPL $03 : JMP +
		LSR A
		AND #$07
		ASL #2
		STA $00
		LDA !DeathTimer
		LSR A
		AND #$38
		LSR #2
		TAY
		REP #$20
		JSL !GetVRAM					; > Get free index
		LDA #$0002					; > 2 bytes/upload
		STA !VRAMbase+!VRAMtable+$00,x			;\
		STA !VRAMbase+!VRAMtable+$07,x			; |
		STA !VRAMbase+!VRAMtable+$0E,x			; |
		STA !VRAMbase+!VRAMtable+$15,x			; |
		STA !VRAMbase+!VRAMtable+$1C,x			; |
		STA !VRAMbase+!VRAMtable+$23,x			; | Set upload regs
		STA !VRAMbase+!VRAMtable+$2A,x			; |
		STA !VRAMbase+!VRAMtable+$31,x			; |
		STA !VRAMbase+!VRAMtable+$38,x			; |
		STA !VRAMbase+!VRAMtable+$3F,x			; |
		STA !VRAMbase+!VRAMtable+$46,x			; |
		STA !VRAMbase+!VRAMtable+$4D,x			;/
		LDA.w #.Zero					; > Data location
		STA !VRAMbase+!VRAMtable+$02,x			;\
		STA !VRAMbase+!VRAMtable+$09,x			; |
		STA !VRAMbase+!VRAMtable+$10,x			; |
		STA !VRAMbase+!VRAMtable+$17,x			; |
		STA !VRAMbase+!VRAMtable+$1E,x			; |
		STA !VRAMbase+!VRAMtable+$25,x			; | Set source regs
		STA !VRAMbase+!VRAMtable+$2C,x			; |
		STA !VRAMbase+!VRAMtable+$33,x			; |
		STA !VRAMbase+!VRAMtable+$3A,x			; |
		STA !VRAMbase+!VRAMtable+$41,x			; |
		STA !VRAMbase+!VRAMtable+$48,x			; |
		STA !VRAMbase+!VRAMtable+$4F,x			;/
		LDA.w #.Zero>>8					; > Data bank
		STA !VRAMbase+!VRAMtable+$03,x			;\
		STA !VRAMbase+!VRAMtable+$0A,x			; |
		STA !VRAMbase+!VRAMtable+$11,x			; |
		STA !VRAMbase+!VRAMtable+$18,x			; |
		STA !VRAMbase+!VRAMtable+$1F,x			; |
		STA !VRAMbase+!VRAMtable+$26,x			; | Set bank regs
		STA !VRAMbase+!VRAMtable+$2D,x			; |
		STA !VRAMbase+!VRAMtable+$34,x			; |
		STA !VRAMbase+!VRAMtable+$3B,x			; |
		STA !VRAMbase+!VRAMtable+$42,x			; |
		STA !VRAMbase+!VRAMtable+$49,x			; |
		STA !VRAMbase+!VRAMtable+$50,x			;/
		LDA.w .VRAMrow,y				;\
		LDY $00						; |
		STA $02						; |
		CLC : ADC.w .VRAMtile+0,y			; |
		STA !VRAMbase+!VRAMtable+$05,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$13,x			; | Dest VRAM for bp1 and bp2
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$21,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$2F,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$3D,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$4B,x			;/
		LDA $02						;\
		CLC : ADC.w .VRAMtile+2,y			; |
		STA !VRAMbase+!VRAMtable+$0C,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$1A,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$28,x			; | Dest VRAM for bp3 and bp4
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$36,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$44,x			; |
		CLC : ADC #$0010				; |
		STA !VRAMbase+!VRAMtable+$52,x			;/
		SEP #$20					; > A 8 bit
		LDX !SpriteIndex				; > X = sprite index
		+

		LDA !DeathTimer
		BNE +
		STZ $14C8,x
		LDA #$35 : STA !SPC3
		LDA #$FF : STA !LevelEnd
		LDA #$01 : STA $3E
		REP #$20
		LDA #$38FC
		LDX #$7E
	-	STA $7FA100,x
		DEX #2
		BPL -
		SEP #$20
		LDX !SpriteIndex
		RTS

		+
		LDA #$08 : STA !HeadAnim
		LDA #$0B : STA !SpriteAnimIndex
		LDA #$08 : STA !SomeScratch
		JMP Graphics_Draw


	.Colors
		dw $0000,$7FFF
		dw $0000,$0011
		dw $0017,$001F
		dw $00B7,$023F
		dw $017C,$1F1F
		dw $19F6,$1E9B
		dw $139F,$0241
		dw $0780,$27E7

	.VRAMrow
		dw $7F00
		dw $7E00
		dw $7D00
		dw $7C00
		dw $7B00
		dw $7A00
		dw $7900
		dw $7800

	.VRAMtile
		dw $0007,$000F
		dw $0006,$000E
		dw $0005,$000D
		dw $0004,$000C
		dw $0003,$000B
		dw $0002,$000A
		dw $0001,$0009
		dw $0000,$0008


	.Zero
		dw $0000


; For each tile:
;
;	Row 0:	byte $00,$01,$10,$11
;	Row 1:	byte $02,$03,$12,$13
;	Row 2:	byte $04,$05,$14,$15
;	Row 3:	byte $06,$07,$16,$17
;	Row 4:	byte $08,$09,$18,$19
;	Row 5:	byte $0A,$0B,$1A,$1B
;	Row 6:	byte $0C,$0D,$1C,$1D
;	Row 7:	byte $0E,$0F,$1E,$1F




;	My VRAM layout seems to be this:
;	0x0000	24K B	4bpp GFX
;	0x6000	4K B	BG1 tilemap (64x32)
;	0x7000	4K B	BG2 tilemap (64x32)
;	0x8000	8K B	2bpp GFX
;	0xA000	---	---
;	0xA600	64 B	Horizontal offset data.
;	0xA640	64 B	Vertical offset data.
;	0xA680	---	---
;	0xC000	16K B	4bpp GFX

;	Offset format:
;		d21---ss ssssssss
;		d is direction. 0 = horizontal, 1 = vertical. Only used in mode 4.
;		2 applies offset to BG2.
;		1 applies offset to BG1.
;		s is value to add to offset.
;
;	Wave motion format:
;		vh-----T tttttttt
;		v is vertical direction. 0 = up, 1 = down.
;		h is horizontal direction. 0 = left, 1 = up.
;		T is hi bit of timer. Counts down.
;		t is lo byte of timer. Counts down.
;
;	Mirror format:
;	0x0000	64 B	Offset data, 2 bytes/column.
;	0x0040	64 B	Wave motion data, 2 bytes/column.


	Battle:
		JSR UPDATE_MODE2
		LDX !SpriteIndex
		LDA !HP				;\
		ORA !DeathFlag			; |
		BNE +				; |
		LDA #$01			; | Check if boss is dead (set !DeathFlag and !DeathTimer)
		STA !DeathFlag			; |
		LDA #$FF			; |
		STA !DeathTimer			;/
	+	LDA !DeathFlag			;\
		BEQ .Alive			; |
		LDA #$05			; | Set phase to dying
		STA !Phase			;/
		JMP Graphics

		.Alive
		LDA $1588,x
		AND #$04
		BEQ GetAttack			; Don't turn around in midair
		LDA !TrueDirection		;\ Use direction as X speed index
		STA !XSpeedIndex		;/

		.Process
		LDA $157C,x			;\ Set direction of last frame
		STA !PrevDirection		;/
		LDA !StunTimer			;\ Don't decrement attack timer while boss is stunned
		BNE GetAttack			;/
		LDA !AttackTimer		;\
		BNE +				; |
		STZ !Attack			; | Decrement attack timer
		BRA GetAttack			; |
	+	DEC !AttackTimer		;/


	GetAttack:
		LDA !InvincTimer
		CMP #$20
		BCC $03 : JMP Interaction
		LDA !Attack
		CMP #$05
		BNE .CheckCombo
		JMP Attack

		.CheckCombo
		LDA $1588,x
		AND #$04
		BEQ .NoCombo
		LDY !ScepterIndex
		LDA !ScepterTimer
		BNE .NoCombo

		.Combo
		BIT !Combo
		BMI .InitCombo1
		BVC .NoCombo

		.InitCombo2
		PEA .InitCombo1+2
		PHY
		LDY #$00
		JMP FacePlayer_P2

		.InitCombo1
		JSR FacePlayer
		LDA #$05
		STA !Attack
		LDA #$30
		STA !StunTimer
		STA !AttackTimer
		LDY !ScepterIndex
		LDA $E4,x
		STA $00E4,y
		LDA $14E0,x
		STA $14E0,y
		LDA $D8,x
		SEC : SBC #$20
		STA $00D8,y
		LDA $14D4,x
		SBC #$00
		STA $14D4,y
		LDA $157C,x
		EOR #$01
		STA $157C,y
		JMP Attack

		.NoCombo
		LDA $1588,x
		AND #$04
		BNE $03 : JMP Attack
		LDA !AttackTimer		; Load attack timer
		BEQ $03 : JMP Attack
		LDA !RNG			; Load RNG
		AND #$03			;\ Store attack number
		STA !Attack			;/
		LDA !AttackMemory		;\
		AND #$0F			; |
		CMP !Attack			; |
		BNE .Fresh			; |
		LDA !AttackMemory		; | 
		LSR #4				; | Don't allow the same attack more than twice in a row
		CMP !Attack			; |
		BNE .Fresh			; |
		LDA !Attack			; |
		INC A				; |
		AND #$03			; |
		STA !Attack			;/

		.Fresh
		LDA !AttackMemory		;\
		ASL #4				; | Move previous attack to high nybble
		ORA !Attack			; |
		STA !AttackMemory		;/
		LDY !Attack			;\
		LDA.w Attack_Timer,y		; | Store attack timer
		STA !AttackTimer		;/
		CPY #$02			;\ Jump needs special code
		BEQ .Special			;/
		CPY #$03			;\ Charge needs special code
		BNE Attack			;/
		LDA $E4,x
		BPL .ChargeRight

		.ChargeLeft
		STZ !TrueDirection
		BRA .Special

		.ChargeRight
		LDA #$01
		STA !TrueDirection

		.Special
		LDA !Difficulty			;\
		AND #$03			; |
		TAY				; |
		LDA !Phase			; | Determine startup time for jump
		AND #$7F : CMP #$04		; |
		BNE $01 : INY			; |
		LDA.w KINGKING_DelayTable,y	; |
		STA !StunTimer			;/


	Attack:
		PEA UpdateSpeed-1
		LDA !Attack
		ASL A
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw Idle				; Idle, long
		dw Idle				; Idle, short
		dw Jump				; Jump
		dw Charge			; Charge
		dw ScepterUp			; Combo throw
		dw ScepterForward		; Boomerang throw
		dw FireBreath			; Fire breath

		.Timer
		db $80				; Idle, long
		db $40				; Idle, short
		db $04				; Jump
		db $80				; Charge
		db $FF				; Combo throw
		db $FF				; Boomerang throw
		db $FF				; Fire breath

	Idle:
		LDX !SpriteIndex
		LDA $1588,x
		AND #$04
		BNE .Process
		RTS

		.Process
		LDA !Phase
		AND #$7F : CMP #$04
		BNE .Phase2
		LDA !AttackTimer
		AND #$0F
		BRA .Shared

		.Phase2
		LDA !AttackTimer
		AND #$1F

		.Shared
		BEQ .Turn
		LDA !TrueDirection
		BEQ .Left

		.Right
		LDA $E4,x
		CMP #$E8
		BCC .Move
		BRA .Turn

		.Left
		LDA $E4,x
		CMP #$10
		BCS .Move

		.Turn
		LDA !TrueDirection		;\
		EOR #$01			; |
		STA !TrueDirection		; |
		JSR FacePlayer			; |
		LDA !PrevDirection		; |
		CMP $157C,x			; | Face player and such
		LDA !Difficulty			; |
		AND #$03 : TAY			; |
		LDA !Phase			; |
		AND #$7F : CMP #$04		; |
		BNE $01 : INY			; |
		LDA.w KINGKING_DelayTable,y	; |
		STA !StunTimer			;/
		LDA !RNG			;\
		AND #$80			; | Randomly decide between stomp and fireball
		STA !Attack			;/
		LDA !Phase			;\
		AND #$7F : CMP #$04		; |
		BNE +				; |
		BIT !Attack			; |
		BPL +				; | Stomp turns into boomerang throw during phase 2
		LDY !ScepterIndex		; |
		LDA !ScepterTimer		; |
		BNE +				; |
		BRA .Scepter			;/

		.Return
		RTS				; > Return

	+	DEC !AttackTimer		; > Prevent boss from getting stuck

		.Move
		LDA !StunTimer
		BEQ .Return
		LDA !Phase
		AND #$7F : CMP #$04
		BNE $03 : JMP Fireball
		BIT !Attack
		BMI Stomp
		JMP Fireball

		.Scepter
		LDA #$05
		STA !Attack
		LDA #$30
		STA !StunTimer
		STA !AttackTimer
		LDA $E4,x
		STA $00E4,y
		LDA $14E0,x
		STA $14E0,y
		LDA $D8,x
		SEC : SBC #$20
		STA $00D8,y
		LDA $14D4,x
		SBC #$00
		STA $14D4,y
		BIT $E4,x
		BPL .ScepterRight

		.ScepterLeft
		LDA #$00
		STA $157C,x
		STA $157C,y
		JMP ScepterForward_P1+3

		.ScepterRight
		LDA #$01
		STA $157C,x
		STA $157C,y
		JMP ScepterForward_P1+3

	Stomp:
		LDA #$1F			;\ Shake BG1
	;	STA !ShakeTimer			;/
		LDA !StunTimer
		DEC A
		BNE .Return
		LDA #$09
		STA !SPC4
		JSL $82A9DE
		LDA !Difficulty
		AND #$03 : CMP #$02
		TYA
		BPL .Process

		.Return
		RTS

		.Process
		LDA $157C,x
		PHP
		LDA $E4,x
		LSR #3
		ASL A
		TAX
		CPX #$04
		BCS $02 : LDX #$04
		CPX #$38
		BCC $02 : LDX #$38
		LDA #$FF : STA $7FA140,x
		LDA #$01
		PLP
		BEQ $02 : LDA #$41
		STA $7FA141,x
		LDX !SpriteIndex
		RTS


	Fireball:
		LDA !Attack
		AND.b #$80^$FF
		STA !Attack
		LDA #$06
		STA !HeadAnim
		STZ !HeadTimer
		LDA !Difficulty
		AND #$03 : TAY
		CPY #$02
		BEQ .Insane
		LDA !Phase
		AND #$7F : CMP #$04
		BNE $01 : INY
		LDA.w KINGKING_DelayTable,y

		.EasyNormal
		XBA
		LDA !Phase
		AND #$7F : CMP #$04
		BNE +
		XBA
		SEC : SBC !StunTimer
		BRA .DoubleSpit
		+
		XBA
		CMP !StunTimer
		BNE .Return

		.Target
		LDA !RNG
		AND #$04
		BEQ $03 : JMP Fireball1
		JMP Fireball2

		.Insane
		LDA !Phase
		AND #$7F : CMP #$04
		BNE $01 : INY
		LDA.w KINGKING_DelayTable,y
		SEC : SBC !StunTimer
		CPY #$03
		BCC .DoubleSpit
		CMP #$00
		BNE $03 : JMP Fireball1
		CMP #$04
		BNE $03 : JMP Fireball2
		CMP #$08
		BNE $03 : JMP Fireball1
		CMP #$0C
		BNE $03 : JMP Fireball2
		RTS

		.DoubleSpit
		CMP #$00
		BNE $03 : JMP Fireball1
		CMP #$04
		BNE $03 : JMP Fireball2

		.Return
		RTS


	Fireball1:
		JSL $82A9DE		;\ Get sprite slot
		BMI .Return		;/
		LDA !P1Dead		;\
		BEQ .Process		; | Get target player
		JMP Fireball2_Process	;/

		.Process
		LDA $E4,x		;\
		STA $00E4,y		; | Same Xpos
		LDA $14E0,x		; |
		STA $14E0,y		;/
		LDA $D8,x		;\
		SEC : SBC #$18		; |
		STA $00D8,y		; | Spawn 0x2 tiles above
		LDA $14D4,x		; |
		SBC #$00		; |
		STA $14D4,y		;/
		LDA #$05		;\  > Custom sprite number
		TYX			; | > X = new sprite index
		STA $7FAB9E,x		; |
		LDA #$36		; | > Acts like
		STA $9E,x		; |
		LDA #$08		; | > MAIN routine
		STA $14C8,x		; |
		JSL $87F7D2		; | > Reset sprite tables
		JSL $8187A7		; | > Reset custom sprite tables
		LDA #$08		; |
		STA $7FAB10,x		;/
		LDA #$FF		;\ Life timer
		STA $1540,x		;/
		LDA #$00		;\ Graphic tile
		STA $1602,x		;/
		LDA $14E0,x		;\
		XBA			; | Load 16 bit Xpos
		LDA $E4,x		;/
		REP #$20		; A 16 bit
		SEC			;\ Subtract 16 bit Mario Xpos
		SBC $94			;/
		LSR A			;\ Divide by 4
		LSR A			;/
		SEP #$20		; A 8 bit
		EOR #$FF		;\
		INC A			; | Invert speed
		STA $B6,x		;/
		LDA #$B0		;\ Set some Y speed
		STA $AA,x		;/
		LDX !SpriteIndex

		.Return
		RTS

	Fireball2:
		JSL $82A9DE		;\ Get sprite slot
		BMI .Return		;/
		LDA !P2Status		;\
		CMP #$02		; | Get target player
		BNE .Process		; |
		JMP Fireball1_Process	;/

		.Process
		LDA $E4,x		;\
		STA $00E4,y		; | Same Xpos
		LDA $14E0,x		; |
		STA $14E0,y		;/
		LDA $D8,x		;\
		SEC : SBC #$18		; |
		STA $00D8,y		; | Spawn 0x2 tiles above
		LDA $14D4,x		; |
		SBC #$00		; |
		STA $14D4,y		;/
		LDA #$05		;\  > Custom sprite number
		TYX			; | > X = new sprite index
		STA $7FAB9E,x		; |
		LDA #$36		; | > Acts like
		STA $9E,x		; |
		LDA #$08		; | > MAIN routine
		STA $14C8,x		; |
		JSL $87F7D2		; | > Reset sprite tables
		JSL $8187A7		; | > Reset custom sprite tables
		LDA #$08		; |
		STA $7FAB10,x		;/
		LDA #$FF		;\ Life timer
		STA $1540,x		;/
		LDA #$00		;\ Graphic tile
		STA $1602,x		;/
		TYX			; > Y -> X
		LDA $14E0,x		;\
		XBA			; | Load 16 bit Xpos
		LDA $E4,x		;/
		REP #$20		; A 16 bit
		SEC : SBC !P2XPosLo	; Subtract P2 Xpos
		LSR #2			; Divide by 4
		SEP #$20		; A 8 bit
		EOR #$FF		;\
		INC A			; | Invert speed
		STA $B6,x		;/
		LDA #$B0		;\ Set some Yspeed
		STA $AA,x		;/
		LDX !SpriteIndex

		.Return
		RTS


	Jump:
		LDX !SpriteIndex
		LDA !Difficulty
		AND #$03
		BEQ .Process
		LDA !Phase
		AND #$7F : CMP #$04
		BNE .Process
		LDA $AA,x
		CMP #$BE
		BNE .Process
		LDX !ScepterIndex
		LDA !StunTimer
		BNE .NoDunk
		LDA #$02 : STA !Stat
		LDA #$38 : STA !StunTimer
		LDA #$08 : STA $AA,x
		LDA #$06 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		TXY
		LDX !SpriteIndex
		LDA $E4,x
		STA $00E4,y
		LDA $14E0,x
		STA $14E0,y
		LDA $D8,x
		SEC : SBC #$20
		STA $00D8,y
		LDA $14D4,x
		SBC #$00
		STA $14D4,y
		LDA $B6,x
		STA $00B6,y
		LDA $157C,x
		STA $157C,y

		.NoDunk
		LDX !SpriteIndex

		.Process
		LDA !AttackTimer
		CMP #$03
		BEQ +
		LDA !StunTimer
		DEC A
		BNE +
		JSR FacePlayer
		LDA !PrevDirection
		CMP $157C,x
	+	LDA !StunTimer
		BNE .Return
		LDA $1588,x
		AND #$04
		BNE .Ground
		LDA $1588,x
		AND #$03
		BEQ .Return
		LDA !TrueDirection
		EOR #$01
		STA !TrueDirection
		STA $157C,x
		ORA #$02
		STA !XSpeedIndex
		LDA #$09 : STA !SPC4

		.Return
		RTS

		.Ground
		LDA !AttackTimer
		CMP #$03
		BNE .NoInit
		LDA #$A0
		STA $AA,x

		.NoInit
		LDA !AttackTimer
		CMP #$02
		BNE .DetermineDirection
		LDA #$09
		STA !SPC4
		LDA #$1F
	;	STA !ShakeTimer
		LDA !Difficulty
		AND #$03 : TAY
		LDA.w KINGKING_DelayTable,y
		STA !StunTimer
		LDA $E4,x
		LSR #3
		ASL A
		TAY
		PHB
		LDA #$7F
		PHA : PLB
		LDA #$FF : STA $A140,y
		STA $A142,y
		LDA #$01 : STA $A141,y
		LDA #$41 : STA $A143,y
		PLB

		.DetermineDirection
		LDA !StunTimer
		BNE .Return
		BIT $E4,x
		BPL .Right

		.Left
		LDA #$02
		STA !XSpeedIndex
		STZ $157C,x
		STZ !TrueDirection
		RTS

		.Right
		LDA #$03
		STA !XSpeedIndex
		LDA #$01
		STA $157C,x
		STA !TrueDirection
		RTS


	Charge:
		LDX !SpriteIndex
		LDA $1588,x
		AND #$03
		BEQ .Process
		LDA !TrueDirection
		EOR #$01
		STA !TrueDirection
		STA $157C,x
		STA !XSpeedIndex
		LDA #$D0
		STA $AA,x
		LDA #$09
		STA !SPC4
		LDA #$1F
	;	STA !ShakeTimer
		STZ !AttackTimer

		.Process
		LDA $1588,x
		AND #$04
		BEQ .NoHop
		LDA !StunTimer
		BNE .PrepHop
		BIT $AA,x
		BMI .NoHop
		LDA #$03
		STA !StunTimer
		BRA .NoHop

		.PrepHop
		DEC A
		BEQ .Hop
		LDA #$0B
		STA !HeadAnim
		LDA #$0E
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .NoHop

		.Hop
		LDA #$F0
		STA $AA,x
		LDY #$0F
		LDA !Attack
		EOR #$80
		STA !Attack
		BPL $01 : INY
		TYA
		STA !SpriteAnimIndex
		SEC : SBC #$04
		STA !HeadAnim

		.NoHop
		LDA !AttackTimer
		BEQ .Return
		LDA !TrueDirection
		STA $157C,x
		ORA #$04
		STA !XSpeedIndex

		.Return
		RTS


	ScepterUp:
		LDX !ScepterIndex
		LDA !StunTimer
		BNE .Return
		LDA $E4,x
		STA $00
		LDA $14E0,x
		STA $01
		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		SEC : SBC $96
		CLC : ADC #$0010
		STA $02
		LDA $00
		SEC : SBC $94
		STA $00
		SEP #$20
		LDA #$40
		JSR Aim
		LDA $00 : STA $B6,x
		LDA $02 : STA $AA,x
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$80
		STA !StunTimer

		.Return
		LDX !SpriteIndex
		RTS


	ScepterForward:
		LDX !SpriteIndex
		BIT !Combo
		BMI .P1
		PEA .P1+2
		PHY
		LDY #$00
		JMP FacePlayer_P2

		.P1
		JSR FacePlayer
		LDY !ScepterIndex
		LDA !ScepterTimer
		BNE .Return
		LDA $157C,x
		AND #$01
		EOR #$01
		+
		STA $157C,y
		EOR #$01
		AND #$01 : TAY
		LDA.w .XSpeed,y
		LDX !ScepterIndex
		STA $B6,x
		LDA #$00 : STA $AA,x
		LDA #$FF : STA !StunTimer
		LDA #$01 : STA !Stat
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDX !SpriteIndex

		.Return
		RTS

		.XSpeed
		db $D0,$30


	FireBreath:


	UpdateSpeed:
	;	LDA !Attack
	;	AND #$7F : CMP #$03
	;	BEQ +
		LDA !StunTimer
		BNE Interaction
		LDA !Attack
		AND #$7F : CMP #$05
		BNE +
		STZ $B6,x
		BRA ++
	+	LDA !Difficulty
		AND #$03 : ASL #3
		CLC : ADC !XSpeedIndex
		TAY
		LDA.w KINGKING_XSpeed,y
		STA $B6,x
	++	JSL $81802A


	Interaction:
		LDX !SpriteIndex
		PEA Graphics-1			; > Set return address

		LDA !P1Dead
		ORA $71
		BNE .P1NoCombo+1
		LDA $77
		AND #$04
		BEQ +
		BIT !Combo
		BMI .P1NoCombo+1
		PHB
		LDA #$7F
		PHA : PLB
		LDA $94
		LSR #3
		ASL A
		TAY
		LDA $A13F,y
		ORA $A141,y
		ORA $A143,y
		ORA $A145,y
		BPL .P1NoCombo
		PLB
		STZ $7B
		LDA #$A0 : STA $7D
		LDA #$03 : STA !SPC1
		LDA !Combo
		ORA #$80
		STA !Combo
		BRA +

		.P1NoCombo
		PLB
		LDA !Combo
		AND.b #$80^$FF
		STA !Combo
		+

		LDA !P2Status
		BNE .P2NoCombo+1
		LDA !P2Blocked
		AND #$04
		BEQ +
		BIT !Combo
		BVS .P2NoCombo+1
		LDA !P2XPosLo
		LSR #3
		ASL A
		TAY
		PHB
		LDA #$7F
		PHA : PLB
		LDA $A13F,y
		ORA $A141,y
		ORA $A143,y
		ORA $A145,y
		BPL .P2NoCombo
		PLB
		LDA #$00 : STA !P2XSpeed
		LDA #$A0 : STA !P2YSpeed
		LDA #$03 : STA !SPC1
		STZ !P2Punch1
		STZ !P2Punch2
		STZ !P2Senku
		LDA !Combo
		ORA #$40
		STA !Combo
		BRA +

		.P2NoCombo
		PLB
		LDA !Combo
		AND.b #$40^$FF
		STA !Combo
		+

		.GetClipping
		LDA $E4,x			;\
		STA $04				; | Clipping X displacement
		LDA $14E0,x			; |
		STA $0A				;/
		LDA #$1C			;\
		STA $06				; |
		LDA !Attack			; |
		AND #$7F : CMP #$03		; | Clipping width
		BNE +				; |
		LDA #$2C			; |
		STA $06				; |
		LDA $04				; |
		SEC : SBC #$10			; |
		STA $04				; |
		LDA $0A				; |
		SBC #$00			; |
		STA $0A				; |
		+				;/
		LDA $D8,x			;\
		SEC : SBC #$30			; |
		STA $05				; | Clipping Y displacement
		LDA $14D4,x			; |
		SBC #$00			; |
		STA $0B				;/
		LDA #$38			;\
		STA $07				; |
		LDA !Attack			; | Clipping height
		AND #$7F : CMP #$03		; |
		BNE +				; |
		LDA #$28			; |
		STA $07				; |
		LDA $05				; |
		CLC : ADC #$10			; |
		STA $05				; |
		LDA $0B				; |
		ADC #$00			; |
		STA $0B				; |
		+				;/
		LDA $154C,x			;\
		ORA $71				; | Run P1 check
		ORA !P1Dead			; |
		BNE $03 : JSR .P1		;/
		LDA !P2Status			;\
		BNE .Return			; | Run P2 check
		LDA $1564,x			; |
		BEQ .P2				;/

		.Return
		RTS				; > Return to graphics routine

		.P2
		JSR P2Clipping
		LDX !SpriteIndex		; > X = boss index
		JSL $83B72B			;\ Check for contact
		BCC .Return			;/
		LDA #$30			;\
		STA $00				; |
		STZ $01				; | Variable hitbox height
		LDA !Attack			; |
		AND #$7F : CMP #$03		; |
		BNE $04 : LDA #$20 : STA $00	;/
		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		SEC : SBC !P2YPosLo
		CMP $00
		SEP #$20
		BMI .P2Side

		.P2Top
		LDA #$08 : STA $1564,x
		LDA !InvincTimer
		BEQ +
		LDA #$02 : STA !SPC1
		BRA .P2Bounce
	+	DEC !HP
		LDA #$30
		STA !InvincTimer
		LDA #$28 : STA !SPC4
		LDA !Difficulty
		AND #$03 : TAY
		LDA.w KINGKING_BaseHP,y
		LSR A
		CMP !HP
		BNE .P2Bounce
		INC !Phase

		.P2Bounce
		JSR P2ContactGFX
		JSR P2Bounce
		RTS

		.P2Side
		LDA !P2Invinc
		BNE +
		JSR HurtP2
	+
	-	RTS


		.P1
		JSL $83B664			; > Get P1 clipping
		JSL $83B72B			;\ Check for contact
		BCC -				;/
		LDA #$30			;\
		STA $00				; |
		STZ $01				; | Variable hitbox height
		LDA !Attack			; |
		AND #$7F : CMP #$03		; |
		BNE $04 : LDA #$20 : STA $00	;/
		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		SEC : SBC $96
		CMP $00
		SEP #$20
		BMI .P1Side

		.P1Top
		LDA !InvincTimer
		BEQ +
		LDA #$02			;\ Spin jump on spiky enemy sound
		STA !SPC1			;/
		BRA .P1Bounce
	+	DEC !HP
		LDA #$30
		STA !InvincTimer
		LDA #$28
		STA !SPC4
		LDA !Difficulty
		AND #$03 : TAY
		LDA.w KINGKING_BaseHP,y
		LSR A
		CMP !HP
		BNE .P1Bounce
		INC !Phase

		.P1Bounce
		JSL $81AB99
		JSL $81AA33
		RTS

		.P1Side
		JSL $80F5B7
		RTS


;================;
;GRAPHICS ROUTINE;
;================;

Graphics:	LDX !SpriteIndex
		LDA $14
		AND #$02
		BEQ .Process
		LDA !InvincTimer
		BEQ .Process
		RTS

		.Process
		LDY #$06				;\
		LDA !Phase				; |
		AND #$7F : CMP #$04			; | CCC bits
		BCC $02 : INY #2			; |
		STY !SomeScratch			;/
		CMP #$03
		BEQ ++
		LDA !InvincTimer
		CMP #$20
		BCC +
		++
		LDA #$08
		STA !HeadAnim
		LDA #$0B
		STA !SpriteAnimIndex
		JMP ++
		+
		LDA !Attack
		AND #$7F : CMP #$03
		BNE $03 : JMP ++
		LDA $1588,x
		AND #$04
		BNE +
		LDA #$0A
		STA !HeadAnim
		LDA #$0D
		STA !SpriteAnimIndex
		JMP ++
		+
		LDA !HeadAnim
		CMP #$06
		BNE +
		LDA !Attack
		BNE +
		LDA !StunTimer
		BNE +
		STZ !HeadAnim
		STZ !HeadTimer
		+
		LDA !HeadAnim
		CMP #$09
		BNE +
		LDA !Attack
		AND #$7F : CMP #$02
		BEQ +
		STZ !HeadAnim
		STZ !HeadTimer
		+

		LDA !Attack
		AND #$7F
		BNE +
		BIT !Attack
		BPL +
		LDA !StunTimer
		BEQ +
		LDA #$0A
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA !HeadAnim
		CMP #$06
		BCC ++
		STZ !HeadAnim
		STZ !HeadTimer
		BRA ++
		+
		CMP #$02
		BNE +
		LDA !StunTimer
		BEQ +
		LDA #$09
		STA !HeadAnim
		LDA #$0C
		STA !SpriteAnimIndex
		BRA ++
		+
		CMP #$05
		BNE +
		LDA #$09
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !HeadAnim
		STZ !HeadTimer
		BRA ++
		+
		LDA !StunTimer
		BEQ +
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA ++
		+
		LDA !SpriteAnimIndex
		BEQ +
		CMP #$09
		BCC ++
		+
		LDA #$01
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		++


		.Draw
		LDA !HeadAnim
		ASL #2
		TAY
		LDA.w .AnimHead+0,y
		STA $04
		LDA.w .AnimHead+1,y
		STA $05
		LDA !HeadTimer
		INC A
		CMP.w .AnimHead+2,y
		BNE +
		LDA.w .AnimHead+3,y
		STA !HeadAnim
		ASL #2
		TAY
		LDA.w .AnimHead+0,y
		STA $04
		LDA.w .AnimHead+1,y
		STA $05
		LDA #$00
	+	STA !HeadTimer
		LDA $15EA,x : PHA
		JSR LOAD_LARGE
		TXA
		LDX !SpriteIndex
		CLC : ADC #$04
		STA $15EA,x
		LDA !Phase				;\
		AND #$7F : CMP #$05			; | Skip head upload + crown during death
		BEQ +					;/
		JSR LOAD_LARGE_LoadHead
		LDA !HeadAnim				;\
		ASL A					; |
		TAY					; |
		LDA.w .AnimCrown+0,y			; |
		STA $04					; |
		LDA.w .AnimCrown+1,y			; | Draw crown
		STA $05					; |
		JSR LOAD_TILEMAP			; |
		LDA $15EA,x				; |
		CLC : ADC $08				; |
		STA $15EA,x				;/
	+	LDA #$80
		TSB !SomeScratch
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .AnimBody+0,y
		STA $04
		LDA.w .AnimBody+1,y
		STA $05
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimBody+2,y
		BNE +
		LDA.w .AnimBody+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .AnimBody+0,y
		STA $04
		LDA.w .AnimBody+1,y
		STA $05
		LDA #$00
	+	STA !SpriteAnimTimer
		JSR LOAD_LARGE
		LDX !SpriteIndex
		LDA !Phase				;\
		AND #$7F : CMP #$05			; | Skip head upload during death
		BEQ +					;/
		JSR LOAD_LARGE_LoadBody
	+	PLA : STA $15EA,x

		.Return
		RTS

		.AnimHead
		.AnimHeadIdle
		dw .HeadIdle00 : db $FF,$01		; 00
		dw .HeadIdle01 : db $01,$02		; 01
		dw .HeadIdle02 : db $01,$03		; 02
		dw .HeadIdle03 : db $03,$04		; 03
		dw .HeadIdle02 : db $01,$05		; 04
		dw .HeadIdle01 : db $01,$00		; 05

		.AnimHeadRoar
		dw .HeadRoar00 : db $FF,$06		; 06

		.AnimHeadBreath
		dw .HeadBreath00 : db $FF,$07		; 07

		.AnimHeadHurt
		dw .HeadHurt00 : db $FF,$08		; 08

		.AnimHeadSquat
		dw .HeadSquat00 : db $FF,$09		; 09

		.AnimHeadJump
		dw .HeadJump00 : db $FF,$0A		; 0A

		.AnimHeadCharge
		dw .HeadCharge00 : db $FF,$0B		; 0B
		dw .HeadCharge01 : db $FF,$0C		; 0C
		dw .HeadCharge02 : db $FF,$0D		; 0D


		.AnimCrown
		.AnimCrownIdle
		dw .CrownIdle00				; 00
		dw .CrownIdle01				; 01
		dw .CrownIdle02				; 02
		dw .CrownIdle03				; 03
		dw .CrownIdle02				; 04
		dw .CrownIdle01				; 05

		.AnimCrownRoar
		dw .CrownRoar00				; 06

		.AnimCrownBreath
		dw .CrownBreath00			; 07

		.AnimCrownHurt
		dw .CrownHurt00				; 08

		.AnimCrownSquat
		dw .CrownSquat00			; 09

		.AnimCrownJump
		dw .CrownJump00				; 0A

		.AnimCrownCharge
		dw .CrownCharge00			; 0B
		dw .CrownCharge01			; 0C
		dw .CrownCharge02			; 0D


		.AnimBody
		.AnimBodyIdle
		dw .BodyIdle00 : db $FF,$00		; 00

		.AnimBodyWalk
		dw .BodyWalk00 : db $07,$02		; 01
		dw .BodyWalk01 : db $07,$03		; 02
		dw .BodyWalk02 : db $07,$04		; 03
		dw .BodyWalk01 : db $07,$05		; 04
		dw .BodyWalk00 : db $07,$06		; 05
		dw .BodyWalk03 : db $07,$07		; 06
		dw .BodyWalk04 : db $07,$08		; 07
		dw .BodyWalk03 : db $07,$01		; 08

		.AnimBodyThrow
		dw .BodyThrow00 : db $FF,$09		; 09

		.AnimBodyStomp
		dw .BodyStomp00 : db $FF,$0A		; 0A

		.AnimBodyHurt
		dw .BodyHurt00 : db $FF,$0B		; 0B

		.AnimBodySquat
		dw .BodySquat00 : db $FF,$0C		; 0C

		.AnimBodyJump
		dw .BodyJump00 : db $FF,$0D		; 0D

		.AnimBodyCharge
		dw .BodyCharge00 : db $FF,$0E		; 0E
		dw .BodyCharge01 : db $FF,$0F		; 0F
		dw .BodyCharge02 : db $FF,$10		; 10



incsrc "SpriteGFX/KingKing.tilemap.asm"


;=============;
;XTURN ROUTINE;
;=============;
XTURN_TABLE:	dw $FFF0
		dw $0010

XTurn:		RTS
		LDA $157C,x			;\
		ASL A				; | Y = direction * 2
		TAY				;/
		LDA $14E0,x			;\
		XBA				; | Load 16 bit Xpos
		LDA $E4,x			;/
		REP #$20			; > A 16 bit
		CLC : ADC XTURN_TABLE,y		; > Add value based on direction
		SEP #$20			; > A 8 bit
		STA $E4,x			;\
		XBA				; | Store 16 bit Xpos
		STA $14E0,x			;/
.Return		RTS


;===================;
;FACE PLAYER ROUTINE;
;===================;
FacePlayer:
		PHY
		LDY #$00
		LDA !P1Dead
		BNE .P2

		.P1
		LDA $94
		SEC : SBC $E4,x
		LDA $95
		SBC $14E0,x
		BCC $01 : INY
		TYA
		STA $157C,x
		PLY
		RTS

		.P2
		LDA !P2XPosLo
		SEC : SBC $E4,x
		LDA !P2XPosHi
		SBC $14E0,x
		BCC $01 : INY
		TYA
		STA $157C,x
		PLY
		RTS

;==============================;
;UPDATE OFFSET-PER-TILE ROUTINE;
;==============================;
UPDATE_MODE2:	PHB				;\
		JSL !GetVRAM			; |
		LDA #$7F			; |
		PHA : PLB			; |
		REP #$20			; |
		LDA.w #$0040			; |
		STA.w !VRAMtable+0,x		; |
		LDA.w #$A100			; | Update offset-per-tile every frame
		STA.w !VRAMtable+2,x		; |
		LDA.w #$7FA1			; |
		STA.w !VRAMtable+3,x		; |
		LDA.w #$5320			; |
		STA.w !VRAMtable+5,x		; |
		SEP #$20			;/

		LDX #$38
		REP #$30
	-	LDA $A140,x
		AND #$01FF^$FFFF
		STA $00
		LDA $A140,x
		AND #$01FF			;\ No motion if timer is zero
		BEQ +				;/
		DEC A				;\
		ORA $00				; | Decrement timer
		STA $A140,x			;/
		BPL .Up

		.Down
		LDA $A100,x
		AND #$01FF
		CMP $1C
		BEQ ++
		DEC $A100,x
		BRA +
	++	STZ $A140,x
		BRA +

		.Up
		INC $A100,x
		INC $A100,x
		LDA $A100,x
		AND #$01FF
		SEC : SBC $1C
		CMP #$0006
		BEQ .Side
		CMP #$000A
		BCC +
		LDA $A140,x
		ORA #$8000
		STA $A140,x
		BRA +

		.Side
		BIT $00
		BVC .Left

		.Right
		CPX #$0038
		BEQ +
		LDA #$41FF
		STA $A142,x
		LDA $1C
		INC #2
		ORA #$2000
		STA $A102,x
		BRA +

		.Left
		CPX #$0004
		BCC +
		LDA #$01FF
		STA $A13E,x

	+	DEX #2
		BPL -
		SEP #$30
		PLB
		RTS



;=============;
;SHAKE ROUTINE;
;=============;
SHAKE:

		LDA $14
		AND #$02
		CLC
		ADC $0300,y
		STA $0300,y
		RTS

;=====================;
;FLYING DEBRIS ROUTINE;
;=====================;
;
; This routine will spawn two flying brick pieces at the position of sprite X
;
DEBRIS:		LDA #$01
		STA $00				; Set up loop
		LDY #$0C
.Loop		DEY
		BMI .Return
		LDA $17F0,y
		BNE .Loop
		LDA #$01			;\ Minor ExSprite = Brick Piece
		STA $17F0,y			;/
		LDA $D8,x			;\
		CLC				; |
		ADC #$0C			; |
		STA $17FC,y			; |
		LDA $14D4,x			; | Spawn 0C pixels below sprite
		ADC #$00			; |
		STA $1814,y			; |
		LDA $E4,x			; |
		STA $1808,y			; | Spawn at sprite pos
		LDA $14E0,x			; |
		STA $18EA,y			;/
		LDA #$FD			;\ Set Y speed
		STA $1820,y			;/
		PHY				;\
		LDY $00				; |
		LDA .XSpeed,y			; | Set X speed
		PLY				; |
		STA $182C,y			;/
		LDA #$00			;\ Set timer
		STA $1850,y			;/
		DEC $00
		BPL .Loop			; Loop once
.Return		RTS

.XSpeed		db $01,$FF			; Table


;==========================;
;COMPARE X POSITION ROUTINE;	Load sprite A Xpos - sprite B Xpos
;==========================;
COMPARE_X:	LDA $14E0,y
		STA $0E
		LDA $00E4,y
		STA $0D
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC
		SBC $0D
		SEP #$20
		RTS

;==================;
;DEATH HDMA ROUTINE;
;==================;
DeathHDMA:

.Enable		LDA !StunTimer
		INC A
		BEQ .Return
		REP #$20
		LDA #$3200		; Register 2132, one register write once
		STA $4330
		LDA #$A400		; Location of HDMA table (within bank)
		STA $4332
		LDY #$7F		; Source bank
		STY $4334		;
		SEP #$20
		LDA #$08		; Enable HDMA on channel 3
		TSB $0D9F

.Update		LDA #$7F
		STA $7FA400
		STA $7FA402
		STA $7FA404

		LDA !StunTimer
		BPL +
		EOR #$FF
		LSR A
		LSR A
		ORA #$E0
		BRA ++
	+	JSR DeathMask
		LDA !StunTimer
		LDA #$FF
	++	STA $7FA401
		STA $7FA403
		STA $7FA405

		LDA #$00		;\ End table
		STA $7FA406		;/
		LDA #$90		;\ Enable colour subtraction on sprites
		STA $40			;/
		LDA #$02		;\ Disable translucency
		TRB $44			;/
		LDA #$3F		;\ Put everything on main screen
		STA $212C		;/
.Return		RTS

;==================;
;DEATH MASK ROUTINE;
;==================;

DeathMask:

		LDA #$80			;\ Disable HDMA channel 7
		TRB $0D9F			;/

		REP #$20			; > A 16 bit
		LDA #$2504			;\ Register 2125, four registers write once (yes, it will mess with 2128)
		STA $4340			;/
		LDA #$A407			;\ Location of table within bank
		STA $4342			;/
		LDY #$7F			;\ Source bank
		STY $4344			;/
		SEP #$20			; > A 8 bit
		LDA #$10			;\ Enable HDMA on channel 4
		TSB $0D9F			;/

		LDA $D8,x
		CLC
		ADC #$11			; Start at this scanline
		STA $00				; Preserve value
		LSR A				; Use twice
		STA $7FA407			;\ Scanline count
		STA $7FA40C			;/
		LDA #$00			;\
		STA $7FA408 : STA $7FA40D	; |
		STA $7FA409 : STA $7FA40E	; | Don't do anything on these scanlines
		STA $7FA40A : STA $7FA40F	; |
		STA $7FA40B : STA $7FA410	;/

		LDA !StunTimer			;\
		EOR #$7F			; |
		LSR A				; | Window height
		INC A				; |
		STA $7FA411			;/
		CLC : ADC $00 : STA $01		; > Preserve value
		LDA #$02 : STA $7FA412		; > 2125 = 0x02
		LDY $157C,x			;\
		LDA .XDisp,y			; | Load left position based on direction
		CLC : ADC $E4,x			;/
		STA $7FA413			; > 2126 = Left edge of boss
		CLC : ADC #$28			;\
		BCC +				; | Handle width overflow
		LDA #$FF			; |
		+				;/
		STA $7FA414			; > 2127 = Right edge of boss
		LDA #$00 : STA $7FA415		; > 2128 = 0x00

		LDA #$DF : SEC : SBC $01	; Calculate remaining scanline count
		LSR A				; Use twice
		STA $7FA416 : STA $7FA41B	; > Scanlince count
		LDA #$00			; > A = 0x00
		STA $7FA417 : STA $7FA41C	; > 2125 = 0x00
		STA $7FA418 : STA $7FA41D	; > 2126 = 0x00
		STA $7FA419 : STA $7FA41E	; > 2127 = 0x00
		STA $7FA41A : STA $7FA41F	; > 2128 = 0x00
		STA $7FA420			; > End table

		LDA #$10			;\
		STA $212E			; | Only mask the sprite layer
		STA $212F			;/
		RTS

.XDisp		db $FE,$E8			; Left, right


;============;
;KILL ROUTINE;
;============;
KILL:
		STZ $71				; > Make sure Mario doesn't die at the end
		LDA #$FF			;\ End level
		STA $1493			;/
		LDA #$31			;\ Defeated boss music
		STA $1DFB			;/
		LDA #$01			;\ Trigger castle #1 cutscene
		STA $13C6			;/
		STZ $14C8,x			; > Delete boss
		LDA #$38			;\ Disable custom HDMA
		TRB $0D9F			;/
		PHP : REP #$20			;\
		LDA #$0000			; |
		STA $0F69 : STA $0F6B		; | Clear boss data
		STA $0F6D : STA $0F6F		; |
		PLP				;/
		RTS


	namespace off



;
;	Tilemap format:
;		dw !ByteCount		; > Must be divisible by 4
;		db !Prop		;\
;		db !X			; | For each tile
;		db !Y			; |
;		db !Tile		;/
;
;	!Prop format:
;		YXPPTTTT
;		Y - Vertical flip
;		X - Horizontal flip
;		P - Priority
;		T - Page number
;
;		Palette is hardcoded
;
;	Memory usage:
;		$00 - Xpos within screen
;		$02 - Ypos within screen
;		$04 - Tilemap pointer
;		$06 - Used for 9-bit xpos function
;		$08 - Tilemap size
;		$0A - Claimed GFX slot
;		$0C - Used for horizontal flip function
;		$0E - Used for horizontal flip function
;		!SomeScratch - CCC bits of YXPPCCCT
;		$36 - High byte of tile number (assume mode 7 is not used)



LOAD_LARGE:	LDA $E4,x : STA $00
		LDA $14E0,x : STA $01
		LDA $D8,x : STA $02
		LDA $14D4,x : STA $03
		LDA !ClaimedGFX : STA $0A
		STZ $0B
		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA $02
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		INC $04
		INC $04
		STZ $0C
		LDA $157C,x
		LSR A
		BCC +
		LDA #$0040
		STA $0C
	+	SEP #$20
		LDA $15EA,x : TAX
		LDY #$00

.Loop		LDA ($04),y			; > Get property byte
		EOR $0C				; Horizontal flip
		AND #$F0			; Filter out page number
		ORA #$01			; Always use SP3/SP4
		ORA !SomeScratch		; Add palette
		AND #$7F
		STA !OAM+$103,x			; Write to OAM
		LDA ($04),y
		AND #$0F
		STA $37
		STZ $36
		BIT !OAM+$103,x
		REP #$20
		STZ $0E
		BVC +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y			;\ Get Xdisp byte
		AND #$00FF			;/
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		JMP .End

.GoodX		STA $06				; Save tile xpos
		INY
		LDA ($04),y			;\ Get Ydisp byte
		AND #$00FF			;/
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		JMP .End

.GoodY		SEP #$20
		STA !OAM+$101,x
		LDA $06
		STA !OAM+$100,x
		INY
		LDA $0A				;\
		CLC				; |
		BIT !SomeScratch		; |
		BMI +				; |
		ADC.w .HeadDisp,y		; | Set dynamic tile number
		BRA ++				; |
	+	ADC.w .BodyDisp,y		; |
	++	STA !OAM+$102,x			;/
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$40,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		RTS

.LoadHead	LDY #$03
		PHB : LDA #$7F
		PHA : PLB
		JSL !GetVRAM
		LDA #$31
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		STA !VRAMtable+$12,x
		STA !VRAMtable+$19,x
		REP #$20
		LDA #$00A0
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		STA !VRAMtable+$0E,x
		STA !VRAMtable+$15,x
		LDA $0A
		ASL #4
		ORA #$7000
		STA !VRAMtable+$05,x
		CLC : ADC #$0100
		STA !VRAMtable+$0C,x
		CLC : ADC #$0100
		STA !VRAMtable+$13,x
		CLC : ADC #$0100
		STA !VRAMtable+$1A,x
		PLB
		LDA ($04)			;\
		AND #$000F			; |
		XBA				; |
		STA $00				; | Get tile number byte
		LDA ($04),y			; |
		AND #$00FF			; |
		ORA $00				;/
		ASL #5
		CLC : ADC #$8000
		STA.l !VRAMbase+!VRAMtable+$02,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$09,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$10,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$17,x
		SEP #$20
		LDX !SpriteIndex
		RTS

.LoadBody	LDY #$03
		PHB : LDA #$7F
		PHA : PLB
		JSL !GetVRAM
		LDA #$31
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		STA !VRAMtable+$12,x
		STA !VRAMtable+$19,x
		REP #$20
		LDA #$00A0
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		STA !VRAMtable+$0E,x
		STA !VRAMtable+$15,x
		LDA $0A
		CLC : ADC #$0040
		ASL #4
		ORA #$7000
		STA !VRAMtable+$05,x
		CLC : ADC #$0100
		STA !VRAMtable+$0C,x
		CLC : ADC #$0100
		STA !VRAMtable+$13,x
		CLC : ADC #$0100
		STA !VRAMtable+$1A,x
		PLB
		LDA ($04)			;\
		AND #$000F			; |
		XBA				; |
		STA $00				; | Get tile number byte
		LDA ($04),y			; |
		AND #$00FF			; |
		ORA $00				;/
		ASL #5
		CLC : ADC #$8000
		STA.l !VRAMbase+!VRAMtable+$02,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$09,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$10,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$17,x
		SEP #$20
		LDX !SpriteIndex
		RTS


.HeadDisp	db $00,$00,$00,$00
		db $02,$02,$02,$02
		db $20,$20,$20,$20
		db $22,$22,$22,$22
		db $03,$03,$03,$03
		db $23,$23,$23,$23

.BodyDisp	db $40,$40,$40,$40
		db $42,$42,$42,$42
		db $60,$60,$60,$60
		db $62,$62,$62,$62
		db $43,$43,$43,$43
		db $63,$63,$63,$63




Aim:		PHX
		PHY
		PHP
		SEP #$30
		STA $0F
		
		LDX #$00
		REP #$20
		LDA $00
		BPL .pos_dx
		EOR #$FFFF
		INC
		INX
		INX
		STA $00
	.pos_dx	SEP #$20
		STA $4202
		STA $4203
		
		NOP
		NOP
		NOP
		REP #$20
		LDA $4216
		STA $04
		LDA $02
		BPL .pos_dy
		EOR #$FFFF
		INC
		INX
		STA $02
	.pos_dy	SEP #$20
		STA $4202
		STA $4203
		STX $0E
		
		REP #$30
		LDA $04
		CLC
		ADC $4216
		LDY #$0000
		BCC .loop
		INY
		ROR
		LSR
	.loop	CMP #$0100
		BCC +
		INY
		LSR
		LSR
		BRA .loop
	+	CLC
		ASL
		TAX
		LDA GET_ROOT_Table,x
	-	DEY
		BMI +
		LSR
		BRA -
	+	SEP #$30
		
		STA $4202
		LDA $0F
		STA $4203
		NOP
		STZ $05
		STZ $07
		LDA $4217
		STA $04
		XBA
		STA $4202
		LDA $0F
		STA $4203
		
		REP #$20
		LDA $04
		CLC
		ADC $4216
		STA $04
		SEP #$20
		
		LDX #$02
	-	LDA $04
		STA $4202
		LDA $00,x
		STA $4203
		
		NOP
		NOP
		NOP
		NOP
		
		LDA $4217
		STA $06
		LDA $05
		STA $4202
		LDA $00,x
		STA $4203

		REP #$20
		LDA $06
		CLC
		ADC $4216
		SEP #$20
		
		LSR $0E
		BCS +
		EOR #$FF
		INC
	+	STA $00,x
		DEX
		DEX
		BPL -
		
		PLP
		PLY
		PLX
		RTS