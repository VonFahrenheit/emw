

	SEI
	PHP
	REP #$30
	PHA
	PHX
	PHY
	PHB
	PHD
	LDA #$4300 : TCD			; > DP = $4300
	SEP #$30
	PHK : PLB
	LDA $4210
	LDA #$80 : STA $2100
	STZ $420C


		LDA $6D9B
		BNE +
		LDA #$80				;\
		STA $2115				; |
		REP #$20				; |
		LDA #$5000				; |
		STA $2116				; |
		LDA #$1801				; |
		STA $00					; |
		LDA.w #$0020				; | Upload top row of dynamic BG3
		STA $02					; |
		LDX #$00				; |
		STX $04					; |
		LDA #$0040				; |
		STA $05					; |
		LDY #$01				; |
		STY $420B				;/
		LDA #$2202				;\
		STA $00					; |
		LDA.w #$00A0				; |
		STA $02					; |
		LDA #$0016				; | Upload color
		STA $05					; |
		STY $2121				; |
		STY $420B				;/
		SEP #$20				; > A 8 bit
		+

		STZ !OAMindex
		STZ !OAMindexhi
		LDA !GameMode				;\
		CMP #$14				; |
		BEQ .Start				; |
		CMP #$13				; | Upload GFX during level load, level, and title screen
		BEQ .Start				; |
		CMP #$07				; |
		BEQ .Start				;/
		JMP ReturnToNMI

.Start		REP #$20				; > A 16 bit
		LDY #$80				; Word writes
		STY $2115
		LDY #!VRAMbank : PHY : PLB		; Set VRAM bank
		LDA.w #!MaxUpload
		STA.w !LoadSize
		LDX.w !LoadIndex

.Loop		LDA.l .Index,x : TAY
		LDA.w !VRAMtable+0,y			;\
		BNE .Go					; |
		INX					; |
		CPX #$24				; | End upload after checking entire table
		BNE .Loop				; |
		STZ.w !LoadIndex			; |
		JMP UPLOAD_CGRAM			;/
.Go		STA $05					; > 4305 = data size
		SEC : SBC.w !LoadSize			;\ Limit data per frame
		BPL .FinalBatch				;/
		EOR #$FFFF : INC A			;\ Update data cap remaining
		STA !LoadSize				;/
		LDA.w #$0000				;\ Clear slot
		STA.w !VRAMtable+0,y			;/
		LDA.w !VRAMtable+2,y			;\
		STA $02					; | Source data
		LDA.w !VRAMtable+3,y			; |
		STA $03					;/
		LDA.w !VRAMtable+5,y			;\ Dest VRAM
		STA.l $002116				;/
		XBA					;\
		AND #$0080				; |
		BEQ +					; |
		LDA $002139				; | Transfer direction (+dummy read)
		LDA #$3981				; |
	+	ORA #$1801				; |
		STA $00					;/
		LDA #$0001 : STA $00420B		; > Transfer data ($420C is 0 anyway)
		INX					;\
		CPX #$24				; |
		BNE .Loop				; | Loop, end at upload index = 0x24
		STZ.w !LoadIndex			; |
		BRA UPLOAD_CGRAM			;/

.FinalBatch	BNE +					;\ Increment index if necessary
		INX					;/
	+	STA.w !VRAMtable+0,y			; Next upload = remaining data
		LDA.w !LoadSize				;\ Current upload = max data
		STA $05					;/
		LDA.w !VRAMtable+2,y			;\
		STA $02					; | Current upload source
		LDA.w !VRAMtable+3,y			; |
		STA $03					;/
		LDA.w !LoadSize				;\
		CLC : ADC.w !VRAMtable+2,y		; | Next upload source
		STA.w !VRAMtable+2,y			;/
		LDA.w !VRAMtable+5,y			;\ Current dest VRAM
		STA.l $002116				;/
		LDA.w !LoadSize				;\
		LSR A					; | Next dest VRAM
		CLC : ADC.w !VRAMtable+5,y		; |
		STA.w !VRAMtable+5,y			;/
		XBA					;\
		AND.w #$0080				; | Transfer direction
		ORA #$1801				; |
		STA $00					;/
		LDA #$0001 : STA $00420B		; > Upload
		STX !LoadIndex				; > Queue remaining data
