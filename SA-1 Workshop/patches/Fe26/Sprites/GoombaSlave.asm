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
		LDA #$07 : STA !SpriteAnimIndex
		LDA #$40 : STA $BE,x

	; look for a sprite on top of this one
		LDY #$0F
	-	LDA $3220,x				;\
		CMP $3220,y				; | Must have same X coord
		BNE +					;/
		LDA $3210,x				;\
		SEC : SBC #$10				; | Must be exactly 0x10 px above
		CMP $3210,y				; |
		BNE +					;/
		TYA
		INC A
		STA $00
		LDA !NewSpriteNum,y
		CMP #$01 : BNE .NoTotem
		LDA !ExtraBits,y
		AND #!CustomBit : BEQ .NoTotem
		LDA #$01 : STA !SpriteAnimIndex
		BRA .Totem

		.NoTotem
		LDA #$40 : TSB $00

		.Totem
		LDA $00					;\ Set tray value
		STA $BE,x				;/


		LDA $3480,x				;\
		ORA #$10				; | Disable contact turn
		STA $3480,x				;/
		BRA .End
	+	DEY : BPL -

		.End
		PLB
		RTL

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
; $3290,x	Used for moving player
; $32A0,x	Used for moving player
; $32B0,x	Carrying Mushroom flag
; $3340,x	Carried player last frame flag
;
; $3350,x	Tray tile
;
; $35D0,x	Xlo memory
; $35E0,x	Xhi memory
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

		LDY #$0F				; If this sprite is carried and using a heavy tray, remove it
	-	LDA !NewSpriteNum,y
		CMP #$01 : BNE +
		LDA !ExtraBits,y
		AND #!CustomBit : BEQ +
		LDA $30BE,y
		AND #$1F
		DEC A
		CMP !SpriteIndex
		BNE +
		LDA $BE,x : BPL +
		STZ $BE,x
		LDA #$01 : STA !SpriteAnimIndex
	+	DEY : BPL -



		LDA $35D0,x : PHA			;\ X pos last frame
		LDA $35E0,x : PHA			;/
		LDA $3220,x : STA $35D0,x		;\ Use this next frame
		LDA $3250,x : STA $35E0,x		;/

		LDY $3320,x				;\
		LDA $BE,x : BMI +			; |
		CMP #$41 : BCS +			; |
		LDA $3280,x				; |
		ORA $32B0,x				; | Walk slower with cargo
		BEQ $02					; |
	+	INY #2					; |
		LDA.w DATA_XSpeed,y			; |
		STA $AE,x				;/
		LDA $3330,x
		AND #$04
		BEQ .ApplySpeed
		LDA #$10 : STA $9E,x

		.ApplySpeed
		JSL $01802A				; > Apply speed


		PLA : STA $01				;\ Restore old Xcoords
		PLA : STA $00				;/

		LDA $35D0,x				;\
		SEC : SBC $00				; |
		STA $3290,x				; | Calculate Xmovement this frame
		LDA $35E0,x				; |
		SBC $01					; |
		STA $32A0,x				;/


		LDA $BE,x : BMI .NoCarried
		AND #$1F : BEQ .NoCarried
		DEC A
		TAY
		LDA $3230,y				;\
		CMP #$01 : BEQ +			; | State must be 01 or 08
		CMP #$08 : BNE ++			;/
	+	LDA $309E,y : BPL +			;\
		CMP #$FD : BCS +			; |
	++	LDA $BE,x				; | Let it go if invalid state
		AND.b #$1F^$FF				; |
		STA $BE,x				; |
		BRA .NoCarried				;/

	+	LDA $3320,x : STA $3320,y		; face same direction

		JSR SPRITE_A_SPRITE_B_COORDS		; Y coords are overwritten anyway

		LDA !ExtraBits,y
		AND #!CustomBit : BNE .CustomCarry
		LDA #$FD : STA $309E,y			; carried Y speed = -3 to account for gravity on vanilla sprites
		.CustomCarry

		LDA #$10 : STA $00
		LDA !SpriteAnimIndex
		CMP #$0D : BCC +
		LDA #$0C : STA $00

	+	LDA $3210,x
		SEC : SBC $00
		STA $3210,y
		LDA $3240,x
		SBC #$00
		STA $3240,y

		.NoCarried




		LDA $3330,x				;\
		AND #$03				; |
		BEQ .NoTurn				; | Turn around at walls
		LDA $3320,x				; |
		EOR #$01				; |
		STA $3320,x				;/

		.NoTurn


	INTERACTION:

		STZ $3280,x				; > Wipe cargo flag
		JSL $018032				; > Interact with other sprites

		BIT $BE,x				;\ Highest bit means that cover is on
		BMI .LoseCover				;/
		BVC .NoCover				; Second highest bit menas that normal tray is used

		JSR HITBOX_TRAY				;\ See if tray touches any of the players
		SEC : JSL !PlayerClipping		;/
		BCS .Tray
		STZ $3340,x
		BRA .NoCover

		.Tray
		LDY #$00
		LSR A
		PHA
		BCC +
		JSR TrayInt
	+	PLA
		LDY #$80
		LSR A
		BCC .NoCover
		PEA .NoCover-1
		JMP TrayInt

		.LoseCover
		JSR HITBOX_COVER			; > Get cover hitbox
		SEC : JSL !PlayerClipping		; > Check for contact
		BCC .NoCover
		LDY #$00				;\
		LSR A					; |
		PHA					; |
		BCC $03 : JSR P2Bounce			; | Bounce player
		PLA					; |
		LDY #$80				; |
		LSR A					; |
		BCC $03 : JSR P2Bounce			;/
		LDA #$02				;\ Spin jump on spiky enemy
		STA !SPC1				;/
		LDA $BE,x				;\
		AND.b #$80^$FF				; | Remove cover
		ORA #$40				; | > Keep tray
		STA $BE,x				;/
		LDA #$0B : STA !SpriteAnimIndex		;\ Carry mushroom animation
		STZ !SpriteAnimTimer			;/
		LDA #$01 : STA $32B0,x			; > Carry mushroom flag

		.NoCover
		LDA $BE,x : BEQ +
		JSR HITBOX_BODY_SQUISHED
		BRA ++

	+	JSR HITBOX_BODY				; > Get body hitbox
	++	SEC : JSL !PlayerClipping		; > Check player contact
		BCC .NoBody
		STA $00					; > Store player contact flags
		LDA $7490 : BEQ .NoStar			;\ Star kill
		JSR SPRITE_STAR				;/

		.NoStar
		LDA $32E0,x : BNE .NoBody		;\ Interaction disable
		LDA #$08 : STA $32E0,x			;/

		LDY #$00
		LSR $00 : BCS .Touch
	-	LDY #$80
		LSR $00 : BCC .NoBody

		.Touch
		LDA #$01 : STA !P2SenkuSmash-$80,y
		LDA !P2YSpeed-$80,y
		CMP #$10 : BCC .HurtPlayer
		LDA $BE,x : BNE .NoBody			; > Can't jump on Goomba through tray
		LDA !P2Character-$80,y			;\
		BNE .NoSpinKill				; | Check for Mario spin jump
		LDA $740D				; |
		BEQ .NoSpinKill				;/
		PLB					;\ Same bank but I have an RTL on the stack
		JMP SPRITE_SPINKILL_Long		;/

		.NoSpinKill
		JSR P2Bounce				; > Bounce player yo
		LDA #$02 : STA $3230,x			; > Kill sprite yo
		LDA #$03 : STA !SPC1			; SFX
		BRA -

		.HurtPlayer
		TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
		BRA -
		.NoBody





	GRAPHICS:

	LDA !GFX_status+$07 : STA !ClaimedGFX

		LDA $BE,x : BMI .NoSmushCarry
		CMP #$41 : BCS .Cargo
		.NoSmushCarry



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
		REP #$20
		LDA.w .AnimIdle+0,y : STA $00
		LDA.w #!BigRAM : STA $04
		LDA ($00)
		STA !BigRAM+0
		INC $00
		INC $00
		LDY #$00
		SEP #$20
	-	LDA ($00),y : BNE +
		LDA #$21
		ORA !GFX_status+$09			; tray uses pal 8
	+	STA !BigRAM+2,y
		INY
		LDA ($00),y : STA !BigRAM+2,y
		INY
		LDA ($00),y : STA !BigRAM+2,y
		INY
		LDA ($00),y
		CMP #$E0 : BNE +
		LDA #$40
		BRA ++
	+	CLC : ADC !ClaimedGFX
	++	STA !BigRAM+2,y
		INY
		CPY !BigRAM+0
		BNE -

		JSR LOAD_TILEMAP
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
		db $00,$F8,$F3,$0C
		db $00,$08,$F3,$0E
		db $00,$F8,$03,$2C
		db $00,$08,$03,$2E
	.TM_Carry01
		dw $0018
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $00,$F9,$F3,$0C
		db $00,$09,$F3,$0E
		db $00,$F9,$03,$2C
		db $00,$09,$03,$2E

	.TM_TrayLight00
		dw $000C
		db $29,$00,$00,$00
		db $00,$F8,$FD,$2C
		db $00,$08,$FD,$2E
	.TM_TrayLight01
		dw $000C
		db $29,$00,$00,$02
		db $00,$F8,$FE,$2C
		db $00,$08,$FE,$2E
	.TM_TrayLight02
		dw $000C
		db $29,$00,$00,$04
		db $00,$F8,$FD,$2C
		db $00,$08,$FD,$2E

	.TM_TrayMush00
		dw $0014
		db $29,$FC,$00,$06
		db $29,$04,$00,$07
		db $00,$F8,$03,$2C
		db $00,$08,$03,$2E
		db $28,$00,$F4,$E0
	.TM_TrayMush01
		dw $0014
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $00,$F9,$03,$2C
		db $00,$09,$03,$2E
		db $28,$01,$F4,$E0

	.TM_TrayHeavy00
		dw $0010
		db $29,$FC,$00,$06
		db $29,$04,$00,$07
		db $00,$F8,$03,$2C
		db $00,$08,$03,$2E
	.TM_TrayHeavy01
		dw $0010
		db $29,$FC,$00,$09
		db $29,$04,$00,$0A
		db $00,$F9,$03,$2C
		db $00,$09,$03,$2E


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


	TrayInt:
		LDA !P2YSpeed-$80,y
		BPL .Process

		.Return
		RTS

		.Process
		LDA !P2Character-$80,y : BEQ .Mario	; > Special rules for Mario
		TXA : STA !P2SpritePlatform-$80,y	;\
		LDA $3210,x				; |
		SEC : SBC #$0D				; |
		STA !P2YPosLo-$80,y			; | Platform settings
		LDA $3240,x				; |
		SBC #$00				; |
		STA !P2YPosHi-$80,y			;/
		LDA $32A0,x : XBA			;\
		LDA $3290,x				; |
		REP #$20				; | Apply sprite movement to player
		CLC : ADC !P2XPosLo-$80,y		; |
		STA !P2XPosLo-$80,y			; |
		SEP #$20				;/
		LDA $32B0,x				;\ Check for mush
		BEQ .NoMush				;/
		LDA !P2HP-$80,y				;\
		INC A					; | Give HP
		STA !P2HP-$80,y				;/
		BRA .MushShared				; > End


		.Mario
		LDA #$03 : STA $7471			; > Mario platform type
		STZ !MarioYSpeed			;\
		LDA #$04 : TSB $77			; |
		LDA $3210,x				; |
		SEC : SBC #$1D				; | Mario Y pos
		STA $96					; |
		LDA $3240,x				; |
		SBC #$00				; |
		STA $97					;/
		LDA $94					;\
		CLC : ADC $3290,x			; |
		STA $94					; | Mario X pos
		LDA $95					; |
		ADC $32A0,x				; |
		STA $95					;/
		LDA $3340,x : BNE .MarioMush		; > Check something???
		LDA $94					;\
		CMP $3220,x				; |
		LDA $95					; | Check Mario relative direction
		SBC $3250,x				; |
		REP #$20				; |
		BCC .Right				;/
	.Left	DEC $94					;\
		BRA +					; | Move Mario 1px to the side based on relative direction
	.Right	INC $94					; |
	+	SEP #$20				;/

		.MarioMush
		LDA $32B0,x				;\ Mush check
		BEQ .NoMush				;/
		LDA $19					;\
		BNE +					; |
		INC $19					; | Mario powerup code
		BRA .MushShared				; |
	+	LDA $6DC2				; |
		BNE .MushShared				; |
		LDA #$01 : STA $6DC2			;/

		.MushShared
		STZ $32B0,x				; > Remove mushroom
		LDA #$0A : STA !SPC1			; SFX

		.NoMush
		INC $3280,x				;\ Carrying something (Player)
		LDA #$01 : STA $3340,x			;/
		PLA : PLA				;\
		CPY #$00				; | Return to fixed address
		BNE $01 : PLA				; |
		JMP INTERACTION_NoBody			;/


	namespace off





