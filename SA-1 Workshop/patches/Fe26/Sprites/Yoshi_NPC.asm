; --Defines--

	!CastleTable	= $00C9A7		; Location of table that determines what levels are castles.
	!LevelTable	= $1EA2			; Location of RAM rable that holds level data.
	!YoshiCode	= $138020		; This has to be adjusted to fit the patch!

	!MaxYoshiCoins	= !UNDEFINED		; How many Yoshi Coins there are in the game.
	!Castle8Beaten	= !UNDEFINED		; The address that determines weither Castle #8 is beaten or not.

	!UNDEFINED	= #$00			; Error suppression.



	; Note to self: make sure to add a 1px offset to the survivor's second-to-last frame since I moved it in the file



print "INIT ",pc

INITCODE:

		PHX				;\
		STZ $00				; |
		LDX #$06			; |
.Loop		LDA $00C9A7,x			; |
		TAY				; |
		LDA $1EA2,y			; | Calculate number of castles beaten
		BPL +				; |
		INC $00				; |
	+	DEX				; |
		BPL .Loop			; |
		PLX				;/
		LDA $00				;\
		CLC				; | Message = Number of castles beaten + 09
		ADC #$09			; | Messages start at slot 01A-1
		STA $C2,x			;/
		RTL

print "MAIN ",pc

		PHB				;\
		PHK				; | Start of bank wrapper
		PLB				;/

		JSR SUB_HORZ_POS		;\
		TYA				; | Face player 1
		STA $157C,x			;/

		LDA $14
		AND #$01
		BEQ +
		LDA $1570,x
		BEQ ++
		DEC $1570,x			; Decrement animation timer
		BRA +
	++	STZ $1602,x			; Reset animation
	+

;==================;
;PLAYER INTERACTION;
;==================;
INTERACTION:

		LDA $1602,x			; Load animation pointer index
		BEQ .Process			; Branch too long
		JMP .Skip			; Only allow talking during ANIM_IDLE
.Process	STZ $00				; Reset talk flag

		LDA $16				;\
		AND #$08			; |
		BEQ .Player2			; | Only check player 1 Xpos if he's on the ground and pressing up
		LDA $77				; |
		AND #$04			; |
		BEQ .Player2			;/

.Player1	LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20			; A 16 bit
		SEC
		SBC $94
		BPL .P1Pos			;\ Only use positive values
		EOR #$FFFF			;/
.P1Pos		CMP #$0020			; Allow talking from up to 2 tiles away
		BPL .Player2
		INC $00				; Set talk flag

.Player2	SEP #$20			; A 8 bit
		LDA $00				;\ Don't check the same thing twice
		BNE +				;/
		LDY $60				; Y = player 2 index

		LDA $0DA7			;\
		AND #$08			; |
		BEQ +				; | Only check player 2 Xpos if he's on the ground and pressing up
		LDA $1588,y			; |
		AND #$04			; |
		BEQ +				;/

		LDA $00E4,y			;\
		STA $01				; | Store player 2 16 bit Xpos to scratch RAM for comparing
		LDA $14E0,y			; |
		STA $02				;/
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20			; A 16 bit
		SEC
		SBC $01				; Subtract player 2 Xpos
		BPL .P2Pos			;\ Only use positive values
		EOR #$FFFF			;/
.P2Pos		CMP #$0020			; Allow talking from up to 2 tiles away
		BPL +
		INC $00				; Set talk flag

	+	SEP #$20			; A 8 bit
		LDA $00
		BEQ .Skip
		LDA $C2,x			; Load message counter
		STA $1426			; Store to message box trigger
		LDA $0DBE
		CMP #$04
		BCS +
		LDA #$01			;\
		STA $7FA517			; | Display an extra message
		LDA #$03			; |
		STA $7FA507			;/

	+	LDA #$01			;\ Animaiton
		STA $1602,x			;/
		LDA #$10			;\ Animation timer
		STA $1570,x			;/

.Skip

;================;
;GRAPHICS ROUTINE;
;================;
GRAPHICS:

