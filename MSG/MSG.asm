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
	print " "
	print "Inserted hijack at $", pc, "."

		autoclean JML MESSAGE_ENGINE		; Hijack message box routine


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
	!MsgOptionRow		= !MsgRAM+$04		; 1 byte, which row the dialogue options start on
	!MsgDestination		= !MsgRAM+$05		; 1 byte, determines what !MsgArrow writes to
	!MsgVertOffset		= !MsgRAM+$06		; 1 byte, number of pixels to move window down
							;	  highest bit toggles portrait to top-right of screen
	!MsgSequence		= !MsgRAM+$07		; 15 bytes, read backwards.
	!MsgScroll		= !MsgRAM+$16		; 1 byte
	!MsgCounter		= !MsgRAM+$17		; 1 byte
	!MsgDelay		= !MsgRAM+$18		; 1 byte
	!MsgWait		= !MsgRAM+$19		; 1 byte
	!MsgWaitFlag		= !MsgRAM+$1A		; 1 byte
	!MsgWaitScroll		= !MsgRAM+$1B		; 1 byte, also used as a kind of scratch during cinematic mode
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
	!MsgTalk		= !MsgRAM+$31		; 1 byte
	!MsgCinematic		= !MsgRAM+$32		; 1 byte, enables cinematic mode
	!MsgCommandData		= !MsgRAM+$33		; Variable length, maximum of 205 bytes.
							; Used to upload text during cinematic mode
							; Last 86 bytes used by dynamic BG3





; - Code:

	freecode
	print "Lunar Magic's message data is located at $", hex(read3($03BC0B)), "."
	print "Custom code inserted at $", pc, "."

	TrueReturn:
		LDA.l !MsgMode : BEQ .Mode0
		CMP #$01 : BEQ .Mode1
		CMP #$02 : BEQ .Mode2

		.Mode0					; Vanilla mode
		JML $00A1E3

		.Mode1					; Run animations but don't let players move
		LDA #$02
		STA !P2Stasis-$80
		STA !P2Stasis

		.Mode2					; Everything moves during message
		LDX #$21				;\
		LDA #$02				; |
	-	STA !OAMhi,x				; | Set proper OAM size
		DEX					; |
		BPL -					;/
		LDA #$88 : STA !OAMindex		; > Set OAM index to after message tiles
		JML $00A1E4				; > Execute game mode


	MESSAGE_ENGINE:

		PHK : PEA TrueReturn-1			; Set proper return address
		PHB : LDA #$40
		PHA : PLB

		LDA !MsgDelay : BEQ .NoDelay
		DEC !MsgDelay
		PLB
		RTL

.NoDelay	LDA !MsgCinematic			;\ Go directly here in cinematic mode
		BNE .NoWait				;/
		LDA !MsgWait
		BEQ .NoWait
		LDA !MsgWaitFlag
		BEQ +
		LDA !MsgWaitScroll			;\
		CMP !MsgWait				; | Wait for the text to scroll
		BEQ ++					;/
		INC !MsgWaitScroll			;\ Increment message scroll
		INC !MsgWaitScroll			;/
		LDA !MsgVertOffset			;\
		AND #$007F				; | get window offset
		STA $00					;/
		LDA !MsgWaitScroll			;\
		REP #$20				; |
		AND #$00FF				; |
		SEC : SBC #$0010			; | Apply message scroll
		SEC : SBC $00				; > apply window offset
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

		LDA.l $400000+!MsgCinematic
		BEQ $03 : JMP HANDLE_WINDOWING

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
		LDA #$00 : STA.l !MsgMode		; Clear message mode

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
		STZ !MsgOptionRow
		STZ !MsgDestination
		STZ !MsgScroll

.Return		PLB
		RTL

.WrongSize	CMP.w DATA_05B106,x
		BNE .WindowJump
		JSR OAM_SUBROUTINE
		LDA #$09				;\ Clear text box
		STA $12					;/
.WindowJump	JMP HANDLE_WINDOWING

.LoadMsg	LDA.l !MsgMode
		BEQ .NoClear
		JSL !KillOAM				; Clear OAM during message mode 1 and 2
		.NoClear

		JSR DRAW_BORDER				; > Draw sprite border
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
		STA.l $000000+!MsgTrigger		;/

		LDA #$09				;\ Clear message box
		STA $12					;/
		STZ !MsgScroll				; Reset layer 3 Ypos
		STZ !MsgWaitScroll			; Clear message scroll
		STZ !MsgEnd				; Reset message
		LDA #$40
		PHA : PLB
		PHP
		REP #$20
		JSR ApplyHeader
		PLP
		PLB
		RTL

	+	LDA !MsgEnd				;\
		ORA !MsgScroll				; | Don't write text if these are set
		BNE .SkipText				;/
		JSR UPLOAD_TEXT				; > Upload message
