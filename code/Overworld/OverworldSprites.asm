


	OverworldSprites:
		LDX #$0000
		.Loop
		LDA !OW_sprite_Num,x
		AND #$007F : BEQ .Next
		CMP.w #(.List_end-.List-1)*2 : BCS .Next
		ASL A
		PEA.w .Next-1
		PHX
		TAX
		JMP (.List-2,x)

		.Next
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CPX.w #(!OW_sprite_Size)*!OW_sprite_Count : BCC .Loop

		.Done
		RTS



		.List
		dw WarpPipe		; 01
		dw GhostZone		; 02
		dw RevealFlash		; 03
		dw Explosion		; 04
		dw CrashingAirship	; 05
		dw BlastHandler		; 06
		..end


	DrawSprites:
		LDX #$0000
		.Loop
		LDA !OW_sprite_Num,x
		AND #$007F : BEQ .Next
		LDA !OW_sprite_Tilemap,x : BEQ .Next
		JSR DrawSpriteMain
		STZ !OW_sprite_Tilemap,x
		.Next
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CPX.w #(!OW_sprite_Size)*!OW_sprite_Count : BCC .Loop
		.Done
		RTS


incsrc "Sprites/WarpPipe.asm"
incsrc "Sprites/GhostZone.asm"
incsrc "Sprites/RevealFlash.asm"
incsrc "Sprites/Explosion.asm"
incsrc "Sprites/CrashingAirship.asm"
incsrc "Sprites/BlastHandler.asm"




	SpriteSpeed:
		REP #$20
		LDY #$0000
		LDA !OW_sprite_XSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_XFraction,x
		STA !OW_sprite_XFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_X+1,x
		STA !OW_sprite_X+1,x
		REP #$20
		LDY #$0000
		LDA !OW_sprite_YSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_YFraction,x
		STA !OW_sprite_YFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_Y+1,x
		STA !OW_sprite_Y+1,x
		REP #$20
		LDY #$0000
		LDA !OW_sprite_ZSpeed,x
		AND #$00FF
		ASL #4
		CMP #$0800
		BCC $04 : ORA #$F000 : DEY
		CLC : ADC !OW_sprite_ZFraction,x
		STA !OW_sprite_ZFraction,x
		SEP #$20
		TYA
		ADC !OW_sprite_Z+1,x
		STA !OW_sprite_Z+1,x
		RTS


; RAM use:
; $00	on-screen X (of sprite)
; $02	on-screen Y (of sprite, includes Z axis)
; $04	pointer to tilemap
; $06	Xflip flag (of sprite, 0x40 bit)
; $08	tilemap byte count
; $0A	S bit flag (of tile, 0x80 bit)
; $0C	on-screen X (of tile)
; $0E	pointer to S bit

; input:
;	A = 16-bit pointer to tilemap
; output:
;	void

