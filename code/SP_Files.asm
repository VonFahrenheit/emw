header
sa1rom

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
print "Von Fahrenheit's manual file inserter v1.0"
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
print "Bank $30:"

	%InsertFile(Normal_Rex)
	incbin Fe26/Sprites/SpriteGFX/Rex.bin
	.End

	%InsertFile(Villager_Rex)
	incbin Fe26/Sprites/SpriteGFX/VillagerRex.bin
	.End

	%InsertFile(Hammer_Rex)
	incbin Fe26/Sprites/SpriteGFX/HammerRex.bin
	.End

	%InsertFile(Koopa_Renegade)
	incbin ExExGFX/Renegade.bin
	.End

	%InsertFile(Plant_Head)
	incbin Fe26/Sprites/SpriteGFX/PlantHead.bin
	.End

	%InsertFile(Thif)
	incbin Fe26/Sprites/SpriteGFX/Thif.bin
	.End

	%InsertFile(TerrainPlatform)
	incbin Fe26/Sprites/SpriteGFX/TerrainPlatform.bin
	.End

	%InsertFile(Novice_Shaman)
	incbin Fe26/Sprites/SpriteGFX/NoviceShaman.bin
	.End

	%InsertFile(Goomba_Slave)
	incbin Fe26/Sprites/SpriteGFX/GoombaSlave.bin
	.End

	%InsertFile(Happy_Slime)
	incbin Fe26/Sprites/SpriteGFX/HappySlime.bin
	.End

	%InsertFile(Mole_Wizard_And_Mini_Mole)
	incbin Fe26/Sprites/SpriteGFX/MagicMole.bin
	.End

	%InsertFile(Monkey)
	incbin Fe26/Sprites/SpriteGFX/Monkey.bin
	.End

	%InsertFile(SpriteYoshiCoin)
	incbin Fe26/Sprites/SpriteGFX/YoshiCoin.bin
	.End

print "$", hex($310000-.End), " bytes free at ", pc, "."
print " "
EndBank30:
warnpc $318000
org $318000
print "Bank $31:"

	%InsertFile(KingKing_KingOfTheRex)
	incbin Fe26/Sprites/SpriteGFX/KingKing.bin
	.End

	%InsertFile(Cannon_Prop)
	incbin ExExGFX/Cannon.bin
	.End


print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
print "!! $", hex($31DC00-.End), " BYTES FREE AT $", pc, " !!"
print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

org $31DC00

	%InsertFile(Sprite_BG_1)
	incbin ExExGFX/SBG.bin
	.End

	%InsertFile(ExSP4)
	incbin ExExGFX/ExSP4.bin
	.End

	%InsertFile(MarioTiles)
	incbin PCE/GFX/MarioSupplement.bin
	.End

print "$", hex($320000-.End), " bytes free at ", pc, "."
print " "
EndBank31:
warnpc $328000
org $328008
print "Bank $32:"

	%InsertFile(Kadaal_VengefulKoopa)
	incbin PCE/GFX/Kadaal.bin
	.End

	%InsertFile(Adept_Shaman)
	incbin Fe26/Sprites/SpriteGFX/AdeptShaman.bin
	.End

	%InsertFile(EliteKoopa)
	incbin Fe26/Sprites/SpriteGFX/EliteKoopa.bin
	.End

print "$", hex($330000-.End), " bytes free at ", pc, "."
print " "
EndBank32:
warnpc $338000
org $338000
print "Bank $33:"

	%InsertFile(CaptainWarrior)
	incbin Fe26/Sprites/SpriteGFX/CaptainWarrior.bin
	.End

	%InsertFile(CaptainWarrior_Axe)
	incbin Fe26/Sprites/SpriteGFX/CaptainWarriorAxe.bin
	.End

print "$", hex($340000-.End), " bytes free at ", pc, "."
print " "
EndBank33:
warnpc $348000
org $348008
print "Bank $34:"

	%InsertFile(LeewaysSword)
	incbin PCE/GFX/LeewaysSword.bin
	.End

	%InsertFile(AggroRex)
	incbin Fe26/Sprites/SpriteGFX/AggroRex.bin
	.End

	%InsertFile(TarCreeperBody)
	incbin Fe26/Sprites/SpriteGFX/TarCreeperBody.bin
	.End

	%InsertFile(TarCreeperHands)
	incbin Fe26/Sprites/SpriteGFX/TarCreeperHands.bin
	.End

