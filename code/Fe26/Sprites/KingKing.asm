

	namespace KingKing


; --Defines--

	!Phase		= !BossData+0
	!HP		= !BossData+1
	!Attack		= !BossData+2
	!AttackTimer	= !BossData+3
	!BossIndex	= !BossData+4
	!ScepterIndex	= !BossData+5
	!BlinkTimer	= !BossData+6		; Timer until boss blinks

	!HoldingScepter	= $BE,x			; If set, scepter will not be displayed on Kingking's sprite.
	!TrueDirection	= $3280,x
	!DeathFlag	= $32A0,x
	!DeathTimer	= $32B0,x
	!StunTimer	= $32D0,x
	!PrevDirection	= $33E0,x
	!XSpeedIndex	= $3410,x
	!InvincTimer	= $3420,x
	!HeadTimer	= $34A0,x		; !SpriteAnimTimer is for body
	!HeadAnim	= $34C0,x		; !SpriteAnimIndex is for body

	!AttackMemory	= $6DF5			; < Technically an OW sprite table, but who cares
	!PreviousFrame	= $6DF6
	!WalkStep	= $6DF7			; Used to pace back and forth
	!IdleAttack	= $6DF8			; 0 for nothing, 1 for fire, 2 for stomp
	!EnrageTimer	= $6DF9


macro KingkingDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+$318000
	dw <DestVRAM>*$10+$6000
endmacro



; --Scepter defines--

	!Stat		= $BE,x
	!ScepterStat	= $30BE,y
	!ScepterTimer	= $32D0,y		; Should equal stun timer, but with Y rather than X


;
; Rework plan:
;	- look over doc and make sure everything is done




	INIT:
	MAIN:
		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04 : BNE SCEPTER
		JMP KINGKING

	SCEPTER:
		LDA !StunTimer : BNE +
		STZ $9E,x
		STZ $AE,x
		LDA #$05
		STA !SpriteAnimIndex
		LDA #$02
		STA $3250,x
		STZ !Stat
		LDA !Phase			;\
		AND #$7F			; |
		CMP #$05 : BEQ +		; | Boss grabs the scepter unless he's dead
		LDX !BossIndex			; |
		STZ !HoldingScepter		; |
		LDX !ScepterIndex		;/
	+	LDA $BE,x
		ASL A
		TAX
		JSR (.StatPtr,x)

		LDA !SpriteAnimIndex
		CMP #$06
		BCC .Interaction
		BEQ .Graphics

		.FireInt
		LDY $3320,x
		LDA $3220,x
		SEC : SBC .FireHitbox,y
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$04
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$18
		STA $06
		BRA +

		.Interaction
		LDA $3220,x			;\
		INC #2				; | X displacement
		STA $04				; |
		LDA $3250,x : STA $0A		;/
		LDA $3210,x : STA $05		;\ Y displacement
		LDA $3240,x : STA $0B		;/
		LDA #$0C : STA $06		;\
		LDA #$10			; | Dimensions
	+	STA $07				;/
		SEC : JSL !PlayerClipping	;\
		BCC .Graphics			; | Hurt players upon contact
		JSL !HurtPlayers		;/

		.Graphics
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .Anim+0,y : STA $04
		LDA.w .Anim+1,y : STA $05
		LDA !SpriteAnimTimer
		INC A
		CMP.w .Anim+2,y : BNE +
		LDA.w .Anim+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA.w .Anim+0,y : STA $04
		LDA.w .Anim+1,y : STA $05
		LDA #$00
	+	STA !SpriteAnimTimer
		JSL LOAD_TILEMAP_Long
		PLB
		RTL

		.StatPtr
		dw .MaintainSpeed		; 00
		dw .Boomerang			; 01
		dw .Dunk			; 02
		dw .Fall			; 03
		dw .ArcBounce			; 04
		dw .FireBlast			; 05

		.FireHitbox
		db $00,$08


		.MaintainSpeed
		LDX !SpriteIndex
	-	JSL $01801A
		JSL $018022
		RTS


		.Boomerang
		LDX !SpriteIndex
		LDY $3320,x
		LDA ..SpeedDeriv,y
		CLC : ADC $AE,x
		STA $AE,x
		LDY !BossIndex
		LDA $3210,x
		CLC : ADC #$10
		CMP $3210,y : BCC +
		DEC $9E,x : BRA -
	+	INC $9E,x : BRA -



		..SpeedDeriv
		db $01,$FF




		.ArcBounce
		JSR .Dunk
		LDA $9E,x			;\
		CMP #$E8 : BCC +		; |
		LDX !BossIndex			; | Have Kingking follow the scepter with his eyes
		LDA !HeadAnim : BNE ++		; |
		LDA #$08 : STA !HeadAnim	; |
		LDA #$10 : STA !HeadTimer	;/
	++	LDX !SpriteIndex
	+	LDA $3330,x
		AND #$03 : BEQ +
		LDA $AE,x
		EOR #$FF : INC A
		STA $AE,x
	+	RTS


		.Dunk
		LDX !SpriteIndex
		JSL $01802A
		LDA $3330,x
		AND #$04 : BEQ +

		LDA #$C8			;\
		LDY !Stat			; |
		CPY #$04			; | Bounce speed
		BNE $02 : LDA #$B0		; |
		STA $9E,x			;/

		LDA $3220,x
		LSR #3
		ASL A
		TAY
		PHB
		LDA #$40
		PHA : PLB
		LDA #$FF : STA $F040,y
		STA $F042,y
		LDA #$01 : STA $F041,y
		LDA #$41 : STA $F043,y
		PLB
		LDA #$09 : STA !SPC4
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
	+	RTS


		.FireBlast
		LDX !SpriteIndex
		STZ $9E,x
		JSL $01802A
		LDA $3330,x
		AND #$03 : BNE +
		RTS


	+	STZ !StunTimer
		LDA $3210,x : STA !BigRAM+0
		LDA $3220,x : STA !BigRAM+1
		LDA $3240,x : STA !BigRAM+2
		LDA $3250,x : STA !BigRAM+3
		LDY $3320,x
		STY !BigRAM+4
		LDA ..Flip,y : STA !BigRAM+5
		LDA !Difficulty
		AND #$03
		TAY
		LDA ..Number,y : BEQ ..Done
		DEC A
		STA !BigRAM+6

	-	JSL $02A9DE			;\ Get sprite slot
		BMI ..Done			;/
		TYX
		LDA #$07 : STA !NewSpriteNum,x
		LDA #$36 : STA $3200,x
		LDA #$08 : STA $3230,x
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08 : STA !ExtraBits,x
		LDA #$FF : STA $32D0,x
		LDA #$E0 : STA $33D0,x
		LDA #$01 : STA $35D0,x
		LDA #$01 : STA $3410,x
		LDA #$38 : STA $33C0,x
		LDY !BigRAM+6
		LDA ..XSpeed,y
		EOR !BigRAM+5
		STA $AE,x
		LDA ..YSpeed,y : STA $9E,x
		LDA !BigRAM+4 : STA $3320,x
		LDA !BigRAM+0 : STA $3210,x
		LDA !BigRAM+1
		CMP #$10
		BCS $02 : LDA #$10
		CMP #$E0
		BCC $02 : LDA #$E0
		STA $3220,x
		LDA !BigRAM+2 : STA $3240,x
		LDA !BigRAM+3 : STA $3250,x
		DEC !BigRAM+6 : BPL -

		..Done
		LDX !SpriteIndex
		JSR Fireball_Target1
		JMP Fireball_Target2


