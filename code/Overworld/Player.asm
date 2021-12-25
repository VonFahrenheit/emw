


	!MapSpeed		= $20
	!MapSpeedSquare		= (!Speed*!Speed)




	Player:
		REP #$30
		LDA !GameMode
		AND #$00FF
		CMP #$000E : BEQ .Process
		JMP .CheckLevel

		.Process
		..p1
		LDX #$0000 : JSR ProcessPlayer
		REP #$30
		LDA !MultiPlayer
		AND #$00FF : BNE ..p2
		STZ !P2MapXSpeed
		STZ !P2MapYSpeed
		STZ !P2MapZ
		LDA !P1MapX
		SEC : SBC #$0004
		STA !P2MapX
		LDA !P1MapY
		SEC : SBC #$0004
		STA !P2MapY
		BRA ..done

		..p2
		LDA $6DA2 : PHA
		LDA $6DA3 : STA $6DA2
		LDX.w #(!P2MapX)-(!P1MapX) : JSR ProcessPlayer
		REP #$30
		PLA : STA $6DA2
		..done


		.WarpPipe
		LDA !WarpPipe
		AND #$00FF : BEQ ..done
		STZ $2250
		LDA #$0020
		SEC : SBC !WarpPipeTimer
		AND #$00FF : STA $2251
		LDA !WarpPipeP2X : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $00
		LDA !WarpPipeP2Y : STA $2253
		NOP : BRA $00
		LDA $2306 : STA $02
		LDA !WarpPipeTimer
		AND #$00FF : STA $2251
		LDA !P1MapX : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $00
		ROR A
		LSR #4
		STA !P2MapX
		LDA !P1MapY : STA $2253
		NOP : BRA $00
		LDA $2306
		CLC : ADC $02
		ROR A
		LSR #4
		STA !P2MapY
		LDA !WarpPipeTimer
		AND #$00FF
		CMP #$0020 : BEQ ..done
		INC !WarpPipeTimer
		..done



		.CapCoords
		LDA !MultiPlayer
		AND #$00FF : BNE ..done
		LDA !P1MapX
		BPL $03 : LDA #$0000
		CMP #$05F0
		BCC $03 : LDA #$05F0
		STA !P1MapX
		LDA !P1MapY
		BPL $03 : LDA #$0000
		CMP #$0020
		BCS $03 : LDA #$0020
		CMP #$03EF
		BCC $03 : LDA #$03EF
		STA !P1MapY
		..done





	; this part is done for P1 only

		.MoveCamera
		LDA !MultiPlayer
		AND #$00FF : BEQ ..single

		..multi
		LDA !P1MapX
		SEC : SBC !P2MapX
		BPL $04 : EOR #$FFFF : INC A
		CMP #$00C0 : BCC ..multixok
		..multixlock
		LDA $1A : STA $00
		BRA ..multixdone
		..multixok
		LDA !P1MapX
		CLC : ADC !P2MapX
		LSR A
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		STA $00
		..multixdone
		LDA !P1MapY
		SEC : SBC !P2MapY
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0080 : BCC ..multiyok
		..multiylock
		LDA $1C : STA $02
		BRA ..movecamera
		..multiyok
		LDA !P1MapY
		CLC : ADC !P2MapY
		LSR A
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		STA $02
		BRA ..movecamera

		..single
		LDA !P1MapX
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		STA $00
		LDA !P1MapY
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		STA $02

		..movecamera
		LDA $1A
		SEC : SBC $00
		INC #3
		CMP #$0007 : BCC ..storeX
		LDA $1A
		CMP $00 : BCS ..decX
		..incX
		INC #4 : BRA ++
		..decX
		DEC #4 : BRA ++
		..storeX
		LDA $00
	++	STA $1A
		+
		LDA $1C
		SEC : SBC $02
		INC #3
		CMP #$0007 : BCC ..storeY
		LDA $1C
		CMP $02 : BCS ..decY
		..incY
		INC #4 : BRA ++
		..decY
		DEC #4 : BRA ++
		..storeY
		LDA $02
	++	STA $1C
		+




		..capcamera
		LDA $1A : BPL +
		LDA #$0000 : STA $1A
	+	CMP #$0500 : BCC +
		LDA #$0500 : STA $1A
		+
		LDA $1C : BPL +
		LDA #$0000 : STA $1C
	+	CMP #$031F : BCC +
		LDA #$031F : STA $1C
		+


		.CapMultiPlayerCoords
		LDA !MultiPlayer
		AND #$00FF : BEQ ..done
		LDA $1A
		CLC : ADC #$00F0
		STA $00
		LDA $1C
		CLC : ADC #$0020
		STA $02
		CLC : ADC #$00B0
		STA $04
		LDX.w #(!P2MapX)-(!P1MapX)

		..loop
		LDA !P1MapX,x
		CMP $1A : BCC ..left
		CMP $00 : BCC ..Y
	..right	LDA $00 : STA !P1MapX,x
		BRA ..Y
	..left	LDA $1A : STA !P1MapX,x

		..Y
		LDA !P1MapY,x
		CMP $02 : BCC ..up
		CMP $04 : BCC ..next
	..down	LDA $04 : STA !P1MapY,x
		BRA ..next
	..up	LDA $02 : STA !P1MapY,x
		..next
		CPX #$0000 : BEQ ..done
		LDX #$0000 : BRA ..loop
		..done



		.CheckLevel
		LDA !Translevel : STA !PrevTranslevel
		STZ !Translevel
		LDA !P1MapX
		STA $00
		STA $08-1
		LDA !P1MapY
		SEP #$20
		STA $01
		XBA : STA $09
		REP #$20
		LDA #$0C0C : STA $02

		LDA !P1MapX+1
		AND #$00FF
		ASL #2
		STA $0E
		LDA !P1MapY+1
		AND #$00FF
		TAY
		LDA ScreenSpeedup_Y,y
		AND #$00FF
		CLC : ADC $0E
		TAY
		LDA ScreenSpeedup+0,y : STA !BigRAM+0		; starting index
		LDA ScreenSpeedup+2,y : STA !BigRAM+2		; final index

		..loop
		LDY !BigRAM+0
		LDA LevelList+0,y
		STA $04
		XBA : STA $0A
		LDA LevelList+4,y : STA $06
		LDA LevelList+2,y
		SEP #$30
		STA $05
		XBA : STA $0B

		JSL !CheckContact
		REP #$30
		BCS ..load
		TYA
		CLC : ADC #$0007
		CMP !BigRAM+2 : BCS ..done
		STA !BigRAM+0
		BRA ..loop

		..load
		LDY !BigRAM+0
		LDA LevelList+6,y
		AND #$00FF : STA !Translevel
		CMP !PrevTranslevel : BEQ ..done
		SEP #$20
	;	LDA #$23 : STA !SPC4			; i kinda don't like this???
		REP #$20
		..done



		.Draw
		LDX #$0000 : JSR DrawPlayer
		LDA !MultiPlayer
		AND #$00FF : BEQ +
		LDX.w #(!P2MapX)-(!P1MapX) : JSR DrawPlayer
	+	LDA !Translevel : BNE ..drawbuttons
		..return
		RTS

		..drawbuttons
		LDA !WarpPipe
		AND #$00FF : BNE ..return
		LDA !GameMode
		AND #$00FF
		CMP #$000E : BCC ..return
		LDA #$0030
		SEC : SBC !CircleRadius
		BEQ ..simple
		BIT #$0004 : BNE ..return
		LSR #2
		XBA
		DEC !ButtonTimer
		..simple
		STA $04
		INC !ButtonTimer


	; draw b button
		LDA !OAMindex_p3 : TAX
		LDA !P1MapX
		SEC : SBC $1A
		AND #$00FF
		STA $00
		LDA !P1MapY
		SEC : SBC $1C
		STA $01
		LDA !ButtonTimer-1
		LSR #3
		AND #$0700
		SEC : SBC #$0400
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC $00
		SEC : SBC #$1400
		SEC : SBC $04
		STA !OAM_p3+$000,x
		STA $00
		LDA #$3E2A : STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3+$00,x
		INX
		TXA
		ASL #2
		STA !OAMindex_p3

	; draw x button and checkpoint icon
		LDX !Translevel
		LDA !LevelTable1,x
		AND #$0040 : BEQ ..nocheckpoint
		LDA !MapCheckpointX
		AND #$00FF : BEQ ..nocheckpoint

		LDA !OAMindex_p1 : TAX
		CLC : ADC #$0004
		STA !OAMindex_p1

		LDA !P1MapX
		CLC : ADC !MapCheckpointX
		SEC : SBC $1A
		STA !OAM_p1+$000,x
		LDA !P1MapY
		SEC : SBC $1C
		STA !OAM_p1+$001,x
		LDA #$342E : STA !OAM_p1+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0202 : STA !OAMhi_p1,x
		..nocheckpoint




		..done


		RTS