; tilemap format:
;	1 byte size header, number of bytes to read
;	for each tile, 5 bytes:
;	- x
;	- y
;	- tile
;	- prop (raw, there's no palset mapping on overworld)
;	- size

	DrawSpriteMain:
		STA $04					; main pointer
		CLC : ADC #$0005			;\ S-bit pointer (+4, +past header)
		STA $0E					;/
		LDA !OW_sprite_X,x			;\
		SEC : SBC $1A				; | base on-screen X
		STA $00					;/
		LDA !OW_sprite_Y,x			;\
		SEC : SBC $1C				; | base on-screen Y
		STA $0C					;/
		SEC : SBC !OW_sprite_Z,x		;\ base Y coord to draw to (Y - Z)
		STA $02					;/
		LDA !OW_sprite_Direction,x		;\
		AND #$0001				; |
		BEQ $03 : LDA #$0040			; | base x-flip
		EOR #$0040				; |
		STA $06					;/
		LDY #$0000				;\
		LDA ($04)				; | byte count of tilemap
		AND #$00FF : STA $08			; |
		INC $04					;/
		PHX					;\
		LDX !MapOAMindex			; | create new tilemap in OAM data
		LDA $0C : STA !MapOAMdata+0,x		;/

		.Loop					;\
		LDA ($0E),y				; |
		AND #$0002				; | size flag (n flag trigger)
		BEQ $03 : LDA #$8000			; |
		STA $0A					;/
		LDA ($04),y				;\
		INY					; > +1 to index
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		BIT $06-1 : BVC ..noflip		; | x coord (flip from direction, also +8 if a small tile is flipped)
		EOR #$FFFF : INC A			; |
		BIT $0A : BMI ..noflip			; |
		CLC : ADC #$0008			; |
		..noflip				; |
		CLC : ADC $00				;/
		CMP #$FFF0 : BCS .GoodX			;\ check if tile is on-screen
		CMP #$0100 : BCC .GoodX			;/
		.BadCoord				;\
		INY #4					; | bad coord: +4 (adds up to +5) to index, then loop
		CPY $08 : BCC .Loop			; |
		BRA .Done				;/
		.GoodX					;\ store tile x
		STA $0C					;/
		LDA ($04),y				;\
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; | get y position
		CLC : ADC $02				; |
		CMP #$FFF0 : BCS .GoodY			; |
		CMP #$00E0 : BCS .BadCoord		; |
		.GoodY					;/

		SEP #$20				;\ store y
		STA !MapOAMdata+5,x			;/
		LDA $0C : STA !MapOAMdata+4,x		; store x
		INY					;\ store tile
		LDA ($04),y : STA !MapOAMdata+6,x	;/
		INY					;\
		LDA ($04),y				; | store prop
		EOR $06					; |
		STA !MapOAMdata+7,x			;/
		INY					;\
		LDA $0D					; |
		AND #$01				; | store hi byte
		ORA ($04),y				; |
		STA !MapOAMdata+8,x			;/
		INY					;\
		REP #$20				; |
		TXA					; | increment both indexes
		CLC : ADC #$0005			; |
		TAX					;/
		CPY $08 : BCS .Done			;\ loop
		JMP .Loop				;/

		.Done
		TXA					;\
		SEC : SBC !MapOAMindex			; | if nothing was written, return
		BEQ .Return				;/
		LDY !MapOAMindex			;\ store number of bytes written
		STA !MapOAMdata+2,y			;/
		TXA					;\
		CLC : ADC #$0004			; | increase map OAM index
		STA !MapOAMindex			; |
		INC !MapOAMcount			;/

		.Return					;\
		PLX					; | return
		RTS					;/


; if returning carry is set, an index could not be found (defaults to index 0)
; otherwise, X = index to a free sprite slot
	GetSpriteIndex:
		PHP
		REP #$30
		LDX #$0000
		.Loop
		LDA !OW_sprite_Num,x
		AND #$00FF : BEQ .ThisOne
		TXA
		CLC : ADC.w #!OW_sprite_Size
		TAX
		CMP.w #(!OW_sprite_Size)*!OW_sprite_Count : BCC .Loop
		PLP
		LDX #$0000
		SEC
		RTS

		.ThisOne
		PLP
		CLC
		RTS


; does not reset num or coords, those should be set separately
	ResetSprite:
		PHP
		REP #$20
		STZ !OW_sprite_Anim,x
	;	STZ !OW_sprite_AnimTimer,x
		STZ !OW_sprite_Z,x
	;	STZ !OW_sprite_Z+1,x
		STZ !OW_sprite_Tilemap,x
	;	STZ !OW_sprite_Tilemap+1,x
		SEP #$20
		STZ !OW_sprite_Timer,x
		STZ !OW_sprite_XFraction,x
		STZ !OW_sprite_YFraction,x
		STZ !OW_sprite_ZFraction,x
		STZ !OW_sprite_XSpeed,x
		STZ !OW_sprite_YSpeed,x
		STZ !OW_sprite_ZSpeed,x
		STZ !OW_sprite_Direction,x
		PLP
		RTS


; input:
;	void
; output:
;	BEQ -> camera at target, BNE -> camera not at target
	SpriteCamera:
		LDA !OW_sprite_X,x
		SEC : SBC #$0078
		STA $00
		LDA !OW_sprite_Y,x
		SEC : SBC #$0078
		STA $02
		JMP UpdateCamera


; input: void
; output: void
	RandomExplosions:
		SEP #$20
		INC !OW_sprite_Timer,x
		REP #$20
		LDA !OW_sprite_Timer,x
		AND #$0007 : BNE .Return
		LDA !RNG
		AND #$000F
		ASL A
		SBC #$000F
		ADC !OW_sprite_X,x
		STA $00
		LDA !RNG
		LSR #3
		AND #$000F*2
		SBC #$000F
		ADC !OW_sprite_Y,x
		STA $02
		LDA !OW_sprite_Z,x : STA $04
		PHX
		JSR GetSpriteIndex
		JSR ResetSprite
		LDA $00 : STA !OW_sprite_X,x
		LDA $02 : STA !OW_sprite_Y,x
		LDA $04 : STA !OW_sprite_Z,x
		LDA #$0004 : STA !OW_sprite_Num,x
		PLX
		.Return
		RTS









