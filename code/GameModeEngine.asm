

; TODO:
; TO DO:
; - level transitions, screen settings
; - windowing has to reset between modes (at least when going into a level)



	RunGameMode:
		LDA !GameMode : JSL $0086DF

		.GameModePtr
		dw GAMEMODE_00		; 00 - runs once right after RESET vector
		dw PresentsScreen	; 01 - presents screen
		dw GAMEMODE_02		; 02 - fade from presents screen
		dw GAMEMODE_03_Main	; 03 - load title screen level data + initialize a bunch of RAM
		dw GAMEMODE_04		; 04 - initialize title screen level
		dw GAMEMODE_05		; 05 - fade in to title screen
		dw GAMEMODE_06		; 06 - ----
		dw MainMenu		; 07 - "press any button"
		dw MainMenu		; 08 - MAIN MENU
		dw GAMEMODE_09		; 09 - ----
		dw GAMEMODE_0A		; 0A - ----
		dw LevelFade		; 0B - LEVEL - fade out to overworld
		dw GAMEMODE_0C		; 0C - LOAD OVERWORLD
		dw LevelToOverworld	; 0D - OVERWORLD - iris open
		dw GAMEMODE_0E		; 0E - OVERWORLD
		dw GAMEMODE_0F		; 0F - LEVEL - fade out to level
		dw GAMEMODE_10		; 10 - LOAD LEVEL - phase 1 (load intro text)
		dw CallGameMode11	; 11 - LOAD LEVEL - phase 2 (load level data)
		dw CallGameMode12	; 12 - LOAD LEVEL - phase 3 (initialize level mode)
		dw LevelFade		; 13 - LEVEL - fade in
		dw CallGameMode14	; 14 - LEVEL
		dw OverworldToLevel	; 15 - OVERWORLD - iris close
		..end

