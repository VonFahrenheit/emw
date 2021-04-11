header
sa1rom


macro BRK()
	SEP #$30
	TSC : XBA
	CMP #$37 : BNE ?BRK
	LDA.b #?BRK : STA $0183
	LDA.b #?BRK>>8 : STA $0184
	LDA.b #?BRK>>16 : STA $0185
	LDA #$D0 : STA $2209
-	LDA $018A : BEQ -
	STZ $018A
	BRA ?End

	?BRK:
	BRK #$FF

	?End:
endmacro


	; -- Defines --

	incsrc "../Defines.asm"



	org $048437
		dl Load
		dl Load_2
		dl KeepExtraBits
		dl SilverCoinFix

		; the following bytes are taken by SP_Patch, look there for more info on the next free space




	; -- Main Hijacks --

	org $018172
		JSL Init
		NOP

	org $0185C3
		JSL Main
		NOP


	org $01817D+($9B*2)
		dw $8171			; point hammer bro init to an RTS since it's unused and we want his space
	org $02DB64
		LDY #$0F			; let hammer bro platform search all sprite slots


	org $01907A
		JML DeathFix			;\ Source: STA $AE,x : LDA $33A0,x
		NOP				;/


	org $01D43E				; This is called later
		JSR $8133			; Handle status
		RTL


; 02A751 is very sus
; this code is responsible for initializing a bunch of variables for the sprite engine
; it seems to be super inefficient though
; removing it has really bizarre effects for unknown reasons
; seemingly, it does something i'm not aware of
;
; running this code fucks up spawned vanilla sprites by turning them into broken customs
; not runnning this code fucks up vanilla sprites by making them despawn instantly upon touching the edge of the screen
;

	org $02A751				; this routine initializes the sprite engine on level load
;		PHB : PHK : PLB
;		JSR $ABF2
;		JSR $AC5C
;		PLB
;		RTL

		LDX #$00			;\
		TXA				; | reset load status for all sprites
	-	STA !SpriteLoadStatus,x		; |
		INX : BNE -			;/
		REP #$10			;\
		LDX #$027A			; |
	-	STZ $7693,x			; | clear all this stuff or whatever
		DEX : BPL -			; |
		SEP #$10			;/
		STZ !ScrollSpriteNum_L1		;\ despawn scroll sprites
		STZ !ScrollSpriteNum_L2		;/
		JML InitSpriteEngine		; set some additional init data from LM3
	warnpc $02A773


	org $0288A7
		db $74				; replace feathers with mushrooms
	org $0288B8
		db $74


	org $029F13
		JML ExBubbleFix			; org: LDA !WaterLevel : BNE $13 ($029F2A)



	org $02A846
		JML NextSprite			; org: INY #2 : INX : BRA $E3 ($02A82E)
		NOP


	org $02A963
		JSL Load
		NOP
	;	AND #$0D
	;	STA $3240,x



	org $02A94B
		JSL Load_2
		NOP

	org $02A9DA
		JML LoadLoopFix			; overwrites an SA-1 JML, we need to take sprite data size into account (3 or 5)


	; $07F722: zero sprite tables
	; $07F78B: load tweaker bytes
	; $07F7D2: zero sprite tables, then load tweaker bytes

	org $07F722
		JML Erase

	org $07F794
		AND #$0E			; lowest bit comes from !SpriteProp

	org $07F7D2
		JSL Erase			; call this routine immediately instead of jumping back and forth
		JML SetSpriteTables		; use this routine as it handles both vanilla and custom sprites
	warnpc $07F7DA

	;org $07F785
	;	JSL Erase
	;	NOP

	org $018151
		JSL Erase
		NOP

	org $0187A7
		JML SetSpriteTables		; This can be JSL'd to load custom sprite data

	org $018127
		JML HandleStatus

	org $02A773
		db $0F				; > Sprite slot max
	org $02A786
		db $0F				; > Sprite slot max 1 special
	org $02A799
		db $0F				; > Sprite slot max 2 special
	org $02A0B8
		LDX #$0F			; > Highest sprite slot Mario's fireball interacts with


	org $0180B8
		LDA #$00			;\ Source: BEQ $04 : JSL $02F808 (cluster sprite routine)
		STA !ProcessingSprites		;/ Clear "processing sprites" flag

	org $02A9C9
		JSL KeepExtraBits		; DON'T autoclean this!


	org $0EF30C
		dl $308008			; pointer to sprite size table (for Lunar Magic)
		db $42				; signal to LM that sprite size table has been inserted



	org $0180C3
		JSL SpritesDone			; org: STZ $787A : STZ $788B
		NOP #2



	; -- Sprite Fixes --

	; -- sprite header data fix --
	org $02A773
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F	; sprite slot max
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
		db $0F,$0F,$0F
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F	; sprite slot max special 1
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
		db $0F,$0F,$0F
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F	; sprite slot max special 2
		db $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
		db $0F,$0F,$0F
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; sprite slot start (value to end loop at)
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $FF,$FF,$FF
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; sprite slot start (special)
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $FF,$FF,$FF
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; special sprite enable 1 (always off)
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $FF,$FF
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; special sprite enable 2 (always off)
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
		db $FF,$FF
	warnpc $02A7F6

	org $02A988
		BRA $0C				; change BPL to BRA to prevent special world sprite swap



	; Walk-off fix
	org $019466
		JML WalkOff_VertY		; > Org: CMP $5D : BCS $4A ($0194B4)

	org $01947B
		JML WalkOff_VertX		; > Org: CMP #$02 : BCS $35 ($0194B4)

	org $0194D2
		JML WalkOff_HorzY		; > Org: REP #$20 : LDA $0C

	org $0194DB
		STA $0D				; remove branch


	org $0194EC
		JML WalkOff_HorzX		; > Org: STA $0B : BMI $C4 ($0194B4) : CMP $5D : BCS $C0 (same)
		NOP #2
		STA $0B


	org $019537
		LDY $0F
		CMP #$00


	org $019F4F
		JML CarriedItemOAM		;\ org: LDA #$02 : ORA $3350,x
		NOP				;/



	; Lakitu Cloud fix
	org $0184CA
		JML LakituCloudSync		; org: PLX : STZ $78E0
		ReturnSync:
	org $01E7DB
		LDY #$0F			; this very simple index fix will let the lakitu cloud move properly


	; Goal Tape fix
	org $01C089
		LDA !ExtraBits,x
		NOP #4
		STA $34A0,x

	; Silver Coin fix
	org $02A9A6
		JSL SilverCoinFix
		NOP

	; eerie generator fix
	org $02B2E3
		LDA #$01			; initialize eerie so it can move


	; Spike Top vertical level fix
	org $02BDA7
		NOP #12				; Prevent Spike Tops from instantly despawning on vertical levels


	; Carried item OAM fix
	org $019F81
		BRA $03				;\ Prevent OAM bug
		NOP #3				;/


	; Custom carried item GFX fix
	org $01A1AE
		BEQ +				; Move this branch so it doesn't break from the hijack
	org $01A1CF
		+
	org $01A1D0
		JML CarriedItemFix		; Source: JSR $9806 : RTS

	org $01A96F
		NOP #4				; don't spawn feather from super koopa


	; -- Custom Code --

	org $168000
