

	!SnowBase	= !3D_Base+$480

	!SnowXLo	= !SnowBase+$000	;
	!SnowXHi	= !SnowBase+$001	;
	!SnowX		= !SnowXLo
	!SnowYLo	= !SnowBase+$060
	!SnowYHi	= !SnowBase+$061
	!SnowY		= !SnowYLo
	!SnowXSpeed	= !SnowBase+$0C0	; amount to add to packed X coordinate every frame
	!SnowYSpeed	= !SnowBase+$0C1	; amount to add to packed Y coordinate every frame
	!SnowXAccel	= !SnowBase+$120	; amount to add to X speed every frame
	!SnowYAccel	= !SnowBase+$121	; amount to add to Y speed every frame

	!SnowRNG	= !SnowBase+$180

	!SnowSpawned	= !SnowBase+$280	; used to determine when to spawn the next particle

	!SnowXFrac	= !SnowBase+$282
	!SnowYFrac	= !SnowBase+$283

	!WeatherType	= !SnowBase+$2E2	; 0 = calm snow
						; 1 = raging snow
						; 2 = spell particles
						; 3 = special effect for Evernight Temple
						; 4 = special effect for Lava Lord boss

	!WeatherIndex	= !SnowBase+$2E3
	!WeatherFreq	= !SnowBase+$2E4	; number of frames to wait until next particle is spawned


Weather:
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JMP $1E80

		.LoadSnow
		STA $00					; store snow type
		JSL !GetVRAM
		REP #$20
		LDA #$0020 : STA.l !VRAMbase+!VRAMtable+$00,x
		LDY $00
		LDA.w .Data,y : STA.l !VRAMbase+!VRAMtable+$02,x
		LDA #$3131 : STA.l !VRAMbase+!VRAMtable+$04,x
		LDA #$7FF0 : STA.l !VRAMbase+!VRAMtable+$05,x
		SEP #$20


		.ResetTable
		LDX #$5F				; reset data so it will work on screen 0/0
		LDA.b #$55
	-	STA.l !SnowX,x
		STA.l !SnowY,x
		STA.l !SnowXSpeed,x
		STA.l !SnowXAccel,x
		DEX : BPL -
		RTS

		.Data
		dw $ECE0,$EEE0


		.SA1
		PHP
		SEP #$30
		LDA !Pause : BEQ .NoPause
		PLP
		RTL


		.NoPause
		PHB
		LDA.b #!SnowBase>>16
		PHA : PLB

		STZ.w !SnowSpawned+1
		LDA.w !SnowSpawned
		BEQ $03 : DEC.w !SnowSpawned

		LDY $14
		LDA.l !RNG : STA.w !SnowRNG,y

		REP #$20
		LDX #$5E
	.Loop	LDA.w !SnowX,x
		SEC : SBC $1A
		CMP #$0100 : BCC .GoodX
		CMP #$FFF8 : BCS .GoodX
		CMP #$0180 : BCS .Spawn
	-	JMP .Process

	.Spawn	LDA.w !SnowSpawned : BNE -
		LDA.w !WeatherFreq		;\
		AND #$00FF			; | spawn timer for next particle
		STA.w !SnowSpawned		;/
		LDY $14
		CPY #$FC
		BCC $02 : LDY #$00
		STX.w !WeatherIndex
		LDA.w !WeatherType
		AND #$00FF
		ASL A
		TAX
		JSR (.SpawnPtr,x)
		JMP .Next

	.GoodX	CMP #$0100
		BCC $03 : ORA #$0100
		AND #$01FF
		STA $00				; OAM X (includes hi bit)
		LDA.w !SnowY,x
		SEC : SBC $1C
		CMP #$00D8 : BCC .GoodY
		CMP #$FFF8 : BCS .GoodY
		CMP #$FF80 : BCS .Process
		JMP .Spawn

	.GoodY	PHX
		SEP #$20
		XBA
		LDA.l !OAMindex : TAX
		CLC : ADC #$04
		STA.l !OAMindex
		XBA
		STA.l !OAM+1,x
		LDA $00 : STA.l !OAM+0,x
		LDA.w !WeatherType
		CMP #$02 : BEQ ++
		CMP #$03 : BNE +
	++	LDA #$4D
		CLC : ADC.l !GFX_status+$0C
		BRA ++
	+	LDA #$FF
	++	STA.l !OAM+2,x
		LDA #$3D : STA.l !OAM+3,x
		TXA
		LSR #2
		TAX
		LDA.w !WeatherType
		CMP #$02 : BEQ ++
		CMP #$03 : BNE +
		LDA #$02
	++	ORA $01
		BRA ++
	+	LDA $01
	++	STA.l !OAMhi,x
		PLX

	.Process
		SEP #$20
		LDA.w !SnowXSpeed,x
		ASL #4
		CLC : ADC.w !SnowXFrac,x
		STA.w !SnowXFrac,x
		PHP
		LDY #$00
		LDA.w !SnowXSpeed,x
		LSR #4
		CMP #$08 : BCC +
		ORA #$F0
		DEY
	+	PLP
		ADC.w !SnowXLo,x : STA.w !SnowXLo,x
		TYA
		ADC.w !SnowXHi,x : STA.w !SnowXHi,x
		LDA.w !SnowYSpeed,x
		ASL #4
		CLC : ADC.w !SnowYFrac,x
		STA.w !SnowYFrac,x
		PHP
		LDY #$00
		LDA.w !SnowYSpeed,x
		LSR #4
		CMP #$08 : BCC +
		ORA #$F0
		DEY
	+	PLP
		ADC.w !SnowYLo,x : STA.w !SnowYLo,x
		TYA
		ADC.w !SnowYHi,x : STA.w !SnowYHi,x

		LDA $14
		AND #$07 : BNE +
		LDA.w !SnowXSpeed,x
		CLC : ADC.w !SnowXAccel,x
		STA.w !SnowXSpeed,x
		LDA.w !SnowYSpeed,x
		CLC : ADC.w !SnowYAccel,x
		STA.w !SnowYSpeed,x

	+	REP #$20

		LDY.w !WeatherType
		CPY #$03 : BNE $03 : JSR .MaskBox


	.Next	DEX #2
		BMI .Done
		JMP .Loop

	.Done	PLB
		PLP
		RTL


		.SpawnPtr
		dw .CalmSnow
		dw .RagingSnow
		dw .SpellParticles		; this one can also be used for lava
		dw .MaskSpecial
		dw .LavaLord			; special one to be used for Lava Lord boss


		.CalmSnow
		LDX.w !WeatherIndex
		LDA.w !SnowRNG+0,y
		AND #$00FF
		ASL A
		CLC : ADC $1A
		SEC : SBC #$0080
		STA.w !SnowX,x
		LDA $1C
		SEC : SBC #$0008
		STA.w !SnowY,x
		LDA #$1000 : STA.w !SnowXSpeed,x
		STZ.w !SnowXAccel,x
		RTS


		.RagingSnow
		LDX.w !WeatherIndex
		LDA.w !SnowRNG+0,y
		AND #$00FF
		LSR A
		ORA #$0100
		CLC : ADC $1A
		STA.w !SnowX,x
		LDA.w !SnowRNG+1,y
		AND #$00FF
		STA $00
		LSR #2
		SEC : SBC $00
		EOR #$FFFF : INC A
		CLC : ADC $1C
		SEC : SBC #$0080
		STA.w !SnowY,x
		SEP #$20
		LDA.w !SnowRNG+2,y
		AND #$3F
		CMP #$20
		BCC $02 : LDA #$20
		SEC : SBC #$40
		STA.w !SnowXSpeed,x
		LDA.w !SnowRNG+3,y
		AND #$10
		CLC : ADC #$10
		STA.w !SnowYSpeed,x

		LDA.w !SnowXSpeed,x
		CMP #$E0 : BCS ++
		LDA.w !SnowYLo,x
		SEC : SBC $1C
		BMI +
	++	LDA #$00 : BRA ++
	+	LDA.w !SnowRNG+3,y
		AND #$01
		DEC A
	++	STA.w !SnowYAccel,x
		STZ.w !SnowXAccel,x
		REP #$20
		RTS


		.SpellParticles
		LDX.w !WeatherIndex
		LDA.w !SnowRNG+0,y
		AND #$00FF
		ASL #2
		CLC : ADC $1A
		SEC : SBC #$0180
		CMP #$0300 : BCC ..R
		STA.w !SnowX,x
		LDA $1C
		CLC : ADC #$00D8
		STA.w !SnowY,x
		SEP #$20
		LDA.w !SnowRNG+1,y
		AND #$0F
		SEC : SBC #$08
		STA.w !SnowXSpeed,x
		LDA.w !SnowRNG+2,y
		AND #$0F
		ADC #$E8
		STA.w !SnowYSpeed,x
		LDA.w !SnowRNG+3,y
		AND #$01
		ASL A
		DEC A
		STA.w !SnowXAccel,x
		LDA.w !SnowRNG+3,y
		AND #$02
		DEC A
		STA.w !SnowYAccel,x
		REP #$20
	..R	RTS


		.MaskSpecial
		LDX.w !WeatherIndex
		STZ $00
		LDA.w !SnowRNG+0,y
		AND #$0001 : BEQ ..R
	..L	LDA.l !Level+2
		AND #$0001 : BEQ ..Return
		LDA #$0C60 : STA.w !SnowX,x
		DEC $00
		BRA +
	..R	LDA.l !Level+2
		AND #$0002 : BEQ ..Return
		LDA #$0C90 : STA.w !SnowX,x
	+	LDA #$0148 : STA.w !SnowY,x

		LDA.w !SnowRNG+1,y
		AND #$0006
		PHX
		TAX
		LDA.l ..SpeedTable,x : STA $02
		LDA.l ..AccelTable,x
		PLX
		SEP #$20
		BIT $00
		BPL $03 : EOR #$FF : INC A
		REP #$20
		STA.w !SnowXAccel,x
		LDA $02
		SEP #$20
		BIT $00
		BPL $03 : EOR #$FF : INC A
		REP #$20
		STA.w !SnowXSpeed,x
	..Return
		RTS



	..SpeedTable
	db $00,$F0
	db $FA,$FC
	db $F8,$F0
	db $FB,$00

	..AccelTable
	db $FF,$01
	db $FF,$FC
	db $00,$00
	db $00,$FD


		.MaskBox
		LDA.w !SnowX,x
		CMP #$0C72 : BCC ..R
		CMP #$0C7E : BCS ..R
		LDA.w !SnowY,x
		CMP #$0110 : BCC ..R
		CMP #$0118 : BCS ..R
		STZ.w !SnowX,x
		STZ.w !SnowY,x
	..R	RTS



		.LavaLord
		PHP
		SEP #$20
		LDX #$0F
	-	LDA.l $3230,x
		CMP #$08 : BNE +
		LDA.l $3590,x
		AND #$08 : BEQ +
		LDA.l $35C0,x
		CMP #$20 : BEQ ++
	+	DEX : BPL -
		PLP
		RTS

	++	LDA.l $3220,x : STA $00
		LDA.l $3250,x : STA $01
		LDA.l $3240,x : XBA
		LDA.l $3210,x


		PLP
		LDX.w !WeatherIndex
		STA.w !SnowY,x
		LDA $00 : STA.w !SnowX,x
		LDA.w !SnowRNG+0,y
		AND #$0003
		XBA
		STA.w !SnowXAccel,x			; X acc = 0, Y acc = 0-3

		LDA.w !SnowRNG+0,y
		AND #$00FC
		LSR #2
		SEC : SBC #$0020
		AND #$00FF
		ORA #$E000
		STA.w !SnowXSpeed,x			; X speed = -20-20, Y speed = -20
		RTS



; set 16-bit A to GFX number, then call this
DecompressGFX:
		LDX.b #!GFX_buffer : STX $00
		LDX.b #!GFX_buffer>>8 : STX $01
		LDX.b #!GFX_buffer>>16 : STX $02
		JSL $0FF900
		RTS



; set 16-bit A to dest VRAM, then call this (source should be in $00-$02, so call after DecompressGFX)
; set 8-bit X to source tile
; set 8-bit Y to upload size (number of 8x8 tiles)
UploadDecomp:
		STA $03
		STX $05
		JSL !GetVRAM
		LDA $02 : STA.l !VRAMbase+!VRAMtable+$04,x
		LDA $05
		AND #$00FF
		ASL #5
		CLC : ADC $00
		STA.l !VRAMbase+!VRAMtable+$02,x
		LDA $03 : STA.l !VRAMbase+!VRAMtable+$05,x
		TYA
		ASL #5
		STA.l !VRAMbase+!VRAMtable+$00,x
		RTS



macro CameraBox(X, Y, W, H, S, FX, FY)
	dw <X>*$100
	dw <Y>*$E0
	dw (<X>+<W>)*$100
	dw (<Y>+<H>)*$E0
	dw <S>|(<FX><<6)|(<FY><<11)
endmacro

macro Door(x, y)
	db <x>|(<y><<4)
endmacro


