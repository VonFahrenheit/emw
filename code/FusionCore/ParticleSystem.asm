




; data struct for each particle:
; 17 bytes per particle
;
; -- misc --
; $00 particle type (hi bit toggles air resistance)
; $01 tile number
; $02 property byte
; $03 layer + ratio
; $04 timer/data
; -- X --
; $05 X sub
; $06 X lo
; $07 X hi
; $08 X speed lo
; $09 X speed hi
; $0A X accel
; -- Y --
; $0B Y sub
; $0C Y lo
; $0D Y hi
; $0E Y speed lo
; $0F Y speed hi
; $10 Y accel


; particle type:
;
;	annnnnnn
;	a
;	 air resistance
;	 when set, particle will lose a percentage of its speed every frame
;	nnnnnnn
;	 particle type
;	 this determines special code and animation
;
; tile number:
;	written to OAM +2
;
; properties:
;	ooppccct
;	ppccct
;	 written to OAM +3
;	oo
;	 which OAM table to use
;
; layer:
;	ll-sprrr
;	rrr
;	 scroll ratio to attached layer
;	 0 - 100%
;	 1 - 87.5%
;	 2 - 75%
;	 3 - 62.5%
;	 4 - 50%
;	 5 - 37.5%
;	 6 - 25%
;	 7 - 12.5%
;	s
;	 oam size bit
;	p
;	 plus 100% scroll rate bit
;	 when set, the initial scroll value is added to the result after ratio is applied
;	 this way ratios of 112.5% - 200% can be used
;	ll
;	 which layer the particle is attached to
;	 00 - layer 1
;	 01 - layer 2
;	 02 - layer 3
;	 03 - camera (screen relative instead of level relative)	 
;
; timer:
;	ticks down every frame, particle despawns when this hits 0
;	if timer is set to 0 through some other means (such as spawning it with time = 0), particle will last indefinitely
;
;

; chunk:
; save 24 cycles each speed call
; lose 7 cycles for each index check
; basically... we gain 17 cycles each time a particle is processed, but lose 7 cycles for each empty slot
; this is better for processing a lot of particles at once but worse if you want no particles at all
; obviously there is no way to swap between them
;

	ParticleMain:
		PHP
		REP #$30
		LDX #$0000
	.Check	LDA !Particle_Type,x
		AND #$007F : BNE .Call
	.Next	TXA
		CLC : ADC #$0011
		TAX
		CPX.w #17*100 : BCC .Check
		PLP
		RTS

	.Call	PHX
		ASL A
		CMP.w #.List_End-.List
		BCC $03 : LDA #$0000
		STX $00
		TAX
		JSR (.List,x)						; PEA.w .Next-1 : JMP (.List,x) uses the same amount of cycles but takes an extra ROM byte
		BRA .Next

		.List
		dw BasicParticle
		..End


incsrc "Particles/BasicParticle.asm"



; returns:
;	16-bit A
;	index unchanged

	ParticleSpeed:
		REP #$20
		LDY #$0000
		LDA !Particle_XSpeed,x
		BPL $01 : DEY
		CLC : ADC !Particle_XSub,x
		STA !Particle_XSub,x
		SEP #$20
		TYA
		ADC !Particle_XHi,x
		STA !Particle_XHi,x
		REP #$20
		LDA !Particle_XAcc,x
		AND #$00FF
		ASL A
		CMP #$0100
		BCC $03 : ORA #$FF00
		CLC : ADC !Particle_XSpeed,x
		STA !Particle_XSpeed,x
		LDY #$0000
		LDA !Particle_YSpeed,x
		BPL $01 : DEY
		CLC : ADC !Particle_YSub,x
		STA !Particle_YSub,x
		SEP #$20
		TYA
		ADC !Particle_YHi,x
		STA !Particle_YHi,x
		REP #$20
		LDA !Particle_YAcc,x
		AND #$00FF
		ASL A
		CMP #$0100
		BCC $03 : ORA #$FF00
		CLC : ADC !Particle_YSpeed,x
		STA !Particle_YSpeed,x
		RTS

