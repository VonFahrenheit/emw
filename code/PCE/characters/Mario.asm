;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Mario


;=================;
;MARIO ADJUSTMENTS;
;=================;

; Look at $00E45D for actual OAM access
;
; 8x8 tile is loaded from $00DFDA ("Mario8x8Tiles" in all.log) indexed by $06
; $06 is loaded from $00DF1A ("TileExpansion?" in all.log)
;
;	Code:
;	LDY $19
;	LDA $73E0
;	CMP #$3D
;	BCS $03 : ADC $DF16,y
;	TAY
;	LDA $DF1A,y
;	STA $06
;	[...]
;	LDX $06
;	LDA $00DFDA,x			; 0x80-0xFF = skip tile


	pushpc

; -- Mario upgrades --

	; throw fireball
	org $00D081
		JML Mario_Fireball		; org: CMP #$03 : BNE $28 ($00D0AD)

	; code that checks air/ground
	org $00D5F2
		JML Mario_AirHook		; org: LDA !MarioAir : BEQ $03 (otherwise JMPs to $00D682)

	; prevent flight
	org $00D674
		BRA $05				;\
		NOP #2				; | org: BNE $05 : LDA #$50 : STA $749F
		STZ $749F			;/

	; ability to float
	org $00D8E9
		JML Mario_Cape1			; org: CMP #$02 : BNE $3B ($00D928)

	; draw cape
	org $00E3FD
		JML Mario_Cape2			; org: CMP #$02 : BNE $57 (careful with repointing! target gone!)

	org $00EA0D
		JSL Mario_HandyGlove		; org: LDA !MarioBlocked : AND #$03


	; first 2 bytes for big Mario, then 2 for small Mario, last 2 are unused
	org $00FE96
		db $00,$08,$00,$08,$FF,$FF	; X lo
	org $00FE9C
		db $00,$00,$00,$00,$FF,$FF	; X hi
	org $00FEA2
		db $08,$08,$10,$10,$FF,$FF	; Y

	org $00FEC4
		JSL Mario_TacticalFire		; org: LDA #$30 : STA !ExSpriteYSpeed,x
		NOP
	org $00FED1
		LDA !MarioPowerUp
		BNE $02 : INY #2
		BRA 6
		NOP #6
	warnpc $00FEDF

	org $01AA33
		JML Mario_Bounce		; hijack the main mario bounce on enemy code (stomp)

; -- Misc Mario edits --

	org $00FEA8
		JML Mario_FireballCheck		; fusion core fireball check fix
		NOP

	org $00FEB6
		db $36				; Fireball SFX

	org $0086A3
	; OBSOLETE DUE TO VR3
	;	JSL Mario_Controls		; > org: BPL $03 : LDX $6DB3
	;	NOP

	org $00D995
		JML Mario_FastSwim		;\ org: LDA $748F : BEQ $51 ($00D9EB)
		NOP				;/

	org $00DA9F
		JML Mario_FastSwim_2		;\ org $748F : BEQ $01 ($00DAA5)
		NOP				;/

	org $00DC2D
		JML Mario_Stasis		; > org: LDA $7D : STA $8A

	org $00E3A6
		JML Mario_ExternalAnim		; > org: LDA $73E0 : CMP #$3D
		NOP

	org $00DFDA
		db $00,$02,$FF,$FF,$00,$02,$18,$FF
		db $00,$02,$1A,$1B,$00,$02,$19,$FF
		db $00,$02,$0E,$0F,$00,$02,$1E,$1F
		db $00,$02,$0A,$0B,$00,$02,$1C,$1D
		db $00,$02,$0C,$0D,$00,$02,$06,$FF
		db $00,$02,$02,$FF,$04,$07,$FF,$FF
		db $FF,$FF
	warnpc $00E00C

	org $00A21B
		JSL Mario_Pause1		; > Org: LDA $16 : AND #$10

	org $00A226
		JSL Mario_Pause2		; > Org: LDA $71 : CMP #$09

	org $00A25B
		JSL Mario_Pause3		; > Org: LDA $15 : AND #$20
	org $00A269
		BRA +				; Org: LDA $6DD5 : BEQ $02 : BPL $19
		NOP #3
	org $00A270
		+
	org $00A281
		NOP #3				; Org: INC $7DE9

	org $00A300
		JML Mario_GFX			; > Org: REP #$20 : LDX #$02
	org $00A309
		JML Mario_Palette		;\ Org: LDY #$86 : STY $2121
		NOP				;/
	org $00A333
		JML Mario_GFXextra		;\ Org: LDA [Address of tile 7F] : STA $2116
		NOP #2				;/
	org $00A34D
		LDA !MarioGFX1			; > Org: LDA #$6000
	org $00A368
		NOP : CPX #$06
	org $00A36D
		LDA !MarioGFX2			; > Org: LDA #$6100
	org $00A388
		NOP : CPX #$06

	org $00CDFC				; Disable L/R scroll
		BRA $4B				; Org: BNE $4B

	org $00D093				; Disable automatic spin jump fireball
		RTS				;\ Org: BEQ $18
		NOP				;/


	org $00E31E
		JSL Mario_PaletteData		;\ Org: LDA $E2A2,y : STA $6D82
		NOP #2				;/

	org $00EA45
		JML Mario_ExtraWater		; org: LDA !WaterLevel : BNE $15 ($00EA5E)

	org $00EAA9
		JSL Mario_ExtraCollision	;\ org: STZ $77 : STZ $73E1
		NOP				;/

	org $028752				; Make big Mario break bricks and small Mario do nothing
		JML Mario_Brick			; Org: LDA $04 : CMP #$07

	org $028773				; Don't give Mario Y speed just because a brick is broken
		JSL Mario_Brick_YSpeed		; Org: LDA #$D0 : STA $7D

	org $02A129
		LDA #$02 : STA $3230,x		;\ Sprites get knocked out by fireballs
		BRA $06 : NOP #6		;/

	org $03B69B
		JML MarioHurtbox		; Org: STA $09 : PLX : RTL


