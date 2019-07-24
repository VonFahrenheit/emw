header
sa1rom

; --Defines--

incsrc "Defines.asm"

!Freespace = $138000

org !Freespace
db $53,$54,$41,$52
dw $FFF7
dw $0008

;
; To do:
;	- Remove the OAM priority system
;	- Restore MSG
;	- Restore kill OAM routine
;



CODE_138008:

	PHB				;\
	PHK				; |
	PLB				; | Wrapper for GET_MAP16 routine, located at !Freespace+$08
	JSR GET_MAP16			; |
	PLB				; |
	RTL				;/

CODE_138010:

	PHB				;\
	PHK				; |
	PLB				; | Wrapper for OAM kill routine
	JSR KILL_OAM_Short		; |
	PLB				; |
	RTL				;/

CODE_138018:

	PHB				;\
	PHK				; |
	PLB				; | Load coordinates in X/Y, then JSL !Freespace+$18
	JSR GET_MAP16_ABSOLUTE		; |
	PLB				; |
	RTL				;/

CODE_138020:

	PHB				;\
	PHK				; |
	PLB				; | Wrapper for Yoshi Coin handler, called by level code
	JSR YoshiCoins			; |
	PLB				; |
	RTL				;/

CODE_138028:

	PHB				;\
	PHK				; |
	PLB				; | Wrapper for the routine that gets the VRAM table index into X
	JSR GET_VRAM			; |
	PLB				; |
	RTL				;/

CODE_138030:

	PHB				;\
	PHK				; |
	PLB				; | Wrapper for the routine that gets the VRAM table index into Y
	JSR GET_CGRAM			; |
	PLB				; |
	RTL				;/

CODE_138038:

	PHB				;\
	JSR WRITE_TILEMAP_HI		; | Wrapper for the hi prio tilemap loader
	PLB				; |
	RTL				;/

CODE_13803E:

	PHB				;\
	JSR WRITE_TILEMAP_LO		; | Wrapper for the lo prio tilemap loader
	PLB				; |
	RTL				;/

CODE_138044:

	PHB				;\
	JSR WRITE_TILEMAP_SPRITE	; | Wrapper for setup routine for sprite OAM tilemap loader
	PLB				; |
	RTL				;/

CODE_13804A:



;=========;
;Get_MAP16;
;=========;
; --Instructions--
;
; Load A and Y with 16-bit X and Y offsets for block to check, then do:
; JSL !Freespace+$08
;
; After the routine is called, [$05] is the map16 number of the block. To check the 16-bit number do:
; LDA [$05]
; XBA
; INC $07
; LDA [$05]
; XBA
;
; A is now the 16-bit map16 number of the block. To access it, use 16-bit mode.
;
; Absolute mode:
; Load X and Y with their respective 16-bit coordinates.
; JSL with 16-bit XY and 8-bit A.
; Returns 8-bit XY, 16-bit A; A = acts like setting of block.



GET_MAP16:

	PHY				; Preserve Y offset (16-bit)
	PHA				; Preserve X offset (16-bit)
	SEP #$30			; All registers 8-bit
	LDA $3250,x
	XBA
	LDA $3220,x
	REP #$20			; A 16-bit
	STA $00
	PLA				; Restore X offset (16-bit)
	CLC
	ADC $00				; Add with sprite Xpos (16-bit)
	STA $02				; Store to scratch RAM
	SEP #$20			; A 8-bit

	LDA $3240,x
	XBA
	LDA $3210,x
	REP #$20			; A 16-bit
	STA $00
	PLA				; Restore Y offset (16-bit)
	CLC
	ADC $00				; Add with sprite Ypos (16-bit)
	STA $00				; Store to scratch RAM
	SEP #$20			; A 8-bit

	LDA $00				; Load sprite Y pos (lo)
	AND #$F0			; Check only the highest nybble
	STA $06				; Store to scratch RAM
	LDA $02				; Load sprite X pos (lo)
	LSR A				;\
	LSR A				; |
	LSR A				; | Divide by 16 (X pos is now in map16-tiles rather than pixels)
	LSR A				;/
	ORA $06				; High nybble is now high nybble of lo Ypos and low nybble is Xpos in tiles?
	PHA				; Preserve this most peculiar value
	LDA $5B				; Load screen mode
	AND #$01			; Check vertical layer 1
	BEQ .Horizontal			; Branch if clear

	.Vertical
	PLA				; Restore the weirdo value
	LDX $01				; Load sprite Y pos (hi) in X
	CLC				; Clear carry
	ADC.L $00BA80,x			; Add a massive map16 table (indexed by X) to weirdo-value
	STA $05				; Store to scratch RAM
	LDA.L $00BABC,x			; Load another massive map16 table (indexed by the same X)
	ADC $03				; Add with sprite X pos (hi)
	STA $06				; Store to scratch RAM
	BRA .Shared			; BRA to a shared routine

	.Horizontal
	PLA				; Restore weirdo-value
	LDX $03				; Load sprite X pos (hi)
	CLC				; Clear carry
	ADC.L $00BA60,x			; Add with massive map16 table
	STA $05				; Store to scratch RAM
	LDA.L $00BA9C,x			; Load massive map16 table
	ADC $01				; Add with sprite Y pos (hi)
	STA $06				; Store to scratch RAM

	.Shared
	LDA.B #$40			; BW-RAM bank 1
	STA $07				; Store to scratch RAM
	LDX $75E9			; Load sprite index in X

	.Return
	RTS				; Return


	.ABSOLUTE
	STY $00
	STX $02
	LDA $00
	AND #$F0 : STA $06
	LDA $02
	LSR #4
	ORA $06
	PHA
	SEP #$10
	LDA !RAM_ScreenMode
	LSR A : BCC ..Horz

	..Vert
	LDA $01
	CMP $5D : BCS ..OutOfBounds
	LDA $03
	CMP #$02 : BCS ..OutOfBounds
	PLA
	LDX $01
	CLC : ADC.l $00BA80,x
	STA $05
	LDA.l $00BABC,x
	ADC $03
	STA $06
	BRA ..Shared

	..OutOfBounds
	PLA
	REP #$20
	LDA #$0025
	RTS

	..Horz
	REP #$20
	LDA $00
	CMP #$01B0
	SEP #$20
	BCS ..OutOfBounds
	LDA $03
	CMP $5D : BCS ..OutOfBounds
	PLA
	LDX $03
	CLC : ADC.l $00BA60,x
	STA $05
	LDA.l $00BA9C,x
	ADC $01
	STA $06

	..Shared
	LDA #$40 : STA $07
	LDA !Map16ActsLike+0 : STA $00
	LDA !Map16ActsLike+1 : STA $01
	LDA !Map16ActsLike+2 : STA $02
	LDA [$05]
	XBA
	INC $07
	LDA [$05]
	XBA
	REP #$30
	AND #$3FFF
	ASL A : TAY
	LDA [$00],y
	SEP #$10

	..Return
	RTS