..Flip		db $00,$FF
..Number	db $00,$02,$04
..XSpeed	db $00,$30,$20,$10
..YSpeed	db $C0,$D6,$C9,$BE


		.Fall
		LDX !SpriteIndex
		BIT !Stat : BMI +
		LDY.w .Fall00
		INY
	-	LDA.w .Fall00,y
		STA $7892,y
		DEY : BPL -
		LDA !Stat
		ORA #$80
		STA !Stat
	+

		LDY !BossIndex
		LDA $3320,y : STA $3320,x
		TAY
		DEC $7892+$03			;\
		DEC $7892+$07			; | Update tilemap
		INC $7892+$0B			;/

		LDA $9E,x : BMI +
		CMP #$40 : BCS ++
	+	INC $9E,x
		INC $9E,x
	++	JSL $01801A
		JSL $018022
		RTS


	.Anim
	.AnimSpin
		dw .Spin00 : db $03,$01		; 00
		dw .Spin01 : db $03,$02		; 01
		dw .Spin02 : db $03,$00		; 02
	.AnimIdle
		dw .Idle00 : db $FF,$03		; 03
	.AnimDunk
		dw .Dunk00 : db $10,$05		; 04
		dw .Dunk01 : db $FF,$05		; 05
	.AnimFall
		dw $7892 : db $FF,$06		; 06
	.AnimFireBlast
		dw .FireBlast00 : db $04,$08	; 07
		dw .FireBlast01 : db $04,$07	; 08


	.Spin00
		dw $0008
		db $68,$FC,$00,$E4
		db $68,$04,$00,$E5
	.Spin01
		dw $0008
		db $68,$FC,$00,$E7
		db $68,$04,$00,$E8
	.Spin02
		dw $0008
		db $68,$FC,$00,$EA
		db $68,$04,$00,$EB

	.Idle00
		dw $0008
		db $68,$00,$00,$A8
		db $68,$00,$08,$B8

	.Dunk00
		dw $0008
		db $E8,$FC,$00,$C5
		db $E8,$04,$00,$C6
	.Dunk01
		dw $0008
		db $E8,$00,$08,$AA
		db $E8,$00,$00,$BA

	.Fall00
		dw $000C
		db $68,$E8,$00,$AA
		db $68,$E8,$08,$BA
		db $68,$10,$F0,$AC

	.FireBlast00
		dw $0018
		db $68,$F8,$F8,$A0
		db $68,$08,$F8,$A2
		db $68,$10,$F8,$A3
		db $68,$F8,$08,$C0
		db $68,$08,$08,$C2
		db $68,$10,$08,$C3
	.FireBlast01
		dw $0018
		db $E8,$F8,$F8,$C0
		db $E8,$08,$F8,$C2
		db $E8,$10,$F8,$C3
		db $E8,$F8,$08,$A0
		db $E8,$08,$08,$A2
		db $E8,$10,$08,$A3



	.Fireblast01


	; The following tilemaps are appended to Kingking's body tilemaps.
	.Idle	db $68,$E7,$F2,$C5
		db $68,$EF,$F2,$C6
	.Walk1	db $68,$E1,$F2,$C5
		db $68,$E9,$F2,$C6
	.Walk2	db $68,$E0,$F3,$A5
		db $68,$E8,$F3,$A6
	.Walk3	db $68,$E9,$E4,$AA
		db $68,$E9,$EC,$BA
	.Walk4	db $68,$E6,$F1,$C5
		db $68,$EE,$F1,$C6
	.Walk5	db $68,$E7,$EF,$C5
		db $68,$EF,$EF,$C6
	.Walk6	db $68,$E7,$F2,$A5
		db $68,$EF,$F2,$A6
	.Walk7	db $68,$E8,$E1,$AA
		db $68,$E8,$E9,$BA
	.Fire	db $68,$E3,$08,$A5
		db $68,$EB,$08,$A6
	.Throw	db $68,$E8,$D1,$AA
		db $68,$E8,$D9,$BA
	.Squat	db $68,$E4,$F8,$C5
		db $68,$E4,$F8,$C5
	.Jump	db $68,$E1,$F1,$C5
		db $68,$E9,$F1,$C6


	KINGKING:
		LDA !ExtraBits,x : BMI .Main
		ORA #$80
		STA !ExtraBits,x
		LDA #$04			;\ Stand on the ground
		STA $3330,x			;/
		LDA !Difficulty			;\
		AND #$03 : TAY			; | Set base HP
		LDA.w .BaseHP,y			; |
		STA !HP				;/
		LDA #$01 : STA !Phase		; > Initialize boss
		STZ !BossData+2			;\
		STZ !BossData+3			; |
		STZ !BossData+4			; | Wipe boss data
		STZ !BossData+5			; |
		STZ !BossData+6			;/
		STZ !EnrageTimer		; Wipe enrage
		LDX #$0F			;\
	-	LDA !NewSpriteNum,x		; |
		CMP #$10 : BNE +		; |
		LDA !ExtraBits,x		; |
		AND #$04 : BEQ +		; | Find scepter
		STX !ScepterIndex		; |
		BRA ++				; |
	+	DEX : BPL -			; |
	++	LDX !SpriteIndex		;/
		STX !BossIndex			; > Save boss index
		LDA #$02 : STA !AnimToggle

		.Main
		LDA !HoldingScepter		;\ This prevents a 1-frame bug
		BEQ $03 : INC !HoldingScepter	;/

		LDA !SpriteAnimIndex		;\ This frame is currently displayed
		STA !PreviousFrame		;/
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE LOCK_SPRITE
		LDA !DeathTimer			;\ Handle death timer
		BEQ $03 : DEC !DeathTimer	;/
		LDA !Phase
		ASL A
		TAX
		JSR (.PhasePtr,x)
		PLB
		RTL

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
	db $F0,$10				; Idle, phase 2	;/
	db $F0,$10				; Idle		;\
	db $E0,$20				; Jump		; | NORMAL
	db $C8,$38				; Charge	; |
	db $F0,$10				; Idle, phase 2	;/
	db $F0,$10				; Idle		;\
	db $E0,$20				; Jump		; | INSANE
	db $C0,$40				; Charge	; |
	db $F0,$10				; Idle, phase 2	;/



	LOCK_SPRITE:
		JMP Graphics


	Intro:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main
		LDA #$FF : STA !StunTimer
		LDA #$80 : TSB !Phase
		JMP Graphics

		.Main
	LDA !StunTimer
	CMP #$80
	BNE +
	LDY #$00 : STY !MsgTrigger
	+
	LDA !StunTimer
	BEQ $03
	.Return
	JMP Graphics

		LDA #$02 : STA !Phase		;\ Next phase
		INC !SpriteAnimIndex		;/
		LDA #$02			;\
		STA $3E				; |
		PHB				; |
		LDA #$40			; |
		PHA : PLB			; |
		REP #$20			; |
		LDX #$3E			; | Enable mode 2 and set up offset-per-tile mirror
		LDA #$2000			; |
		ORA $1C				; |
	-	STA $F000,x			; |
		STZ $F040,x			; |
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
		PEA.w Graphics-1
		JMP UPDATE_MODE2		; > Initialize vertical offset data

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
		DEC !SpriteAnimTimer		;\ Prevent animation
		INC !HeadTimer			;/
		STZ !InvincTimer		; Make visible
		STZ !EnrageTimer		; Wipe rage
		LDA !StunTimer : BNE .Return
		BIT !Phase : BMI .Main
		LDA #$3C : STA !StunTimer
		LDA #$80 : TSB !Phase
		JMP Graphics

		.Main
		INC !Phase			; Increment phase
		LDA #$02 : STA !HeadAnim	;\
		LDA #$10 : STA !HeadTimer	; | Roar!
		LDA #$25 : STA !SPC1		;/

		.Return
		JMP Graphics


	Death:
		JSR UPDATE_MODE2
		BIT !Phase : BMI .Main

		.Init
		LDX !ScepterIndex			;\
		LDA #$06 : STA !SpriteAnimIndex		; |
		LDA #$03 : STA !Stat			; | Set scepter data
		LDA #$C0 : STA $9E,x			; |
		LDA #$00 : STA $AE,x			; |
		LDA #$80 : STA !StunTimer		;/
		TXY					; > Y = scepter index
		LDX !SpriteIndex			; > X = sprite index
		INC !HoldingScepter			; Drop scepter
		LDA $3220,x				;\
		STA $3220,y				; |
		LDA $3250,x				; |
		STA $3250,y				; |
		LDA $3210,x				; |
		SEC : SBC #$20				; | Set up scepter for death animation
		STA $3210,y				; |
		LDA $3240,x				; |
		SBC #$00				; |
		STA $3240,y				; |
		LDA $3320,x				; |
		STA $3320,y				;/
		LDA #$01 : STA !Phase			;\ Make sure graphics are loaded
		JSR Graphics				;/

		LDX #$1F				;\
	-	LDA.w .Colors,x				; |
		STA $40F080,x				; | Put palette in RAM
		DEX					; |
		BPL -					;/
		LDA #$85 : STA !Phase			; > Final phase (death animation)
		STA !SPC3				; > Fade music

		.Main
		LDA $14					;\ Only update palette every 4 frames
		AND #$03 : BNE .NoUpdate		;/

		PHB					;\
		LDA #$40				; |
		PHA : PLB				; |
		LDX #$1E				; |
		REP #$20				; |
	-	LDA $F080,x				; |
		STA $00					; |
		AND #$7C00				; |
		BEQ +					; |
		SEC : SBC #$0400			; |
	+	STA $02					; |
		LDA $00					; |
		AND #$03E0				; |
		BEQ +					; |
		SEC : SBC #$0020			; |
	+	STA $04					; |
		LDA $00					; |
		AND #$001F				; |
		BEQ +					; |
		DEC A					; |
	+	ORA $02					; | Darken boss' palette
		ORA $04					; |
		STA $F080,x				; |
		DEX #2					; |
		BPL -					; |
		LDX #$00				; |
	-	LDA !CGRAMtable,x			; |
		BEQ +					; |
		TXA					; |
		CLC : ADC #$0006			; |
		TAX					; |
		BRA -					; |
	+	LDA #$0020				; |
		STA !CGRAMtable+0,x			; |
		LDA #$F080				; |
		STA !CGRAMtable+2,x			; |
		LDA #$40F0				; |
		STA !CGRAMtable+3,x			; |
		SEP #$20				; |
		LDA #$D0				; |
		STA !CGRAMtable+5,x			; |
		PLB					;/

		.NoUpdate
		LDX !SpriteIndex			; Following code fades boss' GFX
		LDA !DeathTimer
		CMP #$79				; Start erasure at t=78
		BCC $03 : JMP +
		AND #$07
		ASL #2
		STA $00
		LDA !DeathTimer
		AND #$78
		LSR #2
		TAY


		REP #$20
		JSL !GetVRAM				; > Get free index
		LDA #$0002				; > 2 bytes/upload
		STA !VRAMbase+!VRAMtable+$00,x		;\
		STA !VRAMbase+!VRAMtable+$07,x		; |
		STA !VRAMbase+!VRAMtable+$0E,x		; |
		STA !VRAMbase+!VRAMtable+$15,x		; |
		STA !VRAMbase+!VRAMtable+$1C,x		; |
		STA !VRAMbase+!VRAMtable+$23,x		; | Set upload regs
		STA !VRAMbase+!VRAMtable+$2A,x		; |
		STA !VRAMbase+!VRAMtable+$31,x		; |
		STA !VRAMbase+!VRAMtable+$38,x		; |
		STA !VRAMbase+!VRAMtable+$3F,x		; |
		STA !VRAMbase+!VRAMtable+$46,x		; |
		STA !VRAMbase+!VRAMtable+$4D,x		;/
		LDA.w #.Zero				; > Data location
		STA !VRAMbase+!VRAMtable+$02,x		;\
		STA !VRAMbase+!VRAMtable+$09,x		; |
		STA !VRAMbase+!VRAMtable+$10,x		; |
		STA !VRAMbase+!VRAMtable+$17,x		; |
		STA !VRAMbase+!VRAMtable+$1E,x		; |
		STA !VRAMbase+!VRAMtable+$25,x		; | Set source regs
		STA !VRAMbase+!VRAMtable+$2C,x		; |
		STA !VRAMbase+!VRAMtable+$33,x		; |
		STA !VRAMbase+!VRAMtable+$3A,x		; |
		STA !VRAMbase+!VRAMtable+$41,x		; |
		STA !VRAMbase+!VRAMtable+$48,x		; |
		STA !VRAMbase+!VRAMtable+$4F,x		;/
		LDA.w #.Zero>>8				; > Data bank
		STA !VRAMbase+!VRAMtable+$03,x		;\
		STA !VRAMbase+!VRAMtable+$0A,x		; |
		STA !VRAMbase+!VRAMtable+$11,x		; |
		STA !VRAMbase+!VRAMtable+$18,x		; |
		STA !VRAMbase+!VRAMtable+$1F,x		; |
		STA !VRAMbase+!VRAMtable+$26,x		; | Set bank regs
		STA !VRAMbase+!VRAMtable+$2D,x		; |
		STA !VRAMbase+!VRAMtable+$34,x		; |
		STA !VRAMbase+!VRAMtable+$3B,x		; |
		STA !VRAMbase+!VRAMtable+$42,x		; |
		STA !VRAMbase+!VRAMtable+$49,x		; |
		STA !VRAMbase+!VRAMtable+$50,x		;/
		LDA.w .VRAMrow,y			;\
		LDY $00					; |
		STA $02					; |
		CLC : ADC.w .VRAMtile+0,y		; |
		STA !VRAMbase+!VRAMtable+$05,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$13,x		; | Dest VRAM for bp1 and bp2
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$21,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$2F,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$3D,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$4B,x		;/
		LDA $02					;\
		CLC : ADC.w .VRAMtile+2,y		; |
		STA !VRAMbase+!VRAMtable+$0C,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$1A,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$28,x		; | Dest VRAM for bp3 and bp4
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$36,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$44,x		; |
		CLC : ADC #$0010			; |
		STA !VRAMbase+!VRAMtable+$52,x		;/
		SEP #$20				; > A 8 bit
		LDX !SpriteIndex			; > X = sprite index
		+

		LDA !DeathTimer
		BNE +
		STZ $3230,x
		LDA #$35 : STA !SPC3
		LDA #$FF : STA !LevelEnd
		LDA #$01 : STA $3E
		REP #$20
		LDA #$38FC
		LDX #$7E
	-	STA $40F000,x
		DEX #2
		BPL -
		SEP #$20
		LDX !SpriteIndex
		RTS

		+
		LDA #$06 : STA !HeadAnim
		LDA #$FF : STA !HeadTimer
		LDA #$07 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
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
		dw $7500
		dw $7400
		dw $7300
		dw $7200
		dw $7100
		dw $7000
		dw $74A0
		dw $73A0
		dw $72A0
		dw $71A0
		dw $70A0


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

		LDA !BlinkTimer : BNE .AlreadyBlink	;\
		LDA !RNG				; |
		AND #$78				; | Wait 2-4 seconds in-between blinks
		CLC : ADC #$78				; |
		STA !BlinkTimer				;/

		.AlreadyBlink
		DEC !BlinkTimer				;\
		BNE .NoBlink				; |
		LDA !HeadAnim				; | Blink when timer hits zero (unless already in animation)
		BNE .NoBlink				; |
		LDA #$0C : STA !HeadAnim		; |
		LDA #$04 : STA !HeadTimer		;/
		.NoBlink



		BIT $3220,x : BMI .CheckLeft		; See if boss is on left or right side

		.CheckRight
		LDA !P2Status-$80 : BNE ..P2		;\
	..P1	LDA !P2XPosLo-$80			; |
		CMP #$C0 : BCS .Enrage			; |
	..P2	LDA !P2Status : BNE .Main		; | Check for players on the far right
		LDA !P2XPosLo				; |
		CMP #$C0 : BCS .Enrage			; |
		BRA .Main				;/

		.CheckLeft
		LDA !P2Status-$80 : BNE ..P2		;\
	..P1	LDA !P2XPosLo-$80			; |
		CMP #$30 : BCC .Enrage			; | Check for players on the far left
	..P2	LDA !P2Status : BNE .Main		; |
		LDA !P2XPosLo				; |
		CMP #$30 : BCS .Main			;/

		.Enrage
		LDA !EnrageTimer : BMI .Main		;\ Increment until enrage timer hits 0x80
		INC !EnrageTimer			;/

		.Main
		LDA !HP					;\
		ORA !DeathFlag				; |
		BNE +					; |
		LDA #$01				; | Check if boss is dead (set !DeathFlag and !DeathTimer)
		STA !DeathFlag				; |
		LDA #$FF : STA !DeathTimer		;/
	+	LDA !DeathFlag : BEQ .Alive		;\
		LDA #$05 : STA !Phase			; | Set phase to dying
		JMP Graphics				;/

		.Alive
		LDA !InvincTimer			;\
		CMP #$20 : BCC .NoHurtStun		; | Don't do any battle stuff while hurt-stunned
		INC !StunTimer				; |
		DEC !SpriteAnimTimer			; |
		JMP Interaction				;/


		.NoHurtStun
		LDA $3330,x
		AND #$04 : BEQ GetAttack		; Don't turn around in midair
		LDA !TrueDirection			;\ Use direction as X speed index
		STA !XSpeedIndex			;/

		.Process
		LDA $3320,x				;\ Set direction of last frame
		STA !PrevDirection			;/
		LDA !StunTimer : BNE GetAttack		; Don't decrement attack timer while boss is stunned
		LDA !AttackTimer : BNE  +		;\
		STZ !Attack				; | Decrement attack timer
		BRA GetAttack				; |
	+	DEC !AttackTimer			;/


	GetAttack:
		LDA $3330,x
		AND #$04 : BNE +
	-	JMP Attack
	+	LDA !AttackTimer : BNE -		; Load attack timer

		LDA !Phase				;\
		AND #$7F				; | No rage in phase 1
		CMP #$02 : BEQ .NoRage			;/
		LDA !EnrageTimer : BPL .NoRage		;\
		STZ !EnrageTimer			; | Rage attack
		LDA #$05 : BRA ++			;/

		.NoRage
		LDA !RNG				; Load RNG
		AND #$0F
		CMP #$04 : BCS +			;\
		LDY !ScepterIndex			; |
		LDA !ScepterStat			; | 25% chance to use scepter (but not during enrage)
		CMP #$05 : BNE .Scepter			; |
		LDA #$03 : BRA ++			;/

		.Scepter
		LDA #$04 : BRA ++			;\ Determine attack
	+	AND #$03				;/
	++	STA !Attack				; > Set attack number
		CMP !AttackMemory : BNE .Fresh		;\
		LDA !Attack				; |
		INC #2					; | Don't allow the same attack twice in a row
		AND #$03				; |
		STA !Attack				;/

		.Fresh
		LDA !Attack : STA !AttackMemory		; Remember this attack
		TAY					;\
		LDA.w Attack_Timer,y			; | Store attack timer
		STA !AttackTimer			;/
		CPY #$02				;\ Jump needs special code
		BEQ .Special				;/
		CPY #$03				;\ Charge needs special code
		BNE Attack				;/
		LDA $3220,x
		BPL .ChargeRight

		.ChargeLeft
		STZ !TrueDirection
		BRA .Special

		.ChargeRight
		LDA #$01
		STA !TrueDirection

		.Special
		JSR Wait				; Set startup time for jump


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
		dw Throw			; Ultimate scepter attack
		dw FireBreath			; Fire breath

		.Timer
		db $80				; Idle, long
		db $40				; Idle, short
		db $04				; Jump
		db $80				; Charge
		db $FF				; Ultimate scepter attack
		db $FF				; Fire breath




	Idle:
		LDX !SpriteIndex
		LDA $3330,x			;\
		AND #$04			; | Make sure boss is on the ground
		BNE .Process			; |
		RTS				;/

		.Process
		BIT !Attack : BMI .Main		;\
		LDA #$80 : TSB !Attack		; |
		STZ !TrueDirection		; |
		BIT $3220,x : BMI +		; | Init code for idle
		INC !TrueDirection		; |
	+	LDA #$01			; |
		STA !SpriteAnimIndex		; |
		STA !SpriteAnimTimer		; |
		STZ !WalkStep			;/

		.Main
		LDA !StunTimer : BNE +
		STZ !IdleAttack
		LDA !WalkStep
		CMP #$04 : BCC ++
		STZ !AttackTimer
		STZ !WalkStep
		RTS

	++	INC !AttackTimer
		LDA !StunTimer			;\ Pause animation while stun timer is set
		BEQ $03				; |
	+	DEC !SpriteAnimTimer		;/
		LDA !SpriteAnimTimer		;\
		BNE .MoreFire			;/
		LDA !SpriteAnimIndex		;\
		CMP #$01 : BEQ .Fire		; |
		CMP #$04 : BEQ .Stomp1		; | Update at these frames
		CMP #$08 : BEQ .Stomp2		; |
		CMP #$19 : BEQ .Fire		;/

		.MoreFire
		LDA !WalkStep
		CMP #$03 : BCC .Return
		LDA !IdleAttack : BNE .Return
		JMP Fireball

		.Return
		RTS

		.Fire
		INC !WalkStep
		JSR Wait
		STA !HeadTimer
		LDA #$02 : STA !HeadAnim
		INC !SpriteAnimTimer
		BRA Fireball

		.Stomp1
		LDA !Attack
		AND #$7F
		CMP #$01 : BNE Stomp
		LDA #$02 : STA !WalkStep	; Becomes 0x03 since it's incremented by the stomp
		LDA #$19 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.Stomp2
		PEA.w Stomp-1

		.Turn
		LDA !TrueDirection		;\
		EOR #$01			; | Turn around
		STA !TrueDirection		;/
		RTS



	Stomp:
		INC !WalkStep
		INC !IdleAttack			; Current attack is stomp
		JSR Wait
		LSR A
		STA !StunTimer
		INC !SpriteAnimTimer

		LDA #$09 : STA !SPC4
		LDA $3320,x
		PHP
		LDA $3220,x
		LSR #3
		ASL A
		TAX
		CPX #$04
		BCS $02 : LDX #$04
		CPX #$38
		BCC $02 : LDX #$38
		LDA #$FF : STA $40F040,x
		LDA #$01
		PLP
		BEQ $02 : LDA #$41
		STA $40F041,x
		LDX !SpriteIndex

		.Return
		RTS


	Fireball:
		LDA !Difficulty
		AND #$03 : TAY
		CPY #$02 : BEQ .Insane
		LDA !Phase
		AND #$7F : CMP #$04
		BNE $01 : INY
		LDA.w KINGKING_DelayTable,y

		.EasyNormal
		XBA
		LDA !Phase
		AND #$7F
		CMP #$04 : BNE +
		XBA
		SEC : SBC !StunTimer
		BRA .DoubleSpit
	+	XBA
		CMP !StunTimer : BNE .Return
		LDA !RNG
		AND #$80
		TAY
		BRA .Target

		.Insane
		LDA !Phase
		AND #$7F : CMP #$04
		BNE $01 : INY
		LDA.w KINGKING_DelayTable,y
		SEC : SBC !StunTimer
		CPY #$03
		BCC .DoubleSpit
		CMP #$00 : BEQ .Target1
		CMP #$04 : BEQ .Target2
		CMP #$08 : BEQ .Target1
		CMP #$0C : BEQ .Target2
		RTS

		.DoubleSpit
		CMP #$00 : BEQ .Target1
		CMP #$04 : BEQ .Target2

		.Return
		RTS

		.Target1
		LDY #$00
		BRA .Target

		.Target2
		LDY #$80

		.Target
		LDA !P2Status-$80,y
		BEQ .Spawn
		TYA
		EOR #$80
		TAY

		.Spawn
		LDA #$17 : STA !SPC4
		LDA !P2XPosLo-$80,y : STA $00
		LDA !P2XPosHi-$80,y : STA $01
		JSL $02A9DE			;\ Get sprite slot
		BMI .Return			;/
		PEI ($00)

		.Process
		JSL SPRITE_A_SPRITE_B_COORDS_Long	; Y pos is overwritten later anyway
		LDA $3210,x			;\
		SEC : SBC #$18			; |
		STA $3210,y			; | Spawn 0x2 tiles above
		LDA $3240,x			; |
		SBC #$00			; |
		STA $3240,y			;/
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
		LDA #$FF			;\ Life timer
		STA $32D0,x			;/
		LDA #$E0			;\ Graphic tile
		STA $33D0,x			;/
		LDA #$01 : STA $35D0,x		; > Spin type
		LDA #$01 : STA $3410,x		; > Hard prop
		LDA #$38 : STA $33C0,x		; > YXPPCCCT
		LDA $3250,x			;\
		XBA				; | Load 16 bit Xpos
		LDA $3220,x			;/
		REP #$20			; A 16 bit
		STA $00
		PLA : STA $02
		LDA $00
		SEC : SBC $02			; Subtract 16 bit player Xpos
		LSR #2				; Divide by 4
		SEP #$20			; A 8 bit
		EOR #$FF			;\
		INC A				; | Invert speed
		STA $AE,x			;/
		STZ $3320,x			;\ Set direction
		BPL $03 : INC $3320,x		;/
		LDA #$B0 : STA $9E,x		; Set some Y speed
		LDX !SpriteIndex		; > Restore sprite index
		RTS




	Jump:
		LDX !SpriteIndex
		BIT !Attack : BMI .Main		;\
		LDA #$0D : STA !SpriteAnimIndex	; | Init animation
		STZ !SpriteAnimTimer		; |
		LDA #$80 : TSB !Attack		;/

		.Main
		LDA !Difficulty
		AND #$03 : BEQ .Process
		LDA !Phase
		AND #$7F
		CMP #$04 : BNE .Process
		LDA $9E,x
		CMP #$BE : BNE .Process
		LDY $3320,x			;\ This offset will be added to scepter Xpos
		LDA .Offset,y : STA $00		;/

		LDX !ScepterIndex
		LDA #$02 : STA !Stat
		LDA #$38 : STA !StunTimer
		LDA #$08 : STA $9E,x
		LDA #$04 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		TXY
		LDX !SpriteIndex
		LDA $3220,x
		CLC : ADC $00
		STA $3220,y
		LDA $3250,x : STA $3250,y
		LDA $3210,x
		SEC : SBC #$20
		STA $3210,y
		LDA $3240,x
		SBC #$00
		STA $3240,y
		LDA $AE,x : STA $30AE,y
		LDA $3320,x : STA $3320,y
		LDX !SpriteIndex
		INC !HoldingScepter

		.NoDunk
		LDX !SpriteIndex

		.Process
		LDA !StunTimer : BNE .Return
		LDA $3330,x
		AND #$04 : BNE .Ground
		LDA $9E,x
		CMP #$F8 : BCC .UpEye

		.DownEye
		LDA #$09 : STA !HeadAnim

		.UpEye
		LDA $3330,x
		AND #$03 : BEQ .Return
		LDA !TrueDirection
		EOR #$01
		STA !TrueDirection
		STA $3320,x
		ORA #$02
		STA !XSpeedIndex
		LDA #$09 : STA !SPC4

		.Return
		RTS

		.Ground
		LDA !AttackTimer
		CMP #$03 : BNE .NoInit
		LDA #$A0 : STA $9E,x
		LDA #$0E : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$02 : STA !HeadAnim
		LDA #$40 : STA !HeadTimer

		.NoInit
		LDA !AttackTimer
		CMP #$02 : BNE .DetermineDirection
		LDA #$09 : STA !SPC4
		JSR Wait
		LDA $3220,x					;\
		LSR #3						; |
		ASL A						; |
		TAY						; |
		PHB						; |
		LDA #$40					; | Create shockwaves upon landing
		PHA : PLB					; |
		LDA #$FF : STA $F040,y				; |
		STA $F042,y					; |
		LDA #$01 : STA $F041,y				; |
		LDA #$41 : STA $F043,y				; |
		PLB						;/
		LDA #$0D : STA !SpriteAnimIndex			;\
		STZ !SpriteAnimTimer				; | Reset animation
		LDA #$01 : STA !HeadAnim			; | (with head bop)
		LDA #$06 : STA !HeadTimer			;/

		.DetermineDirection
		LDA !StunTimer
		BNE .Return
		BIT $3220,x
		BPL .Right

		.Left
		LDA #$02 : STA !XSpeedIndex
		STZ $3320,x
		STZ !TrueDirection
		RTS

		.Right
		LDA #$03 : STA !XSpeedIndex
		LDA #$01
		STA $3320,x
		STA !TrueDirection
		RTS

		.Offset
		db $E8,$18


	Charge:
		LDX !SpriteIndex
		BIT !Attack : BMI .Main
		LDA #$0F : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer			; |
		LDA #$03 : STA !HeadAnim		; | Init animation
		LDA #$40 : STA !HeadTimer		; |
		LDA #$80 : TSB !Attack			;/

		.Main
		LDA !StunTimer
		BEQ $03 : INC !HeadTimer


		LDA !AttackTimer : BNE .NoLanding
		STZ !SpriteAnimIndex
		STZ !HeadAnim

		.NoLanding
		LDA $3330,x
		AND #$03 : BEQ .Process
		LDA !TrueDirection
		EOR #$01
		STA !TrueDirection
		STA $3320,x
		STA !XSpeedIndex
		LDA #$01 : STA !AttackTimer
		LDA #$C8 : STA $9E,x
		LDA #$0E : STA !SpriteAnimIndex		;\
		STZ !SpriteAnimTimer			; | Collide with wall animation
		LDA #$02 : STA !HeadAnim		; |
		LDA #$30 : STA !HeadTimer		;/

		.Process
		LDA !AttackTimer			;\ Return if 1 or 0
		CMP #$02 : BCC .Return			;/
		LDA !TrueDirection
		STA $3320,x
		ORA #$04
		STA !XSpeedIndex

		.Return
		RTS


	Throw:
		LDX !SpriteIndex			; X = sprite index
		BIT !Attack : BMI .Main			;\
		LDA #$80 : TSB !Attack			; |
		LDA #$90 : STA !StunTimer		; |
		LDA #$0A : STA !SpriteAnimIndex		; | Throw animation
		STZ !SpriteAnimTimer			; |
		LDA #$02 : STA !HeadAnim		; |
		LDA #$19 : STA !HeadTimer		; |
		LDA #$25 : STA !SPC1			;/

		.Main
		LDA !StunTimer : BNE +
		STZ !AttackTimer
		RTS
	+	LDA !SpriteAnimIndex			;\
		CMP #$0A : BNE .Return			; | Throw at transition between frames
		LDA !SpriteAnimTimer			; |
		CMP #$0B : BNE .Return			;/

		INC !HoldingScepter
		LDY !ScepterIndex
		LDA $3210,x
		SEC : SBC #$18
		STA $3210,y
		LDA $3220,x : STA $00
		LDA $3240,x : STA $3240,y
		LDA $3250,x : STA $3250,y
		LDA $3320,x : STA $3320,y
		TAY
		LDA.w .Offset,y
		CLC : ADC $00
		XBA
		LDX !ScepterIndex
		XBA : STA $3220,x
		STZ !SpriteAnimIndex			;\ Spin animation
		STZ !SpriteAnimTimer			;/
		LDA !Difficulty
		AND #$03
		CMP #$02 : BNE .Boomerang
		LDA !Phase
		AND #$7F
		CMP #$04 : BEQ .ArcBounce

		.Boomerang
		LDA.w .XSpeed,y : STA $AE,x		;\
		LDA #$E8 : STA $9E,x			; |
		LDA #$01 : STA !Stat			; | Boomerang throw
		LDA #$7C : STA !StunTimer		; |
		LDX !SpriteIndex			;/

		.Return
		RTS

		.ArcBounce
		LDA.w .XSpeed+2,y : STA $AE,x		;\
		LDA #$B0 : STA $9E,x			; |
		LDA #$04 : STA !Stat			; | ULTIMATE throw
		LDA #$D0 : STA !StunTimer		; |
		LDX !SpriteIndex			; |
		LDA #$E8 : STA !StunTimer		;/
		RTS

		.XSpeed
		db $C0,$40
		db $E8,$18

		.Offset
		db $EC,$14


	FireBreath:
		LDX !SpriteIndex
		BIT !Attack : BMI .Main
		LDA #$80 : TSB !Attack
		LDA #$30 : STA !StunTimer
		LDA #$09 : STA !SpriteAnimIndex
		LDA #$04 : STA !HeadAnim
		LDA #$30 : STA !HeadTimer

		.Main
		LDA !StunTimer : BEQ .End
		CMP #$10 : BEQ .Squat
		CMP #$20 : BEQ .BigFire

		.Return
		RTS

		.End
		STZ !AttackTimer
		RTS

		.Squat
		LDA #$0D : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !HeadAnim
		RTS

		.BigFire
		LDA #$17 : STA !SPC4			; Fire SFX
		LDA #$05 : STA !HeadAnim
		LDY !ScepterIndex
		LDA $3320,x : STA $3320,y
		LDA $3210,x
		SEC : SBC #$08
		STA $3210,y
		LDA $3240,x : STA $3240,y
		LDA $3220,x : STA $00
		LDA $3250,x : STA $3250,y
		LDY $3320,x
		LDX !ScepterIndex
		LDA .XSpeed,y : STA $AE,x
		LDA .Offset,y
		CLC : ADC $00
		STA $3220,x
		LDA #$05 : STA !Stat
		LDA #$FF : STA !StunTimer
		LDA #$07 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDX !SpriteIndex
		RTS

		.XSpeed
		db $E0,$20

		.Offset
		db $D0,$30



	UpdateSpeed:
	;	LDA !Attack
	;	AND #$7F : CMP #$03
	;	BEQ +
		LDA !StunTimer
		BNE Interaction
		LDA !Attack
		AND #$7F : CMP #$05
		BNE +
		STZ $AE,x
		BRA ++
	+	LDA !Difficulty
		AND #$03 : ASL #3
		CLC : ADC !XSpeedIndex
		TAY
		LDA.w KINGKING_XSpeed,y
		STA $AE,x
	++	JSL $01802A


	Interaction:
		JSR Graphics				; > Do graphics first

		LDY #$00				;\
	-	LDA !P2Blocked-$80,y			; |
		AND #$04 : BEQ .WaveNext		; |
		LDA !P2Status-$80,y : BNE .WaveNext	; |
		LDA !P2XPosLo-$80,y			; |
		LSR #3					; |
		ASL A					; |
		TAX					; | See if players touch waves
		REP #$20				; |
		LDA $40F03E,x				; |
		ORA $40F040,x				; |
		ORA $40F042,x				; |
		AND #$81FF				; |
		SEP #$20				; |
		BMI .WaveNext				; |
		BEQ .WaveNext				;/

		.Wave
		TYA					;\
		CLC : ROL #2				; |
		INC A					; | Hurt player
		PHY					; |
		JSL !HurtPlayers			; |
		PLY					;/
		LDA #$00 : STA !P2XSpeed-$80,y		;\
		LDA #$B0 : STA !P2YSpeed-$80,y		; | Bounce
		LDA !P2Character-$80,y : BNE .WaveNext	;/
		STZ !MarioXSpeed			;\
		STZ !MarioYSpeed			; |
		LDA #$C0 : STA !P2VectorY-$80,y		; | Special case for Mario
		LDA #$03 : STA !P2VectorAccY-$80,y	; |
		LDA #$15 : STA !P2VectorTimeY-$80,y	;/

		.WaveNext
		CPY #$80 : BEQ .WaveDone		;\ Check for both players
		LDY #$80 : BRA -			;/

		.WaveDone
		LDX !SpriteIndex			; X = sprite index
		LDA $3210,x : STA $02			;\
		LDA $3240,x : STA $03			; | Unpack sprite coordinates
		LDA $3250,x : XBA			; |
		LDA $3220,x				;/
		REP #$20				;\
		SEC : SBC #$0008			; | X position of hitbox
		STA $04					; |
		STA $09					;/
		LDA $02					;\
		SEC : SBC #$0008			; | Y position of hitbox
		STA $05					; |
		XBA : STA $0B				;/
		LDA #$1820 : STA $06			; Hitbox dimensions
		SEP #$20				; A 8 bit

		PEI ($00)				; Preserve head offsets
		PEI ($04)				;\ Preserve hitbox coords
		PEI ($0A)				;/

		JSL FireballContact_Destroy_Long	; Fireballs break upon touching Kingking


		SEC : JSL !PlayerClipping		;\
		BCC .NoBody				; | Hurt players if they touch the boss' body
		JSL !HurtPlayers			;/
		.NoBody

		REP #$20				;\
		PLA : STA $0A				; | Restore hitbox coords
		PLA : STA $04				;/
		PLA					; Get offsets
		SEP #$20
		STZ $00
		LDY $3320,x				;\ Apply X flip
		BEQ $03 : EOR #$FF : INC A		;/
		BPL $02 : DEC $00			; Value is between -80 and +7F instead of 00-FF
		CLC : ADC $04				;\
		CLC : ADC #$08				; |
		STA $04					; |
		STZ $0A					; |
		STZ $00					; |
		XBA : DEC A : INC A			; | Head hitbox coords
		BPL $02 : DEC $00			; |
		CLC : ADC $05				; |
		STA $05					; |
		LDA $0B					; |
		ADC $00					; |
		STA $0B					;/
		LDA #$10				;\
		STA $06					; | Head dimensions
		STA $07					;/

		JSL FireballContact_Destroy_Long	; Fireballs break upon touching Kingking

		SEC : JSL !PlayerClipping
		BCC .CheckAttack
		LSR A : BCC .Next
		PHA
		LDY #$00
		JSR .PlayerTop
		PLA

		.Next
		LSR A : BCC .CheckAttack
		LDY #$80
		JSR .PlayerTop

		.CheckAttack
		LDY #$00
	-	LDA !P2Status-$80,y : BNE +
		REP #$20
		LDA !P2Hitbox-$80+4,y
		SEP #$20
		BEQ +
		LDA !P2Hitbox-$80+0,y : STA $00
		LDA !P2Hitbox-$80+1,y : STA $08
		LDA !P2Hitbox-$80+2,y : STA $01
		LDA !P2Hitbox-$80+3,y : STA $09
		LDA !P2Hitbox-$80+4,y : STA $02
		LDA !P2Hitbox-$80+5,y : STA $03
		PHY
		JSL !CheckContact
		PLY
		BCC $03 : JSR .HurtBoss
	+	CPY #$80 : BEQ .Return
		LDY #$80 : BRA -

		.Return
		RTS


		.PlayerTop
		LDA #$01 : STA !P2SenkuSmash-$80,y
		LDA !P2Status-$80,y : BNE +
		LDA !P2YSpeed-$80,y : BMI +
		JSR .HurtBoss
		LDA !SPC1
		CMP #$02 : BEQ .PlayerBounce
		LDA #$07 : STA !HeadAnim
		LDA #$08 : STA !HeadTimer

		.PlayerBounce
		JSL P2Bounce_Long
	+	RTS


		.HurtBoss
		PHY
		LDA !SpriteAnimIndex
		CMP #$09 : BEQ ++
		LDA !InvincTimer : BEQ +
		LDA #$02 : STA !SPC1		; SFX
	++	PLY
		RTS
	+	DEC !HP
		LDA #$30 : STA !InvincTimer
		LDA #$06 : STA !HeadAnim
		LDA #$0C : STA !HeadTimer
		LDA #$28 : STA !SPC4
		LDA !Difficulty
		AND #$03 : TAY
		LDA.w KINGKING_BaseHP,y
		LSR A
		CMP !HP : BNE +
		LDA !Phase
		AND #$7F
		INC A
		STA !Phase
	+	PLY
		RTS



