PlantHead:

	namespace PlantHead

		!PlantHeadRotation	= $BE,x
		!PlantHeadClosestPlayer	= $32B0,x
		!PlantHeadTimer		= $32D0,x
		!PlantHeadMode		= $3310,x

		!PlantHeadHP		= $32A0,x
		!PlantHeadInvinc	= $35D0,x


	INIT:
		PHB : PHK : PLB
		LDA !GFX_status+$06 : STA !ClaimedGFX

		LDA !ExtraBits,x
		AND #$04 : BEQ .NoAlt
		LDA !Difficulty
		AND #$03
		INC A
		STA !PlantHeadHP		; alt HP depends on difficulty
		.NoAlt


		REP #$30
		LDA #$0000
		LDY #$0000
		JSL $138008
		LDA [$05]
		TAY
		INC $07
		LDA [$05]
		CMP !VineDestroyPage
		BEQ .GetMode
		JMP .AllRangeMode

		.Vert
		REP #$30
		LDA #$0000
		LDY #$FFF0
		JSL $138008
		LDA [$05]
		BPL .Up
		INC $07
		LDA [$05]
		CMP !VineDestroyPage
		BNE .Up

		.Down
		LDA #$06 : JMP .EndInit

		.Up
		LDA #$00 : JMP .EndInit

		.GetMode
		CPY.b #!VineDestroyHorzTile1 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile2 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile3 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile4 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile5 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile6 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile7 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile8 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile9 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile10 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile11 : BEQ .Horz
		CPY.b #!VineDestroyHorzTile12 : BEQ .Horz
		CPY.b #!VineDestroyVertTile1 : BEQ .Vert
		CPY.b #!VineDestroyVertTile2 : BEQ .Vert
		CPY.b #!VineDestroyVertTile3 : BEQ .Vert
		CPY.b #!VineDestroyVertTile4 : BEQ .Vert
		CPY.b #!VineDestroyVertTile5 : BEQ .Vert
		CPY.b #!VineDestroyVertTile6 : BEQ .Vert
		CPY.b #!VineDestroyVertTile7 : BEQ .Vert
		CPY.b #!VineDestroyVertTile8 : BEQ .Vert
		CPY.b #!VineDestroyVertTile9 : BEQ .Vert
		CPY.b #!VineDestroyVertTile10 : BEQ .Vert
		CPY.b #!VineDestroyVertTile11 : BEQ .Vert
		CPY.b #!VineDestroyVertTile12 : BNE $03 : JMP .Vert

		.AllRangeMode
		LDA #$FF : STA !PlantHeadMode
		BRA +

		.Horz
		REP #$30
		LDA #$FFF0
		LDY #$0000
		JSL $138008
		LDA [$05]
		BPL .Left
		INC $07
		LDA [$05]
		CMP !VineDestroyPage
		BNE .Left

		.Right
		LDA #$09
		BRA .EndInit

		.Left
		LDA #$01 : STA $3320,x
		LDA #$03

		.EndInit
		STA !PlantHeadMode
		+

		PLB


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN_Long
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS

	DATA:
		.Test
		db $FF,$01


		.Vine
		db $02,$00,$00		; Left column is vine destroy direction indexed by !PlantHeadMode (0, 3, 6, 9)
		db $00,$00,$00		; Middle column is base X offset indexed by !PlantHeadMode
		db $03,$00,$00		; Right column is base Y offset indexed by !PlantHeadMode
		db $01,$00,$00		;

.HitBoxOffsetX	db $00,$F8,$F2		; Same table but with a 90 degree displacement
.HitBoxOffsetY	db $F0,$F2,$F8		; Thaaaaaat's trigonometry!
		db $00,$08,$0E
		db $10,$0E,$08
		db $00,$F8,$F2

