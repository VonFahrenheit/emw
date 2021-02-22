Thif:

	namespace Thif

	; $BE	-	idle status
	; $3280	-	chase flag
	; $3290	-	loot flag
	; $32A0	-	jump flag
	; $32B0 -	amount of loot (the number of coins this sprite carries)
	; $32D0	-	main timer for idle phase
	; $3300	-	don't get hurt timer (set upon successful theft)
	; $35D0 -	hide flag



	INIT:
		PHB : PHK : PLB				; > Start of bank wrapper
		JSL SUB_HORZ_POS_Long
		TYA : STA $3320,x
		INC $32A0,x
		LDA !ExtraBits,x
		AND #$04 : BEQ .Return
		LDA $3220,x				;\
		ORA #$08				; | Move half a tile right if extra bit is set
		STA $3220,x				;/
		INC $35D0,x				; hide
	.Return	PLB					; > End of bank wrapper
		RTL					; > End INIT routine


	MAIN:
		PHB : PHK : PLB

		JSL SPRITE_OFF_SCREEN_Long

		LDA $3280,x : BEQ .Next
		JMP .Nope
	.Next	LDA #$80 : STA $0E			;\ this sight box for sprite 0x17
		LDA #$FF : STA $0F			;/
		LDA !ExtraProp1,x : BNE +
		LDA #$40 : STA $0E			;\ this sight box for sprite 0x16
		LDA #$80 : STA $0F			;/
		+

		LDA !ExtraBits,x
		AND #$04 : BEQ .Fake
		LDA !PauseThif : BEQ .Sight
		JMP .Nope				; don't activate when paused


	.Fake	LDA $32D0,x : BNE +
		LDA #$60 : STA $32D0,x

		LDA $3330,x
		AND #$04 : BEQ +
		LDA $BE,x
		INC A
		AND #$03
		STA $BE,x
		TAY
		LDA DATA_YSpeed,y : STA $9E,x
		+

	.Sight	LDA $3220,x
		SEC : SBC $0E
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$20
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA $0F : STA $06
		LDA #$30 : STA $07
		SEC : JSL !PlayerClipping
		BCS .Yes
		LDA !ExtraBits,x
		AND #$04 : BEQ .Nope
		JMP .NoSpeed

	.Yes	LDA #$02 : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		INC $3280,x
		STZ $35D0,x				; unhide
		LDA !ExtraBits,x
		AND #$04 : BEQ .Nope


	; Explosive entrance code here!


		LDY #$0C				;\
	-	REP #$20				; |
		LDA DATA_BlockMatrix+0,y : STA $02	; |
		LDA DATA_BlockMatrix+2,y : STA $04	; |
		SEP #$20				; |
		STZ $00					; |
		STZ $7C					; | Destroy blocks
		LDA #$02 : STA $9C			; |
		PHY					; |
		LDY #$00				; |
		JSL !GenerateBlock			; |
		PLY					; |
		DEY #4 : BPL -				;/

		LDY #$02				;\
		REP #$20				; |
		LDA #$FFF8 : STA $00			; |
		LDA #$FFF0 : STA $02			; |
		SEP #$20				; |
		LDA #$80				; |
		JSL SpawnExSprite_NoSpeed_Long		; | Spawn smoke puffs
		LDY #$02				; |
		LDA #$F8 : STA $00			; |
		DEC $01					; |
		STZ $02					; |
		STZ $03					; |
		LDA #$80				; |
		JSL SpawnExSprite_NoSpeed_Long		;/

		LDA #$19 : STA !SPC4			; Clap SFX

		PHX					;\
		LDA $33F0,x				; |
		TAX					; | Sprite can't respawn after blocks have been broken
		LDA #$EE : STA $418A00,x		; |
		PLX					;/
		.Nope

		LDA $3230,x
		CMP #$08 : BEQ .Process
		STZ $3290,x				;\ Sprite has no loot if it's dead
		STZ $32B0,x				;/
		JMP .NoAttack


		.Process
		LDA $3290,x : BEQ +
		LDY $3320,x
		BRA .Go
	+	LDA $3280,x : BEQ .Apply

		JSL SUB_HORZ_POS_Long
	.Go	TYA : STA $3320,x


		EOR #$01
		ASL A
		DEC A
		CLC : ADC $AE,x
		CMP DATA_XSpeed,y
		BEQ .Max
		STA $AE,x
		.Max

		LDA $3330,x
		AND #$04 : BEQ +
		STZ $9E,x
		STZ $32A0,x
		BRA ++
	+	LDA $32A0,x : BNE ++
		INC $32A0,x

	LDA $3290,x : BNE +			; always jump if fleeing
	LDA $3240,x : XBA
	LDY #$00
	LDA !P2Status-$80
	BEQ $02 : LDY #$80
	LDA $3210,x
	REP #$20
	CMP !P2YPosLo-$80,y
	SEP #$20
	BCC ++					; don't jump if above player

	+	LDA #$C0 : STA $9E,x
		++

		LDA $3330,x
		AND #$03 : BEQ +			; wall collision
	;	LDA $3290,x : BEQ ++			; always climb walls
		LDA #$C0 : STA $9E,x
		STZ $AE,x
	;	BRA +

	;++	LDA $AE,x
	;	EOR #$FF
	;	STA $AE,x
	;	LDA #$E0 : STA $9E,x
	;	LDA #$01 : STA !SPC1
	;	INC $32A0,x
		+

	.Apply	JSL !SpriteApplySpeed

		.NoSpeed
		LDA $35D0,x				;\
		ORA $3300,x				; | can't interact during invinc or when hidden
		BNE .NoAttack				;/
		JSL !GetSpriteClipping04
		SEC : JSL !PlayerClipping
		BCC .NoContact
		LSR A : BCC ..P2
	..P1	PHA
		LDY #$00
		JSR Interact
		PLA
	..P2	LSR A : BCC .NoContact
		LDY #$80
		JSR Interact



		.NoContact

		JSL P2Attack_KnockBack_Long
		BCC .NoAttack
		LDA #$02
		STA $3230,x				; status
		STA !SPC1				; SFX

		LDA $3290,x : BEQ .NoAttack		; only drop loot if it has loot
		JSL !GetSpriteSlot
		BMI .NoAttack
		LDA #$21 : STA $3200,y			; sprite number
		LDA #$08 : STA $3230,y			; status
		JSL SPRITE_A_SPRITE_B_COORDS_Long	; coords
		PHX
		TYX
		JSL $07F7D2				; | > Reset sprite tables
		LDA #$04 : STA !ExtraBits,x
		TXY					;\
		PLX					; |
		LDA $32B0,x				; | coin is worth half the thif's loot
		LSR A					; |
		STA $35D0,y				;/
		.NoAttack




	GRAPHICS:
		LDA $3300,x				;\
		AND #$02				; | Blink while invincible
		ORA $35D0,x				; | Don't draw while hidden
		BNE .Return				;/


		LDA $3280,x : BNE .ProcessAnim
		LDA #$01 : STA !SpriteAnimIndex
		LDA $3330,x
		AND #$04 : BEQ .ProcessAnim
		STZ !SpriteAnimIndex


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
		LDA !SpriteTile,x : STA $03
		TDC
		ROL A
		STA $02
		STZ $06
		REP #$20
		STZ $00
		LDA.w ANIM+0,y : JSR LakituLovers_TilemapToRAM
		LDA $32B0,x
		AND #$00FF : BEQ .NoCoin
		LDA #$0040 : STA $02
		SEP #$20
		LDA $3320,x
		BEQ $02 : STZ $02
	;	LDA !Pal8 : TSB $02		; coin palette is pal8 replacement
		REP #$20
		LDA.w #ANIM_Coin : JSR LakituLovers_TilemapToRAM

	.NoCoin	LDA.w #!BigRAM : STA $04
		SEP #$20

		JSL LOAD_TILEMAP_Long
	.Return	PLB
		RTL


