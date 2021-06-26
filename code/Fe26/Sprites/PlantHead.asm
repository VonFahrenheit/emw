PlantHead:

	namespace PlantHead

		!PlantHeadRotation	= $BE,x		; target angle, anim index is currently displayed angle
		!PlantHeadState		= $3280,x	; 0 = closed mouth, 1 = open mouth, 2 = shrink a bit, 3 = shrink a lot
		!PlantHeadMouth		= $3290,x	; timer for how long to hold mouth open
		!PlantHeadClosestPlayer	= $32B0,x
		!PlantHeadPulse		= $32D0,x	; timer for how long to display pulse animation
		!PlantHeadMode		= $3310,x	; 00 = up, 06 = left, 0C = right, 12 = down, FF = all range mode

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
		JSL !GetMap16Sprite
		SEP #$20
		LDY $03
		LDA $04
		CMP !VineDestroyPage
		BEQ .GetMode
		JMP .AllRangeMode

		.Vert
		REP #$30
		LDA #$0000
		LDY #$FFF0
		JSL !GetMap16Sprite
		SEP #$20
		LDA $03
		BPL .Up
		LDA $04
		CMP !VineDestroyPage
		BNE .Up

		.Down
		LDA #$12 : JMP .EndInit

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
		JSL !GetMap16Sprite
		SEP #$20
		LDA $03
		BPL .Left
		LDA $04
		CMP !VineDestroyPage
		BNE .Left

		.Right
		LDA #$0C
		BRA .EndInit

		.Left
		LDA #$06

		.EndInit
		STA !PlantHeadMode
		+

		LDA #$03 : JSL !GetDynamicTile
		BCC .Erase
		TYA
		ORA #$40
		STA !ClaimedGFX
		TXA
		STA !DynamicTile+0,y
		STA !DynamicTile+1,y
		STA !DynamicTile+2,y
		STA !DynamicTile+3,y
		BRA .Return

		.Erase
		STZ $3230,x

		.Return
		PLB
		RTL



	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN
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



; limit format:
; - left tilt limit
; - right tilt limit
; - up tilt limit
; - down tilt limit
; - min angle
; - max angle

		.Limit
		.UpLimit
		db $10-$0B,$10+$0B,$10-$10,$10-$0B
		db $0E,$12
		.LeftLimit
		db $10-$10,$10-$0B,$10-$0B,$10+$0B
		db $0A,$0E
		.RightLimit
		db $10+$0B,$10+$10,$10-$0B,$10+$0B
		db $02,$06
		.DownLimit
		db $10-$0B,$10+$0B,$10+$0B,$10+$10
		db $06,$0A



		.Pulse
		db $02,$03,$03,$02


		.Quadrant
		db $07,$00,$08,$04
		db $FF,$FF,$FF,$04
		db $07,$00,$00,$03


		.UpDown
		db $00,$06

		.LeftRight
		db $03,$09

		.22
		db $01,$0F,$05,$0B	; indexed by Yflag*2 + Xflag

		.45
		db $02,$0E,$06,$0A	; indexed by Yflag*2 + Xflag

		.68
		db $03,$0D,$07,$09	; indexed by Yflag*2 + Xflag



	PHYSICS:

		LDA !PlantHeadMouth
		BEQ $03 : DEC !PlantHeadMouth

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
	-	LDA !P2Hitbox1+4-$80,y : BEQ .Next	; |
		STA $02					; |
		LDA !P2Hitbox1+0-$80,y			; |
		STA $00					; |
		XBA : STA $08				; |
		LDA !P2Hitbox1+2-$80,y			; | Any attack kills the plant head
		SEP #$20				; |
		STA $01					; |
		XBA : STA $09				; |
		JSL !CheckContact : BCS .Kill		; |
	.Next	CPY #$80 : BEQ +			; |
		LDY #$80 : BRA -			; |
	+	SEP #$20				;/

		JSL FireballContact
		BCC .NoFireball
		LDA #$0F : STA !Ex_Data2,y			;\ Destroy fireball
		LDA #$01+!ExtendedOffset : STA !Ex_Num,y	;/
	.Kill	JSR DestroyPlant
		BRA ++
		.NoFireball

		PHX
		LDX #$01				; smaller hurtbox
	-	LDA $04,x
		CLC : ADC #$03
		STA $04,x
		LDA $0A,x
		ADC #$00
		STA $0A,x
		LDA #$0E : STA $06,x
		DEX : BPL -
		PLX

		SEC : JSL !PlayerClipping		; interact with players
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


