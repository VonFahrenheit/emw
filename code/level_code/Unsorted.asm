


Halve:
	.8	BPL ..pos
	..neg	EOR #$FF
		LSR A
		EOR #$FF
		RTL
	..pos	LSR A
		RTL

	.16	BPL ..pos
	..neg	EOR #$FFFF
		LSR A
		EOR #$FFFF
		RTL
	..pos	LSR A
		RTL


Weather:
		PHP
		SEP #$30
		STA $00							; $00 = weather type
		LDA !41_WeatherTimer : BEQ .Spawn
		DEC A
		STA !41_WeatherTimer
		PLP
		RTL

		.Spawn
		LDA $14							;\
		AND #$1F						; | $02 = RN 1
		TAX							; |
		LDA !RNGtable,x : STA $02				;/
		INX							;\
		CPX #$20						; | $03 = RN 2
		BCC $02 : LDX #$00					; |
		LDA !RNGtable,x : STA $03				;/
		INX							;\
		CPX #$20						; | $04 = RN 3
		BCC $02 : LDX #$00					; |
		LDA !RNGtable,x : STA $04				;/

		REP #$10
		LDX !Particle_Index
		PHB
		LDA #$41
		PHA : PLB

		LDA !WeatherFreq : STA !WeatherTimer

		REP #$20
		LDY.w #!Particle_Count-1
	-	LDA !Particle_Type,x
		AND #$00FF : BEQ .ThisOne
		TXA
		CLC : ADC.w #!Particle_Size
		TAX
		CPX.w #!Particle_Count*!Particle_Size
		BCC $03 : LDX #$0000
		DEY : BPL -

		.ThisOne
		TXA : STA.l !Particle_Index
		LDA $00
		STX $00
		AND #$00FF
		ASL A
		CMP.w #.SpawnPtr_End-.SpawnPtr
		BCC $03 : LDA #$0000
		TAX
		JSR (.SpawnPtr,x)

	.Done	PLB
		PLP
		RTL

		.SpawnPtr
		dw .CalmSnow
		dw .RagingSnow
		dw .SpellParticles		; this one can also be used for lava
		dw .MaskSpecial
		dw .LavaLord			; special one to be used for Lava Lord boss
		..End


	; --old--
	; speed: px/16 f
	; accel: px/128 f^2 (added to speed every 8 frames)

	; --new--
	; speed: px/256 f
	; accel: px/16 f^2

	; --convert--
	; speed: *16
	; accel: *8


		.CalmSnow
		LDX $00							; X = index
		LDA $02							;\
		AND #$00FF						; |
		ASL A							; | RN 1 determines X pos
		CLC : ADC $1A						; |
		SEC : SBC #$0080					; |
		STA !Particle_XLo,x					;/
		LDA $1C							;\
		SEC : SBC #$0008					; | Y pos = just above screen
		STA !Particle_XHi,x					;/
		LDA #$0100 : STA !Particle_YSpeed,x			; Y speed = 1px/frame
		STZ !Particle_XSpeed,x					; clear X speed
		STZ !Particle_XAcc,x					;\ no acceleration
		STZ !Particle_YAcc,x					;/
		SEP #$20						; A 8-bit
		LDA #$FF : STA !Particle_Tile,x				; tile
		LDA #$FF : STA !Particle_Prop,x				; prop
		LDA #$02 : STA !Particle_Layer,x			; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
		RTS							; return


		.RagingSnow
		LDX $00							; X = index
		LDA $02							;\
		AND #$00FF						; |
		LSR A							; | RN 1 determines X pos
		ORA #$0100						; |
		CLC : ADC $1A						; |
		STA !Particle_XLo,x					;/
		LDA $03							;\
		AND #$00FF						; |
		STA $00							; |
		LSR #2							; |
		SEC : SBC $00						; | RN 2 determines Y pos
		EOR #$FFFF : INC A					; |
		CLC : ADC $1C						; |
		SEC : SBC #$0080					; |
		STA !Particle_YLo,x					;/
		LDA $04							;\
		AND #$003F						; |
		CMP #$0020						; | RN 3 determines X speed
		BCC $03 : LDA #$0020					; | (50% chance 32, 50% chance 33-63)
		ASL #4							; |
		STA !Particle_XSpeed,x					;/
		LDA $04							;\
		AND #$0080						; | highest bit of RN 3 determines Y speed
		ASL A							; | (50% 16, 50% chance 32)
		ADC #$0100						; |
		STA !Particle_YSpeed,x					;/
		LDA !Particle_XSpeed,x					;\
		CMP #$0200 : BEQ ..0					; |
		LDA !Particle_YLo,x					; |
		CMP $1C : BCC ..RN					; |
	..0	SEP #$20						; |
		LDA #$00						; | if X speed != 32 AND particle spawns to the side of the camera (rather than above)...
		BRA ..W							; | ...Y acc has a 50% chance of being -2, otherwise it is 0
	..RN	SEP #$20						; |
		LDA $04							; |
		AND #$40						; |
		ASL #2							; |
		ROL A							; |
		ASL A							; |
		DEC #2							; |
	..W	STA !Particle_YAcc,x					;/
		STZ !Particle_XAcc,x					; X acc = 0
		LDA #$FF : STA !Particle_Tile,x				; tile
		LDA #$FF : STA !Particle_Prop,x				; prop
		LDA #$02 : STA !Particle_Layer,x			; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
		RTS							; return


		.SpellParticles
		LDX $00							; X = index
		LDA $02							;\
		AND #$00FF						; |
		ASL #2							; | RN 1 determines X pos
		CLC : ADC $1A						; |
		SEC : SBC #$0180					; |
		STA !Particle_XLo,x					;/
		LDA $1C							;\
		CLC : ADC #$00D8					; | always spawn at the bottom of the screen
		STA !Particle_YLo,x					;/
		LDA $03							;\
		AND #$00F0						; | RN 2 determines X speed
		SEC : SBC #$0080					; |
		STA !Particle_XSpeed,x					;/
		LDA $04							;\
		AND #$00F0						; | RN 3 determines Y speed
		SEC : SBC #$0180					; |
		STA !Particle_YSpeed,x					;/
		SEP #$20						; A 8-bit
		LDA $03							;\
		AND #$04						; | third lowest bit of RN 2 determines X acc
		DEC #2							; |
		STA !Particle_XAcc,x					;/
		LDA $04							;\
		AND #$04						; | third lowest bit of RN 3 determines Y acc
		INC #2							; |
		STA !Particle_YAcc,x					;/
	..prop	LDA !GFX_Conjurex					;\
		AND #$80						; |
		ASL A							; | prop
		ROL A							; |
		ORA #$FA						; |
		STA !Particle_Prop,x					;/
		LDA !GFX_Conjurex					;\
		AND #$70						; |
		ASL A							; |
		STA $00							; |
		LDA !GFX_Conjurex					; | tile
		AND #$0F						; |
		ORA $00							; |
		CLC : ADC #$4D						; |
		STA !Particle_Tile,x					;/
		LDA #$02 : STA !Particle_Layer,x			; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
	..R	RTS


		.MaskSpecial
		LDX $00							; X = index
		STZ $00							; set up side
		LDA $02							;\ RN 1 determines which side to spawn particle on
		AND #$0001 : BEQ ..right				;/
	..left	LDA.l !Level+4						;\ see if left caster is alive
		AND #$0001 : BEQ ..R					;/
		DEC $00							;\ spawn on left side
		LDA #$0D60 : BRA ..W					;/

	..right	LDA.l !Level+4						;\ see if right caster is alive
		AND #$0002 : BEQ ..R					;/
		LDA #$0D90
	..W	STA !Particle_XLo,x
		LDA #$0148 : STA !Particle_YLo,x

		LDA $03							;\
		AND #$0006						; |
		PHX							; |
		TAX							; |
		LDA.l ..SpeedTable,x : STA $02				; |
		LDA.l ..AccelTable,x					; |
		PLX							; | get random speed and invert if spawning right side
		SEP #$20						; |
		BIT $00							; |
		BPL $03 : EOR #$FF : INC A				; |
		REP #$20						; |
		STA !Particle_XAcc,x					;/ > write Y acc via hi byte

		LDA $02							;\
		AND #$00FF						; |
		ASL #4							; |
		CMP #$0800						; | X speed
		BCC $03 : ORA #$F000					; |
		BIT $00							; |
		BPL $04 : EOR #$FFFF : INC A				; |
		STA !Particle_XSpeed,x					;/
		LDA $03							;\
		AND #$00FF						; |
		ASL #4							; | Y speed
		CMP #$0800						; |
		BCC $03 : ORA #$F000					; |
		STA !Particle_YSpeed,x					;/

		SEP #$20						;\ same prop/tile as spell particles
		JMP .SpellParticles_prop				;/

	..R	RTS



	..SpeedTable
	db $00,$F0
	db $FA,$FC
	db $F8,$F0
	db $FB,$00

	..AccelTable
	db $FE,$02
	db $FE,$F8
	db $00,$00
	db $00,$FA


		.MaskBox
		LDA !Particle_XLo,x
		CMP #$0D72 : BCC ..R
		CMP #$0D7E : BCS ..R
		LDA !Particle_YLo,x
		CMP #$0110 : BCC ..R
		CMP #$0118 : BCS ..R
		STZ !Particle_Type,x
	..R	RTS



		.LavaLord
		SEP #$20
		LDX #$0F
	-	LDA.l $3230,x
		CMP #$08 : BNE +
		LDA.l $3590,x
		AND #$08 : BEQ +
		LDA.l $35C0,x
		CMP #$20 : BEQ ++
	+	DEX : BPL -
		RTS

	++	LDA.l $3220,x : STA $02
		LDA.l $3250,x : STA $03
		LDA.l $3240,x : XBA
		LDA.l $3210,x


		REP #$20
		LDX $00
		STA !Particle_XLo,x
		LDA $02 : STA !Particle_XLo,x
		LDA $04
		AND #$0003
		XBA
		STA !Particle_XAcc,x						; X acc = 0, Y acc = 0-3 (Y written via hi byte)

		LDA $04
		AND #$00FC
		ASL #2
		SEC : SBC #$0200
		STA !Particle_XSpeed,x
		LDA #$FE00 : STA !Particle_YSpeed

		SEP #$20
		LDA #$FF : STA !Particle_Tile,x					; tile
		LDA #$FF : STA !Particle_Prop,x					; prop
		LDA #$02 : STA !Particle_Layer,x				; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x			; type
		RTS



		.LoadSnow
		PHB : PHK : PLB
		STA $00					; store weather type
		JSL !GetVRAM
		REP #$30
		LDY.w #!File_Sprite_BG_1
		JSL !GetFileAddress
		SEP #$10

		LDA #$0020 : STA.l !VRAMbase+!VRAMtable+$00,x
		LDY $00
		LDA.w .Data,y
		CLC : ADC !FileAddress
		STA.l !VRAMbase+!VRAMtable+$02,x
		LDA !FileAddress+2 : STA.l !VRAMbase+!VRAMtable+$04,x
		LDA #$7FF0 : STA.l !VRAMbase+!VRAMtable+$05,x
		SEP #$20

		.Data
		dw $0FC0,$0FE0




; set 16-bit A to GFX number, then call this
DecompressGFX:
		LDX.b #!GFX_buffer : STX $00
		LDX.b #!GFX_buffer>>8 : STX $01
		LDX.b #!GFX_buffer>>16 : STX $02
		JSL !DecompressFile
		RTL



