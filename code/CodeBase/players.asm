;=========================;
; PLAYER-RELATED ROUTINES ;
;=========================;

; input: clipping loaded in E8 slot
; output:
;	C = contact flag (0 = no contact, 1 = contact)
;	A = contact bits (0x01 bit = P1 contact, 0x02 bit = P2 contact)
;
; none of the other versions return contact bits, as they only check for contact once
; _P1 checks for contact with player 1
; _P2 checks for contact with player 2
; _Y checks for contact with player based on index, Y is used as input for this one
	PlayerContact:
		PHX					; push X
		LDX #$00				; X = contact bits

		; having P2 first is slightly faster because i can LDX #$02 instead of INX #2

		.CheckPlayer2
		LDA !MultiPlayer : BEQ ..nocontact	; skip P2 if multiplayer is off
		LDA !P2Status				;\ player must exist and not be in pipe
		ORA !P2Pipe : BNE ..nocontact		;/
		JSL .P2 : BCC ..nocontact		;\
		LDX #$02				; | check for contact
		..nocontact				;/

		.CheckPlayer1
		LDA !P2Status-$80			;\ player must exist and not be in pipe
		ORA !P2Pipe-$80 : BNE ..nocontact	;/
		JSL .P1 : BCC ..nocontact		;\
		INX					; | check for contact
		..nocontact				;/

		.Result
		TXA					; A = contact bits
		CMP #$01				; C = contact flag
		PLX					; restore X
		RTL					; return

	.P1
		REP #$20
		LDA !P2HurtboxW-$80
		AND #$00FF
		CLC : ADC !P2HurtboxX-$80
		CMP $E8 : BCC ..return
		LDA $E8
		CLC : ADC $EC
		CMP !P2HurtboxX-$80 : BCC ..return
		LDA !P2HurtboxH-$80
		AND #$00FF
		CLC : ADC !P2HurtboxY-$80
		CMP $EA : BCC ..return
		LDA $EA
		CLC : ADC $EE
		CMP !P2HurtboxY-$80
		..return
		SEP #$20
		RTL

	.P2
		REP #$20
		LDA !P2HurtboxW
		AND #$00FF
		CLC : ADC !P2HurtboxX
		CMP $E8 : BCC ..return
		LDA $E8
		CLC : ADC $EC
		CMP !P2HurtboxX : BCC ..return
		LDA !P2HurtboxH
		AND #$00FF
		CLC : ADC !P2HurtboxY
		CMP $EA : BCC ..return
		LDA $EA
		CLC : ADC $EE
		CMP !P2HurtboxY
		..return
		SEP #$20
		RTL

	.Y
		REP #$20
		LDA !P2HurtboxW-$80,y
		AND #$00FF
		CLC : ADC !P2HurtboxX-$80,y
		CMP $E8 : BCC ..return
		LDA $E8
		CLC : ADC $EC
		CMP !P2HurtboxX-$80,y : BCC ..return
		LDA !P2HurtboxH-$80,y
		AND #$00FF
		CLC : ADC !P2HurtboxY-$80,y
		CMP $EA : BCC ..return
		LDA $EA
		CLC : ADC $EE
		CMP !P2HurtboxY-$80,y
		..return
		SEP #$20
		RTL





