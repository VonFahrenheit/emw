

; data struct for each particle:
; 17 bytes per particle
;
; -- misc --
; $00 particle type (highest bit toggles init/main)
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

; to spawn a particle:
;	- set X/Y coords
;	- set X/Y speed
;	- set X/Y acceleration
;	- set tile number
;	- set prop
;	- set layer (size almost always required but layer bits can usually be skipped)
;	- set timer
;
; some particles have hardcoded values and can have some parameters skipped



; particle type:
;
;	 particle type number
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
;
;	llprrrs-
;
;	s
;	 oam size bit
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
		PHB							;\
		PHP							; |
		SEP #$20						; | push B/P, set bank to 0x41, regs 16-bit
		LDA #$41						; |
		PHA : PLB						; |
		REP #$30						;/


; DEBUG: display current number of particles
;		LDY #$0000
;	-	LDA !Particle_Type,x
;		AND #$00FF : BEQ +
;		INY
;	+	TXA
;		CLC : ADC #$0011
;		CMP #$06A4 : BCS +
;		TAX
;		BRA -
;	+	TYA : STA.l !P1Coins


		LDX #$0000						; starting index
		LDA !DizzyEffect					;\ turbo paradigm: 1 copy of code with dizzy and 1 copy without it
		AND #$00FF : BNE .IncludeDizzyEffect			;/

	.NoDizzy
		..check
		LDA !Particle_Type,x					;\
		AND #$00FF : BNE ..call					; |
		..next							; |
		TXA							; | loop through table and process all particles
		CLC : ADC.w #!Particle_Size				; |
		TAX							; |
		CPX.w #!Particle_Size*!Particle_Count : BCC ..check	;/
		PLP							;\
		PLB							; | pull B/P and return
		RTS							;/
		..call							;\
		STX $00							; |
		ASL A							; |
		CMP.w #.List_End-.List : BCC ..valid			; |
		JSR .ClearParticle					; | call particle code
		BRA ..next						; | (invalid goes to .ClearParticle)
		..valid							; |
		TAX							; |
		JSR (.List-2,x)						; |
		REP #$20						; |
		BRA ..next						;/


	.IncludeDizzyEffect
		..check
		LDA !Particle_Type,x					;\
		AND #$00FF : BNE ..call					; |
		..next							; |
		TXA							; | loop through table and process all particles
		CLC : ADC.w #!Particle_Size				; |
		TAX							; |
		CPX.w #!Particle_Size*!Particle_Count : BCC ..check	;/
		PLP							;\
		PLB							; | pull B/P and return
		RTS							;/
		..call							;\
		STX $00							; |
		ASL A							; |
		CMP.w #.List_End-.List : BCC ..valid			; | loop over all particles
		JSR .ClearParticle					; | (invalid goes to .ClearParticle)
		BRA ..next						; |
		..valid							;/
		TAY							;\
		LDA !CameraBackupY : STA $1C				; |
		LDA !Particle_XLo,x					; |
		SEC : SBC $1A						; |
		AND #$00FF						; |
		LSR #3							; |
		ASL A							; | apply dizzy offset
		TAX							; |
		LDA !DecompBuffer+$1040,x				; |
		AND #$01FF						; |
		CMP #$0100						; |
		BCC $03 : ORA #$FE00					; |
		STA $1C							; |
		TYX							;/
		JSR (.List-2,x)						;\
		REP #$20						; | call particle code
		BRA ..next						;/


	.ClearParticle
		LDX $00
		STZ !Particle_Base+$00,x
		STZ !Particle_Base+$02,x
		STZ !Particle_Base+$04,x
		STZ !Particle_Base+$06,x
		STZ !Particle_Base+$08,x
		STZ !Particle_Base+$0A,x
		STZ !Particle_Base+$0C,x
		STZ !Particle_Base+$0E,x
		STZ !Particle_Base+$0F,x
		RTS

		.List
		dw BasicParticle_BG1		; 01
		dw BasicParticle_BG2
		dw BasicParticle_BG3
		dw BasicParticle_Cam
		dw RatioParticle_BG1
		dw RatioParticle_BG2
		dw RatioParticle_BG3
		dw RatioParticle_Cam
		dw AnimAddParticle_BG1
		dw AnimAddParticle_BG2
		dw AnimAddParticle_BG3
		dw AnimAddParticle_Cam
		dw AnimSubParticle_BG1
		dw AnimSubParticle_BG2
		dw AnimSubParticle_BG3
		dw AnimSubParticle_Cam
		dw SmokeParticle8x8
		dw SmokeParticle16x16
		dw ContactParticle
		dw ContactBigParticle
		dw SpritePart
		dw CoinGlitterParticle
		dw SparkleParticle
		dw LeafParticle

		dw .ClearParticle		; final index, a particle is set to this when it's erased which makes it clear its data next frame

		..End