; set 16-bit A to dest VRAM, then call this (source should be in $00-$02, so call after DecompressGFX)
; set 8-bit X to source tile
; set 8-bit Y to upload size (number of 4bpp 8x8 tiles, so x32)
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
		RTL



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
		PHB : PLA
		STA $02
		JSR $1E80
		RTL


		.SA1
		PHB
		PHP
		SEP #$20
		LDA $02
		PHA : PLB				; maintain bank from SNES CPU
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



		LDA !P2Status-$80 : BEQ .GetCoords
		LDA !P2Status : BEQ .GetCoords
		PLP
		PLB
		RTL

		.GetCoords
		REP #$20
		LDX !P2Status-$80
		BEQ $02 : LDX #$80
		LDA !P2XPosLo-$80,x : STA $00
		LDA !P2YPosLo-$80,x : STA $02
		LDX #$00
		LDA !MultiPlayer
		AND #$00FF
		BEQ $02 : LDX #$80
		LDY !P2Status-$80,x : BNE .CalcRoom
		LDA !P2XPosLo-$80,x
		CLC : ADC $00
		ROR A
		BPL $03 : LDA #$0000
		XBA
		STA $00
		LDA !P2YPosLo-$80,x
		CLC : ADC $02
		ROR A
		BPL $03 : LDA #$0000
		STA $02

		.CalcRoom
		LDA $02
		CMP !LevelHeight
		BCC $04 : LDA !LevelHeight : DEC A
		LDX #$00
	-	CMP #$00E0 : BCC +
		SBC #$00E0
		INX
		BRA -
		+

		LDA !LevelWidth
		EOR #$FFFF : INC A
	-	CLC : ADC !LevelWidth
		DEX : BPL -
		CLC : ADC $00
		TAY
		LDA ($08),y
		AND #$00FF
		STA !BigRAM+0
		TAY : STY !CameraBoxRoom		; store room index


	; door loader
		PEI ($0A)
		PHP
		SEP #$20
		LDA !CameraForceTimer : BEQ $03 : JMP .NoDoor
		STZ $00
		LDY #$00
	--	LDA ($0C),y : BPL +
		CMP #$80 : BNE ++
		JMP .NoDoor
	++	JMP .NextIndex

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
		LDA ($0C),y : BMI +
		JMP -
	+	CMP #$80 : BEQ .NoDoor

	.NextIndex
		INY
		INC $00
		LDA $00
		CMP !BigRAM+0 : BCS .NoDoor
		JMP --


	.NoDoor
		PLP
		PLA : STA $0A


	; camera box
		LDA !BigRAM+0
		ASL A
		STA $00
		ASL #2
		CLC : ADC $00
		CLC : ADC $0A
		STA $0A
		LDY #$00
		LDA !LevelInitFlag			;\ don't do the update during level init
		AND #$00FF : BNE .Old			;/

	-	LDA ($0A),y
		CMP !CameraBoxL,y : BNE .New
		INY #2
		CPY #$08 : BCC -

	.Old	JSR .Load

		PLP
		PLB
		RTL


	.New	LDY !GameMode				;\ don't run this until level is properly going
		CPY #$14 : BNE .Old			;/
		LDY #$0F
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
		LDY #$00				; reset index
	-	LDA ($0A),y : STA !CameraBoxL,y
		INY #2
		CPY #$08 : BCC -
		LDA ($0A),y : STA !CameraForbiddance

		LDA !LevelHeight
		SEC : SBC #$0100
		BPL $03 : LDA #$0000
		CMP !CameraBoxD : BCS +
		STA !CameraBoxD
		CMP !CameraBoxU : BCS +
		STA !CameraBoxU
		+

		RTS


; figure out which $E0 block the door is on vertically, then chain to that

	.CameraChain
		PHB : PHK : PLB
		LDY.b #.ScreensEnd-.VerticalScreens-2
		LDA $0B : XBA
		LDA $05
		REP #$20
	-	CMP .VerticalScreens,y : BCS +
		DEY #2 : BPL -
		PLB
		RTS

	+	LDA .VerticalScreens,y
		SEC : SBC !CameraBackupY
		STA $02
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0008 : BCS +
		LDA .VerticalScreens,y : STA !CameraBackupY
		PLB
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
		PLB
		RTS


		.VerticalScreens
		dw $0000,$00E0,$01C0,$02A0,$0380,$0460,$0540,$0620
		dw $0700,$07E0,$08C0,$09A0,$0A80,$0B60,$0C40,$0D20
		dw $0E00,$0EE0,$0FC0,$10A0,$1180,$1260,$1340,$1420
		dw $1500,$15E0,$16C0,$17A0,$1880,$1960,$1A40,$1B20
		.ScreensEnd



	InitCameraBox:
		PHB : PHK : PLB
		PHP
		REP #$20

		LDA !CameraBoxL
		ADC !CameraBoxR
		ADC #$0100
		LSR A
		CMP $94 : BCS .PlayerLeftSide

		.PlayerRightSide
		LDA $94
		AND #$FF00 : STA $1A
		BRA +

		.PlayerLeftSide
		LDA $94
		SEC : SBC #$0080
		BPL $03 : LDA #$0000
		STA $1A
		LDA !CameraBoxL
		AND #$FF00 : STA !CameraXMem
		+


		; LDA $96
		; SEC : SBC #$0070
		; BPL $03 : LDA #$0000
		; LDY.b #LoadCameraBox_ScreensEnd-LoadCameraBox_VerticalScreens-2
	; -	CMP LoadCameraBox_VerticalScreens,y : BCS +
		; DEY #2 : BPL -
		; LDY #$00
	; +	LDA LoadCameraBox_VerticalScreens,y : STA $1C

		LDA !CameraBoxL
		CMP $1A : BCS .WriteX
		LDA !CameraBoxR
		CMP $1A : BCS .NoX
	.WriteX	STA $1A
		.NoX
		LDA $1A : STA !CameraBackupX

		LDA !CameraBoxU
		CMP $1C : BCS .WriteY
		LDA !CameraBoxD
		CMP $1C : BCS .NoY
	.WriteY	STA $1C
		.NoY
		LDA $1C : STA !CameraBackupY


		LDA $1C
		AND #$FFF0
		STA $00
		LDA #$0000
		LDY $1B : BEQ +
	-	CLC : ADC !LevelHeight
		DEY : BNE -
		+

		.Done
		PLP
		PLB
		RTL





; input:
;	A = sprite num / custom sprite num to search
; output:
;	all sprites matching the input will be erased
	KillSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA $3200,x
		CMP $00 : BNE ..next
		STZ $3230,x
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		STA $00
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !NewSpriteNum,x
		CMP $00 : BNE ..next
		STZ $3230,x
		..next
		DEX : BPL ..loop
		RTL

; input:
;	A = sprite num / custom sprite num to search
; output:
;	all sprites matching the input will be KO'd
	KOSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA $3200,x
		CMP $00 : BNE ..next
		LDA #$02 : STA $3230,x
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		STA $00
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !NewSpriteNum,x
		CMP $00 : BNE ..next
		LDA #$02 : STA $3230,x
		..next
		DEX : BPL ..loop
		RTL

; input:
;	A = sprite num / custom sprite num to search
; output:
;	A = how many sprites matching the input exist
;	$00 = A
	CountSprites:
	.Vanilla
		STZ $00
		STA $01
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA $3200,x
		CMP $01 : BNE ..next
		INC $00
		..next
		DEX : BPL ..loop
		LDA $00
		RTL

	.Custom
		STZ $00
		STA $01
		LDX #$0F
		..loop
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !NewSpriteNum,x
		CMP $01 : BNE ..next
		INC $00
		..next
		DEX : BPL ..loop
		LDA $00
		RTL

; input:
;	A = sprite num / custom sprite num to search
; output:
;	X = sprite num of matching target (0xFF if none are valid)
	SearchSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA $3200,x
		CMP $00 : BEQ ..thisone
		..next
		DEX : BPL ..loop
		..thisone
		RTL

	.Custom
		STA $00
		LDX #$0F
		..loop
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA $3230,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !NewSpriteNum,x
		CMP $00 : BEQ ..thisone
		..next
		DEX : BPL ..loop
		..thisone
		RTL


