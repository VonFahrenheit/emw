

; these are set during spawn (keyhole sprite)
; _W		index, lo byte
; _H		index, hi byte
; _Timer	memory bit

	Keyhole:
		LDX $00

		PHB						; push bank
		PHX						; push X
		LDA !BG_object_W,x : PHA			; push item memory index (neg = no index)
		LDA !BG_object_Timer,x : PHA			; push item memory bit key

		LDA !BG_object_X,x : STA $E8			;\
		LDA !BG_object_Y,x : STA $EA			; | clipping
		LDA #$0010 : STA $EC				; |
		LDA #$0020 : STA $EE				;/

		PHK : PLB					; switch bank

		SEP #$30					; all regs 8-bit
		JSL PlayerContact : STA $00			; check contact with players ($00 = contact bits)

		REP #$20
		PLA : STA $02					; $02 = item memory bit key
		PLA : STA $0E					;\ $0E = item memory index (neg = no index)
		BPL .CheckMem					;/
		.NoMem						;\ if negative, no mem
		LDA #$0000 : BRA .PrepMem			;/
		.CheckMem					;\
		TAX						; |
		SEP #$20					; | get item mem
		LDA $02						; |
		AND !ItemMem0,x					;/
		.PrepMem
		SEP #$30
		STA $04
		; $02 = item memory bit
		; $04 = item memory bit & item memory (0 if not set, $02 if set)
		; $0E = item memory index

		.P1Check					;\
		LSR $00 : BCC ..done				; | player must be touching keyhole and be on ground
		LDA !P2InAir-$80 : BNE ..done			;/
		LDA $04 : BEQ ..checkkey			;\
		LDA $6DA6					; | if door already unlocked, don't require key
		AND #$08 : BEQ ..done				; |
		BRA .EnterDoor_nodestroy			;/
		..checkkey					;\
		LDX !P2Carry-$80 : BEQ ..done			; |
		DEX						; |
		LDA !SpriteNum,x				; |
		CMP #$80 : BNE ..done				; | require key if door is locked
		LDA $6DA6					; |
		AND #$08 : BEQ ..done				; |
		STZ !P2Carry-$80				; |
		BRA .EnterDoor					; |
		..done						;/

		.P2Check					;\
		LSR $00 : BCC .Return				; | player must be touching keyhole and be on ground
		LDA !P2InAir : BNE .Return			;/
		LDA $04 : BEQ ..checkkey			;\
		LDA $6DA7					; | if door already unlocked, don't require key
		AND #$08 : BEQ .Return				; |
		BRA .EnterDoor_nodestroy			;/
		..checkkey					;\
		LDX !P2Carry : BEQ .Return			; |
		DEX						; |
		LDA !SpriteNum,x				; | require key if door is locked
		CMP #$80 : BNE .Return				; |
		LDA $6DA7					; |
		AND #$08 : BEQ .Return				; |
		STZ !P2Carry					;/

		.EnterDoor
		JSR UnlockObject
		..nodestroy
		LDA #$0F : STA !SPC4				; > door sfx
		INC $741A					; +1 door count
		BNE $03 : DEC $741A				; stay at 255 instead of wrapping around to 0
		LDA #$0F : STA !GameMode			; load level
		REP #$20					;\
		LDA $E8 : STA $94				; | handle exit num
		LDA $EA : STA $96				; |
		JSL TranslateOldExitNumber			;/

		.Return
		REP #$30					; all regs 16-bit
		PLX						; restore X
		PLB						; bank wrapper end
		RTS






