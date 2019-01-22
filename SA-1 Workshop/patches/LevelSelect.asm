

	namespace LevelSelect


; This should be included from SP_Patch.asm

; OW game mode starts at $00A1BE
; Its structure is as follows:
;	- JSR to $009A77 (set up $0DA0, a controller address)
;	- Increment main frame counter ($14)
;	- Erase sprite tiles
;	- Call main system ($048241)
;		- $8241: some debug stuff (I'm actually using this)
;		- $8275: dialogue box
;		- $8295: look around map code
;		- $829E: camera and cutscene stuff
;		- $8576: pointer jump based on $13D9 (includes Mario movement)
;		- $F708: OW sprites
;		- $862E: draw player
;
;	- Go to $008494 (build hi OAM table)

; $048295 seems to be the best place to hijack.
;
; All OW sprite tables can be used since I'm killing OW sprites
; $6DDF-$6EE5 is free to be used for this.
; The maximum number that can be added to !LevelSelectBase is +$106

	!LevelSelectBase	=	$6DDF

	!MenuPosition		=	!LevelSelectBase+$000
	!ButtonMatrix		=	!LevelSelectBase+$001	; 1 byte for each button (total 1)

	pushpc
	org $048295
		JML MENU		; 9 bytes total
		NOP #5


	org $04840A
		JSR $8576
		NOP #6

	org $04862E
		RTS			;\ Org: REP #$20
		NOP			;/

	pullpc
	MENU:
		LDA #$01 : STA !ButtonMatrix+0		; Realm 1
		REP #$20
		STZ !ButtonMatrix+1			; Realm 2, 3
		STZ !ButtonMatrix+3			; Realm 4, 5
		STZ !ButtonMatrix+5			; Realm 6, 7
		LDA #$0100 : STA !ButtonMatrix+7	; Realm 8, Base
		XBA : STA !ButtonMatrix+9		; Hero, World
		SEP #$20
		LDY #$06				;\
		LDX #$01				; |
		LDA !StoryFlags+$00			; |
		BPL +					; |
		STX !ButtonMatrix+$A			; | Generate button matrix
	+						; |
	-	LSR A : BCC +				; |
		PHA					; |
		TXA					; |
		STA !ButtonMatrix+1,y			; |
		PLA					; |
	+	DEY : BPL -				;/




		LDA !MenuPosition
		LDY $6DA6
		CPY #$01 : BEQ .Right
		CPY #$02 : BEQ .Left
		CPY #$04 : BEQ .Down
		CPY #$08 : BNE .NoInput

	.Up	CMP #$08 : BCS .NoInput			;\
		CMP #$04 : BCC ..ToEx			; | 
		SEC : SBC #$04				; |
		BRA .InputDir				; |
	..ToEx	CLC : ADC #$08				; |
		LDY !ButtonMatrix+$A : BEQ +		; | Handle up input
		CMP #$0A				; |
		BCC $02 : LDA #$0A			; |
		BRA .InputDir				; |
	+	CMP #$09				; |
		BCC $02 : LDA #$09			; |
		BRA .InputDir				;/

	.Down	CMP #$08 : BCS ..ToLvl			;\
		CMP #$04 : BCS .NoInput			; |
		CLC : ADC #$04				; |
		BRA .InputDir				; |
	..ToLvl	SEC : SBC #$08				; | Handle down input
	-	TAY					; |
		LDX !ButtonMatrix,y : BNE .InputDir	; |
		DEC A					; |
		BRA -					;/

	.Left	DEC A : BMI .NoInput			;\
		CMP #$03 : BEQ .NoInput			; | Handle left input
		CMP #$07 : BEQ .NoInput			; |
		BRA .InputDir				;/

	.Right	INC A					;\
		CMP #$04 : BEQ .NoInput			; |
		CMP #$08 : BEQ .NoInput			; | Handle right input
		CMP #$0A : BEQ .NoInput			; |
		TAY					; |
		LDX !ButtonMatrix,y : BEQ .NoInput	;/

		.InputDir
		STA !MenuPosition

		.NoInput
		LDA !MultiPlayer
		BEQ ..P1
	..P2	LDA $6DA7
	..P1	ORA $6DA6
		BPL .NoButton

		LDA !MenuPosition
		CMP #$08 : BCC .Map
		BEQ .Base
		CMP #$09 : BEQ .Hero

	.World	; Not sure what this should do yet

	.Hero	; Not sure HOW to do this currently ._.

	.Base	JSL LOAD_HIDEOUT_Main
		BRA .NoButton

	.Map






		.NoButton





	; positions:
	;	00-07: Realms
	;	08: Base
	;	09: Characters
	;	0A: World


	; press right:
	;	add 1, unless pointer is at rightmost limit
	; press left:
	;	subtract 1, unless pointer is at leftmost limit
	; press down:
	;	add 4 on high row
	;	funnel down on extra row
	; press up:
	;	subtract 4 on low row
	;	funnel up on high row



	; Add this:
	;	- check for P2 to join (pushing start prompts the character select)
	;	- P1 always controls the menu but if multiplayer is on, P2 also controls the menu at the same time
	;	- Spawn point select, along with a BG3 map of each realm
	;	- Base button
	;	- Hero button: whoever presses it can change their character
	;	- World button (doesn't need to be functional right away, but it needs to exist)




		JML $048356




	MapData:
	.1
		db $00,$00,$00,$00	; header 1
		db $00






	namespace off