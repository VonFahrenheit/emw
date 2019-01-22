; --Defines--

	!CastleNumber	= $00			; Determines what castle this yoshi is rescued from.
	!CastleTable	= $00C9A7		; Location of table that determines what levels are castles.
	!LevelTable	= $1EA2			; Location of RAM rable that holds level data.
	!YoshiCode	= $138020		; This has to be adjusted to fit the patch!


;============;
;INIT ROUTINE;
;============;

print "INIT ",pc

INITCODE:	PHX				; Preserve sprite index
		LDX #!CastleNumber		; X = Castle number
		LDA !CastleTable,x		; Ensure OW compatibility
		PLX				; X = sprite index
		TAY				; Y = Translevel number of castle
		LDA !LevelTable,y		;\ Erase sprite if level is not beaten
		BPL .Erase			;/
		LDA #!CastleNumber		;\ Store castle number to $C2
		STA $C2,x			;/
		RTL

.Erase		STZ $14C8,x			; Erase sprite
		RTL

;============;
;MAIN ROUTINE;
;============;

print "MAIN ",pc

MAINCODE:	JML !YoshiCode			; The Yoshis have such similar code; I think this is best.