

COLLISION:

		; A = 16-bit pointer to clipping table
		STA $F0					;\
		CLC : ADC #$0008			; | collision point pointers
		STA $F3					;/

		LDA !Map16ActsLike+0 : STA $06		;\
		LDA !Map16ActsLike+1 : STA $07		; |
		LDA !Map16ActsLike40+0 : STA $09	; | 24-bit pointers to map16 acts like tables
		LDA !Map16ActsLike40+1			; |
		ORA #$0080				; |
		STA $0A					;/

		LDA #$FFFF				;\
		STA !BigRAM+0				; | default slope push coords
		STA !BigRAM+2				;/

		SEP #$30				; all regs 8-bit
		STZ !BigRAM+$20				; clear "can climb" flag
		PHB : PLA				;\
		STA $F2					; | bank bytes of collision point pointers
		STA $F5					;/
		STZ !P2Slope				; clear slope
		STZ !P2Platform				; clear platform status

		PHB : PHK : PLB				; bank wrapper start

		.DropDown
		LDA !P2DropDownTimer : BEQ ..done	; 0 = done
		BMI ..neg				; neg
		DEC A					;\
		BRA ..w					; |
	..neg	DEC A					; | decrement timer
		BMI ..w					; |
		LDA #$00				; |
	..w	STA !P2DropDownTimer			;/
		..done


		.PipeCheck				;\
		LDA !P2Pipe				; |
		ORA !P2SlantPipe			; |
		BEQ ..done				; | pipe + slant clause
		LDA #$01 : STA !P2InAir			; |
		STZ !P2Blocked				; |
		PLB					; |
		RTL					;/
		..done



		LDA $785F+1				;\
		LSR A					; |
		AND #$40 : STA $0E			; | movement flags
		LDA $78D7+1				; |
		AND #$80 : TSB $0E			;/
		STZ $0F					; collision flags = 0

		BIT $0E : BPL +				;\
		LDA #$04 : TRB !P2ExtraBlock		; | no extra block down while moving up
		+					;/

		LDA #$F0 : STA $00			;\
		LDA $5D					; | max X
		DEC A					; |
		STA $01					;/
		REP #$20				;\
		LDA !LevelHeight			; |
		SEC : SBC #$0010			; | max Y
		STA $02					; |
		SEP #$20				;/

		LDA !P2Water : PHA

		STZ !P2Water				; clear water flag
		STZ !CurrentLayer			; processing layer 1
		JSR INTERACT_LAYER			; interact with layer 1

		BIT !RAM_ScreenMode : BPL .End		;\
		REP #$20				; |
		LDA !P2XPosLo : PHA			; |
		CLC : ADC $26				; |
		STA !P2XPosLo				; |
		LDA !P2YPosLo : PHA			; |
		CLC : ADC $28				; | layer 2
		STA !P2YPosLo				; |
		SEP #$20				; |
		INC !CurrentLayer			; > processing layer 2 flag (Z)
		LDA #$80 : TSB $0F			; > processing layer 2 flag (N)
		JSR INTERACT_LAYER			; |
		REP #$20				; |
		PLA : STA !P2YPosLo			; |
		PLA : STA !P2XPosLo			; |
		SEP #$20				;/

		.End

		LDA !P2Entrance
		CMP #$20 : BCC ..noentrance
		LDA #$04 : TRB $0F
		..noentrance

; extra block:
;	1 -> 1 (right)
;	2 -> 2 (left)
;	4 -> 4 (down)
;	8 -> 8 (up)
;	10 -> 10 (crush)
;	20 -> 4 (water down)
;	40 -> 8 (water up)
;	80 -> 10 (water center)


	;	LDA !P2ExtraBlock			;\
	;	AND #$1F				; | layer collision flags
		LDA $0F					; |
		STA !P2BlockedLayer			;/
		LDA !P2ExtraBlock			;\ extra blocked bits
		AND #$1F				;/
		ORA $0F					; add blocked status from layer
		LDY !P2Platform				;\ set blocked down if platform
		BEQ $02 : ORA #$04			;/
		STA !P2Blocked				; > blocked status
		AND #$04				;\
		EOR #$04				; | set/clear air flag
		STA !P2InAir				;/
		ORA !P2Status				; (also applies when player is dead)
		BNE +					;\
		LDA !P2Platform : BNE +			; | base x speed on ground (but not on platform)
		LDA #$10 : STA !P2YSpeed		;/
	+	LDA !P2ExtraBlock			;\
		AND #$E0				; |
		LSR #3					; | apply extra water
		BEQ $02 : ORA #$40			; |
		TSB !P2Water				;/
		STZ !P2ExtraBlock			; wipe extra collision reg

		PLA : STA $04
		EOR !P2Water
		AND #$10 : BEQ .NoWaterSplash
		JSL CORE_SET_SPLASH
		LDA $04
		AND #$10 : BNE .NoWaterSplash
		LDA !P2YSpeed : BPL +
		EOR #$FF
		LSR #2
		EOR #$FF
		BRA ++
	+	LSR #2
	++	STA !P2YSpeed
		JSL CORE_SET_SPLASH_Bubble
		.NoWaterSplash

		LDA !P2Blocked				;\
		AND $6DA7				; | drop down: must be on ground and press down this frame
		AND #$04 : BEQ .NoDropDown		;/
		LDA !P2DropDownTimer : BNE +		;\
		LDA #$0F : BRA ++			; |
	+	LDA #$89				; | 15 frames to double tap, 5 frames of drop down
	++	STA !P2DropDownTimer			; |
		.NoDropDown				;/


		LDA !P2Carry : BNE .ClearClimb		; can't climb while carrying an object
		LDX !BigRAM+$20 : BEQ .ClearClimb	; check can climb flags
		LDA !P2InAir : BEQ .ClearClimb		; can't climb if touching ground
		LDA !P2Climbing : BNE +			; skip up check if already climbing
		LDA $6DA3				;\ start climbing with up if eligible
		AND #$0C : BEQ .NoClimb			;/
	+	STX !P2Climbing				;\
		LDA $6DA3				; |
		AND #$0F : TAX				; | climb speed
		LDA .ClimbSpeedX,x : STA !P2XSpeed	; |
		LDA .ClimbSpeedY,x : STA !P2YSpeed	;/
		LDX !BigRAM+$1A				;\
		CPX #$07 : BCC .NoClimb			; | check for climbable tiles with borders
		CPX #$10 : BCC .LimitClimbCoord		;/
		BRA .NoClimb				;/
		.ClearClimb				;\
		STZ !P2Climbing				; | end climb if not eligible for climbing
		.NoClimb				;/

		PLB					; bank wrapper end
		RTL					; return



		.ClimbSpeedX
		db $00,$18,$E8,$00
		db $00,$11,$EF,$00
		db $00,$11,$EF,$00
		db $00,$18,$E8,$00

		.ClimbSpeedY
		db $00,$00,$00,$00
		db $10,$0B,$0B,$10
		db $F0,$F5,$F5,$F0
		db $00,$00,$00,$00


		.LimitClimbCoord
		LDY #$07
		LDA [$F0],y
		CLC : ADC !P2XPosLo
		AND #$0F
		STA $9A
		LDA [$F3],y
		CLC : ADC !P2YPosLo
		AND #$0F
		STA $98


		..CheckX
		LDA $9A
		CMP GET_TILE_ClimbingNet_xmin-7,x : BCC ..Left
		CMP GET_TILE_ClimbingNet_xmax-7,x : BCC ..CheckY

		..Right
		LDA #$0F : TRB !P2XPosLo
		LDA [$F0],y
		AND #$0F
		SEC : SBC GET_TILE_ClimbingNet_xmax-7,x
		TSB !P2XPosLo
		BRA ..CheckY

		..Left
		LDA #$0F : TRB !P2XPosLo
		LDA [$F0],y
		AND #$0F
		CLC : ADC GET_TILE_ClimbingNet_xmin-7,x
		DEC A
		TSB !P2XPosLo
		BRA ..CheckY

		..CheckY
		LDA $98
		CMP GET_TILE_ClimbingNet_ymin-7,x : BCS ..r

		..Up
		REP #$20
		LDA GET_TILE_ClimbingNet_ymin-7,x
		AND #$00FF
		STA $00
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		STA $02
		CLC : ADC !P2YPosLo
		AND #$FFF0
		SEC : SBC $02
		CLC : ADC $00
		STA !P2YPosLo
		SEP #$20
	..r	JMP .NoClimb


; scratch RAM:
; $00 - max X coord of level
; $02 - max Y coord of level
; $04 - 16-bit map16 index
;	during block processing, $04 is the sprite to spawn from a block
;	during block processing, $05 is a multiplayer flag for spawning multiple items from blocks
; $06 - 24-bit pointer to map16 acts like table 00
; $09 - 24-bit pointer to map16 acts like table 40
; $0C - map16 acts like
; $0E - movement flags:
;	vhc-4455
;	v - 0 = moving down, 1 = moving up
;	h - 0 = moving right, 1 = moving left
;	c - 0 = not bonking sloped ceiling, 1 = bonking slopes ceiling
;	44 - what sort of slope point 4 touches (0/3 = no slope, 1 = left, 2 = right)
;	55 - what sort of slope point 5 touches (0/3 = no slope, 1 = left, 2 = right)
; $0F - collision this frame
;	01 - right
;	02 - left
;	04 - down
;	08 - up
;	10 - crushed (center)
;	20 - can climb
;	40 - touching layer 2
;	80 - processing layer 2


; other RAM:
; $7693:	conveyor type
; $7694:	temporary conveyor, used within slope processing
; $785F:	how many sub pixels the player has moved horizontally this frame
; $78D7:	how many sub pixels the player has moved vertically this frame

; !BigRAM:
; $00-$01:	Y coord player should be pushed to from interaction point 4
; $02-$03:	Y coord player should be pushed to from interaction point 5
; $04-$0F:
; $10-$1F:	map16 table ($1C-$1F unused)
; $20:		"can climb" flag


; clipping table format:
; [$F0]
; 00 - Xdisp of R, upper
; 00 - Xdisp of L, upper
; 02 - Xdisp of R, lower
; 03 - Xdisp of L, lower
; 04 - Xdisp of D, left side
; 05 - Xdisp of D, right side
; 06 - Xdisp of U
; 07 - Xdisp of C

; [$F3]
; 08 - Ydisp of R, upper
; 09 - Ydisp of L, upper
; 0A - Ydisp of R, lower
; 0B - Ydisp of L, lower
; 0C - Ydisp of D, left side
; 0D - Ydisp of D, right side
; 0E - Ydisp of U
; 0F - Ydisp of C


