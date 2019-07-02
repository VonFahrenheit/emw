;
; Ride Armor by Von Fahrenheit
;
; --RAM usage--
;
; $C2:	Sprite flags: ccc--aad
;	- ccc is controller mode. Values are:
;		000: inactive
;		001: controlled by player 1
;		010: controlled by player 2
;		011: controlled by player 1 and player 2
;		100: controlled by playre 2 and player 1
;		101: controlled by enemy AI
;		110: controlled by ally AI
;		111: controlled by neutral AI
;	- aa is attack mode. Values are:
;		00: can't attack
;		01: can attack players
;		10: can attack enemies
;		11: can attack players and enemies
;	- d is dash. While dashing the sprite accesses the high Xspeed table.
;
; $1540:	Boost timer. While non-zero B can be held to jump higher.
; $1570:	Legs tilemap index, must be divisible by 2
; $157C:	Horizontal direction
; $1594:	Startup timer. Increments.
; $15AC:	Legs animation timer
; $1602:	Torso tilemap index, must be divisible by 2
; $163E:	Torso animation timer

;=======;
;DEFINES;
;=======;
	!OAM = $0300
	!OAMhi = $0460

;============;
;INIT ROUTINE;
;============;
print "INIT ",pc
INITCODE:	LDA #$01
		STA $157C,x
		RTL

;============;
;MAIN ROUTINE;
;============;
print "MAIN ",pc
MAINCODE:	PHB : PHK : PLB
		PEA.w ANIMATION-1			; ANIMATION is the next routine to be run
		PHX
		LDA $C2,x
		LSR #4
		TAX
		JMP (.ControllerPtr,x)
	
		.ControllerPtr
		dw Passive				; 000
		dw Player1				; 001
		dw EmptyPtr				; 010
		dw EmptyPtr				; 011
		dw EmptyPtr				; 100
		dw EnemyAI				; 101
		dw EmptyPtr				; 110
		dw EmptyPtr				; 111

EmptyPtr:	PLX
		RTS

;=================;
;PASSIVE BEHAVIOUR;
;=================;
Passive:	PLX					; X = sprite index
		LDA $71					;\ No contact if Mario is dead
		BNE .NoContact				;/
		LDA $1594,x				;\ Check if the player has already touched the sprite
		BNE .Contact				;/
		LDA $77					;\
		AND #$04				; |
		BNE .NoContact				; | The player has to jump into the sprite
		LDA $7D					; |
		BMI .NoContact				;/
		JSR INTERACTION				;\ Check for contact
		BCC .NoContact				;/
.Contact	LDA #$7F				;\
		STA $78					; |
		LDA $E4,x				; |
		STA $94					; |
		LDA $14E0,x				; |
		STA $95					; |
		LDA $D8,x				; | Snap the player to the sprite
		SEC : SBC #$30				; |
		STA $96					; |
		LDA $14D4,x				; |
		SBC #$00				; |
		STA $97					; |
		STZ $7B					; |
		STZ $7D					;/
		LDA #$F0				;\
		STA $02F9-$18				; |
		STA $02FD-$18				; |
		STA $0301-$18				; | Hide Mario
		STA $0305-$18				; |
		STA $0309-$18				; |
		STA $030D-$18				; |
		STA $0311-$18				; |
		STA $0315-$18				;/
		LDA #$0D				;\ Mario pose
		STA $13E0				;/

		INC $1594,x
		LDA $1594,x
		LSR #3
		TAY
		CPY #$04
		BNE +
		LDA $C2,x				;\
		AND.b #$06^$FF				; | Controller mode 001, attack mode 10
		ORA #$24				; |
		STA $C2,x				;/
	+	LDA.w .StartupFrames,y
		STA $1570,x
		RTS

.NoContact	LDA #$2C				;\ Inactive animation
		STA $1570,x				;/
		LDA $1588,x
		AND #$04
		PHA
		BNE .Ground
		INC $AA,x
		INC $AA,x
		BRA .Ground+2
.Ground		STZ $B6,x
		JSL $01802A
		PLA
		BNE .NoLanding
		LDA $1588,x
		AND #$04
		BEQ .NoLanding
		LDA #$09
		STA $1DFC
		LDA #$08
		STA $1887
.NoLanding	RTS

.StartupFrames	db $2C,$2E,$30,$32,$00

;==================;
;PLAYER 1 BEHAVIOUR;
;==================;
Player1:	PLX					; X = sprite index
		LDA $71
		CMP #$09
		BEQ .Exit
		LDA $16
		LSR #4
		AND $15
		AND #$08
		BEQ .NoExit
.Exit		LDA #$B0
		STA $7D
		LDA $B6,x
		STA $7B
		LDA $C2,x
		AND #$19
		STA $C2,x
		STZ $1602,x
		STZ $140D
		LDA #$0C
		STA $72
		RTS
.NoExit		LDA #$7F				;\
		STA $78					; |
		LDA $E4,x				; |
		STA $94					; |
		LDA $14E0,x				; |
		STA $95					; |
		LDA $D8,x				; | Snap the player to the sprite
		SEC : SBC #$30				; |
		STA $96					; |
		LDA $14D4,x				; |
		SBC #$00				; |
		STA $97					; |
		STZ $7B					; |
		STZ $7D					;/
		STZ $1594,x
		LDA $1588,x
		AND #$04
		PHA
		BEQ .Midair
		LSR $C2,x
		ASL $C2,x
		LDA $1570,x
		CMP #$1C
		BNE +
		LDY $17
		BMI +
		STZ $15AC,x
		BRA .NoDashFlag
	+	CMP #$18
		BCC .NoDashFlag
		CMP #$1D
		BCS .NoDashFlag
		INC $C2,x
.NoDashFlag	LDA $16
		BPL +
		LDA $1570,x				;\
		CMP #$22				; |
		BMI .Jump				; | Don't allow jumping out of landing lag
		CMP #$2B				; |
		BMI +					;/
.Jump		LDA #$B0
		STA $AA,x
		LDA #$1F
		STA $1540,x
		BRA +
.Midair		LDA $15
		BMI .Boost
		STZ $1540,x
.Boost		LDA $1540,x
		BNE +
		INC $AA,x
		INC $AA,x
	+	LDA $C2,x
		AND #$01
		ASL #2
		STA $00
		BEQ .NoDash
		LDA $01,s
		BNE .GroundDash
		LDA $15					;\
		AND #$03				; | Handle midair dash speed
		ORA $00					; |
		BRA .Shared				;/
		.GroundDash
		LDA $15
		AND #$03
		BEQ .NoInput
		CMP #$03
		BEQ .NoInput
		PHA
		LDA $157C,x
		INC A
		EOR $01,s
		AND #$03
		BEQ +
		STZ $15AC,x
	+	PLA
		BRA .GoodInput
.NoInput	LDA $157C,x				;\
		INC A					; | Base speed on direction
.GoodInput	ORA $00					; |
		BRA .Shared				;/
.NoDash		LDA $15
		AND #$03
		BEQ +
		CMP #$03
		BNE ++
	+	LDY $1570,x
		CPY #$22
		BCS ++
		STZ $1570,x
	++	ORA $00