;==============;
;GENERATE_BLOCK;
;==============;
; --Input--
; X = sprite index
; Y = Shatter brick flag (00 does nothing, 01-FF runs the shatter brick routine)
; $00 = Object to spawn from block.
; $02 = 16-bit X offset
; $04 = 16-bit Y offset
; $7C = Bounce sprite to spawn.
; $9C = Block to generate.

GENERATE_BLOCK:

	LDA $98					;\
	PHA					; |
	LDA $99					; |
	PHA					; | Preserve Mario's block values
	LDA $9A					; |
	PHA					; |
	LDA $9B					; |
	PHA					;/
	LDA $00					;\ Preserve object to spawn from block
	PHA					;/
	PHY					; Preserve shatter brick flag

	LDA $3210,x				;\
	STA $00					; |
	LDA $3240,x				; |
	STA $01					; |
	LDA $3250,x				; |
	XBA					; |
	LDA $3220,x				; |
	REP #$20				; | Set pos to sprite pos + offset
	CLC					; |
	ADC $02					; |
	AND.W #$FFF0				; |> Ignore lowest nybble
	STA $9A					; |
	LDA $00					; |
	CLC					; |
	ADC $04					; |
	AND.W #$FFF0				; |> Ignore lowest nybble
	STA $98					;/

GENERATE_BLOCK_SHORT:

	SEP #$20

	LDA $9C
	BEQ GENERATE_BLOCK_SHATTER

		JSL $00BEB0

	GENERATE_BLOCK_SHATTER:

		PLA				; Restore shatter brick flag
		BEQ GENERATE_BLOCK_BOUNCE
		PHB				;\
		LDA #$02			; |
		PHA				; | Bank wrapper
		PLB				; |
		LDA #$00			; |> Normal shatter (01 will spawn rainbow brick pieces)
		JSL $028663			; |> Shatter Block
		PLB				;/

	GENERATE_BLOCK_BOUNCE:

		LDA $7C
		BEQ GENERATE_BLOCK_OBJECT
		JSR BOUNCE_SPRITE		; Spawn bounce sprite of type $7C at ($98;$9A)

	GENERATE_BLOCK_OBJECT:

		PLA
		BEQ RETURN_GENERATE_BLOCK
		STA $05

		REP #$20
		LDA $98
		CLC
		ADC #$0003
		STA $98
		SEP #$20
		LDA $9A
		AND #$F0
		STA $9A

		PHB				;\
		LDA #$02			; |
		PHA				; | Bank wrapper
		PLB				; |
		JSL $02887D			; |> Spawn object
		PLB				;/

RETURN_GENERATE_BLOCK:

	PLA					;\
	STA $9B					; |
	PLA					; |
	STA $9A					; | Restore Mario's block values
	PLA					; |
	STA $99					; |
	PLA					; |
	STA $98					;/
	RTS

;===================;
;SPAWN BOUNCE SPRITE;
;===================;
; --Input--
; Load $00 with bounce sprite number
; Load $01 with tile bounce sprite should turn into (uses $009C values)
; Load $02 with 16 bit X offset
; Load $04 with 16 bit Y offset
; Load $06 with bounce sprite timer (how many frames it will exist)
; Bounce sprite of type $7C will be spawned at ($98;$9A) and will turn into $9C

BOUNCE_SPRITE:

	LDY #$03			; Highest bounce sprite index

LOOP_BOUNCE_SPRITE:

	LDA $7699,y			;\
	BEQ SPAWN_BOUNCE_SPRITE		; |
	DEY				; | Get bounce sprite number
	BPL LOOP_BOUNCE_SPRITE		; |
	RTS				;/

SPAWN_BOUNCE_SPRITE:

	STA $769D,y			; > INIT routine
	STA $76C9,y			; > Layer 1, going up
	STA $76B5,y			; > X speed
	LDA #$C0			;\ Y speed
	STA $76B1,y			;/

	LDA #$08			;\ How many frames bounce sprite will exist
	STA $76C5,y			;/
	LDA $9C				;\ Map16 tile bounce sprite should turn into
	STA $76C1,y			;/

	LDA $7C				;\ Bounce sprite number
	STA $7699,y			;/
	CMP #$07			;\
	BNE PROCESS_BOUNCE_SPRITE	; |
	LDA #$FF			; | Set turn block timer if spawning a turn block
	STA $786C,y			;/

PROCESS_BOUNCE_SPRITE:

	LDA $9A
	STA $76A5,y
	STA $76D1,y
	LDA $9B
	STA $76AD,y
	STA $76D5,y

	LDA $98
	STA $76A1,y
	STA $76D9,y
	LDA $99
	STA $76A9,y
	STA $76DD,y

	LDA $7699,y			;\
	CMP #$07			; |
	BNE RETURN_BOUNCE_SPRITE	; | Set Y speed to zero if spawning a turn block
	LDA #$00			; |
	STA $76B1,y			;/

RETURN_BOUNCE_SPRITE:

	RTS				; Return


;===========;
;YOSHI COINS;
;===========;
incsrc "YoshiCoins.asm"

;========;
;GET VRAM;
;========;
GET_VRAM:
; -- Info --
;
; Caling this routine will set X to the proper VRAM table index.
; If this routine returns with a set carry, it means that the table is full.

		PHY : PHP
		SEP #$30
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDX #$00

.Loop		LDA !VRAMtable,x
		BEQ .SlotFound
		TXA
		CLC : ADC #$0007
		TAX
		BCC .Loop
		PLP : PLY
		SEC
		RTS

.SlotFound	PLP : PLY
		CLC
		RTS


;=========;
;GET CGRAM;
;=========;
GET_CGRAM:
		PHP
		SEP #$30
		LDA #!VRAMbank
		PHA : PLB
		REP #$20
		LDY #$00

.Loop		LDA !CGRAMtable,y
		BEQ .SlotFound
		TAY
		CLC : ADC #$0006
		TYA
		BCC .Loop
		PLP
		SEC
		RTS

.SlotFound	PLP
		CLC
		RTS


; MAKE THIS ONE UPLOAD A COMPLETELY GENERIC TILEMAP USING INFORMATION IN $00-$0F!
; THEN ADD AN OPTIONAL ROUTINE THAT SETS UP SPRITE INFO THERE!!
; THAT WAY I CAN USE THIS CODE FOR ANY TILEMAP, NOT JUST SPRITES!!

;===============;
;HI PRIO TILEMAP;
;===============;
WRITE_TILEMAP_HI:
		REP #$30
		LDA.l !OAM_HiPrioIndex : TAX	; > Always use this index for hi prio uploads
		SEP #$20

