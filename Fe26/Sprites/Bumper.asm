Bumper:

	namespace Bumper


	; $32D0,x = bumper timer


	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		CMP #$08 : BCC .GFX

		LDA $3220,x
		SEC : SBC #$04
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$04
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$18
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCC .GFX
		PHA
		LDA #$10 : STA $32D0,x		; animation
		LDA #$08 : STA !SPC4		; SFX
		PLA
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00
		JSR Interact
		PLA
	.P2	LSR A : BCC .GFX
		LDY #$80
		JSR Interact


		.GFX
		LDX !SpriteIndex
		REP #$20
		LDA.w #!BigRAM : STA $04
		LDA.w #Graphics_TM0 : STA $00
		LDA $32D0,x
		AND #$0002 : BEQ .Graphics
		LDA.w #Graphics_TM1 : STA $00


		.Graphics
		LDA #$0010 : STA !BigRAM
		SEP #$20
		LDY #$0F
	-	LDA ($00),y				;\
		CLC : ADC !GFX_status+$0B		; |
		CLC : ADC !GFX_status+$0B		; | tile number
		STA !BigRAM+2,y				; |
		DEY					;/
		LDA ($00),y : STA !BigRAM+2,y		;\ y disp
		DEY					;/
		LDA ($00),y : STA !BigRAM+2,y		;\ x disp
		DEY					;/
		LDA ($00),y				;\
		BIT !GFX_status+$0B			; |
		BPL $01 : INC A				; | prop
		STA !BigRAM+2,y				; |
		DEY : BPL -				;/

		JSL LOAD_TILEMAP_Long



		.Return
		PLB

	INIT:
		RTL



	Graphics:

		.TM0
		db $29,$F8,$F8,$00
		db $69,$F7,$F8,$00
		db $A9,$F8,$08,$00
		db $E9,$F7,$08,$00

		.TM1
		db $29,$F9,$F9,$00
		db $69,$F8,$F9,$00
		db $A9,$F9,$07,$00
		db $E9,$F8,$07,$00


	Interact:
		LDA !P2Status-$80,y : BNE .Return

		LDA !P2XPosLo-$80,y
		CMP $3220,x
		LDA !P2XPosHi-$80,y
		SBC $3250,x
		EOR #$30
		STA !P2XSpeed-$80,y
		LDA !P2YPosLo-$80,y
		CMP $3210,x
		LDA !P2YPosHi-$80,y
		SBC $3240,x
		EOR #$30
		STA !P2YSpeed-$80,y

		LDA !P2Character-$80,y : BEQ .Mario
		PHA
		LDA !P2YSpeed-$80,y : BPL +
		TYA
		CLC : ROL #2
		TAX
		LDA #$D0			;\
		BIT $6DA2,x			; | Set Y speed
		BPL $02 : LDA #$A8		; |
		STA !P2YSpeed-$80,y		;/
		LDA #$00			;\
		STA !P2SenkuUsed-$80,y		;/ Reset air Senku
	+	PLA
		CMP #$03 : BEQ .Leeway

		.Return
		RTS

		.Mario
		LDA !P2XSpeed-$80,y : STA !MarioXSpeed
		LDA !P2YSpeed-$80,y : STA !MarioYSpeed
		BPL .Return
		JSL !BouncePlayer
		RTS

		.Leeway
		LDA !P2YSpeed-$80,y : BMI +
		LDA #$00 : STA !P2Dashing-$80,y
	+	LDA !P2XSpeed-$80,y : STA !P2VectorX-$80,y
		PHP
		LDA #$01
		PLP
		BMI $02 : DEC #2
		STA !P2VectorAccX-$80,y
		LDA #$30 : STA !P2VectorTimeX-$80,y
		RTS


	namespace off





