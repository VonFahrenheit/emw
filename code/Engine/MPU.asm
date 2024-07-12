

; these codes are copied to SNES WRAM

MPU_PROGRAM_START:
base $1000



	MPU_Wait:
		STA !MPU_SNES						;\
		STA !MPU_phase						; |
		LDA !MPU_phase						; | RAM code that waits for SA-1 handshake
	-	CMP !MPU_SA1 : BNE -					; |
		RTS							; |
		.End							;/

print "MPU wait code is $", hex(.End-MPU_Wait), " bytes long"



; buffer = 0: work on buffer 0
; buffer = 1: work on buffer 1

	MPU_Light:
		PHB							;\
		PHP							; |
		PHD							; |
		REP #$30						; |
		LDA #$0000 : TCD					; |
		LDX !LightIndex_SNES					; |
		LDA !LightBuffer-1					; |
		AND #$0100						; |
		ASL A							; |
		STA $22							; > start wrap value
		ADC #$0200						; |
		STA $20							; > end wrap value
		SEP #$20						; |

	.Wait
		LDA $3189 : BEQ $03 : BRL .Break			; > detect SA-1 being done with its thread
		LDA !ProcessLight					; |
		AND #$03 : BEQ .Init					; | (0 = start new, 1 = continue, 2 = wait for signal)
		CMP #$02 : BCS .Wait					; |
		REP #$20						; |
		BRA .Loop						;/

	.Init
		BIT !ProcessLight : BMI .Wait				; > if SA-1 is currently writing to !ShaderInput, wait
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

	.Loop
		LDA $3189						; > check for SA-1 being done with its thread
		AND #$00FF : BNE .Break					; | this is the main loop controller
		CPX !LightIndexEnd_SNES : BNE .Shade			;/
		LDA !LightBuffer					; |
		EOR #$0001						; | flip buffer
		ORA #$0080						; > mark as finished
		STA !LightBuffer					;/
		INC !ProcessLight					; mark as finished
		PLD							;\
		PLP							; | pull stuff
		PLB							;/
		JMP $1E85						; > go wait for SA-1

	.Break								;\
		SEP #$20						; |
		STZ $3189						; |
		STX !LightIndex_SNES					; > save current index in WRAM
		PLD							; | if SA-1 finishes its thread, this routine must end
		PLP							; |
		PLB							; |
		RTS							;/

	.Shade
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
		AND #$001F : STA $00					; |
		LDA $0E							; |
		LSR #5 : STA $0E					; | unpack color
		AND #$001F : STA $02					; |
		LDA $0E							; |
		LSR #5 : STA $04					;/
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
		CPX #$000E+2 : BCC ..bg3				; |
		CPX #$0202 : BCC ..next					; | BG3 palette mirrors
		CPX #$020E+2 : BCS ..next				; |
		STA $FEA0-2,x						; > does this work???
		BRA ..next						; | it does! it just wraps to the next bank, which is fine with this mirroring (that's probably why STA addr,x and STA long,x both use the same amount of cycles)
		..bg3
		STA $A0-2,x						;/
		..next
		INX #2							;\
		CPX $20							; | loop
		BCC $02 : LDX $22					; |
		BRL .Loop						;/
		.End

print "Shader RAM code is $", hex(.End-MPU_Light), " bytes long"
;warnpc .light+$200


;================;
; HDMA MPU CODES ;
;================;

	MPU_HDMA_Start:
		REP #$30					; all regs 16-bit
		LDA #$3100 : TCD				; DP optimization
		LDA !HDMA2location+1,x : STA !HDMA_Output+1	;\
		LDA !HDMA2counter,x				; |
		AND #$0001 : BEQ +				; | get output table
		LDA !HDMA2size,x				; |
	+	CLC : ADC !HDMA2location,x			; |
		STA !HDMA_Output				;/
		STZ !HDMA_ProgramState				; reset state
		SEP #$20					;\ start SA-1 logic engine
		LDA #$80 : STA $2200				;/
		INC !HDMA2counter,x				; increment internal counter
		LDA !HDMA_Output+2 : PHA : PLB			; bank optimization
		REP #$30					; all regs 16-bit
		RTS


; input:
;	X = HDMA channel index (num-2)*16
;	$3000 = 24-bit pointer to module data
;	$3180 = 24-bit pointer to SA-1 logic engine
	MPU_HDMA_1p1:
		PHP						; push P
		PHD						; push DP
		PHB						; push bank
		JSR MPU_HDMA_Start				; start engine

	.Buffer1
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BPL -
		LDY !HDMA_Buffer1_Output
		LDA !HDMA_Buffer1 : STA $0000,y
		AND #$00FF : BEQ .Return

	.Buffer2
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BMI -
		LDY !HDMA_Buffer2_Output
		LDA !HDMA_Buffer2 : STA $0000,y
		AND #$00FF : BNE .Buffer1

	.Return
		PLB						; restore bank
		LDA !HDMA_Output : STA !HDMA2source,x		; update hardware mirror
		SEP #$20					;\ update hardware bank byte
		LDA !HDMA_Output+2 : STA $4324,x		;/
	-	LDA $89 : BEQ -					;\ wait for SA-1 to finish
		STZ $89						;/
		PLD						; restore DP
		PLP						; restore P
		RTS						; return
		.End




print "MPU_HDMA_1p1 RAM code is $", hex(.End-MPU_HDMA_1p1), " bytes long"
;warnpc MPU_HDMA_1p1+$100


; input:
;	X = HDMA channel index (num-2)*16
;	$3000 = 24-bit pointer to module data
;	$3180 = 24-bit pointer to SA-1 logic engine
	MPU_HDMA_1p2:
		PHP						; push P
		PHD						; push DP
		PHB						; push bank
		JSR MPU_HDMA_Start				; start engine

	.Buffer1
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BPL -
		LDY !HDMA_Buffer1_Output
		LDA !HDMA_Buffer1_Lines : STA $0000,y
		BEQ .Return
		LDA !HDMA_Buffer1_Data : STA $0001,y

	.Buffer2
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BMI -
		LDY !HDMA_Buffer2_Output
		LDA !HDMA_Buffer2_Lines : STA $0000,y
		BEQ .Return
		LDA !HDMA_Buffer2_Data : STA $0001,y
		BRA .Buffer1

	.Return
		PLB						; restore bank
		LDA !HDMA_Output : STA !HDMA2source,x		; update hardware mirror
		SEP #$20					;\ update hardware bank byte
		LDA !HDMA_Output+2 : STA $4324,x		;/
	-	LDA $89 : BEQ -					;\ wait for SA-1 to finish
		STZ $89						;/
		PLD						; restore DP
		PLP
		RTS						; return
		.End




print "MPU_HDMA_1p2 RAM code is $", hex(.End-MPU_HDMA_1p2), " bytes long"
;warnpc MPU_HDMA_1p2+$100


; input:
;	X = HDMA channel index (num-2)*16
;	$3000 = 24-bit pointer to module data
;	$3180 = 24-bit pointer to SA-1 logic engine
	MPU_HDMA_1p4:
		PHP						; push P
		PHD						; push DP
		PHB						; push bank
		JSR MPU_HDMA_Start				; start engine

	.Buffer1
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BPL -
		LDY !HDMA_Buffer1_Output
		LDA !HDMA_Buffer1_Lines : STA $0000,y
		BEQ .Return
		LDA !HDMA_Buffer1_Data+0 : STA $0001,y
		LDA !HDMA_Buffer1_Data+2 : STA $0003,y

	.Buffer2
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BMI -
		LDY !HDMA_Buffer2_Output
		LDA !HDMA_Buffer2_Lines : STA $0000,y
		BEQ .Return
		LDA !HDMA_Buffer2_Data+0 : STA $0001,y
		LDA !HDMA_Buffer2_Data+2 : STA $0003,y
		BRA .Buffer1

	.Return
		PLB						; restore bank
		LDA !HDMA_Output : STA !HDMA2source,x		; update hardware mirror
		SEP #$20					;\ update hardware bank byte
		LDA !HDMA_Output+2 : STA $4324,x		;/
	-	LDA $89 : BEQ -					;\ wait for SA-1 to finish
		STZ $89						;/
		PLD						; restore DP
		PLP
		RTS						; return
		.End




print "MPU_HDMA_1p4 RAM code is $", hex(.End-MPU_HDMA_1p4), " bytes long"
;warnpc MPU_HDMA_1p4+$100


; input:
;	X = HDMA channel index (num-2)*16
;	$3000 = 24-bit pointer to module data
;	$3180 = 24-bit pointer to SA-1 logic engine
	MPU_HDMA_0p2:
		PHP						; push P
		PHD						; push DP
		PHB						; push bank
		JSR MPU_HDMA_Start				; start engine

	.Buffer1
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BPL -

	.Buffer2
		LDA #$0080 : TSB !HDMA_ProgramState
	-	BIT !HDMA_ProgramState : BMI -

	.Return
		PLB						; restore bank
		LDA !HDMA_Output : STA !HDMA2source,x		; update hardware mirror
		SEP #$20					;\ update hardware bank byte
		LDA !HDMA_Output+2 : STA $4324,x		;/
	-	LDA $89 : BEQ -					;\ wait for SA-1 to finish
		STZ $89						;/
		PLD						; restore DP
		PLP
		RTS						; return
		.End




print "MPU_HDMA_0p2 RAM code is $", hex(.End-MPU_HDMA_0p2), " bytes long"
;warnpc MPU_HDMA_0p2+$100





; input:
;	X = HDMA channel index (num-2)*16
;	$3000 = 24-bit pointer to module data
;	$3180 = 24-bit pointer to SA-1 logic engine
;
; takes data sent by SA-1, expected format is 2+2
; first word is written to location
; second word is written to location+size
;
; this code does not update HDMA source since it is not primarily used for HDMA effects
; it still increments counter, however, since it is a proper transcription engine
	MPU_InterlacedData_16:
		PHP
		PHD						; push DP
		PHB						; push bank
		REP #$30					; all regs 16-bit
		PHX						; push X
		LDA #$3100 : TCD				; DP optimization
		LDA !HDMA2location+1,x : STA !HDMA_Output+1	;\ output pointer
		LDA !HDMA2location,x : STA !HDMA_Output		;/
		TAY						; Y = write address 1
		CLC : ADC !HDMA2size,x				;\ X = write address 2
		TAX						;/
		STZ !HDMA_ProgramState				; reset state
		SEP #$20					;\ start SA-1 logic engine
		LDA #$80 : STA $2200				;/
		INC !HDMA2counter,x				; increment internal counter
		LDA !HDMA_Output+2 : PHA : PLB			; bank optimization
		REP #$30					; all regs 16-bit

		STZ !HDMA_Sync					; will be set to 1 when SNES should return


	; hard-coded alternating buffers to skip ,x on LDA dp, saves a few cycles
	.Buffer1
		LDA #$0080 : TSB !HDMA_ProgramState
	-	LDA !HDMA_Sync : BNE .Return
		BIT !HDMA_ProgramState : BPL -
		LDA !HDMA_Buffer1_Data+0 : STA $0000,y		;\
		LDA !HDMA_Buffer1_Data+2 : STA $0000,x		; | copy data and increment index
		INX #2						; |
		INY #2						;/

	.Buffer2
		LDA #$0080 : TSB !HDMA_ProgramState
	-	LDA !HDMA_Sync : BNE .Return
		BIT !HDMA_ProgramState : BMI -
		LDA !HDMA_Buffer2_Data+0 : STA $0000,y		;\
		LDA !HDMA_Buffer2_Data+2 : STA $0000,x		; | copy data and increment index
		INX #2						; |
		INY #2						;/
		BRA .Buffer1					; go to buffer 1

	.Return
		PLX						; restore X
		PLB						; restore bank
		SEP #$20
	-	LDA $89 : BEQ -					;\ wait for SA-1 to finish
		STZ $89						;/
		PLD						; restore DP
		PLP
		RTS						; return
		.End




print "MPU_InterlacedData_16 RAM code is $", hex(.End-MPU_InterlacedData_16), " bytes long"
;warnpc MPU_InterlacedData_16+$100





base off
MPU_PROGRAM_END:




