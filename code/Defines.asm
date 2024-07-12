;=======;
;DEFINES;
;=======;


; turns out this function is pretty useless because LDA/STA addr,x and LDA/STA long,x both use 5 cycles...
macro mapBWRAM(address)
	if <address>&$01FFFF == 0
		STZ $2225
		STZ $318F
	else
		LDA.b #((<address>&$01FFFF)/$2000)&$1F
		STA $2225
		STA $318F
	endif
endmacro


; these macros can be used to quickly find an index to FusionCore
; _fast versions shred regs instead of pushing/pulling them
macro Ex_Index_X()
		PHY
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	?loop:	LDA !Ex_Num,x : BEQ ?thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ?loop			;/
		LDX #$00			; default index = 00
	?thisone:
		PLY
		STX !Ex_Index			; update index
		CPX #$00			; update P
endmacro

macro Ex_Index_X_fast()
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	?loop:	LDA !Ex_Num,x : BEQ ?thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ?loop			;/
		LDX #$00			; default index = 00
	?thisone:
		STX !Ex_Index			; update index
		CPX #$00			; update P
endmacro

macro Ex_Index_Y()
		PHX
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	?loop:	LDA !Ex_Num,y : BEQ ?thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ?loop			;/
		LDY #$00			; default index = 00
	?thisone:
		PLX
		STY !Ex_Index			; update index
		CPY #$00			; update P
endmacro

macro Ex_Index_Y_fast()
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	?loop:	LDA !Ex_Num,y : BEQ ?thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ?loop			;/
		LDY #$00			; default index = 00
	?thisone:
		STY !Ex_Index			; update index
		CPY #$00			; update P
endmacro


macro ReloadOAMData()
		PHP
		REP #$20
		STZ !OAMindex_index+0
		LDA #$0002 : STA !OAMindex_index+2
		LDA #$0004 : STA !OAMindex_index+4
		LDA #$0006 : STA !OAMindex_index+6
		STZ !OAMindex_offset+0
		LDA #$0200 : STA !OAMindex_offset+2
		LDA #$0400 : STA !OAMindex_offset+4
		LDA #$0600 : STA !OAMindex_offset+6
		PLP
endmacro


macro ApplyLight_sharp(S, E)			; whatever is written to !LightR/G/B will be applied with no fading
		PHP				;
		SEP #$30
		LDA !LightBuffer : BPL ?NotReady
		REP #$20
		AND #$0001
		EOR #$0001
		BEQ $03 : LDA #$0200
		PHA
		JSL !GetCGRAM
		PLA
		TYX
		CLC : ADC.w #!LightData_SNES+2 : STA !VRAMbase+!CGRAMtable+$02,x
		LDA.w #!LightData_SNES>>16 : STA !VRAMbase+!CGRAMtable+$04,x
		LDA #$01FE : STA !VRAMbase+!CGRAMtable+$00,x
		SEP #$20
		LDA #$01 : STA !VRAMbase+!CGRAMtable+$05,x
		LDA #$80 : TRB !LightBuffer
	?NotReady:
		LDA !ProcessLight
		CMP #$02 : BCC ?CantSend
		REP #$20
		LDA.w #<S>*2 : STA !LightIndexStart
		LDA.w #<E>*2 : STA !LightIndexEnd
		SEP #$20
		STZ !ProcessLight
	?CantSend:
		PLP
endmacro


macro ApplyLight_fade(S, E)			; this macro takes the values in $00-$05 and fades !LightR/G/B to those values
		PHP				;
		REP #$20
		JSL !FadeLight
		SEP #$30
		LDA !LightBuffer : BPL ?NotReady
		REP #$20
		AND #$0001
		EOR #$0001
		BEQ $03 : LDA #$0200
		PHA
		JSL !GetCGRAM
		PLA
		TYX
		CLC : ADC.w #!LightData_SNES+2 : STA !VRAMbase+!CGRAMtable+$02,x
		LDA.w #!LightData_SNES>>16 : STA !VRAMbase+!CGRAMtable+$04,x
		LDA #$01FE : STA !VRAMbase+!CGRAMtable+$00,x
		SEP #$20
		LDA #$01 : STA !VRAMbase+!CGRAMtable+$05,x
		LDA #$80 : TRB !LightBuffer
	?NotReady:
		LDA !ProcessLight
		CMP #$02 : BCC ?CantSend
		REP #$20
		LDA.w #<S>*2 : STA !LightIndexStart
		LDA.w #<E>*2 : STA !LightIndexEnd
		SEP #$20
		STZ !ProcessLight
	?CantSend:
		PLP
endmacro



; used to sync MPU operation, SNES side
macro MPU_SNES(value)
		PHP				;\ wrap to 8-bit A
		SEP #$20			;/
		LDA.b #<value>			; phase to wait for
		JSR !MPU_wait			; wait for SA-1
		PLP				; restore P
endmacro

; used to sync MPU operation, SA-1 side
macro MPU_SA1(value)
		PHP				;\ wrap to 8-bit A
		SEP #$20			;/
		LDA.b #<value> : STA !MPU_SA1	; phase to wait for
	?Loop:	CMP !MPU_SNES : BNE ?Loop	; wait for SNES
		PLP				; restore P
endmacro


; sets up page $0100 for DP use
macro MPU_copy()
		PHP				;\
		REP #$20			; |
		SEP #$10			; |
		LDX #$2E			; | copy some important stuff to DP $0100
	?Loop:					; | NOTE: DP $40 and up are not accessible on DP in MPU mode!
		LDA $10,x : STA $0110,x		; |	  to access those, read $3040-$30FF instead!
		DEX #2 : BPL ?Loop		; | also, no writes to dp will work during MPU mode!
		LDA #$0100 : TCD		; > DP = $0100
		PLP				;/
endmacro




<<<<<<< Updated upstream
=======
macro generic_dynamo(tilecount, sourcetile, desttile)
		dw <tilecount>*$20
		dl <sourcetile>*$20
		dw (<desttile>*$10)+$6000
endmacro



; llllllll	lo byte
; HHHH-ssh	hi byte

; llllllll are bits 0-7
; h is bit 8
; HHHH are bits 9-12
; ss are always set


macro SecondaryExitValue(exit)
		db <exit>
		db ((<exit>&$1E00)>>5)|((<exit>&$0100)>>8)|$06
endmacro





macro EnterDoor(player)
		LDA #$0F : STA !SPC4					; door SFX
		LDA !MultiPlayer : BEQ ..enter				;\
		LDA !PlayerWaiting : BEQ ..godormant			; | handle multiplayer
		..enter							;/
		INC !DoorCounter					; +1 door count
		BNE $03 : DEC !DoorCounter				; stay at 255 instead of wrapping around to 0
		LDA #$0F : STA !GameMode				; load level

		LDA !P2XPosLo-$80+(<player>*$80) : STA $94		;\ set mario coords to make sure the transition goes into the correct level
		LDA !P2XPosHi-$80+(<player>*$80) : STA $94+1		;/

		..godormant						;\
		LDA !CurrentPlayer					; | wait for the other player in the door
		LDA.b #<player> : TSB !PlayerWaiting			;/
	endmacro




	macro fraction(mult, div)
		if <mult> != 0
		dw $200*<div>/<mult>
		else
		dw $200
		endif
		dw <mult>
		dw <div>
	endmacro



	macro GradientRGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Red		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY.b #<table>_Red>>16		; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Green		; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		LDA #$3200			;\
		STA $4350			; |
		LDA #<table>_Blue		; | Set up blue colour math on channel 5
		STA !HDMA5source		; |
		STY $4354			;/
		SEP #$20			; > A 8 bit
		LDA #$38			;\ Enable HDMA on channels 3, 4, and 5
		TSB !HDMA			;/
	endmacro

	macro GradientGB(table)
		REP #$20			; > A 16 bit
		LDA #$3200			;\
		STA $4330			; |
		LDA #<table>_Green		; |
		STA !HDMA3source		; | Set up red colour math on channel 3
		LDY.b #<table>_Red>>16		; |
		STY $4334			;/
		LDA #$3200			;\
		STA $4340			; |
		LDA #<table>_Blue		; | Set up green colour math on channel 4
		STA !HDMA4source		; |
		STY $4344			;/
		SEP #$20			; > A 8 bit
		LDA #$18			;\ Enable HDMA on channels 3 and 4
		TSB !HDMA			;/
	endmacro


	macro TalkBox(X, Y, W, H, M)		; Xcoord, Ycoord, width, heigth, message
		LDX !P1Dead
		BNE ?P2
		LDA $94
		CMP.w #<X>
		BCC ?P2
		CMP.w #<X>+<H>
		BCS ?P2
		LDA $96
		CMP.w #<Y>
		BCC ?P2
		CMP.w #<Y>+<H>
		BCS ?P2
		LDA $77
		AND #$0004
		BEQ ?P2
		LDA $16
		AND #$0008
		BEQ ?P2
		LDX.b #<M>
		STX !MsgTrigger
		BRA ?Return

		?P2:
		LDX !P2Status
		BNE ?Return
		LDA !P2XPosLo
		CMP.w #<X>
		BCC ?Return
		CMP.w #<X>+<H>
		BCS ?Return
		LDA !P2YPosLo
		CMP.w #<Y>
		BCC ?Return
		CMP.w #<Y>+<H>
		BCS ?Return
		LDA !P2Blocked
		AND #$0004
		BEQ ?Return
		LDA $6DA7
		AND #$0008
		BEQ ?Return
		LDX.b #<M>
		STX !MsgTrigger

		?Return:
	endmacro


	macro CameraBox(X, Y, W, H)
		dw <X>*$100
		dw <Y>*$E0
		dw (<X>+<W>)*$100
		dw (<Y>+<H>)*$E0
	endmacro


macro decreg(reg)
	LDA <reg>,x : BEQ ?skip
	DEC <reg>,x
	?skip:
endmacro


macro ListVanillaInit(name)
	dw <name>_INIT
endmacro

macro ListVanillaMain(name)
	dw <name>_MAIN
endmacro

macro VanillaSprite(name)
	namespace <name>
		incsrc "Fe26/sprites_vanilla/<name>.asm"
	namespace off
endmacro



>>>>>>> Stashed changes


macro snescolor(R, G, B)
	dw <R>+(<G>+(<B>*32)*32)
endmacro








	; -- Free RAM --		; Point to unused addresses, please.
					; Don't change addressing mode (16-bit to 24-bit and vice versa).
					; Doing that requires changing some code.

		!AnimToggle		= $60		; see VR3.asm for info on how to use


; settings for shader:
; !LightList:
;	operates row-by-row
;	if an entry is set to 0, it is handled by SNES shader (no interaction with HSL)
;	if an entry is set to 1, it is shaded by SA-1 before HSL conversion (good for fixed values, or for treating the HSL operation as a lighting op)
;	if an entry is set to 80, it is shaded by SA-1 after HSL conversion (good for variable values, since it treats the HSL operation as affecting the color rather than the light)
; !LightIndex:
;	start and end point for SNES
;	this is a more efficient way of limiting the palette's shade area, since the SNES won't check excluded colors (leading to higher shade FPS)
;	for a color to be completely excluded, it has to be disabled in !LightList (00) and be outside the start/end points of the index




		!LightData_SNES		= $7EFC00	; 2 buffers of 512 bytes each for processing lighting


<<<<<<< Updated upstream
=======
		!MPU_NMI		= $315F		; used to break SA-1 out of final loop to max shader

>>>>>>> Stashed changes
		!LightBuffer		= $3171		; lowest bit: which buffer SNES is working on (0 = first buffer, 1 = second buffer), highest bit: 0 = not ready for upload, 1 = ready for upload
		!LightIndexStart	= $3172
		!LightIndexEnd		= $3174

		!LightR			= $3176		; these are 16-bit numbers with 8-bit fixed point fractions
		!LightG			= $3178		; normal value is 01.00, 01.00, 01.00, meaning that each color is applied 100%
		!LightB			= $317A		; SNES will apply rounded shading in background mode using these values
		!ProcessLight		= $317C		; 0 = not processing, 1 = in process, 2 = done, if highest bit is set, SA-1 is currently writing to !PaletteRGB and SNES should wait
		!LightList		= $3160		; 16 bytes


		!LightList_SNES		= $0FE4		; 16 bytes that determine whether each row should be shaded or not
		!LightIndexStart_SNES	= $0FF4		; these are copied to WRAM at the start of a shade operation
		!LightIndexEnd_SNES	= $0FF6		; this way, SA-1 can queue as much as it wants without disrupting anything
		!LightR_SNES		= $0FF8
		!LightG_SNES		= $0FFA
		!LightB_SNES		= $0FFC
		!LightIndex_SNES	= $0FFE

		!MPU_SNES		= $317D		; SNES status in dual thread operation
		!MPU_SA1		= $317E		; SA-1 status in dual thread operation

		!CCDMA_SLOTS		= $317F
		!CCDMA_TABLE	 	= $3190
		!CC_BUFFER		= $3700



<<<<<<< Updated upstream
		!HDMA2source		= $1F00
		!HDMA3source		= $1F02
		!HDMA4source		= $1F04
		!HDMA5source		= $1F06
		!HDMA6source		= $1F08
		!HDMA7source		= $1F0A
=======
	; regs
		!420C			= $019F

		; thse can only be read/written by SNES
		; source is a mirror of $43x2, written duringNMI
		; module is a 24-bit pointer to an HDMA module (see EffectLibrary.asm)
		; location is a 24-bit pointer to RAM where the HDMA table is generated
		; size is a 16-bit offset to location during odd frames of double buffering
		; bit is the channel's bit: 2^channel num (written during level load)
		; counter is an 8-bit internal frame counter
		; init is an 8-bit flag set to 1 after a module is run
		; mem is 3 bytes of general purpose RAM that the module can use
		; note that channel 7 ONLY has 2 bytes of mem, rather than 3, due to it also holding !420C
		!HDMA2source		= $0140
		!HDMA2module		= $0142
		!HDMA2location		= $0145
		!HDMA2size		= $0148
		!HDMA2bit		= $014A
		!HDMA2counter		= $014B
		!HDMA2init		= $014C
		!HDMA2mem		= $014D
		!HDMA3source		= $0150
		!HDMA3module		= $0152
		!HDMA3location		= $0155
		!HDMA3size		= $0158
		!HDMA3bit		= $015A
		!HDMA3counter		= $015B
		!HDMA3init		= $015C
		!HDMA3mem		= $015D
		!HDMA4source		= $0160
		!HDMA4module		= $0162
		!HDMA4location		= $0165
		!HDMA4size		= $0168
		!HDMA4bit		= $016A
		!HDMA4counter		= $016B
		!HDMA4init		= $016C
		!HDMA4mem		= $016D
		!HDMA5source		= $0170
		!HDMA5module		= $0172
		!HDMA5location		= $0175
		!HDMA5size		= $0178
		!HDMA5bit		= $017A
		!HDMA5counter		= $017B
		!HDMA5init		= $017C
		!HDMA5mem		= $017D
		!HDMA6source		= $0180
		!HDMA6module		= $0182
		!HDMA6location		= $0185
		!HDMA6size		= $0188
		!HDMA6bit		= $018A
		!HDMA6counter		= $018B
		!HDMA6init		= $018C
		!HDMA6mem		= $018D
		!HDMA7source		= $0190
		!HDMA7module		= $0192
		!HDMA7location		= $0195
		!HDMA7size		= $0198
		!HDMA7bit		= $019A
		!HDMA7counter		= $019B
		!HDMA7init		= $019C
		!HDMA7mem		= $019D




		; MPU HDMA regs (DP $3100)


		; 16 bytes, can be used for anything during a module
		; scratch		$00

		!HDMA_WorkingY		= $10			; used to keep track of how many scanlines have been rendered
		!HDMA_MaxY		= $12			; reset to 0x00E0 before each module is processed. module pointers can overwrite this to render a smaller effect
		!HDMA_WorkingIndex	= $14			; used when SA-1 has to hand off its buffer index
		!HDMA_WorkingOutput	= $16			; used when SA-1 has to control SNES' write address
		!HDMA_Misc		= $18			; can be used for any purpose

		; these are copied once before the first module call
		; BG1 X			$1A
		; BG1 Y			$1C
		; BG2 X			$1E
		; BG2 Y			$20
		; BG3 X			$22
		; BG3 Y			$24

		!HDMA_Sync		= $26			; sometimes used to sync SNES and SA-1
		!HDMA_ProgramState	= $28
		; a little more complex, though it only uses a few bits
		; highest bit in lo byte is set by SNES when it requests a new buffer read
		; highest bit in hi byte is set by SA-1 when writing to buffer 2
		; when SA-1 updates the hi byte, it also clears the lo byte
		; SNES only ever sets bit 0x0080

		!HDMA_Input		= $2A			; 16-/24-bit input pointer, sometimes used by SA-1
		!HDMA_Output		= $2D			; 24-bit output pointer

		!HDMA_Buffer1		= $30			; 8 bytes
		!HDMA_Buffer1_Lines	= !HDMA_Buffer1+0	; 2 bytes
		!HDMA_Buffer1_Data	= !HDMA_Buffer1+2	; 4 bytes
		!HDMA_Buffer1_Output	= !HDMA_Buffer1+6	; 2 bytes, address that lines and data are written to

		!HDMA_Buffer2		= $38			; 8 bytes
		!HDMA_Buffer2_Lines	= !HDMA_Buffer2+0	; 2 bytes
		!HDMA_Buffer2_Data	= !HDMA_Buffer2+2	; 4 bytes
		!HDMA_Buffer2_Output	= !HDMA_Buffer2+6	; 2 bytes, address that lines and data are written to

>>>>>>> Stashed changes



		!BG1Address		= $3140		;\ tilemap addresses for layers 1/2
		!BG2Address		= $3142		;/ (based on 2107/2108, meant to be read for VRAM calc)
		!2107			= $3144		; $2107 mirror, BG1 tilemap address control
		!2108			= $3145		; $2108 mirror, BG2 tilemap address control
		!2109			= $3146		; $2109 mirror, BG3 tilemap address control
		!210C			= $3147		; $210C mirror, BG3 GFX address control

