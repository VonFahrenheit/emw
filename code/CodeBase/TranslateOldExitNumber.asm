

; index to exit table:
;	if !HorzLevelMode < 0x0D
;		index = X hi
;
;	otherwise... it gets a little complicated

; number of rows = 32 / !Map16Width
; height of each row = !LevelHeight / number of rows
; 32 / !Map16Width HAS to be calculated ahead of time or bits won't be shredded properly!

; easiest way to calculate index:
;	row count = 32 / !Map16Width
;	row height = !LevelHeight / row count
;	player row = player Y / row height
;	row offset = player row * !Map16Width
;	index = row offset + X hi



; input: !Mario coords set to coords of player triggering the exit
; output: the LM exit value is translated and stored to !LevelEntry
	TranslateOldExitNumber:
		PHP

		.CapCoords
		REP #$20
		LDA !MarioYPosLo
		BPL $03 : LDA #$0000
		BIT !CameraBoxU : BMI +
		CMP !CameraBoxU : BCS +
		LDA !CameraBoxU
	+	STA !MarioYPosLo
		LDA !CameraBoxD
		CLC : ADC #$00EF
		CMP !MarioYPosLo : BCS +
		STA !MarioYPosLo
		+

		LDA !MarioXPosLo
		BPL $03 : LDA #$0000
		CMP !CameraBoxL : BCS +
		LDA !CameraBoxL
	+	CMP !CameraBoxR : BCC +
		LDA !CameraBoxR
	+	STA !MarioXPosLo
		SEP #$30

		.CalcIndex
		LDA !HorzLevelMode
		AND #$1F
		CMP #$0D : BCS ..advancedcalc
		..easycalc
		LDX !MarioXPosHi : BRA .ProcessExit
		..advancedcalc
		LDA #$01 : STA $2250
		REP #$30

		LDA #$0020 : STA $2251				;\
		LDA !Map16Width					; | row count = 32 / !Map16Width
		AND #$00FF : STA $2253				;/
		TAY						; Y = !Map16Width (16-bit)
		LDX !LevelHeight				;\
		LDA $2306					; | row height = !LevelHeight / row count
		STX $2251					; |
		STA $2253					;/
		LDX !MarioYPosLo				;\
		BRA $00						; |
		LDA $2306					; | player row = player Y / row height
		STX $2251					; |
		STA $2253					;/
		LDA $2306					;\
		STZ $2250					; | row offset = player row * !Map16Width
		STA $2251					; |
		STY $2253					;/
		SEP #$30					;\
		LDA !MarioXPosHi				; | index = X hi + row offset
		CLC : ADC $2306					; |
		TAX						;/


		.ProcessExit
		LDA $79B8,x : STA !LevelEntry			; lo byte requires no translation
		LDA $79D8,x
		BIT #$04 : BEQ ..main
		BIT #$02 : BNE ..secondary
		BIT #$08 : BEQ ..main

		..midway
		AND #$01
		ORA #$40
		BRA ..write

		..secondary
		AND #$F0
		LSR #3 : STA $00
		LDA $79D8,x
		AND #$01
		ORA $00
		ORA #$80 : BRA ..write

		..main
		AND #$01

		..write
		STA !LevelEntry+1
		PLP
		RTL







