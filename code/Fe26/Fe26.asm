


macro InsertSprite(name)
	START_<name>:
	incsrc "sprites_custom/<name>.asm"
	END_<name>:
	print "<name> inserted at $", hex(START_<name>), " ($", hex(END_<name>-START_<name>), " bytess)"
endmacro


; states:
;	00 - empty slot
;	01 - INIT
;	02 - dead, falling down
;		$3280, $3290, $32A0 = lo, hi, bank bytes of tilemap pointer
;		in this state, sprite runs speed (no terrain interaction except liquids) + displays its tilemap
;		despawns when off-screen
;	03 -
;	04 - turn to smoke puff particle
;	05 - sinking in lava/mud
;	06 -
;	07 -
;	08 - MAIN
;	09 - can be carried
;	0A - kicked
;	0B - carried
;	0C -
;





macro UpdateX()
		LDA !SpriteXSpeed,x : BEQ ?Return
		ASL #4
		CLC : ADC !SpriteXSub,x
		STA !SpriteXSub,x
		PHP
		LDY #$00
		LDA !SpriteXSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC !SpriteXLo,x
		STA !SpriteXLo,x
		TYA
		ADC !SpriteXHi,x
		STA !SpriteXHi,x
	?Return:
endmacro

macro UpdateY()
		LDA !SpriteYSpeed,x : BEQ ?Return
		ASL #4
		CLC : ADC !SpriteYSub,x
		STA !SpriteYSub,x
		PHP
		LDY #$00
		LDA !SpriteYSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC !SpriteYLo,x
		STA !SpriteYLo,x
		TYA
		ADC !SpriteYHi,x
		STA !SpriteYHi,x
	?Return:
endmacro






	; $07F722: zero sprite tables
	; $07F78B: load tweaker bytes
	; $07F7D2: zero sprite tables, then load tweaker bytes


	pushpc
	org $07F722
		JML Erase

	; hijacked by SA-1 just before
	org $07F7A5
		LDA.l VanillaTweakerData_Tweaker1,x : STA !SpriteTweaker1,y
		LDA.l VanillaTweakerData_Tweaker2,x : STA !SpriteTweaker2,y
		LDA.l VanillaTweakerData_Tweaker3,x : STA !SpriteTweaker3,y
		LDA.l VanillaTweakerData_Tweaker4,x : STA !SpriteTweaker4,y
		LDA.l VanillaTweakerData_Tweaker5,x : STA !SpriteTweaker5,y
		LDA.l VanillaTweakerData_Tweaker6,x : STA !SpriteTweaker6,y
	org $07F7D2
		JSL Erase			; call this routine immediately instead of jumping back and forth
		JML SetSpriteTables		; use this routine as it handles both vanilla and custom sprites
	warnpc $07F7DA
	pullpc





print " "
print "-- Fe26 --"
print "Sprite data inserted at $", pc, "."
	incsrc "SpriteClipping.asm"
	incsrc "SpriteData.asm"
	incsrc "SpriteSubRoutines.asm"