.Loop		LDA ($04),y
		EOR $0C
		STA.l !OAM_HiPrio+$003,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodX		STA $06				; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodY		SEP #$20
		STA.l !OAM_HiPrio+$001,x
		LDA $06
		STA.l !OAM_HiPrio+$000,x
		INY
		LDA ($04),y
		CLC : ADC $0A
		STA.l !OAM_HiPrio+$002,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA.l !OAM_HiPrioHi+$00,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		LDA.l !OAM_HiPrioIndex		;\
		CLC : ADC $08			; | Update index
		STA.l !OAM_HiPrioIndex		;/
		RTS


;===============;
;LO PRIO TILEMAP;
;===============;
WRITE_TILEMAP_LO:

		REP #$30
		LDA.l !OAM_LoPrioIndex : TAX	; > Always use this index for lo prio uploads
		SEP #$20

.Loop		LDA ($04),y
		EOR $0C
		STA.l !OAM_LoPrio+$003,x
		REP #$20
		STZ $0E
		AND #$0040
		BEQ +
		LDA #$FFFF
		STA $0E
	+	INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		CMP #$0100
		BCC .GoodX
		CMP #$FFF0
		BCS .GoodX
		INX #4
		INY #3
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodX		STA $06				; Save tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8
		BCC .GoodY
		CMP #$FFF0
		BCS .GoodY
		INX #4
		INY #2
		SEP #$20
		CPY $08
		BNE .Loop
		BRA .End

.GoodY		SEP #$20
		STA.l !OAM_LoPrio+$001,x
		LDA $06
		STA.l !OAM_LoPrio+$000,x
		INY
		LDA ($04),y
		CLC : ADC $0A
		STA.l !OAM_LoPrio+$002,x
		INY
		PHX
		TXA
		LSR #2
		TAX
		LDA $07
		AND #$01
		ORA #$02
		STA.l !OAM_LoPrioHi+$00,x
		PLX
		CPY $08
		BEQ .End
		INX #4
		JMP .Loop
.End		LDA.l !OAM_LoPrioIndex		;\
		CLC : ADC $08			; | Update index
		STA.l !OAM_LoPrioIndex		;/
		RTS

;======================================;
;LOADER FOR HI PRIORITY SPRITE TILEMAPS;
;======================================;
;
; Set A to positive to load a lo prio tilemap, negative for hi prio tilemap.
;
WRITE_TILEMAP_SPRITE:

		PHP
		SEP #$30
		PHA
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
		BRA .Main

		LDA $3220,x
		LDY $BE,x
		BEQ .Left
		LDY $3320,x
		BNE .Left
.Right		CLC : ADC #$04
.Left		STA $00
		LDA $3250,x
		ADC #$00
		STA $01
		LDA $3210,x : STA $02
		LDA $3240,x : STA $03
.Main		LDA !ClaimedGFX : STA $0A
		REP #$20
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA $02
		SEC : SBC $1C
		STA $02
		LDA ($04)
		STA $08
		LDA $04
		INC #2
		STA $04
		STZ $0C
		LDA $3320,x
		LSR A
		BCS +
		LDA #$0040
		STA $0C
	+	LDY #$00

		PLA
		BPL .Lo
.Hi		PEA .Lo+2 : JMP WRITE_TILEMAP_HI	; 1 cycle less than JSR : BRA
.Lo		JSR WRITE_TILEMAP_LO

		PLP
		LDX !SpriteIndex
		RTS



;================;
;CLEAR CHARACTERS;
;================;
CLEAR_CHARACTERS:

		LDA #$00			;\ Clear player 1 and 2 characters
		STA !Characters			;/
		STA !HDMAptr+0
		STA !HDMAptr+1
		STA !HDMAptr+2

		JSR CLEAR_VR2

		LDY #$0C			;\ Overwritten code
		LDX #$03			;/
		RTL


;=========;
;LOAD SRAM;
;=========;
LOAD_SRAM:

		JSR CLEAR_MSG

		STZ $6DC1			; Make sure there is no Yoshi
		STZ $6DBA			;\ Clear Yoshi colors
		STZ $6DBB			;/
		LDA $404002			; > Load number of lives
		STA $6DBE			; > Write to lives counter
		STZ $73C9			; > Clear the game over flag to supress a game over limbo
		LDA $404003			;\
		PHA				; | Load player 1 powerup
		AND #$0F			; |
		STA $19				;/
		PLA				;\
		LSR #4				; | Load player 1 extra powerup
		STA $6DC2			;/
	+	REP #$20			; A 16 bit
		JML $009E4E			; Return to load OW routine


;=================;
;END LEVEL ROUTINE;
;=================;
END_LEVEL:

		LDA !P2Status
		CMP #$02 : BCC .KeepRunning
		LDY #$0B			; Fade to overworld if both players are dead
		BRA .Return

.KeepRunning	LDY #$14			; Gamemode = level
		INC $7496

.Return		LDA !P2XPosLo			;\
		STA $94				; | Player 1 Xpos = player 2 Xpos
		LDA !P2XPosHi			; |
		STA $95				;/
		RTL



;==============;
;CLEAR PLAYER 2;
;==============;
CLEAR_PLAYER2:
		JSR CLEAR_MSG

		STZ !BossData+0			;\
		STZ !BossData+1			; |
		STZ !BossData+2			; |
		STZ !BossData+3			; | Clear boss data
		STZ !BossData+4			; |
		STZ !BossData+5			; |
		STZ !BossData+6			;/

		STZ !P2Status
		STZ !P2Pipe			; > Remove pipe
		STZ !P1Dead
		LDA #$03
		STA $6D9C
		REP #$30
		STZ $03
		RTL

;=========;
;CLEAR MSG;
;=========;
CLEAR_MSG:
		LDA.b #.SA1 : STA $3180		;\
		LDA.b #.SA1>>8 : STA $3181	; | Have SA-1 clear message box RAM
		LDA.b #.SA1>>16 : STA $3182	; |
		JMP $1E80			;/

		.SA1
		PHP
		PHB
		LDA #$40
		PHA : PLB
		STZ.w !MsgRAM+$FF
		REP #$30
		LDA.w #$00FE
		LDX.w #!MsgRAM+$FF
		LDY.w #!MsgRAM+$FE
		MVP $40,$40
		PLB
		PLP
		RTL


;=========;
;CLEAR VR2;
;=========;
CLEAR_VR2:

		LDA.b #.SA1 : STA $3180		;\
		LDA.b #.SA1>>8 : STA $3181	; | Have SA-1 clear VR2 RAM
		LDA.b #.SA1>>16 : STA $3182	; |
		JMP $1E80			;/


		.SA1
		PHP
		PHB
		LDA #$40
		PHA : PLB
		STZ !VRAMtable+$3FF
		REP #$30
		LDA.w #$03FE
		LDX.w #!VRAMtable+$3FF
		LDY.w #!VRAMtable+$3FE
		MVP $40,$40
		PLB
		PLP
		RTL