;================;
;GRAPHICS ROUTINE;
;================;
; Method:
; - Update frame
; - Put body tilemap pointer in RAM ($0E)
; - Put head offsets in RAM $06-$07
; - Put scepter tilemap pointer in RAM ($08)
; - Load dynamo if this is a new frame
; - Update head by reverting to 0 once the timer hits 0
; - Put head tilemap pointer in RAM ($04)
; - Load head tilemap into !BigRAM using the offsets in $06-$07
; - If scepter is held, add its tilemap to !BigRAM, increasing header by 8
; - Add body tilemap to !BigRAM
;



Graphics:	LDX !SpriteIndex


		.Process
	; Animation checks go here



		.Draw
		REP #$30
		LDA !SpriteAnimIndex			;\
	-	AND #$00FF				; |
		STA $00					; |
		ASL #2					; | Index = frame * 10
		CLC : ADC $00				; |
		ASL A					; |
		TAY					;/
		SEP #$20				;\
		LDA !SpriteAnimTimer			; |
		INC A					; |
		CMP.w ANIM+2,y : BNE +			; | Update frame
		LDA #$FF : STA !SpriteAnimTimer		; |
		LDA.w ANIM+3,y : STA !SpriteAnimIndex	;/
		CMP #$12 : BEQ ++			;\
		CMP #$16 : BNE +++			; | Stomp sound on some charge frames
	++	LDA #$09 : STA !SPC4			; |
		BRA ++++				;/
	+++	CMP #$04 : BEQ ++			; \
		CMP #$08 : BEQ ++			;  | Bop head at frames 4, 8, and 19
		CMP #$19 : BNE +++			;  |
	++	LDA !HeadAnim : BEQ ++			;  | (unless it is already doing another animation)
		CMP #$0A : BCC ++++			;  |
	++	LDA #$01 : STA !HeadAnim		;  |
		LDA #$0D : STA !HeadTimer		; /
	++++	LDA !SpriteAnimIndex			; |
	+++	REP #$20				; |
		BRA -					;/

	+	STA !SpriteAnimTimer			; > Update animation timer
		REP #$20				; A 16 bit
		LDA.w ANIM+0,y : STA $0E		; Tilemap pointer
		LDA.w ANIM+4,y : STA $08		; Scepter tilemap pointer
		LDA.w ANIM+6,y : STA $0C		; Dynamo pointer
		LDA.w ANIM+8,y : STA $06		; Head offsets
		PHA					; (preserve this since it's needed for interaction routine)
		SEP #$30				; > All regs 16 bit
		LDA !SpriteAnimIndex			;\
		CMP !PreviousFrame			; | Load dynamo if this frame isn't loaded
		BEQ +					; |
		CLC : JSL !UpdateGFX			;/
	+	LDA !HeadTimer				;\
		BEQ $03 : DEC !HeadTimer		; |
		CMP #$01 : BNE +			; |
		LDA !HeadAnim				; | Reset head animation once timer hits 0
		CMP #$0B : BCS +++			; |
		CMP #$07 : BNE ++			; | (exception is frame 7 that goes to 6)
	+++	DEC !HeadAnim				; | (and also the C -> B -> A -> 0 progression)
		LDA #$08 : STA !HeadTimer		; |
		BRA +					; |
	++	STZ !HeadAnim				;/
	+	LDA !HeadAnim				;\
		ASL A					; |
		TAY					; |
		REP #$20				; | Get head tilemap pointer and header
		LDA.w HEAD+0,y : STA $04		; |
		LDA ($04)				; |
		STA !BigRAM+0				;/
		TAY					;\ Y = index
		DEY					;/
		INC $04					;\ Update pointer past header
		INC $04					;/
		SEP #$20				; A 8 bit
	-	LDA ($04),y : STA !BigRAM+2,y		; > Tile number
		DEY					;\
		LDA ($04),y				; | Y position
		CLC : ADC $07				; |
		STA !BigRAM+2,y				;/
		DEY					;\
		LDA ($04),y				; |
		CLC : ADC $06				; | X position
		STA !BigRAM+2,y				; |
		DEY					;/
		LDA ($04),y : STA !BigRAM+2,y		; > Property byte
		DEY : BPL -				; > Loop

		LDA !HoldingScepter			;\
		CMP #$02				; |
		REP #$20				; |
		BCS +					; |
		LDY !BigRAM+0				; |
		LDX #$03				; |
	-	LDA ($08) : STA !BigRAM+2,y		; |
		INC $08					; | Add scepter if it's held
		INC $08					; |
		INY #2					; |
		DEX : BPL -				; |
		LDA #$0008				; |
		CLC : ADC !BigRAM+0			; |
		STA !BigRAM+0				;/

	+	LDA !BigRAM+0				;\
		CLC : ADC.w #!BigRAM			; | Pointer to next tile in !BigRAM (-2)
		STA $04					;/

		LDA !Phase				;\
		AND #$007F				; |
		CMP #$0005 : BNE +			; |
		LDA $04					; | Crown is a part of scepter rather than head during death
		SEC : SBC #$0004			; |
		STA $04					; |
		+					;/

		LDA ($0E)
		TAY
		CLC : ADC !BigRAM
		STA !BigRAM
	-	LDA ($0E),y : STA ($04),y		;\ Add body tilemap
		DEY #2 : BNE -				;/

		LDA.w #!BigRAM+0 : STA $04		; > True tilemap
		SEP #$30
		LDX !SpriteIndex
		LDA !InvincTimer
		AND #$02 : BNE .Return
		JSL LOAD_TILEMAP_Long			; > Load tilemap

		LDA !Phase				;\
		AND #$7F				; | Shake during transformation
		CMP #$03				; |
		BNE $03 : JSR SHAKE			;/

		LDA !Phase				;\
		AND #$7F				; | Use different palette during phase 2
		CMP #$04				; |
		BCC $03 : JSR FORM			;/

		.Return
		REP #$20				;\
		PLA : STA $00				; | Restore head offsets to $00-$01
		SEP #$30				;/
		RTS


; ANIM format:
; - tilemap pointer
; - frame count
; - next frame
; - scepter tilemap
; - dynamo pointer
; - head offset (added to X/Y of head)
; Each entry is 10 bytes


	ANIM:

		.Idle
		dw TILEMAP_48x40 : db $FF,$00		; 00
		dw SCEPTER_Idle
		dw DYNAMO_BodyIdle
		db $FC,$E1

		.Walk
		dw TILEMAP_48x40 : db $11,$02		; 01
		dw SCEPTER_Idle
		dw DYNAMO_BodyIdle
		db $FC,$E1
		dw TILEMAP_40x40 : db $09,$03		; 02
		dw SCEPTER_Walk1
		dw DYNAMO_BodyWalk1
		db $F5,$E2
		dw TILEMAP_40x40 : db $07,$04		; 03
		dw SCEPTER_Walk2
		dw DYNAMO_BodyWalk2
		db $F5,$E0
		dw TILEMAP_48x40 : db $07,$05		; 04
		dw SCEPTER_Walk3
		dw DYNAMO_BodyWalk3
		db $F8,$DF
		dw TILEMAP_48x40 : db $11,$06		; 05
		dw SCEPTER_Walk4
		dw DYNAMO_BodyWalk4
		db $FA,$E1
		dw TILEMAP_48x40 : db $09,$07		; 06
		dw SCEPTER_Walk5
		dw DYNAMO_BodyWalk5
		db $FC,$E0
		dw TILEMAP_48x40 : db $07,$08		; 07
		dw SCEPTER_Walk6
		dw DYNAMO_BodyWalk6
		db $FE,$DF
		dw TILEMAP_48x40 : db $07,$1C		; 08
		dw SCEPTER_Walk7
		dw DYNAMO_BodyWalk7
		db $F9,$E0

		.Fire
		dw TILEMAP_32x32 : db $FF,$09		; 09
		dw SCEPTER_Fire
		dw DYNAMO_BodyFire
		db $F0,$00

		.Throw
		dw TILEMAP_48x40 : db $0D,$0B		; 0A
		dw SCEPTER_Walk6
		dw DYNAMO_BodyWalk6
		db $FE,$DF
		dw TILEMAP_48x48 : db $07,$0C		; 0B
		dw SCEPTER_Throw
		dw DYNAMO_BodyThrow1
		db $F8,$E0
		dw TILEMAP_48x48 : db $FF,$0C		; 0C
		dw SCEPTER_Throw
		dw DYNAMO_BodyThrow2
		db $FC,$E1

		.Squat
		dw TILEMAP_40x32 : db $40,$00		; 0D
		dw SCEPTER_Squat
		dw DYNAMO_BodySquat
		db $F1,$E7

		.Jump
		dw TILEMAP_40x40 : db $FF,$00		; 0E
		dw SCEPTER_Jump
		dw DYNAMO_BodyJump
		db $F5,$E1

		.Charge
		dw TILEMAP_48x40 : db $06,$10		; 0F
		dw SCEPTER_Idle
		dw DYNAMO_BodyIdle
		db $FC,$E1
		dw TILEMAP_40x40 : db $04,$11		; 10
		dw SCEPTER_Walk1
		dw DYNAMO_BodyWalk1
		db $F5,$E2
		dw TILEMAP_40x40 : db $04,$12		; 11
		dw SCEPTER_Walk2
		dw DYNAMO_BodyWalk2
		db $F5,$E0
		dw TILEMAP_48x40 : db $04,$13		; 12
		dw SCEPTER_Walk3
		dw DYNAMO_BodyWalk3
		db $F8,$DF
		dw TILEMAP_48x40 : db $06,$14		; 13
		dw SCEPTER_Walk4
		dw DYNAMO_BodyWalk4
		db $FA,$E1
		dw TILEMAP_48x40 : db $04,$15		; 14
		dw SCEPTER_Walk5
		dw DYNAMO_BodyWalk5
		db $FC,$E0
		dw TILEMAP_48x40 : db $04,$16		; 15
		dw SCEPTER_Walk6
		dw DYNAMO_BodyWalk6
		db $FE,$DF
		dw TILEMAP_48x40 : db $04,$0F		; 16
		dw SCEPTER_Walk7
		dw DYNAMO_BodyWalk7
		db $F9,$E0

		.WalkBack
		dw TILEMAP_40x40 : db $09,$01		; 17
		dw SCEPTER_Walk1
		dw DYNAMO_BodyWalk1
		db $F5,$E2
		dw TILEMAP_40x40 : db $07,$17		; 18
		dw SCEPTER_Walk2
		dw DYNAMO_BodyWalk2
		db $F5,$E0
		dw TILEMAP_48x40 : db $11,$18		; 19
		dw SCEPTER_Walk4
		dw DYNAMO_BodyWalk4
		db $FA,$E1
		dw TILEMAP_48x40 : db $09,$19		; 1A
		dw SCEPTER_Walk5
		dw DYNAMO_BodyWalk5
		db $FC,$E0
		dw TILEMAP_48x40 : db $07,$1A		; 1B
		dw SCEPTER_Walk6
		dw DYNAMO_BodyWalk6
		db $FE,$DF
		dw TILEMAP_48x40 : db $11,$1B		; 1C
		dw SCEPTER_Idle
		dw DYNAMO_BodyIdle
		db $FC,$E1





	TILEMAP:
		.48x40
		dw $0024
		db $69,$F0,$E8,$00
		db $69,$00,$E8,$02
		db $69,$10,$E8,$04
		db $69,$F0,$F0,$10
		db $69,$00,$F0,$12
		db $69,$10,$F0,$14
		db $69,$F0,$00,$30
		db $69,$00,$00,$32
		db $69,$10,$00,$34

		.40x40
		dw $0024
		db $69,$F0,$E8,$00
		db $69,$00,$E8,$02
		db $69,$08,$E8,$03
		db $69,$F0,$F0,$10
		db $69,$00,$F0,$12
		db $69,$08,$F0,$13
		db $69,$F0,$00,$30
		db $69,$00,$00,$32
		db $69,$08,$00,$33

		.48x48
		dw $0024
		db $69,$F0,$E0,$00
		db $69,$00,$E0,$02
		db $69,$10,$E0,$04
		db $69,$F0,$F0,$20
		db $69,$00,$F0,$22
		db $69,$10,$F0,$24
		db $69,$F0,$00,$40
		db $69,$00,$00,$42
		db $69,$10,$00,$44

		.32x32
		dw $0010
		db $69,$08,$F0,$00
		db $69,$18,$F0,$02
		db $69,$08,$00,$20
		db $69,$18,$00,$22

		.40x32
		dw $0018
		db $69,$F0,$F0,$00
		db $69,$00,$F0,$02
		db $69,$08,$F0,$03
		db $69,$F0,$00,$20
		db $69,$00,$00,$22
		db $69,$08,$00,$23



; How do I do the eye movements? I don't actually know...

	HEAD:

		dw .Normal1		; 0
		dw .Normal2		; 1
		dw .Roar		; 2
		dw .Charge		; 3
		dw .Prepfire		; 4
		dw .Fire		; 5
		dw .Hurt		; 6 \ Unique progression: 7 -> 6 -> 0
		dw .Stomped		; 7 /
		dw .EyesUp		; 8
		dw .EyesDown		; 9
		dw .EyesHalfClosed	; A \
		dw .EyesClosed		; B  | Unique progression: C -> B -> A -> 0
		dw .EyesHalfClosed	; C /


		.Normal1
		dw $0014
		db $69,$F8,$F0,$80
		db $69,$08,$F0,$82
		db $69,$F8,$00,$A0
		db $69,$08,$00,$A2
		db $68,$0B,$E4,$AC

		.Normal2
		dw $0014
		db $69,$F8,$F0,$84
		db $69,$08,$F0,$86
		db $69,$F8,$00,$A4
		db $69,$08,$00,$A6
		db $68,$0E,$E1,$AC

		.Roar
		dw $0014
		db $69,$F8,$F0,$C0
		db $69,$08,$F0,$C2
		db $69,$F8,$00,$E0
		db $69,$08,$00,$E2
		db $68,$0B,$E4,$AC

		.Charge
		dw $0028
		db $69,$EC,$EE,$06
		db $69,$F4,$EE,$07
		db $69,$04,$EE,$09
		db $69,$EC,$F6,$16
		db $69,$F4,$F6,$17
		db $69,$04,$F6,$19
		db $69,$EC,$06,$36
		db $69,$F4,$06,$37
		db $69,$04,$06,$39
		db $68,$FE,$E7,$AC

		.Prepfire
		dw $0014
		db $69,$F8,$F0,$C4
		db $69,$08,$F0,$C6
		db $69,$F8,$00,$E4
		db $69,$08,$00,$E6
		db $68,$0B,$E2,$AE

		.Fire
		dw $0014
		db $69,$F8,$F0,$C8
		db $69,$08,$F0,$CA
		db $69,$F8,$00,$E8
		db $69,$08,$00,$EA
		db $68,$0B,$E4,$AC

		.Hurt
		dw $001C
		db $69,$F8,$EA,$0B
		db $69,$08,$EA,$0D
		db $69,$F8,$F2,$1B
		db $69,$08,$F2,$1D
		db $69,$F8,$02,$3B
		db $69,$08,$02,$3D
		db $68,$09,$DB,$AE

		.Stomped
		dw $001C
		db $69,$F4,$F8,$56
		db $69,$FC,$F8,$57
		db $69,$0C,$F8,$59
		db $69,$F4,$00,$66
		db $69,$FC,$00,$67
		db $69,$0C,$00,$69
		db $68,$09,$EE,$AE

		.EyesHalfClosed
		dw $0018
		db $69,$00,$F0,$88
		db $69,$08,$F0,$89
		db $69,$F8,$F0,$80
		db $69,$F8,$00,$A0
		db $69,$08,$00,$A2
		db $68,$0B,$E4,$AC

		.EyesClosed
		dw $0018
		db $69,$00,$F0,$8B
		db $69,$08,$F0,$8C
		db $69,$F8,$F0,$80
		db $69,$F8,$00,$A0
		db $69,$08,$00,$A2
		db $68,$0B,$E4,$AC

		.EyesUp
		dw $0018
		db $69,$00,$F0,$A8
		db $69,$08,$F0,$A9
		db $69,$F8,$F0,$80
		db $69,$F8,$00,$A0
		db $69,$08,$00,$A2
		db $68,$0B,$E4,$AC

		.EyesDown
		dw $0014
		db $69,$F8,$F0,$C0
		db $69,$08,$F0,$AC
		db $69,$F8,$00,$E0
		db $69,$08,$00,$E2
		db $68,$0B,$E4,$AC



	DYNAMO:
		.BodyIdle
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $000, $100)
		%KingkingDyn(6, $010, $110)
		%KingkingDyn(6, $020, $120)
		%KingkingDyn(6, $030, $130)
		%KingkingDyn(6, $040, $140)
		..End

		.BodyWalk1
		dw ..End-..Start
		..Start
		%KingkingDyn(5, $006, $100)
		%KingkingDyn(5, $016, $110)
		%KingkingDyn(5, $026, $120)
		%KingkingDyn(5, $036, $130)
		%KingkingDyn(5, $046, $140)
		..End

		.BodyWalk2
		dw ..End-..Start
		..Start
		%KingkingDyn(5, $00B, $100)
		%KingkingDyn(5, $01B, $110)
		%KingkingDyn(5, $02B, $120)
		%KingkingDyn(5, $03B, $130)
		%KingkingDyn(5, $04B, $140)
		..End

		.BodyWalk3
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $050, $100)
		%KingkingDyn(6, $060, $110)
		%KingkingDyn(6, $070, $120)
		%KingkingDyn(6, $080, $130)
		%KingkingDyn(6, $090, $140)
		..End

		.BodyWalk4
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $056, $100)
		%KingkingDyn(6, $066, $110)
		%KingkingDyn(6, $076, $120)
		%KingkingDyn(6, $086, $130)
		%KingkingDyn(6, $096, $140)
		..End

		.BodyWalk5
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $0A0, $100)
		%KingkingDyn(6, $0B0, $110)
		%KingkingDyn(6, $0C0, $120)
		%KingkingDyn(6, $0D0, $130)
		%KingkingDyn(6, $0E0, $140)
		..End

		.BodyWalk6
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $0A6, $100)
		%KingkingDyn(6, $0B6, $110)
		%KingkingDyn(6, $0C6, $120)
		%KingkingDyn(6, $0D6, $130)
		%KingkingDyn(6, $0E6, $140)
		..End

		.BodyWalk7
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $0F0, $100)
		%KingkingDyn(6, $100, $110)
		%KingkingDyn(6, $110, $120)
		%KingkingDyn(6, $120, $130)
		%KingkingDyn(6, $130, $140)
		..End

		.BodyFire
		dw ..End-..Start
		..Start
		%KingkingDyn(4, $05C, $100)
		%KingkingDyn(4, $06C, $110)
		%KingkingDyn(4, $07C, $120)
		%KingkingDyn(4, $08C, $130)
		..End

		.BodyThrow1
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $140, $100)
		%KingkingDyn(6, $150, $110)
		%KingkingDyn(6, $160, $120)
		%KingkingDyn(6, $170, $130)
		%KingkingDyn(6, $180, $140)
		%KingkingDyn(6, $190, $150)
		..End

		.BodyThrow2
		dw ..End-..Start
		..Start
		%KingkingDyn(6, $146, $100)
		%KingkingDyn(6, $156, $110)
		%KingkingDyn(6, $166, $120)
		%KingkingDyn(6, $176, $130)
		%KingkingDyn(6, $186, $140)
		%KingkingDyn(6, $196, $150)
		..End

		.BodySquat
		dw ..End-..Start
		..Start
		%KingkingDyn(5, $0FB, $100)
		%KingkingDyn(5, $10B, $110)
		%KingkingDyn(5, $11B, $120)
		%KingkingDyn(5, $12B, $130)
		..End

		.BodyJump
		dw ..End-..Start
		..Start
		%KingkingDyn(5, $0F6, $100)
		%KingkingDyn(5, $106, $110)
		%KingkingDyn(5, $116, $120)
		%KingkingDyn(5, $126, $130)
		%KingkingDyn(5, $136, $140)
		..End