<<<<<<< Updated upstream
=======

		!2123			= $41		; window settings for BG1/BG2
		!2124			= $42		; window settings for BG3/BG4
		!2125			= $43		; window settings for sprite layer and color plane
		!2130			= $44		; color math settings
		!2131			= $40		; color math designation



		!Mode7Settings		= $786C		; $211A mirror
			; rc--emyx (rc----yx are written to $211A, the rest is software side)
			;
			; hardware bits:
			; r - playing field size (0 = 1024x1024, 1 = "much larger", actual size unknown)
			; c - empty space fill, only used with r = 1 (0 = fill is transparent, 1 = fill is character 0)
			; y/x - flip for entire screen
			;
			; software bits:
			; e - enable mode 7 (0 = skip mode 7 regs during NMI/VR3, 1 = update mode 7 regs during NMI/VR3)
			; m - manual control (0 = use !Mode7Rotation/!Mode7Scaling to feed values to matrix, 1 = use direct writes to matrix)



		!Mode7X			= $3A		; $210D mirror (kept distinct from camera coords since those interact with gameplay)
		!Mode7Y			= $3C		; $210E mirror (same thing here, this just moves the mode7 image without affecting the camera)
		!Mode7MatrixA		= $2E		; $211B mirror
		!Mode7MatrixB		= $30		; $211C mirror
		!Mode7MatrixC		= $32		; $211D mirror
		!Mode7MatrixD		= $34		; $211E mirror
		!Mode7CenterX		= $2A		; $211F mirror
		!Mode7CenterY		= $2C		; $2120 mirror

		!Mode7Rotation		= $36
		!Mode7Scale		= $38








		!DynamicList		= $7600		; 32 bytes, !DynamicTile mirror for each sprite (indexed by sprite number * 2)
		!DynamicMatrix		= $7620		; 32 bytes, -------T tttttttt bits for each dynamic tile
		!DynamicProp		= $7640		; 16 bytes, -------T bit of prop, complement to $F0 for dynamic sprites
		!DynamicTile		= $7650		; 2 bytes, 1 bit per tile (0 = free, 1 = in use)
							; cleaned up by Fe26 at the start of each loop
		!DynamicCount		= $7652		; 16-bit, how many dynamic tiles will be updated this frame
>>>>>>> Stashed changes


		!DynamicTile		= $3150
					; 16 bytes
					; each one represents one tile, starting at [???]
					; to claim one for a sprite, write the sprite's index to the proper index
					; the sprite's !ClaimedGFX register needs to match what is written here as well
					; if the comparison concludes invalid, the slot is considered free


		!CameraPrevX		= $7462			;\
		!CameraPrevY		= $7464			; | these can be overwritten by level/HDMA codes
		!CameraPrevBG2X		= $7466			; |
		!CameraPrevBG2Y		= $7468			;/

<<<<<<< Updated upstream
	!CameraXMem	= $7432		; 16-bit used for PCE camera baybee


		!CameraBackupX		= $3148
		!CameraBackupY		= $314A

		!CameraForceTimer	= $314C			; index 0/1 for both of these, 1 processed first
		!CameraForceDir		= $314E
=======

		!CameraSettings		= $74C8
		!CameraPower		= !CameraSettings+0	; factor player speed is multiplied with to adjust target camera position
		!CameraMinPower		= !CameraSettings+2	; minimum camera adjustment needed for it to be applied
		!CameraMaxPower		= !CameraSettings+4	; maximum allowed camera adjustment
		!CameraPauseTime	= !CameraSettings+6	; how long the camera should remember the player's highest speed before it starts slowing down
		!CameraAccel		= !CameraSettings+8	; how quickly the camera accelerates up to a proper speed adjustment (8.8 format)
		!CameraSlowdown		= !CameraSettings+10	; how quickly the camera returns to center when the player is standing still (8.8 format)
		!CameraYThreshold	= !CameraSettings+12	; how far from the center the player has to be for the camera to scroll vertically
		; 2 bytes free at +14, +15

		!CameraData		= $74D8
		!CameraBackupX		= !CameraData+0		;\ only camera box is allowed to write to these
		!CameraBackupY		= !CameraData+2		;/
		!CameraForceTimer	= !CameraData+4		;\ index 0/1 for both of these, 1 processed first
		!CameraForceDir		= !CameraData+6		;/
		!CameraBoxL		= !CameraData+8
		!CameraBoxU		= !CameraData+10
		!CameraBoxR		= !CameraData+12
		!CameraBoxD		= !CameraData+14
		!CameraBoxRoom		= !CameraData+16	; which camera box room the player is in
		!Room			= !CameraBoxRoom	; alt name
		!LockBox		= !CameraData+18	; 0 = camera box has automatic doors, 1 = camera box is locked

		!CameraXDelta		= !CameraData+20	;\ how much the camera moved last time its position updated
		!CameraYDelta		= !CameraData+22	;/
		!CameraSpeedMem1	= !CameraData+26	; highest speed influence player has recently had on camera (8.8 format)
		!CameraSpeedMem2	= !CameraData+24	; player speed influence on camera, never set if 0
		!CameraPauseTimer	= !CameraData+28	; while set, !CameraSpeedMem2 does not slow down
		!CameraXSpeed		= !CameraData+30	;\ used internally in camera code
		!CameraYSpeed		= !CameraData+32	;/
>>>>>>> Stashed changes

		!CameraYDir		= !CameraData+34	; 0 = not moving vertically, 1 = moving down, -1 = moving up


<<<<<<< Updated upstream
		!CameraBoxL		= $6AC0
		!CameraBoxU		= $6AC2
		!CameraBoxR		= $6AC4
		!CameraBoxD		= $6AC6
		!CameraForbiddance	= $6AC8
					; reg2     reg1
					; yyyyyxxx xxssssss
					; s = which screen of camera box that forbiddance box starts at
					; x = number of screens for forbiddance box to span horizontally (0=1)
					; y = number of screens for forbiddance box to span vertically (0=1)

		!SmoothCamera		= $6AF6			; enables smooth camera (always on with camera box)


=======
		!SpriteEraseMode	= $5C
		; by default, sprites are ereased if they go too far off-screen
		; ALL off-screen checks are ignored if the 0x80 bit in tweaker 3 is set
		; 00 = camera box will freeze sprites outside the border (threshold = 0x20)
		; 01 = camera box will erase sprites outside the border (threshold = 0x20)
		; 02 = camera box will freeze sprites outside the border (threshold = 0x60)
		; 03 = camera box will erase sprites outside the border (threshold = 0x60)
		; 04 = camera box does not affect sprites, sprites will use their default off-screen code


		; set 0x40 bit to disable normal off-screen check for sprites inside camera box
		; set 0x80 bit to disable normal off-screen check




		; these are set by VR3, but not used by it
		; instead, these define the area (level coords) that block updates may occur in
		; any block update outside the zip box only needs to update the map16 table
>>>>>>> Stashed changes
		!BG1ZipBoxL		= $45
		!BG1ZipBoxR		= $47
		!BG1ZipBoxU		= $49
		!BG1ZipBoxD		= $4B
		!BG2ZipBoxL		= $4D
		!BG2ZipBoxR		= $4F
		!BG2ZipBoxU		= $51
		!BG2ZipBoxD		= $53

		!UpdateBG1Row		= $6908
		!UpdateBG1Column	= $690A
		!UpdateBG2Row		= $690C
		!UpdateBG2Column	= $690E

		!BG1ZipColumnX		= $61F0
		!BG1ZipColumnY		= $61F2
		!BG1ZipRowX		= $61F4
		!BG1ZipRowY		= $61F6
		!BG2ZipColumnX		= $61F8
		!BG2ZipColumnY		= $61FA
		!BG2ZipRowX		= $61FC
		!BG2ZipRowY		= $61FE


		!LevelEntry		= $741E			; overwrites yoshi wings flag and skip yoshi intro flag
		!LevelToBeat		= $7420			; level num to beat when BeatLevel is called (equal to !Level by default)
		!Level			= $610B
		!BossData		= $66F9			; 7 bytes
		!RNGtable		= $6660			; 32 random values, a new one is generated each frame
		!RNG			= $6700			; most recently generated RN

		!RAMcode_flag		= $6020			; 0x1234 = Execute, anything else = ignore
		!RAMcode_offset		= $6022			; used for RAM code generation
		!RAMcode		= $404A00

<<<<<<< Updated upstream
=======
		!GlobalLight1		= $6024			; first set of light RGB to use for auto mixing
		!GlobalLight2		= $6025			; second set of light RGB to use for auto mixing
		!GlobalLightMix		= $6026			; balance between global light 1 and global light 2 (0 = all 1, 32 = all 2)
		!GlobalLightMixPrev	= $6027			; used to keep track of when auto mixer should run (leave both at 0 to not use)



		!GFX_status		= $418000
		!Part_status		= !GFX_status+$000	; 512 entries for parts (9-bit, 2 bytes each)
		!Set_status		= !GFX_status+$400	; 128 entries for sets (9-bit, 2 bytes each)
		!SuperSet_status	= !GFX_status+$500	; 64 entries for super sets (9-bit, 2 bytes each)
		!Palset_status		= !GFX_status+$580	; 128 entries for palsets, 7+1 bit, 1 byte each
		!BG_status		= !GFX_status+$600	; 256 entries for BG objects (8-bit, 1 byte each)
		!SD_status		= !GFX_status+$700	; 256 entries for super-dynamic files, 6+2 bit, 1 byte each


		macro def_GFX(name)
			!GFX_<name> := !GFX_status+!Temp
			!GFX_<name>_tile := !GFX_<name>
			!GFX_<name>_prop := !GFX_<name>+1
			!GFX_<name>_offset := !Temp
			!Temp := !Temp+2
		endmacro

		macro def_BG(name)
			!GFX_<name> := !GFX_status+!Temp
			!GFX_<name>_offset := !Temp
			!Temp := !Temp+1
		endmacro


	; GFX parts
		!Temp = 0

		; simple enemies
		%def_GFX(Goomba)
		%def_GFX(Bobomb)
		%def_GFX(Spiny)
		%def_GFX(SpikeTop)
		%def_GFX(BuzzyBeetle)
		%def_GFX(SwooperBat)
		%def_GFX(MontyMole)
		%def_GFX(MegaMole)
		%def_GFX(MiniMole)
		%def_GFX(HoppingFlame)
		%def_GFX(Lakitu)
		%def_GFX(Wiggler)
		%def_GFX(Thwomp)
		%def_GFX(Thwimp)
		%def_GFX(Podoboo)
		%def_GFX(DiagPodoboo)
		%def_GFX(BallAndChain)
		%def_GFX(FallingSpike)
		%def_GFX(WoodenSpike)
		%def_GFX(Grinder)
		%def_GFX(Sparky)
		%def_GFX(HotHead)
		%def_GFX(MechaKoopa)
		%def_GFX(SpikeBall)
		%def_GFX(Fuzzy)
		%def_GFX(SuperKoopa)
		%def_GFX(Pokey)
		%def_GFX(Ninji)
		%def_GFX(Thif)
		%def_GFX(NetKoopa)
		%def_GFX(BulletBill)
		%def_GFX(BulletBillDiag)
		%def_GFX(BulletBillUp)
		%def_GFX(BanzaiBill)
		%def_GFX(BowlingBall)
		%def_GFX(FishBone)
		%def_GFX(DryBones)
		%def_GFX(BonyBeetle)
		%def_GFX(Fish)
		%def_GFX(BlurpFish)
		%def_GFX(PorcuPuffer)
		%def_GFX(Dolphin)
		%def_GFX(Urchin)
		%def_GFX(TorpedoTed)
		%def_GFX(Reznor)
		%def_GFX(Birdo)
		%def_GFX(Monkey)
		%def_GFX(FlamePillar)
		%def_GFX(GasBubble)
		%def_GFX(UltraFuzzy)
		%def_GFX(TarCreeperHands)
		%def_GFX(Boo)
		%def_GFX(Eerie)
		%def_GFX(FishingBoo)
		%def_GFX(BooHoo)

		; beneficial sprites
		%def_GFX(Starman)
		%def_GFX(PSwitch)
		%def_GFX(SpringBoard)
		%def_GFX(Bumper)
		%def_GFX(PBalloon)
		%def_GFX(Sign)
		%def_GFX(Key)
		%def_GFX(SmallBird)
		%def_GFX(YoshiCoin)
		%def_GFX(Chest)

		; platforms
		%def_GFX(GrowingPipe)
		%def_GFX(CastleBlock)
		%def_GFX(FloatingSkulls)
		%def_GFX(BrownGreyPlat)
		%def_GFX(CheckerPlat)
		%def_GFX(RockPlat)
		%def_GFX(OrangePlat)
		%def_GFX(ScalePlat)
		%def_GFX(CastlePlat)
		%def_GFX(CarrotPlat)
		%def_GFX(TimerPlat)
		%def_GFX(MovingLedge)
		%def_GFX(TerrainPlat)
		%def_GFX(Elevator)

		; support sprite parts
		%def_GFX(Shield)
		%def_GFX(Portal)

		; sprite support parts
		%def_GFX(Football)
		%def_GFX(ChuckRock)
		%def_GFX(Rope)
		%def_GFX(Chainsaw)
		%def_GFX(Mechanism)
		%def_GFX(StatueFireball)
		%def_GFX(LakituCloud)
		%def_GFX(BossFireball)
		%def_GFX(SmallFireball)
		%def_GFX(ReznorFireball)
		%def_GFX(Fireball32x32)
		%def_GFX(EnemyFireball)
		%def_GFX(LotusPollen)
		%def_GFX(Baseball)
		%def_GFX(WaterEffects)
		%def_GFX(LavaEffects)
		%def_GFX(LightningEffects)
		%def_GFX(Parachute)
		%def_GFX(Tray)
		%def_GFX(PlantStalk)
		%def_GFX(Wings)		; bat wings
		%def_GFX(AngelWings)
		%def_GFX(Hammer)
		%def_GFX(DinoFire)
		%def_GFX(SmushedKoopa)
		%def_GFX(Shell)
		%def_GFX(FelMagic)
		%def_GFX(Bone)
		%def_GFX(SkeletonRubble)
		%def_GFX(SlimeParticles)
		%def_GFX(SnoreZ)

		; rex support parts
		%def_GFX(RexLegs1)
		%def_GFX(RexLegs2)
		%def_GFX(RexSmall)
		%def_GFX(RexHat1)
		%def_GFX(RexHat2)
		%def_GFX(RexHat3)
		%def_GFX(RexHat4)
		%def_GFX(RexHat5)
		%def_GFX(RexHat6)
		%def_GFX(RexHat7)
		%def_GFX(RexHelmet)
		%def_GFX(RexBag1)
		%def_GFX(RexBag2)
		%def_GFX(RexBag3)
		%def_GFX(RexBag4)
		%def_GFX(RexSword)

		; player support parts
		%def_GFX(LuigiFireball)


		; special particle parts
		%def_GFX(LeafParticle)
		%def_GFX(TinyCoin)
		%def_GFX(SmallNumbers)



	; GFX sets
		!Temp = $400

		; vanilla enemies
		%def_GFX(GoombaSlave)
		%def_GFX(ParaGoomba)
		%def_GFX(PiranhaPlant)	; stalk, fire
		%def_GFX(Magikoopa)
		%def_GFX(Blargg)	; lava parts
		%def_GFX(VolcanoLotus)
		%def_GFX(BooBlock)
		%def_GFX(BigBoo)
		%def_GFX(SumoBro)
		%def_GFX(SumoLightning)
		%def_GFX(BowserStatue)
		%def_GFX(Chuck)
		%def_GFX(AmazingHammerBro)
		%def_GFX(DinoRhino)
		%def_GFX(DinoTorch)
		%def_GFX(ShellessKoopa)
		%def_GFX(KickerKoopa)
		%def_GFX(DryBonesThrower)
		%def_GFX(BulletBillCardinals)
		%def_GFX(ParachuteGoomba)
		%def_GFX(ParachuteBobomb)
		%def_GFX(RipVanFish)

		; neutral things
		%def_GFX(Blocks)	; includes wings

		; custom enemies
		%def_GFX(Rex)
		%def_GFX(HammerRex)
		%def_GFX(FlyingRex)
		%def_GFX(Conjurex)
		%def_GFX(MoleWizard)
		%def_GFX(KompositeKoopa)
		%def_GFX(CoinGolem)



	; super sets
		!Temp = $500
		%def_GFX(ParaKoopa)
		%def_GFX(ParaKoopaBlue)
		%def_GFX(Koopa)
		%def_GFX(KoopaBlue)
		%def_GFX(SuperKoopaKicker)
		%def_GFX(ParachuteGen)
		%def_GFX(CarrierBubble)
		%def_GFX(ExplodingBlock)




	; BG objects
		!Temp = $600
		%def_BG(BushFrame1)
		%def_BG(BushFrame2)
		%def_BG(BushFrame3)
		%def_BG(Window)
		%def_BG(WindowBroken)
		%def_BG(CannonIdle)
		%def_BG(CannonTilt1)
		%def_BG(CannonTilt2)
		%def_BG(CannonFire1)
		%def_BG(CannonFire2)
		%def_BG(CableTiles)
		%def_BG(PoleFrame1)
		%def_BG(PoleFrame2)
		%def_BG(PoleFrame3)
		%def_BG(TrashCan)

