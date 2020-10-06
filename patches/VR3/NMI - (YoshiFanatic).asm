; Note: The NMI vector is set to be in RAM. The location it jumps to points to either an RTI or JML Native_Mode_NMI depending on whether the game should run the NMI routine or not.

Native_Mode_NMI:
	SEI						; Set the interupt disable flag
	;JML FastROMNMI|$800000				; Make the CPU jump to bank $80 so the NMI routine is handled with FastROM addressing
FastROMNMI:
	REP #$10
	;REP #$30					;\ Preserve the value of every register so nothing gets messed up when we return
	;PHA						;| PHP is not here though, because the interupt call preserves the processor flags automatically
	;PHX						;|
	;PHY						;|
	;PHB						;|\ Set the program bank to bank $80
	PHK						;||
	PLB						;|/
	;PHD						;/
	;LDA #$0000					;\ Set the direct page to #$0000 in case it was something else
	;TCD						;/
	;SEP #$20					;

	LDA !NMI_ENABLE					; Supposedly, I need to read this register during NMI.
	LDA #$40					;\ Set the JML to this routine to an RTI so that NMI can't start again until it's changed back.
	STA !RAM_NMIJML					;/
	ASL						;\ Enable force blank so that glitches won't happen if V-Blank time is exceeded
	STA !SCREEN_DISPLAY_REGISTER			;/
	STZ !H_DMA_CHANNEL_ENABLE			; Disable all HDMA channels

	;LDA !RAM_LagFlag				;\ If the game is not lagging, run the NMI routine
	;BEQ .NormalNMI					;/
	;JMP .NoNMI					; Otherwise, skip the NMI routine

.NormalNMI
	;INC !RAM_LagFlag				; Set the lag flag so that the NMI will be skipped on the next frame if this is not cleared
	TSX						;\ Transfer the stack pointer into Y
	TXY						;/
	LDX.w #!BG_3_V_SCROLL_OFFSET			;\ Set the stack pointer to the location of the scroll registers
	TXS						;/

	LDA !RAM_Layer3YLo				;\ Write to most of the BG scroll registers by pushing the low byte to the stack and writing the high byte directly
	PHA						;| This method of writing to these registers is ever so slightly faster than just using a list of LDA/STAs
	LDA !RAM_Layer3YHi				;| This would be a bit faster if I could push all the low bytes, reset the stack pointer, then push all the high bytes...
	STA $01,S					;| ... but sadly, that doesn't work.
	LDA !RAM_Layer3XLo				;| Also, the STA $01,S save 1 byte over writing to the registers directly without any loss of speed.
	PHA						;|
	LDA !RAM_Layer3XHi				;|
	STA $01,S					;|
	LDA !RAM_Layer2YLo				;|
	PHA						;|
	LDA !RAM_Layer2YHi				;|
	STA $01,S					;|
	LDA !RAM_Layer2XLo				;|
	PHA						;|
	LDA !RAM_Layer2XHi				;|
	STA $01,S					;|
	LDA !RAM_ScreenBndryYLo				;|
	PHA						;|
	LDA !RAM_ScreenBndryYHi				;|
	STA $01,S					;|
	LDA !RAM_ScreenBndryXLo				;|
	PHA						;|
	LDA !RAM_ScreenBndryXHi				;|
	STA $01,S					;/

	LDA !RAM_BGMODEMirror				;\ Is the current BG mode set to Mode 7?
	AND #$07					;|
	CMP #$07					;|
	BNE .NoM7					;/ If not, don't bother updating the Mode 7 registers

	LDX.w #!MODE_7_CENTER_POSITION_Y		;\ Otherwise, set the stack pointer to the location of the Mode 7 registers
	TXS						;/
	LDA !RAM_M7SELMirror				;\ Otherwise, update all the Mode 7 registers the same way as the scroll registers
	STA !INITIAL_SETTING_FOR_MODE_7			;|
	LDA !RAM_M7YMirror				;|
	PHA						;|
	LDA !RAM_M7YMirror+$1				;|
	STA $01,S					;|
	LDA !RAM_M7XMirror				;|
	PHA						;|
	LDA !RAM_M7XMirror+$1				;|
	STA $01,S					;|
	LDA !RAM_M7DMirror				;|
	PHA						;|
	LDA !RAM_M7DMirror+$1				;|
	STA $01,S					;|
	LDA !RAM_M7CMirror				;|
	PHA						;|
	LDA !RAM_M7CMirror+$1				;|
	STA $01,S					;|
	LDA !RAM_M7BMirror				;|
	PHA						;|
	LDA !RAM_M7BMirror+$1				;|
	STA $01,S					;|
	LDA !RAM_M7AMirror				;|
	PHA						;|
	LDA !RAM_M7AMirror+$1				;|
	STA $01,S					;/

