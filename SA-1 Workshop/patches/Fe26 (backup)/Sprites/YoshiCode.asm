;==========;
;YOSHI CODE;
;==========;
YOSHI_CODE:

		LDA $14				;\
		ROR A				; |
		BCC .TimerZero			; | Decrement animation timer every other frame
		LDA $1570,x			; |
		BEQ .TimerZero			; |
		DEC $1570,x			;/
.TimerZero	PHX				;\
		LDA $C2,x			; |
		ASL A				; | Jump to subroutine based on index in $C2,x
		TAX				; |
		JMP.w (YOSHI_POINTER,x)		;/

YOSHI_POINTER:	dw CASTLE1_YOSHI
		dw CASTLE2_YOSHI
		dw CASTLE3_YOSHI
		dw CASTLE4_YOSHI
		dw CASTLE5_YOSHI
		dw CASTLE6_YOSHI
		dw CASTLE7_YOSHI
		dw CASTLE8_YOSHI

; This Yoshi is rescued after defeating Kingking in Castle #1

CASTLE1_YOSHI:	PLX				; Restore sprite index
		LDA $C2,x			;\
		BMI .MAIN			; |
		LDA #$02			; |
		STA $1602,x			; | INIT routine
		LDA $C2,x			; |
		ORA #$80			; |
		STA $C2,x			; |
		.MAIN				;/

		LDA $9D				;\
		BEQ .Process			; | Check for lock flag
		JMP .Graphics			; |
		.Process			;/

		LDA $1602,x
		CMP #$01
		BNE .NotJumping
		LDA $1570,x
		BNE .NotJumping
		LDA #$02
		STA $1602,x

.NotJumping	LDA $1602,x
		CMP #$03
		BNE .NotTurning
		LDA $1540,x
		BEQ .StopTurning
		CMP #$08
		BNE .NotTurning
		LDA $157C,x
		EOR #$01
		STA $157C,x
		BRA .UpdateSpeed
.StopTurning	LDA #$02
		STA $1602,x

.NotTurning	LDA $1602,x
		CMP #$02
		BNE .UpdateSpeed

		LDY $157C,x
		LDA .XLimit,y
		CMP $E4,x
		BNE .UpdateSpeed
		LDA #$10
		STA $1540,x
		LDA #$03
		STA $1602,x

.UpdateSpeed	LDY $157C,x
		LDA .XSpeed,y
		STA $B6,x
		LDA $1602,x
		CMP #$01			;\
		BEQ .Talk			; | Don't apply speed during animations 1 and 3
		CMP #$03			; |
		BEQ .Talk			;/
		JSL $818022

.Talk		JSR YOSHI_INTERACTION
		LDA $00
		BEQ .Graphics
		LDA #$05			;\ Message
		STA $1426			;/
		INC A				;\ Next message
		STA $7FA507			;/
		LDA #$01			;\ Display one extra message
		STA $7FA517			;/
		LDA #$01
		STA $1602,x
		LDA #$10
		STA $1570,x

.Graphics	LDA $1602,x
		DEC : BEQ .Animate
		LDA $14
		AND #$10
		LSR #3
		STA $1570,x
		LDA $1602,x
		CMP #$02
		BEQ .Animate
		STZ $1570,x
.Animate	LDA #$08			; CCC-bits
		JSL YOSHI_GRAPHICS
		RTS				; End subroutine

.XSpeed		db $08,$F8
.XLimit		db $A0,$60

CASTLE2_YOSHI:	PLX
		RTS

CASTLE3_YOSHI:	PLX
		RTS

CASTLE4_YOSHI:	PLX
		RTS

CASTLE5_YOSHI:	PLX
		RTS

CASTLE6_YOSHI:	PLX
		RTS

CASTLE7_YOSHI:	PLX
		RTS

CASTLE8_YOSHI:	PLX
		RTS




; Yoshi help routines

