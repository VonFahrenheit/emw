levelinitF:
		JML levelinit13




levelinit10:

		INC !SideExit

		REP #$20

		JSL level10_BGScroll


		LDA #$1388 : STA !P1Coins
		LDA !MultiPlayer
		AND #$00FF : BEQ .1P
		LSR !P1Coins
		LDA !P1Coins : STA !P2Coins
		.1P

		SEP #$20
		STZ !Level+4
		JML level10



levelinit11:
	;;;;;;;;;;;;;;;;;;;;;;;;;
	;	STZ $3E		;	; turn on mode0
	;;;;;;;;;;;;;;;;;;;;;;;;;


		LDX #$12
		LDA #$10
;	-	STZ !MarioPalData+0,x
;		STA !MarioPalData+1,x
;		DEX #2 : BPL -
	;	INC !MarioPalOverride


	RTL



levelinit12:
		LDA #$12 : STA !Translevel
		LDA #$10 : STA !41_WeatherFreq
		LDA #$00				; snow type (smallest)
		JSL Weather_LoadSnow
		RTL

levelinit13:
		LDA #$04 : STA !41_WeatherFreq
		LDA #$02				; snow type (flake)
		JSL Weather_LoadSnow

		LDA #$04 : STA $6D9D			;\ BG3 on main screen, everything else on sub
		LDA #$1B : STA $6D9E			;/

		REP #$20
		LDA #$0F02
		STA $4320
		STA $4330
		LDA #$0200 : STA !HDMA2source
		LDA #$0300 : STA !HDMA3source
		SEP #$20
		STZ $4324
		STZ $4334

		INC !SideExit
		JSL level13_HDMA
		INC $14
		JSL level13_HDMA
		DEC $14
		JML CLEAR_DYNAMIC_BG3


levelinit15:
		RTL


levelinit35:
		JSL .Setup

		LDA #$01 : STA !SmoothCamera
		JSL level35
		JSL InitCameraBox

		INC $14 : JSL level35_HDMA		;\ set up double-buffered HDMA
		DEC $14 : JSL level35_HDMA		;/
		RTL



	.Setup
; $0200/$0400 - color HDMA (512 bytes each)
; $0C00/$0C10 - priority HDMA
; $0C20/$0C80 - BG1 wave HDMA (indirect values at $0D00/$0D10)
; $40A000/$40A400 - BG2 HDMA
; $40A380/$40A780 - BG3 HDMA


		LDA #$01 : STA !3DWater			; enable 3D water
		LDA #$40 : STA !Level+6			; 3D water height

	LDA #$04 : STA !Level+3

		REP #$20				;
		LDA #$1440 : STA !3DWater_Color		; water color
		LDA #$2103 : STA $4320			;\ color HDMA
		LDA #$0200 : STA !HDMA2source		; |
		LDA #$0D43 : STA $4330			; | BG1 wave HDMA (indirect)
		LDA #$0C26 : STA !HDMA3source		; |
		LDA #$0F03 : STA $4350			; | BG2 parallax HDMA
		LDA #$1103 : STA $4360			; | BG3 parallax HDMA
		LDA #$2C01 : STA $4370			; | priority HDMA
		LDA #$0C00 : STA !HDMA7source		;/


		LDX #$00				;\
	-	LDA #$0010				; |
		STA $0C20+6,x : STA $0C80+6,x		; |
		STA $0C23+6,x : STA $0C83+6,x		; |
		STA $0C26+6,x : STA $0C86+6,x		; |
		STA $0C29+6,x : STA $0C89+6,x		; |
		LDA #$0D00 : STA $0C21+6,x		; | BG1 wave tables
		LDA #$0D04 : STA $0C24+6,x		; |
		LDA #$0D08 : STA $0C27+6,x		; |
		LDA #$0D0C : STA $0C2A+6,x		; |
		LDA #$0D10 : STA $0C81+6,x		; |
		LDA #$0D14 : STA $0C84+6,x		; |
		LDA #$0D18 : STA $0C87+6,x		; |
		LDA #$0D1C : STA $0C8A+6,x		; |
		TXA					; |
		CLC : ADC #$000C			; |
		TAX					; |
		CPX #$30 : BCC -			;/
		LDA #$0D00				;\
		STA $0C21 : STA $0C24			; | above water chunk
		LDA #$0D10				; |
		STA $0C81 : STA $0C84			;/
		STZ $0C20+6,x : STZ $0C80+6,x		; end table



		SEP #$20				;
		STZ $4324				; > bank for color HDMA
		STZ $4334				;\ bank for BG1 wave HDMA
		STZ $4337				;/
		LDA #$40 : STA $4354			; > bank for BG2 parallax HDMA
		LDA #$40 : STA $4364			; > bank for BG3 parallax HDMA
		STZ $4374				; > bank for priority HDMA

		LDA #$EC : TSB $6D9F
		RTL



