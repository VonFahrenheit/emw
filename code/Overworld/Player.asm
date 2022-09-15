


	!MapSpeed		= $17
	!MapSpeedDiag		= $10
	!MapSpeedDiag2		= $0B



	Player:
		REP #$30

		LDA !MapEvent				;\
		ORA !CutsceneSmoothness			; |
		BEQ +					; |
		STZ $6DA2				; | no inputs while camera is out of control (during event)
		STZ $6DA4				; |
		STZ $6DA6				; |
		STZ $6DA8				; |
		+					;/



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
		LDA !MapLockCamera : BNE ..done		; no screen border interaction during event
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
		LDA !MapLockCamera : BEQ ..handlecam
		AND #$FF00 : BEQ ..notimer
		DEC !MapCameraTimer
		..notimer
		JMP .ReturnCamera
		..handlecam


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
		JSR UpdateCamera

		.ReturnCamera
		LDA !MapLockCamera : BNE ..done
		LDA $1A
		CMP $00 : BNE ..done
		LDA $1C
		CMP $02 : BNE ..done
		STZ !MapEvent
		..done


		.CapMultiPlayerCoords
		LDA !MapLockCamera : BNE ..done		; no screen border interaction during event
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
		LDA !P1MapX : STA $E0
		LDA !P1MapY : STA $E2
		LDA #$000C
		STA $E4
		STA $E6

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
		LDY !BigRAM+0					; Y = index to level list
		PHX						;\
		LDA LevelList+6,y				; |
		AND #$00FF : TAX				; | see if level is unlocked
		LDA !LevelTable4,x				; |
		PLX						; |
		AND #$0080 : BEQ ..next				;/

		LDA LevelList+0,y : STA $E8
		LDA LevelList+2,y : STA $EA
		LDA LevelList+4,y : STA $EE-1
		AND #$00FF : STA $EC
		SEP #$30
		STZ $EF

		JSL CheckContact
		REP #$30
		BCS ..load
		..next
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
		AND #$00FF
		ORA !MapEvent				; event flag
		ORA !CutsceneSmoothness			; cutscene effect
		BNE ..return
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
		DEC A				; draw 1px up
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
		BIT !P1MapForceFlip-1,x
		BPL $03 : EOR #$8000
		BVC $03 : EOR #$4000
		STA $04

		CPX #$0000 : BEQ +
		LDA #$0202 : TSB $04
		+


		LDA !MapHidePlayers : BEQ ..nothidden	;\
		STX $0A					; | don't draw to OAM if hidden
		BRA ..noshadow				; |
		..nothidden				;/

		LDY !MapOAMindex
		CPY #$0100 : BCS ..fail
		LDA $06 : STA !MapOAMdata+$000,y
		LDA #$0005 : STA !MapOAMdata+$002,y
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
		INC A : STA !OAM_p0+$001,x
		LDA #$1EE0 : STA !OAM_p0+$002,x
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
		JSL GetVRAM : BCS ..done
		REP #$20
		LDA #$0040 : STA !VRAMbase+!VRAMtable+$00,x
		LDA #$007F : STA !VRAMbase+!VRAMtable+$04,x
		LDA $0E
		XBA
		LSR #3
		STA !VRAMbase+!VRAMtable+$02,x
		LDA $0C : STA !VRAMbase+!VRAMtable+$05,x
		JSL GetVRAM : BCS ..done
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

		LDA !P1MapDiag2,x : BEQ +
		TYA
		ORA #$10
		TAY
		STZ !P1MapDiag2,x
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



; debug: skip collision with R
	if !Debug = 1
	LDA $6DA4
	AND #$0010 : BEQ .Collision
	JMP .Collision_done
	endif

		.Collision


	LDA !P1MapGhost,x
	AND #$000F : BEQ $03 : JMP ..done





		LDA !P1MapXSpeed,x
		AND #$00FF
		STA !BigRAM+$10
		STA !BigRAM+$12
		STA !BigRAM+$14
		STA !BigRAM+$16
		LDA !P1MapYSpeed,x
		AND #$00FF
		STA !BigRAM+$18
		STA !BigRAM+$1A
		STA !BigRAM+$1C
		STA !BigRAM+$1E

		LDY #$0000				; index = 0

		..loop					;\
		LDA #$0000 : STA !BigRAM,y		; > clear collision
		LDA #$0000 : STA !BigRAM+$70,y		; > clear corner correction
		LDA !BigRAM+$10,y : BEQ ..next		; |
		EOR .CollisionBits,y			; |
		AND #$0080 : BNE ..next			; |
		LDA Collision_X,y			; |
		CLC : ADC !P1MapX,x			; |
		STA $0C					; | get collision
		STA !BigRAM+$40,y			; > save collision point X
		AND #$0007 : STA !BigRAM+$20,y		; > save within-tile X
		LDA Collision_Y,y			; |
		CLC : ADC !P1MapY,x			; |
		STA $0E					; |
		STA !BigRAM+$50,y			; > save collision point Y
		AND #$0007 : STA !BigRAM+$30,y		; > save within-tile Y
		JSR ReadTile				; |
		..next					; |
		INY #2					; |
		CPY #$0010 : BCC ..loop			;/



