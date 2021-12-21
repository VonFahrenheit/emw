


	!BoostThreshold		= $44



; timer
;	used to keep track of target y displacement
;
; _H
;	current y displacement
;
; tile
;	last used player contact offset
;
; misc
;	aaaaaa21
;	a - anim index
;	2 - contact with player 2
;	1 - contact with player 1
;



	Cable:


		; get update data for this cable
		LDA $52
		AND #$00FF
		DEC A
		STA $02
		ASL #2
		ADC $02
		TAX
		LDA !CableUpdateData+0,x : STA !CableUpdateMinus2
		LDA !CableUpdateData+2,x : STA !CableUpdate0
		LDA !CableUpdateData+3,x : STA !CableUpdatePlus1


		LDX $00



		.GetClipping
		PHX
		PHP
		LDA !BG_object_X,x				;\
		STA $04						; |
		STA $09						; |
		LDA !BG_object_H,x
		AND #$00FF
		CMP #$0080 : BCC +
		LDA #$FFE0 : BRA ++
	+	LDA #$FFFE
	++	CLC : ADC !BG_object_Y,x			; |
		SEP #$20					; |
		STA $05						; | clipping
		XBA : STA $0B					; |
		LDA !BG_object_W,x				; |
		ASL #3						; |
		BNE $01 : DEC A					; |
		STA $06						; |
		LDA !BG_object_H,x : BPL +
		LDA #$23 : BRA ++
	+	LDA #$05
	++	STA $07						;/

		.Timer
		LDA !BG_object_Timer,x : BEQ ..update
		DEC !BG_object_Timer,x
		BRA ..notimer

		..update
		REP #$30
		LDA !BG_object_Misc,x
		AND #$00FF : STA $0C
		AND #$00FC : TRB $0C
		STA $0E
		TAY
		INY
		LDA.w #.AnimTable+2 : STA $00
		LDA.w #.AnimTable>>16 : STA $02
		SEP #$20
		; B already clear due to >>16
		LDA [$00],y
		CMP $0E : BEQ ..notimer
		..nextanim
		STA $0E
		TAY
		LDA !BG_object_Misc,x
		AND #$03
		ORA $0E
		CPY #$0005*4 : BNE ..notlastboost		;\
		BIT #$03 : BNE ..invalid			; | go into bounce0 instead of boost0 if at least one player is still on the cable
		..notlastboost					;/
		BIT #$03 : BEQ ..valid				;\
		CMP #$04 : BCS ..valid				; |
		..invalid					; |
		LDA #$04					; | go into bounce0 instead of resting if at least one player is still on the cable
		ORA $0C						; |
		LDY #$0004					; |
		..valid						;/
		STA !BG_object_Misc,x
		LDA [$00],y : STA !BG_object_Timer,x
		..notimer


		.AdjustPositions				;\
		REP #$20					; | $02 = timer
		LDA !BG_object_Timer,x				; |
		AND #$00FF : STA $02				;/
		LDA !BG_object_Misc,x				;\
		AND #$00FF : STA $08				; | $04 = contact bits from previous frame
		AND #$00FC : TRB $08				;/
		TAY						; Y = anim table index
		PHB : PHK : PLB					; bank wrapper
		LDA.w .AnimTable,y : STA $00			; $00 = main pointer
		LDY $02						;\
		LDA ($00),y					; |
		INY						; |
		SEC : SBC ($00),y				; | $00 = Y delta
		AND #$00FF					; |
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		STA $00						;/
		LSR $08 : BCC ..p2				;\
		..p1						; |
		LDA !P2YPosLo-$80				; |
		CLC : ADC $00					; |
		STA !P2YPosLo-$80				; | apply Y delta to player 1
		LDY !P2Character-$80-1				; |
		CPY #$0100 : BCS ..p2				; |
		SEC : SBC #$0010				; |
		STA $96						;/
		..p2						;\
		LSR $08 : BCC ..done				; |
		LDA !P2YPosLo					; |
		CLC : ADC $00					; |
		STA !P2YPosLo					; | apply Y delta to player 2
		LDY !P2Character-1				; |
		CPY #$0100 : BCS ..done				; |
		SEC : SBC #$0010				; |
		STA $96						; |
		..done						;/



		SEP #$30
		SEC : JSL !PlayerClipping
		STA $0E
		PLB
		PLP
		PLX
		STA $00

		LDA !BG_object_W,x				;\
		AND #$00FF					; |
		ASL #3						; | $08 = right limit
		ADC !BG_object_X,x				; |
		SEC : SBC #$0015				; |
		STA $08						;/
		LDA !BG_object_X,x				;\
		CLC : ADC #$0008				; | $06 = left limit
		STA $06						;/
		; .SetLandingWobble uses $02-$05


		.InteractP1
		LSR $00 : BCC ..done
		SEP #$20
		LDA.l !P2DropDownTimer-$80 : BMI ..fail
		LDA.l !P2YSpeed-$80
		CLC : ADC.l !P2VectorY-$80
		BPL ..interact
		..fail
		LDA #$01 : TRB $0E
		BRA ..done
		..interact
		LDA !BG_object_Misc,x
		AND #$01 : BNE ..noland
		REP #$20
		LDA !ApexP1
		JSR .SetLandingWobble
		..noland
		LDA #$04 : STA.l !P2ExtraBlock-$80
		LDA #$10 : STA.l !P2YSpeed-$80
		LDA !BG_object_Misc,x
		ORA #$01
		STA !BG_object_Misc,x
		REP #$20
		LDA.l !P2XPosLo-$80
		CMP $06
		BCS $02 : LDA $06
		CMP $08
		BCC $02 : LDA $08
		STA.l !P2XPosLo-$80
		..done

		.InteractP2
		LSR $00 : BCC ..done
		SEP #$20
		LDA.l !P2DropDownTimer : BMI ..fail
		LDA.l !P2YSpeed
		CLC : ADC.l !P2VectorY
		BPL ..interact
		..fail
		LDA #$02 : TRB $0E
		BRA ..done
		..interact
		LDA !BG_object_Misc,x
		AND #$02 : BNE ..noland
		REP #$20
		LDA !ApexP1
		JSR .SetLandingWobble
		..noland
		LDA #$04 : STA.l !P2ExtraBlock
		LDA #$10 : STA.l !P2YSpeed
		LDA !BG_object_Misc,x
		ORA #$02
		STA !BG_object_Misc,x
		REP #$20
		LDA.l !P2XPosLo
		CMP $06
		BCS $02 : LDA $06
		CMP $08
		BCC $02 : LDA $08
		STA.l !P2XPosLo
		..done

