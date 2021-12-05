

;
; _Misc
;	------21
;	2 - player 2 on top
;	1 - player 1 on top
;


	Pole:
		LDX $00
		PHX
		PHP

		LDA !BG_object_Y,x
		BIT #$0008 : BNE .Main
		.Init
		ORA #$0008
		SEC : SBC #$0010
		STA !BG_object_Y,x
		SEP #$20
		LDA #$60 : STA !BG_object_Tile,x
		REP #$20


		.Main
		LDA !BG_object_X,x				;\
		STA $04						; |
		STA $09						; |
		LDA !BG_object_Y,x				; |
		CLC : ADC #$0008				; |
		SEP #$20					; | clipping
		STA $05						; |
		XBA : STA $0B					; |
		LDA !BG_object_W,x				; |
		ASL #3						; |
		STA $06						; |
		LDA #$01 : STA $07				;/
		SEP #$30


; $00	interaction bits (this frame, gets shredded)
; $02	24-bit pointer to height map
; $05	scratch for speed calc
; $06	----
; $08	----
; $0A	x speed when bouncing
; $0C	interaction bits (previous frame)
; $0E	interaction bits (this frame, unshredded mirror)


		PHB : PHK : PLB

		LDX #$0F
	-	LDA $3230,x
		CMP #$08 : BCC +
		CMP #$0C : BCS +
		LDA !SpriteYSpeed,x
		CLC : ADC !SpriteVectorY,x
		BMI +
		JSL !GetSpriteClipping00
		LDA $03
		CLC : ADC #$05
		STA $03
		JSL !CheckContact : BCC +
		LDA #$10 : STA !SpriteYSpeed,x
		LDA #$04 : STA !SpriteExtraCollision,x
		LDA $05
		SEC : SBC #$0F
		STA !SpriteYLo,x
		LDA $0B
		SBC #$00
		STA !SpriteYHi,x
	+	DEX : BPL -


		SEC : JSL !PlayerClipping
		PLB
		PLP
		PLX
		STA $00
		STA $0E

		LDA !BG_object_Timer,x
		AND #$00FC
		ASL #2
		ADC.w #.HeightMap : STA $02
		LDA.w #.HeightMap>>16 : STA $04
		LDA !BG_object_Misc,x : STA $0C

		LDA !BG_object_Type,x
		AND #$00FF
		CMP #$0005 : BNE ..faceright

		..faceleft
		LDA #$FFE8 : STA $0A
		BRA +

		..faceright
		LDA #$0018 : STA $0A	
		+