;===========;
;EXTRA CLEAR;
;===========;
EXTRA_CLEAR:
		JSR CLEAR_VR2
		JMP KILL_OAM


;==========;
;FIX MIDWAY;
;==========;
FIX_MIDWAY:

		LDA #$01			;\ Set midway flag
		STA $73CE			;/
		LDX $73BF			;\
		LDA $7EA2,x			; | Set flag in OW table
		ORA #$40			; |
		STA $7EA2,x			;/
		JML $00CA30			; > Return to RTS

;===============;
;DEATH GAME MODE;
;===============;
DEATH_GAMEMODE:

		LDA $6DBE
		CMP #$FF
		BEQ .GameOver
		LDA #$0F
		STA !GameMode
		JML $009C8E

		PHB : PHK : PLB			; > Bank wrapper
		PHX				; > Push X
		LDA $5B				;\
		AND #$01			; | Y = Vertical level flag times 2
		ASL A				; |
		TAY				;/
		REP #$20			;\
		LDA $73BF			; |
		AND.w #$00FF			; |
		CMP.w #$0025			; | Get level number
		BCC +				; |
		CLC				; |
		ADC.w #$00DC			; |
	+	SEP #$20			;/
		LDX $95,y			; Get Mario screen number
		STA $79B8,x			; Set lo byte
		LDY $73CE			; > Y = Midway point flag
		XBA				;\
		ORA.w .MidwayBits,y		; | Set hi byte with exit enabled
		STA $79D8,x			;/
		LDA #$06			;\
		STA $71				; | Set Mario's animation to warp
		STZ $88				; |
		STZ $89				;/
		PLX				; > Restore X
		PLB				; > Restore bank
		LDY #$14			; > Set game mode to level

	; SOME KIND OF JML HERE

.Init		STZ !P2Status			; > Reload player 2
		LDX #$14			;\ Death message = GAME OVER
		STX $743B			;/
		LDY #$15			;\ Game mode = fade to GAME OVER
		STY $6100			;/
		LDA #$C0			;\ GAME OVER animation = 0xC0
		STA $743C			;/
		LDA #$FF			;\ GAME OVER timer = 0xFF
		STA $743D			;/
		JML $00D107

.GameOver	LDA #$01 : STA !SPC3
		STZ $6D9F
		RTL

		STZ $4200			; > Disable interrupts
		SEI				; > Set interrupt
		LDA #$FF			;\ Request SPC upload
		STA $2141			;/
		LDA #$00			;\ Set DB to 0x00
		PHA : PLB			;/
		STZ $420C			; > Disable HDMA
		JML $008016			; > Reset SNES


.MidwayBits	db $04,$0C			; Attribute bits for exits

;===========;
;DELAY DEATH;
;===========;
DELAY_DEATH:

		LDA !P2Status			;\
		CMP #$02			; | If player 2 is still alive, hide player 1
		BCC .NoDeath			;/
		LDA #$01			;\ Set music
		STA !SPC3			;/
		STZ $19				;\ Overwritten code
		LDA #$3E			;/
		JML $00D0BA			; > Execute rest of routine

.NoDeath	LDA #$01			;\ Enable vertical scrolling
		STA !ScrollLayer1		;/
		LDA #$7F			;\ Hide player 1
		STA !MarioMaskBits		;/
		LDA !P1Dead
		BEQ .Process
		JSL $00F6DB
		JMP .Snap
.Process
		LDX #$00			;\
		REP #$20			; | Set up YSpeed index
		LDA !P2YPosLo			; |
		SEC : SBC $96			; |
		STA $02				; |
		BPL +				; |
		INX #4				;/
	+	LDA !P2XPosLo			;\
		SEC : SBC $94			; |
		STA $00				; | Set up XSpeed index
		BPL +				; |
		INX #2				;/
	+	LDA $94				;\
		CLC : ADC.l .XDisp,x		; |
		STA $94				; | Update coords
		LDA $96				; |
		CLC : ADC.l .YDisp,x		; |
		STA $96				;/
		LDA $00
		BPL +
		EOR #$FFFF
		INC A
	+	STA $00
		LDA $02
		BPL +
		EOR #$FFFF
		INC A
	+	CLC : ADC $00
		CMP #$0010
		SEP #$20			; > A 8 bit
		BPL .NoSnap
		LDA #$01 : STA !P1Dead
.Snap		REP #$20			;\
		LDA !P2XPosLo : STA $94		; | P1 snaps to P2
		LDA !P2YPosLo			; |
		SEC : SBC #$0010		; |
		STA $96				; |
		SEP #$20			;/
.NoSnap		LDA #$02			;\ Set invinc timer
		STA $7497			;/
;		LDY #$0B			;\
;	-	STA $754C,y			; | Disable sprite interaction for player 1
;		DEY				; |
;		BPL -				;/
		JML $00D107			; Return to RTS

.XDisp		dw $0004,$FFFC,$0004,$FFFC
.YDisp		dw $0004,$0004,$FFFC,$FFFC

.Init		LDA !P2Status
		CMP #$02
		BCS +
		LDA #$08
		STA !SPC1
	+	LDA #$90			;\ Overwritten code
		STA $7D				;/
		JML $00F60A			; Execute the rest of the routine

;======================;
;SCROLL OPTIONS ROUTINE;
;======================;
SCROLL_OPTIONS:
		LDA $7413			;\
		ASL A				; | X = pointer index
		TAX				;/
		LDA $1A				; > A = BG1 HScroll
		JMP (.HPtr,x)			; > Execute pointer

		.HPtr
		dw .NoHorz			; 0 - 0%
		dw .ConstantHorz		; 1 - 100%
		dw .VariableHorz		; 2 - 50%
		dw .SlowHorz			; 3 - 6.25%
		dw .Variable2Horz		; 4 - 25%
		dw .Variable3Horz		; 5 - 12.5%
		dw .CloseHorz			; 6 - 87.5%
		dw .Close2Horz			; 7 - 75%
		dw .CloseHalfHorz		; 8 - 37.5%
		dw .Close2HalfHorz		; 9 - 43.75%
		dw .40PercentHorz		; A - 40%

.40PercentHorz	ASL #2
		STA $4204
		LDX #$0A
		STX $4206
		JSR .GetDiv
		LDA $4216
		CMP #$0005
		LDA $4214
		ADC #$0000
		BRA .ConstantHorz
.CloseHalfHorz	LSR A
.Close2HalfHorz	LSR #2
		SEC : SBC $1A
		EOR #$FFFF
		INC A
		LSR A
		BRA .ConstantHorz
.CloseHorz	LSR A
.Close2Horz	LSR #2
		SEC : SBC $1A
		EOR #$FFFF
		INC A
		BRA .ConstantHorz
