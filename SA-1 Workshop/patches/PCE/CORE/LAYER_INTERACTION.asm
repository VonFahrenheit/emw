
	; Structure:
	; - Call 019211
	;   - Call 01944D
	;     - Set up clipping box
	;     - Call 019523
	;       - Set up map16 pointer
	;       - Call 00F545 (read map16)
	;   - Call 00F04D (Check something (probably mud/lava sloves))
	;   - Call 019330 (set status to sinking in mud/lava if approperiate)
	;   - Call 0192C9
	;     - Call 019441 (see 01944D)
	;     - Go to 019310 if water
	;     - Call 019425 (set up block coords ($98-$9B))
	;     - Do something with block coords
	;   - Call 01928E
	;     - Call 019441 (see 01944D)
	;     - Call 019425 (set up block coords ($98-$9B))
	;     - Do something with block coords
	; - Call 0284C0 (water/lava splash)

	; RAM:
	; - $7693:	Map16 acts like lo byte
	; - $78A7:	Map16 acts like hi byte
	; - $785F:	Loop count
	; - $7860:	Climb legality flag
	; - $78D7:	Muncher flag
	; - $78D8:	Layer being processed (0 = BG1, 1 = BG3)
	; - $0A:	16-bit Xpos (current)
	; - $0C:	16-bit Ypos (current)


	LAYER_INTERACTION:		;CODE_019140:

		STZ $7694
		STZ !P2Blocked
		STZ !P2Slope
		STZ $785E
		STZ $785F
		STZ $7860
		STZ $78D7
		STZ $78D8
		STZ !P2Map16Index
		REP #$20
		LDA #$0025				;\
		STA !P2Map16Table+0			; |
		STA !P2Map16Table+2			; | Wipe map16 table
		STA !P2Map16Table+4			; |
		STA !P2Map16Table+6			; |
		SEP #$20				;/
		LDA !P2Water				;\
		AND #$40				; | Backup water flag
		STA $7695				;/
		TRB !P2Water				; > Wipe water flag
	-	JSR MAIN		;CODE_019211
	BIT $785F
	BMI +
	LDA #$80 : STA $785F
	LDA #$02 : STA !P2Map16Index
	BRA -
	+
	LDA #$80 : STA !P2Map16Index
		LDA !RAM_ScreenMode
		BPL .End		;.0191BE
		INC $785E		; This allows BG3 to be processed
		INC $78D8
		REP #$20
		LDA !P2XPosLo
		CLC : ADC $26
		STA !P2XPosLo
		LDA !P2YPosLo
		CLC : ADC $28
		STA !P2YPosLo
		SEP #$20
		JSR MAIN		;CODE_019211
		REP #$20
		LDA !P2XPosLo
		SEC : SBC $26
		STA !P2XPosLo
		LDA !P2YPosLo
		SEC : SBC $28
		STA !P2YPosLo
		SEP #$20
		LDA !P2Blocked
		BPL .End		;.0191BE
		AND #$03
		BNE .End		;.0191BE
		LDY #$00
		LDA $77BF
		EOR #$FF
		INC A
		BPL $01 : DEY
		CLC : ADC !P2XPosLo
		STA !P2XPosLo
		TYA
		ADC !P2XPosHi
		STA !P2XPosHi

		.End			;.0191BE
		LDA $78D7 : BEQ .NoMuncher
		AND !P2Blocked : BNE .NoMuncher		; Don't count if standing on another tile
		LDA $78D7 : TSB !P2Blocked		; Solid only if it's the only tile in that direction
		TAY
		LDA !P2Invinc : BNE .NoMuncher
		PHY
		JSR HURT
		PLY
		LDA .MuncherSpeedX,y : STA !P2XSpeed
		LDA .MuncherSpeedY,y : STA !P2YSpeed
		.NoMuncher


		BIT $7860
		BMI .Climb
	-	LDA #$01 : TRB !P2Water
		BRA .NoClimb

		.Climb
		LDA !P2Climb : BNE -		; Leeway's climb flag, Kadaal's kick flag
		LDA !P2Water
		LSR A
		BCS .Climbing
		LDA $6DA3
		AND #$0C
		BEQ .NoClimb
		LDA #$01 : TSB !P2Water
		STZ !P2Punch1
		STZ !P2Punch2
		STZ !P2Senku
		STZ !P2Kick
		STZ !P2SenkuUsed
		STZ !P2KillCount
		STZ !P2Dashing
		LDA #$80 : TRB !P2Water

		.Climbing
		JSR Climb_Limit
		.NoClimb


		LDA !P2Pipe
		BNE .NoPipe
		LDA !P2Map16Table+$01
		ORA !P2Map16Table+$03
		BEQ .NoPipe
		LDA !P2Map16Table+$00
		CMP #$3B : BEQ .Pipe
		LDA !P2Map16Table+$02
		CMP #$3F : BNE .NoPipe

		.Pipe
		LDA !P2Blocked
		AND #$04
		ORA !P2Platform
		ORA !P2SpritePlatform
		BEQ .NoPipe
		LDA $6DA3
		AND !P2Blocked
		AND #$03
		BEQ .NoPipe
		DEC A
		EOR #$01
		CLC : ROR #3
		ORA #$3F
		STA !P2Pipe
		REP #$20
		DEC !P2YPosLo
		DEC !P2YPosLo
		SEP #$20
		.NoPipe


; This is where the backup restoration goes!
; Find the other one for the Y collision too.


		LDA !P2Blocked
		AND #$03
		BEQ +
		;TAX
	PHY
	LSR A
	EOR #$01
	TAY
;	REP #$20
;	LDA !P2XPosBackup : STA !P2XPosLo
;	SEP #$20
		LDA !P2XPosLo
		AND #$F0
		;ORA .XCoords,x
	ORA ($F0),y