print "Fe26 sprite engine starts at $", pc, "."
	MainSpriteLoop:
		PHB

		LDA.b #!PlatformData>>16				;\ addr access
		PHA : PLB						;/

		STZ.w !PlatformExists					; clear platform flag
		%ClearPlatform($00)					;\
		%ClearPlatform($01)					; |
		%ClearPlatform($02)					; |
		%ClearPlatform($03)					; |
		%ClearPlatform($04)					; |
		%ClearPlatform($05)					; |
		%ClearPlatform($06)					; |
		%ClearPlatform($07)					; | clear platforms
		%ClearPlatform($08)					; |
		%ClearPlatform($09)					; |
		%ClearPlatform($0A)					; |
		%ClearPlatform($0B)					; |
		%ClearPlatform($0C)					; |
		%ClearPlatform($0D)					; |
		%ClearPlatform($0E)					; |
		%ClearPlatform($0F)					;/
		STZ.w !ShieldExists					; clear shield flag
		REP #$20						;\
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; | clear shield boxes
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		%ClearShield($00)					; |
		SEP #$20						;/

		PHK : PLB						; get program bank

		LDA !GameMode						;\ just load sprites in game modes other than 0x14
		CMP #$14 : BNE .Load					;/
		LDA !BG1_X_Delta					;\
		ORA !BG1_Y_Delta					; | spawn sprites on the edges of the screen
		BEQ .NoLoad						; | (but only if the camera has moved this frame)
		.Load							;/
		JSR LoadSpriteFromLevel					; > load sprites
		LDA !ProcessingSprites : BNE .NoLoad			;\
		PLB							; | if processing sprites flag is set, also run sprites
		RTL							; | otherwise return
		.NoLoad							;/

		STZ $7471						;\ clear some smw regs
		STZ $78C2						;/
		LDX #$0F						; loop through all 16 sprite slots

		.Loop							;\ set sprite index
		STX !SpriteIndex					;/
		LDA !SpriteStatus,x : BNE .WantToProcess		; check if sprite exists
	; this catches sprites that are despawned from within sprite codes
		LDA !SpriteNum,x					;\
		CMP #$FF : BEQ .NextSprite				; | erase if status = 00 (if sprite num = 0xFF, this sprite is already erased)
		JSL Erase						; |
		LDA #$FF : STA !SpriteNum,x				;/
		.NextSprite						;\ loop
		DEX : BPL .Loop						;/
		.SpritesDone
		REP #$20
		LDA !DizzyEffect
		AND #$00FF : BEQ +
		LDA !CameraBackupY : STA $1C				; restore camera
	+	SEP #$30
		PLB
		RTL

	.WantToProcess							;\
		ASL A							; |
		CMP.b #.StatePtr_end-.StatePtr : BCC ..goodstate	; | get state (invalid -> 0)
		STZ !SpriteStatus,x					; |
		LDA #$00						;/
		..goodstate						;\
		TAY							; |
		REP #$20						; | get pointer
		LDA .StatePtr,y : STA $00				; |
		SEP #$20						; |
		PEA.w .StateReturn-1					;/


	.OffScreenCheck
		BIT !SpriteTweaker3,x : BPL ..process
		JMP ..done

		..process
		LDA !SpriteXLo,x : STA $0C				;\
		LDA !SpriteXHi,x : STA $0D				; | sprite coords
		LDA !SpriteYLo,x : STA $0E				; |
		LDA !SpriteYHi,x : STA $0F				;/

		..camerabox						;\
		REP #$20						; |
		LDA !SpriteEraseMode					; |
		AND #$003F						; | check for camera box
		CMP #$0004 : BCS ..screenbordercheck			; |
		AND #$0002 : TAY					; |
		LDA !CameraBoxU : BMI ..screenbordercheck		;/
		SBC .CameraBoxThreshold_u,y				;\
		CMP $0E : BPL ..boxout					; |
		LDA !CameraBoxD						; |
		CLC : ADC .CameraBoxThreshold_d,y			; |
		CMP $0E : BMI ..boxout					; |
		LDA !CameraBoxL						; | check borders
		SEC : SBC .CameraBoxThreshold_l,y			; |
		CMP $0C : BPL ..boxout					; |
		LDA !CameraBoxR						; |
		CLC : ADC .CameraBoxThreshold_r,y			; |
		CMP $0C : BPL ..insidebox				;/
		..boxout						;\
		LDA !SpriteEraseMode					; |
		BIT #$0001 : BNE ..despawn				; | if outside box in erase mode 0/2, just don't call the sprite code
		..freeze						; |
		SEP #$20						; |
		RTS							;/
		..insidebox						;\ if 0x40 bit is set, ignore normal off-screen check while inside camera box
		BIT !SpriteEraseMode-1 : BVS ..end			;/

		..screenbordercheck					;\ if 0x80 bit is set, ignore normal off-screen check
		BIT !SpriteEraseMode-1 : BMI ..end			;/
		LDA $0C							;\
		CLC : ADC #$0060					; | check sprite x
		SEC : SBC $1A						; |
		CMP #$01C0						; |
		BCS ..despawn						;/
		LDA $6BF4						;\
		AND #$0003						; | get index to spawn/despawn settings
		ASL A : TAY						;/
		LDA $0E							; get sprite y
		BIT $0E : BMI +						;\ check level height
		CMP !LevelHeight : BCS ..despawn			;/
	+	LDA $1C							;\
		CLC : ADC InitSpriteEngine_min_y_range,y		; |
		CMP $0E : BPL ..despawn					; | check spawn/despawn ranges
		LDA $1C							; |
		CLC : ADC.w InitSpriteEngine_max_y_range,y		; |
		CMP $0E : BPL ..end					;/

		..despawn						;\
		SEP #$20						; |
		LDY !SpriteID,x						; |
		CPY #$FF : BEQ Empty					; |
		LDA !SpriteStatus,x					; |
		CMP #$02 : BEQ +					; > status 2 = don't respawn
		TYX							; | handle despawn
		LDA !SpriteLoadStatus,x					; |
		CMP #$EE : BEQ +					; |
		LDA #$00 : STA !SpriteLoadStatus,x			; |
	+	LDX !SpriteIndex					; |
		BRA Empty						;/
		..end							;\
		SEP #$20						; | A 8-bit
		..done							;/


	.GoToState
		JMP ($3000)						;\ execute pointer and return
		.StateReturn						;/
		LDA !SpriteStatus,x : BNE ..done			;\
		STZ !ExtraBits,x					; | if status is 00 after sprite has been processed...
		STZ !ExtraProp1,x					; | ...clear custom sprite regs
		STZ !ExtraProp2,x					; | (this fixes a bug if a slot is opened and claimed on the same frame)
		..done							; |
		JMP .NextSprite						;/


		.StatePtr
		dw Empty	; 00
		dw Init		; 01
		dw Fall		; 02
		dw Empty	; 03
		dw Puff		; 04
		dw Sink		; 05
		dw Empty	; 06
		dw Empty	; 07
		dw Main		; 08
		dw Item		; 09
		dw Kick		; 0A
		dw Held		; 0B
		..end
		; 0C+ are all invalid


	; note that ..d and ..r are 0x10 smaller than one might expect, due to "default size" of sprites being 16x16 pixels
	.CameraBoxThreshold
	..u	dw $001F,$005F
	..d	dw $00F0,$0130
	..l	dw $0020,$0060
	..r	dw $0110,$0150



	; this catches sprites that get auto-despawned from the off-screen check
	Empty:
		STZ !SpriteStatus,x					; status = 0
		LDA !SpriteNum,x					;\ see if sprite is already cleared
		CMP #$FF : BEQ .Return					;/
		CMP #$2B : BNE .NotPortal				;\
		LDA !ExtraBits,x					; |
		AND #$08 : BEQ .NotPortal				; | special portal check
		JSL Portal_DESPAWN					; > mark eaten sprite for respawn
		.NotPortal						;/
		JSL Erase						;\
		LDA #$FF : STA !SpriteNum,x				; | erase sprite (sprite num = 0xFF marks as erased)
		.Return							;/
		RTS							; return from state call

	Init:
		.SetStatus						;\
		LDA #$08 : STA !SpriteStatus,x				; |
		LDA !SpriteTweaker3,x					; | set status to MAIN or ITEM based on tweaker setting
		AND #$04 : BEQ ..done					; |
		INC !SpriteStatus,x					; |
		..done							;/

		.Water							;\
		LDA !BuoyancySettings : BEQ ..done			; > see if liquids are turned off
		BIT !SpriteTweaker1,x : BMI ..done			; > see if sprite doesn't interact with terrain
		LDA !3DWater : BEQ ..map16				; |
		LDA !SpriteYLo,x					; | set water status if sprite is under 3D water surface
		CMP !Level+2						; |
		LDA !SpriteYHi,x : BMI ..map16				; > can't be above the level
		SBC !Level+3 : BCS ..inwater				;/
		..map16							;\
		REP #$30						; |
		LDA #$0000						; |
		LDY #$0000						; |
		JSL GetMap16_Sprite					; | check for water tiles
		CMP #$0004						; |
		SEP #$30						; |
		BCS ..done						; |
		..inwater						;/
		LDA #$60 : STA !SpriteWater,x				;\ set water status if spawning in water
		..done							;/

		JSL SUB_HORZ_POS					;\ face player
		TYA : STA !SpriteDir,x					;/

		LDA !ExtraBits,x
		AND #!CustomBit : BEQ .Vanilla

		.Custom
		PHK : PEA.w .Return-1					; return address (sprite codes end in RTL)
		REP #$30
		LDA !SpriteNum,x
		AND #$00FF
		ASL #2 : STA $00
		ASL A : ADC $00
		TAY
		LDA SpriteData+6,y : STA $00
		LDA SpriteData+7,y : STA $01
		SEP #$30
		JML [$3000]						; run INIT code

		.Vanilla
		JSL HandleVanilla_Init
		.Return
		RTS

	Fall:
		JSL GetSpriteClippingE8					;\ interact with hitboxes
		JSL P2Attack						;/
		LDA #$80 : STA !SpriteTweaker1,x			; disable terrain interaction
		LDA #$C0 : STA !SpriteTweaker2,x			; disable player/sprite interaction
		LDA #$01 : STA !SpriteFloat,x				; normal float
		STZ !SpriteStasis,x					;\ move without stasis
		JSL APPLY_SPEED						;/
		LDA #$FF : STA !SpriteStasis,x				;\ go to main with stasis
		JMP Main						;/


	Puff:
		REP #$20						;\
		STZ $00							; |
		STZ $02							; |
		STZ $04							; | transform into puff particle
		SEP #$20						; |
		LDA $64 : STA $07					; |
		LDA #!prt_smoke16x16 : JSL SpawnParticle		; |
		STZ !SpriteStatus,x					;/
		RTS							; return from state call

	Sink:
		; TODO:
		; TO DO:
		; sink code
		RTS							; return from state call

	Item:
		.CeilingBonk
		LDA !SpriteBlocked,x
		AND #$08 : BEQ ..done
		STA !SpriteYSpeed,x
		LDA #$01 : STA !SPC1					; bonk SFX
		..done

		JSR Main						; run main code
		JSL GetSpriteClippingE8					;\
		LDA $EA							; |
		SEC : SBC #$02						; |
		STA $EA							; |
		BCS $02 : DEC $EB					; |
		INC $EE							; | output platform box
		INC $EE							; |
		LDA !SpriteBlocked,x					; |
		AND #$04 : BNE +					; |
		LDA #$04 : BRA ++					; |
	+	LDA #$07						; |
	++	JSL OutputPlatformBox					;/
		RTS							; return from state call

	Kick:
		.CeilingBonk
		LDA !SpriteBlocked,x
		AND #$08 : BEQ ..done
		STA !SpriteYSpeed,x
		LDA #$01 : STA !SPC1					; bonk SFX
		..done

		JSR Main						; run main code
		JSL GetSpriteClippingE8					;\
		LDA $EA							; |
		SEC : SBC #$02						; |
		STA $EA							; | output platform box
		BCS $02 : DEC $EB					; |
		INC $EE							; |
		INC $EE							; |
		LDA #$04 : JSL OutputPlatformBox			;/
		RTS							; return from state call

	Held:
		TXA							;\
		INC A							; | if held by a player, stay held and run main code
		CMP !P2Carry-$80 : BEQ .StillHeld			; |
		CMP !P2Carry : BEQ .StillHeld				;/
		.Drop							;\
		LDA #$09 : STA !SpriteStatus,x				; | otherwise, go back to being an item
		BRA Item						; |
		.StillHeld						;/

	Main:
		.SilverPTimer
		LDA !SilverPTimer : BEQ ..done				; check for silver P
		LDA !SpriteTweaker4,x					;\ check if sprite is immune to silver P
		AND #$08 : BNE ..done					;/
		LDA !ExtraBits,x					;\
		AND #$08 : BNE ..transform				; |
		LDA !SpriteNum,x					; | check if sprite already is a coin
		CMP #$21 : BEQ ..done					; |
		..transform						;/
		REP #$20						;\
		STZ $00							; |
		STZ $02							; |
		STZ $04							; | spawn smoke puff
		SEP #$20						; |
		LDA $64 : STA $07					; |
		LDA #!prt_smoke16x16 : JSL SpawnParticle		;/
		LDA #$21 : STA !SpriteNum,x				;\
		STZ !ExtraBits,x					; | transform into coin
		JSL !ResetSprite					; |
		..done							;/

		.Dizzy
		LDA !DizzyEffect : BEQ ..done				;\
		LDA !GameMode						; | check for dizzy effect
		CMP #$14 : BNE ..done					;/
		REP #$20						;\
		LDA !CameraBackupY : STA $1C				; |
		SEP #$20						; |
		LDA !SpriteXHi,x : XBA					; |
		LDA !SpriteXLo,x					; |
		REP #$20						; |
		SEC : SBC $1A						; |
		AND #$00FF						; |
		LSR #3							; |
		ASL A							; | apply dizzy offset
		PHX							; |
		TAX							; |
		LDA !DecompBuffer+$1040,x				; |
		AND #$01FF						; |
		CMP #$0100						; |
		BCC $03 : ORA #$FE00					; |
		STA $1C							; |
		PLX							; |
		SEP #$20						; |
		..done							;/

		.UpdateTile						;\
		LDA !ExtraBits,x					; | vanilla/custom check
		AND #!CustomBit : BNE ..custom				; |
		..vanilla						;/
		LDY !SpriteStatus,x					; get status
		PHX							;\
		REP #$30						; |
		LDA !SpriteNum,x					; |
		AND #$00FF : STA $00					; > save sprite number here
		ASL A							; |
		TAX							; |
		LDA.l SpriteGFXIndex_Vanilla,x				; | (don't update if = 0xFFFF)
		CMP #$FFFF : BNE ..updatevanilla			;/
		..dontupdate						;\
		SEP #$30						; |
		PLX							; | restore X and default to 0
		STZ !SpriteTile,x					; |
		STZ !SpriteProp,x					; |
		BRA ..done						;/
		..updatevanilla						;\
		TAX							; |
		LDA $00							; |
		CMP #$007E : BEQ ..dontupdate				; |
		CMP #$007F : BEQ ..dontupdate				; > flying rainbow shroom and flying red coin should use 0
		CMP #$000D : BCS ..update				; |
		CMP #$0004 : BCC ..update				; | get sprite's load status
		CPY #$0002 : BEQ ..shell				; |
		CPY #$0009 : BCC ..update				; | (special case for koopa shell)
		..shell							; |
		LDX.w #!GFX_Shell_offset : BRA ..update			;/
		..custom						;\
		PHX							; |
		REP #$30						; |
		LDA !SpriteNum,x					; |
		AND #$00FF						; | get sprite's load status
		ASL A							; |
		TAX							; |
		LDA.l SpriteGFXIndex_Custom,x : BPL ..updatecustom	;/ (don't update if negative)
		SEP #$30						;\
		PLX							; | just return if negative
		BRA ..done						;/
		..updatecustom						;\ X = index
		TAX							;/
		..update						;\
		LDA !GFX_status,x					; |
		SEP #$30						; |
		PLX							; | get tile + prop
		STA !SpriteTile,x					; |
		XBA : STA !SpriteProp,x					; |
		..done							;/

		.3DWater						;\
		LDA !3DWater : BEQ ..done				; |
		LDA !SpriteYHi,x : XBA					; |
		LDA !SpriteYLo,x					; |
		REP #$20						; |
		CMP !Level+2						; |
		SEP #$20						; | apply 3D water
		BCC ..done						; |
		LDA !SpriteStatus,x					; |
		CMP #$02 : BNE +					; |
		LDA #$01 : STA !SpriteWater,x				; |
	+	LDA !SpriteExtraCollision,x				; |
		ORA #$40 : STA !SpriteExtraCollision,x			; |
		..done							;/

		.DecTimers
		%decreg($32D0)						; main timer
		%decreg(!SpriteDisP1)					; P1 interaction disable timer
		%decreg(!SpriteDisP2)					; P2 interaction disable timer
		%decreg(!SpriteDisSprite)				; sprite interaction disable timer
		%decreg(!SpriteIFrames)					; sprite interaction disable timer
		LDA !SpriteStasis,x : BEQ ..done			;\
		CMP #$FF : BEQ ..done					; | stasis timer (if set to -1, it will never end)
		DEC !SpriteStasis,x					; |
		..done							;/

		LDA !ExtraBits,x					;\ check sprite type (vanilla/custom)
		AND #!CustomBit : BNE .Custom				;/

		.Vanilla						;\ main code for vanilla sprite
		JSL HandleVanilla_Main					;/
		RTS							; return from state call

		.Custom							;\
		LDA !SpriteNum,x					; |
		REP #$30						; |
		AND #$00FF						; |
		ASL #2 : STA $00					; |
		ASL A : ADC $00						; | main code for custom sprite
		TAY							; |
		LDA SpriteData+$09,y : STA $00				; |
		LDA SpriteData+$0A,y : STA $01				; |
		SEP #$30						; |
		PHK : PEA.w ..return-1					; > return address
		JML [$3000]						;/
		..return						;\ return from state call
		RTS							;/




	InitSpriteEngine:
		PHB : PHK : PLB
		PHP
		SEP #$30

		LDX #$00				;\
		TXA					; | reset load status for all sprites
	-	STA !SpriteLoadStatus,x			; |
		INX : BNE -				;/
		REP #$10				;\
		LDX #$027A				; |
	-	STZ $7693,x				; | clear all this stuff or whatever
		DEX : BPL -				; |
		SEP #$10				;/
		STZ !ScrollSpriteNum_L1			;\ despawn scroll sprites
		STZ !ScrollSpriteNum_L2			;/

		STZ !SpriteStatus+$0			;\
		STZ !SpriteStatus+$1			; |
		STZ !SpriteStatus+$2			; |
		STZ !SpriteStatus+$3			; |
		STZ !SpriteStatus+$4			; |
		STZ !SpriteStatus+$5			; |
		STZ !SpriteStatus+$6			; |
		STZ !SpriteStatus+$7			; | kill all sprites
		STZ !SpriteStatus+$8			; |
		STZ !SpriteStatus+$9			; |
		STZ !SpriteStatus+$A			; |
		STZ !SpriteStatus+$B			; |
		STZ !SpriteStatus+$C			; |
		STZ !SpriteStatus+$D			; |
		STZ !SpriteStatus+$E			; |
		STZ !SpriteStatus+$F			;/
		STZ !SpriteNum+$0			;\
		STZ !SpriteNum+$1			; |
		STZ !SpriteNum+$2			; |
		STZ !SpriteNum+$3			; |
		STZ !SpriteNum+$4			; |
		STZ !SpriteNum+$5			; |
		STZ !SpriteNum+$6			; |
		STZ !SpriteNum+$7			; | reset all sprite nums to make sure they will be cleared properly
		STZ !SpriteNum+$8			; |
		STZ !SpriteNum+$9			; |
		STZ !SpriteNum+$A			; |
		STZ !SpriteNum+$B			; |
		STZ !SpriteNum+$C			; |
		STZ !SpriteNum+$D			; |
		STZ !SpriteNum+$E			; |
		STZ !SpriteNum+$F			;/


		LDA $6BF4				; this is set as part of LM's level data
		AND #$03				;\
		ASL A					; |
		TAX					; |
		REP #$20				; | we need to set these due to LM hijacking the vanilla sprite off screen code
		LDA.l .min_y_range,x : STA $6BF0	; |
		LDA.l .max_y_range,x : STA $6BF2	; |
		SEP #$20				;/
		LDA #$00 : STA !ProcessingSprites
		JSL MainSpriteLoop			; call main loop

		REP #$20				;\
		LDA $94					; |
		SEC : SBC #$0020			; |
		STA $E0					; |
		LDA $96					; |
		SEC : SBC #$0010			; |
		STA $E2					; |
		LDA #$0050				; |
		STA $E4					; | despawn sprites that are withing 32px of players upon level entry
		STA $E6					; |
		SEP #$30				; |
		LDX #$0F				; |
	-	LDA !SpriteStatus,x : BEQ +		; |
		LDA !SpriteTweaker3,x			; > check for despawn protection
		AND #$20 : BNE +			; |
		JSL GetSpriteClippingE8			; |
		JSL CheckContact : BCC +		; |
		STZ !SpriteStatus,x			; |
	+	DEX : BPL -				;/

		PLP
		PLB
		RTL


	; shoutout to Vitor for straight up giving me these
	.min_y_range
	dw $FF40,$FFD0,$FF80,$C001		; Horizontal, Vertical, Enhanced Vertical, Infinity
	.max_y_range
	dw $01B0,$0120,$0160,$3FFF		; Horizontal, Vertical, Enhanced Vertical, Infinity



macro NegZero(address)
	LDA <address> : BPL ?Ok
	STZ <address>
	?Ok:
endmacro


; values read from [$CE]
; offset 0 is a header byte
; a vanilla sprite is 3 bytes
; a custom sprite is 5 bytes (vanilla data + 2 extra bytes)
; the main sprite data is:
;	+00	yyyyCEXY
;		Yyyyy = Y position
;		C = custom bit
;		E = extra bits
;		X = X position hi bit (toggles screen 0x00 or 0x10)
;
;	+01	xxxxXXXX
;		xxxx = x position lo nybble (tile position on screen)
;		XXXX = X position hi nybble (screen number lo nybble)
;
;	+02	NNNNNNNN
;		sprite number
;
;	+03	extra byte 1 (only used by custom sprites)
;
;	+04	extra byte 2 (only used by custom sprites)
;

	LoadSpriteFromLevel:
		PHP					;\
		SEP #$20				; |
		BIT $6BF4 : BPL .NoSmart		; |
		LDA $1A					; |
		CMP $6BEE : BNE .SmartUpdate		; | if smart spawn is enabled, sprites only spawn if the camera has moved since last time this was called
		LDA $1C					; |
		CMP $6BEF : BNE .SmartUpdate		; |
		PLP					; |
		RTS					;/
	.SmartUpdate					;\
		LDA $1A : STA $6BEE			; | update smart regs
		LDA $1C : STA $6BEF			; |
	.NoSmart					;/

; $F0	left border of spawn box
; $F2	right border of spawn box
; $F4	top border of spawn box
; $F6	bottom border of spawn box
; $F8	left border of forbiddance box
; $FA	right border of forbiddance box
; $FC	top border of forbiddance box
; $FE	bottom border of forbiddance box

		LDA !GameMode
		CMP #$14 : BEQ ..nobackup
		PEI ($F0)
		PEI ($F2)
		PEI ($F4)
		PEI ($F6)
		PEI ($F8)
		PEI ($FA)
		PEI ($FC)
		PEI ($FE)
		..nobackup
		SEP #$30
		LDA $6BF4
		AND #$03
		ASL A
		TAX
		REP #$30

		LDA $1A						; > BG1 Xpos
		AND #$FFF0					;
		SEC : SBC #$0030				;\
		BPL $03 : LDA #$0000				; | left border spawn box (-0x30)
		STA $F0						;/
		CLC : ADC #$0151				;\ right border spawn box (+0x121)
		STA $F2						;/
		SEC : SBC #$0141				;\ left border forbiddance box (-0x20)
		STA $F8						;/
		CLC : ADC #$0131				;\ right border forbiddance box (+0x111)
		STA $FA						;/
		LDA $1C						;\
		AND #$FFF0					; | top border spawn box
		STA $00						; > store
		CLC : ADC.w InitSpriteEngine_min_y_range,x	; |
		STA $F4						;/
		LDA $00						;\
		CLC : ADC.w InitSpriteEngine_max_y_range,x	; | bottom border spawn box
		STA $F6						;/
		LDA $00						;\
		SEC : SBC #$0020				; | top border forbiddance box
		STA $FC						;/
		CLC : ADC #$0111				;\ bottom border forbiddance box
		STA $FE						;/

		%NegZero($F0)					;\
		%NegZero($F2)					; |
		%NegZero($F4)					; |
		%NegZero($F6)					; | no negative coordinates allowed
		%NegZero($F8)					; |
		%NegZero($FA)					; |
		%NegZero($FC)					; |
		%NegZero($FE)					;/

		LDA !GameMode					;\
		AND #$00FF					; |
		CMP #$0014 : BEQ .SpawnBoxReady			; |
		STZ $F8						; | if in any game mode other than 0x14, disable forbiddance box
		STZ $FA						; | this way all sprites on-screen can be loaded immediately
		STZ $FC						; |
		STZ $FE						; |
	.SpawnBoxReady						;/


		SEP #$20
		LDX #$FFFF					; which sprite we're on (note that the loop starts with INX)
		LDY #$0001					; index to sprite data
		STZ $0E						; clear new sprite system flag
		LDA [$CE]					;\
		AND #$20					; | set sprite system
		BEQ $02 : DEC $0E				;/
		STZ $0F						; clear dynamic Y offset


	.LoadNewSprite
		INX						; next sprite
	.ReadNext
		LDA [$CE],y
		CMP #$FF : BNE .Sprite
	.Command
		BIT $0E : BPL .End
		INY
		LDA [$CE],y : BPL .UpdateY
		CMP #$FF : BEQ .Sprite

	.End
		JMP .Return

	.UpdateY
		ASL A					;\ update dynamic Y offset
		STA $0F					;/
		INY					; increment index
		BRA .ReadNext				; get next (without going to next sprite)

	.Spawned
		INY
	.OutOfBounds
		SEP #$20				; A 8-bit
		LDA $08					;\ vanilla/custom
		AND #$08 : BEQ +			;/
		INY #2					;\ skip past its data
	+	INY #2					;/ (we already incremented once)
		BRA .LoadNewSprite			; get next

	.Sprite
		STA $05					; $05 = copy of first byte
		AND #$0C : STA $08			; $08 = extra bits
		LDA !SpriteLoadStatus,x : BNE .Spawned	; see if sprite is marked for spawning
		LDA $05					;\
		AND #$02				; | $01 = hi Xpos
		ASL #3					; | (highest bit)
		STA $01					;/
		LDA $05					;\
		AND #$01				; | $03 = hi Ypos
		ORA $0F					; | (+dynamic Y offset)
		STA $03					;/
		LDA $05					;\
		AND #$F0				; | $02 = lo Ypos
		STA $02					;/
		INY					;\
		LDA [$CE],y				; | $00 = lo Xpos
		AND #$F0				; |
		STA $00					;/
		LDA [$CE],y				;\
		AND #$0F				; | $01 = hi Xpos
		TSB $01					;/  (complete)

		REP #$20				;\
	if !TrackSpriteLoad
		PHX
		TXA
		ASL A
		TAX
		LDA $02
		XBA
		STA !DebugData+$00,x
		PLX
	endif
		LDA $00					; |
		CMP $F0 : BCC .OutOfBounds		; |
		CMP $F2 : BCS .OutOfBounds		; | has to be within spawn box
		LDA $02					; |
		CMP $F4 : BCC .OutOfBounds		; |
		CMP $F6 : BCS .OutOfBounds		;/
		CMP $FC : BCC .GoodXY			;\
		CMP $FE : BCS .GoodXY			; |
		LDA $00					; | has to be outside of forbiddance box
		CMP $F8 : BCC .GoodXY			; |
		CMP $FA : BCC .OutOfBounds		; |
	.GoodXY	SEP #$20				;/

		PHX					;\
		LDX #$000F				; |
	-	LDA !SpriteStatus,x : BEQ .ThisIndex	; | search for a sprite index
		DEX : BPL -				; | (return if no one is found)
		PLX					; |
	.SpawnFail					;/
		INY
		JMP .LoadNewSprite
	.ThisIndex
		INY					; get ready to read num byte
		LDA $08 : STA !ExtraBits,x		; write extra bits
		AND #$08 : BEQ .NotCustom		; see if custom or vanilla

	.Custom
		LDA #$01 : STA $04			; state = INIT
		LDA [$CE],y : STA !SpriteNum,x		; sprite num
		INY					;\ prop 1
		LDA [$CE],y : STA !ExtraProp1,x		;/
		INY					;\ prop 2
		LDA [$CE],y : STA !ExtraProp2,x		;/
		JMP .INIT				; go to INIT
	.NotCustom


		LDA [$CE],y
		CMP #$F6 : BCS .SpawnFail		; F6-FF are banned by lunar magic and can never be used
		CMP #$E7 : BCC .NotScroll		; E7-F5: scroll sprite
		.Scroll
		SBC #$E7
		XBA
		LDA !ScrollSpriteNum_L1
		ORA !ScrollSpriteNum_L2
		BNE .SpawnFail
		XBA
		STA !ScrollSpriteNum
		LDA $02
		LSR #2
		STA $7440				; Ypos / 4
		PHX
		PHY
		JSL $05BCD6				; init scroll sprite?
		PLY
		PLX
		INY
		JMP .LoadNewSprite
		.NotScroll

		CMP #$DE : BNE .NotEeries		; DE: 5 eeries
		JSR .Spawn5Eeries
		BRA +
		.NotEeries

		CMP #$E0 : BNE .NotPlatforms		; E0: 3 platforms on chains
		JSR .Spawn3Platforms
	-
	+	PLX
		LDA #$01 : STA !SpriteLoadStatus,x
		INY
		JMP .LoadNewSprite
		.NotPlatforms

		CMP #$CB : BCC .NotGenerator		; CB-D9: generator
		CMP #$DA : BCS .Shell
		SBC #$CB
		INC A
		STA !GeneratorNum
		LDA #$00 : STA !SpriteLoadStatus,x	; generator can always be reloaded
		.NotGenerator

		CMP #$C9 : BCC .Vanilla			; C9-CA: shooter
		.Shooter				;\
		SEP #$10				; | get fusion index
		%Ex_Index_Y_fast()			; |
		REP #$10				;/
		LDA #!Shooter_Num : STA !Ex_Num,y	; fusion num: shooter
		LDA $00 : STA !Ex_XLo,y			;\
		LDA $01 : STA !Ex_XHi,y			; | coords
		LDA $02 : STA !Ex_YLo,y			; |
		LDA $03 : STA !Ex_YHi,y			;/
		TXA : STA !Ex_Data2,y			; shooter index to level sprite data
		LDA #$10 : STA !Ex_Data1,y		; timer: 32 frames at spawn (decrements every other frame)
		PLY
		BRA -

		.Shell
		SBC #$DA
		CMP #$04
		BCC $02 : LDA #$00
		ORA #$04
		STA !SpriteNum,x
		BRA .INIT

; 00-C8		normal sprite
; C9-CA		shooter
; CB-D9		generator
; DA-DD		stationary shells
; DE		5 eeries
; DF		green shell, immune to special world
; E0		3 platforms on chains
; E1-E6		cluster sprite
; E7-F5		scroll sprite
; F6-FF		banned by lunar magic


; remap:
;	CB-D9	generators, probably includes some custom ones
;	E1-E6	special commands
;	E7-F5	HDMA pointer commands
;	F6-FF	can't be used, unfortunately, since LM refuses to insert these in any way and will throw errors if they are inserted by a third party
;
;

;	CB	eerie gen
;	CC	para-goomba gen
;	CD	para-bomb gen
;	CE	para-bomb + para-goomba gen
;	CF	dolphin left gen
;	D0	dolphin right gen
;	D1	jumping fish gen
;	D2	turn off gen 2 (same as sprite E5?????)
;	D3	supepr koopa gen
;	D4	bubble with goomba and bob-omb gen
;	D5	bullet bill gen
;	D6	bullet bill surround gen
;	D7	bullet bill diagonal gen
;	D8	bowser fire gen
;	D9	turn off gen
;
;	E1	reload sprite GFX
;	E2	reload dynamic layer object GFX
;	E3	reload pathing map
;	E4	
;	E5
;	E6

;	E7	enable 3D water
;	E8	enable basic parallax
;	E9
;	EA
;	EB
;	EC
;	ED
;	EE
;	EF
;	F0
;	F1
;	F2
;	F3
;	F4
;	F5
;



	.Vanilla
		STA !SpriteNum,x			; sprite num

	.INIT
		LDA $00 : STA !SpriteXLo,x		;\
		LDA $01 : STA !SpriteXHi,x		; | write coords
		LDA $02 : STA !SpriteYLo,x		; |
		LDA $03 : STA !SpriteYHi,x		;/
		LDA $0F : PHA				;
		JSL !ResetSprite			; reset/reload tables (this routine shreds $00-$02)
		LDA [$CE],y				;\
		CMP #$DA : BCC ..noshell		; |
		LDA !SpriteTweaker3,x			; | koopa shell clause
		ORA #$04 : STA !SpriteTweaker3,x	; |
		..noshell				;/
		INY					; increment index
		PLA : STA $0F				;
		LDA !3DWater : BEQ ..no3dwater		;\
		REP #$20				; |
		LDA $02					; |
		CMP !Level+2				; | init in water
		SEP #$20				; |
		BCC ..no3dwater				; |
		LDA #$01 : STA !SpriteWater,x		; |
		..no3dwater				;/
		LDA #$01 : STA !SpriteStatus,x		; state
		LDA $01,s : STA !SpriteID,x		; sprite index to level table, sprite level ID

	.NoInit
		PLX					; restore sprite counter
		LDA #$01 : STA !SpriteLoadStatus,x	; mark this sprite as spawned
		CPY #$0500 : BCS .Return		;\ just to make sure nothing goes wrong
		JMP .LoadNewSprite			;/

		.Return
		REP #$20
		LDA !GameMode
		AND #$00FF
		CMP #$0014 : BEQ ..done
		PLA : STA $FE
		PLA : STA $FC
		PLA : STA $FA
		PLA : STA $F8
		PLA : STA $F6
		PLA : STA $F4
		PLA : STA $F2
		PLA : STA $F0
		..done
		PLP
		RTS

	.Spawn5Eeries
		PHB					;\ wrap to bank 0x02
		LDA #$02 : PHA : PLB			;/
		PHY					; push Y
		SEP #$10				; index 8-bit
		LDY #$04				; loop counter
		LDX #$0F				;\
	-	LDA !SpriteStatus,x : BEQ +		; | loop through sprite slots
	--	DEX : BPL -				;/
		BRA ++					; end if all sprite slots are full

	+	LDA #$08 : STA !SpriteStatus,x		;\ sprite 0x39, state MAIN
		LDA #$39 : STA !SpriteNum,x		;/
		STZ !ExtraBits,x			; vanilla sprite, extra bit clear
		PEI ($02)				;\ this is overwritten by palset loader
		PEI ($00)				;/
		JSL !InitSpriteTables			; reset + init
		PLA : STA $00				;\
		PLA : STA $01				; | this is overwritten by palset loader
		PLA : STA $02				; |
		PLA : STA $03				;/
		LDA $00					;\
		CLC : ADC $AF87,y			; |
		STA !SpriteXLo,x			; | x pos
		LDA $01					; |
		ADC $AF8C,y				; |
		STA !SpriteXHi,x			;/
		LDA $02 : STA !SpriteYLo,x		;\ y pos
		LDA $03 : STA !SpriteYHi,x		;/
		PHY					;\
		JSR SUB_HORZ_POS			; | x speed
		LDA $AF9B,y : STA !SpriteXSpeed,x	; |
		PLY					;/
		LDA $AF91,y : STA !SpriteYSpeed,x	; y speed
		LDA $AF96,y : STA $BE,x			; state
		CPY #$04 : BNE +			;\ only the "main" eerie gets a sprite ID, the others use the default 0xFF meaning they can't respawn
		LDA $06,s : STA !SpriteID,x		;/
	+	DEY : BPL --				; main eerie loop
	++	REP #$10				; index 16-bit
		PLY					; pull Y
		PLB					; pull bank
		RTS					; return

	.Spawn3Platforms
		PHB					;\ wrap to bank 0x02
		LDA #$02 : PHA : PLB			;/
		PHY					; push Y
		SEP #$10				; index 8-bit
		LDY #$02				; loop counter
		LDX #$0F				;\
	-	LDA !SpriteStatus,x : BEQ +		; | loop through sprite slots
	--	DEX : BPL -				;/
		BRA ++					; end if all sprite slots are full

	+	LDA #$01 : STA !SpriteStatus,x		;\ sprite 0xA3, state INIT
		LDA #$A3 : STA !SpriteNum,x		;/
		STZ !ExtraBits,x			; vanilla sprite, extra bit clear
		PEI ($02)				;\ this is overwritten by palset loader
		PEI ($00)				;/
		JSL !InitSpriteTables			; reset + init
		PLA : STA $00				;\
		PLA : STA $01				; | this is overwritten by palset loader
		PLA : STA $02				; |
		PLA : STA $03				;/
		LDA $00 : STA !SpriteXLo,x		;\ x pos
		LDA $01 : STA !SpriteXHi,x		;/
		LDA $02 : STA !SpriteYLo,x		;\ y pos
		LDA $03 : STA !SpriteYHi,x		;/
		LDA $AF2D,y : STA $33D0,x		; rotation lo byte
		LDA $AF30,y : STA $32A0,x		; rotation hi byte
		CPY #$02 : BNE +			;\ only the "main" platform gets a sprite ID, the others use the default 0xFF meaning they can't respawn
		LDA $06,s : STA !SpriteID,x		;/
	+	DEY : BPL --				; main platform loop
	++	REP #$10				; index 16-bit
		PLY					; pull Y
		PLB					; pull bank
		RTS					; return



	Erase:
		.Hitbox
		TXA							;\ handles both 8-bit and 16-bit index
		CMP #$08 : BCS ..8F					;/
	..07	LDA.l CORE_BITS,x					;\
		TRB !P2Hitbox1IndexMem1-$80				; |
		TRB !P2Hitbox2IndexMem1-$80				; |
		TRB !P2Hitbox1IndexMem1					; |
		TRB !P2Hitbox2IndexMem1					; |
		BRA ..hitboxcleared					; | clear hitbox index memory
	..8F	LDA.l CORE_BITS,x					; |
		TRB !P2Hitbox1IndexMem2-$80				; |
		TRB !P2Hitbox2IndexMem2-$80				; |
		TRB !P2Hitbox1IndexMem2					; |
		TRB !P2Hitbox2IndexMem2					; |
		..hitboxcleared						;/

		.IRAM
		STZ $9E,x				;\ speed
		STZ $AE,x				;/
		STZ $BE,x				; misc
	;	STZ $3200,x				; !SpriteNum
	;	STZ $3210,x				; !SpriteYLo
	;	STZ $3220,x				; !SpriteXLo
	;	STZ $3230,x				; !SpriteStatus
	;	STZ $3240,x				; !SpriteYHi
	;	STZ $3250,x				; !SpriteXHi
		STZ $3260,x				; !SpriteYSub
		STZ $3270,x				; !SpriteXSub
		STZ $3280,x				; misc
		STZ $3290,x				; misc
		STZ $32A0,x				; misc
		STZ $32B0,x				; misc
		STZ $32C0,x				; !SpriteHP
		STZ $32D0,x				; main timer
		STZ $32E0,x				; !SpriteDisP1
		STZ $32F0,x				; !SpriteDisP2
		STZ $3300,x				; !SpriteDisSprite
		STZ $3310,x				; !SpriteIFrames
		STZ $3320,x				; !SpriteDir
		STZ $3330,x				; !SpriteBlocked
		STZ $3340,x				; !SpriteSlope
		STZ $3350,x				; !SpriteWater
		STZ $3360,x				; tweaker 1
		STZ $3370,x				; tweaker 2
		STZ $3380,x				; tweaker 3
		STZ $3390,x				; tweaker 4
		STZ $33A0,x				; tweaker 5
		STZ $33B0,x				; tweaker 6
		STZ $33C0,x				; !SpriteOAMProp
		STZ $33D0,x				; !SpriteAnimIndex
		STZ $33E0,x				; !SpriteAnimTimer
		LDA #$FF : STA $33F0,x			; !SpriteID, sprite index in level (defaults to 0xFF = no ID, can't respawn)
		STZ $3400,x				; misc
		STZ $3410,x				; misc
		STZ $3420,x				; misc
		STZ $3430,x				; misc
		STZ $3440,x				; misc
		STZ $3450,x				; misc
		STZ $3460,x				; misc
		STZ $3470,x				; misc
		STZ $3480,x				; misc
		STZ $3490,x				; misc
		STZ $34A0,x				; misc
		STZ $34B0,x				; misc
		STZ $34C0,x				; misc
		STZ $34D0,x				; misc
		STZ $34E0,x				; misc
		STZ $34F0,x				; misc
		STZ $3500,x				; misc
		STZ $3510,x				; misc
		STZ $3520,x				; misc
		STZ $3530,x				; misc
		STZ $3540,x				; misc
		STZ $3550,x				; misc
		STZ $3560,x				; misc
		STZ $3570,x				; misc
		STZ $3580,x				; misc
		STZ $3590,x				; misc
		STZ $35A0,x				; misc
		STZ $35B0,x				; misc
		STZ $35C0,x				; misc
	;	STZ $35D0,x				; extra bits
	;	STZ $35E0,x				; extra byte/prop 1
	;	STZ $35F0,x				; extra byte/prop 2

		.BWRAM					;\
		STZ !SpriteStasis,x			; |
		STZ !SpritePhaseTimer,x			; |
		LDA #$03 : STA !SpriteGravity,x		; |
		LDA #$01 : STA !SpriteFloat,x		; |
		LDA #$40 : STA !SpriteFallSpeed,x	; |
		STZ !SpriteVectorY,x			; |
		STZ !SpriteVectorX,x			; | PhysicsPlus registers
		STZ !SpriteVectorAccY,x			; |
		STZ !SpriteVectorAccX,x			; |
		STZ !SpriteVectorTimeY,x		; |
		STZ !SpriteVectorTimeX,x		; |
		STZ !SpriteExtraCollision,x		; |
		STZ !SpriteDeltaX,x			; |
		STZ !SpriteDeltaY,x			;/

		.DynamicList
		PHX
		PHP
		REP #$30
		TXA
		ASL A : TAX
		LDA !DynamicList+0,x : TRB !DynamicTile+0
		STZ !DynamicList+0,x
		PLP
		PLX
		RTL



	SetSpriteTables:
		LDA !ExtraBits,x				;\ see if custom
		AND.b #!CustomBit : BNE .Custom			;/

		.Vanilla
		PHY
		PHP
		SEP #$30
		STZ !ExtraProp1,x				;\ clear extra props
		STZ !ExtraProp2,x				;/
		JSL !LoadTweakers				; load vanilla tweakers
		LDA !SpriteTweaker5,x				;\
		AND #$07 : BEQ ..nopalset			; |
		PHY						; |
		PHX						; |
		PHP						; |
		CLC : ADC #$09					; |
		SEP #$30					; |
		JSL LoadPalset					; | load palset
		LDX $0F						; |
		LDA !Palset_status,x				; |
		PLP						; |
		PLX						; |
		PLY						; |
		ASL A						; |
		..nopalset					;/
		STA !SpriteOAMProp,x				; > CCC bits
		PLP
		PLY
		RTL

		.Custom
		PHB : PHK : PLB
		PHY
		PHP
		REP #$30					;\
		LDA !SpriteNum,x				; |
		AND #$00FF					; |
		ASL #2 : STA $00				; | index = num * 12
		ASL A : ADC $00					; |
		TAY						; |
		SEP #$20					;/
		LDA SpriteData+$00,y : STA !SpriteTweaker1,x	;\
		LDA SpriteData+$01,y : STA !SpriteTweaker2,x	; |
		LDA SpriteData+$02,y : STA !SpriteTweaker3,x	; | tweaker bytes
		LDA SpriteData+$03,y : STA !SpriteTweaker4,x	; |
		LDA SpriteData+$05,y : STA !SpriteTweaker6,x	; |
		LDA SpriteData+$04,y : STA !SpriteTweaker5,x	;/> 5 last
		AND #$07 : BEQ ..nopalset			;\
		PHY						; |
		PHX						; |
		PHP						; |
		CLC : ADC #$09					; |
		SEP #$30					; |
		JSL LoadPalset					; | load palset
		LDX $0F						; |
		LDA !Palset_status,x				; |
		PLP						; |
		PLX						; |
		PLY						; |
		ASL A						; |
		..nopalset					;/
		STA !SpriteOAMProp,x				; > CCC bits

		REP #$20					;\
		LDA SpriteData+$06,y : STA $00			; | INIT pointer
		SEP #$20					; |
		LDA SpriteData+$08,y : STA $02			;/
		PLP
		PLY
		PLB
		RTL


	ExBubbleFix:
		LDA !WaterLevel : BNE .029F2A			; check for water level
		LDA !3DWater : BEQ .029F17			; check for 3D water
		LDA !IceLevel : BNE .029F17			; no water if frozen
		LDA !Ex_YHi,x : XBA				;\
		LDA !Ex_YLo,x					; |
		REP #$20					; | check if below water
		CMP !Level+2					; |
		SEP #$20					; |
		BCS .029F2A					;/

	.029F17	JML $029F17					; not in water (checks map16 after this)
	.029F2A	JML $029F2A					; in water




print "Fe26 sprite engine ends at $", pc, "."


