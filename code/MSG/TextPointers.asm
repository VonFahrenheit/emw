;=================;
;EXTENDED MESSAGES;
;=================;
; --Manual--
;
; pointer:
;	TO DO!!!
;
; text:
;	text is entered with db "text here" (including the citation marks)
;	the text engine automatically fits the text to the width of the window, meaning that you do not have to insert any line breaks
;	if you enter a long string on a single line, it will appear across multiple lines in-game
;	automatic line breaks replace the spaces in front of words that are too long to fit on the current line, meaning that words never start rendering on the wrong line before having to be moved
;	this also means that words will not be cut off by hitting the window border
;	basically, don't worry about it!
;	you can enter your text all on one line or on multiple lines, it makes no difference in-game
;	but what if you WANT to insert a line break at a specific point?
;	well, that brings us to...
;
; commands:
;	commands can let you do all sorts of things through the text engine
;	commands are used via macros. for example, the speed command (which changes the current text speed) is used by typing "%speed(X)", where X is the desired speed
;	each command corresponds to a certain byte, meaning that commands can also be inserted as db $XX
;	this has no impact in-game, but it is preferable to use the macros since they are more easily readable and also ensure that text data remain compatible after updates to MSG.asm
;	all commands placed before the text of a message will be processed before the message starts rendering
;	this area before the text is called the "header" of the message
;
;
; list of commands:
;	here is a list of the commands available, as well as all the information you'll need to use them
;
;	instantline()
;	- takes no input
;	- immediately renders the current line, regardless of text speed
;
;	linebreak()
;	- takes no input
;	- immediately ends the current line
;	- this command will also end the header if placed before any text, meaning that if it is part of the header it has to be the last command in the header
;
;	endmessage()
;	- takes no input
;	- immediately ends the message
;	- when the message is marked as ended, the window will close upon a player pressing a button
;
;	font(X)
;	- takes a value 0-15 ($00-$0F)
;	- loads the corresponding font
;	- only text rendered after the font update is affected
;
;	p2char(X)
;	- takes a value 0-15 ($00-$0F)
;	- sets player 2's character ID to the given value
;
;	p1char(X)
;	- takes a value 0-15 ($00-$0F)
;	- sets player 1's character ID to the given value
;
;	talk(X)
;	- takes a value 0-15 ($00-$0F)
;	- sets the talk variable to the given value
;	- does nothing on its own, this command is meant to be used with NPC sprites so they know when to display certain animations
;
;	speed(X)
;	- takes a value 0-15 ($00-$0F)
;	- sets text speed to the given value
;	- see "speeds" below for what each value corresponds to (0 is fastest, 15 is slowest)
;
;	clearbox()
;	- takes no input
;	- instantly clears the text box and resets rendering
;
;	music(XX)
;	- takes a value 0-255 ($00-$FF)
;	- stores the given value to the music port
;	- note that any value $80-$FE will fade out the music
;	- a value of $FF should not be used
;
;	portrait(XX, X)
;	- takes a value 0-63 ($00-$3F) and a value 0-1
;	- the first value is the portrait index, the second value is horizontal flip (0 = right side, 1 = left side)
;
;	scroll(XX)
;	- takes a value 0-255 ($00-$FF)
;	- the text will be scrolled up a number of lines equal to the given value
;	- because of this, only small values should be used normally, but you can use the value $FF to cause the message to scroll the exact distance to be just off-screen
;	- because of limited VRAM space, this command should not be used in cinematic mode
;
;	waitforinput()
;	- takes no input
;	- this will pause the text engine until a player pushes A/B/X/Y (after that happens the text engine resumes as usual)
;
;	delay(XX)
;	- takes a value 0-255 ($00-$FF)
;	- will pause the text engine for a number of frames equal to the given value
;	- during this time, player input is ignored
;
;	dialogue(X, XX, XX)
;	- this command allows the player to move a dialogue curser to give a response within the text box
;	- takes 3 inputs: options (0-3), type (0-63 / $00-$3F) and row (0-255 / $00-$FF)
;	- options is how many options the player can choose
;	- type determines what effect the player's choice will have, see below
;	- row determines which row the dialogue will start at
;	- each option is displayed on its own row
;	- note that this command only enables the arrow, the text itself must be written with the arrow in mind for it to look right in-game
;
;	next(XX)
;	- takes a value 0-255 ($00-$FF)
;	- links the current message to the one corresponding to the given value
;	- upon hitting an endmessage command, the window will be cleared and the linked message will immediately start rendering
;	- it is recommended to use the waitforinput and scroll commands to make this transition appear smoother
;
;	setexit(XX, XX)
;	- takes two values 0-255 ($00-$FF)
;	- the first value is written to the lo byte of the exit table (see $19B8 in the RAM map)
;	- the second value is written to the hi byte of the exit table (see $19D8 in the RAM map)
;	- this command can change where a door or pipe will lead, or set up for the triggerexit command
;
;	triggerexit()
;	- takes no input
;	- immediately triggers the exit enabled on the current screen
;	- if the setexit command was used previously, that exit will be used
;
;	endlevel(X)
;	- takes a value 0-1
;	- immediately ends the level
;	- if input was 0, the player simply leaves the level
;	- if input was 1, the player beats the level
;
;
;	headersettings(X, XX, XX, X, X, X, X)
;	- it is recommended to use this command in the message header only (before any text) as it changes how the window is rendered
;	- because this command is meant to be used from the header, it skips any input equal to 0
;	- see below for how to use one of these commands more freely
;	- 1st input: display type, 0 = normal mode, 1 = cinematic mode top of screen, 2 = cinematic mode bottom of screen
;	- 2nd input: message width in 8x8 tiles (0-31 / $00-$1F)
;	- 3rd input: vertical offset, window is moved up 2px for each unit here (0-63 / $00-$3F)
;	- 4th input: border settings, 0 = disable border, 1 = enable border
;	- 5th input: mode, 0 = pause game, 1 = pause physics but enable animations, 2 = enable everything
;	- 6th input: color to replace transparency with when rendering text (0 = transparency, 3 = white, 1-2 depend on the level palette)
;	- 7th input: important, 0 = message can be skipped with start, 1 = message can not be skipped with start
;
;	cinematic(X)
;	- takes a value 0-2
;	- 0 = normal mode, 1 = cinematic mode top of screen, 2 = cinematic mode bottom of screen
;
;	width(XX)
;	- takes a value 0-31 ($00-$1F)
;	- sets the text row rendering width to 8 * the given value
;
;	verticaloffset(XX)
;	- takes a value 0-63 ($00-$3F)
;	- moves the window up by a number of pixels equal to 2 * the given value
;
;	border(X)
;	- takes a value 0-1
;	- 0 = disable border, 1 = enable border
;	- this command is usually used with color(0)
;
;	mode(X)
;	- takes a value 0-2
;	- 0 = pause game, 1 = pause physics but enable animations, 2 = enable everything
;
;	color(X)
;	- takes a value 0-3
;	- the given value replaces transparency during text rendering
;	- this command is usually used with border(0)
;
;	important(X)
;	- takes a value 0-1
;	- 0 = player can skip this message with start, 1 = player can not skip this message with start
;	- this is useful for making some text boxes unskippable, which should only be done if it's necessary
;
;
; speeds:
; 0 - 1 row per frame
; 1 - 1 word per frame
; 2 - 7 characters per frame
; 3 - 6 characters per frame
; 4 - 5 characters per frame
; 5 - 4 characters per frame
; 6 - 3 characters per frame
; 7 - 2 characters per frame
; 8 - 1 character per frame
; 9 - 1 character every 2 frames
; A - 1 character every 3 frames
; B - 1 character every 4 frames
; C - 1 character every 5 frames
; D - 1 character every 6 frames
; E - 1 character every 7 frames
; F - 1 character every 8 frames
; 10+ - invalid, do not use
;
; NOTE!! If you are using a dialogue pointer, the message must end with $E8,$FF rather than just $FF!
;
; dialogue type:
; 0 - option is used as next(X), allowing it to link to various other messages
; 1 - option is written to !Level+2, allowing it to link to level code functions
; 2+- currently unused
;
;
;
;