;	CLC : ADC !P2Direction
	INC A
		STA !P2XPosLo
	PLY
		+

		LDA !P2Water
		AND #$60
		EOR $7695
		BEQ .Return

		LDA !P2Character	;\ Leeway doesn't get speed boost from leaving water
		CMP #$03 : BEQ +++	;/

		LDA !P2XSpeed
		BPL +
		EOR #$FF
		LSR A
		EOR #$FF
		BRA ++
	+	LSR A
	++	STA !P2XSpeed
		BIT !P2Water
		BVS +
		BIT !P2YSpeed
		BPL +++
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		LSR A
		SEC : SBC #$40
		BRA ++
	+	LDA !P2YSpeed
		BMI +
		LSR A
		BRA ++
	+	EOR #$FF
		LSR A
		EOR #$FF
	++	STA !P2YSpeed
	+++	JMP WATER_SPLASH	;0284C0

		.Return
		RTS


		.MuncherSpeedX
		db $00,$F0,$10,$00	; 00-03
		db $00,$F0,$10,$00	; 04-07
		db $00,$F0,$10,$00	; 08-0B
		db $00,$F0,$10,$00	; 0C-0F

		.MuncherSpeedY
		db $00,$00,$00,$00	; 00-03
		db $F0,$F0,$F0,$F0	; 04-07
		db $10,$10,$10,$10	; 08-0B
		db $00,$00,$00,$00	; 0C-0F

		.XCoords
		db $00,$03,$0E,$00



	MAIN:				;CODE_019211:
		; Don't bother with buoyancy; P2 always interacts with water.
		LDA $85
		BEQ .NoWaterLevel
		LDA #$40 : TSB !P2Water

		.NoWaterLevel
		LDA !P2XSpeed
	CLC : ADC !P2VectorX
		ASL A
		ROL A
		AND #$01
		TAY
		JSR GET_TILE		;CODE_01944D
	PHP
	LDX !P2Map16Index
	STA !P2Map16Table+1,x
	PLP
		STA $78A7
		BEQ .Vertical		;.019233
		LDA $7693
	STA !P2Map16Table+0,x
		CMP #$6E : BCS .Vertical		;.01925B
		CMP #$11 : BCC .Vertical
		JSR SET_BLOCK

		.Vertical		;.01925B
		JSR VERTICAL_COLLISION	;CODE_0192C9


		; Check for interactive BG2 goes here
	RTS

		LDA !P2XSpeed
		BEQ .Return
		ASL A
		ROL A
		AND #$01
		TAY
		JSR GET_TILE_Weird	;CODE_019441
		STA $78A7
	PHP
	LDX !P2Map16Index
	STA !P2Map16Table+1,x
	PLP
	;	STA $7862
		BEQ .Zero
		LDA $7693
	STA !P2Map16Table+0,x
		CMP #$11 : BCC .Zero
		CMP #$6E : BCS .Zero
		JSR SET_BLOCK		;CODE_019425
		LDA $785E : BEQ .Zero
		LDA #$40 : TSB !P2Blocked

		.Zero
	;	LDA $7693 : STA $7860

		.Return
		RTS


	VERTICAL_COLLISION:		;CODE_0192C9:
		LDY #$02
		LDA !P2YSpeed
		BPL $01 : INY
		JSR GET_TILE_Weird	;CODE_019441
		STA $78A7
	PHP
	LDX !P2Map16Index
	STA !P2Map16Table+5,x
	LDA $7693
	STA !P2Map16Table+4,x
	PLP
	;	STA $78D7
	;	PHP
	;	LDA $7693 : STA $785F
	;	PLP
		BNE .HiBlock
		LDA $7693
		CMP #$22 : BNE .Return		; Invisible 1-up block
		JMP SET_BLOCK

		.HiBlock
		LDA $7693
		CPY #$02 : BEQ .Down	;.019310
		CMP #$11 : BCC .Return
		CMP #$6E : BCC .Solid	;.0192F9
		CMP $7430 : BCC .Return
		CMP $7431 : BCS .Return

		.Solid			;.0192F9
		JSR SET_BLOCK		;CODE_019425
		LDA $7693 : STA $7868
		LDA $785E
		BEQ .Return
		LDA #$20 : TSB !P2Blocked

		.Return
		RTS

		.Down			;.019310
		CMP #$59 : BCC .NoLava	;.01933B
		CMP #$5C : BCS .NoLava	;.01933B
		LDY $7931
		CPY #$0E : BEQ .Lava
		CPY #$03 : BNE .NoLava	;.01933B

		.Lava
		LDA #$01 : STA !P2Status
		LDA !P1Dead
		BEQ .Return
		LDA #$01 : STA !SPC3
		RTS

		.NoLava			;.01933B
		CMP #$11
		BCC .Ledge		;.0193B0
		CMP #$6E
		BCC .NormalTile		;.0193B8
		CMP #$D8
		BCS .NoSlope		;.019386
		JSR STEEPNESS		;JSL CODE_00FA19
		LDA [$05],y
		CMP #$10
		BEQ .Return
		BCS .NoSlope		;.019386
		LDA $00
		CMP #$0C
		BCS .GetSlope		;.01935D
	;	CMP [$05],y
	;	BCC .Return

		.GetSlope		;.01935D
		LDA [$05],y
		STA $7694
		LDX $08
		LDA.l $00E53D,x
		STA !P2Slope
		CMP #$04
		BEQ .Slope
		CMP #$FC
		BNE .NormalTile		;.019384 -> BRA .0193B8

		.Slope			;.019380
		JSR STEEP_SLOPE		;JSL CODE_03C1CA
		BRA .NormalTile		;.0193B8

		.NoSlope		;.019386
		LDA $0C
		AND #$0F
		CMP #$05
		BCS .Return1
		REP #$20		;\
		DEC !P2YPosLo		; | Move up one pixel
		SEP #$20		;/
		JMP VERTICAL_COLLISION	;CODE_0192C9

		.Ledge			;.0193B0
		LDA $0C
		AND #$0F
		CMP #$05
		BCS .Return1

		.NormalTile		;.0193B8
		LDY $7693
		CPY #$0C
		BEQ .ConveyorTile	;.0193D9
		CPY #$0D
		BNE .NoConveyor		;.019405

		.ConveyorTile		;.0193D9
		LDA !P2Blocked
		AND #$03
		BNE .NoConveyor		;.019405
		LDA $7931
		CMP #$02
		BEQ .Conveyor		;.0193EF
		CMP #$08
		BNE .NoConveyor		;.019405

		.Conveyor		;.0193EF
		TYA
		SEC : SBC #$0C
		TAY
		LDA !P2XPosLo
		CLC : ADC .Table,y
		STA !P2XPosLo
		LDA !P2XPosHi
		ADC .Table+2,y
		STA !P2XPosHi

		.NoConveyor		;.019405
		LDA !P2YPosLo
		AND #$F0
		CLC : ADC $7694
		STA !P2YPosLo
		JSR SET_BLOCK_Blocked	;CODE_019435
		LDA $785E
		BEQ .Return1
		LDA #$80 : TSB !P2Blocked

		.Return1
		RTS

		.Table
		db $01,$FF,$00,$FF


	SET_BLOCK:			;CODE_019425:
	; ONLY TILES ON PAGE 0x01 SHOULD BE SOLID

		LDA !RAM_ScreenMode
		LSR A
		BCC .HorizontalLevel

		.VerticalLevel
		LDA $0A : STA $9A
		LDA $0B : STA $99
		LDA $0C : STA $98
		LDA $0D : STA $9B
		BRA .Blocked

		.HorizontalLevel
		LDA $0A : STA $9A
		LDA $0B : STA $9B
		LDA $0C : STA $98
		LDA $0D : STA $99

		.Blocked		;CODE_019435:
		LDA $7693			;\ Very special muncher case
		CMP #$2F : BEQ .Return		;/

		LDY $0F
		LDA .Bits,y
		TSB !P2Blocked

		CPY #$02 : BEQ .Down
		CPY #$03 : BEQ .Up

		.Return
		RTS

		.Bits
		db $01,$02,$04,$08


		.Down
		LDA $78A7			;\ Must be page 01
		BEQ .Return			;/

		LDA !P2Character			;\
		CMP #$02 : BNE ..NoDrill		; |
		LDA $7693				; |
		CMP #$1E : BNE ..NoDrill		; |
		LDA !P2ShellDrill : BEQ ..NoDrill	; | Kadaal can shell drill through bricks
		STZ $00					; |
		STZ $7C					; |
		LDA #$02 : STA $9C			; |
		LDY #$01				; |
		LDA #$04 : TRB !P2Blocked		; > Doesn't count as solid when drilled
		JMP GENERATE_BLOCK			;/
		..NoDrill


		LDA $6DA3			;\
		AND #$04			; | Must push down
		BEQ .Return			;/
		LDA !P2Pipe			;\
		AND #$1F			; | Must not be in a pipe
		BNE .Return			;/
		LDA $7693
		BIT $785F
		BPL .LeftPipe

		.RightPipe
		CMP #$38
		BEQ .DownPipe
		RTS

		.LeftPipe
		CMP #$37
		BNE .Return

		.DownPipe
		LDA !P2XPosLo
		AND #$0F
		CMP #$04 : BCC .Return
		CMP #$0C : BCS .Return
		LDA #$FF : STA !P2Pipe
		RTS

		.Up
		STZ !P2YSpeed
		LDA #$01 : STA !SPC1		; > Hit head sound
		REP #$20
