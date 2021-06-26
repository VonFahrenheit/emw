Projectile:

	namespace Projectile


; This sprite is quite customizible.
; Behaviour is determined by $BE,x and graphics are determined by $33D0,x
; Setting the highest bit of $BE,x will cause the sprite to animate.
; $33E0 is number of frames.
; $3340 is current frame.
; $3420 is how long current frame should be shown.
; $3310 is how long to show each frame.


; --Defines--

	!Immortal	= $3280,x		; if non-zero, sprite does not die from time

	!LastFrame	= $33E0,x
	!CurrentFrame	= $3340,x
	!AnimTimer	= $3420,x
	!AnimFreq	= $3310,x
	!AnimType	= $35D0,x		; 00 = normal type
						; 01 = spinning type
						; 02 = big type


	!HardProp	= $3410,x		; Setting this causes sprite to use $33C0,x for YXPPCCCT


	INIT:
		PHB : PHK : PLB
		LDA !GFX_status+$14 : STA $3340,x
		LDA #$01 : STA $BE,x
		LDA #$01 : STA !Immortal
		PLB

	MAIN:
		PHB : PHK : PLB
		LDA !Immortal : BEQ +
		LDA #$20 : STA $32D0,x
	+	JSL SPRITE_OFF_SCREEN		; Handle sprite while offscreen
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BNE Graphics
		LDA $7493
		BEQ LoadAction
		STZ $32D0,x			; Kill sprite
LoadAction:	PHX				; Preserve sprite index
		LDA $BE,x
		AND #$3F
		ASL A
		TAX				; X = pointer index
		JMP (ActionPointer,x)
ReturnAction:	LDA $32D0,x			; Check life timer
		BNE Graphics
		BIT $BE,x
		BVC +
		STZ $3230,x
		PLB
		RTL

	+	LDA #$04
		STA $3230,x			; Kill sprite
		LDA #$1F
		STA $32D0,x
		STA $3300,x			; > Prevent player 2 glitch
		PLB
		RTL

Graphics:



JSR SpawnParticle



		LDA !AnimType
		CMP #$02 : BNE .NormalType

		.BigType
		LDA !HardProp : BEQ +
		LDA $33C0,x
		BRA ++
	+	LDY $3320,x			;\
		LDA Property,y			; | YXPPCCCT byte (basic)
	++	STA $00				;/
		LDA $33D0,x : STA $01
		REP #$20
		LDA #$0010 : STA !BigRAM+$00
		LDA #$F8F8 : STA !BigRAM+$03
		LDA #$F808 : STA !BigRAM+$07
		LDA #$08F8 : STA !BigRAM+$0B
		LDA #$0808 : STA !BigRAM+$0F
		SEP #$20

		LDA $14
		AND #$04
		BEQ $02 : LDA #$01
		TAY
		LDA $00
		CLC : ADC BigTiles+0,y
		STA !BigRAM+$05
		INC #2
		STA !BigRAM+$09
		CLC : ADC BigTiles+2,y
		STA !BigRAM+$0D
		INC #2
		STA !BigRAM+$11

		LDA $14
		AND #$04
		BEQ $02 : LDA #$80
		EOR $01
		ORA #$32
		STA !BigRAM+$02
		STA !BigRAM+$06
		STA !BigRAM+$0A
		STA !BigRAM+$0E
		JMP FinishGFX


		.NormalType
		LDA #$04
		STA !BigRAM+$00			;\ Tilemap size: 4 bytes
		STZ !BigRAM+$01			;/
		STZ !BigRAM+$03			; > No Xdisp
		STZ !BigRAM+$04			; > No Ydisp
		LDA !HardProp : BEQ +
		LDA $33C0,x : BRA ++
	+	LDY $3320,x			;\
		LDA Property,y			; | YXPPCCCT byte (basic)
	++	;ORA !SpriteProp,x		; |
		STA !BigRAM+$02			;/
		LDA !AnimType
		CMP #$01 : BNE .ReallyNormal

		.SpinType
		LDA $14
		AND #$0C
		LSR #2
		TAY
		LDA $33D0,x
	;	CLC : ADC SpinTile,y
	;	CLC : ADC !SpriteTile,x
		STA !BigRAM+$05
		LDA !BigRAM+$02
		EOR SpinFlip,y
	;	ORA !SpriteProp,x
		STA !BigRAM+$02
		BRA FinishGFX


		.ReallyNormal
		LDA !AnimTimer
		BNE +
		LDA !AnimFreq
		STA !AnimTimer
		LDA !CurrentFrame
		INC A
		CMP !LastFrame
		BNE ++
		LDA #$00
	++	STA !CurrentFrame
	+	LDA !CurrentFrame
		ASL A
		STA $03				; > $03 = frame
		BIT $BE,x			; Check highest bit
		BMI Animate
		STZ $03				; > Clear animation frequency
