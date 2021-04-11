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
		BIT !CameraBoxU+1 : BPL .GoodX
		LDA $3470,x
		AND #$04 : BNE .GoodX
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC #$0060
		CMP #$01C0
		SEP #$20
		ROL A
		AND #$01
		STA $3350,x

		.GoodX
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		BIT !CameraBoxU : BMI .NoBoxY
		CMP !CameraBoxU : BCC .NoBoxY
		SBC #$00E0
		BMI .GoodY
		CMP !CameraBoxD : BCC .GoodY

		.NoBoxY
		CMP !LevelHeight : BCS .OutOfBoundsY
		SEC : SBC $1C
		BPL +
		EOR #$FFFF
		LDY #$00
		BRA ++
	+	LDY #$02
	++	CMP.w .YBounds,y
		SEP #$20
		BCC .GoodY

		.OutOfBoundsY
		SEP #$20
		INC $3490,x

		.GoodY
		SEP #$20
		LDA $3350,x
		ORA $3490,x
		BEQ .Return
		LDA !SpriteTweaker4,x
		AND #$04 : BNE .Return

		LDA $3230,x
		CMP #$08 : BCC .Kill
		LDY $33F0,x
		CPY #$FF : BEQ .Kill
		PHX
		TYX
		LDA $418A00,x			;\ 0xEE means don't respawn ever
		CMP #$EE : BEQ +		;/
		LDA #$00			;\ Respawn
		STA $418A00,x			;/
	+	PLX

		.Kill
		STZ $3230,x

		.Return
		RTS


.YBounds	dw $00E0,$01C0			; above, below

.Long		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		PLB
		RTL


StompSound:	PHY
		LDA !P2Character-$80,y : BEQ .Mario

.PCE		LDA !P2KillCount-$80,y
		CMP #$07 : BCS .Shared
		INC A
		STA !P2KillCount-$80,y
		DEC A
		BRA .Shared

.Mario		LDA $7697
		CMP #$07 : BCS .Shared
		INC $7697

.Shared		TAY
		CPY #$07
		BCC $02 : LDY #$07
		LDA.w .StarSounds,y : STA !SPC1
.NoSound	PLY
		RTS

.StarSounds	db $13,$14,$15,$16,$17,$18,$19


SPRITE_STAR:	LDA #$02 : STA $3230,x
		LDA #$D0 : STA $3200,x
		JSR SUB_HORZ_POS
		LDA.w .StarXSpeed,y : STA $AE,x
		LDA $78D2
		CMP #$08 : BCS +
		INC A
		STA $78D2
	+	TAY
		CPY #$07
		BCC $02 : LDY #$07
		LDA.w StompSound_StarSounds,y : STA !SPC1
.Return		RTS
.StarXSpeed	db $F0,$10

.Long		JSR SPRITE_STAR
		RTL


SPRITE_SPINKILL:
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		PHY
		JSL $07FC3B
		PLY
		LDA #$08 : STA !SPC1
		RTS

.Long		JSR SPRITE_SPINKILL
		RTL


SUB_HORZ_POS:	LDA !P2Status-$80 : BNE .2
.1		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTS
.2		LDA !MultiPlayer : BEQ .1
		LDA !P2Status : BNE .1
		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo
		SEP #$20
		BPL .Set
		RTS

.Long		JSR SUB_HORZ_POS
		RTL
.Long1		JSR SUB_HORZ_POS_1
		RTL
.Long2		JSR SUB_HORZ_POS_2
		RTL

SUB_VERT_POS:	LDA !P2Status-$80 : BNE .2
.1		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTS
.2		LDA !MultiPlayer : BEQ .1
		LDA !P2Status : BNE .1
		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo
		SEP #$20
		BPL .Set
		RTS

.Long		JSR SUB_VERT_POS
		RTL
.Long1		JSR SUB_VERT_POS_1
		RTL
.Long2		JSR SUB_VERT_POS_2
		RTL



AccelerateX:
		CMP #$00
		BMI .GoLeft
.GoRight	INC $AE,x
		INC $AE,x
		BMI .Return
		CMP $AE,x : BCC .Store
		RTS

