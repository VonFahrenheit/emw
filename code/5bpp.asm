;=======================;
;PLANE-SPLITTING ROUTINE;
;=======================;
;
;	This routine will decompress an 8bpp GFX file into two 4bpp GFX files and upload them to VRAM.
;	By overlapping tiles from the two files you can simulate 5bpp sprites.
;	To use it, store the following in $00-$03:
;
;	$3000:		24-bit pointer to graphics file
;	$3003:		8-bit number of 8x8 tiles


; Source GFX:
;  P1   P2   P1   P2   P1   P2   P1   P2
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 00-07
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 08-0F
;  P3   P4   P3   P4   P3   P4   P3   P4
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 10-17
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 18-1F
;  P5   P6   P5   P6   P5   P6   P5   P6
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 20-27
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 28-2F
;  P7   P8   P7   P8   P7   P8   P7   P8
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 30-37
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 38-3F

; Split GFX lo:
;  P1   P2   P1   P2   P1   P2   P1   P2
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 00-07
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 08-0F
;  P3   P4   P3   P4   P3   P4   P3   P4
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 10-17
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 18-1F

; Split GFX hi:
;  P1   P2   P1   P2   P1   P2   P1   P2
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 00-07
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 08-0F
;  P3   P4   P3   P4   P3   P4   P3   P4
; [Y0],[Y0],[Y1],[Y1],[Y2],[Y2],[Y3],[Y3]		; 10-17
; [Y4],[Y4],[Y5],[Y5],[Y6],[Y6],[Y7],[Y7]		; 18-1F


; --Manual--
; X = pixel
; Y = row * 2
; $00-$07: depth data (static)
; $08-$0B: data for !BufferLo
; $0C-$0F: data for !BufferHi


macro SplitPixel(offset)
		LDA [!GraphicsLoc],y
		INY
		CMP #$10 : BCC ?LoPlane
	?HiPlane:
		AND #$0F
		STA.w (!BufferHi*2)+<offset>,x
		STZ.w (!BufferLo*2)+<offset>,x
		BRA ?Next
	?LoPlane:
		STA.w (!BufferLo*2)+<offset>,x
		STZ.w (!BufferHi*2)+<offset>,x
		?Next:
endmacro


PLANE_SPLIT:

	%TrackSetup(!TrackPlaneSplit)
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182

	if !TrackCPU == 0
		JMP $1E80
	else
		JSR $1E80
		%TrackCPU(!TrackPlaneSplit)
		RTS
	endif

.SA1
		PHB
		PHP
		SEP #$20
		STZ $223F
		LDA #$60
		PHA : PLB
		REP #$30
		LDA !GraphicsSize
		AND #$00FF
		XBA
		LSR #2
		STA $0E
		SEP #$20
		LDX #$0000
		LDY #$0000
	.Loop	%SplitPixel($00)			; bulk split within each loop for faster performance
		%SplitPixel($01)			; this cuts the number of loops in 16
		%SplitPixel($02)			; arbitrary width encoding is still supported, but chunking is not
		%SplitPixel($03)			;
		%SplitPixel($04)			; Y is incremented automatically with each read
		%SplitPixel($05)			; X in added in bulk at the end of each loop
		%SplitPixel($06)
		%SplitPixel($07)
		%SplitPixel($08)
		%SplitPixel($09)
		%SplitPixel($0A)
		%SplitPixel($0B)
		%SplitPixel($0C)
		%SplitPixel($0D)
		%SplitPixel($0E)
		%SplitPixel($0F)
		REP #$20
		TXA
		CLC : ADC #$0010
		CMP #$0100 : BEQ .200			;\
		CMP #$0200 : BEQ .300			; |
		CMP #$0300 : BNE +			; | order: 000 block, 200 block, 100 block, 300 block
	.100	LDA #$0100 : BRA +			; |
	.200	LDA #$0200 : BRA +			; |
	.300	LDA #$0300				; |
	+	TAX					;/
		SEP #$20
		CPY $0E : BCS .End
		JMP .Loop

	.End	PLP
		PLB
		RTL





	;	.SA1
		PHP : SEP #$20				;\
		PHD					; | Back up some regs
		PHB : LDA.b #!BufferLo>>16		; |
		PHA : PLB				;/
		REP #$30				; > All regs 16-bi
		LDA.l !GraphicsSize			;\
		AND #$00FF				; |
		ASL #6					; | Y = tile index
		SEC : SBC #$0032			; |
		TAY					;/
		LDA #$6000 : TCD			; > DP = $6000
		LDA.l !GraphicsLoc+1			;\
		STA !GFX0+1				; |
		STA !GFX1+1				; | Store pointers (hi+bank)
		STA !GFX2+1				; |
		STA !GFX3+1				; |
		STA !GFX4+1				;/
		LDA.l !GraphicsLoc			;\ Base pointer (lo+hi)
		STA !GFX0				;/
		INC A					;\ Base + $01
		STA !GFX1				;/
		CLC : ADC #$000F			;\ Base + $10
		STA !GFX2				;/
		INC A					;\ Base + $11
		STA !GFX3				;/
		CLC : ADC #$000F			;\ Base + $20
		STA !GFX4				;/
		LDA #$0201 : STA $00			;\
		LDA #$0804 : STA $02			; | Copy depth bits to RAM
		LDA #$2010 : STA $04			; |
		LDA #$8040 : STA $06			;/
		STZ $08					;\
		STZ $0A					; | Clear mini-buffer
		STZ $0C					; |
		STZ $0E					;/
		SEP #$20				; > A 8-bit
		LDX #$0007				; > X = Xcoord

