print "REALM SELECT INSERTED AT $", pc, "!"

	namespace LevelSelect


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



	!LevelSelectBase	=	$6DDF

	!MenuPosition		=	!LevelSelectBase+$000
	!MenuMode		=	!LevelSelectBase+$002
					; 00 = select realm
					; 01 = select level
					; 02 = load level

	!SelectedLevel		=	!LevelSelectBase+$004	; written to !Translevel
	!NameIndex		=	!LevelSelectBase+$006	; used during stripe upload

	!CharMenuSize		=	!LevelSelectBase+$008
	!CharMenu		=	!LevelSelectBase+$00A
					; 00 = no char menu
					; 01 = char menu opening
					; 02 = char menu open
					; 03 = char menu closing

	!CharMenuCursor		=	!LevelSelectBase+$00C
	!SelectingPlayer	=	!LevelSelectBase+$00E	; who is controlling the char select
								; 0 = player 1
								; 1 = player 2
								; only player 2 can choose "drop out"


	!UploadPlayerPal	=	!LevelSelectBase+$010	; 0 = upload, 1 = don't upload
	!UploadTilemap		=	!LevelSelectBase+$012	; 0 = upload, 1 = don't upload


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

	org $00A134
		LDA #$0000		; coords for base OW position
	org $00A13B
		LDA #$0000

	org $00A153
		JSL LOAD		; org: LDA #$06 : STA $12 : JSR $85D2
		BRA $01
		NOP			; this removes the overworld border

	org $00A165
		BRA $02 : NOP #2	; org: JSL $04D6E9
					; skip Lunar Magic's overworld layer 2 tilemap loader

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

	org $048249
		BRA +			; org: AND #$20
	org $048295
	+	JML MAIN

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

	LOAD:
		PHB
		PHP
		SEP #$30
		LDX #$13
	-	STZ !LevelSelectBase,x
		DEX : BPL -
		LDA #$01 : STA $3E

		LDA #$80 : STA $2100
		STZ $2115					;\
		REP #$20					; |
		LDA #$1808 : STA $4310				; |
		LDA.w #.Tilemap : STA $4312			; | tile numbers for first half of BG2
		LDX.b #.Tilemap>>16 : STX $4314			; |
		LDA #$0200 : STA $4315				; |
		LDA #$3800 : STA $2116				; |
		LDX #$02 : STX $420B				;/
		LDA #$1808 : STA $4310				;\
		LDA.w #.Tilemap+2 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | tile numbers for second half of BG2
		LDA #$0200 : STA $4315				; |
		LDX #$02 : STX $420B				;/
		LDA #$1808 : STA $4310				;\
		LDA.w #.Tilemap+4 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | clear BG1 tilemap (tiles)
		LDA #$0400 : STA $4315				; |
		LDA #$3000 : STA $2116				; |
		LDX #$02 : STX $420B				;/
		LDX #$80 : STX $2115				;\
		LDA #$1908 : STA $4310				; |
		LDA.w #.Tilemap+1 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | YXPCCCTT for first half of BG2
		LDA #$0200 : STA $4315				; |
		LDA #$3800 : STA $2116				; |
		LDX #$02 : STX $420B				;/
		LDA #$1908 : STA $4310				;\
		LDA.w #.Tilemap+3 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | YXPCCCTT for second half of BG2
		LDA #$0200 : STA $4315				; |
		LDX #$02 : STX $420B				;/
		LDA #$1908 : STA $4310				;\
		LDA.w #.Tilemap+5 : STA $4312			; |
		LDX.b #.Tilemap>>16 : STX $4314			; | clear BG1 tilemap (YXPCCCTT)
		LDA #$0400 : STA $4315				; |
		LDA #$3000 : STA $2116				; |
		LDX #$02 : STX $420B				;/

		SEP #$30
		LDA !2107
		AND.b #$03^$FF
		STA !2107
		LDA !2108
		AND.b #$03^$FF
		STA !2108

		JSL Window_SNES
		PLP
		PLB
		JMP KILL_OAM


	.Tilemap
		dw $1869	; first half of BG2 (16 rows)
		dw $1C69	; second half of BG2(16 rows)
		dw $009F	; BG1 (invisible)


	MAIN:
		PHK : PLB			; Get bank
		REP #$20			;\
		STZ $1A				; |
		STZ $1C				; | Layer 1 & 2 positions
		STZ $1E				; |
		STZ $20				;/

		LDA #$0040 : STA $22
		LDA #$0008 : STA $24

		SEP #$20			; 8-bit A
		LDA #$00 : STA !DizzyEffect	; cancel dizzy