.GoLeft		DEC $AE,x
		DEC $AE,x
		BPL .Return
		CMP $AE,x : BCS .Store
		RTS

.Store		STA $AE,x
.Return		RTS

.Long		JSR AccelerateX
		RTL

AccelerateY:
		CMP #$00
		BMI .GoUp
.GoDown		INC $9E,x
		INC $9E,x
		BMI .Return
		CMP $9E,x : BCC .Store
		RTS

.GoUp		DEC $9E,x
		DEC $9E,x
		BPL .Return
		CMP $9E,x : BCS .Store
		RTS

.Store		STA $9E,x
.Return		RTS

.Long		JSR AccelerateY
		RTL


;==========================;
;SPRITE A SPRITE B ROUTINES;
;==========================;
; These deal with common functions used when X = sprite A index and Y = sprite B index
SPRITE_A_SPRITE_B:

.COORDS		LDA $3220,x : STA $3220,y	;\
		LDA $3250,x : STA $3250,y	; | copy coordinates
		LDA $3210,x : STA $3210,y	; |
		LDA $3240,x : STA $3240,y	;/
		RTS

..Long		JSR .COORDS
		RTL

.ADD		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y			; | copy coordinates and add $00-$03
		LDA $3210,x			; |
		CLC : ADC $02			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		ADC $03				; |
		STA $3240,y			;/
		RTS

..Long		JSR .ADD
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
;	returns with carry set if there was contact
;	sets index mem for player
;	returns with lowest bit of A set for player 1, and second lowest bit set for player 2
P2Attack:	STZ $0F
	.Main	LDA #$00 : PHA
		PHY
		LDY #$00
	.Loop	LDA !P2Status-$80,y : BEQ .ReadIndex
		JMP .Next

		.ReadIndex
		CPX #$08 : BCC ..07
	..8F	LDA !P2IndexMem2-$80,y
		BRA ..Index
	..07	LDA !P2IndexMem1-$80,y
	..Index	AND .ContactBits,x
		BEQ ..Ok
		CLC : BRA .Next
		..Ok

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


		LDA !P2Character-$80,y
		CMP #$03 : BNE +
		LDA #$08 : STA !P2ComboDash-$80,y
		LDA #$00 : JSR DontInteract
		+


		JSR P2HitContactGFX


		.WriteIndex
		LDA .ContactBits,x
		CPX #$08 : BCC ..07
	..8F	ORA !P2IndexMem2-$80,y
		STA !P2IndexMem2-$80,y
		BRA ..Ok
	..07	ORA !P2IndexMem1-$80,y
		STA !P2IndexMem1-$80,y
		..Ok

		LDA $0F : BEQ .Next
		LDA !P2Direction-$80,y
		DEC A
		EOR #$30
		STA $AE,x
		LDA #$F0 : STA $9E,x

		.Next
		CPY #$80 : BEQ .Return
		LDY #$80 : JMP .Loop

		.Return
		PLY
		PLA				;\
		SEC				; |
		BNE $01 : CLC			; | (carry is always set if Y[0x80] = 0x80)
		RTS				;/


.Long		PHB : PHK : PLB
		JSR P2Attack
		PLB
		RTL

.KnockBack	LDA #$01 : STA $0F
		JMP P2Attack_Main

..Long		PHB : PHK : PLB
		JSR .KnockBack
		PLB
		RTL


.ContactBits	db $01,$02,$04,$08,$10,$20,$40,$80
		db $01,$02,$04,$08,$10,$20,$40,$80


;===============;
;GLITTER ROUTINE;
;===============;
MakeGlitter:
		TXA
		CLC : ADC $14
		AND #$0F : BNE .Return
		LDY.b #!Ex_Amount-1
	-	LDA !Ex_Num,y : BNE +
		LDA #$04 : STA !Ex_Num,y
		LDA !RNG
		AND #$0F
		ASL A
		SEC : SBC #$10
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3210,x
		STA !Ex_YLo,y
		LDA $3240,x
		ADC $00
		STA !Ex_YHi,y
		LDA !RNG
		LSR #3
		AND #$17
		SEC : SBC #$08
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3220,x
		STA !Ex_XLo,y
		LDA $3250,x
		ADC $00
		STA !Ex_XHi,y
		LDA #$1F : STA !Ex_Data1,y
		BRA .Return
	+	DEY : BPL -
	.Return	RTS

