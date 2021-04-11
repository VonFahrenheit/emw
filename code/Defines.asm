;=======;
;DEFINES;
;=======;


; turns out this function is pretty useless because LDA/STA addr,x and LDA/STA long,x both use 5 cycles...
macro mapBWRAM(address)
	if <address>&$01FFFF == 0
		STZ $2225
		STZ $318F
	else
		LDA.b #((<address>&$01FFFF)/$2000)&$1F
		STA $2225
		STA $318F
	endif
endmacro


; these macros can be used to quickly find an index to FusionCore
; _fast versions shred regs instead of pushing/pulling them
macro Ex_Index_X()
		PHY
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	?loop:	LDA !Ex_Num,x : BEQ ?thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ?loop			;/
		LDX #$00			; default index = 00
	?thisone:
		PLY
		STX !Ex_Index			; update index
		CPX #$00			; update P
endmacro

macro Ex_Index_X_fast()
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	?loop:	LDA !Ex_Num,x : BEQ ?thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ?loop			;/
		LDX #$00			; default index = 00
	?thisone:
		STX !Ex_Index			; update index
		CPX #$00			; update P
endmacro

macro Ex_Index_Y()
		PHX
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	?loop:	LDA !Ex_Num,y : BEQ ?thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ?loop			;/
		LDY #$00			; default index = 00
	?thisone:
		PLX
		STY !Ex_Index			; update index
		CPY #$00			; update P
endmacro

macro Ex_Index_Y_fast()
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	?loop:	LDA !Ex_Num,y : BEQ ?thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ?loop			;/
		LDY #$00			; default index = 00
	?thisone:
		STY !Ex_Index			; update index
		CPY #$00			; update P
endmacro


macro ReloadOAMData()
		PHP
		REP #$20
		STZ !OAMindex_index+0
		STZ !OAMindex_offset+0
		LDA #$0002 : STA !OAMindex_index+2
		LDA #$0004 : STA !OAMindex_index+4
		LDA #$0006 : STA !OAMindex_index+6
		LDA #$0200 : STA !OAMindex_offset+2
		LDA #$0400 : STA !OAMindex_offset+4
		LDA #$0600 : STA !OAMindex_offset+6
		PLP
