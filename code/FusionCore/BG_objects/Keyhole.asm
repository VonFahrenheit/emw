

; these are set during spawn (keyhole sprite)
; _W	index, lo byte
; _H	index, hi byte
; _Misc	memory bit

	Keyhole:
		LDX $00

		PHB						; push bank
		PHX						; push X
		LDA !BG_object_W,x : PHA			; push item memory index (neg = no index)
		LDA !BG_object_Misc,x : PHA			; push item memory bit key

		LDA !BG_object_Y,x				;\
		STA $05						; |
		STA $0B-1					; |
		LDA #$2010 : STA $06				; | clipping
		LDA !BG_object_X,x				; |
		STA $0A-1					; |
		SEP #$20					; |
		STA $04						;/


		PHK : PLB					; switch bank

		SEP #$30					; all regs 8-bit
		SEC : JSL !PlayerClipping			;\ check contact with players ($00 = contact bits)
		STA $00						;/

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
		LDA $3200,x					; |
		CMP #$80 : BNE ..done				; | require key if door is locked
		LDA $6DA6					; |
		AND #$08 : BEQ ..done				; |
		STZ !P2Carry-$80				; |
		BRA .EnterDoor					; |
		..done						;/

		.P2Check					;\
		LSR $00 : BCC ..done				; | player must be touching keyhole and be on ground
		LDA !P2InAir : BNE ..done			;/
		LDA $04 : BEQ ..checkkey			;\
		LDA $6DA7					; | if door already unlocked, don't require key
		AND #$08 : BEQ ..done				; |
		BRA .EnterDoor_nodestroy			;/
		..checkkey					;\
		LDX !P2Carry : BEQ ..done			; |
		DEX						; |
		LDA $3200,x					; |
		CMP #$80 : BNE ..done				; | require key if door is locked
		LDA $6DA7					; |
		AND #$08 : BEQ ..done				; |
		STZ !P2Carry					; |
		BRA .EnterDoor					; |
		..done						;/

		.Return
		REP #$30
		PLX						; restore X
		PLB						; bank wrapper end
		RTS


		.EnterDoor
		JSR UnlockObject
		..nodestroy
		LDA #$0F : STA !SPC4				; > door sfx
		LDA #$06 : STA $71				;\
		STZ $88						; | start door transition
		STZ $89						; |
		BRA .Return					;/