;==============;
;COMMAND MACROS;
;==============;
macro font(index)
	if <index> < 16
		db $A0|<index>
		endif
		endmacro

macro p2char(char)
	if <char> < 16
		db $B0|<char>
		endif
		endmacro

macro p1char(char)
	if <char> < 16
		db $C0|<char>
		endif
		endmacro

macro talk(value)
	if <value> < 16
		db $D0|<value>
		endif
		endmacro

macro speed(value)
	if <value> < 16
		db $E0|<value>
		endif
		endmacro

macro clearbox()
		db $F2
		endmacro

macro music(song)
		db $F3,<song>
		endmacro

macro portrait(index, xflip)
		db $F4
	if <xflip> == 0
		db <index>
	else
		db <index>|$40
		endif
		endmacro

macro scroll(lines)
		db $F5,<lines>
		endmacro

macro waitforinput()
		db $F6
		endmacro

macro delay(frames)
		db $F7,<frames>
		endmacro

macro dialogue(options, type, row)
		db $F8
		db (<options>&3)|(<type><<2)
		db <row>
		endmacro

macro next(message)
		db $F9,<message>
		endmacro

macro setexit(lo, hi)
		db $FA
		db <lo>
		db <hi>
		endmacro

macro triggerexit()
		db $FB
		endmacro

