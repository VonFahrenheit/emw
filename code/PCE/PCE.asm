header
sa1rom


;=======;
;DEFINES;
;=======;

	incsrc "Defines.asm"

;=======;
;HIJACKS;
;=======;

; PCE FIX MUST BE PATCHED FIRST!!

	org $00A6C7
		JML PLAYER2_Pipe

	org $00F71A
		JSL PLAYER2_Camera		;\ Org: LDA $94 : SEC : SBC $1A
		NOP				;/

	org $00DC4A
		JSL PLAYER2_Coordinates		; Org: LDA $8A : STA $7D


	org $01808C
		JML PLAYER2



;====;
;CODE;
;====;

	org $158000
	db $53,$54,$41,$52
	dw $FFF7
	dw $0008
	print " "
	print "Von Fahrenheit's playable character engine."
	print "Custom code inserted at $", pc, "."


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

	org $00FEB6
		db $36				; Fireball SFX


	org $0086A3
		JSL Mario_Controls		; > Org: BPL $03 : LDX $6DB3
		NOP

	org $00DC2D
		JML Mario_Stasis		; > Org: LDA $7D : STA $8A

	org $00E3A6
		JML Mario_ExternalAnim		; > Org: LDA $73E0 : CMP #$3D
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

	org $00E2B2					; Mario's base OAM index
		db $00					; Org: $10

	org $00E3D2					; Property
		JML MarioTileRemap_Prop
		dl PlayerClipping			; $00E3D6 is a psuedo-vector!
		NOP #2
		STA !OAM+$113-$18,y
		STA !OAM+$0FB-$18,y
		STA !OAM+$0FF-$18,y
	org $00E3EC
		STA !OAM+$10B-$18,y
	org $00E468					; Tile number
		JSL MarioTileRemap			;\ Org: STA $6302,y : LDX $05
		NOP					;/
	org $00E483					; Ypos
		dw !OAM+$101-$18
	org $00E49B					; Xpos
		dw !OAM+$100-$18
	org $00E4AC					; Hi table
		dw !OAMhi+$40-$6

	pullpc



;========;
;PLAYER 2;
;========;

	print "Main player engine at $", pc, "."
	PLAYER2:
		LDA #$00			;\
		STA !RAMcode_Offset+0		; | Always start with a clear RAM code offset
		STA !RAMcode_Offset+1		;/
		LDA !GameMode
		CMP #$14 : BNE .Return
		PHB : PHK : PLB
		LDA.b #.GetCharacter : STA $3180
		LDA.b #.GetCharacter>>8 : STA $3181
		LDA.b #.GetCharacter>>16 : STA $3182
		JSR $1E80
		PLB

		.Return

		LDA #$01 : STA !ProcessingSprites
	;JML $1081E0		; Fahrenheit's constant (hehe)
		JML $1081A6	; new constant


		.Pipe
		STX $71				;\ Store P1 animation trigger and pipe timer
		STY $88				;/
		CPX #$07 : BNE ..NoShoot	;\
		LDA #$18 : STA !P2SlantPipe	; | Slant pipe
		STA !P2SlantPipe-$80		;/
		JML $00A6CB			; > Return slant pipe
		..NoShoot
		LDA $89				;\
		AND #$03			; |
		CLC : ROR #3			; | Get P2 pipe timer
		ORA $88				; |
		STA !P2Pipe			; |
		STA !P2Pipe-$80			;/
		REP #$20			;\
		LDA $96				; | Fix Ypos
		CLC : ADC #$000E		; |
		STA !P2YPosLo			; |
		STA !P2YPosLo-$80		; |
		SEP #$20			;/
		JML $00A6CB

		.Camera
		LDA !MultiPlayer
		AND #$00FF
		BEQ ..SingleCamera
		LDA !GameMode
		AND #$00FF
		CMP #$0014 : BEQ ..AverageCamera
		..SingleCamera

	SEP #$20			; make sure camera movements are smooth for custom characters too
	LDA !CurrentMario
	BNE ++

	LDA !P2XSpeed-$80
	CLC : ADC !P2VectorX-$80
	BEQ ++
	BPL ..R