Animate:	LDA $33D0,x			;\
		CLC : ADC $03			; | Write tile number
	;	CLC : ADC !SpriteTile,x		; |
		STA !BigRAM+$05			;/

FinishGFX:	LDA.b #!BigRAM : STA $04
		LDA.b #!BigRAM>>8 : STA $05

		LDA !BigRAM+2
		AND #$20 : BEQ .LoPrio
	.HiPrio	JSL LOAD_TILEMAP_p2
		PLB
		RTL

	.LoPrio	JSL LOAD_TILEMAP_p1
ReturnMAIN:	PLB
		RTL

Property:	db $72				; Y0 X1 PP11 CCC010 T1
		db $32				; Y0 X0 PP11 CCC010 T1

BigTiles:	db $00,$20,$1E,$DE

SpinTile:	db $00,$02,$00,$02
SpinFlip:	db $00,$00,$C0,$C0





ActionPointer:	dw Action00
		dw Action01
		dw Action02
		dw BigShot

Action00:	PLX				; X = sprite index

		BIT $BE,x
		BVC +
		JSL $01801A
		JSL $018022
		LDA $9E,x
		CLC : ADC #$03
		BMI ++
		CMP #$40
		BCC $02 : LDA #$40
	++	STA $9E,x
		JMP ReturnAction

	+	JSL $01802A			; Apply speed with gravity

;		LDA !AnimType : BNE NoXFlip00	; Don't xflip if spin is set
;		LDA $14
;		AND #$07			; Xflip sprite every 08 frames
;		BNE NoXFlip00
;		LDA $3320,x
;		EOR #$01
;		STA $3320,x
NoXFlip00:	LDA $32E0,x
		ORA !P1Dead
		BNE NoContact00
		JSL $03B664			;\
		JSL $03B69F			; | Check for Mario contact
		JSL $03B72B			;/
		BCC NoContact00
		JSL $00F5B7			; Hurt Mario
		STZ $32D0,x			; Kill sprite
NoContact00:	LDA $3330,x
		BEQ Return00
		STZ $32D0,x			; Kill sprite
Return00:	JMP ReturnAction


XSpeed_01:	;db $01,$FF

Action01:	PLX				; X = sprite index
		LDA $3330,x
		AND #$04 : PHA
		LDA $9E,x : PHA
		JSL $01802A			; Apply speed with gravity
		PLA : STA $00
		PLA : BNE .ok
		EOR $3330,x
		AND #$04
		BEQ .ok
		LDA !Immortal : BEQ .ok
		LDA $3330,x			; immortal version bounces upon landing
		AND #$04 : BEQ .ok
		LDA $00 : BMI .ok
		CMP #$08 : BCC .ok
		LSR A
		EOR #$FF
		STA $9E,x
		.ok


