



;====================
;
; DEBUG SUBROUTINES
;
;====================


; input: void
; output: void
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
		LDA #$AA
		STA $41
		STA $42
		STA $43


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



; input: void
; output: void
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



; input: void
; output: void
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




















;=========================
;
; SUBROUTINES
;
;=========================


; input: void
; output: void
; clears all non-0xEE bytes in !SpriteLoadStatus
; this causes sprites to respawn unless they have been set to hard despawn (signified by load status 0xEE)
	ReloadSprites:
		LDX #$00						; loop through all slots
		.Loop							;\
		LDA !SpriteLoadStatus,x : BEQ .Next			; | check for loaded sprites
		CMP #$EE : BEQ .Next					;/
		STX $00							;\
		LDY #$0F						; |
	-	LDA !SpriteStatus,y : BEQ +				; | check if the sprite is still alive
		LDA !SpriteID,y						; |
		CMP $00 : BEQ .Next					; |
	+	DEY : BPL -						;/
		.Clear							;\ mark for reload
		LDA #$00 : STA !SpriteLoadStatus,x			;/
		.Next							;\
		INX							; | loop
		CPX #$FF : BNE .Loop					;/
		RTL							; return








; THIS ONE IS CURRENTLY UNUSED
; BUT IT MIGHT BE USED FOR UPGRADE SHOP

; this code uses $0400-$0BFF as a buffer, so be careful when using HDMA!
; input:
; .Char
;	A = added to !BG1Address
; normal
;	X = map16 index, lo byte
;	Y = map16 index, hi byte
	; LoadScreen:
		; PHP
		; STX $00
		; STY $01
		; REP #$10
		; LDX $00
		; BRA .Main

	; .Char	PHP
		; LDA !Characters
		; LSR #4
		; TAX
		; LDA.l .Screen+6,x : XBA
		; LDA.l .Screen,x
		; REP #$10
		; TAX

		; .Main
		; LDY #$0000

	; -	LDA $41C800,x : XBA
		; LDA $40C800,x
		; INX
		; STX $00
		; REP #$20
		; ASL A
		; PHX
		; PHY
		; PHP
		; JSL $06F540			; how the fuck did i find this?
		; PLP
		; PLX				; get "Y" in X
		; STA $0A
		; LDY #$0000
		; LDA [$0A],y : STA $0400,x
		; LDY #$0002
		; LDA [$0A],y : STA $0440,x
		; LDY #$0004
		; LDA [$0A],y : STA $0402,x
		; LDY #$0006
		; LDA [$0A],y : STA $0442,x
		; TXY
		; PLX

		; TYA
		; CLC : ADC #$0004
		; AND #$003F : BNE .Same
	; .New	TYA
		; CLC : ADC #$0040
		; TAY
	; .Same	INY #4
		; CPY #$0800 : BEQ .Done
		; SEP #$20
		; LDX $00
		; BRA -

	; .Done	JSL GetVRAM
		; REP #$20
		; LDA #$0400 : STA !VRAMbase+!VRAMtable+$02,x
		; LDA #$0000 : STA !VRAMbase+!VRAMtable+$04,x
		; LDA !BG1Address : STA !VRAMbase+!VRAMtable+$05,x
		; LDA #$0800 : STA !VRAMbase+!VRAMtable+$00,x
		; PLP
		; RTL


; .Screen		db $B0,$60,$10,$C0,$70,$20,$D0,$80
		; db $01,$03,$05,$06,$08,$0A,$0B,$0D












; THIS ONE NEEDS SERIOUS REWORK

