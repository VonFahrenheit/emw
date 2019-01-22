LakituLovers:

	namespace LakituLovers


	!Phase		= !BossData+0
	!HP		= !BossData+1
	!Move		= !BossData+2

	!DesiredXLo	= !BossData+3
	!DesiredXHi	= !BossData+4
	!DesiredYLo	= !BossData+5
	!DesiredYHi	= !BossData+6


	!Enrage		= $3280,x		; If non-zero, boss is enraged
	!Lightning	= $3290,x		; If non-zero, a lightning bolt is on-screen
						;  during Crimson Thunder, it is used to determine the state of the attack
	!LightningTimer	= $32A0,x		; Determines how long the tail should be
	!Impressiveness	= $32B0,x		; Increasing this enough by dancing triggers the peaceful ending


	!Flash		= $32C0,x		; While non-zero, boss will use second palette
						; will flash gent if positive, lady if negative

	!DanceTimer	= $32D0,x
	!MergeTimer	= $3300,x		; While non-zero, big cloud is either separating or forming


	!InvincTimer	= $3420,x

	!AttackMem	= $3430,x		; Previous attack that was used


	!LightningFracX	= $35D0,x
	!LightningFracY	= $35E0,x


	!SpinyMemory	= $6DF5			; 16 bytes

	!Storm		= $6E15			; 1 byte
	!StormSpeed	= $6E16			; 2 bytes

	!Offset1	= $6E18			; 2 bytes
	!Offset2	= $6E1A			; 2 bytes

	!PalFlash	= $6E1C			; 2 bytes



macro LakituDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+$398000
	dw <DestVRAM>*$10+$6000
endmacro



	INIT:
		PHB : PHK : PLB			; > Start of bank wrapper
		LDA !ExtraBits,x		;\ See which sprite it is
		AND #$04 : BNE .Dancepad	;/

		.Lakitu
		PHX
		LDX #$0F
	-	STZ !SpinyMemory
		DEX : BPL -
		LDX #$06
	-	STZ !BossData,x
		DEX : BPL -
		PLX

		LDA #$04 : STA !BigRAM		;\ Suppress crash
		STZ !BigRAM+1			;/
		STZ !Storm
		STZ !StormSpeed
		STZ !StormSpeed+1
		STZ !PalFlash
		STZ !PalFlash+1
		LDA #$06 : STA !Phase		; > Intro phase
		LDA !Difficulty			;\
		AND #$03			; | EASY:	8 HP
		ASL #2				; | NORMAL:	12 HP
		CLC : ADC #$08			; | INSANE:	16 HP
		STA !HP				;/


		.Dancepad
		LDA #$00			;\
		STA.l !VineDestroy+$00		; |
		STA.l !VineDestroy+$11		; | Clear dance regs
		STA.l !VineDestroy+$12		; |
		STA.l !VineDestroy+$13		;/
		PLB				; > End of bank wrapper
		RTL				; > End INIT routine


	MAIN:
		PHB : PHK : PLB

		LDA !ExtraBits,x
		AND #$04 : BEQ LAKITU
		JMP DANCEPAD




; This sprite is mighty strange
; The Lakitu is kind of 2 sprites at once, but they don't actually have unique positions
; The sprite's position is always equal to the male Lakitu's position, unless they are conjoined
; The female Lakitu's position is determined by the GFX routine and an additional hitbox

	LAKITU:


		LDA !Flash			;\
		BEQ .NoFlash			; |
		BPL .Down			; |
	.Up	INC !Flash			; | Handle flash timer
		BRA .NoFlash			; |
	.Down	DEC !Flash			; |
		.NoFlash			;/

		LDA !PalFlash : BEQ +
		INC A
		CMP #$09			; set to 0x0A to flash entire BG
		BNE $02 : LDA #$00
		STA !PalFlash
		+



		LDA !MergeTimer : BEQ .NoMerge
	-	LDA #$0A : STA !SpriteAnimIndex
		REP #$20
		LDA $14
		AND #$0001
		STA $00
		STZ $02
		STZ $06
		STZ !BigRAM
		LDA.w #Anim_BigCloudTM3 : JSR TilemapToRAM
		LDA #$E400 : STA $00
		LDA.w #Anim_BodyTM48x32 : JSR TilemapToRAM
		SEP #$20
		BRA .MaybeStorm
		.NoMerge


		LDA !Phase
		ASL A
		CMP.b #.Limit-.PhasePtr
		BCC $03 : JMP .Invalid
		TAX
		JSR (.PhasePtr,x)
		LDA !MergeTimer : BNE -

		.MaybeStorm
		LDA.b #.HDMA : STA !HDMAptr+0			;\
		LDA.b #.HDMA>>8 : STA !HDMAptr+1		; | Storm HDMA
		LDA.b #.HDMA>>16 : STA !HDMAptr+2		;/
		LDA !Storm : BEQ .Invalid
		CMP #$03 : BCS .Invalid
		LDY #$0F					;\
	-	LDA $3200,y					; |
		CMP #$14 : BNE +				; |
		LDA $309E,y : BMI ++				; |
		LDA $3220,y					; |
		CMP #$1C : BCC +++				; |
		CMP #$D4 : BCS +++				; | Handle spiny fall
		LDA #$10 : STA $309E,y				; |
		BRA +						; |
	+++	LDA #$F3					; |
	++	SEC : SBC #$05					; |
		STA $309E,y					; |
	+	DEY : BPL -					;/

		LDA !SpriteAnimTimer				;\
		LSR #3						; |
		AND #$0F					; | Determine float velocity
		BIT !SpriteAnimTimer				; |
		BPL $02 : EOR #$0F				; |
		STA $00						;/
		PHX						;\
		LDA !MarioYSpeed				; |
		BMI $04 : LDA $00 : STA !MarioYSpeed		; |
		LDX #$00					; |
	-	LDA !P2YPosHi-$80,x : BEQ .Nope			; |
		LDA !P2YPosLo-$80,x				; | Players float at roughly height 0x0130
		CMP #$30 : BCC .Nope				; |
		LDA !P2YSpeed-$80,x				; |
		BMI $05 : LDA $00 : STA !P2YSpeed-$80,x		; |
		LDA #$F4					; |
		STA !P2VectorY-$80,x				; |
		LDA #$10 : STA !P2VectorTimeY-$80,x		;/
	.Nope	CPX #$80 : BEQ +				;\
		LDA !MultiPlayer : BEQ +			; | Float both players
		LDX #$80 : BRA -				;/
	+	PLX

		.Invalid

	; Graphics and interaction

		LDA !Phase
		AND #$7F
		CMP #$03 : BEQ .United
		CMP #$05 : BCS .United
		LDA !MergeTimer : BNE .United

		.Separated
		LDY #$02
	-	JSR .HitBoxBase
		STZ $00
		LDA !Offset1,y
		BPL $02 : DEC $00
		CLC : ADC $04
		STA $04
		LDA $0A
		ADC $00
		STA $0A
		STZ $00
		LDA !Offset1+1,y
		BPL $02 : DEC $00
		CLC : ADC $05
		STA $05
		LDA $0B
		ADC $00
		STA $0B
		JSR .Interact
		DEY #2 : BPL -
		LDA !Enrage
		BEQ $03 : JSR .HitBoxExtra



		LDY !SpriteAnimIndex
		LDA.w Anim_Separated,y
		ASL #2
		CLC : ADC.w Anim_Separated,y
		ASL A
		TAY
		REP #$20
		LDA.w Anim_DoubleData+8,y
		BRA .Shared

		.United
		JSR .HitBoxBase
		JSR .Interact
		LDY !SpriteAnimIndex
		LDA.w Anim_United,y
		ASL A
		CLC : ADC.w Anim_United,y
		ASL A
		TAY
		REP #$20
		LDA.w Anim_SingleData+4,y


		.Shared
		STA $0C
		CLC : JSL !UpdateGFX
		LDA.w #!BigRAM : STA $04
		SEP #$20
		LDA !InvincTimer
		AND #$02 : BNE .Invis
		JSL LOAD_TILEMAP_Long

		.Invis
		PLB
		RTL



		.HDMA
		PHP
		REP #$20
		LDA #$0000 : STA.l !HDMAptr
		SEP #$10

		JSL !GetCGRAM
		LDA #$7217 : STA !VRAMbase+!CGRAMtable+$04,x
		LDA !PalFlash : BEQ ..Reset
		LDA.w #..PalFlash : STA !VRAMbase+!CGRAMtable+$02,x
		LDA !PalFlash
		ASL A
		BRA ..Pal

	..Reset	LDA.w #..PalFlash+$12 : STA !VRAMbase+!CGRAMtable+$02,x
		LDA #$0012
	..Pal	STA !VRAMbase+!CGRAMtable+$00,x

		LDX !MsgTrigger : BNE ..Slow	; > Don't mess up text box

		LDA $22				;\
		CLC : ADC !StormSpeed		; |
		LDX $24				; | Scroll BG3 sideways
		CPX #$90			; | (twice as fast when at the top)
		BNE $04 : CLC : ADC !StormSpeed	; |
		STA $22				;/

		LDY !Storm : BEQ ..Slow
		CPY #$01 : BEQ ..Rise		;
		CPY #$02 : BEQ ..Fall		; 1 and 3 both rise
		CPY #$03 : BEQ ..Rise		;

	..Fall	DEC $24
		LDA $24
		CMP #$0020 : BEQ ++
		CPY #$04 : BEQ ..Slow
		BRA +
	++	LDY #$00 : STY !Storm

	..Slow	LDA $14
		AND #$0003 : BEQ +
		LDA !Level+2
		BRA ++

	..Rise	LDA $24
		INC A
		CMP #$0090
		BCC $03 : LDA #$0090
		STA $24
		CPY #$03 : BCC +
		LDA !Level+2
		CLC : ADC !StormSpeed
		BRA +++

	+	LDA !Level+2
		DEC A
	+++	STA !Level+2
	++	STA $1E
		PLP
		RTL

		..PalFlash
		dw $7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF,$7FFF	; 9 colors
		dw $620B,$59EA,$51A9,$4988,$4147,$3925,$30E4,$28C3,$2082


		.HitBoxBase
		LDA $3220,x : STA $04
		LDA $3250,x : STA $0A
		LDA $3210,x
		CLC : ADC #$04
		STA $05
		LDA $3240,x
		ADC #$00
		STA $0B
		LDA #$10 : STA $06
		LDA #$14 : STA $07
		RTS

		.HitBoxExtra
		LDA $3220,x : STA $04
		LDA $3250,x : STA $0A
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$10
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCS .Interact_Boom
		RTS

		.Interact
		JSR ..Main
		JSL P2Attack_Long
		BCS +
		RTS

		..Main
		PHY
		SEC : JSL !PlayerClipping
		BCC ..Return
		LSR A : BCC ..P2
		PHA
		LDY #$00
		JSR ..Check
		PLA
	..P2	LSR A : BCC ..Return
		LDY #$80
		JSR ..Check

		..Return
		PLY

		..Return2
		RTS


		..Hurt
		LDA !InvincTimer
		CMP #$E0 : BCS ..Return2
		TYA
		CLC : ROL #2
		INC A
	..Boom	JSL !HurtPlayers
		RTS

		..Check
	;	LDA $0B : XBA
	;	LDA $05
	;	REP #$20
	;	SEC : SBC !P2YPosLo-$80,y
	;	CMP #$0004
	;	SEP #$20
	;	BCC ..Hurt

	;	LDA !P2YSpeed-$80,y : BMI ..Return2

	LDA #$01 : STA !P2SenkuSmash-$80,y
	LDA !P2YSpeed-$80,y
	SEC : SBC $9E,x
	BMI ..Hurt
	CMP #$10 : BCC ..Hurt


		LDA #$02 : STA !SPC1
		JSL P2Bounce_Long
		LDA !P2VectorX-$80,y : BNE +
		LDA !RNG
		AND #$40
		SEC : SBC #$20
		STA !P2VectorX-$80,y
		LDA #$10 : STA !P2VectorTimeX-$80,y
	+	LDA !InvincTimer : BNE ..Return2
		LDA #$FF : STA !InvincTimer
		LDA #$28 : STA !SPC4
		DEC !HP
		BNE ..Return2
		LDA #$08 : STA !Phase
		RTS