endmacro



	; -- Free RAM --		; Point to unused addresses, please.
					; Don't change addressing mode (16-bit to 24-bit and vice versa).
					; Doing that requires changing some code.

		!AnimToggle		= $60			; see VR3.asm for info on how to use

		!CCDMA_SLOTS		= $317F
		!CCDMA_TABLE	 	= $3190
		!CC_BUFFER		= $3700



		!HDMA2source		= $1F00
		!HDMA3source		= $1F02
		!HDMA4source		= $1F04
		!HDMA5source		= $1F06
		!HDMA6source		= $1F08
		!HDMA7source		= $1F0A



		!BG1Address		= $3140		;\ tilemap addresses for layers 1/2
		!BG2Address		= $3142		;/ (based on 2107/2108, meant to be read for VRAM calc)
		!2107			= $3144		; $2107 mirror, BG1 tilemap address control
		!2108			= $3145		; $2108 mirror, BG2 tilemap address control
		!2109			= $3146		; $2109 mirror, BG3 tilemap address control
		!210C			= $3147		; $210C mirror, BG3 GFX address control



		!DynamicTile		= $3150
					; 16 bytes
					; each one represents one tile, starting at [???]
					; to claim one for a sprite, write the sprite's index to the proper index
					; the sprite's !ClaimedGFX register needs to match what is written here as well
					; if the comparison concludes invalid, the slot is considered free


	!CameraPower	= #$19		; remap to address later, this is how far ahead the camera is allowed to scroll

	!CameraXMem	= $7432		; 16-bit used for PCE camera baybee


		!CameraBackupX		= $3148
		!CameraBackupY		= $314A

		!CameraForceTimer	= $314C			; index 0/1 for both of these, 1 processed first
		!CameraForceDir		= $314E



		!CameraBoxL		= $3160
		!CameraBoxU		= $3162
		!CameraBoxR		= $3164
		!CameraBoxD		= $3166

		!CameraForbiddance	= $3168
					; reg2     reg1
					; yyyyyxxx xxssssss
					; s = which screen of camera box that forbiddance box starts at
					; x = number of screens for forbiddance box to span horizontally (0=1)
					; y = number of screens for forbiddance box to span vertically (0=1)

		!SmoothCamera		= $6AF6			; enables smooth camera (always on with camera box)


		!BG1ZipBoxL		= $45
		!BG1ZipBoxR		= $47
		!BG1ZipBoxU		= $49
		!BG1ZipBoxD		= $4B
		!BG2ZipBoxL		= $4D
		!BG2ZipBoxR		= $4F
		!BG2ZipBoxU		= $51
		!BG2ZipBoxD		= $53

		!UpdateBG1Row		= $6908
		!UpdateBG1Column	= $690A
		!UpdateBG2Row		= $690C
		!UpdateBG2Column	= $690E

		!BG1ZipColumnX		= $61F0
		!BG1ZipColumnY		= $61F2
		!BG1ZipRowX		= $61F4
		!BG1ZipRowY		= $61F6
		!BG2ZipColumnX		= $61F8
		!BG2ZipColumnY		= $61FA
		!BG2ZipRowX		= $61FC
		!BG2ZipRowY		= $61FE

		!BG1_Y_Delta		= $7858			; remapped from $77BC
		!BG1_X_Delta		= $7859			; remapped from $77BD
		!BG2_Y_Delta		= $785A			; remapped from $77BE
		!BG2_X_Delta		= $785B			; remapped from $77BF


		!Level			= $610B
		!BossData		= $66F9			; 7 bytes
		!RNG			= $6700			; Updated every frame during level (game mode = 0x14)

		!MarioGFX1		= $6F42			; VRAM address for first Mario GFX upload
		!MarioGFX2		= $6F44			; VRAM address for second Mario GFX upload
		!MarioTileOffset	= $6F46			; Added to Mario's tile numbers
		!MarioPropOffset	= $6F47			; Added to Mario's YXPPCCCT

		!RAMcode_flag		= $6020			; 0x1234 = Execute, anything else = ignore
		!RAMcode_offset		= $6022			; used for RAM code generation
		!RAMcode		= $404A00

		!GlobalPalset1		= $6024			; which sprite palset variation to use
		!GlobalPalset2		= $6025			; if mixing is used, this is which sprite palset variation to use for mixing
		!GlobalPalsetMix	= $6026			; balance between palset 1 and palset 2
								; 0 = 100% palset 1
								; 16 = 50% palset 1, 50% palset 2
								; 32 = 0% palset 1, 100% palset 2



	; these hold unpacked information for extra file tilemaps
		!Extra_Tiles		= $74C8
		!Extra_Prop		= !Extra_Tiles+$26

		!Tile_Wings		= !Extra_Tiles+$00
		!Tile_Shell		= !Extra_Tiles+$01
		!Tile_LakituCloud	= !Extra_Tiles+$02
		!Tile_Hammer		= !Extra_Tiles+$03
		!Tile_SmallFireball	= !Extra_Tiles+$04
		!Tile_ReznorFireball	= !Extra_Tiles+$05
		!Tile_LotusPollen	= !Extra_Tiles+$06
		!Tile_Baseball		= !Extra_Tiles+$07
		!Tile_WaterEffects	= !Extra_Tiles+$08
		!Tile_LavaEffects	= !Extra_Tiles+$09
		!Tile_SkeletonRubble	= !Extra_Tiles+$0A
		!Tile_Bone		= !Extra_Tiles+$0B
		!Tile_PlantStalk	= !Extra_Tiles+$0C
		!Tile_BombStar		= !Extra_Tiles+$0D
		!Tile_Parachute		= !Extra_Tiles+$0E
		!Tile_Mechanism		= !Extra_Tiles+$0F
		!Tile_DinoFire		= !Extra_Tiles+$10
		!Tile_AngelWings	= !Extra_Tiles+$11
		!Tile_RexLegs1		= !Extra_Tiles+$12
		!Tile_RexLegs2		= !Extra_Tiles+$13
		!Tile_RexSmall		= !Extra_Tiles+$14

		!Prop_Wings		= !Extra_Prop+$00
		!Prop_Shell		= !Extra_Prop+$01
		!Prop_LakituCloud	= !Extra_Prop+$02
		!Prop_Hammer		= !Extra_Prop+$03
		!Prop_SmallFireball	= !Extra_Prop+$04
		!Prop_ReznorFireball	= !Extra_Prop+$05
		!Prop_LotusPollen	= !Extra_Prop+$06
		!Prop_Baseball		= !Extra_Prop+$07
		!Prop_WaterEffects	= !Extra_Prop+$08
		!Prop_LavaEffects	= !Extra_Prop+$09
		!Prop_SkeletonRubble	= !Extra_Prop+$0A
		!Prop_Bone		= !Extra_Prop+$0B
		!Prop_PlantStalk	= !Extra_Prop+$0C
		!Prop_BombStar		= !Extra_Prop+$0D
		!Prop_Parachute		= !Extra_Prop+$0E
		!Prop_Mechanism		= !Extra_Prop+$0F
		!Prop_DinoFire		= !Extra_Prop+$10
		!Prop_AngelWings	= !Extra_Prop+$11
		!Prop_RexLegs1		= !Extra_Prop+$12
		!Prop_RexLegs2		= !Extra_Prop+$13
		!Prop_RexSmall		= !Extra_Prop+$14


		!GFX_status		= $418100

		!GFX_Koopa		= !GFX_status+$00
		!GFX_BobOmb		= !GFX_status+$01
		!GFX_Key		= !GFX_status+$02
		!GFX_Goomba		= !GFX_status+$03
		!GFX_PiranhaPlant	= !GFX_status+$04
		!GFX_BulletBill		= !GFX_status+$05
		!GFX_Starman		= !GFX_status+$06
		!GFX_SpringBoard	= !GFX_status+$07
		!GFX_PSwitch		= !GFX_status+$08
		!GFX_Blocks		= !GFX_status+$09
		!GFX_WallBouncer	= !GFX_status+$0A
		!GFX_Sign		= !GFX_status+$0B
		!GFX_BooBlock		= !GFX_status+$0C
		!GFX_Spiny		= !GFX_status+$0D
		!GFX_HoppingFlame	= !GFX_status+$0E
		!GFX_GrowingPipe	= !GFX_status+$0F
		!GFX_Lakitu		= !GFX_status+$10
		!GFX_PBalloon		= !GFX_status+$11
		!GFX_Wiggler		= !GFX_status+$12
		!GFX_Magikoopa		= !GFX_status+$13
		!GFX_NetKoopa		= !GFX_status+$14
		!GFX_Thwomp		= !GFX_status+$15
		!GFX_Thwimp		= !GFX_status+$16
		!GFX_Podoboo		= !GFX_status+$17
		!GFX_BallAndChain	= !GFX_status+$18
		!GFX_FishBone		= !GFX_status+$19
		!GFX_FallingSpike	= !GFX_status+$1A
		!GFX_BouncingPodoboo	= !GFX_status+$1B
		!GFX_MovingBlock	= !GFX_status+$1C
		!GFX_BuzzyBeetle	= !GFX_status+$1D
		!GFX_Football		= !GFX_status+$1E
		!GFX_SpikeTop		= !GFX_status+$1F
		!GFX_FloatingSkulls	= !GFX_status+$20
		!GFX_Blargg		= !GFX_status+$21
		!GFX_SwooperBat		= !GFX_status+$22
		!GFX_ChuckRock		= !GFX_status+$23
		!GFX_BrownGreyPlat	= !GFX_status+$24
		!GFX_CheckerPlat	= !GFX_status+$25
		!GFX_RockPlat		= !GFX_status+$26
		!GFX_OrangePlat		= !GFX_status+$27
		!GFX_RopeMechanism	= !GFX_status+$28
		!GFX_Chainsaw		= !GFX_status+$29
		!GFX_Fuzzy		= !GFX_status+$2A
		!GFX_ScalePlat		= !GFX_status+$2B
		!GFX_SpikeBall		= !GFX_status+$2C
		!GFX_Urchin		= !GFX_status+$2D
		!GFX_RipVanFish		= !GFX_status+$2E
		!GFX_Dolphin		= !GFX_status+$2F
		!GFX_TorpedoTed		= !GFX_status+$30
		!GFX_BlurpFish		= !GFX_status+$31
		!GFX_PorcuPuffer	= !GFX_status+$32
		!GFX_SumoLightning	= !GFX_status+$33
		!GFX_MontyMole		= !GFX_status+$34
		!GFX_Pokey		= !GFX_status+$35
		!GFX_SuperKoopa		= !GFX_status+$36
		!GFX_VolcanoLotus	= !GFX_status+$37
		!GFX_SumoBro		= !GFX_status+$38
		!GFX_Ninji		= !GFX_status+$39
		!GFX_Spotlight		= !GFX_status+$3A
		!GFX_SmallBird		= !GFX_status+$3B
		!GFX_BigBoo		= !GFX_status+$3C
		!GFX_Boo		= !GFX_status+$3D
		!GFX_ClimbingDoor	= !GFX_status+$3E
		!GFX_CastlePlat		= !GFX_status+$3F
		!GFX_Grinder		= !GFX_status+$40
		!GFX_HotHead		= !GFX_status+$41
		!GFX_WoodenSpike	= !GFX_status+$42
		!GFX_StatueFireball	= !GFX_status+$43
		!GFX_BowserStatue	= !GFX_status+$44
		!GFX_Fish		= !GFX_status+$45
		!GFX_LakituCloud	= !GFX_status+$46
		!GFX_Chuck		= !GFX_status+$47
		!GFX_AmazingHammerBro	= !GFX_status+$48
		!GFX_BanzaiBill		= !GFX_status+$49
		!GFX_Rex		= !GFX_status+$4A
		!GFX_CarrotPlat		= !GFX_status+$4B
		!GFX_TimerPlat		= !GFX_status+$4C
		!GFX_MegaMole		= !GFX_status+$4D
		!GFX_DinoRhino		= !GFX_status+$4E
		!GFX_DinoTorch		= !GFX_status+$4F
		!GFX_BossFireball	= !GFX_status+$50
		!GFX_BowlingBall	= !GFX_status+$51
		!GFX_MechaKoopa		= !GFX_status+$52
		!GFX_Reznor		= !GFX_status+$53
		!GFX_DryBones		= !GFX_status+$54
		!GFX_BonyBeetle		= !GFX_status+$55
		!GFX_Eerie		= !GFX_status+$56
		!GFX_CarrierBubble	= !GFX_status+$57
		!GFX_FishingBoo		= !GFX_status+$58
		!GFX_Sparky		= !GFX_status+$59

		!GFX_Wings		= !GFX_status+$5A
		!GFX_Shell		= !GFX_status+$5B
		!GFX_LakituCloud	= !GFX_status+$5C
		!GFX_Hammer		= !GFX_status+$5D
		!GFX_SmallFireball	= !GFX_status+$5E
		!GFX_ReznorFireball	= !GFX_status+$5F
		!GFX_LotusPollen	= !GFX_status+$60
		!GFX_Baseball		= !GFX_status+$61
		!GFX_WaterEffects	= !GFX_status+$62
		!GFX_LavaEffects	= !GFX_status+$63
		!GFX_SkeletonRubble	= !GFX_status+$64
		!GFX_Bone		= !GFX_status+$65
		!GFX_PlantStalk		= !GFX_status+$66
		!GFX_BombStar		= !GFX_status+$67
		!GFX_Parachute		= !GFX_status+$68
		!GFX_Mechanism		= !GFX_status+$69
		!GFX_DinoFire		= !GFX_status+$6A
		!GFX_AngelWings		= !GFX_status+$6B
		!GFX_RexLegs1		= !GFX_status+$6C
		!GFX_RexLegs2		= !GFX_status+$6D
		!GFX_RexSmall		= !GFX_status+$6E
		!GFX_LuigiFireball	= !GFX_status+$6F

		!GFX_GoombaSlave	= !GFX_status+$80
		!GFX_VillagerRex	= !GFX_status+$81
		!GFX_HammerRex		= !GFX_status+$82
		!GFX_NoviceShaman	= !GFX_status+$83
		!GFX_MagicMole		= !GFX_status+$84
		!GFX_Thif		= !GFX_status+$85
		!GFX_KompositeKoopa	= !GFX_status+$86
		!GFX_Birdo		= !GFX_status+$87
		!GFX_Bumper		= !GFX_status+$88
		!GFX_Monkey		= !GFX_status+$89
		!GFX_TerrainPlat	= !GFX_status+$8A
		!GFX_YoshiCoin		= !GFX_status+$8B
		!GFX_CoinGolem		= !GFX_status+$8C
		!GFX_BooHoo		= !GFX_status+$8D
		!GFX_FlamePillar	= !GFX_status+$8E
		!GFX_ParachuteGoomba	= !GFX_status+$8F
		!GFX_ParachuteBobomb	= !GFX_status+$90
		!GFX_MovingLedge	= !GFX_status+$91
		!GFX_SuperKoopa2	= !GFX_status+$92
		!GFX_GasBubble		= !GFX_status+$93
		!GFX_RexHat1		= !GFX_status+$94
		!GFX_RexHat2		= !GFX_status+$95
		!GFX_RexHat3		= !GFX_status+$96
		!GFX_RexHat4		= !GFX_status+$97
		!GFX_RexHat5		= !GFX_status+$98
		!GFX_RexHat6		= !GFX_status+$99
		!GFX_RexHelmet		= !GFX_status+$9A
		!GFX_RexBag1		= !GFX_status+$9B
		!GFX_RexBag2		= !GFX_status+$9C
		!GFX_RexBag3		= !GFX_status+$9D
		!GFX_RexBag4		= !GFX_status+$9E
		!GFX_RexSword		= !GFX_status+$9F
		!GFX_FlyingRex		= !GFX_status+$A0


		!GFX_Dynamic		= !GFX_status+$FF	; this one is not used by sprite files, it marks the start of the dynamic area

	; each file has a marker for where it is loaded (unloaded = 0)
	; format: pyyyxxxx
	; p is highest bit of num (T in prop)
	; yyy is which 16px row it starts at (double to get hi nybble of num)
	; xxxx is which tile it starts on (lo nybble of num)
	; 0 means start of SP1, which is why that means unloaded
	; start of SP2 is 0x40
	; start of SP3 is 0x80
	; start of SP4 is 0xC0

		!SD_Hammer		= !GFX_status+$100
		!SD_PlantHead		= !GFX_status+$101
		!SD_Bone		= !GFX_status+$102
		!SD_Fireball8x8		= !GFX_status+$103
		!SD_Fireball16x16	= !GFX_status+$104
		!SD_Goomba		= !GFX_status+$105
		!SD_LuigiFireball	= !GFX_status+$106
		!SD_Baseball		= !GFX_status+$107

	; super dynamic format:
	; bbpppppp
	; bb = bank
	; 00 = $7E
	; 01 = $7F
	; 10 = $40
	; 11 = $41
	; pppppp = location in bank (KB)
	;
	; address of GFX = bank [bb], hi byte [pppppp * 4], lo byte 0


		!Palset8		= $6028
		!Palset9		= $6029
		!PalsetA		= $602A
		!PalsetB		= $602B
		!PalsetC		= $602C
		!PalsetD		= $602D
		!PalsetE		= $602E
		!PalsetF		= $602F

	; index to palset table




	; SP_Files list
	;
	; make sure the order matches the dl list at the start of SP_Files
	; this list only affects defines, it does not insert anything into the ROM

	macro def_file(name)
		!File_<name> := !tempfile
		!tempfile := !tempfile+3
	endmacro

		!tempfile = 0

		; real time linear files

		; player files
		%def_file(Mario_Expand)
		%def_file(Mario_Supplement)
		%def_file(Luigi)
		%def_file(Kadaal)
		%def_file(Leeway)
		%def_file(Leeway_Sword)

		; dynamic sprite files
		%def_file(HappySlime)
		%def_file(AggroRex)
		%def_file(Wizrex)
		%def_file(TarCreeper_Body)
		%def_file(EliteKoopa)

		%def_file(NPC_Survivor)
		%def_file(NPC_Tinkerer)
		%def_file(NPC_Melody)
		%def_file(MiniMech)

		; boss files
		%def_file(CaptainWarrior)
		%def_file(CaptainWarrior_Axe)
		%def_file(Kingking)
		%def_file(LakituLovers)
		%def_file(LavaLord)

		; color gradients and palette tables
		%def_file(level06_night)

		; fonts and text box borders
		%def_file(default_font)
		%def_file(classic_font)
		%def_file(default_border)

		; extra stuff, sprite BG and such
		%def_file(Sprite_BG_1)


	; palset list
	;
	; make sure the order matches the order of palsets in SP_Files

	macro def_palset(name)
		!palset_<name> := !temppalset
		!temppalset := !temppalset+1
	endmacro

		!temppalset = 0

		; player palsets
		%def_palset(mario)
		%def_palset(luigi)
		%def_palset(kadaal)
		%def_palset(leeway)
		%def_palset(placeholder1)
		%def_palset(placeholder2)
		%def_palset(placeholder3)
		%def_palset(placeholder4)
		%def_palset(placeholder5)
		%def_palset(mario_fire)

		; default palsets
		%def_palset(default_yellow)
		%def_palset(default_blue)
		%def_palset(default_red)
		%def_palset(default_green)

		; generic palsets
		%def_palset(generic_grey)
		%def_palset(generic_ghost_blue)
		%def_palset(generic_lightblue)

		; special palsets
		%def_palset(special_wizrex)

		%def_palset(special_flash_white)
		%def_palset(special_flash_black)
		%def_palset(special_flash_red)
		%def_palset(special_flash_green)
		%def_palset(special_flash_blue)




		!Map16Remap		= $418000
			; 256 bytes, 1 for each map16 page
			; format: d-----tt
			; d - disable remap
			; tt - tt bits to use for remapped pages
			; if d is clear, the tile's tt bits are replaced by the remap tt bits


		!BigRAM			= $6080			; if this is moved to $3700, !TransformGFX has to be recoded
								; all defines have to have their highest bit cleared ($80-$FF -> $00-$7F)
								; and DP should be set to !BigRAM instead of !BigRAM-$80

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
		!P2FallSpeed		= !P2Base+$0B
		!P2Gravity		= !P2Base+$0C
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


	; MARIO

		!P2FlareDrill		= !P2Base+$1F		; used by Mario
		!P2Overdrive		= !P2Base+$20		; Mario's ultimate move
		!P2VectorBlocked	= !P2Base+$21		; prevents mario from vectoring into solid objects
		!P2FireFlash		= !P2Base+$22		; used to flash Mario upon getting fire


	; LUIGI

		!P2Carry		= !P2Base+$1F		; used by Luigi and Peach
		!P2PickUp		= !P2Base+$21		; forces crouch for Luigi
		!P2TurnTimer		= !P2Base+$22
					; 23 used by kick
					; 24 index mem 1
					; 25 index mem 2
		!P2SpinAttack		= !P2Base+$26
		!P2FireTimer		= !P2Base+$27
		!P2FireIndex		= !P2Base+$28
		!P2FireLife		= !P2Base+$29


	; KADAAL / LEEWAY

		!P2PoseTimer		= !P2Base+$1F		; Kadaal

		!P2ClimbFirst		= !P2Base+$1F		; Flag set during first frame of Leeway's climb

		!P2Senku		= !P2Base+$20
		!P2Punch1		= !P2Base+$21
		!P2Punch2		= !P2Base+$22
		!P2Kick			= !P2Base+$23		; also Luigi's kick timer

		!P2DashJump		= !P2Base+$20
		!P2SwordAttack		= !P2Base+$21
		!P2SwordTimer		= !P2Base+$22
		!P2Climb		= !P2Base+$23		; used by Mario (ledge) and Leeway

		!P2IndexMem1		= !P2Base+$24
		!P2IndexMem2		= !P2Base+$25

		!P2DashTimerR1		= !P2Base+$26		; Also Leeway's main dash leniency timer
								; for Mario, this is how many frames he has to hold B
								;  to fast swim
								;  set to its default value every frame B is let go

		!P2DashTimerR2		= !P2Base+$27		; Also Leeway's crouch timer
								; for Mario, this is an extra animation timer
								;  it is used for the fast swim


		!P2DashTimerL1		= !P2Base+$28		; Also ORA'd to Leeway's $6DA3 if L2 is set
		!P2DashTimerL2		= !P2Base+$29		; Also Leeway's Timer for L1



	; ALTER

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

		!P2SpinUsed		= !P2Base+$2F		; used by Luigi
		!P2SenkuUsed		= !P2Base+$2F		; used by Kadaal/Leeway

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
		!P2GravityMod		= !P2Base+$43		;\ Can be used to increase or decrease gravity
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
		!P2ClimbTimer		= !P2Base+$61		; how long Leeway can use dino grip for
		!P2ComboDash		= !P2Base+$62		; combo dash can be used if this is nonzero
		!P2ComboDisable		= !P2Base+$63		; set during combo dash to prevent chaining


		!P2LockPalset		= !P2Base+$7C		; while nonzero, player palset will not be reloaded
		!P2Init			= !P2Base+$7D		; set to 1 after player has run its init routine
		!P2ExtraBlock		= !P2Base+$7E
			; written to !P2Blocked, then cleared
			; also applies to Mario
			; highest bit is written to water status


		!P2CoyoteTime		= !P2Base+$7F
			; also applies to Mario
			; it works like this:
			;	j----ttt
			; every frame, t decrements
			; when t hits 0, j is cleared
			; if j i set when the character is on the ground, they will jump and this will be cleared
			; if t is nonzero, the character can jump even in midair
			; when the character is on the ground, t is set to 3
			; when the character presses jump in midair, j is set and t is set to 3



		!P1Dead			= $7FFF

		!MarioFireCharge	= $58
		!MarioClimb		= $62


		!SRAM_block		= $41B000
		!SaveFileSize		= $300
		!SaveSharedSize		= $134
		!SaveINIT		= !SRAM_block+(!SaveFileSize*3)+!SaveSharedSize-4
		!ChecksumComplement	= $1337

		!SRAM_buffer		= $41BC00		; has to be in same bank as !SRAM_block
		!Difficulty		= !SRAM_buffer+$00
					; -hicrtDD
					; DD - difficulty setting (00 = EASY, 01 = NORMAL, 10 = INSANE)
					; t = time
					; r = rank
					; c = critical
					; i = ironman
					; h = hardcore (not implemented)

		!CoinHoard		= !SRAM_buffer+$01	; 3 bytes, goes up to 999999 ($F423F)
		!YoshiCoinCount		= !SRAM_buffer+$04
		!Playtime		= !SRAM_buffer+$06	; 5 bytes (frames, seconds, minutes, hours)
		!PlayTimeFrames		= !Playtime+0		; 1 byte
		!PlayTimeSeconds	= !Playtime+1		; 1 byte
		!PlayTimeMinutes	= !Playtime+2		; 1 byte
		!PlayTimeHours		= !Playtime+3		; 2 bytes
		!Characters		= !SRAM_buffer+$0B
		!P1DeathCounter		= !SRAM_buffer+$0C	; 2 bytes
		!P2DeathCounter		= !SRAM_buffer+$0E	; 2 bytes

		!Database		= !SRAM_buffer+$10	; 64 bytes

		!CharacterData		= !SRAM_buffer+$50	; 60 bytes
		!MarioStatus		= !SRAM_buffer+$50
		!MarioUpgrades		= !SRAM_buffer+$51
					; 01 - fire flower??
					; 02 - Handy Glove
					; 04 - Heroic Cape
					; 08 - Tactical Fire
					; 10 - Flare Spin
					; 20 - Flare Drill
					; 40 - Flower DNA
					; 80 - Flame Overdrive
		!MarioPlaytime		= !SRAM_buffer+$52	; 5 bytes
		!MarioLevelsBeaten	= !SRAM_buffer+$57	; 1 byte
		!MarioDeathCounter	= !SRAM_buffer+$58	; 2 bytes

		!LuigiStatus		= !SRAM_buffer+$5A
		!LuigiUpgrades		= !SRAM_buffer+$5B
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!LuigiPlaytime		= !SRAM_buffer+$5C	; 5 bytes
		!LuigiLevelsBeaten	= !SRAM_buffer+$61	; 1 byte
		!LuigiDeathCounter	= !SRAM_buffer+$62	; 2 bytes

		!KadaalStatus		= !SRAM_buffer+$64
		!KadaalUpgrades		= !SRAM_buffer+$65
					; 01 - Senku Smash
					; 02 - Senku Control
					; 04 - Air Senku
					; 08 - Landslide
					; 10 - Shell Drill
					; 20 - Sturdy Shell
					; 40 - Ground Spin
					; 80 - Shun Koopa Satsu
		!KadaalPlaytime		= !SRAM_buffer+$66	; 5 bytes
		!KadaalLevelsBeaten	= !SRAM_buffer+$6B	; 1 byte
		!KadaalDeathCounter	= !SRAM_buffer+$6C	; 2 bytes

		!LeewayStatus		= !SRAM_buffer+$6E
		!LeewayUpgrades		= !SRAM_buffer+$6F
					; 01 - Combo Slash
					; 02 - Air Dash
					; 04 - Improved Air Dash
					; 08 - Combo Air Slash
					; 10 - Heroic Cape
					; 20 - Dino Grip
					; 40 - Rexcalibur
					; 80 - Star Strike
		!LeewayPlaytime		= !SRAM_buffer+$70	; 5 bytes
		!LeewayLevelsBeaten	= !SRAM_buffer+$75	; 1 byte
		!LeewayDeathCounter	= !SRAM_buffer+$76	; 2 bytes

		!AlterStatus		= !SRAM_buffer+$78
		!AlterUpgrades		= !SRAM_buffer+$79
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!AlterPlaytime		= !SRAM_buffer+$7A	; 5 bytes
		!AlterLevelsBeaten	= !SRAM_buffer+$7F	; 1 byte
		!AlterDeathCounter	= !SRAM_buffer+$80	; 2 bytes

		!PeachStatus		= !SRAM_buffer+$82
		!PeachUpgrades		= !SRAM_buffer+$83
					; 01 - 
					; 02 - 
					; 04 - 
					; 08 - 
					; 10 - 
					; 20 - 
					; 40 - 
					; 80 - 
		!PeachPlaytime		= !SRAM_buffer+$84	; 5 bytes
		!PeachLevelsBeaten	= !SRAM_buffer+$89	; 1 byte
		!PeachDeathCounter	= !SRAM_buffer+$8A	; 2 bytes


		!StoryFlags		= !SRAM_buffer+$8C
		; +00:	realm unlock state, 1 bit for each realm (if this is zero, load intro instead of realm select)
		; +01:	reserved for Realm 1
		; +02:	first 2 bits used by Mountain King






		!VRAMbank		= $40
		!VRAMbase		= !VRAMbank*$10000	; use !VRAMbase+!VRAMtable for long addressing
		!VRAMtable		= $4500
		!VRAMsize		= !VRAMtable+$FC	; remaining upload size
		!VRAMslot		= !VRAMtable+$FE	; index to start upload from
		!CGRAMtable		= $4600
		!TileUpdateTable	= $4700			; first 2 bytes in this table are the header (number of bytes)
								; after that, each 8x8 tile has 4 bytes: VRAM address + tile data
								; maximum of 252 bytes (63 tiles) in one frame
		!CCDMAtable		= $4800			; first 128 bytes are 16 slots for uploads greater than 256 bytes
								; second 128 bytes are 16 slots for uploads of 256 bytes or smaller


		!DebugData		= $404900		; values from V timer, used to track performance over time
								; each entry is 16 bytes and holds:
								; - times called (2 bytes)
								; - average cost (1 byte)
								; - max cost (1 byte)
								; - min cost (1 byte)
								; - previous entries, used to calculate averages (8 bytes)
								; - 3 bytes of padding to make data easier to read in debugger

		; misc
		!DebugZips		= 1			; 0 = normal, 1 = while holding select zips use map16 tile 0x0000

		; do not use several trackers at the same time!
		!TrackSpriteLoad	= 0			; 0 = do not track sprite load, 1 = track sprite load
		!TrackOAM		= 0			; 0 = do not track OAM, 1 = track OAM
		!TrackCPU		= 1			; 0 = do not track CPU performance, 1 = track CPU performance and save in .srm file
		!ResetTracker		= 1			; 0 = keep tracker on bootup, 1 = reset tracker on bootup

		; toggles for !TrackCPU
		!TrackFull		= 0
		!TrackVR3		= 1
		!TrackPCE		= 2
		!TrackMSG		= 3
		!TrackPlaneSplit	= 4
		!TrackFe26		= 5
		!TrackFusionCore	= 6


