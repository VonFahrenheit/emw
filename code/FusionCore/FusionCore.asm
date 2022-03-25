
header
sa1rom

	incsrc "../Defines.asm"


print "-- FusionCore --"

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
;	33 bullet bill shooter
;	34 torpedo ted launcher
;
;	35 -- about to clear --
;	36+ custom


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
	org $028B14		;\ remove shooter call
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





	org $148000
	HandleEx:
		PHB					;\
		LDA #$02				; | wrap to bank 0x02
		PHA : PLB				;/
		LDA !CoinTimer				;\
		CMP #$02 : BCC .CoinTimerReset		; |
		LDA $9D : BNE .CoinTimerReset		; | coin timer code from $02902D
		DEC !CoinTimer				; |
		.CoinTimerReset				;/


		LDX #!Ex_Amount-1			; full index
		LDA $64 : PHA				; preserve this

	.Loop	STX $75E9				; store index
		STX $7698				; store index
		PHX					; just in case

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
		LDA !DecompBuffer+$1040,x
		AND #$01FF
		CMP #$0100
		BCC $03 : ORA #$FE00
		STA $1C
		PLX
		SEP #$20
		+

		LDA !Ex_Num,x
		AND #$7F : BEQ .Clear
		CMP #!MinorOffset : BEQ .Clear
		CMP #!ExtendedOffset : BEQ .Clear
		CMP #!SmokeOffset : BEQ .Clear
		CMP #!BounceOffset : BEQ .Clear
		CMP #!QuakeOffset : BEQ .Clear
		CMP #!ShooterOffset : BEQ .Clear
		CMP #!CustomOffset : BNE .GetNum

	.Clear
		STZ !Ex_Num,x
	;	STZ !Ex_Data1,x
	;	STZ !Ex_Data2,x
	;	STZ !Ex_Data3,x
	;	STZ !Ex_XLo,x
	;	STZ !Ex_XHi,x
	;	STZ !Ex_YLo,x
	;	STZ !Ex_YHi,x
	;	STZ !Ex_XSpeed,x
	;	STZ !Ex_YSpeed,x
	;	STZ !Ex_XFraction,x
	;	STZ !Ex_YFraction,x
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
		PLB				; restore bank


		JSR ParticleMain		; execute particle code
		JSR BG_OBJECTS			; execute BG_object code


		RTL

	.GetNum
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
		LDA !Palset_status,x
		ASL A
		LDX $75E9
	; this will sometimes store 0xFF!
		STA !Ex_Palset,x

		.PalsetDone
		LDX $75E9
		LDA !Ex_Palset,x
		CMP #$FF : BEQ +
		LDA $64
		AND #$F0
		ORA !Ex_Palset,x
		STA $64
		+

		PLA
		CMP #$01 : BEQ .Coin
		CMP #$0C+!MinorOffset : BCC .MinorExtended
		CMP #$13+!ExtendedOffset : BCC .Extended
		CMP #$06+!SmokeOffset : BCC .Smoke
		CMP #$08+!BounceOffset : BCC .Bounce
		CMP #$03+!QuakeOffset : BCC .Quake
		CMP #$02+!ShooterOffset : BCC .Shooter
		CMP.b #((.CustomPtr_End-.CustomPtr)/2)+!CustomOffset+1 : BCS $03 : JMP .Custom
		JMP .Clear			; invalid numbers should be cleared

	.Coin
		LDA !Ex_Data2,x : BEQ +		; hide coin if this timer is set
		DEC !Ex_Data2,x : BNE ++	;\
		LDY !Ex_Data3,x			; | when timer runs out...
		LDA !P1CoinIncrease,y		; |
		INC A				; | ...give coin to owner
		STA !P1CoinIncrease,y		; |
		LDA #$01 : STA !SPC4		; | ...and play sfx
	++	JMP .Return			;/
	+	PHK : PEA .Return-1		; RTL address = .Return
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
		DEC !Ex_Data1,x : BNE ..return
		..kill
		STZ !Ex_Num,x
		..return
		JML .Return
	;	PHK : PEA .Return-1		; RTL address = .Return
	;	PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
	;	JML $02939D			; process quake

	.Shooter
		LDY !Ex_Data1,x : BEQ +		;\
		PHA				; |
		LDA $13				; | decrement shooter timer every other frame
		LSR A : BCC ++			; |
		DEC !Ex_Data1,x			; |
	++	PLA				;/
	+	SEC : SBC #!ShooterOffset	; subtract offset
		PHK : PEA .Return-1		; RTL address = .Return
		PEA $8B66-1			; RTS address = $8B66 (points to an RTL)
		JML $02B3AB			; process shooter

	.Custom
		SEC : SBC #!CustomOffset+1
		PEA .Return-1
		ASL A
		TAX
		JMP (.CustomPtr,x)

		.CustomPtr
		dw DizzyStar			; 01
		dw LuigiFireball		; 02
		dw BigFireball			; 03
		dw CustomShooter		; 04
		dw MMX_Explosion		; 05
		..End


	.PalsetIndex
		db $FF	; 00 - empty
		db $0A	; 01 - coin, yellow

		db $FF	; 02 - empty
		db $0A	; 03 - brick piece, yellow
		db $0B	; 04 - small star, blue
		db $FF	; 05 - unused
		db $0C	; 06 - fire particle, red
		db $0B	; 07 - blue sparkle, blue
		db $0B	; 08 - Z, blue
		db $0B	; 09 - water splash, blue
		db $FF	; 0A - unused
		db $FF	; 0B - unused
		db $0F	; 0C - boo stream, ghost
		db $FF	; 0D - unused

		db $FF	; 0E - empty
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

		db $FF	; 21 - empty
		db $0A	; 22 - puff of smoke, yellow
		db $0A	; 23 - contact, yellow
		db $0A	; 24 - turn smoke, yellow
		db $FF	; 25 - unused
		db $0A	; 26 - glitter, yellow

		db $FF	; 27 - empty
		db $0A	; 28 - still turn block, yellow
		db $0A	; 29 - note block, yellow
		db $0A	; 2A - question block, yellow
		db $0A	; 2B - side bounce block, yellow
		db $0A	; 2C - unknown bounce sprite, yellow
		db $0A	; 2D - unknown bounce sprite, yellow
		db $0A	; 2E - unknown bounce sprite, yellow

		db $FF	; 2F - empty
		db $FF	; 30 - block hitbox
		db $FF	; 31 - yellow yoshi landing hitbox

		db $FF	; 32 - empty
		db $FF	; 33 - bullet bill shooter
		db $FF	; 34 - torpedo ted launcher

		db $FF	; 35 - empty
		db $0A	; 36 - dizzy star, yellow
		db $01	; 37 - luigi fireball, luigi palset
		db $0A	; 38 - big fireball, yellow
		..End


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


