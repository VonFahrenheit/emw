DancerKoopa:

	namespace DancerKoopa

	INIT:
		PHB : PHK : PLB				; > Start of bank wrapper

		LDA $3220,x : STA $3290,x		; Back up starting X coord

		LDA !RNG				;\
		AND #$01				; | Start with a random move
		STA $BE,x				;/

		LDA !RNG				;\
		AND #$02				; | Start in a random direction
		LSR A					; |
		STA $3320,x				;/

		LDA !ExtraBits,x			;\
		AND #$04 : BNE .Return			; |
		LDA $33C0,x				; | Add 1 to palette if extra bit is clear
		ORA #$02				; |
		STA $33C0,x				;/

		.Return
		PLB					; > End of bank wrapper
		RTL


; $BE,x = state
; 00 = walk out
; 01 = jump out
; 02 = walk in
; 03 = jump in


	MAIN:
		PHB : PHK : PLB				; > Start of bank wrapper

		JSL SPRITE_OFF_SCREEN
		LDA $3230,x
		CMP #$08 : BEQ .Main
		JMP Graphics

		.Main
		LDA !SpriteAnimIndex
		CMP #$07 : BCC +
		LDA $14
		AND #$7F : BEQ ++
		LDY $3320,x
		JMP .Shared
	++	STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		JMP ++++


	+	LDA $BE,x				;\
	---	ASL A					; | Go to pointer
		TAX					; |
		JMP (.Ptr,x)				;/

		.Ptr
		dw .WalkOut
		dw .Jump
		dw .WalkIn


	.XSpeed
		db $F0,$10
		db $DC,$24


	.WalkOut
		LDX !SpriteIndex			; Restore X
		LDA $BE,x : BMI +			;\ Handle init
		ORA #$80 : STA $BE,x			;/
		LDA #$1A : STA $32D0,x			; Walk for 16 frames
	+	LDA $32D0,x : BNE +			; See if timer is up
	--	LDA $3320,x				;\
		EOR #$01				; |
		STA $3320,x				; |
		LDA !RNG				; | Turn around, get a random next move, and loop
		AND #$01				; |
		INC A					; |
		STA $BE,x				; |
		BRA ---					;/

	-
	+	LDY $3320,x				;\ Walk speed
		BRA .Shared				;/

	.Jump
		LDX !SpriteIndex			; Restore X
		LDA $BE,x : BMI +			;\ Handle init
		ORA #$80 : STA $BE,x			;/
		LDA #$05 : STA !SpriteAnimIndex		;\ Set anim
		STZ !SpriteAnimTimer			;/
		STZ $3260,x				;\ Clear fraction bits
		STZ $3270,x				;/
		STZ $3330,x				; Clear blocked status
		LDA #$E0 : STA !SpriteYSpeed,x			;\ Set Y speed
		BRA ++					;/
	+	LDA $3330,x				;\ See if landed
		AND #$04 : BEQ ++			;/
		LDA $3220,x				;\
		SEC : SBC $3290,x			; |
		INC A					; | If landing near starting area, fully reset movement
		CMP #$03 : BCC +++			; |
		BRA --					;/

	++	LDY $3320,x				;\
		INY #2					; | Jump speed
		BRA .Shared				;/

	.WalkIn
		LDX !SpriteIndex			; Restore X
		LDY #$00
		LDA $3220,x
		CMP $3290,x
		BPL $01 : INY
		TYA : STA $3320,x

		LDA $3220,x				;\
		CMP $3290,x				; | Just walk if not at starting point
		BNE -					;/



	+++	LDA $14					;\
		AND #$7F : BEQ ++++			; |
		AND #$0F : STA !SpriteAnimTimer		; | Make sure all dancers are synchronized
		LDA #$07 : STA !SpriteAnimIndex		; |
		BRA .Shared				;/

	++++	LDA !RNG				;\ Get random direction
		AND #$01 : STA $3320,x			;/
		LDA !RNG				;\
		AND #$02				; | Get new move
		LSR A					; |
		STA $BE,x				;/


	.Shared
		LDA .XSpeed,y : STA !SpriteXSpeed,x	; X speed

	Physics:
		LDA $3330,x
		AND #$04
		BEQ +
		LDA #$10 : STA !SpriteYSpeed,x
		+

		LDA !SpriteAnimIndex			;\
		CMP #$05 : BEQ Interaction		; |
	+	CMP #$07 : BCC .Normal			;/

		.Clear
		STZ !SpriteYSpeed,x
		STZ !SpriteXSpeed,x

		.Normal
		JSL !SpriteApplySpeed

	Interaction:
		JSL !GetSpriteClipping04		;\
		SEC : JSL !PlayerClipping		; |
		BCC .NoContact				; |
		LSR A : BCC .P2				; |
	.P1	LDY #$00				; |
		PHA					; | check for player contact
		LDA !P2Character-$80,y			; |
		CMP #$02 : BNE +			; |
		LDA #$01 : STA !P2SenkuSmash-$80,y	; |
	+	LDA !SpriteDisP1,x : BNE $03		; |
		JSR Interact				; |
		PLA					; |
	.P2	LSR A : BCC .NoContact			; |
		LDA !P2Character-$80,y			; |
		CMP #$02 : BNE +			; |
		LDA #$01 : STA !P2SenkuSmash-$80,y	; |
	+	LDA !SpriteDisP2,x : BNE .NoContact	; |
		LDY #$80				; |
		JSR Interact				; |
		.NoContact				;/

		JSL P2Attack				;\
		BCC .NoHit				; |
	;	LSR A : BCC .NoHit			; | Check for hitbox contact
		JSR Interact_TakeDamage			; |
		.NoHit					;/

		LDA $3200,x				;\
		CMP #$36 : BEQ +			; |
		PLB					; | Stop right here if sprite is dead
		RTL					; |
		+					;/



	Graphics:
		LDA $3230,x
		CMP #$02 : BNE .NotDead
		LDA #$09 : BRA .SetAnim
		.NotDead

		LDA $BE,x
		LSR A : BCS .ProcessAnim

		.Walking
		LDA !SpriteAnimIndex
		CMP #$07 : BCS .ProcessAnim
		CMP #$04 : BCC .ProcessAnim
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		BRA .ProcessAnim


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
		.SetAnim
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w ANIM+0,y : STA $04
		SEP #$20


		LDA !SpriteAnimIndex
		CMP #$05 : BEQ .Shell
		CMP #$09 : BNE .NotShell

		.Shell
		LDA !GFX_Shell : STA $00
		ASL A
		ROL A
		AND #$01
		STA !SpriteProp,x
		LDA $00
		AND #$F0 : TRB $00
		ASL A
		ORA $00
		STA !SpriteTile,x
		.NotShell

		JSL LOAD_PSUEDO_DYNAMIC			; Draw GFX


		PLB					; > End of bank wrapper
		RTL					; > Return




	Interact:
		LDA #$10 : JSL DontInteract		; set don't interact
		LDA !SpriteYSpeed,x
		CMP !P2YSpeed-$80,y : BMI .HurtSprite

		.HurtPlayer
		TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
		RTS

		.HurtSprite
		JSL StompSound
		JSR .TakeDamage
		LDA !P2Crush-$80,y : BEQ .Stomp
		.Crush
		JSL SPRITE_SPINKILL
		.Stomp
		JSL P2Bounce				; bounce
		.Return
		RTS

		.TakeDamage
		PHY
		LDY #$07				;\
		LDA !NewSpriteNum,x			; |
		CMP #$13				; |
		BNE $02 : DEY #2			; |
		LDA !ExtraBits,x			; |
		PHA					; |
		AND #$04				; | Change sprite number to proper koopa color
		BNE $01 : DEY				; |
		PLA					; |
		AND.b #$0C^$FF				; |
		STA !ExtraBits,x			; |
		TYA : STA $3200,x			; |
		LDA #$09 : STA $3230,x			; |
		STZ !NewSpriteNum,x			;/
		JSL !ResetSprite			;\ Reset stuff
		LDA #$02 : STA $32D0,x			;/
		PLY
		LDA #$10 : JSL DontInteract
		RTS					; > Return



	KoopaX:
		db $3F,$C0


	ANIM:
	.Shuffle
		dw .ShuffleTM0 : db $06,$01		; 00
		dw .ShuffleTM1 : db $06,$02		; 01
		dw .ShuffleTM0 : db $06,$03		; 02
		dw .ShuffleTM2 : db $06,$00		; 03
	.Pose
		dw .PoseTM0 : db $FF,$04		; 04
	.Jump
		dw .JumpTM : db $10,$06			; 05
		dw .PoseTM0 : db $FF,$06		; 06
	.Dance
		dw .PoseTM0 : db $10,$08		; 07
		dw .PoseTM1 : db $10,$07		; 08
	.Dead
		dw .DeadTM : db $FF,$09			; 09



	.ShuffleTM0
		dw $0008
		db $32,$00,$F0,$00
		db $32,$00,$00,$08
	.ShuffleTM1
		dw $0008
		db $32,$00,$F1,$02
		db $32,$00,$01,$0A
	.ShuffleTM2
		dw $0008
		db $32,$00,$F1,$04
		db $32,$00,$01,$0C

	.JumpTM
		dw $0004
		db $32,$00,$01,$00

	.PoseTM0
		dw $0008
		db $32,$00,$F0,$06
		db $32,$00,$00,$0E
	.PoseTM1
		dw $0008
		db $72,$00,$F0,$06
		db $72,$00,$00,$0E

	.DeadTM
		dw $0004
		db $B2,$00,$01,$00


	namespace off





