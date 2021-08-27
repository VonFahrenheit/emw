

Monkey:

	namespace Monkey

	; Monkey GFX address: $30ECA8


	; $BE,x		AI mode
	;			- 0: wait for targets
	;			- 1: walk towards target
	;			- 2: move away from target
	;			- 3: move above target
	;			- 4: attack target
	; $3280,x	Target
	;			- 0-F: sprite of this index
	;			- 10: player 1
	;			- 11: player 2



	!MonkeyAI	= $BE,x
	!MonkeyTarget	= $3280,x
	!MonkeyClimb	= $3290,x
	!MonkeyCarry	= $32A0,x
	!MonkeyConga	= $32B0,x	; timer for conga speed
	!MonkeyCongaY	= $32B0,y



	INIT:
		PHB : PHK : PLB


		LDA !ExtraProp1,x : BEQ .Normal

		.Climb
		LDA $3220,x : STA !MonkeyClimb
		LDA #$05 : STA !MonkeyAI
		REP #$30
		LDA #$0018
		LDY #$0000
		JSL !GetMap16Sprite
		CMP #$0111 : BCC ..L
		CMP #$016E : BCS ..L

	..R	SEP #$20
		STZ $3320,x
		LDA $3220,x
		CLC : ADC #$04
		STA $3220,x
		BRA ..Shared

	..L	SEP #$20
		LDA #$01 : STA $3320,x
		LDA $3220,x
		SEC : SBC #$04
		STA $3220,x

		..Shared
		JSL !GetSpriteSlot
		BMI .NoItem
		LDA !RNG
		AND #$03
		ORA #$04
		STA $3200,y
		LDA #$09 : STA $3230,y
		JSL SPRITE_A_SPRITE_B_COORDS
		TYA
		INC A
		STA !MonkeyCarry
		PHX
		TYX
		JSL $07F7D2			; | > Reset sprite tables
	;	JSL $0187A7			; | > Reset custom sprite tables
		STZ !ExtraBits,x
		LDA #$09 : STA $3230,x
		PLX
		BRA .NoItem


		.Normal
		LDA #$FF : STA !MonkeyClimb
		JSR RandomPlayer
		JSR SearchItem
		LDA !ExtraBits,x
		AND #$04
		LSR #2
		STA !MonkeyAI
		BEQ .NoItem
		JSL !GetSpriteSlot
		BMI .NoItem
		LDA #$1B : STA !NewSpriteNum,y
		LDA #$36 : STA $3200,y
		LDA #$01 : STA $3230,y
		JSL SPRITE_A_SPRITE_B_COORDS
		TYA
		INC A
		STA !MonkeyCarry
		PHX
		TYX
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA #$08 : STA !ExtraBits,x
		PLX



		.NoItem

		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN
		LDA $9D : BNE .gfx
		LDA $3230,x
		CMP #$08 : BEQ AI
		BCS .gfx
		LDY !MonkeyCarry : BEQ .gfx
		DEY
		LDA $3230,x : STA $3230,y	; copy monkey state to carried object when it dies
		LDA $9E,x : STA $309E,y		; copy speeds too
		LDA $AE,x : STA $30AE,y
	.gfx	JMP GRAPHICS

	DATA:
		.WalkSpeed
		db $10,$F0

		.RunSpeed
		db $18,$E8

		.CongaSpeed
		db $04,$FC

		.ClimbSpeed
		db $18,$E8

		.ThrowSpeed
		db $30,$D0



	AI:

		LDA !MonkeyConga		; decrement conga timer
		BEQ $03 : DEC !MonkeyConga

		PEA PHYSICS-1
		PHX
		LDA !MonkeyAI
		ASL A
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw Wait		; 00
		dw Advance	; 01
		dw Flee		; 02
		dw Climb	; 03
		dw Attack	; 04
		dw Hang		; 05
		dw Control	; 06



	Wait:
		PLX
		LDY !MonkeyTarget
		CPY #$10 : BEQ .P1
		CPY #$11 : BEQ .P2

	.Sprite	PHX
		TYX
		JSL $03B6E5
		PLX
		BRA .Check

	.P1	LDA #$01
		BRA .PCE
	.P2	LDA #$02
	.PCE	CLC : JSL !PlayerClipping

	.Check	LDA $3220,x
		SEC : SBC #$40
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$60
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$80 : STA $06
		LDA #$C0 : STA $07

		JSL !Contact16
		BCC .KeepWaiting


	; Decision must be made here
		LDA #$01 : STA !MonkeyAI


		.KeepWaiting
		RTS


	Flee:			; Advance backwards
	Advance:		; SUSUME!!
		PLX

		.Main
		STZ !ExtraProp1,x
		LDY !MonkeyCarry : BEQ .Check
		LDA !MonkeyAI
		CMP #$02 : BEQ .NoCheck		; don't throw items while fleeing
		DEY
		LDA $3230,y
		CMP #$08 : BEQ .NoCheck
		CPX !RNG : BNE .NoCheck
		JMP Attack_Main

		.Check
		CPX !RNG : BNE .NoCheck
		JSR SearchItem			; Monkey has a 1/256 chance of looking for an item each frame
		.NoCheck


		LDA $3330,x
		AND #$04 : BNE .Ground
		LDY $3320,x
		LDA DATA_RunSpeed,y
		STA $AE,x
		RTS


		.Ground
		JSR Conga

		LDY !MonkeyTarget
		CPY #$10 : BEQ .P1
		CPY #$11 : BEQ .P2
		LDA $3210,y : STA $0E		;\ y coord of target
		LDA $3240,y : STA $0F		;/
		LDA $3220,x
		SEC : SBC $3220,y
		LDA $3250,x
		SBC $3250,y
		BPL .1
	.0	LDY #$00 : BRA +
	.1	LDY #$01 : BRA +

	.P2	LDA !P2YPosLo : STA $0E
		LDA !P2YPosHi : STA $0F
		JSL SUB_HORZ_POS_P2
		BRA +
	.P1	LDA !P2YPosLo-$80 : STA $0E
		LDA !P2YPosHi-$80 : STA $0F
		JSL SUB_HORZ_POS_P1
	+	TYA
		LDY !MonkeyAI
		CPY #$02 : BNE +
		EOR #$01			; invert direction when fleeing
	+	STA $3320,x
		TAY

		.CheckLedge
		LDA $0E
		CLC : ADC #$10
		STA $0E
		LDA $0F
		ADC #$00
		STA $0F
		LDA $3210,x
		CMP $0E
		LDA $3240,x
		SBC $0F
		BMI .nope
		JSR LedgeScan
		LDA $0B : BEQ .nope
		LDA #$C0 : STA $9E,x
		.nope

		.Accelerate
		LDA !MonkeyCarry : BEQ +
		LDA DATA_WalkSpeed,y
		BRA ++
	+	LDA DATA_RunSpeed,y
	++	STA $00
		LDA !MonkeyConga : BEQ ..spd
		LDA DATA_CongaSpeed,y
		BRA +
	..spd	LDA $00
	+	CMP $AE,x
		BMI ..L
	..R	INC $AE,x
		INC $AE,x
		RTS
	..L	DEC $AE,x
		DEC $AE,x
		RTS




	Climb:
		PLX
		RTS


	Attack:
		PLX

		.Main
		LDY !MonkeyCarry : BEQ .Nope

		.Throw
		DEY
		PHY
		LDA $3320,x : STA $3320,y
		TAY
		LDA DATA_ThrowSpeed,y
		PLY
		STA $30AE,y
		LDA #$00 : STA $309E,y
		STA $34E0,y				; clear stasis
		LDA #$0A : STA $3230,y
		LDA #$02 : STA !SPC1
		STZ !MonkeyCarry

		.Nope
		LDA #$02 : STA !MonkeyAI		; run away
		JSR RandomPlayer
		RTS


	Hang:
		PLX
		CPX !RNG : BNE .Return
		JSR .Flip
		JSR Attack_Main
		JSR .Flip

		.Return
		RTS

		.Flip
		LDA $3320,x
		EOR #$01
		STA $3320,x
		RTS


	Control:					; monkey under player control
		PLX

		LDA $6DA2
		AND #$03 : BEQ .noLR
		CMP #$03 : BEQ .noLR
		CMP #$01 : BEQ .R

	.L	LDA #$01 : STA $3320,x
		BRA .spd
	.R	STZ $3320,x
	.spd	LDY $3320,x
		JSR Advance_Accelerate
		BRA .CheckJump
	.noLR	STZ $00
		JSR Advance_Accelerate_spd
		LDA $AE,x
		BPL $03 : EOR #$FF : INC A
		CMP #$04 : BCS .CheckJump
		STZ $AE,x

		.CheckJump
		BIT $6DA6 : BPL .NoJump
		LDA $3330,x
		AND #$04 : BEQ .NoJump
		LDA #$C0 : STA $9E,x
		.NoJump


		RTS




	PHYSICS:

		LDA !MonkeyCarry
		BNE .HandleCarry

	.CheckCarry
		LDY !MonkeyTarget
		CPY #$10 : BCC .Carry
		JMP .NoCarry
	.Carry	LDA $3230,y : BEQ .notok	; can't target an item that doesn't exist
		LDA $34E0,y : BEQ .ok		; can't target an item carried by another monkey
	.notok	JSR RandomPlayer
		JMP .NoCarry
		.ok

		PHX
		TYX
		JSL $03B69F
		PLX
		JSL $03B6E5
		JSL $03B72B
		BCS $03 : JMP .NoCarry
		LDA !MonkeyTarget
		INC A
		STA !MonkeyCarry
		TAY
		DEY
		LDA #$09 : STA $3230,y			; Item can be stolen by player
		LDA #$3C				;\
		STA $32E0,y				; | Item can't interact with player for 1 second
		STA $35F0,y				;/
		LDA $3200,y
		CMP #$2F : BEQ +
		CMP #$3E : BEQ +
		CMP #$80 : BNE ++
	+	LDA #$02 : STA !MonkeyAI		; Monkey will run away if it has a spring, POW, or key
	++
	-	JSR RandomPlayer

	.HandleCarry
		LDY !MonkeyCarry
		DEY : BMI .NoCarry
		LDA $3230,y
		CMP #$08 : BEQ ..C
		CMP #$09 : BEQ ..C
		STZ !MonkeyCarry
		LDA #$01 : STA !MonkeyAI		; monkey advances if its item is stolen
		BRA -

	..C	STZ $01
		LDA $3330,x
		AND #$04
		BEQ ..Air

		LDA $3320,x
		EOR #$01
		BRA +

	..Air	LDA $3320,x
	+	STA $00
		ASL A
		CLC : ADC $00
		ASL #2
		SEC : SBC #$06
		STA $00
		BPL $02 : DEC $01

	..X	LDA $3220,x
		CLC : ADC $00
		STA $3220,y
		LDA $3250,x
		ADC $01
		STA $3250,y

		LDA #$08 : STA $00
		LDA $3230,y
		CMP #$08 : BNE +
		LDA $3200,y
		CMP #$2F : BEQ +
		LDA #$10 : STA $00		; objects in state 0x08 are carried further up
	+	LDA $3210,x			; (unless it's a spring)
		SEC : SBC $00
		STA $3210,y
		LDA $3240,x
		SBC #$00
		STA $3240,y
		LDA #$04 : STA $34E0,y		; set stasis
		.NoCarry


		LDA !ExtraProp1,x : BNE .NoCling


		LDA !MonkeyClimb
		CMP #$FF : BEQ .NoClimb
		LDY $3320,x
		LDA DATA_WalkSpeed,y
		STA $AE,x

	; decision about climbing up or down goes here

		LDA DATA_ClimbSpeed+1
		STA $9E,x
		JSL $01802A
		LDA !MonkeyClimb : STA $3220,x
		LDA $3330,x
		AND #$03 : BNE .NoJump
		LDA #$FF : STA !MonkeyClimb
		BRA .NoJump
		.NoClimb


		LDA $3330,x
		PHA
		JSL $01802A
		PLA
		EOR $3330,x
		AND #$04
		BEQ .NoJump
		AND $3330,x
		BNE .NoJump
		LDA #$C0 : STA $9E,x				; jump
		.NoJump

		LDA $3330,x
		AND #$03
		BEQ .NoCling
		LDA $3220,x : STA !MonkeyClimb
		.NoCling



	GRAPHICS:
		LDA !ExtraProp1,x : BEQ .normal
		LDA #$0F : JMP .UpdateAnim
		.normal

		LDA $3330,x
		AND #$04
		BNE .Ground
		LDA !MonkeyClimb
		CMP #$FF : BEQ .Air
	.Climb	LDA !MonkeyCarry : BEQ +
	.CClimb	LDA !SpriteAnimIndex
		CMP #$0C : BCS .ProcessAnim
	-	LDA #$0C : BRA .UpdateAnim

	+	LDA !SpriteAnimIndex
		CMP #$09 : BCC +
		CMP #$0C : BCC .ProcessAnim
	+	LDA #$09 : BRA .UpdateAnim

	.Air	LDA !MonkeyCarry : BNE -
	+	BIT $9E,x
		BPL .Up
	.Down	LDA #$03 : BRA .UpdateAnim
	.Up	LDA #$04 : BRA .UpdateAnim

	.Ground	LDA $AE,x
		BEQ .Still

	.Move	LDA !MonkeyCarry : BEQ .Run
	.Walk	LDA !SpriteAnimIndex
		CMP #$06 : BCC +
		CMP #$09 : BCC .ProcessAnim
	+	LDA #$06 : BRA .UpdateAnim

	.Run	LDA !SpriteAnimIndex
		CMP #$03 : BCC +
		CMP #$06 : BCC .ProcessAnim
	+	LDA #$03 : BRA .UpdateAnim

	.Still	LDA !SpriteAnimIndex
		CMP #$02 : BCC .ProcessAnim
		LDA #$00 : BRA .UpdateAnim


		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		LDA ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA.w ANIM+0,y : STA $04
		LDA.w ANIM+1,y : STA $05

		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL

	.UpdateAnim
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .ProcessAnim



	ANIM:
		dw .IdleTM0 : db $0C,$01	; 00
		dw .IdleTM1 : db $0C,$00	; 01

		dw .IdleTMHold : db $FF,$02	; 02

		dw .WalkTM0 : db $08,$04	; 03
		dw .WalkTM1 : db $08,$05	; 04
		dw .WalkTM2 : db $08,$03	; 05

		dw .WalkTMHold0 : db $08,$07	; 06
		dw .WalkTMHold1 : db $08,$08	; 07
		dw .WalkTMHold2 : db $08,$06	; 08

		dw .ClimbTM0 : db $08,$0A	; 09
		dw .ClimbTM1 : db $08,$0B	; 0A
		dw .ClimbTM2 : db $08,$09	; 0B

		dw .ClimbTMHold0 : db $08,$0D	; 0C
		dw .ClimbTMHold1 : db $08,$0E	; 0D
		dw .ClimbTMHold2 : db $08,$0C	; 0E

		dw .AmbushTM : db $FF,$0F	; 0F

	.IdleTM0
		dw $0008
		db $30,$FC,$F9,$00
		db $30,$00,$00,$04
	.IdleTM1
		dw $0008
		db $30,$FC,$FA,$00
		db $30,$01,$00,$06

	.IdleTMHold
		dw $0008
		db $30,$FD,$F9,$00
		db $30,$00,$00,$08

	.WalkTM0
		dw $0008
		db $30,$FC,$FA,$00
		db $30,$00,$00,$20
	.WalkTM1
		dw $0008
		db $30,$FB,$FA,$00
		db $30,$00,$00,$22
	.WalkTM2
		dw $0008
		db $30,$FB,$FB,$00
		db $30,$00,$00,$24

	.WalkTMHold0
		dw $0008
		db $30,$02,$FB,$02
		db $30,$00,$00,$0A
	.WalkTMHold1
		dw $0008
		db $30,$02,$FA,$02
		db $30,$00,$00,$0C
	.WalkTMHold2
		dw $0008
		db $30,$01,$FA,$02
		db $30,$00,$00,$0E

	.ClimbTM0
		dw $0008
		db $30,$01,$F8,$02
		db $30,$00,$00,$26
	.ClimbTM1
		dw $0008
		db $30,$01,$F9,$02
		db $30,$01,$00,$28
	.ClimbTM2
		dw $0008
		db $30,$00,$FA,$02
		db $30,$00,$00,$2A

	.ClimbTMHold0
		dw $0008
		db $30,$00,$F5,$00
		db $30,$00,$00,$2C
	.ClimbTMHold1
		dw $0008
		db $30,$FF,$F5,$00
		db $30,$00,$00,$2E
	.ClimbTMHold2
		dw $0008
		db $30,$FF,$F6,$00
		db $30,$00,$00,$40

	.AmbushTM
		dw $0008
		db $70,$00,$F5,$00
		db $30,$00,$00,$2C


	SearchItem:
		LDY #$0F
	-	LDA $3200,y
		CMP #$2F : BEQ .Target
		LDA $3230,y
		CMP #$09 : BEQ .Target
		CMP #$0B : BEQ .Target
		DEY : BPL -
		RTS

		.Target
		TYA
		STA !MonkeyTarget
		RTS


	LedgeScan:
		PHY
		LDY $3320,x
		LDA $3220,x
		CLC : ADC .Offset,y
		AND #$F0
		STA $0C
		LDA $3250,x
		ADC .Offset+2,y
		STA $0D

		LDA $3210,x
		SEC : SBC #$38
		AND #$F0
		STA $0E
		LDA $3240,x
		SBC #$00
		STA $0F
		STZ $0B

		LDY #$03

	-	PHX
		PHY
		REP #$10
		LDX $0C
		LDY $0E
		JSL !GetMap16
		PLY
		PLX
		CMP #$0111 : BCC .clear
		CMP #$016E : BCc .solid
	.clear	LDA #$0000
		BRA .set
	.solid	LDA #$0001

	.set	TSB $0B
		LDA $0E
		CLC : ADC #$0010
		STA $0E
		SEP #$20
		DEY : BPL -

		PLY
		RTS


		.Offset
		db $38,$D8
		db $00,$FF


	Conga:
		LDA $3220,x
		SEC : SBC #$04
		STA $00
		LDA $3250,x
		SBC #$00
		STA $08
		LDA $3210,x : STA $01
		LDA $3240,x : STA $09
		LDA #$18
		STA $02
		STA $03

		LDY #$0F
	-	CPY !SpriteIndex : BEQ .next	; don't check self
		LDA $3230,y
		CMP #$08 : BEQ .check
	.next	DEY : BPL -
		RTS

	.check	LDA !ExtraBits,y
		AND.b #!CustomBit
		BEQ .next
		LDA !NewSpriteNum,y		; if it's the same type of sprite, check contact
		CMP !NewSpriteNum,x
		BNE .next
		LDA !MonkeyCongaY : BNE .next
		PHX
		TYX
		JSL !GetSpriteClipping04
		PLX
		JSL !CheckContact
		BCC .next
		LDA #$10 : STA !MonkeyConga	; set conga for 16 frames
		RTS


	RandomPlayer:
		LDA !MultiPlayer : BNE .rng
		LDA #$10 : BRA .write
	.rng	LDA !RNG			; prevent monkey from targeting a nonexistent player
		AND #$01
		ORA #$10
		STA !MonkeyTarget
		ROR #2
		AND #$80
		LDA !P2Status-$80,y
		BEQ .ok
		LDA !MonkeyTarget
		EOR #$01
	.write	STA !MonkeyTarget
	.ok	RTS


	namespace off