; tracker format:
; 00 - number of times called (16-bit)
; 02 - average scanline cost
; 03 - highest scanline cost
; 04 - lowest scanline cost
; 05 - running tally 1
; 06 - running tally 2
; 07 - running tally 3
; 08 - running tally 4
; 09 - running tally 5
; 0A - running tally 6
; 0B - running tally 7
; 0C - running tally 8
; 0D - 24-bit work area
;
macro ResetTracker()
	if !ResetTracker == 1
		PHP
		REP #$30
		LDA #$0000
		LDX #$00FE
	?Loop:	STA !DebugData,x
		DEX #2 : BPL ?Loop
		PLP
	endif
endmacro

macro TrackSetup(index)
	if !TrackCPU == 1
		PHP
		SEP #$20
		LDA $2137
		LDA $213D : XBA
		LDA $213D
		AND #$01
		XBA
		REP #$20
		STA !DebugData+$0E+(<index>*16)
		PLP
	endif
endmacro

macro TrackCPU(index)
	if !TrackCPU == 1
		PHB
		PHP
		SEP #$30
		LDA.b #!DebugData>>16
		PHA : PLB
		LDX.b #<index>*16
		LDA.w !DebugData+$00,x
		AND #$07
		CLC : ADC.b #<index>*16
		TAY
		LDA.l $2137
		LDA.l $213D : XBA
		LDA.l $213D
		AND #$01
		XBA
		REP #$20
		INC.w !DebugData+$00,x				; increment counter in 16-bit mode
		SEC : SBC.w !DebugData+$0E+(<index>*16)		; comparison
		BPL $04 : CLC : ADC.w #261			; account for V wraparound
		CMP #$0100					;\ if still negative, default to $FF
		BCC $03 : LDA #$00FF				;/
		SEP #$20
		STA.w !DebugData+$05,y				; store most recent and free up Y
		CMP.w !DebugData+$03,x : BCC ?NotMax
?Max:		STA.w !DebugData+$03,x
?NotMax:	LDY.w !DebugData+$04,x : BEQ ?Min		; minimum of 00 should always be overwritten
		CMP.w !DebugData+$04,x : BCS ?NotMin
?Min:		STA.w !DebugData+$04,x
?NotMin:	LDY #$00
		LDA.w !DebugData+$05,x
		CLC : ADC.w !DebugData+$06,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$07,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$08,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$09,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0A,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0B,x
		BCC $01 : INY
		CLC : ADC.w !DebugData+$0C,x
		BCC $01 : INY
		XBA
		TYA
		XBA
		REP #$20
		LSR #3
		SEP #$20
		STA !DebugData+$02,x

		PLP
		PLB
	endif
endmacro


macro SA1TrackSetup(index)
	if !TrackCPU == 1
		LDA.b #?SNES : STA $0183
		LDA.b #?SNES>>8 : STA $0184
		LDA.b #?SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	?Wait:	LDA $018A : BEQ ?Wait			; |
		STZ $018A				; |
		JMP ?End
	?SNES:
		%TrackSetup(<index>)
		RTL
	?End:
	endif
endmacro

macro SA1TrackCPU(index)
	if !TrackCPU == 1
		LDA.b #?SNES : STA $0183
		LDA.b #?SNES>>8 : STA $0184
		LDA.b #?SNES>>16 : STA $0185
		LDA #$D0 : STA $2209
	?Wait:	LDA $018A : BEQ ?Wait			; |
		STZ $018A				; |
		JMP ?End
	?SNES:
		%TrackCPU(<index>)
		RTL
	?End:
	endif
