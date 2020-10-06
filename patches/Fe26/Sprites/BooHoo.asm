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
;	- boo hoo + splash tile are both moved to hi prio OAM




	Graphics:
		LDY #$03
	-	LDA.w Anim_TM,y : STA !BigRAM+2,y
		DEY : BPL -
		LDY !SpriteAnimIndex
		LDA Anim_FaceTile,y : STA !BigRAM+5

		LDA $BE,x : BNE .Attack
	.NoCry	LDA #$04 : STA !BigRAM+0
		STZ !BigRAM+1
		JMP .Draw


	.Attack

		LDY $3320,x
		LDA DATA_HitBoxX1,y
		STA !BigRAM+$20			;\ random scratch
		STZ !BigRAM+$21			;/


		REP #$30
		LDY #$0000
	-	LDA !BigRAM+$20
		STY $0E
		JSL !GetMap16Sprite
		REP #$10
		CMP #$0100 : BCC .Side
		CMP #$016E : BCC .Close
	.Side	LDA !BigRAM+$20
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
		CLC : ADC #$04
		STA !BigRAM+0
		STZ !BigRAM+1
		LDA $0E
		CMP #$70 : BEQ +
		LDA $3210,x
		AND #$0F
		CLC : ADC #$08
		STA $0F				; offset to ground ($0F is 0 when we get here)

		LDY $3290,x
		LDA Anim_SplashTile,y
		LDY #$00
		STA !BigRAM+9,y
		LDY $3320,x
		LDA Anim_SplashX,y
		LDY #$00
		STA !BigRAM+7,y
		LDA $0E
		SEC : SBC $0F
		STA !BigRAM+8,y
		LDA $0E
		SEC : SBC #$10
		STA $0E
		LDA #$2E : STA !BigRAM+6,y
		LDY #$04
		BRA .Loop

	+	LDY #$00
	.Loop	LDA $0E
		SEC : SBC $0F
		STA !BigRAM+8,y
		LDA $0E
		SEC : SBC #$10
		STA $0E
		LDA #$02 : STA !BigRAM+7,y
		LDA #$3E : STA !BigRAM+6,y
		LDA #$08
		CLC : ADC $3290,x
		CLC : ADC $3290,x
		STA !BigRAM+9,y

	++	INY #4
		CPY $0C : BCC .Loop

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
		BCC .Draw
		JSL !HurtPlayers


	.Draw	LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05
		JSL LOAD_PSUEDO_DYNAMIC_Long

		LDA !BigRAM
		CMP #$04 : BEQ .Return

		LDA #$08 : JSL HI_PRIO_OAM_Long

		LDA !OAMindex
		LSR #2
		TAY
		DEY
		LDA !OAMhi,y
		AND.b #$02^$FF
		STA !OAMhi,y

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




