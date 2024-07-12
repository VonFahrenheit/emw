



level0:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
	if !Debug = 0
	LDA #$04 : STA !LevelWidth
	endif

		LDA !StoryFlags+$00 : BMI ++		; home base music if cannon has been used
		CMP #$03 : BEQ +			;\
	++	LDA #$30 : STA !SPC3			; | keep music if warp pipe has been obtained but cannon has not been used
		+					;/

		LDA #$06 : STA !PalsetStart

		REP #$20
		LDA.w #!MSG_MarioSwitch : STA !NPC_Talk+(0*2)
		LDA.w #!MSG_LuigiSwitch : STA !NPC_Talk+(1*2)
		LDA.w #!MSG_KadaalSwitch : STA !NPC_Talk+(2*2)
		LDA.w #!MSG_LeewaySwitch : STA !NPC_Talk+(3*2)
		LDA.w #!MSG_AlterSwitch : STA !NPC_Talk+(4*2)
		LDA.w #!MSG_PeachSwitch : STA !NPC_Talk+(5*2)
		LDA.w #!MSG_ToadTemp : STA !NPC_Talk+($10*2)
		SEP #$20


		.Cannon
		LDA !StoryFlags+$00
		CMP #$03 : BCS ..done
		LDX #$01
		..loop
		LDA #$25
		STA $40C800+($1B0*2)+$123,x
		STA $40C800+($1B0*2)+$133,x
		LDA #$00
		STA $41C800+($1B0*2)+$123,x
		STA $41C800+($1B0*2)+$133,x
		DEX : BPL ..loop
		..done

		.Pipe
		LDA !StoryFlags+$00 : BMI ..done
		LDX #$01
		..loop
		LDA #$25
		STA $40C800+$167,x
		STA $40C800+$177,x
		LDA #$00
		STA $41C800+$167,x
		STA $41C800+$177,x
		DEX : BPL ..loop
		..done



		.Cutscene
		LDA $1B : BNE ..done
		LDA !StoryFlags+0 : BMI ..done
		REP #$20
		STZ $00
		LDA #$0170 : STA $02
		LDA.w #!MSG_LuigiSwitchFirstTime : STA !NPC_Talk+(1*2)
		LDA.w #!MSG_LuigiSwitch : STA !NPC_TalkCap+(1*2)
		LDA.w #!MSG_KadaalTalk_IntroLevel : STA !NPC_Talk+(2*2)
		SEP #$20
		LDA #$0E : JSL SpawnSprite_Custom
		LDA #$02 : STA !ExtraProp1,x
		LDA #$14 : STA !SpriteXSpeed,x
		LDA #$02 : STA !Cutscene
		STZ !CutsceneIndex
		..done

		.UnlockLuigi				;\
		LDA !LuigiStatus : BNE ..done		; | unlock luigi
		LDA #$01 : STA !LuigiStatus		; |
		..done					;/

		LDA #$33 : STA !NPC_Talk+$10
		RTL



	.Main

	if !Debug = 1
	LDA $95
	CMP #$04 : BEQ +
	CMP #$05 : BEQ ++
	STZ !Translevel
	BRA +++
	+
	LDA #$03 : STA !Translevel
	BRA +++
	++
	LDA #$05 : STA !Translevel
	+++
	endif


		.MsgPal
		STZ !BorderPal
		LDA $1B
		CMP #$02 : BCC ..A1
	..B1	LDA #$B1 : BRA ..w
	..A1	LDA #$A1
	..w	STA !MsgPal


		LDA !P2SlantPipe-$80 : BEQ +	;\
		LDA #$03 : STA !StoryFlags+$00	; | set cannon overworld cutscene when leaving with cannon
		REP #$20			; |
		LDA #$0080 : JSL END_Up		;/
		+

		LDA #$20
		TRB !P2Pipe-$80
		TRB !P2Pipe
		LDA !P2Pipe-$80
		ORA !P2Pipe
		CMP #$C0 : BCC +
		REP #$20
		LDA #$0170 : JSL END_Down
		+


		LDA !MsgMode : BEQ +		;\
		LDA #$02 : STA !LuigiStatus	; | luigi status -> 2
		+				;/


		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$0E : BNE +
		LDA !ExtraProp1,x
		CMP #$02 : BNE +
		LDA !SpriteXSpeed,x : BEQ +
		LDA !SpriteXHi,x
		CMP #$01 : BCC +
		LDA !SpriteXLo,x
		CMP #$80 : BCC +
		STZ !SpriteXSpeed,x
		STZ !SpriteAnimIndex,x
		LDA #$01 : STA !ExtraProp2,x
	+	DEX : BPL -




		STZ $00
		STZ $01
		JSL DisplayYC

		JSL DisplayHitbox1_Main
		JSL DisplayHitbox2_Main

	;JSL TriangleProjection

		RTL


	DisplayYC:
		PHB : PHK : PLB

		LDA !StoryFlags+$00 : BMI .Process	; only draw if intro level has been cleared
		JMP .Return

		.Process
		REP #$20
		STZ $00
		LDA.w #.CoinIcon : STA $02
		SEP #$20
		STZ $0D
		LDA #$08 : STA $0E
		JSL DrawSpriteHUD
		REP #$30
		LDA !OAMindex_p3
		LSR #2
		TAX
		LDA #$0000
		STA !OAMhi_p3+$00,x
		STA !OAMhi_p3+$01,x
		LDA !OAMindex_p3 : TAX
		LDA #$0814 : STA $00
		LDA !YoshiCoinCount
		CMP.w #999
		BCC $03 : LDA.w #999

		LDY #$0000
	-	CMP #$0064 : BCC ..draw100s
		SBC #$0064
		INY : BRA -
		..draw100s
		CPY #$0000 : BEQ +
		STA $02
		TYA
		ORA #$3F80 : STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		CLC : ADC #$0008
		STA $00
		INX #4
		LDA $02
		+

		LDY #$0000
	-	CMP #$000A : BCC ..draw10s
		SBC #$000A
		INY : BRA -
		..draw10s
		CPY #$0000 : BEQ +
		STA $02
		TYA
		ORA #$3F80 : STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		CLC : ADC #$0008
		STA $00
		INX #4
		LDA $02
		+

		ORA #$3F80 : STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		INX #4
		TXA : STA !OAMindex_p3
		SEP #$30

		.Return
		PLB
		RTL

		.CoinIcon
		db $08,$08,$8E,$3F
		db $08,$10,$8F,$3F




	!RollWidth	= $6DF5