endmacro






		!HDMAptr		= $4046FC		; 24-bit, stored at the end of CGRAM table


		!OAM			= $6200			;\ Main mirror
		!OAMhi			= $6420			;/
		!OAMindex		= $7473			; lo byte
		!OAMindexhi		= $7474			; hi bit
		; $7474 has been remapped to $7475 to allow oam index to be used in 16-bit mode

		!OAM_p0			= $419000
		!OAM_p1			= $419200
		!OAM_p2			= $419400
		!OAM_p3			= $419600
		!OAMhi_p0		= $419800
		!OAMhi_p1		= $419880
		!OAMhi_p2		= $419900
		!OAMhi_p3		= $419980

		!OAMindex_p0		= $418FF8
		!OAMindex_p1		= $418FFA
		!OAMindex_p2		= $418FFC
		!OAMindex_p3		= $418FFE

		!PrioData		= $7FB0			; 16 bytes in mirror (generic bank)
		; holds a static block:
		; $0000,$0002,$0004,$0006
		; $0000,$0200,$0400,$0600
		; the first 4 entries are used to index the !OAMindex_px regs
		; the last 4 entries are added to the OAM index
		; this way, they can all be accessed with the same code

		!OAMindex_index		= !PrioData+0
		!OAMindex_offset	= !PrioData+8

		!ActiveOAM		= $7FC0			; 2 bytes, index to currently used !PrioData


		!Particle_Base		= $9A00			; bank $41

		; each particle is a 17-byte struct laid out as follows:
		!Particle_Type		= !Particle_Base+$00	; type + air resistance flag
		!Particle_Tile		= !Particle_Base+$01	; oam +2
		!Particle_Prop		= !Particle_Base+$02	; oam +3
		!Particle_Layer		= !Particle_Base+$03	; determines scrolling
		!Particle_Timer		= !Particle_Base+$04	; particle despawns when this hits 0 (if this is set to 0 at spawn, particle lasts indefinitely)
		!Particle_XSub		= !Particle_Base+$05	;\
		!Particle_XLo		= !Particle_Base+$06	; | 24-bit X coordinate
		!Particle_XHi		= !Particle_Base+$07	;/
		!Particle_XSpeed	= !Particle_Base+$08	; 16-bit X speed
		!Particle_XAcc		= !Particle_Base+$0A	; 8-bit X acceleration
		!Particle_YSub		= !Particle_Base+$0B	;\
		!Particle_YLo		= !Particle_Base+$0C	; | 24-bit Y coordinate
		!Particle_YHi		= !Particle_Base+$0D	;/
		!Particle_YSpeed	= !Particle_Base+$0E	; 16-bit Y coordinate
		!Particle_YAcc		= !Particle_Base+$10	; 8-bit Y acceleration

		; these are used as scratch during the drawing routine
		!Particle_XTemp		= $00
		!Particle_YTemp		= $04
		!Particle_TileTemp	= $08



		!PlayerBackupData	= $404E00		; > 128 bytes

		!MultiPlayer		= $404E80
		!CurrentPlayer		= $404E81		; Used on OW for character select and during levels

		; $404E82 free

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


		!MarioExtraWaterJump	= $404EA5

		; $404EA6-$404EB0 (11 bytes) free

		!ProcessingSprites	= $404EB1		; Set while sprites are being processed

		!VineDestroyBaseTime	= $404EB2		; Default timer option for vines (set by level code)

		!MegaLevelID		= $404EB3		; 0 = no mega level

		!TextPal		= $404EB4		; CCC bits of text prop, set to 0x18 by default

		!PauseThif		= $404EB5		; when set, thifs will not process

		!LevelInitFlag		= $404EB6		; 0 while INIT is running, 1 while MAIN is running

		!3DWater		= $404EB7		; enable/disable 3D water from DKC2

		!RenderingCache		= $404EB8		; 64 bytes, used to backup rendering regs


		!PaletteHSL		= $404EF8		; mirror of $6703 in HSL format, 3 bytes per color
								; following 768 bytes is scratch RAM / cache for additional HSL colors
								; after that is assembly area for HSL mixing (also 768 bytes)
								; last 512 bytes is color buffer for upload
								; so $300 + $300 + $300 + $200 = $B00 bytes, or 2.75KB

		!DizzyEffect		= $4059F8		; when enabled, table at $40A040 must be used to adjust sprite heights

		!3DWater_Color		= $4059F9		; 16-bit, should be set at level init
		!FileAddress		= $4059FB		; 24-bit, scratch pointer to file

	; next entry at $4059FE



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


	; -- 3D/2D Joint Cluster --

		!3D_Base		= $41C000

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


		!3D_AssemblyCache	= !3D_Base+$200

		!3D_TilemapPointer	= !3D_Base+$400
		!3D_BankCache		= !3D_Base+$402

		!3D_TilemapCache	= $6DDF		; 278 bytes

		!3D_Cache		= $F0		; DP is used for faster access
		!3D_Cache1		= !3D_Cache+$0
		!3D_Cache2		= !3D_Cache+$2
		!3D_Cache3		= !3D_Cache+$4
		!3D_Cache4		= !3D_Cache+$6
		!3D_Cache5		= !3D_Cache+$8
		!3D_Cache6		= !3D_Cache+$A
		!3D_Cache7		= !3D_Cache+$C
		!3D_Cache8		= !3D_Cache+$E


		!2D_Base		= !3D_Base

		!2D_Angle		= !2D_Base+$0	; rotation in relation to parent joint
		!2D_Rotation		= !2D_Base+$1	; total rotation, used to determine which tile to draw
		!2D_Distance		= !2D_Base+$2	; 16-bit, each unit represents 1/256th px
		!2D_X			= !2D_Base+$4
		!2D_Y			= !2D_Base+$6
		!2D_Attachment		= !2D_Base+$8	; 16-bit index
		!2D_Slot		= !2D_Base+$A	; 0 if slot is free, otherwise used
		!2D_Tilemap		= !2D_Base+$B	; tilemap index for this joint



	; -- Sprite stuff --

		!ExtraBits		= $3590		; extra bits of sprite
		!ExtraProp1		= $35A0		;
		!ExtraProp2		= $35B0		;
		!NewSpriteNum		= $35C0		; custom sprite number
					; $35F0		; P2 interaction disable timer
		!CustomBit		= $08


		!SpriteTweaker1		= $3440
		!SpriteTweaker2		= $3450
		!SpriteTweaker3		= $3460
		!SpriteTweaker4		= $3470
		!SpriteTweaker5		= $3480
		!SpriteTweaker6		= $34B0

		!SpriteAnimTimer	= $3310,x
		!SpriteAnimIndex	= $33D0,x
		!SpriteAnimIndexY	= $33D0,y
		!ClaimedGFX		= $32C0,x
		!ClaimedGFX_Y		= $32C0,y
		!AggroRexTile		= $35E0,x


		!SpriteWater		= $3430

		!SpriteStasis		= $34E0
		!SpriteGravityMod	= $3500
		!SpriteGravityTimer	= $3510
		!SpriteVectorY		= $3520
		!SpriteVectorX		= $3530
		!SpriteVectorAccY	= $3540
		!SpriteVectorAccX	= $3550
		!SpriteVectorTimerY	= $3560
		!SpriteVectorTimerX	= $3570
		!SpriteExtraCollision	= $3580			; Applies only on the frame that it's set

		!SpriteTile		= $6030			; offset to add to sprite tilemap numbers
		!SpriteProp		= $6040			; lowest bit of sprite OAM prop



	; -- Fusion Core --

		!Ex_Amount		= $25			; highest index is $24
		!Ex_Index		= $785D

		!CoinOffset		= $00
		!MinorOffset		= $02
		!ExtendedOffset		= $0E
		!SmokeOffset		= $21
		!BounceOffset		= $27
		!QuakeOffset		= $2F
		!ShooterOffset		= $32
		!CustomOffset		= $35


		!Ex_Palset		= $6050			; which palset a FusionCore sprite is using (hidden 13th reg, i suppose)

		!Ex_Index		= $7699			; rolling index for fusion sprites
		!Particle_Index		= $769A			; rolling index for particles (16-bit)

	; $1C3 bytes in this chunk
	; note that the order of the physics regs is important
		!Ex_Num			= $769C
		!Ex_Data1		= !Ex_Num+(!Ex_Amount*1)
		!Ex_Data2		= !Ex_Num+(!Ex_Amount*2)
		!Ex_Data3		= !Ex_Num+(!Ex_Amount*3)
		!Ex_YLo			= !Ex_Num+(!Ex_Amount*4)
		!Ex_XLo			= !Ex_Num+(!Ex_Amount*5)
		!Ex_YHi			= !Ex_Num+(!Ex_Amount*6)
		!Ex_XHi			= !Ex_Num+(!Ex_Amount*7)
		!Ex_YSpeed		= !Ex_Num+(!Ex_Amount*8)
		!Ex_XSpeed		= !Ex_Num+(!Ex_Amount*9)
		!Ex_YFraction		= !Ex_Num+(!Ex_Amount*10)
		!Ex_XFraction		= !Ex_Num+(!Ex_Amount*11)

		; ends at $7857
		; 4 bytes that are overwritten by the FusionCore data ($77BC-$77BF) are mapped to $7858-$785B
		; this means that there are no free bytes at the end of this block



	; -- MSG RAM --
		; DP define
		!MsgPal			= $61

		; LM pointer
		!MsgData		= $03BC0B		; Use this to figure out where Lunar Magic puts message data

		; bank $40 RAM
		!MsgRAM			= $4400			; 256 bytes, base address

		!MsgIndex		= !MsgRAM+$00		; 1 byte \ these two form a 16-bit index to the text data
		!MsgIndexHi		= !MsgRAM+$01		; 1 byte /
		!MsgOptions		= !MsgRAM+$02		; 1 byte
		!MsgArrow		= !MsgRAM+$03		; 1 byte
		!MsgOptionRow		= !MsgRAM+$04		; 1 byte, which row the dialogue options start on
		!MsgDestination		= !MsgRAM+$05		; 1 byte, determines what !MsgArrow writes to
		!MsgVertOffset		= !MsgRAM+$06		; 1 byte, number of pixels to move window down (doubled)
								;	  highest bit toggles portrait to top-right of screen
								;	  second highest bit disables border and window
		!MsgSequence		= !MsgRAM+$07		; 15 bytes, read backwards.
		!MsgScroll		= !MsgRAM+$16		; 1 byte, current scroll value
		!MsgCounter		= !MsgRAM+$17		; 1 byte
		!MsgDelay		= !MsgRAM+$18		; 1 byte
		!MsgTargScroll		= !MsgRAM+$19		; 1 byte, target scroll value
		!MsgWaitFlag		= !MsgRAM+$1A		; 1 byte, engine is paused while this is set, cleared by A/B/X/Y input
		!MsgInstantLine		= !MsgRAM+$1B		; 1 byte, when set the current line will be rendered instantly, cleared when a line is finished rendering
		!MsgFillerColor		= !MsgRAM+$1C		; 1 byte, used in place of transparency when rendering text
		!MsgPortrait		= !MsgRAM+$1D		; 1 byte, 6 bits used for portrait index, second highest bit flips portrait, highest bit marks that the portrait has been loaded
		!MsgSpeed		= !MsgRAM+$1E		; 1 byte
		!MsgEnd			= !MsgRAM+$1F		; 1 byte
		!MsgFont		= !MsgRAM+$20		; 1 byte
		!MsgVRAM1		= !MsgRAM+$21		; 2 bytes, portrait (lo plane)
		!MsgVRAM2		= !MsgRAM+$23		; 2 bytes, portrait (hi plane)
		!MsgVRAM3		= !MsgRAM+$25		; 2 bytes, border
		!MsgBackup41		= !MsgRAM+$27		; 1 byte
		!MsgBackup42		= !MsgRAM+$28		; 1 byte
		!MsgBackup43		= !MsgRAM+$29		; 1 byte
		!MsgBackup44		= !MsgRAM+$2A		; 1 byte
		!MsgBackupMainScreen	= !MsgRAM+$2B		; 1 byte
		!MsgBackupSubScreen	= !MsgRAM+$2C		; 1 byte
		!MsgBackup22		= !MsgRAM+$2D		; 1 byte
		!MsgBackup23		= !MsgRAM+$2E		; 1 byte
		!MsgBackup24		= !MsgRAM+$2F		; 1 byte
		!MsgBackup25		= !MsgRAM+$30		; 1 byte
		!MsgBackup13D5		= !MsgRAM+$31		; 1 byte, layer 3 scroll setting
		!MsgBackup3E		= !MsgRAM+$32		; 1 byte
		!MsgTalk		= !MsgRAM+$33		; 1 byte
		!MsgCinematic		= !MsgRAM+$34		; 1 byte, enables cinematic mode
		!MsgX			= !MsgRAM+$35		; 1 byte, X position to start drawing next character at
		!MsgRow			= !MsgRAM+$36		; 1 byte, current row of text
		!MsgCurrentArrow	= !MsgRAM+$37		; 1 byte, row of current arrow (used to replace it when it moves)
		!MsgWordLength		= !MsgRAM+$38		; 1 byte, accumulating word length
		!MsgCharCount		= !MsgRAM+$39		; 1 byte, accumulating characters
		!MsgWidth		= !MsgRAM+$3A		; 1 byte, how many 8x8 tiles are reserved on layer 3 for text
		!MsgInit		= !MsgRAM+$3B		; 1 byte, set to 80 when init code has been run
		!MsgCachedFont		= !MsgRAM+$3C		; 1 byte
		!MsgArrowMem		= !MsgRAM+$3D		; 1 byte, keeps track of which rows the dialogue arrow moves across
		!MsgTerminateRender	= !MsgRAM+$3E		; 1 byte, set by a command when a render should be terminated
		!MsgImportant		= !MsgRAM+$3F		; 1 byte: 0 = can fast forward with A/B/X/Y and skip with start, 1 = can fast forward with A/B/X/Y but not skip, 2 = can't fast forward or skip, $FF = buffering skip


	; -- 5bpp and GFX scaling --

		!GraphicsLoc	= $00				; 24-bit pointer to graphics file
		!GraphicsSize	= $03				; 8-bit number of 8x8 tiles


		!DecompBuffer	= $407000			; decompression buffer

		!BufferSize	= $0400				; Size of buffer. Must be divisible by 4.
		!BufferLo	= !DecompBuffer			; 24-bit 5bpp decompression buffer address.
		!BufferHi	= !BufferLo+(!BufferSize/2)	; Hi buffer.

		!GFX0		= $10				; Points to GFX+$00
		!GFX1		= $13				; Points to GFX+$01
		!GFX2		= $16				; Points to GFX+$10
		!GFX3		= $19				; Points to GFX+$11
		!GFX4		= $1C				; Points to GFX+$20

		!GFX_buffer	= $402000			; CC work RAM, 8kb
		!V_buffer	= $604000			; virtual VRAM mirror of !GFX_buffer

		!ImageCache	= $403000			; holds input GFX for rotation/scaling
		!V_cache	= $606000			; virtual VRAM mirror of image cache

		; !ImageCache is used as part of !GFX_buffer during triangle rendering
		; this allows images as large as 8kb (128x128px) to be rendered


		; the first 2kb holds the finished GFX
		; the following 2kb is used as work space for shearing
		; the last 4kb is the transformation image cache and holds input GFX
		; depending on mode, it holds up to:
		;	128 8x8 images
		;	32 16x16 images
		;	8 32x32 images
		;	2 64x64 images
		; note that input cache is expected to hold chunked linearly formatted GFX
		; format conversion might be necessary beforehand



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
		!LevelWidth		= $5E	; in screens
		!GlobalProperties	= $64
		!MarioAnim		= $71
		!MarioAir		= $72
		!MarioDucking		= $73
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
		!WaterLevel		= $85
		!IceLevel		= $86
		!MarioXPos		= $94
		!MarioXPosLo		= $94
		!MarioXPosHi		= $95
		!MarioYPos		= $96
		!MarioYPosLo		= $96
		!MarioYPosHi		= $97
		!GameMode		= $6100
		!LevelMode		= $6D9B
		!MainScreen		= $6D9D
		!SubScreen		= $6D9E
		!HDMA			= $6D9F
		!MarioJoypad1Raw	= $6DA2
		!MarioJoypad2Raw	= $6DA4
		!MarioJoypad1RawOneF	= $6DA6
		!ItemBox		= $6DC2
		!Translevel		= $73BF
		!PauseTimer		= $73D3
		!Pause			= $73D4
		!LevelHeight		= $73D7
		!CapeImg		= $73DF
		!MarioImg		= $73E0
		!MarioWallWalk		= $73E3
		!CapeEnable		= $73E8
		!CapeXPosLo		= $73E9
		!CapeXPosHi		= $73EA
		!CapeYPosLo		= $73EB
		!CapeYPosHi		= $73EC
		!MarioBehind		= $73F9
		!EnableHScroll		= $7411
		!EnableVScroll		= $7412
		!ScrollLayer1		= $7404
		!MarioSpinJump		= $740D
		!BG2ModeH		= $7413
		!BG2ModeV		= $7414
		!BG2BaseV		= $7417		; 16-bit
		!MsgTrigger		= $7426
		!ScrollSpriteNum	= $743E
		!ScrollSpriteNum_L1	= !ScrollSpriteNum
		!ScrollSpriteNum_L2	= $743F
		!BG3BaseSettings	= $745E		; first 5 bits determine y position, last 2 bits used by LM
		!BG3BaseSpeed		= $745F		; hi nybble is vertical option, lo nybble is horizontal option
		!MarioCarryingObject	= $7470
		!StarTimer		= $7490
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
		!GeneratorNum		= $78B9
		!WindowDir		= $7B88
		!WindowSize		= $7B89
		!SideExit		= $7B96
		!SPC1			= $7DF9
		!SPC2			= $7DFA
		!SPC3			= $7DFB
		!SPC4			= $7DFC