.SlowHorz	LSR A
.Variable3Horz	LSR A
.Variable2Horz	LSR A
.VariableHorz	LSR A
.ConstantHorz	STA $1E
.NoHorz		LDA $7414
		ASL A
		TAX
		LDA $1C
		JMP (.VPtr,x)

		.VPtr
		dw .NoVert			; 0 - 0%
		dw .ConstantVert		; 1 - 100%
		dw .VariableVert		; 2 - 50%
		dw .SlowVert			; 3 - 6.25%
		dw .Variable2Vert		; 4 - 25%
		dw .Variable3Vert		; 5 - 12.5%
		dw .CloseVert			; 6 - 87.5%
		dw .Close2Vert			; 7 - 75%
		dw .CloseHalfVert		; 8 - 37.5%
		dw .Close2HalfVert		; 9 - 43.75%
		dw .40PercentVert		; A - 40%

.40PercentVert	ASL #2
		STA $4204
		LDX #$0A
		STX $4206
		JSR .GetDiv
		LDA $4216
		CMP #$0005
		LDA $4214
		ADC #$0000
		BRA .ConstantVert
.CloseHalfVert	LSR A
.Close2HalfVert	LSR #2
		SEC : SBC $1C
		EOR #$FFFF
		INC A
		LSR A
		BRA .ConstantVert
.CloseVert	LSR A
.Close2Vert	LSR #2
		SEC : SBC $1C
		EOR #$FFFF
		INC A
		BRA .ConstantVert
.SlowVert	LSR A
.Variable3Vert	LSR A
.Variable2Vert	LSR A
.VariableVert	LSR A
.ConstantVert	CLC : ADC $7417			;\ Add temporary BG2 VScroll and write
		STA $20				;/
		LDA.l !HDMAptr			;\
		BEQ .Return			; |
		STA $00				; |
		LDA.l !HDMAptr+1		; | Execute HDMA code
		STA $01				; |
		PEA $0000 : PLB			; |
		PEA $F7C2-1			; |
		JML [$3000]			;/
.NoVert		LDA $7417
		STA $20
		LDA.l !HDMAptr			;\
		BEQ .Return			; |
		STA $00				; |
		LDA.l !HDMAptr+1		; | Execute HDMA code
		STA $01				; |
		PEA $0000 : PLB			; |
		PEA $F7C2-1			; |
		JML [$3000]			;/
.Return		JML $00F7C2

.GetDiv		NOP #2
		RTS

;===============;
;HAMMER SPINJUMP;
;===============;

	HAMMER:
		.SPINJUMP
		JSL $03B72B
		BCS .Contact
		JML $02A468			; > Return with no contact
.Contact	LDA $770B,x
		CMP #$04
		BNE .NoHammer
		LDA !MarioSpinJump
		BNE .SpinHammer
		LDA $776F,x
		BNE .Return
		BRA .NoHammer

.SpinHammer	LDA $7715,x
		SEC : SBC $96
		LDA $7729,x
		SBC $97
		BCC .NoHammer
		JSL !BouncePlayer
		JSL !ContactGFX
		LDA #$02 : STA !SPC1
		LDA #$40 : STA $773D,x
		STZ $7747,x
.Return		JML $02A468			; > Return
.NoHammer	JML $02A40E			; > Non-hammer code


	; GenerateHammer starts at $02DAC3.

		.SPAWN
		LDA #$04 : STA $770B,y
		LDA #$00 : STA $776F,y
		JML $02DAC8

	pushpc
	org $02A2DF
	.HammerTiles
		db $4C,$4E,$4E,$4C
		db $4C,$4E,$4E,$4C
	pullpc


;====================;
;LOAD HIDEOUT ROUTINE;
;====================;
LOAD_HIDEOUT:

		LDA $73D2			;\
		ORA $7B86			; | Don't allow cancelling OW processes
		ORA $7B87			; |
		BNE .Return			;/
		LDA $73C1			; Tile player is standing on
		CMP #$56			;\ Return if less than 0x56
		BCC .Return			;/
		CMP #$87			;\ Return if equal to or greater than 0x86
		BCS .Return			;/
		INC $73F2			; Set load hideout flag

	; The following code is the level load init routine from all.log, starting at $04919F.

		LDY #$10
		LDA $7F13
		AND #$08
		BEQ +
		LDY #$12
	+	TYA
		STA $7F13
		LDA #$02
		STA $6DB1
		LDA #$80
		STA !SPC3
		INC !GameMode			; Increment game mode to initiate level load
.Return		JML HIDEOUT_CHECK_Skip

.Load		LDA $73F2
		BEQ .NormalLevel
		LDA #$00			;\ Load level 0x000
		STA $73BF			;/
		RTL

.NormalLevel	LDA $743B			;\ If level was loaded from OW, handle as usual
		BEQ +				;/
		STZ $743B			; > Clear game over
		LDY $73BF			; > Y = translevel number
		LDA $73CE			;\ If the midway point has not been reached, load the main entrance
		BEQ .NoMidway			;/
		LDA $7EA2,y			;\
		ORA #$40			; | If the midway point has been reached, carry on from there
		STA $7EA2,y			;/
.NoMidway	TYA				; > A = translevel number
		RTL				; > Return

	+	LDA $40D000,x			; Overwritten code
		RTL



;==================;
;BUILD OAM PRIORITY;
;==================;


; A 16-bit
; Index 8-bit
; DP set to start of OAM mirror to copy
; Set X to 0xF0
; Make ($00) point to assembly area (just overwrite part of the first tile after copying it)
; Make ($02) point to high table of assembly area

macro CheckOAMTile(tile)
	CPX.b $01+(<tile>*4)
	BEQ ?Nope

	LDA.b $00+(<tile>*4)
	STA ($00),y
	INY #2
	LDA.b $02+(<tile>*4)
	STA ($00),y

	PHY
	TYA
	LSR #2
	TAY
	LDA.l !OAMhi+<tile>
	STA ($02),y
	PLY
	INY #2
	CPY $07 : BNE ?Nope
	JMP .Overflow

	?Nope:
endmacro


macro CheckOAMBlock(block)
	%CheckOAMTile((<block>*4)+0)
	%CheckOAMTile((<block>*4)+1)
	%CheckOAMTile((<block>*4)+2)
	%CheckOAMTile((<block>*4)+3)
