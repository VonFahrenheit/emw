
;=======;
;DEFINES;
;=======;


	; -- Free RAM --		; Point to unused addresses, please.
					; Don't change addressing mode (16-bit to 24-bit and vice versa).
					; Doing that requires changing some code.

		!AnimToggle		= $60			; 0 = enabled; 1 = disabled

		!CCDMA_SLOTS		= $317F
		!CCDMA_TABLE	 	= $3190
		!CC_BUFFER		= $3700

		!Level			= $610B
		!BossData		= $66F9			; 7 bytes
		!RNG			= $6700			; Updated every frame during level (game mode = 0x14)

		!MarioGFX1		= $6F42			; VRAM address for first Mario GFX upload
		!MarioGFX2		= $6F44			; VRAM address for second Mario GFX upload
		!MarioTileOffset	= $6F46			; Added to Mario's tile numbers
		!MarioPropOffset	= $6F47			; Added to Mario's YXPPCCCT

		!RAMcode_flag		= $6020			; 0x1234 = Execute, anything else ignore

		!GFX_status		= $6022
					; Value at corresponding offset is added to sprite's tile numbers.
			; $00 = ???
			; $01 = Koopa (x2, highest bit is added to property)
			; $02 = Piranha Plant
			; $03 = Rex
			; $04 = Hammer Rex
			; $05 = Hammer (x2, Extended sprite)
			; $06 = Plant Head
			; $07 = Goomba Slave
			; $08 = Thif
			; $09 = Palette 8 CCC bits (corrects palette usage on a level-level basis)
			; $0A = Volcano Lotus Fire (x2)
			; $0B = Bumper (x2, base tile = $100)
			; $0C = Novice Shaman
			; $0D = Happy Slime
			; $0E = Magic Mole
			; $0F = Monkey
			; $10 = Goomba (x2)
			; $11 = Komposite Koopa
			; $12 = Monty Mole
			; $13 = Terrain Platform
			; $14 = Projectile
			; $15 = Sprite Yoshi Coin
			; $16 = Mario fireball

		!BigRAM			= $6080

		!P1CoinIncrease		= $6F34			;\ Write here to increment player coins
		!P2CoinIncrease		= $6F35			;/
		!P1Coins		= $6F36			; > 2 bytes, goes to 9999
		!P2Coins		= $6F38			; > 2 bytes, goes to 9999
		!CoinSound		= $6F3A			; Timer until next coin sound is a-go
		!CoinOwner		= $6F3B			; Indicates who will get the next coin spawned
								; 0 = Mario, 1 = P1 PCE, 2 = P2 PCE

		; Coin hoard is with SRAM stuff

		!StatusBar		= $6EF9			; 32 bytes, tile numbers for status bar



		!P1Base			= $3600
		!P2Base			= $3680
		!P2Status		= !P2Base+$00
		!P2HP			= !P2Base+$01
		!P2XPosLo		= !P2Base+$02
		!P2XPosHi		= !P2Base+$03
		!P2XSpeed		= !P2Base+$04
		!P2XFraction		= !P2Base+$05
		!P2YPosLo		= !P2Base+$06
		!P2YPosHi		= !P2Base+$07
		!P2YSpeed		= !P2Base+$08
		!P2YFraction		= !P2Base+$09
		!P2Platform		= !P2Base+$0A
		!P2Floatiness		= !P2Base+$0B
		!P2Flags		= !P2Base+$0C
		!P2Direction		= !P2Base+$0D
		!P2Blocked		= !P2Base+$0E
		!P2Offscreen		= !P2Base+$0F
		!P2KillCount		= !P2Base+$10
		!P2HurtTimer		= !P2Base+$11
		!P2Buffer		= !P2Base+$12
		!P2Map16Index		= !P2Base+$13
		!P2Map16Table		= !P2Base+$14

		!P2Slope		= !P2Base+$1C
		!P2Water		= !P2Base+$1D		; dwl----c
								; d = ducking
								; w = water
								; l = lava
								; c = climbing

		!P2Invinc		= !P2Base+$1E
		!P2PoseTimer		= !P2Base+$1F

		!P2ClimbFirst		= !P2Base+$1F		; Flag set during first frame of Leeway's climb

		!P2Senku		= !P2Base+$20
		!P2Punch1		= !P2Base+$21
		!P2Punch2		= !P2Base+$22
		!P2Kick			= !P2Base+$23

		!P2DashJump		= !P2Base+$20
		!P2SwordAttack		= !P2Base+$21
		!P2SwordTimer		= !P2Base+$22
		!P2Climb		= !P2Base+$23

		!P2IndexMem1		= !P2Base+$24
		!P2IndexMem2		= !P2Base+$25

		!P2DashTimerR1		= !P2Base+$26		; Also Leeway's main dash leniency timer
		!P2DashTimerR2		= !P2Base+$27		; Also Leeway's crouch timer
		!P2DashTimerL1		= !P2Base+$28		; Also ORA'd to Leeway's $6DA3 if L2 is set
		!P2DashTimerL2		= !P2Base+$29		; Also Leeway's Timer for L1


		!P2Element		= !P2Base+$20
		!P2Telekinesis		= !P2Base+$21
		!P2Launch		= !P2Base+$22		; highest bit for direction, lo 5 bits for sprite index
		!P2StasisSpell		= !P2Base+$23
		!P2DestroyXLo		= !P2Base+$24
		!P2DestroyXHi		= !P2Base+$25
		!P2DestroyYLo		= !P2Base+$26
		!P2DestroyYHi		= !P2Base+$27
		!P2DestroyTimer		= !P2Base+$28
		!P2FamiliarXLo		= !P2Base+$29
		!P2FamiliarXHi		= !P2Base+$2A
	; 2B-2D for animation
		!P2FamiliarYLo		= !P2Base+$2E
		!P2FamiliarYHi		= !P2Base+$2F
		!P2DoubleJump		= !P2Base+$60
		!P2LaunchTimer		= !P2Base+$61
		!P2Mana			= !P2Base+$62
		!P2ManaTimer		= !P2Base+$63
		!P2ManaLock		= !P2Base+$64



		!P2Dashing		= !P2Base+$2A		; Also Leeway's main dash timer
		!P2Anim			= !P2Base+$2B
		!P2AnimTimer		= !P2Base+$2C
		!P2TilesUsed		= !P2Base+$2D		; Also borrowed for lo prio function
		!P2SenkuDir		= !P2Base+$2E

		!P2ButtonDis		= !P2Base+$2E		; TRB'd to Leeway's $6DA3 if L2 is set

		!P2SenkuUsed		= !P2Base+$2F

		!P2Pipe			= !P2Base+$30		; ddettttt
								; dd = direction:
								;	00: left
								;	01: right
								;	02: up
								;	03: down
								; e = enter (1) / exit (0)
								; t = timer (0x00-0x1F)

		!P2Anim2		= !P2Base+$31		; Used during 30fps mode
		!P2ClippingX		= !P2Base+$32		;\
		!P2ClippingY		= !P2Base+$34		; | 16-bit pointers to actual tables
		!P2ClippingSize		= !P2Base+$36		;/

		!P2SlantPipe		= !P2Base+$38

		!P2PrevPlatform		= !P2Base+$39


		!P2VectorX		= !P2Base+$3A		;\
		!P2VectorY		= !P2Base+$3B		; |
		!P2VectorAccX		= !P2Base+$3C		; |
		!P2VectorAccY		= !P2Base+$3D		; | Can be used to create impulses (push/pull)
		!P2VectorMemX		= !P2Base+$3E		; |
		!P2VectorMemY		= !P2Base+$3F		; |
		!P2VectorTimeX		= !P2Base+$40		; |
		!P2VectorTimeY		= !P2Base+$41		;/

		!P2Stasis		= !P2Base+$42		; > Amount of time to lock player coords
		!P2GravityFactor	= !P2Base+$43		;\ Can be used to increase or decrease gravity
		!P2GravityTimer		= !P2Base+$44		;/

		!P2XPosBackup		= !P2Base+$45		;\ 16-bit backups to use for collision
		!P2YPosBackup		= !P2Base+$47		;/

		!P2SpritePlatform	= !P2Base+$49		; Used by sprites to act as solid platforms

		!P2JumpLag		= !P2Base+$4A		; > How long Kadaal is stunned upon landing

		!P2ExtraInput1		= !P2Base+$4B		; > Overwrites $6DA2 ($15)
		!P2ExtraInput2		= !P2Base+$4C		; > Overwrites $6DA6 ($16)
		!P2ExtraInput3		= !P2Base+$4D		; > Overwrites $6DA4 ($17)
		!P2ExtraInput4		= !P2Base+$4E		; > Overwrites $6DA8 ($18)

		!P2Character		= !P2Base+$4F		; > Mirror of current character

		!P2Hurtbox		= !P2Base+$50		; 6 bytes:
		!P2Hitbox		= !P2Base+$56		; Xlo, Xhi
								; Ylo, Yhi
								; width, height

		!P2MaxHP		= !P2Base+$5C		; Current max HP for player

		!P2ClimbTop		= !P2Base+$5D		; Used by Leeway

		!P2ExternalAnim		= !P2Base+$5E		;\ Overrides normal function
		!P2ExternalAnimTimer	= !P2Base+$5F		;/

		!P2AllRangeSenku	= !P2Base+$60
		!P2ShellSlide		= !P2Base+$61
		!P2SenkuSmash		= !P2Base+$62		; Set if player is touching a smashable enemy this frame
		!P2ShellSpeed		= !P2Base+$63		; Allow maximum air speed when set
		!P2ShellDrill		= !P2Base+$64
		!P2BackDash		= !P2Base+$65


		!P2DashSlash		= !P2Base+$60		; limits Leeway's dash slashes to 1 per dash



		!P1Dead			= $7FFF


		!SRAM_buffer		= $404000
		!Difficulty		= !SRAM_buffer+$01
		!YoshiCoinCount		= !SRAM_buffer+$05
		!P1DeathCounter		= !SRAM_buffer+$07
		!P2DeathCounter		= !SRAM_buffer+$09
		!YoshiCoinTable		= !SRAM_buffer+$0B
		!Bestiary		= !SRAM_buffer+$6B
		!Characters		= !SRAM_buffer+$8B
		!MarioUpgrades		= !SRAM_buffer+$8C
		!LuigiUpgrades		= !SRAM_buffer+$8D
		!KadaalUpgrades		= !SRAM_buffer+$8E
		!LeewayUpgrades		= !SRAM_buffer+$8F
		!AlterUpgrades		= !SRAM_buffer+$91
		!PeachUpgrades		= !SRAM_buffer+$92
		!CoinHoard		= !SRAM_buffer+$93	; 3 bytes, goes up to 999999
		!StoryFlags		= !SRAM_buffer+$96
		; 00:	realm unlock state (if this is zero, load intro instead of realm select)
		; 01:	reserved for Realm 1
		; 02:	first 2 bits used by Mountain King



		!MsgRAM			= $4400			; 256 bytes, base address
		!MsgVRAM1		= !MsgRAM+$23		; 2 bytes
		!MsgVRAM2		= !MsgRAM+$25		; 2 bytes
		!MsgVRAM3		= !MsgRAM+$27		; 2 bytes, border

		!MsgPal			= $61

		!VRAMbank		= $40
		!VRAMbase		= !VRAMbank*$10000	; This is so gross. asar syntax sucks sometimes.
		!VRAMtable		= $4500
		!VRAMslot		= !VRAMtable+$FE
		!CGRAMtable		= $4600

		!HDMAptr		= $4046FC


		!OAM			= $6200			;\ Main mirror
		!OAMhi			= $6420			;/

		!OAMindex		= $7473			; lo byte
		!OAMindexhi		= $7475			; hi bit

		!MarioPalData		= $316A			; colors 0x86-0x8F
		!MarioPalOverride	= $317E			; when set, SMW is not allowed to update !MarioPalData

		!PlayerBackupData	= $404E00		; > 128 bytes

		!MultiPlayer		= $404E80
		!CurrentPlayer		= $404E81		; Used on OW for character select and during levels

		!RAMcode_Offset		= $404E82		; > Used when both players use PCE

		!CurrentMario		= $404E84		; > 0 = no Mario, 1 = P1 Mario, 2 = P2 Mario

		!VineDestroy		= $404E85
		!VineDestroyPage	= !VineDestroy+$00	; > Map16 page of vines
		!VineDestroyXLo		= !VineDestroy+$01
		!VineDestroyXHi		= !VineDestroy+$05
		!VineDestroyYLo		= !VineDestroy+$09
		!VineDestroyYHi		= !VineDestroy+$0D
		!VineDestroyDirection	= !VineDestroy+$11
		!VineDestroyTimer	= !VineDestroy+$15	; > Also borrowed by lightning bolt

		!NPC_ID			= $404E9E		; Used for NPC loading
		!NPC_Talk		= $404EA1		; Pointer to NPC talk table

		!MsgMode		= $404EA4		; 0 = normal message box
								; 1 = play animation during message box
								; 2 = message box has no pause-effect

		!SmokeXHi		= $404EA5		;\ Determines if smoke sprite is within screen bounds
		!SmokeYHi		= $404EA9		;/
		!SmokeHack		= $404EAD		; > Smoke sprite init flag (very hacky fam)

		!ProcessingSprites	= $404EB1		; Set while sprites are being processed

		!VineDestroyBaseTime	= $404EB2		; Default timer option for vines (set by level code)

		!MegaLevelID		= $404EB3		; 0 = no mega level

		!TextPal		= $404EB4		; CCC bits of text prop, set to 0x18 by default

		!PauseThif		= $404EB5		; when set, thifs will not process


		!VineDestroyHorzTile1	= $92
		!VineDestroyHorzTile2	= $93
		!VineDestroyHorzTile3	= $C2
		!VineDestroyHorzTile4	= $C3
		!VineDestroyHorzTile5	= $96
		!VineDestroyHorzTile6	= $97
		!VineDestroyHorzTile7	= $9A
		!VineDestroyHorzTile8	= $9B
		!VineDestroyHorzTile9	= $CA
		!VineDestroyHorzTile10	= $CB
		!VineDestroyHorzTile11	= $9E
		!VineDestroyHorzTile12	= $9F
		!VineDestroyVertTile1	= $A1
		!VineDestroyVertTile2	= $B1
		!VineDestroyVertTile3	= $A4
		!VineDestroyVertTile4	= $B4
		!VineDestroyVertTile5	= $E1
		!VineDestroyVertTile6	= $F1
		!VineDestroyVertTile7	= $A9
		!VineDestroyVertTile8	= $B9
		!VineDestroyVertTile9	= $AC
		!VineDestroyVertTile10	= $BC
		!VineDestroyVertTile11	= $E9
		!VineDestroyVertTile12	= $F9
		!VineDestroyCornerUL1	= $C4
		!VineDestroyCornerUR1	= $C1
		!VineDestroyCornerDL1	= $94
		!VineDestroyCornerDR1	= $91
		!VineDestroyCornerUL2	= $CC
		!VineDestroyCornerUR2	= $C9
		!VineDestroyCornerDL2	= $9C
		!VineDestroyCornerDR2	= $99


		!MidwayLo		= $418AFF	; what level each translevel is currently loading its midway from
		!MidwayHi		= $418B5F


	; -- 3D Joint Cluster --

		!3D_Base		= $41B800

		!3D_AngleXY		= !3D_Base+$0	;\
		!3D_AngleXZ		= !3D_Base+$1	; |
		!3D_AngleYZ		= !3D_Base+$2	; | used for core
		!3D_AngleYX		= !3D_AngleXY	; |
		!3D_AngleZX		= !3D_AngleXZ	; |
		!3D_AngleZY		= !3D_AngleYZ	;/

		!3D_AngleH		= !3D_Base+$0	;\ used for non-core objects
		!3D_AngleV		= !3D_Base+$1	;/

	; for all angles, 256 represents a full 360 degree rotation

		!3D_Distance		= !3D_Base+$3	; 16 bit, each unit represents 1/256th px
		!3D_DistanceSub		= !3D_Base+$3	;
		!3D_DistancePx		= !3D_Base+$4	;
		!3D_X			= !3D_Base+$5	; 16-bit X position
		!3D_Y			= !3D_Base+$7	; 16-bit Y position
		!3D_Z			= !3D_Base+$9	; 8-bit Z position (0x80 is default)
		!3D_Attachment		= !3D_Base+$B	; which object this one is attached to
		!3D_Slot		= !3D_Base+$D	; 8-bit, 0 if this slot is free, otherwise used
		!3D_Extra		= !3D_Base+$E	; empty

		; if an object is set to be attached to itself, then that is the core of that cluster.
		; writing to angles and Z position of the core will affect the entire cluster.
		; distance has no effect on the core.


		!3D_AssemblyCache	= !3D_Base+$400

		!3D_TilemapCache	= $6DDF		; 278 bytes

		!3D_BankCache		= !3D_Base+$7ED
		!3D_TilemapPointer	= !3D_Base+$7EE

		!3D_Cache		= !3D_Base+$7F0
		!3D_Cache1		= !3D_Cache+$0
		!3D_Cache2		= !3D_Cache+$2
		!3D_Cache3		= !3D_Cache+$4
		!3D_Cache4		= !3D_Cache+$6
		!3D_Cache5		= !3D_Cache+$8
		!3D_Cache6		= !3D_Cache+$A
		!3D_Cache7		= !3D_Cache+$C
		!3D_Cache8		= !3D_Cache+$E



	; -- Sprite stuff --

		!SpriteAnimTimer	= $3310,x
		!SpriteAnimIndex	= $33D0,x
		!SpriteAnimIndexY	= $33D0,y
		!ClaimedGFX		= $32C0,x
		!ClaimSize		= $34A0,x	; Used by Kingking!
		!AggroRexTile		= $35E0,x


	; -- 5bpp --

		!GraphicsLoc	= $3000				; 24-bit pointer to graphics file
		!GraphicsSize	= $3003				; 8-bit number of 8x8 tiles

		!BufferLo	= $404A00			; 24-bit pointer to decompression buffer.
		!BufferHi	= !BufferLo+(!BufferSize/2)	; Hi buffer.
		!BufferSize	= $0400				; Size of buffer. Must be divisible by 4.

		!GFX0		= $10				; Points to GFX+$00
		!GFX1		= $13				; Points to GFX+$01
		!GFX2		= $16				; Points to GFX+$10
		!GFX3		= $19				; Points to GFX+$11
		!GFX4		= $1C				; Points to GFX+$20



	; -- SMW/LM RAM --			; This is mainly for easier SA-1 compatibility.

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
		!MarioAnim		= $71
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
		!IceLevel		= $86
		!MarioXPosLo		= $94
		!MarioXPosHi		= $95
		!MarioYPosLo		= $96
		!MarioYPosHi		= $97
		!GameMode		= $6100
		!LevelMode		= $6D9B
		!HDMA			= $6D9F
		!MarioJoypad1Raw	= $6DA2
		!MarioJoypad2Raw	= $6DA4
		!MarioJoypad1RawOneF	= $6DA6
		!ItemBox		= $6DC2
		!Translevel		= $73BF
		!PauseTimer		= $73D3
		!Pause			= $73D4
		!MarioImg		= $73E0
		!MarioWallWalk		= $73E3
		!CapeEnable		= $73E8
		!CapeXPosLo		= $73E9
		!CapeXPosHi		= $73EA
		!CapeYPosLo		= $73EB
		!CapeYPosHi		= $73EC
		!EnableHScroll		= $7411
		!EnableVScroll		= $7412
		!MarioBehind		= $73F9
		!ScrollLayer1		= $7404
		!MarioSpinJump		= $740D
		!BG2ModeH		= $7413
		!BG2ModeV		= $7414
		!BG2BaseV		= $7417		; 16-bit
		!MsgTrigger		= $7426
		!BG3BaseSettings	= $745E		; first 5 bits determine y position, last 2 bits used by LM
		!BG3BaseSpeed		= $745F		; hi nybble is vertical option, lo nybble is horizontal option
		!MarioCarryingObject	= $7470
		!LevelEnd		= $7493
		!MarioFlashTimer	= $7497
		!MarioCapeFloat		= $74A5
		!MarioCapeSpin		= $74A6
		!SpriteIndex		= $75E9
		!MarioKillCount		= $7697
		!CoinTimer		= $786B
		!MarioRidingYoshi	= $787A
		!ShakeTimer		= $7887
		!YoshiIndex		= $78E2
		!SideExit		= $7B96
		!SPC1			= $7DF9
		!SPC2			= $7DFA
		!SPC3			= $7DFB
		!SPC4			= $7DFC
		!LevelTable		= $7EA2


		!ExSpriteNum		= $770B
		!ExSpriteYPosLo		= $7715
		!ExSpriteXPosLo		= $771F
		!ExSpriteYPosHi		= $7729
		!ExSpriteXPosHi		= $7733
		!ExSpriteYSpeed		= $773D
		!ExSpriteXSpeed		= $7747
		!ExSpriteYFraction	= $7751
		!ExSpriteXFraction	= $775B
		!ExSpriteMisc		= $7765
		!ExSpriteTimer		= $776F
		!ExSpriteBehindBG1	= $7779


	; -- Custom routines --

		!InitSpriteTables	= $07F7D2

		!GetMap16Sprite		= $138008
		!KillOAM		= $138010
		!GetMap16		= $138018
		!GetVRAM		= $138028
		!GetCGRAM		= $138030
		!PlaneSplit		= $138038
		!HurtPlayers		= $138040
		!UpdateGFX		= $138048
		!UpdatePal		= $13804C
		!Contact16		= $138050
		!PortraitPointers	= $138058		; DATA! Not a routine!
		!PlayerPalettes		= $048431		; DATA POINTER! Pointer is stored with SP_Level.asm

		!PlayerClipping		= read3($00E3D6)	; Pointer is stored with PCE.asm

		!GenerateBlock		= read3($04842E)	; Pointer is stored with SP_Patch.asm


	; -- SMW routines --

		!BouncePlayer		= $01AA33
		!ContactGFX		= $01AB99

		!SpriteApplySpeed	= $01802A

		!GetSpriteSlot		= $02A9DE

		!GetSpriteClipping04	= $03B69F
		!GetSpriteClipping00	= $03B6E5

		!GetP1Clipping		= $03B664		; < Gets MARIO's clipping
		!CheckContact		= $03B72B



	; -- Data and pointers --

		!Map16ActsLike		= $06F624

		!TrigTable		= $07F7DB


	; -- Values --			; These allow easier customization.

		!Climb1			= $36
		!Climb2			= $36
		!Climb3			= $37
		!Climb4			= $37
		!ClimbUpSpeed		= $F0
		!ClimbDownSpeed		= $10
		!ClimbLeftSpeed		= $F0
		!ClimbRightSpeed	= $10

	; -- Graphics --

		!P2Tile1		= $20		;\
		!P2Tile2		= $22		; | Located in SP1
		!P2Tile3		= $24		; |
		!P2Tile4		= $26		;/
		!P2Tile5		= $28
		!P2Tile6		= $2A
		!P2Tile7		= $2C
		!P2Tile8		= $2E

		!SP1			= $6000
		!SP2			= $6800
		!SP3			= $7000
		!SP4			= $7800


	; -- Booleans --		; Don't mess with these.

		!True 			= 1
		!False			= 0


