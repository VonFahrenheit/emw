

	TrashCan:
		LDX $00

		PHB
		PHX
		PHP
		LDA !BG_object_X,x : STA $9A
		LDA !BG_object_Y,x : STA $98


		.HitboxInteraction
		LDA !BG_object_Misc,x
		AND #$00FF : BNE .BodyInteraction
		JSR CheckHitbox : BCC .BodyInteraction
		PHB : PHK : PLB
		LDA !P2Hitbox1XSpeed-$80,y
		AND #$00FF
		PEA.w ..done-1
		PHA						; dummy push
		PHX
		JMP .KnockOver_main
		..done
		PLB
		LDA !BG_object_Misc,x
		ORA #$0001
		STA !BG_object_Misc,x



		.BodyInteraction
		LDA !BG_object_X,x				;\
		STA $04						; |
		STA $09						; |
		LDA !BG_object_Y,x				; |
		CLC : ADC #$0008				; |
		SEP #$20					; | clipping
		STA $05						; |
		XBA : STA $0B					; |
		LDA !BG_object_W,x				; |
		ASL #3						; |
		STA $06						; |
		LDA #$01 : STA $07				;/
		SEP #$30

		PHK : PLB
		SEC : JSL !PlayerClipping
		PLP
		PLX
		STA $00
		SEP #$20

		.InteractP1					;\ check for player 1 contact
		LSR $00 : BCC ..done				;/
		LDA $410000+!BG_object_Misc,x : BNE ..stand	; bounce / stand check
		..bounce					;\
		LDA !P2InAir-$80 : BEQ ..done			; |
		LDA !P2YSpeed-$80 : BMI ..done			; |
		STA $02						; |
		LDA !P2XSpeed-$80 : STA $0E			; > speed for knockover animation
		LDA !P2XPosLo-$80 : JSR .GetSpeed		; |
		CLC : ADC !P2XSpeed-$80				; |
		STA !P2XSpeed-$80				; |
		LDA $02 : STA !P2YSpeed-$80			; |
		LDY !P2Character-$80-1				; > mario check
		CPY #$0100 : BCS +				; |
		STA !MarioYSpeed				; |
		LDA !P2XSpeed-$80 : STA !MarioXSpeed		; |
	+	JSR .KnockOver					; |
		BRA ..done					;/
		..stand						;\
		LDA !P2YSpeed-$80 : BMI ..done			; | player must be moving down onto object to stand on it
		LDA !P2BlockedLayer-$80				; |
		AND #$04 : BNE ..done				;/
		LDA #$10 : STA !P2YSpeed-$80			;\
		LDA #$04 : TSB !P2ExtraBlock-$80		; |
		REP #$20					; |
		LDA $410000+!BG_object_Y,x			; | stand on object code
		AND #$FFF0					; |
		ORA #$0002					; |
		STA !P2YPosLo-$80				; |
		LDY !P2Character-$80-1				; > mario check
		CPY #$0100 : BCS ..done				; |
		SEC : SBC #$0010				; |
		STA !MarioYPosLo				; |
		LDA #$0010 : STA !MarioYSpeed-1			; |
		..done						;/

		SEP #$20

		.InteractP2					;\ check for player 2 contact
		LSR $00 : BCC ..done				;/
		LDA $410000+!BG_object_Misc,x : BNE ..stand	; bounce / stand check
		..bounce					;\
		LDA !P2InAir : BEQ ..done			; |
		LDA !P2YSpeed : BMI ..done			; |
		STA $02						; |
		LDA !P2XSpeed-$80 : STA $0E			; > speed for knockover animation
		LDA !P2XPosLo : JSR .GetSpeed			; |
		CLC : ADC !P2XSpeed				; |
		STA !P2XSpeed					; |
		LDA $02 : STA !P2YSpeed				; |
		LDY !P2Character-1				; > mario check
		CPY #$0100 : BCS +				; |
		STA !MarioYSpeed				; |
		LDA !P2XSpeed : STA !MarioXSpeed		; |
	+	JSR .KnockOver					; |
		BRA ..done					;/
		..stand						;\
		LDA !P2YSpeed : BMI ..done			; | player must be moving down onto object to stand on it
		LDA !P2BlockedLayer				; |
		AND #$04 : BNE ..done				;/
		LDA #$10 : STA !P2YSpeed			;\
		LDA #$04 : TSB !P2ExtraBlock			; |
		REP #$20					; |
		LDA $410000+!BG_object_Y,x			; | stand on object code
		AND #$FFF0					; |
		ORA #$0002					; |
		STA !P2YPosLo					; |
		LDY !P2Character-1				; > mario check
		CPY #$0100 : BCS ..done				; |
		SEC : SBC #$0010				; |
		STA !MarioYPosLo				; |
		LDA #$0010 : STA !MarioYSpeed-1			; |
		..done						;/

		PLB
		REP #$30
		RTS


	.KnockOver
		PEI ($00)
		LDA #$01 : STA $410000+!BG_object_Misc,x
		PHX
		REP #$20
		LDA $0E
		AND #$00FF
		..main
		CMP #$0080 : BCS ..knockleft
		..knockright
		LDA #$0025 : JSL !ChangeMap16
		LDA $98
		CLC : ADC #$0010
		STA $98
		LDA #$0381 : JSL !ChangeMap16
		LDA $9A
		CLC : ADC #$0010
		STA $9A
		LDA #$0382 : JSL !ChangeMap16
		PLX
		PLA : STA $00
		RTS
		..knockleft
		LDA #$0025 : JSL !ChangeMap16
		LDA $98
		CLC : ADC #$0010
		STA $98
		LDA #$0371 : JSL !ChangeMap16
		LDA $9A
		SEC : SBC #$0010
		STA $9A
		LDA #$0382 : JSL !ChangeMap16
		PLX
		PLA : STA $00
		RTS


; input:
;	A = player X pos
;	$02 = Y speed
; output:
;	A = X speed bonus
;	$02 = Y speed (total)

	.GetSpeed
		CLC : ADC #$08
		SEC : SBC $410000+!BG_object_X,x
		BPL $02 : LDA #$00
		CMP #$0F
		BCC $02 : LDA #$0F
		XBA						;\ emu compat: clear B
		LDA #$00 : XBA					;/
		TAY
		LDA $02
		EOR #$FF : INC A
		CLC : ADC ..speedtableY,y
		STA $02
		LDA ..speedtableX,y
		RTS

		..speedtableX
		db $E4,$E8,$EC,$F0,$F4,$F8,$FC,$00
		db $00,$04,$08,$0C,$10,$14,$18,$1C

		..speedtableY
		db $10,$0E,$0B,$06,$00,$F4,$E8,$E0
		db $E0,$E8,$F4,$00,$06,$0B,$0E,$10