;		PHP				;\
;		LDY #$5F			; |
;	-	LDA !LevelTable,y		; | autosave
;		AND.b #$40^$FF			; | (don't include midway points)
;		STA $7F49,y			; |
;		DEY : BPL -			; |
;		LDA $7F2E : STA $7FD5		; > include number of levels beaten
;		JSL $009BC9			; |
;		PLP				;/

		LDA #$08 : TRB $3E
		LDA #$1F : STA $6D9D
		STZ $6D9E

		JSL CLEAR_MSG_SA1
		JSL CLEAR_PLAYER2

	LDA #$01 : STA !StoryFlags

		STZ !LevelSelectBase+$1
		STZ !LevelSelectBase+$3
		STZ !LevelSelectBase+$5
		STZ !LevelSelectBase+$7
		STZ !LevelSelectBase+$9
		STZ !LevelSelectBase+$B
		STZ !LevelSelectBase+$D
		STZ !LevelSelectBase+$F

	; Check controls here

		STZ $00
		STZ $01
		LDA !MultiPlayer : BEQ .SinglePlayer
		LDA $6DA7 : STA $00
		LDA $6DA9 : STA $01

		.SinglePlayer
		LDA $6DA6 : TSB $00
		LDA $6DA8 : TSB $01


	; $00-$01 now hold proper button input


	Controls:
		LDA !CharMenu : BNE $03 : JMP .NoChar
		CMP #$02 : BEQ .CharMenu
		BCC +
		LDA !CharMenuSize
		SEC : SBC #$10
		STA !CharMenuSize
		BCS ++
		STZ !CharMenu
		STZ !CharMenuSize
	++	JMP Draw

	+	LDA !CharMenuSize				; grows by 16px/frame
		CLC : ADC #$10
		STA !CharMenuSize : BNE +
		LDA #$FF : STA !CharMenuSize
		INC !CharMenu
		STZ !UploadPlayerPal				; upload player palette
		LDX #$00 : JSR Portrait_0			; Upload portrait at t = 0xFF
	+	JMP Draw

		.CharMenu
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
		CMP #$10 : BCC +
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
		LDA $0F						; | Set player 1 char
		ASL #4						; |
		ORA $0E						; |
		STA !Characters					; |
		BRA +						;/

	..P2	LDA $0F						;\
		CMP #$06 : BNE ...Y				; |
		LDA #$00 : STA !MultiPlayer			; |
		BRA +						; |
	...Y	LDA !Characters					; | Set player 2 char
		AND #$F0					; |
		ORA $0F						; |
		STA !Characters					; |
		LDA #$01 : STA !MultiPlayer			;/

	+	JMP Draw
		.NoChar


		LDA $00						;\
		AND #$20 : BEQ +				; |
		STZ !Translevel					; | Go straight to home base if select is pushed
		INC !GameMode					; |
		JMP Draw					;/
	+	LDA !MenuMode : BNE .Mode1
		JMP .Mode0


	; MODE 1 CODE HERE
		.Mode1
		LDA $00						;\
		ORA $01						; |
		ASL A : BCS ..Pick				; | handle A/B/X/Y
		ASL A : BCC ..Main				; |
		BRA ..Back					; |
	..Pick	INC !GameMode					;/
		PLB
		RTL


	..Main	LDA $00
		AND #$0C : BEQ ..Wrap
		LDX #$06 : STX !SPC4				; SFX
		CMP #$04 : BEQ ..D
		CMP #$08 : BNE ..Wrap

	..U	DEC !SelectedLevel
		BRA ..Wrap
	..D	INC !SelectedLevel


	; generate level matrix in !BigRAM
	; select from there
	; makes it easier to not have weird spaces in the list

	..Wrap	LDX !MenuPosition
		REP #$20
		LDA LevelIndex,x
		AND #$00FF
		CLC : ADC.w #LevelList
		STA $0E
		SEP #$20
		LDA LevelCount,x : STA $0D			; limit in $0D
		LDX #$00					;\
		TXY						; |
	-	LDA ($0E),y					; |
		PHX						; |
		TAX						; | copy a list of unlocked levels to !BigRAM+1
		LDA !LevelTable4,x				; |
		PLX						; |
		ASL A : BCC +					; |
		LDA ($0E),y : STA !BigRAM+1,x			; |
		INX						; |
	+	INY						; |
		CPY $0D : BNE -					;/
		STX !BigRAM+0					; number of levels in !BigRAM+0
		CPX #$02 : BCS ..NoSilence
		STZ !SPC4

		..NoSilence


		LDA !SelectedLevel : BPL +			;\
		LDA !BigRAM+0					; |
		DEC A						; | wrap up -> bottom
		STA !SelectedLevel				; |
		BRA ++						;/
	+	CMP !BigRAM+0					;\
		BCC ++						; | Wrap down -> top
		STZ !SelectedLevel				;/
		++

		LDX !SelectedLevel
		LDA !BigRAM+1,x : STA !Translevel

	..R	JMP Draw


	..Back	DEC !MenuMode
		STZ !SelectedLevel



	; MODE 0 CODE HERE
		.Mode0
		LDA $00
		LSR A : BCS .R
		LSR A : BCS .L
		LSR A : BCS .D
		LSR A : BCC .NoDir

	.U	LDA !MenuPosition
		LSR A : BCC .D_Go
	..Go	LDA #$FF
		BRA .Dir

	.D	LDA !MenuPosition
		LSR A : BCS .U_Go
	..Go	LDA #$01
		BRA .Dir

	.L	LDA #$FE
		BRA .Dir

	.R	LDA #$02

		.Dir				;\
		STA $0F				; |
	-	CLC : ADC !MenuPosition		; |
		AND #$07			; |
		STA !MenuPosition		; |
		TAX				; | move cursor and keep it in bounds
		LDA #$06 : STA !SPC4		; > SFX
		LDA Bit,x			; |
		AND !StoryFlags : BNE .NoDir	; |
		LDA $0F				; |
		BRA -				; > loop until cursor is within bounds
		.NoDir				;/

		LDA $6DA6
		AND #$10 : BEQ +
		LDA #$01 : STA !CharMenu	; opening char menu for p1
		STZ !SelectingPlayer
		BRA .NoConfirm
	+	LDA $6DA7
		AND #$10 : BEQ .NoOpen
		LDA #$01
		STA !CharMenu			; opening char menu for p2
		STA !SelectingPlayer
		BRA .NoConfirm
		.NoOpen

		LDA $00
		ORA $01
		BPL .NoConfirm
		LDX !MenuPosition
		LDA Bit,x
		AND !StoryFlags
		BEQ .NoConfirm
		INC !MenuMode
		STZ $00
		STZ $01
		JMP .Mode1_Main
		.NoConfirm


	Draw:
		JSL KILL_OAM_SA1		; Clear all other sprites
		PEA Window-1
		LDA !CharMenu
		CMP #$02 : BEQ .Char		; Don't draw anything else during char menu
		JMP .Normal

	.Char	REP #$30
		LDX.w #CharTilemap_End-CharTilemap-2
		LDA !SelectingPlayer : BEQ +
		LDX.w #CharTilemap_End2-CharTilemap-2
		+
	-	LDA CharTilemap,x : STA !OAM,x
		DEX #2 : BPL -
		SEP #$30
		LDX #$3F
		LDA #$02
	-	STZ !OAMhi,x
		STA !OAMhi+$40,x
		DEX : BPL -

		LDA !CharMenuCursor
		ASL #3
		CLC : ADC #$1E
		CMP #$4E : BCC +