.Long		JSR MakeGlitter
		RTL


;==========================;
;SPRITE CONTACT GFX ROUTINE;
;==========================;
;
; displays contact GFX on the point between two sprites (X and Y)
;
SpriteContactGFX:
		PHX
		LDA $3220,x
		CLC : ADC $3220,y
		STA $00
		LDA $3250,x
		ADC $3250,y
		STA $01
		LDA $3210,x
		CLC : ADC $3210,y
		STA $02
		LDA $3240,x
		ADC $3240,y
		STA $03
		REP #$20
		LDA $00
		LSR A
		STA $00
		SEC : SBC $1A
		CMP #$0100 : BCS .Nope
		LDA $02
		LSR A
		STA $02
		SEC : SBC $1C
		CMP #$00E0 : BCS .Nope
		SEP #$20
		LDX #!Ex_Amount-1

	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; smoke type
		LDA $00 : STA !Ex_XLo,x			; smoke X
		LDA $02 : STA !Ex_YLo,x			; smoke Y
		LDA #$08 : STA !Ex_Data1,x		; smoke timer

	.Nope	SEP #$20
		PLX
		RTS


	.Long	JSR SpriteContactGFX
		RTL


;============================;
;PLAYER 2 CONTACT GFX ROUTINE;
;============================;
P2ContactGFX:	PHX
		LDA !P2Offscreen : BNE .Return
		LDX #!Ex_Amount-1

	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; > Smoke type
		LDA !P2XPosLo-$80,y			;\
		CLC : ADC #$08				; | Smoke Xpos
		STA !Ex_XLo,x				;/
		LDA !P2YPosLo-$80,y			;\
		CLC : ADC #$08				; | Smoke Ypos
		STA !Ex_YLo,x				;/
		LDA #$08 : STA !Ex_Data1,x		; > Smoke timer

		.Return
		PLX
		RTS

.Long		JSR P2ContactGFX
		RTL


;=======================;
;HIT CONTACT GFX ROUTINE;
;=======================;
P2HitContactGFX:
		PHX
		LDX #!Ex_Amount-1

	.Loop	LDA !Ex_Num,x : BEQ .Spawn
		DEX : BPL .Loop
		PLX
		RTS

		.Spawn
		LDA #$02+!SmokeOffset : STA !Ex_Num,x
		LDA $0F : PHA
		LDA $02
		LSR A
		CLC : ADC $00
		STA $0F
		LDA $06
		LSR A
		CLC : ADC $04
		CLC : ADC $0F
		ROR A
		STA !Ex_XLo,x

		LDA $03
		LSR A
		CLC : ADC $01
		STA $0F
		LDA $07
		LSR A
		CLC : ADC $05
		CLC : ADC $0F
		ROR A
		SEC : SBC #$08
		STA !Ex_YLo,x

		LDA #$08 : STA !Ex_Data1,x
		PLA : STA $0F
		PLX
		RTS

.Long		JSR P2HitContactGFX
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


;==============;
;UPDATE PALETTE;
;==============;
; always use long version!
LoadPalset:
.Long
		STA $0F
		LDA.l !LoadPalset : STA $00
		LDA.l !LoadPalset+1 : STA $01
		LDA.l !LoadPalset+2 : STA $02
		LDA $0F
		JML [$3000]


;======================;
;SUPREME TILEMAP LOADER;
;======================;
;
;	This routine can be used by sprites to load a raw OAM tilemap.
;
;	$00:		sprite Xpos within screen
;	$02:		sprite Ypos within screen
;	$04:		pointer to tilemap base
;	$06:		tile Xpos within screen (only for static loader, for pseudo-dynamic, this is the tile size bit)
;	$08:		tilemap size
;	$0A:		graphics claim offset (only for pseudo-dynamic, for static loader this is the tile size bit)
;	$0C:		copy of xflip flag from tilemap
;	$0E:		0xFFFF is tile is x-flipped, otherwise 0x0000
;
; returns with index to next OAM tile in $0E (static) or last written tile (psuedo-dynamic)