LoadCameraBox:
		STA $00
		LDA.w #.SA1 : STA $3180
		LDA.w #.SA1>>8 : STA $3181
		SEP #$20
		JMP $1E80

		.SA1
		PHB : PHK : PLB
		PHP
		REP #$20

		LDX #$06				;\ get main pointers:
	-	TXY					; |	$08 = screen matrix
		LDA ($00),y : STA $08,x			; |	$0A = box table
		DEX #2					; |	$0C = door list
		BPL -					; |	$0E = door table
		SEP #$20				;/

		LDA !CameraForceTimer : BEQ .NoTransition
		LDA !CameraForceDir
		CMP #$04 : BCS .NoTransition
		EOR #$02
		ASL #2
		STA $00
		ASL #2
		CLC : ADC $00
		ASL A
		SEC : SBC #$28
		STA $00
		SEC : SBC !P2XSpeed-$80
		STA !P2VectorX-$80
		LDA $00
		SEC : SBC !P2XSpeed
		STA !P2VectorX
		STZ !P2VectorAccX-$80
		STZ !P2VectorAccX
		.NoTransition




		REP #$20
		LDX #$00
		LDA !P2XPosLo-$80 : STA $00
		LDA !P2YPosLo-$80 : STA $02
		LDA !MultiPlayer
		AND #$00FF
		BEQ $02 : LDX #$80
		LDA !P2XPosLo-$80,x
		CLC : ADC $00
		LSR A
		XBA
		AND #$0007
		STA $00

		LDA !P2YPosLo-$80,x
		CLC : ADC $02
		LSR A
		CMP !LevelHeight
		BCC $04 : LDA !LevelHeight : DEC A
		LDX #$00
	-	CMP #$00E0 : BCC +
		SBC #$00E0
		INX
		BRA -
		+

		LDA #$FFF8
	-	CLC : ADC #$0008
		DEX : BPL -
		ORA $00
		TAY
		LDA ($08),y
		AND #$00FF
		STA !BigRAM+0

	; door loader

		PEI ($0A)
		PHP
		SEP #$20
		LDA !CameraForceTimer : BEQ $03 : JMP .NoDoor
		STZ $00
		LDY #$00
	--	LDA ($0C),y : BPL +
		JMP .NextIndex

	+
	-	LDX $00
		CPX !BigRAM+0 : BNE .NextDoor
		TYX
		TAY
		LDA $00 : PHA
		PEI ($0C)
		PEI ($0E)
		REP #$20
		LDA ($0E),y
		AND #$000F
		XBA
		SEC : SBC #$0018
		STA $04
		STA $09
		LDA ($0E),y
		AND #$00F0
		STA $00
		ASL #3
		SEC : SBC $00
		ASL A
		CLC : ADC #$00A0
		STA $05
		XBA
		STA $0B
		SEP #$20
		LDA #$30 : STA $06
		LDA #$30 : STA $07
		SEC : JSL !PlayerClipping
		TXY
		REP #$20
		PLA : STA $0E
		PLA : STA $0C
		SEP #$20
		PLA : STA $00
		BCC .NextDoor

		LDA $1B
		CMP $0A
		BEQ .Right
		BCS .Left
	.Right	LDA #$00 : BRA +
	.Left	LDA #$02
	+	STA !CameraForceDir
		LDA #$20
		STA !CameraForceTimer
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX
		JSR .CameraChain
		BRA .NoDoor

	.NextDoor
		INY
		LDA ($0C),y
		BMI .NextIndex
		JMP -

	.NextIndex
		INY
		INC $00
		LDA $00
		CMP !BigRAM+0
		BCC +
		BNE .NoDoor
	+	JMP --


	.NoDoor
		PLP
		PLA : STA $0A


	; camera box

		LDA !BigRAM+0
		ASL A
		STA $00
		ASL #2
		CLC : ADC $00
		STA $00					; index in $00
		TAY
		LDX #$00

		LDA !LevelInitFlag			;\ don't do the update during level init
		AND #$00FF : BEQ .Old			;/

	-	LDA ($0A),y
		CMP !CameraBoxL,x
		BNE .New
		INX #2
		INY #2
		CPX #$08 : BNE -

	.Old	JSR .Load

		PLP
		PLB
		RTL


	.New	LDY #$0F
	-	LDX $3220,y : STX $02
		LDX $3250,y : STX $03
		LDX $3210,y : STX $04
		LDX $3240,y : STX $05
		LDX #$02
	--	LDA $02,x
		CMP !CameraBoxL,x : BCC ..Next
		SBC .Offset,x
		CMP !CameraBoxR,x : BCS ..Next

	..Erase	LDA $3230,y
		AND #$FF00
		STA $3230,y
		PHX
		LDX $33F0,y
		LDA $418A00,x
		AND #$00FF
		CMP #$00EE : BEQ +
		LDA $418A00,x
		AND #$FF00
		STA $418A00,x
	+	PLX

	..Next	DEX #2 : BPL --
		DEY : BPL -

		JSR .Load

		LDA !CameraForceTimer : BNE .End		; checks both slots

		LDA !CameraBackupY
		AND #$FFF8 : STA !CameraBackupY
		CMP !CameraBoxU : BEQ .X : BCC .Down
		CMP !CameraBoxD : BEQ .X : BCC .X

	.Up	SBC !CameraBoxD
		LSR #3
		SEP #$20
		STA !CameraForceTimer
		LDA #$06 : STA !CameraForceDir
		BRA .X

	.Down	SEC : SBC !CameraBoxU
		EOR #$FFFF : INC A
		LSR #3
		SEP #$20
		STA !CameraForceTimer
		LDA #$04 : STA !CameraForceDir

	.X	REP #$20
		LDA !CameraBackupX
		AND #$FFF8 : STA !CameraBackupX
		CMP !CameraBoxL : BEQ .End : BCC .R2
		CMP !CameraBoxR : BEQ .End : BCC .End

	.L2	SBC !CameraBoxR
		LSR #3
		SEP #$20
		STA !CameraForceTimer+1
		LDA #$02 : STA !CameraForceDir+1
		BRA .End

	.R2	SEC : SBC !CameraBoxL
		EOR #$FFFF : INC A
		LSR #3
		SEP #$20
		STA !CameraForceTimer+1
		STZ !CameraForceDir+1


	.End	PLP
		PLB
		RTL





	.Offset	dw $0100,$00E0




	.Load
		LDY $00					;\ reset index
		LDX #$00				;/
	-	LDA ($0A),y : STA !CameraBoxL,x
		INX #2
		INY #2
		CPX #$08 : BNE -
		LDA ($0A),y : STA !CameraForbiddance
		RTS


; figure out which $E0 block the door is on vertically, then chain to that

	.CameraChain
		LDY.b #.ScreensEnd-.VerticalScreens-2
		LDA $0B : XBA
		LDA $05
		REP #$20
	-	CMP .VerticalScreens,y : BCS +
		DEY #2 : BPL -
		RTS

	+	LDA .VerticalScreens,y
		SEC : SBC !CameraBackupY
		STA $02
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0008 : BCS +
		LDA .VerticalScreens,y : STA !CameraBackupY
		RTS

	+	LDA $02
		SEP #$20
		BPL ..D

	..U	EOR #$FF : INC A
		LDY #$06 : BRA +
	..D	LDY #$04
	+	STY !CameraForceDir+1
		LSR #3
		STA !CameraForceTimer+1
		STA !P2Stasis-$80
		STA !P2Stasis
		RTS


		.VerticalScreens
		dw $0000,$00E0,$01C0,$02A0,$0380,$0460,$0540,$0620
		dw $0700,$07E0,$08C0,$09A0,$0A80,$0B60,$0C40,$0D20
		.ScreensEnd




InitCameraBox:
		PHP
		REP #$20
		LDA !CameraBoxL
		CMP $1A : BCS .WriteX
		LDA !CameraBoxR
		CMP $1A : BCS .NoX
	.WriteX	STA $1A
		STA !CameraBackupX
		.NoX

		LDA !CameraBoxU
		CMP $1C : BCS .WriteY
		LDA !CameraBoxD
		CMP $1C : BCS .NoY
	.WriteY	STA $1C
		STA !CameraBackupY
		.NoY


		LDA $1C
		AND #$FFF0
		STA $00
		LDA #$0000
		LDY $1B : BEQ +
	-	CLC : ADC !LevelHeight
		DEY : BNE -
		+

		CLC : ADC $00
		STA $00
		SEP #$20
		LDX $00
		LDY $01
		JSR LoadScreen

		PHB
		LDA.b #!VRAMbank
		PHA : PLB


		REP #$20
		LDA $1C
		AND #$00FF
		ASL #2
		CLC : ADC !VRAMtable+$05,x
		SEC : SBC #$0400
		STA !VRAMtable+$05,x
		SEC : SBC #$3000
		BEQ .Done

		ASL A
		STA !VRAMtable+$07,x
		SEC : SBC #$0800
		EOR #$FFFF : INC A
		STA !VRAMtable+$00,x
		CLC : ADC !VRAMtable+$02,x
		STA !VRAMtable+$09,x
		LDA !VRAMtable+$04,x : STA !VRAMtable+$0B,x
		LDA #$3000 : STA !VRAMtable+$0C,x



	.Done	PLB

		INC !SmoothCamera
		PLP
		RTS






; --Level INIT--

levelinit0:
		INC !SideExit
		RTS
levelinit16:
	RTS
levelinit17:
	RTS
levelinit18:
	RTS
levelinit19:
	RTS
levelinit1A:
	RTS
levelinit1B:
	RTS
levelinit1C:
	RTS
levelinit1D:
	RTS
levelinit1E:
	RTS
levelinit1F:
	RTS
levelinit20:
	RTS
levelinit21:
	RTS
levelinit22:
	RTS
levelinit23:
	RTS
levelinit24:
	RTS

levelinit25:

		JSR CLEAR_DYNAMIC_BG3

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80

		STZ $43

		REP #$20
		LDA #$7000 : STA.l $400000+!MsgVRAM1
		LDA #$7080 : STA.l $400000+!MsgVRAM2
		LDA #$7200 : STA.l $400000+!MsgVRAM3

		SEP #$20


		LDA.b #.NPC_table : STA !NPC_ID
		LDA.b #.NPC_table>>8 : STA !NPC_ID+1
		LDA.b #.NPC_table>>16 : STA !NPC_ID+2
		RTS

	.NPC_table
	db $01



		.SA1
		PHP
		SEP #$30
		LDA !Characters
		LSR #4
		TAX					; portrait
		LDY #$C1				; palette
		LDA #$76				; VRAM
		JSL !LoadPortrait
		PLP
		RTL



levelinit33:
	RTS




levelinit38:
	RTS
levelinit39:
	RTS
levelinit3A:
	RTS
levelinit3B:
	RTS
levelinit3C:
	RTS
levelinit3D:
	RTS
levelinit3E:
	RTS
levelinit3F:
	RTS
levelinit40:
	RTS
levelinit41:
	RTS
levelinit42:
	RTS
levelinit43:
	RTS
levelinit44:
	RTS
levelinit45:
	RTS
levelinit46:
	RTS
levelinit47:
	RTS
levelinit48:
	RTS
levelinit49:
	RTS
levelinit4A:
	RTS
levelinit4B:
	RTS
levelinit4C:
	RTS
levelinit4D:
	RTS
levelinit4E:
	RTS
levelinit4F:
	RTS
levelinit50:
	RTS
levelinit51:
	RTS
levelinit52:
	RTS
levelinit53:
	RTS
levelinit54:
	RTS
levelinit55:
	RTS
levelinit56:
	RTS
levelinit57:
	RTS
levelinit58:
	RTS
levelinit59:
	RTS
levelinit5A:
	RTS
levelinit5B:
	RTS
levelinit5C:
	RTS
levelinit5D:
	RTS
levelinit5E:
	RTS
levelinit5F:
	RTS
levelinit60:
	RTS
levelinit61:
	RTS
levelinit62:
	RTS
levelinit63:
	RTS
levelinit64:
	RTS
levelinit65:
	RTS
levelinit66:
	RTS
levelinit67:
	RTS
levelinit68:
	RTS
levelinit69:
	RTS
levelinit6A:
	RTS
levelinit6B:
	RTS
levelinit6C:
	RTS
levelinit6D:
	RTS
levelinit6E:
	RTS
levelinit6F:
	RTS
levelinit70:
	RTS
levelinit71:
	RTS
levelinit72:
	RTS
levelinit73:
	RTS
levelinit74:
	RTS
levelinit75:
	RTS
levelinit76:
	RTS
levelinit77:
	RTS
levelinit78:
	RTS
levelinit79:
	RTS
levelinit7A:
	RTS
levelinit7B:
	RTS
levelinit7C:
	RTS
levelinit7D:
	RTS
levelinit7E:
	RTS
levelinit7F:
	RTS
levelinit80:
	RTS
levelinit81:
	RTS
levelinit82:
	RTS
levelinit83:
	RTS
levelinit84:
	RTS
levelinit85:
	RTS
levelinit86:
	RTS
levelinit87:
	RTS
levelinit88:
	RTS
levelinit89:
	RTS
levelinit8A:
	RTS
levelinit8B:
	RTS
levelinit8C:
	RTS
levelinit8D:
	RTS
levelinit8E:
	RTS
levelinit8F:
	RTS
levelinit90:
	RTS
levelinit91:
	RTS
levelinit92:
	RTS
levelinit93:
	RTS
levelinit94:
	RTS
levelinit95:
	RTS
levelinit96:
	RTS
levelinit97:
	RTS
levelinit98:
	RTS
levelinit99:
	RTS
levelinit9A:
	RTS
levelinit9B:
	RTS
levelinit9C:
	RTS
levelinit9D:
	RTS
levelinit9E:
	RTS
levelinit9F:
	RTS
levelinitA0:
	RTS
levelinitA1:
	RTS
levelinitA2:
	RTS
levelinitA3:
	RTS
levelinitA4:
	RTS
levelinitA5:
	RTS
levelinitA6:
	RTS
levelinitA7:
	RTS
levelinitA8:
	RTS
levelinitA9:
	RTS
levelinitAA:
	RTS
levelinitAB:
	RTS
levelinitAC:
	RTS
levelinitAD:
	RTS
levelinitAE:
	RTS
levelinitAF:
	RTS
levelinitB0:
	RTS
