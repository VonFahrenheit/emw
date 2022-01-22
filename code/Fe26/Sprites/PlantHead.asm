
PlantHead:

	namespace PlantHead

		!PlantHeadRotation		= $BE		; target angle, anim index is currently displayed angle

		!PlantHeadHP			= $3280
		!PlantHeadChew			= $3290
		!PlantHeadMouth			= $32A0		; timer for how long to hold mouth open
		!PlantHeadAttack		= $32B0		; timer for being able to attack
		!PlantHeadPulseTimer		= $32C0		; timer for pulse animation
		!PlantHeadInvinc		= $32D0

		!PlantHeadXLo			= $3500
		!PlantHeadXHi			= $3510
		!PlantHeadYLo			= $3520
		!PlantHeadYHi			= $3530

		!PrevAnimLo			= $3540
		!PrevAnimHi			= $3550
		!PlantID			= $3560



; changes:
;	,x on all regs
;	target closest player
;	rotation + target rotation (separate regs)
;	mouth + size = normal sprite anim
;	merge VineDestroy code into plant head





	INIT:
		PHB : PHK : PLB

		STZ $00
		STZ $01
		STZ $02
		STZ $03
		STZ $0F
		LDY #$0F
	-	CPY !SpriteIndex
		LDA $3230,y
		CMP #$08 : BNE +
		LDA !NewSpriteNum,y
		CMP !NewSpriteNum,x : BNE +
		LDA !PlantHeadHP,y
		BEQ +
		BMI +
		LDA !PlantID,y : STA $0E
		LDA #$FF : STA ($0E)
	+	DEY : BPL -

		LDY #$00
	-	LDA.w $00,y : BEQ .Ok
		INY
		CPY #$03+1 : BCC -
		STZ $3230,x
		PLB
		RTL

		.Ok
		TYA : STA !PlantID,x


		LDA !SpriteXLo,x : STA !PlantHeadXLo,x
		LDA !SpriteXHi,x : STA !PlantHeadXHi,x
		LDA !SpriteYLo,x : STA !PlantHeadYLo,x
		LDA !SpriteYHi,x : STA !PlantHeadYHi,x

		LDA !ExtraBits,x
		AND #$04 : BEQ .SetHP
		LDA #$3C : STA !PlantHeadAttack,x
		LDA !Difficulty
		.SetHP
		INC A : STA !PlantHeadHP,x

		.GetMode
		REP #$30
		LDA #$0000
		LDY #$0000
		JSL !GetMap16Sprite
		SEP #$30
		LDA $04
		CMP #$0E : BNE ..allrange
		LDY $03
		CPY #$90 : BCS ..readtile
		..allrange
		LDA #$FF : STA !ExtraProp1,x
		BRA ..settimer
		..readtile
		LDA DestructionTiles-$90,y : BNE ..vert
		..horz						;\
		REP #$30					; |
		LDA #$0010					; |
		LDY #$0000					; |
		JSL !GetMap16Sprite				; |
		CMP #$0025					; | horizontal: if tile on the right is NOT empty, vine right (otherwise vine left)
		SEP #$20					; |
		BEQ ..left					; |
		..right						; |
		LDA #$00 : BRA ..setdir				; |
		..left						; |
		LDA #$01 : BRA ..setdir				;/
		..vert						;\
		REP #$30					; |
		LDA #$0000					; |
		LDY #$0010					; |
		JSL !GetMap16Sprite				; |
		CMP #$0025					; | vertical: if tile below is NOT empty, vine down (otherwise vine up)
		SEP #$20					; |
		BEQ ..up					; |
		..down						; |
		LDA #$02 : BRA ..setdir				; |
		..up						; |
		LDA #$03					;/
		..setdir					;\ set direction
		STA !ExtraProp1,x				;/
		..settimer					;\
		LDA !ExtraProp2,x : STA $00			; |
		AND #$3F : TRB $00				; | if timer = 0, default to 8
		BNE $02 : LDA #$08				; |
		ORA $00						; |
		STA !ExtraProp2,x				;/

		PLB
		RTL



	MAIN:
		PHB : PHK : PLB
		LDA #$01 : STA $3320,x
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS


	DATA:
		.Angle
		db $00,$0F,$0E,$0D,$0C		; up left
		db $00,$01,$02,$03,$04		; up right
		db $08,$09,$0A,$0B,$0C		; down left
		db $08,$07,$06,$05,$04		; down right

		.AngleOffset
		db $00,$05,$0A,$0F

		.AttackTime
		db $FF,$E0,$C0

		.HITBOX
		dw $0000,$0000 : db $18,$18



	PHYSICS:
		LDA !PlantHeadHP,x
		BEQ .DestroyVine
		BPL .PlantHead

		; destruction direction = !ExtraProp1
		.DestroyVine
		LDA $32D0,x : BNE ..return				;\
		LDA !ExtraProp2,x					; | handle timer
		AND #$3F : STA $32D0,x					;/
		REP #$30
		LDY #$0000
		LDA #$0000
		JSL !GetMap16Sprite
		SEP #$30
		LDA $04
		CMP #$0E : BNE ..kill
		LDY $03
		CPY #$90 : BCC ..kill
		LDA DestructionTiles-$90,y
		CMP #$05+1 : BCS ..kill
		ASL A : STA !BigRAM
		ASL A
		ADC !ExtraProp1,x
		TAY
		LDA DirectionChange,y : BMI ..kill
		STA !ExtraProp1,x
		..keepdir
		JSR .DestroyTile
		..return
		PLB
		RTL

		..kill
		STZ $3230,x
		PLB
		RTL



		.PlantHead
		JSL SPRITE_OFF_SCREEN
		%decreg(!PlantHeadMouth)
		%decreg(!PlantHeadAttack)
		%decreg(!PlantHeadPulseTimer)
		STZ !PlantHeadChew,x
		LDA !ExtraBits,x
		AND #$04 : BEQ ..noattack
		LDA !PlantHeadAttack,x : BNE ..noattack
		LDY !Difficulty
		LDA DATA_AttackTime,y : STA !PlantHeadAttack,x
		JSR Attack
		..noattack
		LDA !PlantHeadXLo,x : STA $00			;\
		LDA !PlantHeadXHi,x : STA $01			; | get sprite coords
		LDA !PlantHeadYLo,x : STA $02			; |
		LDA !PlantHeadYHi,x : STA $03			;/
		JSR GetClosest					; Y = index to closest player
		REP #$20					;\
		CMP #$4000 : BCS +				; | set chew flag if a player is within 4 tiles (composite distance)
		INC !PlantHeadChew,x				; |
		+						;/
		LDA $00						;\
		SEC : SBC !P2XPosLo-$80,y			; |
		STA $0C						; | $0C = DX
		LDA $02						; | $0E = DY
		SEC : SBC !P2YPosLo-$80,y			; |
		STA $0E						; |
		SEP #$20					;/

		.Limit
		LDY !ExtraProp1,x : BMI ..done
		; Y = vine direction

		REP #$20
		LDA $0C
		BPL $04 : EOR #$FFFF : INC A
		STA $00
		LDA $0E
		BPL $04 : EOR #$FFFF : INC A
		STA $02
		SEP #$20

		LDA #$00					;\
		BIT $0C+1					; |
		BPL $01 : INC A					; |
		BIT $0E+1					; | check quadrant
		BPL $02 : ORA #$02				; | (0 = player up left, 1 = player up right, 2 = player down left, 3 = player down right)
		CMP #$03 : BEQ ..q3				; |
		CMP #$02 : BEQ ..q2				; |
		CMP #$01 : BEQ ..q1				;/
		..q0
		LDA .LimitQ0,y : BRA +
		..q1
		LDA .LimitQ1,y : BRA +
		..q2
		LDA .LimitQ2,y : BRA +
		..q3
		LDA .LimitQ3,y
		+
		BPL ..setlimit
		CMP #$C0
		REP #$10
		BCS ..dxdy
		..dydx
		LDY $00
		CPY $02 : BRA +
		..dxdy
		LDY $02
		CPY $00
		+
		SEP #$10
		BCS ..done
		AND #$0F
		..setlimit
		TAY
		REP #$20
		LDA .LimitX,y : STA $0C
		LDA .LimitY,y : STA $0E
		SEP #$20

		..done


		JSR CheckAngle					; > calculate and analyze |DY|/|DX|
		STY $0A


