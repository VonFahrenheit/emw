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

; 048437	;\
; 04843A	; | used by Fe26
; 04843D	; |
; 048440	;/

org $048443
dl GET_DYNAMIC_TILE
dl UPDATE_CLAIMED_GFX
dl TRANSFORM_GFX
dl LevelSelect_Portrait_Long
dl GET_ROOT

; 048452	; used by SP_Level



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
	PLB				; | Load coordinates in X/Y, then JSL here
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
	PLB				; | Wrapper for the routine that gets the CGRAM table index into Y
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


CODE_138058:
	PHB
	PHK
	PLB
	JSR RGBtoHSL
	PLB
	RTL

CODE_138060:
	PHB
	PHK
	PLB
	JSR HSLtoRGB
	PLB
	RTL

CODE_138068:
	PHB
	PHK
	PLB
	JSR MixRGB
	PLB
	RTL

CODE_138070:
	PHB
	PHK
	PLB
	JSR MixHSL
	PLB
	RTL


incsrc "5bpp.asm"
incsrc "Transform_GFX.asm"


;=========;
;Get_MAP16;
;=========;
; --Instructions--
;
; Load A and Y with 16-bit X and Y offsets for block to check, then do:
; JSL !GetMap16Sprite
;
; Returns with the following:
; A	- 16-bit acts like setting
; [$00]	- pointer to map16 acts like settings
; $03	- 16-bit tile number
; [$05]	- pointer to high byte of map16 number
; A is 16-bit, X/Y are 8-bit
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
	ADC.L $006CB6,x			; Add with massive map16 table
	STA $05				; Store to scratch RAM
	LDA.L $006CD6,x			; Load massive map16 table
	ADC $01				; Add with sprite Y pos (hi)
	STA $06				; Store to scratch RAM

	.Shared
	JSR .ABSOLUTE_Shared		; do the thing
	LDX !SpriteIndex		; Load sprite index in X

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
	CMP $73D7
	SEP #$20
	BCS ..OutOfBounds
	LDA $03
	CMP $5D : BCS ..OutOfBounds
	PLA
	LDX $03
	CLC : ADC.l $006CB6,x
	STA $05
	LDA.l $006CD6,x
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
	STA $03
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
;GET ROOT;
;========;
; Load unsigned 17-bit number in A + carry, then JSR here.
; A returns in same mode as before (PHP : PLP)
; A holds square root of input number.
GET_ROOT:	PHB : PHK : PLB
		JSR .Main
		PLB
		RTL


.Main		PHX
		PHP
		REP #$30
		BCS .010000
		CMP #$4000 : BCS .4000
		CMP #$1000 : BCS .1000
		CMP #$0400 : BCS .0400
		CMP #$0100 : BCS .0100
		ASL A
		TAX
		LDA.w .Table,x
		PLP
		PLX
		RTS

.010000		ROR A
		LSR A
.4000		XBA
		AND #$00FE
		ASL A
		TAX
		LDA.w .Table,x
		ASL #4
		PLP
		PLX
		BCC +
		ASL A
	+	RTS

.1000		XBA
		ROL #2
		AND #$00FE
		ASL A
		TAX
		LDA.w .Table,x
		ASL #3
		PLP
		PLX
		RTS

.0400		LSR #3
		AND #$FFFE
		TAX
		LDA.w .Table,x
		ASL #2
		PLP
		PLX
		RTS

.0100		LSR A
		AND #$FFFE
		TAX
		LDA.w .Table,x
		ASL A
		PLP
		PLX
		RTS



; Shifted 8 bits left to account for "hexadecimals"
.Table		dw $0000,$0100,$016A,$01BB,$0200,$023C,$0273,$02A5	; 00-07
		dw $02D4,$0300,$032A,$0351,$0377,$039B,$03BE,$03DF	; 08-0F
		dw $0400,$0420,$043E,$045C,$0479,$0495,$04B1,$04CC	; 10-17
		dw $04E6,$0500,$0519,$0532,$054B,$0563,$057A,$0591	; 18-1F
		dw $05A8,$05BF,$05D5,$05EB,$0600,$0615,$062A,$063F	; 20-27
		dw $0653,$0667,$067B,$068F,$06A2,$06B5,$06C8,$06DB	; 28-2F
		dw $06EE,$0700,$0712,$0724,$0736,$0748,$0759,$076B	; 30-37
		dw $077C,$078D,$079E,$07AE,$07BF,$07CF,$07E0,$07F0	; 38-3F
		dw $0800,$0810,$0820,$082F,$083F,$084E,$085E,$086D	; 40-47
		dw $087C,$088B,$089A,$08A9,$08B8,$08C6,$08D5,$08E3	; 48-4F
		dw $08F2,$0900,$090E,$091C,$092A,$0938,$0946,$0954	; 50-57
		dw $0961,$096F,$097D,$098A,$0997,$09A5,$09B2,$09BF	; 58-5F
		dw $09CC,$09D9,$09E6,$09F3,$0A00,$0A0D,$0A19,$0A26	; 60-67
		dw $0A33,$0A3F,$0A4C,$0A58,$0A64,$0A71,$0A7D,$0A89	; 68-6F
		dw $0A95,$0AA1,$0AAD,$0AB9,$0AC5,$0AD1,$0ADD,$0AE9	; 70-77
		dw $0AF4,$0B00,$0B0C,$0B17,$0B23,$0B2E,$0B3A,$0B45	; 78-7F
		dw $0B50,$0B5C,$0B67,$0B72,$0B7D,$0B88,$0B93,$0B9E	; 80-87
		dw $0BA9,$0BB4,$0BBF,$0BCA,$0BD5,$0BE0,$0BEB,$0BF5	; 88-8F
		dw $0C00,$0C0B,$0C15,$0C20,$0C2A,$0C35,$0C3F,$0C4A	; 90-97
		dw $0C54,$0C5F,$0C69,$0C73,$0C7D,$0C88,$0C92,$0C9C	; 98-9F
		dw $0CA6,$0CB0,$0CBA,$0CC4,$0CCE,$0CD8,$0CE2,$0CEC	; A0-A7
		dw $0CF6,$0D00,$0D0A,$0D14,$0D1D,$0D27,$0D31,$0D3B	; A8-AF
		dw $0D44,$0D4E,$0D57,$0D61,$0D6B,$0D74,$0D7E,$0D87	; B0-B7
		dw $0D91,$0D9A,$0DA3,$0DAD,$0DB6,$0DBF,$0DC9,$0DD2	; B8-BF
		dw $0DDB,$0DE4,$0DEE,$0DF7,$0E00,$0E09,$0E12,$0E1B	; C0-C7
		dw $0E24,$0E2D,$0E36,$0E3F,$0E48,$0E51,$0E5A,$0E63	; C8-CF
		dw $0E6C,$0E75,$0E7E,$0E87,$0E8F,$0E98,$0EA1,$0EAA	; D0-D7
		dw $0EB2,$0EBB,$0EC4,$0ECC,$0ED5,$0EDE,$0EE6,$0EEF	; D8-DF
		dw $0EF7,$0F00,$0F09,$0F11,$0F1A,$0F22,$0F2A,$0F33	; E0-E7
		dw $0F3B,$0F44,$0F4C,$0F54,$0F5D,$0F65,$0F6D,$0F76	; E8-EF
		dw $0F7E,$0F86,$0F8E,$0F97,$0F9F,$0FA7,$0FAF,$0FB7	; F0-F7
		dw $0FBF,$0FC8,$0FD0,$0FD8,$0FE0,$0FE8,$0FF0,$0FF8	; F8-FF



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
		TYA
		CLC : ADC #$0006
		TAY
		BCC .Loop
		PLP
		SEC
		RTS

