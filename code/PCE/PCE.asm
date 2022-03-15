

;=======;
;HIJACKS;
;=======;

; PCE FIX MUST BE PATCHED FIRST!!
;	...but does it really?

	org $00986C				; patch out initial player/sprite engine call to let it be handled by my own code instead
		BRA $02 : NOP #2		; org: JSL $01808C
	org $00A6C7
		JML Multiplayer_Pipe

	org $00DC4A
		JSL Multiplayer_Coordinates	; org: LDA $8A : STA $7D


	org $01808C
		JML PCE


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
	PCE:
		LDA #$00				;\
		STA.l !VRAMbase+!VRAMsize+$00		; | reset number of bytes uploaded
		STA.l !VRAMbase+!VRAMsize+$01		;/
		LDA !GameMode

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
		BRA ProcessMain
		.NoPreProcess
		CMP #$14 : BEQ ProcessMain
		.Return
		RTL


	ProcessMain:
		SEP #$30					; all regs 8-bit


		.Mario
		LDA !CurrentMario : BNE ..inplay		;\
		LDA !GameMode
		CMP #$14 : BNE ..inplay
		..notinplay					;\
		REP #$20					; |
		LDA !P2XPosLo-$80 : STA !MarioXPos		; | mario coords when he's not in play
		LDA !P2YPosLo-$80 : STA !MarioYPos		; |
		SEP #$20					; |
		BRA ..anim					;/
		..inplay
		LDA !P1Dead : BEQ ..marioinput			; check if mario is marked as dead
		..anim
		LDA !MarioAnim					;\ don't skip transitions
		CMP #$06 : BEQ ..call				;/
		LDA #$09 : STA !MarioAnim			; mario anim = 09 (dead) if he's not in play
		..call
		JSR RunMario					; if no one plays mario, run his anim code right away
		BRA ..done
		..marioinput
		LDA !CurrentMario				;\
		DEC A						; |
		TAX						; |
		LDA $6DA2,x : STA $15				; | mario input
		LDA $6DA4,x : STA $17				; |
		LDA $6DA6,x : STA $16				; |
		LDA $6DA8,x : STA $18				;/
		..done


		.IronmanMode
		LDA !Difficulty					;\
		AND.b #!IronmanMode : BEQ ..done		; |
		LDA !MultiPlayer : BEQ ..done			; |
		..p1						; |
		LDA !P2Status-$80 : BEQ ..p2			; |
		LDY !P2Status : BNE ..p2			; | ironman
		STA !P2Status					; |
		..p2						; |
		LDA !P2Status : BEQ ..done			; |
		LDY !P2Status-$80 : BNE ..done			; |
		STA !P2Status-$80				; |
		..done						;/



	ProcessPlayer1:
		LDA #$00 : STA !CurrentPlayer			; > processing P1

		.CheckStatus					;\
		LDA !P2Status-$80				; |
		CMP #$02 : BNE ..done				; |
		..dead						; |
		LDA #$01 : TSB !PlayerWaiting			; > if dead, set wait flag
		LDA !MultiPlayer : BEQ ..done			; |
		REP #$20					; | just skip processing if player 1 is dead
		LDA !P2XPosLo : STA !P2XPosLo-$80		; |
		LDA !P2YPosLo : STA !P2YPosLo-$80		; |
		SEP #$20					; |
		JMP ProcessPlayer2				; |
		..done						;/

		.CheckWait
		LDA !MultiPlayer : BEQ ..done
		LDA !PlayerWaiting : BEQ ..done
		CMP #$01 : BNE ..done
		LDA #$0F : STA !P2Invinc-$80
		JMP ProcessPlayer2
		..done


		REP #$30					; > all regs 16-bit
		LDA.w #$007F					;\
		LDX.w #!P2Base					; | backup player 2 data
		LDY.w #!PlayerBackupData			; |
		MVN $40,$00					;/
		LDA.w #$007F					;\
		LDX.w #!P1Base					; | copy player 1 data to player 2 regs
		LDY.w #!P2Base					; |
		MVN $00,$00					;/
		PHK : PLB					; > B = K
		STZ !P2Hitbox1+4				;\ clear hitboxes by setting size to 0
		STZ !P2Hitbox2+4				;/ (do it here since A is 16-bit)
		SEP #$30					; > all regs 8-bit


		LDA $6DA3 : PHA					;\
		LDA $6DA5 : PHA					; | input backup
		LDA $6DA7 : PHA					; |
		LDA $6DA9 : PHA					;/


		.Inputs						;\
		LDA !P2Entrance : BEQ ..allowinputs		; |
		..entrance					; |
		BMI ..noinputs					; |
		DEC !P2Entrance					; |
		CMP #$20 : BNE ..noinputs			; |
		LDA #$09 : STA !SPC4				; |
		LDA #$1F : STA !ShakeTimer			; | entrance animation (no inputs)
		..noinputs					; |
		STZ $6DA3					; |
		STZ $6DA5					; |
		STZ $6DA7					; |
		STZ $6DA9					; |
		BRA ..done					;/
		..allowinputs					;\
		LDA $6DA2 : STA $6DA3				; |
		LDA $6DA4 : STA $6DA5				; | get joypads
		LDA $6DA6 : STA $6DA7				; |
		LDA $6DA8 : STA $6DA9				;/
		LDA !P2ExtraInput1				;\
		BEQ $03 : STA $6DA3				; |
		LDA !P2ExtraInput2				; |
		BEQ $03 : STA $6DA7				; |
		LDA !P2ExtraInput3				; | input override
		BEQ $03 : STA $6DA5				; |
		LDA !P2ExtraInput4				; |
		BEQ $03 : STA $6DA9				; |
		..done						;/


		JSR Stasis					; apply stasis


		.CriticalMode					;\
		LDA !Difficulty					; |
		AND.b #!CriticalMode : BEQ ..done		; |
		LDA $6DA7					; |
		AND #$20 : BEQ ..done				; |
		LDA !P2HP					; | toggle size with select on critical mode
		CMP #$01 : BEQ ..max				; |
		LDA #$01 : BRA ..w				; |
	..max	LDA !P2MaxHP					; |
	..w	STA !P2HP					; |
		..done						;/



		.RunMain					;\
		LDA !Characters					; |
		LSR #4						; | get player 1 character ID (invalid defaults to mario to avoid crashes)
		ASL A						; |
		CMP.b #CharacterList_End-CharacterList		; |
		BCC $02 : LDA #$00				;/
		TAX						; > X = index
		LDA !PlayerBonusHP : PHA			;\
		LDA !P2TempHP					; |
		CLC : ADC !PlayerBonusHP			; | run code for player 1
		STA !PlayerBonusHP				; |
		JSR (CharacterList,x)				; |
		PLA : STA !PlayerBonusHP			;/


		.Riposte					;\
		LDA !P2HurtTimer				; |
		CMP #$0E : BNE ..done				; |
		LDA !Difficulty					; | riposte
		AND #$03 : BNE ..done				; |
		JSL CORE_RIPOSTE				; |
		..done						;/

		JSL CORE_SHOW_HEARTS				; heart counter

		.Apex
		LDA !ApexTimerP1 : BEQ ..nodec			;\ decrement
		DEC !ApexTimerP1				;/
		..nodec
		REP #$20					; A 16-bit
		LDA !P2BlockedLayer				;\ instantly kill apex if landing on a layer
		AND #$0004 : BNE ..killapex			;/
		LDA !P2Blocked					;\
		AND #$0004 : BNE ..reset			; |
		LDA !ApexTimerP1				; |
		AND #$FF00					; |
		ORA #$001F					; |
		STA !ApexTimerP1				; |
		LDA !P2YSpeed-1					; |
		CLC : ADC !P2VectorY-1				; |
		BMI ..done					; |
		LDA !P2YPosLo					; | update p1 apex reg
		BPL $03 : LDA #$0000				; |
		CMP !ApexP1 : BCS ..done			; |
		STA !ApexP1					; |
		BRA ..done					; |
		..reset						; |
		LDA !ApexTimerP1				; |
		AND #$00FF : BNE ..done				; |
		..killapex					; |
		LDA #$FFFF : STA !ApexP1			; |
		..done						;/

		LDA !Characters					;\
		AND #$00F0 : BEQ +				; | clear input override unless mario
		STZ !P2ExtraInput1				; |
		STZ !P2ExtraInput3				;/
	+	SEP #$20					; A 8-bit


		PLA : STA $6DA9					;\
		PLA : STA $6DA7					; | restore P2 input
		PLA : STA $6DA5					; |
		PLA : STA $6DA3					;/


		REP #$30					; > all regs 16-bit
		LDA.w #$007F					;\
		LDX.w #!P2Base					; | put player 1 data in proper location
		LDY.w #!P1Base					; |
		MVN $00,$00					;/
		LDA.w #$007F					;\
		LDX.w #!PlayerBackupData			; | restore player 2 data
		LDY.w #!P2Base					; |
		MVN $00,$40					;/
		PHK : PLB					; > B = K
		SEP #$30					; > all regs 8-bit







	ProcessPlayer2:
	;	LDA !GameMode
	;	CMP #$0F : BEQ .CheckStatus_return

		LDA #$01 : STA !CurrentPlayer			; > processing P2


		REP #$20					;\
		STZ !P2Hitbox1+4				; | clear hitboxes by setting size to 0
		STZ !P2Hitbox2+4				; |
		SEP #$20					;/


		.CheckStatus					;\
		LDA !MultiPlayer : BEQ ..return			; > return if no multiplayer
		LDA !P2Status					; |
		CMP #$02 : BNE ..done				; |
		..dead						; |
		LDA #$02 : TSB !PlayerWaiting			; > if dead, set wait flag
		..return					; | just skip processing if player 2 is dead
		REP #$20					; |
		LDA !P2XPosLo-$80 : STA !P2XPosLo		; |
		LDA !P2YPosLo-$80 : STA !P2YPosLo		; |
		SEP #$20					; |
	+	RTL						; |
		..done						;/


		.CheckWait
		LDA !MultiPlayer : BEQ ..done
		LDA !PlayerWaiting : BEQ ..done
		CMP #$02 : BNE ..done
		LDA #$0F : STA !P2Invinc
		RTL
		..done


		.Inputs						;\
		LDA !P2Entrance : BEQ ..allowinputs		; |
		..entrance					; |
		BMI ..noinputs					; |
		DEC !P2Entrance					; |
		CMP #$20 : BNE ..noinputs			; |
		LDA #$09 : STA !SPC4				; |
		LDA #$1F : STA !ShakeTimer			; | entrance animation (no inputs)
		..noinputs					; |
		STZ $6DA3					; |
		STZ $6DA5					; |
		STZ $6DA7					; |
		STZ $6DA9					; |
		BRA ..done					;/
		..allowinputs					;\
		LDA !P2ExtraInput1				; |
		BEQ $03 : STA $6DA3				; |
		LDA !P2ExtraInput2				; |
		BEQ $03 : STA $6DA7				; | input override
		LDA !P2ExtraInput3				; |
		BEQ $03 : STA $6DA5				; |
		LDA !P2ExtraInput4				; |
		BEQ $03 : STA $6DA9				; |
		..done						;/


		JSR Stasis					; apply stasis


		.CriticalMode					;\
		LDA !Difficulty					; |
		AND.b #!CriticalMode : BEQ ..done		; |
		LDA $6DA7					; |
		AND #$20 : BEQ ..done				; |
		LDA !P2HP					; | toggle size with select on critical mode
		CMP #$01 : BEQ ..max				; |
		LDA #$01 : BRA ..w				; |
	..max	LDA !P2MaxHP					; |
	..w	STA !P2HP					; |
		..done						;/



		.RunMain					;\
		LDA !Characters					; |
		AND #$0F					; | get player 2 character ID (invalid defaults to mario to avoid crashes)
		ASL A						; |
		CMP.b #CharacterList_End-CharacterList		; |
		BCC $02 : LDA #$00				;/
		TAX						; > X = index
		LDA !PlayerBonusHP : PHA			;\
		LDA !P2TempHP					; |
		CLC : ADC !PlayerBonusHP			; | run code for player 2
		STA !PlayerBonusHP				; |
		JSR (CharacterList,x)				; |
		PLA : STA !PlayerBonusHP			;/


		.Riposte					;\
		LDA !P2HurtTimer				; |
		CMP #$0E : BNE ..done				; |
		LDA !Difficulty					; | riposte
		AND #$03 : BNE ..done				; |
		JSL CORE_RIPOSTE				; |
		..done						;/


		JSL CORE_SHOW_HEARTS				; heart counter


		.Apex
		LDA !ApexTimerP2 : BEQ ..nodec			;\ decrement
		DEC !ApexTimerP2				;/
		..nodec
		REP #$20					; A 16-bit
		LDA !P2BlockedLayer				;\ instantly kill apex if landing on a layer
		AND #$0004 : BNE ..killapex			;/
		LDA !P2Blocked					;\
		AND #$0004 : BNE ..reset			; |
		LDA !ApexTimerP2				; |
		AND #$FF00					; |
		ORA #$001F					; |
		STA !ApexTimerP2				; |
		LDA !P2YSpeed-1					; |
		CLC : ADC !P2VectorY-1				; |
		BMI ..done					; |
		LDA !P2YPosLo					; | update p2 apex reg
		BPL $03 : LDA #$0000				; |
		CMP !ApexP2 : BCS ..done			; |
		STA !ApexP2					; |
		BRA ..done					; |
		..reset						; |
		LDA !ApexTimerP2				; |
		AND #$00FF : BNE ..done				; |
		..killapex					; |
		LDA #$FFFF : STA !ApexP2			; |
		..done						;/

		LDA !Characters					;\
		AND #$000F : BEQ +				; | clear input override unless mario
		STZ !P2ExtraInput1				; |
		STZ !P2ExtraInput3				;/
	+	SEP #$20					; A 8-bit


		RTL						; > return





	CharacterList:
		dw Mario			; 0
		dw Luigi			; 1
		dw Kadaal			; 2
		dw Leeway_Redirect		; 3
		dw Alter			; 4
		.End





	Multiplayer:



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
		LDA $741A
		AND #$00FF : BNE +
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






	Leeway_Redirect:
		JSL Leeway
		RTS


	RunMario:
		LDA !MarioAnim				;\
		CMP #$09 : BNE +			; |
		LDA !CurrentMario : BEQ +		; | if mario status = 9 and mario is in play, set PCE kill reg

		REP #$20
		LDA $1C
		CLC : ADC #$0100
		CMP !MarioYPosLo
		SEP #$20
		BCC .Dead

		.Failling
		LDA #$01 : BRA ++
		.Dead
		LDA #$02
	++	STA !P2Status				;/
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
SD_BANK:
	db $7E,$7F,$40,$41
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
	incsrc "CORE/ACCEL_X.asm"
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
	incsrc "CORE/SHOW_HEARTS.asm"
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