; --Remap Mario tiles--

	org $00CF74
		JSL MarioTileRemap_Fire		; org: LDA #$3F : LDY !MarioAir

	org $00E2B2				; Mario's base OAM index
		db $00				; org: $10

	org $00E3D2				; property
		JML MarioTileRemap_Prop
		dl CORE_PlayerClipping		; $00E3D6 is a psuedo-vector!
		NOP #2
		STA !OAM+$113-$18,y
		STA !OAM+$0FB-$18,y
		STA !OAM+$0FF-$18,y
	org $00E3EC
		STA !OAM+$10B-$18,y
	org $00E448
	MarioCapeReturn:
		JSR $F636			;\
		PLB				; | prevent SMW's attempted priority remap
		RTL				; | org: LDX $73F9 : JSR $E45D
		NOP				;/

	MarioCapeY:
	db $00					; standing still
	db $03,$03,$03,$03,$03,$03		; walking/running
	db $08,$08,$08,$08			; falling
	warnpc $00E45D


	org $00E468				; tile number
		JSL MarioTileRemap		;\ org: STA $6302,y : LDX $05
		NOP				;/
	org $00E482
		JSL MarioTileRemap_Coords	; org: STA !OAM+$101,y : REP #$20
		BRA 23				;\ skip this code
		NOP #23				;/
	warnpc $00E49F



	org $00E4AC				; hi table
		dw !OAMhi+$40-$6


	org $00F699
		JSL MarioTileRemap_Expand	;\ org: LDA #$0A : STA $6D84
		NOP				;/
	pullpc


	Mario:
		LDA $19					;\
		BEQ $02 : LDA #$01			; | HP
		STA !P2HP				;/

		JSR MarioAnimations			; $00E2BD, transcribed and modified

		REP #$20				;\
		LDA !MarioXPos : STA $D1		; | copy of $00A2F3
		LDA !MarioYPos : STA $D3		; |
		SEP #$20				;/

		STZ !P2Gravity				; no extra gravity for Mario
		LDA #$46 : STA !P2FallSpeed		; Mario's fall speed is 0x46
		REP #$20
		STZ !P2ExtraInput1
		STZ !P2ExtraInput3
		SEP #$20
		STZ !P2Character
		LDA $7497 : STA !P2Invinc		; > Copy Mario's invincibility timer
		LDA !MarioDirection : STA !P2Direction	; > Copy direction flag
		LDA !MarioBlocked : STA !P2Blocked	; > Copy collision flags
		LDA $75					;\
		BEQ $02 : LDA #$40			; | Copy Mario's water flag
		LDY !MarioClimbing			; > Add climb flag
		BEQ $01 : INC A				; |
		STA !P2Water				;/
		STZ !P2XSpeed				;\
		STZ !P2YSpeed				; |
		REP #$20				; |
		LDA !MarioXPosLo : STA !P2XPosLo	; |
		LDA !MarioYPosLo			; |
		CLC : ADC #$0010			; |
		STA !P2YPosLo				; |
		SEP #$20				; |
		LDA !P2VectorBlocked : TSB !P2Blocked	; > extra collision variable for mario vectors
		STZ !P2VectorBlocked			; |
		JSR CORE_UPDATE_SPEED			; | Apply vector speeds (already includes a stasis check)
		REP #$20				; |
		LDA !P2XPosLo : STA !MarioXPosLo	; |
		LDA !P2YPosLo				; |
		SEC : SBC #$0010			; \
		BPL +					;  | Make sure Mario's Y coordinate is accurate
		CMP #$FF00 : BCS +			;  |
		LDA #$FF00				;  > can't go higher than -1 screen
	+	STA !MarioYPosLo			; /
		SEP #$20				;/
		LDA !P2Blocked : STA !P2VectorBlocked	;\
		LSR A : BCC $0B				; |
		BIT !P2VectorX : BMI $06		; |
		STZ !P2VectorX : STZ !P2VectorTimeX	; |
		LSR A : BCC $0B				; |
		BIT !P2VectorX : BPL $06		; |
		STZ !P2VectorX : STZ !P2VectorTimeX	; | Prevent Mario from vectoring into walls
		LSR A : BCC $0B				; |
		BIT !P2VectorY : BMI $06		; |
		STZ !P2VectorY : STZ !P2VectorTimeY	; |
		LSR A : BCC $0B				; |
		BIT !P2VectorY : BPL $06		; |
		STZ !P2VectorY : STZ !P2VectorTimeY	;/
		LDA !MarioXSpeed : STA !P2XSpeed	;\ Copy speeds
		LDA !MarioYSpeed : STA !P2YSpeed	;/

		LDA !P2FireFlash
		BEQ $03 : DEC !P2FireFlash

		LDA !MarioBlocked
		AND #$03 : BEQ +
		STZ !MarioClimb				; clear this if mario touches no walls
		+

		RTS


		.HandyGlove
		PHB : PHK : PLB
		PHX
		LDA !MarioUpgrades
		AND #$02 : BEQ +
		LDA !MarioBlocked
		AND #$04 : BEQ ..Check
	+
	-	JMP ..R


		..Check
		LDA !CurrentMario : BEQ -
		LDX #$00
		CMP #$01 : BEQ ..P1
	..P2	LDX #$80
	..P1	LDA !MarioClimb : BEQ ..Init
		JMP ..Main

		..Init
		LDA !MarioYSpeed : BMI -
		LDY !MarioDirection
		LDA !MarioXPosLo
		AND #$0F
		CMP.w ..X,y : BNE -
		LDA !MarioYPosLo
		AND #$0F
		CMP #$08 : BCC -
		CMP #$0C : BCS -
		LDA.w ..Bit,y
		AND $15 : BEQ -

		PHX
		LDA !MarioDirection
		ASL A
		TAY
		REP #$30
		LDA.w ..Offset,y
		CLC : ADC !MarioXPosLo
		AND #$FFF0
		STA $98						; store this
		TAX
		LDA !MarioYPosLo
		SEC : SBC #$0008
		AND #$FFF0
		TAY
		SEP #$20
		JSL !GetMap16
		PLX
		CMP #$0103 : BCC +
		CMP #$016E : BCC -


	+	PHX
		REP #$30
		LDX $98
		LDA !MarioYPosLo
		CLC : ADC #$0008
		AND #$FFF0
		TAY
		SEP #$20
		JSL !GetMap16
		PLX
		CMP #$0103 : BCC ..R
		CMP #$016E : BCS ..R
		LDA !MarioYPosLo
		SEC : SBC #$0008
		AND #$FFF0
		DEC #2
		LDY !MarioPowerUp
		BEQ $02 : DEC #2
		STA !MarioYPosLo
		SEP #$20
		LDA #$30 : STA !MarioClimb			; also used as PP bits for Mario's tiles
		BRA ..Stick

		..Main
		LDY !MarioDirection
		LDA.w ..Bit,y
		AND $15 : BNE ..Stick
		STZ !MarioClimb
	..Stick	LDY !MarioDirection
		STZ !MarioYSpeed
		LDA #$02
		STA !P2Stasis-$80,x
		STA !P2ExternalAnimTimer-$80,x
		STZ !P2ExternalAnim-$80,x
		STZ !MarioSpinJump

		BIT $16 : BPL ..R
		LDA #$C0 : STA !MarioYSpeed
		STZ !P2Stasis-$80,x
		STZ !MarioClimb
		LDA #$2B : STA !SPC1				; jump SFX

	..R	SEP #$20
		PLX
		PLB
		LDA !MarioBlocked				;\ overwritten code
		AND #$03					;/
		RTL						; return


	..Offset
	dw $FFF8,$0018

	..X
	db $0D,$02

	..Bit
	db $02,$01


		.Bounce
		LDA !MarioClimbing : BNE ..return
		LDA #$D0
		BIT $15
		BPL $02 : LDA #$A8
		STA !MarioYSpeed
		..return
		LDA !MarioFireCharge : BNE +			; check if mario has a fire charge
		LDA #$01 : STA !MarioFireCharge			;\
		LDA !CurrentMario : BEQ +			; |
		PHY						; |
		LDY #$00					; |
		CMP #$01 : BEQ ++				; | if he doesn't, give him one and make him flash white
		LDY #$80					; |
	++	LDA #$14 : STA !P2FireFlash-$80,y		; |
		PLY						; |
		+						;/

		RTL


		.Cape1
		LDA !MarioUpgrades
		AND #$04 : BEQ ..Fall
		LDA !CurrentMario : BEQ ..Fall			;\
		LDY #$00					; |
		CMP #$01 : BEQ ..P1				; | can't float during flare drill
	..P2	LDY #$80					; |
	..P1	LDA !P2FlareDrill-$80,y : BNE ..Fall		;/
	..Float	JML $00D8ED
	..Fall	JML $00D928


		.Cape2
		LDA !MarioUpgrades
		AND #$04 : BEQ ..No
	..Yes	JML $00E401
	..No	JML MarioCapeReturn


		.Fireball
	BRA ..Fire
