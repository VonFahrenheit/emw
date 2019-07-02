header
sa1rom

;==============;
;MESSAGE ENGINE;
;==============;
; - Info:
; This routine should be called at $00A1DF with a JSL, to hijack SMW's routine at the very start.
; It will not conflict with Lunar Magic, since it hijacks the routine much later.
; I made this primarily because I'm too stubborn to use RPG Hacker's VWF Dialogues patch in one of my own projects.
; The patch does rely on SP_Patch.asm to clear !MsgRAM at game save load.


; - Hijacks:


;	org $008293
;	print " "
;	print "Updated status bar scanline count at $", pc, "."
;
;		db $24					; How many scanlines the status bar takes (vanilla is 0x24)

	org $00A1DF
	print "Inserted hijack at $", pc, "."

		autoclean JSL MESSAGE_ENGINE		; Hijack message box routine


; - Defines:

	incsrc "Defines.asm"

	!MaxSize		= $48
	!MinSize		= $00
	!GrowSpeed		= $08
	!ShrinkSpeed		= $F8

	!MsgData		= $03BC0B		; Use this to figure out where Lunar Magic puts message data

	; All of this RAM goes in bank $40!

	!MsgRAM			= $4400			; 256 bytes, base address

	!MsgTileNumber		= !MsgRAM+$00		; 1 byte
	!MsgTileNumberHi	= !MsgRAM+$01		; 1 byte
	!MsgOptions		= !MsgRAM+$02		; 1 byte
	!MsgArrow		= !MsgRAM+$03		; 1 byte
	!MsgDestination		= !MsgRAM+$04		; 3 bytes
	!MsgSequence		= !MsgRAM+$07		; 15 bytes, read backwards.
	!MsgScroll		= !MsgRAM+$16		; 1 byte
	!MsgCounter		= !MsgRAM+$17		; 1 byte
	!MsgDelay		= !MsgRAM+$18		; 1 byte
	!MsgWait		= !MsgRAM+$19		; 1 byte
	!MsgWaitFlag		= !MsgRAM+$1A		; 1 byte
	!MsgWaitScroll		= !MsgRAM+$1B		; 1 byte
	!SubMsg			= !MsgRAM+$1C		; 1 byte, loads the specified submessage when set
	!SubMsgTileNumber	= !MsgRAM+$1D		; 1 byte
	!MsgPortrait		= !MsgRAM+$1E		; 1 byte
	!MsgSpeed		= !MsgRAM+$1F		; 1 byte
	!MsgEnd			= !MsgRAM+$20		; 1 byte
	!MsgOffset		= !MsgRAM+$21		; 1 byte
	!MsgFont		= !MsgRAM+$22		; 1 byte
	!MsgVRAM1		= !MsgRAM+$23		; 2 bytes, portrait (lo plane)
	!MsgVRAM2		= !MsgRAM+$25		; 2 bytes, portrait (hi plane)
	!MsgVRAM3		= !MsgRAM+$27		; 2 bytes, border
	!MsgBackup41		= !MsgRAM+$29		; 1 byte
	!MsgBackup42		= !MsgRAM+$2A		; 1 byte
	!MsgBackup43		= !MsgRAM+$2B		; 1 byte
	!MsgBackup44		= !MsgRAM+$2C		; 1 byte
	!MsgBackup0D9D		= !MsgRAM+$2D		; 1 byte
	!MsgBackup0D9E		= !MsgRAM+$2E		; 1 byte
	!MsgBackup24		= !MsgRAM+$2F		; 1 byte
	!MsgBackup25		= !MsgRAM+$30		; 1 byte
	!MsgCommandData		= !MsgRAM+$31		; Variable length, maximum of 207 bytes.
							; Last 86 bytes used by dynamic BG3


	!GraphicsLoc	= $3000				; 24-bit pointer to graphics file
	!GraphicsSize	= $3003				; 8-bit number of 8x8 tiles

	!BufferLo	= $404A00			; 24-bit pointer to decompression buffer.
	!BufferHi	= !BufferLo+(!BufferSize/2)	; Hi buffer.
	!BufferSize	= $0400				; Size of buffer. Must be divisible by 4.

	!GFX0		= $10				; Points to GFX+$00
	!GFX1		= $13				; Points to GFX+$01
	!GFX2		= $16				; Points to GFX+$10
	!GFX3		= $19				; Points to GFX+$11
	!GFX4		= $1C				; Points to GFX+$20




; - Code:

	freecode
	print "Lunar Magic's message data is located at $", hex(read3($03BC0B)), "."
	print "Custom code inserted at $", pc, "."

	MESSAGE_ENGINE:


		PHB : LDA #$40
		PHA : PLB

		LDA !MsgDelay
		BEQ .NoDelay
		DEC !MsgDelay
		PLB
		RTL

.NoDelay	LDA !MsgWait
		BEQ .NoWait
		LDA !MsgWaitFlag
		BEQ +
		LDA !MsgWaitScroll			;\
		CMP !MsgWait				; | Wait for the text to scroll
		BEQ ++					;/
		INC !MsgWaitScroll			;\ Increment message scroll
		INC !MsgWaitScroll			;/
		LDA !MsgWaitScroll			;\
		REP #$20				; |
		AND #$00FF				; |
		SEC : SBC #$0010			; | Apply message scroll
		STA $24					; |
		SEP #$20				; |
		CLC : ADC #$10				;/

		CMP !MsgWait
		BNE .NoWipe
		LDA #$09 : STA $12			; > Wipe message box

		.NoWipe
		PLB
		RTL

	+	LDA $16
		AND #$F0
		BNE +
		LDA $18
		AND #$C0
		BNE +
		PLB
		RTL

	+	LDA !MsgWaitFlag
		BNE ++
		INC !MsgWaitFlag
		PLB
		RTL

	++	STZ !MsgWait				; Clear wait for input
		STZ !MsgWaitFlag			; Clear this flag too
		STZ $16					;\ Wipe joypad 1 for this frame
		STZ $18					;/