; Write to !MergeTimer when:
;
; 00 -> 03, 05
; 01 -> 05
; 02 -> 05
; 04 -> 05
;
; so... always at the end of 01, 02, and 04
; at the end of 00 IF it's going to 03 or 05
;



		.PhasePtr
		dw Idle				; 00
		dw LightningRoundabout		; 01
		dw LightningStormVolley		; 02
		dw CrimsonThunder		; 03
		dw DivineStorm			; 04
		dw DanceChallenge		; 05
		dw Intro			; 06
		dw Respect			; 07
		dw Death			; 08
		.Limit


	Intro:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main

		.Init
		LDA !DanceTimer : BNE ..F2
		LDA #$80 : STA !DanceTimer	; this doesn't have to be included in Respect routine
	..F1	STZ !Move
		LDA #$0B : STA !SpriteAnimIndex
		REP #$20
		LDA #$0078 : STA !DesiredXLo
		LDA #$00E0 : STA !DesiredYLo
		SEP #$20
		RTS

	..F2	CMP #$01 : BNE .Return
		LDA #$03 : STA !MsgTrigger
		LDA #$80 : TSB !Phase
		RTS

		.Main
		JSR Move
		LDA !MsgTrigger : BEQ .Start
		LDA #$40 : STA !DanceTimer
		RTS

		.Start
		LDA !DanceTimer : BNE .Return
		LDA #$20 : STA !MergeTimer
		LDA #$37 : STA !SPC3
		STZ !Phase

		.Return
		JMP CrimsonThunder_GFX

	Respect:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main

		.Init
		LDA #$80 : TSB !Phase
		STA !SPC3				; Also fade music
		STZ !SpriteAnimTimer
		BRA Intro_Init_F1

		.Main
		LDA !MsgTrigger : BEQ .LetEnd
		LDA #$40 : STA !Level+4
		.LetEnd
		
		LDA !Move
		CMP #$FF : BEQ .Return
		JSR Move
		BNE .Return
		LDA #$07 : STA !MsgTrigger
		LDA #$35 : STA !SPC3
		LDA #$FF : STA !Move

		.Return
		JMP CrimsonThunder_GFX


	Death:
		LDX !SpriteIndex
		LDA !Level+5 : BEQ .Init

		.Main
		LDA !InvincTimer
		ORA #$20
		STA !InvincTimer
		LDA #$10 : STA !MergeTimer
		LDA #$20 : STA $9E,x
		JSL !SpriteApplySpeed-$10
		JMP CrimsonThunder_GFX

		.Init
		LDA #$01 : STA !Level+5
		LDA #$80 : STA !Level+4
		LDA #$80 : STA !SPC3
		LDA #$0B : STA !MsgTrigger
		RTS


	NewMove:
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA !Phase
		AND #$7F : BEQ .Next
		CMP #$05 : BNE .Dance
		BIT !RNG : BPL .Idle
		LDA !Enrage : BNE .Idle			; Always do the idle first when enraged
	.Next	LDA !AttackMem
		INC A
		STA !Phase
		AND #$03
		STA !AttackMem
		RTS
	.Idle	STZ !Phase
		RTS
	.Dance	LDA #$05 : STA !Phase
		RTS


	Idle:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main

		.Init
		LDA #$80 : TSB !Phase			; Mark as initiated
		STZ !Move				; Enable movement
		LDA #$02 : STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
	..2	LDA !MultiPlayer : BEQ +		;\
		LDA !RNG				; | Random player
		AND #$80				; |
	+	TAY					;/
		REP #$20				;\ Desired X
		LDA !P2XPosLo-$80,y : STA !DesiredXLo	;/
		LDA !RNG				;\
		AND #$007F				; |
		LSR A					; |
		SEC : SBC #$0040			; | Random Y offset
		CLC : ADC !P2YPosLo-$80,y		; |
		CMP #$00C0				; \ capped at 0x00C0
		BCS $03 : LDA #$00C0			; /
		STA !DesiredYLo				; |
		SEP #$20				;/

		.Main
		LDA !Enrage : BEQ ..NoSpawn		; > Only spawn spinies if enraged
		LDA !MsgTrigger : BNE ..NoSpawn		; > Don't spawn during message
		LDA !Difficulty
		AND #$03 : BEQ ..NoSpawn		; > No spinies on EASY
		CMP #$02 : BEQ ..Insane

		..Normal
		LDA $14 : BRA ..Shared			; > 1 spiny every 256 frames on NORMAL

		..Insane
		LDA $14					;\ 1 spiny every 128 frames on INSANE
		AND #$7F				;/

		..Shared
		BNE ..NoSpawn				;\
		JSR CrimsonThunder_Spiny		; |
		TAY					; | Occasionally throw a spiny
		LDA #$08 : STA $3230,y			; |
		LDA #$C0				; |
		STA $309E,y				; |
		..NoSpawn				;/

		JSR Move
		BNE .Moving

		LDA !DanceTimer : BEQ +
		CMP #$01 : BEQ ++
		BRA .Moving
	+	LDA #$10 : STA !DanceTimer
		BRA .Moving

	++	LDA !Move
		AND #$7F
		INC A
		CMP #$05 : BCC +
		JSR NewMove				; Get new phase
		CMP #$03 : BEQ ++
		CMP #$05 : BNE .Return
	++	LDA #$20 : STA !MergeTimer
		.Return
		RTS

	+	STA !Move
		JMP .Init_2
		.Moving





		.GFX
		INC !SpriteAnimTimer
		INC !SpriteAnimTimer

		TDC : XBA
		LDA !SpriteAnimTimer
		REP #$30
		ASL #2
		TAY
		AND #$01FF
		TAX
		LDA.l !TrigTable,x			;\
		LSR #3					; | sine value
		STA $00					;/
		TXA
		CLC : ADC #$0100
		AND #$01FF
		TAX
		LDA.l !TrigTable,x			;\
		LSR #3					; | cosine value
		STA $01					;/


		.GFX2
		LDA $00
		CPY #$0100 : BCC +
		CPY #$0200 : BCC ++
		CPY #$0300 : BCS +
		EOR #$FF00
		BRA +
	++	EOR #$00FF
		BRA +++
	+	EOR #$FFFF
	+++	STA $00


		.GFX3
		SEP #$30
		LDX !SpriteIndex

		LDA !SpriteAnimTimer
		AND #$1F : BNE +
		LDA !SpriteAnimIndex
		INC A
		AND #$07
		LDY !Phase
		CPY #$84
		BNE $03 : CLC : ADC #$08
		STA !SpriteAnimIndex
		+

		STZ $02
		STZ $03
		STZ $06

		LDY !SpriteAnimIndex
		CPY #$04 : BCC +
		CPY #$08 : BCC ++
		CPY #$0C : BCC +
	++	LDA #$40 : STA $02
		+

		LDA Anim_Separated,y
		ASL #2
		CLC : ADC Anim_Separated,y
		ASL A
		TAY

		LDA !Flash
		BEQ +
		BMI +
		LDA #$02 : TSB $02
		+


		REP #$20
		STZ !BigRAM+0


		LDA Anim_DoubleData+0,y : JSR TilemapToRAM
		LDA Anim_DoubleData+2,y : JSR TilemapToRAM

		LDA $3320,x
		AND #$00FF
		BEQ $03 : LDA #$00FF
		STA $0E

		LDA $00
		BIT $01
		BVS $03 : EOR #$00FF
		EOR $0E
		STA !Offset1
		EOR #$FFFF : STA !Offset2

		LDA $01
		EOR #$40FF
		AND #$0200^$FFFF
		STA $01

		LDA !Flash
		AND #$00FF
		CMP #$0080 : BCC +
		LDA #$0002 : TSB $02
		+


		LDA Anim_DoubleData+4,y : JSR TilemapToRAM
		LDA Anim_DoubleData+6,y : JSR TilemapToRAM

		SEP #$20



		LDA !Phase
		AND #$7F
		CMP #$01 : BEQ .NoLightning
		CMP #$02 : BEQ .Lightning

		LDA !Enrage : BEQ .NoLightning

		.Lightning
		LDA $00
		JSR .Halve
		STA $00
		LDA $01
		JSR .Halve
		STA $01

		LDA !RNG
		AND #$80
		TSB $02
		STZ $03

		REP #$20
		LDA.w #Anim_LightningBallSmall
		PHA
		JSR TilemapToRAM
		LDA $00
		EOR #$FFFF
		STA $00
		PLA
		JSR TilemapToRAM
		STZ $00
		LDA.w #Anim_LightningBallBig : JSR TilemapToRAM
		SEP #$20
		.NoLightning

		RTS



		.Halve
		BPL ..Pos
	..Neg	EOR #$FF
		LSR A
		EOR #$FF
		RTS
	..Pos	LSR A
		RTS




	LightningRoundabout:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main

		.Init
		LDA #$80 : TSB !Phase
		REP #$20				;\
		LDA #$0078 : STA !DesiredXLo		; | Desired coord
		LDA #$00D0 : STA !DesiredYLo		; |
		SEP #$20				;/
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !Move				; Enable movement

		.Main
		JSR Move
		BEQ .Attack
		LDA #$FF : STA !DanceTimer
		JMP Idle_GFX

		.Attack
		LDA !DanceTimer
		ORA !Lightning
		BNE .Go
		LDA #$20 : STA !MergeTimer
		JMP NewMove
	.Go	JSR BigSpin

		LDA !Lightning : BNE .Zap
		LDA !Flash : BEQ .GetAttack
		CMP #$01 : BEQ .GentShoot
		CMP #$FF : BEQ .LadyShoot
	.Return	RTS

		.LadyShoot
		REP #$20
		LDA !Offset2 : STA $00
		BRA .Shoot

		.GentShoot
		REP #$20
		LDA !Offset1 : STA $00

		.Shoot
		SEP #$20
		LDA #$09 : STA !Lightning
		STZ !LightningTimer
		JSR Zap_Spawn
		REP #$20
		LDA $00
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !SpinyMemory+$8
		STA !SpinyMemory+$8
		LDA $00
		AND #$FF00
		XBA
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !SpinyMemory+$A
		STA !SpinyMemory+$A
		SEP #$20

		JSR Zap_TargetPlayer
		SEP #$20
	.Zap	JMP Zap_MAIN

		.GetAttack
		LDA !RNG
		AND #$10
		SEC : SBC #$08
		STA !Flash
		RTS


	LightningStormVolley:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main

		.Init
		LDA #$80 : TSB !Phase
		LDA !RNG				;\ Random side of the screen
		AND #$01 : STA $3320,x			;/
		REP #$20
		BNE .L
	.R	LDA #$0010 : BRA +
	.L	LDA #$00D0
	+	STA !DesiredXLo
		LDA #$0120 : STA !DesiredYLo
		SEP #$20
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !Move

		.Main
		JSR Idle_GFX
		JSR Move
		BEQ .Attack
		LDA #$FF : STA !DanceTimer
		RTS

		.Attack
		LDA !DanceTimer : BNE .Go
		LDA #$04 : STA !Storm
		LDA #$20 : STA !MergeTimer
		JMP NewMove
	.Go	LDA #$0C : STA !SpriteAnimIndex
		LDA #$90 : STA !SpriteAnimTimer


		LDA #$09 : STA !Flash
		LDA $14
		AND #$08
		BEQ +
		LDA #$F7 : STA !Flash
		+

		LDA #$03 : STA !Storm

		TDC
		LDY $24
		CPY #$90
		BNE $02 : LDA #$10
		LDY !Enrage
		BEQ $02 : LDA #$28
		STA $00
		BIT $3220,x : BPL .PushRight

		.PushLeft
		LDA #$F0
		EOR $00
		STA $00
		LDA #$02 : STA !StormSpeed
		XBA					; Acceleration for vector
		STZ !StormSpeed+1
		LDA !P2VectorX-$80
		DEC #3
		CMP $00
		BCS $02 : LDA $00
		BRA .Push

		.PushRight
		LDA #$0F
		EOR $00
		STA $00
		LDA #$FE : STA !StormSpeed
		XBA					; Acceleration for vector
		LDA #$FF : STA !StormSpeed+1
		LDA !P2VectorX-$80
		INC #3
		CMP $00
		BCC $02 : LDA $00

		.Push
		STA !P2VectorX-$80
		STA !P2VectorX
		XBA
		STA !P2VectorAccX-$80
		STA !P2VectorAccX
		LDA #$10
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX


		LDA !Enrage : BNE +		;\
		LDA $24				; | Unless enraged, boss will wait until clouds have risen to shoot orbs
		CMP #$90 : BNE .Return		;/
	+	LDA $14
		AND #$0F : BNE .Return
		LDA #$03
		JSL QUICK_CAST_Long
		LDA #$08			;\ Graphic tile
		STA $33D0,y			;/
		LDA #$01 : STA $35D0,y		; > Spin type
		LDA #$01 : STA $3410,y		; > Hard prop
		LDA #$29 : STA $33C0,y		; > YXPPCCCT
		LDA #$06 : STA !SPC4		; > Fire sound


		.Return
		RTS






	CrimsonThunder:
		LDX !SpriteIndex
		LDA !Lightning : BEQ $03 : JSR Zap_MAIN		; Only run lightning code if a bolt is on screen
		BIT !Phase : BPL .Init
		JMP .Main

		.Init
		LDA #$80 : TSB !Phase				; Mark as initialized
		REP #$20					;\
		LDA #$0100 : STA !SpinyMemory+$8		; |
		LDA #$0302 : STA !SpinyMemory+$A		; | Initialize spiny memory
		LDA #$0504 : STA !SpinyMemory+$C		; |
		LDA #$0706 : STA !SpinyMemory+$E		; |
		SEP #$20					;/

		LDA !Difficulty
		AND #$03
		TAY
		LDA .MoveBase,y
		STA !Move
		JSR Random					;/
		RTS

		.GFX
		INC !SpriteAnimTimer
		LDA !SpriteAnimTimer
		AND #$07 : BNE +
		LDA !Phase
		AND #$7F
		CMP #$06 : BCS +++				; This animation during phases 06-08
		LDA !Lightning : BEQ ++

	+++	LDA !SpriteAnimIndex
		INC A
		CMP #$0F
		BCC $02 : LDA #$0B
		BRA +++

	++	LDA !SpriteAnimIndex
		INC A
		CMP #$0A
		BCC $01 : TDC
	+++	STA !SpriteAnimIndex
		+

		STZ $03
		STZ $06

		LDY !SpriteAnimIndex
		LDA Anim_UnitedProp,y : PHA
		LDA Anim_UnitedPropCloud,y : STA $02
		LDA Anim_United,y
		ASL A
		CLC : ADC Anim_United,y
		ASL A
		TAY
		REP #$20
		STZ $00
		STZ !BigRAM
		LDA Anim_SingleData+0,y : JSR TilemapToRAM
		LDA #$E400 : STA $00
		LDA Anim_SingleData+2,y
		PLY : STY $02
		JSR TilemapToRAM
		SEP #$20
		RTS


		.Main
		PHX
		LDA !Move
		AND #$7F
		CMP #$07
		BCC $02 : LDA #$07
		TAY
	-	LDX !SpinyMemory+0,y
		LDA $3300,x : BMI +
		INC $3300,x
	+	DEY : BPL -
		PLX

		JSR .GFX
		JSR Move					;\ Handle movement
		BNE .Return					;/
		LDA !Lightning : BNE .Return
		LDA !Move					;\
		AND #$7F					; | Handle new movement
		INC A						; |
		CMP #$09 : BNE .KeepMoving			;/
		LDA !Difficulty
		AND #$03
		TAY
		LDA .MoveBase,y : STA !Lightning
		LDA #$0B : STA !SpriteAnimIndex
		BRA Zap_INIT

		.KeepMoving
		STA !Move
		JSR .Spiny

		LDA !Move
		AND #$7F
		CMP #$08 : BNE +
		REP #$20					;\
		LDA #$0078 : STA !DesiredXLo			; | Final position
		LDA #$00E0 : STA !DesiredYLo			; |
		SEP #$20					;/
		RTS

	+	JSR Random					; Select a random destination

		.Return
		RTS


		.Spiny
		JSL !GetSpriteSlot
		BMI .Return
		JSL SPRITE_A_SPRITE_B_COORDS_Long		; Same position
		LDA #$15 : STA !NewSpriteNum,y			;\
		LDA #$14 : STA $3200,y				; | Sprite numbers and status
		LDA #$01 : STA $3230,y				;/
		PHX						; push main sprite index
		PHY						; push secondary sprite index
		TYX						;\
		JSL $07F7D2					; | Clear tables
		JSL $0187A7					;/
		LDA #$0C : STA !ExtraBits,x			; Custom sprite, extra bit
		INC $32A0,x					; Don't do charge effects
		LDA #$10 : STA !SPC1				; > VROOM sound
		LDX !Move					;\
		DEX						; | store index of spawned sprite in !SpinyMemory
		PLA : STA !SpinyMemory+0,x			;/
		PLX						; pull main sprite index
		RTS

		.MoveBase
		db $04,$02,$00



		Zap:
	; Indexes of spinies are stored in !SpinyMemory+0 in the order they spawned
	; !SpinyMemory+8 only holds the remaining indexes, so should be useless at this point

	; This should set a flag that causes lightning to be processed
	;  while that flag is set, the boss does not move and this routine is called every frame
	;  once the lightning is gone, the boss is free to move again
	; Remember, the spinies should be destroyed on impact unless the boss is enraged
	;  if they are not destroyed, they should drop to the ground and roll


		.INIT
		JSR .Spawn						; > Spawn lightning bolt
		LDA !Lightning						;\
		AND #$07						; |
		TAY							; |
		LDA !SpinyMemory+0,y					; |
		TAY							; | Dest coords
		LDA $3220,y : STA !SpinyMemory+$C			; |
		LDA $3250,y : STA !SpinyMemory+$D			; |
		LDA $3210,y : STA !SpinyMemory+$E			; |
		LDA $3240,y : STA !SpinyMemory+$F			;/
		INC !Lightning						; > Increment register
		RTS

		.Spawn
		LDA $3220,x : STA !SpinyMemory+$8			;\
		LDA $3250,x : STA !SpinyMemory+$9			; | Source coords
		LDA $3210,x : STA !SpinyMemory+$A			; |
		LDA $3240,x : STA !SpinyMemory+$B			;/
		LDA #$18 : STA !SPC4

	INC !PalFlash


		RTS

		.TargetPlayer
		LDA !MultiPlayer : BEQ +
		LDA !RNG
		AND #$80
	+	TAY
		REP #$20
		LDA !Difficulty
		AND #$0003
		CMP #$0002 : BEQ ..AimX
		LDA !P2XPosLo-$80,y
		BRA ..X

	..AimX	LDA !P2XSpeed-$80,y					;\
		AND #$00FF						; |
		ASL A							; |
		PHX							; |
		LDX !Phase						; |
		CPX #$81 : BEQ ..VX2					; |
		ASL A							; | Account for speed on INSANE
		CMP #$0200						; |
		BRA ..VX4						; |
	..VX2	CMP #$0100						; |
	..VX4	PLX							; |
		BCC $03 : ORA #$FF00					; |
		CLC : ADC !P2XPosLo-$80,y : BMI ..X2			;/
	..X	CMP #$0020 : BCC ..X2					;\
		CMP #$00D0 : BCC ..XW					; |
	..XD	LDA #$00D0 : BRA ..XW					; | Target closest ground
	..X2	LDA #$0020						; |
	..XW	STA !SpinyMemory+$C					; |
		LDA #$0158 : STA !SpinyMemory+$E			;/
	.Return	RTS


		.MAIN
		BIT !Lightning : BPL .Extend
		LDA !LightningTimer : BEQ .Bounce
		DEC !LightningTimer
		JMP .Nope

		.Bounce
		LDA #$18 : STA !SPC4
		LDA !Lightning					;\
		AND #$7F					; |
		INC A						; |
		CMP #$0A : BNE +				; | End this attack
		STZ !Lightning					; |
		STZ !LightningTimer				; |
		LDA !Phase
		AND #$7F
		CMP #$01 : BEQ .Return
		PLA : PLA
		JMP NewMove					;/

	+	STA !Lightning

		.Extend
		INC !LightningTimer

		.Go
		REP #$20
		LDA !SpinyMemory+$8
		SEC : SBC !SpinyMemory+$C
		STA $00
		LDA !SpinyMemory+$A
		SEC : SBC !SpinyMemory+$E
		STA $02

		SEP #$20
		LDA #$3F
		JSL AIM_SHOT_Long


	-	LDA $04						;\
		ASL #4						; |
		CLC : ADC !LightningFracX			; |
		STA !LightningFracX				; |
		PHP						; |
		LDY #$00					; |
		LDA $04						; |
		LSR #4						; | Lightning X position
		CMP #$08 : BCC +				; |
		ORA #$F0					; |
		DEY						; |
	+	PLP						; |
		ADC !SpinyMemory+$8 : STA !SpinyMemory+$8	; |
		TYA						; |
		ADC !SpinyMemory+$9 : STA !SpinyMemory+$9	;/
		LDA $06						;\
		ASL #4						; |
		CLC : ADC !LightningFracY			; |
		STA !LightningFracY				; |
		PHP						; |
		LDY #$00					; |
		LDA $06						; |
		LSR #4						; | Lightning Y position
		CMP #$08 : BCC +				; |
		ORA #$F0					; |
		DEY						; |
	+	PLP						; |
		ADC !SpinyMemory+$A : STA !SpinyMemory+$A	; |
		TYA						; |
		ADC !SpinyMemory+$B : STA !SpinyMemory+$B	;/


		REP #$20
		LDY #$00
	-	LDA !SpinyMemory+$8,y
		SEC : SBC !SpinyMemory+$C,y
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0004 : BCC $03 : JMP .Nope
		CPY #$02 : BEQ .YesNext
		INY #2
		BRA -

		.YesNext
		LDA !SpinyMemory+$C : STA !SpinyMemory+$8
		LDA !SpinyMemory+$E : STA !SpinyMemory+$A
		SEP #$20
		LDY !Lightning
		CPY #$09 : BEQ .NoDestroy
		CPY #$08 : BNE +
		JSR .TargetPlayer
		SEP #$20
		BRA .RageCheck

	+	LDA !SpinyMemory+0,y
		TAY
		LDA $3220,y : STA !SpinyMemory+$C
		LDA $3250,y : STA !SpinyMemory+$D
		LDA $3210,y : STA !SpinyMemory+$E
		LDA $3240,y : STA !SpinyMemory+$F

		.RageCheck
		LDA !Enrage : BNE .NoDestroy			;\
		LDY !Lightning					; |
		DEY						; |
		LDA !SpinyMemory+0,y				; | Destroy spiny unless enraged
		TAY						; |
		LDA #$04 : STA $3230,y				; |
		LDA #$0F : STA $32D0,y				; |
		.NoDestroy					;/

		LDA !Lightning
		ORA #$80
		STA !Lightning
		LDA !LightningTimer : BEQ +
		CMP #$0F : BCC .Nope
	+	LDA #$0F
		STA !LightningTimer
		.Nope


