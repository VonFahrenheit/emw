;===========;
;SET_GLITTER;
;===========;
	SET_GLITTER:
		%Ex_Index_Y()

		.Spawn
		LDA #!Glitter_Num : STA !Ex_Num,y	; num
		LDA #$10 : STA !Ex_Data1,y		; timer
		LDA !P2XPosLo				;\
		CLC : ADC #$08				; |
		STA !Ex_XLo,y				; | spawn at player X + 8 pixels
		LDA !P2XPosHi				; |
		ADC #$00				; |
		STA !Ex_XHi,y				;/
		LDA !P2YPosLo				;\
		CLC : ADC #$08				; |
		STA !Ex_YLo,y				; | spawn at player Y + 8 pixels
		LDA !P2YPosHi				; |
		ADC #$00				; |
		STA !Ex_YHi,y				;/
		RTL

		.Map16
		%Ex_Index_Y()
		LDA #!Glitter_Num : STA !Ex_Num,y	; num
		LDA #$10 : STA !Ex_Data1,y		; timer
		LDA $9A					;\
		AND #$F0				; | x
		STA !Ex_XLo,y				; |
		LDA $9B : STA !Ex_XHi,y			;/
		LDA $98					;\
		AND #$F0				; | y
		STA !Ex_YLo,y				; |
		LDA $99 : STA !Ex_YHi,y			;/
		RTL
