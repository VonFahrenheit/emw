<<<<<<< Updated upstream
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
db $00,$00,$4B,$A1,$08,$00
%AddToList0toF(HappySlime, $00)

; -- Sprite 01 --
db $36
db $00,$00,$48,$A1,$00,$00
%AddToList0toF(GoombaSlave, $00)

; -- Sprite 02 --
db $36
db $00,$2A,$46,$A1,$00,$00
%AddToList0toF(Rex, $00)

; -- Sprite 03 --
db $36
db $00,$2A,$4A,$A1,$00,$00
%AddToList0toF(HammerRex, $00)

; -- Sprite 04 --
db $36
db $00,$27,$59,$A1,$11,$04
%AddToList0toF(AggroRex, $00)

; -- Sprite 05 --
db $36
db $00,$2A,$4A,$A1,$10,$00
%AddToList0toF(NoviceShaman, $00)

; -- Sprite 06 --
db $36
db $00,$27,$59,$A5,$11,$04
%AddToList0toF(AdeptShaman, $00)

; -- Sprite 07 --
db $36
db $00,$00,$30,$A6,$31,$46
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
db $00,$00,$48,$A1,$00,$00
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
db $00,$00,$59,$A3,$11,$04
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
db $00,$00,$48,$A1,$00,$00
%AddToList(DancerKoopa, $40)

; -- Sprite 14 --
db $36
db $00,$00,$44,$A1,$00,$00			; these two have different palettes (see byte 3, $00)
%AddToList(DancerKoopa, $40)

; -- Sprite 15 --
db $14
db $00,$00,$09,$29,$01,$00
%AddToList(SpinySpecial, $00)

; -- Sprite 16 --
db $36
db $00,$00,$48,$A1,$00,$00
%AddToList(Thif, $00)

; -- Sprite 17
db $36
db $00,$00,$48,$A1,$00,$00
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
db $00,$00,$38,$A6,$39,$46
%AddToList(Bumper, $40)

; -- Sprite 1C --
db $36
db $00,$00,$48,$A1,$00,$00
%AddToList(Monkey, $00)

; -- Sprite 1D --
db $36
db $00,$00,$48,$A1,$00,$00
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
db $00,$00,$30,$A2,$39,$46
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
db $00,$2A,$4C,$A1,$18,$00
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
=======

