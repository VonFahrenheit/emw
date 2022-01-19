;===================;
; MANUAL .MW2 MAKER ;
;===================;
macro sprite(num, ex)
	db $89|((<ex>&1)*4)
	db $70
	db $<num>
	db $00,$00
endmacro

macro extrasprite(num, ex, ext1, ext2)
	db $89|((<ex>&1)*4)
	db $70
	db $<num>
	db $<ext1>,$<ext2>
endmacro

; to use, patch this to your .mw2 file using asar
; to use macro, enter sprite number in hex (but without "$") followed by 0 or 1, which is the extra bit status
; for example, %sprite(02, 0) adds custom sprite $02 with extra bit clear to the list
; NOTE: to use extra bytes, use %extrasprite() macro instead! this takes the same input, + the 2 extra bytes after sprite num + extra bit
; this list doesn't do anything in-game, but Lunar Magic still needs it to correctly display custom sprites
; well, more correctly than just X

norom
org $000000
db $00
%sprite(00, 0)			; Happy Slime
%sprite(00, 1)			; Happy Slime
%sprite(01, 0)			; Goomba Slave
%sprite(01, 1)			; Goomba Slave
%sprite(02, 0)			; Smart Rex
%sprite(02, 1)			; Smart Rex
%extrasprite(02, 0, 01, 01)	; rex: sack + feather hat
%extrasprite(02, 0, 02, 02)	; rex: mushroom set
%extrasprite(02, 0, 03, 03)	; rex: backpack + straw hat
%extrasprite(02, 0, 04, 04)	; rex: courier set
%extrasprite(02, 0, 01, 05)	; rex: bandit
%extrasprite(02, 0, 00, 06)	; rex: aristocrat
%extrasprite(02, 0, 00, 07)	; rex: bandana
%extrasprite(02, 0, 05, 08)	; rex: knight
%sprite(03, 0)			; Hammer Rex
%sprite(03, 1)			; Hammer Rex
%sprite(04, 0)			; Aggro Rex
%sprite(04, 1)			; Aggro Rex
%sprite(05, 0)			; Novice Shaman
%sprite(05, 1)			; Novice Shaman
%sprite(06, 0)			; Adept Shaman
%sprite(06, 1)			; Master Shaman
%sprite(07, 0)			; Ball o' Hurt
%sprite(08, 0)			; Captain Warrior
%sprite(08, 1)			; Captain Warrior
%sprite(09, 0)			; Tar Creeper
%sprite(09, 1)			; Tar Creeper
%sprite(0A, 0)			; Mini Mech
%sprite(0B, 0)			; Mole Wizard
%sprite(0C, 0)			; Mini Mole
%sprite(0C, 1)			; Mini Mole
%sprite(0D, 0)			; Red Plant Head
%sprite(0D, 1)			; Yellow Plant Head
%sprite(0E, 0)			; NPC
%sprite(0F, 0)			; Block
%sprite(0F, 1)			; Block
%sprite(10, 0)			; Kingking
%sprite(10, 1)			; Kingking's Scepter
%sprite(11, 0)			; Sign
%sprite(11, 1)			; Sign
%sprite(12, 0)			; Lakitu Lovers
%sprite(12, 1)			; Dance Pad
%sprite(13, 0)			; Green Dancer Koopa
%sprite(13, 1)			; Red Dancer Koopa
%sprite(14, 0)			; Blue Dancer Koopa
%sprite(14, 1)			; Yellow Dancer Koopa
%sprite(15, 0)			; Spiny
%sprite(15, 1)			; Rolling Spiny
%sprite(16, 0)			; Thif
%sprite(16, 1)			; Thif
%sprite(17, 0)			; Thif
%sprite(17, 1)			; Thif
%sprite(18, 0)			; Red Komposite Koopa
%sprite(18, 1)			; Green Komposite Koopa
%sprite(19, 0)			; Birdo
%sprite(1A, 0)			; Birdo's Egg
%sprite(1B, 0)			; Bumper
%sprite(1C, 0)			; Monkey
%sprite(1C, 1)			; Monkey
%sprite(1D, 0)			; Monkey
%sprite(1D, 1)			; Monkey
%sprite(1E, 0)			; Tall Terrain Platform
%sprite(1E, 1)			; Tall Terrain Platform
%sprite(1F, 0)			; Terrain Platform
%sprite(1F, 1)			; Terrain Platform
%sprite(20, 0)			; Lava Lord
%sprite(21, 0)			; Coin Golem
%sprite(22, 0)			; Yoshi Coin
%sprite(23, 0)			; Green Elite Koopa
%sprite(24, 0)			; Red Elite Koopa
%sprite(25, 0)			; Blue Elite Koopa
%sprite(26, 0)			; Yellow Elite Koopa
%sprite(27, 0)			; Boo Hoo
%sprite(27, 1)			; Boo Hoo
%sprite(28, 0)			; Giga Thwomp
%sprite(29, 0)			; Flame Pillar
%sprite(2A, 0)			; Big Max
%sprite(2B, 0)			; Portal
%sprite(2B, 1)			; Portal
%sprite(2C, 0)			; Flying Rex
%sprite(2C, 1)			; Flying Rex
%sprite(2D, 0)			; Ultra Fuzzy
%sprite(2E, 0)			; Shield (front)
%sprite(2E, 1)			; Shield (back)
%sprite(2F, 0)			; Elevator
%sprite(30, 0)			; Chest
%sprite(31, 0)			; Experimental Block
%sprite(32, 0)			; Shop Object
%sprite(33, 0)			; Life Shroom
%extrasprite(34, 0, 00, 07)	; dense rex: bandana
%extrasprite(34, 0, 01, 07)	; dense rex: bandana
%extrasprite(34, 0, 02, 07)	; dense rex: bandana
%extrasprite(35, 0, 02, 00)	; smoke generator
%sprite(36, 0)			; Airship Display
%sprite(37, 0)			; Lightning Generator
db $FF