; states:
;	00 - straight form
;		requires no interaction on outer half
;		no special jump interaction
;
;	01 - slightly bent down
;		requires interaction on outer half
;		reduced jump height
;
;	02 - strongly bent down
;		set by landing on outer half from a high-enough fall
;		increases jump height
;

		.InteractP1
		LDA.l !P2XPosLo-$80 : JSR .GetMapIndex		; get height map index (also use for bounce, so it has to be before the BCC ..done)
		LSR $00 : BCC ..done				;\
		LDA.l !P2DropDownTimer-$80-1 : BMI ..fail	; |
		LDA.l !P2YPosLo-$80				; |
		SEC : SBC #$0008				; | has to touch while moving down (no interaction during drop down)
		CMP !BG_object_Y,x : BPL ..fail			; |
		LDA.l !P2YSpeed-$80-1				; |
		CLC : ADC.l !P2VectorY-$80-1			; |
		BPL ..ontop					;/
		..fail						;\
		LDA #$0001 : TRB $0E				; | otherwise, clear interaction bit
		BRA ..done					;/
		..ontop						;\
		SEP #$20					; | set platform bit
		LDA #$04 : STA.l !P2ExtraBlock-$80		; |
		REP #$20					;/
		CPY #$0004*2 : BCS ..setcoords			; inner half -> no pressure
		LDA !BG_object_Misc,x				;\
		AND #$0001 : BNE ..nolanding			; |
		LDA.l !ApexP1					; |
		JSR .SetLanding					; | outer half -> set animation
		BRA ..setcoords					; |
		..nolanding					; |
		LDA #$0007 : JSR .SetAnim			;/
		..setcoords					;\
		LDA !BG_object_Y,x				; |
		AND #$FFF0					; |
		CLC : ADC [$02],y				; |
		STA.l !P2YPosLo-$80				; |
		LDA.l !P2Character-$80				; | update player Y coord
		AND #$00FF : BNE ..done				; |
		LDA.l !P2YPosLo-$80				; |
		SEC : SBC #$0010				; |
		STA $96						; |
		..done						;/

		LDA $0E : TSB $0C

		.BounceP1
		LSR $0C : BCC ..done				;\
		CPY #$0004*2 : BCS ..done			; | must be moving down onto the outer half
		LDA.l !P2YSpeed-$80-1 : BPL ..done		;/
		SEP #$20					;\
		LDA !BG_object_Timer,x				; | unless timer is in 8-F range, reduce speed
		CMP #$08 : BCC ..reduce				; |
		CMP #$10 : BCS ..reduce				;/
		..boost						;\
		PHP						; |
		LDA.l !P2Character-$80
		CMP #$02 : BEQ +
		CMP #$03 : BNE ++
	+	LDA #$01 : STA.l !P2Dashing-$80
		++
		LDA #$08 : STA.l !SPC4				; |
		LDA #$17 : JSR .SetAnim				; | anim + sfx
		PLP						; |
		LDA.l !P2XSpeed-$80				; |
		CLC : ADC $0A					; | +0x18 X speed
		STA.l !P2XSpeed-$80				; |
		XBA						; |
		EOR #$FF					; |
		CMP #$54					; | cap speed to prevent overflow (underflow?)
		BCC $02 : LDA #$54				; |
		STA $05						; | +50% speed if at the very tip
		LSR A						; | otherwise +25% speed
		CPY #$0000					; |
		BEQ $01 : LSR A					; |
		ADC $05						; |
		BRA ..setspeed					;/
		..reduce					;\
		XBA						; |
		EOR #$FF					; |
		STA $05						; | -25% speed
		LSR #2						; |
		SBC $05						; |
		EOR #$FF					;/
		..setspeed					;\
		EOR #$FF					; |
		STA.l !P2YSpeed-$80				; |
		LDA.l !P2Character-$80 : BNE ..notmario		; | set speeds
		LDA.l !P2YSpeed-$80 : STA !MarioYSpeed		; |
		LDA.l !P2XSpeed-$80 : STA !MarioXSpeed		; |
		..notmario					; |
		REP #$20					; |
		..done						;/

		.InteractP2
		LDA.l !P2XPosLo : JSR .GetMapIndex		; get height map index (also use for bounce, so it has to be before the BCC ..done)
		LSR $00 : BCC ..done				;\
		LDA.l !P2DropDownTimer-1 : BMI ..fail		; |
		LDA.l !P2YPosLo					; |
		SEC : SBC #$0008				; | has to touch while moving down (no interaction during drop down)
		CMP !BG_object_Y,x : BPL ..fail			; |
		LDA.l !P2YSpeed-1				; |
		CLC : ADC.l !P2VectorY-1			; |
		BPL ..ontop					;/
		..fail						;\
		LDA #$0002 : TRB $0E				; | otherwise, clear interaction bit
		BRA ..done					;/
		..ontop						;\
		SEP #$20					; | set platform bit
		LDA #$04 : STA.l !P2ExtraBlock			; |
		REP #$20					;/
		CPY #$0004*2 : BCS ..setcoords			; inner half -> no pressure
		LDA !BG_object_Misc,x				;\
		AND #$0002 : BNE ..nolanding			; |
		LDA.l !ApexP2					; |
		JSR .SetLanding					; | outer half -> set animation
		BRA ..setcoords					; |
		..nolanding					; |
		LDA #$0007 : JSR .SetAnim			;/
		..setcoords					;\
		LDA !BG_object_Y,x				; |
		AND #$FFF0					; |
		CLC : ADC [$02],y				; |
		STA.l !P2YPosLo					; |
		LDA.l !P2Character				; | update player Y coord
		AND #$00FF : BNE ..done				; |
		LDA.l !P2YPosLo					; |
		SEC : SBC #$0010				; |
		STA $96						; |
		..done						;/

		LDA $0E
		LSR A
		TSB $0C

		.BounceP2
		LSR $0C : BCC ..done				;\
		CPY #$0004*2 : BCS ..done			; | must be moving down onto the outer half
		LDA.l !P2YSpeed-1 : BPL ..done			;/
		SEP #$20					;\
		LDA !BG_object_Timer,x				; | unless timer is in 8-F range, reduce speed
		CMP #$08 : BCC ..reduce				; |
		CMP #$10 : BCS ..reduce				;/
		..boost						;\
		PHP						; |
		LDA.l !P2Character
		CMP #$02 : BEQ +
		CMP #$03 : BNE ++
	+	LDA #$01 : STA.l !P2Dashing
		++
		LDA #$08 : STA.l !SPC4				; |
		LDA #$17 : JSR .SetAnim				; | anim + sfx
		PLP						; |
		LDA.l !P2XSpeed					; |
		CLC : ADC $0A					; | +0x18 X speed
		STA.l !P2XSpeed					; |
		XBA						; |
		EOR #$FF					; |
		CMP #$54					; | cap speed to prevent overflow (underflow?)
		BCC $02 : LDA #$54				; |
		STA $05						; | +50% speed if at the very tip
		LSR A						; | otherwise +25% speed
		CPY #$0000					; |
		BEQ $01 : LSR A					; |
		ADC $05						; |
		BRA ..setspeed					;/
		..reduce					;\
		XBA						; |
		EOR #$FF					; |
		STA $05						; | -25% speed
		LSR #2						; |
		SBC $05						; |
		EOR #$FF					;/
		..setspeed					;\
		EOR #$FF					; |
		STA.l !P2YSpeed					; |
		LDA.l !P2Character : BNE ..notmario		; | set speeds
		LDA.l !P2YSpeed : STA !MarioYSpeed		; |
		LDA.l !P2XSpeed : STA !MarioXSpeed		; |
		..notmario					; |
		REP #$20					; |
		..done						;/




		SEP #$20
		LDA $0E : STA !BG_object_Misc,x
		REP #$20


		LDA !VRAMbase+!TileUpdateTable			;\
		CMP #$00D0 : BCC .Valid				; | check if animation can be done
		RTS						;/

		.Valid						;\
		PHX						; |

		LDA !BG_object_Type,x
		AND #$00FF
		CMP #$0006 : BEQ ..faceright

		..faceleft
		LDA !BG_object_Timer,x				; |
		AND #$00FF : BEQ +				; |
		DEC !BG_object_Timer,x				; | animate
	+	LSR #2						; |
		ASL A						; |
		TAX						; |
		LDA.l .TilePointer,x : STA $00			; |
		PLX						; |
		JMP TileUpdate					;/

		..faceright
		LDA !BG_object_Timer,x				; |
		AND #$00FF : BEQ +				; |
		DEC !BG_object_Timer,x				; | animate
	+	LSR #2						; |
		ASL A						; |
		TAX						; |
		LDA.l .TilePointerX,x : STA $00			; |
		PLX						; |
		JMP TileUpdate					;/


		.TilePointer
		dw .Pole0
		dw .Pole1
		dw .Pole2
		dw .Pole3
		dw .Pole4
		dw .Pole5

		.Pole0
		dw $1410,$1410,$1410,$1410
		dw $1400,$1401,$1402,$1403
		dw $1410,$1411,$1412,$1413
		.Pole1
		dw $1410,$1410,$1410,$1410
		dw $1404,$1405,$1406,$1407
		dw $1414,$1415,$1416,$1417
		.Pole2
		.Pole3
		dw $1410,$1410,$1410,$1410
		dw $1408,$1409,$140A,$140B
		dw $1418,$1419,$141A,$141B
		.Pole4
		.Pole5
		dw $9418,$9419,$941A,$941B
		dw $9408,$9409,$940A,$940B
		dw $1410,$1410,$1410,$1410


		.TilePointerX
		dw .Pole0X
		dw .Pole1X
		dw .Pole2X
		dw .Pole3X
		dw .Pole4X
		dw .Pole5X

		.Pole0X
		dw $1410,$1410,$1410,$1410
		dw $5403,$5402,$5401,$5400
		dw $5413,$5412,$5411,$5410
		.Pole1X
		dw $1410,$1410,$1410,$1410
		dw $5407,$5406,$5405,$5404
		dw $5417,$5416,$5415,$5414
		.Pole2X
		.Pole3X
		dw $1410,$1410,$1410,$1410
		dw $540B,$540A,$5409,$5408
		dw $541B,$541A,$5419,$5418
		.Pole4X
		.Pole5X
		dw $D41B,$D41A,$D419,$D418
		dw $D40B,$D40A,$D409,$D408
		dw $1410,$1410,$1410,$1410



