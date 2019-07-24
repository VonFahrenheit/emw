HURT:
		LDA !P2Invinc			;\
		ORA $7490			; | Don't hurt player while star is active or player is invulnerable
		BNE .Return			;/
		LDA #$F8			;\ Give P2 some Y speed
		STA !P2YSpeed			;/
		LDA #$20			;\ Play Yoshi "OW" sound
		STA !SPC1			;/
		LDA #$80			;\ Set invincibility timer
		STA !P2Invinc			;/
		LDA !P2Water			;\
		AND.b #$01^$FF			; | Drop climb
		STA !P2Water			;/
		LDA #$00			;\
		STA !P2Floatiness		; |
		STA !P2Punch1			; | Reset stuff
		STA !P2Punch2			; |
		STA !P2Senku			; |
		STA !P2Kick			;/ > Kick is Climb for Leeway so he does fall off
		STA !P2ClimbTop			; Also reset this
		STA !P2ShellSlide		;\
		STA !P2ShellDrill		; | Reset shell moves
		STA !P2ShellSpeed		;/
		LDA !P2HP			;\
		DEC A				; |
		STA !P2HP			; | Decrement HP and kill player 2 if zero
		BEQ .Kill			; |
		BMI .Kill			;/
		LDA #$0F
		STA !P2HurtTimer
		RTS

.Kill		LDA #$01 : STA !P2Status		; > This player dies
		LDA !CurrentPlayer : BNE +		; see which player this is
		LDA !PlayerBackupData+0 : BNE .End	; Check if p2 is dead
		RTS

	+	LDA !P2Status-$80 : BEQ .Return		;\ Check if p1 is dead
.End		LDA #$01 : STA !SPC3			;/
		LDA $1D					;\
		INC A					; | Stop camera on vertical levels
		STA $5F					; |
		STZ !EnableVScroll			;/
.Return		RTS