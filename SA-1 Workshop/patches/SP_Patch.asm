header
sa1rom

; --Defines--

incsrc "Defines.asm"

!Freespace = $138000

org !Freespace
db $53,$54,$41,$52
dw $FFF7
dw $0008


pushpc
org $04842E		; 048431 is taken by SP_Level
dl GENERATE_BLOCK

org $048434
dl SCROLL_OPTIONS_Main	; JSL read3($048334) will instantly scroll layer 2 and execute the HDMA code

pullpc



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

	PHB
	PHK
	PLB
	JSR PLANE_SPLIT
	PLB
	RTL

CODE_138040:

	PHB
	PHK
	PLB
	JSR HurtPlayers
	PLB
	RTL

CODE_138048:

	JSR UPDATE_GFX
	RTL

CODE_13804C:

	JSR UPDATE_PAL
	RTL

CODE_138050:

	PHB
	PHK
	PLB
	JSR CONTACT16
	PLB
	RTL


DATA_138058:

	dw .PalPtr		; < This is probably necessary to access the palettes smoothly

	dl $378000 : db $00	; 1, Mario
	dl $378400 : db $01	; 2, Luigi
	dl $378800 : db $02	; 3, Kadaal
	dl $378C00 : db $03	; 4, Leeway
	dl $379000 : db $04	; 5, Alter
	dl $379400 : db $05	; 6, Survivor
	dl $379800 : db $06	; 7, Tinkerer
	dl $379C00 : db $07	; 8, Rally
	dl $37A000 : db $08	; 9, Rex
	dl $37A400 : db $09	; A, Captain Warrior
	dl $37A800 : db $0A	; B, KingKing

	.PalPtr
	dw .MarioPal
	dw .LuigiPal
	dw .KadaalPal
	dw .LeewayPal
	dw .AlterPal
	dw .SurvivorPal
	dw .TinkererPal
	dw .RallyPal
	dw .RexPal
	dw .CaptainWarriorPal
	dw .KingKingPal

.MarioPal	dw $7FFF,$0000,$1084,$5EF7,$6F7B,$182D,$2875,$2C97
		dw $30BA,$34DD,$391F,$499F,$48C4,$4D66,$5228,$0000
		dw $0048,$04AB,$1117,$21BA,$365D,$4EFF,$5F5F,$0C14
		dw $0818,$041C,$001F,$0D1F,$1D9F

.LuigiPal	dw $7FFF,$0000,$0C63,$5294,$6B5A,$1100,$19C0,$2680
		dw $2F20,$3BC0,$3C07,$7CAE,$7DB4,$48C4,$4D66,$0000
		dw $5228,$0048,$008E,$0938,$1DBB,$367E,$4EFF,$679F
		dw $0580,$0241,$0302,$03C4,$13EB,$27F4

.KadaalPal	dw $7FFF,$0000,$0C65,$316A,$5272,$6316,$739B,$01C0
		dw $1A60,$32E0,$011F,$025F,$1ADF,$037F,$03FF,$0000
		dw $206A,$54AE,$7CD4,$477F,$0094,$001B,$00BC,$001F
		dw $011F,$019F

.LeewayPal	dw $7FFF,$0842,$10A6,$294A,$56B5,$6739,$77BD,$18E9
		dw $1D4D,$25B2,$2E36,$090B,$0133,$09B7,$163C,$0000
		dw $229F,$016F,$05F4,$0A98,$0F1C,$139F,$0EA0,$1708
		dw $0FAB,$0BEF,$03FA,$0FFF

.AlterPal

.SurvivorPal	dw $7FFF,$0000,$0C85,$5EB4,$6B38,$77BC,$0C36,$1439
		dw $1C3B,$205E,$285F,$391F,$4DBF,$011A,$017E,$0000
		dw $023F,$1954,$2E5B,$4B3F,$5F9F,$50C0,$5140,$5A20
		dw $3EC0,$2780,$2BE7

.TinkererPal	dw $7FFF,$0000,$0080,$05A4,$0645,$06A7,$0EE9,$134C
		dw $2393,$3BF8,$3057,$487F,$553F,$65FF,$00B8,$0000
		dw $013E,$023F,$0CEA,$1971,$2658,$32FF,$5B9F,$01F4
		dw $02B8,$033C,$03DF,$2BFF

.RallyPal	dw $7FFF,$0000,$0C65,$56B6,$6F7B,$033F,$03DF,$47FF
		dw $0077,$015D,$01FF,$02BF,$10EA,$1993,$2637,$0000
		dw $32BC,$46FD,$535F,$67BF,$66C5,$6BE8,$7BF9

.RexPal		dw $7FFF,$0000,$1842,$18C6,$5252,$62F7,$739C,$5044
		dw $60C8,$692B,$75AE,$7E52,$000A,$0C16,$00B8,$0000
		dw $141B,$013A,$01BD,$025F,$5C0E,$5815,$541B,$501F
		dw $595F,$5A3F

.CaptainWarriorPal
		dw $7FFF,$0000,$0C85,$18E8,$214B,$2DAE,$3A32,$4A95
		dw $52F8,$5F3B,$6B9F,$08AA,$0118,$017C,$01DF,$0000
		dw $127F,$01B6,$0638,$0E99,$12FB,$1B5D,$1FBF,$4467
		dw $54E6,$65A4,$7AA1,$7F68,$7FEA

.KingKingPal	dw $7FFF,$0000,$7F18,$7F9C,$602C,$74CE,$714F,$7992
		dw $7E32,$7EB5,$0100,$0241,$0780,$27E7,$0CBA,$0000
		dw $10DE,$015F,$01FF,$1299,$0B1D,$03BF,$47DF,$281E
		dw $741F




incsrc "5bpp.asm"


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
	LDA [$05] : XBA
	INC $07
	LDA [$05] : XBA
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
	RTL

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

;============;
;LEVEL SELECT;
;============;
incsrc "LevelSelect.asm"


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



