SPRITE_OFF_SCREEN:
		STZ $3490,x
		STZ $3350,x
		LDA !RAM_ScreenMode
		LSR A
		LDA $3250,x
		BCC .HorizontalLevel

		.VerticalLevel
		BEQ .VertY
		DEC A : BEQ .VertY
		LDA $3220,x
		CMP #$F0 : BCS .VertY			; Can be up to 16px off the screen on the left
		INC $3350,x

		.VertY
		LDA $3240,x
		XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		CLC : ADC #$0060			;\ Used to be add 0x0040 compare to 0x0140
		CMP #$01C0				;/
		SEP #$20
		ROL A
		AND #$01
		STA $3490,x
		BRA .GoodY


		.HorizontalLevel
		XBA
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC #$0060
		CMP #$01C0
		SEP #$20
		ROL A
		AND #$01
		STA $3350,x
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		CMP $73D7
		SEP #$20
		BCC .GoodY
		INC $3490,x

		.GoodY
		LDA $3350,x
		ORA $3490,x
		BEQ .Return
		LDA $3230,x
		CMP #$08
		BCC .Kill
		LDY $33F0,x
		CPY #$FF
		BEQ .Kill
		PHX
		TYX
		LDA $418A00,x			;\ 0xEE means don't respawn
		CMP #$EE : BEQ +		;/
		LDA #$00			;\ Respawn
		STA $418A00,x			;/
	+	PLX

		.Kill
		STZ $3230,x

		.Return
		RTS

.Long		JSR SPRITE_OFF_SCREEN
		RTL


SPRITE_POINTS:	PHY
		LDA $7697
		INC $7697
		TAY
		CPY #$07
		BCS .NoSound
		LDA.w .StarSounds,y
		STA !SPC1
.NoSound	TYA
		INC A
		CMP #$08
		BCC .NoReset
		LDA #$08
.NoReset	JSL $02ACE5
		PLY
		RTS
.StarSounds	db $13,$14,$15,$16,$17,$18,$19

.Long		JSR SPRITE_POINTS
		RTL


SPRITE_STAR:	LDA #$02
		STA $3230,x
		LDA #$D0
		STA $3200,x
		JSR SUB_HORZ_POS
		LDA.w .StarXSpeed,y
		STA $AE,x
		LDA $78D2
		CMP #$08
		BEQ +
		INC A
		STA $78D2
	+	PHA
		JSL $02ACE5
		PLY
		CPY #$08
		BCS .Return
		LDA.w SPRITE_POINTS_StarSounds,y
		STA !SPC1
.Return		RTS
.StarXSpeed	db $F0,$10

.Long		JSR SPRITE_STAR
		RTL


SPRITE_SPINKILL:
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		JSL $07FC3B
		LDA #$08 : STA !SPC1
		RTS

.Long		JSR SPRITE_SPINKILL
		RTL


SUB_HORZ_POS:	LDA !P2Status-$80 : BNE .2
.1		LDY #$00
		LDA !P2XPosLo-$80
		SEC : SBC $3220,x
		LDA !P2XPosHi-$80
		SBC $3250,x
		BPL .Return
.Set		INY
.Return		RTS
.2		LDA !MultiPlayer : BEQ .1
		LDA !P2Status : BNE .1
		LDY #$00
		LDA !P2XPosLo
		SEC : SBC $3220,x
		LDA !P2XPosHi
		SBC $3250,x
		BMI .Set
		RTS

.Long		JSR SUB_HORZ_POS
		RTL
.Long1		JSR SUB_HORZ_POS_1
		RTL
.Long2		JSR SUB_HORZ_POS_2
		RTL




;==========================;
;SPRITE A SPRITE B ROUTINES;
;==========================;
; These deal with common functions used when X = sprite A index and Y = sprite B index
SPRITE_A_SPRITE_B:

.COORDS		LDA $3220,x : STA $3220,y	;\
		LDA $3250,x : STA $3250,y	; | Copy coordinates
		LDA $3210,x : STA $3210,y	; |
		LDA $3240,x : STA $3240,y	;/
		RTS

..Long		JSR .COORDS
		RTL



;=========================;
;PLAYER 2 CLIPPING ROUTINE;
;=========================;
P2Clipping:	LDA !P2XPosLo			;\
		CLC : ADC #$02			; |
		STA $00				; |
		LDA !P2XPosHi			; |
		ADC #$00			; |
		STA $08				; |
		LDA !P2YPosLo : STA $01		; | Kadaal's clipping
		LDA !P2YPosHi : STA $09		; |
		LDA #$0C : STA $02		; |
		LDA #$10 : STA $03		;/
		RTS

