
	MarioFireball:
		LDX !SpriteIndex

		JSR ApplySpeed
		.Gravity
		LDA !Ex_YSpeed,x : BMI ..acc
		CMP #$40 : BCS ..done
		..acc
		INC !Ex_YSpeed,x
		INC !Ex_YSpeed,x
		INC !Ex_YSpeed,x
		..done

		JSR DestroyAtWall

		.CheckFloor
		LDA !Ex_YLo,x
		CLC : ADC #$0E
		STA $98
		LDA !Ex_YHi,x
		ADC #$00
		STA $99
		LDA !Ex_XSpeed,x
		LDA !Ex_XHi,x : XBA
		LDA !Ex_XLo,x
		PHX
		REP #$30
		STA $9A
		JSL GetMap16_Tile
		PLX
		CMP #$0100
		SEP #$30
		BCC ..done

		CMP #$11 : BCC ..platform		; platform: check y position within tile
		CMP #$D8 : BCS ..bounce			; slope assist: always bounce
		CMP #$6E : BCC ..bounce			; full solid: always bounce

		..slope					;\
		LDY #$32 : STY $F0			; | $F0 = 24-bit pointer to slope coordinate table ($00E632)
		LDY #$E6 : STY $F1			; |
		STZ $F2					;/
		SEC : SBC #$6E				;\
		TAY					; |
		LDA [$82],y				; |
		ASL #4 : STA $05			; |
		BCC $02 : INC $F1			; | get index to pushout value
		LDA $9A					; |
		AND #$0F : ORA $05			; |
		TAY					;/
		LDA [$F0],y				;\ check for invalid slope
		CMP #$10 : BEQ ..done			;/
		BCS ..bounce				; bounce if slope assist
		LDA $98					;\
		AND #$0F				; |
		CMP #$0C : BCS ..bounce			; | see if can bounce
		CMP [$F0],y : BCS ..bounce		; |
		BRA ..done				;/

		..platform				;\
		LDA $98					; | platform: check y position within tile
		AND #$0F				; |
		CMP #$06 : BCS ..done			;/
		..bounce				;\ bounce
		LDA #$D0 : STA !Ex_YSpeed,x		;/
		..done

		JSR DrawExSprite
		dw !GFX_ReznorFireball_offset
		db $00,$73

		RTS