level25:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		STZ $43
		REP #$20
		LDA #$7000 : STA.l $400000+!MsgVRAM1
		LDA #$7080 : STA.l $400000+!MsgVRAM2
		LDA #$7200 : STA.l $400000+!MsgVRAM3
		SEP #$20
		RTL

	.Main
		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | elevator exit
		dw $97B1				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0090 : db $10,$40	; | command bridge exit
		dw $05F1				; |
		BCC $01 : RTL				;/

		RTL



levelC5:
	dw .Init
	dw $0000
	dw $0000
	dw $0000

	.Init
		LDA #$01 : STA !LevelWidth	; prevent camera scroll
		RTL				; return



;
; !Level+2	timer for jump tooltip
; !Level+3	timer for run tooltip
; !Level+4	timer for attack tooltip and senku jump tooltip
; !Level+5	bit check for kadaal's lessons:
;		0 - run right
;		1 - run left
;		2 - attack 1
;		3 - attack 2
;		4 - senku
;		5 - senku jump
;
; $0A20		BG3 Y offset
; $0A22		color counter for kadaal's animation
levelC6:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		INC $14 : JSL levelC6_HDMA
		DEC $14 : JSL levelC6_HDMA

		LDA.b #999>>8 : STA !TimerSeconds+1

		LDA !Characters
		CMP #$10 : BCC +
		LDA #$20 : STA $0A22
		LDA #$4A : BRA ++
	+	LDA #$80
	++	STA !SPC3

		LDA #$06 : STA !PalsetStart

		LDA $95 : BNE +
		LDA #$FF : STA $97
		+

		LDA #$01 : STA !KadaalStatus			; unlock kadaal

		STZ !P2Status-$80
		STZ !P2Status

		STZ $24
		STZ $25

		RTL

	.Main
		LDA !TranslevelFlags+$00 : BMI +
		LDA !P2InAir-$80 : BNE +
		LDA !P2Character-$80 : BNE +
		DEC !TranslevelFlags+$00
		REP #$20
		LDA.w #!MSG_UnexploredHill_Mario : STA !MsgTrigger
		SEP #$20
		+

		LDA $95 : BNE +
		LDA !P2Entrance-$80 : BEQ +
		LDA !P2HP-$80
		STA !StatusBarP1Hearts
		STA !P2ShowHP-$80
		LDA !P2HP
		STA !StatusBarP2Hearts
		STA !P2ShowHP
		STZ !P2Entrance-$80
		STZ !P2Entrance
		+

		LDA $1B
		CMP #$0D : BNE +
		LDA #$0E : JSL SearchSprite_Custom
		BMI +
		LDA !ExtraProp2,x
		CMP #$07 : BNE +
		LDA !SpriteXHi,x
		CMP #$0E : BNE +
		LDA !SpriteXLo,x
		CMP #$90 : BCC +
		STZ !ExtraProp2,x
		LDA #$08 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		LDA #$01 : STA $400000+!MsgTalk
		+

		.MeetKadaal
		LDA !P2Character-$80				;\
		CMP #$02 : BNE ..meet				; |
		JMP ..done					; |
		..meet						; |
		LDA !Level+4 : BNE ..done			; |
		LDA $1B						; | if mario is at these camera coords
		CMP #$0D : BCC ..done				; |
		LDA $1A						; |
		CMP #$E0 : BCC ..done				;/

		LDA #$0E : JSL SearchSprite_Custom		;\
		BMI ..done					; | kadaal faces mario
		LDA #$01 : STA !SpriteDir,x			;/

		LDA #$02 : STA !P2Stasis-$80			; freeze mario
		LDA #$01 : STA !Cutscene

		LDA $400000+!MsgTalk
		CMP #$02 : BCS ..checkforpose
		LDA #$02 : STA $400000+!MsgTalk
		BRA ..done

		..checkforpose
		CMP #$04 : BEQ ..checkforfinale
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..done
		LDA #$04 : STA $400000+!MsgTalk
		LDA #$20 : STA !SpriteDisSprite,x
		BRA ..done

		..checkforfinale
		LDA $0A22
		CMP #$40 : BNE ..done
		LDA #$3E : STA !ExtraProp2,x			; switch to kadaal
		STZ !StatusBarP1Hearts
		REP #$20					;\
		LDA.w #!MSG_MeetKadaal_1 : STA !MsgTrigger	; | text box
		SEP #$20					;/
		LDA #$01 : STA !Level+4				; flag
		LDA !Level+1					;\
		BEQ $02 : LDA #$20				; |
		ORA #$40					; | checkpoint baybee
		STA !LevelTable1+$00				; |
		LDA !Level : STA !LevelTable2+$00		;/
		..done


	; end level
		REP #$20					;\ end level at coordinate 0x1FF0
		LDA #$1FE8 : JSL EXIT_Right			;/
		BCC .NotEnded					;\
		STZ $6109					; |
		LDA #$00 : STA !Characters			; > swap character to mario
		STZ !P2Character-$80				; |
		.NotEnded					;/

	; set HDMA
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

	; colors
		.HandleColors
		REP #$20
		LDA #$7BDE : STA !PaletteCacheRGB+0
		LDA #$7FFF
		STA !PaletteCacheRGB+($1D*2)
		STA !PaletteCacheRGB+($1E*2)
		STA !PaletteCacheRGB+($1F*2)

		LDA $0A22 : BNE ..kadaal
		LDA $400000+!MsgTalk
		AND #$00FF
		CMP #$0004 : BNE ..mario

		..kadaal
		LDA $14
		LSR A : BCC +
		LDA $0A22
		CMP #$0040
		BEQ $03 : INC $0A22
		+
		LDX #$00
		LDY #$01
		LDA $0A22
		CMP #$001F
		BCC $03 : LDA #$001F
		PHA
		JSL MixRGB
		PLA : BRA ..finish

		..mario
		LDA $1A
		CMP #$07FF
		BCC $03 : LDA #$07FF
		EOR #$07FF
		LSR #6
		LDX #$00
		LDY #$01
		JSL MixRGB
		LDA $1A
		SEC : SBC #$0700
		BPL $03 : LDA #$0000
		CMP #$07FF
		BCC $03 : LDA #$07FF
		EOR #$07FF
		LSR #6

		..finish
		LDX #$1D
		LDY #$03
		JSL MixRGB
		LDA !PaletteBuffer+0 : STA !2132_RGB
		SEP #$20
		..done



	; -- TUTOTIRAL GUI CHECK --


	; character check
		LDA !P2Character-$80
		CMP #$02 : BEQ .Kadaal
		JMP .Mario
		.Kadaal

	; attack 1 check
		.Attack1
		LDA !Level+5
		AND #$04 : BNE ..done
		REP #$20
		LDA !P2XPos-$80
		CMP #$0F80 : BCC ..done
		CMP #$1200 : BCS ..done
		SEP #$20
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$02 : BEQ ..mark
		DEX : BPL ..loop
		LDY #$08 : JMP .LoadTilemap
		..mark
		LDA #$04 : TSB !Level+5
		..done
		SEP #$20

	; attack 2 check
		.Attack2
		LDA !Level+5
		AND #$08 : BNE ..done
		LDA !P2XPosHi-$80
		CMP #$12 : BEQ ..searchblock
		STZ !Level+4
		JMP .TapRun
		..searchblock
		LDX.b #!Ex_Amount-1
		..loop
		LDA !Ex_Num,x
		CMP #!BlockHitbox_Num|$80 : BEQ ..mark
		DEX : BPL ..loop
		BRA ..count
		..mark
		LDA #$08 : TSB !Level+5
		..count
		LDA !Level+4
		CMP #$FF : BEQ ..draw
		INC !Level+4
		JMP .TapRun
		..draw
		LDY #$08 : JMP .LoadTilemap
		..done

	; slide check
		.Slide
		LDA !P2XPosHi-$80
		CMP #$15 : BNE ..done
		LDY #$03 : JMP .LoadTilemap
		..done

	; senku check
		.Senku
		LDA !Level+5
		AND #$10 : BNE ..done
		LDA !P2XPosHi-$80
		CMP #$1A : BNE ..done
		BIT !P2XPosLo-$80 : BPL ..draw
		LDA #$10 : TSB !Level+5
		..draw
		LDY #$09 : JMP .LoadTilemap
		..done

	; senku jump check
		.SenkuJump
		LDA !Level+5
		AND #$20 : BNE ..done
		LDA !P2XPosHi-$80
		CMP #$1B : BEQ ..validscreen
		CMP #$1C : BEQ ..validscreen
		..reset
		STZ !Level+4
		BRA ..done
		..validscreen
		LDA !P2YPosHi-$80 : BNE ..count
		LDA !P2YPosLo-$80
		CMP #$D0 : BCS ..count
		LDA !P2InAir-$80 : BNE ..count
		..mark
		LDA #$20 : TSB !Level+5
		..count
		LDA !Level+4
		CMP #$FF : BEQ ..draw
		INC !Level+4
		BRA ..done
		..draw
		LDY #$0A : JMP .LoadTilemap
		..done

	; tap run check
		.TapRun
		LDA $0A22
		CMP #$40 : BNE ..done
		LDA !CutsceneSmoothness : BNE ..done
		LDA !P2Dashing-$80 : BEQ ..animate
		..mark
		LDA !P2Direction-$80
		EOR #$01
		INC A
		TSB !Level+5
		..animate
		LDA $14
		AND #$10
		BEQ $02 : LDA #$01
		ORA #$04
		TAY
		LDA !Level+5
		AND #$03 : BEQ ..draw
		CMP #$02 : BEQ ..draw
		CMP #$03 : BEQ ..done
		LDX !P2XPosHi-$80
		CPX #$11 : BCS ..done
		INY #2
		..draw
		JMP .LoadTilemap
		..done


	; jump check
		.Mario
		LDA $1B
		CMP #$02 : BEQ .TextRun
		CMP #$03 : BEQ .TextRun
		CMP #$01 : BNE .NoJump
		LDA $95
		CMP #$02 : BCS .NoJump
		LDA $94
		CMP #$F5 : BCS .NoJump
		LDA !Level+2
		CMP #$FF : BNE .CountJump
		LDY #$00 : BRA .LoadTilemap
		.CountJump
		INC A
		STA !Level+2
		BRA .CheckFire
		.NoJump
		STZ !Level+2

	; fire check
		.CheckFire
		LDA !P2Character-$80 : BNE .Return
		LDA !P2FireCharge-$80 : BEQ .Return
		LDA !CutsceneSmoothness : BNE .Return
		LDY #$02 : BRA .LoadTilemap

	; run check
		.TextRun
		LDA $95
		CMP #$02 : BNE +
		LDA $94
		CMP #$90 : BCC .NoRun
	+	CMP #$04 : BCS .NoRun
		LDA $94
		CMP #$F5 : BCS .NoRun
		LDA !Level+3
		CMP #$FF : BEQ .DisplayRunText
		.CountRun
		INC A
		STA !Level+3
		BRA .Return
		.NoRun
		STZ !Level+3
		BRA .Return
		.DisplayRunText
		LDY #$01



	; $00 - Xpos
	; $01 - Ypos
	; $02 - pointer
	; $0D - tile size
	; $0E - byte count
		.LoadTilemap
		LDA .TilemapSize,y : STA $0E
		TYA
		ASL A
		TAY
		LDA #$02 : STA $0D
		REP #$20
		STZ $00
		LDA .TilemapPtr,y : STA $02
		JSL DrawSpriteHUD
		SEP #$20

		.Return
		RTL


		.TilemapPtr
		dw .JumpTM		; 00
		dw .RunTM		; 01
		dw .FireTM		; 02
		dw .SlideTM		; 03
		dw .TapRun1TM		; 04
		dw .TapRun2TM		; 05
		dw .TapRun3TM		; 06
		dw .TapRun4TM		; 07
		dw .AttackTM		; 08
		dw .SenkuTM		; 09
		dw .SenkuJumpTM		; 0A


		.TilemapSize
		db .JumpTM_end-.JumpTM
		db .RunTM_end-.RunTM
		db .FireTM_end-.FireTM
		db .SlideTM_end-.SlideTM
		db .TapRun1TM_end-.TapRun1TM
		db .TapRun2TM_end-.TapRun2TM
		db .TapRun3TM_end-.TapRun3TM
		db .TapRun4TM_end-.TapRun4TM
		db .AttackTM_end-.AttackTM
		db .SenkuTM_end-.SenkuTM
		db .SenkuJumpTM_end-.SenkuJumpTM