; tweaker 1: object/terrain interaction settings
;	tLoooowl
;	t = disable terrain interaction		(0x80)
;	L = disable layer 2/3 interaction	(0x40)			TODO: layer 2 interaction (low priority)
;	oooo = object clipping			(AND#)
;	w = disable water/lava splash
;	l = treat lava as water			(LSR)

; tweaker 2: sprite clipping settings
;	ps-ccccc
;	p = disable player interaction		(0x80)
;	s = disable sprite interaction		(0x40)
;	ccccc = sprite clipping			(AND#)

; tweaker 3: player/sprite interaction processing flags
;	osdpgitf
;	o = off-screen despawn protection	(0x80)
;	s = spiky surface			(0x40)
;	d = level init despawn protection
;	p = can't be picked up when kicked
;	g = ghost mode, no hitstun/hit gfx/sfx
;	i = item, default state is 9 instead of 8
;	t = turn around when touched
;	f = process interaction every frame	(AND#, LSR)

; tweaker 4: resistances + weight
;	mpsPkwww
;	m = melee attack immunity		(0x80)
;	p = projectile immunity (ex + thrown)	(0x40)
;	s = star immunity
;	P = silver POW immunity
;	k = knockback immunity
;	www = weight
;		0 = weightless (example: boo, eerie)
;		1 = very light (example: small bird)
;		2 = light (example: mushroom, shelless koopa)
;		3 = medium (example: goomba)
;		4 = big (example: rex, koopa)
;		5 = heavy (example: chuck, aggro rex)
;		6 = super heavy (example: thwomp)
;		7 = super massive (example: bosses and other rare sprites larger than 32x32)

; tweaker 5: graphics + jump height
;	hhhhhppp
;	hhhhh = jump height			(AND#)
;	ppp = palset (0 = special/hardcoded)	(AND#)

; palset values:
;	0 = don't load anything (used for sprites that are invisible or ones that have a hardcoded palset)
;	1 = default yellow
;	2 = default blue
;	3 = default red
;	4 = default green
;	5 = generic grey
;	6 = generic ghost blue
;	7 = generic light blue

; tweaker 6: common behaviors
;	llt--cww
;	ll = ledge behavior			(0x80, 0x40)
;		00 = ignore ledge
;		40 = turn away from ledge
;		80 = jump at ledge
;		C0 = ledge acts as wall
;	t = turn when touched by other sprite
;	c = can climb wall
;	ww = wall behavior			(AND#)
;		00 = ignore wall (still solid)
;		01 = turn away from wall
;		02 = jump at wall
;		03 = turn + invert X speed


; turn when touched
;	loop over sprites with HIGHER index (lower index will look for this sprite on their own)
;	get hitbox for each one (unless they have sprite interaction disabled)
;	check for contact
;	if contact, this sprite turns away from the other sprite (set not flip)





!temp_sprite_list = 0


macro AddToList(name)
	dl <name>_INIT
	dl <name>_MAIN
	if !temp_sprite_list < 16
	print "Sprite $0", hex(!temp_sprite_list), ": <name>"
	else
	print "Sprite $", hex(!temp_sprite_list), ": <name>"
	endif
	!temp_sprite_list := !temp_sprite_list+1
endmacro


macro TweakerData()
	; tweaker 1: object/terrain interaction
	!temp = !Tweaker_ObjectClipping&$0F*4

	if !Tweaker_DisableTerrain = 1
	!temp := !temp+128
	endif

	if !Tweaker_DisableLayer23 = 1
	!temp := !temp+64
	endif

	if !Tweaker_DisableWaterSplash = 1
	!temp := !temp+2
	endif

	if !Tweaker_TreatLavaAsWater = 1
	!temp := !temp+1
	endif

	db !temp

	; tweaker 2: sprite clipping settings
	!temp = !Tweaker_SpriteClipping&$1F

	if !Tweaker_DisablePlayerInteraction = 1
	!temp := !temp+128
	endif

	if !Tweaker_DisableSpriteInteraction = 1
	!temp := !temp+64
	endif

	db !temp

	; tweaker 3: player/sprite interaction settings
	!temp = !Tweaker_ProcessInteractionEveryFrame&1

	if !Tweaker_TurnWhenTouchedByPlayer = 1
	!temp := !temp+2
	endif

	if !Tweaker_CarryableItem = 1
	!temp := !temp+4
	endif

	if !Tweaker_GhostMode = 1
	!temp := !temp+8
	endif

	if !Tweaker_CantBePickedUpWhenKicked = 1
	!temp := !temp+16
	endif

	if !Tweaker_LevelInitDespawnProtection = 1
	!temp := !temp+32
	endif

	if !Tweaker_SpikySurface = 1
	!temp := !temp+64
	endif

	if !Tweaker_OffScreenDespawnProtection = 1
	!temp := !temp+128
	endif

	db !temp

	; tweaker 4: resistances + weight
	!temp = !Tweaker_Weight&7

	if !Tweaker_KnockbackImmunity = 1
	!temp := !temp+8
	endif

	if !Tweaker_SilverPowImmunity = 1
	!temp := !temp+16
	endif

	if !Tweaker_StarImmunity = 1
	!temp := !temp+32
	endif

	if !Tweaker_ProjectileImmunity = 1
	!temp := !temp+64
	endif

	if !Tweaker_MeleeAttackImmunity = 1
	!temp := !temp+128
	endif

	db !temp

	; tweaker 5: graphics and jump height
	db !Tweaker_Palset+(!Tweaker_JumpHeight&$F8)

	; tweaker 6: common behaviors
	!temp = !Tweaker_WallBehavior&3+(!Tweaker_LedgeBehavior&3*64)

	if !Tweaker_CanClimbWall = 1
	!temp := !temp+4
	endif

	if !Tweaker_TurnWhenTouchedByOtherSprite = 1
	!temp := !temp+32
	endif

	db !temp
endmacro



; VANILLA SPRITE DATA
pushpc
org $07F26C
VanillaTweakerData:
	incsrc "SpriteData_Vanilla.asm"
warnpc $07F722
pullpc


; CUSTOM SPRITE DATA
SpriteData:
	incsrc "SpriteData_Custom.asm"


>>>>>>> Stashed changes