.SkipText	STZ $22					;\ Lock layer 3 Hscroll
		STZ $23					;/
		LDA !MsgVertOffset			;\
		AND #$7F				; | get window offset
		STA $00					; |
		STZ $01					;/
		LDA !MsgScroll				;\
		BEQ .DontScroll				; | Increment message scroll
		INC !MsgScroll				; |
		INC !MsgScroll				;/
.DontScroll	CLC : ADC !MsgWaitScroll		; > Add message scroll
		REP #$20				;\
		AND #$00FF				; |
		BCC $04 : CLC : ADC #$0100		; | Apply BG3 Vscroll
		SEC : SBC #$0010			; |
		SEC : SBC $00				; > apply window offset
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

.CheckControls	LDA $6109 : BNE +++
		PHB : LDA #$40
		PHA : PLB
		LDA !MsgScroll : BNE ++
		LDA !MultiPlayer : BEQ ..1P
	..2P	LDA.l $6DA7				;\
		ORA.l $6DA9				; |
	..1P	ORA.l $6DA6				; | normal mode input
		ORA.l $6DA8				; |
		STA $00					;/
		AND #$F0 : BNE +			; end message if a button is pushed

		LDA !MsgOptions : BEQ ..R		; return if there is no dialogue options
		LDA !MsgEnd : BEQ ..R			; only process arrow at the end of a message
		JSR UPDATE_ARROW			; update arrow tile
		LDA $00					;\
		AND #$0C : BEQ ..R			; |
		CMP #$0C : BEQ ..SFX			; |
		CMP #$08 : BEQ ..Up			; |
	..Down	LDA !MsgArrow				; |
		INC A					; |
		CMP !MsgOptions : BCC ..W		; | move dialogue arrow
		LDA #$00 : BRA ..W			; |
	..Up	LDA !MsgArrow				; |
		DEC A					; |
		BPL ..W					; |
		LDA !MsgOptions				; |
		DEC A					; |
	..W	STA !MsgArrow				;/
	..SFX	LDA #$06 : STA.l !SPC4			; cursor SFX
	..R	PLB
		RTL

	++	STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		STZ !MsgOffset

	-
		PLB
		RTL

	+++	;LDA #$98				;\ Starting Ypos on OW
		;STA $7F19				;/
		STZ $6109
		STZ $6DD5
		LDA #$0B
		STA !GameMode
		RTL

	+	LDA !MsgEnd : BEQ -
		LDA !MsgCounter
		ORA !MsgOptions
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
		STA !MsgRAM+$31
		PLB
		PLP
		RTL


		.NextMessage
		LDA #$01 : STA !MsgScroll
		STZ $16
		STZ $18
		STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		LDA !MsgOptions
.SomeF0		BEQ +

	; dialogue feedback code

		STZ !MsgOptions
		LDA !MsgArrow
		INC A
		LDX !MsgDestination : BEQ .Level
		CPX #$01 : BEQ .MSG
		BRA +

	.Level	STA.l !Level+4
		JMP .Close

	.MSG	LDX !MsgCounter
		CLC : ADC.l !MsgTrigger
		STA !MsgSequence,x
		INC !MsgCounter

	+	PLB
		RTL

HANDLE_WINDOWING:
		PHB : LDA #$40
		PHA : PLB
		LDA !MsgCinematic : BNE .Cinematic	; Check for cinematic mode
		JMP .Normal