; returns:
;	8-bit A
;	index unchanged
;
; XTemp: 16-bit relative layer + 16-bit work area
; YTemp: 16-bit relative layer + 16-bit work area
; TileTemp: tile num, yxppccct, size bit (3 bytes in that order)

	ParticleDraw:
		LDA !Particle_Layer,x					;\
		AND #$00C0 : BEQ .BG1					; | check which layer particle is on
		CMP #$0040 : BEQ .BG2					; |
		CMP #$0080 : BEQ .BG3					;/
	.Cam	LDA !Particle_XLo,x : STA !Particle_XTemp		;\
		LDA !Particle_YLo,x : STA !Particle_YTemp		; | camera
		BRA .Draw						;/
	.BG3	LDA $22							;\
		STA !Particle_XTemp					; |
		STA !Particle_XTemp+2					; | BG3
		LDA $24							; |
		BRA .W							;/
	.BG2	LDA $1E							;\
		STA !Particle_XTemp					; |
		STA !Particle_XTemp+2					; | BG2
		LDA $20							; |
		BRA .W							;/
	.BG1	LDA $1A							;\
		STA !Particle_XTemp					; | BG1
		STA !Particle_XTemp+2					; |
		LDA $1C							;/
	.W	STA !Particle_YTemp					;\ write Y coordinate
		STA !Particle_YTemp+2					;/
		LDA !Particle_Layer,x					;\ skip ratio calc if ratio is 100%
		AND #$0007 : BEQ .RatioDone				;/
		ASL A							;\
		PHX							; |
		TAX							; | apply ratio
		JSR (.RatioPtr,x)					; |
		PLX							;/
	.RatioDone
		LDA !Particle_Layer,x					;\
		AND #$0008 : BEQ .Plus100Done				; |
		LDA !Particle_XTemp					; |
		CLC : ADC !Particle_XTemp+2				; | apply +100% to ratio if enabled
		STA !Particle_XTemp					; |
		LDA !Particle_YTemp					; |
		CLC : ADC !Particle_YTemp+2				; |
		STA !Particle_YTemp					;/
	.Plus100Done
		LDA !Particle_XLo,x					;\
		SEC : SBC !Particle_XTemp				; |
		STA !Particle_XTemp					; | calculate on-screen position
		LDA !Particle_YLo,x					; |
		SEC : SBC !Particle_YTemp				; |
		STA !Particle_YTemp					;/


	.Draw
		LDA !Particle_Prop,x					;\
		AND #$00C0 : BNE $03 : JMP .p0				; | see which table should be written to
		CMP #$0040 : BNE $03 : JMP .p1				; | (bespoke code for each one to speed up the process)
		CMP #$0080 : BEQ .p2					;/

	.p3
		LDY.w !OAMindex_p3
		CPY #$0200 : BCS ..BadCoord
		LDA !Particle_XTemp
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF0 : BCS ..GoodX
	..BadCoord
		SEP #$20
		RTS
	..GoodX
		AND #$01FF
		STA !Particle_XTemp
		LDA !Particle_YTemp
		CMP #$00E0 : BCC ..GoodY
		CMP #$FFF0 : BCC ..BadCoord
	..GoodY
		SEP #$20
		STA.w !OAM_p3+$001,x
		LDA !Particle_XTemp : STA.w !OAM_p3+$000,y
		LDA !Particle_Tile,x : STA.w !OAM_p3+$002,y
		LDA !Particle_TileTemp+1 : STA.w !OAM_p3+$003,y
		REP #$20
		INC.w !OAMindex_p3
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA !Particle_XTemp+1
		AND #$01
		ORA !Particle_TileTemp+2
		STA.w !OAMhi_p3,y
		RTS

	.p2
		LDY.w !OAMindex_p2
		CPY #$0200 : BCS ..BadCoord
		LDA !Particle_XTemp
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF0 : BCS ..GoodX
	..BadCoord
		SEP #$20
		RTS
	..GoodX
		AND #$01FF
		STA !Particle_XTemp
		LDA !Particle_YTemp
		CMP #$00E0 : BCC ..GoodY
		CMP #$FFF0 : BCC ..BadCoord
	..GoodY
		SEP #$20
		STA.w !OAM_p2+$001,x
		LDA !Particle_XTemp : STA.w !OAM_p2+$000,y
		LDA !Particle_Tile,x : STA.w !OAM_p2+$002,y
		LDA !Particle_TileTemp+1 : STA.w !OAM_p2+$003,y
		REP #$20
		INC.w !OAMindex_p2
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA !Particle_XTemp+1
		AND #$01
		ORA !Particle_TileTemp+2
		STA.w !OAMhi_p2,y
		RTS

	.p1
		LDY.w !OAMindex_p1
		CPY #$0200 : BCS ..BadCoord
		LDA !Particle_XTemp
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF0 : BCS ..GoodX
	..BadCoord
		SEP #$20
		RTS
	..GoodX
		AND #$01FF
		STA !Particle_XTemp
		LDA !Particle_YTemp
		CMP #$00E0 : BCC ..GoodY
		CMP #$FFF0 : BCC ..BadCoord
	..GoodY
		SEP #$20
		STA.w !OAM_p1+$001,x
		LDA !Particle_XTemp : STA.w !OAM_p1+$000,y
		LDA !Particle_Tile,x : STA.w !OAM_p1+$002,y
		LDA !Particle_TileTemp+1 : STA.w !OAM_p1+$003,y
		REP #$20
		INC.w !OAMindex_p1
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA !Particle_XTemp+1
		AND #$01
		ORA !Particle_TileTemp+2
		STA.w !OAMhi_p1,y
		RTS

	.p0
		LDY.w !OAMindex_p0
		CPY #$0200 : BCS ..BadCoord
		LDA !Particle_XTemp
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF0 : BCS ..GoodX
	..BadCoord
		SEP #$20
		RTS
	..GoodX
		AND #$01FF
		STA !Particle_XTemp
		LDA !Particle_YTemp
		CMP #$00E0 : BCC ..GoodY
		CMP #$FFF0 : BCC ..BadCoord
	..GoodY
		SEP #$20
		STA.w !OAM_p0+$001,x
		LDA !Particle_XTemp : STA.w !OAM_p0+$000,y
		LDA !Particle_Tile,x : STA.w !OAM_p0+$002,y
		LDA !Particle_TileTemp+1 : STA.w !OAM_p0+$003,y
		REP #$20
		INC.w !OAMindex_p0
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA !Particle_XTemp+1
		AND #$01
		ORA !Particle_TileTemp+2
		STA.w !OAMhi_p0,y
		RTS


	.RatioPtr
		dw ..100
		dw ..87
		dw ..75
		dw ..62
		dw ..50
		dw ..37
		dw ..25
		dw ..12

	..87
		LDA !Particle_XTemp
		LSR #3
		SEC : SBC !Particle_XTemp
		EOR #$FFFF : INC A
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR #3
		SEC : SBC !Particle_YTemp
		EOR #$FFFF : INC A
		STA !Particle_YTemp
	..100	RTS

	..75
		LDA !Particle_XTemp
		LSR #2
		SEC : SBC !Particle_XTemp
		EOR #$FFFF : INC A
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR #2
		SEC : SBC !Particle_YTemp
		EOR #$FFFF : INC A
		STA !Particle_YTemp
		RTS

	..62
		LDA !Particle_XTemp
		LSR A
		STA !Particle_XTemp
		LSR #2
		CLC : ADC !Particle_XTemp
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR A
		STA !Particle_YTemp
		LSR #2
		CLC : ADC !Particle_YTemp
		STA !Particle_YTemp
		RTS

	..50
		LSR !Particle_XTemp
		LSR !Particle_YTemp
		RTS

	..37
		LDA !Particle_XTemp
		LSR A
		STA !Particle_XTemp
		LSR #2
		SEC : SBC !Particle_XTemp
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR A
		STA !Particle_YTemp
		LSR #2
		SEC : SBC !Particle_YTemp
		STA !Particle_YTemp
		RTS

	..25
		LDA !Particle_XTemp
		LSR #2
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR #2
		STA !Particle_YTemp
		RTS

	..12
		LDA !Particle_XTemp
		LSR #3
		STA !Particle_XTemp
		LDA !Particle_YTemp
		LSR #3
		STA !Particle_YTemp
		RTS





; returns:
;	8-bit A
;	16-bit index
;	X = index to particle
;	if C = 0, there are no free slots, meaning that spawning a new particle will overwrite an old one (X is still an index)
;	if C = 1, the current slot is free

	ParticleIndex:
		REP #$30
		LDA.l !Particle_Index : TAX

	.CheckIndex
		LDA !Particle_Type,x
		AND #$007F : BEQ .ThisOne

	.SearchForward
		TXA
		CMP.l !Particle_Index : BEQ .NoSpawn
		CLC : ADC #$0011
		CMP.w #17*100
		BCC $03 : LDA #$0000
		TAX
		BRA .CheckIndex

	.ThisOne
		TXA : STA.l !Particle_Index			; save index so we don't repeatedly check slots we have already confirmed are in use
		SEP #$20
		SEC
		RTS

	.NoSpawn
		SEP #$20
		CLC
		RTS




































