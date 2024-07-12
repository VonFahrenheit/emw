

		; JSL $0DA40F: part of object loader

		; SNES does JSR $[05]85FF, which has a JSL to a vitor address that calls SA-1
		; SA-1 has a short wrapper, then JMLs to $058605
		; before this, it does PHK : PEA $8216-1 : PEA $8124-1
		; it means to hit an RTS, bringing it to $[05]8124, then an RTL that brings it to just after the JML

; $0586C5
;	LDA $5A : BNE +
;	JSR $86E3
;	JMP ++			; NES?
;+	JSR $86EA
;++	SEP #$20
;	REP #$10
;	LDY #$0000
;	LDA [$65],y
;	CMP #$FF : BEQ .RETURN
;	JML sa1address		; restarts the loop
; $86E3
;	SEP #$30
;	JSL $0DA100
;	.RETURN
;	RTS
; $86EA
;	SEP #$30
;	JSL $0DA40F
;	RTS



; object data format:
;	NBBYYYYY bbbbXXXX SSSSSSSS
;	N	 - new screen flag
;	BBbbbb	 - object number
;	XXXX	 - x position
;	YYYYY	 - y position
;	SSSSSSSS - use varies depending on object, usually width/height
;
; object list:
;	unless specified, S = height + width
;	00 - extended object (S = extended object number, see separate list below)
;	01 - water (tile 0002)
;	02 - invisible coin blocks
;	03 - invisible note blocks
;	04 - invisible coins that become visible/active when P is hit
;	05 - coins
;	06 - background dirt
;	07 - water (tile 0003)
;	08 - note blocks
;	09 - turn blocks
;	0A - ? blocks with single coins
;	0B - throw blocks
;	0C - munchers
;	0D - cement blocks
;	0E - brown blocks
;	0F - vertical pipes (S = height + type)
;	10 - horizontal pipes (S = type + width)
;	11 - bullet shooter (S = height + unused)
;	12 - slopes (S = height + type)
;	13 - ledge edges (S = height + type)
;	14 - ground ledge
;	15 - midway point (S = height + type)
;	16 - blue coins
;	17 - rope/clouds (S = type + width)
;	18 - animated water surface
;	19 - still water surface
;	1A - animated lava surface
;	1B - net top edge
;	1C - donut bridge (S = unused + width)
;	1D - net bottom edge
;	1E - net vertical edge (S = height + type)
;	1F - vertical pipe/bone/log (S = height + unused)
;	20 - horizontal pipe/bone/log (S = unused + width)
;	21 - long ground ledge (S = width)
;
;	for all LM objects, S and byte count can vary (see below)
;	22 - LM: direct map16 page 0
;	23 - LM: direct map16 page 1
;	24 - LM: old FG/BG/SP bypass
;	25 - LM: old AN2 bypass
;	26 - LM: music bypass
;	27 - LM: direct map16 (any page)
;	28 - LM: time limit bypass
;	29 - LM: unused
;	2A - LM: unused
;	2B - LM: unused
;	2C - LM: unused
;	2D - LM: unused
;
;	for all tileset specific objects, S can vary (see below)
;	2E - tileset specific 1
;	2F - tileset specific 2
;	30 - tileset specific 3
;	31 - tileset specific 4
;	32 - tileset specific 5
;	33 - tileset specific 6
;	34 - tileset specific 7
;	35 - tileset specific 8
;	36 - tileset specific 9
;	37 - tileset specific 10
;	38 - tileset specific 11
;	39 - tileset specific 12
;	3A - tileset specific 13
;	3B - tileset specific 14
;	3C - tileset specific 15
;	3D - tileset specific 16
;	3E - tileset specific 17
;	3F - tileset specific 18


