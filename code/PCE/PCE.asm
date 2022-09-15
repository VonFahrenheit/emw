


	print "Main player engine at $", pc, "."
	PCE:
		LDA #$00				;\
		STA.l !VRAMbase+!VRAMsize+$00		; | reset number of bytes uploaded
		STA.l !VRAMbase+!VRAMsize+$01		;/
		LDA !GameMode

		CMP #$12 : BEQ .PreProcess
		CMP #$14 : BEQ ProcessMain
		RTL

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


	ProcessMain:
		SEP #$30					; all regs 8-bit

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
		LDA $6DA2 : STA $15				; |
		LDA $6DA4 : STA $17				; | get joypads
		LDA $6DA6 : STA $16				; |
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
		CMP #$0D : BCC ..done				; | riposte
		LDA !Difficulty : BNE ..done			; |
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
		LDA $6DA3 : STA $15				; |
		LDA $6DA5 : STA $17				; | get joypads
		LDA $6DA7 : STA $16				; |
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
		CMP #$0D : BCC ..done				; | riposte
		LDA !Difficulty : BNE ..done			; |
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
		LDA CharacterList,x : STA $00
		LDA CharacterList+1,x : STA $01
		LDA CharacterList+2,x : STA $02
		JML [$3000]

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
	incsrc "CORE/UPDATE_SPEED.asm"
	incsrc "CORE/PLUMBER_SWIM.asm"
	incsrc "CORE/CARRY.asm"
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
	incsrc "CORE/DOUBLE_JUMP_SMOKE.asm"
	incsrc "CORE/DASH_SMOKE.asm"
	incsrc "CORE/KNOCKED_OUT.asm"
	incsrc "CORE/DISPLAY_CONTACT.asm"
	incsrc "CORE/CHECK_ABOVE.asm"
	incsrc "CORE/RIPOSTE.asm"
	incsrc "CORE/FLASHPAL.asm"
	incsrc "CORE/SHOW_HEARTS.asm"
	namespace off




