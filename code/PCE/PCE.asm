header
sa1rom


<<<<<<< Updated upstream
;=======;
;DEFINES;
;=======;

	incsrc "../Defines.asm"

;=======;
;HIJACKS;
;=======;

; PCE FIX MUST BE PATCHED FIRST!!

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
=======
macro Dyn16Bit(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro

macro Dyn24Bit(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db (<TileNumber>>>3)&$7F
	db <Dest>*4
endmacro

macro Dyn24BitFile2(TileCount, TileNumber, Dest)
	db (<TileCount>*2)|((<TileNumber>&$07)<<5)
	db (<TileNumber>>>3)&$7F|$80
	db <Dest>*4
endmacro




	print "Player character engine at $", pc, "."
	PCE:
>>>>>>> Stashed changes
		LDA #$00				;\
		STA.l !VRAMbase+!VRAMsize+$00		; | reset number of bytes uploaded
		STA.l !VRAMbase+!VRAMsize+$01		;/

<<<<<<< Updated upstream
;	if !TrackCPU == 0
		CMP #$14 : BNE .Return
;	else
;		CMP #$14 : BEQ $03 : JMP .Return
;	endif
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

		LDA #$01 : STA !ProcessingSprites
	;	JML $1081A6			; new constant (how did i come up with this?????)
	; note: the "constant" is just the pointer to the SNES -> SA-1 wrapper for the sprite engine
		RTL				; now called by GameMode14.asm


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

=======
		STZ !P2YDelta-$80
		STZ !P2YDelta

		LDA !GameMode
		CMP #$12 : BEQ .PreProcess
		CMP #$14 : BEQ ProcessMain
		RTL
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
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
	..R	LDA $8A : STA $7D
		RTL

=======
	ProcessMain:
		SEP #$30					; all regs 8-bit

		LDA #$00					;\
		LDY !P2Status-$80				; |
		BNE $01 : INC A					; | which players are active
		LDY !P2Status					; | (it doesn't matter if this lags 1 frame behind)
		BNE $02 : ORA #$02				; |
		STA !Players					;/

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


		REP #$20					;\
		LDA !P2XPosLo-$80 : STA $94			; | update dp coords
		LDA !P2YPosLo-$80 : STA $96			; |
		SEP #$20					;/


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
		LDA !P2Dir : STA !P2Dir-$80			; |
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


		.Inputs						;\
		LDA !P2Entrance : BEQ ..allowinputs		; |
		..entrance					; |
		BMI ..noinputs					; |
		DEC !P2Entrance					; |
		CMP #$20 : BNE ..noinputs			; |
		LDA #$09 : STA !SPC4				; |
		LDA #$1F : STA !ShakeTimer			; | entrance animation (no inputs)
		..noinputs					; |
		STZ $15						; |
		STZ $16						; |
		STZ $17						; |
		STZ $18						; |
		BRA ..done					;/
		..allowinputs					;\
		LDA $6DA2 : STA $15				; | get joypads (NES half)
		LDA $6DA6 : STA $16				;/
		AND #$03					;\
		CMP #$03 : BNE +				; |
		TRB $15 : TRB $16				; |
	+	LDA $15						; | prevent left+right and up+down
		AND #$0C					; |
		CMP #$0C : BNE +				; |
		TRB $15 : TRB $16				;/
	+	LDA $6DA4 : STA $17				;\ get joypads (SNES half)
		LDA $6DA8 : STA $18				;/
		LDA !P2ExtraInput1 : BEQ ..input1done		;\
		STA $15						; |
		STZ !P2ExtraInput1				; |
		..input1done					; |
		LDA !P2ExtraInput2 : BEQ ..input2done		; |
		STA $17						; |
		STZ !P2ExtraInput2				; |
		..input2done					; |
		LDA !P2ExtraInput3 : BEQ ..input3done		; | input override
		STA $16						; |
		STZ !P2ExtraInput3				; |
		..input3done					; |
		LDA !P2ExtraInput4 : BEQ ..input4done		; |
		STA $18						; |
		STZ !P2ExtraInput4				; |
		..input4done					; |
		..done						;/


		.Stasis
		LDA !P2Stasis : BEQ ..done
		STZ $15
		STZ $16
		STZ $17
		STZ $18
		DEC !P2AnimTimer
		..done


		.CriticalMode					;\
		LDA !Difficulty					; |
		AND.b #!CriticalMode : BEQ ..done		; |
		LDA $16						; |
		AND #$20 : BEQ ..done				; |
		LDA !P2HP					; | toggle size with select on critical mode
		CMP #$01 : BEQ ..max				; |
		LDA #$01 : BRA ..w				; |
	..max	LDA !P2MaxHP					; |
	..w	STA !P2HP					; |
		..done						;/



		.RunMain					;\
		LDA !Characters					; |
		LSR #4 : STA $00				; | get player 1 character ID (invalid defaults to mario to avoid crashes)
		ASL A : ADC $00					; |
		CMP.b #CharacterList_End-CharacterList		; |
		BCC $02 : LDA #$00				;/
		TAX						; > X = index
		LDA !PlayerBonusHP : PHA			;\
		LDA !P2TempHP					; |
		CLC : ADC !PlayerBonusHP			; | run code for player 1
		STA !PlayerBonusHP				; |
		JSL RunCharacter				; |
		PLA : STA !PlayerBonusHP			;/

		.Riposte					;\
		LDA !P2HurtTimer				; |
		CMP #$0D : BCC ..done				; |
		LDA !P2Character : BNE ..noflamestar		; |
		LDA !P2FlameStar : BNE ..allow			; | riposte
		..noflamestar					; |
		LDA !Difficulty : BNE ..done			; |
		..allow						; |
		JSL CORE_RIPOSTE				; |
		..done						;/

		.ResetHitbox
		REP #$20					;\
		LDA !P2Hitbox1W : BNE ..box2			; |
		STZ !P2Hitbox1IndexMem1				; |
		..box2						; | clear hitbox index mem in empty hitboxes
		LDA !P2Hitbox2W : BNE ..done			; |
		STZ !P2Hitbox2IndexMem1				; |
		..done						; |
		SEP #$20					;/

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
		LDA !MultiPlayer : BNE ..runp2			; | return with p2 dead if no multiplayer
		LDA #$02 : STA !P2Status			; |
		BRA ..return					;/
		..runp2						;\
		LDA !P2Status					; |
		CMP #$02 : BNE ..done				; |
		..dead						; |
		LDA #$02 : TSB !PlayerWaiting			; > if dead, set wait flag
		..return					; | just skip processing if player 2 is dead
		REP #$20					; |
		LDA !P2XPosLo-$80 : STA !P2XPosLo		; |
		LDA !P2YPosLo-$80 : STA !P2YPosLo		; |
		SEP #$20					; |
		LDA !P2Dir-$80 : STA !P2Dir			; |
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
		STZ $15						; |
		STZ $16						; |
		STZ $17						; |
		STZ $18						; |
		BRA ..done					;/
		..allowinputs					;\
		LDA $6DA3 : STA $15				; | get joypads (NES half)
		LDA $6DA7 : STA $16				;/
		AND #$03					;\
		CMP #$03 : BNE +				; |
		TRB $15 : TRB $16				; |
	+	LDA $15						; | prevent left+right and up+down
		AND #$0C					; |
		CMP #$0C : BNE +				; |
		TRB $15 : TRB $16				;/
	+	LDA $6DA5 : STA $17				;\ get joypads (SNES half)
		LDA $6DA9 : STA $18				;/
		LDA !P2ExtraInput1 : BEQ ..input1done		;\
		STA $15						; |
		STZ !P2ExtraInput1				; |
		..input1done					; |
		LDA !P2ExtraInput2 : BEQ ..input2done		; |
		STA $17						; |
		STZ !P2ExtraInput2				; |
		..input2done					; |
		LDA !P2ExtraInput3 : BEQ ..input3done		; | input override
		STA $16						; |
		STZ !P2ExtraInput3				; |
		..input3done					; |
		LDA !P2ExtraInput4 : BEQ ..input4done		; |
		STA $18						; |
		STZ !P2ExtraInput4				; |
		..input4done					; |
		..done						;/


		.Stasis
		LDA !P2Stasis : BEQ ..done
		STZ $15
		STZ $16
		STZ $17
		STZ $18
		DEC !P2AnimTimer
		..done


		.CriticalMode					;\
		LDA !Difficulty					; |
		AND.b #!CriticalMode : BEQ ..done		; |
		LDA $16						; |
		AND #$20 : BEQ ..done				; |
		LDA !P2HP					; | toggle size with select on critical mode
		CMP #$01 : BEQ ..max				; |
		LDA #$01 : BRA ..w				; |
	..max	LDA !P2MaxHP					; |
	..w	STA !P2HP					; |
		..done						;/



		.RunMain					;\
		LDA !Characters					; |
		AND #$0F : STA $00				; | get player 2 character ID (invalid defaults to mario to avoid crashes)
		ASL A : ADC $00					; |
		CMP.b #CharacterList_End-CharacterList		; |
		BCC $02 : LDA #$00				;/
		TAX						; > X = index
		LDA !PlayerBonusHP : PHA			;\
		LDA !P2TempHP					; |
		CLC : ADC !PlayerBonusHP			; | run code for player 2
		STA !PlayerBonusHP				; |
		JSL RunCharacter				; |
		PLA : STA !PlayerBonusHP			;/

		.Riposte					;\
		LDA !P2HurtTimer				; |
		CMP #$0D : BCC ..done				; |
		LDA !P2Character : BNE ..noflamestar		; |
		LDA !P2FlameStar : BNE ..allow			; | riposte
		..noflamestar					; |
		LDA !Difficulty : BNE ..done			; |
		..allow						; |
		JSL CORE_RIPOSTE				; |
		..done						;/


		.ResetHitbox
		REP #$20					;\
		LDA !P2Hitbox1W : BNE ..box2			; |
		STZ !P2Hitbox1IndexMem1				; |
		..box2						; | clear hitbox index mem in empty hitboxes
		LDA !P2Hitbox2W : BNE ..done			; |
		STZ !P2Hitbox2IndexMem1				; |
		..done						; |
		SEP #$20					;/

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




	RunCharacter:
		LDA $00 : STA !P2Character			; character number
		LDA #$08					;\
		CLC : ADC !PlayerBonusHP			; | max HP
		STA !P2MaxHP					;/
		CMP !P2HP					;\ enforce max HP
		BCS $03 : STA !P2HP				;/
		LDA CharacterList,x : STA $00			;\
		LDA CharacterList+1,x : STA $01			; | execute pointer
		LDA CharacterList+2,x : STA $02			; |
		JML [$3000]					;/

	CharacterList:
		dl Mario			; 0
		dl Luigi			; 1
		dl Kadaal			; 2
		dl Leeway			; 3
		dl Alter			; 4
		dl Peach			; 5
		.End




	Leeway_Redirect:
		JSL Leeway
		RTS
>>>>>>> Stashed changes


		.GetCharacter
		SEP #$30				;\
		STZ !MarioMaskBits			; |
		LDA #$00 : PHA : PLB			; |
		LDA $73CB				; | run the mario code at $00C47E
		PHK : PEA .MarioReturn-1		; |
		PEA $84CF-1				; |
		JML $00C483				; |
		.MarioReturn				;/

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
		TDC : STA $3000				;\ Backup DP
		XBA : STA $3001				;/
		LDA #$6D : XBA				;\ DP = $6DA0
		LDA #$A0 : TCD				;/
		LDA $03 : PHA				;\
		LDA $05 : PHA				; |
		LDA $07 : PHA				; |
		LDA $09 : PHA				; | Copy P1 input to P2
		LDA $02 : STA $03			; |
		LDA $04 : STA $05			; |
		LDA $06 : STA $07			; |
		LDA $08 : STA $09			;/
		LDA $3001 : XBA				;\ Restore DP
		LDA $3000 : TCD				;/
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
		JSR Stasis
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
		JSR Stasis
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
		dw Mario			; 0
		dw Luigi			; 1
		dw Kadaal			; 2
		dw Leeway			; 3
		dw Alter			; 4
		..End


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
	incsrc "CORE/SET_GLITTER.asm"
<<<<<<< Updated upstream
	incsrc "CORE/PLAYER_CLIPPING.asm"
	incsrc "CORE/PLATFORM.asm"
=======
	incsrc "CORE/SET_SPLASH.asm"
	incsrc "CORE/SMOKE_AT_FEET.asm"
	incsrc "CORE/SMOKE_AT_WALL.asm"
	incsrc "CORE/SET_SMOKE.asm"
	incsrc "CORE/DASH_SMOKE.asm"
>>>>>>> Stashed changes
	incsrc "CORE/KNOCKED_OUT.asm"
	incsrc "CORE/DISPLAY_CONTACT.asm"
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
	print "Kadaal code inserted at $", pc, " ($", hex(Leeway-Kadaal), " bytes)"
	incsrc "characters/Kadaal.asm"
	Leeway:
	print " "
	print "Leeway code inserted at $", pc, " ($", hex(Alter-Leeway), " bytes)"
	incsrc "characters/Leeway.asm"
	Alter:
	print " "
	print "Alter code inserted at $", pc, " ($", hex(End-Alter), " bytes)"
	incsrc "characters/Alter.asm"


End:
print " "
print "$", hex(End-PLAYER2+8), " bytes used by this patch."
print "$", hex($160000-End), " bytes left in bank."
print " "