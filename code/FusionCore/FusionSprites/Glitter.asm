
	Glitter:
		LDX !SpriteIndex

		LDA !Ex_Data1,x
		CMP #$10 : BCS .Delete
		INC !Ex_Data1,x
		BIT #$03 : BNE .Return

		LSR #2						;\
		AND #$03 : TAY					; |
		LDA .X,y : STA $00				; |
		STZ $01						; |
		BPL $02 : DEC $01				; |
		LDA .Y,y : STA $02				; |
		STZ $03						; |
		BPL $02 : DEC $03				; |
		LDA !Ex_XLo,x					; |
		CLC : ADC $00					; | get spawn coords
		STA $00						; |
		LDA !Ex_XHi,x					; |
		ADC $01						; |
		STA $01						; |
		LDA !Ex_YLo,x					; |
		CLC : ADC $02					; |
		STA $02						; |
		LDA !Ex_YHi,x					; |
		ADC $03						; |
		STA $03						;/

		PHB						;\
		JSL GetParticleIndex				; |
		LDA $00 : STA !Particle_X,x			; |
		LDA $02 : STA !Particle_Y,x			; |
		STZ !Particle_XSpeed,x				; |
		STZ !Particle_YSpeed,x				; | spawn particle
		SEP #$20					; |
		LDA.b #!prt_sparklesmall : STA !Particle_Type,x	; |
		LDA #$C0 : STA !Particle_Prop,x			; > max prio
		PLB						; |
		SEP #$30					; |
		LDX !SpriteIndex				;/

		.Return
		RTS

		.Delete
		STZ !Ex_Num,x
		RTS



		.X
		db $00,$04,$08,$04

		.Y
		db $04,$0C,$04,$FC

