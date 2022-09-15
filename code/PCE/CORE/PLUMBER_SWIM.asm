;============;
;PLUMBER SWIM
;============;


;;; SWIM/WATER CODE ;;;

	PLUMBER_SWIM:

		LDA !P2Blocked				;\
		AND $15					; | set crouch
		AND #$04				; |
		STA !P2Ducking				;/
		BEQ +					;\
		LDA #$03 : TRB $15			; | clear left/right when crouching
		+					;/

		BIT $15 : BMI +				;\
		LDA #$0A : STA !P2FastSwim		; | fast swim check
	+	LDA !P2FastSwim : BEQ .HoldingObject	;/
		DEC !P2FastSwim				; decrement timer
		LDA !P2Carry : BEQ .NotHoldingObject	; holding item flag

		.HoldingObject
		LDA $15					;\
		AND #$03 : BEQ +			; |
		CMP #$03 : BEQ +			; | fast swim speed when no input
		CLC : ADC #$04				; |
		BRA ++					;/
	+	LDA !P2Direction			;\
		EOR #$01				; | fast swim speed when input
		INC A					; |
	++	BRA +					;/

		.NotHoldingObject
		LDA $15					;\
		AND #$03				; | get index
	+	ASL A					; |
		TAX					;/

		REP #$20				;\
		LDA.l .XSpeed,x : BNE .NoFriction	; |
		LDA.l .XSpeed_acc,x			; |
		BIT !P2XSpeedFraction			; |
		BPL $04 : EOR #$FFFF : INC A		; |
		CLC : ADC !P2XSpeedFraction		; | friction
		CMP #$FE00 : BCS ++			; |
		CMP #$0201 : BCS +			; |
	++	LDA #$0000				; |
	+	STA !P2XSpeedFraction			; |
		BRA .XSpeedDone				; |
		.NoFriction				;/
		LDA !P2XSpeedFraction			;\
		CLC : ADC.l .XSpeed_acc,x		; |
		CMP.l .XSpeed_clampmin,x : BCC +	; |
		CMP.l .XSpeed_clampmax,x : BCS +	; | acceleration and speed clamp
		LDA.l .XSpeed,x				; |
	+	STA !P2XSpeedFraction			; |
		.XSpeedDone				; |
		SEP #$20				;/
		LDA $15					;\
		AND #$03 : BEQ .DirDone			; |
		CMP #$03 : BEQ .DirDone			; | set facing direction
		AND #$01				; |
		STA !P2Direction			; |
		.DirDone				;/

		LDA !P2InAir : BNE .Swim		;\
		.Ground					; |
		STZ !P2YSpeed				; | reset fast swim timer when touching the ground
		LDA #$0A : STA !P2FastSwim		; |
		.Swim					;/


		LDA !P2Water				;\
		AND #$08 : BNE .Submerged		; | has to have up collision point above water and be moving up to jump out of water
		BIT !P2YSpeed : BPL .Submerged		;/
		LDA !P2Character : BNE +		;\
		LDA $17					; |
		AND #$80				; |
		ORA $15					; |
		AND #$88				; | mario can spin jump out of water
		CMP #$88 : BNE .FastSwimDown		; |
		BIT $17 : BPL ++			; |
		; spin jump flag here
		LDA #$04 : STA !SPC4			; > spin jump SFX
		BRA ++					;/
	+	LDA $15					;\
		AND #$88				; |
		CMP #$88 : BNE .FastSwimDown		; | can jump out of water with B + up
	++	LDA #$0F : TRB !P2YPosLo		; |
		LDA #$C0 : STA !P2YSpeed		; |
		RTL					;/

		.Submerged
		LDA !P2Carry : BNE .FastSwim		;\ see which swim speed is being used
		LDA !P2FastSwim : BNE .SlowSwim		;/

		.FastSwim				;\
		LDA $15					; |
		AND #$04 : BEQ .FastSwimRise		; |
		.FastSwimDown				; |
		LDA !P2YSpeed				; |
		CLC : ADC #$04				; | fast swim down
		BMI +					; |
		CMP #$10 : BCC +			; |
		LDA #$10				; |
	+	STA !P2YSpeed				; |
		BRA .NoGravity				;/
		.FastSwimRise				;\
		LDA !P2YSpeed : BPL +			; |
		CMP #$F0 : BCS +			; |
		INC A					; |
		BRA ++					; |
	+	LDA $14					; | fast swim neutral/up
		AND #$01				; |
		DEC A					; |
		CLC : ADC !P2YSpeed			; |
	++	STA !P2YSpeed				; |
		BRA .NoGravity				;/

		.SlowSwim
		BIT $16 : BPL .NoSwim			; check input
		LDA #$0E : STA !SPC1			; swim SFX
		LDA !P2Character : BNE ..Luigi		; check for animation type
		..Mario					;\
		LDA #!Mar_SwimSlow+1 : STA !P2Anim	; | mario swim animation
		STZ !P2AnimTimer			; |
		BRA ..CharDone				;/
		..Luigi					;\
		LDA #!Lui_SwimSlow+1 : STA !P2Anim	; | luigi swim animation
		STZ !P2AnimTimer			; |
		..CharDone				;/
		LDA $15					;\
		AND #$0C				; |
		LSR #2					; |
		TAX					; |
		LDA !P2YSpeed				; |
		CLC : ADC.l .YSpeed,x			; | slow swim y speed
		BPL +					; |
		CMP.l .YSpeed,x : BCS +			; |
		LDA.l .YSpeed,x				; |
	+	STA !P2YSpeed				; |
		.NoSwim					;/

		LDA $14					;\
		AND #$01				; |
		CLC : ADC !P2YSpeed			; |
		BMI +					; | apply gravity
		CMP !P2FallSpeed : BCC +		; |
		LDA !P2FallSpeed			; |
	+	STA !P2YSpeed				; |
		.NoGravity				;/


	; accelerate walk: 180
	; max speed walk: 800
	; friction walk: 100

	; accelerate swim: 180
	; max speed swim: 1000
	; friction swim: 100

	; gravity: 2 every 4 frames
	; y swim acc and max speed:
	;	down: -800
	;	neutral: -1800
	;	up: -2800

	; fast swim:
	;	X acc: 180
	;	X speed no sideways input: 1000
	;	X speed with sideways input: 2000
	;	Y acc up: 2 every 4 frames
	;	Y acc down: 4
	;	Y speed: 1000



		RTL



		.XSpeed
		dw $0000,$1000,$F000,$0000
		dw $0000,$2000,$E000,$0000
		..clampmin
		dw $0000,$1000,$8000,$0000
		dw $0000,$2000,$8000,$0000
		..clampmax
		dw $0000,$8000,$F000,$0000
		dw $0000,$8000,$E000,$0000
		..acc
		dw $FF00,$0180,$FE80,$FF00
		dw $FF00,$0180,$FE80,$FF00


		.YSpeed
		db $E8,$F8,$D0,$E8