levelinitB1:
	RTS
levelinitB2:
	RTS
levelinitB3:
	RTS
levelinitB4:
	RTS
levelinitB5:
	RTS
levelinitB6:
	RTS
levelinitB7:
	RTS
levelinitB8:
	RTS
levelinitB9:
	RTS
levelinitBA:
	RTS
levelinitBB:
	RTS
levelinitBC:
	RTS
levelinitBD:
	RTS
levelinitBE:
	RTS
levelinitBF:
	RTS
levelinitC0:
	RTS
levelinitC1:
	RTS
levelinitC2:
	RTS
levelinitC3:
	RTS
levelinitC4:
	RTS
levelinitC5:
		LDA #$01			;\ Prevent camera from scrolling
		STA $5E				;/
		RTS				; > Return
levelinitC6:
	RTS
levelinitC7:
	pushpc
	org $0096C6
		LDA #$2A			; title screen music
	org $009C77
		NOP #6				; remove title screen movements
	org $0093A4
		LDA #$F0			; remove "Nintendo Presents"
	org $0093C0
		LDA #$2A			; first sound
		STA !SPC3

	pullpc
		RTS

levelinitC8:
	RTS
levelinitC9:
	RTS
levelinitCA:
	RTS
levelinitCB:
	RTS
levelinitCC:
	RTS
levelinitCD:
	RTS
levelinitCE:
	RTS
levelinitCF:
	RTS
levelinitD0:
	RTS
levelinitD1:
	RTS
levelinitD2:
	RTS
levelinitD3:
	RTS
levelinitD4:
	RTS
levelinitD5:
	RTS
levelinitD6:
	RTS
levelinitD7:
	RTS
levelinitD8:
	RTS
levelinitD9:
	RTS
levelinitDA:
	RTS
levelinitDB:
	RTS
levelinitDC:
	RTS
levelinitDD:
	RTS
levelinitDE:
	RTS
levelinitDF:
	RTS
levelinitE0:
	RTS
levelinitE1:
	RTS
levelinitE2:
	RTS
levelinitE3:
	RTS
levelinitE4:
	RTS
levelinitE5:
	RTS
levelinitE6:
	RTS
levelinitE7:
	RTS
levelinitE8:
	RTS
levelinitE9:
	RTS
levelinitEA:
	RTS
levelinitEB:
	RTS
levelinitEC:
	RTS
levelinitED:
	RTS
levelinitEE:
	RTS
levelinitEF:
	RTS
levelinitF0:
	RTS
levelinitF1:
	RTS
levelinitF2:
	RTS
levelinitF3:
	RTS
levelinitF4:
	RTS
levelinitF5:
	RTS
levelinitF6:
	RTS
levelinitF7:
	RTS
levelinitF8:
	RTS
levelinitF9:
	RTS
levelinitFA:
	RTS
levelinitFB:
	RTS
levelinitFC:
	RTS
levelinitFD:
	RTS
levelinitFE:
	RTS
levelinitFF:
	RTS
levelinit100:
	RTS
levelinit101:
	RTS
levelinit102:
	RTS
levelinit103:
	RTS
levelinit104:
	RTS
levelinit105:
	RTS
levelinit106:
	RTS
levelinit107:
	RTS
levelinit108:
	RTS
levelinit109:
	RTS
levelinit10A:
	RTS
levelinit10B:
	RTS
levelinit10C:
		JMP levelinit0
		RTS


levelinit10D:
	RTS
levelinit10E:
	RTS
levelinit10F:
	RTS
levelinit110:
	RTS
levelinit111:
	RTS
levelinit112:
	RTS
levelinit113:
	RTS
levelinit114:
	RTS
levelinit115:
	RTS
levelinit116:
	RTS
levelinit117:
	RTS
levelinit118:
	RTS
levelinit119:
	RTS
levelinit11A:
	RTS
levelinit11B:
	RTS
levelinit11C:
	RTS
levelinit11D:
	RTS
levelinit11E:
	RTS
levelinit11F:
	RTS
levelinit120:
	RTS
levelinit121:
	RTS
levelinit122:
	RTS
levelinit123:
	RTS
levelinit124:
	RTS
levelinit125:
	RTS
levelinit126:
	RTS
levelinit127:
	RTS
levelinit128:
	RTS
levelinit129:
	RTS
levelinit12A:
	RTS
levelinit12B:
	RTS
levelinit12C:
	RTS
levelinit12D:
	RTS
levelinit12E:
	RTS
levelinit12F:
	RTS
levelinit130:
	RTS
levelinit131:
	RTS
levelinit132:
	RTS
levelinit133:
	RTS
levelinit134:
	RTS
levelinit135:
	RTS
levelinit136:
	RTS
levelinit137:
	RTS
levelinit138:
	RTS
levelinit139:
	RTS
levelinit13A:
	RTS
levelinit13B:
	RTS
levelinit13C:
	RTS
levelinit13D:
	RTS
levelinit13E:
	RTS
levelinit13F:
	RTS
levelinit140:
	RTS
levelinit141:
	RTS
levelinit142:
	RTS
levelinit143:
	RTS
levelinit144:
	RTS
levelinit145:
	RTS
levelinit146:
	RTS
levelinit147:
	RTS
levelinit148:
	RTS
levelinit149:
	RTS
levelinit14A:
	RTS
levelinit14B:
	RTS
levelinit14C:
	RTS
levelinit14D:
	RTS
levelinit14E:
	RTS
levelinit14F:
	RTS
levelinit150:
	RTS
levelinit151:
	RTS
levelinit152:
	RTS
levelinit153:
	RTS
levelinit154:
	RTS
levelinit155:
	RTS
levelinit156:
	RTS
levelinit157:
	RTS
levelinit158:
	RTS
levelinit159:
	RTS
levelinit15A:
	RTS
levelinit15B:
	RTS
levelinit15C:
	RTS
levelinit15D:
	RTS
levelinit15E:
	RTS
levelinit15F:
	RTS
levelinit160:
	RTS
levelinit161:
	RTS
levelinit162:
	RTS
levelinit163:
	RTS
levelinit164:
	RTS
levelinit165:
	RTS
levelinit166:
	RTS
levelinit167:
	RTS
levelinit168:
	RTS
levelinit169:
	RTS
levelinit16A:
	RTS
levelinit16B:
	RTS
levelinit16C:
	RTS
levelinit16D:
	RTS
levelinit16E:
	RTS
levelinit16F:
	RTS
levelinit170:
	RTS
levelinit171:
	RTS
levelinit172:
	RTS
levelinit173:
	RTS
levelinit174:
	RTS
levelinit175:
	RTS
levelinit176:
	RTS
levelinit177:
	RTS
levelinit178:
	RTS
levelinit179:
	RTS
levelinit17A:
	RTS
levelinit17B:
	RTS
levelinit17C:
	RTS
levelinit17D:
	RTS
levelinit17E:
	RTS
levelinit17F:
	RTS
levelinit180:
	RTS
levelinit181:
	RTS
levelinit182:
	RTS
levelinit183:
	RTS
levelinit184:
	RTS
levelinit185:
	RTS
levelinit186:
	RTS
levelinit187:
	RTS
levelinit188:
	RTS
levelinit189:
	RTS
levelinit18A:
	RTS
levelinit18B:
	RTS
levelinit18C:
	RTS
levelinit18D:
	RTS
levelinit18E:
	RTS
levelinit18F:
	RTS
levelinit190:
	RTS
levelinit191:
	RTS
levelinit192:
	RTS
levelinit193:
	RTS
levelinit194:
	RTS
levelinit195:
	RTS
levelinit196:
	RTS
levelinit197:
	RTS
levelinit198:
	RTS
levelinit199:
	RTS
levelinit19A:
	RTS
levelinit19B:
	RTS
levelinit19C:
	RTS
levelinit19D:
	RTS
levelinit19E:
	RTS
levelinit19F:
	RTS
levelinit1A0:
	RTS
levelinit1A1:
	RTS
levelinit1A2:
	RTS
levelinit1A3:
	RTS
levelinit1A4:
	RTS
levelinit1A5:
	RTS
levelinit1A6:
	RTS
levelinit1A7:
	RTS
levelinit1A8:
	RTS
levelinit1A9:
	RTS
levelinit1AA:
	RTS
levelinit1AB:
	RTS
levelinit1AC:
	RTS
levelinit1AD:
	RTS
levelinit1AE:
	RTS
levelinit1AF:
	RTS
levelinit1B0:
	RTS
levelinit1B1:
	RTS
levelinit1B2:
	RTS
levelinit1B3:
	RTS
levelinit1B4:
	RTS
levelinit1B5:
	RTS
levelinit1B6:
	RTS
levelinit1B7:
	RTS
levelinit1B8:
	RTS
levelinit1B9:
	RTS
levelinit1BA:
	RTS
levelinit1BB:
	RTS
levelinit1BC:
	RTS
levelinit1BD:
	RTS
levelinit1BE:
	RTS
levelinit1BF:
	RTS
levelinit1C0:
	RTS
levelinit1C1:
	RTS
levelinit1C2:
	RTS
levelinit1C3:
	RTS
levelinit1C4:
	RTS
levelinit1C5:
	RTS
levelinit1C6:
	RTS
levelinit1C7:
	RTS
levelinit1C8:
	RTS
levelinit1C9:
	RTS
levelinit1CA:
	RTS
levelinit1CB:
	RTS
levelinit1CC:
	RTS
levelinit1CD:
	RTS
levelinit1CE:
	RTS
levelinit1CF:
	RTS
levelinit1D0:
	RTS
levelinit1D1:
	RTS
levelinit1D2:
	RTS
levelinit1D3:
	RTS
levelinit1D4:
	RTS
levelinit1D5:
	RTS
levelinit1D6:
	RTS
levelinit1D7:
	RTS
levelinit1D8:
	RTS
levelinit1D9:
	RTS
levelinit1DA:
	RTS
levelinit1DB:
	RTS
levelinit1DC:
	RTS
levelinit1DD:
	RTS
levelinit1DE:
	RTS
levelinit1DF:
	RTS
levelinit1E0:
	RTS
levelinit1E1:
	RTS
levelinit1E2:
	RTS
levelinit1E3:
	RTS
levelinit1E4:
	RTS
levelinit1E5:
	RTS
levelinit1E6:
	RTS
levelinit1E7:
	RTS
levelinit1E8:
	RTS
levelinit1E9:
	RTS
levelinit1EA:
	RTS
levelinit1EB:
	RTS
levelinit1EC:
	RTS
levelinit1ED:
	RTS
levelinit1EE:
	RTS
levelinit1EF:
	RTS
levelinit1F0:
	RTS
levelinit1F1:
	RTS
levelinit1F2:
	RTS
levelinit1F3:
	RTS
levelinit1F4:
	RTS
levelinit1F5:
	RTS
levelinit1F6:
	RTS
levelinit1F7:
	RTS
levelinit1F8:
	RTS
levelinit1F9:
	RTS
levelinit1FA:
	RTS
levelinit1FB:
	RTS
levelinit1FC:
	RTS


levelinit1FE:
	RTS
levelinit1FF:
	RTS

; --Level MAIN--

level0:



		STZ $00
		STZ $01
		JSR DisplayYC

	;JSR TriangleProjection

		RTS


	DisplayYC:
		LDX #$0C				; X = index
	-	LDA .Tilemap+0,x			;\
		CLC : ADC $00				; | X coordinates
		STA !OAM+$000,x				;/
		LDA .Tilemap+1,x			;\
		CLC : ADC $01				; | Y coordinates
		STA !OAM+$001,x				;/
		LDA .Tilemap+2,x : STA !OAM+$002,x	;\ tile/prop
		LDA .Tilemap+3,x : STA !OAM+$003,x	;/
		DEX #4 : BPL -				; loop

		REP #$20				;\
		LDA !YoshiCoinCount			; |
		CMP #$03E7				; |
		BCC $03 : LDA #$03E7			; | (cap at 999)
	-	CMP #$0064 : BCC +			; | calculate 100s
		SBC #$0064				; |
		INC !OAM+$006				; |
		BRA -					;/
	+	SEP #$20				;\
	-	CMP #$0A : BCC +			; |
		SBC #$0A				; | calculate 10s
		INC !OAM+$00A				; |
		BRA -					;/
	+	CLC : ADC !OAM+$00E			;\ store remainder as 1s
		STA !OAM+$00E				;/

		LDA #$F0				;\
		LDX #$B2				; |
		CPX !OAM+$006 : BNE +			; | remove starting 0s
		STA !OAM+$005				; |
		CPX !OAM+$00A				; |
		BNE $03 : STA !OAM+$009			;/
	+	STZ !OAMhi+$00				;\
		STZ !OAMhi+$01				; | tile size = 8x8
		STZ !OAMhi+$02				; |
		STZ !OAMhi+$03				;/

		LDA #$10 : STA !OAMindex		; set OAM index
		RTS

.Tilemap	db $08,$08,$F2,$3F
		db $14,$08,$B2,$3F
		db $1E,$08,$B2,$3F
		db $28,$08,$B2,$3F




level16:
	RTS
level17:
	RTS
level18:
	RTS
level19:
	RTS
level1A:
	RTS
level1B:
	RTS
level1C:
	RTS
level1D:
	RTS
level1E:
	RTS
level1F:
	RTS
level20:
	RTS
level21:
	RTS
level22:
	RTS
level23:
	RTS
level24:
	RTS




	!RollWidth	= $6DF5