.SlotFound	PLP
		CLC
		RTS



; load A with number of extra slots to request, then call this (A=0 means you request 1 tile)
; if carry returns clear, no slot was found
; if carry returns set, then Y = index to table
;========================;
;GET DYNAMIC TILE ROUTINE;
;========================;

; $00: number of extra tiles requested
; $01: number of tiles not yet checked for availability
; $02: used as a loop counter when checking several tiles for requests larger than 1
; $03: used as scratch

GET_DYNAMIC_TILE:
		PHX
		PHB : PHK : PLB
		STA $00

		LDY #$00
.Loop		STY $01
		LDA $00 : STA $02

.Process	LDX !DynamicTile,y
		CPX #$10 : BCS .CheckSpace
		LDA $3230,x : BEQ .CheckSpace
		LDA !ClaimedGFX
		CMP #$10 : BCC .CheckSpace
		AND #$0F
		STA $03
		CPY $03 : BNE .CheckSpace

.Next		LDA !ClaimedGFX
		LSR #4
		STA $03
		TYA
	-	CLC : ADC $03
		CMP #$10 : BCC +
		CLC

.Return		PLB
		PLX
		RTL

	+	TAY
		BRA .Loop

.CheckSpace	TYA
		EOR #$0F
		CMP $02 : BCC .Return
		DEC $02 : BMI .ThisOne
		INY
		CPY #$08 : BEQ .Loop
		BRA .Process

.ThisOne	TYA
		SEC : SBC $00
		TAY
		SEC
		BRA .Return





; Store dynamo pointer in $0C-$0D, as usual.
;==========================;
;UPDATE CLAIMED GFX ROUTINE;
;==========================;
UPDATE_CLAIMED_GFX:
		PHY
		LDA !ClaimedGFX
		AND #$0F
		ASL A
		CMP #$10
		BCC $03 : CLC : ADC #$10
		STA $02
		LDA !GFX_Dynamic
		AND #$70
		ASL A
		ADC $02
		STA $02
		LDA !GFX_Dynamic
		AND #$0F
		CLC : ADC $02
		STA $02
		STZ $03
		LDA !GFX_Dynamic
		BPL $02 : INC $03
		JSR UPDATE_GFX_Dynamic
		PLY
		RTL

; Store dynamo pointer in $0C-$0D.
; Set carry to add $02-$03 to destination, clear carry to not include $02-$03
; unit of $02 is number of tiles to add, NOT address bytes
;==================;
;UPDATE GFX ROUTINE;
;==================;
UPDATE_GFX:	BCS .Dynamic
.Static		STZ $02 : STZ $03			; < Clear this unless dynamic option is used
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



;=====================;
;HURT PLAYER 2 ROUTINE;
;=====================;
HurtPlayers:	LDY #$00			; > Index 0
		LSR A : BCC +
		PHA
		LDA !CurrentMario
		CMP #$01 : BNE ++
		LDA $7497 : BNE +++
		JSL $00F5B7			; > Hurt Mario (P1)
		BRA +++
	++	JSR HurtP1
	+++	PLA
	+	LSR A : BCC .Nope
		LDA !CurrentMario
		CMP #$02 : BNE HurtP2
		LDA $7497 : BNE .Nope
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
		STA !P2Punch1-$80,y		; |
		STA !P2Punch2-$80,y		; | Reset stuff
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
		REP #$20			;\
		STZ !P1Coins			; | Players lose all coins upon death
		STZ !P2Coins			; |
		SEP #$20			;/
		LDA $1D				;\
		INC A				; | Stop camera on vertical levels
		STA $5F				; |
		STZ !EnableVScroll		;/
.Return		RTS






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



;==============================;
;ROUTINES FOR HSL FORMAT COLORS;
;==============================;
;
; these codes will convert colors between RGB and HSL format
; RGB colors are stored at $6703 (like normal) and HSL colors are stored at !PaletteHSL
; the HSL section is 1KB long, with the first 768 bytes holding HSL mirrors of the RGB palette
; the last 256 bytes is scratch RAM / cache for processing HSL colors without overwriting stuff
;
; input:
;	A = color balance (00-1F between palette and buffer, used in RGB mixer only)
;	X = color index (00-FF for colors 00-FF, 100-2FF to index HSL cache and buffer)
;	Y = number of colors to convert (00 or 100+ will convert entire palette)
;	8-bit and 16-bit modes are both accepted
;
; output:
;	for RGB to HSL, color is written to !PaletteHSL
;	for HSL to RGB, color is written to buffer at !PaletteHSL+$900 and also uploaded to CGRAM
;	for RGB mixer, colors is written to buffer at !PaletteHSL+$900
;	for HSL mixer, colors from !PaletteHSL and !PaletteHSL+$300 are mixed and written to !PaletteHSL+$600
;
; scratch RAM use:
;	$00 = R
;	$02 = G
;	$04 = B
;	$06 = D
;	$08 = scratch
;	$0A = H + scratch
;	$0C = S + scratch
;	$0E = L


	!color1		= !BigRAM+$00
	!color2		= !BigRAM+$02
	!color3		= !BigRAM+$04
	!colorloop	= !BigRAM+$06
	!colormix	= !BigRAM+$08	; uses 4 bytes

