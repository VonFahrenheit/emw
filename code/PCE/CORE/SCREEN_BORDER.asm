;=============;
;SCREEN BORDER;
;=============;


	SCREEN_BORDER:
<<<<<<< Updated upstream
		LDA !GameMode
		CMP #$14 : BEQ $01 : RTS

		LDA !SideExit
		BNE .NoLevelBorders

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
		LDA !RAM_ScreenMode
		LSR A
		LDA !P2YPosHi : BPL +		;\
		CMP #$FF : BEQ .EndVert		; | Can move a max of -1 screen above the level
		STZ !P2YPosLo			; |
		LDA #$FF : STA !P2YPosHi	;/
	+	BCC .Horizontal

		.Vertical
		CMP $5F
		BRA .Shared

		.Horizontal
		XBA
		LDA !P2YPosLo
		REP #$20
		CMP $73D7
		SEP #$20
		BMI .EndVert
		BCS .OffVert
	;	CMP #$01
	BRA +

		.Shared
		BNE .EndVert
	+	LDA !P2YPosLo
		CMP #$B0
		BCC .EndVert

		.OffVert
		LDA #$02 : STA !P2Status
		LDA !P1Dead
		BEQ .EndVert
		LDA #$01 : STA !SPC3

		.EndVert
		LDA !RAM_ScreenMode
		LSR A
		BCS .WithinScreen
		LDA !P2XPosHi
		BMI .OffHorz
		REP #$20
		LDA !LevelWidth-1
		AND #$FF00
		SEC : SBC #$0010
		CMP !P2XPosLo
		SEP #$20
		BCS .WithinScreen
=======
		LDA !P2Pipe					;\
		ORA !Cutscene					; | skip this during pipe animation and cutscenes
		BNE .Return					;/
		LDA !GameMode					;\ skip if not in game mode 14
		CMP #$14 : BNE .Return				;/
		LDA !Level+1 : BNE .LevelBorders		;\
		LDA !Level					; | no screen limit on level 0x0C7
		CMP #$C7 : BNE .LevelBorders			;/

		.Return
		RTL


>>>>>>> Stashed changes

