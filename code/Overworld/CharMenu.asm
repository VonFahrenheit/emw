

	CharMenu:
		.Main
		ASL A
		TAX
		LDA !CharMenuTimer : BEQ ..nodec
		DEC !CharMenuTimer
		..nodec

		JSR (.Ptr-2,x)

		PHK : PLB
		REP #$30
		LDA !OAMindex_p3 : TAX
		CLC : ADC #$0004
		STA !OAMindex_p3
		LDA !CharMenuOtherPlayerX
		SEC : SBC #$0100			; Y - 1
		STA !OAM_p3+$000,x
		LDA !SelectingPlayer
		AND #$00FF
		BEQ $03 : LDA #$0202
		EOR #$7202
		BIT !CharMenuOtherPlayerP-1
		BVC $03 : EOR #$4000
		STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3,x

		PLP
		PLB
		RTL


		.Ptr
		dw .Opening			; 1
		dw .GreysAppear			; 2
		dw .Menu			; 3
		dw .GreysDisappear		; 4
		dw .Closing			; 5


; go into with:
;	- !CharMenuCurrentPlayerX/Y set to selecting player's on-screen coords
;	- timer set to 32
	.Opening
		BNE ..process
		INC !CharMenu
		LDA #$1C : STA !CharMenuTimer
		JSR ReloadStartButtons
		PHP
		JSR .UpdatePlayer
		PLP
		JMP .GreysAppear_process

		..process				;\
		STZ $2250				; |
		REP #$20				; |
		AND #$00FF : STA $2251			; | p2 not processed on single player
		LDX !SelectingPlayer : BEQ ..go		; |
		LDA !MultiPlayer			; |
		AND #$00FF : BNE ..go			; |
		RTS					;/

		..go					;\
		LDA !CharMenuCurrentPlayerX		; |
		AND #$00FF : STA $2253			; |
		NOP : BRA $00				; |
		LDA $2306 : STA $00			; | base offset component (base * time)
		LDA !CharMenuCurrentPlayerY		; |
		AND #$00FF : STA $2253			; |
		NOP : BRA $00				; |
		LDA $2306 : STA $02			;/

		LDA #$0020-1				;\
		SEC : SBC !CharMenuTimer		; |
		AND #$00FF : STA $2251			; |
		LDA #$0078 : STA $2253			; |
		NOP					; |
		LDA $00					; |
		CLC : ADC $2306				; |
		LSR #5					; | full coords, add (dest * (32-time))
		STA $00					; | /32
		LDA #$002C : STA $2253			; |
		NOP					; |
		LDA $02					; |
		CLC : ADC $2306				; |
		LSR #5					; |
		STA $02					;/

		LDA !CharMenuTimer
		AND #$00FF : TAX
		LDA $02
		CLC : ADC .JumpOffset,x
		STA $02

		LDA !OAMindex_p3 : TAX
		LDA $00 : STA !OAM_p3+$000,x
		LDA $02 : STA !OAM_p3+$001,x

		LDA !SelectingPlayer
		AND #$00FF
		BEQ $03 : LDA #$0202
		ORA #$3000
		STA !OAM_p3+$002,x
		TXA
		CLC : ADC #$0004
		STA !OAMindex_p3
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3,x

		.UpdatePlayer
		SEP #$30
		LDX !SelectingPlayer : STX $0A
		STZ $0B
		LDA !CharMenuCursor
		ASL #3
		ADC !CharMenuCursor
		ASL A
		STA $0E
		AND #$F0 : TRB $0E
		ASL A : ORA $0E
		LDY !CharMenu
		CLC : ADC .Pose,y
		STA $0E
		STZ $0F
		REP #$30
		JMP DrawPlayer_Dynamic


; macro to simulate gravity

macro JumpOffset()
	!Temp := !Temp+(!TempSpeed)
	!TempSpeed := !TempSpeed+6
	db !Temp/16
endmacro
		.Pose
		db $00,$02,$00,$20,$20,$02

		.JumpOffset
		!Temp = 0
		!TempSpeed = -96

		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()
		%JumpOffset()


; coords:
;	- center at $78 X $40 Y
;	- spaced $1C px apart
;	- if odd: center one at $78
;	- if even: center left at $6A, center right at $86

; a character is skipped as a grey if:
;	- it is not unlocked
;	- it is currently controlled by the other player