Weather:
		PHP
		SEP #$30
		STA $00							; $00 = weather type
		LDA !41_WeatherTimer : BEQ .Spawn
		DEC A : STA !41_WeatherTimer
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
		STZ !Particle_Layer,x					; tile size
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
		STZ !Particle_Layer,x					; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
		RTS							; return


		.SpellParticles
		LDX $00							; X = index
		LDA $02							;\
		AND #$00FF						; |
		ASL #2							; | RN 1 determines X pos
		ADC $1A							; |
		SBC #$0180						; |
		STA !Particle_XLo,x					;/
		LDA $1C							;\
		ADC #$00D8						; | always spawn at the bottom of the screen
		STA !Particle_YLo,x					;/
		LDA $03							;\
		AND #$00F0						; | RN 2 determines X speed
		SEC : SBC #$0080					; |
		STA !Particle_XSpeed,x					;/
		LDA $04							;\
		AND #$00F0						; | RN 3 determines Y speed
		SEC : SBC #$0200					; |
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
		..tile							;\
		LDA !GFX_FelMagic_tile					; |
		CLC : ADC #$1A						; |
		STA !Particle_Tile,x					; | tile + prop
		LDA !GFX_FelMagic_prop					; |
		ADC #$00						; |
		AND #$01						; |
		ORA #$FA : STA !Particle_Prop,x				;/
		STZ !Particle_Layer,x					; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
	..R	RTS


		.MaskSpecial
		LDX $00							; X = index

		LDA $02
		AND #$000F
		ADC #$0D74
		STA !Particle_XLo,x
		LDA #$0138 : STA !Particle_YLo,x

		LDA $03
		AND #$00FF
		SBC #$0080
		STA !Particle_XSpeed,x
		BPL +
		CMP #$FFF0 : BCS ..0
		LDA #$0002 : BRA ..setacc
	+	CMP #$0020 : BCC ..0
		LDA #$FFFE : BRA ..setacc
	..0	LDA #$0000
		..setacc
		STA !Particle_XAcc,x
		STZ !Particle_YSpeed,x
		LDA #$00F8 : STA !Particle_YAcc,x

		SEP #$20						;\ same prop/tile as spell particles
		JMP .SpellParticles_tile				;/



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
	-	LDA.l !SpriteStatus,x
		CMP #$08 : BNE +
		LDA.l !ExtraBits,x
		AND #$08 : BEQ +
		LDA.l !SpriteNum,x
		CMP #$20 : BEQ ++
	+	DEX : BPL -
		RTS

	++	LDA.l !SpriteXLo,x : STA $02
		LDA.l !SpriteXHi,x : STA $03
		LDA.l !SpriteYHi,x : XBA
		LDA.l !SpriteYLo,x


		REP #$20
		LDX $00
		STA !Particle_XLo,x
		LDA $02 : STA !Particle_XLo,x
		LDA $04
		AND #$0003
		XBA
		STA !Particle_XAcc,x					; X acc = 0, Y acc = 0-3 (Y written via hi byte)

		LDA $04
		AND #$00FC
		ASL #2
		SEC : SBC #$0200
		STA !Particle_XSpeed,x
		LDA #$FE00 : STA !Particle_YSpeed

		SEP #$20
		LDA #$FF : STA !Particle_Tile,x				; tile
		LDA #$FF : STA !Particle_Prop,x				; prop
		STZ !Particle_Layer,x					; tile size
		LDA.b #!prt_basic_BG1 : STA !Particle_Type,x		; type
		RTS



		.LoadSnow
		PHB : PHK : PLB
		STA $00					; store weather type
		JSL GetVRAM
		REP #$30
		LDY.w #!File_Sprite_BG_1
		JSL GetFileAddress
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








;=====================
;
; SPRITE ROUTINES
;
;=====================
;
; these use A for input instead of a ROM byte
; the reason for this is to make them more flexible for level codes
; for example, you might want to have a list of sprite numbers to check or spawn
; with A input, you can simply loop over the list and call the routine each time
; if it used the ROM byte input method, you would need a bespoke call for each unique sprite number


; input:
;	A = sprite num to search
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output: void
; ereases all sprites of input type
	KillSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteNum,x
		CMP $00 : BNE ..next
		STZ !SpriteStatus,x
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		STA $00
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteNum,x
		CMP $00 : BNE ..next
		STZ !SpriteStatus,x
		..next
		DEX : BPL ..loop
		RTL