; -- inputs --
; A		0x80 (16x16)
; B		0x82 (16x16)
; X		0xA0 (16x16)
; Y		0xA2 (16x16)
; L		0xC0 (32x16)
; R		0xE0 (32x16)
; Start		0x84 (24x16)
; Select	0xA4 (24x16)
; D-pad		0xC4 (32x32)
; D-pad R	0xC8 (16x16)
; D-pad L	0xCA (16x16)
; D-pad D	0xE8 (16x16)
; D-pad U	0xEA (16x16)

; -- text --
; JUMP		0x87 (32x16)
; RUN		0x8B (24x16)
; FIRE		0xA7 (32x16)
; PUNCH		0xAB (40x16)
; DASH		0xCC (32x16)
; SLASH		0xEC (32x16)


		.JumpTM
		db $65,$C2,$87,$3F		; jump
		db $75,$C2,$89,$3F
		db $8B,$C0,$82,$3F		; B
		..end

		.RunTM
		db $65,$C2,$AC,$3F		; run
		db $6D,$C2,$AD,$3F
		db $83,$C0,$A2,$3F		; Y
		..end

		.FireTM
		db $65,$C2,$EC,$3F		; fire
		db $75,$C2,$EE,$3F
		db $85,$C0,$E0,$3F		; R
		db $95,$C0,$E2,$3F
		..end

		.SlideTM
		db $60,$C2,$CC,$3F		; slide
		db $70,$C2,$CE,$3F
		db $8C,$C8,$E8,$3F		; dpad
		db $84,$B8,$C4,$3F
		db $94,$B8,$C6,$3F
		db $84,$C8,$E4,$3F
		db $94,$C8,$E6,$3F
		..end

		.TapRun1TM
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $88,$C0,$C8,$3F		; dpad 1
		db $78,$B8,$C4,$3F
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		db $9C,$C0,$C8,$3F		; dpad 2
		db $8C,$B8,$C4,$3F
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		..end
		.TapRun2TM
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $78,$B8,$C4,$3F		; dpad 1
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		db $8C,$B8,$C4,$3F		; dpad 2
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		..end
		.TapRun3TM
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $8C,$C0,$CA,$3F		; dpad 1
		db $8C,$B8,$C4,$3F
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		db $78,$C0,$CA,$3F		; dpad 2
		db $78,$B8,$C4,$3F
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		..end
		.TapRun4TM
		db $5D,$C2,$AC,$3F		; run
		db $65,$C2,$AD,$3F
		db $8C,$B8,$C4,$3F		; dpad 1
		db $9C,$B8,$C6,$3F
		db $8C,$C8,$E4,$3F
		db $9C,$C8,$E6,$3F
		db $78,$B8,$C4,$3F		; dpad 2
		db $88,$B8,$C6,$3F
		db $78,$C8,$E4,$3F
		db $88,$C8,$E6,$3F
		..end

		.AttackTM
		db $5D,$C2,$A7,$3F		; attack
		db $6D,$C2,$A9,$3F
		db $75,$C2,$AA,$3F
		db $8B,$C0,$A2,$3F		; Y
		..end

		.SenkuTM
		db $61,$C2,$8B,$3F		; senku
		db $71,$C2,$8D,$3F
		db $79,$C2,$8E,$3F
		db $91,$C0,$80,$3F		; A
		..end

		.SenkuJumpTM
		db $4C,$C2,$8B,$3F		; senku
		db $5C,$C2,$8D,$3F
		db $64,$C2,$8E,$3F
		db $74,$C0,$80,$3F		; A
		db $88,$C2,$87,$3F		; jump
		db $98,$C2,$89,$3F
		db $AE,$C0,$82,$3F		; B
		..end




		.HDMA
		PHP
		SEP #$10
		REP #$20

		BIT !LevelEntry : BVS +			; ignore this part if the player spawned from the checkpoint
		LDA $1A					;\
		CMP #$0C80 : BCC +			; |
		CMP #$0F80 : BCS +			; |
		SEC : SBC #$0EC0			; |
		BPL $03 : LDA #$0000			; |
		LSR A					; |
		CLC : ADC #$0060			; |
		CMP $1C : BCS +				; | camera slant where you meet kadaal
		STA $1C					; | so the text box appears at a good height
		STA !CameraBackupY			; |
		+					; |
		LDA $1C					; |
		LSR A					; |
		CLC : ADC !BG2BaseV			; |
		STA $20					;/


	;	LDX #$1F : STX !MainScreen
	;	LDX #$02 : STX !SubScreen
	;	LDX #$20 : STX !2131

		LDA !MsgTrigger : BNE ..fail		; don't run during text box
		LDA $1A : STA $22			; BG3 X
		LDA $0A22 : BEQ ..slow
		..fast					;\
		LDA $0A22				; |
		LSR A					; | quickly raise BG3 for kadaal
		ADC $0A20				; |
		STA $0A20				; |
		BRA ..shared				;/
		..slow					;\
		LDA $14					; | slowly raise BG3 for mario
		AND #$0007				; |
		BNE $03 : INC $0A20			;/
		..shared				;\
		LDA $0A20				; | BG3 Y
		CLC : ADC $1C				; |
		STA $24					;/
		LDX #$13 : STX !SubScreen
		LDX #$04 : STX !MainScreen
		LDX #$02 : STX !2130
		LDX #$24 : STX !2131
		..fail


		PLP
		RTL