incsrc "Particles/BasicParticle.asm"
incsrc "Particles/RatioParticle.asm"
incsrc "Particles/AnimAddParticle.asm"
incsrc "Particles/AnimSubParticle.asm"
incsrc "Particles/SmokeParticle8x8.asm"
incsrc "Particles/SmokeParticle16x16.asm"
incsrc "Particles/ContactParticle.asm"
incsrc "Particles/ContactBigParticle.asm"
incsrc "Particles/SpritePart.asm"
incsrc "Particles/CoinGlitterParticle.asm"
incsrc "Particles/SparkleParticle.asm"
incsrc "Particles/LeafParticle.asm"



; returns:
;	16-bit A
;	index unchanged

	ParticleSpeed:

		.Wind
		REP #$20						;\
		LDY #$0000						; |
		LDA !Particle_XSpeed,x					; |
		CLC : ADC !Particle_WindX				; > add wind
		BPL $01 : DEY						; |
		CLC : ADC !Particle_XSub,x				; | update X pos
		STA !Particle_XSub,x					; |
		SEP #$20						; |
		TYA							; |
		ADC !Particle_XHi,x					; |
		STA !Particle_XHi,x					;/
		REP #$20						;\
		LDA !Particle_XAcc,x					; |
		AND #$00FF						; |
		CMP #$0080						; | update X speed
		BCC $03 : ORA #$FF00					; |
		CLC : ADC !Particle_XSpeed,x				; |
		STA !Particle_XSpeed,x					;/
		LDY #$0000						;\
		LDA !Particle_YSpeed,x					; |
		CLC : ADC !Particle_WindY				; > add wind
		BPL $01 : DEY						; |
		CLC : ADC !Particle_YSub,x				; |
		STA !Particle_YSub,x					; | update Y pos
		SEP #$20						; |
		TYA							; |
		ADC !Particle_YHi,x					; |
		STA !Particle_YHi,x					;/
		REP #$20						;\
		LDA !Particle_YAcc,x					; |
		AND #$00FF						; |
		CMP #$0080						; | update Y speed
		BCC $03 : ORA #$FF00					; |
		CLC : ADC !Particle_YSpeed,x				; |
		STA !Particle_YSpeed,x					;/
		RTS							; return

		.NoWind
		REP #$20						;\
		LDY #$0000						; |
		LDA !Particle_XSpeed,x					; |
		BPL $01 : DEY						; |
		CLC : ADC !Particle_XSub,x				; | update X pos
		STA !Particle_XSub,x					; |
		SEP #$20						; |
		TYA							; |
		ADC !Particle_XHi,x					; |
		STA !Particle_XHi,x					;/
		REP #$20						;\
		LDA !Particle_XAcc,x					; |
		AND #$00FF						; |
		CMP #$0080						; | update X speed
		BCC $03 : ORA #$FF00					; |
		CLC : ADC !Particle_XSpeed,x				; |
		STA !Particle_XSpeed,x					;/
		LDY #$0000						;\
		LDA !Particle_YSpeed,x					; |
		BPL $01 : DEY						; |
		CLC : ADC !Particle_YSub,x				; |
		STA !Particle_YSub,x					; | update Y pos
		SEP #$20						; |
		TYA							; |
		ADC !Particle_YHi,x					; |
		STA !Particle_YHi,x					;/
		REP #$20						;\
		LDA !Particle_YAcc,x					; |
		AND #$00FF						; |
		CMP #$0080						; | update Y speed
		BCC $03 : ORA #$FF00					; |
		CLC : ADC !Particle_YSpeed,x				; |
		STA !Particle_YSpeed,x					;/
		RTS							; return