;=======================;
; CUSTOM FUSION SPRITES ;
;=======================;
incsrc "FusionSprites/DizzyStar.asm"
incsrc "FusionSprites/LuigiFireball.asm"
incsrc "FusionSprites/BigFireball.asm"
incsrc "FusionSprites/CustomShooter.asm"
incsrc "FusionSprites/MMX_Explosion.asm"




;=================;
; SHARED ROUTINES ;
;=================;
;
; input:
;	none
; output:
;	X = free index (if using X version)
;	Y = free index (if using Y version)
;	!Ex_Index = free index that was just found
;	the unused index reg is unchanged
;	if there is no index free, it will default to 00 and that exsprite will be overwritten


	Ex_GetIndex:

		.Y
		PHX
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	..loop	LDA !Ex_Num,y : BEQ ..thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ..loop		;/
		LDY #$00			; default index = 00
	..thisone
		PLX
		STY !Ex_Index			; update index
		CPY #$00			; update P
		RTL

		.X
		PHY
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	..loop	LDA !Ex_Num,x : BEQ ..thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ..loop		;/
		LDX #$00			; default index = 00
	..thisone
		PLY
		STX !Ex_Index			; update index
		CPX #$00			; update P
		RTL


;
; input:
;	JSL followed by table, returns to first byte after table
; returns:
;	$00	number of tiles drawn
;	$02	24-bit pointer to start write area
; table format:
;	header: ptttiiii iiiiiiii
;		p - 0 = use $64, 1 = use PP bits
;		t - number of tiles to read (read bytes = ttt*4)
;		i - GFX status index
;	for each tile:
;		Xdisp
;		Ydisp
;		tile
;		YXPP--s-
;	YX bits are written directly
;	PP bits are written directly if p is set, otherwise $64 is used
;	s is used as size bit
;
; $00 - 16-bit	Xpos
; $02 - 16-bit	Ypos
; $04 - 24-bit	pointer
; $07 - 8-bit	----
; $08 - 8-bit	p flag
; $0A -	16-bit	index to stop reading at
; $0C - 8-bit	tile offset from GFX status
; $0D - 8-bit	hi bit of tile number from GFX status
; $0E - 16-bit	working Xpos

	macro TilemapHeader(bytecount, GFX, P)
	if <P> = 0
		dw <GFX>|(<bytecount><<12)
	else
		dw <GFX>|(<bytecount><<12)|$8000
	endif
	endmacro


	DisplayGFX:
		REP #$20				;\
		LDA $01,s				; |
		INC A					; | pointer to first byte after JSL instruction
		STA $04					; |
		SEP #$20				; |
		LDA $03,s : STA $06			;/
		REP #$20				;\
		LDA [$04]				; |
		AND #$7000				; |
		XBA					; |
		LSR #2					; |
		STA $0A					; > save byte count header in RAM
		INC #2					; |
		CLC : ADC $01,s				; > update return address
		STA $01,s				;/
		LDA [$04]				;\
		AND #$8000				; | p flag
		STA $08-1				;/
		SEP #$20
		PHX					; > push X
		LDA !Ex_XLo,x : STA $00			;\
		LDA !Ex_XHi,x : STA $01			; | base coordinates
		LDA !Ex_YLo,x : STA $02			; |
		LDA !Ex_YHi,x : STA $03			;/
		LDA !Ex_Palset,x			;\
		AND #$0E				; | CCC bits
		STA $0D					;/
		STZ $0C					; base tile num
		BIT $08 : BMI .Skip64			; p bit
		.Set64					;\
		LDA $64					; |
		AND #$30				; | add PP bits from $64
		TSB $0D					; |
		.Skip64					;/
		REP #$30				;\
		LDA [$04]				; |
		AND #$0FFF				; |
		TAX					; | get GFX offset and increment pointer past header
		LDA !GFX_status,x			; |
		CPX #$0FFF				; |
		BNE $03 : LDA #$0000			; > 0xFFF = offset 0
		TSB $0C					; |
		INC $04					; |
		INC $04					; |
		SEP #$30				;/

		LDA $01,s : TAX
		LDA !Ex_Num,x
		CMP #$01 : BEQ DrawPrio2
		JMP DrawPrio3


	DrawPrio2:
		REP #$30
		LDA.l !OAMindex_p2
		CMP #$0200 : BCC .Draw
		SEP #$30
		PLX
		BRA .Return

	.Draw	TAX					; X = OAM index
		LDY #$0000				; Y = index to per-tile data
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
		SEP #$30
		PLX
		STZ !Ex_Num,x
		STX !Ex_Index				; index = slot that was just freed up
	.Return	STZ $00
		RTL

	.BadX	INY					;\
	.BadY	INY #3					; | off-screen: go to next tile
		SEP #$20				; |
		JMP .Next				;/

	.Loop	REP #$20				; A 16-bit (required, see end of loop)
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
	.GoodY	STA.l !OAM_p2+$001,x			; store Y
		SEP #$20				; A 8-bit
		LDA $0E : STA.l !OAM_p2+$000,x		; store X lo
		INY					;\
		LDA [$04],y				; | store tile number
		CLC : ADC $0C				; |
		STA.l !OAM_p2+$002,x			;/
		INY					;\
		LDA [$04],y				; |
		BIT $08 : BPL .64			; |
	.PP	AND #$F0 : BRA .Prop			; | store YXPPCCCT
	.64	AND #$C0				; |
		ORA $64					; |
	.Prop	ORA $0D					; |
		STA.l !OAM_p2+$003,x			;/
		PHX					;\
		REP #$20				; |
		TXA					; |
		LSR #2					; |
		TAX					; |
		SEP #$20				; | store hi byte
		LDA [$04],y				; |
		AND #$02				; |
		ORA $0F					; |
		STA.l !OAMhi_p2+$00,x			; |
		PLX					; |
		INY					;/
		INX #4					; increment OAM index
		CPX #$0200 : BCC .Next			;\
		LDX #$0200				; | handle maximum index
		BRA .Full				;/
	.Next	CPY $0A : BCS $03 : JMP .Loop		; loop

	.Full	REP #$20				;\
		TXA					; |
		SEC : SBC.l !OAMindex_p2		; | return $00 = number of tiles written
		LSR #2					; |
		STA $00					;/
		LDA.l !OAMindex_p2			;\
		CLC : ADC.w #!OAM_p3			; | $02 = pointer to start of OAM write
		STA $02					;/
		TXA : STA.l !OAMindex_p2		; update OAM index
		SEP #$30
		LDA.b #!OAM_p3>>16 : STA $04		; $04 = bank byte of pointer
		PLX					; pull X
		RTL					; return


	DrawPrio3:
		REP #$30
		LDA.l !OAMindex_p3
		CMP #$0200 : BCC .Draw
		SEP #$30
		PLX
		BRA .Return

	.Draw	TAX					; X = OAM index
		LDY #$0000				; Y = index to per-tile data
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
		SEP #$30
		PLX
		STZ !Ex_Num,x
		STX !Ex_Index				; index = slot that was just freed up
	.Return	STZ $00
		RTL

	.BadX	INY					;\
	.BadY	INY #3					; | off-screen: go to next tile
		SEP #$20				; |
		JMP .Next				;/

	.Loop	REP #$20				; A 16-bit (required, see end of loop)
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
	.GoodY	STA.l !OAM_p3+$001,x			; store Y
		SEP #$20				; A 8-bit
		LDA $0E : STA.l !OAM_p3+$000,x		; store X lo
		INY					;\
		LDA [$04],y				; | store tile number
		CLC : ADC $0C				; |
		STA.l !OAM_p3+$002,x			;/
		INY					;\
		LDA [$04],y				; |
		BIT $08 : BPL .64			; |
	.PP	AND #$F0 : BRA .Prop			; | store YXPPCCCT
	.64	AND #$C0				; |
		ORA $64					; |
	.Prop	ORA $0D					; |
		STA.l !OAM_p3+$003,x			;/
		PHX					;\
		REP #$20				; |
		TXA					; |
		LSR #2					; |
		TAX					; |
		SEP #$20				; | store hi byte
		LDA [$04],y				; |
		AND #$02				; |
		ORA $0F					; |
		STA.l !OAMhi_p3+$00,x			; |
		PLX					; |
		INY					;/
		INX #4					; increment OAM index
		CPX #$0200 : BCC .Next			;\
		LDX #$0200				; | handle maximum index
		BRA .Full				;/
	.Next	CPY $0A : BCS $03 : JMP .Loop		; loop

	.Full	REP #$20				;\
		TXA					; |
		SEC : SBC.l !OAMindex_p3		; | return $00 = number of tiles written
		LSR #2					; |
		STA $00					;/
		LDA.l !OAMindex_p3			;\
		CLC : ADC.w #!OAM_p3			; | $02 = pointer to start of OAM write
		STA $02					;/
		TXA : STA.l !OAMindex_p3		; update OAM index
		SEP #$30
		LDA.b #!OAM_p3>>16 : STA $04		; $04 = bank byte of pointer
		PLX					; pull X
		RTL					; return