.NoM7
	REP #$20					;\			
	TYA						;| This bit of code was gotten from a forum thread on NESDev.com
	LDX #!WINDOW_MASK_DESIGNATION_FOR_SUB_SCREEN	;| It's basically a fast way to write to many of the registers that can only be written to during a blank.
	TXS						;| It does so by changing the stack pointer (after preserving it, of course) to point to the hardware registers...
	PEI.b (!RAM_TMWMirror)				;| ... then using PEI to push the values of their hardware mirrors into the registers
	PEI.b (!RAM_TMMirror)				;| I guess you can say that the most effect way to do this is to PEI on the registers. XD
	PEI.b (!RAM_WBGLOGMirror)			;| Sorry, I couldn't resist making that pun.
	PEI.b (!RAM_WH2Mirror)				;|
	PEI.b (!RAM_WH0Mirror)				;| Also, the reason the scroll and Mode 7 registers are not handled by this routine is because those registers are dual write...
	PEI.b (!RAM_W34SELMirror)			;| All the registers handled by this are single write
	LDX #!BG_3_AND_4_TILE_DATA_DESIGNATION		;|
	TXS						;|
	PEI.b (!RAM_BG12NBAMirror)			;|
	PEI.b (!RAM_BG3SCMirror)			;|
	PEI.b (!RAM_BG1SCMirror)			;|
	PEI.b (!RAM_BGMODEMirror)			;|
	SEP #$10					;|
	LDX !RAM_OBSELMirror				;|
	STX !OAM_SIZE_AND_DATA_AREA_DESIGNATION		;|
	LDX !RAM_W12SELMirror				;|
	STX !BG_1_AND_2_WINDOW_MASK_SETTINGS		;|
	TCS						;/
	LDA !RAM_NumNMIUpdates				;\ Load the number of NMI updates that need to be done, double it, and transfer it into Y for later
	ASL						;|
	TAY						;/
	CPY #$02					; If the number of updates is 0, then the carry flag will be cleared

	PHD						; Preserve the direct page register
	LDA #!DMA_0_PARAMS				;\ Set the direct page to $4300 so the upcoming loop and the next bit of code runs faster
	TCD						;/

	LDX #$7E					;\ Set up a DMA transfer that updates the entire OAM table
	STX !RAM_Scratch04				;| This must be done every frame which is why it's not handled in the upcoming loop
	LDA.w #!RAM_OAMDispX				;|
	STA !RAM_Scratch02				;|
	LDA #$0220					;|
	STA !RAM_Scratch05				;|
	LDA #$0400					;|
	STA !RAM_Scratch00				;|
	TAX						;| Because X/Y is 8-bit, this only transfers the low byte of A into X, which is 00
	STX !ADDRESS_FOR_ACCESSING_OAM_LOW		;|
	INX						;|
	STX !REGULAR_DMA_CHANNEL_ENABLE			;/

	BCC .NothingtoUpdate				; If the carry flag was cleared earlier, then skip the DMA loop
							; Fun fact: By the time the CPU gets here, the V-Counter will be at about 229
							; That means that I have almost the entire V-Blank period available for VRAM/CGRAM updates
.NMIUploadLoop
	LDA !RAM_DMADataLoHi-$2,Y			;\ Store the DMA Source Address for DMA channel 0
	STA !RAM_Scratch02				;/

	LDA !RAM_DMADataBytes-$2,Y			;\ Store the number of bytes to transfer for DMA channel 0
	STA !RAM_Scratch05				;/
	LDA !RAM_DMAProp_Designation-$2,Y		;\ Store the DMA settings and the destination register for DMA channel 0
	STA !RAM_Scratch00				;/
	LDX !RAM_DMADataBNK_Flag-$2,Y			;\ Store the DMA Source Bank for DMA channel 0
	STX !RAM_Scratch04				;/
	LDX !RAM_DMAType-$2,Y				;\ Jump to a location based on what type of update we're doing
	JMP.w (.DMATypeTBL,X)				;/

