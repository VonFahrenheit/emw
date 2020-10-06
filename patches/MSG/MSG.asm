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
;
; this patch uses the CCDMA work area as follows:
; $000-$1FF:	work space for rendering the line currently being worked on
; $200-$223:	work space for construcing the tilemap for the line currently being worked on
; $224-$225:	word to fill layer 3 tilemap with (0x32FC, which is an empty tile)
; $226-$227:	word to overwrite dialogue arrow with (0x0000)
; $228-$27F:	----
; $280-$28F:	cached 8x8 linear arrow GFX
; $290-$2FF:	----
; $300-$3FF:	backup of GFX overwritten by border
; $400-$7FF:	backup of GFX overwritten by portrait
; $C00-$FFF:	backup of layer 3 tilemap
;

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

	!MsgTileNumber		= !MsgRAM+$00		; 1 byte \ these two form a 16-bit index to the text data
	!MsgTileNumberHi	= !MsgRAM+$01		; 1 byte /
	!MsgOptions		= !MsgRAM+$02		; 1 byte
	!MsgArrow		= !MsgRAM+$03		; 1 byte
	!MsgOptionRow		= !MsgRAM+$04		; 1 byte, which row the dialogue options start on
	!MsgDestination		= !MsgRAM+$05		; 1 byte, determines what !MsgArrow writes to
	!MsgVertOffset		= !MsgRAM+$06		; 1 byte, number of pixels to move window down (doubled)
							;	  highest bit toggles portrait to top-right of screen
							;	  second highest bit disables border and window
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
	!MsgX			= !MsgRAM+$33		; 1 byte, X position to start drawing next character at
	!MsgRow			= !MsgRAM+$34		; 1 byte, current row of text
	!MsgCurrentArrow	= !MsgRAM+$35		; 1 byte, row of current arrow (used to replace it when it moves)
	!MsgWordLength		= !MsgRAM+$36		; 1 byte, accumulating word length
	!MsgCharCount		= !MsgRAM+$37		; 1 byte, accumulating characters
	!MsgCommandData		= !MsgRAM+$38		; Variable length, maximum of 200 bytes.
							; Used to upload text during cinematic mode








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
		LDX #$25				;\
		LDA #$02				; |
	-	STA !OAMhi,x				; | Set proper OAM size
		DEX					; |
		CPX #$03 : BNE -			;/
		LDA #$98 : STA !OAMindex		; > Set OAM index to after message tiles
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
		AND #$3F				; |
		ASL A					; | get window offset
		STA $00					; |
		STZ $01					;/
		LDA !MsgWaitScroll			;\
		REP #$20				; |
		AND #$00FF				; |
		SEC : SBC #$0010			; | Apply message scroll
		SEC : SBC $00				; > apply window offset
		STA $24					; |
		SEP #$20				; |
		CLC : ADC #$10				;/

		CMP !MsgWait : BNE .NoWipe
		JSR CLEAR_BOX



		.NoWipe
		PLB
		RTL

	+	LDA $16
		AND #$F0 : BNE +
		LDA $18
		AND #$C0 : BNE +
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
		STZ !MsgX
		STZ !MsgRow
		STZ !MsgOffset
		STZ !MsgOptions
		STZ !MsgArrow
		STZ !MsgOptionRow
		STZ !MsgDestination
		STZ !MsgScroll

.Return		PLB
		RTL

.WrongSize	JMP HANDLE_WINDOWING

.LoadMsg	LDA.l !MsgMode
		BEQ .NoClear
		JSL !KillOAM				; Clear OAM during message mode 1 and 2
		.NoClear

		LDA.l $400000+!MsgVertOffset		;\ don't draw border if it's disabled
		AND #$40 : BNE .NoBorder		;/
		JSR DRAW_BORDER				; > Draw sprite border