Interact:	LDA #$01 : STA !P2SenkuSmash-$80,y
		LDA !P2YSpeed-$80,y
		SEC : SBC $9E,x
		BMI .Side
		CMP #$10 : BCC .Side
	.Top	LDA #$02 : STA $3230,x
		JSL P2Bounce_Long
		LDA #$13 : STA !SPC1		; stomp sound
		LDA $3290,x : BEQ +
		TYA
		CLC
		ROL #2
		TAY
		LDA $32B0,x			;\
		LSR A				; | player recovers half the sprite's loot
		CLC : ADC !P1CoinIncrease,y	; |
		STA !P1CoinIncrease,y		;/
	+	RTS

	.Side	LDA $3290,x : BEQ +
		LDA !Difficulty
		AND #$03
		TAY
		LDA DATA_Invinc,y
		STA $3300,x			; Set don't get hurt timer
		LDA $AE,x
		JSR LakituLovers_Idle_Halve
		STA !P2VectorX-$80,y
		LDA #$08 : STA !P2VectorTimeX-$80,y
		RTS

	+	TYA
		CLC
		ROL #2
		ASL A
		TAY
		REP #$20
		LDA !P1Coins,y			;\
		STA $00				; |
		SEC : SBC #$00C8		; |
		BPL $03 : LDA #$0000		; |
		STA !P1Coins,y			; | Sprite steals up to 200 coins from player
		LDA $00				; |
		CMP #$00C8			; |
		BCC $03 : LDA #$00C8		; |
		SEP #$20			; |
		STA $32B0,x			;/
		LDA #$1C : STA !SPC1
		INC $3290,x
		RTS


DATA:
	.XSpeed
	db $20,$E0

	.YSpeed
	db $D0,$C0,$B0,$D0

	.BlockMatrix
	dw $FFF8,$FFF0
	dw $0008,$FFF0
	dw $FFF8,$0000
	dw $0008,$0000

	.Invinc
	db $20,$80,$FF





ANIM:

; Animation table

.AnimWalk
dw .Walk00 : db $FF,$00		; 00
dw .Walk01 : db $FF,$01		; 01

.AnimMorph
dw .Morph : db $05,$03		; 02

.AnimRun
dw .Run00 : db $03,$04		; 03
dw .Run01 : db $03,$05		; 04
dw .Run02 : db $03,$03		; 05



; Tilemap table

.Walk00
dw $0004
db $30,$00,$00,$00

.Walk01
dw $0004
db $30,$00,$00,$02

.Morph
dw $0008
db $30,$00,$F0,$04
db $30,$00,$00,$06

.Run00
dw $0008
db $B0,$00,$F4,$02
db $30,$00,$00,$08

.Run01
dw $0008
db $B0,$00,$F4,$02
db $30,$00,$00,$0A

.Run02
dw $0008
db $B0,$00,$F4,$02
db $30,$00,$00,$0C

.Coin
dw $0004
db $30,$00,$E8,$45


	namespace off





