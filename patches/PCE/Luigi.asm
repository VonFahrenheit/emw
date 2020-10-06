;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Luigi

; --Build 0.4--
;






	MAINCODE:
		PHB : PHK : PLB
		LDA #$01 : STA !P2Character
		LDA #$02 : STA !P2MaxHP
		LDA !P2Status : BEQ .Process
		CMP #$02 : BEQ .SnapToP1
		CMP #$03 : BNE .KnockedOut

		.Snapped
		REP #$20
		LDA $94 : STA !P2XPosLo
		LDA $96 : STA !P2YPosLo
		SEP #$20
		PLB
		RTS

		.KnockedOut
		REP #$20
		LDA !P2YPosLo
		CLC : ADC #$0004
		STA !P2YPosLo
		SEC : SBC $1C
		CMP #$0180
		SEP #$20
		BMI .Fall
		BCC .Fall
		LDA #$02 : STA !P2Status
		PLB
		RTS

		.Fall
		LDA #$27 : STA !P2Anim
		STZ !P2AnimTimer
		JMP ANIMATION_HandleUpdate
		PLB
		RTS

		.SnapToP1
		REP #$20
		LDA !P2XPosLo
		CMP $94 : BCS +
		ADC #$0004
		BRA ++
	+	SBC #$0004
	++	STA !P2XPosLo
		SEC : SBC $94
		BPL $03 : EOR #$FFFF
		CMP #$0008
		BCC $03 : INC !P2Status
		SEP #$20

		.Return
		PLB
		RTS



		.Process
		LDA !P2MaxHP				;\
		CMP !P2HP				; | enforce max HP
		BCS $03 : STA !P2HP			;/
		LDA !P2Platform : BEQ ++		;\
		CMP !P2SpritePlatform : BEQ +		; | platform code
	++	STA !P2PrevPlatform			; |
		+					;/


		LDA !P2Kick
		BEQ $03 : DEC !P2Kick
		LDA !P2Invinc
		BEQ $03 : DEC !P2Invinc
		LDA !P2SlantPipe
		BEQ $03 : DEC !P2SlantPipe
		LDA !P2PickUp
		BEQ $03 : DEC !P2PickUp
		LDA !P2TurnTimer
		BEQ $03 : DEC !P2TurnTimer



		LDA !P2SlantPipe : BEQ +
		LDA #$40 : STA !P2XSpeed
		LDA #$C0 : STA !P2YSpeed
		+


	PIPE:
		JSR CORE_PIPE
		BCC $03 : JMP ANIMATION_HandleUpdate


