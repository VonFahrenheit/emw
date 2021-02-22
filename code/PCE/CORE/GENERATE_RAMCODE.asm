;================;
;GENERATE RAMCODE;
;================;
GENERATE_RAMCODE:

; Load dynamo pointer in A, then JSR here.
; Regs are expected to be 16-bit, will return in 8-bit.
; Overwrites $00-$06. Regs are shredded.

; 12AC84
		STA $00					;\
		PHK : PHK : PLA				; | Set up 24-bit pointer
		STA $02					;/
		LDA ($00) : STA $03			; Byte count here
		INC $00
		INC $00
		PHB
		SEP #$20
		LDA.b #!RAMcode>>16 : PHA : PLB		; switch to RAMcode bank
		REP #$30				; > Regs 16-bit
		STZ $05					;\
		LDA !CurrentPlayer			; | Player VRAM offset
		AND #$00FF				; |
		BNE $05 : LDA #$0200 : STA $05		;/
		LDA.l !RAMcode_offset : TAX		;\ Starting indexes
		LDY #$0000				;/

		LDA #$00A9 : STA.w !RAMcode+$00,x	;\
		LDA #$1801 : STA.w !RAMcode+$01,x	; | start with LDA.w #$1801 : STA $00
		LDA #$0085 : STA.w !RAMcode+$03,x	; |
		INX #5					;/

	-	LDA #$00A9				; LDA #$00XX
		STA.w !RAMcode+$00,x			;\
		STA.w !RAMcode+$05,x			; | In these spots
		STA.w !RAMcode+$0A,x			; |
		STA.w !RAMcode+$0F,x			;/
		LDA #$0285 : STA.w !RAMcode+$03,x	; STA $02
		LDA #$0485 : STA.w !RAMcode+$08,x	; STA $04
		LDA #$0585 : STA.w !RAMcode+$0D,x	; STA $05
		LDA #$168D : STA.w !RAMcode+$12,x	;\
		LDA #$8C21 : STA.w !RAMcode+$14,x	; | STA $2116 : STY $420B
		LDA #$420B : STA.w !RAMcode+$16,x	;/
		LDA [$00],y : STA.w !RAMcode+$0B,x	;\ > upload size
		CLC : ADC.w !VRAMsize			; \ increment upload size
		STA.w !VRAMsize				; /
		INY #2					; |
		LDA [$00],y : STA.w !RAMcode+$01,x	; | > source address
		INY #2					; |
		LDA [$00],y				; | > bank byte
		AND #$00FF				; |
		STA.w !RAMcode+$06,x			; |
		INY					; |
		LDA [$00],y				; |
		SEC : SBC $05				; | > subtract player VRAM offset from dest VRAM
		STA.w !RAMcode+$10,x			; |
		INY #2					;/
		TXA					;\
		CLC : ADC #$0018			; | Increment code index
		TAX					;/
		CPY $03					;\ Loop
		BNE -					;/
		LDA #$6B6B : STA.w !RAMcode+$00,x	; > End routine
		PLB					;\ This is where the next routine should start if there is one
		STX !RAMcode_offset			;/
		LDA #$1234 : STA !RAMcode_flag		; Enable RAM code execution
		SEP #$30
		RTS


; Generated code for each entry is:
;	LDA.w #[source] : STA $02		;\
;	LDA.w #[bank] : STA $04			; |
;	LDA.w #[size] : STA $05			; | 24 bytes, performs the fastest possible upload
;	LDA.w #[dest] : STA.w $2116		; |
;	STY.w $420B				;/
;
; ends with RTL
;
; byte count is 24 x [number of uploads] + 1