; input:
;	A = sprite num to search
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output: void
; KO's all sprites of input type
	KOSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteNum,x
		CMP $00 : BNE ..next
		LDA #$02 : STA !SpriteStatus,x
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		STA $00
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteNum,x
		CMP $00 : BNE ..next
		LDA #$02 : STA !SpriteStatus,x
		..next
		DEX : BPL ..loop
		RTL

; input:
;	A = sprite num to search
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output:
;	A = how many sprites of input type exist
;	$00 = A
	CountSprites:
	.Vanilla
		STZ $00
		STA $01
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteNum,x
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
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteNum,x
		CMP $01 : BNE ..next
		INC $00
		..next
		DEX : BPL ..loop
		LDA $00
		RTL

; input:
;	A = sprite num to search
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output:
;	X = index of found sprite (X = 0xFF if none was found)
;	n = 0 (BPL) if sprite was found, n = 1 (BMI) if sprite was not found
	SearchSprite:
	.Vanilla
		STA $00
		LDX #$0F
		..loop
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
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
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
		CMP $00 : BEQ ..thisone
		..next
		DEX : BPL ..loop
		..thisone
		RTL


; input:
;	A = sprite num to search
;	X = sprite index to start seeking (goes high -> low)
;		to seek from the top, X should be 0x0F
;		because the routine maintains X, it can be called multiple times to seek multiple sprites
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output:
;	X = index of found sprite (X = 0xFF if none was found)
;	n = 0 (BPL) if sprite was found, n = 1 (BMI) if sprite was not found
	SeekSprite:
	.Vanilla
		STA $00
		..loop
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
		CMP $00 : BEQ ..thisone
		..next
		DEX : BPL ..loop
		..thisone
		RTL

	.Custom
		STA $00
		..loop
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
		CMP $00 : BEQ ..thisone
		..next
		DEX : BPL ..loop
		..thisone
		RTL


; input:
;	JSL, followed by 2 bytes: 1 byte for minimum allowed sprite num, 1 byte for maximum allowed sprite num
;	X = sprite index to start seeking (goes high -> low)
;		to seek from the top, X should be 0x0F
;		because the routine maintains X, it can be called multiple times to seek multiple sprites
;	default is _Vanilla, but _Custom can be specified to search custom sprites
; output:
;	X = index of found sprite (X = 0xFF if none was found)
;	n = 0 (BPL) if sprite was found, n = 1 (BMI) if sprite was not found
	SeekSpriteRange:
	.Vanilla
		REP #$20
		LDA $01,s				;\ pointer = return address +1
		INC A : STA $00				;/
		INC A : STA $01,s			; return address +2
		LDA ($00) : STA $00			; read word at pointer
		SEP #$20
		..loop
		LDA !ExtraBits,x
		AND #$08 : BNE ..next
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
		CMP $00 : BCC ..next
		CMP $01
		BEQ ..thisone
		BCC ..thisone
		..next
		DEX : BPL ..loop
		RTL
		..thisone
		REP #$80
		RTL

	.Custom
		REP #$20
		LDA $01,s				;\ pointer = return address +1
		INC A : STA $00				;/
		INC A : STA $01,s			; return address +2
		LDA ($00) : STA $00			; read word at pointer
		SEP #$20
		..loop
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteStatus,x
		CMP #$01 : BEQ ..ok
		CMP #$08 : BCC ..next
		..ok
		LDA !SpriteNum,x
		CMP $00 : BCC ..next
		CMP $01
		BEQ ..thisone
		BCC ..thisone
		..next
		DEX : BPL ..loop
		RTL
		..thisone
		REP #$80
		RTL



