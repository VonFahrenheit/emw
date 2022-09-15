
header
sa1rom


; --core defines--

incsrc "Defines.asm"



; -- rom name --

if !LockROM = 0
print "ROM NAME: SUPER MARIOWORLD     "
print "ROM has not been locked"
	org $00FFC0
	ROMNAME:
	db "SUPER MARIOWORLD     "
	warnpc $00FFD5
else
print "ROM NAME: Extra Mario World    "
print "ROM has been locked"
	org $00FFC0
	ROMNAME:
	db "Extra Mario World    "
	warnpc $00FFD5
endif


; -- extra defines --

incsrc "MSG/TextCommands.asm"
cleartable
table "MSG/MessageTable.txt"
!CompileText = 0
incsrc "MSG/TextData.asm"




	; claim banks
	org $10FFF8
	db $53,$54,$41,$52
	dw $8000,$7FFF
	%BigRATS($128000)
	%BigRATS($148000)
	%BigRATS($168000)
	%BigRATS($188000)
	%BigRATS($1A8000)
	%BigRATS($1C8000)
	%BigRATS($1E8000)




; CORE DOCUMENTATION

; 00806B	JMP $81E1		; go to FinalShade, where SNES will spend the rest of the frame shading
; 0081E1				; some shader code here, ends up in RAM
; 001E8F	LDA $10 : BEQ $1E8E 	; wait for NMI if necessary (it never is since sa-1 runs timing duty)
; 001E93	JMP $806F

; 00806F	CLI
; 008070	INC $13
; 008072	JSR $81CE		; MainExpand

; 0081CE	JSR $9322		; GetGameMode (MAIN MAIN MAIN)
; 0081D1	LDA !GameMode
; 0081D4	CMP #$05 : BCC $81E0
; 0081D8	CMP #$11 : BEQ $81E0
; 0081DC	JML Build_RAM_Code	; build ram code at the end of the frame
; 0081E0	RTS

; 008075	JML $0E8020		; AMK code (includes STZ $10)
; 00E864	JML $00806B		; return to CORE loop


	org $00806B
		JMP FinalShade				; org: JMP $1E8F
		NOP #2
	; this is where the CPU jumps after NMI
		CLI
		JMP MainExpand				;\ org: INC $13 : JSR $9322
		NOP #2					;/
	warnpc $008079
	; can't expand past here since that's where the music engine upload starts


	org $0081CE					; unused NMI code
	MainExpand:
		JSR GameModeTemp			; overwritten code (GetGameMode)
		LDA !GameMode
		CMP #$05 : BCC Return_RAM_Code
		CMP #$11 : BEQ Return_RAM_Code
		JML Build_RAM_Code
	Return_RAM_Code:
		JML $0E8020

	; this is where the CPU waits for NMI
	FinalShade:
		LDA !GameMode				;\ only run final shade on game mode 05+
		CMP #$05 : BCC +			;/
		LDA #$A1				;\
	-	BIT $4212 : BMI - : BVS -		; | always enable NMI + IRQ here (IRQ will know during which game modes to display status bar)
		STA $4200				;/
		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | have SA-1 keep track of when NMI occurs
		LDA.b #.SA1>>16 : STA $3182		; |
		LDA #$80 : STA $2200			;/
		JSR !MPU_light				; have SNES run shading operation
	+	JMP $1E8F				; go to end of game loop

		.SA1
		LDA $10 : BNE +				; skip this if CPU is behind PPU (if NMI has already fired)
		STZ !MPU_NMI				;\
	-	LDA !MPU_NMI : BEQ -			; | otherwise wait for NMI, then clear MPU NMI flag
	+	STZ !MPU_NMI				;/
		RTL					; return
	warnpc $008371



	; vector calls
	org $00816A					; Start of NMI routine
		SEI
		JML NMI					; PHP : REP #$30 : PHA
	org $00838F
		JML IRQ
	org $0083B2
		JML ReturnNMI				; REP #$30 : PLB : PLY




	org $008027 : BRA +				;\ patch out the code that generates smw's RAM code
	org $00804A : +					;/


	org $008AB4
	; some freespace that can be used
	warnpc $008CFF


	org $008E1A
	; some freespace that can be used
	warnpc $0090D1






;==========================;
; BANK 01: VANILLA SPRITES ;
;==========================;
	org $018000
	incsrc "Fe26/VanillaSprites.asm"


;=====================;
; BANK 02: FUSIONCORE ;
;=====================;
	org $028000
	incsrc "FusionCore/FusionCore.asm"


;=========;
; BANK 03 ;
;=========;
	org $038000


;=========;
; BANK 04 ;
;=========;
	org $048000



