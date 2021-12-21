;=======;
;ACCEL_X;
;=======;

; input:
;	A = target X speed
;	Y = acceleration

	ACCEL_X:
		.8Bit
		STA $00				; $00 = target speed
		STY $01				; $01 = acc
		SEC : SBC !P2XSpeed		;\
		BPL $03 : EOR #$FF : INC A	; |
		CMP $01				; | if |target speed - speed| <= acc, speed = target speed
		BEQ ..set			; |
		BCS ..calc			;/
		..set
		LDA $00 : STA !P2XSpeed		; return speed = target speed
		RTL
		..calc
		LDA $00 : BMI ..targetleft
		..targetright
		BIT !P2XSpeed : BMI ..accr	; neg -> pos = plus
		CMP !P2XSpeed : BCS ..accr	;
		LDA !P2InAir : BEQ ..accl
		LDA $6DA3
		LSR A : BCC ..accl
		RTL				; return without updating speed if in aerial super speed
		..accr				;\
		LDA !P2XSpeed			; |
		CLC : ADC $01			; | return speed = speed + acc
		STA !P2XSpeed			; |
		RTL				;/
		..targetleft
		BIT !P2XSpeed : BPL ..accl	; pos -> neg = minus
		CMP !P2XSpeed : BCC ..accl	;
		LDA !P2InAir : BEQ ..accr
		LDA $6DA3
		AND #$02 : BEQ ..accr
		RTL				; return without updating speed if in aerial super speed
		..accl				;\
		LDA !P2XSpeed			; |
		SEC : SBC $01			; | return speed = speed - acc
		STA !P2XSpeed			; |
		RTL				;/