.NoWait		PHK : PLB				; Change bank
		LDX $7B88				; X = Window growing/shrinking flag
		LDA $7B89				; A = Window size
		BNE .NoBackup
		TXY
		BNE .NoBackup
.Backup		LDA $41 : STA $400000+!MsgBackup41
		LDA $42 : STA $400000+!MsgBackup42
		LDA $43 : STA $400000+!MsgBackup43
		LDA $44 : STA $400000+!MsgBackup44
		LDA $6D9D : STA $400000+!MsgBackup0D9D
		LDA $6D9E : STA $400000+!MsgBackup0D9E
		LDA $24 : STA $400000+!MsgBackup24
		LDA $25 : STA $400000+!MsgBackup25
		LDA $7B89
.NoBackup	CMP.w DATA_05B108,x			; Compare to max/min size
		BNE .WrongSize				; Handle window size
		TXA
		BEQ .LoadMsg				; Branch if shrinking flag is clear
		STZ !MsgTrigger				; Clear message
		STZ $7B88				; Set window to not closing
		LDA $400000+!MsgBackup41 : STA $41
		LDA $400000+!MsgBackup42 : STA $42
		LDA $400000+!MsgBackup43 : STA $43
		LDA $400000+!MsgBackup44 : STA $44
		LDA $400000+!MsgBackup0D9D : STA $6D9D
		LDA $400000+!MsgBackup0D9E : STA $6D9E
		LDA $400000+!MsgBackup24 : STA $24
		LDA $400000+!MsgBackup25 : STA $25

		LDA #$40
		PHA : PLB
		STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		STZ !MsgOffset
		STZ !MsgOptions
		STZ !MsgArrow
		STZ !MsgDestination
		STZ !MsgDestination+$01
		STZ !MsgDestination+$02
		STZ !MsgScroll

.Return		PLB
		RTL

.WrongSize	CMP.w DATA_05B106,x
		BNE .WindowJump
		JSR OAM_SUBROUTINE
		LDA #$09				;\ Clear text box
		STA $12					;/
.WindowJump	JMP HANDLE_WINDOWING

.LoadMsg	JSR DRAW_BORDER				; > Draw sprite border
		LDA #$40				;\ Switch to bank 40
		PHA : PLB				;/
		LDA !MsgPortrait			;\
		BEQ +					; | Draw sprite portrait
		JSR DRAW_PORTRAIT			;/
	+	LDA !MsgScroll				;\
		CMP #$40				; |
		BCC +					; |
		LDX !MsgCounter				; | Load next message
		DEX					; |
		STX !MsgCounter				; |
		LDA !MsgSequence,x			; |
		STA $007426				;/

		LDA #$09				;\ Clear message box
		STA $12					;/
		STZ !MsgScroll				; Reset layer 3 Ypos
		STZ !MsgWaitScroll			; Clear message scroll
		STZ !MsgEnd				; Reset message
		PLB
		RTL

	+	LDA !MsgEnd				;\
		ORA !MsgScroll				; | Don't write text if these are set
		BNE .SkipText				;/
		JSR UPLOAD_TEXT				; > Upload message
.SkipText	STZ $22					;\ Lock layer 3 Hscroll
		STZ $23					;/
		LDA !MsgScroll				;\
		BEQ .DontScroll				; | Increment message scroll
		INC !MsgScroll				; |
		INC !MsgScroll				;/
.DontScroll	CLC : ADC !MsgWaitScroll		; > Add message scroll
		REP #$20				;\
		AND #$00FF				; |
		BCC $04 : CLC : ADC #$0100		; | Apply BG3 Vscroll
		SEC : SBC #$0010			; |
		STA $24					; |
		SEP #$20				;/
		PLB					; Restore bank
	;	LDA $6109				; Check intro stage flag
		ORA $73D2				; Check switch palace flag
		BEQ .CheckControls
		LDA $7DF5				; Load timer

	BRA .CheckControls

		BEQ .CheckControls
		LDA $13					;\
		AND #$03				; |
		BNE +					; | Decrement timer
		DEC $7DF5				; |
		BNE +					;/
		LDA $73D2
		BEQ .CheckControls
		INC $7DE9
		LDA #$01
		STA $73CE
		STA $6DD5
		LDA #$0B
		STA !GameMode
	+	RTL

