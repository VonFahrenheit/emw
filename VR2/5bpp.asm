;=======================;
;PLANE-SPLITTING ROUTINE;
;=======================;
;
;	This routine will decompress an 8bpp GFX file into two 4bpp GFX files and upload them to VRAM.
;	By overlapping tiles from the two files you can simulate 5bpp sprites.
;	To use it, store the following in $00-$03:
;
;	$0000:		24-bit pointer to graphics file
;	$0003:		8-bit number of 8x8 tiles

	!GraphicsLoc	= $0000				; 24-bit pointer to graphics file
	!GraphicsSize	= $0003				; 8-bit number of 8x8 tiles

	!BufferLo	= $7EC100			; 24-bit pointer to decompression buffer.
	!BufferHi	= !BufferLo+(!BufferSize/2)	; Hi buffer.
	!BufferSize	= $0400				; Size of buffer. Must be divisible by 4.

	!GFX0		= $10
	!GFX1		= $13
	!GFX2		= $16
	!GFX3		= $19
	!GFX4		= $1C


; X = pixel
; Y = row * 2

PLANE_SPLIT:	PHP : SEP #$20
		PHD
		PHB : LDA.b #!BufferLo>>16
		PHA : PLB
		REP #$30
		LDA !GraphicsSize
		AND #$00FF
		ASL #6
		SEC : SBC #$0032
		TAY
		LDA #$0120 : TCD
		LDA !GraphicsLoc+1
		STA !GFX0+1
		STA !GFX1+1
		STA !GFX2+1
		STA !GFX3+1
		STA !GFX4+1
		LDA !GraphicsLoc
		STA !GFX0
		INC A
		STA !GFX1
		CLC : ADC #$0E
		STA !GFX2
		INC A
		STA !GFX3
		CLC : ADC #$0E
		STA !GFX4
		LDA #$0201 : STA $00
		LDA #$0804 : STA $02
		LDA #$2010 : STA $04
		LDA #$8040 : STA $06
		SEP #$20
		LDX #$0007
.RowLoop	LDA (!GFX4),y
		AND $00,x
		BNE .HiPlane

.LoPlane	LDA (!GFX0),y
		AND $00,x
		TSB $08 : TRB $0C
		LDA (!GFX1),y
		AND $00,x
		TSB $09 : TRB $0D
		LDA (!GFX2),y
		AND $00,x
		TSB $0A : TRB $0E
		LDA (!GFX3),y
		AND $00,x
		TSB $0B : TRB $0F
		DEX : BPL .RowLoop
		BRA .Shared

.HiPLane	LDA (!GFX0),y
		AND $00,x
		TRB $08 : TSB $0C
		LDA (!GFX1),y
		AND $00,x
		TRB $09 : TSB $0D
		LDA (!GFX2),y
		AND $00,x
		TRB $0A : TSB $0E
		LDA (!GFX3),y
		AND $00,x
		TRB $0B : TSB $0F
		DEX : BPL .RowLoop

.Shared		REP #$20
		LDA $08 : STA.w !BufferLo+$00,y
		LDA $0A : STA.w !BufferLo+$10,y
		LDA $0C : STA.w !BufferHi+$00,y
		LDA $0E : STA.w !BufferHi+$10,y
		DEY #2
		TYA
		AND #$000F
		BEQ +
		SEP #$20
		JMP .RowLoop
	+	TYA
		BEQ .Return
		SEC : SBC #$0040
		TAY
		JMP .RowLoop

.Return		PLB
		PLD
		PLP
		RTL