; elevator room
level13B:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		.BlockExit
		LDA !LevelTable1+$5E : BMI ..done
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..thisone
		DEX : BPL ..loop
		BRA ..done
		..thisone
		LDA #$80 : STA !SpriteXLo,x
		LDA #$00 : STA !SpriteXHi,x
		LDA #$60 : STA !SpriteYLo,x
		LDA #$03 : STA !SpriteYHi,x
		LDA #$0F : STA !SpriteNum,x
		LDA #$0C : STA !ExtraBits,x
		LDA #$36 : STA !SpriteNum,x
		LDA #$01 : STA !SpriteStatus,x
		JSL !ResetSprite
		..done

		REP #$20
		LDA.w #!MSG_Toad_Guard2 : STA !NPC_Talk+($10*2)
		SEP #$20

		RTL

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0050 : db $10,$40	; | deck exit (right)
		dw $05F9				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$00F0 : db $10,$40	; | engine room exit
		dw $0425				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$00F0 : db $10,$40	; | deck exit (left)
		dw $0DF9				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0270 : db $10,$40	; | training room exit
		dw $05F4				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$02F0 : db $10,$40	; | corridor exit
		dw $05F5				; |
		BCC $01 : RTL				;/

		REP #$20
		LDA #$0380 : JSL END_Down
		RTL



	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		;
		.BoxTable
		.Box0	%CameraBox(0, 0, 0, 3)

		.ScreenMatrix
		db $00
		db $00
		db $00
		db $00
		db $00



