;===========;
;SET_GLITTER;
;===========;
	SET_GLITTER:
		%Ex_Index_Y()
.Spawn		LDA #$05+!SmokeOffset : STA !Ex_Num,y	; Smoke sprite to spawn
		LDA #$10 : STA !Ex_Data1,y		; Show glitter sprite for 16 frames
		LDA !P2XPosLo				;\
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
		RTL


.Map16		%Ex_Index_Y()
		LDA #$05+!SmokeOffset : STA !Ex_Num,y	; Smoke sprite to spawn
		LDA #$10 : STA !Ex_Data1,y		; Show glitter sprite for 16 frames
		LDA $9A					;\
		AND #$F0				; |
		STA !Ex_XLo,y				; |
		LDA $9B : STA !Ex_XHi,y			;/
		LDA $98					;\
		AND #$F0				; |
		STA !Ex_YLo,y				; |
		LDA $99 : STA !Ex_YHi,y			;/
		RTL