; In cinematic mode, !MsgOffset controls the position of the drawn tile
;		     !MsgTileNumber determines where to read data


		.Cinematic
		LDA !MsgMode : BEQ ..NoClear		; Don't clear during message mode 0
		JSL !KillOAM				; Needed since level mode doesn't clear OAM during message
		..NoClear

		PHP					;\
		REP #$20				; |
		STZ $22					; | Keep BG3 in place
		LDA #$FFFC : STA $24			; |
		PLP					;/

		LDA !MsgWait : BEQ ..NoWait		;\
		DEC !MsgWait				; |
	..R	PLB					; | Wait
		PLB					; |
		RTL					; |
		..NoWait				;/

		LDA !MsgWaitFlag : BEQ ..NoInput	;\
		LDA !MultiPlayer : BEQ ..1P		; |
	..2P	LDA.l $6DA7				; |
		ORA.l $6DA9				; |
	..1P	ORA.l $6DA6				; | Wait for input
		ORA.l $6DA8				; |
		AND #$F0 : BEQ ..R			; |
		STZ !MsgWaitFlag			; |
		..NoInput				;/

		LDA.l $7B89				;\
		CMP #$47 : BNE +			; |
		LDA !MsgEnd : BNE +			; |
		JSR UPLOAD_TEXT				; |
		SEP #$10				; |
		LDA !MsgWaitScroll : BNE ++		; > Don't draw on the same frame that a special command is used
		JSL !GetVRAM				; |
		LDA #$40 : STA !VRAMtable+$04,x		; |
		PHP					; |
		REP #$20				; |
		LDA.w #!MsgCommandData			; | Upload text
		STA !VRAMtable+$02,x			; |
		LDA !MsgOffset				; |
		AND #$00FF				; > It's a word address so no ASL here
		PHA					; |
		ORA #$5000				; |
		STA !VRAMtable+$05,x			; |
		LDA $01,s				; |
		CMP #$0020 : BCS ..Not0			; |
		ASL A					; |
		PHX					; |
		TAX					; |
		LDA !MsgCommandData+0 : STA.l $000020,x	; |
		PLX					; |
	..Not0	LDA #$0002 : STA !VRAMtable+$00,x	;/

		PLA					;\
		AND #$001F				; |
		CMP #$001E : BNE ..NoRow		; | Keep edge columns clear
		INC !MsgOffset				; |
		INC !MsgOffset				; |
		..NoRow					;/

		PLP					;\
		BRA ++					; | Clear regs while growing/shrinking
	+	JSR .Wipe				; |
		++					;/

		LDA !MsgEnd : BEQ ..Inc			;\
		LDA !MsgArrow : BNE ..C			; > Only clear once
	..Dec	JSR CINEMATIC_COMMANDS_Clear		; |
		LDA #$01 : STA !MsgArrow		; > Mark as cleared
	..C	PLB					; |
		LDA $7B89				; |
		SEC : SBC #$04				; | Handle shrinking window
		BPL $01 : TDC				; |
		STA $7B89				; |
		CMP #$00 : BNE ..W			; |
		STA.l $400000+!MsgCinematic		; |
		JMP MESSAGE_ENGINE_Close		;/

	..Inc	PLB					;\
		LDA $7B89				; |
		CLC : ADC #$04				; | Handle growing window
		CMP #$47				; |
		BCC $02 : LDA #$47			; |
		STA $7B89				;/
	..W	PHP					;\
		REP #$20				; |
		LDA $7B89				; |
		AND #$00FF				; | Math for window
		ASL A					; |
		STA $00					; |
		LDY #$00				;/
		LDA #$FF00				; Entire scanline
	-	STA $64A0,y				;\
		INY #2					; | Write up to $7B89,
		CPY $00 : BNE +				; | then remove windowing below it
		XBA					; |
	+	CPY #$90 : BNE -			;/
		PLP

		JMP .SetHDMA

	; HDMA setting is:
	; mode:		41	(2 regs write once, indirect)
	; reg:		26	(window 1 left edge + window 1 right edge)
	; source:	$00927C	(that table holds the data: $F0,$A0,$04,$F0,$80,$05,$00)
	; bank:		$00	(indirect)
	; The indirect table almost certainly means that:
	; $64A0 is read for 0x70 scanlines
	; $6580 is read for 0x70 scanlines
	; $00 terminates the channel
	; The actual window begins at $650C (scanline 0x36)


		.Normal
		JSR .Wipe				; > Wipe counters
		LDA #$F0 : STA $24			;\ Reset BG3 Vscroll
		LDA #$FF : STA $25			;/

	PHP
	REP #$20
	JSR ApplyHeader
	PLP
	LDA !MsgCinematic : BEQ $03 : JMP .Cinematic

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

	;	JSR ApplyHeader
		PLB					;\ Pull stuff
		LDX #$22 : STX !SPC4			; > Play message box sound
		PLP					;/
		PLA					; > Pull window size




.SkipINIT	CLC : ADC.w DATA_05B10A,y
		STA $7B89
		CLC : ADC #$80
		XBA
		LDA.l $400000+!MsgVertOffset
		ASL A
		STA $00					; store window offset
		TAX					; X = window offset
		CLC : ADC #$50				;\ Y = window offset + 0x50
		TAY					;/
		SEC : SBC #$50				;\
		CLC : ADC $7B89				; | set up mirror of $7B89
		STA $01					;/
		LDA #$80
		SEC : SBC $7B89
		REP #$20				; > A 16 bit