.NoBorder	LDA #$40				;\ Switch to bank 40
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

	;	LDA #$09				;\ Clear message box
	;	STA $12					;/

		JSR CLEAR_BOX


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
		AND #$3F				; |
		ASL A					; | get window offset
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
		STZ !MsgX
		STZ !MsgRow
		STZ !MsgOffset

	-
		PLB
		RTL

	+++	STZ $6109
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
		LDA.b #.SA1 : STA $3180			;\
		LDA.b #.SA1>>8 : STA $3181		; | Have SA-1 clear out RAM (but not VRAM/backups)
		LDA.b #.SA1>>16 : STA $3182		; |
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

		SEP #$30
		JSL !GetVRAM
		LDA.b #!GFX_buffer>>16				;\
		STA !VRAMtable+$04,x				; |
		STA !VRAMtable+$0B,x				; |
		STA !VRAMtable+$12,x				; |
		STA !VRAMtable+$19,x				; |
		STA !VRAMtable+$20,x				; |
		STA !VRAMtable+$27,x				; |
		REP #$20					; |
		LDA.w #!GFX_buffer+$300 : STA !VRAMtable+$02,x	; |
		LDA.w #!GFX_buffer+$380 : STA !VRAMtable+$09,x	; |
		LDA.w #!GFX_buffer+$400 : STA !VRAMtable+$10,x	; |
		LDA.w #!GFX_buffer+$500 : STA !VRAMtable+$17,x	; |
		LDA.w #!GFX_buffer+$600 : STA !VRAMtable+$1E,x	; |
		LDA.w #!GFX_buffer+$700 : STA !VRAMtable+$25,x	; |
		LDA !MsgVRAM3 : STA !VRAMtable+$05,x		; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$0C,x				; | restore GFX overwritten by border and portrait
		LDA !MsgVRAM1 : STA !VRAMtable+$13,x		; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$1A,x				; |
		LDA !MsgVRAM2 : STA !VRAMtable+$21,x		; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$28,x				; |
		LDA #$0080					; |
		STA !VRAMtable+$00,x				; |
		STA !VRAMtable+$07,x				; |
		LDA #$0100					; |
		STA !VRAMtable+$0E,x				; |
		STA !VRAMtable+$15,x				; |
		STA !VRAMtable+$1C,x				; |
		STA !VRAMtable+$23,x				;/
		LDA.l !2109						;\
		AND #$00FC						; |
		XBA							; |
		ORA #$00C0						; | restore layer 3 tilemap
		STA !VRAMtable+$2F,x					; |
		LDA.w #!GFX_buffer+$C00 : STA !VRAMtable+$2C,x		; |
		LDA.w #!GFX_buffer+$C00>>8 : STA !VRAMtable+$2D,x	; |
		LDA #$0400 : STA !VRAMtable+$2A,x			;/

		PHK : PLB
		LDA #$F0F0				;\
		STA !OAM+$91 : STA !OAM+$11		; |
		STA !OAM+$95 : STA !OAM+$15		; |
		STA !OAM+$89 : STA !OAM+$19		; |
		STA !OAM+$8D : STA !OAM+$1D		; |
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
		PLB
		PLP
		RTL


		.NextMessage
		LDA #$01 : STA !MsgScroll
		STZ $16
		STZ $18
		STZ !MsgTileNumber
		STZ !MsgTileNumberHi
		STZ !MsgX
		STZ !MsgRow
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

