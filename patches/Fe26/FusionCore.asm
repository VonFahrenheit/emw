header
sa1rom

; done:
; - make DAMN sure no score sprites can write anything anywhere
; - reprogram engines to subtract their offset value
; - look at all the reads and make sure number comparisons are correct
; - reprogram bounce sprites a bit to fit 2 extra tables, and to add their offset (gotta hijack to do that)
; - lots and lots of bug testing

incsrc "../Defines.asm"


	!DebugRemapCount = 0


; list:
;	00 -- EMPTY --
;	01 coin
;
;	02 -- about to clear --
;	03 brick piece
;	04 small star (glitter?)
;	05 egg piece
;	06 fire particle
;	07 small blue sparkle (invincibility sparkle)
;	08 Z
;	09 water splash
;	0A -- UNUSED --
;	0B -- UNUSED --
;	0C boo stream tile
;	0D -- UNUSED --
;
;	0E -- about to clear --
;	0F puff of smoke
;	10 reznor fireball
;	11 tiny flame
;	12 hammer
;	13 mario fireball
;	14 bone
;	15 lava splash
;	16 torpedo ted arm
;	17 malleable extended sprite
;	18 coin from coin cloud
;	19 piranha fireball
;	1A volcano lotus fire
;	1B baseball
;	1C wiggler flower
;	1D trail of smoke
;	1E spin jump stars
;	1F yoshi fireball
;	20 water bubble
;
;	21 -- about to clear --
;	22 puff of smoke
;	23 contact
;	24 turn smoke
;	25 -- UNUSED --
;	26 glitter
;
;	27 -- about to clear --
;	28 still turn block
;	29 note block
;	2A question block
;	2B side bounce block
;	2C another bounce sprite
;	2D another bounce sprite
;	2E another bounce sprite
;
;	2F -- about to clear --
;	30 block hitbox
;	31 yellow yoshi landing hitbox
;
;	32 -- about to clear --
;	33+ custom


macro remap(source, reg)
	org <source>+1
	dw <reg>
	!DebugRemapCount := !DebugRemapCount+1
endmacro

macro index(source, index)
	org <source>+1
	db <index>
	!DebugRemapCount := !DebugRemapCount+1
endmacro

	org $13F800
	pushpc
	org $028B05		;\ remove minor extended call
	NOP #3			;/
	org $029040		;\ remove bounce call
	NOP #3			;/
	org $029043		;\ remove quake call
	NOP #3			;/
	org $029046		;\ remove smoke call
	NOP #3			;/
	org $028B11		;\ remove coin call
	NOP #3			;/
	org $029B0A		;\
	JSL HandleEx		; | expand extended to include all types
	RTS			;/


	; kill score sprites
	org $00F388
		RTL		; prevent score sprite spawn
		NOP
		RTL		; RTL second entry point as well
	BubbleOffsetY:		; use this extra space to map extra bubble coordinates
		db $10,$16,$13,$1C
		db $10,$16,$13,$1C
	BubbleOffsetX:
		db $00,$04,$0A,$07
		db $08,$03,$02,$02
	org $00FE26+1
		dw BubbleOffsetY
	org $00FE35+1
		dw BubbleOffsetX

	org $028B0B
		BRA $01 : NOP	; prevent score sprite call
	org $029AA8
		BRA $2A		;\ prevent coin from becoming a score sprite
		NOP #$2A	;/
	org $02A43D
		RTS		;\ don't spawn score sprite
		NOP #3		;/
	org $02ACE5		;\ don't spawn score sprite
		RTL		;/ (main call)
	org $02ACEF
		RTL		; don't spawn score sprite
	org $02AD34
		RTL		; don't search score sprite table
	org $02ADA4
		RTS		; remove score sprite engine
	org $02FF6C
		RTS		; don't spawn score sprite

	pullpc

	BounceNumCalc:
		CLC : ADC #!BounceOffset+1	; we're overwriting an INC A, so we need to add +1 here
		STA !Ex_Num,y
		RTL

	BounceSetInit:
		ORA #$80 : STA !Ex_Num,x	; set init flag
		PEA $9085-1			; RTS address: $9085
		JML $0291B8			; execute invisible solid block routine

	BounceSetInit2:
		BMI .Main

		.Init
		ORA #$80 : STA !Ex_Num,x	; set init flag
		JML $0290ED			; return

		.Main
		JML $02910B			; return

	BounceRemapTile:
		AND #$7F
		TAX
		LDA $91F0-!BounceOffset,x
		RTL

	BounceCheck07:
		LDA !Ex_Num,x
		AND #$7F
		CMP #$07+!BounceOffset
		RTL

	BounceCheck06:
		PHA
		LDA !Ex_Num,x
		AND #$7F
		TAY
		PLA
		CPY #$06+!BounceOffset
		RTL


	FixSparkleOffset:
	.Init	REP #$20
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$00FF
		CLC : ADC $96
		STA $00
		LDA $748E
		AND #$000F
		SEC : SBC #$0002
		CLC : ADC $94
		STA $02
		SEP #$20
		RTL

	.Main	STA !Ex_Data1,y
		LDA $01 : STA !Ex_YHi,y
		LDA $03 : STA !Ex_XHi,y
		RTL

	GlitterSparkleFix:
	.Init	LDA !Ex_XHi,x : STA $01
		LDA !Ex_YLo,x : STA $02
		LDA !Ex_YHi,x : STA $03
		RTL

	.Main	REP #$20
		LDA $98C2,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $00
		SEP #$20
		STA !Ex_XLo,y
		XBA : STA !Ex_XHi,y
		REP #$20
		LDA $98C6,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $02
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y
		RTL

	ZSpawnFix:
		STA !Ex_YLo,y
		LDA $3240,x : STA !Ex_YHi,y
		LDA $3250,x
		ADC #$00				; hi bit still in carry so this is fine
		STA !Ex_XHi,y
		RTL

	SmokeSpawn:
		.SpritePlus0001
		PEI ($0E)
		STA !Ex_Num,y
		LDA $3220,x : STA $0E
		LDA $3250,x : STA $0F
		REP #$20
		LDA $00
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $0E
		SEP #$20
		STA !Ex_XLo,y
		XBA : STA !Ex_XHi,y
		LDA $3210,x : STA $0E
		LDA $3240,x : STA $0F
		REP #$20
		LDA $01
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $0E
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y
		REP #$20
		PLA : STA $0E
		SEP #$20
		JMP .Finish

		.Block
		STA !Ex_Num,y
		LDA $7933 : BNE ..layer2
		..layer1
		LDA $9A
		AND #$F0
		STA !Ex_XLo,y
		LDA $9B : STA !Ex_XHi,y
		LDA $98
		AND #$F0
		STA !Ex_YLo,y
		LDA $99 : STA !Ex_YHi,y
		JMP .Finish
		..layer2
		REP #$20
		LDA $9A
		SEC : SBC $26
		SEP #$20
		STA !Ex_XLo,y
		XBA : STA !Ex_XHi,y
		REP #$20
		LDA $98
		SEC : SBC $28
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y
		JMP .Finish

		.Sprite
		STA !Ex_Num,y
		LDA $3220,x : STA !Ex_XLo,y
		LDA $3250,x : STA !Ex_XHi,y
		LDA $3210,x : STA !Ex_YLo,y
		LDA $3240,x : STA !Ex_YHi,y
		BRA .Finish

		.Mario8
		STA !Ex_Num,y
		REP #$20
		LDA $94
		CLC : ADC #$0004
		SEP #$20
		STA !Ex_XLo,y
		XBA : STA !Ex_XHi,y
		REP #$20
		LDA $96
		CLC : ADC #$001A
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y
		BRA .Finish

		.Mario16
		STA !Ex_Num,y
		LDA $94 : STA !Ex_XLo,y
		LDA $95 : STA !Ex_XHi,y
		REP #$20
		LDA $96
		CLC : ADC #$0014
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y
		BRA .Finish

		.MarioSpecial
		STA !Ex_Num,y
		LDA $94 : STA !Ex_XLo,y
		LDA $95 : STA !Ex_XHi,y
		REP #$20
		LDA $96
		CLC : ADC #$0008
		SEP #$20
		STA !Ex_YLo,y
		XBA : STA !Ex_YHi,y

		.Finish
		LDA !Ex_Num,y
		AND #$7F
		SEC : SBC.b #!SmokeOffset
		PHX
		TAX
		LDA.l .Timer,x : STA !Ex_Data1,y
		PLX
		RTL

		.Timer
		;   00  01  02  03  04  05
		db $00,$1B,$08,$13,$00,$10

		.SpriteX
		PHX
		PHY
		PHX
		PHY
		PLX
		PLY
		JSL .Sprite
		PLY
		PLX
		RTL


	TransformCoordinates:
		LDA !Ex_XLo,x
		SBC $26					; small optimization, carry already set
		STA !Ex_XLo,x
		LDA !Ex_XHi,x
		SBC $27
		STA !Ex_XHi,x
		LDA !Ex_YLo,x
		SEC : SBC $28
		STA !Ex_YLo,x
		LDA !Ex_YHi,x
		SBC $29
		STA !Ex_YHi,x
		RTL


	HandleEx:
		LDX #!Ex_Amount-1		; full index
		LDA $64 : PHA			; preserve this

	.Loop	STX $75E9			; store index
		STX $7698			; store index
		PHX				; just in case

		LDA !DizzyEffect : BEQ +
		REP #$20
		LDA !CameraBackupY : STA $1C
		SEP #$20
		LDA !Ex_XHi,x : XBA
		LDA !Ex_XLo,x
		REP #$20
		SEC : SBC $1A
		AND #$00FF
		LSR #3
		ASL A
		PHX
		TAX
		LDA $40A040,x
		AND #$01FF
		CMP #$0100
		BCC $03 : ORA #$FE00
		STA $1C
		PLX
		SEP #$20
		+

		LDA !Ex_Num,x
		AND #$7F : BEQ .Clear

		PHA
		TAX
		LDA.l .PalsetIndex,x : BMI .PalsetDone	; if index is negative, keep the current one
		STA $0F
		LDA.l !LoadPalset : STA $00
		LDA.l !LoadPalset+1 : STA $01
		LDA.l !LoadPalset+2 : STA $02
		LDA $0F
		PHK : PEA.w .PalsetReturn-1
		JML [$3000]
		.PalsetReturn
		LDX $0F
		LDA !GFX_status+$180,x
		ASL A
		LDX $75E9
	; this will sometimes store 0xFF!
		STA !Ex_Palset,x

		.PalsetDone
		LDX $75E9
		LDA $64
		AND #$F0
		ORA !Ex_Palset,x
		STA $64

		PLA
		CMP #!MinorOffset : BEQ .Clear
		CMP #!ExtendedOffset : BEQ .Clear
		CMP #!SmokeOffset : BEQ .Clear
		CMP #!BounceOffset : BEQ .Clear
		CMP #!QuakeOffset : BEQ .Clear
		CMP #!CustomOffset : BNE .GetNum

	.Clear
		STZ !Ex_Num,x
		STZ !Ex_Data1,x
		STZ !Ex_Data2,x
		STZ !Ex_Data3,x
		STZ !Ex_XLo,x
		STZ !Ex_XHi,x
		STZ !Ex_YLo,x
		STZ !Ex_YHi,x
		STZ !Ex_XSpeed,x
		STZ !Ex_YSpeed,x
		STZ !Ex_XFraction,x
		STZ !Ex_YFraction,x
		LDA #$FF : STA !Ex_Palset,x

	.Return
		PLX				; restore X
		DEX : BMI $03 : JMP .Loop

		PHP
		REP #$20
		LDA !DizzyEffect
		AND #$00FF : BEQ +
		LDA !CameraBackupY : STA $1C
	+	PLP
		PLA : STA $64			; restore this
		RTL

	.GetNum
		CMP #$01 : BEQ .Coin
		CMP #$0C+!MinorOffset : BCC .MinorExtended
		CMP #$13+!ExtendedOffset : BCC .Extended
		CMP #$06+!SmokeOffset : BCC .Smoke
		CMP #$08+!BounceOffset : BCC .Bounce
		CMP #$03+!QuakeOffset : BCC .Quake
		CMP.b #((.CustomPtr_End-.CustomPtr)/2)+!CustomOffset+1 : BCC .Custom
		BRA .Clear			; invalid numbers should be cleared

	.Coin
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $0299F1			; process coin

	.MinorExtended
		SEC : SBC #!MinorOffset		; subtract offset
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $028B94			; execute minor extended pointer

	.Extended
		SEC : SBC #!ExtendedOffset	; subtract offset
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $029B1B			; execute extended pointer

	.Smoke
		SEC : SBC #!SmokeOffset		; subtract offset
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $0296C7			; execute smoke pointer

	.Bounce
		SEC : SBC #!BounceOffset	; subtract offset
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $029052			; execute bounce pointer

	.Quake
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $02939D			; process quake

	.Custom
		SEC : SBC #!CustomOffset+1
		PEA .Return-1
		ASL A
		TAX
		JMP (.CustomPtr,x)

		.CustomPtr
		dw DizzyStar
		dw LuigiFireball
		dw BigFireball
		..End


	.PalsetIndex
		db $00	; 00 - empty
		db $0A	; 01 - coin, yellow
		db $00	; 02 - empty
		db $0A	; 03 - brick piece, yellow
		db $0B	; 04 - small star, blue
		db $00	; 05 - unused
		db $0C	; 06 - fire particle, red
		db $0B	; 07 - blue sparkle, blue
		db $0B	; 08 - Z, blue
		db $0B	; 09 - water splash, blue
		db $00	; 0A - unused
		db $00	; 0B - unused
		db $0F	; 0C - boo stream, ghost
		db $00	; 0D - unused
		db $00	; 0E - empty
		db $0A	; 0F - smoke puff, yellow
		db $0A	; 10 - enemy fireball, yellow (for big/reznor version, use custom 35)
		db $0A	; 11 - tiny flame, yellow
		db $0B	; 12 - hammer, blue
		db $0A	; 13 - mario fireball, yellow
		db $0E	; 14 - bone, grey
		db $0C	; 15 - lava splash, red
		db $0E	; 16 - torpedo ted arm, grey
		db $FF	; 17 - malleable extended sprite, should be set at spawn!
		db $0A	; 18 - coin from coin cloud, yellow
		db $0A	; 19 - piranha fireball, yellow
		db $0C	; 1A - volcano lotus fire
		db $0C	; 1B - baseball, red
		db $0D	; 1C - wiggler's flower, green
		db $0A	; 1D - puff of smoke, yellow
		db $0A	; 1E - spin jump star, yellow
		db $0C	; 1F - yoshi fireball, red
		db $0B	; 20 - water bubble, blue
		db $00	; 21 - empty
		db $0A	; 22 - puff of smoke, yellow
		db $0A	; 23 - contact, yellow
		db $0A	; 24 - turn smoke, yellow
		db $00	; 25 - unused
		db $0A	; 26 - glitter, yellow
		db $00	; 27 - empty
		db $0A	; 28 - still turn block, yellow
		db $0A	; 29 - note block, yellow
		db $0A	; 2A - question block, yellow
		db $0A	; 2B - side bounce block, yellow
		db $0A	; 2C - unknown bounce sprite, yellow
		db $0A	; 2D - unknown bounce sprite, yellow
		db $0A	; 2E - unknown bounce sprite, yellow
		db $00	; 2F - empty
		db $00	; 30 - block hitbox
		db $00	; 31 - yellow yoshi landing hitbox
		db $00	; 32 - empty
		db $0A	; 33 - dizzy star, yellow
		db $01	; 34 - luigi fireball, luigi palset
		db $0A	; 35 - big fireball, yellow
		..End


	; data 1: --ppssss
	; pp	= which player to attach to
	; ssss	= which sprite to attach to if pp = 0
	;
	; data 2: timer
	; data 3: y offset to attachment

	DizzyStar:
		LDX $75E9
		LDA !Ex_Data2,x : BNE .Go
	.Kill	STZ !Ex_Num,x
		RTS

	.Go	LDA $14
		AND #$03 : BNE +
		DEC !Ex_Data2,x
		+

		LDA !Ex_Data1,x
		CMP #$10 : BCC .Sprite
		CMP #$30 : BCS .Sprite

	.Player
		ASL #2
		AND #$80
		TAY
		LDA !P2Status-$80,y : BNE .Kill
		LDA !P2XPosLo-$80,y : STA !Ex_XLo,x
		LDA !P2XPosHi-$80,y : STA !Ex_XHi,x
		STZ $00
		LDA !Ex_Data3,x
		BPL $02 : DEC $00
		CLC : ADC !P2YPosLo-$80,y
		STA !Ex_YLo,x
		LDA $00
		ADC !P2YPosHi-$80,y
		STA !Ex_YHi,x
		BRA .Graphics

	.Sprite
		AND #$0F
		TAY
		LDA $3230,y : BEQ .Kill
		LDA $3220,y : STA !Ex_XLo,x
		LDA $3250,y : STA !Ex_XHi,x
		STZ $00
		LDA !Ex_Data3,x
		BPL $02 : DEC $00
		CLC : ADC $3210,y
		STA !Ex_YLo,x
		LDA $00
		ADC $3240,y
		STA !Ex_YHi,x

	.Graphics
		REP #$20
		STZ $0C
		JSR .Draw
		LDA #$0155 : STA $0C
		JSR .Draw
		LDA #$02AA : STA $0C
		JSR .Draw
		SEP #$30
		RTS


		.Draw
		LDA !Ex_XLo,x : STA $00
		LDA !Ex_XHi,x : STA $01
		LDA !Ex_YLo,x : STA $02
		LDA !Ex_YHi,x : STA $03
		REP #$20
		STZ $0E
		LDA $14
		LDY !Ex_Data2,x
		CPY #$40 : BCC +
		ASL A
	+	CPY #$20 : BCC +
		ASL A
	+	AND #$00FF
		ASL #2
		CLC : ADC $0C
		AND #$03FF
		STA $04				; angle
		CMP #$0200
		BCC $02 : DEC $0E
		AND #$01FE
		REP #$10
		TAX
		LDA.l !TrigTable,x
		EOR $0E
		BPL $01 : INC A
		CLC : ADC #$0100
		LSR #4
		CLC : ADC $00
		SEC : SBC #$000C
		SEC : SBC $1A
		STA $00
		CMP #$FFF8 : BCS .GoodX
		CMP #$0100 : BCC .GoodX
	.BadCoord
		SEP #$10
		REP #$20
		LDX $75E9
		RTS

	.GoodX	LDA $02
		SEC : SBC $1C
		CMP #$FFF8 : BCS .GoodY
		CMP #$00E0 : BCS .BadCoord

	.GoodY	SEP #$10
		LDY $05
		CPY #$01 : BEQ .HiPrio
		CPY #$02 : BEQ .HiPrio

	.LoPrio
		STA $02
		LDY #$FC
	-	LDA !OAM+$101,y
		AND #$00FF
		CMP #$00F0 : BEQ +
		DEY #4
		CPY #$FC : BCC -
		LDX $75E9
		RTS

	+	LDA $02 : STA !OAM+$101,y
		LDA #$3448 : STA !OAM+$102,y
		SEP #$30
		LDA $00 : STA !OAM+$100,y
		LDX $75E9
		TYA
		LSR #2
		TAY
		LDA $01
		AND #$01
		STA !OAMhi+$40,y
		REP #$20
		RTS

	.HiPrio
		LDY !OAMindex
		STA !OAM+$001,y
		LDA #$3448 : STA !OAM+$002,y
		SEP #$20
		LDA $00 : STA !OAM+$000,y
		LDX $75E9
		PHY
		TYA
		LSR #2
		TAY
		LDA $01
		AND #$01
		STA !OAMhi+$00,y
		PLA
		CLC : ADC #$04
		STA !OAMindex
		REP #$20
		RTS


	LuigiFireball:
		LDX $75E9

		LDA !Ex_YLo,x : PHA
		LDA !Ex_YHi,x : PHA
		STZ !Ex_YSpeed,x
		LDA !GFX_SmallFireball : PHA
		LDA !GFX_LuigiFireball : STA !GFX_SmallFireball

		PHK : PEA.w .Return-1
		PEA $8B66-1			; point to RTL
		JML $029FAF

		.Return
		PLA : STA !GFX_SmallFireball
		PLA : STA !Ex_YHi,x
		PLA : STA !Ex_YLo,x
		RTS

	BigFireball:
		LDX $75E9
		PHK : PEA.w .Return-1
		PEA $8B66-1
		JML $02A16B			; enemy fireball code
		.Return
		RTS


