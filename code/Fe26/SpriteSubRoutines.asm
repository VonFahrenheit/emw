;=======================;
; GENERIC SUPPORT CODES ;
;=======================;


; input: void
; output: void
SPRITE_OFF_SCREEN:
		PHB : PHK : PLB
		STZ $3490,x
		STZ $3350,x
	;	LDA !RAM_ScreenMode
	;	LSR A
	;	LDA $3250,x
	;	BCC .HorizontalLevel
	;	.VerticalLevel
	;	BEQ .VertY
	;	DEC A : BEQ .VertY
	;	LDA $3220,x
	;	CMP #$F0 : BCS .VertY				; Can be up to 16px off the screen on the left
	;	INC $3350,x
	;	.VertY
	;	LDA $3240,x
	;	XBA
	;	LDA $3210,x
	;	REP #$20
	;	SEC : SBC $1C
	;	CLC : ADC #$0060				;\ Used to be add 0x0040 compare to 0x0140
	;	CMP #$01C0					;/
	;	SEP #$20
	;	ROL A
	;	AND #$01
	;	STA $3490,x
	;	BRA .GoodY
	;	.HorizontalLevel
		LDA $3250,x
		XBA
		BIT !CameraBoxU+1 : BPL .GoodX
		LDA $3470,x
		AND #$04 : BNE .GoodX
		LDA $3220,x
		REP #$20
		SEC : SBC $1A
		CLC : ADC #$0060
		CMP #$01C0
		SEP #$20
		ROL A
		AND #$01
		STA $3350,x
		.GoodX
		LDA $6BF4
		AND #$03
		ASL A
		TAY
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		BIT !CameraBoxU : BMI .NoBoxY
		CMP !CameraBoxU : BCC .NoBoxY
		SBC #$00E0 : BMI .GoodY
		CMP !CameraBoxD : BCC .GoodY

		.NoBoxY
		CMP !LevelHeight : BCS .OutOfBoundsY
		STA $00
		LDA $1C
		CLC : ADC.w InitSpriteEngine_min_y_range,y
		CMP $00 : BPL .OutOfBoundsY
		LDA $1C
		CLC : ADC.w InitSpriteEngine_max_y_range,y
		CMP $00 : BPL .GoodY

;		SEC : SBC $1C
;		BPL +
;		EOR #$FFFF
;		LDY #$00
;		BRA ++
;	+	LDY #$02
;	++	CMP.w .YBounds,y
;		SEP #$20
;		BCC .GoodY

		.OutOfBoundsY
		SEP #$20
		INC $3490,x
		.GoodY
		SEP #$20
		LDA $3350,x
		ORA $3490,x
		BEQ .Return
		LDA !SpriteTweaker4,x
		AND #$04 : BNE .Return
		LDA $3230,x
		CMP #$08 : BCC .Kill
		LDY $33F0,x
		CPY #$FF : BEQ .Kill
		PHX
		TYX
		LDA $418A00,x					;\ 0xEE means don't respawn ever
		CMP #$EE : BEQ +				;/
		LDA #$00					;\ Respawn
		STA $418A00,x					;/
	+	PLX
		.Kill
		STZ $3230,x
		.Return
		PLB
		RTL

;		.YBounds
;		dw $00E0,$01C0					; above, below




; input: void
; output: void
	SPRITE_SPINKILL:
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		PHY
		JSL $07FC3B
		PLY
		LDA #$08 : STA !SPC1
		RTL


; input: void (for _Target, Y = player index)
; output:
;	A = sprite X - player X
;	Y = 0 if player on the left, 1 if player on the right
	SUB_HORZ_POS:
		LDA !P2Status-$80 : BNE .P2
.P1		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTL
.P2		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status : BNE .P1
		LDY #$00
		LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo
		SEP #$20
		BPL .Set
		RTL

		.Target
		LDA !P2Status-$80,y : BEQ ..go
		TYA
		EOR #$80
		TAY
	..go	LDA $3250,x : XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo-$80,y
		SEP #$20
		BPL ..1
	..0	LDY #$00
		RTL
	..1	LDY #$01
		RTL


; input: void (for _Target, A = offset and Y = player index)
; output:
;	A = sprite Y - player Y
;	Y = 0 if player below, 1 if player above
	SUB_VERT_POS:
		LDA !P2Status-$80 : BNE .P2
.P1		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo-$80
		SEP #$20
		BMI .Return
.Set		INY
.Return		RTL
.P2		LDA !MultiPlayer : BEQ .P1
		LDA !P2Status : BNE .P1
		LDY #$00
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		SEC : SBC !P2YPosLo
		SEP #$20
		BPL .Set
		RTL

		.Target
		STA $00
		STZ $01
		BPL $02 : DEC $01
		LDA !P2Status-$80,y : BEQ ..go
		TYA
		EOR #$80
		TAY
	..go	LDA $3240,x : XBA
		LDA $3210,x
		REP #$20
		CLC : ADC $00
		SEC : SBC !P2YPosLo-$80,y
		SEP #$20
		BPL ..1
	..0	LDY #$00
		RTL
	..1	LDY #$01
		RTL


; input: void
; output: void
	GroundSpeed:
		LDA !SpriteSlope,x
		BPL $03 : EOR #$FF : INC A
		TAX
		LDA.l .SlopeSpeed,x
		LDX !SpriteIndex
		STA !SpriteYSpeed,x
		RTL

		.SlopeSpeed
		db $00,$10,$10,$20,$40


; input: A = target X speed
; output: void
	AccelerateX:
		CMP #$00 : BMI .GoLeft
		.GoRight
		INC !SpriteXSpeed,x
		INC !SpriteXSpeed,x
		BMI .Return
		CMP !SpriteXSpeed,x : BCC .Limit
		RTL
		.GoLeft
		DEC !SpriteXSpeed,x
		DEC !SpriteXSpeed,x
		BPL .Return
		CMP !SpriteXSpeed,x : BCS .Limit
		RTL
		.Limit
		STA !SpriteXSpeed,x
	.Return	RTL


	.Friction
	.Friction1
		LDA !SpriteXSpeed,x : BEQ ..0
		BPL ..dec
	..inc	INC !SpriteXSpeed,x
		RTL
	..dec	DEC !SpriteXSpeed,x
		RTL
	..0	STZ !SpriteXSpeed,x
		RTL

	.Friction2
		LDA !SpriteXSpeed,x : BEQ .Friction1_0
		BPL ..dec
	..inc	CMP #$FF : BEQ .Friction1_0
		INC !SpriteXSpeed,x
		RTL
	..dec	CMP #$01 : BEQ .Friction1_0
		DEC !SpriteXSpeed,x
		RTL


	.Unlimit
	.Unlimit1
		CMP !SpriteXSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..left					; see if target is left/right
		..right						;\
		BIT !SpriteXSpeed,x : BMI ..inc			; |
		CMP !SpriteXSpeed,x : BCC ..dec			; | accel: target right
	..inc	INC !SpriteXSpeed,x				; |
		RTL						;/
		..left						;\
		BIT !SpriteXSpeed,x : BPL ..dec			; |
		CMP !SpriteXSpeed,x : BCS ..inc			; | accel: target left
	..dec	DEC !SpriteXSpeed,x				; |
		RTL						;/

	.Unlimit2
		CMP !SpriteXSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..left					; see if target is left/right
		..right						;\
		BIT !SpriteXSpeed,x : BMI ..inc			; |
		CMP !SpriteXSpeed,x : BCC ..dec			; | accel: target right
	..inc	INC !SpriteXSpeed,x				; |
		INC !SpriteXSpeed,x				; |
		RTL						;/
		..left						;\
		BIT !SpriteXSpeed,x : BPL ..dec			; |
		CMP !SpriteXSpeed,x : BCS ..inc			; | accel: target left
	..dec	DEC !SpriteXSpeed,x				; |
		DEC !SpriteXSpeed,x				; |
		RTL						;/




