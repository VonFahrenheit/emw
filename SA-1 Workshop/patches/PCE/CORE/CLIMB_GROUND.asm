;=================;
;CLIMB GROUND CODE;
;=================;


	CLIMB_GROUND:


		LDA !P2Blocked				;\
		AND #$04 : BEQ +			; |
		LDA !P2YSpeed				; |
		BEQ +					; |
		BMI +					; | Allow climbing down to the ground

	NO_CLIMB:

		LDA !P2Water				; |
		AND.b #$01^$FF				; |
		STA !P2Water				; |
		+					;/
		RTS