;=====================;
; GFX UPDATE ROUTINES ;
;=====================;

; input:
;	Y = file index
;	$02 = 16-bit VRAM offset (same format as !GFX_status)
;	$0C = 16-bit dynamo pointer
;
; _NoOffset version clears $02
; _NoFile version clears !FileAddress
; _Raw version clears both $02 and !FileAddress

; output: void

; NOTE:
; i repeat: $02 is number of TILES to add
; this means that !GFX_status can be written here directly
	UpdateGFX:
		PHX
		PHP
		REP #$20

	.GetFile
		JSL GetFileAddress

	.Main
		JSL GetVRAM
		REP #$30
		LDA $02					;\
		ASL #4					; | calculating this here is faster
		STA $02					;/
		LDA $0C : BEQ .Return			; return if dynamo is empty
		LDA ($0C) : BEQ .Return			; return if size is 0
		STA $00
		LDY #$0000
		INC $0C
		INC $0C
		..loop
		LDA ($0C),y
		STA !VRAMbase+!VRAMtable+$00,x
		INY #2
		LDA ($0C),y
		INY #2
		CLC : ADC !FileAddress
		STA !VRAMbase+!VRAMtable+$02,x
		LDA ($0C),y
		ADC !FileAddress+2
		STA !VRAMbase+!VRAMtable+$04,x
		INY
		LDA ($0C),y
		CLC : ADC $02
		STA !VRAMbase+!VRAMtable+$05,x
		INY #2
		CPY $00 : BCS .Return
		TXA
		CLC : ADC #$0007
		TAX
		BRA ..loop

		.Return
		PLP
		PLX
		RTL

	.NoOffset
		PHX
		PHP
		REP #$20
		STZ $02
		BRA .GetFile

	.NoFile
		PHX
		PHP
		REP #$20
		STZ !FileAddress
		STZ !FileAddress+1
		BRA .Main

	.Raw
		PHX
		PHP
		REP #$20
		STZ $02
		STZ !FileAddress
		STZ !FileAddress+1
		BRA .Main