.Long		JSR P2Clipping
		RTL


;============================;
;PLAYER ATTACK HITBOX ROUTINE;
;============================;
; Load sprite hitbox into $04-$07 and $0A-$0B, then call this
P2Attack:	STZ $0F
	.Main	LDA #$00 : PHA
		PHY
		LDY #$00
	.Loop	LDA !P2Status-$80,y : BNE .Next

		REP #$20			;\
		LDA !P2Hitbox-$80+4,y		; |
		STA $02				; | See if there is a hitbox
		SEP #$20			; |
		BEQ .Next			;/
		LDA !P2Hitbox-$80+0,y : STA $00	;\
		LDA !P2Hitbox-$80+1,y : STA $08	; |
		LDA !P2Hitbox-$80+2,y : STA $01	; | See if sprite touches hitbox
		LDA !P2Hitbox-$80+3,y : STA $09	; |
		LDA $0F : PHA			; |
		PHY				; |
		JSL !Contact16			; |
		PLY				; |
		PLA : STA $0F			; |
		BCC .Next			;/

		TYA				;\
		CLC : ROL #2			; |
		INC A				; | Mark contact
		ORA $02,s			; |
		STA $02,s			;/

		LDA $0F : BEQ .Next
		LDA !P2Direction-$80,y
		DEC A
		EOR #$30
		STA $AE,x
		LDA #$F0 : STA $9E,x

		.Next
		CPY #$80 : BEQ .Return
		LDY #$80 : BRA .Loop

		.Return
		PLY
		PLA				;\
		SEC				; |
		BNE $01 : CLC			; | (carry is always set if Y[0x80] = 0x80)
		RTS				;/



.Long		JSR P2Attack
		RTL

.KnockBack	LDA #$01 : STA $0F
		BRA P2Attack_Main

..Long		PHB : PHK : PLB
		JSR .KnockBack
		PLB
		RTL



;============================;
;PLAYER 2 CONTACT GFX ROUTINE;
;============================;
P2ContactGFX:	PHX
		LDA !P2Offscreen
		BNE .Return
		LDX #$03

		.Loop
		LDA $77C0,x
		BEQ .Spawn
		DEX
		BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02 : STA $77C0,x		; > Smoke type
		LDA !P2XPosLo-$80,y		;\
		CLC : ADC #$08			; | Smoke Xpos
		STA $77C8,x			;/
		LDA !P2YPosLo-$80,y		;\
		CLC : ADC #$08			; | Smoke Ypos
		STA $77C4,x			;/
		LDA #$08 : STA $77CC,x		; > Smoke timer

		.Return
		PLX
		RTS

.Long		JSR P2ContactGFX
		RTL

;=======================;
;PLAYER 2 BOUNCE ROUTINE;
;=======================;
P2Bounce:
		TYA : JSR CheckMario
		BNE .PCE
		JSL !BouncePlayer
		JSL !ContactGFX+5
		RTS

		.PCE
		PHX				; preserve sprite index
		TYA
		CLC : ROL #2
		TAX
		LDA #$D0			;\
		BIT $6DA2,x			; | Set Y speed
		BPL $02 : LDA #$A8		; |
		PLX				; |
		STA !P2YSpeed-$80,y		;/
		LDA #$00			;\
		STA !P2SenkuUsed-$80,y		;/ Reset air Senku
		JMP P2ContactGFX

.Long		JSR P2Bounce
		RTL

;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	This routine can be used by sprites to load a raw OAM tilemap.
;
;	$00:		sprite Xpos within screen
;	$02:		sprite Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		tile Xpos within screen
;	$08:		tilemap size
;	$0A:		graphics claim offset
;	$0C:		copy of xflip flag from tilemap
;	$0E:		0xFFFF is tile is x-flipped, otherwise 0x0000


LOAD_TILEMAP:	LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA $02
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		LDA $04
		INC #2
		STA $04
		STZ $0C
		LDA $3320,x
		LSR A
		BCS +
		LDA #$0040
		STA $0C
	+	SEP #$20
		LDA $33B0,x : TAX
		LDY #$00

.Loop		LDA ($04),y
		EOR $0C
		STA !OAM+$103,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodX		STA $06			; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodY		SEP #$20
		STA !OAM+$101,x
		LDA $06
		STA !OAM+$100,x
		INY
		LDA ($04),y
		STA !OAM+$102,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$40,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		LDX !SpriteIndex
		RTS

