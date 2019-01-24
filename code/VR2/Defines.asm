;=======;
;DEFINES;
;=======;


	; -- Free RAM --		; Point to unused addresses, please.
					; Don't change addressing mode (16-bit to 24-bit and vice versa).
					; Doing that requires changing some code.

		!AnimToggle		= $60			; 0 = enabled; 1 = disabled

		!Level			= $010B
		!BossData		= $06F9			; 7 bytes
		!RNG			= $0700			; Updated every frame during level (game mode = 0x14)

		!Player1HP		= $0F42
		!WallCling		= $0F43
		!DashTimer		= $0F44
		!SlashTimer		= $0F45
		!InstantDash		= $0F46
		!SwordHover		= $0F47
		!PropellerSlash		= $147B

		!P2Base =		$0F4A
		!P2Status = 		!P2Base+$00
		!P2HP =			!P2Base+$01
		!P2XPosLo =		!P2Base+$02
		!P2XPosHi =		!P2Base+$03
		!P2XSpeed =		!P2Base+$04
		!P2XFraction =		!P2Base+$05
		!P2YPosLo =		!P2Base+$06
		!P2YPosHi =		!P2Base+$07
		!P2YSpeed =		!P2Base+$08
		!P2YFraction =		!P2Base+$09
		!P2Platform =		!P2Base+$0A
		!P2Floatiness =		!P2Base+$0B
		!P2Flags =		!P2Base+$0C
		!P2Direction =		!P2Base+$0D
		!P2Blocked =		!P2Base+$0E
		!P2Offscreen =		!P2Base+$0F
		!P2KillCount =		!P2Base+$10
		!P2HurtTimer =		!P2Base+$11
		!P2Buffer =		!P2Base+$12
		!P2Map16Index =		!P2Base+$13
		!P2Map16Table =		!P2Base+$14

		!P2Slope =		!P2Base+$1C
		!P2Water =		!P2Base+$1D		; dwl----c
								; d = ducking
								; w = water
								; l = lava
								; c = climbing

		!P2Invinc =		!P2Base+$1E
		!P2PoseTimer =		!P2Base+$1F
		!P2Senku =		!P2Base+$20
		!P2Punch1 =		!P2Base+$21
		!P2Punch2 =		!P2Base+$22
		!P2Kick =		!P2Base+$23

		!P2IndexMem1 =		!P2Base+$24
		!P2IndexMem2 =		!P2Base+$25

		!P2DashTimerR1 =	!P2Base+$26
		!P2DashTimerR2 =	!P2Base+$27
		!P2DashTimerL1 =	!P2Base+$28
		!P2DashTimerL2 =	!P2Base+$29
		!P2Dashing =		!P2Base+$2A
		!P2Anim =		!P2Base+$2B
		!P2AnimTimer =		!P2Base+$2C
		!P2TilesUsed =		!P2Base+$2D		; Also borrowed for lo prio function
		!P2SenkuDir =		!P2Base+$2E
		!P2SenkuUsed =		!P2Base+$2F

		!P2Pipe =		!P2Base+$30		; ddettttt
								; dd = direction:
								;	00: left
								;	01: right
								;	02: up
								;	03: down
								; e = enter (1) / exit (0)
								; t = timer (0x00-0x1F)

		!P1Dead			= $1FFF

		!Difficulty		= $7FA301
		!Characters		= $7FA38B

		!MsgRAM			= $A500			; 256 bytes, base address
		!MsgVRAM1		= !MsgRAM+$23		; 2 bytes
		!MsgVRAM2		= !MsgRAM+$25		; 2 bytes
		!MsgVRAM3		= !MsgRAM+$27		; 2 bytes, border

		!MsgPal			= $61

		!VRAMbank		= $7F
		!VRAMbase		= !VRAMbank*$10000	; This is so gross. asar syntax sucks sometimes.
		!VRAMtable		= $A600
		!VRAMslot		= !VRAMtable+$FE
		!CGRAMtable		= $A700

		!HDMAptr		= $7FA7FC

		!MidwayTable		= $7FAA00		; 192 (0xC0) bytes

		!OAMindex		= $1473			; lo byte
		!OAMindexhi		= $1475			; hi bit

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
		!GameMode		= $0100
		!OAM			= $0200
		!OAMhi			= $0420
		!LevelMode		= $0D9B
		!HDMA			= $0D9F
		!MarioJoypad1Raw	= $0DA2
		!MarioJoypad2Raw	= $0DA4
		!MarioJoypad1RawOneF	= $0DA6
		!ItemBox		= $0DC2
		!Translevel		= $13BF
		!PauseTimer		= $13D3
		!Pause			= $13D4
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
		!MsgTrigger		= $1426
		!MarioCarryingObject	= $1470
		!LevelEnd		= $1493
		!MarioFlashTimer	= $1497
		!MarioCapeFloat		= $14A5
		!MarioCapeSpin		= $14A6
		!SpriteIndex		= $15E9
		!CoinTimer		= $186B
		!MarioRidingYoshi	= $187A
		!ShakeTimer		= $1887
		!YoshiIndex		= $18E2
		!SideExit		= $1B96
		!SPC1			= $1DF9
		!SPC2			= $1DFA
		!SPC3			= $1DFB
		!SPC4			= $1DFC
		!LevelTable		= $1EA2

	; -- Custom routines --

		!GetVRAM		= $938028

	; -- SMW routines --

		!BouncePlayer		= $81AA33
		!ContactGFX		= $81AB99

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

		!P2Tile1		= $80		;\
		!P2Tile2		= $C2		; | Located in SP2
		!P2Tile3		= $84		; |
		!P2Tile4		= $86		;/


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