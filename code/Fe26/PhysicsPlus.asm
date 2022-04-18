

	PhysicsPlus:
	pushpc
	org $019032
		JML .Main					;\ source: JSR $ABD8 : LDY #$00
		NOP						;/

	org $019140
		JSL .ExtraCollision				;\ org: STZ $7694 : STZ $3330,x
		NOP #2						;/

	org $01914C
		BRA $07 : NOP #7				; org:	LDA !SpriteWater,x
								;	STA $7695
								;	STZ !SpriteWater,x

	org $0191ED						; let Fe26 (main) handle water splash...
		RTS						;\ org: LDA !SpriteWater,x
		NOP #2						;/


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
		LDA !SpriteStasis,x : BNE .NoVectors		; > don't update gravity or vectors during stasis

		LDA !SpriteYSpeed,x : PHA			;\ backup speed regs
		LDA !SpriteXSpeed,x : PHA			;/
		LDA !SpriteVectorTimerY,x : BEQ .ClearVectorY	;\
		DEC !SpriteVectorTimerY,x			; |
		BRA .VectorY					; |
.ClearVectorY	STZ !SpriteVectorY,x				; |
		STZ !SpriteVectorAccY,x				; | vector Y
.VectorY	LDA !SpriteVectorY,x : STA !SpriteYSpeed,x	; |
		LDA !SpriteVectorAccY,x				; |
		CLC : ADC !SpriteVectorY,x			; |
		STA !SpriteVectorY,x				;/
		LDA !SpriteVectorTimerX,x : BEQ .ClearVectorX	;\
		DEC !SpriteVectorTimerX,x			; |
		BRA .VectorX					; |
.ClearVectorX	STZ !SpriteVectorX,x				; |
		STZ !SpriteVectorAccX,x				; | vector X
.VectorX	LDA !SpriteVectorX,x : STA !SpriteXSpeed,x	; |
		LDA !SpriteVectorAccX,x				; |
		CLC : ADC !SpriteVectorX,x			; |
		STA !SpriteVectorX,x				;/
		JSL $01801A					;\ apply vectors
		JSL $018022					;/
		PLA : STA !SpriteXSpeed,x			;\ restore speed regs
		PLA : STA !SpriteYSpeed,x			;/
		.NoVectors





		LDA !SpriteStasis,x : BEQ .NoStasis		;\
		JML $019084					; | just skip the rest of this routine during stasis
		.NoStasis					;/

		%UpdateY()					; overwritten code

		LDA !SpriteFallSpeed,x
		LSR #2 : STA $00
		EOR #$FF : STA $01
		LDA !SpriteYSpeed,x
		LDY !SpriteGravityTimer,x : BEQ .NormalGravity	;\
		DEC !SpriteGravityTimer,x			; |
		CLC : ADC !SpriteGravityMod,x
		.NormalGravity
		INC A						; +1
		LDY !SpriteWater,x : BEQ .Land

		.Water
		CMP #$80 : BCC ++
		CMP $01 : BCS +
		LDA $01 : BRA +
	++	CMP $00 : BCC +
		LDA $00 : BRA +

		.Land
		INC #2						; additional +2
		BMI +
		CMP !SpriteFallSpeed,x : BCC +
		LDA !SpriteFallSpeed,x
	+	STA !SpriteYSpeed,x
		JML $01905D					; return


		.UpdateX
		%UpdateX()
		JML .ReturnX

		.UpdateY
		%UpdateY()
		JML .ReturnY


.ExtraCollision	STZ $7694					; overwritten code!
		LDA !SpriteWater,x : STA $7695			; entering water flag
		LDA !SpriteExtraCollision,x			;\
		AND #$0F					; | apply extra collision
		STA $3330,x					;/
		LDA !SpriteExtraCollision,x			;\
		AND #$40					; | apply extra water flag
		BEQ $02 : LDA #$01				; |
		STA !SpriteWater,x				;/
		STZ !SpriteExtraCollision,x			; clear after it's applied
		RTL

.Phase		LDA !SpritePhaseTimer,x : BEQ .NoPhase		;\ phase timer
		DEC !SpritePhaseTimer,x				;/
.CODE_019210	JML $019210					; return to RTS
		.NoPhase					;\ check tweaker
		LDA !SpriteTweaker5,x : BMI .CODE_019210	;/
.CODE_019260	JML $019260					; run collision code



