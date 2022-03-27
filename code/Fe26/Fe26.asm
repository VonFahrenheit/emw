

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


	org $0195F2				; stunned sprite interaction
		JSR $A40D			; org: JSR $8FC1


	org $019F71				; carried status (HandleSprCarried in all.log)
		TXA
		INC A
		CMP !P2Carry-$80 : BEQ +
		CMP !P2Carry : BEQ +
		LDA #$09 : STA $3230,x
	+	LDA $3200,x : BMI KEY_REROUTE
		LDA $64 : PHA
		JSR $A187
		PLA : STA $64
		RTS
	KEY_REROUTE:
		JSL KEY_MAIN
		RTS
	warnpc $019F99
	org $07F3FE+$80
		db $24				; key palset = yellow



	org $01A91C
		JSL SPINJUMP_FIX		;\ org: LDA !MarioSpinJump : ORA $787A (check mario spin jump + yoshi flag)
		NOP #2				;/


	org $01E1B8
		JSL KEYHOLE_MAIN
		RTS
	warnpc $01E1C8


	org $07F335+$80				;\ make key hitbox smaller
		db $00				;/

	org $0185CC+($80*2)			;\ repoint key MAIN
		dw KEY_REROUTE			;/


	org $01817D+($80*2)			;\ repoint key INIT
		dw KEY_REROUTE			;/
	org $01817D+($9B*2)			;\ point hammer bro init to an RTS since it's unused and we want his space
		dw $8171			;/
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
		NOP #6				; org: BEQ $04 : JSL $02F008 (cluster sprite routine)

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



	; patch out fire flower (turns into mushroom)
	org $01C349				; fire flower code:
		LDA #$74 : STA !SpriteNum,x	; org: LDA $14 : AND #$04 : LSR A
		LDA #$08 : STA $33C0,x		; org: LSR #2 : STA $3320,x
	warnpc $01C353


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

	JMP MainSpriteLoop

incsrc "SpriteData.asm"