.CheckControls	LDA $6109
		BNE +++
		PHB : LDA #$40
		PHA : PLB
		LDA !MsgScroll
		BNE ++
		LDA $16
		AND #$F0
		BNE +
		LDA $18
		AND #$C0
		BNE +
		PLB
		RTL

	++	STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		STZ !MsgOffset
		PLB
		RTL

	+++	LDA #$98				;\ Starting Ypos on OW
		;STA $7F19				;/
		STZ $6109
		STZ $6DD5
		LDA #$0B
		STA !GameMode
		RTL

	+	LDA #$40
		PHA : PLB
		LDX !MsgCounter
		BEQ .Close
		JMP .NextMessage

		.Close
		PLB					; > Restore bank
		INC $7B88				; > Close window
		REP #$20				; > A 16-bit
		LDA #$F0F0				;\
		STA !OAM+$01 : STA !OAM+$11		; |
		STA !OAM+$05 : STA !OAM+$15		; |
		STA !OAM+$09 : STA !OAM+$19		; |
		STA !OAM+$0D : STA !OAM+$1D		; |
		STA !OAM+$21 : STA !OAM+$31		; |
		STA !OAM+$25 : STA !OAM+$35		; |
		STA !OAM+$29 : STA !OAM+$39		; | Remove border and portrait
		STA !OAM+$2D : STA !OAM+$3D		; |
		STA !OAM+$41 : STA !OAM+$51		; |
		STA !OAM+$45 : STA !OAM+$55		; |
		STA !OAM+$49 : STA !OAM+$59		; |
		STA !OAM+$4D : STA !OAM+$5D		; |
		STA !OAM+$61 : STA !OAM+$71		; |
		STA !OAM+$65 : STA !OAM+$75		; |
		STA !OAM+$69 : STA !OAM+$79		; |
		STA !OAM+$6D : STA !OAM+$7D		; |
		STA !OAM+$81 : STA !OAM+$85		;/
		LDA.w #.SA1 : STA $3180			;\
		SEP #$20				; | A 8-bit
		LDA.b #.SA1>>16 : STA $3182		; | Have SA-1 clear out RAM (but not VRAM/backups)
		JSR $1E80				;/
		RTL					; > Return


		.SA1
		PHP
		PHB
		LDA #$40 : PHA : PLB
		REP #$20 : LDA #$0000
		STA !MsgRAM+$00 : STA !MsgRAM+$02
		STA !MsgRAM+$04 : STA !MsgRAM+$06
		STA !MsgRAM+$08 : STA !MsgRAM+$0A
		STA !MsgRAM+$0C : STA !MsgRAM+$0E
		STA !MsgRAM+$10 : STA !MsgRAM+$12
		STA !MsgRAM+$14 : STA !MsgRAM+$16
		STA !MsgRAM+$18 : STA !MsgRAM+$1A
		STA !MsgRAM+$1C : STA !MsgRAM+$1E
		STA !MsgRAM+$20 : STA !MsgRAM+$21
		PLB
		PLP
		RTL


		.NextMessage
		LDA #$01
		STA !MsgScroll
		STZ $16
		STZ $18
		STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		LDA !MsgOptions
.SomeF0		BEQ +
		LDA !MsgDestination			;\
		STA $00					; |
		LDA !MsgDestination+$01			; |
		STA $01					; | Write option to address
		LDA !MsgDestination+$02			; |
		STA $02					; |
		LDA !MsgArrow				; |
		STA [$00]				;/
		STZ !MsgOptions
	+	PLB
		RTL

HANDLE_WINDOWING:
		PHB : LDA #$40
		PHA : PLB
		STZ !MsgTileNumber			;\
		STZ !MsgTileNumberHi			; |
		STZ !MsgOffset				; | Make sure the counters don't mess up
		STZ !MsgScroll				; |
		STZ !MsgDelay				; |
		STZ !MsgWaitScroll			;/
		LDA #$F0 : STA $24			;\ Reset BG3 Vscroll
		LDA #$FF : STA $25			;/

		PLB

		LDA $7B89
		LDY $7B88
		BNE +
		CMP.b #!MaxSize-!GrowSpeed
		BEQ ++
	+	JMP .SkipINIT
	++	PHA					; > Push window size
		PHP					; > Push processor
		PHB : LDX #$40				;\ Set bank
		PHX : PLB				;/
		JSL !GetVRAM				; > Get VRAM table index
		LDA #SPRITE_TILES>>16			;\
		STA !VRAMtable+$04,x			; | bank
		STA !VRAMtable+$0B,x			;/
		REP #$20				; > A 16 bit
		LDA #$0080				;\
		STA !VRAMtable+$00,x			; | size
		STA !VRAMtable+$07,x			;/
		LDA #SPRITE_TILES			;\
		STA !VRAMtable+$02,x			; | source
		CLC : ADC #$00A0			; |
		STA !VRAMtable+$09,x			;/
		LDA !MsgVRAM3				;\
		STA !VRAMtable+$05,x			; | VRAM
		CLC : ADC #$0100			; |
		STA !VRAMtable+$0C,x			;/


		.ApplyHeader
		PHY					; > Preserve Y
		REP #$10				; > Index 16 bit
		LDA $007426				;\
		AND #$00FF				; |
		DEC A					; | 01 and 02 are always normal messages
		STA $00					; |
		CMP #$0002				; |
		BCC ..NormalHeader			;/
		LDA $0073BF				;\
		AND #$00FF				; |
		TAX					; | Normal if level doesn't have ExMessages
		LDA.l ExMessage_H000,x			; |
		BEQ ..NormalHeader			;/
		INC #2					;\
		CMP $00					; |
		BCS ..ExHeader				; |
		LDA $00					; | See if an ExMessage has been selected
		SEC : SBC.l ExMessage_H000,x		; |
		STA $00					; |
		BRA ..NormalHeader			;/
		..ExHeader				;\
		PHB : PHK : PLB				; |
		LDA $73BF				; |
		AND #$00FF				; |
		ASL A					; | Get ExMessage header location
		TAX					; |
		LDA ExMessage_MainPtr,x			; |
		STA $0E					; |
		LDA $00					; |
		DEC #2					; |
		ASL A					; |
		TAY					; |
		LDA ($0E),y				; |
		PLB					; |
		BRA ..Shared				;/
		..NormalHeader				;\
		LDA $0073BF				; |
		AND #$00FF				; |
		ASL A					; | Get normal header location
		CLC : ADC $00				; |
		ASL A					; |
		TAX					; |
		LDA.l HEADER_Ptr,x			;/
		..Shared				;\
		STA $00					; |
		SEP #$30				; | Set bank pointer
		PHK : PLA				; |
		STA $02					;/
		LDY #$00				;\
		LDA [$00],y				; |
		BEQ ..NoPortrait			; |
		STA !MsgPortrait			; |
		..NoPortrait				; |
		INY					; |
		LDA [$00],y				; |
		BEQ ..NoSequence			; |
		STA !MsgSequence			; | Apply message header
		INC !MsgCounter				; |
		..NoSequence				; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgOptions				; |
		BEQ ..NoDialogue			; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgDestination+$00			; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgDestination+$01			; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgDestination+$02			; |
		..NoDialogue				; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgSpeed				; |
		PLY					; |
		PLB					; |
		PLP					;/
		LDA #$22 : STA !SPC4			; > Play message box sound
		PLA					; > Pull window size