; $00 AND
; changed: 1
; off: 1

		REP #$30
		LDA $0E : STA $02
		EOR #$0003
		STA $00

; $00	interaction flags
; $02	scratch
; $04	scratch
; $06	BG_object_Misc (mirror)
; $08	----
; $0A	height
; $0C	animation to go into for small jump (..reduce)
; $0E	interaction flags (different from $00)


		LDA !BG_object_H,x : STA $0A
		LDA !BG_object_Misc,x : STA $06
		EOR $0E
		AND $00
		AND #$0003
		STA $00
		PHB : PHK : PLB
		SEP #$20
		LDA #$01*4 : STA $0C
		LDA $06
		AND #$03
		CMP #$03 : BEQ +
		LDA #$05*4 : STA $0C
	+	STZ $0D


		.BoostP1
		LSR $00 : BCS $03 : JMP ..done
		LDA !P2YSpeed-$80 : BMI ..bounce
		LDA #$05*4 : STA $04
		BRA ..setanim
		..bounce
		LDA #$04 : TRB !P2ExtraBlock-$80
		LDA $0A
		CMP #$0A : BCC ..reduce
		REP #$20
		LDA !ApexP1 : BMI ..reduce
		SEC : SBC $410000+!BG_object_Y,x
		BPL ..reduce
		CMP.w #-!BoostThreshold
		SEP #$20
		BCS ..normal
		..boost
		LDY.w #$07*4
		LDA !P2YSpeed-$80
		EOR #$FF
		CMP #$54
		BCC $02 : LDA #$54
		STA $02
		LSR A
		ADC $02
		EOR #$FF
		BRA ..set
		..normal
		LDY.w #$06*4
		LDA !P2YSpeed-$80 : BRA ..set
		..reduce
		SEP #$20
		LDY $0C
		LDA !P2YSpeed-$80
		EOR #$FF
		STA $02
		LSR #2
		SBC $02
		..set
		STY $04
		STA !P2YSpeed-$80
		LDA #$08 : STA !SPC4
		..setanim
		LDA $06
		AND #$03
		ORA $04
		STA $410000+!BG_object_Misc,x
		REP #$20
		AND #$00FC : TAY
		LDA.w #.AnimTable+2 : STA $02
		SEP #$20
		LDA ($02),y : STA $410000+!BG_object_Timer,x
		LDA !P2Character-$80 : BNE ..done
		LDA !P2YSpeed-$80 : STA !MarioYSpeed
		..done


		.BoostP2
		LSR $00 : BCS $03 : JMP ..done
		LDA !P2YSpeed : BMI ..bounce
		LDA #$05*4 : STA $04
		BRA ..setanim
		..bounce
		LDA #$04 : TRB !P2ExtraBlock
		LDA $0A
		CMP #$0A : BCC ..reduce
		REP #$20
		LDA !ApexP2 : BMI ..reduce
		SEC : SBC $410000+!BG_object_Y,x
		BPL ..reduce
		CMP.w #-!BoostThreshold
		SEP #$20
		BCS ..normal
		..boost
		LDY.w #$07*4
		LDA !P2YSpeed
		EOR #$FF
		CMP #$54
		BCC $02 : LDA #$54
		STA $02
		LSR A
		ADC $02
		EOR #$FF
		BRA ..set
		..normal
		LDY.w #$06*4
		LDA !P2YSpeed : BRA ..set
		..reduce
		SEP #$20
		LDY $0C
		LDA !P2YSpeed
		EOR #$FF
		STA $02
		LSR #2
		SBC $02
		..set
		STY $04
		STA !P2YSpeed
		LDA #$08 : STA !SPC4
		..setanim
		LDA $06
		AND #$03
		ORA $04
		STA $410000+!BG_object_Misc,x
		REP #$20
		AND #$00FC : TAY
		LDA.w #.AnimTable+2 : STA $02
		SEP #$20
		LDA ($02),y : STA $410000+!BG_object_Timer,x
		LDA !P2Character : BNE ..done
		LDA !P2YSpeed : STA !MarioYSpeed
		..done

		REP #$30
		PLB
		LDA !BG_object_Misc,x
		EOR $0E
		AND #$0003 : STA $00
		SEP #$20
		LDA !BG_object_Misc,x
		AND.b #$03^$FF
		ORA $0E
		STA !BG_object_Misc,x
		REP #$20


		.Anim
		LDA $53 : BMI +
		CMP #$0080 : BCS ..justupdateheight
	+	LDA !BG_object_Misc,x
		BIT #$0003 : BNE ..render
		AND #$00FC
		CMP #$0005*4 : BCS ..render
		JMP ..norender

		..render
		JSR RenderCable
		LDA $53
		CMP #$0080 : BCS ..justupdateheight

		PHX
		LDA !BG_object_H,x
		SEP #$30
		STA $00
		PHB
		LDA #$40
		PHA : PLB
		LDA $00 : BPL ..0
		CMP #$F8 : BCS ..up1
	..up2	LDX #$02 : BRA +
	..up1	LDX #$03 : BRA +
	..0	LDX #$04
	+	LDY #$02
	-	LDA.w !CableRenderLineTemp,y : BEQ +
		LDA.w !CableUpdateMinus2,x
		ORA #$01
		STA.w !CableUpdateMinus2,x
	+	DEX
		DEY : BPL -
		PLB
		REP #$30
		PLX

		JSR .TilemapUpdate
		..justupdateheight
		LDA.w #.AnimTable : STA $02
		LDA.w #.AnimTable>>16 : STA $04
		LDA !BG_object_Misc,x
		AND #$0003 : STA $00
		LDA !BG_object_Misc,x
		AND #$00FC
		TAY
		LDA [$02],y : STA $02
		LDA !BG_object_Timer,x
		AND #$00FF : TAY
		LDA [$02],y
		SEP #$20
		LDY $00
		CPY #$0003
		BNE $02 : ADC #$04
		STA !BG_object_H,x
		REP #$20
		LDA $53
		CMP #$0080 : BCC ..done			; if this was set, actually go into ..norender

		..norender
	; handle bounce animation here
	; update tiles into static catenary here
		SEP #$20
		LDA #$04 : STA !BG_object_H,x
		REP #$20

		JSR RenderCable_GetStaticTilemap
		JSR .TilemapUpdate
		..done


		; store update data for this cable
		STX $00
		LDA $52
		AND #$00FF
		DEC A
		STA $02
		ASL #2
		ADC $02
		TAX
		LDA !CableUpdateMinus2 : STA !CableUpdateData+0,x
		LDA !CableUpdate0 : STA !CableUpdateData+2,x
		LDA !CableUpdatePlus1 : STA !CableUpdateData+3,x
		LDA !CableTilemapIndex				;\
		CLC : ADC #$00C0				; | tilemap index +0xC0
		STA !CableTilemapIndex				;/


		.SetCoordsP1
		LDX $00
		LDA !BG_object_Misc,x
		AND #$0003
		LSR A
		STA $00
		BCC ..done
		LDA !BG_object_Y,x
		AND #$FFF0
		DEC A
		AND #$FFF0
		STA $02
		LDA !BG_object_H,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $02
		STA.l !P2YPosLo-$80
		LDA.l !P2Character-$80
		AND #$00FF : BNE ..done
		LDA.l !P2YPosLo-$80
		SEC : SBC #$0010
		STA $96
		LDA.l !P2XPosLo-$80 : STA $94
		..done

		.SetCoordsP2
		LSR $00 : BCC ..done
		LDA !BG_object_Y,x
		AND #$FFF0
		DEC A
		AND #$FFF0
		STA $02
		LDA !BG_object_H,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		CLC : ADC $02
		STA.l !P2YPosLo
		LDA.l !P2Character
		AND #$00FF : BNE ..done
		LDA.l !P2YPosLo
		SEC : SBC #$0010
		STA $96
		LDA.l !P2XPosLo : STA $94
		..done



		RTS