..L	LDA $742A
	CMP #$90 : BEQ +
	INC A
	BRA +
..R	LDA $742A
	CMP #$5E : BEQ +
	DEC A
+	STA $742A
++	REP #$20

		LDA $94
		SEC : SBC $1A
		RTL
		..AverageCamera
		LDA !P2XPosLo-$80
		SEC : SBC !P2XPosLo
		BPL $04 : EOR #$FFFF : INC A
		CMP #$00C0
		BCC ..Movement
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		SEC : SBC $1A
		STA $742A
		PLA				;\
		SEP #$20			; | Kill previous RTL and turn to 8-bit
		PLA				;/
		STZ $7400			; > Disable camera movement
		PLB				;\ Restore bank and return
		RTL				;/
		..Movement
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		SEC : SBC $1A
		RTL



		.Coordinates
		PHX
		PHP
		REP #$20
		LDA $94
		STA !P2XPosLo-$80
		STA !P2XPosLo
		LDA $96
		CLC : ADC #$0010
		LDX !P2Pipe-$80
		BNE $03 : STA !P2YPosLo-$80
		LDX !P2Pipe
		BNE $03 : STA !P2YPosLo

		PLP
		PLX
		LDA $8A : STA $7D
		RTL



		.GetCharacter
		REP #$30			; > All regs 16-bit
		LDA.w #$007F			;\
		LDX.w #!P2Base			; | Backup player 2 data
		LDY.w #!PlayerBackupData	; |
		MVN $40,$00			;/
		LDA.w #$007F			;\
		LDX.w #!P1Base			; | Copy player 1 data to player 2 regs
		LDY.w #!P2Base			; |
		MVN $00,$00			;/
		SEP #$30			; > All regs 8-bit

		PHK : PLB			; > Switch banks
		LDA !Characters			;\
		LSR #4				; |
		ASL A				; | Check for player 1 character ID
		CMP.b #..End-..List		; |
		BCC ..P1 : JMP ..P2		;/

		..P1
		TAX				; > X = index
		LDA #$00 : STA !CurrentPlayer	; > Processing P1
		TDC : STA $3000			;\ Backup DP
		XBA : STA $3001			;/
		LDA #$6D : XBA			;\ DP = $6DA0
		LDA #$A0 : TCD			;/
		LDA $03 : PHA			;\
		LDA $05 : PHA			; |
		LDA $07 : PHA			; |
		LDA $09 : PHA			; | Copy P1 input to P2
		LDA $02 : STA $03		; |
		LDA $04 : STA $05		; |
		LDA $06 : STA $07		; |
		LDA $08 : STA $09		;/
		LDA $3001 : XBA			;\ Restore DP
		LDA $3000 : TCD			;/
	LDA !P2Stasis : BEQ +
	STZ $6DA2
	STZ $6DA4
	STZ $6DA6
	STZ $6DA8
	LDA !CurrentMario
	CMP #$01 : BNE +
	STZ $15
	STZ $16
	STZ $17
	STZ $18
	+

		LDA !P2Status
		CMP #$02 : BNE +
		REP #$20
		LDA !PlayerBackupData+$02 : STA !P2XPosLo
		LDA !PlayerBackupData+$06 : STA !P2YPosLo
		BRA +++
		+

		REP #$20			;\
		STZ !P2Hurtbox+4		; | Reset hitboxes
		STZ !P2Hitbox+4			; |
		SEP #$20			;/

		LDA !P2Platform : BNE ++	;\
		LDA !P2SpritePlatform		; | Sprite platform setup
		STA !P2Platform			; |
		BEQ ++				; |
		LDA #$04 : TSB !P2Blocked	; |
		++				;/
		LDA !P2ExtraInput1		;\
		BEQ $03 : STA $6DA3		; |
		LDA !P2ExtraInput2		; |
		BEQ $03 : STA $6DA7		; | Input overwrite
		LDA !P2ExtraInput3		; |
		BEQ $03 : STA $6DA5		; |
		LDA !P2ExtraInput4		; |
		BEQ $03 : STA $6DA9		;/
		JSR ClearBox
		JSR (..List,x)			; > Run code for player 1
		LDA !Characters
		AND #$F0
		BEQ +
		REP #$20			;\
		STZ !P2ExtraInput1		; | Clear input overwrite
		STZ !P2ExtraInput3		; |
		SEP #$20			;/
	+	LDA !P2SpritePlatform : BEQ +	;\
		STA !P2PrevPlatform		; | Sprite platform clear
		STZ !P2SpritePlatform		; |
		+				;/

		LDA !CurrentMario : BNE +	; > Mario check
		LDA !Characters			;\
		AND #$0F			; |
		BEQ +				; |
		REP #$20			; | Make sure "Mario" tags along even if no one plays him
		LDA !P2XPosLo : STA $94		; |
		LDA !P2YPosLo : STA $96		; |
	+++	SEP #$20			;/
	+	PLA : STA $6DA9			;\
		PLA : STA $6DA7			; | Restore P2 input
		PLA : STA $6DA5			; |
		PLA : STA $6DA3			;/


		..P2
		LDA #$01 : STA !CurrentPlayer	; > Processing P2
		REP #$30			; > All regs 16-bit
		LDA.w #$007F			;\
		LDX.w #!P2Base			; | Put player 1 data in proper location
		LDY.w #!P1Base			; |
		MVN $00,$00			;/
		LDA.w #$007F			;\
		LDX.w #!PlayerBackupData	; | Restore player 2 data
		LDY.w #!P2Base			; |
		MVN $00,$40			;/
		SEP #$30			; > All regs 8-bit

		PHK : PLB			; > Switch banks
		LDA !MultiPlayer : BNE ++	;\ P2 is always dead if multiplayer is disabled
		LDA #$02 : STA !P2Status	;/
	-	REP #$20
		LDA !P2XPosLo-$80 : STA !P2XPosLo
		LDA !P2YPosLo-$80 : STA !P2YPosLo
		SEP #$30
		RTL

	++	LDA !P2Status : CMP #$02 : BEQ -
		LDA !Characters			;\
		AND #$0F			; | Check for player 2 character ID
		ASL A				; |
		CMP.b #..End-..List		;/
		BCS +				; > Return if character ID is illegal
		TAX				;
	LDA !P2Stasis : BEQ ++
	STZ $6DA3
	STZ $6DA5
	STZ $6DA7
	STZ $6DA9
	LDA !CurrentMario
	CMP #$02 : BNE ++
	STZ $15
	STZ $16
	STZ $17
	STZ $18
	++

		REP #$20			;\
		STZ !P2Hurtbox+4		; | Reset hitboxes
		STZ !P2Hitbox+4			; |
		SEP #$20			;/


		LDA !P2Platform : BNE +++	;\
		LDA !P2SpritePlatform		; | Sprite platform setup
		STA !P2Platform			; |
		BEQ +++				; |
		LDA #$04 : TSB !P2Platform	; |
		+++				;/
		LDA !P2ExtraInput1		;\
		BEQ $03 : STA $6DA3		; |
		LDA !P2ExtraInput2		; |
		BEQ $03 : STA $6DA7		; | Input overwrite
		LDA !P2ExtraInput3		; |
		BEQ $03 : STA $6DA5		; |
		LDA !P2ExtraInput4		; |
		BEQ $03 : STA $6DA9		;/
		JSR ClearBox
		JSR (..List,x)			; > Run code for player 2
		LDA !Characters
		AND #$0F
		BEQ +
		REP #$20			;\
		STZ !P2ExtraInput1		; | Clear input overwrite
		STZ !P2ExtraInput3		; |
		SEP #$20			;/
	+	LDA !P2SpritePlatform : BEQ +	;\
		STA !P2PrevPlatform		; | Sprite platform clear
		STZ !P2SpritePlatform		; |
		+				;/
		SEP #$30			; > All regs 8-bit
	+	RTL				; > Return


		..List
		dw Mario
		dw Luigi			; < Unused
		dw Kadaal
		dw Leeway
		dw Alter
		..End