.Long		JSR LOAD_TILEMAP
		RTL


LOAD_PSUEDO_DYNAMIC:
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
.Main		LDA !ClaimedGFX : STA $0A
		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA $02
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		LDA $04
		INC #2
		STA $04
		STZ $0C
		LDA $3320,x
		LSR A
		BCS +
		LDA #$0040
		STA $0C
	+	SEP #$20
		LDA $33B0,x : TAX
		LDY #$00

.Loop		LDA ($04),y
		EOR $0C
		STA !OAM+$103,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodX		STA $06			; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodY		SEP #$20
		STA !OAM+$101,x
		LDA $06
		STA !OAM+$100,x
		INY
		LDA ($04),y
		CLC : ADC $0A
		STA !OAM+$102,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$40,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		LDX !SpriteIndex
		RTS

.Long		JSR LOAD_PSUEDO_DYNAMIC
		RTL



; This routine is hardcoded to upload Aggro Rex GFX.
LOAD_DYNAMIC:	LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		LDA !ClaimedGFX : STA $0A
		STZ $0B
		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA $02
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		LDA $04
		INC #2
		STA $04
		STZ $0C
		LDA $3320,x
		LSR A
		BCS +
		LDA #$0040
		STA $0C
	+	SEP #$20
		LDA $33B0,x : TAX
		LDY #$00

.Loop		LDA ($04),y
		EOR $0C
		STA !OAM+$103,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		JMP .End

.GoodX		STA $06			; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		JMP .End

.GoodY		SEP #$20
		STA !OAM+$101,x
		LDA $06
		STA !OAM+$100,x
		INY
		LDA $0A
		CLC : ADC.w .TileDisp,y
		STA !OAM+$102,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA !OAMhi+$40,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		LDX !SpriteIndex
		LDY #$03
		LDA !AggroRexTile
		CMP ($04),y
		BNE +
		RTS

	+	JSL !GetVRAM
		BCC +
		LDX !SpriteIndex
		RTS

	+	PHB : LDA #!VRAMbank
		PHA : PLB
		LDA #$30
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		STA !VRAMtable+$12,x
		STA !VRAMtable+$19,x
		REP #$20
		LDA #$0080
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		STA !VRAMtable+$0E,x
		STA !VRAMtable+$15,x
		LDA $0A
		ASL #4
		ORA #$6000
		STA !VRAMtable+$05,x
		CLC : ADC #$0100
		STA !VRAMtable+$0C,x
		CLC : ADC #$0100
		STA !VRAMtable+$13,x
		CLC : ADC #$0100
		STA !VRAMtable+$1A,x
		PLB
		LDA ($04),y
		AND #$00FF
		ASL #5
		CLC : ADC #$A408
		STA.l !VRAMbase+!VRAMtable+$02,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$09,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$10,x
		CLC : ADC #$0200
		STA.l !VRAMbase+!VRAMtable+$17,x
		SEP #$20
		LDX !SpriteIndex
		LDA ($04),y
		STA !AggroRexTile
		RTS


.TileDisp	db $00,$00,$00,$00
		db $02,$02,$02,$02
		db $20,$20,$20,$20
		db $22,$22,$22,$22



;
;
;


CheckMario:	CLC : ROL #2
		INC A
		CMP !CurrentMario
		RTS

.Long		JSR CheckMario
		RTL

FireballContact:
		LDY #$01
	-	JSR .Main
		BCS .Return
		DEY : BPL -
.ReturnC	CLC
.Return		RTS

.Main		LDA $770B+$08,y
		CMP #$05 : BNE .ReturnC
		LDA $7715+$08,y
		STA $01
		LDA $771F+$08,y
		STA $00
		LDA $7729+$08,y
		STA $09
		LDA $7733+$08,y
		STA $08
		LDA #$08
		STA $02
		STA $03
		PHY
		JSL !CheckContact
		PLY
		RTS

.Long		JSR FireballContact
		RTL

.Destroy	LDY #$01
	-	JSR .Main
		BCC +
		LDA #$0F : STA !ExSpriteTimer+$08,y
		LDA #$01
		STA !ExSpriteNum+$08,y
		STA !SPC1
	+	DEY : BPL -
		RTS

..Long		JSR .Destroy
		RTL


; Call this to see if player is in a state that crushes sprite

CheckCrush:
		LDA !P2Character-$80,y
		BNE .Nope
		LDA !MarioSpinJump : BEQ .Nope

		.Yep
		SEC
		RTS

		.Nope
		CLC
		RTS

.Long		JSR CheckCrush
		RTL