; input:
;	$0C = X coord
;	$0E = Y coord

	ReadTile:
		LDA $0E+1
		AND #$00FF
		CMP #$0004 : BCS .OutOfBounds
		TAY
		LDA $0C+1
		AND #$00FF
		CMP #$0006 : BCS .OutOfBounds
		ASL A
		ADC HandleZips_TilemapMatrix_y,y
		AND #$00FF
		TAY
		LDA HandleZips_TilemapMatrix,y : TAY
		LDA DecompressionMap+1,y : STA $00
		LDA DecompressionMap+2,y : STA $01
		LDA $0C
		AND #$00F8
		LSR #2
		STA $04
		LDA $0E
		AND #$00F8
		ASL #3
		ORA $04
		TAY
		LDA [$00],y
		AND #$03FF
		TAY
		LDA .Solidity,y
		AND #$00FF
		RTS

		.OutOfBounds
		LDA #$0001
		RTS


	.Solidity
		db $01		; tile 000
		db $01		; tile 001
		db $01		; tile 002
		db $01		; tile 003
		db $01		; tile 004
		db $01		; tile 005
		db $01		; tile 006
		db $01		; tile 007
		db $01		; tile 008
		db $01		; tile 009
		db $01		; tile 00A
		db $01		; tile 00B
		db $01		; tile 00C
		db $01		; tile 00D
		db $01		; tile 00E
		db $01		; tile 00F
		db $00		; tile 010
		db $00		; tile 011
		db $00		; tile 012
		db $00		; tile 013
		db $00		; tile 014
		db $00		; tile 015
		db $00		; tile 016
		db $00		; tile 017
		db $00		; tile 018
		db $00		; tile 019
		db $00		; tile 01A
		db $00		; tile 01B
		db $00		; tile 01C
		db $00		; tile 01D
		db $00		; tile 01E
		db $00		; tile 01F