; order:
; - side, upper		\ bits 01 or 02
; - side, lower		/
; - bottom, left	\ bit 04
; - bottom, right	/
; - head		> bit 08
; - core		> bit 10


	INTERACT_LAYER:
		STZ $7694				; clear this for slope processing
		LDA #$80 : STA $7693			; conveyor disable flag

		LDA !WaterLevel : BEQ .NoWaterLevel
		LDA #$5F : TSB !P2Water
		.NoWaterLevel

		LDA !P2XPosLo				;\
		CLC : ADC #$08				; | position within block
		AND #$0F				; | (based on center of character)
		STA $92					;/


		; down collision
		LDA !P2Direction : BEQ +
		LDY #$04 : JSR GET_TILE			;\ left/right down points
		LDY #$05 : JSR GET_TILE			;/
		BRA ++
	+	LDY #$05 : JSR GET_TILE			;\ right/left down points
		LDY #$04 : JSR GET_TILE			;/

	++	LDA $0E
		AND #$0F : BEQ .NoSlope			;\
		CMP #$03 : BEQ .NoSlope			; | check for invalids (3 is not a real type)
		CMP #$0C : BEQ .NoSlope			; |
		CMP #$0F : BEQ .NoSlope			;/
		CMP #$02 : BEQ .ApplySlopePoint4	;\ special cases when touching a slope AND a solid block
		CMP #$04 : BEQ .ApplySlopePoint5	;/
		CMP #$06 : BEQ .CompareSlope
		CMP #$09 : BEQ .CompareSlope
		CMP #$0D : BCS .ApplySlopePoint5
		CMP #$03 : BCC .ApplySlopePoint5
		CMP #$05 : BEQ .ApplySlopePoint5
		BRA .ApplySlopePoint4
		.CompareSlope
		REP #$20
		LDA !BigRAM+0
		CMP !BigRAM+2
		SEP #$20
		BCS .ApplySlopePoint5
		.ApplySlopePoint4
		LDA !BigRAM+1 : BMI .ApplySlopePoint5	; never use a coord that hasn't been set
		STA !P2YPosHi
		LDA !BigRAM+0 : STA !P2YPosLo
		BRA .SetSlope
		.ApplySlopePoint5
		LDA !BigRAM+3 : BMI .ApplySlopePoint4	; never use a coord that hasn't been set
		STA !P2YPosHi
		LDA !BigRAM+2 : STA !P2YPosLo
		.SetSlope
		LDA #$04 : TSB $0F


; 0 - no
; 1 - 4 no, 5 left	-> point 5
; 2 - 4 no, 5 right	-> point 5
; 3 - no
; 4 - 4 left, 5 no	-> point 4
; 5 - 4 left, 5 left	-> point 5
; 6 - 4 left, 5 right	-> COMPARE
; 7 - 4 left, 5 no	-> point 4
; 8 - 4 right, 5 no	-> point 4
; 9 - 4 right, 5 left	-> COMPARE
; A - 4 right, 5 right	-> point 4
; B - 4 right, 5 no	-> point 4
; C - no
; D - 4 no, 5 left	-> point 5
; E - 4 no, 5 right	-> point 5
; F - no


; or....
; always interact, then remember where it wants to push the player rather than doing it right away
; then do this:
; 4 slope left, 5 slope left: use point 5
; 4 slope left, 5 slope right: go with lowest value (highest coord)
; 4 slope left, 5 no slope: use point 4
; 4 slope right, 5 slope left: go with lowest value (highest coord)
; 4 slope right, 5 slope right: use point 5
; 4 slope right, 5 no slope: use point 4
; 4 no slope, 5 slope left: use point 5
; 4 no slope, 5 slope right: use point 5
; 4 no slope, 5 no slope: don't use either


		.NoSlope
		LDA $14					;\ conveyor only moves every 4 frames
		AND #$03 : BNE .NoConveyor		;/
		LDA $7693 : BMI .NoConveyor		;\
		ASL A					; |
		TAX					; |
		REP #$20				; |
		LDA !P2XPosLo				; | apply conveyor
		CLC : ADC .ConveyorDisp,x		; |
		STA !P2XPosLo				; |
		SEP #$20				; |
		.NoConveyor				;/
		LDA $0F					;\ check for collision
		AND #$04 : BEQ .DownDone		;/
		LDA !P2Slope : BNE .DownDone		; slopes update coords on their own
		.BlockDown				;\
		LDY #$04				; |
		REP #$20				; |
		LDA [$F3],y				; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; | update coords
		STA $0C					; |
		CLC : ADC !P2YPosLo			; |
		AND #$FFF0				; |
		SEC : SBC $0C				; |
		STA !P2YPosLo				; |
		SEP #$20				; |
		.DownDone				;/
		BIT $0E : BPL ..noclear			;\
		LDA #$04 : TRB $0F			; | if moving up, clear down collision
		..noclear				;/



		; up collision
		LDY #$06 : JSR GET_TILE			; up point
		LDA $0F					;\ check for collision
		AND #$08 : BEQ .UpDone			;/
		LDA $0F					;\ skip up collision if also on the ground
		AND #$04 : BNE .UpDone			;/
		LDA $0E					;\ go to bonk if touching sloped ceiling
		AND #$20 : BNE .Bonk			;/
		.BlockUp				;\
		LDY #$06				; |
		REP #$20				; |
		LDA [$F3],y				; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; | update coords
		STA $0C					; |
		CLC : ADC !P2YPosLo			; |
		AND #$FFF0				; |
		CLC : ADC #$0010			; |
		SEC : SBC $0C				; |
		STA !P2YPosLo				; |
		SEP #$20				;/
		.Bonk					;\
		LDA !P2YSpeed : BPL +			; > don't 0 speed unless moving up
		STZ !P2YSpeed				; |
	+	STZ !P2VectorTimeY			; | bonk code
		LDA !SPC1 : BNE .UpDone			; |
		LDA #$01 : STA !SPC1			; > bonk sfx
		.UpDone					;/
		BIT $0E : BMI ..noclear			;\
		LDA #$08 : TRB $0F			; | if moving down, clear up collision
		..noclear				;/

		; side collision
		LDA !PlatformExists : BEQ +		;\
		LDY #$00 : JSR GET_TILE			; |
		LDY #$01 : JSR GET_TILE			; | if there are platforms, check all points
		LDY #$02 : JSR GET_TILE			; |
		LDY #$03 : JSR GET_TILE			; |
		BRA .BlockSide				;/

	+	LDY #$00				;\
		LDA $92					; | check which side
		CMP #$08				; |
		BCS $01 : INY				;/
		PHY					;\
		JSR GET_TILE				; |
		PLY					; | upper and lower side points
		INY #2					; |
		JSR GET_TILE				;/
		.BlockSide				;\
		LDA $0F					; | see if a side is blocked
		LSR A : BCS .BlockRight			; |
		LSR A : BCC .SideDone			;/
		.BlockLeft				;\
		LDY #$01				; |
		REP #$20				; |
		LDA [$F0],y				; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		STA $0C					; |
		CLC : ADC !P2XPosLo			; | update coords (left side)
		AND #$FFF0				; |
		CLC : ADC #$0010			; |
		SEC : SBC $0C				; |
		DEC A					; |
		STA !P2XPosLo				; |
		SEP #$20				; |
		BRA .SideDone				;/
		.BlockRight				;\
		LDA #$0F : TRB !P2XPosLo		; |
		LDA [$F0]				; |
		DEC A					; | update coords (right side)
		AND #$0F				; | (this one can be simpler because characters are always less than 16px wide)
		EOR #$0F				; |
		TSB !P2XPosLo				; |
		.SideDone				;/
		LDA $785F				;\
		ORA $785F+1				; | don't clear if standing still
		BEQ ..noclear				;/
		LDA $0E					;\
		AND #$40				; |
		EOR #$40				; |
		BEQ $02 : LDA #$01			; | don't set collision flag if moving away from the wall
		INC A					; |
		TRB $0F					; |
		..noclear				;/


		; center collision
		LDY #$07 : JSR GET_TILE			; center point
		LDA $0F					;\ check for crush collision
		AND #$10 : BEQ .CenterDone		;/
		.BlockCenter				;\
		LDA #$01 : STA !P2Status		; | player dies instantly if crushed
		STZ !P2HP				; |
		.CenterDone				;/

		RTS


		.ConveyorDisp
		dw $0001,$0001,$FFFF,$FFFF



		;  00  01  02  03  04  05  06  07
	TABLE_INDEX:
		db $00,$00,$02,$02,$04,$06,$08,$0A




macro PlatformCollision(num)
		LDA !PlatformStatus+(<num>*!PlatformByteCount) : BEQ ?Return8
		REP #$20
		LDA $9A
		CMP !PlatformXLeft+(<num>*!PlatformByteCount) : BCC ?Return
		CMP !PlatformXRight+(<num>*!PlatformByteCount) : BCS ?Return
		LDA $98
		CMP !PlatformYUp+(<num>*!PlatformByteCount) : BCC ?Return
		CMP !PlatformYDown+(<num>*!PlatformByteCount) : BCS ?Return
		SEP #$20

		LDA .CollisionTable,y
		AND !PlatformStatus+(<num>*!PlatformByteCount)
		BEQ ?Return
		LDX.b #<num>*!PlatformByteCount
		LSR A : BCC $03 : JSR .PlatformRight
		LSR A : BCC $03 : JSR .PlatformLeft
		LSR A : BCC $03 : JSR .PlatformDown
		LSR A : BCC $03 : JSR .PlatformUp
	?Return:
		SEP #$20
	?Return8:

endmacro



; these are macros so they can also be used by the attack interaction point

macro SetCoords()
		REP #$20				;\
		LDA [$F0],y				; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC !P2XPosLo			; |
		BPL $03 : LDA #$0000			; > not out of bounds left
		CMP $00					; |
		BCC $02 : LDA $00			; > not out of bounds right
		STA $9A					; |
		LDA [$F3],y				; |
		AND #$00FF				; |
		CMP #$0080				; |
		BCC $03 : ORA #$FF00			; |
		CLC : ADC !P2YPosLo			; |
		BPL $03 : LDA #$0000			; > not out of bounds up
		CMP $02					; |
		BCC $02 : LDA $02			; > not out of bounds down
		STA $98					; |
		SEP #$20				;/
endmacro


macro SetMap16Index()
		LDA $98					;\
		AND #$F0				; |
		STA $04					; | lo byte of map16 index
		LDA $9A					; |
		LSR #4					; |
		TSB $04					;/
		LDX $9B					;\
		LDA $6CB6,x				; |
		BIT $0F					; | add lo byte offset based on layer and screen
		BPL $03 : LDA $6CC6,x			; |
		CLC : ADC $04				; |
		STA $04					;/
		LDA $6CD6,x				;\
		BIT $0F					; |
		BPL $03 : LDA $6CE6,x			; | hi byte of index based on layer and screen
		ADC $99					; |
		STA $05					;/