level25:

		LDA #$0C : STA !TextPal			; default text pal in this room is 0x0C-0x0F


		LDA !Level+6 : BNE .PortraitLoaded

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		INC !Level+6
		STZ !RollWidth
		JMP $1E80

		.SA1
		PHP
		SEP #$30
		LDX #$07				; special tinker portrait
		LDY #$A1				; palette
		LDA #$70				; VRAM
		JSL !LoadPortrait
		PLP
		RTL
		.PortraitLoaded




	LDA #$FF : STA !LeewayUpgrades

		LDY !Level+4 : BEQ .NoRoll




	LDA .Y,y
	STA $6DF6
	STA $00
	STZ $01

	LDX #$00
-	LDA .RollTM+0,x
	SEC : SBC !RollWidth
	STA !OAM+$010,x
	EOR #$FF : INC A
	SEC : SBC #$10
	STA !OAM+$084,x

	REP #$20
	LDA .RollTM+1,x
	AND #$00FF
	SEC : SBC #$00E0
	CLC : ADC $00
	CMP #$00E0 : BCC .GoodY
	CMP #$FFF0
	BCS $03 : LDA #$00F0
.GoodY	SEP #$20
	STA !OAM+$011,x
	STA !OAM+$085,x

	LDA .RollTM+2,x
	STA !OAM+$012,x
	STA !OAM+$086,x
	LDA .RollTM+3,x
	STA !OAM+$013,x
	EOR #$40
	STA !OAM+$087,x
	INX #4
	CPX.b #.RollTM_End-.RollTM : BNE -

	LDX #$7F
	LDA #$02
-	STA !OAMhi,x
	DEX
	CPX #$03 : BNE -


	.NoRoll	STZ $00
		STZ $01
		LDA !RollWidth : BEQ .YC
		ASL A
		CMP #$64
		BCC $02 : LDA #$64
		STA $00
		LSR #2
		STA $01
		LSR #2
		CLC : ADC $01
		LSR A
		BCC $01 : INC A
		STA $01
		LDA #$14 : STA !MainScreen
		LDA #$03 : STA !SubScreen
		LDA #$08 : TRB $3E

	.YC	JSR DisplayYC

		LDA !Level+2 : BNE .NoUpload
		INC !Level+2
		JSR LoadScreen_Char
		RTS
		.NoUpload


		LDA !Level+4 : BNE $03 : JMP ++
		CMP.b #.Y_End-.Y-1 : BCS +
		INC !Level+4
		JMP ++
	+	LDA.b #.Y_End-.Y-1 : STA !Level+4
		LDA #$D8 : STA $404406

	LDA #$1C : STA !TextPal

	LDA !RollWidth
	CMP #$60 : BEQ +
	CLC : ADC #$04
	STA !RollWidth
	+



	LDA !Characters
	LSR #4
	TAX
	LDA .CharIndex,x : STA $00
	CLC : ADC #$03
	CLC : ADC !Level+5
	STA !MsgTrigger

	LDA $6DA6
	AND #$03 : BEQ .NoInput
	CMP #$03 : BEQ .NoInput
	EOR #$03
	DEC A
	ASL A
	DEC A
	CLC : ADC !Level+5
	BPL $02 : LDA #$06
	CMP #$07
	BCC $02 : LDA #$00
	STA !Level+5
	LDA $00
	CLC : ADC #$03
	CLC : ADC !Level+5
	STA !MsgTrigger
	LDA #$00
	STA.l $400000+!MsgRAM+$00
	STA.l $400000+!MsgRAM+$01
	STA.l $400000+!MsgRAM+$20
	STA.l $400000+!MsgRAM+$33
	STA.l $400000+!MsgRAM+$34
	.NoInput


		LDA !RollWidth				;\ no cursor or portraits before here
		CMP #$40 : BCC ++			;/


		LDA !Characters				;\
		LSR #4					; |
		TAX					; | get index to character tree
		LDA .CharIndex,x			; |
		CLC : ADC !Level+5			; |
		TAX					;/
		LDA .CursorX,x : STA $01		;\
		LDA .CursorY,x : STA $02		; |
		LDX #$00				; | get input for cursor tilemap
		LDA $14					; |
		LSR #2					; |
		AND #$02 : STA $00			;/
	-	LDA .CursorTM+0,x			;\
		CLC : ADC $01				; | cursor X
		STA !OAM+$1E0,x				;/
		LDA .CursorTM+1,x			;\
		CLC : ADC $02				; | cursor Y
		STA !OAM+$1E1,x				;/
		LDA .CursorTM+2,x			;\
		CLC : ADC $00				; | cursor tile
		STA !OAM+$1E2,x				;/
		LDA .CursorTM+3,x : STA !OAM+$1E3,x	; cursor prop
		INX #4
		CPX #$10 : BNE -
		STZ !OAMhi+$78
		STZ !OAMhi+$79
		STZ !OAMhi+$7A
		STZ !OAMhi+$7B


		.DrawPortrait
		LDX #$3F				;
	-	LDA .PortraitTM,x : STA !OAM+$1A0,x	; draw portrait
		DEX : BPL -
		++


		LDA !RollWidth
		CMP #$48 : BCS .PortraitIn
		LDA #$F0
		STA !OAM+$1A1+$04
		STA !OAM+$1A1+$0C
		STA !OAM+$1A1+$14
		STA !OAM+$1A1+$1C
		STA !OAM+$1A1+$24
		STA !OAM+$1A1+$2C
		STA !OAM+$1A1+$34
		STA !OAM+$1A1+$3C
		.PortraitIn




		REP #$20				;\
		LDA #$0D03 : STA $4330			; |
		LDA $14					; |
		AND #$0001				; | double buffered table for BG1
		ASL #5					; | X = index
		TAX					; |
		ORA #$0600				; |
		STA !HDMA3source			;/

		LDA #$0100				;\
		STA $0601,x				; |
		STA $0606,x				; |
		LDY !Level+4				; |
		LDA .Y,y				; |
		AND #$00FF				; | BG1 table
		EOR #$FFFF				; |
		STA $0603,x				; |
		STA $0608,x				; |
		STZ $060B,x				; |
		STA $060D,x				; |
		STZ $060F,x				;/

		SEP #$20
		STZ $4334
		STZ $4344
		STZ $4354
		LDA .Y,y
		LSR A
		STA $0600,x
		BCC $01 : INC A
		STA $0605,x
		LDA #$01 : STA $060A,x


	; 78-88
	; 18-E8


		LDA #$78
		SEC : SBC !RollWidth
		STA $00
		EOR #$FF : INC A
		STA $01


		REP #$20

		LDA #$2801 : STA $4340			;\
		LDA #$2301 : STA $4350			; > windows settings HDMA
		LDA $14					; |
		AND #$0001				; |
		ASL #5					; | double buffered table for window 2
		TAX					; |
		ORA #$0700				; |
		STA !HDMA4source			;/
		CLC : ADC #$0080			;\ table for window settings table
		STA !HDMA5source			;/


		LDA $00					;\
		STA $0701,x				; | this is a little hacky but I need to set it up here
		STA $0704,x				;/


		LDA #$0C0C
		STA $0781,x
		STA $0784,x



		SEP #$20
		LDA .Y,y
		LSR A
		STA $0700,x : STA $0780,x
		BCC $01 : INC A
		STA $0703,x : STA $0783,x
		LDA #$01
		STA $0706,x : STA $0786,x
		LDA #$FF : STA $0707,x
		STZ $0708,x

		STZ $0787,x
		STZ $0788,x

		STZ $0709,x : STZ $0789,x
		LDA #$38 : TSB !HDMA
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;
; give upgrade code
		LDA !Characters
		LSR #4
		STA $00
		CLC : ADC !Level+5
		TAX
		LDA .UpgradeBit,x
		LDX $00
		ORA !MarioUpgrades,x
		STA !MarioUpgrades,x
;;;;;;;;;;;;;;;;;;;;;;;;;





.CharIndex	db $00,$07,$0E,$15,$00,$00


.CursorTM	db $2C,$1C,$EC,$3F
		db $3C,$1C,$EC,$7F
		db $2C,$2C,$EC,$BF
		db $3C,$2C,$EC,$FF


.CursorX	db $00,$30,$60		;\ Mario
		db $00,$30,$60,$90	;/
		db $00,$30,$60		;\ Luigi
		db $00,$30,$60,$90	;/
		db $28,$48,$68		;\ Kadaal
		db $18,$38,$58,$78	;/
		db $00,$00,$30,$60	;\ Leeway
		db $00,$50,$A0		;/



.CursorY	db $00,$00,$00		;\ Mario
		db $30,$30,$30,$30	;/
		db $00,$00,$00		;\ Luigi
		db $30,$30,$30,$30	;/
		db $20,$20,$20		;\ Kadaal
		db $38,$38,$38,$38	;/
		db $00,$20,$20,$10	;\ Leeway
		db $40,$40,$40		;/


.UpgradeBit	db $00,$00,$00		;\ Mario
		db $00,$00,$00,$00	;/
		db $00,$00,$00		;\ Luigi
		db $00,$00,$00,$00	;/
		db $02,$04,$01		;\ Kadaal
		db $40,$08,$10,$20	;/
		db $01,$02,$04,$08	;\ Leeway
		db $10,$20,$80		;/


.PortraitTM	db $38,$10,$60,$79	; 00
		db $28,$10,$62,$79	; 04
		db $38,$20,$64,$79	; 08
		db $28,$20,$66,$79	; 0C
		db $38,$10,$68,$7B	; 10
		db $28,$10,$6A,$7B	; 14
		db $38,$20,$6C,$7B	; 18
		db $28,$20,$6E,$7B	; 1C

		db $B8,$10,$00,$35	; 20
		db $C8,$10,$02,$35	; 24
		db $B8,$20,$04,$35	; 28
		db $C8,$20,$06,$35	; 2C
		db $B8,$10,$08,$37	; 30
		db $C8,$10,$0A,$37	; 34
		db $B8,$20,$0C,$37	; 38
		db $C8,$20,$0E,$37	; 3C

.RollTM		db $68,$00,$85,$3E
		db $70,$00,$86,$3E
		db $68,$10,$85,$3E
		db $70,$10,$86,$3E
		db $68,$20,$85,$3E
		db $70,$20,$86,$3E
		db $68,$30,$85,$3E
		db $70,$30,$86,$3E
		db $68,$40,$85,$3E
		db $70,$40,$86,$3E
		db $68,$50,$85,$3E
		db $70,$50,$86,$3E
		db $68,$60,$85,$3E
		db $70,$60,$86,$3E
		db $68,$70,$85,$3E
		db $70,$70,$86,$3E
		db $68,$80,$85,$3E
		db $70,$80,$86,$3E
		db $68,$90,$85,$3E
		db $70,$90,$86,$3E
		db $68,$A0,$85,$3E
		db $70,$A0,$86,$3E
		db $68,$B0,$85,$3E
		db $70,$B0,$86,$3E

		db $68,$B8,$81,$3E
		db $68,$B8,$82,$3E
		db $60,$C0,$90,$3E
		db $70,$C0,$92,$3E
		db $78,$C0,$93,$3E
		..End


		.Y
		db $01,$08,$0F,$16,$1E,$25,$2C,$32
		db $39,$3F,$45,$4B,$51,$57,$5D,$63
		db $69,$6E,$73,$78,$7D,$82,$87,$8C
		db $91,$95,$99,$9D,$A1,$A5,$A9,$AD
		db $B1,$B4,$B7,$BA,$BD,$C0,$C3,$C6
		db $C9,$CB,$CD,$CF,$D1,$D3,$D5,$D7
		db $D9,$DA,$DB,$DC,$DD,$DE,$DF,$E0
		..End


; this code uses $0400-$0BFF as a buffer, so be careful when using HDMA!


LoadScreen:	PHP
		STX $00
		STY $01
		REP #$10
		LDX $00
		BRA .Main

	.Char	PHP
		LDA !Characters
		LSR #4
		TAX
		LDA .Screen+6,x : XBA
		LDA .Screen,x
		REP #$10
		TAX

		.Main
		LDY #$0000

	-	LDA $41C800,x : XBA
		LDA $40C800,x
		INX
		STX $00
		REP #$20
		ASL A
		PHX
		PHY
		PHP
		JSL $06F540			; how the fuck did i find this?
		PLP
		PLX				; get "Y" in X
		STA $0A
		LDY #$0000
		LDA [$0A],y : STA $0400,x
		INY #2
		LDA [$0A],y : STA $0440,x
		INY #2
		LDA [$0A],y : STA $0402,x
		INY #2
		LDA [$0A],y : STA $0442,x
		TXY
		PLX

		TYA
		CLC : ADC #$0004
		AND #$003F : BNE .Same
	.New	TYA
		CLC : ADC #$0040
		TAY
	.Same	INY #4
		CPY #$0800 : BEQ .Done
		SEP #$20
		LDX $00
		BRA -

	.Done	JSL !GetVRAM
		REP #$20
		LDA #$0400 : STA !VRAMbase+!VRAMtable+$02,x
		LDA #$0000 : STA !VRAMbase+!VRAMtable+$04,x
		LDA #$3400 : STA !VRAMbase+!VRAMtable+$05,x
		LDA #$0800 : STA !VRAMbase+!VRAMtable+$00,x
		PLP
		RTS


.Screen		db $B0,$60,$10,$C0,$70,$20
		db $01,$03,$05,$06,$08,$0A








level33:
	RTS





level38:
	RTS
level39:
	RTS
level3A:
	RTS
level3B:
	RTS
level3C:
	RTS
level3D:
	RTS
level3E:
	RTS
level3F:
	RTS
level40:
	RTS
level41:
	RTS
level42:
	RTS
level43:
	RTS
level44:
	RTS
level45:
	RTS
level46:
	RTS
level47:
	RTS
level48:
	RTS
level49:
	RTS
level4A:
	RTS
level4B:
	RTS
level4C:
	RTS