; each entry is for a quad pixel

	.HeightMap
	..0	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	..1	dw $0004,$0004,$0003,$0003,$0002,$0002,$0001,$0001
	..2	dw $0008,$0005,$0003,$0002,$0002,$0002,$0001,$0001
	..3	dw $0008,$0005,$0003,$0002,$0002,$0002,$0001,$0001
	..4	dw $FFF7,$FFF7,$FFF7,$FFFC,$FFFF,$0000,$0001,$0001
	..5	dw $FFF7,$FFF7,$FFF7,$FFFC,$FFFF,$0000,$0001,$0001



		.SetLanding
		BMI ..return
		SEC : SBC !BG_object_Y,x : BPL ..return
		CMP.w #-$0030 : BCS ..return
		..set2
		LDA #$000F : JSR .SetAnim
		AND #$00FC
		ASL #2
		ADC.w #.HeightMap
		STA $02
		..return
		RTS

		.GetMapIndex
		CLC : ADC #$0008
		SEC : SBC !BG_object_X,x
		BPL $03 : LDA #$0000
		CMP #$001F
		BCC $03 : LDA #$001F
		LSR #2
		PHA
		LDA !BG_object_Type,x
		AND #$00FF
		CMP #$0006 : BEQ ..faceright
		..faceleft
		PLA
		ASL A
		TAY
		RTS
		..faceright
		PLA
		EOR #$0007
		ASL A
		TAY
		RTS

		.SetAnim
		SEP #$20
		CMP !BG_object_Timer,x : BCC ..return
		STA !BG_object_Timer,x
		..return
		REP #$20
		RTS