;======;
;MACROS;
;======;

macro TM16(x, y, tile, prop)
	dw $0004
	db <prop>,<x>,<y>,<tile>
endmacro

macro TM24x32(x, y, tile, prop)
	dw $0010
	db <prop>,<x>+$00,<y>+$F0,<tile>+$00
	db <prop>,<x>+$08,<y>+$F0,<tile>+$01
	db <prop>,<x>+$00,<y>+$00,<tile>+$20
	db <prop>,<x>+$08,<y>+$00,<tile>+$21
endmacro

macro TM32(x, y, tile, prop)
	dw $0010
	db <prop>,<x>+$00,<y>+$F0,<tile>+$00
	db <prop>,<x>+$10,<y>+$F0,<tile>+$02
	db <prop>,<x>+$00,<y>+$00,<tile>+$20
	db <prop>,<x>+$10,<y>+$00,<tile>+$22
endmacro

macro LTM32x32(prop, x, y, tile)
	dw $0010
	db <prop>&$F0|<tile>>>8,<x>+$00,<y>+$00,<tile>+$00
	db <prop>&$F0|<tile>>>8,<x>+$10,<y>+$00,<tile>+$02
	db <prop>&$F0|<tile>>>8,<x>+$00,<y>+$10,<tile>+$20
	db <prop>&$F0|<tile>>>8,<x>+$10,<y>+$10,<tile>+$22
