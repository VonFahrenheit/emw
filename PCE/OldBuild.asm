;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

namespace Kadaal

; --Build 4.0--
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;ALL DEFINES ARE FOUND HERE;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; pd--iiii format:
; p is priority. While set other sprites will not overwrite d or iiii.
; d is direction. Clear means horizontal, set means vertical. Vertical platforms don't apply Xspeed to player 2.
; iiii is the sprite index of the platform.

; --Sprite Table Usage--
; Always assume LoRAM unless specifically stated.
;
; $00C2,x	; Platform data. Format: pd--iiii. Cleared if no sprite contact is detected or when landing.
; $00D8,x	; Current position along Y-axis in level (low byte).
; $00E4,x	; Current position along X-axis in level (low byte).
; $00AA,x	; Current speed along Y-axis.
; $00B6,x	; Current speed along X-axis.
; $14C8,x	; Sprite status. Usually 08.
; $14D4,x	; Current position along Y-axis in level (high byte).
; $14E0,x	; Current position along X-axis in level (high byte).
; $1504,x	; Determines how long player 2 can hold jump to increase altitude
; $1510,x	; Used as a custom frame counter during jumps. It caps out at 5.
; $151C,x	; Index for YSPEED during jumps. Incremented twice each frame that $1510,x is zero.
; $1528,x	; Invincibility counter. While non-zero the hurt routine is not called.
; $1534,x	; Set at the end of a levitate, cleared upon touching the ground. Prevents levitating while set.
; $1540,x	; Cut scene timer. Controller input is loaded from $0F5E when this address is non-zero.
; $1570,x	; Kicked shell immunity timer. While non-zero player 2 does not interact with kicked shells.
; $157C,x	; Horizontal direction.
; $1588,x	; Sprite collision table.
; $15A0,x	; Sprite off screen flag (horizontal). While this is set, smoke sprites are not spawned by player 2.
; $1626,x	; Consecutive enemies killed in one jump. Cleared upon touching the ground.
; $186C,x	; Sprite off screen flag (vertical). While this is set, smoke sprites are not spawned by player 2.

; --Extra RAM Usage--
;
; $0058		; Contact flag. Set to 01 during GET_SPRITE_CLIPPING if sprite contact is detected.
; $0060		; Sprite index. Primarily used in sprite interaction. Also accessed by some hijacks and custom sprites.
; $0061		; Determines what tile(s) should be used in the graphics routine.
; $0062		; Timer for how long $61 will remain non-zero.
; $0063		; Copy of $157C,x. Used in the INIT routine.
; $0079		; Springboard timer. While non-zero holding B sets Yspeed to #$90.
; $007C		; Input for GENERATE_BLOCK.
; $0D9C		; Current HP.
; $0DA1		; Extra data used in shell power routines.
; $0DDB		; Swim speed. Set when player 2 pushes jump while swimming.
; $0DDC		; Swim timer. How long $0DDB will be used as Yspeed.
; $0F3A		; Index to map16 table.
; $0F42		; Used by player 1.
; $0F5E		; Cut scene controller input table. 16 bytes long, each byte is used 16 frames.
; $0F6E		; Cut scene number.
; $13D8		; Player 2 loaded/killed flag. 00 = not loaded, 01 = loaded, 02 = killed.
; $13E6		; First GFX tile to load from SP.bin. Uploaded to VRAM during NMI.
; $13E7		; Second GFX tile to load from SP.bin. Uploaded to VRAM during NMI.
; $13F2		; Load hideout flag. Only used on Overworld.
; $1695		; Sprite B index. Used during sprite interaction. This is also used by SMW, so it isn't free RAM.
; $18C5		; 16-bit map16 tile numbers of tiles sprite is touching. 8 bytes long.

; --Pose ($61) Usage--
;
; 01 is initiating Ashura Senku. Disables some physics routines.
; 02 is performing Ashura Senku. Disables the same physics routines as 01 and also most sprite interactions.
; 03 is kicking a shell or fish. Purely graphical.
; 04 is falling back from taking damage.
; 05 is set when letting go of B during a jump. Determines for how long the ascending animation will be used.
; 06 is performing a ground pound with the yellow shell power.
; 07 is going through a pipe.
; 08 is gaining an upgrade.

; --Bank 7F Stuff--
;
; $7FA100	; Used for a lot of purposes
; $7FA200	; Stripe image for menus
; $7FA300	; SRAM buffer
; $7FA400	; HDMA tables
; $7FA500	; Temporary message data
; $7FA600	; 1kB VR2 RAM

; --SRAM Buffer--
;
; $7FA300	Save file header
; $7FA301	Difficulty settings
; $7FA302	Player lives
; $7FA303	Player 1 powerup (lo nybble is current powerup, hi nybble is reserve item)
; $7FA304	Player 2 powerup
; $7FA305	Number of Yoshi Coins collected (16 bit)
; $7FA307	Player 1 death counter (16-bit)
; $7FA309	Player 2 death counter (16-bit)
; $7FA30B	Yoshi Coins collected for each level table (96/0x60 bytes)
; $7FA36B	Bestiary (32/0x20 bytes)
; $7FA38B	Characters in play. Hi nybble is for player 1, lo nybble is for player 2. Used during gameplay.
; $7FA38C	Mario's upgrades. Bit format: --------
;
; $7FA38D	Koops' upgrades. Bit format: Aac-hflg
;		A is Aura. It lets Koops spend magic to activate star power on himself.
;		a is improved Ashura Senku. It lets Koops use it in midair and jump-cancel it.
;		c is combo. It lets Koops spend magic to kill enemies by pushing Y during Ashura Senku.
;		h is high jump. It lets Koops perform a short jump followed by a high jump by pressing down and B.
;		f is fireball. It lets Koops spend magic to shoot a fireball.
;		l is levitate. It lets Koops spend magic to maintain Ashura Senku in midair and control Xspeed.
;		g is ground pound. It lets Koops use a ground pound move by pushing down in midair.
		
;
; $7FA38E	Leeway's upgrades. Bit format: D-----hi
;		D is Durandal. It has a larger hitbox and can damage dark enemies.
;		h is hover. It lets Leeway descend very slowly while using Sword Spin in midair.
;		i is Instant Dash. It lets Leeway cancel backwing animations into a dash.

;=======;
;DEFINES;
;=======;


	; -- Free RAM --		; Point to unused addresses, please.
					; Don't change addressing mode (16-bit to 24-bit and vice versa).
					; Doing that requires changing some code.

		!Player1HP		= $0F42
		!WallCling		= $0F43
		!DashTimer		= $0F44
		!SlashTimer		= $0F45
		!InstantDash		= $0F46
		!SwordHover		= $0F47
		!PropellerSlash		= $147B
		!Characters		= $7FA38B

		!VRAMbank		= $7F
		!VRAMbase		= !VRAMbank*$10000	; This is so gross. asar syntax sucks sometimes.
		!VRAMtable		= $A600
		!VRAMslot		= !VRAMtable+$FE
		!CGRAMtable		= $A700

	; -- SMW RAM --			; This is mainly for easier SA-1 compatibility.

		!RAM_TrueFrameCounter	= $13
		!RAM_FrameCounter	= $14
		!MarioJoypad1		= $15
		!MarioJoypad1OneF	= $16
		!MarioJoypad2		= $17
		!MarioJoypad2OneF	= $18
		!MarioPowerUp		= $19
		!RAM_ScreenMode		= $5B
		!Palette		= $5C
		!GlobalProperties	= $64
		!MarioClimbing		= $74
		!MarioUnderWater	= $75
		!MarioDirection		= $76
		!MarioBlocked		= $77
		!MarioMaskBits		= $78
		!MarioXSpeed		= $7B
		!MarioYSpeed		= $7D
		!MarioScreenXPosLo	= $7E
		!MarioScreenXPosHi	= $7F
		!MarioScreenYPosLo	= $80
		!MarioScreenYPosHi	= $81
		!MarioXPosLo		= $94
		!MarioXPosHi		= $95
		!MarioYPosLo		= $96
		!MarioYPosHi		= $97
		!GameMode		= $0100
		!OAM			= $0200
		!OAMsize		= $0420
		!MarioJoypad1Raw	= $0DA2
		!MarioJoypad2Raw	= $0DA4
		!MarioJoypad1RawOneF	= $0DA6
		!ItemBox		= $0DC2
		!MarioImg		= $13E0
		!MarioWallWalk		= $13E3
		!CapeEnable		= $13E8
		!CapeXPosLo		= $13E9
		!CapeXPosHi		= $13EA
		!CapeYPosLo		= $13EB
		!CapeYPosHi		= $13EC
		!MarioBehind		= $13F9
		!ScrollLayer1		= $1404
		!MarioSpinJump		= $140D
		!MarioCarryingObject	= $1470
		!MarioFlashTimer	= $1497
		!MarioCapeFloat		= $14A5
		!MarioCapeSpin		= $14A6
		!MarioRidingYoshi	= $187A
		!SPC1			= $1DF9
		!SPC2			= $1DFA
		!SPC3			= $1DFB
		!SPC4			= $1DFC

	; -- SMW routines --

		!ContactGFX		= $01AB99

	; -- Values --			; These allow easier customization.

		!Climb1			= $36
		!Climb2			= $36
		!Climb3			= $37
		!Climb4			= $37
		!ClimbUpSpeed		= $F0
		!ClimbDownSpeed		= $10
		!ClimbLeftSpeed		= $F0
		!ClimbRightSpeed	= $10

	; -- Booleans --		; Don't mess with these.

		!True 			= 1
		!False			= 0


	!Palette		= $5C
	!Index			= $60
	!Pose			= $61
	!PoseTimer		= $62

	!Map16Table		= $18C5		; 8 bytes
	!Map16Index		= $0F3A		; 1 byte

	!Upgrades		= $7FA38D	; 1 byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;
;;;;;INIT ROUTINE;;;;;
;;;;;;;;;;;;;;;;;;;;;;

INITCODE:	PHB
		PHK
		PLB

		LDA $7FAB10,x
		BMI MAINCODE
		ORA #$80
		STA $7FAB10,x

		LDA $13D8
		BEQ .Process
		STZ $14C8,x			; Erase player 2 if a player 2 sprite already exists
		PLB
		RTS

.Process	STX $60				; Store player 2 index to RAM
		LDA #$80			;\ Enable dynamic palette upload
		STA !Palette			;/
		STZ $15DC,x			; Make player 2 interact with objects
		LDA $63
		STA $157C,x			; Make sure sprite is facing the right direction
		STZ $B6,x			; Reset Xspeed (necessary after intro animations)
		STZ $0F6E			; Clear cut scene number
		LDA $13BF			; Load translevel number
		CLC
		ADC #$CA			; Check level 0x112
		BNE .Return
		LDY $13BF
		LDA $1EA2,y
		AND #$40
		BEQ .Return
		STZ $14C8,x			; Erase player 2
.Return		PLB
		RTS


;;;;;;;;;;;;;;;;;;;;;;
;;;;;MAIN ROUTINE;;;;;
;;;;;;;;;;;;;;;;;;;;;;

MAINCODE:	STX $60				; > Make sure index is not overwritten
		LDA #$36			;\ Set sprite number
		STA $9E,x			;/
		JSR TESTSPRITE			; > Run testing routine

		LDA #$01			;\ Set player 2 loaded flag
		STA $13D8			;/

		LDA $61
		CMP #$07
		BNE CUTSCENE
		LDA $62
		BEQ .Clearpose
		DEC $62
		BRA .NoPoseTimer
.Clearpose	STZ $61
		STZ $0F6E
.NoPoseTimer	INC $D8,x
		LDA #$04
		STA $1DF9
		JSR GRAPHICS
		PLB
		RTS

;=========================;
;CUTSCENE HANDLING ROUTINE;
;=========================;

CUTSCENE:	LDA $0F6E
		BEQ .Animation

		LDA $1540,x			;\ Check cut scene timer
		BEQ .End			;/
		CMP #$60
		BCS .Move

		LDA #$04			;\ Play "go in pipe"-sound
		STA $1DF9			;/
		INC $D8,x
		DEC $1540
		JSR GRAPHICS
		PLB
		RTS

.End		STZ $88
		JSR GRAPHICS
		PLB
		RTS

.Move		LSR A				;\
		LSR A				; | Update input every 16 frames
		LSR A				; |
		LSR A				;/
		TAX				; X = index for joypad input table
		LDA $0F5E,x			; Load joypad input
		STA $0DA3			; Set joypad 2 data 1 (all frames)
		STA $0DA7			; Set joypad 2 data 1 (one frame)
		STZ $0DA5			; Clear joypad 2 data 2 (all frames)
		STZ $0DA9			; Clear joypad 2 data 2 (one frame)
		LDX $60				; X = player 2 index
		JMP MAIN_ENGINE			; Ignore lock flags

.Animation	LDA $71				; Load current player 1 animation
		CMP #$07			; Check if shooting out of a slanted pipe
		BEQ .SlantPipe
		CMP #$0A			; Check castle intro
		BNE .Pipe
		LDA $7B				;\
		STA $B6,x			; |
		LDA $94				; |
		SEC				; | Player 2 follows player 1
		SBC #$14			; |
		STA $E4,x			; |
		JSR GRAPHICS			; |
		JMP APPLY_SPEED_Main		;/

.SlantPipe	LDA $94				;\
		SEC				; |
		SBC #$18			; |
		STA $E4,x			; |
		LDA $95				; |
		SBC #$00			; |
		STA $14E0,x			; | Player 2 pos = player 1 pos (+ some offset)
		LDA $96				; |
		CLC				; |
		ADC #$20			; |
		STA $D8,x			; |
		LDA $97				; |
		ADC #$00			; |
		STA $14D4,x			;/

		LDA $7B				;\
		STA $B6,x			; | Player 2 speed = player 1 speed
		LDA $7D				; |
		STA $AA,x			;/

.Pipe		LDA $71
		BEQ LOCK_Check
		LDA $88
		BEQ LOCK_Check
		LDA $89
		CMP #$04
		BMI LOCK_Check			; Branch if player 1 is entering a pipe

		LDA $76				;\
		EOR #$01			; | Player 2 direction = player 1 direction
		STA $157C,x			;/
		LDA $7B				;\
		STA $B6,x			; | Player 2 speed = player 1 speed
		LDA $7D				; |
		STA $AA,x			;/
		LDA $94				;\
		STA $E4,x			; |
		LDA $95				; |
		STA $14E0,x			; | Player 2 pos = player 1 pos
		LDA $96				; |
		CLC				; |
		ADC #$10			; |
		STA $D8,x			; |
		LDA $97				; |
		ADC #$00			; |
		STA $14D4,x			;/
		LDA #$04			;\ Set player 2 blocked from below (to use walking animation)
		STA $1588,x			;/