.Loop		CPX $01 : BCC +				;\
		LDA.w #$00FF				; |
	+	STA $650C,y				; |
		STA $655C,x				; | Write to windowing table
		INX					; |
		INX					; |
		DEY					; |
		DEY					; |
		CPY $00 : BNE .Loop			;/


.SetHDMA	SEP #$20				; > A 8 bit
		LDA #$22				;\ Enable window 1 for BG1 and BG2
		STA $41					;/
		LDY $73D2 : BEQ .Return
		LDA #$20				;\ Enable window 1 for color layer
.Return		STA $43					;/
		LDA #$20
		STA $44
		LDA #$03				;\ Enable inverted layer 3 masking
		STA $42					;/

		LDX #$04				;\
	-	LDA.l $009277,x				; |
		STA $4320,x				; | Enable SMW's HDMA settings
		DEX					; |
		BPL -					;/
		STZ $4327				; > Indirect HDMA bank
		LDA #$1F				;\
		STA $6D9D				; | Everything on main screen
		STZ $6D9E				;/

		LDA #$04				;\ Enable HDMA on channel 2
		TSB $6D9F				;/
		PLB
		RTL


		.Wipe
		STZ !MsgTileNumber			;\
		STZ !MsgTileNumberHi			; |
		STZ !MsgOffset				; | Make sure the counters don't mess up
		STZ !MsgScroll				; |
		STZ !MsgDelay				; |
		STZ !MsgWaitScroll			;/
		RTS


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


;============;
;APPLY HEADER;
;============;
ApplyHeader:
.Main
		PHY					; > Preserve Y
		REP #$10				; > Index 16 bit
		LDA.l $000000+!MsgTrigger		;\
		AND #$00FF				; |
		DEC A					; | 01 and 02 are always normal messages
		STA $00					; |
		CMP #$0002				; |
		BCC ..NormalHeader			;/
		LDA.l $0073BF				;\
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
		LDA.l $0073BF				; |
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
		STZ !MsgCinematic			; > Clear cinematic mode here
		BPL $03 : INC !MsgCinematic		; > Check for cinematic mode
		STA !MsgPortrait			; |
		..NoPortrait				; |
		INY					; |
		LDA [$00],y				; |
		BEQ ..NoSequence			; |
		STA !MsgSequence			; | Apply message header
		LDA #$01 : STA !MsgCounter		; |
		..NoSequence				; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgOptions				; |
		BEQ ..NoDialogue			; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgOptionRow+$00			; |
		INY					; |
		LDA [$00],y				; |
		STA !MsgDestination			; |
		..NoDialogue				; |
		INY					; |
		LDA [$00],y				; |
		AND #$3F				; |
		STA !MsgSpeed				; |
		LDA [$00],y				; |
		ROL #3					; |
		AND #$03				; |
		STA !MsgMode				; |
		PLY					;/
		RTS					; > Return


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
		LDA.l ExMessage_H000,x : BEQ .NormalMessage
		INC #2
		CMP $00 : BCS .ExMessage
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
		LDA ($0E),y : STA $00
		CLC : ADC #$0004
		STA $08
		LDY #$0002
		LDA ($00),y
		AND #$00FF : BEQ ..NoDialogue
		INC $08					;\ header is 2 bytes longer if dialogue is set
		INC $08					;/
		..NoDialogue
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

.Process	LDA !MsgSpeed				;\
		AND #$00FF				; | Upload entire message if text speed is 0x00
		BNE .Gradual				; |
		JMP UPLOAD_ALL				;/

.Gradual	LDA !MsgCinematic
		AND #$00FF
		BEQ ..Normal


..Cinematic	STZ !MsgWaitScroll			; don't worry about wiping !SubMessage here
	-	LDY !MsgTileNumber			; 16-bit index
		INC !MsgTileNumber
		SEP #$20
		LDA [$08],y
		CMP #$F7 : BCC +
		JSR CINEMATIC_COMMANDS
		BCS -
	...R	RTS

	+	STA !MsgCommandData+0
		LDA #$39 : STA !MsgCommandData+1

		LDA !MultiPlayer : BEQ ...1P		;\
		LDA.l $6DA3				; |
		ORA.l $6DA5				; | text goes at max speed if A/B is held
	...1P	ORA.l $6DA2				; |
		ORA.l $6DA4				; |
		CMP #$40 : BCS ...Spd			;/

		LDA !MsgSpeed : STA !MsgDelay		; > Wait
	...Spd	INC !MsgOffset				;\
		LDA !MsgOffset : BNE ...R		; | Clear box if it's full
	...C	JMP CINEMATIC_COMMANDS_Clear		;/