.SkipINIT	CLC : ADC.w DATA_05B10A,y
		STA $7B89
		CLC : ADC #$80
		XBA
		LDA #$80
		SEC : SBC $7B89
		REP #$20				; > A 16 bit
		LDX #$00
		LDY #$50
.Loop		CPX $7B89				;\
		BCC +					; |
		LDA.w #$00FF				; |
	+	STA $650C,y				; |
		STA $655C,x				; | Write to windowing table
		INX					; |
		INX					; |
		DEY					; |
		DEY					; |
		BNE .Loop				;/
		SEP #$20				; > A 8 bit
		LDA #$22				;\ Enable window 1 for BG1 and BG2
		STA $41					;/
		LDY $73D2
		BEQ .Return
		LDA #$20				;\ Enable window 1 for color layer
.Return		STA $43					;/
		LDA #$20
		STA $44
		LDA #$03				;\ Enable inverted layer 3 masking
		STA $42					;/

		LDX #$04				;\
	-	LDA $009277,x				; |
		STA $4320,x				; | Enable SMW's HDMA settings
		DEX					; |
		BPL -					;/
		LDA #$00				;\ Indirect HDMA bank
		STA $4327				;/
		LDA #$1F				;\
		STA $6D9D				; | Everything on main screen
		STZ $6D9E				;/

		LDA #$04				;\ Enable HDMA on channel 2
		TSB $6D9F				;/
		PLB
		RTL


DATA_05A580:	db $50,$C7				; First half of stripe image headers.
		db $50,$E7
		db $51,$07
		db $51,$27
		db $51,$47
		db $51,$67
		db $51,$87
		db $51,$A7


DATA_05B106:	db !MaxSize-!GrowSpeed,!MaxSize		; Determines when to write to OAM.
DATA_05B108:	db !MaxSize,!MinSize			; Maximum/minimum values for window size. Minimum should be 00.
DATA_05B10A:	db !GrowSpeed,!ShrinkSpeed		; Message box growing/shrinking speed.

;=============;
;HELP ROUTINES;
;=============;

OAM_SUBROUTINE:
;
; These OAM writes set the Ypos of switch palace tiles.
;
		LDY #$1C
		LDA #$F0
.Loop		STA !OAM+$01,y
		DEY
		DEY
		DEY
		DEY
		BPL .Loop
		RTS

SWITCH_PALACE:
		LDA !MsgTileNumber
		CMP #$5A
		BCC .Return
		PHY
		LDY #$01
		LDA $0073BF
		CMP #$14
		BEQ .Process				; Yellow Switch Palace
		INY
		CMP #$45
		BEQ .Process				; Blue Switch Palace
		INY
		CMP #$3F
		BEQ .Process				; Red Switch Palace
		INY
		CMP #$08
		BEQ .Process				; Green Switch Palace
		PLY
.Return		RTS

.Process	PHB : PHK : PLB
		PHX
		TYX
		STX $73D2				; Set colour of Switch Palace
		DEX
		TXA
		ASL #4
		TAX
		STZ $00
		REP #$20
		LDY #$1C
.Loop		LDA.l $05B29B,x				;\
		STA !OAM+$02,y				; |
		PHX					; |
		LDX $00					; |
		LDA.l $05B2DB,x				; |
		STA !OAM+$00,y				; |
		PLX					; |
		INX					; | Draw sprite tiles
		INX					; |
		INC $00					; |
		INC $00					; |
		DEY					; |
		DEY					; |
		DEY					; |
		DEY					; |
		BPL .Loop				;/
		STZ !OAM+$200
		SEP #$20
		PLX : PLB : PLY
		RTS


;======================;
;TEXT UPLOADING ROUTINE;
;======================;
UPLOAD_TEXT:	LDA #$00 : XBA				; Wipe hi byte of A
		LDA !MsgTileNumber			;\
		LDY #$00				; |
	-	CMP #$12				; |
		BCC .CalcDone				; | Calculate Xpos and Ypos of tile
		SEC : SBC #$12				; |
		INY					; |
		BRA -					;/

.CalcDone	STY $02					; Store line number
		REP #$30				; All registers 16 bit
		XBA
		STA $04					; Store 16 bit Xpos

		LDA $007426				; Load message number
		AND #$00FF				; Wipe hi byte
		DEC A					; Decrement so it can be used for indexing
		STA $00					; Store to scratch RAM
		CMP #$0002
		BCC .NormalMessage

		LDA $0073BF
		AND #$00FF
		TAX
		LDA.l ExMessage_H000,x
		BEQ .NormalMessage
		INC #2
		CMP $00
		BCS .ExMessage
		LDA $00
		SEC : SBC.l ExMessage_H000,x
		STA $00
		BRA .NormalMessage

.ExMessage	PHB : PHK : PLB
		LDA $73BF
		AND #$00FF
		ASL A
		TAX
		LDA ExMessage_MainPtr,x
		STA $0E
		TYX
		LDA $00
		DEC #2
		ASL A
		TAY
		PHK : PHK
		PLA : STA $09
		LDA ($0E),y
		CLC : ADC #$0004
		STA $08
		STZ $00
		TXY
		PLB
		BRA .Process

