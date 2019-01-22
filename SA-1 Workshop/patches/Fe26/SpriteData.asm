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


macro AddToList0toF(name)

	dl <name>_INIT
	dl <name>_MAIN
	db $00,$00
	print "Sprite $0", hex(((?temp-SpriteData)/16)-1), ": <name>"

	?temp:

endmacro

macro AddToList(name)

	dl <name>_INIT
	dl <name>_MAIN
	db $00,$00
	print "Sprite $", hex(((?temp-SpriteData)/16)-1), ": <name>"

	?temp:

endmacro


SpriteData:

; -- Sprite 00 --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(HappySlime)

; -- Sprite 01 --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(GoombaSlave)

; -- Sprite 02 --
db $01,$36
db $00,$2A,$47,$81,$00,$00
%AddToList0toF(Rex)

; -- Sprite 03 --
db $01,$36
db $00,$2A,$4B,$81,$00,$00
%AddToList0toF(HammerRex)

; -- Sprite 04 --
db $01,$36
db $00,$27,$59,$81,$11,$04
%AddToList0toF(AggroRex)

; -- Sprite 05 --
db $01,$36
db $00,$2A,$4B,$81,$00,$00
%AddToList0toF(NoviceShaman)

; -- Sprite 06 --
db $01,$36
db $00,$27,$59,$85,$11,$04
%AddToList0toF(AdeptShaman)

; -- Sprite 07 --
db $01,$36
db $00,$00,$30,$A6,$31,$46
%AddToList0toF(Projectile)

; -- Sprite 08 --
db $01,$36
db $00,$00,$59,$81,$11,$04
%AddToList0toF(CaptainWarrior)

; -- Sprite 09 --
db $01,$36
db $00,$00,$57,$85,$00,$00
%AddToList0toF(TarCreeper)

; -- Sprite 0A --
db $01,$36
db $00,$00,$57,$81,$00,$00
%AddToList0toF(MiniMech)

; -- Sprite 0B --
db $01,$36
db $00,$00,$47,$81,$00,$00
%AddToList0toF(MoleWizard)

; -- Sprite 0C --
db $01,$36
db $00,$00,$47,$81,$00,$04
%AddToList0toF(MiniMole)

; -- Sprite 0D --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList0toF(PlantHead)

; -- Sprite 0E --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList0toF(NPC)

; -- Sprite 0F --
db $01,$36
db $00,$22,$30,$BE,$B9,$46
%AddToList0toF(Block)

; -- Sprite 10 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(KingKing)

; -- Sprite 11 --
db $01,$36
db $00,$22,$30,$BE,$B9,$46
%AddToList(Sign)

; -- Sprite 12 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(LakituLovers)

; -- Sprite 13 --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(DancerKoopa)

; -- Sprite 14 --
db $01,$36
db $00,$00,$44,$81,$00,$00
%AddToList(DancerKoopa)

; -- Sprite 15 --
db $01,$14
db $00,$00,$09,$09,$01,$00
%AddToList(SpinySpecial)

; -- Sprite 16 --
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Thif)

; -- Sprite 17
db $01,$36
db $00,$00,$48,$81,$00,$00
%AddToList(Thif)

; -- Sprite 18 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(KompositeKoopa)

; -- Sprite 19 --
db $01,$36
db $00,$00,$59,$83,$11,$04
%AddToList(Birdo)

; -- Sprite 1A --
db $01,$3E
db $00,$00,$47,$81,$00,$00
%AddToList(Birdo_Egg)

; -- Sprite 1B --
db $01,$36
db $00,$00,$30,$A6,$39,$46
%AddToList(Bumper)