..Normal	TYA : ASL A				;\ X = Line number times 2 (index to header table)
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
		STA $06
		LDA !MsgOffset
		AND.w #$00FF
		CLC : ADC $06				; Add offset caused by commands
		CLC : ADC $00				; Add message index
		TAY					; Y = Message data index

		SEP #$20				; A 8 bit


.Read		LDA [$08],y				; Load tile to upload
		JSR HANDLE_COMMANDS			; > Handle message commands
		PLX					; X = Table index
		STA $7F8381,x				; Upload tile
		LDA !TextPal				;\
		ORA #$21				; | Set YXPCCCTT
		STA $7F8382,x				;/
		LDA #$FF				;\ End upload
		STA $7F8383,x				;/
		SEP #$10				; Index 8 bit
.LineReturn	JSR SWITCH_PALACE

		LDA !MsgTileNumber
		CMP #$8F : BNE .Increment
		STA !MsgEnd
		RTS

.Increment	INC !MsgTileNumber			; Increment tile number
.Return		RTS					; Return



UPLOAD_ALL:	PHB : PHK : PLB
		LDY $00
		STZ $04					; end flag
		LDA !TextPal-1
		AND #$FF00
		ORA #$2100
		STA $02
		LDX #$0000
	-	LDA $04 : BEQ +
		LDA #$001F : BRA ++
	+	LDA [$08],y
		AND #$00FF
		CMP #$00FF : BNE $02 : STA $04
		CMP #$00F0
		BCC $03 : LDA #$001F
	++	ORA $02
		STA $0800,x
		INX #2
		INY
		CPY #$0090 : BNE -
		PLB

	.Done	SEP #$30
		LDA #$10 : STA !MsgEnd
		LDA #$8F : STA !MsgTileNumber
		JSL !GetVRAM
		LDA #$00
		STA !VRAMtable+$04,x
		STA !VRAMtable+$0B,x
		STA !VRAMtable+$12,x
		STA !VRAMtable+$19,x
		STA !VRAMtable+$20,x
		STA !VRAMtable+$27,x
		STA !VRAMtable+$2E,x
		STA !VRAMtable+$35,x
		REP #$20
		LDA #$0800 : STA !VRAMtable+$02,x
		LDA #$0824 : STA !VRAMtable+$09,x
		LDA #$0848 : STA !VRAMtable+$10,x
		LDA #$086C : STA !VRAMtable+$17,x
		LDA #$0890 : STA !VRAMtable+$1E,x
		LDA #$08B4 : STA !VRAMtable+$25,x
		LDA #$08D8 : STA !VRAMtable+$2C,x
		LDA #$08FC : STA !VRAMtable+$33,x

		LDA #$50C7 : STA !VRAMtable+$05,x
		LDA #$50E7 : STA !VRAMtable+$0C,x
		LDA #$5107 : STA !VRAMtable+$13,x
		LDA #$5127 : STA !VRAMtable+$1A,x
		LDA #$5147 : STA !VRAMtable+$21,x
		LDA #$5167 : STA !VRAMtable+$28,x
		LDA #$5187 : STA !VRAMtable+$2F,x
		LDA #$51A7 : STA !VRAMtable+$36,x

		LDA #$0024
		STA !VRAMtable+$00,x
		STA !VRAMtable+$07,x
		STA !VRAMtable+$0E,x
		STA !VRAMtable+$15,x
		STA !VRAMtable+$1C,x
		STA !VRAMtable+$23,x
		STA !VRAMtable+$2A,x
		STA !VRAMtable+$31,x

		SEP #$20
		RTS





DRAW_BORDER:	PHK : PLB
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		RTS


		.SA1
		PHP
		PHB : PHK : PLB
		SEP #$30
		LDA.l $400000+!MsgVertOffset		;\
		AND #$7F				; | Y offset
		STA $00					;/
		REP #$20				;\
		LDA.l $400000+!MsgVRAM3			; |
		LSR #4					; | tile offset
		SEP #$20				; |
		STA $01					;/
	-	LDA.w .TileMap+0,x : STA.w !OAM+0,x
		LDA.w .TileMap+1,x
		CLC : ADC $00
		STA.w !OAM+1,x
		LDA.w .TileMap+2,x
		CLC : ADC $01
		STA !OAM+2,x
		LDA.w .TileMap+3,x : STA !OAM+3,x
		INX #4
		CPX.b #.End-.TileMap : BNE -

		REP #$20
		LDA #$AAAA				;\
		STA.w !OAM+$200				; |
		STA.w !OAM+$202				; | Set tilesize to 16x16
		STA.w !OAM+$204				; |
		STA.w !OAM+$205				;/
		PLB
		PLP
		RTL


		;  ___ ___ ___ ___
		; | X | Y | T | P |

