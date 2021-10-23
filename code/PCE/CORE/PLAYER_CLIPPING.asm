; To load player 1 clipping, do:
;	CLC
;	LDA #$00
;	JSL !GetPlayerClipping
;
; To load player 2 clipping, do:
;	CLC
;	LDA #$01
;	JSL !GetPlayerClipping
;
; To check for contact, do:
;	SEC
;	JSL !GetPlayerClipping
;
; When checking for contact, the routine will compare the hitbox stored at $04-$07, $0A-$0B to player hitboxes.
; Upon returning, the routine will yield the following result:
;	Carry flag: set if contact is detected, otherwise clear
;	A: first bit set if P1 contact is detected, second bit set if P2 contact is detected
; To check for contact, a sprite can do:
;	JSL $03B69F
;	SEC : JSL !PlayerClipping
;	BCC .NoContact
;	LSR A : BCC .P2
;	.P1
;	;[code]
;	.P2
;	;[code]
;	.NoContact
;
; player clipping gets stored like so:
; $00 - XLo
; $01 - YLo
; $02 - width
; $03 - height
; $08 - XHi
; $09 - YHi



	PlayerClipping:
		PHX					;  push X
		BCS .Compare				; if carry set, compare

		PHY					;\
		LSR A					; |
		ROR A					; |
		AND #$80				; |
		TAY					; |
		REP #$20				; |
		LDA !P2Hurtbox-$80+2,y			; |
		STA $01					; | otherwise just load hurtbox and return
		STA $08					; |
		LDA !P2Hurtbox-$80+4,y : STA $02	; |
		LDA !P2Hurtbox-$80+0,y			; |
		SEP #$20				; |
		STA $00					; |
		XBA : STA $08				; |
		PLY					; |
		PLX					; |
		RTL					;/

		.Compare
		LDX #$00				; X = contact bits
		LDA !MultiPlayer : BEQ .Player1		; skip P2 if multiplayer is off

		.Player2
		LDA !P2Status : BNE .Player1		;\ player must exist and not be in pipe
		LDA !P2Pipe : BNE .Player1		;/
	.P2Yes	REP #$20				;\
		LDA !P2Hurtbox+2			; |
		STA $01					; |
		STA $08					; |
		LDA !P2Hurtbox+4 : STA $02		; | check for P2 contact
		LDA !P2Hurtbox+0			; |
		SEP #$20				; |
		STA $00					; |
		XBA : STA $08				; |
		JSL !Contact16				;/
		BCC ..nocontact				; branch
		INX #2					; mark P2 contact
		..nocontact				;

		.Player1
		LDA !P2Status-$80 : BNE .Result		;\ player must exist and not be in pipe
		LDA !P2Pipe-$80 : BNE .Result		;/
	.P1Yes	REP #$20				;\
		LDA !P2Hurtbox-$80+2			; |
		STA $01					; |
		STA $08					; |
		LDA !P2Hurtbox-$80+4 : STA $02		; | check for P1 contact
		LDA !P2Hurtbox-$80+0			; |
		SEP #$20				; |
		STA $00					; |
		XBA : STA $08				; |
		JSL !Contact16				;/
		BCC ..nocontact				; branch
		INX					; mark P1 contact
		..nocontact				;

		.Result
		CLC					; clear carry
		TXA					; > A = contact bits
		BEQ $01 : SEC				; > C = contact flag
		PLX					; restore X
		RTL					; return


