
	RIPOSTE:
		PHB : PHK : PLB
		REP #$20						;\
		LDA.w #.FakeTable : STA $0E				; > rig this table to always read 0
		LDA.w #.Hitbox : JSL CORE_ATTACK_LoadHitbox		; |
		JSL CORE_ATTACK_ActivateHitbox1				; | riposte hitbox
		JSR Kadaal_HITBOX_GetClipping				; |
		REP #$20						; |
		LDA !P2Hitbox1IndexMem1 : TSB !P2Hitbox2IndexMem1	; > merge hitboxes
		SEP #$20						; |
		JSL CORE_ATTACK_ActivateHitbox2				; |
		JSR Kadaal_HITBOX_GetClipping				;/
		PLB
		RTL							; return


	.Hitbox
	dw $0008,$FFF4 : db $0F,$1F	; X/Y + W/H
	db $18,$E8			; speeds
	db $10				; timer
	db $00				; hitstun
	db $02,$00			; SFX
	dw $FFF9,$FFF4 : db $0F,$1F	; X/Y + W/H
	db $E8,$E8			; speeds
	db $10				; timer
	db $00				; hitstun
	db $02,$00			; SFX


	.FakeTable
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; 16 0x00 bytes

