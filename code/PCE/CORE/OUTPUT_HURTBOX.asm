;
; call with:
;	REP #$30
;	LDA.w #ANIM
;	JSL CORE_OUTPUT_HURTBOX
;

OUTPUT_HURTBOX:
		CLC : ADC #$0006			;\ get ANIM table, offset to clipping
		STA $00					;/
		LDA !P2Anim				;\
		AND #$00FF				; | get index for current frame
		ASL #3					; |
		TAY					;/
		LDA ($00),y				;\
		CLC : ADC #$0010			; | get pointer to hurtbox
		STA $00					;/
		SEP #$10				;\
		LDY #$04				; |
		LDA ($00),y : STA !P2Hurtbox+4		; | get hurtbox size
		AND #$00FF				; |
		STA $02					;/
		LDY #$00				;\
		LDA ($00),y				; |
		LDX !P2Direction : BNE +		; |
		EOR #$FFFF				; | get hurtbox X
		CLC : ADC #$0010			; |
		SEC : SBC $02				; |
	+	CLC : ADC !P2XPosLo			; |
		STA !P2Hurtbox+0			;/
		LDY #$02				;\
		LDA ($00),y				; | get hurtbox Y
		CLC : ADC !P2YPosLo			; |
		STA !P2Hurtbox+2			;/
		SEP #$30				; all regs 8-bit
		RTL					; return