;
; data:
;	buffer+$00	-> baseline
;	buffer+$40	-> 1 row below, can be dipped into
;	buffer+$80	-> 2 rows below, can be overflowed into
;
; each row can be updated independently
;
; buffer regs:
;	00 = do not update, not updated last loop
;	01 = update now
;	80 = updated last loop, clear now
;	81 = update now, updated last loop


; when i write to !CableTilemapBuffer, i'll check which row the tile belongs to and set the 01 bit of that reg

; $00	x bits of address (0x001F)
; $02	y bits of address (0x03E0) + tilemap bits of address (0xF400)
; $04	tilemap buffer offset
; $06	width of cable (number of bytes)
; $08	width of cable (number of pixels)
; $0A	24-bit source address
; $0D	height byte
; $0E	fixed mode bit

; $98	base y position
; $9A	base x position


; if 0xF0 < _H < 0xF7
;	buffer+0	-> updateminus2
;	buffer+40	-> updateminus1
;	buffer+80	-> update0
;	clear		-> updateplus1
;	clear		-> updateplus2
; if 0xF8 < _H < 0xFF
;	clear		-> updateminus2
;	buffer+0	-> updateminus1
;	buffer+40	-> update0
;	buffer+80	-> updateplus1
;	clear		-> updateplus2
; all other cases
;	clear		-> updateminus2
;	clear		-> updateminus1
;	buffer+0	-> update0
;	buffer+40	-> updateplus1
;	buffer+80	-> updateplus2










; $4D	amount to add to source address (bytes)
; $4F	overflow past right border (bytes)




	.TilemapUpdate
		PHB
		PHX
		PHP

		STZ $4D						; no source offset
		LDA !BG_object_X,x				;\
		CMP $45 : BCS ..noadd				; |
		LDA $45						; |
		SEC : SBC !BG_object_X,x			; | source offset if sticking out past left border
		LSR #3						; |
		ASL A						; |
		STA $4D						;/
		LDA !BG_object_W,x				;\
		AND #$00FF					; |
		ASL #3						; | at least 1 tile must be within bounds
		ADC !BG_object_X,x				; |
		CMP $45 : BCC ..fail				;/
		LDA $45						; starting xpos when sticking out past left border
		..noadd
		CMP $47 : BCC ..okx
		..fail
		PLP
		PLX
		PLB
		RTS
		..okx
		STA $9A						;\ > base x position
		LSR #3						; | x bits of address
		AND #$001F					; |
		STA $00						;/

		LDA !BG_object_W,x				;\
		AND #$00FF					; |
		ASL #3						; |
		ADC !BG_object_X,x				; |
		SEC : SBC $47					; | amount to cut off of right side (if it sticks out past right border)
		BPL $03 : LDA #$0000				; |
		LSR #3						; |
		ASL A						; |
		ADC $4D						; |
		STA $4F						;/

		LDA !BG_object_Y,x				;\
		SEC : SBC #$0010				; | base y position (adjusted for minus2 position)
		CMP $4B : BCS ..fail				; > instant fail if below bottom line
		STA $98						;/
		LDA $4D						;\
		ASL #2						; | > x offset can change which tilemap this starts on
		ADC !BG_object_X,x				; |
		AND #$0100					; | tilemap bits of address
		ASL #2						; |
		ORA.l !BG1Address				; |
		STA $02						;/
		LDA !BG_object_W,x				;\
		AND #$00FF					; | byte count of rows
		ASL A						; |
		SEC : SBC $4F					; > minus offset
		BEQ ..fail					; > ALWAYS FAIL IF SIZE = 0
		STA $06						;/
		ASL #2						;\
		DEC A						; | pixel count of rows
		STA $08						;/
		LDA !BG_object_H,x : STA $0D			; height byte

		SEP #$30					; all regs 8-bit
		LDA.b #!VRAMbank				;\ go into bank 0x40
		PHA : PLB					;/
		LDY #$00					; y = 0
		REP #$20					; a 16-bit

		LDA.w !CableTilemapIndex : STA $04		; tilemap offset
		LDA $98						; ypos

		..loop						;\
		CMP $49 : BCC ..outofbounds			; |
		CMP $4B : BCS ..outofbounds			; | y bits of address
		ASL #2						; |
		AND #$03E0					; |
		TSB $02						;/
		SEP #$20					; a 8-bit
		LDA.w !CableUpdateMinus2,y : BNE ..process
		JMP ..next

		..outofbounds
		SEP #$20
		LDA.w !CableUpdateMinus2,y
		AND #$01 : BEQ +
		ORA #$80 : STA.w !CableUpdateMinus2,y
	+	JMP ..next

		..process
		BIT #$01 : BNE ..update

		..clear
		SEP #$20
		LDA #$00 : STA.w !CableUpdateMinus2,y
		REP #$20
		LDA.w #..someF8 : STA $0A
		LDA.w #..someF8>>8 : STA $0B
		LDA #$4000 : STA $0E
		BRA ..transfer

		..update
		LDA #$80 : STA.w !CableUpdateMinus2,y
		REP #$20
		TYA
		AND #$00FF
		STA $0E
		ASL A
		ADC $0E
		TAX
		LDA $0D-1 : BPL ..normaloffset
		CMP #$F800 : BCS ..up1

		..up2
		LDA.l ..transfersource+6,x : BEQ ..clear
		CLC : ADC $4D
		CLC : ADC $04
		STA $0A
		LDA.l ..transfersource+8,x
		BRA ..settransfer

		..up1
		LDA.l ..transfersource+3,x : BEQ ..clear
		CLC : ADC $4D
		CLC : ADC $04
		STA $0A
		LDA.l ..transfersource+5,x
		BRA ..settransfer

		..normaloffset
		LDA.l ..transfersource+0,x : BEQ ..clear
		CLC : ADC $4D
		CLC : ADC $04
		STA $0A
		LDA.l ..transfersource+2,x

		..settransfer
		SEP #$20
		STA $0A+2
		REP #$20
		STZ $0E

		..transfer
		; upload from buffer here
		; also make sure to respect tilemap boundaries and zips

		LDA $9A
		CLC : ADC $08
		EOR $9A
		AND #$0100 : BNE ..doubletransfer

		..singletransfer
		JSL !GetVRAM
		LDA $06
		ORA $0E
		STA !VRAMtable+$00,x
		LDA $0A : STA !VRAMtable+$02,x
		LDA $0C : STA !VRAMtable+$04,x
		LDA $00
		ORA $02
		STA !VRAMtable+$05,x
		BRA ..next

		..doubletransfer
		JSL !GetVRAM
		LDA #$0020
		SEC : SBC $00
		ASL A
		PHA
		ORA $0E
		STA !VRAMtable+$00,x
		LDA $0A : STA !VRAMtable+$02,x
		LDA $0C : STA !VRAMtable+$04,x
		LDA $00
		ORA $02
		STA !VRAMtable+$05,x
		JSL !GetVRAM
		LDA $01,s
		SEC : SBC $06
		EOR #$FFFF : INC A
		ORA $0E
		STA !VRAMtable+$00,x
		BIT #$4000 : BEQ ..fill
		..void
		PLA
		LDA $0A : BRA +
		..fill
		PLA
		CLC : ADC $0A
	+	STA !VRAMtable+$02,x
		LDA $0C : STA !VRAMtable+$04,x
		LDA $02
		EOR #$0400
		STA !VRAMtable+$05,x

		..next
		REP #$20					; a 16-bit
		LDA #$03E0 : TRB $02				; clear y bits of address
		LDA $98						;\
		CLC : ADC #$0008				; | y+8
		STA $98						;/
		INY						;\
		CPY #$05 : BCS ..end				; | loop
		JMP ..loop					;/

		..end
		PLP
		PLX
		PLB
		RTS

		..someF8
		db $F8

		..transfersource
		dl $000000
		dl $000000
		dl !CableTilemapBuffer+$00
		dl !CableTilemapBuffer+$40
		dl !CableTilemapBuffer+$80
		dl $000000
		dl $000000