macro OAMhook(index)
	if <index> == 2
	.HiPrio
	endif
	.p<index>
		LDA.b #<index>*2
		BRA .Shared

	..Long
	if <index> == 1
	.Long
	elseif <index> == 2
	.HiPrio_Long
	endif
		JSR .p<index>
		RTL
endmacro

LOAD_TILEMAP:
; default to prio 1 if not specified
		%OAMhook(1)
		%OAMhook(2)
		%OAMhook(0)
		%OAMhook(3)

	.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
	+	LDY #$00
		REP #$30
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTS


.Loop		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				;\
		AND #$10				; |
		ASL A					; |
		STA $0A					; | YXPPCCCT
		LDA ($04),y				; | (lower P bit is shifted 1 bit left)
		AND.b #$20^$FF				; |
		ORA $0A					; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/

		PHA
		LDA ($04),y				;\
		AND #$20				; | tile size bit
		BEQ $02 : LDA #$02			; |
		STA $0A					;/
		STZ $0B					;\ n flag trigger
		BEQ $02 : DEC $0B			;/
		PLA

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
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INY
.BadCoord	INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

.GoodX		STA $06					; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

.GoodY		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA ($04),y : STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
.End		RTS



LOAD_PSUEDO_DYNAMIC:
; default to prio 1 if not specified

		%OAMhook(1)
		%OAMhook(2)
		%OAMhook(0)
		%OAMhook(3)


	.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
	+	LDY #$00
		SEP #$20
		LDA !SpriteTile,x : STA $0A		; dynamic tile
		LDA !SpriteProp,x			;\
		ORA $33C0,x				; | add RAM palette
		TSB $0C					;/
		REP #$30
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTS

.Loop		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y
		AND.b #$30^$FF
		EOR $0C
		ORA $64
		STA !OAM_p0+$003,x
		LDA ($04),y
		AND #$20
		LSR #4 : STA $06			; tile size bit
		BEQ $02 : LDA #$80
		STA $07					; n flag trigger for 16-bit mode (n = 0 -> small tile, n = 1 -> big tile)
		REP #$20
		STZ $0E
		LDA !OAM_p0+$003,x
		AND #$0040 : BEQ +
		LDA #$FFFF : STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $06 : BMI +
		BIT $0E : BPL +
		CLC : ADC #$0008			; add 8 to x-flipped 8x8 tile
	+	CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INY
.BadCoord	INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

.GoodX		PHA					; push 16-bit tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		PLA					; get this off the stack
		BRA .BadCoord

.GoodY		SEP #$20
		STA !OAM_p0+$001,x
		PLA : STA !OAM_p0+$000,x		; lo byte of tile xpos
		PLA : STA $07				; hi byte of tile xpos
		INY
		LDA ($04),y
		CLC : ADC $0A
		STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07					; hi byte of tile xpos
		AND #$01
		ORA $06					; tile size bit
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
.End		RTS



; This routine should be used with dynamic sprites that use the GFX claim system
LOAD_CLAIMED:
	.p1	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p1
		PLA : STA !SpriteTile,x
		RTS
	..Long
	.Long
		JSR .p1
		RTL


	.p0	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p0
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p0
		RTL


	.p2	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p2
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p2
		RTL


	.p3	LDA !SpriteTile,x : PHA
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10 : BCC +
		CLC : ADC #$10
	+	CLC : ADC !SpriteTile,x			; add claim offset to sprite tile offset
		STA !SpriteTile,x
		JSR LOAD_PSUEDO_DYNAMIC_p3
		PLA : STA !SpriteTile,x
		RTS
	..Long
		JSR .p3
		RTL



CheckMario:	CLC : ROL #2
		INC A
		CMP !CurrentMario
		RTS

.Long		JSR CheckMario
		RTL

FireballContact:
		LDY #!Ex_Amount-1
	-	JSR .Main
		BCS .Return
		DEY : BPL -
.ReturnC	CLC
.Return		RTS