.NormalMessage	LDA $0073BF
		AND #$00FF
		ASL A					; > Each level has 2 messages
		CLC : ADC $00				; > Add with message number
		ASL A					; > Each pointer is 2 bytes
		TAX					;\ Load pointer from table in bank 03
		LDA $03BE80,x				;/
		STA $00					; $00 = index to message data

		LDA !MsgData+$00 : STA $08
		LDA !MsgData+$01 : STA $09

		LDA !MsgSpeed				;\
		AND #$00FF				; | Upload entire message if text speed is 0x00
		BNE .Process				; |
		JMP UPLOAD_ALL				;/

.Process	TYA : ASL A				;\ X = Line number times 2 (index to header table)
		TAX					;/
		LDA.l DATA_05A580,x			;\ Calculate first half of stripe header
		CLC : ADC $04				;/
		PHA

		LDA $7F837B : TAX			;\
		PLA : STA $7F837D,x			; | Upload stripe image header (1 tile)
		LDA #$0100				; |
		STA $7F837F,x				;/
		TXA : CLC : ADC.w #$0006		;\ Increment table index
		STA $7F837B				;/
		PHX					; Push table index

		LDA !MsgTileNumber			; Load data index
		AND.w #$00FF
		STA $04
		LDA !MsgOffset
		AND.w #$00FF
		CLC : ADC $04				; Add offset caused by commands
		CLC : ADC $00				; Add message index
		TAY					; Y = Message data index

		SEP #$20				; A 8 bit


.Read		LDA [$08],y				; Load tile to upload
		JSR HANDLE_COMMANDS			; > Handle message commands
		PLX					; X = Table index
		STA $7F8381,x				; Upload tile
		LDA #$39				;\ Set YXPCCCTT
		STA $7F8382,x				;/
		LDA #$FF				;\ End upload
		STA $7F8383,x				;/
		SEP #$10				; Index 8 bit
.LineReturn	JSR SWITCH_PALACE

		LDA !MsgTileNumber
		CMP #$8F
		BNE .Increment
		STA !MsgEnd
		RTS

.Increment	INC !MsgTileNumber			; Increment tile number
.Return		RTS					; Return


UPLOAD_ALL:	STZ $02					; Clear $02-$03
		LDA $7F837B : TAX
		LDY $00
		SEP #$20

	--	PHX
		REP #$20
		LDA $03
		AND #$00FF
		ASL A
		TAX
		LDA.l .Headers,x
		PLX
		STA $7F837D,x
		LDA #$2300 : STA $7F837F,x
		INX #4
		SEP #$20
	-	LDA [$08],y
		CMP #$FF : BEQ .End
		STA $7F837D,x
		LDA #$39 : STA $7F837E,x
		INY
		INX #2
		INC $02
		LDA $02
		CMP #$12
		BNE -
		INC $03
		LDA $03
		CMP #$08
		BEQ .End
		STZ $02
		BRA --

		.End
	-	LDA $02
		CMP #$12 : BEQ .Done
		LDA #$1F : STA $7F837D,x
		LDA #$39 : STA $7F837E,x
		INX #2
		INC $02
		BRA -

		.Done
		LDA #$FF : STA $7F837D,x
		TXA : STA $7F837B
		XBA : STA $7F837C
		LDA #$8F : STA !MsgTileNumber
		LDA #$1F : STA !MsgEnd
		SEP #$10
		RTS


		.Headers
		db $50,$C7
		db $50,$E7
		db $51,$07
		db $51,$27
		db $51,$47
		db $51,$67
		db $51,$87
		db $51,$A7


DRAW_BORDER:	PHK : PLB
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		RTS


		.SA1
		PHP
		PHB
		LDA.b #!OAM_HiPrio>>16 : PHA		; > Push bank for later
		REP #$30
		LDA.w #.End-.TileMap-1
		LDX.w #.TileMap
		LDY.w #!OAM_HiPrio
		MVN !OAM_HiPrio>>16,.TileMap>>16
		PLB					; > Pop bank
		REP #$20
		LDA #$AAAA				;\
		STA.w !OAM_HiPrio+$200			; |
		STA.w !OAM_HiPrio+$202			; | Set tilesize to 16x16
		STA.w !OAM_HiPrio+$204			; |
		STA.w !OAM_HiPrio+$205			;/
		LDA #$0068 : STA.w !OAM_HiPrioIndex	; > Set index
		PLB
		PLP
		RTL


		;  ___ ___ ___ ___
		; | X | Y | T | P |

.TileMap	db $31,$37,$EB,$21			; > Topleft corner
		db $41,$37,$EC,$21			;\
		db $51,$37,$EC,$21			; |
		db $61,$37,$EC,$21			; |
		db $71,$37,$EC,$21			; | Upper border
		db $81,$37,$EC,$21			; |
		db $91,$37,$EC,$21			; |
		db $A1,$37,$EC,$21			; |
		db $B1,$37,$EC,$21			;/
		db $C1,$37,$EB,$61			; > Topright corner
		db $31,$47,$EE,$21			;\
		db $C1,$47,$EE,$61			; |
		db $31,$57,$EE,$21			; | Side borders
		db $C1,$57,$EE,$61			; |
		db $31,$67,$EE,$21			; |
		db $C1,$67,$EE,$61			;/
		db $31,$77,$EB,$A1			; > Botleft corner
		db $41,$77,$EC,$A1			;\
		db $51,$77,$EC,$A1			; |
		db $61,$77,$EC,$A1			; |
		db $71,$77,$EC,$A1			; | Lower border
		db $81,$77,$EC,$A1			; |
		db $91,$77,$EC,$A1			; |
		db $A1,$77,$EC,$A1			; |
		db $B1,$77,$EC,$A1			;/
		db $C1,$77,$EB,$E1			; > Botright corner
		.End