YOSHI_INTERACTION:

		STZ $00				; Reset talk flag
		LDA $1602,x			; Load animation pointer index
		CMP #$01			;\ Don't allow talking while Yoshi is jumping
		BEQ .Return			;/

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
		BNE .Return			;/
		LDY $60				; Y = player 2 index

		LDA $0DA7			;\
		AND #$08			; |
		BEQ .Return			; | Only check player 2 Xpos if he's on the ground and pressing up
		LDA $1588,y			; |
		AND #$04			; |
		BEQ .Return			;/

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
		BPL .Return
		INC $00				; Set talk flag
.Return		SEP #$20			; A 8 bit
		RTS

YOSHI_GRAPHICS:

; -Input-
;
; A		= CCC-bits
; X		= Sprite index
; $1570,x	= Animation timer
; $157C,x	= Horizontal direction
; $1602,x	= Animation number
;
; -Memory Usage-
;
; $00   	= Xpos within screen
; $01   	= Ypos within screen
; ($02) 	= Tilemap location within bank (16-bit, obviously)
; $04   	= OAM index
; $05   	= First byte of tilemap (number of bytes to draw)
; $06   	= $157C,x (horizontal direction)
; $07   	= Stored to when flipping Xdisp and YXPPCCCT
; $08		= CCC-bits (palette), ORA'd to YXPPCCCT

		STA $08				; Store CCC-bits to scratch RAM
		JSR GET_DRAW_INFO		; Calculate some things
		STY $04				; Store OAM index to scratch RAM

		PHX				; Preserve sprite index
		LDA $1602,x			;\
		CMP #$8A			; |
		BEQ ++				; | Face Mario during certain animations
		CMP #$8B			; |
		BNE +				; |
	++	JSR REX_HORZ_POS		; |
		BRA ++				;/
	+	LDA $157C,x			;\ Store direction to scratch RAM
		STA $06				;/
	++	LDA $1570,x			;\
		AND #$FE			; | Preserve animation timer without lowest bit
		PHA				;/
		LDA $1602,x
		ASL A
		TAX
		REP #$20			; A 16 bit
		BCS .Rex
.Yoshi		LDA.w YOSHI_ANIMATION_PTR,x	; Load Yoshi animation table location
		BRA +
.Rex		LDA.w REX_ANIMATION_PTR,x	; Load Rex animation table location
	+	STA $02				; Store to scratch RAM
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
		EOR #$FF			; \ Invert Xdisp if facing right
		INC A				; /
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
		CLC : ADC $08			; > Add palette
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
		JML $81B7B3			; Draw tiles

; This pointer table determines what animaiton has what number.
; There can be a maximum of 128 animations, as the table is indexed by a 7 bit number.

YOSHI_ANIMATION_PTR:
		dw YOSHI_ANIM_IDLE		; 00
		dw YOSHI_ANIM_JUMP		; 01
		dw YOSHI_ANIM_WALK		; 02
		dw YOSHI_ANIM_TURN		; 03

REX_ANIMATION_PTR:
		dw REX_ANIM_IDLE		; 80
		dw REX_ANIM_HURT		; 81
		dw REX_ANIM_SMUSH		; 82
		dw REX_ANIM_DEAD		; 83
		dw REX_ANIM_HURT		; 86
		dw REX_ANIM_SMUSH		; 87
		dw REX_ANIM_DEAD		; 88
		dw REX_ANIM_THROW		; 8A
		dw REX_ANIM_STUMBLE		; 8B

; Note that animation tables are read backwards.
; The last tilemap in the table is the first frame, the second to last table is the second frame, etc.

YOSHI_ANIM_IDLE:
		dw YOSHI_IDLE00

YOSHI_ANIM_JUMP:
		dw YOSHI_JUMP00
		dw YOSHI_JUMP01
		dw YOSHI_JUMP02
		dw YOSHI_JUMP03
		dw YOSHI_JUMP03
		dw YOSHI_JUMP02
		dw YOSHI_JUMP01
		dw YOSHI_JUMP00
		dw YOSHI_IDLE00