.End		BRA UPLOAD_CGRAM

.Index		db $00,$07,$0E,$15,$1C,$23,$2A,$31
		db $38,$3F,$46,$4D,$54,$5B,$62,$69
		db $70,$77,$7E,$85,$8C,$93,$9A,$A1
		db $A8,$AF,$B6,$BD,$C4,$CB,$D2,$D9
		db $E0,$E7,$EE,$F5


UPLOAD_CGRAM:	LDA #$2202				;\ Parameters and destination of DMA
		STA $00					;/
		LDX #$00

.Loop		LDA.l .Index,x : TAY
		LDA.w !CGRAMtable+0,y			;\ End upload at an 0x0000 word
		BEQ ReturnToNMI				;/
		STA $05					;\
		LDA.w #$0000				; | Set data size and clear slot
		STA.w !CGRAMtable+0,y			;/
		LDA.w !CGRAMtable+2,y			;\
		STA $02					; | Source address
		LDA.w !CGRAMtable+3,y			; |
		STA $03					;/
		SEP #$20				;\
		LDA.w !CGRAMtable+5,y			; | Set dest CGRAM
		STA.l $002121				; |
		REP #$20				;/
		LDA #$0001 : STA $00420B		; > Upload data
		INX
		CPX #$2A
		BNE .Loop
		BRA ReturnToNMI				; > Loop

.Index		db $00,$06,$0C,$12,$18,$1E,$24,$2A
		db $30,$36,$3C,$42,$48,$4E,$54,$5A
		db $60,$66,$6C,$72,$78,$7E,$84,$8A
		db $90,$96,$9C,$A2,$A8,$AE,$B4,$BA
		db $C0,$C6,$CC,$D2,$D8,$DE,$E4,$EA
		db $F0,$F6

ReturnToNMI:

	PHK : PLB
	REP #$10
	TSX			; > Backup stack pointer
	LDA #$3000 : TCD	; > DP = $3000
	LDA #$2112 : TCS	; > Stack = $2112
	SEP #$20
	LDA $24 : PHA
	LDA $25 : STA $01,s
	LDA $22 : PHA
	LDA $23 : STA $01,s
	LDA $20 : PHA
	LDA $21 : STA $01,s
	LDA $1E : PHA
	LDA $1F : STA $01,s
	LDA $1C : PHA
	LDA $1D : STA $01,s
	LDA $1A : PHA
	LDA $1B : STA $01,s

	; MODE 7 WRITES GO HERE

	TXS
	LDA $3E : STA $2105	; > Screen mode
	LDA $6DB0 : STA $2106	; > Mosaic
	LDA $44 : STA $2130	;\ Color stuff
	LDA $40 : STA $2131	;/
	LDA $41 : STA $2123	;\ Window stuff
	LDX $42 : STX $2124	;/
	LDX $6D9D		;\ Main/sub screen
	STX $212C : STX $212E	;/



; Checklist:
;	- Update music ($2140-$2143)
;	- Dynamic BG3
;	- OAM index
;	- Dynamic graphics/palette
;
;	- Windowing regs ($2123-$2125, $2130)
;	- CGADSUB ($2131)
;	- BG mode ($2105)
;	- Mosaic ($2106)
;	- Layer positions ($210D-$2110)

;	- $00A488: Dynamic palette
;	- $0087AD: Level loader
;	- $00A390: Player GFX DMA
;	- $0085D2: Stripe loader
;	- $008449: OAM update
;	- $008650: Controller update

;	- IRQ ($4209-$420A, $4211)
;	- Set $4200
;	- Brightness ($2100)
;	- HDMA ($420C)