DRAW_PORTRAIT:	BPL .INIT
		JMP .MAIN

		.INIT
		DEC A
		ASL #2
		TAX
		LDA.l SPRITE_TILES_Ptr+0,x		;\
		STA !GraphicsLoc+$00			; |
		LDA.l SPRITE_TILES_Ptr+1,x		; |
		STA !GraphicsLoc+$01			; | GFX pointer
		LDA.l SPRITE_TILES_Ptr+2,x		; |
		STA !GraphicsLoc+$02			;/


		LDA #!VRAMbank
		PHA : PLB
		JSL $138030				;\ Get CGRAM table index
		BCS ++					;/
		LDA #$3E : STA !CGRAMtable+$00,y	;\ Data size
		LDA #$00 : STA !CGRAMtable+$01,y	;/
		LDA.l SPRITE_TILES_Ptr+3,x		;\
		ASL A					; |
		CLC : ADC.l SPRITE_TILES_Ptr+3,x	; |
		TAX					; |
		LDA.l SPRITE_TILES_Palette+0,x		; | Source address
		STA !CGRAMtable+$02,y			; |
		LDA.l SPRITE_TILES_Palette+1,x		; |
		STA !CGRAMtable+$03,y			; |
		LDA.l SPRITE_TILES_Palette+2,x		; |
		STA !CGRAMtable+$04,y			;/
		LDA !MsgPal : STA !CGRAMtable+$05,y	; > Destination CGRAM

	++	LDA #$10 : STA !GraphicsSize		; > 16 8x8 tiles
		JSL PLANE_SPLIT				; > Decode

		REP #$20				; > A 16-bit
		JSL !GetVRAM				; > Get VRAM upload slot
		LDA #$0080				;\
		STA !VRAMtable+$00,x			; |
		STA !VRAMtable+$07,x			; |
		STA !VRAMtable+$0E,x			; |
		STA !VRAMtable+$15,x			; | Upload sizes
		STA !VRAMtable+$1C,x			; |
		STA !VRAMtable+$23,x			; |
		STA !VRAMtable+$2A,x			; |
		STA !VRAMtable+$31,x			;/
		LDA.w #!BufferLo+$000			;\
		STA !VRAMtable+$02,x			; |
		LDA.w #!BufferLo+$080			; |
		STA !VRAMtable+$09,x			; |
		LDA.w #!BufferLo+$100			; |
		STA !VRAMtable+$10,x			; |
		LDA.w #!BufferLo+$180			; | Source of data
		STA !VRAMtable+$17,x			; |
		LDA.w #!BufferHi+$000			; |
		STA !VRAMtable+$1E,x			; |
		LDA.w #!BufferHi+$080			; |
		STA !VRAMtable+$25,x			; |
		LDA.w #!BufferHi+$100			; |
		STA !VRAMtable+$2C,x			; |
		LDA.w #!BufferHi+$180			; |
		STA !VRAMtable+$33,x			;/
		LDA.w #!BufferLo>>16			;\
		STA !VRAMtable+$04,x			; |
		STA !VRAMtable+$0B,x			; |
		STA !VRAMtable+$12,x			; |
		STA !VRAMtable+$19,x			; | Data bank
		STA !VRAMtable+$20,x			; |
		STA !VRAMtable+$27,x			; |
		STA !VRAMtable+$2E,x			; |
		STA !VRAMtable+$35,x			;/
		LDA !MsgVRAM1 : STA !VRAMtable+$05,x	;\
		CLC : ADC #$0100 : STA !VRAMtable+$0C,x	; |
		SEC : SBC #$00C0 : STA !VRAMtable+$13,x	; |
		CLC : ADC #$0100 : STA !VRAMtable+$1A,x	; | Dest VRAM
		LDA !MsgVRAM2 : STA !VRAMtable+$21,x	; |
		CLC : ADC #$0100 : STA !VRAMtable+$28,x	; |
		SEC : SBC #$00C0 : STA !VRAMtable+$2F,x	; |
		CLC : ADC #$0100 : STA !VRAMtable+$36,x	;/

		LDA #$0080 : TSB !MsgPortrait		; > Set portrait init flag


		.MAIN
		REP #$20
		LDA !MsgVRAM1
		LSR #4
		STA $00
		LDA !MsgVRAM2
		LSR #4
		SEP #$20
		STA $01

		LDA !MsgPortrait
		PHB : PHK : PLB				; Bank wrapper
		AND #$40				;\
		ORA #$30				; | Get YXPPCCCT
		STA $02					;/
		LDA !MsgPal
		LSR #4
		SEC : SBC #$08
		ASL A
		TSB $02
		LDA $400001+!MsgVRAM1
		CMP #$70
		BCC +
		LDA #$01 : TSB $02
		+

		LDY #$03				; Y = times to loop
		BIT $02					;\ Check direction
		BVC .Right				;/

.Left		LDX.w .OAM+$00,y			; > Lo plane OAM index
		LDA.w .XLeft,y				;\ Lo plane xpos
		STA.l !OAM_HiPrio+$000,x		;/
		LDA.w .Y,y				;\ Lo plane ypos
		STA.l !OAM_HiPrio+$001,x		;/
		LDA.w .TilesLeft,y			;\
		CLC : ADC $00				; | Lo plane tile number
		STA.l !OAM_HiPrio+$002,x		;/
		LDA $02					;\ Lo plane YXPPCCCT
		STA.l !OAM_HiPrio+$003,x		;/
		LDX.w .OAM+$04,y			; > Hi plane OAM index
		LDA.w .XLeft,y				;\ Hi plane xpos
		STA.l !OAM_HiPrio+$000,x		;/
		LDA.w .Y,y				;\ Hi plane ypos
		STA.l !OAM_HiPrio+$001,x		;/
		LDA.w .TilesLeft,y			;\
		CLC : ADC $01				; | Hi plane tile number
		STA.l !OAM_HiPrio+$002,x		;/
		LDA $02					;\
		INC #2					; | Hi plane YXPPCCCT
		STA.l !OAM_HiPrio+$003,x		;/
		DEY					;\ Decrement loop count and loop
		BPL .Left				;/
		BRA .End