macro cableanim(name, next)
	dw .<name>
	db .<name>_end-.<name>-1
	db <next>*4
endmacro



	.AnimTable
		%cableanim(resting, $00)	; 00
		%cableanim(bounce0, $01)	; 01
		%cableanim(bounce1, $01)	; 02
		%cableanim(bounce2, $02)	; 03
		%cableanim(bounce3, $03)	; 04
		%cableanim(boost0, $00)		; 05
		%cableanim(boost1, $05)		; 06
		%cableanim(boost2, $06)		; 07

	.resting
		db $04
		..end
		db $04

	.bounce0
		db $0A,$0A,$0B,$0B,$0C,$0C,$0D,$0D,$0D,$0D,$0D,$0D,$0C,$0C,$0B,$0B,$0A,$09
		..end

	.bounce1
		db $08,$07,$06,$05,$05,$04,$04,$04,$04,$05,$05,$06,$08,$09
		..end

	.bounce2
		db $0B,$0C,$0D,$0D,$0E,$0E,$0F,$0F,$0F,$0F,$0F,$0F,$0E,$0E,$0D,$0C,$0B,$0B
		..end

	.bounce3
		db $09,$06,$04
		..end
		db $04

	.boost0
		db $06,$06,$06,$05,$05,$05,$07,$07,$06,$04,$02,$02,$02,$03,$04,$05,$07,$09,$09,$09,$08,$07,$06,$05,$04,$02,$00,$00,$00,$00,$01,$02,$04,$07
		..end

	.boost1
		db $0A,$0A,$0A,$0A,$09,$08,$07,$06,$04,$02,$00,$FE,$FB,$F8,$F8,$F8,$F8,$F8,$F9,$FA,$FC,$FF,$02,$06
		..end

	.boost2
		db $0B,$0B,$0B,$0B,$0B,$0A,$09,$07,$05,$03,$00,$FD,$F9,$F5,$F0,$F0,$F0,$F0,$F0,$F0,$F1,$F2,$F3,$F5,$F8,$FC,$01,$05
		..end
		db $0A



	.SetLandingWobble
		BMI ..reset
		SEC : SBC !BG_object_Y,x
		CMP.w #-!BoostThreshold
		SEP #$20
		BCC ..4

		..1
		LDA #$01*4 : BRA ..set

		..reset
		SEP #$20
		LDA !BG_object_Misc,x
		AND #$03
		ORA #$04
		STA !BG_object_Misc,x
		STZ !BG_object_Timer,x
		RTS

		..4
		LDA #$04*4

		..set
		STA $02
		LDA #$00 : XBA
		LDA.b #.AnimTable+2 : STA $03
		LDA.b #.AnimTable+2>>8 : STA $04
		LDA.b #.AnimTable>>16 : STA $05
		LDA !BG_object_Misc,x
		AND #$03
		ORA $02
		STA !BG_object_Misc,x
		AND #$FC
		TAY
		LDA [$03],y : STA !BG_object_Timer,x
		RTS





; texture map:
;	- copy up to 8 chunks into buffer (offset 000-00F)
;	- draw chunks as a 4px wide column
;	- $4D holds size
;		00 = 4x1
;		02 = 4x2
;		04 = 4x3
;		06 = 4x4
;		08 = 4x5
;		0A = 4x6
;		0C = 4x7
;		0E = 4x8
;		10 = 8x1
;		12 = 8x2
;		14 = 8x3
;		16 = 8x4
;		18 = 8x5
;		1A = 8x6
;		1C = 8x7
;		1E = 8x8