endmacro

macro GetActsLike()
		PHY					; preserve Y
		REP #$10				;\
		LDX $04					; | read raw tile number
		LDA $410000,x : XBA			; |
		LDA $400000,x				;/
		REP #$20				;\
		CMP #$4000				; |
		AND #$3FFF				; |
		BCS ?block40				; |
	?block00:					; |
		ASL A					; |
		TAY					; | get acts like setting
		LDA [$06],y				; |
		BRA ?W					; |
	?block40:					; |
		ASL A					; |
		TAY					; |
		LDA [$09],y				; |
	?W:	STA $0C					; > write to $0C
		SEP #$10				;/
		PLY					; restore Y
endmacro



	GET_TILE:
		%SetCoords()
		.SetMap16Index
		%SetMap16Index()

		LDA !3DWater : BEQ .Not3DWater		;\
		REP #$20				; |
		LDA $98					; |
		CMP !Level+2				; |
		SEP #$20				; |
		BCC .Not3DWater				; |
		LDA !IceLevel : BEQ .3DWater		; |
		REP #$20				; | apply 3D water/ice
		LDA #$0130 : STA $0C			; |
		BRA .SetIndex				; |
		.3DWater				; |
		LDA .CollisionTable,y			; |
		ORA #$40				; |
		TSB !P2Water				; |
		.Not3DWater				;/

		%GetActsLike()

		.SetIndex
		LDX TABLE_INDEX,y			;\ store to map16 table
		STA !BigRAM+$10,x			;/
		SEP #$20				; A 8-bit (now all regs)
		BIT $0F : BMI +				; no platforms on layer 2
		LDA !PlatformExists : BNE .CheckPlatforms
	+	JMP .PlatformsDone
		.CheckPlatforms
		%PlatformCollision($00)
		%PlatformCollision($01)
		%PlatformCollision($02)
		%PlatformCollision($03)
		%PlatformCollision($04)
		%PlatformCollision($05)
		%PlatformCollision($06)
		%PlatformCollision($07)
		%PlatformCollision($08)
		%PlatformCollision($09)
		%PlatformCollision($0A)
		%PlatformCollision($0B)
		%PlatformCollision($0C)
		%PlatformCollision($0D)
		%PlatformCollision($0E)
		%PlatformCollision($0F)
		.PlatformsDone


		; A = 16-bit acts like setting
		; X = map16 index
		; Y = interaction point index
		; $98/$9A = coords of tile
		; $78D8 = layer being processed


		; and now! interact with the tiles!

; --PAGE 0--
; 00 water, anim surface
; 01 water, still surface
; 02 water
; 03 water
; 04 lava, anim surface
; 05 lava
; 06 vine
; 07 net, top left
; 08 net, top mid
; 09 net, top right
; 0A net, mid left
; 0B net, mid mid (neutral)
; 0C net, mid right
; 0D net, bot left
; 0E net, bot mid
; 0F net, bot right
; 10-1C net (neutral)
; 1D-1E UNUSED???
; 1F door top
; 20 door bot
; 21 invisible coin block
; 22 invisible 1-up block
; 23 invisible note block
; 24 invisible note block (UNUSED???)
; 25-26 ----
; 27 silver door top
; 28 silver door bot
; 29 blue P coin block
; 2A blue P coin
; 2B coin
; 2C blue coin (UNUSED???)
; 2D yoshi coin top
; 2E yoshi coin bot
; 2F-37 ----
; 38 checkpoint
; 39-44 ----
; 45 red fruit
; 46 pink fruit
; 47 green fruit
; 48-69 ----
; 6A green ! block
; 6B yellow ! block
; 6C blue ! block
; 6D red ! block
; 6E moon
; 6F invisible 1-up point 1
; 70 invisible 1-up point 2
; 71 invisible 1-up point 3
; 72 invisible 1-up point 4

; 73-FF TILESET SPECIFIC
; tileset 0: all empty
; tileset 1: 73-82 solid, 83-97 empty, 98-9C boss door, 9D-9E solid, 9F-FF empty
; tileset 2: all empty
; tileset 3: all empty
; tileset 4: 73-EB empty, EC-FB solid, FC-FF empty
; tileset 5: all empty
; tileset 6: all empty
; tileset 7: all empty
; tileset 8: all empty
; tileset 9: all empty
; tileset A: all empty
; tileset B: all empty
; tileset C: all empty
; tileset D: all empty
; tileset E: all empty


; --PAGE 1--
; 00-10 ledge (solid from top but nowhere else)
; 11 note block with flower/feather/star
; 12 ON/OFF block
; 13 note block
; 14 directional coin block
; 15 note block (UNUSED???)
; 16 note block (all directions, UNUSED???)
; 17 brick with flower
; 18 brick with feather
; 19 brick with star
; 1A brick with star2/1-up/vine
; 1B brick with multiple coins
; 1C brick with coin
; 1D brick with silver P/blue P
; 1E brick
; 1F block with flower
; 20 block with feather
; 21 block with star
; 22 block with star2
; 23 block with multiple coins
; 24 block with coin
; 25 block with key/wings/balloon/shell
; 26 block with yoshi
; 27 block with shell
; 28 block with shell
; 29 brick with nothing (UNUSED???)
; 2A side brick with feather (UNUSED???)
; 2B side brick (UNUSED???)
; 2C translucent block with changing item
; 2D green star block
; 2E blue brick that can be picked up
; 2F muncher
; 30 grey block
; 31 UNUSED???
; 32 brown block
; 33-36 solid pipe
; 37 vertical exit pipe left side
; 38 vertical exit pipe right side
; 39-3E solid pipe
; 3F horizontal exit pipe bottom tile
; 40 unbreakable brick (UNUSED???)
; 41-44 solid

; 45-51 TILESET SPECIFIC (always solid)
; 52 temporary invisible solid tile
; 53-69 TILESET SPECIFIC (always solid)
; 6A green ! block
; 6B yellow ! block
; 6C blue ! block
; 6D red ! block
; 6E-B3 TILESET SPECIFIC (slopes)
; B4-B5 purple triangles (counts as a slope)
; B6-D7 TILESET SPECIFIC (slopes)
; D8-EA slope assist tiles
; EB purple triangle assist tile
; EC-FA slope assist tiles
; FB-FF lava

; this one is pretty simple!
; tiles 45-69 are tileset-specific, but always solid
; tiles 6E-D7 are tileset specific, but always slopes (have to be read from [$82])


macro BounceSprite(num, tile)
	LDA.b #<tile> : STA $9C
	LDA.b #<num>+!BounceOffset
	JSR BOUNCE_SPRITE
endmacro


		.InteractTile
		REP #$20				; A 16-bit
		LDA $0C					; A = map16 acts like setting
		CMP #$002F : BCS $03 : JMP .Pointer1	; 000-02D: pointer 1
		CMP #$0038 : BEQ .Midway		; 038: midway
		CMP #$006A : BCC .EmptyTile		;\ 02E-037 and 039-069: empty
		CMP #$0073 : BCS $03 : JMP .Pointer2	;/ 06A-072: pointer 2
		CMP #$0100 : BCC .TilesetSpecific	; 073-0FF: tileset-specific
		CMP #$0145 : BCS $03 : JMP .Pointer3	; 100-144: pointer 3
		CMP #$0152 : BEQ .InvisSolid		; 152: invisible solid
		CMP #$016A : BCC .TilesetSpecific	; 145-169: tileset-specific
		CMP #$016E : BCC .InvisSolid		; 16A-16D: solid
		CMP #$01D8 : BCC .TilesetSpecific	; 16E-1D7: tileset-specific
		CMP #$01FB : BCC .SlopeAssist		; 1D8-1FA: slope assist
		.LavaSlopeSupport			; 1FB-1FF: lava slope support
		SEP #$20
		JMP .Lava

		.EmptyTile
		SEP #$20
		RTS

		.TilesetSpecific
		JMP .TilesetHandler

		; 152, 16A-16D
		.InvisSolid
		SEP #$20
		JMP .SetBlocked

		; 038
		.Midway
		SEP #$20
		LDA #$14 : STA !P2FlashPal		; flash white
		LDA !P2HP				;\
		CMP !P2MaxHP : BEQ +			; | +1 HP unless at max
		INC !P2HP				;/
	+	LDA #$05 : STA !SPC1			; checkpoint SFX
		LDA #$01 : STA $73CE			; midway flag
		LDX !Translevel				;\
		LDA !LevelTable1,x			; | translevel checkpoint flag
		ORA #$40				;/
		STA !LevelTable1,x			;\
		LDA !Level : STA !LevelTable2,x		; |
		LDA !Level+1 : BEQ ..0xx		; | sublevel number
	..1xx	LDA !LevelTable1,x			; |
		ORA #$20				; |
		STA !LevelTable1,x			;/
	..0xx	JSL SET_GLITTER_Map16
		JMP REMOVE_TILE




; assist tiles:

; $D8: under 1/4 slope left, tile 1
; $D9: copy of $D8
; $DA: under 1/4 slope left, tile 2
; $DB: under 1/4 slope right, tile 2
; $DC: under 1/4 slope right, tile 1
; $DD: copy of $DC

; $DE: under 1/2 slope left, tile 1
; $DF: copy of $DA
; $E0: under 1/2 slope right, tile 1
; $E1: copy of $DB

; $E2: under 1/1 slope left, tile 1
; $E3: copy of $E2
; $E4: under 1/1 slope right, tile 1
; $E5: copy of $E4

; $E6-$E8: unused???

; $E9: copy of $E2
; $EA: copy of $E4

; $EB: under purple triangle

; -- tileset 0/7 --
; $EC: copy of $E2
; $ED: copy of $E4
; $EE: copy of $E2
; $EF: copy of $E4

; -- other tilesets --
; $EC: above upside down 1/1 slope left, tile 1
; $ED: above upside down 1/1 slope right, tile 1
; $EE: above upside down 1/2 slope left, tile 1
; $EF: above upside down 1/2 slope right, tile 1

; $F0: unused???

; $F1: under 2/1 slope left, tile 1
; $F2: under 2/1 slope right, tile 1

; $F3: under conveyor up/right
; $F4: under conveyor down/right
; $F5: under conveyor up/left
; $F6: under conveyor down/left

; $F7-$FA: unused???

		.SlopeAssist
		SEP #$20
		CPY #$04 : BCS +			; no side collision
	-	RTS
	+	CPY #$07 : BEQ -			; no center collision

		LDA $0C
		SEC : SBC #$D8
		TAX
		LDA .AssistData,x
		CMP #$FF : BNE ..groundslope

		LDA !HeaderTileset : BEQ ..07
		CMP #$07 : BEQ ..07

		..ceilingslope
