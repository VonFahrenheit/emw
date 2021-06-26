GoombaSlave:

	namespace GoombaSlave

; $BE,x		Tray status
;		CT-iiiii
;		C - cover
;		T - tray
;		i - index of carried sprite + 1
; $3280,x	player cargo flag
;
; !ExtraProp1	which sprite to spawn under the tray
; !ExtraProp2	0 = spawn vanilla sprite, 1+ = spawn custom sprite
;
;
;
; To do:
; - Have cover fall off
;
;
;
;



	INIT:
		PHB : PHK : PLB
		LDA !ExtraBits,x
		AND #$04						;\
		BEQ .NoCover						; |
		LDA #$80						; | toggle cover
		STA $BE,x						; |
		LDA #$05 : STA !SpriteAnimIndex				;/
		BRA .End

		.NoCover
		LDA #$07 : STA !SpriteAnimIndex
		LDA #$40 : STA $BE,x

	; look for a sprite on top of this one
		LDY #$0F
	-	LDA $3220,x						;\ must have same X coord
		CMP $3220,y : BNE +					;/
		LDA $3210,x						;\
		SEC : SBC #$10						; | must be exactly 0x10 px above
		CMP $3210,y : BNE +					;/
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
		LDA $00 : STA $BE,x					; set tray value


		LDA $3480,x						;\
		ORA #$10						; | disable contact turn
		STA $3480,x						;/
		BRA .End
	+	DEY : BPL -

		.End
		PLB
		RTL


	MAIN:
		PHB : PHK : PLB
		JSL SPRITE_OFF_SCREEN

		LDA $9D : BEQ INTERACTION_COVER
		JMP GRAPHICS


	INTERACTION_COVER:
	;	JSL $018032						; > interact with other sprites
		BIT $BE,x : BMI .ProcessCover				;\
	-	JMP .NoCover						; |
		.ProcessCover						; |
		JSR HITBOX_COVER					; | get cover hitbox
		JSL P2Attack : BCS .LoseCover				; | check for hitbox contact
		SEC : JSL !PlayerClipping				; | check for contact
		BCC -							;/
		LSR A : BCC .P2						;\
	.P1	PHA							; |
		LDY #$00 : JSL P2Bounce					; |
		PLA							; | cover interact with player
	.P2	LSR A : BCC .LoseCover					; |
		LDY #$80 : JSL P2Bounce					; |
		.LoseCover						;/

		LDA $3220,x						;\
		SEC : SBC #$08						; |
		STA $00							; |
		LDA $3250,x						; |
		SBC #$00						; |
		STA $01							; |
		LDA $3210,x						; |
		SEC : SBC #$0C						; |
		STA $02							; |
		LDA $3240,x						; | set up parameters for particles
		SBC #$00						; |
		STA $03							; |
		LDA !SpriteTile,x					; |
		CLC : ADC #$0C						; |
		STA $04							; |
		LDA !SpriteProp,x					; |
		ORA $33C0,x						; |
		ORA #$B0						; |
		STA $05							;/

		PHB							;\
		JSL !GetParticleIndex					; |
		LDA $00 : STA !Particle_XLo,x				; |
		LDA $02 : STA !Particle_YLo,x				; |
		LDA $04 : STA !Particle_Tile,x				; |
		LDA #$FD80 : STA !Particle_YSpeed,x			; | spawn particle 1
		SEP #$20						; |
		LDA #!prt_basic : STA !Particle_Type,x			; |
		LDA #$02 : STA !Particle_Layer,x			; |
		LDA #$FF : STA !Particle_Timer,x			; |
		LDA #$18 : STA !Particle_YAcc,x				;/
		JSL !GetParticleIndex					;\
		LDA $00							; |
		CLC : ADC #$0010					; |
		STA !Particle_XLo,x					; |
		LDA $02 : STA !Particle_YLo,x				; |
		LDA $04							; |
		INC #2							; | spawn particle 2
		STA !Particle_Tile,x					; |
		LDA #$FD80 : STA !Particle_YSpeed,x			; |
		SEP #$20						; |
		LDA #!prt_basic : STA !Particle_Type,x			; |
		LDA #$02 : STA !Particle_Layer,x			; |
		LDA #$FF : STA !Particle_Timer,x			; |
		LDA #$18 : STA !Particle_YAcc,x				; |
		PLB							;/

		SEP #$10						; index 8-bit
		LDX !SpriteIndex					; X = sprite index

		LDA #$02 : STA !SPC1					; contact SFX
		STZ $00							;\
		LDA #$F0 : STA $01					; |
		LDA !ExtraProp2,x					; |
		CLC							; |
		AND #$3F						; | spawn revealed sprite
		BEQ $01 : SEC						; |
		LDA !ExtraProp1,x					; |
		JSL SpawnSprite						; |
		CPY #$FF : BEQ .NoCover					;/
		LDA #$20						;\
		STA !SpriteDisP1,y					; | don't let sprite be insta-gibbed
		STA !SpriteDisP2,y					;/
		TYA							;\
		INC A							; |
		ORA #$40						; |
		STA $BE,x						; | if a sprite could be spawned successfully, carry it
		LDA #$0B : STA !SpriteAnimIndex				; |
		STZ !SpriteAnimTimer					; |
		.NoCover						;/


	GRAPHICS:

		LDA $BE,x : BMI .NoSmushCarry
		CMP #$41 : BCS .Cargo
		.NoSmushCarry

		LDA $3280,x : BEQ .NoCargo

		.Cargo
		LDA !SpriteAnimIndex
		CMP #$0B : BCS .ProcessAnim
		LDA #$0B : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .ProcessAnim
		.NoCargo

		LDA !SpriteAnimIndex
		CMP #$0B : BCC .ProcessAnim
		LDA #$07 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer

		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim

		.NewAnim : LDA ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w ANIM+0,y : STA $00
		LDA.w #!BigRAM : STA $04
		LDA ($00)
		STA !BigRAM+0
		INC $00
		INC $00
		LDY #$00
		SEP #$20
	-	LDA ($00),y : BNE +
		LDA #$20
	+	ORA !SpriteProp,x
		ORA $33C0,x
		STA !BigRAM+2,y
		INY
		LDA ($00),y : STA !BigRAM+2,y
		INY
		LDA ($00),y : STA !BigRAM+2,y
		INY
		LDA ($00),y
		CLC : ADC !SpriteTile,x
		STA !BigRAM+2,y
		INY
		CPY !BigRAM+0 : BNE -

		JSL LOAD_TILEMAP					; different palettes on goomba and tray, yo

		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		PLB
		RTL

	DATA:
		.XSpeed
		db $10,$F0
		db $08,$F8

		.XAdjust
		db $01,$FF
		db $FF,$01



	PHYSICS:
		LDY #$0F						; If this sprite is carried and using a heavy tray, remove it
	-	LDA !NewSpriteNum,y
		CMP #$01 : BNE +
		LDA !ExtraBits,y
		AND #!CustomBit : BEQ +
		LDA.w $BE,y
		AND #$1F
		DEC A
		CMP !SpriteIndex : BNE +
		LDA $BE,x : BPL +
		STZ $BE,x
		LDA #$01 : STA !SpriteAnimIndex
	+	DEY : BPL -

		LDY $3320,x						;\
		LDA $BE,x : BMI +					; |
		CMP #$41 : BCS +					; |
		LDA $3280,x						; | walk slower with cargo
		BEQ $02							; |
	+	INY #2							; |
		LDA.w DATA_XSpeed,y : STA !SpriteXSpeed,x		;/
		LDA $3330,x
		AND #$04
		BEQ .ApplySpeed
		LDA #$10 : STA !SpriteYSpeed,x

		.ApplySpeed
		JSL !SpriteApplySpeed					; > apply speed

		LDA $BE,x : BMI .NoCarried
		AND #$1F : BEQ .NoCarried
		DEC A
		TAY
		LDA $3230,y						;\
		CMP #$01 : BEQ +					; | state must be 01 or 08
		CMP #$08 : BNE ++					;/
	+	LDA.w !SpriteYSpeed,y : BPL +				;\
		CMP #$FD : BCS +					; |
	++	LDA $BE,x						; | let it go if invalid state
		AND.b #$1F^$FF						; |
		STA $BE,x						; |
		BRA .NoCarried						;/

	+	LDA $3320,x : STA $3320,y				; face same direction

		LDA.w !SpriteYSpeed,y : BPL .CarrySetCoord		; let carried sprite jump off with upwards speed
		.JumpingOff						;\
		LDA $BE,x						; |
		AND #$40						; |
		STA $BE,x						; |
		BRA .NoCarried						;/

		.CarrySetCoord
		LDA #$02 : STA !SpriteStasis,y				; carried sprite has stasis
		JSL SPRITE_A_SPRITE_B_COORDS				;\
		LDA #$10 : STA $00					; |
		LDA !SpriteAnimIndex					; |
		CMP #$0B : BCC +					; |
		LDA #$0C : STA $00					; |
	+	LDA $3210,x						; | coords of carried sprite
		SEC : SBC $00						; |
		STA $3210,y						; |
		LDA $3240,x						; |
		SBC #$00						; |
		STA $3240,y						; |
		.NoCarried						;/

		LDA $3330,x						;\
		AND #$03 : BEQ .NoTurn					; |
		LDA $3320,x						; | turn at walls
		EOR #$01						; |
		STA $3320,x						; |
		.NoTurn							;/

	INTERACTION_BODY:
		LDA !SpriteAnimIndex					;\
		CMP #$05 : BEQ .Squished				; | check for squished tilemaps
		CMP #$06 : BEQ .Squished				; |
		CMP #$0B : BCS .Squished				;/
		JSR HITBOX_BODY : BRA .BodyCheck			; normal body hitbox
		.Squished						;\ squished body hitbox
		JSR HITBOX_BODY_SQUISHED				;/
		.BodyCheck						;\ check for player contact
		SEC : JSL !PlayerClipping : BCC .Tray			;/
		LSR A : BCC .P2						;\
	.P1	PHA							; | interact player 1
		LDY #$00 : JSR Interact					; |
		PLA							;/
	.P2	LSR A : BCC .Tray					;\ interact player 1
		LDY #$80 : JSR Interact					;/
		.Tray							;\
		JSL P2Attack : BCC .NoContact				; |
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x	; | player hitbox interaction
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x	; |
		LDA #$02 : STA $3230,x					; |
		.NoContact						;/



	INTERACTION_TRAY:
		STZ $3280,x						; clear player cargo flag
		BIT $BE,x : BVC .NoPlatform				; only platform if sprite has a tray
		JSR HITBOX_TRAY						;\ platform box
		LDA #$04 : JSL OutputPlatformBox			;/
		SEC : JSL !PlayerClipping : BCC .NoPlatform		;\
		LSR A : BCC .P2						; |
	.P1	XBA							; |
		LDA !P2YSpeed-$80 : BMI +				; |
		LDA !P2BlockedLayer-$80					; |
		AND #$04 : BEQ .Squish					; |
	+	XBA							; |
	.P2	LSR A : BCC .NoPlatform					; | set cargo flag and animation
		LDA !P2YSpeed : BMI .NoPlatform				; |
		LDA !P2BlockedLayer					; |
		AND #$04 : BNE .NoPlatform				; |
	.Squish	LDA #$01 : STA $3280,x					; |
		LDA !SpriteAnimIndex					; |
		CMP #$0B : BCS .NoPlatform				; |
		LDA #$0B : STA !SpriteAnimIndex				; |
		STZ !SpriteAnimTimer					; |
		.NoPlatform						;/

		PLB
		RTL


	Interact:
		LDA !P2BlockedLayer-$80,y				;\
		AND #$04 : BNE .HurtPlayer				; |
		BIT $BE,x : BVS .Return					; | hurt player if player is on the ground
		JSL P2Bounce						; |
		LDA #$02 : STA $3230,x					; |
	.Return	RTS							;/
		.HurtPlayer						;\
		TYA							; |
		ASL A							; |
		ROL A							; | if player touches sprite on ground, they take damage
		AND #$01						; |
		INC A							; |
		JSL !HurtPlayers					; |
		RTS							;/




	ANIM:
	.Idle
		dw .TM_Idle : db $FF,$00		; 00
	.Walk
		dw .TM_Walk00 : db $08,$02		; 01
		dw .TM_Walk01 : db $08,$03		; 02
		dw .TM_Walk00 : db $08,$04		; 03
		dw .TM_Walk02 : db $08,$01		; 04
	.Carry
		dw .TM_Carry00 : db $0C,$06		; 05
		dw .TM_Carry01 : db $0C,$05		; 06
	.TrayLight
		dw .TM_TrayLight00 : db $08,$08		; 07
		dw .TM_TrayLight01 : db $08,$09		; 08
		dw .TM_TrayLight00 : db $08,$0A		; 09
		dw .TM_TrayLight02 : db $08,$07		; 0A
	.TrayHeavy
		dw .TM_TrayHeavy00 : db $0C,$0C		; 0B
		dw .TM_TrayHeavy01 : db $0C,$0B		; 0C


	.TM_Idle
		dw $0004
		db $30,$00,$00,$00
	.TM_Walk00
		dw $0004
		db $30,$00,$00,$00
	.TM_Walk01
		dw $0004
		db $30,$00,$00,$02
	.TM_Walk02
		dw $0004
		db $30,$00,$00,$04

	.TM_Carry00
		dw $0018
		db $30,$FC,$00,$06
		db $30,$04,$00,$07
		db $30,$F8,$F3,$0C
		db $30,$08,$F3,$0E
		db $30,$F8,$03,$20
		db $30,$08,$03,$22
	.TM_Carry01
		dw $0018
		db $30,$FC,$00,$09
		db $30,$04,$00,$0A
		db $30,$F9,$F3,$0C
		db $30,$09,$F3,$0E
		db $30,$F9,$03,$20
		db $30,$09,$03,$22

	.TM_TrayLight00
		dw $000C
		db $30,$00,$00,$00
		db $30,$F8,$FD,$20
		db $30,$08,$FD,$22
	.TM_TrayLight01
		dw $000C
		db $30,$00,$00,$02
		db $30,$F8,$FE,$20
		db $30,$08,$FE,$22
	.TM_TrayLight02
		dw $000C
		db $30,$00,$00,$04
		db $30,$F8,$FD,$20
		db $30,$08,$FD,$22

	.TM_TrayHeavy00
		dw $0010
		db $30,$FC,$00,$06
		db $30,$04,$00,$07
		db $30,$F8,$03,$20
		db $30,$08,$03,$22
	.TM_TrayHeavy01
		dw $0010
		db $30,$FC,$00,$09
		db $30,$04,$00,$0A
		db $30,$F9,$03,$20
		db $30,$09,$03,$22


	HITBOX:
		.BODY
		LDA $3220,x						;\
		CLC : ADC #$02						; |
		STA $04							; | hitbox xpos
		LDA $3250,x						; |
		ADC #$00						; |
		STA $0A							;/
		LDA #$0C : STA $06					; hitbox width
		LDA $3210,x						;\
		CLC : ADC #$02						; |
		STA $05							; | hitbox ypos
		LDA $3240,x						; |
		ADC #$00						; |
		STA $0B							;/
		LDA #$0E : STA $07					; hitbox height
		RTS							; return

		.BODY_SQUISHED
		LDA $3220,x						;\
		CLC : ADC #$02						; |
		STA $04							; | hitbox xpos
		LDA $3250,x						; |
		ADC #$00						; |
		STA $0A							;/
		LDA #$0C : STA $06					; hitbox width
		LDA $3210,x						;\
		CLC : ADC #$06						; |
		STA $05							; | hitbox ypos
		LDA $3240,x						; |
		ADC #$00						; |
		STA $0B							;/
		LDA #$0A : STA $07					; hitbox height
		RTS							; return

		.COVER
		LDA $3220,x						;\
		SEC : SBC #$06						; |
		STA $04							; | hitbox xpos
		LDA $3250,x						; |
		SBC #$00						; |
		STA $0A							;/
		LDA #$1C : STA $06					; hitbox width
		LDA $3210,x						;\
		SEC : SBC #$10						; |
		STA $05							; | hitbox ypos
		LDA $3240,x						; |
		SBC #$00						; |
		STA $0B							;/
		LDA #$0E  : STA $07					; hitbox height
		RTS							; return

		.TRAY
		LDA $3220,x						;\
		SEC : SBC #$06						; |
		STA $04							; | hitbox xpos
		LDA $3250,x						; |
		SBC #$00						; |
		STA $0A							;/
		LDA #$1C : STA $06					; hitbox width
		LDA $3210,x						;\
		CLC : ADC #$03						; |
		STA $05							; | hitbox ypos on frames B+
		LDA $3240,x						; |
		ADC #$00						; |
		STA $0B							;/
		LDA #$08 : STA $07					; hitbox height
		RTS							; return



	namespace off





