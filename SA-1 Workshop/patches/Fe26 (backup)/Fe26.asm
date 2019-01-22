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




	; -- Main Hijacks --

	org $018172
		JSL Init
		NOP

	org $0185C3
		JSL Main
		NOP

	org $01D43E				; This is called later
		JSR $8133			; Handle status
		RTL

	org $02A963
		JSL Load
		NOP

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
		db $0F				; > Highest sprite slot

	org $02A9C9
		JSL KeepExtraBits		; DON'T autoclean this!


	; -- Sprite Fixes --

	; Goal Tape fix
	org $01C089
		LDA !ExtraBits,x
		NOP #4
		STA $34A0,x

	org $02A9A6
		JSL SilverCoinFix
		NOP




	; -- Custom Code --

	org $168000		; Bank already claimed because of PCE
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
		SEP #$10
		JSL !InitSpriteTables
		REP #$10
		PLY
		PLX
		PLA
		STA !ExtraBits,x
		RTL



incsrc "SpriteSubRoutines.asm"
incsrc "SpriteData.asm"
incsrc "GFX_expand.asm"

incsrc "Replace/SP_spring_board.asm"
incsrc "Replace/SP_Koopa.asm"
incsrc "Replace/SP_Mole.asm"
incsrc "Replace/SP_RainbowShroom.asm"

incsrc "Sprites/HappySlime.asm"
incsrc "Sprites/GoombaSlave.asm"
incsrc "Sprites/RexCode.asm"
incsrc "Sprites/Projectile.asm"
incsrc "Sprites/CaptainWarrior.asm"
incsrc "Sprites/TarCreeper.asm"
incsrc "Sprites/MiniMech.asm"
incsrc "Sprites/MoleWizard.asm"
incsrc "Sprites/MiniMole.asm"




print "Fe26 Sprite Engine ends at $", pc, "."


org $178000
db $53,$54,$41,$52
dw $FFF7
dw $0008






