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
	dl Linear_Hammer
	dl Linear_PlantHead
	dl Linear_Bone
	dl Linear_Fireball8x8
	dl Linear_Fireball16x16
	dl Linear_LuigiFireball
	dl Linear_Goomba
	dl Linear_Baseball

	dl Mario_Expand
	dl Mario_Supplement
	dl Luigi
	dl Kadaal
	dl Leeway
	dl Leeway_Sword

	dl HappySlime
	dl AggroRex
	dl Wizrex
	dl TarCreeper_Hands
	dl TarCreeper_Body
	dl EliteKoopa
	dl NPC_Survivor
	dl NPC_Tinkerer
	dl NPC_Melody
	dl MiniMech

	dl CaptainWarrior
	dl CaptainWarrior_Axe
	dl Kingking
	dl LakituLovers
	dl LavaLord

	dl level06_night

	dl Sprite_BG_1



	%InsertFile(Linear_Hammer)
	incbin ExExGFX/Hammer.bin
	.End

	%InsertFile(Linear_PlantHead)
	incbin ExExGFX/PlantHead.bin
	.End

	%InsertFile(Linear_Bone)
	incbin ExExGFX/Bone.bin
	.End

	%InsertFile(Linear_Fireball8x8)
	incbin ExExGFX/Fireball8x8.bin
	.End

	%InsertFile(Linear_Fireball16x16)
	incbin ExExGFX/Fireball16x16.bin
	.End

	%InsertFile(Linear_LuigiFireball)
	incbin ExExGFX/LuigiFireball.bin
	.End

	%InsertFile(Linear_Goomba)
	incbin ExExGFX/Goomba.bin
	.End

	%InsertFile(Linear_Baseball)
	incbin ExExGFX/Baseball.bin
	.End

	%InsertFile(HappySlime)
	incbin Fe26/Sprites/SpriteGFX/HappySlime.bin
	.End


%BankEnd(30)
warnpc $318000
org $318000
%BankStart(31)

	%InsertFile(Kingking)
	incbin Fe26/Sprites/SpriteGFX/KingKing.bin
	.End

	%InsertFile(Mario_Expand)
	incbin ExExGFX/MarioExpand.bin
	.End

	%InsertFile(Sprite_BG_1)
	incbin ExExGFX/SBG.bin
	.End

	%InsertFile(Mario_Supplement)
	incbin PCE/GFX/MarioSupplement.bin
	.End

%BankEnd(31)
warnpc $328000
org $328008
%BankStart(32)

	%InsertFile(Kadaal)
	incbin PCE/GFX/Kadaal.bin
	.End

	%InsertFile(Wizrex)
	incbin Fe26/Sprites/SpriteGFX/Wizrex.bin
	.End

	%InsertFile(EliteKoopa)
	incbin Fe26/Sprites/SpriteGFX/EliteKoopa.bin
	.End

%BankEnd(32)
warnpc $338000
org $338000
%BankStart(33)

	%InsertFile(CaptainWarrior)
	incbin Fe26/Sprites/SpriteGFX/CaptainWarrior.bin
	.End

	%InsertFile(CaptainWarrior_Axe)
	incbin Fe26/Sprites/SpriteGFX/CaptainWarriorAxe.bin
	.End

%BankEnd(33)
warnpc $348000
org $348008
%BankStart(34)

	%InsertFile(Leeway_Sword)
	incbin PCE/GFX/LeewaysSword.bin
	.End

	%InsertFile(AggroRex)
	incbin Fe26/Sprites/SpriteGFX/AggroRex.bin
	.End

	%InsertFile(TarCreeper_Body)
	incbin Fe26/Sprites/SpriteGFX/TarCreeperBody.bin
	.End

	%InsertFile(TarCreeper_Hands)
	incbin Fe26/Sprites/SpriteGFX/TarCreeperHands.bin
	.End

%BankEnd(34)
warnpc $358000
org $358000
%BankStart(35)

	%InsertFile(Leeway)
	incbin PCE/GFX/Leeway.bin
	.End

%BankEnd(35)
warnpc $368000
org $368008
%BankStart(36)

	%InsertFile(MiniMech)
	incbin Fe26/Sprites/SpriteGFX/MiniMechBeta.bin
	.End

	%InsertFile(LavaLord)
	incbin Fe26/Sprites/SpriteGFX/LavaLord.bin
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
	dl SurvivorPortrait : db $05		; 06, Survivor
	dl TinkererPortrait : db $06		; 07, Tinkerer
	dl RallyPortrait : db $07		; 08, Rally
	dl RexPortrait : db $08			; 09, Rex
	dl CaptainWarriorPortrait : db $09	; 0A, Captain Warrior
	dl KingKingPortrait : db $0A		; 0B, KingKing

	.PalPtr
	dw .MarioPal		; 00
	dw .LuigiPal		; 01
	dw .KadaalPal		; 02
	dw .LeewayPal		; 03
	dw .AlterPal		; 04
	dw .SurvivorPal		; 05
	dw .TinkererPal		; 06
	dw .RallyPal		; 07
	dw .RexPal		; 08
	dw .CaptainWarriorPal	; 09
	dw .KingKingPal		; 0A

