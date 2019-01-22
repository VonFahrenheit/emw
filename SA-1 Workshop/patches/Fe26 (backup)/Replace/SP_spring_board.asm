
pushpc
org $01E650
	JML HANDLE_PLAYER2		;\ Source: LDA $32D0,x : BEQ $5B ($01E6B0)
	NOP				;/
pullpc


;============================;
;PLAYER 2 INTERACTION ROUTINE;
;============================;
HANDLE_PLAYER2:

	LDA $3420,x : BEQ .Return
	LSR A : TAY			; Y = half of $3420,x
	LDA.w $01E61A,y
	STA $00
	LDA $3210,x
	CLC : ADC #$10
	SEC : SBC $00
	STA !P2YPosLo
	LDA $3240,x
	SBC #$00
	STA !P2YPosHi
	STZ !P2XSpeed
	STZ !P2YSpeed

	LDA $3420,x
	CMP #$01
	BNE .Return
	LDA #$B0
	STA !P2YSpeed			; Set player 2 Yspeed
	LDA #$08
	STA $3300,x			; Disable interaction with player 2
	BIT $6DA3 : BPL .Return		; Return if player 2 does not hold B
	LDA #$90 : STA !P2YSpeed	; Give player 2 much higher Yspeed
	LDA #$0F : STA !P2Floatiness	; Set springboard timer

	.Return
	LDA $32D0,x
	CMP $3420,x : BPL .P1

	.P2
	LDA $3420,x
	LSR A : TAY
	LDA.w $01E611,y
	STA $33D0,x
	BRA .Shared

	.P1
	LSR A : TAY

	.Shared
	LDA $32D0,x : BEQ .01E6B0
.01E655	JML $01E655
.01E6B0	JML $01E6B0