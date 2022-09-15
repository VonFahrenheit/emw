;===========;
; BRK RESET ;
;===========;
	RESET_GAME:
		CLC : XCE
		PHK : PLB			; B = K
		REP #$30			;\ D = 0x3000
		LDA #$3000 : TCD		;/
		SEP #$30			;\
		TSC				; |
		XBA				; |
		CMP #$37 : BNE .SNES		; |
		LDA.b #.SNES : STA $0183	; | force SNES CPU
		LDA.b #.SNES>>8 : STA $0184	; |
		LDA.b #.SNES>>16 : STA $0185	; |
		LDA #$D0 : STA $2209		; |
	-	BRA -				;/

		.SNES
		PHK : PLB			; B = K
		STZ $4200			; set up RESET
		SEI				; interrupt
		SEP #$30			; all regs 8-bit
		LDA #$00			;\ B = 0x00
		PHA : PLB			;/
		STZ $420C			; kill HDMA

		REP #$20			;\
		LDA #$8008 : STA $4300		; |
		LDA.w #.some00 : STA $4302	; |
		LDA.w #.some00>>8 : STA $4303	; |
		STZ $4305			; |
		STZ $2181			; |
		STZ $2182			; | kill SNES WRAM
		LDX #$01 : STX $420B		; |
		STZ $4305			; |
		STZ $2181			; |
		STX $2183			; |
		STX $420B			; |
		SEP #$20			;/

		LDA.l $00FFFC : STA $0000	;\
		LDA.l $00FFFC+1 : STA $0001	; | go to RESET vector
		STZ $0002			; |
		JML [$0000]			;/

		.some00
		db $00


	pushpc
	org $00FFE6 : dw .Reroute
	org $00FFF6 : dw .Reroute
	org $008A58
		.Reroute
		JML RESET_GAME
	pullpc

