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
			; $05 = Hammer (Extended sprite)

		!P1CoinIncrease		= $6F34			;\ Write here to increment player coins
		!P2CoinIncrease		= $6F35			;/
		!P1Coins		= $6F36			; > 2 bytes, goes to 9999
		!P2Coins		= $6F38			; > 2 bytes, goes to 9999
		!CoinSound		= $6F3A			; Timer until next coin sound is a-go
		!CoinOwner		= $6F3B			; Indicates who will get the next coin spawned

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
		!StoryFlags		= !SRAM_buffer+$95



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

		!MidwayTable		= $404900		; 192 (0xC0) bytes

		!OAM			= $6200			;\ Main mirror
		!OAMhi			= $6420			;/

		!OAMindex		= $7473			; lo byte
		!OAMindexhi		= $7475			; hi bit

		!PlayerBackupData	= $404E00		; > 128 bytes

		!MultiPlayer		= $404E80
		!CurrentPlayer		= $404E81		; > Used on OW for character select
								; Currently unused in levels

		!RAMcode_Offset		= $404E82		; > Used when both players use PCE

		!CurrentMario		= $404E84		; > 0 = no Mario, 1 = P1 Mario, 2 = P2 Mario


	; -- Sprite stuff --

		!SpriteAnimTimer	= $3310,x
		!SpriteAnimIndex	= $33D0,x
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
		!MarioBehind		= $73F9
		!ScrollLayer1		= $7404
		!MarioSpinJump		= $740D
		!MsgTrigger		= $7426
		!MarioCarryingObject	= $7470
		!LevelEnd		= $7493
		!MarioFlashTimer	= $7497
		!MarioCapeFloat		= $74A5
		!MarioCapeSpin		= $74A6
		!SpriteIndex		= $75E9
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

	; -- Custom routines --

		!InitSpriteTables	= $07F7D2

		!GetVRAM		= $138028
		!GetCGRAM		= $138030
		!PlaneSplit		= $138038
		!PortraitPointers	= $138040		; DATA! Not a routine!
		!PlayerClipping		= read3($00E3D6)	; Pointer is stored with PCE.asm

		!GenerateBlock		= read3($048259)	; Pointer is stored with SP_Patch.asm


	; -- SMW routines --

		!BouncePlayer		= $01AA33
		!ContactGFX		= $01AB99

		!SpriteApplySpeed	= $01802A

		!GetP1Clipping		= $03B664		; < Gets MARIO's clipping
		!CheckContact		= $03B72B



	; -- Data and pointers --

		!Map16ActsLike		= $06F624


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