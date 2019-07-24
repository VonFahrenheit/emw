;================;
;GENERATE RAMCODE;
;================;
GENERATE_RAMCODE:

; Load dynamo pointer in A, then JSR here.
; Regs are expected to be 16-bit, will return in 8-bit.
; Overwrites $00-$06. Regs are shredded.

; 12AC84
		STA $00				;\
		PHK : PHK : PLA			; | Set up 24-bit pointer
		STA $02				;/
		LDA ($00) : STA $03		; Byte count here
		INC $00
		INC $00
		PHB
		PEA $4141			;\ Switch to bank 0x41
		PLB : PLB			;/
		REP #$30			; > Regs 16-bit
		STZ $05				;\
		LDA !CurrentPlayer		; | Player VRAM offset
		AND #$00FF			; |
		BNE $05 : LDA #$0200 : STA $05	;/
		LDA !RAMcode_Offset : TAX	;\ Starting indexes
		LDY #$0000			;/

	-	LDA #$00A9			; LDA #$00XX
		STA $8000,x			;\
		STA $8005,x			; | In these spots
		STA $800A,x			; |
		STA $800F,x			;/
		LDA #$0285 : STA $8003,x	; STA $02
		LDA #$0485 : STA $8008,x	; STA $04
		LDA #$0585 : STA $800D,x	; STA $05
		LDA #$168D : STA $8012,x	;\
		LDA #$8C21 : STA $8014,x	; | STA $2116 : STY $420B
		LDA #$420B : STA $8016,x	;/
		LDA [$00],y : STA $800B,x	;\
		INY #2				; |
		LDA [$00],y : STA $8001,x	; |
		INY #2				; |
		LDA [$00],y			; | Write dynamic data
		AND #$00FF			; |
		STA $8006,x			; |
		INY				; |
		LDA [$00],y			; |
		SEC : SBC $05			; > Subtract player VRAM offset
		STA $8010,x			; |
		INY #2				;/
		TXA				;\
		CLC : ADC #$0018		; | Increment code index
		TAX				;/
		CPY $03				;\ Loop
		BNE -				;/
		LDA #$6B6B : STA $8000,x	; > End routine
		TXA				;\ This is where the next routine should start if there is one
		STA !RAMcode_Offset		;/
		PLB
		LDA #$1234 : STA !RAMcode_flag	; Enable RAM code execution
		SEP #$30
		RTS