.Main		LDA !Ex_Num,y
		AND #$7F
		CMP #$05+!ExtendedOffset : BEQ .Check	; check mario fireball
		CMP #$02+!CustomOffset : BNE .ReturnC	; check luigi fireball
	.Check	LDA !Ex_YLo,y : STA $01
		LDA !Ex_XLo,y : STA $00
		LDA !Ex_YHi,y : STA $09
		LDA !Ex_XHi,y : STA $08
		LDA #$08
		STA $02
		STA $03
		PHY
		JSL !CheckContact
		PLY
		RTS

.Long		JSR FireballContact
		RTL

.Destroy	LDY #!Ex_Amount-1
	-	JSR .Main
		BCC +
		LDA #$0F : STA !Ex_Data2,y
		LDA #$01+!ExtendedOffset : STA !Ex_Num,y
		LDA #$01 : STA !SPC1
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


;============;
;SPAWN SPRITE;
;============;
; A:	sprite num
; C:	0 = vanilla, 1 = custom
; $00:	Xdisp
; $01:	Ydisp
; if Y returns as 0xFF, sprite could not be spawned!

	SpawnSprite:
		STA $0E
		STZ $0F
		BCC $02 : INC $0F
		LDY #$0F
	-	LDA $3230,y : BEQ .Spawn
		DEY : BPL -
		RTS

	.Spawn
		LDA $00
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3220,x
		STA $3220,y
		LDA $02
		ADC $3250,x
		STA $3250,y
		LDA $01
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3210,x
		STA $3210,y
		LDA $02
		ADC $3240,x
		STA $3240,y
		LDA $0F : BNE .Custom

	.Vanilla
		LDA $0E : STA $3200,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		STZ !ExtraBits,x
		STZ !NewSpriteNum,x
		JSL !ResetSprite		; | > Reset sprite tables
		PLX
		PLY
		RTS

	.Custom
		LDA $0E : STA !NewSpriteNum,y
		LDA #$08 : STA !ExtraBits,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		JSL !ResetSprite		; | > Reset sprite tables
		PLX
		PLY
		RTS

	.Long	JSR SpawnSprite
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
		LDA.w .Type,y
		CLC : ADC #!ExtendedOffset
		STA $08
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

		LDY #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ .Yes
	--	DEY : BPL -
		RTS


		.Yes
		LDA $08 : STA !Ex_Num,y		; ExSprite number
		LDA $09 : STA !Ex_Data2,y	; Unknown, probably a timer
		LDA $04 : STA !Ex_XSpeed,y	;\ Speed
		LDA $05 : STA !Ex_YSpeed,y	;/
		TDC : STA !Ex_Data3,y		; Special prop

		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA !Ex_XLo,y			; | X position
		LDA $3250,x			; |
		ADC $01				; |
		STA !Ex_XHi,y			;/
		LDA $3210,x			;\
		CLC : ADC $02			; |
		STA !Ex_YLo,y			; | Y position
		LDA $3240,x			; |
		ADC $03				; |
		STA !Ex_YHi,y			;/

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



; load A with the number of bytes to move, then call this
; that number of tiles will be moved from the start of the sprite's tilemap to hi prio OAM
; this has to be called after LOAD_TILEMAP or any of its variants

;===============;
;HI PRIORITY OAM;
;===============;
HI_PRIO_OAM:
		PHX
		STA $02
		LSR #2
		DEC A
		STA $03
		LDA $33B0,x : PHA
		CLC : ADC.b #!OAM
		STA $00
		LDA.b #!OAM>>8
		ADC #$01
		STA $01
		LDY #$00
		LDX !OAMindex
	-	LDA ($00),y : STA !OAM+$000,x
		INY
		LDA ($00),y : STA !OAM+$001,x
		LDA #$F0 : STA ($00),y			; remove old tile
		INY
		LDA ($00),y : STA !OAM+$002,x
		LDA #$FF : STA ($00),y			; this signals to the sprite that it was moved to lo OAM
		INY
		LDA ($00),y : STA !OAM+$003,x
		INY
		INX #4
		CPY $02 : BCC -
		LDA !OAMindex
		STX !OAMindex
		LSR #2
		TAX
		PLA
		LSR #2
		TAY
	-	LDA !OAMhi+$40,y : STA !OAMhi,x
		INY
		INX
		DEC $03 : BPL -
		PLX
		RTS

.Long		JSR HI_PRIO_OAM
		RTL
		