;
; rotation key:
;	- 00	straight up
;	- 01	1/16 clockwise
;	- 02	2/16 clockwise
;	- 03	3/16 clockwise
;	- 04	straight right
;	- 05	5/16 clockwise
;	- 06	6/16 clockwise
;	- 07	7/16 clockwise
;	- 08	straight down
;	- 09	9/16 clockwise
;	- 0A	10/16 clockwise
;	- 0B	11/16 clockwise
;	- 0C	straight left
;	- 0D	13/16 clockwise
;	- 0E	14/16 clockwise
;	- 0F	15/16 clockwise
;



	GRAPHICS:

		STZ !PlantHeadState
		LDA !PlantHeadMouth : BEQ .Closed
		INC !PlantHeadState
		.Closed
		LDA !PlantHeadPulse : BEQ .NoPulse
		LSR #2
		AND #$03
		TAY
		LDA DATA_Pulse,y : STA !PlantHeadState
		.NoPulse


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
		STA !BigRAM+$40			; |
		BPL +				; |
		EOR #$FFFF : INC A		; | Calculate dividend
		INC $01				;/
	+	STA $2251			; > Dividend = |DY|
		LDA $02				;\
		SEC : SBC !P2XPosLo-$80,y	; |
		STA !BigRAM+$42			; |
		BPL +				; | Calculate divisor
		EOR #$FFFF : INC A		; |
		INC $00				;/
	+	STA $2253			; > Divisor = |DX|

		JSR CheckAngle			; > Analyze |DY|/|DX|


		PHX
		LDA $01
		ASL A
		ORA $00
		TAX
		TYA
		CMP DATA_Quadrant+4,x : BEQ +
		CLC : ADC DATA_Quadrant,x
		EOR DATA_Quadrant+8,x
	+	PLX
		LDY !PlantHeadMode : BMI +
		BNE ++
		CMP #$08 : BCS ++
		ORA #$10
	++	CMP DATA_Limit+4,y : BCS ++
		LDA DATA_Limit+4,y : BRA +
	++	CMP DATA_Limit+5,y : BCC +
		LDA DATA_Limit+5,y
	+	AND #$0F
		STA !SpriteAnimIndex



	LDA !PlantHeadState : STA $02
	STZ $03

	REP #$20
	LDA.w #!BigRAM : STA $0C
	LDA #$001C : STA !BigRAM+$00	; header
	LDA #$0080			; upload size
	STA !BigRAM+$02
	STA !BigRAM+$09
	STA !BigRAM+$10
	STA !BigRAM+$17
	LDA !SpriteAnimIndex
	AND #$00FF
	ASL #2
	ORA $02
	ASL A
	TAY
	LDA ANIM,y
	STA !BigRAM+$04
	CLC : ADC #$0080
	STA !BigRAM+$0B
	CLC : ADC #$0080
	STA !BigRAM+$12
	CLC : ADC #$0080
	STA !BigRAM+$19
	LDA #$6000 : STA !BigRAM+$07
	LDA #$6100 : STA !BigRAM+$0E
	LDA #$6040 : STA !BigRAM+$15
	LDA #$6140 : STA !BigRAM+$1C
	SEP #$20
	LDA #$41
	STA !BigRAM+$06
	STA !BigRAM+$0D
	STA !BigRAM+$14
	STA !BigRAM+$1B
	JSL !UpdateClaimedGFX


		.GetTilemap

	LDA #$01 : STA $3320,x

		REP #$20
		LDA !BigRAM+$42 : STA $0C
		LDA !BigRAM+$40 : STA $0E
		SEP #$20
		LDA #$10 : JSR LimitCircle

		LDY !PlantHeadMode : BMI .DrawPlant
		LDA $00
		CLC : ADC #$10
		CMP DATA_Limit+0,y : BCS +
		LDA DATA_Limit+0,y : BRA ++
	+	CMP DATA_Limit+1,y : BCC ++
		LDA DATA_Limit+1,y
	++	SEC : SBC #$10
		STA $00
		LDA $01
		CLC : ADC #$10
		CMP DATA_Limit+2,y : BCS +
		LDA DATA_Limit+2,y : BRA ++
	+	CMP DATA_Limit+3,y : BCC ++
		LDA DATA_Limit+3,y
	++	SEC : SBC #$10
		STA $01

		.DrawPlant
		STZ $02
		STZ $03
		STZ $06
		REP #$20
		LDA.w #.TM : STA $04
		JSL LakituLovers_TilemapToRAM_Long
		LDA.w #!BigRAM : STA $04
		SEP #$20
		JSL LOAD_DYNAMIC



		PLB
		RTL


	.TM
	dw $0010
	db $30,$F8,$F8,$00
	db $30,$08,$F8,$02
	db $30,$F8,$08,$04
	db $30,$08,$08,$06






	ANIM:
		dw $0000,$0200,$4000,$6000		; 00
		dw $0400,$2200,$4200,$6200		; 01
		dw $0600,$2400,$4400,$6400		; 02
		dw $0800,$2600,$4600,$6600		; 03
		dw $0A00,$2800,$4800,$6800		; 04
		dw $0C00,$2A00,$4A00,$6A00		; 05
		dw $0E00,$2C00,$4C00,$6C00		; 06
		dw $1000,$2E00,$4E00,$6E00		; 07
		dw $1200,$3000,$5000,$7000		; 08
		dw $1400,$3200,$5200,$7200		; 09
		dw $1600,$3400,$5400,$7400		; 0A
		dw $1800,$3600,$5600,$7600		; 0B
		dw $1A00,$3800,$5800,$7800		; 0C
		dw $1C00,$3A00,$5A00,$7A00		; 0D
		dw $1E00,$3C00,$5C00,$7C00		; 0E
		dw $2000,$3E00,$5E00,$7E00		; 0F

		.Y
		db $F0			; table extension for Y disp (offset by -90 degrees, of course!)
		db $F2
		db $F5
		db $FA
		.X
		db $00			; 00
		db $06			; 01
		db $0B			; 02
		db $0E			; 03
		db $10			; 04
		db $0E			; 05
		db $0B			; 06
		db $06			; 07
		db $00			; 08
		db $FA			; 09
		db $F5			; 0A
		db $F2			; 0B
		db $F0			; 0C
		db $F2			; 0D
		db $F5			; 0E
		db $FA			; 0F





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

