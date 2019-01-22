

pushpc
org $01E2FE
	JSL MoleExtra_Wait	; > Source : BEQ $02 ($01E302) : LDA #$20

org $01E339
	JSL MoleExtra		; > Source: STA $99 : LDA #$08
pullpc




	MoleExtra:
		STA $99				; > Original code
		LDA !ExtraBits,x		;\ Check extra bit
		AND #$04 : BEQ .Normal		;/
		LDA #$FF			;\ Don't respawn sprite
		STA $33F0,x			;/
		LDA #$01			;\ Generate empty space
		RTL				;/

		.Normal
		LDA #$08			;\ Generate mole hole
		RTL				;/


		.Wait
		BEQ .Return
		LDA !ExtraBits,x
		AND #$04 : BEQ .Short
		LDA #$C0
		RTL

		.Short
		LDA #$20

		.Return
		RTL