CLEAR_BOX:
; wipe message box
		PHP
		SEP #$30
		JSL !GetVRAM
		REP #$20
		LDA #$38FC : STA.w !GFX_buffer+$224
		LDA.w #!GFX_buffer+$224 : STA !VRAMtable+$02,x
		LDA.w #!GFX_buffer+$224>>8 : STA !VRAMtable+$03,x
		LDA #$50C0 : STA !VRAMtable+$05,x
		LDA #$4400 : STA !VRAMtable+$00,x
		PLP
		RTS


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
	..Dec	;JSR CINEMATIC_COMMANDS_Clear		; |
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


	; upload border GFX
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

		LDA.b #!GFX_buffer>>16				;\
		STA !VRAMtable+$04,x				; |
		STA !VRAMtable+$0B,x				; |
		STA !VRAMtable+$12,x				; |
		STA !VRAMtable+$19,x				; |
		STA !VRAMtable+$20,x				; |
		STA !VRAMtable+$27,x				; |
		REP #$20					; |
		LDA.w #!GFX_buffer+$300 : STA !VRAMtable+$02,x	; |
		LDA.w #!GFX_buffer+$380 : STA !VRAMtable+$09,x	; |
		LDA.w #!GFX_buffer+$400 : STA !VRAMtable+$10,x	; |
		LDA.w #!GFX_buffer+$500 : STA !VRAMtable+$17,x	; |
		LDA.w #!GFX_buffer+$600 : STA !VRAMtable+$1E,x	; |
		LDA.w #!GFX_buffer+$700 : STA !VRAMtable+$25,x	; |
		LDA !MsgVRAM3					; |
		ORA #$8000					; |
		STA !VRAMtable+$05,x				; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$0C,x				; | backup GFX that will be overwritten by border and portrait
		LDA !MsgVRAM1					; |
		ORA #$8000					; |
		STA !VRAMtable+$13,x				; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$1A,x				; |
		LDA !MsgVRAM2					; |
		ORA #$8000					; |
		STA !VRAMtable+$21,x				; |
		CLC : ADC #$0100				; |
		STA !VRAMtable+$28,x				; |
		LDA #$0080					; |
		STA !VRAMtable+$00,x				; |
		STA !VRAMtable+$07,x				; |
		LDA #$0100					; |
		STA !VRAMtable+$0E,x				; |
		STA !VRAMtable+$15,x				; |
		STA !VRAMtable+$1C,x				; |
		STA !VRAMtable+$23,x				;/

		SEP #$20				; adjust index
		TXA
		CLC : ADC #$2A
		TAX

		LDA.b #GFX>>16				;\
		STA !VRAMtable+$04,x			; | bank
		STA !VRAMtable+$0B,x			;/
		REP #$20				; > A 16 bit
		LDA #$0080				;\
		STA !VRAMtable+$00,x			; | size
		STA !VRAMtable+$07,x			;/
		LDA #GFX_Misc				;\
		STA !VRAMtable+$02,x			; | source
		CLC : ADC #$00A0			; |
		STA !VRAMtable+$09,x			;/
		LDA !MsgVRAM3				;\
		STA !VRAMtable+$05,x			; | VRAM
		CLC : ADC #$0100			; |
		STA !VRAMtable+$0C,x			;/

		LDA.l !2109						;\
		AND #$00FC						; |
		XBA							; |
		ORA #$80C0						; | backup layer 3 tilemap
		STA !VRAMtable+$13,x					; |
		LDA.w #!GFX_buffer+$C00 : STA !VRAMtable+$10,x		; |
		LDA.w #!GFX_buffer+$C00>>8 : STA !VRAMtable+$11,x	; |
		LDA #$0400 : STA !VRAMtable+$0E,x			;/


		LDX #$4F*2						;\
		LDA.l GFX_FontData+0,x					; |
		AND #$000F						; |
		ASL A							; |
		STA $00							; | get index to dialogue arrow GFX
		LDA.l GFX_FontData+0,x					; |
		AND #$00F0						; |
		ASL #4							; |
		TSB $00							; |
		REP #$10						; |
		LDX $00							;/
		LDA.w !ImageCache+$000,x : STA.w !GFX_buffer+$280	;\
		LDA.w !ImageCache+$020,x : STA.w !GFX_buffer+$282	; |
		LDA.w !ImageCache+$040,x : STA.w !GFX_buffer+$284	; |
		LDA.w !ImageCache+$060,x : STA.w !GFX_buffer+$286	; |
		LDA.w !ImageCache+$080,x : STA.w !GFX_buffer+$288	; | cache arrow GFX in 8px wide format
		LDA.w !ImageCache+$0A0,x : STA.w !GFX_buffer+$28A	; |
		LDA.w !ImageCache+$0C0,x : STA.w !GFX_buffer+$28C	; |
		LDA.w !ImageCache+$0E0,x : STA.w !GFX_buffer+$28E	; |
		SEP #$10						;/




		PLB					;\ Pull stuff
		LDX #$22 : STX !SPC4			; > Play message box sound
		PLP					;/
		PLA					; > Pull window size




.SkipINIT	CLC : ADC.w DATA_05B10A,y
		STA $7B89
		CLC : ADC #$80
		XBA
		LDA.l $400000+!MsgVertOffset
		AND #$3F
		ASL #2
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
		LDA.l $400000+!MsgVertOffset		;\ don't enable HDMA if window is disabled
		AND #$40 : BNE .NoWindow		;/
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
		DEX : BPL -				;/
		STZ $4327				; > Indirect HDMA bank


		LDA #$1F				;\
		STA !MainScreen				; | Everything on main screen
		STZ !SubScreen				;/
		LDA #$04				;\ Enable HDMA on channel 2
		TSB !HDMA				;/
		PLB
		RTL

.NoWindow	LDA #$04 : TRB !HDMA
		LDA #$04 : STA !MainScreen
		LDA #$1B : STA !SubScreen
		PLB
		RTL


		.Wipe
		STZ !MsgTileNumber			;\
		STZ !MsgTileNumberHi			; |
		STZ !MsgX				; |
		STZ !MsgRow				; |
		STZ !MsgOffset				; | Make sure the counters don't mess up
		STZ !MsgScroll				; |
		STZ !MsgDelay				; |
		STZ !MsgWaitScroll			;/
		RTS


DATA_05B106:	db !MaxSize-!GrowSpeed,!MaxSize		; Determines when to write to OAM.
DATA_05B108:	db !MaxSize,!MinSize			; Maximum/minimum values for window size. Minimum should be 00.
DATA_05B10A:	db !GrowSpeed,!ShrinkSpeed		; Message box growing/shrinking speed.


;============;
;APPLY HEADER;
;============;
ApplyHeader:	PHP
		PHB : PHK : PLB
		SEP #$20
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLB
		PLP