; vine right
;	topright quadrant -> snap to upper limit
;	botright quadrant -> snap to lower limit
;	topleft quadrant
;		if |DX| < |DY| -> snap to upper limit
;		otherwise keep as is
;	botleft quadrant
;		if |DX| < |DY| -> snap to lower limit
;		otherwise keep as is

; vine left
;	topright quadrant
;		if |DX| < |DY| -> snap to upper limit
;	botright quadrant
;		if |DX| < |DY| -> snap to lower limit
;	topleft quadrant -> snap to upper limit
;	botleft quadrant -> snap to lower limit

; vine down
;	topleft quadrant
;		if |DX| > |DY| -> snap to left limit
;	topright quadrant
;		if |DX| > |DY| -> snap to right limit
;	botleft quadrant -> snap to left limit
;	botright quadrant -> snap to right limit

; vine up
;	botleft quadrant
;		if |DX| > |DY| -> snap to left limit
;	botright quadrant
;		if |DX| > |DY| -> snap to right limit
;	topleft quadrant -> snap to left limit
;	topright quadrant -> snap to right limit


		LDA $01
		ASL A
		ORA $00
		TAY
		LDA DATA_AngleOffset,y
		CLC : ADC $0A
		TAY
		LDA DATA_Angle,y : STA !PlantHeadRotation,x

		LDA #$10 : JSR LimitCircle
		STZ $02
		LDA $00
		BPL $02 : DEC $02
		CLC : ADC !PlantHeadXLo,x
		STA !SpriteXLo,x
		LDA $02
		ADC !PlantHeadXHi,x
		STA !SpriteXHi,x
		STZ $02
		LDA $01
		BPL $02 : DEC $02
		CLC : ADC !PlantHeadYLo,x
		STA !SpriteYLo,x
		LDA $02
		ADC !PlantHeadYHi,x
		STA !SpriteYHi,x
		JMP INTERACTION



