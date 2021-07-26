

; special file to deal with asar's limitations
; there is no way to repeat a macro a number of times based on the distance between two labels (confirmed by alcaro)
; because of this, i'm compiling all the RAM codes to a .bin file and using a macro to read that in an anti-compressed format
; essentially, each word in the .bin file becomes 6 bytes (LDA #[source word] : STA !RAMcode,x)
; however, this is the fastest possible way to load it, and the data is small enough that this bloating should be insignificant

; when this file is assembled with !CompileBinary = 1, it compiles the binary
; when this file is assembled with !CompileBinary = 0, it assembles the code that reads the binary, which is inserted into the ROM



; binary format:
; $0000-$00FF: 16-bit pointers to routines
; $0100-$7FFF: RAM code
; $8000-$FFFF: data used to find specific locations in RAM code, 256 bytes per index




macro registerhook(label)
	pushpc
	org (!BinaryIndex*$100)|$8000+(!Temp*2)
		dw <label>-..code+1
	pullpc
	!Temp := !Temp+1
	!HooksRegistered := !HooksRegistered+1
	!TotalHooksRegistered := !TotalHooksRegistered+1
endmacro


macro storetohook(ID)
	STA.w !RAMcode+readfile2("bin/RAMcode.bin", (!BinaryIndex*$100|$8000)+(<ID>*2)),x
endmacro


macro DMAsettings(word)
		LDA.w #<word>
		CMP $0C : BEQ ?Same
	?New:
		STA $0C
		LDA.w #$00A9 : STA.w !RAMcode+$00,x
		LDA.w #<word> : STA.w !RAMcode+$01,x
		LDA.w #$0085 : STA.w !RAMcode+$03,x
		TXA
		CLC : ADC #$0005
		TAX
	?Same:
endmacro

macro VideoPort(byte)
		LDA.w #<byte>
		CMP $08 : BEQ ?Same
	?New:
		STA $08
		LDA.w #<byte><<8+$A2 : STA.w !RAMcode+$00,x
		LDA.w #$008E : STA.w !RAMcode+$02,x
		LDA.w #$2115 : STA.w !RAMcode+$03,x
		TXA
		CLC : ADC #$0005
		TAX
	?Same:
endmacro



macro turbocopy(index)
	LDA.w #readfile2("bin/RAMcode.bin", readfile2("bin/RAMcode.bin", (<index>*2))+!Temp) : STA.w !RAMcode+!Temp,x
	!Temp := !Temp+2
endmacro

macro turbocode(bytes)
	!Temp = 0
	rep (((<bytes>+1)&$FFFE)/2) : %turbocopy(!BinaryIndex)
	LDA.w #<bytes> : STA $0A
endmacro






; RAM use:
;	$00
;	$02
;	$04
;	$06
;	$08 - currently loaded setting for $2115 (16-bit, hi byte always 0), used to optimize RAM code
;	$0A - size of last appended RAM code
;	$0C - currently loaded setting for $4300 (16-bit), used to optimize RAM code
;	$0E - remaining bandwidth




		!BinaryIndex = 0


	if !CompileBinary = 1
	print "Compiling RAM code binary..."
	print "  Code byte counts:"
	norom
	org $000000
		!HooksRegistered = 0
		!TotalHooksRegistered = 0
		fillbyte $00
		fill $10000
	org $000000
	Binary:
	;	dw .AppendDynamo
	;	dw .AppendDownload
	;	dw .AppendTile
		dw .AppendSquare
	;	dw .AppendRow1
	;	dw .AppendRow2
	;	dw .AppendColumn1
	;	dw .AppendColumn2
	;	dw .AppendBackground
	;	dw .AppendPalette
	;	dw .AppendSMWPalette
	;	dw .AppendLight
	;	dw .AppendSMW0D7C
	;	dw .AppendSMW0D7E
	;	dw .AppendSMW0D80
	;	dw .AppendMario
	;	dw .AppendExAnimationGFX
	;	dw .AppendExAnimationPalette
	org $000100
	endif


macro CommentOut1()

	.AppendDynamo
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..src	LDA.w #$0000 : STA $02				; source address
	..bank	LDX.b #$00 : STX $04				; source bank
	..size	LDA.w #$0000 : STA $05				; upload size
	..vram	LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
		..end
		%registerhook(..src)
		%registerhook(..bank)
		%registerhook(..size)
		%registerhook(..vram)
	print "  - Dynamo             index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		..main
		%turbocode(23)					; 23 bytes
		LDA.w !VRAMtable+$00,y				;\
		AND #$3FFF					; | get size without background mode flag or fixed flag
		STA $00						;/
		LDA.w !VRAMtable+$00,y				;\
		AND #$8000					; | get background mode flag
		STA $02						;/
		LDA.w !VRAMtable+$00,y				;\
		AND #$4000					; |
		STA $04						; > remember fixed mode flag
	;	XBA						; | get fixed flag
	;	LSR #3						; | (and set in RAM code right away)
	;	ORA #$1801					; |
	;	STA.w !RAMcode+$01,x				;/
		LDA $0E						;\
		SEC : SBC $00					; | subtract transfer size from remaining bytes allowed
		BCS ..ok					;/
		EOR #$FFFF : INC A				;\
		ORA $02						; > include background mode flag
		ORA $04						; > include fixed mode flag
		STA.w !VRAMtable+$00,y				; |
		LDA $0E : %storetohook(2)			; |
		LDA.w !VRAMtable+$02,y : %storetohook(0)	; |
		BIT $04 : BVS +					; > don't update source for fixed mode
		CLC : ADC $0E					; |
		STA.w !VRAMtable+$02,y				; |
	+	SEP #$20					; | if entire upload can't fit, upload as much as possible
		LDA.w !VRAMtable+$04,y : %storetohook(1)	; | then adjust entry and store its index to keep going next frame
		REP #$20					; |
		LDA.w !VRAMtable+$05,y : %storetohook(3)	; |
		LDA $0E						; |
		LSR A						; |
		CLC : ADC.w !VRAMtable+$05,y			; |
		STA.w !VRAMtable+$05,y				; |
		STZ.w !VRAMslot					; |
		BIT $02 : BMI +					; > background mode transfers don't store their index
		STY.w !VRAMslot					;/
	+	STZ $0E						;\ clear remaining bytes allowed and return
		BRA ..done					;/
		..ok
		STA $0E						; store remaining transfer size allowed
		LDA.w !VRAMtable+$02,y : %storetohook(0)	; source address
		SEP #$20					;\
		LDA.w !VRAMtable+$04,y : %storetohook(1)	; | source bank
		REP #$20					;/
		LDA $00 : STA.w %storetohook(2)			; upload size
		LDA.w !VRAMtable+$05,y : %storetohook(3)	; VRAM address
		LDA #$0000 : STA.w !VRAMtable+$00,y		; clear this slot
		TYA						;\
		CLC : ADC #$0007				; | add 7 to VRAM table index
		TAY						;/
		..done
		TXA
		CLC : ADC $0A
		TAX
		RTS

		..fixed
		%DMAsettings($1809)
		%VideoPort($80)					; 2115
		JMP ..main

	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendDownload
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..src	LDA.w #$0000 : STA $02				; source address
	..bank	LDX.b #$00 : STX $04				; source bank
	..size	LDA.w #$0000 : STA $05				; upload size
	..vram	LDA.w #$0000 : STA $2116			; VRAM address
		LDA.w $2139					; dummy read
		STY.w $420B					; DMA toggle
		..end
		%registerhook(..src)
		%registerhook(..bank)
		%registerhook(..size)
		%registerhook(..vram)
	print "  - Download           index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($3981)				; 4300
		%VideoPort($80)					; 2115
		%turbocode(26)					; 26 bytes
		LDA.w !VRAMtable+$00,y				;\
		AND #$7FFF					; | get size without background mode flag
		STA $00						;/
		LDA.w !VRAMtable+$00,y				;\
		AND #$8000					; | get background mode flag
		STA $02						;/
		LDA $0E						;\
		SEC : SBC $00					; | subtract transfer size from remaining bytes allowed
		BCS ..ok					;/
		EOR #$FFFF : INC A				;\
		ORA $02						; > include background mode flag
		STA.w !VRAMtable+$00,y				; |
		LDA $0E : %storetohook(2)			; |
		LDA.w !VRAMtable+$02,y : %storetohook(0)	; |
		CLC : ADC $0E					; |
		STA.w !VRAMtable+$02,y				; |
		SEP #$20					; | if entire download can't fit, download as much as possible
		LDA.w !VRAMtable+$04,y : %storetohook(1)	; | then adjust entry and store its index to keep going next frame
		REP #$20					; |
		LDA.w !VRAMtable+$05,y : %storetohook(3)	; |
		LDA $0E						; |
		LSR A						; |
		CLC : ADC.w !VRAMtable+$05,y			; |
		STA.w !VRAMtable+$05,y				; |
		STZ.w !VRAMslot					; |
		BIT $02 : BMI +					; > background mode transfers don't store their index
		STY.w !VRAMslot					;/
	+	STZ $0E						;\ clear remaining bytes allowed and return
		BRA ..done					;/
		..ok
		STA $0E						; store remaining transfer size allowed
		LDA.w !VRAMtable+$02,y : %storetohook(0)	; source address
		SEP #$20					;\
		LDA.w !VRAMtable+$04,y : %storetohook(1)	; | source bank
		REP #$20					;/
		LDA $00 : %storetohook(2)			; upload size
		LDA.w !VRAMtable+$05,y : %storetohook(3)	; VRAM address
		LDA #$0000 : STA.w !VRAMtable+$00,y		; clear this slot
		TYA						;\
		CLC : ADC #$0007				; | add 7 to VRAM table index
		TAY						;/
		..done
		TXA
		CLC : ADC $0A
		TAX
		RTS
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendTile
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..size	LDA.w #$0000 : STA $05				; upload size
		LDA.w #!TileUpdateTable+2 : STA $02		; source address
		LDX.b #!VRAMbank : STX $04			; source bank
		STY.w $420B					; DMA toggle
		..end
		%registerhook(..size)
	print "  - Tile               index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1604)				; 4300
		%VideoPort($80)					; 2115
		LDA.w !TileUpdateTable : %storetohook(0)	; upload size
		TXA
		CLC : ADC $0A
		TAX
		RTS
	endif
		!BinaryIndex := !BinaryIndex+1

endmacro


	.AppendSquare
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..src1	LDA.w #$0000 : STA $02				; source address
	..bank1	LDX.b #$00 : STX $04				; source bank
	..vram1	LDA.w #$0000 : STA $2116			; VRAM address
		LDA.w #$0040 : STA $05				; upload size (always 0x0040)
		STY.w $420B					; DMA toggle
		STA $05						; upload size (always 0x0040)
	..src2	LDA.w #$0000 : STA $02				; source address
	..bank2	LDX.b #$00 : STX $04				; source bank
	..vram2	LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
		..end
		%registerhook(..src1)
		%registerhook(..bank1)
		%registerhook(..vram1)
		%registerhook(..src2)
		%registerhook(..bank2)
		%registerhook(..vram2)
	print "  - Square             index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else

	STZ $7FFF


		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		%turbocode(43)					; 46 bytes
		LDA.w !SquareTable+0,y : %storetohook(0)	; source address 1 lo + hi
		CLC : ADC #$0200				;\ source address 2 lo + hi
		%storetohook(3)					;/
		SEP #$20					;\
		LDA.w !SquareTable+2,y				; |
		%storetohook(1)					; | source bank 1 and 2
		%storetohook(4)					; |
		REP #$20					;/
		TYA						;\
		CMP #$0020					; |
		BCC $03 : ADC #$001F				; |
		ASL #3						; | VRAM address 1 and 2
		ORA $00						; | ($00 is set prior to calling this)
		%storetohook(2)					; |
		CLC : ADC #$0100				; |
		%storetohook(5)					;/

		LDA #$0000 : STA.w !SquareTable+0,y		; clear this square

		TXA
		CLC : ADC $0A
		TAX
		RTS
	endif
		!BinaryIndex := !BinaryIndex+1


macro CommentOut2()

	.AppendRow1
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		STZ $04						; bank (always 0x00)
	..vram1	LDA #$0000 : STA $2116				; modify 0A-0B
	..src1	LDA #$6950 : STA $02				; modify 10-11
	..size1	LDA #$0050 : STA $05				; modify 15-16
		STY $420B					;
	..vram2	LDA #$0000 : STA $2116				; modify 1D-1E
	..src2	LDA #$6950 : STA $02				; modify 23-24
	..size2	LDA #$0050 : STA $05				; modify 28-29
		STY $420B					;
	..vram3	LDA #$0000 : STA $2116				; modify 30-31
	..src3	LDA #$6950 : STA $02				; modify 36-37
	..size3	LDA #$0050 : STA $05				; modify 3B-3C
		STY $420B					;
		..end
		%registerhook(..vram1)
		%registerhook(..src1)
		%registerhook(..size1)
		%registerhook(..vram2)
		%registerhook(..src2)
		%registerhook(..size2)
		%registerhook(..vram3)
		%registerhook(..src3)
		%registerhook(..size3)
	print "  - Row1               index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		LDA $0E						;\
		SEC : SBC #$0050				; | update transfer size
		STA $0E						;/
		LDA.l !BG1ZipRowX				;\
		AND #$00F0					; | lowest 5 bits determined by x position (ignore 8px bit)
		LSR #2						; |
		STA $02						; > save this
		LSR A						; |
		STA $00						;/
		LDA.l !BG1ZipRowY				;\
		AND #$00F8					; | following 5 bits determined by y position
		ASL #2						; |
		TSB $00						;/

		LDA $02
		CMP #$0031 : BCS ..three
		JMP ..two

; three:
; row 1: 6950+0, w bytes
; row 2: 6950+w, 64 bytes
; row 3: 6950+w+64, 16-w bytes

; two:
; row 1: 6950+0, w bytes
; row 2: 6950+w, 80-w bytes

		..three
		%turbocode(59)					; 59 bytes
		LDA.l !BG1ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG1Address				; |
		%storetohook(0)					;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%storetohook(3)					;/
		EOR #$0400					;\ row 3
		%storetohook(6)					;/
		LDA $02
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		STA $02
		%storetohook(2)
		LDA #$0040 : %storetohook(5)
		LDA #$0010
		SEC : SBC $02
		%storetohook(8)
		LDA $02
		CLC : ADC #$6950
		%storetohook(4)
		CLC : ADC #$0040
		%storetohook(7)
		TXA
		CLC : ADC $0A
		TAX
		RTS

		..two
		%turbocode(40)					; 40 bytes
		LDA.l !BG1ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG1Address				; |
		%storetohook(0)					;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%storetohook(3)					;/
		LDA $02
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%storetohook(2)					; size of first row (32 - w)
		STA $02
		LDA #$0050
		SEC : SBC $02
		%storetohook(5)					; size of second row (40 - (32 - w))
		LDA $02						;\
		CLC : ADC #$6950				; | source address of second row
		%storetohook(4)					;/
		TXA
		CLC : ADC $0A
		TAX
		RTS
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendRow2
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		STZ $04						; bank (always 0x00)
	..vram1	LDA #$0000 : STA $2116				; modify 0A-0B
	..src1	LDA #$69E0 : STA $02				; modify 10-11
	..size1	LDA #$0050 : STA $05				; modify 15-16
		STY $420B					;
	..vram2	LDA #$0000 : STA $2116				; modify 1D-1E
	..src2	LDA #$69E0 : STA $02				; modify 23-24
	..size2	LDA #$0050 : STA $05				; modify 28-29
		STY $420B					;
	..vram3	LDA #$0000 : STA $2116				; modify 30-31
	..src3	LDA #$69E0 : STA $02				; modify 36-37
	..size3	LDA #$0050 : STA $05				; modify 3B-3C
		STY $420B					;
		..end
		%registerhook(..vram1)
		%registerhook(..src1)
		%registerhook(..size1)
		%registerhook(..vram2)
		%registerhook(..src2)
		%registerhook(..size2)
		%registerhook(..vram3)
		%registerhook(..src3)
		%registerhook(..size3)
	print "  - Row2               index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		LDA $0E						;\
		SEC : SBC #$0050				; | update transfer size
		STA $0E						;/
		LDA.l !BG2ZipRowX				;\
		AND #$00F0					; | lowest 5 bits determined by x position (ignore 8px bit)
		LSR #2						; |
		STA $02						; > save this
		LSR A						; |
		STA $00						;/
		LDA.l !BG2ZipRowY				;\
		AND #$00F8					; | following 5 bits determined by y position
		ASL #2						; |
		TSB $00						;/

		LDA $02
		CMP #$0031 : BCS ..three
		JMP ..two

		..three
		%turbocode(59)					; 59 bytes
		LDA.l !BG2ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG2Address				; |
		%storetohook(0)					;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%storetohook(3)					;/
		EOR #$0400					;\ row 3
		%storetohook(6)					;/
		LDA $02
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		STA $02
		%storetohook(2)
		LDA #$0040 : %storetohook(5)
		LDA #$0010
		SEC : SBC $02
		%storetohook(8)
		LDA $02
		CLC : ADC #$6950
		%storetohook(4)
		CLC : ADC #$0040
		%storetohook(7)
		TXA
		CLC : ADC $0A
		TAX
		RTS

		..two
		%turbocode(40)					; 40 bytes
		LDA.l !BG2ZipRowX				;\
		AND #$0100					; |
		ASL #2						; | determine which tilemap to use
		ORA $00						; |
		ORA.l !BG2Address				; |
		%storetohook(0)					;/
		EOR #$0400					;\
		AND #$FFE0					; | continue into next tilemap
		%storetohook(3)					;/
		LDA $02
		SEC : SBC #$0040
		EOR #$FFFF : INC A
		%storetohook(2)					; size of first row (32 - w)
		STA $02
		LDA #$0050
		SEC : SBC $02
		%storetohook(5)					; size of second row (40 - (32 - w))
		LDA $02						;\
		CLC : ADC #$6950				; | source address of second row
		%storetohook(4)					;/
		TXA
		CLC : ADC $0A
		TAX
		RTS
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendColumn1
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		STZ $04						; bank (always 0x00)
		LDA #$0000 : STA $2116				; modify 0F-10
		LDA #$6910 : STA $02				; modify 15-16
		LDA #$0040 : STA $05				; modify 1A-1B
		STY $420B					;
		LDA #$0000 : STA $2116				; modify 22-23
		LDA #$6910 : STA $02				; modify 28-29
		LDA #$0040 : STA $05				; modify 2D-2E
		STY $420B
		..end
	print "  - Column1            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($81)					; 2115; word columns
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendColumn2
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		STZ $04						; bank (always 0x00)
		LDA #$0000 : STA $2116				; modify 0F-10
		LDA #$69A0 : STA $02				; modify 15-16
		LDA #$0040 : STA $05				; modify 1A-1B
		STY $420B					;
		LDA #$0000 : STA $2116				; modify 22-23
		LDA #$69A0 : STA $02				; modify 28-29
		LDA #$0040 : STA $05				; modify 2D-2E
		STY $420B
		..end
	print "  - Column2            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($81)					; 2115: word columns
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendBackground
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		LDX.b #!BG2Tilemap>>16 : STX $04
		LDA #$0000 : STA $2116				; modify 0A-0B
		LDA #$0000 : STA $02				; modify 10-11
		LDA #$0040 : STA $05
		STY $420B
		LDA #$0000 : STA $2116				; modify 1D-1E
		LDA #$0000 : STA $02				; modify 23-24
		LDA #$0040 : STA $05
		STY $420B
		..end
	print "  - Background         index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendPalette
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		LDA #$0000 : STA $02				; 05-09
		LDX #$00 : STX $04				; 0A-0D
		LDA #$0000 : STA $05				; 0E-12
		LDX #$00 : STX $2121				; 13-16
		STY $420B					; 17-19
		..end
	print "  - Palette            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($2202)				; 4300
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendSMWPalette
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		..end
	print "  - SMWPalette         index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)

	else
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendLight
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		; ?????????????????????????????????????????????
		..end
	print "  - Light              index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)

	else
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendSMW0D7C
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..bank	LDX #$00 : STX $04				; bank
	..VRAM1	LDA #$0000 : STA $2116				;\
	..src1	LDA #$0000 : STA $02				; | 0x80 bytes from $6D76 -> $6D7C
	..size	LDA #$0080 : STA $05				; |
		STY $420B					;/
		..end2
	..VRAM2	LDA #$0000 : STA $2116				;\
	..src2	LDA #$0000 : STA $02				; | special case: when $6D7C = 0x0800, it is split into upper/lower half
		LDA #$0040 : STA $05				; | when this happens, also update color 0x64
		STY $420B					;/
		..end
	print "  - SMW0D7C            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendSMW0D7E
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..bank	LDX #$00 : STX $04				; bank
	..VRAM	LDA #$0000 : STA $2116				;\
	..src	LDA #$0000 : STA $02				; | 0x80 bytes from $6D78 -> $6D7E
		LDA #$0080 : STA $05				; |
		STY $420B					;/
		..end
	print "  - SMW0D7E            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendSMW0D80
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..bank	LDX #$00 : STX $04				; bank
	..VRAM	LDA #$0000 : STA $2116				;\
	..src	LDA #$0000 : STA $02				; | 0x80 bytes from $6D7A -> $6D80
		LDA #$0080 : STA $05				; |
		STY $420B					;/
		..end
	print "  - SMW0D80            index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendMario
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
	..bank	LDX #$00 : STX $04				; source bank
	..VRAM1	LDA #$0000 : STA $2116				; this applies for the next 4 transfers (!MarioGFX1)
	..src1	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D85 -> !MarioGFX1
		STY $420B					;/
	..src2	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D87 -> !MarioGFX1 + 0x40
		STY $420B					;/
	..src3	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D89 -> !MarioGFX1 + 0x80
		STY $420B					;/
	..VRAM2	LDA #$0000 : STA $2116				; this applies for the next 3 transfers (!MarioGFX2)
	..src4	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D8F -> !MarioGFX1
		STY $420B					;/
	..src5	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D91 -> !MarioGFX1 + 0x40
		STY $420B					;/
	..src6	LDA #$0000 : STA $02				;\
		LDA #$0040 : STA $05				; | $6D93 -> !MarioGFX1 + 0x80
		STY $420B					;/
		..end
	print "  - Mario              index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendExAnimationGFX
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		LDA.w #$0000 : STA $02				; source address
		LDX.b #$00 : STX $04				; source bank
		LDA.w #$0000 : STA $05				; upload size
		LDA.w #$0000 : STA $2116			; VRAM address
		STY.w $420B					; DMA toggle
		..end2
	; this section only used for square row 2
		LDA.w #$0000 : STA $02				; address (DMA settings + bank are the same)
		LDA.w #$0000 : STA $05				; upload size
		LDA.w #$0000 : STA $2116			; reset address (1 row below so can't use continuous)
		STY.w $420B					; DMA toggle
		..end
	print "  - ExAnimationGFX     index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($1801)				; 4300
		%VideoPort($80)					; 2115
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


	.AppendExAnimationPalette
	if !CompileBinary = 1
		!Temp = 0
		!HooksRegistered = 0
		..code
		LDA.w #$0000 : STA $02				; source address
		LDX.b #$00 : STX $04				; source bank
		LDA.w #$0000 : STA $05				; upload size
		LDX.b #$00 : STX $2121				; CGRAM address
		STY.w $420B					; DMA toggle
		..end
	print "  - ExAnimationPalette index $", hex(!BinaryIndex, 2), ", addr $", hex(..code, 4), ", size ", dec(..end-..code, 2), ", hooks ", dec(!HooksRegistered)
	else
		%DMAsettings($2202)				; 4300
		; insert data here
		TXA
		CLC : ADC $0A
		TAX
	endif
		!BinaryIndex := !BinaryIndex+1


endmacro


	if !CompileBinary = 1
	print " "
	print "  Total hooks registered: ", dec(!TotalHooksRegistered)
	print " "
	endif