; clear both speeds if holding into wall
; and...
;
; R2 = D2 = bot right
;
; L2 = D1 = bot left
;
; R1 = U2 = top right
;
; L1 = U1 = top left
;
; + snap to position (HOW TO DO THIS???)
		LDA $6DA2
		AND #$000F : TAY

		CPY #$0005 : BNE +
		LDA #$0002*$400
		CMP !BigRAM+$02 : BEQ ++
		CMP !BigRAM+$0A : BEQ ++
		+
		CPY #$0006 : BNE +
		LDA #$0003*$400
		CMP !BigRAM+$06 : BEQ ++
		CMP !BigRAM+$08 : BEQ ++
		+
		CPY #$0009 : BNE +
		LDA #$0004*$400
		CMP !BigRAM+$00 : BEQ ++
		CMP !BigRAM+$0E : BEQ ++
		+
		CPY #$000A : BNE +
		LDA #$0005*$400
		CMP !BigRAM+$04 : BEQ ++
		CMP !BigRAM+$0C : BNE +
	++	SEP #$20
		STZ !P1MapXSpeed,x
		STZ !P1MapYSpeed,x
		REP #$20
		+
		..nodiagcollision


; if R1 = top right
; and R2 = bot right
;	- cap X
;	- set Y
;
; if D1 = bot left
; and D2 = bot right
;	- set X
;	- cap Y
;
; if L1 = top left
; and L2 = bot left
;	- cap X
;	- set Y
;
; if U1 = top left
; and U2 = top right
;	- set X
;	- cap Y

		LDA !BigRAM+$00				;\ if R1 = top right
		CMP #$0004*$400 : BNE +			;/
		LDA !BigRAM+$02				;\ and R2 = bot right
		CMP #$0002*$400 : BNE +			;/
		LDA !P1MapX,x
		AND #$0007
		CMP #$0004 : BCC +
		LDA !P1MapX,x
		AND #$FFF8
		ORA #$0004 : STA !P1MapX,x
		LDA !BigRAM+$50
		AND #$FFF8
		ORA #$0000 : STA !P1MapY,x
		LDA #$0000
		STA !BigRAM+$00
		STA !BigRAM+$02
		SEP #$20
		STZ !P1MapXSpeed,x
		REP #$20
		+

		LDA !BigRAM+$04				;\ if L1 = top left
		CMP #$0005*$400 : BNE +			;/
		LDA !BigRAM+$06				;\ and L2 = bot left
		CMP #$0003*$400 : BNE +			;/
		LDA !P1MapX,x
		AND #$0007
		CMP #$0004+1 : BCS +
		LDA !P1MapX,x
		AND #$FFF8
		ORA #$0004 : STA !P1MapX,x
		LDA !BigRAM+$54
		AND #$FFF8
		ORA #$0000 : STA !P1MapY,x
		LDA #$0000
		STA !BigRAM+$04
		STA !BigRAM+$06
		SEP #$20
		STZ !P1MapXSpeed,x
		REP #$20
		+

		LDA !BigRAM+$08				;\ if D1 = top left
		CMP #$0003*$400 : BNE +			;/
		LDA !BigRAM+$0A				;\ and D2 = bot left
		CMP #$0002*$400 : BNE +			;/
		LDA !P1MapY,x
		AND #$0007
		CMP #$0004 : BCC +
		LDA !BigRAM+$48
		AND #$FFF8
		ORA #$0000 : STA !P1MapX,x
		LDA !P1MapY,x
		AND #$FFF8
		ORA #$0004 : STA !P1MapY,x
		LDA #$0000
		STA !BigRAM+$08
		STA !BigRAM+$0A
		SEP #$20
		STZ !P1MapYSpeed,x
		REP #$20
		+

		LDA !BigRAM+$0C				;\ if U1 = top left
		CMP #$0005*$400 : BNE +			;/
		LDA !BigRAM+$0E				;\ and U2 = bot left
		CMP #$0004*$400 : BNE +			;/
		LDA !P1MapY,x
		AND #$0007
		CMP #$0004+1 : BCS +
		LDA !BigRAM+$4C
		AND #$FFF8
		ORA #$0000 : STA !P1MapX,x
		LDA !P1MapY,x
		AND #$FFF8
		ORA #$0004 : STA !P1MapY,x
		LDA #$0000
		STA !BigRAM+$0C
		STA !BigRAM+$0E
		SEP #$20
		STZ !P1MapYSpeed,x
		REP #$20
		+




