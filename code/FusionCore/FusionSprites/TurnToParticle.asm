

; !Ex_Data1: which particle to turn into
; !Ex_Data2: base tile
; !Ex_Data3: base prop


	TurnToParticle:
		LDX !SpriteIndex				; reload index
		STX $00 : STZ $01				; set up 16-bit fusion index
		PHB						; bank wrapper start

		JSL GetParticleIndex : TXY			; get particle index in X and Y
		STZ !Particle_XAcc,x				;\ clear acc + sub pixel
		STZ !Particle_YAcc,x				;/

		LDX $00						; X = fusion index
		SEP #$20					; A 8-bit
		LDA.l !Ex_Data1,x : STA !Particle_Type,y	; particle num
		LDA.l !Ex_Data2,x : STA !Particle_Tile,y	;\ particle tile + prop
		LDA.l !Ex_Data3,x : STA !Particle_Prop,y	;/

		LDA.l !Ex_XLo,x : STA !Particle_XLo,y		;\
		LDA.l !Ex_XHi,x : STA !Particle_XHi,y		; | coords
		LDA.l !Ex_YLo,x : STA !Particle_YLo,y		; |
		LDA.l !Ex_YHi,x : STA !Particle_YHi,y		;/

		REP #$20					; A 16-bit

		LDA.l !Ex_XSpeed,x				;\
		AND #$00FF					; |
		ASL #3						; | particle X speed
		CMP #$0400					; |
		BCC $03 : ORA #$F800				; |
		STA !Particle_XSpeed,y				;/
		LDA.l !Ex_YSpeed,x				;\
		AND #$00FF					; |
		ASL #3						; | particle Y speed
		CMP #$0400					; |
		BCC $03 : ORA #$F800				; |
		STA !Particle_YSpeed,y				;/
		SEP #$30					; all regs 8-bit

		PLB						; bank wrapper end
		STZ !Ex_Num,x					; despawn
		RTS						; return