;=============;
; GAMEMODE 00 ;
;=============;
	GAMEMODE_00:
		JSL CheckInitSRAM

		%LockROM(ROMNAME, #$45)
		%ResetTracker()

	if !LockROM = 1
		SEP #$30
		LDX.b #.BackupName_end-.BackupName-1
	-	LDA.l .BackupName,x
		CMP.l ROMNAME,x : BNE .Fail
		DEX : BPL -
		BRA +

		.Fail
		BRK

		.BackupName
		cleartable
		db "Extra Mario World"
		table "MSG/MessageTable.txt"
		..end
		+
	endif

		REP #$30
		LDX #$00FE
		LDA #$0000
	-	STA $400000+!MsgRAM,x
		DEX #2 : BPL -
		STA !OAMindex_p0
		STA !OAMindex_p1
		STA !OAMindex_p2
		STA !OAMindex_p3
		STA !HDMAptr+0
		STA !HDMAptr+1
		%ReloadOAMData()

		STZ !HDMA2source
		STZ !HDMA3source
		STZ !HDMA4source
		STZ !HDMA5source
		STZ !HDMA6source
		STZ !HDMA7source

		SEP #$20
		REP #$10

		STZ $420C						; HDMA reg
		STZ !HDMA						; HDMA mirror 1
		STZ $1F0C						; HDMA mirror 2


		LDX #$8000 : STX $4300					;\
		LDX.w #MPU_wait : STX $4302				; |
		LDA.b #MPU_wait>>16 : STA $4304				; |
		LDX.w #MPU_wait_end-MPU_wait : STX $4305		; | DMA !MPU_wait routine into place
		LDX.w #!MPU_wait : STX $2181				; |
		STZ $2183						; |
		LDA #$01 : STA $420B					;/
		LDX.w #MPU_light : STX $4302				;\
		LDX.w #MPU_light_end-MPU_light : STX $4305		; |
		LDX.w #!MPU_light : STX $2181				; | DMA !MPU_light routine into place
		STZ $2183						; |
		STA $420B						;/

		SEP #$30


	-	BIT $4212 : BPL -					; wait for v-blank to avoid tearing
		LDA #$80 : STA $2100					; f-blank baybeee
		STZ $2115						; lo byte only first to upload tilemap

		REP #$20
		LDA.w #!DecompBuffer : STA $00
		LDA.w #!DecompBuffer>>8 : STA $01
		LDA.w #$B00
		JSL !DecompressFile
		LDA #$1800 : STA $4300
		LDA.w #!DecompBuffer : STA $4302
		LDA.w #!DecompBuffer>>8 : STA $4303
		LDA #$4000 : STA $4305
		STZ $2116
		LDX #$01 : STX $420B

		LDX #$80 : STX $2115					; hi byte only to upload GFX
		LDA.w #!DecompBuffer : STA $00
		LDA.w #!DecompBuffer>>8 : STA $01
		LDA.w #$D00
		JSL !DecompressFile
		LDA #$1900 : STA $4300
		LDA.w #!DecompBuffer : STA $4302
		LDA.w #!DecompBuffer>>8 : STA $4303
		LDA #$4000 : STA $4305
		STZ $2116
		LDX #$01 : STX $420B

		LDX #$00 : STX $2121					; CGRAM color 1
		LDA #$2202 : STA $4300					; 2122 write twice
		LDA.w #.SourcePal : STA $4302
		LDA.w #.SourcePal>>8 : STA $4303
		LDA #$0200 : STA $4305
		LDX #$01 : STX $420B
		LDA.l .SourcePal+$00 : STA !Color0

		LDX #$07 : STX $2105					; mode 7
		STX $3E

		LDA #$FFC0
		STA $1A
		STA $1C

		LDX #$00 : STX $211B
		LDX #$01 : STX $211B
		LDX #$00 : STX $211C
		LDX #$00 : STX $211C
		LDX #$00 : STX $211D
		LDX #$00 : STX $211D
		LDX #$00 : STX $211E
		LDX #$01 : STX $211E

		LDX #$80 : STX $211A					; mode 7 settings: large playfield, transparency fill, no mirroring


		SEP #$20
		LDA #$01 : STA $212C
		STA !MainScreen

		STZ $7DF5

		SEP #$30
		LDA #$0F : STA !2100					; brightness = max


		.SetScreen
		STZ $2133						; disable hires mode
		STZ $6DAF						; mosaic direction = growing
		STZ !2132_RGB
		STZ !2132_RGB+1
		LDA #$01 : STA $6D9B					; disable status bar IRQ
		INC !GameMode
		LDA #$81						;\
	-	BIT $4212 : BMI - : BVS -				; | wait for no blanks, then enable NMI + auto joypad
		STA $4200						;/
		RTS

		.PriorityData
		dw $0000,$0002,$0004,$0006		; holds the index to the current OAM index reg
		dw $0000,$0200,$0400,$0600		; holds the offset to the current OAM index

		.SourcePal
		incbin "../PaletteData/PresentsScreenPalette.mw3"

;=============;
; GAMEMODE 01 ;
;=============;
	PresentsScreen:
		LDA $6DA6					;\
		ORA $6DA7					; |
		ORA $6DA8					; | skip animation with any button press
		ORA $6DA9					; |(but not d-pad)
		AND #$F0 : BNE .NextGameMode			;/
		DEC $7DF5					; decrement timer
	-	BIT $4212 : BPL -				; wait for v-blank since doing this during h-blank breaks snes9x for some reason
		LDA $7DF5
		ASL A : STA $211B
		LDA #$00
		ROL A : STA $211B
		LDA $7DF5
		ASL A : STA $211E
		LDA #$00
		ROL A : STA $211E
		LDA #$40 : STA $211F
		STZ $211F
		LDA #$40 : STA $2120
		STZ $2120
		LDA $7DF5 : BEQ .NextGameMode
		LDA !GameMode
		CMP #$01 : BNE .Return
		LDA.l GAMEMODE_00_SourcePal+$00 : STA !Color0
		LDA.l GAMEMODE_00_SourcePal+$01 : STA !Color0+1
		LDA #$01 : STA $6DAF
		LDA #$0F : STA !2100
		.Return
		RTS

		.NextGameMode
		LDA #$02 : STA !GameMode
		RTS


;=============;
; GAMEMODE 03 ;
;=============;
	GAMEMODE_03:

		.SA1
		PHP
		PHB
		STZ $7FFF
		STZ $30FF
		STZ $3200
		REP #$30
		LDA #$1EF3
		LDX #$7FFF
		LDY #$7FFE
		MVP $00,$00
		LDA #$00FF
		LDX #$30FF
		LDY #$30FE
		MVP $00,$00
		LDA #$0225
		LDX #$3200
		LDY #$3201
		MVN $00,$00
		SEP #$30
		PLB
		LDA #$FF					;\
		STA !HeldItemP1_num				; | these have to be initialized here
		STA !HeldItemP2_num				;/
		PLP
		RTL

		.Main
		STZ $4200
		REP #$30
		LDA #$0000
		STA $7FC0C0
		STA $7FC0C7
		STA $7FC0CE
		STA $7FC0D5
		STA $7FC0DC
		STA $7FC0E3
		STA $7FC0EA
		STA $7FC0F1
		LDA.w #.SA1 : STA $3180
		SEP #$30
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80

		LDX #$07
		LDA #$FF
	-	STA $6101,x
		DEX : BPL -
		LDA $6109 : BNE +
		LDA #$2A : STA !SPC3				; main menu music
	+	LDA #$C7 : STA $6109				;\ what level should be loaded (main menu)
		STZ $7F11					;/

		JSL GAMEMODE_11

		LDA #$33 : STA !2123				;\
		LDA #$00 : STA !2124				; | initial screen settings for main menu
		LDA #$23 : STA !2125				; |
		LDA #$12 : STA !2130				;/
		LDA #$05 : STA !GameMode
		RTS


	GAMEMODE_04:


;=================================;
; GAMEMODE 11: LOAD LEVEL PHASE 1 ;
;=================================;
	CallGameMode11:
		JSL GAMEMODE_11
		RTS



;========================================;
; GAMEMODE 05: OPEN IRIS ON TITLE SCREEN ;
;========================================;
	GAMEMODE_05:
		JSR UpdateIris
		LDA #$01 : STA !CircleForceCenter

		.CheckButtons
		LDA $6DA6					;\
		ORA $6DA7					; |
		ORA $6DA8					; | skip animation with any button press
		ORA $6DA9					; | (but make sure to still render the fully open circle)
		AND #$F0 : BEQ ..done				; |
		LDA #$30 : STA !CircleRadius			; |
		..done						;/

		LDA #$0F : STA !2100
		LDA.b #Overworld_RenderCircle : STA $3180
		LDA.b #Overworld_RenderCircle>>8 : STA $3181
		LDA.b #Overworld_RenderCircle>>16 : STA $3182
		JSR $1E80
		LDA !CircleRadius
		CMP #$30 : BCS .NextMode
		INC !CircleRadius
		RTS

		.NextMode
		LDA #$07 : STA !GameMode
		STZ !HDMA
		STZ !2123
		STZ !2124
		STZ !2125
		LDA #$02 : STA !2130
		RTS



;=============;
; GAMEMODE 06 ;
;=============;
	GAMEMODE_06:
		; gamemode 04 actually JSRs to $9443, but that shouldn't be a problem after the rewrite


;=============;
; GAMEMODE 09 ;
;=============;
	GAMEMODE_09:		; not actually used


;=============;
; GAMEMODE 0A ;
;=============;
	GAMEMODE_0A:		; not actually used


;=============;
; GAMEMODE 0C ;
;=============;
	GAMEMODE_0C:
		JSL Overworld_LOAD
		RTS


;=============;
; GAMEMODE 0D ;
;=============;
	LevelToOverworld:
		LDA #$01 : STA $6DAF
		LDA #$0F : STA !2100
		LDA #$0F : STA !Mosaic
		JSR UpdateIris
		JSL Overworld_MAIN
		LDA !CircleRadius
		CMP #$30 : BEQ .Done
		INC !CircleRadius
		RTS
		.Done
		INC !GameMode
		RTS


;=============;
; GAMEMODE 15 ;
;=============;
	OverworldToLevel:
		JSR UpdateIris
		JSL Overworld_MAIN
		LDA !CircleRadius : BEQ .Done
		DEC !CircleRadius
		RTS
		.Done
		LDA #$10 : STA !GameMode
		STZ $6DAF
		STZ !2100
		LDA #$FF : STA !Mosaic
		RTS


	UpdateIris:
		PHP
		REP #$30					;\
		LDA #$2641 : STA $4360				; |
		SEP #$20					; | set up HDMA
		LDA.b #.HDMA>>16				; |
		STA $4364					; |
		STA $4367					; |
		LDA #$40 : STA !HDMA				;/
		LDA #$33 : STA !2123
		LDA #$23 : STA !2125
		LDX.w #.HDMA_window2				;\
		LDA !CircleTimer				; |
		LSR A						; | source for window HDMA
		BCC $03 : LDX.w #.HDMA_window1			; |
		STX !HDMA6source				;/
		INC !CircleTimer
		PLP
		RTS


	.HDMA
	; indirect -> $2126 + $2127, B = K
	..window1
		db $F0 : dw !CircleTable1
		db $F0 : dw !CircleTable1+$E0
		db $00

	..window2
		db $F0 : dw !CircleTable2
		db $F0 : dw !CircleTable2+$E0
		db $00

;=============;
; GAMEMODE 02 ;
;=============;
	GAMEMODE_02:
		JSR PresentsScreen
		JSR LevelFade
		STZ !Mosaic
		.Return
		RTS


;==========================;
; GAMEMODES 05, 0B, 0F, 13 ;
;==========================;
	LevelFade:
	PHB : PHK : PLB
		LDY $6DAF
		LDA !GameMode
		CMP #$0B : BEQ .Slow
		LDA $741A : BNE .Quick
		.Slow
		LDA $13
		LSR A : BCC .Return
		LDA !2100
		CLC : ADC .SlowFadeTable,y
		STA !2100
		ASL #4
		EOR #$F0
		ORA #$0F
		STA !Mosaic
		LDA !2100 : BEQ .End
		BRA +
		.Quick
		LDA #$0F : STA !Mosaic
		LDA !2100
		CLC : ADC .QuickFadeTable,y
		BPL $02 : LDA #$00
		CMP #$0F
		BCC $02 : LDA #$0F
		STA !2100
		CMP #$00 : BEQ .End
	+	CMP #$0F : BCC .Return
		.End
		INC !GameMode
		TYA
		EOR #$01 : STA $6DAF
		.Return
	PLB
		RTS

	.SlowFadeTable
		db $01,$FF

	.QuickFadeTable
		db $01,$FE



	GAMEMODE_0F:
		JSR LevelFade
		LDA !GameMode
		CMP #$10 : BNE GAMEMODE_02_Return		; mind the PLB on LevelFade

		; set carried item for player 1
		.P1
		LDY !P2Carry-$80 : BEQ ..noitem
		DEY
		LDA !SpriteNum,y : STA !HeldItemP1_num
		LDA !ExtraBits,y				;\
		CMP !HeldItemP1_extra : BNE ..set		; |
		LDA !SpriteID,y					; | if all these are the same, this sprite was carried from a PREVIOUS level
		CMP #$FF : BEQ ..done				; |
		CMP !HeldItemP1_ID : BEQ ..done			;/
		..set
		LDA !SpriteNum,y
		CMP #$32 : BEQ ..noitem
		LDA !ExtraBits,y : STA !HeldItemP1_extra
		LDA !ExtraProp1,y : STA !HeldItemP1_prop1
		LDA !ExtraProp2,y : STA !HeldItemP1_prop2
		REP #$20
		LDA !Level : STA !HeldItemP1_level
		SEP #$20
		LDA !SpriteID,y : STA !HeldItemP1_ID
		BRA ..done
		..noitem
		LDA #$FF : STA !HeldItemP1_num
		..done

		; set carried item for player 2
		.P2
		LDY !P2Carry : BEQ ..noitem
		DEY
		LDA !SpriteNum,y : STA !HeldItemP2_num
		LDA !ExtraBits,y				;\
		CMP !HeldItemP2_extra : BNE ..set		; |
		LDA !SpriteID,y					; | if all these are the same, this sprite was carried from a PREVIOUS level
		CMP #$FF : BEQ ..done				; |
		CMP !HeldItemP2_ID : BEQ ..done			;/
		..set
		LDA !SpriteNum,y
		CMP #$32 : BEQ ..noitem
		LDA !ExtraBits,y : STA !HeldItemP2_extra
		LDA !ExtraProp1,y : STA !HeldItemP2_prop1
		LDA !ExtraProp2,y : STA !HeldItemP2_prop2
		REP #$20
		LDA !Level : STA !HeldItemP2_level
		SEP #$20
		LDA !SpriteID,y : STA !HeldItemP2_ID
		BRA ..done
		..noitem
		LDA #$FF : STA !HeldItemP2_num
		..done

		; flow into gamemode 10


;====================================;
; GAMEMODE 10: LOAD LEVEL INTRO TEXT ;
;====================================;
	GAMEMODE_10:
		STZ $4200
		LDA #$80 : STA $2100
		LDA $741A
		ORA $6109
		ORA $7F11
		BEQ .IntroText
		JMP GAMEMODE_00_SetScreen			; go to shared mode 00 code

		.IntroText
	PHB : PHK : PLB
		STZ !HDMA					;\
		STZ $1F0C					; | no HDMA
		STZ $420C					;/
		LDA #$10					;\
		STA $212C					; |
		STA !MainScreen					; | sprites only
		STZ $212D					; |
		STZ !SubScreen					;/

		STZ $2123					;\
		STZ $2124					; |
		STZ $2125					; |
		STZ !2123					; | no clipping windows
		STZ !2124					; |
		STZ !2125					; |
		STZ $212E					; |
		STZ $212F					;/

		STZ $2121
		STZ $2122
		STZ $2122

		LDA #$80 : STA $2115
		REP #$30
		LDY.w #!File_IntroQuotes : JSL GetFileAddress
		LDA #$1801 : STA $4300
		LDA !FileAddress : STA $4302
		LDA !FileAddress+1 : STA $4303
		LDA #$1000 : STA $4305
		LDA #$6800 : STA $2116
		SEP #$30
		LDA #$01 : STA $420B

		LDA !MultiPlayer : BEQ .p1
		BIT $13 : BPL .p1
	.p2	LDA !Characters
		AND #$0F
		BRA +
	.p1	LDA !Characters
		LSR #4
	+	TAX
		LDA $13
		AND #$01
		CLC : ADC.w .CharIndex,x
		ASL A
		TAX
		REP #$20
		LDA .Ptr,x : STA $0E
		SEP #$20
		LDA #$68 : STA $01		; base Y
		STZ $00				;\
		LDY #$00			; |
	-	LDA ($0E),y			; |
		CMP #$FF : BEQ +		; |
		ASL A				; |
		ADC ($0E),y			; |
		TAX				; |
		LDA .TileData+2,x		; | base X
		CLC : ADC $00			; |
		STA $00				; |
		INY : BRA -			; |
		+				; |
		LDA #$00			; |
		SEC : SBC $00			; |
		ROR A				; |
		STA $00				;/

		LDX #$00
		LDY #$00

	.loop	LDA ($0E),y
		CMP #$FF : BEQ .done

		PHY				; push index
		STA $02				;\
		ASL A				; | get index to tile data
		ADC $02				; |
		TAY				;/
		LDA .TileData+0,y : STA $02	; $02 = base tile num
		LDA .TileData+1,y : STA $03	; $03 = number of 8x16 blocks
		LDA $00 : STA $04		; $04 = temp Xpos

	-	LDA $04				;\
		STA !OAM_p3+0,x			; | Xpos
		STA !OAM_p3+4,x			;/
		LDA $01 : STA !OAM_p3+1,x	;\
		CLC : ADC #$08			; | Ypos
		STA !OAM_p3+5,x			;/
		LDA $02 : STA !OAM_p3+2,x	;\
		CLC : ADC #$10			; | tile num
		STA !OAM_p3+6,x			;/
		LDA #$34			;\
		STA !OAM_p3+3,x			; | prop
		STA !OAM_p3+7,x			;/
		TXA				;\
		LSR #2				; |
		TAX				; | hi bytes
		LDA #$00			; |
		STA !OAMhi_p3+0,x		; |
		STA !OAMhi_p3+1,x		;/
		INX #2				;\
		TXA				; | increment
		ASL #2				; |
		TAX				;/
		DEC $03 : BMI .next		; check remaining tiles on characters
		LDA $04				;\
		CLC : ADC #$08			; | increment temp Xpos
		STA $04				;/
		INC $02				; increment tile num
		BRA -				; mini loop

		.next
		LDA .TileData+2,y		;\
		CLC : ADC $00			; | increment Xpos
		STA $00				;/
		PLY				; pull index
		INY
		BRA .loop

		.done
		LDA !Translevel : BEQ +

		TXA : STA !OAMindex_p3
		LDA #$00
		STA !OAMindex_p0
		STA !OAMindex_p1
		STA !OAMindex_p2
		JSL BuildOAM
		LDA !OAMindex_p3_prev : STA !OAMindex_p3
		+
	PLB

		STZ $4304			;\
		REP #$20			; |
		LDA #$0400 : STA $4300		; |
		LDA #$6200 : STA $4302		; | upload OAM
		LDA #$0220 : STA $4305		; |
		SEP #$20			; |
		LDA #$01 : STA $420B		;/

		LDA #$E0 : STA $2132
		LDA #$0F
		STA !2100
		STA $2100

		JMP GAMEMODE_00_SetScreen			; go to shared mode 00 code

		.CharIndex
		db $00			; mario
		db $02			; luigi
		db $04			; kadaal
		db $06			; leeway
		db $08			; alter
		db $0A			; peach

		.Ptr
		dw .Mario_1
		dw .Mario_2
		dw .Luigi_1
		dw .Luigi_2
		dw .Kadaal_1
		dw .Kadaal_2
		dw .Leeway_1
		dw .Leeway_2
		dw .Alter_1
		dw .Alter_2
		dw .Peach_1
		dw .Peach_2


; Values are, in order: base tile number, number of 8x16 tiles -1, character width.
; Character height is always 16 pixels.

		.TileData
	.A	db $80,$00,$08
	.B	db $81,$01,$09
	.C	db $83,$00,$08
	.D	db $84,$01,$09
	.E	db $86,$00,$08
	.F	db $87,$00,$08
	.G	db $88,$00,$08
	.H	db $89,$00,$08
	.I	db $8A,$00,$04
	.J	db $8B,$00,$08
	.K	db $8C,$01,$09
	.L	db $8E,$00,$08
	.M	db $A0,$01,$0B
	.N	db $A2,$00,$08
	.O	db $A3,$00,$08
	.P	db $A4,$01,$09
	.Q	db $A6,$01,$09
	.R	db $A8,$01,$09
	.S	db $AA,$00,$08
	.T	db $AB,$00,$08
	.U	db $AC,$00,$08
	.V	db $AD,$00,$08
	.W	db $AE,$01,$0C
	.X	db $C0,$00,$08
	.Y	db $C1,$00,$08
	.Z	db $C2,$00,$08

		db $C3,$00,$04			; '
		db $C4,$00,$08			; -
		db $C5,$00,$04			; !
		db $C6,$00,$04			; ,
		db $C7,$00,$04			; .
		db $C8,$00,$08			; ?
		db $C9,$00,$08			; space


cleartable
table "IntroTable.txt"


	.Mario
		..1
		db "IT'S-A-ME!"
		db $FF
		..2
		db "IT'S-A GO TIME!"
		db $FF

	.Luigi
		..1
		db "OH YEAH, LUIGI TIME!"
		db $FF
		..2
		db "GO-IGI!"
		db $FF

	.Kadaal
		..1
		db "KOOPA VENGEANCE!"
		db $FF
		..2
		db "JUST TRY TO KEEP UP!"
		db $FF

	.Leeway
		..1
		db "GET REXT!"
		db $FF
		..2
		db "SLICE AND DICE!"
		db $FF

	.Alter
		..1
		..2
	.Peach
		..1
		..2
		db "COMING SOON..."
		db $FF

cleartable
table "MSG/MessageTable.txt"




;================================;
; GAMEMODES 07 AND 08: MAIN MENU ;
;================================;
	MainMenu:
		LDA #$01 : STA $6DAF
		JSL MAIN_MENU
		RTS


;========================;
; GAMEMODE 0E: OVERWORLD ;
;========================;
	GAMEMODE_0E:
		JSR UpdateIris
		JSL Overworld_MAIN
		RTS


;=================================;
; GAMEMODE 12: LOAD LEVEL PHASE 2 ;
;=================================;
	CallGameMode12:
		JSL GAMEMODE_12
		RTS


;====================;
; GAMEMODE 14: LEVEL ;
;====================;
	CallGameMode14:
		JSL GAMEMODE_14
		RTS

		







