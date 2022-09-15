

!temp_sprite_list = 0



; set highest bit of p2 to have MAIN run during special states
; set second highest bit of p2 to run normal special state codes
; for the purposes of this, any sprite state other than 0x01 or 0x08 is considered special
; MAIN refers to the custom sprite's code
; highest 2 bits of p2 are always set by this table, but the other 6 bits can be set by LM for use as normal

macro AddToList0toF(name)
	dl <name>_INIT
	dl <name>_MAIN
	print "Sprite $0", hex(((?temp-SpriteData)/12)-1), ": <name>"
	?temp:
endmacro

macro AddToList(name)
	dl <name>_INIT
	dl <name>_MAIN
	print "Sprite $", hex(((?temp-SpriteData)/12)-1), ": <name>"
	?temp:
endmacro




; tweaker 1: object/terrain interaction settings
;	tLoooowl
;	t = disable terrain interaction		(0x80)
;	L = disable layer 2/3 interaction	(0x40)			TODO: layer 2 interaction (low priority)
;	oooo = object clipping			(AND#)
;	w = disable water splash
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

; tweaker 4: resistances
;	mpksP-K-
;	m = melee attack immunity		(0x80)
;	p = projectile immunity (ex + thrown)	(0x40)
;	k = slide kick immunity						TODO
;	s = star immunity
;	P = silver POW immunity
;	K = knockback immunity

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
;		40 = turn around at ledge
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







; VANILLA SPRITE DATA
pushpc
org $07F26C
VanillaTweakerData:
.Tweaker1
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0
..1	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1
..2	db $08,$00,$0C,$0C,$0C,$0C,$04,$00,$00,$00,$04,$00,$00,$00,$00,$00	; 2
..3	db $00,$00,$00,$00,$00,$14,$00,$00,$00,$00,$1C,$1C,$1C,$00,$00,$00	; 3
..4	db $00,$00,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$30	; 4
..5	db $30,$00,$00,$00,$00,$00,$04,$00,$04,$04,$04,$2C,$2C,$2C,$2C,$00	; 5
..6	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$24,$00	; 6
..7	db $28,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00	; 7
..8	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$18,$00,$00,$00,$00,$00	; 8
..9	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 9
..A	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; A
..B	db $00,$34,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$38	; B
..C	db $00,$00,$80,$00,$00,$00,$3C,$00,$00					; C

org $07F335
.Tweaker2
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,$00	; 0
..1	db $00,$00,$08,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01	; 1
..2	db $00,$00,$01,$01,$01,$01,$06,$00,$07,$06,$01,$00,$00,$00,$00,$00	; 2
..3	db $37,$00,$37,$00,$00,$09,$01,$00,$00,$00,$02,$02,$02,$00,$00,$00	; 3
..4	db $00,$0F,$0F,$10,$14,$00,$0D,$00,$00,$1D,$00,$00,$00,$00,$00,$00	; 4
..5	db $00,$00,$02,$0C,$03,$05,$04,$05,$04,$00,$00,$04,$05,$04,$05,$00	; 5
..6	db $1D,$0C,$04,$04,$12,$20,$21,$2C,$34,$04,$04,$04,$04,$0C,$16,$00	; 6
..7	db $17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1E,$35,$00,$00,$00	; 7
..8	db $00,$00,$00,$0C,$0C,$00,$00,$3A,$08,$08,$C3,$00,$00,$00,$1C,$08	; 8
..9	db $38,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$00,$0D,$00,$1D,$00,$00,$36	; 9
..A	db $24,$23,$3B,$1F,$22,$00,$27,$00,$00,$28,$00,$2A,$2B,$2B,$00,$00	; A
..B	db $00,$0C,$00,$2D,$00,$00,$00,$2E,$2E,$0C,$1D,$04,$0C,$00,$00,$30	; B
..C	db $32,$31,$40,$00,$33,$07,$3F,$00,$0C					; C

org $07F3FE
.Tweaker3
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 0
..1	db $02,$02,$02,$42,$42,$00,$00,$00,$00,$02,$02,$02,$02,$02,$02,$02	; 1
..2	db $02,$0A,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 2
..3	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$02,$02	; 3
..4	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$02	; 4
..5	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 5
..6	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 6
..7	db $02,$02,$02,$02,$0A,$0A,$0A,$0A,$0A,$02,$02,$02,$02,$02,$02,$02	; 7
..8	db $A4,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; 8
..9	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$40,$02,$02,$02,$02,$02,$02	; 9
..A	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02	; A
..B	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$20,$02,$02,$02,$02	; B
..C	db $02,$02,$00,$02,$02,$02,$02,$02,$02					; C

org $07F4C7
.Tweaker4
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 0
..1	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 1
..2	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 2
..3	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 3
..4	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 4
..5	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 5
..6	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 6
..7	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 7
..8	db $FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 8
..9	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 9
..A	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; A
..B	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00	; B
..C	db $00,$00,$00,$00,$00,$00,$00,$00,$00					; C

org $07F590
.Tweaker5
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $E4,$E3,$E2,$E1,$04,$03,$02,$01,$04,$C2,$03,$03,$01,$07,$02,$01	; 0
..1	db $01,$0D,$0D,$03,$03,$D1,$D1,$D1,$D1,$0B,$08,$01,$02,$05,$09,$0F	; 1
..2	db $0C,$01,$0B,$09,$0B,$09,$03,$03,$0D,$0B,$08,$05,$0B,$0A,$09,$0A	; 2
..3	db $03,$03,$03,$04,$09,$0A,$05,$03,$0D,$0D,$07,$07,$07,$02,$00,$05	; 3
..4	db $05,$07,$07,$07,$03,$00,$0B,$05,$0D,$0B,$0B,$09,$04,$C1,$C1,$08	; 4
..5	db $08,$09,$00,$00,$00,$03,$03,$03,$03,$03,$03,$01,$01,$0B,$0B,$03	; 5
..6	db $03,$03,$01,$01,$03,$03,$03,$03,$03,$03,$00,$03,$03,$0F,$0F,$0F	; 6
..7	db $05,$0B,$09,$07,$03,$03,$C8,$04,$01,$0A,$0A,$00,$00,$01,$08,$00	; 7
..8	db $01,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$0B	; 8
..9	db $03,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$04,$03,$00,$00,$01,$01,$01	; 9
..A	db $0B,$0B,$0B,$03,$03,$05,$05,$09,$05,$05,$0D,$07,$07,$07,$0D,$0F	; A
..B	db $0F,$00,$01,$01,$01,$04,$05,$0B,$0B,$06,$0B,$05,$03,$06,$0B,$01	; B
..C	db $05,$05,$04,$0D,$03,$0F,$0F,$00,$08					; C

org $07F659
.Tweaker6
	;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
..0	db $21,$61,$61,$21,$20,$60,$60,$00,$00,$01,$00,$00,$00,$01,$01,$01	; 0
..1	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 1
..2	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 2
..3	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$01,$01	; 3
..4	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$82,$82,$01	; 4
..5	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 5
..6	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 6
..7	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 7
..8	db $00,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 8
..9	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; 9
..A	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01	; A
..B	db $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$01,$01,$01,$01	; B
..C	db $01,$01,$00,$01,$01,$01,$01,$01,$01					; C

warnpc $07F722
pullpc



; sprite clippings:
; 00 - small (16x16)
; 01 - tall (16x32)
; 02 - big (32x32)


SpriteData:

; -- Sprite 00 --
db $00,$00,$00,$00,$04,$00
%AddToList0toF(HappySlime)

; -- Sprite 01 --
db $00,$00,$00,$00,$03,$21
%AddToList0toF(GoombaSlave)

; -- Sprite 02 --
db $00,$01,$00,$00,$C2,$61
%AddToList0toF(Rex)

; -- Sprite 03 --
db $00,$01,$00,$00,$C4,$61
%AddToList0toF(HammerRex)

; -- Sprite 04 --
db $00,$02,$00,$00,$D3,$81		; 00/80 when chasing, depending on whether it should jump or drop down
%AddToList0toF(AggroRex)

; -- Sprite 05 --
db $00,$01,$00,$00,$04,$61
%AddToList0toF(Conjurex)

; -- Sprite 06 --
db $00,$05,$80,$00,$00,$00
%AddToList0toF(Wizrex)

; -- Sprite 07 --
db $00,$40,$00,$FF,$00,$00
%AddToList0toF(Projectile)

; -- Sprite 08 --
db $00,$00,$A1,$38,$00,$00
%AddToList0toF(CaptainWarrior)

; -- Sprite 09 --
db $00,$00,$00,$00,$01,$41
%AddToList0toF(TarCreeper)

; -- Sprite 0A --
db $00,$40,$00,$00,$00,$00			;\ UNUSED, DUPED AS A DUMMY
%AddToList0toF(ShopObject)			;/

; -- Sprite 0B --
db $00,$00,$00,$00,$01,$00
%AddToList0toF(MoleWizard)

; -- Sprite 0C --
db $18,$03,$00,$00,$01,$21
%AddToList0toF(MiniMole)

; -- Sprite 0D --
db $00,$00,$00,$00,$03,$00
%AddToList0toF(PlantHead)

; -- Sprite 0E --
db $00,$40,$A0,$FF,$00,$C0
%AddToList0toF(NPC)

; -- Sprite 0F --
db $00,$40,$A0,$FF,$01,$00
%AddToList0toF(Block)

; -- Sprite 10 --
db $00,$40,$A0,$00,$00,$00
%AddToList(KingKing)

; -- Sprite 11 --
db $00,$C0,$20,$FF,$01,$00
%AddToList(Sign)

; -- Sprite 12 --
db $00,$40,$A0,$00,$00,$00
%AddToList(LakituLovers)

; -- Sprite 13 --
db $00,$00,$00,$00,$00,$03			;\ UNUSED, DUPED AS A DUMMY
%AddToList(ShopObject)				;/

; -- Sprite 14 --
db $00,$00,$00,$00,$01,$03			;\ UNUSED, DUPED AS A DUMMY
%AddToList(ShopObject)				;/

; -- Sprite 15 --
db $00,$00,$00,$00,$03,$00			;\ UNUSED, DUPED AS A DUMMY
%AddToList(ShopObject)				;/

; -- Sprite 16 --
db $00,$00,$00,$00,$00,$00
%AddToList(Thif)

; -- Sprite 17
db $00,$00,$00,$00,$00,$00
%AddToList(Thif)

; -- Sprite 18 --
db $00,$00,$00,$00,$00,$00
%AddToList(KompositeKoopa)

; -- Sprite 19 --
db $00,$00,$00,$00,$00,$00
%AddToList(Birdo)

; -- Sprite 1A --
db $00,$00,$04,$00,$00,$00
%AddToList(Birdo_Egg)

; -- Sprite 1B --
db $00,$02,$00,$FF,$04,$00
%AddToList(Bumper)

; -- Sprite 1C --
db $00,$00,$00,$00,$01,$00
%AddToList(Monkey)

; -- Sprite 1D --
db $00,$00,$00,$00,$01,$00
%AddToList(Monkey)

; -- Sprite 1E --
db $00,$1F,$A0,$00,$00,$00
%AddToList(TerrainPlatform)

; -- Sprite 1F --
db $00,$1F,$A0,$00,$00,$00
%AddToList(TerrainPlatform)

; -- Sprite 20 --
db $00,$00,$A0,$00,$00,$00
%AddToList(LavaLord)

; -- Sprite 21 --
db $00,$00,$A0,$00,$01,$00
%AddToList(CoinGolem)

; -- Sprite 22 --
db $00,$00,$28,$00,$01,$00
%AddToList(YoshiCoin)

; -- Sprite 23 --
db $00,$01,$00,$00,$04,$41
%AddToList(EliteKoopa_Green)

; -- Sprite 24 --
db $00,$01,$00,$00,$03,$00
%AddToList(EliteKoopa_Red)

; -- Sprite 25 --
db $00,$01,$00,$00,$02,$00
%AddToList(EliteKoopa_Blue)

; -- Sprite 26 --
db $00,$01,$80,$00,$01,$00
%AddToList(EliteKoopa_Yellow)

; -- Sprite 27 --
db $00,$40,$00,$FF,$06,$00
%AddToList(BooHoo)

; -- Sprite 28 --
db $00,$00,$A0,$FF,$00,$00
%AddToList(GigaThwomp)

; -- Sprite 29 --
db $00,$40,$00,$FF,$01,$00
%AddToList(FlamePillar)

; -- Sprite 2A --
db $00,$00,$A0,$00,$03,$00
%AddToList(BigMax)

; -- Sprite 2B --
db $00,$C0,$00,$FF,$04,$00
%AddToList(Portal)

; -- Sprite 2C --
db $00,$01,$00,$00,$07,$83
%AddToList(FlyingRex)

; -- Sprite 2D --
db $00,$40,$08,$02,$06,$00
%AddToList(UltraFuzzy)

; -- Sprite 2E --
db $00,$00,$00,$00,$01,$00
%AddToList(ShieldBearer)

; -- Sprite 2F --
db $00,$40,$A0,$FF,$01,$00
%AddToList(Elevator)

; -- Sprite 30 --
db $00,$00,$A4,$00,$01,$00
%AddToList(Chest)

; -- Sprite 31 --
db $00,$00,$20,$FF,$05,$00
%AddToList(EpicBlock)

; -- Sprite 32 --
db $00,$00,$A0,$FF,$01,$00
%AddToList(ShopObject)

; -- Sprite 33 --
db $00,$00,$20,$00,$04,$01		;\ UNUSED, DUPED AS A DUMMY
%AddToList(ShopObject)			;/

; -- Sprite 34 --
db $00,$01,$00,$00,$C7,$83
%AddToList(Rex_Dense)

; -- Sprite 35 --
db $00,$DF,$20,$FF,$00,$00
%AddToList(SmokeyBoy)

; -- Sprite 36 --
db $00,$DF,$20,$FF,$00,$00
%AddToList(AirshipDisplay)

; -- Sprite 37 --
db $00,$5F,$A0,$FF,$02,$00
%AddToList(Lightning)