.TileMap	db $31,$37,$00,$21			; > Topleft corner
		db $41,$37,$01,$21			;\
		db $51,$37,$01,$21			; |
		db $61,$37,$01,$21			; |
		db $71,$37,$01,$21			; | Upper border
		db $81,$37,$01,$21			; |
		db $91,$37,$01,$21			; |
		db $A1,$37,$01,$21			; |
		db $B1,$37,$01,$21			;/
		db $C1,$37,$00,$61			; > Topright corner
		db $31,$47,$03,$21			;\
		db $C1,$47,$03,$61			; |
		db $31,$57,$03,$21			; | Side borders
		db $C1,$57,$03,$61			; |
		db $31,$67,$03,$21			; |
		db $C1,$67,$03,$61			;/
		db $31,$77,$00,$A1			; > Botleft corner
		db $41,$77,$01,$A1			;\
		db $51,$77,$01,$A1			; |
		db $61,$77,$01,$A1			; |
		db $71,$77,$01,$A1			; | Lower border
		db $81,$77,$01,$A1			; |
		db $91,$77,$01,$A1			; |
		db $A1,$77,$01,$A1			; |
		db $B1,$77,$01,$A1			;/
		db $C1,$77,$00,$E1			; > Botright corner
		.End

; 10C5A3
DRAW_PORTRAIT:	BPL .INIT
		JMP .MAIN





		.INIT
		DEC A
	;	ASL A
		ASL #2
		TAX
		LDA.l !PortraitPointers+2,x : STA $00	;\
		LDA.l !PortraitPointers+3,x : STA $01	; | GFX pointer
		LDA.l !PortraitPointers+4,x : STA $02	;/


		LDA #!VRAMbank
		PHA : PLB
		JSL !GetCGRAM				;\ Get CGRAM table index
		BCS ++					;/
		LDA #$3E : STA !CGRAMtable+$00,y	;\ Data size
		LDA #$00 : STA !CGRAMtable+$01,y	;/
		LDA.l !PortraitPointers+5,x		;\
		ASL A					; |
		TAX					; |
		LDA.l $130000+read2(!PortraitPointers)+0,x	; | Source address
		STA !CGRAMtable+$02,y			; |
		LDA.l $130000+read2(!PortraitPointers)+1,x	; |
		STA !CGRAMtable+$03,y			; |
		LDA.b #!PortraitPointers>>16		; |
		STA !CGRAMtable+$04,y			;/
		LDA !MsgPal : STA !CGRAMtable+$05,y	; > Destination CGRAM

	++	LDA #$10 : STA $03			; > 16 8x8 tiles
		JSL !PlaneSplit				; > Decode

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

		LDA.l $400000+!MsgVertOffset : STA $0F	; store this for later

		LDY #$03				; Y = times to loop
		BIT $02					;\ Check direction
		BVC .Right				;/

.Left		LDX.w .OAM+$00,y			; > Lo plane OAM index
		LDA.w .XLeft,y				;\ Lo plane xpos
		STA.w !OAM+$000,x			;/
		LDA.w .Y,y				;\ Lo plane ypos
		STA.w !OAM+$001,x			;/
		LDA.w .TilesLeft,y			;\
		CLC : ADC $00				; | Lo plane tile number
		STA.w !OAM+$002,x			;/
		LDA $02					;\ Lo plane YXPPCCCT
		STA.w !OAM+$003,x			;/
		LDX.w .OAM+$04,y			; > Hi plane OAM index
		LDA.w .XLeft,y				;\ Hi plane xpos
		STA.w !OAM+$000,x			;/
		LDA.w .Y,y				;\ Hi plane ypos
		STA.w !OAM+$001,x			;/
		LDA.w .TilesLeft,y			;\
		CLC : ADC $01				; | Hi plane tile number
		STA.w !OAM+$002,x			;/
		LDA $02					;\
		INC #2					; | Hi plane YXPPCCCT
		STA.w !OAM+$003,x			;/
		DEY					;\ Decrement loop count and loop
		BPL .Left				;/
		BRA .End