level4D:
	RTS
level4E:
	RTS
level4F:
	RTS
level50:
	RTS
level51:
	RTS
level52:
	RTS
level53:
	RTS
level54:
	RTS
level55:
	RTS
level56:
	RTS
level57:
	RTS
level58:
	RTS
level59:
	RTS
level5A:
	RTS
level5B:
	RTS
level5C:
	RTS
level5D:
	RTS
level5E:
	RTS
level5F:
	RTS
level60:
	RTS
level61:
	RTS
level62:
	RTS
level63:
	RTS
level64:
	RTS
level65:
	RTS
level66:
	RTS
level67:
	RTS
level68:
	RTS
level69:
	RTS
level6A:
	RTS
level6B:
	RTS
level6C:
	RTS
level6D:
	RTS
level6E:
	RTS
level6F:
	RTS
level70:
	RTS
level71:
	RTS
level72:
	RTS
level73:
	RTS
level74:
	RTS
level75:
	RTS
level76:
	RTS
level77:
	RTS
level78:
	RTS
level79:
	RTS
level7A:
	RTS
level7B:
	RTS
level7C:
	RTS
level7D:
	RTS
level7E:
	RTS
level7F:
	RTS
level80:
	RTS
level81:
	RTS
level82:
	RTS
level83:
	RTS
level84:
	RTS
level85:
	RTS
level86:
	RTS
level87:
	RTS
level88:
	RTS
level89:
	RTS
level8A:
	RTS
level8B:
	RTS
level8C:
	RTS
level8D:
	RTS
level8E:
	RTS
level8F:
	RTS
level90:
	RTS
level91:
	RTS
level92:
	RTS
level93:
	RTS
level94:
	RTS
level95:
	RTS
level96:
	RTS
level97:
	RTS
level98:
	RTS
level99:
	RTS
level9A:
	RTS
level9B:
	RTS
level9C:
	RTS
level9D:
	RTS
level9E:
	RTS
level9F:
	RTS
levelA0:
	RTS
levelA1:
	RTS
levelA2:
	RTS
levelA3:
	RTS
levelA4:
	RTS
levelA5:
	RTS
levelA6:
	RTS
levelA7:
	RTS
levelA8:
	RTS
levelA9:
	RTS
levelAA:
	RTS
levelAB:
	RTS
levelAC:
	RTS
levelAD:
	RTS
levelAE:
	RTS
levelAF:
	RTS
levelB0:
	RTS
levelB1:
	RTS
levelB2:
	RTS
levelB3:
	RTS
levelB4:
	RTS
levelB5:
	RTS
levelB6:
	RTS
levelB7:
	RTS
levelB8:
	RTS
levelB9:
	RTS
levelBA:
	RTS
levelBB:
	RTS
levelBC:
	RTS
levelBD:
	RTS
levelBE:
	RTS
levelBF:
	RTS
levelC0:
	RTS
levelC1:
	RTS
levelC2:
	RTS
levelC3:
	RTS
levelC4:
	RTS
levelC5:
	RTS
levelC6:
	RTS
levelC7:
		LDA #$FF
		STA !P2Stasis-$80
		STA !P2Stasis
		RTS
levelC8:
	RTS
levelC9:
	RTS
levelCA:
	RTS
levelCB:
	RTS
levelCC:
	RTS
levelCD:
	RTS
levelCE:
	RTS
levelCF:
	RTS
levelD0:
	RTS
levelD1:
	RTS
levelD2:
	RTS
levelD3:
	RTS
levelD4:
	RTS
levelD5:
	RTS
levelD6:
	RTS
levelD7:
	RTS
levelD8:
	RTS
levelD9:
	RTS
levelDA:
	RTS
levelDB:
	RTS
levelDC:
	RTS
levelDD:
	RTS
levelDE:
	RTS
levelDF:
	RTS
levelE0:
	RTS
levelE1:
	RTS
levelE2:
	RTS
levelE3:
	RTS
levelE4:
	RTS
levelE5:
	RTS
levelE6:
	RTS
levelE7:
	RTS
levelE8:
	RTS
levelE9:
	RTS
levelEA:
	RTS
levelEB:
	RTS
levelEC:
	RTS
levelED:
	RTS
levelEE:
	RTS
levelEF:
	RTS
levelF0:
	RTS
levelF1:
	RTS
levelF2:
	RTS
levelF3:
	RTS
levelF4:
	RTS
levelF5:
	RTS
levelF6:
	RTS
levelF7:
	RTS
levelF8:
	RTS
levelF9:
	RTS
levelFA:
	RTS
levelFB:
	RTS
levelFC:
	RTS
levelFD:
	RTS
levelFE:
	RTS
levelFF:
	RTS
level100:
	RTS
level101:
	RTS
level102:
	RTS
level103:
	RTS
level104:
	RTS
level105:
	RTS
level106:
	RTS
level107:
	RTS
level108:
	RTS
level109:
	RTS
level10A:
	RTS
level10B:
	RTS
level10C:
	RTS
level10D:
	RTS
level10E:
	RTS
level10F:
	RTS
level110:
	RTS
level111:
	RTS
level112:
	RTS
level113:
	RTS
level114:
	RTS
level115:
	RTS
level116:
	RTS
level117:
	RTS
level118:
	RTS
level119:
	RTS
level11A:
	RTS
level11B:
	RTS
level11C:
	RTS
level11D:
	RTS
level11E:
	RTS
level11F:
	RTS
level120:
	RTS
level121:
	RTS
level122:
	RTS
level123:
	RTS
level124:
	RTS
level125:
	RTS
level126:
	RTS
level127:
	RTS
level128:
	RTS
level129:
	RTS
level12A:
	RTS
level12B:
	RTS
level12C:
	RTS
level12D:
	RTS
level12E:
	RTS
level12F:
	RTS
level130:
	RTS
level131:
	RTS
level132:
	RTS
level133:
	RTS
level134:
	RTS
level135:
	RTS
level136:
	RTS
level137:
	RTS
level138:
	RTS
level139:
	RTS
level13A:
	RTS
level13B:
	RTS
level13C:
	RTS
level13D:
	RTS
level13E:
	RTS
level13F:
	RTS
level140:
	RTS
level141:
	RTS
level142:
	RTS
level143:
	RTS
level144:
	RTS
level145:
	RTS
level146:
	RTS
level147:
	RTS
level148:
	RTS
level149:
	RTS
level14A:
	RTS
level14B:
	RTS
level14C:
	RTS
level14D:
	RTS
level14E:
	RTS
level14F:
	RTS
level150:
	RTS
level151:
	RTS
level152:
	RTS
level153:
	RTS
level154:
	RTS
level155:
	RTS
level156:
	RTS
level157:
	RTS
level158:
	RTS
level159:
	RTS
level15A:
	RTS
level15B:
	RTS
level15C:
	RTS
level15D:
	RTS
level15E:
	RTS
level15F:
	RTS
level160:
	RTS
level161:
	RTS
level162:
	RTS
level163:
	RTS
level164:
	RTS
level165:
	RTS
level166:
	RTS
level167:
	RTS
level168:
	RTS
level169:
	RTS
level16A:
	RTS
level16B:
	RTS
level16C:
	RTS
level16D:
	RTS
level16E:
	RTS
level16F:
	RTS
level170:
	RTS
level171:
	RTS
level172:
	RTS
level173:
	RTS
level174:
	RTS
level175:
	RTS
level176:
	RTS
level177:
	RTS
level178:
	RTS
level179:
	RTS
level17A:
	RTS
level17B:
	RTS
level17C:
	RTS
level17D:
	RTS
level17E:
	RTS
level17F:
	RTS
level180:
	RTS
level181:
	RTS
level182:
	RTS
level183:
	RTS
level184:
	RTS
level185:
	RTS
level186:
	RTS
level187:
	RTS
level188:
	RTS
level189:
	RTS
level18A:
	RTS
level18B:
	RTS
level18C:
	RTS
level18D:
	RTS
level18E:
	RTS
level18F:
	RTS
level190:
	RTS
level191:
	RTS
level192:
	RTS
level193:
	RTS
level194:
	RTS
level195:
	RTS
level196:
	RTS
level197:
	RTS
level198:
	RTS
level199:
	RTS
level19A:
	RTS
level19B:
	RTS
level19C:
	RTS
level19D:
	RTS
level19E:
	RTS
level19F:
	RTS
level1A0:
	RTS
level1A1:
	RTS
level1A2:
	RTS
level1A3:
	RTS
level1A4:
	RTS
level1A5:
	RTS
level1A6:
	RTS
level1A7:
	RTS
level1A8:
	RTS
level1A9:
	RTS
level1AA:
	RTS
level1AB:
	RTS
level1AC:
	RTS
level1AD:
	RTS
level1AE:
	RTS
level1AF:
	RTS
level1B0:
	RTS
level1B1:
	RTS
level1B2:
	RTS
level1B3:
	RTS
level1B4:
	RTS
level1B5:
	RTS
level1B6:
	RTS
level1B7:
	RTS
level1B8:
	RTS
level1B9:
	RTS
level1BA:
	RTS
level1BB:
	RTS
level1BC:
	RTS
level1BD:
	RTS
level1BE:
	RTS
level1BF:
	RTS
level1C0:
	RTS
level1C1:
	RTS
level1C2:
	RTS
level1C3:
	RTS
level1C4:
	RTS
level1C5:
	RTS
level1C6:
	RTS
level1C7:
	RTS
level1C8:
	RTS
level1C9:
	RTS
level1CA:
	RTS
level1CB:
	RTS
level1CC:
	RTS
level1CD:
	RTS
level1CE:
	RTS
level1CF:
	RTS
level1D0:
	RTS
level1D1:
	RTS
level1D2:
	RTS
level1D3:
	RTS
level1D4:
	RTS
level1D5:
	RTS
level1D6:
	RTS
level1D7:
	RTS
level1D8:
	RTS
level1D9:
	RTS
level1DA:
	RTS
level1DB:
	RTS
level1DC:
	RTS
level1DD:
	RTS
level1DE:
	RTS
level1DF:
	RTS
level1E0:
	RTS
level1E1:
	RTS
level1E2:
	RTS
level1E3:
	RTS
level1E4:
	RTS
level1E5:
	RTS
level1E6:
	RTS
level1E7:
	RTS
level1E8:
	RTS
level1E9:
	RTS
level1EA:
	RTS
level1EB:
	RTS
level1EC:
	RTS
level1ED:
	RTS
level1EE:
	RTS
level1EF:
	RTS
level1F0:
	RTS
level1F1:
	RTS
level1F2:
	RTS
level1F3:
	RTS
level1F4:
	RTS
level1F5:
	RTS
level1F6:
	RTS
level1F7:
	RTS
level1F8:
	RTS
level1F9:
	RTS
level1FA:
	RTS
level1FB:
	RTS
level1FC:
	RTS


level1FE:
	RTS
level1FF:
	RTS

CLEAR_DYNAMIC_BG3:
		PHP
		REP #$30
		LDA #$38FC
		LDX #$003E
	-	STA $0020,x
		DEX #2
		BPL -
		PLP
		RTS


LOCK_VSCROLL:	LDY #$00
		CMP $1C
		BEQ .Done
		LDA $1C
		BCC .Up
.Down		INC A
		INY
		BRA .Done
.Up		DEC A
		INY
.Done		STA !Level+2
		STY !EnableVScroll
		LDA.w #.Scroll : STA !HDMAptr+0
		LDA.w #.Scroll>>8 : STA !HDMAptr+1
		RTS

		.Scroll
		PHP
		REP #$20
		LDA !Level+2
		STA $1C
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL


LOCK_HSCROLL:	LDY #$00
		CMP $1A
		BEQ .Done
		LDA $1A
		BCC .Left
.Right		INC A
		INY
		BRA .Done
.Left		DEC A
		INY
.Done		STA !Level+2
		STY !EnableHScroll
		LDA.w #.Scroll : STA !HDMAptr+0
		LDA.w #.Scroll>>8 : STA !HDMAptr+1
		RTS

		.Scroll
		PHP
		REP #$20
		LDA !Level+2
		STA $1A
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL


SCROLL_UPRIGHT:	LDY #$00
		STY !EnableHScroll
		STY !EnableVScroll
		CMP $1C
		BEQ .DoneUp
		LDA $1C
		DEC A
		STA !Level+2
		LDA.w #.ScrollUp : STA !HDMAptr+0
		LDA.w #.ScrollUp>>8 : STA !HDMAptr+1
		RTS

.DoneUp		LDA $1A
		CMP $00
		BEQ .DoneRight
		INC A
		STA !Level+2
		LDA.w #.ScrollRight : STA !HDMAptr+0
		LDA.w #.ScrollRight>>8 : STA !HDMAptr+1
.DoneRight	RTS


		.ScrollUp
		PHP
		REP #$20
		LDA !Level+2
		STA $1C
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL

		.ScrollRight
		PHP
		REP #$20
		LDA !Level+2
		STA $1A

		SEC : SBC !MarioXPosLo
		CMP #$0004 : BCS +
		LDA $1A
		CLC : ADC #$0004
		STA !MarioXPosLo
		+

		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL



CALC_MULTI:	LDA $00
		CLC : ADC $00
		DEX
		BNE CALC_MULTI
		STA $4204
		SEP #$10
		LDX #100
		STX $4206
		JSR GET_DIVISION
		LDA $4214
		RTS

GET_DIVISION:	NOP #2
		RTS