; index = vine direction

; read:
;	00-06	-> index to .LimitX and .LimitY
;	if 80 is set, this applies only if $00 < $02
;	if C0 is set, this applies only if $00 > $02


	.LimitQ0
		db $80,$02,$C0,$04
	.LimitQ1
		db $00,$82,$C2,$06
	.LimitQ2
		db $84,$06,$00,$C4
	.LimitQ3
		db $04,$86,$02,$C6

	.LimitX
		dw $0010,$FFF0,$0010,$FFF0
	.LimitY
		dw $0010,$0010,$FFF0,$FFF0



		.XDispLo
		db $10,$F0,$00,$00
		.XDispHi
		db $00,$FF,$00,$00
		.YDispLo
		db $00,$00,$10,$F0
		.YDispHi
		db $00,$00,$00,$FF



		.DestroyTile
		JSL BigPuff
		LDY !ExtraProp1,x
		LDA !SpriteXLo,x
		AND #$F0
		STA $9A
		CLC : ADC .XDispLo,y
		STA !SpriteXLo,x
		LDA !SpriteXHi,x : STA $9B
		ADC .XDispHi,y
		STA !SpriteXHi,x
		LDA !SpriteYLo,x
		AND #$F0
		STA $98
		CLC : ADC .YDispLo,y
		STA !SpriteYLo,x
		LDA !SpriteYHi,x : STA $99
		ADC .YDispHi,y
		STA !SpriteYHi,x
		LDY !BigRAM
		REP #$20
		LDA DestructionCorrection_Loop,y : STA !BigRAM+$10
		LDA DestructionCorrection_X1,y : STA !BigRAM+$00
		LDA DestructionCorrection_X2,y : STA !BigRAM+$02
		LDA DestructionCorrection_X3,y : STA !BigRAM+$04
		LDA DestructionCorrection_Y1,y : STA !BigRAM+$06
		LDA DestructionCorrection_Y2,y : STA !BigRAM+$08
		LDA DestructionCorrection_Y3,y : STA !BigRAM+$0A
		LDA $9A : STA !BigRAM+$0C
		LDA $98 : STA !BigRAM+$0E
		..loop
		LDA #$0025 : JSL !ChangeMap16
		LDY !BigRAM+$10 : BMI ..done
		LDA !BigRAM+$0C
		CLC : ADC !BigRAM+$00,y
		STA $9A
		LDA !BigRAM+$0E
		CLC : ADC !BigRAM+$06,y
		STA $98
		DEY #2 : STY !BigRAM+$10
		BRA ..loop
		..done
		SEP #$20
		LDX !SpriteIndex
		RTS




	INTERACTION:
		REP #$20
		LDA.w #DATA_HITBOX : JSL LOAD_HITBOX

	.HitboxContact
		LDA !PlantHeadInvinc,x : BNE ..nocontact
		JSL P2Attack : BCC ..nocontact
		JSR TakeDamage
		..nocontact

	.FireballContact
		JSL FireballContact_Destroy
		BCC ..nocontact
		LDA !PlantHeadInvinc,x : BNE ..nocontact	; check after so fireballs still get destroyed
		JSR TakeDamage
		..nocontact


	.HurtPlayers
		LDA !PlantHeadPulseTimer,x : BNE ..nocontact
		SEC : JSL !PlayerClipping : BCC ..nocontact
		JSL !HurtPlayers
		..nocontact



	GRAPHICS:

; note:
;	tile 1 = top left
;	tile 2 = top right
;	tile 3 = bot left
;	tile 4 = bot right

; source GFX format:
; -offset-	-content-
;  $000		 upper tile 1
;  $040		 upper tile 2
;  $080		 lower tile 1
;  $0C0		 lower tile 2
;  $100		 upper tile 3
;  $140		 upper tile 4
;  $180		 lower tile 3
;  $1C0		 lower tile 4

; +$200 for each rotation step
; +$2000 for open mouth
; +$4000 for pulse frame 1
; +$6000 for pulse frame 2


	.UpdateAnim
		LDA !PlantHeadPulseTimer,x : BEQ ..idle
		..pulse
		LDA !SpriteAnimIndex
		CMP #$02 : BCS ..animdone
		LDA #$02 : BRA ..setanim
		..idle
		LDA !ExtraBits,x
		AND #$04 : BEQ ..normal
		LDA !PlantHeadAttack,x
		CMP #$1E : BCC ..pulse
		LDA !PlantHeadMouth,x : BEQ ..closedmouth
		..openmouth
		LDA #$01 : BRA ..setanim
		..normal
		LDA !PlantHeadChew,x : BEQ ..closedmouth
		LDA !SpriteAnimIndex
		CMP #$02 : BCC ..animdone
		..closedmouth
		LDA #$00
		..setanim
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..animdone


	.UpdatePalette
		LDA !PlantHeadPulseTimer,x : BNE ..pulsepal
		LDA !ExtraBits,x
		AND #$04 : BRA ..setpal
		..pulsepal
		AND #$04
		..setpal
		EOR #$04
		CLC : ADC #$04
		STA $33C0,x


	.HandleAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP ANIM+$02,y : BNE ..same
		..new
		LDA ANIM+$03,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00
		..same
		STA !SpriteAnimTimer


	.UpdateGFX
		REP #$20
		LDA ANIM,y : STA $00
		LDA !PlantHeadRotation,x
		AND #$000F
		XBA
		ASL A
		ORA $00
		STA $00
		SEP #$20
		CMP !PrevAnimLo,x : BNE ..new
		XBA
		CMP !PrevAnimHi,x : BEQ ..done
		XBA
		..new
		STA !PrevAnimLo,x
		XBA : STA !PrevAnimHi,x
		LDA !PlantID,x : STA $03
		STZ $02
		REP #$20
		JSL !GetVRAM
		LDA #$0200 : STA !VRAMbase+!VRAMtable+$00,x
		LDA #$7F00
		SEC : SBC $02
		STA !VRAMbase+!VRAMtable+$05,x
		LDA !SD_PlantHead : STA $02
		AND #$0003 : TAY
		LDA $02-1
		AND #$FC00
		CLC : ADC $00
		STA !VRAMbase+!VRAMtable+$02,x
		SEP #$20
		LDA .SuperDynamicBank,y : STA !VRAMbase+!VRAMtable+$04,x
		LDX !SpriteIndex
		..done


	.LoadTilemap
		LDA !PlantHeadPulseTimer,x : BNE ..draw
		LDA !PlantHeadInvinc,x
		AND #$02 : BNE ..skip
		..draw
		REP #$20
		LDA.w #ANIM_TM : STA $04
		SEP #$20

		LDA !PlantID,x
		EOR #$03
		ASL #4
		STA !SpriteTile,x
		LDA #$01 : STA !SpriteProp,x

		JSL LOAD_PSUEDO_DYNAMIC_p3
		..skip



		PLB
		RTL




	.SuperDynamicBank
		db $7E,$7F,$40,$41