levelinit36:
		RTL

levelinit37:
		RTL








levelF:
		LDA.b #level13_HDMA : STA !HDMAptr+0
		LDA.b #level13_HDMA>>8 : STA !HDMAptr+1
		LDA.b #level13_HDMA>>16 : STA !HDMAptr+2
		LDA #$01 : JML Weather



level10:

; .BGScroll by default
; .HDMA2 on screen 0x0A
; .HDMA if !BossData+0 is 6 or greater


		LDA.b #.BGScroll : STA !HDMAptr+0
		LDA.b #.BGScroll>>8 : STA !HDMAptr+1
		LDA.b #.BGScroll>>16 : STA !HDMAptr+2

		STZ $00


		REP #$20
		LDA #$0FE8 : JSL END_Right


		LDX !Translevel
		LDA !LevelTable1,x
		LSR A : BCS .nopause1
		LDA $1D
		CMP #$01 : BCC .nopause1	; pause on lower screens 00-01
		LDA $1B
		CMP #$02 : BCS .nopause1
		INC $00
		.nopause1

		LDA !LevelTable1,x
		AND #$02 : BNE .nopause2
		LDA $1D : BNE .nopause2		; pause on upper screens 00-02
		LDA $1B
		CMP #$03 : BCS .nopause2
		INC $00
		.nopause2

		LDA !LevelTable1,x
		AND #$04 : BNE .nopause3
		LDA $1D
		CMP #$02 : BCS .nopause3
		LDA $1B
		CMP #$05 : BEQ .p3
		CMP #$06 : BNE .nopause3
	.p3	INC $00
		.nopause3



		LDA $00 : STA !PauseThif


		STZ !SideExit
		LDY $1B
		CPY #$0E : BCC +
		BNE ++
		LDA $1A
		CMP #$F0 : BCC +
	++	INC !SideExit
	+	CPY #$0A : BCS .Scroll
		RTL
		.Scroll


		LDA !BossData+0
		AND #$7F
		CMP #$06 : BCS ++

		LDA $1B
		CMP #$0C : BCS +
		CMP #$0A : BEQ +++
		CMP #$0B : BCC ++
		STZ !EnableVScroll
		BRA ++

	+++	LDA.b #.HDMA2 : STA !HDMAptr+0
		LDA.b #.HDMA2>>8 : STA !HDMAptr+1
		LDA.b #.HDMA2>>16 : STA !HDMAptr+2

	++	JML .HandleGrind

	+	PEA.w .HandleGrind-1
		LDA !BossData+0
		ASL A
		TAX
		JMP (.GrindPtr,x)


		.GrindPtr
		dw .Init		; 00
		dw .GrindStart		; 01
		dw .Wait		; 02
		dw .SpawnBirdo		; 03
		dw .KillBirdo		; 04
		dw .RisingPlatform	; 05
		dw .EmptyPtr		; 06
		dw .EmptyPtr		; 07

		.EmptyPtr
		RTL


		.Init
		LDA #$80 : STA !SPC3
		STZ !EnableHScroll
		INC !BossData+0
		RTS

		.GrindStart
		LDA !Level+4
		CMP #$08 : BCS ..Next
		LDA $14
		AND #$0F : BNE ..R
		INC !Level+4
		LDA #$0F : STA !ShakeTimer
		LDA #$17 : STA !SPC4
	..R	RTL
	..Next	INC !BossData+0
		LDA #$37 : STA !SPC3
		RTS

		.Wait
		LDA !BossData+0 : BMI ..Main
	..Init	ORA #$80 : STA !BossData+0
		LDA #$FF : STA !BossData+1
	..Main	LDA !BossData+1 : BNE ..Go
		INC !BossData+0
	..Go	DEC !BossData+1
		RTS

		.SpawnBirdo
		JSL SpawnBirdo
		LDA #$A0 : STA $3210,x
		LDA #$80 : STA $3220,x
		LDA #$01 : STA $3240,x
		LDA #$01 : STA $3230,x
		LDA #$80 : STA $9E,x
		INC !BossData+0
		RTS

		.KillBirdo
		JSL FindBirdo
		CPY #$00 : BNE ..R
		INC !BossData+0
	..R	RTS


		.RisingPlatform
		LDA $14
		AND #$0F : BNE ..R
		LDA $14
		AND #$1F : BNE $03 : DEC !BG2BaseV
		LDA #$0F : STA !ShakeTimer
		LDA #$17 : STA !SPC4

		INC !BossData+1
		LDA !BossData+1
		CMP #$1A : BNE ..R
		INC !BossData+0

		LDA #$01 : STA !EnableHScroll
		LDA #$09 : STA !SPC4
		LDA #$60
		STA !P2VectorX-$80
		STA !P2VectorX
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX
		LDA #$FF
		STA !P2VectorAccX-$80
		STA !P2VectorAccX
		LDA #$C0
		STA !P2VectorY-$80
		STA !P2VectorY
		LDA #$40
		STA !P2VectorTimeY-$80
		STA !P2VectorTimeY
	..R	RTS


		.HandleGrind
		LDA !BossData+0
		AND #$7F : BEQ ..Grind
		CMP #$06 : BCC ..Plat

		STZ !Level+2
		LDA #$04 : STA !Level+3
		STZ !Level+4
		LDA $1B					;\ Only go fast until screen 0x0D is reached
		CMP #$0D : BCC ..Fast			;/
		CMP #$0E : BNE ..Slow
		STZ $6D9F
	..Slow	LDA #$01 : STA !Level+3
	..Fast	LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		STZ !EnableHScroll
		RTL

	..Grind	LDA #$01 : STA !Level+2
		STA !Level+3
		STZ !Level+4
		JML ScreenGrind

	..Plat	LDA #$FC
		STA !P2VectorX-$80
		STA !P2VectorX
		LDA #$02
		STA !P2VectorTimeX-$80
		STA !P2VectorTimeX
		JSL SpeedPlatform



	; Spawn Thif code

		LDA !BossData+0
		CMP #$02 : BCC .Return
		LDA $14
		AND #$0F : BNE .Return
		LDY #$00
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ +
		CMP #$08 : BNE ++
	+	LDA $35C0,x
		CMP #$17 : BNE ++
		INY

	++	DEX : BPL -
		LDA !Difficulty
		AND #$03
		INC A
		STA $00
		CPY $00 : BCS .Return
		JSL !GetSpriteSlot
		BMI .Return
		TYX
		LDA #$17 : STA $35C0,x		; custom sprite number
		LDA #$36 : STA $3200,x
		LDA #$01 : STA $3230,x
		JSL $07F7D2			; | > Reset sprite tables
		JSL $0187A7			; | > Reset custom sprite tables
		LDA !RNG			;\ Random table entry
		AND #$04 : TAY			;/
		LDA #$08 : STA $3590,x		; extra bits
		LDA .Table+0,y : STA $3220,x
		LDA .Table+1,y : STA $3250,x
		LDA #$50 : STA $3210,x
		LDA #$01 : STA $3240,x
		LDA #$A0 : STA $9E,x
		LDA .Table+2,y : STA $3320,x
		LDA .Table+3,y : STA $AE,x

		.Return
		RTL

		.Table
		dw $0BF0 : db $00,$10
		dw $0D10 : db $01,$F0


		.BGScroll
		PHP
		JSL ..main
		PLP
		RTL

		..main
		REP #$20
		LDA $1A
		LSR A
		STA $1E
		LSR A
		STA $22
		LDA $1C
		LSR A
		CLC : ADC #$0030
		STA $20
		LSR A
		CLC : ADC #$0070
		STA $24
		LDA $20
	-	CMP #$0120 : BCC +
		SEC : SBC #$0020
		STA $20
		BRA -
	+	RTL




		.HDMA
		PHP
		JSL ScreenGrind_HDMA
		JSL .BGScroll_main		; handle BG2/BG3 (returns with 16-bit A)

		LDA $1A
		CMP #$0D00 : BCC +
		CMP #$0DFF : BCC ++
	+	LDA #$004F			; this handles the post-impact crash scroll
		STA $0205
		DEC A
		STA $020A
		LDA $1A
		STA $0206
		STA $020B
		STA $0210
		LDA $1C
		STA $0208
		STA $020D
		LDA #$FFC0 : STA $0212
		PLP
		RTL

		.HDMA2
		PHP
		JSL .BGScroll_main		; handle BG2/BG3 (and set A 16-bit)
	++	LDA #$0002 : STA $41		; window 1 enable
		LDA #$0004 : TRB $6D9F		; end parallax at this point
		LDA #$2601 : STA $4330
		STZ $4334
		LDA #$0400 : STA !HDMA3source
		LDA #$0022 : STA $0400
		LDA #$0001 : STA $0403
		STZ $0406
		LDA #$FF00 : STA $0401
		XBA
		STA $0404
		LDA #$0008 : TSB $6D9F		; different channel so the platform won't disappear for 1 frame

		LDA $1C				; snap Y coord of camera to 0x0080
		SEC : SBC #$0005
		CMP #$0080
		BCS $03 : LDA #$0080
		STA $1C

		PLP
		RTL



	FindBirdo:
		LDY #$00
		LDX #$0F
	.Loop	LDA $3230,x : BEQ .Nope
		LDA $3590,x
		AND #$08 : BEQ .Nope
		LDA $35C0,x
		CMP #$19 : BNE .Nope
		INY				; +1 Birdo

	.Nope	DEX : BPL .Loop
		RTL


	SpawnBirdo:
		JSL !GetSpriteSlot
		TYX
		LDA #$36 : STA $3200,x		; > Sprite num
		LDA #$19 : STA $35C0,x		; custom sprite num
		JSL $07F7D2			; > Reset tables
		JSL $0187A7			; > Reset custom sprite tables
		LDA #$08 : STA $3590,x		; extra bits
		LDA $1B : STA $3250,x		; spawn on screen (X)
		RTL


	DebrisRNG:
		LDA !RNG				; generate random values
		AND #$07
		ASL A
		STA $00
		LDA !RNG
		AND #$38
		LSR #2
		STA $01
		LDA !RNG
		CLC
		ROL #4
		PHA
		AND #$04
		STA $02
		PLA
		ASL A
		AND #$04
		STA $03
		RTL


