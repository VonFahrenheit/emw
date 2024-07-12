


; anatomy of a level code:
; (all bank bytes are the same as levelx)
; (any pointer can be skipped by replacing it with a 0 word)
;
; levelx:		; pointed to from a single table of 24-bit addresses, one for each level
;	dw .Init	; called by SNES from LoadLevel (SNES thread 5)
;	dw .Main	; called by SA-1 from GameMode14 (accelerator mode; SNES will wait)
;	dw .Modules	; pointer to HDMA modules that this level will use, loaded right before .Init is executed
;
;	.Init
;	; init code here, executed by SNES
;
;	.Main
;	; main code here, executed by SA-1 (DP 0)
;
;	.Modules	; HDMA modules, read during level load, but their code pointers are executed on level load and at end of camera routine
;..2	dl pointer
;..3	dl pointer
;..4	dl pointer
;..5	dl pointer
;..6	dl pointer
;..7	dl pointer
;
;	.Data
;	; any level-specific data goes here (not pointed to)








level1:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $FFFF

		LDA #$09
		STA !BG2ModeH
		STA !BG2ModeV
		RTL

	.Main
		REP #$20
		LDA $1A
		CMP #$0DA0 : BCC ..return
		LDX #$01 : STX !EnableVScroll
		..return
		RTL

	.Modules
	..2	dl 0
	..3	dl 0
	..4	dl Gradient_BlueSky_Module
	..5	dl 0
	..6	dl 0
	..7	dl 0


level2:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		DEC !RightExitLimitD+1			; easiest way to enable full exit on a level border

		LDA !DoorCounter : BNE +
		LDA #$80
		STA !P2Entrance-$80
		STA !P2Entrance
		+

	.Graphics
		LDA #$01 : STA !GlobalLight1
		DEC !GlobalLightMixPrev
		LDA !TranslevelFlags+$00 : STA !GlobalLightMix
		LDA #$E1 : STA !MsgPal
		RTL


	.Main
	if !Debug = 1					;\
	LDA $6DA6					; |
	AND #$20 : BEQ +				; |
	REP #$20					; | select to enter doors cheat
	JSL EXIT_GetExitNum_1				; |
	+						; |
	endif						;/


		LDA $1B
		CMP #$02 : BCS +
		JSL BorderExit_Down
			dw $0000,$0200
			dw $02E|$4000
		BRA ++

	+	JSL BorderExit_Down
			dw $1000,$1060
			dw $02E
		++



		.ReloadSprites
		JSL ReloadSprites

		.MorningLight
		LDA !TranslevelFlags+$00
		CMP #$20 : BEQ +
		LDA $14 : BNE +
		INC !TranslevelFlags+$00
	+	LDA !TranslevelFlags+$00 : STA !GlobalLightMix

		RTL


	.Modules
	..2	dl 0
	..3	dl Gradient_BlueSky_Module
	..4	dl 0
	..5	dl 0
	..6	dl 0
	..7	dl 0




; why is SBG not just a sprite?
; the extra byte can determine which one it is
; that would make it much easier to use, wouldn't it?

; no, eric, that's not right
; then you have to place one by each entrance and manage each SBG object to make sure you don't get dupes
; there's also no reason it should be sprite slot contingent

; using it like this is more technical, true, but also more convenient

; however... i should move SBG into a shared file somewhere
; then turn them into JSL's: one init that will load the dynamo and one main that will display the tilemap (set to !HDMAptr)
; a new SBG can even be loaded during a level simply by calling init


level3:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $FFFF

		JSL BorderExit_Right
			dw $0000,$FFFF
			dw $BEA7

		LDA #$06 : STA !PalsetStart			; exclude palette F
		LDA #$E1 : STA !MsgPal				; portrait: palettes E and F
		LDA #$03*4 : STA !TextPal			;

		JSL UpdateGFX_NoOffset_fromstruct		; upload castle (sprite BG)
			dw .Dynamo
			dw !File_Sprite_BG_1

		RTL


	.Main
		REP #$20					; A 16-bit
		LDA.w #.HDMA : STA !HDMAptr			;\ HDMA code
		LDA.w #.HDMA>>8 : STA !HDMAptr+1		;/

		LDA !MsgTrigger : BNE +				;\
		LDA #$001F : STA !MainScreen			; | everything on main, nothing on sub
		+						;/

		RTL						; > return


	.Modules
	..2	dl 0
	..3	dl Gradient_BlueSky_Module
	..4	dl 0
	..5	dl 0
	..6	dl FlowerField
	..7	dl 0




	.HDMA

		; BG3 + SBG code
		REP #$30
		LDA !MsgTrigger : BNE ..return			; skip
		INC !Level+2					;\
		LDA !Level+2					; |
		LSR A : ADC $1A					; |
		LSR #3 : STA $22				; | BG3 position
		LDA $1C						; |
		LSR #2 : ADC #$0078				; |
		STA $24						;/

		..spritebg					;\
		LDA #$2000					; |
		SEC : SBC $1A					; |
		LSR #5						; |
		SEC : SBC #$0008				; |
		AND #$01FF					; |
		EOR #$0100					; |
		STA $00						; | draw castle (sprite BG)
		STA $0C						; |
		LDA.w #.Tilemap : STA $02			; |
		SEP #$30					; |
		LDA #$14 : STA $01				; |
		LDA #$20 : STA $0E				; |
		PHB : PHK : PLB					; |
		JSL DrawSpriteBG				; |
		PLB						;/

		..return
		RTL


		.Tilemap
		db $00,$00,$EE,$0F
		db $08,$00,$EE,$4F
		db $00,$08,$EF,$0F
		db $08,$08,$EF,$0F
		db $00,$10,$EF,$0F
		db $08,$10,$EF,$0F
		db $00,$18,$EF,$0F
		db $08,$18,$EF,$0F



		.Dynamo
		dw ..end-..start
		..start
		dw $0040
		dl $20*2
		dw $7EE0
		..end






level4:
	dw .Init
	dw .Main
	dw .Modules
	dw .RoomPointers

	.Init
		INC !LockBox
		DEC !HardBoxBorders
		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $FFFF

		JSL BorderExit_Right
			dw $0000,$FFFF
			dw $BEA7

		LDA $94+1
		CMP #$1C : BCS ..return
		LDA #$04 : STA !SpriteEraseMode			; disable camera box sprite erase
		..return
		RTL

	.Main
		LDA #$02 : STA !GlobalLight2			; fade into sunset
		LDA $1B						;\
		CMP #$1D : BCS +				; | advance light as player proceeds in level
		CMP !GlobalLightMix : BCC +			; > can't go back
		STA !GlobalLightMix				; |
		+						;/

		.HandlePipe
		LDA #$20 : STA $64
		..p1
		LDA !P2Status : BNE ..p2
		LDA !P2Pipe : BNE ..enterpipe
		..p2
		LDA !P2Status-$80 : BNE ..done
		LDA !P2Pipe-$80 : BEQ ..done
		..enterpipe
		STZ $64
		LDA #$40 : STA !SPC4				; dizzy OFF!! SFX
		..done

		JSL DIZZY_STARS


		.SecretWall
		..p1
		LDA !P2Status-$80 : BNE ..p2
		LDA !P2XPosHi-$80
		CMP #$0E : BNE ..p2
		LDA !P2XSpeed-$80 : BPL ..p2
		CMP #$E8 : BCC ..secret
		..p2
		LDA !P2Status : BNE ..wall
		LDA !P2XPosHi
		CMP #$0E : BNE ..wall
		LDA !P2XSpeed : BPL ..wall
		CMP #$E8 : BCS ..wall
		..secret
		LDA $1C
		CMP #$B0 : BCC ..wall
		LDA #$8B
		LDY #$02 : BRA ..update
		..wall
		LDA #$A5
		LDY #$05
		..update
		STA $40C800+($1C0*$0E)+$15E
		STA $40C800+($1C0*$0E)+$16E
		TYA
		STA $41C800+($1C0*$0E)+$15E
		STA $41C800+($1C0*$0E)+$16E


		.SpawnFuzzy
		LDX !Room
		LDA .SpawnRate,x
		CMP #$FF : BEQ ..done
		AND $14 : BNE ..done
		LDY .SpawnSide,x
		; Y = 0 to spawn on left side, Y = 2 to spawn on right side, otherwise spawn side is determined by camera movement
		LDX #$0E					; don't use all slots
		..loop
		LDA !SpriteStatus,x : BEQ ..spawn
		DEX : BPL ..loop
		BRA ..done
		..spawn
		LDA !RNG
		AND #$F0
		CLC : ADC $1C
		CLC : ADC $7888
		STA !SpriteYLo,x
		LDA $1D
		ADC $7889
		STA !SpriteYHi,x
		CPY #$00 : BEQ ..getx
		CPY #$02 : BEQ ..getx
		LDY #$00
		LDA !CameraXDelta
		BEQ ..random
		BMI ..getx
		LDY #$02 : BRA ..getx
		..random
		LDA !RNG
		AND #$02 : TAY
		..getx
		REP #$20
		LDA $1A
		CLC : ADC .SpawnX,y
		SEP #$20
		STA !SpriteXLo,x
		XBA : STA !SpriteXHi,x
		LDA #$01 : STA !SpriteStatus,x
		LDA #$2D : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		JSL !ResetSprite
		..done


		LDA $94+1
		CMP #$1D : BCS .Return

		.Return
		RTL



	.SpawnRate
	db $FF,$9F,$3F,$0F,$FF,$FF,$FF				; based on which part of the level the camera is on
	.SpawnSide
	db $FF,$FF,$FF,$02,$FF,$FF,$FF
	.SpawnX
	dw $FFE0
	dw $0120




	.Modules
	..2	dl 0
	..3	dl MountainRange
	..4	dl 0
	..5	dl 0
	..6	dl DizzyEffect_BG1
	..7	dl DizzyEffect_BG2


	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	    X   Y  W  H
		;		    |   |  |  |
		;		    V   V  V  V
		.BoxTable
		.Box0	%CameraBox($00, 0, $1C, 1)
		.Box1	%CameraBox($00, 0, $1C, 1)
		.Box2	%CameraBox($00, 0, $1C, 1)
		.Box3	%CameraBox($00, 0, $1C, 1)
		.Box4	%CameraBox($1D, 0, 1, 0)
		.Box5	%CameraBox($1D, 1, 1, 0)
		.Box6	%CameraBox($1F, 0, 0, 1)

		.ScreenMatrix
		;   00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F  10  11  12  13  14  15  16  17  18  19  1A  1B  1C  1D  1E  1F
		db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$00,$00,$00,$04,$04,$06
		db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03,$03,$03,$00,$00,$00,$05,$05,$06






