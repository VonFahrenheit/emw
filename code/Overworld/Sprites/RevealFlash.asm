

; timer = event num


	RevealFlash:
		PLX

		INC !MapLockCamera		; camera can't move while an event is running
		INC !MapEvent

		LDA !CircleRadius
		AND #$00FF
		CMP #$0030 : BEQ $03 : JMP .Return

		.ControlCamera
		JSR SpriteCamera : BNE .Return

		.HandleAnim
		SEP #$20

		LDA !OW_sprite_AnimTimer,x
		INC A
		CMP #$04 : BNE ..same
		LDA !OW_sprite_Anim,x
		INC A : STA !OW_sprite_Anim,x
		CMP #$04 : BEQ .LoadEvent

		..noevent
		CMP #$08 : BNE ..next
		STZ !OW_sprite_Num,x
		REP #$20
		RTS
		..next
		LDA #$00
		..same
		STA !OW_sprite_AnimTimer,x
		REP #$20
		LDA !OW_sprite_Anim,x
		AND #$00FF
		ASL A : TAY
		LDA .Ptr,y : STA !OW_sprite_Tilemap,x

		.Return
		RTS


		.LoadEvent
		REP #$20
		LDA !OW_sprite_X,x : STA $00
		LDA !OW_sprite_Y,x : STA $02
		LDA !OW_sprite_Timer,x			;\ update tilemap (VRAM)
		AND #$00FF : JSR RealTimeEvent		;/
		SEP #$20
		LDA #$22 : STA !SPC4			; SFX
		LDA #$40 : STA !MapCameraTimer		; lock camera for 1 second
		BRA .HandleAnim_next



	.Ptr
	dw $0000
	dw .Tilemap1
	dw .Tilemap2
	dw .Tilemap3
	dw .Tilemap4
	dw .Tilemap3
	dw .Tilemap2
	dw .Tilemap1

	.Tilemap1
	db ..end-..start
	..start
	db $F8,$F8,$98,$1E,$02
	db $08,$F8,$98,$5E,$02
	db $F8,$08,$98,$9E,$02
	db $08,$08,$98,$DE,$02
	..end

	.Tilemap2
	db ..end-..start
	..start
	db $F8,$F8,$96,$1E,$02
	db $08,$F8,$96,$5E,$02
	db $F8,$08,$96,$9E,$02
	db $08,$08,$96,$DE,$02
	..end

	.Tilemap3
	db ..end-..start
	..start
	db $F8,$F8,$94,$1E,$02
	db $08,$F8,$94,$5E,$02
	db $F8,$08,$94,$9E,$02
	db $08,$08,$94,$DE,$02
	..end

	.Tilemap4
	db ..end-..start
	..start
	db $F8,$F8,$92,$1E,$02
	db $08,$F8,$92,$5E,$02
	db $F8,$08,$92,$9E,$02
	db $08,$08,$92,$DE,$02
	..end




; input:
;	A = event number
;	$00 = x position
;	$02 = y position
; output:
;	$0C = tilemap index
;	$0E = event data pointer

	RealTimeEvent:

		PHX					; push sprite index

		PEI ($00)				;\ push coords
		PEI ($02)				;/
		PHA					; push event number

		ASL A					;\
		TAY					; | pointer to event data
		LDA EventTable_Ptr-2,y : STA $0E	;/
		LDY #$0002				;\ w (hijack diagonal setting)
		LDA ($0E),y : STA.l !zipdiagonalsize	;/
		LDY #$0004				;\ h
		LDA ($0E),y : STA.l !ziploopcache	;/

		.Decrement				;\
		PHB					; |
		PEA $4141 : PLB : PLB			; |
		STZ.w !zipdiagonaloffsetinc		; > no offsets
		STZ.w !zipdiagonaloffsetdec		; |
		LDA.w !ziploopcache : STA.w !ziploop	; |
		..loop					; |
		STZ $04					; | unload previous tiles
		PEI ($00)				; |
		PEI ($02)				; |
		JSR HandleZips_Decrement		; |
		PLA					; |
		CLC : ADC #$0008			; |
		STA $02					; |
		PLA : STA $00				; |
		DEC.w !ziploop : BNE ..loop		; |
		PLB					;/

		PLA : JSR LoadEvent			; update tilemap (RAM)
		PLA : STA $02				;\ restore coords
		PLA : STA $00				;/

		.Increment				;\
		PHB					; |
		PEA $4141 : PLB : PLB			; |
		LDA.w !ziploopcache : STA.w !ziploop	; |
		..loop					; |
		STZ $04					; |
		PEI ($00)				; | tally new tiles
		PEI ($02)				; |
		JSR HandleZips_Increment		; > tally new tiles
		JSR .LoadGFX				; > convert to proper nums

		LDA !VRAMbase+!TileUpdateTable+0 : TAX
		LDY #$0000
	-	CPY.w !zipbuffer+0 : BCS ..next
		LDA.w !zipbuffer+2 : STA !VRAMbase+!TileUpdateTable+2,x
		INC.w !zipbuffer+2
		LDA.w !zipbuffer+4,y : STA !VRAMbase+!TileUpdateTable+4,x
		INX #4
		INY #2
		BRA -
		..next
		TXA : STA !VRAMbase+!TileUpdateTable+0
		STZ.w !zipbuffer+0

		PLA					; |
		CLC : ADC #$0008			; |
		STA $02					; |
		PLA : STA $00				; |
		DEC.w !ziploop : BNE ..loop		;/

		.UpdateTilemap				;\
		JSR HandleZips_Convert			; | update tileset (VRAM)
		PLB					;/

		PLX					; restore sprite index
		RTS					; return



	.LoadGFX
		LDY #$01FE : STY $0C

		TAY
		DEY #2

		..loop
		LDA.w !zipbuffer+4,y : STA $04
		AND #$03FF^$FFFF : STA $06
		LDA $04
		AND #$03FF
		ASL A
		TAX
		LDA.w !tileaddress,x : BPL ..loaded

		..findvram
		PHY
		LDY $0C
	-	LDA.w !vramalloc,y : BMI ..thisone
		DEY #2 : BPL -
		BRK							; crash upon overflow to make sure i catch it

		..thisone
		TYA
		LSR A
		STA.w !tileaddress,x
		TXA
		LSR A
		STA.w !vramalloc,y
		DEY #2
		STY $0C
		LDY.w !loadindex
		ASL #7
		SEC
		ROR A
		STA.w !loadbuffer+0,y
		CPX #$0200*2 : BCS ..secondbank
		..firstbank
		LDA #$003D : BRA ..setbank				; > hardcoded for speedup
		..secondbank
		; opcode here
		..setbank
		STA.w !loadbuffer+2,y
		LDA $0C
		INC #2
		ASL #4
		STA.w !loadbuffer+3,y
		TYA
		CLC : ADC #$0005
		STA.w !loadindex
		PLY
		LDA $0C
		LSR A
		INC A
		..loaded
		ORA $06
		STA.w !zipbuffer+4,y
		DEY #2 : BPL ..loop
		RTS