; input:
;	A = sprite num
;	$00 = 16-bit Xpos
;	$02 = 16-bit Ypos
; output:
;	X = sprite index (0xFF if invalid)
	SpawnSprite:
	.Vanilla
		LDX #$0F
		..loop
		LDY $3230,x : BNE ..next
		STA $3200,x
		STZ !ExtraBits,x
		LDA $00 : STA !SpriteXLo,x
		LDA $01 : STA !SpriteXHi,x
		LDA $02 : STA !SpriteYLo,x
		LDA $03 : STA !SpriteYHi,x
		JSL !ResetSprite
		INC $3230,x
		RTL
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		LDX #$0F
		..loop
		LDY $3230,x : BNE ..next
		STA !NewSpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		LDA $00 : STA !SpriteXLo,x
		LDA $01 : STA !SpriteXHi,x
		LDA $02 : STA !SpriteYLo,x
		LDA $03 : STA !SpriteYHi,x
		PHB
		JSL !ResetSprite
		PLB
		INC $3230,x
		RTL
		..next
		DEX : BPL ..loop
		RTL




	DisplayHitbox1:
	.OutsideJump
		JML .Outside

	.Main
		PHP
		SEP #$20
		STZ $41
		STZ $42
		STZ $43
		REP #$20
		LDA !P2Hitbox1+4-$80 : BEQ .OutsideJump
		AND #$00FF
		CLC : ADC !P2Hitbox1+0-$80
		STA $00					; $00 = x + w
		LDA !P2Hitbox1+5-$80
		AND #$00FF
		CLC : ADC !P2Hitbox1+2-$80
		STA $02					; $02 = y + h

		LDA $1A
		CLC : ADC #$0100
		STA $04					; $04 = screen right
		LDA $1C
		CLC : ADC #$00D8
		STA $06					; $06 = screen bottom


		LDA !P2Hitbox1+2-$80 : BMI .OverTop
		CMP $1C : BCC .OverTop

	.UnderTop
		CMP $06 : BCS .OutsideJump

	; case 5: outside

		LDA !P2Hitbox1+2-$80
		SEC : SBC $1C
		TAY
		LDA $02
		CMP $06 : BCC .YInside
		LDA $06
		SEC : SBC !P2Hitbox1+2-$80
		BRA .Height

	; case 4: visible $1C+0xD8-y


	.YInside
		LDA !P2Hitbox1+5-$80
		AND #$00FF
		BRA .Height

	; case 3: completely inside


	.OverTop
		LDA $02
		SEC : SBC $1C
		BCC .OutsideJump
		LDY #$00				; start at scanline 0

	; case 1: outside
	; case 2: visible y+h-$1C


	.Height
		STY $0F					; $0F = starting scanline
		TAY					; y = number of scanlines visible


		LDA !P2Hitbox1+0-$80 : BMI .LeftLeft
		CMP $1A : BCC .LeftLeft

	.RightLeft
		CMP $04 : BCS .OutsideJump

	; case E: outside

		LDA !P2Hitbox1+0-$80
		SEC : SBC $1A
		TAX
		LDA $00
		CMP $04 : BCC .XInside
		LDA $04
		SEC : SBC !P2Hitbox1+0-$80
		BRA .Width

	; case D: visible $1A+0x100-x


	.XInside
		LDA !P2Hitbox1+4-$80
		AND #$00FF
		BRA .Width

	; case C: completely inside


	.LeftLeft
		LDA $00
		SEC : SBC $1A
		BCS $03 : JMP .Outside
		LDX #$00				; x coord 0

	; case A: outside
	; case B: visible x+w-$1A


	.Width
		STX $0D
		SEP #$20
		CLC : ADC $0D
		BCC $02 : LDA #$FF			; cap at 0xFF
		STA $0E

	; $0D:	left border
	; $0E:	right border
	; $0F:	starting y coord
	; y:	number of scanlines visible


		LDA #$04 : STA !HDMA			; enable HDMA on channel 2
		LDA #$22
		STA $41
		STA $42
		STZ $43


		LDX #$00				; table index: 0
		LDA $0F : BEQ .InstantStart
		CMP #$40 : BCC +

		LSR A
		STA $0400
		BCC $01 : INC A
		STA $0403
		INX
		LDA #$FF : STA $0400,x
		STZ $0401,x
		INX #3
		BRA ++

	+	STA $0400
		INX
		LDA #$FF
	++	STA $0400,x				;\
		STZ $0401,x				; | set up skip lines
		INX #2					;/

	.InstantStart
		TYA : STA $0400,x			;\
		LDA $0D : STA $0401,x			; | write box
		LDA $0E : STA $0402,x			;/
		LDA #$01 : STA $0403,x			;\
		LDA #$FF : STA $0404,x			; | set up a final skip line
		STZ $0405,x				;/
		STZ $0406,x				; end table

		REP #$20
		LDA #$2601 : STA $4320
		STZ $4323
		LDA #$0400 : STA !HDMA2source
		STA $4322

		SEP #$20
		LDA $14
		AND #$01
		ASL #4
		TAX
		CLC : ADC #$10
		STA !HDMA2source
		STA $4322
		LDA $0400 : STA $0410,x
		LDA $0401 : STA $0411,x
		LDA $0402 : STA $0412,x
		LDA $0403 : STA $0413,x
		LDA $0404 : STA $0414,x
		LDA $0405 : STA $0415,x
		LDA $0406 : STA $0416,x
		LDA $0407 : STA $0417,x
		LDA $0408 : STA $0418,x
		LDA $0409 : STA $0419,x
		LDA $040A : STA $041A,x
		LDA $040B : STA $041B,x
		LDA $040C : STA $041C,x
		LDA $040D : STA $041D,x
		LDA $040E : STA $041E,x
		LDA $040F : STA $041F,x

	.Outside

		PLP
		RTL


	DisplayHitbox2:
	.OutsideJump
		JML .Outside

	.Main
		PHP
		REP #$20
		LDA !P2Hitbox2+4-$80 : BEQ .OutsideJump
		AND #$00FF
		CLC : ADC !P2Hitbox2+0-$80
		STA $00					; $00 = x + w
		LDA !P2Hitbox2+5-$80
		AND #$00FF
		CLC : ADC !P2Hitbox2+2-$80
		STA $02					; $02 = y + h

		LDA $1A
		CLC : ADC #$0100
		STA $04					; $04 = screen right
		LDA $1C
		CLC : ADC #$00D8
		STA $06					; $06 = screen bottom


		LDA !P2Hitbox2+2-$80 : BMI .OverTop
		CMP $1C : BCC .OverTop

	.UnderTop
		CMP $06 : BCS .OutsideJump

	; case 5: outside

		LDA !P2Hitbox2+2-$80
		SEC : SBC $1C
		TAY
		LDA $02
		CMP $06 : BCC .YInside
		LDA $06
		SEC : SBC !P2Hitbox2+2-$80
		BRA .Height

	; case 4: visible $1C+0xD8-y


	.YInside
		LDA !P2Hitbox2+5-$80
		AND #$00FF
		BRA .Height

	; case 3: completely inside


	.OverTop
		LDA $02
		SEC : SBC $1C
		BCC .OutsideJump
		LDY #$00				; start at scanline 0

	; case 1: outside
	; case 2: visible y+h-$1C


	.Height
		STY $0F					; $0F = starting scanline
		TAY					; y = number of scanlines visible


		LDA !P2Hitbox2+0-$80 : BMI .LeftLeft
		CMP $1A : BCC .LeftLeft

	.RightLeft
		CMP $04 : BCS .OutsideJump

	; case E: outside

		LDA !P2Hitbox2+0-$80
		SEC : SBC $1A
		TAX
		LDA $00
		CMP $04 : BCC .XInside
		LDA $04
		SEC : SBC !P2Hitbox2+0-$80
		BRA .Width

	; case D: visible $1A+0x100-x


	.XInside
		LDA !P2Hitbox2+4-$80
		AND #$00FF
		BRA .Width

	; case C: completely inside


	.LeftLeft
		LDA $00
		SEC : SBC $1A
		BCS $03 : JMP .Outside
		LDX #$00				; x coord 0

	; case A: outside
	; case B: visible x+w-$1A


	.Width
		STX $0D
		SEP #$20
		CLC : ADC $0D
		BCC $02 : LDA #$FF			; cap at 0xFF
		STA $0E

	; $0D:	left border
	; $0E:	right border
	; $0F:	starting y coord
	; y:	number of scanlines visible


		LDA #$08 : TSB !HDMA			; enable HDMA on channel 2
		LDA #$88
		TSB $41
		TSB $42


		LDX #$00				; table index: 0
		LDA $0F : BEQ .InstantStart
		CMP #$40 : BCC +

		LSR A
		STA $0600
		BCC $01 : INC A
		STA $0603
		INX
		LDA #$FF : STA $0600,x
		STZ $0601,x
		INX #3
		BRA ++

	+	STA $0600
		INX
		LDA #$FF
	++	STA $0600,x				;\
		STZ $0601,x				; | set up skip lines
		INX #2					;/

	.InstantStart
		TYA : STA $0600,x			;\
		LDA $0D : STA $0601,x			; | write box
		LDA $0E : STA $0602,x			;/
		LDA #$01 : STA $0603,x			;\
		LDA #$FF : STA $0604,x			; | set up a final skip line
		STZ $0605,x				;/
		STZ $0606,x				; end table

		REP #$20
		LDA #$2801 : STA $4330
		STZ $4333
		LDA #$0600 : STA !HDMA3source
		STA $4332

		SEP #$20
		LDA $14
		AND #$01
		ASL #4
		TAX
		CLC : ADC #$10
		STA !HDMA3source
		STA $4332
		LDA $0600 : STA $0610,x
		LDA $0601 : STA $0611,x
		LDA $0602 : STA $0612,x
		LDA $0603 : STA $0613,x
		LDA $0604 : STA $0614,x
		LDA $0605 : STA $0615,x
		LDA $0606 : STA $0616,x
		LDA $0607 : STA $0617,x
		LDA $0608 : STA $0618,x
		LDA $0609 : STA $0619,x
		LDA $060A : STA $061A,x
		LDA $060B : STA $061B,x
		LDA $060C : STA $061C,x
		LDA $060D : STA $061D,x
		LDA $060E : STA $061E,x
		LDA $060F : STA $061F,x

	.Outside

		PLP
		RTL




	DisplayHurtbox:
	.OutsideJump
		JML .Outside

	.Main
		PHP
		SEP #$20
		STZ $41
		STZ $42
		STZ $43
		REP #$20
		LDA !P2Hurtbox+4-$80 : BEQ .OutsideJump
		AND #$00FF
		CLC : ADC !P2Hurtbox+0-$80
		STA $00					; $00 = x + w
		LDA !P2Hurtbox+5-$80
		AND #$00FF
		CLC : ADC !P2Hurtbox+2-$80
		STA $02					; $02 = y + h

		LDA $1A
		CLC : ADC #$0100
		STA $04					; $04 = screen right
		LDA $1C
		CLC : ADC #$00D8
		STA $06					; $06 = screen bottom


		LDA !P2Hurtbox+2-$80 : BMI .OverTop
		CMP $1C : BCC .OverTop

	.UnderTop
		CMP $06 : BCS .OutsideJump

	; case 5: outside

		LDA !P2Hurtbox+2-$80
		SEC : SBC $1C
		TAY
		LDA $02
		CMP $06 : BCC .YInside
		LDA $06
		SEC : SBC !P2Hurtbox+2-$80
		BRA .Height

	; case 4: visible $1C+0xD8-y


	.YInside
		LDA !P2Hurtbox+5-$80
		AND #$00FF
		BRA .Height

	; case 3: completely inside


	.OverTop
		LDA $02
		SEC : SBC $1C
		BCC .OutsideJump
		LDY #$00				; start at scanline 0

	; case 1: outside
	; case 2: visible y+h-$1C


	.Height
		STY $0F					; $0F = starting scanline
		TAY					; y = number of scanlines visible


		LDA !P2Hurtbox+0-$80 : BMI .LeftLeft
		CMP $1A : BCC .LeftLeft

	.RightLeft
		CMP $04 : BCS .OutsideJump

	; case E: outside

		LDA !P2Hurtbox+0-$80
		SEC : SBC $1A
		TAX
		LDA $00
		CMP $04 : BCC .XInside
		LDA $04
		SEC : SBC !P2Hurtbox+0-$80
		BRA .Width

	; case D: visible $1A+0x100-x


	.XInside
		LDA !P2Hurtbox+4-$80
		AND #$00FF
		BRA .Width

	; case C: completely inside


	.LeftLeft
		LDA $00
		SEC : SBC $1A
		BCS $03 : JMP .Outside
		LDX #$00				; x coord 0

	; case A: outside
	; case B: visible x+w-$1A


	.Width
		STX $0D
		SEP #$20
		CLC : ADC $0D
		BCC $02 : LDA #$FF			; cap at 0xFF
		STA $0E

	; $0D:	left border
	; $0E:	right border
	; $0F:	starting y coord
	; y:	number of scanlines visible


		LDA #$04 : STA !HDMA			; enable HDMA on channel 2
		LDA #$22
		STA $41
		STA $42
		STZ $43


		LDX #$00				; table index: 0
		LDA $0F : BEQ .InstantStart
		CMP #$40 : BCC +

		LSR A
		STA $0400
		BCC $01 : INC A
		STA $0403
		INX
		LDA #$FF : STA $0400,x
		STZ $0401,x
		INX #3
		BRA ++

	+	STA $0400
		INX
		LDA #$FF
	++	STA $0400,x				;\
		STZ $0401,x				; | set up skip lines
		INX #2					;/

	.InstantStart
		TYA : STA $0400,x			;\
		LDA $0D : STA $0401,x			; | write box
		LDA $0E : STA $0402,x			;/
		LDA #$01 : STA $0403,x			;\
		LDA #$FF : STA $0404,x			; | set up a final skip line
		STZ $0405,x				;/
		STZ $0406,x				; end table

		REP #$20
		LDA #$2601 : STA $4320
		STZ $4323
		LDA #$0400 : STA !HDMA2source
		STA $4322

		SEP #$20
		LDA $14
		AND #$01
		ASL #4
		TAX
		CLC : ADC #$10
		STA !HDMA2source
		STA $4322
		LDA $0400 : STA $0410,x
		LDA $0401 : STA $0411,x
		LDA $0402 : STA $0412,x
		LDA $0403 : STA $0413,x
		LDA $0404 : STA $0414,x
		LDA $0405 : STA $0415,x
		LDA $0406 : STA $0416,x
		LDA $0407 : STA $0417,x
		LDA $0408 : STA $0418,x
		LDA $0409 : STA $0419,x
		LDA $040A : STA $041A,x
		LDA $040B : STA $041B,x
		LDA $040C : STA $041C,x
		LDA $040D : STA $041D,x
		LDA $040E : STA $041E,x
		LDA $040F : STA $041F,x

	.Outside

		PLP
		RTL





; --Level INIT--

levelinit0:
		LDX #$0F			;\
	-	LDA !LevelTable4,x		; |
		ORA #$80			; | unlock levels 0-F
		STA !LevelTable4,x		; |
		DEX : BPL -			;/

		LDA #$33 : STA !NPC_Talk+$10


		INC !SideExit
		PHP
;		REP #$30
;		LDY.w #!File_NPC_Survivor
;		LDA #$6C00
;		JSL !LoadFile


		REP #$20
		LDA.w #!MSG_MarioSwitch : STA !NPC_Talk+(0*2)
		LDA.w #!MSG_LuigiSwitch : STA !NPC_Talk+(1*2)
		LDA.w #!MSG_KadaalSwitch : STA !NPC_Talk+(2*2)
		LDA.w #!MSG_LeewaySwitch : STA !NPC_Talk+(3*2)
		LDA.w #!MSG_AlterSwitch : STA !NPC_Talk+(4*2)
		LDA.w #!MSG_PeachSwitch : STA !NPC_Talk+(5*2)


		LDA.w #!MSG_Survivor_Talk_1 : STA !NPC_Talk+(6*2)


		LDA.w #!MSG_Toad1 : STA !NPC_Talk+($10*2)
		LDA.w #!MSG_Toad1+1 : STA !NPC_TalkCap+($10*2)


;		SEP #$20
;		LDA #$01 : STA $410000+!BG_object_Type
;		LDA #$04 : STA $410000+!BG_object_W
;		LDA #$02 : STA $410000+!BG_object_H
;		REP #$20
;		LDA #$00D0 : STA $410000+!BG_object_X
;		LDA #$0170 : STA $410000+!BG_object_Y

		PLP
		RTL







levelinit16:
	RTL
levelinit17:
	RTL
levelinit18:
	RTL
levelinit19:
	RTL
levelinit1A:
	RTL
levelinit1B:
	RTL
levelinit1C:
	RTL
levelinit1D:
	RTL
levelinit1E:
	RTL
levelinit1F:
	RTL
levelinit20:
	RTL
levelinit21:
	RTL
levelinit22:
	RTL
levelinit23:
	RTL
levelinit24:
	RTL

levelinit25:

		LDA $94
		CMP #$20 : BCC .L
	.R	LDA #$E0
		STA $94
		STA !P2XPosLo-$80
		STA !P2XPosLo
	.L

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
	;	JSR $1E80

		STZ $43

		REP #$20
		LDA #$7000 : STA.l $400000+!MsgVRAM1
		LDA #$7080 : STA.l $400000+!MsgVRAM2
		LDA #$7200 : STA.l $400000+!MsgVRAM3

		SEP #$20
		RTL


		.SA1
		PHP
		SEP #$30
		LDA !Characters
		LSR #4
		TAX					; portrait
		LDY #$C1				; palette
		LDA #$76				; VRAM
	;	JSL !LoadPortrait
		PLP
		RTL



levelinit33:
	RTL



levelinit3A:
	RTL
levelinit3B:
	RTL
levelinit3C:
	RTL
levelinit3D:
	RTL
levelinit3E:
	RTL
levelinit3F:
	RTL
levelinit40:
	RTL
levelinit41:
	RTL
levelinit42:
	RTL
levelinit43:
	RTL
levelinit44:
	RTL
levelinit45:
	RTL
levelinit46:
	RTL
levelinit47:
	RTL
levelinit48:
	RTL
levelinit49:
	RTL
levelinit4A:
	RTL
levelinit4B:
	RTL
levelinit4C:
	RTL
levelinit4D:
	RTL
levelinit4E:
	RTL
levelinit4F:
	RTL
levelinit50:
	RTL
levelinit51:
	RTL
levelinit52:
	RTL
levelinit53:
	RTL
levelinit54:
	RTL
levelinit55:
	RTL
levelinit56:
	RTL
levelinit57:
	RTL
levelinit58:
	RTL
levelinit59:
	RTL
levelinit5A:
	RTL
levelinit5B:
	RTL
levelinit5C:
	RTL
levelinit5D:
	RTL
levelinit5E:
	RTL
levelinit5F:
	RTL
levelinit60:
	RTL
levelinit61:
	RTL
levelinit62:
	RTL
levelinit63:
	RTL
levelinit64:
	RTL
levelinit65:
	RTL
levelinit66:
	RTL
levelinit67:
	RTL
levelinit68:
	RTL
levelinit69:
	RTL
levelinit6A:
	RTL
levelinit6B:
	RTL
