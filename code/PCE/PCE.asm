header
sa1rom


;=======;
;DEFINES;
;=======;

	incsrc "../Defines.asm"

;=======;
;HIJACKS;
;=======;

; PCE FIX MUST BE PATCHED FIRST!!
;	...but does it really?

	org $00986C				; patch out initial player/sprite engine call to let it be handled by my own code instead
		BRA $02 : NOP #2		; org: JSL $01808C
	org $00A6C7
		JML PLAYER2_Pipe
	org $00F71A
		JSL PLAYER2_Camera		;\ org: LDA $94 : SEC : SBC $1A
		NOP				;/
	org $00DC4A
		JSL PLAYER2_Coordinates		; org: LDA $8A : STA $7D


	org $01808C
		JML PLAYER2


	org $01CAC2
		JSL CORE_PLATFORM_Bank01	; org: JSL $03B664 (!GetP1Clipping)
	org $01E809
		JML CORE_PLATFORM_Cloud		; org: JSR $F7A7 : BCC $2F ($01E83D)
		NOP
	org $02D71E
		JSL CORE_PLATFORM_Bank02	; org: JSL $01B44F (solid block main)

	org $03911F
		JSL FishingBooFix		; org: JSL $03B664 (!GetP1Clipping)
		LDA !BigRAM : BEQ +		; JSL $03B72B (!CheckContact)
		JSL !HurtPlayers		; BCC $04
		NOP				; JSL $00F5B7 (!HurtMario)
	warnpc $03912D
	org $03912D
	+	RTS


;====;
;CODE;
;====;

	org $1E8000				; claim banks $1E and $1F
	db $53,$54,$41,$52
	dw $FFF7
	dw $0008

	org $158000
	db $53,$54,$41,$52
	dw $FFF7
	dw $0008
	print " "
	print "-- PCE --"
	print "Von Fahrenheit's playable character engine."



;========;
;PLAYER 2;
;========;

	print "Main player engine at $", pc, "."
	PLAYER2:
		LDA #$00				;\
		STA.l !VRAMbase+!VRAMsize+$00		; | reset number of bytes uploaded
		STA.l !VRAMbase+!VRAMsize+$01		;/
		LDA !GameMode

;	if !TrackCPU == 0
		CMP #$12 : BEQ .PreProcess
		CMP #$13 : BNE .NoPreProcess
		.PreProcess
		LDA #$04
		STA !P2Blocked-$80
		STA !P2Blocked
		REP #$20
		STZ $15
		STZ $17
		STZ $6DA2
		STZ $6DA4
		STZ $6DA6
		STZ $6DA8
		SEP #$20
		BRA .ProcessMain
		.NoPreProcess
		CMP #$14 : BNE .Return