.VRAMRead
	LDX !RAM_DMADataBNK_Flag-$1,Y			;\ Store the VRAM settings for the upcoming VRAM read
	STX !VRAM_ADDRESS_INCREMENT_VALUE		;/
	LDA !RAM_DMAToAddress-$2,Y			;\ Store the VRAM address we will be reading from
	STA !ADDRESS_FOR_VRAM_READ_WRITE_LOW_BYTE	;/
	LDA !READ_DATA_FROM_VRAM_LOW			; Perform a dummy read so the actual VRAM read will work correctly
	BRA .DoneTask					; Branch to some code shared by all of these mini routines

.VRAMWriteGeneral
.VRAMWriteSprite8x8
	LDX !RAM_DMADataBNK_Flag-$1,Y			;\ Store the VRAM settings for the upcoming VRAM write
	STX !VRAM_ADDRESS_INCREMENT_VALUE		;/
	LDA !RAM_DMAToAddress-$2,Y			;\ Store the VRAM address we will be writing to
	STA !ADDRESS_FOR_VRAM_READ_WRITE_LOW_BYTE	;/
	BRA .DoneTask					; Branch to some code shared by all of these mini routines

.CGRAMRead
.CGRAMWrite
	LDX !RAM_DMAToAddress-$2,Y			;\ Store the CGRAM address we will be reading from or writing to
	STX !ADDRESS_FOR_CG_RAM_WRITE			;/
	BRA .DoneTask					; Branch to some code shared by all of these mini routines

.OAMWrite
	STZ !ADDRESS_FOR_ACCESSING_OAM_LOW		; Set the OAM Write address to 0 so we can update the entire OAM
	BRA .DoneTask					; Branch to some code shared by all of these mini routines

.VRAMWriteSprite16x16
	LDX !RAM_DMADataBNK_Flag-$1,Y			;\ Store the VRAM settings for the upcoming VRAM write
	STX !VRAM_ADDRESS_INCREMENT_VALUE		;/
	LDA !RAM_DMAToAddress-$2,Y			;\ Store the VRAM address we will be writing to
	STA !ADDRESS_FOR_VRAM_READ_WRITE_LOW_BYTE	;/
	LDX #$01					;\ Start up DMA channel 0 so we can update the top half of the sprite, then we'll set things up to update the bottom half
	STX !REGULAR_DMA_CHANNEL_ENABLE			;/
	ORA #$0100					;\ Add 0100 to the VRAM address we will be writing to
	STA !ADDRESS_FOR_VRAM_READ_WRITE_LOW_BYTE	;/
	LDA !RAM_DMADataLoHi-$2,Y			;\ Add 0200 to the DMA source address
	CLC						;|
	ADC #$0200					;|
	STA !RAM_Scratch02				;/
	LDA !RAM_DMADataBytes-$2,Y			;\ Set the number of bytes to transfer again
	STA !RAM_Scratch05				;/

.DoneTask
	LDX #$01					;\ Start up DMA channel 0 so we can update whatever needed updating
	STX !REGULAR_DMA_CHANNEL_ENABLE			;/
	DEY						;\ Decrement Y twice to prepare for the next loop/end the loop
	DEY						;/
	BNE .NMIUploadLoop				; If Y = 0, exit the DMA loop
.NothingtoUpdate
	PLD						; Restore the direct page register
	SEP #$30					; Set A,X and Y to be 8-bit
	STZ !RAM_NumNMIUpdates				; Set the number of NMI updates to 0

	LDA !RAM_VWFmode				;\ If a VWF dialog is running, poll the controller registers every frame
	BNE .60FPSControls				;/

	LDA !RAM_ControllerFPSFlag			;\ Is the game running at 30 FPS (ex. While controlling Mario)?
	BEQ .60FPSControls				;/ If not, poll the controller registers every frame
	LDA !RAM_GlobalFrameCounter			;\ Otherwise, is the global frame counter an odd number?
	LSR						;|
	BCC .Skipcontrol				;/ If not, don't poll the controller registers on this frame

.60FPSControls
	LDA !JOYPAD_1_DATA_LOW_BYTE			;\ Check what buttons are being pressed this frame and store it to some RAM addresses
	AND #$F0					;|
	STA !RAM_ControllerBHold			;|
	TAY						;|
	EOR !RAM_ControlDisableB			;|
	AND !RAM_ControllerBHold			;|
	STA !RAM_ControllerBPress			;|
	STY !RAM_ControlDisableB			;|
	LDA !JOYPAD_1_DATA_HIGH_BYTE			;|
	STA !RAM_ControllerAHold			;|
	TAY						;|
	EOR !RAM_ControlDisableA			;|
	AND !RAM_ControllerAHold			;|
	STA !RAM_ControllerAPress			;|
	STY !RAM_ControlDisableA			;/
