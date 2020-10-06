KompositeKoopa:

	namespace KompositeKoopa


	!HP		=	$BE,x

	!Player1Hurt	=	$3280,x
	!Player2Hurt	=	$3290,x

	!Player1Touch	=	$32A0,x		; A player can only interact with 1 segment per frame
	!Player2Touch	=	$32B0,x		; If both are set, then it skips to head interaction

	!OpenMouth	=	$32D0,x		; While timer is non-zero, mouth is open

	!HurtTimer	=	$3300,x		; Flashing and invulnerable while non-zero

	!DeathTimer	=	$3340,x		; Used for death animation





	INIT:
		PHB : PHK : PLB			; > Start of bank wrapper
		INC $3320,x
		LDA !Difficulty			;\
		AND #$03			; | Starting HP
		CLC : ADC #$03			; |
		STA !HP				;/
		LDA #$06 : STA !SpriteAnimIndex
		PLB				; > End of bank wrapper
		RTL				; > End INIT routine


; The tail-end is stationary.
; The head moves in a figure 8.
; The other tiles need to follow somehow...
; Let's start by just making the tail and head.
; Assume 9 (2 for head/torso segment) tiles total.





	MAIN:
		PHB : PHK : PLB

		JSL SPRITE_OFF_SCREEN_Long


		LDA !HP : BPL .NoDeath
		INC !DeathTimer
		JSR GRAPHICS
		PLB
		RTL
		.NoDeath


		JSR GRAPHICS


		LDA $14 : BNE Interact
		LDA #$10 : STA !OpenMouth
		LDA #$06 : STA !SPC4
		STZ $01
		STZ $03
		LDA !BigRAM+3
		BPL $02 : DEC $01
		STA $00
		LDA !BigRAM+4
		BPL $02 : DEC $03
		STA $02
		LDA $3320,x
		DEC A
		EOR #$DF			; 0x20 speed in proper direction
		STA $04
		STZ $05
		JSR Fire
		LDA !Difficulty
		AND #$03
		CMP #$02 : BNE Interact
		LDA #$10 : STA $05
		JSR Fire
		LDA #$F0 : STA $05
		JSR Fire


	Interact:
		LDA !Player1Touch
		BEQ $03 : DEC !Player1Touch
		LDA !Player2Touch
		BEQ $03 : DEC !Player2Touch
		STZ !Player1Hurt
		STZ !Player2Hurt



		LDA $3220,x : STA !BigRAM+$26
		LDA $3250,x : STA !BigRAM+$27
		LDA $3210,x : STA !BigRAM+$28
		LDA $3240,x : STA !BigRAM+$29


	
	.Head	LDY #$00 : JSR .GetSegment
		LDA #$14 : STA $06
		SEC : JSL !PlayerClipping
		BCC .CheckAttack
		LSR A : BCC ..P2
	..P1	LDY !Player1Touch : BNE ..P2
		PHA
		LDA #$01 : STA !P2SenkuSmash-$80
		LDA #$08 : STA !Player2Touch
		LDY #$00 : JSR .CheckContact
		BCC $03 : INC !Player1Hurt
		LDA !P2YSpeed-$80 : BMI ...End
		JSR .Stomp
	...End	PLA
	..P2	LDY !Player2Touch : BNE .CheckAttack
		LSR A : BCC .CheckAttack
		LDA #$01 : STA !P2SenkuSmash
		LDA #$08 : STA !Player2Touch
		LDY #$80 : JSR .CheckContact
		BCC $03 : INC !Player2Hurt
		LDA !P2YSpeed : BMI .CheckAttack
		JSR .Stomp

	.CheckAttack
		JSL P2Attack_Long
		BCC .NoAttack
		JSR .Stomp_2
		.NoAttack

	.Body	LDY #$20

	-	JSR .GetSegment

		PHY
		SEC : JSL !PlayerClipping
		BCC .Nope
	..P1	LDY !Player1Touch : BNE ..P2
		LSR A : BCC ..P2
		PHA
		LDA #$01 : STA !P2SenkuSmash-$80
		LDY #$00 : JSR .CheckContact
		BCC $03 : INC !Player1Hurt
		LDA #$08 : STA !Player1Touch
		LDA !P2YSpeed-$80 : BMI ...End
		JSR .Bounce
	...End	PLA
	..P2	LDY !Player2Touch : BNE .Nope
		LSR A : BCC .Nope
		LDA #$01 : STA !P2SenkuSmash
		LDY #$80 : JSR .CheckContact
		BCC $03 : INC !Player2Hurt
		LDA #$08 : STA !Player2Touch
		LDA !P2YSpeed : BMI .Nope
		JSR .Bounce

	.Nope	PLA
		SEC : SBC #$04
		CMP #$04 : BEQ .Return
		TAY
		LDA !Player1Touch : BEQ -
		LDA !Player2Touch : BEQ -

		.Return
		TDC
		LDY !Player1Hurt
		BEQ $01 : INC A
		LDY !Player2Hurt
		BEQ $02 : INC #2
		JSL !HurtPlayers

		PLB
		RTL



	.GetSegment
		REP #$20
		LDA #$0C0C : STA $06
		LDA !BigRAM+3,y : JSR .Convert
		ADC !BigRAM+$26
		STA $04
		STA $09
		LDA !BigRAM+4,y : JSR .Convert
		ADC !BigRAM+$28
		STA $05
		SEP #$20
		XBA : STA $0B
		RTS


	.Convert
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		INC #2
		CLC
		RTS


	.CheckContact
		LDA !P2Hurtbox-$80+2,y
		SEC : SBC #$04
		STA $00
		LDA !P2Hurtbox-$80+3,y
		SBC #$00
		STA $01
		LDA $00
		CMP $05
		LDA $01
		SBC $09
		RTS


	.Bounce
		JSL P2Bounce_Long
		LDA #$02 : STA !SPC1
		RTS


	.Stomp
		JSL P2Bounce_Long
	..2	LDA !HurtTimer : BEQ ..Yes
		LDA #$02 : STA !SPC1
		RTS

		..Yes
		LDA #$20 : STA !OpenMouth
		LDA #$28 : STA !SPC4
		LDA #$80 : STA !HurtTimer
		DEC !HP
		RTS



	Fire:
		LDY #$01
		LDA #$01
		JSL SpawnExSprite_Long
		RTS



	GRAPHICS:
		LDY !SpriteAnimIndex				;\
		LDA !DeathTimer : BNE +				; > Don't update position during death
		LDA !SpriteAnimTimer				; |
		INC A						; |
		CMP.w .AnimTime,y				; |
		BNE $04 : TDC : INC !SpriteAnimIndex		; | Update animation index and timer
		STA !SpriteAnimTimer				; |
		CMP #$00 : BNE +				; |
		LDA !SpriteAnimIndex				; |
		CMP #$06					; |
		BCC $03 : STZ !SpriteAnimIndex			; |
		CMP #$07 : BNE +				; > 6 goes straight to 1
		INC !SpriteAnimIndex				; | 
		+						;/

		LDA !SpriteAnimIndex				;\
		ASL #2						; |
		TAY						; |
		REP #$20					; |
		STZ $00						; | copy tilemap to RAM
		STZ $02						; |
		STZ $06						; |
		LDA.w .Anim+2,y : PHA				;  > set formula address
		LDA.w .Anim,y : JSR LakituLovers_TilemapToRAM	; |
		LDA.w #!BigRAM : STA $04			; |
		SEP #$20					;/
		RTS						; > jump to address set by the PHA earlier

		.Return
		LDA !SpriteAnimIndex				;\
		CMP #$03 : BCC .Draw				; |
		LDY #$1C					; |
	-	LDA !BigRAM+4,y					; |
		EOR #$FF					; | Invert Y offset during frames 4-6
		INC A						; |
		STA !BigRAM+4,y					; |
		DEY #4						; |
		BPL -						;/

		.Draw
		LDA !DeathTimer : BNE .Open			; mouth open during death animation
		LDA !OpenMouth : BEQ .Closed
	.Open	LDA !BigRAM+5
		CLC : ADC #$03
		STA !BigRAM+5
		LDA !BigRAM+9
		CLC : ADC #$03
		STA !BigRAM+9
		.Closed


		LDA !DeathTimer : BEQ .NoDeath
		AND #$F0
		LSR #2
		STA $00
		LDA !BigRAM
		SEC : SBC $00
		CMP #$04 : BNE +
		STZ $3230,x

	+	STA !BigRAM
		JSR .Go

		LDA !DeathTimer
		AND #$0F : BNE .Skip
		LDY !BigRAM
		LDA #$08 : STA !SPC1
		REP #$20
		LDA !BigRAM+3,y : JSR Interact_Convert
		STA $00
		LDA !BigRAM+4,y : JSR Interact_Convert
		STA $02
		SEP #$20
		LDY #$01
		LDA #$00
		JSL SpawnExSprite_NoSpeed_Long
		RTS
		.NoDeath

		LDA !HurtTimer
		AND #$02 : BNE .Skip
	.Go	JSL LOAD_PSUEDO_DYNAMIC_Long

		.Skip
		RTS



		.Formula1
		LDA !SpriteAnimTimer		;\
		LSR A				; |
		TAY				; | Set up RAM
		LDA ..WaveX,y : STA $00		; |
		LDA ..WaveY,y : STA $01		;/
		LDA !BigRAM+3			;\
		SEC : SBC $00			; |
		STA !BigRAM+3			; |
		CLC : ADC #$08			; | Head and torso
		STA !BigRAM+7			; |
		LDA $01				; |
		CLC : ADC !BigRAM+4		; |
		STA !BigRAM+4			;/
		STA !BigRAM+8

		LDY #$01			;\
		LDA #$10 : JSR .Multiply	; |
		LDA !BigRAM+$0B			; |
		SEC : SBC $00			; | Tile 1
		STA !BigRAM+$0B			; |
		LDA #$14 : JSR .Divide		; |
		CLC : ADC !BigRAM+$0C		; |
		STA !BigRAM+$0C			;/

		LDY #$00			;\
		LDA #$19 : JSR .Multiply	; |
		LDA #$2C : JSR .Divide		; |
		STA $02				; |
		LDA !BigRAM+$0F			; |
		SEC : SBC $02			; | Tile 2
		STA !BigRAM+$0F			; |
		LDY #$01			; |
		LDA #$0B : JSR .Multiply	; |
		LDA #$14 : JSR .Divide		; |
		CLC : ADC !BigRAM+$10		; |
		STA !BigRAM+$10			;/

		LDA !SpriteAnimTimer		;\
		LSR #2 : STA $02		; | $02: timer/4
		LSR A : PHA			; | stack: timer/8
		LSR A				; | $03: timer/16
		STA $03				; |
		LSR A : PHA			; | stack: timer/32
		LDA !BigRAM+$13			; |
		SEC : SBC $02			; | Tile 3
		STA !BigRAM+$13			; |
		LDA $03				; |
		CLC : ADC !BigRAM+$14		; |
		STA !BigRAM+$14			;/
		PLA				;\
		SEC : SBC !BigRAM+$17		; |
		EOR #$FF : INC A		; |
		STA !BigRAM+$17			; | Tile 4
		PLA				; |
		SEC : SBC !BigRAM+$18		; |
		EOR #$FF : INC A		; |
		STA !BigRAM+$18			;/
		LDY #$00			;\
		LDA #$08 : JSR .Multiply	; |
		LDA #$30 : JSR .Divide		; |
		PHA				; | Tile 5
		EOR #$FF			; |
		CLC : ADC !BigRAM+$1C		; |
		STA !BigRAM+$1C			;/
		PLA				;\
		LSR A				; |
		EOR #$FF			; | Tile 6
		CLC : ADC !BigRAM+$20		; |
		STA !BigRAM+$20			;/

		JMP .Return


		..WaveX
		db $00,$00,$01,$02,$04,$06,$08,$0A
		db $0D,$0F,$11,$13,$16,$19,$1C,$1F
		db $22,$25,$27,$29,$2A,$2B,$2C,$2C

		..WaveY
		db $FF,$FF,$FE,$FE,$FE,$FD,$FD,$FD
		db $FE,$FE,$FF,$FF,$00,$01,$02,$03
		db $05,$07,$09,$0B,$0D,$0E,$0F,$10


	; head:
	;	X: $E0 -> $B3	(-2D)
	;	Y: $D0 -> $E4	(+14)
	; tile 1:
	;	X: $EA -> $BE	(-2C)
	;	Y: $D8 -> $E8	(+10)
	; tile 2:
	;	X: $E2 -> $C9	(-19)
	;	Y: $E1 -> $EC	(+0B)
	; tile 3:
	;	X: $E0 -> $D4	(-C)
	;	Y: $ED -> $F0	(+3)
	; tile 4:
	;	X: $E2 -> $DF	(-3)	
	;	Y: $F9 -> $F3	(-6)
	; tile 5:
	;	X: $EA -> $EA	(--)
	;	Y: $00 -> $F8	(-8)
	; tile 6:
	;	X: $F5 -> $F5	(--)
	;	Y: $00 -> $FC	(-4)
	; base:
	;	- no movement -





		.Formula2
		LDA !SpriteAnimTimer		;\
		LSR A				; |
		PHA				; |
		LSR A				; |
		TAY				; | Set up RAM
		LDA ..Tile2X,y : STA $00	; |
		LDA ..Tile2Y,y : STA $01	; |
		PLY				; |
		LDA ..WaveY,y : STA $02		;/

		TYA				;\
		CLC : ADC !BigRAM+3		; |
		STA !BigRAM+3			; | Head and torso X
		CLC : ADC #$08			; |
		STA !BigRAM+7			;/
		TYA				;\
		CLC : ADC !BigRAM+$0B		; | Tile 1 X
		STA !BigRAM+$0B			;/

		CPY #$08 : BCC +		;\
		INC !BigRAM+$20			; | Tile 6 (complete)
		+				;/

		LDA $02				;\
		CLC : ADC !BigRAM+4		; | Head and torso Y
		STA !BigRAM+4			; |
		STA !BigRAM+8			;/

		PHY				; > push Y
		LDY #$02			;\
		LDA #$16			; |
		JSR .Multiply			; | Tile 1 Y
		LDA #$1C : JSR .Divide		; |
		CLC : ADC !BigRAM+$0C		; |
		STA !BigRAM+$0C			;/
		LDA #$05 : JSR .Multiply	; Set up math for tile 5
		PLY				; > pull Y

		TYA				;\
		LSR A				; |
		TAY				; |
		LDA $00				; |
		CLC : ADC !BigRAM+$0F		; | Tile 2
		STA !BigRAM+$0F			; |
		LDA $01				; |
		CLC : ADC !BigRAM+$10		; |
		STA !BigRAM+$10			;/

		TYA				;\
		CLC : ADC !BigRAM+$13		; |
		STA !BigRAM+$13			; |
		TYA				; | Tile 3
		LSR A				; |
		EOR #$FF			; |
		CLC : ADC !BigRAM+$14		; |
		STA !BigRAM+$14			;/

		TYA				;\
		CLC : ADC !BigRAM+$17		; |
		STA !BigRAM+$17			; |
		TYA				; | Tile 4
		EOR #$FF			; |
		CLC : ADC !BigRAM+$18		; |
		STA !BigRAM+$18			;/

		LDA #$1C : JSR .Divide		;\
		PHA				; |
		CLC : ADC !BigRAM+$1B		; |
		STA !BigRAM+$1B			; | Tile 5
		PLA				; |
		EOR #$FF			; |
		CLC : ADC !BigRAM+$1C		; |
		STA !BigRAM+$1C			;/

		JMP .Return

		..WaveY
		db $01,$03,$05,$06,$08,$0A,$0B,$0D
		db $0F,$10,$12,$14,$15,$17,$19,$1A

		..Tile2X
		db $00,$01,$03,$04,$06,$07,$09,$0A

		..Tile2Y
		db $00,$02,$03,$04,$05,$06,$06,$07


	; head:
	;	X: $B3 -> $C4	(11)
	;	Y: $E4 -> $00	(1C)
	; tile 1:
	;	X: $BE -> $D0	(12)
	;	Y: $E8 -> $FE	(16)
	; tile 2:
	;	X: $C9 -> $D4	(0B)
	;	Y: $EC -> $F3	(07)
	; tile 3:
	;	X: $D4 -> $DC	(08)
	;	Y: $F0 -> $EB	(-5)
	; tile 4:
	;	X: $DF -> $E8	(09)
	;	Y: $F3 -> $EB	(-8)
	; tile 5:
	;	X: $EA -> $F0	(06)
	;	Y: $F8 -> $F3	(-5)
	; tile 6:
	;	X: $F5 -> $F4	(-1)
	;	Y: $FC -> $FE	(02)
	; base:
	;	- no movement -



		.Formula3
		LDA !SpriteAnimTimer		;\
		CMP #$20 : BCC +		; | Tile 6
		INC !BigRAM+$20			; |
		+				;/
		STA $03				;\
		LSR A				; |
		PHA				; |
		TAY				; |
		LDA ..WaveX,y : STA $00		; | Set up RAM
		LDA ..WaveY,y : STA $01		; |
		PLA				; |
		LSR A				; |
		TAY				; |
		LDA ..Rotate,y : STA $02	;/

		LDA $00				;\
		CLC : ADC !BigRAM+3		; |
		STA !BigRAM+3			; |
		CLC : ADC #$08			; |
		STA !BigRAM+7			; | Head and torso
		LDA $01				; |
		CLC : ADC !BigRAM+4		; |
		STA !BigRAM+4			; |
		STA !BigRAM+8			;/

		LDY #$00			;\
		LDA #$1A : JSR .Multiply	; |
		LDA #$1C : JSR .Divide		; |
		CLC : ADC !BigRAM+$0B		; |
		STA !BigRAM+$0B			; | Tile 1
		LDY #$01			; |
		LDA #$2A : JSR .Multiply	; |
		LDA #$30 : JSR .Divide		; |
		CLC : ADC !BigRAM+$0C		; |
		STA !BigRAM+$0C			;/

		LDY #$00			;\
		LDA #$0E : JSR .Multiply	; |
		LDA #$1C : JSR .Divide		; |
		CLC : ADC !BigRAM+$0F		; |
		STA !BigRAM+$0F			; | Tile 2
		LDY #$01			; |
		LDA #$2C : JSR .Multiply	; |
		LDA #$30 : JSR .Divide		; |
		CLC : ADC !BigRAM+$10		; |
		STA !BigRAM+$10			;/

		LDY #$00			;\
		LDA #$04 : JSR .Multiply	; |
		LDA #$1C : JSR .Divide		; |
		CLC : ADC !BigRAM+$13		; |
		STA !BigRAM+$13			; | Tile 3
		LDY #$01			; |
		LDA #$28 : JSR .Multiply	; |
		LDA #$30 : JSR .Divide		; |
		CLC : ADC !BigRAM+$14		; |
		STA !BigRAM+$14			;/



		LDA $02				;\
		CLC : ADC !BigRAM+$18		; | Tile 4 Y
		STA !BigRAM+$18			;/

		LDY #$02			;\
		LDA #$0D : JSR .Multiply	; |
		LDA #$1C : JSR .Divide		; | Tile 5 Y
		CLC : ADC !BigRAM+$1C		; |
		STA !BigRAM+$1C			;/

		LDY #$03			;\
		LDA #$06 : JSR .Multiply	; | math for tile 4/5 X
		LDA #$40 : JSR .Divide		; |
		EOR #$FF			;/
		PHA				;\
		CLC : ADC !BigRAM+$17		; | Tile 4 X
		STA !BigRAM+$17			;/
		PLA				;\
		CLC : ADC !BigRAM+$1B		; | Tile 5 X
		STA !BigRAM+$1B			;/


		JMP .Return




		..WaveX
		db $01,$03,$04,$06,$07,$09,$0A,$0B
		db $0C,$0D,$0F,$10,$11,$12,$13,$14
		db $15,$16,$17,$18,$18,$19,$19,$1A
		db $1A,$1A,$1B,$1B,$1B,$1C,$1C,$1C

		..WaveY
		db $02,$04,$06,$08,$0A,$0C,$0D,$0F
		db $11,$13,$14,$15,$16,$17,$18,$18
		db $18,$19,$1A,$1C,$1E,$20,$22,$24
		db $26,$28,$2A,$2C,$2D,$2E,$2F,$2F

		..Rotate
		db $01,$03,$05,$06,$08,$0A,$0B,$0D
		db $0F,$10,$12,$14,$15,$17,$19,$1A





	; head:
	;	X: $C4 -> $E0	(+1C)
	;	Y: $00 -> $30	(+30)
	; tile 1:
	;	X: $D0 -> $EA	(+1A)
	;	Y: $FE -> $28	(+2A)
	; tile 2:
	;	X: $D4 -> $E2	(+0E)
	;	Y: $F3 -> $1F	(+2C)
	; tile 3:
	;	X: $DC -> $E0	(+04)
	;	Y: $EB -> $13	(+28)
	; tile 4:
	;	X: $E8 -> $E2	(-06)
	;	Y: $EB -> $07	(+1C)
	; tile 5:
	;	X: $F0 -> $EA	(-06)
	;	Y: $F3 -> $00	(+0D)
	; tile 6:
	;	X: $F4 -> $F5	(+01)
	;	Y: $FE -> $00	(-02)
	; base:
	;	- no movement -


		; Multiplies A by $00,y, returns A = product
		.Multiply
		STZ $2250
		STA $2251
		STZ $2252
		BPL $03 : DEC $2252
		LDA $3000,y : STA $2253
		PHP
		LDA #$00
		PLP
		BPL $01 : DEC A
		STA $2254
		NOP
		BRA $00
		LDA $2306
		RTS


		; Divides $2306 by A, returns A = quotient
		.Divide
		PHA
		PHA
		LDA #$01 : STA $2250
		REP #$20
		LDA $2306 : STA $2251
		PLA
		AND #$00FF
		STA $2253
		NOP
		SEP #$20
		LDA $2306
		RTS




	.InitFormula
		LDA !SpriteAnimTimer
		LSR #2
		STA $00
		STA $02
		LSR #2
		STA $01
		INC A
		STA $03
		LDA !SpriteAnimTimer : STA !P1Coins
		LSR A
		AND #$07
		BNE $01 : INC A
		STA $0F			; number of Y-adjusted tiles on this level


		LDY #$1B
	-	LDA !BigRAM+4,y
		SEC : SBC $00
		STA !BigRAM+4,y
		LDA !BigRAM+5,y
		CLC : ADC $01
		STA !BigRAM+5,y

		LDA $00
		CLC : ADC $02
		STA $00
		LDA $01
		CLC : ADC $03
		STA $01
		DEC $0F : BNE +
		DEC $03

	+	DEY #4 : BPL -

		LDA !BigRAM+7
		SEC : SBC #$08
		STA !BigRAM+3
		LDA !BigRAM+8
		STA !BigRAM+4


		JMP .Return