;
; $00	X
; $02	Y
; $04	tile + prop
; $06	origin Y

	DrawPlayer:
		LDA !P1MapX,x
		SEC : SBC $1A
		STA $00
		LDA !P1MapY,x
		SEC : SBC $1C
		STA $06
		SEC : SBC !P1MapZ,x
		STA $02

		LDA !P1MapAnim,x
		AND #$00FF
		ASL #2
		STA $04
		CMP #$0004*4 : BEQ +
		LDA !P1MapXSpeed,x
		ORA !P1MapYSpeed,x
		AND #$00FF : BEQ +
		LDA $14
		LSR #3
		AND #$0003
		BIT #$0001 : BEQ +
		DEC $02
	+	ORA $04
		TAY
		LDA Anim,y
		AND #$00FF : STA $0E
		AND #$0040 : TRB $0E
		XBA : STA $04

		SEP #$30
		LDA !P1MapChar,x
		.Plus1
		CMP #$01 : BNE ..notluigi
		LDY !P1MapAnim,x
		CPY #$04 : BNE ..done
		BRA ..add
		..notluigi
		CMP #$02 : BEQ ..checkxflip
		CMP #$03 : BNE ..done
		..checkxflip
		LDY $05
		CPY #$40 : BCC ..done
		..add
		INC $00
		..done

		ASL #3
		CLC : ADC !P1MapChar,x
		ASL A
		CLC : ADC $0E
		STA $0E
		AND #$F0 : TRB $0E
		ASL A
		TSB $0E
		REP #$30

		.Draw
		LDA !P1MapAnim,x
		AND #$00FF
		CMP #$0001 : BEQ ..checkflip
		LDA $04
		BRA ..setprop
		..checkflip
		LDA !P1MapDirection,x
		AND #$0001
		BEQ $03 : LDA #$4000
		EOR #$4000
		EOR $04
		..setprop
		ORA #$1000
		STA $04

		CPX #$0000 : BEQ +
		LDA #$0202 : TSB $04
		+

		LDY !MapOAMindex
		CPY #$0100 : BCS ..fail
		LDA #$0005 : STA !MapOAMdata+$002,y
		LDA $06 : STA !MapOAMdata+$000,y
		INY #4

		LDA $00 : STA !MapOAMdata+$000,y
		LDA $02 : STA !MapOAMdata+$001,y
		LDA $04 : STA !MapOAMdata+$002,y
		LDA $01
		AND #$0001
		ORA #$0002
		STA !MapOAMdata+$004,y
		TYA
		CLC : ADC #$0005
		STA !MapOAMindex
		INC !MapOAMcount

		..fail

	; draw shadow
		STX $0A
		LDA !P1MapZ,x : BEQ ..noshadow
		LDA !OAMindex_p0 : TAX
		LDA $00 : STA !OAM_p0+$000,x
		LDA $06
		CLC : ADC #$0006
		STA !OAM_p0+$001,x
		LDA #$1504 : STA !OAM_p0+$002,x
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $01
		AND #$01
		ORA #$02
		STA !OAMhi_p0,x
		REP #$20
		INX
		TXA
		ASL #2
		STA !OAMindex_p0
		..noshadow



	; check if tile in $0E should be uploaded

		.Dynamic
		LDA $0A
		BEQ $03 : LDA #$0020
		ORA #$6000
		STA $0C
		SEP #$20
		LDA $0E
		CMP !P1MapPrevAnim,x : BEQ ..done
		JSL !GetVRAM : BCS ..done
		REP #$20
		LDA #$0040 : STA !VRAMbase+!VRAMtable+$00,x
		LDA #$007F : STA !VRAMbase+!VRAMtable+$04,x
		LDA $0E
		XBA
		LSR #3
		STA !VRAMbase+!VRAMtable+$02,x
		LDA $0C : STA !VRAMbase+!VRAMtable+$05,x
		JSL !GetVRAM : BCS ..done
		LDA #$0040 : STA !VRAMbase+!VRAMtable+$00,x
		LDA #$007F : STA !VRAMbase+!VRAMtable+$04,x
		LDA $0E
		ORA #$0010
		XBA
		LSR #3
		STA !VRAMbase+!VRAMtable+$02,x
		LDA $0C
		ORA #$0100
		STA !VRAMbase+!VRAMtable+$05,x
		SEP #$20
		LDX $0A
		LDA $0E : STA !P1MapPrevAnim,x

		..done
		REP #$20
		RTS



	Anim:
		; index = $14>>3&3
		.Front
		db $00
		db $02
		db $00
		db $42

		.Side
		db $04
		db $06
		db $04
		db $08

		.Back
		db $0A
		db $0C
		db $0A
		db $4C

		.Climb
		db $0E
		db $4E
		db $0E
		db $4E

		.Victory
		db $10
		db $10
		db $10
		db $10



	ProcessPlayer:

; to do:
; accel = 2 for cardinal
; accel = 1.5 for diagonal (1 every other frame, 2 every other frame)


		.Controls
		SEP #$30
		LDA $6DA2
		AND #$0F
		TAY
		LDA .SpeedTable_accel,y : BNE +
		LDA $14
		AND #$01
	+	STA $02
		BIT $6DA2 : BVC +
		TYA
		ORA #$10
		TAY
		+
		LDA .SpeedTable_x,y : STA $00
		LDA .SpeedTable_y,y : STA $01

		.XSpeed
		LDA !P1MapXSpeed,x : BMI ..neg
		..pos
		BIT $00 : BMI ..dec
		CMP $00 : BCS ..dec
		..inc
		INC #2
		CLC : ADC $02
		BRA ..write
		..neg
		BIT $00 : BPL ..inc
		CMP $00 : BCC ..inc
		..dec
		DEC #2
		SEC : SBC $02
		..write
		STA !P1MapXSpeed,x
		SEC : SBC $00
		INC #3
		CMP #$07 : BCS ..done
		LDA $00 : STA !P1MapXSpeed,x
		..done

		.YSpeed
		LDA !P1MapYSpeed,x : BMI ..neg
		..pos
		BIT $01 : BMI ..dec
		CMP $01 : BCS ..dec
		..inc
		INC #2
		CLC : ADC $02
		BRA ..write
		..neg
		BIT $01 : BPL ..inc
		CMP $01 : BCC ..inc
		..dec
		DEC #2
		SEC : SBC $02
		..write
		STA !P1MapYSpeed,x
		SEC : SBC $01
		INC #3
		CMP #$07 : BCS ..done
		LDA $01 : STA !P1MapYSpeed,x
		..done

		.Animation
		LDA $6DA2
		BIT #$04 : BNE ..d
		BIT #$08 : BEQ ..vertdone
	..u	LDA !P1MapDirection,x
		AND #$01
		ORA #$02
		STA !P1MapDirection,x
		LDA !P1MapAnim,x
		CMP #$01 : BNE +
		LDA $6DA2
		AND #$03 : BNE ..vertdone
	+	LDA #$02 : STA !P1MapAnim,x
		BRA ..vertdone
	..d	LDA !P1MapDirection,x
		AND #$01
		STA !P1MapDirection,x
		LDA !P1MapAnim,x
		CMP #$01 : BNE +
		LDA $6DA2
		AND #$03 : BNE ..vertdone
	+	STZ !P1MapAnim,x
		..vertdone
		LDA $6DA2
		LSR A : BCS ..r
		LSR A : BCC ..horzdone
	..l	LDA !P1MapDirection,x
		AND #$02
		ORA #$01
		BRA ..sethorzanim
	..r	LDA !P1MapDirection,x
		AND #$02
		..sethorzanim
		STA !P1MapDirection,x
		LDA $6DA2
		AND #$0C : BNE ..horzdone
		LDA #$01 : STA !P1MapAnim,x
		..horzdone
		REP #$30



		.UpdateSpeed
		LDA !WarpPipe
		AND #$00FF : BNE ..z
		..x
		LDY #$0000
		LDA !P1MapXSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !P1MapXFraction,x
		STA !P1MapXFraction,x
		SEP #$20
		TYA
		ADC !P1MapX+1,x
		STA !P1MapX+1,x
		REP #$20
		..y
		LDY #$0000
		LDA !P1MapYSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !P1MapYFraction,x
		STA !P1MapYFraction,x
		SEP #$20
		TYA
		ADC !P1MapY+1,x
		STA !P1MapY+1,x
		REP #$20
		..z
		LDY #$0000
		LDA !P1MapZSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !P1MapZFraction,x
		STA !P1MapZFraction,x
		SEP #$20
		TYA
		ADC !P1MapZ+1,x
		STA !P1MapZ+1,x
		..done


		.AccelZ
		LDA !P1MapZSpeed,x : BPL ..accel
		CMP #$C0 : BCC ..done
		..accel
		DEC !P1MapZSpeed,x
		DEC !P1MapZSpeed,x
		..done


		; .CapSpeedX
		; LDA !P1MapXSpeed,x : BMI ..neg
		; ..pos
		; CMP #$20 : BCC ..done
		; LDA #$20 : STA !P1MapXSpeed,x
		; BRA ..done
		; ..neg
		; CMP #$E0 : BCS ..done
		; LDA #$E0 : STA !P1MapXSpeed,x
		; ..done

		; .CapSpeedY
		; LDA !P1MapYSpeed,x : BMI ..neg
		; ..pos
		; CMP #$20 : BCC ..done
		; LDA #$20 : STA !P1MapYSpeed,x
		; BRA ..done
		; ..neg
		; CMP #$E0 : BCS ..done
		; LDA #$E0 : STA !P1MapYSpeed,x
		; ..done



		REP #$30

		.CapZ
		LDA !P1MapZ,x : BPL ..done
		STZ !P1MapZ,x
		..done