; in SMB2:
;	- Luigi's max speed is 0x25 (average of 0x24 and 0x26)
;	- his acceleration is 0x02
;	- his frition is 0x03 (yes, it's as retarded as it sounds)
;	- his maximum fall speed is 0x39
;	- his gravity is 0x02
;	- holding B sets his gravity to 0x01
;	- his initial jump speed is 0xD6 from standstill
;	- his highest running jump speed is 0xD0
;	- his high jump speed is 0xC9



	CONTROLS:
		JSR CORE_COYOTE_TIME
		PEA.w PHYSICS-1








		BIT !P2Water : BPL .Drift			;\
		LDA !P2Blocked					; | only friction when crouching on ground
		AND #$04 : BNE .Friction			;/

		.Drift
		LDA $6DA3					;\
		AND #$03					; |
		TAX						; |
		LDA .Direction,x : BMI .NoTurn			; |
		CMP !P2Direction				; | set direction when only 1 direction is held
		STA !P2Direction				; | (also set turn timer)
		BEQ .NoTurn					; |
		LDA #$08 : STA !P2TurnTimer			; |
		STZ !P2PickUp					; > clear pick up
		.NoTurn						;/

		BIT $6DA3					;\ increment index while running
		BVC $04 : INX #4				;/
		LDA.w .XSpeed,x					;\
		BEQ .Friction					; | determine target speed
		BPL .Right					;/

	.Left	BIT !P2XSpeed : BPL .Friction_L
		CMP !P2XSpeed
		BEQ .SpeedDone
		LDA !P2XSpeed
		BCC .Friction_L+4
		BRA .Friction_R+4

	.Right	BIT !P2XSpeed : BMI .Friction_R
		CMP !P2XSpeed
		BEQ .SpeedDone
		LDA !P2XSpeed
		BCC .Friction_L+4
		BRA .Friction_R+4

		.Friction
		LDA !P2Blocked
		AND #$04 : BNE ..Skid
		LDA !P2XSpeed : BRA .SpeedDone

		..Skid
		LDA !P2XSpeed : BEQ .SpeedDone
		CMP #$FF : BEQ ..0
		CMP #$01 : BNE ..Not0
	..0	LDA #$00 : BRA .SpeedDone

	..Not0	BPL ..L
	..R	LDA !P2XSpeed : INC #2 : BRA .SpeedDone
	..L	LDA !P2XSpeed : DEC #2


		.SpeedDone
		JSR CORE_SET_XSPEED
		LDA !P2Blocked
		AND #$04 : BEQ .Air


		.Ground
		LDA #$80 : TRB !P2Water
		LDA $6DA3
		AND #$04
		BEQ $02 : LDA #$80
		TSB !P2Water

		BIT $6DA7 : BPL .Done

		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		LSR A
		EOR #$FF : INC A
		CLC : ADC #$C0
		STA !P2YSpeed
		LDA #$2B : STA !SPC1		; jump SFX
		BRA .Done


		.Air


		.Done

		RTS


		.XSpeed
		db $00,$18,$E8,$00
		db $00,$25,$DB,$00

		.Direction
		db $FF,$01,$00,$FF

		.CarryOffsetX
		db $F6,$0A
		db $FF,$00

		.CarryOffsetY
		db $04,$02

		.ItemSpeed
		db $F0,$10			; speed for dropping item with no kick



	PHYSICS:
		LDA !P2XSpeed : BEQ +
		LDA !P2Blocked
		AND #$03 : BEQ +
		CMP #$03 : BEQ +
		DEC A
		ROR #2
		EOR !P2XSpeed : BMI +
		STZ !P2XSpeed
		+

		LDA !P2Blocked
		AND #$04 : BEQ .Air

		.Ground
		STZ !P2Dashing
		LDA !P2XSpeed
		BPL $03 : EOR #$FF : INC A
		CMP #$20
		BCC $03 : INC !P2Dashing
		STZ !P2KillCount
		BRA .Done

		.Air

		.Done



	SPRITE_INTERACTION:
		JSR CORE_SPRITE_INTERACTION


	EXSPRITE_INTERACTION:
		JSR CORE_EXSPRITE_INTERACTION


	UPDATE_SPEED:
		LDA #$01				; gravity when holding B is 1
		BIT $6DA3				;\ gravity when not holding B is 2
		BMI $02 : LDA #$02			;/
		BIT !P2YSpeed				;\ increase gravity by 1 while ascending
		BPL $01 : INC A				;/
		STA !P2Gravity				; store gravity
		LDA #$39 : STA !P2FallSpeed		; fall speed is 0x39


		LDA !P2Platform : BEQ .Main
		AND #$0F
		TAX
		LDA $9E,x : STA !P2YSpeed
		LDA $3260,x : STA !P2YFraction
		LDA !P2Blocked : PHA
		LDA !P2XSpeed : PHA
		LDA !P2XFraction : PHA
		BIT !P2Platform
		BVC .Horizontal

		.Vertical
		STZ !P2XSpeed
		BRA .Platform

		.Horizontal
		LDA $AE,x : STA !P2XSpeed
		LDA $3270,x : STA !P2XFraction

		.Platform
		JSR CORE_UPDATE_SPEED
		PLA : STA !P2XFraction
		PLA : STA !P2XSpeed
		PLA : TSB !P2Blocked
		STZ !P2YSpeed

		.Main
		JSR CORE_UPDATE_SPEED
		LDA !P2Platform
		ORA !P2SpritePlatform
		BEQ +
		LDA #$04 : TSB !P2Blocked
		+



	; CARRY ITEM CODE
	; (this has to be run after speed update to sync sprite image)

		LDA !P2Carry : BNE $03
	-	JMP .NoCarry
		DEC A
		TAX

		BIT $6DA3 : BVS .Carry
	.Throw	STZ !P2Carry
		STZ !P2PickUp
		LDA $6DA3					;\
		AND #$0C : BEQ -				; | kick if up/down are not held
		CMP #$0C : BEQ -				;/
		LDY !P2Direction				; Y = index to tables
		CMP #$04 : BEQ .Drop

	.KickUp	LDA #$90 : STA $9E,x				;\ give item X/Y speed
		LDA !P2XSpeed : STA $AE,x			;/
		LDA #$08 : STA !P2Kick				; kick pose
		LDA #$03 : STA !SPC1				; kick sound
		LDA CONTROLS_CarryOffsetX+0,y			;\
		LDY #$FC					; | contact GFX
		JSR CORE_ContactGFX				;/
		BRA +						; go to shared code

	.Drop	LDA !P2XSpeed					;\
		CLC : ADC CONTROLS_ItemSpeed,y			; | give item X speed
		STA $AE,x					;/
	+	LDA #$08					;\
		STA $32E0,x					; | item can't interact with players for 8 frames
		STA $35F0,x					;/
		STZ !SpriteStasis,x				; clear stasis from sprite
		BRA .NoCarry

	.Carry	STZ $3400,x					; clear item's kill count
		LDA $3230,x					;\
		CMP #$09 : BEQ +				; | drop item if its state changes
		STZ !P2Carry					; |
		BRA .NoCarry					;/
	+	LDA !CurrentPlayer				;\
		INC A						; | set shell owner
		STA $34F0,x					;/
		LDA #$02					;\
		STA !SpriteStasis,x				; | item can't move or interact with players
		STA $32E0,x					; |
		STA $35F0,x					;/
		LDY !P2Direction				;\
		LDA !P2XPosLo					; |
		CLC : ADC.w CONTROLS_CarryOffsetX+0,y		; |
		STA $3220,x					; | set item X coordinate
		LDA !P2XPosHi					; |
		ADC.w CONTROLS_CarryOffsetX+2,y			; |
		STA $3250,x					;/
		LDY #$00					;\
		LDA !P2HP					; |
		CMP #$01 : BEQ .Low				; | get height index
		BIT !P2Water : BMI .Low				; |
		LDA !P2PickUp : BEQ .High			; |
	.Low	INY						;/
	.High	LDA !P2YPosLo					;\
		SEC : SBC.w CONTROLS_CarryOffsetY,y		; |
		STA $3210,x					; | set item Y coordinate
		LDA !P2YPosHi					; |
		SBC #$00					; |
		STA $3240,x					;/
		STZ !P2Kick					; > clear kick image
		.NoCarry

		




	OBJECTS:
		LDA !P2Blocked : PHA
		REP #$30
		LDA !P2Anim
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$06,y				;\
		STA $F0					; |
		CLC : ADC #$0004			; | Pointers to clipping
		STA $F2					; |
		CLC : ADC #$0004			; |
		STA $F4					;/
		SEP #$30
		JSR CORE_LAYER_INTERACTION
		PLA
		EOR !P2Blocked
		AND #$04 : BEQ .NoLand

		.Land

		.NoLand


		JSR CORE_CLIMB_GROUND


	SCREEN_BORDER:
		JSR CORE_SCREEN_BORDER


	ANIMATION:
		LDA !P2ExternalAnimTimer			;\
		BEQ .ClearExternal				; |
		DEC !P2ExternalAnimTimer			; | enforce external animations
		LDA !P2ExternalAnim : STA !P2Anim		; |
		DEC !P2AnimTimer				; |
		JMP .HandleUpdate				;/

		.ClearExternal
		STZ !P2ExternalAnim				; clear external animation when timer hits 0


		BIT !P2Water : BMI .Crouch			;\
		LDA !P2PickUp : BEQ .NoCrouch			; > force crouch image timer
	.Crouch	LDA #$05 : STA !P2Anim				; | crouch
		JMP .HandleUpdate				; |
		.NoCrouch					;/

		LDA !P2Kick : BEQ .NoKick			;\
		LDA #$0B : STA !P2Anim				; |
		STZ !P2AnimTimer				; | kick
		JMP .HandleUpdate				; |
		.NoKick						;/


		LDA !P2Carry : BEQ +				;\
		LDA !P2TurnTimer : BEQ +			; | turn if turn timer is set and item is held
		JMP .Turn					; |
		+						;/

		LDA !P2Blocked					;\ determine air/ground status
		AND #$04 : BNE .Ground				;/

		.Air
		BIT !P2YSpeed : BMI .NoFlutter			; no flutter while ascending
		BIT $6DA3 : BPL .NoFlutter			; no flutter without holding B
	.Flutter
		LDA !P2AnimTimer				;\
		INC A						; |
		CMP #$05					; | walk animation with faster speed
		BCC $02 : LDA #$05				; |
		STA !P2AnimTimer				; |
		BRA .Walk					;/
		.NoFlutter

		LDA !P2Carry : BNE .CarryJump			; > carry jump check
		LDA !P2Dashing : BEQ .NormalJump		;\
		LDA #$0F : STA !P2Anim				; | long jump frame during running jump
		JMP .HandleUpdate				;/

		.NormalJump
		LDA #$06					;\
		BIT !P2YSpeed : BMI $01 : INC A			; | determine rising/falling frame
		STA !P2Anim					; |
		JMP .HandleUpdate				;/

		.CarryJump
		LDA #$03 : STA !P2Anim				;\
		STZ !P2AnimTimer				; | second frame of walk animation
		JMP .HandleUpdate				;/

		.Ground
		LDA !P2XSpeed : BNE .Move			; check for Xspeed

		LDA $6DA3					;\
		AND #$08 : BEQ .Stand				; | look up frame when up is held
		LDA #$04 : STA !P2Anim				; |
		BRA .HandleUpdate				;/
	.Stand	STZ !P2Anim					;\ standing frame when X speed is 0
		BRA .HandleUpdate				;/

		.Move
		STA $00						;\
		LDA $6DA3					; |
		AND #$03 : BEQ .NoTurn				; |
		CMP #$03 : BEQ .NoTurn				; | turn frame when holding against Xspeed direction
		DEC A						; |
		ROR #2						; |
		EOR $00 : BMI .Turn				;/

	.NoTurn	LDA !P2Dashing : BNE .Run			; determine walk/run animation
	.Walk	LDA !P2Anim					;\
		CMP #$01 : BCC +				; |
		CMP #$04 : BCC .HandleUpdate			; | walk animation
	+	LDA #$01 : STA !P2Anim				; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Run
		LDA !P2Carry : BEQ $03 : JMP .Flutter		; flutter for running with item
		LDA !P2Anim					;\
		CMP #$0C : BCC +				; |
		CMP #$0F : BCC .HandleUpdate			; | run animation
	+	LDA #$0C : STA !P2Anim				; |
		STZ !P2AnimTimer				; |
		BRA .HandleUpdate				;/

		.Turn
		LDA #$10 : STA !P2Anim				; turn frame
		LDA !P2Carry : BEQ .HandleUpdate		;\
		DEC A						; |
		TAX						; | set carried item coordinate
		LDA !P2XPosLo : STA $3220,x			; |
		LDA !P2XPosHi : STA $3250,x			;/




		.HandleUpdate
		LDA !P2Anim
		REP #$30
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$20
		LDA !P2AnimTimer
		INC A
		CMP ANIM+$02,y
		BNE .NoUpdate
		LDA ANIM+$03,y
		STA !P2Anim
		REP #$20
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$20
		LDA #$00

		.NoUpdate
		STA !P2AnimTimer
		LDA !MultiPlayer : BEQ .ThisOne		; animate at 60fps on single player
		LDA !CurrentPlayer
		BEQ +
		LDA $14
		LSR A
		BCS .ThisOne
		BRA .OtherOne
	+	LDA $14
		LSR A
		BCC .ThisOne

		.OtherOne
		REP #$30
		LDA !P2Anim2
		AND #$00FF
		ASL #3
		TAY
		LDA ANIM+$00,y
		STA $0E
		SEP #$30
		JMP GRAPHICS

		.ThisOne
		REP #$30
		LDA ANIM+$04,y : STA $04



;	tiles:		4 bits
;	source tile:	10 bits
;	bank:		predefined
;	dest VRAM:	5 bits
;
; -------d dddd----
; -------t ttt-----
; -sssssss sss-----
;
; format:
;   \20        \10
; 32109876 54321098 76543210
; ddddd--t tttsssss sssss---
;
; calculate dest:
;	LDA Dyn+2
;	AND #$00F8
;	ASL A
;	STA !BigRAM+5
;
; calculate source:
;	LDA Dyn+0
;	AND #$1FF8
;	ASL #2
;	STA !BigRAM+2
;
; calculate size:
;	LDA Dyn+1
;	AND #$01E0
;	STA !BigRAM+0
;
;
;
; Luigi format:
; ttttssss ssssss--
;
; calculate source:
;	LDA Dyn+0
;	AND #$0FFC
;	ASL #3
;	STA !BigRAM+2
;
; calculate size:
;	LDA Dyn+1
;	AND #$00F0
;	ASL A
;	STA !BigRAM+0


		SEP #$10
		LDY #$3A				;\
		STY !BigRAM+$06				; |
		STY !BigRAM+$0D				; | bank bytes
		STY !BigRAM+$14				; |
		STY !BigRAM+$1B				;/

		LDA ($04)				;\
		AND #$0FFC				; | get source tile bits
		ASL #3					;/

		LDY !P2Carry : BEQ .NoCarryAddress	;\
		CLC : ADC #$0800			; | carrying offset
		.NoCarryAddress				;/


		LDY !P2HP				;\
		CPY #$02 : BCS .BigAddress		; |
		STA $00					; |
		AND #$01E0				; |
		STA $02					; X tile
		LDA $00					; |
		AND #$7E00				; | recalculate address for small Luigi
		LSR #2					; |
		STA $00					; |
		ASL A					; |
		CLC : ADC $00				; |
		ORA $02					; |
		CLC : ADC #$3800			; |
		.BigAddress				;/

		CLC : ADC #$8008			;\
		STA !BigRAM+$04				; |
		CLC : ADC #$0200			; | source address
		STA !BigRAM+$0B				; | (add 0x800 while carrying)
		CLC : ADC #$0200			; | (multiply by .75 and add 0x3800 for small Luigi)
		STA !BigRAM+$12				; |
		CLC : ADC #$0200			; |
		STA !BigRAM+$19				;/

		LDA.w #(!P2Tile1*$10)|$6000		;\ $6200
		STA !BigRAM+$07				;/
		LDA.w #(!P2Tile1*$10)|$6100		;\ $6300
		STA !BigRAM+$0E				;/
		LDA.w #(!P2Tile3*$10)|$6000		;\ $6240
		STA !BigRAM+$15				;/
		LDA.w #(!P2Tile3*$10)|$6100		;\ $6340
		STA !BigRAM+$1C				;/



		LDY !P2HP
		CPY #$02 : BCS .BigFormat
		LDA !BigRAM+$12 : STA !BigRAM+$19	; 3 -> 4
		LDA !BigRAM+$0B : STA !BigRAM+$12	; 2 -> 3
		.BigFormat




		INC $04					;\
		LDA ($04)				; |
		AND #$00F0				; |
		ASL A					; | upload size
		STA !BigRAM+$02				; |
		STA !BigRAM+$09				; |
		STA !BigRAM+$10				; |
		STA !BigRAM+$17				;/

		LDA #$001C : STA !BigRAM+$00		; header


		LDA.w #!BigRAM
		JSR CORE_GENERATE_RAMCODE
		LDA !P2Anim
		STA !P2Anim2


	GRAPHICS:
		LDA !P2HurtTimer : BNE .DrawTiles
		LDA !P2Invinc : BEQ .DrawTiles
		AND #$06 : BNE .DrawTiles
		PLB
		RTS

		.DrawTiles
		REP #$20
		LDA $0E : STA $04
		LDY !P2HP
		CPY #$02 : BCS .Big
		CLC : ADC ($04)				;\
		INC #2					; | small Luigi tilemap
		STA $04					;/

	.Big	SEP #$20
		JSR CORE_LOAD_TILEMAP
		PLB
		RTS




	; Anim format:
	; dw $TTTT : db $tt,$NN
	; dw $DDDD
	; dw $CCCC
	; TTTT is tilemap pointer.
	; tt is frame count.
	; NN is next anim.
	; DDDD is dynamo pointer.
	; CCCC is clipping pointer.


	ANIM:
	.Idle0
	dw .16x32TM : db $00,$00	; 00
	dw .IdleDyn
	dw .ClippingStandard

	.Walk
	dw .16x32TM : db $06,$02	; 01
	dw .IdleDyn
	dw .ClippingStandard
	dw .16x32TM : db $06,$03	; 02
	dw .WalkDyn00
	dw .ClippingStandard
	dw .16x32TM : db $06,$01	; 03
	dw .WalkDyn01
	dw .ClippingStandard

	.LookUp
	dw .16x32TM : db $FF,$04	; 04
	dw .LookUpDyn
	dw .ClippingStandard

	.Crouch
	dw .16x32TM : db $FF,$05	; 05
	dw .CrouchDyn
	dw .ClippingCrouch

	.Jump
	dw .16x32TM : db $FF,$06	; 06
	dw .RiseDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,$07	; 07
	dw .FallDyn
	dw .ClippingStandard

	.Slide
	dw .16x32TM : db $FF,$08	; 08
	dw .SlideDyn
	dw .ClippingStandard

	.FaceBack
	dw .16x32TM : db $FF,$09	; 09
	dw .FaceBackDyn
	dw .ClippingStandard

	.FaceFront
	dw .16x32TM : db $FF,$0A	; 0A
	dw .FaceFrontDyn
	dw .ClippingStandard

	.Kick
	dw .16x32TM : db $08,$00	; 0B
	dw .KickDyn
	dw .ClippingStandard

	.Run
	dw .24x32TM : db $03,$0D	; 0C
	dw .RunDyn00
	dw .ClippingStandard
	dw .24x32TM : db $03,$0E	; 0D
	dw .RunDyn01
	dw .ClippingStandard
	dw .24x32TM : db $03,$0C	; 0E
	dw .RunDyn02
	dw .ClippingStandard

	.LongJump
	dw .24x32TM : db $FF,$0F	; 0F
	dw .LongJumpDyn
	dw .ClippingStandard

	.Turn
	dw .16x32TM : db $FF,$10	; 10
	dw .TurnDyn
	dw .ClippingStandard

	.Victory
	dw .16x32TM : db $FF,$11	; 11
	dw .VictoryDyn
	dw .ClippingStandard

	.Swim
	dw .24x32TM : db $FF,$12	; 12
	dw .SwimDyn00
	dw .ClippingStandard
	dw .24x32TM : db $04,$14	; 13
	dw .SwimDyn01
	dw .ClippingStandard
	dw .24x32TM : db $04,$12	; 14
	dw .SwimDyn02
	dw .ClippingStandard

	.Climb
	dw .16x32TM : db $FF,$15	; 15
	dw .ClimbFrontDyn
	dw .ClippingStandard
	dw .24x32TM : db $FF,$16	; 16
	dw .ClimbFrontTDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,$17	; 17
	dw .ClimbBackTDyn
	dw .ClippingStandard
	dw .16x32TM : db $FF,$18	; 18
	dw .ClimbBackDyn
	dw .ClippingStandard
	dw .24x32TM : db $FF,$19	; 19
	dw .ClimbPunchDyn
	dw .ClippingStandard

	.Hammer
	dw .16x32TM : db $08,$1B	; 1A
	dw .HammerDyn00
	dw .ClippingStandard
	dw .16x32TM : db $08,$1C	; 1B
	dw .HammerDyn01
	dw .ClippingStandard
	dw .16x32TM : db $10,$1A	; 1C
	dw .HammerDyn02
	dw .ClippingStandard

	.Cutscene
	dw .16x32TM : db $FF,$1D	; 1D
	dw .CutsceneDyn00
	dw .ClippingStandard
	dw .16x32TM : db $FF,$1E	; 1E
	dw .CutsceneDyn01
	dw .ClippingStandard
	dw .16x32TM : db $FF,$1F	; 1F
	dw .CutsceneDyn02
	dw .ClippingStandard
	dw .16x32TM : db $FF,$20	; 20
	dw .CutsceneDyn03
	dw .ClippingStandard
	dw .16x32TM : db $FF,$21	; 21
	dw .CutsceneDyn04
	dw .ClippingStandard
	dw .16x32TM : db $FF,$22	; 22
	dw .CutsceneDyn05
	dw .ClippingStandard
	dw .16x32TM : db $FF,$23	; 23
	dw .CutsceneDyn06
	dw .ClippingStandard

	.Balloon
	dw .32x32TM : db $FF,$24	; 24
	dw .BalloonDyn
	dw .ClippingStandard

	.Hurt
	dw .16x32TM : db $20,$00	; 25
	dw .HurtDyn
	dw .ClippingStandard

	.Shrink
	dw .16x32TM : db $20,$00	; 26
	dw .ShrinkDyn
	dw .ClippingStandard

	.Death
	dw .16x32TM : db $FF,$27	; 27
	dw .DeathDyn
	dw .ClippingStandard




	.16x32TM
	dw $0008			; big Luigi
	db $2E,$00,$F0,!P2Tile1
	db $2E,$00,$00,!P2Tile3
	dw $0008			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$00,$00,!P2Tile3


	.24x32TM
	dw $0010			; big Luigi
	db $2E,$00,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1
	dw $0010			; small Luigi
	db $2E,$00,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile1+1
	db $2E,$00,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile3+1


	.32x32TM
	dw $0010			; big Luigi
	db $2E,$F8,$F0,!P2Tile1
	db $2E,$08,$F0,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4
	dw $0010			; small Luigi
	db $2E,$F8,$F8,!P2Tile1
	db $2E,$08,$F8,!P2Tile2
	db $2E,$F8,$00,!P2Tile3
	db $2E,$08,$00,!P2Tile4


macro LuiDyn(TileCount, TileNumber)
	dw <TileNumber><<2|(<TileCount><<12)
endmacro


	.IdleDyn	%LuiDyn(2, $000)
	.WalkDyn00	%LuiDyn(2, $002)
	.WalkDyn01	%LuiDyn(2, $004)

	.LookUpDyn	%LuiDyn(2, $006)

	.CrouchDyn	%LuiDyn(2, $008)

	.RiseDyn	%LuiDyn(2, $00A)
	.FallDyn	%LuiDyn(2, $00C)

	.SlideDyn	%LuiDyn(2, $00E)

	.CarryIdleDyn	%LuiDyn(2, $040)
	.CarryWalkDyn00	%LuiDyn(2, $042)
	.CarryWalkDyn01	%LuiDyn(2, $044)
	.CarryLookUpDyn	%LuiDyn(2, $046)
	.CarryCrouchDyn	%LuiDyn(2, $048)

	.FaceBackDyn	%LuiDyn(2, $08E)

	.FaceFrontDyn	%LuiDyn(2, $08C)

	.KickDyn	%LuiDyn(2, $04E)

	.RunDyn00	%LuiDyn(3, $080)
	.RunDyn01	%LuiDyn(3, $083)
	.RunDyn02	%LuiDyn(3, $086)

	.LongJumpDyn	%LuiDyn(3, $089)

	.TurnDyn	%LuiDyn(2, $04C)

	.VictoryDyn	%LuiDyn(2, $04A)

	.SwimDyn00	%LuiDyn(3, $0C0)
	.SwimDyn01	%LuiDyn(3, $0C3)
	.SwimDyn02	%LuiDyn(3, $0C6)
	.SwimCarryDyn00	%LuiDyn(3, $100)
	.SwimCarryDyn01	%LuiDyn(3, $103)
	.SwimCarryDyn02	%LuiDyn(3, $106)

	.ClimbFrontDyn	%LuiDyn(2, $0C9)
	.ClimbFrontTDyn	%LuiDyn(3, $0CB)
	.ClimbBackTDyn	%LuiDyn(2, $109)
	.ClimbBackDyn	%LuiDyn(2, $10B)
	.ClimbPunchDyn	%LuiDyn(3, $10D)

	.HammerDyn00	%LuiDyn(2, $140)
	.HammerDyn01	%LuiDyn(2, $142)
	.HammerDyn02	%LuiDyn(2, $144)

	.CutsceneDyn00	%LuiDyn(2, $146)
	.CutsceneDyn01	%LuiDyn(2, $148)
	.CutsceneDyn02	%LuiDyn(2, $14A)
	.CutsceneDyn03	%LuiDyn(2, $14C)
	.CutsceneDyn04	%LuiDyn(2, $14E)
	.CutsceneDyn05	%LuiDyn(2, $180)
	.CutsceneDyn06	%LuiDyn(2, $182)

	.BalloonDyn	%LuiDyn(4, $184)

	.HurtDyn	%LuiDyn(2, $188)
	.ShrinkDyn	%LuiDyn(2, $18A)
	.DeathDyn	%LuiDyn(2, $18C)



	.ClippingStandard
	db $0D,$02,$05,$05		; < X offset
	db $FF,$FF,$10,$F4		; < Y offset
	db $10,$10,$05,$05		; < Size

	.ClippingCrouch
	db $0D,$02,$05,$05		; < X offset
	db $05,$05,$10,$00		; < Y offset
	db $0A,$0A,$05,$05		; < Size


.End
print "  Anim data: $", hex(.End-ANIM), " bytes"
print "  - sequence data: $", hex(.16x32TM-ANIM), " bytes (", dec((.16x32TM-ANIM)*100/(.End-ANIM)), "%)"
print "  - tilemap data:  $", hex(.IdleDyn-.16x32TM), " bytes (", dec((.IdleDyn-.16x32TM)*100/(.End-ANIM)), "%)"
print "  - dynamo data:   $", hex(.ClippingStandard-.IdleDyn), " bytes (", dec((.ClippingStandard-.IdleDyn)*100/(.End-ANIM)), "%)"
print "  - clipping data: $", hex(.End-.ClippingStandard), " bytes (", dec((.End-.ClippingStandard)*100/(.End-ANIM)), "%)"


namespace off