; $00 = current X
; $02 = distance between chars, based on counter this frame
; $04 = main character
; $0E = adjusted timer value



	.GreysAppear
		BNE ..process					; check for counter running out
		INC !CharMenu					;\
		LDX !CharMenuCursor				; |
	-	LDA !CharMenuSpriteStatus,x : BNE +		; |
		INX						; | update cursor to always start on a valid character
		CPX #$06					; |
		BCC $02 : LDX #$00				; |
		BRA -						; |
	+	STX !CharMenuCursor				;/
		LDX !SelectingPlayer				;\
		LDA !CharMenuCursor : STA !P1MapChar,x		; | let's go player 2!
		CPX #$00 : BEQ ..updateportrait			; |
		LDA #$01 : STA !MultiPlayer			;/
		..updateportrait				;\
		JSR .UpdateRender				; | update portrait
		SEP #$30					;/

		..process
		LDX !SelectingPlayer
		LDA !P1MapChar,x : STA $04
		STZ $05
		LDX !CharMenuTimer
		LDA !CharMenu
		CMP #$02
		REP #$30
		BNE ..filter2
		..filter1
		LDA .NumFilter1,x : BRA ..setfilter
		..filter2
		LDA .NumFilter2,x
		..setfilter
		AND #$00FF : STA $0E

		LDA !CharMenuCount
		AND #$00FF
		DEC A
		STA $2251
		LDA #$001C
		SEC : SBC $0E
		STA $2253
		STA $02
		LDA #$0078*2
		SEC : SBC $2306
		LSR A
		AND #$00FF
		ORA #$2C00
		STA $00

		STZ $2250
		LDA !OAMindex_p2 : TAX
		LDY #$0000

		..loop
		LDA !CharMenuSpriteStatus,y
		AND #$00FF : BEQ ..skip
		CPY $04 : BEQ ..drawmain

		..drawgrey
		LDA $00 : STA !OAM_p2+$000,x
		TYA
		ASL A
		ADC #$3E04
		STA !OAM_p2+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p2,x
		INX
		TXA
		ASL #2
		TAX
		BRA ..next

		..drawmain
		PHX
		LDA !OAMindex_p3 : TAX
		CLC : ADC #$0004
		STA !OAMindex_p3
		LDA $00 : STA !OAM_p3+$000,x			;
		CPY #$0001 : BNE ..notluigi			;\
		LDA !CharMenu					; |
		AND #$007F					; |
		CMP #$0004 : BNE ..notluigi			; | adjust luigi victory pose
		LDA !OAM_p3+$000,x				; |
		INC A						; |
		STA !OAM_p3+$000,x				; |
		..notluigi					;/
		LDA !SelectingPlayer
		AND #$00FF
		BEQ $03 : LDA #$0202
		ORA #$3000
		STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3,x
		PLX

		..next
		LDA $00
		CLC : ADC $02
		AND #$00FF
		ORA #$2C00
		STA $00

		..skip
		INY
		CPY #$0006 : BCS ..end
		JMP ..loop
		..end
		TXA : STA !OAMindex_p2

		RTS



		.NumFilter1
		db $00,$01,$01,$02,$02,$03,$04,$04	; 00-07
		db $05,$06,$06,$07,$08,$08,$09,$0A	; 08-0F
		db $0B,$0C,$0D,$0F,$10,$11,$12,$14	; 10-17
		db $15,$17,$18,$1A,$1C			; 18-1C

		.NumFilter2
		db $00,$02,$04,$05,$07,$08,$0A,$0B
		db $0C,$0D,$0F,$10,$11,$12,$13,$14
		db $14,$15,$16,$16,$17,$18,$18,$19
		db $1A,$1A,$1B,$1B,$1C