.Main		PHY					; > Preserve Y
		REP #$10				; > Index 16 bit
		LDA.l $000000+!MsgTrigger		;
		AND #$00FF				;
		DEC A					;
		STA $00					;
		PHB : PHK : PLB				;\
		LDA $73BF				; |
		AND #$00FF				; |
		ASL A					; | Get ExMessage header location
		TAX					; |
		LDA ExMessage_MainPtr,x			; |
		STA $0E					; |
		LDA $00					; |
		ASL A					; |
		TAY					; |
		LDA ($0E),y				; |
		PLB					;/
		STA $00					;\
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



		.SA1
		PHP					;\
		PHB : PHK : PLB				; |
		REP #$30				; |
		LDX #$07FE				; |
	-	LDA.w GFX_Font,x : STA.l !ImageCache,x	; | copy font to image cache
		DEX #2 : BPL -				; |
		PLB					; |
		PLP					; |
		RTL					;/




; this should be run by SA-1
; actually, it HAS to be run by SA-1

;======================;
;TEXT UPLOADING ROUTINE;
;======================;
UPLOAD_TEXT:	PHB : PHK : PLB
		PHP
		SEP #$20
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLP
		PLB
		RTS


.SA1		PHB
		PHP
		SEP #$20
		LDA #$40
		PHA : PLB
		LDA !MsgRow : PHA
		STZ !MsgWordLength			; treat each render as the start of a new word
		STZ !MsgCharCount			; number of characters rendered on this frame
		JSR .Main
		SEP #$20
		LDA !MsgSpeed				;\
		CMP #$08 : BCC .NoDelay			; |
		SBC #$08				; | delay on these speeds
		STA !MsgDelay				; |
		.NoDelay				;/
		PLA : STA $00
		REP #$20
		LDA $00
		AND #$00FF
		ASL #2
		TAX
		LDA.l .TilemapData,x : STA $0E		; VRAM address in $0E
		LDA !TextPal-1				;\
		AND #$FF00				; | palette
		STA $0C					;/
		LDA.l .TilemapData+2,x			;\
		ORA $0C					; |
		LDX #$0000				; |
	-	STA.l !GFX_buffer+$200,x		; | build tilemap
		INC A					; |
		INX #2					; |
		CPX #$0024 : BCC -			;/
		SEP #$30
		JSL !GetVRAM
		REP #$20
		LDA.w #!GFX_buffer+$200 : STA !VRAMtable+$02,x
		LDA.w #!GFX_buffer+$200>>8 : STA !VRAMtable+$03,x
		LDA.w #$0024 : STA !VRAMtable+$00,x
		LDA $0E : STA !VRAMtable+$05,x
		PLP
		PLB
		RTL


