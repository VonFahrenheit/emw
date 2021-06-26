



	BG_OBJECTS:


; method:
;	loop through list of objects
;		- update timers
;		- run interaction
;		- queue VRAM uploads


		PHB
		PHP
		SEP #$20
		LDA #$41
		PHA : PLB
		REP #$30
		LDX #$0000
	.Loop	LDA !BG_object_Type,x
		AND #$00FF : BEQ .Next
		LDA !BG_object_X,x			;\
		SBC $1A					; |
		ADC #$0100				; |
		CMP #$0300 : BCS .Next			; | must be within this distance
		LDA !BG_object_Y,x			; | precision not important, this is just to save cycles
		SBC $1C					; |
		ADC #$0100				; |
		CMP #$0300 : BCS .Next			;/
		JSR Bush

	.Next	TXA
		CLC : ADC.w #!BG_object_Size
		TAX
		DEY : BPL .Loop

		PLP
		PLB
		RTS


;
; bush
; tall grass
; windows
;
;



	Bush:
		LDA !BG_object_Timer,x			;\ see which code to run
		AND #$00FF : BNE .HandleAnimation	;/

		.CheckInteract
		LDA !BG_object_X,x			;\
		STA $04					; |
		STA $09					; |
		LDA !BG_object_Y,x			; |
		SEP #$20				; |
		STA $05					; |
		XBA : STA $0B				; | clipping
		LDA !BG_object_W,x			; |
		ASL #3					; |
		STA $06					; |
		LDA !BG_object_H,x			; |
		ASL #3					; |
		STA $07					;/

		PHX					;\
		PHB : PHK : PLB				; | setup
		SEP #$30				;/
		CLC					;\
		LDA #$00				; |
		JSL !PlayerClipping			; | player 1 contact
		JSL !CheckContact			; |
		BCC +					; |
		LDA !P2XSpeed-$80 : BNE .Interact	;/
	+	CLC					;\
		LDA #$01				; |
		JSL !PlayerClipping			; | player 2 contact
		JSL !CheckContact			; |
		BCC +					; |
		LDA !P2XSpeed : BNE .Interact		;/
	+	LDX #$0F				;\
	-	LDA $3230,x : BEQ +			; |
		JSL !GetSpriteClipping00		; |
		JSL !CheckContact			; | sprite contact
		BCC +					; |
		LDA !SpriteXSpeed,x : BNE .Interact	; |
	+	DEX : BPL -				;/
		REP #$30				;\
		PLB					; | restore and return
		PLX					; |
		RTS					;/

		.Interact				;\
		REP #$10				; |
	;	LDA #$00 : STA !SPC1			; > bush SFX
		PLB					; | start animation
		PLX					; |
		LDA #$0F : STA !BG_object_Timer,x	; |
		REP #$20				; |
		RTS					;/



		.HandleAnimation
		SEP #$20
		DEC !BG_object_Timer,x
		REP #$20
		PHX
		AND #$00FF
		ASL A
		TAX
		LDA.l .TilePointer,x : STA $00
		PLX


; translate position into tilemap address
; 	then upload row by row

; $00:	16-bit pointer to tilemap data
; $02:	current VRAM Y address
; $04:	starting VRAM X address
; $06:	current VRAM X address
; $08:	ending VRAM X address
; $0A:	width
; $0C:	ending VRAM Y address
; $0E:	location on page 3





		.TileUpdate
		LDA !BG_object_X,x				;\
		LSR #3						; |
		AND #$003F					; |
		BIT #$0020					; | base VRAM X address
		BEQ $03 : ORA #$0400				; |
		AND #$041F					; |
		STA $04						;/
		LDA !BG_object_Y,x				;\
		AND #$00F8					; | base VRAM Y address
		ASL #2						; |
		STA $02						;/
		LDA !BG_object_W,x				;\ W VRAM offset
		AND #$00FF : STA $0A				;/
		CLC : ADC $04					;\
		LDY $04						; |
		CPY #$0400 : BCC ..000				; | ending X address
	..400	CMP #$0420 : BCS ..420				; | (account for double tilemap)
		BRA +						; |
	..000	CMP #$0020 : BCC +				;/
	..420	EOR #$0420					; 0x420 flip baybeeee
	+	STA $08						; store ending X adddress
		LDA !BG_object_H,x				;\
		AND #$00FF					; |
		ASL #5						; | ending Y address
		ADC $02						; |
		STA $0C						;/

; if...
; $04 < 400
; $08 < 20
;	-> do nothing
;
; $04 < 400
; $08 > 20
;	-> EOR #$0420 on $08
;
; $04 > 400
; $08 > 420
;	-> EOR #$0420 on $08
;
; $04 > 400
; $08 < 420
;	-> do nothing


		LDA #$0300 : STA $0E
		; HERE: GET LOCATION ON PAGE 3
		; STORE TO $0E (tttttttt + ------tt)

		PHX
		PHB : PHK : PLB

		LDY #$0000
		LDA !VRAMbase+!TileUpdateTable : TAX

		LDA $04 : STA $06				; start new row
	.Loop	LDA $06						;\
		ORA $02						; | write VRAM address
		ORA !BG1Address					; |
		STA !VRAMbase+!TileUpdateTable+2,x		;/
		LDA $06						;\ increment address
		INC A						;/
		CMP #$0020 : BEQ ..400				;\
		CMP #$0420 : BNE +				; | wrap between tilemaps
	..000	LDA #$0000 : BRA +				; |
	..400	LDA #$0400					;/
	+	CMP $08 : BNE +					;\
		LDA $02						; |
		CLC : ADC #$0020				; |
		AND #$03E0					; | if at the end, start a new row
		STA $02						; |
		LDA $04						; |
	+	STA $06						;/
		LDA ($00),y					;\
		CLC : ADC $0E					; | tile number + yxpccctt
		STA !VRAMbase+!TileUpdateTable+4,x		;/
		INY #2						; increment read index
		INX #4						; increment write index

		LDA $02						;\ if at the end, done
		CMP $0C : BEQ .Done				;/
		BRA .Loop					; loop

		.Done
		TXA : STA !VRAMbase+!TileUpdateTable		; update header for tile update table


		PLB
		PLX

		RTS




		.TilePointer
		dw .Bush0
		dw .Bush1
		dw .Bush2
		dw .Bush3
		dw .Bush4
		dw .Bush5
		dw .Bush6
		dw .Bush7
		dw .Bush8
		dw .Bush9
		dw .BushA
		dw .BushB
		dw .BushC
		dw .BushD
		dw .BushE
		dw .BushF


		.Bush0
		.Bush1
		.Bush2
		.Bush3
		dw $3400,$3401,$3402,$3403
		dw $3410,$3411,$3412,$3413
		.Bush4
		.Bush5
		.Bush6
		.Bush7
		dw $3404,$3405,$3406,$3407
		dw $3414,$3415,$3416,$3417
		.Bush8
		.Bush9
		.BushA
		.BushB
		dw $3408,$3409,$340A,$340B
		dw $3418,$3419,$341A,$341B
		.BushC
		.BushD
		.BushE
		.BushF
		dw $3404,$3405,$3406,$3407
		dw $3414,$3415,$3416,$3417









