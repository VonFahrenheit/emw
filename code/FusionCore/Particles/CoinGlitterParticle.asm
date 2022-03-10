
; need:
;	initial angle offset + target player
;	timer (increments angle and handles movement)

; X speed + Y speed are unused... so they will be source coords
; X acc will be target player
; Y acc will be initial angle

; 00-0F: move + shrink
; 10-1F: move
; 20-3F: grow


	CoinGlitterParticle:
		LDX $00
		LDA !Particle_XAcc,x
		AND #$00FF : STA $0A
		DEC !Particle_Timer,x
		LDA !Particle_Timer,x
		AND #$00FF : BEQ .Despawn
		CMP #$0020 : BCC .Move

		.Grow
		SBC #$003F						;\
		EOR #$FFFF : INC A					; |
		CMP #$0010 : BCC ..table				; |
		LDA #$0020 : BRA ..set					; |
		..table							; |
		TAX							; | Y = size factor (smooth scaling)
		LDA.l ..factor,x					; |
		AND #$00FF						; |
		LDX $00							; |
		..set							; |
		TAY							;/
		LDA !Particle_XSpeed,x : STA $02			;\ org coords
		LDA !Particle_YSpeed,x : STA $04			;/
		LDA $0A : JMP .GetCircle

		..factor
		db $04,$08,$0C,$0F,$12,$15,$17,$19,$1B,$1C,$1D,$1E,$1F,$1F,$1F,$1F

		.Despawn						;\
		LDA !Particle_YAcc,x					; |
		AND #$00FF						; |
		TAX							; | make target player flash gold
		SEP #$20						; |
		LDA #$B4 : STA.l !P2FlashPal-$80,x			; |
		LDA #$1C : STA.l !SPC1					; > yoshi coin SFX
		LDX $00							;/
		LDA.b #(ParticleMain_List_End-ParticleMain_List)/2	;\
		STA !Particle_Type,x					; |
		REP #$20						; | standard despawn code
		TXA : STA.l !Particle_Index				; |
		RTS							;/

		.Move
		ASL #3							;\ Y = timer factor
		TAY							;/
		STA $0E							; store in $0E too
		LDA !Particle_YAcc,x					;\
		AND #$0080						; |
		TAX							; |
		LDA.l !P2XLo-$80,x					; | $02,$04 = target X,Y coords
		CLC : ADC #$0008					; |
		STA $02							; |
		LDA.l !P2YLo-$80,x : STA $04				; |
		LDX $00							;/
		LDA !Particle_XSpeed,x : STA $06			;\ org coords
		LDA !Particle_YSpeed,x					;/
		PHB : PHK : PLB						; bank wrapper start
		STZ $2250						; prepare multiplication
		STA $2251						;\
		STY $2253						; | calculate org Y component
		NOP : BRA $00						; |
		LDA $2307 : STA $08					;/
		LDA $06 : STA $2251					;\
		STY $2253						; | calculate org X component
		NOP : BRA $00						; |
		LDA $2307 : STA $06					;/
		LDA #$0100						;\
		SEC : SBC $0E						; | reverse timer for target coord
		TAY							;/
		LDA $02 : STA $2251					;\
		STY $2253						; |
		LDA $06							; | calculate final X
		NOP							; |
		CLC : ADC $2307						; |
		STA $02							;/
		LDA $04 : STA $2251					;\ set up final Y calc
		STY $2253						;/
		LDA !41_Particle_Timer,x				;\
		AND #$00FF						; |
		ASL A							; | calculate circle size
		CMP #$0020						; |
		BCC $03 : LDA #$0020					; |
		TAY							;/
		LDA $08							;\ calculate final Y
		CLC : ADC $2307						;/
		PLB							; bank wrapper end


	; $02 = Xpos of rotation point
	; $04 = Ypos of rotation point
		.Rotate
		STA $04							; Y pos of rotation point

		LDA !Particle_Timer,x
		AND #$00FF
		CMP #$0018
		BCC $01 : LSR A
		CLC : ADC $0A

		.GetCircle
		AND #$003F
		ASL #4
		STA $0C
		STZ $0E
		CMP #$0200
		BCC $02 : DEC $0E
		AND #$01FE
		TAX
		PHB : PHK : PLB
		LDA.l !TrigTable,x
		EOR $0E
		STZ $2250
		STA $2251
		STY $2253
		NOP : BRA $00
		LDA $2307
		CLC : ADC $02
		STA $02
		LDA $0C
		SEC : SBC #$0100
		STZ $0E
		AND #$03FF
		CMP #$0200
		BCC $02 : DEC $0E
		AND #$01FE
		TAX
		LDA.l !TrigTable,x
		EOR $0E
		STA $2251
		STY $2253
		NOP : BRA $00
		LDA $2307
		CLC : ADC $04
		STA $04


		LDX $00
		PLB


		.Draw
		LDA $02 : STA !Particle_XLo,x
		LDA $04 : STA !Particle_YLo,x


		LDA !Particle_Timer,x
		LSR #2
		AND #$0001
		ORA #$3458
		STA !Particle_TileTemp

		STZ !Particle_TileTemp+2
		JSR ParticleDrawSimple_BG1


		RTS							;/




