;
; input:
;	JSL followed by table, returns to first byte after table
; table format:
;	header (number of per-tile bytes to read, highest bit is p (0 = use $64, 1 = use PP bits))
;	GFX status index
;	for each tile:
;		Xdisp
;		Ydisp
;		tile
;		YXPP--sp
;	YX bits are written directly
;	PP bits are written directly if p is set, otherwise $64 is used
;	s is used as size bit
;
; $00 - 16-bit	Xpos
; $02 - 16-bit	Ypos
; $04 - 24-bit	pointer
; $07 - 8-bit	index to stop reading at
; $08 - 8-bit	p flag
; $0A -
; $0C - 8-bit	tile offset from GFX status
; $0D - 8-bit	hi bit of tile number from GFX status
; $0E - 16-bit	working Xpos

	DisplayGFX:
		REP #$20				;\
		LDA $01,s				; |
		INC A					; | pointer to first byte after JSL instruction
		STA $04					; |
		SEP #$20				; |
		LDA $03,s : STA $06			;/
		REP #$20				;\
		LDA [$04]				; |
		AND #$007F				; |
		STA $07					; > save header in RAM
		INC #2					; |
		CLC : ADC $01,s				; > update return address
		STA $01,s				;/
		LDA [$04]				;\
		AND #$0080				; | p flag
		STA $08					;/
		INC $04					;\
		LDA [$04]				; |
		INC $04					; | read GFX status index and increment past header bytes
		SEP #$20				; | (now ready to read per-tile data)
		STA $0F					;/

		PHX					; > push X
		LDA !Ex_XLo,x : STA $00			;\
		LDA !Ex_XHi,x : STA $01			; | base coordinates
		LDA !Ex_YLo,x : STA $02			; |
		LDA !Ex_YHi,x : STA $03			;/
		LDA !Ex_Palset,x			;\
		AND #$0E				; | CCC bits
		STA $0D					;/
		BIT $08 : BMI .Skip64			; p bit
	.Set64	LDA $64					;\
		AND #$30				; | add PP bits from $64
		TSB $0D					;/
	.Skip64	LDX $0F					;\
		CPX #$FF : BNE +			; | (0xFF means offset 0)
		STZ $0C					; |
		BRA ++					; |
	+	LDA !GFX_status,x : STA $0F		; |
		AND #$70				; |
		ASL A					; |
		STA $0C					; | unpack GFX offset
		LDA $0F					; |
		AND #$0F				; |
		TSB $0C					; |
		LDA $0F					; |
		BPL $02 : INC $0D			; |
		++					;/

		LDX !OAMindex				; X = OAM index
		LDY #$00				; Y = per-tile data

		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		CMP #$0110 : BCC +
		CMP #$FFE0 : BCC .Despawn
	+	LDA $02
		SEC : SBC $1C
		STA $02
		CMP #$00F0 : BCC .Loop
		CMP #$FFE0 : BCS .Loop

	.Despawn
		SEP #$20
		PLX
		STZ !Ex_Num,x
		STZ $00
		RTL

	.BadX	INY					;\
	.BadY	INY #3					; | off-screen: go to next tile
		SEP #$20				; |
		BRA .Next				;/

	.Loop	REP #$20				; A 16-bit
		LDA [$04],y				;\
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; | check X
		CLC : ADC $00				; |
		CMP #$0100 : BCC .GoodX			; |
		CMP #$FFF0 : BCC .BadX			;/

	.GoodX	AND #$01FF				;\ store 9-bit X in scratch RAM
		STA $0E					;/
		INY					;\
		LDA [$04],y				; |
		AND #$00FF				; |
		CMP #$0080				; | check Y
		BCC $03 : ORA #$FF00			; |
		CLC : ADC $02				; |
		CMP #$00E0 : BCC .GoodY			; |
		CMP #$FFF0 : BCC .BadY			;/
	.GoodY	STA !OAM+$001,x				; store Y
		SEP #$20				; A 8-bit
		LDA $0E : STA !OAM+$000,x		; store X lo
		INY					;\
		LDA [$04],y				; | store tile number
		CLC : ADC $0C				; |
		STA !OAM+$002,x				;/
		INY					;\
		LDA [$04],y				; |
		BIT $08 : BPL .64			; |
	.PP	AND #$F0 : BRA .Prop			; | store YXPPCCCT
	.64	AND #$30				; |
	.Prop	ORA $0D					; |
		STA !OAM+$003,x				;/
		PHX					;\
		TXA					; |
		LSR #2					; |
		TAX					; |
		LDA [$04],y				; | store hi byte
		AND #$02				; |
		ORA $0F					; |
		STA !OAMhi+$00,x			; |
		PLX					; |
		INY					;/
		INX #4					; increment OAM index
	.Next	CPY $07 : BCC .Loop			; loop

		STZ $00					;\
		TXA					; |
		SEC : SBC !OAMindex			; | return $00 = number of tiles written
		LSR #2					; |
		STA $00					;/
		STX !OAMindex				; update OAM index
		PLX					; pull X
		RTL					; return


	HammerSpinJump:
		JSL !CheckContact
		BCS .Contact
		JML $02A468				; > return with no contact
