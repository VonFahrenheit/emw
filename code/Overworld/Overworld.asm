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
; The maximum number that can be added to !LevelSelectBase is +$106

; Menu controls:
;	X/Y:	go back (goes back to base if you push it enough)
;	A/B:	confirm
;	L/R:	switch between character select and realm select
;	Start:	join/drop out (only for player 2!)


; $7EA2:
;	this table should be repurposed to determine which areas have been unlocked and beaten.
;	use together with level select function.


; TO DO:
;	- OAM sort
;



	!IntroLevel		= $1F7;$0C6



	!LevelSelectBase	= $6DDF			; can be up to $500 bytes i think


	macro MapDef(name, size)
		!<name>	:= !LevelSelectBase+!Temp
		!Temp	:= !Temp+<size>
	endmacro


	!Temp = 0
	%MapDef(CharMenuSize,		1)	; used to hide characters that are not yet unlocked
	%MapDef(CharMenu,		1)	; 00 = no menu, 01 = opening, 02 = main, 03 = closing
	%MapDef(CharMenuCursor,		1)	; position
	%MapDef(SelectingPlayer,	1)	; which player controls the char select (0 = player 1, 1 = player 2)
	%MapDef(UploadPlayerPal,	1)	; 0 = upload, anything else = don't upload

	%MapDef(P1MapXFraction,		1)
	%MapDef(P1MapX,			2)
	%MapDef(P1MapYFraction,		1)
	%MapDef(P1MapY,			2)
	%MapDef(P1MapXSpeed,		1)
	%MapDef(P1MapYSpeed,		1)
	%MapDef(P1MapAnim,		1)
	%MapDef(P1MapAnimTimer,		1)
	%MapDef(P1MapDirection,		1)

	%MapDef(P2MapXFraction,		1)
	%MapDef(P2MapX,			2)
	%MapDef(P2MapYFraction,		1)
	%MapDef(P2MapY,			2)
	%MapDef(P2MapXSpeed,		1)
	%MapDef(P2MapYSpeed,		1)
	%MapDef(P2MapAnim,		1)
	%MapDef(P2MapAnimTimer,		1)
	%MapDef(P2MapDirection,		1)

	%MapDef(MapLight,		$50)
	!MapLight_X	= !MapLight+0
	!MapLight_Y	= !MapLight+2
	!MapLight_R	= !MapLight+4
	!MapLight_G	= !MapLight+6
	!MapLight_B	= !MapLight+8

	%MapDef(MapOAMindex,		2)	; index to next free area of data
	%MapDef(MapOAMcount,		2)	; number of tilemaps currently in data
	%MapDef(MapOAMdata,		$100)	; holds OAM data to be sorted by Y coord






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

	org $009F53
		JSL SetBrightness		;\ org: STA !2100 : CMP $9F33,y
		NOP #2				;/

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
	pullpc
	incsrc "Zip.asm"
	incsrc "Player.asm"
	incsrc "Load.asm"
	incsrc "RenderName.asm"
	incsrc "LevelList.asm"
	incsrc "Lighting.asm"
	incsrc "OAM_sort.asm"



	SetBrightness:
		PHA
		LDA !GameMode
		CMP #$0D : BNE +
		JSL MAIN
	+	LDA $01,s : STA !2100
		LDX !GameMode
		CPX #$0B : BEQ ++
		CPX #$0D : BNE +
	++	AND #$0F
		EOR #$0F
		ASL #4
		STA $6DB0
	+	PLA
		CMP $9F33,y
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
; channel 6 - FREE
; channel 7 - FREE


	MAIN:
		REP #$20					;\
		LDA #$2C40 : STA $4330				; |
		LDA #$0800 : STA $4340				; |
		LDA #$0F43 : STA $4350				; |
		LDA.w #HDMA_MainScreen : STA !HDMA3source	; |
		LDA.w #HDMA_Tilemap : STA !HDMA4source		; |
		LDA.w #HDMA_Coords : STA !HDMA5source		; |
		SEP #$20					; | set up HUD at top of screen using HDMA
		LDA.b #HDMA>>16					; |
		STA $4334					; |
		STA $4337					; |
		STA $4344					; |
		STA $4354					; |
		STA $4357					; |
		LDA #$38 : STA !HDMA				;/
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
		JSL Render

		REP #$30

	LDA #$0100 : STA !MapLight_X
	LDA #$0300 : STA !MapLight_Y
	LDA #$0120 : STA !MapLight_R
	LDA #$00E0 : STA !MapLight_G
	LDA #$00E0 : STA !MapLight_B

	LDA #$0080 : STA !MapLight_X+10
	LDA #$0300 : STA !MapLight_Y+10
	LDA #$0100 : STA !MapLight_R+10
	LDA #$0100 : STA !MapLight_G+10
	LDA #$0140 : STA !MapLight_B+10

	LDA #$0000 : STA !MapLight_X+20
	LDA #$0000 : STA !MapLight_Y+20
	LDA #$0180 : STA !MapLight_R+20
	LDA #$0040 : STA !MapLight_G+20
	LDA #$0040 : STA !MapLight_B+20

	LDA #$0000 : STA !MapLight_X+30
	LDA #$0000 : STA !MapLight_Y+30
	LDA #$0180 : STA !MapLight_R+30
	LDA #$0040 : STA !MapLight_G+30
	LDA #$0040 : STA !MapLight_B+30


		JSR CalcLightPoints
		SEP #$20
		LDA !ProcessLight			;\
		CMP #$02 : BNE ..noshade		; | start new shade operation when previous one finishes
		STZ !ProcessLight			; |
		..noshade				;/
		REP #$20




	; draw character faces on HUD
		.DrawChar
		LDA !OAMindex_p3 : TAX
		LDA #$0880 : STA !OAM_p3+$000,x
		LDA !Characters
		AND #$00F0
		LSR #3
		CLC : ADC #$3FE4
		STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA #$02 : STA !OAMhi_p3,x
		REP #$20
		INX
		TXA
		ASL #2
		TAX
		LDA #$08B0 : STA !OAM_p3+$000,x
		LDA !MultiPlayer
		AND #$00FF : BNE +
		LDA #$3FA0 : BRA ++
	+	LDA !Characters
		AND #$000F
		ASL 	
		CLC : ADC #$3FE4
	++	STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA #$02 : STA !OAMhi_p3,x
		REP #$20
		INX
		TXA
		ASL #2
		TAX
		..done
		TXA : STA !OAMindex_p3


		LDA !CharMenu
		AND #$00FF : BNE +
		JSR Player
		; sprite call
		JSR OAM_sort


		+
		SEP #$10				;\ regs: A 16-bit, index 8-bit
		REP #$20				;/
		LDA $1A : STA $1E			;\ layer 2 positions
		LDA $1C : STA $20			;/

		LDA #$7FFF : STA !Color0

		SEP #$20				; 8-bit A

		LDA #$00 : STA !DizzyEffect		; cancel dizzy
		LDA #$08 : TRB !2105
		LDA #$1D : STA !MainScreen
		STZ !SubScreen

		JSL CLEAR_MSG_SA1
		JSL CLEAR_PLAYER2

	LDA #$01 : STA !StoryFlags

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
		LDX !CharMenu : BEQ .NoCharSelect

		LDA #$01
		STA !ShaderRowDisable+$C
		STA !ShaderRowDisable+$D
		STA !ShaderRowDisable+$E

		CPX #$01 : BEQ .Opening
		CPX #$03 : BEQ .Closing
		JMP .HandleCharSelect

		.Opening
		LDA !CharMenuSize				; grows by 16px/frame
		CLC : ADC #$10
		STA !CharMenuSize : BNE +
		LDA #$FF : STA !CharMenuSize
		INC !CharMenu
		STZ !UploadPlayerPal				; upload player palette
		LDX #$00 : JSR Portrait_0			; Upload portrait at t = 0xFF
		+
		JMP Draw

		.Closing
		LDA !CharMenuSize
		SEC : SBC #$10
		STA !CharMenuSize
		BCS +
		STZ !CharMenu
		STZ !CharMenuSize
		+
		JMP Draw

		.NoCharSelect
		LDA $6DA6 : BPL +
		LDA !Translevel : BEQ +
		BRA ++
		+
		LDA $6DA6
		AND #$20 : BEQ +
		STZ !Translevel
	++	INC !GameMode
		REP #$20
		LDA !P1MapX : STA !SRAM_overworldX
		LDA !P1MapY : STA !SRAM_overworldY
		SEP #$20
		JSL !SaveGame
		PLP
		PLB
		RTL
		+

		LDA $6DA6
		AND #$10 : BEQ +
		LDA !CharMenu : BNE +
		INC !CharMenu
		STZ !SelectingPlayer
		+

		LDA $6DA7
		AND #$10 : BEQ +
		LDA !CharMenu : BNE +
		INC !CharMenu
		LDA #$01 : STA !SelectingPlayer
		+
		PLP
		PLB
		RTL


		.HandleCharSelect
		LDA !CharMenuCursor : STA $00

		LDA !SelectingPlayer				;\
		CLC : ADC #$05					; |
		STA $0E						; | Menu size depending on player
		INC A						; |
		STA $0F						;/
		LDY !SelectingPlayer				;\
		LDA $6DA6,y					; |
		AND #$0C : BEQ ..NoI				; |
		LDX #$06 : STX !SPC4				; > SFX
		CMP #$08 : BCS ..U				; |
	..D	INC !CharMenuCursor				; |
		BRA ..NoI					; | Handle character select cursor
	..U	DEC !CharMenuCursor				; |
	..NoI	LDA !CharMenuCursor : BPL ..Pos			; |
		LDA $0E : STA !CharMenuCursor			; |
		BRA ..Go					; |
	..Pos	CMP $0F : BCC ..Go				; |
		STZ !CharMenuCursor				; |
		..Go						;/

		LDA !CharMenuCursor
		CMP $00 : BEQ ..NoUpdate
		STZ !UploadPlayerPal				; upload player pal
		JSR Portrait
		..NoUpdate


		LDA $6DA6,y
		CMP #$10 : BCS $03 : JMP Draw
		INC !CharMenu					; close char menu

		REP #$20					;\
		LDA #$005E					; |
		STA.l !VRAMbase+!CGRAMtable+0			; |
		LDA.w #Portrait_RestorePal			; |
		STA.l !VRAMbase+!CGRAMtable+2			; | Restore palette
		SEP #$20					; |
		LDA.b #Portrait_RestorePal>>16			; |
		STA.l !VRAMbase+!CGRAMtable+4			; |
		LDA #$C1					; |
		STA.l !VRAMbase+!CGRAMtable+5			;/
		LDA !CharMenuCursor : STA $0F
		STZ !CharMenuCursor
		LDA !SelectingPlayer : BNE ..P2

	..P1	LDA !Characters					;\
		AND #$0F					; |
		STA $0E						; |
		LDA $0F : STA !P2Character-$80			; | Set player 1 char
		ASL #4						; |
		ORA $0E						; |
		STA !Characters					; |
		BRA +						;/

	..P2	LDA $0F						;\
		CMP #$06 : BNE ...Y				; |
		LDA #$00 : STA !MultiPlayer			; |
		BRA +						; |
	...Y	STA !P2Character				; | Set player 2 char
		LDA !Characters					; |
		AND #$F0					; |
		ORA $0F						; |
		STA !Characters					; |
		LDA !MultiPlayer : BNE ++
		LDA !P1MapX : STA !P2MapX
		LDA !P1MapX+1 : STA !P2MapX+1
		LDA !P1MapY : STA !P2MapY
		LDA !P1MapY+1 : STA !P2MapY+1
	++	LDA #$01 : STA !MultiPlayer			;/

	+	JMP Draw
		.NoChar

		PLP
		PLB
		RTL



	Draw:
		PEA Window-1
		LDA !CharMenu
		CMP #$02 : BEQ .Char				; don't draw anything else during char menu
		JMP .Normal

	.Char	REP #$30
		LDX.w #CharTilemap_End-CharTilemap
		LDA !SelectingPlayer : BEQ +
		LDX.w #CharTilemap_End2-CharTilemap
		+

		STX $00						;\
		LDA !OAMindex_p3 : TAX				; |
		LDY #$0000					; |
	-	LDA CharTilemap,y : STA !OAM_p3,x		; |
		LDA CharTilemap+2,y : STA !OAM_p3+2,x		; |
		TXA						; |
		LSR #2						; |
		TAX						; |
		SEP #$20					; | draw text for character select menu
		LDA #$00 : STA !OAMhi_p3,x			; |
		REP #$20					; |
		INX						; |
		TXA						; |
		ASL #2						; |
		TAX						; |
		INY #4						; |
		CPY $00 : BCC -					;/


		SEP #$20					;\
		LDA !CharMenuCursor				; |
		ASL #3						; |
		CLC : ADC #$1E					; |
		CMP #$4E					; |
		BCC $02 : LDA #$56				; |
		STA !OAM_p3+$01,x				; |
		LDA #$10 : STA !OAM_p3+$00,x			; |
		LDA #$AE : STA !OAM_p3+$02,x			; |
		LDA #$31 : STA !OAM_p3+$03,x			; |
		REP #$20					; | draw menu cursor
		TXA						; |
		LSR #2						; |
		TAX						; |
		SEP #$20					; |
		LDA #$00 : STA !OAMhi_p3,x			; |
		REP #$20					; |
		INX						; |
		TXA						; |
		ASL #2						; |
		TAX						; |
		STA !OAMindex_p3				;/


		LDA !CharMenuCursor				;\
		AND #$00FF					; |
		TAY						; |
		LDA Portrait_Table-1,y : BPL ..drawportrait	; |
		JMP ..NoPortrait				; |
		..drawportrait					; |
		PHY						; |
		LDY #$0000					; |
	-	LDA.w Portrait_Tilemap,y : STA !OAM_p3,x	; |
		LDA.w Portrait_Tilemap+2,y : STA !OAM_p3+2,x	; |
		TXA						; |
		LSR #2						; |
		TAX						; | draw character portrait
		SEP #$20					; |
		LDA #$02 : STA !OAMhi_p3,x			; |
		REP #$20					; |
		INX						; |
		TXA						; |
		ASL #2						; |
		TAX						; |
		INY #4						; |
		CPY #$0020 : BCC -				; |
		TXA : STA !OAMindex_p3				;/

		PLA						;\
		ASL #2						; |
		TAX						; |
		REP #$20					; | get character data
		LDA Portrait_CharPtr,x				; |
		CMP #$FFFF : BNE $03 : JMP ..NoPortrait		; |
		STA $00						; |
		LDA Portrait_CharPtr+2,x : STA $0C		;/


		SEP #$10


		LDA ($0C) : STA $3700+0				;\
		INC $0C						; | dynamo header
		INC $0C						;/
		LDY #$00					; starting index = 00
	-	TYX						; update $3700 index
		LDA ($0C),y : STA $3700+2,x			;\ upload size
		INY #2						;/
		LDA ($0C),y					;\
		AND #$00FF					; |
		PHY						; |
		TAY						; |
		JSL !GetFileAddress				; | source address
		PLY						; |
		LDA !FileAddress+1 : STA $3700+5,x		; > source bank
		INY						; |
		LDA ($0C),y					; |
		CLC : ADC !FileAddress+0			; |
		STA $3700+4,x					; |
		INY #2						;/
		LDA ($0C),y : STA $3700+7,x			;\ dest VRAM
		INY #2						;/
		CPY $3700+0 : BCC -				; loop
		LDA.w #$3700 : STA $0C				; pointer ($3700)
		..DynDone

		REP #$30					;\
		LDA ($00)					; |
		AND #$00FF					; |
		STA $02						; |
		INC $00						; |
		LDY #$0000					; |
		LDA !OAMindex_p3 : TAX				; |
	-	LDA ($00),y : STA !OAM_p3+0,x			; |
		INY #2						; |
		LDA ($00),y : STA !OAM_p3+2,x			; |
		TXA						; |
		LSR #2						; |
		TAX						; | draw character
		SEP #$20					; |
		LDA #$02 : STA !OAMhi_p3,x			; |
		REP #$20					; |
		INX						; |
		TXA						; |
		ASL #2						; |
		TAX						; |
		INY #2						; |
		CPY $02 : BCC -					; |
		TXA : STA !OAMindex_p3				; |
		SEP #$30					;/
		CLC : JSL !UpdateGFX				; > load character GFX

		..NoPortrait
		SEP #$30
		RTS


		.Normal
		.Full
		RTS



	KillVR3:
		LDA #$00 : STA !VRAMbase+!VRAMtable+$3FF
		REP #$30
		LDA.w #$03FE
		LDX.w #!VRAMtable+$3FF
		LDY.w #!VRAMtable+$3FE
		MVP $40,$40
		RTS





	Window:
;		LDA.b #.SNES : STA $0183
;		LDA.b #.SNES>>8 : STA $0184
;		LDA.b #.SNES>>16 : STA $0185
;		LDA #$D0 : STA $2209
;	-	LDA $018A : BEQ -
;		STZ $018A

		PLP				;\
		PLB				; | Restore stuff and return
		RTL				;/




		.SNES
		PHK : PLB
		SEP #$30

		LDA #$3F : TRB $40		;\ no color math
		STZ $44				;/
		LDA #$22 : STA $41		;\ hide BG1/BG2 inside window, show BG3 ONLY inside window
		LDA #$03 : STA $42		;/
		STZ $43				; > enable sprites within window
		STZ $4324			; bank 0x00 for both channels
		REP #$20
		LDA #$2601 : STA $4320		; > regs 2126 and 2127
		LDA #$0200 : STA !HDMA2source	; > table at $0200

		LDA #$00FF			;\
		STA $0201			; |
		STA $0204			; | Default window table (no window)
		STA $0207			; |
		STA $020A			;/

		SEP #$20
		LDA #$04 : TSB !HDMA		; Enable HDMA

		LDA #$07 : STA $0200		;\
		LDA #$40			; |
		STA $0203			; | Base windowing table
		STA $0206			; |
		LDA #$01 : STA $0209		; |
		STZ $020C			;/

		LDA !CharMenu : BEQ ..R		;\
		LDA #$07 : STA $0200		; |
		LDA #$70			; |
		STA $0203			; |
		LDA #$01 : STA $0206		; |
		STZ $0209			; | Char menu windowing table
		STZ $0202			; |
		STZ $0204			; |
		STZ $0208			; |
		LDA #$FF			; |
		STA $0201			; |
		STA $0207			; |
		LDA !CharMenuSize		; |
		STA $0205			; |
		LDA #$22			; |
		STA $41				; |
		STA $42				; |
		STZ $43				; |
		LDA !CharMenu			; |
		LSR A : BCC ..R			; > Disable sprite window when char menu is fully open
		LDA #$02 : STA $43		; |
	..R	RTL				;/





	Portrait:

		LDX !CharMenuCursor
	.0	LDA.w .Table,x : BPL .Valid
		RTS


		.Valid
		TXA								;\
		ASL A								; |
		PHA								; |
		ASL A								; | portrait address
		TAX								; |
		LDA.l !PortraitPointers+2,x : STA $00				; |
		LDA.l !PortraitPointers+3,x : STA $01				; |
		LDA.l !PortraitPointers+4,x : STA $02				; |
		LDA #$10 : STA $03						;/

		LDA #$00 : XBA
		TXA								;\
		REP #$20							; |
		ASL #3								; |
		CLC : ADC.w #!PlayerPalettes					; |
		STA $0D								; | Player palette in !BigRAM
		SEP #$20							; |
		LDA.b #!PlayerPalettes>>16 : STA $0F				; |
		LDY #$1F							; |
	-	LDA [$0D],y : STA !BigRAM+$3E,y					; |
		DEY : BPL -							;/

		PLX								;\
		LDA.b #!PortraitPointers>>16 : STA $0F				; |
		LDA #$00							; |
		STA.l !VRAMbase+!CGRAMtable+4					; |
		REP #$20							; |
		LDA.l (!PortraitPointers&$FF0000)+read2(!PortraitPointers)+0,x	; |
		STA $0D								; |
		LDY #$3C							; |
	-	LDA [$0D],y : STA !BigRAM,y					; | upload player and portrait palettes
		DEY #2 : BPL -							; |
		LDA.w #!BigRAM							; |
		STA.l !VRAMbase+!CGRAMtable+2					; |
		LDA #$005E							; |
		LDY !UploadPlayerPal						; \ upload player pal clause
		BEQ $03 : LDA #$003E						; /
		STA.l !VRAMbase+!CGRAMtable+0					; |
		SEP #$20							; |
		LDA #$C1							; |
		STA.l !VRAMbase+!CGRAMtable+5					;/

		JSL PLANE_SPLIT_SA1						; > unpack 5bpp portrait

		PHB
		LDA.b #!VRAMbank
		PHA : PLB

		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x				; upload size = .5 KB
		LDA.w #!BufferLo : STA !CCDMAtable+$02,x			; source address = !BufferLo
		LDA #$7600 : STA !CCDMAtable+$05,x				; dest VRAM = 0x7600
		SEP #$20
		LDA.b #!BufferLo>>16 : STA !CCDMAtable+$04,x			; source bank
		LDA #$09 : STA !CCDMAtable+$07,x				; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x				; upload size = .5 KB
		LDA.w #!BufferLo+$100 : STA !CCDMAtable+$02,x			; source address = !BufferLo+$100
		LDA #$7700 : STA !CCDMAtable+$05,x				; dest VRAM = 0x7700
		SEP #$20
		LDA.b #!BufferLo>>16 : STA !CCDMAtable+$04,x			; source bank
		LDA #$09 : STA !CCDMAtable+$07,x				; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x				; upload size = .5 KB
		LDA.w #!BufferHi : STA !CCDMAtable+$02,x			; source address = !BufferHi
		LDA #$7680 : STA !CCDMAtable+$05,x				; dest VRAM = 0x7680
		SEP #$20
		LDA.b #!BufferHi>>16 : STA !CCDMAtable+$04,x			; source bank
		LDA #$09 : STA !CCDMAtable+$07,x				; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x				; upload size = .5 KB
		LDA.w #!BufferHi+$100 : STA !CCDMAtable+$02,x			; source address = !BufferHi+$100
		LDA #$7780 : STA !CCDMAtable+$05,x				; dest VRAM = 0x7780
		SEP #$20
		LDA.b #!BufferHi>>16 : STA !CCDMAtable+$04,x			; source bank
		LDA #$09 : STA !CCDMAtable+$07,x				; settings = 4bpp, 32px

		PLB
		RTS

	.Long	PHB : PHK : PLB
		PHA
		PHY
		LDA #$01 : STA !UploadPlayerPal					; don't upload player pal
		JSR .0

		LDA.b #!VRAMbank						;\
		PHA : PLB							; |
		PLA : STA !CGRAMtable+5						; > adjust palette
		PLA								; |
		STA !VRAMtable+$06,x						; |
		STA !VRAMtable+$14,x						; |
		STA !VRAMtable+$22,x						; | adjust upload destination
		STA !VRAMtable+$30,x						; |
		INC A								; |
		STA !VRAMtable+$0D,x						; |
		STA !VRAMtable+$1B,x						; |
		STA !VRAMtable+$29,x						; |
		STA !VRAMtable+$37,x						;/

		PLB
		RTL



		.Table		; portrait index
		db $00
		db $01
		db $02
		db $03
		db $FF
		db $FF
		db $FF
		db $07		; special tinker portrait


		.Tilemap	; OAM data
		db $C0,$20,$60,$39
		db $D0,$20,$62,$39
		db $C0,$30,$64,$39
		db $D0,$30,$66,$39
		db $C0,$20,$68,$3B
		db $D0,$20,$6A,$3B
		db $C0,$30,$6C,$3B
		db $D0,$30,$6E,$3B


		.RestorePal
		dw $7FFF,$0000,$0523,$05E5,$0B0F,$26E0,$1BAE,$054A	; pal 8
		dw $1E72,$7E69,$0D4E,$11B5,$1E59,$26FA,$0000
		dw $0000,$0000,$2CE7,$3D6B,$51EF,$6294,$7318,$34E4	; pal 9
		dw $4DC1,$6D80,$35EC,$3A72,$0523,$1D46,$25C6,$1AC5
		dw $0000,$0000,$575F,$36BF,$2DD7,$2D52,$28EA,$494D	; pal A
		dw $55B1,$6253,$5D4A,$7DAA,$7E69,$0523,$05E5,$0B0F


