header
sa1rom

; when adding files:
;	insert the file with the InsertFile macro
;	update the pointer table at FileList
;	update the defines (def_file macro in Defines.asm)
;
; when adding palsets:
;	insert the palset with the storepalset macro at PalsetData
;	update the defines (def_palset macro in Defines.asm)





	!bnk30		= $310000-EndBank30
	!bnk31		= $320000-EndBank31
	!bnk32		= $330000-EndBank32
	!bnk33		= $340000-EndBank33
	!bnk34		= $350000-EndBank34
	!bnk35		= $360000-EndBank35
	!bnk36		= $370000-EndBank36
	!bnk37		= $380000-EndBank37
	!bnk38		= $390000-EndBank38
	!bnk39		= $3A0000-EndBank39
	!bnk3A		= $3B0000-EndBank3A
	!bnk3B		= $3C0000-EndBank3B
	!bnk3C		= $3D0000-EndBank3C
	!bnk3D		= $3E0000-EndBank3D
	!bnk3E		= $3F0000-EndBank3E
	!bnk3F		= $400000-EndBank3F


	!half1		= !bnk30+!bnk31+!bnk32+!bnk33+!bnk34+!bnk35+!bnk36+!bnk37
	!half2		= !bnk38+!bnk39+!bnk3A+!bnk3B+!bnk3C+!bnk3D+!bnk3E+!bnk3F
	!total		= !half1+!half2


macro BigRATS(address)
org <address>
	db $53,$54,$41,$52
	dw $FFF7
	dw $0008
endmacro

macro BankStart(bank)
	Bank<bank>:
	print "Bank $<bank>:"
endmacro

macro BankEnd(bank)
	EndBank<bank>:
	print "$", hex(!bnk<bank>), " bytes (", dec((!bnk<bank>+512)/1024),  "KB) free at ", pc, "."
	print " "
endmacro

macro InsertFile(name)
	<name>:
	print "<name> (", dec((.End-<name>+512)/1024), "KB) inserted at $", pc, "."
endmacro

macro TotalSpace(bnk)
	print "Total space used: $", hex($7FFC0-(<bnk>)), "/$7FFC0 bytes (", dec((524224-(<bnk>))/1024), " kB)"
	print "Total space left: $", hex(<bnk>), "/$7FFC0 bytes (", dec((<bnk>)/1024), " kB)"
	print "Approximately ", dec(((524224*100)-((<bnk>)*100))/524224), "% of total space is used."
endmacro



; A big RATS should be able to protect two LoROM banks, since the pc file stores ROM in a packed format.
; For the SNES this means the first protected bank is essentially 0x7FF8 bytes but the second is the full 0x8000 bytes.

print " "
print "-- SP_FILES --"
print "Von Fahrenheit's manual file inserter v1.1"
print " "


		%BigRATS($308000)		;\
		%BigRATS($328000)		; |
		%BigRATS($348000)		; |
		%BigRATS($368000)		; | Reserve banks 30-3F
		%BigRATS($388000)		; |
		%BigRATS($3A8000)		; |
		%BigRATS($3C8000)		; |
		%BigRATS($3E8000)		;/