; bot right:
; if R1 Y = 0, immediately move player 1 px up (+ set R2 = bot right)
; if D1 X = 0, immediately move player 1 px left (+ set D2 = bot right)

; bot left:
; if L1 Y = 0, immediately move player 1 px up (+ set L2 = bot left)
; if D2 X = 7, immediately move player 1 px right (+ set D1 = bot left)

; top right
; if R2 Y = 7, immediately move player 1 px down (+ set R1 = top right)
; if U1 X = 0, immediately move player 1 px left (+ set U2 = top right)

; top left
; if L2 Y = 7, immediately move player 1 px down (+ set L1 = top left)
; if U2 X = 7, immediately move player 1 px right (+ set U1 = top left)

		LDA !BigRAM+$30 : BNE +
		LDA !BigRAM+$00				;
		CMP #$0002*$400 : BNE +			; if R1 = bot right
		STA !BigRAM+$72
		DEC !P1MapY,x
		LDA #$0000 : STA !BigRAM+$00
		+

		LDA !BigRAM+$32
		CMP #$0007 : BNE +
		LDA !BigRAM+$02				; 
		CMP #$0004*$400 : BNE +			; if R2 = top right
		STA !BigRAM+$70
		INC !P1MapY,x
		LDA #$0000 : STA !BigRAM+$02
		+

		LDA !BigRAM+$34 : BNE +
		LDA !BigRAM+$04				; 
		CMP #$0003*$400 : BNE +			; if L1 = bot left
		STA !BigRAM+$76
		DEC !P1MapY,x
		LDA #$0000 : STA !BigRAM+$04
		+

		LDA !BigRAM+$36
		CMP #$0007 : BNE +
		LDA !BigRAM+$06				; 
		CMP #$0005*$400 : BNE +			; if L2 = top left
		STA !BigRAM+$74
		INC !P1MapY,x
		LDA #$0000 : STA !BigRAM+$06
		+

		LDA !BigRAM+$28 : BNE +
		LDA !BigRAM+$08				; 
		CMP #$0002*$400 : BNE +			; if D1 = bot right
		STA !BigRAM+$7A
		DEC !P1MapX,x
		LDA #$0000 : STA !BigRAM+$08
		+

		LDA !BigRAM+$2A
		CMP #$0007 : BNE +
		LDA !BigRAM+$0A				; 
		CMP #$0003*$400 : BNE +			; if D2 = bot left
		STA !BigRAM+$78
		INC !P1MapX,x
		LDA #$0000 : STA !BigRAM+$0A
		+

		LDA !BigRAM+$2C : BNE +
		LDA !BigRAM+$0C				; 
		CMP #$0004*$400 : BNE +			; if U1 = top right
		STA !BigRAM+$7E
		DEC !P1MapX,x
		LDA #$0000 : STA !BigRAM+$0C
		+

		LDA !BigRAM+$2E
		CMP #$0007 : BNE +
		LDA !BigRAM+$0E				; 
		CMP #$0005*$400 : BNE +			; if U2 = top left
		STA !BigRAM+$7C
		INC !P1MapX,x
		LDA #$0000 : STA !BigRAM+$0E
		+

		LDY #$000E				;\
	-	LDA !BigRAM+$70,y : BEQ +		; | apply corner correction to tile numbers
		STA !BigRAM,y				; |
	+	DEY #2 : BPL -				;/



		LDY #$0000
	-	LDA Collision_X,y
		CLC : ADC !P1MapX,x
		STA $0C
		LDA Collision_Y,y
		CLC : ADC !P1MapY,x
		STA $0E
		JSR RunTile : BEQ +
		JSR Collision				; |
	+	INY #2
		CPY #$0010 : BCC -

		..done



		.UpdateSpeed

	LDA !P1MapGhost,x
	AND #$000F
	CMP #$000F : BEQ ++
	LDA !P1MapGhost,x
	AND #$0003 : BEQ +
	SEP #$20
	STZ !P1MapYSpeed,x
	REP #$20
	+
	LDA !P1MapGhost,x
	AND #$000C : BEQ ++
	SEP #$20
	STZ !P1MapXSpeed,x
	REP #$20
	++


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

		REP #$30

		.CapZ
		LDA !P1MapZ,x : BPL ..done
		STZ !P1MapZ,x
		SEP #$20
		STZ !P1MapZSpeed,x
		REP #$20
		..done





		.AnimSpeed
		SEP #$20
		LDA !Translevel : BEQ ..nopose
		BIT $6DA6 : BMI +
		..nopose


		.AnimDir
		LDA !Cutscene
		CMP #$02 : BEQ ..process
		LDA !WarpPipe : BEQ ..done
		..process
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

	.CollisionBits
		dw $0000,$0000
		dw $0080,$0080
		dw $0000,$0000
		dw $0080,$0080


	.SpeedTable
		..x
		db $00,!MapSpeed,-!MapSpeed,$00
		db $00,!MapSpeedDiag,-!MapSpeedDiag,$00
		db $00,!MapSpeedDiag,-!MapSpeedDiag,$00
		db $00,!MapSpeed,-!MapSpeed,$00

		db $00,!MapSpeedDiag2,-!MapSpeedDiag2,$00
		db $00,!MapSpeedDiag2,-!MapSpeedDiag2,$00
		db $00,!MapSpeedDiag2,-!MapSpeedDiag2,$00
		db $00,!MapSpeedDiag2,-!MapSpeedDiag2,$00

		..y
		db $00,$00,$00,$00
		db !MapSpeed,!MapSpeedDiag,!MapSpeedDiag,!MapSpeed
		db -!MapSpeed,-!MapSpeedDiag,-!MapSpeedDiag,-!MapSpeed
		db $00,$00,$00,$00

		db $00,$00,$00,$00
		db !MapSpeedDiag2,!MapSpeedDiag2,!MapSpeedDiag2,!MapSpeedDiag2
		db -!MapSpeedDiag2,-!MapSpeedDiag2,-!MapSpeedDiag2,-!MapSpeedDiag2
		db $00,$00,$00,$00


		..accel
		db $00,$01,$01,$00
		db $01,$00,$00,$01
		db $01,$00,$00,$01
		db $00,$01,$01,$00