; example code for texture mapping
;
;		LDX $53
;		LDA $00
;		ORA $02
;		AND #$0707
;		ORA.l .TileCCIndex,x
;		LSR A
;		TAY
;		LDX $4D
;		JMP (..ptr,x)
;		..ptr
;		dw ..8
;		dw ..7
;		dw ..6
;		dw ..5
;		dw ..4
;		dw ..3
;		dw ..2
;		dw ..1		
;	..8	LDA !CableTexture+$00E : STA.w (!CableRenderBuffer+$700)/2,y
;	..7	LDA !CableTexture+$00C : STA.w (!CableRenderBuffer+$600)/2,y
;	..6	LDA !CableTexture+$00A : STA.w (!CableRenderBuffer+$500)/2,y
;	..5	LDA !CableTexture+$008 : STA.w (!CableRenderBuffer+$400)/2,y
;	..4	LDA !CableTexture+$006 : STA.w (!CableRenderBuffer+$300)/2,y
;	..3	LDA !CableTexture+$004 : STA.w (!CableRenderBuffer+$200)/2,y
;	..2	LDA !CableTexture+$002 : STA.w (!CableRenderBuffer+$100)/2,y
;	..1	LDA !CableTexture+$000 : STA.w (!CableRenderBuffer)/2,y




; Xpos of left connection point is always 0
; Xpos of right connection point is always 8 * W
;
;
	
; seems like i have to free up $0A-$0F
; i need to fit in both the tile hash AND the tile index
; plan:
; $00	current Xpos of plotting line (* 1)
; $02	current Ypos of plotting line * 256 (without sub pixels)
; $04	current Ypos of plotting line * 256 (including sub pixels)
; $06	deepest Ypos
; $08	k factor of current line (not used for middle line)
; $0A	hash of current tile (used to quickly check if a new tile should be initialized)
; $0C	latent growth
; $0E	Xpos to stop rendering the current line at
;
; $4F	safe stack pointer
; $53	which tile is next to be rendered