; input: A = target Y speed
; output: void
	AccelerateY:
		CMP #$00 : BMI .GoUp
		.GoDown
		INC !SpriteYSpeed,x
		INC !SpriteYSpeed,x
		BMI .Return
		CMP !SpriteYSpeed,x : BCC .Limit
		RTL
		.GoUp
		DEC !SpriteYSpeed,x
		DEC !SpriteYSpeed,x
		BPL .Return
		CMP !SpriteYSpeed,x : BCS .Limit
		RTL
		.Limit
		STA !SpriteYSpeed,x
	.Return	RTL


	.Friction
	.Friction1
		LDA !SpriteYSpeed,x : BEQ ..0
		BPL ..dec
	..inc	INC !SpriteYSpeed,x
		RTL
	..dec	DEC !SpriteYSpeed,x
		RTL
	..0	STZ !SpriteYSpeed,x
		RTL


	.Unlimit
	.Unlimit1
		CMP !SpriteYSpeed,x : BEQ .Return		; return if alreaddy at target speed
		CMP #$00 : BEQ .Friction1			; just use friction1 if target speed = 0
		BMI ..up					; see if target is up/down
		..down						;\
		BIT !SpriteYSpeed,x : BMI ..inc			; |
		CMP !SpriteYSpeed,x : BCC ..dec			; | accel: target down
	..inc	INC !SpriteYSpeed,x				; |
		RTL						;/
		..up						;\
		BIT !SpriteYSpeed,x : BPL ..inc			; |
		CMP !SpriteYSpeed,x : BCS ..inc			; | accel: target up
	..dec	DEC !SpriteYSpeed,x				; |
		RTL						;/


; input: void
; output: void
	MakeGlitter:
		TXA
		CLC : ADC $14
		AND #$0F : BNE .Return
	.Loop	%Ex_Index_Y()
		LDA #$02+!MinorOffset : STA !Ex_Num,y
		LDA !RNG
		AND #$0F
		ASL A
		SEC : SBC #$10
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3210,x
		STA !Ex_YLo,y
		LDA $3240,x
		ADC $00
		STA !Ex_YHi,y
		LDA !RNG
		LSR #3
		AND #$17
		SEC : SBC #$08
		STZ $00
		BPL $02 : DEC $00
		CLC : ADC $3220,x
		STA !Ex_XLo,y
		LDA $3250,x
		ADC $00
		STA !Ex_XHi,y
		LDA #$1F : STA !Ex_Data1,y
	.Return	RTL



; input: A = palset to load
; output: void
	LoadPalset:
		STA $0F
		LDA.l !LoadPalset : STA $00
		LDA.l !LoadPalset+1 : STA $01
		LDA.l !LoadPalset+2 : STA $02
		LDA $0F
		JML [$3000]


