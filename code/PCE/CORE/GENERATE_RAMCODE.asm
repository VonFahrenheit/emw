;================;
;GENERATE RAMCODE;
;================;
;
; 16-bit input:
;	A = dynamo word, shifted left 8 bits
;	Y = format (0x00 = big, 0xFF = small)
;	$02 = source offset (within file)
;	!FileAddress = 24-bit source address of file (gets shredded)
;
; 24-bit input:
;	A = pointer to dynamo
;	!FileAddress = 24-bit source address of file
;


GENERATE_RAMCODE:

; TODO:
; - add a check for small format (mario, luigi, peach)



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
; order is 6000, 6100, 6040, 6140, 6080, 6180, 60C0, 61C0 (with +200 for P2, but same increments/decrements)
;
; the 0x0100 bit changes every time
; every time it is cleared, 0x0040 is added to the address





	.16bit
		REP #$30
		AND #$00F0 : ASL A					;\ $00 = upload size (ASL clears c)
		STA $00							;/
		LDA $02							;\
		ADC !FileAddress					; | source address
		STA !FileAddress					;/
		LDA !CurrentPlayer					;\
		AND #$00FF						; |
		BEQ $03 : LDA #$0200					; | $04 = player's base VRAM address
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
		EOR #$0100						;\
		BIT #$0100						; | optimized increment
		BNE $03 : ADC #$0040					; | (c should still be clear)
		STA $04							;/

		TXA							;\
		ADC #$0013						; | update index and loop
		TAX							; |
		DEY : BPL ..loop					;/


		BIT $02 : BPL ..bigformat
		..smallformat
		LDA.l !RAMcode-($13*2)+$01,x : STA.l !RAMcode-($13*1)+$01,x
		LDA.l !RAMcode-($13*3)+$01,x : STA.l !RAMcode-($13*2)+$01,x
		..bigformat

		JMP .Done









; -- dynamo format --
;
; 1 byte header (size)
; for each upload:
; +00 	cccssss-
; +01	Fccccccc
; +02	ttttt---
;
; ssss:		DMA size (shift left 4)
; cccccccccc:	character (formatted for source address)
; F:		second file flag (when set, file stored at !FileAddress+4 should be used for the rest of the dynamo)
; ttttt:	tile number (one of 32 possible locations in player section, shift left once then add VRAM offset)
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
		BEQ $03 : LDA #$0200					; | $04 = player VRAM offset
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
		LDY !FileAddress+4 : JSL !GetFileAddress		; |
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
		AND #$00F8 : ASL A					; | dest VRAM + player offset
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