.Right		LDX.w .OAM+$00,y			; > Lo plane OAM index
		LDA.w .XRight,y				;\
		BIT $0F : BPL +				; | Lo plane xpos
		LDA.w .XSpecial,y			; |
	+	STA.w !OAM+$000,x			;/
		LDA.w .Y,y				;\
		BIT $0F : BPL +				; | Lo plane ypos
		LDA.w .YSpecial,y			; |
	+	STA.w !OAM+$001,x			;/
		LDA.w .TilesRight,y			;\
		CLC : ADC $00				; | Lo plane tile number
		STA.w !OAM+$002,x			;/
		LDA $02					;\ Lo plane YXPPCCCT
		STA.w !OAM+$003,x			;/
		LDX.w .OAM+$04,y			; > Hi plane OAM index
		LDA.w .XRight,y				;\
		BIT $0F : BPL +				; | Hi plane xpos
		LDA.w .XSpecial,y			; |
	+	STA.w !OAM+$000,x			;/
		LDA.w .Y,y				;\
		BIT $0F : BPL +				; | Hi plane ypos
		LDA.w .YSpecial,y			; |
	+	STA.w !OAM+$001,x			;/
		LDA.w .TilesRight,y			;\
		CLC : ADC $01				; | Hi plane tile number
		STA.w !OAM+$002,x			;/
		LDA $02					;\
		INC #2					; | Hi plane YXPPCCCT
		STA.w !OAM+$003,x			;/
		DEY					;\ Decrement loop count and loop
		BPL .Right				;/

.End		LDA #$AA				;\
		STA !OAM+$207				; | Set tile size
		STA !OAM+$208				;/
		PLB : RTS				; > Restore bank 0x40 and return


.OAM		db $68,$6C,$70,$74			; Lo
		db $78,$7C,$80,$84			; Hi

.XLeft		db $31,$41,$31,$41
.XRight		db $B1,$C1,$B1,$C1
.Y		db $17,$17,$27,$27
.TilesLeft	db $02,$00,$06,$04
.TilesRight	db $00,$02,$04,$06

.XSpecial	db $DC,$EC,$DC,$EC
.YSpecial	db $04,$04,$14,$14


;====================;
;UPDATE ARROW ROUTINE;
;====================;
UPDATE_ARROW:

		PHP

		LDA !MsgOptionRow
		CLC : ADC !MsgArrow
		ASL A
		TAX
		LDA.l DATA_05A580+0,x : STA $0E			;\ first half of header for arrow tile
		LDA.l DATA_05A580+1,x : STA $0F			;/

		LDA !MsgOptionRow
		ASL A
		TAX
		REP #$30
		LDA.l DATA_05A580,x : STA $02			; first half of header
		LDA #$00C0 : STA $04				; direction + RLE
		LDA !MsgOptions					;\
		AND #$00FF					; | length of string
		ASL A						; |
		XBA						; |
		TSB $04						;/

		LDA $7F837B : TAX				;\
		LDA $02 : STA $7F837D,x				; |
		LDA $04 : STA $7F837F,x				; | RLE string
		LDA !TextPal-1					; |
		ORA #$211F					; |
		STA $7F8381,X					;/

		LDA $0E : STA $7F8383,x				;\
		LDA #$0100 : STA $7F8385,x			; |
		LDA !TextPal-1					; | arrow tile
		AND #$FF00					; |
		ORA #$212E					; |
		STA $7F8387,x					;/
		LDA #$FFFF : STA $7F8389,x			; end upload
		TXA						;\
		CLC : ADC #$000C				; | update index
		STA $7F837B					;/

		PLP
		RTS



;=========================;
;CINEMATIC COMMAND ROUTINE;
;=========================;
CINEMATIC_COMMANDS:

;
; For cinematic mode:
;	FF	end
;	FE	end line
;	FD	next message, follow with !MsgTrigger input
;	FC	delay, follow with number of frames to wait
;	FB	wait for input
;	FA	portrait, follow with portrait index
;	F9	speed, follow with speed value
;	F8	clear
;	F7	music, follow with !SPC3 value
;

		CMP #$FF : BEQ .End
		CMP #$FE : BEQ .LineBreak
		CMP #$FB : BEQ .WaitForInput
		CMP #$F8 : BEQ .Clear
		INY					; Get ready to read next byte
		CMP #$FD : BEQ .NextMessage
		CMP #$FC : BEQ .Wait
		CMP #$FA : BEQ .Portrait
		CMP #$F9 : BEQ .Speed

.Music		LDA [$08],y : STA.l !SPC3
		BRA .R2B

.Speed		LDA [$08],y : STA !MsgSpeed
		BRA .R2B

.Portrait	LDA [$08],y : STA !MsgPortrait
		BRA .R2B

.WaitForInput	LDA #$01 : STA !MsgWaitFlag
		BRA .R2B_2

.Wait		LDA [$08],y : STA !MsgWait

		.R2B
		INC !MsgTileNumber : BNE ..2
		INC !MsgTileNumberHi
	..2	INC !MsgWaitScroll
		CLC
		RTS