print "PCE CORE inserted at ", pc, ". ($", hex(Mario-CORE), " bytes)"
print "Mario modification code at $", hex(Mario), " ($", hex(Luigi-Mario), " bytes)"
print "Luigi code at $", hex(Luigi), " ($", hex(Kadaal-Luigi), " bytes)"
print "Kadaal code at $", hex(Kadaal), " ($", hex(Leeway-Kadaal), " bytes)"
print "Leeway code at $", hex(Leeway), " ($", hex(Alter-Leeway), " bytes)"

	CORE:
	namespace CORE
BITS:	db $01,$02,$04,$08,$10,$20,$40,$80
	db $01,$02,$04,$08,$10,$20,$40,$80
.16	dw $0001,$0002,$0004,$0008,$0010,$0020,$0040,$0080
	dw $0100,$0200,$0400,$0800,$1000,$2000,$4000,$8000
	incsrc "CORE/SPRITE_INTERACTION.asm"
	incsrc "CORE/EXSPRITE_INTERACTION.asm"
	incsrc "CORE/UPDATE_SPEED.asm"
	incsrc "CORE/LAYER_INTERACTION.asm"
	incsrc "CORE/LOAD_TILEMAP.asm"
	incsrc "CORE/GENERATE_RAMCODE.asm"
	incsrc "CORE/PIPE.asm"
	incsrc "CORE/SCREEN_BORDER.asm"
	incsrc "CORE/CLIMB_GROUND.asm"
	incsrc "CORE/HURT.asm"
	incsrc "CORE/ATTACK.asm"
	incsrc "CORE/SET_XSPEED.asm"
	incsrc "CORE/COYOTE_TIME.asm"
	namespace off



	ClearBox:
		REP #$20			;\
		STZ !P2Hurtbox+0		; |
		STZ !P2Hurtbox+2		; |
		STZ !P2Hurtbox+4		; | Clear hurt/hitbox
		STZ !P2Hitbox+0			; |
		STZ !P2Hitbox+2			; |
		STZ !P2Hitbox+4			; |
		SEP #$20			;/
		RTS


	; Mario's physics routine seems to be at $00DC2D

	Mario:
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
		LDA !P2Blocked : TSB !MarioBlocked	;\
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
		RTS


		.Stasis
		LDA !CurrentMario : BEQ +		; > If there's no Mario, just go on as usual
		CMP #$02 : BEQ ++			; > Branch if P2 is controlling Mario
		LDA !P2Stasis-$80 : BEQ +		; > Check for P1 stasis
	-	JML $00DC77				; > Don't apply Mario speed
	++	LDA !P2Stasis : BNE -			; > Check for P2 stasis
	+	LDA $7D : STA $8A			;\ Return as normal
		JML $00DC2F				;/


		.ExternalAnim
		LDA !CurrentMario : BEQ ..NoExternal+1
		DEC A
		CLC : ROL #2
		PHY
		TAY
		LDA !P2ExternalAnimTimer-$80,y		;\
		BEQ ..ClearExternal			; |
		DEC A					; |
		STA !P2ExternalAnimTimer-$80,y		; | Enforce external animations for Mario
		LDA !P2ExternalAnim-$80,y		; |
		STA $73E0				; |
		BRA ..NoExternal			;/

		..ClearExternal
		LDA #$00 : STA !P2ExternalAnim-$80,y	; Clear once timer runs out

		..NoExternal
		PLY
		LDA $73E0				;\
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


		.Controls
		PHP
		LDA !CurrentMario
		BEQ +
		DEC A
		CLC : ROR #2
		TAY
		REP #$20
		LDA !P2ExtraInput1-$80,y
		ORA !P2ExtraInput3-$80,y
		SEP #$20
		BEQ +
		LDA !P2ExtraInput1-$80,y		;\
		BEQ $02 : STA $15			; |
		LDA !P2ExtraInput2-$80,y		; |
		BEQ $02 : STA $16			; | Input overwrite
		LDA !P2ExtraInput3-$80,y		; |
		BEQ $02 : STA $17			; |
		LDA !P2ExtraInput4-$80,y		; |
		BEQ $02 : STA $18			;/
		PLP
		PLA : PLA : PLA
		JML $0086C6

	+	PLP
		BPL ..Return				; > Not sure what this actually does but it's in the source code
		LDX #$00				;\
		LDA !MultiPlayer			; |
		BEQ ..Return				; | Allow P2 to control Mario
		LDA !Characters				; |
		AND #$0F : BNE ..Return			; |
		INX					;/

		..Return
		RTL


		.Palette
		LDA !MarioPropOffset			;\
		AND #$00FF				; |
		ASL #3					; | Make sure Mario palette is uploaded to the right place
		CLC : ADC #$0086			; |
		TAY : STY $2121				; |
		JML $00A30E				;/


		.PaletteData
		LDA.w #!MarioPalData : STA $6D82		; Mario's palette is in I-RAM
		LDA !MarioPalOverride
		AND #$00FF : BNE ..override

		PEI ($00)
		PHY
		TYA
		CLC : ADC.w #$E2A2
		STA $00
		LDA ($00) : STA $00
		LDY #$12
	-	LDA ($00),y : STA !MarioPalData,y	; move Mario's palette into buffer
		DEY #2 : BPL -
		PLY
		PLA : STA $00

		..override
		RTL



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