;		!LevelTable		= $7EA2

		!LevelTable1		= $7EA2		; BCH54321 (beaten, checkpoint flag, checkpoint level number hi bit, yoshi coins 1-5)
		!LevelTable2		= $6A60		; cccccccc (checkpoint level number lo byte)
		!LevelTable3		= $6120		; Rrrrrrrr (rank attained (0 = no 1 = yes), rank score (0-100))
		!LevelTable4		= $7938		; U-ssssss (unlock (0 = locked, 1 = unlocked), best time seconds (0-59))
		!LevelTable5		= $7F49		; --mmmmmm (best time minutes (0-63))

		!SpriteLoadStatus	= $418A00	; 255 bytes, 1 for each sprite in level data

	; -- Custom routines --

		!InitSpriteTables	= $07F7D2
		; same as !ResetSprite
		; procedure: set sprite num + extra bits, then call, then set ID, then store coords + status
		; NOTE: shreds $00-$02 when called for a custom sprite!

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
		!RGBtoHSL		= $138058
		!HSLtoRGB		= $138060
		!MixRGB			= $138068
		!MixRGB_Upload		= $138070
		!MixHSL			= $138078
		!MixHSL_Upload		= $138080
		!Update3DCluster	= $138088
		!Update2DCluster	= $13808C
		!GetFileAddress		= $138090
		!UpdateFromFile		= $138098
		!DecompFromFile		= $13809C
		!LoadFile		= $1380A0
		!SpriteHUD		= $1380A4
		!GetBigCCDMA		= $1380A8
		!GetSmallCCDMA		= $1380B0
		!BuildOAM		= $1380B8
		!ChangeMap16		= $1380C0

		!PortraitPointers	= $378000		; DATA pointer stored with SP_Files.asm, along with portrait GFX
		!PalsetData		= $3F8000		; DATA pointer stored with SP_Files.asm, along with palset data
		!PlayerPalettes		= !PalsetData+5		;

		!PlayerClipping		= read3($00E3D6)	; pointer is stored with PCE.asm

		!GenerateBlock		= read3($04842E)	; pointer is stored with SP_Patch.asm
		!GetDynamicTile		= read3($048443)	; pointer is stored with SP_Patch.asm
		!UpdateClaimedGFX	= read3($048446)	; pointer is stored with SP_Patch.asm
		!TransformGFX		= read3($048449)	; pointer is stored with SP_Patch.asm
		!LoadPortrait		= read3($04844C)	; pointer is stored with SP_Patch.asm
		!GetRoot		= read3($04844F)	; pointer is stored with SP_Patch.asm

		!LoadPalset		= $048452		; pointer to LoadPalset routine, must be manually read to be accessed (this is to avoid repatch problems)


	macro CallMSG()
		JSL read3($00A1DF+1)+4
	endmacro


	; -- SMW and LM routines --

		!BouncePlayer		= $01AA33
		!ContactGFX		= $01AB99

		!SpriteApplySpeed	= $01802A

		!GetSpriteSlot		= $02A9DE

		!GetSpriteClipping04	= $03B69F
		!GetSpriteClipping00	= $03B6E5

		!GetP1Clipping		= $03B664		; < Gets MARIO's clipping
		!CheckContact		= $03B72B

		!LoadTweakers		= $07F78B		; reloads vanilla tweakers and set OAM prop
		!ResetSprite		= $07F7D2		; hijacked by Fe26 to work with custom sprites
		; same as !InitSpriteTables
		; procedure: set sprite num + extra bits, then call, then set ID, then store coords + status
		; NOTE: shreds $00-$02 when called for a custom sprite!

		!ResetSpriteExtra	= $0187A7		; reloads spawn data

		!DecompressFile		= $0FF900


	; -- Data and pointers --

		!Map16ActsLike		= $06F624		; for pages 00-3F
		!Map16ActsLike40	= $06F63A		; for pages 40-7F

		!TrigTable		= $07F7DB

		!Map16BG		= $0EFD50		; 8 24-bit pointers
								; first to data for map16 pages 80-8F
								; next to data for pages 90-9F, and so on
								; if a pointer is zero, those pages are unused


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