MainSpriteLoop:


	; should now be called by the processor that runs it
	;	%TrackSetup(!TrackFe26)

	;	LDA.b #.Main : STA $3180
	;	LDA.b #.Main>>8 : STA $3181
	;	LDA.b #.Main>>16 : STA $3182
	;	JSR $1E80

	;	%TrackCPU(!TrackFe26)
	;	RTL


		.Main
		PHB

		LDA.b #!PlatformData>>16		;\ addr access
		PHA : PLB				;/

		STZ.w !PlatformExists			; clear platform flag
		%ClearPlatform($00)			;\
		%ClearPlatform($01)			; |
		%ClearPlatform($02)			; |
		%ClearPlatform($03)			; |
		%ClearPlatform($04)			; |
		%ClearPlatform($05)			; |
		%ClearPlatform($06)			; |
		%ClearPlatform($07)			; | clear platforms
		%ClearPlatform($08)			; |
		%ClearPlatform($09)			; |
		%ClearPlatform($0A)			; |
		%ClearPlatform($0B)			; |
		%ClearPlatform($0C)			; |
		%ClearPlatform($0D)			; |
		%ClearPlatform($0E)			; |
		%ClearPlatform($0F)			;/
		STZ.w !ShieldExists			; clear shield flag
		REP #$20				;\
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; | clear shield boxes
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		%ClearShield($00)			; |
		SEP #$20				;/

		PHK : PLB				; get program bank

		LDA !GameMode				;\
		CMP #$14 : BNE .Load			; | > ignore camera in game modes other than 0x14
		LDA !BG1_X_Delta			; |
		ORA !BG1_Y_Delta			; | spawn sprites on the edges of the screen
		BEQ .NoLoad				; | (but only if the camera has moved this frame)
		.Load					; |
		JSR LoadSpriteFromLevel			; |
		LDA !ProcessingSprites : BNE .NoLoad
		PLB
		RTL
		.NoLoad					;/

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
		LDA $3200,x						;\
		CMP #$FF : BEQ +					; |
		JSL Erase						; | erase if status = 00 (if sprite num = 0xFF, this sprite is already erased)
		LDA #$FF : STA $3200,x					; |
	+	JMP .Return						;/

	.WantToProcess
		%decreg($32D0)			; main timer
		%decreg($32F0)			; sinking timer
		%decreg($3300)			; sprite interaction disable timer
		%decreg($3360)			; misc timer 1
		%decreg($3420)			; misc timer 2
		%decreg($34D0)			; cape interaction disable timer
		LDA !SpriteStasis,x : BEQ +	;\
		CMP #$FF : BEQ +		; | stasis timer (if set to -1, it will never end)
		DEC !SpriteStasis,x		; |
		+				;/
		%decreg(!SpriteDisP1)		; P1 interaction disable timer
		%decreg(!SpriteDisP2)		; P2 interaction disable timer

		.NoDec
		LDA !SpriteWater,x : PHA
		PHK : PEA.w .CheckSplash-1	; RTL address: .CheckSplash
		PEA.w $80CA-1			; RTS address: $80CA ($0180CA points to RTL)
		JMP HandleStatus

		.CheckSplash						;\
		PLA							; |
		CMP !SpriteWater,x : BEQ ..done				; |
		%Ex_Index_Y()						; |
		LDA #$07+!MinorOffset : STA !Ex_Num,y			; | splash when entering or exiting water
		LDA #$00 : STA !Ex_Data1,y				; |
		LDA !SpriteXLo,x : STA !Ex_XLo,y			; |
		LDA !SpriteXHi,x : STA !Ex_XHi,y			; |
		LDA !SpriteYLo,x : STA !Ex_YLo,y			; |
		LDA !SpriteYHi,x : STA !Ex_YHi,y			;/
		..done

		.Return
		LDA $3230,x : BNE ..processitem				;\
		STZ !ExtraBits,x					; |
		STZ !NewSpriteNum,x					; | if status is 00 after sprite has been processed...
		STZ !ExtraProp1,x					; | ...clear custom sprite regs
		STZ !ExtraProp2,x					; | (this fixes a bug if a slot is opened and claimed on the same frame)
		BRA ..notitem						;/
		..processitem
		CMP #$09 : BEQ ..item
		CMP #$0B : BNE ..notitem
		..item
		JSL !GetSpriteClipping04
		LDA $05
		SEC : SBC #$02
		STA $05
		BCS $02 : DEC $0B
		INC $07
		INC $07
		LDA $3330,x
		AND #$04 : BNE +
		LDA #$04 : BRA ++
	+	LDA #$07
	++	JSL OutputPlatformBox
		..notitem


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
		LDY #$0000						; |
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


	Init:
	;	LDA !GameMode
	;	CMP #$14 : BEQ $03 : JMP .Return	; don't run until level has started!!
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
		CMP #$0E : BEQ .DarkGrey	;/
		LDY !GameMode			;\ only search for default palset if it was loaded during level
		CPY #$14 : BNE .Return		;/
		LSR A				;\
		ADC #$08			; | default palset
		BRA .Palset			;/

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
		LDA !Palset_status,x		; |
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
		LDA !SpriteStasis,x : BNE .KeepDelta	;\
		STZ !SpriteDeltaX,x			; | just make sure these are cleared every frame
		STZ !SpriteDeltaY,x			; | ...except in stasis
		.KeepDelta				;/


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
		STZ $3230+$0				;\
		STZ $3230+$1				; |
		STZ $3230+$2				; |
		STZ $3230+$3				; |
		STZ $3230+$4				; |
		STZ $3230+$5				; |
		STZ $3230+$6				; |
		STZ $3230+$7				; | kill all sprites
		STZ $3230+$8				; |
		STZ $3230+$9				; |
		STZ $3230+$A				; |
		STZ $3230+$B				; |
		STZ $3230+$C				; |
		STZ $3230+$D				; |
		STZ $3230+$E				; |
		STZ $3230+$F				;/


		.UnmarkP1Item				;\
		LDA !HeldItemP1_num			; |
		CMP #$FF : BEQ ..done			; |
		REP #$20				; |
		LDA !HeldItemP1_level			; |
		CMP !Level				; | mark P1 item
		SEP #$20				; |
		BNE ..done				; |
		LDX !HeldItemP1_ID			; |
		CPX #$FF : BEQ ..done			; |
		LDA #$EE : STA !SpriteLoadStatus,x	; |
		..done					;/

		.UnmarkP2Item				;\
		LDA !HeldItemP2_num			; |
		CMP #$FF : BEQ ..done			; |
		REP #$20				; |
		LDA !HeldItemP2_level			; |
		CMP !Level				; | mark P2 item
		SEP #$20				; |
		BNE ..done				; |
		LDX !HeldItemP2_ID			; |
		CPX #$FF : BEQ ..done			; |
		LDA #$EE : STA !SpriteLoadStatus,x	; |
		..done					;/


		LDA $6BF4				; this is set as part of LM's level data
		AND #$03				;\
		ASL A					; |
		TAX					; |
		REP #$20				; | we need to set these due to LM hijacking the vanilla sprite off screen code
		LDA.l .min_y_range,x : STA $6BF0	; |
		LDA.l .max_y_range,x : STA $6BF2	; |
		SEP #$20				;/
		LDA #$00 : STA !ProcessingSprites
		JMP MainSpriteLoop_Main			; go directly to SA-1 hook, ends in RTL so this is fine

	; shoutout to Vitor for straight up giving me these
	.min_y_range
	dw $FF40,$FFD0,$FF80,$C001		; Horizontal, Vertical, Enhanced Vertical, Infinity
	.max_y_range
	dw $01B0,$0120,$0160,$3FFF		; Horizontal, Vertical, Enhanced Vertical, Infinity