.Contact	LDA !Ex_Num,x
		CMP #$04+!ExtendedOffset : BNE .NoHammer
		LDA !Ex_Data3,x
		LSR A : BCS .Return
		LDA !MarioSpinJump : BNE .SpinHammer
		BRA .NoHammer

.SpinHammer	JSL !BouncePlayer
		JSL !ContactGFX
		LDA #$02 : STA !SPC1
		LDA #$40 : STA !Ex_YSpeed,x
		STZ !Ex_XSpeed,x
		LDA !Ex_Data3,x				; mark hammer as owned by player
		ORA #$01
		STA !Ex_Data3,x
.Return		JML $02A468				; > return
.NoHammer	JML $02A40E				; > non-hammer code


	; GenerateHammer starts at $02DAC3.

	HammerSpawn:
		LDA #$04+!ExtendedOffset : STA !Ex_Num,y
		LDA #$00 : STA !Ex_Data3,y
		JML $02DAC8

	HammerWaterCheck:
		PHX
		LDA !Ex_XLo,x : STA $00
		LDA !Ex_XHi,x : STA $01
		LDA !Ex_YLo,x : STA $02
		LDA !Ex_YHi,x : STA $03
		REP #$10
		LDA !IceLevel : BNE .No3D
		LDA !3DWater : BEQ .No3D
		LDY $02 : BMI .No3D
		CPY !Level+2 : BCS .Water
	.No3D	LDX $00
		LDY $02
		JSL !GetMap16
		CMP #$0006 : BCS .NoWater

	.Water	SEP #$30
		PLX
		LDA $9D : BNE .02A30C
		TXA
		CLC : ADC $14
		AND #$01 : BNE .02A2F3
	.02A2F9	JML $02A2F9

	.NoWater
		SEP #$30
	.Return	PLX
		LDA $9D : BNE .02A30C
	.02A2F3	JML $02A2F3
	.02A30C	JML $02A30C


incsrc "MalleableExtendedSprite.asm"



	; -- coin gfx fix --
	; (coin needs no fix)

	; -- minor gfx fix --
	org $028FCA
	BrickPiece:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA $14
		LSR A
		CLC : ADC $7698
		AND #$07
		TAY
		LDA $8B84,y
		LDY !OAMindex
		STA !OAM+$002-4,y
		LDA !Ex_Data1,x : BEQ .Return
		LDA !OAM+$003-4,y
		AND.b #$0E^$FF
		STA $00
		LDA $14
		AND #$0E
		ORA $00
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02902D

	org $028EE1
	Sparkles:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #3
		TAY
		LDA !Ex_Num,x
		CMP #$02+!MinorOffset : BEQ .SmallStar
		.BlueSparkle
		INY #3
		.SmallStar
		LDA $8ECC,y				; same table but different offsets
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $028F2B

	org $028F4D
	FireParticle:
		JSL DisplayGFX
		db $04,!GFX_LavaEffects-!GFX_status
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #3
		TAY
		LDA $8F2B,y
		CLC : ADC $0C
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS

	org $028E20
	Z:
		JSL DisplayGFX
		db $04,!GFX_RipVanFish-!GFX_status
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #5
		AND #$03
		TAY
		LDA $8DD7,y
		CLC : ADC $0C
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $028E76

	org $028DEA
		BNE +
		STZ !Ex_Num,x		; make Z actually despawn when timer runs out
		RTS
		NOP
		+
	warnpc $028DF1

	org $028D42			; water splash tile table
		db $00,$00,$02,$02,$02	; $68 -> $00, $6A -> $02
	org $028D8B
	WaterSplash:
		LDA !Ex_Data1,x
		INC !Ex_Data1,x
		LSR A
		CMP #$0C
		BCC $02 : LDA #$0C
		TAY
		LDA $8D42,y : BEQ .Water00
		CMP #$02 : BEQ .Water02
		CMP #$66 : BNE .Smoke16x16		; catch 8x8 smoke tile
		.Smoke8x8
		JMP Smoke01_8
		.Smoke16x16
		PHA
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$02
		PLA
		LDY $00 : BEQ .Return
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
		.Water00
		JSL DisplayGFX
		db $04,!GFX_WaterEffects-!GFX_status
		db $00,$00,$00,$02
		RTS
		.Water02
		JSL DisplayGFX
		db $04,!GFX_WaterEffects-!GFX_status
		db $00,$00,$02,$02
		RTS
	warnpc $028DD7

	org $028CFF
	BooStream:
		JSL DisplayGFX
		db $04,!GFX_Boo-!GFX_status
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY !OAMindex
		PHX
		TXA
		AND #$0B
		TAX
		LDA $8CB8,x
		PLX
		CLC : ADC !OAM+$002-4,y
		STA !OAM+$002-4,y
		LDA !Ex_XSpeed,x
		LSR A
		AND #$40
		ORA !OAM+$003-4,y
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $028D42


	; -- extended gfx fix --
	org $02A362
	SmokeExtended:
		LDA !Ex_Data2,x
		LSR #2
		TAY
		LDA $A347,y
		CMP #$66 : BNE .16
	.8	JMP Smoke01_8

	.16	JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDA !Ex_Data2,x
		LSR #2
		TAY
		LDA $A347,y
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $02A3AE

	org $02A178
	EnemyFireball:
		LDA !Ex_Num,x					;\ if num  = extended 02, this looks like mario's fireball
		CMP #$02+!ExtendedOffset : BEQ MarioFireball	;/ otherwise, it's a big fireball
		JSL DisplayGFX
		db $04,!GFX_ReznorFireball-!GFX_status
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY !OAMindex
		LDA !OAM+$003-4,y
		AND #$3F
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02A1A4

	org $02A232
	TinyFlame:
		JSL DisplayGFX
		db $04,!GFX_HoppingFlame
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		AND #$04
		LSR #2
		TAY
		LDA $A217,y
		ADC $0C			; trick due to VERY limited space: the LSR always clears C
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $02A254

	org $02A405
		JML HammerSpinJump
	org $02DAC3
		JML HammerSpawn		; org: LDA #$04 : STA $170B,y
		NOP
	org $02A2EF
		JML HammerWaterCheck	; org: LDA $9D : BNE $19 ($02A30C)

	org $02A317
	Hammer:
		JSL DisplayGFX
		db $04,!GFX_Hammer-!GFX_status
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY !OAMindex
		LDA !OAM+$003-4,y
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02A344

	org $029FB3
		BRA 13 : NOP #13
	warnpc $029FC2
	org $02A03B
		JMP MarioFireball
	org $02A1A4
	MarioFireball:
		JSL DisplayGFX
		db $04,!GFX_SmallFireball-!GFX_status
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDY !OAMindex
		LDA !OAM+$003-4,y
		AND #$3F
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02A211

	org $02A2C3
	Bone:
		JSL DisplayGFX
		db $04,!GFX_Bone-!GFX_status
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		TXA
		AND #$01
		BEQ $02 : LDA #$C0
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
		LDY !OAMindex
		ORA !OAM+$003-4,y
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02A2EF			; we can overwrite the hammer tile table since it's unused
	org $03C44E
		BRA 6 : NOP #6		; spawn bone even if dry bones is off-screen
	warnpc $03C456

	org $029E9D
	LavaSplash:
		JSL DisplayGFX
		db $00,!GFX_LavaEffects-!GFX_status
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data2,x
		LSR #3
		AND #$03
		TAY
		LDA $9E82,y
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $029EE6

	org $029E39
	Code_029E39:

	org $029E3D
	TorpedoTedArm:
		LDY #$00
		LDA !Ex_Data2,x : BEQ Code_029E39
		CMP #$60 : BCS .Speed
		INY
		CMP #$30 : BCS .Speed
		INY
	.Speed	LDA $9D : BNE .GFX
		LDA $9E36,y : STA !Ex_YSpeed,x
		JSR $B560
	.GFX	LDA !Ex_Data2,x
		CMP #$60 : BCC .Tile08
	.Tile06	JSL DisplayGFX
		db $84,!GFX_TorpedoTed-!GFX_status
		db $00,$00,$06,$12
		RTS
	.Tile08	JSL DisplayGFX
		db $84,!GFX_TorpedoTed-!GFX_status
		db $00,$00,$08,$12
		RTS
	warnpc $029E82

	org $02A313
	EnemyFireballWithGravity:
		JSR MarioFireball
	warnpc $02A316

	org $029B51
	LotusPollen:
		LDA $14
		LSR A
		EOR $75E9
		LSR #2
		BCC .Tile10
	.Tile00	JSL DisplayGFX
		db $04,!GFX_LotusPollen-!GFX_status
		db $00,$00,$00,$00
		BRA .Done
	.Tile10	JSL DisplayGFX
		db $04,!GFX_LotusPollen-!GFX_status
		db $00,$00,$10,$00
		BRA .Done
	warnpc $029BA5
	org $029BA5
	.Done

	org $02A271
	Baseball:
		JSL DisplayGFX
		db $04,!GFX_Baseball-!GFX_status
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		TXA
		AND #$01
		BEQ $02 : LDA #$C0
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
		LDY !OAMindex
		ORA !OAM+$003-4,y
		STA !OAM+$003-4,y
	.Return	RTS
	warnpc $02A2BF
	org $02C466
		LDA $32F0,x			;\ spawn baseball even if chuck is off-screen
		BEQ $03 : RTS : NOP #2		;/
	warnpc $02C46E

	org $029C88
	SpinJumpStars:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$48,$00
		BRA .Done
	warnpc $029C98
	org $029C98
		.Done

	org $029F2A
	Bubble:
		LDA !Ex_Data1,x
		LSR #2
		AND #$03
		TAY
		LDA $9EEA,y
		BEQ .Disp00
		BMI .DispFF
	.Disp01	JSL DisplayGFX
		db $04,!GFX_WaterEffects-!GFX_status
		db $01,$05,$04,$00
		RTS
	.Disp00	JSL DisplayGFX
		db $04,!GFX_WaterEffects-!GFX_status
		db $00,$05,$04,$00
		RTS
	.DispFF	JSL DisplayGFX
		db $04,!GFX_WaterEffects-!GFX_status
		db $FF,$05,$04,$00
		RTS
	warnpc $029F61


	; -- smoke gfx fix --
	org $02999F
	SmokeGeneric:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY !OAMindex
		LDA !Ex_Data1,x
		LSR #2
		TAX
		LDA $9922,x : STA !OAM+$102-4,y
	.Return	LDX $7698
		RTS

	org $029701
	Smoke01:
		LDA !Ex_Data1,x
		LSR #2
		TAY
		LDA $96D8,y
		CMP #$66 : BNE .16
	.8	JSL DisplayGFX
		db $04,$FF
		db $04,$04,$5E,$00
		RTS

	.16	JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #2
		TAY
		LDA $96D8,y
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	warnpc $02974A
	org $02974A
		JMP Smoke01

	org $0297B2
	ContactGFX:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$66,$02
		LDA $00 : BEQ .Return
		LDY !Ex_Data1,x
		LDA.w .Tiles,y
		LDY !OAMindex
		STA !OAM+$002-4,y
	.Return	RTS
	.Tiles	db $6A,$6A,$6A,$68,$68,$68,$66,$66

	org $029936
		JMP $9793		; skip a pointless code that just writes 0xF0 to OAM Y

	org $02996F
	TurnSmoke:
		JSL DisplayGFX
		db $04,$FF
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDY !OAMindex
		PHX
		LDA !Ex_Data1,x
		LSR #2
		TAX
		LDA.w $9922,x : STA !OAM+$002-4,y
		PLX
	.Return	RTS



	; to DO:
	; integrate GFX_expand edits
	; test EVERYTHING
	; make sure new GFX code works




;===================;
; REMAP STUFF BELOW ;
;===================;


;	table size:
	%index($01F7EC, !Ex_Amount-1)		;\
	%index($028677, !Ex_Amount-1)		; |
	%index($0298E9, !Ex_Amount-1)		; | minor extended (index mem)
	%index($02C0FF, !Ex_Amount-1)		; |
	%index($03902F, !Ex_Amount-1)		;/
	%index($00FDA9, !Ex_Amount-1)		;\
	%index($0284DD, !Ex_Amount-1)		; |
	%index($0285BA, !Ex_Amount-1)		; |
	%index($0285E4, !Ex_Amount-1)		; |
	%index($028668, !Ex_Amount-1)		; | minor extended (spawn checks)
	%index($028BC0, !Ex_Amount-1)		; |
	%index($028C30, !Ex_Amount-1)		; |
	%index($0298DA, !Ex_Amount-1)		; |
	%index($02C0F0, !Ex_Amount-1)		; |
	%index($039020, !Ex_Amount-1)		; |
	%index($03AD69, !Ex_Amount-1)		;/
	%index($028B67, !Ex_Amount-1)		; minor extended (main loop)
	%index($018EFE, !Ex_Amount-1)		; extended (index mem)
	%index($00FD19, !Ex_Amount-1)
	%index($00FDFE, $07)		; special index: loop counter for how many bubbles spawn when mario enters water
