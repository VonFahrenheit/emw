

	PhysicsPlus:
	pushpc
	org $019032
		JML .Main					;\ Source: JSR $ABD8 : LDY #$00
		PLY						;/ (PLY will act as LDY #$00 but takes only 1 byte)

	org $019140
		JSL .ExtraCollision				;\ org: STZ $7694 : STZ $3330,x
		NOP #2						;/

	org $01914C
		BRA $07 : NOP #7				; org:	LDA !SpriteWater,x
								;	STA $7695
								;	STZ !SpriteWater,x

	org $019258
		STA !SpriteWater,x
		JML .Phase					;\ org: LDA !SpriteTweaker5,x : BMI $B0 ($019210)
		NOP						;/


	org $01ABCC
		JML .UpdateX					; org: TXA : CLC : ADC #$10 : TAX
		.ReturnX
		RTS

	org $01ABD8
		JML .UpdateY					; org: LDA $9E,x : BEQ $2D : ASL A
		.ReturnY
		RTS


	org $01B457						; replace invisible solid block with proper platform box output
		JSL !GetSpriteClipping04			;\
		LDA $05
		CLC : ADC #$03
		STA $05
		LDA $0B
		ADC #$00
		STA $0B
		LDA $07
		SEC : SBC #$03
		STA $07
		LDA #$0F					; |
		LDY $3200,x					; |

		; compare sprite num here... i guess		; |
		JSL OutputPlatformBox				; |
		RTS						;/
	warnpc $01B4B2



	pullpc
	.Main
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
		PEA.w $9036-1					; Return to $019036 (which is PLY [0x00 in all.log])
		JML $01ABD8					; Faux JSR to $01ABD8 from $019036



		.UpdateX
		LDA $3220,x : STA $00
		LDA !SpriteXSpeed,x : BEQ ..R
		ASL #4
		CLC : ADC !SpriteXFraction,x
		STA !SpriteXFraction,x
		PHP
		LDY #$00
		LDA !SpriteXSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC $3220,x
		STA $3220,x
		TYA
		ADC $3250,x
		STA $3250,x
		LDA $3220,x
		SEC : SBC $00
	..R	STA !SpriteDeltaX,x
		JML .ReturnX

		.UpdateY
		LDA $3210,x : STA $00
		LDA !SpriteYSpeed,x : BEQ ..R
		ASL #4
		CLC : ADC !SpriteYFraction,x
		STA !SpriteYFraction,x
		PHP
		LDY #$00
		LDA !SpriteYSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC $3210,x
		STA $3210,x
		TYA
		ADC $3240,x
		STA $3240,x
		LDA $3210,x
		SEC : SBC $00
	..R	STA !SpriteDeltaY,x
		JML .ReturnY




.ExtraCollision	STZ $7694					; overwritten code!
		LDA !SpriteWater,x : STA $7695			; entering water flag
		LDA !SpriteExtraCollision,x			;\
		AND #$0F					; | apply extra collision
		STA $3330,x					;/
		LDA !SpriteExtraCollision,x			;\
		ASL A						; |
		ROL A						; | apply extra water flag
		AND #$01					; |
		STA !SpriteWater,x				;/
		STZ !SpriteExtraCollision,x			; clear after it's applied
		RTL

.Phase		LDA !SpritePhaseTimer,x : BEQ .NoPhase		;\ phase timer
		DEC !SpritePhaseTimer,x				;/
.CODE_019210	JML $019210					; return to RTS
		.NoPhase					;\ check tweaker
		LDA !SpriteTweaker5,x : BMI .CODE_019210	;/
.CODE_019260	JML $019260					; run collision code