levelinit6C:
	RTL
levelinit6D:
	RTL
levelinit6E:
	RTL
levelinit6F:
	RTL
levelinit70:
	RTL
levelinit71:
	RTL
levelinit72:
	RTL
levelinit73:
	RTL
levelinit74:
	RTL
levelinit75:
	RTL
levelinit76:
	RTL
levelinit77:
	RTL
levelinit78:
	RTL
levelinit79:
	RTL
levelinit7A:
	RTL
levelinit7B:
	RTL
levelinit7C:
	RTL
levelinit7D:
	RTL
levelinit7E:
	RTL
levelinit7F:
	RTL
levelinit80:
	RTL
levelinit81:
	RTL
levelinit82:
	RTL
levelinit83:
	RTL
levelinit84:
	RTL
levelinit85:
	RTL
levelinit86:
	RTL
levelinit87:
	RTL
levelinit88:
	RTL
levelinit89:
	RTL
levelinit8A:
	RTL
levelinit8B:
	RTL
levelinit8C:
	RTL
levelinit8D:
	RTL
levelinit8E:
	RTL
levelinit8F:
	RTL
levelinit90:
	RTL
levelinit91:
	RTL
levelinit92:
	RTL
levelinit93:
	RTL
levelinit94:
	RTL
levelinit95:
	RTL
levelinit96:
	RTL
levelinit97:
	RTL
levelinit98:
	RTL
levelinit99:
	RTL
levelinit9A:
	RTL
levelinit9B:
	RTL
levelinit9C:
	RTL
levelinit9D:
	RTL
levelinit9E:
	RTL
levelinit9F:
	RTL
levelinitA0:
	RTL
levelinitA1:
	RTL
levelinitA2:
	RTL
levelinitA3:
	RTL
levelinitA4:
	RTL
levelinitA5:
	RTL
levelinitA6:
	RTL
levelinitA7:
	RTL
levelinitA8:
	RTL
levelinitA9:
	RTL
levelinitAA:
	RTL
levelinitAB:
	RTL
levelinitAC:
	RTL
levelinitAD:
	RTL
levelinitAE:
	RTL
levelinitAF:
	RTL
levelinitB0:
	RTL
levelinitB1:
	RTL
levelinitB2:
	RTL
levelinitB3:
	RTL
levelinitB4:
	RTL
levelinitB5:
	RTL
levelinitB6:
	RTL
levelinitB7:
	RTL
levelinitB8:
	RTL
levelinitB9:
	RTL
levelinitBA:
	RTL
levelinitBB:
	RTL
levelinitBC:
	RTL
levelinitBD:
	RTL
levelinitBE:
	RTL
levelinitBF:
	RTL
levelinitC0:
	RTL
levelinitC1:
	RTL
levelinitC2:
	RTL
levelinitC3:
	RTL
levelinitC4:
	RTL
levelinitC5:
		LDA #$01 : STA $5E		; prevent camera scroll
		RTL				; return



levelinitC6:
		LDA.b #999>>8 : STA !TimerSeconds+1

		LDA #$06 : STA !PalsetStart

		LDA $95 : BNE +
		LDA #$FF : STA $97
		+


		LDA #$01 : STA !KadaalStatus			; unlock kadaal

		STZ !P1Dead
		STZ !MarioAnim
		STZ !P2Status-$80
		STZ !P2Status

		STZ $24
		STZ $25

		RTL




levelinitC7:
		RTL


	pushpc
	org $0093A4
		LDA #$F0			; remove "Nintendo Presents"
	org $0093C0
		LDA #$2A			; first sound
		STA !SPC3
	org $0096C6
		LDA #$2A			; title screen music
	pullpc

levelinitC8:

		STZ $0A80			; clear chunk status
		STZ $0A87
		PHP
		REP #$20
		LDA.w #.ChunkTable : STA $0A81
		PLP
		RTL

.ChunkTable	dw $0160,$00E0 : db $02


levelinitC9:
	RTL
levelinitCA:
	RTL
levelinitCB:
	RTL
levelinitCC:
	RTL
levelinitCD:
	RTL
levelinitCE:
	RTL
levelinitCF:
	RTL
levelinitD0:
	RTL
levelinitD1:
	RTL
levelinitD2:
	RTL
levelinitD3:
	RTL
levelinitD4:
	RTL
levelinitD5:
	RTL
levelinitD6:
	RTL
levelinitD7:
	RTL
levelinitD8:
	RTL
levelinitD9:
	RTL
levelinitDA:
	RTL
levelinitDB:
	RTL
levelinitDC:
	RTL
levelinitDD:
	RTL
levelinitDE:
	RTL
levelinitDF:
	RTL
levelinitE0:
	RTL
levelinitE1:
	RTL
levelinitE2:
	RTL
levelinitE3:
	RTL
levelinitE4:
	RTL
levelinitE5:
	RTL
levelinitE6:
	RTL
levelinitE7:
	RTL
levelinitE8:
	RTL
levelinitE9:
	RTL
levelinitEA:
	RTL
levelinitEB:
	RTL
levelinitEC:
	RTL
levelinitED:
	RTL
levelinitEE:
	RTL
levelinitEF:
	RTL
levelinitF0:
	RTL
levelinitF1:
	RTL
levelinitF2:
	RTL
levelinitF3:
	RTL
levelinitF4:
	RTL
levelinitF5:
	RTL
levelinitF6:
	RTL
levelinitF7:
	RTL
levelinitF8:
	RTL
levelinitF9:
	RTL
levelinitFA:
	RTL
levelinitFB:
	RTL
levelinitFC:
	RTL
levelinitFD:
	RTL
levelinitFE:
	RTL
levelinitFF:
	RTL
levelinit100:
	RTL
levelinit101:
	RTL
levelinit102:
	RTL
levelinit103:
	RTL
levelinit104:
	RTL
levelinit105:
	RTL
levelinit106:
	RTL
levelinit107:
	RTL
levelinit108:
	RTL
levelinit109:
	RTL
levelinit10A:
	RTL
levelinit10B:
	RTL
levelinit10C:
		JML levelinit0
		RTL


levelinit10D:
	RTL
levelinit10E:
	RTL
levelinit10F:
	RTL
levelinit110:
	RTL
levelinit111:
	RTL
levelinit112:
	RTL
levelinit113:
	RTL
levelinit114:
	RTL
levelinit115:
	RTL
levelinit116:
	RTL
levelinit117:
	RTL
levelinit118:
	RTL
levelinit119:
	RTL
levelinit11A:
	RTL
levelinit11B:
	RTL
levelinit11C:
	RTL
levelinit11D:
	RTL
levelinit11E:
	RTL
levelinit11F:
	RTL
levelinit120:
	RTL
levelinit121:
	RTL
levelinit122:
	RTL
levelinit123:
	RTL
levelinit124:
	RTL
levelinit125:
	RTL
levelinit126:
	RTL
levelinit127:
	RTL
levelinit128:
	RTL
levelinit129:
	RTL
levelinit12A:
	RTL
levelinit12B:
	RTL
levelinit12C:
	RTL
levelinit12D:
	RTL
levelinit12E:
	RTL
levelinit12F:
	RTL
levelinit130:
	RTL
levelinit131:
	RTL
levelinit132:
	RTL
levelinit133:
	RTL
levelinit134:
	RTL
levelinit135:
	RTL
levelinit136:
	RTL
levelinit137:
	RTL
levelinit138:
	RTL
levelinit139:
	RTL
levelinit13A:
	RTL


levelinit13B:

		.BlockExit
		LDA !LevelTable1+$5E : BMI ..done
		LDX #$0F
		..loop
		LDA $3230,x : BEQ ..thisone
		DEX : BPL ..loop
		BRA ..done
		..thisone
		LDA #$80 : STA !SpriteXLo,x
		LDA #$00 : STA !SpriteXHi,x
		LDA #$60 : STA !SpriteYLo,x
		LDA #$03 : STA !SpriteYHi,x
		LDA #$0F : STA !NewSpriteNum,x
		LDA #$0C : STA !ExtraBits,x
		LDA #$36 : STA $3200,x
		LDA #$01 : STA $3230,x
		JSL !ResetSprite
		..done



		REP #$20
		LDA.w #!MSG_Toad_Guard2 : STA !NPC_Talk+($10*2)
		SEP #$20

		RTL


levelinit13C:
	RTL
levelinit13D:
	RTL
levelinit13E:
	RTL
levelinit13F:
	RTL
levelinit140:
	RTL
levelinit141:
	RTL
levelinit142:
	RTL
levelinit143:
	RTL
levelinit144:
	RTL
levelinit145:
	RTL
levelinit146:
	RTL
levelinit147:
	RTL
levelinit148:
	RTL
levelinit149:
	RTL
levelinit14A:
	RTL
levelinit14B:
	RTL
levelinit14C:
	RTL
levelinit14D:
	RTL
levelinit14E:
	RTL
levelinit14F:
	RTL
levelinit150:
	RTL
levelinit151:
	RTL
levelinit152:
	RTL
levelinit153:
	RTL
levelinit154:
	RTL
levelinit155:
	RTL
levelinit156:
	RTL
levelinit157:
	RTL
levelinit158:
	RTL
levelinit159:
	RTL
levelinit15A:
	RTL
levelinit15B:
	RTL
levelinit15C:
	RTL
levelinit15D:
	RTL
levelinit15E:
	RTL
levelinit15F:
	RTL
levelinit160:
	RTL
levelinit161:
	RTL
levelinit162:
	RTL
levelinit163:
	RTL
levelinit164:
	RTL
levelinit165:
	RTL
levelinit166:
	RTL
levelinit167:
	RTL
levelinit168:
	RTL
levelinit169:
	RTL
levelinit16A:
	RTL
levelinit16B:
	RTL
levelinit16C:
	RTL
levelinit16D:
	RTL
levelinit16E:
	RTL
levelinit16F:
	RTL
levelinit170:
	RTL
levelinit171:
	RTL
levelinit172:
	RTL
levelinit173:
	RTL
levelinit174:
	RTL
levelinit175:
	RTL
levelinit176:
	RTL
levelinit177:
	RTL
levelinit178:
	RTL
levelinit179:
	RTL
levelinit17A:
	RTL
levelinit17B:
	RTL
levelinit17C:
	RTL
levelinit17D:
	RTL
levelinit17E:
	RTL
levelinit17F:
	RTL
levelinit180:
	RTL
levelinit181:
	RTL
levelinit182:
	RTL
levelinit183:
	RTL
levelinit184:
	RTL
levelinit185:
	RTL
levelinit186:
	RTL
levelinit187:
	RTL
levelinit188:
	RTL
levelinit189:
	RTL
levelinit18A:
	RTL
levelinit18B:
	RTL
levelinit18C:
	RTL
levelinit18D:
	RTL
levelinit18E:
	RTL
levelinit18F:
	RTL
levelinit190:
	RTL
levelinit191:
	RTL
levelinit192:
	RTL
levelinit193:
	RTL
levelinit194:
	RTL
levelinit195:
	RTL
levelinit196:
	RTL
levelinit197:
	RTL
levelinit198:
	RTL
levelinit199:
	RTL
levelinit19A:
	RTL
levelinit19B:
	RTL
levelinit19C:
	RTL
levelinit19D:
	RTL
levelinit19E:
	RTL
levelinit19F:
	RTL
levelinit1A0:
	RTL
levelinit1A1:
	RTL
levelinit1A2:
	RTL
levelinit1A3:
	RTL
levelinit1A4:
	RTL
levelinit1A5:
	RTL
levelinit1A6:
	RTL
levelinit1A7:
	RTL
levelinit1A8:
	RTL
levelinit1A9:
	RTL
levelinit1AA:
	RTL
levelinit1AB:
	RTL
levelinit1AC:
	RTL
levelinit1AD:
	RTL
levelinit1AE:
	RTL
levelinit1AF:
	RTL
levelinit1B0:
	RTL
levelinit1B1:
	RTL
levelinit1B2:
	RTL
levelinit1B3:
	RTL
levelinit1B4:
	RTL
levelinit1B5:
	RTL
levelinit1B6:
	RTL
levelinit1B7:
	RTL
levelinit1B8:
	RTL
levelinit1B9:
	RTL
levelinit1BA:
	RTL
levelinit1BB:
	RTL
levelinit1BC:
	RTL
levelinit1BD:
	RTL
levelinit1BE:
	RTL
levelinit1BF:
	RTL
levelinit1C0:
	RTL
levelinit1C1:
	RTL
levelinit1C2:
	RTL
levelinit1C3:
	RTL
levelinit1C4:
	RTL
levelinit1C5:
	RTL
levelinit1C6:
	RTL
levelinit1C7:
	RTL
levelinit1C8:
	RTL
levelinit1C9:
	RTL
levelinit1CA:
	RTL
levelinit1CB:
	RTL
levelinit1CC:
	RTL
levelinit1CD:
	RTL
levelinit1CE:
	RTL
levelinit1CF:
	RTL
levelinit1D0:
	RTL