VineDestroy:

		.INIT
		LDX #$17					;\
		LDA #$FF					; | Write 0xFF ("off") to all vine destroy regs
	-	STA !VineDestroy+1,x				; |
		DEX : BPL -					;/
		RTS						; > Return


		.MAIN
		LDA.b #..SA1 : STA $3180			;\
		LDA.b #..SA1>>8 : STA $3181			; | Make the SA-1 process this since it's really intense
		LDA.b #..SA1>>16 : STA $3182			; |
		JMP $1E80					;/

		..SA1
		PHB						;\
		LDA.b #!VineDestroy>>16				; | Switch to vine bank
		PHA : PLB					;/
		LDY #$03					; > Highest vine destroy index
	..Loop	LDA $14						;\
	-	CMP.w !VineDestroyTimer,y			; |
		BCC +						; |
		SBC.w !VineDestroyTimer,y			; | Use timer to determine if vine should be processed
		BCS -						; |
	+	STA $00						; |
		CPY $00 : BNE ..Next				;/
		LDA.w !VineDestroyXHi,y				;\ Check if register is active
		CMP #$FF : BNE ..ProcessVine			;/

		..Next
		DEY : BPL ..Loop				; > Next reg

		..Return
		PLB						; > Restore bank
		RTL						; > Return

		..ProcessVine
		PEI ($98)					;\ Push block values
		PEI ($9A)					;/
		XBA						;\
		LDA.w !VineDestroyYLo,y : STA $00		; |
		LDA.w !VineDestroyYHi,y : STA $01		; |
		LDA.w !VineDestroyXLo,y				; |
		PHY						; | Read map16 tile
		PHP						; |
		REP #$10					; |
		TAX						; |
		LDY $00						; |
		JSL $138018					;/
		PLP						;\ Restore stuff
		PLY						;/
		LDA [$05]					;\
		CMP.w !VineDestroyPage				; | Return if wrong page
		BEQ $03						; |
	-	JMP ..Invalid					;/
		DEC $07						;\
		LDA [$05]					; | Get actual number, not acts like setting
		BPL -						;/

		PHA						; > Preserve map16 number (lo byte)
		LDA.w !VineDestroyXLo,y : STA $9A		;\
		LDA.w !VineDestroyXHi,y : STA $9B		; | Set up tile destruction
		LDA.w !VineDestroyYLo,y : STA $98		; |
		LDA.w !VineDestroyYHi,y : STA $99		;/
		JSR .DestroyTile				; > Destroy tile
		TYX						;\
		LDA #$01 : STA $0077C0,x			; |
		LDA $9A : STA $0077C8,x				; | Spawn smoke puff
		LDA $9B : STA.l !SmokeXHi,x			; |
		LDA $98 : STA $0077C4,x				; |
		LDA $99 : STA.l !SmokeYHi,x			; |
		LDA #$01 : STA.l !SmokeHack,x			; |
		LDA #$13 : STA $0077CC,x			;/
		LDA #$01 : STA.l !SPC1
		PLA						; > Restore map16 number (lo byte)
		BRA +
	-	JMP ..Horz
	--	JMP ..Vert
	+	CMP.b #!VineDestroyHorzTile1 : BEQ -		;\
		CMP.b #!VineDestroyHorzTile2 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile3 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile4 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile5 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile6 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile7 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile8 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile9 : BEQ -		; |
		CMP.b #!VineDestroyHorzTile10 : BEQ ..Horz	; |
		CMP.b #!VineDestroyHorzTile11 : BEQ ..Horz	; |
		CMP.b #!VineDestroyHorzTile12 : BEQ ..Horz	; |
		CMP.b #!VineDestroyVertTile1 : BEQ --		; | Check tile type
		CMP.b #!VineDestroyVertTile2 : BEQ --		; |
		CMP.b #!VineDestroyVertTile3 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile4 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile5 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile6 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile7 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile8 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile9 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile10 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile11 : BEQ ..Vert	; |
		CMP.b #!VineDestroyVertTile12 : BEQ ..Vert	; |
		CMP.b #!VineDestroyCornerUL1 : BEQ ..UL		; |
		CMP.b #!VineDestroyCornerUL2 : BEQ ..UL		; |
		CMP.b #!VineDestroyCornerUR1 : BEQ ..UR		; |
		CMP.b #!VineDestroyCornerUR2 : BEQ ..UR		; |
		CMP.b #!VineDestroyCornerDL1 : BEQ ..DL		; |
		CMP.b #!VineDestroyCornerDL2 : BEQ ..DL		; |
		CMP.b #!VineDestroyCornerDR1 : BEQ ..DR		; |
		CMP.b #!VineDestroyCornerDR2 : BEQ ..DR		;/

		..Invalid
		LDA #$FF					;\
		STA.w !VineDestroyXLo,y				; |
		STA.w !VineDestroyXHi,y				; | Clear regs if invalid tile
		STA.w !VineDestroyYLo,y				; |
		STA.w !VineDestroyYHi,y				; |
		STA.w !VineDestroyDirection,y			;/

		..Back
		REP #$20					;\
		PLA : STA $9A					; | Restore block values
		PLA : STA $98					; |
		SEP #$20					;/
		PLB						;\ Return since only one vine is processed in a frame
		RTL						;/

		..Horz
		JSR .HorzExtra					; > Destroy extra tiles
		LDA.w !VineDestroyDirection,y			;\
		TAX						; |
	..Horz2	LDA.l .MovementXLo,x				; |
		CLC : ADC.w !VineDestroyXLo,y			; | Move horizontally
		STA.w !VineDestroyXLo,y				; |
		LDA.l .MovementXHi,x				; |
		ADC.w !VineDestroyXHi,y				; |
		STA.w !VineDestroyXHi,y				;/
		BRA ..Back					; > Loop

		..Vert
		JSR .VertExtra					; > Destroy extra tiles
		LDA.w !VineDestroyDirection,y			;\
		TAX						; |
	..Vert2	LDA.l .MovementYLo,x				; |
		CLC : ADC.w !VineDestroyYLo,y			; | Move vertically
		STA.w !VineDestroyYLo,y				; |
		LDA.l .MovementYHi,x				; |
		ADC.w !VineDestroyYHi,y				; |
		STA.w !VineDestroyYHi,y				;/
		BRA ..Back					; > Loop

		..UL
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_UL-1				; |
		BRA .CornerExtra				;/

		..UR
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_UR-1				; |
		BRA .CornerExtra				;/

		..DL
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_DL-1				; |
		BRA .CornerExtra				;/

		..DR
		PHY						;\
		LDY #$03					; | Erase extra tiles
		PEA ..Corner-1					; |
		PEA .CornerExtra_DR-1				; |
		BRA .CornerExtra				;/

		..Corner
		PLY
		CLC : ADC.w !VineDestroyDirection,y		;\
		TAX						; |
		LDA.l .CornerUL,x				; |
		STA.w !VineDestroyDirection,y			; | Change direction then move
		TAX						; |
		AND #$02 : BEQ ..Horz2				; |
		BRA ..Vert2					;/


		.DestroyTile
		PHY						;\
		PHP						; |
		SEP #$20					; |
		LDA #$01 : STA $9C				; |
		PHB : PHK : PLB					; | Destroy tile at $9A;$98
		JSL $00BEB0					; | (complete with wrappers for most important regs)
		PLB						; |
		PLP						; |
		PLY						;/
		RTS						; > Return


	.VertExtra
		PHP
		REP #$20
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR .DestroyTile
		LDA $9A
		CLC : ADC #$0020
		STA $9A
		PLP
		BRA .DestroyTile

	.HorzExtra
		PHP
		REP #$20
		LDA $98
		SEC : SBC #$0010
		STA $98
		JSR .DestroyTile
		LDA $98
		CLC : ADC #$0020
		STA $98
		PLP
		BRA .DestroyTile


	.CornerExtra
		REP #$20
		RTS

	..DR	LDA $9A
		SEC : SBC #$0010
		STA $9A
		JSR .DestroyTile
		DEY : BEQ ..ReturnUL
	..DL	LDA $98
		SEC : SBC #$0010
		STA $98
		JSR .DestroyTile
		DEY : BEQ ..ReturnUR
	..UL	LDA $9A
		CLC : ADC #$0010
		STA $9A
		JSR .DestroyTile
		DEY : BEQ ..ReturnDR
	..UR	LDA $98
		CLC : ADC #$0010
		STA $98
		JSR .DestroyTile
		DEY : BNE ..DR

		..ReturnDL
		SEP #$20
		LDA #$08
		RTS

		..ReturnUL
		SEP #$20
		LDA #$00
		RTS

		..ReturnUR
		SEP #$20
		LDA #$04
		RTS

		..ReturnDR
		SEP #$20
		LDA #$0C
		RTS



; Indexed by direcion: right, left, down, up
; 0 = right
; 1 = left
; 2 = down
; 3 = up

.MovementXLo	db $10,$F0
.MovementYLo	db $00,$00
		db $10,$F0

.MovementXHi	db $00,$FF
.MovementYHi	db $00,$00
		db $00,$FF

.CornerUL	db $03,$01,$01,$03
.CornerUR	db $00,$03,$00,$03
.CornerDL	db $02,$01,$02,$01
.CornerDR	db $00,$02,$02,$00





; Write X coordinate to $0C and Y coordinate to $0E