; normal version just checks for contact
; _Destroy version will also destroy the fireball that touches the sprite (only 1 per frame, there is no way that this can cause problems, future Eric, i know what you're thinking!)
; input: sprite hurtbox loaded in $04 slot ($04-$07, $0A-$0B)
; output:
;	C set if contact, C clear if no contact
;	Y = fireball fusion index
;	$00: fireball X speed (converted to sprite format, but halved)
	FireballContact:
		LDY #!Ex_Amount-1
	-	JSR .Main : BCS .Return
		DEY : BPL -
		CLC
		RTL

	.Destroy
		LDY #!Ex_Amount-1
	-	JSR .Main : BCS ..puff
		DEY : BPL -
		CLC
		RTL
	..puff	LDA #$0F : STA !Ex_Data2,y			; don't mess with carry here! it has to return set
		LDA #$01+!ExtendedOffset : STA !Ex_Num,y	; smoke puff num
		LDA #$01 : STA !SPC1				; SFX
	.Return	LDA !Ex_XSpeed,y				;\
		ASL #3						; |
		CMP #$40					; | fireball speed output
		BCC $02 : ORA #$80				; |
		STA $00						;/
		SEC						; set C
		RTL						; return


	; main JSR
		.Main
		LDA !Ex_Num,y
		AND #$7F
		CMP #$05+!ExtendedOffset : BEQ .Check		; check mario fireball
		CMP #$02+!CustomOffset : BNE .ReturnC		; check luigi fireball
	.Check	LDA !Ex_YLo,y : STA $01
		LDA !Ex_XLo,y : STA $00
		LDA !Ex_YHi,y : STA $09
		LDA !Ex_XHi,y : STA $08
		LDA #$08
		STA $02
		STA $03
		PHY
		JSL !Contact16
		PLY
		RTS

	.ReturnC
		CLC
		RTS



; input: A = 16-bit pointer to hitbox data (hitbox based on facing left)
; output: hitbox loaded in $04 slot
	LOAD_HITBOX:
		REP #$30				; all regs 16-bit
		TAY					; Y = index to hitbox data
		SEP #$20				;\
		LDA !SpriteXLo,x : STA $0C		; |
		LDA !SpriteXHi,x : STA $0D		; | get sprite coords
		LDA !SpriteYHi,x : XBA			; |
		LDA !SpriteYLo,x			; |
		REP #$20				;/
		CLC : ADC $0002,y			;\
		STA $05					; | Y coords
		STA $0A					;/

		LDA $0004,y : STA $06			; W + H
		AND #$00FF : STA $0E			; W, 16-bit

		LDA $0000,y				; read X offset
		SEP #$10				; index 8-bit
		LDY $3320,x : BNE .Left			; check direction
		.Right					;\
		EOR #$FFFF				; |
		CLC : ADC #$0010			; | facing left adjustment
		SEC : SBC $0E				; |
		.Left					;/
		CLC : ADC $0C				;\
		SEP #$20				; | add sprite Xpos and store
		STA $04					; |
		XBA : STA $0A				;/
		RTL					; return

; debug: display hitbox
;	PEI ($04)
;	PEI ($06)
;	PEI ($0A)
;	LDA $3320,x : PHA
;	LDA #$01 : STA $3320,x
;	LDA !SpriteXLo,x : PHA
;	LDA !SpriteXHi,x : PHA
;	LDA !SpriteYLo,x : PHA
;	LDA !SpriteYHi,x : PHA
;	LDA $04 : STA !SpriteXLo,x
;	LDA $0A : STA !SpriteXHi,x
;	LDA $05 : STA !SpriteYLo,x
;	LDA $0B : STA !SpriteYHi,x
;	REP #$20
;	LDA #$0010 : STA !BigRAM+$00
;	STZ !BigRAM+$03
;	STZ !BigRAM+$07
;	STZ !BigRAM+$0B
;	STZ !BigRAM+$0F
;	LDA #!BigRAM : STA $04
;	SEP #$20
;	LDA #$32
;	STA !BigRAM+$02
;	STA !BigRAM+$06
;	STA !BigRAM+$0A
;	STA !BigRAM+$0E
;	LDA #$6E
;	STA !BigRAM+$05
;	STA !BigRAM+$09
;	STA !BigRAM+$0D
;	STA !BigRAM+$11
;	LDA $06
;	SEC : SBC #$10
;	STA !BigRAM+$07
;	STA !BigRAM+$0F
;	LDA $07
;	SEC : SBC #$10
;	STA !BigRAM+$0C
;	STA !BigRAM+$10
;	JSL LOAD_TILEMAP_p3
;	PLA : STA !SpriteYHi,x
;	PLA : STA !SpriteYLo,x
;	PLA : STA !SpriteXHi,x
;	PLA : STA !SpriteXLo,x
;	PLA : STA $3320,x
;	REP #$20
;	PLA : STA $0A
;	PLA : STA $06
;	PLA : STA $04
;	SEP #$20
;	RTL




; input: void
; output: void
	OutputShieldBox:
		PHB
		LDA.b #!ShieldData>>16
		PHA : PLB
		TXA
		STA $00
		ASL A
		ADC $00
		ASL A
		TAY
		LDA $04 : STA.w !ShieldXLo,y
		LDA $0A : STA.w !ShieldXHi,y
		LDA $05 : STA.w !ShieldYLo,y
		LDA $0B : STA.w !ShieldYHi,y
		LDA $06 : STA.w !ShieldW,y
		LDA $07 : STA.w !ShieldH,y
		INC.w !ShieldExists
		PLB
		RTL



; input:
;	A = collision points to interact with (01 = right, 02 = left, 04 = down, 08 = up, 10 = center/crush point)
;	sprite clipping loaded in $04 slot ($04-$07, $0A-$0B)
; output: void
	OutputPlatformBox:
		PHX					; push X
		STA $00					; preserve status
		STZ $2250				;\
		STX $2251				; |
		STZ $2252				; | calculate platform data index
		LDA.b #!PlatformByteCount : STA $2253	; |
		STZ $2254				;/
		LDA !SpriteDeltaY,x : XBA		;\ sprite delta
		LDA !SpriteDeltaX,x			;/
		TXY					; Y = sprite index
		LDX $2306				; X = platform data index
		STA !PlatformDeltaX,x			;\ platform delta
		XBA : STA !PlatformDeltaY,x		;/
		TYA : STA !PlatformSprite,x		; platform sprite index
		LDA $00 : STA !PlatformStatus,x		; set status
		LDA $04 : STA !PlatformXLeft+0,x	; left border lo
		CLC : ADC $06				;\ right border lo
		STA !PlatformXRight+0,x			;/
		LDA $0A : STA !PlatformXLeft+1,x	; left border hi
		ADC #$00				;\ right border hi
		STA !PlatformXRight+1,x			;/
		LDA $05 : STA !PlatformYUp+0,x		; up border lo
		CLC : ADC $07				;\ down border lo
		STA !PlatformYDown+0,x			;/
		LDA $0B : STA !PlatformYUp+1,x		; up border hi
		ADC #$00				;\ down border hi
		STA !PlatformYDown+1,x			;/
		LDA #$01 : STA !PlatformExists		; mark that players have to check for platform contact next frame
		PLX					; restore X
		RTL					; return


; input:
;	A = sprite num
;	C = custom bit
;	$00 = Xdisp (8-bit signed)
;	$01 = Ydisp (8-bit signed)
;	$02 = Xspeed
;	$03 = Yspeed
; output: Y = sprite number of spawned sprite (if Y = 0xFF, a sprite could not be spawned)
	SpawnSprite:
		STA $0E
		STZ $0F
		BCC $02 : INC $0F
		LDY #$0F
	.Loop	LDA $3230,y : BEQ .Spawn
		DEY : BPL .Loop
		RTL

		.Spawn
		PEI ($02)
		LDA $00
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3220,x
		STA $3220,y
		LDA $02
		ADC $3250,x
		STA $3250,y
		LDA $01
		STZ $02
		BPL $02 : DEC $02
		CLC : ADC $3210,x
		STA $3210,y
		LDA $02
		ADC $3240,x
		STA $3240,y
		LDA $0F : BNE .Custom

		.Vanilla
		LDA $0E : STA $3200,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		STZ !ExtraBits,x
		STZ !NewSpriteNum,x
		JSL !ResetSprite		; reset sprite tables
		BRA .Finish

		.Custom
		LDA $0E : STA !NewSpriteNum,y
		LDA #$08 : STA !ExtraBits,y
		LDA #$01 : STA $3230,y
		PHY
		PHX
		TYX
		JSL !ResetSprite		; reset sprite tables

		.Finish
		PLX
		PLY
		PLA : STA.w !SpriteXSpeed,y
		PLA : STA.w !SpriteYSpeed,y
		RTL

		.NoSpeed
		STZ $02
		STZ $03
		JMP SpawnSprite

		.SpriteSpeed
		LDA !SpriteXSpeed,x : STA $02
		LDA !SpriteYSpeed,x : STA $03
		JMP SpawnSprite


; input:
;	A = !Ex_Num
;	$00 = X offset (8-bit signed)
;	$01 = Y offset (8-bit signed)
;	$02 = X speed
;	$03 = Y speed
; output: Y = number of spawned ExSprite
	SpawnExSprite:
		.Main
		STA $08					; store ExSprite num

		LDA $01 : STA $04			;\
		STZ $05					; |
		BPL $02 : DEC $05			; | 16-bit offsets
		LDA $00					; |
		STZ $01					; |
		BPL $02 : DEC $01			;/

		%Ex_Index_Y()				; Y = index

		LDA $08 : STA !Ex_Num,y			; ExSprite number
		PHX					;\
		TAX					; |
		LDA.l .Ex_Data1,x : STA !Ex_Data1,y	; | load special values
		LDA.l .Ex_Data2,x : STA !Ex_Data2,y	; |
		LDA.l .Ex_Data3,x : STA !Ex_Data3,y	; |
		PLX					;/

		LDA $02 : STA !Ex_XSpeed,y		; X speed
		LDA $03 : STA !Ex_YSpeed,y		; Y speed
		LDA $3220,x				;\
		CLC : ADC $00				; |
		STA !Ex_XLo,y				; | Xpos
		LDA $3250,x				; |
		ADC $01					; |
		STA !Ex_XHi,y				;/
		LDA $3210,x				;\
		CLC : ADC $04				; |
		STA !Ex_YLo,y				; | Ypos
		LDA $3240,x				; |
		ADC $05					; |
		STA !Ex_YHi,y				;/

		RTL					; return

	.SpriteSpeed					;\
		LDA !SpriteXSpeed,x : STA $02		; | inherit sprite speeds
		LDA !SpriteYSpeed,x : STA $03		; |
		JMP .Main				;/

	.NoSpeed					;\
		STZ $02					; | spawn without speed
		STZ $03					; |
		JMP .Main				;/


		.Ex_Data1
		db $00,$00				; coin
		db $00,$00,$1F,$00,$0F,$1F,$0F,$0F	;\ minor
		db $00,$00,$0F,$00			;/
		db $00,$00,$00,$00,$00,$00,$00,$00	;\
		db $00,$00,$00,$00,$00,$00,$00,$00	; | extended
		db $00,$00,$00				;/
		db $00,$00,$08,$13,$00,$00		; smoke
		db $00,$00,$00				; quake
		db $00,$00,$00				; shooter
		db $00,$00,$00,$00			; custom

		.Ex_Data2
		db $00,$00				; coin
		db $00,$00,$1F,$00,$0F,$1F,$0F,$0F	;\ minor
		db $00,$00,$0F,$00			;/
		db $00,$00,$00,$00,$00,$00,$00,$00	;\
		db $00,$00,$00,$00,$00,$00,$00,$00	; | extended
		db $00,$00,$00				;/
		db $00,$00,$08,$13,$00,$00		; smoke
		db $00,$00,$00				; quake
		db $00,$00,$00				; shooter
		db $00,$00,$00,$00			; custom

		.Ex_Data3
		db $00,$00				; coin
		db $00,$00,$1F,$00,$0F,$1F,$0F,$0F	;\ minor
		db $00,$00,$0F,$00			;/
		db $00,$00,$00,$00,$00,$00,$00,$00	;\
		db $00,$00,$00,$00,$00,$00,$00,$00	; | extended
		db $00,$00,$00				;/
		db $00,$00,$08,$13,$00,$00		; smoke
		db $00,$00,$00				; quake
		db $00,$00,$00				; shooter
		db $00,$00,$00,$00			; custom





; input:
;	A = particle num
;	$00 = X offset (8-bit signed)
;	$01 = Y offset (8-bit signed)
;	$02 = X speed (sprite format)
;	$03 = Y speed (sprite format)
;	$04 = X acc
;	$05 = Y acc
;	$06 = tile
;	$07 = prop (S-PPCCCT, S is size bit, PP is mirrored to top 2 bits for layer prio + OAM prio)
; output:
;	$0E = index to spawned particle
;	mirrors the PP bits of $07 to the upper 2 bits, but the rest of $00-$07 remain
	SpawnParticle:
		PHX						; push X
		STA $0F						; $0F = particle num
		LDA $07						;\
		ROL #3						; | $0E = size bit
		AND #$02					; |
		STA $0E						;/
		LDA #$C0 : TRB $07				;\
		LDA $07						; |
		AND #$30					; | mirror PP bits
		ASL #2						; |
		TSB $07						;/
		LDA $01 : STA $08				;\
		STZ $09						; |
		BPL $02 : DEC $09				; |
		CLC : ADC $3210,x				; | $08 = 16-bit Ypos
		STA $08						; |
		LDA $3240,x					; |
		ADC $09						; |
		STA $09						;/
		LDA $00						;\
		STZ $0B						; |
		BPL $02 : DEC $0B				; |
		CLC : ADC $3220,x				; | $00 = 16-bit Xpos
		STA $0A						; |
		LDA $3250,x					; |
		ADC $0B						; |
		STA $0B						;/

		PHB						; push bank
		JSL !GetParticleIndex				; X = 16-bit particle index, bank = $41
		LDA $0A : STA !Particle_XLo,x			;\ particle coords
		LDA $08 : STA !Particle_YLo,x			;/
		LDA $06 : STA !Particle_Tile,x			; particle tile/prop
		LDA $02						;\
		AND #$00FF					; |
		ASL #4						; | particle X speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_XSpeed,x				;/
		LDA $03						;\
		AND #$00FF					; |
		ASL #4						; | particle Y speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_YSpeed,x				;/
		SEP #$20					; A 8-bit
		LDA $04 : STA !Particle_XAcc,x			;\ particle acc
		LDA $05 : STA !Particle_YAcc,x			;/
		LDA $0E : STA !Particle_Layer,x			; particle size bit
		LDA $0F : STA !Particle_Type,x			; particle num
		LDY #$00FF					; default timer = 0xFF
		CMP #!prt_smoke8x8				;\ timer for 8x8 smoke = 0x13
		BNE $03 : LDY #$0013				;/
		CMP #!prt_smoke16x16				;\ timer for 16x16 = 0x17
		BNE $03 : LDY #$0017				;/
		CMP #!prt_sparkle				;\ timer for sparkle = 0x20
		BNE $03 : LDY #$0020				;/
		TYA : STA !Particle_Timer,x			; store particle timer

		STX $0E						; save this index
		PLB						; restore bank
		SEP #$30					; all regs 8-bit
		PLX						; restore X
		RTL						; return



; input:
;	Y = index to pointer
;	$00 - X acc
;	$01 - Y acc
;	$02 - X speed (sprite format)
;	$03 - Y speed (sprite format)
;	$04 - pointer to tilemap
; output: $00 = index to spawned particle
	SpawnSpriteTile:
		PHX						; push X
		STY $0E						;\ $0E = 16-bit index to tilemap
		STZ $0F						;/
		LDA !SpriteTile,x : STA $06			; $06 = sprite tile offset lo
		LDA !SpriteProp,x				;\
		ORA $33C0,x					; | $07 = ----CCCT
		STA $07						;/
		LDA $3220,x : STA $08				;\ $08 = 16-bit Xpos
		LDA $3250,x : STA $09				;/
		LDA $3210,x : STA $0A				;\ $0A = 16-bit Ypos
		LDA $3240,x : STA $0B				;/
		STZ $0C						;\
		LDA $3320,x					; | $0C = flip bits for X coord
		BNE $02 : DEC $0C				;/

		PHB						; push bank
		JSL !GetParticleIndex				; get particle index

		LDA $00 : STA !Particle_XAcc,x			; particle X acc
		STA !Particle_YAcc-1,x				; write particle Y acc with hi byte

		LDA $02						;\
		AND #$00FF					; |
		ASL #4						; | particle X speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_XSpeed,x				;/
		LDA $03						;\
		AND #$00FF					; |
		ASL #4						; | particle Y speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_YSpeed,x				;/

		PLB						; restore bank
		LDY $0E						; Y = index to tilemap
		LDA ($04),y					;\
		BIT #$0001 : BEQ +				; |
		SEP #$20					; |
		AND #$EE					; |
		BIT $0C						; |
		BPL $02 : EOR #$40				; |
		LSR $07						; | static particle prop
		BCC $01 : INC A					; |
		REP #$20					; |
		STA !41_Particle_Prop,x				; |
		LDA ($04),y					; |
		AND #$0010					; |
		BEQ $03 : LDA #$0002				; |
		BRA ++						;/
	+	LDA ($04),y					;\
		AND #$00F0					; |
		BIT $0C-1					; | dynamic particle prop
		BPL $03 : EOR #$0040				; |
		ORA $07						; |
		STA !41_Particle_Prop,x				;/
		LDA ($04),y					;\
		AND #$0002					; | particle size bit
	++	STA !41_Particle_Layer,x			;/
		INY						;\
		LDA ($04),y					; |
		EOR $0C						; |
		AND #$00FF					; | particle Xpos
		CMP #$0080					; |
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $08					; |
		STA !41_Particle_XLo,x				;/
		INY						;\
		LDA ($04),y					; |
		AND #$00FF					; |
		CMP #$0080					; | particle Ypos
		BCC $03 : ORA #$FF00				; |
		CLC : ADC $0A					; |
		STA !41_Particle_YLo,x				;/
		INY						;\
		SEP #$20					; |
		LDA ($04),y					; | particle tile
		CLC : ADC $06					; |
		STA !41_Particle_Tile,x				;/

		LDA #$FF : STA !41_Particle_Timer,x		; particle timer
		LDA #!prt_spritepart : STA !41_Particle_Type,x	; particle type

		STX $00						; $00 = index to spawned particle
		SEP #$30					; all regs 8-bit
		PLX						; restore X
		RTL						; return



; input: A = GFX index
; output: !SpriteProp and !SpriteTile updated
	LoadGFXIndex:
		PHX
		REP #$30
		TAX
		LDA !GFX_status,x
		SEP #$30
		PLX
		STA !SpriteTile,x
		XBA : STA !SpriteProp,x
		RTL





; input:
; (targeting a player automatically)
;	A = speed
; (_Main: target player is already determined)
;	Y = target player index
;	$0F = speed
; output:
;	$04 = X speed
;	$06 = Y speed
	TARGET_PLAYER:
		STA $0F					; store speed
		LDY #$00				;\ if singleplayer, always target player 1
		LDA !MultiPlayer : BEQ .P1		;/
		LDA !P2Status-$80 : BNE .P2		; if player 1 is dead, target player 2
		LDA !P2Status : BNE .P1			; if player 2 is dead, target player 1
		LDA !RNG				;\
		AND #$80 : TAY				; | if both are alive, target a random player
		BRA .P1					;/
	.P2	LDY #$80
		.Main
	.P1	LDA $3220,x				;\
		SEC : SBC !P2XPosLo-$80,y		; |
		STA $00					; | DX
		LDA $3250,x				; |
		SBC !P2XPosHi-$80,y			; |
		STA $01					;/
		LDA $3210,x				;\
		SEC : SBC !P2YPosLo-$80,y		; |
		STA $02					; | DY
		LDA $3240,x				; |
		SBC !P2YPosHi-$80,y			; |
		STA $03					;/
		BRA AIM_SHOT_Main			; go to main code


; input:
;	A = speed
;	$00 = source X - target X
;	$02 = source Y - target Y
; output:
;	$04 = X speed
;	$06 = Y speed
;
; s = sqrt(dx^2 + dy^2)
;
; dx/x = s/0x40
;
; x = 0x40*dx/s
; y = 0x40*dy/s
;
; dx and dy are actually 15-bit.
	AIM_SHOT:
		STA $0F
	.Main	STZ $2250		; > Enable multiplication
		REP #$20
		STZ $0D			; > No shifts yet
		LDA $00
		BPL .Pos_dx
		EOR #$FFFF : INC A
.Pos_dx		STA $04			; $04 = |dx| (unscaled)

		LDA $02
		BPL .Pos_dy
		EOR #$FFFF
		INC A
.Pos_dy		STA $06			; $06 = |dy| (unscaled)
		LDY #$01		;\
		CMP $04			; | Load the largest of the two
		BCS $03 : LDA $04 : DEY	;/ > Y = 1, Y is bigger; Y = 0, X is bigger
		CMP #$0100 : BCC .0100	;\
		CMP #$0200 : BCC .0200	; |
		CMP #$0400 : BCC .0400	; |
		CMP #$0800 : BCC .0800	; |
		CMP #$1000 : BCC .1000	; |
		CMP #$2000 : BCC .2000	; | Downscale it
.4000		LSR A : INC $0D		; |
.2000		LSR A : INC $0D		; |
.1000		LSR A : INC $0D		; |
.0800		LSR A : INC $0D		; |
.0400		LSR A : INC $0D		; |
.0200		LSR A : INC $0D		; |
.0100		STA $08			;/
		LDA $06			;\
		CMP $04			; | Load the smaller of the two
		BCC $02 : LDA $04	;/

.Loop		DEC $0D : BMI .Scaled	;\ Downscale the other number
		LSR A : BRA .Loop	;/
.Scaled		CPY #$01 : BEQ .BigY	; > Determine which number is biggest
.BigX		STA $2251		;\
		STZ $2253		; |
		NOP			; | Calculate Y^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate X^2
		NOP			; |
		BRA .Shared		;/

.BigY		STA $2251		;\
		STA $2253		; |
		NOP			; | Calculate X^2
		BRA $00			; |
		LDA $2306 : STA $0A	;/
		LDA $08			;\
		STA $2251		; |
		STA $2253		; | Calculate Y^2
		NOP			; |
		BRA .Shared		;/

.Shared		LDA $2306
		CLC : ADC $0A
		JSL !GetRoot		; (handles 17-bit numbers)
		ROR A
		LSR #7
		STA $0A			; > $0A = distance
		LDA $0F
		AND #$00FF
		STA $2251
		LDA $04 : STA $2253
		NOP
		BRA $00
		LDA $2306
		STA $04			; > $04 = v*|dx|
		LDA $06 : STA $2253
		NOP
		BRA $00
		LDA $2306		; > A = v*|dy|
		LDY #$01 : STY $2250	; > Enable division
		STA $2251
		LDA $0A
		STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $02 : BMI +
		EOR #$00FF
		INC A
	+	STA $06			; > $06 = y
		LDA $04 : STA $2251
		LDA $0A : STA $2253
		NOP
		BRA $00
		LDA $2306
		BIT $00 : BMI +
		EOR #$00FF
		INC A
	+	STA $04			; > $04 = x
		SEP #$20
		RTL




;==========================;
; PLAYER INTERACTION CODES ;
;==========================;
; most of these require input Y = 0x00 for player 1 or 0x80 for player 2
; the sprite itself is responsible for making sure that player exists before calling a routine


; input: Y = player index
; output: void
	StompSound:
		PHX
		LDA !P2Character-$80,y : BEQ .Mario

		.PCE
		LDA !P2KillCount-$80,y
		CMP #$07 : BCS .Shared
		INC A
		STA !P2KillCount-$80,y
		DEC A
		BRA .Shared

		.Mario
		LDA $7697
		CMP #$07 : BCS .Shared
		INC $7697

		.Shared
		TAX
		CPX #$06
		BCC $02 : LDX #$06
		LDA.l .StarSounds,x : STA !SPC1
		.NoSound
		PLX
		RTL

		.StarSounds
		db $13,$14,$15,$16,$17,$18,$19

; input: Y = player index
; output: void
	SPRITE_STAR:
		PHX
		LDA #$02 : STA $3230,x
		LDA #$E8 : STA !SpriteYSpeed,x
		LDA !P2XSpeed-$80,y : STA !SpriteXSpeed,x
		LDA $78D2
		CMP #$08 : BCS +
		INC A
		STA $78D2
	+	TAX
		CPX #$06
		BCC $02 : LDX #$06
		LDA.l StompSound_StarSounds,x : STA !SPC1
		PLX
		RTL




; input:
;	sprite hurtbox in $04 slot ($04-$07, $0A-$0B)
; output:
;	C clear = no contact
;	C set = contact
;	Y = index to hitbox (00, 0A, 80 or 8A)
;
; normal version will not apply knockback
; _Knockback version will apply knockback
	P2Attack:
		STZ $0F

		.Main
		LDY #$00

	.CheckPlayer
	;	LDA !P2Status-$80,y : BNE .Player2

	.CheckHitbox
		LDA !P2Hitbox1Shield-$80,y : BNE .Hitbox2		; no hit if a shield blocks the way
		LDA !P2Hitbox1W-$80,y
		ORA !P2Hitbox1H-$80,y
		BEQ .Hitbox2

		CPX #$08 : BCS ..8F
	..07	LDA !P2Hitbox1IndexMem1-$80,y : BRA ..index
	..8F	LDA !P2Hitbox1IndexMem2-$80,y
	..index	AND.l .ContactBits,x : BNE .Hitbox2
		LDA !P2Hitbox1XLo-$80,y : STA $00
		LDA !P2Hitbox1XHi-$80,y : STA $08
		LDA !P2Hitbox1YLo-$80,y : STA $01
		LDA !P2Hitbox1YHi-$80,y : STA $09
		LDA !P2Hitbox1W-$80,y : STA $02
		LDA !P2Hitbox1H-$80,y : STA $03
		JSL !Contact16
		BCS .YesContact

		.Hitbox2
		CPY #$81 : BCS .NoContact
		TYA : BNE .Player2
		CLC : ADC.b #!P2Hitbox2Offset
		TAY
		BRA .CheckHitbox

	.Player2
		CPY #$80 : BCS .NoContact
		LDA !MultiPlayer : BEQ .NoContact
		LDY #$80 : BRA .CheckPlayer

		.NoContact
		CLC
		RTL

	.YesContact
		LDA !P2Hitbox1Hitstun-$80,y : STA $0C

		PHY
		CPX #$08
		BCC $01 : INY
		LDA.l .ContactBits,x
		ORA !P2Hitbox1IndexMem1-$80,y
		STA !P2Hitbox1IndexMem1-$80,y
		LDA $0C
		CMP #$06 : BCC ..small
		TYA
		AND #$80
		TAY
		LDA !P2Character-$80,y
		CMP #$02 : BNE ..gosmall
		JSL P2BigContactGFX
		BRA .NotLeeway
		..small
		TYA
		AND #$80
		TAY
		..gosmall
		JSL P2HitContactGFX
		LDA !P2Character-$80,y
		CMP #$03 : BNE .NotLeeway
		LDA #$08 : STA !P2ComboDash-$80,y
		.NotLeeway
		PLY
		LDA !P2Hitbox1DisTimer-$80,y : JSL DontInteract		; interaction disable
		LDA !P2Hitbox1Hitstun-$80,y : STA $9D			; hitstun
		.Return
		LDA !P2Hitbox1SFX1-$80,y : BEQ .SkipSFX1		;\
		STA !SPC1						; | SFX 1
		.SkipSFX1						;/
		LDA !P2Hitbox1SFX2-$80,y : BEQ .SkipSFX2		;\
		STA !SPC4						; | SFX 2
		.SkipSFX2						;/
		SEC
		RTL


		.ContactBits
		db $01,$02,$04,$08,$10,$20,$40,$80
		db $01,$02,$04,$08,$10,$20,$40,$80




; input: Y = player index
; output: void
	P2ContactGFX:
		PHX
		%Ex_Index_X()				; X = fusion index
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; > fusion type
		LDA !P2XPosLo-$80,y : STA !Ex_XLo,x	;\ Xpos
		LDA !P2XPosHi-$80,y : STA !Ex_XHi,x	;/
		LDA !P2YPosLo-$80,y			;\
		CLC : ADC #$08				; |
		STA !Ex_YLo,x				; | Ypos
		LDA !P2YPosHi-$80,y			; |
		ADC #$00				; |
		STA !Ex_YHi,x				;/
		LDA #$08 : STA !Ex_Data1,x		; > smoke timer
		PLX
		RTL



; input: clipping boxes loaded in both slots
; output: void
	P2HitContactGFX:
		PHX
		%Ex_Index_X()
		LDA #$02+!SmokeOffset : STA !Ex_Num,x

		LDA $02
		CLC : ADC $06
		ROR A
		STA $0C
		STZ $0D

		LDA $00 : STA $0E
		LDA $08 : STA $0F

		LDA $0A : XBA
		LDA $04
		REP #$20
		CLC : ADC $0C
		CLC : ADC $0E
		LSR A
		SEC : SBC #$0008
		SEP #$20
		STA !Ex_XLo,x
		XBA : STA !Ex_XHi,x

		LDA $03
		CLC : ADC $07
		ROR A
		STA $0C
		STZ $0D

		LDA $01 : STA $0E
		LDA $09 : STA $0F

		LDA $0B : XBA
		LDA $05
		REP #$20
		CLC : ADC $0C
		CLC : ADC $0E
		LSR A
		SEC : SBC #$0008
		SEP #$20
		STA !Ex_YLo,x
		XBA : STA !Ex_YHi,x

		LDA #$08 : STA !Ex_Data1,x
		PLX
		RTL


; input:
;	Y = player index
;	clipping boxes loaded in both slots
; output: void
	P2BigContactGFX:
		REP #$10
		PHX
		PHB
		PHY
		JSL !GetParticleIndex
		LDA #$0007 : STA !Particle_Timer,x
		LDA.w #!prt_contactbig : STA !Particle_Type,x
		PLY
		TYA
		BEQ $03 : LDA #$0220				; set lowest c bit as well as add 0x20 to tile num
		CLC : ADC.w #!P2Tile7-$20
		ORA #$F000
		STA !Particle_Tile,x
		SEP #$20
		LDA #$02 : STA !Particle_Layer,x
		PLB
		LDA $00 : STA $0C
		LDA $08 : STA $0D
		LDA $01 : STA $0E
		LDA $09 : STA $0F
		LDA $0A : XBA
		LDA $04
		REP #$20
		CLC : ADC $0C
		LSR A
		STA $0C
		SEP #$20
		LDA $0B : XBA
		LDA $05
		REP #$20
		CLC : ADC $0E
		LSR A
		STA $0E
		SEC : SBC #$000E
		STA !41_Particle_YLo,x
		LDA $0C : STA !41_Particle_XLo,x
		LDA !P2Direction-$80,y
		AND #$00FF
		BEQ $03 : LDA #$0040
		STA !41_Particle_XSpeed,x
		PLX
		SEP #$30
		RTL


; input: Y = player index
; output: void
	P2Bounce:
		PHX						; preserve X
		LDX !P2Character-$80,y : BNE .Shared		; X = player character
		.Mario						;\
		LDA !P2FireCharge-$80,y : BNE .Shared		; |
		INC A						; | mario fire flash code
		STA !P2FireCharge-$80,y				; |
		LDA #!MarioFlashPal : STA !P2FlashPal-$80,y	;/
		.Shared						;\ refund special
		LDA #$00 : STA !P2SpecialUsed-$80,y		;/
		CPY #$80 : BEQ ..p2				;\
	..p1	LDA $6DA2 : BRA ..read				; |
	..p2	LDA $6DA3					; | read input
	..read	BMI ..B						; |
		LDA.l .BounceSpeed,x : BRA ..comp		; |
	..B	LDA.l .BounceSpeedB,x				;/
	..comp	LDX !P2YSpeed-$80,y : BPL ..set			; > X = player Y speed, always bounce if player is moving down
		CMP !P2YSpeed-$80,y : BCS ..end			;\ otherwise only bounce if player would gain speed from it
	..set	STA !P2YSpeed-$80,y				;/
	..end	JSL P2ContactGFX				; include contact GFX
		LDA !P2Character-$80,y : BNE .Return		;\
		LDA !P2YSpeed-$80,y : STA !MarioYSpeed		; | final mario check: write to his Y speed reg
		.Return						;/
		PLX						; restore X
		RTL						; return

		.BounceSpeed
		db $D0,$E0,$C8,$C8,$00,$00	; Mario, Luigi, Kadaal, Leeway, Alter, Peach
		.BounceSpeedB
		db $A8,$C0,$A8,$A8,$00,$00	; Mario, Luigi, Kadaal, Leeway, Alter, Peach (when holding B)


; input: A = number of frames to not interact, Y = player index
; output: void
	DontInteract:
		CPY #$80 : BCS .P2
	.P1	STA !SpriteDisP1,x
		RTL
	.P2	STA !SpriteDisP2,x
		RTL


; input: sprite clipping loaded in $04 slot ($04-$07, $0A-$0B)
; output:
;	C = clear if no contact, C = set if contact
;	A = !BigRAM+$7E (instant BEQ will trigger if sprite was not hurt, instant BNE will trigger if it was)
;	!BigRAM+$7E = how many times sprite was hurt
;	!BigRAM+$7F = player contact bits (0 = no, 1 = p1, 2 = p2, 3 = both)
; note: if "can be jumped on" = 0, crush state will not crush the sprite
	P2Standard:
		STZ !BigRAM+$7E
		STZ !BigRAM+$7F
		SEC : JSL !PlayerClipping : BCC .NoContact
		STA !BigRAM+$7F
		LSR A : BCC .P2

		.P1
		PHA
		LDA !SpriteDisP1,x : BEQ ..int
		LDA #$01 : TRB !BigRAM+$7F
		BRA ..next
	..int	LDY #$00 : JSR .PlayerContact
	..next	PLA

		.P2
		LSR A : BCC .Return
		LDA !SpriteDisP2,x : BEQ ..int
		LDA #$02 : TRB !BigRAM+$7F
		BRA .Return
	..int	LDY #$80 : JSR .PlayerContact

		.Return
		CLC
		LDA !BigRAM+$7F : BEQ .NoContact
		SEC

		.NoContact
		LDA !BigRAM+$7E
		RTL


	.PlayerContact
		LDA !StarTimer : BEQ .NoStar
		JSL SPRITE_STAR
		INC !BigRAM+$7E
		RTS
		.NoStar

		LDA $0B : XBA
		LDA $05
		REP #$20
		SEC : SBC #$0004
		CMP !P2YPosLo-$80,y
		SEP #$20	
		BCC .HurtPlayer
		LDA #$08 : JSL DontInteract		; interaction disable when stomping sprite: 8 frames
		INC !BigRAM+$7E
		JSL P2Bounce

		.Bounce
		LDA !SpriteTweaker1,x
		AND #$10 : BEQ .NoCrush
		LDA !P2Crush-$80,y : BNE .Crush
		.NoCrush
		JSL StompSound
		RTS

		.Crush
		LDA #$04 : STA $3230,x
		LDA #$1B : STA $32D0,x
		JSL $07FC3B
		LDA #$08 : STA !SPC1
		RTS

		.HurtPlayer
		LDA #$0F : JSL DontInteract		; interaction disable when hurt by sprite: 15 frames
		TYA
		CLC : ROL #2
		INC A
		JSL !HurtPlayers
		RTS

; input:
;	sprite clipping loaded in $04 slot ($04-$07, $0A-$0B)
;	A = horizontal knockback for players
; output:
;	hurts players that touch the sprite, but only if interaction timers are clear
;	C = clear if no contact, C = set if contact
	P2Hurt:
		LDY $3320,x : BEQ .Right
		.Left
		EOR #$FF : INC A
		.Right
		STA !BigRAM+$7E
		SEC : JSL !PlayerClipping : BCC .NoContact
		STA !BigRAM+$7F
		LSR A : BCC .P2

		.P1
		PHA
		LDA !P2Invinc-$80
		ORA !StarTimer
		BNE ..nope
		LDA !SpriteDisP1,x : BEQ ..int
		..nope
		LDA #$01 : TRB !BigRAM+$7F
		BRA ..next
		..int
		LDY #$00
		LDA #$0F : JSL DontInteract
		LDA !BigRAM+$7E : STA !P2VectorX-$80
		LDA #$0F : STA !P2VectorTimeX-$80
		..next
		PLA

		.P2
		LSR A : BCC .Return
		LDA !P2Invinc
		ORA !StarTimer
		BNE ..nope
		LDA !SpriteDisP2,x : BEQ ..int
		..nope
		LDA #$02 : TRB !BigRAM+$7F
		BRA .Return
		..int
		LDY #$80
		LDA #$0F : JSL DontInteract
		LDA !BigRAM+$7E : STA !P2VectorX
		LDA #$0F : STA !P2VectorTimeX

		.Return
		LDA !BigRAM+$7F : BEQ .NoContact
		JSL !HurtPlayers

		.NoContact
		RTL



;==========================;
; SPRITE INTERACTION CODES ;
;==========================;
; for these, X = sprite A index and Y = sprite B index

	SPRITE_A_SPRITE_B:

; input: void
; output: void
		.COORDS
		LDA $3220,x : STA $3220,y	;\
		LDA $3250,x : STA $3250,y	; | copy coordinates
		LDA $3210,x : STA $3210,y	; |
		LDA $3240,x : STA $3240,y	;/
		RTL

; input:
;	$00 = 16-bit X offset
;	$02 = 16-bit Y offset
; output: void
		.ADD
		LDA $3220,x			;\
		CLC : ADC $00			; |
		STA $3220,y			; |
		LDA $3250,x			; |
		ADC $01				; |
		STA $3250,y			; | copy coordinates and add $00-$03
		LDA $3210,x			; |
		CLC : ADC $02			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		ADC $03				; |
		STA $3240,y			;/
		RTL


; displays contact GFX on the point between two sprites (X and Y)
; input: void
; output: void
	SpriteContactGFX:
		LDA $3220,x
		CLC : ADC $3220,y
		STA $00
		LDA $3250,x
		ADC $3250,y
		STA $01
		LDA $3210,x
		CLC : ADC $3210,y
		STA $02
		LDA $3240,x
		ADC $3240,y
		STA $03
		REP #$20
		LSR $00
		LSR $02
		SEP #$20

		%Ex_Index_X()
		LDA #$02+!SmokeOffset : STA !Ex_Num,x	; smoke type
		LDA $00 : STA !Ex_XLo,x			; smoke X
		LDA $02 : STA !Ex_YLo,x			; smoke Y
		LDA #$08 : STA !Ex_Data1,x		; smoke timer
		LDX !SpriteIndex
		RTL



;=================;
; TILEMAP LOADERS ;
;=================;
;
; these routines can be used by sprites to load an OAM tilemap
;
; global tilemap format:
;	2-byte header: number of bytes to load (equal to 4 times the number of tiles to load)
;	for each tile
;		prop
;		X (inverted based on xflip)
;		Y
;		tile num
;
;	for LOAD_TILEMAP, prop has the following format:
;		YXSPCCCT
;		everything is exactly what you'd expect, except S which is the size bit, and P which is shifted left (prio = 0 or 2, but never 1 or 3)
;	tile num is written as is
;
;	for LOAD_TILEMAP_COLOR, prop is this:
;		YXPP--ST
;		CCC bits come from sprite's $33C0,x
;
;	for LOAD_PSUEDO_DYNAMIC (yes i spelled that wrong when i was a teenager, get over it), prop has the following format:
;		YXPP--Sc
;		C bits are unused since those are instead read from $33C0,x
;		T bit is unused since it is read from !SpriteProp,x
;		S is size bit
;		c if set, --S bits are used as CCC and lower P bit is used as S, $33C0,x is ignored
;	tile num is added to !SpriteTile,x and stored to OAM
;
;	for LOAD_DYNAMIC, prop has the same format as for LOAD_PSUEDO_DYNAMIC, but the T bit comes from the highest bit of !GFX_Dynamic
;	tile num is used as an index to $F0 to find the appropriate dynamic tile, rather than being written directly to OAM
;
;

; recode all to use this memory format:
;
; $00		sprite screen-relative Xpos
; $02		sprite screen-relative Ypos
; $04		tilemap pointer
; $06		temp: prop or tile screen-relative Xpos
; $08		tilemap byte count
; $0A		tile size bit
; $0C		-X--CCCT (applied as EOR, unused by static loader)
; $0E		x-flip EOR mask (0x0000 or 0xFFFF)
;
; !BigRAM+$7C	(PSUEDO_DYNAMIC only) tile offset
; !BigRAM+$7D	----
; !BigRAM+$7E	16-bit upper boundary of OAM mirror index



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_TILEMAP:
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p2	LDA #$04 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		STZ $0E
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
		DEC $0E
	+	LDY #$0000
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTL

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				;\
		AND #$20				; |
		STA $0A					; | YXP-CCCT
		LDA ($04),y				; | (lower P bit is size bit)
		AND.b #$10^$FF				; |
		ORA $0A					; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/

		LDA ($04),y				;\
		AND #$10				; | tile size bit
		BEQ $02 : LDA #$02			; |
		STA $0A					;/
		STZ $0B					;\ n flag trigger
		BEQ $02 : DEC $0B			;/

		REP #$20
		INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

		.GoodX
		STA $06					; temp tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA ($04),y : STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
	.End	RTS



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_TILEMAP_COLOR:
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p2	LDA #$04 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		STZ $0C
		STZ $0E
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : STA $0C
		DEC $0E
	+	LDA $33C0,x
		AND #$000E : TSB $0C
		LDY #$0000
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTL

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				;\
		AND #$02 : STA $0A			; |
		STZ $0B					;\ n flag trigger (for size bit)
		BEQ $02 : DEC $0B			;/
		LDA ($04),y				; | YXPP--ST
		AND.b #$0E^$FF				; |
		EOR $0C					; |
		STA !OAM_p0+$003,x			;/


		REP #$20
		INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .Loop
		RTS

		.GoodX
		STA $06					; temp tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x
		INY
		LDA ($04),y : STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
	.End	RTS



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_PSUEDO_DYNAMIC:
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p2	LDA #$04 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		LDA !SpriteProp,x			;\
		ORA $33C0,x				; | prop base
		AND #$00FF				; |
		STA $0C					;/
		STZ $0E
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : TSB $0C
		DEC $0E
	+	LDY #$0000
		LDA !SpriteTile,x			;\
		AND #$00FF				; | dynamic tile
		STA !BigRAM+$7C				;/
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTL

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				; read prop byte
		BIT #$01 : BEQ ..dynamicprop		; check which format this is

		..staticprop				;\
		AND #$FE				; > only clear c bit
		STA $07					; |
		EOR $0C					; | get static prop
		AND #$E1				; > get XY, flip X, get T bit
		STA $06					; |
		LDA $07					; |
		AND #$0E				; > get CCC bits
		ORA $64					; > add global PP bits
		ORA $06					; |
		STA !OAM_p0+$003,x			;/
		LDA $07					;\
		AND #$10				; | get size bit
		BEQ $02 : LDA #$02			; |
		BRA ..propdone				;/

		..dynamicprop				;\
		AND #$F0				; |
		EOR $0C					; | get dynamic prop
		ORA $64					; |
		STA !OAM_p0+$003,x			;/
		LDA ($04),y				;\ S bit
		AND #$02				;/

		..propdone
		STA $0A					; write S bit
		BEQ $02 : LDA #$80			;\ n flag trigger
		STA $0B					;/

		REP #$20
		INY

		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $0A : BMI +
		BIT $0E : BPL +
		CLC : ADC #$0008			; add 8 to x-flipped 8x8 tile
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .L
		RTS

		.GoodX
		STA $06					; $06 = 16-bit tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCS .GoodY
		BRA .BadCoord

		.GoodY
		SEP #$20
		STA !OAM_p0+$001,x
		LDA $06 : STA !OAM_p0+$000,x		; lo byte of tile xpos
		INY
		LDA ($04),y
		CLC : ADC !BigRAM+$7C
		STA !OAM_p0+$002,x
		INY
		PHX
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07					; hi byte of tile xpos
		AND #$01
		ORA $0A					; tile size bit
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
	.End	RTS



; input:
;	X = sprite index
;	$04 = pointer to tilemap
; output: void
	LOAD_DYNAMIC:
	.p1	LDA #$02 : BRA .Shared			; default to prio 1 if not specified
	.p2	LDA #$04 : BRA .Shared
	.p0	LDA #$00 : BRA .Shared
	.p3	LDA #$06

		.Shared
		STA !ActiveOAM
		STZ !ActiveOAM+1
		PHP
		SEP #$30
		LDA $3220,x : STA $00
		LDA $3250,x : STA $01
		LDA $3240,x : XBA
		LDA $3210,x
		REP #$30
		SEC : SBC $1C
		STA $02
		LDA $00
		SEC : SBC $1A
		STA $00
		LDA ($04) : STA $08
		INC $04
		INC $04
		LDA $33C0,x
		AND #$000E
		STA $0C
		STZ $0E
		LDA $3320,x
		LSR A : BCS +
		LDA #$0040 : TSB $0C
		DEC $0E
	+	;LDA !GFX_Dynamic-1
		;BPL $02 : INC $0C
		LDY #$0000
		LDX !ActiveOAM
		LDA !OAMindex_offset,x
		CLC : ADC #$0200
		STA !BigRAM+$7E				; index break point
		LDA !OAMindex_offset,x
		CLC : ADC !OAMindex_p0,x
		TAX
		SEP #$20
		JSR .Loop
		REP #$20
		STX $0E					; return $0E = effective index
		TXA
		LDX !ActiveOAM
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x
		PLP
		LDX !SpriteIndex
		RTL

		.Loop
		CPX !BigRAM+$7E : BCC .WithinBounds
		RTS

		.WithinBounds
		LDA ($04),y				; read prop byte
		BIT #$01 : BEQ ..dynamicprop		; check which format this is

		..staticprop				;\
		AND #$FE				; > only clear c bit
		STA $07					; |
		EOR $0C					; | get static prop
		AND #$E1				; > get XY, flip X, get T bit
		STA $06					; |
		LDA $07					; |
		AND #$0E				; > get CCC bits
		ORA $64					; > add global PP bits
		ORA $06					; |
		STA !OAM_p0+$003,x			;/
		LDA $07					;\
		AND #$10				; | get size bit
		BEQ $02 : LDA #$02			; |
		BRA ..propdone				;/

		..dynamicprop				;\
		AND #$F0				; |
		EOR $0C					; | get dynamic prop
		ORA $64					; |
		STA !OAM_p0+$003,x			;/
		LDA ($04),y				;\ S bit
		AND #$02				;/

		..propdone
		STA $0A					; write S bit
		BEQ $02 : LDA #$80			;\ n flag trigger
		STA $0B					;/

		REP #$20
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		EOR $0E
		CLC : ADC $00
		BIT $0E : BPL +				;\
		BIT $0A : BMI +				; | x-flipped 8x8 tiles move 8px right
		CLC : ADC #$0008			;/
	+	CMP #$0100 : BCC .GoodX
		CMP #$FFF0 : BCS .GoodX
		INY

		.BadCoord
		INY #2
		SEP #$20
		CPY $08 : BCC .L
		RTS

		.GoodX
		STA $06					; tile xpos
		INY
		LDA ($04),y
		AND #$00FF
		CMP #$0080
		BMI $03 : ORA #$FF00
		CLC : ADC $02
		CMP #$00E8 : BCC .GoodY
		CMP #$FFF0 : BCC .BadCoord

		.GoodY
		STA !OAM_p0+$001,x
		LDA #$0000				; clear B
		SEP #$20
		LDA $06 : STA !OAM_p0+$000,x
		INY
		PHX
		LDA ($04),y : TAX
		LDA !DynamicProp,x : STA $06		; -------T flip for dynamic tile
		LDA $F0,x
		PLX
		STA !OAM_p0+$002,x			; tile num
		LDA !OAM_p0+$003,x
		EOR $06
		STA !OAM_p0+$003,x
		PHX
		INY
		REP #$20
		TXA
		LSR #2
		TAX
		SEP #$20
		LDA $07
		AND #$01
		ORA $0A
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		CPY $08 : BCS .End
	.L	JMP .Loop
	.End	RTS







;=====================;
; SQUARE DYNAMO CODES ;
;=====================;
;
; draw dynamic procedure:
;	- LOAD_SQUARE_DYNAMO to load the square dynamo (this step can be skipped if there is no dynamo update this frame)
;	- SETUP_SQUARE to get the table for which dynamic tile to use for each sprite tile (this is not included in LOAD_DYNAMIC since that would be a waste for sprites that combine tilemaps)
;	- LOAD_DYNAMIC to draw to OAM
;




; this routine generates a tile table in $F0-$FF (lo byte) and !DynamicProp (hi byte)
; this table is indexed by the sprite's tile numbers, and the read byte is used as a replacement
; NOTE:
;	dynamic sprites have to use tile numbers in the $00-$0F range
;	this number is which of its claimed tiles to use, not the actual OAM tile
;	$00 is the first claimed tile, $01 is the second claimed tile, and so on
;	most sprites don't use more than a few dynamic tiles, but theoretically one could use up to $0F for a full 128x64 size
; this routine should never mess with $04 since that is used so often in OAM routines


; input: X = sprite number
; output: $F0 = dynamic tile use table
	SETUP_SQUARE:
		PHX
		PHP
		SEP #$30
		TXA
		ASL A
		TAX
		REP #$20
		LDA !DynamicList,x : STA $00
		SEP #$20
		LDA #$00						; starting dynamic tile number
		LDX #$00						; starting tile number

		.Block1							;\
	..loop	STA $F0,x						; |
		LSR $00							; | dynamic tile nums for first 8 possible tiles
		BCC $01 : INX						; |
		INC #2							; |
		CMP #$10 : BCC ..loop					;/

		.Block2							;\
		LDY $01 : STY $00					; |
	..loop	STA $F0,x						; |
		LSR $00							; | dynamic tile nums for remaining 8 possible tiles
		BCC $01 : INX						; |
		INC #2							; |
		CMP #$20 : BCC ..loop					;/

		.Complete
		LDX #$0F						;\
	..loop	LDY $F0,x						; |
		LDA !DynamicMatrix+0,y : STA $F0,x			; | get full tile numbers from matrix
		LDA !DynamicMatrix+1,y : STA !DynamicProp,x		; |
		DEX : BPL ..loop					;/
		PLP
		PLX
		RTL





; RAM use:
; $00	current bit being checked
; $02	accumulating tiles this sprite will claim
; $0E	how many tiles are left to check
;
; input:
;	A = number of tiles to claim
;	X = sprite number
; output:
;	$00 = bits representing which tiles this sprite claimed
;	C clear if there weren't enough free tiles (sprite should not spawn), C set if tiles were claimed without problems
	GET_SQUARE:
		PHX							; push sprite index
		REP #$20						; A 16-bit
		AND #$000F						;\ number of tiles to check
		STA $0E							;/
		LDA #$0001 : STA $02					; starting bit
		STZ $00							; starting accumulation
		LDX #$0F						; starting loop counter (number of bits to check)

	.Loop	LDA !DynamicTile					;\
		AND $02 : BEQ .TakeOne					; | see if this tile is free
		ASL $02							; |
	.Loop2	DEX : BPL .Loop						;/
		.Fail							;\
		SEP #$20						; |
		PLX							; | if there aren't enough free tiles, fail and return
		CLC							; |
		RTL							;/

		.TakeOne						;\
		LDA $02 : TSB $00					; | if tile is free, prelim mark it as used and loop
		ASL $02							; |
		DEC $0E : BPL .Loop2					;/

		.Success						;\
		LDA $00 : TSB !DynamicTile				; |
		LDA $01,s						; |
		AND #$00FF						; |
		ASL A							; |
		TAX							; | if there were enough free tiles, mark the claimed ones as used and return
		LDA $00 : STA !DynamicList,x				; |
		SEP #$20						; |
		PLX							; |
		SEC							; |
		RTL							;/


; RAM use:
; $00	remaining tiles to use
; $02	size of square dynamo
; $0C	pointer to square dynamo
;
; input:
;	X = sprite index
;	Y = ID of file to load from (call _Main to ignore input Y, use with first input setting file or hardcoding address)
;	$0C = pointer to square dynamo
; output: void
	LOAD_SQUARE_DYNAMO:
		JSL !GetFileAddress					; get file address

		.Main							;\
		PHX							; |
		PHP							; |
		REP #$30						; | push stuff and get index to !DynamicList
		TXA							; |
		ASL A							; |
		TAX							;/
		LDA !DynamicList,x : STA $00				; $00 = which dynamic tiles are in use
		LDX #$0000						; X = square table index
		LDY #$0000						; Y = pointer index
		LDA ($0C) : BEQ .Return					; if size = 0, return
		STA $02							;\
		INC $0C							; | otherwise store size to $02 and set up pointer
		INC $0C							;/


		.Loop							;\ return if at end of dynamo
		CPY $02 : BCS .Return					;/
		LDA ($0C),y : BPL .LoadTile				;\ check type
		CMP #$C000 : BCC .GetFile				;/

		.SkipTiles						;\
		INY #2							; |
		AND #$000F : BEQ .Loop					; |
		PHA							; |
		PEI ($04)						; | add skip count * 4 to X
		STX $04							; |
		ASL #2							; |
		ADC $04							; |
		TAX							; |
		PLA : STA $04						;/
		PLA							;\
	-	LSR $00							; | shift $00 once per skip count
		DEC A : BEQ .Loop					; |
		BRA -							;/

		.GetFile						;\
		PHY							; |
		AND #$7FFF : TAY					; |
		JSL !GetFileAddress					; | get file address
		PLY							; |
		INY #2							; |
		BRA .Loop						;/

		.LoadTile						;\ see if tile is in use
	..loop	LSR $00 : BCC ..nextone					;/
		..thisone						;\ source bank
		LDA !FileAddress+1 : STA !VRAMbase+!SquareTable+1,x	;/
		LDA ($0C),y						;\
		CLC : ADC !FileAddress+0				; | source address
		STA !VRAMbase+!SquareTable+0,x				;/
		INC !DynamicCount					; 1 more tile in use
		INY #2							; increment index
		INX #4							;\ increment output index and return if at end
		CPX #$0040 : BCS .Return				;/
		BRA .Loop						; loop
		..nextone						;\
		INX #4							; | otherwise loop until all tiles have been checked
		CPX #$0040 : BCC ..loop					;/

		.Return							;\
		PLP							; | pull stuff
		PLX							;/
		RTL							; return