levelinit1D1:
	RTL
levelinit1D2:
	RTL
levelinit1D3:
	RTL
levelinit1D4:
	RTL
levelinit1D5:
	RTL
levelinit1D6:
	RTL
levelinit1D7:
	RTL
levelinit1D8:
	RTL
levelinit1D9:
	RTL
levelinit1DA:
	RTL
levelinit1DB:
	RTL
levelinit1DC:
	RTL
levelinit1DD:
	RTL
levelinit1DE:
	RTL
levelinit1DF:
	RTL
levelinit1E0:
	RTL
levelinit1E1:
	RTL
levelinit1E2:
	RTL
levelinit1E3:
	RTL
levelinit1E4:
	RTL
levelinit1E5:
	RTL
levelinit1E6:
	RTL
levelinit1E7:
	RTL
levelinit1E8:
	RTL
levelinit1E9:
	RTL
levelinit1EA:
	RTL
levelinit1EB:
	RTL
levelinit1EC:
	RTL
levelinit1ED:
	RTL
levelinit1EE:
	RTL
levelinit1EF:
	RTL
levelinit1F0:
	RTL
levelinit1F1:

		.BlockExit
		LDA !LevelTable1+$5E : BMI ..done
		LDX #$0F
		..loop
		LDA $3230,x : BEQ ..thisone
		DEX : BPL ..loop
		BRA ..done
		..thisone
		LDA #$80 : STA !SpriteXLo,x
		LDA #$00 : STA !SpriteXHi,x
		LDA #$10 : STA !SpriteYLo,x
		LDA #$00 : STA !SpriteYHi,x
		LDA #$0F : STA !NewSpriteNum,x
		LDA #$0C : STA !ExtraBits,x
		LDA #$36 : STA $3200,x
		LDA #$01 : STA $3230,x
		JSL !ResetSprite
		..done

		REP #$20
		LDA.w #!MSG_Toad_IntroLevel_1 : STA !NPC_Talk+($10*2)
		SEP #$20

		RTL


levelinit1F2:
	RTL
levelinit1F3:
	RTL
levelinit1F4:
		REP #$20
		LDA.w #!MSG_Toad_Training_1 : STA !NPC_Talk+($10*2)
		SEP #$20

		RTL


levelinit1F5:
	RTL
levelinit1F6:
	RTL
levelinit1F7:

		LDA #$FF : STA !TimerSeconds+1

		LDA !LevelTable1+$5E : BMI .NotIntro
		REP #$20
		LDA.w #!MSG_Toad_Wakeup
		STA !NPC_Talk+($10*2)
		STA !NPC_TalkCap+($10*2)
		SEP #$20


	; spawn wakeup toad on intro mode
		LDA #$0E : STA !NewSpriteNum
		LDA #$36 : STA $3200
		LDA #$10 : STA !ExtraProp1
		LDA #$01 : STA !ExtraProp2
		LDA #$30 : STA !SpriteXLo
		STZ !SpriteXHi
		LDA #$B0 : STA !SpriteYLo
		STZ !SpriteYHi
		LDA #$01 : STA $3230
		LDA #$08 : STA !ExtraBits
		LDX #$00
		JSL !ResetSprite


		.NotIntro

		RTL


levelinit1F8:
	RTL
levelinit1F9:
	RTL
levelinit1FA:
	RTL
levelinit1FB:
	RTL
levelinit1FC:
	RTL
levelinit1FD:
	RTL
levelinit1FE:
	RTL

levelinit1FF:
	JSL level1FF
	RTL

; --Level MAIN--

level0:
		STZ $00
		STZ $01
		JSL DisplayYC

	;	JSL DisplayHitbox1_Main
	;	JSL DisplayHitbox2_Main

	;JSL TriangleProjection

		RTL


	DisplayYC:
		PHB : PHK : PLB

		LDA !LevelTable1+$5E : BMI .Process	; only draw if intro level has been cleared
		JMP .Return

		.Process
		LDX !OAMindex				; OAM index
		LDY #$0C				; loop counter
	-	LDA .Tilemap+0,y			;\
		CLC : ADC $00				; | X coordinates
		STA !OAM+$000,x				;/
		LDA .Tilemap+1,y			;\
		CLC : ADC $01				; | Y coordinates
		STA !OAM+$001,x				;/
		LDA .Tilemap+2,y : STA !OAM+$002,x	;\ tile/prop
		LDA .Tilemap+3,y : STA !OAM+$003,x	;/
		INX #4
		DEY #4 : BPL -				; loop

		LDX !OAMindex

		REP #$20				;\
		LDA !YoshiCoinCount			; |
		CMP #$03E7				; |
		BCC $03 : LDA #$03E7			; | (cap at 999)
	-	CMP #$0064 : BCC +			; | calculate 100s
		SBC #$0064				; |
		INC !OAM+$006,x				; |
		BRA -					;/
	+	SEP #$20				;\
	-	CMP #$0A : BCC +			; |
		SBC #$0A				; | calculate 10s
		INC !OAM+$00A,x				; |
		BRA -					;/
	+	CLC : ADC !OAM+$00E,x			;\ store remainder as 1s
		STA !OAM+$00E,x				;/

		LDA !OAM+$006,x				;\
		CMP #$B2 : BNE +			; |
		LDA #$F0 : STA !OAM+$005,x		; | wipe leading 0s
		LDA !OAM+$00A,x				; |
		CMP #$B2 : BNE +			; |
		LDA #$F0 : STA !OAM+$009,x		;/

	+	TXA					;\
		LSR #2					; |
		TAX					; |
		STZ !OAMhi+$00,x			; | tile size = 8x8
		STZ !OAMhi+$01,x			; |
		STZ !OAMhi+$02,x			; |
		STZ !OAMhi+$03,x			;/

		LDA !OAMindex
		CLC : ADC #$10
		STA !OAMindex				; set OAM index

		.Return
		PLB
		RTL

.Tilemap	db $08,$08,$F2,$3F
		db $14,$08,$B2,$3F
		db $1E,$08,$B2,$3F
		db $28,$08,$B2,$3F




level16:
	RTL
level17:
	RTL
level18:
	RTL
level19:
	RTL
level1A:
	RTL
level1B:
	RTL
level1C:
	RTL
level1D:
	RTL
level1E:
	RTL
level1F:
	RTL
level20:
	RTL
level21:
	RTL
level22:
	RTL
level23:
	RTL
level24:
	RTL




	!RollWidth	= $6DF5


level25:

		LDA #$0C : STA !TextPal			; default text pal in this room is 0x0C-0x0F


		LDA !Level+6 : BNE .PortraitLoaded

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		INC !Level+6
		STZ !RollWidth
	;	JSR $1E80
		RTL

		.SA1
		PHP
		SEP #$30
		LDX #$07				; special tinker portrait
		LDY #$A1				; palette
		LDA #$70				; VRAM
	;	JSL !LoadPortrait
		PLP
		RTL
		.PortraitLoaded


		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | elevator exit
		dw $97B1				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0090 : db $10,$40	; | command bridge exit
		dw $05F1				; |
		BCC $01 : RTL				;/



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

	.YC	JSL DisplayYC

		LDA !Level+2 : BNE .NoUpload
		INC !Level+2
		LDA #$0400 : JSL LoadScreen_Char
		RTL
		.NoUpload


		LDA !Level+4 : BNE $04 : JML ++
		CMP.b #.Y_End-.Y-1 : BCS +
		INC !Level+4
		JML ++
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
	ASL A
	TAX
	REP #$20
	LDA !Level+5
	AND #$00FF
	CLC : ADC .CharIndex,x : STA $00
	STA !MsgTrigger
	SEP #$20

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

	REP #$20
	LDA !Level+5
	AND #$00FF
	CLC : ADC $00
	STA !MsgTrigger
	SEP #$20

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
		RTL

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





.CharIndex	dw !MSG_Mario_Upgrade_1
		dw !MSG_Luigi_Upgrade_1
		dw !MSG_Kadaal_Upgrade_1
		dw !MSG_Leeway_Upgrade_1
		dw !MSG_Alter_Upgrade_1
		dw !MSG_Peach_Upgrade_1


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
; input:
; .Char
;	A = added to !BG1Address
; normal
;	X = map16 index, lo byte
;	Y = map16 index, hi byte
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
		LDA.l .Screen+6,x : XBA
		LDA.l .Screen,x
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
		LDY #$0002
		LDA [$0A],y : STA $0440,x
		LDY #$0004
		LDA [$0A],y : STA $0402,x
		LDY #$0006
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
		LDA !BG1Address : STA !VRAMbase+!VRAMtable+$05,x
		LDA #$0800 : STA !VRAMbase+!VRAMtable+$00,x
		PLP
		RTL


.Screen		db $B0,$60,$10,$C0,$70,$20,$D0,$80
		db $01,$03,$05,$06,$08,$0A,$0B,$0D








level33:
	RTL



level3A:
	RTL
level3B:
	RTL
level3C:
	RTL
level3D:
	RTL
level3E:
	RTL
level3F:
	RTL
level40:
	RTL
level41:
	RTL
level42:
	RTL
level43:
	RTL
level44:
	RTL
level45:
	RTL
level46:
	RTL
level47:
	RTL
level48:
	RTL
level49:
	RTL
level4A:
	RTL
level4B:
	RTL
level4C:
	RTL
level4D:
	RTL
level4E:
	RTL
level4F:
	RTL
level50:
	RTL
level51:
	RTL
level52:
	RTL
level53:
	RTL
level54:
	RTL
level55:
	RTL
level56:
	RTL
level57:
	RTL
level58:
	RTL
level59:
	RTL
level5A:
	RTL
level5B:
	RTL
level5C:
	RTL
level5D:
	RTL
level5E:
	RTL
level5F:
	RTL
level60:
	RTL
level61:
	RTL
level62:
	RTL
level63:
	RTL
level64:
	RTL
level65:
	RTL
level66:
	RTL
level67:
	RTL
level68:
	RTL
level69:
	RTL
level6A:
	RTL
level6B:
	RTL
level6C:
	RTL
level6D:
	RTL
level6E:
	RTL
level6F:
	RTL
level70:
	RTL
level71:
	RTL
level72:
	RTL
level73:
	RTL
level74:
	RTL
level75:
	RTL
level76:
	RTL
level77:
	RTL
level78:
	RTL
level79:
	RTL
level7A:
	RTL
level7B:
	RTL
level7C:
	RTL
level7D:
	RTL
level7E:
	RTL
level7F:
	RTL
level80:
	RTL
level81:
	RTL
level82:
	RTL
level83:
	RTL
level84:
	RTL
level85:
	RTL
level86:
	RTL
level87:
	RTL
level88:
	RTL
level89:
	RTL
level8A:
	RTL
level8B:
	RTL
level8C:
	RTL
level8D:
	RTL
level8E:
	RTL
level8F:
	RTL
level90:
	RTL
level91:
	RTL
level92:
	RTL
level93:
	RTL
level94:
	RTL
level95:
	RTL
level96:
	RTL
level97:
	RTL
level98:
	RTL
level99:
	RTL
level9A:
	RTL
level9B:
	RTL
level9C:
	RTL
level9D:
	RTL
level9E:
	RTL
level9F:
	RTL
levelA0:
	RTL
levelA1:
	RTL
levelA2:
	RTL
levelA3:
	RTL
levelA4:
	RTL
levelA5:
	RTL
levelA6:
	RTL
levelA7:
	RTL
levelA8:
	RTL
levelA9:
	RTL
levelAA:
	RTL
levelAB:
	RTL
levelAC:
	RTL
levelAD:
	RTL
levelAE:
	RTL
levelAF:
	RTL
levelB0:
	RTL
levelB1:
	RTL
levelB2:
	RTL
levelB3:
	RTL
levelB4:
	RTL
levelB5:
	RTL
levelB6:
	RTL
levelB7:
	RTL
levelB8:
	RTL
levelB9:
	RTL
levelBA:
	RTL
levelBB:
	RTL
levelBC:
	RTL
levelBD:
	RTL
levelBE:
	RTL
levelBF:
	RTL
levelC0:
	RTL
levelC1:
	RTL
levelC2:
	RTL
levelC3:
	RTL
levelC4:
	RTL


levelC5:
		RTL





;
; !Level+2	timer for jump tooltip
; !Level+3	timer for run tooltip
; !Level+4	timer for attack tooltip and senku jump tooltip
; !Level+5	bit check for kadaal's lessons:
;		0 - run right
;		1 - run left
;		2 - attack 1
;		3 - attack 2
;		4 - senku
;		5 - senku jump
;