; Tip of lightning should be a ball while timer is negative (waiting for tail)
; otherwise it should be the same as the tail
;

		REP #$20
		LDY #$01 : STY $2250
		LDY #$04

		LDA $06
		AND #$00FF
		CMP #$0080
		BCC +
		EOR #$FFFF : INC A
		AND #$00FF
	+	STA $2251
		LDA $04
		CMP #$0080
		AND #$00FF
		BCC .Calc
		EOR #$FFFF : INC A
		AND #$00FF

		.Calc
		BEQ .Node4			; Edge case: Don't divide by 0
		STA $2253			; Divide |Y speed| / |X speed|
		PHA
		BRA $00
		LDA $2306
		AND #$00FF
		XBA
		STA $0E
		LDA $2308
		XBA
		AND #$FF00
		STA $2251
		PLA : STA $2253
		BRA $00
		LSR A
		CMP $2308
		LDA $2306
		BCS $01 : INC A
		AND #$00FF
		ORA $0E

		CMP #$0507 : BCS .Node4
		CMP #$017F : BCS .Node3
		CMP #$00AB : BCS .Node2
		CMP #$008F : BCS .Node1
	.Node0	DEY				; dominant X
	.Node1	DEY				; somewhat dominant X
	.Node2	DEY				; equivalent X/Y
	.Node3	DEY				; somewhat dominant Y
	.Node4					; dominant Y

		SEP #$20

		LDA !Lightning : BPL +
		LDA #$08 : BRA ++
	+	LDA .Tile,y
	++	STA $0A
		LDA #$29 : STA $0B
		LDA $04
		AND #$80
		EOR #$80
		LSR A
		TSB $0B
		LDA $06
		AND #$80
		TSB $0B


		.FinishCalc
		LDA !LightningTimer
		CMP #$0F
		BCC $02 : LDA #$0F
		LSR A
		STA $08				; number of tail tiles

		REP #$20
		PHX

		LDA !SpinyMemory+$8
		SEC : SBC $1A
		STA $00
		CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCC .OutOfBounds
	.GoodX	LDA !SpinyMemory+$A
		SEC : SBC $1C
		STA $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .OutOfBounds
	.GoodY	SEP #$20
		LDY !OAMindex
		LDA $00 : STA !OAM+$000,y
		LDA $02 : STA !OAM+$001,y
		LDA $0A : STA !OAM+$002,y
		LDA $0B : STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		LDA $01
		AND #$01
		ORA #$02
		STA !OAMhi,y
		INY
		TYA
		ASL #2
		TAY

		.OutOfBounds
		STY !OAMindex					;\
		LDA !LightningTimer				; |
		LSR A : BCS +					; |
		LDA #$06					; |
		LDY #$01					; |
		JSL SpawnExSprite_NoSpeed_Long			; |
		LDA !LightningTimer				; |
		AND #$0F					; |
		LSR A						; |
		TAX						; |
		LDA $0A						; |
		PHA						; |
		AND #$0E					; |
		LSR A						; | Spawn Malleable ExSprites to act as tail
		STA $0A						; |
		PLA						; |
		AND #$E0					; |
		LSR #2						; |
		ORA $0A						; |
		ORA #$80					; |
		STA !ExSpriteMisc,y				; |
		LDA $0B : STA !ExSpriteBehindBG1,y		; |
		LDA #$08 : STA !ExSpriteTimer,y			; |
		LDA !SpinyMemory+$8 : STA !ExSpriteXPosLo,y	; |
		LDA !SpinyMemory+$9 : STA !ExSpriteXPosHi,y	; |
		LDA !SpinyMemory+$A : STA !ExSpriteYPosLo,y	; |
		LDA !SpinyMemory+$B : STA !ExSpriteYPosHi,y	;/

	+	PLX