;=====================;
;HURT PLAYER 2 ROUTINE;
;=====================;
HurtPlayers:	LDY #$00			; > Index 0
		LSR A : BCC +
		PHA
		LDA !CurrentMario
		CMP #$01 : BNE ++
		JSL $00F5B7			; > Hurt Mario (P1)
		BRA +++
	++	JSR HurtP1
	+++	PLA
	+	LSR A : BCC .Nope
		LDA !CurrentMario
		CMP #$02 : BNE HurtP2
		JSL $00F5B7			; > Hurt Mario (P2)
.Nope		RTS

HurtP2:		LDY #$80			; > P2 index
HurtP1:		LDA !P2Invinc-$80,y		;\
		ORA $7490			; | Don't hurt player while star is active or player is invulnerable
		BNE .Return			;/
		LDA #$F8			;\ Give P2 some Y speed
		STA !P2YSpeed-$80,y		;/
		LDA #$20			;\ Play Yoshi "OW" sound
		STA !SPC1			;/
		LDA #$80			;\ Set invincibility timer
		STA !P2Invinc-$80,y		;/
		LDA !P2Water-$80,y		;\
		AND.b #$01^$FF			; | Drop climb
		STA !P2Water-$80,y		;/
		LDA #$00			;\
		STA !P2Floatiness-$80,y		; |
		STA !P2Punch1-$80,y		; | Reset stuff
		STA !P2Punch2-$80,y		; |
		STA !P2Senku-$80,y		; |
		STA !P2Kick-$80,y		;/ > Kick is Climb for Leeway so he does fall off
		STA !P2ClimbTop-$80,y		; Also reset this
		STA !P2ShellSlide-$80,y		;\
		STA !P2ShellDrill-$80,y		; | Reset shell moves
		STA !P2ShellSpeed-$80,y		;/
		LDA !P2HP-$80,y			;\
		DEC A				; |
		STA !P2HP-$80,y			; | Decrement HP and kill player 2 if zero
		BEQ .Kill			; |
		BMI .Kill			;/
		LDA #$0F
		STA !P2HurtTimer-$80,y
		RTS

.Kill		LDA #$01 : STA !P2Status-$80,y	; > This player dies
		LDA !P2Status-$80 : BEQ .Return	;\ (this is actually correct! note the absent ",y")
		LDA !MultiPlayer : BEQ .Music	; | (ignore p2 on singleplayer)
		LDA !P2Status : BEQ .Return	; | If both players are dead, play death music
.Music		LDA #$01 : STA !SPC3		;/
		LDA $1D				;\
		INC A				; | Stop camera on vertical levels
		STA $5F				; |
		STZ !EnableVScroll		;/
.Return		RTS


; Store dynamo pointer in $0C-$0D.
; Set carry to add $02-$03 to destination, clear carry to not include $02-$03
;==================;
;UPDATE GFX ROUTINE;
;==================;
UPDATE_GFX:	BCS .Dynamic
		STZ $02 : STZ $03			; < Clear this unless dynamic option is used
.Dynamic	PHX
		PHB
		JSR GET_VRAM
		PLB
		PHP
		REP #$30
		LDA $0C : BEQ +				; < Return if dynamo is empty
		LDA ($0C) : STA $00
		LDY #$0000
		INC $0C
		INC $0C
	-	LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$00,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$02,x
		INY
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$03,x
		INY #2
		LDA $02
		ASL #4
		CLC : ADC ($0C),y
		STA !VRAMbase+!VRAMtable+$05,x
		INY #2
		CPY $00
		BCS +
		TXA
		CLC : ADC #$0007
		TAX
		BRA -

		+
		PLP
		PLX
		RTS


UPDATE_PAL:	JSR GET_CGRAM
		PHP
		REP #$30
		LDA $0C : BEQ +
		LDA ($0C) : STA $00
		LDY #$0000
		INC $0C
		INC $0C
	-	LDA ($0C),y
		STA !VRAMbase+!CGRAMtable+$00,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!CGRAMtable+$02,x
		INY #2
		LDA ($0C),y
		STA !VRAMbase+!CGRAMtable+$04,x
		INY #2
		CPY $00
		BCS +
		TXA
		CLC : ADC #$0006
		TAX
		BRA -

		+
		PLP
		RTS

; Clipping 1:
; $00,$08: Xpos
; $01,$09: Ypos
; $02,$03: Dimensions
; Clipping 2:
; $04,$0A: Xpos
; $05,$0B: Ypos
; $06,$07: Dimensions
;
; $0C-$0F is used by this routine
;==================================;
;IMPROVED CONTACT DETECTION ROUTINE;
;==================================;
CONTACT16:
		PHX
		LDX #$01
	-	LDA $00,x : STA $0C	;\ Pos1 in $0C
		LDA $08,x : STA $0D	;/
		LDA $0A,x : XBA
		LDA $04,x
		REP #$20
		STA $0E			; > Pos2 in $0E
		LDA $02,x		;\
		AND #$00FF		; | Pos1 + Dim1 - Pos2
		CLC : ADC $0C		; |
		CMP $0E			;/
		BCC .Return		; > Return if smaller
		LDA $06,x		;\
		AND #$00FF		; | Pos2 + Dim2 - Pos1
		CLC : ADC $0E		; |
		CMP $0C			;/
		BCC .Return		; > Return if smaller
		SEP #$20
		DEX : BPL -		; > Check Y coordinates/height too
		PLX
		RTS

		.Return
		SEP #$20
		PLX
		RTS



;========;
;HDMA FIX;
;========;
; Disable HDMA during game mode 0x11

HDMA_FIX:


		.A
		LDA !GameMode
		CMP #$11
		BEQ ..Nope
		LDA $6D9F : STA $420C
		RTL
	..Nope	STZ $420C
		RTL

		.Y
		LDY !GameMode
		CPY #$11
		BEQ ..Nope
		LDY $6D9F : STY $420C
		RTL
	..Nope	LDY #$00 : STY $420C
		RTL