levelC6:
		LDA !P2Character-$80
		CMP #$02 : BEQ +
		LDA !Level+4 : BNE +
		LDA $1B
		CMP #$0E : BNE +
		LDX #$0F
	-	LDA $3230,x : BEQ ++
		LDA !NewSpriteNum,x
		CMP #$0E : BNE ++
		LDA #$01 : STA $3320,x
		LDA #$3E : STA !ExtraProp2,x

		LDA !Level+1					;\
		BEQ $02 : LDA #$20				; |
		ORA #$40					; |
		STA !LevelTable1+$5E				; |
		LDA !Level : STA !LevelTable2+$5E		;/

		REP #$20
		LDA.w #!MSG_MeetKadaal_1 : STA !MsgTrigger
		SEP #$20
	++	DEX : BPL -
		LDA #$01 : STA !Level+4
		+


	; end level
		REP #$20					;\ end level at coordinate 0x1FF0
		LDA #$1FF0 : JSL END_Right			;/
		LDA !GameMode					;\
		CMP #$0B : BNE .NotEnded			; |
		STZ $6109					; | beat intro level when reaching the end
		LDA #$80 : TSB !LevelTable1			; |
		.NotEnded					;/

	; set HDMA
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

	; screen regs
	;	LDA #$44 : STA !2131
	;	LDA #$13 : STA !SubScreen
	;	LDA #$17 : STA !MainScreen
	;	LDA #$09 : STA !2105

	; background color
		REP #$20
		LDA #$7BDE : STA !PaletteCacheRGB+0
		LDA $1B
		AND #$00FF
		CMP #$001F
		BCC $03 : LDA #$001F
		EOR #$001F
		LDX #$00
		LDY #$01
		JSL !MixRGB
		LDA !PaletteBuffer+0 : STA !2132_RGB	;STA !Color0
		SEP #$20



	; -- TUTOTIRAL GUI CHECK --


	; character check
		LDA !P2Character-$80
		CMP #$02 : BEQ .Kadaal
		JMP .Mario
		.Kadaal

	; attack 1 check
		LDA !Level+5
		AND #$04 : BNE .NoAttack1
		REP #$20
		LDA !P2XPos-$80
		CMP #$0F80 : BCC .NoAttack1
		CMP #$1200 : BCS .NoAttack1
		SEP #$20
		LDX #$0F
	-	LDA $3230,x
		CMP #$02 : BEQ +
		DEX : BPL -
		LDY #$08
		JMP .LoadTilemap
	+	LDA #$04 : TSB !Level+5
		.NoAttack1
		SEP #$20

	; attack 2 check
		LDA !Level+5
		AND #$08 : BNE .NoAttack2
		LDA !P2XPosHi-$80
		CMP #$12 : BEQ +
		STZ !Level+4
		JMP .NoSenkuJump
	+	LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x
		CMP #$01+!MinorOffset : BEQ +
		DEX : BPL -
		BRA ++
	+	LDA #$08 : TSB !Level+5
	++	LDA !Level+4
		CMP #$FF : BEQ +
		INC !Level+4
		JMP .NoSenkuJump
	+	LDY #$08
		JMP .LoadTilemap
		.NoAttack2

	; slide check
		LDA !P2XPosHi-$80
		CMP #$15 : BNE .NoSlide
		LDY #$03
		JMP .LoadTilemap
		.NoSlide

	; senku check
		LDA !Level+5
		AND #$10 : BNE .NoSenku
		LDA !P2XPosHi-$80
		CMP #$1A : BNE .NoSenku
		BIT !P2XPosLo-$80 : BPL +
		LDA #$10 : TSB !Level+5
	+	LDY #$09
		JMP .LoadTilemap
		.NoSenku

	; senku jump check
		LDA !Level+5
		AND #$20 : BNE .NoSenkuJump
		LDA !P2XPosHi-$80
		CMP #$1B : BEQ +
		CMP #$1C : BEQ +
		STZ !Level+4
		BRA .NoSenkuJump
	+	LDA !P2YPosHi-$80 : BNE +
		LDA !P2YPosLo-$80
		CMP #$D0 : BCS +
		LDA !P2InAir-$80 : BNE +
		LDA #$20 : TSB !Level+5
	+	LDA !Level+4
		CMP #$FF : BEQ +
		INC !Level+4
		BRA .NoSenkuJump
	+	LDY #$0A
		JMP .LoadTilemap
		.NoSenkuJump

	; tap run check
		LDA !P2Dashing-$80 : BEQ +
		LDA !P2Direction-$80
		EOR #$01
		INC A
		TSB !Level+5
	+	LDA $14
		AND #$10
		BEQ $02 : LDA #$01
		ORA #$04
		TAY
		LDA !Level+5
		AND #$03 : BEQ +
		CMP #$02 : BEQ +
		CMP #$03 : BEQ .NoTapRun
		LDX !P2XPosHi-$80
		CPX #$11 : BCS .NoTapRun
		INY #2
	+	JMP .LoadTilemap
		.NoTapRun


	; jump check
		.Mario
		LDA $1B
		CMP #$02 : BEQ .TextRun
		CMP #$03 : BEQ .TextRun
		CMP #$01 : BNE .NoJump
		LDA $95
		CMP #$02 : BCS .NoJump
		LDA $94
		CMP #$F5 : BCS .NoJump
		LDA !Level+2
		CMP #$FF : BNE .CountJump
		LDY #$00
		BRA .LoadTilemap
		.CountJump
		INC A
		STA !Level+2
		BRA .CheckFire
		.NoJump
		STZ !Level+2

	; fire check
		.CheckFire
		LDA !CurrentMario : BEQ .Return
		DEC A
		LSR A
		ROR A
		AND #$80
		TAX
		LDA !P2FireCharge-$80,x : BEQ .Return
		LDY #$02
		BRA .LoadTilemap

	; run check
		.TextRun
		LDA $95
		CMP #$02 : BNE +
		LDA $94
		CMP #$90 : BCC .NoRun
	+	CMP #$04 : BCS .NoRun
		LDA $94
		CMP #$F5 : BCS .NoRun
		LDA !Level+3
		CMP #$FF : BEQ .DisplayRunText
		.CountRun
		INC A
		STA !Level+3
		BRA .Return
		.NoRun
		STZ !Level+3
		BRA .Return
		.DisplayRunText
		LDY #$01



	; $00 - Xpos
	; $01 - Ypos
	; $02 - pointer
	; $0D - tile size
	; $0E - byte count
		.LoadTilemap
		LDA .TilemapSize,y : STA $0E
		TYA
		ASL A
		TAY
		LDA #$02 : STA $0D
		REP #$20
		STZ $00
		LDA .TilemapPtr,y : STA $02
		JSL !SpriteHUD
		SEP #$20

		.Return
		RTL


		.TilemapPtr
		dw .Jump		; 00
		dw .Run			; 01
		dw .Fire		; 02
		dw .Slide		; 03
		dw .TapRun1		; 04
		dw .TapRun2		; 05
		dw .TapRun3		; 06
		dw .TapRun4		; 07
		dw .Attack		; 08
		dw .Senku		; 09
		dw .SenkuJump		; 0A


		.TilemapSize
		db .Jump_End-.Jump
		db .Run_End-.Run
		db .Fire_End-.Fire
		db .Slide_End-.Slide
		db .TapRun1_End-.TapRun1
		db .TapRun2_End-.TapRun2
		db .TapRun3_End-.TapRun3
		db .TapRun4_End-.TapRun4
		db .Attack_End-.Attack
		db .Senku_End-.Senku
		db .SenkuJump_End-.SenkuJump

; -- inputs --
; A		0x80 (16x16)
; B		0x82 (16x16)
; X		0xA0 (16x16)
; Y		0xA2 (16x16)
; L		0xC0 (32x16)
; R		0xE0 (32x16)
; Start		0x84 (24x16)
; Select	0xA4 (24x16)
; D-pad		0xC4 (32x32)
; D-pad R	0xC8 (16x16)
; D-pad L	0xCA (16x16)
; D-pad D	0xE8 (16x16)
; D-pad U	0xEA (16x16)

; -- text --
; JUMP		0x87 (32x16)
; RUN		0x8B (24x16)
; FIRE		0xA7 (32x16)
; PUNCH		0xAB (40x16)
; DASH		0xCC (32x16)
; SLASH		0xEC (32x16)


		.Jump
		db $65,$C2,$87,$3F		; jump
		db $75,$C2,$89,$3F
		db $8B,$C0,$82,$3F		; B
		..End

		.Run
		db $65,$C2,$AC,$3F		; run
		db $6D,$C2,$AD,$3F
		db $83,$C0,$A2,$3F		; Y
		..End

		.Fire
		db $65,$C2,$EC,$3F		; fire
		db $75,$C2,$EE,$3F
		db $8B,$C0,$A2,$3F		; Y
		..End

		.Slide
		db $60,$C2,$CC,$3F		; slide
		db $70,$C2,$CE,$3F
		db $8C,$C8,$E8,$3F		; dpad
		db $84,$B8,$C4,$3F
		db $94,$B8,$C6,$3F
		db $84,$C8,$E4,$3F
		db $94,$C8,$E6,$3F
		..End

		.TapRun1
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $88,$C0,$C8,$3F		; dpad 1
		db $78,$B8,$C4,$3F
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		db $9C,$C0,$C8,$3F		; dpad 2
		db $8C,$B8,$C4,$3F
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		..End
		.TapRun2
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $78,$B8,$C4,$3F		; dpad 1
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		db $8C,$B8,$C4,$3F		; dpad 2
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		..End
		.TapRun3
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $8C,$C0,$CA,$3F		; dpad 1
		db $8C,$B8,$C4,$3F
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		db $78,$C0,$CA,$3F		; dpad 2
		db $78,$B8,$C4,$3F
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		..End
		.TapRun4
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $8C,$B8,$C4,$3F		; dpad 1
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		db $78,$B8,$C4,$3F		; dpad 2
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		..End

		.Attack
		db $5D,$C2,$A7,$3F		; attack
		db $6D,$C2,$A9,$3F
		db $75,$C2,$AA,$3F
		db $8B,$C0,$A2,$3F		; Y
		..End

		.Senku
		db $61,$C2,$8B,$3F		; senku
		db $71,$C2,$8D,$3F
		db $79,$C2,$8E,$3F
		db $91,$C0,$80,$3F		; A
		..End

		.SenkuJump
		db $4C,$C2,$8B,$3F		; senku
		db $5C,$C2,$8D,$3F
		db $64,$C2,$8E,$3F
		db $74,$C0,$80,$3F		; A
		db $88,$C2,$87,$3F		; jump
		db $98,$C2,$89,$3F
		db $AE,$C0,$82,$3F		; B
		..End




		.HDMA
		PHP
		SEP #$10
		REP #$20
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0010
		TAX
		LDA $1A
		CMP #$0600 : BCC +
		LDA $14
		AND #$0007 : BNE +
		INC $22
		LDA $24
		CMP #$01B0
		BEQ $01 : INC A
		STA $24
	+	LDA #$0001 : STA $0A00,x
		STZ $0A05,x
		LDA $1A
		CLC : ADC $22
		STA $0A01,x
		LDA $1C
		CLC : ADC $24
		CMP #$0100
		BCS $03 : LDA #$0100
		STA $0A03,x
		LDA #$1103 : STA $4320
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0010
		ORA #$0A00
		STA !HDMA2source
		SEP #$20
		STZ $4324
		LDA #$04 : TSB !HDMA		; use channel 2 so it gets overwritten by message box
		PLP
		RTL







levelC7:
	pushpc
	org $009C6F
		JSL levelC7_Main		; > run level code on title screen	\
		JMP $8494			; > assemble hi OAM 			 | overwriting mario's title screen movement (source: LDX $7DF4 : DEC $7DF5 : BNE $0B)
		NOP				; > erase leftover code			/
	pullpc
	.Main
		PHB : PHK : PLB


		PLB
		RTL


levelC8:

		LDA !P2Blocked-$80
		AND #$04 : BEQ +
		LDA #$10 : STA !Characters
		LDA #$01 : STA !P2Character-$80
		LDA #$00 : STA !CurrentMario
		+


		LDX #$0F
	-	LDA $3200,x
		CMP #$13 : BNE +
		LDA $3230,x
		CMP #$02 : BNE +
		LDA #$01 : JSL LoadChunk
	+	DEX : BPL -

		LDA $0A87 : BEQ .NoChunk
		JSL DestroyChunk
		.NoChunk

		RTL

levelC9:
	RTL
levelCA:
	RTL
levelCB:
	RTL
levelCC:
	RTL
levelCD:
	RTL
levelCE:
	RTL
levelCF:
	RTL
levelD0:
	RTL
levelD1:
	RTL
levelD2:
	RTL
levelD3:
	RTL
levelD4:
	RTL
levelD5:
	RTL
levelD6:
	RTL
levelD7:
	RTL
levelD8:
	RTL
levelD9:
	RTL
levelDA:
	RTL
levelDB:
	RTL
levelDC:
	RTL
levelDD:
	RTL
levelDE:
	RTL
levelDF:
	RTL
levelE0:
	RTL
levelE1:
	RTL
levelE2:
	RTL
levelE3:
	RTL
levelE4:
	RTL
levelE5:
	RTL
levelE6:
	RTL
levelE7:
	RTL
levelE8:
	RTL
levelE9:
	RTL
levelEA:
	RTL
levelEB:
	RTL