macro endlevel(parameters)
		db $FC,<parameters>
		endmacro

macro instantline()
		db $FD
		endmacro

macro linebreak()
		db $FE
		endmacro

macro endmessage()
		db $FF
		endmacro


;======================;
;HEADER SETTINGS MACROS;
;======================;
macro headersettings(cinematic, width, verticaloffset, border, mode, color, important)
		db $F0			; start macro
	if <cinematic> != 0
		db $00,<cinematic>
		endif
	if <width> != 0
		db $01,<width>
		endif
	if <verticaloffset> != 0
		db $02,<verticaloffset>
		endif
	if <border> != 0
		db $03,<border>
		endif
	if <mode> != 0
		db $04,<mode>
		endif
	if <color> != 0
		db $05,<color>
		endif
	if <important> != 0
		db $06,<important>
		endif
		db $FF			; end macro
		endmacro

macro cinematic(setting)
		db $F0
		db $00,<setting>
		db $FF
		endmacro

macro width(setting)
		db $F0
		db $01,<setting>
		db $FF
		endmacro

macro verticaloffset(setting)
		db $F0
		db $02,<setting>
		db $FF
		endmacro

macro border(setting)
		db $F0
		db $03,<setting>
		db $FF
		endmacro

macro mode(setting)
		db $F0
		db $04,<setting>
		db $FF
		endmacro

macro color(setting)
		db $F0
		db $05,<setting>
		db $FF
		endmacro

macro important(setting)
		db $F0
		db $06,<setting>
		db $FF
		endmacro