; still need:
;	thickness / rendering style



	RenderCable:
		LDA !BG_object_H,x
		AND #$00FF
		XBA
		STA $06

		LDA !BG_object_W,x			;\
		ASL #3					; | prepare to push ending Xpos of last line
		AND #$01FF				; |
		CLC : ADC !CableCacheX			; > add cached X
		STA $02					;/

		LDA #$0010 : STA $04			; default width of middle line



		LDA !BG_object_Misc,x			;\
		AND #$0003 : BNE +			; | use last offset if there is no player contact

		.AdjustCenter
		LDA #$0007 : STA $0C
		LDA !BG_object_W,x
		AND #$00FF
		CMP #$000A
		BCC $04 : ASL $04 : ASL $0C
		SEP #$20
		LDA !BG_object_W,x
		ASL #2
		SBC $0C
		CMP !BG_object_Tile,x
		BEQ ..go
		BCC ..dec
	..inc	INC !BG_object_Tile,x : BRA ..go
	..dec	DEC !BG_object_Tile,x
		..go
		REP #$20
		STZ $0C
		LDA $06 : BEQ ..nocurve
		LDA !BG_object_W,x
		AND #$00FF
		ASL #2
		STA $00
		LDA !BG_object_Tile,x
		AND #$00FF
		ASL A
		ADC $04
		LSR A
		SEC : SBC $00
		BPL $04 : EOR #$FFFF : INC A
		CMP #$0028 : BCS ..nocurve
		CMP #$0010 : BCS ..curve1
		..curve2
		LDA #$0002 : BRA ..setcurve
		..curve1
		LDA $00
		CMP #$0050 : BCS ..nocurve
		LDA #$0001
		..setcurve
		BIT $06
		BPL $04 : EOR #$FFFF : INC A
		STA $0C
		..nocurve
		LDA !BG_object_Tile,x : BRA ++		;/

	+	STZ $0C
		CMP #$0003 : BEQ .Double
		CMP #$0002 : BEQ .P2

		.P1
		LDA.l !P2XPosLo-$80 : BRA +

		.P2
		LDA.l !P2XPosLo				;\
	+	SEC : SBC !BG_object_X,x		; |
		BPL $03 : LDA #$0000			; |
		SEP #$20				; | calculate ending Xpos of first line
		STA !BG_object_Tile,x			; |
		REP #$20				; |
		BRA ++

		.Double
		LDA.l !P2XPosLo-$80
		SEC : SBC.l !P2XPosLo
		PHP
		BPL $04 : EOR #$FFFF : INC A
		CLC :  ADC $04
		STA $04
		PLP : BPL .P2
		BRA .P1

	++	AND #$00FC				; |
		CLC : ADC !CableCacheX			; > add cached X
		CMP #$0008
		BCS $03 : LDA #$0008
		STA $0E					;/
		CLC : ADC $04				;\
		AND #$00FC				; | prepare to push ending Xpos of second line
		STA $00					;/

		LDA $02					;\
		SEC : SBC #$0009
		CMP $00 : BCS ..nocap			; |
		PHA					; | cap coords to maintain smoothness
		SEC : SBC $00				; |
		CLC : ADC $0E				; |
		STA $0E					; |
		PLA : STA $00				; |
		..nocap					;/

		PHX
		PHP
		PHB : PHK : PLB
		TSC : STA $4F				; save stack pointer

		LDA $02					;\
		SEC : SBC $00				; | push dx for line 3
		PHA					;/
		PEI ($02)				; push ending Xpos of line 3
		PEI ($00)				; push ending Xpos of line 2

		SEP #$20
		LDA #$40 : PHA
		LDA #$01 : STA $2250			; prep division
		STZ $223F				; project 4bpp bitmap
		REP #$20
		LDA #$FFFF : STA $0A			; start with an invalid hash so first tile always counts as new



	.FirstLine
		LDA $06 : BPL ..pos

		..neg
		EOR #$FFFF : INC A
		STA $2251
		LDA $0E
		SEC : SBC !CableCacheX			; | /dx
		STA $2253
		LDA !CableCacheX : STA $00
		LDA $06
		AND #$F800
		EOR #$FFFF : INC A
		STA $02
		STA $04
		LDA $2306
		ASL #2
		EOR #$FFFF : INC A
		BRA ..go

		..pos
		STA $2251				; 256 * dy
		LDA $0E					;\
		SEC : SBC !CableCacheX			; | /dx
		STA $2253				;/
		LDA !CableCacheX : STA $00		;\
		STZ $02					; | starting coords
		STZ $04					;/
		LDA $2306				;\
		ASL #2					; | k factor
		..go
		STA $08					;/
		PLB

		STZ.w !CableRenderLineTemp+0		;\ reset temp update regs
		STZ.w !CableRenderLineTemp+1		;/
		LDA #$8000
		STA.w !CableConnectionHash		; give connection hash an initially invalid number (still not 0xFFFF since that would trigger false positive)

		LDX #$003E				;\
		LDA.w !CableTilemapIndex		; |
		ORA #$003E				; |
		TAY					; |
		LDA #$00F8				; |
	-	STA.w !CableTilemapBuffer+$00,y		; | all tiles are empty and none have been rendered to
		STA.w !CableTilemapBuffer+$40,y		; | (these don't use the same index, but we'll still clear them both here)
		STA.w !CableTilemapBuffer+$80,y		; |
		STZ.w !CableTileOverflow+$00,x		; |
		STZ.w !CableTileOverflow+$40,x		; |
		DEY #2					; |
		DEX #2 : BPL -				;/

		..loop
		LDA $00
		ORA $02
		AND #$0707^$FFFF
		CMP $0A : BEQ ..sametile
		JSR .NewTile
		..sametile
		LDX $53
		LDA $00
		ORA $02
		AND #$0707
		ORA.l .TileCCIndex,x
		LSR A
		TAX
		LDA #$2222
		STA.w (!CableRenderBuffer)/2,x
	;	LDA #$1111
		STA.w (!CableRenderBuffer+$100)/2,x
	;	LDA #$1111
	;	STA.w (!CableRenderBuffer+$200)/2,x
	;	LDA #$2222
	;	STA.w (!CableRenderBuffer+$300)/2,x
		TXA
		AND #$0700/2
		CMP #$0700/2 : BCC ..nooverflow
		JSR .OverflowTile
		..nooverflow
		LDA $04
		CLC : ADC $08
		BPL $03 : LDA #$0000
		STA $04
		AND #$FF00 : STA $02
		LDA $08
		SEC : SBC $0C
		TAX
		EOR $08
		BMI $02 : STX $08
		LDA $00
		CLC : ADC #$0004
		STA $00
		CMP $0E : BCC ..loop


	.MiddleLine
		PLA : STA $0E				; pull ending Xpos of second line
		LDA $0C : BNE ..loop
		LDA $06 : BMI ..loop
		STA $02
		STA $04
		..loop
		LDA $00
		ORA $02
		AND #$0707^$FFFF
		CMP $0A : BEQ ..sametile
		JSR .NewTile
		..sametile
		LDX $53
		LDA $00
		ORA $02
		AND #$0707
		ORA.l .TileCCIndex,x
		LSR A
		TAX
		LDA $53 : STA.w !CableConnectionIndex	; update with last index
		LDA #$2222
		STA.w (!CableRenderBuffer)/2,x
	;	LDA #$1111
		STA.w (!CableRenderBuffer+$100)/2,x
	;	LDA #$1111
	;	STA.w (!CableRenderBuffer+$200)/2,x
	;	LDA #$2222
	;	STA.w (!CableRenderBuffer+$300)/2,x
		TXA
		AND #$0700/2
		CMP #$0700/2 : BCC ..nooverflow
		JSR .OverflowTile
		..nooverflow
		LDA $00
		CLC : ADC #$0004
		STA $00
		CMP $0E : BCC ..loop

		LDA $0A : STA.w !CableConnectionHash
		LDX $53
		CPX #$0080 : BCC +
		LDA $4F : TCS
		PLB
		PLP
		PLX
		RTS
		+
		LDA.w !CableTileOverflow,x : BEQ ..done
		INX #2
		STX $53
		..done

		LDA #$FFFF : STA $0A


	.LastLine
		LDA $00 : STA $0E
		PLA
		SEC : SBC #$0004
		STA $00				; pull ending Xpos of last line
		LDA $06 : BPL ..pos

		..neg
		EOR #$FFFF : INC A
		STA.l $2251
		PLA : STA.l $2253
		LDA $06
		AND #$F800
		EOR #$FFFF : INC A
		STA $02
		ORA #$00FF
		STA $04
		LDA.l $2306
		ASL #2
		EOR #$FFFF : INC A
		BRA ..go

		..pos
		STA.l $2251				; 256 * dy
		PLA : STA.l $2253			; /dx
		STZ $02
		STZ $04
		NOP
		LDA.l $2306				;\
		ASL #2					; | k factor
		..go
		STA $08					;/

		..loop
		LDA $00
		ORA $02
		AND #$0707^$FFFF
		CMP $0A : BEQ ..sametile
		JSR .NewTile
		..sametile
		LDA.w !CableTilemapBuffer,y		; last line has to get the index this way to account for variations in end point
		AND #$003F
		ASL A
		TAX
		..finaltile
		LDA $00
		ORA $02
		AND #$0707
		ORA.l .TileCCIndex,x
		LSR A
		TAX
		LDA #$2222
		STA.w (!CableRenderBuffer)/2,x
	;	LDA #$1111
		STA.w (!CableRenderBuffer+$100)/2,x
	;	LDA #$1111
	;	STA.w (!CableRenderBuffer+$200)/2,x
	;	LDA #$2222
	;	STA.w (!CableRenderBuffer+$300)/2,x
		TXA
		AND #$0700/2
		CMP #$0700/2 : BCC ..nooverflow
		PHY
		JSR .OverflowTile
		PLY
		..nooverflow
		LDA $04
		CLC : ADC $08
		BPL $03 : LDA #$0000
		STA $04
		AND #$FF00 : STA $02
		LDA $08
		SEC : SBC $0C
		TAX
		EOR $08
		BMI $02 : STX $08
		LDA $00
		SEC : SBC #$0004
		STA $00
		CMP $0E : BCS ..loop

		LDX $53					;\
		CPX #$0080 : BCC +
		LDA $4F : TCS
		PLB
		PLP
		PLX
		RTS
		+
		LDA.w !CableTileOverflow,x : BEQ ..end	; |
		LDA $0A					; |
		SEC : SBC.w !CablePrevHash		; | if last tile overflowed, make sure it's still appended to CCDMA
		CMP #$0800 : BEQ ..end			; | (if last hash diff indicated crossing up only, this tile is already appended)
		INX #2					; |
		STX $53					;/

		..end
		INC $51					; +1 render
		LDA $0E
		CLC : ADC #$0004
		AND #$FFF8
		STA.w !CableCacheX			; cache ending X

		PLB
		PLP
		PLX
		RTS



	.NewTile
		LDX $0A : STX.w !CablePrevHash
		STA $0A
		CMP.w !CableConnectionHash : BNE ..normal
		..finalhash
		LDX $53					;\
		CPX #$0080 : BCC +
		LDA $4F : TCS
		PLB
		PLP
		PLX
		RTS
		+
		LDA.w !CableTileOverflow,x : BEQ +	; | register overflow of penultimate tile
		INX #2					; |
		STX $53					;/
	+	LDX.w !CableConnectionIndex
		PLA					; kill RTS
		JMP .LastLine_finaltile

		..normal
		TXA
		LDX $53 : BMI +
		CPX #$0080 : BCC +
		LDA $4F : TCS
		PLB
		PLP
		PLX
		RTS
		+

		EOR $0A
		AND #$0008 : BNE ..sideways
		BRA +
		..sideways
		LDA.w !CableTileOverflow,x : BEQ +
		INX #2
	+	INX #2
		STX $53

		LDA $00
		SEC : SBC.w !CableCacheX
		ORA $02
		AND #$18FF
		LSR #3
		BIT #$0100
		BEQ $03 : ORA #$0020
		BIT #$0200
		BEQ $03 : ORA #$0040
		AND #$00FF
		ASL A
		ADC.w !CableTilemapIndex
		TAY
		LDA.w !CableTilemapBuffer,y
		CMP #$00F8 : BNE ..append
		..createnew
		LDX $53
		LDA.l .TileCCIndex,x
		LSR A
		TAX
		STZ.w (!CableRenderBuffer/2)+$000,x
		STZ.w (!CableRenderBuffer/2)+$002,x
		STZ.w (!CableRenderBuffer/2)+$080,x
		STZ.w (!CableRenderBuffer/2)+$082,x
		STZ.w (!CableRenderBuffer/2)+$100,x
		STZ.w (!CableRenderBuffer/2)+$102,x
		STZ.w (!CableRenderBuffer/2)+$180,x
		STZ.w (!CableRenderBuffer/2)+$182,x
		STZ.w (!CableRenderBuffer/2)+$200,x
		STZ.w (!CableRenderBuffer/2)+$202,x
		STZ.w (!CableRenderBuffer/2)+$280,x
		STZ.w (!CableRenderBuffer/2)+$282,x
		STZ.w (!CableRenderBuffer/2)+$300,x
		STZ.w (!CableRenderBuffer/2)+$302,x
		STZ.w (!CableRenderBuffer/2)+$380,x
		STZ.w (!CableRenderBuffer/2)+$382,x
		LDA $53
		LSR A
		ORA #$1FC0
		STA.w !CableTilemapBuffer,y

		LDA $02+1					;\
		AND #$00FF					; |
		LSR #3						; | mark this line as update
		TAX						; |
		INC.w !CableRenderLineTemp,x			;/

		..append
		RTS


	.OverflowTile
		PHA
