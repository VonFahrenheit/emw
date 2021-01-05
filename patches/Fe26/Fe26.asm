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


incsrc "SpriteData.asm"


	Init:
		LDA !GameMode
		CMP #$14 : BEQ $03 : JMP .Return	; don't run until level has started!!
		LDA #$08 : STA $3230,x			; set status to MAIN
		LDA !ExtraBits,x
		AND #!CustomBit : BEQ .Vanilla

		.Custom
		JSL SetSpriteTables
		PLA : PLA
		PEA $85C2-1
		LDA #$01
		JML [$3000]

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
		LDA !NewSpriteNum,x
		JSR GetMainPtr
		PLA
		PLA
		PEA $85C2-1
		LDA $3230,x
		JML [$3000]



	NextSprite:
		DEY			;\
		LDA [$CE],y		; | check custom bit
		INY			; |
		AND #$08 : BEQ +	;/
		INY #4			;\ custom sprites are 5 bytes
		BRA ++			;/

	+	INY #2			; vanilla sprites are 3 bytes
	++	INX			; next sprite in level
		JML $02A82E		; return to loop



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
		JSR .GetExpansionBytes
		PLA : PHA
		AND #$01
		STA $3240,x
		LDA $05 : STA !NewSpriteNum,x
		PLA
		RTL

		.2
		PHA
		AND #$0D
		STA !ExtraBits,x
		JSR .GetExpansionBytes
		PLA : PHA
		AND #$01
		STA $3250,x
		LDA $05 : STA !NewSpriteNum,x
		PLA
		RTL

	.GetExpansionBytes
		LSR #2
		CMP #$02 : BCC +
		XBA
		LDA $05
		BRA ++
	+	XBA
		LDA $3200,x
	++	PHX
		PHP
		REP #$30
		TAX
		LDA $308008,x
		PLP
		PLX
		CMP #$03 : BEQ +
		PHY
		INY #3
		LDA [$CE],y : STA !ExtraProp1,x
		INY
		LDA [$CE],y
		AND #$3F
		STA !ExtraProp2,x
		PLY
	+	RTS


	LoadLoopFix:
		PLA					;\ clear garbage bytes (probably from a JSR)
		PLA					;/
		INX					; increment sprite index to level
		PHY					;\
		SEP #$10				; | this really just clears the high byte of X
		REP #$10				;/
		DEY #3					; > free because Y is on the stack
		LDA [$CE],y				; check first byte of sprite data
		PLY					; restore Y
		AND #$08 : BEQ .Size3
	.Size5
		INY #2
	.Size3
		JML $02A82E				; back to main sprite load loop


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
		STZ $35D0,x				; |
		STZ $35E0,x : STZ $35F0,x		;/
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
		PHB : PHK : PLB
		PHY
		PHP
		LDA !NewSpriteNum,x
		STZ $2250			;\
		REP #$30			; |
		AND #$00FF			; |
		STA $2251			; | index = sprite num * 14
		LDA #$000E : STA $2253		; |
		NOP : BRA $00			; |
		LDY $2306			;/
		SEP #$20
		LDA SpriteData+$00,y : STA $3200,x
		LDA SpriteData+$01,y : STA $3440,x
		LDA SpriteData+$02,y : STA $3450,x
		LDA SpriteData+$03,y : STA $3460,x
		AND #$0E : STA $33C0,x
		LDA SpriteData+$04,y
		STA $3470,x : LDA SpriteData+$05,y
		STA $3480,x : LDA SpriteData+$06,y
		STA $34B0,x
		REP #$20
		LDA SpriteData+$07,y : STA $00
		SEP #$20
		LDA SpriteData+$09,y : STA $02
		LDA !ExtraProp2,x
		AND #$3F
		STA !ExtraProp2,x
		LDA SpriteData+$0D,y
		AND #$C0
		ORA !ExtraProp2,x
		STA !ExtraProp2,x
		PLP
		PLY
		PLB
		RTL


	HandleStatus:

		SEP #$20
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


		LDA $35F0,x			;\ Decrement P2 interaction disable timer
		BEQ $03 : DEC $35F0,x		;/
		LDA $34E0,x			;\ Decrement stasis timer
		BEQ $03 : DEC $34E0,x		;/
		JSR UpdateTile			; update VR3 tile claim
		LDA $3230,x
		CMP #$02 : BCC .CallDefault
		CMP #$08 : BNE .NoMainRoutine
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


	; this code runs at the end of each sprite loop
	SpritesDone:
		PHP
		REP #$20
		LDA !DizzyEffect
		AND #$00FF : BEQ +
		LDA !CameraBackupY : STA $1C		; restore camera
	+	PLP
		STZ $787A
		STZ $788B
		RTL


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
%InsertSprite(CaptainWarrior)

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


BANK1AEnd:

print "Bank $1A ends at $", pc, ". ($", hex($1B0000-BANK1AEnd), " bytes left)"
print " "

