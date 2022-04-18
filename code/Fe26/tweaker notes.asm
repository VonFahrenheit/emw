
; all.log has 140 references to "Tweaker", including defines and comments

; scrapped features:	24
; remapped features:	17
; new features:		2


; tweaker 1
;	sSjJcccc
;	s = disappear in cloud of smoke		(0x80)		KILL (only used by 3-5ish sprites)
;	S = hop in/kick shells			(0x40)		KILL (only used by shelless koopas)
;	j = dies when jumped on					KILL (only used by 8-10ish sprites)
;	J = spiky surface					REMAP: t1:10 -> t3:40
;	cccc = object clipping			(AND#)		UNCHANGED

; tweaker 2
;	dscccccc
;	d = falls straight down when killed	(0x80)		KILL (used by about a dozen sprites, but i want to remove this)
;	s = use shell as death frame		(0x40)		KILL (used by 10ish sprites, replace with particle)
;	cccccc = sprite clipping		(AND#)		UNCHANGED

; tweaker 3
;	lwcfpppg
;	l = don't interact with layer 2/3	(0x80)		REMAP: t3:80 -> t1:40
;	w = disable water splash		(0x40)		REMAP: t3:40 -> t1:20
;	c = disable cape contact				REMAP: t3:20 -> t4:80
;	f = disable fireball kill				REMAP: t3:10 -> t4:40
;	ppp = ccc bits of OAM prop		(AND#)		REMAP: t3:0E -> t5:0E
;	g = t bit of OAM prop			(AND#, LSR)	REMAP: t3:01 -> t5:01

; tweaker 4
;	dpmksPiS
;	d = ignore default mario interaction	(0x80)		KILL (used quite a lot, FIGURE OUT)
;	p = gives power-up when eaten by yoshi	(0x40)		KILL (used by a small number of sprites, SCRAP!)
;	m = process interaction every frame			REMAP: t4:20 -> t3:01
;	k = can't be kicked like a shell			KILL (used by 15ish sprites, FIGURE OUT)
;	s = don't become shell when stunned			KILL (used by 5ish sprites, FIGURE OUT)
;	P = process while off-screen				REMAP: t4:04 -> t3:80
;	i = invincible to star/cape/fire/thrown			REMAP: t4:02 -> t4:10
;	S = don't disable clipping in state 02	(LSR)		KILL (used a lot, but i want every sprite to have this property)

; tweaker 5
;	dnctswye
;	d = don't interact with terrain		(0x80)		REMAP: t5:80 -> t1:80
;	n = spawns a new sprite			(0x40)		KILL (used by 10ish sprites, FIGURE OUT)
;	c = don't turn into a coin from goal			KILL (SCRAP!)
;	t = don't change direction if touched			REMAP: t5:10 -> t3:02
;	s = don't interact with other sprites			REMAP: t5:08 -> t2:40
;	w = weird ground behavior				KILL (FIGURE OUT!)
;	y = stay in yoshi's mouth				KILL (used by carryable items, SCRAP!)
;	e = inedible				(LSR)		KILL (used quite a bit, SCRAP!)

; tweaker 6
;	wcdj5sDp
;	w = don't get stuck in walls		(0x80)		KILL (make default behavior in sprite states 09/0A)
;	c = immune to silver POW		(0x40)		REMAP: t6:40 -> t4:08
;	d = death frame uses 2 tiles				KILL (FIGURE OUT!)
;	j = can be jumped on with up Y speed			REMAP: t6:10 -> t3:20)
;	5 = takes 5 fireballs to kill				KILL (FIGURE OUT!)
;	s = immune to slide kill				REMAP: t6:04 -> t4:20)
;	D = don't erase from goal				KILL (SCRAP!)
;	p = platform passable from below	(LSR)		KILL (just use platform box)




; ANALYSIS

; functions:
;	object clipping
;	sprite clipping
;	graphics:
;		- ccc bits
;		- t bit
;	immunity/resistance:
;		- cape (rework to melee attack)
;		- fire (rework to ex_projectile + thrown item)
;		- slide
;		- star/cape/fire/thrown (rework to star only)
;		- silver POW
;	player/sprite interaction:
;		- process interaction 30/60 times per second
;		- process when off-screen
;		- interact with other sprites
;		- turn around when touched
;		- can be jumped on with up Y speed
;		- spiky surface
;	terrain interaction:
;		- interact with terrain
;		- disable layer 2/3 interaction
;		- disable water splash
;		ADD: treat lava as water
;	



; REWORK

; tweaker 1: object/terrain interaction settings
;	tLoooowl
;	t = disable terrain interaction		(0x80)
;	L = disable layer 2/3 interaction	(0x40)
;	oooo = object clipping			(AND#)
;	w = disable water splash
;	l = treat lava as water			(LSR)

; tweaker 2: sprite clipping settings
;	pscccccc
;	p = disable player interaction		(0x80)
;	s = disable sprite interaction		(0x40)
;	cccccc = sprite clipping		(AND#)

; tweaker 3: player/sprite interaction processing flags
;	osu---tf
;	o = process while off-screen		(0x80)
;	s = spiky surface			(0x40)
;	u = can be jumped on with up Y speed
;	t = turn around when touched
;	f = process interaction every frame	(AND#, LSR)

; tweaker 4: resistances
;	mpksPc--
;	m = melee attack immunity		(0x80)
;	p = projectile immunity (ex + thrown)	(0x40)
;	k = slide kick immunity
;	s = star immunity
;	P = silver POW immunity
;	c = crush immunity (effects such as spin jump)

; tweaker 5: graphics + jump height
;	hhhhccct
;	hhhh = jump height			(AND#)
;	ccc = ccc bits of OAM prop		(AND#)
;	t = t bit of OAM prop			(AND#, LSR)

; tweaker 6: common behaviors
;	ll----ww
;	ll = ledge behavior			(0x80, 0x40)
;		00 = ignore ledge
;		01 = turn around at ledge
;		02 = jump at ledge
;		03 = ledge acts as wall
;	ww = wall behavior			(AND#)
;		00 = ignore wall (still can't pass through)
;		01 = turn around at wall
;		02 = jump at wall
;		03 = turn around at wall + invert X speed




