

;;; CARRY ITEM CODE ;;;

	CARRY:
		PHB : PHK : PLB
		DEX
		LDA !CurrentPlayer : STA !ShellOwner,x		; own the shell
		BIT $15 : BVC .Throw
		JMP .Carry
	.Throw	STZ !P2Carry
		STZ !P2PickUp
		LDA $15						;\
		AND #$0C : BEQ .Forward				; | kick if up/down are not held
		CMP #$0C : BEQ .Forward				;/
		LDY !P2Direction				; Y = index to tables
		CMP #$04 : BEQ .Drop

	.KickUp	LDA !P2XSpeed : STA !SpriteXSpeed,x		; item x speed = player x speed
		LDA #$08 : STA !P2KickTimer			; kick pose
		LDA #$03 : STA !SPC1				; kick sfx
		LDA .CarryOffsetX+0,y : STA $00			;\
		STZ $01						; |
		BPL $02 : DEC $01				; |
		PHX						; |
		PHB						; |
		JSL GetParticleIndex				; |
		LDA.l !P2XPosLo					; |
		CLC : ADC $00					; |
		STA !Particle_X,x				; | contact gfx
		LDA.l !P2YPosLo					; |
		SEC : SBC #$0004				; |
		STA !Particle_Y,x				; |
		LDA.w #!prt_contact : STA !Particle_Type,x	; |
		LDA #$C000 : STA !Particle_Prop,x		; |
		PLB						; |
		SEP #$30					; |
		PLX						;/
		LDA #$90 : BRA +				; item Y speed (go to shared code)

	.Forward
		LDY !P2Direction				;\
		LDA .ThrowSpeed,y : STA !SpriteXSpeed,x		; |
		EOR !P2XSpeed : BMI ..sety			; |
		LDA !P2XSpeed					; | throw x speed
		CMP #$80 : ROR A				; | (reference: $01A087 in all.log)
		CLC : ADC .ThrowSpeed,y				; |
		STA !SpriteXSpeed,x				;/
		..sety						;\ no y speed
		STZ !SpriteYSpeed,x				;/
		LDA #$08 : STA !P2KickTimer			; kick pose
		LDA #$03 : STA !SPC1				; kick sfx
		LDA !SpriteNum,x				;\
		CMP #$08 : BCS ++				; | sprites 00-07 go to state 0A (kicked)
		LDA #$0A : BRA +++				;/

	.Drop	LDA !P2XSpeed					;\
		CLC : ADC .ItemSpeed,y				; | give item x speed
		STA !SpriteXSpeed,x				;/
		LDA #$08					; item Y speed = 8
	+	STA !SpriteYSpeed,x				; set Y speed
	++	LDA #$09					; state 09
	+++	STA !SpriteStatus,x				; write status
		STZ !SpriteStasis,x				; clear stasis from sprite
		LDA #$10					;\
		STA !SpriteDisP1,x				; | item can't interact with players for 16 frames
		STA !SpriteDisP2,x				;/
		STA !SpriteIFrames,x				; give sprites some i-frames
		PLB
		RTL

	.Carry	STZ !SpriteKillCount,x				; clear item's kill count
		STZ !SpriteBlocked,x				; clear item's collision status
		STZ !SpriteSlope,x				; clear item's slope status
		LDA !SpriteStatus,x				;\
		CMP #$0B : BEQ +				; |
		STZ !P2Carry					; | drop item if its status changes
		STZ !P2PickUp					; |
		PLB						; |
		RTL						;/

	+	LDA !P2Direction				;\ item facing
		EOR #$01 : STA !SpriteDir,x			;/
		LDA #$02					;\
		STA !SpriteStasis,x				; | item can't move or interact with players
		STA !SpriteDisP1,x				; |
		STA !SpriteDisP2,x				;/
		LDY !P2Direction				;\
		LDA !P2XPosLo					; |
		CLC : ADC.w .CarryOffsetX+0,y			; |
		STA !SpriteXLo,x				; | set item X coordinate
		LDA !P2XPosHi					; |
		ADC.w .CarryOffsetX+2,y				; |
		STA !SpriteXHi,x				;/
		LDY #$00					;\
		LDA !P2HP					; |
		CMP #$01 : BEQ .Low				; | get height index
		LDA !P2Ducking : BNE .Low			; |
		LDA !P2PickUp : BEQ .High			; |
	.Low	INY						;/
	.High	LDA !P2YPosLo					;\
		SEC : SBC.w .CarryOffsetY,y			; |
		STA !SpriteYLo,x				; | set item Y coordinate
		LDA !P2YPosHi					; |
		SBC #$00					; |
		STA !SpriteYHi,x				;/
		STZ !P2KickTimer				; > clear kick image
		PLB
		RTL


		.CarryOffsetX
		db $F6,$0B
		db $FF,$00

		.CarryOffsetY
		db $04,$02

		.ItemSpeed
		db $F0,$10			; speed for dropping item with no kick

		.ThrowSpeed
		db $CC,$34