.Shared		TAY
		LDA.w .XSpeed,y
		STA $B6,x
		BEQ +
		LDA $1570,x
		CMP #$22
		BCS +
		CMP #$1D
		BCS .StartWalk
		CMP #$00
		BNE +
.StartWalk	LDA #$02
		STA $1570,x
	+	TYA
		LSR A
		BCC +
		STZ $157C,x
		BRA ++
	+	LSR A
		BCC ++
		LDA #$01
		STA $157C,x
	++	JSR XCOLLISION
		JSL $01802A
		JSR INTERACTION
		PLA
		BNE .NoLanding
		LDA $1588,x
		AND #$04
		BEQ .NoLanding
		LDA #$09
		STA $1DFC
		LDA #$22
		STA $1570,x
		LDA #$05
		STA $15AC,x
		LDA #$08
		STA $1887
.NoLanding	RTS

.XSpeed		db $00,$10,$F0,$00
		db $00,$28,$D8,$00

;==================;
;ENEMY AI BEHAVIOUR;
;==================;
EnemyAI:	PLX
		RTS

;==================;
;XCOLLISION ROUTINE;
;==================;
XCOLLISION:	LDA $B6,x
		BPL .PosX
		LDA $1588,x
		AND #$02
		BEQ .Return
		LDA #$F0
		STA $B6,x
		INC $E4,x
		RTS
.PosX		LDA $1588,x
		LSR A
		BCC .Return
		LDA #$10
		STA $B6,x
		DEC $E4,x
.Return		RTS

;===================;
;INTERACTION ROUTINE;
;===================;
INTERACTION:	LDY $157C,x				;\
		LDA $E4,x				; |
		SEC : SBC.w .SpriteXDisp,y		; |
		STA $04					; |
		LDA $14E0,x				; |
		SBC #$00				; |
		STA $0A					; |
		LDA #$22				; | Get sprite clipping. Look at $03B69F in all.log for reference.
		STA $06					; |
		LDY $1570,x				; |
		LDA $D8,x				; |
		SEC : SBC.w .SpriteYDisp,y		; |
		STA $05					; |
		LDA $14D4,x				; |
		SBC #$00				; |
		STA $0B					; |
		LDA #$40				; |
		STA $07					;/
		PEA.w .AttackBlocks-1			; > Set return address
		PHX					;\
		LDA $C2,x				; |
		AND #$06				; | Decide what to compare to
		TAX					; |
		BEQ .SearchPilot			; |
		JMP (.HitBoxPtr,x)			;/

		.HitBoxPtr
		dw .SearchPilot
		dw .AttackPlayers
		dw .AttackEnemies
		dw .AttackAll

.AttackBlocks	LDA [$00]
		XBA
		INC $02
		LDA [$00]
		XBA
		REP #$20
		CMP.w #$0111
		BCC +
		CMP.w #$12F
		BCS +
		SEP #$20
	+	SEP #$20
		RTS

.SearchPilot	TXY					; Y = 0x00
		PLX					; X = sprite index
		LDA $94					;\
		CLC : ADC #$02				; |
		STA $00					; |
		LDA $95					; |
		ADC #$00				; |
		STA $08					; |
		LDA #$0C				; |
		STA $02					; |
		LDA $73					; |
		BNE .Ducking				; |
		LDA $19					; | Get player clipping. Look at $03B664 in all.log for reference.
		BNE .BigHitbox				; |
.Ducking	INY					; |
.BigHitbox	LDA $187A				; |
		BEQ .NoYoshi				; |
		INY #2					; |
.NoYoshi	LDA.w .PlayerHeight,y			; |
		STA $03					; |
		LDA $96					; |
		CLC : ADC.w .PlayerYDisp,y		; |
		STA $01					; |
		LDA $97					; |
		ADC #$00				; |
		STA $09					;/
		JSL $03B72B
		PLA : PLA
		RTS

.AttackPlayers	PLX
		RTS

.AttackEnemies	LDX #$0B				;\ Set up loop
		LDY $15E9				;/
		LDA #$10				;\
		STA $07					; |
		LDA $05					; |
		CLC : ADC #$30				; | Set up hitbox
		STA $05					; |
		LDA $0B					; |
		ADC #$00				; |
		STA $0B					;/
	-	PHY					; Push sprite index
		CPX $15E9				;\
		BEQ +					; |
		LDA $14C8,x				; |
		CMP #$08				; |
		BMI +					; |
		CMP #$0A				; |
		BPL +					; |
		LDA $1588,y				; | See if stomping is approperiate
		AND #$04				; |
		BNE +					; |
		LDA $00AA,y				; |
		BMI +					;/
		LDY #$00				;\
		LDA $7FAB10,x				; | Check for custom sprite
		AND #$08				; |
		BEQ ++					;/
		LDA $7FAB9E,x				;\
		LSR A					; |
		BCC $01 : INY				; |
		LSR A					; |
		BCC $02 : INY #2			; | Get custom sprite module index
		LSR A					; |
		BCC $04 : INY #4			; |
		CLC : ADC #$20				; |
		BRA +++					;/
	++	LDA $9E,x				;\
		LSR A					; |
		BCC $01 : INY				; |
		LSR A					; |
		BCC $02 : INY #2			; |
		LSR A					; | Check sprite module
		BCC $04 : INY #4			; |
	+++	STY $0F					; |
		TAY					; |
		LDA.w SpriteModules,y			; |
		LDY $0F					; |
		AND.w AND_table,y			; |
		BEQ +					;/
		JSL $03B6E5				;\
		JSL $03B72B				; | Check for contact
		BCC +					;/
		LDA #$04				;\
		STA $14C8,x				; |
		LDA #$1F				; | Crush sprite
		STA $1540,x				; |
		LDA #$08				; |
		STA $1DF9				;/
	+	PLY					; Y = sprite index
		DEX					;\ Loop
		BPL -					;/
		LDA $1602,y				;\
		BNE .ProcessPunch			; |
		PLX					; | Return if there is no punch
		PLA : PLA				; |
		RTS					;/
.ProcessPunch	DEC #2					;\
		TAX					; | Get punch table index
		LDA $157C,y				; |
		BEQ $01 : INX				;/
		LDA $05					;\
		SEC : SBC.w .PunchYDisp,x		; |
		STA $05					; |
		LDA $0B					; |
		SBC #$00				; |
		STA $0B					; |
		LDA.w .PunchWidth,x			; |
		STA $06					; |
		LDA.w .PunchHeight,x			; |
		STA $07					; |
		LDA $157C,y				; | Get punch clipping
		BEQ +					; |
		LDA $00E4,y				; |
		SEC : SBC.w .PunchXDisp,x		; |
		STA $04					; |
		LDA $14E0,y				; |
		SBC #$00				; |
		STA $0A					; |
		BRA .PunchSprites			; |
	+	LDA $00E4,y				; |
		CLC : ADC.w .PunchXDisp,x		; |
		STA $04					; |
		LDA $14E0,y				; |
		ADC #$00				; |
		STA $0A					;/