;==========================;
;MAIN POINTER (DON'T TOUCH);
;==========================;
Text:
.MainPtr
dw .L000,.L001
dw .L002,.L003
dw .L004,.L005
dw .L006,.L007
dw .L008,.L009
dw .L00A,.L00B
dw .L00C,.L00D
dw .L00E,.L00F
dw .L010,.L011
dw .L012,.L013
dw .L014,.L015
dw .L016,.L017
dw .L018,.L019
dw .L01A,.L01B
dw .L01C,.L01D
dw .L01E,.L01F
dw .L020,.L021
dw .L022,.L023
dw .L024

dw .L101,.L102
dw .L103,.L104
dw .L105,.L106
dw .L107,.L108
dw .L109,.L10A
dw .L10B,.L10C
dw .L10D,.L10E
dw .L10F,.L110
dw .L111,.L112
dw .L113,.L114
dw .L115,.L116
dw .L117,.L118
dw .L119,.L11A
dw .L11B,.L11C
dw .L11D,.L11E
dw .L11F,.L120
dw .L121,.L122
dw .L123,.L124
dw .L125,.L126
dw .L127,.L128
dw .L129,.L12A
dw .L12B,.L12C
dw .L12D,.L12E
dw .L12F,.L130
dw .L131,.L132
dw .L133,.L134
dw .L135,.L136
dw .L137,.L138
dw .L139,.L13A
dw .L13B


;===================;
;LEVEL TEXT POINTERS;
;===================;

.L000	dw .Survivor_Talk_1			; 01


	dw .Tinker_Talk_1			; 02
	dw .Mario_Upgrade_1			; 03
	dw .Mario_Upgrade_2			; 04
	dw .Mario_Upgrade_3			; 05
	dw .Mario_Upgrade_4			; 06
	dw .Mario_Upgrade_5			; 07
	dw .Mario_Upgrade_6			; 08
	dw .Mario_Upgrade_7			; 09
	dw .Luigi_Upgrade_1			; 0A
	dw .Luigi_Upgrade_2			; 0B
	dw .Luigi_Upgrade_3			; 0C
	dw .Luigi_Upgrade_4			; 0D
	dw .Luigi_Upgrade_5			; 0E
	dw .Luigi_Upgrade_6			; 0F
	dw .Luigi_Upgrade_7			; 10
	dw .Kadaal_Upgrade_SenkuControl		; 11
	dw .Kadaal_Upgrade_AirSenku		; 12
	dw .Kadaal_Upgrade_SenkuSmash		; 13
	dw .Kadaal_Upgrade_ShellSpin		; 14
	dw .Kadaal_Upgrade_LandSlide		; 15
	dw .Kadaal_Upgrade_ShellDrill		; 16
	dw .Kadaal_Upgrade_SturdyShell		; 17
	dw .Leeway_Upgrade_ComboSlash		; 18
	dw .Leeway_Upgrade_AirDash		; 19
	dw .Leeway_Upgrade_AirDashPlus		; 1A
	dw .Leeway_Upgrade_ComboAirSlash	; 1B
	dw .Leeway_Upgrade_HeroicCape		; 1C
	dw .Leeway_Upgrade_DinoGrip		; 1D
	dw .Leeway_Upgrade_StarStrike		; 1E
	dw .Alter_Upgrade_1			; 1F
	dw .Alter_Upgrade_2			; 20
	dw .Alter_Upgrade_3			; 21
	dw .Alter_Upgrade_4			; 22
	dw .Alter_Upgrade_5			; 23
	dw .Alter_Upgrade_6			; 24
	dw .Alter_Upgrade_7			; 25
	dw .Peach_Upgrade_1			; 26
	dw .Peach_Upgrade_2			; 27
	dw .Peach_Upgrade_3			; 28
	dw .Peach_Upgrade_4			; 29
	dw .Peach_Upgrade_5			; 2A
	dw .Peach_Upgrade_6			; 2B
	dw .Peach_Upgrade_7			; 2C


	dw .MarioSwitch				; 2D
	dw .LuigiSwitch				; 2E
	dw .KadaalSwitch			; 2F
	dw .LeewaySwitch			; 30
	dw .AlterSwitch				; 31
	dw .PeachSwitch				; 32

	dw .Toad1				; 33




.L001	dw .MushroomGorge_Sign_1		; 01


.L002	dw .RexVillage_Sign_1			; 01
	dw .RexVillage_Sign_2			; 02
	dw .RexVillage_Rex_1			; 03


.L003	dw .DinolordsDomain_Sign_1		; 01
	dw .DinolordsDomain_Sign_2		; 02
	dw .CaptainWarrior_Fight1_Intro_1	; 03
	dw .CaptainWarrior_Fight1_Defeated	; 06
	dw .CaptainWarrior_Fight1_Leeway	; 07


.L004
.L005	dw .CastleRex_Sign_1			; 01
	dw .CastleRex_Sign_2			; 02
	dw .CastleRex_Rex_Warning_1		; 03
	dw .CastleRex_Rex_Warning_2		; 05
	dw .CastleRex_Rex_Warning_3		; 06
	dw .CaptainWarrior_Warning		; 08

.L006
.L007

;	dw .MountainKingA		; 01
;	dw .MountainKingB		; 02
;	dw .MountainKing1		; 03
;	dw .MountainKing2		; 04
;	dw .MountainKing3		; 05
;	dw .MountainKing4		; 06
;	dw .MountainKing5		; 07
;	dw .MountainKing6		; 08

.L008
.L009
.L00A
.L00B
.L00C
.L00D




.L00E

;	dw .TowerOfStorms_Sign_1	; 01
;	dw .TowerOfStorms_Sign_2	; 02
;	dw .LakituLovers_Intro		; 03
;	dw .LakituLovers_Impress_1	; 04
;	dw .LakituLovers_Almost_1	; 05
;	dw .LakituLovers_Enrage_1	; 06
;	dw .LakituLovers_Respect	; 07
;	dw .LakituLovers_Impress_2	; 08
;	dw .LakituLovers_Almost_2	; 09
;	dw .LakituLovers_Enrage_2	; 0A
;	dw .LakituLovers_Death		; 0B


.L00F
.L010
.L011
.L012
.L013
.L014
.L015
.L016
.L017
.L018
.L019
.L01A
.L01B
.L01C
.L01D
.L01E
.L01F
.L020
.L021
.L022
.L023
.L024

.L101
.L102
.L103
.L104
.L105
.L106
.L107
.L108
.L109
.L10A
.L10B
.L10C
.L10D
.L10E
.L10F
.L110
.L111
.L112
.L113
.L114
.L115
.L116
.L117
.L118
.L119
.L11A
.L11B
.L11C
.L11D
.L11E
.L11F
.L120
.L121
.L122
.L123
.L124
.L125
.L126
.L127
.L128
.L129
.L12A
.L12B
.L12C
.L12D
.L12E
.L12F
.L130
.L131
.L132
.L133
.L134
.L135
.L136
.L137
.L138
.L139


.L13A	dw .FoundLuigi			; 01



.L13B	dw .Menu_EasyMode		; 01
	dw .Menu_NormalMode		; 02
	dw .Menu_InsaneMode		; 03

	dw .Menu_TimeMode		; 04
	dw .Menu_RankMode		; 05
	dw .Menu_CriticalMode		; 06
	dw .Menu_IronmanMode		; 07
	dw .Menu_Hardcore		; 08
