>>>>>>> Stashed changes

		!GlobalPalset1		= $6024			; which sprite palset variation to use
		!GlobalPalset2		= $6025			; if mixing is used, this is which sprite palset variation to use for mixing
		!GlobalPalsetMix	= $6026			; balance between palset 1 and palset 2
								; 0 = 100% palset 1
								; 16 = 50% palset 1, 50% palset 2
								; 32 = 0% palset 1, 100% palset 2

		!GlobalLight1		= !GlobalPalset1	; alt names
		!GlobalLight2		= !GlobalPalset2
		!GlobalLightMix		= !GlobalPalsetMix




	; these hold unpacked information for extra file tilemaps
		!Extra_Tiles		= $74C8
		!Extra_Prop		= !Extra_Tiles+$26

		!Tile_Wings		= !Extra_Tiles+$00
		!Tile_Shell		= !Extra_Tiles+$01
		!Tile_LakituCloud	= !Extra_Tiles+$02
		!Tile_Hammer		= !Extra_Tiles+$03
		!Tile_SmallFireball	= !Extra_Tiles+$04
		!Tile_ReznorFireball	= !Extra_Tiles+$05
		!Tile_LotusPollen	= !Extra_Tiles+$06
		!Tile_Baseball		= !Extra_Tiles+$07
		!Tile_WaterEffects	= !Extra_Tiles+$08
		!Tile_LavaEffects	= !Extra_Tiles+$09
		!Tile_SkeletonRubble	= !Extra_Tiles+$0A
		!Tile_Bone		= !Extra_Tiles+$0B
		!Tile_PlantStalk	= !Extra_Tiles+$0C
		!Tile_BombStar		= !Extra_Tiles+$0D
		!Tile_Parachute		= !Extra_Tiles+$0E
		!Tile_Mechanism		= !Extra_Tiles+$0F
		!Tile_DinoFire		= !Extra_Tiles+$10
		!Tile_AngelWings	= !Extra_Tiles+$11
		!Tile_RexLegs1		= !Extra_Tiles+$12
		!Tile_RexLegs2		= !Extra_Tiles+$13
		!Tile_RexSmall		= !Extra_Tiles+$14

		!Prop_Wings		= !Extra_Prop+$00
		!Prop_Shell		= !Extra_Prop+$01
		!Prop_LakituCloud	= !Extra_Prop+$02
		!Prop_Hammer		= !Extra_Prop+$03
		!Prop_SmallFireball	= !Extra_Prop+$04
		!Prop_ReznorFireball	= !Extra_Prop+$05
		!Prop_LotusPollen	= !Extra_Prop+$06
		!Prop_Baseball		= !Extra_Prop+$07
		!Prop_WaterEffects	= !Extra_Prop+$08
		!Prop_LavaEffects	= !Extra_Prop+$09
		!Prop_SkeletonRubble	= !Extra_Prop+$0A
		!Prop_Bone		= !Extra_Prop+$0B
		!Prop_PlantStalk	= !Extra_Prop+$0C
		!Prop_BombStar		= !Extra_Prop+$0D
		!Prop_Parachute		= !Extra_Prop+$0E
		!Prop_Mechanism		= !Extra_Prop+$0F
		!Prop_DinoFire		= !Extra_Prop+$10
		!Prop_AngelWings	= !Extra_Prop+$11
		!Prop_RexLegs1		= !Extra_Prop+$12
		!Prop_RexLegs2		= !Extra_Prop+$13
		!Prop_RexSmall		= !Extra_Prop+$14


		!GFX_status		= $418100

		!GFX_Koopa		= !GFX_status+$00
		!GFX_BobOmb		= !GFX_status+$01
		!GFX_Key		= !GFX_status+$02
		!GFX_Goomba		= !GFX_status+$03
		!GFX_PiranhaPlant	= !GFX_status+$04
		!GFX_BulletBill		= !GFX_status+$05
		!GFX_Starman		= !GFX_status+$06
		!GFX_SpringBoard	= !GFX_status+$07
		!GFX_PSwitch		= !GFX_status+$08
		!GFX_Blocks		= !GFX_status+$09
		!GFX_WallBouncer	= !GFX_status+$0A
		!GFX_Sign		= !GFX_status+$0B
		!GFX_BooBlock		= !GFX_status+$0C
		!GFX_Spiny		= !GFX_status+$0D
		!GFX_HoppingFlame	= !GFX_status+$0E
		!GFX_GrowingPipe	= !GFX_status+$0F
		!GFX_Lakitu		= !GFX_status+$10
		!GFX_PBalloon		= !GFX_status+$11
		!GFX_Wiggler		= !GFX_status+$12
		!GFX_Magikoopa		= !GFX_status+$13
		!GFX_NetKoopa		= !GFX_status+$14
		!GFX_Thwomp		= !GFX_status+$15
		!GFX_Thwimp		= !GFX_status+$16
		!GFX_Podoboo		= !GFX_status+$17
		!GFX_BallAndChain	= !GFX_status+$18
		!GFX_FishBone		= !GFX_status+$19
		!GFX_FallingSpike	= !GFX_status+$1A
		!GFX_BouncingPodoboo	= !GFX_status+$1B
		!GFX_MovingBlock	= !GFX_status+$1C
		!GFX_BuzzyBeetle	= !GFX_status+$1D
		!GFX_Football		= !GFX_status+$1E
		!GFX_SpikeTop		= !GFX_status+$1F
		!GFX_FloatingSkulls	= !GFX_status+$20
		!GFX_Blargg		= !GFX_status+$21
		!GFX_SwooperBat		= !GFX_status+$22
		!GFX_ChuckRock		= !GFX_status+$23
		!GFX_BrownGreyPlat	= !GFX_status+$24
		!GFX_CheckerPlat	= !GFX_status+$25
		!GFX_RockPlat		= !GFX_status+$26
		!GFX_OrangePlat		= !GFX_status+$27
		!GFX_RopeMechanism	= !GFX_status+$28
		!GFX_Chainsaw		= !GFX_status+$29
		!GFX_Fuzzy		= !GFX_status+$2A
		!GFX_ScalePlat		= !GFX_status+$2B
		!GFX_SpikeBall		= !GFX_status+$2C
		!GFX_Urchin		= !GFX_status+$2D
		!GFX_RipVanFish		= !GFX_status+$2E
		!GFX_Dolphin		= !GFX_status+$2F
		!GFX_TorpedoTed		= !GFX_status+$30
		!GFX_BlurpFish		= !GFX_status+$31
		!GFX_PorcuPuffer	= !GFX_status+$32
		!GFX_SumoLightning	= !GFX_status+$33
		!GFX_MontyMole		= !GFX_status+$34
		!GFX_Pokey		= !GFX_status+$35
		!GFX_SuperKoopa		= !GFX_status+$36
		!GFX_VolcanoLotus	= !GFX_status+$37
		!GFX_SumoBro		= !GFX_status+$38
		!GFX_Ninji		= !GFX_status+$39
		!GFX_Spotlight		= !GFX_status+$3A
		!GFX_SmallBird		= !GFX_status+$3B
		!GFX_BigBoo		= !GFX_status+$3C
		!GFX_Boo		= !GFX_status+$3D
		!GFX_ClimbingDoor	= !GFX_status+$3E
		!GFX_CastlePlat		= !GFX_status+$3F
		!GFX_Grinder		= !GFX_status+$40
		!GFX_HotHead		= !GFX_status+$41
		!GFX_WoodenSpike	= !GFX_status+$42
		!GFX_StatueFireball	= !GFX_status+$43
		!GFX_BowserStatue	= !GFX_status+$44
		!GFX_Fish		= !GFX_status+$45
		!GFX_LakituCloud	= !GFX_status+$46
		!GFX_Chuck		= !GFX_status+$47
		!GFX_AmazingHammerBro	= !GFX_status+$48
		!GFX_BanzaiBill		= !GFX_status+$49
		!GFX_Rex		= !GFX_status+$4A
		!GFX_CarrotPlat		= !GFX_status+$4B
		!GFX_TimerPlat		= !GFX_status+$4C
		!GFX_MegaMole		= !GFX_status+$4D
		!GFX_DinoRhino		= !GFX_status+$4E
		!GFX_DinoTorch		= !GFX_status+$4F
		!GFX_BossFireball	= !GFX_status+$50
		!GFX_BowlingBall	= !GFX_status+$51
		!GFX_MechaKoopa		= !GFX_status+$52
		!GFX_Reznor		= !GFX_status+$53
		!GFX_DryBones		= !GFX_status+$54
		!GFX_BonyBeetle		= !GFX_status+$55
		!GFX_Eerie		= !GFX_status+$56
		!GFX_CarrierBubble	= !GFX_status+$57
		!GFX_FishingBoo		= !GFX_status+$58
		!GFX_Sparky		= !GFX_status+$59

		!GFX_Wings		= !GFX_status+$5A
		!GFX_Shell		= !GFX_status+$5B
		!GFX_LakituCloud	= !GFX_status+$5C
		!GFX_Hammer		= !GFX_status+$5D
		!GFX_SmallFireball	= !GFX_status+$5E
		!GFX_ReznorFireball	= !GFX_status+$5F
		!GFX_LotusPollen	= !GFX_status+$60
		!GFX_Baseball		= !GFX_status+$61
		!GFX_WaterEffects	= !GFX_status+$62
		!GFX_LavaEffects	= !GFX_status+$63
		!GFX_SkeletonRubble	= !GFX_status+$64
		!GFX_Bone		= !GFX_status+$65
		!GFX_PlantStalk		= !GFX_status+$66
		!GFX_BombStar		= !GFX_status+$67
		!GFX_Parachute		= !GFX_status+$68
		!GFX_Mechanism		= !GFX_status+$69
		!GFX_DinoFire		= !GFX_status+$6A
		!GFX_AngelWings		= !GFX_status+$6B
		!GFX_RexLegs1		= !GFX_status+$6C
		!GFX_RexLegs2		= !GFX_status+$6D
		!GFX_RexSmall		= !GFX_status+$6E
		!GFX_LuigiFireball	= !GFX_status+$6F

		!GFX_GoombaSlave	= !GFX_status+$80
		!GFX_VillagerRex	= !GFX_status+$81
		!GFX_HammerRex		= !GFX_status+$82
		!GFX_NoviceShaman	= !GFX_status+$83
		!GFX_MagicMole		= !GFX_status+$84
		!GFX_Thif		= !GFX_status+$85
		!GFX_KompositeKoopa	= !GFX_status+$86
		!GFX_Birdo		= !GFX_status+$87
		!GFX_Bumper		= !GFX_status+$88
		!GFX_Monkey		= !GFX_status+$89
		!GFX_TerrainPlat	= !GFX_status+$8A
		!GFX_YoshiCoin		= !GFX_status+$8B
		!GFX_CoinGolem		= !GFX_status+$8C
		!GFX_BooHoo		= !GFX_status+$8D
		!GFX_FlamePillar	= !GFX_status+$8E
		!GFX_ParachuteGoomba	= !GFX_status+$8F
		!GFX_ParachuteBobomb	= !GFX_status+$90
		!GFX_MovingLedge	= !GFX_status+$91
		!GFX_SuperKoopa2	= !GFX_status+$92
		!GFX_GasBubble		= !GFX_status+$93
		!GFX_RexHat1		= !GFX_status+$94
		!GFX_RexHat2		= !GFX_status+$95
		!GFX_RexHat3		= !GFX_status+$96
		!GFX_RexHat4		= !GFX_status+$97
		!GFX_RexHat5		= !GFX_status+$98
		!GFX_RexHat6		= !GFX_status+$99
		!GFX_RexHelmet		= !GFX_status+$9A
		!GFX_RexBag1		= !GFX_status+$9B
		!GFX_RexBag2		= !GFX_status+$9C
		!GFX_RexBag3		= !GFX_status+$9D
		!GFX_RexBag4		= !GFX_status+$9E
		!GFX_RexSword		= !GFX_status+$9F
		!GFX_FlyingRex		= !GFX_status+$A0


		!GFX_Dynamic		= !GFX_status+$FF	; this one is not used by sprite files, it marks the start of the dynamic area

	; each file has a marker for where it is loaded (unloaded = 0)
	; format: pyyyxxxx
	; p is highest bit of num (T in prop)
	; yyy is which 16px row it starts at (double to get hi nybble of num)
	; xxxx is which tile it starts on (lo nybble of num)
	; 0 means start of SP1, which is why that means unloaded
	; start of SP2 is 0x40
	; start of SP3 is 0x80
	; start of SP4 is 0xC0

		!SD_Hammer		= !GFX_status+$100
		!SD_PlantHead		= !GFX_status+$101
		!SD_Bone		= !GFX_status+$102
		!SD_Fireball8x8		= !GFX_status+$103
		!SD_Fireball16x16	= !GFX_status+$104
		!SD_Goomba		= !GFX_status+$105
		!SD_LuigiFireball	= !GFX_status+$106
		!SD_Baseball		= !GFX_status+$107

	; super dynamic format:
	; bbpppppp
	; bb = bank
	; 00 = $7E
	; 01 = $7F
	; 10 = $40
	; 11 = $41
	; pppppp = location in bank (KB)
	;
<<<<<<< Updated upstream
	; address of GFX = bank [bb], hi byte [pppppp * 4], lo byte 0
=======
	; address of GFX = bank [bb translated], hi byte [pppppp--], lo byte 0

	macro def_SD(name)
		!SD_<name> := !SD_status+!Temp
		!SD_<name>_offset := !Temp
		!Temp := !Temp+1
	endmacro

		!Temp = 0
		%def_SD(Hammer)
		%def_SD(PlantHead)
		%def_SD(Bone)
		%def_SD(Fireball8x8)
		%def_SD(Fireball16x16)
		%def_SD(Goomba)
		%def_SD(LuigiFireball)
		%def_SD(Baseball)
		%def_SD(KadaalLinear)
		%def_SD(Fireball32x32)
		%def_SD(EnemyFireball)
		%def_SD(LuigiWallRun)






	; palset list
	;
	; make sure the order matches the order of palsets in SP_Files

	macro def_palset(name)
		!palset_<name> := !temppalset
		!addr_palset_<name> := !Palset_status+!temppalset
		!temppalset := !temppalset+1
	endmacro

		!temppalset = 1

		; player palsets
		%def_palset(mario)
		%def_palset(luigi)
		%def_palset(kadaal)
		%def_palset(leeway)
		%def_palset(alter)
		%def_palset(peach)
		%def_palset(placeholder4)
		%def_palset(placeholder5)
		%def_palset(mario_fire)

		; default palsets
		%def_palset(default_yellow)
		%def_palset(default_blue)
		%def_palset(default_red)
		%def_palset(default_green)

		; generic palsets
		%def_palset(generic_grey)
		%def_palset(generic_ghost_blue)
		%def_palset(generic_lightblue)

		; special palsets
		%def_palset(special_wizrex)

		%def_palset(special_flash_white)
		%def_palset(special_flash_black)
		%def_palset(special_flash_red)
		%def_palset(special_flash_green)
		%def_palset(special_flash_blue)
		%def_palset(special_flash_yellow)
		%def_palset(special_flash_caster)
		%def_palset(special_kingking_blue)
		%def_palset(special_kingking_red)

		%def_palset(special_toad)
		%def_palset(special_melody)

>>>>>>> Stashed changes


		!Palset8		= $6028
		!Palset9		= $6029
		!PalsetA		= $602A
		!PalsetB		= $602B
		!PalsetC		= $602C
		!PalsetD		= $602D
		!PalsetE		= $602E
		!PalsetF		= $602F

	; index to palset table




	; SP_Files list
	;
	; make sure the order matches the dl list at the start of SP_Files
	; this list only affects defines, it does not insert anything into the ROM

	macro def_file(name)
		!File_<name> := !tempfile
		!tempfile := !tempfile+3
	endmacro

		!tempfile = 0

		; real time linear files

		; player files
		%def_file(Mario_Expand)
		%def_file(Mario_Supplement)
		%def_file(Luigi)
		%def_file(Kadaal)
		%def_file(Leeway)
		%def_file(Leeway_Sword)
		%def_file(PlayerObjects)

		; dynamic sprite files
		%def_file(HappySlime)
		%def_file(AggroRex)
		%def_file(Wizrex)
		%def_file(TarCreeper_Body)
		%def_file(EliteKoopa)

		%def_file(NPC_Survivor)
		%def_file(NPC_Tinkerer)
		%def_file(NPC_Melody)
		%def_file(MiniMech)

		; boss files
		%def_file(CaptainWarrior)
		%def_file(CaptainWarrior_Axe)
		%def_file(Kingking)
		%def_file(LakituLovers)
		%def_file(LavaLord)

		; color gradients and palette tables
		%def_file(level06_night)

		; fonts and text box borders
		%def_file(default_font)
		%def_file(classic_font)
		%def_file(default_border)

		; extra stuff, sprite BG and such
		%def_file(Sprite_BG_1)


	; palset list
	;
	; make sure the order matches the order of palsets in SP_Files

	macro def_palset(name)
		!palset_<name> := !temppalset
		!temppalset := !temppalset+1
	endmacro

		!temppalset = 0

		; player palsets
		%def_palset(mario)
		%def_palset(luigi)
		%def_palset(kadaal)
		%def_palset(leeway)
		%def_palset(placeholder1)
		%def_palset(placeholder2)
		%def_palset(placeholder3)
		%def_palset(placeholder4)
		%def_palset(placeholder5)
		%def_palset(mario_fire)

		; default palsets
		%def_palset(default_yellow)
		%def_palset(default_blue)
		%def_palset(default_red)
		%def_palset(default_green)

		; generic palsets
		%def_palset(generic_grey)
		%def_palset(generic_ghost_blue)
		%def_palset(generic_lightblue)

		; special palsets
		%def_palset(special_wizrex)

		%def_palset(special_flash_white)
		%def_palset(special_flash_black)
		%def_palset(special_flash_red)
		%def_palset(special_flash_green)
		%def_palset(special_flash_blue)




		!Map16Remap		= $418000
			; 256 bytes, 1 for each map16 page
			; format: d-----tt
			; d - disable remap
			; tt - tt bits to use for remapped pages
			; if d is clear, the tile's tt bits are replaced by the remap tt bits


		!BigRAM			= $6080			; if this is moved to $3700, !TransformGFX has to be recoded
								; all defines have to have their highest bit cleared ($80-$FF -> $00-$7F)
								; and DP should be set to !BigRAM instead of !BigRAM-$80

		!P1CoinIncrease		= $6F34			;\ Write here to increment player coins
		!P2CoinIncrease		= $6F35			;/
		!P1Coins		= $6F36			; > 2 bytes, goes to 9999
		!P2Coins		= $6F38			; > 2 bytes, goes to 9999
		!CoinSound		= $6F3A			; Timer until next coin sound is a-go
		!CoinOwner		= $6F3B			; Indicates who will get the next coin spawned
								; 0 = Mario, 1 = P1 PCE, 2 = P2 PCE

		; Coin hoard is with SRAM stuff

		!StatusBar		= $6EF9			; 32 bytes, tile numbers for status bar



		!P1Base			= $3600
		!P2Base			= $3680
		!P2Status		= !P2Base+$00
		!P2HP			= !P2Base+$01
		!P2XPosLo		= !P2Base+$02
		!P2XPosHi		= !P2Base+$03
		!P2XSpeed		= !P2Base+$04
		!P2XFraction		= !P2Base+$05
		!P2YPosLo		= !P2Base+$06
		!P2YPosHi		= !P2Base+$07
		!P2YSpeed		= !P2Base+$08
		!P2YFraction		= !P2Base+$09
		!P2Platform		= !P2Base+$0A
		!P2FallSpeed		= !P2Base+$0B
		!P2Gravity		= !P2Base+$0C
		!P2Direction		= !P2Base+$0D
		!P2Blocked		= !P2Base+$0E
		!P2Offscreen		= !P2Base+$0F
		!P2KillCount		= !P2Base+$10
		!P2HurtTimer		= !P2Base+$11
		!P2Buffer		= !P2Base+$12
		!P2Map16Index		= !P2Base+$13
		!P2Map16Table		= !P2Base+$14

		!P2Slope		= !P2Base+$1C
		!P2Water		= !P2Base+$1D		; dwl----c
								; d = ducking
								; w = water
								; l = lava
								; c = climbing
		!P2Invinc		= !P2Base+$1E


	; MARIO

		!P2FlareDrill		= !P2Base+$1F		; used by Mario
		!P2Overdrive		= !P2Base+$20		; Mario's ultimate move
		!P2VectorBlocked	= !P2Base+$21		; prevents mario from vectoring into solid objects
		!P2FireFlash		= !P2Base+$22		; used to flash Mario upon getting fire


	; LUIGI

		!P2Carry		= !P2Base+$1F		; used by Luigi and Peach
		!P2PickUp		= !P2Base+$21		; forces crouch for Luigi
		!P2TurnTimer		= !P2Base+$22
					; 23 used by kick
					; 24 index mem 1
					; 25 index mem 2
		!P2SpinAttack		= !P2Base+$26
		!P2FireTimer		= !P2Base+$27
		!P2FireIndex		= !P2Base+$28
		!P2FireLife		= !P2Base+$29


	; KADAAL / LEEWAY

		!P2PoseTimer		= !P2Base+$1F		; Kadaal

		!P2ClimbFirst		= !P2Base+$1F		; Flag set during first frame of Leeway's climb

		!P2Senku		= !P2Base+$20
		!P2Punch1		= !P2Base+$21
		!P2Punch2		= !P2Base+$22
		!P2Kick			= !P2Base+$23		; also Luigi's kick timer

		!P2DashJump		= !P2Base+$20
		!P2SwordAttack		= !P2Base+$21
		!P2SwordTimer		= !P2Base+$22
		!P2Climb		= !P2Base+$23		; used by Mario (ledge) and Leeway

		!P2IndexMem1		= !P2Base+$24
		!P2IndexMem2		= !P2Base+$25

		!P2DashTimerR1		= !P2Base+$26		; Also Leeway's main dash leniency timer
								; for Mario, this is how many frames he has to hold B
								;  to fast swim
								;  set to its default value every frame B is let go

		!P2DashTimerR2		= !P2Base+$27		; Also Leeway's crouch timer
								; for Mario, this is an extra animation timer
								;  it is used for the fast swim


		!P2DashTimerL1		= !P2Base+$28		; Also ORA'd to Leeway's $6DA3 if L2 is set
		!P2DashTimerL2		= !P2Base+$29		; Also Leeway's Timer for L1



	; ALTER

		!P2Element		= !P2Base+$20
		!P2Telekinesis		= !P2Base+$21
		!P2Launch		= !P2Base+$22		; highest bit for direction, lo 5 bits for sprite index
		!P2StasisSpell		= !P2Base+$23
		!P2DestroyXLo		= !P2Base+$24
		!P2DestroyXHi		= !P2Base+$25
		!P2DestroyYLo		= !P2Base+$26
		!P2DestroyYHi		= !P2Base+$27
		!P2DestroyTimer		= !P2Base+$28
		!P2FamiliarXLo		= !P2Base+$29
		!P2FamiliarXHi		= !P2Base+$2A
	; 2B-2D for animation
		!P2FamiliarYLo		= !P2Base+$2E
		!P2FamiliarYHi		= !P2Base+$2F
		!P2DoubleJump		= !P2Base+$60
		!P2LaunchTimer		= !P2Base+$61
		!P2Mana			= !P2Base+$62
		!P2ManaTimer		= !P2Base+$63
		!P2ManaLock		= !P2Base+$64



		!P2Dashing		= !P2Base+$2A		; Also Leeway's main dash timer
		!P2Anim			= !P2Base+$2B
		!P2AnimTimer		= !P2Base+$2C
		!P2TilesUsed		= !P2Base+$2D		; Also borrowed for lo prio function
		!P2SenkuDir		= !P2Base+$2E