; input:
;	A = sprite num
;	$00 = 16-bit Xpos
;	$02 = 16-bit Ypos
; output:
;	X = sprite index (0xFF if spawn failed)
;	n = 0 (BPL) if sprite was successfully spawned, n = 1 (BMI) if spawn failed
	SpawnSprite:
	.Vanilla
		LDX #$0F
		..loop
		LDY !SpriteStatus,x : BNE ..next
		STA !SpriteNum,x
		STZ !ExtraBits,x
		LDA $00 : STA !SpriteXLo,x
		LDA $01 : STA !SpriteXHi,x
		LDA $02 : STA !SpriteYLo,x
		LDA $03 : STA !SpriteYHi,x
		JSL !ResetSprite
		INC !SpriteStatus,x
		RTL
		..next
		DEX : BPL ..loop
		RTL

	.Custom
		LDX #$0F
		..loop
		LDY !SpriteStatus,x : BNE ..next
		STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		LDA $00 : STA !SpriteXLo,x
		LDA $01 : STA !SpriteXHi,x
		LDA $02 : STA !SpriteYLo,x
		LDA $03 : STA !SpriteYHi,x
		PHB
		JSL !ResetSprite
		PLB
		INC !SpriteStatus,x
		RTL
		..next
		DEX : BPL ..loop
		RTL





;=========================
;
; FUSION SPRITE ROUTINES
;
;=========================


; input: void
; output:
;	X = fusion sprite index (_X version)
;	Y = fusion sprite index (_Y version)
;	!Ex_Index = fusion sprite index
	GetExIndex:
	.X
		LDY.b #!Ex_Amount-1			; Y = loop counter
		LDX !Ex_Index				; X = starting index
		..loop					;\
		LDA !Ex_Num,x : BEQ ..thisone		; |
		DEX					; | search table
		BPL $02 : LDX.b #!Ex_Amount-1		; |
		DEY : BPL ..loop			;/
		LDX #$00				; default index = 00
		..thisone
		STX !Ex_Index				; update index
		RTL

	.Y
		LDX.b #!Ex_Amount-1			; Y = loop counter
		LDY !Ex_Index				; X = starting index
		..loop					;\
		LDA !Ex_Num,y : BEQ ..thisone		; |
		DEY					; | search table
		BPL $02 : LDY.b #!Ex_Amount-1		; |
		DEX : BPL ..loop			;/
		LDY #$00				; default index = 00
		..thisone
		STY !Ex_Index				; update index
		RTL











;=========================
;
; MORE SUBROUTINES
;
;=========================




; REWORKING THESE TO USE STRUCT INPUT IS NEXT
; it will just be a word though, nothing complex


; something like...
; SCROLL:
;	_Full (default)
;		takes 2 words: X coord, Y coord
;	_H
;		takes 1 word: X coord
;	_V
;		takes 1 word: Y coord
;
; camera is robust enough that using its own registers should be good enough, no !Level+2 required
; the routine sets up an !HDMAptr code that scrolls the camera towards the target coord(s)
; it will 





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
		LDA !LevelWidth
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

		; LDA #$01+!MinorOffset : STA !Ex_Num,x	; number
		; LDA #$50
		; SEC : SBC !BossData+1			; scale with platform
		; CLC : ADC $00
		; STA !Ex_YLo,x				; Y lo
		; LDA #$D0
		; CLC : ADC $01
		; STA !Ex_XLo,x				; X lo
		; LDA #$01 : STA !Ex_YHi,x		; Y hi
		; LDA #$0C : STA !Ex_XHi,x		; X hi
		; LDA #$FC
		; CLC : ADC $02
		; STA !Ex_YSpeed,x			; Y speed
		; LDA #$FC
		; CLC : ADC $03
		; STA !Ex_XSpeed,x			; X speed


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









;========================
;
; STRUCT INPUT ROUTINES
;
;========================