;	CMP #$3E : BCC +

		LDA #$56
	+	STA !OAM+$FD
		LDA #$10 : STA !OAM+$FC
		LDA #$AE : STA !OAM+$FE
		LDA #$31 : STA !OAM+$FF

		LDX !CharMenuCursor
		LDA Portrait_Table,x : BMI ..NoPortrait
		LDY #$1F
	-	LDA.w Portrait_Tilemap,y : STA !OAM+$100,y
		DEY : BPL -

		TXA
		ASL #2
		TAX
		REP #$20
		LDA Portrait_CharPtr,x
		CMP #$FFFF : BEQ ..NoPortrait
		STA $00
		LDA Portrait_CharPtr+2,x : STA $0C
		LDA ($00)
		INC $00
		SEP #$20
		TAY
	-	LDA ($00),y : STA !OAM+$120,y
		DEY : BPL -
		CLC : JSL !UpdateGFX

		..NoPortrait
		SEP #$20

		RTS


		.Normal
		LDA !MenuMode : BEQ .Realm
		JMP .Level
	.Realm	LDA !CharMenu : BEQ .Full
		REP #$30
		LDY #$011E
	-	LDA RealmTilemap,y : STA !OAM,y
		DEY #2 : BPL -
		SEP #$30
		BRA .OAMhi

	.Full	LDA !MenuPosition
		ASL A
		TAY
		REP #$30
		LDA SelectOffset,y : STA $04	; X/Y offset for selection shadow
		LDA SelectIndex,y : STA $00	;\ 
		INY #2				; | index paremeters for selected tilemap
		LDA SelectIndex,y : STA $02	;/
		LDX #$0138

	-	LDA RealmTilemap+0,x
		CPX #$0120 : BCC ++
		CLC : ADC $04
		BRA +
	++	CPX $00 : BCC +
		CPX $02 : BCS +
		SEC : SBC #$0303
	+	STA !OAM+0,x
		LDA RealmTilemap+2,x : STA !OAM+2,x
		DEX #4 : BPL -

		SEP #$30
	.OAMhi	LDX #$7F
		LDA #$02
	-	STA !OAMhi,x
		DEX : BPL -

		.UnlockCorrection		; Set Y disp to 0xF0 for tiles belonging to closed realms
		LDY #$07
	-	LDA !StoryFlags
		AND Bit,y : BNE +
		REP #$30
		PHY
		TYA
		ASL A
		TAY
		LDX SelectIndex,y
		INY #2
		LDA SelectIndex,y : STA $00
		SEP #$20
		LDA #$F0
	--	STA !OAM+1,x
		INX #4
		CPX $00 : BNE --
		PLY
		SEP #$30
	+	DEY : BPL -
		RTS


	.Level	STZ !OAMindex
		STZ !OAMindex+1
		LDA #$04 : STA !OAM+$1D4	;\
		LDA !SelectedLevel		; |
		ASL #3				; |
		CLC : ADC #$8F			; | level list cursor position
		STA !OAM+$1D5			; |
		LDA #$AE : STA !OAM+$1D6	; |
		LDA #$2F : STA !OAM+$1D7	;/
		LDX #$75			;\
	-	STZ !OAMhi,x			; |
		DEX : BPL -			; |
		LDA #$02			; | set OAM size (all small except last 10 tiles)
		LDX #$09			; |
	-	STA !OAMhi+$76,x		; |
		DEX : BPL -			;/


		LDA !MenuPosition			;\
		ASL A					; |
		TAY					; |
		REP #$30				; |
		LDX SelectIndex,y			; |
		LDA SelectIndex+2,y : STA $00		; |
		LDY #$0000				; | draw realm icon
	-	LDA RealmTilemap,x			; |
		AND #$3F3F				; |
		STA !OAM+$1DC,y				; |
		LDA RealmTilemap+2,x : STA !OAM+$1DE,y	; |
		INY #4					; |
		INX #4					; |
		CPX $00 : BNE -				; |
		SEP #$30				;/


		LDA !BigRAM+0 : BNE .YC		; don't draw if there are no levels here
		RTS

	.YC	STA $0E				; number of rows to draw
		STZ $0F
		LDY #$00			; Y = current row
		REP #$10			; index 16 bit

		LDA #$AC : STA $0C		; base coords
		LDA #$8F : STA $0D

	--	LDA #$00 : XBA
		LDA !BigRAM+1,y			;\
		TAX				; |
		PHY				; |
	.MLoop	STX $08				; > Save X in $08
		LDA !LevelTable1,x		; | generate coin matrix in $02-$05 and tile data in $0D-$0E
		LDX #$0004			; |
	-	STZ $02,x			; |
		LSR A				; |
		BCC $02 : INC $02,x		; |
		DEX : BPL -			;/
		LDX #$0004			;\
		LDY !OAMindex			; |
		REP #$20			; |
	-	LDA $0C : STA !OAM+0,y		; |
		CLC : ADC #$0008		; |
		STA $0C				; | loop for each coin
		LDA $02,x			; |
		AND #$0001			; |
		ORA #$3FF0			; |
		STA !OAM+2,y			; |
		INY #4				; |
		DEX : BPL -			; |
		STY !OAMindex			;/

		LDA $08				;\
		AND #$00FF			; |
		STA $06				; |
		ASL #2				; |
		CLC : ADC $06			; |
		STA $06				; |
		ASL #2				; |
		CLC : ADC $06			; |
		CLC : ADC.w #Data+3		; |
		STA $06				; |
		LDA ($06)			; | Mega level clause
		BMI .NoMega			; |
		AND #$7E00 : BEQ .NoMega	; |
		SEP #$20			; |
		XBA				; |
		LSR A				; |
		SEC : SBC #$60			; |
		EOR #$FF			; |
		INC A				; |
		TAX				; |
		BRA .MLoop			; |
		.NoMega				;/

		LDA $0C				;\
		CLC : ADC #$0800		; |
		AND #$FF00			; |
		ORA #$00AC			; |
		STA $0C				; | loop for each row
		SEP #$20			; |
		PLY				; |
		INY				; |
		CPY $0E : BEQ $03 : JMP --	;/

		SEP #$10			; index 8 bit


		LDY !SelectedLevel		;\
		LDA !BigRAM+1,y			; |
		ASL A				; | Level position indicator
		TAX				; |
		REP #$20			; |
		LDA.w Cursor,x			; |
		STA !OAM+$1D8			; |
		LDA #$3FEC : STA !OAM+$1DA	; |
		SEP #$20			;/
		LDA $13				;\
		AND #$20 : BEQ +		; | Animation thing
		INC !OAM+$1DA			; |
		INC !OAM+$1DA			;/
		+

		RTS



	Window:
		LDA.b #.SNES : STA $0183
		LDA.b #.SNES>>8 : STA $0184
		LDA.b #.SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	-	LDA $018A : BEQ -
		STZ $018A
		PLB				;\ Restore bank and return
		RTL				;/




		.SNES
		PHK : PLB
		SEP #$30


		PHP
		REP #$20
		LDA #$4222 : STA $0C
		LDY #$00
		LDA !BigRAM+0
		AND #$00FF
		STA !NameIndex

	-	REP #$30
		LDA !BigRAM+1,y
		AND #$00FF
		PHY
		JSR ReadName
		PLY
	.NoRead	SEP #$10
		INY
		CPY #$08 : BNE -
		PLP


		LDA #$3F : TRB $40		;\ No color math
		STZ $44				;/
		LDA #$22 : STA $41		;\ Hide BG1/BG2 inside window, show BG3 ONLY inside window
		LDA #$03 : STA $42		;/
		STZ $43				; > Enable sprites within window
		STZ $4324			;\ Bank 0x00 for both channels
		STZ $4334			;/
		REP #$20
		LDA #$2601 : STA $4320		; > regs 2126 and 2127
		LDA #$0200 : STA !HDMA2source	; > table at $0200

		LDA #$1103 : STA $4330		; > regs 2111 and 2112 (both 16-bit)
		LDA #$0400 : STA !HDMA3source		; > table at $0400

		LDA #$00FF			;\
		STA $0201			; |
		STA $0204			; | Default window table (no window)
		STA $0207			; |
		STA $020A			;/


		LDA !MenuPosition		;\
		PHA				; |
		AND #$0001			; | BG3 x position
		BEQ $03 : LDA #$00B8		; |
		SEC : SBC #$0040		; |
		STA $0401			;/
		PLA				;\
		AND #$0006			; |
		XBA				; | BG3 y position
		LSR #2				; |
		SEC : SBC #$0008		; |
		STA $0403			;/

		SEP #$20
		LDA #$0C : TSB $6D9F		; Enable HDMA

		LDA #$01 : STA $0400		;\ Set up BG3 positioning table
		STZ $0405			;/


		LDA #$07 : STA $0200		;\
		LDA #$40			; |
		STA $0203			; | Base windowing table
		STA $0206			; |
		LDA #$01 : STA $0209		; |
		STZ $020C			;/

		LDA !CharMenu : BEQ ..Norm	;\
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
		RTL				;/

	..Norm	LDA !MenuMode			;\
		CMP #$01 : BNE ..R		; |
		LDA #$40			; |
		STA $0204			; | Map windowing table
		STA $0207			; |
		LDA #$F7			; |
		STA $0205			; |
		STA $0208			;/
	..R	RTL




	; All regs 16-bit, A = translevel number