; proper repeating movement is:
; - rotate up
; - straighten up
; - bend down
; - rotate down
; - straighten down
; - bend up
;
; If I animate the first half, I can simply repeat it and invert the Y-offsets for the second half.
;
; Proposed method:
; - write 3 base frames (1, 2, 3)
; - for each frame, write a formula that gradually transforms it into the next one
; - if !SpriteAnimIndex > 3, invert Y offset of each tile before calling LOAD_TILEMAP
;
; This way, I only need to write 3 tilemaps/transformations.
; For the other ones (4, 5, 6) I just invert the vertical offset.
;





	.Anim
	dw .Frame1,.Formula1-1		; frame 1, index 0
	dw .Frame2,.Formula2-1		; frame 2, index 1
	dw .Frame3,.Formula3-1		; frame 3, index 2
	dw .Frame1,.Formula1-1		; frame 4, index 3
	dw .Frame2,.Formula2-1		; frame 5, index 4
	dw .Frame3,.Formula3-1		; frame 6, index 5
	dw .Frame0,.InitFormula-1	; init frame, index 6

	.AnimTime
	db $30,$20,$40			; frames 1-3
	db $30,$20,$40			; frames 4-6
	db $2C				; init frame

	.Frame1
	dw $0024
	db $3A,$D8,$D0,$AA	; head
	db $3A,$E0,$D0,$AB	; torso
	db $3A,$EA,$D8,$A4	; tile 1
	db $3A,$E2,$E1,$A4	; tile 2
	db $3A,$E0,$ED,$A4	; tile 3
	db $3A,$E2,$F9,$A4	; tile 4
	db $3A,$EA,$00,$A4	; tile 5
	db $3A,$F5,$02,$A4	; tile 6
	db $3A,$00,$00,$A4	; base

	.Frame2
	dw $0024
	db $3A,$AB,$E4,$AA	; head
	db $3A,$B3,$E4,$AB	; torso
	db $3A,$BE,$E8,$A4	; tile 1
	db $3A,$C9,$EC,$A4	; tile 2
	db $3A,$D4,$F0,$A4	; tile 3
	db $3A,$DF,$F4,$A4	; tile 4
	db $3A,$EA,$F8,$A4	; tile 5
	db $3A,$F5,$FC,$A4	; tile 6
	db $3A,$00,$00,$A4	; base

	.Frame3
	dw $0024
	db $3A,$BC,$00,$AA	; head
	db $3A,$C4,$00,$AB	; torso
	db $3A,$D0,$FE,$A4	; tile 1
	db $3A,$D4,$F3,$A4	; tile 2
	db $3A,$DC,$EB,$A4	; tile 3
	db $3A,$E8,$EB,$A4	; tile 4
	db $3A,$F0,$F3,$A4	; tile 5
	db $3A,$F4,$FE,$A4	; tile 6
	db $3A,$00,$00,$A4	; base


	.Frame0
	dw $0024
	db $3A,$F8,$00,$AA	; head
	db $3A,$00,$00,$AB	; torso
	db $3A,$00,$00,$A4	; tile 1
	db $3A,$00,$00,$A4	; tile 2
	db $3A,$00,$00,$A4	; tile 3
	db $3A,$00,$00,$A4	; tile 4
	db $3A,$00,$00,$A4	; tile 5
	db $3A,$00,$00,$A4	; tile 6
	db $3A,$00,$00,$A4	; base





	namespace off