;		CMP #$03 : BEQ ..Fire
;		LDA !MarioUpgrades
;		AND #$40 : BNE ..Fire
	..No	JML $00D0AD
	..Fire	LDA !MarioFireCharge : BEQ ..No			; only allow if mario has a fire charge
		JML $00D085


		.TacticalFire
		STZ !MarioFireCharge				; consume mario's fire charge
		LDA !MarioUpgrades
		AND #$08 : BEQ ..30
		LDA $15
		AND #$08 : BEQ ..30
	..C0	LDA #$C0 : STA !Ex_YSpeed,x
		RTL
	..30	LDA #$30 : STA !Ex_YSpeed,x
		RTL



		.AirHook
		JSR .Coyote
		LDA !P2CoyoteTime-$80,x
		BEQ ..Normal
		BPL ..Ground

		..Normal
		LDA !MarioAir : BEQ ..Ground

		LDA !MarioUpgrades				;\ upgrade check
		AND #$10 : BEQ ..NoFlareSpin			;/
		LDA !MarioSpinJump : BNE ..NoFlareSpin		;\
		BIT $18 : BPL ..NoFlareSpin			; |
		LDA #$E0 : STA !MarioYSpeed			; | flare spin
		LDA #$01 : STA !MarioSpinJump			; |
		LDA #$04 : STA !SPC4				;/
		..NoFlareSpin

		LDA !MarioUpgrades				;\ upgrade check
		AND #$20 : BEQ ..NoFlareDrill			;/
		LDA !P2FlareDrill-$80,x : BNE ..NoFlareDrill
		LDA !MarioSpinJump : BEQ ..NoFlareDrill		;\
		LDA !MarioYSpeed : BPL ..NoFlareDrill		; |
		LDA $16						; | flare drill
		AND #$04 : BEQ ..NoFlareDrill			; |
		LDA #$01 : STA !P2FlareDrill-$80,x		; |
		..NoFlareDrill					;/
		LDA !MarioSpinJump				;\ clear flare drill when spin jump ends
		BNE $03 : STZ !P2FlareDrill-$80,x		;/
		LDA !P2FlareDrill-$80,x				;\ flare drill descent
		BEQ $04 : LDA #$60 : STA !MarioYSpeed		;/


		JML $00D682					; air

		..Ground
		STZ !P2FlareDrill-$80,x
		JML $00D5F9					; ground




		.Coyote
		LDA !CurrentMario
		LDX #$00
		CMP #$02
		BNE $02 : LDX #$80
		LDA !MarioAir : BEQ ..Ground

		..Air
		LDA !P2CoyoteTime-$80,x
		BEQ ..Jump
		BPL ..Timer
	..Jump	LDA $16
		AND #$80 : BEQ ..Timer
		ORA #$03 : STA !P2CoyoteTime-$80,x
		RTS

		..Ground
		LDA !P2CoyoteTime-$80,x : BMI ..Buffer
		LDA #$03 : STA !P2CoyoteTime-$80,x
		RTS

		..Buffer
		AND #$80 : TSB $16
	..Clear	STZ !P2CoyoteTime-$80,x
		RTS

		..Timer
		LDA !P2CoyoteTime-$80,x
		DEC A
		CMP #$7F : BEQ ..Clear
		CMP #$FF : BEQ ..Clear
		STA !P2CoyoteTime-$80,x
		RTS




		.FastSwim
		PHA					;\
		PHX					; |
		LDX #$00				; |
		LDA !CurrentMario : BEQ ..R		; |
		CMP #$01 : BEQ ..P1			; |
	..P2	LDX #$80				; | if Mario holds B for 10 frames or more he can
	..P1	BIT $15 : BMI ..B			; | swim fast even without an item
		LDA #$0A : STA !P2DashTimerR1-$80,x	; |
	..B	LDA !P2DashTimerR1-$80,x : BNE ..Slow	; |
		INC !P2DashTimerR2-$80,x		; > extra animation timer
		LDA !P2DashTimerR2-$80,x		; |
		AND #$0F				; |
		STA $7496				; > Mario animation timer
		PLX					; |
		PLA					; |
		BRA .00D99A				;/

	..Slow	DEC !P2DashTimerR1-$80,x
	..R	PLX
		PLA
		LDA $748F : BEQ .00D9EB

	.00D99A	JML $00D99A
	.00D9EB	JML $00D9EB


		.FastSwim_2
		LDY $748F : BNE .00DAA4			;\
		PHA					; |
		LDA !CurrentMario : BEQ +		; |
		LDX #$00				; |
		CMP #$01 : BEQ ..P1			; | don't flail arms during fast swim
	..P2	LDX #$80				; |
	..P1	LDA !P2DashTimerR1-$80,x : BNE +	; |
		PLA					; |
	.00DAA4	JML $00DAA4				;/

	+	PLA					;\ animate arms as usual if there's no object or fast swim
	.00DAA5	JML $00DAA5				;/



		.Stasis
		LDA !CurrentMario : BEQ +		; > If there's no Mario, just go on as usual
		CMP #$02 : BEQ ++			; > Branch if P2 is controlling Mario
		LDA !P2Stasis-$80 : BEQ +		; > Check for P1 stasis
	-	JML $00DC77				; > Don't apply Mario speed
	++	LDA !P2Stasis : BNE -			; > Check for P2 stasis
	+	LDA $7D : STA $8A			;\ Return as normal
		JML $00DC31				;/


		.ExternalAnim
		LDA !CurrentMario : BEQ ..NoExternal
		DEC A
		CLC : ROL #2
		TAX
		LDA !P2ExternalAnimTimer-$80,x		;\
		BEQ ..ClearExternal			; |
		DEC A					; |
		STA !P2ExternalAnimTimer-$80,x		; | Enforce external animations for Mario
		LDA !P2ExternalAnim-$80,x		; |
		STA !MarioImg				; |
		LDA !P2Anim-$80,x : STA $73DF		; > enforce cape too
		BRA ..NoExternal			;/

		..ClearExternal
		STZ !P2ExternalAnim-$80,x		; Clear once timer runs out
		STZ !P2Anim-$80,x

		..NoExternal
		LDA !MarioImg				;\
		CMP #$3D				; | Overwritten code + return
		JML $00E3AB				;/



		.GFX
		LDA !GameMode				;\ Not on the realm select menu
		CMP #$0F : BCC ..NoMario		;/
		LDA !Characters				;\
		AND #$F0 : BEQ ..Mario1			; |
		LDA !MultiPlayer			; | See if anyone is playing Mario
		BEQ ..NoMario				; |
		LDA !Characters				; |
		AND #$0F : BNE ..NoMario		;/

		..Mario2
		LDA #$20 : STA !MarioTileOffset		; > Tile offset for P2 Mario
		LDA #$02 : STA !MarioPropOffset		; > Prop offset for P2 Mario
		REP #$20				;\
		LDX #$02				; |
		LDA #$6200 : STA !MarioGFX1		; | Set Mario's VRAM address to P2
		LDA #$6300 : STA !MarioGFX2		; |
		JML $00A304				;/

		..Mario1
		STZ !MarioTileOffset			; > Tile offset for P1 Mario
		STZ !MarioPropOffset			; > Prop offset for P1 Mario
		REP #$20				;\
		LDX #$02				; |
		LDA #$6000 : STA !MarioGFX1		; | Execute Mario DMA as normal
		LDA #$6100 : STA !MarioGFX2		; |
		JML $00A304				;/

		..NoMario
		JML $00A38F				; > Ignore the whole Mario DMA routine


		.GFXextra
		LDA #$6070
		CLC : ADC !MarioGFX1			;\ Recalculate position
		SEC : SBC #$6000			;/
		STA $2116				; > Store VRAM address
		JML $00A33C


		.FireballCheck
		STZ $00					; number of fireballs currently in play
		LDX.b #!Ex_Amount-1
	-	LDA !Ex_Num,x
		CMP.b #$05+!ExtendedOffset
		BNE $02 : INC $00
		DEX : BPL -
		LDA $00
		CMP #$02 : BCS ..nope			; only allow 2 fireballs at once
	..spawn	LDX.b #!Ex_Amount-1			;\
	-	LDA !Ex_Num,x : BEQ ..go		; | look for a free slot
		DEX : BPL -				;/
	..nope	JML $00FEB4				; return without spawning a fireball
	..go	JML $00FEB5				; spawn a fireball



		.Controls
		PHP
		LDA !CurrentMario : BEQ +
		DEC A
		CLC : ROR #2
		TAY
		REP #$20
		LDA !P2ExtraInput1-$80,y
		ORA !P2ExtraInput3-$80,y
		SEP #$20
		BEQ +
		LDA !P2ExtraInput1-$80,y			;\
		BEQ $02 : STA $15				; |
		LDA !P2ExtraInput2-$80,y			; |
		BEQ $02 : STA $16				; | Input overwrite
		LDA !P2ExtraInput3-$80,y			; |
		BEQ $02 : STA $17				; |
		LDA !P2ExtraInput4-$80,y			; |
		BEQ $02 : STA $18				;/
		PLP
		PLA : PLA : PLA
		JML $0086C6

	+	PLP
		BPL ..Return					; > Not sure what this actually does but it's in the source code
		LDX #$00					;\
		LDA !MultiPlayer				; |
		BEQ ..Return					; | Allow P2 to control Mario
		LDA !Characters					; |
		AND #$0F : BNE ..Return				; |
		INX						;/

		..Return
		RTL


		.Palette
		LDA !MarioPropOffset				;\
		AND #$00FF					; |
		ASL #3						; | Make sure Mario palette is uploaded to the right place
		CLC : ADC #$0086				; |
		TAY : STY $2121					; |
		JML $00A30E					;/


		.PaletteData
	;	LDA.w #!MarioPalData : STA $6D82		; Mario's palette is in I-RAM
	;	LDA !MarioPalOverride
	;	AND #$00FF : BNE ..override

	;	PEI ($00)
	;	PHY

		SEP #$20
		LDY #$00
	;	LDA !MarioUpgrades				;\
	;	AND #$40					; | always use fire palette with flower DNA
	;	BEQ $02 : LDY.b #!palset_mario_fire		;/
		LDA !MarioFireCharge				;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire		;/
	;	LDA $19						;\
	;	CMP #$03					; | fire palette if mario has fire flower
	;	BNE $02 : LDY.b #!palset_mario_fire		;/


		LDA !MarioFireCharge				;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire		;/
		LDA !CurrentMario : BNE $03 : JMP ..NoUpdate
		DEC A
		TAX
		PHX
	;	TYA : STA !Palset8,x

		LDA !P2FireFlash-$80,x : BNE +
		CPY.b #!palset_mario_fire : BEQ $03 : JMP ..NoGlow
		+

		PHY
		TXY
		BEQ $02 : LDY #$80
		LDA !P2FireFlash-$80,y : BEQ +
		PHX
		PHA
		LDA #$01 : STA !P2LockPalset-$80,y
		CPX #$00
		BEQ $02 : LDX #$20
		REP #$20
		LDA #$7FFF
		STA.l !PaletteHSL+$904+$100,x
		STA.l !PaletteHSL+$906+$100,x
		STA.l !PaletteHSL+$908+$100,x
		STA.l !PaletteHSL+$90A+$100,x
		STA.l !PaletteHSL+$90C+$100,x
		STA.l !PaletteHSL+$90E+$100,x
		STA.l !PaletteHSL+$910+$100,x
		STA.l !PaletteHSL+$912+$100,x
		STA.l !PaletteHSL+$914+$100,x
		STA.l !PaletteHSL+$916+$100,x
		STA.l !PaletteHSL+$918+$100,x
		STA.l !PaletteHSL+$91A+$100,x
		STA.l !PaletteHSL+$91C+$100,x
		STA.l !PaletteHSL+$91E+$100,x
		SEP #$20
		LDA $02,s
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$0E
		PLA
		CMP #$10 : BCC ++
		SBC #$10
		ASL #3
		BRA +++
	++	ASL A
		EOR #$1F
	+++	JSL !MixRGB_Upload
		PLX
		PLY
		JMP ..NoGlow

		+
		LDA #$00 : STA !P2LockPalset-$80,y
		PLY
		LDA !Palset8,x
		AND #$7F : BEQ +
		STZ !Palset8,x
		+
		CPY #$09 : BNE ..NoGlow

	; write to colors 2, 3, 8 and A
		..Glow
		CPX #$00
		BEQ $02 : LDX #$20
		LDA #$1F
		STA !PaletteHSL+$904+$100,x
		STA !PaletteHSL+$906+$100,x
		STA !PaletteHSL+$910+$100,x
		STA !PaletteHSL+$914+$100,x
		TXA
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$02
		LDA $14
		AND #$3F
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		PHA
		PHX
		JSL !MixRGB_Upload
		PLX
		LDA $01,s
		INX #6
		LDY #$01
		PHX
		JSL !MixRGB_Upload
		PLX
		PLA
		INX #2
		LDY #$01
		JSL !MixRGB_Upload

		..NoGlow
		PLX
		..NoUpdate

		..override
		RTL


		.ExtraCollision
		STZ $73E1					; overwritten code
		LDX #$00
		LDA !CurrentMario : BEQ ..return
		CMP #$01 : BEQ ..p1
	..p2	LDX #$80
	..p1	LDA !P2ExtraBlock-$80,x
		AND #$7F : STA !MarioBlocked
		EOR !P2ExtraBlock-$80,x
		STA !P2ExtraBlock-$80,x