;	read3($03BB57):	Lunar Magic's level name table

; probably just dump the tilemaps in !GFX_buffer and upload them with VR2
; also ReadName should be moved to SA-1 side

	ReadName:
		CPY.w !NameIndex
		PHB
		PEA $7F7F
		PLB : PLB
		BCC .Name


	.Blank	LDA $837B				;\
		TAY					; |
		CLC : ADC #$0026			; |
		STA $02					; |
		CLC : ADC #$0004			; |
		STA $837B				; |
		JSR .Header				; | if this index is empty, remove previous name from list
	;	LDA #$2500 : STA $837F,y		; |
		LDA #$38F9				; | this is necessary to remove leftover names from previous page
	-	STA $8381,y				; |
		INY #2					; |
		CPY $02 : BCC -				; |
		SEP #$20				; |
		LDA #$FF : STA $8381,y			; |
		PLB					; |
		RTS					;/


	.Name	STA $00
		ASL A
		PHA
		CLC : ADC $00
		STA $00
		PLA
		ASL #3
		CLC : ADC $00
		TAX
		LDA.l !MenuMode : BEQ .Blank

		LDA $837B
		TAY
		CLC : ADC #$0026
		STA $02
		CLC : ADC #$0004			; + another 4 because of the header
		STA $837B


		JSR .Header				;\ name header
	;	LDA #$2500 : STA $837F,y		;/


		SEP #$20
	-	LDA.l read3($03BB57),x			; LM name
		CPY $02 : BCS .End
		ORA #$80 : STA $8381,y			; use upper half of page
		LDA #$38 : STA $8382,y			; YXPCCCTT byte (use first page)
		INY #2
		INX
		BRA -

	.End	LDA #$FF : STA $8381,y
		PLB
		RTS


		.Header
	;	LDA $0C : STA $837D,y			; header

		PHX
		PHB : PHK : PLB
		PHY
		JSL !GetVRAM
		PEA $4040 : PLB : PLB
		PLY
		TYA
		CLC : ADC #$8381
		STA.w !VRAMtable+$02,x
		LDA #$7F7F : STA !VRAMtable+$04,x
		LDA $0C
		XBA
		AND #$0FFF
		ORA #$3000
		STA.w !VRAMtable+$05,x
		LDA #$0026 : STA.w !VRAMtable+$00,x
		PLB
		PLX

		LDA $0C					;\
		CLC : ADC #$2000			; | update
		BCC $01 : INC A				; |
		STA $0C					;/

		RTS




	Portrait:

		LDX !CharMenuCursor
	.0	LDA.w .Table,x : BPL .Valid
		RTS


		.Valid
		TXA					;\
		ASL A					; |
		PHA					; |
		ASL A					; | portrait address
		TAX					; |
		LDA.l !PortraitPointers+2,x : STA $00	; |
		LDA.l !PortraitPointers+3,x : STA $01	; |
		LDA.l !PortraitPointers+4,x : STA $02	; |
		LDA #$10 : STA $03			;/

		LDA #$00 : XBA
		TXA					;\
		REP #$20				; |
		ASL #3					; |
		CLC : ADC.w #!PlayerPalettes		; |
		STA $0D					; | Player palette in !BigRAM
		SEP #$20				; |
		LDA.b #!PlayerPalettes>>16 : STA $0F	; |
		LDY #$1F				; |
	-	LDA [$0D],y : STA !BigRAM+$3E,y		; |
		DEY : BPL -				;/

		PLX					;\
		LDA.b #!PortraitPointers>>16 : STA $0F	; |
		LDA #$00				; |
		STA.l !VRAMbase+!CGRAMtable+4		; |
		REP #$20				; |
		LDA.l (!PortraitPointers&$FF0000)+read2(!PortraitPointers)+0,x	; |
		STA $0D					; |
		LDY #$3C				; |
	-	LDA [$0D],y : STA !BigRAM,y		; | upload player and portrait palettes
		DEY #2 : BPL -				; |
		LDA.w #!BigRAM				; |
		STA.l !VRAMbase+!CGRAMtable+2		; |
		LDA #$005E				; |
		LDY !UploadPlayerPal			; \ upload player pal clause
		BEQ $03 : LDA #$003E			; /
		STA.l !VRAMbase+!CGRAMtable+0		; |
		SEP #$20				; |
		LDA #$C1				; |
		STA.l !VRAMbase+!CGRAMtable+5		;/

		JSL PLANE_SPLIT_SA1			; > unpack 5bpp portrait

		PHB
		LDA.b #!VRAMbank
		PHA : PLB

		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x			; upload size = .5 KB
		LDA.w #!BufferLo : STA !CCDMAtable+$02,x		; source address = !BufferLo
		LDA #$7600 : STA !CCDMAtable+$05,x			; dest VRAM = 0x7600
		SEP #$20
		LDA.b #!BufferLo>>16 : STA !CCDMAtable+$04,x		; source bank
		LDA #$09 : STA !CCDMAtable+$07,x			; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x			; upload size = .5 KB
		LDA.w #!BufferLo+$100 : STA !CCDMAtable+$02,x		; source address = !BufferLo+$100
		LDA #$7700 : STA !CCDMAtable+$05,x			; dest VRAM = 0x7700
		SEP #$20
		LDA.b #!BufferLo>>16 : STA !CCDMAtable+$04,x		; source bank
		LDA #$09 : STA !CCDMAtable+$07,x			; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x			; upload size = .5 KB
		LDA.w #!BufferHi : STA !CCDMAtable+$02,x		; source address = !BufferHi
		LDA #$7680 : STA !CCDMAtable+$05,x			; dest VRAM = 0x7680
		SEP #$20
		LDA.b #!BufferHi>>16 : STA !CCDMAtable+$04,x		; source bank
		LDA #$09 : STA !CCDMAtable+$07,x			; settings = 4bpp, 32px
		REP #$20
		JSL !GetBigCCDMA
		LDA #$0100 : STA !CCDMAtable+$00,x			; upload size = .5 KB
		LDA.w #!BufferHi+$100 : STA !CCDMAtable+$02,x		; source address = !BufferHi+$100
		LDA #$7780 : STA !CCDMAtable+$05,x			; dest VRAM = 0x7780
		SEP #$20
		LDA.b #!BufferHi>>16 : STA !CCDMAtable+$04,x		; source bank
		LDA #$09 : STA !CCDMAtable+$07,x			; settings = 4bpp, 32px

		PLB
		RTS

	.Long	PHB : PHK : PLB
		PHA
		PHY
		LDA #$01 : STA !UploadPlayerPal		; don't upload player pal
		JSR .0

		LDA.b #!VRAMbank			;\
		PHA : PLB				; |
		PLA : STA !CGRAMtable+5			; > adjust palette
		PLA					; |
		STA !VRAMtable+$06,x			; |
		STA !VRAMtable+$14,x			; |
		STA !VRAMtable+$22,x			; | adjust upload destination
		STA !VRAMtable+$30,x			; |
		INC A					; |
		STA !VRAMtable+$0D,x			; |
		STA !VRAMtable+$1B,x			; |
		STA !VRAMtable+$29,x			; |
		STA !VRAMtable+$37,x			;/
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


