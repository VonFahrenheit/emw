



; $45	16-bit	left border
; $47	16-bit	right border
; $49	16-bit	top border
; $4B	16-bit	bottom border
; $F0	16-bit	---- (can be used internally by BG objects)
; $F2	16-bit	---- (can be used internally by BG objects)
; $F4	8-bit	number of cables that have been rendered
; $F5	8-bit	how many cables have been processed (increments by 1 before each cable code call)
; $F6	16-bit	current tile being rendered to (carries across multiple cables)



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

	; set by VR3
		; LDA $1A						;\
		; AND #$FFF8					; |
		; SEC : SBC #$0010				; | +1
		; BPL $03 : LDA #$0000				; |
		; STA $45						; |
		; LDA $1A						; |
		; AND #$FFF8					; |
		; CLC : ADC #$0118				; | +1
		; STA $47						; |
		; LDA $1C						; |
		; AND #$FFF8					; | zip box border
		; SEC : SBC #$0004				; |
		; BPL $03 : LDA #$0000				; |
		; AND #$FFF8					; |
		; STA $49						; |
		; LDA $1C						; |
		; AND #$FFF8					; |
		; CLC : ADC #$00EC				; |
		; AND #$FFF8					; |
		; STA $4B						;/

		STZ $F4						; clear number of cable renders
		LDA #$FFFE : STA $F6				; reset cable tile count
		LDA #$0000
		STA !CableCacheX
		STA !CableTilemapIndex

		LDX #$0000
	.Loop	LDA !BG_object_Type,x
		AND #$00FF : BEQ .Next
		STA $00						; store type num
		CMP #$0004 : BNE ..notcable
		INC $F5						; +1 cable call
		..notcable
		LDA !BG_object_X,x				;\
		SBC $1A						; |
		ADC #$0100					; |
		CMP #$0300 : BCS .Next				; | must be within this distance
		LDA !BG_object_Y,x				; | precision not important, this is just to save cycles
		SBC $1C						; |
		ADC #$0100					; |
		CMP #$0300 : BCS .Next				;/

		LDA $00						; A = type num
		STX $00						; $00 = index
		DEC A
		ASL A
		CMP.w #.Ptr_end-.Ptr : BCS .Next
		TAX
		JSR (.Ptr,x)

	.Next	TXA
		CLC : ADC.w #!BG_object_Size
		TAX
		CPX.w #(!BG_object_Size)*(!BG_object_Count) : BCC .Loop


		.CCDMA						;\
		SEP #$30					; |
		LDA $F6+1 : BMI ..fail				; |
		LDA.b #!VRAMbank				; |
		PHA : PLB					; |
		REP #$30					; |
		JSL !GetBigCCDMA : BCS ..fail			; |
		LDA $F6						; |
		CMP #$007E					; |
		BCC $03 : LDA #$007E				; | run CCDMA if anything was rendered this frame
		INC #2						; |
		ASL #4						; |
		STA !CCDMAtable+$00,x				; |
		LDA.w #!GFX_buffer : STA !CCDMAtable+$02,x	; |
		LDA.w #!GFX_buffer>>16 : STA !CCDMAtable+$04,x	; |
		LDA #$03C0*$10 : STA !CCDMAtable+$05,x		; |
		SEP #$20					; |
		LDA #$15 : STA !CCDMAtable+$07,x		; |
		..fail						;/



		PLP
		PLB
		RTS



		.Ptr
		dw Bush			; 01
		dw Window		; 02
		dw Cannon		; 03
		dw Cable		; 04
		dw Pole			; 05
		dw Pole			; 06
		dw Keyhole		; 07 (invisible BG object spawned by sprite marker)
		dw TrashCan		; 08
		dw KeyBlock		; 09
		..end




incsrc "SpriteSize.asm"




incsrc "BG_objects/Bush.asm"
incsrc "BG_objects/Window.asm"
incsrc "BG_objects/Cannon.asm"
incsrc "BG_objects/Cable.asm"
incsrc "BG_objects/Pole.asm"
incsrc "BG_objects/Keyhole.asm"
incsrc "BG_objects/TrashCan.asm"
incsrc "BG_objects/KeyBlock.asm"




; translate position into tilemap address
; 	then upload row by row

; $00:	16-bit pointer to tilemap data
; $02:	current VRAM Y address
; $04:	starting VRAM X address
; $06:	current VRAM X address
; $08:	ending VRAM X address
; $0A:	starting X coordinate
; $0C:	ending VRAM Y address
; $0E:	location on page 3

; $45:	left border of zip box
; $47:	right border of zip box
; $49:	top border of zip box
; $4B:	bottom border of zip box