.PunchSprites	LDX #$0B				; > Set up loop
	-	PHY					;\
		CPX $15E9				; |
		BEQ +					; |
		LDA $14C8,x				; |
		CMP #$08				; | See if punching is approperiate
		BMI +					; |
		CMP #$0A				; |
		BPL +					;/
		LDY #$00				;\
		LDA $7FAB10,x				; | Check for custom sprite
		AND #$08				; |
		BEQ ++					;/
		LDA $7FAB9E,x				;\
		LSR A					; |
		BCC $01 : INY				; |
		LSR A					; |
		BCC $02 : INY #2			; | Get custom sprite module index
		LSR A					; |
		BCC $04 : INY #4			; |
		CLC : ADC #$20				; |
		BRA +++					;/
	++	LDA $9E,x				;\
		LSR A					; |
		BCC $01 : INY				; |
		LSR A					; |
		BCC $02 : INY #2			; |
		LSR A					; | Check sprite module
		BCC $04 : INY #4			; |
	+++	STY $0F					; |
		TAY					; |
		LDA.w SpriteModules,y			; |
		LDY $0F					; |
		AND.w AND_table,y			; |
		BEQ +					;/
		JSL $03B6E5				;\
		JSL $03B72B				; | Check for contact
		BCC +					;/
		LDA #$04				;\
		STA $14C8,x				; |
		LDA #$1F				; | Crush sprite
		STA $1540,x				; |
		LDA #$08				; |
		STA $1DF9				;/
	+	PLY					; Y = sprite index
		DEX					;\ Loop
		BPL -					;/
.Return		PLX					; X = sprite index
		JMP GET_MAP16				; Return

.AttackAll	PLX
		JSR .AttackPlayers+1
		JMP .AttackEnemies+1

.PlayerYDisp	db $06,$14,$10,$18
.PlayerHeight	db $1A,$0C,$20,$18
.SpriteXDisp	db $00,$14				; Indexed by $157C, subtracted from Xpos
.SpriteYDisp	dw $0027,$002B,$002A,$0029		; Indexed by $1570, subtracted from Ypos
		dw $002B,$002C,$002B,$0028
		dw $002B,$002C,$0027,$0027
		dw $0026,$0025,$0024,$0025
		dw $0026,$0026,$0025,$0024
		dw $0025,$0026,$001F,$0022
		dw $0024,$0026

.PunchXDisp	dw $1800,$3018,$3418,$3018,$1800
.PunchYDisp	dw $2020,$1E1E,$1D1D,$1E1E,$2020
.PunchWidth	dw $1010,$2020,$2424,$2020,$1010
.PunchHeight	dW $1010,$1010,$1212,$1010,$1010


AND_table:	db $01,$02,$04,$08,$10,$20,$40,$80

SpriteModules:
; 0 = not attackable
; 1 = attackable

;		    76543210  FEDCBA98  76543210  FEDCBA98

.Vanilla	db %11111111,%10101111,%01111011,%11010101	; sprites 00-1F
		db %00111100,%01000100,%00000111,%10111100	; sprites 20-3F
		db %11011111,%11111001,%00000011,%00000000	; sprites 40-5F
		db %00000000,%11000001,%00001111,%00000000	; sprites 60-7F
		db %01000000,%00000000,%10111110,%10101111	; sprites 80-9F
		db %00000110,%00000000,%01100000,%11101101	; sprites A0-BF
		db %00001100,%00000000,%00000000,%10111100	; sprites C0-DF
		db %00000000,%00000000,%00000000,%00000000	; sprites E0-FF
.Custom		db %00110000,%00000000,%00000000,%00000000	; custom sprites 00-1F
		db %00000000,%00000000,%00000000,%00000000	; custom sprites 20-3F
		db %00000000,%00000000,%00000000,%00000000	; custom sprites 40-5F
		db %00000000,%00000000,%00000000,%00000000	; custom sprites 60-7F
		db %00000000,%00000000,%00000000,%00000000	; custom sprites 80-9F
		db %00000000,%10111000,%00000000,%00000000	; custom sprites A0-BF
		db %00000000,%00000000,%00000000,%00000000	; custom sprites C0-DF
		db %00000000,%00000000,%00000000,%00000000	; custom sprites E0-FF

;=================;
;ANIMATION ROUTINE;
;=================;
ANIMATION:	LDA $C2,x
		AND #$E0
		BNE .Process
		JMP .Graphics
.Process	LDY $1602,x
		LDA.w GRAPHICS_MarioAnimation,y
		STA $13E0
		LDA $16
		AND #$40
		BEQ .NoPunch
		LDA $1602,x
		BNE .NoPunch
		LDA #$02
		TAY
		STA $1602,x
		LDA.w GRAPHICS_UpperTimer,y
		STA $163E,x
.NoPunch	LDA $163E,x
		BNE .HandleLegs
		LDY $1602,x
		LDA.w GRAPHICS_UpperSequence,y
		STA $1602,x
		TAY
		LDA.w GRAPHICS_UpperTimer,y
		STA $163E,x
.HandleLegs	LDA $18
		LDA $1588,x
		AND #$04
		BNE .Ground
		LDA #$14
		LDY $1602,x
		BNE .NoBoost
		LDY $1540,x
		CPY #$10
		BCS .Boost
.NoBoost	INC #2
.Boost		STA $1570,x
		STA $15AC,x
		BRA .Graphics
.Ground		LDA $18
		BPL +
		LDA #$18
		STA $1570,x
		LDA #$05
		STA $15AC,x
		BRA .Graphics
	+	LDA $15AC,x
		BNE .Graphics
		LDY $1570,x
		LDA.w GRAPHICS_LowerSequence,y
		STA $1570,x
		TAY
		LDA.w GRAPHICS_LowerTimer,y
		STA $15AC,x
		CPY #$06
		BNE +
		LDA #$01
		STA $1DF9
		BRA .Graphics
	+	CPY #$0E
		BNE .Graphics
		LDA #$01
		STA $1DF9
.Graphics	JSR GRAPHICS
		PLB
		RTL

