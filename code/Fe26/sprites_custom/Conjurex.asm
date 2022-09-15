

	!Temp = 0
	%def_anim(Conjurex_Walk, 4)
	%def_anim(Conjurex_Cast, 9)
	%def_anim(Conjurex_Pushback, 3)
	%def_anim(Conjurex_Hurt, 1)



	!ConjurexIFrames	= $BE
	!ConjurexPushback	= $3280
	!ConjurexMask		= $3290
	!ConjurexAmmo		= $32A0
	!ConjurexMaxAmmo	= $32B0


Conjurex:

	namespace Conjurex


	INIT:
		PHB : PHK : PLB

		LDA !RNG
		AND #$1F : STA !ConjurexMask,x

		LDY !Difficulty
		LDA DATA_Ammo,y
		STA !ConjurexMaxAmmo,x
		STA !ConjurexAmmo,x

		LDA #$60 : STA $32D0,x

	;	LDA #!palset_special_flash_caster : JSL LoadPalset	; load this palset right away

		PLB
		RTL


	MAIN:
		PHB : PHK : PLB

		%decreg(!ConjurexPushback)
		%decreg(!ConjurexIFrames)

		LDA !SpriteStatus,x
		CMP #$08 : BEQ PHYSICS
		CMP #$02 : BNE .Return
		LDA #!Conjurex_Hurt : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		STZ $32D0,x
		LDA #$02 : STA !SpriteHP,x
		JMP GRAPHICS_HandleUpdate

		.Return
		PLB
		RTL


	PHYSICS:

		.Cast
		LDA $32D0,x : BEQ ..startcast
		CMP #$40 : BNE ..noface
		JSL SUB_HORZ_POS				;\ face player
		TYA : STA !SpriteDir,x				;/
		..noface
		JMP ..nocast
		..startcast
		LDA !RNG					;\
		LSR #2						; | wait a random number of frames
		ORA #$C0					; |
		STA $32D0,x					;/

		LDA #$10 : STA !SPC1				; cast SFX
		LDY !SpriteDir,x
		LDA DATA_CastX,y : STA $00
		LDA #$FC : STA $01
		LDA DATA_CastXSpeed,y : STA $02
		STZ $03
		SEC : LDA #$07
		JSL SpawnSprite
		CPY #$FF : BEQ ..nocast
		LDA #$08 : STA !SpriteStatus,y			; state = 8
		LDA !SpriteTile,x				;\
		CLC : ADC #$45					; | tile options
		STA !SpriteTile,y				; |
		LDA !SpriteProp,x : STA !SpriteProp,y		;/
		LDA.w !SpriteXSpeed,y				;\
		LSR A						; |
		AND #$40					; | prop options
		ORA #$3A					; |
		STA !SpriteOAMProp,y				;/
		LDA #$00 : STA !ProjectileType,y		; type 0 with no collision
		LDA #$32 : STA !ProjectileAnimType,y		; end particle pattern, OAM prio 3
		LDA #$03*2 : STA !ProjectileAnimFrames,y	; 3 anim frames (16x16)
		LDA #$06 : STA !ProjectileAnimTime,y		; 6 frames per anim frame
		LDA #$00 : STA !SpriteGravity,y			; no gravity
		LDA #$40 : STA !ProjectileTimer,y		; timer = 64 frames
		LDA #!prt_basic : STA !ProjectilePrtNum,y	; particle type = basic
		LDA !SpriteProp,x				;\
		ORA #$2A					; |
		STA !ProjectilePrtProp,y			; | particle settings
		LDA !SpriteTile,x				; |
		CLC : ADC #$5F					; |
		STA !ProjectilePrtTile,y			;/

		LDY !SpriteDir,x
		LDA DATA_Recoil,y : STA !SpriteXSpeed,x
		LDA #$20 : STA !ConjurexPushback,x

		DEC !ConjurexAmmo,x
		LDA !ConjurexAmmo,x : BEQ +
		LDA #$20 : STA $32D0,x
		BRA ..nocast
	+	LDA #!Conjurex_Pushback : STA !SpriteAnimIndex,x
		LDA !ConjurexMaxAmmo,x : STA !ConjurexAmmo,x
		..nocast


		.Speed
		LDA !SpriteAnimIndex,x
		CMP #!Conjurex_Hurt : BEQ ..hurt
		LDA !ConjurexPushback,x : BEQ ..nothurt
		..hurt
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..move
		JSL AccelerateX_Friction1
		LDA !SpriteXSpeed,x
		CLC : ADC #$08
		CMP #$10 : BCC ..move
		LDA $14
		AND #$03 : BNE ..move
		LDA !SpriteXSpeed,x
		ROL #2
		AND #$01
		TAY
		LDA DATA_DustOffset,y : STA $00
		LDA #$0C : STA $01
		REP #$20
		STZ $02
		STZ $04
		LDA #$3000 : STA $06
		SEP #$20
		LDA #!prt_smoke8x8 : JSL SpawnParticle		; smoke at feet while sliding
		BRA ..move
		..nothurt

		STZ !SpriteXSpeed,x
		LDA !ExtraBits,x
		AND #$04 : BNE ..move
		LDA $32D0,x
		CMP #$40 : BCC ..move
		LDY !SpriteDir,x
		LDA DATA_XSpeed,y : STA !SpriteXSpeed,x
		..move

		LDA #$41					;\
		LDY !ConjurexPushback,x				; | behavior depends on pushback
		BEQ $02 : LDA #$C1				; |
		STA !SpriteTweaker6,x				;/

		JSL APPLY_SPEED



	INTERACTION:

		JSL GetSpriteClippingE8

		.Attacks
		LDA !ConjurexIFrames,x : BNE ..nocontact
		JSL InteractAttacks : BCC ..nocontact
		STZ !SpriteBlocked,x
	-	JSR Hurt
		BRA .Done
		..nocontact

		.Body
		JSL P2Standard : BEQ ..nocontact
		LDA !ConjurexIFrames,x : BEQ -
		..nocontact

		.Done


	GRAPHICS:

		LDA !ConjurexPushback,x : BNE .HandleUpdate

		LDA !SpriteAnimIndex,x
		CMP #!Conjurex_Hurt : BEQ .HandleUpdate


	; cast check
		LDA $32D0,x
		CMP #$40 : BCS .NoCast
		LDA !SpriteAnimIndex,x
		CMP #!Conjurex_Cast : BCC +
		CMP #!Conjurex_Cast_over : BCC ++
	+	LDA #!Conjurex_Cast : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
	++	LDA $14
		AND #$03 : BNE .HandleUpdate
		JSR SpellParticles
		BRA .HandleUpdate
		.NoCast


	; stand still/walk check
		LDA !ExtraBits,x
		AND #$04 : BNE .Wait
		LDA !SpriteAnimIndex,x
		CMP #!Conjurex_Walk_over : BCC .HandleUpdate
		BRA .Walk

		.Wait
		LDA !SpriteAnimIndex,x
		CMP #!Conjurex_Walk_over : BCS .HandleUpdate

		.Walk
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x


	; standard update
		.HandleUpdate
		LDA !SpriteAnimIndex,x
		ASL #2 : TAY
		LDA !SpriteAnimTimer,x
		INC A
		CMP.w ANIM+2,y : BNE .SameAnim
		.NewAnim
		LDA.w ANIM+3,y : STA !SpriteAnimIndex,x
		ASL #2
		TAY
		LDA #$00
		.SameAnim
		STA !SpriteAnimTimer,x

		CPY.b #(!Conjurex_Hurt)*4 : BEQ .Draw
		LDA !ConjurexIFrames,x
		AND #$02 : BEQ .Draw
		PLB
		RTL


		.Draw
		LDA #$0A : STA !SpriteOAMProp,x
		LDA $32D0,x
		CMP #$10 : BCS ..paldone
		CMP #$08 : BCC ..paldone
		PHY
		LDA #!palset_special_flash_caster : JSL LoadPalset
		PLY
		LDX $0F
		LDA !Palset_status,x
		ASL A
		LDX !SpriteIndex
		STA !SpriteOAMProp,x
		..paldone
		LDA !SpriteOAMProp,x : PHA
		LDA !ConjurexMask,x : BMI ..skipmask
		LDA $32D0,x
		CMP #$10 : BCS +
		CMP #$08 : BCS ++
	+	LDA #$04 : STA !SpriteOAMProp,x
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
		LDA !SpriteHP,x : BEQ ..drawmask
		JSR DropMask
		BRA ..skipmask
		..drawmask
		JSL LOAD_PSUEDO_DYNAMIC
		..skipmask
		PLA : STA !SpriteOAMProp,x
		LDA !SpriteAnimIndex,x
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
		dw .HurtTM00 : db $1F,!Conjurex_Walk+0


	.WalkTM00
		dw $0004
		db $22,$FC,$F3,$04
		dw $0008
		db $22,$00,$F0,$00
		db $22,$00,$00,$20
	.WalkTM01
		dw $0004
		db $22,$FC,$F2,$04
		dw $0008
		db $22,$00,$EF,$00
		db $22,$00,$FF,$02
	.WalkTM02
		dw $0004
		db $22,$FC,$F2,$04
		dw $0008
		db $22,$00,$EF,$00
		db $22,$00,$FF,$22

	.CastTM00
		dw $0004
		db $22,$F8,$F4,$04
		dw $0014
		db $22,$F0,$FC,$4D
		db $22,$FB,$F0,$0A
		db $22,$03,$F0,$0B
		db $22,$FB,$00,$2A
		db $22,$03,$00,$2B
	.CastTM01
		dw $0004
		db $22,$F8,$F3,$04
		dw $0014
		db $A2,$F0,$FC,$4D
		db $22,$FB,$F0,$0D
		db $22,$03,$F0,$0E
		db $22,$FB,$00,$2D
		db $22,$03,$00,$2E
	.CastTM02
		dw $0004
		db $22,$F9,$F3,$04
		dw $0014
		db $22,$F0,$FC,$4D
		db $22,$FB,$F0,$40
		db $22,$03,$F0,$41
		db $22,$FB,$00,$60
		db $22,$03,$00,$61
	.CastTM03
		dw $0004
		db $22,$F8,$F4,$04
		dw $0014
		db $A2,$F0,$FC,$4B
		db $22,$FB,$F0,$0A
		db $22,$03,$F0,$0B
		db $22,$FB,$00,$2A
		db $22,$03,$00,$2B
	.CastTM04
		dw $0004
		db $22,$F8,$F3,$04
		dw $0014
		db $22,$F0,$FC,$4B
		db $22,$FB,$F0,$0D
		db $22,$03,$F0,$0E
		db $22,$FB,$00,$2D
		db $22,$03,$00,$2E
	.CastTM05
		dw $0004
		db $22,$F9,$F3,$04
		dw $0014
		db $A2,$F0,$FC,$4B
		db $22,$FB,$F0,$40
		db $22,$03,$F0,$41
		db $22,$FB,$00,$60
		db $22,$03,$00,$61
	.CastTM06
		dw $0004
		db $22,$F8,$F4,$04
		dw $0014
		db $22,$F0,$FC,$45
		db $22,$FB,$F0,$0A
		db $22,$03,$F0,$0B
		db $22,$FB,$00,$2A
		db $22,$03,$00,$2B
	.CastTM07
		dw $0004
		db $22,$F8,$F3,$04
		dw $0014
		db $22,$F0,$FC,$47
		db $22,$FB,$F0,$0D
		db $22,$03,$F0,$0E
		db $22,$FB,$00,$2D
		db $22,$03,$00,$2E
	.CastTM08
		dw $0004
		db $22,$F9,$F3,$04
		dw $0014
		db $22,$F0,$FC,$49
		db $22,$FB,$F0,$40
		db $22,$03,$F0,$41
		db $22,$FB,$00,$60
		db $22,$03,$00,$61

	.PushbackTM00
		dw $0004
		db $22,$F8,$F4,$04
		dw $0010
		db $22,$FB,$F0,$0A
		db $22,$03,$F0,$0B
		db $22,$FB,$00,$2A
		db $22,$03,$00,$2B
	.PushbackTM01
		dw $0004
		db $22,$F8,$F3,$04
		dw $0010
		db $22,$FB,$F0,$0D
		db $22,$03,$F0,$0E
		db $22,$FB,$00,$2D
		db $22,$03,$00,$2E
	.PushbackTM02
		dw $0004
		db $22,$F9,$F3,$04
		dw $0010
		db $22,$FB,$F0,$40
		db $22,$03,$F0,$41
		db $22,$FB,$00,$60
		db $22,$03,$00,$61

	.HurtTM00
		dw $0004
		db $22,$FC,$F3,$04
		dw $0008
		db $22,$00,$F0,$43
		db $22,$00,$00,$63



	SpellParticles:
		LDA !SpriteAnimIndex,x					;\
		ASL #2							; |
		TAY							; | get tilemap pointer to find X coord
		REP #$20						; |
		LDA.w ANIM+0,y : STA $04				; |
		SEP #$20						;/

		LDA #$4D						;\
		CLC : ADC !SpriteTile,x					; | tile
		STA $06							;/
		LDA !SpriteOAMProp,x						;\
		AND #$0E						; |
		ORA #$B0						; | prop
		ORA !SpriteProp,x					; |
		STA $07							;/

		REP #$20						;\
		LDY #$03+6						; |
		LDA ($04),y						; |
		AND #$00FF						; | coords
		LDY !SpriteDir,x					; |
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
		LDY !Difficulty
		LDA DATA_IFrames,y : STA !ConjurexIFrames,x

		LDA !SpriteHP,x : BEQ +
		LDA #$02 : STA !SpriteStatus,x
		LDY !SpriteDir,x
		LDA DATA_MaskXSpeed,y : STA !SpriteXSpeed,x
		LDA #$D0 : STA !SpriteYSpeed,x
	+	INC !SpriteHP,x
		LDA #!Conjurex_Hurt : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$50 : STA $32D0,x
		LDA !ConjurexMaxAmmo,x : STA !ConjurexAmmo,x
		RTS



	DropMask:
		LDA #$FF : STA !ConjurexMask,x

		LDY !SpriteDir,x
		STZ $00
		LDA #$18 : STA $01
		LDA DATA_MaskXSpeed,y : STA $02
		LDA #$E8 : STA $03
		LDA #$35 : STA !BigRAM+2

		LDY #$02
		JSL SpawnSpriteTile
		REP #$10
		LDX $0E
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
		db $01,$02,$03

		.IFrames
		db $40,$60,$80

		.Recoil
		db $EC,$14

		.DustOffset
		db $0A,$FE


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