LightningBolt:
		PHP
		REP #$20
		LDA !Level+3
		AND #$00FF
		CMP #$0001 : BNE .BigBolt

		.WarningBolt
		LDA #$0040 : STA $07
		LDA $0C
		STA $04
		STA $09
		LDA $1C
		SEC : SBC #$0010
		AND #$FFF0
		SEP #$20
		STA $05
		XBA : STA $0B
		JMP .DrawLightning

		.BigBolt
		LDA !VineDestroyTimer+$00	;\
		AND #$00FF : BEQ .Init		; |
		LDA !VineDestroyTimer+$01	; |
		STA $05				; |
		STA $0A				; |
		LDA !Level+4			; | Only calculate the shape of the bolt during the first frame
		SEP #$20			; |
		STA $04				; |
		XBA : STA $0A			; |
		LDA !VineDestroyTimer+$03	; |
		STA $07				; |
		JMP .Main			;/

		.Init
		LDA $1C				;\
		AND #$FFF0			; | Start 2 tiles above screen
		SEC : SBC #$0020		; |
		STA $0E				;/
		LDA $0C				;\
		CLC : ADC #$0008		; | Look at tile from middle
		STA $0C				;/
	-	REP #$10
		SEP #$20
		LDX $0C
		LDY $0E
		JSL $138018
		CMP #$0002 : BEQ .WaterImpact
		CMP #$0003 : BEQ .WaterImpact
		CMP #$0100 : BCC .NextTile
		CMP #$016A : BCC .TileImpact

		.NextTile
		LDA $1C				;\
		CLC : ADC #$00D0		; | Max height = 0xF0 px
		STA $00				;/
		LDA $0E				;\
		CLC : ADC #$0010		; |
		BMI +				; |
		CMP #$0170 : BCS .WaterImpact	; |
		CMP $00 : BCS .TileImpact	; | Enforce a max height even if it doesn't hit anything
	+	STA $0E				; |
		BRA -				;/

		.WaterImpact
		LDA #$0001
		STA !VineDestroyPage

		.TileImpact
		LDA $0C				;\
		SEC : SBC #$0008		; | Restore Xpos
		STA $0C				;/
		LDA $1C				;\
		SEC : SBC #$0020		; |
		AND #$FFF0			; | Lo byte of Y in $05, hi byte in $0B (always starts at screen top)
		STA $05				; |
		STA $0A				;/
		LDA $0E				;\
		SEC : SBC $05			; | Height in $07
		BEQ $02 : BPL $03		; |
		JMP .WarningBolt		; | > Go to .WarningBolt if zero or negative
		STA $07				;/
		LDA $0C				;\
		SEP #$20			; | Lo byte of X in $04, hi byte in $0A
		STA $04				; |
		XBA : STA $0A			;/
		LDA #$10 : STA $06		; > Width in $06

		LDX #$03			;\
	-	LDA $7699,x : BEQ +		; |
		LDA $76A1,x : STA $01		; |
		LDA $76A5,x : STA $00		; |
		LDA $76A9,x : STA $09		; |
		LDA $76AD,x : STA $08		; | See if lightning hits a bounce sprite
		LDA #$10			; |
		STA $02				; |
		STA $03				; |
		JSL !Contact16			; |
		BCC +				;/
		LDA $09 : STA $02		;\
		LDA $0B : XBA			; |
		LDA $05				; |
		REP #$20			; |
		SEC : SBC $01			; | Update lightning hitbox
		EOR #$FFFF : INC A		; |
		SEP #$20			; |
		STA $07				;/
	+	DEX : BPL -			; > Check all bounce sprites

		LDA !Translevel			;\ Ignore sprites on Tower of Storms
		CMP #$10 : BEQ ++		;/
		LDX #$0F			;\
	-	LDA $3230,x			; |
		CMP #$08 : BCC +		; |
		CMP #$0B : BCS +		; |
		JSL $03B6E5			; | See if lightning hits a sprite
		JSL !Contact16			; |
		BCS .SpriteImpact		; |
	+	DEX : BPL -			;/
	++	SEC : JSL !PlayerClipping	;\
		LDY #$00			; | See if lightning hits a player
		LSR A : BCS .P1Impact		; |
		LSR A : BCS .P2Impact		;/
		BRA .Electrocute		; > Either way, draw lightning

		.SpriteImpact
		LDA $3430,x : BNE +		;\ Clear water flag unless sprite is in water
		LDA #$00 : STA !VineDestroyPage	;/
	+	LDA $3210,x : STA $0E		;\
		LDA $3240,x			; | Update coordinates for sprite impact
		BRA .UpdateImpact		;/

		.P2Impact
		LDY #$80			; > index for player 2

		.P1Impact
		LDA !P2Water			;\
		AND #$40 : BNE +		; | Clear water flag unless player is in water
		LDA #$00 : STA !VineDestroyPage	;/
	+	LDA !P2YPosLo-$80,y : STA $0E	;\ Update coordinates for player impact
		LDA !P2YPosHi-$80,y		;/

		.UpdateImpact
		STA $0F				;\
		LDA $0B : XBA			; |
		LDA $05				; |
		REP #$20			; | Update height of lightning bolt so it'll end on impact
		SEC : SBC $0E			; |
		EOR #$FFFF : INC A		; |
		SEP #$20			; |
		CLC : ADC #$10			; |
		STA $07				;/
		CPX #$FF : BEQ .Electrocute	; > Try finding a higher target unless all sprites are checked
		DEX : BPL -			; > Loop

		.Electrocute
		LDA !VineDestroyTimer+$00	;\
		BNE .Main			; |
		LDA $05				; |
		STA !VineDestroyTimer+$01	; |
		LDA $0B				; | Backup Ypos and height
		STA !VineDestroyTimer+$02	; |
		LDA $07				; |
		STA !VineDestroyTimer+$03	; |
		LDA #$01			; |
		STA !VineDestroyTimer+$00	;/

		.Main
		LDA $07				;\
		CLC : ADC #$08			; | The hitbox needs to actually reach the ground...
		STA $07				;/

		JSR .BrickBreak			; > Break bricks

		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		CMP #$0C : BCS +
		LDA $3460,x			;\
		AND #$30			; |
		CMP #$30 : BEQ +		; | Lightning counts as both fire and cape
		LDA $3470,x			; |
		AND #$02 : BNE +		;/
		LDA $3430,x			;\
		AND !VineDestroyPage		; | If water contact overlaps, then ZAP!
		BNE ++				;/
		JSL $03B6E5
		JSL !Contact16
		BCC +
	++	LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
	+	DEX : BPL -

		LDA !VineDestroyPage		;\
		BEQ +				; |
		LDA !P2Water			; |
		AND #$40			; |
		ASL A				; |
		STA $00				; | Zap players in water
		LDA !P2Water-$80		; |
		AND #$40			; |
		ORA $00				; |
		CLC : ROL #3			; |
		JSL !HurtPlayers		;/

	+	SEC : JSL !PlayerClipping
		BCC .DrawLightning
		JSL !HurtPlayers

		.DrawLightning
		LDA !VineDestroyPage		;\ Horizontal electricity upon water contact
		BEQ $03 : JSR .WaterShock	;/
		LDA $05 : STA $02		;\
		LDA $0B : STA $03		; | Set up OAM calculations
		LDA $0A : XBA			;/
		LDA $04				;\
		REP #$20			; |
		SEC : SBC $1A			; |
		STA $00				; |
		CMP #$0100 : BCC .GoodX		; | If X coordinate is invalid, don't draw anything
		CMP #$FFF0 : BCS .GoodX		; |
		PLP				; |
		RTS				;/

	.GoodX	LDA $02
		SEC : SBC $1C
		SEC : SBC #$0010
		STA $02
		SEP #$20
		LDX !OAMindex
		LDY #$00
		LDA $07
		CLC : ADC #$08
		AND #$F0
		LSR #2
		CLC : ADC !OAMindex
		STA $08				; > End index
		STX $09				; > Start index

	-	LDA $00 : STA !OAM+$00,x
		REP #$20
		LDA $02
		CLC : ADC #$0010
		STA $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		LDA #$00F0
	.GoodY	STA !OAM+$01,x
		LDA .Tilemap,y
		AND #$00FF
		ORA #$3F00
		STA !OAM+$02,x
		SEP #$20

		PHX
		TXA
		LSR #2
		TAX
		LDA $01
		AND #$01
		ORA #$02 : STA !OAMhi,x
		PLX

		INX #4
		INY
		CPY #$0E : BEQ +
		CPX $08 : BNE -

	+	LDA $08					;\
		STA !OAMindex				;/
		LDA #$8A : STA !OAM-$06,x		;\ Set tip
		LDA #$8C : STA !OAM-$02,x		;/

		LDX $09
		REP #$20
		LDA !OAM+$00,x				;\ Totally done dude
		BMI .Return				;/

		LDX $08					;\
		LDY #$01				; |
	-	SEC : SBC #$1000			; |
		STA !OAM+$00,x				; |
		LDA .Tilemap,y				; |
		AND #$00FF				; |
		ORA #$3F00				; |
		STA !OAM+$02,x				; |
		SEP #$20				; |
		PHX					; | Fill out empty top area
		TXA					; |
		LSR #2					; |
		TAX					; |
		LDA $01					; |
		AND #$01				; |
		ORA #$02 : STA !OAMhi,x			; |
		PLX					; |
		REP #$20				; |
		INX #4					; |
		INY					; |
		LDA !OAM-$04,x				; |
		BPL -					; |
		STX !OAMindex				;/

	.Return	PLP
		RTS

.Tilemap	db $86,$88,$86,$88
		db $86,$88,$86,$88
		db $86,$88,$86,$88
		db $86,$88,$86,$88


.WaterShock	PHP
		REP #$30
		LDA #$3F80
		STA !OAM+$02
		STA !OAM+$06
		STA !OAM+$0A
		STA !OAM+$0E
		STA !OAM+$12
		STA !OAM+$16
		STA !OAM+$1A
		STA !OAM+$1E

		LDA $14
		AND #$000C
		ASL #3
		CLC : ADC $1A
		AND #$003F
		EOR #$003F
		STA $00

		LDA #$0168
		SEC : SBC $1C
		BMI .Nope
		CMP #$00E8 : BCS .Nope
		AND #$00FF
		XBA
		ORA $00
		LDX #$0018
	-	STA !OAM+$04,x
		CLC : ADC #$0010
		STA !OAM+$00,x
		CLC : ADC #$0030
		DEX #8
		BPL -

		LDA #$0202
		LDX #$0006
	-	STA !OAMhi,x
		DEX #2
		BPL -
		SEP #$20
		LDA #$20 : STA !OAMindex
		LDA $00
		CMP #$21 : BCC .Nope
		AND #$0F : BEQ .Nope
		ORA #$F0
		STA !OAM+$20
		LDA !OAM+$1D : STA !OAM+$21
		LDA !OAM+$1E : STA !OAM+$22
		LDA !OAM+$1F : STA !OAM+$23
		LDA #$03 : STA !OAMhi+$08
		LDA #$24 : STA !OAMindex
		.Nope

		PLP
		RTS


.BrickBreak	PEI ($04)
		PEI ($06)
		PEI ($0A)

		REP #$10
		LDA $04
		CLC : ADC #$08
		STA $04
		LDA $0A
		ADC #$00
		XBA
		LDA $04
		AND #$F0
		TAX
		STX $9A						; > Block X
		LDA $05
		CLC : ADC $07
		STA $05
		LDA $0B
		ADC #$00
		XBA
		LDA $05
		AND #$F0
		TAY
		STY $98						; > Block Y
		JSL $138018
		CMP #$011E : BNE +

		PHB						;\
		PHP						; |
		SEP #$20					; |
		LDA #$02					; |
		PHA : PLB					; |
		LDA #$01 : STA $9C				; | Shatter brick
		JSL $00BEB0					; |
		LDA #$00					; |
		JSL $028663					; |
		PLP						; |
		PLB						;/

	+	PLA : STA $0A
		PLA : STA $06
		PLA : STA $04
		SEP #$20
		RTS

; To call:
; REP #$20
; LDA.w #.TalkBox
; JSR TalkOnce
;
; Data format:
; 00: ID (bit in RAM table, min 0 max 15) times 2
; 01: Message number
; 02-03: Xcoord
; 04-05: Ycoord
; 06: Width
; 07: Height
TalkOnce:
		STA $00
		LDA ($00)
		TAY			; ID in Y
		XBA : TAX		; Message number in X
		LDA.w .Table,y		;\
		AND $6DF5		; | Only trigger message once
		BNE .Return		;/

		PHY			; ID on stack
		INC $00
		INC $00
		LDA ($00)
		STA $04			; Xlo in $04
		STA $09			; Xhi in $0A
		INC $00
		INC $00
		LDA ($00)
		STA $05			; Ylo in $05
		XBA : STA $0B		; Yhi in $0B
		INC $00
		INC $00
		LDA ($00)
		STA $06			; Dimensions in $06-$07
		INC $00
		INC $00
		SEP #$21		; 8-bit, set carry
		JSL !PlayerClipping	; Check player contact
		BCC .ReturnP
		STZ $00			;\
		LSR A : BCC +		; |
		PHA			; |
		LDA !P2Blocked-$80	; |
		AND #$04		; |
		TSB $00			; | Only trigger on a player that's on the ground
		PLA			; |
	+	LSR A : BCC +		; |
		LDA !P2Blocked		; |
		AND #$04		; |
		TSB $00			; |
	+	LDA $00 : BEQ .ReturnP	;/
		STX !MsgTrigger		; Trigger message
		PLY
		REP #$20
		LDA.w .Table,y		;\ Mark message as triggered
		TSB $6DF5		;/
		RTS

		.ReturnP
		REP #$20
		PLY

		.Return
		RTS
		

		.Table
		dw $0001,$0002,$0004,$0008
		dw $0010,$0020,$0040,$0080
		dw $0100,$0200,$0400,$0800
		dw $1000,$2000,$4000,$8000


; regs:
; $00		- 0 if inactive, 1 if active
; $01		- symbol of first input (set highest bit to mark as missed)
; $02		- timer for first input, determines height
; $03-$10	- identical to $01-$02 but for the rest of the symbols
; $11		- number of misses
; $12		- P1 pose
; $13		- P2 pose




; !Level+2 holds AND value for $14. If $14&!Level+2 == 0, then !Level+3 is added to $1A (16-bit)
ScreenGrind:
		STZ !EnableHScroll
		STZ !EnableVScroll
		LDA !Level+2 : BEQ .Go			; If frequency = 0, always scroll
		AND $14 : BNE .Return			; Otherwise, only scroll when $14&!Level+2 == 0

	.Go	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
	.Return	RTS

		.HDMA
		PHP
		REP #$20
	;	LDA #$0000 : STA !HDMAptr+0
		LDA $1A
		CLC : ADC !Level+3
		STA $1A
		SEP #$20
		LDA $5E
		DEC A
		XBA					; stop grind when reaching the last screen
		LDA #$00
		REP #$20
		DEC A
		CMP $1A : BCS ..R
		STA $1A
		PLP
		RTL

	..R	INC !EnableHScroll
		PLP
		RTL



; Speed platform eats up !Level+2, 3 and 4.
; 2+3 are used to hold the scroll value, 4 is the value to add to 2+3 every frame.
SpeedPlatform:

		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTS

		.HDMA
		PHP
		REP #$20
		LDA !Level+4
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		STA $00
		LDA !Level+2
		CLC : ADC $00				; add this twice to BG1
		CLC : ADC $00
		STA !Level+2
		ASL A
		CLC : ADC $1A
		LSR #2					; divide by 4 for BG2, to make sure the scrolling is right
		STA $1E
		CLC : ADC #$0280			; fix offset
		LSR A
		STA $22

		LDA !BossData+0
		AND #$007F
		CMP #$0006 : BCC ..Process
		PLP
		RTL


		..Process
		LDA $14					;\
		ASL #2					; |
		AND #$00FF				; | Hide top 2 tile layers
		STA $0201				; |
		LDA #$000D : STA $0203			;/
		LDA $1A : STA $0206			;\
		LDA !ShakeTimer				; |
		AND #$00FF : BEQ +			; |
		AND #$0003				; |
		BNE $04 : DEC #2 : BRA +		; | Put main chunk in the right place
		CMP #$0002 : BEQ +			; |
		LDA #$0000				; |
	+	CLC : ADC $1C				; |
		STA $0208				;/
		LDA #$0D07 : STA $4320			;\
		LDA #$0200 : STA !HDMA3source		; |
		SEP #$20				; | Set up HDMA
		STZ $4324				; |
		LDA #$04 : TSB $6D9F			;/
		LDA #$22 : STA $0200			;\
		LDA #$01 : STA $0205			; | Scanlines
		STZ $020A				;/

		LDA !BossData+0				;\
		AND #$7F				; | Check for crash
		CMP #$05 : BCS $03 : JMP ..Return	;/

		LDA #$B6				;\
		SEC : SBC !BossData+1			; |
		LSR A					; | Scanline counts for main chunk
		STA $0205				; |
		BCC $01 : INC A				; |
		STA $020A				;/
		LDA #$01 : STA $020F			;\ Rest of the scanlines
		STZ $0214				;/
		REP #$20				;\
		LDA $0206 : STA $020B			; | Split main chunk in 2 pieces
		LDA $0208 : STA $020D			;/
		LDA $0201 : STA $0210			; > Horizontal position of crash chunk
		LDA !BossData+1				;\
		AND #$00FF				; | Vertical position of crash chunk
		CLC : ADC #$FFA7			; |
		STA $0212				;/

		CMP #$FFAF : BCC ..Return		; debris code here
		SEP #$30
		LDA $14
		AND #$03 : BNE ..Return
		LDX #!Ex_Amount-1
	-	LDA !Ex_Num,x : BEQ +
		DEX : BPL -
		BMI ..Return
	+	JSR DebrisRNG

		LDA #$01+!MinorOffset : STA !Ex_Num,x	; number
		LDA #$50
		SEC : SBC !BossData+1			; scale with platform
		CLC : ADC $00
		STA !Ex_YLo,x				; Y lo
		LDA #$D0
		CLC : ADC $01
		STA !Ex_XLo,x				; X lo
		LDA #$01 : STA !Ex_YHi,x		; Y hi
		LDA #$0C : STA !Ex_XHi,x		; X hi

		LDA #$FC
		CLC : ADC $02
		STA !Ex_YSpeed,x			; Y speed
		LDA #$FC
		CLC : ADC $03
		STA !Ex_XSpeed,x			; X speed


		..Return
		PLP
		RTL


	; Normal:
	; 0x22 scanlines of value 0x20 (hides top)
	; rest is just $1C (+ shake value)

	; Rising:
	; 0x22 scanlines of value 0x20 (hides top)
	; 0xB6 - (!BossData+1) scanlines of $1C (2 entries)
	; rest is (!BossData+1) + 0xFF50