..return	RTL





	; $73FA was cleared literally just before this routine was called

		.ExtraWater
		LDA !WaterLevel : BNE ..WaterLevel

		LDX #$00				;\
		LDA !CurrentMario : BEQ ..NoMario	; |
		CMP #$01 : BEQ ..P1			; |
	..P2	LDX #$80				; |
	..P1	LDA !P2ExtraBlock-$80,x : BPL ..NoMario	; | apply external water reg to Mario, then clear it
		AND #$7F				; |
		STA !P2ExtraBlock-$80,x			; |
		BRA ..Water				; |
		..NoMario				;/

		LDA !MarioExtraWaterJump : BNE ..CanJump

		LDA !3DWater : BEQ ..NoWater		;\
		LDA !IceLevel : BNE ..NoWater		; |
		REP #$20				; |
		LDA !MarioYPosLo			; | check for (nonfrozen) 3D water
		CLC : ADC #$0018			; > Mario offset
		BPL $03 : LDA #$0000			; > can't be out of bounds
		SEC : SBC !Level+2			; |
		SEP #$20				; |
		BCC ..NoWater				;/
		XBA : BNE ..Water
		XBA
		CMP #$10 : BCS ..Water			; Mario can jump out when in the top tile of the water

		..CanJump
		LDA #$00 : STA !MarioExtraWaterJump
		LDA !MarioUnderWater : BEQ ..Water	; water splash animation
		LDA #$FC				;\
		CMP !MarioYSpeed			; | I don't know what this does but smw does it
		BMI $02 : STA !MarioYSpeed		;/
		LDA #$01
		STA $73FA				; allow jump
		STA !MarioUnderWater
		TSB $8A					; as far as I can tell, these bits work like this:
		LDA #$02 : TRB $8A			; 0 - no swim, no jump
							; 1 - jump, no swim
							; 2 - entering water (?)
							; 3 - swim, no jump
		JML $00EA49

..Water		LDA #$03 : TSB $8A
..NoWater	JML $00EA49				; shared return
..WaterLevel	JML $00EA5E




		.Brick
		LDA !ProcessingSprites : BNE ..NotMario
		LDA $04
		CMP #$07 : BNE ..028756
		LDA $19 : BNE ..Break
..Bounce	REP #$20
		LDA $98 : STA $0C
		LDA $9A : STA $0A
		SEP #$20
		STZ $00
		LDA #$01 : STA $7C			;\ (0x07 is spinning turn block)
		LDA #$0C : STA $9C			; | Normal turn block code
		LDY #$00				;/
		JSR CORE_GENERATE_BLOCK
		JML $028788
..Break		JML $028758

..NotMario	LDA $04					;\ Overwritten code
		CMP #$07				;/
..028756	JML $028756				; > Return

..YSpeed	LDA !ProcessingSprites : BNE ..Return
		BIT !MarioYSpeed : BMI ..Return
		LDA #$D0 : STA !MarioYSpeed
..Return	RTL