; rotation key:
;	- 00	straight up
;	- 01	1/16 clockwise
;	- 02	2/16 clockwise
;	- 03	3/16 clockwise
;	- 04	straight right
;	- 05	5/16 clockwise
;	- 06	6/16 clockwise
;	- 07	7/16 clockwise
;	- 08	straight down
;	- 09	9/16 clockwise
;	- 0A	10/16 clockwise
;	- 0B	11/16 clockwise
;	- 0C	straight left
;	- 0D	13/16 clockwise
;	- 0E	14/16 clockwise
;	- 0F	15/16 clockwise






	ANIM:
		dw $0000 : db $08,$01
		dw $2000 : db $08,$00

		dw $4000 : db $03,$03
		dw $6000 : db $05,$04
		dw $4000 : db $03,$05
		dw $0000 : db $05,$02

		.TM
		dw $0040
		db $20,$F8,$F8,$C0
		db $20,$00,$F8,$C1
		db $20,$08,$F8,$C2
		db $20,$10,$F8,$C3
		db $20,$F8,$00,$C4
		db $20,$00,$00,$C5
		db $20,$08,$00,$C6
		db $20,$10,$00,$C7
		db $20,$F8,$08,$C8
		db $20,$00,$08,$C9
		db $20,$08,$08,$CA
		db $20,$10,$08,$CB
		db $20,$F8,$10,$CC
		db $20,$00,$10,$CD
		db $20,$08,$10,$CE
		db $20,$10,$10,$CF




	Attack:
		LDA #$0F : STA !PlantHeadMouth,x	; open mouth timer
		LDA !PlantHeadRotation,x
		ASL A : ADC !PlantHeadRotation,x
		STA $01
		LDA #$02 : STA $00			; > spawn 3 spores

		LDY.b #!Ex_Amount-1
	-	LDA !Ex_Num,y : BEQ .Spawn
	--	DEY : BPL -
		RTS

		.Spawn
		LDA #$0C+!ExtendedOffset : STA !Ex_Num,y
		LDA !SpriteYLo,x : STA !Ex_YLo,y
		LDA !SpriteXLo,x : STA !Ex_XLo,y
		LDA !SpriteYHi,x : STA !Ex_YHi,y
		LDA !SpriteXHi,x : STA !Ex_XHi,y
		LDX $01
		LDA .SpeedY,x : STA !Ex_YSpeed,y
		LDA .SpeedX,x : STA !Ex_XSpeed,y
		LDX !SpriteIndex
		INC $01
		DEC $00 : BPL --
		RTS


		.SpeedY
		db $E8,$E8,$E8		; up
		db $EA,$EC,$EB		; +1 clockwise
		db $EC,$F0,$EE		; +2 clockwise
		db $EE,$F4,$F1		; +3 clockwise
		db $F0,$F8,$F4		; right
		db $F4,$FA,$F7		; +1 clockwise
		db $F8,$FC,$FA		; +2 clockwise
		db $FC,$FE,$FD		; +3 clockwise
		db $00,$00,$00		; down
		db $FC,$FE,$FD		; +1 clockwise
		db $F8,$FC,$FA		; +2 clockwise
		db $F4,$FA,$F7		; +3 clockwise
		db $F0,$F8,$F4		; left
		db $EE,$F4,$F1		; +1 clockwise
		db $EC,$F0,$EE		; +2 clockwise
		db $EA,$EC,$EB		; +3 clockwise

		.SpeedX
		db $08,$00,$F8		; up
		db $0A,$08,$FE		; +1 clockwise
		db $0C,$10,$04		; +2 clockwise
		db $0E,$18,$0A		; +3 clockwise
		db $10,$20,$10		; right
		db $08,$18,$10		; +1 clockwise
		db $00,$10,$10		; +2 clockwise
		db $F8,$08,$10		; +3 clockwise
		db $F0,$00,$10		; down
		db $F0,$F8,$08		; +1 clockwise
		db $F0,$F0,$00		; +2 clockwise
		db $F0,$E8,$F8		; +3 clockwise
		db $F0,$E0,$F0		; left
		db $F6,$E8,$F2		; +1 clockwise
		db $FC,$F0,$F4		; +2 clockwise
		db $02,$F8,$F6		; +3 clockwise


	TakeDamage:
		LDA #$20 : STA !PlantHeadPulseTimer,x
		LDA #$60 : STA !PlantHeadInvinc,x
		DEC !PlantHeadHP,x : BNE .Return
		.Die
		LDA !PlantHeadXLo,x : STA !SpriteXLo,x
		LDA !PlantHeadXHi,x : STA !SpriteXHi,x
		LDA !PlantHeadYLo,x : STA !SpriteYLo,x
		LDA !PlantHeadYHi,x : STA !SpriteYHi,x
		JSL BigPuff
		LDA !ExtraProp2,x				;\ set initial timer
		AND #$3F : STA $32D0,x				;/
		.Return
		RTS



