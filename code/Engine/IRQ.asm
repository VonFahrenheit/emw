;=============;
;IRQ EXPANSION;
;=============;
; regs used:
; 2100 - brightness + f-blank
; 2105 - screen mode
; 2106 - mosaic
; 2109 - BG3 tilemap address
; 2111 - BG3 hscroll
; 2112 - BG3 vscroll
; 2115 - VRAM transfer stuff
; 2116 - VRAM transfer stuff
; 2121 - CGRAM address
; 2122 - CGRAM write
; 2124 - BG3/BG4 window settings
; 212C - main screen settings
; 212E - main screen settings
; 2130 - color math
; 2131 - color math
IRQ:
		PHD					; > push direct page
		LDA #$43 : XBA				;\ DP = 0x4300
		LDA #$00 : TCD				;/
		LDA !Cutscene : BEQ .NoCutscene		;\
		LDA #$80 : STA $2100			; | cutscene: turn black
		JMP .Return				; |
		.NoCutscene				;/

		LDX !GameMode
		LDA.l .GameModeEnable,x : BEQ +		; 00 -> return
		BPL .Level				; 01 -> level
		LDA !P2Status-$80 : BEQ +		;\ FF -> return if at least one player alive, otherwise level
		LDA !P2Status : BNE .Level		;/
	+	JMP .Return

.Level		BIT $4212 : BVC .Level			; wait for f-blank to prevent tearing
		LDA #$80 : STA $2100			; enable f-blank
		LDA !210C				;\
		ASL #4					; | BG3 tilemap location (inside GFX)
		STA $2109				;/
		STZ $420C				; disable HDMA
		STZ $2115				; byte uploads
		LDY #$01				; channel bit
		REP #$20				;\
		LDA !210C				; |
		AND #$000F				; |
		XBA					; |
		ASL #4					; |
		ORA #$0080				; > tiles 0x010-0x013
		PHA					; |
		STA $2116				; |
		LDA #$1800 : STA $00			; |
		LDA #$6EF9 : STA $02			; | upload status bar tilemap
		LDX #$00 : STX $04			; |
		LDA #$0020 : STA $05			; |
		STY $420B				;/
		LDX #$80 : STX $2115			; > word uploads (we're kinda cheating but it's ok)
		PLA : STA $2116				;\
		LDA #$1900 : STA $00			; |
		LDA.w #!StatusProp : STA $02		; | upload status bar YXPCCCTT
		STZ $04					; |
		LDA #$0020 : STA $05			; |
		STY $420B				;/
		LDA #$2202 : STA $00			;\
		LDA.w #!StatusBarColors : STA $02	; |
		STZ $04					; | upload status bar palette
		LDA #$000E : STA $05			; |
		STY $2121				; |
		STY $420B				;/
		LDA #$2100 : TCD			; > DP = 0x2100
		SEP #$20				; > A 8 bit
		LDA !StatusX : STA $11			;\ BG3 Hscroll
		STZ $11					;/
		LDA #$47 : STA $12			;\ BG3 Vscroll
		LDA #$FF : STA $12			;/
.Shared		LDA #$04 : STA $2C			; > main screen designation
		STZ $24					;\ disable windowing
		STZ $2E					;/
		STZ $30					;\ color math settings
		STZ $31					;/
		STZ $21					;\
		STZ $22					; | color 0 to black
		STZ $22					;/
		LDA #$09 : STA $05			; > GFX mode 1 + Layer 3 priority
		STZ $06					; > no mosaic
	-	BIT $4212 : BVC -			;\ wait for h-blank and restore brightness
		LDA !2100 : STA $00			;/
.Return		REP #$30				;\
		PLD					; |
		PLB					; |
		PLY					; | return from interrupt
		PLX					; |
		PLA					; |
		PLP					; |
		RTI					;/



.GameModeEnable
		db $00,$00,$00,$00,$00,$00,$00,$00	; 00-07
		db $00,$00,$00,$FF,$00,$00,$00,$01	; 08-0F
		db $00,$00,$00,$01,$01,$00,$00,$00	; 10-17
		db $00,$00,$00,$00,$00,$00,$00,$00	; 18-1F
		db $00,$00,$00,$00,$00,$00,$00,$00	; 20-27
		db $00,$00,$00,$00,$00,$00,$00,$00	; 28-2F