; Multiplayer, Mario 0: $6DA6 OR $6DA7
; Multiplayer, Mario 1: $16 OR $6DA7
; Multiplayer, Mario 2: $16 OR $6DA6
; Singleplayer, Mario 0: $6DA6
; Singleplayer, Mario 1: $16

		.Pause1
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI $02 : BNE +				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		LDA #$00				; |
		RTL					; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer
		BEQ $03 : LDA $6DA6
		ORA $16
		BRA +

	..PCE	LDA !MultiPlayer
		BEQ $03 : LDA $6DA7
	-	ORA $6DA6
	+	AND #$10
		RTL

	..M2	LDA $16
		BRA -


; returning with carry clear will pause
; returning with carry set will not pause

		.Pause2
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI ..No				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		BEQ ..No				; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer : BEQ ..M
		LDA !P2Status
		ORA !P2Pipe
		BEQ ..Yes

	..M	LDA !MarioAnim
		CMP #$09
		RTL

	..PCE	LDA !MultiPlayer : BEQ +
		LDA !P2Status
		ORA !P2Pipe
		BEQ ..Yes
	+	LDA !P2Status-$80
		ORA !P2Pipe-$80
		BEQ ..Yes

	..No	SEC
		RTL

	..M2	LDA !P2Status-$80
		ORA !P2Pipe-$80
		BNE ..M

	..Yes	CLC
		RTL


		.Pause3
		LDA !MsgTrigger : BEQ +			;\
		LDA $400000+!MsgImportant		; |
		BMI $02 : BNE +				; | hitting start when a skippable text box is open only closes the text box without pausing the game
		LDA #$00				; |
		RTL					; |
		+					;/
		LDA !CurrentMario : BEQ ..PCE
		CMP #$02 : BEQ ..M2
		LDA !MultiPlayer : BEQ +
		LDA $6DA3
	+	ORA $15
	-	AND #$20
		RTL

	..PCE	LDA !MultiPlayer
		BEQ $03 : LDA $6DA3
		ORA $6DA2
		BRA -

	..M2	LDA !MultiPlayer
		BEQ $03 : LDA $6DA2
		ORA $15
		BRA -


; $00E2BD - $00E4B8 + the JSR at $00F636 - $00F69E
MarioAnimations:
		PHB								;\ wrapper to bank 0x00
		LDA #$00 : PHA : PLB						;/
		LDA !MarioImg : PHA						; push this

		LDA !P2ExternalAnimTimer : BEQ .ClearExternal			;\
		DEC !P2ExternalAnimTimer					; | enforce external animations for Mario
		LDA !P2ExternalAnim : STA !MarioImg				; |
		LDA !P2Anim : STA !CapeImg					; > enforce cape too
		BRA .NoOverride							;/
		.ClearExternal
		STZ !P2ExternalAnim						; clear once timer runs out
		STZ !P2Anim
		.NoOverride

		LDA #$05							;\
		CMP !MarioWallWalk : BCS +					; |
		LDA !MarioWallWalk						; |
		LDY $19 : BEQ ++						; |
		CPX #$13 : BNE +++						; | mario's screen-relative Xpos
	++	EOR #$01							; |
	+++	LSR A								; |
	+	REP #$20							; |
		LDA !MarioXPos							; |
		SBC $1A								; | (yep, no SEC)
		REP #$20							; |
		STA $7E								; |
		LDX !MarioClimb : BEQ ..NoClimb					; |
		LDA !MarioDirection						; |
		AND #$00FF							; |
		ASL A								; |
		TAX								; | climb offset code
		LDA.l .ClimbOffsets,x						; |
		CLC : ADC $7E							; |
		STA $7E								; |
		..NoClimb							;/


		LDA $788B							;\
		AND #$00FF							; > offset caused by shaking camera
		CLC : ADC !MarioYPos						; |


		; $00E34F reference
	;	LDY $19								; |
	;	CPY #$01							; |
	;	LDY #$01							; |
	;	LDX !MarioImg							; |
	;	BCS $02 : DEC A : DEY						; | mario's screen-relative Ypos
	;	CPX #$0A							; |
	;	BCS $03 : CPY $73DB						; > bop up and down while walking/running
	;	SBC $1C								; | (frames 00-09)
	;	CPX #$1C							; |
	;	BNE $03 : ADC #$0001						; |

		DEC A
		LDX !MarioImg : BEQ +
		CPX #$1C : BEQ ..D1
		CPX #$0A : BCS +
		LDY $19
		BNE $01 : INX
		CPX #$02 : BEQ ..U1
		CPX #$06 : BEQ ..U1
		CPX #$09 : BNE +
	..U1	DEC #2
	..D1	INC A
	+	SEC : SBC $1C

		STA $0E								; |

		LDA !DizzyEffect						;\
		AND #$00FF : BEQ ..NoDizzy					; |
		LDA !MarioXPos							; |
		SEC : SBC $1A							; |
		AND #$00FF							; |
		LSR #3								; |
		ASL A								; |
		TAX								; > adjust mario during dizzy effect
		LDA $40A040,x							; |
		AND #$1FFF							; |
		SEC : SBC $1C							; |
		EOR #$FFFF : INC A						; |
		CLC : ADC $0E							; |
		STA $0E								; |
		..NoDizzy							;/

		LDA $0E								;\
		LDY !Level+1 : BNE ..NoDown					; |
		LDY !Level							; |
		CPY #$25 : BNE ..NoDown						; |
		LDY !Level+4 : BEQ ..NoDown					; |
		REP #$20							; |
		STA $0E								; |
		LDA $6DF6							; > move down with screen on upgrade menu
		AND #$00FF							; |
		CLC : ADC $0E							; |
		CMP #$00F0							; |
		BCC $03 : LDA #$00F0						; |
		SEP #$20							; |
		..NoDown							; |
		STA $80								;/

		SEP #$20							;\
		LDA !MarioFlashTimer : BEQ .GFX					; |
		LSR #3								; |
		TAY								; |
		LDA $E292,y							; | figure out if mario should be drawn (flash logic)
		AND !MarioFlashTimer						; |
		ORA $9D								; |
		ORA $73FB							; |
		BNE .GFX							;/
		PLA : STA !MarioImg						;\
		PLB								; | return
		RTS								;/


; -info-
; $00	16-bit	index to table with X/Y disp, 2 bytes for each (facing left + facing right), only lo byte is used
; $02	16-bit	index to table with tile numbers (values 0x80+ are skipped), only lo byte is used
; $04	8-bit	collection of size bits for mario's tiles
; $05	8-bit	YXPPCCCT
; $06	16-bit	which tile we're on (starts at 0 and counts up)
; $08	16-bit	copy of !CapeImg, with hi byte cleared
; $0A	16-bit	used for VRAM transfer
; $0C	16-bit	used for VRAM transfer (should be 0 if cape is not used)
; $0E	16-bit	used as scratch by cape

; $7E	16-bit	mario xpos relative to screen
; $80	16-bit	mario ypos relative to screen