level11:

		LDY #$00						; avalanche physics
		REP #$20
	-	LDA !P2Water-$80,y					;\ no push while climbing
		LSR A : BCS +						;/
		LDA !P2YPosLo-$80,y : BMI +				; no wrap-around to the top
		LDA !Level+3
		AND #$00FF
		CLC : ADC !P2YPosLo-$80,y
		CMP #$01E8
		BCC +
		LDA !Difficulty
		AND #$0003
		ASL #3
		EOR #$FFFF
		SEC : SBC #$0020
		AND #$00FF
		ORA #$1000
		STA !P2VectorX-$80,y
		LDA #$0000 : STA !P2VectorAccX-$80,y
		LDA #$0202 : STA !P2VectorTimeX-$80,y
	+	CPY #$80 : BEQ +
		LDY #$80 : BRA -
	+	SEP #$20


		LDA !Level+2 : BNE .nope
		INC !Level+2

		JSL !GetCGRAM
		REP #$20						; make players black silhouettes
		LDA.w #$0040 : STA.l !VRAMbase+!CGRAMtable+$00,x
		LDA.w #.color : STA.l !VRAMbase+!CGRAMtable+$02,x
		LDA.w #.color>>8 : STA.l !VRAMbase+!CGRAMtable+$03,x
		SEP #$20
		LDA #$80 : STA.l !VRAMbase+!CGRAMtable+$05,x


		.nope

		LDA #$01
		LDY $1B
		CPY #$01 : BCC +
		LDA #$08
	+	CPY #$02 : BCC +
		LDA #$20
		CPY #$04 : BCC +

		CPY #$0C : BCC ++		; 0C+
		LDX #$00
		CPY #$12 : BCC $02 : INX #2	; if also over 12
		LDA !Level+2
		CMP .Avalanche2+1,x : BEQ .go	; make sure it actually staRTL at some point
		CMP .Avalanche2+0,x : BNE .lo
	.go	LDA !Level+3
		CMP .Avalanche2+0,x : BCS .lo
		CMP .Avalanche2+1,x
		BEQ .hi
		BCS +++
	.hi	LDA .Avalanche2+0,x : BRA +
	.lo	LDA .Avalanche2+1,x : BRA +


	++	LDA $14				; 02-0B
		LSR #5				;
		TAX				;
		LDA .Avalanche,x		;
	+	STA !Level+2


	+++	LDA $1B
		CMP #$0C : BCS .fast
		LDA $14
		LSR A : BCC +
	.fast	LDA !Level+5 : BEQ ++		; don't update while !Level+5 is nonzero
		DEC !Level+5
		BRA +
	++	LDA !Level+3			; !Level+3 changes until it hits !Level+2
		CMP !Level+2			; this controls the layer 3 Y position
		BEQ +

	++	BCC ++
		DEC !Level+3
		BRA .lastcheck
	++	INC !Level+3

	.lastcheck
		LDA $1B
		CMP #$0C : BCC +
		LDA !Level+2
		CMP !Level+3 : BNE +
		LDA #$20 : STA !Level+5		; freeze avalance for 32 frames each time it switches direction
		+

		REP #$20
		LDA #$19E8 : JSL END_Right





		LDA.b #.HDMA : STA.l !HDMAptr+0
		LDA.b #.HDMA>>8 : STA.l !HDMAptr+1
		LDA.b #.HDMA>>16 : STA.l !HDMAptr+2

		RTL

	.color
	dw $1000,$1000,$1000,$1000,$1000,$1000,$1000,$1000
	dw $1000,$1000,$1000,$1000,$1000,$1000,$1000,$1000
	dw $1000,$1000,$1000,$1000,$1000,$1000,$1000,$1000
	dw $1000,$1000,$1000,$1000,$1000,$1000,$1000,$1000

	.Avalanche
	db $48,$48,$48,$48
	db $80,$80,$80,$80

	.Avalanche2
	db $C0,$01	; screens 0C-11
	db $60,$01	; screens 13+


		.HDMA
	;	JSL level3_HDMA

		PHP
		REP #$20
		LDA $14
		AND #$00FF
		ASL #2
		CLC : ADC $1A
		STA $22

		LDA $1C
		SEC : SBC #$00E0
		CLC : ADC !Level+3
		BPL $03 : LDA #$0000			; prevent bottom of BG3 from showing up at the top
		STA $24

		PLP
		RTL



