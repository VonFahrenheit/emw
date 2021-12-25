

UltraFuzzy:

	namespace UltraFuzzy

	INIT:
		PHB : PHK : PLB
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D : BNE .Graphics
		JSR .Process

		.Graphics
		REP #$20
		LDA.w #.Tilemap : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC


	.Return
		PLB
		RTL


		.Process
		JSL SPRITE_OFF_SCREEN

		LDA #!palset_generic_ghost_blue : JSL LoadPalset
		LDA !Palset_status+!palset_generic_ghost_blue
		ASL A
		STA $33C0,x


		INC $3280,x
		REP #$30
		LDA $3280,x
		AND #$00FF
		ASL #2
		CMP #$0200
		PHP
		AND #$01FF
		TAX
		LDA.l !TrigTable,x
		LSR #4
		PLP
		BCC $04 : EOR #$FFFF : INC A
		SEP #$30
		LDX !SpriteIndex
		STA $9E,x
		LDY $3320,x
		LDA .XSpeed,y : STA $AE,x

		JSL !SpriteApplySpeed-$10
		JSL !SpriteApplySpeed-$08


		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC .NoContact

		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		LDA !StarTimer : BNE .NoContact

		LDA #$0F
		STA !P2Stasis-$80
		STA !P2Stasis
		STZ !Level+2
		LDA #$04 : STA !Level+3
		LDA #$F3 : STA $6DB0

		LDA #$3F : STA !SPC4			; dizzy sfx

		LDA #$01+!CustomOffset			;\
		STA !Ex_Num				; |
		STA !Ex_Num+1				; |
		LDA #$10 : STA !Ex_Data1		; |
		LDA #$20 : STA !Ex_Data1+1		; |
		LDA #$FF				; | dizzy stars on players
		STA !Ex_Data2				; |
		STA !Ex_Data2+1				; |
		LDA #$F0				; |
		STA !Ex_Data3				; |
		STA !Ex_Data3+1				;/
		.NoContact

		RTS


	.XSpeed
		db $08,$F8

	.Tilemap
		dw $0010
		db $32,$F8,$F8,$00
		db $32,$08,$F8,$02
		db $32,$F8,$08,$04
		db $32,$08,$08,$06



	namespace off




