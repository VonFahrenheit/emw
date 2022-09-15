;==========;
;SET_SPLASH;
;==========;
	SET_SPLASH:
		REP #$20
		LDA !P2XSpeed
		AND #$00FF
		LSR #4
		CMP #$0008
		BCC $03 : ORA #$FFF0
		CLC : ADC !P2XPos
		STA $00

		LDY #$06
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2YPos
		AND #$FFF0
		STA $02
		SEP #$20

		PHB
		JSL GetParticleIndex
		LDA.w #!prt_watersplash : STA !Particle_Type,x
		LDA.l !P2XPosLo : STA !Particle_X,x
		LDA $02 : STA !Particle_Y,x
		SEP #$30
		LDA #$F0 : STA !Particle_Prop,x
		PLB
		RTL



	.Bubble
		LDA #$07 : STA $0E				;\ loop counter
		STZ $0F						;/
		LDA $02						;\
		SEC : SBC #$05					; | adjust Y position
		STA $02						; |
		BCS $02 : DEC $03				;/
		PHB						; bank wrapper start
		..loop
		JSL GetParticleIndex : TXY			; get index
		LDA.w #!prt_bubble : STA !Particle_Type,y	; particle type
		LDX $0E						; loop counter as coord index
		LDA.l ..xoffset,x				;\
		AND #$00FF					; | X coord
		CLC : ADC $00					; |
		STA !Particle_X,y				;/
		LDA.l ..yoffset,x				;\
		AND #$00FF					; | Y coord
		CLC : ADC $02					; |
		STA !Particle_Y,y				;/
		LDA #$F000 : STA !Particle_Tile,y		; prop
		DEC $0E : BPL ..loop				; loop
		..end
		SEP #$30					; all regs 8-bit
		PLB						; bank wrapper end
		RTL						; return

		..xoffset
		db $00,$04,$0A,$07
		db $08,$03,$02,$02

		..yoffset
		db $15,$1B,$18,$21
		db $15,$1B,$18,$21


