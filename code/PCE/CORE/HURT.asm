

	HURT:
		LDA !dmg : BNE .Go			;\
		LDA.b #!DefaultDamage : STA !dmg	; | make sure there is a damage value loaded
		.Go					;/
		BEQ .Ready				;\
		LDY !Difficulty : BNE .Ready		; | take 1 less damage on easy, but not less than 1
		DEC !dmg				; |
		.Ready					;/

		LDA !P2Invinc				;\
		ORA !StarTimer				; |
		ORA !P2Pipe				; | invincibility
		ORA !P2SlantPipe			; |
		BNE .Return				;/

		REP #$20				;\
		LDA #$0000				; |
		STA !P2Hitbox1IndexMem			; | reset index mem for riposte
		STA !P2Hitbox2IndexMem			; |
		SEP #$20				;/

		LDA !Difficulty_full			;\
		AND.b #!CriticalMode : BEQ .NotCrit	; | critical mode sets HP to 1 when player gets hit, meaning they'll always die from the damage
		LDA #$01 : STA !P2HP			; |
		.NotCrit				;/

		LDA #$F8 : STA !P2YSpeed		; give player some Y speed
		LDA #$20 : STA !SPC1			; play Yoshi "OW" SFX
		LDA #$80 : STA !P2Invinc		; set invincibility timer

		LDA !P2Character			;\
		ASL A					; |
		CMP.b #.Ptr_End-.Ptr			; |
		BCC $02 : LDA #$00			; | execute pointer
		PHX					; |
		TAX					; |
		JSR (.Ptr,x)				; |
		PLX					;/

		.TempHP					;\
		LDA !P2TempHP				; |
		CMP !dmg : BCC ..remove			; |
		SBC !dmg				; | if temp HP >= dmg, 0 dmg and reduce temp HP
		STA !P2TempHP				; |
		STZ !dmg				; |
		BRA ..done				;/
		..remove				;\
		LDA !dmg				; |
		SEC : SBC !P2TempHP			; | remaining temp HP buffers against dmg
		STA !dmg				; |
		STZ !P2TempHP				; |
		..done					;/

		LDA #$0F : STA !P2HurtTimer		; set hurt animation timer
		LDA !P2HP				;\
		SEC : SBC !dmg				; |
		BPL $02 : LDA #$00			; | subtract damage from player HP (kill if 0)
		STA !P2HP				; |
		CMP #$00 : BEQ .Kill			;/
		STZ !dmg				; damage value used
		.Return
		RTL					; return

.Kill		LDA #$01 : STA !P2Status		; > this player dies
		LDA #$C0 : STA !P2YSpeed		; > set Y speed
		LDA !CurrentPlayer : BNE ..p2
		..p1
		REP #$20
		LDA !P1DeathCounter
		INC A : STA !P1DeathCounter
		SEP #$20
		STZ !dmg				; damage value used
		RTL
		..p2
		REP #$20
		LDA !P1DeathCounter
		INC A : STA !P1DeathCounter
		SEP #$20
		STZ !dmg				; damage value used
		RTL


		.Ptr
		dw .Mario		; 0
		dw .Luigi		; 1
		dw .Kadaal		; 2
		dw .Leeway		; 3
		dw .Alter		; 4
		dw .Peach		; 5
		..End

		.Mario
		LDA !P2HP				;\
		CMP #$05 : BCC ..nosizechange		; |
		SBC !dmg				; | set shrink timer when size changes from big to small
		CMP #$05 : BCS ..nosizechange		; |
		LDA #$1F : STA !P2ShrinkTimer		; |
		LDA #$04 : STA !SPC1			; > shrink sfx
		..nosizechange				;/
		STZ !P2PickUp				; end pickup animation
		STZ !P2KickTimer			; end kick animation
		STZ !P2TurnTimer			; end turn animation
		STZ !P2Dashing				; end dash state
		STZ !P2HangFromLedge			; fall if hanging from ledge
		RTS

		.Luigi
		LDA !P2HP				;\
		CMP #$05 : BCC ..nosizechange		; |
		SBC !dmg				; | set shrink timer when size changes from big to small
		CMP #$05 : BCS ..nosizechange		; |
		LDA #$1F : STA !P2ShrinkTimer		; |
		LDA #$04 : STA !SPC1			; > shrink sfx
		..nosizechange				;/
		STZ !P2FireTimer			; reset fire timer
		STZ !P2PickUp				; end pickup animation
		STZ !P2SpinAttack			; end spin attack
		STZ !P2KickTimer			; end kick animation
		STZ !P2TurnTimer			; end turn animation
		STZ !P2Dashing				; end dash state
		RTS

		.Kadaal
		STZ !P2Punch				; punch timer
		STZ !P2Headbutt				; headbutt timer
		STZ !P2ShellSlide			; end shell slide
		STZ !P2ShellSpin			; end shell spin attack
		STZ !P2ShellSpeed			; end fast shell slide status
		STZ !P2Senku				; end senku
		STZ !P2AllRangeSenku			; reset all range senku
		STZ !P2DropKick				; end drop kick
		STZ !P2BackDash				; end back dash
		STZ !P2Dashing				; end dash state
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
		STZ !P2Dashing				; end dash state
		RTS

		.Alter
		RTS

		.Peach
		RTS