RGBtoHSL:
		PHP
		REP #$30
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		DEY
		STY !colorloop


; during the process, Y will index the RGB palette and X will index the HSL palette

		STX $00
		TXA
		ASL A
		TAY
		CLC : ADC $00
		TAX
		TYA
		AND #$01FF
		TAY


		TSC
		AND #$FF00
		CMP #$3700 : BEQ .Go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTS

	.SA1
		PEA.w ..return-1
		PHP
		REP #$30
		LDX $00
		LDY $02
		BRA .Go
		..return
		RTL

	.Go

	-	CPY #$01FE			;\
		BCC $03 : LDY #$01FE		; | cap overflow
		CPX #$08FD			; |
		BCC $03 : LDX #$08FD		;/

		LDA $6703,y			;\
		AND #$001F			; | R
		STA $00				;/
		LDA $6703,y			;\
		LSR #5				; | G
		AND #$001F			; |
		STA $02				;/
		LDA $6703,y			;\
		XBA				; |
		LSR #2				; | B
		AND #$001F			; |
		STA $04				;/
		JSR .Convert

		SEP #$20
		LDA $0A : STA !PaletteHSL,x
		LDA $0C : STA !PaletteHSL+1,x
		LDA $0E : STA !PaletteHSL+2,x
		REP #$20

		INY #2
		INX #3
		DEC !colorloop : BPL -

		PLP
		RTS




; this code will convert RGB to HSL
	.Convert
		LDA $00
		CMP $02 : BCC .G
		CMP $04 : BCC .B
	.R	LDA $02
		CMP $04 : BCC .RBG
	.RGB	LDA $00				;\
		SEC : SBC $04			; |
		BRA +				; | get D (R greatest)
	.RBG	LDA $00				; |
		SEC : SBC $02			; |
	+	STA $06				;/
		LDA $02 : STA $08
		LDA $04 : STA $0A
		LDA #$0000
		BRA .LoadEquation

	.G	LDA $02
		CMP $04 : BCC .B
		LDA $00
		CMP $04 : BCC .GBR
	.GRB	LDA $02				;\
		SEC : SBC $04			; |
		BRA +				; | get D (G greatest)
	.GBR	LDA $02				; |
		SEC : SBC $00			; |
	+	STA $06				;/
		LDA $04 : STA $08
		LDA $00 : STA $0A
		LDA #$0050
		BRA .LoadEquation

	.B	LDA $00
		CMP $02 : BCC .BGR
	.BRG	LDA $04				;\
		SEC : SBC $02			; |
		BRA +				; | get D (B greatest)
	.BGR	LDA $04				; |
		SEC : SBC $00			; |
	+	STA $06				;/
		LDA $00 : STA $08
		LDA $02 : STA $0A
		LDA #$00A0

	.LoadEquation
		STA $0C
		SEP #$20
		STZ $2250
		REP #$20
		LDA $08
		SEC : SBC $0A
		STA $2251
		LDA #$0028 : STA $2253
		BRA $00 : NOP
		LDA $2306 : STA $2251
		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $06 : STA $2253
		NOP
		LDA $0C
		CLC : ADC $2306
		BPL $04 : CLC : ADC #$00F0
		CMP #$00F0
		BCC $03 : SBC #$00F0
		STA $0A				; H get!

	.SortColors
		LDA $00
		CMP $02 : BCC ..NotR
		CMP $04 : BCC ..NotR
		STA !color1			; greatest color = R
		LDA $02
		CMP $04 : BCC ..RBG
	..RGB	STA !color2
		LDA $04 : STA !color3
		BRA .ColorsDone
	..RBG	STA !color3
		LDA $04 : STA !color2
		BRA .ColorsDone

	..NotR	LDA $02
		CMP $04 : BCC ..NotG
		STA !color1
		LDA $00
		CMP $04 : BCC ..GBR
	..GRB	STA !color2
		LDA $04 : STA !color3
		BRA .ColorsDone
	..GBR	STA !color3
		LDA $04 : STA !color2
		BRA .ColorsDone

	..NotG	LDA $04 : STA !color1
		LDA $00
		CMP $02 : BCC ..BGR
	..BRG	STA !color2
		LDA $02 : STA !color3
		BRA .ColorsDone
	..BGR	STA !color3
		LDA $02 : STA !color2

	.ColorsDone
		LDA !color1
		CLC : ADC !color3
	;	LSR A
		STA $0E				; L get!

		SEP #$20
		STZ $2250
		REP #$20
		LDA $06 : STA $2251
		LDA #$003F : STA $2253
		BRA $00 : NOP
		LDA $2306 : STA $2251
		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $0E
		ASL A
		SEC : SBC #$003F
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$003F
		EOR #$FFFF : INC A
		STA $2253
		BRA $00 : NOP
		LDA $2306
		ASL A
		STA $0C		; S get!

		RTS


HSLtoRGB:
		PHP
		REP #$30
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		TYA
		ASL A
		DEY
		STY !colorloop
		STA !colormix				; save this for CGRAM upload
		STX !colormix+2				; save this for CGRAM upload

