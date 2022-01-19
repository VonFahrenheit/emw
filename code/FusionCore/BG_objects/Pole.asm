

;
; _Misc
;	------21
;	2 - player 2 on top
;	1 - player 1 on top
;

; bounce model:
;	Yspeed * (16 * Ydisp + 256) / 256
; delta excluded because it's irrelevant with this discrete step model



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
		STZ !SpriteYSpeed,x
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

		LDA !BG_object_Misc,x : STA $0C


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

		PHB : PHK : PLB

		.InteractP1
		LSR $00 : BCC ..done				;\
		LDA !P2XPosLo-$80 : JSR .GetMapIndex		; get height map index
		LDA !P2DropDownTimer-$80-1 : BMI ..fail		; |
		LDA !P2YPosLo-$80				; |
		SEC : SBC #$0008				; | has to touch while moving down (no interaction during drop down)
		CMP $410000+!BG_object_Y,x : BPL ..fail		; |
		LDA !P2YSpeed-$80-1				; |
		CLC : ADC !P2VectorY-$80-1			; |
		BPL ..ontop					;/
		..fail						;\
		LDA #$0001 : TRB $0E				; | otherwise, clear interaction bit
		BRA ..done					;/
		..ontop						;\
		SEP #$20					; | set platform bit
		LDA #$04 : TSB !P2ExtraBlock-$80		; |
		REP #$20					;/
		CPY #$0004*2 : BCS ..setcoords			; inner half -> no pressure
		LDA $410000+!BG_object_Misc,x			;\
		AND #$0001 : BNE ..nolanding			; |
		LDA !ApexP1 : JSR .SetLanding			; | outer half -> set animation
		BRA ..setcoords					; |
		..nolanding					; |
		LDA #$0007 : JSR .SetAnim			;/
		..setcoords					;\
		LDA $410000+!BG_object_Y,x			; |
		AND #$FFF0					; |
		CLC : ADC ($02),y				; |
		STA !P2YPosLo-$80				; |
		LDA !P2Character-$80				; | update player Y coord
		AND #$00FF : BNE ..done				; |
		LDA !P2YPosLo-$80				; |
		SEC : SBC #$0010				; |
		STA $96						; |
		..done						;/

		.InteractP2
		LSR $00 : BCC ..done				;\
		LDA !P2XPosLo : JSR .GetMapIndex		; get height map index
		LDA !P2DropDownTimer-1 : BMI ..fail		; |
		LDA !P2YPosLo					; |
		SEC : SBC #$0008				; | has to touch while moving down (no interaction during drop down)
		CMP $410000+!BG_object_Y,x : BPL ..fail		; |
		LDA !P2YSpeed-1					; |
		CLC : ADC !P2VectorY-1				; |
		BPL ..ontop					;/
		..fail						;\
		LDA #$0002 : TRB $0E				; | otherwise, clear interaction bit
		BRA ..done					;/
		..ontop						;\
		SEP #$20					; | set platform bit
		LDA #$04 : TSB !P2ExtraBlock			; |
		REP #$20					;/
		CPY #$0004*2 : BCS ..setcoords			; inner half -> no pressure
		LDA $410000+!BG_object_Misc,x			;\
		AND #$0002 : BNE ..nolanding			; |
		LDA !ApexP2 : JSR .SetLanding			; | outer half -> set animation
		BRA ..setcoords					; |
		..nolanding					; |
		LDA #$0007 : JSR .SetAnim			;/
		..setcoords					;\
		LDA $410000+!BG_object_Y,x			; |
		AND #$FFF0					; |
		CLC : ADC ($02),y				; |
		STA !P2YPosLo					; |
		LDA !P2Character				; | update player Y coord
		AND #$00FF : BNE ..done				; |
		LDA !P2YPosLo					; |
		SEC : SBC #$0010				; |
		STA $96						; |
		..done						;/


		LDA $0E : TSB $0C				; update collision flags

		LDA $410000+!BG_object_Type,x			;\
		AND #$00FF					; |
		CMP #$0005 : BNE ..faceright			; |
		..faceleft					; | update x speed bonus
		LDA #$FFF4 : BRA +				; |
		..faceright					; |
		LDA #$000C					; |
	+	STA $0A						;/

		.BounceP1
		LDA $0C						;\
		AND #$0001 : BEQ ..done				; | must be moving off of pole
		LDA !P2YSpeed-$80-1 : BPL ..done		;/
		LDA !P2XPosLo-$80 : JSR .GetMapIndex		; get height map index
		STZ $2250					;\
		LDA ($02),y					; |
		BPL $03 : LDA #$0000				; > negative -> 0
		AND #$00FF					; |
		ASL #4						; |
		ADC #$0100					; |
		STA $2251					; | y speed calc
		LDA !P2YSpeed-$80				; |
		EOR #$FFFF : INC A				; |
		AND #$00FF					; |
		STA $2253					; |
		SEP #$20					;/
		CPY #$0004*2 : BCS ..nobounce			; check bounce
		CPY #$0000*2					;\
		BNE $02 : ASL $0A				; |
		LDA !P2XSpeed-$80				; | x speed calc
		CLC : ADC $0A					; |
		STA !P2XSpeed-$80				;/
		LDA #$08 : STA !SPC4				; > SFX
		LDA $410000+!BG_object_Timer,x			;\
		CMP #$08 : BCS ..bigbounce			; |
		LDA #$17 : BRA ..setbounce			; |
		..bigbounce					; |
		LDA #$1B					; | bounce anim
		..setbounce					; |
		JSR .SetAnim					; |
		SEP #$20					; |
		..nobounce					;/
		LDA $2307					;\
		BPL $02 : LDA #$7F				; |
		EOR #$FF : INC A				; |
		STA !P2YSpeed-$80				; |
		LDA !P2Character-$80 : BNE ..notmario		; | write speeds
		LDA !P2YSpeed-$80 : STA !MarioYSpeed		; |
		LDA !P2XSpeed-$80 : STA !MarioXSpeed		; |
		..notmario					; |
		REP #$20					; |
		..done						;/

		.BounceP2
		LDA $0C						;\
		AND #$0002 : BEQ ..done				; | must be moving off of pole
		LDA !P2YSpeed-1 : BPL ..done			;/
		LDA !P2XPosLo : JSR .GetMapIndex		; get height map index
		STZ $2250					;\
		LDA ($02),y					; |
		BPL $03 : LDA #$0000				; > negative -> 0
		AND #$00FF					; |
		ASL #4						; |
		ADC #$0100					; |
		STA $2251					; | y speed calc
		LDA !P2YSpeed					; |
		EOR #$FFFF : INC A				; |
		AND #$00FF					; |
		STA $2253					; |
		SEP #$20					;/
		CPY #$0004*2 : BCS ..nobounce			; check bounce
		CPY #$0000*2					;\
		BNE $02 : ASL $0A				; |
		LDA !P2XSpeed					; | x speed calc
		CLC : ADC $0A					; |
		STA !P2XSpeed					;/
		LDA #$08 : STA !SPC4				; > SFX
		LDA $410000+!BG_object_Timer,x			;\
		CMP #$08 : BCS ..bigbounce			; |
		LDA #$17 : BRA ..setbounce			; |
		..bigbounce					; |
		LDA #$1B					; | bounce anim
		..setbounce					; |
		JSR .SetAnim					; |
		SEP #$20					; |
		..nobounce					;/
		LDA $2307					;\
		BPL $02 : LDA #$7F				; |
		EOR #$FF : INC A				; |
		STA !P2YSpeed					; |
		LDA !P2Character : BNE ..notmario		; | write speeds
		LDA !P2YSpeed : STA !MarioYSpeed		; |
		LDA !P2XSpeed : STA !MarioXSpeed		; |
		..notmario					; |
		REP #$20					; |
		..done						;/

		PLB




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
		STZ $0E						; palette included in tile table
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
		STZ $0E						; palette included in tile table
		JMP TileUpdate					;/


		.TilePointer
		dw .Pole0
		dw .Pole1
		dw .Pole2
		dw .Pole3
		dw .Pole4
		dw .Pole5
		dw .Pole6

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
		dw $9414,$9415,$9416,$9417
		dw $9404,$9405,$9406,$9407
		dw $1410,$1410,$1410,$1410
		.Pole5
		.Pole6
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
		dw .Pole6X

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
		dw $D417,$D416,$D415,$D414
		dw $D407,$D406,$D405,$D404
		dw $1410,$1410,$1410,$1410
		.Pole5X
		.Pole6X
		dw $D41B,$D41A,$D419,$D418
		dw $D40B,$D40A,$D409,$D408
		dw $1410,$1410,$1410,$1410



