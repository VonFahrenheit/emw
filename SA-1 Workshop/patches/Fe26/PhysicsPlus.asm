

	!SpriteStasis		=	$34E0
	!SpriteGravityMod	=	$3500
	!SpriteGravityTimer	=	$3510
	!SpriteVectorY		=	$3520
	!SpriteVectorX		=	$3530
	!SpriteVectorAccY	=	$3540
	!SpriteVectorAccX	=	$3550
	!SpriteVectorTimerY	=	$3560
	!SpriteVectorTimerX	=	$3570


	pushpc
	org $019032
		JML PhysicsPlus					;\ Source: JSR $ABD8 : LDY #$00
		PLY						;/ (PLY will act as LDY #$00 but takes only 1 byte)
	pullpc
	PhysicsPlus:

		LDA !SpriteStasis,x : BNE .NoVectors		; > Don't update gravity or vectors during stasis
		LDA !SpriteGravityTimer,x : BEQ .NormalGravity	;\
		DEC !SpriteGravityTimer,x			; |
		LDA !SpriteGravityMod,x				; | Apply gravity modifier
		CLC : ADC $9E,x					; |
		STA $9E,x					; |
		.NormalGravity					;/

		LDA $9E,x : PHA					;\ Backup speed regs
		LDA $AE,x : PHA					;/
		LDA !SpriteVectorTimerY,x : BEQ .ClearVectorY	;\
		DEC !SpriteVectorTimerY,x			; |
		BRA .VectorY					; |
.ClearVectorY	STZ !SpriteVectorY,x				; |
		STZ !SpriteVectorAccY,x				; | Vector Y
.VectorY	LDA !SpriteVectorY,x : STA $9E,x		; |
		LDA !SpriteVectorAccY,x				; |
		CLC : ADC !SpriteVectorY,x			; |
		STA !SpriteVectorY,x				;/
		LDA !SpriteVectorTimerX,x : BEQ .ClearVectorX	;\
		DEC !SpriteVectorTimerX,x			; |
		BRA .VectorX					; |
.ClearVectorX	STZ !SpriteVectorX,x				; |
		STZ !SpriteVectorAccX,x				; | Vector X
.VectorX	LDA !SpriteVectorX,x : STA $AE,x		; |
		LDA !SpriteVectorAccX,x				; |
		CLC : ADC !SpriteVectorX,x			; |
		STA !SpriteVectorX,x				;/
		JSL $01801A					;\ Apply vectors
		JSL $018022					;/
		PLA : STA $AE,x					;\ Restore speed regs
		PLA : STA $9E,x					;/
		.NoVectors

		LDA !SpriteStasis,x : BEQ .NoStasis		;\
		DEC !SpriteStasis,x				; |
		STZ $9E,x					; | Apply stasis
		STZ $AE,x					; |
		.NoStasis					;/

		TDC : PHA					; Push 0x00 on the stack
		PEA.w $9036-1					; Return to $019036 (which is PLY [0x00])
		JML $01ABD8					; Faux JSR to $01ABD8 from $019033