;	%index($00FEA8, !Ex_Amount-1) ; mario fireball, special index handled by PCE
	%index($018EEF, !Ex_Amount-1)
	%index($01D3B8, !Ex_Amount-1) ; special case, uses full index
	%index($018EEF, !Ex_Amount-1)
	%index($01FD0A, !Ex_Amount-1) ; special case, uses full index + 1 normally
	%index($028534, !Ex_Amount-1)
	%index($029BF5, !Ex_Amount-1)
	%index($02B422, !Ex_Amount-1)
	%index($02C46E, !Ex_Amount-1)
	%index($02DAB8, !Ex_Amount-1)
	%index($02E085, !Ex_Amount-1)
	%index($02E1C2, !Ex_Amount-1)
	%index($02EFB1, !Ex_Amount-1)
	%index($02F2D7, !Ex_Amount-1)
	%index($039AF8, !Ex_Amount-1)
	%index($03C456, !Ex_Amount-1)
	%index($07FC47, !Ex_Amount-1)
	%index($00FAD4, !Ex_Amount-1) ; this is a loop that clears extended sprites at level end
	%index($039906, !Ex_Amount-1) ; this is a loop that clears extended sprites for reznor
;	%index($029B0A, !Ex_Amount-1)		; extended (main loop, hijacked)
	%index($01C5CC, !Ex_Amount-1)		; smoke (index mem)
	%index($00FB82, !Ex_Amount-1)		;\
	%index($00FD60, !Ex_Amount-1)		; |
	%index($00FE67, !Ex_Amount-1)		; |
	%index($018068, !Ex_Amount-1)		; |
	%index($01AB78, !Ex_Amount-1)		; |
	%index($01AB9F, !Ex_Amount-1)		; |
	%index($01BD98, !Ex_Amount-1)		; | smoke (spawn checks)
	%index($01C4F0, !Ex_Amount-1)		; |
	%index($01C5BD, !Ex_Amount-1)		; |
