



BG_OBJECTS:
namespace BG_OBJECTS



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
		LDA !BG_object_X,x				;\
		SBC $1A						; |
		ADC #$0100					; |
		CMP #$0300 : BCS .Next				; | must be within this distance
		LDA !BG_object_Y,x				; | precision not important, this is just to save cycles
		SBC $1C						; |
		ADC #$0100					; |
		CMP #$0300 : BCS .Next				;/

		; GET POINTER TO BG_OBJECT CODE HERE


		STX $00
		LDA !BG_object_Type,x
		AND #$00FF
		DEC A
		ASL A
		CMP.w #.Ptr_end-.Ptr : BCS .Next
		TAX
		JSR (.Ptr,x)

	.Next	TXA
		CLC : ADC.w #!BG_object_Size
		TAX
		CPX.w #(!BG_object_Size)*(!BG_object_Count) : BCC .Loop

		PLP
		PLB
		RTS



		.Ptr
		dw Bush
		dw Window
		..end



; idea list:
; - bush
; - tall grass
; - windows



incsrc "SpriteSize.asm"




incsrc "BG_objects/Bush.asm"
incsrc "BG_objects/Window.asm"




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

	TileUpdate:

		.Setup						;\
		LDA !BG_object_X,x				; |
		LSR #3						; |
		AND #$003F					; | base VRAM X address
		BIT #$0020					; |
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

		LDA !BG_object_Tile,x
		AND #$00FF
		ORA #$0300
		STA $0E
		; HERE: GET LOCATION ON PAGE 3
		; STORE TO $0E (tttttttt + ------tt)


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

		.Update
		PHX						;\ push stuff
		PHB : PHK : PLB					;/
		LDA !VRAMbase+!TileUpdateTable : TAX		; X = tile update index
		LDY #$0000					; Y = source data index
		LDA $04 : STA $06				; start new row
		..loop						;\
		LDA $06						; |
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
		CMP $0C : BEQ ..done				;/
		BRA ..loop					; loop

		..done
		TXA : STA !VRAMbase+!TileUpdateTable		; update header for tile update table
		PLB						;\ restore stuff
		PLX						;/
		RTS						; return




; !BigRAM+0 = timer

	CheckInteract:
		LDA !BG_object_X,x				;\
		STA $04						; |
		STA $09						; |
		LDA !BG_object_Y,x				; |
		SEP #$20					; |
		STA $05						; |
		XBA : STA $0B					; | clipping
		LDA !BG_object_W,x				; |
		ASL #3						; |
		STA $06						; |
		LDA !BG_object_H,x				; |
		ASL #3						; |
		STA $07						;/

		PHX						;\
		PHB : PHK : PLB					; | reg/bank setup
		SEP #$30					;/


	.Player1
		LDA !BigRAM : BEQ ..valid			;\
		LDY #!Medium					; > default size of player = medium
		LDA !P2XSpeed-$80				; |
		JSR .AdjustSize					; |
		REP #$20					; |
		LDA .ParticleFrequency,y : STA $0E		; | check if an interaction can occur on this frame
		SEP #$20					; |
		LDA !BigRAM+0					; |
		AND #$0F : TAY					; |
		LDA ($0E),y : BEQ ..nocontact			; |
		..valid						;/
		CLC : LDA #$00					;\
		JSL !PlayerClipping				; |
		JSL !CheckContact : BCC ..nocontact		; | player 1 contact
		LDA !P2XSpeed-$80 : BEQ ..nocontact		; |
		JMP .Interact					; |
		..nocontact					;/


	.Player2
		LDA !BigRAM : BEQ ..valid			;\
		LDY #!Medium					; > default size of player = medium
		LDA !P2XSpeed					; |
		JSR .AdjustSize					; |
		REP #$20					; |
		LDA .ParticleFrequency,y : STA $0E		; | check if an interaction can occur on this frame
		SEP #$20					; |
		LDA !BigRAM+0					; |
		AND #$0F : TAY					; |
		LDA ($0E),y : BEQ ..nocontact			; |
		..valid						;/
		CLC : LDA #$01					;\
		JSL !PlayerClipping				; |
		JSL !CheckContact : BCC ..nocontact		; | player 2 contact
		LDA !P2XSpeed : BNE .Interact			; |
		..nocontact					;/


	.Sprites
		LDX #$0F					; loop through all sprites
		..loop						;\
		LDA $3230,x : BEQ ..next			; |
		LDA !ExtraBits,x				; |
		AND #$08 : BNE ..customsprite			; |
		..vanillasprite					; |
		LDY $3200,x					; |
		LDA SpriteSize_Vanilla,y : BRA ..readfreq	; | get sprite size/weight
		..customsprite					; |
		LDY !NewSpriteNum,x				; |
		LDA SpriteSize_Custom,y				; |
		..readfreq					; |
		BEQ ..next					; > if weight = 0, interaction is invalid
		TAY						;/
		LDA !SpriteXSpeed,x : BEQ ..next		;\ adjust size based on speed
		JSR .AdjustSize					;/
		REP #$20					;\
		LDA .ParticleFrequency,y : STA $0E		; |
		SEP #$20					; | check if an interaction can occur on this frame
		LDA !BigRAM+0 : BEQ ..valid			; |
		AND #$0F : TAY					; |
		LDA ($0E),y : BEQ ..next			;/
		..valid						;\
		JSL !GetSpriteClipping00			; | sprite contact
		JSL !CheckContact : BCS ..interact		; |
		..next						;/
		DEX : BPL ..loop				; > loop
		REP #$30					;\
		PLB						; |
		PLX						; | restore and return
		CLC						; |
		RTS						;/
		..interact					;\ A = X speed
		LDA !SpriteXSpeed,x				;/
		.Interact					;\
		REP #$30					; |
		PLB						; | return with carry set (meaning interaction)
		PLX						; | A = X speed of interacting entity
		SEC						; |
		RTS						;/


