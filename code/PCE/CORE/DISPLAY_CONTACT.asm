;===============;
;DISPLAY CONTACT;
;===============;
DISPLAY_CONTACT:


	DISPLAYCONTACT:
		PHX
		%Ex_Index_X()
		LDA $00 : STA $0C
		LDA $08 : STA $0D
		LDA $01 : STA $0E
		LDA $09 : STA $0F
		LDA $0A : XBA
		LDA $04
		REP #$20
		CLC : ADC $0C
		LSR A
		STA $0C
		SEP #$20
		LDA $0B : XBA
		LDA $05
		REP #$20
		CLC : ADC $0E
		LSR A
		STA $0E
		SEP #$20
		STA !Ex_YLo,x
		XBA : STA !Ex_YHi,x
		LDA $0C : STA !Ex_XLo,x
		LDA $0D : STA !Ex_XHi,x
		LDA #$02+!SmokeOffset : STA !Ex_Num,x
		LDA #$07 : STA !Ex_Data1,x
		PLX
		RTS