; during the process, Y will index the RGB palette and X will index the HSL palette

		STX $00
		TXA
		ASL A
		TAY
		CLC : ADC $00
		TAX
		TYA
		AND #$01FF
		TAY


		TSC
		AND #$FF00
		CMP #$3700 : BEQ .Go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTS

	.SA1
		PHB
		PEA.w ..return-1
		PHP
		REP #$30
		LDX $00
		LDY $02
		BRA .Go
		..return
		PLB
		RTL

	.Go

	-	CPY #$01FE			;\
		BCC $03 : LDY #$01FE		; | cap overflow
		CPX #$08FD			; |
		BCC $03 : LDX #$08FD		;/

		LDA !PaletteHSL,x		;\
		AND #$00FF			; | H
		STA $0A				;/
		LDA !PaletteHSL+1,x		;\
		AND #$00FF			; | S
		STA $0C				;/
		LDA !PaletteHSL+2,x		;\
		AND #$00FF			; | L
		STA $0E				;/

		JSR .Convert

		PHX
		TYX
		LDA $04				;\
		ASL #5				; |
		ORA $02				; | assemble RGB
		ASL #5				; |
		ORA $00				; |
		STA !PaletteHSL+$900,x		;/
		PLX

		INY #2
		INX #3
		DEC !colorloop : BPL -


		SEP #$30
		JSR GET_CGRAM
		LDA.b #!VRAMbank
		PHA : PLB
		LDA.b #!PaletteHSL>>16 : STA !CGRAMtable+$04,y			; bank (VRAM bank)
		LDA.l !colormix+2 : STA !CGRAMtable+$05,y		; dest CGRAM
		REP #$20
		AND #$00FF
		ASL A
		ADC.w #!PaletteHSL+$900
		STA !CGRAMtable+$02,y			; source address
		LDA.l !colormix : STA !CGRAMtable+$00,y		; upload size

	; leave bank because the end of the wrapper is after the RTS anyway

		PLP
		RTS



; this code will convert HSL to RGB
	.Convert
		SEP #$20
		STZ $2250
		REP #$20
		LDA $0E
		ASL A
		SEC : SBC #$003F
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$003F
		EOR #$FFFF : INC A
		STA $2251
		LDA $0C : STA $2253
		BRA $00 : NOP
		LDA $2306
		LSR #7
		STA !color1			; strongest color

; formula here is:
; (63 - pos(2L - 63)) x S / 128



		; get H / 20, but fractions
		; so 256 x H / 20

		SEP #$20
		LDA #$01 : STA $2250
		REP #$20
		LDA $0A
		XBA
		LSR A
		STA $2251
		LDA #$0028 : STA $2253
		BRA $00 : NOP
		LDA $2306
		ASL A
		AND #$01FF
		SEC : SBC #$0100
		BPL $04 : EOR #$FFFF : INC A
		SEC : SBC #$0100
		EOR #$FFFF : INC A
		STA $2251
		SEP #$20
		STZ $2250
		REP #$20
		LDA !color1 : STA $2253
		BRA $00 : NOP
		LDA $2307 : STA !color2		; middle color

; factor:
; 1 - pos((H / 40) mod2 - 1)
;
; 256 - pos((H / 40) mod 512 - 256)
		LDA $0E
	;	ASL A
		SEC : SBC !color1
		LSR A
		STA !color3			; weakest color
		CLC : ADC !color1		;\ complete strongest color
		STA !color1			;/
		LDA !color3			;\
		CLC : ADC !color2		; | complete middle color
		STA !color2			;/

		LDA $0A
		CMP #$0028 : BCC .RGB
		CMP #$0050 : BCC .GRB
		CMP #$0078 : BCC .GBR
		CMP #$00A0 : BCC .BGR
		CMP #$00C8 : BCC .BRG

	.RBG	LDA !color1 : STA $00
		LDA !color2 : STA $04
		LDA !color3 : STA $02
		RTS

	.RGB	LDA !color1 : STA $00
		LDA !color2 : STA $02
		LDA !color3 : STA $04
		RTS

	.GRB	LDA !color1 : STA $02
		LDA !color2 : STA $00
		LDA !color3 : STA $04
		RTS

	.GBR	LDA !color1 : STA $02
		LDA !color2 : STA $04
		LDA !color3 : STA $00
		RTS

	.BGR	LDA !color1 : STA $04
		LDA !color2 : STA $02
		LDA !color3 : STA $00
		RTS

	.BRG	LDA !color1 : STA $04
		LDA !color2 : STA $00
		LDA !color3 : STA $02
		RTS


MixRGB:
		PHP
		REP #$30
		AND #$00FF
		STA !colormix
		LDA #$0020
		SEC : SBC !colormix
		STA !colormix+2
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		TYA
		ASL A
		DEY
		STY !colorloop

; during the process, only X is required for indexing

		TXA
		ASL A
		TAX

		TSC
		AND #$FF00
		CMP #$3700 : BEQ .Go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTS

	.SA1
		PEA.w ..return-1
		PHP
		REP #$30
		LDX $00
		LDY $02
		BRA .Go
		..return
		RTL

	.Go

		SEP #$20			;\
		STZ $2250			; | prepare multiplication
		REP #$20			;/

	-	CPX #$01FE			;\ cap overflow
		BCC $03 : LDX #$01FE		;/

		LDA $6703,x			;\
		AND #$001F			; |
		STA $2251			; | R
		LDA !colormix : STA $2253	; |
		BRA $00 : NOP			; |
		LDA $2306 : STA $00		;/
		LDA $6703,x			;\
		LSR #5				; |
		AND #$001F			; |
		STA $2251			; | G
		LDA !colormix : STA $2253	; |
		BRA $00 : NOP			; |
		LDA $2306 : STA $02		;/
		LDA $6703,x			;\
		XBA				; |
		LSR #2				; |
		AND #$001F			; | B
		STA $2251			; |
		LDA !colormix : STA $2253	; |
		BRA $00 : NOP			; |
		LDA $2306 : STA $04		;/

		LDA !PaletteHSL+$900,x		;\
		AND #$001F			; |
		STA $2251			; |
		LDA !colormix+2 : STA $2253	; |
		BRA $00 : NOP			; | mix R
		LDA $2306			; |
		CLC : ADC $00			; |
		LSR #5				; |
		STA $00				;/
		LDA !PaletteHSL+$900,x		;\
		LSR #5				; |
		AND #$001F			; |
		STA $2251			; |
		LDA !colormix+2 : STA $2253	; | mix G
		BRA $00 : NOP			; |
		LDA $2306			; |
		CLC : ADC $02			; |
		LSR #5				; |
		STA $02				;/
		LDA !PaletteHSL+$900,x		;\
		XBA				; |
		LSR #2				; |
		AND #$001F			; |
		STA $2251			; | mix B
		LDA !colormix+2 : STA $2253	; |
		BRA $00 : NOP			; |
		LDA $2306			; |
		CLC : ADC $04			;/

		AND #$03E0			;\
		ORA $02				; |
		ASL #5				; | assemble and store mixed color
		ORA $00				; |
		STA !PaletteHSL+$900,x		;/


		INX #2
		DEC !colorloop : BMI $03 : JMP -


		PLP
		RTS