print " "
print "-- Fe26 --"
print "Fe26 sprite engine starts at $", pc, "."

macro decreg(reg)
	LDA <reg>,x
	BEQ ?skip
	DEC <reg>,x
	?skip:
endmacro


MainSpriteLoop:

		%TrackSetup(!TrackFe26)

		LDA.b #.Main : STA $3180
		LDA.b #.Main>>8 : STA $3181
		LDA.b #.Main>>16 : STA $3182
		JSR $1E80

		%TrackCPU(!TrackFe26)
		RTL


		.Main
		PHB : PHK : PLB

		JSR LoadSpriteFromLevel			; spawn sprites on the edges of the screen

		LDA #$01 : STA !ProcessingSprites	; set processing sprites flag

		LDA $748F : STA $7470
		STZ $748F
		STZ $7471
		STZ $78C2
		LDX #$0F
	.Loop	STX !SpriteIndex
		REP #$20
		LDA !SpriteIndex
		AND #$00FF
		CLC : ADC #$3200
		STA $D8
		CLC : ADC #$0010
		STA $DA
		CLC : ADC #$0010
		STA $DE
		SEP #$20
		LDA ($D8) : STA $87
		LDA !ExtraBits,x					;\
		AND #$08						; | for vanilla sprites, OAM index has to be 0, but for custom sprites this is a free reg
		BNE $03 : STZ $33B0,x					;/
		LDA $3230,x : BNE .WantToProcess			; check if sprite exists
		STZ $3200,x						;\
		STZ !ExtraBits,x					; |
		STZ !NewSpriteNum,x					; | if it doesn't, clear these regs
		STZ !ExtraProp1,x					; | (ID will automatically be set to 0xFF later)
		STZ !ExtraProp2,x					; | there might be a bug if a sprite slot is cleared and reused on the same frame
		BRA .NoDec						;/

	.WantToProcess
		LDA $9D : BNE .NoDec
		%decreg($32D0)			; main timer
		%decreg($32E0)			; P1 interaction disable timer
		%decreg($32F0)			; sinking timer
		%decreg($3300)			; sprite interaction disable timer
		%decreg($3360)			; misc timer 1
		%decreg($3420)			; misc timer 2
		%decreg($34D0)			; cape interaction disable timer
		%decreg($34E0)			; stasis timer
		%decreg($35F0)			; P2 interaction disable timer

		.NoDec
		PHK : PEA.w .Return-1		; RTL address: .Return
		PEA.w $80CA-1			; RTS address: $80CA ($0180CA points to RTL)
		JMP HandleStatus

		.Return
		; sort OAM here, right after the sprite was processed
		; legacy hi prio goes into prio 2
		; legacy lo prio goes into prio 1

		LDA !ExtraBits,x
		AND.b #$08 : BEQ .SortOAM
		JMP .NextSprite

	.SortOAM
		PHX							;\
		LDY #$00						; |
		REP #$30						; |
		LDA.l !OAMindex_p2 : TAX				; |
	-	CPY !OAMindex : BCS .FinishHiTable			; | copy the main table from legacy hi prio to prio 2
		LDA !OAM+$000,y : STA.l !OAM_p2+$000,x			; |
		LDA !OAM+$002,y : STA.l !OAM_p2+$002,x			; |
		INY #4							; |
		INX #4							; |
		BRA -							;/
	.FinishHiTable
		LDA !OAMindex : BEQ .HiPrioDone				;\
		LSR #2							; |
		STA $00							; |
		LDA.l !OAMindex_p2					; |
		LSR #2							; |
		TAX							; | copy hi table from legacy hi prio to hi table of prio 2
		SEP #$20						; |
	-	LDA !OAMhi+$00,y : STA.l !OAMhi_p2+$00,x		; |
		INX							; |
		INY							; |
		CPY $00 : BCC -						; |
		REP #$20						;/
		.HiPrioDone
		LDA.l !OAMindex_p2					;\
		CLC : ADC !OAMindex					; | update index regs
		STA.l !OAMindex_p2					; |
		STZ !OAMindex						;/

		SEP #$30						;\
		LDY !SpriteIndex					; |
		LDX $3200,y						; | find index to stop searching at
		LDA.l TileCount,x					; |
		ASL #2							; |
		STA $00							;/
		STZ $01
		LDY #$00						; Y = 00
		REP #$30						; all regs 16-bit (save 1 byte baybeeee)
		LDA !OAMindex_p1 : TAX					; X = OAM index
	-	CPY $00 : BCS .LoPrioDone				;\
		LDA !OAM+$101,y						; |
		AND #$00FF						; |
		CMP #$00F0 : BEQ +					; > skip erased tiles
		LDA !OAM+$100,y : STA.l !OAM_p1+$000,x			; |
		LDA !OAM+$102,y : STA.l !OAM_p1+$002,x			; |
		LDA #$00F0 : STA !OAM+$101,y				; > erase tile so it's not seen as part of next sprite
		PHX							; |
		PHY							; |
		TXA							; |
		LSR #2							; | copy data from legacy lo prio to prio 1
		TAX							; |
		TYA							; |
		LSR #2							; |
		TAY							; |
		SEP #$20						; |
		LDA !OAMhi+$40,y : STA.l !OAMhi_p1+$00,x		; > hi byte has to be done like this to account for skipped tiles
		REP #$20						; |
		PLY							; |
		PLX							; |
		INX #4							; |
	+	INY #4							; |
		BRA -							;/
	.LoPrioDone
		TXA : STA !OAMindex_p1					; update index

		.TilesDone
		SEP #$30
		PLX
		.NextSprite
		DEX : BMI .SpritesDone
		JMP .Loop

		.SpritesDone
		LDA #$00 : STA !ProcessingSprites	; clear processing sprites flag

		PHP
		REP #$20
		LDA !DizzyEffect
		AND #$00FF : BEQ +
		LDA !CameraBackupY : STA $1C		; restore camera
	+	PLP
		PLB
		RTL


; tile counts for all vanilla sprites

		;   X0  X1  X2  X3  X4  X5  X6  X7  X8  X9  XA  XB  XC  XD  XE  XF