.HitBoxHiX	db $00,$FF,$FF
.HitBoxHiY	db $FF,$FF,$FF
		db $00,$00,$00
		db $00,$00,$00
		db $00,$FF,$FF


		.UpAllow
		db $00,$01,$02
		db $02,$02,$02
		db $00,$0A,$0A
		db $0A,$0A,$0B

		.LeftAllow
		db $01,$01,$02
		db $03,$04,$05
		db $05,$05,$05
		db $03,$01,$01

		.DownAllow
		db $06,$04,$04
		db $04,$04,$05
		db $06,$07,$08
		db $08,$08,$08

		.RightAllow
		db $0B,$0B,$0B
		db $09,$07,$07
		db $07,$07,$08
		db $09,$0A,$0B



		.UpDown
		db $00,$06

		.LeftRight
		db $03,$09

		.30
		db $01,$0B,$05,$07	; indexed by Yflag*2 + Xflag

		.60
		db $02,$0A,$04,$08	; indexed by Yflag*2 + Xflag



	PHYSICS:

		LDA !PlantHeadInvinc
		BEQ $03 : DEC !PlantHeadInvinc

		LDA $14
		AND #$7F : BNE +			;\
		LDA !ExtraBits,x			; |
		AND #$04 : BEQ +			; | Attack every 128 frames if extra bit is set
	;	LDA !PlantHeadMode : BMI +		; | (but not in all-range mode)
		JSR Attack				; |
		+					;/


	INTERACTION:

		LDA $3220,x : STA $00			; Figure out which player is closest based on DX + DY
		LDA $3250,x : STA $01			; (because division and roots are too much)
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		REP #$20
		LDA !P2XPosLo-$80
		SEC : SBC $00
		BPL $03 : EOR #$FFFF
		STA $04
		LDA !P2YPosLo-$80
		SEC : SBC $02
		BPL $03 : EOR #$FFFF
		CLC : ADC $04
		STA $04
		LDA !P2XPosLo
		SEC : SBC $00
		BPL $03 : EOR #$FFFF
		STA $00
		LDA !P2YPosLo
		SEC : SBC $02
		BPL $03 : EOR #$FFFF
		CLC : ADC $00
		CMP $04
		SEP #$20
		BCS .P1Closest

		.P2Closest
		LDA #$80
		BRA .Close

		.P1Closest
		LDA #$00
	.Close	STA !PlantHeadClosestPlayer


		LDY !PlantHeadRotation
		LDA $3220,x
		CLC : ADC DATA_HitBoxOffsetX,y
		STA $04
		LDA $3250,x
		ADC DATA_HitBoxHiX,y
		STA $0A
		LDA $3210,x
		CLC : ADC DATA_HitBoxOffsetY,y
		STA $05
		LDA $3240,x
		ADC DATA_HitBoxHiY,y
		STA $0B
		LDA #$14
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC ++
		PHA
		JSL !HurtPlayers
		PLA
		LSR A : BCC +
		PHA
		LDA #$01 : STA !P2SenkuSmash-$80
		PLA
		LSR A : BCC ++
	+	LDA #$01 : STA !P2SenkuSmash
	++

		LDY #$0F				;\
	-	LDA $3230,y				; |
		CMP #$09 : BCC .No			; |
		CMP #$0B : BCS .No			; |
		PHX					; |
		TYX					; | Plant can be killed by thrown objects
		JSL !GetSpriteClipping00		; |
		PLX					; |
		JSL !CheckContact : BCS .Kill		; |
	.No	DEY : BPL -				;/



		LDY #$00				;\
		REP #$20				; |
	-	LDA !P2Hitbox+4-$80,y : BEQ .Next	; |
		STA $02					; |
		LDA !P2Hitbox+0-$80,y			; |
		STA $00					; |
		XBA : STA $08				; |
		LDA !P2Hitbox+2-$80,y			; | Any attack kills the plant head
		SEP #$20				; |
		STA $01					; |
		XBA : STA $09				; |
		JSL !CheckContact : BCS .Kill		; |
	.Next	CPY #$80 : BEQ +			; |
		LDY #$80 : BRA -			; |
	+	SEP #$20				;/

		JSL FireballContact_Long
		BCC .NoFireball
		LDA #$0F : STA $776F+$08,y		;\ Destroy fireball
		LDA #$01 : STA $770B+$08,y		;/
	.Kill	JSR DestroyPlant
		.NoFireball


	GRAPHICS:

		.HandleSpin
		LDA !PlantHeadTimer : BEQ .Normal
		CMP #$01 : BNE .Lock
		LDA !PlantHeadRotation
		STA !SpriteAnimIndex
	.Lock	JMP .NoMove


		.Normal
		LDY !PlantHeadClosestPlayer	; Y = index
		LDA #$01 : STA $2250		; Enable division
		LDA $3220,x : STA $02
		LDA $3250,x : STA $03
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		STZ $00				; > $00 and $01 determine if DX and DY are positive or negative
		SEC : SBC !P2YPosLo-$80,y	;\
		BPL +				; |
		EOR #$FFFF : INC A		; | Calculate dividend
		INC $01				; |
	+	CMP #$0100 : BCC .Ok		;/
	.NotOk	SEP #$20			;\ Enforce sight limit
		JMP .GetTilemap			;/

	.Ok	STA $2251			; > Dividend = |DY|
		LDA $02				;\
		SEC : SBC !P2XPosLo-$80,y	; |
		BPL +				; | Calculate divisor
		EOR #$FFFF : INC A		; |
		INC $00				; |
	+	CMP #$0100 : BCS .NotOk		;/
		STA $2253			; > Divisor = |DX|

		JSR CheckAngle			; > Analyze |DY|/|DX|

		CPY #$00 : BEQ .UpDown
		CPY #$01 : BEQ .30
		CPY #$02 : BEQ .60

		.LeftRight
		LDY $00
		LDA DATA_LeftRight,y
		BRA .CompareSpin

		.UpDown
		LDY $01
		LDA DATA_UpDown,y
		BRA .CompareSpin

		.30
		LDA $01
		ASL A
		ORA $00
		TAY
		LDA DATA_30,y
		BRA .CompareSpin

		.60
		LDA $01
		ASL A
		ORA $00
		TAY
		LDA DATA_60,y

		.CompareSpin
		STA $00
		TAY
		LDA !PlantHeadMode : BMI .AllRange
		CMP #$09 : BEQ .Right
		CMP #$06 : BEQ .Down
		CMP #$03 : BEQ .Left
	.Up	LDA DATA_UpAllow,y
		BRA +
	.Left	LDA DATA_LeftAllow,y
		BRA +
	.Down	LDA DATA_DownAllow,y
		BRA +
	.Right	LDA DATA_RightAllow,y
	+	STA !PlantHeadRotation

		BRA .GetTilemap

		.AllRange
		LDA $00
		STZ $3320,x
		STA !PlantHeadRotation
		CMP #$07
		BCS .GetTilemap
		LDA #$01 : STA $3320,x
		BRA .GetTilemap


		.GetTilemap
		LDA $14				;\ Only tilt every 8 frames
		AND #$07 : BNE .NoMove		;/
		LDA !PlantHeadRotation		;\
		SEC : SBC !SpriteAnimIndex	; | If it's already at the right place, don't do anything
		BEQ .NoMove			;/
		BPL $03 : CLC : ADC #$0C	;\ Wrap 00-0B
		CMP #$07 : BCC +		;/
		DEC !SpriteAnimIndex		;\
		BRA ++				; | Rotate 1 step
	+	INC !SpriteAnimIndex		;/
	++	LDA !SpriteAnimIndex		;\
		CMP #$FF : BNE +		; |
		LDA #$0B : BRA .Control		; | Control overflow
	+	CMP #$0C : BNE .NoMove		; |
		LDA #$00			;/

		.Control
		STA !SpriteAnimIndex		; > Store

		.NoMove
		LDA #$01 : STA $3320,x		;\
		LDA !SpriteAnimIndex		; | Figure out facing
		CMP #$07			; |
		BCC $03 : STZ $3320,x		;/
		ASL A
		TAY
		LDA ANIM,y : STA $04
		LDA ANIM+1,y : STA $05

		LDA !ExtraBits,x		;\
		AND #$04			; | Extra bit determines palette
		EOR #$04			; |
		STA $00				;/

		LDA !PlantHeadInvinc
		AND #$02 : STA $0C
		LDA !PlantHeadMode : BPL +
		LDA !PlantHeadRotation		;\
		CMP #$09 : BCC ++		; |
		LDA #$09 : BRA +		; |
	++	CMP #$06 : BCC ++		; | Figure out index for all-range mode
		LDA #$06 : BRA +		; |
	++	CMP #$03 : BCC ++		; |
		LDA #$03 : BRA +		; |
	++	LDA #$00			;/
	+	TAX				; X = some index
		REP #$20
		LDA ($04) : TAY
		STA !BigRAM
		INC $04
		INC $04
		DEY
		SEP #$20
	-	LDA ($04),y : STA !BigRAM+2,y	; > Tile number
		DEY				;\
		LDA ($04),y			; | Y position
		CLC : ADC DATA_Vine+2,x		; |
		STA !BigRAM+2,y			;/
		DEY				;\
		LDA ($04),y			; | X position
		CLC : ADC DATA_Vine+1,x		; |
		STA !BigRAM+2,y			;/
		DEY				;\
		LDA ($04),y			; | Property (depends on extra bit)
		CLC : ADC $00			; |
		EOR $0C				; > Add invinc flash
		STA !BigRAM+2,y			;/
		DEY				;\ Loop
		BPL -				;/

		LDX !SpriteIndex		; > X = sprite index
		LDA.b #!BigRAM : STA $04	;\ Actual tilemap pointer
		LDA.b #!BigRAM>>8 : STA $05	;/

		JSL LOAD_PSUEDO_DYNAMIC_Long

		.Return
		PLB
		RTL


	ANIM:

		dw .UpTM		; 0
		dw .30DegreeTM		; 1
		dw .60DegreeTM		; 2
		dw .SideTM		; 3
		dw .TM4			; 4
		dw .TM5			; 5
		dw .TM6			; 6
		dw .TM5			; 7
		dw .TM4			; 8
		dw .SideTM		; 9
		dw .60DegreeTM		; A
		dw .30DegreeTM		; B
		dw .UpOpenTM		; C
		dw .SideOpenTM		; D
		dw .DownOpenTM		; E



	.SideTM
		dw $0010
		db $35,$F8-$08,$F6+$00,$40
		db $35,$08-$08,$F6+$00,$42
		db $35,$F8-$08,$06+$00,$44
		db $35,$08-$08,$06+$00,$46
	.SideOpenTM
		dw $0010
		db $35,$F8-$10,$F8+$00,$48
		db $35,$08-$10,$F8+$00,$4A
		db $35,$F8-$10,$08+$00,$4C
		db $35,$08-$10,$08+$00,$4E
	.UpTM
		dw $0010
		db $35,$F8+$00,$F8-$08,$00
		db $35,$08+$00,$F8-$08,$02
		db $35,$F8+$00,$08-$08,$20
		db $35,$08+$00,$08-$08,$22
	.UpOpenTM
		dw $0010
		db $35,$F8+$00,$F8-$08,$04
		db $35,$08+$00,$F8-$08,$06
		db $35,$F8+$00,$08-$08,$24
		db $35,$08+$00,$08-$08,$26
	.30DegreeTM
		dw $0010
		db $35,$F8-$04,$F8-$07,$08
		db $35,$08-$04,$F8-$07,$0A
		db $35,$F8-$04,$08-$07,$28
		db $35,$08-$04,$08-$07,$2A
	.60DegreeTM
		dw $0010
		db $35,$F8-$07,$F8-$04,$0C
		db $35,$08-$07,$F8-$04,$0E
		db $35,$F8-$07,$08-$04,$2C
		db $35,$08-$07,$08-$04,$2E
	.TM4
		dw $0010
		db $B5,$F8-$07,$08+$04,$0C
		db $B5,$08-$07,$08+$04,$0E
		db $B5,$F8-$07,$F8+$04,$2C
		db $B5,$08-$07,$F8+$04,$2E
	.TM5
		dw $0010
		db $B5,$F8-$04,$08+$07,$08
		db $B5,$08-$04,$08+$07,$0A
		db $B5,$F8-$04,$F8+$07,$28
		db $B5,$08-$04,$F8+$07,$2A
	.TM6
		dw $0010
		db $B5,$F8+$00,$08+$08,$00
		db $B5,$08+$00,$08+$08,$02
		db $B5,$F8+$00,$F8+$08,$20
		db $B5,$08+$00,$F8+$08,$22
	.DownOpenTM
		dw $0010
		db $B5,$F8+$00,$08+$08,$04
		db $B5,$08+$00,$08+$08,$06
		db $B5,$F8+$00,$F8+$08,$24
		db $B5,$08+$00,$F8+$08,$26



	CheckAngle:
		CMP #$0000 : BNE .NotInfinity
		LDY #$00
		BRA .0

		.NotInfinity
		PHA
		LDA $2306
		AND #$00FF
		XBA
		STA $04
		LDA $2308
		XBA
		AND #$FF00
		STA $2251
		PLA : STA $2253
		NOP
		LDY #$00
		LSR A
		CMP $2308
		LDA $2306
		BCS $01 : INC A
		AND #$00FF
		ORA $04

		CMP #$03BB : BCS .0
		CMP #$0100 : BCS .1
		CMP #$0045 : BCS .2
	.3	INY				; Vastly dominant X (75 < A)
	.2	INY				; Somewhat dominant X (45 < A < 75)
	.1	INY				; Somewhat dominant Y (15 < A < 45)
	.0	SEP #$20			; Vastly dominant Y (A < 15)
		RTS


	DestroyPlant:
		LDA !PlantHeadInvinc : BNE .Fail
		LDA #$28 : STA !SPC4
		LDA !PlantHeadHP : BEQ .Kill
		DEC !PlantHeadHP
		LDA #$80 : STA !PlantHeadInvinc
	.Fail	RTS

		.Kill
		LDA #$04 : STA $3230,x
		LDA #$1F : STA !PlantHeadTimer
		TXY
		LDX #$03
	-	LDA !VineDestroyXHi,x
		CMP #$FF : BEQ .FoundSlot
		DEX : BPL -
		BRA .End

		.FoundSlot
		LDA $3220,y : AND #$F0 : STA !VineDestroyXLo,x
		LDA $3250,y : STA !VineDestroyXHi,x
		LDA $3210,y : AND #$F0 : STA !VineDestroyYLo,x
		LDA $3240,y : STA !VineDestroyYHi,x
		LDA $3310,y
		TAY
		LDA.w DATA_Vine,y
		STA !VineDestroyDirection,x
		LDA !VineDestroyBaseTime : STA !VineDestroyTimer,x

		.End
		LDX !SpriteIndex
		RTS


	Attack:
		LDA !PlantHeadMode
		BPL $02 : LDA #$00
		STA $01				; mode (all-range counts as up)
		LDY #$0C
		LDA !PlantHeadMode : BMI .Yes

	.Angle	CMP #$0B : BEQ .Yes
		CMP #$02 : BCC .Yes
		INY
		CMP #$05 : BCC .Yes
		INY
		CMP #$08 : BCC .Yes
		DEY
	.Yes	TYA : STA !SpriteAnimIndex
		LDA #$0F : STA !PlantHeadTimer

		LDA #$02 : STA $00		; > Spawn 3 spores
		LDY #$07
	-	LDA $770B,y : BEQ .Spawn
	--	DEY
		BPL -
		RTS

		.Spawn
		LDA #$0C : STA $770B,y
		LDA $3210,x : STA $7715,y
		LDA $3220,x : STA $771F,y
		LDA $3240,x : STA $7729,y
		LDA $3250,x : STA $7733,y
		LDX $01
		LDA .SpeedY,x : STA $773D,y
		LDA .SpeedX,x : STA $7747,y
		LDX !SpriteIndex
		INC $01
		DEC $00 : BPL --
		RTS


		.SpeedY
		db $E8,$E8,$E8
		db $F0,$F8,$F4
		db $00,$00,$00
		db $F4,$F8,$F0

		.SpeedX
		db $08,$00,$F8
		db $F0,$E0,$F0
		db $F0,$00,$10
		db $10,$20,$10

	namespace off