; input: A = contact bits (0x01 bit = hurt player 1, 0x02 bit = hurt player 2)
; output: void
	HurtPlayers:
		LDY !dmg : BNE .Go			;\
		LDY.b #!DefaultDamage : STY !dmg	; | make sure there is a damage value loaded
		.Go					;/
		CPY #$01 : BEQ .Ready			;\
		LDY !Difficulty : BNE .Ready		; | take 1 less damage on easy, but not less than 1
		DEC !dmg				; |
		.Ready					;/
		LSR A : BCC .P2
	.P1	PHA
		LDY #$00 : JSR .Main
		PLA
	.P2	LSR A : BCC .Return
		LDY #$80 : JSR .Main
		.Return
		STZ !dmg				; this damage instance was used
		RTL


	.Main
		LDA !P2Invinc-$80,y			;\
		ORA !StarTimer				; |
		ORA !P2Pipe-$80,y			; | gaming
		ORA !P2SlantPipe-$80,y			; |
		BNE .RTS				;/

		REP #$20				;\
		LDA #$0000				; |
		STA !P2Hitbox1IndexMem-$80,y		; | reset index mem for riposte
		STA !P2Hitbox2IndexMem-$80,y		; |
		SEP #$20				;/

		LDA !Difficulty_full			;\
		AND.b #!CriticalMode : BEQ .NotCrit	; | critical mode sets HP to 1 when player gets hit, meaning they'll always die from the damage
		LDA #$01 : STA !P2HP-$80,y		; |
		.NotCrit				;/

		LDA #$F8 : STA !P2YSpeed-$80,y		; give player some Y speed
		LDA #$20 : STA !SPC1			; play Yoshi "OW" SFX
		LDA #$80 : STA !P2Invinc-$80,y		; set invincibility timer

		LDA !P2Character-$80,y			;\
		ASL A					; |
		CMP.b #.Ptr_end-.Ptr			; |
		BCC $02 : LDA #$00			; | execute pointer
		PHX					; |
		TAX					; |
		LDA #$00				; > A = 0x00 so we can "STZ"
		JSR (.Ptr,x)				; |
		PLX					;/

		.TempHP					;\
		LDA !P2TempHP-$80,y			; |
		CMP !dmg : BCC ..remove			; |
		SBC !dmg				; | if temp HP >= dmg, 0 dmg and reduce temp HP
		STA !P2TempHP-$80,y			; |
		STZ !dmg				; |
		BRA ..done				;/
		..remove				;\
		LDA !dmg				; |
		SEC : SBC !P2TempHP-$80,y		; | remaining temp HP buffers against dmg
		STA !dmg				; |
		LDA #$00 : STA !P2TempHP-$80,y		; |
		..done					;/

		LDA #$0F : STA !P2HurtTimer-$80,y	; set hurt animation timer
		LDA !P2HP-$80,y				;\
		SEC : SBC !dmg				; |
		BPL $02 : LDA #$00			; | subtract damage from player HP (kill if 0)
		STA !P2HP-$80,y				; |
		CMP #$00 : BEQ .Kill			;/

		.RTS
		RTS					; return

		.Kill
		LDA #$01 : STA !P2Status-$80,y		; > This player dies
		LDA #$C0 : STA !P2YSpeed-$80,y
		CPY #$80 : BEQ ..p2
		..p1
		REP #$20
		LDA !P1DeathCounter
		INC A : STA !P1DeathCounter
		SEP #$20
		RTS
		..p2
		REP #$20
		LDA !P2DeathCounter
		INC A : STA !P2DeathCounter
		SEP #$20
		RTS


		.Ptr
		dw .Mario		; 0
		dw .Luigi		; 1
		dw .Kadaal		; 2
		dw .Leeway		; 3
		dw .Alter		; 4
		dw .Peach		; 5
		..end

	.Mario
		LDA !P2HP-$80,y				;\
		CMP #$05 : BCC ..nosizechange		; |
		SBC !dmg				; | set shrink timer when size changes from big to small
		CMP #$05 : BCS ..nosizechange		; |
		LDA #$1F : STA !P2ShrinkTimer-$80,y	; |
		LDA #$04 : STA !SPC1			; > shrink sfx
		..nosizechange				;/
		LDA #$00
		STA !P2PickUp-$80,y			; end pickup animation
		STA !P2KickTimer-$80,y			; end kick animation
		STA !P2TurnTimer-$80,y			; end turn animation
		STA !P2Dashing-$80,y			; end dash state
		STA !P2HangFromLedge-$80,y		; fall if hanging from ledge
		RTS

	.Luigi
		LDA !P2HP-$80,y				;\
		CMP #$05 : BCC ..nosizechange		; |
		SBC !dmg				; | set shrink timer when size changes from big to small
		CMP #$05 : BCS ..nosizechange		; |
		LDA #$1F : STA !P2ShrinkTimer-$80,y	; |
		LDA #$04 : STA !SPC1			; > shrink sfx
		..nosizechange				;/
		LDA #$00
		STA !P2FireTimer-$80,y			; reset fire timer
		STA !P2PickUp-$80,y			; end pickup animation
		STA !P2SpinAttack-$80,y			; end spin attack
		STA !P2KickTimer-$80,y			; end kick animation
		STA !P2TurnTimer-$80,y			; end turn animation
		STA !P2Dashing-$80,y			; end dash state
		RTS

	.Kadaal
		STA !P2Punch-$80,y			; punch timer
		STA !P2Headbutt-$80,y			; headbutt timer
		STA !P2ShellSlide-$80,y			; end shell slide
		STA !P2ShellSpin-$80,y			; end shell spin attack
		STA !P2ShellSpeed-$80,y			; end fast shell slide status
		STA !P2Senku-$80,y			; end senku
		STA !P2AllRangeSenku-$80,y		; reset all range senku
		STA !P2DropKick-$80,y			; end drop kick
		STA !P2BackDash-$80,y			; end back dash
		STA !P2Dashing-$80,y			; end dash state
		RTS

	.Leeway
		STA !P2SwordAttack-$80,y		;\ end sword attack
		STA !P2SwordTimer-$80,y			;/
		STA !P2CrouchTimer-$80,y		; reset crouch timer
		STA !P2WallJumpInput-$80,y		;\ reset wall jump effect
		STA !P2WallJumpInputTimer-$80,y		;/
		STA !P2DashSlash-$80,y			; refund dash slash
		STA !P2ComboDash-$80,y			; clear combo flag (can't combo out of getting hit)
		STA !P2ComboDisable-$80,y		; clear combo used flag
		STA !P2WallClimb-$80,y			; fall off if climbing
		STA !P2WallClimbFirst-$80,y		; end climb start
		STA !P2WallClimbTop-$80,y		; end getup
		STA !P2Dashing-$80,y			; end dash state
		RTS

	.Alter
		RTS

	.Peach
		RTS