; compared to original:
; $05 was remapped to $00
; $06 was remapped to $02


	.GFX
		LDX #$00							;\
		LDA !MarioBehind						; |
		CMP #$02							; |
		BCS $02 : LDX #$02						; | !BigRAM+0: which index to use (_p0 or _p1)
		LDA $7499 : BEQ +						; | !BigRAM+2: how much to add to X (0x000 or 0x200)
		LDA !MarioImg							; |
		CMP #$0F : BEQ ++						; |
		CMP #$45 : BNE +						; |
	++	LDX #$00							; |
	+	REP #$20							; |
		LDA.l !OAMindex_index,x : STA !BigRAM+0				; |
		LDA.l !OAMindex_offset,x : STA !BigRAM+2			;/
		STZ $00								;\
		STZ $02								; |
		STZ $06								; |
		LDA !CapeImg							; | set up scratch
		AND #$00FF							; |
		STA $08								; |
		STZ $0C								;/
		LDX !MarioImg							; X = mario image
		SEP #$20

		; i believe these are used to determine the size of mario's tiles
		LDA #$C8							;\
		CPX #$43							; | if mario is a big balloon, $04 = 0xE8
		BNE $02 : LDA #$E8						; | otherwise, $04 = 0xC8
		STA $04								;/
		LDA $DCEC,x							;\
		ORA !MarioDirection						; | write $00 based on indexed table + direction
		TAY								; | this will index the X/Y coord table
		LDA $DD32,y : STA $00						;/
		TXA								;\
		CMP #$3D : BCS +						; |
		LDY $19								; > if !MarioImg <= 0x3D, add a value indexed by powerup status
		ADC $DF16,y							; | Y = that sum
	+	TAY								;/
		LDA $DF1A,y : STA $02						;\
		LDA $E00C,y : STA $0A						; | use Y to set up $02 and $0A
		LDA $E0CC,y : STA $0B						;/
		LDA $3E								;\
		AND #$07							; | Y = current screen mode
		TAY								;/

		LDA $64								;\
		LDX !MarioBehind						; | get PP bits
		BEQ $03 : LDA $E2B9,x						;/
		LDX !MarioDirection						;\ get X bit
		ORA $E18C,x							;/
		CLC : ADC !MarioPropOffset					; > add player palette offset
		ORA !MarioClimb							; > add extra priority during ledge hang
		CPY #$02							;\ clear lowest P bit during mode2
		BNE $02 : AND #$EF						;/
		STA $05								; store YXPPCCCT in scratch

		REP #$30							;\
		LDX !BigRAM+0							; |
		LDA !OAMindex_p1,x						; | index to _p1 or _p2
		CLC : ADC !BigRAM+2						; |
		TAX								; |
		SEP #$20							;/
		LDA !MarioImg							;\
		CMP #$25 : BEQ .BehindCape					; |
		CMP #$44 : BNE .NotBehindCape					; | frames 0x25 and 0x45 are drawn behind the cape
		.BehindCape							; |
		LDA #$F0 : STA !OAM_p1+$001,x					; > hide this tile
		INX #4								; |
		.NotBehindCape							;/

		JSR .Draw
		JSR .Draw
		JSR .Draw
		JSR .Draw

		LDA !MarioUpgrades
		AND #$04 : BNE $03 : JMP .Finish


	; cape code
		LDA !MarioSpinJump : BEQ .NoCapeRemap
		BIT !MarioYSpeed : BMI .AscendingCape

	.DescendingCape
		LDA $19 : BNE .NoCapeRemap
		LDA !MarioImg : BEQ +
		CMP #$0F : BEQ ..45
	..44	LDA #$44 : BRA $02
	..45	LDA #$45
	+	STA !MarioImg
		BEQ ..c_07
	..c_09	LDA #$09 : BRA .W
	..c_07	LDA #$07 : BRA .W

	.AscendingCape
		LDA $19 : BEQ +
		LDA !MarioImg : BEQ +
		CMP #$44 : BEQ ..25
	..0F	LDA #$0F : BRA $02
	..25	LDA #$25
		STA !MarioImg
	+	LDA !MarioImg : BEQ .W
		LDA #$0B
	.W	STA !CapeImg
		.NoCapeRemap

		LDA $19 : BNE +
		LDY $08
		REP #$20
		LDA $E448+6,y							; | ("MarioCapeY")
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $80
		STA $80
		SEP #$20
		+

		LDA #$00 : XBA							; clear B
		LDA #$2C : STA $02
		LDA #$FF : STA $04
		LDA !MarioImg : TAY
		LDA $E18E,y : TAY
		LDA $E1D5,y : STA $0C
		CMP #$04 : BCS .DrawCape
		LDA !CapeImg
		ASL #2
		ORA $0C
		TAY
		LDA $E23A,y : STA $0C
		LDA $E266,y
		BRA +

	.DrawCape
		LDA !MarioImg : TAY
		LDA $E1D6,y
	+	ORA !MarioDirection
		TAY
		LDA $E21A,y : STA $00
		LDA !MarioImg							;\
		CMP #$25 : BEQ +						; |
		CMP #$44 : BNE ++						; |
	+	PHX								; |
		REP #$20							; |
		LDX !BigRAM+0							; |
		LDA !OAMindex_p1,x						; | for mario images 0x25 and 0x44 cape is drawn in front
		CLC : ADC !BigRAM+2						; |
		TAX								; |
		SEP #$20							; |
		JSR .Draw							; |
		PLX								; |
		BRA .Finish							;/

	++	JSR .Draw							; draw cape (normally behind mario)

	.Finish
		REP #$20							;\
		TXA								; |
		SEC : SBC !BigRAM+2						; | store new OAM index
		LDX !BigRAM+0							; |
		STA !OAMindex_p1,x						;/
		SEP #$10
	; HIJACK: mario sprite sheet expansion
	; this code is for uploading GFX from sources other than the main file at $7E2000
	; should be merged into the above code for efficiency
		LDA !MarioClimb : BEQ .NormalVRAM
		REP #$20
		LDA !MarioPowerUp-1
		AND #$FF00
		BEQ $03 : LDA #$0080
		CLC : ADC #$7D00+$C00
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		SEC : SBC #$01C0
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
		BRA .c_VRAM

	.NormalVRAM
		LDX #$00
		LDA $09
		ORA #$0800
		CMP $09
		BEQ $01 : CLC
		AND #$F700
		ROR A
		LSR A
		ADC #$2000
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		LDX #$00
		LDA $0A
		ORA #$0800
		CMP $0A
		BEQ $01 : CLC
		AND #$F700
		ROR A
		LSR A
		ADC #$2000
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
	.c_VRAM	LDA $0B
		AND #$FF00
		LSR #3
		ADC #$2000
		STA $6D89
		CLC : ADC #$0200
		STA $6D93
		LDA $0C
		AND #$FF00
		LSR #3
		ADC #$2000
		STA $6D99

		; fire flash code
		SEP #$30
		LDY #$00
		LDA !MarioFireCharge							;\ fire palette if mario has palette charge
		BEQ $02 : LDY.b #!palset_mario_fire					;/
		LDA !CurrentMario : BNE $03 : JMP ..NoUpdate
		LDA !P2FireFlash : BNE +
		CPY.b #!palset_mario_fire : BEQ $03 : JMP ..NoGlow
		+

		PHY
		TXY
		BEQ $02 : LDY #$80
		LDA !P2FireFlash : BEQ +
		PHX
		PHA
		LDA #$01 : STA !P2LockPalset
		CPX #$00
		BEQ $02 : LDX #$20
		REP #$20
		LDA #$7FFF
		STA.l !PaletteHSL+$904+$100,x
		STA.l !PaletteHSL+$906+$100,x
		STA.l !PaletteHSL+$908+$100,x
		STA.l !PaletteHSL+$90A+$100,x
		STA.l !PaletteHSL+$90C+$100,x
		STA.l !PaletteHSL+$90E+$100,x
		STA.l !PaletteHSL+$910+$100,x
		STA.l !PaletteHSL+$912+$100,x
		STA.l !PaletteHSL+$914+$100,x
		STA.l !PaletteHSL+$916+$100,x
		STA.l !PaletteHSL+$918+$100,x
		STA.l !PaletteHSL+$91A+$100,x
		STA.l !PaletteHSL+$91C+$100,x
		STA.l !PaletteHSL+$91E+$100,x
		SEP #$20
		LDA $02,s
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$0E
		PLA
		CMP #$10 : BCC ++
		SBC #$10
		ASL #3
		BRA +++
	++	ASL A
		EOR #$1F
	+++	JSL !MixRGB_Upload
		PLX
		PLY
		JMP ..NoGlow

		+
		LDA #$00 : STA !P2LockPalset
		PLY
		LDA !Palset8,x
		AND #$7F : BEQ +
		STZ !Palset8,x
		+
		CPY #$09 : BNE ..NoGlow

	; write to colors 2, 3, 8 and A
		..Glow
		CPX #$00
		BEQ $02 : LDX #$20
		LDA #$1F
		STA !PaletteHSL+$904+$100,x
		STA !PaletteHSL+$906+$100,x
		STA !PaletteHSL+$910+$100,x
		STA !PaletteHSL+$914+$100,x
		TXA
		BEQ $02 : LDA #$10
		CLC : ADC #$82
		TAX
		LDY #$02
		LDA $14
		AND #$3F
		SEC : SBC #$20
		BPL $03 : EOR #$FF : INC A
		PHA
		PHX
		JSL !MixRGB_Upload
		PLX
		LDA $01,s
		INX #6
		LDY #$01
		PHX
		JSL !MixRGB_Upload
		PLX
		PLA
		INX #2
		LDY #$01
		JSL !MixRGB_Upload

		..NoGlow
		..NoUpdate

	.Return	PLA : STA !MarioImg						;\
		PLB								; | return
		RTS								;/


		.Draw
		LSR !MarioMaskBits : BCS .Fail					; if tile is masked, skip it

		LDY $02								;\ if tile doesn't exist, skip it
		LDA $DFDA,y : BMI .Fail						;/
		CLC : ADC !MarioTileOffset					; add player offset
		STA !OAM_p1+$002,x						; store tile num

		LDA $05 : STA !OAM_p1+$003,x					; store YXPPCCCT
		LDA !MarioImg							;\
		CMP #$43 : BNE .NoFlip						; |
		LDA $06								; |
		CMP #$04 : BNE .NoFlip						; | unless mario is big balloon, xflip the 5th tile
		LDA !OAM_p1+$003,x						; |
		EOR #$40							; |
		STA !OAM_p1+$003,x						; |
		.NoFlip								;/

		LDA $0C								;\
		CMP #$2C : BNE .NotCapeY					; |
		REP #$20							; | special cape check Y
		LDA $80								; |
		CLC : ADC #$0010						; > add 16px
		BRA +								;/

		.NotCapeY							;\
		LDY $00								; |
		REP #$20							; |
		LDA $80								; |
		CLC : ADC $DE32,y						; |
	+	PHA								; | see if tile is on-screen vertically
		CLC : ADC #$0010						; |
		CMP #$0100							; |
		PLA								; |
		SEP #$20							; |
		BCS .Fail							;/
		STA !OAM_p1+$001,x						; > store Y coord

		LDA $0C								;\
		CMP #$2C : BNE .NotCapeX					; |
		REP #$20							; | special cape check X
		LDA $7E								; |
		BRA +								;/

	.Fail	INC $00								;\ increment coord index
		INC $00								;/
		INC $02								; increment tile index
		INC $06								; increment tile counter
		ASL $04								; always shift this
		RTS

		.NotCapeX							;\
		LDY $00								; |
		REP #$20							; |
		LDA $7E								; |
		CLC : ADC $DD4E,y						; | see if tile is on-screen horizontally
	+	PHA								; |
		CLC : ADC #$0080						; |
		CMP #$0200							; |
		PLA								; |
		SEP #$20							; |
		BCS .Fail							;/
		STA !OAM_p1+$000,x						; > store X coord
		XBA								;\ swap
		LSR A								;/

		.WriteHi							;\
		PHX								; |
		PHP								; |
		REP #$20							; |
		TXA								; |
		LSR #2								; |
		TAX								; |
		SEP #$20							; | write OAM hi byte
		ASL $04								; |
		ROL A								; |
		PLP								; |
		ROL A								; |
		AND #$03							; |
		STA !OAMhi_p1+$00,x						; |
		PLX								;/
		INX #4								; increment OAM index
		INC $00								;\ increment coord index
		INC $00								;/
		INC $02								; increment tile index
		INC $06								; increment tile counter
		RTS


	.ClimbOffsets
	dw $FFFD,$0004