; input:
;	$00 = pushout value
;	$02 = pushout direction
	Collision:
		LDA $02 : BNE .Vertical
		.Horizontal
		LDA $0C
		AND #$FFF8
		CLC : ADC $00
		STA !P1MapX,x
		SEP #$20
		STZ !P1MapXSpeed,x
		REP #$20
		RTS
		.Vertical
		LDA $0E
		AND #$FFF8
		CLC : ADC $00
		STA !P1MapY,x
		SEP #$20
		STZ !P1MapYSpeed,x
		REP #$20
		RTS


		.X
		dw $000F,$000F		; R1, R2
		dw $0000,$0000		; L1, L2
		dw $0004,$000C		; D1, D2
		dw $0004,$000C		; U1, U2

		.Y
		dw $0004,$000C		; R1, R2
		dw $0004,$000C		; L1, L2
		dw $000F,$000F		; D1, D2
		dw $0000,$0000		; U1, U2



; input:
;	Y = collision dir
;	$0C = X coord
;	$0E = Y coord
; output:
;	BNE -> collision, BEQ -> no collision
;	$00 = value to add to coordinate
;	$02 = pushout direction (0 = horizontal, 1 = vertical)
;
; RAM:
;	$00 - 24-bit tilemap pointer ($02 gets overwritten later)
;	$02 - player index
;	$08 - collision point index
;

	ReadTile:
		STY $08					; $08 = direction index

		LDA $0E+1
		AND #$00FF
		CMP #$0004 : BCS .FullSolid
		TAY
		LDA $0C+1
		AND #$00FF
		CMP #$0006 : BCS .FullSolid
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
		AND #$0007*$400
		LDY $08					; Y = direction index
		STA !BigRAM,y				; store collision type (this might not end up being used)
		RTS


	.FullSolid
		LDY $08
		LDA #$0001*$400 : STA !BigRAM,y
		RTS


	RunTile:
		LDA !BigRAM,y
		STY $08
		STX $02
		LSR A
		XBA
		TAX
		JMP (.TilePtr,x)

		.TilePtr
		dw .NotSolid				; 0
		dw .FullSolid				; 1
		dw .TriangleBotRight			; 2
		dw .TriangleBotLeft			; 3
		dw .TriangleTopRight			; 4
		dw .TriangleTopLeft			; 5
		dw .VerticalWall			; 6
		dw .HorizontalWall			; 7

	.FullSolid
		LDX $02					; X = player index
		LDY $08					; Y = direction index
		LDA .PushoutDirection,y : STA $02	; get pushout direction
		LDA .PushoutValue,y : STA $00		; get pushout value
		RTS

	.NotSolid
		LDX $02					; X = player index
		LDY $08					; Y = direction index
		LDA #$0000 : STA !BigRAM,y
	;	SEP #$02				; z = 1 (zero), no collision
		RTS


