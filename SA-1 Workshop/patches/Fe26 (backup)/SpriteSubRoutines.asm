SPRITE_OFF_SCREEN:
		STZ $3490,x
		STZ $3350,x
		LDA !RAM_ScreenMode
		LSR A
		LDA $3250,x
		BCC .HorizontalLevel

		.VerticalLevel
		BEQ .VertY
		DEC A
		BEQ .VertY
		INC $3350,x

		.VertY
		LDA $3240,x
		XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		CLC : ADC #$0040
		CMP #$0140
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
		LDA $3240,x
		CMP #$02
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
		LDA #$00			;\ Respawn
		STA $418A00,x			;/
		PLX

		.Kill
		STZ $3230,x

		.Return
		RTS


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

SPRITE_SPINKILL:
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		JSL $07FC3B
		LDA #$08 : STA !SPC1
		RTS

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


;=====================;
;HURT PLAYER 2 ROUTINE;
;=====================;
HurtPlayers:	LDY #$00		; > Index 0
		LSR A : BCC +
		PHA
		LDA !CurrentMario
		CMP #$01 : BNE ++
		JSL $00F5B7		; > Hurt Mario (P1)
		BRA +++
	++	JSR HurtP1
	+++	PLA
	+	LSR A : BCC .Nope
		LDA !CurrentMario
		CMP #$02 : BNE HurtP2
		JSL $00F5B7		; > Hurt Mario (P2)
.Nope		RTS


HurtP2:		LDY #$80		; > P2 index
HurtP1:		LDA !P2Invinc-$80,y	;\
		ORA $7490		; | Don't hurt player while star is active or player is invulnerable
		BNE .Return		;/
		LDA #$D8		;\ Give P2 some Y speed
		STA !P2YSpeed-$80,y	;/
		LDA #$20		;\ Play Yoshi "OW" sound
		STA !SPC1		;/
		LDA #$80		;\ Set invincibility timer
		STA !P2Invinc-$80,y	;/
		LDA #$00		;\
		STA !P2Floatiness-$80,y	; |
		STA !P2Punch1-$80,y	; | Reset stuff
		STA !P2Punch2-$80,y	; |
		STA !P2Senku-$80,y	; |
		STA !P2Kick-$80,y	;/
		LDA !P2HP-$80,y		;\
		DEC A			; | Decrement HP and kill player 2 if zero
		STA !P2HP-$80,y		; |
		BEQ .Kill		;/
		LDA #$0F
		STA !P2HurtTimer-$80,y



	RTS

		LDA $3250,x
		XBA
		LDA $3220,x
		REP #$20
		CMP !P2XPosLo-$80,y
		SEP #$20
		BMI .Left
.Right		LDA #$1F		;\ Give some X speed
		STA !P2XSpeed-$80,y	;/
		RTS
.Left		LDA #$E1		;\ Give some X speed
		STA !P2XSpeed-$80,y	;/
		RTS

.Kill		LDA #$01 : STA !P2Status-$80,y
		LDA !P1Dead
		BEQ .Return
		LDA #$01 : STA !SPC3
.Return		RTS


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

;=======================;
;PLAYER 2 BOUNCE ROUTINE;
;=======================;
P2Bounce:
		TYA : JSR CheckMario
		BNE .PCE
		JSL !BouncePlayer
		JSL !ContactGFX
		RTS

		.PCE
		PHX
		TYA
		CLC : ROL #2
		TAX
		LDA #$D0			;\
		BIT $6DA2,x			; | Set Y speed
		BPL $02 : LDA #$A8		; |
		PLX
		STA !P2YSpeed-$80,y		;/
		LDA #$00			;\
		STA !P2SenkuUsed-$80,y		;/ Reset air Senku
		JMP P2ContactGFX


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


LOAD_PSUEDO_DYNAMIC:
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		BRA .Main

.Rex		LDA $3220,x
		LDY $BE,x
		BEQ .Left
		LDY $3320,x
		BNE .Left
.Right		CLC : ADC #$04
.Left		STA $00
		LDA $3250,x
		ADC #$00
		STA $01
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


UPDATE_GFX:	STZ $02 : STZ $03			; < Clear this unless dynamic option is used
.Dynamic	JSL !GetVRAM
		PHP
		REP #$30
		LDA $0C : BEQ +				; < Return if dynamo is empty
		LDA ($0C) : STA $00
		LDY #$0000
		INC $0C
		INC $0C
	-	LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$00,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$02,x
		INY
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$03,x
		INY #2
		LDA $02
		ASL #4
		CLC : ADC ($0C),y
		STA !VRAMbase+!VRAMtable+$05,x
		INY #2
		CPY $00
		BCS +
		TXA
		CLC : ADC #$0007
		TAX
		BRA -

		+
		SEP #$10
		LDX !SpriteIndex
		PLP
		RTS



CheckMario:	CLC : ROL #2
		INC A
		CMP !CurrentMario
		RTS