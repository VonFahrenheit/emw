
	WeatherParticle:








	.BG1	LDX $00							; reload index
		JSR ParticleSpeed					; move particle
	..x	LDA !Particle_XLo,x					;\
		SEC : SBC $1A						; |
		BIT !Particle_XSpeed,x					; |
		BPL ..right						; |
	..left	CMP #$0200 : BCC ..y					; | despawn if moving off-screen horizontally
		CMP #$FFE0 : BCS $03 : JMP .Erase			; |
		BRA ..y							; |
	..right	CMP #$FF00 : BCS ..y					; |
		CMP #$0110 : BCC $03 : JMP .Erase			;/
	..y	LDA !Particle_YLo,x					;\
		SEC : SBC $1C						; |
		BIT !Particle_YSpeed,x					; |
		BPL ..down						; |
	..up	CMP #$01E0 : BCC ..draw					; | despawn if moving off-screen vertically
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..draw						; |
	..down	CMP #$FF00 : BCS ..draw					; |
		CMP #$00F0 : BCS .Erase					;/
	..draw	LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawSimple_BG1				; draw particle without ratio






	.BG2	LDX $00							; reload index
		JSR ParticleSpeed					; move particle
	..x	LDA !Particle_XLo,x					;\
		SEC : SBC $1E						; |
		BIT !Particle_XSpeed,x					; |
		BPL ..right						; | despawn if moving off-screen horizontally
	..left	CMP #$0200 : BCC ..y					; |
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..y							; |
	..right	CMP #$0110 : BCS .Erase					;/
	..y	LDA !Particle_YLo,x					;\
		SEC : SBC $20						; |
		BIT !Particle_YSpeed,x					; |
		BPL ..down						; | despawn if moving off-screen horizontally
	..up	CMP #$01E0 : BCC ..draw					; |
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..draw						; |
	..down	CMP #$00F0 : BCS .Erase					;/
	..draw	LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawSimple_BG2				; draw particle without ratio

		.Erase							;\
		LDA.w #(ParticleMain_List_End-ParticleMain_List)/2	; | erase particle and set index to the one that was just freed up
		STA !Particle_Type,x					; | then return
		RTS							;/

	.BG3	LDX $00							; reload index
		JSR ParticleSpeed					; move particle
	..x	LDA !Particle_XLo,x					;\
		SEC : SBC $22						; |
		BIT !Particle_XSpeed,x					; |
		BPL ..right						; | despawn if moving off-screen horizontally
	..left	CMP #$0200 : BCC ..y					; |
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..y							; |
	..right	CMP #$0110 : BCS .Erase					;/
	..y	LDA !Particle_YLo,x					;\
		SEC : SBC $24						; |
		BIT !Particle_YSpeed,x					; |
		BPL ..down						; | despawn if moving off-screen horizontally
	..up	CMP #$01E0 : BCC ..draw					; |
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..draw						; |
	..down	CMP #$00F0 : BCS .Erase					;/
	..draw	LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawSimple_BG3				; draw particle without ratio

	.Cam	LDX $00							; reload index
		JSR ParticleSpeed					; move particle
	..x	LDA !Particle_XLo,x					;\
		BIT !Particle_XSpeed,x					; |
		BPL ..right						; | despawn if moving off-screen horizontally
	..left	CMP #$0200 : BCC ..y					; |
		CMP #$FFE0 : BCC .Erase					; |
		BRA ..y							; |
	..right	CMP #$0110 : BCS .Erase					;/
	..y	LDA !Particle_YLo,x					;\
		BIT !Particle_YSpeed,x					; |
		BPL ..down						; | despawn if moving off-screen horizontally
	..up	CMP #$01E0 : BCC ..draw					; |
		CMP #$FFE0 : BCS $03					; |
	-	JMP .Erase						; |
		BRA ..draw						; |
	..down	CMP #$00F0 : BCS -					;/
	..draw	LDA !Particle_Tile,x					;\
		AND #$3FFF						; | tile number + property byte (X/Y flip clear)
		STA !Particle_TileTemp					;/
		LDA !Particle_Layer,x					;\
		AND #$0002						; | oam size bit
		STA !Particle_TileTemp+2				;/
		JMP ParticleDrawSimple_Cam				; draw particle without ratio

