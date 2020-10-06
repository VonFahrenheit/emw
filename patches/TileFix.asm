header
sa1rom

incsrc "Defines.asm"

!UnusedTile = $FF
;Set this to an unused tile.
;"Used" means "used 8x8 tile, or top left part of a used 16x16 tile", other parts of 16x16 tiles are considered free in this case.
;It should be free on both page 2xx and 3xx (3xx and 4xx if you're using LM17 or higher).
;If you're using a custom graphics routine (aka not JSLing to anything from the original SMW), it's safe to use this tile.


macro FillTwo(addr)
org <addr>
db !UnusedTile,!UnusedTile
endmacro

%FillTwo($019BC1)
%FillTwo($019BC5);jumping piranha plant

%FillTwo($019C25);springboard

;%FillTwo($01DEE5)
;%FillTwo($01DEEB)
;%FillTwo($01DEF1);bonus game
;%FillTwo($01DEF7)
;%FillTwo($01DEFD)
;there was also a reference to $01DF03 here, but there's no 69 or 83 there. how does that make sense

org $02AD4D
db !UnusedTile,!UnusedTile,!UnusedTile,!UnusedTile;score


; Fix contact GFX
org $0297C1
	BRA +
	NOP #10
	+
org $0297D6
	BRA +
	NOP #10
	+
org $0297F1
	BRA +
	NOP #16
	+
	LDA #$6C
	STA !OAM+$002,y
	BRA +
org $029825
	+
org $029829
	LDA #$02
	STA !OAMhi,y
	RTS


org $019D39
autoclean JSL HijackStdTable11
NOP
NOP

org $019D8F
JSL HijackStdTable11
NOP
NOP
org $019D95
JSL HijackStdTable22
NOP
NOP

org $019DF3
JSL HijackStdTable21;These edits the standard tile table so tile FF means "do not add a tile here".
NOP
NOP
org $019DF9
JSL HijackStdTable12
NOP
NOP

org $019F24
JSL HijackStdTable11
NOP
NOP

org $02AEC5
JSL HijackScoreStuff
NOP
NOP

org $01DF74
JML HijackBonusStuff

freecode

HijackStdTable11:
	LDA $9B83,x
CheckDeleteOam1:
	CMP #!UnusedTile : BEQ .Delete
	STA !OAM+$102,y
	RTL
	.Delete
	LDA #$EF	;if you wonder why I'm using EF instead of F0, it's to mark them used in the eyes of the no more sprite tile limits patch.
	STA !OAM+$101,y	;Slots after those might be used.
	RTL

HijackStdTable12:
	LDA $9B84,x
	BRA CheckDeleteOam1

HijackStdTable21:
	LDA $9B83,x
CheckDeleteOam2:
	CMP #!UnusedTile : BEQ .Delete
	STA !OAM+$106,y
	RTL
	.Delete
	LDA #$EF
	STA !OAM+$105,y
	RTL

HijackStdTable22:
	LDA $9B84,x
	BRA CheckDeleteOam2

HijackScoreStuff:
LDA $AD4C,x
CMP #!UnusedTile
BEQ .Delete
STA !OAM+$002,y
RTL

.Delete
LDA #$EF
STA !OAM+$001,y
RTL

HijackBonusStuff:
macro BonusThing(id)
LDA.w $DEE3+<id>,x
CMP #$83
BEQ +
STA.w <id>*4+!OAM+$102,y
BRA ++
+
LDA #$F0
STA.w <id>*4+!OAM+$101,y
++
endmacro
%BonusThing(0)
%BonusThing(1)
%BonusThing(2)
%BonusThing(3)
JML $01DF8C