DANCE:

		LDA !VineDestroy+$00 : BNE .Go			;\ See if it should run
		RTS						;/

	.Go	LDA !VineDestroy+$12 : STA !P2ExternalAnim-$80
		LDA !VineDestroy+$13 : STA !P2ExternalAnim
		LDA #$02
		STA !P2ExternalAnimTimer-$80
		STA !P2ExternalAnimTimer

		LDA #$02					;\
		STA !P2Stasis-$80				; | Players can't move normally during dance
		STA !P2Stasis					;/
		LDX #$0E					;\
	-	STZ $00,x					; | Clear $00, $02, $04, $06, $08, $0A, $0C, and $0E
		DEX #2						; |
		BPL -						;/
		PHB
		LDA #$40
		PHA : PLB
		LDX #$0E
	.Next	LDA.w !VineDestroy+$01,x
		BMI .NoInput
		BEQ .Skip
		LDA.w !VineDestroy+$02,x			;\ No input for first second to prevent mash fail
		CMP #$40 : BCC .NoInput				;/

		STZ $00						;\
		PHX						; |
	-	DEX #2 : BMI +					; |
		LDA.w !VineDestroy+$01,x			; |
		BEQ -						; | See if another symbol should be first
		BMI -						; |
		INC $00						; |
		BRA -						; |
	+	PLX						;/
		LDA $00 : BNE .NoInput				; > Only allow input on one symbol at a time
		LDA.w !VineDestroy+$02,x			;\
		CMP #$90 : BCC +				; |
	-	LDA.w !VineDestroy+$01,x			; | No input past 0xD0
		ORA #$80					; |
		STA.w !VineDestroy+$01,x			;/
		LDA #$2A : STA.l !SPC4				; Wrong! SFX
		INC.w !VineDestroy+$11				; Add one miss

		BRA .NoInput					; Branch
	+	CMP #$80 : BCC +				; > Good input between 0x80 and 0x90
		LDA.l $006DA6					;\
		ORA.l $006DA7					; |
		PHP						; | Look for correct input
		AND.w !VineDestroy+$01,x			; |
		BNE .CorrectInput				;/
		PLP						;\
		BEQ .NoInput					; | If the wrong button is pushed, mark a failure
		BRA -						;/

		.CorrectInput
		PLP						; Get this off the stack
		JSR .Pose					; Get the pose yo
		STZ.w !VineDestroy+$01,x			; Remove input
		LDA #$29 : STA.l !SPC4				; Correct! SFX
		BRA .NoInput					; Branch
	+	LDA.l $006DA6					;\
		ORA.l $006DA7					; | Look for early button presses
		BNE -						;/

		.NoInput
		LDA.w !VineDestroy+$01,x : STA $00,x		; Tile setting in scratch RAM
		LDA.w !VineDestroy+$02,x : STA $01,x		; Timer in scratch RAM
		INC A						; Increment
		CMP #$A8 : BCC .Write				;\
		STZ.w !VineDestroy+$01,x			; | Kill this input after px 0xA8
		BRA .Skip					;/

		.Write
		STA.w !VineDestroy+$02,x			; Update timer


		.Skip
		DEX #2 : BMI $03 : JMP .Next			; Loop
		PLB						; Restore bank

		.DrawSymbols
		LDX #$0E					;\ Indexes
		LDY !OAMindex					;/

	-	LDA $00,x : BEQ ..Next				; Look for symbol
		AND #$7F					;\
		CMP #$04 : BCC +				; |
		LDA #$02 : BRA $02				; | Tile number
	+	LDA #$00					; |
		STA !OAM+$002,y					;/
		LDA $01,x					;\
		CMP #$20					; | Y coordinate
		BCS $02 : LDA #$20				; |
		STA !OAM+$001,y					;/
		TXA						;\
		STA $0F						; |
		ASL #3						; | X coordinate
		CLC : ADC $0F					; | (includes "O" symbol)
		CLC : ADC #$38					; |
		STA !OAM+$000,y					; |
		STA !OAM+$004,y					;/
		PHX						;\
		LDA $00,x					; |
		AND #$7F					; |
		TAX						; |
		LDA.w ..PropTable-1,x				; | Prop
		PLX						; |
		BIT $00,x					; |
		BPL $02 : INC #2				; |
		STA !OAM+$003,y					;/
		LDA #$88 : STA !OAM+$005,y			;\
		LDA #$06 : STA !OAM+$006,y			; | "O" symbol
		LDA #$37 : STA !OAM+$007,y			;/
		PHY						;\
		TYA						; |
		LSR #2						; |
		TAY						; | Tile size
		LDA #$02					; |
		STA !OAMhi,y					; |
		STA !OAMhi+1,y					;/
		PLA						;\
		CLC : ADC #$08					; | Increment index
		TAY						;/
	..Next	DEX #2 : BPL -					; Loop
		STY !OAMindex					; Store new index
		RTS


	..PropTable
		db $7D,$3D,$FF,$BD
		db $FF,$FF,$FF,$3D

	.Pose
		PHX
		LDA.w !VineDestroy+$01,x
		TAX
		LDA.l !P2Character-$80
		BEQ .Mario
		CMP #$02 : BEQ .Kadaal
		CMP #$03 : BEQ .Leeway
		PLX
		RTS

		.Mario
	-	LDA.l .MarioPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

		.Kadaal
	-	LDA.l .KadaalPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

		.Leeway
	-	LDA.l .LeewayPose-1,x
		CMP.w !VineDestroy+$12 : BNE +
		INX #5
		BRA -

	+	STA.w !VineDestroy+$12
		PLX
		RTS



	.MarioPose
		db $0E,$23,$FF,$38		; R1, L1, XX, D1
		db $FF,$1D,$32,$26		; XX, R2, L2, U1
		db $39,$FF,$FF,$FF		; D2, XX, XX, XX
		db $1E				; U2

	.KadaalPose
		db $12,$28,$FF,$0C		; R1, L1, XX, D1
		db $FF,$13,$2A,$19		; XX, R2, L2, U1
		db $0D,$FF,$FF,$FF		; D2, XX, XX, XX
		db $13				; U2

	.LeewayPose
		db $0F,$3D,$FF,$24		; R1, L1, XX, D1
		db $FF,$10,$11,$42		; XX, R2, L2, U1
		db $26,$FF,$FF,$FF		; D2, XX, XX, XX
		db $43				; U2

; Mario poses:
; right:	0E
; left:		23
; down:		38
; up:		26




; LDX #$XX (index*6)
; JSR WARP_BOX
WARP_BOX:
		REP #$20
		LDA .Table+0,x : STA $04	; Xlo in $04
		STA $09				; Xhi in $0A
		LDA .Table+2,x : STA $05	; Ylo in $05
		XBA : STA $0B			; Yhi in $0B
		LDA .Table+4,x : STA $06	; Dimensions in $06-$07
		SEP #$20
		SEC : JSL !PlayerClipping
		BCS EXIT_Exit+2			; Warp if player is touching box
		RTS


		.Table
		dw $0170,$1440 : db $50,$20	; index 00
		dw $01F6,$0B90 : db $0A,$20	; index 06
		dw $0000,$0290 : db $0A,$20	; index 0C


EXIT:
		.Right
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI +
		CMP !P2XPosLo-$80
		BEQ .Exit
		BCC .Exit
	+	LDX !P2Status : BNE .Return
		BIT !P2XPosLo : BMI .Return
		CMP !P2XPosLo
		BEQ .Exit
		BCC .Exit
		.Return
		SEP #$20
		RTS

		.Left
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80 : BCS .Exit
	+	LDX !P2Status : BNE .Return
		CMP !P2XPosLo : BCS .Exit
		SEP #$20
		RTS

		.Exit					; Placed here so the WARP_BOX routine can reach
		SEP #$20
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		RTS

		.Down
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI +
		CMP !P2YPosLo-$80
		BEQ .Exit
		BCC .Exit
	+	LDX !P2Status : BNE .Return
		BIT !P2YPosLo : BMI .Return
		CMP !P2YPosLo
		BEQ .Exit
		BCC .Exit
		SEP #$20
		RTS

		.Up
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BCS .Exit
	+	LDX !P2Status : BNE .Return
		CMP !P2YPosLo
		BCS .Exit
		SEP #$20
		RTS


; Same as the normal one, except it fades the music upon exit
EXIT_FADE:
		.Right
		JSR EXIT_Right
		BRA .Exit

		.Left
		JSR EXIT_Left
		BRA .Exit

		.Down
		JSR EXIT_Down
		BRA .Exit

		.Up
		JSR EXIT_Up

		.Exit
		LDA $71
		CMP #$06 : BNE .Return
		LDA #$80 : STA !SPC3

		.Return
		RTS



END:
		.Right
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		CMP !P2XPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTS

		.Left
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80
		BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2XPosLo
		BCS .End
	+	SEP #$20
		RTS

		.Down
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		CMP !P2YPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTS

		.Up
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80
		BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2YPosLo
		BCS .End
	+	SEP #$20
		RTS

		.End
		SEP #$20
		LDA #$02
		STA $73CE
		LDA #$80				;\ Fade music
		STA !SPC3				;/
		STA $6DD5				; Set exit
		LDX !Translevel				;\
		LDA !LevelTable,x : BMI +		; |
		INC $7F2E				; > You've now beaten one more level (only once/level)
		ORA #$80				; | Set clear, remove midway
	+	AND.b #$40^$FF				; > Clear checkpoint
		STA !LevelTable,x			;/
		LDA #$00				;\
		STA !MidwayLo,x				; | clear extra checkpoint data
		STA !MidwayHi,x				; |
		STZ $73CE				;/
		LDA #$0B : STA !GameMode

		REP #$10				; unlock level
		LDX !Level
		LDA LEVEL_Unlock,x
		SEP #$10
		TAX
		LDA !LevelTable,x
		ORA #$01
		STA !LevelTable,x

		RTS


; --HDMA tables--

HDMA_Evening:

	.Red
	db $0E,$31
	db $0E,$32
	db $0E,$33
	db $0E,$34
	db $0E,$35
	db $0E,$36
	db $0E,$37
	db $0E,$38
	db $0E,$39
	db $0E,$3A
	db $0E,$3B
	db $0E,$3C
	db $0E,$3D
	db $1F,$3E
	db $1F,$3F
	db $00

	.Green
	db $15,$40
	db $15,$41
	db $15,$42
	db $15,$43
	db $15,$44
	db $15,$45
	db $15,$46
	db $15,$47
	db $15,$48
	db $15,$49
	db $15,$4A
	db $00

	.Blue
	db $1A,$88
	db $1A,$87
	db $1A,$86
	db $1A,$85
	db $1A,$84
	db $1A,$83
	db $1A,$82
	db $1A,$81
	db $1A,$80
	db $00

HDMA_Sunset:

	.Red
	db $70,$3F
	db $70,$3F
	db $00

	.Green
	db $13,$4B
	db $13,$4C
	db $13,$4D
	db $13,$4E
	db $13,$4F
	db $13,$50
	db $13,$51
	db $13,$52
	db $13,$53
	db $13,$54
	db $13,$55
	db $13,$56
	db $00

	.Blue
	db $00,$86
	db $20,$85
	db $20,$84
	db $20,$83
	db $20,$82
	db $20,$81
	db $20,$80
	db $00

HDMA_BlueSky:

	.Red
	db $0C,$29
	db $0C,$2A
	db $0C,$2B
	db $0C,$2C
	db $0C,$2D
	db $0C,$2E
	db $0C,$2F
	db $0C,$30
	db $0C,$31
	db $0C,$32
	db $00

	.Green
	db $0E,$54
	db $0E,$55
	db $0E,$56
	db $0E,$57
	db $0E,$58
	db $0E,$59
	db $0E,$5A
	db $0E,$5B
	db $0E,$5C
	db $00

	.Blue
	db $26,$99
	db $26,$9A
	db $26,$9B
	db $00


HDMA_Mist:

	db $30,$E0
	db $30,$E0
	db $08,$E1
	db $08,$E2
	db $08,$E3
	db $08,$E4
	db $08,$E5
	db $08,$E6
	db $08,$E7
	db $08,$E8
	db $08,$E9
	db $08,$EA
	db $08,$EB
	db $08,$EC
	db $08,$ED
	db $08,$EE
	db $08,$EF
	db $08,$F0
	db $00

HDMA_Nighttime:

	.Green
	db $26,$40
	db $26,$41
	db $26,$42
	db $26,$43
	db $26,$44
	db $26,$45
	db $00

	.Blue
	db $0C,$80
	db $0C,$81
	db $0C,$82
	db $0C,$83
	db $0C,$84
	db $0C,$85
	db $0C,$86
	db $0C,$87
	db $0C,$88
	db $0C,$89
	db $0C,$8A
	db $0C,$8B
	db $0C,$8C
	db $0C,$8D
	db $0C,$8E
	db $0C,$8F
	db $0C,$90
	db $0C,$91
	db $0C,$92
	db $0C,$93
	db 00