; input:
;	16-bit A
;	16-bit index
;	!TileTemp: tile num, yxppccct, size bit (3 bytes in that order)
;
; returns:
;	16-bit A
;	index unchanged
;
; XTemp: 16-bit relative layer + 16-bit work area
; YTemp: 16-bit relative layer + 16-bit work area
; TileTemp: tile num, yxppccct, size bit (3 bytes in that order)

	macro DrawParticle(p)
		LDY.w !OAMindex_<p>
		CPY #$0200 : BCS ..BadCoord
		LDA !Particle_XTemp
		CMP #$0100 : BCC ..GoodX
		CMP #$FFF0 : BCS ..GoodX
	..BadCoord
		RTS
	..GoodX
		AND #$01FF
		STA !Particle_XTemp
		LDA !Particle_YTemp
		CMP #$00E0 : BCC ..GoodY
		CMP #$FFF0 : BCC ..BadCoord
	..GoodY
		SEP #$20
		STA.w !OAM_<p>+$001,y
		LDA !Particle_XTemp : STA.w !OAM_<p>+$000,y
		LDA !Particle_TileTemp : STA.w !OAM_<p>+$002,y
		LDA !Particle_TileTemp+1 : STA.w !OAM_<p>+$003,y
		REP #$20
		LDA.w !OAMindex_<p>
		CLC : ADC #$0004
		STA.w !OAMindex_<p>
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA !Particle_XTemp+1
		AND #$01
		ORA !Particle_TileTemp+2
		STA.w !OAMhi_<p>,y
		REP #$20
		RTS
	endmacro

	ParticleDrawSimple:
		LDA !Particle_Layer,x					;\
		AND #$00C0 : BEQ .BG1					; | check which layer particle is on
		CMP #$0040 : BEQ .BG2					; |
		CMP #$0080 : BEQ .BG3					;/
	.Cam	LDA !Particle_XLo,x : STA !Particle_XTemp		;\
		LDA !Particle_YLo,x : STA !Particle_YTemp		; | camera
		BRA .Draw						;/
	.BG3	LDA $22							;\
		STA !Particle_XTemp					; | BG3
		LDA $24							; |
		BRA .W							;/
	.BG2	LDA $1E							;\
		STA !Particle_XTemp					; | BG2
		LDA $20							; |
		BRA .W							;/
	.BG1	LDA $1A							;\
		STA !Particle_XTemp					; | BG1
		LDA $1C							;/
	.W	STA !Particle_YTemp					; write Y coordinate
		LDA !Particle_XLo,x					;\
		SEC : SBC !Particle_XTemp				; |
		STA !Particle_XTemp					; | calculate on-screen position
		LDA !Particle_YLo,x					; |
		SEC : SBC !Particle_YTemp				; |
		STA !Particle_YTemp					;/
	.Draw

	ParticleFinishDraw:
		LDA !Particle_Prop,x					;\
		AND #$00C0 : BNE $03 : JMP .p0				; | see which table should be written to
		CMP #$0040 : BNE $03 : JMP .p1				; | (bespoke code for each one to speed up the process)
		CMP #$0080 : BEQ .p2					;/
	.p3	%DrawParticle(p3)
	.p2	%DrawParticle(p2)
	.p1	%DrawParticle(p1)
	.p0	%DrawParticle(p0)

	ParticleDrawRatio:
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
		AND #$001C : BEQ .RatioDone				;/
		LSR A							;\
		PHX							; |
		TAX							; | apply ratio
		JSR (.RatioPtr-2,x)					; |
		PLX							;/
	.RatioDone
		LDA !Particle_Layer,x					;\
		AND #$0020 : BEQ .Plus100Done				; |
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

	.Draw	JMP ParticleFinishDraw



	.RatioPtr
		dw ..87		; 1
		dw ..75		; 2
		dw ..62		; 3
		dw ..50		; 4
		dw ..37		; 5
		dw ..25		; 6
		dw ..12		; 7

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



; call this after draw routine, which saves screen cords in $00 + $02
; this will despawn the particle if it's offscreen and moving away from the camera


; X:
;	100-17F: despawn right
;	180-1F0: despawn left
; Y:
;	0E0-17F: despawn down
;	180-1F0: despawn up

	ParticleDespawn:
		LDA !Particle_XTemp
		CMP #$0100 : BCC .XDone
		CMP #$0180 : BCS .Left
		.Right
		LDA !Particle_XSpeed,x : BPL .Despawn
		.Left
		CMP #$01F0 : BCS .XDone
		LDA !Particle_XSpeed,x : BMI .Despawn
		.XDone

		LDA !Particle_YTemp
		AND #$01FF
		CMP #$00E0 : BCC .YDone
		CMP #$0180 : BCS .Up
		.Down
		LDA !Particle_YSpeed,x : BPL .Despawn
		.Up
		CMP #$01F0 : BCS .YDone
		LDA !Particle_YSpeed,x : BPL .YDone
		.Despawn
		LDA.w #(ParticleMain_List_End-ParticleMain_List)/2 : STA !Particle_Type,x
		.YDone
		RTS