; $0F = number of options in menu

	.Menu
		INC !CharMenuTimer
		INC !CharMenuTimer
		LDX !SelectingPlayer
		BEQ $02 : LDX #$01
		TXA
		ORA #$06
		STA $0F
		LDA $6DA6,x : BMI ..close
		BIT #$10 : BNE ..close
		JMP ..noclose

		..close
		INC !CharMenu
		LDA !CharMenuCursor : STA !P1MapChar,x

		CPX #$00 : BNE ..closep2

		..closep1
		ASL #4
		STA $00
		LDA !Characters
		AND #$0F : BRA ..setchar

		..closep2
		CMP #$06 : BCS ..dropout
		..nodropout
		PHA
		PHP
		REP #$30
		%LoadHUD(SwitchP2)
		JSR RenderHUD
		PLP
		PLA
		BRA ..setp2char
		..dropout
		PHP
		JSR RemoveP2
		PLP
		LDA #$00 : STA !MultiPlayer
		STA !P2MapChar
		..setp2char
		STA $00
		LDA !Characters
		AND #$F0
		..setchar
		ORA $00
		STA !Characters

		PHP
		JSR .UpdatePlayer
		PLP
		LDA #$1C : STA !CharMenuTimer
		JMP .GreysDisappear_process

		..noclose
		AND #$03 : BEQ ..noupdate
		CMP #$03 : BEQ ..noupdate
		STZ !CharMenuTimer
		LDY #$06 : STY !SPC4
		LDY !CharMenuCursor
		CMP #$02 : BEQ ..l
	..r	INY
		CPY $0F
		BCC $02 : LDY #$00
		LDA !CharMenuSpriteStatus,y : BEQ ..r
		BRA ..write
	..l	DEY
		BPL $03 : LDY $0F : DEY
		LDA !CharMenuSpriteStatus,y : BEQ ..l
		..write
		STY !CharMenuCursor
		CPY #$06 : BCS ..noupdate
		LDX !SelectingPlayer
		TYA : STA !P1MapChar,x
		JSR .UpdateRender
		SEP #$30
		..noupdate




		STZ $02
		STZ $03
		LDX !SelectingPlayer : BEQ +
		LDA #$02
		STA $02
		STA $03
	+	LDA !CharMenuTimer
		AND #$03*8
		CMP #$03*8 : BNE +
		LDA #$40 : TSB $03
	+	LDA !CharMenuCursor : STA !P1MapChar,x
		TAY
		STA $00
		STZ $01
		REP #$30
		LDA !OAMindex_p3 : TAX



		; draw arrow
		CPY #$0006 : BNE ..chararrow

		..dropoutarrow
		LDA #$18E0 : STA !OAM_p3+$000,x
		BRA +

		..chararrow
		LDA !CharMenuSpriteX,y
		AND #$00FF
		ORA #$1800
		STA !OAM_p3+$000,x
	+	LDA #$3E2C : STA !OAM_p3+$002,x
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3,x
		INX
		TXA
		ASL #2
		TAX


		LDY #$0005

		..loop
		LDA !CharMenuSpriteStatus,y
		AND #$00FF : BEQ ..next
		LDA !CharMenuSpriteX,y
		AND #$00FF
		ORA #$2C00
		STA !OAM_p3+$000,x
		CPY $00 : BEQ ..drawmain

		..drawgrey
		TYA
		ASL A
		ADC #$3E04
		STA !OAM_p3+$002,x
		BRA ..finishdraw

		..drawmain
		LDA $02
		ORA #$3000
		STA !OAM_p3+$002,x
		LDA !CharMenuTimer
		AND #$0001*8 : BEQ ..finishdraw
		LDA !OAM_p3+$001,x
		DEC A
		STA !OAM_p3+$001,x
		LDA !CharMenuTimer
		AND #$0003*8
		CMP #$0003*8 : BNE ..finishdraw
		CPY #$0002 : BEQ ..xflip
		CPY #$0003 : BNE ..finishdraw
		..xflip
		LDA !OAM_p3+$000,x
		INC A
		STA !OAM_p3+$000,x

		..finishdraw
		TXA
		LSR #2
		TAX
		LDA #$0002 : STA !OAMhi_p3,x
		INX
		TXA
		ASL #2
		TAX
		..next
		DEY : BPL ..loop

		LDA !SelectingPlayer
		AND #$00FF : BEQ ..nodropoutoption
		TXA
		LSR #2
		TAX
		LDA #$0000
		STA !OAMhi_p3+$00,x
		STA !OAMhi_p3+$02,x
		STA !OAMhi_p3+$04,x
		STA !OAMhi_p3+$05,x
		TXA
		ASL #2
		TAX
		LDY #$0006*2
	-	LDA .DropOutTM1,y : STA !OAM_p3+$000,x
		LDA .DropOutTM2,y : STA !OAM_p3+$002,x
		INX #4
		DEY #2 : BPL -
		..nodropoutoption

		TXA : STA !OAMindex_p3

		SEP #$30
		LDA.b #!VRAMbank : PHA				; push bank 0x40
		LDX !SelectingPlayer : STX $0A
		STZ $0B
		LDA !CharMenuCursor
		ASL #3
		ADC !CharMenuCursor
		ASL A
		STA $0E
		AND #$F0 : TRB $0E
		ASL A : TSB $0E
		LDA !CharMenuTimer
		AND #$01*8
		LSR #2
		ADC $0E
		STA $0E
		STZ $0F
		REP #$30
		JSR DrawPlayer_Dynamic



		LDA.w #!PalsetData>>8 : STA $01			;\
		LDA !CharMenuCursor				; |
		AND #$00FF					; | get palette data pointer
		ASL #5						; |
		ADC.w #!PalsetData+2				; |
		STA $00						;/
		LDY #$001C					;\
		LDA !SelectingPlayer				; |
		AND #$00FF					; |
		BEQ $03 : LDA #$0020				; |
		ORA #$011E					; |
		TAX						; | update palette (RGB mirror + shader input)
	-	LDA [$00],y					; |
		STA !PaletteRGB,x				; |
		STA !ShaderInput,x				; |
		DEX #2						; |
		DEY #2 : BPL -					;/
		JSL GetCGRAM					;\
		PLB						; > go into bank 0x40
		LDA $00 : STA !CGRAMtable+$02,y			; |
		LDA.w #!PalsetData>>16 : STA !CGRAMtable+$04,y	; |
		LDA #$001E : STA !CGRAMtable+$00,y		; |
		SEP #$20					; | update palette (CGRAM)
		LDA.l !SelectingPlayer				; |
		BEQ $02 : LDA #$10				; |
		ORA #$81					; |
		STA !CGRAMtable+$05,y				; |
		LSR #4						; |
		TAX						; |
		LDA #$01 : STA !ShaderRowDisable,x		;/
		RTS


		.UpdateRender
		LDA !SelectingPlayer
		REP #$30
		BNE ..p2

		..p1
		JSR ReloadP1Portrait
		REP #$30
		JMP ReloadP1Name

		..p2
		%LoadHUD(NameP2)
		LDA !P2MapChar
		AND #$000F
		ASL A
		TAX
		LDA NameOffset,x : STA $00
		JSR RenderP2Name
		%LoadHUD(PortraitP2)
		LDA !P2MapChar
		AND #$000F
		ASL #3
		ADC $00
		STA $00
		JMP RenderHUD



	; coords
	.DropOutTM1
		db $D8,$2C	; D
		db $E0,$2C	; r
		db $E8,$2C	; o
		db $F0,$2C	; p

		db $DC,$36	; O
		db $E4,$36	; u
		db $EC,$36	; t


	; tile + prop
	.DropOutTM2
		db $30,$3E	; D
		db $31,$3E	; r
		db $32,$3E	; o
		db $33,$3E	; p
		db $34,$3E	; O
		db $35,$3E	; u
		db $36,$3E	; t



	.GreysDisappear
		BNE ..process
		LDA #$1F : STA !CharMenuTimer
		INC !CharMenu
		BRA .Closing_process

		..process
		DEC A
		PHA
		PHP
		LDA #$1C
		SEC : SBC !CharMenuTimer
		STA !CharMenuTimer
		JSR .GreysAppear_process
		PLP
		PLA : STA !CharMenuTimer
		RTS


	.Closing
		BNE ..process
		STZ !CharMenu
		RTS

		..process
		DEC A
		PHA
		PHP
		LDA #$1F
		SEC : SBC !CharMenuTimer
		STA !CharMenuTimer
		INC A
		JSR .Opening_process
		PLP
		PLA : STA !CharMenuTimer
		RTS



	InitCharMenu:
		SEP #$30
		LDA #$1F : STA !CharMenuTimer
		STZ !CharMenuCount
		STZ $00

		.GetChars
		LDX #$00
		TXY
		..loop
		LDA !MarioStatus,x : STA !CharMenuSpriteStatus,y
		BEQ ..next
		LDA !SelectingPlayer : BNE ..lockp1char
		LDA !MultiPlayer : BEQ ..nolockout
		..lockp2char
		CPY !P2MapChar : BEQ ..lockout
		BRA ..nolockout
		..lockp1char
		CPY !P1MapChar : BNE ..nolockout
		..lockout
		LDA #$00 : STA !CharMenuSpriteStatus,y
		BRA ..next
		..nolockout
		LDA $00 : STA !CharMenuSpriteX,y
		CLC : ADC #$1C
		STA $00
		INC !CharMenuCount
		..next
		TXA
		CLC : ADC #$0A
		TAX
		INY
		CPY #$06 : BCC ..loop

		.Distribute
		LDX !CharMenuCount
		LDA .Offset-1,x : STA !CharMenuBaseX
		LDX #$05
		..loop
		LDA !CharMenuSpriteX,x
		CLC : ADC !CharMenuBaseX
		STA !CharMenuSpriteX,x
		DEX : BPL ..loop


		RTS


		.Offset
		db $78,$6A,$5C,$4E,$40,$32







