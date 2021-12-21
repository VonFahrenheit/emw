
; _W	index, lo byte
; _H	index, hi byte
; _Misc	memory bit




	Keyhole:
		LDX $00

		LDA !BG_object_X,x				;\
		STA $04						; |
		STA $09						; |
		LDA #$2010 : STA $06				; | clipping
		LDA !BG_object_Y,x				; |
		SEP #$20					; |
		STA $05						; |
		XBA : STA $0B					;/


		PHX
		LDA !BG_object_Misc,x : STA $02
		PHB : PHK : PLB
		REP #$20
		LDA $410000+!BG_object_W,x : BPL .CheckMem

		.NoMem
		LDA #$FFFF : STA $02
		LDA #$0000
		BRA .PushMem

		.CheckMem
		TAX
		SEP #$20
		LDA $02 : PHA					; push bit key
		LDA !ItemMem0,x
		AND $02						; A = item memory bit (current)
		STX $02						; $02 = item memory index

		.PushMem
		SEP #$30
		PHA						; push item memory bit
		PEI ($02)					; push item memory index
		SEC : JSL !PlayerClipping
		STA $00
		PLA : STA $0E					;\ $0E = item memory index (for keyhole, not key)
		PLA : STA $0F					;/


		.P1Check					;\
		LSR $00 : BCC ..done				; | player must be touching keyhole and be on ground
		LDA !P2InAir-$80 : BNE ..done			;/
		LDA $01,s : BEQ ..checkkey			;\
		LDA $6DA6					; | if door already unlocked, don't require key
		AND #$08 : BEQ ..done				; |
		JMP .EnterDoor_nomem				;/
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
		LDA $01,s : BEQ ..checkkey			;\
		LDA $6DA7					; | if door already unlocked, don't require key
		AND #$08 : BEQ ..done				; |
		BRA .EnterDoor_nomem				;/
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
		PLA : PLA					; pop 2 bytes

		REP #$30
		PLB
		PLX
		RTS

		.EnterDoor					;\
		LDA #$04 : STA $3230,x				; | puff key
		LDA #$1F : STA $32D0,x				;/
		LDA !ExtraProp2,x				;\
		AND #$03					; | check if key has an item mem bit
		CMP #$03 : BEQ ..nomem				;/
		XBA						;\
		LDA !ExtraProp2,x				; |
		LSR #2						; |
		AND #$07 : TAY					; |
		LDA #$01					; | unpack item memory bit
		..loop						; |
		DEY : BMI ..thisbit				; |
		ASL A : BRA ..loop				; |
		..thisbit					; |
		STA $02						;/
		LDA !ExtraProp1,x				;\
		REP #$30					; |
		TAX						; |
		SEP #$20					; | set item memory bit for key
		LDA $02						; |
		ORA !ItemMem0,x : STA !ItemMem0,x		; |
		SEP #$30					;/
		..nomem						;\
		REP #$10					; |
		LDX $0E : BMI ..nokeyholemem			; | set item memory bit for keyhole
		LDA $02,s					; |
		ORA !ItemMem0,x : STA !ItemMem0,x		;/
		..nokeyholemem					;\
		LDA #$0F : STA !SPC4				; > door sfx
		LDA #$06 : STA $71				; | start door transition
		STZ $88						; |
		STZ $89						; |
		BRA .Return					;/


