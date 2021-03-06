

	!Temp = 0
	%def_anim(Conjurex_Walk, 4)
	%def_anim(Conjurex_Cast, 9)
	%def_anim(Conjurex_Pushback, 3)
	%def_anim(Conjurex_Hurt, 1)



	!ConjurexPushback	= $3280
	!ConjurexMask		= $3290
	!ConjurexAmmo		= $32A0
	!ConjurexMaxAmmo	= $32B0


Conjurex:

	namespace Conjurex


	INIT:
		PHB : PHK : PLB

		LDA !RNG
		AND #$1F
		STA !ConjurexMask,x

		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_Ammo,y
		STA !ConjurexMaxAmmo,x
		STA !ConjurexAmmo,x

		PLB
		RTL


	MAIN:
		PHB : PHK : PLB

		LDA $9D : BEQ .Process
		JMP GRAPHICS

		.Process

		%decreg(!ConjurexPushback)

		LDA $3230,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA #!Conjurex_Hurt : STA !SpriteAnimIndex
		STZ $32D0,x
		LDA #$02 : STA $BE,x
		JMP GRAPHICS

		.Return
		PLB
		RTL


	PHYSICS:

		.Cast
		LDA $32D0,x : BEQ ..startcast
		CMP #$40 : BNE ..noface
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA $3320,x				;/
		..noface
		JMP ..nocast
		..startcast
		LDA !RNG					;\
		LSR #2						; | wait a random number of frames
		ORA #$C0					; |
		STA $32D0,x					;/

		LDY $3320,x
		LDA DATA_CastX,y : STA $00
		LDA #$FC : STA $01
		LDA DATA_CastXSpeed,y : STA $02
		STZ $03
		SEC : LDA #$07
		JSL SpawnSprite
		CPY #$FF : BEQ ..nocast
		LDA #$10 : STA !SPC1				; cast SFX
		LDA #$08 : STA $3230,y
		LDA #$08 : STA $3300,y				; > don't interact with sprites for 8 frames
		LDA #$3C : STA $32D0,y				; > life timer (1 sec)
		LDA #$82 : STA.w $BE,y				; > behavior (line + anim)
		LDA #$03 : STA $33E0,y				; > number of frames (3)
		LDA #$05 : STA $3310,y				; > animation frequency
		LDA #$45					;\
		CLC : ADC !SpriteTile,x				; | base tile
		STA $33D0,y					;/
		LDA $33C0,x					;\
		ORA !SpriteProp,x				; | prop
		ORA #$30					; |
		STA $33C0,y					;/
		LDA #$01 : STA $3410,y				; ???

		LDY $3320,x
		LDA DATA_Recoil,y : STA !SpriteXSpeed,x
		LDA #$20 : STA !ConjurexPushback,x

		DEC !ConjurexAmmo,x
		LDA !ConjurexAmmo,x : BEQ +
		LDA #$20 : STA $32D0,x
		BRA ..nocast
	+	LDA #!Conjurex_Pushback : STA !SpriteAnimIndex
		LDA !ConjurexMaxAmmo,x : STA !ConjurexAmmo,x
		..nocast


		.Speed
		LDA !ConjurexPushback,x : BEQ ..nothurt
		LDA $3330,x
		AND #$04 : BEQ ..nospeed
		JSL AccelerateX_Friction1
		LDA !SpriteXSpeed,x
		CLC : ADC #$08
		CMP #$10 : BCC ..nospeed
		LDA $14
		AND #$03 : BNE ..nospeed
		LDY $3320,x
		LDA DATA_DustOffset,y : STA $00
		LDA #$0C : STA $01
		REP #$20
		STZ $02
		STZ $04
		LDA #$3000 : STA $06
		SEP #$20
		LDA #!prt_smoke8x8 : JSL SpawnParticle		; smoke at feet while sliding
		BRA ..nospeed
		..nothurt

		STZ !SpriteXSpeed,x
		LDA !ExtraBits,x
		AND #$04 : BNE ..nospeed
		LDA $32D0,x
		CMP #$40 : BCC ..nospeed
		LDY $3320,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..nospeed
		LDA $3220,x : PHA
		LDA $3250,x : PHA
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA $3330,x
		AND #$04 : PHA
		JSL !SpriteApplySpeed
		PLA : BEQ ..checkwall
		LDA $3330,x
		AND #$04 : BEQ ..turn
		..checkwall
		LDA $3330,x
		AND #$03 : BEQ ..noturn
		..turn
		PLA : STA $3240,x
		PLA : STA $3210,x
		PLA : STA $3250,x
		PLA : STA $3220,x
		LDA !ConjurexPushback,x : BNE ..turndone
		LDA $3320,x
		EOR #$01
		STA $3320,x
		BRA ..turndone
		..noturn
		PLA : PLA : PLA : PLA
		..turndone


	INTERACTION:

		JSL !GetSpriteClipping04

		.Body
		JSL P2Standard
		BCC ..nocontact
		BEQ ..nocontact
		JSR Hurt
		..nocontact

		.Attack
		JSL P2Attack : BCC ..nocontact
		LDA #$08 : JSL DontInteract
		LDA !P2Hitbox1XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA !P2Hitbox1YSpeed-$80,y : STA !SpriteYSpeed,x
		JSR Hurt
		..nocontact


	GRAPHICS:

		LDA !ConjurexPushback,x : BNE .HandleUpdate

		LDA !SpriteAnimIndex
		CMP #!Conjurex_Hurt : BEQ .HandleUpdate


	; cast check
		LDA $32D0,x
		CMP #$40 : BCS .NoCast
		LDA !SpriteAnimIndex
		CMP #!Conjurex_Cast : BCC +
		CMP #!Conjurex_Cast_over : BCC ++
	+	LDA #!Conjurex_Cast : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
	++	LDA $14
		AND #$03 : BNE .HandleUpdate
		JSR SpellParticles
		BRA .HandleUpdate
		.NoCast


	; stand still/walk check
		LDA !ExtraBits,x
		AND #$04 : BNE .Wait
		LDA !SpriteAnimIndex
		CMP #!Conjurex_Walk_over : BCC .HandleUpdate
		BRA .Walk

		.Wait
		LDA !SpriteAnimIndex
		CMP #!Conjurex_Walk_over : BCS .HandleUpdate

		.Walk
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer


	; standard update
		.HandleUpdate
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer

		.Draw
		LDA #$0A : STA $33C0,x
		LDA $32D0,x
		CMP #$10 : BCS ..paldone
		CMP #$08 : BCC ..paldone
		PHY
		LDA #!palset_special_flash_caster : JSL LoadPalset
		PLY
		LDX $0F
		LDA !GFX_status+$180,x
		ASL A
		LDX !SpriteIndex
		STA $33C0,x
		..paldone
		LDA $33C0,x : PHA
		LDA !ConjurexMask,x : BMI ..skipmask
		LDA $32D0,x
		CMP #$10 : BCS +
		CMP #$08 : BCS ++
	+	LDA #$04 : STA $33C0,x
	++	REP #$20
		LDA.w ANIM+0,y : STA $04
		LDA ($04) : STA !BigRAM
		LDY #$02
		LDA ($04),y : STA !BigRAM+2
		LDY #$04
		LDA ($04),y : STA !BigRAM+4
		LDA.w #!BigRAM : STA $04
		SEP #$20
		LDY !ConjurexMask,x
		LDA DATA_MaskTile,y : STA !BigRAM+5
		LDA $BE,x : BEQ ..drawmask
		JSR DropMask
		BRA ..skipmask
		..drawmask
		JSL LOAD_PSUEDO_DYNAMIC
		..skipmask
		PLA : STA $33C0,x
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		REP #$20
		LDA.w ANIM+0,y
		CLC : ADC #$0006
		STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL


	ANIM:
	; walk
		dw .WalkTM00 : db $10,!Conjurex_Walk+1
		dw .WalkTM01 : db $10,!Conjurex_Walk+2
		dw .WalkTM00 : db $10,!Conjurex_Walk+3
		dw .WalkTM02 : db $10,!Conjurex_Walk+0
	; cast
		dw .CastTM00 : db $06,!Conjurex_Cast+1
		dw .CastTM01 : db $06,!Conjurex_Cast+2
		dw .CastTM02 : db $06,!Conjurex_Cast+3
		dw .CastTM03 : db $06,!Conjurex_Cast+4
		dw .CastTM04 : db $06,!Conjurex_Cast+5
		dw .CastTM05 : db $06,!Conjurex_Cast+6
		dw .CastTM06 : db $06,!Conjurex_Cast+7
		dw .CastTM07 : db $06,!Conjurex_Cast+8
		dw .CastTM08 : db $06,!Conjurex_Cast+6
	; pushback
		dw .PushbackTM00 : db $06,!Conjurex_Pushback+1
		dw .PushbackTM01 : db $06,!Conjurex_Pushback+2
		dw .PushbackTM02 : db $06,!Conjurex_Pushback+0
	; hurt
		dw .HurtTM00 : db $FF,!Conjurex_Hurt


	.WalkTM00
		dw $0004
		db $32,$FC,$F3,$04
		dw $0008
		db $32,$00,$F0,$00
		db $32,$00,$00,$20
	.WalkTM01
		dw $0004
		db $32,$FC,$F2,$04
		dw $0008
		db $32,$00,$EF,$00
		db $32,$00,$FF,$02
	.WalkTM02
		dw $0004
		db $32,$FC,$F2,$04
		dw $0008
		db $32,$00,$EF,$00
		db $32,$00,$FF,$22

	.CastTM00
		dw $0004
		db $32,$F8,$F4,$04
		dw $0014
		db $32,$F0,$FC,$4D
		db $32,$FB,$F0,$0A
		db $32,$03,$F0,$0B
		db $32,$FB,$00,$2A
		db $32,$03,$00,$2B
	.CastTM01
		dw $0004
		db $32,$F8,$F3,$04
		dw $0014
		db $B2,$F0,$FC,$4D
		db $32,$FB,$F0,$0D
		db $32,$03,$F0,$0E
		db $32,$FB,$00,$2D
		db $32,$03,$00,$2E
	.CastTM02
		dw $0004
		db $32,$F9,$F3,$04
		dw $0014
		db $32,$F0,$FC,$4D
		db $32,$FB,$F0,$40
		db $32,$03,$F0,$41
		db $32,$FB,$00,$60
		db $32,$03,$00,$61
	.CastTM03
		dw $0004
		db $32,$F8,$F4,$04
		dw $0014
		db $B2,$F0,$FC,$4B
		db $32,$FB,$F0,$0A
		db $32,$03,$F0,$0B
		db $32,$FB,$00,$2A
		db $32,$03,$00,$2B
	.CastTM04
		dw $0004
		db $32,$F8,$F3,$04
		dw $0014
		db $32,$F0,$FC,$4B
		db $32,$FB,$F0,$0D
		db $32,$03,$F0,$0E
		db $32,$FB,$00,$2D
		db $32,$03,$00,$2E
	.CastTM05
		dw $0004
		db $32,$F9,$F3,$04
		dw $0014
		db $B2,$F0,$FC,$4B
		db $32,$FB,$F0,$40
		db $32,$03,$F0,$41
		db $32,$FB,$00,$60
		db $32,$03,$00,$61
	.CastTM06
		dw $0004
		db $32,$F8,$F4,$04
		dw $0014
		db $32,$F0,$FC,$45
		db $32,$FB,$F0,$0A
		db $32,$03,$F0,$0B
		db $32,$FB,$00,$2A
		db $32,$03,$00,$2B
	.CastTM07
		dw $0004
		db $32,$F8,$F3,$04
		dw $0014
		db $32,$F0,$FC,$47
		db $32,$FB,$F0,$0D
		db $32,$03,$F0,$0E
		db $32,$FB,$00,$2D
		db $32,$03,$00,$2E
	.CastTM08
		dw $0004
		db $32,$F9,$F3,$04
		dw $0014
		db $32,$F0,$FC,$49
		db $32,$FB,$F0,$40
		db $32,$03,$F0,$41
		db $32,$FB,$00,$60
		db $32,$03,$00,$61

	.PushbackTM00
		dw $0004
		db $32,$F8,$F4,$04
		dw $0010
		db $32,$FB,$F0,$0A
		db $32,$03,$F0,$0B
		db $32,$FB,$00,$2A
		db $32,$03,$00,$2B
	.PushbackTM01
		dw $0004
		db $32,$F8,$F3,$04
		dw $0010
		db $32,$FB,$F0,$0D
		db $32,$03,$F0,$0E
		db $32,$FB,$00,$2D
		db $32,$03,$00,$2E
	.PushbackTM02
		dw $0004
		db $32,$F9,$F3,$04
		dw $0010
		db $32,$FB,$F0,$40
		db $32,$03,$F0,$41
		db $32,$FB,$00,$60
		db $32,$03,$00,$61

	.HurtTM00
		dw $0004
		db $32,$FC,$F3,$04
		dw $0008
		db $32,$00,$F0,$43
		db $32,$00,$00,$63



	SpellParticles:
		LDA !SpriteAnimIndex					;\
		ASL #2							; |
		TAY							; | get tilemap pointer to find X coord
		REP #$20						; |
		LDA.w ANIM+0,y : STA $04				; |
		SEP #$20						;/

		LDA #$4D						;\
		CLC : ADC !SpriteTile,x					; | tile
		STA $06							;/
		LDA $33C0,x						;\
		AND #$0E						; |
		ORA #$B0						; | prop
		ORA !SpriteProp,x					; |
		STA $07							;/

		REP #$20						;\
		LDY #$03+6						; |
		LDA ($04),y						; |
		AND #$00FF						; | coords
		LDY $3320,x						; |
		BNE $04 : EOR #$00FF : INC A				; |
		CLC : ADC #$0004					; |
		ORA #$0D00						; |
		STA $00							;/

		SEP #$20						;\
		LDA !RNG						; |
		AND #$07						; |
		TAY							; |
		LDA .XSpeed,y : STA $02					; |
		LDA $14							; | speeds
		AND #$04 : BEQ +					; |
		LDA $02							; |
		EOR #$FF						; |
		STA $02							; |
	+	STZ $03							;/

		STZ $04							;\
		LDA !RNG						; |
		AND #$0F						; | acc
		EOR #$FF						; |
		SEC : SBC #$04						; |
		STA $05							;/

		LDA #!prt_smoke8x8 : JSL SpawnParticle			; spawn 8x8 particle

		RTS


		.XSpeed
		db $02,$04,$06,$08,$0A,$0C,$0E,$10



	Hurt:
		LDA $BE,x : BEQ +
		LDA #$02 : STA $3230,x
	+	INC $BE,x
		RTS


	DropMask:
		LDA #$FF : STA !ConjurexMask,x

		LDY $3320,x
		STZ $00
		LDA #$18 : STA $01
		LDA DATA_MaskXSpeed,y : STA $02
		LDA #$E8 : STA $03
		LDA #$35 : STA !BigRAM+2

		LDY #$02
		JSL SpawnSpriteTile
		REP #$10
		LDX $00
		LDA !41_Particle_Prop,x
		AND #$0E^$FF
		ORA #$04
		STA !41_Particle_Prop,x
		SEP #$10
		LDX !SpriteIndex
		RTS


	DATA:
		.XSpeed
		db $08,$F8

		.MaskXSpeed
		db $F8,$08

		.CastX
		db $10,$EF

		.CastXSpeed
		db $20,$E0

		.Ammo
		db $03,$03,$03

		.Recoil
		db $EC,$14

		.DustOffset
		db $FE,$0A

		.MaskTile
		db $04,$04,$04,$04
		db $06,$06,$06,$06
		db $08,$08,$08,$08
		db $24,$24,$24,$24
		db $26,$26,$26,$26
		db $28,$28,$28,$28
		db $04,$06,$08,$04
		db $24,$26,$28,$24





namespace off