; if tile border was crossed from below, we have to overflow into the previous tile
; in any other case, we have to overflow into the next tile
; (we know direction by checking hash diff)
		LDA $00
		SEC : SBC.w !CableCacheX
		ORA $02
		AND #$08FF
		LSR #3
		BIT #$0100
		BEQ $03 : ORA #$0020
		AND #$00FF
		CLC : ADC #$0020
		ASL A
		ADC.w !CableTilemapIndex
		TAY
		LDA.w !CableTilemapBuffer,y
		CMP #$00F8 : BNE ..append
		..createnew
		LDA $53
		LSR A
		INC A
		ORA #$1FC0
		STA.w !CableTilemapBuffer,y
		LDX $53
		INC.w !CableTileOverflow,x			; this tile has overflown
		INX #2
		LDA.l .TileCCIndex,x
		LSR A
		TAX
		STZ.w (!CableRenderBuffer/2)+$000,x
		STZ.w (!CableRenderBuffer/2)+$002,x
		STZ.w (!CableRenderBuffer/2)+$080,x
		STZ.w (!CableRenderBuffer/2)+$082,x
		STZ.w (!CableRenderBuffer/2)+$100,x
		STZ.w (!CableRenderBuffer/2)+$102,x
		STZ.w (!CableRenderBuffer/2)+$180,x
		STZ.w (!CableRenderBuffer/2)+$182,x
		STZ.w (!CableRenderBuffer/2)+$200,x
		STZ.w (!CableRenderBuffer/2)+$202,x
		STZ.w (!CableRenderBuffer/2)+$280,x
		STZ.w (!CableRenderBuffer/2)+$282,x
		STZ.w (!CableRenderBuffer/2)+$300,x
		STZ.w (!CableRenderBuffer/2)+$302,x
		STZ.w (!CableRenderBuffer/2)+$380,x
		STZ.w (!CableRenderBuffer/2)+$382,x

		LDA $02+1					;\
		AND #$00FF					; |
		LSR #3						; | mark this line as update
		TAX						; |
		INX						; |
		INC.w !CableRenderLineTemp,x			;/

		LDA.w !CableTilemapBuffer,y
		..append
		AND #$003F
		ASL A
		TAX

		..draw
		LDA $00
		AND #$0007
		ORA.l .TileCCIndex,x
		LSR A
		TAX

		PLA
		; CMP #$0600/2 : BCC ..overflow1
		; CMP #$0700/2 : BCC ..overflow2

		; ..overflow3
		; LDA #$1111
		; STA.w (!CableRenderBuffer+$000)/2,x
		; STA.w (!CableRenderBuffer+$100)/2,x
		; LDA #$2222
		; STA.w (!CableRenderBuffer+$200)/2,x
		; RTS

		; ..overflow2
		; LDA #$1111
		; STA.w (!CableRenderBuffer+$000)/2,x
		; LDA #$2222
		; STA.w (!CableRenderBuffer+$100)/2,x
		; RTS

		..overflow1
		LDA #$2222
		STA.w (!CableRenderBuffer+$000)/2,x
		RTS


	