; $00 = horizontal
; $01 = vertical
; $02 = topleft corner
; $03 = topright corner
; $04 = botleft corner
; $05 = botright corner
; anything else = no interaction with this tile, stop chain


	DestructionTiles:
		db $FF,$02,$00,$00,$03,$FF,$00,$00,$FF,$02,$00,$00,$03,$FF,$00,$00	; 9x
		db $FF,$01,$FF,$FF,$01,$FF,$FF,$FF,$FF,$01,$FF,$FF,$01,$FF,$FF,$FF	; Ax
		db $FF,$01,$FF,$FF,$01,$FF,$FF,$FF,$FF,$01,$FF,$FF,$01,$FF,$FF,$FF	; Bx
		db $FF,$04,$00,$00,$05,$FF,$00,$00,$FF,$04,$00,$00,$05,$FF,$00,$00	; Cx
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; Dx
		db $FF,$01,$FF,$FF,$01,$FF,$FF,$FF,$FF,$01,$FF,$FF,$01,$FF,$FF,$FF	; Ex
		db $FF,$01,$FF,$FF,$01,$FF,$FF,$FF,$FF,$01,$FF,$FF,$01,$FF,$FF,$FF	; Fx


		; format: right, left, down, up
		; index: tile type * 4
	DirectionChange:
		;   R   L   D   U
		db $00,$01,$FF,$FF	; horizontal
		db $FF,$FF,$02,$03	; vertical
		db $FF,$02,$FF,$00	; topleft corner
		db $02,$FF,$FF,$01	; topright corner
		db $FF,$03,$00,$FF	; botleft corner
		db $03,$FF,$01,$FF	; botright corner


	DestructionCorrection:
		.Loop
		dw $0002		; horizontal
		dw $0002		; vertical
		dw $0004		; topleft corner
		dw $0004		; topright corner
		dw $0004		; botleft corner
		dw $0004		; botright corner