; input:
;	$00 = pointer to tile table
;	$0E = base tile (tttttttt), added to tile num from tilemap
;	$0F = base prop (YXPCCCTT), used for entire tilemap (tilemap can specify X/Y flip, however)

	TileUpdate:

		.Setup
		LDA !BG_object_X,x				;\
		AND #$FFF8					; | base X position
		STA $9A						;/
		STA $0A						; > keep this in $0A
		LSR #3						;\
		AND #$003F					; |
		BIT #$0020					; | base VRAM X address
		BEQ $03 : ORA #$0400				; |
		AND #$041F					; |
		STA $04						;/
		LDA !BG_object_Y,x				;\
		AND #$FFF8					; | base Y position
		STA $98						;/
		AND #$00F8					;\
		ASL #2						; | base VRAM Y address
		STA $02						;/
		LDA !BG_object_W,x				;\ ending VRAM address (X + W)
		AND #$00FF					;/
		ADC $04						;\
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
		AND #$03E0					; |
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

		.Update
		PHX						;\ push stuff
		PHB : PHK : PLB					;/
		LDA !VRAMbase+!TileUpdateTable : TAX		; X = tile update index
		LDY #$0000					; Y = source data index
		LDA $04 : STA $06				; start new row
		..loop						;\
		LDA $9A						; |
		CMP !BG1ZipBoxL : BCC ..next			; |
		CMP !BG1ZipBoxR : BCS ..next			; | check tiles individually
		LDA $98						; |
		CMP !BG1ZipBoxU : BCC ..next			; |
		CMP !BG1ZipBoxD : BCS ..next			;/
		..valid						;\
		LDA $06						; |
		ORA $02						; | write VRAM address
		ORA !BG1Address					; |
		STA !VRAMbase+!TileUpdateTable+2,x		;/
		SEP #$20					;\
		LDA ($00),y					; |
		AND #$C0					; | get prop (yx------ ^ $0F)
		EOR $0F						; |
		XBA						;/
		LDA ($00),y					;\
		AND #$3F					; | get tile num (--tttttt + $0E)
		CLC : ADC $0E					; |
		REP #$20					;/
		STA !VRAMbase+!TileUpdateTable+4,x		; store to table
		INX #4						; increment write index
		..next						;\
		LDA $9A						; | x+8
		CLC : ADC #$0008				; |
		STA $9A						;/
		LDA $06						;\ increment address
		INC A						;/
		CMP #$0020 : BEQ ..400				;\
		CMP #$0420 : BNE +				; | wrap between tilemaps
	..000	LDA #$0000 : BRA +				; |
	..400	LDA #$0400					;/
	+	CMP $08 : BNE +					;\
		LDA $0A : STA $9A				; > reset x
		LDA $98						;\
		CLC : ADC #$0008				; > y+8
		STA $98						; |
		LDA $02						; |
		CLC : ADC #$0020				; | if at the end, start a new row
		AND #$03E0					; |
		STA $02						; |
		LDA $04						; |
	+	STA $06						;/
		INY						; increment read index
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



; input: void
; output:
;	carry: 0 = no contact, 1 = contact
;	Y = index to hitbox (only if contact)
	CheckHitbox:
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

		.Main
		PHX						;\
		PHB : PHK : PLB					; | reg/bank setup
		SEP #$30					;/
		LDY #$00

	.CheckHitbox
		LDA !P2Hitbox1Shield-$80,y : BNE .Hitbox2	; no hit if a shield blocks the way
		LDA !P2Hitbox1W-$80,y
		ORA !P2Hitbox1H-$80,y
		BEQ .Hitbox2
		LDA !P2Hitbox1XLo-$80,y : STA $00
		LDA !P2Hitbox1XHi-$80,y : STA $08
		LDA !P2Hitbox1YLo-$80,y : STA $01
		LDA !P2Hitbox1YHi-$80,y : STA $09
		LDA !P2Hitbox1W-$80,y : STA $02
		LDA !P2Hitbox1H-$80,y : STA $03
		JSL !Contact16 : BCS .YesContact

		.Hitbox2
		CPY #$81 : BCS .NoContact
		TYA : BNE .Player2
		CLC : ADC.b #!P2Hitbox2Offset
		TAY
		BRA .CheckHitbox

	.Player2
		CPY #$80 : BCS .NoContact
		LDA !MultiPlayer : BEQ .NoContact
		LDY #$80 : BRA .CheckHitbox

		.NoContact
		REP #$30
		PLB
		PLX
		CLC
		RTS

	.YesContact
		REP #$30
		PLB
		PLX
		SEC
		RTS



; input:
;	regs 8-bit
;	DB = K
;	X = index to key sprite
;	$02 = item memory bit of BG_object (8-bit)
;	$0C = index to BG_object (16-bit)
;	$0E = item memory index of BG_object (16-bit, negative means no index)

; output:
;	A 8-bit
;	index 16-bit
	UnlockObject:

		.PuffKey
		LDA #$04 : STA $3230,x				;\ puff key
		LDA #$1F : STA $32D0,x				;/

		.KeyMem
		LDA !ExtraProp2,x				;\
		AND #$03					; | check if key has an item mem bit
		CMP #$03 : BEQ ..nomem				;/
		XBA						;\
		LDA !ExtraProp2,x				; |
		LSR #2						; |
		AND #$07 : TAY					; |
		LDA #$01					; | unpack item memory bit
		..loop						; |
		DEY : BMI ..thisbit				; |
		ASL A : BRA ..loop				; |
		..thisbit					; |
		STA $02						;/
		LDA !ExtraProp1,x				;\
		REP #$30					; |
		TAX						; |
		SEP #$20					; | set item memory bit for key
		LDA $02						; |
		ORA !ItemMem0,x : STA !ItemMem0,x		; |
		SEP #$30					; |
		..nomem						;/

		.BG_Mem
		REP #$10					;\
		LDX $0E : BMI .Return				; | set item memory bit for BG_object
		LDA $02						; |
		ORA !ItemMem0,x : STA !ItemMem0,x		;/

		.Return
		RTS



; input:
;	$98 = Y coord
;	$9A = X coord

	PuffTile:
		LDA #$0025 : JSL !ChangeMap16
		STZ $00
		STZ $02
		STZ $04
		LDA.w #!prt_smoke16x16 : JSL !SpawnParticleBlock
		RTS

; input:
;	$98 = Y coord
;	$9A = X coord

	WaterTile:
		LDA #$0002 : JSL !ChangeMap16
		STZ $00
		STZ $02
		STZ $04
		LDA.w #!prt_smoke16x16 : JSL !SpawnParticleBlock
		RTS



namespace off



