; speed thresholds
;	<10 = -6
;	<14 = -5
;	<18 = -4
;	<1C = -3
;	<20 = -2
;	<28 = -1
;	>28 = +0

; input:
;	A = speed
;	Y = size
; output:
;	Y = adjusted size

		.AdjustSize
		STY $0E
		BPL $03 : EOR #$FF : INC A
		CMP #$10 : BCC ..minus6
		CMP #$14 : BCC ..minus5
		CMP #$18 : BCC ..minus4
		CMP #$1C : BCC ..minus3
		CMP #$20 : BCC ..minus2
		CMP #$28 : BCC ..minus1
		..plus0
		LDY #$06 : BRA ..calc
		..minus1
		LDY #$05 : BRA ..calc
		..minus2
		LDY #$04 : BRA ..calc
		..minus3
		LDY #$03 : BRA ..calc
		..minus4
		LDY #$02 : BRA ..calc
		..minus5
		LDY #$01 : BRA ..calc
		..minus6
		LDY #$00
		..calc
		LDA ..data,y
		CLC : ADC $0E
		BPL $02 : LDA #$00
		ASL A
		TAY
		RTS

		..data
		db -6,-5,-4,-3,-2,-1,0



; usage:
;	load pointer from .ParticleFrequency
;	index pointer with timer&$000F
;	if 0: don't spawn, if nonzero: spawn

		.ParticleFrequency
		dw ..0
		dw ..1
		dw ..2
		dw ..3
		dw ..4
		dw ..5
		dw ..6
		dw ..7
		dw ..8
		dw ..9
		dw ..A
		dw ..B
		dw ..C
		dw ..D
		dw ..E
		dw ..F
		dw ..10


		; timer index ->
		;- 0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - A - B - C - D - E - F
	..0	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	..1	db $00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$00
	..2	db $00,$00,$00,$FF,$00,$00,$00,$00,$00,$00,$00,$FF,$00,$00,$00,$00
	..3	db $00,$00,$00,$00,$FF,$00,$00,$00,$00,$FF,$00,$00,$00,$00,$FF,$00
	..4	db $00,$00,$00,$FF,$00,$00,$00,$FF,$00,$00,$00,$FF,$00,$00,$00,$FF
	..5	db $00,$00,$FF,$00,$00,$FF,$00,$00,$FF,$00,$00,$FF,$00,$00,$FF,$00
	..6	db $00,$FF,$00,$00,$FF,$00,$FF,$00,$00,$FF,$00,$00,$FF,$00,$FF,$00
	..7	db $FF,$00,$FF,$00,$00,$FF,$00,$FF,$00,$FF,$00,$00,$FF,$00,$FF,$00
	..8	db $00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF
	..9	db $00,$FF,$00,$FF,$FF,$00,$FF,$00,$FF,$00,$FF,$FF,$00,$FF,$00,$FF
	..A	db $FF,$00,$FF,$FF,$00,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$00,$FF
	..B	db $FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF,$FF,$00,$FF
	..C	db $FF,$FF,$FF,$00,$FF,$FF,$FF,$00,$FF,$FF,$FF,$00,$FF,$FF,$FF,$00
	..D	db $FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$00,$FF
	..E	db $FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF
	..F	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	..10	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF




namespace off



























