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


;
; So... what do I gotta do with this thing?
; I honestly don't care for generators and shooters, those are better put in LevelCode anyway.
; But I need more sprite number slots. 256 new ones should do, easily.
; I need:
;	- Load sprite hijack
;	- Custom tweaker/hitbox list
;	- Init sprite hijack
;	- Main sprite hijack
;	- Kill sprite hijack (table reset)
;	- Custom sprite list
;	- Handle status


	; -- Defines --

	incsrc "Defines.asm"

		!ExtraBits		= $3590 ; extra bits of sprite
		!NewCodeFlag		= $3140 ; flag indicating whether current sprite uses custom code
		!ExtraProp1		= $35A0 ;
		!ExtraProp2		= $35B0 ;
		!NewSpriteNum		= $35C0 ; custom sprite number
					; $35F0 ; P2 interaction disable timer

		!CustomBit		= $08



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

	org $01907A
		JML DeathFix			;\ Source: STA $AE,x : LDA $33A0,x
		NOP				;/


	org $01D43E				; This is called later
		JSR $8133			; Handle status
		RTL


	org $02A940
	;	JML Load		; overwrites LSR A : BCC $18 ($02A95B) : LDA [$CE],y
	;	NOP

	org $02A963
		JSL Load
		NOP
	;	AND #$0D
	;	STA $3240,x



	org $02A94B
		JSL Load_2
		NOP

	org $07F785
		JSL Erase
		NOP

	org $018151
		JSL Erase_2
		NOP

	org $0187A7
		JML SetSpriteTables		; This can be JSL'd to reset tables

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


	; -- Sprite Fixes --

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


	; Goal Tape fix
	org $01C089
		LDA !ExtraBits,x
		NOP #4
		STA $34A0,x

	; Silver Coin fix
	org $02A9A6
		JSL SilverCoinFix
		NOP

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


	; -- Custom Code --

	org $168000
print " "
print "Fe26 sprite engine starts at $", pc, "."


	Init:
		LDA #$08
		STA $3230,x
		LDA !ExtraBits,x
		AND #!CustomBit
		BNE .Custom

		.Return
		RTL

		.Custom
		JSL SetSpriteTables
		LDA !NewCodeFlag
		BEQ .Return
		PLA : PLA
		PEA $85C2-1
		LDA #$01
		JML [$3000]


	Main:
		STZ $7491
		LDA !ExtraBits,x
		AND #!CustomBit
		BNE .Custom
		LDA ($D8)
		RTL

		.Custom
		LDA !NewSpriteNum,x
		JSR GetMainPtr
		PLA
		PLA
		PEA $85C2-1
		LDA $3230,x
		JML [$3000]


	Load:

	;	LSR A : BCS .Vert
	;	LDA [$CE],y
	;	AND #$0D : STA !ExtraBits,x
	;	LDA $05 : STA !NewSpriteNum,x
	;	JML $02A95B

	;	.Vert
	;	LDA [$CE],y
	;	JML $02A945



		PHA
		AND #$0D
		STA !ExtraBits,x
		AND #$01
		STA $3240,x
		LDA $05
		STA !NewSpriteNum,x
		PLA
		RTL

		.2
		PHA
		AND #$0D
		STA !ExtraBits,x
		AND #$01
		STA $3250,x
		LDA $05
		STA !NewSpriteNum,x
		PLA
		RTL


	Erase:

	LDA $3200,x
	CMP #$36
	BEQ +
	LDA !ExtraBits,x
	AND #!CustomBit^$FF
	STA !ExtraBits,x
	+

		STZ $3290,x				; Clear this reg too
		STZ $3360,x
		LDA #$01 : STA $3350,x
		DEC A
		STZ $34E0,x : STZ $34F0,x		;\
		STZ $3500,x : STZ $3510,x		; |
		STZ $3520,x : STZ $3530,x		; |
		STZ $3540,x : STZ $3550,x		; | Clear Physics+/Fe26 data
		STZ $3560,x : STZ $3570,x		; |
		STZ $3580,x 				; |
		STZ $35A0,x : STZ $35B0,x		; |
		STZ $35D0,x				; |
		STZ $35E0,x : STZ $35F0,x		;/
		RTL

		.2

	LDA $3200,x
	CMP #$36
	BEQ +
	LDA !ExtraBits,x
	AND #!CustomBit^$FF
	STA !ExtraBits,x
	+

		STZ $3290,x				; Clear this reg too
		LDA #$FF : STA $33F0,x
		INC A
		STZ $34E0,x : STZ $34F0,x		;\
		STZ $3500,x : STZ $3510,x		; |
		STZ $3520,x : STZ $3530,x		; |
		STZ $3540,x : STZ $3550,x		; | Clear Physics+/Fe26 data
		STZ $3560,x : STZ $3570,x		; |
		STZ $3580,x 				; |
		STZ $35A0,x : STZ $35B0,x		; |
		STZ $35D0,x				; |
		STZ $35E0,x : STZ $35F0,x		;/
		RTL


	GetMainPtr:
		PHB : PHK : PLB
		PHP
		REP #$30
		LDA !NewSpriteNum,x
		AND #$00FF
		ASL #4
		TAY

		LDA SpriteData+$0B,y
		STA $00
		LDA SpriteData+$0C,y
		STA $01

		PLP
		PLB
		RTS


	SetSpriteTables:
		PHY
		PHB : PHK : PLB
		PHP
		LDA !NewSpriteNum,x
		REP #$30
		AND #$00FF
		ASL #4
		TAY
		SEP #$20
		LDA SpriteData+$00,y
		STA !NewCodeFlag
		LDA SpriteData+$01,y
		STA $3200,x
		LDA SpriteData+$02,y
		STA $3440,x
		LDA SpriteData+$03,y
		STA $3450,x
		LDA SpriteData+$04,y
		STA $3460,x
		AND #$0F
		STA $33C0,x
		LDA SpriteData+$05,y
		STA $3470,x
		LDA SpriteData+$06,y
		STA $3480,x
		LDA SpriteData+$07,y
		STA $34B0,x
		LDA !NewCodeFlag
		BNE .Custom
		PLP
		PLB
		PLY
		LDA #$00
		STA !ExtraBits,x
		RTL

		.Custom
		REP #$20
		LDA SpriteData+$08,y
		STA $00
		SEP #$20
		LDA SpriteData+$0A,y
		STA $02
		LDA SpriteData+$0E,y
		STA !ExtraProp1,x
		LDA SpriteData+$0F,y
		STA !ExtraProp2,x
		PLP
		PLB
		PLY
		RTL


	HandleStatus:
		LDA $35F0,x			;\ Decrement P2 interaction disable timer
		BEQ $03 : DEC $35F0,x		;/
		LDA $34E0,x			;\ Decrement stasis timer
		BEQ $03 : DEC $34E0,x		;/
		LDA $3230,x
		CMP #$02
		BCC .CallDefault
		CMP #$08
		BNE .NoMainRoutine
		JML $0185C3

		.NoMainRoutine
		PHA
		LDA !ExtraBits,x
		AND #!CustomBit
		BNE .Custom
		PLA

		.CallDefault
		JML $018133

		.Custom
		LDA !ExtraProp2,x
		BMI .CallMain
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
		PHP
		REP #$30
		AND #$00FF
		ASL #4
		TAX
		LDA.l SpriteData+$07,x
		PLP
		RTL


	KeepExtraBits:
		LDA !ExtraBits,x
		PHA
		PHX
		PHY
		PHP
		SEP #$10
		JSL !InitSpriteTables
		PLP
		PLY
		PLX
		PLA
		STA !ExtraBits,x
		RTL


	DeathFix:
		STA $AE,x
		LDA $3230,x
		CMP #$02 : BEQ .019085
		LDA $33A0,x : BNE .019085
	.019081	JML $019081
	.019085	JML $019085


	CarriedItemFix:
		LDA !ExtraBits,x
		AND #!CustomBit : BNE .Return
		JML $019806

		.Return
		JML $01A1CF