;		tile 1		tile 2		tile 3
; horz		  0,-10		  0,+10		  n/a
; vert		-10,  0		+10,  0		  n/a
; topleft	-10,-10		  0,-10		-10,  0
; topright	  0,-10		+10,-10		+10,  0
; botleft	-10,  0		-10,+10		  0,+10
; botright	+10,  0		  0,+10		+10,+10


		.X1
		dw $0000		; horizontal
		dw $FFF0		; vertical
		dw $FFF0		; topleft corner
		dw $0000		; topright corner
		dw $FFF0		; botleft corner
		dw $0010		; botright corner

		.X2
		dw $0000		; horizontal
		dw $0010		; vertical
		dw $0000		; topleft corner
		dw $0010		; topright corner
		dw $FFF0		; botleft corner
		dw $0000		; botright corner

		.X3
		dw $FFFF		; horizontal
		dw $FFFF		; vertical
		dw $FFF0		; topleft corner
		dw $0010		; topright corner
		dw $0000		; botleft corner
		dw $0010		; botright corner

		.Y1
		dw $FFF0		; horizontal
		dw $0000		; vertical
		dw $FFF0		; topleft corner
		dw $FFF0		; topright corner
		dw $0000		; botleft corner
		dw $0000		; botright corner

		.Y2
		dw $0010		; horizontal
		dw $0000		; vertical
		dw $FFF0		; topleft corner
		dw $FFF0		; topright corner
		dw $0010		; botleft corner
		dw $0010		; botright corner

		.Y3
		dw $FFFF		; horizontal
		dw $FFFF		; vertical
		dw $0000		; topleft corner
		dw $0000		; topright corner
		dw $0010		; botleft corner
		dw $0010		; botright corner



; input:
;	$00 = source X
;	$02 = source Y
; output:
;	Y = index to closest player
;	A = distance to closest player (also stored in $0C)
	GetClosest:
		STZ $2250					; prepare multiplication
		REP #$20					;\
		LDA !P2XPosLo-$80				; |
		SEC : SBC $00					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $2251					; |
		STA $2253					; |
		LDA !P2YPosLo-$80				; | calculate |DX|^2 and |DY|^2 for player 1
		SEC : SBC $02					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $06						; |
		LDA $2306 : STA $04				; |
		LDA $06						; |
		STA $2251					; |
		STA $2253					;/
		NOP						;\
		LDA $04						; | calculate sqrt(|DX|^2 + |DY|^2)
		CLC : ADC $2306					; |
		JSL !GetRoot : STA $0C				;/
		REP #$20					;\
		LDA !P2XPosLo					; |
		SEC : SBC $00					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $2251					; |
		STA $2253					; |
		LDA !P2YPosLo					; | calculate |DX|^2 and |DY|^2 for player 2
		SEC : SBC $02					; |
		BPL $03 : EOR #$FFFF				; |
		CMP #$00FF					; |
		BCC $03 : LDA #$00FF				; |
		STA $06						; |
		LDA $2306 : STA $04				; |
		LDA $06						; |
		STA $2251					; |
		STA $2253					;/
		NOP						;\
		LDA $04						; | calculate sqrt(|DX|^2 + |DY|^2)
		CLC : ADC $2306					; |
		JSL !GetRoot					;/

		CMP $0C						;\
		BCC .P2Closest					; |
		.P1Closest					; |
		LDA $0C						; |
		SEP #$20					; |
		LDY #$00					; | return with closest player
		RTS						; |
		.P2Closest					; |
		STA $0C						; |
		SEP #$20					; |
		LDY #$80					; |
		RTS						;/



