

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


macro UpdateX()
		LDA $3220,x : STA $00
		LDA !SpriteXSpeed,x : BEQ ?Return
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
	?Return:
		STA !SpriteDeltaX,x
endmacro

macro UpdateY()
		LDA $3210,x : STA $00
		LDA !SpriteYSpeed,x : BEQ ?Return
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
	?Return:
		STA !SpriteDeltaY,x
endmacro



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
		LDA !SpriteGravityTimer,x : BEQ .NormalGravity	;\
		DEC !SpriteGravityTimer,x			; |
		LDA !SpriteGravityMod,x				; | apply gravity modifier
		CLC : ADC !SpriteYSpeed,x			; |
		STA !SpriteYSpeed,x				; |
		.NormalGravity					;/
		LDY #$00					; overwritten code
		JML $019037					; return


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