;================;
;GRAPHICS ROUTINE;
;================;
; Scratch RAM:
; 00+01: Coords for legs
; 02-09: Tile size table pointers
; 0A-0D: Tile size table lengths
; 0E+0F: Coords for torso
;
; Tilesize is uploaded lo -> hi
;
; Scratch RAM:
; 00+01: Coords for legs
; 02-09: Tilemap pointers
; 0A-0D: Tilemap lengths
; 0E+0F: Coords for torso
;
; Tilemap is uploaded hi -> lo
;
GRAPHICS:	JSR GET_DRAW_INFO
		LDA $C2,x
		AND #$E0
		ORA $1594,x
		STA $0C
		PHX					; Stack: [sprite index]
		LDA $157C,x : EOR #$FE			;\ Stack: [Hdir1],[sprite index]
		INC A : PHA				;/
		LDA $157C,x : EOR #$01			;\ Stack: [Hdir2],[Hdir1],[sprite index]
		CLC : ROR #3 : PHA			;/
		LDA $15EA,x				;\ Store OAM index
		STA $02					;/
		LDA $1570,x				;\ Stack: [legs index],[Hdir2],[Hdir],[sprite index]
		PHA					;/
		TAX					; X = legs index
		LDA.w .LegsSizePtr,x : STA $04		;\
		LDA.w .LegsSizePtr+$01,x : STA $05	; | Set up legs size pointer
		LDA.w .LegsSizeSize,x : STA $0B		;/
		LDA $02					;\ X = OAM index
		LSR #2 : TAX				;/
		LDA.w .TorsoSizePtr,y : STA $02		;\
		LDA.w .TorsoSizePtr+$01,y : STA $03	; |
		LDA.w .TorsoSizeSize,y : STA $0A	; |
		LDA $0C	: BNE +				; |
		STZ $0C : BRA ++			; |
	+	LDA.w .PilotSizePtr,y : STA $06		; |
		LDA.w .PilotSizePtr+$01,y : STA $07	; | Set up torso size pointers
		LDA.w .PilotSizeSize,y : STA $0C	; |
	++	LDA.w .Arm2SizePtr,y : STA $08		; |
		LDA.w .Arm2SizePtr+$01,y : STA $09	; |
		LDA.w .Arm2SizeSize,y : STA $0D		;/
		PHY					; Stack: [torso index],[legs index],[Hdir2],[Hdir1],[sprite index]
		LDY #$00				;\
		CPY $0A					; |
		BEQ +					; |
	-	LDA ($02),y				; | Upload torso tile size
		STA !OAMhi,x				; |
		INX : INY				; |
		CPY $0A					; |
		BNE -					;/
	+	LDY #$00				;\
		CPY $0B					; |
		BEQ +					; |
	-	LDA ($04),y				; | Upload legs tile size
		STA !OAMhi,x				; |
		INX : INY				; |
		CPY $0B					; |
		BNE -					;/
	+	LDY #$00				;\
		CPY $0C					; |
		BEQ +					; |
	-	LDA ($06),y				; | Upload pilot tile size
		STA !OAMhi,x				; |
		INX : INY				; |
		CPY $0C					; |
		BNE -					;/
	+	LDY #$00				;\
		CPY $0D					; |
		BEQ +					; |
	-	LDA ($08),y				; | Upload arm 2 tile size
		STA !OAMhi,x				; |
		INX : INY				; |
		CPY $0D					; |
		BNE -					;/
	+	PLY					; Stack: [legs index],[Hdir2],[Hdir1],[sprite index]
		LDA.w .TorsoPtr,y : STA $02		;\
		LDA.w .TorsoPtr+$01,y : STA $03		; |
		LDA.w .TorsoTileCount,y : STA $0A	; |
		LDA $0C : BEQ +				; |
		LDA.w .PilotPtr,y : STA $06		; |
		LDA.w .PilotPtr+$01,y : STA $07		; | Set up torso pointers
		LDA.w .PilotTileCount,y : STA $0C	; |
	+	LDA.w .Arm2Ptr,y : STA $08		; |
		LDA.w .Arm2Ptr+$01,y : STA $09		; |
		LDA.w .Arm2TileCount,y : STA $0D	;/
		PLY					; > Stack: [Hdir2],[Hdir1],[sprite index]
		LDA.w .LegsPtr,y : STA $04		;\
		LDA.w .LegsPtr+$01,y : STA $05		; | Set up legs pointer
		LDA.w .LegsTileCount,y : STA $0B	;/
		TXA
		DEC A
		ASL #2
		TAX

.DrawArm2	LDY $0D
		BEQ .DrawPilot
.Arm2Loop	LDA ($08),y
		EOR $01,s
		STA !OAM+3,x
		DEY
		LDA ($08),y
		STA !OAM+2,x
		DEY
		LDA ($08),y
		CLC : ADC $0F
		STA !OAM+1,x
		DEY
		LDA $01,s : BEQ ++ : PHX : TXA : LSR #2 : TAX : LDA !OAMhi,x : BNE + : LDA #$00 : PLX : BRA ++ : + : LDA #$08 : PLX : ++
		CLC : ADC ($08),y
		EOR $02,s
		BPL .PosArm2
		EOR #$FF
		PHA
		LDA $0E
		SEC : SBC $01,s
		STA !OAM,x
		PLA
		BCS + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .Arm2Loop
		BRA .DrawPilot
.PosArm2	CLC : ADC $0E
		STA !OAM,x
		BCC + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .Arm2Loop
.DrawPilot	LDY $0C
		BEQ .DrawLegs
.PilotLoop	LDA ($06),y
		EOR $01,s
		STA !OAM+3,x
		DEY
		LDA ($06),y
		STA !OAM+2,x
		DEY
		LDA ($06),y
		CLC : ADC $0F
		STA !OAM+1,x
		DEY
		LDA $01,s : BEQ ++ : PHX : TXA : LSR #2 : TAX : LDA !OAMhi,x : BNE + : LDA #$00 : PLX : BRA ++ : + : LDA #$08 : PLX : ++
		CLC : ADC ($06),y
		EOR $02,s
		BPL .PosPilot
		EOR #$FF
		PHA
		LDA $0E
		SEC : SBC $01,s
		STA !OAM,x
		PLA
		BCS + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .PilotLoop
		BRA .DrawLegs
.PosPilot	CLC : ADC $0E
		STA !OAM,x
		BCC + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .PilotLoop
.DrawLegs	LDY $0B
		BEQ .DrawTorso
.LegsLoop	LDA ($04),y
		EOR $01,s
		STA !OAM+3,x
		DEY
		LDA ($04),y
		STA !OAM+2,x
		DEY
		LDA ($04),y
		CLC : ADC $01
		STA !OAM+1,x
		DEY
		LDA $01,s : BEQ ++ : PHX : TXA : LSR #2 : TAX : LDA !OAMhi,x : BNE + : LDA #$00 : PLX : BRA ++ : + : LDA #$08 : PLX : ++
		CLC : ADC ($04),y
		EOR $02,s
		BPL .PosLegs
		EOR #$FF
		PHA
		LDA $00
		SEC : SBC $01,s
		STA !OAM,x
		PLA
		BCS + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .LegsLoop
		BRA .DrawTorso
.PosLegs	CLC : ADC $00
		STA !OAM,x
		BCC + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .LegsLoop
.DrawTorso	LDY $0A
		BEQ .Return
.TorsoLoop	LDA ($02),y
		EOR $01,s
		STA !OAM+3,x
		DEY
		LDA ($02),y
		STA !OAM+2,x
		DEY
		LDA ($02),y
		CLC : ADC $0F
		STA !OAM+1,x
		DEY
		LDA $01,s : BEQ ++ : PHX : TXA : LSR #2 : TAX : LDA !OAMhi,x : BNE + : LDA #$00 : PLX : BRA ++ : + : LDA #$08 : PLX : ++
		CLC : ADC ($02),y
		EOR $02,s
		BPL .PosTorso
		EOR #$FF
		PHA
		LDA $0E
		SEC : SBC $01,s
		STA !OAM,x
		PLA
		BCS + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .TorsoLoop
		BRA .Return
.PosTorso	CLC : ADC $0E
		STA !OAM,x
		BCC + : PHX : TXA : LSR #2 : TAX : INC !OAMhi,x : PLX : +
		DEY
		DEX #4
		CPY #$FF
		BNE .TorsoLoop

.Return		PLA : PLA				; Stack: [sprite index]
		PLX					; Restore sprite index
		RTS					; Return

;=====================;
;EXTENDED TILEMAP DATA;
;=====================;
.UpperXDisp	dw $0000,$0000,$0000,$0000		; Indexed by $1570, odd bytes are for facing left
		dw $0000,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000
		dw $FE02,$FD03,$FC04,$FD03
		dw $FE02,$0000,$0000,$0000
		dw $0000,$0000,$0000,$0000
		dw $0000,$0000