; input: JSL, followed by talk box struct
; output: void
;
; talk box struct is as follows:
; 00		talk box ID (determines corresponding bit in !TranslevelFlags+$20)
; 01-02		message ID, input for !MsgTrigger
; 03-08		collision box for message trigger
	TALK_BOX:
		REP #$30
		LDA $01,s : TAY
		CLC : ADC #$0009
		STA $01,s
		INY

		LDA $0000,y
		AND #$00FF
		ASL A : TAX
		LDA.l CORE_BITS_16,x : STA $00		; ID
		AND !TranslevelFlags+$20 : BNE .Return

		LDA $0001,y : STA $02			; msg value

		LDA $0003,y : STA $E8			; box X
		LDA $0005,y : STA $EA			; box Y
		LDA $0007,y : STA $EE-1			; box H (lo byte only)
		AND #$00FF : STA $EC			; box W
		SEP #$30
		STZ $EF					; clear box H hi
		JSL PlayerContact : BCC .Return

		REP #$20
		LDA $02 : STA !MsgTrigger
		LDA $00 : TSB !TranslevelFlags+$20

		.Return
		SEP #$20
		RTL




; input: JSL, followed by collision box (16,16,8,8) for water
; output: void
	WATER_BOX:
		REP #$30
		LDA $01,s : TAY
		CLC : ADC #$0006
		STA $01,s
		INY
		LDA $0000,y : STA $E8			; box X
		LDA $0002,y : STA $EA			; box Y
		LDA $0004,y : STA $EE-1			; box H (lo byte only)
		AND #$00FF : STA $EC			; box W
		SEP #$30
		STZ $EF					; clear box H hi

		JSL PlayerContact : BCC .Return		; check for player contact
		LSR A : BCC .P2
	.P1	STA $00
		REP #$20
		LDA $EA
		CMP !P2YPosLo-$80
		SEP #$20
		BCC ..under
		..over
		LDA #$A0 : TSB !P2ExtraBlock-$80
		BRA +
		..under
		LDA #$E0 : TSB !P2ExtraBlock-$80
	+	LDA $00
	.P2	LSR A : BCC .Return
		REP #$20
		LDA $EA
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




; input: JSL, followed by rift box struct
; output: void
;
; rift box struct is as follows:
; 00-01:	rift offset to add to X position
; 02-03:	16-bit left camera limit
; 04-05:	16-bit right camera limit
; 06-07:	16-bit top player limit
; 08-09:	16-bit bottom player limit
	RIFT_BOX:
		REP #$30
		LDA $01,s : TAY
		CLC : ADC #$000A
		STA $01,s
		INY

		LDA !CameraXDelta : BEQ .Return		; if camera didn't move, return
		EOR $0000,y : BPL .Return		; if moving in same direction as rift, return

		.CheckCamera
		LDA $1A
		CMP $0002,y : BCC .Return
		CMP $0004,y : BCS .Return

		.CheckPlayers
		..p1
		LDY !P2Status-$80 : BNE ..p2
		LDA !P2Y-$80
		CMP $0006,y : BCC ..p2
		CMP $0008,y : BCC SpaceTimeLoop
		..p2
		LDY !P2Status : BNE .Return
		LDA !P2Y
		CMP $0006,y : BCC .Return
		CMP $0008,y : BCC SpaceTimeLoop

		.Return
		SEP #$30
		RTL


; input: Y = address (bank B) of rift offset value
; output: void
	SpaceTimeLoop:
		.Camera
		LDA $0000,y : STA $00
		CLC : ADC $1A
		STA $1A
		LDA $7462
		CLC : ADC $00
		STA $7462
		LDA !CameraBackupX
		CLC : ADC $00
		STA !CameraBackupX

		.Players
		LDA !P2X-$80
		CLC : ADC $00
		STA !P2X-$80
		LDA !P2X
		CLC : ADC $00
		STA !P2X

		.Sprites
		SEP #$30
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..next
		LDA !SpriteXHi,x : XBA
		LDA !SpriteXLo,x
		REP #$20
		CLC : ADC #$0030
		CMP $1A : BCC ..spriteout
		SEC : SBC #$0140
		BMI ..spriteneg				; if sprite is too close to left border of level to make this calc, just assume it should move
		CMP $1A : BCS ..spriteout
		..spriteneg
		CLC : ADC #$0110
		CLC : ADC $00
		SEP #$20
		STA !SpriteXLo,x
		XBA : STA !SpriteXHi,x
		..spriteout
		SEP #$20
		..next
		DEX : BPL ..loop

		.FusionSprites
		LDX #!Ex_Amount
		..loop
		LDA !Ex_Num,x : BEQ ..next
		LDA !Ex_XLo,x
		CLC : ADC $00
		STA !Ex_XLo,x
		LDA !Ex_XHi,x
		ADC $00
		STA !Ex_XHi,x
		..next
		DEX : BPL ..loop

		.Particles
		PHB
		LDA #$41 : PHA : PLB
		REP #$30
		LDX #$0000
		..loop
		LDA !Particle_Type,x
		AND #$00FF : BEQ ..next
		LDA !Particle_X,x
		CLC : ADC $00
		STA !Particle_X,x
		..next
		TXA
		CLC : ADC.w #!Particle_Size
		TAX
		CPX.w #(!Particle_Size*!Particle_Count) : BCC ..loop
		PLB

		.Return
		SEP #$30
		RTL