;	else
;		CMP #$14 : BEQ $03 : JMP .Return
;	endif


		.ProcessMain
		PHB : PHK : PLB

		JSL .GetCharacter


	; should now be called by SA-1
	;	%TrackSetup(!TrackPCE)

	;	LDA.b #.GetCharacter : STA $3180
	;	LDA.b #.GetCharacter>>8 : STA $3181
	;	LDA.b #.GetCharacter>>16 : STA $3182
	;	JSR $1E80

	;	%TrackCPU(!TrackPCE)

		PLB

		.Return
	;	JML $1081A6			; new constant (how did i come up with this?????)
	; note: the "constant" is just the pointer to the SNES -> SA-1 wrapper for the sprite engine
		RTL				; but it's now called by GameMode14.asm


		.Pipe
		STZ !P2Entrance
		STZ !P2Entrance-$80
		STX !MarioAnim			;\ Store P1 animation trigger and pipe timer
	;	STY $88				;/
		CPX #$07 : BNE ..NoShoot	;\
		LDA #$30			; | slant pipe
		STA !P2SlantPipe		; |
		STA !P2SlantPipe-$80		;/
		STZ !MarioAnim
		JML $00A6CB			; > Return slant pipe
		..NoShoot
		LDA $89				;\
		AND #$03			; |
		CLC : ROR #3			; | Get P2 pipe timer
	;	ORA $88				; |
		ORA #$0F
		STA !P2Pipe			; |
		STA !P2Pipe-$80			;/


		STZ !MarioAnim			; clear mario anim
		REP #$20			;\
		LDA $96				; | Fix Ypos
		CLC : ADC #$000E		; |
		STA !P2YPosLo			; |
		STA !P2YPosLo-$80		; |
		SEP #$20			;/
		JML $00A6CB




		.Camera
		PHY
		LDY #$00
		LDA !MultiPlayer
		AND #$00FF : BEQ ..SingleCamera

		LDA !P2Status-$80			;\
		AND #$00FF				; |
		CMP #$0002 : BCC +			; |
		LDY #$80 : BRA ..SingleCamera		; | multiplayer should use single camera if only one player is left
	+	LDA !P2Status				; |
		AND #$00FF				; |
		CMP #$0002 : BCC +			; |
		LDY #$00 : BRA ..SingleCamera		;/

	+	LDA !GameMode
		AND #$00FF
		CMP #$0014 : BEQ ..AverageCamera
		..SingleCamera
		SEP #$20				; make sure camera movements are smooth for custom characters too
	;	LDA !CurrentMario : BNE ++
		LDA #$77				;\
		CLC : ADC !CameraPower			; | left value (0x77 + power)
		STA $00					;/
		LDA #$77				;\
		SEC : SBC !CameraPower			; | right value (0x77 - power)
		STA $01					;/
	; turns out that 0x77 is the magic number for this camera routine
	; default values are 0x90 for left and 0x5E for right


		REP #$20
		LDA !P2XPosLo-$80,y
		SEC : SBC !CameraXMem
		CMP #$0018 : BCC ++
		CMP #$8000 : BCC ..R
		CMP #$FFE8 : BCS ++

	..L	SEP #$20
		LDA $742A
		CMP $00 : BEQ +++
		INC A
		CMP $00 : BEQ +++
		INC A
		BRA +

	..R	SEP #$20
		LDA $742A
		CMP $01 : BEQ +++
		DEC A
		CMP $01 : BEQ +++
		DEC A
		BRA +

	+++	PHA
		REP #$20
		LDA !P2XPosLo-$80,y : STA !CameraXMem	; save this to know when to scroll again
		SEP #$20
		PLA
	+	STA $742A
	++	REP #$20
		LDA !GameMode
		AND #$00FF
		CMP #$0014 : BEQ ..Level

		..Loading
		LDA $94
		SEC : SBC $1A
		PLY
		RTL

		..Level
		LDA !P2XPosLo-$80,y
		SEC : SBC $1A
		PLY
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
		PLY				; > also restore Y
		RTL				;/

		..Movement
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		SEC : SBC $1A
		PLY
		RTL



		.Coordinates
		LDA !GameMode
		CMP #$14 : BEQ ..R
		TSC
		XBA
		CMP #$37 : BEQ ..R

		PHX
		PHP
		REP #$20
		LDA !MarioXPosLo
		STA !P2XPosLo-$80
		STA !P2XPosLo
		LDA !MarioYPosLo
		CLC : ADC #$0010
		LDX !P2Pipe-$80
		BNE $03 : STA !P2YPosLo-$80
		LDX !P2Pipe : BNE +
		STA !P2YPosLo
		LDA !MultiPlayer
		AND #$00FF : BEQ +
		LDA !P2XPosLo
		SEC : SBC #$0008
		STA !P2XPosLo
		CLC : ADC #$0010
		STA !P2XPosLo-$80
		+

		LDA !CurrentMario
		AND #$00FF : BEQ +
		DEC A
		BEQ $03 : LDA #$0080
		TAX
		LDA !P2XPosLo-$80,x : STA !MarioXPosLo
		+

		PLP
		PLX
	..R	LDA $8A : STA $7D
		RTL



		.GetCharacter
		SEP #$30				; all regs 8-bit
		LDA !CurrentMario : BNE ++		;\
		LDA !GameMode
		CMP #$14 : BNE ++
		REP #$20				; |
		LDA !P2XPosLo-$80 : STA !MarioXPos	; | mario coords when he's not in play
		LDA !P2YPosLo-$80 : STA !MarioYPos	; |
		SEP #$20				; |
		BRA +					;/
	++	LDA !P1Dead : BNE +			; run this code if mario is dead
		LDA !CurrentMario			;\
		DEC A					; |
		TAX					; |
		LDA $6DA2,x : STA $15			; | mario input
		LDA $6DA4,x : STA $17			; |
		LDA $6DA6,x : STA $16			; |
		LDA $6DA8,x : STA $18			; |
		BRA ..NoMario				;/
	+	LDA !MarioAnim				;\ don't skip transitions
		CMP #$06 : BEQ +			;/
		LDA #$09 : STA !MarioAnim		; mario anim = 09 (dead) if he's not in play
	+	JSR RunMario				; if no one plays mario, run his anim code right away
		..NoMario


		LDA !Difficulty				;\
		AND #$20 : BEQ .NotIronman		; |
		LDA !MultiPlayer : BEQ .NotIronman	; |
		LDA !P2Status-$80 : BEQ +		; |
		LDY !P2Status : BNE +			; | ironman
		STA !P2Status				; |
	+	LDA !P2Status : BEQ .NotIronman		; |
		LDY !P2Status-$80 : BNE .NotIronman	; |
		STA !P2Status-$80			; |
		.NotIronman				;/


		REP #$30				; > All regs 16-bit
		LDA.w #$007F				;\
		LDX.w #!P2Base				; | Backup player 2 data
		LDY.w #!PlayerBackupData		; |
		MVN $40,$00				;/
		LDA.w #$007F				;\
		LDX.w #!P1Base				; | Copy player 1 data to player 2 regs
		LDY.w #!P2Base				; |
		MVN $00,$00				;/
		SEP #$30				; > All regs 8-bit

		PHK : PLB				; > Switch banks
		LDA !Characters				;\
		LSR #4					; |
		ASL A					; | Check for player 1 character ID
		CMP.b #..End-..List			; |
		BCC ..P1 : JMP ..P2			;/

		..P1
		TAX					; > X = index
		LDA #$00 : STA !CurrentPlayer		; > Processing P1
		LDA $6DA3 : PHA				;\
		LDA $6DA5 : PHA				; |
		LDA $6DA7 : PHA				; |
		LDA $6DA9 : PHA				; | Copy P1 input to P2
		LDA $6DA2 : STA $6DA3			; |
		LDA $6DA4 : STA $6DA5			; |
		LDA $6DA6 : STA $6DA7			; |
		LDA $6DA8 : STA $6DA9			;/
		LDA !P2Status
		CMP #$02 : BNE +
		LDA !MultiPlayer : BEQ +
		REP #$20
		LDA !PlayerBackupData+$21 : STA !P2XPosLo
		LDA !PlayerBackupData+$24 : STA !P2YPosLo
		JMP ..p1end
		+

		LDA !P2ExtraInput1			;\
		BEQ $03 : STA $6DA3			; |
		LDA !P2ExtraInput2			; |
		BEQ $03 : STA $6DA7			; | Input overwrite
		LDA !P2ExtraInput3			; |
		BEQ $03 : STA $6DA5			; |
		LDA !P2ExtraInput4			; |
		BEQ $03 : STA $6DA9			;/

		LDA !P2Entrance : BEQ +
		STZ $6DA3
		STZ $6DA5
		STZ $6DA7
		STZ $6DA9
		+

		REP #$20				; a 16-bit
		STZ !P2Hitbox1+4			;\ clear hitbox by setting size to 0
		STZ !P2Hitbox2+4			;/
		SEP #$20				; a 8-bit
		JSR Stasis				; stasis
		LDA !Difficulty				;\
		AND #$10 : BEQ +			; |
		LDA $6DA7				; |
		AND #$20 : BEQ +			; |
		LDA !P2HP				; | toggle size with select on critical mode
		CMP #$01 : BEQ ++			; |
		LDA #$01 : BRA +++			; |
	++	LDA !P2MaxHP				; |
	+++	STA !P2HP				; |
		+					;/
		LDA !P2Entrance
		BEQ $03 : DEC !P2Entrance
		CMP #$20 : BNE +
		LDA #$09 : STA !SPC4
		LDA #$1F : STA !ShakeTimer
		+
		JSR (..List,x)				; > run code for player 1

		LDA !P2HurtTimer			;\
		CMP #$0E : BNE +			; |
		LDA !Difficulty				; | P1 riposte
		AND #$03 : BNE +			; |
		JSL CORE_RIPOSTE			; |
		+					;/

		LDA !ApexTimerP1 : BEQ +
		DEC !ApexTimerP1
		+

		REP #$20				; a 16-bit
		LDA !P2BlockedLayer			;\ instantly kill apex if landing on a layer
		AND #$0004 : BNE ..killapexp1		;/
		..apexp1				;\
		LDA !P2Blocked				; |
		AND #$0004 : BNE ..resetapexp1		; |
		LDA !ApexTimerP1			; |
		AND #$FF00				; |
		ORA #$001F				; |
		STA !ApexTimerP1			; |
		LDA !P2YSpeed-1				; |
		CLC : ADC !P2VectorY-1			; |
		BMI ..doneapexp1			; |
		LDA !P2YPosLo				; | update p1 apex reg
		BPL $03 : LDA #$0000			; |
		CMP !ApexP1 : BCS ..doneapexp1		; |
		STA !ApexP1				; |
		BRA ..doneapexp1			; |
		..resetapexp1				; |
		LDA !ApexTimerP1			; |
		AND #$00FF : BNE ..doneapexp1		; |
		..killapexp1				; |
		LDA #$FFFF : STA !ApexP1		; |
		..doneapexp1				;/

		LDA !Characters
		AND #$00F0 : BEQ +
		STZ !P2ExtraInput1			;\ clear input overwrite
		STZ !P2ExtraInput3			;/
	+	SEP #$20				; a 8-bit


		LDA !GameMode
		CMP #$14 : BNE +

		LDA !CurrentMario : BNE +		; > Mario check
		LDA !Characters				;\
		AND #$0F : BEQ +			; |
		REP #$20				; | Make sure "Mario" tags along even if no one plays him
		LDA !P2XPosLo : STA $94			; |
		LDA !P2YPosLo : STA $96			; |
		..p1end
		SEP #$20				;/
	+	PLA : STA $6DA9				;\
		PLA : STA $6DA7				; | Restore P2 input
		PLA : STA $6DA5				; |
		PLA : STA $6DA3				;/


		..P2
		LDA #$01 : STA !CurrentPlayer		; > Processing P2
		REP #$30				; > All regs 16-bit
		LDA.w #$007F				;\
		LDX.w #!P2Base				; | Put player 1 data in proper location
		LDY.w #!P1Base				; |
		MVN $00,$00				;/
		LDA.w #$007F				;\
		LDX.w #!PlayerBackupData		; | Restore player 2 data
		LDY.w #!P2Base				; |
		MVN $00,$40				;/
		SEP #$30				; > All regs 8-bit

		PHK : PLB				; > Switch banks
		LDA !MultiPlayer : BNE ++		;\ P2 is always dead if multiplayer is disabled
		LDA #$02 : STA !P2Status		;/
	-	REP #$20
		LDA !P2XPosLo-$80 : STA !P2XPosLo
		LDA !P2YPosLo-$80 : STA !P2YPosLo
		SEP #$30
		RTL

	++	LDA !P2Status : CMP #$02 : BEQ -
		LDA !Characters				;\
		AND #$0F				; | Check for player 2 character ID
		ASL A					; |
		CMP.b #..End-..List			;/
		BCS +					; > Return if character ID is illegal
		TAX					;

		LDA !P2ExtraInput1			;\
		BEQ $03 : STA $6DA3			; |
		LDA !P2ExtraInput2			; |
		BEQ $03 : STA $6DA7			; | Input overwrite
		LDA !P2ExtraInput3			; |
		BEQ $03 : STA $6DA5			; |
		LDA !P2ExtraInput4			; |
		BEQ $03 : STA $6DA9			;/

		LDA !P2Entrance : BEQ +
		STZ $6DA3
		STZ $6DA5
		STZ $6DA7
		STZ $6DA9
		+

		REP #$20				;\
		STZ !P2Hitbox1+4			; | clear hitbox by setting size to 0
		STZ !P2Hitbox2+4			; |
		SEP #$20				;/
		JSR Stasis				; stasis
		LDA !Difficulty				;\
		AND #$10 : BEQ +			; |
		LDA $6DA7				; |
		AND #$20 : BEQ +			; |
		LDA !P2HP				; | toggle size with select on critical mode
		CMP #$01 : BEQ ++			; |
		LDA #$01 : BRA +++			; |
	++	LDA !P2MaxHP				; |
	+++	STA !P2HP				; |
		+					;/
		LDA !P2Entrance
		BEQ $03 : DEC !P2Entrance
		CMP #$20 : BNE +
		STA !P2Entrance-$80
		LDA #$09 : STA !SPC4
		LDA #$1F : STA !ShakeTimer
		+
		JSR (..List,x)				; > run code for player 2

		LDA !P2HurtTimer			;\
		CMP #$0E : BNE +			; |
		LDA !Difficulty				; | P2 riposte
		AND #$03 : BNE +			; |
		JSL CORE_RIPOSTE			; |
		+					;/

		LDA !ApexTimerP2 : BEQ +
		DEC !ApexTimerP2
		+


		REP #$20				; a 16-bit
		LDA !P2BlockedLayer			;\ instantly kill apex if landing on a layer
		AND #$0004 : BNE ..killapexp2		;/
		..apexp2				;\
		LDA !P2Blocked				; |
		AND #$0004 : BNE ..resetapexp2		; |
		LDA !ApexTimerP2			; |
		AND #$FF00				; |
		ORA #$001F				; |
		STA !ApexTimerP2			; |
		LDA !P2YSpeed-1				; |
		CLC : ADC !P2VectorY-1			; |
		BMI ..doneapexp2			; |
		LDA !P2YPosLo				; | update p1 apex reg
		BPL $03 : LDA #$0000			; |
		CMP !ApexP2 : BCS ..doneapexp2		; |
		STA !ApexP2				; |
		BRA ..doneapexp2			; |
		..resetapexp2				; |
		LDA !ApexTimerP2			; |
		AND #$00FF : BNE ..doneapexp2		; |
		..killapexp2				; |
		LDA #$FFFF : STA !ApexP2		; |
		..doneapexp2				;/

		LDA !Characters
		AND #$000F : BEQ +
		STZ !P2ExtraInput1			;\ clear input overwrite
		STZ !P2ExtraInput3			;/
	+	SEP #$30				; all regs 8-bit

		RTL					; > Return


		..List
		dw Mario				; 0
		dw Luigi				; 1
		dw Kadaal				; 2
		dw Leeway_Redirect			; 3
		dw Alter				; 4
		..End



	Leeway_Redirect:
		JSL Leeway
		RTS


	RunMario:
		LDA !MarioAnim				;\
		CMP #$09 : BNE +			; |
		LDA !CurrentMario : BEQ +		; | if mario status = 9 and mario is in play, set PCE kill reg
		LDA !P2Status : BNE +			; |
		INC !P2Status				;/
	+	LDA !MarioAnim				;\
		PHB					; |
		LDX #$00 : PHX : PLB			; |
		PHK : PEA.w .MarioReturn-1		; |
		PEA $84CF-1				; | if mario animation/status != 0, execute special code
		JML $00C595				; |
		.MarioReturn				; |
		PLB					; |
		.Return					; |
		RTS					;/