macro CharDyn(base, tiles, source, dest)
	dw <tiles>*$20
	dl <source>*$20+<base>
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
		%CharDyn($7E2000, 2, $0E0, $10C)
		%CharDyn($7E2000, 2, $0F0, $11C)
		%CharDyn($7E2000, 2, $004, $10E)
		%CharDyn($7E2000, 2, $014, $11E)
		..End


		.LuigiTM
		db $07
		db $80,$20,$0C,$3D
		db $80,$30,$0E,$3D


		.LuigiDyn
		dw ..End-..Start
		..Start
		%CharDyn($3A8008, 2, $000, $10C)
		%CharDyn($3A8008, 2, $010, $11C)
		%CharDyn($3A8008, 2, $020, $10E)
		%CharDyn($3A8008, 2, $030, $11E)
		..End


		.KadaalTM
		db $07
		db $80,$20,$0C,$3D
		db $80,$30,$0E,$3D

		.KadaalDyn
		dw ..End-..Start
		..Start
		%CharDyn($328008, 2, $000, $10C)
		%CharDyn($328008, 2, $010, $11C)
		%CharDyn($328008, 2, $020, $10E)
		%CharDyn($328008, 2, $030, $11E)
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
		%CharDyn($358000, 2, $000, $10C)
		%CharDyn($358000, 2, $010, $11C)
		%CharDyn($358000, 3, $020, $12C)
		%CharDyn($358000, 3, $030, $13C)
		%CharDyn($348008, 3, $008, $14C)
		%CharDyn($348008, 3, $018, $15C)
		..End