.Right		LDX.w .OAM+$00,y			; > Lo plane OAM index
		LDA.w .XRight,y				;\ Lo plane xpos
		STA.l !OAM_HiPrio+$000,x		;/
		LDA.w .Y,y				;\ Lo plane ypos
		STA.l !OAM_HiPrio+$001,x		;/
		LDA.w .TilesRight,y			;\
		CLC : ADC $00				; | Lo plane tile number
		STA.l !OAM_HiPrio+$002,x		;/
		LDA $02					;\ Lo plane YXPPCCCT
		STA.l !OAM_HiPrio+$003,x		;/
		LDX.w .OAM+$04,y			; > Hi plane OAM index
		LDA.w .XRight,y				;\ Hi plane xpos
		STA.l !OAM_HiPrio+$000,x		;/
		LDA.w .Y,y				;\ Hi plane ypos
		STA.l !OAM_HiPrio+$001,x		;/
		LDA.w .TilesRight,y			;\
		CLC : ADC $01				; | Hi plane tile number
		STA.l !OAM_HiPrio+$002,x		;/
		LDA $02					;\
		INC #2					; | Hi plane YXPPCCCT
		STA.l !OAM_HiPrio+$003,x		;/
		DEY					;\ Decrement loop count and loop
		BPL .Right				;/

.End		LDA #$AA				;\
		STA !OAM_HiPrio+$207			; | Set tile size
		STA !OAM_HiPrio+$208			;/
		LDA #$88 : STA.l !OAM_HiPrioIndex	; > Update index to hi prio OAM
		PLB : RTS				; > Restore bank 0x40 and return


.OAM		db $68,$6C,$70,$74			; Lo
		db $78,$7C,$80,$84			; Hi

.XLeft		db $31,$41,$31,$41
.XRight		db $B1,$C1,$B1,$C1
.Y		db $17,$17,$27,$27
.TilesLeft	db $02,$00,$06,$04
.TilesRight	db $00,$02,$04,$06




;========================;
;COMMAND-HANDLING ROUTINE;
;========================;
HANDLE_COMMANDS:

		CMP.b #((.End-.Ptr-2)/2)^$FF
		BCS +
		CMP #$1F : BEQ .Return
		PHA
		LDA !MsgSpeed
		STA !MsgDelay
		LDA #$01 : STA.l !SPC1
		PLA

		.Return
		RTS

	+	XBA
		LDA #$00
		XBA
		EOR #$FF
		ASL A
		TAX
		JMP (.Ptr,x)

.Ptr		dw .End			; FF
		dw .LineBreak		; FE	<-- This one doesn't work because of Lunar Magic, use F3
		dw .Give1Ups		; FD
		dw .P1Character		; FC, character number
		dw .P2Character		; FB, character number
		dw .NextMessage		; FA, message number
		dw .SubMessage		; F9, submessage number
		dw .Dialogue		; F8, option count
		dw .Delay		; F7, frame count
		dw .WaitForInput	; F6, line count
		dw .AutoScroll		; F5, line count
		dw .Portrait		; F4, portrait index
		dw .LineBreak		; F3	<-- This one works, for some reason Lunar Magic doesn't let you insert FE
		dw .InstantLine		; F2
		dw .LinkMessage		; F1
		dw .TextSpeed		; F0, speed value

.End		LDA #$1F
		STA !MsgEnd
		RTS

.LineBreak	LDA $02
		TAX
		LDA.l ..Lines,x
		STA !MsgTileNumber
		INC $02
		LDA #$1F
		RTS

..Lines		db $11
		db $23
		db $35
		db $47
		db $59
		db $6B
		db $7D
		db $8F
		db $A1
		db $B3
		db $C5
		db $D7
		db $E9
		db $FB

.Give1Ups	LDA #$04				;\ Set lives to 5
		STA $006DBE				;/
		LDA #$05				;\ Play 1-up sound
		STA $007DFC				;/
		LDA #$1F
		RTS

.P1Character	INY
		LDA [$08],y				; Load next byte
		ASL #4					; Convert to proper format
		STA $0F					; Store to scratch RAM
		LDA.w !Characters			;\
		AND #$0F				; | Overwrite player 1 character with next byte
		ORA $0F					; |
		STA.w !Characters			;/
		INC !MsgTileNumber
		LDA #$1F
		RTS

.P2Character	INY
		LDA [$08],y
		STA $0F
		LDA.w !Characters
		AND #$F0
		ORA $0F
		STA.w !Characters
		INC !MsgTileNumber
		LDA #$1F
		RTS

.NextMessage	LDA !MsgCounter
		TAX
		INY
		LDA [$08],y
		STA !MsgSequence,x
		INC !MsgCounter
		INC !MsgTileNumber
		LDA #$1F
		RTS

.SubMessage	INY
		LDA [$08],y
		STA !SubMsg
		STZ !SubMsgTileNumber
		BRA .LineBreak

.Dialogue	INY
		LDA [$08],y
		STA !MsgOptions
		STZ !MsgArrow
		INC !MsgTileNumber
		LDA #$1F
		RTS

.Delay		INY
		LDA [$08],y
		STA !MsgDelay
		INC !MsgTileNumber
		LDA #$1F
		RTS

.WaitForInput	INY
		LDA [$08],y
		ASL #3
		STA !MsgWait
		INC !MsgTileNumber
		LDA #$1F
		RTS

.AutoScroll	INY
		LDA [$08],y
		ASL #3
		STA !MsgWait
		INC !MsgWaitFlag
		INC !MsgTileNumber
		LDA #$1F
		RTS