levelEC:
	RTL
levelED:
	RTL
levelEE:
	RTL
levelEF:
	RTL
levelF0:
	RTL
levelF1:
	RTL
levelF2:
	RTL
levelF3:
	RTL
levelF4:
	RTL
levelF5:
	RTL
levelF6:
	RTL
levelF7:
	RTL
levelF8:
	RTL
levelF9:
	RTL
levelFA:
	RTL
levelFB:
	RTL
levelFC:
	RTL
levelFD:
	RTL
levelFE:
	RTL
levelFF:
	RTL
level100:
	RTL
level101:
	RTL
level102:
	RTL
level103:
	RTL
level104:
	RTL
level105:
	RTL
level106:
	RTL
level107:
	RTL
level108:
	RTL
level109:
	RTL
level10A:
	RTL
level10B:
	RTL
level10C:
	RTL
level10D:
	RTL
level10E:
	RTL
level10F:
	RTL
level110:
	RTL
level111:
	RTL
level112:
	RTL
level113:
	RTL
level114:
	RTL
level115:
	RTL
level116:
	RTL
level117:
	RTL
level118:
	RTL
level119:
	RTL
level11A:
	RTL
level11B:
	RTL
level11C:
	RTL
level11D:
	RTL
level11E:
	RTL
level11F:
	RTL
level120:
	RTL
level121:
	RTL
level122:
	RTL
level123:
	RTL
level124:
	RTL
level125:
	RTL
level126:
	RTL
level127:
	RTL
level128:
	RTL
level129:
	RTL
level12A:
	RTL
level12B:
	RTL
level12C:
	RTL
level12D:
	RTL
level12E:
	RTL
level12F:
	RTL
level130:
	RTL
level131:
	RTL
level132:
	RTL
level133:
	RTL
level134:
	RTL
level135:
	RTL
level136:
	RTL
level137:
	RTL
level138:
	RTL
level139:
	RTL
level13A:
	RTL

; elevator room
level13B:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0050 : db $10,$40	; | deck exit (right)
		dw $05F9				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$00F0 : db $10,$40	; | engine room exit
		dw $0425				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$00F0 : db $10,$40	; | deck exit (left)
		dw $0DF9				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0270 : db $10,$40	; | training room exit
		dw $05F4				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$02F0 : db $10,$40	; | corridor exit
		dw $05F5				; |
		BCC $01 : RTL				;/

		REP #$20
		LDA.w #.RoomPointers
		JSL LoadCameraBox

		REP #$20
		LDA #$0380 : JSL END_Down
		RTL



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
.Box0	%CameraBox(0, 0, 0, 3, $FF, 0, 0)

.ScreenMatrix	db $00
		db $00
		db $00
		db $00
		db $00

.DoorList	db $FF			; no doors
.DoorTable



level13C:
	RTL
level13D:
	RTL
level13E:
	RTL
level13F:
	RTL
level140:
	RTL
level141:
	RTL
level142:
	RTL
level143:
	RTL
level144:
	RTL
level145:
	RTL
level146:
	RTL
level147:
	RTL
level148:
	RTL
level149:
	RTL
level14A:
	RTL
level14B:
	RTL
level14C:
	RTL
level14D:
	RTL
level14E:
	RTL
level14F:
	RTL
level150:
	RTL
level151:
	RTL
level152:
	RTL
level153:
	RTL
level154:
	RTL
level155:
	RTL
level156:
	RTL
level157:
	RTL
level158:
	RTL
level159:
	RTL
level15A:
	RTL
level15B:
	RTL
level15C:
	RTL
level15D:
	RTL
level15E:
	RTL
level15F:
	RTL
level160:
	RTL
level161:
	RTL
level162:
	RTL
level163:
	RTL
level164:
	RTL
level165:
	RTL
level166:
	RTL
level167:
	RTL
level168:
	RTL
level169:
	RTL
level16A:
	RTL
level16B:
	RTL
level16C:
	RTL
level16D:
	RTL
level16E:
	RTL
level16F:
	RTL
level170:
	RTL
level171:
	RTL
level172:
	RTL
level173:
	RTL
level174:
	RTL
level175:
	RTL
level176:
	RTL
level177:
	RTL
level178:
	RTL
level179:
	RTL
level17A:
	RTL
level17B:
	RTL
level17C:
	RTL
level17D:
	RTL
level17E:
	RTL
level17F:
	RTL
level180:
	RTL
level181:
	RTL
level182:
	RTL
level183:
	RTL
level184:
	RTL
level185:
	RTL
level186:
	RTL
level187:
	RTL
level188:
	RTL
level189:
	RTL
level18A:
	RTL
level18B:
	RTL
level18C:
	RTL
level18D:
	RTL
level18E:
	RTL
level18F:
	RTL
level190:
	RTL
level191:
	RTL
level192:
	RTL
level193:
	RTL
level194:
	RTL
level195:
	RTL
level196:
	RTL
level197:
	RTL
level198:
	RTL
level199:
	RTL
level19A:
	RTL
level19B:
	RTL
level19C:
	RTL
level19D:
	RTL
level19E:
	RTL
level19F:
	RTL
level1A0:
	RTL
level1A1:
	RTL
level1A2:
	RTL
level1A3:
	RTL
level1A4:
	RTL
level1A5:
	RTL
level1A6:
	RTL
level1A7:
	RTL
level1A8:
	RTL
level1A9:
	RTL
level1AA:
	RTL
level1AB:
	RTL
level1AC:
	RTL
level1AD:
	RTL
level1AE:
	RTL
level1AF:
	RTL
level1B0:
	RTL
level1B1:
	RTL
level1B2:
	RTL
level1B3:
	RTL
level1B4:
	RTL
level1B5:
	RTL
level1B6:
	RTL
level1B7:
	RTL
level1B8:
	RTL
level1B9:
	RTL
level1BA:
	RTL
level1BB:
	RTL
level1BC:
	RTL
level1BD:
	RTL
level1BE:
	RTL
level1BF:
	RTL
level1C0:
	RTL
level1C1:
	RTL
level1C2:
	RTL
level1C3:
	RTL
level1C4:
	RTL
level1C5:
	RTL
level1C6:
	RTL
level1C7:
	RTL
level1C8:
	RTL
level1C9:
	RTL
level1CA:
	RTL
level1CB:
	RTL
level1CC:
	RTL
level1CD:
	RTL
level1CE:
	RTL
level1CF:
	RTL
level1D0:
	RTL
level1D1:
	RTL
level1D2:
	RTL
level1D3:
	RTL
level1D4:
	RTL
level1D5:
	RTL
level1D6:
	RTL
level1D7:
	RTL
level1D8:
	RTL
level1D9:
	RTL
level1DA:
	RTL
level1DB:
	RTL
level1DC:
	RTL
level1DD:
	RTL
level1DE:
	RTL
level1DF:
	RTL
level1E0:
	RTL
level1E1:
	RTL
level1E2:
	RTL
level1E3:
	RTL
level1E4:
	RTL
level1E5:
	RTL
level1E6:
	RTL
level1E7:
	RTL
level1E8:
	RTL
level1E9:
	RTL
level1EA:
	RTL
level1EB:
	RTL
level1EC:
	RTL
level1ED:
	RTL
level1EE:
	RTL
level1EF:
	RTL
level1F0:
	RTL


; the secondary exit format actually makes no sense
; fusoya what were you even thinking??
;
; so, the lo byte is exactly what you'd expect, it's the lo byte of the secondary exit number
; hi byte has this format:
;	Hhhhwlsh
;	w - water level flag (if secondary exit = 0, this is the midway entrance flag)
;	l - lunar magic flag (always set)
;	s - secondary exit flag (always set)
;	H - highest bit of secondary exit
;	hhhh - third nybble of secondary exit
;
; this means that the third nybble is split between bit 0 and bits 4-6 in the hi byte, instead of just being the hi or lo nybble like you'd expect
;
; to translate from secondary exit/entrance number:
;	lo byte -> lo byte
;	third nybble -> lowest bit to lowest bit of hi byte
;			-> rest in bits 4-6 of hi byte
;	highest bit -> highest bit of hi byte
;	then set 0x06 bits in hi byte to enable lunar magic secondary exit


; command bridge
level1F1:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | engine room exit
		dw $0C25				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $08 : dw $0060,$0000 : db $40,$10	; | deck exit
		dw $F790				; |
		BCC $01 : RTL				;/


		REP #$20
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
.Box0	%CameraBox(0, 0, 1, 0, $FF, 0, 0)

.ScreenMatrix	db $00,$00,$00

.DoorList	db $FF			; no doors
.DoorTable



; empty room
level1F2:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		RTL


; empty room
level1F3:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		RTL


; training room
level1F4:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0170 : db $10,$40	; | elevator exit
		dw $97B3				; |
		BCC $01 : RTL				;/

		RTL

; corridor
level1F5:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | coin hoard exit
		dw $05F8				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $02F0,$0090 : db $10,$40	; | elevator exit
		dw $97B4				; |
		BCC $01 : RTL				;/

		RTL


level1F6:	; unused mode7 level
RTL		;


; living rooms
level1F7:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		REP #$20
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
.Box0	%CameraBox(0, 0, 0, 0, $FF, 0, 0)
.Box1	%CameraBox(1, 0, 0, 0, $FF, 0, 0)
.Box2	%CameraBox(2, 0, 0, 0, $FF, 0, 0)
.Box3	%CameraBox(3, 0, 0, 0, $FF, 0, 0)

.ScreenMatrix	db $00,$01,$02,$03

.DoorList	db $FF			; no doors
.DoorTable





; coin hoard
level1F8:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0090 : db $10,$40	; | corridor exit
		dw $0DF5				; |
		BCC $01 : RTL				;/

		RTL


; airship deck
level1F9:
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $0410,$0140 : db $10,$40	; | elevator exit (right)
		dw $97B2				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $04E0,$00A0 : db $10,$40	; | elevator exit (left)
		dw $97B0				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $04 : dw $0660,$00E0 : db $40,$10	; | command bridge exit
		dw $0DF1				; |
		BCC $01 : RTL				;/

		REP #$20
		LDA #$01A0 : JSL END_Down


		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL


		.HDMA
		PHP
		REP #$20
		INC !Level+2
		INC !Level+2
		INC !Level+2
		INC !Level+2

		LDA !Level+2 : STA $1E
		STZ $20
		PLP
		RTL


; mario tutorial room
level1FA:
		RTL


; luigi tutorial room
level1FB:
		RTL


; kadaal tutorial room
level1FC:
		RTL


; leeway tutorial room
level1FD:
		RTL


; alter tutorial room
level1FE:
		RTL


; peach
level1FF:
		RTL




CLEAR_DYNAMIC_BG3:
		PHP
		REP #$30
		LDA #$38FC
		LDX #$003E
	-	STA $0020,x
		DEX #2
		BPL -
		PLP
		RTL


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
		RTL

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
		RTL

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
		RTL

.DoneUp		LDA $1A
		CMP $00
		BEQ .DoneRight
		INC A
		STA !Level+2
		LDA.w #.ScrollRight : STA !HDMAptr+0
		LDA.w #.ScrollRight>>8 : STA !HDMAptr+1
.DoneRight	RTL


		.ScrollUp
		PHP
		REP #$20
		LDA !Level+2
		STA $1C
		STA $7464
		LDA #$0000
		STA !HDMAptr+0
		STA !HDMAptr+1
		PLP
		RTL

		.ScrollRight
		PHP
		REP #$20
		STZ $1C
		STZ $7464
		LDA !Level+2
		STA $1A
		STA $7462
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
		JSL GET_DIVISION
		LDA $4214
		RTL

GET_DIVISION:	NOP #2
		RTL



VineDestroy:

		.INIT
		LDX #$17					;\
		LDA #$FF					; | Write 0xFF ("off") to all vine destroy regs
	-	STA !VineDestroy+1,x				; |
		DEX : BPL -					;/
		RTL						; > Return


		.MAIN
		LDA.b #..SA1 : STA $3180			;\
		LDA.b #..SA1>>8 : STA $3181			; | Make the SA-1 process this since it's really intense
		LDA.b #..SA1>>16 : STA $3182			; |
		JSR $1E80					;/
		RTL

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
	;	LDA #$01 : STA $0077C0,x			; |
	;	LDA $9A : STA $0077C8,x				; | Spawn smoke puff
	;	LDA $9B : STA.l !SmokeXHi,x			; |
	;	LDA $98 : STA $0077C4,x				; |
	;	LDA $99 : STA.l !SmokeYHi,x			; |
	;	LDA #$01 : STA.l !SmokeHack,x			; |
	;	LDA #$13 : STA $0077CC,x			;/
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
		RTL

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
		RTL

		..ReturnUL
		SEP #$20
		LDA #$00
		RTL

		..ReturnUR
		SEP #$20
		LDA #$04
		RTL

		..ReturnDR
		SEP #$20
		LDA #$0C
		RTL



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
		JML .DrawLightning

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
		JML .Main			;/

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
		AND #$FFF0			; | Lo byte of Y in $05, hi byte in $0B (always staRTL at screen top)
		STA $05				; |
		STA $0A				;/
		LDA $0E				;\
		SEC : SBC $05			; | Height in $07
		BEQ $02 : BPL $03		; |
		JML .WarningBolt		; | > Go to .WarningBolt if zero or negative
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

		JSL .BrickBreak			; > Break bricks

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
		BEQ $03 : JSL .WaterShock	;/
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
		RTL				;/

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
		RTL

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
		RTL


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
		RTL

