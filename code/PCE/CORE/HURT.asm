HURT:
		LDA !P2Character : BNE .NotMario	; check for mario
		LDA $19					;\
		BEQ $02 : LDA #$01			; | mario HP (+1 removed to automatically "subtract" 1)
		STA !P2HP				;/
		JSL !HurtMario				; hurt mario
		JSR .Mario				; mario code
		RTL
		.NotMario

		LDA !P2Invinc				;\
		ORA !StarTimer				; | don't hurt player while star is active or player is invulnerable
		BNE .Return				;/

		LDA !P2Character			;\
		ASL A					; |
		CMP.b #.Ptr_End-.Ptr			; | execute pointer
		BCC $02 : LDA #$00			; |
		TAX					; |
		JSR (.Ptr,x)				;/

		LDA #$F8 : STA !P2YSpeed		; give player some Y speed
		LDA #$20 : STA !SPC1			; play Yoshi "OW" SFX
		LDA #$80 : STA !P2Invinc		; set invincibility timer

		LDA !P2HP				;\
		DEC A					; |
		STA !P2HP				; | decrement HP and kill player 2 if zero
		BEQ .Kill				; |
		BMI .Kill				;/
		LDA #$0F : STA !P2HurtTimer		;\ if player didn't die: set hurt animation timer and return
		RTL					;/

.Kill		LDA #$01 : STA !P2Status		; > this player dies
		LDA #$C0 : STA !P2YSpeed		; > set Y speed
		LDA !MultiPlayer : BEQ .End		; > skip checking other player in single player
		LDA !CurrentPlayer : BNE +		; see which player this is
		LDA !PlayerBackupData+0 : BNE .End	; check if p2 is dead
		RTL
	+	LDA !P2Status-$80 : BEQ .Return		; check if p1 is dead
.End		LDA #$01 : STA !SPC3			;\ death music + disable backup
		LDA #$FF : STA !MusicBackup		;/
		REP #$20				;\
		STZ !P1Coins				; | players lose all coins upon death
		STZ !P2Coins				; |
		SEP #$20				;/
.Return		RTL


		.Ptr
		dw .Mario		; 0
		dw .Luigi		; 1
		dw .Kadaal		; 2
		dw .Leeway		; 3
		dw .Alter		; 4
		dw .Peach		; 5
		..End

		.Mario
		STZ !P2FastSwim				;\ end fast swim
		STZ !P2FastSwimAnim			;/
		STZ !P2FlareDrill			; end flare drill
		STZ !P2HangFromLedge			; fall if hanging from ledge
		RTS

		.Luigi
		STZ !P2FireTimer			; reset fire timer
		STZ !P2PickUp				; end pickup animation
		STZ !P2SpinAttack			; end spin attack
		STZ !P2KickTimer			; end kick animation
		STZ !P2TurnTimer			; end turn animation
		RTS

		.Kadaal
		STZ !P2Punch1				;\ punch timers
		STZ !P2Punch2				;/
		STZ !P2ShellSlide			; end shell slide
		STZ !P2ShellSpin			; end shell spin attack
		STZ !P2ShellSpeed			; end fast shell slide status
		STZ !P2Senku				; end senku
		STZ !P2AllRangeSenku			; reset all range senku
		STZ !P2SenkuSmash			; end senku smash
		STZ !P2ShellDrill			; end shell drill
		STZ !P2BackDash				; end back dash
		RTS

		.Leeway
		STZ !P2SwordAttack			;\ end sword attack
		STZ !P2SwordTimer			;/
		STZ !P2CrouchTimer			; reset crouch timer
		STZ !P2WallJumpInput			;\ reset wall jump effect
		STZ !P2WallJumpInputTimer		;/
		STZ !P2DashSlash			; refund dash slash
		STZ !P2ComboDash			; clear combo flag (can't combo out of getting hit)
		STZ !P2ComboDisable			; clear combo used flag
		STZ !P2WallClimb			; fall off if climbing
		STZ !P2WallClimbFirst			; end climb start
		STZ !P2WallClimbTop			; end getup
		RTS

		.Alter
		RTS

		.Peach
		RTS








