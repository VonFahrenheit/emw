; Each sprite type has 16 bytes, the format is as follows:
; $00 - New code flag (really just a leftover from sprite tool)
; $01 - Sprite number		($3200)
; $02 - Tweaker 1		($3440)
; $03 - Tweaker 2		($3450)
; $04 - Tweaker 3		($3460 + $33C0)
; $05 - Tweaker 4		($3470)
; $06 - Tweaker 5		($3480)
; $07 - Tweaker 6		($34B0)
; $08 - 24-bit INIT pointer
; $0B - 24-bit MAIN pointer
; $0E - Extra property 1	($35A0)
; $0F - Extra property 2	($35B0)

!temp_sprite_list = 0



; set highest bit of p2 to have MAIN run during special states
; set second highest bit of p2 to run normal special state codes

macro AddToList0toF(name, p1, p2)

	dl <name>_INIT
	dl <name>_MAIN
	db <p1>,<p2>
	print "Sprite $0", hex(((?temp-SpriteData)/16)-1), ": <name>"

	?temp:

endmacro

macro AddToList(name, p1, p2)

	dl <name>_INIT
	dl <name>_MAIN
	db <p1>,<p2>
	print "Sprite $", hex(((?temp-SpriteData)/16)-1), ": <name>"

	?temp:

endmacro


SpriteData:

; -- Sprite 00 --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(HappySlime, $00, $00)

; -- Sprite 01 --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(GoombaSlave, $00, $00)

; -- Sprite 02 --
db $01,$36
db $00,$2A,$47,$81,$00,$00
%AddToList0toF(Rex, $00, $00)

; -- Sprite 03 --
db $01,$36
db $00,$2A,$4B,$81,$00,$00
%AddToList0toF(HammerRex, $00, $00)

; -- Sprite 04 --
db $01,$36
db $00,$27,$59,$81,$11,$04
%AddToList0toF(AggroRex, $00, $00)

; -- Sprite 05 --
db $01,$36
db $00,$2A,$4B,$81,$00,$00
%AddToList0toF(NoviceShaman, $00, $00)

; -- Sprite 06 --
db $01,$36
db $00,$27,$59,$85,$11,$04
%AddToList0toF(AdeptShaman, $00, $00)

; -- Sprite 07 --
db $01,$36
db $00,$00,$30,$A6,$31,$46
%AddToList0toF(Projectile, $00, $00)

; -- Sprite 08 --
db $01,$36
db $00,$00,$59,$81,$11,$04
%AddToList0toF(CaptainWarrior, $00, $00)

; -- Sprite 09 --
db $01,$36
db $00,$00,$57,$85,$00,$00
%AddToList0toF(TarCreeper, $00, $00)

; -- Sprite 0A --
db $01,$36
db $00,$00,$57,$81,$00,$00
%AddToList0toF(MiniMech, $00, $00)

; -- Sprite 0B --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(MoleWizard, $00, $00)

; -- Sprite 0C --
db $01,$36
db $00,$00,$47,$81,$00,$04
%AddToList0toF(MiniMole, $00, $00)

; -- Sprite 0D --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList0toF(PlantHead, $00, $00)

; -- Sprite 0E --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList0toF(NPC, $00, $00)

; -- Sprite 0F --
db $01,$36
db $00,$22,$30,$BE,$B9,$46
%AddToList0toF(Block, $00, $00)

; -- Sprite 10 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(KingKing, $00, $00)

; -- Sprite 11 --
db $01,$36
db $00,$22,$30,$BE,$B9,$46
%AddToList(Sign, $00, $00)

; -- Sprite 12 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(LakituLovers, $00, $00)

; -- Sprite 13 --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(DancerKoopa, $00, $00)

; -- Sprite 14 --
db $01,$36
db $00,$00,$44,$81,$00,$00			; these two have different palettes (see byte 3)
%AddToList(DancerKoopa, $00, $00)

; -- Sprite 15 --
db $01,$14
db $00,$00,$09,$09,$01,$00
%AddToList(SpinySpecial, $00, $00)

; -- Sprite 16 --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Thif, $00, $00)

; -- Sprite 17
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Thif, $01, $00)

; -- Sprite 18 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(KompositeKoopa, $00, $00)

; -- Sprite 19 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(Birdo, $00, $00)

; -- Sprite 1A --
db $01,$3E
db $00,$00,$47,$81,$00,$00
%AddToList(Birdo_Egg, $00, $00)

; -- Sprite 1B --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList(Bumper, $00, $40)

; -- Sprite 1C --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Monkey, $00, $00)

; -- Sprite 1D --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Monkey, $01, $00)

; -- Sprite 1E --
db $01,$36
db $00,$1F,$30,$A6,$39,$47
%AddToList(TerrainPlatform, $00, $00)

; -- Sprite 1F --
db $01,$36
db $00,$1F,$30,$A6,$39,$47
%AddToList(TerrainPlatform, $01, $00)

; -- Sprite 20 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(LavaLord, $00, $00)

; -- Sprite 21 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(CoinGolem, $00, $00)

; -- Sprite 22 --
db $01,$36
db $00,$37,$30,$BE,$39,$46
%AddToList(YoshiCoin, $00, $00)

; -- Sprite 23 --
db $01,$36
db $00,$27,$50,$81,$11,$04
%AddToList(EliteKoopa_Green, $00, $00)

; -- Sprite 24 --
db $01,$36
db $00,$27,$50,$81,$11,$04
%AddToList(EliteKoopa_Red, $00, $00)

; -- Sprite 25 --
db $01,$36
db $00,$27,$50,$81,$11,$04
%AddToList(EliteKoopa_Blue, $00, $00)

; -- Sprite 26 --
db $01,$36
db $00,$27,$50,$81,$11,$04
%AddToList(EliteKoopa_Yellow, $00, $00)