; -Info Stuffs-
;
; $00   = Xpos within screen
; $01   = Ypos within screen
; ($02) = Tilemap location within bank
; $04   = OAM index
; $05   = First byte of tilemap (number of bytes to draw)
; $06   = $157C,x (horizontal direction)
; $07   = Stored to when flipping Xdisp and YXPPCCCT

		JSR GET_DRAW_INFO
		STY $04				; Store OAM index to scratch RAM

		PHX				; Preserve sprite index
		LDA $157C,x			;\ Store direction to scratch RAM
		STA $06				;/
		LDA $1570,x			;\
		AND #$FE			; | Preserve animation timer without lowest bit
		PHA				;/
		LDA $1602,x
		ASL A
		TAX
		REP #$20			; A 16 bit
		LDA ANIMATION_PTR,x		; Load animation table location
		STA $02				; Store to scratch RAM
		PLY				; Y = animation timer (index to animation table)
		LDA ($02),y			; Load tilemap location
		STA $02				; Store to scratch RAM
		SEP #$20

		LDY #$00			; Set up tilemap index
		LDA ($02),y			; Load first byte of tilemap (tile number byte)
		STA $05				; Store to scratch RAM
		PHA				; Push on stack

		LDX $04				; X = OAM index
		INY				; Increment tilemap index

.Loop		LDA ($02),y			;\
		STA $07				; |
		LDA $06				; | Set Xpos
		BNE +				; |
		LDA $07				; |
		EOR #$FF			;  > Invert Xdisp if facing right
		STA $07				; |
	+	LDA $07				; |
		CLC				; |
		ADC $00				; |
		STA $0300,x			;/

		INY				; Increment tilemap index
		LDA ($02),y			;\
		CLC				; | Set Ypos
		ADC $01				; |
		STA $0301,x			;/

		INY				; Increment tilemap index
		LDA ($02),y			;\ Set tile
		STA $0302,x			;/

		INY				; Increment tilemap index
		LDA ($02),y			;\
		STA $07				; |
		LDA $06				; |
		BNE +				; | Set YXPPCCCT
		LDA $07				; |
		EOR #$40			;  > Xflip if facing right
		STA $07				; |
	+	LDA $07				; |
		STA $0303,x			;/

		INY				; Increment tilemap index
		INX				;\
		INX				; | Add 4 to OAM index
		INX				; |
		INX				;/
		DEC $05				; Decrement loop count
		BNE .Loop			; Loop if there are tiles left to draw

		LDY #$02			; Size of tiles to draw
		PLA				; Restore number of tiles to draw
		DEC A
		PLX				; Restore sprite index
		JSL $01B7B3			; Draw tiles

		PLB				; End of bank wrapper
		RTL

; This pointer table determines what animaiton has what number.
; There can be a maximum of 128 animations, as it is indexed by a 7 bit number.

ANIMATION_PTR:	dw ANIM_IDLE
		dw ANIM_JUMP

;================;
;ANIMATION TABLES;
;================;
; Note that animation tables are read backwards.
; The last tilemap in the table is the first frame, the second to last table is the second frame, etc.

ANIM_IDLE:	dw IDLE00

ANIM_JUMP:	dw JUMP00
		dw JUMP01
		dw JUMP02
		dw JUMP03
		dw JUMP03
		dw JUMP02
		dw JUMP01
		dw JUMP00
		dw IDLE00

;========;
;TILEMAPS;
;========;

IDLE00:		db $04				; Number of tiles
		db $F8,$F0,$00,$2B
		db $F8,$00,$20,$2B
		db $00,$F0,$01,$2B
		db $00,$00,$21,$2B

JUMP00:		db $04				; Number of tiles
		db $F8,$F0,$00,$2B
		db $F8,$00,$20,$2B
		db $00,$F0,$01,$2B
		db $00,$00,$21,$2B
JUMP01:		db $04				; Number of tiles
		db $F8,$EF,$03,$2B
		db $F8,$FF,$23,$2B
		db $00,$EF,$04,$2B
		db $00,$FF,$24,$2B
JUMP02:		db $04				; Number of tiles
		db $F8,$ED,$06,$2B
		db $F8,$FD,$26,$2B
		db $00,$ED,$07,$2B
		db $00,$FD,$27,$2B
JUMP03:		db $04				; Number of tiles
		db $F8,$EC,$06,$2B
		db $F8,$FC,$26,$2B
		db $00,$EC,$07,$2B
		db $00,$FC,$27,$2B