TileCount:	db $02,$02,$02,$02,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$01	; 0X
		db $03,$01,$00,$01,$01,$01,$01,$01,$01,$00,$02,$01,$01,$01,$0F,$03	; 1X
		db $03,$02,$02,$02,$02,$02,$05,$04,$14,$12,$01,$0A,$01,$00,$01,$04	; 2X
		db $03,$02,$02,$01,$01,$04,$00,$01,$01,$01,$05,$05,$05,$01,$02,$02	; 3X
		db $02,$03,$03,$02,$03,$02,$05,$01,$01,$02,$01,$02,$01,$02,$02,$05	; 4X
		db $05,$01,$03,$01,$09,$05,$05,$05,$05,$05,$05,$03,$05,$05,$09,$09	; 5X
		db $02,$04,$03,$05,$05,$05,$05,$04,$01,$00,$02,$05,$05,$00,$04,$05	; 6X
		db $05,$04,$04,$04,$01,$01,$01,$01,$01,$01,$00,$03,$08,$01,$03,$03	; 7X
		db $01,$01,$12,$03,$03,$00,$07,$03,$00,$00,$01,$02,$00,$08,$00,$04	; 8X
		db $10,$05,$05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$06,$06,$10	; 9X
		db $00,$0C,$04,$06,$04,$01,$04,$01,$04,$06,$04,$02,$05,$05,$08,$01	; AX
		db $06,$01,$01,$02,$04,$01,$01,$03,$03,$01,$03,$04,$03,$02,$01,$04	; BX
		db $03,$05,$01,$04,$10,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00	; CX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$03,$03,$03,$00,$03	; DX
		db $12,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; EX
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; FX


incsrc "SpriteData.asm"


	Init:
		LDA !GameMode
		CMP #$14 : BEQ $03 : JMP .Return	; don't run until level has started!!
		LDA #$08 : STA $3230,x			; set status to MAIN
		LDA !ExtraBits,x
		AND #!CustomBit : BEQ .Vanilla

		.Custom
		PLA : PLA				;\ swap lower 2 bytes of RTL address to point to an RTS opcode
		PEA $85C2-1				;/ (instead of $018176, which will exectute the vanilla INIT code)
		JSL SetSpriteTables_Custom		; load custom sprite data
	;	LDA #$01				; ???
		JML [$3000]				; run INIT code

		.Vanilla
		PHX				;\
		LDA $3200,x			; |
		CMP #$02 : BNE +		; |
		JSL BlueKicker_RememberPosition	; > have kicker koopa remember its position
		PLX				; |
		BRA .Return			; > then have it return
	+	CMP #$3E : BEQ .P		; | get sprite num (with exceptions for P and statue)
		CMP #$BC : BNE +		;/
	.statue	LDA $3220,x			;\
		AND #$30			; |
		CMP #$20 : BNE .GoGr		; | check statue color
	.GoBr	PLX				; |
		BRA .Brown			;/
	.P	LDA $3220,x			;\
		AND #$10 : BEQ ++		; | check P-switch color
	.GoGr	PLX				; |
		BRA .Grey			;/
	++	LDA $3200,x			; get pswitch sprite num
	+	TAX				;\
		LDA $07F3FE,x			; |
		PLX				; | check for non-default palsets
		AND #$0E : BEQ .Brown		; |
		CMP #$02 : BEQ .Grey		; |
		CMP #$0C : BEQ .Ghost		; |
		CMP #$0E : BNE .Return		;/

	.DarkGrey
		LDA #$0D : BRA .Palset		; dark grey remapped to green
	.Brown	LDA #$0A : BRA .Palset		; brown remapped to yellow
	.Ghost	LDA #$0F : BRA .Palset		; ghost
	.Grey	LDA #$0E			; grey
	.Palset	JSL LoadPalset			;\
		LDA $3460,x			; |
		AND.b #$F0			; |
		STA $00				; |
		PHX				; | get palset for vanilla sprites
		LDX $0F				; |
		LDA !GFX_status+$180,x		; |
		PLX				; |
		ASL A				; |
		ORA $00				; |
		STA $3460,x			;/

		.Return
		LDA $3460,x
		AND #$0E
		STA $33C0,x
		RTL


	Main:
		STZ $7491
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Custom
		LDA ($D8)
		RTL

		.Custom
		PLA : PLA		;\ swap lower 2 bytes of RTL address to point to an RTS opcode
		PEA $85C2-1		;/
		LDA !NewSpriteNum,x
		JSR GetMainPtr
	;	LDA $3230,x		; ????
		JML [$3000]



	NextSprite:
;		DEY			;\
;		LDA [$CE],y		; | check custom bit
;		INY			; |
;		AND #$08 : BEQ +	;/
;		INY #4			;\ custom sprites are 5 bytes
;		BRA ++			;/
;
;	+	INY #2			; vanilla sprites are 3 bytes
;	++	INX			; next sprite in level
;		JML $02A82E		; return to loop



	Load:
;		PHA
;		AND #$0D
;		STA !ExtraBits,x
;		JSR .GetExpansionBytes
;		PLA : PHA
;		AND #$01
;		STA $3240,x
;		LDA $05 : STA !NewSpriteNum,x
;		PLA
;		RTL

		.2
;		PHA
;		AND #$0D
;		STA !ExtraBits,x
;		JSR .GetExpansionBytes
;		PLA : PHA
;		AND #$01
;		STA $3250,x
;		LDA $05 : STA !NewSpriteNum,x
;		PLA
;		RTL

	.GetExpansionBytes
;		LSR #2
;		CMP #$02 : BCC +
;		XBA
;		LDA $05
;		BRA ++
;	+	XBA
;		LDA $3200,x
;	++	PHX
;		PHP
;		REP #$30
;		TAX
;		LDA $308008,x
;		PLP
;		PLX
;		CMP #$03 : BEQ +
;		PHY
;		INY #3
;		LDA [$CE],y : STA !ExtraProp1,x
;		INY
;		LDA [$CE],y
;		AND #$3F
;		STA !ExtraProp2,x
;		PLY
;	+	RTS


	LoadLoopFix:
;		PLA					;\ clear garbage bytes (probably from a JSR)
;		PLA					;/
;		INX					; increment sprite index to level
;		PHY					;\
;		SEP #$10				; | this really just clears the high byte of X
;		REP #$10				;/
;		DEY #3					; > free because Y is on the stack
;		LDA [$CE],y				; check first byte of sprite data
;		PLY					; restore Y
;		AND #$08 : BEQ .Size3
;	.Size5
;		INY #2
;	.Size3
;		JML $02A82E				; back to main sprite load loop


	InitSpriteEngine:
		LDA $6BF4				; this is set as part of LM's level data
		AND #$03				;\
		ASL A					; |
		TAX					; |
		REP #$20				; | we need to set these due to LM hijacking the vanilla sprite off screen code
		LDA.l .min_y_range,x : STA $6BF0	; |
		LDA.l .max_y_range,x : STA $6BF2	; |
		SEP #$20				;/
		JMP MainSpriteLoop_Main			; go directly to SA-1 hook, ends in RTL so this is fine

	; shoutout to Vitor for straight up giving me these
	.min_y_range
	dw -192, -48, -128, -16383		; Horizontal, Vertical, Enhanced Vertical, Infinity
	.max_y_range
	dw +432, 288, +352, +16383		; Horizontal, Vertical, Enhanced Vertical, Infinity



	LoadSpriteFromLevel:
		PHP					;\
		SEP #$20				; |
		BIT $6BF4 : BPL .NoSmart		; |
		LDA $1A					; |
		CMP $6BEE : BNE .SmartUpdate		; | if smart spawn is enabled, sprites only spawn if the camera has moved since last time this was called
		LDA $1C					; |
		CMP $6BEF : BNE .SmartUpdate		; |
		PLP					; |
		RTS					;/
	.SmartUpdate					;\
		LDA $1A : STA $6BEE			; | update smart regs
		LDA $1C : STA $6BEF			; |
	.NoSmart					;/

; for large levels, pushing/pulling these is faster than using addr regs
; $45	left border of spawn box
; $47	right border of spawn box
; $49	top border of spawn box
; $4B	bottom border of spawn box
; $4D	left border of forbiddance box
; $4F	right border of forbiddance box
; $51	top border of forbiddance box
; $53	bottom border of forbiddance box

		PEI ($45)
		PEI ($47)
		PEI ($49)
		PEI ($4B)
		PEI ($4D)
		PEI ($4F)
		PEI ($51)
		PEI ($53)
		SEP #$30
		LDA $6BF4
		AND #$03
		ASL A
		TAX
		REP #$30

		LDA $1A						; > BG1 Xpos
		AND #$FFF0					;
		SEC : SBC #$0030				;\
		BPL $03 : LDA #$0000				; | left border spawn box (-0x30)
		STA $45						;/
		CLC : ADC #$0151				;\ right border spawn box (+0x121)
		STA $47						;/
		SEC : SBC #$0141				;\ left border forbiddance box (-0x20)
		STA $4D						;/
		CLC : ADC #$0131				;\ right border forbiddance box (+0x111)
		STA $4F						;/
		LDA $1C						;\
		AND #$FFF0					; | top border spawn box
		STA $00						; > store
		CLC : ADC.w InitSpriteEngine_min_y_range,x	; |
		STA $49						;/
		LDA $00						;\
		CLC : ADC.w InitSpriteEngine_max_y_range,x	; | bottom border spawn box
		STA $4B						;/
		LDA $00						;\
		SEC : SBC #$0020				; | top border forbiddance box
		STA $51						;/
		CLC : ADC #$0111				;\ bottom border forbiddance box
		STA $53						;/

		LDA !GameMode					;\
		AND #$00FF					; |
		CMP #$0014 : BEQ .SpawnBoxReady			; |
		STZ $4D						; | if in any game mode other than 0x14, disable forbiddance box
		STZ $4F						; | this way all sprites on-screen can be loaded immediately
		STZ $51						; |
		STZ $53						; |
	.SpawnBoxReady						;/


		SEP #$20
		LDX #$FFFF					; which sprite we're on (note that the loop starts with INX)
		LDY #$0001					; index to sprite data
		STZ $0E						; clear new sprite system flag
		LDA [$CE]					;\
		AND #$20					; | set sprite system
		BEQ $02 : DEC $0E				;/
		STZ $0F						; clear dynamic Y offset


	.LoadNewSprite
		INX						; next sprite
	.ReadNext
		LDA [$CE],y
		CMP #$FF : BNE .Sprite
	.Command
		BIT $0E : BPL .End
		INY
		LDA [$CE],y : BPL .UpdateY
		CMP #$FF : BEQ .Sprite

	.End
		JMP .Return

	.UpdateY
		ASL A					;\ update dynamic Y offset
		STA $0F					;/
		INY					; increment index
		BRA .ReadNext				; get next (without going to next sprite)

	.Spawned
		INY
	.OutOfBounds
		SEP #$20				; A 8-bit
		LDA $08					;\ vanilla/custom
		AND #$08 : BEQ +			;/
		INY #2					;\ skip past its data
	+	INY #2					;/ (we already incremented once)
		BRA .LoadNewSprite			; get next

	.Sprite
		STA $05					; $05 = copy of first byte
		AND #$0C : STA $08			; $08 = extra bits
		LDA !SpriteLoadStatus,x : BNE .Spawned	; see if sprite is marked for spawning
		LDA $05					;\
		AND #$02				; | $01 = hi Xpos
		ASL #3					; | (highest bit)
		STA $01					;/
		LDA $05					;\
		AND #$01				; | $03 = hi Ypos
		ORA $0F					; | (+dynamic Y offset)
		STA $03					;/
		LDA $05					;\
		AND #$F0				; | $02 = lo Ypos
		STA $02					;/
		INY					;\
		LDA [$CE],y				; | $00 = lo Xpos
		AND #$F0				; |
		STA $00					;/
		LDA [$CE],y				;\
		AND #$0F				; | $01 = hi Xpos
		TSB $01					;/  (complete)

		REP #$20				;\
	if !TrackSpriteLoad
		PHX
		TXA
		ASL A
		TAX
		LDA $02
		XBA
		STA !DebugData+$00,x
		PLX
	endif
		LDA $00					; |
		CMP $45 : BCC .OutOfBounds		; |
		CMP $47 : BCS .OutOfBounds		; | has to be within spawn box
		LDA $02					; |
		CMP $49 : BCC .OutOfBounds		; |
		CMP $4B : BCS .OutOfBounds		;/
		CMP $51 : BCC .GoodXY			;\
		CMP $53 : BCS .GoodXY			; |
		LDA $00					; | has to be outside of forbiddance box
		CMP $4D : BCC .GoodXY			; |
		CMP $4F : BCC .OutOfBounds		; |
	.GoodXY	SEP #$20				;/

		PHX					;\
		LDX #$000F				; |
	-	LDA $3230,x : BEQ .ThisIndex		; | search for a sprite index
		DEX : BPL -				; | (return if no one is found)
		PLX					; |
	.SpawnFail					;/
		INY
		JMP .LoadNewSprite
	.ThisIndex
	; TO DO:
	; - shooters
	; - generators
	; - scroll sprites
	; - multi sprites (eeries etc)
		INY					; get ready to read num byte
		LDA $08 : STA !ExtraBits,x		; write extra bits
		AND #$08 : BEQ .NotCustom		; see if custom or vanilla

	.Custom
		LDA #$01 : STA $04			; state = INIT
		LDA [$CE],y : STA !NewSpriteNum,x	; sprite num
		INY					;\ prop 1
		LDA [$CE],y : STA !ExtraProp1,x		;/
		INY					;\
		LDA [$CE],y				; | prop 2
		AND #$3F				; | (highest 2 bits from static sprite data)
		STA !ExtraProp2,x			;/
		JMP .INIT				; go to INIT
	.NotCustom


		LDA [$CE],y
		CMP #$F6 : BCS .SpawnFail		; F6-FF are banned by lunar magic and can never be used
		CMP #$E7 : BCC .NotScroll		; E7-F5: scroll sprite
		.Scroll
		SBC #$E7
		XBA
		LDA !ScrollSpriteNum_L1
		ORA !ScrollSpriteNum_L2
		BNE .SpawnFail
		XBA
		STA !ScrollSpriteNum
		LDA $02
		LSR #2
		STA $7440				; Ypos / 4
		PHX
		PHY
		JSL $05BCD6				; init scroll sprite?
		PLY
		PLX
		INY
		JMP .LoadNewSprite
		.NotScroll

		CMP #$DE : BNE .NotEeries		; DE: 5 eeries
		JSR .Spawn5Eeries
		BRA +
		.NotEeries

		CMP #$E0 : BNE .NotPlatforms		; E0: 3 platforms on chains
		JSR .Spawn3Platforms
	-
	+	PLX
		LDA #$01 : STA !SpriteLoadStatus,x
		INY
		JMP .LoadNewSprite
		.NotPlatforms

		CMP #$CB : BCC .NotGenerator		; CB-D9: generator
		CMP #$DA : BCS .Shell
		SBC #$CB
		INC A
		STA !GeneratorNum
		LDA #$00 : STA !SpriteLoadStatus,x	; generator can always be reloaded
		.NotGenerator

		CMP #$C9 : BCC .Vanilla			; C9-CA: shooter
		.Shooter
		SBC.b #$C8-!ShooterOffset
		STA $05
		PHY
		SEP #$10
		%Ex_Index_Y_fast()
		REP #$10
		LDA $05 : STA !Ex_Num,y			; num
		LDA $00 : STA !Ex_XLo,y			;\
		LDA $01 : STA !Ex_XHi,y			; | coords
		LDA $02 : STA !Ex_YLo,y			; |
		LDA $03 : STA !Ex_YHi,y			;/
		TXA : STA !Ex_Data1,y			; shooter index to level sprite data
		LDA #$10 : STA !Ex_Data2,y		; timer: 32 frames at spawn (decrements every other frame)
		PLY
		BRA -

		.Shell
		SBC #$DA
		CMP #$04
		BCC $02 : LDA #$00
		ORA #$04
		STA $3200,x
		LDA #$09 : STA $04
		BRA .INIT