MarioTileRemap:	CLC : ADC !MarioTileOffset		; > Add player offset
		STA !OAM+$102-$18,y			;\ Original code
		LDX $05					;/
		RTL					; > Return

.Prop		CLC : ADC !MarioPropOffset		; > Add player palette offset
		STA !OAM+$103-$18,y			;\
		STA !OAM+$107-$18,y			; | Original code
		STA !OAM+$10F-$18,y			;/
		JML $00E3DB				; > Return


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




	Luigi:
		RTS

	Kadaal:
	incsrc "Kadaal.asm"
	Leeway:
	incsrc "Leeway.asm"
	Alter:
	incsrc "Alter.asm"

;=============;
;HELP ROUTINES;
;=============;

; To load player 1 clipping, do:
;	CLC
;	LDA #$00
;	JSL !GetPlayerClipping
;
; To load player 2 clipping, do:
;	CLC
;	LDA #$01
;	JSL !GetPlayerClipping
;
; To check for contact, do:
;	SEC
;	JSL !GetPlayerClipping
;
; When checking for contact, the routine will compare the hitbox stored at $04-$07, $0A-$0B to player hitboxes.
; Upon returning, the routine will yield the following result:
;	Carry flag: set if contact is detected, otherwise clear
;	A: first bit set if P1 contact is detected, second bit set if P2 contact is detected
; To check for contact, a sprite can do:
;	JSL $03B69F
;	SEC : JSL !PlayerClipping
;	BCC .NoContact
;	LSR A : BCC .P2
;	.P1
;	;[code]
;	.P2
;	;[code]
;	.NoContact
;

	PlayerClipping:
		PHX				;\ Backup stuff
		PHB : PHK : PLB			;/
		BCS .Compare			;\ Split to different parts of routine based on input
		CMP #$00 : BNE +		;/
		PEA .End-1 : JMP .P1		; > Load P1 hitbox, then end
	+	PEA .End-1 : JMP .P2		; > Load P2 hitbox, then end

		.Compare
		LDX #$00			; < X = contact bits
		LDA !MultiPlayer : BEQ +
		LDA !Characters
		AND #$0F
		BNE ++
		LDA !P1Dead
		ORA $71
		BNE +
		BRA .P2Yes
	++	LDA !P2Status : BNE +
		LDA !P2Pipe : BNE +
	.P2Yes	PHX				; > Backup X
		JSR .P2				;\ Check for P2 contact
		JSL !Contact16			;/
		PLA				;\
		BCC $02 : LDA #$02		; | Mark P2 contact
		TAX				;/

	+	LDA !Characters
		AND #$F0
		BNE +
		LDA !P1Dead
		ORA $71
		BNE .Result
		BRA .P1Yes
	+	LDA !P2Status-$80 : BNE .Result
		LDA !P2Pipe-$80 : BNE .Result
	.P1Yes	PHX				; > Backup X
		JSR .P1				;\ Check for P1 contact
		JSL !Contact16			;/
		PLA				;\
		BCC $02 : ORA #$01		; | Mark P1 contact
		TAX				;/

		.Result
		CLC				; > Clear carry
		TXA				; > A = contact bits
		BEQ $01 : SEC			; > C = contact flag

		.End
		PLB
		PLX
		RTL


		.CharPointer
		dw $FFFF
		dw Luigi
		dw Kadaal_ANIM
		dw Leeway_ANIM


		.P1
		LDA !Characters			;\
		LSR #4				; | P1 index
		ASL A				; |
		TAY				;/
		REP #$30			;\
		LDA !P2Anim-$80 : STA $F0	; | P1 setup
		LDA !P2XPosLo-$80 : STA $08	; |
		LDA !P2YPosLo-$80 : STA $02	;/
		BRA .ReadData			; > Write hitbox

		.P2
		LDA !Characters			;\
		AND #$0F			; | P2 index
		ASL A				; |
		TAY				;/
		REP #$30			;\
		LDA !P2Anim : STA $F0		; | P2 setup
		LDA !P2XPosLo : STA $08		; |
		LDA !P2YPosLo : STA $02		;/

		.ReadData
		LDA.w .CharPointer,y		;\
		CMP #$FFFF : BNE .PCE		; |
		SEP #$30			; | Get Mario clipping
		JSL !GetP1Clipping		; |
		RTS				;/

	.PCE	STA $00				;\
		LDA $F0				; |
		AND #$00FF			; | Get PCE clipping value
		ASL #3				; |
		CLC : ADC #$0006		; |
		TAY				;/
		LDA ($00),y			;\
		INC A				; < Get left X coordinate
		STA $F0				; | (Set up pointers to player clipping)
		CLC : ADC #$0006		; < Get upper Y coordinate
		STA $F2				; |
		CLC : ADC #$0002		; < Get pointer to second width
		STA $F4				;/
		LDA ($F0)			;\
		AND #$00FF			; |
		CMP #$0080			; |
		BCC $03 : ORA #$FF00		; | Player X coordinates
		CLC : ADC $08			; |
		STA $00				; |
		XBA : STA $08			;/
		LDA ($F2)			;\
		AND #$00FF			; |
		CMP #$0080			; |
		BCC $03 : ORA #$FF00		; | Player Y coordinates
		CLC : ADC $02			; |
		STA $01				; |
		SEP #$30			; |
		XBA : STA $09			;/
		LDA #$10			;\
		SEC : SBC $01			; | This arcane magic is player height
		CLC : ADC !P2YPosLo		; | (NEVER CHANGE THIS EVER)
		STA $03				;/
		LDY #$01			;\ Player width
		LDA #$10 : STA $02		;/
		RTS




	; -- Get map16 routine --

	GET_MAP16:

		LDA !MarioXPosHi
		PHA
		LDA !MarioXPosLo
		PHA
		CLC
		ADC #$08
		AND #$F0			; > Only accept even tiles
		STA !MarioXPosLo
		LDA !MarioXPosHi
		ADC #$00
		STA !MarioXPosHi

		LDA !MarioYPosLo		; Load Mario Ypos (lo)
		AND #$F0			; Check only the highest nybble
		STA $06				; Store to scratch RAM
		LDA !MarioXPosLo		; Load Mario Xpos (lo)
		LSR				;\
		LSR				; | Divide by 16 (Xpos is now in 16*16-tiles rather than pixels)
		LSR				; |
		LSR				;/
		ORA $06				; High nybble is now high nybble of lo Ypos and low nybble is Xpos (tiles)
		PHA				; Preserve this most peculiar value
		LDA !RAM_ScreenMode		; Load screen mode
		AND #$01			; Check vertical layer 1
		BEQ .Horizontal			; Branch if clear

		.Vertical
		PLA				; Restore the weirdo value
		LDX !MarioXPosHi		; Load Mario Ypos (hi) in X
		CLC				; Clear carry
		ADC.L $00BA80,x			; Add a massive map16 table (indexed by X) to weirdo-value
		STA $05				; Store to scratch RAM
		LDA.L $00BABC,x			; Load another massive map16 table (indexed by the same X)
		ADC !MarioXPosHi		; Add with Mario Xpos (hi)
		STA $06				; Store to scratch RAM
		BRA .Shared			; BRA to a shared routine

		.Horizontal
		PLA				; Restore weirdo-value
		LDX !MarioXPosHi		; Load Mario Xpos (hi)
		CLC				; Clear carry
		ADC.L $00BA60,x			; Add with massive map16 table
		STA $05				; Store to scratch RAM
		LDA.L $00BA9C,x			; Load massive map16 table
		ADC !MarioYPosHi		; Add with Mario Ypos (hi)
		STA $06				; Store to scratch RAM

		.Shared
		LDA.B #$7E			; Bank 0x7E
		STA $07				; Store to scratch RAM
		PLA
		STA !MarioXPosLo
		PLA
		STA !MarioXPosHi
		RTS