; SEE IF TAIL IS PROPERLY FLIPPED!! (180 degrees)
		LDA $14
		LSR A : BCS +
		LDY #$09
	-	LDA !ExSpriteNum,y
		CMP #$09 : BEQ ++
	--	DEY : BPL -
		BRA +
	++	LDA !ExSpriteTimer,y
		CMP #$02 : BNE --
		LDA !ExSpriteBehindBG1,y
		EOR #$C0
		STA !ExSpriteBehindBG1,y
		+
		RTS


		.Tile
		db $20,$22,$24,$26,$28



		Random:
		LDA #$01 : STA $2250				; Enable division
		TDC : XBA					; Wipe B
		LDA !RNG
		REP #$20
		STA $2251
		LDA !Move
		AND #$007F
		SEC : SBC #$0008
		BNE +
		LDY #$00					; If there's only one slot, there's no need to use RNG
		BRA ++

	+	EOR #$FFFF
		INC A
		STA $2253
		STA $00
		SEP #$20
		LDY $2308
	++	LDA !SpinyMemory+8,y
		ASL A
		PHA
		LDA #$00 : STA !SpinyMemory+$10
	-	INY						;\
		CPY $00 : BEQ +					; | Collapse data to overwrite the chosen slot
		LDA !SpinyMemory+8,y : STA !SpinyMemory+7,y	; |
		BRA -						;/

	+	PLY						;\
		LDA .Coords+0,y : STA !DesiredXLo		; |
		LDA .Coords+1,y : STA !DesiredYLo		; | Set destination
		STZ !DesiredXHi					; |
		LDA #$01 : STA !DesiredYHi			;/
		RTS