macro CharDyn(file, tiles, source, dest)
	dw <tiles>*$20
	db <file>
	dw <source>*$20
	dw <dest>*$10+$6000
endmacro

		.CharPtr
		dw .MarioTM,.MarioDyn
		dw .LuigiTM,.LuigiDyn
		dw .KadaalTM,.KadaalDyn
		dw .LeewayTM,.LeewayDyn
		dw $FFFF,$FFFF
		dw $FFFF,$FFFF
		dw $FFFF,$FFFF

		.MarioTM
		db $07
		db $80,$20,$0C,$3D
		db $80,$30,$0E,$3D

	; tile $004 is the body
	; tile $0E0 is the head

		.MarioDyn
		dw ..End-..Start
		..Start
		%CharDyn(!File_Mario, 2, $000, $10C)
		%CharDyn(!File_Mario, 2, $010, $11C)
		%CharDyn(!File_Mario, 2, $020, $10E)
		%CharDyn(!File_Mario, 2, $030, $11E)
		..End


		.LuigiTM
		db $07
		db $80,$20,$0C,$3D
		db $80,$30,$0E,$3D


		.LuigiDyn
		dw ..End-..Start
		..Start
		%CharDyn(!File_Luigi, 2, $000, $10C)
		%CharDyn(!File_Luigi, 2, $010, $11C)
		%CharDyn(!File_Luigi, 2, $020, $10E)
		%CharDyn(!File_Luigi, 2, $030, $11E)
		..End


		.KadaalTM
		db $07
		db $80,$20,$0C,$3D
		db $80,$30,$0E,$3D

		.KadaalDyn
		dw ..End-..Start
		..Start
		%CharDyn(!File_Kadaal, 2, $000, $10C)
		%CharDyn(!File_Kadaal, 2, $010, $11C)
		%CharDyn(!File_Kadaal, 2, $020, $10E)
		%CharDyn(!File_Kadaal, 2, $030, $11E)
		..End


		.LeewayTM
		db $13
		db $75,$38,$4C,$3D		; sword
		db $7D,$38,$4D,$3D
		db $80,$20,$0C,$3D		; body
		db $80,$30,$2C,$3D
		db $88,$30,$2D,$3D

		.LeewayDyn
		dw ..End-..Start
		..Start
		%CharDyn(!File_Leeway, 2, $000, $10C)
		%CharDyn(!File_Leeway, 2, $010, $11C)
		%CharDyn(!File_Leeway, 3, $020, $12C)
		%CharDyn(!File_Leeway, 3, $030, $13C)
		%CharDyn(!File_Leeway_Sword, 3, $008, $14C)
		%CharDyn(!File_Leeway_Sword, 3, $018, $15C)
		..End



	CharTilemap:
		db $20,$1F,$8C,$31	; M
		db $28,$1F,$80,$31	; A
		db $30,$1F,$91,$31	; R
		db $38,$1F,$88,$31	; I
		db $40,$1F,$8E,$31	; O

		db $20,$27,$8B,$31	; L
		db $28,$27,$94,$31	; U
		db $30,$27,$88,$31	; I
		db $38,$27,$86,$31	; G
		db $40,$27,$88,$31	; I

		db $20,$2F,$8A,$31	; K
		db $28,$2F,$80,$31	; A
		db $30,$2F,$83,$31	; D
		db $38,$2F,$80,$31	; A
		db $40,$2F,$80,$31	; A
		db $48,$2F,$8B,$31	; L

		db $20,$37,$8B,$31	; L
		db $28,$37,$84,$31	; E
		db $30,$37,$84,$31	; E
		db $38,$37,$96,$31	; W
		db $40,$37,$80,$31	; A
		db $48,$37,$98,$31	; Y

		db $20,$3F,$80,$31	; A
		db $28,$3F,$8B,$31	; L
		db $30,$3F,$93,$31	; T
		db $38,$3F,$84,$31	; E
		db $40,$3F,$91,$31	; R

		db $20,$47,$8F,$31	; P
		db $28,$47,$84,$31	; E
		db $30,$47,$80,$31	; A
		db $38,$47,$82,$31	; C
		db $40,$47,$87,$31	; H


		.End

		db $20,$57,$83,$31	; D
		db $28,$57,$91,$31	; R
		db $30,$57,$8E,$31	; O
		db $38,$57,$8F,$31	; P
		db $48,$57,$8E,$31	; O
		db $50,$57,$94,$31	; U
		db $58,$57,$93,$31	; T
		.End2



	HDMA:
	; direct -> 2108
	.Tilemap
		db $20 : db $50
		db $01 : db $48
		db $00

	; indirect -> 210F, B = K
	.Coords
		db $20 : dw ..hud
		db $01 : dw $301E
		db $00

		..hud
		dw $0000,$FFFF

	; indirect -> 212C, B = K
	.MainScreen
		db $20 : dw ..hud
		db $01 : dw !MainScreen
		db $00


		..hud
		db $12		; BG2 + sprites only


	namespace off