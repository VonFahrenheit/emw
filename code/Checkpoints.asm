;
;
;	$05D9D7 is where the game checks for the midway flag
;	Lunar Magic inserts the following code at $05DCE0:
;		CMP #$25
;		BCC $03 : SBC #$24 : INY
;		STA $77BB
;		STA $0E
;		TYA
;		RTL
;
;		As soon as it returns, A is stored to $0F, making $0E hold the 16-bit level number to be loaded.
;		If I can hijack this, I win.



CHECKPOINTS:
	pushpc
	org $05DCE7
		JML .Main		;\ Org: STA $770B : STA $0E (inserted by Lunar Magic)
		NOP			;/

	org $0DA691
		JSL .Load		; Org: LDA.l !LevelTable,x
	org $0DA699
		BRA $03 : NOP #3	; Org: LDA $73CE : BNE $12
	pullpc
	.Main
		STA $770B
		STA $0E
		TYA
		STA $0F
		PHX
		PHP
		SEP #$10
		LDX !Translevel
		BIT !LevelTable,x : BVC .Return
		LDA !MidwayLo,x : STA $0E		; Load new level
		LDA !MidwayHi,x : TAY

	.Return	PLP
		PLX
		RTL


	.Load
		LDA.l !LevelTable,x
		AND #$40 : BEQ .R
		PEI ($00)
		LDA !MidwayLo,x : STA $00
		LDA !MidwayHi,x : STA $01

		REP #$20
		LDA.l !Level
		CMP $00 : BEQ .Hide
	.Show	PLA : STA $00
		SEP #$20
		LDA #$00
	.R	RTL

	.Hide	PLA : STA $00
		SEP #$20
		LDA #$40
		RTL		