level12:
		LDA #$04 : JSL Weather
		RTL

level13:
		LDX #$0F				; sprite Yoshi Coin on this level is number 2
	-	LDA $3230,x
		CMP #$08 : BNE +
		LDA $3590,x
		AND #$08 : BEQ +
		LDA $35C0,x
		CMP #$22 : BNE +
		LDA #$02 : STA $BE,x
	+	DEX : BPL -


		LDA #$01 : JSL Weather


		REP #$20
		LDA.w #.HDMA : STA !HDMAptr+0
		LDA.w #.HDMA>>8 : STA !HDMAptr+1
		LDA #$1AE8 : JML END_Right


		.HDMA
		PHP
		REP #$30
		LDA $14
		AND #$000F
		BNE $03 : INC !Level+2
		INC !Level+4

		LDX #$0000
		LDA $14
		LSR A
		BCC $03 : LDX #$0100

		LDA #$0130
		SEC : SBC $20
		LSR A
		STA $0200,x
		BCC $01 : INC A
		STA $0203,x
		LDA #$0001 : STA $0206,x
		STZ $0209,x
		LDA $1E : STA $0207,x
		LSR #3
		CLC : ADC !Level+2
		STA $0201,x
		STA $0204,x
		LDA $1A
		LSR #2
		CLC : ADC $1A
		CLC : ADC !Level+4
		STA $22
		LDA $1C : STA $24
		SEP #$20
		LDA $14
		AND #$01
		INC A
		ASL #2
		TSB $6D9F
		EOR #$0C
		TRB $6D9F
		PLP
		RTL