MixHSL:
		PHP
		REP #$30
		AND #$00FF
		STA !colormix
		LDA #$00FF
		SEC : SBC !colormix
		STA !colormix+2
		CPY #$0000 : BEQ .Full
		CPY #$0100 : BCC .NotFull
	.Full	LDY #$0100
	.NotFull
		TYA
		ASL A
		DEY
		STY !colorloop

; during the process, only X is required for indexing

		TXA
		STA $00
		ASL A
		CLC : ADC $00
		TAX

		TSC
		AND #$FF00
		CMP #$3700 : BEQ .Go
		STX $00
		STY $02
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		RTS

	.SA1
		PEA.w ..return-1
		PHP
		REP #$30
		LDX $00
		LDY $02
		BRA .Go
		..return
		RTL

	.Go

		SEP #$20			;\
		STZ $2250			; | prepare multiplication
		REP #$20			;/

	.Loop	CPX #$02FD			;\ cap overflow
		BCC $03 : LDX #$02FD		;/


; 00 -> 20	+20 / m
; 00 -> 68	-10 / m
; 70 -> 68	-8 / m
;
;
;
; $00	hue 1
; $02	hue 2
; $08	hue 1 - hue 2
; $0A	hue 2 - hue 1
; $0E	|hue 2 - hue 1|

		LDA !PaletteHSL,x
		AND #$00FF
		STA $0A
		LDA !PaletteHSL+$300,x
		AND #$00FF
		SEC : SBC $0A
	STA $0C
	BMI .Calc
	CMP #$0078 : BCC .Calc

	.CClock	LDA #$00F0
		SEC : SBC $0C
		EOR #$FFFF : INC A

		BRA .Calc

	.Calc	STA $2251
		LDA !colormix+2 : STA $2253	; amount to add is based on 32-m
		NOP : BRA $00
		LDA $2306 : BPL +
		EOR #$FFFF : INC A
		XBA : AND #$00FF
		EOR #$FFFF : INC A
		BRA ++
	+	XBA : AND #$00FF
	++	CLC : ADC $0A
		BPL $04 : CLC : ADC #$00F0
	-	CMP #$00F0 : BCC +
		SBC #$00F0 : BRA -
	+	STA $0A


		LDA !PaletteHSL+1,x			;\
		AND #$00FF				; |
		STA $2251				; |
		LDA !colormix : STA $2253		; |
		BRA $00 : NOP				; |
		LDA $2306 : STA $0C			; |
		LDA !PaletteHSL+$301,x			; |
		AND #$00FF				; | calculate S as m*S1 + (32-m)*S2
		STA $2251				; |
		LDA !colormix+2 : STA $2253		; |
		BRA $00 : NOP				; |
		LDA $2306				; |
		CLC : ADC $0C				; |
		XBA : AND #$00FF			; |
		STA $0C					;/
		LDA !PaletteHSL+2,x			;\
		AND #$00FF				; |
		STA $2251				; |
		LDA !colormix : STA $2253		; |
		BRA $00 : NOP				; |
		LDA $2306 : STA $0E			; |
		LDA !PaletteHSL+$302,x			; |
		AND #$00FF				; | calculate L as m*L1 + (32-m)*L2
		STA $2251				; |
		LDA !colormix+2 : STA $2253		; |
		BRA $00 : NOP				; |
		LDA $2306				; |
		CLC : ADC $0E				; |
		XBA : AND #$00FF			; |
		STA $0E					;/

		SEP #$20				;\
		LDA $0A : STA !PaletteHSL+$600,x	; |
		LDA $0C : STA !PaletteHSL+$601,x	; | assemble HSL
		LDA $0E : STA !PaletteHSL+$602,x	; |
		REP #$20				;/

		INX #3
		DEC !colorloop : BMI $03 : JMP .Loop


		PLP
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
		LDA #$00 : STA !DizzyEffect
		RTL

		.Y
		LDY !GameMode
		CPY #$11
		BEQ ..Nope
		LDY $6D9F : STY $420C
		RTL
	..Nope	LDY #$00 : STY $420C
		LDA #$00 : STA !DizzyEffect
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

		STZ !RAMcode_offset
		STZ !RAMcode_offset+1
		STZ !RAMcode_flag
		STZ !RAMcode_flag+1

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
		REP #$20			;\
		STZ !P1Coins			; | Players lose all coins upon death
		STZ !P2Coins			; |
		SEP #$20			;/

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


; don't restore the other ones, they set up the camera and Mario's position and stuff

	pushpc
	org $00F70D
	;	LDA #$00C0			;\ restore SMW code from LM3
	;	JSR $F7F4			;/

	org $00F77B
		SEC : SBC $742C,y		; restore SMW code from LM3


	org $00F79D
		; this is my hijack :)

	org $00F871
	;	LDY #$04			;\ restore SMW code from LM3
	;	BRA $0C				;/

	org $05DA17
	;	SEP #$30			;\ restore SMW code from LM3
	;	LDA !Translevel			;/
	pullpc

SCROLL_OPTIONS:


; this routine is called once at level load (game mode == 0x11) to set initial screen coordinates
; if I just rewrite those I can decide where the camera ends up
; when this routine is called in this way, !Level is already set properly so I do know where I'm going


; culprit: $80C426 (probably a LM routine)

; LM table:
; $832C		00
; $832A		01
; $8329		02
; $8325		03
; $8328		04
; $8327		05
; $8326		06
; $8324		07

; $833E		00
; $8338		01
; $8337		02
; $8333		03
; $8336		04
; $8335		05
; $8334		06
; $8332		07