; the secondary exit format actually makes no sense
; fusoya what were you even thinking??
;
; so, the lo byte is exactly what you'd expect, it's the lo byte of the secondary exit number
; hi byte has this format:
;	Hhhhwlsh
;	w - water level flag (if secondary exit = 0, this is the midway entrance flag)
;	l - lunar magic flag (always set)
;	s - secondary exit flag (always set)
;	H - highest bit of secondary exit
;	hhhh - third nybble of secondary exit
;
; this means that the third nybble is split between bit 0 and bits 4-6 in the hi byte, instead of just being the hi or lo nybble like you'd expect
;
; to translate from secondary exit/entrance number:
;	lo byte -> lo byte
;	third nybble -> lowest bit to lowest bit of hi byte
;			-> rest in bits 4-6 of hi byte
;	highest bit -> highest bit of hi byte
;	then set 0x06 bits in hi byte to enable lunar magic secondary exit


; command bridge
level1F1:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA #$30 : STA !SPC3
		LDA #$06 : STA !PalsetStart

		REP #$20
		LDA #$7000 : STA $400000+!MsgVRAM1
		LDA #$7200 : STA $400000+!MsgVRAM2
		LDA #$7400 : STA $400000+!MsgVRAM3
		SEP #$20

		REP #$20
		LDA.w #!MSG_Toad_IntroLevel_1 : STA !NPC_Talk+($10*2)
		SEP #$20

		RTL


	.Main
		LDA $400000+!MsgTalk : BEQ +
		LDA #$01 : STA !StoryFlags+$00
		+


		.Explosions
		REP #$20
		LDA !MsgTrigger
		CMP.w #!MSG_Toad_IntroLevel_2
		SEP #$20
		BNE ..done
		..shake
		LDA #$10 : TSB !ShakeBG1
		..sfx
		LDA $14
		AND #$07 : BNE ..sprites
		LDA #$18 : STA !SPC4
		..sprites
		LDA $14
		AND #$03 : BNE ..done
		%Ex_Index_X_fast()
		LDA #!Explosion_Num : STA !Ex_Num,x
		LDA !RNG
		AND #$F0
		CLC : ADC $1A
		STA !Ex_XLo,x
		LDA $1B
		ADC #$00
		STA !Ex_XHi,x
		LDA !RNG
		ASL #4
		CMP #$E0
		BCC $02 : AND #$80
		CLC : ADC $1C
		STA !Ex_YLo,x
		LDA $1D
		ADC #$00
		STA !Ex_YHi,x
		STZ !Ex_Data1,x
		..done



		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | engine room exit
		dw $0C25				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $08 : dw $0060,$0000 : db $40,$10	; | deck exit
		dw $F790				; |
		BCC $01 : RTL				;/



		RTL


	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		;
		.BoxTable
		.Box0	%CameraBox(0, 0, 1, 0)

		.ScreenMatrix
		db $00,$00,$00


