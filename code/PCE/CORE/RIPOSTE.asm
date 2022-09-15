
	RIPOSTE:
		LDA !P2Hitbox1W						;\ riposte can't overwrite other attacks
		ORA !P2Hitbox1H : BNE .Return				;/

		PHB : PHK : PLB						;\
		REP #$20						; | riposte hitbox
		LDA.w #.Hitbox : JSL CORE_ATTACK_LoadHitbox		; |
		PLB							;/

		.Return
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