level15:
		RTL


level35:
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

		JSL .Graphics		; returns 16-bit A

		LDA.w #.RoomPointers
		JML LoadCameraBox


		.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable
		dw .DoorList
		dw .DoorTable




;	Key ->	   X  Y  W  H  S  FX FY
;		   |  |  |  |  |  |  |
;		   V  V  V  V  V  V  V
;
.BoxTable
.Box0	%CameraBox(0, 0, 7, 7, $FF, 0, 0)

.ScreenMatrix	db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00

.DoorList	db $FF			; no doors
.DoorTable



	.Graphics
		LDA #$02 : STA $44			;\ translucency settings
		LDA #$24 : STA $40			;/

		STZ !BG2ModeV
		LDA #$C0 : STA !BG2BaseV


	REP #$20
	LDA !Level+6
	AND #$00FF
	ASL #4
	STA $00
	LDA !Level+2
	LDX !IceLevel : BNE .Write		; don't move water while frozen

	SEC : SBC $00
	BCC .Down

	.Up
	CMP #$0002 : BCC .Set
	LDA !Level+2
	SBC #$0002
	BRA .Write

	.Down
	CMP #$FFFE : BCS .Set
	LDA !Level+2
	ADC #$0002
	BRA .Write

	.Set
	LDA $00

	.Write
	STA !Level+2

