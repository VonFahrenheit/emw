
pushpc
org $01E650
	JML HANDLE_PCE				;\ Source: LDA $32D0,x : BEQ $5B ($01E6B0)
	NOP					;/
pullpc

; $3360:	bounce timer for plaeyr 1 PCE
; $3420:	bounce timer for player 2 PCE


;============================;
;PLAYER 2 INTERACTION ROUTINE;
;============================;
HANDLE_PCE:

	LDA $3420,x : BEQ +			;\
	LDY #$80				; | Interaction for player 2 PCE
	JSR Process				;/
+	LDA $3360,x : BEQ +			;\
	LDY #$00				; | Interaction for player 1 PCE
	JSR Process				;/
	+

	LDA $32D0,x : BEQ +
	CMP $3420,x : BCS .Mario
+	LDA $3420,x : BEQ .P1
	CMP $3360,x : BCS .P2

	.P1
	LDA $3360,x

	.P2
	LSR A : TAY
	LDA.w $01E611,y
	STA $33D0,x
	BRA .Shared

	.Mario
	LSR A : TAY

	.Shared
	LDA $32D0,x : BEQ .01E6B0
.01E655	JML $01E655
.01E6B0	JML $01E6B0



Process:
	PHA
	PHY
	LSR A : TAY				; Y = half of $3420,x
	LDA.w $01E61A,y
	PLY
	STA $00
	LDA $3210,x
	CLC : ADC #$10
	SEC : SBC $00
	STA !P2YPosLo-$80,y
	LDA $3240,x
	SBC #$00
	STA !P2YPosHi-$80,y
	LDA #$00
	STA !P2XSpeed-$80,y
	STA !P2YSpeed-$80,y
	PLA
	CMP #$01 : BNE .Return

	LDA #$B0
	STA !P2YSpeed-$80,y			; Set player 2 Yspeed
	LDA #$08
	STA $3300,x				; Disable interaction with player 2
	BIT $6DA3 : BPL .Return			; Return if player 2 does not hold B
	LDA #$90 : STA !P2YSpeed-$80,y		; Give player 2 much higher Yspeed

	.Return
	RTS