; Have used up slots stored in upper half of !SpinyMemory
; When a new slot is used up, delete it and move all greater slots down one step





	.Coords		; X and Y coords for possible spiny spawns
	db $48,$00
	db $A8,$00
	db $28,$20
	db $C8,$20
	db $58,$48
	db $98,$48
	db $08,$58
	db $E8,$58




	DivineStorm:
		LDX !SpriteIndex
		LDA #$02 : STA !StormSpeed
		STZ !StormSpeed+1
		BIT !Phase : BMI .Main

		.Init
		LDA #$80 : TSB !Phase
		REP #$20					;\
		LDA #$0078 : STA !DesiredXLo			; | Desired coord
		LDA #$00D0 : STA !DesiredYLo			; |
		SEP #$20					;/
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		STZ !Move					; Enable movement

		.Main
		JSR Move
		BEQ .Attack

		LDA #$FE : STA !DanceTimer
		JMP Idle_GFX

		.Attack
		LDA $14
		AND #$03
		BEQ .Smoke
		INC !DanceTimer
		BRA .NoSmoke

		.Smoke
		LDA !RNG
		AND #$FF
		SEC : SBC $3220,x
		STA $00
		LDA #$00
		SBC $3250,x
		STA $01
		REP #$20
		LDA #$00C8 : STA $02
		LDA #$8000 : STA $04
		SEP #$20
		LDY #$01
		LDA #$00
		JSL SpawnExSprite_Long
		.NoSmoke

		LDY #$09
	-	LDA !ExSpriteNum,y
		CMP #$01 : BNE +
		LDA !ExSpriteYPosLo,y
		SEC : SBC #$0C
		STA !ExSpriteYPosLo,y
	+	DEY : BPL -


		LDA !DanceTimer : BNE .Go
		LDA #$02 : STA !Storm
		LDA #$20 : STA !MergeTimer
		JMP NewMove
	.Go	JSR BigSpin

		LDA #$01 : STA !Storm

	.Spiny	LDA !DanceTimer
		CMP #$20 : BCC .Return
		LDA $14
		AND #$1F : BNE .Return
		JSR CrimsonThunder_Spiny
		BMI .Return
		TAY
		LDA !RNG
		CMP #$F0 : BCC +
		ASL #4
	+	CMP #$20 : BCS +
		LDA #$20
	+	CMP #$D0 : BCC +
		LDA #$D0
	+	STA $3220,y
		LDA #$80 : STA $3210,y
		LDA #$00 : STA $3240,y
		LDA #$08 : STA $3230,y

		.Return
		RTS



	DanceChallenge:
		LDX !SpriteIndex
		BIT !Phase : BMI .Main


		.Init
		LDA #$80 : TSB !Phase				; Mark as initialized
		REP #$20					;\
		LDA #$0078 : STA !DesiredXLo			; | Go to 0x0080;0x00A0
		LDA #$00A0 : STA !DesiredYLo			; |
		SEP #$20					;/
		STZ !Move					; Enable movement
		TDC : STA !VineDestroy+$11			; Clear number of misses

		.Main
		JSR CrimsonThunder_GFX
		JSR Move
		BEQ .Dance
		RTS

		.Dance
		LDA !VineDestroy+$00 : BNE .Dancing		; Don't wait if it's already begun
		STZ $00						;\
		LDY #$0F					; |
	-	LDA $3230,y					; |
		BEQ $02 : INC $00				; | Wait until there are at most 2 sprites on-screen
		DEY : BPL -					; |
		LDA $00						; |
		CMP #$03 : BCS .Return				;/
		LDA !P2Status-$80				;\
		BEQ $02 : ORA #$04				; |
		ORA !P2Blocked-$80				; |
		STA $00						; |
		LDA !MultiPlayer : BEQ +			; |
		LDA !P2Status					; | Wait until all players are on the ground
		BEQ $02 : ORA #$04				; |
		ORA !P2Blocked					; | (dead players count as touching the ground)
		AND $00						; |
		STA $00						; |
	+	LDA $00						; |
		AND #$04					; |
		BEQ .Return					;/
		LDA #$01 : STA !VineDestroy+$00			; Enable dance


		.Dancing
		LDA !DanceTimer : BNE .Return

	.Spawn	LDA !Difficulty
		AND #$03
		TAY
		LDA DANCEPAD_SpawnSpeed,y
		STA !DanceTimer
		LDA !Move
		AND #$7F
		CMP #$08 : BCS .Wait
		ASL A
		PHX
		TAX
		LDA !RNG
		AND #$03
		TAY
		LDA.w DANCEPAD_InputTable,y
		STA.l !VineDestroy+$01,x
		LDA #$00 : STA !VineDestroy+$02,x
		PLX
		INC !Move

		.Return
		RTS


		.Wait
		TXY
		LDX #$0C
		LDA.l !VineDestroy+$03,x
	-	ORA.l !VineDestroy+$01,x
		DEX #2 : BPL -
		TYX
		CMP #$01 : BCS .Return

		STZ !Enrage
		LDA.l !VineDestroy+$11				;\
		BNE $03 : INC !Impressiveness			; |
		CMP #$02					; | 0 misses: +1 impressiveness
		BCC +						; |
		LDA #$02 : STA !Enrage				; | 1 miss: nothing
		STZ !Impressiveness				; |
	+	CLC : ADC #$04					; | 2+ misses: enrage!
		BIT !RNG					; |
		BPL $02 : EOR #$0C				; > Each message has 2 variations
		STA !MsgTrigger					;/

		TDC						;\
		STA.l !VineDestroy+$00				; | End dance mode
		STA.l !VineDestroy+$11				;/

		LDA !Difficulty
		AND #$03
		CLC : ADC #$03
		CMP !Impressiveness
		BNE .NotImpressed
		LDA #$07 : STA !Phase
		STZ !MsgTrigger
		RTS



		.NotImpressed
		JMP NewMove



	BigSpin:					; Get X offset for big spin movement


		INC !SpriteAnimTimer
		INC !SpriteAnimTimer

		TDC : XBA
		LDA !SpriteAnimTimer
		REP #$30
		ASL #2
		TAY
		AND #$01FF
		TAX
		LDA.l !TrigTable,x			;\
		LSR #2					; | sine value
		STA $00					;/
		TXA
		CLC : ADC #$0100
		AND #$01FF
		TAX
		LDA.l !TrigTable,x			;\
		LSR #4					; | cosine value
		STA $01					;/

		JMP Idle_GFX2




	Move:
		BIT !Move : BMI .Main

		.Init
		LDA #$80 : TSB !Move				; Mark as initiated
		LDA $3240,x : STA $03				;\
		LDA $3210,x : STA $02				; | 16-bit X and Y
		LDA $3250,x : XBA				; |
		LDA $3220,x					;/
		REP #$20					;\
		SEC : SBC !DesiredXLo				; |
		STA $00						; |
		LDA $02						; |
		SEC : SBC !DesiredYLo				; | Calculate speeds
		STA $02						; |
		SEP #$20					; |
		LDA !Phase					; |
		AND #$7F : BEQ +++				; |
		CMP #$03 : BNE +				; |
	+++	LDA #$10 : BRA ++				; | > Move slower during idle and Crimson Thunder
	+	LDA #$28					; |
	++	JSL AIM_SHOT_Long				;/
		LDA $04 : STA $AE,x				;\ Set speed
		LDA $06 : STA $9E,x				;/

		.Main
		LDA !MsgTrigger : BEQ +				;\ Only move during message 03
		CMP #$03 : BNE .Return				;/
	+	JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08
	.X	LDA $3220,x
		CMP !DesiredXLo
		LDA $3250,x
		SBC !DesiredXHi
		PHP
		BIT $AE,x : BMI .L
	.R	PLP : BCC .Y
		BRA .0X
	.L	PLP : BCS .Y
	.0X	STZ $AE,x
	.Y	LDA $3210,x
		CMP !DesiredYLo
		LDA $3240,x
		SBC !DesiredYHi
		PHP
		BIT $9E,x : BMI .U
	.D	PLP : BCC .Return
		BRA .0Y
	.U	PLP : BCS .Return
	.0Y	STZ $9E,x
	.Return	LDA $9E,x
		ORA $AE,x
		RTS