macro NegZero(address)
	LDA <address> : BPL ?Ok
	STZ <address>
	?Ok:
endmacro


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

; $F0	left border of spawn box
; $F2	right border of spawn box
; $F4	top border of spawn box
; $F6	bottom border of spawn box
; $F8	left border of forbiddance box
; $FA	right border of forbiddance box
; $FC	top border of forbiddance box
; $FE	bottom border of forbiddance box

		LDA !GameMode
		CMP #$14 : BEQ ..nobackup
		PEI ($F0)
		PEI ($F2)
		PEI ($F4)
		PEI ($F6)
		PEI ($F8)
		PEI ($FA)
		PEI ($FC)
		PEI ($FE)
		..nobackup
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
		STA $F0						;/
		CLC : ADC #$0151				;\ right border spawn box (+0x121)
		STA $F2						;/
		SEC : SBC #$0141				;\ left border forbiddance box (-0x20)
		STA $F8						;/
		CLC : ADC #$0131				;\ right border forbiddance box (+0x111)
		STA $FA						;/
		LDA $1C						;\
		AND #$FFF0					; | top border spawn box
		STA $00						; > store
		CLC : ADC.w InitSpriteEngine_min_y_range,x	; |
		STA $F4						;/
		LDA $00						;\
		CLC : ADC.w InitSpriteEngine_max_y_range,x	; | bottom border spawn box
		STA $F6						;/
		LDA $00						;\
		SEC : SBC #$0020				; | top border forbiddance box
		STA $FC						;/
		CLC : ADC #$0111				;\ bottom border forbiddance box
		STA $FE						;/

		%NegZero($F0)					;\
		%NegZero($F2)					; |
		%NegZero($F4)					; |
		%NegZero($F6)					; | no negative coordinates allowed
		%NegZero($F8)					; |
		%NegZero($FA)					; |
		%NegZero($FC)					; |
		%NegZero($FE)					;/

		LDA !GameMode					;\
		AND #$00FF					; |
		CMP #$0014 : BEQ .SpawnBoxReady			; |
		STZ $F8						; | if in any game mode other than 0x14, disable forbiddance box
		STZ $FA						; | this way all sprites on-screen can be loaded immediately
		STZ $FC						; |
		STZ $FE						; |
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
		CMP $F0 : BCC .OutOfBounds		; |
		CMP $F2 : BCS .OutOfBounds		; | has to be within spawn box
		LDA $02					; |
		CMP $F4 : BCC .OutOfBounds		; |
		CMP $F6 : BCS .OutOfBounds		;/
		CMP $FC : BCC .GoodXY			;\
		CMP $FE : BCS .GoodXY			; |
		LDA $00					; | has to be outside of forbiddance box
		CMP $F8 : BCC .GoodXY			; |
		CMP $FA : BCC .OutOfBounds		; |
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
		INY					; get ready to read num byte
		LDA $08 : STA !ExtraBits,x		; write extra bits
		AND #$08 : BEQ .NotCustom		; see if custom or vanilla

	.Custom
		LDA #$01 : STA $04			; state = INIT
		LDA [$CE],y : STA !NewSpriteNum,x	; sprite num
		INY					;\ prop 1
		LDA [$CE],y : STA !ExtraProp1,x		;/
		INY					;\ prop 2
		LDA [$CE],y : STA !ExtraProp2,x		;/
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
		SBC.b #$C8-!ShooterOffset		;\
		CMP.b #$01+!ShooterOffset		; | custom bullet bill shooter
		BNE $02 : LDA.b #$04+!CustomOffset	;/
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
		TXA : STA !Ex_Data2,y			; shooter index to level sprite data
		LDA #$10 : STA !Ex_Data1,y		; timer: 32 frames at spawn (decrements every other frame)
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
		LDA !3DWater : BEQ ..no3dwater		;\
		REP #$20				; |
		LDA $02					; |
		CMP !Level+2				; | init in water
		SEP #$20				; |
		BCC ..no3dwater				; |
		LDA #$01 : STA !SpriteWater,x		; |
		..no3dwater				;/
		LDA $04 : STA $3230,x			; state
		LDA $01,s : STA $33F0,x			; sprite index to level table, sprite level ID
		LDA !ExtraBits,x			;\
		AND.b #!CustomBit : BEQ .NoInit		; |
		PHY					; |
		PHP					; |
		SEP #$30				; | run INIT routine of custom sprites right away (no, this breaks too many sprites)
		PHX
	;	PHK : PEA ..return-1			; |
	;	JML [$3000]				; |
		..return				; |
		PLX
	;	LDA #$08 : STA $3230,x			; > status = MAIN
		PLP					; |
		PLY					;/
	.NoInit
		PLX					; restore sprite counter
		LDA #$01 : STA !SpriteLoadStatus,x	; mark this sprite as spawned
		CPY #$0500 : BCS .Return		;\ just to make sure nothing goes wrong
		JMP .LoadNewSprite			;/

		.Return
		REP #$20
		LDA !GameMode
		AND #$00FF
		CMP #$0014 : BEQ ..done
		PLA : STA $FE
		PLA : STA $FC
		PLA : STA $FA
		PLA : STA $F8
		PLA : STA $F6
		PLA : STA $F4
		PLA : STA $F2
		PLA : STA $F0
		..done
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
		.IRAM
		STZ $9E,x				;\ speed
		STZ $AE,x				;/
		STZ $BE,x				; misc
	;	STZ $3200,x				; sprite num
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
		STZ $34E0,x				; misc
		STZ $34F0,x				; misc (shell owner)
		STZ $3500,x				; misc
		STZ $3510,x				; misc
		STZ $3520,x				; misc
		STZ $3530,x				; misc
		STZ $3540,x				; misc
		STZ $3550,x				; misc
		STZ $3560,x				; misc
		STZ $3570,x				; misc
		STZ $3580,x				; misc
	;	STZ $3590,x				; extra bits
	;	STZ $35A0,x				; extra byte 1
	;	STZ $35B0,x				; extra byte 2
	;	STZ $35C0,x				; custom sprite number
		STZ $35D0,x				; misc (unused by vanilla)
		STZ $35E0,x				; misc (unused by vanilla)
		STZ $35F0,x				; P2 interaction disable timer

		.BWRAM					;\
		STZ !SpriteStasis,x			; |
		STZ !SpritePhaseTimer,x			; |
		STZ !SpriteGravityMod,x			; |
		STZ !SpriteGravityTimer,x		; |
		STZ !SpriteVectorY,x			; |
		STZ !SpriteVectorX,x			; | PhysicsPlus registers
		STZ !SpriteVectorAccY,x			; |
		STZ !SpriteVectorAccX,x			; |
		STZ !SpriteVectorTimerY,x		; |
		STZ !SpriteVectorTimerX,x		; |
		STZ !SpriteExtraCollision,x		; |
		STZ !SpriteDeltaX,x			; |
		STZ !SpriteDeltaY,x			; |
		LDA #$40 : STA !SpriteFallSpeed,x	;/

		.DynamicList
		PHX
		PHP
		REP #$30
		TXA
		ASL A : TAX
		LDA !DynamicList+0,x : TRB !DynamicTile+0
		STZ !DynamicList+0,x
		PLP
		PLX
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
		AND.b #!CustomBit : BNE .Custom		;/

		.Vanilla
		PHY
		PHP
		SEP #$30
		STZ !ExtraProp1,x
		STZ !ExtraProp2,x
		STZ !NewSpriteNum,x
		JSL !LoadTweakers				; load vanilla tweakers
		LDA $04 : PHA					; LoadPalset will eat this byte if lighting is enabled
		JSL Init_Vanilla				; make sure palset is loaded even if sprite was spawned in a state other than 01
		PLA : STA $04					; keep this baybeeeeee
		PLP
		PLY
		RTL

		.Custom
		PHB : PHK : PLB
		PHY
		PHP
		LDA !NewSpriteNum,x
		STZ $2250					;\
		REP #$30					; |
		AND #$00FF					; |
		STA $2251					; | index = sprite num * 14
		LDA #$000E : STA $2253				; |
		NOP						; |
		SEP #$20					; |
		LDY $2306					;/
		LDA SpriteData+$00,y : STA $3200,x		; acts like
		LDA SpriteData+$01,y : STA !SpriteTweaker1,x	;\
		LDA SpriteData+$02,y : STA !SpriteTweaker2,x	; |
		LDA SpriteData+$03,y : STA !SpriteTweaker3,x	; | tweaker bytes
		AND #$0E : STA $33C0,x				; > CCC bits
		LDA SpriteData+$04,y : STA !SpriteTweaker4,x	; |
		LDA SpriteData+$05,y : STA !SpriteTweaker5,x	; |
		LDA SpriteData+$06,y : STA !SpriteTweaker6,x	;/
		REP #$20					;\
		LDA SpriteData+$07,y : STA $00			; | INIT pointer
		SEP #$20					; |
		LDA SpriteData+$09,y : STA $02			;/
		LDA SpriteData+$0D,y				;\
		AND #$C0					; | highest 2 bits of extra bits
		ORA !ExtraBits,x				; |
		STA !ExtraBits,x				;/
		PLP
		PLY
		PLB
		RTL


	HandleStatus:
		SEP #$20					; A 8-bit
		LDA #$01 : PHA : PLB				; bank = 0x01

		.Dizzy
		LDA !GameMode					;\
		CMP #$14 : BNE ..done				; | check for dizzy effect
		LDA $3230,x : BEQ ..done			; |
		LDA !DizzyEffect : BEQ ..done			;/
		REP #$20					;\
		LDA !CameraBackupY : STA $1C			; |
		SEP #$20					; |
		LDA $3250,x : XBA				; |
		LDA $3220,x					; |
		REP #$20					; |
		SEC : SBC $1A					; |
		AND #$00FF					; |
		LSR #3						; |
		ASL A						; | apply dizzy offset
		PHX						; |
		TAX						; |
		LDA !DecompBuffer+$1040,x			; |
		AND #$01FF					; |
		CMP #$0100					; |
		BCC $03 : ORA #$FE00				; |
		STA $1C						; |
		PLX						; |
		SEP #$20					; |
		..done						;/

		.UpdateTile					;\
		LDA !ExtraBits,x				; | vanilla/custom check
		AND #!CustomBit : BNE ..custom			; |
		..vanilla					;/
		LDY $3230,x					; get status
		PHX						;\
		REP #$30					; |
		LDA $3200,x					; |
		AND #$00FF : STA $00				; > save sprite number here
		ASL A						; |
		TAX						; |
		LDA $188450,x					; | (don't update if = 0xFFFF)
		CMP #$FFFF : BNE ..updatevanilla		;/
		..dontupdate					;\
		SEP #$30					; |
		PLX						; | restore X and default to 0
		STZ !SpriteTile,x				; |
		STZ !SpriteProp,x				; |
		BRA ..done					;/
		..updatevanilla					;\
		TAX						; |
		LDA $00						; |
		CMP #$007E : BEQ ..dontupdate			; |
		CMP #$007F : BEQ ..dontupdate			; > flying rainbow shroom and flying red coin should use 0
		CMP #$000D : BCS ..update			; |
		CMP #$0004 : BCC ..update			; | get sprite's load status
		CPY #$0002 : BEQ ..shell			; |
		CPY #$0009 : BCC ..update			; | (special case for koopa shell)
		CPY #$000C : BCS ..update			; |
	..shell	LDX.w #!GFX_Shell_offset : BRA ..update		;/
		..custom					;\
		PHX						; |
		REP #$30					; |
		LDA !NewSpriteNum,x				; |
		AND #$00FF					; | get sprite's load status
		ASL A						; |
		TAX						; |
		LDA $188650,x : BPL ..updatecustom		;/ (don't update if negative)
		SEP #$30					;\
		PLX						; | just return if negative
		BRA ..done					;/
		..updatecustom					;\ X = index
		TAX						;/
		..update					;\
		LDA !GFX_status,x				; |
		SEP #$30					; |
		PLX						; | get tile + prop
		STA !SpriteTile,x				; |
		XBA : STA !SpriteProp,x				; |
		..done						;/

		LDA !3DWater : BEQ ..no3dwater
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CMP !Level+2
		SEP #$20
		BCC ..no3dwater
		LDA $3230,x
		CMP #$02 : BNE +
		LDA #$01 : STA !SpriteWater,x
	+	LDA !SpriteExtraCollision,x
		ORA #$40 : STA !SpriteExtraCollision,x
		..no3dwater

		LDA $3230,x
		CMP #$02 : BCC .CallDefault
		CMP #$04 : BEQ .Puff
		CMP #$08 : BNE .NoMainRoutine
	;	JMP Main					; we need to take the roundabout way due to stack order
		JML $0185C3

		.NoMainRoutine
		PHA
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Custom
		PLA
		.CallDefault
		JML $018133

		.Puff						;\
		REP #$20					; |
		PLA						; > pull RTS address
		STZ $00						; |
		STZ $02						; | transform into puff particle
		STZ $04						; |
		SEP #$20					; |
		LDA $64 : STA $07				; |
		LDA #!prt_smoke16x16 : JSL SpawnParticle	; |
		STZ $3230,x					;/
		RTL						; return

		.Custom
		LDA !ExtraBits,x : BMI .CallMain
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



	CarriedItemOAM:
		LDA $3230,x
		CMP #$0B : BNE .Return
		TXA
		INC A
		LDY #$00
		CMP !P2Carry-$80 : BEQ +
		LDY #$80
	+	LDA !P2TurnTimer-$80,y : BNE .HiPrio

	.Return	LDA #$02				;\
		ORA $3350,x				; | normal routine
		JML $019F54				;/

	.HiPrio	LDA !OAMindex : TAY			;\
		CLC : ADC #$04				; |
		STA !OAMindex				; |
		REP #$20				; |
		LDA !OAM+$100 : STA !OAM+$000,y		; |
		LDA !OAM+$102 : STA !OAM+$002,y		; | smw compatibility moment
		SEP #$20				; |
		LDA #$F0 : STA !OAM+$101		; |
		TYA					; |
		LSR #2					; |
		TAY					; |
		LDA #$02				; |
		ORA $3350,x				; |
		STA !OAMhi+$00,y			;/
		LDY #$00
		JML $019F5A



	SPINJUMP_FIX:
		LDA #$00			; disable spin jump crush
		RTL


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




; physics map16 fix
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



incsrc "PhysicsPlus.asm"

Bank16:

incsrc "SpriteSubRoutines.asm"
incsrc "GFX_expand.asm"

print "Fe26 Sprite Engine ends at $", pc, "."

print "Sprite data inserted at $", pc, "."

incsrc "Replace/SP_spring_board.asm"
incsrc "Replace/SP_Koopa.asm"
incsrc "Replace/SP_Mole.asm"
incsrc "Replace/SP_GoldShroom.asm"
incsrc "Replace/SP_SpikeTop.asm"
incsrc "Replace/SP_Spiny.asm"
incsrc "Replace/SP_Coin.asm"
incsrc "Replace/SP_HammerPlat.asm"
incsrc "Replace/SP_SumoLightning.asm"
incsrc "Replace/SP_Swooper.asm"
incsrc "Replace/SP_Rip.asm"
incsrc "Replace/SP_BulletBill.asm"
incsrc "Replace/SP_Goomba.asm"
incsrc "Replace/SP_Key.asm"
incsrc "Replace/SP_Dino.asm"

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
%InsertSprite(Rex)
%InsertSprite(HammerRex)
%InsertSprite(AggroRex)
%InsertSprite(FlyingRex)
%InsertSprite(Conjurex)
%InsertSprite(Wizrex)
%InsertSprite(Projectile)
%InsertSprite(Chest)
%InsertSprite(EpicBlock)

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
%InsertSprite(AirshipDisplay)
%InsertSprite(SmokeyBoy)
%InsertSprite(LifeShroom)

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
%InsertSprite(MiniMech)
%InsertSprite(GigaThwomp)
%InsertSprite(BooHoo)
%InsertSprite(MoleWizard)
%InsertSprite(Lightning)
%InsertSprite(ShopObject)


BANK1AEnd:

print "Bank $1A ends at $", pc, ". ($", hex($1B0000-BANK1AEnd), " bytes left)"
print " "

