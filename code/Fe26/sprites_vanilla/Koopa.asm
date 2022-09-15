

	!KickTimer1		= $BE
	!KickTimer2		= $3280
	!SlideTimer		= $3290

	!RainbowForm		= $32A0
	!YellowTurnTimer	= $32B0		; while set, koopa can't AI turn, only set when touching a wall

	!ShakeTimer		= $32D0

	!DancerMove		= $3410
	!KoopaHomeX		= $3420

	!WingTimer		= $3500
	!YellowParaTarget	= $3510



	INIT:
		LDA !SpriteXLo,x : STA !KoopaHomeX,x				; back up starting X coord

		LDA !RNG
		AND #$80 : STA !YellowParaTarget,x

		.LockDir
		LDA !SpriteNum,x
		CMP #$0A : BEQ ..lock
		CMP #$0B : BNE ..done
		..lock
		STZ !SpriteDir,x
		..done

		LDA !ExtraBits,x
		AND #$04 : BEQ .Return

		LDA !RNG							;\ start with a random move
		AND #$01 : STA !DancerMove,x					;/
		LDA !RNG							;\
		AND #$02							; | start in a random direction
		LSR A								; |
		STA !SpriteDir,x						;/

		.Return
		RTS



	MAIN:
		.Parakoopa
		LDA !SpriteNum,x
		CMP #$08 : BCC ..done
		JMP Parakoopa
		..done


		LDA !SpriteStatus,x
		CMP #$08 : BCS .Process
		JMP Animation

		.Process
		%decreg(!YellowTurnTimer)					; used to prevent spam turn
		LDA !SpriteXSpeed,x : BNE +					; must stand still to decrement windup timer
		%decreg(!KickTimer1) : BEQ +					; decrement windup timer
		LDA !ExtraBits,x						;\
		AND #$04 : BEQ +						; |
		REP #$20							; | if extra bit is set, wait for there to be a player in sight
		LDA #DATA_KickerSight : JSL LOAD_HITBOX_E8			; |
		JSL PlayerContact : BCC ++					;/
		STZ !KickTimer1,x						;\ kick instantly when a player is seen
	++	INC !KickTimer1,x						;/
	+	%decreg(!KickTimer2)						; decrement kick timer

		.SlideTimer
		LDA !SpriteBlocked,x
		AND #$04 : BEQ ..done
		LDA !SlideTimer,x : BEQ ..done
		DEC !SlideTimer,x : BNE ..done
		..hop
		LDA !SpriteTweaker5,x
		AND #$F8 : STA !SpriteYSpeed,x
		STZ !SpriteBlocked,x
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		..done


	Physics:
		LDA !SpriteHP,x : BNE +
		LDA !ShakeTimer,x : BEQ .Process
		CMP #$01 : BNE .Shaking
		LDA #$08 : STA !SpriteStatus,x
		JSL SUB_HORZ_POS
		TYA : STA !SpriteDir,x
		TXY								;\
		LDX !SpriteNum,y						; | reload tweaker 6
		LDA VanillaTweakerData_Tweaker6,x : STA !SpriteTweaker6,y	; |
		TYX								;/
		LDA !GFX_Koopa_tile : STA !SpriteTile,x
		LDA !GFX_Koopa_prop : STA !SpriteProp,x
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x

		.Shaking
		LDA !SpriteNum,x
		CMP #$07 : BNE .Process
		STA !RainbowForm,x
		LDA !SpriteTweaker3,x						;\ rainbow shell can't be picked up
		ORA #$10 : STA !SpriteTweaker3,x				;/
		BRA .Process

	+
	-	JMP Animation

		.Process
		LDA !SpriteStatus,x
		CMP #$08 : BEQ .Normal
		CMP #$09 : BEQ .Shell
		CMP #$0A : BNE -

		.Kicked
		LDA !RainbowForm,x : BEQ ..normal
		TXA
		EOR $14
		AND #$06
		CLC : ADC #$04
		STA !SpriteOAMProp,x
		JSL SUB_HORZ_POS
		LDA DATA_XSpeedShell,y : JSL AccelerateX_Unlimit1
		BRA .Shell
		..normal
		LDA #$00
		LDY !SpriteXSpeed,x : BEQ +
		BPL $01 : INC A
		STA !SpriteDir,x
	+	LDY !SpriteDir,x
		LDA DATA_XSpeedShell,y : STA !SpriteXSpeed,x

		.Shell
		LDA #$03 : STA !SpriteTweaker6,x
		JSL APPLY_SPEED
		LDA !SpriteBlocked,x						;\
		AND #$04 : BEQ ..air						; | find landing frame
		AND $F4 : BNE ..ground						;/
		LDA !SpriteXSpeed,x						;\
		CMP #$80							; |
		ROR A : STA !SpriteXSpeed,x					; |
		LDA !SpriteYSpeed,x						; |
		CMP #$20							; | bounce
		BPL $02 : LDA #$00						; > BCC can cause a bug
		LSR #2								; |
		EOR #$FF : INC A						; |
		STA !SpriteYSpeed,x						;/
		..air
		JMP .Done
		..ground
		LDA !RainbowForm,x : BNE ..air
		LDA !SpriteXSpeed,x : BNE ..friction
		STZ !SpriteKillCount,x						; reset kill count when still on ground
		..friction
		JSL AccelerateX_Friction2
		JMP .Done


		.Normal
		LDY !SpriteNum,x
		CPY #$04 : BCC ..notdancer
		LDA !ExtraBits,x
		AND #$04 : BEQ ..notdancer
		JMP DancerPhysics
		..notdancer

		LDA !RainbowForm,x : BEQ ..norainbow
		LDA #$0A : STA !SpriteStatus,x
		BRA .Shell
		..norainbow
		LDA !SpriteBlocked,x
		AND #$04 : BNE $03 : JMP ..move
		CPY #$04 : BCS ..noslope
		TYX								;\
		LDA VanillaTweakerData_Tweaker6,x				; | reload tweaker 6
		LDX !SpriteIndex						; |
		STA !SpriteTweaker6,x						;/
		LDA !SpriteSlope,x : BEQ ..noslope				;\
		CLC : ADC #$04							; |
		TAY								; |
		LDA !SlideTimer,x : BNE +					; | handle slope
		LDA DATA_SlopeTrigger,y : BEQ ..noslope				; |
	+	LDA DATA_SlopeSpeed,y : JSL AccelerateX_Unlimit2		; |
		LDA #$1F : STA !SlideTimer,x					; |
		..noslope							;/
		LDA !SpriteAnimIndex,x
		CMP #$04 : BCC ..canwalk
		LDA #$00 : BRA ..setspeed
		..canwalk
		LDY !SpriteDir,x
		LDA !SlideTimer,x : BEQ ..noslide
		..friction
		LDA !SpriteXSpeed,x : BEQ ..move
		JSL FrictionSmoke						; > smoke particles
		LDA !KickTimer1,x : BEQ ..sliding
		JSL AccelerateX_Friction2 : BRA ..move
		..sliding
		LDA !SpriteTweaker6,x						;\ ignore ledges when sliding
		AND.b #$C0^$FF : STA !SpriteTweaker6,x				;/
		JSL AccelerateX_Friction1 : BRA ..move
		..noslide

		LDA !SpriteNum,x						;\
		CMP #$06 : BEQ ..fastforward					; | blue and yellow big koopas are fast, green and red are slow
		CMP #$07 : BEQ ..fastchase					;/
		CMP #$02 : BEQ ..kicker						; kicker is fast but can also use friction
		CMP #$03 : BEQ ..fastforward					; green and red shelless are slow, yellow is fast
		..slow
		LDA DATA_XSpeedSlow,y : BRA ..setspeed
		..kicker
		LDA !KickTimer1,x
		ORA !KickTimer2,x
		BNE ..friction
		BRA ..fastforward
		..fastchase
		LDA !YellowTurnTimer,x : BNE ..fastforward
		LDA !SpriteAnimIndex,x
		CMP #$04 : BEQ ..fastforward
		JSL SUB_HORZ_POS
		TYA
		CMP !SpriteDir,x : BEQ ..fastforward
		LDA #$04 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..fastforward
		LDA DATA_XSpeedFast,y
		..setspeed
		STA !SpriteXSpeed,x
		..move
		JSL APPLY_SPEED


		.CheckTurn
		LDA !SpriteNum,x						;\ check for big koopa
		CMP #$04 : BCC .Done						;/
		LDA !SpriteAnimIndex,x						;\ can turn in turning anim only
		CMP #$04 : BNE ..cantturn					;/
		..maybeturn							;\
		LDA !SpriteAnimTimer,x						; |
		CMP #$08 : BNE .Done						; | turn at time = 8
		LDA !SpriteDir,x						; |
		EOR #$01 : STA !SpriteDir,x					; |
		LDA #$20 : STA !YellowTurnTimer,x				; |
		BRA .Done							;/
		..cantturn							;\
		LDA !SpriteBlocked,x						; | check if touching wall
		AND #$03 : BEQ .Done						; | if not in turning anim, enter it
		LDA #$04 : STA !SpriteAnimIndex,x				; |
		STZ !SpriteAnimTimer,x						;/

		.Done


	ShellInteraction:
		LDA !KickTimer2,x : BNE +					; can NOT interact during kick
		LDA !SlideTimer,x : BNE +					; can't jump or fuse while sliding
		LDA !SpriteNum,x						;\ shelless can look for shells
		CMP #$04 : BCC .LookForShell					;/
	+	JMP .Done

		.LookForShell
		STZ $0F								; clear interact with status A flag
		CMP #$02 : BNE ..notkicker					; > kicker check
		INC $0F								; set interact with status A flag
		BRA ..sight
		..notkicker
		LDA !SpriteBlocked,x						;\ body if in air, sight if on ground
		AND #$04 : BNE ..sight						;/
		..body								;\
		JSL GetSpriteClippingE8						; | body hitbox
		LDA #$03 : STA $EE						; |
		BRA ..process							;/
		..sight								;\
		REP #$20							; | sight box
		LDA.w #DATA_ShellSight : JSL LOAD_HITBOX_E8			;/
		..process							;\
		LDX #$0F							; | loop over all sprites
		..loop								;/
		CPX !SpriteIndex : BEQ ..next					; can't interact with self
		LDA !SpriteStatus,x						;\
		CMP #$09 : BEQ ..ok						; | must be item or kicked
		LDY $0F : BEQ ..next						; > can only interact with status A if kicker flag is set
		CMP #$0A : BNE ..next						; |
		..ok								;/
		LDA !ExtraBits,x						;\
		AND #$08 : BNE ..next						; | must be koopa
		LDA !SpriteNum,x						; |
		CMP #$08 : BCS ..next						;/
		JSL GetSpriteClippingE0						;\ check for contact
		JSL CheckContact : BCS ..interact				;/
		..next								;\ loop
		DEX : BPL ..loop						;/
		LDX !SpriteIndex						; reload sprite index
		JMP .Done

		..interact
		TXY								;\ indexes
		LDX !SpriteIndex						;/
		LDA !SpriteNum,x						;\ kicker check
		CMP #$02 : BNE ..nokick						;/
		..kicker
		LDA !SpriteDir,x
		REP #$20
		BNE +
		LDA $E8 : BRA ++
	+	LDA $E8
		SEC : SBC #$000E
	++	SEP #$20
		STA !SpriteXLo,y
		XBA : STA !SpriteXHi,y
		LDA !KickTimer1,x : BNE ..kick
		..windup							;\
		LDA.w !SpriteXSpeed,y : STA !SpriteXSpeed,x			; |
		LDA #$09 : STA !SpriteStatus,y					; | start windup
		LDA #$1F : STA !KickTimer1,x					; |
		BRA .Done							;/
		..kick								;\
		LDA !SpriteXSpeed,x : STA.w !SpriteXSpeed,y			; |
		LDA !SpriteXSub,x : STA !SpriteXSub,y				; > sync sub
		LDA !KickTimer1,x						; |
		CMP #$01 : BNE .Done						; > only kick on last frame
		LDA #$03 : STA !SpriteAnimIndex,x				; |
		STZ !SpriteAnimTimer,x						; |
		LDA #$14 : STA !KickTimer2,x					; |
		PHY								; | process kick
		LDY !SpriteDir,x						; |
		LDA DATA_XSpeedShell,y						; |
		PLY								; |
		STA.w !SpriteXSpeed,y						; |
		LDA #$0A : STA !SpriteStatus,y					; |
		BRA .Done							;/

		..nokick							;\
		LDA !SpriteBlocked,x						; | check ground/air
		AND #$04 : BNE ..jump						;/
		..fusion							;\
		STZ !SpriteStatus,x						; |
		LDA #$06 : STA !SpriteAnimIndex,y				; | fuse if in air
		LDA #$00 : STA !SpriteAnimTimer,y				; |
		LDA #$1F : STA !ShakeTimer,y					; |
		RTS								;/
		..jump								;\
		LDA !SpriteTweaker5,x						; |
		AND #$F8 : STA !SpriteYSpeed,x					; | jump if on ground
		LDA #$1F : STA !SpriteDisSprite,x				; |
		STZ !SpriteBlocked,x						;/

		.Done


	Interaction:
		JSL GetSpriteClippingE8

		.Projectiles
		JSL ThrownItemContact : BCS ..die
		LDA !RainbowForm,x : BNE ..nocontact				; rainbow shell immune to fireballs
		JSL FireballContact_Destroy : BCC ..nocontact
		..die
		LDA #$02 : STA !SpriteStatus,x
		LDA !SpriteNum,x
		CMP #$04 : BCC +
		JMP .Body_reloadshellgfx
	+
	-	JMP .Done
		..nocontact

		.Hitbox
		JSL P2Attack : BCC ..nocontact
		LDA !SpriteStatus,x
		CMP #$09 : BCC ..normal
		LDA !RainbowForm,x : BNE -
		JMP .Body_turntoshell
		..normal
		LDA !SpriteNum,x
		CMP #$04 : BCS .Body_big
		BRA .Projectiles_die
		..nocontact

		.Body
		LDA !SpriteStatus,x
		CMP #$08 : BEQ ..normal
		CMP #$0A : BNE -

		..kicked
		REP #$20
		LDA $EA
		CLC : ADC $EE
		STA $EA
		LDA #$0001 : STA $EE
		SEP #$20
		LDA !SpriteDisP1,x : BNE -
		JSL PlayerContact : BCC -
		BRA +

		..normal
		LDA !SlideTimer,x : BEQ ..standard				;\
		LDA !SpriteDisP1,x : BNE -					; |
		JSL PlayerContact : BCC -					; |
		LDY !SpriteSlope,x : BEQ ..die					; |
	+	JSL HurtPlayers							; | if sliding, die if touched on flat ground, hurt player on slope
		JMP ..nocontact							; |
		..die								; |
		JSL P2Kick							; > kick frame
		LDA #$02 : STA !SpriteStatus,x					; |
		BRA ..nocontact							;/
		..standard							;\ otherwise, use standard interaction
		JSL P2Standard : BEQ ..nocontact				;/

		LDA !RainbowForm,x : BNE ..nocontact				; just bounce off of rainbow shell
		LDA !SpriteStatus,x
		CMP #$0A : BEQ ..shell

		LDA !SpriteNum,x						;\ check size
		CMP #$04 : BCS ..big						;/
		INC !SpriteHP,x							;\ smush
		BRA ..nocontact							;/

		..big
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		LDA !SpriteNum,x
		SEC : SBC #$04
		CLC : JSL SpawnSprite : BMI ..shell
		TYX
		LDA #$08 : STA !SpriteStatus,x
		LDA #$FF
		LDY !SpriteNum,x
		CPY #$02
		BNE $02 : LDA #$32
		STA !SlideTimer,x
		LDA #$08 : JSL IFrames						; i-frames + index mem
		LDA #$1E : STA !SpriteDisSprite,x				; can't interact with sprites for a bit
		JSL SUB_HORZ_POS
		TYA
		EOR #$01 : STA !SpriteDir,x
		TAY
		LDA DATA_XSpeedShell,y : STA !SpriteXSpeed,x
		LDX !SpriteIndex
		..shell
		STZ !SpriteXSpeed,x
		STZ !ShakeTimer,x
		..turntoshell
		LDA #$09 : STA !SpriteStatus,x
		..reloadshellgfx
		LDA !GFX_Shell_tile : STA !SpriteTile,x
		LDA !GFX_Shell_prop : STA !SpriteProp,x
		..nocontact


		.Done


	Animation:
		LDY !SpriteStatus,x
		CPY #$09 : BCS .Shell
		CPY #$02 : BNE .Normal

		.Dead
		LDA #$05 : JMP .SetAnim						; 5 is the death frame for all forms

		.Normal
		LDA !SpriteNum,x
		CMP #$04 : BCC .Small
		LDA !ExtraBits,x
		AND #$04 : BNE .DancerGraphics
		JMP .Done

		.DancerGraphics
		LDA !DancerMove,x
		LSR A : BCS ..processanim
		..walking
		LDA !SpriteAnimIndex,x
		CMP #$07 : BCS ..processanim
		CMP #$04 : BCC ..processanim
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..processanim
		REP #$20
		LDA.w #ANIM_Dancer : JSL UPDATE_ANIM
		..checkshell
		LDA !SpriteAnimIndex,x
		CMP #$05 : BEQ ..shell
		CMP #$09 : BCC ..done
		..shell
		LDA !GFX_Shell_tile : STA !SpriteTile,x
		LDA !GFX_Shell_prop : STA !SpriteProp,x
		..done
		JMP Graphics_CheckAnim


		.Shell
		LDA !ShakeTimer,x : BNE .Done
		CPY #$0A : BNE ..still						; 9 and B are both still, A is moving
		LDA !SpriteXSpeed,x : BEQ ..still
		LDA !SpriteAnimIndex,x
		CMP #$04 : BCC .Done
		LDA #$00 : BRA .SetAnim
		..still
		LDA #$04 : BRA .SetAnim

		.Small
		LDA !SpriteHP,x : BEQ ..alive					;\
		LDA #$04							; |
		CMP !SpriteAnimIndex,x						; | death clause
		BEQ .Done							; |
		BRA .SetAnim							; |
		..alive								;/
		LDA !KickTimer2,x : BNE .Done					;\ wait for kick
		LDA !KickTimer1,x : BNE ..0					;/
		LDA !SlideTimer,x : BNE ..slide					; check slide
		LDA !SpriteAnimIndex,x						;\
		CMP #$02 : BCC .Done						; | walk check
	..0	LDA #$00 : BRA .SetAnim						;/
		..slide								;\
		LDA !SpriteAnimIndex,x						; | slide anim is stuck in first frame while still moving
		CMP #$02 : BCS .Done						; |
		LDA #$02							;/

		.SetAnim
		STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		.Done



	Graphics:
		.UpdateTile
		LDA !SpriteHP,x : BEQ ..done
		LDA !GFX_SmushedKoopa_tile : STA !SpriteTile,x
		LDA !GFX_SmushedKoopa_prop : STA !SpriteProp,x
		..done

		LDA !SpriteStatus,x
		CMP #$02 : BEQ .Shell
		CMP #$09 : BCS .Shell
		LDA !SpriteNum,x
		CMP #$04 : BCS .Big
		CMP #$02 : BEQ .Kicker

		.Small
		REP #$20
		LDA.w #ANIM_Shelless : BRA .Draw

		.Kicker
		REP #$20
		LDA.w #ANIM_Kicker : BRA .Draw

		.Shell
		REP #$20
		LDA.w #ANIM_Shell : BRA .Draw

		.Big
		REP #$20
		LDA.w #ANIM_Koopa
		.Draw
		JSL UPDATE_ANIM
		.CheckAnim
		LDA !SpriteAnimIndex,x : BMI DESPAWN

		LDA !SpriteStatus,x
		CMP #$0B : BEQ .Carried
		JSL LOAD_PSUEDO_DYNAMIC
		RTS

		.Carried
		JSL SETUP_CARRIED
		JSL DRAW_CARRIED
		RTS

	DESPAWN:
		STZ !SpriteStatus,x
		RTS



	DancerPhysics:
		LDA !SpriteAnimIndex,x
		CMP #$07 : BCC .RunPointer
		LDA $14
		AND #$7F : BEQ .Reset
		LDY !SpriteDir,x
		JMP .SetXSpeed

		.Reset
		STZ !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		JMP .RollNewMove


		.RunPointer
		LDA !DancerMove,x						;\
		..A								; | go to pointer
		ASL A : TAX							; |
		JMP (.Ptr,x)							;/

		.Ptr
		dw .WalkOut
		dw .Jump
		dw .WalkIn

	.WalkOut
		LDX !SpriteIndex						; restore X
		LDA !DancerMove,x : BMI ..main					;\
		..init								; |
		ORA #$80 : STA !DancerMove,x					; | init: walk for 16 frames (apparently this works out to 16...?)
		LDA #$1A : STA $32D0,x						; |
		..main								;/
		LDA $32D0,x : BNE .WalkSpeed					; see if timer is up (otherwise walk speed)

		.TurnAround
		LDA !SpriteDir,x						;\
		EOR #$01 : STA !SpriteDir,x					; |
		LDA !RNG							; | turn around, get a random next move, and loop
		AND #$01							; |
		INC A								; |
		STA !DancerMove,x : BRA .RunPointer_A				;/

		.WalkSpeed
		LDY !SpriteDir,x						;\ walk speed
		JMP .SetXSpeed							;/

	.Jump
		LDX !SpriteIndex						; restore X
		LDA !DancerMove,x : BMI ..main					;\
		..init								; | init
		ORA #$80 : STA !DancerMove,x					; |
		LDA #$05 : STA !SpriteAnimIndex,x				; > set anim
		STZ !SpriteAnimTimer,x						; |
		STZ !SpriteXSub,x						; > clear sub pixels
		STZ !SpriteYSub,x						; |
		STZ !SpriteBlocked,x						; > clear blocked status
		LDA #$E0 : STA !SpriteYSpeed,x					;/> set Y speed to start jump
		LDY #$00							;\
		LDA !SpriteXLo,x						; |
		CMP !KoopaHomeX,x						; | move to home
		BPL $01 : INY							; |
		TYA : STA !SpriteDir,x						;/
		..jump								;\
		LDY !SpriteDir,x						; | jump speed
		INY #2								; |
		BRA .SetXSpeed							;/
		..main
		LDA !SpriteBlocked,x						;\ see if landed
		AND #$04 : BEQ ..jump						;/

		LDA !SpriteXLo,x						;\
		SEC : SBC !KoopaHomeX,x						; |
		INC A								; | if landing near starting area, fully reset movement
		CMP #$03 : BCC .FullReset					; |
		BRA .TurnAround							;/


	.WalkIn
		LDX !SpriteIndex						; restore X
		LDY #$00							;\
		LDA !SpriteXLo,x						; |
		CMP !KoopaHomeX,x						; | move to home
		BPL $01 : INY							; |
		TYA : STA !SpriteDir,x						;/

		LDA !SpriteXLo,x						;\ just walk if not at starting point
		CMP !KoopaHomeX,x : BNE .WalkSpeed				;/

		.FullReset
		LDA $14								;\
		AND #$7F : BEQ .RollNewMove					; |
		AND #$0F : STA !SpriteAnimTimer,x				; | make sure all dancers are synchronized
		LDA #$07 : STA !SpriteAnimIndex,x				; |
		BRA .SetXSpeed							;/

	.RollNewMove
		LDA !RNG							;\ get random direction
		AND #$01 : STA !SpriteDir,x					;/
		TAY								; Y = dir
		LDA !RNG							;\
		AND #$02							; | get new move
		LSR A								; |
		STA !DancerMove,x						;/

		.SetXSpeed
		LDA DATA_DancerXSpeed,y : STA !SpriteXSpeed,x			; X speed

		.GroundSpeed							;\
		LDA !SpriteBlocked,x						; |
		AND #$04 : BEQ ..done						; | ground speed
		JSL GroundSpeed							; |
		..done								;/

		LDA !SpriteAnimIndex,x						;\ anim 5 = no speed
		CMP #$05 : BEQ .Done						;/
		CMP #$07 : BCC .Normal						; anim 0-6 (except 5) = normal speed
		.Clear								;\
		STZ !SpriteYSpeed,x						; | anim 7+ = clear speed
		STZ !SpriteXSpeed,x						;/
		.Normal								;\ move
		JSL APPLY_SPEED							;/

		.Done
		JMP Interaction




	Parakoopa:
		AND #$07
		ASL A
		CMP.b #.Ptr_end-.Ptr
		BCC $02 : LDA #$00
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Green
		dw .Blue
		dw .RedVert
		dw .RedHorz
		dw .Yellow
		..end

	.Blue
		LDX !SpriteIndex					; reload sprite index
		LDA #$02 : STA !SpriteGravity,x				; reduced gravity
		LDA #$30 : STA !SpriteFallSpeed,x			; reduced fall speed

		LDA !SpriteAnimIndex,x : BEQ ..jump
		CMP #$02 : BNE ..nojump
		..jump
		LDA !SpriteTweaker5,x
		AND #$F8 : STA !SpriteYSpeed,x
		STZ !SpriteBlocked,x
		LDY !SpriteAnimTimer,x
		LDA DATA_BlueWingTakeoff-9,y : STA !WingTimer,x
		BRA ..end
		..nojump

		LDY !SpriteDir,x					;\ set x speed
		LDA DATA_XSpeedSlow,y : STA !SpriteXSpeed,x		;/
		LDA !SpriteBlocked,x
		AND #$04 : BNE ..ground					; jump when touching ground

		..freefall
	LDA !WingTimer,x
	AND #$18
	LDY !SpriteYSpeed,x : BMI ++
	CMP #$00 : BEQ +
	BRA ++++