YOSHI_ANIM_WALK:
		dw YOSHI_WALK01
		dw YOSHI_WALK00

YOSHI_ANIM_TURN:
		dw YOSHI_TURN00


REX_ANIM_IDLE:
		dw REX_IDLE01
		dw REX_IDLE00

REX_ANIM_HURT:
		dw REX_HURT00
		dw REX_HURT00

REX_ANIM_SMUSH:
		dw REX_SMUSH01
		dw REX_SMUSH00

REX_ANIM_DEAD:
		dw REX_DEAD00
		dw REX_DEAD00


REX_ANIM_THROW:
		dw REX_THROW00
		dw REX_THROW00

REX_ANIM_STUMBLE:
		dw REX_STUMBLE00
		dw REX_STUMBLE00

; Tilemaps

YOSHI_IDLE00:	db $04				; Number of tiles
		db $F8,$F0,$00,$21
		db $F8,$00,$20,$21
		db $00,$F0,$01,$21
		db $00,$00,$21,$21

YOSHI_JUMP00:	db $04				; Number of tiles
		db $F8,$F0,$00,$21
		db $F8,$00,$20,$21
		db $00,$F0,$01,$21
		db $00,$00,$21,$21
YOSHI_JUMP01:	db $04				; Number of tiles
		db $F8,$EF,$03,$21
		db $F8,$FF,$23,$21
		db $00,$EF,$04,$21
		db $00,$FF,$24,$21
YOSHI_JUMP02:	db $04				; Number of tiles
		db $F8,$ED,$06,$21
		db $F8,$FD,$26,$21
		db $00,$ED,$07,$21
		db $00,$FD,$27,$21
YOSHI_JUMP03:	db $04				; Number of tiles
		db $F8,$EC,$06,$21
		db $F8,$FC,$26,$21
		db $00,$EC,$07,$21
		db $00,$FC,$27,$21

YOSHI_WALK00:	db $02				; Number of tiles
		db $F6,$F0,$88,$21
		db $00,$00,$8A,$21
YOSHI_WALK01:	db $02
		db $F6,$F1,$88,$21
		db $00,$01,$92,$21

YOSHI_TURN00:	db $02				; Number of tiles
		db $F9,$F1,$96,$21
		db $00,$00,$A8,$21


REX_IDLE00:	db $02				; Vanilla frame 1
		db $00,$00,$00,$21
		db $FC,$F1,$0A,$21
REX_IDLE01:	db $02				; Vanilla frame 2
		db $00,$00,$20,$21
		db $FC,$F0,$0A,$21

REX_HURT00:	db $02
		db $00,$00,$00,$21
		db $FE,$F8,$0A,$21

REX_SMUSH00:	db $01
		db $00,$00,$0C,$21
REX_SMUSH01:	db $01
		db $00,$00,$28,$21

REX_DEAD00:	db $01
		db $00,$00,$60,$21


REX_THROW00:	db $03
		db $04,$FA,$08,$1D
		db $00,$00,$20,$21
		db $FC,$F0,$4E,$21

REX_STUMBLE00:	db $03
		db $00,$00,$2E,$21
		db $F0,$00,$0E,$21
		db $FC,$F0,$42,$21





SPR_T1: db $0C,$1C
SPR_T2: db $01,$02

GET_DRAW_INFO:	STZ $186C,x
		STZ $15A0,x
		LDA $E4,x
		CMP $1A
		LDA $14E0,x
		SBC $1B
		BEQ ON_SCREEN_X
		INC $15A0,x

ON_SCREEN_X:	LDA $14E0,x
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

ON_SCREEN_LOOP:	LDA $D8,x
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

ON_SCREEN_Y:	DEY
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

INVALID:	PLA : PLA			; Get RTS address off the stack
		RTL				; End graphics routine