; each entry is for a quad pixel

	.HeightMap
	..0	dw $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
	..1	dw $0004,$0004,$0003,$0003,$0002,$0002,$0001,$0001
	..2	dw $0008,$0005,$0003,$0002,$0002,$0002,$0001,$0001
	..3	dw $0008,$0005,$0003,$0002,$0002,$0002,$0001,$0001
	..4	dw $0000,$FFFE,$FFFF,$FFFF,$0000,$0000,$0001,$0001
	..5	dw $FFF7,$FFF7,$FFF7,$FFFC,$FFFF,$0000,$0001,$0001
	..6	dw $FFF7,$FFF7,$FFF7,$FFFC,$FFFF,$0000,$0001,$0001



		.SetLanding
		BMI ..return
		SEC : SBC $410000+!BG_object_Y,x : BPL ..return
		CMP.w #-$0030 : BCS ..return
		..set2
		LDA #$000F : JSR .SetAnim
		..return
		RTS

		.GetMapIndex
		CLC : ADC #$0008
		SEC : SBC $410000+!BG_object_X,x
		BPL $03 : LDA #$0000
		CMP #$001F
		BCC $03 : LDA #$001F
		LSR #2
		PHA
		LDA $410000+!BG_object_Type,x
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
		CMP $410000+!BG_object_Timer,x : BCC ..return
		STA $410000+!BG_object_Timer,x
		REP #$20
		AND #$00FC
		ASL #2
		ADC.w #.HeightMap
		STA $02
		..return
		REP #$20
		RTS










