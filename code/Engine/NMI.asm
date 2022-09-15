


macro CCDMA(slot)
	LDY $97+(<slot>*8) : STY.w $2231	; CCDMA mode
	LDA $92+(<slot>*8)			;\
	STA.w $2232				; | source address
	STA.w $4302				;/
	LDY $94+(<slot>*8)			;\
	STY.w $2234				; | source bank
	STY.w $4304				;/
	LDA #$3700 : STA.w $2235		; buffer address
	CLI					;\
?Sync:	LDY $8D : BEQ ?Sync			; | sync with SA-1 CPU
	LDY #$00 : STY $8D			; |
	SEI					;/
	LDA $90+(<slot>*8) : STA.w $4305	; upload size
	LDA $95+(<slot>*8) : STA.w $2116	; VRAM address
	LDY #$01 : STY.w $420B			; execute CCDMA
	DEX : BNE ?Next				;\ check remaining slots
	JMP ..end				;/
	?Next:
endmacro




	NMI:
		PHP					;\
		REP #$30				; |
		PHA					; |
		PHX					; | push everything
		PHY					; |
		PHB					; |
		PHD					;/


	; initialize NMI
		PHK : PLB				; set bank
		SEP #$10				; all regs 8-bit
		LDX $4210				; clear NMI flag
		LDX #$80 : STX $2100			; enable f-blank
		STZ $420B				; disable DMA + HDMA (DMA doesn't matter, but we're in 16-bit A and don't want to touch $420D)
		INC !MPU_NMI				; set NMI flag for SA-1


	; direct color update
		LDA !2132_RGB
		ASL #3
		SEP #$21
		ROR #3
		XBA
		ORA #$40
		STA $2132
		LDA !2132_RGB+1
		LSR A
		SEC : ROR A
		STA $2132
		XBA
		STA $2132

	; color 0 update
		STZ $2121
		LDA !Color0 : STA $2122
		LDA !Color0+1 : STA $2122


	; check lag
		LDA $3010 : BEQ .NoLag			; DP is undefined currently, so we need to use 16-bit address
		PEA $3000 : PLD				; DP = $3000
		LDA !2105 : STA $2105			;\
		LDA !2109 : STA $2109			; |
		LDA $22 : STA $2111			; |
		LDA $23 : STA $2111			; |
		LDA $24 : STA $2112			; |
		LDA $25 : STA $2112			; | just update these regs on lag frames
		LDA !2124 : STA $2124			; | (these are changed during status bar IRQ so they have to be updated every v-blank)
		LDA !MainScreen				; |
		STA $212C				; |
		STA $212E				; |
		LDA !2130 : STA $2130			; |
		LDA !2131 : STA $2131			;/
		STZ $4304				; bank 00
		REP #$20				;\
		LDA #$2202 : STA $4300			; |
		LDA #$00A0 : STA $4302			; |
		LDA #$000E : STA $4305			; | upload dynamic BG3 color
		LDY #$01				; |
		STY $2121				; |
		STY $420B				;/
		JMP .Lag				; skip most of NMI on lag frames
		.NoLag


		REP #$20				; A 16-bit
		LDY #$01				;\ setup: Y = 01, DP = $4300
		LDA #$4300 : TCD			;/

	; OAM update
		STZ $00					;\
		STZ $2102				; |
		LDA #$0004 : STA $01			; | $6200 -> OAM
		LDA #$0062 : STA $03			; |
		LDA #$0220 : STA $05			; |
		STY $420B				;/


	; HDMA update
		LDX !MsgTrigger : BNE +			; > let message boxes use indirect mode
		LDX !GameMode				;\
		CPX #$03 : BCC .NoRAMcode		; | presents screen has no HDMA or dynamic BG3
		CPX #$0B : BCC +			;/
		LDA !HDMA2source : STA $22		;\
	+	LDA !HDMA3source : STA $32		; |
		LDA !HDMA4source : STA $42		; | HDMA source mirrors to prevent tearing
		LDA !HDMA5source : STA $52		; |
		LDA !HDMA6source : STA $62		; |
		LDA !HDMA7source : STA $72		;/
		STZ $04					; bank 00
		LDA #$2202 : STA $00			;\
		LDA #$00A0 : STA $02			; |
		LDA #$000E : STA $05			; | upload dynamic BG3 color
		STY $2121				; |
		STY $420B				;/

	; RAM code (requires DP = $4300)
		LDA !RAMcode_flag
		CMP #$1234 : BNE .NoRAMcode
		JSL !RAMcode
		STZ !RAMcode_flag
		STZ !RAMcode_offset
	.NoRAMcode
		LDA #$3000 : TCD			; DP = $3000


		SEP #$20


		INC $10					; set processing frame flag (anywhere in .NoLag where DP = $3000 and A is 8-bit will do)


	; misc registers
		REP #$10				; 16-bit index
		TSX					;\ preserve stack in Y
		TXY					;/
		LDX #$2131 : TXS			; S = $2131
		LDA !2131 : PHA				; 2131
		LDA !2130 : PHA				; 2130
		LDA !SubScreen				;\
		PHA					; | !SubScreen -> 212D and 212F
		STA $212D				;/
		LDA !MainScreen				;\
		PHA					; | !MainScreen -> 212C and 212E
		STA $212C				;/

		; S = 212D
		; 212A-212B: window combination logic, left at 0000 (OR)

		LDX #$2125 : TXS			; this is actually faster than LDA dp : STA addr x3
		LDA !2125 : PHA				; 2125
		PEI (!2123)				; 2123-2124 (stored next to each other)


		.Mode7
		LDA !Mode7Settings			;\ skip mode 7 if disabled
		BIT #$08 : BEQ ..skip			;/
		AND #$C3 : STA $211A			; $211A: mode 7 settings (hardware bits only)
		LDX #$2120 : TXS			; S = $2120
		LDA !Mode7CenterY : PHA			;\ $2120: mode 7 center Y
		LDA !Mode7CenterY+1 : STA $2120		;/
		LDA !Mode7CenterX : PHA			;\ $211F: mode 7 center X
		LDA !Mode7CenterX+1 : STA $211F		;/
		LDA !Mode7MatrixD : PHA			;\ $211E: mode 7 matrix D
		LDA !Mode7MatrixD+1 : STA $211E		;/
		LDA !Mode7MatrixC : PHA			;\ $211D: mode 7 matrix C
		LDA !Mode7MatrixC+1 : STA $211D		;/
		LDA !Mode7MatrixB : PHA			;\ $211C: mode 7 matrix B
		LDA !Mode7MatrixB+1 : STA $211C		;/
		LDA !Mode7MatrixA : PHA			;\ $211B: mode 7 matrix A
		LDA !Mode7MatrixA+1 : STA $211B		;/
		LDX #$210E : TXS			; S = $210E
		LDA !Mode7Y : PHA			;\ $210E: mode 7 Y position
		LDA !Mode7Y+1 : STA $210E		;/
		LDA !Mode7X : PHA			;\ $210D: mode 7 X position
		LDA !Mode7X+1 : STA $210D		;/
		BRA .NormalMode_done			; go to $210C write area (S = $210C after these writes)
		..skip


		.NormalMode
		LDX #$2114 : TXS			; S = $2114
		STZ $2114				;\
		PEA $0000				; | 2113: BG4 horizontal scroll and 2114: BG4 vertical scroll both = 00
		STZ $2113				;/
		LDA $24 : PHA				;\ 2112: BG3 vertical scroll
		LDA $25 : STA $2112			;/
		LDA $22 : PHA				;\ 2111: BG3 horizontal scroll
		LDA $23 : STA $2111			;/
		LDA $20 : PHA				;\ 2110: BG2 vertical scroll
		LDA $21 : STA $2110			;/
		LDA $1E : PHA				;\ 210F: BG2 horizontal scroll
		LDA $1F : STA $210F			;/
		LDA $1C					;\
		CLC : ADC $7888				; |
		PHA					; | 210E: BG1 vertical scroll
		LDA $1D					; |
		ADC $7889				; |
		STA $210E				;/
		LDA $1A : PHA				;\ 210D: BG1 horizontal scroll
		LDA $1B : STA $210D			;/
		..done


		LDA !210C : PHA				; 210C: BG3 and BG4 chr address
		PEA $0000				; 210A: BG4 tilemap address and 210B: BG1 and BG2 chr address both = 00
		LDA !2109 : PHA				; 2109: BG3 tilemap address
		LDA !2108 : PHA				; 2108: BG2 tilemap address
		LDA !2107 : PHA				; 2107: BG1 tilemap address
		LDA !2106 : PHA				; 2106: mosaic
		LDA !2105 : PHA				; 2105: screen mode
		LDA #$80 : STA $2103			; 2103: OAM priority bit
		LDA !2102 : STA $2102			; 2102: OAM address

		TYX					;\ restore stack pointer from Y
		TXS					;/
		SEP #$10				; index 8-bit



	; CCDMA
		.CCDMA
		REP #$20
		LDX.w $317F : BNE ..run
		JMP ..done
		..run
		LDA #$3100 : TCD			; DP = $3100
		LDA #$1801 : STA.w $4300		;\
		LDY #$81 : STY.w $2200			; | prepare DMA
		DEY					; |
		STY.w $2115				;/
	-	LDY $8D : BEQ -				;\ wait for SA-1 CPU to get ready
		LDY #$00 : STY $8D			;/
		%CCDMA(0)				;\
		%CCDMA(1)				; |
		%CCDMA(2)				; |
		%CCDMA(3)				; |
		%CCDMA(4)				; | execute CCDMA
		%CCDMA(5)				; |
		%CCDMA(6)				; |
		%CCDMA(7)				; |
		%CCDMA(8)				; |
		%CCDMA(9)				;/
		..end					; this label is used by the macros
		LDY #$80 : STY.w $2231			;\ end CCDMA
		LDY #$82 : STY.w $2200			;/
		LDY #$00 : STY $7F			; > clear upload count
		LDA #$3000 : TCD			; DP = $3000
		..done


		.Lag
		SEP #$30				; all regs 8-bit

	; finish v-blank
		LDY #$D6				;\
		LDA $4211				; | set IRQ scanline
		STY $4209				; |
		STZ $420A				;/
		STZ $11					; clear IRQ counter (probably unused, but for safety...)
		LDA #$A1 : STA $4200			; enable NMI + controller
		LDA !2100 : STA $2100			; set screen brightness
		LDA $1F0C : STA $420C			; this is double-mirrored to prevent oddities on lag frames



; now we move on to stuff that can be done outside of v-blank but still has to be PPU-synced

		INC $13					; increment real-time frame counter


		.Playtime				;\
		LDA !GameMode				; | increment playtime counter on game modes 0x0B and up
		CMP #$0B : BCC ..done			;/
		LDA !Playtime+0				;\
		INC A					; |
		CMP.b #60				; | frame counter
		BCC $02 : LDA #$00			; |
		STA !Playtime+0				; |
		BNE ..done				;/
		LDA !Playtime+1				;\
		INC A					; |
		CMP.b #60				; | second counter
		BCC $02 : LDA #$00			; |
		STA !Playtime+1				; |
		BNE ..done				;/
		LDA !Playtime+2				;\
		INC A					; |
		CMP.b #60				; | minute counter
		BCC $02 : LDA #$00			; |
		STA !Playtime+2				; |
		BNE ..done				;/
		REP #$20				;\
		LDA !Playtime+3				; |
		INC A					; |
		CMP.w #999				; | hour counter
		BCC $03 : LDA.w #999			; |
		STA !Playtime+3				; |
		SEP #$20				; |
		..done					;/



; controllers have to be last since they change DP
;
; 4218
;	-> $A2 (hold)
; 4219
;	-> $A4 (hold)
; 4218 ^ $A2 & 4218
;	-> $A6 (press)
; 4219 ^ $A4 & 4219
;	-> $A8 (press)
; 421A
;	-> $A3 (hold)
; 421B
;	-> $A5 (hold)
; 421A ^ $A3 & 421A
;	-> $A7 (press)
; 421B ^ $A5 & 421B
;	-> $A9 (press)

		.Joypads
		PEA $6D00 : PLD				; DP optimization
		LDA $309D : BEQ ..load
		..buffer
		LDA $AA : TRB $A8			;\
		LDA $AB : TRB $A6			; |
		LDA $AC : TRB $A9			; |
		LDA $AD : TRB $A7			; | clear press input from before buffer
		STZ $AA					; |
		STZ $AB					; |
		STZ $AC					; |
		STZ $AD					;/
		LDA $4218				;\
		EOR $A4					; |
		AND $4218				; |
		AND #$F0 : TSB $A8			; |
		LDA $4218				; |
		AND #$F0 : TSB $A4			; | buffer joypad 1
		LDA $4219				; |
		EOR $A2					; |
		AND $4219				; |
		TSB $A6					; |
		LDA $4219 : TSB $A2			;/
		LDA $421A				;\
		EOR $A5					; |
		AND $421A				; |
		AND #$F0 : TSB $A9			; |
		LDA $421A				; |
		AND #$F0 : TSB $A5			; | buffer joypad 2
		LDA $421B				; |
		EOR $A3					; |
		AND $421B				; |
		TSB $A7					; |
		LDA $421B : TSB $A3			;/
		BRA ..done				; go to build mario joypad
		..load
		LDA $4218				;\
		EOR $A4					; |
		AND $4218				; |
		AND #$F0 : STA $A8 : STA $AA		; > press flags in case buffer mode turns on
		LDA $4218				; |
		AND #$F0 : STA $A4			; | load joypad 1
		LDA $4219				; |
		EOR $A2					; |
		AND $4219				; |
		STA $A6 : STA $AB			; > press flags in case buffer mode turns on
		LDA $4219 : STA $A2			;/
		LDA $421A				;\
		EOR $A5					; |
		AND $421A				; |
		AND #$F0 : STA $A9 : STA $AC		; > press flags in case buffer mode turns on
		LDA $421A				; |
		AND #$F0 : STA $A5			; | load joypad 2
		LDA $421B				; |
		EOR $A3					; |
		AND $421B				; |
		STA $A7 : STA $AD			; > press flags in case buffer mode turns on
		LDA $421B : STA $A3			;/
		..done


	; some RAM stuff
		REP #$20
		LDA #$0000 : STA $7F837B		; clear stripe image table


	ReturnNMI:
		REP #$30
		PLD					;\
		PLB					; |
		PLY					; | restore everything
		PLX					; |
		PLA					; |
		PLP					;/
		RTI					; > return from interrupt

