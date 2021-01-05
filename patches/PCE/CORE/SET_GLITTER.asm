;===========;
;SET_GLITTER;
;===========;
	SET_GLITTER:
		LDA !P2Offscreen : BNE .Return
		LDY #!Ex_Amount-1			; Set up loop

.Loop		LDA !Ex_Num,y				;\
		BEQ .Spawn				; |
		DEY					; | Find empty smoke sprite slot
		BPL .Loop				;/
.Return		RTS

.Spawn		LDA #$05+!SmokeOffset : STA !Ex_Num,y	; Smoke sprite to spawn
		LDA #$10 : STA !Ex_Data1,y		; Show glitter sprite for 16 frames
		BIT !P2Map16Index
		BMI .NoMap16

.Map16		LDA $9A : STA !Ex_XLo,y
		LDA $9B : STA !Ex_XHi,y
		LDA $98 : STA !Ex_YLo,y
		LDA $99 : STA !Ex_YHi,y
		RTS

.NoMap16	LDA !P2XPosLo				;\
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
		RTS