org $308008
%BankStart(30)

	SpriteSizeTable:
	; vanilla, extra bit 0
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 000-00F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 010-01F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 020-02F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 030-03F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 040-04F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 050-05F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 060-06F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 070-07F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 080-08F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 090-09F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0A0-0AF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0B0-0BF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0C0-0CF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0D0-0DF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0E0-0EF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0F0-0FF
	; vanilla, extra bit 1
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 000-00F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 010-01F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 020-02F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 030-03F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 040-04F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 050-05F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 060-06F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 070-07F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 080-08F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 090-09F
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0A0-0AF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0B0-0BF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0C0-0CF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0D0-0DF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0E0-0EF
	db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03	; 0F0-0FF
	; custom, extra bit 0
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 100-10F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 110-11F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 120-12F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 130-13F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 140-14F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 150-15F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 160-16F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 170-17F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 180-18F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 190-19F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1A0-1AF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1B0-1BF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1C0-1CF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1D0-1DF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1E0-1EF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1F0-1FF
	; custom, extra bit 1
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 100-10F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 110-11F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 120-12F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 130-13F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 140-14F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 150-15F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 160-16F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 170-17F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 180-18F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 190-19F
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1A0-1AF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1B0-1BF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1C0-1CF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1D0-1DF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1E0-1EF
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05	; 1F0-1FF


	FileList:
	dl Mario
	dl Luigi
	dl Kadaal
	dl Leeway
	dl Leeway_Sword

	dl DynamicVanilla
	dl HappySlime
	dl AggroRex
	dl Wizrex
	dl TarCreeper_Body
	dl EliteKoopa
	dl NPC_Survivor
	dl NPC_Tinkerer
	dl NPC_OldYoshi
	dl NPC_Melody
	dl NPC_Toad
	dl MiniMech

	dl CaptainWarrior
	dl CaptainWarrior_Axe
	dl Kingking
	dl KingkingDeath
	dl LakituLovers
	dl LavaLord

	dl level06_night

	dl default_font
	dl classic_font
	dl default_border

	dl Sprite_BG_1



	dl Overworld_GFX
	dl Overworld_Anim



	%InsertFile(DynamicVanilla)
	incbin ../RawGraphics/DynamicSprites/DynamicVanilla.bin
	.End

	%InsertFile(HappySlime)
	incbin ../RawGraphics/DynamicSprites/HappySlime.bin
	.End


%BankEnd(30)
warnpc $318000
org $318000
%BankStart(31)

	%InsertFile(Kingking)
	incbin ../RawGraphics/DynamicSprites/KingKing.bin
	.End
	%InsertFile(KingkingDeath)
	incbin ../RawGraphics/RealTimeLinear/KingkingDeath.bin
	.End

	%InsertFile(Sprite_BG_1)
	incbin ../RawGraphics/SpriteBG/Sprite_BG_1.bin
	.End

%BankEnd(31)
warnpc $328000
org $328008
%BankStart(32)

	%InsertFile(Kadaal)
	incbin ../RawGraphics/PlayerGFX/Kadaal.bin
	.End

	%InsertFile(Wizrex)
	incbin ../RawGraphics/DynamicSprites/Wizrex.bin
	.End

	%InsertFile(EliteKoopa)
	incbin ../RawGraphics/DynamicSprites/EliteKoopa.bin
	.End

%BankEnd(32)
warnpc $338000
org $338000
%BankStart(33)

	%InsertFile(CaptainWarrior)
	incbin ../RawGraphics/DynamicSprites/CaptainWarrior.bin
	.End

	%InsertFile(CaptainWarrior_Axe)
	incbin ../RawGraphics/DynamicSprites/CaptainWarriorAxe.bin
	.End

%BankEnd(33)
warnpc $348000
org $348008
%BankStart(34)

	%InsertFile(Leeway_Sword)
	incbin ../RawGraphics/PlayerGFX/LeewaysSword.bin
	.End

	%InsertFile(AggroRex)
	incbin ../RawGraphics/DynamicSprites/AggroRex.bin
	.End

	%InsertFile(TarCreeper_Body)
	incbin ../RawGraphics/DynamicSprites/TarCreeperBody.bin
	.End

%BankEnd(34)
warnpc $358000
org $358000
%BankStart(35)

	%InsertFile(Leeway)
	incbin ../RawGraphics/PlayerGFX/Leeway.bin
	.End

%BankEnd(35)
warnpc $368000
org $368008
%BankStart(36)

	%InsertFile(MiniMech)
	incbin ../RawGraphics/DynamicSprites/MiniMechBeta.bin
	.End

	%InsertFile(LavaLord)
	incbin ../RawGraphics/DynamicSprites/LavaLord.bin
	.End

	%InsertFile(NPC_Toad)
	incbin ../RawGraphics/DynamicSprites/Toad.bin
	.End

