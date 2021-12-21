

	KEY_MAIN:
		PHB : PHK : PLB

		LDA $3230,x				;\
		CMP #$08 : BNE +			; | state 08 -> 09
		LDA #$09 : STA $3230,x			; |
		+					;/



; prop 1:
;	lo byte of index
; prop 2:
;	FF-bbbhh
;	  h - hi bits of index (0 and 1 are valid, 3 is invalid)
;	  b - which bit is used (0 = 01, 1 = 02, 2 = 04, etc, to 7 = 80)

		LDA !ExtraBits,x : BMI .Main		;\
		.Init					; |
		ORA #$80 : STA !ExtraBits,x		; |
		JSL GetItemMem : BEQ ..valid		; | init: kill if already used
		..kill					; |
		STZ $3230,x				; |
		BRA .Return				;/
		..valid					;\
		LDA !HeaderItemMem			; |
		CMP #$03 : BCC ..setmem			; |
		LDA !ExtraProp2,x			; | if spawning (note: only triggers in original level) with header = 3, mark invalid item mem
		AND #$C0				; |
		ORA #$03 : STA !ExtraProp2,x		; |
		BRA .Main				;/
		..setmem				;\
		LDY #$00				; |
		LDA $02					; |
		..loop					; |
		LSR A : BEQ ..setbit			; | crunch memory bit
		INY : BRA ..loop			; |
		..setbit				; |
		TYA					; |
		ASL #2					; |
		STA $02					;/
		LDA $00 : STA !ExtraProp1,x		;\
		LDA !ExtraProp2,x			; |
		AND #$C0				; | store item memory index + bit
		ORA $01					; |
		ORA $02					; |
		STA !ExtraProp2,x			;/
		.Main					;\
		REP #$20				; |
		LDA.w #.TM : STA $04			; | main: draw
		SEP #$20				; |
		JSL SETUP_CARRIED			; |
		JSL DRAW_CARRIED			;/

		.Return
		PLB
		RTL

		.TM
		dw $0004
		db $02,$00,$00,$00


	KEYHOLE_MAIN:
		JSL GetItemMem
		; $02 = 0, spawn locked door
		; $02 != 0, spawn unlocked door

		PHB
		LDA #$41
		PHA : PLB
		REP #$30
		LDY #$0000

		.Loop
		LDA !BG_object_Type,y
		AND #$00FF : BNE .Next
		SEP #$20
		LDA #$07 : STA !BG_object_Type,y
		LDA.l !SpriteXLo,x : STA !BG_object_XLo,y
		LDA.l !SpriteXHi,x : STA !BG_object_XHi,y
		LDA.l !SpriteYLo,x : STA !BG_object_YLo,y
		LDA.l !SpriteYHi,x : STA !BG_object_YHi,y
		LDA $02 : STA !BG_object_Misc,y			;\
		LDA $00 : STA !BG_object_W,y			; |
		LDA $01 : STA !BG_object_H,y			;/
		LDA !HeaderItemMem
		CMP #$03 : BCC .Return
		LDA #$FF : STA !BG_object_H,y			; mark as invalid if item mem >= 3
		BRA .Return

		.Next
		TYA
		CLC : ADC.w #!BG_object_Size
		TAY
		CPY.w #(!BG_object_Size)*(!BG_object_Count) : BCC .Loop

		.Return
		SEP #$30
		PLB
		.Kill
		STZ $3230,x
		PHX
		LDA $33F0,x : TAX
		LDA #$EE : STA !SpriteLoadStatus,x
		PLX
		RTL