++	CMP #$18 : BEQ +
+++	INC !WingTimer,x
++++	INC !WingTimer,x
	+
		LDA !SpriteAnimIndex,x : BEQ ..move
		CMP #$02 : BEQ ..move
		DEC !SpriteAnimTimer,x
		BRA ..move

		..ground
		LDA !SpriteAnimIndex,x
		INC A
		AND #$03 : STA !SpriteAnimIndex,x
		LDA #$08 : STA !SpriteAnimTimer,x

		..move
		JSL APPLY_SPEED
		..end
		JMP .TurnAnim


	.Green
		LDX !SpriteIndex
		LDY !SpriteDir,x
		LDA DATA_XSpeedFast,y : STA !SpriteXSpeed,x
		LDY !WingTimer,x
		LDA DATA_ParakoopaSine,y : JSL AccelerateY_Unlimit1
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		JMP .TurnAnim


	.RedVert
		LDX !SpriteIndex
		LDA $32D0,x : BNE ..move
		LDA #$88 : STA $32D0,x
		LDA #$04 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..move
		LDY !SpriteDir,x
		LDA DATA_XSpeedFast,y : JSL AccelerateY_Unlimit1
		JSL APPLY_SPEED_Y
		JMP .TurnAnim


	.RedHorz
		LDX !SpriteIndex
		LDA $32D0,x : BNE ..move
		LDA #$88 : STA $32D0,x
		LDA #$04 : STA !SpriteAnimIndex,x
		STZ !SpriteAnimTimer,x
		..move
		LDY !SpriteDir,x
		LDA DATA_XSpeedFast,y : JSL AccelerateX_Unlimit1
		LDY !WingTimer,x
		LDA DATA_ParakoopaSine,y : JSL AccelerateY_Unlimit1
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y
		BRA .TurnAnim


	.Yellow
		LDX !SpriteIndex					; reload sprite index
		LDA #$20 : STA $0F					;\
		LDY !YellowParaTarget,x : JSL TARGET_PLAYER		; |
		LDA $04 : JSL AccelerateX_Unlimit1			; | update speeds, targeting a player
		LDY !WingTimer,x					; |
		LDA DATA_ParakoopaSine,y				; |
		CLC : ADC $06 : JSL AccelerateY_Unlimit1		;/
		LDA !SpriteAnimIndex,x					;\
		CMP #$04 : BEQ ..move					; |
		LDY !YellowParaTarget,x					; |
		JSL SUB_HORZ_POS_Target					; | turn when target is behind
		TYA							; |
		CMP !SpriteDir,x : BEQ ..move				; |
		LDA #$04 : STA !SpriteAnimIndex,x			; |
		STZ !SpriteAnimTimer,x					;/
		..move							;\ must be moving down to glide
		LDA $06 : BMI ..noglide					;/
		CMP #$10 : BCC ..glide2					;\
		CMP #$18 : BCC ..flapx					; | glide 1 if target down speed > 0x18
		..glide1						; |
		LDA #$08 : BRA ..setglide				;/
		..glide2						;\
		LDA !SpriteXSpeed,x					; |
		CLC : ADC #$10						; | glide 2 if target down speed > 0x10 and |current x speed| > 0x10
		CMP #$20 : BCC ..flapx					; |
		LDA #$00						;/
		..setglide						;\
		STA !WingTimer,x					; | set glide
		BRA ..noflap						;/
		..noglide						;\ if moving down and trying to move up, fast flap
		BIT !SpriteYSpeed,x : BPL ..fastflap			;/
		CMP #$F0 : BCC ..fastflap				; if target y speed is faster than 0x10 up, fast flap
		..flapx							;\
		LDA $04							; | if trying to turn around, fast flap
		EOR !SpriteXSpeed,x : BPL ..normalflap			;/
		..fastflap						;\ fast flap: +2
		INC !WingTimer,x					;/
		..normalflap						;\ normal flap: +1
		INC !WingTimer,x					;/
		..noflap						;\
		JSL APPLY_SPEED_X					; | apply speeds
		JSL APPLY_SPEED_Y					;/


	.TurnAnim
		LDA !SpriteAnimIndex,x
		CMP #$04 : BNE ..done
		LDA !SpriteAnimTimer,x
		CMP #$08 : BNE ..done
		LDA !SpriteDir,x
		EOR #$01 : STA !SpriteDir,x
		..done


	.Interaction
		JSL GetSpriteClippingE8
		JSL InteractAttacks : BCS ..hurt
		JSL P2Standard : BEQ ..nocontact
		..hurt
		LDY !SpriteNum,x
		LDA DATA_ParakoopaColor-8,y : STA !SpriteNum,x
		STZ !ExtraBits,x
		JSL !LoadTweakers
		LDA #$40 : STA !SpriteFallSpeed,x
		LDA #$03 : STA !SpriteGravity,x


		LDA #$F8
		STA $00
		STA $01
		STA $02
		LDA #$E0 : STA $03
		STZ $04
		LDA #$18 : STA $05
		LDA !GFX_Wings_tile
		INC #2 : STA $06
		LDA !GFX_Wings_prop
		ORA !SpriteOAMProp,x
		ORA #$90 : STA $07
		LDA.b #!prt_spritepart : JSL SpawnParticle
		LDA #$08
		STA $00
		STA $02
		LDA $07
		AND #$10^$FF
		ORA #$80 : STA $07
		LDA.b #!prt_spritepart : JSL SpawnParticle
		JMP Animation
		..nocontact


	.Graphics
		REP #$20
		LDA.w #ANIM_Koopa : JSL UPDATE_ANIM
		JSL LOAD_PSUEDO_DYNAMIC

		LDA !SpriteNum,x
		CMP #$09 : BEQ ..drawwings
		CMP #$0C : BEQ ..drawwings
		..sync
		LDA !SpriteAnimIndex,x
		ASL #3 : STA !WingTimer,x
		..drawwings


		LDA !GFX_Wings_tile : STA !SpriteTile,x
		LDA !GFX_Wings_prop : STA !SpriteProp,x
		LDA !WingTimer,x
		LSR #3
		AND #$03
		ASL A : TAY
		REP #$20
		LDA ANIM_WingsFront,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC_p3

		LDA !WingTimer,x
		LSR #3
		AND #$03
		ASL A : TAY
		REP #$20
		LDA ANIM_WingsBack,y : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC


		RTS




	DATA:
	.XSpeedSlow
		db $08,$F8

	.XSpeedFast
		db $10,$F0

	.XSpeedShell
		db $38,$C8

	.SlopeTrigger
		db $01,$01,$00,$00,$00,$00,$00,$01,$01		; which slopes the sprite will lose its footing on
	.SlopeSpeed
		db $E0,$D0,$E0,$E0,$00,$20,$20,$30,$20

	.DancerXSpeed
		db $F0,$10	; walk (backwards)
		db $E0,$20	; jump (backwards)

	.ShellSight
		dw $FFFE,$0000 : db $02,$10

	.KickerSight
		dw $FF40,$0004 : db $C0,$1C

	.ParakoopaColor
		db $04,$06,$05,$05,$07

	.ParakoopaSine
		db $10,$10,$10,$10,$10,$10,$10,$10
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
		db $00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00

	.BlueWingTakeoff
		db $08,$08,$08,$08,$08,$10,$18


	ANIM:
	.Koopa
		dw .Walk0	: db $10,$01	; 00
		dw .Walk1	: db $10,$02	; 01
		dw .Walk0	: db $10,$03	; 02
		dw .Walk2	: db $10,$00	; 03
		dw .Turn	: db $10,$00	; 04

		.Walk0
		dw $0008
		db $22,$00,$F0,$00
		db $22,$00,$00,$04

		.Walk1
		dw $0008
		db $22,$00,$EF,$00
		db $22,$00,$FF,$06

		.Walk2
		dw $0008
		db $22,$00,$EF,$00
		db $22,$00,$FF,$08

		.Turn
		dw $0008
		db $22,$00,$F0,$02
		db $22,$00,$00,$0A

		.TurnX
		dw $0008
		db $62,$00,$F0,$02
		db $62,$00,$00,$0A



	.Shelless
		dw .SmallWalk0	: db $10,$01	; 00
		dw .SmallWalk1	: db $10,$00	; 01
		dw .SmallSlide0	: db $08,$03	; 02
		dw .SmallSlide1	: db $08,$02	; 03
		dw .Dead	: db $18,$FF	; 04 -> invalid (despawn)
		dw .KnockedOut	: db $FF,$05	; 05

	.Kicker
		dw .KickerWalk0	: db $10,$01	; 00
		dw .KickerWalk1	: db $10,$00	; 01
		dw .KickerSlide	: db $FF,$02	; 02
		dw .KickerKick	: db $10,$00	; 03
		dw .Dead	: db $18,$FF	; 04 -> invalid (despawn)
		dw .KnockedOut	: db $FF,$05	; 05

		.Dead
		.Shake0
		.Shell0
		.KickerWalk0
		.SmallWalk0
		dw $0004
		db $22,$00,$00,$00

		.KickerWalk1
		.SmallWalk1
		dw $0004
		db $22,$00,$FE,$02

		.KickerSlide
		.SmallSlide0
		dw $0004
		db $22,$00,$00,$04

		.KickerKick
		.SmallSlide1
		dw $0004
		db $22,$00,$00,$06

		.KnockedOut
		dw $0004
		db $A2,$00,$00,$00


	.Shell
		dw .Shell0	: db $04,$01	; 00
		dw .Shell1	: db $04,$02	; 01
		dw .Shell0X	: db $04,$03	; 02
		dw .Shell2	: db $04,$00	; 03
		dw .Shell0	: db $FF,$04	; 04
		dw .DeadShell	: db $FF,$05	; 05
		dw .Shake0	: db $01,$07	; 06
		dw .Shake1	: db $01,$08	; 07
		dw .Shake0	: db $01,$09	; 08
		dw .Shake2	: db $01,$06	; 09

		.Shell1
		dw $0004
		db $22,$00,$00,$02

		.Shell2
		dw $0004
		db $22,$00,$00,$04

		.Shell0X
		dw $0004
		db $62,$00,$00,$00

		.DeadShell
		dw $0004
		db $A2,$00,$00,$02

		.Shake1
		dw $0004
		db $22,$01,$00,$00

		.Shake2
		dw $0004
		db $22,$FF,$00,$00


	.Dancer
		dw .Walk0 : db $06,$01		; 00
		dw .Walk1 : db $06,$02		; 01
		dw .Walk0 : db $06,$03		; 02
		dw .Walk2 : db $06,$00		; 03
		dw .Turn : db $FF,$04		; 04
		dw .Shell1 : db $10,$06		; 05
		dw .Turn : db $FF,$06		; 06
		dw .Turn : db $10,$08		; 07
		dw .TurnX : db $10,$07		; 08


	.WingsFront
		dw ..TM0
		dw ..TM1
		dw ..TM0
		dw ..TM2
		dw ..TM0

		..TM0
		dw $0004
		db $22,$0C,$F4,$00

		..TM1
		dw $0004
		db $22,$0C,$F2,$02

		..TM2
		dw $0004
		db $22,$0C,$F9,$04


	.WingsBack
		dw ..TM0
		dw ..TM1
		dw ..TM0
		dw ..TM2
		dw ..TM0

		..TM0
		dw $0004
		db $62,$FE,$F3,$00

		..TM1
		dw $0004
		db $62,$FE,$F1,$02

		..TM2
		dw $0004
		db $62,$FE,$F8,$04
















