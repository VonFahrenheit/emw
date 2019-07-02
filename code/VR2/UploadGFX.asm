UploadGFX:	SEI
		PHP
		REP #$30
		PHA
		PHX
		PHY
		PHB
		PHD : LDA #$420B : TCD			; Direct page = 0x420B
		SEP #$30				; A and index 8 bit
		STZ !OAMindex				;\ Clear OAM index at every NMI
		STZ !OAMindexhi				;/
		LDA $0100				; Check game mode to see if in game
		CMP #$14				; Must be in this game mode (level)
		BEQ +
		BRL ReturnNMI
	+	REP #$20				; > A 16 bit

	; DMA SETUP

		LDY #$80				; Word writes
		STY $2115
		LDA #$1801				; Parameters and destination for DMA
		STA $F5

	; VRAM TABLE UPLOAD

		LDY #!VRAMbank : PHY : PLB		; Set VRAM bank
		LDX #$00				; Set up index at 0x00
.Loop		LDA.w !VRAMtable,x			;\ End upload at an 0x0000 word
		BEQ UPLOAD_CGRAM			;/
		STA $FA					;\ Set data size, then clear the upload register
		STZ.w !VRAMtable,x			;/
		INX : INX				; > Increment index
		LDA.w !VRAMtable,x			;\ Set lo and hi bytes of source address
		STA $F7					;/
		INX : INX				; > Increment index
		LDY.w !VRAMtable,x			;\ Set bank byte of source address
		STY $F9					;/
		INX					; > Increment index
		LDA.w !VRAMtable,x			;\ Set dest VRAM
		STA.l $002116				;/
		INX : INX				; > Increment index
		LDY #$01				;\ Transfer data
		STY $00					;/
		BRA .Loop				; > Loop

UPLOAD_CGRAM:	LDA #$2202				;\ Parameters and destination of DMA
		STA $F5					;/
		LDX #$00				; Start upload at X = 0x00
.Loop		LDA.w !CGRAMtable,x			;\ End upload at an 0x0000 word
		BEQ ReturnNMI				;/
		STA $FA					;\ Set data size and clear upload register
		STZ.w !CGRAMtable,x			;/
		INX : INX				; > Increment index
		LDA.w !CGRAMtable,x			;\ Set source address
		STA $F7					;/
		INX : INX				; > Increment index
		LDY.w !CGRAMtable,x			;\ Set source bank
		STY $F9					;/
		INX					; > Increment index
		SEP #$20				;\
		LDA.w !CGRAMtable,x			; | Set dest CGRAM
		STA.l $002121				; |
		REP #$20				;/
		INX					; > Increment index
		LDY #$01				;\ Upload palette data
		STY $00					;/
		BRA .Loop				; > Loop

ReturnNMI:	PLD					; Restore direct page
		SEP #$30				; All registers 8 bit
		LDA #$80 : PHA : PLB			; Set FastROM bank
		LDA #$01 : STA $420D			; Enable FastROM
		JML $808176				; Return to NMI routine with FastROM enabled