;	LDA !P2YPosLo
		LDA $0C
		AND #$FFF0
		CLC : ADC #$0011
	CLC : ADC !P2YPosLo
	SEC : SBC $0C
		STA !P2YPosLo
		SEP #$20


	UPCOLLISION:
		LDA $78A7			;\
		XBA				; | Get acts like
		LDA $7693			;/
		REP #$20			; > A 16 bit

		CMP #$0022			;\ Invisible 1-Up block
		BNE $03 : JMP .1Up		;/
		CMP #$0114			;\ Direction coins
		BNE $03 : JMP .DirCoins		;/
		CMP #$0129			;\ Most container blocks
		BCC .GetInteraction		;/
		CMP #$0137			;\
		BNE $03 : JMP .VertPipe		; | Vertical pipe from below
		CMP #$0138			; |
		BNE $03 : JMP .VertPipe		;/
		SEP #$20
		RTS

		.GetInteraction
		SEC : SBC #$0117
		ASL A : TAX
		SEP #$20
		JMP (.Map16Ptr,x)

		.Map16Ptr
		dw .FlowerTBlock		; 117
		dw .FeatherTBlock		; 118
		dw .StarTBlock			; 119
		dw .VariableTBlock		; 11A
		dw .MultiCoinTBlock		; 11B
		dw .CoinTBlock			; 11C
		dw .PTBlock			; 11D
		dw .TBlock			; 11E
		dw .FlowerQBlock		; 11F
		dw .FeatherQBlock		; 120
		dw .StarQBlock			; 121
		dw .Star2QBlock			; 122
		dw .MultiCoinQBlock		; 123
		dw .CoinQBlock			; 124
		dw .VariableQBlock		; 125
		dw .YoshiQBlock			; 126
		dw .ShellQBlock			; 127
		dw .ShellQBlock			; 128


		.FlowerTBlock
		LDA #$02 : JMP .TBlockUsed

		.FeatherTBlock
		LDA #$04 : BRA .TBlockUsed

		.StarTBlock
		LDA #$03 : BRA .TBlockUsed

		.VariableTBlock
		LDA $0A				;\
		LSR #4				; | Get index based on Xpos
		TAX				; |
		LDA ..Table,x			;/
		BNE +				;\
		LDA $7490			; | Star 2
		BEQ .CoinTBlock			; |
		LDA #$03 : BRA .TBlockUsed	;/
	+	CMP #$01 : BNE +		;\ 1-Up
		LDA #$05 : BRA .TBlockUsed	;/
	+	LDA #$08 : BRA .TBlockUsed	; > Vine

		..Table
		db $00,$01,$02,$00
		db $01,$02,$00,$01
		db $02,$00,$01,$02
		db $00,$01,$02,$00

		.MultiCoinTBlock
		LDA !CoinTimer			;\
		BNE +				; | Start coin timer at first bounce
		LDA #$0A : STA $9C		; |
		LDA #$07 : BRA .TBlockMain	;/
	+	CMP #$01 : BNE +		;\
		STZ !CoinTimer			; | Reset coin timer at last bounce
		BRA .CoinTBlock			;/
	+	LDA #$0A : STA $9C		;\ Generate coins in-between
		LDA #$06 : BRA .TBlockMain	;/

		.CoinTBlock
		LDA #$06 : BRA .TBlockUsed

		.PTBlock
		LDA #$0A : BRA .TBlockUsed

		.TBlock
		STZ $00				; > No object
		LDA !P2Character		;\ Leeway doesn't break bricks
		CMP #$03 : BEQ .TBlockBounce	;/

		.TBlockBreak
		LDA #$02 : STA $9C		; Empty space
		LDY #$01			; Shatter block
		STZ $7C				; No bounce sprite
		JMP GENERATE_BLOCK

		.TBlockBounce
		LDA #$01 : STA $7C		;\ (0x07 is spinning turn block)
		LDA #$0C : STA $9C		; | Normal turn block code
		LDY #$00			;/
		JMP GENERATE_BLOCK

		.TBlockUsed
		LDY #$0D : STY $9C		; Used block

		.TBlockMain
		STA $00
		LDY #$00			; Don't shatter block
		LDA #$01			;\ Bounce sprite to spawn (turn block)
		STA $7C				;/
		JMP GENERATE_BLOCK

		.1Up
		SEP #$20
		LDA #$05 : BRA .QBlockMain

		.DirCoins
		SEP #$20
		LDA #$0F : BRA .QBlockMain

		.FlowerQBlock
		LDA #$01
		LDY $19
		BEQ $01 : INC A
		BRA .QBlockMain

		.FeatherQBlock
		LDA #$01
		LDY $19
		BEQ $02 : LDA #$04
		BRA .QBlockMain

		.Star2QBlock
		LDA $7490
		BEQ .CoinQBlock

		.StarQBlock
		LDA #$03 : BRA .QBlockMain

		.MultiCoinQBlock
		LDA !CoinTimer			;\
		BNE +				; | Start coin counter at first bounce
		LDA #$0B : STA $9C		; |
		LDA #$07			;/
	-	STA $00				;\
		LDY #$00			; | Generic multi-coin question block setup
		LDA #$03 : STA $7C		; |
		JMP GENERATE_BLOCK		;/
	+	CMP #$01 : BNE +		;\
		STZ !CoinTimer			; | Reset coin timer at last bounce
		BRA .CoinQBlock			;/
	+	LDA #$0B : STA $9C		;\ Generate coins in-between
		LDA #$06 : BRA -		;/

		.CoinQBlock
		SEP #$20
		LDA #$06 : BRA .QBlockMain

		.QBlockYoshi
		LDA #$0C : BRA .QBlockMain

		.ShellQBlock
		LDA #$0D

		.QBlockMain
		STA $00
		LDY #$00			;> Shatter block flag
		LDA #$0D			;\ Used block
		STA $9C				;/
		LDA #$03			;\ Bounce sprite (question block)
		STA $7C				;/
		JMP GENERATE_BLOCK		; Clear block

		.VariableQBlock
		LDA $0A				;\
		AND #$30			; | Spawn shell if certain Xpos
		CMP #$30			; |
		BEQ .ShellQBlock		;/
		LDA #$0B : BRA .QBlockMain	; > Otherwise get variable

		.YoshiQBlock
		LDA !YoshiIndex			;\
		BEQ +				; | If no Yoshi exists, spawn 1-Up, otherwise spawn Yoshi.
		LDA #$05 : BRA .QBlockMain	; |
	+	LDA #$0C : BRA .QBlockMain	;/

		.VertPipe
		SEP #$20
		BIT $785F
		BMI .RightSide

		.LeftSide
		CMP #$37
		BEQ .Enter
		RTS

		.RightSide
		CMP #$38
		BNE +

		.Enter
		LDA !P2XPosLo
		AND #$0F
		CMP #$04 : BCC +
		CMP #$0C : BCS +
		LDA $6DA3
		AND #$08
		BEQ +
		LDA !P2Pipe
		BNE +
		LDA #$BF : STA !P2Pipe
	+	RTS



	GET_TILE:
		.Weird			;CODE_019441:
		STY $0F

		.Main			;CODE_01944D:
		LDA $785E
		INC A
		AND !RAM_ScreenMode
		BNE $03 : JMP .Horizontal

		.Vertical