;	REP #$20
;	LDA $98
;	CLC : ADC #$0010
;	AND #$FFF0
;	STA $98
;	SEP #$20
;	JMP .SetMap16Index

		CPY #$06 : BEQ +			;\
		BIT $0E : BMI -				; | simple solid unless up collision
		JMP .SetBlocked				;/
	+	LDA $98
		CLC : ADC #$10
		AND #$F0
		STA $98
		BCC $02 : INC $99
		LDA .AssistData_TilesetOther-$14,x
		PHY
		SEC : SBC #$6E
		TAY
		JMP .Slope_set

	..07	LDA .AssistData_Tileset07-$14,x

		..groundslope
		CPY #$06 : BEQ -			; no up collision
		BIT $0E : BMI -				; must be moving down
		PHY
		SEC : SBC #$6E
		TAY
		REP #$30
		LDA [$82],y
		AND #$00FF
		ASL #4
		STA $0C
		LDA $9A
		AND #$000F
		ORA $0C
		TAX
		LDA.l $00E632,x
		AND #$000F
		STA $04
		SEP #$30
		CLC : ADC #$06
		STA $0C
		LDA $98
		AND #$0F
		CMP $0C : BCC +
		PLY
		RTS

	+

	PLY
	REP #$20
	LDA $98
	SEC : SBC #$0010
	ORA #$000F
	STA $98
	SEP #$20
	JMP .SetMap16Index

		REP #$20
		LDA $98
		AND #$FFF0
		DEC A
		AND #$FFF0
		ORA $04
		STA $98
		SEP #$20
		BRA .Slope_set

		.AssistData
		db $6E,$6E,$73,$8C,$91,$91,$96,$73	; D8-DF
		db $A5,$8C,$AA,$AA,$AF,$AF,$00,$00	; E0-E7
		db $00,$AA,$AF,$00,$FF,$FF,$FF,$FF	; E8-EF
		db $00,$CB,$CD,$CE,$CF,$D0,$D1,$00	; F0-F7
		db $00,$00,$00				; F8-FA

	; 00 - unused
	; FF - tileset specific

		..Tileset07
		db $E2,$E4,$E2,$E4

		..TilesetOther
		db $C4,$C5,$C6,$C9




		.TilesetHandler
		CMP #$0100 : BCS $03 : JMP .Page0
		CMP #$016E : BCS $03 : JMP .Page1
		; flow into slope for 16E-1FF

; slope values:
; (direction is which direction things will slide down)

; $00: 1/4 slope left, tile 1
; $01: 1/4 slope left, tile 2
; $02: 1/4 slope left, tile 3
; $03: 1/4 slope left, tile 4
; $04: 1/4 slope right, tile 1
; $05: 1/4 slope right, tile 2
; $06: 1/4 slope right, tile 3
; $07: 1/4 slope right, tile 4
; $08: 1/2 slope left, tile 1
; $09: 1/2 slope left, tile 2
; $0A: 1/2 slope right, tile 1
; $0B: 1/2 slope right, tile 2
; $0C: 1/1 slope left, tile 1
; $0D: 1/1 slope right, tile 1
; $0E: purple triangle left
; $0F: purple triangle right
; $10: ???
; $11: ???
; $12: upside down 1/1 slope left, tile 1
; $13: upside down 1/1 slope right, tile 1
; $14: upside down 1/2 slope left, tile 1
; $15: upside down 1/2 slope left, tile 2
; $16: upside down 1/2 slope right, tile 1
; $17: upside down 1/2 slope right, tile 2
; $18: conveyor up right
; $19: conveyor down right
; $1A: conveyor up left
; $1B: conveyor down left
; $1C: 2/1 slope left, tile 1
; $1D: 2/1 slope left, tile 2
; $1E: 2/1 slope right, tile 1
; $1F: 2/1 slope right, tile 2
; $20: flat ground

; --conveyor tiles--
; tileset 01/02/08/0B
; - 1CE: up right
; - 1CF: down right
; - 1D0: up left
; - 1D1: down left
; - 1F3: support for 1CE
; - 1F4: support for 1CF
; - 1F5: support for 1D0
; - 1F6: support for 1D1

; --lava tiles--
; tileset 03 only
; - 1D2: 1/2 slope left tile 1
; - 1D3: 1/2 slope left tile 2
; - 1D4: 1/2 slope right tile 1
; - 1D5: 1/2 slope right tile 2
; - 1D6: 1/1 slope left
; - 1D7: 1/1 slope right


		.Slope
		SEP #$20					;\
		LDX $0C						; |
		CPX #$71 : BCC ..nowater			; | if any point (not just down) touches a water slope...
		CPX #$B4 : BCS ..nowater			; | ...set water flag
		LDA .UnderwaterSlopes-$71,x : BEQ ..nowater	; |
		LDA .CollisionTable,y				; |
		ORA #$40					; |
		TSB !P2Water					; |
		..nowater					;/

		LDA !HeaderTileset
		CMP #$03 : BNE ..notlava
		CPX #$D2 : BCC ..notlava
		LDA .LavaSlopes-$D2,x : STA $0C
		LDA #$40 : TSB $7694				; lava slope flag
		..notlava

		CPY #$04 : BCS +				; no side collision
	-	RTS
	+	CPY #$07 : BEQ -				; no center collision
		PHY
		LDA $0C
		SEC : SBC #$6E
		TAY
	..set	LDA #$80 : TSB $7694				; > set conveyor disable bit
		LDA [$82],y : TAX
		LDA $00E4B9,x : STA $04				; mario slope value
		LDA .SlopeData,x
		CMP #$40 : BCC ..notconveyor
		CMP #$44 : BCS ..notconveyor
		AND #$03
		TAY
		STY $7694
		LDA .ConveyorSlope,y
		..notconveyor
		STA $05						; PCE slope value