; $FFFF



		LDX !GameMode
		CPX #$11 : BNE .NoInit

		; ladies and gentlemen. we got em.

		PHP
		SEP #$20
		LDX !Level
		LDA.l .LevelTable,x
		LDX !Level+1
		AND.l .LevelSwitch,x
		BEQ .NormalCoords
		CMP #$10 : BCC +
		LSR #4
	+	DEC A
		ASL A
		CMP.b #.CoordsEnd-.CoordsPtr
		BCS .NormalCoords
		TAX
		JSR (.CoordsPtr,x)

	.NormalCoords
		PLP
		JML $00F7C2

	.NoInit	CPX #$14 : BNE .NoBox

		.Expand
		LDY #$01
	-	LDX !CameraForceTimer,y : BEQ .NextForce
		DEX
		TXA
		SEP #$20
		STA !CameraForceTimer,y
		REP #$20
		LDX !CameraForceDir,y
		PHY
		LDY #$00
		TXA
		AND #$0002
		BNE $02 : LDY #$02
		STY $55
		PLY
		LDA !CameraBackupX
		CLC : ADC.l .ForceTableX,x
		AND #$FFF8
		STA $1A
		LDA !CameraBackupY
		CLC : ADC.l .ForceTableY,x
		AND #$FFF8
		STA $1C
		JMP .CameraBackup
.NextForce	DEY : BPL -


		BIT !CameraBoxU : BMI .NoBox
		LDA.w #.SA1 : STA $3180
		LDA.w #.SA1>>8 : STA $3181
		PHP
		SEP #$20
		JSR $1E80
		PLP
		JMP .CameraBackup

		.NoBox
		LDX !SmoothCamera : BEQ .CameraBackup
		PHB : PHK : PLB
		STZ $00
		LDX $5D
		DEX
		STX $01
		LDA !LevelHeight
		SEC : SBC #$00E0
		STA $02
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		SEC : SBC #$0080
		BPL $03 : LDA #$0000
		CMP $00
		BCC $02 : LDA $00
		STA $1A
		LDY !EnableVScroll : BEQ +
		LDA !P2YPosLo-$80
		CLC : ADC !P2YPosLo
		BPL $03 : LDA #$0000
		LSR A
		SEC : SBC #$0070
		BPL $03 : LDA #$0000
		CMP $02
		BCC $02 : LDA $02
		STA $1C
	+	LDX #$02
	-	LDA !CameraBackupX,x
		CMP $1A,x : BEQ +
		LDY #$00
		BCC $02 : LDY #$02
		CLC : ADC.w .SmoothSpeed,y
		STA $00
		LDA !CameraBackupX,x
		SEC : SBC $1A,x
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0006 : BCC +
		LDA $00 : STA $1A,x
	+	DEX #2 : BPL -
		PLB



		.CameraBackup
		LDA !CameraBackupX : STA !BG1ZipRowX	;\
		LDA !CameraBackupY : STA !BG1ZipRowY	; | coordinates from previous frame
		LDA $1E : STA !BG2ZipRowX		; | (used for updating tilemap)
		LDA $20 : STA !BG2ZipRowY		;/
		LDA $1A : STA !CameraBackupX		;\ backup for next frame
		LDA $1C : STA !CameraBackupY		;/

		JSL .Main

		LDA.l !HDMAptr+0 : BEQ .Return	;\
		STA $00				; |
		LDA.l !HDMAptr+1		; |
		STA $01				; | Execute HDMA code
		PEA $0000 : PLB			; |
		PEA $F7C2-1			; |
		JML [$3000]			;/

	.Return	JML $00F7C2


	.ForceTableY
		dw $0000,$0000
	.ForceTableX
		dw $0008,$FFF8,$0000,$0000

	.SmoothSpeed
		dw $0006,$FFFA

	.CameraOffset
		dw $0100,$00E0
	.CameraCenter
		dw $0080,$0070


		.SA1
		PHB : PHK : PLB
		PHP
		SEP #$10
		REP #$20

		JSR .Aim
		JSR .Forbiddance
		JSR .Process

		LDX #$02
	-	LDY #$00
		LDA $1A,x
		CMP !CameraBackupX,x
		BEQ +
		BCC $02 : LDY #$02
		STY $55
	+	DEX #2 : BPL -



		LDA !CameraBoxL
		SEC : SBC #$0020
		STA $04
		LDA !CameraBoxR
		CLC : ADC #$0110
		STA $06
		LDA !CameraBoxU
		SEC : SBC #$0020
		STA $08
		LDA !CameraBoxD
		CLC : ADC #$00F0
		STA $0A


		LDX #$0F
	-	LDA $3470,x
		ORA #$0004
		STA $3470,x
		LDY !CameraForceTimer : BNE .Freeze
		LDY $3220,x : STY $00
		LDY $3250,x : STY $01
		LDY $3210,x : STY $02
		LDY $3240,x : STY $03
		LDA $00
		SEC : SBC $04
		BPL .CheckR
		CMP #$FF00 : BCC .Delete
		CMP #$FFE0 : BCC .Freeze

	.Delete	LDA $3230,x
		AND #$FF00
		STA $3230,x
		LDY $33F0,x
		CPY #$FF : BEQ .Next
		PHX
		TYX
		LDA $418A00,x
		AND #$00FF
		CMP #$00EE : BEQ +
		LDA $418A00,x
		AND #$FF00
		STA $418A00,x
	+	PLX
		BRA .Next

	.CheckR	LDA $00
		SEC : SBC $06
		BMI .GoodX
		CMP #$0020 : BCC .Delete
		CMP #$0100 : BCS .Delete

	.Freeze	LDA !SpriteStasis,x
		ORA #$0002
		STA !SpriteStasis,x
		BRA .Next

	.GoodX	LDA $02
		CMP $08 : BMI .Freeze
		CMP $0A : BPL .Freeze
	.Next	DEX : BMI $03 : JMP -

		PLP
		PLB
		RTL


		.Aim
		LDA !P2XPosLo-$80
		CLC : ADC !P2XPosLo
		LSR A
		SEC : SBC #$0080
		CMP #$4000
		BCC $03 : LDA #$0000
		STA $1A
		LDA !P2YPosLo-$80
		CLC : ADC !P2YPosLo
		LSR A
		SEC : SBC #$0070
		CMP #$4000
		BCC $03 : LDA #$0000
		STA $1C
		RTS

		.Process
		LDX #$02
	-	LDA $1A,x
		CMP !CameraBoxL,x : BCS +
		LDA !CameraBoxL,x : STA $1A,x
		BRA ++
	+	CMP !CameraBoxR,x : BCC ++ : BEQ ++
		LDA !CameraBoxR,x : STA $1A,x
	++	LDA !CameraBackupX,x			; apply smooth camera
		CMP $1A,x : BEQ +
		LDY #$00
		BCC $02 : LDY #$02
		CLC : ADC.w .SmoothSpeed,y
		STA $00
		LDA !CameraBackupX,x
		SEC : SBC $1A,x
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0006 : BCC +
		LDA $00 : STA $1A,x
	;	TXA
	;	EOR #$0002
	;	TAX
	;	LDA !CameraBackupX,x : STA $1A,x
	;	BRA .Absolute
	+	DEX #2 : BPL -
	..R	RTS


		.Absolute
		LDA $1A,x
		CMP !CameraBoxL,x : BCS +
		LDA !CameraBoxL,x : STA $1A,x
		RTS
	+	CMP !CameraBoxR,x : BCC + : BEQ +
		LDA !CameraBoxR,x : STA $1A,x
	+	RTS


		.Forbiddance
		LDX !CameraForbiddance
		CPX #$FF : BEQ .Process_R
		LDA !CameraForbiddance
		AND #$003F
		TAX

		LDA !CameraBoxU : STA $0A	; forbiddance top border start
		LDA !CameraBoxL
	-	CPX #$00 : BEQ +
		DEX
		CLC : ADC #$0100
		STA $08
		CMP !CameraBoxR : BCC - : BEQ -
		LDA $0A
		CLC : ADC #$00E0
		STA $0A				; forbiddance top border
		LDA !CameraBoxL
		BRA -

	+	STA $08				; forbiddance left border
		LDA !CameraForbiddance
		ASL #2
		AND #$1F00
		CLC : ADC $08
		CLC : ADC #$0100
		STA $0C				; forbiddance right border
		LDA !CameraForbiddance
		AND #$F800
		LSR #3
		PHA
		LSR #3
		STA $0E
		PLA
		SEC : SBC $0E
		CLC : ADC $0A
		CLC : ADC #$00E0
		STA $0E				; forbiddance bottom border


		LDA $1A
		CMP $0C : BCS .NoForbid
		ADC #$0100
		CMP $08 : BCC .NoForbid
		LDA $1C
		CMP $0E : BCS .NoForbid
		ADC #$00E0
		CMP $0A : BCC .NoForbid


		LDX #$02
	-	LDA $08,x
		CLC : ADC $0C,x
		LSR A
		STA !BigRAM+0
		LDA $1A,x
		CLC : ADC .CameraCenter,x
		CMP !BigRAM+0
		BCS ..RD
	..LU	LDA $08,x : STA $00,x
		SEC : SBC .CameraOffset,x
		BRA +
	..RD	LDA $0C,x : STA $00,x
	+	SEC : SBC $1A,x
		BPL $04 : EOR #$FFFF : INC A
		STA $04,x
		DEX #2 : BPL -


		LDX #$00
		LDA $04
		CMP $06
		BCC $02 : LDX #$02
		LDA $00,x
		CMP !CameraBoxL,x : BNE +
		TXA
		EOR #$0002
		TAX
		LDA $00,x
	+	CMP $08,x : BNE +
		SEC : SBC .CameraOffset,x
		BPL $03 : LDA #$0000
	+	STA $1A,x

		.NoForbid
		RTS



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
		dw .DoubleHorz			; B - 200%