; If z = true, then boss has arrived at its destination


; Load $00-$01 with X/Y offset
; Load $02 with property "OR" bits
; Load $03 with tile offset
; Load 16-bit A with location of tilemap to add
; The tilemap will be transcribed and added to !BigRAM
;
; Make sure to clear $06 before the first upload!

	TilemapToRAM:
		PHY
		PHX
		PHP
		LDX $06 : BNE .NotInit
		STZ !BigRAM+0
		.NotInit
		STA $04
		LDY #$00
		LDA ($04)
		STA $08
		CLC : ADC !BigRAM+0
		STA !BigRAM+0
		INC $04
		INC $04
		SEP #$20
	-	LDA ($04),y			;\
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
		STA !BigRAM+5,x			; | Tile
		CLC : ADC $03			; |
		INY				;/
		INX #4
		CPY $08 : BNE -
		STX $06

		PLP
		PLX
		PLY
		RTS

	.Long	JSR TilemapToRAM
		RTL





; Anim is uploaded to !BigRAM and modified during phase processing



	Anim:

	.Separated
		db $00			; 00
		db $01			; 01
		db $02			; 02
		db $03			; 03
		db $03			; 04
		db $02			; 05
		db $01			; 06
		db $00			; 07

		db $04			; 08
		db $05			; 09
		db $06			; 0A
		db $07			; 0B
		db $07			; 0C
		db $06			; 0D
		db $05			; 0E
		db $04			; 0F



	.DoubleData

	; Wheel movement
		dw .BodyTM24x32M	; 00
		dw .WheelTilemap0
		dw .BodyTM24x32F
		dw .WheelTilemap3
		dw .WheelDynamo0

		dw .BodyTM24x32M	; 01
		dw .WheelTilemap1
		dw .BodyTM24x32F
		dw .WheelTilemap2
		dw .WheelDynamo1

		dw .BodyTM24x32M	; 02
		dw .WheelTilemap2
		dw .BodyTM24x32F
		dw .WheelTilemap1
		dw .WheelDynamo2

		dw .BodyTM24x32M	; 03
		dw .WheelTilemap3
		dw .BodyTM24x32F
		dw .WheelTilemap0
		dw .WheelDynamo3


	; Wheel movement, arms up
		dw .BodyTM24x32M	; 04
		dw .WheelTilemap0
		dw .BodyTM24x32F
		dw .WheelTilemap3
		dw .WheelDynamoAlt0

		dw .BodyTM24x32M	; 05
		dw .WheelTilemap1
		dw .BodyTM24x32F
		dw .WheelTilemap2
		dw .WheelDynamoAlt1

		dw .BodyTM24x32M	; 06
		dw .WheelTilemap2
		dw .BodyTM24x32F
		dw .WheelTilemap1
		dw .WheelDynamoAlt2

		dw .BodyTM24x32M	; 07
		dw .WheelTilemap3
		dw .BodyTM24x32F
		dw .WheelTilemap0
		dw .WheelDynamoAlt3



	.United
		db $00			; 00
		db $01			; 01
		db $02			; 02
		db $02			; 03
		db $01			; 04
		db $00			; 05
		db $03			; 06
		db $04			; 07
		db $04			; 08
		db $03			; 09

		db $05			; 0A

		db $06			; 0B
		db $07			; 0C
		db $08			; 0D
		db $09			; 0E

	.UnitedProp
		db $00			; 00
		db $00			; 01
		db $00			; 02
		db $40			; 03
		db $40			; 04
		db $40			; 05
		db $00			; 06
		db $00			; 07
		db $40			; 08
		db $40			; 09
		db $00			; 0A
		db $00			; 0B
		db $00			; 0C
		db $00			; 0D
		db $00			; 0E


	.UnitedPropCloud
		db $00			; 00
		db $00			; 01
		db $00			; 02
		db $40			; 03
		db $40			; 04
		db $40			; 05
		db $40			; 06
		db $40			; 07
		db $00			; 08
		db $00			; 09
		db $00			; 0A
		db $00			; 0B
		db $00			; 0C
		db $00			; 0D
		db $40			; 0E



	.SingleData

	; Spinning animation

		dw .BigCloudTM0		; 00
		dw .BodyTM40x32
		dw .SpinDynamo0

		dw .BigCloudTM1		; 01
		dw .BodyTM40x32
		dw .SpinDynamo1

		dw .BigCloudTM2		; 02
		dw .BodyTM24x32
		dw .SpinDynamo2

		dw .BigCloudTM1		; 03
		dw .BodyTM40x32
		dw .SpinDynamo3

		dw .BigCloudTM2		; 04
		dw .BodyTM24x32
		dw .SpinDynamo4


	; Split animation

		dw .BigCloudTM3		; 05
		dw .BodyTM48x32
		dw .SplitDynamo


	; Idle animation

		dw .BigCloudTM2		; 06
		dw .BodyTM40x32
		dw .IdleDynamo

		dw .BigCloudTM1		; 07
		dw .BodyTM40x32
		dw .IdleDynamo

		dw .BigCloudTM2		; 08
		dw .BodyTM40x32
		dw .IdleDynamo

		dw .BigCloudTM1		; 09
		dw .BodyTM40x32
		dw .IdleDynamo






		.BodyTM24x32M
		dw $0010
		db $29,$FC,$F0,$A0
		db $29,$04,$F0,$A1
		db $29,$FC,$00,$C0
		db $29,$04,$00,$C1

		.BodyTM24x32F
		dw $0010
		db $29,$FC,$F0,$A3
		db $29,$04,$F0,$A4
		db $29,$FC,$00,$C3
		db $29,$04,$00,$C4



		.WheelTilemap0
		dw $0014
		db $29,$F4,$00,$50
		db $29,$F4,$08,$60
		db $29,$04,$08,$51
		db $29,$0C,$08,$62
		db $29,$0C,$00,$52

		.WheelTilemap1
		dw $0014
		db $29,$F4,$00,$54
		db $29,$F4,$08,$64
		db $29,$04,$08,$66
		db $29,$0C,$08,$67
		db $29,$0C,$00,$55

		.WheelTilemap2
		dw $0010
		db $29,$F4,$00,$59
		db $29,$F4,$08,$69
		db $29,$04,$08,$6B
		db $29,$0C,$00,$5A	; this one doesn't need the ($08;$08)-tile

		.WheelTilemap3
		dw $0014
		db $29,$F4,$00,$5D
		db $29,$F4,$08,$6D
		db $29,$FC,$08,$6E
		db $29,$0C,$08,$57
		db $29,$0C,$00,$5E




		.LightningBallBig
		dw $0004
		db $29,$00,$00,$08


		.LightningBallSmall
		dw $0004
		db $29,$00,$00,$0A


		.BigCloudTM0
		dw $0020
		db $28,$EC,$00,$80
		db $28,$FC,$00,$82
		db $28,$0C,$00,$84
		db $28,$14,$00,$85
		db $28,$EC,$10,$CE
		db $28,$FC,$10,$A2
		db $28,$0C,$10,$A4
		db $28,$14,$10,$A5

		.BigCloudTM1
		dw $0020
		db $28,$EC,$00,$87
		db $28,$FC,$00,$89
		db $28,$04,$00,$8A
		db $28,$14,$00,$AE
		db $28,$EC,$10,$A7
		db $28,$FC,$10,$A9
		db $28,$0C,$10,$AB
		db $28,$14,$10,$AC

		.BigCloudTM2
		dw $0020
		db $28,$EC,$00,$C0
		db $28,$FC,$00,$C2
		db $28,$0C,$00,$C4
		db $28,$14,$00,$C5
		db $28,$EC,$10,$E0
		db $28,$FC,$10,$E2
		db $28,$0C,$10,$E4
		db $28,$14,$10,$E5

		.BigCloudTM3
		dw $0020
		db $28,$EC,$00,$C7
		db $28,$FC,$00,$C9
		db $28,$0C,$00,$CB
		db $28,$14,$00,$CC
		db $28,$EC,$10,$E7
		db $28,$FC,$10,$E9
		db $28,$0C,$10,$EB
		db $28,$14,$10,$EC


		.BodyTM40x32
		dw $0018
		db $29,$F4,$00,$A0
		db $29,$04,$00,$A2
		db $29,$0C,$00,$A3
		db $29,$F4,$10,$C0
		db $29,$04,$10,$C2
		db $29,$0C,$10,$C3

		.BodyTM24x32
		dw $0010
		db $29,$FC,$00,$A0
		db $29,$04,$00,$A1
		db $29,$FC,$10,$C0
		db $29,$04,$10,$C1

		.BodyTM48x32
		dw $0018
		db $29,$F0,$00,$A0
		db $29,$00,$00,$A2
		db $29,$10,$00,$A4
		db $29,$F0,$10,$C0
		db $29,$00,$10,$C2
		db $29,$10,$10,$C4


	; Wheel tilemap, arms down
	.WheelDynamo0
	dw ..End-..Start
	..Start
	%LakituDyn(3, $000, $1A0)		;\
	%LakituDyn(3, $010, $1B0)		; | Gent facing screen
	%LakituDyn(3, $020, $1C0)		; |
	%LakituDyn(3, $030, $1D0)		;/
	%LakituDyn(3, $079, $1A3)		;\
	%LakituDyn(3, $089, $1B3)		; | Lady facing back
	%LakituDyn(3, $099, $1C3)		; |
	%LakituDyn(3, $0A9, $1D3)		;/
	..End

	.WheelDynamo1
	dw ..End-..Start
	..Start
	%LakituDyn(3, $003, $1A0)		;\
	%LakituDyn(3, $013, $1B0)		; | Gent facing front corner
	%LakituDyn(3, $023, $1C0)		; |
	%LakituDyn(3, $033, $1D0)		;/
	%LakituDyn(3, $076, $1A3)		;\
	%LakituDyn(3, $086, $1B3)		; | Lady facing back corner
	%LakituDyn(3, $096, $1C3)		; |
	%LakituDyn(3, $0A6, $1D3)		;/
	..End

	.WheelDynamo2
	dw ..End-..Start
	..Start
	%LakituDyn(3, $006, $1A0)		;\
	%LakituDyn(3, $016, $1B0)		; | Gent facing back corner
	%LakituDyn(3, $026, $1C0)		; |
	%LakituDyn(3, $036, $1D0)		;/
	%LakituDyn(3, $073, $1A3)		;\
	%LakituDyn(3, $083, $1B3)		; | Lady facing front corner
	%LakituDyn(3, $093, $1C3)		; |
	%LakituDyn(3, $0A3, $1D3)		;/
	..End

	.WheelDynamo3
	dw ..End-..Start
	..Start
	%LakituDyn(3, $009, $1A0)		;\
	%LakituDyn(3, $019, $1B0)		; | Gent facing back
	%LakituDyn(3, $029, $1C0)		; |
	%LakituDyn(3, $039, $1D0)		;/
	%LakituDyn(3, $070, $1A3)		;\
	%LakituDyn(3, $080, $1B3)		; | Lady facing screen
	%LakituDyn(3, $090, $1C3)		; |
	%LakituDyn(3, $0A0, $1D3)		;/
	..End


	; Alternate wheel version with arms raised, same tilemap
	.WheelDynamoAlt0
	dw ..End-..Start
	..Start
	%LakituDyn(3, $000, $1A0)		;\
	%LakituDyn(3, $040, $1B0)		; | Gent facing screen
	%LakituDyn(3, $050, $1C0)		; |
	%LakituDyn(3, $060, $1D0)		;/
	%LakituDyn(3, $079, $1A3)		;\
	%LakituDyn(3, $0B9, $1B3)		; | Lady facing back
	%LakituDyn(3, $0C9, $1C3)		; |
	%LakituDyn(3, $0D9, $1D3)		;/
	..End

	.WheelDynamoAlt1
	dw ..End-..Start
	..Start
	%LakituDyn(3, $003, $1A0)		;\
	%LakituDyn(3, $043, $1B0)		; | Gent facing front corner
	%LakituDyn(3, $053, $1C0)		; |
	%LakituDyn(3, $063, $1D0)		;/
	%LakituDyn(3, $076, $1A3)		;\
	%LakituDyn(3, $0B6, $1B3)		; | Lady facing back corner
	%LakituDyn(3, $0C6, $1C3)		; |
	%LakituDyn(3, $0D6, $1D3)		;/
	..End

	.WheelDynamoAlt2
	dw ..End-..Start
	..Start
	%LakituDyn(3, $006, $1A0)		;\
	%LakituDyn(3, $046, $1B0)		; | Gent facing back corner
	%LakituDyn(3, $056, $1C0)		; |
	%LakituDyn(3, $066, $1D0)		;/
	%LakituDyn(3, $073, $1A3)		;\
	%LakituDyn(3, $0B3, $1B3)		; | Lady facing front corner
	%LakituDyn(3, $0C3, $1C3)		; |
	%LakituDyn(3, $0D3, $1D3)		;/
	..End

	.WheelDynamoAlt3
	dw ..End-..Start
	..Start
	%LakituDyn(3, $009, $1A0)		;\
	%LakituDyn(3, $049, $1B0)		; | Gent facing back
	%LakituDyn(3, $059, $1C0)		; |
	%LakituDyn(3, $069, $1D0)		;/
	%LakituDyn(3, $070, $1A3)		;\
	%LakituDyn(3, $0B0, $1B3)		; | Lady facing screen
	%LakituDyn(3, $0C0, $1C3)		; |
	%LakituDyn(3, $0D0, $1D3)		;/
	..End


	.SpinDynamo0
	dw ..End-..Start
	..Start
	%LakituDyn(5, $0E0, $1A0)
	%LakituDyn(5, $0F0, $1B0)
	%LakituDyn(5, $100, $1C0)
	%LakituDyn(5, $110, $1D0)
	..End

	.SpinDynamo1
	dw ..End-..Start
	..Start
	%LakituDyn(5, $0E5, $1A0)
	%LakituDyn(5, $0F5, $1B0)
	%LakituDyn(5, $105, $1C0)
	%LakituDyn(5, $115, $1D0)
	..End

	.SpinDynamo2
	dw ..End-..Start
	..Start
	%LakituDyn(3, $0EA, $1A0)
	%LakituDyn(3, $0FA, $1B0)
	%LakituDyn(3, $10A, $1C0)
	%LakituDyn(3, $11A, $1D0)
	..End

	.SpinDynamo3
	dw ..End-..Start
	..Start
	%LakituDyn(5, $120, $1A0)
	%LakituDyn(5, $130, $1B0)
	%LakituDyn(5, $140, $1C0)
	%LakituDyn(5, $150, $1D0)
	..End

	.SpinDynamo4
	dw ..End-..Start
	..Start
	%LakituDyn(3, $0ED, $1A0)
	%LakituDyn(3, $0FD, $1B0)
	%LakituDyn(3, $10D, $1C0)
	%LakituDyn(3, $11D, $1D0)
	..End

	.SplitDynamo
	dw ..End-..Start
	..Start
	%LakituDyn(6, $125, $1A0)
	%LakituDyn(6, $135, $1B0)
	%LakituDyn(6, $145, $1C0)
	%LakituDyn(6, $155, $1D0)
	..End

	.IdleDynamo
	dw ..End-..Start
	..Start
	%LakituDyn(5, $12B, $1A0)
	%LakituDyn(5, $13B, $1B0)
	%LakituDyn(5, $14B, $1C0)
	%LakituDyn(5, $15B, $1D0)
	..End