print "$", hex($350000-.End), " bytes free at ", pc, "."
print " "
EndBank34:
warnpc $358000
org $358000
print "Bank $35:"

	%InsertFile(Leeway_GoldenRex)
	incbin PCE/GFX/Leeway.bin
	.End

print "$", hex($360000-.End), " bytes free at ", pc, "."
print " "
EndBank35:
warnpc $368000
org $368008
print "Bank $36:"

	%InsertFile(MiniMech)
	incbin Fe26/Sprites/SpriteGFX/MiniMechBeta.bin
	.End

print "$", hex($370000-.End), " bytes free at ", pc, "."
print " "
EndBank36:
warnpc $378000
org $378000
print "Bank $37:"

	%InsertFile(MarioPortrait)
	incbin ExExGFX/Portraits/MarioPortrait.bin
	.End
	%InsertFile(LuigiPortrait)
	incbin ExExGFX/Portraits/LuigiPortrait.bin
	.End
	%InsertFile(KadaalPortrait)
	incbin ExExGFX/Portraits/KadaalPortrait.bin
	.End
	%InsertFile(LeewayPortrait)
	incbin ExExGFX/Portraits/LeewayPortrait.bin
	.End
	%InsertFile(AlterPortrait)			; < Reserved for Alter
	incbin ExExGFX/Portraits/AlterPortrait.bin
	.End

	%InsertFile(SurvivorPortrait)
	incbin ExExGFX/Portraits/SurvivorPortrait.bin
	.End
	%InsertFile(TinkererPortrait)
	incbin ExExGFX/Portraits/TinkererPortrait.bin
	.End
	%InsertFile(RallyPortrait)
	incbin ExExGFX/Portraits/RallyPortrait.bin
	.End

	%InsertFile(RexPortrait)
	incbin ExExGFX/Portraits/RexPortrait.bin
	.End

	%InsertFile(CaptainWarriorPortrait)
	incbin ExExGFX/Portraits/CaptainWarriorPortrait.bin
	.End
	%InsertFile(KingKingPortrait)
	incbin ExExGFX/Portraits/KingKingPortrait.bin
	.End


print "$", hex($380000-.End), " bytes free at ", pc, "."
print " "
EndBank37:
warnpc $388000
org $388008
print "Bank $38:"

	%InsertFile(Survivor_NPC)
	incbin Fe26/Sprites/SpriteGFX/Survivor.bin
	.End

	%InsertFile(Tinkerer_NPC)
	incbin Fe26/Sprites/SpriteGFX/Tinkerer.bin
	.End

	%InsertFile(Melody_NPC)
	incbin Fe26/Sprites/SpriteGFX/Melody.bin
	.End

print "$", hex($390000-.End), " bytes free at ", pc, "."
print " "
EndBank38:
warnpc $398000
org $398000
print "Bank $39:"

	%InsertFile(LakituLovers)
	incbin Fe26/Sprites/SpriteGFX/LakituLovers.bin
	.End


print "$", hex($3A0000-.End), " bytes free at ", pc, "."
print " "
EndBank39:
warnpc $3A8000
org $3A8008
print "Bank $3A:"

	Temp3A:
	.End


print "$", hex($3B0000-.End), " bytes free at ", pc, "."
print " "
EndBank3A:
warnpc $3B8000
org $3B8000
print "Bank $3B:"

	Temp3B:
	.End


print "$", hex($3C0000-.End), " bytes free at ", pc, "."
print " "
EndBank3B:
warnpc $3C8000
org $3C8008
print "Bank $3C:"

	Temp3C:
	.End


print "$", hex($3D0000-.End), " bytes free at ", pc, "."
print " "
EndBank3C:
warnpc $3D8000
org $3D8000
print "Bank $3D:"

	Temp3D:
	.End


print "$", hex($3E0000-.End), " bytes free at ", pc, "."
print " "
EndBank3D:
warnpc $3E8000
org $3E8008
print "Bank $3E:"

	Temp3E:
	.End


print "$", hex($3F0000-.End), " bytes free at ", pc, "."
print " "
EndBank3E:
warnpc $3F8000
org $3F8000
print "Bank $3F:"

	Temp3F:
	.End


print "$", hex($3FFFFF-.End+1), " bytes free at ", pc, "."
print " "
EndBank3F:
warnpc $3FFFFF

%TotalSpace(!total)
print " "
















