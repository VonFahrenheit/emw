



; TM format:
;	4 byte header, Y origin (first word) + byte count of tile data (second word)
;	OAM data, 5 bytes per tile (X, Y, T, P, hi byte)
; (total 5 bytes per tile + 4 bytes for header)
;
; note that Y origin is in map coords, not on-screen coords


; $00	current highest Y origin
; $02	index of current highest Y origin
; $04	pointer to OAM data
; $06	byte count of OAM data at pointer



	Sort_OAM:
		LDA !MapOAMcount : BNE .Process			;\ check if there's anything to sort
		RTS						;/

		.Process					;\ setup
		LDA !OAMindex_p2 : TAX				;/

		.FindHighest					;\
		LDY #$0000					; | start from the top with highest Y = 0
		STZ $00						;/
		..loop						;\
		LDA !MapOAMdata+0,y : BMI ..nothighest		; |
		CMP $00 : BCC ..nothighest			; |
		..newhighest					; | check for new highest Y
		STA $00						; |
		STY $02						; |
		..nothighest					;/
		TYA						;\
		CLC : ADC !MapOAMdata+2,y			; |
		CLC : ADC #$0004				; | loop through all the data to make sure we have the highest number
		TAY						; |
		CPY !MapOAMindex : BCC ..loop			;/

		; here we know that we have the highest one


		.Draw						;\
		LDY $02						; |
		LDA !MapOAMdata+2,y : STA $06			; | pointer + index cutoff
		LDA $02						; |
		CLC : ADC.w #!MapOAMdata+4			; |
		STA $04						;/
		LDA #$FFFF : STA !MapOAMdata+0,y		; delete this map
		LDY #$0000					; Y = 0x0000

		..loop						;\
		LDA ($04),y : STA !OAM_p2+$000,x		; |
		INY #2						; | copy X, Y, T and P
		LDA ($04),y : STA !OAM_p2+$002,x		; |
		INY #2						;/
		TXA						;\
		LSR #2						; |
		TAX						; |
		SEP #$20					; | copy hi byte
		LDA ($04),y : STA !OAMhi_p2,x			; |
		REP #$20					; |
		INY						;/
		INX						;\
		TXA						; |
		ASL #2						; | increment OAM index and loop
		TAX						; |
		CPX #$0200 : BCS ..done				; > break if hitting index 0x200+
		CPY $06 : BCC ..loop				;/

		DEC !MapOAMcount : BEQ ..done			;\
		JMP .FindHighest				; | loop to find new highest until all tilemaps are sorted
		..done						;/
		TXA : STA !OAMindex_p2				; store new OAM index
		RTS						; return













