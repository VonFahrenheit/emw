

	!SpriteStasis		=	$34E0
	!SpriteGravityMod	=	$3500
	!SpriteGravityTimer	=	$3510
	!SpriteVectorY		=	$3520
	!SpriteVectorX		=	$3530
	!SpriteVectorAccY	=	$3540
	!SpriteVectorAccX	=	$3550
	!SpriteVectorTimerY	=	$3560
	!SpriteVectorTimerX	=	$3570
	!SpriteExtraCollision	=	$3580			; Applies only on the frame that it's set


	pushpc
	org $019032
		JML PhysicsPlus					;\ Source: JSR $ABD8 : LDY #$00
		PLY						;/ (PLY will act as LDY #$00 but takes only 1 byte)

	org $019140
		JSL PhysicsPlus_ExtraCollision			;\ Source: STZ $7694 : STZ $3330,x
		NOP #2						;/

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
		JML $019084					; | just skip the rest of this routine during stasis
		.NoStasis					;/

		TDC : PHA					; Push 0x00 on the stack
		PEA.w $9036-1					; Return to $019036 (which is PLY [0x00])
		JML $01ABD8					; Faux JSR to $01ABD8 from $019036



.ExtraCollision	STZ $7694					; Overwritten code!
		LDA !SpriteExtraCollision,x : STA $3330,x	; Apply extra collision
		STZ !SpriteExtraCollision,x			; ...but only for one frame
		RTL


