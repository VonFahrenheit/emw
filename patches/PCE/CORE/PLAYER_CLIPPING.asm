; To load player 1 clipping, do:
;	CLC
;	LDA #$00
;	JSL !GetPlayerClipping
;
; To load player 2 clipping, do:
;	CLC
;	LDA #$01
;	JSL !GetPlayerClipping
;
; To check for contact, do:
;	SEC
;	JSL !GetPlayerClipping
;
; When checking for contact, the routine will compare the hitbox stored at $04-$07, $0A-$0B to player hitboxes.
; Upon returning, the routine will yield the following result:
;	Carry flag: set if contact is detected, otherwise clear
;	A: first bit set if P1 contact is detected, second bit set if P2 contact is detected
; To check for contact, a sprite can do:
;	JSL $03B69F
;	SEC : JSL !PlayerClipping
;	BCC .NoContact
;	LSR A : BCC .P2
;	.P1
;	;[code]
;	.P2
;	;[code]
;	.NoContact
;

	PlayerClipping:
		PHX				;\ Backup stuff
		PHB : PHK : PLB			;/
		BCS .Compare			;\ Split to different parts of routine based on input
		CMP #$00 : BNE +		;/
		PEA .End-1 : JMP .P1		; > Load P1 hitbox, then end
	+	PEA .End-1 : JMP .P2		; > Load P2 hitbox, then end

		.Compare
		LDX #$00			; < X = contact bits
		LDA !MultiPlayer : BEQ +
		LDA !Characters
		AND #$0F
		BNE ++
		LDA !P1Dead
		ORA $71
		BNE +
		BRA .P2Yes
	++	LDA !P2Status : BNE +
		LDA !P2Pipe : BNE +
	.P2Yes	PHX				; > Backup X
		JSR .P2				;\ Check for P2 contact
		JSL !Contact16			;/
		PLA				;\
		BCC $02 : LDA #$02		; | Mark P2 contact
		TAX				;/

	+	LDA !Characters
		AND #$F0
		BNE +
		LDA !P1Dead
		ORA $71
		BNE .Result
		BRA .P1Yes
	+	LDA !P2Status-$80 : BNE .Result
		LDA !P2Pipe-$80 : BNE .Result
	.P1Yes	PHX				; > Backup X
		JSR .P1				;\ Check for P1 contact
		JSL !Contact16			;/
		PLA				;\
		BCC $02 : ORA #$01		; | Mark P1 contact
		TAX				;/

		.Result
		CLC				; > Clear carry
		TXA				; > A = contact bits
		BEQ $01 : SEC			; > C = contact flag

		.End
		PLB
		PLX
		RTL


		.CharPointer
		dw $FFFF
		dw Luigi_ANIM
		dw Kadaal_ANIM
		dw Leeway_ANIM


		.P1
		LDA !Characters			;\
		LSR #4				; | P1 index
		ASL A				; |
		TAY				;/
		REP #$30			;\
		LDA !P2Anim-$80 : STA $F0	; | P1 setup
		LDA !P2XPosLo-$80 : STA $08	; |
		LDA !P2YPosLo-$80 : STA $02	;/
		BRA .ReadData			; > Write hitbox

		.P2
		LDA !Characters			;\
		AND #$0F			; | P2 index
		ASL A				; |
		TAY				;/
		REP #$30			;\
		LDA !P2Anim : STA $F0		; | P2 setup
		LDA !P2XPosLo : STA $08		; |
		LDA !P2YPosLo : STA $02		;/

		.ReadData
		LDA.w .CharPointer,y		;\
		CMP #$FFFF : BNE .PCE		; |
		SEP #$30			; | Get Mario clipping
		JSL !GetP1Clipping		; |
		RTS				;/

	.PCE	STA $00				;\
		LDA $F0				; |
		AND #$00FF			; | Get PCE clipping value
		ASL #3				; |
		CLC : ADC #$0006		; |
		TAY				;/
		LDA ($00),y			;\
		INC A				; < Get left X coordinate
		STA $F0				; | (Set up pointers to player clipping)
		CLC : ADC #$0006		; < Get upper Y coordinate
		STA $F2				; |
		CLC : ADC #$0002		; < Get pointer to second width
		STA $F4				;/
		LDA ($F0)			;\
		AND #$00FF			; |
		CMP #$0080			; |
		BCC $03 : ORA #$FF00		; | Player X coordinates
		CLC : ADC $08			; |
		STA $00				; |
		XBA : STA $08			;/
		LDA ($F2)			;\
		AND #$00FF			; |
		CMP #$0080			; |
		BCC $03 : ORA #$FF00		; | Player Y coordinates
		CLC : ADC $02			; |
		STA $01				; |
		SEP #$30			; |
		XBA : STA $09			;/
		LDA #$10			;\
		SEC : SBC $01			; | This arcane magic is player height
		CLC : ADC !P2YPosLo		; | (NEVER CHANGE THIS EVER)
		STA $03				;/
		LDY #$01			;\ Player width
		LDA #$10 : STA $02		;/
		RTS