.MarioPal	dw $7FFF,$0000,$1084,$5EF7,$6F7B,$182D,$2875,$2C97
		dw $30BA,$34DD,$391F,$499F,$48C4,$4D66,$5228,$0000
		dw $0048,$04AB,$1117,$21BA,$365D,$4EFF,$5F5F,$0C14
		dw $0818,$041C,$001F,$0D1F,$1D9F

.LuigiPal	dw $7FFF,$0000,$0C63,$5294,$6B5A,$1100,$19C0,$2680
		dw $2F20,$3BC0,$3C07,$7CAE,$7DB4,$48C4,$4D66,$0000
		dw $5228,$0048,$008E,$0938,$1DBB,$367E,$4EFF,$679F
		dw $0580,$0241,$0302,$03C4,$13EB,$27F4

.KadaalPal	dw $7FFF,$0000,$0C65,$316A,$5272,$6316,$739B,$01C0
		dw $1A60,$32E0,$011F,$025F,$1ADF,$037F,$03FF,$0000
		dw $206A,$54AE,$7CD4,$477F,$0094,$001B,$00BC,$001F
		dw $011F,$019F

.LeewayPal	dw $7FFF,$0842,$10A6,$294A,$56B5,$6739,$77BD,$18E9
		dw $1D4D,$25B2,$2E36,$090B,$0133,$09B7,$163C,$0000
		dw $229F,$016F,$05F4,$0A98,$0F1C,$139F,$0EA0,$1708
		dw $0FAB,$0BEF,$03FA,$0FFF

.AlterPal

.SurvivorPal	dw $7FFF,$0000,$0C85,$5EB4,$6B38,$77BC,$0C36,$1439
		dw $1C3B,$205E,$285F,$391F,$4DBF,$011A,$017E,$0000
		dw $023F,$1954,$2E5B,$4B3F,$5F9F,$50C0,$5140,$5A20
		dw $3EC0,$2780,$2BE7

.TinkererPal	dw $7FFF,$0000,$0080,$05A4,$0645,$06A7,$0EE9,$134C
		dw $2393,$3BF8,$3057,$487F,$553F,$65FF,$00B8,$0000
		dw $013E,$023F,$0CEA,$1971,$2658,$32FF,$5B9F,$01F4
		dw $02B8,$033C,$03DF,$2BFF

.RallyPal	dw $7FFF,$0000,$0C65,$56B6,$6F7B,$033F,$03DF,$47FF
		dw $0077,$015D,$01FF,$02BF,$10EA,$1993,$2637,$0000
		dw $32BC,$46FD,$535F,$67BF,$66C5,$6BE8,$7BF9

.RexPal		dw $7FFF,$0000,$1842,$18C6,$5252,$62F7,$739C,$5044
		dw $60C8,$692B,$75AE,$7E52,$000A,$0C16,$00B8,$0000
		dw $141B,$013A,$01BD,$025F,$5C0E,$5815,$541B,$501F
		dw $595F,$5A3F

.CaptainWarriorPal
		dw $7FFF,$0000,$0C85,$18E8,$214B,$2DAE,$3A32,$4A95
		dw $52F8,$5F3B,$6B9F,$08AA,$0118,$017C,$01DF,$0000
		dw $127F,$01B6,$0638,$0E99,$12FB,$1B5D,$1FBF,$4467
		dw $54E6,$65A4,$7AA1,$7F68,$7FEA

.KingKingPal	dw $7FFF,$0000,$7F18,$7F9C,$602C,$74CE,$714F,$7992
		dw $7E32,$7EB5,$0100,$0241,$0780,$27E7,$0CBA,$0000
		dw $10DE,$015F,$01FF,$1299,$0B1D,$03BF,$47DF,$281E
		dw $741F

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


%BankEnd(37)
warnpc $388000
org $388008
%BankStart(38)

	%InsertFile(NPC_Survivor)
	incbin Fe26/Sprites/SpriteGFX/Survivor.bin
	.End

	%InsertFile(NPC_Tinkerer)
	incbin Fe26/Sprites/SpriteGFX/Tinkerer.bin
	.End

	%InsertFile(NPC_Melody)
	incbin Fe26/Sprites/SpriteGFX/Melody.bin
	.End

%BankEnd(38)
warnpc $398000
org $398000
%BankStart(39)

	%InsertFile(LakituLovers)
	incbin Fe26/Sprites/SpriteGFX/LakituLovers.bin
	.End


%BankEnd(39)
warnpc $3A8000
org $3A8008
%BankStart(3A)

	%InsertFile(Luigi)
	incbin PCE/GFX/Luigi.bin
	.End

