;=============;
;SCREEN BORDER;
;=============;


	SCREEN_BORDER:
		LDA !P2Pipe				;\
		ORA !Cutscene				; | skip this during pipe animation and cutscenes
		BNE .Kill				;/
		LDA !GameMode				;\ skip if not in game mode 14
		CMP #$14 : BNE .Kill			;/
		LDA !Level+1 : BNE .Process		;\
		LDA !Level				; | no screen limit on level 0x0C7
		CMP #$C7 : BNE .Process			;/

		.Kill
		RTL


		.Process
		LDA !SideExit : BNE .NoLevelBorders

		.CheckLeft
		REP #$20
		LDA !P2XPosLo : BMI +
		BNE .CheckRight
	+	STZ !P2XPosLo
		LDA #$0002 : TSB !P2Blocked
		BRA .NoLevelBorders

		.CheckRight
		LDX #$F0 : STX $00
		LDX !LevelWidth
		DEX
		STX $01
		LDA !RAM_ScreenMode
		LSR A
		BCC +
		LDX #$01 : STX $01
	+	LDA !P2XPosLo
		CMP $00
		BCC .NoLevelBorders
		LDA $00 : STA !P2XPosLo
		LDA #$0001 : TSB !P2Blocked

		.NoLevelBorders
		SEP #$20
		LDA $7411
		BNE .NoLimit

		REP #$20			;\
		LDX #$00			; |
		LDA $1A				; |
		CMP !P2XPosLo			; |
		BEQ +				; |
		BCC +				; | Stay within screen
		STA !P2XPosLo			; |
		STX !P2XSpeed			; |
	+	CLC : ADC #$00F0		; |
		CMP !P2XPosLo			; |
		BCS +				; |
		STA !P2XPosLo			; |
		STX !P2XSpeed			; |
	+	SEP #$20			;/

		.NoLimit
	;	LDA !RAM_ScreenMode
	;	LSR A
		LDA !P2YPosHi : BPL +		;\
		CMP #$FF : BEQ .EndVert		; | Can move a max of -1 screen above the level
		STZ !P2YPosLo			; |
		LDA #$FF : STA !P2YPosHi	;/
	+	;BCC .Horizontal

	;	.Vertical
	;	CMP $5F
	;	BRA .Shared

	;	.Horizontal
		XBA
		LDA !P2YPosLo
		REP #$20
		CMP $73D7
		SEP #$20
		BMI .EndVert
		BCS .OffVert
	;	CMP #$01

	;	.Shared
	;	BNE .EndVert
	+	LDA !P2YPosLo
		CMP #$B0
		BCC .EndVert

		.OffVert
		LDA !Difficulty
		AND #$03 : BNE ..die
		JSL CORE_HURT			;\ easy mode: pits do 1 damage instead of instant death
		LDA !P2Status : BNE ..die	;/
		LDA !P2Character : BNE +	;\
		LDA !MarioAnim			; | check if mario just died
		CMP #$09 : BEQ ..die		;/
	+	LDA #$80
		LDX !P2Character
		CPX #$01
		BNE $02 : LDA #$98
		STA !P2YSpeed
		BRA .EndVert
		..die
		LDA #$02 : STA !P2Status
		LDA !Difficulty			;\ prevent easy mode pit kill from counting as 2 deaths
		AND #$03 : BEQ .EndVert		;/
		LDA !CurrentPlayer : BNE ..p2
		..p1
		REP #$20
		LDA !P1DeathCounter
		INC A : STA !P1DeathCounter
		SEP #$20
		BRA .EndVert
		..p2
		REP #$20
		LDA !P2DeathCounter
		INC A : STA !P2DeathCounter
		SEP #$20

		.EndVert
		LDA !P2XPosHi
		BMI .OffHorz
		REP #$20
		LDA !LevelWidth-1
		AND #$FF00
		SEC : SBC #$0010
		CMP !P2XPosLo
		SEP #$20
		BCS .WithinScreen

		.OffHorz
		LDA !SideExit
		BEQ .WithinScreen

		.LeaveLevel
		LDA #$0B : STA !GameMode
		RTL

		.WithinScreen
		REP #$20
		LDA !P2XPosLo
		SEC : SBC $1A
		BMI .OutLeft
		BEQ .OutLeft
		CMP #$00F0 : BCC .Return

		.OutRight
		LDA $1A
		CLC : ADC #$00F0
		STA !P2XPosLo
		SEP #$20
		RTL

		.OutLeft
		LDA $1A
		STA !P2XPosLo

		.Return
		SEP #$20
		RTL