; input
;	$0C = DX
;	$0E = DY

	CheckAngle:
		LDA #$01 : STA $2250			; prepare division
		REP #$20
		STZ $00					; > $00 and $01 determine if DX and DY are positive or negative
		LDA $0E : BPL +				;\
		EOR #$FFFF : INC A			; | calculate dividend
		INC $01					;/
	+	STA $2251				; > dividend = |DY|
		LDA $0C : BPL +				;\
		EOR #$FFFF : INC A			; | calculate divisor
		INC $00					;/
	+	STA $2253				; > divisor = |DX|

		CMP #$0000 : BNE .NotInfinity
		LDY #$00
		BRA .0

		.NotInfinity
		PHA
		LDA $2306
		AND #$00FF
		XBA
		STA $04
		LDA $2308
		XBA
		AND #$FF00
		STA $2251
		PLA : STA $2253
		NOP
		LDY #$00
		LSR A
		CMP $2308
		LDA $2306
		BCS $01 : INC A
		AND #$00FF
		ORA $04

; possible angles (quadrant 1)
;	- 00
;	- 22.5
;	- 45
;	- 67.5
;	- 90

; cutoff angles:
;	- 11.25
;	- 33.75
;	- 56.5
;	- 78.75
		CMP #$0507 : BCS .0
		CMP #$0183 : BCS .1
		CMP #$00AB : BCS .2
		CMP #$0033 : BCS .3
	.4	INY
	.3	INY				; Vastly dominant X (75 < A)
	.2	INY				; Somewhat dominant X (45 < A < 75)
	.1	INY				; Somewhat dominant Y (15 < A < 45)
	.0	SEP #$20			; Vastly dominant Y (A < 15)
		RTS



; MAKE THIS A SHARED ROUTINE!!
;	- comment it
;	- add output description
;
; input:
;	A: radius of circle
;	$0C: DX
;	$0E: DY
;
; output:
;	$00 = circle X
;	$01 = circle Y


	LimitCircle:
		STA $0A					; $0A = radius
		STZ $2250				; multiplication
		REP #$20				;\
		LDA $0E					; |
		BPL $04 : EOR #$FFFF : INC A		; |
		STA $2251				; |
		STA $2253				; |
		NOP : BRA $00				; |
		LDA $2306 : STA $00			; |
		LDA $0C					; | calculate distance to target point
		BPL $04 : EOR #$FFFF : INC A		; |
		STA $2251				; |
		STA $2253				; |
		NOP					; |
		LDA $00					; |
		CLC : ADC $2306				; |
		JSL !GetRoot				;/
		AND #$FF00				;\
		XBA : STA $04				; |
		LDY #$01 : STY $2250			; |
		LDA $0A-1				; |
		AND #$FF00				; | radius / distance (8-bit fixed point) 
		STA $2251				; |
		LDA $04 : STA $2253			; |
		NOP : BRA $00				; |
		LDA $2306				;/
		STA $0A					; store fraction in $0A
		STZ $2250				;\
		STA $2251				; |
		LDA $0E : STA $2253			; |
		NOP : BRA $00				; | multiply DY
		LDA $2307				; |
		AND #$00FF				; |
		EOR #$00FF : INC A			; |
		STA $01					;/
		LDA $0A : STA $2251			;\
		LDA $0C : STA $2253			; |
		NOP : BRA $00				; |
		LDA $2307				; | multiply DX
		AND #$00FF				; |
		EOR #$00FF : INC A			; |
		SEP #$20				; |
		STA $00					;/
		RTS					; return

	.Long
		JSR LimitCircle
		RTL


	namespace off