%BankEnd(3A)
warnpc $3B8000
org $3B8000
%BankStart(3B)

	Temp3B:
	.End


%BankEnd(3B)
warnpc $3C8000
org $3C8008
%BankStart(3C)

	Temp3C:
	.End


%BankEnd(3C)
warnpc $3D8000
org $3D8000
%BankStart(3D)

	Temp3D:
	.End


%BankEnd(3D)
warnpc $3E8000
org $3E8008
%BankStart(3E)

	%InsertFile(level06_night)
	incbin HSLPalettes/level06_night.bin
	.End


%BankEnd(3E)
warnpc $3F8000
org $3F8000
%BankStart(3F)

macro storepal(name)
	.<name>
	incbin "SpritePalset/<name>.mw3":0-20
endmacro

macro altpal(basename, altsuffix, type)
	db ((.<basename>-PalsetData)/32),<type>
	incbin "SpritePalset/<basename>_<altsuffix>.mw3":2-20
endmacro


PalsetData:
	dl .Alt
	dw .Alt_End-.Alt

	%storepal(player_mario)			; 00
	%storepal(player_luigi)			; 01
	%storepal(player_kadaal)		; 02	
	%storepal(player_leeway)		; 03
	%storepal(placeholder1)			; 04, placeholder
	%storepal(placeholder2)			; 05, placeholder
	%storepal(placeholder3)			; 06, placeholder
	%storepal(placeholder4)			; 07, placeholder
	%storepal(placeholder5)			; 08, placeholder
	%storepal(placeholder6)			; 09, placeholder

	%storepal(default_A_yellow)		; 0A
	%storepal(default_B_blue)		; 0B
	%storepal(default_C_red)		; 0C
	%storepal(default_D_green)		; 0D

	%storepal(generic_grey)			; 0E
	%storepal(generic_ghost_blue)		; 0F
	%storepal(generic_lightblue)		; 10

	%storepal(special_wizrex)		; 11


.Alt
	; player alts
	%altpal(player_mario, dawn, 1)
	%altpal(player_luigi, dawn, 1)
	%altpal(player_kadaal, dawn, 1)
	%altpal(player_leeway, dawn, 1)
	%altpal(player_mario, dusk, 2)
	%altpal(player_luigi, dusk, 2)
	%altpal(player_kadaal, dusk, 2)
	%altpal(player_leeway, dusk, 2)
	%altpal(player_mario, night, 3)
	%altpal(player_luigi, night, 3)
	%altpal(player_kadaal, night, 3)
	%altpal(player_leeway, night, 3)
	%altpal(player_mario, lava, 4)
	%altpal(player_luigi, lava, 4)
	%altpal(player_kadaal, lava, 4)
	%altpal(player_leeway, lava, 4)
	%altpal(player_mario, water, 5)
	%altpal(player_luigi, water, 5)
	%altpal(player_kadaal, water, 5)
	%altpal(player_leeway, water, 5)

	; pal A alts
	%altpal(default_A_yellow, dawn, 1)
	%altpal(default_A_yellow, dusk, 2)
	%altpal(default_A_yellow, night, 3)
	%altpal(default_A_yellow, water, 5)

	; pal B alts
	%altpal(default_B_blue, dawn, 1)
	%altpal(default_B_blue, dusk, 2)
	%altpal(default_B_blue, night, 3)
	%altpal(default_B_blue, lava, 4)
	%altpal(default_B_blue, water, 5)

	; pal C alts
	%altpal(default_C_red, dawn, 1)
	%altpal(default_C_red, dusk, 2)
	%altpal(default_C_red, night, 3)
	%altpal(default_C_red, water, 5)

	; pal D alts
	%altpal(default_D_green, dawn, 1)
	%altpal(default_D_green, dusk, 2)
	%altpal(default_D_green, night, 3)
	%altpal(default_D_green, lava, 4)
	%altpal(default_D_green, water, 5)

	; grey alts
	%altpal(generic_grey, dawn, 1)
	%altpal(generic_grey, dusk, 2)
	%altpal(generic_grey, night, 3)
	%altpal(generic_grey, lava, 4)
	%altpal(generic_grey, water, 5)

	; ghost blue alts
	%altpal(generic_ghost_blue, night, 3)
	%altpal(generic_ghost_blue, lava, 4)
	%altpal(generic_ghost_blue, water, 5)

	; lightblue alts
	%altpal(generic_lightblue, dawn, 1)
	%altpal(generic_lightblue, dusk, 2)
	%altpal(generic_lightblue, night, 3)
	%altpal(generic_lightblue, lava, 4)
	%altpal(generic_lightblue, water, 5)

..End	; don't remove this label!

	print "Sprite palset data (", dec(..End-PalsetData), " bytes) stored at $", hex(PalsetData), "."


	Temp3F:
	.End


%BankEnd(3F)
warnpc $3FFFFF

%TotalSpace(!total)
print " "
