.RowLoop	LDA [!GFX4],y				;\
		AND $00,x				; | Check plane of pixel
		BNE .HiPlane				;/

.LoPlane	LDA [!GFX0],y				;\
		AND $00,x				; |
		TSB $08					; |
		LDA [!GFX1],y				; |
		AND $00,x				; |
		TSB $09					; | Generate pixel in lo plane
		LDA [!GFX2],y				; |
		AND $00,x				; |
		TSB $0A					; |
		LDA [!GFX3],y				; |
		AND $00,x				; |
		TSB $0B					;/
		DEX : BPL .RowLoop			; > Loop
		BRA .Shared				; > Go to shared routine

.HiPlane	LDA [!GFX0],y				;\
		AND $00,x				; |
		TSB $0C					; |
		LDA [!GFX1],y				; |
		AND $00,x				; |
		TSB $0D					; | Generate pixel in hi plane
		LDA [!GFX2],y				; |
		AND $00,x				; |
		TSB $0E					; |
		LDA [!GFX3],y				; |
		AND $00,x				; |
		TSB $0F					;/
		DEX : BPL .RowLoop			; > Loop

.Shared		REP #$20				; > A 16-bit
		TYX					; > Preserve Y in X
		TYA					;\
		AND #$000F				; |
		STA $003000				; |
		TYA					; | Calculate buffer index
		AND #$FFF0				; |
		LSR A					; |
		ORA $003000				; |
		TAY					;/
		LDA $08 : STA.w !BufferLo+$00,y		;\
		LDA $0A : STA.w !BufferLo+$10,y		; | Upload data to buffers
		LDA $0C : STA.w !BufferHi+$00,y		; |
		LDA $0E : STA.w !BufferHi+$10,y		;/
		STZ $08					;\
		STZ $0A					; | Clear mini-buffer
		STZ $0C					; |
		STZ $0E					;/
		TXY					; > Restore Y from X
		DEY #2					;\ Return at index underflow
		BMI .Return				;/
		LDX #$0007				; > X = Xcoord
		TYA					;\
		AND #$000F				; | Check for end of tile
		CMP #$000E				; |
		BEQ .NextTile				;/
		SEP #$20				; > A 8-bit
		JMP .RowLoop				; > Decode tile

.NextTile	TYA					;\
		SEC : SBC #$0030			; |
		TAY					; | Get index for next tile
		SEP #$20				; |
		JMP .RowLoop				;/

.Return		PLB					;\
		PLD					; | Restore regs
		PLP					;/
		RTL					; > Return