;============;
; HAMMER FIX ;
;============;

	HammerSpinJump:
		JSL !CheckContact : BCS .Contact
		JML $02A468				; > return with no contact
.Contact	LDA !Ex_Num,x
		CMP #$04+!ExtendedOffset : BNE .NoHammer
		LDA !Ex_Data3,x
		LSR A : BCS .Return
		LDA $01					;\
		CMP $05					; | the top border of mario's hitbox has to be above the top border of the hammer's hitbox
		LDA $09					; |
		SBC $0B : BCS .NoHammer			;/
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


;=================;
; PARTICLE SYSTEM ;
;=================;
incsrc "ParticleSystem.asm"


;============;
; BG OBJECTS ;
;============;
incsrc "BG_objects.asm"


;==============;
; FUSION REMAP ;
;==============;
pushpc
incsrc "Remap.asm"
pullpc



;=========;
; BANK 02 ;
;=========;
incsrc "FusionSprites/BulletBillShooter.asm"
incsrc "FusionSprites/MalleableExtendedSprite.asm"

	; -- coin gfx fix --
	org $029A08
	ExCoin:
		PEI ($1A)				;\ preserve BG1 coords
		PEI ($1C)				;/
		REP #$20				;\
		LDA !Ex_Data1,x				; |
		AND #$0003				; |
		ASL #2					; | layer that coin is on
		TAY					; | 0 = BG1
		LDA $301A,y : STA $1A			; | 1 = BG2
		LDA $301C,y : STA $1C			; | 2 = BG3
		SEP #$20				;/
		TXA
		CLC : ADC $14
		AND #$0C : BEQ .frame0
		CMP #$08 : BNE .frame1
	.frame2	JSL DisplayGFX
		%TilemapHeader(2, $FFF, 0)
		db $04,$00,$57,$00
		db $04,$08,$57,$80
		BRA .Return
	.frame1	JSL DisplayGFX
		%TilemapHeader(2, $FFF, 0)
		db $04,$00,$47,$00
		db $04,$08,$47,$80
		BRA .Return
	.frame0	JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$45,$02
	.Return	REP #$20				;\
		PLA : STA $1C				; | restore BG1 coords
		PLA : STA $1A				; |
		SEP #$20				;/
		RTS
	warnpc $029AA8


	; -- minor gfx fix --
	org $028FCA
	BrickPiece:
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA $14
		LSR A
		CLC : ADC $7698
		AND #$07
		TAY
		LDA $8B84,y
		LDY #$02
		STA [$02],y
		LDA !Ex_Data1,x : BEQ .Return
		LDY #$03
		LDA [$02],y
		AND.b #$0E^$FF
		STA $00
		LDA $14
		AND #$0E
		ORA $00
		STA [$02],y
	.Return	RTS
	warnpc $02902D

	org $028EE1
	Sparkles:
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #3 : TAY
		CPY #$02
		BCC $02 : LDY #$02
		LDA !Ex_Num,x
		CMP #$02+!MinorOffset : BEQ .SmallStar
		.BlueSparkle
		INY #3
		.SmallStar
		LDA.w SparkleTiles,y			; same table but different offsets
		LDY #$02
		STA [$02],y
	.Return	RTS
	warnpc $028F2B


	org $028ECC
	SparkleTiles:
		db $5A,$59,$58
		db $4A,$49,$48
	warnpc $028ED2



	org $028F4D
	FireParticle:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_LavaEffects_offset, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #3
		TAY
		LDA $8F2B,y
		CLC : ADC $0C
		LDY #$02
		STA [$02],y
	.Return	RTS

	org $028E20
	Z:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_RipVanFish_offset, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #5
		AND #$03
		TAY
		LDA $8DD7,y
		CLC : ADC $0C
		LDY #$02
		STA [$02],y
	.Return	RTS
	warnpc $028E76

	org $028DEA
		BNE +
		STZ !Ex_Num,x		; make Z actually despawn when timer runs out
		RTS
		NOP
		+
	warnpc $028DF1

	org $028D42					; water splash tile table
		db $00,$00,$02,$02,$02,$60,$60,$60	; $68 -> $00, $6A -> $02
		db $5D,$5D,$5E,$5E,$5F

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
		CMP #$60 : BEQ .Smoke16x16		; catch 8x8 smoke tile
		.Smoke8x8
		JMP Smoke01_8
		.Smoke16x16
		JMP Smoke01_16
		.Water00
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_WaterEffects_offset, 0)
		db $00,$00,$00,$02
		RTS
		.Water02
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_WaterEffects_offset, 0)
		db $00,$00,$02,$02
		RTS
	warnpc $028DD7

	org $028CFF
	BooStream:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_Boo_offset, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		PHX
		TXA
		AND #$0B
		TAX
		LDA $8CB8,x
		PLX
		LDY #$02
		CLC : ADC [$02],y
		STA [$02],y
		LDA !Ex_XSpeed,x
		LSR A
		AND #$40
		LDY #$03
		ORA [$02],y
		STA [$02],y
	.Return	RTS
	warnpc $028D42


	; -- extended gfx fix --
	org $02A362
	SmokeExtended:
		LDA !Ex_Data2,x
		LSR #2
		TAY
		LDA $A347,y
		CMP #$60 : BEQ .16
	.8	JMP Smoke01_8

	.16	PHA
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$02
		PLA
		LDY $00 : BEQ .Return
		LDY #$02
		STA [$02],y
	.Return	RTS
	warnpc $02A3AE
	org $02A347
		db $5F,$5E,$5D,$60
	warnpc $02A34B



	org $02A178
	EnemyFireball:
		LDA !Ex_Num,x					;\ if num  = extended 02, this looks like mario's fireball
		CMP #$02+!ExtendedOffset : BEQ MarioFireball	;/ otherwise, it's a big fireball
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_ReznorFireball_offset, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY #$03
		LDA [$02],y
		AND #$3F
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		STA [$02],y
	.Return	RTS
	warnpc $02A1A4

	org $02A232
	TinyFlame:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_HoppingFlame_offset, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		AND #$04
		LSR #2
		TAY
		LDA $A217,y
		ADC $0C			; trick due to VERY limited space: the LSR always clears C
		LDY #$02
		STA [$02],y
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
		%TilemapHeader(1, !GFX_Hammer_offset, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDY #$03
		LDA [$02],y
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		STA [$02],y
	.Return	RTS
	warnpc $02A344

	org $029FB3
		BRA 13 : NOP #13
	warnpc $029FC2
	org $029FC5			; remove automatic fireball sprite interaction
		JSR $A0AC		; org: JSR $A0AC
	org $02A0AC
		TXA			; org: TXA
	org $02A0C4
		LDA !SpriteTweaker4,x	; org:
		AND #$02 : BNE +	;	LDA !SpriteTweaker4,x
		LDA $3200,x		;	AND #$02
		CMP #$36 : BEQ +	;	ORA ;yoshi eat reg
		BRA ++			;	ORA ;sprite behind layers reg
	warnpc $02A0D4			;	EOR !Ex_Data3,y : BNE $6F ($02A143)
	org $02A0D4
		++
	org $02A143
		+


	org $02A03B
		JMP MarioFireball
	org $02A1A4
	MarioFireball:
		LDA !Ex_Num,x
		CMP.b #$02+!CustomOffset : BEQ .Luigi

	.Mario	JSL DisplayGFX
		%TilemapHeader(1, !GFX_ReznorFireball_offset, 0)
		db $FC,$F8,$00,$02			; changed coords from 00;00, changed size to 02, removed xflip
		BRA .Shared

	.Luigi	JSL DisplayGFX
		%TilemapHeader(1, !GFX_LuigiFireball_offset, 0)
		db $00,$00,$00,$40

	.Shared	LDA $00 : BEQ .Return
		LDY #$03
		LDA [$02],y
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
	;	AND #$3F
	;	BIT !Ex_Data3,x
	;	BPL $02 : ORA #$C0
	;	BVC $02 : EOR #$40
		STA [$02],y
	.Return	RTS


	warnpc $02A211

	org $02A2C3
	Bone:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_Bone_offset, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		TXA
		AND #$01
		BEQ $02 : LDA #$C0
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
		LDY #$03
		ORA [$02],y
		STA [$02],y
	.Return	RTS
	warnpc $02A2EF			; we can overwrite the hammer tile table since it's unused
	org $03C44E
		BRA 6 : NOP #6		; spawn bone even if dry bones is off-screen
	warnpc $03C456

	org $029E9D
	LavaSplash:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_LavaEffects_offset, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		LDA !Ex_Data2,x
		LSR #3
		AND #$03
		TAY
		LDA $9E82,y
		LDY #$02
		STA [$02],y
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
		%TilemapHeader(1, !GFX_TorpedoTed_offset, 1)
		db $00,$00,$06,$12
		RTS
	.Tile08	JSL DisplayGFX
		%TilemapHeader(1, !GFX_TorpedoTed_offset, 1)
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
		%TilemapHeader(1, !GFX_LotusPollen_offset, 0)
		db $00,$00,$00,$00
		BRA .Done
	.Tile10	JSL DisplayGFX
		%TilemapHeader(1, !GFX_LotusPollen_offset, 0)
		db $00,$00,$10,$00
		BRA .Done
	warnpc $029BA5
	org $029BA5
	.Done

	org $02A271
	Baseball:
		JSL DisplayGFX
		%TilemapHeader(1, !GFX_Baseball_offset, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		TXA
		AND #$01
		BEQ $02 : LDA #$C0
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
		LDY #$03
		ORA [$02],y
		STA [$02],y
	.Return	RTS
	warnpc $02A2BF
	org $02C466
		LDA $32F0,x			;\ spawn baseball even if chuck is off-screen
		BEQ $03 : RTS : NOP #2		;/
	warnpc $02C46E

	org $029C88
	SpinJumpStars:
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$4F,$00
		BRA .Done
	warnpc $029C98
	org $029C98
		.Done

	org $029F2A
	ExBubble:
		LDA !Ex_Data1,x
		LSR #2
		AND #$03
		TAY
		LDA $9EEA,y
		BEQ .Disp00
		BMI .DispFF
	.Disp01	JSL DisplayGFX
		%TilemapHeader(1, !GFX_WaterEffects_offset, 0)
		db $01,$05,$04,$00
		RTS
	.Disp00	JSL DisplayGFX
		%TilemapHeader(1, !GFX_WaterEffects_offset, 0)
		db $00,$05,$04,$00
		RTS
	.DispFF	JSL DisplayGFX
		%TilemapHeader(1, !GFX_WaterEffects_offset, 0)
		db $FF,$05,$04,$00
		RTS
	warnpc $029F61


	; -- smoke gfx fix --
	org $02999F
	SmokeGeneric:
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDA !Ex_Data1,x
		LSR #2
		TAX
		LDA $9922,x
		LDY #$02
		STA [$02],y
	.Return	LDX $7698
		RTS

	org $029701
	Smoke01:
		LDA !Ex_Data1,x
		LSR #2
		TAY
		LDA $96D8,y
		CMP #$60 : BEQ .16
	.8	PHA
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $04,$04,$5E,$00
		PLA
		LDY $00 : BEQ .Return
		LDY #$02
		STA [$02],y
	.Return	RTS

	.16	JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$60,$02
		RTS
	warnpc $02974A
	org $02974A
		JMP Smoke01


	org $0297B2
	ContactGFX:
		PHB							;\
		STX $00							; |
		STZ $01							; |
		JSL !GetParticleIndex					; |
		PLB							; |
		SEP #$20						; |
		LDY $00							; |
		LDA !Ex_XLo,y : STA !41_Particle_XLo,x			; |
		LDA !Ex_XHi,y : STA !41_Particle_XHi,x			; | turn into particle form
		LDA !Ex_YLo,y : STA !41_Particle_YLo,x			; |
		LDA !Ex_YHi,y : STA !41_Particle_YHi,x			; |
		LDA #$C0 : STA !41_Particle_Prop,x			; |
		LDA #$07 : STA !41_Particle_Timer,x			; |
		LDA.b #!prt_contact : STA !41_Particle_Type,x		; |
		JSL !InitParticle : STA !41_Particle_Timer,x		; > store particle timer
		SEP #$30						; |
		LDX $00							; |
		STZ !Ex_Num,x						; |
		RTS							;/
	warnpc $029837

	org $029936
		JMP $9793		; skip a pointless code that just writes 0xF0 to OAM Y

	org $02996F
	TurnSmoke:
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$00
		LDA $00 : BEQ .Return
		PHX
		LDA !Ex_Data1,x
		LSR #2
		TAX
		LDA.w $9922,x
		LDY #$02
		STA [$02],y
		PLX
	.Return	RTS


	; -- bounce gfx fix --
	org $0291F8
	Bounce:
		LDA !Ex_Data3,x : BEQ .Die
		PEI ($1A)				;\ backup BG1 coords
		PEI ($1C)				;/
		LDY #$00				;\
		BIT !Ex_Data1,x				; |
		BPL $02 : LDY #$04			; | layer
		REP #$20				; | 00 = BG1
		LDA $301A,y : STA $1A			; | 80 = BG2
		LDA $301C,y : STA $1C			; |
		SEP #$20				;/
		JSL DisplayGFX
		%TilemapHeader(1, $FFF, 0)
		db $00,$00,$00,$02
		LDA $00 : BEQ .Return
		LDA !Ex_Num,x
		AND #$7F
		TAY
		LDA $91F0-!BounceOffset,y
		LDY #$02
		STA [$02],y
	.Return	REP #$20				;\
		PLA : STA $1C				; | restore BG1 coords
		PLA : STA $1A				; |
		SEP #$20				;/
	.Die	RTS
	warnpc $029265





print " - Ex_Num mapped to ........$", hex(!Ex_Num), " - $", hex(!Ex_Num+!Ex_Amount-1)
print " - Ex_Data1 mapped to ......$", hex(!Ex_Data1), " - $", hex(!Ex_Data1+!Ex_Amount-1)
print " - Ex_Data2 mapped to ......$", hex(!Ex_Data2), " - $", hex(!Ex_Data2+!Ex_Amount-1)
print " - Ex_Data3 mapped to ......$", hex(!Ex_Data3), " - $", hex(!Ex_Data3+!Ex_Amount-1)
print " - Ex_YLo mapped to ........$", hex(!Ex_YLo), " - $", hex(!Ex_YLo+!Ex_Amount-1)
print " - Ex_XLo mapped to ........$", hex(!Ex_XLo), " - $", hex(!Ex_XLo+!Ex_Amount-1)
print " - Ex_YHi mapped to ........$", hex(!Ex_YHi), " - $", hex(!Ex_YHi+!Ex_Amount-1)
print " - Ex_XHi mapped to ........$", hex(!Ex_XHi), " - $", hex(!Ex_XHi+!Ex_Amount-1)
print " - Ex_YSpeed mapped to .....$", hex(!Ex_YSpeed), " - $", hex(!Ex_YSpeed+!Ex_Amount-1)
print " - Ex_XSpeed mapped to .....$", hex(!Ex_XSpeed), " - $", hex(!Ex_XSpeed+!Ex_Amount-1)
print " - Ex_YFraction mapped to ..$", hex(!Ex_YFraction), " - $", hex(!Ex_YFraction+!Ex_Amount-1)
print " - Ex_XFraction mapped to ..$", hex(!Ex_XFraction), " - $", hex(!Ex_XFraction+!Ex_Amount-1)
print dec(!DebugRemapCount), " addresses remapped"
print "Number of ExSprites allowed: ", dec(!Ex_Amount), " (0x", hex(!Ex_Amount), ")"
print "Number of ExSprite types: ", dec(HandleEx_PalsetIndex_End-HandleEx_PalsetIndex), " (0x", hex(HandleEx_PalsetIndex_End-HandleEx_PalsetIndex), ")"
print " "