;	LDA ($F2),y
;	BPL +
;	EOR #$FF : INC A
;	STA $00				; This will soon be overwritten anyway
;	LDA !P2YPosLo
;	SEC : SBC $00
;	ROR A
;	EOR #$80
;	ASL A
;	BRA ++
;	+
;	CLC : ADC !P2YPosLo
;	++
;	LDX #$00
;	BIT $785F
;	BPL ++
;	PHP
;	CPY #$02
;	BCS +
;	CLC : ADC ($F4),y
;	BCC +
;	INX
;	+
;	PLP
;	++

	REP #$20
	LDA ($F2),y
	AND #$00FF
	CMP #$0080
	BCC $03 : ORA #$FF00
	CLC : ADC !P2YPosLo
	LDX $785F : BPL +
	CPY #$02 : BCS +
	STA $00
	LDA ($F4),y
	AND #$00FF
	CLC : ADC $00
	+
	STA $0C
	SEP #$20

;		STA $0C
		AND #$F0
		STA $00
;		LDA !P2YPosHi
;	ADC .HiByte,x
	LDA $0D
		BPL +				; enforce vertical extension
		STZ $00				; up limit
		STZ $0C
		LDA #$00
		BRA ..GoodY
	+	CMP $5D : BCC ..GoodY
		LDA #$F0			; down limit
		STA $00
		STA $0C
		LDA $5D
		DEC A

	..GoodY	STA $0D
		LDA !P2XPosLo
		CLC : ADC ($F0),y		; Add clipping value
	LDX #$00
	BIT $785F
	BPL ++
	PHP
	CPY #$02
	BCC +
	CLC : ADC ($F4),y
	BCC +
	INX
	+
	PLP
	++
		STA $0A
		STA $01
		LDA !P2XPosHi
	ADC .HiByte,x
		BPL +
		STZ $01				; limit left
		STZ $0A
		LDA #$00
		BRA ..GoodX

	+	CMP #$02 : BCC ..GoodX
		LDA #$F0			; limit right
		STA $01
		STA $0A
		LDA #$01

	..GoodX	STA $0B
		LDA $01
		LSR #4
		ORA $00 : STA $00
		LDX $0D
		LDA.l $00BA80,x
		LDY $78D8			; $785E fails
		BEQ $04 : LDA.l $00BA8E,x
		CLC : ADC $00
		STA $05
		LDA.l $00BABC,x
		LDY $78D8			; $785E fails
		BEQ $04 : LDA.l $00BACA,x

	BIT !RAM_ScreenMode
	BPL $04 : LDA.l $00BACA,x

		ADC $0B
		STA $06
		JMP .Shared		;CODE_019523

		.OutOfBounds
		LDY $0F
		LDA #$00
		STA $7693
		STA $7694
		RTS


		.ClippingX
		db $0D,$02,$05,$05		; $0E,$02,$08,$08
		; Xdisp of vertical bar: left, right
		; Xdisp of horizontal bar: down, up

		.ClippingY
		db $05,$05,$10,$00		; $08,$08,$10,$02
		; Ydisp of vertical bar: right, left
		; Ydisp of horizontal bar: down, up

		.ClippingSize
		db $0A,$0A,$05,$05
		; Length of vertical bar: left, right
		; Length of horizontal bar: down, up


		.Horizontal