LOCK:		JSR GRAPHICS
		PLB
		RTS

.Check		LDA $14C8,x			;\
		SEC : SBC #$08			; | Most efficient check for lock flags
		ORA $9D				; |
		BNE LOCK			;/

MAIN_ENGINE:

; --Manual--
;
; This is the core of the player 2 engine.
; It will run the following routines, in the given order:
;
; - Object interaction:
;	Handles most of the object/layer 1 interaction.
;	Checks 4 tiles every frame.
;
; - Sprite interaction:
;	Handles all sprite interaction.
;	Player 2 can interact with up to two sprites each frame (to minimize slowdown).
;
; - Extended sprite interaction:
;	Handles all extended sprite interaction.
;	Player 2 can interact with one extended sprite each frame (to minimize slowdown).
;
; - Physics routine:
;	Handles player 2's movement and combat mechanics.
;	Calls several subroutines each frame.
;
; - Graphics routine:
;	Updates RAM addresses that determine what is uploaded to VRAM during NMI.
;	The sprite is dynamic so it always uses the same tile numbers.
;
; - Apply speed routine:
;	Updates the sprite's X and Y positions based on speed.
;	Takes into considerations wether player 2 is on a moving platform or not.
;	X and Y collision routines are also called from here.
;	They make sure the approperiate speed (X or Y) is set to zero when the sprite collides with anything solid.
;
; - Offscreen routine:
;	Handles player 2 while offscreen.
;	Also checks if player 2 should die or not (from being too far below the screen).


;==========================;
;OBJECT INTERACTION ROUTINE;
;==========================;

; --Manual--
;
; The object interatction routine is quite different from the one SMW uses.
; It will check 4 tiles each frame, located at each corner of P2's base position.
; The process is as follows:
;
; - Set up a loop for accessing map16 data.
; - Load all 4 corner tiles' 16-bit map16 acts like settings and store them to $18C5.
; - Run interaction for all 4 tiles.

JMP +
incsrc "OBJECT_INTERACTION.asm"
+