; empty room
level1F2:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		RTL


; empty room
level1F3:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		RTL


; training room
level1F4:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		REP #$20
		LDA.w #!MSG_Toad_Training_1 : STA !NPC_Talk+($10*2)
		SEP #$20
		RTL

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0170 : db $10,$40	; | elevator exit
		dw $97B3				; |
		BCC $01 : RTL				;/

		RTL

; corridor
level1F5:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $02 : dw $0000,$0090 : db $10,$40	; | coin hoard exit
		dw $05F8				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $01 : dw $02F0,$0090 : db $10,$40	; | elevator exit
		dw $97B4				; |
		BCC $01 : RTL				;/

		RTL


; empty room
level1F6:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/
		RTL


; living rooms
level1F7:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA #$FF : STA !TimerSeconds+1

		LDA !LevelTable1+$00 : BMI .NotIntro
		REP #$20
		LDA.w #!MSG_Toad_Wakeup
		STA !NPC_Talk+($10*2)
		STA !NPC_TalkCap+($10*2)
		SEP #$20


	; spawn wakeup toad on intro mode
		LDA #$0E : STA !SpriteNum
		LDA #$10 : STA !ExtraProp1
		LDA #$01 : STA !ExtraProp2
		LDA #$30 : STA !SpriteXLo
		STZ !SpriteXHi
		LDA #$B0 : STA !SpriteYLo
		STZ !SpriteYHi
		LDA #$01 : STA !SpriteStatus
		LDA #$08 : STA !ExtraBits
		LDX #$00
		JSL !ResetSprite


		.NotIntro

		RTL


	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		RTL




	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		;
		.BoxTable
		.Box0	%CameraBox(0, 0, 0, 0)
		.Box1	%CameraBox(1, 0, 0, 0)
		.Box2	%CameraBox(2, 0, 0, 0)
		.Box3	%CameraBox(3, 0, 0, 0)

		.ScreenMatrix
		db $00,$01,$02,$03