; $BE,x		- activated flag
; $3280,x	- amount of symbols spawned
; $3290,x	- prize/punishment given flag
; $32A0,x	- number of floors destroyed (caps at 3)
; $32D0,x	- timer used for spawning symbols
; $3300,x	- timer used for repeatable modes
; $3420,x	- wait timer used for spawning


	DANCEPAD:

		LDA $BE,x : BEQ .Interact			; Can only be used once

		LDA $3420,x
		CMP #$01 : BNE .Done

		.Init
		LDA !Difficulty					;\
		AND #$03					; |
		TAY						; | Spawn more symbols
		LDA.w .SpawnSpeed,y : STA $3420,x		; |
		LDA $32D0,x : BEQ .Done				; |
		JMP .Spawn					;/

		.Done
		LDA $3300,x					;\
		CMP #$01					; |
		BNE +						; |
		JSR DANCE_RESULT_GenerateFloor			; | Reset sprite and respawn floor when timer runs out
		PHK : PEA.w .NoContact-1			; |
		JML $07F7D2					; |
		+						;/


		LDA $3290,x : BEQ $03
	--	JMP .NoContact					; Only give prize/punishment once
		TXY
		LDX #$0C
		LDA.l !VineDestroy+$03,x
	-	ORA.l !VineDestroy+$01,x
		DEX #2 : BPL -
		TYX
		CMP #$01 : BCS --
		INC $3290,x					; Set result
		JSR DANCE_RESULT				; Handle result
		TDC						; Load zero
		STA.l !VineDestroy+$00				; End dance game
		STA.l !VineDestroy+$11				; Clear number of misses
		JMP .NoContact

		.Interact
		LDA $3220,x : STA $04
		LDA $3210,x : STA $05
		LDA $3250,x : STA $0A
		LDA $3240,x : STA $0B
		LDA #$10
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .NoContact
		STZ $00						;\
		LSR A : BCC +					; |
		PHA						; |
		LDA !P2Blocked-$80				; |
		AND #$04					; |
		TSB $00						; | Player must be on ground
		PLA						; |
	+	LSR A : BCC +					; |
		LDA !P2Blocked					; |
		AND #$04					; |
		TSB $00						; |
	+	LDA $00 : BEQ .NoContact			;/


		INC $BE,x					; Dance pad activated
		LDA #$01 : STA.l !VineDestroy+$00		; Activate dance game
		LDA !Difficulty					;\
		AND #$03 : TAY					; | Spawn time depends on difficulty
		LDA.w .SpawnSpeed,y : STA $3420,x		; |
		LDA.w .SpawnTime,y : STA $32D0,x		;/
		INC A

		.Spawn
		PHX						;\
		LDA $3280,x					; | Get index
		ASL A						; |
		TAX						;/
		LDA !RNG					;\
		AND #$03					; |
		TAY						; |
		LDA.w .InputTable,y				; | Random input
		STA.l !VineDestroy+$01,x			; |
		LDA #$00 : STA !VineDestroy+$02,x		; |
		PLX						;/
		INC $3280,x					; Increment amount spawned

		.NoContact
		LDA $3230,x : BEQ .NoGFX
		LDA.b #.Tilemap : STA $04			; GFX
		LDA.b #.Tilemap>>8 : STA $05
		JSL LOAD_TILEMAP_Long

		.NoGFX
		PLB
		RTL


		.InputTable
		db $01,$02,$04,$08

		.SpawnTime
		db $DF,$A7,$6F

		.SpawnSpeed
		db $20,$18,$10


		.Tilemap
		dw $0004
		db $27,$00,$00,$04


	DANCE_RESULT:

		LDA !RAM_ScreenMode
		LSR A
		BCC .Horz

	.Vert	LDA $3240,x				;\
		ASL A					; |
		CLC : ADC $3250,x			; | +1 if hi X, otherwise just hi Y
		TAY					; |
		BRA .Go					;/

	.Horz	BIT $3220,x				;\
		PHP					; |
		LDA $3250,x				; |
		ASL A					; | +1 if right half of screen, otherwise just hi X
		TAY					; |
		PLP					; |
		BPL $01 : INY				;/


	.Go	LDA.w .ResultTable,y
		ASL A
		TAY
		LDA .ResultPtr+0,y : STA $00
		LDA .ResultPtr+1,y : STA $01
		LDA.l !VineDestroy+$11
		JMP ($3000)



		.ResultTable
		db $00,$02		; 00
		db $00,$00		; 01
		db $00,$00		; 02
		db $00,$02		; 03
		db $00,$00		; 04
		db $00,$00		; 05
		db $00,$00		; 06
		db $00,$00		; 07
		db $00,$00		; 08
		db $00,$03		; 09
		db $00,$00		; 0A
		db $00,$04		; 0B
		db $00,$00		; 0C
		db $00,$00		; 0D
		db $00,$00		; 0E
		db $00,$03		; 0F
		db $00,$00		; 10
		db $00,$00		; 11
		db $00,$00		; 12
		db $00,$02		; 13
		db $00,$00		; 14
		db $00,$00		; 15
		db $00,$00		; 16
		db $04,$00		; 17
		db $00,$00		; 18
		db $00,$00		; 19
		db $00,$00		; 1A
		db $00,$00		; 1B


		.ResultPtr
		dw .DestroyWallRight	; 0
		dw .DestroyWallLeft	; 1
		dw .DestroyFloor	; 2
		dw .RepeatableRight	; 3
		dw .RepeatableLeft	; 4



		.DestroyWallLeft
		BNE .FailDelete
		PEA.w $FFE0
		LDA #$FF : STA $03
		LDA #$E0
		BRA .DestroyWall

		.DestroyWallRight
		BNE .FailDelete
		PEA.w $0020
		STZ $03
		LDA #$20

		.DestroyWall
		STA $02
		LDA #$E0 : STA $04
		LDA #$FF : STA $05
		STZ $00
		STZ $7C
		LDA #$02 : STA $9C
		LDY #$00
		PEI ($02)
		PEI ($04)
		JSL !GenerateBlock
		REP #$20
		PLA
		CLC : ADC #$0010
		STA $04
		PLA : STA $02
		SEP #$20
		STZ $00
		LDY #$00
		PEI ($02)
		PEI ($04)
		JSL !GenerateBlock
		REP #$20
		PLA
		CLC : ADC #$0010
		STA $04
		PLA : STA $02
		SEP #$20
		STZ $00
		LDY #$00
		JSL !GenerateBlock
		LDA #$09 : STA !SPC4			;\
		REP #$20				; |
		PLA : STA $00				; |
		LDA #$FFE0 : STA $02			; | Smoke puff pattern: 3 on top of each other
		SEP #$20				; |
		LDY #$03				; |
		LDA #$20				; |
		JSL SpawnExSprite_NoSpeed_Long		;/

		.FailDelete
		STZ $3230,x
		RTS


		.DestroyFloor
		BNE +					;\
		STZ $3230,x				; |
		LDA $32A0,x				; |
		ASL #4					; |
		STA $00					; |
		LDA $3210,x				; |
		SEC : SBC $00				; | On a success, sprite is erased and wall is destroyed
		STA $3210,x				; |
		LDA $3220,x				; |
		CLC : ADC #$10				; |
		STA $3220,x				; |
		JMP .DestroyWallRight+2			;/

	+	LDA $3210,x				;\
		CLC : ADC #$10				; | Move sprite 1 tile down
		STA $3210,x				;/

		LDA #$E0 : STA $02			;\
		LDA #$FF : STA $03			; | Start offset
		STZ $04					; |
		STZ $05					;/

		STZ $7C
	-	STZ $00
		LDY #$00
		LDA #$02 : STA $9C
		PEI ($02)
		PEI ($04)
		JSL !GenerateBlock
		REP #$20
		PLA : STA $04
		PLA
		CLC : ADC #$0010
		STA $02
		SEP #$20
		CMP #$30 : BNE -

	+	LDA #$19 : STA !SPC4			; Clap SFX
		STZ $BE,x				; Reset sprite so it can be activated again
		STZ $3280,x				; Reset symbols
		STZ $3290,x				; Reset result flag
		LDA $32A0,x
		INC A
		CMP #$03 : BEQ .FailDelete
		STA $32A0,x
		RTS



		.RepeatableRight
		BNE .GenerateFloor
		JMP .DestroyWallRight+2

		.RepeatableLeft
		BNE .GenerateFloor
		JMP .DestroyWallLeft+2


		.GenerateFloor		; if $3300,x is clear, break floor, otherwise restore it
		LDA #$F0 : STA $02			;\
		LDA #$FF : STA $03			; | Starting offsets
		LDA #$10 : STA $04			; |
		STZ $05					;/
		STZ $7C					;\
		LDA #$0D				; |
		LDY $3300,x : BNE +			; | Block settings
		LDA #$20 : STA $3300,x			; | > Set timer
		LDA #$02				; |
	+	STA $9C					; |
	-	STZ $00					; |
		LDY #$00				;/
		PEI ($02)
		PEI ($04)
		JSL !GenerateBlock
		REP #$20
		PLA : STA $04
		PLA
		CLC : ADC #$0010
		STA $02
		SEP #$20
		CMP #$20 : BNE -
		LDA #$19 : STA !SPC4			; SFX

		REP #$20
		LDA #$FFF0 : STA $00
		LDA $04 : STA $02
		SEP #$20
		LDY #$03
		LDA #$80
		JSL SpawnExSprite_NoSpeed_Long

		RTS











	namespace off