level5:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $FFFF

		DEC !RightExitLimitD+1


		..graphics
		LDA #$02 : STA !GlobalLight1
		DEC !GlobalLightMixPrev
		LDA.b #$51*2 : STA !LightIndexStart
		LDA.b #$EF*2 : STA !LightIndexEnd
		LDA.b #$EF*2>>8 : STA !LightIndexEnd+1

		LDA #$06 : STA !PalsetStart
		LDA #$D1 : STA !MsgPal

		LDA #$1F : STA !MainScreen
		STZ !SubScreen
		LDA #$01 : STA !BG2ModeH	; BG2 HScroll = 40%

		.UploadDynamo
		JSL UpdateGFX_NoOffset_fromstruct
			dw .SunDynamo
			dw !File_Sprite_BG_1

		RTL


		.SunDynamo
		dw ..end-..start
		..start
		dw $0040
		dl $20*$00
		dw $7E90
		dw $0040
		dl $20*$10
		dw $7F90
		..end



	.Main
		LDA #$02 : JSL SearchSprite_Custom : BMI +
		LDA !ExtraBits,x
		AND #$04 : BEQ +
		LDA !ExtraProp1,x
		CMP #$02 : BNE +
		STZ !SpriteDir,x
		JSL TALK_BOX
			db 0 : dw !MSG_CastleRex_Villager
			dw $0070,$00E0 : db $70,$FF
		+
		LDA.b #.HDMA : STA !HDMAptr
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL


	.HDMA
		LDA #$3060 : STA $00
		LDA.w #.SunTilemap : STA $02
		LDA #$0002 : STA $0D
		LDA.w #.SunTilemap_end-.SunTilemap : STA $0E
		JSL DrawSpriteBG
		RTL

		.SunTilemap
		db $00,$00,$E9,$0F
		db $08,$00,$E9,$4F
		db $00,$10,$E9,$8F
		db $08,$10,$E9,$CF
		..end


	.Modules
	..2	dl 0
	..3	dl 0
	..4	dl MountainTopsWithClouds
	..5	dl 0
	..6	dl 0
	..7	dl 0




; $0400-$06FF: reserved
; $0700 - red HDMA table
; $0800 - green HDMA table
; $0900 - blue HDMA table
; $0A00 - BG2 Hscroll HDMA table
; $0A80 - reserved

level6:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $FFFF

		DEC !RightExitLimitD+1


		JSL UpdateGFX_NoOffset_fromstruct
			dw .BigMaskDyn
			dw !File_Wizrex

		JSL UpdateGFX_NoOffset_fromstruct
			dw level5_SunDynamo
			dw !File_Sprite_BG_1

		LDA #$17 : STA !MainScreen			;\ main/sub screen settings
		STZ !SubScreen					;/
		LDA #$FF : STA !PalsetF				;\ lock palsetF for the sun BG
		LDA #$06 : STA !PalsetStart			;/
		LDA #$02 : STA !GlobalLight1			;\
		LDA #$03 : STA !GlobalLight2			; |
		LDA #$40 : STA !LightIndexStart			; | initial shader settings
		LDA #$01 : STA !LightIndexStart+1		; |
		LDA #$E0 : STA !LightIndexEnd			; |
		LDA #$01 : STA !LightIndexEnd+1			;/

		LDA #$EE : STA !HDMA4mem			;\ initial gradient positions
		LDA #$D0 : STA !HDMA6mem			;/

		PHB						;\
		LDA.b #!PaletteCacheHSL>>16			; |
		PHA : PLB					; |
		REP #$30					; |
		LDY.w #!File_level06_night			; |
		JSL GetFileAddress				; | cache the HSL-formatted night time palette
		LDY #$017E					; |
	-	LDA [!FileAddress],y : STA.w !PaletteCacheHSL,y	; |
		DEY #2 : BPL -					; |
		SEP #$30					; |
		PLB						;/

		INC !Level+4					; generate a tick
		LDA.b #.HDMA : STA !HDMAptr
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

		JSL level5_UploadDynamo

		RTL



	.BigMaskDyn
		dw ..end-..start
		..start
		%generic_dynamo(4, $104, $1CA)
		%generic_dynamo(4, $114, $1DA)
		%generic_dynamo(4, $124, $1EA)
		%generic_dynamo(4, $134, $1FA)
		..end


