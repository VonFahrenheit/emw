
	!BallAndChainXLo	= $3500
	!BallAndChainXHi	= $3510
	!BallAndChainYLo	= $3520
	!BallAndChainYHi	= $3530


	INIT:
		LDA !ExtraBits,x						;\
		AND #$04							; | start pointing down (extra bit clear) or up (extra bit set)
		BEQ $02 : LDA #$80						; |
		ORA #$40 : STA $3280,x						;/
		LDA !SpriteXLo,x : STA !BallAndChainXLo,x			;\
		AND #$10 : STA $3290,x						; > direction
		LDA !SpriteXHi,x : STA !BallAndChainXHi,x			; | origin coords
		LDA !SpriteYLo,x : STA !BallAndChainYLo,x			; |
		LDA !SpriteYHi,x : STA !BallAndChainYHi,x			;/
		RTS


	MAIN:

	.Rotate
		LDA $3290,x : BEQ ..clockwise					;\
		..counterclock							; |
		DEC $3280,x : BRA ..done					; | rotate
		..clockwise							; |
		INC $3280,x							; |
		..done								;/


	.GetChainCoords
		STZ $2250							; set multiplication
		LDA !BallAndChainXLo,x : STA $E0				;\
		LDA !BallAndChainXHi,x : STA $E1				; | origin coords
		LDA !BallAndChainYLo,x : STA $E2				; |
		LDA !BallAndChainYHi,x : STA $E3				;/

		REP #$30							; all regs 16-bit
		LDA $3280,x							;\
		AND #$00FF							; |
		ASL A : TAY							; |
		ASL A								; |
		AND #$01FF : TAX						; | sine x base value
		LDA !TrigTable,x						; |
		CPY #$0100							; |
		BCC $04 : EOR #$FFFF : INC A					; |
		STA $2251							; |
		LDX #$0010 : STX $2253						;/
		TYA								;\
		CLC : ADC #$0080						; | get cosine index (doing this here saves some cycles later)
		AND #$01FF : TAY						;/

		; want to keep 16-bit index so Y isn't shredded (slightly better)
		LDA $2307							;\
		LDX #$0020 : STX $2253						; | y of link 1 + calc y of link 2
		CLC : ADC $E2							; |
		STA $E6								;/
		LDA $2307							;\
		LDX #$0038 : STX $2253						; | y of link 2 + calc y of ball
		CLC : ADC $E2							; |
		STA $EA								;/
		LDA $2307							;\
		CLC : ADC $E2							; | y of ball
		STA $EE								;/

		TYA								;\
		ASL A								; |
		AND #$01FF : TAX						; |
		LDA !TrigTable,x						; | cosine x base value
		CPY #$0100							; |
		BCC $04 : EOR #$FFFF : INC A					; |
		STA $2251							; |
		LDX #$0010 : STX $2253						;/

		LDX #$0020							; run any instruction here to waste as few cycles as possible
		BRA $00								; let multiplication finish

		LDA $2307							;\
		STX $2253							; | x of link 1 + calc x of link 2
		CLC : ADC $E0							; |
		STA $E4								;/
		LDA $2307							;\
		LDX #$0038 : STX $2253						; | x of link 2 + calc x of ball
		CLC : ADC $E0							; |
		STA $E8								;/
		LDA $2307							;\
		CLC : ADC $E0							; | x of ball
		STA $EC								;/

		SEP #$30							; all regs 8-bit
		LDX !SpriteIndex						; X = sprite index


	.Graphics
		LDA $E4 : STA !SpriteXLo,x					;\
		LDA $E5 : STA !SpriteXHi,x					; |
		LDA $E6 : STA !SpriteYLo,x					; | draw link 1
		LDA $E7 : STA !SpriteYHi,x					; |
		JSL DRAW_SIMPLE_0						;/
		LDA $E8 : STA !SpriteXLo,x					;\
		LDA $E9 : STA !SpriteXHi,x					; |
		LDA $EA : STA !SpriteYLo,x					; | draw link 2
		LDA $EB : STA !SpriteYHi,x					; |
		JSL DRAW_SIMPLE_0						;/
		LDA $EC : STA !SpriteXLo,x					;\
		LDA $ED : STA !SpriteXHi,x					; |
		LDA $EE : STA !SpriteYLo,x					; |
		LDA $EF : STA !SpriteYHi,x					; | draw ball (can't load tilemap earlier since it will be shredded)
		REP #$20							; |
		LDA.b #.BallTilemap : STA $04					; |
		SEP #$20							; |
		JSL LOAD_PSUEDO_DYNAMIC						;/


	.Interaction
		JSL GetSpriteClippingE8						;\ interact with players
		JSL P2Standard							;/

		LDA !BallAndChainXLo,x : STA !SpriteXLo,x			;\
		LDA !BallAndChainXHi,x : STA !SpriteXHi,x			; | restore origin coords
		LDA !BallAndChainYLo,x : STA !SpriteYLo,x			; |
		LDA !BallAndChainYHi,x : STA !SpriteYHi,x			;/
		RTS



		.BallTilemap
		dw ..end-..start
		..start
		db $02,$F8,$F8,$02
		db $42,$08,$F8,$02
		db $82,$F8,$08,$02
		db $C2,$08,$08,$02
		..end