.Skipcontrol
.NoNMI
	LDA !SOFTWARE_LATCH_FOR_H_V_COUNTER		; Prepare H/V-count data
	LDA !V_COUNTER_DATA				;\ Get V-count data, then subtract #$E1 from it
	SEC						;|
	SBC #$E1					;|
	ASL						;/ Double the result
	STA !RAM_OAMDispY+$1F8				; Then store it to the Y position of the V-Blank meter
	STZ !RAM_OAMDispX+$1F8				; Set the X position of the V-Blank meter to 0
	STZ !RAM_OAMSize+$7E				; Set the size of the V-Blank meter tile to 8x8
	LDA !V_COUNTER_DATA				; Load the V-count data again to prevent glitches. This is due to this register being dual read, not single read

	LDA !RAM_INIDISPMirror				;\ Reset the screen brightness back to what it was before the NMI routine
	STA !SCREEN_DISPLAY_REGISTER			;/
	LDA !RAM_HDMAMirror				;\ Restore all the active HDMA channels
	STA !H_DMA_CHANNEL_ENABLE			;/
	REP #$30					;\ Restore all the stuff that needed to be preserved at the start of the NMI routine
	LDA #$39EE					;|\ Set the properties and the tile number of the V-Blank meter
	STA !RAM_OAMTile+$1F8				;|/
	;PLD						;|
	;PLB						;|
	;PLY						;|
	;PLX						;|
	;PLA						;/
	RTI						; Return

.DMATypeTBL
	dw .OAMWrite,.CGRAMWrite,.CGRAMRead,.VRAMRead,.VRAMWriteGeneral,.VRAMWriteSprite16x16

;====Idea====

; If I were to adjust the controller polling code to be handled with 16-bit A and Y, then I'd save a few more cycles and bytes.
; I have yet to test if this will work, but I'm sure it will.

.NothingtoUpdate
	PLD						; Restore the direct page register
	LDA #$39EE					;\ Set the properties and the tile number of the V-Blank meter while A is still 16-bit
	STA !RAM_OAMTile+$1F8				;/

	LDY !RAM_VWFmode				;\ If a VWF dialog is running, poll the controller registers every frame
	BNE .60FPSControls				;/

	LDY !RAM_ControllerFPSFlag			;\ Is the game running at 30 FPS (ex. While controlling Mario)?
	BEQ .60FPSControls				;/ If not, poll the controller registers every frame
	LDA !RAM_GlobalFrameCounter			;\ Otherwise, is the global frame counter an odd number?
	LSR						;|
	BCC .Skipcontrol				;/ If not, don't poll the controller registers on this frame

.60FPSControls
	LDA !JOYPAD_1_DATA_LOW_BYTE			;\ Check what buttons are being pressed this frame and store it to some RAM addresses
	AND #$FFF0					;|
	STA !RAM_ControllerAHold			;|
	EOR !RAM_ControlDisableA			;|
	AND !RAM_ControllerAHold			;|
	STA !RAM_ControllerAPress			;|
	LDA !JOYPAD_1_DATA_LOW_BYTE			;|
	STA !RAM_ControlDisableA			;/
.Skipcontrol
	SEP #$30					; Set A,X and Y to be 8-bit
	STZ !RAM_NumNMIUpdates				; Set the number of NMI updates to 0
.NoNMI
	LDA !SOFTWARE_LATCH_FOR_H_V_COUNTER		; Prepare H/V-count data
	LDA !V_COUNTER_DATA				;\ Get V-count data, then subtract #$E1 from it
	SEC						;|
	SBC #$E1					;|
	ASL						;/ Double the result
	STA !RAM_OAMDispY+$1F8				; Then store it to the Y position of the V-Blank meter
	STZ !RAM_OAMDispX+$1F8				; Set the X position of the V-Blank meter to 0
	STZ !RAM_OAMSize+$7E				; Set the size of the V-Blank meter tile to 8x8
	LDA !V_COUNTER_DATA				; Load the V-count data again to prevent glitches. This is due to this register being dual read, not single read

	LDA !RAM_INIDISPMirror				;\ Reset the screen brightness back to what it was before the NMI routine
	STA !SCREEN_DISPLAY_REGISTER			;/
	LDA !RAM_HDMAMirror				;\ Restore all the active HDMA channels
	STA !H_DMA_CHANNEL_ENABLE			;/
	RTI						; Return