.UpperYDisp	dw $D1D1,$CDCD,$CECE,$CFCF		; Indexed by $1570, odd bytes should mirror even bytes
		dw $CDCD,$CCCC,$CDCD,$D0D0
		dw $CDCD,$CCCC,$D1D1,$D1D1
		dw $D2D2,$D3D3,$D4D4,$D3D3
		dw $D2D2,$D2D2,$D3D3,$D4D4
		dw $D3D3,$D2D2,$D9D9,$D6D6
		dw $D4D4,$D2D2

.LowerXDisp	dw $0000,$0000,$0000,$0000		; Indexed by $1602, odd bytes are for facing left
		dw $0000,$0000,$0000,$0000

.LowerYDisp	dw $D1D1,$CDCD,$CECE,$CFCF		; Indexed by $1570, odd bytes should mirror even bytes
		dw $CDCD,$CCCC,$CDCD,$D0D0
		dw $CDCD,$CCCC,$D1D1,$D1D1
		dw $D1D1,$D1D1,$D1D1,$D1D1
		dw $D1D1,$D1D1,$D1D1,$D1D1
		dw $D1D1,$D1D1,$D1D1,$D1D1
		dw $D1D1,$D1D1

.UpperTimer	dw $0000,$0004,$0004,$0001		; Indexed by $1602
		dw $0002,$000A
.UpperSequence	dw $0000,$0004,$0006,$0008
		dw $000A,$0000

.LowerTimer	dw $0000,$0007,$0007,$0007		; Indexed by $1570
		dw $0007,$0007,$0007,$0007
		dw $0007,$0007,$0000,$0000
		dw $0007,$0007,$002F,$0007
		dw $0007,$0005,$0005,$0005
		dw $0005,$0005,$0000,$0000
		dw $0000,$0000
.LowerSequence	dw $0000,$0004,$0006,$0008
		dw $000A,$000C,$000E,$0010
		dw $0012,$0004,$0014,$0016
		dw $001A,$001C,$001E,$0020
		dw $0000,$0024,$0026,$0028
		dw $002A,$0000,$0000,$0000
		dw $0000,$0000

.MarioAnimation	dw $0021,$0032,$0028,$0028
		dw $0028,$0032

;==================;
;TORSO TILEMAP DATA;
;==================;
.TorsoPtr	dw .TorsoIdle				; 0x00, idle
		dw .TorsoHit0				; 0x02 \ punch coming out
		dw .TorsoHit1				; 0x04 /
		dw .TorsoHit2				; 0x06 > punch impact
		dw .TorsoHit1				; 0x08 \ retracting arm after punch
		dw .TorsoHit0				; 0x0A /
.TorsoTileCount	dw $0033,$003F
		dw $0033,$0037
		dw $0033,$003F

.TorsoIdle	db $08,$21,$AC,$2D			;\
		db $00,$21,$AB,$2D			; | Arm 1 16x16
		db $06,$11,$AE,$2D			;/
		db $16,$19,$91,$2D			;\ Arm 1 8x8
		db $08,$31,$90,$2D			;/
		db $00,$08,$86,$2C			;\
		db $E7,$11,$E0,$2C			; |
		db $EF,$11,$E1,$2C			; | Chest plate 16x16
		db $FF,$09,$CC,$2D			; |
		db $FF,$11,$B0,$2D			; |
		db $EF,$09,$CA,$2D			;/
		db $E7,$09,$A6,$2D			;\ Chest plate 8x8
		db $E6,$15,$81,$2D			;/
.TorsoHit0	db $F3,$1A,$A4,$2D			;\
		db $E3,$19,$A2,$2D			; | Arm 1 16x16
		db $F2,$12,$CE,$2D			; |
		db $F5,$08,$84,$2C			;/
		db $E3,$29,$B6,$2D			;\ Arm 1 8x8
		db $EB,$29,$B7,$2D			;/
		db $E4,$09,$A6,$2D			;\
		db $E4,$11,$A4,$2C			; |
		db $EC,$11,$A5,$2C			; | Chest plate 8x8
		db $E4,$19,$A6,$2C			; |
		db $09,$12,$C7,$2C			; |
		db $09,$1A,$D6,$2C			;/
		db $EC,$09,$CA,$2D			;\
		db $FC,$09,$CC,$2D			; | Chest plate 16x16
		db $EC,$11,$C0,$2D			; |
		db $FC,$11,$B0,$2D			;/
.TorsoHit1	db $D7,$18,$A4,$2D			;\
		db $C7,$17,$A2,$2D			; | Arm 1 16x16
		db $DE,$0F,$A0,$2D			; |
		db $E2,$08,$86,$6C			;/
		db $C7,$27,$B6,$2D			;\ Arm 1 8x8
		db $CF,$27,$B7,$2D			;/
		db $0A,$12,$A3,$2C			;\
		db $0A,$1A,$C6,$2C			; | Chest plate 8x8
		db $E4,$19,$E2,$2D			;/
		db $FA,$12,$EC,$2D			;\
		db $EC,$09,$CA,$2D			; | Chest plate 16x16
		db $FC,$09,$CC,$2D			; |
		db $EC,$11,$C0,$2D			;/
.TorsoHit2	db $D1,$18,$A4,$2D			;\
		db $C1,$17,$A2,$2D			; |
		db $D6,$18,$A4,$2D			; | Arm 1 16x16
		db $DE,$0F,$A0,$2D			; |
		db $E2,$08,$86,$6C			;/
		db $C1,$27,$B6,$2D			;\ Arm 2 8x8
		db $C9,$27,$B7,$2D			;/
		db $0A,$12,$A3,$2C			;\
		db $0A,$1A,$C6,$2C			; | Chest plate 8x8
		db $E4,$19,$E2,$2D			;/
		db $FA,$12,$EC,$2D			;\
		db $EC,$09,$CA,$2D			; | Chest plate 16x16
		db $FC,$09,$CC,$2D			; |
		db $EC,$11,$C0,$2D			;/

.TorsoSizePtr	dw .TorsoSizeIdle
		dw .TorsoSizeHit0
		dw .TorsoSizeHit1
		dw .TorsoSizeHit2
		dw .TorsoSizeHit1
		dw .TorsoSizeHit0
.TorsoSizeSize	dw $000D,$0010
		dw $000D,$000E
		dw $000D,$0010

.TorsoSizeIdle	db $02,$02,$02				;\ Arm 1
		db $00,$00				;/
		db $02,$02,$02,$02,$02,$02		;\ Chest plate
		db $00,$00				;/
.TorsoSizeHit0	db $02,$02,$02,$02			;\ Arm 1
		db $00,$00				;/
		db $00,$00,$00,$00,$00,$00		;\ Chest plate
		db $02,$02,$02,$02			;/
.TorsoSizeHit1	db $02,$02,$02,$02			;\ Arm 1
		db $00,$00				;/
		db $00,$00,$00				;\ Chest plate
		db $02,$02,$02,$02			;/
.TorsoSizeHit2	db $02,$02,$02,$02,$02			;\ Arm 1
		db $00,$00				;/
		db $00,$00,$00				;\ Chest plate
		db $02,$02,$02,$02			;/

