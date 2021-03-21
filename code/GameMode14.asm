;====================;
;GAME MODE 14 REWRITE;
;====================;

GAMEMODE14:

		LDA !MsgTrigger : BEQ .NoMSG
		JML read3($00A1DF+1)		; go to MSG
		RTS
		.NoMSG

	; disable down and X/Y during animations and level end
		LDA !MarioAnim
		ORA !LevelEnd
		BEQ +
		LDA #$04 : TRB $15
		LDA #$40
		TRB $16
		TRB $18
		+


	; optimized pause code
		LDA !PauseTimer : BEQ .CheckPause
		DEC !PauseTimer
		BRA .CheckSelect

		.CheckPause
		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status-$80 : BNE .notP1
	.notP1	LDA !P2Status : BNE .PauseDone
	.P2	LDA $6DA7
		BRA .W
	.both	LDA $6DA7
	.P1	ORA $6DA6
	.W	STA $00
		AND #$10 : BEQ .CheckSelect
		LDA !Pause
		EOR #$01
		STA !Pause
		EOR #$01
		CLC : ADC #$11
		STA !SPC1
		LDA #$3C : STA !PauseTimer

		.CheckSelect
		LDA !Pause : BEQ .PauseDone
		LDA $00
		AND #$20 : BEQ .PauseDone
		LDX !Translevel
		LDA !LevelTable1,x : BPL .PauseDone
		LDA #$0B : STA !GameMode
		.PauseDone

		LDA !Pause : BNE +			; see if paused
		LDA !MsgTrigger : BEQ ++		; > always clear if there's no message box
		LDA !WindowDir : BNE +			; > don't clear while window is closing
		LDA.l !MsgMode				;\
		BNE +					; | don't clear OAM during !MsgMode non-zero
	++	JSL !KillOAM				;/
		+

	; calls
		JSR MAIN_Level

		JSL $00F6DB				; scroll code
		JSL $05BC00				; scroll sprites
		JSL read3($00A2A5+1)			; use LM's version of vanilla animation
		PEI ($1C)				; push BG1 Y
		REP #$20
		STZ $7888				;
		LDA $7887 : BEQ .noshake		; note that 88 was JUST cleared so hi byte is fine
		DEC $7887
		AND #$0003
		ASL A
		TAY
		LDA $A1CE,y : STA $7888
		BIT $6BF4
		BVC $02 : DEC #2
		STA $7888
		CLC : ADC $1C
		STA $1C
		.noshake
		SEP #$20
		JSL $008E1A				; status bar (added JSL/RTL wrapper at the start)
		JSL $00E2BD				; mario stuff
		REP #$20				;\
		LDA !MarioXPos : STA $D1		; | copy of $00A2F3
		LDA !MarioYPos : STA $D3		; |
		SEP #$20				;/


		PHK : PEA.w .MarioReturn-1		;\ return address
		PEA.w $F7F3-1				;/
		JML $00C47E				; mario stuff (wrapper to $C47E)
		.MarioReturn


		JSL $158008				; call PCE (will swap to SA-1 automatically)
		JSL $168000				; call main sprite loop (will swap to SA-1 automatically)


		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80

		PLA : STA $1C
		PLA : STA $1D

		JSL !BuildOAM

		JML $00A289				; JML to RTS

		; generator: JSR $AFFE (bank $02)
		; load sprite from level


		.SA1
		PHB
		LDA #$02
		PHA : PLB
		JSR HandleGraphics_RainbowShifter
		LDA $7490 : BEQ .nostar
		CMP #$08 : BCC .nostar
		LSR #5
		TAY
		LDA $13
		AND $8AA9,y
		BRA +
		.nostar
		LDA $78D3 : BEQ ++
		DEC $78D3
		AND #$01
	+	ORA $7F
		ORA $81
		BNE ++
		LDA $80
		CMP #$D0 : BCS ++
		JSL $02858F				; sparkles
		; - contents?
		++

		JSL $148000				; call FusionCore
		PLB
		RTL