.Main		REP #$30
		LDA.l !MsgTrigger			;\
		AND #$00FF				; | store message trigger
		DEC A					; |
		STA $00					;/

	.Ex	PHB : PHK : PLB				;\
		LDA !Translevel				; |
		AND #$00FF				; | main ExMessage pointer
		ASL A					; |
		TAX					; |
		LDA.w ExMessage_MainPtr,x : STA $0E	;/
		TYX					;\
		LDA $00					; |
		ASL A					; |
		TAY					; | 16-bit header pointer in $00
		PHK : PHK				; | 24-bit text pointer in $08
		PLA : STA $09				; |
		LDA ($0E),y : STA $00			; |
		CLC : ADC #$0004			; |
		STA $08					;/
		LDY #$0002				;\
		LDA ($00),y				; |
		AND #$00FF : BEQ ..NoDialogue		; | header is 2 bytes longer if dialogue is used
		INC $08					; |
		INC $08					; |
		..NoDialogue				;/
		STZ $00					;\
		TXY					; | clear header pointer, restore Y + bank
		PLB					;/

	.Process
		REP #$20
		LDY !MsgTileNumber
		INC !MsgTileNumber
		SEP #$20

		LDA !MsgWordLength : BNE .Ok		; if we're already processing a word, keep rendering it
		XBA					; clear B
		PHY
	-	LDA [$08],y
		INY
		CMP #$FF : BEQ ++			;\
		CMP #$FE : BEQ ++			; | 7F, FE, FF all end a word
		CMP #$7F : BEQ ++			;/
		BCS +					; skip this one if command
		ASL A
		TAX
		LDA.l GFX_FontData+1,x
		AND #$0F
		SEC : ADC !MsgWordLength		; add +1 epic style
		STA !MsgWordLength
	+	BRA -

	++	PLY
		LDA !MsgWordLength
		CLC : ADC !MsgX
		CMP #$90 : BCC .Ok			; if word doesn't fit, it has to go on the next row
		INC !MsgRow
		STZ !MsgX
		REP #$20
		DEC !MsgTileNumber
		RTS

	.Ok	LDA [$08],y : BPL ..Text		; 00-7F is text, 80-FF are command headers

	..Command
		CMP #$FE : BCS ..Done			; FE and FF always terminate the current render
		PEA .Continue-1
	..Done	JMP HANDLE_COMMANDS

	..Text	INC !MsgCharCount			; 1 more character rendered
		REP #$20				;\
		AND #$00FF				; | check for space
		CMP #$007F : BNE +			;/
		SEP #$20				;\
		STZ !MsgWordLength			; > new word
		LDA !MsgX : BNE ++			; |
		JSR RENDER_TEXT_Clear			; | special case when line starts with a space
		SEP #$20				; |
		LDA #$06 : STA !MsgX			; |
		LDA !MsgSpeed : BNE .Return		; > end at new word unless full line
		JMP .Process				;/

	++	CLC : ADC #$06				; | increase X
		CMP #$90				; |
		STA !MsgX				;/
		BCS ++
		LDA !MsgSpeed : BNE .Return		; end at new word unless rendering full line
		JMP .Process				; if we didn't hit a new row, just get next character
	++	INC !MsgRow				;\
		STZ !MsgX				; | new row from space
		LDA !MsgSpeed : BNE .Return		; > end at new word unless rendering full line
		JMP .Process				;/

	+	ASL A
		TAX
		LDA.l GFX_FontData+0,x			;\
		AND #$000F				; |
		ASL #3					; |
		STA $00					; |
		LDA.l GFX_FontData+0,x			; | index to cached font
		AND #$0070				; |
		XBA					; |
		LSR #2					; |
		TSB $00					;/
		LDA.l GFX_FontData+1,x			;\
		AND #$000F				; | width of character
		INC A					; |
		STA $04					;/

		STZ $0E					;\ cinematic width = 255px (no, not 256)
		DEC $0E					;/
		LDA !MsgCinematic
		AND #$00FF : BNE +
		LDA #$0090 : STA $0E			; normal width = 144px
	+	SEP #$20
		STZ $03					; hi byte of X coordinate
		LDA !MsgX
		CLC : ADC $04
		CMP $0E : BCC .Go


	..New	INC !MsgRow				; | start new row
		STZ !MsgX				;/
	.Return	RTS					; starting a new row always ends the transfer

	.Go	LDA !MsgX : STA $02
		CLC : ADC $04
		STA !MsgX

		SEP #$20
		JSR RENDER_TEXT				;/

		.Continue
		SEP #$20
		LDA !MsgSpeed
		CMP #$02 : BCC .Next
		CMP #$08 : BCS .Return

		SEC : SBC #$09
		EOR #$FF : INC A
		CMP !MsgCharCount
		BEQ .Return
		BCC .Return


	.Next	JMP .Process


; speeds:
; 0 - 1 row per frame
; 1 - 1 word per frame
; 2 - 7 characters per frame
; 3 - 6 characters per frame
; 4 - 5 characters per frame
; 5 - 4 characters per frame
; 6 - 3 characters per frame
; 7 - 2 characters per frame
; 8 - 1 character per frame
; 9 - 1 character every 2 frames
; A - 1 character every 3 frames
; B - 1 character every 4 frames
; C - 1 character every 5 frames
; D - 1 character every 6 frames
; E - 1 character every 7 frames
; F - 1 character every 8 frames

; full row:
;	- get full row input, until hitting end or FE or FF
;	- only process GFX update once
;
; full word:
;	- get input until hitting space, end, FE or FF
;	- only process GFX update once
;
; multi-character:
;	- get input until hitting limit, end, FE or FF
;	- only process GFX update once
;
; single-character:
;	- get input for single character
;	- only process GFX update once
;	- set !MsgDelay to !MsgSpeed - 8



.TilemapData
; format: starting VRAM, starting tile (table generated into !GFX_buffer+$800)
dw $50C7,$0014	; row 0
dw $50E7,$0026	; row 1
dw $5107,$0038	; row 2
dw $5127,$004A	; row 3
dw $5147,$005C	; row 4
dw $5167,$006E	; row 5
dw $5187,$0080	; row 6
dw $51A7,$0092	; row 7
dw $51C7,$00A4	; row 8
dw $51E7,$00B6	; row 9
dw $5207,$00C8	; row A
dw $5227,$00DA	; row B
dw $5247,$00EC	; row C
dw $5267,$00FE	; row D
dw $5287,$0110	; row E
dw $52A7,$0122	; row F







macro copypixel(x, y)
	LDA.w !V_cache*2+<x>+(<y>*128),y
	BNE $02 : LDA $06
	STA.w !V_buffer*2+<x>+(<y>*256),x
endmacro

