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
;	portrait(name, X)
;	- takes a character name (starts with upper case) and a value 0-1
;	- the first value is the portrait index, the second value is horizontal flip (0 = right side, 1 = left side)
;
;	noportrait()
;	- takes no input
;	- removes portrait
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
		db !port_<index>
	else
		db !port_<index>|$40
		endif
		endmacro

macro noportrait()
		db $F4,$00
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
		dw <message>
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