;=========;
; BANK 11 ;
;=========;
	org $118000
	incsrc "CodeBase/OAM.asm"
	incsrc "CodeBase/map16.asm"
	incsrc "CodeBase/VR3_interface.asm"
	incsrc "CodeBase/GFX_update.asm"
	incsrc "CodeBase/color.asm"
	incsrc "CodeBase/players.asm"
	incsrc "CodeBase/math.asm"
	incsrc "CodeBase/physics.asm"
	incsrc "CodeBase/joint_clusters.asm"
	incsrc "CodeBase/particles.asm"

	incsrc "CodeBase/5bpp.asm"
	incsrc "CodeBase/Transform_GFX.asm"





	pushpc
	org $009322
	GameModeTemp:
		PHK : PEA.w .Return-1		; RTL address: .Return
		PEA.w .TempReturn-1		; RTS address: .TempReturn
		JML RunGameMode
		.Return
		RTS

	warnpc $009387D
	pullpc
		.TempReturn
		RTL
	incsrc "GameModeEngine.asm"




;=========;
; BANK 12 ;
;=========;

	org $128008
	incsrc "Engine/NMI.asm"
	incsrc "Engine/IRQ.asm"
	incsrc "Engine/BRK.asm"
	incsrc "Engine/VR3.asm"
	incsrc "Engine/SRAM.asm"
	incsrc "Engine/MPU.asm"
	incsrc "Engine/StatusBar.asm"
	incsrc "Engine/GFX_Loader.asm"
	incsrc "Engine/DecompressBackground.asm"

	org $138000
	incsrc "MainMenu.asm"
	incsrc "MSG/MSG.asm"

	org $148008
	incsrc "PCE/PCE.asm"
	Mario:
	print " "
	print "Mario modification code inserted at $", pc, " ($", hex(Luigi-Mario), " bytes)"
	incsrc "PCE/characters/Mario.asm"
	Luigi:
	print " "
	print "Luigi code inserted at $", pc, " ($", hex(Kadaal-Luigi), " bytes)"
	incsrc "PCE/characters/Luigi.asm"
	Kadaal:
	print " "
	print "Kadaal code inserted at $", pc, " ($", hex(Bank14End-Kadaal), " bytes)"
	incsrc "PCE/characters/Kadaal.asm"
	Bank14End:
	print " "
	print "$", hex($150000-Bank14End), " bytes left in bank."
	print " "

	org $158000
	Leeway:
	print " "
	print "Leeway code inserted at $", pc, " ($", hex(Alter-Leeway), " bytes)"
	incsrc "PCE/characters/Leeway.asm"
	Alter:
	print " "
	print "Alter code inserted at $", pc, " ($", hex(Peach-Alter), " bytes)"
	incsrc "PCE/characters/Alter.asm"
	Peach:
	print " "
	print "Peach code inserted at $", pc, " ($", hex(Bank15End-Peach), " bytes)"
	incsrc "PCE/characters/Peach.asm"
	Bank15End:
	print " "
	print "$", hex($160000-Bank15End), " bytes left in bank."
	print " "

	org $168008
	incsrc "Fe26/Fe26.asm"
	Bank16:
	print " "
	print "-- BANK $16 --"
	%InsertSprite(HappySlime)
	%InsertSprite(GoombaSlave)
	%InsertSprite(Rex)
	%InsertSprite(HammerRex)
	%InsertSprite(AggroRex)
	%InsertSprite(FlyingRex)
	%InsertSprite(Conjurex)
	%InsertSprite(Wizrex)
	Bank16End:
	print "Bank $16 ends at $", pc, ". ($", hex($170000-Bank16End), " bytes left)"

	org $178000
	Bank17:
	print " "
	print "-- BANK $17 --"
	%InsertSprite(NPC)
	%InsertSprite(Block)
	%InsertSprite(KingKing)
	%InsertSprite(LakituLovers)
	%InsertSprite(Thif)
	%InsertSprite(KompositeKoopa)
	%InsertSprite(Birdo)
	%InsertSprite(Bumper)
	%InsertSprite(Sign)
	%InsertSprite(Monkey)
	%InsertSprite(MiniMole)			; must be inserted before mole wizard
	%InsertSprite(TerrainPlatform)
	%InsertSprite(CoinGolem)
	%InsertSprite(YoshiCoin)
	%InsertSprite(EliteKoopa)
	%InsertSprite(AirshipDisplay)
	%InsertSprite(SmokeyBoy)
	BANK17End:
	print "Bank $17 ends at $", pc, ". ($", hex($180000-BANK17End), " bytes left)"

	org $188008
	Bank18:
	print " "
	print "-- BANK $18 --"
	%InsertSprite(LavaLord)
	%InsertSprite(FlamePillar)
	%InsertSprite(BigMax)
	%InsertSprite(Portal)
	%InsertSprite(TarCreeper)
	%InsertSprite(PlantHead)
	%InsertSprite(UltraFuzzy)
	%InsertSprite(ShieldBearer)
	%InsertSprite(Elevator)
	%InsertSprite(CaptainWarrior)
	%InsertSprite(GigaThwomp)
	%InsertSprite(BooHoo)
	%InsertSprite(MoleWizard)
	%InsertSprite(Lightning)
	%InsertSprite(ShopObject)
	%InsertSprite(Projectile)
	%InsertSprite(Chest)
	%InsertSprite(EpicBlock)
	BANK18End:
	print "Bank $18 ends at $", pc, ". ($", hex($190000-BANK18End), " bytes left)"
	print " "

	org $198000
	incsrc "Overworld/Overworld.asm"

	org $1A8008
	incsrc "GameModeLevelLoad.asm"
	incsrc "GameMode14.asm"
	incsrc "LevelData.asm"
	incsrc "LevelPointers.asm"