; 00-C8		normal sprite
; C9-CA		shooter
; CB-D9		generator
; DA-DD		stationary shells
; DE		5 eeries
; DF		green shell, immune to special world
; E0		3 platforms on chains
; E1-E6		cluster sprite
; E7-F5		scroll sprite
; F6-FF		banned by lunar magic


; remap:
;	CB-D9	generators, probably includes some custom ones
;	E1-E6	special commands
;	E7-F5	HDMA pointer commands
;	F6-FF	can't be used, unfortunately, since LM refuses to insert these in any way and will throw errors if they are inserted by a third party
;
;

;	CB	eerie gen
;	CC	para-goomba gen
;	CD	para-bomb gen
;	CE	para-bomb + para-goomba gen
;	CF	dolphin left gen
;	D0	dolphin right gen
;	D1	jumping fish gen
;	D2	turn off gen 2 (same as sprite E5?????)
;	D3	supepr koopa gen
;	D4	bubble with goomba and bob-omb gen
;	D5	bullet bill gen
;	D6	bullet bill surround gen
;	D7	bullet bill diagonal gen
;	D8	bowser fire gen
;	D9	turn off gen
;
;	E1	reload sprite GFX
;	E2	reload dynamic layer object GFX
;	E3	reload pathing map
;	E4	
;	E5
;	E6