MarioTileRemap:	CLC : ADC !MarioTileOffset		; > add player offset
		STA !OAM+$102-$18,y			; original code
		LDX $05					; original code
		RTL					; > return

.Prop		CLC : ADC !MarioPropOffset		; > add player palette offset
		ORA !MarioClimb
		PHA
		LDA $3E
		AND #$07
		CMP #$02 : BNE +			; priority works differently in mode 2
		PLA
		AND #$EF
		BRA ++
	+	PLA
	++	STA !OAM+$103-$18,y			;\
		STA !OAM+$107-$18,y			; | original code
		STA !OAM+$10F-$18,y			;/
		JML $00E3DB				; > return


.Coords		PHY					; preserve

		XBA
		LDA !CurrentMario : BNE +		;\ don't draw mario if he's not in play
		LDA #$F0 : BRA ..WriteY			;/
	+	XBA

		CPY #$10 : BNE ..NoCape			;\
		LDY !MarioPowerUp : BNE ..NoCape	; |
		LDY $73DF				; | adjust Mario's cape when small
		CLC : ADC.w MarioCapeY,y		; |
		..NoCape				;/

		STA $0E					;\
		LDA !DizzyEffect : BEQ ..NoDizzy	; |
		REP #$20				; |
		LDA $94					; |
		SEC : SBC $1A				; |
		AND #$00FF				; |
		LSR #3					; |
		ASL A					; |
		PHX					; | adjust mario during dizzy effect
		TAX					; |
		LDA $40A040,x				; |
		AND #$1FFF				; |
		SEC : SBC $1C				; |
		PLX					; |
		EOR #$FFFF : INC A			; |
		CLC : ADC $0E				; |
		SEP #$20				; |
		STA $0E					; |
		..NoDizzy				; |
		LDA $0E					;/

		LDY !Level+1 : BNE ..NoDown		;\
		LDY !Level				; |
		CPY #$25 : BNE ..NoDown			; |
		LDY !Level+4 : BEQ ..NoDown		; |
		REP #$20				; |
		STA $0E					; |
		LDA $6DF6				; | move down with screen on upgrade menu
		AND #$00FF				; |
		CLC : ADC $0E				; |
		CMP #$00F0				; |
		BCC $03 : LDA #$00F0			; |
		SEP #$20				; |
		..NoDown				;/

		..WriteY
		PLY					;\ write Ypos
		STA !OAM+$101-$18,y			;/

		REP #$20				;\
		LDA $7E					; |
		CLC : ADC $DD4E,x			; |
		STA $0E					; |
		LDX !MarioClimb : BEQ ..NoClimb		; \
		LDA !MarioDirection			;  |
		AND #$00FF				;  |
		ASL A					;  |
		TAX					;  | climb offset code
		LDA.l ..ClimbOffsets,x			;  |
		CLC : ADC $0E				;  |
		STA $0E					;  |
		..NoClimb				; /
		CLC : ADC #$0080			; |
		CMP #$0200				; | SMW X coord code
		LDA $0E					; |
		SEP #$20				; |
		BCS $05					; |
		STA !OAM+$100-$18,y			; |
		XBA					; |
		LSR A					;/

		RTL					; > return


	..ClimbOffsets
	dw $FFFD,$0004



.Fire		LDA !MarioPowerUp : BEQ ..07		;\
	..3F	LDA #$3F				; |
		LDY !MarioAir				; |
		RTL					; | different pose for throwing fireball when small
	..07	LDA #$07				; |
		LDY !MarioAir				; |
		RTL					;/

.Expand		LDA #$0A : STA $6D84			; overwritten code, number of 8x8 tiles to upload for mario
		LDA !MarioClimb : BEQ ..R

		REP #$20
		LDA !MarioPowerUp-1
		AND #$FF00
		BEQ $03 : LDA #$0080
		CLC : ADC #$7D00+$C00
		STA $6D85
		CLC : ADC #$0200
		STA $6D8F
		SEC : SBC #$01C0
		STA $6D87
		CLC : ADC #$0200
		STA $6D91
		SEP #$20

	..R	RTL




	; Mario's physics routine seems to be at $00DC2D