;	LDX !P2Character-$80 : BEQ ++
;
;	LDX !IceLevel : BNE +
;	LDA !P2YPosLo-$80 : BMI ++
;	CMP !Level+2 : BCC ++
;	LDX #$80 : STX !P2ExtraBlock-$80
;	BRA ++
;
;+	LDA !Level+2
;	SEC : SBC #$0010
;	CMP !P2YPosLo-$80 : BCS ++
;	LDX #$04 : STX !P2ExtraBlock-$80
;	INC A
;	STA !P2YPosLo-$80
;	++


	LDX !IceLevel : BNE ++
	LDX #$0F
-	LDA $3240,x : STA $02
	LDA $3210-1,x : STA $00
	LDA $01
	CMP !Level+2 : BCC +
	LDA !SpriteExtraCollision,x
	ORA #$0080
	STA !SpriteExtraCollision,x
+	DEX : BPL -
	++


	LDA !3DWater_Color
	LDX !IceLevel
	BEQ $03 : LDA #$2880
	STA $00
	AND #$001F : STA $02
	LDA $00
	AND #$03E0 : STA $04
	LDA $00
	AND #$7C00 : STA $06

	LDA $6701
	STA $08
	AND #$001F : STA $0A
	LDA $08
	AND #$03E0 : STA $0C
	LDA $08
	AND #$7C00 : STA $0E

	LDA $0A
	CMP $02 : BEQ +
	BCS $03 : INC A : BRA +
	DEC A
+	STA $00

	LDA $0C
	CMP $04 : BEQ +
	BCS $05 : ADC #$0020 : BRA +
	SBC #$0020
+	TSB $00

	LDA $0E
	CMP $06 : BEQ +
	BCS $05 : ADC #$0400 : BRA +
	SBC #$0400
+	TSB $00


	LDA $00 : STA $6701
	RTL


		.HDMA
		PHP
		JSL levelD_HDMA

		PHB : PHK : PLB
		REP #$20
		LDA.w #.Gradient