;	E7	enable 3D water
;	E8	enable basic parallax
;	E9
;	EA
;	EB
;	EC
;	ED
;	EE
;	EF
;	F0
;	F1
;	F2
;	F3
;	F4
;	F5
;



	.Vanilla
		STA $3200,x				; sprite num
		LDA #$01 : STA $04

	.INIT
		INY					; increment index
		LDA $00 : STA $3220,x			;\
		LDA $01 : STA $3250,x			; | write coords
		LDA $02 : STA $3210,x			; |
		LDA $03 : STA $3240,x			;/
		JSL !ResetSprite			; reset/reload tables (this routine shreds $00-$02)
		LDA $04 : STA $3230,x			; state
		LDA $01,s : STA $33F0,x			; sprite index to level table, sprite ID
		LDA !ExtraBits,x			;\
		AND #$08 : BEQ .NoInit			; |
		PHY					; |
		PHP					; |
		SEP #$30				; | run INIT routine of custom sprites right away
		PHK : PEA ..return-1			; |
		JML [$3000]				; |
		..return				; |
		PLP					; |
		PLY					;/
	.NoInit
		PLX					; restore sprite counter
		LDA #$01 : STA !SpriteLoadStatus,x		; mark this sprite as spawned
		CPY #$0500 : BCS .Return		;\ just to make sure nothing goes wrong
		JMP .LoadNewSprite			;/

		.Return
		REP #$20
		PLA : STA $53
		PLA : STA $51
		PLA : STA $4F
		PLA : STA $4D
		PLA : STA $4B
		PLA : STA $49
		PLA : STA $47
		PLA : STA $45
		PLP
		RTS

	.Spawn5Eeries
		PHB					;\ wrap to bank 0x02
		LDA #$02 : PHA : PLB			;/
		PHY					; push Y
		SEP #$10				; index 8-bit
		LDY #$04				; loop counter
		LDX #$0F				;\
	-	LDA $3230,x : BEQ +			; | loop through sprite slots
	--	DEX : BPL -				;/
		BRA ++					; end if all sprite slots are full

	+	LDA #$08 : STA $3230,x			;\ sprite 0x39, state MAIN
		LDA #$39 : STA $3200,x			;/
		STZ !ExtraBits,x			; vanilla sprite, extra bit clear
		PEI ($02)				;\ this is overwritten by palset loader
		PEI ($00)				;/
		JSL !InitSpriteTables			; reset + init
		PLA : STA $00				;\
		PLA : STA $01				; | this is overwritten by palset loader
		PLA : STA $02				; |
		PLA : STA $03				;/
		LDA $00					;\
		CLC : ADC $AF87,y			; |
		STA $3220,x				; | x pos
		LDA $01					; |
		ADC $AF8C,y				; |
		STA $3250,x				;/
		LDA $02 : STA $3210,x			;\ y pos
		LDA $03 : STA $3240,x			;/
		PHY					;\
		JSR SUB_HORZ_POS			; | x speed
		LDA $AF9B,y : STA $AE,x			; |
		PLY					;/
		LDA $AF91,y : STA $9E,x			; y speed
		LDA $AF96,y : STA $BE,x			; state
		CPY #$04 : BNE +			;\ only the "main" eerie gets a sprite ID, the others use the default 0xFF meaning they can't respawn
		LDA $06,s : STA $33F0,x			;/
	+	DEY : BPL --				; main eerie loop
	++	REP #$10				; index 16-bit
		PLY					; pull Y
		PLB					; pull bank
		RTS					; return

	.Spawn3Platforms
		PHB					;\ wrap to bank 0x02
		LDA #$02 : PHA : PLB			;/
		PHY					; push Y
		SEP #$10				; index 8-bit
		LDY #$02				; loop counter
		LDX #$0F				;\
	-	LDA $3230,x : BEQ +			; | loop through sprite slots
	--	DEX : BPL -				;/
		BRA ++					; end if all sprite slots are full

	+	LDA #$01 : STA $3230,x			;\ sprite 0xA3, state INIT
		LDA #$A3 : STA $3200,x			;/
		STZ !ExtraBits,x			; vanilla sprite, extra bit clear
		PEI ($02)				;\ this is overwritten by palset loader
		PEI ($00)				;/
		JSL !InitSpriteTables			; reset + init
		PLA : STA $00				;\
		PLA : STA $01				; | this is overwritten by palset loader
		PLA : STA $02				; |
		PLA : STA $03				;/
		LDA $00 : STA $3220,x			;\ x pos
		LDA $01 : STA $3250,x			;/
		LDA $02 : STA $3210,x			;\ y pos
		LDA $03 : STA $3240,x			;/
		LDA $AF2D,y : STA $33D0,x		; rotation lo byte
		LDA $AF30,y : STA $32A0,x		; rotation hi byte
		CPY #$02 : BNE +			;\ only the "main" platform gets a sprite ID, the others use the default 0xFF meaning they can't respawn
		LDA $06,s : STA $33F0,x			;/
	+	DEY : BPL --				; main platform loop
	++	REP #$10				; index 16-bit
		PLY					; pull Y
		PLB					; pull bank
		RTS					; return



	Erase:
		STZ $9E,x				;\ speed
		STZ $AE,x				;/
		STZ $BE,x				; misc
	;	STZ $3200,x				; sprite number
	;	STZ $3210,x				; Ypos lo
	;	STZ $3220,x				; Xpos lo
	;	STZ $3230,x				; sprite status
	;	STZ $3240,x				; Ypos hi
	;	STZ $3250,x				; Xpos hi
		STZ $3260,x				;\ fraction bits
		STZ $3270,x				;/
		STZ $3280,x				; misc
		STZ $3290,x				; misc
		STZ $32A0,x				; misc
		STZ $32B0,x				; misc
		STZ $32C0,x				; !ClaimedGFX
		STZ $32D0,x				; main timer
		STZ $32E0,x				; P1 interaction disable timer
		STZ $32F0,x				; sinking timer
		STZ $3300,x				; sprite interaction disable timer
		STZ $3310,x				; !SpriteAnimTimer
		STZ $3320,x				; direction
		STZ $3330,x				; collision status
		STZ $3340,x				; misc
		STZ $3350,x				; misc (off-screen horz)
		STZ $3360,x				; misc timer 1
		STZ $3370,x				; slope status
		STZ $3380,x				; misc (off-screen horz by more than 4 tiles)
		STZ $3390,x				; misc (being eaten)
		STZ $33A0,x				; disable object interaction flag
		STZ $33B0,x				; misc (old OAM index)
		STZ $33C0,x				; OAM prop
		STZ $33D0,x				; !SpriteAnimIndex
		STZ $33E0,x				; misc
		LDA #$FF : STA $33F0,x			; sprite index in level, sprite ID (defaults to 0xFF = no ID, can't respawn)
		STZ $3400,x				; misc (consecutive kills)
		STZ $3410,x				; misc (behind scenery)
		STZ $3420,x				; misc timer 2
		STZ $3430,x				; water flag
		STZ $3440,x				; tweaker 1
		STZ $3450,x				; tweaker 2
		STZ $3460,x				; tweaker 3
		STZ $3470,x				; tweaker 4
		STZ $3480,x				; tweaker 5
		STZ $3490,x				; misc (sprite off-screen vert)
		STZ $34A0,x				; misc (stomp immunity flag)
		STZ $34B0,x				; tweaker 6
		STZ $34C0,x				; misc (unused by vanilla)
		STZ $34D0,x				; cape interaction disable timer
		STZ $34E0,x				; PhysicsPlus: stasis timer
		STZ $34F0,x				; misc (shell owner)
		STZ $3500,x				; PhysicsPlus: gravity modifier
		STZ $3510,x				; PhysicsPlus: gravity timer
		STZ $3520,x				; PhysicsPlus: vector Y
		STZ $3530,x				; PhysicsPlus: vector X
		STZ $3540,x				; PhysicsPlus: vector acceleration Y
		STZ $3550,x				; PhysicsPlus: vector acceleration X
		STZ $3560,x				; PhysicsPlus: vector timer Y
		STZ $3570,x				; PhysicsPlus: vector timer X
		STZ $3580,x				; PhysicsPlus: extra collision
	;	STZ $3590,x				; extra bits
	;	STZ $35A0,x				; extra byte 1
	;	STZ $35B0,x				; extra byte 2
	;	STZ $35C0,x				; custom sprite number
		STZ $35D0,x				; misc (unused by vanilla)
		STZ $35E0,x				; misc (unused by vanilla)
		STZ $35F0,x				; P2 interaction disable timer
		RTL



	GetMainPtr:
		PHB : PHK : PLB
		PHP
		STZ $2250
		REP #$30
		LDA !NewSpriteNum,x
		AND #$00FF
		STA $2251
		LDA #$000E : STA $2253
		BRA $00 : NOP
		LDY $2306

		LDA SpriteData+$0A,y : STA $00
		LDA SpriteData+$0B,y : STA $01

		PLP
		PLB
		RTS


	SetSpriteTables:
		LDA !ExtraBits,x			;\ see if custom
		AND #$08 : BNE .Custom			;/

		.Vanilla
		PHY
		PHP
		SEP #$30
		STZ !ExtraProp1,x
		STZ !ExtraProp2,x
		STZ !NewSpriteNum,x
		JSL !LoadTweakers			; load vanilla tweakers
		JSL Init_Vanilla			; make sure palset is loaded even if sprite was spawned in a state other than 01
		PLP
		PLY
		RTL

		.Custom
		PHB : PHK : PLB
		PHY
		PHP
		LDA !NewSpriteNum,x
		STZ $2250				;\
		REP #$30				; |
		AND #$00FF				; |
		STA $2251				; | index = sprite num * 14
		LDA #$000E : STA $2253			; |
		NOP					; |
		SEP #$20				; |
		LDY $2306				;/
		LDA SpriteData+$00,y : STA $3200,x	; acts like
		LDA SpriteData+$01,y : STA $3440,x	;\
		LDA SpriteData+$02,y : STA $3450,x	; |
		LDA SpriteData+$03,y : STA $3460,x	; | tweaker bytes
		AND #$0E : STA $33C0,x			; > CCC bits
		LDA SpriteData+$04,y : STA $3470,x	; |
		LDA SpriteData+$05,y : STA $3480,x	; |
		LDA SpriteData+$06,y : STA $34B0,x	;/
		REP #$20				;\
		LDA SpriteData+$07,y : STA $00		; | INIT pointer
		SEP #$20				; |
		LDA SpriteData+$09,y : STA $02		;/
		LDA !ExtraProp2,x			;\
		AND #$3F				; |
		STA !ExtraProp2,x			; |
		LDA SpriteData+$0D,y			; | highest 2 bits of prop2
		AND #$C0				; |
		ORA !ExtraProp2,x			; |
		STA !ExtraProp2,x			;/
		PLP
		PLY
		PLB
		RTL


	HandleStatus:
		SEP #$20
		LDA #$01 : PHA : PLB
		LDA !GameMode
		CMP #$14 : BNE +
		LDA $3230,x : BEQ +
		LDA !DizzyEffect : BEQ +
		REP #$20
		LDA !CameraBackupY : STA $1C
		SEP #$20
		LDA $3250,x : XBA
		LDA $3220,x
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

		JSR UpdateTile			; update VR3 tile claim
		LDA $3230,x
		CMP #$02 : BCC .CallDefault
		CMP #$08 : BNE .NoMainRoutine
	;	JMP Main			; we need to take the roundabout way due to stack order
		JML $0185C3

		.NoMainRoutine
		PHA
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Custom
		PLA

		.CallDefault
		JML $018133

		.Custom
		LDA !ExtraProp2,x : BMI .CallMain
		PHA
		LDA $02,s
		JSL $01D43E
		PLA
		ASL A
		BMI .CallMain
		PLA
		CMP #$09 : BCS .CallMain2
		CMP #$03 : BEQ .CallMain2
		JML $0185C2

		.CallMain2
		PHA

		.CallMain
		LDA !NewSpriteNum,x
		JSR GetMainPtr
		PLA
		LDY #$01 : PHY
		PEA $85C2-1
		JML [$3000]


	UpdateTile:
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Custom

		.Vanilla
		LDY $3230,x				; get status
		PHX					;\
		LDA $3200,x : TAX			; |
		STA $00					; > save sprite number here
		LDA $188450,x : TAX			;/
		LDA $00					;\
		CMP #$7E : BEQ ++			; \
		CMP #$7F : BNE +++			;  | flying rainbow shroom and flying red coin should use index 0xFE
	++	LDX #$FE				;  |
		BRA +					; /
	+++	CMP #$0D : BCS +			; |
		CMP #$04 : BCC +			; | get sprite's load status
		CPY #$02 : BEQ ++			; |
		CPY #$09 : BCC +			; | (special case for koopa shell)
		CPY #$0C : BCS +			; |
	++	LDX #$5B				;/
	+	LDA !GFX_status,x			;\
		ASL A					; |
		ROL A					; |
		AND #$01				; |
		STA !BigRAM				; |
		LDA !GFX_status,x			; |
		AND #$70				; | unpack PYYYXXXX format
		ASL A					; |
		STA !BigRAM+1				; |
		LDA !GFX_status,x			; |
		AND #$0F				; |
		TSB !BigRAM+1				; |
		PLX					;/
		LDA !BigRAM+1 : STA !SpriteTile,x	;\ update VRAM offset
		LDA !BigRAM : STA !SpriteProp,x		;/
		RTS

		.Custom
		PHX					;\
		LDA !NewSpriteNum,x : TAX		; | get sprite's load status
		LDA $188550,x : TAX			;/
		LDA !GFX_status,x			;\
		ASL A					; |
		ROL A					; |
		AND #$01				; |
		STA !BigRAM				; |
		LDA !GFX_status,x			; |
		AND #$70				; | unpack PYYYXXXX format
		ASL A					; |
		STA !BigRAM+1				; |
		LDA !GFX_status,x			; |
		AND #$0F				; |
		TSB !BigRAM+1				; |
		PLX					;/
		LDA !BigRAM+1 : STA !SpriteTile,x	;\ update VRAM offset
		LDA !BigRAM : STA !SpriteProp,x		;/
		RTS



	CarriedItemOAM:
		LDA $3230,x
		CMP #$0B : BEQ .Mario

		LDA !P2Character-$80
		CMP #$01 : BEQ .P1
		LDA !P2Character
		CMP #$01 : BNE .Return

	.P2	LDA !P2Status : BNE .Return
		LDA !P2Anim
		CMP #$10 : BNE .Return
		LDA !P2Carry
		BRA +

	.P1	LDA !P2Status-$80 : BNE .Return
		LDA !P2Anim-$80
		CMP #$10 : BNE .Return
		LDA !P2Carry-$80
	+	STA $00
		TXA
		INC A
		CMP $00 : BEQ .HiPrio

	.Return	LDA #$02			;\
		ORA $3350,x			; | normal routine
		JML $019F54			;/

	.Mario	LDA $7499 : BEQ .Return
	.HiPrio	LDA #$04 : JSR HI_PRIO_OAM
		JML $019F5A



	LakituCloudSync:
		TXY
		STY $00
		PLX
		CPX $00 : BCC .Return		; if lakitu has the lower index it's fine

		REP #$30			; if lakitu has higher index, completely swap sprites
		TXA
		CLC : ADC #$03F0
		TAX
		TYA
		CLC : ADC #$03F0
	-	TAY
		SEP #$20
		LDA $3200,x : XBA
		LDA $3200,y : XBA
		STA $3200,y
		XBA : STA $3200,x
		REP #$20
		TXA
		SEC : SBC #$0010
		TAX
		TYA
		SEC : SBC #$0010
		BPL -
		SEP #$30
		STY !SpriteIndex
		LDX !SpriteIndex

	.Return
		STZ $78E0			; overwritten code
		;PLX
		JML ReturnSync




	SilverCoinFix:
		PHA
		LDA !ExtraBits,x
		AND #!CustomBit
		BNE .Custom
		LDA #$00
		XBA
		PLA
		TAX
		LDA $07F659,x
		RTL

		.Custom
		PLA
		LDA !NewSpriteNum,x
		STZ $2250
		PHP
		REP #$30
		AND #$00FF
		STA $2251
		LDA #$000E : STA $2253
		BRA $00 : NOP
		LDX $2306
		LDA.l SpriteData+$06,x
		PLP
		RTL


	KeepExtraBits:
;		LDA !ExtraBits,x
;		PHA
;		PHX
;		PHY
;		PHP
;		SEP #$10
;		JSL !InitSpriteTables
;		PLP
;		PLY
;		PLX
;		PLA
;		STA !ExtraBits,x
;		RTL


	; this code runs at the end of each sprite loop
	SpritesDone:
;		PHP
;		REP #$20
;		LDA !DizzyEffect
;		AND #$00FF : BEQ +
;		LDA !CameraBackupY : STA $1C		; restore camera
;	+	PLP
;		STZ $787A
;		STZ $788B
;		RTL


	DeathFix:
		STA $AE,x
		LDA $3230,x
		CMP #$02 : BEQ .019085
		LDA $33A0,x : BNE .019085
	.019081	JML $019081
	.019085	JML $019085


	ExBubbleFix:
		LDA !WaterLevel : BNE .029F2A	; check for water level
		LDA !3DWater : BEQ .029F17	; check for 3D water
		LDA !IceLevel : BNE .029F17	; no water if frozen
		LDA !Ex_YHi,x : XBA		;\
		LDA !Ex_YLo,x			; |
		REP #$20			; | check if below water
		CMP !Level+2			; |
		SEP #$20			; |
		BCS .029F2A			;/

	.029F17	JML $029F17			; not in water (checks map16 after this)
	.029F2A	JML $029F2A			; in water



	CarriedItemFix:
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Return
		JML $019806

		.Return
		JML $01A1CF