%BankEnd(36)
warnpc $378000
org $378000
%BankStart(37)

	PortraitData:
	dw .PalPtr		; < This is probably necessary to access the palettes smoothly

	dl MarioPortrait : db $00		; 01, Mario
	dl LuigiPortrait : db $01		; 02, Luigi
	dl KadaalPortrait : db $02		; 03, Kadaal
	dl LeewayPortrait : db $03		; 04, Leeway
	dl AlterPortrait : db $04		; 05, Alter
	dl PeachPortrait : db $05		; 06, Peach
	dl SurvivorPortrait : db $06		; 07, Survivor
	dl TinkererPortrait : db $07		; 08, Tinkerer
	dl RallyoshiPortrait : db $08		; 09, Rallyoshi
	dl RexPortrait : db $09			; 0A, Rex
	dl CaptainWarriorPortrait : db $0A	; 0B, Captain Warrior
	dl KingKingPortrait : db $0B		; 0C, KingKing

	.PalPtr
	dw .MarioPal		; 00
	dw .LuigiPal		; 01
	dw .KadaalPal		; 02
	dw .LeewayPal		; 03
	dw .AlterPal		; 04
	dw .PeachPal		; 05
	dw .SurvivorPal		; 06
	dw .TinkererPal		; 07
	dw .RallyoshiPal	; 08
	dw .RexPal		; 09
	dw .CaptainWarriorPal	; 0A
	dw .KingKingPal		; 0B

	.MarioPal
		incbin ../PaletteData/portraits/MarioPortrait.mw3
	.LuigiPal
		incbin ../PaletteData/portraits/LuigiPortrait.mw3
	.KadaalPal
		incbin ../PaletteData/portraits/KadaalPortrait.mw3
	.LeewayPal
		incbin ../PaletteData/portraits/LeewayPortrait.mw3
	.AlterPal
	.PeachPal
	.SurvivorPal
		incbin ../PaletteData/portraits/SurvivorPortrait.mw3
	.TinkererPal
		incbin ../PaletteData/portraits/TinkererPortrait.mw3
	.RallyoshiPal
		incbin ../PaletteData/portraits/RallyoshiPortrait.mw3
	.RexPal
		incbin ../PaletteData/portraits/RexPortrait.mw3
	.CaptainWarriorPal
		incbin ../PaletteData/portraits/CaptainWarriorPortrait.mw3
	.KingKingPal
		incbin ../PaletteData/portraits/KingKingPortrait.mw3

	%InsertFile(MarioPortrait)
	incbin ../RawGraphics/Portraits/MarioPortrait.bin
	.End
	%InsertFile(LuigiPortrait)
	incbin ../RawGraphics/Portraits/LuigiPortrait.bin
	.End
	%InsertFile(KadaalPortrait)
	incbin ../RawGraphics/Portraits/KadaalPortrait.bin
	.End
	%InsertFile(LeewayPortrait)
	incbin ../RawGraphics/Portraits/LeewayPortrait.bin
	.End
	%InsertFile(AlterPortrait)			; < reserved for Alter
	incbin ../RawGraphics/Portraits/MarioPortrait.bin
	.End
	%InsertFile(PeachPortrait)			; < reserved for peach
	incbin ../RawGraphics/Portraits/MarioPortrait.bin
	.End

	%InsertFile(SurvivorPortrait)
	incbin ../RawGraphics/Portraits/SurvivorPortrait.bin
	.End
	%InsertFile(TinkererPortrait)
	incbin ../RawGraphics/Portraits/TinkererPortrait.bin
	.End
	%InsertFile(RallyoshiPortrait)
	incbin ../RawGraphics/Portraits/RallyoshiPortrait.bin
	.End

	%InsertFile(RexPortrait)
	incbin ../RawGraphics/Portraits/RexPortrait.bin
	.End

	%InsertFile(CaptainWarriorPortrait)
	incbin ../RawGraphics/Portraits/CaptainWarriorPortrait.bin
	.End
	%InsertFile(KingKingPortrait)
	incbin ../RawGraphics/Portraits/KingKingPortrait.bin
	.End