namespace LevelCode
	print "Realm 5 code inserted at $", pc, "."
	incsrc "level_code/Realm5.asm"
	print "Realm 6 code inserted at $", pc, "."
	incsrc "level_code/Realm6.asm"
	print "Realm 7 code inserted at $", pc, "."
	incsrc "level_code/Realm7.asm"
	print "Realm 8 code inserted at $", pc, "."
	incsrc "level_code/Realm8.asm"
	print "Bank $1A level code ends at $", pc, "."

	org $1B8000
	print "Unsorted code inserted at $", pc, "."
	incsrc "level_code/Unsorted.asm"
	print "Bank $1B code ends at $", pc, "."

	org $1C8008
	print "Realm 1 code inserted at $", pc, "."
	incsrc "level_code/Realm1.asm"
	print "Realm 2 code inserted at $", pc, "."
	incsrc "level_code/Realm2.asm"
	print "Realm 3 code inserted at $", pc, "."
	incsrc "level_code/Realm3.asm"
	print "Realm 4 code inserted at $", pc, "."
	incsrc "level_code/Realm4.asm"
	print "Bank $1C code ends at $", pc, "."
	print " "
namespace off

	org $1D8000
	org $1E8008
	org $1F8000









;=========;
;DMA REMAP;
;=========;
pushpc
incsrc "DMA_Remap.asm"
pullpc




;===================;
;BRICK ANIMATION FIX;
;===================;
; $14 & F:
; 0 ->	question block, animated, tile 0x0060
;	water, animated, tile 0x0070
; 1 ->	question block, animated 2 (?), tile 0x0078
;	muncher, tile 0x005C
; 2 ->	coin, tile 0x0054
; 3 ->	coin 2 (?), tile 0x006C
; 4 ->	used block, static, tile 0x0058
; 5 ->	corner man (!!???), tile 0x00EE (ExAnimation)
; 6 ->	?????
; 7 ->	?????
; 8 ->	question block, static (?), tile 0x0040
; 9 ->	[repeat of 1]
; A ->	[repeat of 2]
; B ->	[repeat of 3]
; C ->	[repeat of 4]
; D ->	[repeat of 5]
; E ->	?????
; F ->	?????

; Brick updates at:
; $14&7 = 1
; Read from $6D7E



; the routine this comes from is called from VR3, possibly from one other place too

pushpc
org $05BBA2
	JML BrickAnim	; Source: SEP #$20 : PLB : RTL
pullpc

	BrickAnim:
		LDA $6D7E
		CMP #$0EA0 : BNE .Return
		LDA $14
		AND #$00FF
		CMP #$0020 : BCC .Return

		LDA #$9600 : STA $6D78		; Delay animation

		.Return
		SEP #$20
		PLB
		RTL

; Plan: Read LM's VRAM table to check for address 0x0EA0 (AND #$7FFF)
; Then use that to figure out if it should be delayed

; Data (bank 7F)
; $C003: backup frame counter?
; $C00A: ExAnimation enable?
; $C00E: Highest ExAnimation frame slot?
; $C019: Unknown

; $C0C0: VRAM table
; $00-$01:	Data size
; $02-$03:	VRAM address (highest bit has unknown meaning)
; $04-$06:	Source address






	; patch out all references to $6F40
	org $05CD04
		NOP #3		; STA
	org $05CEDD
		NOP #3		;\ LDA : BEQ
		BRA $23		;/
	org $05CEED
		NOP #3		; STA
	org $05CF36
		NOP #5		; LDA : BNE
	org $05CF66
		NOP #3		;\ LDA : BEQ
		BRA $35		;/


print " "


	incsrc "SP_Files.asm"