;================;
;CLEAR CHARACTERS;
;================;
CLEAR_CHARACTERS:

		LDA #$00			;\ Clear player 1 and 2 characters
		STA !Characters			;/
		STA !HDMAptr+0
		STA !HDMAptr+1
		STA !HDMAptr+2
		STA !MultiPlayer		; > Disable Multiplayer

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

		STZ !BossData+0			;\
		STZ !BossData+1			; |
		STZ !BossData+2			; |
		STZ !BossData+3			; | Clear boss data
		STZ !BossData+4			; |
		STZ !BossData+5			; |
		STZ !BossData+6			;/

		LDA #$00			; > Set up clear
		STA !NPC_ID+0			;\
		STA !NPC_ID+1			; | Clear NPC ID pointer
		STA !NPC_ID+2			;/
		STA !NPC_Talk+0			;\
		STA !NPC_Talk+1			; | Clear NPC talk pointer
		STA !NPC_Talk+2			;/
		STA !MsgMode			; > Clear message mode
		STA !HDMAptr+0			;\
		STA !HDMAptr+1			; | clear HDMA pointer
		STA !HDMAptr+2			;/

		REP #$20			;\
		LDA !P2CoinIncrease		; |
		AND #$00FF			; |
		CLC : ADC !P2Coins		; | Add up coin increase to make sure player's aren't cheated
		STA !P2Coins			; |
		LDA !P1CoinIncrease		; |
		AND #$00FF			; |
		CLC : ADC !P1Coins		;/
		CLC : ADC !P2Coins		;\
		BEQ .NoCoins			; |
		STZ !P1Coins			; |
		STZ !P2Coins			; |
		CLC : ADC !CoinHoard+0		; |
		STA !CoinHoard+0		; | Put coins in hoard
		LDA !CoinHoard+2		; |
		ADC #$0000			; |
		STA !CoinHoard+2		;/


		LDA #$0F42
		CMP !CoinHoard+1
		BCC .CapHoard			; > If less, then cap hoard
		BNE .NoCoins			; > If greater than, don't cap hoard
		LDA !CoinHoard+0		;\ If equal, check lowest byte
		CMP #$423F : BCC .NoCoins	;/
		LDA #$0F42			; > If it overflows, cap hoard

		.CapHoard
		STA !CoinHoard+1
		LDA #$423F : STA !CoinHoard+0

		.NoCoins
		SEP #$20		
		STZ !P1CoinIncrease		;\ Clear coin increase
		STZ !P2CoinIncrease		;/

		STZ !P1Dead			;\
		LDX #$7F			; | revive and reset players
	-	STZ !P2Base-$80,x		; |
		STZ !P2Base,x			; |
		DEX : BPL -			;/
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
		LDA !Level : STA !MidwayLo,x	;\ Store to midway table
		LDA !Level+1 : STA !MidwayHi,x	;/
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


.MidwayBits	db $04,$0C			; Attribute bits for exits

;===========;
;DELAY DEATH;
;===========;
DELAY_DEATH:

		LDA !MultiPlayer : BEQ .Death	; > Ignore P2 if multiplayer is disabled
		LDA !Characters			;\ If player 2 is Mario, they're dead
		AND #$0F : BEQ .Death		;/
		LDA !P2Status			;\
		CMP #$02			; | If player 2 is still alive, hide player 1
		BCC .NoDeath			;/
.Death		LDA !Characters			;\
		AND #$F0			; |
		BEQ .ReallyDeath		; | Allow custom player 1 character to survive
		LDA !P2Status-$80		; |
		CMP #$02			; |
		BCC .NoDeath			;/
.ReallyDeath	LDA #$01			;\ Set music
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


	;	TSC : XBA
	;	CMP #$37 : BEQ ..SA1
	;	JSL ..SNES
		JMP .Snap

		..SA1
		LDA.b #..SNES : STA $0183
		LDA.b #..SNES>>8 : STA $0184
		LDA.b #..SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	-	LDA $018A : BEQ -
		STZ $018A
		JMP .Snap

		pushpc
		org $00F6DB
		..SNES				; > Only SNES is allowed to do the camera routine
		pullpc


.Process
		LDX #$00			;\
		REP #$20			; | Set up YSpeed index
		LDA !P2YPosLo			; |
		SEC : SBC !P2YPosLo-$80		; |
		STA $02				; |
		BPL +				; |
		INX #4				;/
	+	LDA !P2XPosLo			;\
		SEC : SBC !P2XPosLo-$80		; |
		STA $00				; | Set up XSpeed index
		BPL +				; |
		INX #2				;/
	+	LDA $94				;\
		CLC : ADC.l .XDisp,x		; |
		STA $94				; | Update MARIO coords
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
		BCS .NoSnap
		LDA #$01 : STA !P1Dead		;\
		LDA !CurrentMario		; |
		BEQ .Snap			; |
		DEC A				; | Make sure Mario's PCE reg also says that he's dead
		CLC : ROL #2			; |
		TAY				; |
		LDA #$02 : STA !P2Status-$80,y	;/


.Snap		LDA !MultiPlayer		;\
		BEQ .Override			; |
		LDA !P2Status			; |
		CMP #$02 : BCC .NoOverride	; |
.Override	REP #$20			; | If there's no P2, use P1's coordinates instead
		LDA !P2XPosLo-$80		; |
		STA !P2XPosLo			; |
		LDA !P2YPosLo-$80		; |
		STA !P2YPosLo			;/
.NoOverride

		REP #$20			;\
		LDA !P2XPosLo : STA $94		; | Mario snaps to remaining player
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
		CMP #$02 : BCS +
		LDA #$08 : STA !SPC1
	+	LDA #$90			;\ Overwritten code
		STA $7D				;/
		JML $00F60A			; Execute the rest of the routine

