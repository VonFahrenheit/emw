


; this lets the big form of the dino breathe fire and fully enables the hitbox of the flame

	pushpc
	org $039D7A
		BRA $04 : NOP #4		; org: LDA !SpriteNum (dp indirect) : CMP #$6E : BEQ $1D (to RTS)
	org $039D8A
	DinoFireAttack:
		SEC : JSL !PlayerClipping
		BCC .Return
		JSL !HurtPlayers
		.Return
		RTS
; org:
;	JSL !GetP1Clipping
;	JSL !CheckContact
;	BCC .Return
;	LDA !StarTimer : BNE .Return
;	JSL !HurtMario
;	.Return
;	RTS
	warnpc $039D9E
	pullpc