; input:
; $00 - 16-bit image cache index (font is expected to be stored at the start of the image cache)
; $02 - x position to start writing at
; $04 - width of font tile
; $06 - filler value, written to empty pixels
;
; note that the input GFX is assumed to be a 128x64px linear 2bpp file
; output is a 256x8px linear 2bpp image, uploaded using CCDMA
; this routine can only be run by SA-1 CPU
RENDER_TEXT:
		PHB					; push bank
		PHK : PLB
		LDA $02 : BNE $03 : JSR .Clear		; clear buffer if we're starting at 0
		REP #$20
		LDA $00					;\
		CLC : ADC $04				; | index to end on
		STA $04					;/
		LDY $00					; Y = input index
		LDX $02					; X = output index
		SEP #$20				; 8-bit A
		LDA #$80 : STA $223F			; 2bpp
		LDA #$60 : PHA : PLB			; bank = $60

	-	%copypixel($00, $00)			;\
		%copypixel($00, $01)			; |
		%copypixel($00, $02)			; |
		%copypixel($00, $03)			; | copy a column
		%copypixel($00, $04)			; | (empty pixels use filler color)
		%copypixel($00, $05)			; |
		%copypixel($00, $06)			; |
		%copypixel($00, $07)			;/

		INX					;\
		INY					; | increment index and check for end of tile
		CPY $04 : BCC -				;/

		PHK : PLB				; generic bank
		STZ $2250				; prepare multiplication
		LDA #$01 : STA $317F			; 1 CCDMA upload
		LDA #$16 : STA $3190			; width = 256px, bit depth = 2bpp
		LDA.b #!GFX_buffer>>16 : STA $3195	;\
		REP #$20				; | source address = !GFX_buffer
		LDA.w #!GFX_buffer : STA $3193		;/
		LDA #$0200 : STA $3196			; 512 bytes
		LDA $400000+!MsgRow : STA $2251		;\
		LDA #$0012*8 : STA $2253		; |
		LDA !210C				; |
		AND #$000F				; | VRAM address = layer 3 GFX address + row * $12 * $8 + $14
		XBA					; |
		ASL #4					; |
		ORA $2306				; |
		CLC : ADC.w #$0014*8			; |
		STA $3191				;/

		PLB					; restore bank
		RTS


		.Clear
		PHB					;\
		LDA.b #!GFX_buffer>>16			; |
		PHA : PLB				; |
		REP #$20				; |
		LDX #$01FE				; | clear render buffer
	-	STZ.w !GFX_buffer,x			; |
		DEX #2 : BPL -				; |
		PLB					; |
		RTS					;/



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
		LDX #$00				; tilemap index
		LDY #$10				; OAM index
		LDA.l $400000+!MsgVertOffset		;\
		AND #$3F				; | Y offset
		ASL A					; |
		STA $00					;/
		REP #$20				; 16-bit A
		LDA.l $400000+!MsgVRAM3			;\
		LSR #4					; | tile offset
		SEP #$20				; |
		STA $01					;/
	-	LDA.w .TileMap+0,x : STA.w !OAM+0,y
		LDA.w .TileMap+1,x
		CLC : ADC $00
		STA.w !OAM+1,y
		LDA.w .TileMap+2,x
		CLC : ADC $01
		STA !OAM+2,y
		LDA.w .TileMap+3,x : STA !OAM+3,y
		INY #4
		INX #4
		CPX.b #.End-.TileMap : BNE -

		REP #$20
		LDA #$AAAA				;\
		STA.w !OAM+$200				; |
		STA.w !OAM+$202				; | Set tilesize to 16x16
		STA.w !OAM+$204				; |
		STA.w !OAM+$206				;/
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
		STA !OAM+$208				; |
		STA !OAM+$209				;/
		PLB : RTS				; > Restore bank 0x40 and return


.OAM		db $78,$7C,$80,$84			; Lo
		db $88,$8C,$90,$94			; Hi

.XLeft		db $31,$41,$31,$41
.XRight		db $B1,$C1,$B1,$C1
.Y		db $17,$17,$27,$27
.TilesLeft	db $02,$00,$06,$04
.TilesRight	db $00,$02,$04,$06

.XSpecial	db $B8,$C8,$B8,$C8
.YSpecial	db $10,$10,$20,$20


;====================;
;UPDATE ARROW ROUTINE;
;====================;
UPDATE_ARROW:	PHP
		PHB : PHK : PLB
		SEP #$30
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		PLB
		PLP
		RTS