; possible angles (quadrant 1)
;	- 00
;	- 22.5
;	- 45
;	- 67.5
;	- 90


; cutoff angles:
;	- 11.25
;	- 33.75
;	- 56.5
;	- 78.75



		CMP #$0507 : BCS .0
		CMP #$0183 : BCS .1
		CMP #$00AB : BCS .2
		CMP #$0033 : BCS .3
	.4	INY
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
		LDA #$1F : STA $32D0,x
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
		LDA #$0F : STA !PlantHeadMouth

		LDA #$02 : STA $00		; > Spawn 3 spores
		LDY.b #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ .Spawn
	--	DEY : BPL -
		RTS

		.Spawn
		LDA #$0C+!ExtendedOffset : STA !Ex_Num,y
		LDA $3210,x : STA !Ex_YLo,y
		LDA $3220,x : STA !Ex_XLo,y
		LDA $3240,x : STA !Ex_YHi,y
		LDA $3250,x : STA !Ex_XHi,y
		LDX $01
		LDA .SpeedY,x : STA !Ex_YSpeed,y
		LDA .SpeedX,x : STA !Ex_XSpeed,y
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

; input:
;	A: radius of circle
;	$0C: DX
;	$0E: DY
;
	LimitCircle:
		STA $0A
		STZ $2250
		REP #$20
		LDA $0E
		BPL $04 : EOR #$FFFF : INC A
		STA $2251
		STA $2253
		NOP : BRA $00
		LDA $2306 : STA $00
		LDA $0C
		BPL $04 : EOR #$FFFF : INC A
		STA $2251
		STA $2253
		NOP
		LDA $00
		CLC : ADC $2306
		JSL !GetRoot
		AND #$FF00
		XBA : STA $04
		LDY #$01 : STY $2250
		LDA $0A-1
		AND #$FF00
		STA $2251
		LDA $04 : STA $2253
		NOP : BRA $00
		LDA $2306
		LDY #$00 : STY $2250
		STA $2251
		LDA $0E : STA $2253
		NOP : BRA $00
		LDA $2307
		AND #$00FF
		EOR #$00FF : INC A
		STA $01
		LDY #$01 : STY $2250
		LDA $0A-1
		AND #$FF00
		STA $2251
		LDA $04 : STA $2253
		NOP : BRA $00
		LDA $2306
		LDY #$00 : STY $2250
		STA $2251
		LDA $0C : STA $2253
		NOP : BRA $00
		LDA $2307
		AND #$00FF
		EOR #$00FF : INC A
		SEP #$20
		STA $00
		RTS

	.Long
		JSR LimitCircle
		RTL


	namespace off








