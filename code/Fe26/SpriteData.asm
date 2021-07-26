; Each sprite type has 16 bytes, the format is as follows:
; $00 - Sprite number		($3200)
; $01 - Tweaker 1		($3440)
; $02 - Tweaker 2		($3450)
; $03 - Tweaker 3		($3460 + $33C0, palette)
; $04 - Tweaker 4		($3470)
; $05 - Tweaker 5		($3480)
; $06 - Tweaker 6		($34B0)
; $07 - 24-bit INIT pointer
; $0A - 24-bit MAIN pointer
; $0D - highest 2 bits of extra prop 2	($35B0)

!temp_sprite_list = 0



; set highest bit of p2 to have MAIN run during special states
; set second highest bit of p2 to run normal special state codes
; for the purposes of this, any sprite state other than 0x01 or 0x08 is considered special
; MAIN refers to the custom sprite's code
; highest 2 bits of p2 are always set by this table, but the other 6 bits can be set by LM for use as normal

macro AddToList0toF(name, p2)

	dl <name>_INIT
	dl <name>_MAIN
	db <p2>
	print "Sprite $0", hex(((?temp-SpriteData)/14)-1), ": <name>"

	?temp:

endmacro

macro AddToList(name, p2)

	dl <name>_INIT
	dl <name>_MAIN
	db <p2>
	print "Sprite $", hex(((?temp-SpriteData)/14)-1), ": <name>"

	?temp:

endmacro


SpriteData:

; -- Sprite 00 --
db $36
db $10,$00,$4A,$A1,$08,$00
%AddToList0toF(HappySlime, $00)

; -- Sprite 01 --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList0toF(GoombaSlave, $00)

; -- Sprite 02 --
db $36
db $10,$2A,$46,$A1,$00,$00
%AddToList0toF(Rex, $00)

; -- Sprite 03 --
db $36
db $10,$2A,$4A,$A1,$00,$00
%AddToList0toF(HammerRex, $00)

; -- Sprite 04 --
db $36
db $10,$27,$59,$A1,$11,$04
%AddToList0toF(AggroRex, $00)

; -- Sprite 05 --
db $36
db $10,$2A,$4A,$A1,$10,$00
%AddToList0toF(Conjurex, $00)

; -- Sprite 06 --
db $36
db $00,$27,$59,$A5,$11,$04
%AddToList0toF(Wizrex, $00)

; -- Sprite 07 --
db $36
db $00,$00,$30,$A2,$31,$46
%AddToList0toF(Projectile, $00)

; -- Sprite 08 --
db $36
db $00,$00,$59,$A1,$11,$04
%AddToList0toF(CaptainWarrior, $00)

; -- Sprite 09 --
db $36
db $00,$00,$57,$A5,$00,$00
%AddToList0toF(TarCreeper, $00)

; -- Sprite 0A --
db $36
db $00,$00,$57,$A1,$00,$00
%AddToList0toF(MiniMech, $00)

; -- Sprite 0B --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList0toF(MoleWizard, $00)

; -- Sprite 0C --
db $36
db $00,$00,$48,$A1,$00,$04
%AddToList0toF(MiniMole, $00)

; -- Sprite 0D --
db $36
db $00,$00,$38,$A6,$39,$46
%AddToList0toF(PlantHead, $00)

; -- Sprite 0E --
db $36
db $00,$00,$30,$A6,$39,$46
%AddToList0toF(NPC, $00)

; -- Sprite 0F --
db $36
db $00,$22,$34,$BE,$B9,$46
%AddToList0toF(Block, $00)

; -- Sprite 10 --
db $36
db $00,$00,$56,$A3,$11,$04
%AddToList(KingKing, $00)

; -- Sprite 11 --
db $36
db $00,$22,$34,$BE,$B9,$46
%AddToList(Sign, $00)

; -- Sprite 12 --
db $36
db $00,$00,$59,$A3,$11,$04
%AddToList(LakituLovers, $00)

; -- Sprite 13 --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList(DancerKoopa, $40)

; -- Sprite 14 --
db $36
db $10,$00,$44,$A1,$00,$00			; these two have different palettes (see byte 3, $00)
%AddToList(DancerKoopa, $40)

; -- Sprite 15 --
db $14
db $00,$00,$09,$29,$01,$00
%AddToList(SpinySpecial, $00)

; -- Sprite 16 --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList(Thif, $00)

; -- Sprite 17
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList(Thif, $00)

; -- Sprite 18 --
db $36
db $00,$00,$59,$A3,$11,$04
%AddToList(KompositeKoopa, $00)

; -- Sprite 19 --
db $36
db $00,$00,$59,$A3,$11,$04
%AddToList(Birdo, $00)

; -- Sprite 1A --
db $3E
db $00,$00,$47,$A1,$00,$00
%AddToList(Birdo_Egg, $00)

; -- Sprite 1B --
db $36
db $00,$00,$3A,$A6,$39,$46
%AddToList(Bumper, $40)

; -- Sprite 1C --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList(Monkey, $00)

; -- Sprite 1D --
db $36
db $10,$00,$48,$A1,$00,$00
%AddToList(Monkey, $00)

; -- Sprite 1E --
db $36
db $00,$1F,$30,$A6,$39,$47
%AddToList(TerrainPlatform, $00)

; -- Sprite 1F --
db $36
db $00,$1F,$30,$A6,$39,$47
%AddToList(TerrainPlatform, $00)

; -- Sprite 20 --
db $36
db $00,$00,$59,$A3,$11,$04
%AddToList(LavaLord, $00)

; -- Sprite 21 --
db $36
db $00,$00,$54,$A3,$11,$04
%AddToList(CoinGolem, $00)

; -- Sprite 22 --
db $36
db $00,$37,$34,$BE,$39,$46
%AddToList(YoshiCoin, $00)

; -- Sprite 23 --
db $36
db $00,$00,$50,$A1,$19,$04
%AddToList(EliteKoopa_Green, $00)

; -- Sprite 24 --
db $36
db $00,$00,$50,$A1,$19,$04
%AddToList(EliteKoopa_Red, $00)

; -- Sprite 25 --
db $36
db $00,$00,$50,$A1,$19,$04
%AddToList(EliteKoopa_Blue, $00)

; -- Sprite 26 --
db $36
db $00,$00,$50,$A1,$19,$04
%AddToList(EliteKoopa_Yellow, $00)

; -- Sprite 27 --
db $36
db $00,$00,$30,$A2,$39,$46
%AddToList(BooHoo, $00)

; -- Sprite 28 --
db $36
db $00,$00,$30,$A6,$39,$46
%AddToList(GigaThwomp, $00)

; -- Sprite 29 --
db $36
db $00,$00,$34,$A2,$39,$46
%AddToList(FlamePillar, $00)

; -- Sprite 2A --
db $36
db $00,$27,$59,$A5,$11,$04
%AddToList(BigMax, $00)

; -- Sprite 2B --
db $36
db $00,$00,$30,$A2,$39,$46
%AddToList(Portal, $00)

; -- Sprite 2C --
db $36
db $10,$2A,$4C,$A1,$18,$00
%AddToList(FlyingRex, $00)

; -- Sprite 2D --
db $36
db $00,$00,$36,$A2,$39,$46
%AddToList(UltraFuzzy, $00)

; -- Sprite 2E --
db $36
db $00,$00,$34,$A2,$39,$46
%AddToList(ShieldBearer, $40)

; -- Sprite 2F --
db $36
db $00,$1F,$30,$A6,$39,$47
%AddToList(Elevator, $00)