; $00F6DB (scroll routine)
Camera:
		PHB : PHK : PLB
		REP #$20
		LDA $742A
		SEC
		; LM call
		SBC #$000C
		STA $742C
		PHA
		LDX #$06
	-	LDA $1A : STA $7F831F,x			; back up BG1/BG2 coords
		DEX #2 : BPL -
		PLA
		; LM return
		CLC : ADC #$0018
		STA $742E
		LDA $7462 : STA $1A
		LDA $7464 : STA $1C
		LDA $7466 : STA $1E
		LDA $7468 : STA $20
		LDA $5B
		LSR A : BCC .Horz
		JMP .Vert
		.Horz
		; LM call
		LDA $6BF5
		AND #$0040
		BEQ $03 : LDA #$000F
		ADC !LevelHeight
		SBC #$00EF				; note: C was for sure cleared so this subtracts 0xE0
		PEA .ReturnVScroll-1
		; LM return
		LDX !EnableVScroll
		BNE $01 : RTS
		STA $04
		LDY #$00
		LDA !MarioYPos
		SEC : SBC $1C
		STA $00
		CMP #$0070
		BMI $02 : LDY #$02
		STY $55
		STY $56
		SEC : SBC $F69F,y
		STA $02
		EOR $F6A3,y
		BMI $04 : LDY #$02 : STZ $02
;		LDA $02 : BMI +
;		LDX #$00 : STX $7404
;		BRA ....83
;	+	SEP #$20
;		LDA $73E7
;		CMP  #$06 : BCS ....45
;		LDA $7410
;		LSR A
;		ORA $749F
;		ORA $74
;		ORA $73F3
;		ORA $78C2
;		ORA $7406
;	....45	TAX
;		REP #$20
;		BNE ....69
;		LDX $787A : BEQ ....56
;		LDX $741E
;		CPX #$02 : BCS ....69
;	....56	LDX $75 : BEQ ....5E
;		LDX $72 : BNE ....69
;	....5E	LDX !EnableVScroll
;		DEX : BEQ ....75
;		LDX $73F1 : BNE ....75
;	....69	STX $73F1
;		LDX $73F1 : BNE ....81
;		; LM call (from $00F871)
;		; UNDOCUMENTED!!
;	....75	LDX $7404 : BNE ....81
;		LDX $72 : BNE ....AA
;		INC $7404
;	....81	LDA $02
;		SEC : SBC $F6A7,y
;		EOR $F6A7,y
;		ASL A
;		LDA $02 : BCS ....92
;		LDA $F6A7,y
;	....92	CLC : ADC $1C
;		CMP $F6AD,y
;		BPL $03 : LDA $F6AD,y
;		STA $1C
;		LDA $04
;		CMP $1C
;		BPL ....AA
;		STA $1C
;		STA $73F1
;	....AA	RTS

		.ReturnVScroll
		LDY $7411 : BEQ .FinishScroll
		LDY #$02
	;	LDA !MarioXPos
	;	SEC : SBC $1A

		; call PCE camera

		STA $00
		CMP $742A
		BPL $02 : LDY #$00
		STY $55
		STY $56
		SEC : SBC $742C,y
		BEQ .FinishScroll
		STA $02
		EOR $F6A3,y
		BPL .FinishScroll
		JSR $F8AB ;??
		LDA $02
		CLC : ADC $1A
		BPL $03 : LDA #$0000
		STA $1A
		LDA $5E
		DEC A
		XBA
		AND #$FF00
		BPL $03 : LDA #$0080
		CMP $1A
		BPL $02 : LDA $1A
	;	BRA .FinishScroll

		.Vert
		; probably axe this mode

		.FinishScroll
		; call camera box
		; call HDMA ptr
		; call unlimited scroll works
		SEP #$20
		LDA $1A
		SEC : SBC $7462
		STA $77BD
		LDA $1C
		SEC : SBC $7464
		STA $77BC
		LDA $1E
		SEC : SBC $7466
		STA $77BF
		LDA $20
		SEC : SBC $7468
		STA $77BE
		; LM call
		PHP
		LDX #$06
		LDY #$03
		REP #$20
	-	LDA $1A,x : STA $7462,x
		CMP $7F831F,x : BEQ +
		SEP #$20
		BMI ++
		LDA #$02
		BRA +++
	++	LDA #$00
	+++	PHX
		TYX
		STA $7F831B,x
		PLX
		REP #$20
	+	DEX #2
		DEY : BPL -
		PLP
		; LM return
		PLB
		RTL