;==============================;
;UPDATE OFFSET-PER-TILE ROUTINE;
;==============================;
UPDATE_MODE2:	PHB				;\
		JSL !GetVRAM			; |
		LDA #$40			; |
		PHA : PLB			; |
		REP #$20			; |
		LDA.w #$0040			; |
		STA.w !VRAMtable+0,x		; |
		LDA.w #$F000			; | Update offset-per-tile every frame
		STA.w !VRAMtable+2,x		; |
		LDA.w #$40F0			; |
		STA.w !VRAMtable+3,x		; |
		LDA.w #$5320			; |
		STA.w !VRAMtable+5,x		; |
		SEP #$20			;/

		LDX #$38
		REP #$30
	-	LDA $F040,x
		AND #$01FF^$FFFF
		STA $00
		LDA $F040,x
		AND #$01FF			;\ No motion if timer is zero
		BEQ +				;/
		DEC A				;\
		ORA $00				; | Decrement timer
		STA $F040,x			;/
		BPL .Up

		.Down
		LDA $F000,x
		AND #$01FF
		CMP $1C
		BEQ ++
		DEC $F000,x
		BRA +
	++	STZ $F040,x
		BRA +

		.Up
		INC $F000,x
		INC $F000,x
		LDA $F000,x
		AND #$01FF
		SEC : SBC $1C
		CMP #$0006
		BEQ .Side
		CMP #$000A
		BCC +
		LDA $F040,x
		ORA #$8000
		STA $F040,x
		BRA +

		.Side
		BIT $00
		BVC .Left

		.Right
		CPX #$0038
		BEQ +
		LDA #$41FF
		STA $F042,x
		LDA $1C
		INC #2
		ORA #$2000
		STA $F002,x
		BRA +

		.Left
		CPX #$0004
		BCC +
		LDA #$01FF
		STA $F03E,x

	+	DEX #2
		BPL -
		SEP #$30
		PLB
		RTS