<<<<<<< Updated upstream
		!P2ButtonDis		= !P2Base+$2E		; TRB'd to Leeway's $6DA3 if L2 is set
=======
		!Cutscene		= $6AC0			; 1 byte, cutscene index (0 = no cutscene)
		!CutsceneIndex		= !Cutscene+1		; 1 byte
		!CutsceneWait		= !Cutscene+2		; 1 byte
		!Cutscene6DA2		= !Cutscene+3		;\
		!Cutscene6DA3		= !Cutscene+4		; |
		!Cutscene6DA4		= !Cutscene+5		; |
		!Cutscene6DA5		= !Cutscene+6		; | input mirrors
		!Cutscene6DA6		= !Cutscene+7		; | (these override the normal regs)
		!Cutscene6DA7		= !Cutscene+8		; |
		!Cutscene6DA8		= !Cutscene+9		; |
		!Cutscene6DA9		= !Cutscene+10		;/
		!CutsceneSmoothness	= !Cutscene+11		; transition thing
>>>>>>> Stashed changes

		!P2SpinUsed		= !P2Base+$2F		; used by Luigi
		!P2SenkuUsed		= !P2Base+$2F		; used by Kadaal/Leeway

		!P2Pipe			= !P2Base+$30		; ddettttt
								; dd = direction:
								;	00: left
								;	01: right
								;	02: up
								;	03: down
								; e = enter (1) / exit (0)
								; t = timer (0x00-0x1F)

		!P2Anim2		= !P2Base+$31		; Used during 30fps mode
		!P2ClippingX		= !P2Base+$32		;\
		!P2ClippingY		= !P2Base+$34		; | 16-bit pointers to actual tables
		!P2ClippingSize		= !P2Base+$36		;/

<<<<<<< Updated upstream
		!P2SlantPipe		= !P2Base+$38
=======
		!PlayerWaiting		= $7871				; 00 = no wait, 01 = P1 waiting, 02 = P2 waiting, 03 = trigger exit
		!Players		= $7872				; 00 = no players alive, 01 = P1 alive, 02 = P2 alive, 03 = both players alive
>>>>>>> Stashed changes

		!P2PrevPlatform		= !P2Base+$39


		!P2VectorX		= !P2Base+$3A		;\
		!P2VectorY		= !P2Base+$3B		; |
		!P2VectorAccX		= !P2Base+$3C		; |
		!P2VectorAccY		= !P2Base+$3D		; | Can be used to create impulses (push/pull)
		!P2VectorMemX		= !P2Base+$3E		; |
		!P2VectorMemY		= !P2Base+$3F		; |
		!P2VectorTimeX		= !P2Base+$40		; |
		!P2VectorTimeY		= !P2Base+$41		;/

		!P2Stasis		= !P2Base+$42		; > Amount of time to lock player coords
		!P2GravityMod		= !P2Base+$43		;\ Can be used to increase or decrease gravity
		!P2GravityTimer		= !P2Base+$44		;/

		!P2XPosBackup		= !P2Base+$45		;\ 16-bit backups to use for collision
		!P2YPosBackup		= !P2Base+$47		;/

		!P2SpritePlatform	= !P2Base+$49		; Used by sprites to act as solid platforms

		!P2JumpLag		= !P2Base+$4A		; > How long Kadaal is stunned upon landing

		!P2ExtraInput1		= !P2Base+$4B		; > Overwrites $6DA2 ($15)
		!P2ExtraInput2		= !P2Base+$4C		; > Overwrites $6DA6 ($16)
		!P2ExtraInput3		= !P2Base+$4D		; > Overwrites $6DA4 ($17)
		!P2ExtraInput4		= !P2Base+$4E		; > Overwrites $6DA8 ($18)

		!P2Character		= !P2Base+$4F		; > Mirror of current character

		!P2Hurtbox		= !P2Base+$50		; 6 bytes:
		!P2Hitbox		= !P2Base+$56		; Xlo, Xhi
								; Ylo, Yhi
								; width, height

		!P2MaxHP		= !P2Base+$5C		; Current max HP for player

		!P2ClimbTop		= !P2Base+$5D		; Used by Leeway

		!P2ExternalAnim		= !P2Base+$5E		;\ Overrides normal function
		!P2ExternalAnimTimer	= !P2Base+$5F		;/

		!P2AllRangeSenku	= !P2Base+$60
		!P2ShellSlide		= !P2Base+$61
		!P2SenkuSmash		= !P2Base+$62		; Set if player is touching a smashable enemy this frame
		!P2ShellSpeed		= !P2Base+$63		; Allow maximum air speed when set
		!P2ShellDrill		= !P2Base+$64
		!P2BackDash		= !P2Base+$65


		!P2DashSlash		= !P2Base+$60		; limits Leeway's dash slashes to 1 per dash
		!P2ClimbTimer		= !P2Base+$61		; how long Leeway can use dino grip for
		!P2ComboDash		= !P2Base+$62		; combo dash can be used if this is nonzero
		!P2ComboDisable		= !P2Base+$63		; set during combo dash to prevent chaining


<<<<<<< Updated upstream
		!P2LockPalset		= !P2Base+$7C		; while nonzero, player palset will not be reloaded
		!P2Init			= !P2Base+$7D		; set to 1 after player has run its init routine
		!P2ExtraBlock		= !P2Base+$7E
			; written to !P2Blocked, then cleared
			; also applies to Mario
			; highest bit is written to water status


		!P2CoyoteTime		= !P2Base+$7F
			; also applies to Mario
			; it works like this:
=======
		!P2Basics		= !P2Base+$00
		!P2Physics		= !P2Base+$20
		!P2Hitbox		= !P2Base+$41
		!P2Custom		= !P2Base+$60			; 5 bytes at the end are an extension of basic


	; --BASICS--
		!P2Character		= !P2Basics+$00			; faster than reading !Characters
		!P2Init			= !P2Basics+$01			; 0 = run init code, 1 = do not run init code
		!P2Status		= !P2Basics+$02			; 0 = normal, 1 = dying, 2 = not in play
		!P2HP			= !P2Basics+$03			; current HP
		!P2MaxHP		= !P2Basics+$04			; max HP
		!P2Invinc		= !P2Basics+$05			; invincibility/i-frames timer
		!P2HurtTimer		= !P2Basics+$06			; hurt animation timer, does not give i-frames on its own
		!P2Anim			= !P2Basics+$07			; animation index
		!P2AnimTimer		= !P2Basics+$08			; animation timer, increments
		!P2Anim2		= !P2Basics+$09			; secondary animation index, used in 30FPS mode (co-op)
		!P2ExternalAnim		= !P2Basics+$0A			; overrides !P2Anim
		!P2ExternalAnimTimer	= !P2Basics+$0B			; timer for external anim, decrements
		!P2LockPalset		= !P2Basics+$0C			; 0 = reload palset each frame, 1 = do not reload palset
		!P2Direction		= !P2Basics+$0D			; 0 = left, 1 = right
		!P2Dir			= !P2Direction			; alt name
		!P2Hurtbox		= !P2Basics+$0E			;\
		!P2HurtboxXLo		= !P2Hurtbox+$00		; |
		!P2HurtboxXHi		= !P2Hurtbox+$01		; |
		!P2HurtboxYLo		= !P2Hurtbox+$02		; | hurtbox, stored so sprites/fusion sprites can access it
		!P2HurtboxYHi		= !P2Hurtbox+$03		; |
		!P2HurtboxW		= !P2Hurtbox+$04		; |
		!P2HurtboxH		= !P2Hurtbox+$05		;/
		!P2HurtboxX		= !P2HurtboxXLo			;\ alt names
		!P2HurtboxY		= !P2HurtboxYLo			;/
		!P2KillCount		= !P2Basics+$14			; kill count, usually cleared upon touching ground
		!P2Buffer		= !P2Basics+$15			;\
		!P2Buffer1		= !P2Buffer+$00			; | input buffer
		!P2Buffer2		= !P2Buffer+$01			;/
		!P2ExtraInput		= !P2Basics+$17			;\
		!P2ExtraInput1		= !P2ExtraInput+$00		; |
		!P2ExtraInput2		= !P2ExtraInput+$01		; | forced input
		!P2ExtraInput3		= !P2ExtraInput+$02		; | (each one is cleared after being applied)
		!P2ExtraInput4		= !P2ExtraInput+$03		;/
		!P2DropDownTimer	= !P2Basics+$1B			; set to 0xA when player pushes down, counts down, when set, player can drop through ledges with down
		!P2SlopeSpeed		= !P2Basics+$1C			; 00 = use default slope speed limiter, 01+ = do not limit
		!P2Crush		= !P2Basics+$1D			; if set, player currently has the crushing property of mario's spin jump

		!P2FlashPal		= !P2Basics+$1E
			; format:
			;	pppttttt
			;	p = which flash color to use
			;		0 = white
			;		1 = black
			;		2 = red
			;		3 = green
			;		4 = blue
			;		5 = yellow
			;		6 = cyan
			;		7 = purple
			;	t = timer
		!P2Entrance		= !P2Basics+$1F


	; --PHYSICS--
		!P2XFraction		= !P2Physics+$00		;\
		!P2XPos			= !P2XFraction+$01		; | 24-bit xpos
		!P2XPosLo		= !P2XFraction+$01		; |
		!P2XPosHi		= !P2XFraction+$02		;/
		!P2YFraction		= !P2Physics+$03		;\
		!P2YPos			= !P2YFraction+$01		; | 24-bit xpos
		!P2YPosLo		= !P2YFraction+$01		; |
		!P2YPosHi		= !P2YFraction+$02		;/

		!P2XLo			= !P2XPosLo			;\
		!P2XHi			= !P2XPosHi			; | shorter mirrors
		!P2YLo			= !P2YPosLo			; |
		!P2YHi			= !P2YPosHi			;/
		!P2X			= !P2XPosLo			;\ even shorter mirrors for 16-bit use
		!P2Y			= !P2YPosLo			;/


		!P2XSpeedFraction	= !P2Physics+$06		;\ 16-bit xspeed
		!P2XSpeed		= !P2XSpeedFraction+$01		;/
		!P2YSpeedFraction	= !P2Physics+$08		;\ 16-bit yspeed
		!P2YSpeed		= !P2YSpeedFraction+$01		;/

		!P2VectorX		= !P2Physics+$0A		; added to xspeed
		!P2VectorTimeX		= !P2VectorX+$01		; timer for X vector (decrements)
		!P2VectorAccX		= !P2VectorX+$02		; added to X vector each frame that timer is nonzero
		!P2VectorY		= !P2Physics+$0D		; added to yspeed
		!P2VectorTimeY		= !P2VectorY+$01		; timer for Y vector (decrements)
		!P2VectorAccY		= !P2VectorY+$02		; added to Y vector each frame that timer is nonzero

		!P2FallSpeed		= !P2Physics+$10		; maximum fall speed
		!P2Gravity		= !P2Physics+$11		; added to yspeed each frame in midair
		!P2GravityMod		= !P2Physics+$12		; same as gravity (added together), can be modified externally
		!P2Stasis		= !P2Physics+$13		; timer (decrements), while nonzero, speed is not applied

		!P2Blocked		= !P2Physics+$14		; bits: 1 = r, 2 = l, 4 = d, 8 = u, 10 = crushed
		!P2BlockedLayer		= !P2Physics+$15		; same as blocked, but only set by layer collision (not platform)
		!P2ExtraBlock		= !P2Physics+$16		; wwwcudlr (w = water flags, rest same as blocked) can be modified externally
		!P2InAir		= !P2Physics+$17		; 0 = on ground, slope or, platform, 4 = in midair
		!P2Platform		= !P2Physics+$18		; index (+1) of sprite that player is standing on

		!P2Slope		= !P2Physics+$19		; 0 = no slope, 1-4 = slope right, FC-FF = slope left
		!P2Water		= !P2Physics+$1A		; 0 = not in water, 40 = in water (set if center point touches water)
									; bits 0-4 show which parts are in water (same order as !P2Blocked)
									; usually, bit 4 (10) has to be set for water physics to be used

		!P2CoyoteTime		= !P2Physics+$1B		; coyote time status
			; format:
>>>>>>> Stashed changes
			;	j----ttt
			; every frame, t decrements
			; when t hits 0, j is cleared
			; if j i set when the character is on the ground, they will jump and this will be cleared
			; if t is nonzero, the character can jump even in midair
			; when the character is on the ground, t is set to 3
			; when the character presses jump in midair, j is set and t is set to 3
