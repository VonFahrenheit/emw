
PlantHead:

	namespace PlantHead

		!PlantHeadRotation	= $BE		; target angle, anim index is currently displayed angle
		!PlantHeadState		= $3280		; 0 = closed mouth, 1 = open mouth, 2 = shrink a bit, 3 = shrink a lot
		!PlantHeadMouth		= $3290		; timer for how long to hold mouth open
		!PlantHeadClosestPlayer	= $32B0
		!PlantHeadPulse		= $32D0		; timer for how long to display pulse animation
		!PlantHeadMode		= $3310		; 00 = up, 06 = left, 0C = right, 12 = down, FF = all range mode

		!PlantHeadHP		= $32A0
		!PlantHeadInvinc	= $35D0



; changes:
;	,x on all regs
;	target closest player
;	rotation + target rotation (separate regs)
;	mouth + size = normal sprite anim
;	merge VineDestroy code into plant head





	INIT:
		PHB : PHK : PLB

		LDA !ExtraBits,x
		AND #$04 : BEQ .NoAlt
		LDA !Difficulty
		INC A : STA !PlantHeadHP,x		; alt HP depends on difficulty
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
		LDA #$FF : STA !PlantHeadMode,x
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
		STA !PlantHeadMode,x
		+

		LDA #$03 : JSL GET_SQUARE : BCC .Return
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



	PHYSICS:
		%decreg(!PlantHeadMouth)
		%decreg(!PlantHeadInvinc)




	INTERACTION:

		STZ $2250					; prepare multiplication

		LDA !SpriteXLo,x : STA $00			;\
		LDA !SpriteXHi,x : STA $01			; | get sprite coords
		LDA !SpriteYLo,x : STA $02			; |
		LDA !SpriteYHi,x : STA $03			;/
		REP #$20					;\
		LDA !P2XPosLo-$80				; |
		SEC : SBC $00					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $2251					; |
		STA $2253					; |
		LDA !P2YPosLo-$80				; | calculate |DX|^2 and |DY|^2 for player 1
		SEC : SBC $02					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $06						; |
		LDA $2306 : STA $04				; |
		LDA $06						; |
		STA $2251					; |
		STA $2253					;/
		NOP						;\
		LDA $04						; | calculate sqrt(|DX|^2 + |DY|^2)
		CLC : ADC $2306					; |
		JSL !GetRoot : STA $0C				;/
		REP #$20					;\
		LDA !P2XPosLo					; |
		SEC : SBC $00					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $2251					; |
		STA $2253					; |
		LDA !P2YPosLo					; | calculate |DX|^2 and |DY|^2 for player 2
		SEC : SBC $02					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $06						; |
		LDA $2306 : STA $04				; |
		LDA $06						; |
		STA $2251					; |
		STA $2253					;/
		NOP						;\
		LDA $04						; | calculate sqrt(|DX|^2 + |DY|^2)
		CLC : ADC $2306					; |
		JSL !GetRoot					;/

		CMP $0C						;\
		SEP #$20					; |
		BCC .P2Closest					; |
		.P1Closest					; | closest player
		LDA #$00 : BRA +				; |
		.P2Closest					; |
		LDA #$80					; |
	+	STA !PlantHeadClosestPlayer,x			;/




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
		JSR CheckAngle				; > calculate and analyze |DY|/|DX|

		; ???????
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




; dynamo format:
;	header (16-bit)
;	for each tile: address offset


		.GenerateDynamo
		REP #$20
		LDA #$000A : STA !BigRAM+$00				; 10 bytes
		LDA.w #!SD_PlantHead_offset|$E000 : STA !BigRAM+$02	; super-dynamic file
		LDA !PlantHeadRotation,x
		AND #$00FF
		ASL A : TAY
		LDA ANIM_RotationOffset,y : STA !BigRAM+$04
		CLC : ADC #$0080
		STA !BigRAM+$06
		CLC : ADC #$0800-$0080
		STA !BigRAM+$08
		CLC : ADC #$0080
		STA !BigRAM+$0A



		LDA.w #!BigRAM : STA $0C
		SEP #$20
		JSL LOAD_SQUARE_DYNAMO_Main				; load






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



		.RotationOffset
		dw $0000,$0080,$0100,$0180
		dw $0800,$0880,$0900,$0980
		dw $1000,$1080,$1100,$1180
		dw $1800,$1880,$1900,$1980





	CheckAngle:
		LDY !PlantHeadClosestPlayer,x		; Y = index
		LDA #$01 : STA $2250			; prepare division
		LDA !SpriteXLo,x : STA $02
		LDA !SpriteXHi,x : STA $03
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		STZ $00					; > $00 and $01 determine if DX and DY are positive or negative
		SEC : SBC !P2YPosLo-$80,y		;\
		STA !BigRAM+$40				; |
		BPL +					; |
		EOR #$FFFF : INC A			; | calculate dividend
		INC $01					;/
	+	STA $2251				; > dividend = |DY|
		LDA $02					;\
		SEC : SBC !P2XPosLo-$80,y		; |
		STA !BigRAM+$42				; |
		BPL +					; | calculate divisor
		EOR #$FFFF : INC A			; |
		INC $00					;/
	+	STA $2253				; > divisor = |DX|

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
		LDA !SpriteYLo,x : STA !Ex_YLo,y
		LDA !SpriteXLo,x : STA !Ex_XLo,y
		LDA !SpriteYHi,x : STA !Ex_YHi,y
		LDA !SpriteXHi,x : STA !Ex_XHi,y
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








; MAKE THIS A SHARED ROUTINE!!
;	- comment it
;	- add output description
;
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