; input: JSL, followed by a warp box struct
; output: C = 0 (BCC) means warp box was not triggered, C = 1 (BCS) means warp box was triggered
;
; warp box struct is as follows:
; 00:		directional flags (1 = right, 2 = left, 4 = down, 8 = up), 0 will never trigger F will always trigger
; 01-02:	16-bit Xpos of box, left border
; 03-04:	16-bit Ypos of box, top border
; 05:		8-bit width of box
; 06:		8-bit height of box
; 07-08:	!LevelEntry word
;
; if a player touches the box and is moving in one of the enabled directions, a level->level transition will be triggered
;
; directions key:
; 00		NEVER (don't use)
; 01		right
; 02		left
; 03		right / left
; 04		down
; 05		right / down
; 06		left / down
; 07		right / left / down
; 08		up
; 09		right / up
; 0A		left / up
; 0B		right / left / up
; 0C		down / up
; 0D		right / down / up
; 0E		left / down / up
; 0F		ALWAYS (special)
;
; generally, only 00, 01, 02, 04, 08, and 0F are used
	WARP_BOX:
		REP #$30
		LDA $01,s : TAY
		CLC : ADC #$0009
		STA $01,s
		INY
		LDA $0007,y : STA !BigRAM+2		; entrance data
		LDA $0001,y : STA $E8			; box X
		LDA $0003,y : STA $EA			; box Y
		LDA $0005,y : STA $EE-1			; box H (lo byte only)
		AND #$00FF : STA $EC			; box W
		LDA $0000,y : STA !BigRAM+0		; directional value
		SEP #$30
		STZ $EF					; clear box H hi

		JSL PlayerContact : BCC .Return		; check for player contact

		LDX !BigRAM+0				;\ don't check directions if all directions are enabled already
		CPX #$0F : BEQ .Link			;/
		LSR A : BCC .P2				;\
	.P1	PHA					; |
		LDY #$00 : JSR .CheckDirections		; | check player 1
		PLA					; > pull A first
		BCS .Link				;/
		LSR A : BCC .Return			; > return if only player 1 should be checked
	.P2	LDY #$00 : JSR .CheckDirections		;\ check player 2
		BCS .Link				;/

		.Return
		CLC
		RTL

		.Link
		REP #$20				;\ get level entrance number
		LDA !BigRAM+2 : STA !LevelEntry		;/
		JMP EXIT_Exit				; load next sublevel


		.CheckDirections
		CLC
		LDA !P2Platform-$80,y : BEQ +		; note that this branch only triggers if A = 0, so no LDA #$00 is needed
		TAX
		DEX
		LDA !SpriteXSpeed,x
	+	ADC !P2XSpeed-$80,y
		ADC !P2VectorX-$80,y
		BEQ ..checkY
		AND #$80
		ASL A
		ROL A
		INC A
		AND !BigRAM+0 : BNE ..match
		..checkY
		CLC
		LDA !P2Platform-$80,y : BEQ +		; note that this branch only triggers if A = 0, so no LDA #$00 is needed
		TAX
		DEX
		LDA !SpriteYSpeed,x
	+	ADC !P2YSpeed-$80,y
		ADC !P2VectorY-$80,y
		BEQ ..nomatch
		AND #$80
		ASL A
		ROL A
		INC A
		ASL #2
		AND !BigRAM+0 : BNE ..match
		..nomatch
		CLC
		RTS
		..match
		SEC
		RTS



; input: JSL, followed by door box struct
; output: void
;
; door box struct is as follows:
; 00	16-bit X position
; 02	16-bit Y position
; 04	8-bit width
; 05	8-bit height
; 06	16-bit entrance data
	DOOR_BOX:
		REP #$30					;\
		LDA $01,s : TAY					; |
		CLC : ADC #$0008				; | get read address and update return address on stack
		STA $01,s					; |
		INY						;/
		LDA $0006,y : STA $02				; save entrance data
		LDA $0000,y : STA $E8				;\
		LDA $0002,y : STA $EA				; |
		LDA $0004,y : STA $EE-1				; | get door box clipping
		AND #$00FF : STA $EC				; |
		SEP #$30					; |
		STZ $EF						;/

		JSL PlayerContact : BCC .Return
		LSR A : BCC .P2

		.P1
		STA $00
		LDA !P2Blocked-$80
		AND #$04 : BEQ ..done
		LDA $6DA6
		AND #$08 : BNE .EnterDoor
		..done
		LDA $00

		.P2
		LSR A : BCC .Return
		LDA !P2Blocked
		AND #$04 : BEQ .Return
		LDA $6DA7
		AND #$08 : BEQ .Return

		.EnterDoor
		LDA $02 : STA !LevelEntry
		LDA $02+1 : STA !LevelEntry+1
		LDA #$0F : STA !GameMode			; load level
		LDA #$80 : STA !SPC3				; fade music
		LDA #$0F : STA !SPC4				; door sfx

		.Return
		RTL


; input: JSL followed by border exit struct
; output: void
;
; border exit struct:
; 00	16-bit L/U limit
; 02	16-bit R/D limit
; 04	16-bit override value (will be used for !LevelEntry if player triggers exit, which is done from PCE)
;
; note that an exit value of 0xFFFF will go to the overworld without beating the level
; a value of 0xBEA7 will BEAT the level


	BorderExit:
		.Up
		REP #$30
		LDA $01,s
		TAY : INY
		CLC : ADC #$0006
		STA $01,s
		LDA $0000,y : STA !UpExitLimitL
		LDA $0002,y : STA !UpExitLimitR
		LDA $0004,y : STA !UpExitOverride
		SEP #$30
		RTL

		.Left
		REP #$30
		LDA $01,s
		TAY : INY
		CLC : ADC #$0006
		STA $01,s
		LDA $0000,y : STA !LeftExitLimitU
		LDA $0002,y : STA !LeftExitLimitD
		LDA $0004,y : STA !LeftExitOverride
		SEP #$30
		RTL

		.Right
		REP #$30
		LDA $01,s
		TAY : INY
		CLC : ADC #$0006
		STA $01,s
		LDA $0000,y : STA !RightExitLimitU
		LDA $0002,y : STA !RightExitLimitD
		LDA $0004,y : STA !RightExitOverride
		SEP #$30
		RTL

		.Down
		REP #$30
		LDA $01,s
		TAY : INY
		CLC : ADC #$0006
		STA $01,s
		LDA $0000,y : STA !DownExitLimitL
		LDA $0002,y : STA !DownExitLimitR
		LDA $0004,y : STA !DownExitOverride
		SEP #$30
		RTL




;============================
;
; COORDINATE INPUT ROUTINES
;
;============================


; input: JSL, followed by 16-bit coordinate
; output: C = 0 (BCC) means no exit occurred, C = 1 (BCS) means the exit was triggered
; will trigger a door exit if a player is past the coordinate in the specified direction
	EXIT:
		.Right
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		..a
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI +
		CMP !P2XPosLo-$80
		BEQ .GetExitNum_1
		BCC .GetExitNum_1
	+	LDX !P2Status : BNE ..return
		BIT !P2XPosLo : BMI ..return
		CMP !P2XPosLo
		BEQ .GetExitNum_2
		BCC .GetExitNum_2
		..return
		SEP #$30
		CLC
		RTL

		.Left
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		..a
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI .GetExitNum_1
		CMP !P2XPosLo-$80 : BCS .GetExitNum_1
	+	LDX !P2Status : BNE ..return
		BIT !P2XPosLo : BMI .GetExitNum_2
		CMP !P2XPosLo : BCS .GetExitNum_2
		..return
		SEP #$30
		CLC
		RTL

		.GetExitNum
		..1
		LDA !P2X-$80 : STA $94
		LDA !P2Y-$80 : BRA ..go
		..2
		LDA !P2X : STA $94
		LDA !P2Y
		..go
		STA $96
		JSL TranslateOldExitNumber

		.Exit
		SEP #$30
		INC !DoorCounter : BNE +			; +1 door count
		DEC !DoorCounter : +				; stay at 255 instead of wrapping around to 0
		LDA #$0F : STA !GameMode			; load level
		SEC
		RTL

		.Down
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		..a
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI +
		CMP !P2YPosLo-$80
		BEQ .GetExitNum_1
		BCC .GetExitNum_1
	+	LDX !P2Status : BNE ..return
		BIT !P2YPosLo : BMI ..return
		CMP !P2YPosLo
		BEQ .GetExitNum_2
		BCC .GetExitNum_2
		..return
		SEP #$30
		CLC
		RTL

		.Up
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		..a
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI .GetExitNum_1
		CMP !P2YPosLo-$80 : BCS .GetExitNum_1
	+	LDX !P2Status : BNE ..return
		BIT !P2YPosLo : BMI .GetExitNum_2
		CMP !P2YPosLo : BCS .GetExitNum_2
		..return
		SEP #$30
		CLC
		RTL


; input: JSL, followed by 16-bit coordinate
; output: C = 0 (BCC) means no exit occurred, C = 1 (BCS) means the exit was triggered
; same as the normal one, except it fades the music upon exit
	EXIT_FADE:
		.Right
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		JSL EXIT_Right_a
		BRA .Exit

		.Left
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		JSL EXIT_Left_a
		BRA .Exit

		.Down
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		JSL EXIT_Down_a
		BRA .Exit

		.Up
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		JSL EXIT_Up_a

		.Exit
		LDA !GameMode
		CMP #$0F : BNE .Return
		LDA #$80 : STA !SPC3

		.Return
		RTL


; input: JSL, followed by 16-bit coordinate
; output: void
; will trigger a stage clear if a player is past the coordinate in the specified direction
	END:
		.Right
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI +
		CMP !P2XPosLo-$80
		BEQ ..jump
		BCC ..jump
	+	LDX !P2Status : BNE +
		BIT !P2XPosLo : BMI +
		CMP !P2XPosLo
		BEQ ..jump
		BCC ..jump
	+	SEP #$30
		RTL
		..jump
		JMP .End

		.Left
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		LDX !P2Status-$80 : BNE +
		BIT !P2XPosLo-$80 : BMI .End
		CMP !P2XPosLo-$80 : BCS .End
	+	LDX !P2Status : BNE +
		BIT !P2XPosLo : BMI .End
		CMP !P2XPosLo : BCS .End
	+	SEP #$30
		RTL

		.Down
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
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
	+	SEP #$30
		RTL

		.Up
		REP #$30
		LDA $01,s
		INC A : TAY
		INC A : STA $01,s
		LDA $0000,y
		LDX !P2Status-$80 : BNE +
		BIT !P2YPosLo-$80 : BMI .End
		CMP !P2YPosLo-$80 : BCS .End
	+	LDX !P2Status : BNE +
		BIT !P2YPosLo : BMI .End
		CMP !P2YPosLo : BCS .End
	+	SEP #$30
		RTL


		.End
		JML BeatLevel




