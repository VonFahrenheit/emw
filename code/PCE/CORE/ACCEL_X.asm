;=======;
;ACCEL_X;
;=======;

; input:
;	A = target X speed (8-bit)
;	Y = acceleration (8-bit)

	ACCEL_X:
		.8
		.8Bit
		STA $00					; $00 = target speed
		STY $01					; $01 = acc
		LDY #$00				; Y = snap flag
		SEC : SBC !P2XSpeed			;\
		BPL $03 : EOR #$FF : INC A		; |
		CMP $01					; | if |target speed - speed| <= acc, speed = target speed
		BEQ ..set				; |
		BCS ..calc				;/
		..set
		INY					; set snap flag
		..calc
		LDA $00 : BMI ..targetleft
		..targetright
		BIT !P2XSpeed : BMI ..accr		; neg -> pos = plus
		CMP !P2XSpeed : BCS ..accr		;
		LDA !P2InAir : BEQ ..accl
		LDA $15
		LSR A : BCC ..accl
		RTL					; return without updating speed if in aerial super speed
		..accr					;\
		CPY #$01 : BCS ..snap			; > check snap
		LDA !P2XSpeed				; | return speed = speed + acc
		CLC : ADC $01				; |
		STA !P2XSpeed				; |
		RTL					;/
		..targetleft
		BIT !P2XSpeed : BPL ..accl		; pos -> neg = minus
		CMP !P2XSpeed : BCC ..accl		;
		LDA !P2InAir : BEQ ..accr
		LDA $15
		AND #$02 : BEQ ..accr
		RTL					; return without updating speed if in aerial super speed
		..accl					;\
		CPY #$01 : BCS ..snap			; > check snap
		LDA !P2XSpeed				; | return speed = speed - acc
		SEC : SBC $01				; |
		STA !P2XSpeed				; |
		RTL					;/

		..snap
		LDA $00 : STA !P2XSpeed			; return speed = target speed
		RTL


; input:
;	A = target X speed (16-bit)
;	Y = acceleration (16-bit)
		.16
		.16Bit
		STA $00					; $00 = target speed
		STY $02					; $02 = acc
		LDY #$0000				; Y = snap flag
		SEC : SBC !P2XSpeedFraction		;\
		BPL $04 : EOR #$FFFF : INC A		; |
		CMP $02					; | if |target speed - speed| <= acc, speed = target speed
		BEQ ..set				; |
		BCS ..calc				;/
		..set
		INY
		..calc
		LDA $00 : BMI ..targetleft
		..targetright
		BIT !P2XSpeedFraction : BMI ..accr	; neg -> pos = plus
		CMP !P2XSpeedFraction : BCS ..accr	;
		LDA !P2InAir
		AND #$00FF : BEQ ..accl
		LDA $15
		LSR A : BCC ..accl
		RTL					; return without updating speed if in aerial super speed
		..accr					;\
		CPY #$0001 : BCS ..snap			; > check snap
		LDA !P2XSpeedFraction			; | return speed = speed + acc
		CLC : ADC $02				; |
		STA !P2XSpeedFraction			; |
		RTL					;/
		..targetleft
		BIT !P2XSpeedFraction : BPL ..accl	; pos -> neg = minus
		CMP !P2XSpeedFraction : BCC ..accl	;
		LDA !P2InAir
		AND #$00FF : BEQ ..accr
		LDA $15
		AND #$0002 : BEQ ..accr
		RTL					; return without updating speed if in aerial super speed
		..accl					;\
		CPY #$0001 : BCS ..snap			; > check snap
		LDA !P2XSpeedFraction			; | return speed = speed - acc
		SEC : SBC $02				; |
		STA !P2XSpeedFraction			; |
		RTL					;/

		..snap
		LDA $00 : STA !P2XSpeedFraction		; return speed = target speed
		RTL