.SA1		PHP
		PHB : PHK : PLB				; generic bank
		SEP #$30
		STZ $2250				; prepare multiplication
		LDA $400000+!MsgOptionRow
		CLC : ADC $400000+!MsgArrow
		STA $2251
		STZ $2252
		LDA #$01 : STA $317F			; 1 CCDMA upload
		LDA #$02 : STA $3190			; width = 8px, bit depth = 2bpp
		LDA.b #!GFX_buffer>>16 : STA $3195	;\
		REP #$20				; | source address = !GFX_buffer+$280 (cached dialogue arrow)
		LDA.w #!GFX_buffer+$280 : STA $3193	;/
		LDA #$0010 : STA $3196			; 16 bytes
		LDA #$0012*8 : STA $2253		;\
		LDA !210C				; |
		AND #$000F				; | VRAM address = layer 3 GFX address + row * $12 * $8 + $15*8
		XBA					; |
		ASL #4					; |
		ORA $2306				; |
		CLC : ADC.w #$0015*8			; |
		STA $3191				;/

		LDX #$40
		PHX : PLB

		LDA !MsgOptionRow
		CLC : ADC !MsgArrow
		CMP !MsgCurrentArrow : BEQ .Return
		LDA !MsgCurrentArrow : BEQ .Return

	; if arrow has moved, erase the previous one

		PHP
		SEP #$20
		JSL !GetVRAM
		PLP
		LDA #$0000 : STA.w !GFX_buffer+$226
		LDA !MsgCurrentArrow
		AND #$00FF
		STA.l $2251
		LDA #$0012*8 : STA.l $2253
		LDA.l !210C
		AND #$000F
		XBA
		ASL #4
		ORA.l $2306
		CLC : ADC.w #$0015*8
		STA !VRAMtable+$05,x
		LDA.w #!GFX_buffer+$226 : STA !VRAMtable+$02,x
		LDA.w #!GFX_buffer+$226>>8 : STA !VRAMtable+$03,x
		LDA #$4010 : STA !VRAMtable+$00,x
		SEP #$20
	.Return	LDA !MsgOptionRow
		CLC : ADC !MsgArrow
		STA !MsgCurrentArrow


		PLB
		PLP
		RTL





;========================;
;COMMAND-HANDLING ROUTINE;
;========================;
HANDLE_COMMANDS:
		CMP #$D0 : BCC .Return			; 80-CF are currently unused
		CMP #$E0 : BCC .Talk
		CMP #$F0 : BCC .Speed

		AND #$0F
		ASL A
		XBA
		LDA #$00
		XBA
		TAX
		PEA.w .Return-1
		JMP (.Ptr,x)

	.Talk	AND #$0F
		STA !MsgTalk
		BRA .Return

	.Speed	AND #$0F
		STA !MsgSpeed

	.Unused
	.Return	RTS


; commands:
; DX - talk (X is talk flag value)
; EX - speed (X is speed value)
; F0 - unused
; F1 - unused
; F2 - instant line
; F3,XX - music, !SPC3 value
; F4,XX - portrait, value
; F5,XX - auto scroll, rows to scroll
; F6,XX - wait for input, rows to scroll
; F7,XX - delay, frame count
; F8,XX - dialogue, parameters (lo 2 bits = number of options-1, rest is destination/type)
; F9,XX - submessage, submessage number
; FA,XX - next message, message number
; FB,XX - player 1 character, character number
; FC,XX - player 2 character, character number
; FD - unused
; FE - line break
; FF - end of message
.Ptr		dw .Unused		; F0
		dw .Unused		; F1
		dw .InstantLine		; F2
		dw .Music		; F3,XX
		dw .Portrait		; F4,XX
		dw .AutoScroll		; F5,XX
		dw .WaitForInput	; F6,XX
		dw .Delay		; F7,XX
		dw .Dialogue		; F8,XX
		dw .Sub			; F9,XX
		dw .Next		; FA,XX
		dw .P1Char		; FB,XX
		dw .P2Char		; FC,XX
		dw .Unused		; FD
		dw .LineBreak		; FE
		dw .End			; FF


.InstantLine	RTS

.Music		INY
		LDA [$08],y : STA.l !SPC3
		INY
		STY !MsgTileNumber
		RTS

.Portrait	INY
		LDA [$08],y : STA !MsgPortrait
		INY
		STY !MsgTileNumber
		RTS

.AutoScroll	INY
		LDA [$08],y
		ASL #3
		STA !MsgWait
		INC !MsgWaitFlag
		INY
		STY !MsgTileNumber
		RTS

.WaitForInput	INY
		LDA [$08],y
		ASL #3
		STA !MsgWait
		INY
		STY !MsgTileNumber
		RTS

.Delay		INY
		LDA [$08],y : STA !MsgDelay
		INY
		STY !MsgTileNumber
		RTS

.Dialogue	INY
		LDA [$08],y
		AND #$03
		STA !MsgOptions
		LDA [$08],y
		LSR #2
		INC A
		STA !MsgDestination
		LDA !MsgRow : STA !MsgOptionRow
		STZ !MsgArrow
		INY
		STY !MsgTileNumber
		RTS

.Sub		INY
		LDA [$08],y : STA !SubMsg
		STZ !SubMsgTileNumber
		INY
		STY !MsgTileNumber
		BRA .LineBreak

.Next		LDA !MsgCounter
		TAX
		INY
		LDA [$08],y : STA !MsgSequence,x
		INC !MsgCounter
		INY
		STY !MsgTileNumber
		RTS