.Portrait	INY
		LDA [$08],y
		STA !MsgPortrait
		INC !MsgTileNumber
		LDA #$1F
		RTS

.InstantLine	LDA $02
		TAX
		REP #$20
		LDA.l DATA_05A580,x

		PHA					;\
		TYA					; |
		SEC : SBC $04				; | Calculate new index
		CLC : ADC.l DATA_05A580,x		; |
		TAY					; |
		PLA					;/

		PLX : PLX : PHX				; Kill RTS and restore X
		STA $7F837D,x				; Set first half of stripe image header
		LDA #$2300
		STA $7F837F,x
		SEP #$20
		LDA $02
		TAX
		LDA.l .LineBreak_Lines,x
		STA !MsgTileNumber
		PLX
		LDA #$12
		STA $0F
	-	LDA [$08],y
		STA $7F8381,x
		LDA #$39
		STA $7F8382,x
		INX
		INX
		INY
		DEC $0F
		BNE -
		LDA #$FF
		STA $7F8381,x
		SEP #$10				; All registers 8 bit
		JMP UPLOAD_TEXT_LineReturn		; Return

.LinkMessage	LDA !MsgCounter
		TAX
		LDA $007426
		INC A
		STA !MsgSequence,x
		INC !MsgCounter
		LDA #$1F
		RTS

.TextSpeed	INY
		LDA [$08],y
		STA !MsgSpeed
		INC !MsgTileNumber
		LDA #$1F
		RTS

cleartable
table "MessageTable.txt"

incsrc "MessageHeaders.asm"
incsrc "ExMessages.asm"
incsrc "5bpp.asm"


SPRITE_TILES:

.Misc		incbin "Border.bin"			; GFX file to load border from
.Mario		incbin "Portraits/Mario.bin"		; Mario's portrait
.Luigi		incbin "Portraits/Luigi.bin"		; Luigi's portrait
.Leeway		incbin "Portraits/Leeway.bin"		; Leeway's portrait
.Yoshi		incbin "Portraits/Yoshi.bin"		; Yoshi's portrait
.CaptainWarrior	incbin "Portraits/CaptainWarrior.bin"	; Captain Warrior's portrait
.Rex		incbin "Portraits/Rex.bin"		; Generic Rex portrait


.Palette	dl .LuigiPal
		dl .CaptainWarriorPal
		dl .RexPal

	.MarioPal
		dw $029F,$2093,$186E,$000A
		dw $0EFF,$30B7,$351B,$391F
		dw $7FFF,$7F97,$023F,$0842
		dw $019F,$253A,$7FDC,$0000	; < Break
		dw $35DF,$1514,$08CA,$56BF
		dw $677F,$48C4,$7BDF,$2118
		dw $2D7B,$013F,$00FD,$5228
		dw $4D45,$6B91,$0000

	.LuigiPal
		dw $7EED,$7EA8,$1E61,$2BA7
		dw $3FE0,$1140,$7FFF,$7E64
		dw $2F20,$7BD8,$22C2,$0421
		dw $7E20,$05DC,$7FFD,$0000	; < Break
		dw $167F,$32FF,$08C9,$0511
		dw $3C07,$535F,$75C0,$6BBF
		dw $3F1F,$5140,$646C,$7D34
		dw $7CAE,$7DB4,$65A0

	.LeewayPal
		dw $4F31,$00C8,$09B4,$4FAF
		dw $2569,$10A6,$177E,$1AFB
		dw $1A98,$739C,$7FFF,$16FB
		dw $6318,$175F,$46AF,$0000	; < Break
		dw $56B5,$0441,$0822,$1637
		dw $3A4D,$1196,$15FA,$2DCA
		dw $227E,$0952,$1D2C,$18E9
		dw $216F,$2DD4,$0000

	.YoshiGreenPal
		dw $7D9D,$7D1A,$7D1B,$09C0
		dw $0520,$1780,$12C0,$0920
		dw $737B,$7FFF,$7C18,$1D08
		dw $5AD6,$0421,$008F,$0000	; < Break
		dw $39CE,$029F,$01BC,$6C14
		dw $01BB,$00B8,$1BC0,$17E0
		dw $1380,$5FF7,$540E,$440C
		dw $3C0C,$3008,$0000

	.CaptainWarriorPal
		dw $7F29,$18E8,$7FFF,$6B9F
		dw $0000,$635C,$05F9,$256D
		dw $4ED8,$3E96,$3634,$6ACA
		dw $76EA,$069B,$2DB1,$0000	; < Break
		dw $0572,$1FBF,$175C,$06FD
		dw $5229,$628A,$01DF,$1EBF
		dw $025F,$05BE,$013C,$49C8
		dw $7F6F,$0000,$0000

	.RexPal
		dw $03D3,$036E,$2529,$18C6
		dw $7108,$739C,$7FFF,$6739
		dw $30A1,$5AD6,$71AD,$6A2F
		dw $0842,$02EC,$7E52,$0000	; < Break
		dw $616A,$0269,$0226,$011A
		dw $00B8,$019D,$025F,$6F7B
		dw $0180,$000A,$0100,$4E73
		dw $0000,$0000,$0000


; Portraits are pretty straight-forward.
; Each portrait uses 4 bytes: a 24-bit pointer to GFX data, and an 8-bit index to palette pointers.
; Setting the second highest bit of the index X-flips the portrait and puts it on the left side of the message box.

.Ptr		dl .Luigi		: db $00	; Portrait 1
		dl .CaptainWarrior	: db $01	; Portrait 2
		dl .Rex			: db $02	; Portrait 3


.End

	print "In total this patch takes up ", freespaceuse, " (0x", hex(SPRITE_TILES_End-MESSAGE_ENGINE), ") bytes."
	print " "