;	%index($028A45, !Ex_Amount-1)		; | > overwritten by remap, see $028A44
;	%index($029ADA, !Ex_Amount-1)		; | > overwritten by optimization, see $029ADA
;	%index($02A41C, !Ex_Amount-1)		; | > overwritten by optimization, see $02A419
	%index($02B4DE, !Ex_Amount-1)		; |
	%index($02B952, !Ex_Amount-1)		; |
	%index($038A16, !Ex_Amount-1)		;/
	%index($0287A1, !Ex_Amount-1)		; bounce (index mem)
	%index($028792, !Ex_Amount-1)		; bounce (spawn check
	%index($0286ED, !Ex_Amount-1)		;\ quake (spawn check)
	%index($0286ED, !Ex_Amount-1)		;/
	%index($02903B, !Ex_Amount-1)		; main loop for bounce, quake, and smoke sprites
	%index($028A66, !Ex_Amount-1)		; coin (spawn check)
	%index($028A75, !Ex_Amount-1)		; coin (index mem)
	%index($029356, !Ex_Amount-1)		; coin (spawn check)
	%index($0299D2, !Ex_Amount-1)		; coin (main loop)
	%index($00FEB0, $00)			;\
	%index($01D406, $00)			; | special case, minumum fireball index
	%index($01FD4B, $00)			;/

	%index($02B5BE, !Ex_Amount)		; part of minor physics routine
	%index($02B556, !Ex_Amount)		; part of extended physics routine
	%index($02B51C, !Ex_Amount)		; part of bounce physics routine


;	minor extended num writes
	%remap($00FDEA, !Ex_Num)
	%remap($01F7F6, !Ex_Num)
	%remap($028507, !Ex_Num)
	%remap($0285C7, !Ex_Num)
	%remap($0285F5, !Ex_Num)
	%remap($028686, !Ex_Num)
	%remap($028BCD, !Ex_Num)
	%remap($028C3D, !Ex_Num)
	%remap($0298F3, !Ex_Num)
	%remap($02C108, !Ex_Num)
	%remap($039039, !Ex_Num)
	%remap($03AD76, !Ex_Num)
;	minor extended num clears
	%remap($028C66, !Ex_Num)
	%remap($028D62, !Ex_Num)
	%remap($028E76, !Ex_Num)
	%remap($028F87, !Ex_Num)
;	minor extended num reads
	%remap($00FDAB, !Ex_Num)
	%remap($01F7DF, !Ex_Num)
	%remap($0284DF, !Ex_Num)
	%remap($0285BC, !Ex_Num)
	%remap($0285E6, !Ex_Num)
	%remap($02866A, !Ex_Num)
	%remap($028B69, !Ex_Num)
	%remap($028BC2, !Ex_Num)
	%remap($028C32, !Ex_Num)
	%remap($028E02, !Ex_Num)	; num remapped!
;	%remap($028E4F, !Ex_Num)	; num remapped! part of GFX recode
;	%remap($028EFE, !Ex_Num)	; num remapped! part of GFX recode
	%remap($0298DC, !Ex_Num)
	%remap($02C0F2, !Ex_Num)
	%remap($039022, !Ex_Num)
	%remap($03AD6B, !Ex_Num)

;	remap minor extended num writes
	org $00FDE8
		LDA #$07+!MinorOffset
	org $01F7F4
		LDA #$03+!MinorOffset
	org $028505
		LDA #$07+!MinorOffset


	org $0285A9
		JSL FixSparkleOffset_Init	; org: ADC $96 : STA $00
		BRA 11 : NOP #11		; see all.log for reference
	warnpc $0285BA
	org $0285DB
		JML FixSparkleOffset_Main	; org: STA !Ex_Data,y : RTL
	warnpc $0285DF
	org $0285C5
		LDA #$05+!MinorOffset


	org $0285F3
		LDA #$04+!MinorOffset
	org $028684
		LDA #$01+!MinorOffset
	org $028BCB
		LDA #$0B+!MinorOffset
	org $028C3B
		LDA #$0B+!MinorOffset


	org $0298F1
		LDA #$02+!MinorOffset
	org $0298F6
		JSL GlitterSparkleFix_Init	;\ org: LDA !Ex_YLo,x : STA $01
		NOP				;/
	org $029909
		JSL GlitterSparkleFix_Main	; org: LDA $98C2,x : CLC
		BRA 12 : NOP #12
	warnpc $02991B


	org $02C0D9
		LDA #$06+!MinorOffset
	org $02C115
		JSL ZSpawnFix			;\ org: CLC : ADC #$00 : STA !Ex_YLo,y
		NOP #2				;/

	org $039037
		LDA #$0A+!MinorOffset
	org $03AD74
		LDA #$05+!MinorOffset


;	remap minor extended num reads
	org $028E05
		CPY #$09+!MinorOffset
	org $028E52
		CMP #$08+!MinorOffset
	org $028F0A
		CMP #$05+!MinorOffset


;	extended num writes
	%remap($00FD28, !Ex_Num)
	%remap($00FE18, !Ex_Num)
	%remap($00FEC1, !Ex_Num)
	%remap($018F8E, !Ex_Num)
	%remap($01D3EB, !Ex_Num)
	%remap($01F29A, !Ex_Num)
	%remap($01FD38, !Ex_Num)
	%remap($028541, !Ex_Num)
	%remap($029C02, !Ex_Num)
	%remap($02A4E5, !Ex_Num)
	%remap($02B42F, !Ex_Num)
	%remap($02C47B, !Ex_Num)
	%remap($02DAC5, !Ex_Num)
	%remap($02E092, !Ex_Num)
	%remap($02E1CF, !Ex_Num)
	%remap($02EFBE, !Ex_Num)
	%remap($02F2E4, !Ex_Num)
	%remap($039B0A, !Ex_Num)
	%remap($03C463, !Ex_Num)
	%remap($07FC54, !Ex_Num)
;	extended num clears
	%remap($00FAD8, !Ex_Num)
	%remap($029BDA, !Ex_Num)
	%remap($029C7F, !Ex_Num)
	%remap($029D5A, !Ex_Num)
;	%remap($029D99, !Ex_Num)	; part of GFX recode
	%remap($029E39, !Ex_Num)
	%remap($029EE6, !Ex_Num)
;	%remap($02A213, !Ex_Num)	; hijacked by malleable extended sprite
	%remap($02A2BF, !Ex_Num)
	%remap($02A419, !Ex_Num)
	%remap($03990A, !Ex_Num)
;	extended num reads
	%remap($00FD1B, !Ex_Num)
	%remap($00FE05, !Ex_Num)
;	%remap($00FEAA, !Ex_Num)	; mario fireball, special index handled by PCE
	%remap($018EF1, !Ex_Num)
	%remap($01D3BD, !Ex_Num)	; remapped!
	%remap($01FD0F, !Ex_Num)	; remapped!
	%remap($028536, !Ex_Num)
	%remap($029636, !Ex_Num)	; remapped!
	%remap($029649, !Ex_Num)	; remapped!
	%remap($029B16, !Ex_Num)
	%remap($029BF7, !Ex_Num)
	%remap($029CC9, !Ex_Num)	; remapped!
	%remap($029D20, !Ex_Num)	; remapped!
	%remap($02A0E1, !Ex_Num)	; remapped!
	%remap($02A26A, !Ex_Num)	; remapped!
	%remap($02A30C, !Ex_Num)	; remapped!
	%remap($02A40B, !Ex_Num)	; remapped!
	%remap($02A4B5, !Ex_Num)	; remapped!
	%remap($02A519, !Ex_Num)	; remapped! (special case since this is an index, see below)
	%remap($02B424, !Ex_Num)
	%remap($02C470, !Ex_Num)
	%remap($02DABA, !Ex_Num)
	%remap($02E087, !Ex_Num)
	%remap($02E1C4, !Ex_Num)
	%remap($02EFB3, !Ex_Num)
	%remap($02F2D9, !Ex_Num)
	%remap($039AFA, !Ex_Num)
	%remap($03C458, !Ex_Num)
	%remap($07FC49, !Ex_Num)


;	remap extended num writes
	org $00FD26
		LDA #$12+!ExtendedOffset
	org $00FE16
		LDA #$12+!ExtendedOffset
	org $00FEBF
		LDA #$05+!ExtendedOffset
	org $018F8C
		LDA #$03+!ExtendedOffset
	org $01D3E9
		LDA #$01+!ExtendedOffset
	org $01F298
		LDA #$11+!ExtendedOffset
	org $01FD36
		LDA #$01+!ExtendedOffset
	org $02853F
		LDA #$07+!ExtendedOffset
	org $029C00
		LDA #$0F+!ExtendedOffset
	org $02A4E3
		LDA #$01+!ExtendedOffset
	org $02B42D
		LDA #$08+!ExtendedOffset
	org $02C479
		LDA #$0D+!ExtendedOffset
	org $02DAC3
		LDA #$04+!ExtendedOffset
	org $02E090
		LDA #$0C+!ExtendedOffset
	org $02E1CD
		LDA #$0B+!ExtendedOffset
	org $02EFBC
		LDA #$0A+!ExtendedOffset
	org $02F2E2
		LDA #$0E+!ExtendedOffset
	org $039B08
		LDA #$02+!ExtendedOffset
	org $03C461
		LDA #$06+!ExtendedOffset
	org $07FC52
		LDA #$10+!ExtendedOffset

;	remap extended num reads
	org $01D3C0
		CMP #$05+!ExtendedOffset
	org $01FD12
		CMP #$05+!ExtendedOffset
	org $029639
		CMP #$02+!ExtendedOffset
	org $02964C
		CMP #$12+!ExtendedOffset
	org $029CCC
		CMP #$0E+!ExtendedOffset
	org $029D23
		CMP #$0E+!ExtendedOffset
	org $02A0E4
		CMP #$11+!ExtendedOffset
	org $02A26D
		CMP #$0D+!ExtendedOffset
	org $02A30F
		CMP #$0B+!ExtendedOffset
	org $02A40E
		CMP #$0A+!ExtendedOffset
	org $02A4B8
		CMP #$04+!ExtendedOffset
	%remap($02A520, $A4E7-!ExtendedOffset)	; remap hitbox table offset
	%remap($02A52C, $A4FF-!ExtendedOffset)	; remap hitbox table offset
	%remap($02A535, $A4F3-!ExtendedOffset)	; remap hitbox table offset
	%remap($02A541, $A50B-!ExtendedOffset)	; remap hitbox table offset


;	smoke num writes
;	%remap($00FB8F, !Ex_Num)	; overwritten by spawn code
;	%remap($00FD6D, !Ex_Num)	; overwritten by spawn code
;	%remap($00FE74, !Ex_Num)	; overwritten by spawn code
;	%remap($018075, !Ex_Num)	; overwritten by spawn code
;	%remap($01AB85, !Ex_Num)	; removed due to repair, see $01AB83
;	%remap($01ABAC, !Ex_Num)	; overwritten by spawn code
;	%remap($01BDA5, !Ex_Num)	; overwritten by spawn code
;	%remap($01C4FD, !Ex_Num)	; overwritten by spawn code
;	%remap($01C5D6, !Ex_Num)	; overwritten by spawn code
	%remap($01D01C, !Ex_Num) ; not indexed, (used by reznor)
;	%remap($028A52, !Ex_Num)	; overwritten by spawn code
;	%remap($029AE7, !Ex_Num)	; overwritten by optimization, see $029ADA
;	%remap($02A429, !Ex_Num)	; overwritten by optimization, see $02A419
	%remap($02B4ED, !Ex_Num)
;	%remap($02B991, !Ex_Num)	; torpedo ted special, see $02B969
;	%remap($038A23, !Ex_Num)	; overwritten by spawn code
;	smoke num clears
	%remap($0296DF, !Ex_Num)
	%remap($029793, !Ex_Num)
	%remap($0298BE, !Ex_Num)
;	smoke num reads
	%remap($00FB84, !Ex_Num)
	%remap($00FD62, !Ex_Num)
	%remap($00FE69, !Ex_Num)
	%remap($01806A, !Ex_Num)
	%remap($01AB7A, !Ex_Num)
	%remap($01ABA1, !Ex_Num)
	%remap($01BD9A, !Ex_Num)
	%remap($01C4F2, !Ex_Num)
	%remap($01C5BF, !Ex_Num)
	%remap($028A47, !Ex_Num)
	%remap($0296C0, !Ex_Num)
	%remap($0296E8, !Ex_Num)	; this one just checks the highest bit
;	%remap($029ADC, !Ex_Num)	; overwritten by optimization, see $029ADA
;	%remap($02A41E, !Ex_Num)	; overwritten by optimization, see $02A419
	%remap($02B4E0, !Ex_Num)
	%remap($02B954, !Ex_Num)
	%remap($038A18, !Ex_Num)



	; remap smoke num writes
	org $00FB8D
		LDA #$01+!SmokeOffset
		JSL SmokeSpawn_Sprite
		RTS

	org $00FD6B
		LDA #$05+!SmokeOffset
		JSL SmokeSpawn_Block
		RTS

	org $00FE72
		LDA #$03+!SmokeOffset
		JSL SmokeSpawn_Mario8
		RTS

	org $018073
		LDA #$03+!SmokeOffset
		JSL SmokeSpawn_SpritePlus0001
		RTS

	org $01AB83
	;	LDA #$02+!SmokeOffset : STA !Ex_Num,y
	;	LDA ($DE) : STA !Ex_XLo,y	; this is the pointer to sprite X lo
	;	LDA ($DA)			; this is the pointer to sprite Y lo
		JSL SmokeSpawn_Sprite
		PLY
		RTL

	org $01ABAA
		LDA #$02+!SmokeOffset
		JSL SmokeSpawn_Mario16
		PLY
		RTL

	org $01BDA3
		LDA #$01+!SmokeOffset
		JSL SmokeSpawn_SpriteX
		RTS

	org $01C4FB
		LDA #$05+!SmokeOffset
		JSL SmokeSpawn_Sprite
		RTS


	org $01C5D4
		LDA #$81+!SmokeOffset	;?????????
		JSL SmokeSpawn_MarioSpecial
		RTL

	org $01D01A
		LDA #$01+!SmokeOffset		; used for reznor so w/e

	org $028A44
		PHY
		LDY.b #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ +
		DEY: BPL -
		INY
	+	LDA #$01+!SmokeOffset
		JSL SmokeSpawn_Block
		PLY
		RTL

	; turn coin into glitter
	; optimization
	org $029AD7
		RTS
		RTS
		RTS
	warnpc $029ADA
	org $029ADA
		LDA #$05+!SmokeOffset : STA !Ex_Num,x
		LDA !Ex_Data1,x
		LSR A : BCC .Return
		JSL TransformCoordinates
		.Return
		LDA #$10 : STA !Ex_Data1,x
		RTS
	warnpc $029B0A

	;org $029AE5
	;	LDA #$05+!SmokeOffset	; overwritten by optimization, see $029ADA

	org $02A419
		LDA #$05+!SmokeOffset : STA !Ex_Num,x
		LDA #$0A : STA !Ex_Data1,x
		RTS

	;org $02A427
	;	LDA #$05+!SmokeOffset	; overwritten by optimization, see $02A419

	org $02B4EB
		LDA #$01+!SmokeOffset	; shooter, probably irrelevant??

	org $02B94E
		dw $FFF4,$001C		; torpedo ted offsets
	warnpc $02B952

	org $02B969
		LDA ($DE) : STA $00
		LDA $3250,x : STA $01
		PHX
		LDA $3320,x
		ASL A
		TAX
		REP #$20
		LDA $00
		CLC : ADC $B94E,x
		SEP #$20
		PLX
		STA !Ex_XLo,y
		XBA : STA !Ex_XHi,y
		LDA ($DA) : STA !Ex_YLo,y
		LDA $3240,x : STA !Ex_YHi,y
		LDA #$01+!SmokeOffset : STA !Ex_Num,y
		LDA #$0F : STA !Ex_Data1,y
		RTS
	warnpc $02B9A4


;	org $02B98F
;		LDA #$01+!SmokeOffset

	org $038A21
		LDA #$03+!SmokeOffset
		JSL SmokeSpawn_SpritePlus0001
		RTS

	; remap smoke num reads
	; there are no reads lol


;	bounce num writes
	org $02882C
		JSL BounceNumCalc
;	%remap($02882D, !Ex_Num)	; need to hijack this to add to the number
;	bounce num clears
	%remap($0290CA, !Ex_Num)
	%remap($029199, !Ex_Num)
;	bounce num reads
	%remap($028794, !Ex_Num)
	%remap($0287A9, !Ex_Num)	; remapped!
	%remap($02886E, !Ex_Num)	; remapped!
	%remap($02904D, !Ex_Num)	; part of main loop
	%remap($029185, !Ex_Num)	; remapped!
	%remap($02924E, !Ex_Num)	; remapped!

	; remap bounce num writes




	; remap bounce num reads
	org $0287A9
		JSL BounceCheck07
		NOP
;	org $0287AC
;		CMP #$07+!BounceOffset
	org $02886E
		JSL BounceCheck07
		NOP
;	org $028871
;		CMP #$07+!BounceOffset
	org $029185
		JSL BounceCheck06
		NOP
;	org $029188
;		CPY #$06+!BounceOffset

	org $029251
		JSL BounceRemapTile
;	%remap($029252, $91F0-!BounceOffset)	; remap table index



;	quake num writes
	%remap($0286CC, !Ex_Num)
	%remap($028731, !Ex_Num)
;	quake num clears
	%remap($029394, !Ex_Num)
;	quake num reads
	%remap($0286EF, !Ex_Num)
;	%remap($029398, !Ex_Num)	; this one's hijacked
	%remap($029664, !Ex_Num)	; remapped!

;	remap quake num writes
	org $0286CA
		LDA #$02+!QuakeOffset
	org $02872F
		LDA #$01+!QuakeOffset

;	remap quake num reads
	%remap($02966C, $9656-!QuakeOffset)	;\
	%remap($029674, $9658-!QuakeOffset)	; |
	%remap($029679, $965A-!QuakeOffset)	; | remap hitbox table index offset
	%remap($029682, $965C-!QuakeOffset)	; |
	%remap($02968A, $965E-!QuakeOffset)	; |
	%remap($02968F, $9660-!QuakeOffset)	;/



;	coin num writes
	%remap($028A81, !Ex_Num)	; note: this one uses INC
	%remap($029363, !Ex_Num)
;	coin num clears
	%remap($0299E5, !Ex_Num)
;	coin num reads
	%remap($028A68, !Ex_Num)
	%remap($029358, !Ex_Num)
;	%remap($0299D7, !Ex_Num)	; this one's hijacked


;	remap coin num writes
	org $029361
		LDA #$01





;	score num writes
	org $00F390
		NOP #3
	org $029AAE
		NOP #3
	org $02A443
		NOP #3
	org $02ACF6
		NOP #3
	org $02FF72
		NOP #3
	org $02ADD5
		NOP #3
	org $02AF29
		NOP #3






; note that spawns are WRITES to num reg, and so needs to be modified since the numbers will be rearranged
; the following is a list of reg references, which only need to be remapped

;	remap:
;
;	$77F0 -> !Ex_Num	; minor extended
;	$770B -> !Ex_Num	; extended
;	$77C0 -> !Ex_Num	; smoke
;	$7699 -> !Ex_Num	; bounce
;	$76CD -> !Ex_Num	; quake
;	$77D0 -> !Ex_Num	; coin
;
; many of these have an index in RAM pointing to the next free slot
; i need to remap those as well, so they all use the same one
;
;	index remap
;	$785D	; minor extended
;	$78FC	; extended
;	$7863	; smoke
;	$78CD	; bounce
;	$7865	; coin
;
; these need to be remapped to the same address (let's just pick $785D)
; they are used like this:
;
;	DEC !Ex_Index : BPL +
;	LDA #!Ex_Amount-1 : STA !Ex_Index
;	+
;
; usually the address is loaded in X or Y right after that
; this keeps track of the oldest spawned one, which is used ONLY if all slots are full




;	index:
	%remap($018EF9, !Ex_Index)		;\
	%remap($018F00, !Ex_Index)		; | extended
	%remap($018F03, !Ex_Index)		;/
	%remap($01C5C7, !Ex_Index)		;\
	%remap($01C5CE, !Ex_Index)		; | smoke
	%remap($01C5D1, !Ex_Index)		;/
	%remap($02879C, !Ex_Index)		;\
	%remap($0287A3, !Ex_Index)		; | bounce
	%remap($0287A6, !Ex_Index)		; |
	%remap($028004, !Ex_Index)		;/
	%remap($028A70, !Ex_Index)		;\
	%remap($028A77, !Ex_Index)		; | coin
	%remap($028A7A, !Ex_Index)		;/


; only reads should go in this list




;=============================;
; MINOR EXTENDED SPRITE REMAP ;
;=============================;

;	minor extended remap
;	$7808 -> !Ex_XLo
;	$78EA -> !Ex_XHi
;	$77FC -> !Ex_YLo
;	$7814 -> !Ex_YHi
;	$782C -> !Ex_XSpeed
;	$7820 -> !Ex_YSpeed
;	$7844 -> !Ex_XFraction
;	$7838 -> !Ex_YFraction
;	$7850 -> !Ex_Data1


;	minor extended XLo:
	%remap($00FDE0, !Ex_XLo)
	%remap($01F7FF, !Ex_XLo)
	%remap($0284FA, !Ex_XLo)
	%remap($0285D6, !Ex_XLo)
	%remap($028608, !Ex_XLo)
	%remap($02868F, !Ex_XLo)
	%remap($028BFC, !Ex_XLo)
	%remap($028C43, !Ex_XLo)
	%remap($028C46, !Ex_XLo)
	%remap($028C71, !Ex_XLo)
	%remap($028CC8, !Ex_XLo)
;	%remap($028D02, !Ex_XLo)	; part of OAM remap
	%remap($028D4F, !Ex_XLo)
;	%remap($028D8E, !Ex_XLo)	; part of OAM remap
;	%remap($028E23, !Ex_XLo)	; part of OAM remap
	%remap($028EA4, !Ex_XLo)
;	%remap($028EE4, !Ex_XLo)	; part of OAM remap
	%remap($028F2F, !Ex_XLo)
;	%remap($028F50, !Ex_XLo)	; part of OAM remap
	%remap($028F9E, !Ex_XLo)
	%remap($028FA1, !Ex_XLo)
;	%remap($028FE0, !Ex_XLo)	; part of OAM remap
;	%remap($02990F, !Ex_XLo)	; overwritten by spawn code
	%remap($02C110, !Ex_XLo)
	%remap($03903E, !Ex_XLo)
	%remap($03AD8B, !Ex_XLo)

;	minor extended XHi:
	%remap($00FDE5, !Ex_XHi)
	%remap($028502, !Ex_XHi)
	%remap($028610, !Ex_XHi)
	%remap($028696, !Ex_XHi)
	%remap($028C04, !Ex_XHi)
	%remap($028C49, !Ex_XHi)
	%remap($028C4C, !Ex_XHi)
	%remap($028C79, !Ex_XHi)
	%remap($028CD0, !Ex_XHi)
;	%remap($028D0A, !Ex_XHi)	; part of GFX recode
	%remap($028D54, !Ex_XHi)
	%remap($028F34, !Ex_XHi)
	%remap($028FA5, !Ex_XHi)
	%remap($028FA8, !Ex_XHi)
;	%remap($028FE8, !Ex_XHi)	; part of GFX recode
	%remap($039044, !Ex_XHi)
	%remap($03AD93, !Ex_XHi)

;	minor extended YLo:
	%remap($00FDCF, !Ex_YLo)
	%remap($01F808, !Ex_YLo)
	%remap($0284F2, !Ex_YLo)
	%remap($0285D1, !Ex_YLo)
	%remap($02861E, !Ex_YLo)
	%remap($02869F, !Ex_YLo)
	%remap($028BDA, !Ex_YLo)
	%remap($028C4F, !Ex_YLo)
	%remap($028C52, !Ex_YLo)
	%remap($028C80, !Ex_YLo)
	%remap($028CD7, !Ex_YLo)
;	%remap($028D16, !Ex_YLo)	; part of GFX recode
	%remap($028D72, !Ex_YLo)
;	%remap($028D9E, !Ex_YLo)	; part of GFX recode
	%remap($028E1D, !Ex_YLo)
;	%remap($028E34, !Ex_YLo)	; part of GFX recode
;	%remap($028E97, !Ex_YLo)	; part of OAM remap
;	%remap($028EF1, !Ex_YLo)	; part of GFX recode
;	%remap($028F59, !Ex_YLo)	; part of GFX recode
	%remap($028FB4, !Ex_YLo)
	%remap($028FB7, !Ex_YLo)
;	%remap($028FCA, !Ex_YLo)	; part of GFX recode
;	%remap($029918, !Ex_YLo)	; overwritten by spawn code
	%remap($02B5E5, !Ex_YLo)
	%remap($02B5E8, !Ex_YLo)
;	%remap($02C118, !Ex_YLo)	; overwritten by spawn code
	%remap($039049, !Ex_YLo)
	%remap($03AD9D, !Ex_YLo)

;	minor extended YHi:
	%remap($00FDDA, !Ex_YHi)
	%remap($01F80D, !Ex_YHi)
	%remap($028626, !Ex_YHi)
	%remap($0286A6, !Ex_YHi)
	%remap($028BE2, !Ex_YHi)
	%remap($028C55, !Ex_YHi)
	%remap($028C58, !Ex_YHi)
	%remap($028C88, !Ex_YHi)
	%remap($028CDF, !Ex_YHi)
	%remap($028FBB, !Ex_YHi)
	%remap($028FBE, !Ex_YHi)
;	%remap($028FD2, !Ex_YHi)	; part of GFX recode
	%remap($03904F, !Ex_YHi)
	%remap($03ADA5, !Ex_YHi)

;	minor extended XSpeed:
	%remap($01F819, !Ex_XSpeed)
	%remap($0286B2, !Ex_XSpeed)
	%remap($028BF3, !Ex_XSpeed)
	%remap($028C14, !Ex_XSpeed)
	%remap($028C23, !Ex_XSpeed)
;	%remap($028D29, !Ex_XSpeed)	; part of GFX recode
	%remap($028DF1, !Ex_XSpeed)
	%remap($028DF8, !Ex_XSpeed)
	%remap($028DFB, !Ex_XSpeed)
	%remap($028DFE, !Ex_XSpeed)
	%remap($028E0C, !Ex_XSpeed)
	%remap($028E13, !Ex_XSpeed)
	%remap($028F97, !Ex_XSpeed)
	%remap($02C122, !Ex_XSpeed)
	%remap($039059, !Ex_XSpeed)

;	minor extended YSpeed:
	%remap($01F813, !Ex_YSpeed)
	%remap($0285CC, !Ex_YSpeed)
	%remap($0285FA, !Ex_YSpeed)
	%remap($0286AC, !Ex_YSpeed)
	%remap($028C40, !Ex_YSpeed)
	%remap($028E8E, !Ex_YSpeed)
	%remap($028E91, !Ex_YSpeed)
	%remap($028F4A, !Ex_YSpeed)
	%remap($028FAD, !Ex_YSpeed)
	%remap($028FC7, !Ex_YSpeed)
	%remap($02B5C8, !Ex_YSpeed)
	%remap($02B5D7, !Ex_YSpeed)
	%remap($03ADAA, !Ex_YSpeed)

;	minor extended XFraction:
;	only accessed by overflowing the index on YFraction

;	minor extended YFraction:
	%remap($02B5D0, !Ex_YFraction)
	%remap($02B5D3, !Ex_YFraction)

;	minor extended Data1:
	%remap($00FDEF, !Ex_Data1)
	%remap($01F825, !Ex_Data1)
	%remap($02850C, !Ex_Data1)
;	%remap($0285DB, !Ex_Data1)	; overwritten by spawn code
	%remap($02862B, !Ex_Data1)
	%remap($0286B7, !Ex_Data1)
	%remap($028BD2, !Ex_Data1)
	%remap($028C0F, !Ex_Data1)
	%remap($028C5D, !Ex_Data1)
	%remap($028C61, !Ex_Data1)
	%remap($028C9A, !Ex_Data1)
	%remap($028CFA, !Ex_Data1)
	%remap($028D5B, !Ex_Data1)
	%remap($028D75, !Ex_Data1)
;	%remap($028DAB, !Ex_Data1)	; part of GFX recode
;	%remap($028DD3, !Ex_Data1)	; part of GFX recode
	%remap($028DDF, !Ex_Data1)
	%remap($028DE4, !Ex_Data1)
	%remap($028DE7, !Ex_Data1)
;	%remap($028DEE, !Ex_Data1)	; part of Z bug fix
	%remap($028E16, !Ex_Data1)
;	%remap($028E48, !Ex_Data1)	; part of GFX recode
;	%remap($028E58, !Ex_Data1)	; part of GFX recode
	%remap($028E7E, !Ex_Data1)
	%remap($028E81, !Ex_Data1)
	%remap($028EB6, !Ex_Data1)
	%remap($028ED2, !Ex_Data1)
	%remap($028EDE, !Ex_Data1)
;	%remap($028F02, !Ex_Data1)	; part of GFX recode
	%remap($028F3B, !Ex_Data1)
	%remap($028F44, !Ex_Data1)
;	%remap($028F66, !Ex_Data1)	; part of GFX recode
;	%remap($028FFD, !Ex_Data1)	; part of GFX recode
	%remap($02991E, !Ex_Data1)
	%remap($02C11D, !Ex_Data1)
	%remap($039054, !Ex_Data1)
	%remap($03ADAF, !Ex_Data1)


;=======================;
; EXTENDED SPRITE REMAP ;
;=======================;

;	extended remap
;	$771F -> !Ex_XLo
;	$7733 -> !Ex_XHi
;	$7715 -> !Ex_YLo
;	$7729 -> !Ex_YHi
;	$7747 -> !Ex_XSpeed
;	$773D -> !Ex_YSpeed
;	$775B -> !Ex_XFraction
;	$7751 -> !Ex_YFraction
;	$7765 -> !Ex_Data1
;	$776F -> !Ex_Data2
;	$7779 -> !Ex_Data3


;	extended XLo:
	%remap($00FD33, !Ex_XLo)
	%remap($00FE38, !Ex_XLo)
	%remap($00FEE5, !Ex_XLo)
	%remap($018F71, !Ex_XLo)
	%remap($01D3C4, !Ex_XLo)
	%remap($01F29F, !Ex_XLo)
	%remap($01FD16, !Ex_XLo)
	%remap($028554, !Ex_XLo)
;	%remap($029B54, !Ex_XLo)	; part of OAM remap
	%remap($029C1C, !Ex_XLo)
	%remap($029D04, !Ex_XLo)
	%remap($029D15, !Ex_XLo)
;	%remap($029DC7, !Ex_XLo)	; part of GFX recode
;	%remap($029EA0, !Ex_XLo)	; part of OAM remap
	%remap($02A01C, !Ex_XLo)
	%remap($02A01F, !Ex_XLo)
	%remap($02A05A, !Ex_XLo)
;	%remap($02A1B1, !Ex_XLo)	; part of GFX recode
;	%remap($02A271, !Ex_XLo)	; part of GFX recode
;	%remap($02A36C, !Ex_XLo)	; part of GFX recode
	%remap($02A3B4, !Ex_XLo)
;	%remap($02A42C, !Ex_XLo)	; overwritten by optimization, see $02A419
	%remap($02A452, !Ex_XLo)
	%remap($02A4BC, !Ex_XLo)
	%remap($02A4C2, !Ex_XLo)
	%remap($02A51C, !Ex_XLo)
	%remap($02A547, !Ex_XLo)
	%remap($02A592, !Ex_XLo)
	%remap($02A5CC, !Ex_XLo)
	%remap($02A5D3, !Ex_XLo)
	%remap($02A609, !Ex_XLo)
	%remap($02A631, !Ex_XLo)
	%remap($02A697, !Ex_XLo)
	%remap($02B438, !Ex_XLo)
	%remap($02C4A2, !Ex_XLo)
	%remap($02DACA, !Ex_XLo)
	%remap($02E09A, !Ex_XLo)
	%remap($02E1D7, !Ex_XLo)
	%remap($02EFC6, !Ex_XLo)
	%remap($02F2EE, !Ex_XLo)
	%remap($039B13, !Ex_XLo)
	%remap($03C478, !Ex_XLo)
	%remap($07FC70, !Ex_XLo)

;	extended XHi:
	%remap($00FD3A, !Ex_XHi)
	%remap($00FE3F, !Ex_XHi)
	%remap($00FEED, !Ex_XHi)
	%remap($018F79, !Ex_XHi)
	%remap($01D3C9, !Ex_XHi)
	%remap($01F2A5, !Ex_XHi)
	%remap($02855C, !Ex_XHi)
;	%remap($029B5C, !Ex_XHi)	; part of GFX recode
	%remap($029C24, !Ex_XHi)
	%remap($029D09, !Ex_XHi)
;	%remap($029EA8, !Ex_XHi)	; part of GFX recode
	%remap($02A023, !Ex_XHi)
	%remap($02A026, !Ex_XHi)
;	%remap($02A1B9, !Ex_XHi)	; part of GFX recode
;	%remap($02A279, !Ex_XHi)	; part of GFX recode
	%remap($02A458, !Ex_XHi)
	%remap($02A4C5, !Ex_XHi)
	%remap($02A4CA, !Ex_XHi)
	%remap($02A525, !Ex_XHi)
	%remap($02A54F, !Ex_XHi)
	%remap($02A59B, !Ex_XHi)
	%remap($02A5D6, !Ex_XHi)
	%remap($02A5DC, !Ex_XHi)
	%remap($02A605, !Ex_XHi)
	%remap($02A63B, !Ex_XHi)
	%remap($02A6A1, !Ex_XHi)
	%remap($02B440, !Ex_XHi)
	%remap($02C4AA, !Ex_XHi)
	%remap($02DAD0, !Ex_XHi)
	%remap($02E0A2, !Ex_XHi)
	%remap($02E1DF, !Ex_XHi)
	%remap($02EFCE, !Ex_XHi)
	%remap($02F2F4, !Ex_XHi)
	%remap($039B1D, !Ex_XHi)
	%remap($03C47E, !Ex_XHi)
	%remap($07FC78, !Ex_XHi)

;	extended YLo:
	%remap($00FD4C, !Ex_YLo)
	%remap($00FE29, !Ex_YLo)
	%remap($00FEF6, !Ex_YLo)
	%remap($018F81, !Ex_YLo)
	%remap($01D3CE, !Ex_YLo)
	%remap($01F2AA, !Ex_YLo)
	%remap($01FD20, !Ex_YLo)
	%remap($028546, !Ex_YLo)
;	%remap($029B63, !Ex_YLo)	; part of GFX recode
	%remap($029C0A, !Ex_YLo)
	%remap($029CF8, !Ex_YLo)
;	%remap($029DD3, !Ex_YLo)	; part of GFX recode
;	%remap($029EB4, !Ex_YLo)	; part of GFX recode
	%remap($029EFC, !Ex_YLo)
	%remap($029EFF, !Ex_YLo)
;	%remap($029F2A, !Ex_YLo)	; part of GFX recode
;	%remap($029FB3, !Ex_YLo)	; part of mario fireball fix
	%remap($029FFF, !Ex_YLo)
	%remap($02A006, !Ex_YLo)
	%remap($02A067, !Ex_YLo)
;	%remap($02A1C0, !Ex_YLo)	; part of GFX recode
;	%remap($02A28F, !Ex_YLo)	; part of GFX recode
;	%remap($02A379, !Ex_YLo)	; part of GFX recode
	%remap($02A3C1, !Ex_YLo)
;	%remap($02A432, !Ex_YLo)	; overwritten by optimization, see $02A419
	%remap($02A446, !Ex_YLo)
	%remap($02A4CD, !Ex_YLo)
	%remap($02A4D3, !Ex_YLo)
	%remap($02A531, !Ex_YLo)
	%remap($02A55A, !Ex_YLo)
	%remap($02A58C, !Ex_YLo)
	%remap($02A5A3, !Ex_YLo)
	%remap($02A5DF, !Ex_YLo)
	%remap($02A5E6, !Ex_YLo)
	%remap($02A601, !Ex_YLo)
	%remap($02A618, !Ex_YLo)
	%remap($02A679, !Ex_YLo)
	%remap($02A73D, !Ex_YLo)
	%remap($02A743, !Ex_YLo)
	%remap($02B449, !Ex_YLo)
	%remap($02B580, !Ex_YLo)
	%remap($02B583, !Ex_YLo)
	%remap($02C48C, !Ex_YLo)
	%remap($02DAD5, !Ex_YLo)
	%remap($02E0A7, !Ex_YLo)
	%remap($02E1E4, !Ex_YLo)
	%remap($02EFD3, !Ex_YLo)
	%remap($02F2F9, !Ex_YLo)
	%remap($039B28, !Ex_YLo)
	%remap($03C46B, !Ex_YLo)
	%remap($07FC60, !Ex_YLo)

;	extended YHi:
	%remap($00FD53, !Ex_YHi)
	%remap($00FE30, !Ex_YHi)
	%remap($00FEFD, !Ex_YHi)
	%remap($018F89, !Ex_YHi)
	%remap($01D3D3, !Ex_YHi)
	%remap($01F2B0, !Ex_YHi)
	%remap($02854C, !Ex_YHi)
;	%remap($029B6B, !Ex_YHi)	; part of GFX recode
	%remap($029C11, !Ex_YHi)
	%remap($029F05, !Ex_YHi)
;	%remap($029F2F, !Ex_YHi)	; part of GFX recode
;	%remap($029FB8, !Ex_YHi)	; part of mario fireball fix
	%remap($02A00B, !Ex_YHi)
;	%remap($02A1C8, !Ex_YHi)	; part of GFX recode
;	%remap($02A297, !Ex_YHi)	; part of GFX recode
	%remap($02A44C, !Ex_YHi)
	%remap($02A4D6, !Ex_YHi)
	%remap($02A4DB, !Ex_YHi)
	%remap($02A53A, !Ex_YHi)
	%remap($02A562, !Ex_YHi)
	%remap($02A5AC, !Ex_YHi)
	%remap($02A5E9, !Ex_YHi)
	%remap($02A5EF, !Ex_YHi)
	%remap($02A5FD, !Ex_YHi)
	%remap($02A624, !Ex_YHi)
	%remap($02A685, !Ex_YHi)
	%remap($02A746, !Ex_YHi)
	%remap($02A74B, !Ex_YHi)
	%remap($02B451, !Ex_YHi)
	%remap($02B587, !Ex_YHi)
	%remap($02B58A, !Ex_YHi)
	%remap($02C494, !Ex_YHi)
	%remap($02DADB, !Ex_YHi)
	%remap($02E0AD, !Ex_YHi)
	%remap($02E1EA, !Ex_YHi)
	%remap($02EFD9, !Ex_YHi)
	%remap($02F2FE, !Ex_YHi)
	%remap($039B31, !Ex_YHi)
	%remap($03C473, !Ex_YHi)
	%remap($07FC68, !Ex_YHi)

;	extended XSpeed:
	%remap($00FECE, !Ex_XSpeed)
	%remap($01F2C7, !Ex_XSpeed)
	%remap($02856B, !Ex_XSpeed)
	%remap($029BD6, !Ex_XSpeed)
	%remap($029C2A, !Ex_XSpeed)
	%remap($029C74, !Ex_XSpeed)
	%remap($029C78, !Ex_XSpeed)
	%remap($029CDB, !Ex_XSpeed)
;	%remap($029DA0, !Ex_XSpeed)	; part of GFX recode
	%remap($029F82, !Ex_XSpeed)
	%remap($029FE7, !Ex_XSpeed)
	%remap($02A015, !Ex_XSpeed)
	%remap($02A052, !Ex_XSpeed)
;	%remap($02A1A7, !Ex_XSpeed)	; part of OAM remap
;	%remap($02A280, !Ex_XSpeed)	; part of GFX recode
	%remap($02B45F, !Ex_XSpeed)
	%remap($02C4B0, !Ex_XSpeed)
	%remap($02DAE5, !Ex_XSpeed)
	%remap($02E0B6, !Ex_XSpeed)
	%remap($02E1F4, !Ex_XSpeed)
	%remap($02EFE3, !Ex_XSpeed)
	%remap($02F30B, !Ex_XSpeed)
	%remap($039B4D, !Ex_XSpeed)
	%remap($03C48B, !Ex_XSpeed)
	%remap($07FC80, !Ex_XSpeed)

;	extended YSpeed:
	%remap($00FEC6, !Ex_YSpeed)
	%remap($01F2CD, !Ex_YSpeed)
	%remap($028578, !Ex_YSpeed)
	%remap($029BB8, !Ex_YSpeed)
	%remap($029BBF, !Ex_YSpeed)
	%remap($029BC2, !Ex_YSpeed)
	%remap($029CBC, !Ex_YSpeed)
	%remap($029CC6, !Ex_YSpeed)
	%remap($029CEF, !Ex_YSpeed)
;	%remap($029E56, !Ex_YSpeed)	; part of GFX recode
	%remap($029E90, !Ex_YSpeed)
	%remap($029E96, !Ex_YSpeed)
	%remap($029FC8, !Ex_YSpeed)
	%remap($029FCF, !Ex_YSpeed)
	%remap($029FD5, !Ex_YSpeed)
	%remap($029FFC, !Ex_YSpeed)
	%remap($02A2F9, !Ex_YSpeed)
	%remap($02A300, !Ex_YSpeed)
	%remap($02A303, !Ex_YSpeed)
	%remap($02B560, !Ex_YSpeed)
	%remap($02B571, !Ex_YSpeed)
	%remap($02DAE0, !Ex_YSpeed)
	%remap($02E0BC, !Ex_YSpeed)
	%remap($02E1EF, !Ex_YSpeed)
	%remap($02EFDE, !Ex_YSpeed)
	%remap($02F303, !Ex_YSpeed)
	%remap($039B48, !Ex_YSpeed)
	%remap($07FC87, !Ex_YSpeed)

;	extended XFraction:
	%remap($029FDD, !Ex_XFraction)
	%remap($029FE0, !Ex_XFraction)
	%remap($02A010, !Ex_XFraction)

;	extended YFraction:
	%remap($02B568, !Ex_YFraction)
	%remap($02B56B, !Ex_YFraction)

;	extended Data1:
	%remap($00FE21, !Ex_Data1)
	%remap($029CE3, !Ex_Data1)
	%remap($029CF2, !Ex_Data1)
;	%remap($029DBE, !Ex_Data1)	; part of GFX recode
;	%remap($029DF6, !Ex_Data1)	; part of GFX recode
	%remap($029EF2, !Ex_Data1)
	%remap($029EF5, !Ex_Data1)
;	%remap($029F39, !Ex_Data1)	; part of GFX recode
	%remap($029FC2, !Ex_Data1)
	%remap($02A079, !Ex_Data1)
	%remap($02A21D, !Ex_Data1)
;	%remap($02A238, !Ex_Data1)	; part of OAM remap
	%remap($02A25B, !Ex_Data1)
	%remap($02A264, !Ex_Data1)
	%remap($02A309, !Ex_Data1)
;	%remap($02A31D, !Ex_Data1)	; part of OAM remap
	%remap($02EFE6, !Ex_Data1)
	%remap($02F2E9, !Ex_Data1)

;	extended Data2:
	%remap($00FD56, !Ex_Data2)
	%remap($00FE44, !Ex_Data2)
	%remap($018F93, !Ex_Data2)
	%remap($01D3F0, !Ex_Data2)
	%remap($01F2D2, !Ex_Data2)
	%remap($01FD3D, !Ex_Data2)
	%remap($028586, !Ex_Data2)
	%remap($029B1F, !Ex_Data2)
	%remap($029B24, !Ex_Data2)
	%remap($029C2F, !Ex_Data2)
;	%remap($029C44, !Ex_Data2)	; part of OAM remap
	%remap($029C6B, !Ex_Data2)
	%remap($029C83, !Ex_Data2)
	%remap($029C9C, !Ex_Data2)
;	%remap($029DAA, !Ex_Data2)	; part of GFX recode
;	%remap($029E3F, !Ex_Data2)	; part of GFX recode
;	%remap($029EC1, !Ex_Data2)	; part of GFX recode
	%remap($02A220, !Ex_Data2)
	%remap($02A34F, !Ex_Data2)
;	%remap($02A386, !Ex_Data2)	; part of GFX recode
	%remap($02A3CE, !Ex_Data2)
	%remap($02A4E0, !Ex_Data2)
	%remap($02B456, !Ex_Data2)
	%remap($07FC8C, !Ex_Data2)

;	extended Data3:
	%remap($00FF03, !Ex_Data3)
	%remap($01F2B5, !Ex_Data3)
	%remap($02A074, !Ex_Data3)
	%remap($02A0CF, !Ex_Data3)
	%remap($02A1DD, !Ex_Data3)
	%remap($02A3F9, !Ex_Data3)


;====================;
; SMOKE SPRITE REMAP ;
;====================;

;	smoke remap
;	$77C8 -> !Ex_XLo	; have to add hi bytes here
;	$77C4 -> !Ex_YLo
;	$77CC -> !Ex_Data1




;	smoke XLo:
;	%remap($00FB9B, !Ex_XLo)	; overwritten by spawn code
;	%remap($00FD74, !Ex_XLo)	; overwritten by spawn code
;	%remap($00FD8A, !Ex_XLo)	; overwritten by spawn code
;	%remap($00FE7B, !Ex_XLo)	; overwritten by spawn code
;	%remap($01807C, !Ex_XLo)	; overwritten by spawn code
;	%remap($01AB8A, !Ex_XLo)	; overwritten by spawn code
;	%remap($01ABB1, !Ex_XLo)	; overwritten by spawn code
;	%remap($01BDAA, !Ex_XLo)	; overwritten by spawn code
;	%remap($01C502, !Ex_XLo)	; overwritten by spawn code
;	%remap($01C5E8, !Ex_XLo)	; overwritten by spawn code
	%remap($01D023, !Ex_XLo) ; not indexed (used by reznor)
;	%remap($028A5C, !Ex_XLo)	; overwritten by spawn code
;	%remap($029704, !Ex_XLo)	; part of OAM remap
;	%remap($02974D, !Ex_XLo)	; part of OAM remap
;	%remap($0297B4, !Ex_XLo)	; part of OAM remap
	%remap($02983A, !Ex_XLo)
	%remap($0298FB, !Ex_XLo)
;	%remap($02996F, !Ex_XLo)	; part of OAM remap
;	%remap($0299A2, !Ex_XLo)	; part of OAM remap
;	%remap($029AF6, !Ex_XLo)	; overwritten by optimization, see $029ADA
;	%remap($02A42F, !Ex_XLo)	; overwritten by optimization, see $02A419
	%remap($02B513, !Ex_XLo)
;	%remap($02B996, !Ex_XLo)	; torpedo ted special, see $02B969
;	%remap($038A2B, !Ex_XLo)	; overwritten by spawn code

;	smoke YLo:
;	%remap($00FB95, !Ex_YLo)	; overwritten by spawn code
;	%remap($00FD7B, !Ex_YLo)	; overwritten by spawn code
;	%remap($00FD94, !Ex_YLo)	; overwritten by spawn code
;	%remap($00FE8A, !Ex_YLo)	; overwritten by spawn code
;	%remap($018083, !Ex_YLo)	; overwritten by spawn code
;	%remap($01AB8F, !Ex_YLo)	; overwritten by spawn code
;	%remap($01ABC2, !Ex_YLo)	; overwritten by spawn code
;	%remap($01BDAF, !Ex_YLo)	; overwritten by spawn code
;	%remap($01C507, !Ex_YLo)	; overwritten by spawn code
;	%remap($01C5E3, !Ex_YLo)	; overwritten by spawn code
	%remap($01D02A, !Ex_YLo) ; note indexed (used by reznor)
;	%remap($028A57, !Ex_YLo)	; overwrittenby spawn code
;	%remap($029711, !Ex_YLo)	; part of GFX recode
	%remap($02975A, !Ex_YLo)
;	%remap($0297CD, !Ex_YLo)	; part of GFX recode
	%remap($029853, !Ex_YLo)
;	%remap($0298F6, !Ex_YLo)	; overwritten by spawn code
	%remap($02994C, !Ex_YLo)
;	%remap($029978, !Ex_YLo)	; part of GFX recode
	%remap($0299AB, !Ex_YLo)
;	%remap($029B01, !Ex_YLo)	; overwritten by optimization, see $029ADA
;	%remap($02A435, !Ex_YLo)	; overwritten by optimization, see $02A419
	%remap($02B4F3, !Ex_YLo)
;	%remap($02B99B, !Ex_YLo)	; torpedo ted special, see $02B969
;	%remap($038A33, !Ex_YLo)	; overwritten by spawn code

;	smoke Data1:
;	%remap($00FBA0, !Ex_Data1)	; overwritten by spawn code
;	%remap($00FD99, !Ex_Data1)	; overwritten by spawn code
;	%remap($00FE90, !Ex_Data1)	; overwritten by spawn code
;	%remap($018088, !Ex_Data1)	; overwritten by spawn code
;	%remap($01AB94, !Ex_Data1)	; overwritten by spawn code
;	%remap($01ABC7, !Ex_Data1)	; overwritten by spawn code
;	%remap($01BDB4, !Ex_Data1)	; overwritten by spawn code
;	%remap($01C50C, !Ex_Data1)	; overwritten by spawn code
;	%remap($01C5DB, !Ex_Data1)	; overwritten by spawn code
	%remap($01D02F, !Ex_Data1) ; not indexed (used by reznor)
;	%remap($028A61, !Ex_Data1)	; overwritten by spawn code
	%remap($0296E3, !Ex_Data1)
	%remap($0296F1, !Ex_Data1)
;	%remap($02971E, !Ex_Data1)	; part of GFX recode
;	%remap($029732, !Ex_Data1)	; part of GFX recode
	%remap($029767, !Ex_Data1)
	%remap($02977B, !Ex_Data1)
	%remap($029797, !Ex_Data1)
	%remap($0297A0, !Ex_Data1)
;	%remap($0297E2, !Ex_Data1)	; part of GFX recode
;	%remap($0297FC, !Ex_Data1)	; part of GFX recode
	%remap($029868, !Ex_Data1)
	%remap($029882, !Ex_Data1)
	%remap($0298CA, !Ex_Data1)
	%remap($0298D3, !Ex_Data1)
	%remap($029900, !Ex_Data1)
	%remap($029927, !Ex_Data1)
	%remap($029945, !Ex_Data1)
;	%remap($029986, !Ex_Data1)	; part of GFX recode
	%remap($0299B9, !Ex_Data1)
;	%remap($029B06, !Ex_Data1)	; overwritten by optimization, see $029ADA
;	%remap($02A43A, !Ex_Data1)	; overwritten by optimization, see $02A419
	%remap($02B4F8, !Ex_Data1)
;	%remap($02B9A0, !Ex_Data1)	; torpedo ted special, see $02B969
;	%remap($038A38, !Ex_Data1)	; overwritten by spawn code


;=====================;
; BOUNCE SPRITE REMAP ;
;=====================;

;	bounce remap
;	$76A5 -> !Ex_XLo
;	$76AD -> !Ex_XHi
;	$76A1 -> !Ex_YLo
;	$76A9 -> !Ex_YHi
;	$76B5 -> !Ex_XSpeed
;	$76B1 -> !Ex_YSpeed
;	$76BD -> !Ex_XFraction
;	$76B9 -> !Ex_YFraction
;	$769D -> recode into number as highest bit (init flag)
;	$76C1 -> !Ex_Data2	; map16 tile
;	$76C5 -> !Ex_Data3	; timer
;	$76C9 -> !Ex_Data1	; direction and layer
;	$7901 -> ???		; YXPPCCCT (this is always 0...)


;	bounce XLo:
	%remap($0287BC, !Ex_XLo)
	%remap($028837, !Ex_XLo)
	%remap($0291BC, !Ex_XLo)
	%remap($029221, !Ex_XLo)
	%remap($02923B, !Ex_XLo)
	%remap($02928C, !Ex_XLo)
	%remap($0292DF, !Ex_XLo)
	%remap($02936A, !Ex_XLo)

;	bounce XHi:
	%remap($0287C1, !Ex_XHi)
	%remap($02883C, !Ex_XHi)
	%remap($0291C6, !Ex_XHi)
	%remap($029226, !Ex_XHi)
	%remap($029291, !Ex_XHi)
	%remap($0292E4, !Ex_XHi)
	%remap($029370, !Ex_XHi)

;	bounce YLo:
	%remap($0287C6, !Ex_YLo)
	%remap($028841, !Ex_YLo)
	%remap($02908E, !Ex_YLo)
	%remap($029096, !Ex_YLo)
	%remap($029145, !Ex_YLo)
	%remap($0291CD, !Ex_YLo)
	%remap($029215, !Ex_YLo)
;	%remap($029230, !Ex_YLo)	; part of OAM remap
	%remap($029273, !Ex_YLo)
	%remap($0292CA, !Ex_YLo)
	%remap($029333, !Ex_YLo)
	%remap($02933B, !Ex_YLo)
	%remap($029352, !Ex_YLo)
	%remap($029376, !Ex_YLo)
	%remap($02B546, !Ex_YLo)
	%remap($02B549, !Ex_YLo)

;	bounce YHi:
	%remap($0287D0, !Ex_YHi)
	%remap($028846, !Ex_YHi)
	%remap($029099, !Ex_YHi)
	%remap($02909E, !Ex_YHi)
	%remap($02914D, !Ex_YHi)
	%remap($0291D7, !Ex_YHi)
	%remap($02921A, !Ex_YHi)
	%remap($02927D, !Ex_YHi)
	%remap($0292D4, !Ex_YHi)
	%remap($02933E, !Ex_YHi)
	%remap($029344, !Ex_YHi)
	%remap($02934E, !Ex_YHi)
	%remap($02937C, !Ex_YHi)
	%remap($02B54D, !Ex_YHi)
	%remap($02B550, !Ex_YHi)

;	bounce XSpeed:
	%remap($02885B, !Ex_XSpeed)
	%remap($029121, !Ex_XSpeed)
	%remap($029128, !Ex_XSpeed)

;	bounce YSpeed:
	%remap($028855, !Ex_YSpeed)
	%remap($0290AE, !Ex_YSpeed)
	%remap($0290B5, !Ex_YSpeed)
	%remap($029117, !Ex_YSpeed)
	%remap($02911E, !Ex_YSpeed)
	%remap($02B526, !Ex_YSpeed)
	%remap($02B535, !Ex_YSpeed)


;	bounce XFraction:
;	only accessed by overflowing the index on YFraction

;	bounce YFraction:
	%remap($02B52E, !Ex_YFraction)
	%remap($02B531, !Ex_YFraction)

;	bounce init flag, reprogram to use highest bit of number
	org $028830
		BRA $03 : NOP #3	; this doesn't have to be cleared since num was just set
	org $02907A
		LDA !Ex_Num,x : BMI $06
		JML BounceSetInit
		NOP #2
	warnpc $029085
	org $0290E5
		LDA !Ex_Num,x
		JML BounceSetInit2
		NOP
	warnpc $0290ED



;	%remap($028832, !Ex_Data1)
;	%remap($02907A, !Ex_Data1)
;	%remap($02907F, !Ex_Data1)
;	%remap($0290E5, !Ex_Data1)
;	%remap($0290EA, !Ex_Data1)


;	bounce Data2:
	%remap($0287D7, !Ex_Data2)
	%remap($028866, !Ex_Data2)
	%remap($0290C4, !Ex_Data2)
	%remap($02919F, !Ex_Data2)

;	bounce Data3:
	%remap($02886B, !Ex_Data3)
	%remap($029056, !Ex_Data3)
	%remap($02905B, !Ex_Data3)
	%remap($029085, !Ex_Data3)
	%remap($02915E, !Ex_Data3)

;	bounce Data1:
	%remap($028861, !Ex_Data1)
	%remap($0290AB, !Ex_Data1)
	%remap($0290F3, !Ex_Data1)
	%remap($029111, !Ex_Data1)
	%remap($02912B, !Ex_Data1)
	%remap($029163, !Ex_Data1)
	%remap($0291DE, !Ex_Data1)
	%remap($0291FA, !Ex_Data1)
	%remap($029267, !Ex_Data1)
	%remap($029382, !Ex_Data1)



; 1901 is always 0 in EMW, so just do this
	org $028813
		NOP #3
	org $028827
		NOP #3
	org $029246
		LDA #$00
		NOP

;	unknown from 1901
;	$028813
;	$028827
;	$029246



;====================;
; QUAKE SPRITE REMAP ;
;====================;

;	quake remap
;	$76D1 -> !Ex_XLo
;	$76D5 -> !Ex_XHi
;	$76D9 -> !Ex_YLo
;	$76DD -> !Ex_YHi
;	$78F8 -> !Ex_Data1

;	quake XLo:
	%remap($0286D1, !Ex_XLo)
	%remap($0286FA, !Ex_XLo)
	%remap($028716, !Ex_XLo)
	%remap($029668, !Ex_XLo)

;	quake XHi:
	%remap($0286FF, !Ex_XHi)
	%remap($02871D, !Ex_XHi)
	%remap($029671, !Ex_XHi)

;	quake YLo:
	%remap($0286DE, !Ex_YLo)
	%remap($028704, !Ex_YLo)
	%remap($028725, !Ex_YLo)
	%remap($02967E, !Ex_YLo)

;	quake YHi:
	%remap($0286D6, !Ex_YHi)
	%remap($0286E5, !Ex_YHi)
	%remap($028709, !Ex_YHi)
	%remap($02872C, !Ex_YHi)
	%remap($029687, !Ex_YHi)

;	quake Data1:
	%remap($028736, !Ex_Data1)
	%remap($02939D, !Ex_Data1)
	%remap($0293A2, !Ex_Data1)



;===================;
; COIN SPRITE REMAP ;
;===================;

;	coin remap
;	$77E0 -> !Ex_XLo
;	$77EC -> !Ex_XHi
;	$77D4 -> !Ex_YLo
;	$77E8 -> !Ex_YHi
;		;!Ex_XSpeed unused
;	$77D8 -> !Ex_YSpeed
;		;!Ex_XFraction unused
;	$77DC -> !Ex_YFraction
;	$77E4 -> !Ex_Data1


;	coin XLo:
	%remap($028A86, !Ex_XLo)
	%remap($02936D, !Ex_XLo)
	%remap($029A29, !Ex_XLo)
	%remap($029ABD, !Ex_XLo)
;	%remap($029AEF, !Ex_XLo)	; overwritten by optimization, see $029ADA

;	coin XHi:
	%remap($028A8B, !Ex_XHi)
	%remap($029373, !Ex_XHi)
	%remap($029AC3, !Ex_XHi)

;	coin YLo:
	%remap($028A93, !Ex_YLo)
	%remap($029379, !Ex_YLo)
	%remap($029A1D, !Ex_YLo)
	%remap($029A35, !Ex_YLo)
	%remap($029AB1, !Ex_YLo)
;	%remap($029AF9, !Ex_YLo)	; overwritten by optimization, see $029ADA
	%remap($02B5AE, !Ex_YLo)
	%remap($02B5B1, !Ex_YLo)

;	coin YHi:
	%remap($028A9A, !Ex_YHi)
	%remap($02937F, !Ex_YHi)
	%remap($029A22, !Ex_YHi)
	%remap($029AB7, !Ex_YHi)
	%remap($02B5B5, !Ex_YHi)
	%remap($02B5B8, !Ex_YHi)

;	coin YSpeed:
	%remap($028AA5, !Ex_YSpeed)
	%remap($02938E, !Ex_YSpeed)
	%remap($0299F8, !Ex_YSpeed)
	%remap($0299FE, !Ex_YSpeed)
	%remap($02B58E, !Ex_YSpeed)
	%remap($02B59F, !Ex_YSpeed)

;	coin YFraction:
	%remap($02B596, !Ex_YFraction)
	%remap($02B599, !Ex_YFraction)

;	coin Data1:
	%remap($028AA0, !Ex_Data1)
	%remap($029389, !Ex_Data1)
	%remap($029A08, !Ex_Data1)
	%remap($029ACE, !Ex_Data1)
;	%remap($029AEA, !Ex_Data1)	; overwritten by optimization, see $029ADA





print " "
print "FusionCore V1.2"
print " - Ex_Num mapped to ........$", hex(!Ex_Num)
print " - Ex_Data1 mapped to ......$", hex(!Ex_Data1)
print " - Ex_Data2 mapped to ......$", hex(!Ex_Data2)
print " - Ex_Data3 mapped to ......$", hex(!Ex_Data3)
print " - Ex_XLo mapped to ........$", hex(!Ex_XLo)
print " - Ex_XHi mapped to ........$", hex(!Ex_XHi)
print " - Ex_YLo mapped to ........$", hex(!Ex_YLo)
print " - Ex_YHi mapped to ........$", hex(!Ex_YHi)
print " - Ex_XSpeed mapped to .....$", hex(!Ex_XSpeed)
print " - Ex_YSpeed mapped to .....$", hex(!Ex_YSpeed)
print " - Ex_XFraction mapped to ..$", hex(!Ex_XFraction)
print " - Ex_YFraction mapped to ..$", hex(!Ex_YFraction)
print dec(!DebugRemapCount), " addresses remapped"
print "Number of ExSprites allowed: ", dec(!Ex_Amount), " (0x", hex(!Ex_Amount), ")"
print "Number of ExSprite types: ", dec(HandleEx_PalsetIndex_End-HandleEx_PalsetIndex)
print " "