.P1Char		INY
		LDA [$08],y
		ASL #4
		STA $0F
		LDA !Characters
		AND #$0F
		ORA $0F
		STA !Characters
		INY
		STY !MsgTileNumber
		RTS

.P2Char		INY
		LDA [$08],y
		AND #$0F
		STA $0F
		LDA !Characters
		AND #$F0
		ORA $0F
		STA !Characters
		INY
		STY !MsgTileNumber
		RTS

.LineBreak	STZ !MsgX
		INC !MsgRow
		RTS

.End		LDA #$01 : STA !MsgEnd
		RTS







cleartable
table "MessageTable.txt"

incsrc "ExMessages.asm"


GFX:

.Misc		incbin "Border.bin"			; GFX file to load border from


; each character needs:
; - tile number (7 bits)
; - width (4 bits)
;
; for table order, see MessageTable.txt
;
; the font GFX is 128px wide, whereas the output width is 256px


; text format is pretty simple
; any value 00-4F will index the table below
; 50-7E are reserved for future expansion
; 7F is a space, which simply skips ahead and doesn't actually have any GFX associated with it
; 80-FF are commands without associated GFX, many of these are more than 1 byte long
; FF will end the message


macro Char(number, width)
	db <number>
	db <width>
endmacro


.FontData	%Char($00, 7)	; A
		%Char($01, 7)	; B
		%Char($02, 7)	; C
		%Char($03, 7)	; D
		%Char($04, 7)	; E
		%Char($05, 7)	; F
		%Char($06, 7)	; G
		%Char($07, 7)	; H
		%Char($08, 7)	; I
		%Char($09, 7)	; J
		%Char($0A, 7)	; K
		%Char($0B, 7)	; L
		%Char($0C, 7)	; M
		%Char($0D, 7)	; N
		%Char($0E, 7)	; O
		%Char($0F, 7)	; P
		%Char($10, 7)	; Q
		%Char($11, 7)	; R
		%Char($12, 7)	; S
		%Char($13, 7)	; T
		%Char($14, 7)	; U
		%Char($15, 7)	; V
		%Char($16, 7)	; W
		%Char($17, 7)	; X
		%Char($18, 7)	; Y
		%Char($19, 7)	; Z
		%Char($1A, 7)	; .
		%Char($1B, 7)	; ,
		%Char($1C, 7)	; !
		%Char($1D, 7)	; ?
		%Char($1E, 7)	; :
		%Char($1F, 7)	; ;
		%Char($20, 7)	; a
		%Char($21, 7)	; b
		%Char($22, 7)	; c
		%Char($23, 7)	; d
		%Char($24, 7)	; e
		%Char($25, 7)	; f
		%Char($26, 7)	; g
		%Char($27, 7)	; h
		%Char($28, 7)	; i
		%Char($29, 7)	; j
		%Char($2A, 7)	; k
		%Char($2B, 7)	; l
		%Char($2C, 7)	; m
		%Char($2D, 7)	; n
		%Char($2E, 7)	; o
		%Char($2F, 7)	; p
		%Char($30, 7)	; q
		%Char($31, 7)	; r
		%Char($32, 7)	; s
		%Char($33, 7)	; t
		%Char($34, 7)	; u
		%Char($35, 7)	; v
		%Char($36, 7)	; w
		%Char($37, 7)	; x
		%Char($38, 7)	; y
		%Char($39, 7)	; z
		%Char($3A, 7)	; +
		%Char($3B, 7)	; -
		%Char($3C, 7)	; *
		%Char($3D, 7)	; /
		%Char($3E, 7)	; \
		%Char($3F, 7)	; =
		%Char($40, 7)	; 0
		%Char($41, 7)	; 1
		%Char($42, 7)	; 2
		%Char($43, 7)	; 3
		%Char($44, 7)	; 4
		%Char($45, 7)	; 5
		%Char($46, 7)	; 6
		%Char($47, 7)	; 7
		%Char($48, 7)	; 8
		%Char($49, 7)	; 9
		%Char($4A, 7)	; (
		%Char($4B, 7)	; )
		%Char($4C, 7)	; #
		%Char($4D, 7)	; $
		%Char($4E, 7)	; %
		%Char($4F, 7)	; > (cursor symbol)


.Font		incbin "Font.bin"			; GFX file to load font from (linearly formatted)


; Portraits are pretty straight-forward.
; Each portrait uses 4 bytes: a 24-bit pointer to GFX data, and an 8-bit index to palette pointers.
; Setting the second highest bit of the index X-flips the portrait and puts it on the left side of the message box.


.End

	print "In total this patch takes up ", freespaceuse, " (0x", hex(GFX_End-MESSAGE_ENGINE), ") bytes."
	print " "