; extended object list:
;	00 - screen exit (4 bytes long, see below)
;	01 - screen jump (see below)
;	02 - screen exit v2 (see below)
;	03 - screen jump v2 (see below)
;	04 - unused
;	05 - unused
;	06 - unused
;	07 - unused
;	08 - unused
;	09 - unused
;	0A - unused
;	0B - unused
;	0C - unused
;	0D - unused
;	0E - unused
;	0F - unused
;	10 - small door
;	11 - invisible ? block with 1-up
;	12 - invisible note block
;	13 - top left corner edge tile 1
;	14 - top right corner edge tile 1
;	15 - small silver door (only visible with P)
;	16 - invisible ? block, becomes visible with P
;	17 - green star block
;	18 - 3-up moon
;	19 - invisible 1-up 1
;	1A - invisible 1-up 2
;	1B - invisible 1-up 3
;	1C - invisible 1-up 4
;	1D - red berry
;	1E - pink berry
;	1F - green berry
;	20 - constantly turning turn block
;	21 - bottom right of midway point (unused?)
;	22 - bottom right of midway point (unused?)
;	23 - note block (can contain a flower, feather, or star)
;	24 - ON/OFF block
;	25 - ? block with directional coins
;	26 - note block
;	27 - note block, bouncy on all sides
;	28 - brick (flower)
;	29 - brick (feather)
;	2A - brick (star)
;	2B - brick (star 2, 1-up, or vine)
;	2C - brick (multiple coins)
;	2D - brick (1 coin)
;	2E - brick (nothing)
;	2F - brick (P)
;	30 - ? block (flower)
;	31 - ? block (feather)
;	32 - ? block (star)
;	33 - ? block (star 2)
;	34 - ? block (multiple coins)
;	35 - ? block (key, wings, balloon, or shell)
;	36 - ? block (yoshi)
;	37 - ? block (shell)
;	38 - ? block (shell)
;	39 - brick, unbreakable (feather)
;	3A - top left corner edge tile 2
;	3B - top right corner edge tile 2
;	3C - top left corner edge tile 3
;	3D - top right corner edge tile 3
;	3E - top left corner edge tile 4
;	3F - top right corner edge tile 4
;	40 - translucent block
;	41 - yoshi coin
;	42 - top left slope
;	43 - top right slope
;	44 - purple triangle, left
;	45 - purple triangle, right
;	46 - midway point rope
;	47 - door
;	48 - invisible silver door (visible with P)
;	49 - ghost house exit
;	4A - climbing net door
;	4B - conveyor end tile 1
;	4C - conveyor end tile 2
;	4D-56 - line-guided shit
;	57-5A - switch palace tiles
;	5B-5E - bits of brick background
;	5F - large background area
;	60 - lava/mud top right corner edge
;	61-6F - ghost house objects
;	70-7E - canvas tiles (?)
;	7F - torpedo launcher
;	80 - ghost house entrance
;	81 - water weed
;	82 - big bush 1
;	83 - big bush 2
;	84 - castle entrance
;	85 - yoshi's house
;	86 - arrow sign
;	87 - ! block, green (feather)
;	88 - tree branch, left
;	89 - tree branch, right
;	8A - switch (green)
;	8B - switch (yellow)
;	8C - switch (blue)
;	8D - switch (red)
;	8E - ! block, yellow (mushroom)
;	8F - ghost house window
;	90 - boss door
;	91-96 - slope objects only used in vertical levels
;	97 - switch palace tiles
;	98-FF - unused




; screen exits, version 1:
;	these are 4 bytes each
;	---ppppp ----wush -------- dddddddd
;	ppppp	 - screen number
;	w	 - midway flag
;	u	 - LM flag
;	s	 - secondary exit flag
;	h	 - hi bit of destination level
;	dddddddd - destination level

; screen exits, version 2:
;	these are 5 bytes each
;	---ppppp -------- -------- dddddddd HHHHw--h
;	ppppp	 - screen number
;	w	 - water flag
;	HHHH	 - 0x1E00 bits of secondary exit number
;	h	 - 0x0100 bit of secondary exit number
;	dddddddd - 0x00FF bits of secondary exit number

; screen jumps, version 1:
;	---HHHHH ----VVVV --------
;	HHHHH	- horizontal screen number
;	VVVV	- vertical subscreen number / 2 (objects have 5 y bits, so this marks 32-tile jumps)

; screen jumps, version 2:
;	---VVVVV ----HHHH --------
;	VVVVV	- vertical subscreen number / 2 (same as above, but it can reach twice as far down)
;	HHHH	- horizontal screen number