;		LDA #$01
;		STA $00				; Set up loop
;		LDA $14
;		AND #$0F
;		BNE EndLoop01			; Only spawn every 0F frames
;		LDY #$0C
;Loop01:		DEY
;		BMI EndLoop01
;		LDA $77F0,y
;		BNE Loop01
;		LDA #$01			;\ Minor ExSprite = Brick Piece
;		STA $77F0,y			;/
;		LDA $3210,x			;\
;		CLC				; |
;		ADC #$0C			; |
;		STA $77FC,y			; |
;		LDA $3240,x			; | Spawn 0C pixels below sprite
;		ADC #$00			; |
;		STA $7814,y			; |
;		LDA $3220,x			; |
;		STA $7808,y			; | Spawn at sprite pos
;		LDA $3250,x			; |
;		STA $78EA,y			;/
;		LDA #$FD			;\ Set Y speed
;		STA $7820,y			;/
;		PHY				;\
;		LDY $00				; |
;		LDA XSpeed_01,y			; | Set X speed
;		PLY				; |
;		STA $782C,y			;/
;		LDA #$00			;\ Set timer
;		STA $7850,y			;/
;		DEC $00
;		BPL Loop01			; Loop once
EndLoop01:	LDA $32E0,x
		ORA !P1Dead
		BNE NoContact01
		JSL $03B664			;\
		JSL $03B69F			; | Check for Mario contact
		JSL $03B72B			;/
		BCC NoContact01
		JSL $00F5B7			; Hurt Mario
NoContact01:	LDA $3330,x
		AND #$03
		BEQ Return01
		STZ $32D0,x			; Kill sprite
Return01:	JMP ReturnAction

Action02:	PLX
		JSL $01801A
		JSL $018022
		LDA $32E0,x
		ORA !P1Dead
		BNE Return02
		JSL $03B664			;\
		JSL $03B69F			; | Check for Mario contact
		JSL $03B72B			;/
		BCC Return02
		JSL $00F5B7			; Hurt Mario
Return02:	JMP ReturnAction

BigShot:	PLX
		STZ $9E,x			;\ Apply speed with gravity but no y speed
		JSL $01802A			;/
		LDA $3330,x
		AND #$0F : BNE .Kill
		LDA $3220,x
		SEC : SBC #$02
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$02
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$14
		STA $06
		STA $07
		LDA !P1Dead : BNE .Return
		JSL !GetP1Clipping
		JSL !CheckContact
		BCC .Return
		JSL $00F5B7

		.Kill
		STZ $32D0,x
.Return		JMP ReturnAction




	SpawnParticle:

LDA $32D0,x
CMP #$08 : BCC .Spawn
RTS

		.Spawn
		PHB
		JSL !GetParticleIndex
		PLB
		LDY !SpriteIndex
		SEP #$20
		LDA $3220,y : STA !41_Particle_XLo,x
		LDA $3250,y : STA !41_Particle_XHi,x
		LDA $3210,y : STA !41_Particle_YLo,x
		LDA $3240,y : STA !41_Particle_YHi,x
		LDA #!prt_basic : STA !41_Particle_Type,x
		LDA #$FF : STA !41_Particle_Timer,x
		LDA !GFX_NoviceShaman : STA $00
		AND #$F0 : TRB $00
		ASL A
		ORA $00
		CLC : ADC #$4D
		STA !41_Particle_Tile,x
		LDA $33C0,y : STA !41_Particle_Prop,x
		LDA #$02 : STA !41_Particle_Layer,x

		REP #$20
		LDA.w !SpriteXSpeed,y
		AND #$00FF
		ASL #3
		CMP #$0400
		BCC $03 : ORA #$F800
		STA $00
		LDA !RNG
		AND #$00F0
		SEC : SBC #$0080
		CLC : ADC $00
		STA !41_Particle_XSpeed,x
		SEP #$20
		LDA !RNG
		AND #$07
		SEC : SBC #$05
		STA !41_Particle_YAcc,x




		SEP #$10
		TYX


		RTS



	namespace off