;==================;
;PILOT TILEMAP DATA;
;==================;
.PilotPtr	dw .PilotMario0				; 0x00, idle
		dw .PilotMario0				; 0x02
		dw .PilotMario1				; 0x04
		dw .PilotMario1				; 0x06
		dw .PilotMario1				; 0x08
		dw .PilotMario0				; 0x0A
.PilotTileCount	dw $0007,$0007
		dw $000B,$000B
		dw $000B,$0007

.PilotRex	db $F6,$0C,$20,$27			;\ Pilot 16x16
		db $F2,$FC,$0A,$27			;/

.PilotMario0	db $F4,$08,$02,$20
		db $F4,$F8,$00,$20
.PilotMario1	db $F4,$08,$02,$20
		db $F4,$F8,$00,$20
		db $EC,$08,$7E,$20

.PilotSizePtr	dw .PilotSizeIdle0
		dw .PilotSizeIdle0
		dw .PilotSizeIdle1
		dw .PilotSizeIdle1
		dw .PilotSizeIdle1
		dw .PilotSizeIdle0
.PilotSizeSize	dw $0002,$0002
		dw $0003,$0003
		dw $0003,$0002

.PilotSizeIdle0	db $02,$02				; > Pilot
.PilotSizeIdle1 db $02,$02,$00
;==================;
;ARM 2 TILEMAP DATA;
;==================;
.Arm2Ptr	dw .Arm2Idle				; 0x00, idle
		dw $0000				; 0x02 \ punch coming out
		dw .Arm2Hit				; 0x04 /
		dw .Arm2Hit				; 0x06 > punch impact
		dw .Arm2Hit				; 0x08 \ retracting arm after punch
		dw $0000				; 0x0A /
.Arm2TileCount	dw $0013,$0000
		dw $0017,$0017
		dw $0017,$0000

.Arm2Idle	db $E5,$08,$B4,$2C			;\ Arm 2 16x16
		db $E1,$23,$A8,$2D			;/
		db $E5,$1B,$BA,$2D			;\
		db $ED,$1B,$E3,$2D			; | Arm 2 8x8
		db $F1,$23,$AA,$2D			;/
.Arm2Hit	db $FF,$08,$B4,$6C			; > Arm 2 16x16
		db $0C,$10,$E9,$2D			;\
		db $0D,$18,$E8,$2D			; |
		db $0D,$20,$E6,$2D			; | Arm 2 8x8
		db $05,$20,$E5,$2D			; |
		db $05,$18,$E7,$2D			;/

.Arm2SizePtr	dw .Arm2SizeIdle
		dw $0000
		dw .Arm2SizeHit
		dw .Arm2SizeHit
		dw .Arm2SizeHit
		dw $0000
.Arm2SizeSize	dw $0005,$0000
		dw $0006,$0006
		dw $0006,$0000

.Arm2SizeIdle	db $02,$02
		dw $00,$00,$00
.Arm2SizeHit	db $02
		db $00,$00,$00,$00,$00

;=================;
;LEGS TILEMAP DATA;
;=================;
.LegsPtr	dw .LegsIdle				; 0x00, idle
		dw .LegsWalk0				; 0x02, walk startup
		dw .LegsWalk1				; 0x04 \
		dw .LegsWalk2				; 0x06  |
		dw .LegsWalk3				; 0x08  | walk cycle
		dw .LegsWalk4				; 0x0A  |
		dw .LegsWalk5				; 0x0C  |
		dw .LegsWalk6				; 0x0E  |
		dw .LegsWalk7				; 0x10  |
		dw .LegsWalk8				; 0x12 /
		dw .LegsBoost				; 0x14, boost
		dw .LegsMidair				; 0x16, midair
		dw .LegsDash0				; 0x18 \ dash startup
		dw .LegsDash1				; 0x1A /
		dw .LegsDash2				; 0x1C, dashing
		dw .LegsDash1				; 0x1E \ dash ending
		dw .LegsDash0				; 0x20 /
		dw .LegsLand0				; 0x22 \ on the way down
		dw .LegsLand1				; 0x24 /
		dw .LegsLand2				; 0x26, peak of landing animation
		dw .LegsLand1				; 0x28 \ on the way up
		dw .LegsLand0				; 0x2A /
		dw .LegsInactive			; 0x2C, inactive
		dw .LegsStartup0			; 0x2E \
		dw .LegsStartup1			; 0x30  | standing up
		dw .LegsStartup2			; 0x32 /
.LegsTileCount	dw $0037,$0037				; 0x00-02
		dw $0037,$0037				; 0x04-06
		dw $0037,$0037				; 0x08-0A
		dw $0037,$0037				; 0x0C-0E
		dw $0037,$0037				; 0x10-12
		dw $0033,$002F				; 0x14-16
		dw $0037,$0037				; 0x18-1A
		dw $0037,$0037				; 0x1C-1E
		dw $0037,$0037				; 0x20-22
		dw $0037,$0037				; 0x24-26
		dw $0037,$0037				; 0x28-2A
		dw $0037,$0037				; 0x2C-2E
		dw $0037,$0037				; 0x30-32

.LegsIdle	db $FD,$20,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $EF,$20,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsWalk0	db $FD,$1E,$8E,$2D			;\ Front leg 16x16
		db $FD,$25,$8C,$2D			;/
		db $F4,$35,$9B,$2D			;\
		db $FC,$35,$8A,$2D			; | Front leg 8x8
		db $04,$35,$8B,$2D			; |
		db $F5,$2D,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F5,$24,$88,$2D			;\ Back leg 16x16
		db $F5,$2C,$86,$2D			;/
		db $EC,$3B,$95,$2D			;\
		db $F4,$3B,$84,$2D			; | Back leg 8x8
		db $FC,$3B,$85,$2D			; |
		db $ED,$33,$94,$2D			;/
.LegsWalk1	db $FB,$1E,$8E,$2D			;\ Front leg 16x16
		db $FB,$26,$8C,$2D			;/
		db $F2,$36,$9B,$2D			;\
		db $FA,$36,$8A,$2D			; | Front leg 8x8
		db $02,$36,$8B,$2D			; |
		db $F3,$2E,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F8,$24,$88,$2D			;\ Back leg 16x16
		db $F8,$2B,$86,$2D			;/
		db $EF,$3A,$95,$2D			;\
		db $F7,$3A,$84,$2D			; | Back leg 8x8
		db $FF,$3A,$85,$2D			; |
		db $00,$32,$94,$2D			;/
.LegsWalk2	db $FB,$21,$8E,$2D			;\ Front leg 16x16
		db $FB,$29,$8C,$2D			;/
		db $F2,$39,$9B,$2D			;\
		db $FA,$39,$8A,$2D			; | Front leg 8x8
		db $02,$39,$8B,$2D			; |
		db $F3,$31,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $FA,$23,$88,$2D			;\ Back leg 16x16
		db $FA,$2A,$86,$2D			;/
		db $F1,$39,$95,$2D			;\
		db $F9,$39,$84,$2D			; | Back leg 8x8
		db $01,$39,$85,$2D			; |
		db $F2,$31,$94,$2D			;/
