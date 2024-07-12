;===========;
;SET_GLITTER;
;===========;
	SET_GLITTER:
		%Ex_Index_Y()
.Spawn		LDA #$05+!SmokeOffset : STA !Ex_Num,y	; Smoke sprite to spawn
		LDA #$10 : STA !Ex_Data1,y		; Show glitter sprite for 16 frames
		BIT !P2Map16Index
		BMI .NoMap16

<<<<<<< Updated upstream
.Map16		LDA $9A : STA !Ex_XLo,y
		LDA $9B : STA !Ex_XHi,y
		LDA $98 : STA !Ex_YLo,y
		LDA $99 : STA !Ex_YHi,y
		RTS

.NoMap16	LDA !P2XPosLo				;\
=======
		.Spawn
		LDA #!Glitter_Num : STA !Ex_Num,y	; num
		LDA #$00 : STA !Ex_Data1,y		; timer
		LDA !P2XPosLo				;\
>>>>>>> Stashed changes
		CLC : ADC #$08				; |
		STA !Ex_XLo,y				; | Spawn at player X + 8 pixels
		LDA !P2XPosHi				; | (include hi byte for FusionCore 1.2+)
		ADC #$00				; |
		STA !Ex_XHi,y				;/
		LDA !P2YPosLo				;\
		CLC : ADC #$08				; |
		STA !Ex_YLo,y				; | Spawn at player Y + 8 pixels
		LDA !P2YPosHi				; | (include hi byte for FusionCore 1.2+)
		ADC #$00				; |
		STA !Ex_YHi,y				;/
<<<<<<< Updated upstream
		RTS
=======
		RTL

		.Map16
		%Ex_Index_Y()
		LDA #!Glitter_Num : STA !Ex_Num,y	; num
		LDA #$00 : STA !Ex_Data1,y		; timer
		LDA $9A					;\
		AND #$F0				; | x
		STA !Ex_XLo,y				; |
		LDA $9B : STA !Ex_XHi,y			;/
		LDA $98					;\
		AND #$F0				; | y
		STA !Ex_YLo,y				; |
		LDA $99 : STA !Ex_YHi,y			;/
		RTL
>>>>>>> Stashed changes
