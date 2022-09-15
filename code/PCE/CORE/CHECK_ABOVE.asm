;===========;
;CHECK ABOVE;
;===========;
;
; this routine checks if the tile above the player is solid, can be used to force crouch
;
CHECK_ABOVE:
		REP #$30
		LDA !P2XPosLo
		CLC : ADC #$0008
		TAX
		LDA !P2YPosLo
		SEC : SBC #$000F
		TAY
		SEP #$20
		JSL GetMap16
		CMP #$0111
		SEP #$20
		BCC .Return
		CMP #$37 : BEQ .Free
		CMP #$38 : BEQ .Free
		CMP #$6E : BCS .Free
	.Solid	SEC
		RTL
	.Free	CLC
	.Return	RTL