; scratch:
; $00	left border (+0)
; $02	right border (+0)
; $04	top border (+0)
; $06	bottom border (+0)
; $08	left border (-16)
; $0A	right border (+16)
; $0C
; $0E



		.LevelBorders
		REP #$30					; all regs 16-bit

		BIT !HardBoxBorders-1 : BPL ..levelcoords
		LDA !CameraBoxU : BMI ..levelcoords
		..boxcoords
		STA $04
		SEC : SBC #$0010
		STA $0C
		LDA !CameraBoxD
		CLC : ADC #$00E0
		STA $06
		LDA !CameraBoxL : STA $00
		SEC : SBC #$0010
		STA $08
		LDA !CameraBoxR
		CLC : ADC #$00F0
		BRA ..setR

		..levelcoords
		STZ $00
		STZ $04
		LDA #$FFF0
		STA $08
		STA $0C
		LDA !LevelHeight
		CLC : ADC #$0010
		STA $06
		LDA !LevelWidth
		AND #$00FF
		DEC A
		XBA
		ORA #$00F0
		..setR
		STA $02
		CLC : ADC #$0010
		STA $0A
		LDY !P2Y					; Y = Y

		..horizontal
		LDX !P2X : BMI ..checkL				; X = X + check L/R
		CPX $00 : BCS ..checkR

		..checkL
		CPY !LeftExitLimitU : BCC ..vertical		;\
		CPY !LeftExitLimitD : BCS ..blockL		; | left exit check
		CPX #$FFF0 : BCS ..vertical			; > must be at least 16px off screen to trigger exit
		..exitL						; |
		LDA !LeftExitOverride : BRA ..exit		;/
		..blockL					;\
		LDX #$0000 : STX !P2X				; | left border block
		LDA #$0002 : TSB !P2Blocked			; |
		BRA ..vertical					;/

		..checkR
		CPX $02 : BCC ..vertical			;\
		CPY !RightExitLimitU : BCC ..vertical		; |
		CPY !RightExitLimitD : BCS ..blockR		; | right exit check
		CPX $0A : BCC ..vertical			; > must be at least 16px off screen to trigger exit)
		LDA !RightExitOverride : BRA ..exit		;/
		..blockR					;\
		LDX $02 : STX !P2X				; | right border block
		LDA #$0001 : TSB !P2Blocked			;/

		..vertical
		CPY #$0000 : BPL ..checkD			;\ check U/D
		JMP ..checkU					;/

		..checkD
		LDA !P2YDelta-1 : BMI +				;\ must be moving down to trigger down border exit
		CMP #$0100 : BCC +				;/
		CPY $06 : BCS ++				; must be past down border
	+	JMP ..done					;\
	++	CPX !DownExitLimitL : BCC ..fallintopit		; |
		CPX !DownExitLimitR : BCS ..fallintopit		; | down exit check (if past threshold and not in exit zone, die)
		..exitD						; |
		LDA !DownExitOverride				;/

		..exit
		BEQ ..nooverride
		CMP #$FFFF : BEQ ..overworld			; 0xFFFF = exit to overworld
		CMP #$BEA7 : BEQ ..beatlevel			; 0xBEA7 (get it it says BEAT) = beat level
		STA !LevelEntry : BRA ..triggerexit
		..nooverride
		STX !MarioX
		STY !MarioY
		JSL TranslateOldExitNumber			; (this routine auto-clamps coords and doesn't care about reg size)
		..triggerexit
		SEP #$30
		INC !DoorCounter : BNE +			; +1 door count
		DEC !DoorCounter : +				; stay at 255 instead of wrapping around to 0
		LDA #$0F : STA !GameMode			; load level
		RTL

		..overworld
		SEP #$30
		LDA #$0B : STA !GameMode
<<<<<<< Updated upstream
		RTS
=======
		LDA #$80 : STA !SPC3
		RTL
>>>>>>> Stashed changes

		..beatlevel
		SEP #$30
		JML BeatLevel

<<<<<<< Updated upstream
		.OutRight
		LDA $1A
		CLC : ADC #$00F0
		STA !P2XPosLo
		SEP #$20
		RTS
=======
		..fallintopit
		SEP #$30
		LDA !Difficulty : BNE ..die
		..easypit
		LDA #$05 : STA !dmg				; > 1 full heart of damage (+1 because easy armor)
		JSL CORE_HURT					;\ easy mode: pits do damage instead of instant death
		LDA !P2Status : BNE ..setstatus			;/
		LDA #$80					;\
		LDX !P2Character				; |
		CPX #$01					; | bounce player
		BNE $02 : LDA #$98				; |
		STA !P2YSpeed					;/
		RTL
		..die
		LDA !CurrentPlayer : BNE ..p2			;\
		..p1						; |
		REP #$20					; |
		LDA !P1DeathCounter				; |
		INC A : STA !P1DeathCounter			; |
		BRA +						; | increase death count
		..p2						; |
		REP #$20					; |
		LDA !P2DeathCounter				; |
		INC A : STA !P2DeathCounter			; |
	+	SEP #$20					;/
		..setstatus
		LDA #$02 : STA !P2Status			; status = dead
		RTL
>>>>>>> Stashed changes

		..checkU
		LDA !P2YDelta-1 : BPL ..done			; must be moving up to trigger up border exit
		CPY #$0000 : BMI +
		CPY $08 : BCS ..done				; must be at least 16px above level to trigger exit
	+	CPX !UpExitLimitL : BCC ..done			;\
		CPX !UpExitLimitR : BCS ..done			; | up exit check
		LDA !UpExitOverride : JMP ..exit		;/
		..done

<<<<<<< Updated upstream
		.Return
		SEP #$20
		RTS
=======




		.CameraBorders

		..checkL
		CPX #$0000 : BMI ..done				; during co-op, if one player is on the way out, let them continue even if camera scrolls back
		LDA $1A						;\ let level border handle this
		CMP $00 : BEQ ..checkR				;/
		CMP !P2X : BCC ..checkR				;\ clamp to left edge of screen
		STA !P2X					;/
		BRA ..done

		..checkR
		LDA $1A						;\ if camera is at right limit, let level border handle this
		CMP $08 : BEQ ..done				;/
		LDA !P2X					;\ during co-op, if one player is on the way out, let them continue even if camera scrolls back
		CMP $02 : BCS ..done				;/
		LDA $1A						;\
		CLC : ADC #$00F0				; | clamp to right edge of screen
		CMP !P2X : BCS ..done				; |
		STA !P2X					;/
		..done


		SEP #$30
		RTL






>>>>>>> Stashed changes