; 0x30		2 copy, 1x src5
; 0x40		3 copy, 1x src5
; 0x50		2 copy, 1x src4, 1 copy, 1x src5
; 0x60		2 copy, 1x src4, 1 copy, 2x src5
; 0x70		3 copy, 1x src4, 1 copy, 2x src5
; 0x80		3 copy, 2x src4, 1 copy, 2x src5
; 0x90		2 copy, 1x src3, 1 copy, 1x src4, 1 copy, 3x src5
; 0xA0		2 copy, 1x src3, 1 copy, 2x src4, 1 copy, 3x src5
; 0xB0		2 copy, 1x src3, 1 copy, 3x src4, 1 copy, 3x src5
; 0xC0		2 copy, 2x src3, 1 copy, 3x src4, 1 copy, 3x src5
; 0xD0		3 copy, 1x src3, 1 copy, 3x src4, 1 copy, 4x src5
; 0xE0		3 copy, 1x src3, 1 copy, 4x src4, 1 copy, 4x src5
; 0xF0		3 copy, 2x src3, 1 copy, 3x src4, 1 copy, 5x src5
; 0x100		3 copy, 2x src3, 1 copy, 4x src4, 1 copy, 5x src5

	!Temp = $20
	; base tile of each cable type

	.BaseTile
	db !Temp+$00	; 3 blocks wide
	db !Temp+$02	; 4 blocks wide
	db !Temp+$05	; 5 blocks wide
	db !Temp+$08	; 6 blocks wide
	db !Temp+$0B	; 7 blocks wide
	db !Temp+$10	; 8 blocks wide
	db !Temp+$14	; 9 blocks wide
	db !Temp+$18	; 10 blocks wide
	db !Temp+$1C	; 11 blocks wide
	db !Temp+$20	; 12 blocks wide
	db !Temp+$24	; 13 blocks wide
	db !Temp+$29	; 14 blocks wide
	db !Temp+$30	; 15 blocks wide
	db !Temp+$35	; 16 blocks wide


; commands:
;	first nybble 0: copy that many tiles from curve's unique tiles
;	first nybble 3: lo nybble number of src3 tiles (tile 0x3D)
;	first nybble 4: lo nybble number of src4 tiles (tile 0x3E)
;	first nybble 5: lo nybble number of src5 tiles (tile 0x3F)
;	first nybble 8-F: END UPLOAD HERE

	.WidthTable
	dw ..w3
	dw ..w4
	dw ..w5
	dw ..w6
	dw ..w7
	dw ..w8
	dw ..w9
	dw ..w10
	dw ..w11
	dw ..w12
	dw ..w13
	dw ..w14
	dw ..w15
	dw ..w16


	..w3	db $02,$51,$FF
	..w4	db $03,$51,$FF
	..w5	db $02,$41,$01,$51,$FF
	..w6	db $02,$41,$01,$52,$FF
	..w7	db $03,$41,$01,$52,$FF
	..w8	db $03,$42,$01,$52,$FF
	..w9	db $02,$31,$01,$41,$01,$53,$FF
	..w10	db $02,$31,$01,$42,$01,$53,$FF
	..w11	db $02,$31,$01,$43,$01,$53,$FF
	..w12	db $02,$32,$01,$43,$01,$53,$FF
	..w13	db $03,$31,$01,$43,$01,$54,$FF
	..w14	db $03,$31,$01,$44,$01,$54,$FF
	..w15	db $03,$32,$01,$43,$01,$55,$FF
	..w16	db $03,$32,$01,$44,$01,$55,$FF



; $00 - pointer to command table
; $02 - base tile
; $04 - number of tiles read from source
; $06 - loop counter
; $08 - 
; $0A - 
; $0C - xflip bit

; procedure:
; - execute commands to generate tilemap
; - copy tilemap backwards while setting xflip to generate second half

	.GetStaticTilemap
		PHX
		LDA !BG_object_W,x
		AND #$00FF
		LSR A
		CMP #$0010
		BCC $03 : LDA #$0010
		SEC : SBC #$0003
		BPL $03 : LDA #$0000
		TAY
		ASL A
		TAX
		PHB : PHK : PLB
		LDA .WidthTable,x : STA $00
		LDA .BaseTile,y
		AND #$00FF
		ORA #$1F00
		STA $02

		LDA !CableTilemapIndex
		ORA #$003E
		TAX
		LDY #$001F
		LDA #$00F8
	-	STA !CableTilemapBuffer+$40,x
		STA !CableTilemapBuffer+$80,x
		STA !CableTilemapBuffer+$C0,x
		DEX #2
		DEY : BPL -
		LDY #$0000
		LDA !CableTilemapIndex : TAX

		..loop
		SEP #$20
		LDA ($00),y : BMI ..end
		AND #$0F : STA $06
		STZ $07
		LDA ($00),y
		CMP #$10 : BCC ..copy
		CMP #$3F+1 : BCC ..src3
		CMP #$4F+1 : BCC ..src4

		..src5
		REP #$20
		LDA #$1F3D+!Temp
	-	STA !CableTilemapBuffer,x
		INX #2
		DEC $06 : BNE -
		BRA ..next

		..src4
		REP #$20
		LDA #$1F3E+!Temp
	-	STA !CableTilemapBuffer,x
		INX #2
		DEC $06 : BNE -
		BRA ..next

		..src3
		REP #$20
		LDA #$1F3F+!Temp
	-	STA !CableTilemapBuffer,x
		INX #2
		DEC $06 : BNE -
		BRA ..next

		..copy
		REP #$20
		LDA $02
	-	STA !CableTilemapBuffer,x
		INX #2
		INC A
		DEC $06 : BNE -
		STA $02

		..next
		INY
		BRA ..loop

		..end

		SEP #$20
		LDA.b #!CableTilemapBuffer>>16
		PHA : PLB
		REP #$20
		STX $06
		TXA
		SEC : SBC.w !CableTilemapIndex
		ASL A
		DEC #2
		CLC : ADC.w !CableTilemapIndex
		TAY
		LDX.w !CableTilemapIndex

	-	LDA.w !CableTilemapBuffer,x
		EOR #$4000
		STA.w !CableTilemapBuffer,y
		DEY #2
		INX #2
		CPX $06 : BCC -

		LDA.w !CableUpdate0			;\
		ORA #$0001				; | only center row should be updated
		STA.w !CableUpdate0			;/

		PLB
		PLX
		RTS



	.TileCCIndex
		dw $0000,$0008,$0010,$0018,$0020,$0028,$0030,$0038,$0040,$0048,$0050,$0058,$0060,$0068,$0070,$0078
		dw $0080,$0088,$0090,$0098,$00A0,$00A8,$00B0,$00B8,$00C0,$00C8,$00D0,$00D8,$00E0,$00E8,$00F0,$00F8
		dw $0800,$0808,$0810,$0818,$0820,$0828,$0830,$0838,$0840,$0848,$0850,$0858,$0860,$0868,$0870,$0878
		dw $0880,$0888,$0890,$0898,$08A0,$08A8,$08B0,$08B8,$08C0,$08C8,$08D0,$08D8,$08E0,$08E8,$08F0,$08F8


