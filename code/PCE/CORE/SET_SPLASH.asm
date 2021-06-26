;==========;
;SET_SPLASH;
;==========;
	SET_SPLASH:
		REP #$20
		LDA !P2XSpeed
		AND #$00FF
		LSR #4
		CMP #$0008
		BCC $03 : ORA #$FFF0
		CLC : ADC !P2XPos
		STA $00

		LDY #$06
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC !P2YPos
		AND #$FFF0
		STA $02
		SEP #$20

		%Ex_Index_Y()
		LDA #$07+!MinorOffset : STA !Ex_Num,y		; Smoke sprite to spawn
		LDA #$00 : STA !Ex_Data1,y			; Show glitter sprite for 16 frames
		LDA !P2XPosLo					;\
		STA !Ex_XLo,y					; | Spawn at player X + 8 pixels
		LDA !P2XPosHi					; | (include hi byte for FusionCore 1.2+)
		STA !Ex_XHi,y					;/
		LDA $02						;\
		STA !Ex_YLo,y					; | Spawn at player Y + 8 pixels
		LDA $03						; | (include hi byte for FusionCore 1.2+)
		STA !Ex_YHi,y					;/
		RTL

.Bubble		LDX #$07
		LDA $02
		SEC : SBC #$05
		STA $02
		BCS $02 : DEC $03

	..loop	%Ex_Index_Y()
		LDA #$12+!ExtendedOffset : STA !Ex_Num,y	; bubble num
		LDA #$00
		STA !Ex_Data1,y
		STA !Ex_Data2,y
		STA !Ex_Data3,y

		LDA $00
		CLC : ADC.l $00F388+$0B,x
		STA !Ex_XLo,y
		LDA $01
		ADC #$00
		STA !Ex_XHi,y
		LDA $02
		CLC : ADC.l $00F388+$03,x
		STA !Ex_YLo,y
		LDA $03
		ADC #$00
		STA !Ex_YHi,y
		DEX : BPL ..loop

		RTL