; input:
;	A - Y position of first solid pixel within column (counting from open side)
;	$00 - X position of first solid pixel within row (counting from open side)
;	$02 - player index


	.TriangleBotRight
		LDA ..fullsolid,y : BNE .TriangleClosed	; if touching flat side, full solid
		LDA $0C					;\
		AND #$0007 : STA $00			; |
		LDA $0E					; | check X + Y
		AND #$0007				; |
		CLC : ADC $00				; |
		CMP #$0007 : BCC .TriangleOpen		;/
		..pushout
		LDA $0E					;\ X position of first solid pixel (row) = Y coordinate
		AND #$0007 : STA $00			;/
		LDA $0C					;\
		AND #$0007				; | Y position of first solid pixel (column) = X coordinate
		BRA .TrianglePush			;/

		..fullsolid
		dw $FFFF,$0000		; R
		dw $FFFF,$FFFF		; L
		dw $FFFF,$0000		; D
		dw $FFFF,$FFFF		; U


	.TriangleBotLeft
		LDA ..fullsolid,y : BNE .TriangleClosed	; if touching flat side, full solid
		LDA $0C					;\
		AND #$0007				; |
		EOR #$0007 : STA $00			; > flip X
		LDA $0E					; | check X + Y
		AND #$0007				; |
		CLC : ADC $00				; |
		CMP #$0007 : BCC .TriangleOpen		;/
		..pushout
		LDA $0E					;\ X position of first solid pixel (row) = Y coordinate
		AND #$0007 : STA $00			;/
		LDA $0C					;\
		AND #$0007				; | Y position of first solid pixel (column) = -X coordinate
		EOR #$0007				; |
		BRA .TrianglePush			;/

		..fullsolid
		dw $FFFF,$FFFF		; R
		dw $FFFF,$0000		; L
		dw $0000,$FFFF		; D
		dw $FFFF,$FFFF		; U


	.TriangleClosed
		LDX $02					; X = player index
		LDY $08					; Y = direction index
		LDA .PushoutDirection,y : STA $02	; get pushout direction
		LDA .PushoutValue,y : STA $00		; get pushout value
		RTS

	.TriangleOpen
		LDX $02					; X = player index
		LDY $08					; Y = direction index
		LDA #$0000 : STA !BigRAM,y
	;	SEP #$02				; z = 1 (zero), no collision
		RTS


	.TrianglePush
		LDX $08
		STA $04
		LDA .PushoutValue_triangle,y
		JMP (..ptr,x)

		..ptr
		dw .TrianglePushDown	; R1
		dw .TrianglePushUp	; R2
		dw .TrianglePushDown	; L1
		dw .TrianglePushUp	; L2
		dw .TrianglePushRight	; D1
		dw .TrianglePushLeft	; D2
		dw .TrianglePushRight	; U1
		dw .TrianglePushLeft	; U2


	.TriangleTopRight
		LDA ..fullsolid,y : BNE .TriangleClosed	; full solid check
		LDA $0C					;\
		AND #$0007 : STA $00			; |
		LDA $0E					; |
		AND #$0007				; | check X + Y
		EOR #$0007				; > flip Y
		CLC : ADC $00				; |
		CMP #$0007 : BCC .TriangleOpen		;/
		..pushout
		LDA $0E					;\
		AND #$0007				; | X position of first solid pixel (row) = -Y coordinate
		EOR #$0007 : STA $00			;/
		LDA $0C					;\
		AND #$0007				; | Y position of first solid pixel (column) = X coordinate
		BRA .TrianglePush			;/

		..fullsolid
		dw $0000,$FFFF		; R
		dw $FFFF,$FFFF		; L
		dw $FFFF,$FFFF		; D
		dw $FFFF,$0000		; U


	.TriangleTopLeft
		LDA ..fullsolid,y : BNE .TriangleClosed	; full solid check
		LDA $0C					;\
		AND #$0007				; > flip X
		EOR #$0007 : STA $00			; |
		LDA $0E					; | check X + Y
		AND #$0007				; |
		EOR #$0007				; > flip Y
		CLC : ADC $00				; |
		CMP #$0007 : BCS $03 : JMP .TriangleOpen		;/
		..pushout
		LDA $0E					;\
		AND #$0007				; | X position of first solid pixel (row) = -Y coordinate
		EOR #$0007 : STA $00			;/
		LDA $0C					;\
		AND #$0007				; | Y position of first solid pixel (column) = -X coordinate
		EOR #$0007				; |
		JMP .TrianglePush			;/

		..fullsolid
		dw $FFFF,$FFFF		; R
		dw $0000,$FFFF		; L
		dw $FFFF,$FFFF		; D
		dw $0000,$FFFF		; U


	.TrianglePushRight
		LDX $02
		CLC : ADC $00
		SEC : SBC #$000A
		BRA .OutputTriangle

	.TrianglePushLeft
		LDX $02
		CLC : ADC #$0009
		SEC : SBC $00
		BRA .OutputTriangle

	.TrianglePushDown
		LDX $02
		CLC : ADC $04
		SEC : SBC #$000A
		BRA .OutputTriangle

	.TrianglePushUp
		LDX $02
		CLC : ADC #$0009
		SEC : SBC $04

	.OutputTriangle
		STA $00
		INC !P1MapDiag2,x
		LDA .PushoutDirection_triangle,y : STA $02	; get pushout direction
		REP #$02				; z = 0 (nonzero)
		RTS




	.WallOpen
		SEP #$02
		RTS

	.VerticalWall
		LDX $02
		LDA .SolidSide_vertical,y : BNE ..left

		..right
		LDA $0C
		AND #$0007
		CMP #$0004 : BCC .WallOpen
		LDA .PushoutValue,y
		CPY #$0008 : BCS .CloseWall
		CLC : ADC #$0004
		BRA .CloseWall

		..left
		LDA $0C
		AND #$0007
		CMP #$0004 : BCS .WallOpen
		LDA .PushoutValue,y
		CPY #$0008 : BCS .CloseWall
		SEC : SBC #$0004
		BRA .CloseWall


	.HorizontalWall
		LDX $02
		LDA .SolidSide_horizontal,y : BNE ..up

		..down
		LDA $0E
		AND #$0007
		CMP #$0004 : BCC .WallOpen
		LDA .PushoutValue,y
		CPY #$0008 : BCC .CloseWall
		CLC : ADC #$0004
		BRA .CloseWall

		..up
		LDA $0E
		AND #$0007
		CMP #$0004 : BCS .WallOpen
		LDA .PushoutValue,y
		CPY #$0008 : BCC .CloseWall
		SEC : SBC #$0004

	.CloseWall
		STA $00
		LDA .PushoutDirection,y : STA $02
		REP #$02
		RTS


	.SolidSide
		..horizontal
		dw $FFFF,$0000
		dw $FFFF,$0000
		..vertical
		dw $0000,$0000
		dw $FFFF,$FFFF
		dw $FFFF,$0000
		dw $FFFF,$0000


	.PushoutValue
		dw $FFF1,$FFF1		; R
		dw $0007,$0007		; L
		dw $FFF1,$FFF1		; D
		dw $0007,$0007		; U
		..triangle
		dw $0007,$FFF1		; R
		dw $0007,$FFF1		; L
		dw $0007,$FFF1		; D
		dw $0007,$FFF1		; U



	.PushoutDirection
		..cardinal
		dw $0000,$0000
		dw $0000,$0000
		..triangle
		dw $0002,$0002
		dw $0002,$0002
		dw $0000,$0000
		dw $0000,$0000






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