endmacro



	BUILD_OAM_PRIORITY:

		PHB
		LDA.b #!OAM_HiPrio>>16
		PHA : PLB
		PHD
		PHP
		REP #$30
		LDA #$0200
		SEC : SBC.w !OAM_HiPrioIndex
		BEQ .NoClear
		DEC #2
		LDX #$F0F0 : STX.w !OAM_HiPrio+$1FE	; > Fixed byte
		LDX.w #!OAM_HiPrio+$1FE
		LDY.w #!OAM_HiPrio+$1FD
		PHB
		MVP !OAM_HiPrio>>16,!OAM_HiPrio>>16
		PLB
		.NoClear

		STZ.w !OAM_PrioCache+2			; > Clear 256B-flag
		LDA.w #!OAM : TCD			; > Point direct page to start of main OAM mirror
		LDY.w !OAM_HiPrioIndex			;\
		CPY #$01F4				; | Don't assemble if hi prio is close to full
		BCC $03 : JMP .Assemble			;/
		LDA.l !OAMhi+$00 : STA.w !OAM_PrioCache	; > Load hi table data into cache
		JSR .Prep				; > Finish setup


		%CheckOAMTile($02)			;\
		%CheckOAMTile($03)			; |
		%CheckOAMTile($04)			; |
		%CheckOAMTile($05)			; |
		%CheckOAMTile($06)			; |
		%CheckOAMTile($07)			; |
		%CheckOAMTile($08)			; |
		%CheckOAMTile($09)			; |
		%CheckOAMTile($0A)			; |
		%CheckOAMTile($0B)			; |
		%CheckOAMTile($0C)			; |
		%CheckOAMTile($0D)			; |
		%CheckOAMTile($0E)			; |
		%CheckOAMTile($0F)			; |
		%CheckOAMTile($10)			; |
		%CheckOAMTile($11)			; |
		%CheckOAMTile($12)			; |
		%CheckOAMTile($13)			; |
		%CheckOAMTile($14)			; |
		%CheckOAMTile($15)			; |
		%CheckOAMTile($16)			; |
		%CheckOAMTile($17)			; |
		%CheckOAMTile($18)			; |
		%CheckOAMTile($19)			; |
		%CheckOAMTile($1A)			; |
		%CheckOAMTile($1B)			; |
		%CheckOAMTile($1C)			; |
		%CheckOAMTile($1D)			; |
		%CheckOAMTile($1E)			; | Copy tiles 2-63
		%CheckOAMTile($1F)			; |
		%CheckOAMTile($20)			; |
		%CheckOAMTile($21)			; |
		%CheckOAMTile($22)			; |
		%CheckOAMTile($23)			; |
		%CheckOAMTile($24)			; |
		%CheckOAMTile($25)			; |
		%CheckOAMTile($26)			; |
		%CheckOAMTile($27)			; |
		%CheckOAMTile($28)			; |
		%CheckOAMTile($29)			; |
		%CheckOAMTile($2A)			; |
		%CheckOAMTile($2B)			; |
		%CheckOAMTile($2C)			; |
		%CheckOAMTile($2D)			; |
		%CheckOAMTile($2E)			; |
		%CheckOAMTile($2F)			; |
		%CheckOAMTile($30)			; |
		%CheckOAMTile($31)			; |
		%CheckOAMTile($32)			; |
		%CheckOAMTile($33)			; |
		%CheckOAMTile($34)			; |
		%CheckOAMTile($35)			; |
		%CheckOAMTile($36)			; |
		%CheckOAMTile($37)			; |
		%CheckOAMTile($38)			; |
		%CheckOAMTile($39)			; |
		%CheckOAMTile($3A)			; |
		%CheckOAMTile($3B)			; |
		%CheckOAMTile($3C)			; |
		%CheckOAMTile($3D)			; |
		%CheckOAMTile($3E)			; |
		%CheckOAMTile($3F)			;/

		TDC					;\
		CMP.w #!OAM				; | Upload both halves
		BEQ $03 : JMP .End			;/
		TYA					;\
		CLC : ADC.w !OAM_PrioCache		; | Update index
		CMP #$0200 : BCC $03 : JMP .Assemble	; |
		STA.w !OAM_HiPrioIndex			;/
		LDA.w #!OAM+$100 : TCD			; > Update direct page
		REP #$10				; > Index 16-bit
		LDA.l !OAMhi+$40 : STA.w !OAM_PrioCache	; > Load hi table data into cache
		JSR .Prep				; > Finish setup


		%CheckOAMTile($42)			;\
		%CheckOAMTile($43)			; |
		%CheckOAMTile($44)			; |
		%CheckOAMTile($45)			; |
		%CheckOAMTile($46)			; |
		%CheckOAMTile($47)			; |
		%CheckOAMTile($48)			; |
		%CheckOAMTile($49)			; |
		%CheckOAMTile($4A)			; |
		%CheckOAMTile($4B)			; |
		%CheckOAMTile($4C)			; |
		%CheckOAMTile($4D)			; |
		%CheckOAMTile($4E)			; |
		%CheckOAMTile($4F)			; |
		%CheckOAMTile($50)			; |
		%CheckOAMTile($51)			; |
		%CheckOAMTile($52)			; |
		%CheckOAMTile($53)			; |
		%CheckOAMTile($54)			; |
		%CheckOAMTile($55)			; |
		%CheckOAMTile($56)			; |
		%CheckOAMTile($57)			; |
		%CheckOAMTile($58)			; |
		%CheckOAMTile($59)			; |
		%CheckOAMTile($5A)			; |
		%CheckOAMTile($5B)			; |
		%CheckOAMTile($5C)			; |
		%CheckOAMTile($5D)			; |
		%CheckOAMTile($5E)			; | Copy tiles 66-127
		%CheckOAMTile($5F)			; |
		%CheckOAMTile($60)			; |
		%CheckOAMTile($61)			; |
		%CheckOAMTile($62)			; |
		%CheckOAMTile($63)			; |
		%CheckOAMTile($64)			; |
		%CheckOAMTile($65)			; |
		%CheckOAMTile($66)			; |
		%CheckOAMTile($67)			; |
		%CheckOAMTile($68)			; |
		%CheckOAMTile($69)			; |
		%CheckOAMTile($6A)			; |
		%CheckOAMTile($6B)			; |
		%CheckOAMTile($6C)			; |
		%CheckOAMTile($6D)			; |
		%CheckOAMTile($6E)			; |
		%CheckOAMTile($6F)			; |
		%CheckOAMTile($70)			; |
		%CheckOAMTile($71)			; |
		%CheckOAMTile($72)			; |
		%CheckOAMTile($73)			; |
		%CheckOAMTile($74)			; |
		%CheckOAMTile($75)			; |
		%CheckOAMTile($76)			; |
		%CheckOAMTile($77)			; |
		%CheckOAMTile($78)			; |
		%CheckOAMTile($79)			; |
		%CheckOAMTile($7A)			; |
		%CheckOAMTile($7B)			; |
		%CheckOAMTile($7C)			; |
		%CheckOAMTile($7D)			; |
		%CheckOAMTile($7E)			; |
		%CheckOAMTile($7F)			;/

		.End


		LDA !OAM_LoPrioIndex : BEQ .Assemble	; > Skip this if no lo prio tiles exist
		REP #$10				; > Index 16-bit
		TYA					;\
		CLC : ADC $00				; |
		TAY					;  > Y = Destination address
		SEC : SBC.w #!OAM_HiPrio		; | A = free bytes left = bytes to transfer
		SEC : SBC #$0200			; |
		BCS .Assemble				; | > End routine if too many tiles have been written
		EOR #$FFFF : INC A			;/
		CMP.w !OAM_LoPrioIndex			;\ Transfer the lowest amount of tiles possible
		BCC $03 : LDA.w !OAM_LoPrioIndex	;/
		LDX.w #!OAM_LoPrio			; > X = Source address
		PHA					;\ Preserve byte count and dest address
		PHY					;/
		PHB					;\
		MVN !OAM_HiPrio>>16,!OAM_HiPrio>>16	; | Copy lo prio tiles to the end of the assembly area
		PLB					;/
		PLA					;\
		SEC : SBC.w #!OAM_HiPrio		; | Y = Index to hi table
		LSR #2					; |
		TAY					;/
		PLA					;\
		LSR #2					; | $00 = Number of hi table bytes to copy
		STA $00					;/
		LDX #$0000				; > X = 0x0000
		SEP #$20				; > A 8-bit
	-	LDA.w !OAM_LoPrioHi,x			;\
		STA.w !OAM_HiPrioHi,y			; |
		INY					; | Copy lo prio hi table to assembly area hi table
		INX					; |
		CPX $00					; |
		BNE -					;/


		.Assemble
		LDA #$8475 : TCD			; > Set direct page to a ROM table in bank 0x00
		PLP					; > Restore processor
		LDY #$1E				; > Start loop at 0x1E to reach all tiles (32 bytes)
	-	LDX.b $00,y				;\
		LDA.w !OAM_HiPrioHi+3,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+2,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+1,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+0,x			; | Assemble hi OAM table
		STA.w !OAM_HiPrio+$200,y		; |
		LDA.w !OAM_HiPrioHi+7,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+6,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+5,x			; |
		ASL #2					; |
		ORA.w !OAM_HiPrioHi+4,x			; |
		STA.w !OAM_HiPrio+$201,y		; |
		DEY #2					; |
		BPL -					;/
		PLD					;\ Restore direct page and data bank
		PLB					;/
		RTL					; > Return


		.Prep
		LDA $01					;\
		AND #$00FF : CMP #$00F0			; |
		BEQ .Empty0				; |
		LDA $00 : STA.w !OAM_HiPrio+0,y		; |
		LDA $02 : STA.w !OAM_HiPrio+2,y		; |
		PHY					; |
		TYA					; |
		LSR #2					; |
		TAY					; |
		LDA.l !OAM_PrioCache+0			; |
		STA.w !OAM_HiPrioHi+0,y			; |
		PLY					; |
		INY #4					; | Manually check/copy first 2 tiles
		.Empty0					; |
		LDA $05					; |
		AND #$00FF : CMP #$00F0			; |
		BEQ .Empty1				; |
		LDA $04 : STA.w !OAM_HiPrio+0,y		; |
		LDA $06 : STA.w !OAM_HiPrio+2,y		; |
		PHY					; |
		TYA					; |
		LSR #2					; |
		TAY					; |
		LDA.l !OAM_PrioCache+1			; |
		STA.w !OAM_HiPrioHi+0,y			; |
		PLY					; |
		INY #4					; |
		.Empty1					;/

		STY.w !OAM_HiPrioIndex			; > Update index
		SEP #$10				; > Index 8-bit
		LDY #$00				; > Reset index
		LDA #$0200
		SEC : SBC.w !OAM_HiPrioIndex
		CMP #$0100
		BCC .64

		.128
		STZ $06					; > Remove tile limit (and clear $06 for pointer)
		BRA .SetUp

		.64
		XBA					;\ Write tile limit to $07 (and clear $06 for pointer)
		STA $06					;/

		.SetUp
		LDX #$F0				; > X = 0xF0
		LDY #$00				; > Y = 0x00
		LDA.w #!OAM_HiPrio			;\
		CLC : ADC.w !OAM_HiPrioIndex		; | Pointer to lo table of assembly area
		STA $00					;/
		LDA.w !OAM_HiPrioIndex			;\
		LSR #2					; | Pointer to hi table of assembly area
		CLC : ADC.w #!OAM_HiPrioHi		; |
		STA $02					;/
		RTS


		.Overflow				;\ If this triggers because total index reaches 0x200,
		INC.w !OAM_PrioCache+3			; |this makes no difference. If it triggers from reaching
		JMP .Assemble				;/ 0x100, it means I can detect overflow!
	; Note that I'm adding 0x100, not 1.