; coin hoard
level1F8:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $00F0,$0090 : db $10,$40	; | corridor exit
		dw $0DF5				; |
		BCC $01 : RTL				;/

		RTL


; airship deck
level1F9:
	dw $0000
	dw .Main
	dw $0000
	dw $0000

	.Main
		STZ $00					;\
		STZ $01					; | YC count
		JSL DisplayYC				;/

		JSL WARP_BOX				;\
		db $01 : dw $0410,$0140 : db $10,$40	; | elevator exit (right)
		dw $97B2				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $02 : dw $04E0,$00A0 : db $10,$40	; | elevator exit (left)
		dw $97B0				; |
		BCC $01 : RTL				;/

		JSL WARP_BOX				;\
		db $04 : dw $0660,$00E0 : db $40,$10	; | command bridge exit
		dw $0DF1				; |
		BCC $01 : RTL				;/

		REP #$20
		LDA #$01A0 : JSL END_Down


		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL


		.HDMA
		PHP
		REP #$20
		INC !Level+2
		INC !Level+2
		INC !Level+2
		INC !Level+2

		LDA !Level+2 : STA $1E
		STZ $20
		PLP
		RTL


level1FA:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		LDA !StoryFlags+$00
		CMP #$03 : BCC .IntroLevel
		.Normal
		REP #$20
		LDA.w #!MSG_Survivor_Talk_1 : STA !NPC_Talk+(6*2)
		SEP #$20
		RTL
		.IntroLevel
		REP #$20
		LDA.w #!MSG_Survivor_Talk_IntroLevel : STA !NPC_Talk+(6*2)
		SEP #$20
		RTL

	.Main
		REP #$20
		LDA !MsgTrigger
		CMP.w #!MSG_Survivor_Talk_IntroLevel_End
		SEP #$20
		BNE +
		LDA $400000+!MsgPortrait : BNE +
		LDA #$03 : STA !StoryFlags+$00			; portable warp pipe get
		LDA #$80 : TSB !LevelTable1+$00			;\ beat intro level and save event
		LDA #$80 : TSB !LevelTable3+$00			;/

		REP #$20
		LDA #$00B8 : STA !SRAM_overworldX		;\ move on overworld
		LDA #$0330 : STA !SRAM_overworldY		;/
		LDA.w #!MSG_Survivor_Talk_1 : STA !NPC_Talk+(6*2)
		LDA !P2XPosLo
		SEC : SBC $1A
		STA $00
		LDA $14
		LSR #2
		AND #$000F
		SBC #$0008
		BPL $03 : EOR #$FFFF
		CLC : ADC #$0020
		STA $02
		LDA !P2YPosLo
		SEC : SBC $1C
		SEC : SBC $02
		STA $01
		LDA.w #.PipeTilemap : STA $02
		SEP #$20
		LDA #$02 : STA $0D
		LDA #$04 : STA $0E
		JSL DrawSpriteHUD
		+


		STZ $00
		STZ $01
		JSL DisplayYC
		RTL

		.PipeTilemap
		db $00,$00,$90,$3B



; luigi tutorial room
level1FB:
	dw $0000
	dw $0000
	dw $0000
	dw $0000

; kadaal tutorial room
level1FC:
	dw $0000
	dw $0000
	dw $0000
	dw $0000

; leeway tutorial room
level1FD:
	dw $0000
	dw $0000
	dw $0000
	dw $0000

; alter tutorial room
level1FE:
	dw $0000
	dw $0000
	dw $0000
	dw $0000

; peach
level1FF:
	dw $0000
	dw $0000
	dw $0000
	dw $0000