;	LDA ($F2),y
;	BPL +
;	EOR #$FF : INC A
;	STA $00				; This will soon be overwritten anyway
;	LDA !P2YPosLo
;	SEC : SBC $00
;	ROR A
;	EOR #$80
;	ASL A
;	BRA ++
;	+
;	CLC : ADC !P2YPosLo
;	++
;	LDX #$00
;	BIT $785F
;	BPL ++
;	PHP
;	CPY #$02
;	BCS +
;	CLC : ADC ($F4),y
;	BCC +
;	INX
;	+
;	PLP
;	++

	REP #$20
	LDA ($F2),y
	AND #$00FF
	CMP #$0080
	BCC $03 : ORA #$FF00
	CLC : ADC !P2YPosLo
	LDX $785F : BPL +
	CPY #$02 : BCS +
	STA $00
	LDA ($F4),y
	AND #$00FF
	CLC : ADC $00
	+
	STA $0C
	SEP #$20

;		STA $0C
		AND #$F0
		STA $00
;		LDA !P2YPosHi
;	ADC .HiByte,x
;		STA $0D
		BIT $0D : BMI +

		REP #$20
		LDA $0C
		CMP #$01B0
		SEP #$20
		BCC ..GoodY

		LDA #$A0			; limit down
		STA $00
		STA $0C
		LDA #$01
		BRA ..SetY

	+	STZ $00				; limit up
		STZ $0C
		LDA #$00
	..SetY	STA $0D

	..GoodY	LDA !P2XPosLo
		CLC : ADC ($F0),y		; Add clipping value
	LDX #$00
	BIT $785F
	BPL ++
	PHP
	CPY #$02
	BCC +
	CLC : ADC ($F4),y
	BCC +
	INX
	+
	PLP
	++
		STA $0A
		STA $01
		LDA !P2XPosHi
	ADC .HiByte,x
		BPL +
		STZ $01
		STZ $0A
		LDA #$00
		BRA ..GoodX

	+	CMP $5D : BCC ..GoodX
		LDA #$F0
		STA $01
		STA $0A
		LDA $5D
		DEC A

	..GoodX	STA $0B
		LDA $01
		LSR #4
		ORA $00 : STA $00
		LDX $0B
		LDA.l $00BA60,x
		LDY $78D8		; $785E fails
		BEQ $04 : LDA.l $00BA70,x
		CLC : ADC $00
		STA $05
		LDA.l $00BA9C,x
		LDY $78D8		; $785E fails
		BEQ $04 : LDA.l $00BAAC,x
		ADC $0D
		STA $06


		.Shared			;CODE_019523:
		LDA $00 : PHA
		LDA $01 : PHA
		LDA $02 : PHA
		LDA !Map16ActsLike+0 : STA $00
		LDA !Map16ActsLike+1 : STA $01
		LDA !Map16ActsLike+2 : STA $02
		LDA #$40 : STA $07
		LDA [$05]
		XBA
		INC $07
		LDA [$05]
		XBA
		REP #$30
		AND #$3FFF
		ASL A : TAY
		LDA [$00],y
		SEP #$30
		STA $7693
		XBA
		STA $78A7
		JSR READ_TILE		;CODE_00F545
		PLX : STX $02
		PLX : STX $01
		PLX : STX $00
		LDY $0F
		CMP #$00
		RTS

		.HiByte
		db $00,$01


	READ_TILE:			;CODE_00F545:
		TAY
		BEQ .LoBlock
		JMP .HiBlock

		.LoBlock
		LDY $7693
		CPY #$21 : BNE .NoInvisCoinBlock
		LDX $0F
		CPX #$03 : BNE .ReturnLo
		LDY #$24 : STY $7693
		LDA #$01

		.ReturnLo
		RTS

		.NoInvisCoinBlock
		CPY #$22 : BNE .NoInvis1UpBlock
		LDX $0F
		CPX #$03 : BEQ .ReturnLo
		LDY #$25 : STY $7693		; > Act as air unless from below
		LDA #$00
		RTS

		.NoInvis1UpBlock
		CPY #$29 : BNE .PNotInvis
		LDY $74AD
		BEQ .Return
		LDY #$24 : STY $7693
		LDA #$01
		RTS

		.PNotInvis
		CPY #$06 : BCS .NoWater

		.CheckLava		;.01923A
		CPY #$02
		BCS .DeepWater
		LDA $0C
		AND #$0F
		CMP #$08
		BCC .ReturnWater

		.DeepWater
		LDA #$40		;\
		CPY #$04		; | Check for lava
		BEQ .Lava		; |
		CPY #$05		; |
		BNE .Water		;/

		.Lava
		LDA #$01 : STA !P2Status
		LDA !P1Dead
		BEQ +
		LDA #$01 : STA !SPC3
		+
		LDA #$40|$20

		.Water
		TSB !P2Water

		.ReturnWater
		LDA #$00
		RTS


		.NoWater
		CPY #$1D : BCS $03 : JMP Climb
		CPY #$1F : BEQ $04 : CPY #$20 : BNE $03 : JMP Door
		CPY #$9C : BNE +
		LDA $7931
		DEC A
		BNE +
		JMP Door
	+	CPY #$38 : BNE $03 : JMP MidwayPoint
		CPY #$2B : BEQ .PCoinBrown
		CPY #$2C : BEQ Coin
		CPY #$2D : BNE $03 : JMP YoshiCoin_Hi
		CPY #$2E : BNE $03 : JMP YoshiCoin_Lo

		.Return
		RTS

		.PCoinBrown
		LDA $74AD
		BEQ Coin
		LDA #$32 : STA $7693
		RTS

		.HiBlock
		STA $78A7
		LDY $7693
		CPY #$2F : BNE .NoMuncher
		LDX $0F				;\
		LDA SET_BLOCK_Bits,x		; | Remember which side the muncher is on
		TSB $78D7			;/
		RTS
		.NoMuncher

		LDX $7931
		CPX #$03
		BNE .NoWaterSlope
		LDX #$19
		TYA
	-	CMP.l $00EAC1,x
		BEQ .WaterSlope
		DEX
		BPL -
		BRA .NoWaterSlope

		.WaterSlope
		LDA #$40 : TSB !P2Water
		LDA $78A7
		RTS

		.NoWaterSlope
		LDA $78A7
		CPY #$32 : BNE .Not132
		LDY $74AD
		BEQ .Return
		LDY #$2B : STY $7693
		BRA Coin
		LDA #$00
		RTS

		.Not132
		CPY #$2F : BNE .Return
		LDY $74AE
		BEQ .Return


	Coin:
		PEA .GetBack-1
		LDA #$00 : PHA : PHA : PHA
		LDA #$02 : STA $9C
		LDY #$00			; Don't shatter block
		STZ $7C
		REP #$20
		JMP GENERATE_BLOCK_HorzLevel

		.GetBack
		JSR SET_GLITTER
		LDA !CurrentPlayer		;\
		TAX				; | Increase coins
		INC !P1CoinIncrease,x		;/
		LDY #$25 : STY $7693
		LDA #$00 : XBA
		LDA #$00
		RTS

	MidwayPoint:
		PEA .GetBack-1
		LDY #$00 : PHY : PHY : PHY
		LDA #$02 : STA $9C
		STZ $7C
		REP #$20
		JMP GENERATE_BLOCK_HorzLevel

		.GetBack
		JSR SET_GLITTER
		LDA #$01			;\ Set midway flag
		STA $73CE			;/
		LDX $73BF			;\
		LDA $7EA2,x			; | Set flag in OW table
		ORA #$40			; |
		STA $7EA2,x			;/
		LDA !Level : STA !MidwayLo,x	;\ Store to midway table
		LDA !Level+1 : STA !MidwayHi,x	;/
		LDA #$05 : STA !SPC1
		LDA !P2HP
		CMP !P2MaxHP
		BEQ +
		INC !P2HP
	+	LDA #$01 : STA $73CE
		LDY #$25 : STY $7693
		LDA #$00 : XBA
		LDA #$00
		RTS

	YoshiCoin:
		.Lo
		PEA .GetBackLo-1
		LDA #$00 : PHA : PHA : PHA
		LDA #$02 : STA $9C
		LDY #$00			; Don't shatter block
		STZ $7C
		REP #$20
		JMP GENERATE_BLOCK_HorzLevel

		.GetBackLo
		JSR SET_GLITTER
		LDA $77C4,y
		SEC : SBC #$08
		STA $77C4,y
		LDA !RAM_ScreenMode
		LSR A
		LDA $98
		BCC .LoHorz

		.LoVert
		SEC : SBC #$10
		STA $98
		LDA $99
		XBA
		LDA $9B
		STA $99
		XBA
		SBC #$00
		STA $9B
		BRA .Shared

		.LoHorz
		SEC : SBC #$10
		STA $98
		LDA $99
		SBC #$00
		STA $99
		BRA .Shared

		.Hi
		PEA .GetBackHi-1
		LDA #$00 : PHA : PHA : PHA
		LDA #$02 : STA $9C
		LDY #$00			; Don't shatter block
		STZ $7C
		REP #$20
		JMP GENERATE_BLOCK_HorzLevel

		.GetBackHi
		JSR SET_GLITTER
		LDA $77C4,y
		CLC : ADC #$08
		STA $77C4,y
		LDA !RAM_ScreenMode
		LSR A
		LDA $98
		BCC .HiHorz

		.HiVert
		CLC : ADC #$10
		STA $98
		LDA $99
		XBA
		LDA $9B
		STA $99
		XBA
		ADC #$00
		STA $9B
		BRA .Shared

		.HiHorz
		CLC : ADC #$10
		STA $98
		LDA $99
		ADC #$00
		STA $99

		.Shared
		REP #$20
		LDA !YoshiCoinCount
		INC A
		STA !YoshiCoinCount
		SEP #$20
		LDA !CurrentPlayer		;\
		TAX				; | Increase coins (200)
		LDA !P1CoinIncrease,x		; |
		CLC : ADC #$C8			; |
		STA !P1CoinIncrease,x		;/
		PEA .Return-1
		LDA #$00 : PHA : PHA : PHA
		LDA #$02
		STA $9C
		STZ $7C
		JMP GENERATE_BLOCK_Short

		.Return
		LDA $78A7
		RTS

	Door:
		LDA !P2Blocked
		AND #$04
		BEQ .Return
		LDA $6DA7
		AND #$08
		BEQ .Return
		INC $741A
		REP #$20
		LDA !P2XPosLo : STA $94		;\ Player 1 coords
		LDA !P2YPosLo : STA $96		;/
		SEP #$20
		LDX #$06 : STX $71		; > $71 = 06
		STZ $88				; > Wipe $88-$89
		LDX #$0F : STX !SPC4		; > Door sound
		LDX #$0F : STX !GameMode
		LDX #$01 : STX $741D
		LDA $78A7

		.Return
		RTS


	Climb:
		CPY #$0A : BCS +
		LDA !P2YSpeed : BPL +

		LDA $785F : BMI ++

	+	LDA #$80 : STA $7860		; Climb is legal
	++	LDA $78A7
		RTS

		.XSpeed
		db $00,$10,$F0,$00		; 00-03
		db $00,$0B,$F5,$00		; 04-07
		db $00,$0B,$F5,$00		; 08-0B
		db $00,$10,$F0,$00		; 0C-0F

		.YSpeed
		db $00,$00,$00,$00		; 00-03
		db $10,$0B,$0B,$10		; 04-07
		db $F0,$F5,$F5,$F0		; 08-0B
		db $00,$00,$00,$00		; 0C-0F


		.Limit
		STZ !P2ClimbTop			; For Leeway, reset his get-up animation
		LDA $6DA3
		AND #$0F
		TAX
		LDA .XSpeed,x : STA !P2XSpeed
		BEQ ..Vert
		BPL ..Right

	..Left	LDA !P2Map16Table+6
		CMP #$07 : BEQ ..HorzL
		CMP #$0A : BEQ ..HorzL
		CMP #$0D : BNE ..Vert
	..HorzL	REP #$20
		LDA $0A
		AND #$FFF0
		CMP !P2XPosLo
		SEP #$20
		BCC ..Vert
		STA !P2XPosLo
		XBA : STA !P2XPosHi
		BRA ..Vert

	..Right	LDA !P2Map16Table+4
		CMP #$09 : BEQ ..HorzR
		CMP #$0C : BEQ ..HorzR
		CMP #$0F : BNE ..Vert
	..HorzR	REP #$20
		LDA $0A
		AND #$FFF0
		CMP !P2XPosLo
		SEP #$20
		BCS ..Vert
		STA !P2XPosLo
		XBA : STA !P2XPosHi

	..Vert	LDA .YSpeed,x : STA !P2YSpeed
		DEC A : BPL .Return
		LDA $7693
		CMP #$07 : BCC .Return
		CMP #$0A : BCS .Return
		REP #$20
		LDA $0C
		AND #$FFF0
		CLC : ADC #$000F
		CMP !P2YPosLo
		BCC $03 : STA !P2YPosLo
		SEP #$20

	.Return
		RTS






	WATER_SPLASH:			;CODE_0284C0:
		LDA !P2Offscreen
		BNE .NoSplash
		LDA !P2YPosLo			;\
		AND #$F0			; | Store modified Ypos
		CLC : ADC #$03			; |
		STA $00				;/
		LDY #$0B
	-	LDA $77F0,y
		BEQ .Spawn
		DEY
		BPL -
		RTS

		.Spawn
		LDA $00				;\ Ypos lo
		STA $77FC,y			;/
		LDA !P2YPosHi			;\ Ypos hi
		STA $7814,y			;/
		LDA !P2XPosLo			;\ Xpos lo
		STA $7808,y			;/
		LDA !P2XPosHi			;\ Xpos hi
		STA $78EA,y			;/
		LDA #$07 : STA $77F0,y
		LDA #$00 : STA $7850,y

		BIT !P2Water			;\ Only bubble when going in
		BVC .NoSplash			;/
		LDX #$04			; > Number of bubbles (-1)
		LDY #$08			; > Number of indexes
	-	DEY				;\
		BMI .NoSplash			; | Loop for slot
		LDA $770B,y			; |
		BNE -				;/
		LDA #$12 : STA $770B,y		;\
		LDA $00				; |
		CLC : ADC .Y,x			; |
		STA $7715,y			; |
		LDA !P2YPosHi			; |
		ADC #$00			; |
		STA $7729,y			; | Spawn bubble
		LDA !P2XPosLo			; |
		CLC : ADC .X,x			; |
		STA $771F,y			; |
		LDA !P2XPosHi			; |
		ADC #$00			; |
		STA $7733,y			; |
		LDA #$00 : STA $773D,y		; |
		LDA #$00 : STA $7747,y		;/
		DEX				;\ Loop for more bubbles
		BPL -				;/

		.NoSplash
		RTS

		.X
		db $00,$05,$08,$0B,$05

		.Y
		db $0D,$10,$13,$10,$16


	STEEPNESS:			;CODE_00FA19:
		LDY #$32 : STY $05		;\
		LDY #$E6 : STY $06		; | [$05] = $00E632
		LDY #$00 : STY $07		;/
		SEC : SBC #$6E
		TAY
		LDA [$82],y			; > How steep slopes are
		STA $08
		ASL #4
		STA $01
		BCC $02 : INC $06
		LDA $0C
		AND #$0F
		STA $00
		LDA $0A
		AND #$0F
		ORA $01
		TAY
		RTS
	; Let's see, what is Y?
	; It gets the lower 4 bits from Xpos within tile.
	; Upper 4 bits are the low nybble of [$82], indexed by [tilenum]-0x16E.
	; 


	STEEP_SLOPE:			;CODE_03C1CA:
		LDY #$00
		LDA !P2Slope
		BPL $02 : LDY #$02
		REP #$20
		LDA !P2XPosLo
		CLC : ADC .Table,y
		STA !P2XPosLo
		SEP #$20
		LDA #$18 : STA !P2YSpeed
		RTS

		.Table
		dw $0002,$FFFE


