


	OverworldSprites:

		LDX #$0000
		LDA !OW_sprite_Num,x
		AND #$007F : BEQ .Next
		CMP.w #(.List_end-.List-1)*2 : BCS .Next
		ASL A
		PEA.w .Next-1
		PHX
		TAX
		JMP (.List-2,x)

		.Next
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CPX.w #!OW_sprite_Size*1 : BCS .Done



		.Done
		RTS


		.List
		dw WarpPipe		; 01
		..end


incsrc "Sprites/WarpPipe.asm"




	SpriteSpeed:
		REP #$20
		LDY #$0000
		LDA !OW_sprite_XSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_XFraction,x
		STA !OW_sprite_XFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_X+1,x
		STA !OW_sprite_X+1,x
		REP #$20
		LDY #$0000
		LDA !OW_sprite_YSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_YFraction,x
		STA !OW_sprite_YFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_Y+1,x
		STA !OW_sprite_Y+1,x
		REP #$20
		LDY #$0000
		LDA !OW_sprite_ZSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_ZFraction,x
		STA !OW_sprite_ZFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_Z+1,x
		STA !OW_sprite_Z+1,x
		RTS


; $00	on-screen X (sprite)
; $02	on-screen Y (sprite, includes Z axis)
; $04	pointer to tilemap
; $06	Xflip flag (sprite, 0x40)
; $08	tilemap byte count
; $0A	S bit flag (tile, 0x80)
; $0C	on-screen X (tile)
; $0E	pointer to S bit


	DrawSprite:
		STA $04
		CLC : ADC #$0005	; +4, +past header, points to first S bit
		STA $0E
		LDA !OW_sprite_X,x
		SEC : SBC $1A
		STA $00
		LDA !OW_sprite_Y,x
		SEC : SBC $1C
		STA $0C
		SEC : SBC !OW_sprite_Z,x
		STA $02
		LDA !OW_sprite_Direction,x
		AND #$0001
		BEQ $03 : LDA #$0040
		EOR #$0040
		STA $06
		LDY #$0000
		LDA ($04)
		AND #$00FF : STA $08
		INC $04
		PHX
		LDX !MapOAMindex
		STA !MapOAMdata+2,x
		LDA $0C : STA !MapOAMdata+0,x

		.Loop
		LDA ($0E),y
		AND #$0002
		BEQ $03 : LDA #$8000
		STA $0A
		LDA ($04),y
		INY
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		BIT $06-1 : BVC ..noflip
		EOR #$FFFF : INC A
		BIT $0A : BPL ..noflip
		CLC : ADC #$0008
		..noflip
		CLC : ADC $00
		CMP #$FFF0 : BCS .GoodX
		CMP #$0100 : BCC .GoodX
		.BadCoord
		INY #4
		CPY $08 : BCC .Loop
		BRA .Done
		.GoodX
		STA $0C
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$FFF0 : BCS .GoodY
		CMP #$00E0 : BCS .BadCoord
		.GoodY

		SEP #$20
		STA !MapOAMdata+5,x
		LDA $0C : STA !MapOAMdata+4,x
		INY
		LDA ($04),y : STA !MapOAMdata+6,x
		INY
		LDA ($04),y
		EOR $06
		STA !MapOAMdata+7,x
		INY
		LDA $0D
		AND #$01
		ORA ($04),y
		STA !MapOAMdata+8,x
		INY
		REP #$20
		TXA
		CLC : ADC #$0005
		TAX
		CPY $08 : BCS .Done
		JMP .Loop

		.Done
		CPX !MapOAMindex : BEQ .Return
		TXA
		CLC : ADC #$0004
		STA !MapOAMindex
		INC !MapOAMcount

		.Return
		PLX
		RTS


; if returning carry is set, an index could not be found
; otherwise, X = index to a free sprite slot
	GetSpriteIndex:
		PHP
		REP #$30
		LDX #$0000
		.Loop
		LDA !OW_sprite_Num,x
		AND #$00FF : BEQ .ThisOne
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CMP.w #(!OW_sprite_Size)*1 : BCC .Loop
		PLP
		SEC
		RTS

		.ThisOne
		PLP
		CLC
		RTS


; does not reset num or coords, those should be set separately
	ResetSprite:
		PHP
		SEP #$20
		STZ !OW_sprite_Timer,x
		STZ !OW_sprite_Anim,x
		STZ !OW_sprite_AnimTimer,x
		STZ !OW_sprite_XFraction,x
		STZ !OW_sprite_YFraction,x
		STZ !OW_sprite_ZFraction,x
		STZ !OW_sprite_XSpeed,x
		STZ !OW_sprite_YSpeed,x
		STZ !OW_sprite_ZSpeed,x
		STZ !OW_sprite_Direction,x
		PLP
		RTS












