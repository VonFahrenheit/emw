




	!Temp = 0
	%def_anim(Mario_Walk_Front, 4)
	%def_anim(Mario_Walk_Back, 4)
	%def_anim(Mario_Walk_Side, 2)

	MarioAnim:
		; walk front
		dw .Front0 : db $08,!Mario_Walk_Front+1
		dw .Front1 : db $08,!Mario_Walk_Front+2
		dw .Front0 : db $08,!Mario_Walk_Front+3
		dw .Front2 : db $08,!Mario_Walk_Front+0

		; walk back
		dw .Back0 : db $08,!Mario_Walk_Back+1
		dw .Back1 : db $08,!Mario_Walk_Back+2
		dw .Back0 : db $08,!Mario_Walk_Back+3
		dw .Back2 : db $08,!Mario_Walk_Back+0

		; walk side
		dw .Side0 : db $08,!Mario_Walk_Side+1
		dw .Side1 : db $08,!Mario_Walk_Side+0


		.Front0
		db $04
		db $00,$00,$00,$31
		.Front1
		db $04
		db $00,$00,$02,$31
		.Front2
		db $04
		db $00,$00,$04,$31

		.Back0
		db $04
		db $00,$00,$20,$31
		.Back1
		db $04
		db $00,$00,$22,$31
		.Back2
		db $04
		db $00,$00,$24,$31

		.Side0
		db $04
		db $00,$00,$06,$31
		.Side1
		db $04
		db $00,$00,$08,$31



	Player:
		REP #$30
		LDX #$0000 : JSR ProcessPlayer
		REP #$30
		LDA !MultiPlayer
		AND #$00FF : BEQ +
		LDA $6DA2 : PHA
		LDA $6DA3 : STA $6DA2
		LDX.w #(!P2MapX)-(!P1MapX) : JSR ProcessPlayer
		REP #$30
		PLA : STA $6DA2
		+



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
		.CheckLevel
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
		..done


		.MoveCamera
		LDA !MultiPlayer
		AND #$00FF : BEQ ..single

		..multi
		LDA !P1MapX
		SEC : SBC !P2MapX
		BPL $04 : EOR #$FFFF : INC A
		CMP #$00C0 : BCC $03 : - : JMP ..capcamera
		LDA !P1MapY
		SEC : SBC !P2MapY
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0080 : BCS -

		LDA !P1MapX
		CLC : ADC !P2MapX
		LSR A
		SEC : SBC #$0078
		BPL $03 : LDA #$0000
		STA $00
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
		INC #2
		CMP #$0005 : BCC ..storeX
		LDA $1A
		CMP $00 : BCS ..decX
		..incX
		INC #3 : BRA ++
		..decX
		DEC #3 : BRA ++
		..storeX
		LDA $00
	++	STA $1A
		+
		LDA $1C
		SEC : SBC $02
		INC #2
		CMP #$0005 : BCC ..storeY
		LDA $1C
		CMP $02 : BCS ..decY
		..incY
		INC #3 : BRA ++
		..decY
		DEC #3 : BRA ++
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



		.Draw
		LDX #$0000 : JSR DrawPlayer
		LDA !MultiPlayer
		AND #$00FF : BEQ +
		LDX.w #(!P2MapX)-(!P1MapX) : JSR DrawPlayer
	+	LDA !Translevel : BEQ ..done
		LDA !OAMindex_p3 : TAX
		LDA !P1MapX
		SEC : SBC $1A
		AND #$00FF
		STA $00
		LDA !P1MapY
		SEC : SBC $1C
		STA $01
		LDA $13-1
		LSR #3
		AND #$0700
		SEC : SBC #$0400
		BPL $04 : EOR #$FFFF : INC A
		CLC : ADC $00
		SEC : SBC #$1400
		STA !OAM_p3+$000,x
		LDA #$3E2A : STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3+$00,x
		INX
		TXA
		ASL #2
		STA !OAMindex_p3


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




	DrawPlayer:
		.HandleAnim
		LDA !P1MapAnim,x
		AND #$00FF
		ASL #2
		TAY
		SEP #$20
		LDA !P1MapAnimTimer,x
		INC A
		CMP MarioAnim+2,y : BNE ..same
		LDA MarioAnim+3,y : STA !P1MapAnim,x
		REP #$20
		AND #$00FF
		ASL #2
		TAY
		SEP #$20
		LDA #$00
		..same
		STA !P1MapAnimTimer,x
		REP #$20
		LDA MarioAnim+0,y : STA $04


		.Draw
		LDA !P1MapDirection,x
		AND #$0001
		BEQ $03 : LDA #$4000
		EOR #$4000
		STA $06

		LDA !P1MapX,x
		SEC : SBC $1A
		STA $00
		LDA !P1MapY,x
		SEC : SBC $1C
		STA $02
		LDA ($04)
		AND #$00FF : STA $08
		INC $04
		LDY #$0000
		LDX !MapOAMindex
		LSR #2
		CLC : ADC $08
		STA !MapOAMdata+$002,x
		LDA $02 : STA !MapOAMdata+$000,x
		INX #4

		..loop
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		BIT $06
		BVC $04 : EOR #$FFFF : INC A
		CLC : ADC $00
		STA !MapOAMdata+$000,x
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $02
		STA !MapOAMdata+$001,x
		INY
		LDA ($04),y
		EOR $06
		STA !MapOAMdata+$002,x
		INY #2
		LDA #$0002 : STA !MapOAMdata+$004,x
		TXA
		CLC : ADC #$0005
		TAX
		CPY $08 : BCC ..loop
		TXA : STA !MapOAMindex
		INC !MapOAMcount
		RTS


	ProcessPlayer:
		SEP #$20


		.Controls
		LDA $6DA2
		LSR #2
		LSR A : BCS ..d
		LSR A : BCS ..u
		BRA ..horzdone
	..u	DEC !P1MapYSpeed,x : BRA ..horzdone
	..d	INC !P1MapYSpeed,x
		..horzdone

		LDA $6DA2
		LSR A : BCS ..r
		LSR A : BCS ..l
		BRA ..vertdone
	..l	DEC !P1MapXSpeed,x : BRA ..vertdone
	..r	INC !P1MapXSpeed,x
		..vertdone


		REP #$20

		.UpdateSpeed
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

		.FrictionX
		LDA $6DA2
		AND #$03 : BNE ..done
		LDA !P1MapXSpeed,x
		BEQ ..done
		BMI ..inc
		..dec
		DEC !P1MapXSpeed,x
		DEC !P1MapXSpeed,x
		BRA ..stopcheck
		..inc
		INC !P1MapXSpeed,x
		INC !P1MapXSpeed,x
		..stopcheck
		LDA !P1MapXSpeed,x
		INC A
		CMP #$03 : BCS ..done
		STZ !P1MapXSpeed,x
		..done

		.FrictionY
		LDA $6DA2
		AND #$0C : BNE ..done
		LDA !P1MapYSpeed,x
		BEQ ..done
		BMI ..inc
		..dec
		DEC !P1MapYSpeed,x
		DEC !P1MapYSpeed,x
		BRA ..stopcheck
		..inc
		INC !P1MapYSpeed,x
		INC !P1MapYSpeed,x
		..stopcheck
		LDA !P1MapYSpeed,x
		INC A
		CMP #$03 : BCS ..done
		STZ !P1MapYSpeed,x
		..done


		.CapSpeedX
		LDA !P1MapXSpeed,x : BMI ..neg
		..pos
		CMP #$20 : BCC ..done
		LDA #$20 : STA !P1MapXSpeed,x
		BRA ..done
		..neg
		CMP #$E0 : BCS ..done
		LDA #$E0 : STA !P1MapXSpeed,x
		..done

		.CapSpeedY
		LDA !P1MapYSpeed,x : BMI ..neg
		..pos
		CMP #$20 : BCC ..done
		LDA #$20 : STA !P1MapYSpeed,x
		BRA ..done
		..neg
		CMP #$E0 : BCS ..done
		LDA #$E0 : STA !P1MapYSpeed,x
		..done








		REP #$30

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
		LDA !P1MapXSpeed,x
		BPL $03 : EOR #$FF : INC A
		STA $00
		LDA !P1MapYSpeed,x
		BPL $03 : EOR #$FF : INC A
		STA $01

		CLC : ADC $00
		BEQ ..0
		CMP #$10 : BCC ..1
		CMP #$18 : BCS ..done
		..2
		LDA $13
		LSR A : BCS ..dec
		BRA ..done
		..1
		LDA $13
		AND #$03 : BEQ ..done
		..dec
		DEC !P1MapAnimTimer,x
		BRA ..done
		..0
		LDA !P1MapAnim,x
		AND #$FE
		STA !P1MapAnim,x
		STZ !P1MapAnimTimer,x
		..done


		.AnimDir
		LDA $00
		ORA $01
		BEQ ..nodir

		LDA !P1MapYSpeed,x
		ROL A
		LDA !P1MapXSpeed,x		; gotta get negative values so can't use $00/$01
		ROL #2
		AND #$03 : STA !P1MapDirection,x
		..nodir

		LDA $01
		CMP $00
		BEQ ..done
		BCC ..side

		..frontback
		LDA !P1MapYSpeed,x : BMI ..back

		..front
		LDA !P1MapAnim,x
		CMP #!Mario_Walk_Front : BCC +
		CMP #!Mario_Walk_Front_over : BCC ..done
	+	LDA #!Mario_Walk_Front : BRA ..write

		..back
		LDA !P1MapAnim,x
		CMP #!Mario_Walk_Back : BCC +
		CMP #!Mario_Walk_Back_over : BCC ..done
	+	LDA #!Mario_Walk_Back : BRA ..write

		..side
		LDA !P1MapAnim,x
		CMP #!Mario_Walk_Side : BCC +
		CMP #!Mario_Walk_Side_over : BCC ..done
	+	LDA #!Mario_Walk_Side

		..write
		STA !P1MapAnim,x
		STZ !P1MapAnimTimer,x
		..done
		RTS





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