print "PCE CORE inserted at ", pc, ". ($", hex(Mario-CORE), " bytes)"

	CORE:
	namespace CORE
BITS:	db $01,$02,$04,$08,$10,$20,$40,$80
	db $01,$02,$04,$08,$10,$20,$40,$80
.16	dw $0001,$0002,$0004,$0008,$0010,$0020,$0040,$0080
	dw $0100,$0200,$0400,$0800,$1000,$2000,$4000,$8000
	incsrc "CORE/SPRITE_INTERACTION.asm"
	incsrc "CORE/EXSPRITE_INTERACTION.asm"
	incsrc "CORE/UPDATE_SPEED.asm"
	incsrc "CORE/PLUMBER_SWIM.asm"
	incsrc "CORE/PLUMBER_CARRY.asm"
	incsrc "CORE/COLLISION.asm"
	incsrc "CORE/LOAD_TILEMAP.asm"
	incsrc "CORE/GENERATE_RAMCODE.asm"
	incsrc "CORE/PIPE.asm"
	incsrc "CORE/SCREEN_BORDER.asm"
	incsrc "CORE/OUTPUT_HURTBOX.asm"
	incsrc "CORE/HURT.asm"
	incsrc "CORE/ATTACK.asm"
	incsrc "CORE/SET_XSPEED.asm"
	incsrc "CORE/COYOTE_TIME.asm"
	incsrc "CORE/SET_GLITTER.asm"
	incsrc "CORE/SET_SPLASH.asm"
	incsrc "CORE/SMOKE_AT_FEET.asm"
	incsrc "CORE/DASH_SMOKE.asm"
	incsrc "CORE/PLAYER_CLIPPING.asm"
	incsrc "CORE/PLATFORM.asm"
	incsrc "CORE/KNOCKED_OUT.asm"
	incsrc "CORE/DISPLAY_CONTACT.asm"
	incsrc "CORE/CHECK_ABOVE.asm"
	incsrc "CORE/RIPOSTE.asm"
	incsrc "CORE/FLASHPAL.asm"
	namespace off


	Stasis:
		LDA !P2Stasis : BEQ .Return
		STZ $6DA3
		STZ $6DA7
		STZ $6DA5
		STZ $6DA9
		DEC !P2AnimTimer
		LDA !CurrentPlayer
		INC A
		CMP !CurrentMario : BNE .Return
		STZ $15
		STZ $16
		STZ $17
		STZ $18
	.Return	RTS


	FishingBooFix:
		STZ !BigRAM
		SEC : JSL !PlayerClipping
		BCC .Return
		STA !BigRAM
	.Return
		RTL

	Mario:
	print " "
	print "Mario modification code inserted at $", pc, " ($", hex(Luigi-Mario), " bytes)"
	incsrc "characters/Mario.asm"
	Luigi:
	print " "
	print "Luigi code inserted at $", pc, " ($", hex(Kadaal-Luigi), " bytes)"
	incsrc "characters/Luigi.asm"
	Kadaal:
	print " "
	print "Kadaal code inserted at $", pc, " ($", hex(End15-Kadaal), " bytes)"
	incsrc "characters/Kadaal.asm"

End15:
print " "
print "$", hex($160000-End15), " bytes left in bank."
print " "

	org $1F8000
	Leeway:
	print " "
	print "Leeway code inserted at $", pc, " ($", hex(Alter-Leeway), " bytes)"
	incsrc "characters/Leeway.asm"
	Alter:
	print " "
	print "Alter code inserted at $", pc, " ($", hex(End1F-Alter), " bytes)"
	incsrc "characters/Alter.asm"


End1F:
print " "
print "$", hex($200000-End1F), " bytes left in bank."
print " "


	; store this pointer at the end to prevent breaking
	org $00E3D6				; property
		dl CORE_PlayerClipping		; $00E3D6 is a psuedo-vector!