; debug: skip collision with R
	LDA $6DA4
	AND #$0010 : BEQ .Terrain
	JMP .Terrain_noup


		.Terrain

; points:
;	right
;	 F,4
;	 F,B
;	left
;	 0,4
;	 0,B
;	down
;	 4,F
;	 B,F
;	up
;	 4,0
;	 B,0


		..right
		LDA !P1MapX,x
		CLC : ADC #$000F
		STA $0C
		LDA !P1MapY,x
		CLC : ADC #$0004
		STA $0E
		JSR ReadTile : BNE ..collisionright
		LDA !P1MapY,x
		CLC : ADC #$000B
		STA $0E
		JSR ReadTile : BEQ ..noright
		..collisionright
		LDA $0C
		AND #$FFF8
		SEC : SBC #$000F
		STA !P1MapX,x
		SEP #$20
		STZ !P1MapXSpeed,x
		REP #$20
		..noright

		..left
		LDA !P1MapX,x : STA $0C
		LDA !P1MapY,x
		CLC : ADC #$0004
		STA $0E
		JSR ReadTile : BNE ..collisionleft
		LDA !P1MapY,x
		CLC : ADC #$000B
		STA $0E
		JSR ReadTile : BEQ ..noleft
		..collisionleft
		LDA $0C
		AND #$FFF8
		CLC : ADC #$0008
		STA !P1MapX,x
		SEP #$20
		STZ !P1MapXSpeed,x
		REP #$20
		..noleft

		..down
		LDA !P1MapX,x
		CLC : ADC #$0004
		STA $0C
		LDA !P1MapY,x
		CLC : ADC #$000F
		STA $0E
		JSR ReadTile : BNE ..collisiondown
		LDA !P1MapX,x
		CLC : ADC #$000B
		STA $0C
		JSR ReadTile : BEQ ..nodown
		..collisiondown
		LDA $0E
		AND #$FFF8
		SEC : SBC #$000F
		STA !P1MapY,x
		SEP #$20
		STZ !P1MapYSpeed,x
		REP #$20
		..nodown

		..up
		LDA !P1MapX,x
		CLC : ADC #$0004
		STA $0C
		LDA !P1MapY,x : STA $0E
		JSR ReadTile : BNE ..collisionup
		LDA !P1MapX,x
		CLC : ADC #$000B
		STA $0C
		JSR ReadTile : BEQ ..noup
		..collisionup
		LDA $0E
		AND #$FFF8
		CLC : ADC #$0008
		STA !P1MapY,x
		SEP #$20
		STZ !P1MapYSpeed,x
		REP #$20
		..noup




		SEP #$20

		.AnimSpeed
		LDA !Translevel : BEQ ..nopose
		BIT $6DA6 : BMI +
		..nopose


		.AnimDir
		LDA !WarpPipe : BEQ ..done
		LDA !P1MapZSpeed,x : BMI +
		STZ !P1MapDirection,x
		LDA $14
		AND #$03
		CMP #$03 : BNE ..write
		INC !P1MapDirection,x
		LDA #$01 : BRA ..write
	+	LDA #$04
		..write
		STA !P1MapAnim,x
		..done
		RTS




	.SpeedTable
		..x
		db $00,$20,$E0,$00
		db $00,$17,$E9,$00
		db $00,$17,$E9,$00
		db $00,$20,$E0,$00

		db $00,$40,$C0,$00
		db $00,$2E,$D2,$00
		db $00,$2E,$D2,$00
		db $00,$40,$C0,$00

		..y
		db $00,$00,$00,$00
		db $20,$17,$17,$20
		db $E0,$E9,$E9,$E0
		db $00,$00,$00,$00

		db $00,$00,$00,$00
		db $40,$2E,$2E,$40
		db $C0,$D2,$D2,$C0
		db $00,$00,$00,$00

		..accel
		db $01,$01,$01,$01
		db $01,$00,$00,$01
		db $01,$00,$00,$01
		db $01,$01,$01,$01



macro screenpointer(name)
	dw LevelList_<name>-LevelList
	dw LevelList_<name>_end-LevelList
endmacro


	ScreenSpeedup:
		%screenpointer(Screen11)
		%screenpointer(Screen12)
		%screenpointer(Screen13)
		%screenpointer(Screen14)
		%screenpointer(Screen15)
		%screenpointer(Screen16)
		%screenpointer(Screen21)
		%screenpointer(Screen22)
		%screenpointer(Screen23)
		%screenpointer(Screen24)
		%screenpointer(Screen25)
		%screenpointer(Screen26)
		%screenpointer(Screen31)
		%screenpointer(Screen32)
		%screenpointer(Screen33)
		%screenpointer(Screen34)
		%screenpointer(Screen35)
		%screenpointer(Screen36)
		%screenpointer(Screen41)
		%screenpointer(Screen42)
		%screenpointer(Screen43)
		%screenpointer(Screen44)
		%screenpointer(Screen45)
		%screenpointer(Screen46)

		.Y
		db 0*4,6*4,12*4,18*4



