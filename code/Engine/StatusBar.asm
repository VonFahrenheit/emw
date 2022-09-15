


	!CoinTile		= $18
	!YoshiCoinTile		= $19
	!DashTile		= $1A
	!HeartTile		= $0A
	!HeartTile_empty	= !HeartTile+0
	!HeartTile_quarter	= !HeartTile+1
	!HeartTile_half		= !HeartTile+2
	!HeartTile_threeq	= !HeartTile+3
	!HeartTile_full		= !HeartTile+4
	!SkullTile		= $0F



	StatusBar:
		PHB : PHK : PLB
		JSR .Main
		PLB
		RTL

	.Main
		LDA !Difficulty_full				;\ see if timer is enabled
		AND.b #!TimeMode : BNE .RunTimer		;/
	-	JMP .NoTimer					;\ run timer

		.RunTimer
		LDA !TimerSeconds+1 : BMI -			; don't process if negative

		LDA !Mosaic					;\ not during level fades
		AND #$F0 : BNE -				;/
		LDA !MsgTrigger					;\
		ORA !MsgTrigger+1				; | skip this stuff when a text box is open
		BNE -						;/
		INC !TimeElapsedFrames				; 1 more frame has passed
		DEC !TimerFrames : BEQ ..newsecond		;\
		..gotodraw					; |
		JMP ..drawtimer					; | timer (frames per second)
		..newsecond					; |
		LDA.b #60 : STA !TimerFrames			;/
		STZ !TimeElapsedFrames				;\
		LDA !TimeElapsedSeconds				; |
		INC A						; |
		CMP #60						; |
		BCC $02 : LDA #$00				; | on a new second tick, clear frames elapsed and tick up seconds/minutes
		STA !TimeElapsedSeconds				; |
		BNE ..upcountdone				; |
		INC !TimeElapsedMinutes				; |
		..upcountdone					;/

		REP #$20					;\
		LDA !TimerSeconds				; |
		CMP.w #100 : BNE +				; |
		LDX #$80 : STX !SPC1				; > speed up music tempo
		LDX #$1D : STX !SPC4				; > running out of time SFX
	+	LDA !TimerSeconds : BEQ ..gotodraw		; |
		DEC !TimerSeconds				; | timer (seconds)
		SEP #$20					; |
		BNE ..timerupdate				;/
		LDA #$01					;\
		LDY !P2Status-$80				; |
		BNE $03 : STA !P2Status-$80			; | kill players when timer hits 0
		LDY !P2Status					; |
		BNE $03 : STA !P2Status				;/

		..timerupdate
		REP #$20					; A 16-bit
		STZ $00						; 100s
		STZ $02						; 10s
		STZ $04						; 1s

		LDA !TimerSeconds				;\
	..100s	CMP.w #100 : BCC ..10s				; |
		SBC.w #100					; |
		INC $00						; |
		BRA ..100s					; | get digits
	..10s	CMP.w #10 : BCC ..1s				; |
		SBC.w #10					; |
		INC $02						; |
		BRA ..10s					; |
	..1s	STA $04						;/

		LDY.b #!File_Sprite_BG_1 : JSL GetFileAddress	; file: sprite BG 1
		JSL GetVRAM					; get VRAM table index
		PHB						; push bank
		LDY.b #!VRAMbank				;\ VRAM table bank
		PHY : PLB					;/
		LDA #$0020					;\
		STA !VRAMtable+$00,x				; | upload size
		STA !VRAMtable+$07,x				; |
		STA !VRAMtable+$0E,x				;/
		LDA !FileAddress+2				;\
		STA !VRAMtable+$04,x				; | source bank
		STA !VRAMtable+$0B,x				; |
		STA !VRAMtable+$12,x				;/
		LDA $00						;\
		BNE $03 : LDA #$000A				; |
		ASL #5						; | 100s source address
		ADC.w #$60*$20					; |
		ADC !FileAddress				; |
		STA !VRAMtable+$02,x				;/
		LDA $02						;\
		BNE +						; |
		LDY $00 : BNE +					; |
		LDA #$000A					; | 10s source address
	+	ASL #5						; |
		ADC.w #$60*$20					; |
		ADC !FileAddress				; |
		STA !VRAMtable+$09,x				;/
		LDA $04						;\
		ASL #5						; |
		ADC.w #$60*$20					; | 1s source address
		ADC !FileAddress				; |
		STA !VRAMtable+$10,x				;/

		LDA #$6420 : STA !VRAMtable+$05,x		;\
		LDA #$6430 : STA !VRAMtable+$0C,x		; | dest VRAM
		LDA #$6520 : STA !VRAMtable+$13,x		;/

		PLB						; restore bank

		..drawtimer
		REP #$20					; A 16-bit
		LDA #$CE70 : STA !OAM_p3+$00C			;\ timer tile 0
		LDA #$3453 : STA !OAM_p3+$00E			;/
		LDA #$CE78 : STA !OAM_p3+$008			;\ timer tile 1
		LDA #$3442 : STA !OAM_p3+$00A			;/
		LDA #$CE80 : STA !OAM_p3+$004			;\ timer tile 2
		LDA #$3443 : STA !OAM_p3+$006			;/
		LDA #$CE88 : STA !OAM_p3+$000			;\ timer tile 3
		LDA #$3452 : STA !OAM_p3+$002			;/
		LDA #$0010 : STA !OAMindex_p3			; OAM index
		LDA #$0000					;\
		STA !OAMhi_p3+$000				; | tile size (8x8)
		STA !OAMhi_p3+$002				;/
		SEP #$20					; A 8-bit
		.NoTimer					;/

	.Coins
		LDA !CoinSound
		BEQ $03 : DEC !CoinSound
		REP #$20					; > A 16 bit
		LDX !P1CoinIncrease : BEQ .Next
	.P1	DEC !P1CoinIncrease
		INC !P1Coins
		JSR CoinSound
	.Next	LDX !P2CoinIncrease : BEQ .Nope
	.P2	DEC !P2CoinIncrease
		INC !P2Coins
		JSR CoinSound
	.Nope	LDA #$270F					;\
		CMP !P1Coins					; |
		BCS $03 : STA !P1Coins				; | cap coins at 9999
		CMP !P2Coins					; |
		BCS $03 : STA !P2Coins				;/

		LDA !P1Coins : JSR HexToDec			;\
		STA !StatusBar+$04				; |
		LDA $00 : STA !StatusBar+$03			; | P1 coin counter
		LDA $01 : STA !StatusBar+$02			; |
		LDA $02 : STA !StatusBar+$01			;/

		LDA #$14					;\
		STA !StatusBar+$19				; | clear these tiles (in case they're not overwritten)
		STA !StatusBar+$1A				; |
		STA !StatusBar+$1F				;/
		LDA !MultiPlayer : BEQ .SinglePlayer		;\
		LDA !StatusX					; |
		BEQ $02 : LDA #$01				; | index to P2 coin counter
		EOR #$01					; |
		TAX						;/
		REP #$20					;\
		LDA !P2Coins : JSR HexToDec			; |
		STA !StatusBar+$1E,x				; | P2 coin counter
		LDA $00 : STA !StatusBar+$1D,x			; |
		LDA $01 : STA !StatusBar+$1C,x			; |
		LDA $02 : STA !StatusBar+$1B,x			;/
		LDA.b #!CoinTile : STA !StatusBar+$1A,x		; coin tile
		BRA .MultiPlayer

		.SinglePlayer					;\
		REP #$20					; |
		LDA #$1414					; | empty space on single player
		STA !StatusBar+$1A				; |
		STA !StatusBar+$1C				; |
		STA !StatusBar+$1E				;/

		.MultiPlayer					;\
		REP #$20					; |
		LDA #$1414					; |
		STA !StatusBar+$05				; |
		STA !StatusBar+$07				; |
		STA !StatusBar+$09				; |
		STA !StatusBar+$0B				; |
		STA !StatusBar+$0D				; | empty space
		STA !StatusBar+$0F				; |
		STA !StatusBar+$11				; |
		STA !StatusBar+$13				; |
		STA !StatusBar+$15				; |
		STA !StatusBar+$17				; |
		SEP #$20					;/
		LDA.b #!CoinTile : STA !StatusBar+$00		; P1 coin symbols


	.YoshiCoins
		LDA !MegaLevelID : BEQ ..normallevelinit	;\
		..megalevelinit					; |
		TAX						; | check for and draw mega level coins
		LDY #$0A : STY $01				; |
		LDY #$05					; |
		BRA ..draw					;/
		..normallevelinit				;\
		LDY #$07 : STY $01				; | settings for normal coins
		LDY #$02					; |
		..loadnormal					;/
		LDX !Translevel : BEQ ..done			; return if on intro level / home base
		..draw						;\ get coins to draw
		LDA !LevelTable1,x : STA $00			;/
		..loop						;\
		LDA.b #!DashTile				; |
		LSR $00						; |
		BCC $02 : LDA.b #!YoshiCoinTile			; | draw coins
		STA !StatusBar+$0B,y				; |
		INY						; |
		CPY $01 : BCC ..loop				;/
		CPY #$0A : BNE ..done				;\
		LDY #$05 : STY $01				; |
		LDY #$00					; | if on mega level, also draw normal coins
		BRA ..loadnormal				; |
		..done						;/


	.Player1HP
		LDX #$00
		LDY #$06
		JSR DrawHearts

	.Player2HP
		LDA !MultiPlayer : BEQ ..done
		LDX #$80
		LDY #$18
		LDA !MegaLevelID
		BEQ $01 : INY
		JSR DrawHearts
		..done

	.Return
		RTS					; > Return





; input:
;	X = player index
;	Y = status bar index (x06 for player 1, x18 for player 2 on normal levels / x19 on mega levels)
	DrawHearts:
		.CriticalMode				;\
		LDA !Difficulty_full			; |
		AND.b #!CriticalMode : BEQ ..done	; | on critical mode, just draw the skull icon and return
		LDA.b #!SkullTile : STA !StatusBar+1,y	; |
		RTS					; |
		..done					;/


		STY $0F					; $0F = index to status bar tilemap

		.CheckStatus				;\
		LDA !P2Status-$80,x : BEQ ..notdead	; | clear HP + temp HP if dead
		STZ !P2HP-$80,x				; |
		STZ !P2TempHP-$80,x			;/
		..notdead				;\
		LDA !P2Entrance-$80,x			; |
		CMP #$20 : BCC ..done			; | wait for entrance animation
		RTS					; |
		..done					;/

		LDA #$01				;\
		LDY #$00				; |
		CPX #$80 : BNE +			; | index to heart timer + status bar hearts
		LDA #$FF				; | + index change (+1 for P1, -1 for P2)
		LDY #$03				; |
	+	STA $0E					;/

		.CheckTemp				;\
		LDA !P2TempHP-$80,x : BEQ ..done	; | heart timer
		LDA #$1F : STA !HeartTimerP1,y		; |
		..done					;/


		.UpdateTimer				;\
		LDA $14					; |
		AND #$03 : BNE ..done			; |
		LDA !P2HP-$80,x				; |
		CLC : ADC !P2TempHP-$80,x		; |
		CMP !StatusBarP1Hearts,y		; |
		BEQ ..done				; | heart displays moves 1 step towards actual heart count every 4 frames
		BCS ..inc				; |
	..dec	LDA !StatusBarP1Hearts,y		; |
		DEC A : STA !StatusBarP1Hearts,y	; |
		BIT !P2ShowHP-$80,x : BPL ..done
		LDA #$88 : STA !P2ShowHP-$80,x
		BRA ..done				; |
	..inc	LDA !StatusBarP1Hearts,y		; |
		INC A : STA !StatusBarP1Hearts,y	; |
		LDA #$1B : STA !HeartTimerP1,y		; |
		BIT !P2ShowHP-$80,x : BPL ..done
		LDA #$88 : STA !P2ShowHP-$80,x
		..done					;/




; $0D = counting HP
; $0E = index change
; $0F = tilemap index

		.DrawHearts				;\
		LDA !P2MaxHP-$80,x : BEQ ..done		; |
		CLC : ADC #$03				; |
		LSR #2					; |
		BIT $0E					; |
		BPL $03 : EOR #$FF : INC A		; |
		CLC : ADC $0F				; | setup
		STA $00					; |
		LDA !StatusBarP1Hearts,y		; |
		LDY $0F					; |
		STA $0D					;/
		..loop					;\
		CMP #$04 : BCC ..fraction		; |
		SBC #$04				; |
		STA $0D					; |
		LDA.b #!HeartTile_full : BRA ..draw	; |
		..fraction				; |
		ADC.b #!HeartTile			; |
		STZ $0D					; | draw hearts
		..draw					; |
		STA !StatusBar+$00,y			; |
		TYA					; |
		CLC : ADC $0E				; |
		TAY					; |
		LDA $0D					; |
		CPY $00 : BNE ..loop			; |
		..done					;/


		LDY #$00				;\
		CPX #$80				; | index to heart timer + status bar hearts
		BNE $02 : LDY #$03			;/

		.GetColor				;\
		REP #$20				; |
		LDA !HeartTimerP1,y : BEQ ..nodec	; |
		DEC A : STA !HeartTimerP1,y		; |
		..nodec					; |
		ASL #5					; |
		STA $00					; |
		ASL #5					; |
		STA $02					; |
		LDA #$0007*$20				; |
		CMP $00					; |
		BCS $02 : LDA $00			; | update heart color
		STA $00					; |
		LDA #$0003*$20*$20			; |
		CMP $02					; |
		BCS $02 : LDA $02			; |
		ORA $00					; |
		ORA #$001B				; |
		LDY #$00				; |
		CPX #$80				; |
		BNE $02 : LDY #$08			; |
		STA !StatusBarColors+$02,y		; |
		SEP #$20				;/

		RTS					; return



; input:
;	A = 16-bit number to convert to dec
; output
;	A 8-bit
;	A = 1s digit
;	$00 = 10s digit
;	$01 = 100s digit
;	$02 = 1000s digit
	HexToDec:
		.1000
		LDY #$00
		..loop
		CMP #$03E8 : BCC ..store
		SBC #$03E8
		INY : BRA ..loop
		..store
		STY $02

		.100
		LDY #$00
		..loop
		CMP #$0064 : BCC ..store
		SBC #$0064
		INY : BRA ..loop
		..store
		STY $01

		.10
		LDY #$00
		..loop
		CMP #$000A : BCC ..store
		SBC #$000A
		INY : BRA ..loop
		..store
		STY $00

		.1
		SEP #$20
		RTS

	CoinSound:
		LDX !CoinSound : BNE .ManyCoins
		LDX #$01 : STX !SPC4
		LDX #$04 : STX !CoinSound
		.ManyCoins
		RTS