;======================;
;SCROLL OPTIONS ROUTINE;
;======================;
SCROLL_OPTIONS:

		JSL .Main
		LDA.l !HDMAptr+0 : BEQ .Return	;\
		STA $00				; |
		LDA.l !HDMAptr+1		; |
		STA $01				; | Execute HDMA code
		PEA $0000 : PLB			; |
		PEA $F7C2-1			; |
		JML [$3000]			;/

	.Return	JML $00F7C2


		.Main
		LDA !BG2ModeH			;\
		ASL A				; | X = pointer index
		TAX				;/
		BNE .ProcessHorz		;\ 0%
		STZ $1E				;/

		.ProcessHorz
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
		dw .CloseHalfHorz		; 8 - 43.75%
		dw .Close2HalfHorz		; 9 - 37.5%
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
.NoHorz		LDA !BG2ModeV
		ASL A
		TAX
		BNE .ProcessVert		;\ 0%
		STZ $20				;/

		.ProcessVert
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
		dw .CloseHalfVert		; 8 - 43.75%
		dw .Close2HalfVert		; 9 - 37.5%
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
.ConstantVert	CLC : ADC !BG2BaseV		;\ Add temporary BG2 VScroll and write
		STA $20				;/
		RTL

.NoVert		LDA !BG2BaseV
		STA $20
		RTL

.GetDiv		NOP #2
		RTS


;==========;
;1-UP BLOCK;
;==========;

	UpBlock:
		CPY #$0C : BNE .028905		;\ Replace Yoshi with 1-up
		LDY #$05 : STY $05		;/
	.028905	JML $028905			; > Go to shared routine


;========;
;TIDE FIX;
;========;
pushpc
org $00DA58
	BRA $03			; > Source: BEQ $03
org $00DA6F
	BRA $08			; > Source: BEQ $08

pullpc



;================;
;SMOKE SPRITE FIX;
;================;
SmokeFix:

		LDA $77C0,x : BEQ .Clear	; > Clear extra regs for empty slots
		LDA !SmokeHack,x : BNE .Main	; > Run init routine for fresh smoke sprites

		.Init
		LDY $1B				;\
		LDA $77C8,x			; | Set hi X
		CMP $1A				; |
		BCS $01 : INY			; |
		TYA : STA !SmokeXHi,x		;/
		LDY $1D				;\
		LDA $77C4,x			; | Set hi X
		CMP $1C				; |
		BCS $01 : INY			; |
		TYA : STA !SmokeYHi,x		;/
		LDA #$01 : STA !SmokeHack,x	; > Set init flag

		.Main
		LDA $77C4,x : STA $00		;\
		LDA !SmokeYHi,x : STA $01	; |
		LDA !SmokeXHi,x : XBA		; |
		LDA $77C8,x			; |
		REP #$20			; |
		SEC : SBC $1A			; |
		CMP #$0100 : BCS .Erase		; | Smoke sprite must be within the screen or it will be erased
		LDA $00				; |
		SEC : SBC $1C			; |
		CMP #$00E8 : BCS .Erase		; |
		SEP #$20			;/
		LDA $77C0,x			;\ Execute main routine
		JML $0296C5			;/


		.Erase
		SEP #$20			;\ Erase this smoke sprite
		STZ $77C0,x			;/

		.Clear
		LDA #$00
		STA !SmokeXHi,x			;\
		STA !SmokeYHi,x			; | Clear extra regs
		STA !SmokeHack,x		;/
		JML $0296D7			; > Get next slot



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

