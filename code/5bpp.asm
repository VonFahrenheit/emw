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


; planar format
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
	;	LDA [!GraphicsLoc],y
	;	INY
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

macro ShiftPixels(offset)
		LDA [!GraphicsLoc],y		;\
		AND #$1F			; | read B0:0-4
		%SplitPixel(<offset>+$00)	;/
		REP #$20			;\
		LDA [!GraphicsLoc],y		; |
		ASL #3				; |
		XBA				; | read B0:5-7 + B1:0-1
		SEP #$20			; |
		AND #$1F			; |
		%SplitPixel(<offset>+$01)	;/
		INY				;\
		LDA [!GraphicsLoc],y		; |
		LSR #2				; | read B1:2-6
		AND #$1F			; |
		%SplitPixel(<offset>+$02)	;/
		REP #$20			;\
		LDA [!GraphicsLoc],y		; |
		ASL A				; |
		XBA				; | read B1:7 + B2:0-3
		SEP #$20			; |
		AND #$1F			; |
		%SplitPixel(<offset>+$03)	;/
		INY				;\
		REP #$20			; |
		LDA [!GraphicsLoc],y		; |
		LSR #4				; | read B2:4-7 + B3:0
		SEP #$20			; |
		AND #$1F			; |
		%SplitPixel(<offset>+$04)	;/
		INY				;\
		LDA [!GraphicsLoc],y		; |
		LSR A				; | read B3:1-5
		AND #$1F			; |
		%SplitPixel(<offset>+$05)	;/
		REP #$20			;\
		LDA [!GraphicsLoc],y		; |
		ASL #2				; |
		XBA				; | read B3:6-7 + B4:0-2
		SEP #$20			; |
		AND #$1F			; |
		%SplitPixel(<offset>+$06)	;/
		INY				;\
		LDA [!GraphicsLoc],y		; | read B4:3-7
		LSR #3				; |
		%SplitPixel(<offset>+$07)	;/
		INY				; Y+1
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
		SEP #$30
		STZ $223F
		LDA #$60
		PHA : PLB
		REP #$10
		LDX #$0000
		LDY #$0000

		..loop
		%ShiftPixels($00)
		%ShiftPixels($08)

		REP #$20
		TXA
		CLC : ADC #$0010
		CMP #$0400 : BEQ ..end			; end at 0x400 (output)
		CMP #$0100 : BEQ ..200			;\
		CMP #$0200 : BEQ ..300			; |
		CMP #$0300 : BNE ..next			; | order: 000 block, 200 block, 100 block, 300 block
	..100	LDA #$0100 : BRA ..next			; |
	..200	LDA #$0200 : BRA ..next			; |
	..300	LDA #$0300				; |
		..next					;/

		TAX
		SEP #$20
		JMP ..loop

		..end
		PLP
		PLB
		RTL






