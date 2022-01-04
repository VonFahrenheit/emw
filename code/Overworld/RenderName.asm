


; GFX_buffer:
;	$0000-$1FFF: cached font in 4bpp linear format
;	$1800-$1BFF: rendering area (overwrites part of the cached font)



; $00	24-bit pointer to source data (LM level name)
; $03	24-bit pointer to font data (not GFX)
; $06	16-bit source index
; $08	16-bit rendering index
; $0A	current width of actual text
; $0C	----
; $0E	----
; $0F	8-bit width of character


	!NameBuffer	= !V_buffer+($1800*2)

	macro rendername(offset)
		LDA.w !V_buffer+(<offset>*$80),y : BEQ ?Next
	?3:	STX $0A
		LDA.w !NameBuffer+(<offset>*$80)+$181,x : BNE +
		LDA #$0B : STA.w !NameBuffer+(<offset>*$80)+$181,x
		+
		LDA.w !NameBuffer+(<offset>*$80)+$200,x : BNE +
		LDA #$0B : STA.w !NameBuffer+(<offset>*$80)+$200,x
		+
		LDA.w !NameBuffer+(<offset>*$80)+$202,x : BNE +
		LDA #$0B : STA.w !NameBuffer+(<offset>*$80)+$202,x
		+
		LDA.w !NameBuffer+(<offset>*$80)+$281,x : BNE +
		LDA #$0B : STA.w !NameBuffer+(<offset>*$80)+$281,x
		+
		LDA #$03
	?W:	STA.w !NameBuffer+(<offset>*$80)+$201,x
	?Next:
	endmacro



	RenderName:
		PHB							;\ wrapper start
		PHP							;/
		REP #$30						; all regs 16-bit

		.DrawYoshiCoins
		LDA !CharMenu
		AND #$00FF : BNE +
		LDA !Translevel
		AND #$00FF : BNE ..draw
	+	JMP ..nolevel

		..draw
		TAY
		TYX
		LDA #$9C6A : STA $00
		LDA.l $188000,x
		AND #$00FF
		STA $06
		BEQ +
		LDA $00
		SEC : SBC #$0016
		STA $00
	+	LDA !OAMindex_p3 : TAX
		..megaloop
		LDA !LevelTable1,y : STA $02
		LDY #$0004
		..loop
		LSR $02 : BCC ..noYC
		..YC
		LDA #$3E8F : STA !OAM_p3+$002,x
		LDA $00
		CLC : ADC #$0800
		STA !OAM_p3+$000,x
		TXA
		LSR #2
		TAX
		LDA #$0000 : STA !OAMhi_p3,x
		TXA
		INC A
		ASL #2
		TAX
		LDA #$3E8E : BRA ..shared
		..noYC
		LDA #$3E8D
		..shared
		STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		CLC : ADC #$0009
		STA $00
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA #$00 : STA !OAMhi_p3,x
		REP #$20
		INX
		TXA
		ASL #2
		TAX
		DEY : BPL ..loop
		LDA $06 : BEQ ..done
		STZ $06
		TAY
		BRA ..megaloop
		..done
		TXA : STA !OAMindex_p3
		..nolevel


		.DrawTime
		LDA !CharMenu
		AND #$00FF : BNE +
		LDY !Translevel : BNE ..time
	+
	-	JMP ..notime
		..time
		LDA !Difficulty
		AND.w #!TimeMode : BEQ -
		LDA #$A964 : STA $00

		LDA !OAMindex_p3 : TAX			; X = OAM index
		LDA $00					;\
		SEC : SBC #$0010			; | clock symbol
		STA !OAM_p3+$000,x			; |
		LDA #$3E8C : STA !OAM_p3+$002,x		;/
		LDA $00					;\
		CLC : ADC #$0010			; | colon
		STA !OAM_p3+$004,x			; |
		LDA #$3E8A : STA !OAM_p3+$006,x		;/
		LDA $00					;\
		CLC : ADC #$0028			; | period
		STA !OAM_p3+$008,x			; |
		LDA #$3E8B : STA !OAM_p3+$00A,x		;/
		TXA
		CLC : ADC #$000C
		STA !OAMindex_p3
		TXA
		LSR #2
		TAX
		LDA #$0000
		STA !OAMhi_p3+$00,x
		STA !OAMhi_p3+$02,x
		STA !OAMhi_p3+$04,x
		STA !OAMhi_p3+$06,x
		STA !OAMhi_p3+$08,x
		STA !OAMhi_p3+$09,x


		LDX #$0000
		LDA !LevelTable5,y
		AND #$003F
	-	CMP #$000A : BCC +
		SBC #$000A
		INX
		BRA -
	+	STA $0A
		TXA : JSR .DrawTimeDigit
		LDA $0A : JSR .DrawTimeDigit
		LDA $00
		CLC : ADC #$0008
		STA $00
		LDX #$0000
		LDA !LevelTable4,y
		AND #$003F
	-	CMP #$000A : BCC +
		SBC #$000A
		INX
		BRA -
	+	STA $0A
		TXA : JSR .DrawTimeDigit
		LDA $0A : JSR .DrawTimeDigit
		LDA $00
		CLC : ADC #$0008
		STA $00
		LDA !LevelTable3,y
		AND #$003F
		ASL #2
		TAY
		LDA FrameDigits+1,y : STA $0A			; stored backwards
		LDA FrameDigits+0,y
		AND #$000F
		JSR .DrawTimeDigit
		LDA $0A
		AND #$000F
		JSR .DrawTimeDigit
		LDA $0B
		AND #$000F
		JSR .DrawTimeDigit
		..notime





		.Main
		STZ $2250						;\
		LDA !Translevel						; |
		AND #$00FF : STA $2251					; |
		LDA #$0013 : STA $2253					; | pointer to source data (!Translevel * $13 + $03BB57)
		LDA.l $03BB57+2 : STA $02				; |
		LDA.l $03BB57+0						; |
		CLC : ADC $2306						; |
		STA $00							;/

		LDA.w #!TextFontData
		CLC : ADC.w #read2(!TextFontData+2)
		STA $03							;\ pointer to font data
		LDA.w #!TextFontData>>16 :  STA $05			;/
		STZ $06							; starting read index
		STZ $08							; starting rendering index
		SEP #$20						; A 8-bit
		STZ $223F						; 4bpp

		LDA.b #!GFX_buffer>>16					;\
		PHA : PLB						; |
		REP #$30						; |
		LDY #$03FE						; | clear rendering buffer
		LDA #$0000						; |
	-	STA.w !GFX_buffer+$1800,y				; |
		DEY #2 : BPL -						;/
		SEP #$20						; A 8-bit
		LDA.b #!V_buffer>>16					;\ go into bank 0x60
		PHA : PLB						;/
		LDA.l !CharMenu : BNE ..return
		LDA.l !Translevel : BEQ ..return			; blank if not on a level
		CMP.l !PrevTranslevel : BEQ ..drawtext
		STA.l !PrevTranslevel
		JMP .Render

		..return
		PLP
		PLB
		RTS


		..drawtext
		PHK : PLB
		REP #$30
		LDA !OAMindex_p3 : TAX
		LDA !MapLevelNameWidth
		LSR A
		EOR #$FFFF : INC A
		CLC : ADC #$8C80
		STA !OAM_p3+$000,x
		CLC : ADC #$0010
		STA !OAM_p3+$004,x
		CLC : ADC #$0010
		STA !OAM_p3+$008,x
		CLC : ADC #$0010
		STA !OAM_p3+$00C,x
		CLC : ADC #$0010
		STA !OAM_p3+$010,x
		CLC : ADC #$0010
		STA !OAM_p3+$014,x
		CLC : ADC #$0010
		STA !OAM_p3+$018,x
		CLC : ADC #$0010
		STA !OAM_p3+$01C,x

		LDA #$3E60 : STA !OAM_p3+$002,x
		LDA #$3E62 : STA !OAM_p3+$006,x
		LDA #$3E64 : STA !OAM_p3+$00A,x
		LDA #$3E66 : STA !OAM_p3+$00E,x
		LDA #$3E68 : STA !OAM_p3+$012,x
		LDA #$3E6A : STA !OAM_p3+$016,x
		LDA #$3E6C : STA !OAM_p3+$01A,x
		LDA #$3E6E : STA !OAM_p3+$01E,x

		TXA
		LSR #2
		TAX
		LDA #$0202
		STA !OAMhi_p3+$00,x
		STA !OAMhi_p3+$02,x
		STA !OAMhi_p3+$04,x
		STA !OAMhi_p3+$06,x
		LDA !OAMindex_p3
		CLC : ADC #$0020
		STA !OAMindex_p3
		PLP
		PLB
		RTS


		.Render
		..loop
		REP #$20
		LDY $06
		..readnext
		LDA [$00],y
		INY
		STY $06
		CPY #$0014 : BCS +
		AND #$00FF
		TAX
		LDA.l ConversionTable,x
		AND #$00FF
		CMP #$007F : BEQ ..space
		CMP #$00FF : BNE ..rendertext
	+	JMP ..endmessage

		..space
		LDA $08							;\
		CLC : ADC #$0006					; | add 6 to X
		STA $08							;/
		BRA ..readnext						; go to next

		..rendertext
		ASL A							;\
		TAY							; |
		LDA [$03],y : STA $0E					; |
		AND #$000F						; |
		ASL #3							; | Y = index to character in cached font
		STA $0C							; | ($0F = width of character)
		LDA $0E							; |
		AND #$00F0						; |
		XBA							; |
		LSR #2							; |
		ORA $0C							; |
		TAY							;/

		LDX $08							;\ reg setup for render
		SEP #$20						;/
		LDA $08							;\
		CLC : ADC $0F						; |
		CMP #$81 : BCC ..nextcolumn				; |
		SBC #$80						; | check for limit of rendering area
		SBC $0F							; |
		EOR #$FF : INC A					; |
		STA $0F							;/

		..nextcolumn						;\
		%rendername(0)						; |
		%rendername(1)						; |
		%rendername(2)						; |
		%rendername(3)						; |
		%rendername(4)						; |
		%rendername(5)						; | render character
		%rendername(6)						; |
		%rendername(7)						; |
		%rendername(8)						; |
		INX							; |
		INY							; |
		DEC $0F : BEQ $03 : JMP ..nextcolumn			;/
		STX $08							; store new rendering index
		CPX #$0080 : BCS ..endmessage				; end at limit
		JMP ..loop						; go to loop

		..endmessage
		LDA $0A : STA.l !MapLevelNameWidth
		SEP #$30
		LDA #$40 : PHA : PLB

		JSL !GetBigCCDMA					; X = index to CCDMA table
		LDA #$11 : STA !CCDMAtable+$07,x			; > width = 128px, bit depth = 4bpp
		LDA.b #!GFX_buffer>>16 : STA !CCDMAtable+$04,x		;\
		REP #$20						; | source adddress
		LDA.w #!GFX_buffer+$1800 : STA !CCDMAtable+$02,x	;/
		LDA #$0200 : STA !CCDMAtable+$00,x			; upload size
		LDA #$6600 : STA !CCDMAtable+$05,x			; dest VRAM
		SEP #$20
		JSL !GetBigCCDMA					; X = index to CCDMA table
		LDA #$11 : STA !CCDMAtable+$07,x			; > width = 128px, bit depth = 4bpp
		LDA.b #!GFX_buffer>>16 : STA !CCDMAtable+$04,x		;\
		REP #$20						; | source adddress
		LDA.w #!GFX_buffer+$1A00 : STA !CCDMAtable+$02,x	;/
		LDA #$0200 : STA !CCDMAtable+$00,x			; upload size
		LDA #$6700 : STA !CCDMAtable+$05,x			; dest VRAM

		PLP							;\ wrapper end
		PLB							;/
		RTS							; return



		.Cache
		PHB : PHK : PLB						;\ wrapper start
		PHP							;/
		REP #$30						;\
		LDY.w #read2(!TextFontGFX+2)				; | get font address
		JSL !GetFileAddress					;/
		SEP #$20						; A 8-bit
		STZ $223F						; 4bpp
		LDA.b #!V_cache>>16					;\ bank 0x60
		PHA : PLB						;/
		REP #$20						;\
		LDA !FileAddress+0 : STA $00				; |
		LDA !FileAddress+1 : STA $01				; | setup
		LDX #$0000						; |
		LDY #$0000						;/
		..loop							;\
		LDA [$00],y : STA $0E					; |
		AND #$0003 : STA.w !V_buffer+$00,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$01,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$02,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$03,x			; |
		LDA $0E							; |
		LSR #2							; | packed 2bpp linear -> unpacked 4bpp linear
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$04,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$05,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$06,x			; |
		LDA $0E							; |
		LSR #2							; |
		STA $0E							; |
		AND #$0003 : STA.w !V_buffer+$07,x			; |
		INY #2							; |
		TXA							; |
		CLC : ADC #$0008					; |
		TAX							; |
		CPY #$1000 : BCC ..loop					;/
		PLP							;\ wrapper end
		PLB							;/
		RTL							; return

	.DrawTimeDigit
		; A = digit
		PHA
		LDA !OAMindex_p3 : TAX
		PLA
		CLC : ADC #$3E80
		STA !OAM_p3+$002,x
		LDA $00 : STA !OAM_p3+$000,x
		CLC : ADC #$0008
		STA $00
		TXA
		CLC : ADC #$0004
		STA !OAMindex_p3
		RTS



	cleartable
	table ../MSG/MessageTable.txt
	ConversionTable:
		db "ABCDEFGHIJKLMNOP"
		db "QRSTUVWXYZ!.-,? "
		db "                "
		db "            :+> "
		db "abcdefghijklmnop"
		db "qrstuvwxyz#()'* "
		db "    12345670    "

	Width:
		db $07	; 0
		db $05	; 1
		db $07	; 2
		db $07	; 3
		db $06	; 4
		db $07	; 5
		db $07	; 6
		db $07	; 7
		db $07	; 8
		db $07	; 9


	FrameDigits:
		db 0,0,0	: db $00	; 0 frames
		db 0,1,7	: db $00	; 1 frame
		db 0,3,3	: db $00	; 2 frames
		db 0,5,0	: db $00	; 3 frames
		db 0,6,7	: db $00	; 4 frames
		db 0,8,3	: db $00	; 5 frames

		db 1,0,0	: db $00	; 6 frames
		db 1,1,7	: db $00	; 7 frames
		db 1,3,3	: db $00	; 8 frames
		db 1,5,0	: db $00	; 9 frames
		db 1,6,7	: db $00	; 10 frames
		db 1,8,3	: db $00	; 11 frames

		db 2,0,0	: db $00	; 12 frames
		db 2,1,7	: db $00	; 13 frames
		db 2,3,3	: db $00	; 14 frames
		db 2,5,0	: db $00	; 15 frames
		db 2,6,7	: db $00	; 16 frames
		db 2,8,3	: db $00	; 17 frames

		db 3,0,0	: db $00	; 18 frames
		db 3,1,7	: db $00	; 19 frames
		db 3,3,3	: db $00	; 20 frames
		db 3,5,0	: db $00	; 21 frames
		db 3,6,7	: db $00	; 22 frames
		db 3,8,3	: db $00	; 23 frames

		db 4,0,0	: db $00	; 24 frames
		db 4,1,7	: db $00	; 25 frames
		db 4,3,3	: db $00	; 26 frames
		db 4,5,0	: db $00	; 27 frames
		db 4,6,7	: db $00	; 28 frames
		db 4,8,3	: db $00	; 29 frames

		db 5,0,0	: db $00	; 30 frames
		db 5,1,7	: db $00	; 31 frames
		db 5,3,3	: db $00	; 32 frames
		db 5,5,0	: db $00	; 33 frames
		db 5,6,7	: db $00	; 34 frames
		db 5,8,3	: db $00	; 35 frames

		db 6,0,0	: db $00	; 36 frames
		db 6,1,7	: db $00	; 37 frames
		db 6,3,3	: db $00	; 38 frames
		db 6,5,0	: db $00	; 39 frames
		db 6,6,7	: db $00	; 40 frames
		db 6,8,3	: db $00	; 41 frames

		db 7,0,0	: db $00	; 42 frames
		db 7,1,7	: db $00	; 43 frames
		db 7,3,3	: db $00	; 44 frames
		db 7,5,0	: db $00	; 45 frames
		db 7,6,7	: db $00	; 46 frames
		db 7,8,3	: db $00	; 47 frames

		db 8,0,0	: db $00	; 48 frames
		db 8,1,7	: db $00	; 49 frames
		db 8,3,3	: db $00	; 50 frames
		db 8,5,0	: db $00	; 51 frames
		db 8,6,7	: db $00	; 52 frames
		db 8,8,3	: db $00	; 53 frames

		db 9,0,0	: db $00	; 54 frames
		db 9,1,7	: db $00	; 55 frames
		db 9,3,3	: db $00	; 56 frames
		db 9,5,0	: db $00	; 57 frames
		db 9,6,7	: db $00	; 58 frames
		db 9,8,3	: db $00	; 59 frames