; updates:
;
; 2 frame:	mix HSL color (even frames)
; 2 frame:	upload HSL color (odd frames)
;
; 1 tick:	+1 to green stretch (to a maximum scanline count of 0x26, which is a stretch of 0x11)
; 1 tick:	red scroll -1, to a minimum of -x100 (starts at 0xEE)
; 2 tick:	sun X-1, Y+1 (if timer => 0xA0, don't draw sun)
; 2 tick:	blue scroll -1, to a minimum of 0 (starts at 0xD0)
; 4 tick:	$00A2 = .BGColors,[timer/4*2]
; 8 tick:	global light mix = tick/8, to a max of 0x20
; 16 tick:	all color planes in $00A4-$00B3 = (timer-0x108)/16, clamped to 0-31
; 


	.Main
		; TICK CONTROL
		REP #$20
		LDA $1A
		LSR #3
		CMP !Level+2 : BCC + : BEQ +
		STA !Level+2 : BRA ++

	+	LDA $14
		AND #$001F : BNE +
		INC !Level+2		; timer+1
	++	INC !Level+4		; generate new tick
	+	SEP #$20

		.CarriedMask
		LDA !TranslevelFlags : BNE ..done
		LDA $1A
		ORA $1B : BEQ ..done
		LDA !P2YPosHi-$80 : BEQ ..done
		INC !TranslevelFlags
		REP #$20
		LDA #$FFE0 : STA $00
		LDA #$00D0 : STA $02
		SEP #$20
		LDA #$06 : JSL SpawnSprite_Custom
		INC !ExtraProp1,x
		LDA #$C0 : STA !SpriteTweaker1,x
		STZ !SpriteTweaker3,x
		..done

		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

		RTL




	.HDMA
		LDA $20 : STA !HDMA3mem			; set scroll for color math setting (attch to BG2)

		; HSL blend
		LDA $14
		LSR A
		AND #$0007 : BEQ ..nomix
		ASL #4
		ORA #$0002
		TAX
		LDY #$0E
		LDA $14
		LSR A : BCS ..uploadcolor
		..mixcolor
		LDA !Level+2
		CMP #$00FF
		BCC $03 : LDA #$00FF
		SEC : SBC #$00FF
		EOR #$FFFF : INC A
		JSL MixHSL
		BRA ..nomix
		..uploadcolor
		REP #$10
		TXA
		ORA #$0200 : TAX
		LDY #$000E
		JSL HSLtoRGB
		SEP #$10
		..nomix

		; draw sun
		LDA !Level+2
		CMP #$00A0 : BCS +
		SEP #$20
		LSR A : STA $02				; $02 temporarily holds timer/2
		CLC : ADC #$60
		STA $01
		LDA #$60
		SEC : SBC $02
		STA $00
		REP #$20
		LDA.w #level5_SunTilemap : STA $02
		LDA #$0002 : STA $0D
		LDA.w #level5_SunTilemap_end-level5_SunTilemap : STA $0E
		JSL DrawSpriteBG
		+

		; check for tick
		LDA !Level+4 : BNE ..run		;\
		RTL					; | wait for a tick
		..run					; |
		STZ !Level+4				;/

		; red
		LDA #$00EE
		SEC : SBC !Level+2
		BPL +
		CMP #$FF00
		BCS $03 : LDA #$FF00
	+	STA !HDMA4mem

		; green
		LDA !Level+2
		EOR #$FFFF : INC A
		BPL +
		CMP #$FF20
		BCS $03 : LDA #$FF20
	+	STA !HDMA5mem

		; blue
		LDA !Level+2
		LSR A
		SEC : SBC #$00D0
		EOR #$FFFF : INC A
		BPL $03 : LDA #$0000
		STA !HDMA6mem

		; global light mix
		LDA !Level+2
		BIT #$0007 : BNE +
		LSR #3
		CMP #$0020
		BCC $03 : LDA #$0020
		STA !GlobalLightMix
		+

		; BG color
		LDA !Level+2
		LSR #2
		ASL A
		CMP.w #.BGColors_end-.BGColors
		BCC $03 : LDA.w #.BGColors_end-.BGColors
		TAX
		LDA.l .BGColors,x
		STA $00A2
		STA !PaletteRGB+4

		; star colors
		LDA !Level+2
		BIT #$000F : BNE +			; every 16 ticks
		SEC : SBC #$0100
		BPL $03 : LDA #$0000
		LSR #4
		CMP #$001F
		BCC $03 : LDA #$001F
		STA $00
		ASL #5 : ORA $00
		ASL #5 : ORA $00
		STA $00A0
		STA !PaletteRGB+2
		LDX #$10
	-	STA $00A4,x
		STA !PaletteRGB+6,x
		DEX #2 : BPL -
		+

		RTL


	.Modules
	..2	dl StarrySkyWithWall
	..3	dl StarrySkyWithWall_ColorMath
	..4	dl Gradient_Evening_Red
	..5	dl Gradient_Evening_Green
	..6	dl Gradient_Evening_Blue
	..7	dl 0


	.BGColors
		rep 2 :	%snescolor(15, 3, 0)
		rep 2 :	%snescolor(14, 3, 0)
		rep 2 :	%snescolor(13, 3, 0)
		rep 2 :	%snescolor(12, 3, 0)
		rep 2 :	%snescolor(12, 2, 0)
		rep 2 :	%snescolor(11, 2, 0)
		rep 2 :	%snescolor(10, 2, 0)
		rep 2 :	%snescolor(9, 2, 0)
		rep 2 :	%snescolor(8, 2, 0)
			%snescolor(8, 1, 0)
			%snescolor(7, 1, 0)
			%snescolor(6, 1, 0)
			%snescolor(5, 1, 0)
		rep 2 :	%snescolor(4, 1, 0)
		rep 2 :	%snescolor(4, 0, 0)
		rep 7 :	%snescolor(3, 0, 0)
		rep 7 :	%snescolor(3, 0, 1)
		rep 7 :	%snescolor(2, 0, 2)
		..end	%snescolor(1, 0, 3)








levelC:
	dw .Init
	dw .Main
	dw .Modules
	dw $0000

	.Init
		JSL BorderExit_Right
			dw $0000,$FFFF
			dw $BEA7

		LDA #$DC : STA !Level+2

		LDA $96+1 : BEQ +
		LDA #$C4
		STA !P2VectorY-$80
		STA !P2VectorY
		LDA #$3C
		STA !P2VectorTimeY-$80
		STA !P2VectorTimeY
		LDA #$01
		STA !P2VectorAccY-$80
		STA !P2VectorAccY
		+

	LDA #$02 : STA !2130
	LDA #$24 : STA !2131

	REP #$20
	LDA #$4210 : STA !2132_RGB
	SEP #$20



	;	JSL level35_Setup
	;	JSL levelC
		LDA #$0D : STA !Level+6
		STZ !Level+3
		REP #$20
		LDA $6701 : STA !3DWater_Color

		SEP #$20
	;	INC $14 : JSL HDMA3DWater		;\ set up double-buffered HDMA
	;	DEC $14 : JSL HDMA3DWater		;/
		RTL




	.Main
		LDA $1B
		CMP #$14 : BCS +
		JSL BorderExit_Down
			dw $12D0,$1330
			dw $039
		BRA ++
	+	JSL BorderExit_Down
			dw $1910,$1970
			dw $039|$4000
		++


		.SpawnDense
		LDA $1B						;\
		CMP #$16 : BCC ..done				; | spawn on screens 0x13-0x18
		CMP #$18+1 : BCS ..done				;/
		LDA $14						;\ spawn every 128 frames (roughly every 2 seconds)
		AND #$7F : BNE ..done				;/
		LDA #$34 : JSL CountSprites_Custom		;\ max 10 dense active
		CMP #$0A : BCS ..done				;/
		REP #$20					;\
		LDA $1C						; |
		SEC : SBC #$0020				; |
		STA $02						; |
		LDA !CameraXDelta+1				; |
		AND #$0080					; |
		EOR #$0080					; |
		STA $00						; | spawn above camera, random X offset
		LDA !RNG					; | (favors side that camera is moving towards)
		AND #$0070					; |
		ORA $00						; |
		ADC $1A						; |
		STA $00						; |
		SEP #$20					; |
		LDA #$34 : JSL SpawnSprite_Custom : BMI ..done	; |
		LDA !RNG					; |
		AND #$01					; |
		INC A : STA !ExtraProp1,x			; |
		..done						;/


	; squish dense on ground, but only underwater
		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$34 : BNE +
		LDA !SpriteWater,x : BEQ +
		LDA !SpriteHP,x
		CMP #$02 : BCS +
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		LDA #$0B : STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$02 : STA !SpriteHP,x
	+	DEX : BPL -


	;	LDA.b #HDMA3DWater : STA !HDMAptr+0
	;	LDA.b #HDMA3DWater>>8 : STA !HDMAptr+1
	;	LDA.b #HDMA3DWater>>16 : STA !HDMAptr+2

	;	LDA #$30 : TRB !HDMA			; disable channels 4 + 5

	;	JSL level35_Graphics			; returns 16-bit A
		SEP #$30
		RTL


	.Modules
	..2	dl WaterProjection
	..3	dl 0
	..4	dl WaterGradient
	..5	dl WaterSkyGradient
	..6	dl WaterPriority
	..7	dl WaterWaveEffect




	HDMA3DWater:
		PHP
		SEP #$20
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		PHP
		PHB : PHK : PLB				; start of bank wrapper has to go here so .Gradient can be read
		REP #$20
		LDA.w #.Gradient : JML level35_HDMA_3DWater

	.SA1
		PHB
		PHP
		SEP #$20
		LDA.b #Water3D_Calc>>16
		PHA : PLB
		REP #$30
		JSL Water3D_Calc
		PLP
		PLB
		RTL


	.Gradient
		dw ..end-..start
		dw $0007
		..start
		dw $5986
		dw $59A6
		dw $59A7
		dw $59C7
		dw $59E8
		dw $5A08
		dw $5A29
		dw $5A49
		dw $5A6A
		dw $5A8A
		dw $5A8B
		dw $5AAB
		..end



level26:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		JSL BorderExit_Right
			dw $0000,$FFFF
			dw $BEA7

		LDA #$02 : STA !GlobalLight2
		LDA #$06				;\
		STA !BG2ModeH				; | BG2 scroll = close/close
		STA !BG2ModeV				;/

		LDA !BG3ScrollSettings
		AND #$0F
		ORA #$50
		STA !BG3ScrollSettings
		RTL


	.Main
		LDA $14
		AND #$7F : BNE +
		LDA !TranslevelFlags+$00
		CMP #$20 : BEQ +
		INC !TranslevelFlags+$00
		+
		LDA !TranslevelFlags+$00 : STA !GlobalLightMix
		LDA !LightBuffer
		LSR A
		REP #$20
		BCS +
		LDA !LightData_SNES+($10*2)+$200 : BRA ++
		+
		LDA !LightData_SNES+($10*2)
	++	STA !2132_RGB
		RTL




level27:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA #$10 : STA !Level+3			; timer
		LDA #$E1 : STA !MsgPal
		LDA #$81 : STA !SpriteEraseMode		; erase sprites outside camera box, but ignore standard off-screen check

		; spawn light point in catacombs
		.DarkLight
		LDA $97 : BNE ..done
		LDA $95
		CMP #$06 : BCC ..done
		REP #$20
		LDA #$0700 : STA !LightPointX
		LDA #$0420 : STA !LightPointY
		LDA #$0080
		STA !LightPointR
		STA !LightPointG
		STA !LightPointB
		LDA #$0200 : STA !LightPointS
		LDA #$000C : STA !LightPointIndex
		SEP #$20
		..done

		.CheckModule
		LDA !Room
		CMP #$04 : BEQ ..darkroom
		CMP #$0A : BEQ ..darkroom
		CMP #$05 : BEQ ..bighouse
		CMP #$06 : BEQ ..bighouse
		RTL
		..darkroom
		LDA.b #DarknessEffect : STA !HDMA4module+0
		LDA.b #DarknessEffect>>8 : STA !HDMA4module+1
		LDA.b #DarknessEffect>>16 : STA !HDMA4module+2
		REP #$20
		LDA #$0080
		STA !LightR
		STA !LightG
		STA !LightB
		SEP #$20
		RTL
		..bighouse
		LDA.b #FogOfWar : STA !HDMA3module+0
		LDA.b #FogOfWar>>8 : STA !HDMA3module+1
		LDA.b #FogOfWar>>16 : STA !HDMA3module+2
		RTL



	.Main
		LDA !Level+3 : BEQ +			;\ timer
		DEC !Level+3 : +			;/



	if !Debug = 1					;\
	LDA $6DA6					; |
	AND #$20 : BEQ +				; |
	REP #$20					; | select to enter doors cheat
	JSL EXIT_GetExitNum_1				; |
	+						; |
	endif						;/


		LDA !Room
		ASL A : TAX
		JSR (.RoomCode,x)
		RTL




		.RoomCode
		dw .AristocratHouse		; 00
		dw .Shop			; 01
		dw .SwoopoHouse			; 02
		dw .EmptyPtr			; 03
		dw .EmptyPtr			; 04, has HDMA module
		dw .EmptyPtr			; 05, has HDMA module
		dw .EmptyPtr			; 06, has HDMA module
		dw .Negotiator			; 07
		dw .EmptyPtr			; 08
		dw .EmptyPtr			; 09
		dw .DimensionalCatacombs	; 0A, has HDMA module


	.EmptyPtr
		RTS


	.AristocratHouse
		LDA #$02 : JSL SearchSprite_Custom : BMI ..done
		LDA $3400,x : BNE ..done
		LDA !SpriteHP,x : BNE ..done
		LDA #$02 : STA !SpriteStasis,x
		LDA #$5A : STA !SpriteXLo,x
		LDA !P2XPosHi
		LDA $95 : BEQ ..done
		LDA !TranslevelFlags+$01
		BIT #$01 : BNE ..nomsg1
		..msg1
		ORA #$01 : STA !TranslevelFlags+$01
		REP #$20
		LDA.w #!MSG_RexVillage_Aristocrat1 : STA !MsgTrigger
		SEP #$20
		..nomsg1
		LDA #$78 : JSL CountSprites_Vanilla : BNE ..nomsg2
		LDA !TranslevelFlags+$01
		BIT #$02 : BNE ..nomsg2
		..msg2
		ORA #$02 : STA !TranslevelFlags+$01
		REP #$20
		LDA.w #!MSG_RexVillage_Aristocrat2 : STA !MsgTrigger
		SEP #$20
		LDA #$02 : JSL SearchSprite_Custom : BMI ..nomsg2
		..enrage
		LDA #$03 : STA $3400,x
		STZ !SpriteTweaker6,x
		LDA #$05 : STA !ExtraProp1,x
		..nomsg2
		..done
		RTS


	.Shop
		LDA !Level+3
		CMP #$01 : BNE ..nomsg
		STZ !Level+2
		LDA !StoryFlags+2
		AND #$01
		REP #$20
		BEQ ..buy
		..sins
		LDA.w #!MSG_RexVillage_ShopRegret : STA !MsgTrigger
		SEP #$20
		BRA ..nomsg
		..buy
		LDA.w #!MSG_RexVillage_Shop1 : STA !MsgTrigger
		SEP #$20
		..nomsg

		STZ $00
		LDX #$0F					;\
	-	LDA !SpriteStatus,x				; |
		CMP #$0B : BNE +				; |
		LDA !SpriteNum,x				; | look for purchaseable items in shop area
		CMP #$32 : BNE +				; |
		LDA !SpriteXHi,x				; |
		CMP #$03 : BCS +				; |
		LDA !SpriteXLo,x : BMI +			;/

		LDY #$00					;\
		TXA						; |
		INC A						; | index to player coin count
		CMP !P2Carry-$80				; |
		BEQ $02 : LDY #$02				;/

		REP #$20
		LDA !ExtraProp1,x
		AND #$00FF
		CMP !P1Coins,y
		BEQ ++
		BCC ++
		SEP #$20
		INC $00
		BRA +
	++	SEC : SBC !P1Coins,y
		EOR #$FFFF : INC A
		STA !P1Coins,y
		LDA.w #!MSG_RexVillage_Shop2 : STA !MsgTrigger
		SEP #$20
		LDA #$29 : STA !SPC4
		STZ !SpriteStatus,x
		PHX
		LDA #$02 : JSL SearchSprite_Custom : BMI ++
		LDA #$C0 : STA !SpriteYSpeed,x
		STZ !SpriteBlocked,x
	++	PLX
	+	DEX : BPL -
		LDA $00
		CMP !Level+2 : BEQ ..nobuy
		STA !Level+2
		BCC ..nobuy
		REP #$20
		LDA !MsgTrigger : BNE +
		LDA.w #!MSG_RexVillage_Shop3 : STA !MsgTrigger
	+	SEP #$20
		LDA !SPC4 : BNE ..nobuy
		LDA #$2A : STA !SPC4
		..nobuy

		LDA !StoryFlags+2
		AND #$01 : BEQ ..nokill
		LDA #$02 : JSL KillSprite_Custom
		..nokill
		LDA #$02 : JSL SearchSprite_Custom : BMI ..kill
		LDA !SpriteHP,x : BNE ..assault
		STZ !SpriteXSpeed,x
		STZ !SpriteXSub,x
		LDA #$65 : STA !SpriteXLo,x
		LDA !SpriteBlocked,x
		AND #$04 : BEQ +
		STZ !SpriteAnimTimer
		+
		BRA ..noclear
		..assault
		LDA !Level+4 : BNE ..noclear
		INC !Level+4
		REP #$20
		LDA.w #!MSG_RexVillage_ShopHurt : STA !MsgTrigger
		SEP #$20
		BRA ..noclear
		..kill
		LDA !StoryFlags+2				;\ shopkeeper is kill
		ORA #$01 : STA !StoryFlags+2			;/
		LDA #$32 : JSL KillSprite_Custom
		..noclear

		LDA #$21 : JSL KillSprite_Vanilla
		..noshop
		RTS



	.Negotiator
		LDA #$02 : JSL SearchSprite_Custom : BMI ..return
		LDA !SpriteHP,x : BNE ..return
		STA !SpriteStasis,x
		LDA #$7A : STA !SpriteXLo,x
		LDA $95
		CMP #$05 : BCC ..return
		LDA !TranslevelFlags+$02
		BIT #$01 : BEQ ..talk1
		BIT #$02 : BNE ..return

		..talk2
		LDA #$74 : JSL CountSprites_Vanilla : BNE ..return
		LDA #$02 : TSB !TranslevelFlags+$02
		REP #$20
		LDA.w #!MSG_RexVillage_Negotiator2 : STA !MsgTrigger
		SEP #$20
		RTS

		..talk1
		LDA #$01 : TSB !TranslevelFlags+$02
		REP #$20
		LDA.w #!MSG_RexVillage_Negotiator1 : STA !MsgTrigger
		SEP #$20

		..return
		RTS


	.SwoopoHouse
		LDA $14
		AND #$3F : BNE ..return
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..thisone
		DEX : BPL ..loop
		RTS
		..thisone
		LDA #$2C : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		LDA #$01 : STA !SpriteStatus,x
		STZ !SpriteXLo,x
		LDA #$06 : STA !SpriteXHi,x
		LDA $14
		AND #$40 : STA !SpriteYLo,x
		LDA #$01 : STA !SpriteYHi,x
		JSL !ResetSprite
		..return
		RTS


	.DimensionalCatacombs
		JSL ReloadSprites
		LDA !TranslevelFlags+$03
		BIT #$01 : BNE ..nomsg
		LDA #$01 : TSB !TranslevelFlags+$03
		REP #$20
		LDA.w #!MSG_RexVillage_Catacombs : STA !MsgTrigger
		SEP #$20
		..nomsg

		JSL RIFT_BOX
			dw $FFF0		; rift offset
			dw $0120,$0130		; X limits of camera
			dw $0630,$0690		; Y limits of players

		JSL RIFT_BOX
			dw $0010		; rift offset
			dw $0110,$0120		; X limits of camera
			dw $0690,$0700		; Y limits of players


		RTS





	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(0, 0, 1, 1)
		.Box1	%CameraBox(2, 0, 1, 0)
		.Box2	%CameraBox(4, 0, 1, 1)
		.Box3	%CameraBox(0, 2, 1, 1)
		.Box4	%CameraBox(2, 2, 0, 0)
		.Box5	%CameraBox(4, 4, 1, 3)
		.Box6	%CameraBox(4, 5, 3, 2)
		.Box7	%CameraBox(4, 2, 1, 0)
		.Box8	%CameraBox(1, 4, 1, 1)
		.Box9	%CameraBox(6, 0, 1, 4)
		.BoxA	%CameraBox(0, 6, 3, 1)

		.ScreenMatrix
		;   00  01  02  03  04  05  06  07
		db $00,$00,$01,$01,$02,$02,$09,$09
		db $00,$00,$FF,$FF,$02,$02,$09,$09
		db $03,$03,$04,$FF,$07,$07,$09,$09
		db $03,$03,$FF,$FF,$FF,$FF,$09,$09
		db $FF,$08,$08,$FF,$05,$05,$09,$09
		db $FF,$08,$08,$FF,$05,$05,$06,$06
		db $0A,$0A,$0A,$0A,$05,$05,$06,$06
		db $0A,$0A,$0A,$0A,$06,$06,$06,$06






level2A:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init

		JSL BorderExit_Left
			dw $0000,$FFFF
			dw $02B


		DEC !UpExitLimitR+1			; enable up exit (use LM exit setting)
		RTL


	.Main
		.FirstBit
		LDA !StoryFlags+1
		AND #$01 : BNE ..done

		REP #$20
		LDA.w #190*16 : STA $E8
		LDA #$0030 : STA $EA
		LDA #$0050
		STA $EC
		STA $EE
		SEP #$20

		JSL PlayerContact : BCC ..done
		LSR A : BCC ..p2
		LDY !P2InAir-$80 : BEQ ..msg
		..p2
		LSR A : BCC ..done
		LDY !P2InAir : BNE ..done
		..msg
		REP #$20
		LDA.w #!MSG_FirstBit : STA !MsgTrigger
		SEP #$20
		LDA !StoryFlags+1
		ORA #$01 : STA !StoryFlags+1
		..done

		RTL



level2B:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		DEC !RightExitLimitD+1

		LDA #$0F : STA $0E
		STZ $0F
		PHB

	-	JSL GetParticleIndex : TXY
		LDX $0E
		LDA.l .XDisp,x
		AND #$00FF
		CLC : ADC $94
		STA !Particle_X,y
		LDA.l .YDisp,x
		AND #$00FF
		CLC : ADC $96
		STA !Particle_Y,y
		LDA.l .XSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $03 : ORA #$F000
		STA !Particle_XSpeed,y
		LDA.l .YSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $03 : ORA #$F000
		STA !Particle_YSpeed,y
		LDA #$0000 : STA !Particle_XAcc,y
		DEC $0E : BPL -

		PLB
		SEP #$30
		LDA #$09 : STA !SPC4
		LDA #$1F
		STA !ShakeTimer
		STA !ShakeBG3

		JSL level5_Init_graphics
		JMP .Main

		.XDisp
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		db $00,$08,$00,$08
		.YDisp
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		.XSpeed
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		db $20,$30,$20,$30
		.YSpeed
		db $90,$90,$B0,$B0
		db $A0,$A0,$D0,$D0
		db $B0,$B0,$E0,$E0
		db $C0,$C0,$F0,$F0


	.Main
		LDA.b #.HDMA : STA !HDMAptr
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2

	; WARNING: EXTREMELY SCUFFED
		.SlantFix
		LDA !P2SlantPipe-$80 : BNE ..tempslant
		..normal
		LDA #$1F : STA !MainScreen
		STZ !SubScreen
		BRA ..done
		..tempslant
		LDA #$1D : STA !MainScreen
		LDA #$02 : STA !SubScreen
		..done

		RTL


	.HDMA
		LDA $1A
		LSR #2 : ADC $1A
		STA $22
		LDA $1C
		LSR #2 : ADC $1C
		STA $24
		LDA !BG3BaseSettings
		AND #$00F8
		ASL A : ADC $24
		STA $24
		JMP level5_HDMA						; draw sun




level2C:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		STZ $6DF5 : STZ $6DF6					; what is this?
		LDA #$0A
		STA !BG2ModeH
		STA !BG2ModeV
		REP #$20
		LDA #$00A0 : STA !LightR
		LDA #$00A0 : STA !LightG
		LDA #$00A0 : STA !LightB
		SEP #$30
		RTL


	.Main
		LDA #$E1 : STA !MsgPal

		LDX #$0F						;\
	-	LDA !SpriteStatus,x					; | look for a killed sprite (states 2-7)
		CMP #$02 : BCC +					; |
		CMP #$08 : BCS +					;/
		LDY !SpriteYHi,x					;\ must be on Y screen 00-03
		CPY #$04 : BCS +					;/
		LDA .Table,y : TSB !TranslevelFlags+$20			; if there is a rex, it can talk
	+	DEX : BPL -						; loop

		JSL TALK_BOX
			db 0 : dw !MSG_CastleRex_Rex_Warning_1
			dw $0150,$0360 : db $70,$30
		JSL TALK_BOX
			db 1 : dw !MSG_CastleRex_Rex_Warning_2
			dw $0020,$0280 : db $50,$40
		JSL TALK_BOX
			db 2 : dw !MSG_CastleRex_Rex_Warning_3
			dw $0090,$0120 : db $20,$30

		LDY !Translevel						;\ captain warrior doesn't spawn if level is beaten
		LDA !LevelTable1-1,y : BMI +				;/
		LDA $1A
		CMP #$00E0 : BNE +
		LDA $1C : BNE +
		LDA !TranslevelFlags+$20
		AND #$0008 : BNE +
		LDA.w #!MSG_CaptainWarrior_Warning : STA !MsgTrigger
		LDA #$0008 : TSB !TranslevelFlags+$20
		+

		JSL DOOR_BOX
			dw $0140,$0030 : db $40,$90
			dw $002D

		REP #$20
		LDA !P2YPosLo
		CMP #$00A1 : BCS +
		LDA #$00E0 : STA $00
		LDA #$0000 : JSL SCROLL_UPRIGHT
		SEP #$20
		RTL
	+	STZ !Level+2
		SEP #$20
		LDA #$01
		STA !EnableVScroll
		RTL

		.Table
		db $00,$04,$02,$01






level2D:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		LDX !Translevel
		LDA !Level : STA !LevelTable2,x
		LDA !LevelTable1,x
		AND.b #$60^$FF
		ORA #$40
		STA !LevelTable1,x
		LDA !Level+1
		BEQ $02 : LDA #$40
		ORA !LevelTable1,x
		STA !LevelTable1,x


		REP #$20
		LDA #$6800 : STA $400000+!MsgVRAM1
		LDA #$6880 : STA $400000+!MsgVRAM2
		LDA #$75C0 : STA $400000+!MsgVRAM3
		SEP #$20
		JSL level2D_HDMA
		RTL


	.Main
		LDA #$10 : JSL CountSprites_Custom	;\ count custom sprite 0x10 (boss + scepter)
		CMP #$01 : BNE .KeepFighting		;/ if there is 1 (scepter) boss is dead

		LDA !Level+4 : BEQ .End			;\
		CMP #$C0 : BNE .DecTimer		; |
		LDA #$36 : STA !SPC3			; > victory fanfare
		.DecTimer				; |
		LDA $14					; |
		AND #$03 : BNE .Stall			; | once boss has died, wait for timer then beat the level
		DEC !Level+4 : BRA .Stall		; |
		.End					; |
		JSL END_End				;/
		.KeepFighting				;\
		LDA #$E0 : STA !Level+4			; | if boss is alive, keep timer up
		.Stall					;/
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2
		RTL

		.HDMA
		REP #$20
		STZ $22
		STZ $24
		LDA $14
		AND #$0007
		BNE $03 : DEC !Level+2
		LDA !Level+2 : STA $1E
		RTL



level2E:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		REP #$20
		LDA #$FFE0
		STA !P2YPosLo-$80
		STA !P2YPosLo
		STA $96
		SEP #$20
		RTL


	.Main
		JSL ReloadSprites


		LDA $1B
		CMP #$04 : BCS +
		JSL BorderExit_Up
			dw $0300,$0400
			dw $002B|$8000
		BRA ++
	+	JSL BorderExit_Up
			dw $0500,$0600
			dw $0384|$8000
		++

		RTL



	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(3, 0, 0, 0)
		.Box1	%CameraBox(1, 0, 1, 1)
		.Box2	%CameraBox(0, 1, 0, 1)
		.Box3	%CameraBox(3, 1, 1, 1)
		.Box4	%CameraBox(1, 2, 1, 1)
		.Box5	%CameraBox(3, 3, 1, 0)
		.Box6	%CameraBox(5, 0, 0, 1)
		.Box7	%CameraBox(5, 2, 0, 1)
		.Box8	%CameraBox(6, 0, 2, 2)
		.Box9	%CameraBox(6, 3, 0, 1)
		.BoxA	%CameraBox(5, 5, 1, 1)
		.BoxB	%CameraBox(2, 6, 2, 0)
		.BoxC	%CameraBox(2, 4, 0, 1)
		.BoxD	%CameraBox(4, 5, 0, 0)
		.BoxE	%CameraBox(0, 0, 0, 0)

		.ScreenMatrix
		;   00  01  02  03  04  05  06  07  08
		db $0E,$01,$01,$00,$FF,$06,$08,$08,$08
		db $02,$01,$01,$03,$03,$06,$08,$08,$08
		db $02,$04,$04,$03,$03,$07,$08,$08,$08
		db $FF,$04,$04,$05,$05,$07,$09,$FF,$FF
		db $FF,$FF,$0C,$FF,$FF,$FF,$09,$FF,$FF
		db $FF,$FF,$0C,$FF,$0D,$0A,$0A,$FF,$FF
		db $FF,$FF,$0B,$0B,$0B,$0A,$0A,$FF,$FF




; level+2
;	--------
; level+3
; level+4
	!StatueX	= 191
	!StatueY	= 48


level2F:
	dw .Init
	dw .Main
	dw .Modules
	dw .RoomPointers

	.Init
		DEC !LeftExitLimitD+1

		JSL BorderExit_Right
			dw $0000,$FFFF
			dw $BEA7

		JSL level2_Graphics				;\
		LDA !DoorCounter : BNE .Return			; |
		LDA #$20					; | if entering through midway entrance, time of day is already mid day
		STA !TranslevelFlags+$00			; |
		STA !GlobalLightMix				;/
		.Return
		RTL


	.Main
		LDA !Level+3 : BEQ +
		DEC !Level+3
		+


		LDA #$02
		LDX $1D : BNE +
		TRB !SubScreen					; disable BG2
		BRA ++
		+
		TSB !SubScreen					; enable BG2
		++


		JSL level2_ReloadSprites


		.HandleRooms
		STZ !HardBoxBorders				; default: no hard box borders
		LDA #$02 : STA !LevelToBeat			; default: level to beat = 0x02 (it's fine that this is lo byte only)
		LDA !Room : STA !Level+4
		STZ !LockBox
		LDA !Room
		CMP !Level+4
		STA !Level+4 : BEQ ..same
		..newroom
		LDA #$3F : STA !Level+3
		..same
		LDA !Room : BEQ .NoBox
		CMP #$01 : BEQ .Brawl
		..room2
		LDA #$FF : STA !HardBoxBorders			; room 2: hard box borders
		STA !LockBox					; room 2: lock box
		LDA !LevelToBeat : STA !LevelToBeat		; room 2: level to beat = level (only lo byte changes)

		.Return2
		RTL

		.NoBox
		LDA #$FF : STA !CameraBoxU+1			; box 0 = no camera box
		RTL


	.Brawl
		LDA !TranslevelFlags+$10 : BMI .Return2
		LDA #$01 : STA !LockBox
		LDA #$83 : STA !SpriteEraseMode			; erase sprites outside of camera box (threshold = 0x60), disable normal check
		REP #$20
		LDA #$0C00 : STA !CameraBoxR
		SEP #$20

		LDX !TranslevelFlags+$10
		CPX.b #..lastwaveindex-..waveindex+3 : BCC ..nextwave
		..end
		LDA #$04 : JSL CountSprites_Custom : BNE .Return2
		LDA #$FF : STA !TranslevelFlags+$10
		INC !CameraBoxR+1				; reload camera box
		REP #$30
		LDA #$0025 : JSR ..togglegates
		SEP #$30
		LDA #$80 : STA !SPC3				; fade music
		RTL

		..nextwave
		CPX.b #..lastwaveindex-..waveindex+1 : BCC ..normalwave
		..aggrowave
		LDA !Level+3 : BEQ ..aggroinit
		CMP #$80 : BEQ ..aggroshake
		RTL

		..aggroinit
		CPX.b #..lastwaveindex-..waveindex+2 : BEQ ..aggrospawn
		LDA #$FF : STA !Level+3
		INC !TranslevelFlags+$10
		RTL

		..aggroshake
		ADC #$20
		STA !ShakeBG1
		RTL

		..aggrospawn
		JMP ..breakstatue


		..normalwave
		LDA !Level+3 : BNE .Return2			;\
		LDX #$0F					; |
		LDY #$00					; |
	-	LDA !SpriteStatus,x : BEQ +			; |
		LDA !SpriteNum,x				; |
		CMP #$02 : BEQ ++				; | count brawlers
		CMP #$03 : BEQ ++				; |
		CMP #$04 : BEQ ++				; |
		CMP #$2C : BNE +				; |
	++	LDA !SpriteXHi,x				; |
		CMP #$0A : BCC +				; \ don't count if too far off-screen
		CMP #$0E : BCS +				; /
		INY						; |
	+	DEX : BPL -					; |
		CPY #$02 : BCS ..return				;/

		LDA #$48 : STA !SPC3				; switch music when spawning first wave

		LDX !TranslevelFlags+$10
		INC !TranslevelFlags+$10
		CPX.b #..lastwaveindex-..waveindex : BCS ..return
		LDA ..waveindex+1,x : STA $0F
		LDA ..waveindex,x : TAX

		..nextspawn
		REP #$20
		LDA ..wavedata+0,x
		AND #$00FF
		ASL #4
		ADC #$0A00
		STA $00
		LDA ..wavedata+1,x
		AND #$00FF
		ASL #4
		ADC #$0200
		STA $02
		SEP #$20
		PHX
		LDA $0F : PHA
		LDA ..wavedata+2,x : JSL SpawnSprite_Custom
		PLA : STA $0F
		CPX #$FF : BEQ +
		LDA !SpriteNum,x
		CMP #$02 : BNE +
		LDA #$05 : STA !ExtraProp1,x
		LDA #$08 : STA !ExtraProp2,x
	+	PLX
		INX #3
		CPX $0F : BCC ..nextspawn
		..return
		RTL


		..breakstatue
		INC !TranslevelFlags+$10
		REP #$30
		LDX.w #..statueblocky-..statueblockx-2
	-	LDA ..statueblockx,x : STA $9A
		LDA ..statueblocky,x : STA $98
		PHX
		LDA #$0025 : JSL ChangeMap16
		STZ $00
		LDA #$FF80 : STA $02
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		PLX
		DEX #2 : BPL -
		LDA #$0130 : JSR ..togglegates
		REP #$30
		LDA.w #!StatueX*16+16 : STA $00
		LDA.w #!StatueY*16+48 : STA $02
		SEP #$30
		LDA #$04 : JSL SpawnSprite_Custom
		CPX #$FF : BEQ ..return
		LDA #!AggroRex_Roar+1 : STA !SpriteAnimIndex,x
		LDA #$D8 : STA !SpriteAnimTimer,x
		LDA #$38 : STA !AggroRexStunTimer,x
		INC !AggroRexChase,x
		LDA #$25 : STA !SPC1					; roar SFX
		RTL

		..statueblockx
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		dw !StatueX*16,!StatueX*16+16,!StatueX*16+32
		..statueblocky
		dw !StatueY*16,!StatueY*16,!StatueY*16
		dw !StatueY*16+16,!StatueY*16+16,!StatueY*16+16
		dw !StatueY*16+32,!StatueY*16+32,!StatueY*16+32
		dw !StatueY*16+48,!StatueY*16+48,!StatueY*16+48


	; input: A = map16 tile
		..togglegates
		REP #$10
		LDX #$0000
		SEP #$20
	-	STA $40C800+($A*$400)+$2AD,x
		STA $40C800+($D*$400)+$2A2,x
		XBA
		STA $41C800+($A*$400)+$2AD,x
		STA $41C800+($D*$400)+$2A2,x
		XBA
		INX #16
		CPX #$00B0 : BCC -
		RTS



	..waveindex
	db ..wave0-..wavedata
	db ..wave1-..wavedata
	db ..wave2-..wavedata
	db ..wave3-..wavedata
	..lastwaveindex
	db ..waveend-..wavedata

; coords relative to 0A00,0200
	..wavedata
	..wave0
	db $30,$14	: db $02
	db $31,$14	: db $02
	db $32,$14	: db $02
	..wave1
	db $0C,$14	: db $02
	db $0D,$14	: db $02
	db $0E,$14	: db $02
	db $0F,$14	: db $02
	..wave2
	db $0C,$14	: db $02
	db $0D,$14	: db $03
	db $0E,$14	: db $03
	db $0F,$14	: db $03
	..wave3
	db $0C,$0C	: db $2C
	db $0E,$0D	: db $2C
	db $30,$0D	: db $2C
	db $32,$0C	: db $2C
	..waveend




	.Modules
	..2	dl 0
	..3	dl Gradient_BlueSky_Module
	..4	dl 0
	..5	dl 0
	..6	dl 0
	..7	dl 0


	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(0, 0, 11, 4)
		.Box1	%CameraBox(11, 3, 2, 0)
		.Box2	%CameraBox(0, 0, 9, 0)

		.ScreenMatrix
		;   00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D
		db $00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01





	!CollapseStart	= $11A0
	!CollapseEnd	= $1C80



level32:
	dw .Init
	dw .Main
	dw $0000
	dw $0000

	.Init
		JSL level6_Init
		LDA #$02 : STA $41				; enable window 1 on layer 1

		LDA $95
		CMP #$0E : BCS +
		LDA #$0F : STA !LevelWidth
		+


		LDA #$07 : STA !PalsetStart			; restore this

		STZ $4324
		STZ $4374
		REP #$20
		LDA #$0D03 : STA $4320
		LDA #$0B00 : STA !HDMA2source
		LDA #$2601 : STA $4370				;\ clipping window HDMA
		LDA #$0C00 : STA !HDMA7source			;/

		LDA #!CollapseStart : STA !Level+6		; set starting point for collapsing level
		STA $0400					; also set for falling columns
		STZ $0402

		SEP #$20
		STZ !Level+3
		LDA #$04 : STA !41_WeatherFreq

		STZ $0A80					; clear chunk status
		STZ $0A87					; reset chunk size, baby!
		REP #$20					; A 16-bit
		LDA.w #.ChunkTable : STA $0A81			; set chunk data pointer
		LDA.w level6_BGColors_end : STA $00A2		; set color 0x02
		SEP #$20					; A 8-bit
		LDA #$F4 : STA !HDMA				; enable HDMA on channels 2 and 4 through 7
		INC $14 : JSL level32_HDMA
		DEC $14 : JSL level32_HDMA
		JML level32


.ChunkTable	dw $02D0,$0110 : db $06		; X, Y, size




	.Main
		REP #$20
		LDA.w #.HDMA : STA.l !HDMAptr+0
		LDA.w #.HDMA>>8 : STA.l !HDMAptr+1
		LDA #$0080 : STA !LightR
		LDA #$0100 : STA !LightG
		LDA #$00E0 : STA !LightB
		SEP #$20


		.Weather
		LDA $1B
		CMP #$1C : BCS ..done
		LDA #$06 : JSL SearchSprite_Custom : BMI ..spellparticles

		LDA !ExtraProp1,x
		CMP #$01 : BNE ..spellparticles

		..ritualcasters
		LDA #$7F : TRB !Level+4
		LDX #$0F
		..loop
		LDA !SpriteStatus,x
		CMP #$08 : BNE ..next
		LDA !ExtraBits,x
		AND #$08 : BEQ ..next
		LDA !SpriteNum,x
		CMP #$05 : BNE ..next
		LDA !SpriteXHi,x
		CMP #$0D : BNE ..next
		LDA !SpriteHP,x : BNE ..next
		LDA !SpriteXLo,x
		ASL A
		ROL A
		AND #$01
		STA !SpriteDir,x
		INC A : TSB !Level+4
		LDA #$0F : STA $32D0,x
		..next
		DEX : BPL ..loop

		LDA #$03 : BRA ..spawnweather
		..spellparticles
		LDA #$02
		..spawnweather
		JSL Weather
		..done



		LDA $1B
		CMP #$0E : BNE .NoExit
		JSL EXIT_Up
			dw $00A0
		.NoExit

		JSL END_Right
			dw $1FE8



		.DestroyChunk
		LDA #$01					;\
		AND $0A80 : BNE ..done				; |
		LDA #$06 : JSL SearchSprite_Custom : BMI ..done	; |
		LDA $BE,x					; | load chunks when adept shaman dies
		AND #$03					; |
		CMP #$02 : BNE ..done				; |
		LDA #$01 : JSL LoadChunk			; |
		..done						;/

		LDA $0A87 : BEQ .Return
		LDA $14
		AND #$1F : BNE $04 : JML DestroyChunk

		.Return
		RTL



		.HDMA
		PHB : PHK : PLB
		SEP #$30

		LDA $14
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		LDA $1F						;\
		LSR A : STA $0A08,x				; | update BG2 Hscroll
		LDA $1E						; |
		ROR A : STA $0A07,x				;/
		STX !HDMA6source				; update source for BG2

		REP #$30


		LDA $0402 : BNE $03 : JMP .NotCollapsingYet
		LDA $14
		AND #$0003 : BEQ .Smoke
		LDA $14
		INC A
		AND #$0003 : BEQ .Debris
		JMP .CheckTimer

		.Debris
		LDA !RNG
		AND #$00F0
		ORA #$0008
		CLC : ADC $1A
		PHA
		AND #$FF00
		XBA
		TAX
		PLA
		AND #$00FF
		LSR #4
		CLC : ADC #$00C0
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDA $40C800,x
		AND #$00FF
		CMP #$0025 : BEQ ..fail

		PHB
		JSL GetParticleIndex
		LDA.l !RNG
		AND #$00FF
		ADC $1A
		STA !Particle_X,x
		LDA #$00B8 : STA !Particle_Y,x
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		PLB
		..fail
		; keep all regs 16-bit here
		JMP .CheckTimer


		.Smoke
		LDA !Level+6
		CLC : ADC #$0008
		AND #$FF00
		XBA
		TAX
		LDA !Level+6
		CLC : ADC #$0008
		AND #$00FF
		LSR #4
		CLC : ADC !LevelHeight		;\ start at the bottom
		SEC : SBC #$0010		;/
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDY #$0000
	-	LDA $40C800,x
		AND #$00FF
		CMP #$0025 : BEQ +
		INY
		CPY #$000E : BEQ +
		TXA
		SEC : SBC #$0010
		TAX
		BRA -

	+	TYA
		ASL #4
		INC A
		STA $00


		SEP #$30
		LDA !RNG
		AND #$F0
		CMP $00 : BCS ..fail
		STA $00
		STZ $01
		PHB
		JSL GetParticleIndex
		LDA.l !RNG
		AND #$001F
		SEC : SBC #$0010
		CLC : ADC.l !Level+6
		STA !Particle_X,x
		LDA.l !LevelHeight
		SEC : SBC $00
		STA !Particle_Y,x
		STZ !Particle_XSpeed,x
		STZ !Particle_YSpeed,x
		STZ !Particle_XAcc,x
		STZ !Particle_YAcc,x
		PLB
		..fail
		REP #$30
		BRA .CheckTimer

		.NotCollapsingYet
		LDA $1A
		CMP #!CollapseStart : BCS .CheckTimer
	-	JMP .HandleColumns_done
		.CheckTimer

		SEP #$30
		LDA #$06 : JSL SearchSprite_Custom
		REP #$30
		LDA $3570,x
		AND #$00FF : BNE -

		LDA #$001F : STA $00
		LDA !Level+6
		CMP.w #!CollapseEnd : BCS ..nospawn
		CMP $1A : BCS +
		LDA #$0007 : STA $00
		+

		LDA $14
		AND $00 : BEQ ..spawnnew
		..nospawn
		JMP .NoCollapse
		..spawnnew

		LDX $0402					;\
		STZ $0404,x					; |
		STZ $0406,x					; | spawn new collapsing column
		INX #4						; |
		STX $0402					;/
		LDA !ShakeTimer
		ORA #$0010 : STA !ShakeTimer

		; update map16 to remove interaction
		; TO DO: non-interaction page without blanking the column upon reload
		LDA !Level+6
		CLC : ADC #$0008
		AND #$FF00
		XBA
		TAX
		LDA !Level+6
		CLC : ADC #$0008
		AND #$00FF
		LSR #4
	-	DEX : BMI +
		CLC : ADC !LevelHeight
		BRA -
	+	TAX
		LDA !LevelHeight
		LSR #4
		TAY
	-	SEP #$20
		LDA #$25 : STA $40C800,x
		LDA #$00 : STA $41C800,x
		REP #$20
		DEY : BEQ +
		TXA
		CLC : ADC #$0010
		TAX
		BRA -

	+	LDA !Level+6					;\
		CLC : ADC #$0010				; | X of next column to fall
		STA !Level+6					;/
		.NoCollapse


		.HandleColumns
		LDX $0402
	..loop	DEX #4 : BMI ..done
		LDA $0404,x
		INC A
		CMP #$002A : BCC ..down
		PHX
		LDX #$0000
	-	CPX $0402 : BCS ..reorderdone
		LDA $0408,x : STA $0404,x
		LDA $040A,x : STA $0406,x
		INX #4
		BRA -
		..reorderdone
		LDA $0400					;\
		CLC : ADC #$0010				; | update X of currently collapsing area
		STA $0400					;/
		LDA $0402
		SEC : SBC #$0004
		BPL $03 : LDA #$0000
		STA $0402
		PLX
		BRA ..loop
	..down	STA $0404,x
		TAY
		LDA .ChunkY,y
		AND #$00FF : STA $0406,x
		BRA ..loop
		..done

		SEP #$30
		LDA $14
		AND #$01
		BEQ $02 : LDA #$10
		TAX
		STX !HDMA2source				; update source for BG1
		LDA #$01 : STA $0B00,x
		STZ $0B05,x

		LDA $14
		AND #$01
		LSR A
		ROR A
		AND #$80 : TAX
		STX !HDMA7source				; update source for clipping window
		LDA #$01 : STA $0C00,x				;\
		LDA #$FF : STA $0C01,x				; | pre-emptively disable clipping window
		STZ $0C02,x					; |
		STZ $0C03,x					;/

		REP #$20					;\
		LDX !HDMA6source				; | layer 1 positions in hdma table
		LDA $1A : STA $0B01,x				; |

		; LDA $14
		; AND #$0003
		; CMP #$0003
		; BNE $03 : LDA #$0001
		; DEC A
		; STA $0E
		LDA $1C
		CLC : ADC $7888
		STA $0B03,x

	;	LDA $1C : STA $0B03,x				;/
		STZ $22						;\
		STZ $24						; |
		LDA $1A						; |
		AND #$01FF					; |
		ORA #$2000					; |
		STA $00						; |
		LDA $1C						; | set up mode 2 table
		CLC : ADC $7888
	;CLC : ADC $0E
		AND #$01FF					; |
		ORA #$2000					; |
		STA $02						; |
		LDX #$3E					; |
	-	LDA $00 : STA !DecompBuffer+$1000,x		; |
		LDA $02 : STA !DecompBuffer+$1040,x		; |
		DEX #2 : BPL -					;/


		.HandleDisplacement
		LDA $0400					; left edge of collapsing area
		SEC : SBC $1A
		STA $0E
		LDY #$00
	..loop	CPY $0402 : BCC ..process
		JMP ..done

		..process
		LDA $0E : BEQ ..bg1plusfirst
		CMP #$00F8 : BCC ..full
		CMP #$0100 : BCC ..onecolumn
		CMP #$FFF1 : BCC ..next
		CMP #$FFF9 : BCC ..bg1

		..bg1plusfirst
		LDX !HDMA6source
		LDA $0B03,x
		SEC : SBC $0406,y
		STA $0B03,x
		LDX #$00 : BRA +

		..bg1
		LDX !HDMA6source
		LDA $0B03,x
		SEC : SBC $0406,y
		STA $0B03,x
		BRA ..next

		..onecolumn
		LSR #3
		ASL A
		TAX
		LDA $0E
		AND #$0007
		BNE $02 : DEX #2
	+	LDA !DecompBuffer+$1040,x
		AND #$01FF
		SEC : SBC $0406,y
		AND #$01FF
		ORA #$2000
		STA !DecompBuffer+$1040,x
		BRA ..next

		..full
		LSR #3
		ASL A
		TAX
		LDA $0E
		AND #$0007
		BNE $02 : DEX #2
		LDA !DecompBuffer+$1040,x
		AND #$01FF
		SEC : SBC $0406,y
		AND #$01FF
		ORA #$2000
		STA !DecompBuffer+$1040,x
		STA !DecompBuffer+$1042,x

		..next
		LDA $0E
		CLC : ADC #$0010
		STA $0E
		INY #4
		JMP ..loop
		..done



; left edge is !CollapseStart
; right edge is !Level+6
; start with R = !Level+6, for scanlines = Ydisp of last column
; then R = !Level+6 - 16, for scanlines = Ydisp of second to last column - Ydisp of last column
; repeat for all columns
; then set R = $0400
;

; $00 - left edge of window area
; $02 - right edge of top row
; $04 - left edge of top row
; $0E - keeping track of current Xpos of window's right edge

		.HandleClipping
		LDX !HDMA7source
		LDY $0402
		LDA #$0000 : STA $0406,y		; clear this to make the math simpler later
		LDA #!CollapseStart
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $00

		LDA $0400
		CMP.w #!CollapseEnd : BCS ..generatewindow

		CMP !Level+6 : BNE $03 : JMP ..done	; exception: collapse has not started yet

		..generatewindow
		SEC : SBC $1A
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $02

		LDA !Level+6
		DEC A
		SEC : SBC $1A
		STA $0E
		BPL $03 : LDA #$0000
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $04
		LDA $0E : BEQ +				; if right edge is exactly 0, it is not off-screen
		CMP $00 : BEQ ..done			; no clipping if both are off-screen at the same side
	+	SEP #$20

		..loop
		DEY #4 : BMI ..finish
		LDA $0406,y
		SEC : SBC $040A,y
		SEC : SBC $7888
		BPL ..small

		..big
		LSR A
		STA $0C00,x
		BCC $01 : INC A
		STA $0C03,x
		LDA $00
		STA $0C01,x
		STA $0C04,x
		LDA $04
		STA $0C02,x
		STA $0C05,x
		INX #3
		BRA ..shared
		..small
		STA $0C00,x
		LDA $00 : STA $0C01,x
		LDA $04 : STA $0C02,x
		..shared
		INX #3
		REP #$20
		LDA $0E
		SEC : SBC #$0010
		STA $0E : BMI ..offscreen
		CMP #$00FF
		BCC $03 : LDA #$00FF
		STA $04
		SEP #$20
		BRA ..loop

		..offscreen
		SEP #$20

		..finish
		LDA $00 : STA $0C01,x
		LDA $02
		BEQ $01 : DEC A
		STA $0C02,x
		BNE +
		LDA #$FF : STA $0C01,x
	+	LDA #$01 : STA $0C00,x
		STZ $0C03,x
		REP #$20

		..done


		JSL GetVRAM
		LDA #$0080 : STA !VRAMbase+!VRAMtable+$00,x
		LDA.w #!DecompBuffer+$1000 : STA !VRAMbase+!VRAMtable+$02,x
		LDA.w #!DecompBuffer>>16 : STA !VRAMbase+!VRAMtable+$04,x
		LDA !2109
		AND #$00FC
		XBA
		STA !VRAMbase+!VRAMtable+$05,x
		PLB
		RTL


		.ChunkY
		db $01,$01,$02,$02,$03,$04,$05,$07,$09,$0B,$0E,$11,$14,$18,$1C,$20
		db $25,$2A,$2F,$35,$3B,$41,$48,$4F,$57,$5F,$67,$6F,$77,$7F,$87,$8F
		db $97,$9F,$A7,$AF,$B7,$BF,$C7,$CF,$D7,$DF


; !Level+6	-	next column that will fall
; $0400		-	X of last column that disappeared
; $0402		-	how many falling columns there are
; $0404 +2X	-	timer for X falling column
; $0406 +2X	-	displacement of X falling column





;	$0A80:		chunk status (each bit represents a chunk, so bit 0 = chunk 1, bit 1 = chunk 2 etc.)
;	$0A81-$0A82:	16-bit pointer to chunk data (uses B as bank)
;	$0A83-$0A84:	X coord of section being destroyed
;	$0A85-$0A86:	Y coord of section being destroyed
;	$0A87:		how many rows are left to destroy

	DestroyChunk:
		REP #$20
		JSL PuffTile
		LDA $0A83 : PHA
		CLC : ADC #$0010
		STA $0A83
		JSL PuffTile
		PLA : STA $0A83
		LDA $0A85
		CLC : ADC #$0010
		STA $0A85
		SEP #$20
		DEC $0A87
		LDA #$09 : STA !SPC4			; > Boom sound
	.Return	RTL


	PuffTile:
		PHP
		PEI ($98)
		PEI ($9A)
		REP #$20
		LDA $0A83 : STA $9A
		LDA $0A85 : STA $98
		LDX #$02 : STX $9C
		JSL $00BEB0

		STZ $00
		STZ $02
		STZ $04
		STZ $06
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		PLA : STA $9A
		PLA : STA $98

		.Return
		PLP
		RTL



; call LoadChunk_Force to force a chunk to load, even if it has been loaded before

	LoadChunk:
		STA $00
		AND $0A80 : BNE .Return
		LDA $00
	.Force
		TSB $0A80			; set chunk as loaded
		PHY				; push Y
		PHP				; push P
		SEP #$10			;\
		LDY #$FB			; |
	-	INY #5				; | get index
		LSR A				; |
		BCC -				;/
		REP #$20			;\
		LDA $0A81 : STA $00		; |
		LDA ($00),y : STA $0A83		; |
		INY #2				; | load chunk
		LDA ($00),y : STA $0A85		; |
		INY #2				; |
		SEP #$20			; |
		LDA ($00),y : STA $0A87		;/
		PLP				; pull P
		PLY				; pull Y
	.Return	RTL





level33:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA $95 : BNE +
		LDA #$80
		STA !P2YSpeed-$80
		STA !P2YSpeed
		+
		RTL


	.Main
		JSL EXIT_Down
			dw $0270

		RTL


	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(0, 0, 1, 0)
		.Box1	%CameraBox(2, 0, 0, 0)
		.Box2	%CameraBox(2, 1, 0, 1)
		.Box3	%CameraBox(3, 0, 2, 2)
		.Box4	%CameraBox(6, 0, 1, 2)
		.Box5	%CameraBox(8, 0, 5, 2)

		.ScreenMatrix
		;   00  01  02  03  04  05  06  07  08  09  0A  0B  0C  0D  0E  0F  10  11  12  13  14
		db $00,$00,$01,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
		db $00,$00,$02,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
		db $00,$00,$02,$03,$03,$03,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05




level38:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA $97
		CMP #$0B : BNE +
		LDA #$80
		STA !P2YSpeed-$80
		STA !P2YSpeed
		LDA #$E0
		STA !P2XSpeed-$80
		STA !P2XSpeed
		+


		LDA #$E1 : STA !MsgPal

		RTL


	.Main


	.HandleRooms
		LDA !Level+3 : BEQ ..timerdone
		DEC !Level+3
		..timerdone

		LDA !Room
		ASL A
		TAX
		JSR (.RoomCode,x)
		LDA !Room
		CMP !Level+4
		STA !Level+4 : BEQ ..same
		..newroom
		LDA #$FF : STA !Level+3
		..same
		RTL


		.RoomCode
		dw .TopFloor		; 00
		dw .Floor6		; 01
		dw .Floor5		; 02
		dw .Floor4		; 03
		dw .Floor3		; 04
		dw .Floor2		; 05
		dw .GroundFloor		; 06

		dw .MayorsHouse		; 07
		dw .MayorsHouse		; 08

		dw .TrashHouse		; 09
		dw .Prison		; 0A
		dw .Library		; 0B




	.TopFloor
		LDA #$32 : JSL KillSprite_Custom
		RTS

	.Floor6
		LDA #$10 : JSR .BreakInBox
		dw $0100,$0200		; trigger X,Y
		db $FF,$18		; trigger W,H
		db $08,$02		; sprite data
		dw $0BCB		; tile
		dw $01A0,$0210		; coords
		JSR .SetBandit

		LDA #$20 : JSR .BreakInBox
		dw $0000,$01C0
		db $E0,$20
		db $08,$02
		dw $0BCB
		dw $0040,$01C0
		JSR .SetBandit

		LDA #$40 : JSR .BreakInBox
		dw $0140,$0150
		db $C0,$40
		db $08,$02
		dw $0BCB
		dw $01A0,$0160
		JSR .SetBandit

		LDA #$80 : JSR .BreakInBox
		dw $0100,$0120
		db $FF,$20
		db $08,$02
		dw $0BCB
		dw $01A0,$0120
		JSR .SetBandit

		JSR .SpawnAssassin
		RTS

	.Floor5
		JSR .SpawnAssassin
		RTS

	.Floor4
		JSR .SpawnAssassin
		RTS

	.Floor3
		LDA #$04 : JSR .BreakInBox
		dw $0100,$0480
		db $FF,$18
		db $08,$02
		dw $0BCB
		dw $01A0,$0480
		JSR .SetBandit

		..nobreakin
		JSR .SpawnAssassin
		RTS


	.Floor2
		LDA !Level+2
		AND #$02 : BNE ..spawn
		LDA $1B : BNE ..return
		LDA #$02 : TSB !Level+2
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper3 : STA !MsgTrigger
		SEP #$20
		..spawn
		JSR .SpawnAssassin
		..return

		RTS

	.GroundFloor
		LDA #$02 : JSL SearchSprite_Custom : BMI ..return
		LDA !SpriteHP,x : BEQ ..normal
		..hurt
		LDA !Level+2
		AND #$01 : BNE ..return
		LDA #$01 : TSB !Level+2
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper2 : STA !MsgTrigger
		SEP #$20
		RTS
		..normal
		LDA #$08 : STA !SpriteOAMProp,x
		LDA #$2A : STA !SpriteXLo,x
		LDA !Level+3
		CMP #$01 : BNE ..return
		REP #$20
		LDA.w #!MSG_RexVillage_SkyScraper1 : STA !MsgTrigger
		SEP #$20
		..return
		RTS


	.HandleSprites
		LDA !Room
		CMP #$01
		REP #$20
		BNE ..screen
		..camerabox
		LDA !CameraBoxU
		SEC : SBC #$0018
		STA $00
		LDA !CameraBoxD
		CMP $1C
		BCS $02 : LDA $1C
		CLC : ADC #$00F8
		BRA ..set
		..screen
		LDA $1C
		SEC : SBC #$0018
		STA $00
		LDA $1C
		CLC : ADC #$00F8
		..set
		STA $02
		SEP #$20
		LDX #$0F
		..loop
		LDA !SpriteNum,x
		CMP #$02 : BEQ ..thisnum
		CMP #$30 : BNE ..next
		..thisnum
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x
		REP #$20
		CMP $00 : BCC ..kill
		CMP $02 : BCC ..next
		..kill
		SEP #$20
		STZ !SpriteStatus,x
		..next
		SEP #$20
		DEX : BPL ..loop
		..return
		RTS


	.SpawnAssassin
		JSR .HandleSprites
		REP #$20
		LDA $1C
		CMP !CameraBoxU : BCC ..return16
		CMP !CameraBoxD
		SEP #$20
		BEQ ..process
		BCC ..process
		..return16
		SEP #$20
		RTS
		..process
		LDA $14
		AND #$1F : BNE ..return
		LDA #$02 : JSL CountSprites_Custom
	;	LDY !Room
	;	CMP ..count,y : BCS ..return
	CMP #$04 : BCS ..return
		LDX #$0F
		..loop
		LDA !SpriteStatus,x : BEQ ..thisone
		DEX : BPL ..loop
		RTS
		..thisone
		LDA #$08 : STA !SpriteStatus,x
		LDA #$02 : STA !SpriteNum,x
		LDA #$08 : STA !ExtraBits,x
		JSL !ResetSprite
		LDY !Room
		LDA ..xlo,y : STA !SpriteXLo,x
		LDA ..xhi,y : STA !SpriteXHi,x
		LDA ..ylo,y : STA !SpriteYLo,x
		LDA ..yhi,y : STA !SpriteYHi,x
		LDA #$05 : STA !ExtraProp1,x
		LDA #$05 : STA !ExtraProp2,x
		LDA #$03 : STA $3400,x
		LDA #$C0 : STA !SpriteYSpeed,x
		..return
		RTS

		..count
		db $00,$09,$07,$06,$05,$04,$00
		..xlo
		db $FF,$F8,$80,$70,$70,$80,$FF
		..xhi
		db $FF,$00,$01,$00,$00,$01,$FF
		..ylo
		db $FF,$A0,$80,$60,$40,$20,$FF
		..yhi
		db $FF,$02,$03,$04,$05,$06,$FF




		.SetBandit
		CPX #$10 : BCS ..return
		LDA #$03 : STA $3400,x
		LDA #$05 : STA !ExtraProp1,x
		LDA #$05 : STA !ExtraProp2,x
		..return
		RTS



	.BreakInBox
		BIT !Level+2 : BEQ ..ok					; check bit key
		LDX #$FF						; return X = invalid
		..return						;\
		REP #$20						; |
		LDA $01,s						; |
		CLC : ADC #$000E					; | +14 to return address, then return
		STA $01,s						; |
		SEP #$20						; |
		RTS							;/

		..ok							;\
		STA !BigRAM						; > preserve bit key
		REP #$20						; |
		LDA $01,s						; |
		INC A							; | $0E = pointer
		STA $0E							; | return address +6
		CLC : ADC #$0005					; |
		STA $01,s						;/




		LDA ($0E) : STA $E8					;\
		LDY #$02						; |
		LDA ($0E),y : STA $EA					; |
		LDY #$04						; |
		LDA ($0E),y : STA $EE-1					; |
		AND #$00FF : STA $EC					; | check trigger box, then let .BreakIn code take over
		SEP #$20						; |
		STZ $EF							; |
		JSL PlayerContact : BCC .BreakIn_fail			; |
		LDA !BigRAM						; > A = bit key
		BCS .BreakIn_spawn					; |
		BRA .BreakIn_return					;/




; input:
;	A = bit key
;	8 bytes after JSR = input for !ChangeMap16 (sprite extra bits, sprite num, map16 tile num, x coord, y coord)
; output:
;	X = sprite index (0xFF if spawn failed)

; example:
;	JSR .BreakIn
;	db $08,$02		; rex
;	dw $0B70		; tile
;	dw $0080,$0480		; coords

	.BreakIn
		BIT !Level+2 : BEQ ..spawn				; check bit key
		..fail							;\ return X = invalid
		LDX #$FF						;/
		..return						;\
		REP #$20						; |
		LDA $01,s						; |
		CLC : ADC #$0008					; | +8 to return address, then return
		STA $01,s						; |
		SEP #$20						; |
		RTS							;/

		..spawn							;\ set bit key
		TSB !Level+2						;/
		REP #$20						;\
		LDA $01,s						; |
		SEC : ADC #$0002					; > +1 +2 to get to map16 part of data
		STA $00							; |
		LDY #$02						; |
		LDA ($00),y : STA $9A					; > X
		LDY #$04						; |
		LDA ($00),y : STA $98					; > Y
		LDA ($00) : PHA						; > tile
		JSR ..break						; |
		LDA $9A							; | break + puff blocks
		CLC : ADC #$0010					; |
		STA $9A							; |
		LDA $01,s : JSR ..break					; |
		LDA $98							; |
		CLC : ADC #$0010					; |
		STA $98							; |
		LDA $01,s : JSR ..break					; |
		LDA $9A							; |
		SEC : SBC #$0010					; |
		STA $9A							; |
		PLA : JSR ..break					; |
		SEP #$20						;/

		LDX #$00						;\
		..loop							; |
		LDA !SpriteStatus,x : BEQ ..thisone				; | search for a sprite slot
		INX							; |
		CPX #$10 : BCC ..loop					; |
		BRA ..fail						;/
		..thisone						;\
		REP #$20						; |
		LDA $01,s						; |
		INC A							; |
		STA $00							; |
		SEP #$20						; |
		LDY #$01						; |
		LDA ($00) : STA !ExtraBits,x				; | get sprite data
		BIT #$08 : BNE ..custom					; |
		..vanilla						; |
		LDA ($00),y : STA !SpriteNum,x				; |
		BRA ..reset						; |
		..custom						; |
		LDA ($00),y : STA !SpriteNum,x				; |
		..reset							;/
		INC !SpriteStatus,x					;\
		JSL !ResetSprite					; |
		LDA $9A							; |
		ORA #$08 : STA !SpriteXLo,x				; | spawn sprite
		LDA $9B : STA !SpriteXHi,x				; | (NOTE: block coords are at +0,+10 after block update, so this is perfect)
		LDA $98 : STA !SpriteYLo,x				; |
		LDA $99 : STA !SpriteYHi,x				;/
		LDA #$3F : STA !ShakeTimer				; shake timer
		JMP ..return

		..break
		JSL ChangeMap16
		LDA #$FF80 : STA $00
		STZ $02
		LDA.w #!prt_smoke16x16 : JSL SpawnParticleBlock
		RTS




	.MayorsHouse
		LDA !TranslevelFlags+$04
		AND #$02 : BEQ ..normal
		LDA #$02 : JSL KillSprite_Custom
		..normal

		LDX #$0F
	-	LDA !ExtraBits,x
		AND #$08 : BNE ..custom
		..vanilla
		LDA !SpriteNum,x
		CMP #$1D : BNE +
		LDA #$02
		STA !SpriteStasis,x
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
		BRA +
		..custom
		LDA !SpriteNum,x
		CMP #$02 : BNE +
		..mayor
		LDA !SpriteStatus,x
		CMP #$04 : BEQ ..dead
		LDA !SpriteHP,x : BEQ ..alive
		CMP #$01 : BEQ +
		..dead
		LDA !TranslevelFlags+$04
		AND #$02 : BNE +
		LDA #$02 : TSB !TranslevelFlags+$04
		REP #$20
		LDA.w #!MSG_RexVillage_Mayor2 : STA !MsgTrigger
		SEP #$20
		BRA +

		..alive
		LDA #$02 : STA !SpriteStasis,x
		LDA #$04 : STA !SpriteOAMProp,x
		LDA #$1A : STA !SpriteXLo,x
		LDA !TranslevelFlags+$04
		AND #$01 : BNE +
		LDA #$01 : TSB !TranslevelFlags+$04
		REP #$20
		LDA.w #!MSG_RexVillage_Mayor1 : STA !MsgTrigger
		SEP #$20
	+	DEX : BPL -
		RTS


	.TrashHouse
		JSL WARP_BOX
			db $04
			dw $00E0,$0B70 : db $40,$10
			dw $02E0|$8000
		RTS

	.Prison
		LDX #$0F
	-	LDA !SpriteNum,x
		CMP #$1D : BNE +
		LDA #$02
		STA !SpriteStasis,x
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x
	+	DEX : BPL -

		LDA #$02 : JSL SearchSprite_Custom : BMI ..return
		LDA !SpriteHP,x : BNE ..return
		STZ !SpriteDir,x

		LDA !TranslevelFlags+$05
		BIT #$01 : BNE ..return
		LDA $95 : BEQ ..return
		LDA #$01 : TSB !TranslevelFlags+$05
		REP #$20
		LDA.w #!MSG_RexVillage_BullyGuard : STA !MsgTrigger
		SEP #$20
		..return
		RTS


	.Library
		LDA #$02 : JSL SearchSprite_Custom : BMI ..return
		LDA #$01 : JSR .TalkBox
		dw $0130,$0F00
		db $40,$20
		dw !MSG_RexVillage_Library
		..return
		RTS


	.TalkBox
		BIT !Level+2 : BEQ ..process
		..return
		REP #$20
		LDA $01,s
		CLC : ADC #$0008
		STA $01,s
		SEP #$20
		RTS

		..process
		STA !BigRAM
		REP #$20
		LDA $01,s
		INC A
		STA $0E

		LDA ($0E) : STA $E8
		LDY #$02
		LDA ($0E),y : STA $EA
		LDY #$04
		LDA ($0E),y : STA $EE-1
		AND #$00FF : STA $EC
		SEP #$20
		STZ $EF

		JSL PlayerContact : BCC ..return
		LDA !BigRAM : TSB !Level+2
		REP #$20
		LDA $01,s
		SEC : ADC #$0006
		STA $0E
		LDA ($0E) : STA !MsgTrigger
		BRA ..return



	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(0, 0, 1, 0)
		.Box1	%CameraBox(0, 1, 1, 1)
		.Box2	%CameraBox(0, 3, 1, 0)
		.Box3	%CameraBox(0, 4, 1, 0)
		.Box4	%CameraBox(0, 5, 1, 0)
		.Box5	%CameraBox(0, 6, 1, 0)
		.Box6	%CameraBox(0, 7, 1, 0)
		.Box7	%CameraBox(0, 9, 1, 2)
		.Box8	%CameraBox(0, 8, 1, 0)
		.Box9	%CameraBox(0, 12, 1, 0)
		.BoxA	%CameraBox(0, 14, 1, 1)
		.BoxB	%CameraBox(0, 16, 1, 1)

		.ScreenMatrix
		;   00  01
		db $00,$00	; top floor
		db $01,$01	;\ floor 6
		db $01,$01	;/
		db $02,$02	; floor 5
		db $03,$03	; floor 4
		db $04,$04	; floor 3
		db $05,$05	; floor 2
		db $06,$06	; ground floor

		db $08,$08	; mayor's attic
		db $07,$07	;\ mayor's house
		db $07,$07	;/

		db $09,$09	;\
		db $09,$09	; | trash house
		db $09,$09	;/

		db $0A,$0A	;\ prison
		db $0A,$0A	;/

		db $0B,$0B	;\ some house
		db $0B,$0B	;/

		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06
		db $06,$06







;lines	x	w
;10	+30	40
;50	+30	90
;60	+90	30
;10	+50	80
;10	+30	A0
;60	+00	D0
;10	+70	60
;10	+80	50
;10	+80	40
level39:
	dw .Init
	dw .Main
	dw $0000
	dw .RoomPointers

	.Init
		LDA $95 : BEQ ..cave
		..chasm
		LDA #$08 : TSB !HDMA
		..cave
		LDA #$20
		STA !P2YSpeed-$80
		STA !P2YSpeed
		STZ !P2VectorY-$80
		STZ !P2VectorY
		JML level39


	.Main
		LDA.b #.HDMA : STA !HDMAptr+0
		LDA.b #.HDMA>>8 : STA !HDMAptr+1
		LDA.b #.HDMA>>16 : STA !HDMAptr+2



		LDA !Room : BNE .Chasm

		.Cavern
		JSL WARP_BOX
			db $08
			dw $0040,$0000 : db $50,$04
			dw $00C0|$8000

		JSL WARP_BOX
			db $08
			dw $0100,$0000 : db $50,$04
			dw $00C1|$8000

		JSL WATER_BOX
			dw $0000,$0000 : db $FF,$FF

		JSL WATER_BOX
			dw $0000,$0100 : db $FF,$FF

		JSL WATER_BOX
			dw $0100,$01A0 : db $60,$30

		JSL WATER_BOX
			dw $0100,$00C0 : db $80,$30

		JSL WATER_BOX
			dw $0100,$0000 : db $40,$FF

		BRA .GetCam

		.Chasm
		JSL WARP_BOX
			db $08
			dw $0380,$0000 : db $50,$04
			dw $00C2|$8000

		LDA #$01 : STA !WaterLevel
		REP #$20
		LDA $1C
		CMP #$0100 : BCC ..daylight
		SBC #$0100
		LSR #3
		CMP #$0080
		BCC $03 : LDA #$0080
		STA $00
		LDA #$0100
		SEC : SBC $00
		STA !LightR
		LDA #$0100
		LSR $00
		SBC $00
		BRA +

		..daylight
		LDA #$0100
		STA !LightR
		BRA +

	+	STA !LightG
		SEP #$20

		.GetCam
		RTL


	.RoomPointers
		dw .ScreenMatrix
		dw .BoxTable

		;	key ->	   X  Y  W  H
		;		   |  |  |  |
		;		   V  V  V  V
		.BoxTable
		.Box0	%CameraBox(0, 0, 1, 2)
		.Box1	%CameraBox(2, 0, 1, 7)

		.ScreenMatrix
		db $00,$00,$01,$01
		db $00,$00,$01,$01
		db $00,$00,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01
		db $FF,$FF,$01,$01



	.HDMA
		PHB : PHK : PLB
	; BG1 wave code

		REP #$20
		STZ $0E
		LDA $14
		AND #$0001
		BEQ $03 : LDA #$0060
		TAX
		CLC : ADC #$0C21+6			; get pointer and index to current tables
		STA $00
		SEP #$20


		LDA $14					;\
		LSR #2					; |
		AND #$0F				; |
		INC A					; | update scanline count to scroll wave effect
		STA $0C20+6,x				; |
		CMP #$01 : BNE .NoUpdate		; |
		LDA $14					; |
		AND #$02 : BNE .NoUpdate		;/

		.Update					;\
		LDY #$30				; |
	-	LDA ($00),y				; |
		AND #$F0				; > maintain hi nybble
		STA $02					; |
		LDA ($00),y				; |
		SEC : SBC #$04				; | update pointers for wave effect
		AND #$0F				; |
		ORA $02					; |
		STA ($00),y				; |
		DEY #3 : BPL -				; |
		.NoUpdate				;/

		REP #$20				;\
		LDA $0E					; |
		BPL $03 : LDA #$0000			; |
		LDY !IceLevel : BNE +			; > no wave effect when frozen
		CMP #$00E0				; |
		BCC $03					; |
	+	LDA #$00E0				; | distance to hi prio water from top of screen
		SEP #$20				; |
		LSR A					; |
		STA $0C20,x				; |
		BCC $01 : INC A				; |
		STA $0C23,x				;/
		LDA $00					;\ > lo byte of pointer
		SEC : SBC #$07				; |
		TAY					; |
		LDA $0C20,x				; |
		BNE $03 : INY #3			; | see how many chunks we need
		LDA $0C23,x				; |
		BNE $03 : INY #3			;/
		STY !HDMA3source			; > update source



	; +0+0
	; -1+0
	; -1+1
	; +0+1


		REP #$20				;\
		LDA $14					; |
		AND #$0001				; |
		BEQ $03 : LDA #$0010			; |
		TAX					; |
		LDA $1A					; |
		STA $0D00,x				; |
		STA $0D0C,x				; |
		DEC A					; |
		BPL $03 : LDA #$0000			; > don't allow negative due to clipping errors
		STA $0D04,x				; |
		STA $0D08,x				; | recalculate BG1 positions
		LDA $1C					; |
		CLC : ADC $7888
		STA $0D02,x				; |
		STA $0D06,x				; |
		INC A					; |
		STA $0D0A,x				; |
		STA $0D0E,x				;/
		PLB
		RTL