;========;
;KILL OAM;
;========;

	KILL_OAM:

		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		RTL

		.Short
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JMP $1E80

		.SA1
		PHB : PHK : PLB
		LDA #$00
		STA.l !OAM_HiPrioIndex+0
		STA.l !OAM_HiPrioIndex+1
		STA.l !OAM_LoPrioIndex+0
		STA.l !OAM_LoPrioIndex+1
		LDA #$F0
		STA !OAM+$001 : STA !OAM+$005 : STA !OAM+$009 : STA !OAM+$00D
		STA !OAM+$011 : STA !OAM+$015 : STA !OAM+$019 : STA !OAM+$01D
		STA !OAM+$021 : STA !OAM+$025 : STA !OAM+$029 : STA !OAM+$02D
		STA !OAM+$031 : STA !OAM+$035 : STA !OAM+$039 : STA !OAM+$03D
		STA !OAM+$041 : STA !OAM+$045 : STA !OAM+$049 : STA !OAM+$04D
		STA !OAM+$051 : STA !OAM+$055 : STA !OAM+$059 : STA !OAM+$05D
		STA !OAM+$061 : STA !OAM+$065 : STA !OAM+$069 : STA !OAM+$06D
		STA !OAM+$071 : STA !OAM+$075 : STA !OAM+$079 : STA !OAM+$07D
		STA !OAM+$081 : STA !OAM+$085 : STA !OAM+$089 : STA !OAM+$08D
		STA !OAM+$091 : STA !OAM+$095 : STA !OAM+$099 : STA !OAM+$09D
		STA !OAM+$0A1 : STA !OAM+$0A5 : STA !OAM+$0A9 : STA !OAM+$0AD
		STA !OAM+$0B1 : STA !OAM+$0B5 : STA !OAM+$0B9 : STA !OAM+$0BD
		STA !OAM+$0C1 : STA !OAM+$0C5 : STA !OAM+$0C9 : STA !OAM+$0CD
		STA !OAM+$0D1 : STA !OAM+$0D5 : STA !OAM+$0D9 : STA !OAM+$0DD
		STA !OAM+$0E1 : STA !OAM+$0E5 : STA !OAM+$0E9 : STA !OAM+$0ED
		STA !OAM+$0F1 : STA !OAM+$0F5 : STA !OAM+$0F9 : STA !OAM+$0FD
		STA !OAM+$101 : STA !OAM+$105 : STA !OAM+$109 : STA !OAM+$10D
		STA !OAM+$111 : STA !OAM+$115 : STA !OAM+$119 : STA !OAM+$11D
		STA !OAM+$121 : STA !OAM+$125 : STA !OAM+$129 : STA !OAM+$12D
		STA !OAM+$131 : STA !OAM+$135 : STA !OAM+$139 : STA !OAM+$13D
		STA !OAM+$141 : STA !OAM+$145 : STA !OAM+$149 : STA !OAM+$14D
		STA !OAM+$151 : STA !OAM+$155 : STA !OAM+$159 : STA !OAM+$15D
		STA !OAM+$161 : STA !OAM+$165 : STA !OAM+$169 : STA !OAM+$16D
		STA !OAM+$171 : STA !OAM+$175 : STA !OAM+$179 : STA !OAM+$17D
		STA !OAM+$181 : STA !OAM+$185 : STA !OAM+$189 : STA !OAM+$18D
		STA !OAM+$191 : STA !OAM+$195 : STA !OAM+$199 : STA !OAM+$19D
		STA !OAM+$1A1 : STA !OAM+$1A5 : STA !OAM+$1A9 : STA !OAM+$1AD
		STA !OAM+$1B1 : STA !OAM+$1B5 : STA !OAM+$1B9 : STA !OAM+$1BD
		STA !OAM+$1C1 : STA !OAM+$1C5 : STA !OAM+$1C9 : STA !OAM+$1CD
		STA !OAM+$1D1 : STA !OAM+$1D5 : STA !OAM+$1D9 : STA !OAM+$1DD
		STA !OAM+$1E1 : STA !OAM+$1E5 : STA !OAM+$1E9 : STA !OAM+$1ED
		STA !OAM+$1F1 : STA !OAM+$1F5 : STA !OAM+$1F9 : STA !OAM+$1FD
		PLB
		RTL