<<<<<<< Updated upstream
=======
		!P2CoyoteDisable	= !P2Physics+$1C		; speed added to player when using coyote jump, cleared when coyote is cleared (yyyyxxxx)


		!P2Ducking		= !P2Physics+$1D		; 0 = not ducking, 4 = ducking
		!P2Climbing		= !P2Physics+$1E		; 0 = not climbing, 1 = climbing

		!P2Pipe			= !P2Physics+$1F		; pipe status
			; format:
			;	ddettttt
			; dd = direction:
			;	00 (00) left
			;	01 (40) right
			;	02 (80) up
			;	03 (C0) down
			; e = enter (1) / exit (0)
			; t = timer (0x00-0x1F) 
		!P2SlantPipe		= !P2Physics+$20		; timer (decrements) for shooting out of slant pipe


	; --HITBOXES--
		; pre-loaded:
		!P2Hitbox1		= !P2Hitbox+$00			;\
		!P2Hitbox1XLo		= !P2Hitbox1+$00		; |
		!P2Hitbox1XHi		= !P2Hitbox1+$01		; |
		!P2Hitbox1YLo		= !P2Hitbox1+$02		; | hitbox 1
		!P2Hitbox1YHi		= !P2Hitbox1+$03		; |
		!P2Hitbox1W		= !P2Hitbox1+$04		; |
		!P2Hitbox1H		= !P2Hitbox1+$05		;/
		!P2Hitbox1X		= !P2Hitbox1XLo			; reference options
		!P2Hitbox1Y		= !P2Hitbox1YLo			; reference options
		!P2Hitbox1XSpeed	= !P2Hitbox1+$06		; x knockback
		!P2Hitbox1YSpeed	= !P2Hitbox1+$07		; y knockback
		!P2Hitbox1DisTimer	= !P2Hitbox1+$08		; interaction disable timer on hit
		!P2Hitbox1Hitstun	= !P2Hitbox1+$09		; hitstun
		!P2Hitbox1SFX1		= !P2Hitbox1+$0A		; SFX (!SPC1) on hit (0 = no SFX)
		!P2Hitbox1SFX2		= !P2Hitbox1+$0B		; SFX (!SPC4) on hit (0 = no SFX)
		; not pre-loaded:
		!P2Hitbox1IndexMem1	= !P2Hitbox1+$0C		;\ hitbox 1 index mem (1 bit per sprite)
		!P2Hitbox1IndexMem2	= !P2Hitbox1+$0D		;/
		!P2Hitbox1Shield	= !P2Hitbox1+$0E		; marks shield contact

		!P2Hitbox1IndexMem	= !P2Hitbox1IndexMem1		; alt name

		; pre-loaded:
		!P2Hitbox2		= !P2Hitbox+$0F			;\
		!P2Hitbox2XLo		= !P2Hitbox2+$00		; |
		!P2Hitbox2XHi		= !P2Hitbox2+$01		; |
		!P2Hitbox2YLo		= !P2Hitbox2+$02		; | hitbox 2
		!P2Hitbox2YHi		= !P2Hitbox2+$03		; |
		!P2Hitbox2W		= !P2Hitbox2+$04		; |
		!P2Hitbox2H		= !P2Hitbox2+$05		;/
		!P2Hitbox2X		= !P2Hitbox2XLo			; reference options
		!P2Hitbox2Y		= !P2Hitbox2YLo			; reference options
		!P2Hitbox2XSpeed	= !P2Hitbox2+$06		; x knockback
		!P2Hitbox2YSpeed	= !P2Hitbox2+$07		; y knockback
		!P2Hitbox2DisTimer	= !P2Hitbox2+$08		; interaction disable timer on hit
		!P2Hitbox2Hitstun	= !P2Hitbox1+$09		; hitstun
		!P2Hitbox2SFX1		= !P2Hitbox2+$0A		; SFX (!SPC1) on hit (0 = no SFX)
		!P2Hitbox2SFX2		= !P2Hitbox2+$0B		; SFX (!SPC4) on hit (0 = no SFX)
		; not pre-loaded:
		!P2Hitbox2IndexMem1	= !P2Hitbox2+$0C		;\ hitbox 2 index mem (1 bit per sprite)
		!P2Hitbox2IndexMem2	= !P2Hitbox2+$0D		;/
		!P2Hitbox2Shield	= !P2Hitbox2+$0E		; marks shield contact

		!P2Hitbox2IndexMem	= !P2Hitbox2IndexMem1		; alt name


		!P2ActiveHitbox		= !P2Hitbox+$1E			; 0 = hitbox 1, !P2Hitbox2Offset = hitbox 2


		; offsets
		!P2HitboxXOffset	= (!P2Hitbox1X-(!P2Hitbox1))
		!P2HitboxYOffset	= (!P2Hitbox1Y-(!P2Hitbox1))
		!P2HitboxWOffset	= (!P2Hitbox1W-(!P2Hitbox1))
		!P2HitboxHOffset	= (!P2Hitbox1H-(!P2Hitbox1))
		!P2HitboxXSpeedOffset	= (!P2Hitbox1XSpeed-(!P2Hitbox1))
		!P2HitboxYSpeedOffset	= (!P2Hitbox1YSpeed-(!P2Hitbox1))
		!P2HitboxDisOffset	= (!P2Hitbox1DisTimer-(!P2Hitbox1))
		!P2HitboxHitstunOffset	= (!P2Hitbox1Hitstun-(!P2Hitbox1))
		!P2HitboxSFX1Offset	= (!P2Hitbox1SFX1-(!P2Hitbox1))
		!P2HitboxSFX2Offset	= (!P2Hitbox1SFX2-(!P2Hitbox1))
		!P2HitboxIndex1Offset	= (!P2Hitbox1IndexMem1-(!P2Hitbox1))
		!P2HitboxIndex2Offset	= (!P2Hitbox1IndexMem2-(!P2Hitbox1))

		!P2Hitbox2Offset	= (!P2Hitbox2-(!P2Hitbox1))




	; --SPECIFIC/GENERIC NAMES--
		!P2Carry		= !P2Custom+$00
		!P2FusionIndex		= !P2Custom+$03			; index to owned fusion sprite
		!P2PickUp		= !P2Custom+$05			; timer for picking up an item
		!P2SpecialUsed		= !P2Custom+$07			; cleared when touching ground or bouncing on enemy
		!P2Dashing		= !P2Custom+$08			; used by most characters as a timer or flag for dash status
		!P2KickTimer		= !P2Custom+$09			; timer (decrements) after kicking objects like shells
		!P2TurnTimer		= !P2Custom+$0A			; timer (decrements) for turning around


		!P2YDelta		= !P2Base+$7C
		!P2ShowHP		= !P2Base+$7D
		!P2TouchingItem		= !P2Base+$7E			; penultimate byte = set if touching a carryable item
		!P2TempHP		= !P2Base+$7F			; last byte = temp HP

	; --MARIO DEFINES--
		;!P2Carry		= !P2Custom+$00
		!P2FastSwim		= !P2Custom+$01
		!P2FireTimer		= !P2Custom+$02
		!P2SpinJump		= !P2Custom+$03			; mario can't own a fusion sprite (has to search table anyway)
		!P2Overdrive		= !P2Custom+$04
		;!P2PickUp		= !P2Custom+$05			; 05
		!P2FireFlash		= !P2Custom+$06			; internally controlled frame counter
		!P2GalaxySpinUsed	= !P2SpecialUsed		; 07
		;!P2Dashing		= !P2Custom+$08			; 08
		;!P2KickTimer		= !P2Custom+$09			; 09
		;!P2TurnTimer		= !P2Custom+$0A			; 0A
		!P2Sliding		= !P2Custom+$0B			; flag for sliding on slopes
		!P2ShrinkTimer		= !P2Custom+$0C			; timer for shrink animation
		!P2FireCharge		= !P2Custom+$0D			; 0 = can't shoot fire, 1 = can shoot fire

		!P2RolloutTimer		= !P2Custom+$0E			; counts down from 3 when landing, allows grounded rollout
		!P2RolloutSpeed		= !P2Custom+$0F			; how much speed mario gets from a rollout, set while falling
		!P2RolloutBuffer	= !P2Custom+$10			; buffers rollout for 3 frames, then locks you out for 3 frames, set to -1 during rollout animation
		!P2RolloutStomp		= !P2Custom+$11			; set for 4 frames when stomping an enemy, allows aerial rollout
		!P2WallKickDir		= !P2Custom+$12			; which wall direction was used for wall kick
		!P2WallKickLockInput	= !P2Custom+$13			; timer, locks d-pad in wall kick direction
		!P2FlameDash		= !P2Custom+$14			; timer
		!P2FlameDashDown	= !P2Custom+$15			; flag
		!P2FlameDashPlus	= !P2Custom+$16			; flag, increases flame dash speed
		!P2FlameStar		= !P2Custom+$17			; timer
		!P2FlameStarCharge	= !P2Custom+$18			; timer, counts up
		!P2FlameStarUsed	= !P2Custom+$19			; flag, only cleared at level load
		!P2MarioFinale		= !P2Custom+$1A			; timer

		!MarioFlashPal		= $54

	; --LUIGI DEFINES--
		;!P2Carry		= !P2Custom+$00
		;!P2FastSwim		= !P2Custom+$01
		;!P2FireTimer		= !P2Custom+$02
		!P2FireIndex		= !P2FusionIndex		; 03
	; FREE	offset $04
		;!P2PickUp		= !P2Custom+$05			; 05
		!P2SpinAttack		= !P2Custom+$06
		!P2SpinUsed		= !P2SpecialUsed		; 07
		;!P2Dashing		= !P2Custom+$08			; 08
		;!P2KickTimer		= !P2Custom+$09			; 09
		;!P2TurnTimer		= !P2Custom+$0A			; 0A
		;!P2Sliding		= !P2Custom+$0B			; flag for sliding on slopes
		;!P2ShrinkTimer		= !P2Custom+$0C			; timer for shrink animation
		!P2WaterRun		= !P2Custom+$0D			; flag
		!P2WallRun		= !P2Custom+$0E			; flag
		!P2Statue		= !P2Custom+$0F			; timer
		!P2Cyclone		= !P2Custom+$10			; number of mash presses during spin
		!P2JumpCharge		= !P2Custom+$11			; counts up
		!P2LightningJump	= !P2Custom+$12			; timer
		!P2LightningCounter	= !P2Custom+$13			; frame counter for lightning jump
		!P2YoshiFlutter		= !P2Custom+$14			; timer


	; --KADAAL DEFINES--
		;!P2Carry		= !P2Custom+$00
		!P2Headbutt		= !P2Custom+$01			; timer (decrements) for kadaal's headbutt
		!P2DashTimerR		= !P2Custom+$02			;\ kadaal's dash timers
		!P2DashTimerL		= !P2Custom+$03			;/(doesn't own a fusion sprite, so free for this)
		!P2WalkTimer		= !P2Custom+$04			; kadaal walk startup
		!P2CanTurn		= !P2Custom+$05			; marks whether kadaal is allowed to turn around with left/right
		!P2Senku		= !P2Custom+$06			; timer (decrements) for senku
		!P2SenkuUsed		= !P2SpecialUsed		; 07
		;!P2Dashing		= !P2Custom+$08			; 08
		!P2SenkuDir		= !P2Custom+$09			; which direction kadaal's senku will go (0 = right, 1 = left)
		!P2AllRangeSenku	= !P2Custom+$0A			; all range direction for senku, requires upgrade
		!P2JumpLag		= !P2Custom+$0B			; timer (decrements) for kadaal's land lag
		!P2ShellSpin		= !P2Custom+$0C			; timer (decrements) for shell spin attack
		!P2ShellSlide		= !P2Custom+$0D			; kadaal's shell slide
		!P2ShellSpeed		= !P2Custom+$0E			; flag that kadaal is going fast enough to maintain shell slide speed in air
		!P2BackDash		= !P2Custom+$0F			; timer (decrements) for kadaal's back dash or perfect pivot
		!P2Punch		= !P2Custom+$10			; timer (decrements) for kadaal's punch
		!P2DashSmoke		= !P2Custom+$11
		!P2Throw		= !P2Custom+$12			; timer for item throw
		!P2DropKick		= !P2Custom+$13


	; --LEEWAY DEFINES--
		;!P2Carry		= !P2Custom+$00
		!P2SwordTimer		= !P2Custom+$01			; timer (decrements) for leeway's current sword attack
		!P2IdleTimer		= !P2Custom+$02			; counts up while idle
		!P2WallJumpInput	= !P2Custom+$03			; while timer is set, these bits are ORA'd to leeway's $6DA3
		!P2WallJumpTimer	= !P2Custom+$04			; timer for wall jump input
		!P2WallCoyote		= !P2Custom+$05			; if nonzero, wall jump can be used in air
		!P2WallJumpDir		= !P2Custom+$06			; collision bit of wall
		!P2AirDashUsed		= !P2SpecialUsed		; 07
		;!P2Dashing		= !P2Custom+$08			; 08
		;!P2KickTimer		= !P2Custom+$09			; 09
		!P2WallClimb		= !P2Custom+$0A			; leeway's climb reg
		;!P2Sliding		= !P2Custom+$0B			; 0B
		!P2JumpHold		= !P2Custom+$0C			; set while leeway holds B, used for jump snap
		!P2AirDash		= !P2Custom+$0D			; flag set when dash is started in midair, locks Yspeed to 0
		!P2Stamina		= !P2Custom+$0E			; resource for leeway's climb and wall jump
		!LeewayMaxStamina	= #$78
		!P2DashJump		= !P2Custom+$0F			; allows dash speed without dash animation in midair
		!P2SwordAttack		= !P2Custom+$10			; which sword attack leeway is performing
		;!P2DashSmoke		= !P2Custom+$11
		;!P2Throw		= !P2Custom+$12			; timer for item throw

		!P2BraveDash		= !P2Custom+$13			; marks leeway as invincible during dash
		!P2BraveDashCooldown	= !P2Custom+$14			; cooldown for brave dash

		;			= !P2Custom+$15
		;			= !P2Custom+$16


		!P2DroppedSword		= !P2Custom+$17			; set so leeway only drops his sword once
		!P2WallAnim		= !P2Custom+$18			; used for wall climb animation with ledge


	; --ALTER DEFINES--
	; --PEACH DEFINES--




	; --PLAYER ANIMATIONS--

macro def_anim(name, count)
	!<name>		:= !Temp		; define anim start
	!<name>_frames	:= <count>		; define number of frames
	!<name>_over	:= !Temp+<count>	; define over value
	!Temp		:= !Temp+<count>	; increment counter
endmacro

	!Temp = 0
	%def_anim(Mar_Idle, 1)			;\
	%def_anim(Mar_Walk, 3)			; | these use ice animation speed
	%def_anim(Mar_Run, 3)			;/
	%def_anim(Mar_LookUp, 1)
	%def_anim(Mar_Crouch, 1)
	%def_anim(Mar_Jump, 2)
	%def_anim(Mar_Slide, 1)
	%def_anim(Mar_FaceBack, 1)
	%def_anim(Mar_FaceFront, 1)
	%def_anim(Mar_Kick, 1)
	%def_anim(Mar_LongJump, 1)
	%def_anim(Mar_Turn, 1)
	%def_anim(Mar_Victory, 1)
	%def_anim(Mar_SwimSlow, 4)
	%def_anim(Mar_SwimFast, 3)
	%def_anim(Mar_Climb, 2)
	%def_anim(Mar_Hammer, 3)
	%def_anim(Mar_Cutscene, 7)
	%def_anim(Mar_Balloon, 1)
	%def_anim(Mar_Spin, 4)
	%def_anim(Mar_Fire, 1)
	%def_anim(Mar_Hang, 1)
	%def_anim(Mar_RolloutStart, 1)
	%def_anim(Mar_Rollout, 4)
	%def_anim(Mar_WallKick, 1)
	%def_anim(Mar_FlameStar, 1)
	%def_anim(Mar_Hurt, 2)
	%def_anim(Mar_Shrink, 2)
	%def_anim(Mar_Dead, 1)

	!Temp = 0
	%def_anim(Lui_Idle, 1)			;\
	%def_anim(Lui_Walk, 3)			; | these use ice animation speed
	%def_anim(Lui_Run, 3)			;/
	%def_anim(Lui_LookUp, 1)
	%def_anim(Lui_Crouch, 1)
	%def_anim(Lui_Jump, 2)
	%def_anim(Lui_Slide, 1)
	%def_anim(Lui_FaceBack, 1)
	%def_anim(Lui_FaceFront, 1)
	%def_anim(Lui_Kick, 1)
	%def_anim(Lui_LongJump, 1)
	%def_anim(Lui_Turn, 1)
	%def_anim(Lui_Victory, 1)
	%def_anim(Lui_SwimSlow, 4)
	%def_anim(Lui_SwimFast, 3)
	%def_anim(Lui_Climb, 2)
	%def_anim(Lui_Hammer, 3)
	%def_anim(Lui_Cutscene, 7)
	%def_anim(Lui_Balloon, 1)
	%def_anim(Lui_Spin, 4)
	%def_anim(Lui_SpinEnd, 4)
	%def_anim(Lui_Flutter, 3)
	%def_anim(Lui_WallRun, 6)
	%def_anim(Lui_Statue, 1)
	%def_anim(Lui_LightningJump, 1)
	%def_anim(Lui_Hurt, 2)
	%def_anim(Lui_Shrink, 2)
	%def_anim(Lui_Dead, 1)



	!Temp = 0
	%def_anim(Kad_Idle, 4)			;\
	%def_anim(Kad_Walk, 4)			; | these use ice animation speed
	%def_anim(Kad_Dash, 6)			;/
	%def_anim(Kad_Spin, 4)
	%def_anim(Kad_Squat, 1)
	%def_anim(Kad_Fall, 3)			; fall has to be before shell
	%def_anim(Kad_Shell, 4)
	%def_anim(Kad_Turn, 1)
	%def_anim(Kad_Senku, 1)
	%def_anim(Kad_Punch, 4)
	%def_anim(Kad_Hurt, 1)
	%def_anim(Kad_Dead, 1)
	%def_anim(Kad_Climb, 2)
	%def_anim(Kad_Duck, 2)
	%def_anim(Kad_Swim, 4)
	%def_anim(Kad_DropKick, 5)
	%def_anim(Kad_DropKickBounce, 2)
	%def_anim(Kad_Headbutt, 4)
	%def_anim(Kad_Carry, 3)
	%def_anim(Kad_Throw, 1)
	%def_anim(Kad_Victory, 1)




	!Temp = 0
	%def_anim(Lee_Idle1, 4)
	!Lee_Sleep = !Lee_Idle1+3
	%def_anim(Lee_IdleTransition, 2)
	%def_anim(Lee_Idle2, 3)
	%def_anim(Lee_Walk, 6)
	%def_anim(Lee_Kick, 1)
	%def_anim(Lee_CrouchTransition, 2)
	%def_anim(Lee_Crouch, 4)
	%def_anim(Lee_Surf0, 1)
	%def_anim(Lee_Surf1, 2)
	%def_anim(Lee_Surf2, 2)
	%def_anim(Lee_GroundAttack1, 4)
	%def_anim(Lee_GroundAttack2, 3)
	%def_anim(Lee_DashTransition, 2)
	%def_anim(Lee_Dash, 2)
	%def_anim(Lee_DashAttack, 3)
	%def_anim(Lee_Jump, 1)
	%def_anim(Lee_Fall, 3)
	%def_anim(Lee_AirAttack, 8)
	%def_anim(Lee_DoubleJump, 4)
	%def_anim(Lee_SpinAttack, 4)
	%def_anim(Lee_ClimbBG, 1)
	%def_anim(Lee_WallClimb, 4)
	%def_anim(Lee_WallClimbTop, 3)
	%def_anim(Lee_WallAttack, 5)
	%def_anim(Lee_CeilingHang, 1)
	%def_anim(Lee_CeilingClimb, 6)
	%def_anim(Lee_CeilingAttack, 4)
	%def_anim(Lee_Hurt, 1)
	%def_anim(Lee_Dead, 1)
	%def_anim(Lee_Victory, 2)


>>>>>>> Stashed changes



		!P1Dead			= $7FFF

		!MarioFireCharge	= $58
		!MarioClimb		= $62



		!SRAM_block		= $41B000
		!SaveFileSize		= $300
		!SaveSharedSize		= $134
		!SaveINIT		= !SRAM_block+(!SaveFileSize*3)+!SaveSharedSize-4
		!ChecksumComplement	= $1337

		!SRAM_buffer		= $41BC00		; has to be in same bank as !SRAM_block
		!Difficulty		= !SRAM_buffer+$00
					; -hicrtDD
					; DD - difficulty setting (00 = EASY, 01 = NORMAL, 10 = INSANE)
					; t = time
					; r = rank
					; c = critical
					; i = ironman
					; h = hardcore (not implemented)

		!CoinHoard		= !SRAM_buffer+$01	; 3 bytes, goes up to 999999 ($F423F)
		!YoshiCoinCount		= !SRAM_buffer+$04
		!Playtime		= !SRAM_buffer+$06	; 5 bytes (frames, seconds, minutes, hours)
		!PlayTimeFrames		= !Playtime+0		; 1 byte
		!PlayTimeSeconds	= !Playtime+1		; 1 byte
		!PlayTimeMinutes	= !Playtime+2		; 1 byte
		!PlayTimeHours		= !Playtime+3		; 2 bytes
		!Characters		= !SRAM_buffer+$0B
		!P1DeathCounter		= !SRAM_buffer+$0C	; 2 bytes
		!P2DeathCounter		= !SRAM_buffer+$0E	; 2 bytes

		!Database		= !SRAM_buffer+$10	; 64 bytes

		!CharacterData		= !SRAM_buffer+$50	; 60 bytes
		!MarioStatus		= !SRAM_buffer+$50
		!MarioUpgrades		= !SRAM_buffer+$51
					; 01 - fire charge+
					; 02 - wall kick
					; 04 - flame dash (down)
					; 08 - tactical fire
					; 10 - dash boots
					; 20 - flame dash
					; 40 - flame star
					; 80 - dive/rollout
		!MarioPlaytime		= !SRAM_buffer+$52	; 5 bytes
		!MarioLevelsBeaten	= !SRAM_buffer+$57	; 1 byte
		!MarioDeathCounter	= !SRAM_buffer+$58	; 2 bytes

		!LuigiStatus		= !SRAM_buffer+$5A
		!LuigiUpgrades		= !SRAM_buffer+$5B
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!LuigiPlaytime		= !SRAM_buffer+$5C	; 5 bytes
		!LuigiLevelsBeaten	= !SRAM_buffer+$61	; 1 byte
		!LuigiDeathCounter	= !SRAM_buffer+$62	; 2 bytes

		!KadaalStatus		= !SRAM_buffer+$64
		!KadaalUpgrades		= !SRAM_buffer+$65
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - Shun Koopa Satsu
		!KadaalPlaytime		= !SRAM_buffer+$66	; 5 bytes
		!KadaalLevelsBeaten	= !SRAM_buffer+$6B	; 1 byte
		!KadaalDeathCounter	= !SRAM_buffer+$6C	; 2 bytes

		!LeewayStatus		= !SRAM_buffer+$6E
		!LeewayUpgrades		= !SRAM_buffer+$6F
					; 01 - 
					; 02 - brave dash
					; 04 - air dash
					; 08 - dino grip
					; 10 - dino rush
					; 20 - 
					; 40 - rexcalibur
					; 80 - double jump
		!LeewayPlaytime		= !SRAM_buffer+$70	; 5 bytes
		!LeewayLevelsBeaten	= !SRAM_buffer+$75	; 1 byte
		!LeewayDeathCounter	= !SRAM_buffer+$76	; 2 bytes

		!AlterStatus		= !SRAM_buffer+$78
		!AlterUpgrades		= !SRAM_buffer+$79
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!AlterPlaytime		= !SRAM_buffer+$7A	; 5 bytes
		!AlterLevelsBeaten	= !SRAM_buffer+$7F	; 1 byte
		!AlterDeathCounter	= !SRAM_buffer+$80	; 2 bytes

		!PeachStatus		= !SRAM_buffer+$82
		!PeachUpgrades		= !SRAM_buffer+$83
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!PeachPlaytime		= !SRAM_buffer+$84	; 5 bytes
		!PeachLevelsBeaten	= !SRAM_buffer+$89	; 1 byte
		!PeachDeathCounter	= !SRAM_buffer+$8A	; 2 bytes


		!StoryFlags		= !SRAM_buffer+$8C
		; +00:	realm unlock state, 1 bit for each realm (if this is zero, load intro instead of realm select)
		; +01:	reserved for Realm 1
		; +02:	first 2 bits used by Mountain King






		!VRAMbank		= $40
		!VRAMbase		= !VRAMbank*$10000	; use !VRAMbase+!VRAMtable for long addressing
		!VRAMtable		= $4500
		!VRAMsize		= !VRAMtable+$FC	; remaining upload size
		!VRAMslot		= !VRAMtable+$FE	; index to start upload from
		!CGRAMtable		= $4600
		!TileUpdateTable	= $4700			; first 2 bytes in this table are the header (number of bytes)
								; after that, each 8x8 tile has 4 bytes: VRAM address + tile data
								; maximum of 252 bytes (63 tiles) in one frame
		!CCDMAtable		= $4800			; first 128 bytes are 16 slots for uploads greater than 256 bytes
								; second 128 bytes are 16 slots for uploads of 256 bytes or smaller


<<<<<<< Updated upstream
=======
		!SquareTable		= $44C0			; 4 bytes per entry (indexed by dynamic tile number * 4)
								; each entry simply holds a 24-bit source address to be uploaded to that square


	macro RawDyn(tiles, source, dest)
		dw <tiles>*$20
		dl <source>
		dw <dest>
	endmacro

	macro FileDyn(tiles, sourcetile, dest)
		dw <tiles>*$20
		dl <sourcetile>*$20
		dw <dest>
	endmacro


	; upload this tile
	macro SquareDyn(tilenum)
		dw <tilenum>*$20
	endmacro

	; update source file address
	macro SquareFile(file)
		dw $8000|<file>
	endmacro

	; skip forward that number of tiles (used to update later claimed tiles without updating earlier ones)
	macro SquareSkipTiles(tiles)
		dw $C000|<tiles>
	endmacro

	; update source file address to a super-dynamic one
	macro SquareSuperDynamic(ID)
		dw $E000|<ID>
	endmacro





	!IntroLevel_Airship		= $1F7
	!IntroLevel_Airship		= $1F1
	!IntroLevel_UnexploredHill	= $0C6



		!LockROM		= 0			; 0 = lock ROM and finalize header
								; 1 = do not lock ROM
		!Version		= 0			; 1.!Version is written to header




	macro LockROM(read, condition)
	if !LockROM != 0
		PHP
		SEP #$20
		LDA <read>
		CMP <condition> : BEQ ?Ok
	?LockROM:
		db $00
	?Ok:
		PLP
	endif
	endmacro



		!Debug			= 1			; 0 = do not insert debug code
								; 1 = insert debug code

	macro DebugCode()
		if !Debug == 1
	endmacro


	macro EndDebug()
		endif
	endmacro


>>>>>>> Stashed changes
		!DebugData		= $404900		; values from V timer, used to track performance over time
								; each entry is 16 bytes and holds:
								; - times called (2 bytes)
								; - average cost (1 byte)
								; - max cost (1 byte)
								; - min cost (1 byte)
								; - previous entries, used to calculate averages (8 bytes)
								; - 3 bytes of padding to make data easier to read in debugger

		; misc
		!DebugZips		= 1			; 0 = normal, 1 = while holding select zips use map16 tile 0x0000

		; do not use several trackers at the same time!
		!TrackSpriteLoad	= 0			; 0 = do not track sprite load, 1 = track sprite load
		!TrackOAM		= 0			; 0 = do not track OAM, 1 = track OAM
		!TrackCPU		= 1			; 0 = do not track CPU performance, 1 = track CPU performance and save in .srm file
		!ResetTracker		= 1			; 0 = keep tracker on bootup, 1 = reset tracker on bootup

		; toggles for !TrackCPU
		!TrackFull		= 0
		!TrackVR3		= 1
		!TrackPCE		= 2
		!TrackMSG		= 3
		!TrackPlaneSplit	= 4
		!TrackFe26		= 5
		!TrackFusionCore	= 6


; tracker format:
; 00 - number of times called (16-bit)
; 02 - average scanline cost
; 03 - highest scanline cost
; 04 - lowest scanline cost
; 05 - running tally 1
; 06 - running tally 2
; 07 - running tally 3
; 08 - running tally 4
; 09 - running tally 5
; 0A - running tally 6
; 0B - running tally 7
; 0C - running tally 8
; 0D - 24-bit work area
;
macro ResetTracker()
	if !ResetTracker == 1
		PHP
		REP #$30
		LDA #$0000
		LDX #$00FE
	?Loop:	STA !DebugData,x
		DEX #2 : BPL ?Loop
		PLP
	endif
endmacro

macro TrackSetup(index)
	if !TrackCPU == 1
		PHP
		SEP #$20
		LDA $2137
		LDA $213D : XBA
		LDA $213D
		AND #$01
		XBA
		REP #$20
		STA !DebugData+$0E+(<index>*16)
		PLP
	endif
endmacro

macro TrackCPU(index)
	if !TrackCPU == 1
		PHB
		PHP
		SEP #$30
		LDA.b #!DebugData>>16
		PHA : PLB
		LDX.b #<index>*16
		LDA.w !DebugData+$00,x
		AND #$07
		CLC : ADC.b #<index>*16
		TAY
		LDA.l $2137
		LDA.l $213D : XBA
		LDA.l $213D
		AND #$01
		XBA
		REP #$20
		INC.w !DebugData+$00,x				; increment counter in 16-bit mode
		SEC : SBC.w !DebugData+$0E+(<index>*16)		; comparison
		BPL $04 : CLC : ADC.w #261			; account for V wraparound
		CMP #$0100					;\ if still negative, default to $FF
		BCC $03 : LDA #$00FF				;/
		SEP #$20
		STA.w !DebugData+$05,y				; store most recent and free up Y
		CMP.w !DebugData+$03,x : BCC ?NotMax
?Max:		STA.w !DebugData+$03,x
?NotMax:	LDY.w !DebugData+$04,x : BEQ ?Min		; minimum of 00 should always be overwritten
		CMP.w !DebugData+$04,x : BCS ?NotMin
?Min:		STA.w !DebugData+$04,x
?NotMin:	LDY #$00
		LDA.w !DebugData+$05,x
		CLC : ADC.w !DebugData+$06,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$07,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$08,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$09,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0A,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0B,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0C,x
		BCC $01 : INY
		XBA
		TYA
		XBA
		REP #$20
		LSR #3
		SEP #$20
		STA !DebugData+$02,x

		PLP
		PLB
	endif
endmacro


macro SA1TrackSetup(index)
	if !TrackCPU == 1
		LDA.b #?SNES : STA $0183
		LDA.b #?SNES>>8 : STA $0184
		LDA.b #?SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	?Wait:	LDA $018A : BEQ ?Wait			; |
		STZ $018A				; |
		JMP ?End
	?SNES:
		%TrackSetup(<index>)
		RTL
	?End:
	endif
endmacro

macro SA1TrackCPU(index)
	if !TrackCPU == 1
		LDA.b #?SNES : STA $0183
		LDA.b #?SNES>>8 : STA $0184
		LDA.b #?SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	?Wait:	LDA $018A : BEQ ?Wait			; |
		STZ $018A				; |
		JMP ?End
	?SNES:
		%TrackCPU(<index>)
		RTL
	?End:
	endif
endmacro






		!HDMAptr		= $4046FC		; 24-bit, stored at the end of CGRAM table


		!OAM			= $6200			;\ Main mirror
		!OAMhi			= $6420			;/
		!OAMindex		= $7473			; lo byte
		!OAMindexhi		= $7474			; hi bit
		; $7474 has been remapped to $7475 to allow oam index to be used in 16-bit mode

		!OAM_p0			= $419000
		!OAM_p1			= $419200
		!OAM_p2			= $419400
		!OAM_p3			= $419600
		!OAMhi_p0		= $419800
		!OAMhi_p1		= $419880
		!OAMhi_p2		= $419900
		!OAMhi_p3		= $419980

		!OAMindex_p0		= $418FF8
		!OAMindex_p1		= $418FFA
		!OAMindex_p2		= $418FFC
		!OAMindex_p3		= $418FFE

		!PrioData		= $7FB0			; 16 bytes in mirror (generic bank)
		; holds a static block:
		; $0000,$0002,$0004,$0006
		; $0000,$0200,$0400,$0600
		; the first 4 entries are used to index the !OAMindex_px regs
		; the last 4 entries are added to the OAM index
		; this way, they can all be accessed with the same code

		!OAMindex_index		= !PrioData+0
		!OAMindex_offset	= !PrioData+8

		!ActiveOAM		= $7FC0			; 2 bytes, index to currently used !PrioData


		!Particle_Base		= $9A00			; bank $41

		; each particle is a 17-byte struct laid out as follows:
		!Particle_Type		= !Particle_Base+$00	; type + air resistance flag
		!Particle_Tile		= !Particle_Base+$01	; oam +2
		!Particle_Prop		= !Particle_Base+$02	; oam +3
		!Particle_Layer		= !Particle_Base+$03	; determines scrolling
		!Particle_Timer		= !Particle_Base+$04	; particle despawns when this hits 0 (if this is set to 0 at spawn, particle lasts indefinitely)
		!Particle_XSub		= !Particle_Base+$05	;\
		!Particle_XLo		= !Particle_Base+$06	; | 24-bit X coordinate
		!Particle_XHi		= !Particle_Base+$07	;/
		!Particle_XSpeed	= !Particle_Base+$08	; 16-bit X speed
		!Particle_XAcc		= !Particle_Base+$0A	; 8-bit X acceleration
		!Particle_YSub		= !Particle_Base+$0B	;\
		!Particle_YLo		= !Particle_Base+$0C	; | 24-bit Y coordinate
		!Particle_YHi		= !Particle_Base+$0D	;/
		!Particle_YSpeed	= !Particle_Base+$0E	; 16-bit Y coordinate
		!Particle_YAcc		= !Particle_Base+$10	; 8-bit Y acceleration

		; these are used as scratch during the drawing routine
		!Particle_XTemp		= $00
		!Particle_YTemp		= $04
		!Particle_TileTemp	= $08


<<<<<<< Updated upstream
=======
	macro def_particle(name)
		!prt_<name>	:= !Temp
		!prt_<name>_BG1	:= !prt_<name>
		!prt_<name>_BG2	:= !prt_<name>+1
		!prt_<name>_BG3	:= !prt_<name>+2
		!prt_<name>_Cam	:= !prt_<name>+3
		!Temp		:= !Temp+4
	endmacro

	macro def_particle_simple(name)
		!prt_<name>	:= !Temp
		!Temp		:= !Temp+1
	endmacro



	!Temp = 1			; 0 doesn't count!

	; super customs
	%def_particle(basic)
	%def_particle(ratio)
	%def_particle(anim_add)
	%def_particle(anim_sub)

	; minor customs
	%def_particle_simple(spritepart)
	%def_particle_simple(flash)

	; hardcoded: vanilla replacements
	%def_particle_simple(smoke8x8)
	%def_particle_simple(smoke16x16)
	%def_particle_simple(contact)
	%def_particle_simple(contactbig)
	%def_particle_simple(coinglitter)
	%def_particle_simple(sparkle)
	%def_particle_simple(sparklesmall)
	%def_particle_simple(text100)
	%def_particle_simple(brickpiece)

;	%def_particle_simple(watersplash)
;	%def_particle_simple(lavasplash)

	%def_particle_simple(lavaparticle)
	%def_particle_simple(splash)

	%def_particle_simple(bubble)
	%def_particle_simple(snorez)

	; hardcoded: new particles
	%def_particle_simple(leaf)
	%def_particle_simple(tinycoin)




	; BG_object regs
		!BG_object_Base		= $A0B0			; bank $41
		!BG_object_Count	= 128
		!BG_object_Size		= 10

		!BG_object_Index	= $57			; 16-bit, holds the index to the next free BG object

		!BG_object_Type		= !BG_object_Base+$00	; which object this is
		!BG_object_Timer	= !BG_object_Base+$01	; timer
		!BG_object_X		= !BG_object_Base+$02	;\
		!BG_object_XLo		= !BG_object_X		; | 16-bit X pos
		!BG_object_XHi		= !BG_object_X+1	;/
		!BG_object_Y		= !BG_object_Base+$04	;\
		!BG_object_YLo		= !BG_object_Y		; | 16-bit Y pos
		!BG_object_YHi		= !BG_object_Y+1	;/
		!BG_object_W		= !BG_object_Base+$06	; how many 8x8 tiles wide this object is
		!BG_object_H		= !BG_object_Base+$07	; how many 8x8 tiles tall this object is
		!BG_object_Tile		= !BG_object_Base+$08	; position on page 3
		!BG_object_Misc		= !BG_object_Base+$09	; reg that can be used for various purposes

	; BG_object map16
		!BG_object_Map16	= $41A5B0		; 2 KiB right after BG object data
		!Map16Page3		= !BG_object_Map16	;\ alt names
		!Map16_Page3		= !BG_object_Map16	;/


	; cable regs
		!CableRenderBuffer	= !V_buffer

		!CableRAM		= !GFX_buffer+$1000	; starts right after buffer

		!CableCacheX		= !CableRAM+$000	; carried between renders, cleared at the start of each frame
		!CableTilemapLookup	= !CableRAM+$002	; 16 bytes marking whether each tilemap buffer is used (indexed by $51, can be reordered each frame)
		!CableTilemapBuffer	= !CableRAM+$012	; $C0 * 16 bytes = $C00 bytes (3 KiB) total

		!CableTileOverflow	= !CableRAM+$C12	; up to 128 bytes, used internally in renderer, can be shared
		!CablePrevHash		= !CableRAM+$C92	; 2 bytes, used internally in renderer, can be shared
		!CableConnectionHash	= !CableRAM+$C94	; 2 bytes, hash of last tile used for middle line
		!CableConnectionIndex	= !CableRAM+$C96	; 2 bytes, render index to the last tile used for middle line
		!CableRenderLineTemp	= !CableRAM+$C98	; 3 bytes, used internally in renderer, can be shared

		; these 5 are the cache used for tilemap updates, true mirrors below
		!CableUpdateMinus2	= !CableRAM+$C9B
		!CableUpdateMinus1	= !CableRAM+$C9C
		!CableUpdate0		= !CableRAM+$C9D
		!CableUpdatePlus1	= !CableRAM+$C9E
		!CableUpdatePlus2	= !CableRAM+$C9F

		; each cable needs its own set of these 5 bytes... so there are 64 structs of this type here
		!CableUpdateData	= !CableRAM+$CA0

		!CableTilemapIndex	= !CableRAM+$DE0	; 2 bytes, carried between renders, cleared at the start of each frame


		!CableTexture		= !CableRAM+$E00






		; shield box data
		!ShieldByteCount	= $06
		!ShieldData		= $418B00
		!ShieldXLo		= !ShieldData+0
		!ShieldXHi		= !ShieldData+1
		!ShieldYLo		= !ShieldData+2
		!ShieldYHi		= !ShieldData+3
		!ShieldW		= !ShieldData+4
		!ShieldH		= !ShieldData+5
		!ShieldX		= !ShieldXLo
		!ShieldY		= !ShieldYLo

		!ShieldExists		= !ShieldData+($10*!ShieldByteCount)

	; call from bank $41!
	macro ClearShield(num)
		STZ.w !ShieldW+(<num>*!PlatformByteCount)
	endmacro



		; platform box data
		!PlatformByteCount	= $0C
		!PlatformData		= $418F00		; 192 bytes (16 slots, 11 bytes per slot, index with sprite num * 0x0C)
		!PlatformStatus		= !PlatformData+0	; which collision points to interact with (00 = this platform does not exist)
		!PlatformXLeft		= !PlatformData+1	; 16-bit Xpos of left border
		!PlatformXRight		= !PlatformData+3	; 16-bit Xpos of right border
		!PlatformYUp		= !PlatformData+5	; 16-bit Ypos of top border
		!PlatformYDown		= !PlatformData+7	; 16-bit Ypos of down border
		!PlatformDeltaX		= !PlatformData+9	; 8-bit X delta
		!PlatformDeltaY		= !PlatformData+10	; 8-bit Y delta
		!PlatformSprite		= !PlatformData+11	; 8-bit sprite index

		!PlatformExists		= !PlatformData+($10*!PlatformByteCount)

	; call from bank $41!
	macro ClearPlatform(num)
		STZ.w !PlatformStatus+(<num>*!PlatformByteCount)
	endmacro





>>>>>>> Stashed changes

		!PlayerBackupData	= $404E00		; > 128 bytes

		!MultiPlayer		= $404E80
<<<<<<< Updated upstream
		!CurrentPlayer		= $404E81		; Used on OW for character select and during levels
=======
		!CurrentPlayer		= $404E81		; used on OW for character select and during levels
		!HitboxType		= $404E82		; 0 = normal hitbox, 1 = sight box
>>>>>>> Stashed changes

		; $404E82 free

		!CurrentMario		= $404E84		; > 0 = no Mario, 1 = P1 Mario, 2 = P2 Mario

		; THESE ARE PROBABLY UNUSED
		!VineDestroy		= $404E85
		!VineDestroyPage	= !VineDestroy+$00	; > Map16 page of vines
		!VineDestroyXLo		= !VineDestroy+$01
		!VineDestroyXHi		= !VineDestroy+$05
		!VineDestroyYLo		= !VineDestroy+$09
		!VineDestroyYHi		= !VineDestroy+$0D
		!VineDestroyDirection	= !VineDestroy+$11
		!VineDestroyTimer	= !VineDestroy+$15	; > Also borrowed by lightning bolt

		!NPC_ID			= $404E9E		; Used for NPC loading
		!NPC_Talk		= $404EA1		; Pointer to NPC talk table

		!MsgMode		= $404EA4		; 0 = normal message box
								; 1 = play animation during message box
								; 2 = message box has no pause-effect


		!MarioExtraWaterJump	= $404EA5

		; $404EA6-$404EB0 (11 bytes) free

		!ProcessingSprites	= $404EB1		; Set while sprites are being processed

		!VineDestroyBaseTime	= $404EB2		; Default timer option for vines (set by level code)

		!MegaLevelID		= $404EB3		; 0 = no mega level

		; $404EB4 (1 byte) free

		!PauseThif		= $404EB5		; when set, thifs will not process

		!LevelMainFlag		= $404EB6		; 0 while INIT is running, 1 while MAIN is running

		!3DWater		= $404EB7		; enable/disable 3D water from DKC2

		!RenderingCache		= $404EB8		; 64 bytes, used to backup rendering regs


		!PaletteHSL		= $404EF8		; mirror of $6703 in HSL format, 3 bytes per color
								; following 768 bytes is scratch RAM / cache for additional HSL colors
								; after that is assembly area for HSL mixing (also 768 bytes)
								; last 512 bytes is color buffer for upload
								; so $300 + $300 + $300 + $200 = $B00 bytes, or 2.75KB
		!PaletteBuffer		= !PaletteHSL+$900

<<<<<<< Updated upstream
=======
		!PaletteCacheHSL	= !PaletteHSL+$300
		!PaletteBufferHSL	= !PaletteHSL+$600
		!PaletteCacheRGB	= !PaletteHSL+$900
		!PaletteBuffer		= !PaletteHSL+$B00
		!ShaderInput		= !PaletteHSL+$D00


		!DizzyEffect		= $405DF8		; when enabled, table at !DecompBuffer+$1000 must be used to adjust sprite heights

		!3DWater_Color		= $405DF9		; 16-bit, should be set at level init
>>>>>>> Stashed changes


		!DizzyEffect		= $4059F8		; when enabled, table at $40A040 must be used to adjust sprite heights

		!3DWater_Color		= $4059F9		; 16-bit, should be set at level init
		!FileAddress		= $4059FB		; 24-bit, scratch pointer to file

<<<<<<< Updated upstream
	; next entry at $4059FE
=======
		; 1 byte free at $405DFB
		!ShakeBG3		= $405DFC		; same as !ShakeTimer but for BG3

		; 2 bytes free at $405DFD-$405DFE!

		!NPC_TalkSign		= $405DFF
		!NPC_Talk		= $405E00		; 256 word entries (512 B), 1 for each NPC ID, index with NPC ID * 2 to get input for !MsgTrigger
		!NPC_TalkCap		= $406000		; same format as previous table, cap for auto-incrementing function

	; next entry at $406200

>>>>>>> Stashed changes


		; these are values not addresses
		!VineDestroyHorzTile1	= $92
		!VineDestroyHorzTile2	= $93
		!VineDestroyHorzTile3	= $C2
		!VineDestroyHorzTile4	= $C3
		!VineDestroyHorzTile5	= $96
		!VineDestroyHorzTile6	= $97
		!VineDestroyHorzTile7	= $9A
		!VineDestroyHorzTile8	= $9B
		!VineDestroyHorzTile9	= $CA
		!VineDestroyHorzTile10	= $CB
		!VineDestroyHorzTile11	= $9E
		!VineDestroyHorzTile12	= $9F
		!VineDestroyVertTile1	= $A1
		!VineDestroyVertTile2	= $B1
		!VineDestroyVertTile3	= $A4
		!VineDestroyVertTile4	= $B4
		!VineDestroyVertTile5	= $E1
		!VineDestroyVertTile6	= $F1
		!VineDestroyVertTile7	= $A9
		!VineDestroyVertTile8	= $B9
		!VineDestroyVertTile9	= $AC
		!VineDestroyVertTile10	= $BC
		!VineDestroyVertTile11	= $E9
		!VineDestroyVertTile12	= $F9
		!VineDestroyCornerUL1	= $C4
		!VineDestroyCornerUR1	= $C1
		!VineDestroyCornerDL1	= $94
		!VineDestroyCornerDR1	= $91
		!VineDestroyCornerUL2	= $CC
		!VineDestroyCornerUR2	= $C9
		!VineDestroyCornerDL2	= $9C
		!VineDestroyCornerDR2	= $99


	; -- 3D/2D Joint Cluster --

		!3D_Base		= $41C000

		!3D_AngleXY		= !3D_Base+$0	;\
		!3D_AngleXZ		= !3D_Base+$1	; |
		!3D_AngleYZ		= !3D_Base+$2	; | used for core
		!3D_AngleYX		= !3D_AngleXY	; |
		!3D_AngleZX		= !3D_AngleXZ	; |
		!3D_AngleZY		= !3D_AngleYZ	;/

		!3D_AngleH		= !3D_Base+$0	;\ used for non-core objects
		!3D_AngleV		= !3D_Base+$1	;/

	; for all angles, 256 represents a full 360 degree rotation

		!3D_Distance		= !3D_Base+$3	; 16 bit, each unit represents 1/256th px
		!3D_DistanceSub		= !3D_Base+$3	;
		!3D_DistancePx		= !3D_Base+$4	;
		!3D_X			= !3D_Base+$5	; 16-bit X position
		!3D_Y			= !3D_Base+$7	; 16-bit Y position
		!3D_Z			= !3D_Base+$9	; 8-bit Z position (0x80 is default)
		!3D_Attachment		= !3D_Base+$B	; which object this one is attached to
		!3D_Slot		= !3D_Base+$D	; 8-bit, 0 if this slot is free, otherwise used
		!3D_Extra		= !3D_Base+$E	; empty

		; if an object is set to be attached to itself, then that is the core of that cluster.
		; writing to angles and Z position of the core will affect the entire cluster.
		; distance has no effect on the core.


		!3D_AssemblyCache	= !3D_Base+$200

		!3D_TilemapPointer	= !3D_Base+$400
		!3D_BankCache		= !3D_Base+$402

		!3D_TilemapCache	= $6DDF		; 278 bytes

		!3D_Cache		= $F0		; DP is used for faster access
		!3D_Cache1		= !3D_Cache+$0
		!3D_Cache2		= !3D_Cache+$2
		!3D_Cache3		= !3D_Cache+$4
		!3D_Cache4		= !3D_Cache+$6
		!3D_Cache5		= !3D_Cache+$8
		!3D_Cache6		= !3D_Cache+$A
		!3D_Cache7		= !3D_Cache+$C
		!3D_Cache8		= !3D_Cache+$E


		; the parent's coordinates and total rotation is used along with the child's relative rotation to calculate the child's coordinates
		; this means that moving the core will move the entire cluster, whereas attempting to move a joint will do nothing as it will be overwritten by the rotation application

		!2D_Base		= !3D_Base
		!2D_Angle		= !2D_Base+$0	; rotation in relation to parent joint
		!2D_Rotation		= !2D_Base+$1	; total rotation, used to determine which tile to draw
		!2D_Distance		= !2D_Base+$2	; 16-bit, each unit represents 1/256 px
		!2D_X			= !2D_Base+$4	; 16-bit X position
		!2D_Y			= !2D_Base+$6	; 16-bit Y position
		!2D_Attachment		= !2D_Base+$8	; 16-bit index
		!2D_Slot		= !2D_Base+$A	; 0 if slot is free, otherwise used
		!2D_Tilemap		= !2D_Base+$B	; tilemap index for this joint



	; -- Sprite stuff --

	; these addresses were freed from sprite data being moved to I-RAM:
	;	$74C8-$75E8:	289 B	last byte unused in vanilla, next byte is !SpriteIndex
	;	$75EA-$7691:	167 B	next byte is sprite memory setting (from header)
	;	$786C-$7877:	12 B	sprite off screen flag, vertical
	;	$787B-$7886:	12 B	sprite stomp immunity flag
	;	$790F-$791B:	13 B	tweaker 6, last byte is unused in vanilla
	;	$7FD6-$7FED:	24 B	unused sprite table and misc (water/cape etc) timer


		!ExtraBits		= $3590		; extra bits of sprite
		!ExtraProp1		= $35A0		;
		!ExtraProp2		= $35B0		;
		!NewSpriteNum		= $35C0		; custom sprite number
					; $35F0		; P2 interaction disable timer
		!CustomBit		= $08

<<<<<<< Updated upstream
=======
		!SpriteTile		= $6030		; offset to add to sprite tilemap numbers, normally updated each frame before MAIN
		!SpriteProp		= $6040		; lowest bit of sprite OAM prop, normally updated each frame before MAIN
>>>>>>> Stashed changes

		!SpriteDisP1		= $32E0
		!SpriteDisSprite	= $3300
		!SpriteDisP2		= $35F0


		!SpriteTweaker1		= $3440
		!SpriteTweaker2		= $3450
		!SpriteTweaker3		= $3460
		!SpriteTweaker4		= $3470
		!SpriteTweaker5		= $3480
		!SpriteTweaker6		= $34B0

		!SpriteAnimTimer	= $3310,x
		!SpriteAnimIndex	= $33D0,x
		!SpriteAnimIndexY	= $33D0,y
		!ClaimedGFX		= $32C0,x
		!ClaimedGFX_Y		= $32C0,y
		!AggroRexTile		= $35E0,x


		!SpriteWater		= $3430

		!ShellOwner		= $34F0


	; after moving physics+ to BWRAM, these tables are free:
	; $34E0
	; $3500
	; $3510
	; $3520
	; $3530
	; $3540
	; $3550
	; $3560
	; $3570
	; $3580

		!SpriteStasis		= $74D0	;$34E0
		!SpritePhaseTimer	= $74E0		; while set, sprite will not experience normal collision (extra collision still applies)
		!SpriteGravityMod	= $74F0	;$3500
		!SpriteGravityTimer	= $7500	;$3510
		!SpriteVectorY		= $7510	;$3520
		!SpriteVectorX		= $7520	;$3530
		!SpriteVectorAccY	= $7530	;$3540
		!SpriteVectorAccX	= $7540	;$3550
		!SpriteVectorTimerY	= $7550	;$3560
		!SpriteVectorTimerX	= $7560	;$3570
		!SpriteExtraCollision	= $7570	;$3580			; Applies only on the frame that it's set

		!SpriteTile		= $6030			; offset to add to sprite tilemap numbers
		!SpriteProp		= $6040			; lowest bit of sprite OAM prop



	; -- Fusion Core --

		!Ex_Amount		= $25			; highest index is $24
		!Ex_Index		= $785D

		!CoinOffset		= $00
		!MinorOffset		= $02
		!ExtendedOffset		= $0E
		!SmokeOffset		= $21
		!BounceOffset		= $27
		!QuakeOffset		= $2F
		!ShooterOffset		= $32
		!CustomOffset		= $35


<<<<<<< Updated upstream
		!Ex_Palset		= $6050			; which palset a FusionCore sprite is using (hidden 13th reg, i suppose)
=======
	; fusion sprite list
		!MarFireball_Num	= $01
		!MarFinale_Num		= $02
		!LuiFireball_Num	= $03
		; 01-07 reserved for player use
		!Malleable_Num		= $08
		!Hammer_Num		= $09
		!Bone_Num		= $0A
		!Baseball_Num		= $0B
		!SmallFireball_Num	= $0C
		!BigFireball_Num	= $0D
		!TinyFlame_Num		= $0E
		!VolcanoLotusFire_Num	= $0F
		!Glitter_Num		= $10
		!QuestionBlock_Num	= $11
		!Brick_Num		= $12
		!BlockHitbox_Num	= $13
		!CoinFromBlock_Num	= $14
		!Shooter_Num		= $15
		!TorpedoArm_Num		= $16
		!DizzyStar_Num		= $17
		!Explosion_Num		= $18
		!TurnToPrt_Num		= $19
>>>>>>> Stashed changes

		!Ex_Index		= $7699			; rolling index for fusion sprites
		!Particle_Index		= $769A			; rolling index for particles (16-bit)

	; player projectile list
		!PlayerProjectile	= $7660
		!PProjectile_Index	= !PlayerProjectile+0
		!PProjectile_List	= !PlayerProjectile+1


	; $1C3 bytes in this chunk
	; note that the order of the physics regs is important
		!Ex_Num			= $769C
		!Ex_Data1		= !Ex_Num+(!Ex_Amount*1)
		!Ex_Data2		= !Ex_Num+(!Ex_Amount*2)
		!Ex_Data3		= !Ex_Num+(!Ex_Amount*3)
		!Ex_YLo			= !Ex_Num+(!Ex_Amount*4)
		!Ex_XLo			= !Ex_Num+(!Ex_Amount*5)
		!Ex_YHi			= !Ex_Num+(!Ex_Amount*6)
		!Ex_XHi			= !Ex_Num+(!Ex_Amount*7)
		!Ex_YSpeed		= !Ex_Num+(!Ex_Amount*8)
		!Ex_XSpeed		= !Ex_Num+(!Ex_Amount*9)
		!Ex_YFraction		= !Ex_Num+(!Ex_Amount*10)
		!Ex_XFraction		= !Ex_Num+(!Ex_Amount*11)

		; ends at $7857
		; 4 bytes that are overwritten by the FusionCore data ($77BC-$77BF) are mapped to $7858-$785B
		; this means that there are no free bytes at the end of this block



	; -- MSG RAM --
		; DP define
<<<<<<< Updated upstream
		!MsgPal			= $61
=======
		!MsgPal			= $61			; first portrait color (default = 0xA1)
		!BorderPal		= $62			; ccc bits of border prop (default = 0x08)
		!TextPal		= $63			; CCC bits of text prop, set to 0x18 by default
>>>>>>> Stashed changes

		; LM pointer
		!MsgData		= $03BC0B		; Use this to figure out where Lunar Magic puts message data

		; bank $40 RAM
		!MsgRAM			= $4400			; 256 bytes, base address

		!MsgIndex		= !MsgRAM+$00		; 1 byte \ these two form a 16-bit index to the text data
		!MsgIndexHi		= !MsgRAM+$01		; 1 byte /
		!MsgOptions		= !MsgRAM+$02		; 1 byte
		!MsgArrow		= !MsgRAM+$03		; 1 byte
		!MsgOptionRow		= !MsgRAM+$04		; 1 byte, which row the dialogue options start on
		!MsgDestination		= !MsgRAM+$05		; 1 byte, determines what !MsgArrow writes to
		!MsgVertOffset		= !MsgRAM+$06		; 1 byte, number of pixels to move window down (doubled)
								;	  highest bit toggles portrait to top-right of screen
								;	  second highest bit disables border and window
		!MsgSequence		= !MsgRAM+$07		; 15 bytes, read backwards.
		!MsgScroll		= !MsgRAM+$16		; 1 byte, current scroll value
		!MsgCounter		= !MsgRAM+$17		; 1 byte
		!MsgDelay		= !MsgRAM+$18		; 1 byte
		!MsgTargScroll		= !MsgRAM+$19		; 1 byte, target scroll value
		!MsgWaitFlag		= !MsgRAM+$1A		; 1 byte, engine is paused while this is set, cleared by A/B/X/Y input
		!MsgInstantLine		= !MsgRAM+$1B		; 1 byte, when set the current line will be rendered instantly, cleared when a line is finished rendering
		!MsgFillerColor		= !MsgRAM+$1C		; 1 byte, used in place of transparency when rendering text
		!MsgPortrait		= !MsgRAM+$1D		; 1 byte, 6 bits used for portrait index, second highest bit flips portrait, highest bit marks that the portrait has been loaded
		!MsgSpeed		= !MsgRAM+$1E		; 1 byte
		!MsgEnd			= !MsgRAM+$1F		; 1 byte
		!MsgFont		= !MsgRAM+$20		; 1 byte
		!MsgVRAM1		= !MsgRAM+$21		; 2 bytes, portrait (lo plane)
		!MsgVRAM2		= !MsgRAM+$23		; 2 bytes, portrait (hi plane)
		!MsgVRAM3		= !MsgRAM+$25		; 2 bytes, border
		!MsgBackup41		= !MsgRAM+$27		; 1 byte
		!MsgBackup42		= !MsgRAM+$28		; 1 byte
		!MsgBackup43		= !MsgRAM+$29		; 1 byte
		!MsgBackup44		= !MsgRAM+$2A		; 1 byte
		!MsgBackupMainScreen	= !MsgRAM+$2B		; 1 byte
		!MsgBackupSubScreen	= !MsgRAM+$2C		; 1 byte
		!MsgBackup22		= !MsgRAM+$2D		; 1 byte
		!MsgBackup23		= !MsgRAM+$2E		; 1 byte
		!MsgBackup24		= !MsgRAM+$2F		; 1 byte
		!MsgBackup25		= !MsgRAM+$30		; 1 byte
		!MsgBackup13D5		= !MsgRAM+$31		; 1 byte, layer 3 scroll setting
		!MsgBackup3E		= !MsgRAM+$32		; 1 byte
		!MsgTalk		= !MsgRAM+$33		; 1 byte
		!MsgCinematic		= !MsgRAM+$34		; 1 byte, enables cinematic mode
		!MsgX			= !MsgRAM+$35		; 1 byte, X position to start drawing next character at
		!MsgRow			= !MsgRAM+$36		; 1 byte, current row of text
		!MsgCurrentArrow	= !MsgRAM+$37		; 1 byte, row of current arrow (used to replace it when it moves)
		!MsgWordLength		= !MsgRAM+$38		; 1 byte, accumulating word length
		!MsgCharCount		= !MsgRAM+$39		; 1 byte, accumulating characters
		!MsgWidth		= !MsgRAM+$3A		; 1 byte, how many 8x8 tiles are reserved on layer 3 for text
		!MsgInit		= !MsgRAM+$3B		; 1 byte, set to 80 when init code has been run
		!MsgCachedFont		= !MsgRAM+$3C		; 1 byte
		!MsgArrowMem		= !MsgRAM+$3D		; 1 byte, keeps track of which rows the dialogue arrow moves across
		!MsgTerminateRender	= !MsgRAM+$3E		; 1 byte, set by a command when a render should be terminated
		!MsgImportant		= !MsgRAM+$3F		; 1 byte: 0 = can fast forward with A/B/X/Y and skip with start, 1 = can fast forward with A/B/X/Y but not skip, 2 = can't fast forward or skip, $FF = buffering skip


	; -- 5bpp and GFX scaling --

		!GraphicsLoc	= $00				; 24-bit pointer to graphics file
		!GraphicsSize	= $03				; 8-bit number of 8x8 tiles


		!DecompBuffer	= $407000			; decompression buffer

		!BufferSize	= $0400				; Size of buffer. Must be divisible by 4.
		!BufferLo	= !DecompBuffer			; 24-bit 5bpp decompression buffer address.
		!BufferHi	= !BufferLo+(!BufferSize/2)	; Hi buffer.

		!GFX0		= $10				; Points to GFX+$00
		!GFX1		= $13				; Points to GFX+$01
		!GFX2		= $16				; Points to GFX+$10
		!GFX3		= $19				; Points to GFX+$11
		!GFX4		= $1C				; Points to GFX+$20

		!GFX_buffer	= $402000			; CC work RAM, 8kb
		!V_buffer	= $604000			; virtual VRAM mirror of !GFX_buffer

		!ImageCache	= $403000			; holds input GFX for rotation/scaling
		!V_cache	= $606000			; virtual VRAM mirror of image cache

		; !ImageCache is used as part of !GFX_buffer during triangle rendering
		; this allows images as large as 8kb (128x128px) to be rendered


		; the first 2kb holds the finished GFX
		; the following 2kb is used as work space for shearing
		; the last 4kb is the transformation image cache and holds input GFX
		; depending on mode, it holds up to:
		;	128 8x8 images
		;	32 16x16 images
		;	8 32x32 images
		;	2 64x64 images
		; note that input cache is expected to hold chunked linearly formatted GFX
		; format conversion might be necessary beforehand



	; -- SMW/LM RAM --			; This is mainly for easier SA-1 compatibility.

		!RAM_TrueFrameCounter	= $13
		!RAM_FrameCounter	= $14
		!RAM_ScreenMode		= $5B
<<<<<<< Updated upstream
		!Palette		= $5C
		!LevelWidth		= $5E	; in screens
		!GlobalProperties	= $64
		!MarioAnim		= $71
		!MarioAir		= $72
		!MarioDucking		= $73
		!MarioClimbing		= $74
		!MarioUnderWater	= $75
		!MarioDirection		= $76
		!MarioBlocked		= $77
		!MarioMaskBits		= $78
		!MarioXSpeed		= $7B
		!MarioYSpeed		= $7D
		!MarioScreenXPosLo	= $7E
		!MarioScreenXPosHi	= $7F
		!MarioScreenYPosLo	= $80
		!MarioScreenYPosHi	= $81
=======
		!Map16Width		= $5D		; how many screens fit in the current level mode (number of map16 columns, actual max width with no -1)
		!LevelWidth		= $5E		; in screens (effective width not max width: only used screens are counted)
		!GlobalProperties	= $64
>>>>>>> Stashed changes
		!WaterLevel		= $85
		!IceLevel		= $86

		!MarioXPos		= $94		;\
		!MarioXPosLo		= !MarioXPos	; |
		!MarioXPosHi		= !MarioXPos+1	; | still used sometimes for loading and such
		!MarioYPos		= $96		; |
		!MarioYPosLo		= !MarioYPos	; |
		!MarioYPosHi		= !MarioYPos+1	;/
		!MarioX			= !MarioXPos
		!MarioY			= !MarioYPos


		!GameMode		= $6100
		!PaletteRGB		= $6703
<<<<<<< Updated upstream
=======
		!Color0			= $6903
		!HorzLevelMode		= $6BF5		; tbn mmmmm (t = layer 2/3 uses map16, b = show bottom row, n = use new sprite system, mmmmm = horizontal level mode)
		!Layer2LevelMap16Addr	= $6C26
>>>>>>> Stashed changes
		!LevelMode		= $6D9B
		!MainScreen		= $6D9D
		!SubScreen		= $6D9E
		!HDMA			= $6D9F
<<<<<<< Updated upstream
		!MarioJoypad1Raw	= $6DA2
		!MarioJoypad2Raw	= $6DA4
		!MarioJoypad1RawOneF	= $6DA6
		!ItemBox		= $6DC2
=======
		!HeaderItemMem		= $73BE		; which of the !ItemMem tables to use (3 = ignore)
>>>>>>> Stashed changes
		!Translevel		= $73BF
		!BG2Height		= $73CD		; height of BG2, in tiles: OA-HHHHH (O = relative to FG only, A = auto-coord, H = height)
		!PauseTimer		= $73D3
		!Pause			= $73D4
		!LevelHeight		= $73D7
<<<<<<< Updated upstream
		!CapeImg		= $73DF
		!MarioImg		= $73E0
		!MarioWallWalk		= $73E3
		!CapeEnable		= $73E8
		!CapeXPosLo		= $73E9
		!CapeXPosHi		= $73EA
		!CapeYPosLo		= $73EB
		!CapeYPosHi		= $73EC
		!MarioBehind		= $73F9
=======
>>>>>>> Stashed changes
		!BG3TideSettings	= $7403		; 0 = no tide, 1 = tide that goes up/down, 2 = static tide
		!ScrollLayer1		= $7404
		!EnableHScroll		= $7411
		!EnableVScroll		= $7412
		!BG2ModeH		= $7413
		!BG2ModeV		= $7414
		!BG2BaseV		= $7417		; 16-bit
<<<<<<< Updated upstream
		!MsgTrigger		= $7426
=======
		!DoorCounter		= $741A
		!MsgTrigger		= $7426		; 16-bit
		!DeathTimer		= $743C		; used for death animation
>>>>>>> Stashed changes
		!ScrollSpriteNum	= $743E
		!ScrollSpriteNum_L1	= !ScrollSpriteNum
		!ScrollSpriteNum_L2	= $743F
		!BG3XSpeed		= $7458		; 16-bit
		!BG3YSpeed		= $745A		; 16-bit
		!BG3XFraction		= $745C		; 16-bit
		!BG3BaseSettings	= $745E		; first 5 bits determine y position, last 2 bits used by LM
		!BG3ScrollSettings	= $745F		; hi nybble is vertical option, lo nybble is horizontal option
		!BG3YFraction		= $7460		; 16-bit
		!BG3BaseH		= $746A		; 16-bit
<<<<<<< Updated upstream
		!MarioCarryingObject	= $7470
		!StarTimer		= $7490
		!LevelEnd		= $7493
		!MarioFlashTimer	= $7497
		!MarioCapeFloat		= $74A5
		!MarioCapeSpin		= $74A6
		!SpriteIndex		= $75E9
		!MarioKillCount		= $7697
=======
		!RNG_Seed1		= $748B		;\
		!RNG_Seed2		= $748C		; | vanilla compat
		!RNG_Seed3		= $748D		; | (seed 3 and 4 are sometimes read as output by vanilla sprites)
		!RNG_Seed4		= $748E		;/
		!StarTimer		= $7490
		!LevelEnd		= $7493
		!PSwitchTimer		= $74AD
		!SilverPTimer		= $74AE
		!SpriteIndex		= $75E9
>>>>>>> Stashed changes
		!CoinTimer		= $786B
		!ShakeTimer		= $7887
<<<<<<< Updated upstream
		!YoshiIndex		= $78E2
		!GeneratorNum		= $78B9
		!MarioStunTimer		= $78BD
		!WindowDir		= $7B88
		!WindowSize		= $7B89
		!SideExit		= $7B96
=======
		!ShakeBG1		= !ShakeTimer	; alt name
		!GeneratorNum		= $78B9
		!BuoyancySettings	= $790E		; 0x80 = enabled, 0x40 = enabled but disable BG2 interaction for sprites
		!HeaderTileset		= $7931
		!CurrentLayer		= $7933		; 0x00 = BG1, 0x80 = BG2/BG3
		!WindowDir		= $7B88
		!WindowSize		= $7B89


	; these can be freely used, as far as i can tell
	; note that 7BA1 is used during level load and CAN NOT be freely used
		; 7B8A	menu stuff related to old OW
		; 7B8B	old main menu stuff
		; 7B8C	old HDMA flag
		; 7B8D	old OW stuff
		; 7B8E	old OW stuff
		; 7B8F	old OW stuff
		; 7B90	old OW stuff
		; 7B91	old main menu stuff
		; 7B92	old main menu stuff
		; 7B93	"use secondary exits" flag, written during level load (bank 0D) but never read
		; 7B94	"disable bonus game" flag
		; 7B95	old yoshi stuff
		; 7B96	old side exit flag
		; 7B97	unused scroll sprite register
		; 7B99	old goal point register
		; 7B9A	old scroll sprite register
		; 7B9B	old yoshi stuff
		; 7B9C	old OW stuff
		; 7B9D	old rising/sinking water stuff
		; 7B9E	old OW stuff
		; 7B9F	old reznor stuff
		; 7BA0	old OW stuff
		; ONE BYTE USED HERE AT 7BA1 (LEVEL LOAD)
		; 7BA2-7BE2	old mode 7 stuff

		!LevelBorderExits	= $7BA2
		!UpExitLimitL		= !LevelBorderExits+$00
		!UpExitLimitR		= !LevelBorderExits+$02
		!LeftExitLimitU		= !LevelBorderExits+$04
		!LeftExitLimitD		= !LevelBorderExits+$06
		!RightExitLimitU	= !LevelBorderExits+$08
		!RightExitLimitD	= !LevelBorderExits+$0A
		!DownExitLimitL		= !LevelBorderExits+$0C
		!DownExitLimitR		= !LevelBorderExits+$0E
		!UpExitOverride		= !LevelBorderExits+$10
		!LeftExitOverride	= !LevelBorderExits+$12
		!RightExitOverride	= !LevelBorderExits+$14
		!DownExitOverride	= !LevelBorderExits+$16
		!HardBoxBorders		= !LevelBorderExits+$18		; flag (n trigger) when set, camera box borders clamp collision points and inherit level border exits


		!MusicBackup		= $6DDA		; set to 0xFF to prevent music from reloading on death
>>>>>>> Stashed changes
		!SPC1			= $7DF9
		!SPC2			= $7DFA
		!SPC3			= $7DFB
		!SPC4			= $7DFC
;		!LevelTable		= $7EA2

		!LevelTable1		= $7EA2		; BCH54321 (beaten, checkpoint flag, checkpoint level number hi bit, yoshi coins 1-5)
		!LevelTable2		= $6A60		; cccccccc (checkpoint level number lo byte)
		!LevelTable3		= $6120		; Rrrrrrrr (rank attained (0 = no 1 = yes), rank score (0-100))
		!LevelTable4		= $7938		; U-ssssss (unlock (0 = locked, 1 = unlocked), best time seconds (0-59))
		!LevelTable5		= $7F49		; --mmmmmm (best time minutes (0-63))

		!SpriteLoadStatus	= $418A00	; 255 bytes, 1 for each sprite in level data

	; -- Custom routines --
		!MPU_phase		= $1EFF			; phase SA-1 has to get to before MPU_wait can stop


		!InitSpriteTables	= $07F7D2
		; same as !ResetSprite
		; procedure: set sprite num + extra bits, then call, then set ID, then store coords + status
		; NOTE: shreds $00-$02 when called for a custom sprite!

		!GetMap16Sprite		= $138008
		!KillOAM		= $138010
		!GetMap16		= $138018
		!ProcessYoshiCoins	= $138020
		!GetVRAM		= $138028
		!GetCGRAM		= $138030
		!PlaneSplit		= $138038
		!HurtPlayers		= $138040
		!UpdateGFX		= $138048
		!UpdatePal		= $13804C
		!Contact16		= $138050
		!RGBtoHSL		= $138058
		!HSLtoRGB		= $138060
		!MixRGB			= $138068
		!MixRGB_Upload		= $138070
		!MixHSL			= $138078
		!MixHSL_Upload		= $138080
		!Update3DCluster	= $138088
		!Update2DCluster	= $13808C
		!GetFileAddress		= $138090
		!UpdateFromFile		= $138098
		!DecompFromFile		= $13809C
		!LoadFile		= $1380A0
		!SpriteHUD		= $1380A4
		!GetBigCCDMA		= $1380A8
		!GetSmallCCDMA		= $1380B0
		!BuildOAM		= $1380B8
		!ChangeMap16		= $1380C0
		!FadeLight		= $1380C4

		!PortraitPointers	= $378000		; DATA pointer stored with SP_Files.asm, along with portrait GFX
		!PalsetData		= $3F8000		; DATA pointer stored with SP_Files.asm, along with palset data
		!PlayerPalettes		= !PalsetData+5		;

		!PlayerClipping		= read3($00E3D6)	; pointer is stored with PCE.asm

		!GenerateBlock		= read3($04842E)	; pointer is stored with SP_Patch.asm
		!GetDynamicTile		= read3($048443)	; pointer is stored with SP_Patch.asm
		!UpdateClaimedGFX	= read3($048446)	; pointer is stored with SP_Patch.asm
		!TransformGFX		= read3($048449)	; pointer is stored with SP_Patch.asm
		!LoadPortrait		= read3($04844C)	; pointer is stored with SP_Patch.asm
		!GetRoot		= read3($04844F)	; pointer is stored with SP_Patch.asm

		!LoadPalset		= $048452		; pointer to LoadPalset routine, must be manually read to be accessed (this is to avoid repatch problems)


	macro CallMSG()
		JSL read3($00A1DF+1)+4
	endmacro


	; -- SMW and LM routines --

		!Random			= $01ACF9


		!BouncePlayer		= $01AA33
		!ContactGFX		= $01AB99

		!SpriteApplySpeed	= $01802A

		!GetSpriteSlot		= $02A9DE

<<<<<<< Updated upstream
		!GetSpriteClipping04	= $03B69F
		!GetSpriteClipping00	= $03B6E5

		!GetP1Clipping		= $03B664		; < Gets MARIO's clipping
		!CheckContact		= $03B72B

		!LoadTweakers		= $07F78B		; reloads vanilla tweakers and set OAM prop
=======
	;	!LoadTweakers		= $07F7A0		; reloads vanilla tweakers and sets OAM prop
>>>>>>> Stashed changes
		!ResetSprite		= $07F7D2		; hijacked by Fe26 to work with custom sprites
		; same as !InitSpriteTables
		; procedure: set sprite num + extra bits, then call, then set ID, then store coords + status
		; NOTE: shreds $00-$02 when called for a custom sprite!

		!ResetSpriteExtra	= $0187A7		; reloads spawn data

		!DecompressFile		= $0FF900


	; -- Data and pointers --

		!Map16ActsLike		= $06F624		; for pages 00-3F
		!Map16ActsLike40	= $06F63A		; for pages 40-7F

		!TrigTable		= $07F7DB

		!Map16BG		= $0EFD50		; 8 24-bit pointers
								; first to data for map16 pages 80-8F
								; next to data for pages 90-9F, and so on
								; if a pointer is zero, those pages are unused


	; -- Values --			; These allow easier customization.

		!Climb1			= $36
		!Climb2			= $36
		!Climb3			= $37
		!Climb4			= $37
		!ClimbUpSpeed		= $F0
		!ClimbDownSpeed		= $10
		!ClimbLeftSpeed		= $F0
		!ClimbRightSpeed	= $10

	; -- Graphics --
<<<<<<< Updated upstream

		!P2Tile1		= $20		;\
		!P2Tile2		= $22		; | Located in SP1
		!P2Tile3		= $24		; |
		!P2Tile4		= $26		;/
		!P2Tile5		= $28
		!P2Tile6		= $2A
		!P2Tile7		= $2C
		!P2Tile8		= $2E
=======
		!P1Tile1		= $00		;\
		!P1Tile2		= $02		; |
		!P1Tile3		= $04		; |
		!P1Tile4		= $06		; | first 64x32 block in SP1
		!P1Tile5		= $20		; |
		!P1Tile6		= $22		; |
		!P1Tile7		= $24		; |
		!P1Tile8		= $26		;/

		!P2Tile1		= $08		;\
		!P2Tile2		= $0A		; |
		!P2Tile3		= $0C		; |
		!P2Tile4		= $0E		; | second 64x32 block in SP1
		!P2Tile5		= $28		; |
		!P2Tile6		= $2A		; |
		!P2Tile7		= $2C		; |
		!P2Tile8		= $2E		;/
>>>>>>> Stashed changes

		!P2TileOffset		= !P2Tile1-!P1Tile1

		!SP1			= $6000
		!SP2			= $6800
		!SP3			= $7000
		!SP4			= $7800


	; -- Booleans --		; Don't mess with these.

		!True 			= 1
		!False			= 0