; input
;	A = pointer to gradient (stored to $0C)
;	first word of gradient is byte count
;	second word of gradient is scanline count for each chunk
;	the rest is raw color data


		..3DWater
		STA $0C
		SEP #$20
		LDA #$80 : STA !HDMA6source		;\
		LDA $14					; |
		AND #$01				; | double buffer BG3 parallax table
		ASL #2					; |
		ORA #$A3				; |
		STA !HDMA6source+1			;/


; !BigRAM+$00 = h (horizon height on screen)
; !BigRAM+$10 = w (water height on screen)
; !BigRAM+$16 = Cx (closest chunk height on screen)


	; layer priority code

		LDA $14					;\
		AND #$01				; |
		ASL #4					; | index to double buffer
		STA $00					; |
		TAX					;/

		REP #$20				;\
		LDA $1C					; | determine perspective
		CLC : ADC #$0070			; |
		CMP !Level+2 : BCC .AboveWater		;/

		.BelowWater
		LDA !BigRAM+$16 : STA $0E		; wave effect will start at Cx
		LDA !BigRAM+$10				;\ check w
		BEQ ..LowP : BMI ..LowP			;/
		LDA !BigRAM+$16				;\ check Cx
		BEQ ..HighP : BMI ..HighP		;/
		STA $0C00,x				;\ above water chunk
		LDA #$1317 : STA $0C01,x		;/
		INX #3
		LDA !BigRAM+$10
		SEC : SBC !BigRAM+$16
		BNE $01 : INC A
		BRA ..HighP_w

	..HighP
		LDA !BigRAM+$10
	...w	STA $0C00,x
		LDA #$1304 : STA $0C01,x
		INX #3

	..LowP
		LDA #$0001 : STA $0C00,x		; final chunk is always the rest of the screen
		LDA #$1700 : STA $0C01,x
		STZ $0C03,x
		BRA .PrioDone

		.AboveWater
		LDA !BigRAM+$10 : STA $0E		; wave effect will start at w
		LDA !BigRAM+$00				;\
		LSR A					; |
		STA $0C00,x				; |
		BCC $01 : INC A				; | above water chunk
		STA $0C03,x				; |
		LDA #$1317				; |
		STA $0C01,x				; |
		STA $0C04,x				;/

		LDA !BigRAM+$10
		CMP #$00E0 : BCC ..HighP

	..LowP
		LDA #$0001 : STA $0C06,x		;\
		LDA #$1315 : STA $0C07,x		; | hi prio doesn't fit so just go with lo prio
		STZ $0C09,x				; |
		BRA .PrioDone				;/


	..HighP
		LDA !BigRAM+$10				;\
		SEC : SBC !BigRAM+$00			; | lo prio for w - h scanlines
		BNE $01 : INC A				; | (minimum 1 scanline)
		STA $0C06,x				; |
		LDA #$1315 : STA $0C07,x		;/
		LDA #$0001 : STA $0C09,x		;\ hi prio for rest of screen
		LDA #$1304 : STA $0C0A,x		;/
		STZ $0C0C,x				; end table
		.PrioDone

		SEP #$30
		LDA $00 : STA !HDMA7source		; double buffer this table



	; BG1 wave code

		REP #$20
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0060
		TAX
		CLC : ADC #$0C21+6			; get pointer and index to current tables
		STA $00
		SEP #$20


		LDA $14					;\
		LSR #2					; |
		AND #$0F				; |
		INC A					; | update scanline count to scroll wave effect
		STA $0C20+6,x				; |
		CMP #$01 : BNE .NoUpdate		; |
		LDA $14					; |
		AND #$02 : BNE .NoUpdate		;/

		.Update					;\
		LDY #$30				; |
	-	LDA ($00),y				; |
		AND #$F0				; > maintain hi nybble
		STA $02					; |
		LDA ($00),y				; |
		SEC : SBC #$04				; | update pointers for wave effect
		AND #$0F				; |
		ORA $02					; |
		STA ($00),y				; |
		DEY #3 : BPL -				; |
		.NoUpdate				;/

		REP #$20				;\
		LDA $0E					; |
		BPL $03 : LDA #$0000			; |
		LDY !IceLevel : BNE +			; > no wave effect when frozen
		CMP #$00E0				; |
		BCC $03					; |
	+	LDA #$00E0				; | distance to hi prio water from top of screen
		SEP #$20				; |
		LSR A					; |
		STA $0C20,x				; |
		BCC $01 : INC A				; |
		STA $0C23,x				;/
		LDA $00					;\ > lo byte of pointer
		SEC : SBC #$07				; |
		TAY					; |
		LDA $0C20,x				; |
		BNE $03 : INY #3			; | see how many chunks we need
		LDA $0C23,x				; |
		BNE $03 : INY #3			;/
		STY !HDMA3source			; > update source



	; +0+0
	; -1+0
	; -1+1
	; +0+1


		REP #$20				;\
		LDA $14					; |
		AND #$0001				; |
		BEQ $03 : LDA #$0010			; |
		TAX					; |
		LDA $1A					; |
		STA $0D00,x				; |
		STA $0D0C,x				; |
		DEC A					; |
		BPL $03 : LDA #$0000			; > don't allow negative due to clipping errors
		STA $0D04,x				; |
		STA $0D08,x				; | recalculate BG1 positions
		LDA $1C					; |
		STA $0D02,x				; |
		STA $0D06,x				; |
		INC A					; |
		STA $0D0A,x				; |
		STA $0D0E,x				;/



	; gradient and color filter code

		REP #$10				; > index 16-bit
		LDA $14					;\
		AND #$0001				; |
		XBA					; | X = double buffer index
		ASL A					; |
		STA $04					; > store to $04
		TAX					;/

		LDA !BigRAM+$00				;\
		CMP !BigRAM+$16				; |
		BMI $03 : LDA !BigRAM+$16		; |
		CMP #$0000				; | number of scanlines above water
		BPL $03 : LDA #$0000			; |
		CMP #$00E0				; |
		BCC $03 : LDA #$00E0			; |
		STA $00					;/
		LDA $00 : BEQ .Filter			; skip gradient if entirely under water

		LDA ($0C) : STA $0A			;\
		INC $0C					; |
		INC $0C					; | unpack gradient header
		LDA ($0C) : STA $0E			; |
		INC $0C					; |
		INC $0C					;/

		LDY #$0000				; Y = gradient table index
	-	REP #$20				;\
		STZ $0201,x				; | gradient data
		LDA ($0C),y : STA $0203,x		; |
		SEP #$20				;/
		LDA $0E : STA $0200,x			; gradient scanline count
		SEC : SBC $00				;\
		PHP					; |
		EOR #$FF : INC A			; | subtract from total scanlines allowed
		PLP					; |
		BCC +					;/

		LDA $00 : BEQ ++			; > ignore counts of 0
		STA $0200,x				;\
		INX #5					; | otherwise write
		BRA ++					;/

	+	STA $00					; store remaining scanlines allowed
		INX #5					;\
		INY #2					; | if allowed, loop
		CPY $0A : BNE -				;/

		LDA $00					;\
		CLC : ADC $0200-5,x			; | if entire gradient fit, extend bottom chunk
		STA $0200-5,x				;/

	++	REP #$20

		.Filter					;\
		LDA #$0001 : STA $0200,x		; |
		STZ $0201,x				; | apply background color and end table
		LDA $6701 : STA $0203,x			; |
		STZ $0205,x				; |
		.ColorDone				;/

		LDA $04					;\
		CLC : ADC #$0200			; | update double buffer
		STA !HDMA2source			;/

		PLB
		PLP
		RTL


.Gradient
		dw ..end-..start
		dw $0008
		..start
		dw $4CA0
		dw $48A0
		dw $4080
		dw $3C80
		dw $3880
		dw $3060
		dw $2C60
		dw $2860
		dw $2040
		dw $1C40
		dw $1840
		dw $1020
		dw $0C20
		dw $0400
		..end





level36:
		RTL

level37:
		RTL