%BankEnd(37)
warnpc $388000
org $388008
%BankStart(38)

	%InsertFile(NPC_Survivor)
	incbin ../RawGraphics/DynamicSprites/Survivor.bin
	.End

	%InsertFile(NPC_Tinkerer)
	incbin ../RawGraphics/DynamicSprites/Tinkerer.bin
	.End

	%InsertFile(NPC_OldYoshi)
	incbin ../RawGraphics/DynamicSprites/OldYoshi.bin
	.End

	%InsertFile(NPC_Melody)
	incbin ../RawGraphics/DynamicSprites/Melody.bin
	.End

%BankEnd(38)
warnpc $398000
org $398000
%BankStart(39)

	%InsertFile(LakituLovers)
	incbin ../RawGraphics/DynamicSprites/LakituLovers.bin
	.End


%BankEnd(39)
warnpc $3A8000
org $3A8008
%BankStart(3A)

	%InsertFile(Luigi)
	incbin ../RawGraphics/PlayerGFX/Luigi.bin
	.End

%BankEnd(3A)
warnpc $3B8000
org $3B8000
%BankStart(3B)

	%InsertFile(default_font)
	incbin ../RawGraphics/TextBox/DefaultFont.bin
	.End

	%InsertFile(classic_font)
	incbin ../RawGraphics/TextBox/ClassicFont.bin
	.End

	%InsertFile(default_border)
	incbin ../RawGraphics/TextBox/DefaultBorder.bin
	.End

%BankEnd(3B)
warnpc $3C8000
org $3C8008
%BankStart(3C)

	%InsertFile(Mario)
	incbin ../RawGraphics/PlayerGFX/Mario.bin
	.End


%BankEnd(3C)
warnpc $3D8000
org $3D8000
%BankStart(3D)

	%InsertFile(Overworld_GFX)
	incbin ../RawGraphics/Overworld/gfx.bin
	.End


%BankEnd(3D)
warnpc $3E8000
org $3E8008
%BankStart(3E)

	%InsertFile(level06_night)
	incbin ../PaletteData/HSL/level06_night.bin
	.End

	%InsertFile(Overworld_Anim)
	incbin ../RawGraphics/Overworld/realm1_anim.bin
	.End


%BankEnd(3E)
warnpc $3F8000
org $3F8000
%BankStart(3F)

macro storepal(name)
	.<name>
	incbin "../PaletteData/SpritePalset/<name>.mw3":0-20
endmacro

PalsetData:
	%storepal(player_mario)			; 00, mario palette
	%storepal(player_luigi)			; 01, luigi palette
	%storepal(player_kadaal)		; 02, kadaal palette
	%storepal(player_leeway)		; 03, leeway palette
	%storepal(player_alter)			; 04, alter palette
	%storepal(player_peach)			; 05, peach palette
	%storepal(placeholder3)			; 06, placeholder
	%storepal(placeholder4)			; 07, placeholder
	%storepal(placeholder5)			; 08, placeholder
	%storepal(player_mario_fire)		; 09, mario's fire power palette

	%storepal(default_A_yellow)		; 0A
	%storepal(default_B_blue)		; 0B
	%storepal(default_C_red)		; 0C
	%storepal(default_D_green)		; 0D

	%storepal(generic_grey)			; 0E
	%storepal(generic_ghost_blue)		; 0F
	%storepal(generic_lightblue)		; 10

	%storepal(special_wizrex)		; 11

	%storepal(special_flash_white)		; 12
	%storepal(special_flash_black)		; 13
	%storepal(special_flash_red)		; 14
	%storepal(special_flash_green)		; 15
	%storepal(special_flash_blue)		; 16
	%storepal(special_flash_yellow)		; 17
	%storepal(special_flash_caster)		; 18

	%storepal(special_kingking_blue)
	%storepal(special_kingking_red)

	%storepal(special_toad)
	%storepal(special_melody)



.End	; don't remove this label!

	print "Sprite palset data (", dec(.End-PalsetData), " bytes) stored at $", hex(PalsetData), "."


	Temp3F:
	.End


%BankEnd(3F)
warnpc $3FFFFF

%TotalSpace(!total)
print " "
