.SpinHammer	;LDA $7715,x
		;SEC : SBC $96
		;LDA $7729,x
		;SBC $97
		;BCC .NoHammer
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


		.GFX
		TAX
		BIT !GFX_status+$05		;\ Flip bit 0 of $00 (EOR'd to property) if page should be shifted
		BPL $02 : INC $00		;/
		LDA $A2DF,x
		CLC : ADC !GFX_status+$05	; Add hammer offset
		CLC : ADC !GFX_status+$05	; Twice, so highest bit can be used for page bit in YXPPCCCT
		RTL


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

.Main

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



;=========;
;BUILD OAM;
;=========;
BUILD_OAM:

		.Assemble
		PHB
		LDA #$00
		PHA : PLB
		LDY #$1E				; > Start loop at 0x1E to reach all tiles (32 bytes)
	-	LDX.w $8475,y				;\
		LDA.w !OAMhi+3,x			; |
		ASL #2					; |
		ORA.w !OAMhi+2,x			; |
		ASL #2					; |
		ORA.w !OAMhi+1,x			; |
		ASL #2					; |
		ORA.w !OAMhi+0,x			; | Assemble hi OAM table
		STA.w !OAM+$200,y			; |
		LDA.w !OAMhi+7,x			; |
		ASL #2					; |
		ORA.w !OAMhi+6,x			; |
		ASL #2					; |
		ORA.w !OAMhi+5,x			; |
		ASL #2					; |
		ORA.w !OAMhi+4,x			; |
		STA.w !OAM+$201,y			; |
		DEY #2					; |
		BPL -					;/
		PLB
		RTL					; > Return



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
incsrc "Checkpoints.asm"


;===============;
;REALM SELECTION;
;===============;
incsrc "RealmSelect.asm"


;===================;
;BRICK ANIMATION FIX;
;===================;
; $14&F:
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

;=============;
;SIDE EXIT FIX;
;=============;
SideExitFix:

		LDA !RAM_ScreenMode
		LSR A : BCS .Ok
		LDA $1B : BEQ .Ok
		INC A
		CMP $5D : BEQ .Ok
		RTL

	.Ok	STZ $6109
		LDA #$00
		JML $05B165


;=====================;
;TILE UPDATE OPTIMIZER;
;=====================;
; this routine is heavilty altered by Lunar Magic, I'd better be careful...
; there's another routine at $00C227 that ends at $00C299, can probably wire that up too (nope)

pushpc
org $00C143
	JSL TileOptimize_Init		; > Source: SEP #$20 : LDA $06
org $00C1A7
	JSL TileOptimize		; > Source: STA $7F837B

org $00C227
	JSL TileOptimize_Init
org $00C299
	JSL TileOptimize		; > Source: STA $7F837B


pullpc

	TileOptimize:
	; A:		next empty index
	; X:		last used index
	; $0000:	first index to convert


	; 2000 = layer 1	->	3000
	; 3000 = layer 2	->	3800
	; 5000 = layer 3

		STA $7F837B				; > Overwritten code
		LDY $0000
		JSL !GetVRAM
		PHB
		PEA $7F7F
		PLB : PLB

		LDA $1C
		STA $04
		LDA $20
		STA $06

	.Loop	LDA $837D,y
		XBA					; > Swap bytes
		CMP #$8000 : BCC .Go			; > Check for end
		PLB
		RTL

	.Go	CMP #$5000 : BCS .BG3			; > Check for BG3
		JSR Transform				; > Transform address for BG1/BG2
	.BG3	STA.l !VRAMbase+!VRAMtable+$05,x	; > Dest VRAM
		LDA #$FFFF : STA $837D,y		; > Kill this upload
		LDA #$7F7F				;\
		STA.l !VRAMbase+!VRAMtable+$03,x	; |
		TYA					; | Source address
		CLC : ADC #$8381			; |
		STA.l !VRAMbase+!VRAMtable+$02,x	;/
		LDA $837F,y				;\
		XBA					; | Upload size (contains direction + RLE)
		CMP #$C000 : BCS .RLE			; |
		CMP #$8000 : BCS .Normal		; | Check for RLE
		CMP #$4000 : BCS .RLE			; |
	.Normal	INC A					; > Make sure it works with standard VR2 if there's no D/R
		STA.l !VRAMbase+!VRAMtable+$00,x	;/
		AND #$3FFF
		CLC : ADC #$0004
		STA $02
		BRA .LoopX

	.RLE	STA.l !VRAMbase+!VRAMtable+$00,x
		LDA #$0006 : STA $02
	.LoopX	TXA
		CLC : ADC #$0007
		TAX
	.LoopY	TYA
		CLC : ADC $02
		TAY
		JMP .Loop


	.End	PLB
		RTL


		.Init
		STX $0000				; > Preserve original index in $0000
		SEP #$20
		LDA $06
		RTL


	Transform:
		STA $00
		AND #$0800
		BEQ $03 : LDA #$0100
		STA $08
		LDA $00
		AND #$03E0
		LSR #2
		TSB $08					; > Y position (looping pixels)
		LDA !RAM_ScreenMode
		LSR A
		BCS +
		LDA $98
		BRA ++
	+	LDA $9A
	++	AND #$FF00
		TSB $08

		LDA $00
		CMP #$3000
		LDA $08
		BCC .BG1
	.BG2	SEC : SBC $06
		BRA .Check
	.BG1	SEC : SBC $04
	.Check	CMP #$00E8 : BCC .Valid
		CMP #$FFE8 : BCS .Valid
		LDA #$FFFF : STA $837D,y
		LDA $837F,y
		XBA
		CMP #$C000 : BCS .RLE
		CMP #$8000 : BCS .Normal
		CMP #$4000 : BCS .RLE
	.Normal	INC A
		AND #$3FFF
		CLC : ADC #$0004
		BRA .End
	.RLE	LDA #$0006
	.End	STA $02
		PLA : JMP TileOptimize_LoopY		; NEXT!!

	.Valid	LDA $00					;\
		AND #$F7FF				; |
		CMP #$3000				; | Final address transformation
		BCC $03 : ORA #$0800			; |
		ORA #$1000				;/
		RTS


;	LDA $1C
;	SEC : SBC #$0080
;	STA $08
;	LDA $08
;	AND #$FFF0
;	BMI .upper
;	CMP $0C : BCS .return
;	.upper
;	CLC : ADC #$0200
;	CMP $0C : BEQ .return
;	BCS .go
;	.return
;	RTS
;	.go
;	; actual VRAM code


;	REP #$10
;	STA $4314
;	LDY #$0000

;	.Next
;	LDA [$00],y
;	BPL .Go
;	SEP #$30
;	RTS

;	.Go
;	STA $04
;	INY
;	LDA [$00],y
;	STA $03
;	INY
;	LDA [$00],y
;	STZ $07
;	ASL A
;	ROL $07
;	LDA #$18 : STA $4311
;	LDA [$00],y
;	AND #$40
;	LSR #3
;	STA $05
;	STZ $06
;	ORA #$01
;	STA $4310
;	REP #$20
;	LDA $03
;	STA $2116
;	LDA [$00],y
;	XBA
;	AND #$3FFF
;	TAX
;	INX
;	INY #2
;	TYA
;	CLC : ADC $00
;	STA $3212
;	STX $4315
;	LDA $05 : BEQ +
;	SEP #$20
;	LDA $07 : STA $2115
;	LDA #$02 : STA $420B
;	LDA #$19 : STA $4311
;	REP #$21
;	LDA $03 : STA $2116
;	TYA
;	ADC $00
;	INC A
;	STA $4312
;	STX $4315
;	LDX #$0002
;
;+	STX $03
;	TYA
;	CLC : ADC $03
;	TAY
;	SEP #$20
;	LDA $07
;	ORA #$80
;	STA $2115
;	LDA #$02 : STA $420B
;	JMP .Next


;================;
;CHARACTER SELECT;
;================;
;
; To do:
;	- Remap buttons (camera to X, character select to start, close window to B)
;	- Make it work for one player at a time
;	- Make sure PCE keeps track of which player/character is being processed
;
; Seems to work like this:
;	- $04828A does a multiplayer check to see if showing the menu is valid
;	- $04828F does a JSR to a pointer handler
;	- Pointers 2-4 are used ONLY for lives exchanger (other pointers are for other things)
;	- Third entry in pointer table goes to lives exchanger
;	- Lives exchanger JSL's to $009C13, which enables stripe image by jumping to $009D29
;	- $04F513 is a short routine that checks for any player pushing start.
;		- Doing so closes the window and stores lives to the current player.
;	- $04F52B is the bulk of the routine that calculates lives and does stripe image stuff.
;	- $04F415 is the routine that handles opening/closing the window (pointer 2/4)


CHARACTER_SELECT:


	PHP				; > Preserve processor
	LDA $7B8A			;\
	CMP #$10			; | Reset some stuff (otherwise this starts at 0x40)
	BCC $03 : STZ $7B8A		;/
	INC $7B8B			; > Update flash timer
	LDA !CurrentPlayer : TAX	; > X = Player index
	LDA !Characters			;\
	CPX #$00 : BEQ +		; |
	LSR #4				; | $0D = other player's character
+	AND #$0F			; |
	STA $0D				;/
	LDA $6DA6,x			;\
	AND #$0C			; |
	BEQ .ControlInput		; | Process controller input
	LDY #$23 : STY !SPC4		; > Play SFX
	STZ $7B8B			; > Reset flash timer
	CMP #$08 : BEQ .Up		;/
.Down	INC $7B8A			;\ Move down
	BRA .ControlInput		;/
.Up	DEC $7B8A			; > Move up
	LDA !MultiPlayer		;\ Ignore char checks during singleplayer
	BEQ .SinglePlayer		;/
	LDA $7B8A			;\
	CMP $0D : BNE .SinglePlayer	; | Prevent selecting the same character
	DEC $7B8A			;/

	.ControlInput
	LDA !MultiPlayer		;\ Ignore char checks during singleplayer
	BEQ .SinglePlayer		;/
	LDA $7B8A			;\
	CMP $0D : BNE .SinglePlayer	; | Prevent selecting the same character with Mario/down
	INC $7B8A			;/

	.SinglePlayer
	LDA #$04 : STA $00		;\
	INC A : STA $01			; > Set up RAM index for player menu size
	INC A : STA $02			; |
	LDA $7B8A			; |
	BMI .Bottom			; |
	CMP $01,x : BCC .NoInput	; | Make sure selection stays within limits
	LDA #$00 : BRA .Write		; |
.Bottom	LDA $00,x			; |
.Write	STA $7B8A			; |
	CMP $0D : BNE .NoInput		; > Make sure you can't choose Mario with both at the same time
	INC $7B8A			; |
	.NoInput			;/

	LDA.b #.SNES : STA $0183	;\
	LDA.b #.SNES>>8 : STA $0184	; |
	LDA.b #.SNES>>16 : STA $0185	; | Have the SNES do the rest since SA-1 can't access $7E0000-$7FFFFF
	LDA #$D0 : STA $2209		; |
-	LDA $018A : BEQ -		; |
	STZ $018A			;/
	PLP				; > Restore regs
	RTL				; > Return


	.SNES
	PHP				; > Register backup
	PHB : PHK : PLB			; > Bank backup
	LDA !CurrentPlayer
	REP #$30			; > All regs 16-bit
	BNE +				;\
	LDY.w #.EndEarly-.Table		; | "DROP OUT" option doesn't exist for player 1
	BRA $03				;/
+	LDY.w #.EndTable-.Table		;\	(0x50)
	TYA				; |
	CLC : ADC $7F837B		; |
	STA $7F837B			; | Write character names
	TAX				; |
	SEP #$20			; > A 8-bit
	LDA #$FF : STA $7F837D,x	; \ Write end of table
	DEX				; /
	DEY				; |
-	LDA .Table,y			; |	($04:F4B2)
	STA $7F837D,x			; |
	DEX				; |
	DEY				; |
	BPL -				;/

	INX				; > Get index to start of upload
	STX $0E				; > Backup in $0E
	LDA $7B8B			;\
	AND #$18			; | Only flash certain frames
	EOR #$18			; |
	BEQ .Return			;/
	LDA #$00 : XBA			;\
	LDA $7B8A			; | Y = position of selection
	TAY				;/
-	BEQ .Flash			; > If this is the selection, perform FLASH
	STX $00				;\
	LDA $7F8380,x			; |
	CLC : ADC #$05			; |
	CLC : ADC $00			; |
	XBA : ADC $01			; | Find proper stripe location
	XBA : TAX			; |
	DEY				; |
	BMI .Return			; |
	BRA -				;/

	.Flash
	REP #$20
	LDA $7F8380,x			; > Check length
	AND #$00FF
	TAY
	TXA
	CLC : ADC #$8381
	STA $00
	SEP #$20
	LDA #$7F : STA $02
	LDA #$3C
-	STA [$00],y
	DEY #2
	BPL -

	.Return
	SEP #$20
	LDA !CurrentPlayer
	BEQ .P1

	.P2
	LDA !Characters			;\
	LSR #4				; | Visually disable P1's character
	STA $00				; |
	JSR .Prevent			;/
	LDA $7B8A
	CMP #$01 : BEQ +		;\
	CMP #$04 : BEQ +		; | Only allow legal characters
	CMP #$06 : BEQ +		;/
	AND #$0F : STA $00		;\
	LDA !Characters			; | Store P2 character
	AND #$F0 : ORA $00		; |
	STA !Characters			;/
	LDA #$01 : STA !MultiPlayer	; > Enable multiplayer
	BRA +				; > Return

	.P1
	LDA !MultiPlayer		;\ Ignore P2 if multiplayer is off
	BEQ ..NoPrevent			;/
	LDA !Characters			;\
	AND #$0F			; |
	STA $00				; | Visually disable P2's character
	JSR .Prevent			; |
	..NoPrevent			;/
	LDA $7B8A
	CMP #$01 : BEQ +		; < Luigi not inserted
	CMP #$04 : BEQ +		; < Alter not inserted
	CMP #$06 : BEQ +		; < Drop out function should not be used by P1
	ASL #4 : STA $00		;\
	LDA !Characters			; | Store P1 character
	AND #$0F : ORA $00		; |
	STA !Characters			;/
+	PLB				; > Restore bank
	PLP				; > Restore processor
	RTL				; > Return


	.Prevent
	LDX $0E
	LDA #$00 : XBA			;\ Y = stripe to disable
	LDA $00 : TAY			;/
-	BEQ ..Prevent			;\
	STX $00				; |
	LDA $7F8380,x			; |
	CLC : ADC #$05			; |
	CLC : ADC $00			; | Find proper stripe location
	XBA : ADC $01			; |
	XBA : TAX			; |
	DEY				; |
	BMI ..Return			; |
	BRA -				;/
	..Prevent
	LDA $7F837E,x			;\
	AND.b #$1F^$FF			; | Move 1 step to the right
	ORA #$06			; |
	STA $7F837E,x			;/
	..Return
	RTS


	.ERASE
	LDA.b #..SNES : STA $0183	;\
	LDA.b #..SNES>>8 : STA $0184	; |
	LDA.b #..SNES>>16 : STA $0185	; | Have the SNES do the rest since SA-1 can't access $7E0000-$7FFFFF
	LDA #$D0 : STA $2209		; |
-	LDA $018A : BEQ -		; |
	STZ $018A			;/
	RTL				; > Return

	..SNES
	PHP
	SEP #$30
	PHB : PHK : PLB
	LDA $7B87			;\
	CMP #$02 : BEQ +		; | Only when opening/closing character select menu
	CMP #$04 : BNE ++		;/
+	REP #$30
	LDY.w #.EndClear-.Clear-1
	TYA
	CLC : ADC $7F837B
	STA $7F837B
	TAX
	SEP #$20
-	LDA .Clear,y
	STA $7F837D,x
	DEX
	DEY
	BPL -
	STZ $7B8A			; > Reset selection
++	LDX #$00 : LDA $6DB4		; > Restore overwritten code
	PLB
	PLP
	RTL


	.REMAP1				; > Choosing a level

;	LDA #$00

	LDA !MultiPlayer
	BEQ ..P1
	LDA $6DA7
	ORA $6DA9
..P1	ORA $6DA6
	ORA $6DA8
	RTL


	.REMAP2				; > Choosing a character in the menu
	LDA !CurrentPlayer
	BNE ..P2
	LDA $6DA6			;\ Player 1
	ORA $6DA8			;/
	RTL
..P2	LDA $7B8A
	CMP #$06 : BNE ++
	LDA $6DA7			;\
	ORA $6DA9			; |
	AND #$80 : BEQ +		; | Player 2 dropping out
	LDA #$00 : STA !MultiPlayer	; |
	LDA #$80			;/
+	RTL
++	LDA $6DA7			;\ Player 2 not dropping out
	ORA $6DA9			;/
	RTL


	.REMAP3				; > Enabling free camera
	LDA $6DA6
	AND #$10
	BEQ ..NoP1
	LDA #$00 : STA !CurrentPlayer
	LDA #$10
	RTL
	..NoP1
	LDA $6DA7
	AND #$10
	BEQ ..Return
	LDA #$01 : STA !CurrentPlayer
	LDA #$10
	..Return
	RTL


	.REMAP4				; > Moving on OW

;	LDA #$00


	LDA !MultiPlayer		;\
	BEQ ..P1			; | Include P2 input during multiplayer
	LDA $6DA7			;/
..P1	ORA $6DA6			; > Add P1 input
	AND #$0F			; > Get directional input
	RTL				; > Return


; E	1:80	0x01	> End flag
; H	1:40	0x04	\
; H	1:20	0x02	 | VRAM destination
; H	1:10	0x01	/
; Yh	1:08	0x20	> Hi bit of Y
; Xh	1:04	0x20	> Hi bit of X
; y	1:02	0x10	\
; y	1:01	0x08	 |
; y	2:80	0x04	 | Lo position of y
; y	2:40	0x02	 |
; y	2:20	0x01	/
; xlo	2:1F	0x1F	> lo position of x
; D	3:80	0x01	> Direction (0 = horizontal, 1 = vertical)
; R	3:40	0x01	> RLE flag
; l	3:3F	0x3F	> RLE length
; L	4:FF	0xFF	> Non-RLE length


.Table
db $51,$85,$00,$09			; < "MARIO"
db $16,$28,$0A,$28,$1B,$28,$12,$28,$18,$28
db $51,$A5,$00,$09			; < "LUIGI"
db $15,$28,$1E,$28,$12,$28,$10,$28,$12,$28
db $51,$C5,$00,$0B			; < "KADAAL"
db $14,$28,$0A,$28,$0D,$28,$0A,$28,$0A,$28,$15,$28
db $51,$E5,$00,$0B			; < "LEEWAY"
db $15,$28,$0E,$28,$0E,$28,$20,$28,$0A,$28,$22,$28
db $52,$05,$00,$09			; < "ALTER"
db $0A,$28,$15,$28,$1D,$28,$0E,$28,$1B,$28
.EndEarly
db $52,$45,$00,$0F			; < "DROP OUT"
db $0D,$28,$1B,$28,$18,$28,$19,$28,$FC,$38,$18,$28,$1E,$28,$1D,$28
.EndTable

.Clear
db $51,$85,$40,$10
db $FC,$38
db $51,$A5,$40,$10
db $FC,$38
db $51,$C5,$40,$10
db $FC,$38
db $51,$E5,$40,$10
db $FC,$38
db $52,$05,$40,$10
db $FC,$38
db $52,$45,$40,$10
db $FC,$38
db $FF
.EndClear





; This is actually pretty complicated.
; Each character has 7 components:
; - Upload sprite GFX
; - Upload sprite tilemap
; - Upload sprite palette
; - Unpack portrait
; - Upload portrait GFX
; - Upload portrait tilemap
; - Upload portrait palette

.CharacterTable
	dw ..Mario
	dw ..Luigi
	dw ..Kadaal
	dw ..Leeway
	;dw ..Alter

..Mario

..Luigi

..Kadaal

..Leeway

..Alter



..SpritePal

..SpriteOAM

..MarioPortrait

..LuigiPortrait

..KadaalPortrait

..LeewayPortrait

..AlterPortrait

..UploadPortrait

..UploadPalette

..DrawPortrait



;=========;
;BRK RESET;
;=========;
BRK:

		SEP #$30			; Make sure the SNES is doing this
		TSC
		XBA
		CMP #$37 : BNE .SNES
		LDA.b #.SNES : STA $0183
		LDA.b #.SNES>>8 : STA $0184
		LDA.b #.SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
		BRA $FE

		.SNES
		STZ $4200			; Set up RESET
		SEI
		SEP #$30
		LDA #$FF
		STA $2141
		LDA #00
		PHA : PLB
		STZ $420C

		LDA #$00 : STA.w $0000		; Clear all SNES RAM
		REP #$20
		LDA #$8008 : STA $4300
		STZ $4302
		STZ $4303
		STZ $4305
		STZ $2181
		STZ $2182
		LDX #$01 : STX $420B
		LDA #$8008 : STA $4300
		STZ $4302
		STZ $4303
		STZ $4305
		STZ $2181
		STX $2183
		STX $420B
		SEP #$20

	;	JML $008016
		JML $000000+read2($00FFFC)	; Go to RESET vector


;=================;
;BLOCK ADJUSTMENTS;
;=================;
org $00F05C+$0D
	db $07		; Org: $06

org $00F0C8+$0D


;=======;
;HIJACKS;
;=======;

org $00828C
	JSL HDMA_FIX_Y			;\ Source: LDY $6D9F : STY $420C
	NOP #2				;/

org $0082B6
	JSL HDMA_FIX_A			;\ Source: LDA $6D9F : STA $420C
	NOP #2				;/


org $00939A				; Game mode 00 routine
	JSL CLEAR_CHARACTERS


org $009CB1
	db $00				; < Disable intro level

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

org $00D0D8
	NOP #3				;\ Skip game over code (source: DEC $6DBE : BPL $09)
	BRA $09				;/

org $00D0E6				; Mario's death routine
	;JML DEATH_GAMEMODE_Init		;\ Source: LDY #$0B : LDA $0F31
	;NOP				;/

	LDY #$0B : LDA $6F31

org $00E98F
	BEQ $10				; Disable side exit for Mario (Source: BEQ $10)

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

org $0288F9
	JML UpBlock			; > Source: CPY #$0C : BNE $08 ($028905)

org $028B84
	db $4A,$4B,$4B,$4A		;\ Brick pieces, apparently STEAR can't handle this
	db $4A,$4B,$4B,$4A		;/ (BrokenBlock2 in all.log)

org $0296C0
	JML SmokeFix			;\ Main routine for smoke sprites
	NOP				;/ Source: LDA $77C0,x : BEQ $12 ($0296D7)

org $02A326
	JSL HAMMER_GFX			; Source: TAX : LDA.w $A2DF,x

org $02A405
	JML HAMMER_SPINJUMP

org $02DAC3
	JML HAMMER_SPAWN		; Source: LDA #$04 : STA $170B,y
	NOP


org $048086

;	JSL CLEAR_PLAYER2		; Hijack some Overworld routine
		REP #$30
		STZ $03

org $04824B
	HIDEOUT_CHECK:
		BEQ .Skip		; Enable an unused beta routine

		; There's 20 bytes of unused code here, so I'm not overwriting anything important.

		LDA $6DA4
		ORA $6DA8
		BNE .Skip
		JML LOAD_HIDEOUT
		dl GENERATE_BLOCK	;\ 8 bytes free at $048259, used as vectors
		NOP #5			;/
		.Skip

org $04828A
	BRA $03 : NOP #3		; LDY $6DB2 : BEQ $06, enable character select always

org $048366
	JSL CHARACTER_SELECT_REMAP3	;\ LDA $6DA8 : ORA $6DA9
	NOP #2				;/
	NOP #2				; > AND #$30

org $04837D
	LDA $18				;\ LDA $16 : AND #$10
	AND #$40			;/

org $049150
	JSL CHARACTER_SELECT_REMAP1	;\ LDA $16 : ORA $18
	AND #$80			;/ AND #$C0

org $04925F
	JSL CHARACTER_SELECT_REMAP4	; > LDA $16 : AND #$0F

org $04F415
	JSL CHARACTER_SELECT_ERASE	;\ LDX #$00 : LDA $6DB4
	NOP				;/

org $04F513
	JSL CHARACTER_SELECT_REMAP2	;\ LDA $6DA6 : ORA $6DA7
	NOP #2				;/
	AND #$80			; > AND #$10

org $04F52B
	JSL CHARACTER_SELECT		;\ LDA $6DA6 : AND #$C0
	RTS				;/

org $05B161
	JML SideExitFix			; STZ $6109 : LDA #$00
	NOP

org $05D89B
	JSL LOAD_HIDEOUT_Load		; Hijack level load init

org $05D9D7
;	JML CHECKPOINTS			; Checkpoint check routine
;	NOP

	LDA !LevelTable,x
	AND #$40


;==========;
;FREE $6F40;
;==========;
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

;=========;
;BUILD OAM;
;=========;

org $008449

	STZ $4300
	REP #$20
	STZ $2102
	LDA #$0004 : STA $4301
	LDA.w #!OAM>>8 : STA $4303
	LDA #$0220 : STA $4305
	LDY #$01 : STY $420B
	SEP #$20
	LDA #$80 : STA $2103
	LDA $3F : STA $2102
	RTS

warnpc $008475


org $008494
				; < This is hijacked by SA-1 but WE'RE OVERWRITING IT!! >:D

	LDA.b #BUILD_OAM		;\
	STA $3180			; |
	LDA.b #BUILD_OAM>>8		; |
	STA $3181			; | Send SA-1 to subroutine
	LDA.b #BUILD_OAM>>16		; |
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
;org $00A295				;\ This one is handled by SP_Level
;	JSL KILL_OAM_Special		;/


;================;
;BRK RESET MAPPER;
;================;

org $00FFE6
	dw $8A58
org $00FFF6
	dw $8A58


org $008A58
	JML BRK