endmacro

macro LTM40x32(prop, x, y, tile)
	dw $0018
	db <prop>&$F0|<tile>>>8,<x>+$00,<y>+$00,<tile>+$00
	db <prop>&$F0|<tile>>>8,<x>+$10,<y>+$00,<tile>+$02
	db <prop>&$F0|<tile>>>8,<x>+$00,<y>+$10,<tile>+$20
	db <prop>&$F0|<tile>>>8,<x>+$10,<y>+$10,<tile>+$22
	db <prop>&$F0|<tile>>>8,<x>+$18,<y>+$00,<tile>+$03
	db <prop>&$F0|<tile>>>8,<x>+$18,<y>+$10,<tile>+$23
endmacro

macro Crown(prop, x, y, t)
	dw $0004
	db <prop>|$01,<x>,<y>,<t>&$03*$02+$05
endmacro

macro LTM32x64(prop, x1, y1, tile1, x2, y2, tile2)
	dw $0020
	db <prop>&$F0|<tile1>>>8,<x1>+$00,<y1>+$00,<tile1>+$00
	db <prop>&$F0|<tile1>>>8,<x1>+$10,<y1>+$00,<tile1>+$02
	db <prop>&$F0|<tile1>>>8,<x1>+$00,<y1>+$10,<tile1>+$20
	db <prop>&$F0|<tile1>>>8,<x1>+$10,<y1>+$10,<tile1>+$22
	db <prop>&$F0|<tile2>>>8,<x2>+$00,<y2>+$00,<tile2>+$00
	db <prop>&$F0|<tile2>>>8,<x2>+$10,<y2>+$00,<tile2>+$02
	db <prop>&$F0|<tile2>>>8,<x2>+$00,<y2>+$10,<tile2>+$20
	db <prop>&$F0|<tile2>>>8,<x2>+$10,<y2>+$10,<tile2>+$22
endmacro

macro LTM40x64(prop, x1, y1, tile1, x2, y2, tile2)
	dw $0028
	db <prop>&$F0|<tile1>>>8,<x1>+$00,<y1>+$00,<tile1>+$00
	db <prop>&$F0|<tile1>>>8,<x1>+$10,<y1>+$00,<tile1>+$02
	db <prop>&$F0|<tile1>>>8,<x1>+$00,<y1>+$10,<tile1>+$20
	db <prop>&$F0|<tile1>>>8,<x1>+$10,<y1>+$10,<tile1>+$22
	db <prop>&$F0|<tile2>>>8,<x2>+$00,<y2>+$00,<tile2>+$00
	db <prop>&$F0|<tile2>>>8,<x2>+$10,<y2>+$00,<tile2>+$02
	db <prop>&$F0|<tile2>>>8,<x2>+$18,<y2>+$00,<tile2>+$03
	db <prop>&$F0|<tile2>>>8,<x2>+$00,<y2>+$10,<tile2>+$20
	db <prop>&$F0|<tile2>>>8,<x2>+$10,<y2>+$10,<tile2>+$22
	db <prop>&$F0|<tile2>>>8,<x2>+$18,<y2>+$10,<tile2>+$23
endmacro