;==============;
;GENERATE_BLOCK;
;==============;
; --Input--
; Y = Shatter brick flag (00 does nothing, 01-FF runs the shatter brick routine)
; $00 = Object to spawn from block.
; $0A = 16-bit X offset
; $0C = 16-bit Y offset
; $7C = Bounce sprite to spawn.
; $9C = Block to generate.

	GENERATE_BLOCK:
		LDA $7695 : PHA
		LDA $00				;\ Preserve object to spawn from block
		PHA				;/
		PHY				; Preserve shatter brick flag
		REP #$20			;\ > A 16-bit

		LDA !RAM_ScreenMode
		LSR A
		BCC .HorzLevel

		.VertLevel
		SEP #$20
		LDA $0A
		AND #$F0
		STA $9A
		LDA $0B
		STA $99
		LDA $0C
		AND #$F0
		STA $98
		LDA $0D
		STA $9B
		BRA .Short

		.HorzLevel
		LDA $0A				; |
		AND #$FFF0			; |> Ignore lowest nybble
		STA $9A				; |
		LDA $0C				; |
		AND #$FFF0			; |> Ignore lowest nybble
		STA $98				;/
		SEP #$20			; > A 8-bit

		.Short
		LDA $9C
		BEQ .Shatter

		JSL $00BEB0

		.Shatter
		PLA				; Restore shatter brick flag
		BEQ .Bounce
		PHB				;\
		LDA #$02			; |
		PHA				; | Bank wrapper
		PLB				; |
		LDA #$00			; |> Normal shatter (01 will spawn rainbow brick pieces)
		JSL $028663			; |> Shatter Block
		PLB				;/

		.Bounce
		LDA $7C
		BEQ .Object
		JSR BOUNCE_SPRITE		; Spawn bounce sprite of type $7C at ($98;$9A)

		.Object
		PLA
		BEQ .Return
		STA $05
		CMP #$06 : BEQ ..Owner
		CMP #$07 : BNE ..NoOwner

		..Owner
		LDA !CurrentPlayer
		INC A
		STA !CoinOwner
		..NoOwner

		REP #$20
		AND #$00FF
		CMP #$0008 : BEQ ++		;\
		CMP #$000A : BEQ ++		; |
		CMP #$000B : BEQ ++		; |
		CMP #$000D : BEQ ++		; | Some objects are spawned higher
		CMP #$000F : BNE +		; |
	++	LDA $98				; |
		SEC : SBC #$000D		; |
		BRA ++				;/
	+	LDA $98
		CLC : ADC #$0003
	++	STA $98
		SEP #$20
		LDA $9A
		AND #$F0
		STA $9A

		PHB				;\
		LDA #$02			; |
		PHA				; | Bank wrapper
		PLB				; |
		JSL $02887D			; |> Spawn object
		PLB				;/

		.Return
		PLA : STA $7695
		RTS