;===================;
;CHECKPOINTS ROUTINE;
;===================;
;incsrc "Checkpoints.asm"


;=========;
;BRK RESET;
;=========;
BRK:
		STZ $4200
		SEI
		SEP #$30
		LDA #$FF
		STA $2141
		LDA #00
		PHA : PLB
		STZ $420C
		JML $008016


;=======;
;HIJACKS;
;=======;

org $00939A				; Game mode 00 routine
	JSL CLEAR_CHARACTERS

org $009767
	;JML DEATH_GAMEMODE		; Source: LDA $0DBE : BPL $1C ($009788)
	;NOP

	LDA $6DBE : BPL $1C

org $009E24
	JML LOAD_SRAM			; Hijack the routine that writes garbage to player status
	NOP				; Clean up garbage


org $009F66
	LDA #$0F			; < Enable mosaic on all layers

org $00A1C3
	JSL EXTRA_CLEAR			; Source: JSL $7F8000

org $00CA2B
	JML FIX_MIDWAY			;\ Source: LDA #$01 : STA $13CE
	NOP				;/

org $00D0DD
	JSL DEATH_GAMEMODE_GameOver	;\ Source : LDA #$01 : STA $1DFB (actually LDA #$0B, but AMK requires 0x01)
	NOP				;/

	;LDA #$01 : STA $7DFB

org $00D0B6
	JML DELAY_DEATH			; Source : STZ $19 : LDA #$3E

org $00D0E6				; Mario's death routine
	;JML DEATH_GAMEMODE_Init		;\ Source: LDY #$0B : LDA $0F31
	;NOP				;/

	LDY #$0B : LDA $6F31

org $00F606
	JML DELAY_DEATH_Init		; Source: LDA #$90 : STA $7F

org $00F60C
	NOP : NOP : NOP			; Source : STA $1DFB

org $00F79D
	JML SCROLL_OPTIONS		; Source: LDY $1413 : BEQ $08 (00F7AA)

org $01C39D
	db $20				; Priority set by powerups

org $01C4A2
	db $20				; Priority set by powerups

org $01EC3D
	NOP : NOP : NOP			; Prevent Yoshi from saying anything when he hatches. (Source: STA $1426)

org $02A405
	JML HAMMER_SPINJUMP

org $02DAC3
	JML HAMMER_SPAWN		; Source: LDA #$04 : STA $170B,y
	NOP


org $048086

	JSL CLEAR_PLAYER2		; Hijack some Overworld routine

org $04824B
	HIDEOUT_CHECK:
		BEQ .Skip		; Enable an unused beta routine

		; There's 20 bytes of unused code here, so I'm not overwriting anything important.

		LDA $6DA4
		ORA $6DA8
		BNE .Skip
		JML LOAD_HIDEOUT
		NOP : NOP		;\
		NOP : NOP		; | 8 bytes free at $048259, used as vectors
		NOP : NOP		; |
		NOP : NOP		;/
		.Skip

org $05D89B
	JSL LOAD_HIDEOUT_Load		; Hijack level load init

org $05D9D7
;	JML CHECKPOINTS			; Checkpoint check routine
;	NOP

	LDA !LevelTable,x
	AND #$40


;==================;
;BUILD OAM PRIORITY;
;==================;

org $008449

	STZ $4300
	REP #$20
	STZ $2102
	LDA #$0004 : STA $4301
	LDA.w #!OAM_HiPrio>>8 : STA $4303
	LDA #$0220 : STA $4305
	LDY #$01 : STY $420B
	SEP #$20
	LDA #$80 : STA $2103
	LDA $3F : STA $2102
	RTS

warnpc $008475


org $008494
				; < This is hijacked by SA-1 but WE'RE OVERWRITING IT!! >:D

	LDA.b #BUILD_OAM_PRIORITY	;\
	STA $3180			; |
	LDA.b #BUILD_OAM_PRIORITY>>8	; |
	STA $3181			; | Send SA-1 to subroutine
	LDA.b #BUILD_OAM_PRIORITY>>16	; |
	STA $3182			; |
	JMP $1E80			;/
	NOP #34				; > Wipe the rest of the routine

warnpc $0084C8


;==============;
;KILL OAM REMAP;
;==============;

org $008027
	BRA +
org $00804A
	+
org $008642
	JSL KILL_OAM
org $0094FD
	JSL KILL_OAM
org $0095AB
	JSL KILL_OAM
org $009632
	JSL KILL_OAM
org $009759
	JSL KILL_OAM
org $009870
	JSL KILL_OAM
org $009888
	JSL KILL_OAM
org $009A6F
	JSL KILL_OAM
org $009C9F
	JSL KILL_OAM
org $00A1C3
	JSL KILL_OAM
org $00A295
	JSL KILL_OAM


;================;
;BRK RESET MAPPER;
;================;

org $00FFE6
	dw $8A58
org $00FFF6
	dw $8A58


org $008A58
	JML BRK