.End		STA !MsgEnd
		CLC
		RTS

.LineBreak	LDA !MsgOffset
		AND #$1F
		EOR #$1F
		CLC : ADC !MsgOffset
		INC A
		STA !MsgOffset
		BEQ .Clear
		SEC
		RTS

.NextMessage	LDA [$08],y : STA.l !MsgTrigger
		STZ !MsgTileNumber
		STZ !MsgTileNumberHi
.Clear		JSL !GetVRAM
		PHP
		REP #$30
		LDY #$007E
		LDA #$391F
	-	STA !MsgCommandData+2,y
		DEY #2 : BPL -

		LDA #$5000 : STA $00

		LDY #$0003
	-	LDA.w #!MsgCommandData+2 : STA !VRAMtable+$02,x
		LDA #$4040 : STA !VRAMtable+$04,x
		LDA $00 : STA !VRAMtable+$05,x
		CLC : ADC #$0040
		STA $00

; somehow the act of emptying the box causes the next one to mess up...
; I don't know why this happens.

		LDA #$0080 : STA !VRAMtable+$00,x
		TXA
		CLC : ADC #$0007
		TAX
		DEY : BPL -

		LDA #$391F
		LDX #$003E
	-	STA.l $000020,x
		DEX #2 : BPL -

		PLP
		STZ !MsgOffset
		SEC
		RTS



;========================;
;COMMAND-HANDLING ROUTINE;
;========================;
HANDLE_COMMANDS:
		CMP #$1F : BEQ .Return
		PHA
		LDA !MultiPlayer : BEQ .1P		;\
		LDA.l $6DA3				; |
		ORA.l $6DA5				; | text goes at max speed if A/B is held
	.1P	ORA.l $6DA2				; |
		ORA.l $6DA4				; |
		CMP #$40 : BCS .Spd			;/

		LDA !MsgSpeed : STA !MsgDelay
	.Spd	LDA #$01 : STA.l !SPC1

		PLA
		CMP.b #((.End-.Ptr-2)/2)^$FF
		BCS +

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
		dw .Talk		; FD
		dw .P1Character		; FC, character number
		dw .P2Character		; FB, character number
		dw .NextMessage		; FA, message number
		dw .SubMessage		; F9, submessage number
		dw .Dialogue		; F8, option (lo 2 bits number of options-1, rest of bits destination)
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

		db $FF
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

.Talk		LDA #$01 : STA !MsgTalk			; > Set talk flag
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
		AND #$03
		STA !MsgOptions
		LDA [$08],y
		LSR #2
		INC A
		STA !MsgDestination
		LDA $02 : STA !MsgOptionRow
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

.InstantLine	LDA #$01 : STA !MsgSpeed
		LDA #$00 : XBA
		LDA $02 : TAX
		LDA.l .LineBreak_Lines,x
		INC A
		STA !MsgTileNumber
		TYA
		SEC : SBC $04
		TAY
		LDA $02
		ASL A
		TAX
		REP #$20
		LDA.l DATA_05A580,x				; first half of header
		PLX : PLX					; kill RTS and get stripe index
		STA $7F837D,x					; set first half of stripe image header
		LDA #$2300 : STA $7F837F,x			; second half of header
		SEP #$20
		LDA #$12 : STA $0F				; loop counter
		STZ $0E						; flag for line end
	-	LDA !MsgEnd : BNE ++
		LDA $0E : BNE ++
		LDA [$08],y
		CMP #$F2 : BEQ ++
		CMP #$F3 : BNE $02 : INC $0E			; set line end flag
		CMP #$FF : BNE +
		STA !MsgEnd
	++	LDA #$1F
	+	STA $7F8381,x
		LDA.w !TextPal
		ORA #$21
		STA $7F8382,x
		INX
		INX
		INY
		DEC $0F : BNE -
		LDA #$FF : STA $7F8381,x
		REP #$20
		PLA						; kill RTS
		TXA
		STA $7F837B					; set new index
		SEP #$30					; all registers 8 bit
		PLB
		RTL

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


SPRITE_TILES:

.Misc		incbin "Border.bin"			; GFX file to load border from



; Portraits are pretty straight-forward.
; Each portrait uses 4 bytes: a 24-bit pointer to GFX data, and an 8-bit index to palette pointers.
; Setting the second highest bit of the index X-flips the portrait and puts it on the left side of the message box.


.End

	print "In total this patch takes up ", freespaceuse, " (0x", hex(SPRITE_TILES_End-MESSAGE_ENGINE), ") bytes."
	print " "