.DoubleHorz	ASL A
		BRA .ConstantHorz
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
		dw .DoubleVert			; B - 200%

.DoubleVert	ASL A
		BRA .ConstantVert
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


; lo nybble is used by levels 0x000-0x0FF, hi nybble is used by levels 0x100-0x1FF
; 0 means it's unused, so just use normal coords
; any other number is treated as an index to the coordinate routine pointer table

.LevelTable	db $00,$00,$00,$00,$00,$00,$00,$00		; 00-07
		db $00,$00,$00,$00,$00,$00,$00,$00		; 08-0F
		db $00,$00,$00,$00,$01,$00,$00,$00		; 10-17
		db $00,$00,$00,$00,$00,$00,$00,$00		; 18-1F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 20-27
		db $00,$00,$00,$00,$00,$00,$00,$00		; 28-2F
		db $00,$00,$00,$00,$01,$00,$00,$00		; 30-37
		db $00,$00,$00,$00,$00,$00,$00,$00		; 38-3F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 40-47
		db $00,$00,$00,$00,$00,$00,$00,$00		; 48-4F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 50-57
		db $00,$00,$00,$00,$00,$00,$00,$00		; 58-5F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 60-67
		db $00,$00,$00,$00,$00,$00,$00,$00		; 68-6F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 70-77
		db $00,$00,$00,$00,$00,$00,$00,$00		; 78-7F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 80-87
		db $00,$00,$00,$00,$00,$00,$00,$00		; 88-8F
		db $00,$00,$00,$00,$00,$00,$00,$00		; 90-97
		db $00,$00,$00,$00,$00,$00,$00,$00		; 98-9F
		db $00,$00,$00,$00,$00,$00,$00,$00		; A0-A7
		db $00,$00,$00,$00,$00,$00,$00,$00		; A8-AF
		db $00,$00,$00,$00,$00,$00,$00,$00		; B0-B7
		db $00,$00,$00,$00,$00,$00,$00,$00		; B8-BF
		db $00,$00,$00,$00,$00,$00,$00,$00		; C0-C7
		db $00,$00,$00,$00,$00,$00,$00,$00		; C8-CF
		db $00,$00,$00,$00,$00,$00,$00,$00		; D0-D7
		db $00,$00,$00,$00,$00,$00,$00,$00		; D8-DF
		db $00,$00,$00,$00,$00,$00,$00,$00		; E0-E7
		db $00,$00,$00,$00,$00,$00,$00,$00		; E8-EF
		db $00,$00,$00,$00,$00,$00,$00,$00		; F0-F7
		db $00,$00,$00,$00,$00,$00,$00,$00		; F8-FF