;===========;
;SET_GLITTER;
;===========;
	SET_GLITTER:
		LDA !P2Offscreen
		BNE .Return
		LDY #$03			; Set up loop

.Loop		LDA $77C0,y			;\
		BEQ .Spawn			; |
		DEY				; | Find empty smoke sprite slot
		BPL .Loop			;/
.Return		RTS

.Spawn		LDA #$05 : STA $77C0,y		; Smoke sprite to spawn
		LDA #$10 : STA $77CC,y		; Show glitter sprite for 16 frames
		BIT !P2Map16Index
		BMI .NoMap16

.Map16		LDA $98 : STA $77C4,y
		LDA $9A : STA $77C8,y
		RTS

.NoMap16	LDA !P2XPosLo			;\
		CLC : ADC #$08			; | Spawn at player X + 8 pixels
		STA $77C8,y			;/
		LDA !P2YPosLo			;\
		CLC : ADC #$08			; | Spawn at player Y + 8 pixels
		STA $77C4,y			;/
		RTS



;==========;
;GIVE_SCORE;
;==========;
; --Input--
; $00 = score sprite to spawn
; $01 = consecutive enemies killed in one jump, added to $00 (set to zero to ignore)
; Routine spawns score sprite independent of layer 1, one tile above player 2.
; Y contains the score sprite index, so the positions can easily be altered afterwards.

	GIVE_SCORE:
		PHY				; Preserve Y
		LDY #$05

.Loop		LDA $76E1,y
		BEQ .Spawn
		DEY
		BPL .Loop
		PLY				; Restore Y
		RTS

.Spawn		LDA $00
		CLC : ADC $01			; Increase based on kill count
		STA $76E1,y			; Spawn score sprite
		LDA !P2XPosLo			;\
		STA $76ED,y			; |
		LDA !P2XPosHi			; |
		STA $76F3,y			; |
		REP #$20			; |
		LDA !P2YPosLo			; | score sprite pos = (sprite pos - 16 Ypixels)
		SEC : SBC #$0010		; |
		SEP #$20			; |
		STA $76E7,y			; |
		XBA				; |
		STA $76F9,y			;/
		LDA #$30			;\ Score sprite Yspeed
		STA $76FF,y			;/
		LDA #$00			;\ Make score sprite independent of BG1
		STA $7705,y			;/
		PLY				; Restore Y
		RTS


	End:


print "$", hex(End-PLAYER2+8), " bytes used by this patch."
print " "