incsrc "PhysicsPlus.asm"

Bank16:

incsrc "SpriteSubRoutines.asm"
incsrc "GFX_expand.asm"

print "Fe26 Sprite Engine ends at $", pc, "."

print "Sprite data inserted at $", pc, "."
print " "
print "-- SPRITE LIST --"

incsrc "Replace/SP_spring_board.asm"
incsrc "Replace/SP_Koopa.asm"
incsrc "Replace/SP_Mole.asm"
incsrc "Replace/SP_RainbowShroom.asm"
incsrc "Replace/SP_SpikeTop.asm"
incsrc "Replace/SP_Spiny.asm"
incsrc "Replace/SP_Coin.asm"
incsrc "Replace/SP_HammerPlat.asm"
incsrc "Replace/SP_SumoLightning.asm"
incsrc "Replace/SP_Swooper.asm"
incsrc "Replace/SP_Rip.asm"

macro InsertSprite(name)
	START_<name>:
	incsrc "Sprites/<name>.asm"
	END_<name>:
	print "<name> inserted at $", hex(START_<name>), " ($", hex(END_<name>-START_<name>), " bytess)"
endmacro


print " "
print "-- BANK $16 --"

Bank16Start:

%InsertSprite(HappySlime)
%InsertSprite(GoombaSlave)
%InsertSprite(RexCode)
%InsertSprite(Projectile)

Bank16End:

print "Bank $16 ends at $", pc, ". ($", hex($170000-Bank16End), " bytes left)"


org $178000
db $53,$54,$41,$52
dw $FFF7
dw $0008

Bank17:

print " "
print "-- BANK $17 --"
%InsertSprite(NPC)
%InsertSprite(Block)
%InsertSprite(KingKing)
%InsertSprite(LakituLovers)
%InsertSprite(DancerKoopa)
%InsertSprite(SpinySpecial)
%InsertSprite(Thif)
%InsertSprite(KompositeKoopa)
%InsertSprite(Birdo)
%InsertSprite(Bumper)
%InsertSprite(Sign)
%InsertSprite(Monkey)
%InsertSprite(MiniMole)
%InsertSprite(TerrainPlatform)
%InsertSprite(CoinGolem)
%InsertSprite(YoshiCoin)
%InsertSprite(EliteKoopa)
%InsertSprite(MoleWizard)
%InsertSprite(BooHoo)
%InsertSprite(GigaThwomp)
%InsertSprite(MiniMech)

	WalkOff:
	.VertY	BMI ..LimitUp
		CMP $5D : BCC ..Return

		..LimitDown
		LDA #$F0 : STA $00
		LDA #$FF : STA $0C
		LDA $5D
		DEC A
		BRA ..Return

		..LimitUp
		STZ $00
		STZ $0C
		LDA #$00

		..Return
		JML $01946A			; within bounds


	.VertX	BMI ..LimitLeft
		CMP #$02 : BCC ..Return

		..LimitRight
		LDA #$F0
		STA $01
		STA $0A
		LDA #$01
		BRA ..Return

		..LimitLeft
		STZ $01
		STZ $0A
		LDA #$00

		..Return
		JML $01947F			; within bounds


	.HorzY	REP #$20
		LDA $0C
		BMI ..LimitUp
		CMP !LevelHeight		; address added by Lunar Magic 3
		SEP #$20
		BCS ..LimitDown
		XBA
		BRA ..Return

		..LimitDown
		LDA !LevelHeight
		SEC : SBC #$10
		STA $00
		STA $0C
		LDA !LevelHeight+1
		BRA ..Return

		..LimitUp
		SEP #$20
		STZ $00
		STZ $0C
		LDA #$00

		..Return
		JML $0194DB			; within bounds


	.HorzX	BMI ..LimitLeft
		CMP $5D : BCC ..Return

		..LimitRight
		LDA #$F0
		STA $01
		STA $0A
		LDA $5D
		DEC A
		BRA ..Return

		..LimitLeft
		STZ $01
		STZ $0A
		LDA #$00

		..Return
		JML $0194F2			; within bounds




BANK17End:

print "Bank $17 ends at $", pc, ". ($", hex($180000-BANK17End), " bytes left)"


org $1A8000

Bank1A:

print " "
print "-- BANK $1A --"
%InsertSprite(LavaLord)
%InsertSprite(FlamePillar)
%InsertSprite(BigMax)
%InsertSprite(Portal)
%InsertSprite(TarCreeper)
%InsertSprite(PlantHead)
%InsertSprite(UltraFuzzy)
%InsertSprite(ShieldBearer)
%InsertSprite(Elevator)
%InsertSprite(CaptainWarrior)


BANK1AEnd:

print "Bank $1A ends at $", pc, ". ($", hex($1B0000-BANK1AEnd), " bytes left)"
print " "