; or....
; always interact, then remember where it wants to push the player rather than doing it right away
; then do this:
; 4 slope left, 5 slope left: use point 5
; 4 slope left, 5 slope right: go with lowest value (highest coord)
; 4 slope left, 5 no slope: use point 4
; 4 slope right, 5 slope left: go with lowest value (highest coord)
; 4 slope right, 5 slope right: use point 5
; 4 slope right, 5 no slope: use point 4
; 4 no slope, 5 slope left: use point 5
; 4 no slope, 5 slope right: use point 5
; 4 no slope, 5 no slope: don't use either

		REP #$30
		LDA $9A
		AND #$000F
		STA $0C
		TXA
		ASL #4
		ORA $0C
		TAX
		LDA $00E632,x : BPL ..groundslope
		CPX #$01C0 : BCS ..groundslope

		..ceilingslope
		SEP #$30
		PLY
		CPY #$06 : BEQ +
		BIT $0E : BMI -
		JMP .SetBlocked					; ceiling slope solid from above
	+	AND #$0F
		EOR #$0F
		STA $0C
		LDA $98
		AND #$0F
		CMP $0C : BEQ $02 : BCS ..r
		LDA $98
		AND #$F0
		ORA $0C
		STA $98
		REP #$20
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		SEC : SBC $98
		EOR #$FFFF : INC A
		STA !P2YPosLo
		SEP #$20
		LDA #$20 : TSB $0E				; ceiling slope flag
		BIT $0E : BPL ..r				;\ up collision flag (only if moving up)
		LDA #$08 : TSB $0F				;/
	..r	RTS

		..groundslope
		SEP #$30
		PLY
		CPY #$06 : BCS ..r				; no ceiling collision on ground slopes
		CMP #$10 : BEQ ..r				; no interaction if set to 0x10
		STA $0D						; supersteeps can have negative values here
		AND #$0F
		STA $0C


		BIT $0E : BPL +					;\
		LDA $785F					; |
		ORA $785F+1					; | exception: return if moving perfectly straight up
		BNE +						; |
		RTS						; |
		+						;/


		LDA $785F+1					;\ compare direction of horizontal movement and slope
		EOR $05 : BPL ..checkadjust			;/
		BIT $0E : BPL +					; if moving down: don't angle snap, instead just normal snap
		JMP ..checkangle				; > angle check (doesn't fit with branch)
		..checkadjust					;\
		BIT $0E : BMI ..r				; | must be moving down to interact with ground slopes
	+	LDA !P2Blocked					; | can't snap from midair (last frame)
		AND #$04 : BEQ ..noadjust			;/
		..adjust					;\
		LDA $98						; |
		AND #$F0					; |
		ORA $0C						; | adjust position (snap to slope)
		STA $98						; |
	;	LDA #$40 : STA !P2YSpeed			; |
		..noadjust					;/

		BIT $0D : BMI +					; skip check if supersteep up tile
		LDA $98
		AND #$0F
		CMP $0C : BCC ..r
		SEC : SBC #$06
		CMP $0C : BPL ..r

	+	LDA $05 : STA !P2Slope				;\ PCE slope
		LDX !P2Character : BNE +			;/
		STA $73EE					;\ mario slopes
		LDA $04 : STA !MarioSlope			;/
	+	LDA $7694 : STA $7693				; conveyor data
		BIT #$40 : BEQ $03 : JMP .Lava			; go to lava if lava slope flag set

		LDA $98
		AND #$F0
		ORA $0C
		STA $98
		REP #$20
		LDA [$F3],y
		AND #$00FF
		SEC : SBC $98
		EOR #$FFFF : INC A
		INC #2
		BIT $0C
		BPL $04 : SEC : SBC #$0010
		CPY #$05 : BEQ ..point5
		..point4
		STA !BigRAM+0
		SEP #$20
		LDA !P2Slope
		AND #$80
		ASL A
		ROL A
		EOR #$01
		INC A
		ASL #2
		TSB $0E
		RTS
		..point5
		STA !BigRAM+2
		SEP #$20
		LDA !P2Slope
		AND #$80
		ASL A
		ROL A
		EOR #$01
		INC A
		TSB $0E
		RTS

		..checkangle
		LDA $98						;\
		AND #$0F					; | don't angle snap if above slope
		CMP $0C : BCC ..nosnap				;/
		LDA $05						;\
		CLC : ADC #$04					; | X = index to slope angle table
		ASL A						; |
		TAX						;/
		LDA #$01 : STA $2250				; set division
		REP #$20					;\
		LDA $78D7					; |
		BPL $04 : EOR #$FFFF : INC A			; |
		ASL #3						; |
		STA $2251					; |
		LDA $785F					; | 256 * |DY| / |DX|
		BPL $04 : EOR #$FFFF : INC A			; |
		LSR #4						; | (regs only support unsigned)
		STA $2253					; |
		NOP : BRA $00					; |
		LDA $2306					; |
		ASL A						;/
		BIT $785F					;\
		BPL $04 : EOR #$FFFF : INC A			; | apply minus
		BIT $78D7					; |
		BPL $04 : EOR #$FFFF : INC A			;/
		CMP #$0000 : BPL +				;\
		CMP .SlopeAngle,x : BCC ..nosnap		; |
		..snap						; |
		SEP #$20					; |
		JMP ..adjust					; | compare to slope thresholds
	+	CMP .SlopeAngle,x : BCC ..snap			; |
		..nosnap					; |
		SEP #$20					; |
		RTS						;/





		.SlopeData
		db $FF,$FF,$FF,$FF,$01,$01,$01,$01		; 00-07
		db $FE,$FE,$02,$02,$FD,$03,$FF,$01		; 08-0F
		db $00,$00,$FD,$00,$00,$00,$00,$00		; 10-17
		db $40,$41,$42,$43,$FC,$FC,$04,$04		; 18-1F: conveyors + super steep
		db $00						; 20

		.ConveyorSlope
		db $FD,$03,$03,$FD

		; index 71-B3 (70 or lower should not read, B4 and higher should not read)
		; index with tile number then read the table-71
		.UnderwaterSlopes
		db $71,$72,$00,$00,$00,$76,$77,$00,$00,$00,$7B,$7C,$00,$00,$00,$00
		db $81,$00,$00,$00,$00,$86,$00,$00,$00,$8A,$8B,$00,$00,$00,$8F,$90
		db $00,$00,$00,$94,$95,$00,$00,$00,$99,$9A,$00,$00,$00,$9E,$9F,$00
		db $00,$00,$A3,$A4,$00,$00,$00,$A8,$A9,$00,$00,$00,$AD,$AE,$00,$00
		db $00,$B2,$B3

		; index D2-D7 (D1 or lower should not read, D8 and higher aren't even slopes)
		; index with tile number then read the table-D2
		.LavaSlopes
		db $9A,$9F,$A4,$A9,$AE,$B3

		; index by (slope + 4) * 2
		.SlopeAngle
		dw $FE00,$FF00,$FF80,$FFC0	; left slopes
		dw $0000			; no slope (really a dummy value)
		dw $0040,$0080,$0100,$0200	; right slopes




		; 073-0FF
		; 73-FF TILESET SPECIFIC
		; tileset 0: all empty
		; tileset 1: 73-82 solid, 83-97 empty, 98-9C boss door, 9D-9E solid, 9F-FF empty
		; tileset 2: all empty
		; tileset 3: all empty
		; tileset 4: 73-EB empty, EC-FB solid, FC-FF empty
		; tileset 5: all empty
		; tileset 6: all empty
		; tileset 7: all empty
		; tileset 8: all empty
		; tileset 9: all empty
		; tileset A: all empty
		; tileset B: all empty
		; tileset C: all empty
		; tileset D: all empty
		; tileset E: all empty
		.Page0
		SEP #$20
		LDA !HeaderTileset
		CMP #$01 : BEQ ..Tileset1	; castle
		CMP #$04 : BNE ..empty		; no interaction at all on other tilesets
		..Tileset4			; switch palace
		LDA $0C				;\ 73-EB: empty
		CMP #$EC : BCC ..empty		;/
		CMP #$FC : BCC .Page1_solid	; EC-FB: solid (these are the giant switches, probably won't be used, but this is the hook)
	..empty	RTS				; all others empty
		..Tileset1			; castle
		LDA $0C				;\ 73-82: solid with no effect
		CMP #$83 : BCC .Page1_solid	;/
		CMP #$98 : BCC ..empty		; 83-97: empty
		CMP #$9D : BCS ..empty		; 9D-FF: empty
		..BossDoor			;\ 98-9C: boss door (act as a normal door)
		JMP .Door			;/


		; 145-169
		.Page1
		SEP #$20
		LDX !HeaderTileset		; X = tileset
		LDA $0C				;\ 145-158: always solid with no effect
		CMP #$59 : BCC ..solid		;/
		CMP #$5C : BCS +		;\
		CPX #$03 : BNE ..notlava	; | 159-15B:
	..lava	JMP .Lava			; | - hurt on tileset 01/04/0D
		..notlava			; | - lava on tileset 03
		CPX #$04 : BEQ ..hurt		; | - othwerwise solid with no effect
		CPX #$0D : BEQ ..hurt		; |
	-	CPX #$01 : BNE ..solid		;/
	..hurt	JSL HURT			;\ hurt, then set blocked
		JMP .SetBlocked			;/
	+	BEQ -				; 15C: hurt on tileset 01, otherwise solid with no effect
		CMP #$66 : BCS -		; 166-169: hurt on tileset 01, otherwise solid with no effect
	..solid	JMP .SetBlocked			; rest always solid


		; 000-02E
		.Pointer1
		ASL A
		TAX
		SEP #$20
		JMP (..ptr,x)

		..ptr
		dw .Water			; 000
		dw .Water			; 001
		dw .Water			; 002
		dw .Water			; 003
		dw .Lava			; 004
		dw .Lava			; 005
		dw .Vine			; 006
		dw .ClimbingNet			; 007
		dw .ClimbingNet			; 008
		dw .ClimbingNet			; 009
		dw .ClimbingNet			; 00A
		dw .ClimbingNet			; 00B
		dw .ClimbingNet			; 00C
		dw .ClimbingNet			; 00D
		dw .ClimbingNet			; 00E
		dw .ClimbingNet			; 00F
		dw .ClimbingNet			; 010
		dw .ClimbingNet			; 011
		dw .ClimbingNet			; 012
		dw .ClimbingNet			; 013
		dw .ClimbingNet			; 014
		dw .ClimbingNet			; 015
		dw .ClimbingNet			; 016
		dw .ClimbingNet			; 017
		dw .ClimbingNet			; 018
		dw .ClimbingNet			; 019
		dw .ClimbingNet			; 01A
		dw .ClimbingNet			; 01B
		dw .ClimbingNet			; 01C
		dw .EmptyTile			; 01D
		dw .EmptyTile			; 01E
		dw .Door			; 01F
		dw .Door			; 020
		dw .InvisCoinBlock		; 021
		dw .Invis1UpBlock		; 022
		dw .InvisNote			; 023
		dw .InvisNote			; 024
		dw .EmptyTile			; 025
		dw .EmptyTile			; 026
		dw .SilverDoor			; 027
		dw .SilverDoor			; 028
		dw .BluePCoinBlock		; 029
		dw .BluePCoin			; 02A
		dw .Coin			; 02B
		dw .Coin			; 02C
		dw .YoshiCoin_Upper		; 02D
		dw .YoshiCoin_Lower		; 02E

		; 06A-072
		.Pointer2
		SEC : SBC #$006A
		CMP #$0072
		BCC $03 : LDA #$0072
		ASL A
		TAX
		SEP #$20
		JMP (..ptr,x)

		..ptr
		dw .GreenSwitchBlock		; 06A
		dw .YellowSwitchBlock		; 06B
		dw .BlueSwitchBlock		; 06C
		dw .RedSwitchBlock		; 06D
		dw .Moon			; 06E
		dw .Invis1UpPoint		; 06F
		dw .Invis1UpPoint		; 070
		dw .Invis1UpPoint		; 071
		dw .Invis1UpPoint		; 072

		; 100-144
		.Pointer3
		AND #$00FF
		ASL A
		TAX
		SEP #$20
		JMP (..ptr,x)

		..ptr
		dw .Ledge			; 100
		dw .Ledge			; 101
		dw .Ledge			; 102
		dw .Ledge			; 103
		dw .Ledge			; 104
		dw .Ledge_DropDown		; 105
		dw .Ledge_DropDown		; 106
		dw .Ledge			; 107
		dw .Ledge			; 108
		dw .Ledge			; 109
		dw .Ledge			; 10A
		dw .Ledge			; 10B
		dw .Ledge			; 10C
		dw .Ledge			; 10D
		dw .Ledge			; 10E
		dw .Ledge			; 10F
		dw .Ledge			; 110
		dw .ContentNoteBlock		; 111
		dw .OnOffBlock			; 112
		dw .NoteBlock			; 113
		dw .Block_DirectionalCoin	; 114
		dw .NoteBlock			; 115
		dw .BouncyNoteBlock		; 116
		dw .Brick_Flower		; 117
		dw .Brick_Feather		; 118
		dw .Brick_Star			; 119
		dw .Brick_VariableItem		; 11A
		dw .Brick_MultipleCoins		; 11B
		dw .Brick_Coin			; 11C
		dw .Brick_VariableP		; 11D
		dw .Brick_Empty			; 11E
		dw .Block_Flower		; 11F
		dw .Block_Feather		; 120
		dw .Block_Star			; 121
		dw .Block_Star2			; 122
		dw .Block_MultipleCoins		; 123
		dw .Block_Coin			; 124
		dw .Block_VariableItem		; 125
		dw .Block_Yoshi			; 126
		dw .Block_GreenShell		; 127
		dw .Block_GreenShell		; 128
		dw .Brick_Fakeout		; 129
		dw .Brick_Fakeout		; 12A
		dw .Brick_Fakeout		; 12B
		dw .TranslucentBlock		; 12C
		dw .StarBlock			; 12D
		dw .CarryableBrick		; 12E
		dw .Muncher			; 12F
		dw .Solid			; 130
		dw .Solid			; 131
		dw .BrownBlock			; 132
		dw .Solid			; 133
		dw .Solid			; 134
		dw .Solid			; 135
		dw .Solid			; 136
		dw .Pipe_LeftSide		; 137
		dw .Pipe_RightSide		; 138
		dw .Solid			; 139
		dw .Solid			; 13A
		dw .Solid			; 13B
		dw .Solid			; 13C
		dw .Solid			; 13D
		dw .Solid			; 13E
		dw .Pipe_BottomTile		; 13F
		dw .Solid			; 140
		dw .Solid			; 141
		dw .Solid			; 142
		dw .Solid			; 143
		dw .Solid			; 144



		.CarryableBrick
		CPY #$06 : BCC +
	..solid	JMP .SetBlocked
	+	BIT $6DA7 : BVC ..solid
		LDA !P2Character : BEQ ..mario
		CMP #$01 : BNE ..solid
		..luigi
		LDA !P2Carry : BNE ..solid
		BRA ..takeblock
		..mario
		LDA $748F : BNE ..solid
		..takeblock
		LDX #$0F
	-	LDA $3230,x : BEQ +
		DEX : BPL -
		BRA ..solid
	+	LDA #$53 : STA $3230,x
		STZ !ExtraBits,x
		JSL !InitSpriteTables
		LDA #$0B : STA $3230,x
		LDA !P2XPosLo : STA $3220,x
		LDA !P2XPosHi : STA $3250,x
		LDA !P2YPosLo : STA $3210,x
		LDA !P2YPosHi : STA $3240,x
		LDA #$FF : STA $32D0,x
		LDA !P2Character : BEQ ..setmario
		..setluigi
		LDA #$09 : STA $3230,x
		INX : STX !P2Carry
		LDA #$08 : STA !P2PickUp
		BRA ++
		..setmario
		LDA #$08
		STA $7498
		STA $748F
	++	JMP REMOVE_TILE


		.Water
		LDA .CollisionTable,y
		ORA #$40
		TSB !P2Water
		RTS

		.Lava
		LDA !Difficulty
		AND #$03 : BNE ..die
		JSL CORE_HURT
		LDA !P2Status : BNE ..die
		LDA #$80
		LDX !P2Character
		CPX #$01
		BNE $02 : LDA #$98
		STA !P2YSpeed
		RTS
		..die
		LDA #$01 : STA !P2Status
		..return
		RTS

		.Vine
		.ClimbingNet
		CPY #$07 : BNE ..r				; only interact with center point
		LDX $0C						; x = tile number
		LDA !P2Climbing : BNE ..nolimit			; only apply edge right away if player is trying to grab the climbable tile
		CPX #$07 : BCC ..nolimit			;\ tiles 006 and 010-01C have no edges
		CPX #$10 : BCS ..nolimit			;/
		LDA $9A						;\
		AND #$0F					; |
		CMP ..xmin-7,x : BCC ..r			; |
		CMP ..xmax-7,x : BCS ..r			; | tiles 007-00F have edges
		LDA $98						; |
		AND #$0F					; |
		CMP ..ymin-7,x : BCC ..r			; |
		..nolimit
		INC !BigRAM+$20					; set "can climb" flag
	..r	RTS


		; read as ..table-7,x (x = tile number)
		; NOTE: values larger than $08 will not work for ..xmin and ..xmax
		..xmin
		db $08,$00,$00,$08,$00,$00,$08,$00,$00
		..xmax
		db $10,$10,$08,$10,$10,$08,$10,$10,$08
		..ymin
		db $08,$08,$08,$00,$00,$00,$00,$00,$00


		.SilverDoor
		LDA !PSwitchTimer : BEQ .Door_r	; P must be active for silver door to activate
		.Door
		LDA $0F				;\ player must be on ground this frame
		AND #$04 : BEQ ..r		;/
		LDA $6DA7			;\ player must press up this frame
		AND #$08 : BEQ ..r		;/
		CPY #$07 : BNE ..r		; > has to touch with center point
		LDA $741A			;\
		INC A				; | increment room counter, but cap it at 255
		BNE $01 : DEC A			; | (no wrap)
		STA $741A			;/
		LDA #$0F : STA !SPC4		; door SFX
		LDA #$0F : STA !GameMode	; load level
		LDA #$0D : STA !MarioAnim	; enter door animation
	..r	RTS


		.BrownBlock
		STZ $7909			; start eater block
		LDA !PSwitchTimer : BNE .Coin_Collect
		JMP .Solid
		.BluePCoin
		LDA !PSwitchTimer : BNE .Coin_Collect
		RTS
		.Coin
		LDA !PSwitchTimer : BEQ ..Collect
		JMP .Solid
		..Collect
		LDA !CurrentPlayer : TAX
		INC !P1CoinIncrease,x
		JSR REMOVE_TILE
		JSL SET_GLITTER_Map16
		JSR SET_ITEM_MEM
		RTS

		.YoshiCoin
		..Upper
		JSR REMOVE_TILE
		REP #$20
		LDA $98
		CLC : ADC #$0010
		STA $98
		JSR REMOVE_TILE
		REP #$20
		LDA $98
		SEC : SBC #$0008
		BRA ..collect
		..Lower
		JSR REMOVE_TILE
		REP #$20
		LDA $98
		SEC : SBC #$0010
		STA $98
		JSR REMOVE_TILE
		REP #$20
		LDA $98
		CLC : ADC #$0008
		..collect
		STA $98
		LDA !YoshiCoinCount
		INC A
		STA !YoshiCoinCount
		SEP #$20
		JSL SET_GLITTER_Map16
	;	LDA #$B4 : STA !P2FlashPal	; flash gold
		LDA #$1C : STA !SPC1		; yoshi coin SFX
	;	RTS

	!CoinSpinTime = $3F

		PHY
		PHB
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$08 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$10 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$18 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$20 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$28 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$30 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x
		JSL !GetParticleIndex
		LDA $9A : STA !Particle_XSpeed,x
		LDA $98 : STA !Particle_YSpeed,x
		SEP #$20
		LDA #$38 : STA !Particle_XAcc,x
		LDA.l !CurrentPlayer
		LSR A
		ROR A
		STA !Particle_YAcc,x
		LDA #!CoinSpinTime : STA !Particle_Timer,x
		LDA #!prt_coinglitter : STA !Particle_Type,x




		PLB
		SEP #$30
		PLY
		RTS







		.GreenSwitchBlock
		.YellowSwitchBlock
		.BlueSwitchBlock
		.RedSwitchBlock
		RTS

		.Moon
		JSR REMOVE_TILE
		JSL SET_GLITTER_Map16
		RTS

		.Invis1UpPoint
	; TODO: make this work!
		LDX $7421
		CPX #$05 : BCS ..r
		LSR A
		SBC #$03			; C clear so this subs 0x04
		CMP $7421 : BEQ ..inc
		INC
		CMP $7421 : BEQ ..r
		LDA #$FF
	..inc	INC A
		STA $7421
		BNE +
		LDX #$29 : STX !SPC4		; correct sfx
	+	CMP #$05 : BNE ..r
		LDX #$0F
	-	LDA $3230,x : BEQ +
		DEX : BPL -
		RTS
	+	LDA #$78 : STA $3200,x
		STZ !ExtraBits,x
		JSL !InitSpriteTables
		LDA !P2XPosLo : STA $3220,x
		LDA !P2XPosHi : STA $3250,x
		LDA !P2YPosLo : STA $3210,x
		LDA !P2YPosHi : STA $3240,x
	..r	RTS

		.ContentNoteBlock
		.InvisNote
		.NoteBlock

		.BouncyNoteBlock



		.Brick
		..MultipleCoins
		JSR SET_ITEM_MEM
		..Coin
		CPY #$06 : BEQ $03
	-	JMP .SetBlocked
		BIT $0E : BPL -
		LDA $0C
		CMP #$1C : BEQ ..1coin
		LDA !CoinTimer : BEQ ..multicoinstart
		CMP #$01 : BNE ..multicoin
		STZ !CoinTimer
		BRA ..1coin
		..multicoinstart
		LDA #$FF : STA !CoinTimer
		..multicoin
		JSR SPAWN_COIN
		%BounceSprite($01, $0A)			; brick -> multi coin brick
		BRA ..bonk
		..1coin
		JSR SPAWN_COIN
		BRA ..use

		..Flower
		LDA #$74				;\
		LDX $19 : BEQ ..set			; | if big, flower
		INC A					; | if small, mushroom
		BRA ..set				;/
		..Feather
		LDA #$74				; feather -> always mushroom
	..set	STA $04					;\
		LDA !MultiPlayer : STA $05		; | set item and loop counter
		BRA ..Shared				;/
		..Star2
		LDA !StarTimer : BNE ..Star		; if have star, get another one
		LDA #$1C : STA $0C			;\ otherwise 1 coin
		BRA ..Coin				;/
		..Star
		LDA #$76 : STA $04			;\
		STZ $05					; | 1 star (players share invincibility)
		BRA ..Shared				;/
		..VariableItem
		LDA $9A					;\
		AND #$30				; | 00/30 = vine, 10 = star2, 20 = 1up
		CMP #$10 : BEQ ..Star2			; |
		CMP #$20 : BEQ ..1Up			;/
		..Vine
		LDA #$79 : STA $04			;\
		STZ $05					; | spawn 1 vine
		BRA ..Shared				;/
		..1Up
		LDA #$78 : STA $04			;\
		STZ $05					; | spawn 1 golden mushroom
		BRA ..Shared				;/
		..VariableP
		LDA #$3E : STA $04			;\
		STZ $05					; | this will probably spawn the right color on its own
		BRA ..Shared				;/
		..Fakeout
		STZ $04					;\ just nothing
		STZ $05					;/

		..Shared
		JSR SET_ITEM_MEM
		CPY #$06 : BEQ ..pop
	..solid	JMP .SetBlocked
	..pop	BIT $0E : BPL ..solid
		JSR SPAWN_OBJECT
	..use	%BounceSprite($01, $0D)			; brick -> used block
	..bonk	LDY #$06
		JMP .SetBlocked

		..Empty
		CPY #$06 : BEQ ..emptyup
		CPY #$04 : BEQ ..emptydown
		CPY #$05 : BNE ..solid
		..emptydown
		BIT $0E : BMI ..r
		LDA !P2Blocked
		AND #$04 : BNE ..solid
		LDA !P2Character : BEQ ..checkspin
		CMP #$02 : BNE ..solid
		..checkdrill
		LDA !P2DropKick : BNE +
		..checkspin
		LDA $19 : BEQ ..solid
		LDA !MarioSpinJump : BEQ ..solid
	+	LDA #$D0 : STA !P2YSpeed
		JSR SHATTER_BLOCK
	..r	RTS
		..emptyup
		BIT $0E : BPL ..solid
		LDA !P2Character
		CMP #$02 : BCS ..shatter
		LDA !P2HP				;\ mario/luigi need to be big to break brick
		CMP #$02 : BCS ..shatter		;/
	..bop	%BounceSprite($01, $0C)			; brick -> brick
		BRA ..bonk
		..shatter
		JSR SHATTER_BLOCK
		BRA ..bonk




		.BluePCoinBlock
		LDA !PSwitchTimer : BNE .Block_Coin
		RTS
		.Invis1UpBlock
		BIT $78D7+1 : BPL +
		CPY #$06 : BNE +
		JSR SET_ITEM_MEM
		LDA #$78 : STA $04
		STZ $05
		JMP .Block_spawn
		.InvisCoinBlock
		BIT $78D7+1 : BPL +
		CPY #$06 : BNE +
		BIT $0E : BMI .Block_1coin
	+	RTS

		.Block
		..MultipleCoins
		JSR SET_ITEM_MEM
		..Coin
		CPY #$06 : BEQ $03
	-	JMP .SetBlocked
		BIT $0E : BPL -
		LDA $0C
		CMP #$24 : BEQ ..1coin
		LDA !CoinTimer : BEQ ..multicoinstart
		CMP #$01 : BNE ..multicoin
		STZ !CoinTimer
		BRA ..1coin
		..multicoinstart
		LDA #$FF : STA !CoinTimer
		..multicoin
		JSR SPAWN_COIN
		%BounceSprite($03, $0B)			; ?block -> multi coin ?block
		BRA ..bonk
		..1coin
		JSR SPAWN_COIN
		BRA ..use

		..Flower
		LDA #$74				;\
		LDX $19 : BEQ ..set			; | if big, flower
		INC A					; | if small, mushroom
		BRA ..set				;/
		..Feather
		LDA #$74				; feather -> always mushroom
	..set	STA $04					;\
		LDA !MultiPlayer : STA $05		; | set item and loop counter
		BRA ..Shared				;/
		..Star2
		LDA !StarTimer : BNE ..Star		; if have star, get another one
		LDA #$24 : STA $0C			;\ otherwise 1 coin
		BRA ..Coin				;/
		..Star
		LDA #$76 : STA $04			;\
		STZ $05					; | 1 star (players share invincibility)
		BRA ..Shared				;/
		..DirectionalCoin
		LDA #$45 : STA $04			;\
		STZ $05					; | 1 directional coin
		BRA ..Shared				;/
		..VariableItem
		LDA $9A
		AND #$30 : BEQ ..Key
		CMP #$10 : BEQ ..WingBlock
		CMP #$20 : BNE ..GreenShell
		..Balloon
		LDA #$7D : BRA +
		..Key
		LDA #$80 : BRA +
		..WingBlock
		LDA #$84 : STA $04
		STZ $05
		JSR SPAWN_OBJECT
		JSR REMOVE_TILE
		BRA ..bonk
		..Yoshi					; yoshi banned, just go to shell
		..GreenShell
		LDA #$04				; 1 green shell
	+	STA $04					;\ set item with no loop
		STZ $05					;/

		..Shared
		JSR SET_ITEM_MEM
		CPY #$06 : BEQ ..pop
	..solid	JMP .SetBlocked
	..pop	BIT $0E : BPL ..solid
	..spawn	JSR SPAWN_OBJECT
	..use	%BounceSprite($03, $0D)			; ?block -> used block
	..bonk	LDY #$06
		JMP .SetBlocked



		.Muncher
		LDA !SilverPTimer : BEQ $03 : JMP .Coin	; silver P makes munchers act like coins
		LDA !P2Invinc : BNE ..solid		; just act as solid block if invinc
		CPY #$06 : BCS ..hurt			; always hurt on a bonk
		CPY #$04 : BEQ ..solid			; > set blocked
		CPY #$05 : BNE ..notfloor		;\
		LDA $0F					; |
		AND #$04 : BEQ ..hurt			; |
		LDA !BigRAM+$15				; | to be hurt by walking on a muncher...
		CMP #$01 : BNE ..solid			; | ...both down points need to touch muncher blocks on the same frame
		LDA !BigRAM+$14				; |
		CMP #$2F : BEQ ..hurt			; |
		..notfloor				;/

		TYA					;\ just set blocked status on first side point
		AND #$02 : BEQ ..solid			;/
		LDA $0F					;\
		AND #$03 : BEQ ..hurt			; |
		LDA !BigRAM+$11				; | only hurt sideways...
		CMP #$01 : BNE ..solid			; | ...if both points touch muncher blocks
		LDA !BigRAM+$10				; |
		CMP #$2F : BNE ..solid			;/

	..hurt	JSL HURT
		LDA !P2Status : BNE ..solid		; don't set new speed if player died
		LDA ..XSpeed,y
		STA !P2XSpeed
		STA !P2VectorX
		LDA ..YSpeed,y
		STA !P2YSpeed
		STA !P2VectorY
		LDA ..XAcc,y : STA !P2VectorAccX
		LDA ..YAcc,y : STA !P2VectorAccY
		LDA #$10
		STA !P2VectorTimeX
		STA !P2VectorTimeY
	..solid	JMP .SetBlocked



		..XSpeed
		db $F0,$10,$F0,$10,$00,$00,$00,$00
		..XAcc
		db $01,$FF,$01,$FF,$00,$00,$00,$00

		..YSpeed
		db $00,$00,$00,$00,$F0,$F0,$10,$00
		..YAcc
		db $00,$00,$00,$00,$01,$01,$FF,$00


		.Pipe
		..LeftSide			;\
		CPY #$05 : BEQ ..solid		; > right half of player can't enter left side of pipe
		LDA $92				; | left side: must be on right half of block
		CMP #$08 : BCS +		; |
	..solid	JMP .SetBlocked			;/
		..RightSide			;\
		CPY #$04 : BEQ ..solid		; > left half of player can't enter right side of pipe
		LDA $92				; | right side: must be on left half of block
		CMP #$08 : BCS ..solid		;/
	+	CPY #$07 : BEQ ..solid		; center
		CPY #$06 : BEQ ..Up		; up?
		CPY #$04 : BCC ..solid		; sides are just solid

		..Down
		BIT $0E : BMI ..solid		; must move down
		LDA $6DA3			;\ must hold down
		AND #$04 : BEQ ..solid		;/
		LDA #$FF : STA !P2Pipe		; set pipe status
		RTS

		..Up
		BIT $0E : BPL ..solid		; must move up
		LDA $6DA3			;\ must hold up
		AND #$08 : BEQ ..solid		;/
		LDA #$BF : STA !P2Pipe		; pipe
		RTS

		..BottomTile
		LDA $0F				;\
		AND #$04			; | must be on ground
		ORA !P2Platform			; |
		BEQ .SetBlocked			;/
		TYA
		CMP #$02 : BEQ ..EnterRight
		CMP #$03 : BNE .SetBlocked

		..EnterLeft
		LDA $0F
		AND $6DA3
		AND #$02 : BEQ .SetBlocked
		LDA #$3F : STA !P2Pipe
		BRA ..SetY
		..EnterRight
		LDA $0F
		AND $6DA3
		LSR A : BCC .SetBlocked
		LDA #$7F : STA !P2Pipe
		..SetY
		REP #$20
		LDA !P2YPosLo
		CLC : ADC #$0008
		AND #$FFF0
		DEC #2
		STA !P2YPosLo
		SEP #$20
		RTS


		.Ledge_DropDown
		BIT !P2DropDownTimer : BMI +	; tiles 105 and 106 can be dropped through

		.Ledge
		CPY #$04 : BEQ ..d
		CPY #$05 : BEQ ..d
	+
	-	RTS
	..d	LDA $98
		AND #$0F
		CMP #$06 : BCS -
		BIT $0E : BMI -
		LDA $14				;\ conveyors only move every 4 frames
		AND #$03 : BNE .SetBlocked	;/
		LDA $0C				;\
		CMP #$07 : BEQ ..r		; |
		CMP #$08 : BNE .SetBlocked	; |
	..l	REP #$20			; |
		DEC !P2XPosLo			; | conveyors left/right
		BRA +				; |
	..r	REP #$20			; |
		INC !P2XPosLo			; |
	+	SEP #$20			;/

		.OnOffBlock
		.StarBlock
		.TranslucentBlock
		.Solid
		.SetBlocked
		LDA .CollisionTable,y : TSB $0F	; set collision status
		CPY #$04 : BCC ..return
		CPY #$06 : BCS ..return
		REP #$20
		LDA [$F3],y
		AND #$00FF
		SEC : SBC $98
		EOR #$FFFF : INC A
		AND #$FFF0
		CPY #$05 : BEQ ..5
		..4
		STA !BigRAM+0
		SEP #$20
		RTS
		..5
		STA !BigRAM+2
		SEP #$20
		..return
		RTS

		.CollisionTable
		db $01,$02,$01,$02,$04,$04,$08,$10



	.PlatformRight
		STA $05
		LDA !PlatformDeltaX,x : BMI ..left
	..right	BIT $785F+1 : BMI ..R
		BRA +
	..left	BIT $785F+1 : BPL ..yes
	+	CMP $785F+1
		BEQ ..yes
		BCS ..R
		..yes
		REP #$20
		LDA [$F0],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		EOR #$FFFF : INC A
		CLC : ADC !PlatformXLeft,x
		STA !P2XPos
		SEP #$20
		STZ !P2XSpeed
	..R	LDA $05
		RTS

	.PlatformLeft
		STA $05
		LDA !PlatformDeltaX,x : BPL ..right
	..left	BIT $785F+1 : BPL ..R
		BRA +
	..right	BIT $785F+1 : BMI ..yes
	+	CMP $785F+1 : BCC ..R
		..yes
		REP #$20
		LDA [$F0],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		EOR #$FFFF : INC A
		CLC : ADC !PlatformXRight,x
		DEC A
		STA !P2XPos
		SEP #$20
		STZ !P2XSpeed
	..R	LDA $05
		RTS

	.PlatformDown
		STA $05
		LDA !PlatformDeltaY,x : BMI ..up
	..down	BIT $78D7+1 : BMI ..R
		BRA +
	..up	BIT $78D7+1 : BPL ..yes
	+	CMP $78D7+1
		BEQ ..yes
		BCS ..R
		..yes
		LDA !PlatformSprite,x
		INC A
		STA !P2Platform
		REP #$20
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		EOR #$FFFF : INC A
		CLC : ADC !PlatformYUp,x
		INC A
		STA !P2YPos
		SEP #$20
		LDX !P2Platform
		DEX
		LDA !SpriteYSpeed,x : BMI ..R
		CMP !P2YSpeed : BCC ..R
		STA !P2YSpeed
	..R	LDA $05
		RTS

	.PlatformUp		; this one doesn't care about delta: always bonk when hitting head on ceiling (also no need to maintain A)
		STZ !P2YSpeed			;\
		STZ !P2VectorTimeY		; | bonk code
		LDA !SPC1 : BNE +		; |
		LDA #$01 : STA !SPC1		;/ > bonk sfx
	+	REP #$20
		LDA [$F3],y
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		EOR #$FFFF : INC A
		CLC : ADC !PlatformYDown,x
		STA !P2YPos
		SEP #$20
		RTS




; SPECIAL JSL: allow interaction for hitboxes!
; $98/$9A must be set beforehand
	.Attack
		REP #$20				;\
		LDA !P2Hitbox1W				; | return if there are no hitboxes
		ORA !P2Hitbox2W : BNE ..go		;/
		SEP #$30
		RTL

	..go	LDA !Map16ActsLike+0 : STA $06		;\
		LDA !Map16ActsLike+1 : STA $07		; |
		LDA !Map16ActsLike40+0 : STA $09	; | 24-bit pointers to map16 acts like tables
		LDA !Map16ActsLike40+1			; |
		ORA #$0080				; |
		STA $0A					;/
		SEP #$20				; A 8-bit
		LDA #$F0 : STA $00			;\
		LDA $5D					; | max X
		DEC A					; |
		STA $01					;/
		REP #$20				;\
		LDA !LevelHeight			; | max Y
		SEC : SBC #$0010			; |
		STA $02					;/

		LDA !P2Hitbox1W : BEQ ..hitbox1done	;\
		LDA !P2Hitbox1X : STA $9A		; |
		LDA !P2Hitbox1Y : STA $98		; |
		LDA $14					; |
		LSR A : BCC +				; |
		LDA !P2Hitbox1W				; |
		AND #$00FF				; |
		CLC : ADC $9A				; |
		STA $9A					; | process hitbox 1
	+	LDA $14					; |
		AND #$0002 : BEQ +			; |
		LDA !P2Hitbox1H				; |
		AND #$00FF				; |
		CLC : ADC $98				; |
		STA $98					; |
	+	JSR .ProcessAttack			; |
		REP #$20				; |
		..hitbox1done				;/
		LDA !P2Hitbox2W : BEQ ..hitbox2done	;\
		LDA !P2Hitbox2X : STA $9A		; |
		LDA !P2Hitbox2Y : STA $98		; |
		LDA $14					; |
		LSR A : BCC +				; |
		LDA !P2Hitbox2W				; |
		AND #$00FF				; |
		CLC : ADC $9A				; |
		STA $9A					; | process hitbox 2
	+	LDA $14					; |
		AND #$0002 : BEQ +			; |
		LDA !P2Hitbox2H				; |
		AND #$00FF				; |
		CLC : ADC $98				; |
		STA $98					; |
	+	JSR .ProcessAttack			; |
		..hitbox2done				;/

	..R	SEP #$30
		RTL


		.ProcessAttack
		LDA $98					;\
		BPL $03 : LDA #$0000			; |
		CMP $02					; | limit Y
		BCC $02 : LDA $02			; |
		STA $98					;/
		LDA $9A					;\
		BPL $03 : LDA #$0000			; |
		CMP $00					; | limit X
		BCC $02 : LDA $00			; |
		STA $9A					;/
		SEP #$20				; A 8-bit
		STZ $0F					; layer 1

		%SetMap16Index()
		%GetActsLike()

		CMP #$002A : BCC ..R			;\
		CMP #$002F : BCS ..notcoins		; | 02A-02E: pointer 1
		JMP .Pointer1				; |
		..notcoins				;/
		LDY #$80 : STY $0E			; $0E = 80 to pass as moving up
		LDY #$06				; Y = 6 to pass as top point
		CMP #$0114 : BCC ..R			;\
		CMP #$012E : BCS ..notborrow		; | 114-12D: pointer 3
		JMP .Pointer3				; |
		..notborrow				;/
		BNE ..R					;\
		SEP #$20				; | 12E: break it baybeeee
		JMP .Brick_Empty			;/
	..R	RTS					; return





	REMOVE_TILE:
		PEI ($00)
		PEI ($02)
		PEI ($06)
		PEI ($08)
		PEI ($0A)
		PEI ($0E)
		REP #$20
		LDA #$0025
		JSL !ChangeMap16
		PLA : STA $0E
		PLA : STA $0A
		PLA : STA $08
		PLA : STA $06
		PLA : STA $02
		PLA : STA $00
		SEP #$20
		RTS


	BOUNCE_SPRITE:
		PHA
		%Ex_Index_X()
		PLA : STA !Ex_Num,x			; num (init)
		STZ !Ex_Data1,x				; layer/dir
		LDA $9C : STA !Ex_Data2,x		; tile: used block
		LDA #$0A : STA !Ex_Data3,x		; timer
		STZ !Ex_XSpeed,x
		LDA #$C0 : STA !Ex_YSpeed,x
		STZ !Ex_XFraction,x
		STZ !Ex_YFraction,x
		LDA $9A
		AND #$F0
		STA !Ex_XLo,x
		LDA $9B : STA !Ex_XHi,x
		LDA $98
		AND #$F0
		STA !Ex_YLo,x
		LDA $99 : STA !Ex_YHi,x
		RTS


	SHATTER_BLOCK:
		LDY #$03

	-	%Ex_Index_X()
		LDA $9A
		AND #$F0
		CLC : ADC .XDisp,y
		STA !Ex_XLo,x
		LDA $9B
		ADC #$00
		STA !Ex_XHi,x
		LDA $98
		AND #$F0
		CLC : ADC .YDisp,y
		STA !Ex_YLo,x
		LDA $99
		ADC #$00
		STA !Ex_YHi,x
		LDA.b #$01+!MinorOffset : STA !Ex_Num,x
		LDA .XSpeed,y : STA !Ex_XSpeed,x
		LDA .YSpeed,y : STA !Ex_YSpeed,x
		STZ !Ex_Data1,x
		STZ !Ex_Data2,x
		STZ !Ex_Data3,x
		DEY : BPL -

		LDA #$07 : STA !SPC4			; shatter block SFX
		JMP REMOVE_TILE


		.XDisp
		db $00,$08,$00,$08

		.YDisp
		db $00,$00,$08,$08

		.XSpeed
		db $FF,$01,$FF,$01

		.YSpeed
		db $FB,$FB,$FD,$FD


; note: the !LevelWidth variable is NOT how many screens there can be in this mode, just how many are used
;	this is NOT a problem, future!Eric
;	it just means less of the table is used, but everything will still be mapped properly

	SET_ITEM_MEM:
		PHX
		PHP
		PEI ($00)
		SEP #$30
		LDA !HeaderItemMem			;\ return if invalid index
		CMP #$03 : BCS .Return			;/

		STA $00					; $00 = index (will be converted to 00 or 80)
		LSR A					;\ $01 = -------I
		STA $01					;/
		STZ $2250				;\
		REP #$20				; |
		LDA $99					; | y screen * level width
		AND #$00FF : STA $2251			; |
		LDA !LevelWidth				; |
		AND #$00FF : STA $2253			;/
		SEP #$20				;\
		LDA $9B					; | + x screen
		CLC : ADC $2306				;/
		ASL A					; * 2
		BIT $9A					;\ +1 on right half
		BPL $01 : INC A				;/
		ASL A					;\
		LSR $00					; | get highest bit from index
		ROR A					;/
		STA $00					; $00 = iSSSSSSx

		LDA $9A					;\
		AND #$70				; |
		LSR #4					; | get bit (reverse order because of course it is)
		TAX					; |
		LDA .Bits,x				;/
		REP #$10				;\
		LDX $00					; | set item memory bit
		ORA !ItemMem0,x				; |
		STA !ItemMem0,x				;/

		.Return
		REP #$20
		PLA : STA $00
		PLP
		PLX
		RTS

		.Bits
		db $80,$40,$20,$10,$08,$04,$02,$01


; input:
; $04 - object (sprite num)
; $05 - loop counter
	SPAWN_OBJECT:
		PEI ($00)
		PEI ($02)
		PEI ($06)
		PEI ($08)
		PEI ($0A)
		PEI ($0C)
		PEI ($0E)

		LDA $04 : BEQ ++			; skip if no sprite
		CMP #$08 : BCC .Powerup			; koopa shells
		CMP #$80 : BEQ .Powerup			; key
		CMP #$81 : BEQ .Powerup			; changing item from translucent block
		CMP #$74 : BCC .NotPowerup		;\ 74-78 range (mushroom, flower, star, feather, 1-up)
		CMP #$79 : BCS .NotPowerup		;/
		.Powerup
		LDX #$02 : STX !SPC4			; > powerup from block SFX
		.NotPowerup
		CMP #$79 : BNE .NotVine			; vine
		LDX #$03 : STX !SPC4			; > vine from block SFX
		.NotVine


		LDX #$0F
	-	LDA $3230,x : BEQ +
		DEX : BPL -
	++	JMP .Return

	+	LDA $04 : PHA
		LDA $05 : BEQ +
		LDA #$74 : STA $04
	+	LDA $04 : STA $3200,x
		PLA : STA $04
		STZ !ExtraBits,x
		PEI ($04)
		JSL !InitSpriteTables
		REP #$20
		PLA : STA $04
		SEP #$20


		LDA #$08 : STA $3230,x
		LDA $98
		AND #$F0
		STA $3210,x
		LDA $99 : STA $3240,x
		LDA $9A
		AND #$F0
		STA $3220,x
		LDA $9B : STA $3250,x

		LDA #$10 : STA $3360,x
		LDA #$D0 : STA !SpriteYSpeed,x
		LDA $05 : BNE +

		LDA #$3E : STA $32D0,x
		BRA ++

	+	LDA $9A
		AND #$0F
		CMP #$08
		BCC $03 : INC $3320,x
		LDY $3320,x
		LDA .VectorX,y : STA !SpriteVectorX,x
		LDA .VectorX+2,y : STA !SpriteVectorAccX,x
		LDA #$10 : STA !SpriteVectorTimerX,x

	++	LDA #$2C
		STA !SpriteDisP1,x
		STA !SpriteDisP2,x

		LDA $3200,x				;\
		CMP #$04 : BEQ .Carryable		; |
		CMP #$3E : BEQ .Init			; |
		CMP #$80 : BNE .StatusDone		; |
		.Carryable				; | carryable sprite status = 09
		INC $3230,x				; | (also timer = 00)
		STZ $32D0,x				; |
		BRA .StatusDone				;/
		.Init
		LDA #$01 : STA $3230,x
		STZ $32D0,x
		.StatusDone


		LDA $3200,x
		CMP #$7D : BEQ .y0
		CMP #$84 : BNE .SpeedDone
	.y0	STZ !SpriteYSpeed,x
		STZ $32D0,x
		LDA #$01 : STA $3320,x			; make ?block face the right way
		.SpeedDone

		LDA $05 : BEQ +
		STZ $05
		JMP -
		+


		.Return
		REP #$20
		PLA : STA $0E
		PLA : STA $0C
		PLA : STA $0A
		PLA : STA $08
		PLA : STA $06
		; not $04
		PLA : STA $02
		PLA : STA $00
		SEP #$20

		RTS

		.VectorX
		db $F0,$10		; speed
		db $01,$FF		; acc



	SPAWN_COIN:

		%Ex_Index_X()
		LDA #$01 : STA !Ex_Num,x
		LDA $9A
		AND #$F0
		STA !Ex_XLo,x
		LDA $9B : STA !Ex_XHi,x
		LDA $98
		AND #$F0
		SEC : SBC #$10
		STA !Ex_YLo,x
		LDA $99
		SBC #$00
		STA !Ex_YHi,x
		LDA !CurrentLayer : STA !Ex_Data1,x
		LDA #$D0 : STA !Ex_YSpeed,x
		STZ !Ex_YFraction,x
		LDA #$04 : STA !Ex_Data2,x		; coin hide timer
		LDA !CurrentPlayer : STA !Ex_Data3,x	; coin owner
		RTS