MarioHurtbox:	PHA
		LDX #$00
		LDA !CurrentMario
		CMP #$01 : BEQ +
		LDX #$80
	+	LDA $00 : STA !P2Hurtbox-$80+0,x
		LDA $08 : STA !P2Hurtbox-$80+1,x
		LDA $01 : STA !P2Hurtbox-$80+2,x
		LDA $02 : STA !P2Hurtbox-$80+4,x
		LDA $03 : STA !P2Hurtbox-$80+5,x
		PLA
		STA $09
		STA !P2Hurtbox-$80+3,x
		PLX
		RTL



macro CommentOut()


;=====================;
; TRANSCRIBED $00C47E ;
;=====================;
MarioMain:
		STZ $78
	; this feature was scrapped during vanilla
	;	LDA $73CB : BPL +
	;	JSL $01C580
	;	STZ $73CB
	;	+

	; keyhole logic
	; BEQ to BRA to $00C4F8

.CODE_00C4F8	LDA $73FB : BEQ .ProcessMario
		JMP .CODE_00C58F

.ProcessMario
.CODE_00C500	LDA $9D : BNE .CODE_00C569
		INC $14				; oh gosh
		LDX #$13			;\
	-	LDA $7495,x			; | auto-decrement $7496-$74A8
		BEQ $03 : DEC $7495,x		; | (note the BNE, $7495 is not decremented)
		DEX : BNE -			;/
		LDA $14
		AND #$03 : BNE .CODE_00C569
		LDA $7495 : BEQ .CODE_00C533	; something related to score count
		; useless score code here??
.CODE_00C533	LDY $74AD			;\
		CPY $74AE			; |
		BCS $03 : LDY $74AE		; |
		LDA $6DDA : BMI +		; |
		CPY #$01 : BNE +		; | POW (blue and silver) timer + music
		LDY $790C : BNE +		; |
		STA !SPC3			; |
	+	CMP #$FF : BEQ .CODE_00C55C	; |
		CPY #$1E : BNE .CODE_00C55C	; |
		LDA #$24 : STA !SPC4		;/
.CODE_00C55C	LDX #$06			;\
	-	LDA $74A8,x			; | auto-decrement $74A9-$74AE
		BEQ $03 : DEC $74A8,x		; | (same as above: $74A8 is not decremented)
		DEX : BNE -			;/
.CODE_00C569	JSR .MARIO_ANIM			; this seems to be the main part of mario's code
		LDA $16				;\ if mario is not pressing select on this frame, skip the item box drop thing
		AND #$20 : BEQ .CODE_00C58F	;/
		; unused debug code here (BRAd past)
.CODE_00C585	PHB				;\
		LDA #$02			; |
		PHA : PLB			; | process item box swap
		JSL $028008			; |
		PLB				;/
.CODE_00C58F	STZ $7402			; clear "mario on note block" flag
		RTS				; return


.MARIO_ANIM	LDA !MarioAnim
		JSL $0086DF

		.ANIM_ptr
		dw .Normal			; 00
		dw .PowerDown			; 01
		dw .MushroomGet			; 02
		dw .CapeGet			; 03
		dw .FlowerGet			; 04
		dw .HorizontalPipe		; 05
		dw .VerticalPipe		; 06
		dw .SlantPipe			; 07
		dw .YoshiWings			; 08
		dw .Death			; 09
		dw .EnterCastle			; 0A
		dw .Freeze			; 0B
		dw .RandomMovement		; 0C
		dw .Door			; 0D





;
; MARIO MAIN START
;

.Normal		; a bunch of debug code at the start
.CODE_00CCBB	LDA $7493			; end level?
		BEQ $03 : JMP .CODE_00C915
		JSR .CODE_00CDDD		; unknown
		LDA $9D : BNE .CODE_00CCDF

		STZ $73E8
		STZ $73DE
		LDA !MarioStunTimer : BEQ .CODE_00CCE0
		DEC !MarioStunTimer
		STZ !MarioXSpeed
		LDA #$0F : STA !MarioImg
.CODE_00CCDF	RTS

.CODE_00CCE0	; special level code
.CODE_00CD24	LDA !MarioYSpeed : BPL +	;\
		LDA !MarioBlocked		; |
		AND #$08 : BEQ +		; | mario y speed = 0 when bonking
		STZ !MarioYSpeed		; |
		+				;/

		JSR .CODE_00DC2D		; > mario X + Y speed
		JSR .CODE_00E92B		; > mario collision
		JSR .CODE_00F595		; > mario screen border interaction

		STZ $73DD
		LDY $73F3 : BNE .CODE_00CD95
		LDA $78BE : BEQ +
		LDA #$1F : STA $8B
	+	LDA !MarioClimbing : BNE .CODE_00CD72
		LDA $748F
		; yoshi check
		BNE .CODE_00CD79
		LDA $8B
		AND #$1B
		CMP #$1B
		BNE .CODE_00CD79
		LDA $15
		AND #$0C : BEQ .CODE_00CD72
		LDY $72 : BNE .CODE_00CD72
		LDA $8B
		AND #$04 : BEQ .CODE_00CD79
.CODE_00CD72	LDA $8B : STA !MarioClimbing
		JMP .CODE_00DB17		; mario climb handler

.CODE_00CD79	LDA !MarioUnderWater : BEQ .CODE_00CD82
		JSR .CODE_00D988		; mario swim handler
		; BRA to next yoshi check
		RTS

.CODE_00CD82	JSR .CODE_00D5F2		; > controls, includes jump/spin jump
		JSR .CODE_00D062		; > shoot fireball routine
		JSR .CODE_00D7E4		; > handle flight + jump Y speed influence
		JSL .CODE_00CEB1		; > set cape image
		; yoshi check
		RTS

.CODE_00CD95	LDA #$42			;\
		LDX $19				; |
		BEQ $02 : LDA #$43		; |
		DEY				; | mario pose during level end
		BEQ $05 : STY $73F3 : LDA #$0F	; |
		STA !MarioImg			; |
		RTS				;/

;
; MARIO MAIN SUB
;

.CODE_00DC2D	LDA !MarioYSpeed : STA $8A
		LDA $73E3 : BEQ +		; wall run stuff
		LSR A
		LDA !MarioXSpeed
		BCC $03 : EOR #$FF : INC A
		STA !MarioYSpeed
	+	LDX #$00 : JSR .MarioSpeed
		LDX #$02 : JSR .MarioSpeed
		LDA $8A : STA !MarioYSpeed
		RTS

		.MarioSpeed
		LDA !MarioXSpeed,x
		ASL #4
		CLC : ADC $73DA,x
		STA $73DA,x
		REP #$20
		PHP
		LDA !MarioXSpeed,x
		LSR #4
		AND #$000F
		CMP #$0008
		BCC $03 : ORA #$FFF0
		PLP
		ADC !MarioXPos,x
		STA !MarioXPos,x
		SEP #$20
		RTS



;
; OTHER ANIMS
;



; anim 0B
.Freeze		STZ $73DE
		STZ $73ED
		LDA $7493 : BEQ .CODE_00C5CE	; end level timer
		JSL $0CAB13
		LDA !GameMode
		CMP #$14 : BEQ .CODE_00C5D1
		JMP .CODE_00C95B

.CODE_00C5CE	STZ !HDMA
.CODE_00C5D1	LDA #$01 : STA $7B88
		LDA #$07 : STA $7928
		JSR .NoButtons
		JMP .CODE_00CD24


.RandomMovement	JSR .NoButtons
		STZ $73DE
		JSR





.CODE_00DC2D
.CODE_00E92B
.CODE_00F595




.NoButtons	STZ $15
		STZ $16
		STZ $17
		STZ $18
		RTS





endmacro








namespace off

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


