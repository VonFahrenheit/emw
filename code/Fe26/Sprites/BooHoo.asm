BooHoo:

	namespace BooHoo




; extra bit controls movement type
; 0 - chase player, sine motion for vertical speed
; 1 - face player upon spawn, slowly move in one direction




	INIT:
		LDA !ExtraBits,x
		AND #$04 : BEQ .Return
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x
	.Return	RTL



	MAIN:

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D : BEQ .Process
		RTL


		.Process
		PHB : PHK : PLB
		INC $3280,x


		LDA !ExtraBits,x
		AND #$04 : BEQ .Chase

	.Forward
		LDY $3320,x
		LDA DATA_XSpeed+2,y : STA $AE,x
		STZ $9E,x
		BRA +					; go to sine wave handler


	.Chase
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x
		LDA $AE,x
		CMP DATA_XSpeed,y : BEQ +
		CLC : ADC DATA_XAcc,y
		STA $AE,x
	+	LDA $3280,x
		REP #$30
		AND #$00FF
		ASL A
		TAX
		LDA.l !TrigTable,x
		LSR #4
		SEP #$30
		LDX !SpriteIndex
		SEC : SBC #$0A
		STA $9E,x


	.GoSpeed
		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$8

		LDA $3280,x
		AND #$7F
		BNE +
		LDA $BE,x
		EOR #$01
		STA $BE,x
		TAY
		LDA Anim_Reset,y : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		+


	Animation:

		INC $32A0,x
		LDA $32A0,x
		CMP #$04 : BNE +
		STZ $32A0,x
		INC $3290,x
		LDA $3290,x
		CMP #$03 : BNE +
		STZ $3290,x
		+

		LDY !SpriteAnimIndex
		LDA !SpriteAnimTimer
		INC A
		CMP Anim_FaceTime,y : BNE +
		LDA !SpriteAnimIndex
		EOR #$01
		STA !SpriteAnimIndex
		LDA #$00

	+	STA !SpriteAnimTimer





; Plan:
;	- !SpriteAnimIndex is used for animating the sprite itself
;	- $3290,x is used for tear animation (which matches splash animation)
;	- splash frame is drawn first in OAM
;	- boo hoo + splash tile are both drawn in hi prio OAM

; !BigRAM:
;	- $00 tilemap for face (splash tile is appended here)
;	- $20 tilemap for tear stream
;	- $40 used as scratch for Map16 calc



	Graphics:

; this should be moved to hi prio
		LDY #$03
	-	LDA.w Anim_TM,y : STA !BigRAM+$02,y
		DEY : BPL -
		LDY !SpriteAnimIndex
		LDA Anim_FaceTile,y : STA !BigRAM+$05
		STZ !BigRAM+$01

		LDA $BE,x : BNE .Attack
	.NoCry	LDA #$04 : STA !BigRAM+$00
		JMP .Draw


	.Attack
		LDY $3320,x
		LDA DATA_HitBoxX1,y
		STA !BigRAM+$40			;\ random scratch
		STZ !BigRAM+$41			;/


		REP #$30
		LDY #$0000
	-	LDA !BigRAM+$40
		STY $0E
		JSL !GetMap16Sprite
		REP #$10
		CMP #$0100 : BCC .Side
		CMP #$016E : BCC .Close
	.Side	LDA !BigRAM+$40
		CLC : ADC #$0007
		LDY $0E
		JSL !GetMap16Sprite
		REP #$10
		CMP #$0100 : BCC .Next
		CMP #$016E : BCC .Close

	.Next	LDA $0E
		CMP #$0070 : BEQ .Close
		CLC : ADC #$0010
		TAY
		BRA -

	.Close	SEP #$30
		LDA $0E : BEQ .NoCry
		STA $0D				; height of tear stream
		LSR #2
		SEC : SBC #$04
		STA $0C				; final index for y
		STA !BigRAM+$20
		STZ !BigRAM+$21
		LDA $0E
		CMP #$70 : BEQ +


	; splash tile
		LDA $3210,x
		AND #$0F
		CLC : ADC #$08
		STA $0F				; offset to ground ($0F is 0 when we get here)
		LDA #$02 : STA !BigRAM+$07			;\
		LDY $3290,x					; |
		LDA Anim_SplashTile,y : STA !BigRAM+$09		; |
		LDA $0E						; | append splash tile
		SEC : SBC $0F					; |
		STA !BigRAM+$08					; |
		LDA #$1E : STA !BigRAM+$06			; |
		LDA #$08 : STA !BigRAM+$00			;/
		LDA !BigRAM+$20
		SEC : SBC #$04
		STA !BigRAM+$20
		LDA $0C
		SEC : SBC #$08
		TAY
		BRA .DrawStream


	+	LDA $0C
		SEC : SBC #$04
		TAY
	.DrawStream
		LDA $0E
		SEC : SBC #$10
		STA $0E


	.Loop	LDA $0E
		SEC : SBC $0F
		STA !BigRAM+$24,y
		LDA $0E
		SEC : SBC #$10
		STA $0E
		LDA #$02 : STA !BigRAM+$23,y
		LDA #$3E : STA !BigRAM+$22,y
		LDA $3290,x
		ASL A
		ADC #$08
		STA !BigRAM+$25,y
		DEY #4 : BPL .Loop


		LDY $3320,x
		LDA $3220,x
		CLC : ADC DATA_HitBoxX2,y
		STA $04
		LDA $3250,x
		ADC #$00
		STA $0A
		LDA $0D : STA $07
		LDA $3210,x : STA $05
		LDA $3240,x : STA $0B
		LDA #$04 : STA $06
		SEC : JSL !PlayerClipping
		BCC .NoHit
		JSL !HurtPlayers
		.NoHit

		LDA !BigRAM+$20 : BMI .Fail
		LDA.b #!BigRAM+$20 : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_PSUEDO_DYNAMIC_p1_Long
		.Fail


	.Draw	LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_PSUEDO_DYNAMIC_p2_Long

	.Return
		PLB
		RTL




	Anim:
		.TM
		db $3E,$00,$00,$00

		.FaceTile
		db $00,$02,$04,$06

		.FaceTime
		db $30,$10,$08,$08

		.Reset
		db $00,$02


		.SplashTile
		db $0E,$0F,$1E

		.SplashX
		db $FA,$02

	DATA:
		.XSpeed
		db $20,$E0
		db $0C,$F4

		.XAcc
		db $01,$FF

		.HitBoxX1
		db $06,$02

		.HitBoxX2
		db $08,$04




	namespace off




