;===========;
;KNOCKED OUT;
;===========;
KNOCKED_OUT:

<<<<<<< Updated upstream
		STZ !P2XSpeed
		STZ !P2VectorX
		STZ !P2VectorY
		LDA #$03 : STA !P2Gravity
		LDA #$46 : STA !P2FallSpeed
		JSR CORE_UPDATE_SPEED
=======
		.Riposte
		LDA !Difficulty : BNE ..done
		LDA !P2HurtTimer : BEQ ..done
		STZ !P2HurtTimer
		JSL CORE_RIPOSTE
		..done

		STZ !P2XSpeed
		STZ !P2VectorX
		STZ !P2VectorY
		LDA #$04 : STA !P2InAir
		STZ !P2Blocked
		STZ !P2ExtraBlock
		STZ !P2Platform
		STZ !P2FlashPal
		STZ !P2Carry
		STZ !P2Invinc
		LDA #$03 : STA !P2Gravity
		LDA #$46 : STA !P2FallSpeed

		.Flip
		BIT !P2YSpeed : BMI ..done
		LDA $14
		LSR #3
		AND #$01 : STA !P2Direction
		..done

		BIT !P2ShowHP				;\
		BMI .Wait				; | wait for heart counter
		BVS .Wait				;/

		JSL CORE_UPDATE_SPEED

		.Wait
>>>>>>> Stashed changes
		REP #$20
		LDA !P2YPosLo
		SEC : SBC $1C
		CMP #$0180
		SEP #$20

		RTS








