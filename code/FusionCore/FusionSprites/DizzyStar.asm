
; data 1: 21--ssss
; 2	= attach to player 2
; 1	= attach to player 1
; ssss	= which sprite to attach to if not attached to player
;
; data 2: timer
; data 3: y offset to attachment



	DizzyStar:
		LDX !SpriteIndex

		.Timer
		LDA $14
		AND #$03 : BNE ..done
		DEC !Ex_Data2,x : BNE ..done
		..kill
		STZ !Ex_Num,x
		RTS
		..done

		LDA !Ex_Data1,x
		CMP #$10 : BCC .Sprite

	.Player
		AND #$80 : TAY
		LDA !StarTimer : BNE .Timer_kill
		LDA !P2Status-$80,y : BNE .Timer_kill
		LDA !P2XPosLo-$80,y : STA !Ex_XLo,x
		LDA !P2XPosHi-$80,y : STA !Ex_XHi,x
		STZ $00
		LDA !Ex_Data3,x
		BPL $02 : DEC $00
		CLC : ADC !P2YPosLo-$80,y
		STA !Ex_YLo,x
		LDA $00
		ADC !P2YPosHi-$80,y
		BRA .Graphics

	.Sprite
		AND #$0F : TAY
		LDA !SpriteStatus,y : BEQ .Timer_kill
		LDA !SpriteXLo,y : STA !Ex_XLo,x
		LDA !SpriteXHi,y : STA !Ex_XHi,x
		STZ $00
		LDA !Ex_Data3,x
		BPL $02 : DEC $00
		CLC : ADC !SpriteYLo,y
		STA !Ex_YLo,x
		LDA $00
		ADC !SpriteYHi,y

	.Graphics
		STA !Ex_YHi,x
		REP #$20
		STZ $0C
		JSR .Draw
		LDA #$0155 : STA $0C
		JSR .Draw
		LDA #$02AA : STA $0C
		JSR .Draw
		SEP #$30
		RTS


		.Draw
		LDA !Ex_XLo,x : STA $00
		LDA !Ex_XHi,x : STA $01
		LDA !Ex_YLo,x : STA $02
		LDA !Ex_YHi,x : STA $03
		REP #$20
		STZ $0E
		LDA $14
		LDY !Ex_Data2,x
		CPY #$40 : BCC +
		ASL A
	+	CPY #$20 : BCC +
		ASL A
	+	AND #$00FF
		ASL #2
		CLC : ADC $0C
		AND #$03FF
		STA $04				; angle
		CMP #$0200
		BCC $02 : DEC $0E
		AND #$01FE
		REP #$10
		TAX
		LDA.l !TrigTable,x
		EOR $0E
		BPL $01 : INC A
		CLC : ADC #$0100
		LSR #4
		CLC : ADC $00
		SEC : SBC #$000C
		SEC : SBC $1A
		STA $00
		CMP #$FFF8 : BCS .GoodX
		CMP #$0100 : BCC .GoodX
	.BadCoord
		SEP #$10
		REP #$20
		LDX !SpriteIndex
		RTS

	.GoodX	LDA $02
		SEC : SBC $1C
		CMP #$FFF8 : BCS .GoodY
		CMP #$00E0 : BCS .BadCoord

	.GoodY	SEP #$10
		LDY $05
		CPY #$01 : BEQ .HiPrio
		CPY #$02 : BEQ .HiPrio

	.LoPrio
		REP #$30
		PHA
		LDA !OAMindex_p1 : TAX
		LDA $00 : STA !OAM_p1+$000,x
		PLA : STA !OAM_p1+$001,x
		LDA #$344F : STA !OAM_p1+$002,x
		PHX
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $01
		AND #$01
		STA !OAMhi_p1+$00,x
		REP #$20
		PLA
		CLC : ADC #$0004
		STA !OAMindex_p1
		SEP #$10
		LDX !SpriteIndex
		RTS

	.HiPrio
		REP #$30
		PHA
		LDA !OAMindex_p3 : TAX
		LDA $00 : STA !OAM_p3+$000,x
		PLA : STA !OAM_p3+$001,x
		LDA #$344F : STA !OAM_p3+$002,x
		PHX
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $01
		AND #$01
		STA !OAMhi_p3+$00,x
		REP #$20
		PLA
		CLC : ADC #$0004
		STA !OAMindex_p3
		SEP #$10
		LDX !SpriteIndex
		RTS




