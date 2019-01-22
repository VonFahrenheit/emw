GoombaSlave:

	namespace GoombaSlave

	INIT:
		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04				;\
		BEQ .NoCover				; |
		LDA #$80				; | Toggle cover
		STA $BE,x				; |
		LDA #$05 : STA !SpriteAnimIndex		;/
		BRA .End

		.NoCover
		LDA #$01 : STA !SpriteAnimIndex

		.End
		LDA #$60 : STA !ClaimedGFX
		BRA $03

; Man, been a while since I've done this.
; Alright, here's the plan:
;
;	Pause check
;	Physics
;	Cargo
;	Interaction
;	Graphics
;
; $BE,x		Tray status
; $3280,x	Cargo flag
; $3290,x	Used for moving Mario
; $32A0,x	Used for moving Mario
; $32B0,x	Carrying Mushroom flag
; $3340,x	Carried Mario last frame flag
;
; $3350,x	Tray tile
;
; To do:
; - Have cover fall off



	MAIN:
		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS

	DATA:
		.XSpeed
		db $10,$F0
		db $08,$F8

	PHYSICS:
		LDY $3320,x				;\
		BIT $BE,x				; |
		BMI +					; |
		LDA $3280,x				; |
		ORA $32B0,x				; | Walk slower with cargo
		BEQ $02					; |
	+	INY #2					; |
		LDA.w DATA_XSpeed,y			; |
		STA $AE,x				;/
		LDA $3330,x
		AND #$04
		BEQ .ApplySpeed
		LDA #$10
		STA $9E,x

		.ApplySpeed
		LDA $3220,x : PHA			;\ Preserve old Xcoords
		LDA $3250,x : PHA			;/

		JSL $01802A				; > Apply speed

		PLA : STA $01				;\ Restore old Xcoords
		PLA : STA $00				;/
		LDA $3220,x				;\
		SEC : SBC $00				; |
		STA $3290,x				; | Calculate Xmovement this frame
		LDA $3250,x				; |
		SBC $01					; |
		STA $32A0,x				;/

		LDA $3330,x
		AND #$03
		BEQ .NoTurn
		LDA $3320,x
		EOR #$01
		STA $3320,x

		.NoTurn


	INTERACTION:

		STZ $3280,x				; > Wipe cargo flag
		JSL $018032				; > Interact with other sprites

		JSL $03B664				; > Get P1 clipping
		BIT $BE,x
		BPL $03 : JMP .LoseCover1

		JSR HITBOX_TRAY
		JSL $03B72B
		BCS .Tray1
		STZ $3340,x
		JMP .NoCover1


		.Tray1
		BIT !MarioYSpeed
		BPL $03 : JMP .NoCover1
		LDA #$03 : STA $7471
		STZ !MarioYSpeed
		LDA #$04 : TSB $77
		LDA $3210,x
		SEC : SBC #$1D
		STA $96
		LDA $3240,x
		SBC #$00
		STA $97

		LDA $94
		CLC : ADC $3290,x
		STA $94
		LDA $95
		ADC $32A0,x
		STA $95

		LDA $32B0,x
		BEQ .NoMush1
		LDA #$0A : STA !SPC1
		LDA $19
		BNE +
		INC $19
		BRA ++
	+	LDA $6DC2
		BNE ++
		LDA #$01 : STA $6DC2
	++	STZ $32B0,x				; > Remove mushroom

		.NoMush1
		LDA $3340,x
		BNE +
		LDA $94
		CMP $3220,x
		LDA $95
		SBC $3250,x
		REP #$20
		BCC .Right1

		.Left1
		DEC $94
		BRA ++

		.Right1
		INC $94
	++	SEP #$20

	+	INC $3280,x
		LDA #$01 : STA $3340,x
		JMP .NoBody1


		.LoseCover1
		JSR HITBOX_COVER			; > Get cover hitbox
		JSL $03B72B				; > Check for contact
		BCC .NoCover1

		LDA #$02				;\ Spin jump on spiky enemy
		STA !SPC1				;/
		LDA $BE,x				;\
		AND.b #$80^$FF				; | Remove cover
		ORA #$40				; | > Keep tray
		STA $BE,x				;/
		JSL $01AB99				;\ P1 stuff
		JSL $01AA33				;/
		LDA #$0B : STA !SpriteAnimIndex		;\ Carry mushroom animation
		STZ !SpriteAnimTimer			;/
		LDA #$01 : STA $32B0,x			; > Carry mushroom flag

		.NoCover1

		LDA $BE,x
		BEQ +
		JSR HITBOX_BODY_SQUISHED
		BRA ++

	+	JSR HITBOX_BODY				; > Get body hitbox
	++	JSL $03B664				; > Get P1 clipping
		JSL $03B72B				; > Check for contact
		BCC .NoBody1
		LDA $7490
		BEQ .NoStar
		JSR SPRITE_STAR

		.NoStar
		LDA $32E0,x
		BNE .NoBody1
		LDA #$08
		STA $32E0,x
		LDA !MarioYSpeed
		CMP #$10
		BMI .HurtP1
		LDA $BE,x			;\ Can't jump on Goomba through tray
		BNE .NoBody1			;/

		JSR SPRITE_POINTS		; Give points
		JSL $01AA33			; Give Mario some bounce
		JSL $01AB99			; Display contact GFX
		LDA $740D
		ORA $787A
		BEQ .NoSpinKill
		JSR SPRITE_SPINKILL
		PLB
		RTL

		.NoSpinKill
		LDA #$02 : STA $3230,x
		BRA .NoBody1

		.HurtP1
		JSL $00F5B7

		.NoBody1


	GRAPHICS:

		LDA $3280,x
		BEQ .NoCargo

		.Cargo
		LDA !SpriteAnimIndex
		CMP #$0D : BCS .ProcessAnim
		LDA #$0D : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .ProcessAnim

		.NoCargo
		LDA !SpriteAnimIndex
		CMP #$0D : BCC .ProcessAnim
		LDA #$07 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w .AnimIdle+2,y
		BNE .SameAnim

		.NewAnim
		LDA .AnimIdle+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA.w .AnimIdle+0,y : STA $04
		LDA.w .AnimIdle+1,y : STA $05
		JSR LOAD_PSUEDO_DYNAMIC
		PLB
		RTL



	.AnimIdle
		dw .TM_Idle : db $FF,$00		; 00
	.AnimWalk
		dw .TM_Walk00 : db $08,$02		; 01
		dw .TM_Walk01 : db $08,$03		; 02
		dw .TM_Walk00 : db $08,$04		; 03
		dw .TM_Walk02 : db $08,$01		; 04
	.AnimCarry
		dw .TM_Carry00 : db $0C,$06		; 05
		dw .TM_Carry01 : db $0C,$05		; 06
	.AnimTrayLight
		dw .TM_TrayLight00 : db $08,$08		; 07
		dw .TM_TrayLight01 : db $08,$09		; 08
		dw .TM_TrayLight00 : db $08,$0A		; 09
		dw .TM_TrayLight02 : db $08,$07		; 0A
	.AnimTrayMush
		dw .TM_TrayMush00 : db $0C,$0C		; 0B
		dw .TM_TrayMush01 : db $0C,$0B		; 0C
	.AnimTrayHeavy
		dw .TM_TrayHeavy00 : db $0C,$0E		; 0D
		dw .TM_TrayHeavy01 : db $0C,$0D		; 0E


	.TM_Idle
		dw $0004
		db $29,$00,$00,$00
	.TM_Walk00
		dw $0004
		db $29,$00,$00,$00
	.TM_Walk01
		dw $0004
		db $29,$00,$00,$02
	.TM_Walk02
		dw $0004
		db $29,$00,$00,$04

	.TM_Carry00
		dw $0018
		db $29,$FC,$00,$06
		db $29,$04,$00,$07
		db $23,$F8,$F3,$0C
		db $23,$08,$F3,$0E
		db $23,$F8,$03,$2C
		db $23,$08,$03,$2E
	.TM_Carry01
		dw $0018
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $23,$F9,$F3,$0C
		db $23,$09,$F3,$0E
		db $23,$F9,$03,$2C
		db $23,$09,$03,$2E

	.TM_TrayLight00
		dw $000C
		db $29,$00,$00,$00
		db $23,$F8,$FD,$2C
		db $23,$08,$FD,$2E
	.TM_TrayLight01
		dw $000C
		db $29,$00,$00,$02
		db $23,$F8,$FE,$2C
		db $23,$08,$FE,$2E
	.TM_TrayLight02
		dw $000C
		db $29,$00,$00,$04
		db $23,$F8,$FD,$2C
		db $23,$08,$FD,$2E

	.TM_TrayMush00
		dw $0014
		db $29,$FC,$00,$06
		db $29,$04,$00,$07
		db $23,$F8,$03,$2C
		db $23,$08,$03,$2E
		db $2C,$00,$F4,$C4
	.TM_TrayMush01
		dw $0014
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $23,$F9,$03,$2C
		db $23,$09,$03,$2E
		db $2C,$01,$F4,$C4

	.TM_TrayHeavy00
		dw $0010
		db $29,$FC,$00,$06
		db $29,$04,$00,$07
		db $23,$F8,$03,$2C
		db $23,$08,$03,$2E
	.TM_TrayHeavy01
		dw $0010
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $23,$F9,$03,$2C
		db $23,$09,$03,$2E


	HITBOX:
		.BODY
		LDA $3220,x				;\
		CLC : ADC #$02				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		ADC #$00				; |
		STA $0A					;/
		LDA #$0C				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		CLC : ADC #$02				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		ADC #$00				; |
		STA $0B					;/
		LDA #$0E				;\ Hitbox height
		STA $07					;/
		RTS

		.BODY_SQUISHED
		LDA $3220,x				;\
		CLC : ADC #$02				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		ADC #$00				; |
		STA $0A					;/
		LDA #$0C				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		CLC : ADC #$06				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		ADC #$00				; |
		STA $0B					;/
		LDA #$0A				;\ Hitbox height
		STA $07					;/
		RTS

		.COVER
		LDA $3220,x				;\
		SEC : SBC #$06				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		SBC #$00				; |
		STA $0A					;/
		LDA #$1C				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		SEC : SBC #$10				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		SBC #$00				; |
		STA $0B					;/
		LDA #$0E				;\ Hitbox height
		STA $07					;/
		RTS

		.TRAY
		LDA $3220,x				;\
		SEC : SBC #$06				; |
		STA $04					; | Hitbox xpos
		LDA $3250,x				; |
		SBC #$00				; |
		STA $0A					;/
		LDA #$1C				;\ Hitbox width
		STA $06					;/
		LDA $3210,x				;\
		CLC : ADC #$03				; |
		STA $05					; | Hitbox ypos
		LDA $3240,x				; |
		ADC #$00				; |
		STA $0B					;/
		LDA #$04				;\ Hitbox height
		STA $07					;/
		RTS


	namespace off