;=============;
;SHAKE ROUTINE;
;=============;
SHAKE:		LDA $33B0,x : STA $00		; $33B0,x is the start of the OAM access
		CLC : ADC $08			; $08 is the tilemap size from the LOAD_TILEMAP routine
		TAY				; This will be the OAM index
		LDA $14				;\
		AND #$02			; | Base the shaking off of this
		STA $01				;/
	-	LDA !OAM+$100,y			;\
		CLC : ADC $01			; |
		STA !OAM+$100,y			; | Shake it baby!
		CPY $00 : BEQ +			; |
		DEY #4				; |
		BRA -				;/
	+	RTS				; Return

;=================;
;FORM PROP ROUTINE;
;=================;
FORM:		PHX
		LDA $33B0,x : STA $00
		CLC : ADC $08
		TAX
	-	INC !OAM+$103,x
		INC !OAM+$103,x
		CPX $00 : BEQ +
		DEX #4
		BRA -
	+	PLX
		RTS

;============;
;WAIT ROUTINE;
;============;
Wait:		LDA !Difficulty
		AND #$03
		TAY
		LDA !Phase
		AND #$7F
		CMP #$04
		BNE $01 : INY
		LDA KINGKING_DelayTable,y
		STA !StunTimer
		RTS



	namespace off