;===================;
;INTERACTION ROUTINE;
;===================;
; --Info--
; Interaction 00 means the sprite has no set interaction.
; Interaction 01 is for Shelless Koopas (#$00-#$03) and Sliding Koopa (#$BD).
; Interaction 02 is for Koopas (#$04-#$07), Buzzy Beetle (#$11), Koopa Shells (#$DA-#$DD and #$DF) and
; MechaKoopa (#$A2).
; Interaction 03 is for Parakoopas (#$08-#$0C).
; Interaction 04 is for Bob-omb (#$0D) and Parabomb (#$40).
; Interaction 05 is for Goomba (#$0F).
; Interaction 06 is for Bouncing Paragoomba (#$10) and Paragoomba (#$3F).

; Interaction 07 is for Spiny (#$13), Falling Spiny (#$14), Bouncing Football (#$1B), Hopping Fireball (#$1D),
; Magikoopa's Magic (#$20), Thwomp (#$26), Thwimp (#$27), Big Boo (#$28), Pirahna Plants (#$2A and #$4F-#$50),
; Sumo Brother's Lightning (#$2B), Spike Top (#$2E), Fireball Vertical (#$33), Boss Fireball Stationary (#$34),
; Boo (#$37), Eeries (#$38-#$39), Urchins (#$3A-#$3C), Rip Van Fish (#$3D), Torpedo Ted (#$44),
; Diggin' Chuck's Rock (#$48), Chainsaws (#$65-66), Grinder Line-guided (#$67), Fuzzball Line-guided (#$68),
; Volcano Lotus (#$99), Sumo Brother (#$9A), Ball and Chain (#$9E), Bowser's Bowling Ball (#$A1),
; Floating Spike Ball (#$A4), Sparky/Fuzzball (#$A5), Hothead (#$A6), Blargg (#$A8), Reznor (#$A9),
; Fishbone (#$AA), Reflecting Stream of Boo Buddies (#$B0), Falling Spike (#$B2), Bowser Statue Fireball (#$B3),
; Grinder non-line-guided (#$B4), Reflecting Fireball (#$B6), Blurp Fish (#$C2), Porcu-Puffer Fish (#$C3),
; Big Boo Boss (#$C5), Group of 5 Eeries wave motion (#$DE) .

; Interaction 08 is for Fish (#$15-#$16 and #$18).
; Interaction 09 is for Bullet Bill (#$1C).
; Interaction 0A is for Lakitus (#$1E and #$4B), Magikoopa (#$1F), Ninji (#$51), Hammerbrother (#$9B) and
; Swooper Bat (#$BE).
; Interaction 0B is for Moving Coin (#$21).
; Interaction 0C is for Net Koopas (#$22-#$25).
; Interaction 0D is for Portable Springboard (#$2F) and POW (#$3E).
; Interaction 0E is for Dry Bones (#$30 and #$32) and Bony Beetle (#$31).
; Interaction 0F is for Dolphins (#$41-#$43), Growing/shrinking Pipe End (#$49) and Timed Lift (#$BA),
; Grey Moving Castle Block Horizontal (#$BB), Grey platform on lava (#$C0), Grey platform that falls (#$C4).
; Interaction 10 is for Chucks (#$46, #$91-#$95, #$97 and #$98).
; Interaction 11 is for Goal Point Sphere (#$4A).
; Interaction 12 is for Monty Mole (#$4D and #$4E).
; Interaction 13 is for Dino Rhino (#$6E) and Dino Torch (#$6F).
; Interaction 14 is for Banzai Bill (#$9F).
; Interaction 15 is for Rex (#$AB).
; Interaction 16 is for Boo Block (#$AC).
; Interaction 17 is for Carrot Top Platforms (#$B7-#$B8).
; Interaction 18 is for Mega Mole (#$BF).
; Interaction 19 is for upgrades (custom sprites).

; Interaction FF is for custom sprites (#$36). It usually jumps to a regular interaction routine depending.

INTERACTION:

		LDA !Pose			;\
		CMP #$02			; | Don't interact during Ashura Senku
		BEQ +				;/
		STZ $C2,x
		STZ $58				; Clear contact flag
		JSR GET_SPRITE_CLIPPING		; Check for contact with other sprites (sets contact flag)
		LDA $58
		BEQ .Return			; Return if contact flag is clear
		LDY $00				; Load interaction number into Y
		BEQ .Return
.Process	CPY #$FF
		BNE .ExecutePtr

		LDX $1695			; X = sprite B index
		LDA $7FAB9E,x			; Load custom sprite number
		LDX $60				; X = player 2 index

		CMP #$05			; Projectile
		BNE +
		LDY #$07
		BRA .ExecutePtr
	+	CMP #$40			; Player 2 upgrade 1
		BNE +
		LDY #$19
		BRA .ExecutePtr
	+	CMP #$AB			; Aggressive Rex
		BNE +
		LDY #$15
		BRA .ExecutePtr
	+	CMP #$AC			; Turning Rex
		BNE +
		LDY #$15
		BRA .ExecutePtr
	+	CMP #$AD			; Hammer Rex
		BNE +
		LDY #$15
		BRA .ExecutePtr
	+	BRA .Return

.ExecutePtr	TYA
		ASL A				; Double A to work with them 16-bit pointers
		TAX
		JSR (INTERACTION_POINTER,x)	; Execute routine
.Return

;===========================;
;EXTENDED SPRITE INTERACTION;
;===========================;

INT_EXTENDED:	LDY #$08			; Set up loop
.Loop		DEY
		BPL .Process
		JMP .Return			; Break loop after checking all the sprites

.Process	LDA $170B,y
		CMP #$0E			;\ Filter out the highest numbers as they're all unused
		BPL .Loop			;/
		CMP #$02			;\ Filter out the lowest numbers as they're all unused
		BMI .Loop			;/
		CMP #$05			;\ Branch if 02, 03 or 04
		BMI .Valid			;/
		BEQ .Loop			; Loop if 05 (Mario's fireball)
		CMP #$06			;\ Branch if Dry Bone's bone
		BEQ .Valid			;/
		CMP #$0A			;\ Loop if 07, 08 or 09
		BMI .Loop			;/

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;;NOTE: All unchecked numbers are valid;;;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.Valid		LDX $60				; X = player 2 index
		LDA $1715,y			; Ypos, lo byte
		STA $00
		LDA $1729,y			; Ypos, hi byte
		STA $01

		LDA $171F,y			; Xpos, lo byte
		STA $02
		LDA $1733,y			; Xpos, hi byte
		STA $03

		LDA $E4,x
		STA $04
		LDA $14E0,x
		STA $05

		LDA $14D4,x
		XBA
		LDA $D8,x
		REP #$20
		CLC
		ADC.w #$0004			; Calculate from center of sprite
		SEC
		SBC $00
		STA $00
		BPL +
		EOR.w #$FFFF
	+	CMP.w #$000C
		BMI .CheckX
		SEP #$20
		BRA .Loop

.CheckX		LDA $04
		CLC
		ADC.w #$0004			; Calculate from center of sprite
		SEC
		SBC $02
		BPL +
		EOR.w #$FFFF
	+	CMP.w #$000C
		BMI .Contact
		SEP #$20
		BRA .Loop

.Contact	SEP #$20
		LDA $170B,y
		CMP #$0A
		BNE .Hurt

.Coin		LDA #$00
		STA $170B,y			; Erase coin
		PHY				; Y = Exsprite index
		JSR SET_GLITTER
		PLX				; X = Exsprite index, Y = smoke sprite index
		LDA $1715,x			;\
		STA $17C4,y			; | Glitter pos = Exsprite pos
		LDA $171F,x			; |
		STA $17C8,y			;/
		TXY				; Y = Exsprite index
		LDX $60				; X = player 2 index

		LDA #$01			;\ Play collect coin sound
		STA $1DFC			;/
		INC $13CC			; Add 1 to coin counter
		LDA #$05			;\ Score sprite to spawn
		STA $00				;/
		STZ $01				; Ignore kill count
		PHY
		JSR GIVE_SCORE
		PLY
		BRA .Return

.Hurt		LDA $1528,x
		BNE .Return
		JSR HURT			; Hurt player 2..
		STZ $B6,x			; ..with no Xspeed
.Return		BRA PHYSICS


;===============;
;PHYSICS ROUTINE;
;===============;
XSPEED:		db $14,$EB			; Upper row holds walking speeds.
		db $2F,$D0			; Middle row holds dashing speeds.
		db $00				; Lower row holds default speed.

YSPEED:		db $C8,$C8,$C9,$C9,$CA,$CA,$CB,$CB
		db $CC,$CD,$CE,$CF,$D0,$D1,$D2,$D3
		db $D4,$D5,$D6,$D7
		db $D8,$D9,$DA,$DB,$DC,$DD,$DE,$DF
		db $E0,$E1,$E2,$E3,$E4,$E5,$E6,$E7
		db $E8,$E9,$EA,$EB,$EC,$ED,$EE,$EF
		db $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7
		db $F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF

PHYSICS:	LDA $1504,x
		BEQ +
		DEC $1504,x			; While $1504,x is non-zero gravity is much weaker
	+	LDA $1528,x
		BEQ +
		DEC $1528,x			; While $1528,x is non-zero the hurt routine is not called
	+	LDA $1570,x
		BEQ +
		DEC $1570,x			; While $1570,x is non-zero, sprite does not interact with kicked shells
	+	LDA $62
		BEQ .ClearPose
		DEC $62
		BRA +
.ClearPose	STZ $61
	+	LDA $79
		BEQ +
		DEC $79				; While $79 is non-zero player 2 can hold B to set Yspeed to #$90
	+	LDA $0DDC
		BEQ .ResetSwim
		DEC $0DDC
		BRA +
.ResetSwim	STZ $0DDB			; Reset swim speed
	+	;JSR CONTROLS
		JSR PHYSICS_JUMP
		JSR PHYSICS_ASHURASENKU
	;	JSR PHYSICS_SHELLPOWER
		JSR PHYSICS_GRAVITY
		JSR PHYSICS_WATER
		JSR PHYSICS_PLAYER1

		JSR GRAPHICS			; Draw graphics

;===================;
;APPLY SPEED ROUTINE;
;===================;

APPLY_SPEED:	LDA $C2,x			; Load pd--iiii
		BEQ .Main
		AND #$0F			; Only check iiii
		TAY
		LDA $00AA,y			;\ Player 2 Yspeed = Platform Yspeed
		STA $AA,x			;/
		LDA $1588,x			;\
		PHA				; |
		LDA $B6,x			; |
		PHA				; |
		LDA $C2,x			; |
		AND #$40			; |> Check direction bit
		BEQ +				; |
		STZ $B6,x			; |
		BRA .Platform			; |
	+	LDA $00B6,y			; | APPLY PLATFORM SPEEDS
		STA $B6,x			; |
.Platform	JSL $01802A			; |> Update sprite pos based on speed
		JSR PHYSICS_XCOLLISION		; |\ Apply collision for platform speeds
		JSR YCOLLISION			; |/
		PLA				; |
		STA $B6,x			; |
		PLA				; |
		ORA $1588,x			; |
		STA $1588,x			; |
		STZ $AA,x			;/

.Main		JSR PHYSICS_XCOLLISION		;\ Apply collision
		JSR YCOLLISION			;/

		LDA $B6,x			;\ Preserve Xspeed
		PHA				;/

.Water		LDA $164A,x			;\
		ORA $85				; |
		BEQ .NoWater			; |
		LDA $1588,x			; | Only apply 3/4 Xspeed while walking under water
		AND #$04			; |
		BEQ .NoWater			; |
		LDA $B6,x			; |
		BPL +				;/
		EOR #$FF			;\
		INC A				; |
		LSR A				; |
		PHA				; |
		LSR A				; | Calculate negative Xspeed
		STA $00				; |
		PLA				; |
		EOR #$FF			; |
		INC A				; |
		BRA ++				;/
	+	LSR A				;\
		STA $00				; | Calculate positive Xspeed
		LSR A				;/
	++	CLC : ADC $00			;\ Write Xspeed
		STA $B6,x			;/

.NoWater	LDA $AA,x			;\ Preserve Yspeed
		PHA				;/
		LDA $164A,x
		ORA $85
		BEQ .WriteSpeed
		LDA $AA,x
		BMI .WriteSpeed
		LSR A
		STA $AA,x			; Halve Yspeed

.WriteSpeed	LDA $1588,x
		AND #$04
		PHA
		JSL $01802A			; Apply speed
		PLY
		LDA $61
		CMP #$02
		BNE .NoSenku
		TYA
		ORA $1588,x
		STA $1588,x

.NoSenku	LDA $164A,x			;\
		ORA $85				; |
		BEQ +				; | Don't apply SMW's universal gravity underwater
		PLA				; |
		STA $AA,x			; |
		PLA				;/
		BRA OFFSCREEN			; YEAH!
	+	PLA : PLA			; Pull Yspeed off the stack

;===========================;
;PLAYER 2 OFF SCREEN ROUTINE;
;===========================;

OFFSCREEN:	LDA $5B				;\
		LSR A				; | Check if level is horizontal of vertical
		BCS .Vertical			;/

.Horizontal	LDA $14D4,x			;\
		CMP #$02			; | If player 2 is not beneath level, do nothing
		BMI RETURN			;/
		BRA .Kill			; > Kill player 2

.Vertical	LDA $14D4,x			;\
		CMP $5F				; | If player 2 is beneath level, kill player 2
		BEQ .Kill			;/
		PLB : RTS			; > Return

.Kill		JSR HURT_Kill			; > Kill player 2
RETURN:		PLB : RTS			; > End of bank wrapper


;===================;
;TEST SPRITE ROUTINE;
;===================;

!Sprite = $01					; Sprite to test

TESTSPRITE:	PHX
		LDX #$0C
.Loop		DEX
		BMI .Return
		LDA $9E,x
		CMP #!Sprite
		BNE .Loop
.Found		NOP
		NOP
.Return		PLX
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc "CONTROLS.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PHYSICS_JUMP:

		LDA $164A,x			;\
		ORA $85				; |
		BNE .Return			; |
		LDA $79				; | Some checks
		BNE .SpringBoard		; |
		LDA $1588,x			; |
		AND #$04			; |
		BEQ .Return			;/
		LDA $61				;\
		BEQ .Process			; |
		CMP #$03			; |
		BEQ .Process			; | Pose checks
		CMP #$05			; |
		BEQ .Process			;/
		LDA $7FA38D			;\
		AND #$40			; |
		BEQ .Return			; |
		LDA $62				; | Allow jumping out of Ashura Senku if it is upgraded
		CMP #$02			; |
		BEQ .Process			; |
.Return		RTS				;/

.Process	LDA $0DA7
		BPL .Return
		LDA $B6,x
		BPL +
		EOR #$FF			; Only calculate positive values
		INC A
	+	LSR A				; Divide by 2
		CMP #$0E
		BPL .Calc
		LDA #$0E			; Minimum jump-float is 16 frames (14+2)
.Calc		INC A
		INC A
		STA $1504,x			; Store to extra sprite data
		LDA #$C8
		STA $AA,x			; Give sprite Y-speed
		LDA #$01
		STA $1DFA			; Play jump sound
		LDA #$05
		STA $1510,x			; Set up floatiness timer
		STZ $151C,x			; Reset YSPEED index
		STZ $C2,x			; Reset pd--iiii

		LDA #$05			;\ Pose = ascending
		STA $61				;/
		LDA #$08			;\ Pose timer = 08 frames
		STA $62				;/
		RTS

.SpringBoard	LDA $0DA3
		BPL .Return
		LDA #$90
		STA $AA,x
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PHYSICS_ASHURASENKU:

		LDA $61
		CMP #$02
		BEQ .Dash
		CMP #$01
		BNE .NoDash
		LDA $62
		BNE .NoDash
		INC $61
		LDA #$1F
		STA $62
.NoDash		LDA $1588,x
		AND #$03
		BNE .Return			; Don't allow Ashura Senku into walls
		LDA $7FA38D			;\
		AND #$40			; | Allow in midair if player 2 has an upgrade
		BNE .AirSenku			;/
		LDA $1588,x			;\
		AND #$04			; | Don't allow in midair if player 2 hasn't an upgrade
		BEQ .Return			;/
.AirSenku	LDA $61
		BNE .Return
		LDA $0DA9			; Load joypad 2 data 2 (1 frame)
		BMI +				; Branch if A is set
		RTS

	+	LDA #$01
		STA $61				; Set pose to "initiating Ashura Senku"
		STZ $B6,x
		LDA $7FA38D
		AND #$40
		BEQ +
		LDA #$01
		STA $62
		RTS
	+	LDA #$0F
		STA $62				; Set posetimer to 16 frames
		RTS

.Dash		LDY $157C,x
		INY
		INY
		LDA XSPEED,y
		STA $B6,x
		STZ $AA,x
		LDA $62
		BNE .Return
		LDA $B6,x			;\
		BPL +				; |
		EOR #$FF			; |
		INC A				; |
		LSR A				; | Halve Xspeed
		EOR #$FF			; |
		INC A				; |
		BRA ++				; |
	+	LSR A				; |
	++	STA $B6,x			;/
		LDA #$04			;\
		STA $61				; |
		LDA #$07			; | Stun sprite at the end of Ashura Senku
		STA $62				; |
		STZ $AA,x			;/
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	FIREXSPEED: db $3F,$C0

	PHYSICS_SHELLPOWER:

		LDY $0D9C
		DEY
		DEY
		BEQ REDPOWER
		DEY
		BNE +
		JMP BLUEPOWER
	+	DEY
		BNE .Return
		JMP YELLOWPOWER
.Return		RTS


REDPOWER:	LDY $0DA1			; "Remember my index."
		LDA $170B,y
		CMP #$11
		BEQ +
		STZ $0DA1
	+	LDA $0DA1
		BNE .Return
		LDA $0DA7			; Load joypad 2 data 1 (1 frame)
		AND #$40			; Check if Y was pushed this frame
		BEQ .Return			; Branch if clear

		LDY #$08			; Set up loop
.Loop		DEY
		BPL .Spawn
		RTS

.Spawn		LDA $170B,y
		BNE .Loop
		STY $0DA1			; Store Exsprite index to extra shell data
		LDA #$11			; Exsprite = Yoshi fireball
		STA $170B,y
		LDA $14D4,x			;\
		XBA				; |
		LDA $D8,x			; |
		REP #$20			; |
		SEC				; |
		SBC.w #$0004			; |
		SEP #$20			; |
		STA $1715,y			; |
		LDA $E4,x			; |
		STA $171F,y			; | Exsprite pos = (Sprite pos - 4 Ypixels)
		XBA				; |
		STA $1729,y			; |
		LDA $14E0,x			; |
		STA $1733,y			;/
		LDA #$00
		STA $173D,y			; Exsprite Y speed
		LDA $157C,x
		TAX
		LDA FIREXSPEED,x		; Load fireball speed based on direction
		STA $1747,y			; Store to exsprite X speed
		LDA #$FF
		STA $176F,y
		LDA #$17			;\ Play "breath fire"-sound
		STA $1DFC			;/
		LDX $60				; X = sprite index
.Return		RTS


BLUEPOWER:	LDA $1534,x
		BNE .Return			; Don't allow levitating more than once each jump
		LDA $1588,x
		AND #$04
		BNE .Return			; Don't allow levitating on the ground
		LDA $0DA7
		AND #$80
		BNE .Init			; Pushing B can cancel a jump into a levitate
		LDA $AA,x
		BMI .Return
		LDA $0DA3
		AND #$80
		BNE .Levitate			; Holding B starts the levitate at the top of the jump
		RTS

.Init		LDA $0DA1
		BNE .Levitate
		LDA #$78			; 2 seconds worth of flying frames
		STA $0DA1
		STZ $AA,x
		STZ $1504,x			;\
		STZ $1510,x			; | Reset gravity timers
		STZ $151C,x			;/
		RTS

.Levitate	DEC $0DA1
		LDA $0DA1
		BEQ .Reset
		STZ $AA,x			; Reset Y speed
		RTS

.Reset		INC $1534,x			; Set levitated flag
.Return		STZ $0DA1
		RTS


YELLOWPOWER:	LDA $1588,x
		AND #$04
		BEQ .Air			; Branch if sprite is in midair
		RTS

.Air		LDA $61
		CMP #$06
		BNE .Init			; Branch if not performing ground pound
		INC $62
		STZ $B6,x
		LDA $0DA1
		BEQ .Fall
		DEC $0DA1
		BNE .NoFall
.Fall		LDA #$40			;\
		STA $AA,x			;/ Set Y speed (only if $0DA1 is clear)
		RTS

.NoFall		STZ $AA,x
		RTS

.Init		LDA $0DA7			; Load joypad 2 data 1 (1 frame)
		AND #$04			; Check if down was pushed this frame
		BEQ .Return			; Return if clear
		LDA #$10
		STA $0DA1			; Store to extra shell data
		LDA #$06			;\
		STA $61				;/ Set pose to ground pound
		LDA #$FF			;\
		STA $62				;/ Set pose timer
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PHYSICS_GRAVITY:

		LDA $164A,x			;\
		ORA $85				; |
		BNE .Return			; |> Let water routine handle gravity while under water
		LDA $61				; |
		BEQ .Process			; |
		CMP #$03			; | Pose checks
		BEQ .Process			; |
.Return		RTS				;/

.Process	LDA $61
		CMP #$06
		BEQ .NoJump
		LDA $1504,x			;\
		BEQ .NoJump			; |
		LDA $0DA3			; | If floatiness is non-zero and jump is held,
		AND #$80			; | don't apply standard gravity.
		BEQ .NoJump			;/
		DEC $1510,x
		LDA $1510,x			; 1510,x is used as a custom frame counter. It caps out at 5.
		BEQ .ResetTimer
		LDY $151C,x
		LDA YSPEED,y
		STA $AA,x
		INC $62				; Increment pose timer
		RTS

.ResetTimer	LDA #$05
		STA $1510,x
		INC $151C,x
		INC $151C,x
		RTS

.NoJump		STZ $1504,x			; Reset floatiness
		LDA $AA,x
		CMP #$38
		BEQ .Return
		INC $AA,x
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	WATER_YSPEED:	db $E6,$C0
	BUBBLE_XDISP:	db $0C,$FC

	PHYSICS_WATER:

		LDA $164A,x			; Sprite is in water flag
		ORA $85				; Add with water level flag
		BEQ PHYSICS_GRAVITY_Return	; Yes, I'm borrowing a label from the gravity routine

		LDA $14
		AND #$7F
		BNE WATER_NOBUBBLE

		LDY #$08
BUBBLE_LOOP:	DEY
		BMI WATER_NOBUBBLE
		LDA $170B,y
		BNE BUBBLE_LOOP
		LDA #$12			;\ Exsprite = bubble
		STA $170B,y			;/

		LDA $D8,x			;\
		STA $1715,y			; |
		LDA $14D4,x			; | Exsprite pos = sprite pos + BUBBLE_XDISP indexed by direction
		STA $1729,y			; |
		PHX				; |
		LDA $157C,x			; |
		TAX				; |
		LDA BUBBLE_XDISP,x		; |
		PLX				; |
		CLC				; |
		ADC $E4,x			; |
		STA $171F,y			; |
		ADC #$00			; |
		LDA $14E0,x			; |
		STA $1733,y			;/

	WATER_NOBUBBLE:

		LDA $61				;\
		CMP #$05			; | No jump-stacking!
		BNE .Process			; |
		RTS				;/

.Process	LDA $85				;\ You don't jump underwater
		BNE .NoJump			;/
		LDA $1403
		CMP #$02
		BEQ .Tide
		REP #$20
		LDA !Map16Table
		DEC A
		BEQ .NoJump
		DEC A
		BEQ .NoJump
		DEC A
		BEQ .NoJump
		LDA !Map16Table+$02
		DEC A
		BEQ .NoJump
		DEC A
		BEQ .NoJump
		DEC A
		BEQ .NoJump
		SEP #$20
		LDA $0DA7
		BPL .NoJump
		LDA #$20
		JMP PHYSICS_JUMP_Process+$07
.Tide		LDA $0DA7
		BPL .NoJump
		LDA $14D4,x
		DEC A
		BNE .NoJump
		LDA $D8,x
		CMP #$90
		BPL .NoJump
		LDA #$20
		JMP PHYSICS_JUMP_Process+$07
.NoJump		SEP #$20

		LDA #$01			;\ Set Loop
		STA $00				;/
		LDA $0DA3			;\
		AND #$0F			; | Y = direction bits
		TAY				;/
.Loop		LDA $B6,x
		CMP.w .XSpeed,y
		BEQ .PerfX
		BPL .PosX
		INC A
		INC A
.PosX		DEC A
.PerfX		STA $B6,x
		LDA $AA,x
		CMP.w .YSpeed,y
		BEQ .PerfY
		BPL .PosY
		INC A
		INC A
.PosY		DEC A
.PerfY		STA $AA,x
		DEC $00
		BEQ .Loop
		RTS

.XSpeed		db $00,$40,$C0,$00
		db $00,$2D,$D3,$00
		db $00,$2D,$D3,$00
		db $00,$40,$C0,$00
.YSpeed		db $00,$00,$00,$00
		db $40,$2D,$2D,$40
		db $C0,$D3,$D3,$C0
		db $00,$00,$00,$00

; What follows is the old water routine.
; It lets player 2 swim more like Mario.
; I decided to keep it in case it turned out useful.


		LDA $AA,x
		CMP #$20
		BEQ WATER_NOSWIMSPEED
		BMI WATER_INCY
		LDA #$20			;\ Don't allow falling speed higher than #$20
		STA $AA,x			;/

	WATER_INCY:

		LDA $14
		AND #$01
		BNE WATER_NOSWIMSPEED		; Only update Yspeed every other frame
		INC $AA,x			; Update Yspeed
		INC $0DDB

	WATER_NOSWIMSPEED:

		LDA $0DDC
		BEQ WATER_NOTIMER
		LDA $0DDB
		STA $AA,x

	WATER_NOTIMER:

		LDA $61
		CMP #$06
		BNE WATER_CHECK_CONTROLS
		LDA $0DA1
		BEQ WATER_CHECK_CONTROLS
		STZ $AA,x

	WATER_CHECK_CONTROLS:

		LDA $61
		CMP #$06
		BEQ NOWATER

		LDA $0DA7
		BPL NOWATER		; Check if B was pressed this frame
		LDA $0F3A
		ORA $0F3B
		BNE WATER_SWIM

	WATER_JUMP:

		SEP #$20
		LDA $0DA3
		AND #$08
		BEQ WATER_SWIM
		JSR PHYSICS_JUMP_Process
		STZ $1DFA
		LDA #$0E
		STA $1DF9
		RTS

	WATER_SWIM:

		LDY #$00		; Set up WATER_YSPEED index

		LDA #$0E		;\ Play swim sound
		STA $1DF9		;/

		STZ $00
		LDA $0DA3
		AND #$08
		BEQ WATER_NOUP
		LDA #$08
		STA $00
		INY			; Increase WATER_YSPEED index

	WATER_NOUP:

		LDA $1588,x
		AND #$04
		BEQ WATER_SETSPEED
		LDA #$08
		CLC
		ADC $00
		STA $00

	WATER_SETSPEED:

		LDA $AA,x
		SEC
		SBC #$18
		SEC
		SBC $00
		STA $0DDB			; Set swim speed
		BPL WATER_NOMAXCHECK
		CMP WATER_YSPEED,y
		BCS WATER_NOMAXCHECK
		LDA WATER_YSPEED,y
		STA $0DDB

	WATER_NOMAXCHECK:

		LDA $0DA3
		AND #$04
		BEQ WATER_NODOWN
		LDA $0DDB
		BPL WATER_NODOWN
		LDA $0DDB
		EOR #$FF
		LSR A
		EOR #$FF
		STA $0DDB

	WATER_NODOWN:

		LDA #$20			;\ Set swim timer
		STA $0DDC			;/

	NOWATER:

		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PHYSICS_XCOLLISION:

		LDA $61
		CMP #$02
		BNE .Process
		LDA $1588,x
		AND #$03
		BEQ .Return

		LDA #$D0			;\
		STA $AA,x			; |
		LDA $157C,x			; |
		EOR #$01			; |
		TAY				; |
		LDA XSPEED,y			; |
		STA $B6,x			; | Stun sprite and bounce it back if it hits
		LDA #$04			; | a wall during Ashura Senku.
		STA $61				; |
		LDA #$3C			; |
		STA $62				;/
		RTS

.Process	LDA $B6,x
		BEQ .Return
		BMI .NegX

.PosX		LDA $1588,x
		LSR A
		BCC .Return
		STZ $B6,x
		STZ $14F8,x
		LDY #$02
		LDA $0DA3
		LSR A
		BCS .CheckPipe
		RTS

.NegX		LDA $1588,x
		AND #$02
		BEQ .Return
		STZ $B6,x
		LDA #$FF			; The fraction bits need to be set..
		STA $14F8,x			; ..or the sprite will just keep going.
		LDY #$00
		LDA $0DA3
		AND #$02
		BNE .CheckPipe
.Return		RTS

.CheckPipe	REP #$20
		LDA !Map16Table,y
		CMP #$013F
		BEQ .Pipe
		CMP #$0279
		BEQ .Pipe
		CMP #$0345
		BEQ .Pipe
.NoPipe		SEP #$20
		RTS

.Pipe		SEP #$20
		LDA #$06
		STA $71
		STZ $88
		STZ $89
		LDA $E4,x
		STA $94
		LDA $14E0,x
		STA $95
		LDA $D8,x
		STA $96
		LDA $14D4,x
		STA $97
		RTS

incsrc "YCOLLISION.asm"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PHYSICS_PLAYER1:


;	LDA !MarioJoypad1OneF
;	AND #$20
;	BEQ .NoToggle
;	LDA $1FFF
;	EOR #$01
;	STA $1FFF
;	.NoToggle
	LDA $71			;\
	CMP #$07		; | Don't do this while shooting out of a slanted pipe
	BEQ .No			;/
	LDA $1FFF
	BEQ .No
	LDA #$FF
	STA !MarioMaskBits
	LDA $E4,x
	STA $94
	LDA $14E0,x
	STA $95
	LDA $D8,x
	STA $96
	LDA $14D4,x
	STA $97
	LDA #$02
	STA $1497
	LDY #$0B
-	STA $154C,y
	DEY
	BPL -
	.No

		LDA $18D3
		BNE .NoContact
		LDA $77
		AND #$04
		BNE .NoContact
		JSL $01A7DC
		BCC .NoContact
		LDA $16
		ORA $18
		BPL .NoContact
		LDA #$A0
		STA $7D
		LDA #$1F
		STA $18D3
		LDA #$10
		STA $1DF9

.NoContact	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

INTERACTION_POINTER:	dw INTERACTION_Return		; No interaction
			dw INT_01			; Shelless Koopas
			dw INT_02			; Koopas and Buzzy Beetle
			dw INT_03			; Parakoopas
			dw INT_04			; Bobomb and Parabomb
			dw INT_05			; Goomba
			dw INT_06			; Paragoombas
			dw INT_07			; Sprites that simply hurt player 2
			dw INT_08			; Fish
			dw INT_09			; Bullet Bill
			dw INT_0A			; Lakitus, Magikoopa, Ninji and Hammer Brother
			dw INT_0B			; Coins
			dw INT_0C			; Net Koopas (STILL UNFINISHED!!)
			dw INT_0D			; POW and Springboard (USES A MODIFIED DISASSEMBLY!!)
			dw INT_0E			; Dry Bones and Bony Beetle
			dw INT_0F			; Solid Sprites (FIX Y OFFSET!!)
			dw INT_10			; Chucks
			dw INT_11			; Goal
			dw INT_12			; Monty Mole
			dw INT_13			; Dinos
			dw INT_14			; Banzai Bill
			dw INT_15			; Rex
			dw INT_16			; Boo Block
			dw INT_17			; Carrot Top Platforms (STILL UNFINISHED!!)
			dw INT_18			; Mega Mole
			dw INT_19			; Player 2 upgrade 1
			dw INT_1A			; Powerups

STOMPSOUND_TABLE:	db $13,$14,$15,$16		; Indexed with consecutive kills
			db $17,$18,$19,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; --Interaction subroutine manual--
;
; All interaction routines should start with:
;
; LDX $60
; LDY $1695
;
; This loads the player 2 index in X and the sprite B index in Y.
; Most interaction routines should follow this up with:
;
; LDA $14C8,y
; CMP #$08
; BEQ .Process
; RTS
; .Process
;
; This makes sure that interaction will only happen if sprite B status is 08 (normal).
;
; 
; --Commonly called subroutines--
;
; - COMPARE_Y:
;
;	Loads 16 bit Ypos of player 2 and subtracts 16 bit Ypos of sprite B.
;	Usually called immediatedly after .Process. Should be followed by:
;
;	CLC : ADC #$XX
;	BMI .Top
;	.Side
;
;	CMP can be used instead of ADC, but will use negative numbers and can be confusing.
;	(because the SNES starts the Y-axis at the top of the screen, rather than the bottom)
;
; - COMPARE_X:
;
;	Loads 16 bit Xpos of player 2 and subtracts 16 bit Xpos of sprite B.
;	Not used nearly as much as COMPARE_Y, but still deserves a mention.
;
; - HURT:
;
;	Simply hurts player 2. Should be called like this:
;
;	LDA $1528,x
;	BNE .Return
;	LDA #$08
;	STA $1564,y
;	JMP HURT
;
;	$1564 disables sprite interaction. Setting it to 08 prevents player 2 from stomping right after being hit.
;
; - INCREMENT_KILLS:
;
;	Spawns a score sprite and increments player 2's kill count. X and Y are not changed by this routine.
;
; - BOUNCE:
;
;	Gives player 2 some Yspeed. Holding B will give additional floatiness.
;
; - CONTACTGFX:
;
;	Displays the contact star (that Mario usually uses).
;	Should be called like this:
;
;	LDA #$XX
;	LDY #$XX
;	JSR CONTACTGFX
;
;	A and Y determine where the smoke sprite spawns. They are offsets in pixels.
;	X is used as a sprite table index (instead of $60) so it can be spawned at other sprites, too.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This should be a fairly standard interaction. The only deviation from the norm is the kick, which can be performed
; while sprite B is lying face down.

	INT_01:

		LDX $60				; X = player 2 index
		LDY $1695			; Y = sprite B index
		LDA $14C8,y
		CMP #$08			; Only process interaction if sprite B status = 08
		BEQ .Process
.Return		RTS

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BNE .NoSpin
		JSR INCREMENT_KILLS		; Give score
		JMP SPINKILL			; Obliterate sprite B

.NoSpin		LDA $1528,y			;\ Kill sprite B if it is sliding out of a shell
		BNE .Kick			;/
		LDA $163E,y			;\ Kill sprite B if it is lying face down on the ground
		BNE .Kick			;/

		JSR COMPARE_Y
		CLC
		ADC #$04
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Set don't interact timer for sprite B
		STA $1564,y			;/
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Handle kill count and score

		LDA #$30			;\
		STA $1540,y			;/ Set sprite b smushed timer to #$30 frames
		LDA #$03			;\ Set sprite b status to smushed
		STA $14C8,y			;/

		LDA #$00			; X offset
		LDY #$08			; Y offset
		JSR CONTACTGFX
		JMP BOUNCE

.Kick		LDA #$00			;\
		STA $00AA,y			; | Reset sprite b speeds
		STA $00B6,y			;/
		LDA #$02			;\
		STA $14C8,y			;/ Set sprite b status to knocked out
		LDA #$03			;\
		STA $61				;/ Set pose to kick
		LDA #$0C			;\
		STA $62				;/ Set kickframe timer
		LDA #$03			;\ Play kick shell sound
		STA $1DF9			;/

		JMP INCREMENT_KILLS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KOOPA_XSPEED: db $3F,$C0

;SOURCE: GeneralResetSpr ($0196E1 in all.log)


;SHELLESS KOOPA RAM USAGE:
;
;	$00C2,x			; The Koopa (the one WITH the shell) uses this as a timer
;	$14C8,x			; Status is 08 (normal) the entire time
;	$1504,x			; Unused
;	$1510,x			; Unused
;	$151C,x			; Briefly set to 20 when the koopa slides out of the shell, set to 01 when it gets up from the ground
;	$1528,x			; Set to 16 while the koopa is sliding
;	$1534,x			; Briefly set to 20 when the koopa slides out of the shell
;	$1540,x			; Used as a stun-timer (CAN YOU IMAGINE!?), starts at 16
;	$154C,x			; Unused
;	$1558,x			; Unused
;	$1564,x			; Used as a timer (same as $1540,x?)
;	$1570,x			; Timer for how long the koopa will remain lying on the ground, set to 1 while it is sliding
;	$157C,x			; Sprite direction, does not reset when sprite dies
;	$1594,x			; Set to 06 when the koopa enters a shell, not reset when it dies
;	$15A0,x			; Briefly set to 20 when the koopa slides out of the shell
;	$15AC,x			; Set to 8 when sprite walks into a wall, then decrements until it hits 0
;	$15DC,x			; Seemingly unused
;	$1602,x			; Seems to be an index for a graphics table
;	$160E,x			; Briefly set to 20 when the koopa slides out of the shell
;	$163E,x			; A timer that starts at 255 when the koopa stops sliding, set to 0 when the koopa gets up from the ground and never finishes

	INT_02:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BPL +
		RTS					; Return if sprite B status is less than 0x08
	+	CMP #$0B
		BMI .Process
.Return		RTS					; Return if sprite B status is greater than 0x0A

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$06
		BNE .NoSpin
		JSR INCREMENT_KILLS			; Give score
		JMP SPINKILL				; Obliterate sprite B

.NoSpin		LDA $14C8,y				; Status is known to be in the range 0x08-0x0A
		CMP #$08
		BNE .NotNormal
		JMP .Normal
.NotNormal	CMP #$09
		BEQ .Stunned

.Kicked		LDA $61
		CMP #$02
		BEQ .Return
		LDA $1570,x				;\ Don't interact if player 2 has immunity to kicked shells
		BNE .Return				;/
		JSR COMPARE_Y
		CLC
		ADC #$06
		BMI +
		JMP .Side
	+	JMP .TopKicked

.Stunned	LDA $009E,y
		CMP #$A2
		BNE .Kick
.Mecha		JSR INT_04_Stunned			;\
		LDA #$FF				; | Mecha Koopa routine
		STA $1540,y				;/
		RTS

.Kick		LDA #$03				;\ Kick sound
		STA $1DF9				;/
		JSR INCREMENT_KILLS			; Increment kill counter and give score
		LDA #$03				;\ Set pose to kick
		STA $61					;/
		LDA #$0C				;\ Set kickframe timer
		STA $62					;/
		LDA #$18				;\ Set shell immunity timer to 24 frames
		STA $1570,x				;/
		LDA #$08				;\ Set "don't interact"-timer for sprite B
		STA $1564,x				;/
		LDA #$0A				;\ Set sprite B status to kicked
		STA $14C8,y				;/
		JSR COMPARE_X
		BPL +					; Branch if player 2 is to the right of sprite B
		LDA #$01				;\ Direction = 0x01
		STA $157C,y				;/
		LDA #$32				;\ Xspeed = 0x32
		STA $00B6,y				;/
		LDA #$10				; Xdisp = 0x10
		BRA ++
	+	LDA #$00				;\ Direction = 0x00
		STA $157C,y				;/
		LDA #$CE				;\ Xspeed = 0x32
		STA $00B6,y				;/
		LDA #$F0				; Xdisp = 0xF0
	++	LDY #$00				; Ydisp = 0x00
		JMP CONTACTGFX				; Display contact GFX

.Side		LDA $1528,x
		BEQ .Hurt
.Return2	RTS
.Hurt		JMP HURT

.Normal		JSR COMPARE_Y
		CLC
		ADC #$06
		BPL .Side

.Top		LDA $009E,y
		CMP #$08
		BPL .TopKicked

		PHY
		TYX				; X = sprite B index
		JSL $02A9DE			; Get new sprite number into Y
		BMI .TopKicked			; If there are no empty slots, don't spawn

		LDA $9E,x
		SEC
		SBC #$04
		STA $009E,y			; Store sprite number for new sprite

		LDA #$08			;\ Set new sprite status to normal
		STA $14C8,y			;/

		LDA $E4,x			;\
		STA $00E4,y			; |
		LDA $14E0,x			; |
		STA $14E0,y			; | Set positions
		LDA $D8,x			; |
		STA $00D8,y			; |
		LDA $14D4,x			; |
		STA $14D4,y			;/

		PHX				;\
		TYX				; | Reset tables for new sprite
		JSL $07F7D2			; |
		PLX				;/

		LDA #$10			;\
		STA $1528,y			; |
		STA $1540,y			; | Some sprite tables that SMW normally sets
		LDA #$01			; |
		STA $1570,y			;/

		LDA #$10			;\ Temporarily disable sprite interaction for new sprite
		STA $1564,y			;/
		LDA $164A,x			;\ Copy "is in water" flag from sprite B
		STA $164A,y			;/
		LDA #$02			;\
		STA $1540,y			; | Some sprite tables
		LDA #$01			; |
		STA $00C2,y			;/
		LDX $60				; Load player 2 index in X

		JSR COMPARE_X
		BMI +
		LDA #$01			; Load 1 into a (new sprite will face right)
		BRA ++
	+	LDA #$00
	++	PHX				; Preserve player 2 index
		STA $157C,y			; Make new sprite face away from sprite A
		TAX				; X = new sprite direction
		LDA KOOPA_XSPEED,x		; Load X speed table indexed by direction
		STA $00B6,y			; Store to new sprite X speed
		PLX				; Restore player 2 index
		PLY

.TopKicked	LDA #$09			;\ Stun sprite B
		STA $14C8,y			;/
		LDA $009E,y			;\
		CMP #$08			; | Check if sprite B is a Koop
		BMI .DontStun			;/
		LDA #$FF			;\ Stun sprite B if it is a Mecha Koopa or a Buzzy Beetle
		STA $1540,y			;/

.DontStun	LDA #$08			;\ Prevent interaction for 08 frames
		STA $1564,y			;/

		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/

		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX
		JSR INCREMENT_KILLS
		JMP BOUNCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PARAKOOPACOLOR:	db $04,$04,$05,$05,$07		; This table determines what sprite the parakoopa will turn into

	INT_03:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BNE .NoSpin
		JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL

.NoSpin		JSR COMPARE_Y
		CLC
		ADC #$06
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\
		STA $1564,y			;/ Set "don't interact"-timer for sprite b
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score
		LDA $009E,y			; Load sprite b sprite number
		SEC				;\
		SBC #$08			;/ Subtract base number of Parakoopa sprite numbers
		PHX				; Push player 2 index
		TAX
		LDA PARAKOOPACOLOR,x		; Load new sprite number
		STA $009E,y			; Set new sprite number
		LDA #$01			;\
		STA $14C8,y			;/ Initialize sprite b
		LDA #$08			;\
		STA $1564,y			;/ Set "don't interact"-timer for sprite b
		PLX				; Pull player 2 index
		LDA #$00			; Xdisp = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact star
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BOBOMBXSPEED:	db $2C,$D4

	INT_04:

		LDX $60
		LDY $1695
		LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $1656,y
		BEQ .Side			; Branch if sprite b is exploding
		LDA $14C8,y
		CMP #$08
		BEQ .Normal
		CMP #$09
		BEQ .Stunned
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Obliterate sprite B

.Stunned	LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		LDA #$03			;\ Kick shell sound
		STA $1DF9			;/
		LDA #$40			;\ Set stun timer
		STA $1540,y			;/

		PHX
		JSR COMPARE_X
		BMI +
		LDX #$01
		BRA ++
	+	LDX #$00
	++	LDA BOBOMBXSPEED,x
		STA $00B6,y
		LDA #$10
		STA $1564,y
		PLX
		RTS

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Normal		LDA $61
		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC				;\ Standard stomp threshold
		ADC #$06			;/
		BPL .Side

		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		LDA $009E,y
		CMP #$40
		BEQ .ParaBomb
		LDA #$09			;\
		STA $14C8,y			; | Regular bobomb code (stuns it)
		BRA .Shared			;/

.ParaBomb	LDA #$0D			;\ Sprite = Bobomb
		STA $009E,y			;/
		LDA #$01			;\ Initialize sprite B
		STA $14C8,y			;/
		PHX
		TYX
		JSL $07F7D2			; Reset sprite tables
		PLX

.Shared		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact star
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GOOMBAXSPEED:	db $2C,$D4

	INT_05:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Normal
		CMP #$09
		BEQ .Stunned
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill count and give score
		JMP SPINKILL			; Exterminate sprite B

.Stunned	LDA $1490			;\
		BEQ +				; | Check star
		JMP STARKILL			;/
	+	LDA #$03			;\ Kick enemy sound
		STA $1DF9			;/
		JSR COMPARE_X
		BMI +
		LDX #$01
		BRA ++
	+	LDX #$00
	++	LDA GOOMBAXSPEED,x
		STA $00B6,y
		LDA #$F0			;\ Set some Yspeed
		STA $00AA,y			;/
		LDA #$10			;\ Prevent sprite B from interacting for 0x10 frames
		STA $1564,y			;/
		LDA #$FF			;\ Stun sprite B
		STA $1540,y			;/
		LDX $60				; X = player 2 index
		RTS

.Normal		LDA $1490			;\
		BEQ +				; | Check star
		JMP STARKILL			;/
	+	LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC
		ADC #$06

		BPL .Side

		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill count and give score

		LDA #$09
		STA $14C8,y

		LDA #$08
		STA $1564,y

		LDA #$FF
		STA $1540,y

		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact star
		JMP BOUNCE			; Give player 2 some bounce

.Side		LDA $1528,x
		BEQ +
		RTS
	+	LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_06:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Destroy sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC
		ADC #$06
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$0F			; Load new sprite number
		STA $009E,y			; Set new sprite number
		LDA #$01			;\
		STA $14C8,y			;/ Initialize sprite b

		PHX
		TYX
		JSL $07F7D2			; Reset sprite tables
		PLX

		LDA #$00			; Xdisp = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact GFX
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_07:

		LDX $1695			;\
		LDA $7FAB9E,x			; | Check for custom projectile
		CMP #$05			; |
		BNE .NoCustomShot		;/
		LDA $C2,x			;\ Don't destroy unless fireball
		BNE .NoCustomShot		;/
		LDA #$04			;\
		STA $14C8,x			; |
		LDA #$1F			; | Destroy custom projectile
		STA $1540,x			; |
		STA $1564,x			;/
.NoCustomShot	LDX $60				;\
		LDA $1528,x			; | Don't hurt player 2 while invulnerable
		BNE .Return			;/
		LDY $1695			; > Load sprite b index in Y
		JMP HURT			; > Hurt sprite a
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_08:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Destroy sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		LDA $009E,y
		CMP #$18
		BEQ .Water
		LDA $164A,y
		BNE .Water
		LDA #$03
		STA $1DF9
		LDA #$03			;\ Pose = kick
		STA $61				;/
		LDA #$0C			;\ Timer = 0X0C (12 frames)
		STA $62				;/
		LDA #$02			;\ Sprite B status = knocked out
		STA $14C8,y			;/
		JMP INCREMENT_KILLS		; Increment kill count and give score

.Water		LDA $1528,x
		BNE .Return
		LDA #$08
		STA $1564,y
		JMP HURT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_09:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Destroy sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC
		ADC #$06
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08
		STA $1564,y
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$10
		STA $1564,y
		LDA #$02
		STA $14C8,y
		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact GFX
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0A:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Destroy sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC
		ADC #$06			; Stomping threshold
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08
		STA $1564,y
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$02			;\ Sprite B status = knocked out
		STA $14C8,y			;/
		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact star
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0B:

		LDX $60
		PHX
		LDX $1695
		STZ $14C8,x
		JSR SET_GLITTER
		LDA $D8,x
		STA $17C4,y
		LDA $E4,x
		STA $17C8,y

		LDA #$01
		STA $1DFC			; Play "collect coin"-sound
		INC $13CC			; Add 1 to coin counter
		PLX
		LDA #$06			;\ Score sprite to spawn
		STA $00				;/
		STZ $01				; Ignore kill count
		JMP GIVE_SCORE			; Spawn score sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0C:

		LDX $60
		LDY $1695
		LDA $1632,y
		BNE .Return			; Don't process interaction while sprite B is behind scenery
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Obliterate sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC
		ADC #$05
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		LDA #$02
		STA $14C8,y			; Set sprite B status to knocked out

		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$02
		STA $14C8,y
		LDA #$00
		STA $00AA,y
		STA $00B6,y
		LDY #$08
		JSR CONTACTGFX
		JMP BOUNCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0D:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$0B
		BEQ .Return
		JSR COMPARE_Y
		CLC
		ADC #$06
		BMI .Top

.Side		JSR COMPARE_X
		BMI .Left
		LDA $1588,x
		ORA #$02			; Set sprite is blocked to the left
		STA $1588,x
		RTS

.Left		LDA $1588,x
		ORA #$01			; Set sprite is blocked to the right
		STA $1588,x
		RTS

.Top		STZ $61				;\
		STZ $62				;/ Reset pose data
		LDA $AA,x
		BMI .Return
		LDA $009E,y
		CMP #$3E
		BEQ .POW
		LDA $163E,y
		BNE .Return
		LDA #$11			;\
		STA $163E,y			;/ Process player 2 interaction
		LDA #$08			;\
		STA $1DFC			;/ Play springboard sound
		RTS

.POW		LDA $14C8,y
		CMP #$09
		BNE .Return
		LDA $163E,y
		BNE .Return
		STZ $AA,x
		LDA #$1F			;\ Push P-switch
		STA $163E,y			;/
		STA $1564,y			; Set "don't interact"-timer
		LDA #$0B			;\ Play switch sound
		STA $1DF9			;/
		LDA #$0E			;\ Change music
		STA $1DFB			;/

		LDA $15F6,y
		CMP #$02
		BEQ .Silver
		LDA #$B0			;\ Set P-switch timer
		STA $14AD			;/
		RTS

.Silver		LDA #$B0			;\ Set silver switch timer
		STA $14AE			;/
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	SKELETON_HITBOX:	db $06,$04,$06

	INT_0E:

		LDX $60
		LDY $1695
		LDA $1534,y
		BNE .Return
		LDA $14C8,y
		CMP #$08
		BNE .Return
		LDA $009E,y			;\
		CMP #$31			; |
		BNE .Process			; | Always get hurt when touching Bony Beetle with spikes out
		LDA $1540,y			; |
		BEQ .Process			; |
		CMP #$6E			; |
		BMI .Side			;/

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61				;\
		CMP #$02			; |
		BEQ .Top			; | Don't hurt player 2 during Shell Bash or ground pound
		CMP #$06			; |
		BEQ .Top			;/
		LDA $009E,y
		SEC
		SBC #$30
		PHA

		JSR COMPARE_Y
		PLX
		CLC
		ADC SKELETON_HITBOX,x		; Dry Bones (#$30 and #$32) add 6, Bony Beetle (#$31) adds 4
		BMI .Top

.Side		LDX $60
		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		LDX $60
		LDA #$01
		STA $1534,y
		LDA #$FF
		STA $1540,y
		LDA #$07			;\ Play "Dry Bones collapse"-sound
		STA $1DF9			;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$00
		LDY #$08
		JSR CONTACTGFX
		LDA $61
		CMP #$06
		BEQ .Return
		JMP BOUNCE

.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0F:

		LDX $60
		LDY $1695
		JSR COMPARE_Y

		CLC
		ADC #$08
		BPL .Return			; Don't interact if touching from side
		LDA $1504,x			;\ Return if player 2 is jumping (let him jump through/off platform)
		BNE .Return			;/
		LDA $C2,x
		BMI .Return			; Return if priority bit is set
		STY $C2,x			; tttt bits = platform index

		LDA $00D8,y			;\
		SEC				; |
		SBC #$0E			; |
		STA $D8,x			; | Player 2 Ypos = solid sprite Ypos - 14
		LDA $14D4,y			; |
		SBC #$00			; |> This subtracts 01 if carry is clear
		STA $14D4,x			;/
		LDA $1588,x			;\
		ORA #$04			; | Set player 2 blocked from beneath
		STA $1588,x			;/
		LDA $009E,y			;\
		CMP #$57			; |
		BEQ .Vertical			; | Check for vertical platforms
		CMP #$58			; |
		BEQ .Vertical			;/
		CMP #$BA
		BEQ .Timed
		RTS

.Vertical	LDA $C2,x			;\
		ORA #$40			; | Direction = vertical
		STA $C2,x			;/
		RTS

.Timed		LDA #$01			;\
		STA $1528,y			; |
		LDA #$10			; | Start plaform (source: $038DBB in all.log)
		STA $00C2,y			; |
		STA $00B6,y			;/
		RTS

.Return		STZ $C2,x			; Reset pd--iiii
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_10:

		LDX $60
		LDY $1695			; Load sprite b index in Y
		LDA $14C8,y
		CMP #$08
		BEQ .Process			; Only interact if status is normal
.Return		LDX $60				; Make sure that X = player 2 index
		RTS

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06			;\ Chuck is not crushed by ground pound
		BNE .NoSpin			;/
		STZ $61				;\ Clear pose data
		STZ $62				;/
		BRA .Top			; Handle interaction

.NoSpin		JSR COMPARE_Y
		CLC				;\ Stomp threshold is 0x0C (12) pixels
		ADC #$0C			;/
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		LDA #$05			;\ Set "don't interact"-flag to 5 frames
		STA $1564,y			;/
		LDA #$02			;\ Play "spin jump on spiky enemy"-sound
		STA $1DF9			;/
		LDA #$00			;\
		LDY #$08			;/ Set up contact star
		JSR CONTACTGFX			; Display contact star
		JSR BOUNCE

		LDX $1695			; Load sprite B index in X

		STZ $163E,x			; Reset unknown sprite table
		LDA $C2,x			;\
		CMP #$03			; |
		BEQ .Return			;/> Return if sprite b is still recovering from a stomp
		INC $1528,x			; Increment sprite B stomp count
		LDA $1528,x
		CMP #$03
		BEQ .Kill
		LDA #$28			;\ Play enemy stomp sound
		STA $1DFC			;/
		LDA #$03
		STA $C2,x			; Stun sprite B
		LDA #$03
		STA $1540,x			; Set sprite B stunned timer to 3 frames
		STZ $1570,x			; Reset follow player timer
		LDX $60				; X = player 2 index
		LDY $1695
		JSR COMPARE_X
		BMI .BounceLeft

		LDA #$20
		STA $B6,x			; Give sprite a some X speed (the same amount Mario gets)
		RTS

.BounceLeft	LDA #$E0
		STA $B6,x			; Give sprite a some X speed (the same amount Mario gets)
		RTS

.Kill		STZ $AA,x			; Reset sprite B Y speed
		STZ $B6,x			; Reset sprite B X speed
		LDA #$02			;\ Sprite B status = knocked out
		STA $14C8,x			;/
		LDX $60				; X = player 2 index
		LDA #$03			;\ Kicked shell sound
		STA $1DF9			;/
		LDA #$08			;\ Score sprite to spawn
		STA $00				;/
		STZ $01				; Don't include kill count
		JMP GIVE_SCORE			; Spawn score sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_11:

		LDX $1695			; > X = goal sprite index
		JSL $00FA80			; > Run goal sprite code
		LDX $60				;\ Set sprite indexes
		LDY $1695			;/
		LDA #$00			;\ Erase goal
		STA $14C8,y			;/
		STZ $71				; > Clear Mario animation
		STZ $1490			; > Clear star timer
		LDA $009E,y			;\
		CMP #$4E			; | I don't know if this is necessary, might be
		BNE .NoSphere			;/
		BRA .NoSecret			; > Spheres don't activate secrets
.NoSphere	LDA $187B,y			;\
		LSR #2				; | Set secret exit flag
		STA $141C			;/
.NoSecret	LDA #$04			;\ Change music
		STA !SPC3			;/
		LDA #$FF			;\
		STA $0DDA			; | Set music backup and end level timer
		STA $1493			;/
		STA $62				;\
		LDA #$04			; | Stun player 2
		STA $61				;/
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_12:

		LDX $60				; X = player 2 index
		LDY $1695			; Y = sprite B index
		LDA $14C8,y
		CMP #$08
		BNE .Return			; Only interact if sprite b status is normal
		LDA $00C2,y			;\
		BEQ .Return			; | Only interact if sprite b has emerged from the ground
		LDA $1540,y			; |
		BEQ .Process			;/
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill count and give score
		JMP SPINKILL			; Eradicate sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y			; Load Ya-Yb
		CLC				;\ Stomp threshold is 6 pixels
		ADC #$06			;/
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$02			;\ Set sprite b status to knocked out
		STA $14C8,y			;/

		LDA #$00			; Xdisp = 0x00
		STA $00AA,y			; Yspeed = 0x00
		STA $00B6,y			; Xspeed = 0x00
		LDY #$08			; Ydisp = 0x08
		JSR CONTACTGFX			; Display contact GFX
		JMP BOUNCE			; Give player 2 some bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DINO_HITBOX:	db $14,$06

	INT_13:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; Disintegrate sprite B

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		STA $00
		LDA $009E,y
		SEC
		SBC #$6E
		TAX
		LDA DINO_HITBOX,x
		CLC
		ADC $00
		BMI .Top
		LDX $60

.Side		LDX $60
		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill count and give score

		LDA $009E,y
		CMP #$6E
		BEQ .Large

.Small		LDA #$03			;\
		STA $14C8,y			; | Sprite status = smushed for 48 frames
		LDA #$30			; |
		STA $1540,y			;/
		BRA .Shared

.Large		LDA #$6F			;\ Sprite number
		STA $009E,y			;/
		LDA #$01			;\ Init routine
		STA $14C8,y			;/
		PHY
		PHX
		TYX
		JSL $07F7D2			; Reset sprite tables
		PLX
		PLY
		LDA #$02			;\ Action = breathing fire upwards
		STA $00C2,y			;/

.Shared		LDA #$00
		STA $00AA,y
		STA $00B6,y
		LDY #$08
		JSR CONTACTGFX
		JMP BOUNCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_14:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BEQ .Process
.Return		RTS

.Side		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		JSR COMPARE_Y
		BMI .Top

.Top		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score

		LDA #$02			;\ Sprite stauts = knocked out
		STA $14C8,y			;/
		LDA #$00
		STA $00AA,y
		STA $00B6,y
		LDY #$08
		JSR CONTACTGFX
		JMP BOUNCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	REX_HITBOX:	db $06,$06

	INT_15:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BNE .Return
		LDA $1558,y
		BEQ .Process			; Return if smush timer is set
.Return		RTS

.SpinKill	JSR INCREMENT_KILLS		; Increment kill counter and give score
		JMP SPINKILL			; DESTROY DESTROY!!

.Process	LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		LDA $61
		CMP #$02
		BNE .NoBash
		JSR INCREMENT_KILLS
		JMP BASHKILL
.NoBash		CMP #$06
		BEQ .SpinKill

		JSR COMPARE_Y
		CLC : ADC #$06
		BMI .Top

.Side		LDX $60
		LDA $1528,x
		BNE .Return
		LDA #$08			;\ Prevent sprite B from interacting for 0x08 frames
		STA $1564,y			;/
		JMP HURT

.Top		TYX : LDA $7FAB9E,x
		LDX $60
		CMP #$AB
		BNE .NotAggro

		LDA $00C2,y
		INC A
		STA $00C2,y
		CMP #$03
		BEQ .Small
		LDA #$20
		STA $1DF9
		BRA +

.NotAggro	LDA $00C2,y
		BNE .Small

.Large		LDA #$01			;\ Sprite state = half smushed
		STA $00C2,y			;/
		LDA #$0C			;\ Set half smush timer
		STA $1FE2,y			;/
		BRA .Shared

.Small		LDA #$02
		STA $00C2,y
		LDA #$0C
		STA $1602,y
		LDA #$00
		STA $1570,y
		LDA #$1F			;\ Set smush timer
		STA $1558,y			;/

.Shared		PHY				;\
		LDY $1626,x			; |
		LDA STOMPSOUND_TABLE,y		; | Play enemy stomp sound
		STA $1DF9			; |
		PLY				;/
		JSR INCREMENT_KILLS		; Increment kill counter and give score
	+	LDA #$08			;\ Prevent sprite B from interacting
		STA $1564,y			;/
		LDA #$00
		LDY #$00
		JSR CONTACTGFX
		JMP BOUNCE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_16:

		LDX $60
		LDY $1695
		LDA $1602,y
		BEQ .Hurt

		JSR COMPARE_Y
		CLC
		ADC #$08
		BPL .ReturnPlat			; Don't interact if touching from side
		LDA $1504,x			;\ Return if player 2 is jumping (let him jump through/off platform)
		BNE .ReturnPlat			;/
		STY $C2,x			; tttt bits = platform index
		LDA $00D8,y			;\
		SEC				; |
		SBC #$0E			; |
		STA $D8,x			; | Player 2 Ypos = solid sprite Ypos - 14
		LDA $14D4,y			; |
		SBC #$00			; |> This subtracts 01 if carry is clear
		STA $14D4,x			;/
		LDA $1588,x			;\
		ORA #$04			; | Set player 2 blocked from beneath
		STA $1588,x			;/
		RTS

.Hurt		LDA $1528,x
		BNE .Return
		JMP HURT

.ReturnPlat	STZ $C2,x			; Reset pd--iiii
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CARROT_PLAT1:		db $20,$1E,$1C,$1A,$18,$16,$14,$12
				db $10,$0E,$0C,$0A,$08,$06,$04,$02
				db $00,$00,$00,$00,$00,$00,$00,$00

	INT_17:

		LDX $60
		LDY $1695
		JSR COMPARE_Y
		CLC
		ADC #$08
		BPL .Return
		STY $C2,x			; iiii -bits = platform index

		JSR COMPARE_X			; A = player 2 X - platform X
		CLC
		ADC #$04
		BPL .Pos
.Neg		LDA #$00			; Don't accept negative values

.Pos		PHY
		LSR A
		TAY
		LDA CARROT_PLAT1,y
		PLY

		STA $00
		LDA $00D8,y
		CLC
		ADC $00
		STA $D8,x
		LDA $14D4,y
		ADC #$00
		STA $14D4,x
		LDA $D8,x
		SEC
		SBC #$10
		STA $D8,x
		LDA $14D4,x
		SBC #$00
		STA $14D4,x

		LDA $1588,x			;\
		ORA #$04			; | Set player 2 blocked from beneath
		STA $1588,x			;/
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_18:

		LDX $60
		LDY $1695
		LDA $14C8,y
		CMP #$08
		BNE .Return
		LDA $1490
		BEQ .NoStar
		JMP STARKILL
.NoStar		JSR COMPARE_Y
		CLC
		ADC #$14
		BMI .Top

.Side		LDA $1528,x
		BNE .Return
		JMP HURT

.Top		STY $C2,x
		LDA $00D8,y
		SEC
		SBC #$1A
		STA $D8,x
		LDA $14D4,y
		SBC #$00
		STA $14D4,x
		LDA $1588,x
		ORA #$04
		STA $1588,x
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_19:

		LDX $60				; > X = player 2 index
		LDY $1695			; > Y = sprite B index
		LDA #$00			;\ Erase sprite B
		STA $14C8,y			;/
		LDA $7FA38D			;\
		ORA #$40			; | Set improved senku bit
		STA $7FA38D			;/
		LDA #$08			;\
		STA $61				; | Set upgrade animation
		LDA #$2C			; |
		STA $62				;/
		RTS				; > Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_1A:

		LDX $60
		LDY $1695
		STZ $01				; > Don't include kill count
		LDA #$00			;\ Erase powerup
		STA $14C8,y			;/
		LDA $009E,y
		CMP #$78
		BEQ .1UP
		CMP #$76			;\ Branch unless star
		BNE .Powerup			;/
		LDA #$FF			;\ Set star timer
		STA $1490			;/
		BRA +
.Powerup	LDA $0D9C			;\
		CMP #$03			; | Give HP
		BEQ +				; |
		INC $0D9C			;/
	+	LDA #$0A
		STA !SPC1
		DEC A
		STA $00
		JMP GIVE_SCORE


.1UP		LDA #$0D
		STA $00
		JMP GIVE_SCORE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==========================;
;GRAPHICS ROUTINE BUILD 3.2;
;==========================;

PROPERTY_TABLE:	db $6E,$2E		; Indexed by direction and ORA'd to property byte
TILEMAP:	db $80,$C2		; First 16x16 tile, second 16x16 tile (both are dynamic tiles)
XDISP:		db $00,$10		; First tile, second tile
YDISP:		db $00,$F0		; Lower tile, upper tile

PALTABLE:	dw .Purple
		dw .UpGrade1
		dw .UpGrade2
		dw .UpGrade3
		dw .UpGrade4
		dw .UpGrade5
		dw .UpGrade6
		dw $0000
		dw .PurpleSenku
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw $0000
		dw $0000

.Green		dw $0000,$7FFF
		dw $0000,$01E0
		dw $02E0,$03E0
		dw $00B7,$023F
.Red		dw $0000,$7FFF
		dw $0000,$0011
		dw $0017,$001F
		dw $00B7,$023F
.Blue		dw $0000,$7FFF
		dw $0000,$6D08
		dw $6DAD,$7E31
		dw $00B7,$023F
.Yellow		dw $0000,$7FFF
		dw $0000,$01FF
		dw $031F,$03FF
		dw $00B7,$023F
.Purple		dw $0000,$7FFF
		dw $0000,$7C54
		dw $654E,$6DB1
		dw $00B7,$023F
.PurpleSenku	dw $0000,$7FFF
		dw $0000,$7C54
		dw $654E,$6DB1
		dw $6DB1,$023F

.UpGrade1	dw $023F,$0000
		dw $0000,$7FFF		; < first here is unused
		dw $7C54,$654E
		dw $6DBE,$00B7
.UpGrade2	dw $00B7,$023F
		dw $0000,$0000
		dw $7FFF,$7C54
		dw $654E,$6DBE
.UpGrade3	dw $6DBE,$00B7
		dw $0000,$023F
		dw $0000,$7FFF
		dw $7C54,$654E
.UpGrade4	dw $654E,$6DBE
		dw $0000,$00B7
		dw $023F,$0000
		dw $7FFF,$7C54
.UpGrade5	dw $7C54,$654E
		dw $0000,$6DBE
		dw $00B7,$023F
		dw $0000,$7FFF
.UpGrade6	dw $7FFF,$7C54
		dw $0000,$654E
		dw $6DBE,$00B7
		dw $023F,$0000



GRAPHICS:	LDA $1528,x		;\
		AND #$02		; | Make sprite invisible for 2 frames every 2 frames after taking damage
		BEQ +			; |
		RTS			;/

	+	LDA $61			;\
		CMP #$08		; |
		BNE .NoUpGrade		; |
		LDA !Palette		; |
		AND #$F0		; | Handle upgrade palette
		STA $00			; |
		LDA $62			; |
		LSR #2			; |
		ORA $00			; |
		STA !Palette		; |
		.NoUpGrade		;/

		LDA $14			;\
		AND #$03		; | Only update star power palette every four frames
		BNE ++			;/
		LDA $1490		;\
		BEQ +			; |
		LDA !Palette		; |
		AND #$F0		; |
		STA $00			; |
		LDA !Palette		; |
		AND #$0F		; | Handle star power palette
		CMP #$04		; |
		BEQ +			; |
		INC A			; |
		ORA $00			; |
		STA !Palette		; |
		BRA ++			; |
	+	LDA #$0F		; |
		TRB !Palette		;/
	++	LDA !Palette
		LSR #4
		STA $00
		LDA !Palette
		AND #$0F
		CMP $00
		BEQ ++
		PHA
		ASL A
		TAX
		ASL #3
		STA !Palette
		PLA
		TSB !Palette
		PHB : LDA #!VRAMbank
		PHA : PLB
		LDY #$00
	-	LDA.w !CGRAMtable+$00,y
		BEQ +
		TYA
		CLC : ADC #$06
		TAY
		BRA -
	+	LDA.w !CGRAMtable+$01,y
		BEQ +
		TYA
		CLC : ADC #$06
		TAY
		BRA -
	+	LDA #$10				;\ Lo byte of data size
		STA.w !CGRAMtable+$00,y			;/
		LDA #$00				;\ Hi byte of data size
		STA.w !CGRAMtable+$01,y			;/
		LDA.l PALTABLE,x			;\ Lo byte of source
		STA.w !CGRAMtable+$02,y			;/
		LDA.l PALTABLE+$01,x			;\ Hi byte of source
		STA.w !CGRAMtable+$03,y			;/
		PHK : PLA				;\ Source bank
		STA.w !CGRAMtable+$04,y			;/
		LDA #$F8				;\ Dest CGRAM
		STA.w !CGRAMtable+$05,y			;/
		PLB					; > Restore bank
		LDX $60					; > X = sprite index
	++	JSR GET_DRAW_INFO	; $00 = Xpos, $01 = Ypos, Y = OAM index (0x00C)
		LDA $15C4,x		;\
		BEQ +			; | Don't draw sprite while offscreen
		RTS			;/
	+	JSR GET_TILEMAP		; Store tiles to load from SP.bin to $13E6 and $13E7 (Uploaded during NMI)
		LDA $157C,x		;\ Store direction to scratch RAM
		STA $02			;/
		LDA $1588,x		;\
		AND #$04		; |
		BEQ +			; |
		LDA $03			; |
		CMP #$04		; | Invert direction while sliding
		BNE +			; |
		LDA $02			; |
		EOR #$01		; |
		STA $02			;/

	+	PHX			; Preserve sprite index
		LDX #$01		; Set up loop

.Loop		PHX			; Preserve loop count
		LDA $0D9C		;\ Use full Xdisp table when unequipped
	;	BEQ +			;/
		LDX #$00		; Use half Xdisp table
	+	LDA $02			;\ Don't invert Xdisp while facing left
		BNE +			;/
		LDA XDISP,x		;\
		EOR #$FF		; |
		BRA .WriteX		; |
	+	LDA XDISP,x		; | Calculate Xpos
.WriteX		CLC			; |
		ADC $00			; |
		STA $0300,y		;/
		PLX			; Restore loop count

		PHX			; Preserve loop count
		LDA $0D9C		;\ Use full Ydisp table when equipped
	;	BNE +			;/
	BRA +
		LDX #$00		; Use half Ydisp table
	+	LDA YDISP,x		;\
		CLC			; | Calculate Ypos
		ADC $01			; |
		STA $0301,y		;/

		PLX			; Restore loop count
		LDA TILEMAP,x		;\ Tile number
		STA $0302,y		;/

		PHX			; Preserve loop count
		LDX $02			;\
		LDA PROPERTY_TABLE,x	; | > Set property byte
		STA $0303,y		;/
		LDA $71			;\
		CMP #$07		; |
		BEQ +			; |
		LDA $0F6E		; |
		BNE +			; |
		LDA $61			; |
		CMP #$07		; | Calculate priority
		BEQ +			; |
		LDA $88			; |
		BEQ ++			; |
		LDA $89			; |
		CMP #$04		; |
		BMI ++			; |
	+	LDA $0303,y		; |
		AND #$CF		; |
		STA $0303,y		;/
	++	PLX			; Restore loop count

		INY			; Increment OAM index
		INY
		INY
		INY
		DEX			; Decrement loop count
		BPL .Loop

		PLX			; X = player 2 sprite index
		LDA #$01		; A = Number of tiles to draw (2)
		LDY #$02		; Y = Tile size (16x16)
		JSL $01B7B3		; Draw tiles

.Return		RTS

;===================;
;GET TILEMAP ROUTINE;
;===================;
ANIMATION_FREQ:	db $08,$08,$04,$04
JUMP_FRAME:	db $01,$02,$03,$04

TRUE_TILEMAP:	db $00,$EE		; Idle
		db $02,$EE		; Walking (alternates between this and idle)
		db $04,$EE		; Kick
		db $2C,$2E		; Jump frame 5 (used when floatiness has run out)
		db $0A,$EE		; Slide, jump frame 1
		db $0C,$EE		; Jump frame 2
		db $0E,$EE		; Jump frame 3
		db $2A,$EE		; Jump frame 4
		db $20,$EE		; Swim frame 1
		db $22,$EE		; Swim frame 2
		db $24,$EE		; Hurt, stunned
		db $84,$86		; Ashura Senku frame 1
		db $A4,$A6		; Ashura Senku frame 2

.Shell		db $62,$42		; Idle
		db $64,$44		; Walking (alternates between this and idle)
		db $64,$44		; Kick
		db $60,$40		; Jump frame 5, Slide
		db $E4,$EE		; Jump frame 1
		db $E6,$EE		; Jump frame 2
		db $E0,$EE		; Jump frame 3
		db $E2,$EE		; Jump frame 4
		db $62,$42		; Swim frame 1
		db $64,$44		; Swim frame 2
		db $60,$40		; Hurt, stunned
		db $A0,$80		; Ashura Senku frame 1
		db $A2,$82		; Ashura Senku frame 2
		db $C0,$EE		; Shell Bash
		db $E4,$EE		; Duck


GET_TILEMAP:	PHX			; Preserve sprite index
		STZ $03			; Reset TRUE_TILEMAP index
		STZ $04			; Reset ANIMATION_FREQ

		LDA $0DA3
		AND #$03		; Check left/right on joypad 2 (all frames)
		BNE .Walk
		LDA $B6,x
		BEQ .Jump

.Walk		LDA $61
		CMP #$01
		BEQ .Jump
		LDA $B6,x
		BPL +
		EOR #$FF
		INC A
	+	LSR #4
		TAX			; X = ANIMATION_FREQ index
		LDA ANIMATION_FREQ,x	; Load animation frequency
		STA $04
		LDA $14
		AND $04
		BEQ .Jump
		INC $03			; Increment tilemap index

.Jump		LDX $60			; X = sprite index
		LDA $1588,x
		AND #$04		; Check if sprite is touching the ground
		BNE .Kick		; Branch if sprite is on the ground
		LDA $164A,x
		ORA $85
		BNE .Swim

		STZ $05
		LDA $AA,x		; Load Yspeed
		BPL +
		LDA $14			;\
		LSR #3			; |
		AND #$03		; | Load jump frame based on frame counter
		TAX			; |
		LDA JUMP_FRAME,x	;/
		STA $05
	+	LDA $05
		CLC : ADC #$03		; Base index for jump frames in TRUE_TILEMAP
		STA $03
		BRA .Kick

.Swim		LDA $0DA3		;\
		AND #$0F		; |
		BNE +			; | Use duck animation if no buttons are held
		LDA #$0E		; |
		STA $03			; |
		JMP .Return		;/
	+	LDA $14			;\
		LSR #3			; |
		AND #$03		; | Load swim frame based on frame counter
		TAX			; |
		LDA JUMP_FRAME,x	;/
		CLC : ADC #$03		; > Add base index for jump frames in TRUE_TILEMAP
		STA $03
		BRL .Return

.JumpShell

.Kick		LDA $61
		CMP #$03
		BNE .Slide
		LDA #$02
		STA $03

.Slide		LDA $164A,x
		ORA $85
		BNE .Hurt
		LDA $61
		BEQ +
		CMP #$05
		BEQ +
		BRA .Hurt
	+	LDA $1588,x
		AND #$04
		BEQ .Hurt
		LDA $B6,x
		BEQ .Hurt
		BMI +

		CMP #$10
		BMI .Hurt
		LDA $0DA3
		AND #$02
		BEQ .Hurt
		BRA .DrawSlide

	+	EOR #$FF
		CMP #$10
		BMI .Hurt
		LDA $0DA3
		AND #$01
		BEQ .Hurt

.DrawSlide	JSR TURNSMOKE
	;	LDA $0D9C
	;	BNE .SlideShell
		LDA #$03
		STA $03
		BRA .Hurt

.SlideShell

.Hurt		LDA $61
		CMP #$04
		BNE .Duck
		LDA #$0A
		STA $03

.Duck	;	LDA $61
	;	CMP #$06
	LDA $0DA3
	AND #$04
		BEQ .Senku
		LDA $1588,x
		AND #$04
		BEQ .Senku
		LDA $B6,x
		BNE .Senku
		LDA #$0E
		STA $03

.Senku		LDA $61
		DEC A
		BEQ +
		DEC A
		BNE .Return
		LDA #$0C
		STA $03
		BRA .Return
	+	LDA #$0B			; Initiating Ashura Senku
		STA $03

.Return		PHY				; Push OAM index
		PHB : LDA #!VRAMbank		;\ Wrap bank
		PHA : PLB			;/
		LDA $03
		ASL A
		TAX
		LDA.l TRUE_TILEMAP_Shell,x
		STA $0E
		LDA.l TRUE_TILEMAP_Shell+1,x
		STA $0F
		LDX #$00
		REP #$20
	-	LDA.l .VRAMindex,x : TAY
		LDA.w !VRAMtable+$00,y
		BEQ +
		INX
		BRA -
	+	LDA.w #$0040
		STA.w !VRAMtable+$00,y
		LDA $0D
		AND #$FF00
		LSR #3
		CLC : ADC.w #GFX_Source
		STA.w !VRAMtable+$02,y
		PHA
		LDA.w #GFX_Source>>16
		STA.w !VRAMtable+$04,y
		LDA #$6800
		STA.w !VRAMtable+$05,y
		INX
	-	LDA.l .VRAMindex,x : TAY
		LDA.w !VRAMtable+$00,y
		BEQ +
		INX
		BRA -
	+	LDA.w #$0040
		STA.w !VRAMtable+$00,y
		PLA
		CLC : ADC.w #$0200
		STA.w !VRAMtable+$02,y
		LDA.w #GFX_Source>>16
		STA.w !VRAMtable+$04,y
		LDA #$6900
		STA.w !VRAMtable+$05,y
		INX
	-	LDA.l .VRAMindex,x : TAY
		LDA.w !VRAMtable+$00,y
		BEQ +
		INX
		BRA -
	+	LDA.w #$0040
		STA.w !VRAMtable+$00,y
		LDA $0E
		AND #$FF00
		LSR #3
		CLC : ADC.w #GFX_Source
		STA.w !VRAMtable+$02,y
		PHA
		LDA.w #GFX_Source>>16
		STA.w !VRAMtable+$04,y
		LDA #$6C20
		STA.w !VRAMtable+$05,y
		INX
	-	LDA.l .VRAMindex,x : TAY
		LDA.w !VRAMtable+$00,y
		BEQ +
		INX
		BRA -
	+	LDA.w #$0040
		STA.w !VRAMtable+$00,y
		PLA
		CLC : ADC.w #$0200
		STA.w !VRAMtable+$02,y
		LDA.w #GFX_Source>>16
		STA.w !VRAMtable+$04,y
		LDA #$6D20
		STA.w !VRAMtable+$05,y
		SEP #$20			; > A 8 bit
		PLB				; Restore bank
		PLY				; Restore OAM index
		PLX				; Restore sprite index
		RTS

.VRAMindex	db $00,$07,$0E,$15,$1C,$23,$2A,$31
		db $38,$3F,$46,$4D,$54,$5B,$62,$69
		db $70,$77,$7E,$85,$8C,$93,$9A,$A1
		db $A8,$AF,$B6,$BD,$C4,$CB,$D2,$D9
		db $E0,$E7,$EE,$F5


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;SUPPORT ROUTINES;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;=================;
;SPIN KILL ROUTINE;
;=================;
SPINKILL:	LDA #$04			; Status = spin killed
		STA $14C8,y
		LDA #$1F			; Spin kill timer
		STA $1540,y
		LDA #$08			; Spin kill sound
		STA $1DF9
		RTS

;=================;
;STAR KILL ROUTINE;
;=================;
STARKILL:	LDA #$02			;\ Status = knocked out
		STA $14C8,y			;/
		LDY $18D2			; > Get star kill count
		CPY #$08			;\
		BCC .Reasonable			; | Don't allow numbers greater than 8
		LDY #$08			;/
.Reasonable	CPY #$08			;\
		BEQ .Return			; | Increment kills
		INY				; |
		STY $18D2			;/
.Return		LDA #$05			;\
		STA $00				; | Prepare to give score
		STY $01				;/
		DEY				;\
		LDA STOMPSOUND_TABLE,y		; | Play kill sound
		STA !SPC1			;/
		JMP GIVE_SCORE			; > Give score

;=================;
;BASH KILL ROUTINE;
;=================;
BASHKILL:	LDA #$02
		STA $14C8,y
		PHX
		PHY
		TYX
		LDA #$08
		LDY #$08
		JSR CONTACTGFX
		PLY
		PLX
		LDA #$03
		STA $1DF9
		RTS

;======================;
;TURN-SMOKE GFX ROUTINE;
;======================;
TURNSMOKE:	PHY
		LDA $1588,x
		AND #$04
		BEQ .Return			; Only spawn turn smoke on ground
		LDA $15A0,x
		ORA $186C,x
		BNE .Return			; Only spawn smoke sprites on screen
		LDA $14
		AND #$03
		BNE .Return
		LDY #$03			; Set up loop

.Loop		LDA $17C0,y			;\
		BEQ .Spawn			; |
		DEY				; | Find empty smoke sprite slot
		BPL .Loop			;/
		PLY
		RTS

.Spawn		LDA #$03			; Smoke sprite to spawn
		STA $17C0,y
		LDA $E4,x			;\
		ADC #$04			; | Spawn at sprite X + 4 pixels
		STA $17C8,y			;/
		LDA $D8,x			;\
		ADC #$0B			; | Spawn at sprite Y + 11 pixels
		STA $17C4,y			;/
		LDA #$13			;\
		STA $17CC,y			;/ Show smoke sprite for 19 frames

.Return		PLY
		RTS

;===================;
;CONTACT GFX ROUTINE;	Load A and Y with offsets before calling this routine (A is Xdisp, Y is Ydisp)
;===================;
CONTACTGFX:	PHY				; Preserve Y offset
		PHA				; Preserve X offset
		LDA $15A0,x
		ORA $186C,x
		BNE .Return			; Only spawn smoke sprite on screen
		LDY #$03			; Set up loop

.Loop		LDA $17C0,y			;\
		BEQ .Spawn			; |
		DEY				; | Find empty smoke sprite slot
		BPL .Loop			;/

.Return		PLA				;\
		PLA				;/ Pull offsets off the stack
		RTS				; Return

.Spawn		LDA #$02			; Load #$02 (contact GFX) in A
		STA $17C0,y
		PLA				; Restore X offset
		CLC
		ADC $E4,x			; Add with sprite Xpos
		STA $17C8,y			; Smoke sprite X = sprite X + X offset
		PLA				; Restore Y offset
		CLC
		ADC $D8,x			; Add with sprite Ypos
		STA $17C4,y			; Smoke sprite Y = sprite Y + Y offset
		LDA #$08
		STA $17CC,y			; Show smoke sprite for 8 frames
		RTS

;==============;
;BOUNCE ROUTINE;
;==============;
BOUNCE:		LDA #$D0			;\ Give sprite Y speed
		STA $AA,x			;/
		STZ $1534,x			; Reset levitated flag

		LDA $0DA3			;\
		AND #$80			; |
		BEQ .Return			; | Enable floatiness if jump is held
		LDA #$14			; |
		STA $1504,x			; |
		LDA #$05			; |
		STA $1510,x			; |
		STZ $151C,x			;/
.Return		RTS

;============;
;HURT ROUTINE;
;============;
HURT:		LDA $1490		;\ Don't hurt player 2 while star is active
		BNE .Return		;/
		LDA #$D8		;\ Give sprite some Y speed
		STA $AA,x		;/
		LDA #$20		;\ Play Yoshi "OW" sound
		STA $1DF9		;/
		LDA #$80		;\ Set invincibility timer
		STA $1528,x		;/
		STZ $1504,x		; Reset floatiness
		STZ $151C,x		; Reset YSPEED index
		DEC $0D9C		;\ Decrement HP and kill player 2 if zero
		BEQ .Kill		;/
		LDA #$04		;\ Pose = hurt
		STA $61			;/
		LDA #$30		;\ Pose timer = 0x30
		STA $62			;/
		JSR COMPARE_X
		BMI .Left
.Right		LDA #$1F		;\ Give sprite some X speed
		STA $B6,x		;/
		RTS
.Left		LDA #$E1		;\ Give sprite some X speed
		STA $B6,x		;/
		RTS

.Kill		LDA #$04
		STA $14C8,x
		LDA #$1F
		STA $1540,x
		LDA #$08
		STA $1DF9
		INC $13D8		; Set player 2 killed flag
.Return		RTS

;==========================;
;COMPARE X POSITION ROUTINE;	Load sprite A Xpos - sprite B Xpos
;==========================;

COMPARE_X:	LDA $14E0,y
		STA $0E
		LDA $00E4,y
		STA $0D
		LDA $14E0,x
		XBA
		LDA $E4,x
		REP #$20
		SEC
		SBC $0D
		SEP #$20
		RTS


;==========================;
;COMPARE Y POSITION ROUTINE;	Load sprite A Ypos - sprite B Ypos
;==========================;

COMPARE_Y:	LDA $14D4,y
		STA $0E
		LDA $00D8,y
		STA $0D
		LDA $14D4,x		; Load high byte of sprite A Ypos
		XBA			; Store it to the high byte of A
		LDA $D8,x		; Load low byte of sprite A Ypos
		REP #$20		; A 16 bit
		SEC			; Set carry
		SBC $0D			; Subtract sprite B Ypos (16 bit)
		SEP #$20		; A 8 bit
		RTS


;===========;
;SET_GLITTER;
;===========;
SET_GLITTER:	LDA $15A0,x
		ORA $186C,x
		BNE .Return
		LDY #$03			; Set up loop

.Loop		LDA $17C0,y			;\
		BEQ .Spawn			; |
		DEY				; | Find empty smoke sprite slot
		BPL .Loop			;/
.Return		RTS

.Spawn		LDA !Map16Index
		BMI .NoMap16
		PHX
		TAX
		LDA XOffsets,x
		STA $00
		LDA YOffsets,x
		STA $01
		PLX
		BRA .Shared

.NoMap16	LDA #$08
		STA $00
		STA $01

.Shared		LDA #$05			; Smoke sprite to spawn
		STA $17C0,y
		LDA $E4,x			;\
		CLC				; |
		ADC $00				; | Spawn at sprite X + 8 pixels
		AND #$F0			; |
		STA $17C8,y			;/
		LDA $D8,x			;\
		CLC				; |
		ADC $01				; | Spawn at sprite Y + 8 pixels
		AND #$F0			; |
		STA $17C4,y			;/
		LDA #$10			;\
		STA $17CC,y			;/ Show glitter sprite for 16 frames
		RTS


;==========;
;GIVE_SCORE;
;==========;
; --Input--
; $00 = score sprite to spawn
; $01 = consecutive enemies killed in one jump, added to $00 (set to zero to ignore)
; Routine spawns score sprite independent of layer 1, one tile above player 2.
; Y contains the score sprite index, so the positions can easily be altered afterwards.

GIVE_SCORE:

		PHY				; Preserve Y
		LDY #$05

.Loop		LDA $16E1,y
		BEQ .Spawn
		DEY
		BPL .Loop
		PLY				; Restore Y
		RTS

.Spawn		LDA $00
		CLC
		ADC $01				; Increase based on kill count
		STA $16E1,y			; Spawn score sprite

		LDA $E4,x			;\
		STA $16ED,y			; |
		LDA $14E0,x			; |
		STA $16F3,y			; |
		LDA $14D4,x			; |
		XBA				; |
		LDA $D8,x			; | score sprite pos = (sprite pos - 16 Ypixels)
		REP #$20			; |
		SEC				; |
		SBC.w #$0010			; |
		SEP #$20			; |
		STA $16E7,y			; |
		XBA				; |
		STA $16F9,y			;/

		LDA #$30			;\ Score sprite Yspeed
		STA $16FF,y			;/

		LDA #$00			;\ Make score sprite independent of layer 1
		STA $1705,y			;/

		PLY				; Restore Y
		RTS

;=================================;
;INCREMENT KILLS AND SCORE ROUTINE;
;=================================;
; --Info--
; Routine that increments kill count and spawns approperiate score sprite.
; Should be JSR's during interaction subroutines.


INCREMENT_KILLS:

		PHY				; Preserve Y
		LDY #$05
.Loop		LDA $16E1,y
		BEQ .Spawn
		DEY
		BPL .Loop
		PLY				; Restore Y
		BRA .IncKills

.Spawn		LDA #$06			; Base score sprite (200)
		CLC
		ADC $1626,x			; Increase based on kill count
		STA $16E1,y			; Spawn score sprite
		LDA $E4,x			;\
		STA $16ED,y			; |
		LDA $14E0,x			; |
		STA $16F3,y			; |
		LDA $14D4,x			; |
		XBA				; |
		LDA $D8,x			; | score sprite pos = (sprite pos - 16 Ypixels)
		REP #$20			; |
		SEC				; |
		SBC.w #$0010			; |
		SEP #$20			; |
		STA $16E7,y			; |
		XBA				; |
		STA $16F9,y			;/
		LDA #$30			;\ Score sprite Yspeed
		STA $16FF,y			;/
		LDA #$00			;\ Make score sprite independent of layer 1
		STA $1705,y			;/
		PLY				; Restore Y

.IncKills	LDA $1626,x
		CMP #$07
		BEQ .MaxKills
		INC $1626,x
.MaxKills	RTS

;===================;
;SPAWN BOUNCE SPRITE;
;===================;
;--Input--
; Load $00 with bounce sprite number
; Load $01 with tile bounce sprite should turn into (uses $009C values)
; Load $02 with 16 bit X offset
; Load $04 with 16 bit Y offset
; Load $06 with bounce sprite timer (how many frames it will exist)
; Bounce sprite of type $7C will be spawned at ($98;$9A) and will turn into $9C

BOUNCE_SPRITE:

		LDY #$03			; Highest bounce sprite index

.Loop		LDA $1699,y			;\
		BEQ .Spawn			; |
		DEY				; | Get bounce sprite number
		BPL .Loop			; |
		RTS				;/

.Spawn		STA $169D,y			; > INIT routine
		STA $16C9,y			; > Layer 1, going up
		STA $16B5,y			; > X speed
		LDA #$C0			;\ Y speed
		STA $16B1,y			;/

		LDA #$08			;\ How many frames bounce sprite will exist
		STA $16C5,y			;/
		LDA $9C				;\ Map16 tile bounce sprite should turn into
		STA $16C1,y			;/

		LDA $7C				;\ Bounce sprite number
		STA $1699,y			;/
		CMP #$07			;\
		BNE .Process			; |
		LDA #$FF			; | Set turn block timer if spawning a turn block
		STA $186C,y			;/

.Process	LDA $9A
		STA $16A5,y
		STA $16D1,y
		LDA $9B
		STA $16AD,y
		STA $16D5,y

		LDA $98
		STA $16A1,y
		STA $16D9,y
		LDA $99
		STA $16A9,y
		STA $16DD,y

		LDA $1699,y			;\
		CMP #$07			; |
		BNE .Return			; | Set Y speed to zero if spawning a turn block
		LDA #$00			; |
		STA $16B1,y			;/

.Return		RTS				; Return

;==============;
;GENERATE_BLOCK;
;==============;
; --Input--
; X = sprite index
; Y = Shatter brick flag (00 does nothing, 01-FF runs the shatter brick routine)
; $00 = Object to spawn from block.
; $02 = 16-bit X offset
; $04 = 16-bit Y offset
; $7C = Bounce sprite to spawn.
; $9C = Block to generate.

GENERATE_BLOCK:

		LDA $98					;\
		PHA					; |
		LDA $99					; |
		PHA					; | Preserve Mario's block values
		LDA $9A					; |
		PHA					; |
		LDA $9B					; |
		PHA					;/
		LDA $00					;\ Preserve object to spawn from block
		PHA					;/
		PHY					; Preserve shatter brick flag

		LDA $D8,x				;\
		STA $00					; |
		LDA $14D4,x				; |
		STA $01					; |
		LDA $14E0,x				; |
		XBA					; |
		LDA $E4,x				; |
		REP #$20				; | Set pos to sprite pos + offset
		CLC					; |
		ADC $02					; |
		AND.w #$FFF0				; |> Ignore lowest nybble
		STA $9A					; |
		LDA $00					; |
		CLC					; |
		ADC $04					; |
		AND.w #$FFF0				; |> Ignore lowest nybble
		STA $98					;/

		SEP #$20				; A 8 bit

		LDA $9C
		BEQ .Shatter

		JSL $00BEB0

.Shatter	PLA					; Restore shatter brick flag
		BEQ .Object
		PHB					;\
		LDA #$02				; |
		PHA					; | Bank wrapper
		PLB					; |
		LDA #$00				; |> Normal shatter (01 will spawn rainbow brick pieces)
		JSL $028663				; |> Shatter Block
		PLB					;/

.Object		PLA
		BEQ .Bounce
		STA $05
		PHB					;\
		LDA #$02				; |
		PHA					; | Bank wrapper
		PLB					; |
		JSL $02887D				; |> Spawn object
		PLB					;/

.Bounce		LDA $7C
		BEQ .Return
		JSR BOUNCE_SPRITE			; Spawn bounce sprite of type $7C at ($98;$9A)

.Return		PLA					;\
		STA $9B					; |
		PLA					; |
		STA $9A					; | Restore Mario's block values
		PLA					; |
		STA $99					; |
		PLA					; |
		STA $98					;/
		RTS

;===================;
;GET_SPRITE_CLIPPING;
;===================;
;This routine checks for contact with other sprites. If there is contact, offsets will be stored to scratch RAM.
;interaction value will be stored to $00.

;$00: Low byte of sprite B's clipping X displacement. If contact is detected interaction number is stored here.
;$01: Low byte of sprite B's clipping Y displacement.
;$02: Sprite B's clipping width.
;$03: Sprite B's clipping height.
;$04: Low byte of sprite A's clipping X displacement.
;$05: Low byte of sprite A's clipping Y displacement.
;$06: Sprite A's clipping width.
;$07: Sprite A's clipping height.
;$08: High byte of sprite B's clipping X displacement.
;$09: High byte of sprite B's clipping Y displacement.
;$0A: High byte of sprite A's clipping X displacement.
;$0B: High byte of sprite A's clipping Y displacement.
;$0C: $08-$0A
;$0D:
;$0E:
;$0F: $04+$06-$00

;			   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			|
;	LO NYBBLE	   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |	HI NYBBLE	|
;	--->		   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			V

INTERACTION_TABLE:	db $01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$00,$05	;| 0
			db $06,$02,$00,$07,$07,$08,$08,$00,$08,$00,$00,$07,$09,$07,$0A,$0A	;| 1
			db $07,$0B,$0C,$0C,$0C,$0C,$07,$07,$07,$00,$07,$07,$00,$00,$07,$0D	;| 2
			db $0E,$0E,$0E,$07,$07,$00,$FF,$07,$07,$07,$07,$07,$07,$07,$0D,$06	;| 3
			db $04,$0F,$0F,$0F,$07,$00,$10,$00,$07,$0F,$11,$0A,$00,$12,$12,$07	;| 4
			db $07,$0A,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$0F,$0F,$0F,$0F,$00	;| 5
			db $00,$0F,$0F,$0F,$00,$07,$07,$07,$07,$00,$00,$00,$00,$00,$13,$13	;| 6
			db $00,$00,$00,$00,$1A,$1A,$1A,$1A,$1A,$00,$00,$11,$00,$00,$00,$00	;| 7
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 8
			db $00,$10,$10,$10,$10,$10,$00,$10,$10,$07,$07,$0A,$0F,$00,$07,$14	;| 9
			db $00,$07,$02,$00,$07,$07,$07,$00,$07,$07,$07,$15,$00,$00,$07,$16	;| A
			db $07,$00,$07,$07,$07,$00,$07,$17,$17,$00,$0F,$0F,$00,$01,$0A,$18	;| B
			db $0F,$00,$07,$07,$0F,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| C
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$07,$02	;| D
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| E
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| F

GET_SPRITE_CLIPPING:

		TXY				;Store X to Y
		PHX				;Push X

		LDA #$FF			;\ This starts the loop off at X = #$FF
		STA $1695			;/

.Loop		LDX $1695
.LoopX		INX				; Increment X (the first time this happens X is set to zero)

		CPX #$0C			;\ Terminate loop if it has been run 12 times this frame
		BEQ .Return			;/

		CPX $60				;\ Loop if sprite is trying to compare clipping values with itself
		BEQ .LoopX			;/

		LDA $14C8,x
		BEQ .LoopX			; Loop if sprite B is non-existent

		LDA $1564,x
		BNE .LoopX			; Loop if sprite B has sprite interaction disabled

		JSL $03B6E5			; Get sprite B clipping values

		LDA $9E,x
		CMP #$AF
		BEQ .BooBlock
		CMP #$BF
		BEQ .BooBlock
		CMP #$B7
		BEQ .CarrotPlat1
		BRA .GetClippingA

.BooBlock	LDA $01				;\
		SEC				; |
		SBC #$06			; |
		STA $01				; | Add 6 to sprite B clipping Y displacement
		LDA $09				; |
		SBC #$00			; |
		STA $09				;/
		BRA .GetClippingA

.CarrotPlat1	PHY
		PHX
		PHY				;\
		TXY				; | X = sprite A index, Y = sprite B index
		PLX				;/
		JSR COMPARE_X			;\
		CLC				; |
		ADC #$04			; |
		BPL +				; |
		LDA #$00			; |
	+	TAX				; |
		LDA CARROT_PLAT1,x		; |
		CLC				; |
		ADC $01				; |
		STA $01				; | Add difference in XPos to sprite B clipping Y displacement
		LDA $09				; |
		ADC #$00			; |
		STA $09				;/
		PLX
		PLY

.GetClippingA	STX $1695			; Store sprite B index
		TYX				; Restore X from Y
		JSL $03B69F			; Get sprite A's clipping values
		JSL $03B72B			; Check for contact (if they touch the carry flag will be set)
		BCC .Loop			; Loop if carry is clear

.SetInt		LDX $1695			; Load sprite B index (sprite B is now confirmed to touch sprite A)
		LDA $9E,x			; Load sprite B's sprite number
		TAX				; Store sprite B's sprite number to X
		LDA INTERACTION_TABLE,x		; Load specific interaction value indexed by sprite number
		STA $00				; Store to scratch RAM
		LDA #$01
		STA $58				; Set contact flag
.Return		PLX
		RTS


;=============;
;GET_DRAW_INFO;
;=============;
SPR_T1: db $0C,$1C
SPR_T2: db $01,$02

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
		CLC
		ADC.w #$0040
		CMP.w #$0180
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
		LDY $15EA,x
		LDA $E4,x
		SEC
		SBC $1A
		STA $00
		LDA $D8,x
		SEC
		SBC $1C
		STA $01
INVALID:	RTS


GFX_Source:
incbin "Kadaal.bin"


namespace off