;================;
;GENERATE RAMCODE;
;================;
GENERATE_RAMCODE:
<<<<<<< Updated upstream

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
=======
; mario/luigi/peach format:
;
; +00	cccccc--
; +01	sssscccc
;
;	s = number of tiles
;	c = source address
;
; (swapping s and c results in the same number of bit shifts)
;
; calculate source:
;	LDA Dyn+0
;	AND #$0FFC : ASL #3
;
; calculate size:
;	LDA Dyn+1
;	AND #$00F0 : ASL A


; fast RAMcode:

; $00	upload size
; $02	format, stored in hi byte (0x00 = big, 0xFF = small)
; $04	player VRAM offset, increments as uploads are performed
; $06	tracking number of bytes uploaded
;
; VRAM offset algorithm:
; order is 6000, 6100, 6200, 6300, 6040, 6140, 6240, 6340 (with +80 for P2, but same increments/decrements)




	.16bit
		REP #$30
		AND #$00F0 : ASL A					;\ $00 = upload size (ASL clears c)
		STA $00							;/
		LDA $02							;\
		ADC !FileAddress					; | source address
		STA !FileAddress					;/
		LDA !CurrentPlayer					;\
		AND #$00FF						; |
		BEQ $03 : LDA.w #(!P2Tile1-!P1Tile1)*$10		; | $04 = player's base VRAM address
		ORA #$6000						; |
		STA $04							;/
		STY $03							; $02 = small/big format
		STZ $06							; $06 = bandwidth used

		CLC							; there *should* be no overflow so clearing c once *should* be fine

		STZ !RAMcode_flag					; disable RAM code execution
		LDX !RAMcode_offset					; X = index to RAM code
		LDA #$00A9 : STA.l !RAMcode+$00,x			;\
		LDA #$1801 : STA.l !RAMcode+$01,x			; | start with LDA.w #$1801 : STA $00
		LDA #$0085 : STA.l !RAMcode+$03,x			;/
		LDA !FileAddress+2-1					;\
		AND #$FF00						; | update bank
		ORA #$00A2 : STA.l !RAMcode+$05,x			; | LDX.b #$XX : STX $04
		LDA #$0486 : STA.l !RAMcode+$07,x			;/
		TXA							;\
		ADC #$0009						; | update index
		TAX							;/

		LDY #$0003						; Y = loop counter
		BIT $02							;\ small format check
		BPL $01 : DEY						;/


		..loop
		LDA #$00A9						; LDA #$xxxx
		STA.l !RAMcode+$00,x					;\
		STA.l !RAMcode+$05,x					; | in these spots
		STA.l !RAMcode+$0A,x					;/
		LDA #$0285 : STA.l !RAMcode+$03,x			; STA $02
		LDA #$0585 : STA.l !RAMcode+$08,x			; STA $05
		LDA #$168D : STA.l !RAMcode+$0D,x			; STA $xx16
		LDA #$8C21 : STA.l !RAMcode+$0F,x			; $21 (previous opcode) : STY $xxxx
		LDA #$420B : STA.l !RAMcode+$11,x			; $420B (previous opcode)

		LDA $00 : STA.l !RAMcode+$06,x				; upload size
		ADC $06							;\ update bandwidth used
		STA $06							;/
		LDA !FileAddress : STA.l !RAMcode+$01,x			; source address
		ADC #$0200						;\ update source address
		STA !FileAddress					;/
		LDA $04 : STA.l !RAMcode+$0B,x				; dest VRAM
		ADC #$0100						;\
		BIT #$0300						; | optimized increment
		BNE $03 : EOR #$0340					; | (c should still be clear)
		STA $04							;/
		TXA							;\
		ADC #$0013						; | update index and loop
		TAX							; |
		DEY : BPL ..loop					;/


	;	BIT $02 : BPL ..bigformat
	;	..smallformat
	;	LDA.l !RAMcode-($13*2)+$01,x : STA.l !RAMcode-($13*1)+$01,x
	;	LDA.l !RAMcode-($13*3)+$01,x : STA.l !RAMcode-($13*2)+$01,x
	;	..bigformat

		JMP .Done









; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; +00 	cccssss-
; +01	Fccccccc
; +02	tttttt--
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; F:		second file flag (when set, file stored at !FileAddress+4 should be used for the rest of the dynamo)
; tttttt:	tile number (one of 64 possible locations in player section, shift left twice then add VRAM offset)
;		note that each player only has 32 8x8 tiles, but these are spread over 64 spaces
;
; $00	bank (stored in hi byte)
; $02	end index
; $04	player VRAM offset
; $06	tracking number of bytes uploaded
; $08	which file is being loaded


	.24bit
		REP #$30						; > all regs 16-bit
		STA $00							;\
		LDA ($00)						; |
		AND #$00FF						; | $02 = end index
		INC $00							; | Y = index to dynamo data
		CLC : ADC $00						; |
		STA $02							; |
		LDY $00							;/

		LDA !CurrentPlayer					;\
		AND #$00FF						; |
		BEQ $03 : LDA.w #(!P2Tile1-!P1Tile1)*$10		; | $04 = player VRAM offset
		ORA #$6000						; |
		STA $04							;/

		STZ $00							; $00 = start with invalid bank
		STZ $06							; $06 = bandwidth used
		STZ $08							; $08 = start with primary file

		STZ !RAMcode_flag					; disable RAM code execution
		LDX !RAMcode_offset					; X = index to RAM code
		LDA #$00A9 : STA.l !RAMcode+$00,x			;\
		LDA #$1801 : STA.l !RAMcode+$01,x			; | start with LDA.w #$1801 : STA $00
		LDA #$0085 : STA.l !RAMcode+$03,x			; |
		INX #5							;/

		..updatebank						;\
		LDA !FileAddress+2-1					; |
		AND #$FF00						; | update bank
		ORA #$00A2 : STA.l !RAMcode+$00,x			; | LDX.b #$XX : STX $04
		LDA #$0486 : STA.l !RAMcode+$02,x			; |
		INX #4							;/

		CLC							; this *should* be fine to do just once here

		..loop
		LDA $0000,y						;\ check for file swap
		EOR $08 : BPL ..keepaddress				;/
		..updateaddress						;\
		STA $08							; |
		PHY							; | get secondary file
		LDY !FileAddress+4 : JSL GetFileAddress			; |
		PLY							; |
		BRA ..updatebank					; > update bank
		..keepaddress						;/

		LDA #$00A9						; LDA #$xxxx
		STA.l !RAMcode+$00,x					;\
		STA.l !RAMcode+$05,x					; | in these spots
		STA.l !RAMcode+$0A,x					;/
		LDA #$0285 : STA.l !RAMcode+$03,x			; STA $02
		LDA #$0585 : STA.l !RAMcode+$08,x			; STA $05
		LDA #$168D : STA.l !RAMcode+$0D,x			; STA $xx16
		LDA #$8C21 : STA.l !RAMcode+$0F,x			; $21 (previous opcode) : STY $xxxx
		LDA #$420B : STA.l !RAMcode+$11,x			; $420B (previous opcode)

		LDA $0000,y						;\
		AND #$001E : ASL #4					; | upload size
		STA.l !RAMcode+$06,x					;/
		ADC $06							;\ update bandwidth used
		STA $06							;/
		LDA $0000,y						;\
		AND #$7FE0						; | source address
		ADC !FileAddress+0					; |
		STA.l !RAMcode+$01,x					;/
		LDA $0002,y						;\
		AND #$00FC : ASL #2					; | dest VRAM + player offset
		ADC $04							; |
		STA.l !RAMcode+$0B,x					;/

		TXA							;\
		ADC #$0013						; |
		TAX							; | update indexes and loop
		INY #3							; |
		CPY $02 : BCS .Done					; |
		JMP ..loop						;/


		.Done
		LDA #$6B6B : STA.l !RAMcode+$00,x			; RTL : RTL (appended here since index wasn't updated on the last loop)
		LDA $06							;\
		CLC : ADC.l !VRAMbase+!VRAMsize				; | update bandwidth used for VR3
		STA.l !VRAMbase+!VRAMsize				;/
		STX !RAMcode_offset					; update RAM code index
		LDA #$1234 : STA !RAMcode_flag				; enable RAM code execution
		SEP #$30						; all regs 8-bit
		RTL							; return



>>>>>>> Stashed changes