;===================;
;SPAWN BOUNCE SPRITE;
;===================;
; --Input--
; Load $00 with bounce sprite number
; Load $01 with tile bounce sprite should turn into (uses $009C values)
; Load $02 with 16 bit X offset
; Load $04 with 16 bit Y offset
; Load $06 with bounce sprite timer (how many frames it will exist)
; Bounce sprite of type $7C will be spawned at ($98;$9A) and will turn into $9C

BOUNCE_SPRITE:

		LDY #$03			; Highest bounce sprite index

		.Loop
		LDA $7699,y			;\
		BEQ .Spawn			; |
		DEY				; | Get bounce sprite number
		BPL .Loop			; |
		RTS				;/

		.Spawn
		STA $769D,y			; > INIT routine
		STA $76C9,y			; > Layer 1, going up
		STA $76B5,y			; > X speed
		LDA #$C0			;\ Y speed
		STA $76B1,y			;/
		LDA #$08			;\ How many frames bounce sprite will exist
		STA $76C5,y			;/
		LDA #$01 : STA $76CD,y		;\ Bounce sprite can interact
		LDA #$06 : STA $78F8,y		;/
		LDA $9C				;\ Map16 tile bounce sprite should turn into
		STA $76C1,y			;/
		LDA $7C				;\ Bounce sprite number
		STA $7699,y			;/
		CMP #$07			;\
		BNE .Process			; |
		LDA #$FF			; | Set turn block timer if spawning a turn block
		STA $78CE,y			;/

		.Process
		LDA $9A
		STA $76A5,y
		STA $76D1,y
		LDA $9B
		STA $76AD,y
		STA $76D5,y
		LDA $98
		STA $76A1,y
		STA $76D9,y
		LDA $99
		STA $76A9,y
		STA $76DD,y

		.Return
		RTS				; Return