;======================;
;DON'T INTERACT ROUTINE;
;======================;
DontInteract:
		CPY #$80 : BEQ .P2
	.P1	STA $32E0,x
		RTS
	.P2	STA $35F0,x
		RTS

.Long		JSR DontInteract
		RTL



;======================;
;SPAWN EXSPRITE ROUTINE;
;======================;
; extended
; LOAD Y WITH NUMBER OF EXSPRITES TO SPAWN, LOAD A WITH TYPE/PATTERN, LOAD $00-$03 WITH OFFSET!
; THEN CALL THE FUNCTION TO SPAWN THEM!
;
; You can call it normally to spawn with speed based on $04/$05
; Add _SpriteSpeed to use sprite's speeds
; Add _NoSpeed to spawn without speed
; All versions have a _Long version as well that comes with a bank wrapper
;
; Writes this to scratch RAM:
; $00-$03: offset
; $04-$05: speeds
; $06-$07: input data
; $08-$09: ExSprite number/timer
; $0A-$0B: -----
; $0C-$0F: pattern data

	SpawnExSprite:
		STY $06
		STA $07
		BRA .Shared
	.Long	PHB : PHK : PLB
		JSR SpawnExSprite
		PLB
		RTL

	.SpriteSpeed
		STY $06
		STA $07
		LDA $AE,x : STA $04
		LDA $9E,x : STA $05
		LDA $07
		BRA .Shared
	..Long	PHB : PHK : PLB
		JSR .SpriteSpeed
		PLB
		RTL

	.NoSpeed
		STZ $04
		STZ $05
		BRA SpawnExSprite
	..Long	PHB : PHK : PLB
		JSR .NoSpeed
		PLB
		RTL
		


	.Shared

		AND #$0F
		TAY
		LDA.w .Type,y : STA $08
		LDA.w .Time,y : STA $09
		STZ $0D
		STZ $0F
		LDA $07
		AND #$C0
		CLC : ROL #3
		TAY
		LDA.w .PatternX,y : STA $0C
		BPL $02 : DEC $0D
		LDA $07
		AND #$30
		LSR #4
		TAY
		LDA.w .PatternY,y : STA $0E
		BPL $02 : DEC $0F

		LDY #$07
	-	LDA !ExSpriteNum,y : BEQ .Yes
	--	DEY : BPL -
		RTS


		.Yes
		LDA $08 : STA !ExSpriteNum,y	; ExSprite number
		LDA $09 : STA !ExSpriteTimer,y	; Unknown, probably a timer
		LDA $04 : STA !ExSpriteXSpeed,y	;\ Speed
		LDA $05 : STA !ExSpriteYSpeed,y	;/
		TDC : STA !ExSpriteBehindBG1,y	; Special prop

		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA !ExSpriteXPosLo,y		; | X position
		LDA $3250,x			; |
		ADC $01				; |
		STA !ExSpriteXPosHi,y		;/
		LDA $3210,x			;\
		CLC : ADC $02			; |
		STA !ExSpriteYPosLo,y		; | Y position
		LDA $3240,x			; |
		ADC $03				; |
		STA !ExSpriteYPosHi,y		;/

		LDA $00
		CLC : ADC $0C
		STA $00
		LDA $01
		ADC $0D
		STA $01
		LDA $02
		CLC : ADC $0E
		STA $02
		LDA $03
		ADC $0F
		STA $03

		DEC $06 : BNE --		; Spawn until done

		RTS


		.PatternX			; Indexed by highest 2 bits
		db $00,$08,$10,$F0

		.PatternY			; Indexed by 0x30 bits
		db $00,$08,$10,$F0


		.Type
		db $01,$02,$03,$04
		db $06,$07,$09,$0A
		db $0B,$0C,$0D,$0E
		db $0F,$10,$11,$12

		.Time
		db $0F,$FF,$FF,$FF
		db $FF,$1F,$FF,$FF
		db $FF,$FF,$FF,$FF
		db $1F,$1F,$FF,$FF

; X0	-	puff of smoke
; X1	-	Reznor fireball
; X2	-	tiny flame
; X3	-	hammer
; X4	-	bone
; X5	-	lava splash
; X6	-	Malleable Extended Sprite
; X7	-	coin from coin cloud
; X8	-	piranha fireball
; X9	-	volcano lotus' fire
; XA	-	baseball
; XB	-	Wiggler's flower
; XC	-	trail of smoke
; XD	-	spin jump star
; XE	-	Yoshi's fireball
; XF	-	water bubble