.LegsWalk3	db $FB,$23,$8E,$2D			;\ Front leg 16x16
		db $FB,$2B,$8C,$2D			;/
		db $F2,$3B,$9B,$2D			;\
		db $FA,$3B,$8A,$2D			; | Front leg 8x8
		db $02,$3B,$8B,$2D			; |
		db $F3,$33,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F7,$21,$88,$2D			;\ Back leg 16x16
		db $F7,$28,$86,$2D			;/
		db $EE,$37,$95,$2D			;\
		db $F6,$37,$84,$2D			; | Back leg 8x8
		db $FC,$37,$85,$2D			; |
		db $EF,$2F,$94,$2D			;/
.LegsWalk4	db $FE,$24,$8E,$2D			;\ Front leg 16x16
		db $FE,$2C,$8C,$2D			;/
		db $F5,$3C,$9B,$2D			;\
		db $FD,$3C,$8A,$2D			; | Front leg 8x8
		db $05,$3C,$8B,$2D			; |
		db $F6,$34,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F4,$20,$88,$2D			;\ Back leg 16x16
		db $F4,$27,$86,$2D			;/
		db $EB,$36,$95,$2D			;\
		db $F3,$36,$84,$2D			; | Back leg 8x8
		db $FB,$36,$85,$2D			; |
		db $EC,$2E,$94,$2D			;/
.LegsWalk5	db $FF,$23,$8E,$2D			;\ Front leg 16x16
		db $FF,$2B,$8C,$2D			;/
		db $F6,$3B,$9B,$2D			;\
		db $FE,$3B,$8A,$2D			; | Front leg 8x8
		db $06,$3B,$8B,$2D			; |
		db $F7,$33,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F0,$21,$88,$2D			;\ Back leg 16x16
		db $F0,$28,$86,$2D			;/
		db $E7,$37,$95,$2D			;\
		db $EF,$37,$84,$2D			; | Back leg 8x8
		db $F7,$37,$85,$2D			; |
		db $E8,$2F,$94,$2D			;/
.LegsWalk6	db $02,$1F,$8E,$2D			;\ Front leg 16x16
		db $02,$26,$8C,$2D			;/
		db $F9,$36,$9B,$2D			;\
		db $01,$36,$8A,$2D			; | Front leg 8x8
		db $09,$36,$8B,$2D			; |
		db $FA,$2E,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $EF,$21,$88,$2D			;\ Back leg 16x16
		db $EF,$28,$86,$2D			;/
		db $E6,$38,$95,$2D			;\
		db $EE,$38,$84,$2D			; | Back leg 8x8
		db $F6,$38,$85,$2D			; |
		db $E7,$30,$94,$2D			;/
.LegsWalk7	db $FF,$1F,$8E,$2D			;\ Front leg 16x16
		db $FF,$26,$8C,$2D			;/
		db $F6,$36,$9B,$2D			;\
		db $FE,$36,$8A,$2D			; | Front leg 8x8
		db $06,$36,$8B,$2D			; |
		db $F7,$2E,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F3,$23,$88,$2D			;\ Back leg 16x16
		db $F3,$2B,$86,$2D			;/
		db $EA,$3B,$95,$2D			;\
		db $F2,$3B,$84,$2D			; | Back leg 8x8
		db $FA,$3B,$85,$2D			; |
		db $EB,$33,$94,$2D			;/
.LegsWalk8	db $FE,$1E,$8E,$2D			;\ Front leg 16x16
		db $FE,$26,$8C,$2D			;/
		db $F5,$36,$9B,$2D			;\
		db $FD,$36,$8A,$2D			; | Front leg 8x8
		db $05,$36,$8B,$2D			; |
		db $F5,$2E,$9A,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $F5,$24,$88,$2D			;\ Back leg 16x16
		db $F5,$2C,$86,$2D			;/
		db $ED,$3C,$95,$2D			;\
		db $F5,$3C,$84,$2D			; | Back leg 8x8
		db $FD,$3C,$85,$2D			; |
		db $ED,$34,$94,$2D			;/
.LegsBoost	db $FC,$33,$D7,$2D			;\ Front leg 8x8
		db $09,$3B,$C6,$2D			;/
		db $FE,$23,$8E,$2D			;\
		db $F9,$3B,$C4,$2D			; | Front leg 16x16
		db $FC,$2B,$8C,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $0D,$21,$EE,$2D			; > Boost Flame
		db $EC,$33,$C7,$2D			;\ Back leg 8x8
		db $F4,$33,$D6,$2D			;/
		db $F0,$23,$88,$2D			;\
		db $E9,$3B,$C2,$2D			; | Back leg 16x16
		db $F0,$2B,$86,$2D			;/
.LegsMidair	db $FC,$33,$D7,$2D			;\ Front leg 8x8
		db $09,$3B,$C6,$2D			;/
		db $FE,$23,$8E,$2D			;\
		db $F9,$3B,$C4,$2D			; | Front leg 16x16
		db $FC,$2B,$8C,$2D			;/
		db $F5,$21,$C8,$2D			; > Crotch 16x16
		db $ED,$21,$E0,$2D			; > Crotch 8x8
		db $EC,$33,$C7,$2D			;\ Back leg 8x8
		db $F4,$33,$D6,$2D			;/
		db $F0,$23,$88,$2D			;\
		db $E9,$3B,$C2,$2D			; | Back leg 16x16
		db $F0,$2B,$86,$2D			;/
.LegsDash0	db $FD,$20,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F4,$22,$C8,$2D			; > Crotch 16x16
		db $EC,$22,$E0,$2D			; > Crotch 8x8
		db $EE,$20,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsDash1	db $FD,$20,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F4,$23,$C8,$2D			; > Crotch 16x16
		db $EC,$23,$E0,$2D			; > Crotch 8x8
		db $EE,$20,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsDash2	db $FD,$21,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F4,$24,$C8,$2D			; > Crotch 16x16
		db $EC,$24,$E0,$2D			; > Crotch 8x8
		db $EE,$21,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsLand0	db $FD,$20,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$22,$C8,$2D			; > Crotch 16x16
		db $ED,$22,$E0,$2D			; > Crotch 8x8
		db $EF,$20,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsLand1	db $FD,$21,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$23,$C8,$2D			; > Crotch 16x16
		db $ED,$23,$E0,$2D			; > Crotch 8x8
		db $EF,$21,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsLand2	db $FD,$21,$8E,$2D			;\ Front leg 16x16
		db $FD,$27,$8C,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$24,$C8,$2D			; > Crotch 16x16
		db $ED,$24,$E0,$2D			; > Crotch 8x8
		db $EF,$21,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsInactive	db $FD,$27,$8C,$2D			;\ Front leg 16x16
		db $FD,$26,$8E,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$29,$C8,$2D			; > Crotch 16x16
		db $ED,$29,$E0,$2D			; > Crotch 8x8
		db $EF,$26,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsStartup0	db $FD,$27,$8C,$2D			;\ Front leg 16x16
		db $FD,$24,$8E,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$26,$C8,$2D			; > Crotch 16x16
		db $ED,$26,$E0,$2D			; > Crotch 8x8
		db $EF,$24,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsStartup1	db $FD,$27,$8C,$2D			;\ Front leg 16x16
		db $FD,$23,$8E,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$24,$C8,$2D			; > Crotch 16x16
		db $ED,$24,$E0,$2D			; > Crotch 8x8
		db $EF,$23,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/