.LevelSwitch	db $0F,$F0


	; this is entered with all regs 8-bit
	; PLP is used at return, so no need to bother keeping track of P


	.CoordsPtr
	dw .Coords1
	.CoordsEnd


	.Coords1
		STZ $1A
		REP #$20
		LDX #$00
		LDA $1C
	-	CMP #$00E0 : BCC ..Yes
		INX #2
		SBC #$00E0
		BRA -

	..Yes	CMP #$0070
		BCC $02 : INX #2
		LDA.l ..Y,x : STA $1C
		LDX #$02
	-	LDA $1A,x
		STA !CameraBackupX,x
		STA !CameraBoxL,x
		STA $7462,x
		INC A
		STA !CameraBoxR,x
		DEX #2
		BPL -
		RTS

	..Y	dw $0000,$00E0,$01C0,$02A0
		dw $0380,$0460,$0540,$0620


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
.Contact	LDA !Ex_Num,x
		CMP #$04+!ExtendedOffset : BNE .NoHammer
		LDA !Ex_Data3,x
		LSR A : BCS .Return
		LDA !MarioSpinJump : BNE .SpinHammer
		BRA .NoHammer

.SpinHammer	;LDA $7715,x
		;SEC : SBC $96
		;LDA $7729,x
		;SBC $97
		;BCC .NoHammer
		JSL !BouncePlayer
		JSL !ContactGFX
		LDA #$02 : STA !SPC1
		LDA #$40 : STA !Ex_YSpeed,x
		STZ !Ex_XSpeed,x
		LDA !Ex_Data3,x			; mark hammer as owned by player
		ORA #$01
		STA !Ex_Data3,x
.Return		JML $02A468			; > Return
.NoHammer	JML $02A40E			; > Non-hammer code


	; GenerateHammer starts at $02DAC3.

		.SPAWN
		LDA #$04+!ExtendedOffset : STA !Ex_Num,y
		LDA #$00 : STA !Ex_Data3,y
		JML $02DAC8



;============;
;ENTRANCE FIX;
;============;
EntranceFix:
		STA $1C				;\ camera backup
		STA !CameraBackupY		;/
		RTL


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
; there's another routine at $00C227 that ends at $00C299, can probably wire that up too (nope (yep))

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


	; 2000 = layer 1	->	!BG1Address
	; 3000 = layer 2	->	!BG2Address
	; 5000 = layer 3 (not remapped)

		STA $7F837B				; > Overwritten code
		LDA $1C
		STA $04
		LDA $20
		STA $06
		LDY $0000
		PHB
		PEA $7F7F
		PLB : PLB

		LDA.l !VRAMbase+!TileUpdateTable : TAX
	.Loop	LDA $837D,y
		XBA
		CMP #$8000 : BCC .Go
		PLB
		RTL


	.Go	CMP #$5000 : BCS .BG3
		JSR Transform						; convert address
	.BG3	STA $0E

		LDA #$FFFF : STA $837D,y

		LDA #$0001 : STA $0C					; address increment for horizontal
		LDA $837F,y
		AND #$0080 : BEQ +
		LDA #$0020 : STA $0C					; address increment for vertical
		+

		LDA $837F,y
		XBA
		CMP #$C000 : BCS +
		CMP #$8000 : BCS ++
		CMP #$4000 : BCS +
	++	INC A
	+	AND #$3FFF
		CMP #$0008
		BCC $03 : LDA #$0008
		STA $02							; number of bytes to copy from stripe
		ASL A							;\
		CLC : ADC.l !VRAMbase+!TileUpdateTable+$00		; | update header to tile update table
		STA.l !VRAMbase+!TileUpdateTable+$00			;/

		TYA
		CLC : ADC #$8381
		STA $00

		PHY
		LDY #$0000
	-	LDA $0E : STA.l !VRAMbase+!TileUpdateTable+$02,x
		CLC : ADC $0C
		STA $0E
		LDA ($00),y : STA.l !VRAMbase+!TileUpdateTable+$04,x
		INX #4
		INY #2
		CPY $02 : BCC -
		PLY

		LDA $837F,y
		AND #$0040 : BEQ +
		LDA #$0006
		BRA ++
	+	LDA $02
		CLC : ADC #$0004
	++	STA $02


	.Next	TYA
		CLC : ADC $02
		TAY
		JMP .Loop





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
		PLA : JMP TileOptimize_Next		; out of bounds: NEXT!!

	.Valid	LDA $00					;\
		AND #$F7FF				; | final transformation for valid BG1/BG2
		CMP #$3000 : BCC ..BG1			;/
	..BG2	AND #$07FF				;\ remap
		ORA.l !BG2Address			;/
		RTS

	..BG1	AND #$07FF				;\ remap
		ORA.l !BG1Address			;/
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


;==============;
;MAP16 EXPANDER;
;==============;
; this code allows for some massive objects that can overwrite standard map16 codes
; does not apply to PCE characters unless CORE/LAYER_INTERACTION is updated

MAP16_EXPAND:
		PHA
		LDA !3DWater : BEQ .Return
		LDA !ProcessingSprites
		REP #$20
		BNE .Sprites
		LDA $98 : BRA .Shared
.Sprites	LDA $0C
.Shared		CMP !Level+2
		SEP #$20
		BCC .Return
		LDA !IceLevel : BNE .Ice
.Return		PLA
		TAY : BNE .00F577
		LDY $7693
.00F54B		JML $00F54B
.00F577		JML $00F577


.Ice		PLA
		LDA #$30 : STA $7693
		LDY #$01
		RTL







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
		LDA #$00
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
	db $07		; org: $06

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

org $00F545
	JML MAP16_EXPAND		;\ org: TAY : BNE $2F ($00F577) : LDY $7693
	NOP #2				;/


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

org $0296C0
;	JML SmokeFix			;\ Main routine for smoke sprites
;	NOP				;/ Source: LDA $77C0,x : BEQ $12 ($0296D7)

	LDA !Ex_Num,x : BEQ $12


org $02A326
;	JSL HAMMER_GFX			; Source: TAX : LDA.w $A2DF,x
	TAX : LDA.w $A2DF,x

org $02A3F6
	BRA $06 : NOP #6		; source: LDA !Ex_Data3,x : EOR $1779,x : BNE Return

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

org $05D80B
	JSL EntranceFix			; org: STA $1C : LDA $00 (need to update camera backup here)

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


