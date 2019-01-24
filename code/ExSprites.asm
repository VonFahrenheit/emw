@includefrom sa1.asm

	!ExSpriteNum		= $3140

	!ExSpriteXLo		= $7699
	!ExSpriteXHi		= $76B9
	!ExSpriteXSpeed		= $76D9
	!ExSpriteXFraction	= $76F9
	!ExSpriteYLo		= $7619
	!ExSpriteYHi		= $7639
	!ExSpriteYSpeed		= $7659
	!ExSpriteYFraction	= $7679
	!ExSpriteTimer		= $7699
	!ExSpriteMisc1		= $77C0
	!ExSpriteMisc2		= $77E0
	!ExSpriteGFX		= $7800
	!ExSpriteProp		= $7820



	10 extended sprites

	4 bounce sprites

	8 shooters

	4 coin sprites

	6 score sprites

	12 minor extended sprites

	4 smoke sprites


org $00FAD4
	LDY #$1B			; [all slots] - [fireball slots] - 1
	LDA #$00
	STA !ExSpriteNum,y

org $00FD19
	LDX #$1B
	LDA !ExSpriteNum,x

org $00FD26
	LDA #$12			; Water bubble
	STA !ExSpriteNum,x

org $00FE05
	LDA !ExSpriteNum,y

org $00FE16
	LDA #$12			; Water bubble
	STA !ExSpriteNum,y

org $00FEA8
	LDX #$1F			; Highest index
	LDA !ExSpriteNum,x
	BEQ $06
	DEX
	CPX #$1D			; Highest illegal index

org $00FEBF
	LDA #$05			; Mario fireball
	STA !ExSpriteNum,x


	00 - Free slot
	01 - Puff of smoke 1
	02 - Reznor fireball
	03 - Little flame (left by hopping flame)
	04 - Hammer
	05 - Player fireball
	06 - Bone from dry bones
	07 - Lava splash
	08 - Torpedo Ted shooter's arm
	09 - Shooter
	0A - Coin from coin cloud game
	0B - Pirahna Plant fireball
	0C - Lava Lotus fireball
	0D - Baseball
	0E - Wiggler's flower
	0F - Yellow Yoshi stomp smoke
	10 - Spinjump stars
	11 - Yoshi fireballs
	12 - Water bubble

	13 - Moving turn block
	14 - Note block
	15 - ?Block
	16 - Sideways bouncing block (?)
	17 - Translucent block
	18 - On/Off block
	19 - Spinning turn block

	1A - Coin from block

	1B - 10 pts
	1C - 20 pts
	1D - 40 pts
	1E - 80 pts
	1F - 100 pts
	20 - 200 pts
	21 - 400 pts
	22 - 800 pts
	23 - 1000 pts
	24 - 2000 pts
	25 - 4000 pts
	26 - 8000 pts
	27 - 1up
	28 - 2up
	29 - 3up

	2A - Puff of smoke 2
	2B - Contact GFX
	2C - Turn smoke
	2D - Glitter sprite

	2E - Piece of brick
	2F - Small star
	30 - Cracked shell (Yoshi egg)
	31 - Flame from jumping fireball (Podoboo)
	32 - Blue sparkle
	33 - Z (Rip Van Fish)
	34 - Water splash
	35 - Boo stream tail
	36 - Puff of smoke 3
