;============;
;SUB_HORZ_POS;
;============;
SUB_HORZ_POS:

		LDY #$00
		LDA $94
		SEC : SBC $E4,x
		LDA $95
		SBC $14E0,x
		BPL .Return
		INY
.Return		RTS


;=============;
;GET_DRAW_INFO;
;=============;
SPR_T1: db $0C,$1C
SPR_T2: db $01,$02

GET_DRAW_INFO:

		STZ $186C,x
		STZ $15A0,x
		LDA $E4,x
		CMP $1A
		LDA $14E0,x
		SBC $1B
		BEQ ON_SCREEN_X
		INC $15A0,x

ON_SCREEN_X:

		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC
		SBC $1A
		CLC
		ADC #$0040
		CMP #$0180
		SEP #$20
		ROL A
		AND #$01
		STA $15C4,x
		BNE INVALID
		LDY #$00
		LDA $1662,x
		AND #$20
		BEQ ON_SCREEN_LOOP
		INY

ON_SCREEN_LOOP:

		LDA $D8,x
		CLC
		ADC SPR_T1,y
		PHP
		CMP $1C
		ROL $00
		PLP
		LDA $14D4,x
		ADC #$00
		LSR $00
		SBC $1D
		BEQ ON_SCREEN_Y
		LDA $186C,x
		ORA SPR_T2,y
		STA $186C,x

ON_SCREEN_Y:

		DEY
		BPL ON_SCREEN_LOOP
		LDY $15EA,x
		LDA $E4,x
		SEC
		SBC $1A
		STA $00
		LDA $D8,x
		SEC
		SBC $1C
		STA $01
		RTS

INVALID:

		PLA : PLA			; Pull RTS address
		PLB : RTL			; End sprite routine


;==============;
;SUB_OFF_SCREEN;
;==============;
START_SUB:	STZ $03
		LDA $15A0,x
		ORA $186C,x
		BEQ RETURN_35
		LDA $5B
		AND #$01
		BNE VERTICAL_LEVEL
		LDA $D8,x
		CLC
		ADC #$50
		LDA $14D4,x
		ADC #$00
		CMP #$02
		BPL ERASE_SPRITE
		LDA $167A,x
		AND #$04
		BNE RETURN_35
		LDA $13
		AND #$01
		ORA $03
		STA $01
		TAY
  		LDA $1A
		CLC
		ADC SPR_T14,y
		ROL $00
		CMP $E4,x
		PHP
		LDA $1B
		LSR $00
		ADC SPR_T15,y
		PLP
		SBC $14E0,x
		STA $00
		LSR $01
		BCC SPR_L31
		EOR #$80
		STA $00
SPR_L31:	LDA $00
		BPL RETURN_35
ERASE_SPRITE:	LDA $14C8,x
		CMP #$08
		BCC KILL_SPRITE
		LDY $161A,x
		CPY #$FF
		BEQ KILL_SPRITE
		LDA #$00
		STA $1938,y
KILL_SPRITE:	LDA #$00
		STA $14C8,x
		STA $7FAB10,x
RETURN_35:	RTS

VERTICAL_LEVEL:	LDA $167A,x
		AND #$04
		BNE RETURN_35
		LDA $13
		LSR A
		BCS RETURN_35
		LDA $E4,x
		CMP #$00
		LDA $14E0,x
		SBC #$00
		CMP #$02
		BCS ERASE_SPRITE
		LDA $13
		LSR A
		AND #$01
		STA $01
		TAY
		LDA $1C
		CLC
		ADC SPR_T12,y
		ROL $00
		CMP $D8,x
		PHP
		LDA $001D
		LSR $00
		ADC SPR_T13,y
		PLP
		SBC $14D4,x
		STA $00
		LDY $01
		BEQ SPR_L38
		EOR #$80
  		STA $00
SPR_L38:	LDA $00
		BPL RETURN_35
		BMI ERASE_SPRITE


SPR_T12:	db $40,$B0
SPR_T13:	db $01,$FF
SPR_T14:	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
		db $30,$C0,$A0,$80,$A0,$40,$60,$B0
SPR_T15:	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
		db $01,$FF,$01,$FF,$01,$00,$01,$FF