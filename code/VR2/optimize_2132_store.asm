

org $00A4D1
	JSR $AE41

org $00AE41
	REP #$20
	LDA $6701
	ASL #3
	SEP #$21
	ROR #3
	XBA
	ORA #$40
	STA $2132
	LDA $6702
	LSR A
	SEC : ROR A
	STA $2132
	XBA
	STA $2132
	RTS
	NOP #3