incsrc "PhysicsPlus.asm"
incsrc "MalleableExtendedSprite.asm"


Bank16:

incsrc "SpriteSubRoutines.asm"
incsrc "GFX_expand.asm"

print "Fe26 Sprite Engine ends at $", pc, "."

print "Sprite data inserted at $", pc, "."
print " "
print "-- SPRITE LIST --"

incsrc "SpriteData.asm"
incsrc "Replace/SP_spring_board.asm"
incsrc "Replace/SP_Koopa.asm"
incsrc "Replace/SP_Mole.asm"
incsrc "Replace/SP_RainbowShroom.asm"
incsrc "Replace/SP_SpikeTop.asm"
incsrc "Replace/SP_Spiny.asm"
incsrc "Replace/SP_Coin.asm"
incsrc "Replace/SP_HammerPlat.asm"

macro InsertSprite(name)
	START_<name>:
	incsrc "Sprites/<name>.asm"
	END_<name>:
	print "<name> inserted at $", hex(START_<name>), " ($", hex(END_<name>-START_<name>), " bytes)."
endmacro


print " "
print "-- BANK $16 --"
%InsertSprite(HappySlime)
%InsertSprite(GoombaSlave)
%InsertSprite(RexCode)
%InsertSprite(Projectile)
%InsertSprite(CaptainWarrior)
%InsertSprite(TarCreeper)
%InsertSprite(MiniMech)

.End

print "Bank $16 ends at $", pc, ". ($", hex($170000-.End), " bytes left)"


org $178000
db $53,$54,$41,$52
dw $FFF7
dw $0008

Bank17:

print " "
print "-- BANK $17 --"
%InsertSprite(PlantHead)
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
		CMP $73D7			; address added by Lunar Magic 3
		SEP #$20
		BCS ..LimitDown
		XBA
		BRA ..Return

		..LimitDown
		LDA $73D7
		SEC : SBC #$10
		STA $00
		STA $0C
		LDA $73D7+1
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
		JML $0194F2		; within bounds



BANK17End:

print "Bank $17 ends at $", pc, ". ($", hex($180000-BANK17End), " bytes left)"


org $198000
db $53,$54,$41,$52
dw $FFF7
dw $0008

Bank19:

print " "
print "-- BANK $19 --"
%InsertSprite(LavaLord)
%InsertSprite(FlamePillar)




BANK19End:

print "Bank $19 ends at $", pc, ". ($", hex($1A0000-BANK19End), " bytes left)"
print " "

