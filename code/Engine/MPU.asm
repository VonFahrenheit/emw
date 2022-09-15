

; these codes are copied to SNES WRAM

	MPU:
	.wait								;\
		STA !MPU_SNES						; |
		STA !MPU_phase						; |
		LDA !MPU_phase						; | RAM code that waits for SA-1 handshake
	-	CMP !MPU_SA1 : BNE -					; |
		RTS							; |
		..end							;/



; buffer = 0: work on buffer 0
; buffer = 1: work on buffer 1

	.light
		PHB							;\
		PHP							; |
		PHD							; |
		REP #$30						; |
		LDA #$0000 : TCD					;\
		LDX !LightIndex_SNES					; |
		LDA !LightBuffer-1					; |
		AND #$0100						; |
		ASL A							; |
		STA $22							; > start wrap value
		ADC #$0200						; |
		STA $20							; > end wrap value
		SEP #$20						; |

		..wait
		LDA $3189 : BEQ $03 : BRL ..break			; > detect SA-1 being done with its thread
		LDA !ProcessLight					; |
		AND #$03 : BEQ ..init					; | (0 = start new, 1 = continue, 2 = wait for signal)
		CMP #$02 : BCS ..wait					; |
		REP #$20						; |
		BRA ..loop						;/

		..init
		BIT !ProcessLight : BMI ..wait				; > if SA-1 is currently writing to !ShaderInput, wait
		INC !ProcessLight					;\
		REP #$10						; | this code runs once at the start of a new shading operation
		LDX #$8000 : STX $4300					; |
		LDX.w #!ShaderInput : STX $4302				; | use DMA to copy the data (fuck version 1.1.1)
		LDA.b #!ShaderInput>>16 : STA $4304			; | (i guess i'm not worried about the DMA + HDMA crash...?)
		LDX #$0200 : STX $4305					; |
		STZ $2183						; |
		LDX.w #!LightData_SNES					; |
		LDA !LightBuffer					; |
		AND #$01						; |
		BEQ $03 : LDX.w #!LightData_SNES+$200			; |
		STX $2181						; |
		LDA #$01 : STA $420B					; |
		REP #$30						; > all regs 16-bit
		LDA !LightIndexStart : STA !LightIndexStart_SNES	; |
		LDA !LightIndexEnd : STA !LightIndexEnd_SNES		; |
		LDA !LightBuffer-1					; |
		AND #$0100						; > add 512 to access second buffer
		ASL A							; |
		TSB !LightIndexStart_SNES				; |
		TSB !LightIndexEnd_SNES					; | copy operation parameters to SNES RAM
		LDA !LightR : STA !LightR_SNES				; | (this way SA-1 can freely queue new shading ops with different parameters)
		LDA !LightG : STA !LightG_SNES				; |
		LDA !LightB : STA !LightB_SNES				; |
		LDX #$000E						; |
	-	LDA !LightList,x : STA !LightList_SNES,x		; |
		DEX #2 : BPL -						; |
		LDX !LightIndexStart_SNES				;/

		..loop							;\
		LDA $3189						; > check for SA-1 being done with its thread
		AND #$00FF : BNE ..break				; | this is the main loop controller
		CPX !LightIndexEnd_SNES : BNE ..shade			;/

		..done							;\
		LDA !LightBuffer					; |
		EOR #$0001						; | flip buffer
		ORA #$0080						; > mark as finished
		STA !LightBuffer					;/
		INC !ProcessLight					; mark as finished
		PLD							;\
		PLP							; | pull stuff
		PLB							;/
		JMP $1E85						; > go wait for SA-1

		..break							;\
		SEP #$20						; |
		STZ $3189						; |
		STX !LightIndex_SNES					; > save current index in WRAM
		PLD							; | if SA-1 finishes its thread, this routine must end
		PLP							; |
		PLB							; |
		RTS							;/

		..shade
		TXA							;\
		ASL #3							; |
		XBA							; |
		AND #$000F						; |
		TAY							; | check exclude list
		LDA !LightList_SNES,y					; |
		AND #$00FF : BEQ ..include				; |
		BRL ..next						; |
		..include						;/

		LDA.l !LightData_SNES,x : STA $0E			;\
		AND #$001F						; |
		STA $00							; |
		LDA $0E							; |
		LSR #5							; |
		STA $0E							; | unpack color
		AND #$001F						; |
		STA $02							; |
		LDA $0E							; |
		LSR #5							; |
		AND #$001F						; |
		STA $04							;/
		SEP #$20						;\
		LDA $00 : STA $4202					; |
		LDA !LightR_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightR_SNES+1 : STA $4203				; | calculate red
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					; |
		STA $00							;/
		SEP #$20						;\
		LDA $02 : STA $4202					; |
		LDA !LightG_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightG_SNES+1 : STA $4203				; | calculate green
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					; |
		STA $02							;/
		SEP #$20						;\
		LDA $04 : STA $4202					; |
		LDA !LightB_SNES : STA $4203				; |
		NOP #3							; |
		REP #$20						; |
		LDA $4216 : STA $10					; |
		LDA !LightB_SNES+1 : STA $4203				; | calculate blue
		LDA $10							; |
		CMP #$0F80						; |
		XBA							; |
		AND #$00FF						; |
		ADC $4216						; |
		CMP #$001F						; |
		BCC $03 : LDA #$001F					;/
		ASL #5							;\
		ORA $02							; |
		ASL #5							; | assemble color
		ORA $00							; |
		STA.l !LightData_SNES,x					;/
		CPX #$0002 : BCC ..next					;\
		CPX #$000E+2 : BCC ..BG3				; |
		CPX #$0202 : BCC ..next					; | BG3 palette mirrors
		CPX #$020E+2 : BCS ..next				; |
		STA $FEA0-2,x						; > does this work???
		BRA ..next						; | it does! it just wraps to the next bank, which is fine with this mirroring (that's probably why STA addr,x and STA long,x both use the same amount of cycles)
	..BG3	STA $A0-2,x						;/
	..next	INX #2							;\
		CPX $20							; | loop
		BCC $02 : LDX $22					; |
		BRL ..loop						;/
		..end

print "Shader RAM code is $", hex(..end-.light), " bytes long"
warnpc .light+$200


