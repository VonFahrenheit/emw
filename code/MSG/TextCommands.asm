;=================;
;EXTENDED MESSAGES;
;=================;
; --Manual--
;
; pointer:
;	TO DO!!!
;
; text:
;	text is entered with db "type whatever text you want here" (including the citation marks, but whatever is between them is up to you)
;	the text engine automatically fits the text to the width of the window, meaning that you do not have to insert any line breaks
;	if you enter a long string on a single line, it will appear across multiple lines in-game
;	automatic line breaks replace the spaces in front of words that are too long to fit on the current line, meaning that words never start rendering on the wrong line before having to be moved
;	this also means that words will not be cut off by hitting the window border
;	basically, don't worry about it!
;	you can enter your text all on one line or on multiple lines, it makes no difference in-game
;	but what if you WANT to insert a line break at a specific point, regardless of the window border?
;	well, that brings us to...
;
; commands:
;	commands can let you do all sorts of things through the text engine
;	commands are used via macros. for example, the speed command (which changes the current text speed) is used by typing "%speed(X)", where X is the desired speed
;	each command corresponds to a certain byte, meaning that commands can also be inserted as db $XX
;	this has no impact in-game, but it is preferable to use the macros since they are more easily readable and also ensure that text data remain compatible after updates to MSG.asm
;	all commands placed before the first text of a message will be processed before the message starts rendering
;	this area before the text is called the "header" of the message
;	commands that affect rendering (such as border, cinematic, fillercolor, and so on) should almost always be placed in the header
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
;	newsection()
;	- can also be shortened to n()
;	- takes no input
;	- waits for player input, then scrolls all text off-screen, then clears the box
;	- it's effectively %waitforinput() and %scrollfull() in one command, but using this one is better since it makes text data smaller
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
;	portrait(name, side)
;	- takes a character name (starts with upper case), and a side
;	- side is "right" or "left"
;	- uses the neutral version of a portrait
;
;	noportrait()
;	- takes no input
;	- removes portrait
;
;	expression(name, expression, side)
;	- takes a character name (starts with upper case), an expression, and a side
;	- side is "right" or "left"
;	- expressions: "neutral", "happy", "angry", "distressed", "sad"
;	- this command will display a variation of a portrait
;
;	playerportrait(side)
;	- takes a side
;	- side is "right" or "left"
;	- loads the portrait of the character currently in play
;	- uses the neutral expression
;
;	playerexpression(expression, side)
;	- takes an expression and a side
;	- side is "right" or "left"
;	- loads the portrait of the character currently in play, with the specified expression
;	- expressions: "neutral", "happy", "angry", "distressed", "sad"
;
;	scroll(XX)
;	- takes a value 0-255 ($00-$FF)
;	- the text will be scrolled up a number of lines equal to the given value
;	- because of this, only small values should be used normally, but you can use the value $FF to cause the message to scroll the exact distance to be just off-screen
;	- because of limited VRAM space, this command should not be used in cinematic mode
;
;	scrollfull()
;	- takes no input
;	- scrolls all text off-screen, then clears box
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
;	dialogue(X, XX)
;	- this command allows the player to move a dialogue curser to give a response within the text box
;	- takes 2 inputs: options (0-3) and type (0-63 / $00-$3F)
;	- options is how many options the player can choose, -1 (0 = 1 option, 1 = 2 options, etc, max 4 options)
;	- type determines what effect the player's choice will have (see below)
;	- each option is displayed on its own row
;	- note that this command only enables the arrow, the text itself must be written with the arrow in mind for it to look right in-game
;	  (with most fonts, adding 3 spaces at the start of the line will make enough room for the arrow)
;	- this command should be entered at the start of the text row holding the first line of dialogue option text
;	  example:
;		db "Question?"
;		%dialogue(2, 0)
;		db "   Answer 1"
;		db "   Answer 2"
;		db "   Answer 3"
;		%endmessage()
;
;	- types:
;		- 0: next message, player's choice is added to current message ID
;
;
;
;	next(MSG)
;	- takes a MSG name
;	- links the current message to the one specified
;	- upon hitting an endmessage command, the window will be cleared and the linked message will immediately start rendering
;	- it is recommended to use the waitforinput and scroll commands to make this transition appear smoother
;
;	playernext()
;	- takes no input
;	- same as next, but adds the player character number to the current message
;	- mario will load the next message, luigi the one after that, and so on
;	- order is:
;		mario	+1
;		luigi	+2
;		kadaal	+3
;		leeway	+4
;		alter	+5
;		peach	+6
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
;	- 0 = pause game, 1 = pause physics but enable animations, 2 = don't pause anything
;
;	color(X)
;	- takes a value 0-3
;	- the given value replaces transparency during text rendering
;	- this command is usually used with border(0)
;
;	important(X)
;	- takes a value 0-2
;	- 0 = player can skip this message with start
;	- 1 = player can not skip this message with start
;	- 2 = player can not skip this message with start and can not increase text speed with A/B/Y/X
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
; 8 - 1 character per frame (DEFAULT)
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
; (this might be incorrect)
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
		db $90|<index>
		endif
		endmacro

macro p2char(char)
	if <char> < 16
		db $A0|<char>
		endif
		endmacro

macro p1char(char)
	if <char> < 16
		db $B0|<char>
		endif
		endmacro

macro talk(value)
	if <value> < 16
		db $C0|<value>
		endif
		endmacro

macro speed(value)
	if <value> < 16
		db $D0|<value>
		endif
		endmacro

macro cinematic(setting)
		db $E0,<setting>
		endmacro

macro width(setting)
	if <setting> < 32
		db $E1,<setting>
	else
		db $E1,$1F
	endif
		endmacro

macro verticaloffset(setting)
	if <setting> < 64
		db $E2,<setting>
	else
		db $E2,$3F
	endif
		endmacro

macro borderon()
		db $E3
		endmacro

macro borderoff()
		db $E4
		endmacro

macro mode(setting)
		db $E5,<setting>
		endmacro

macro color(setting)
		db $E6,<setting>
		endmacro

macro important(setting)
		db $E7,<setting>
		endmacro

macro n()
		db $F0
		endmacro

macro newsection()
		db $F0
		endmacro

macro clearbox()
		db $F2
		endmacro

macro music(song)
		db $F3,<song>
		endmacro

macro portrait(index, side)
		db $F4
	if !<side> == 0
		db !port_<index>
	else
		db !port_<index>|$40
		endif
		endmacro

macro noportrait()
		db $F4,$00
		endmacro

macro expression(index, expression, side)
		db $F1
	if !<side> == 0
		db !port_<index>
	else
		db !port_<index>|$40
		endif
		db !<expression>
		endmacro

macro playerportrait(side)
	if !<side> == 0
		db $EC
	else
		db $ED
		endif
		endmacro

macro playerexpression(expression, side)
	if !<side> == 0
		db $EE
	else
		db $EF
		endif
		db !<expression>
		endmacro

macro scroll(lines)
		db $F5,<lines>
		endmacro

macro scrollfull()
		db $F5,$FF
		db $F2
		endmacro

macro waitforinput()
		db $F6
		endmacro

macro delay(frames)
		db $F7,<frames>
		endmacro

macro dialogue(options, type)
		db $F8
		db (<options>&3)|(<type><<2)
		endmacro

macro next(message)
		db $F9
		dw !MSG_<message>
		endmacro

macro playernext()
		db $EB
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


