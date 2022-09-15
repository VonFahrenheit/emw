

MiniMech:

	namespace MiniMech


	!MiniMechBeta	= $368008			; Source GFX address

	!MiniMechRiding	= $3280,x			; Set if someone is piloting the mech

	INIT:
		PHB : PHK : PLB
		LDA #$08 : STA !SpriteAnimIndex
		PLB



	MAIN:
		PHB : PHK : PLB

	PHYSICS:
		STZ $AE,x

		LDA !MiniMechRiding
		BEQ .NoPilot

		LDA #$7F : STA $78
		LDA #$00 : STA !MarioImg

		LDA $3220,x
		STA !MarioXPosLo
		LDA $3250,x
		STA !MarioXPosHi
		LDA $3210,x
		SEC : SBC #$20
		STA !MarioYPosLo
		LDA $3240,x
		SBC #$00
		STA !MarioYPosHi

		LDA !SpriteAnimIndex
		CMP #$08 : BCS .NoPilot

		BIT $16
		BPL +
		STZ !MiniMechRiding
		LDA #$D0 : STA !MarioYSpeed
		LDA #$08 : STA !SpriteAnimIndex
		BRA .NoPilot
		+

		LDA !SpriteAnimIndex
		CMP #$08 : BCS .NoPilot

		LDA $15
		AND #$03
		BEQ .StandStill
		CMP #$03
		BEQ .StandStill
		DEC A
		STA $3320,x
		TAY
		LDA.w DATA_XSpeed,y
		STA $AE,x
		BRA .NoPilot

		.StandStill
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.NoPilot

		JSL APPLY_SPEED



	INTERACTION:

		LDA !MiniMechRiding
		BNE .NoContact

		JSR HITBOX_BODY				; > Get mech hitbox
		JSL $03B664				; > Get P1 clipping
		JSL $03B72B				; > Check for contact

		BCC .NoContact
		LDA !MarioYSpeed
		BMI .NoContact
		LDA !MarioBlocked
		AND #$04 : BNE .NoContact

		LDA #$01 : STA !MiniMechRiding
		INC !SpriteAnimIndex
		STZ !SpriteAnimTimer



		.NoContact


	GRAPHICS:

		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		LDA ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w ANIM+0,y : STA $04
		LDA ($04)
		CLC : ADC $04
		INC #2
		STA $0C
		SEP #$20
		CLC : JSL !UpdateGFX

		REP #$20
		LDA ($04)
		STA !BigRAM+0
		TAY
		DEY #2
		INC $04
		INC $04
	-	LDA ($04),y
		STA !BigRAM+2,y
		DEY #2
		BPL -

		LDA.w #!BigRAM : STA $04

		SEP #$20

		LDA !MiniMechRiding
		BNE .NoPilot
		LDA !BigRAM+0
		SEC : SBC #$08
		STA !BigRAM+0
		.NoPilot

		JSL LOAD_TILEMAP
		PLB
		RTL



	ANIM:
	.AnimIWalk
		dw .TM_Walk00 : db $06,$01		; 00
		dw .TM_Walk01 : db $06,$02		; 01
		dw .TM_Walk02 : db $06,$03		; 02
		dw .TM_Walk03 : db $06,$04		; 03
		dw .TM_Walk04 : db $06,$05		; 04
		dw .TM_Walk05 : db $06,$06		; 05
		dw .TM_Walk06 : db $06,$07		; 06
		dw .TM_Walk07 : db $06,$00		; 07
	.AnimRise
		dw .TM_Rise00 : db $FF,$08		; 08
		dw .TM_Walk06 : db $0A,$0A		; 09
		dw .TM_Walk07 : db $0A,$00		; 0A



macro MiniMechDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20+!MiniMechBeta
	dw <DestVRAM>*$10+$6000
endmacro


	.TM_Walk00
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$02,$E4,$00
		db $30,$02,$F4,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $000, $0C0)
		%MiniMechDyn(4, $010, $0D0)
		%MiniMechDyn(4, $020, $0E0)
		%MiniMechDyn(4, $030, $0F0)
		..End

	.TM_Walk01
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$03,$E3,$00
		db $30,$03,$F3,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $004, $0C0)
		%MiniMechDyn(4, $014, $0D0)
		%MiniMechDyn(4, $024, $0E0)
		%MiniMechDyn(4, $034, $0F0)
		..End

	.TM_Walk02
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$02,$E3,$00
		db $30,$02,$F3,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $008, $0C0)
		%MiniMechDyn(4, $018, $0D0)
		%MiniMechDyn(4, $028, $0E0)
		%MiniMechDyn(4, $038, $0F0)
		..End

	.TM_Walk03
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$FF,$E5,$00
		db $30,$FF,$F5,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $00C, $0C0)
		%MiniMechDyn(4, $01C, $0D0)
		%MiniMechDyn(4, $02C, $0E0)
		%MiniMechDyn(4, $03C, $0F0)
		..End

	.TM_Walk04
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$00,$E4,$00
		db $30,$00,$F4,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $040, $0C0)
		%MiniMechDyn(4, $050, $0D0)
		%MiniMechDyn(4, $060, $0E0)
		%MiniMechDyn(4, $070, $0F0)
		..End

	.TM_Walk05
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$02,$E3,$00
		db $30,$02,$F3,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $044, $0C0)
		%MiniMechDyn(4, $054, $0D0)
		%MiniMechDyn(4, $064, $0E0)
		%MiniMechDyn(4, $074, $0F0)
		..End

	.TM_Walk06
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$03,$E3,$00
		db $30,$03,$F3,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $048, $0C0)
		%MiniMechDyn(4, $058, $0D0)
		%MiniMechDyn(4, $068, $0E0)
		%MiniMechDyn(4, $078, $0F0)
		..End

	.TM_Walk07
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$01,$E5,$00
		db $30,$01,$F5,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $04C, $0C0)
		%MiniMechDyn(4, $05C, $0D0)
		%MiniMechDyn(4, $06C, $0E0)
		%MiniMechDyn(4, $07C, $0F0)
		..End

	.TM_Rise00
		dw $0018
		db $34,$F8,$F0,$C0
		db $34,$08,$F0,$C2
		db $34,$F8,$00,$E0
		db $34,$08,$00,$E2
		db $30,$04,$E7,$00
		db $30,$04,$F7,$02
		dw ..End-..Start
		..Start
		%MiniMechDyn(4, $080, $0C0)
		%MiniMechDyn(4, $090, $0D0)
		%MiniMechDyn(4, $0A0, $0E0)
		%MiniMechDyn(4, $0B0, $0F0)
		..End



	HITBOX:
		.BODY
		LDA $3220,x				;\
		SEC : SBC #$02				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		SBC #$00				; |
		STA $0A					;/
		LDA #$14				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		SEC : SBC #$08				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		SBC #$00				; |
		STA $0B					;/
		LDA #$18				;\ Hitbox height
		STA $07					;/
		RTS


	DATA:
		.XSpeed
		db $10,$F0


	namespace off





