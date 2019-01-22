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

		!Player1HP		= $6F42
		!WallCling		= $6F43
		!DashTimer		= $6F44
		!SlashTimer		= $6F45
		!InstantDash		= $6F46
		!SwordHover		= $6F47
		!PropellerSlash		= $747B

		!P1Base			= $3600


		!RAMcode_flag		= $6020			; 0x1234 = Execute, anything else ignore

		!GFX_status		= $6022
					; Value at corresponding offset is added to sprite's tile numbers.

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
		!KadaalUpgrades		= !SRAM_buffer+$8D
		!LeewayUpgrades		= !SRAM_buffer+$8E
		!AlterUpgrades		= !SRAM_buffer+$8F
		!LuigiUpgrades		= !SRAM_buffer+$90
		!StoryFlags		= !SRAM_buffer+$94

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

	;	!OAMindex		= $7473			; lo byte
	;	!OAMindexhi		= $7475			; hi bit


		!OAM_HiPrio		= $404E00		;\ Goes before main mirror
		!OAM_HiPrioHi		= $4052A0		;/
		!OAM_LoPrio		= $4050A0		;\ Goes after main mirror
		!OAM_LoPrioHi		= $405320		;/
		!OAM_HiPrioIndex	= $4053A0		; > Index to hi prio table (16-bit)
		!OAM_LoPrioIndex	= $4053A2		; > Index to lo prio table (16-bit)
		!OAM_PrioCache		= $4053A4		; > 4 bytes, cache



	; -- Sprite stuff --

		!SpriteAnimTimer	= $3310,x
		!SpriteAnimIndex	= $33D0,x
		!ClaimedGFX		= $32C0,x
		!ClaimSize		= $34A0,x	; Used by Kingking!
		!AggroRexTile		= $35E0,x



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
		!WriteHiTilemap		= $138038
		!WriteLoTilemap		= $13803E
		!SpritePrioTilemap	= $138044


	; -- SMW routines --

		!BouncePlayer		= $01AA33
		!ContactGFX		= $01AB99

		!SpriteApplySpeed	= $01802A

		!GetP1Clipping		= $03B664
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