.LegsStartup2	db $FD,$27,$8C,$2D			;\ Front leg 16x16
		db $FD,$22,$8E,$2D			;/
		db $F4,$37,$9B,$2D			;\
		db $FC,$37,$8A,$2D			; | Front leg 8x8
		db $04,$37,$8B,$2D			; |
		db $F5,$2F,$9A,$2D			;/
		db $F5,$22,$C8,$2D			; > Crotch 16x16
		db $ED,$22,$E0,$2D			; > Crotch 8x8
		db $EF,$22,$88,$2D			;\ Back leg 16x16
		db $EF,$27,$86,$2D			;/
		db $E6,$37,$95,$2D			;\
		db $EE,$37,$84,$2D			; | Back leg 8x8
		db $F6,$37,$85,$2D			; |
		db $E7,$2F,$94,$2D			;/


.LegsSizePtr	dw .LegsSizeIdle			; 0x00, idle
		dw .LegsSizeIdle			; 0x02, walk startup
		dw .LegsSizeIdle			; 0x04 \
		dw .LegsSizeIdle			; 0x06  |
		dw .LegsSizeIdle			; 0x08  |
		dw .LegsSizeIdle			; 0x0A  | walk cycle
		dw .LegsSizeIdle			; 0x0C  |
		dw .LegsSizeIdle			; 0x0E  |
		dw .LegsSizeIdle			; 0x10  |
		dw .LegsSizeIdle			; 0x12 /
		dw .LegsSizeBoost			; 0x14, boost
		dw .LegsSizeMidair			; 0x16, midair
		dw .LegsSizeIdle			; 0x18 \ dash startup
		dw .LegsSizeIdle			; 0x1A /
		dw .LegsSizeIdle			; 0x1C, dashing
		dw .LegsSizeIdle			; 0x1E \ dash ending
		dw .LegsSizeIdle			; 0x20 /
		dw .LegsSizeIdle			; 0x22 \ on the way down
		dw .LegsSizeIdle			; 0x24 /
		dw .LegsSizeIdle			; 0x26, peak of landing animation
		dw .LegsSizeIdle			; 0x28 \ on the way up
		dw .LegsSizeIdle			; 0x2A /
		dw .LegsSizeIdle			; 0x2C, inactive
		dw .LegsSizeIdle			; 0x2E \
		dw .LegsSizeIdle			; 0x30  | standing up
		dw .LegsSizeIdle			; 0x32 /
.LegsSizeSize	dw $000E,$000E				; 0x00-02
		dw $000E,$000E				; 0x04-06
		dw $000E,$000E				; 0x08-0A
		dw $000E,$000E				; 0x0C-0E
		dw $000E,$000E				; 0x10-12
		dw $000D,$000C				; 0x14-16
		dw $000E,$000E				; 0x18-1A
		dw $000E,$000E				; 0x1C-1E
		dw $000E,$000E				; 0x20-22
		dw $000E,$000E				; 0x24-26
		dw $000E,$000E				; 0x28-2A
		dw $000E,$000E				; 0x2C-2E
		dw $000E,$000E				; 0x30-32

.LegsSizeIdle	db $02,$02				;\ Front leg
		db $00,$00,$00,$00			;/
		db $02					;\ Crotch
		db $00					;/
		db $02,$02				;\ Back leg
		db $00,$00,$00,$00			;/
.LegsSizeBoost	db $00,$00				;\ Front leg
		db $02,$02,$02				;/
		db $02					;\ Crotch
		db $00					;/
		db $02					; > Boost flame
		db $00,$00				;\ Back leg
		db $02,$02,$02				;/
.LegsSizeMidair	db $00,$00				;\ Front leg
		db $02,$02,$02				;/
		db $02					;\ Crotch
		db $00					;/
		db $00,$00				;\ Back leg
		db $02,$02,$02				;/

;=============;
;HELP ROUTINES;
;=============;
GET_DRAW_INFO:	STZ $186C,x
		STZ $15A0,x
		LDA $E4,x
		CMP $1A
		LDA $14E0,x
		SBC $1B
		BEQ ON_SCREEN_X
		INC $15A0,x

ON_SCREEN_X:	LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC
		SBC $1A

	;	CLC : ADC #$0040
	;	CMP #$0180

	CLC : ADC #$0000
	CMP #$0100

		SEP #$20
		ROL A
		AND #$01
		STA $15C4,x
		BNE INVALID
		LDY #$00
		LDA $1662,x
		AND #$20
		BEQ ON_SCREEN_LOOP
		INY

ON_SCREEN_LOOP:	LDA $D8,x
		CLC
		ADC SPR_T1,y
		PHP
		CMP $1C
		ROL $00
		PLP
		LDA $14D4,x
		ADC #$00
		LSR $00
		SBC $1D
		BEQ ON_SCREEN_Y
		LDA $186C,x
		ORA SPR_T2,y
		STA $186C,x

ON_SCREEN_Y:	DEY
		BPL ON_SCREEN_LOOP
		LDA $1570,x
		CLC : ADC $157C,x
		TAY
		LDA $E4,x
		SEC : SBC $1A
		CLC : ADC.w GRAPHICS_UpperXDisp,y
		STA $0E
		LDA $D8,x
		SEC : SBC $1C
		CLC : ADC.w GRAPHICS_UpperYDisp,y
		STA $0F
		LDA $D8,x
		SEC : SBC $1C
		CLC : ADC.w GRAPHICS_LowerYDisp,y
		STA $01
		LDA $1602,x
		CLC : ADC $157C,x
		TAY
		LDA $E4,x
		SEC : SBC $1A
		CLC : ADC.w GRAPHICS_LowerXDisp,y
		STA $00
		LDY $1602,x
		RTS

INVALID:	PLA : PLA			; Get RTS address off the stack
		RTS				; End graphics routine

SPR_T1: db $0C,$1C
SPR_T2: db $01,$02

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GET_MAP16:	LDA $05
		AND #$F0			; Check only the highest nybble
		STA $01				; Store to scratch RAM
		LDA $04				; Load sprite X pos (lo)
		LSR #4
		ORA $01
		XBA
		LDA $5B
		LSR A
		BCC .Horizontal

.Vertical	XBA				; Restore the weirdo value
		LDX $0B				; Load sprite Y pos (hi) in X
		CLC				; Clear carry
		ADC.l $00BA80,x			; Add a massive map16 table (indexed by X) to weirdo-value
		STA $00				; Store to scratch RAM
		LDA.l $00BABC,x			; Load another massive map16 table (indexed by the same X)
		ADC $0A				; Add with sprite X pos (hi)
		STA $01				; Store to scratch RAM
		LDA #$7E			; RAM bank 1
		STA $02				; Store to scratch RAM
		LDX $15E9			; Load sprite index in X
		RTS

.Horizontal	XBA				; Restore weirdo-value
		LDX $0A				; Load sprite X pos (hi)
		CLC				; Clear carry
		ADC.l $00BA60,x			; Add with massive map16 table
		STA $00				; Store to scratch RAM
		LDA.l $00BA9C,x			; Load massive map16 table
		ADC $0B				; Add with sprite Y pos (hi)
		STA $01				; Store to scratch RAM
		LDA #$7E			; RAM bank 1
		STA $02				; Store to scratch RAM
		LDX $15E9			; Load sprite index in X
		RTS