; set Y to the file index, which is (ExGFX number - 0x100) * 3
	Decompress:
		PHP
		REP #$30
		LDA $0FF937 : STA $00		;\
		LDA $0FF938 : STA $01		; |
		LDA [$00],y : STA $8A		; | load LM's super ExGFX pointer
		INY				; |
		LDA [$00],y : STA $8B		;/
		LDA #$0040 : STA $02		;\ decompression destination: $417000
		LDA #$7000 : STA $00		;/
		SEP #$30
		JSL $108299			; decompress
		PLP
		RTS


	Bit:
		db $01,$02,$04,$08
		db $10,$20,$40,$80




	RealmTilemap:
		db $08,$07,$00,$30	; Realm 1
		db $18,$07,$02,$30
		db $28,$07,$04,$30
		db $08,$17,$20,$30
		db $18,$17,$22,$30
		db $28,$17,$24,$30
		db $08,$27,$40,$30
		db $18,$27,$42,$30
		db $28,$27,$44,$30

		db $08,$47,$06,$32	; Realm 2
		db $18,$47,$08,$32
		db $28,$47,$0A,$32
		db $08,$57,$26,$32
		db $18,$57,$28,$32
		db $28,$57,$2A,$32
		db $08,$67,$46,$32
		db $18,$67,$48,$32
		db $28,$67,$4A,$32

		db $48,$07,$0C,$34	; Realm 3
		db $58,$07,$0E,$34
		db $68,$07,$60,$34
		db $48,$17,$2C,$34
		db $58,$17,$2E,$34
		db $68,$17,$62,$34
		db $48,$27,$4C,$34
		db $58,$27,$4E,$34
		db $68,$27,$64,$34

		db $48,$47,$80,$34	; Realm 4
		db $58,$47,$82,$34
		db $68,$47,$84,$34
		db $48,$57,$A0,$34
		db $58,$57,$A2,$34
		db $68,$57,$A4,$34
		db $48,$67,$C0,$34
		db $58,$67,$C2,$34
		db $68,$67,$C4,$34

		db $88,$07,$00,$30	; Realm 5 placeholder
		db $98,$07,$02,$30
		db $A8,$07,$04,$30
		db $88,$17,$20,$30
		db $98,$17,$22,$30
		db $A8,$17,$24,$30
		db $88,$27,$40,$30
		db $98,$27,$42,$30
		db $A8,$27,$44,$30

		db $88,$47,$06,$32	; Realm 6 placeholder
		db $98,$47,$08,$32
		db $A8,$47,$0A,$32
		db $88,$57,$26,$32
		db $98,$57,$28,$32
		db $A8,$57,$2A,$32
		db $88,$67,$46,$32
		db $98,$67,$48,$32
		db $A8,$67,$4A,$32

		db $C8,$07,$0C,$34	; Realm 7 placeholder
		db $D8,$07,$0E,$34
		db $E8,$07,$60,$34
		db $C8,$17,$2C,$34
		db $D8,$17,$2E,$34
		db $E8,$17,$62,$34
		db $C8,$27,$4C,$34
		db $D8,$27,$4E,$34
		db $E8,$27,$64,$34

		db $C8,$47,$80,$34	; Realm 8 placeholder
		db $D8,$47,$82,$34
		db $E8,$47,$84,$34
		db $C8,$57,$A0,$34
		db $D8,$57,$A2,$34
		db $E8,$57,$A4,$34
		db $C8,$67,$C0,$34
		db $D8,$67,$C2,$34
		db $E8,$67,$C4,$34


	SelectTilemap:
		db $2D,$04,$6E,$30
		db $2D,$14,$6D,$30
		db $2D,$24,$6D,$30
		db $05,$2C,$6C,$30
		db $15,$2C,$5C,$30
		db $25,$2C,$5C,$30
		db $2D,$2C,$6A,$30

	SelectIndex:
		dw $0000,$0024,$0048,$006C
		dw $0090,$00B4,$00D8,$00FC
		dw $0120

	SelectOffset:
		dw $0000,$4000,$0040,$4040
		dw $0080,$4080,$00C0,$40C0

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



	LevelIndex:
		db LevelList_1-LevelList
		db LevelList_2-LevelList
		db LevelList_3-LevelList
		db LevelList_4-LevelList
		db LevelList_5-LevelList
		db LevelList_6-LevelList
		db LevelList_7-LevelList
		db LevelList_8-LevelList

	LevelCount:
		db LevelList_2-LevelList_1
		db LevelList_3-LevelList_2
		db LevelList_4-LevelList_3
		db LevelList_5-LevelList_4
		db LevelList_6-LevelList_5
		db LevelList_7-LevelList_6
		db LevelList_8-LevelList_7
		db Cursor-LevelList_8

	LevelList:
		.1
		db $02		; Rex Village
		db $01		; Mushroom Gorge
		db $03		; Dinolord's Domain
		db $04		; Hilltop Rex Road
		db $05		; Castle Rex
		db $06		; Evernight Temple
		db $0C		; Unnamed Beach Level

		.2
		db $07		; Crossroad Plains
		db $08		; Melody's Mountain
		db $0B		; Living Garden
		db $0A		; Path of Thunder
		db $0E		; Tower of Storms
		db $0D		; Sunken City
		db $14		; Yoshi's Boneyard

		.3
		db $00		; UNKNOWN

		.4
		db $10		; Thieves' Valley
		db $11		; Avalanche Incline
		db $13		; Sovereign Peak
		db $0F		; Dragonfell Keep
		db $0C		; Monkey Village
		db $12		; Hellfire Cave
		db $30		; <<<<<<<<<<<<< unnamed debug level
		db $15		; Ice Palace

		.5
		db $00		; UNKNOWN
		.6
		db $00		; UNKNOWN
		.7
		db $00		; UNKNOWN
		.8
		db $00		; UNKNOWN


	Cursor:

; Format:
; YYYYXXXX
; Y = Y coordinate (4x4 tiles)
; X = X coordinate (4x4 tiles)

macro MapCursor(X, Y)
	db <X><<2+$3C
	db <Y><<2+$07
endmacro

	.000	dw $0000
	.001	%MapCursor($0, $0F)
	.002	%MapCursor($0, $15)
	.003	%MapCursor($A, $13)
	.004	%MapCursor($16, $13)
	.005	%MapCursor($1E, $11)
	.006	%MapCursor($A, $9)
	.007	%MapCursor($E, $13)
	.008	%MapCursor($8, $11)
	.009	%MapCursor($22, $13)
	.00A	%MapCursor($18, $B)
	.00B	%MapCursor($6, $B)
	.00C	%MapCursor($1C, $B)
	.00D	%MapCursor($14, $15)
	.00E	%MapCursor($24, $B)
	.00F	%MapCursor($18, $B)
	.010	%MapCursor($0, $15)
	.011	%MapCursor($A, $11)
	.012	%MapCursor($1C, $1B)
	.013	%MapCursor(18, $B)




	namespace off