; To call:
; REP #$20
; LDA.w #.TalkBox
; JSL TalkOnce
;
; Data format:
; 00: ID (bit in RAM table, min 0 max 15) times 2
; 01-02: Xcoord
; 03-04: Ycoord
; 05: Width
; 06: Height
; 07-08: MSG number
TalkOnce:
		STA $00
		LDA ($00) : TAX				; ID in X
		LDA.l .BitTable,x			;\ only trigger message once
		AND $6DF5 : BNE .Return			;/

		PHX					; ID on stack
		INC $00
		LDA ($00)
		STA $04					; Xlo in $04
		STA $09					; Xhi in $0A
		INC $00
		INC $00
		LDA ($00) : STA $05			; Ylo in $05
		XBA : STA $0B				; Yhi in $0B
		INC $00
		INC $00
		LDA ($00) : STA $06			; dimensions in $06-$07
		INC $00
		INC $00
		LDA ($00) : PHA				; push message number

		SEP #$21				; 8-bit, set carry
		JSL !PlayerClipping			; check player contact
		BCC .ReturnP
		STZ $00					;\
		LSR A : BCC +				; |
		PHA					; |
		LDA !P2Blocked-$80			; |
		AND #$04				; |
		TSB $00					; | only trigger on a player that's on the ground
		PLA					; |
	+	LSR A : BCC +				; |
		LDA !P2Blocked				; |
		AND #$04				; |
		TSB $00					; |
	+	LDA $00					;/
		REP #$20
		BEQ .ReturnP
		PLA : STA !MsgTrigger			; trigger MSG
		PLX
		LDA.l .BitTable,x : TSB $6DF5		; mark message as triggered
		RTL

		.ReturnP
		REP #$20
		PLA
		PLX

		.Return
		RTL
		

		.BitTable
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
	.Return	RTL

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
		RTL

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
		CMP #$05 : BCS $04 : JML ..Return	;/

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
	+	JSL DebrisRNG

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
		RTL						;/

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
		DEX #2 : BMI $04 : JMP .Next			; Loop
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
		RTL


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




WATER_BOX:
		REP #$20
		LDA $01,s			;\
		INC A				; | lo / hi bytes
		STA $00				;/
		CLC : ADC #$0005		;\ update stack value (return address)
		STA $01,s			;/

		LDY #$02			;\
		LDA ($00),y			; | box Y
		STA $05				; |
		STA $0A				;/
		LDY #$04			;\ box dimensions
		LDA ($00),y : STA $06		;/
		LDA ($00)			;\
		STA $09				; | box X
		SEP #$20			; |
		STA $04				;/

		LDA !P2Invinc-$80 : PHA		;\ backup invinc regs
		LDA !P2Invinc : PHA		;/
		STZ !P2Invinc-$80		;\ temp clear invinc regs
		STZ !P2Invinc			;/
		SEC : JSL !PlayerClipping	; check for player contact
		PLX : STX !P2Invinc		;\ restore invinc regs
		PLX : STX !P2Invinc-$80		;/
		LSR A : BCC .P2
	.P1	PHA
		LDA $0B : XBA
		LDA $05
		REP #$20
		CMP !P2YPosLo-$80
		SEP #$20
		BCC ..under
		..over
		LDA #$A0 : TSB !P2ExtraBlock-$80
		BRA +
		..under
		LDA #$E0 : TSB !P2ExtraBlock-$80
	+	PLA
	.P2	LSR A : BCC .Return
		LDA $0B : XBA
		LDA $05
		REP #$20
		CMP !P2YPosLo
		SEP #$20
		BCC ..under
		..over
		LDA #$A0 : TSB !P2ExtraBlock
		RTL
		..under
		LDA #$E0 : TSB !P2ExtraBlock

		.Return
		RTL




; JSL here
; the JSL should be followed by 9 data bytes (JSL/RTL will return to first instruction after data)
; 00:		directional flags (1 = right, 2 = left, 4 = down, 8 = up), 0 will never trigger F will always trigger
; 01-02:	16-bit Xpos of box, left border
; 03-04:	16-bit Ypos of box, top border
; 05:		8-bit width of box
; 06:		8-bit height of box
; 07-08:	entrance link data
;
; if a player touches the box and is moving in one of the enabled directions, a level->level transition will be triggered
;
; directions key:
; 00		NEVER
; 01		right
; 02		left
; 03		ALWAYS
; 04		down
; 05		right + down
; 06		left + down
; 07		ALWAYS
; 08		up
; 09		right + up
; 0A		left + up
; 0B		ALWAYS
; 0C		ALWAYS
; 0D		ALWAYS
; 0E		ALWAYS
; 0F		ALWAYS

WARP_BOX:
		REP #$20

		LDA $01,s			;\
		INC A				; | lo / hi bytes
		STA $00				;/
		CLC : ADC #$0008		;\ update stack value (return address)
		STA $01,s			;/

		LDY #$07			;\ entrance link data
		LDA ($00),y : STA !BigRAM+2	;/
		LDY #$03			;\
		LDA ($00),y			; | box Y
		STA $05				; |
		STA $0A				;/
		LDY #$05			;\ box dimensions
		LDA ($00),y : STA $06		;/
		LDY #$01			;\
		LDA ($00),y			; |
		STA $09				; | box X
		SEP #$20			; |
		STA $04				;/
		LDA ($00) : STA !BigRAM		; directional value
		LDA !P2Invinc-$80 : PHA		;\ backup invinc regs
		LDA !P2Invinc : PHA		;/
		STZ !P2Invinc-$80		;\ temp clear invinc regs
		STZ !P2Invinc			;/
		SEC : JSL !PlayerClipping	; check for player contact
		PLX : STX !P2Invinc		;\ restore invinc regs
		PLX : STX !P2Invinc-$80		;/
		BCC .Return

		LDX !BigRAM			;\ don't check directions if all directions are enabled already
		CPX #$0F : BEQ .Link		;/
		LSR A : BCC .P2			;\
	.P1	PHA				; |
		LDY #$00			; | check player 1
		JSR .CheckDirections		; |
		PLA				; > pull A first
		BCS .Link			;/
		LSR A : BCC .Return		; > return if only player 1 should be checked
	.P2	LDY #$80			;\
		JSR .CheckDirections		; | check player 2
		BCS .Link			;/

		.Return
		CLC
		RTL

		.Link
		LDX #$1F			;\
		LDA !BigRAM+2			; | level link data (lo byte)
	-	STA $79B8,x			; |
		DEX : BPL -			;/
		LDX #$1F			;\
		LDA !BigRAM+3			; | level link data (hi byte)
	-	STA $79D8,x			; |
		DEX : BPL -			;/
		JMP EXIT_Exit+2


		.CheckDirections
		LDA !P2Platform-$80,y : BEQ +		; note that this branch only triggers if A = 0, so no LDA #$00 is needed
		TAX
		DEX
		LDA !SpriteXSpeed,x
	+	CLC : ADC !P2XSpeed-$80,y
		CLC : ADC !P2VectorX-$80,y
		BEQ ..checkY
		ASL A
		ROL A
		INC A
		AND !BigRAM : BNE ..match

		..checkY
		LDA !P2Platform-$80,y : BEQ +		; note that this branch only triggers if A = 0, so no LDA #$00 is needed
		TAX
		DEX
		LDA !SpriteYSpeed,x
	+	CLC : ADC !P2YSpeed-$80,y
		CLC : ADC !P2VectorY-$80,y
		BEQ ..nomatch
		ASL A
		ROL A
		INC A
		ASL #2
		AND !BigRAM : BNE ..match

		..nomatch
		CLC
		RTS

		..match
		SEC
		RTS



	EXIT:
		.Exit
		SEP #$20
		LDA #$06 : STA $71
		STZ $88
		STZ $89
		SEC
		RTL

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
		RTL

		.Left
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI .Exit
		CMP !P2XPosLo-$80 : BCS .Exit
	+	BIT !P2XPosLo : BMI .Exit
		LDX !P2Status : BNE .Return
		CMP !P2XPosLo : BCS .Exit
		SEP #$20
		RTL

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
		RTL

		.Up
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI ++
		CMP !P2YPosLo-$80 : BCS ++
	+	BIT !P2YPosLo : BMI ++
		LDX !P2Status : BNE .Return
		CMP !P2YPosLo
		BCC ..fail
	++	JMP .Exit
		..fail
		SEP #$20
		RTL


; Same as the normal one, except it fades the music upon exit
	EXIT_FADE:
		.Right
		JSL EXIT_Right
		BRA .Exit

		.Left
		JSL EXIT_Left
		BRA .Exit

		.Down
		JSL EXIT_Down
		BRA .Exit

		.Up
		JSL EXIT_Up

		.Exit
		LDA $71
		CMP #$06 : BNE .Return
		LDA #$80 : STA !SPC3

		.Return
		RTL



	END:
		.Right
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI +
		CMP !P2XPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		BIT !P2XPosLo : BMI +
		CMP !P2XPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTL

		.Left
		LDX !P2Status-$80 : BNE +
		CMP !P2XPosLo-$80 : BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2XPosLo : BCS .End
	+	SEP #$20
		RTL

		.Down
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI +
		CMP !P2YPosLo-$80
		BEQ .End
		BCC .End
	+	LDX !P2Status : BNE +
		BIT !P2YPosLo : BMI +
		CMP !P2YPosLo
		BEQ .End
		BCC .End
	+	SEP #$20
		RTL

		.Up
		LDX !P2Status-$80 : BNE +
		CMP !P2YPosLo-$80 : BCS .End
	+	LDX !P2Status : BNE +
		CMP !P2YPosLo : BCS .End
	+	SEP #$20
		RTL


		.End
		SEP #$20
		LDA #$02 : STA $73CE			; set this
		LDA #$80				;\ fade music
		STA !SPC3				;/
		STA $6DD5				; set exit
		LDX !Translevel : BEQ ..leveldone	;\ > intro level does not count
		LDA !LevelTable1,x : BMI ..beaten	; |
		LDA !LevelsBeaten			; |
		INC A					; |
		STA !LevelsBeaten			; > you've now beaten one more level (only once/level)
		ORA #$80				; | Set clear, remove midway
		..beaten				; |
		AND.b #$60^$FF				; > clear checkpoint
		STA !LevelTable1,x			;/
		STZ !LevelTable2,x			; > clear checkpoint level
		STZ $73CE				; > clear midway flag
		..leveldone

		.SaveTime				;\
		LDA !Difficulty				; | only save time on time mode
		AND #$04 : BEQ ..nosave			;/
		LDA !LevelTable3,x			;\
		ORA !LevelTable4,x			; |
		ORA !LevelTable5,x			; | always store time if there is none
		AND #$3F : BEQ ..storetime		; |
		..compare				;/
		LDA !LevelTable5,x			;\
		AND #$3F				; |
		CMP !TimeElapsedMinutes			; | check minutes
		BEQ ..checkseconds			; |
		BCS ..storetime				; |
		BCC ..nosave				;/
		..checkseconds				;\
		LDA !LevelTable4,x			; |
		AND #$3F				; |
		CMP !TimeElapsedSeconds			; | check seconds
		BEQ ..checkframes			; |
		BCS ..storetime				; |
		BCC ..nosave				;/
		..checkframes				;\
		LDA !LevelTable3,x			; | check frames
		AND #$3F				; |
		CMP !TimeElapsedFrames : BCC ..nosave	;/
		..storetime				;\
		LDA !LevelTable3,x			; |
		AND #$C0 : STA $00			; |
		LDA !LevelTable4,x			; |
		AND #$C0 : STA $01			; |
		LDA !LevelTable5,x			; |
		AND #$C0 : STA $02			; |
		LDA !TimeElapsedFrames			; |
		AND #$3F				; |
		ORA $00					; | store new fastest time
		STA !LevelTable3,x			; |
		LDA !TimeElapsedSeconds			; |
		AND #$3F				; |
		ORA $01					; |
		STA !LevelTable4,x			; |
		LDA !TimeElapsedMinutes			; |
		AND #$3F				; |
		ORA $02					; |
		STA !LevelTable5,x			; |
		..nosave				;/

		.UnlockNextLevel			;\
		REP #$10				; |
		LDX !Level				; |
		LDA.l LEVEL_Unlock,x			; |
		SEP #$10				; | unlock level
		TAX					; |
		LDA !LevelTable4,x			; |
		ORA #$80				; |
		STA !LevelTable4,x			;/

		LDA #$0B : STA !GameMode		; load overworld

		RTL					; return


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



