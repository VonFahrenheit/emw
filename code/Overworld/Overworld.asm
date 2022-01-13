print "OVERWORLD INSERTED AT $", pc, "!"

	namespace Overworld


; This should be included from SP_Patch.asm

; OW game mode starts at $00A1BE
; Its structure is as follows:
;	- JSR to $009A77 (set up $0DA0, a controller address)
;	- Increment main frame counter ($14)
;	- Erase sprite tiles
;	- Call main system ($048241)
;		- $8241: some debug stuff (I'm actually using this)
;		- $8275: dialogue box
;		- $8295: look around map code
;		- $829E: camera and cutscene stuff
;		- $8576: pointer jump based on $13D9 (includes Mario movement)
;		- $F708: OW sprites
;		- $862E: draw player
;
;	- Go to $008494 (build hi OAM table)

; $048295 seems to be the best place to hijack.
;
; All OW sprite tables can be used since I'm killing OW sprites
; $6DDF-$6EE5 is free to be used for this.
; The maximum number that can be added to !OverworldBase is +$106 (outdated, based on base address of $6DDF)


; $7EA2:
;	this table should be repurposed to determine which areas have been unlocked and beaten.
;	use together with level select function.




	!OverworldBase	= $74C8			; can be up to $500 bytes i think


	macro MapDef(name, size)
	print "<name>: $", hex(!OverworldBase+!Temp)

		!<name>	:= !OverworldBase+!Temp
		!Temp	:= !Temp+<size>
	endmacro


	!Temp = 0
	%MapDef(CharMenuSize,		1)	; used to hide characters that are not yet unlocked
	%MapDef(CharMenu,		1)	; 00 = no menu, 01 = opening, 02 = main, 03 = closing
	%MapDef(CharMenuCursor,		1)	; position
	%MapDef(SelectingPlayer,	1)	; which player controls the char select (0 = player 1, 1 = player 2)
	%MapDef(CharMenuTimer,		1)	; decrements
	%MapDef(CharMenuSpriteX,	6)	;\
	%MapDef(CharMenuSpriteStatus,	6)	; |
	%MapDef(CharMenuCurrentPlayerX,	1)	; | controls character select animations and options
	%MapDef(CharMenuCurrentPlayerY,	1)	; |
	%MapDef(CharMenuOtherPlayerX,	1)	; |
	%MapDef(CharMenuOtherPlayerY,	1)	; |
	%MapDef(CharMenuOtherPlayerP,	1)	; |
	%MapDef(CharMenuCount,		1)	; |
	%MapDef(CharMenuBaseX,		1)	;/

	%MapDef(WarpPipe,		1)
	%MapDef(WarpPipeP2X,		2)
	%MapDef(WarpPipeP2Y,		2)
	%MapDef(WarpPipeTimer,		1)
	%MapDef(CircleRadius,		2)
	%MapDef(CircleCenterX,		2)
	%MapDef(CircleCenterY,		2)
	%MapDef(CircleForceCenter,	2)
	%MapDef(ButtonTimer,		2)
	%MapDef(MapCheckpointX,		1)
	%MapDef(MapCheckpointTargetX,	1)
	%MapDef(CircleTimer,		1)
	%MapDef(PrevTranslevel,		2)
	%MapDef(MapLockCamera,		1)	;\ these 2 are used together
	%MapDef(MapCameraTimer,		1)	;/
	%MapDef(MapEvent,		2)	; when set, players can't move. gets cleared when camera reaches its resting position
	%MapDef(MapCameraSpeedX,	2)
	%MapDef(MapCameraSpeedY,	2)
	%MapDef(MapUpdateHUD,		4)
	%MapDef(MapLevelNameWidth,	2)

	%MapDef(MapHidePlayers,		2)

	%MapDef(P1MapXFraction,		1)
	%MapDef(P1MapX,			2)
	%MapDef(P1MapYFraction,		1)
	%MapDef(P1MapY,			2)
	%MapDef(P1MapZFraction,		1)
	%MapDef(P1MapZ,			2)
	%MapDef(P1MapXSpeed,		1)
	%MapDef(P1MapYSpeed,		1)
	%MapDef(P1MapZSpeed,		1)
	%MapDef(P1MapAnim,		1)
	%MapDef(P1MapPrevAnim,		1)
	%MapDef(P1MapDirection,		1)
	%MapDef(P1MapDiag2,		1)
	%MapDef(P1MapChar,		1)
	%MapDef(P1MapGhost,		1)
	%MapDef(P1MapForceFlip,		1)

	%MapDef(P2MapXFraction,		1)
	%MapDef(P2MapX,			2)
	%MapDef(P2MapYFraction,		1)
	%MapDef(P2MapY,			2)
	%MapDef(P2MapZFraction,		1)
	%MapDef(P2MapZ,			2)
	%MapDef(P2MapXSpeed,		1)
	%MapDef(P2MapYSpeed,		1)
	%MapDef(P2MapZSpeed,		1)
	%MapDef(P2MapAnim,		1)
	%MapDef(P2MapPrevAnim,		1)
	%MapDef(P2MapDirection,		1)
	%MapDef(P2MapDiag2,		1)
	%MapDef(P2MapChar,		1)
	%MapDef(P2MapGhost,		1)
	%MapDef(P2MapForceFlip,		1)

	%MapDef(MapLight,		$60)
	!MapLight_X	= !MapLight+0
	!MapLight_Y	= !MapLight+2
	!MapLight_R	= !MapLight+4
	!MapLight_G	= !MapLight+6
	!MapLight_B	= !MapLight+8
	!MapLight_S	= !MapLight+10

	%MapDef(MapOAMindex,		2)	; index to next free area of data
	%MapDef(MapOAMcount,		2)	; number of tilemaps currently in data
	%MapDef(MapOAMdata,		$100)	; holds OAM data to be sorted by Y coord


	print "Overworld RAM:"
	print " $", hex(!OverworldBase), "-$", hex(!OverworldBase+!Temp-1)
	print " total $", hex(!Temp), " bytes"



	!OverworldSpriteBase = $6DDF

	macro MapSpriteDef(name, size)
	print "<name>: $", hex(!OverworldSpriteBase+!Temp)
		!<name>	:= !OverworldSpriteBase+!Temp
		!Temp	:= !Temp+<size>
	endmacro

	!Temp = 0
	%MapSpriteDef(OW_sprite_Num,		1)
	%MapSpriteDef(OW_sprite_Timer,		1)
	%MapSpriteDef(OW_sprite_Anim,		1)
	%MapSpriteDef(OW_sprite_AnimTimer,	1)
	%MapSpriteDef(OW_sprite_XFraction,	1)
	%MapSpriteDef(OW_sprite_X,		2)
	%MapSpriteDef(OW_sprite_YFraction,	1)
	%MapSpriteDef(OW_sprite_Y,		2)
	%MapSpriteDef(OW_sprite_ZFraction,	1)
	%MapSpriteDef(OW_sprite_Z,		2)
	%MapSpriteDef(OW_sprite_XSpeed,		1)
	%MapSpriteDef(OW_sprite_YSpeed,		1)
	%MapSpriteDef(OW_sprite_ZSpeed,		1)
	%MapSpriteDef(OW_sprite_Direction,	1)
	%MapSpriteDef(OW_sprite_Tilemap,	2)
	!OW_sprite_Size	:= !Temp
	!OW_sprite_Count = 16

	print "Overworld sprite RAM:"
	print " $", hex(!OverworldSpriteBase), "-$", hex(!OverworldSpriteBase+((!Temp)*!OW_sprite_Count)-1)
	print " total $", hex((!Temp)*!OW_sprite_Count), " bytes"



; For game mode 0C (the OW loader)
;	3 bytes inserted at $00A0B3 by AMK
;	4 bytes inserted at $00A140 by Lunar Magic
;	4 bytes inserted at $00A149 by unknown source, probably Lunar Magic
;	4 bytes inserted at $00A153 by Lunar Magic
;	5 bytes inserted at $00A1A8 by unknown source, probably SA-1 patch or Lunar Magic





	pushpc
	org $008779
		NOP #3			; org: STA $420B (prevent layer 3 garbage)
	org $0087A7
		NOP #3			; org: STA $420B

	org $009329+($0B*2)
		dw LevelFade_Main
	org $009329+($0D*2)
		dw LevelToOverworld	; org: dw $9F6F
	org $009329+($0F*2)
		dw LevelFade_Item	; org: dw $9F37
	org $009329+($13*2)
		dw LevelFade_Main	; org: dw $9F37
	org $009329+($15*2)
		dw OverworldToLevel	; org: dw $9F6F

	org $009F37
		BRA $06 : NOP #6
	warnpc $009F3F


	org $00A134
	;	LDA #$0000		; coords for base OW position
	org $00A13B
	;	LDA #$0000
	org $00A153
	;	JSL LOAD		; org: LDA #$06 : STA $12 : JSR $85D2
	;	BRA $01
	;	NOP			; this removes the overworld border
		LDA #$06 : STA $12
		JSR $85D2
	org $00A165
	;	BRA $02 : NOP #2	; org: JSL $04D6E9
					; skip Lunar Magic's overworld layer 2 tilemap loader

	org $00A087			; start of game mode 0C (OW loader)
		JML LOAD		;\
		ReturnLoad:		; | org:; JSR $937D : LDA $7B9C
		RTS			; |
		NOP			;/

	LevelToOverworld:
		LDA #$01 : STA $6DAF
		LDA #$0F : STA !2100
		LDA #$0F : STA !Mosaic
		JSL MAIN
		INC $14
		LDA !CircleRadius
		CMP #$30 : BEQ .Done
		INC !CircleRadius
		RTS

		.Done
		INC !GameMode
		RTS

	OverworldToLevel:
		JSL MAIN
		INC $14
		LDA !CircleRadius : BEQ .Done
		DEC !CircleRadius
		RTS

		.Done
		LDA #$10 : STA !GameMode
		STZ $6DAF
		STZ !2100
		LDA #$FF : STA !Mosaic
		RTS

	LevelFade:
		.Item
		JSR .Main
		LDA !GameMode
		CMP #$10 : BNE .Return
		JSL SetCarriedItem
		RTS


		.Main
		LDY $6DAF
		LDA !GameMode
		CMP #$0B : BEQ .Slow
		LDA $741A : BNE .Quick

		.Slow
		LDA $13
		LSR A : BCC .Return
		LDA !2100
		CLC : ADC $9F2F,y
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
		EOR #$01
		STA $6DAF

		.Return
		RTS

		.QuickFadeTable
		db $01,$FE


	warnpc $00A1A6



	org $00A1C3
		JSL MAIN
		RTS
		NOP #3


	org $03BB20
		RTL			; org: STA $02
		NOP			; This messes with LM, so I'd better be careful

	org $04DD57
		RTS			; prevent layer 2 overworld tilemap from loading
	org $04DABA
		RTS			; prevent layer 2 event tilemap from loading


	org $049D07
		RTS			; org: LDA $7F837B
		NOP #3			; this removes the level name

	org $0485CF
		RTS			; org: JSL $00E2BD
		NOP #3			; remove sprite OW border tiles

	org $049878
		STZ $1A,x		; org: STA $1A,x : STA $1E,x
		STZ $1E,x

	org $05D89F
		NOP #3			; org: STA !Translevel

	org $05DBF2
		RTL			; org: PHB (prevent lives from showing on OW)


	org $05DDA0	; All levels start clear of initial flags
		db $01,$01,$01,$01,$01,$01,$01,$01	; 00-07
		db $01,$01,$01,$01,$01,$01,$01,$01	; 08-0F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 10-17
		db $01,$01,$01,$01,$01,$01,$01,$01	; 18-1F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 20-27
		db $01,$01,$01,$01,$01,$01,$01,$01	; 28-2F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 30-37
		db $01,$01,$01,$01,$01,$01,$01,$01	; 38-3F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 40-47
		db $01,$01,$01,$01,$01,$01,$01,$01	; 48-4F
		db $01,$01,$01,$01,$01,$01,$01,$01	; 50-57
		db $01,$01,$01,$01,$01,$01,$01,$01	; 58-5F


; insert new code here
	pullpc
	incsrc "Data/LevelList.asm"
	incsrc "Data/MapLightPoints.asm"
	incsrc "Data/Events.asm"

	incsrc "Zip.asm"
	incsrc "RenderHUD.asm"
	incsrc "RenderName.asm"
	incsrc "RenderCircle.asm"
	incsrc "Load.asm"
	incsrc "Player.asm"
	incsrc "CharMenu.asm"
	incsrc "OverworldSprites.asm"
	incsrc "Lighting.asm"
	incsrc "Sort_OAM.asm"





	SetCarriedItem:
		.P1
		LDY !P2Carry-$80 : BEQ ..nop1
		DEY
		LDA $3200,y : STA !HeldItemP1_num
		LDA !NewSpriteNum,y					;\
		CMP !HeldItemP1_customnum : BNE ..set			; |
		LDA !ExtraBits,y					; |
		CMP !HeldItemP1_extra : BNE ..set			; | if all these are the same, this sprite was carried from a PREVIOUS level
		LDA $33F0,y						; |
		CMP #$FF : BEQ ..done					; |
		CMP !HeldItemP1_ID : BEQ ..done				;/
		..set
		LDA !NewSpriteNum,y
		CMP #$32 : BEQ ..nop1
		STA !HeldItemP1_customnum
		LDA !ExtraBits,y : STA !HeldItemP1_extra
		LDA !ExtraProp1,y : STA !HeldItemP1_prop1
		LDA !ExtraProp2,y : STA !HeldItemP1_prop2
		REP #$20
		LDA !Level : STA !HeldItemP1_level
		SEP #$20
		LDA $33F0,y : STA !HeldItemP1_ID
		BRA ..done
		..nop1
		LDA #$FF : STA !HeldItemP1_num
		..done

		.P2
		LDY !P2Carry : BEQ ..nop2
		DEY
		LDA $3200,y : STA !HeldItemP2_num
		LDA !NewSpriteNum,y					;\
		CMP !HeldItemP2_customnum : BNE ..set			; |
		LDA !ExtraBits,y					; |
		CMP !HeldItemP2_extra : BNE ..set			; | if all these are the same, this sprite was carried from a PREVIOUS level
		LDA $33F0,y						; |
		CMP #$FF : BEQ ..done					; |
		CMP !HeldItemP2_ID : BEQ ..done				;/
		..set
		LDA !NewSpriteNum,y
		CMP #$32 : BEQ ..nop2
		STA !HeldItemP2_customnum
		LDA !ExtraBits,y : STA !HeldItemP2_extra
		LDA !ExtraProp1,y : STA !HeldItemP2_prop1
		LDA !ExtraProp2,y : STA !HeldItemP2_prop2
		REP #$20
		LDA !Level : STA !HeldItemP2_level
		SEP #$20
		LDA $33F0,y : STA !HeldItemP2_ID
		BRA ..done
		..nop2
		LDA #$FF : STA !HeldItemP2_num
		..done

		RTL




; VRAM map:
; 0x0000 / $0000	16 KiB BG1 GFX		256 8bpp characters (128x128 px)
; 0x4000 / $2000	16 KiB BG2 GFX		512 4bpp characters (128x512 px)
; 0x8000 / $4000	4 KiB BG1 tilemap	2 tilemaps, 64x32 tiles
; 0x9000 / $4800	4 KiB BG2 tilemap	2 tilemaps, 64x32 tiles, main part
; 0xA000 / $5000	2 KiB BG2 tilemap	1 tilemap, 32x32 tiles, HUD part
; 0xA800 / $5400	6 KiB tilemap cache	total 3 tilemaps
; 0xC000 / $6000	16 KiB sprite GFX	512 4bpp characters (128x512 px)



; HDMA:
; channel 0 - used for DMA during NMI
; channel 1 - FREE
; channel 2 - window
; channel 3 - main screen
; channel 4 - BG2 tilemap
; channel 5 - BG2 coordinates
; channel 6 - circle window
; channel 7 - FREE


; $0200
;	+0	main screen
;	+10	BG2 tilemap
;	+20	BG2 coordinates
;	+80	double buffer mirrors



	MAIN:
		LDA $14					;\
		AND #$1F				; |
		TAY					; | index RNG table
		DEC A					; |
		AND #$1F				; |
		TAX					;/
		JSL !Random				; get vanilla RN
		ADC !RNGtable,x				; add RNG from last frame
		ADC $13					; add true frame counter
		ADC $6DA2				;\
		ADC $6DA3				; |
		ADC $6DA4				; |
		ADC $6DA5				; | add player controller input
		ADC $6DA6				; |
		ADC $6DA7				; |
		ADC $6DA8				; |
		ADC $6DA9				;/
		ADC !P1MapXSpeed			;\ add player 1 speed
		ADC !P1MapYSpeed			;/
		ADC !P1MapX				;\ add player 1 position
		ADC !P1MapY				;/
		ADC !P2MapXSpeed			;\ add player 2 speed
		ADC !P2MapYSpeed			;/
		ADC !P2MapX				;\ add player 2 position
		ADC !P2MapY				;/
		STA !RNGtable,y				; store new RN
		STA !RNG				; most recently generated


		REP #$20					;\
		LDA #$2C04 : STA $4330				; |
		LDA #$0800 : STA $4340				; |
		LDA #$0F03 : STA $4350				; |
		LDA #$2641 : STA $4360				; |
		SEP #$20					; | set up HDMA
		STZ $4334					; |
		STZ $4344					; |
		STZ $4354					; |
		LDA.b #HDMA>>16					; |
		STA $4364					; |
		STA $4367					; |
		LDA #$78 : STA !HDMA				;/

		LDA #$33 : STA !2123
		LDA #$33 : STA !2125


		LDA #$40 : STA !AnimToggle


		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		LDA !GameMode
		CMP #$0E : BEQ .Light
		JSR $1E80
		BRA .Shared

		.Light
		LDA #$80 : STA $2200
		JSR !MPU_light

		.Shared
		REP #$30					;\
		LDX.w #HDMA_Window2				; |
		LDA !CircleTimer				; | source for window HDMA
		AND #$0001					; |
		BNE $03 : LDX.w #HDMA_Window1			; |
		STX !HDMA6source				;/

; $0200 -> adjust scanline (MainScreen + SubScreen)
; $0210 -> adjust scanline (BG2 Tilemap address)
; $0220 -> expand (BG2 coordinates)

		LDA !CircleTimer
		AND #$0001
		BEQ $03 : LDA #$0080
		TAX
		SEP #$20

		LDA !CharMenuTimer : STA $00
		LDA !CharMenu : BEQ ..20
		CMP #$01 : BEQ ..dynamic
		CMP #$05 : BNE ..40
		..inversedynamic
		LDA #$20
		SEC : SBC $00
		STA $00

		..dynamic
		LDA #$40
		SEC : SBC $00
		STA $0200,x
		STA $0210,x
		SBC #$20
		STA $0225,x
		LDA #$20 : STA $0220,x
		LDA #$01 : STA $022A,x
		STZ $022F,x
		REP #$20
		STZ $0226,x
		LDA $00
		AND #$00FF
		DEC A
		STA $0228,x
		LDA $1A : STA $022B,x
		LDA $1C : STA $022D,x
		BRA ..updatemirrors

		..40						;\
		LDA #$40					; |
		STA $0200,x					; | all initial scanline counts 0x40
		STA $0210,x					; |
		STA $0220,x					;/
		BRA ..setmain
		..20						;\
		LDA #$20					; |
		STA $0200,x					; | all initial scanline counts 0x20
		STA $0210,x					; |
		STA $0220,x					;/
		..setmain					;\ set scanline count for BG2 coords (map part of screen)
		LDA #$01 : STA $0225,x				;/
		STZ $022A,x					; end BG2 coords table
		REP #$20					;\
		LDA $1A : STA $0226,x				; | make sure map part has the correct BG2 coords
		LDA $1C : STA $0228,x				;/

		..updatemirrors
		TXA
		ORA #$0200
		STA !HDMA3source
		CLC : ADC #$0010
		STA !HDMA4source
		CLC : ADC #$0010
		STA !HDMA5source

		SEP #$30					; all regs 8-bit
		INC !CircleTimer				; circle timer +1


		JSL !BuildOAM
		RTL


		.SA1
		PHB						;\ wrapper start
		PHP						;/

		STZ !RAMcode_offset
		STZ !RAMcode_offset+1
		STZ !RAMcode_flag
		STZ !RAMcode_flag+1
		STZ !MapOAMindex
		STZ !MapOAMindex+1
		STZ !MapOAMcount
		STZ !MapOAMcount+1



; light intensity = L / d ^ 2
; L = light constant
; d = distance to camera center

; for each light source point, multiply its RGB values with light intensity for that point
; then add all RGB values together and set light values to that
; (make sure to exclude the HUD)


		JSR KillVR3

		JSL HandleZips

		PHK : PLB				; get bank
		SEP #$20
		LDA !WarpPipe : BEQ .RenderName
		REP #$30
		%LoadHUD(SelectPressed)
		JSR RenderHUD
		SEP #$30
		BRA .UpdateHUD

		.RenderName
		JSR RenderName

		.UpdateHUD
		LDA !MapUpdateHUD+0
		ORA !MapUpdateHUD+1
		ORA !MapUpdateHUD+2
		ORA !MapUpdateHUD+3 : BEQ +
		JSR ReloadP1Color
		JSR ReloadP2Color
		+
		%UpdateHUD(0)
		%UpdateHUD(1)
		%UpdateHUD(2)
		%UpdateHUD(3)
		REP #$30




		JSR CalcLightPoints


	; draw coin hoard counter on HUD
		.DrawCoinHoardCounter
		LDA #$0314 : STA $00
		STZ $0E							; has not yet drawn anything

		LDA !CoinHoard : STA $0A				;\
		LDA !CoinHoard+2					; | setup
		AND #$00FF : STA $0C					; |
		TAY							;/
		BEQ ..skipfirst						;\
		LDX #$0000						; |
		LDA $0A							; |
	-	CPY #$0002 : BCS +					; |
		CMP #$86A0 : BCS +					; | calculate 100000s digit
		CPY #$0001 : BEQ ..draw100000s				; |
	+	SBC #$86A0						; |
		INX							; |
		DEY : BNE -						;/
		..draw100000s						;\
		STA $0A							; |
		STY $0C							; | draw 100000s digit
		TXA : JSR DrawCoinDigit					; |
		LDY $0C							; |
		..skipfirst						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

		LDX #$0000						;\
		LDA $0A							; |
		LDY $0C : BNE ..calcsecond				; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$2710 : BCC ..skipsecond				; |
		..calcsecond						; | calculate 10000s digit
	-	CMP #$2710 : BCS +					; |
		CPY #$0001 : BCC ..draw10000s				; |
	+	SBC #$2710						; |
		BCS $01 : DEY						; |
		INX							; |
		BRA -							;/
		..draw10000s						;\
		STA $0A							; | draw 10000s digit
		TXA : JSR DrawCoinDigit					; |
		..skipsecond						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$03E8 : BCC ..skipthird				; |
		..calcthird						; | calculate 1000s digit
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX							; |
		BRA -							;/
		..draw1000s						;\
		STA $0A							; | draw 1000s digit
		TXA : JSR DrawCoinDigit					; |
		..skipthird						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcfourth				; |
		CMP #$0064 : BCC ..skipfourth				; |
		..calcfourth						; | calculate 100s digit
	-	CMP #$0064 : BCC ..draw100s				; |
		SBC #$0064						; |
		INX							; |
		BRA -							;/
		..draw100s						;\
		STA $0A							; | draw 100s digit
		TXA : JSR DrawCoinDigit					; |
		..skipfourth						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/

		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcfifth				; |
		CMP #$000A : BCC ..skipfifth				; |
		..calcfifth						; | calculate 10s digit
	-	CMP #$000A : BCC ..draw10s				; |
		SBC #$000A						; |
		INX							; |
		BRA -							;/
		..draw10s						;\
		STA $0A							; | draw 10s digit
		TXA : JSR DrawCoinDigit					; |
		..skipfifth						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDA $0A : JSR DrawCoinDigit				; draw 1s digit


	; draw yoshi coin counter on HUD
		.DrawYoshiCoinCounter
		LDA #$101E : STA $00					;\ setup
		LDA !YoshiCoinCount : STA $0A				;/
		STZ $0E
		LDX #$0000						;\
		CMP #$03E8 : BCC ..skipfirst				; |
	-	CMP #$03E8 : BCC ..draw1000s				; |
		SBC #$03E8						; |
		INX : BRA -						; | 1000s
		..draw1000s						; |
		STA $0A							; |
		TXA : JSR DrawCoinDigit					; |
		..skipfirst						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcsecond				; |
		CMP #$0064 : BCC ..skipsecond				; |
		..calcsecond						; |
	-	CMP #$0064 : BCC ..draw100s				; | 100s
		SBC #$0064						; |
		INX : BRA -						; |
		..draw100s						; |
		STA $0A							; |
		TXA : JSR DrawCoinDigit					; |
		..skipsecond						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDX #$0000						;\
		LDA $0A							; |
		BIT $0E : BMI ..calcthird				; |
		CMP #$000A : BCC ..skipthird				; |
		..calcthird						; |
	-	CMP #$000A : BCC ..draw10s				; | 10s
		SBC #$000A						; |
		INX : BRA -						; |
		..draw10s						; |
		STA $0A							; |
		TXA : JSR DrawCoinDigit					; |
		..skipthird						;/
		LDA $00							;\
		CLC : ADC #$0005					; | X+5
		STA $00							;/
		LDA $0A : JSR DrawCoinDigit				; 1s


	.Objects
		LDA !CharMenu
		AND #$00FF : BNE ..done

		..cameraspeed
		LDA !MapEvent : BEQ ..speed4
		..speed2
		LDA #$0002
		STA !MapCameraSpeedX
		STA !MapCameraSpeedY
		BRA +
		..speed4
		LDA #$0004
		STA !MapCameraSpeedX
		STA !MapCameraSpeedY
		+

		LDA !WarpPipe						;\
		AND #$00FF : BEQ ..nowarppipe				; |
		JSR Player						; | players are processed first when a warp pipe is on-screen
		JSR OverworldSprites					; |
		BRA ..drawstuff						;/

		..nowarppipe						;\
		JSR OverworldSprites					; | otherwise, sprites first to let them control the camera during events
		JSR Player						;/

		..drawstuff
		PHP
		SEP #$20
		STZ !P1MapGhost
		STZ !P2MapGhost
		STZ !MapLockCamera		; KEEP THIS ONE WHEN YOU REMOVE GHOST ZONES
		PLP
		JSR DrawSprites			; separate call to let sprites control the camera
		JSR Sort_OAM
		..done


	.Circle
		LDA !CircleForceCenter
		STZ !CircleForceCenter
		BEQ ..calccenter
		LDA #$0080
		STA !CircleCenterX
		STA !CircleCenterY
		BRA ..process

		..calccenter
		LDA !P1MapX
		CLC : ADC #$0008
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA !CircleCenterX
		LDA !P1MapY
		CLC : ADC #$0008
		SEC : SBC $1C
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA !CircleCenterY

		..process
		LDA !CircleRadius
		BPL $03 : LDA #$0000
		CMP #$0030
		BCC $03 : LDA #$0030
		STA !CircleRadius
		PHA
		STZ $2250
		STA $2251
		CLC
		JSL !GetRoot : STA $2253
		NOP : BRA $00
		LDA $2307 : STA !CircleRadius
		JSR RenderCircle
		JSR RenderCircle_Cutscene
		PLA : STA !CircleRadius
		..done


		SEP #$10				;\ regs: A 16-bit, index 8-bit
		REP #$20				;/
		LDA $1A : STA $1E			;\ layer 2 positions
		LDA $1C : STA $20			;/

		SEP #$20				; 8-bit A

		LDA #$00 : STA !DizzyEffect		; cancel dizzy
		LDA #$08 : TRB !2105
		LDA #$1D : STA !MainScreen
		STZ !SubScreen

		JSL CLEAR_MSG_SA1

		LDA !GameMode				;\
		CMP #$0E : BEQ +			; |
		STZ $15					; |
		STZ $16					; |
		STZ $17					; |
		STZ $18					; |
		STZ $6DA2				; | only accept input in game mode 0E
		STZ $6DA3				; |
		STZ $6DA4				; |
		STZ $6DA5				; |
		STZ $6DA6				; |
		STZ $6DA7				; |
		STZ $6DA8				; |
		STZ $6DA9				; |
		+					;/





	Controls:
		LDA !CharMenu : BEQ .NoCharMenu
		JMP CharMenu
		.NoCharMenu

		LDA !WarpPipe : BEQ $03 : JMP .Return
		LDX !Translevel : BNE .Level
		LDA #$14
		STA !MapCheckpointX
		STA !MapCheckpointTargetX
		BRA .CheckPipe


	; X = translevel num / index
		.Level
		LDA !MapCheckpointX
		CMP !MapCheckpointTargetX
		BEQ ..same
		BCS ..dec
	..inc	CLC : ADC #$04
	..dec	DEC #2
		STA !MapCheckpointX
		..same


		LDA $6DA8
		AND #$30 : BEQ ..noLR
		LDA !MapCheckpointTargetX : BNE ..0
		LDA #$14 : STA !MapCheckpointTargetX
		BRA ..noLR
	..0	STZ !MapCheckpointTargetX
		..noLR

		LDA $6DA6 : BPL .CheckPipe
		BRA .LoadLevel

		.CheckPipe
		LDA $6DA6
		AND #$20 : BNE ..openpipe
		JMP .P1OpenMenu
		..openpipe
		LDA #$03 : STA !SPC4
		REP #$10
		JSR GetSpriteIndex
		JSR ResetSprite
		LDA #$01 : STA !OW_sprite_Num,x
		SEP #$10
		LDA #$30 : STA !P1MapZSpeed
		LDA #$38 : STA !P2MapZSpeed
		LDA !P2MapX : STA !WarpPipeP2X
		LDA !P2MapX+1 : STA !WarpPipeP2X+1
		LDA !P2MapY : STA !WarpPipeP2Y
		LDA !P2MapY+1 : STA !WarpPipeP2Y+1
		STZ !WarpPipeTimer
		BRA .P1OpenMenu

	; X still has to be translevel num here
		.LoadLevel
		LDA #$15 : STA !GameMode
		LDA #$02 : STA !SPC1
		LDA #$80 : STA !SPC3
		REP #$20
		LDA !P1MapX : STA !SRAM_overworldX
		LDA !P1MapY : STA !SRAM_overworldY
		SEP #$20
		BIT !LevelTable1,x : BVC ..nocheckpoint
		LDA !MapCheckpointTargetX : BEQ ..nocheckpoint
		..checkpoint
		LDA #$01 : BRA ..w
		..nocheckpoint
	;	LDA !LevelTable1,x
	;	AND.b #$40^$FF : STA !LevelTable1,x
		LDA #$00
	..w	STA !LoadCheckpoint
		STA $73CE

		JSL !SaveGame

		.Return
		PLP
		PLB
		RTL

		.P1OpenMenu
		LDA $6DA6
		AND #$10 : BEQ ..done
		LDA !CharMenu : BNE ..done
		INC !CharMenu
		LDX #$00 : BRA .OpenMenu
		..done

		.P2OpenMenu
		LDA $6DA7
		AND #$10 : BEQ ..done
		LDA !CharMenu : BNE ..done
		INC !CharMenu
		LDX.b #(!P2MapX)-(!P1MapX) : BRA .OpenMenu
		..done

		PLP
		PLB
		RTL


		.OpenMenu
		STX !SelectingPlayer
		LDA !P1MapX,x
		SEC : SBC $1A
		STA !CharMenuCurrentPlayerX
		LDA !P1MapY,x
		SEC : SBC $1C
		STA !CharMenuCurrentPlayerY
		TXA
		EOR.b #(!P2MapX)-(!P1MapX)
		TAY
		LDA !P1MapX,y
		SEC : SBC $1A
		STA !CharMenuOtherPlayerX
		LDA !P1MapY,y
		SEC : SBC $1C
		STA !CharMenuOtherPlayerY
		LDA !P1MapDirection,y
		AND #$01
		BEQ $02 : LDA #$40
		STA !CharMenuOtherPlayerP
		LDA !P1MapChar,x : STA !CharMenuCursor
		JSR ReloadStartButtons
		JSR InitCharMenu
		PLP
		PLB
		RTL




	RemoveP2:
		PHP
		SEP #$20
		LDA #$00 : STA !MultiPlayer
		REP #$30
		%LoadHUD(NameP2)
		JSR ResetHUD
		%LoadHUD(PortraitP2)
		JSR ResetHUD
		%LoadHUD(SwitchP2)
		JSR ResetHUD
		%LoadHUD(JoinP2)
		JSR RenderHUD
		PHB
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		JSL !GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.w #Palette+($79*2) : STA !CGRAMtable+$02,y
		LDA.w #Palette>>16 : STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$79 : STA !CGRAMtable+$05,y
		PLB
		PLP
		RTS

	AddP2:
		PHP
		SEP #$20
		LDA #$01 : STA !MultiPlayer
		REP #$30
		%LoadHUD(NameP2)
		LDA !Characters
		AND #$000F
		ASL A
		TAX
		LDA NameOffset,x : STA $00
		JSR RenderP2Name
		%LoadHUD(PortraitP2)
		LDA !Characters
		AND #$000F
		ASL #3
		ADC $00
		STA $00
		JSR RenderHUD
		%LoadHUD(SwitchP2)
		JSR RenderHUD
		JSR ReloadP2Color
		PLP
		RTS

	ReloadStartButtons:
		PHP
		REP #$20
		SEP #$10
		.P1
		%LoadHUD(StartSolidP1)
		LDX !CharMenu
		CPX #$01 : BNE ..load
		LDX !SelectingPlayer : BNE ..load
		LDA $00
		CLC : ADC #$000C
		STA $00
		..load
		JSR RenderHUD
		.P2
		%LoadHUD(StartSolidP2)
		LDX !CharMenu
		CPX #$01 : BNE ..load
		LDX !SelectingPlayer : BEQ ..load
		LDA $00
		CLC : ADC #$000C
		STA $00
		..load
		JSR RenderHUD
		PLP
		RTS

	ReloadSelectArea:
		%LoadHUD(WarpPipe)
		JSR RenderHUD
		%LoadHUD(HomeText)
		JSR RenderHUD
		%LoadHUD(SelectSolid)
		JSR RenderHUD
		RTS

	ReloadP1Name:
		%LoadHUD(NameP1)
		LDA !P1MapChar
		AND #$000F
		ASL A
		TAX
		LDA NameOffset,x : STA $00
		JSR RenderHUD
		RTS

	ReloadP1Color:
		PHB
		PHP
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		REP #$20
		JSL !GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.l !P1MapChar
		AND #$000F
		ASL A
		ADC.w #Palette_CharName
		STA !CGRAMtable+$02,y
		LDA.w #Palette_CharName>>16 : STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$78 : STA !CGRAMtable+$05,y
		REP #$20
		PLP
		PLB
		RTS

	ReloadP1Portrait:
		%LoadHUD(PortraitP1)
		LDA !P1MapChar
		AND #$000F
		ASL #3
		ADC $00
		STA $00
		JSR RenderHUD
		RTS

	ReloadP2Color:
		PHB
		PHP
		SEP #$10
		LDY.b #!VRAMbank
		PHY : PLB
		REP #$20
		JSL !GetCGRAM
		LDA #$0002 : STA !CGRAMtable+$00,y
		LDA.l !MultiPlayer
		AND #$00FF : BNE .CharColor
		LDA.w #Palette+($79*2) : STA !CGRAMtable+$02,y
		LDA.w #Palette>>16 : BRA .Write

		.CharColor
		LDA.l !P2MapChar
		AND #$000F
		ASL A
		ADC.w #Palette_CharName
		STA !CGRAMtable+$02,y
		LDA.w #Palette_CharName>>16
		.Write
		STA !CGRAMtable+$04,y
		SEP #$20
		LDA #$79 : STA !CGRAMtable+$05,y
		PLP
		PLB
		RTS

	NameOffset:
		dw $0098/2,$00B8/2,$00D8/2
		dw $0898/2,$08B8/2,$08D8/2




	KillVR3:
		LDA #$00 : STA !VRAMbase+!VRAMtable+$2FF
		REP #$30
		LDA.w #$02FE
		LDX.w #!VRAMtable+$2FF
		LDY.w #!VRAMtable+$2FE
		MVP $40,$40
		RTS



	DrawCoinDigit:
		; A = digit
		TAY
		LDA !OAMindex_p3 : TAX
		TYA
		CLC : ADC #$3E20
		STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		DEC $0E				; n flag set
		CPY #$0001			;\ "1" digit is 1px slimmer
		BNE $02 : DEC $00		;/

		TXA
		LSR #2
		TAX
		LDA #$0000 : STA !OAMhi_p3,x
		INX
		TXA
		ASL #2
		STA !OAMindex_p3
		RTS


; input:
;	$00 = target X
;	$02 = target Y
; output:
;	BEQ -> camera at target, BNE -> camera not at target

	UpdateCamera:
		LDA $00
		BPL $02 : STZ $00
		LDA $02
		BPL $02 : STZ $02
		LDA !MapCameraSpeedX
		ASL A : STA $04
		LDA !MapCameraSpeedY
		ASL A : STA $06

		.MoveX
		LDA $1A
		SEC : SBC $00
		CLC : ADC !MapCameraSpeedX
		CMP $04 : BCC ..snapX
		LDA $1A
		CMP $00 : BCS ..decX
		..incX
		CLC : ADC !MapCameraSpeedX
		BRA ..storeX
		..decX
		SEC : SBC !MapCameraSpeedX
		BRA ..storeX
		..snapX
		LDA $00
		..storeX
		STA $1A

		.MoveY
		LDA $1C
		SEC : SBC $02
		CLC : ADC !MapCameraSpeedY
		CMP $06 : BCC ..snapY
		LDA $1C
		CMP $02 : BCS ..decY
		..incY
		CLC : ADC !MapCameraSpeedY
		BRA ..storeY
		..decY
		SEC : SBC !MapCameraSpeedY
		BRA ..storeY
		..snapY
		LDA $02
		..storeY
		STA $1C

		.CapCameraX
		LDA $1A : BPL ..pos
		LDA #$0000 : STA $1A
	..pos	CMP #$0500 : BCC ..done
		LDA #$0500 : STA $1A
		..done

		.CapCameraY
		LDA $1C : BPL ..pos
		LDA #$0000 : STA $1C
	..pos	CMP #$031F : BCC ..done
		LDA #$031F : STA $1C
		..done

		LDA $1A
		SEC : SBC $00
		BNE .Return
		LDA $1C
		SEC : SBC $02

		.Return
		RTS



macro CharDyn(file, tiles, source, dest)
	dw <tiles>*$20
	db <file>
	dw <source>*$20
	dw <dest>*$10+$6000
endmacro


	DropoutTilemap:
		db $20,$57,$83,$31	; D
		db $28,$57,$91,$31	; R
		db $30,$57,$8E,$31	; O
		db $38,$57,$8F,$31	; P
		db $48,$57,$8E,$31	; O
		db $50,$57,$94,$31	; U
		db $58,$57,$93,$31	; T
		.End



	HDMA:

	; indirect -> $2126 + $2127, B = K
	.Window1
		db $F0 : dw !CircleTable1
		db $F0 : dw !CircleTable1+$E0
		db $00

	.Window2
		db $F0 : dw !CircleTable2
		db $F0 : dw !CircleTable2+$E0
		db $00




	namespace off


