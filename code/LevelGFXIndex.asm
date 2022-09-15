
; bug list:
; 49		- growing pipe (generates weird tiles)




; $02BE4B - this RTL had been replaced somehow, breaking wall followers
;	    keep this in mind if they start crashing the game again


	print "Sprite GFX file table stored at $", pc, "."

macro gfx_index(name)
	dw !GFX_<name>_offset
endmacro


SpriteGFXIndex:
; this is which file each sprite corresponds to
; the value here is used as an index to .PartList, .SetList, and .SuperSetList
; word offsets 000-0FF are vanilla sprites
; word offsets 100-1FF are custom sprites
; a value of 0xFFFF means the sprite does not load anything
; a value of 0x8000 means the sprite should search the super-dynamic table but load nothing on its own

;===========================================;
;	vanilla sprite slots (000-0C8)
;===========================================;
.Vanilla
	%gfx_index(ShellessKoopa)	; 000
	%gfx_index(ShellessKoopa)	; 001
	%gfx_index(KickerKoopa)		; 002
	%gfx_index(ShellessKoopa)	; 003
	%gfx_index(Koopa)		; 004
	%gfx_index(Koopa)		; 005
	%gfx_index(KoopaBlue)		; 006
	%gfx_index(Koopa)		; 007
	%gfx_index(ParaKoopa)		; 008
	%gfx_index(ParaKoopa)		; 009
	%gfx_index(ParaKoopa)		; 00A
	%gfx_index(ParaKoopa)		; 00B
	%gfx_index(ParaKoopa)		; 00C
	%gfx_index(Bobomb)		; 00D
	%gfx_index(Key)			; 00E
	%gfx_index(Goomba)		; 00F
	%gfx_index(ParaGoomba)		; 010
	%gfx_index(BuzzyBeetle)		; 011
	dw $FFFF			; 012
	%gfx_index(Spiny)		; 013
	%gfx_index(Spiny)		; 014
	%gfx_index(Fish)		; 015
	%gfx_index(Fish)		; 016
	%gfx_index(Fish)		; 017
	%gfx_index(Fish)		; 018
	%gfx_index(Sign)		; 019
	%gfx_index(PiranhaPlant)	; 01A
	%gfx_index(Football)		; 01B
	%gfx_index(BulletBill)		; 01C
	%gfx_index(HoppingFlame)	; 01D
	%gfx_index(Lakitu)		; 01E
	%gfx_index(Magikoopa)		; 01F
	%gfx_index(Magikoopa)		; 020
	dw $FFFF			; 021
	%gfx_index(NetKoopa)		; 022
	%gfx_index(NetKoopa)		; 023
	%gfx_index(NetKoopa)		; 024
	%gfx_index(NetKoopa)		; 025
	%gfx_index(Thwomp)		; 026
	%gfx_index(Thwimp)		; 027
	%gfx_index(BigBoo)		; 028
	dw $FFFF			; 029
	%gfx_index(PiranhaPlant)	; 02A
	%gfx_index(SumoLightning)	; 02B
	dw $FFFF			; 02C
	dw $FFFF			; 02D
	%gfx_index(SpikeTop)		; 02E
	%gfx_index(SpringBoard)		; 02F
	%gfx_index(DryBonesThrower)	; 030
	%gfx_index(DryBones)		; 031
	%gfx_index(BonyBeetle)		; 032
	%gfx_index(Podoboo)		; 033
	%gfx_index(BossFireball)	; 034
	dw $FFFF			; 035
	dw $FFFF			; 036
	%gfx_index(Boo)			; 037
	%gfx_index(Eerie)		; 038
	%gfx_index(Eerie)		; 039
	%gfx_index(Urchin)		; 03A
	%gfx_index(Urchin)		; 03B
	%gfx_index(Urchin)		; 03C
	%gfx_index(RipVanFish)		; 03D
	%gfx_index(PSwitch)		; 03E
	%gfx_index(ParachuteGoomba)	; 03F
	%gfx_index(ParachuteBobomb)	; 040
	%gfx_index(Dolphin)		; 041
	%gfx_index(Dolphin)		; 042
	%gfx_index(Dolphin)		; 043
	%gfx_index(TorpedoTed)		; 044
	dw $FFFF			; 045
	%gfx_index(Chuck)		; 046
	%gfx_index(Fish)		; 047
	%gfx_index(ChuckRock)		; 048
	%gfx_index(GrowingPipe)		; 049
	dw $FFFF			; 04A
	%gfx_index(Lakitu)		; 04B
	%gfx_index(ExplodingBlock)	; 04C
	%gfx_index(MontyMole)		; 04D
	%gfx_index(MontyMole)		; 04E
	%gfx_index(PiranhaPlant)	; 04F
	%gfx_index(PiranhaPlant)	; 050
	%gfx_index(Ninji)		; 051
	%gfx_index(MovingLedge)		; 052
	%gfx_index(Blocks)		; 053
	dw $FFFF			; 054
	%gfx_index(CheckerPlat)		; 055
	%gfx_index(RockPlat)		; 056
	%gfx_index(CheckerPlat)		; 057
	%gfx_index(RockPlat)		; 058
	%gfx_index(Blocks)		; 059
	%gfx_index(Blocks)		; 05A
	%gfx_index(BrownGreyPlat)	; 05B
	%gfx_index(CheckerPlat)		; 05C
	%gfx_index(OrangePlat)		; 05D
	%gfx_index(OrangePlat)		; 05E
	%gfx_index(BrownGreyPlat)	; 05F
	dw $FFFF			; 060
	%gfx_index(FloatingSkulls)	; 061
	%gfx_index(BrownGreyPlat)	; 062
	%gfx_index(CheckerPlat)		; 063
	%gfx_index(Rope)		; 064
	%gfx_index(Chainsaw)		; 065
	%gfx_index(Chainsaw)		; 066
	%gfx_index(Grinder)		; 067
	%gfx_index(Fuzzy)		; 068
	dw $FFFF			; 069
	dw $FFFF			; 06A
	dw $FFFF			; 06B
	dw $FFFF			; 06C
	dw $FFFF			; 06D
	%gfx_index(DinoRhino)		; 06E
	%gfx_index(DinoTorch)		; 06F
	%gfx_index(Pokey)		; 070
	%gfx_index(SuperKoopa)		; 071
	%gfx_index(SuperKoopa)		; 072
	%gfx_index(SuperKoopa)		; 073
	dw $FFFF			; 074
	dw $FFFF			; 075
	%gfx_index(Starman)		; 076
	dw $FFFF			; 077
	dw $FFFF			; 078
	%gfx_index(PiranhaPlant)	; 079
	dw $FFFF			; 07A
	dw $FFFF			; 07B
	dw $FFFF			; 07C
	%gfx_index(PBalloon)		; 07D
	%gfx_index(AngelWings)		; 07E
	%gfx_index(AngelWings)		; 07F
	%gfx_index(Key)			; 080
	dw $FFFF			; 081
	dw $FFFF			; 082
	%gfx_index(Blocks)		; 083
	%gfx_index(Blocks)		; 084
	%gfx_index(Blocks)		; 085
	%gfx_index(Wiggler)		; 086
	%gfx_index(LakituCloud)		; 087
	dw $FFFF			; 088
	dw $FFFF			; 089
	%gfx_index(SmallBird)		; 08A
	dw $FFFF			; 08B
	dw $FFFF			; 08C
	dw $FFFF			; 08D
	dw $FFFF			; 08E
	%gfx_index(ScalePlat)		; 08F
	%gfx_index(GasBubble)		; 090
	%gfx_index(Chuck)		; 091
	%gfx_index(Chuck)		; 092
	%gfx_index(Chuck)		; 093
	%gfx_index(Chuck)		; 094
	%gfx_index(Chuck)		; 095
	%gfx_index(Chuck)		; 096
	%gfx_index(Chuck)		; 097
	%gfx_index(Chuck)		; 098
	%gfx_index(VolcanoLotus)	; 099
	%gfx_index(SumoBro)		; 09A
	%gfx_index(AmazingHammerBro)	; 09B
	%gfx_index(Blocks)		; 09C
	%gfx_index(CarrierBubble)	; 09D
	%gfx_index(BallAndChain)	; 09E
	%gfx_index(BanzaiBill)		; 09F
	dw $FFFF			; 0A0
	%gfx_index(BowlingBall)		; 0A1
	%gfx_index(MechaKoopa)		; 0A2
	%gfx_index(BrownGreyPlat)	; 0A3
	%gfx_index(SpikeBall)		; 0A4
	%gfx_index(Sparky)		; 0A5
	%gfx_index(HotHead)		; 0A6
	dw $FFFF			; 0A7
	%gfx_index(Blargg)		; 0A8
	%gfx_index(Reznor)		; 0A9
	%gfx_index(FishBone)		; 0AA
	%gfx_index(Rex)			; 0AB
	%gfx_index(WoodenSpike)		; 0AC
	%gfx_index(WoodenSpike)		; 0AD
	%gfx_index(FishingBoo)		; 0AE
	%gfx_index(BooBlock)		; 0AF
	%gfx_index(Boo)			; 0B0
	%gfx_index(Blocks)		; 0B1
	%gfx_index(FallingSpike)	; 0B2
	%gfx_index(StatueFireball)	; 0B3
	%gfx_index(Grinder)		; 0B4
	dw $FFFF			; 0B5
	%gfx_index(DiagPodoboo)		; 0B6
	%gfx_index(CarrotPlat)		; 0B7
	%gfx_index(CarrotPlat)		; 0B8
	dw $FFFF			; 0B9
	%gfx_index(TimerPlat)		; 0BA
	%gfx_index(CastleBlock)		; 0BB
	%gfx_index(BowserStatue)	; 0BC
	%gfx_index(KickerKoopa)		; 0BD
	%gfx_index(SwooperBat)		; 0BE
	%gfx_index(MegaMole)		; 0BF
	%gfx_index(RockPlat)		; 0C0
	%gfx_index(Blocks)		; 0C1
	%gfx_index(BlurpFish)		; 0C2
	%gfx_index(PorcuPuffer)		; 0C3
	%gfx_index(BrownGreyPlat)	; 0C4
	%gfx_index(BigBoo)		; 0C5
	dw $FFFF			; 0C6
	dw $FFFF			; 0C7
	dw $FFFF			; 0C8


;===========================================;
;	sprite command slots (0C9-0FF)
;===========================================;
	%gfx_index(BulletBill)		; 0C9
	%gfx_index(TorpedoTed)		; 0CA
	%gfx_index(Eerie)		; 0CB
	%gfx_index(ParachuteGoomba)	; 0CC
	%gfx_index(ParachuteBobomb)	; 0CD
	%gfx_index(ParachuteGen)	; 0CE (FC)
	%gfx_index(Dolphin)		; 0CF
	%gfx_index(Dolphin)		; 0D0
	%gfx_index(Fish)		; 0D1
	dw $FFFF			; 0D2
	%gfx_index(SuperKoopa)		; 0D3
	%gfx_index(CarrierBubble)	; 0D4
	%gfx_index(BulletBill)		; 0D5
	%gfx_index(BulletBillDiag)	; 0D6
	%gfx_index(BulletBillCardinals)	; 0D7
	%gfx_index(StatueFireball)	; 0D8
	dw $FFFF			; 0D9
	%gfx_index(Shell)		; 0DA
	%gfx_index(Shell)		; 0DB
	%gfx_index(Shell)		; 0DC
	%gfx_index(Shell)		; 0DD
	%gfx_index(Eerie)		; 0DE
	%gfx_index(Shell)		; 0DF
	%gfx_index(BrownGreyPlat)	; 0E0
	%gfx_index(Boo)			; 0E1
	%gfx_index(Boo)			; 0E2
	%gfx_index(Boo)			; 0E3
	%gfx_index(SwooperBat)		; 0E4
	%gfx_index(Boo)			; 0E5
	dw $FFFF			; 0E6
	dw $FFFF			; 0E7
	dw $FFFF			; 0E8
	dw $FFFF			; 0E9
	dw $FFFF			; 0EA
	dw $FFFF			; 0EB
	dw $FFFF			; 0EC
	dw $FFFF			; 0ED
	dw $FFFF			; 0EE
	dw $FFFF			; 0EF
	dw $FFFF			; 0F0
	dw $FFFF			; 0F1
	dw $FFFF			; 0F2
	dw $FFFF			; 0F3
	dw $FFFF			; 0F4
	dw $FFFF			; 0F5
	dw $FFFF			; 0F6
	dw $FFFF			; 0F7
	dw $FFFF			; 0F8
	dw $FFFF			; 0F9
	dw $FFFF			; 0FA
	dw $FFFF			; 0FB
	dw $FFFF			; 0FC
	dw $FFFF			; 0FD
	dw $FFFF			; 0FE
	dw $FFFF			; 0FF


;===========================================;
;	custom sprite slots (100-1FF)
;===========================================;
.Custom
	%gfx_index(SlimeParticles)	; 100
	%gfx_index(GoombaSlave)		; 101
	%gfx_index(Rex)			; 102
	%gfx_index(HammerRex)		; 103
	dw $FFFF			; 104
	%gfx_index(Conjurex)		; 105
	%gfx_index(FelMagic)		; 106 (new)
	dw $FFFF			; 107
	dw $FFFF			; 108
	%gfx_index(TarCreeperHands)	; 109
	dw $FFFF			; 10A
	%gfx_index(MoleWizard)		; 10B
	%gfx_index(MiniMole)		; 10C (new)
	dw $8000			; 10D (SD search)
	dw $FFFF			; 10E
	%gfx_index(Blocks)		; 10F
	dw $8000			; 110 (SD search)
	%gfx_index(Sign)		; 111
	dw $FFFF			; 112
	dw $FFFF			; 113
	dw $FFFF			; 114
	dw $FFFF			; 115
	%gfx_index(Thif)		; 116
	%gfx_index(Thif)		; 117
	%gfx_index(KompositeKoopa)	; 118
	%gfx_index(Birdo)		; 119
	%gfx_index(Birdo)		; 11A
	%gfx_index(Bumper)		; 11B
	%gfx_index(Monkey)		; 11C
	%gfx_index(Monkey)		; 11D
	%gfx_index(TerrainPlat)		; 11E
	%gfx_index(TerrainPlat)		; 11F
	dw $FFFF			; 120
	%gfx_index(CoinGolem)		; 121
	%gfx_index(YoshiCoin)		; 122
	%gfx_index(Koopa)		; 123
	%gfx_index(Koopa)		; 124
	%gfx_index(KoopaBlue)		; 125
	%gfx_index(Koopa)		; 126
	%gfx_index(BooHoo)		; 127
	dw $FFFF			; 128
	%gfx_index(FlamePillar)		; 129
	dw $FFFF			; 12A
	%gfx_index(Portal)		; 12B
	%gfx_index(FlyingRex)		; 12C
	%gfx_index(UltraFuzzy)		; 12D
	%gfx_index(Shield)		; 12E
	%gfx_index(Elevator)		; 12F
	%gfx_index(Chest)		; 130
	%gfx_index(CastleBlock)		; 131
	%gfx_index(SmallNumbers)	; 132
	dw $FFFF			; 133
	%gfx_index(Rex)			; 134
	dw $FFFF			; 135
	dw $FFFF			; 136
	%gfx_index(LightningEffects)	; 137
	dw $FFFF			; 138
	dw $FFFF			; 139
	dw $FFFF			; 13A
	dw $FFFF			; 13B
	dw $FFFF			; 13C
	dw $FFFF			; 13D
	dw $FFFF			; 13E
	dw $FFFF			; 13F
	dw $FFFF			; 140
	dw $FFFF			; 141
	dw $FFFF			; 142
	dw $FFFF			; 143
	dw $FFFF			; 144
	dw $FFFF			; 145
	dw $FFFF			; 146
	dw $FFFF			; 147
	dw $FFFF			; 148
	dw $FFFF			; 149
	dw $FFFF			; 14A
	dw $FFFF			; 14B
	dw $FFFF			; 14C
	dw $FFFF			; 14D
	dw $FFFF			; 14E
	dw $FFFF			; 14F
	dw $FFFF			; 150
	dw $FFFF			; 151
	dw $FFFF			; 152
	dw $FFFF			; 153
	dw $FFFF			; 154
	dw $FFFF			; 155
	dw $FFFF			; 156
	dw $FFFF			; 157
	dw $FFFF			; 158
	dw $FFFF			; 159
	dw $FFFF			; 15A
	dw $FFFF			; 15B
	dw $FFFF			; 15C
	dw $FFFF			; 15D
	dw $FFFF			; 15E
	dw $FFFF			; 15F
	dw $FFFF			; 160
	dw $FFFF			; 161
	dw $FFFF			; 162
	dw $FFFF			; 163
	dw $FFFF			; 164
	dw $FFFF			; 165
	dw $FFFF			; 166
	dw $FFFF			; 167
	dw $FFFF			; 168
	dw $FFFF			; 169
	dw $FFFF			; 16A
	dw $FFFF			; 16B
	dw $FFFF			; 16C
	dw $FFFF			; 16D
	dw $FFFF			; 16E
	dw $FFFF			; 16F
	dw $FFFF			; 170
	dw $FFFF			; 171
	dw $FFFF			; 172
	dw $FFFF			; 173
	dw $FFFF			; 174
	dw $FFFF			; 175
	dw $FFFF			; 176
	dw $FFFF			; 177
	dw $FFFF			; 178
	dw $FFFF			; 179
	dw $FFFF			; 17A
	dw $FFFF			; 17B
	dw $FFFF			; 17C
	dw $FFFF			; 17D
	dw $FFFF			; 17E
	dw $FFFF			; 17F
	dw $FFFF			; 180
	dw $FFFF			; 181
	dw $FFFF			; 182
	dw $FFFF			; 183
	dw $FFFF			; 184
	dw $FFFF			; 185
	dw $FFFF			; 186
	dw $FFFF			; 187
	dw $FFFF			; 188
	dw $FFFF			; 189
	dw $FFFF			; 18A
	dw $FFFF			; 18B
	dw $FFFF			; 18C
	dw $FFFF			; 18D
	dw $FFFF			; 18E
	dw $FFFF			; 18F
	dw $FFFF			; 190
	dw $FFFF			; 191
	dw $FFFF			; 192
	dw $FFFF			; 193
	dw $FFFF			; 194
	dw $FFFF			; 195
	dw $FFFF			; 196
	dw $FFFF			; 197
	dw $FFFF			; 198
	dw $FFFF			; 199
	dw $FFFF			; 19A
	dw $FFFF			; 19B
	dw $FFFF			; 19C
	dw $FFFF			; 19D
	dw $FFFF			; 19E
	dw $FFFF			; 19F
	dw $FFFF			; 1A0
	dw $FFFF			; 1A1
	dw $FFFF			; 1A2
	dw $FFFF			; 1A3
	dw $FFFF			; 1A4
	dw $FFFF			; 1A5
	dw $FFFF			; 1A6
	dw $FFFF			; 1A7
	dw $FFFF			; 1A8
	dw $FFFF			; 1A9
	dw $FFFF			; 1AA
	dw $FFFF			; 1AB
	dw $FFFF			; 1AC
	dw $FFFF			; 1AD
	dw $FFFF			; 1AE
	dw $FFFF			; 1AF
	dw $FFFF			; 1B0
	dw $FFFF			; 1B1
	dw $FFFF			; 1B2
	dw $FFFF			; 1B3
	dw $FFFF			; 1B4
	dw $FFFF			; 1B5
	dw $FFFF			; 1B6
	dw $FFFF			; 1B7
	dw $FFFF			; 1B8
	dw $FFFF			; 1B9
	dw $FFFF			; 1BA
	dw $FFFF			; 1BB
	dw $FFFF			; 1BC
	dw $FFFF			; 1BD
	dw $FFFF			; 1BE
	dw $FFFF			; 1BF
	dw $FFFF			; 1C0
	dw $FFFF			; 1C1
	dw $FFFF			; 1C2
	dw $FFFF			; 1C3
	dw $FFFF			; 1C4
	dw $FFFF			; 1C5
	dw $FFFF			; 1C6
	dw $FFFF			; 1C7
	dw $FFFF			; 1C8
	dw $FFFF			; 1C9
	dw $FFFF			; 1CA
	dw $FFFF			; 1CB
	dw $FFFF			; 1CC
	dw $FFFF			; 1CD
	dw $FFFF			; 1CE
	dw $FFFF			; 1CF
	dw $FFFF			; 1D0
	dw $FFFF			; 1D1
	dw $FFFF			; 1D2
	dw $FFFF			; 1D3
	dw $FFFF			; 1D4
	dw $FFFF			; 1D5
	dw $FFFF			; 1D6
	dw $FFFF			; 1D7
	dw $FFFF			; 1D8
	dw $FFFF			; 1D9
	dw $FFFF			; 1DA
	dw $FFFF			; 1DB
	dw $FFFF			; 1DC
	dw $FFFF			; 1DD
	dw $FFFF			; 1DE
	dw $FFFF			; 1DF
	dw $FFFF			; 1E0
	dw $FFFF			; 1E1
	dw $FFFF			; 1E2
	dw $FFFF			; 1E3
	dw $FFFF			; 1E4
	dw $FFFF			; 1E5
	dw $FFFF			; 1E6
	dw $FFFF			; 1E7
	dw $FFFF			; 1E8
	dw $FFFF			; 1E9
	dw $FFFF			; 1EA
	dw $FFFF			; 1EB
	dw $FFFF			; 1EC
	dw $FFFF			; 1ED
	dw $FFFF			; 1EE
	dw $FFFF			; 1EF
	dw $FFFF			; 1F0
	dw $FFFF			; 1F1
	dw $FFFF			; 1F2
	dw $FFFF			; 1F3
	dw $FFFF			; 1F4
	dw $FFFF			; 1F5
	dw $FFFF			; 1F6
	dw $FFFF			; 1F7
	dw $FFFF			; 1F8
	dw $FFFF			; 1F9
	dw $FFFF			; 1FA
	dw $FFFF			; 1FB
	dw $FFFF			; 1FC
	dw $FFFF			; 1FD
	dw $FFFF			; 1FE
	dw $FFFF			; 1FF



PalsetDefaults:
	db $FF				; pal 8
	db $FF				; pal 9
	db !palset_default_yellow	; pal A
	db !palset_default_blue		; pal B
	db !palset_default_red		; pal C
	db !palset_default_green	; pal D
	db $FF				; pal E
	db $FF				; pal F


	!FileMark	= $410000			; might be overwritten by super-dynamic GFX
	!BG_Mark	= $412000			; might be overwritten by super-dynamic GFX
	!SD_Mark	= $418800			; wiggler data, unused during GFX load

	!TempSpriteMark	= $414000			; used to generate sprites that are carried over by players


	GFXIndex:
		PHP						; preserve P
		SEP #$30					; all regs 8-bit
		STZ !PalsetA					;\
		STZ !PalsetB					; |
		STZ !PalsetC					; | clear palset regs
		STZ !PalsetD					; |
		STZ !PalsetE					; |
		STZ !PalsetF					;/
		LDA.b #ReadLevelData : STA $3180		;\
		LDA.b #ReadLevelData>>8 : STA $3181		; | have SA-1 scan level
		LDA.b #ReadLevelData>>16 : STA $3182		; |
		JSR $1E80					;/
		JSR GetFiles					; upload files


	; allocate dynamic tiles
	.AllocateDynamic
		REP #$20
		SEP #$10
		LDX #$1E					;\
	-	STZ !DynamicList,x				; | clear these regs
		DEX #2 : BPL -					; |
		STZ !DynamicTile				;/
		LDY #$00					; dynamic tile matrix index
		LDX #$00					; index to row data
		..loop						;\
		LDA !BigRAM,x					; |
		CMP #$0002 : BCC ..nextrow			; |
		STA $00						; | if a row has at least 2 blocks left, place a dynamic tile there
		LDA #$0010					; |
		SEC : SBC $00					; |
		CLC : ADC.l .DynamicNum,x			; |
		STA !DynamicMatrix,y				;/
		INY #2						; increment dynamic tile index
		DEC !BigRAM,x					;\ decrement space left on row
		DEC !BigRAM,x					;/
		CPY #$20 : BCC ..loop				; loop until all tiles are placed
		BRA ..end					; go to end
		..nextrow					;\
		INX #2						; | if row is full, go to next row
		CPX #$18 : BCC ..loop				;/
		..end						; done


	; allocate BG objects
		; load as streams of 8x8 tiles
		; this will work perfectly as all BG objects use exclusively 8x8 tiles

	.AllocateBG
	; object -> file
		PHB						; bank wrapper start
		REP #$30					;\
		LDA #$FFFF : STA !BG_status			; |
		LDA #$00FE					; | default values = 0xFF
		LDX.w #!BG_status+0				; |
		LDY.w #!BG_status+1				; |
		MVN !BG_status>>16,!BG_status>>16		;/
		SEP #$30					;\
		LDA.b #!BG_Mark>>16				; | switch bank
		PHA : PLB					;/
		LDY #$00					; 0x00-0xFF
	-	LDX.w !BG_Mark+$000,y : BEQ +			; if BG_object isn't marked, go to next
		LDA.l BG_objectFiles_Index,x : BEQ +		; if BG_object has no associated file, go to next
		TAX						;\ mark file as load
		INC.w !BG_Mark+$100,x				;/
	+	INY : BNE -					; loop
		PLB						; bank wrapper end

	; load files
		REP #$20
		LDA #$0100 : STA !BigRAM			; space remaining
		STZ !BigRAM+2					; currently decompressed GFX file
		LDA #$3000 : STA $2116				; starting VRAM (auto-incremented)
		LDA #$1801 : STA $4300				; DMA mode (words -> 2118)
		LDX.b #!DecompBuffer>>16 : STX $4304		; source bank
		LDA.w #!DecompBuffer : STA $00			;\ decompression address
		LDX.b #!DecompBuffer>>16 : STX $02		;/
		LDX #$00					; 0x00-0xFF

		..loop						;\
		LDA.l !BG_Mark+$100,x				; | check if file is marked for loading
		AND #$00FF : BEQ ..next				;/
		TXA						;\
		ASL A : TAY					; | check if the file exists
		LDA.w BG_objectFiles_List,y : BEQ ..next	;/
		STA $0E						;\
		LDA ($0E)					; | check if file is already decompressed
		CMP !BigRAM+2 : BEQ ..loadfromfile		;/
		..decompressfile				;\
		STA !BigRAM+2					; |
		PEI ($0E)					; | decompress file if necessary
		JSL !DecompressFile				; |
		PLA : STA $0E					;/
		..loadfromfile					;\ prepare to load tiles from file
		LDY #$02					;/
		..loadtilestring				;\
		LDA ($0E),y					; | check entry (tile string, status, or file end)
		AND #$00FF : BEQ ..next				; |
		CMP #$00FF : BNE ..fittiles			;/

		..status					;\
		INY						; |
		SEP #$20					; |
		PHX						; |
		LDA ($0E),y : TAX				; |
		LDA !BigRAM					; | mark where this part is loaded
		EOR #$FF : INC A				; |
		STA !BG_status,x				; |
		PLX						; |
		REP #$20					; |
		INY : BRA ..loadtilestring			;/

		..fittiles					;\
		CMP !BigRAM					; |
		BEQ ..upload					; |
		BCS ..next					; |
		..upload					; |
		STA $0C						; |
		SEC : SBC !BigRAM				; |
		EOR #$FFFF : INC A				; |
		STA !BigRAM					; |
		LDA $0C						; | load all tile strings from file
		ASL #5 : STA $4305				; |
		INY						; |
		LDA ($0E),y					; |
		AND #$00FF					; |
		ASL #5						; |
		ADC.w #!DecompBuffer				; |
		STA $4302					; |
		LDA #$0001 : STA $420B				; |
		INY : BRA ..loadtilestring			;/

		..next						;\
		INX : BEQ ..done				; | loop over all entries
		JMP ..loop					; |
		..done						;/


		SEP #$30
		LDA.b #.GenerateMap16 : STA $3180
		LDA.b #.GenerateMap16>>8 : STA $3181
		LDA.b #.GenerateMap16>>16 : STA $3182
		JSR $1E80


	; stuff loaded with players
		SEP #$20					;\
		LDA !GFX_ReznorFireball : BNE .NoMarioFire	; |
		LDA !MultiPlayer : BEQ +			; |
		LDA !Characters					; |
		AND #$0F : BNE +				; |
		LDA #$2A : BRA ++				; | mario fireball can be included in mario's file
	+	LDA !Characters					; |
		AND #$F0 : BNE .NoMarioFire			; |
		LDA #$0A					; |
	++	STA !GFX_ReznorFireball_tile			; |
		LDA #$00 : STA !GFX_ReznorFireball_prop		; |
		LDA #$01 : STA !SD_Mark+!SD_Fireball16x16_offset; |
		.NoMarioFire					;/

		LDA !MultiPlayer : BEQ +			;\
		LDA !Characters					; |
		AND #$0F					; |
		CMP #$01 : BNE +				; |
		LDA #$2D : BRA ++				; |
	+	LDA !Characters					; | luigi fireball
		AND #$F0					; |
		CMP #$10 : BNE .NoLuigiFire			; |
		LDA #$0D					; |
	++	STA !GFX_LuigiFireball_tile			; |
		LDA #$00 : STA !GFX_LuigiFireball_prop		; |
		LDA #$01 : STA !SD_Mark+!SD_LuigiFireball_offset; |
		.NoLuigiFire					;/

		LDA !MultiPlayer : BEQ +			;\
		AND #$0F					; |
		CMP #$20 : BNE .NoKadaalSwim			; |
		BRA ++						; |
	+	LDA !Characters					; | super-dynamic kadaal swim frames
		AND #$F0					; |
		CMP #$20 : BNE .NoKadaalSwim			; |
	++	LDA #$01 : STA !SD_Mark+!SD_KadaalLinear_offset	; |
		.NoKadaalSwim					;/


		JSR SuperDynamicFiles				; upload super-dynamic files
		SEP #$30

		LDY #$07					;\
	-	LDA !Palset8,y : BNE +				; |
		LDA #$80 : STA !Palset8,y			; | unused rows are marked 0x80, meaning they are free
		BRA ++						; |
	+	LDA PalsetDefaults,y : BMI ++			; | A-D load their default palsets if they are used
		STA !Palset8,y					; |
		TAX						; |
		TYA : STA !Palset_status,x			; |
	++	DEY						; |
		CPY #$02 : BCS -				;/

		REP #$30					; all regs 16-bit
		LDA.w #!PalsetData>>16 : STA $02		; bank byte
		LDX #$0005					;\
	-	LDA !PalsetA,x					; | check which palsets have to be loaded
		AND #$00FF					; |
		CMP #$0080 : BEQ +				;/
		AND #$007F					;\
		ASL #5						; |
		ADC.w #!PalsetData-$20				; |
		STA $00						; |
		LDY #$0000					; | pointer + indexes
		PHX						; |
		TXA						; |
		INC #2						; > compensate for +2
		ASL #5						; |
		TAX						;/
	--	LDA [$00],y : STA !PaletteRGB+($80*2),x		;\
		INX #2						; |
		INY #2						; | copy palset to palette
		CPY #$0020 : BCC --				; |
		PLX						;/
	+	DEX : BPL -					; loop




		PLP
		RTS



	.DynamicNum
		dw $0080,$00A0,$00C0,$00E0	; SP2
		dw $0100,$0120,$0140,$0160	; SP3
		dw $0180,$01A0,$01C0,$01E0	; SP4




; $00 = location of source GFX (tile in VRAM)
; $01 = width (added to tile num to get nums of lower half of block)
; $02 = xflip (x ordering is inverted if set)

	; generate map16
	.GenerateMap16
		PHB						; bank wrapper start
		PHP						; reg wrapper start
		REP #$30					; all regs 16-bit

		LDA #$0300*2 : JSL $06F540			;\
		STA $E0						; |
		INC A : STA $E2					; |
		INC A : STA $E4					; |
		INC A : STA $E6					; | full pointer setup for map16 tile data
		INC A : STA $E8					; |
		INC A : STA $EA					; |
		INC A : STA $EC					; |
		INC A : STA $EE					;/
		LDA #$0000					; > clear B
		SEP #$20
		LDA $0C
		PHA : PLB
		LDY #$0000					; starting index = 0

		..loop						;\
		LDA ($E8),y : TAX				; | check if file is loaded
		LDA !BG_status,x				; |
		CMP #$FF : BEQ ..next				;/
		STA $00						; $00 = location of source GFX (tile in VRAM)

		LDA ($E0),y : STA $02				;\
		AND #$3F					; | get width ($01) and xflip ($02)
		TRB $02						; |
		STA $01						;/

		LDA ($E4),y					; read base tile
		CLC : ADC $00					; add offset from VRAM location
		CLC						; clear C
		TYX						; X = index (same as Y)
		BIT $02 : BVS ..flip				; check flip
		..noflip					;\
		STA !Map16Page3+$00,x				; |
		INC A : STA !Map16Page3+$04,x			; |
		ADC $01						; | get tile nums for map16 block (no flip)
		STA !Map16Page3+$06,x				; |
		DEC A : STA !Map16Page3+$02,x			; |
		BRA ..next					;/
		..flip						;\
		STA !Map16Page3+$04,x				; |
		INC A : STA !Map16Page3+$00,x			; | get tile nums for map16 block (with flip)
		ADC $01						; |
		STA !Map16Page3+$02,x				; |
		DEC A : STA !Map16Page3+$06,x			;/
		..next						;\
		TYX						; |
		LDA ($E2),y					; |
		ORA #$03 : STA !Map16Page3+$01,x		; |
		LDA ($E6),y					; | get property bytes from LM's map16 data
		ORA #$03 : STA !Map16Page3+$03,x		; |
		LDA ($EA),y					; |
		ORA #$03 : STA !Map16Page3+$05,x		; |
		LDA ($EE),y					; |
		ORA #$03 : STA !Map16Page3+$07,x		;/
		REP #$20					;\
		TYA						; |
		CLC : ADC #$0008				; | loop through entire map16 page
		TAY						; |
		LDA #$0000					; > clear B
		SEP #$20					; |
		CPY.w #$0100*8 : BCC ..loop			;/

		REP #$20
		LDA #$00F8					;\
		STA !Map16Page3+($70*8)+$00			; |
		STA !Map16Page3+($70*8)+$04			; | these tiles in the trashcan are clear
		STA !Map16Page3+($82*8)+$00			; |
		STA !Map16Page3+($82*8)+$04			;/
		STA !Map16Page3+($50*8)+$02			;\ these tiles in the cable tile are clear
		STA !Map16Page3+($50*8)+$06			;/

		PLP						; reg wrapper end
		PLB						; bank wrapper end
		RTL						; return



; address of page3 tiles:
; tile num * 8 + read2($6F552+1) + (read1($06F555+2)<<16)

print "Map16 page 3 data is stored at $", hex(($300*8)+read2($6F552+1)+(read1($06F555+2)<<16))
;
; org ($300*8)+read2($6F552+1)+(read1($06F555+2)<<16)+0
; org ($300*8)+read2($6F552+1)+(read1($06F555+2)<<16)+2
; org ($300*8)+read2($6F552+1)+(read1($06F555+2)<<16)+4
; org ($300*8)+read2($6F552+1)+(read1($06F555+2)<<16)+6
;
;


macro TileInfo(map16, tilecount, basetile, gfxindex)
	pushpc
		org (($300+<map16>)*8)+read2($6F552+1)+(read1($06F555+2)<<16)+0
			db <tilecount>
		org (($300+<map16>)*8)+read2($6F552+1)+(read1($06F555+2)<<16)+2
			db <basetile>
		org (($300+<map16>)*8)+read2($6F552+1)+(read1($06F555+2)<<16)+4
			db <gfxindex>
		org (($300+<map16>)*8)+read2($6F552+1)+(read1($06F555+2)<<16)+6
			; unused
	pullpc
endmacro

		; bush
		%TileInfo($00, $04, $00, !GFX_BushFrame1)
		%TileInfo($01, $04, $02, !GFX_BushFrame1)

		; windows
		%TileInfo($10, $04, $00, !GFX_Window)
		%TileInfo($11, $04, $02, !GFX_Window)
		%TileInfo($20, $04, $08, !GFX_Window)
		%TileInfo($21, $04, $0A, !GFX_Window)
		%TileInfo($12, $04, $00, !GFX_WindowBroken)
		%TileInfo($13, $04, $02, !GFX_WindowBroken)
		%TileInfo($22, $04, $08, !GFX_WindowBroken)
		%TileInfo($23, $04, $0A, !GFX_WindowBroken)

		; cannon
		%TileInfo($30, $04, $00, !GFX_CannonIdle)
		%TileInfo($31, $04, $02, !GFX_CannonIdle)
		%TileInfo($40, $04, $08, !GFX_CannonIdle)
		%TileInfo($41, $04, $0A, !GFX_CannonIdle)
		%TileInfo($32, $04, $00, !GFX_CannonIdle)
		%TileInfo($33, $04, $02, !GFX_CannonIdle)
		%TileInfo($42, $04, $08, !GFX_CannonIdle)
		%TileInfo($43, $04, $0A, !GFX_CannonIdle)

		; trashcan
		%TileInfo($70, $02, -$02, !GFX_TrashCan) ; -2 because we only want the first 2 tiles, but they have to end up in the bottom half
		%TileInfo($80, $02, $04, !GFX_TrashCan)
		%TileInfo($71, $42, $08, !GFX_TrashCan)
		%TileInfo($81, $02, $08, !GFX_TrashCan)
		%TileInfo($82, $02, $00, !GFX_TrashCan)






; file format:
; - header	2 b	size of DMA data (highest 2 bits determine priority)
; - GFX file	2 b	which LM GFX file to use
; - GFX status	1 b	index to GFX status table
; - block count	1 b	how many blocks (8x16px chunks) the file needs
; - DMA data	var	each row has 3 bytes: offset in file, offset in VRAM, and number of 8x8 tiles
; - commands	var	used to include and mark other files, usually only hi prio files have these
; - FF		1 b	signals the end of the file
;
; super-dynamic file format:
; - width	2 b	width encoding of file
; - size	2 b	RAM required (including command-generated images)
; - GFX address	2 b	ExGFX file to load from
; - GFX status	1 b	index to super-dynamic load table
; - chunk count	1 b	how many chunks the file has
; - chunk w	1 b	horizontal size of chunks (/2)
; - chunk h	1 b	vertical size of chunks
; - commands	var	used to scale and rotate chunks
; - FF		1 b	signals the end of the file
;
; 00 - rotate (80 - maintain image width)
; - chunk	1 b	which chunk should be rotated
; - iterations	1 b	how many chunks should be rotated (uses the same angle and copies)
; - angle	1 b	which angle to apply
; - copies	1 b	how many times each rotated chunk should be copied with the rotation applied again
;
; 01 - scale (81 - maintain image width)
; - chunk	1 b	which chunk should be scaled
; - iterations	1 b	how many chunks should be scaled in the same way
; - x scaling	1 b	x scaling
; - y scaling	1 b	y scaling
;
; images generated by commands will simply be placed at the end of the original file




; idea
; i still use the file system, and each sprite is associated with a file
; then i mark a file as "should load" in a RAM table if the corresponding sprite is found in the data
; this way dupes won't cause any issues
; a "file" consists of a dynamo expanded to include source GFX, since the graphics are compressed
; i should order files based on which source GFX they use, to minimize decompression time

;
; there are something like 100 files that are loaded by tileset sprites
; with the global sprites, fusion core sprites and custom sprites added, 256 files in total will probably do
; so i need a RAM table with 256 entries that start off but are toggled on during the scan
; after than, files are loaded until they are all done or sprite VRAM is full
;

; format:
; - header (16-bit, byte count of file information) highest bit is priority, if that is set then this should be uploaded in pass 1
; - source GFX (16-bit)
; - GFX status (8-bit)
; - total size (8-bit, number of 8x16 chunks)
; (repeat the following 3 for each entry)
; - VRAM offset (8-bit, 8x8 tiles)
; - source start (8-bit, 8x8 tile number)
; - size (8-bit, number of 8x8 tiles)
; (ending bytes)
; - a series of commands
;	- $00,$XX,$YY: set status $XX to file offset + $YY
;	- $01,$XX: load extra file $XX during pass 3
;	- $02,$XX: mark super-dynamic file
;	- $FF: end
; hi priority files are uploaded in pass 1 (these have complex shapes and/or include lo priority files)
; lo priority files are uploaded in pass 2 (these have simple shapes and do not include other files)
; support files are uploaded in pass 3
;
;
; processing should go:
; - store size of file information
; - unpack ExGFX
; - start uploading from ..start
; - stop uploading at ..end
;
;

; this is a simple source command, which will upload a 16px tall stripe of variable length (max 128px/16 characters wide)
; it will set one byte in !GFX_status


; here, !BigRAM holds information on how many tiles are free on each row
; when a file is uploaded, it is sent to the first area large enough to hold it (no line break allowed)
; this means that large files tend to start at new rows, with small ones filling in the gaps at the end of rows
; offset	location	address
;	0x00	SP2 row 1	$6800
;	0x02	SP2 row 2	$6A00
;	0x04	SP2 row 3	$6C00
;	0x06	SP2 row 4	$6E00
;	0x08	SP3 row 1	$7000
;	0x0A	SP3 row 2	$7200
;	0x0C	SP3 row 3	$7400
;	0x0E	SP3 row 4	$7600
;	0x10	SP4 row 1	$7800
;	0x12	SP4 row 2	$7A00
;	0x14	SP4 row 3	$7C00
;	0x16	SP4 row 4	$7E00

GetFiles:
		REP #$30				; all regs 16-bit
		LDX #$0016				;\
		LDA #$0010				; | clear VRAM allocation table
	-	STA !BigRAM,x				; |
		DEX #2 : BPL -				;/
		STZ !BigRAM+$7E				; reset this (currently decompressed file)


		.SuperSets				;\
		LDX #$0000				; |
		..loop					; |
		LDA !FileMark+$500,x : STA $02		; |
		AND #$7FFF : BEQ ..next			; |
		LDA !GFX_status+$500,x : STA $0C	; |
		LDA File_SuperSetList,x			; |
		PHX					; | load supersets
		PEA.w ..return-1			; |
		BRA .Load				; |
		..return				; |
		PLX					; |
		..next					; |
		INX #2					; |
		CPX #$0080 : BCC ..loop			;/

		.Sets					;\
		LDX #$0000				; |
		..loop					; |
		LDA !FileMark+$400,x : STA $02		; |
		AND #$7FFF : BEQ ..next			; |
		LDA !GFX_status+$400,x : STA $0C	; |
		LDA File_SetList,x			; |
		PHX					; | load sets
		PEA.w ..return-1			; |
		BRA .Load				; |
		..return				; |
		PLX					; |
		..next					; |
		INX #2					; |
		CPX #$0100 : BCC ..loop			;/

		.Parts					;\
		LDX #$0000				; |
		..loop					; |
		LDA !FileMark,x : STA $02		; |
		AND #$7FFF : BEQ ..next			; |
		LDA !GFX_status,x : STA $0C		; |
		LDA File_PartList,x			; |
		PHX					; | load parts
		PEA.w ..return-1			; |
		BRA .Load				; |
		..return				; |
		PLX					; |
		..next					; |
		INX #2					; |
		CPX #$0400 : BCC ..loop			;/
		RTS					; return



macro EXTREME_FAIL()
	if !Debug = 1
		LDA #$0080 : STA $9D
	endif
endmacro


; use of scratch RAM, 16-bit regs
; $00: pointer to file information
; $02: starting VRAM of file
; $04: 
; $06: GFX status offset/index
; $08: total number of 8x16 blocks used
; $0A: number of rows needed (used for big files)
; $0C: starting tile of tile (PYYYXXXX format)
; $0E: size of file information, used for loop

		.Load						;\ pointer to data
		STA $00						;/
		LDA $02 : BMI ..included			; if file was included, just read its commands
		LDA ($00)					; read size
		AND #$00FF : BNE ..file				; see if this entry has an upload command
		..included					;\
		LDA ($00)					; |
		AND #$00FF					; |
		BNE $03 : LDA #$0006				; | skip header and process commands
		TAY						; |
		SEP #$20					; |
		JMP .LoadFlags					;/

		..file						;\ push file size
		PHA						;/
		LDY #$0001					;\
		LDA ($00),y					; | get file number
		AND #$0FFF					;/
		CMP #$0F00 : BCS ..exgfx			;\
		TAY						; | num < $F00 = uncompressed file, num => $F00 = ExGFX
		JSL GetFileAddress				; |
		BRA ..addressdone				;/
		..exgfx						;\ don't decompress if already decompressed
		CMP !BigRAM+$7E : BEQ ..decompdone		;/
		STA !BigRAM+$7E					; store ExGFX num of currently decompressed file
		PEI ($00)					; push pointer
		LDY.w #!DecompBuffer : STY $00			;\ decompression buffer pointer
		LDY.w #!DecompBuffer>>8 : STY $01		;/
		SEP #$10					;\
		JSL !DecompressFile				; | decompress, load full ExGFX file into !DecompBuffer
		REP #$30					;/
		PLA : STA $00					;\ restore pointer
		..decompdone					;/
		LDA.w #!DecompBuffer : STA !FileAddress		;\ address of source GFX
		LDA.w #!DecompBuffer>>8 : STA !FileAddress+1	;/
		..addressdone					;\ $0E = block information size
		PLA : STA $0E					;/
		LDY #$0003					;\ $06 = GFX status index
		LDA ($00),y : STA $06				;/
		LDY #$0005					;\
		LDA ($00),y					; | $08 = number of 8x16px blocks needed
		AND #$00FF : STA $08				;/
		LDY #$0006					; Y = index to block information
		LDX #$0000					; X = index to current row load status (!BigRAM)
		CMP #$0011 : BCC .SmallBlock			; check size

		.BigBlock					;\
		LSR #4						; |
		AND #$000F					; |
		TAY						; | Y = number of full rows needed
		LDA $08						; |
		AND #$000F					; |
		BEQ $01 : INY					;/
		STY $0A						; store to $0A
		..loop						;\
		LDA !BigRAM,x					; |
		CMP #$0010 : BEQ ..thisone			; | look for an empty row to start at
		INX #2						; |
		CPX #$0018 : BCC ..loop				;/
		..EXTREME_FAIL_1
		%EXTREME_FAIL()
		RTS						; return if there isn't enough space

		..thisone					;\
		LDA .VRAM,x : STA $02				; | preliminary starting VRAM
		CPX #$0008 : BCS ..SP34				;/
		..SP2						;\
		TXA						; |
		SEC : SBC #$0008				; | number of rows free in SP2
		EOR #$FFFF : INC A				; |
		LSR A						;/
		CMP $0A : BCS .MarkFile				; compare to number of rows required
		LDX #$0008					;\ if there's not enough room, check next page
		BRA ..loop					;/
		..SP34						;\
		TXA						; |
		SEC : SBC #$0018				; | number of rows free on second page
		EOR #$FFFF : INC A				; |
		LSR A						;/
		CMP $0A : BCS .MarkFile				; compare to number of rows required
		..EXTREME_FAIL_2
		%EXTREME_FAIL()
		RTS						; return if there isn't enough space

		.SmallBlock					;\
		..loop						; |
		CMP !BigRAM,x					; |
		BEQ ..thisone					; | look for a row with an equal or greater number of free tiles
		BCC ..thisone					; |
		INX #2						; |
		CPX #$0018 : BCC ..loop				;/
		..EXTREME_FAIL_3
		%EXTREME_FAIL()
		RTS						; return if there isn't enough space


		..thisone					;\
		LDA #$0010					; |
		SEC : SBC !BigRAM,x				; |
		ASL #4						; | starting dest VRAM
		CLC : ADC .VRAM,x				; | (*16 instead of *32 because word address)
		STA $02						;/

		.MarkFile					;\
		LDA $02						; |
		AND #$1FF0					; | tile + prop of file (-------T tttttttt)
		LSR #4						; |
		STA $0C						;/
		LDA $08						;\
		..loop						; |
		CMP #$0010 : BCC ..thisone			; |
		SBC #$0010					; | loop through full rows
		STZ !BigRAM,x					; |
		INX #2						; |
		DEY : BNE ..loop				;/
		..thisone					;\
		SEC : SBC !BigRAM,x				; | update number free blocks remaining on current row
		EOR #$FFFF : INC A				; |
		STA !BigRAM,x					;/
		LDY #$0006					; Y = starting index to file information

		.UploadFile					;\
		..loop						; |
		LDA ($00),y					; |
		AND #$00FF					; | dest VRAM
		ASL #4						; |
		CLC : ADC $02					; |
		STA $2116					;/
		INY						;\
		LDA ($00),y					; |
		AND #$00FF					; |
		XBA						; | source address
		LSR #3						; |
		CLC : ADC !FileAddress				; |
		STA $4302					;/
		INY						;\
		LDA ($00),y					; |
		AND #$00FF					; | upload size
		XBA						; |
		LSR #3						; |
		STA $4305					;/
		LDA #$1801 : STA $4300				; DMA parameters
		INY						; > update index
		SEP #$20					;\
		LDA !FileAddress+2 : STA $4304			; |
		LDA #$80 : STA $2115				; | finish DMA after setting source bank and video port
		LDA #$01 : STA $420B				; |
		REP #$20					;/
		CPY $0E : BCC ..loop				; loop through upload stripes
		..gfxstatus					;\
		LDX $06						; |
		LDA $0C : STA !GFX_status,x			; | set main GFX status
		LDA #$0000 : STA !FileMark,x			; > don't reload this
		SEP #$20					;/

		.LoadFlags					;\
		..loop						; |
		LDA ($00),y : BEQ ..include			; | determine command code
		CMP #$01 : BEQ ..mark				; | (any other value ends the block, usually 0xFF)
		CMP #$02 : BEQ ..superdynamic			; |
		CMP #$03 : BEQ ..defaultpal			;/
		..done						;\
		REP #$30					; | all regs 16-bit, then return
		RTS						;/

		..defaultpal					;\
		INY						; |
		LDA ($00),y					; |
		CMP #$07					; |
		BCC $02 : LDA #$00				; | mark selected palset as used
		TAX						; |
		LDA #$01 : STA !Palset8,x			; |
		INY						; |
		BRA ..loop					;/

		..mark						;\
		INY						; |
		REP #$20					; |
		LDA ($00),y : TAX				; |
		LDA !FileMark,x					; | mark file for loading, then loop
		ORA #$0001					; |
		STA !FileMark,x					; |
		SEP #$20					; |
		INY #2						; |
		BRA ..loop					;/

		..include					;\
		INY						; |
		REP #$20					; |
		LDA ($00),y : TAX				; |
		INY #2						; | mark file as included
		LDA ($00),y					; |
		AND #$00FF					; > this is fine because large files always start at X = 0
		CLC : ADC $0C					; |
		STA !GFX_status,x				; |
		LDA !FileMark,x					; |
		ORA #$8000					; |
		STA !FileMark,x					; |
		SEP #$20					; |
		INY						; |
		BRA ..loop					;/

		..superdynamic					;\
		INY						; |
		REP #$20					; |
		LDA ($00),y					; |
		AND #$00FF : TAX				; | mark super dynamic file for loading, then loop
		SEP #$20					; |
		LDA #$01 : STA !SD_Mark,x			; |
		INY						; |
		BRA ..loop					;/


; starting address of each row
.VRAM	dw $6800
	dw $6A00
	dw $6C00
	dw $6E00
	dw $7000
	dw $7200
	dw $7400
	dw $7600
	dw $7800
	dw $7A00
	dw $7C00
	dw $7E00



; note that these correspond to GFX status offsets
File:
	.PartList
		; simple enemies
		dw .Goomba
		dw .Bobomb
		dw .Spiny
		dw .SpikeTop
		dw .BuzzyBeetle
		dw .SwooperBat
		dw .MontyMole
		dw .MegaMole
		dw .MiniMole
		dw .HoppingFlame
		dw .Lakitu
		dw .Wiggler
		dw .Thwomp
		dw .Thwimp
		dw .Podoboo
		dw .DiagPodoboo
		dw .BallAndChain
		dw .FallingSpike
		dw .WoodenSpike
		dw .Grinder
		dw .Sparky
		dw .HotHead
		dw .MechaKoopa
		dw .SpikeBall
		dw .Fuzzy
		dw .SuperKoopa
		dw .Pokey
		dw .Ninji
		dw .Thif
		dw .NetKoopa
		dw .BulletBill
		dw .BulletBillDiag
		dw .BulletBillUp
		dw .BanzaiBill
		dw .BowlingBall
		dw .FishBone
		dw .DryBones
		dw .BonyBeetle
		dw .Fish
		dw .BlurpFish
		dw .PorcuPuffer
		dw .Dolphin
		dw .Urchin
		dw .TorpedoTed
		dw .Reznor
		dw .Birdo
		dw .Monkey
		dw .FlamePillar
		dw .GasBubble
		dw .UltraFuzzy
		dw .TarCreeperHands
		dw .Boo
		dw .Eerie
		dw .FishingBoo
		dw .BooHoo

		; beneficial sprites
		dw .Starman
		dw .PSwitch
		dw .SpringBoard
		dw .Bumper
		dw .PBalloon
		dw .Sign
		dw .Key
		dw .SmallBird
		dw .YoshiCoin
		dw .Chest

		; platforms
		dw .GrowingPipe
		dw .CastleBlock
		dw .FloatingSkulls
		dw .BrownGreyPlat
		dw .CheckerPlat
		dw .RockPlat
		dw .OrangePlat
		dw .ScalePlat
		dw .CastlePlat
		dw .CarrotPlat
		dw .TimerPlat
		dw .MovingLedge
		dw .TerrainPlat
		dw .Elevator

		; support sprite parts
		dw .Shield
		dw .Portal

		; sprite support parts
		dw .Football
		dw .ChuckRock
		dw .Rope
		dw .Chainsaw
		dw .Mechanism
		dw .StatueFireball
		dw .LakituCloud
		dw .BossFireball
		dw .SmallFireball
		dw .ReznorFireball
		dw .Fireball32x32
		dw .EnemyFireball
		dw .LotusPollen
		dw .Baseball
		dw .WaterEffects
		dw .LavaEffects
		dw .LightningEffects
		dw .Parachute
		dw .Tray
		dw .PlantStalk
		dw .Wings		; bat wings
		dw .AngelWings
		dw .Hammer
		dw .DinoFire
		dw .SmushedKoopa
		dw .Shell
		dw .FelMagic
		dw .Bone
		dw .SkeletonRubble
		dw .SlimeParticles
		dw .SnoreZ

		; rex support parts
		dw .RexLegs1
		dw .RexLegs2
		dw .RexSmall
		dw .RexHat1
		dw .RexHat2
		dw .RexHat3
		dw .RexHat4
		dw .RexHat5
		dw .RexHat6
		dw .RexHat7
		dw .RexHelmet
		dw .RexBag1
		dw .RexBag2
		dw .RexBag3
		dw .RexBag4
		dw .RexSword

		; player support parts
		dw .LuigiFireball

		; special particle parts
		dw .LeafParticle
		dw .TinyCoin
		dw .SmallNumbers



	.SetList
		; vanilla enemies
		dw .GoombaSlave
		dw .ParaGoomba
		dw .PiranhaPlant	; stalk, fire
		dw .Magikoopa
		dw .Blargg		; lava parts
		dw .VolcanoLotus
		dw .BooBlock
		dw .BigBoo
		dw .SumoBro
		dw .SumoLightning
		dw .BowserStatue
		dw .Chuck
		dw .AmazingHammerBro
		dw .DinoRhino
		dw .DinoTorch
		dw .ShellessKoopa
		dw .KickerKoopa
		dw .DryBonesThrower
		dw .BulletBillCardinals
		dw .ParachuteGoomba
		dw .ParachuteBobomb
		dw .RipVanFish

		; neutral things
		dw .Blocks		; includes wings

		; custom enemies
		dw .Rex
		dw .HammerRex
		dw .FlyingRex
		dw .Conjurex
		dw .MoleWizard
		dw .KompositeKoopa
		dw .CoinGolem


	.SuperSetList
		dw .ParaKoopa
		dw .Koopa
		dw .KoopaBlue
		dw .SuperKoopaKicker
		dw .ParachuteGen
		dw .CarrierBubble
		dw .ExplodingBlock



; -- format --

; header, 6 bytes
;	hhhhhhhh
;	pp--ffff ffffffff
;	-----iii iiiiiiii
;	bbbbbbbb
;	(p = priority)
;	(h = header bits for upload commands, number of bytes to read)
;	(f = ExGFX file number)
;	(i = index to !GFX_status)
;	(b = number of 8x16 blocks needed)
;
; upload commands, 3 bytes per upload
;	ssssssss
;	dddddddd
;	cccccccc
;	(s = source tile offset)
;	(d = destination tile offset)
;	(c = tile count, number of tiles to upload)
;
; secondary commands, variable length, ends with an $FF byte
;	can be used to include other files, mark them for loading, etc


; macro order: GFX, start, blocks, name, prio
; prio: 0, 1, 2 or 3
;	3 is MAX priority, 2 is high priority, 1 and 0 are the same

macro src(GFX, start, blocks, name, prio)
	; upload size
	if <blocks> != 0
		db (..end-..start)+6
	else
		db $00
	endif

	; ExGFX file + priority
	if <prio> = 0
		dw <GFX>
	elseif <prio> = 1
		dw <GFX>|$4000
	elseif <prio> = 2
		dw <GFX>|$8000
	elseif <prio> = 3
		dw <GFX>|$C000
	else
	; if invalid priority, throw an error
		ERROR, INVALID PRIORITY SETTING
	endif
		dw !GFX_<name>_offset
		db <blocks>

	; upload in 2 stripes for uploads < 16, or all at once for uploads >= 16
	if <blocks> = 0
	elseif <blocks> < 16
		..start
		db $00,<start>,<blocks>
		db $10,<start>+$10,<blocks>
		..end
	elseif <blocks>&$0F = 0
		..start
		db $00,<start>,<blocks>*2
		..end
	else
		..start
		db $00,<start>,((<blocks>&$F0)*2)+(<blocks>&$0F)
		db ((<blocks>&$F0)*2)+$10,((<blocks>&$F0)*2)+<start>+$10,<blocks>&$0F
		..end
	endif
		db $FF
endmacro




; same as above, but allows commands
; make sure to put db $FF after!!
macro cmd(GFX, start, blocks, name, prio)
	; upload size
	if <blocks> != 0
		db (..end-..start)+6
	else
		db $00
	endif

	; ExGFX file + priority
	if <prio> = 0
		dw <GFX>
	elseif <prio> = 1
		dw <GFX>|$4000
	elseif <prio> = 2
		dw <GFX>|$8000
	elseif <prio> = 3
		dw <GFX>|$C000
	else
	; if invalid priority, throw an error
		ERROR, INVALID PRIORITY SETTING
	endif
		dw !GFX_<name>_offset
		db <blocks>

	; upload in 2 stripes for uploads < 16, or all at once for uploads >= 16
	if <blocks> = 0
	elseif <blocks> < 16
		..start
		db $00,<start>,<blocks>
		db $10,<start>+$10,<blocks>
		..end
	elseif <blocks>&$0F = 0
		..start
		db $00,<start>,<blocks>*2
		..end
	else
		..start
		db $00,<start>,((<blocks>&$F0)*2)+(<blocks>&$0F)
		db ((<blocks>&$F0)*2)+$10,((<blocks>&$F0)*2)+<start>+$10,<blocks>&$0F
		..end
	endif
endmacro

; marks another file as included in this one
macro include(name, offset)
	db $00
	dw !GFX_<name>_offset
	db <offset>
endmacro

; marks another file to be loaded
macro mark(name)
	db $01
	dw !GFX_<name>_offset
endmacro

; marks a super-dynamic file for loading
macro super(superGFX)
	db $02
	db <superGFX>
endmacro

; marks a certain palette row for use
macro defaultpal(index)
	db $03
	db $<index>&$07
endmacro





;=============;
; -- parts -- ;
;=============;
;===============================================================
.Goomba		%cmd($F03, $00, $08, Goomba, 0)
		%super(!SD_Goomba_offset)
		db $FF
;===============================================================
.Bobomb		%src($F01, $00, $04, Bobomb, 0)
;===============================================================
.Spiny		%src($F0D, $00, $08, Spiny, 0)
;===============================================================
.SpikeTop	%src($F1F, $00, $0C, SpikeTop, 0)
;===============================================================
.BuzzyBeetle	%src($F1D, $00, $0A, BuzzyBeetle, 0)
;===============================================================
.SwooperBat	%src($F22, $00, $06, SwooperBat, 0)
;===============================================================
.MontyMole	%src($F34, $00, $09, MontyMole, 0)
;===============================================================
.MegaMole	%src($F4D, $00, $10, MegaMole, 0)
;===============================================================
.MiniMole	%src($F84, $20, $05, MiniMole, 0)
;===============================================================
.HoppingFlame	%src($F0E, $00, $05, HoppingFlame, 0)
;===============================================================
.Lakitu		%cmd($F10, $00, $0B, Lakitu, 2)
		%mark(Spiny)
		%include(LakituCloud, $08)
		db $FF
;===============================================================
.Wiggler	%src($F12, $00, $09, Wiggler, 0)
;===============================================================
.Thwomp		%src($F15, $00, $08, Thwomp, 0)
;===============================================================
.Thwimp		%src($F16, $00, $01, Thwimp, 0)
;===============================================================
.Podoboo	%cmd($F17, $00, $02, Podoboo, 0)
		%mark(LavaEffects)
		db $FF
;===============================================================
.DiagPodoboo	%src($F1B, $00, $02, DiagPodoboo, 0)
;===============================================================
.BallAndChain	%src($F18, $00, $04, BallAndChain, 0)
;===============================================================
.FallingSpike	%src($F1A, $00, $02, FallingSpike, 0)
;===============================================================
.WoodenSpike	%src($F42, $00, $04, WoodenSpike, 0)
;===============================================================
.Grinder	%src($F40, $00, $04, Grinder, 0)
;===============================================================
.Sparky		%src($F59, $00, $02, Sparky, 0)
;===============================================================
.HotHead	%src($F41, $00, $05, HotHead, 0)
;===============================================================
.MechaKoopa	%src($F52, $00, $10, MechaKoopa, 0)
;===============================================================
.SpikeBall	%src($F2C, $00, $04, SpikeBall, 0)
;===============================================================
.Fuzzy		%src($F2A, $00, $02, Fuzzy, 0)
;===============================================================
.SuperKoopa	%src($F36, $00, $0A, SuperKoopa, 0)
;===============================================================
.Pokey		%src($F35, $00, $04, Pokey, 0)
;===============================================================
.Ninji		%src($F39, $00, $04, Ninji, 0)
;===============================================================
.Thif		%src($F85, $00, $10, Thif, 0)
;===============================================================
.NetKoopa	%src($F14, $00, $0C, NetKoopa, 0)
;===============================================================
.BulletBill	%src($F05, $00, $02, BulletBill, 0)
;===============================================================
.BulletBillDiag	%src($F05, $04, $04, BulletBillDiag, 0)
;===============================================================
.BulletBillUp	%src($F05, $02, $02, BulletBillUp, 0)
;===============================================================
.BanzaiBill	%src($F49, $00, $28, BanzaiBill, 2)
;===============================================================
.BowlingBall	%src($F51, $00, $0A, BowlingBall, 0)
;===============================================================
.FishBone	%src($F19, $00, $05, FishBone, 0)
;===============================================================
.DryBones	%cmd($F54, $00, $08, DryBones, 2)
		%mark(SkeletonRubble)
		db $FF
;===============================================================
.BonyBeetle	%cmd($F55, $00, $08, BonyBeetle, 0)
		%mark(SkeletonRubble)
		db $FF
;===============================================================
.Fish		%src($F45, $00, $08, Fish, 0)
;===============================================================
.BlurpFish	%src($F31, $00, $04, BlurpFish, 0)
;===============================================================
.PorcuPuffer	%src($F32, $00, $0A, PorcuPuffer, 0)
;===============================================================
.Dolphin	%src($F2F, $00, $0E, Dolphin, 0)
;===============================================================
.Urchin		%src($F2D, $00, $08, Urchin, 0)
;===============================================================
.TorpedoTed	%src($F30, $00, $0A, TorpedoTed, 0)
;===============================================================
.Reznor		%cmd($F53, $00, $20, Reznor, 2)
		%mark(ReznorFireball)
		db $FF
;===============================================================
.Birdo		%src($F87, $00, $10, Birdo, 0)
;===============================================================
.Monkey		%src($F89, $00, $26, Monkey, 2)
;===============================================================
.FlamePillar	%src($F8E, $00, $04, FlamePillar, 0)
;===============================================================
.GasBubble	%src($F3C, $00, $10, GasBubble, 0)
;===============================================================
.UltraFuzzy	%src($FA2, $00, $08, UltraFuzzy, 0)
;===============================================================
.TarCreeperHands
		%src($FA4, $00, $1A, TarCreeperHands, 2)
;===============================================================
.Boo		%src($F3D, $00, $0C, Boo, 0)
;===============================================================
.Eerie		%src($F56, $00, $04, Eerie, 0)
;===============================================================
.FishingBoo	%src($F58, $00, $0A, FishingBoo, 0)
;===============================================================
.BooHoo		%src($F8D, $00, $10, BooHoo, 0)
;===============================================================
.Starman	%cmd($F06, $00, $02, Starman, 0)
		%defaultpal(A)
		%defaultpal(B)
		%defaultpal(D)
		db $FF
;===============================================================
.PSwitch	%src($F08, $00, $03, PSwitch, 0)
;===============================================================
.SpringBoard	%src($F07, $00, $02, SpringBoard, 0)
;===============================================================
.Bumper		%src($F88, $02, $02, Bumper, 0)			; slime version
;===============================================================
.PBalloon	%src($F11, $00, $02, PBalloon, 0)
;===============================================================
.Sign		%src($F0B, $00, $02, Sign, 0)
;===============================================================
.Key		%src($F02, $00, $04, Key, 0)
;===============================================================
.SmallBird	%src($F3B, $00, $03, SmallBird, 0)
;===============================================================
.YoshiCoin	%src($F8B, $00, $04, YoshiCoin, 0)
;===============================================================
.Chest		%cmd($FA5, $02, $04, Chest, 0)
		%mark(TinyCoin)
		%defaultpal(A)
		db $FF
;===============================================================
.GrowingPipe	%src($F0F, $00, $04, GrowingPipe, 0)
;===============================================================
.CastleBlock	%src($F1C, $00, $08, CastleBlock, 0)
;===============================================================
.FloatingSkulls	%src($F20, $00, $04, FloatingSkulls, 0)
;===============================================================
.BrownGreyPlat	%src($F24, $00, $06, BrownGreyPlat, 0)
;===============================================================
.CheckerPlat	%src($F25, $00, $04, CheckerPlat, 0)
;===============================================================
.RockPlat	%src($F26, $00, $05, RockPlat, 0)
;===============================================================
.OrangePlat	%src($F27, $00, $06, OrangePlat, 0)
;===============================================================
.ScalePlat	%src($F2B, $00, $02, ScalePlat, 0)
;===============================================================
.CastlePlat	%src($F3F, $00, $06, CastlePlat, 0)
;===============================================================
.CarrotPlat	%src($F4B, $00, $06, CarrotPlat, 0)
;===============================================================
.TimerPlat	%src($F4C, $00, $04, TimerPlat, 0)
;===============================================================
.MovingLedge	%src($F91, $00, $03, MovingLedge, 0)
;===============================================================
.TerrainPlat	%src($F8A, $00, $0E, TerrainPlat, 0)
;===============================================================
.Elevator	%src($F24, $00, $06, Elevator, 0)		; TEMPORARY ELEVATOR GFX
;===============================================================
.Shield		%src($FA3, $00, $04, Shield, 0)
;===============================================================
.Portal		%cmd(!File_Portal, $00, $04, Portal, 0)
		%defaultpal(D)
		db $FF
;===============================================================
.Football	%src($F1E, $00, $02, Football, 0)
;===============================================================
.ChuckRock	%src($F23, $00, $04, ChuckRock, 0)
;===============================================================
.Rope		%cmd($F28, $00, $04, Rope, 0)
		%mark(Mechanism)
		db $FF
;===============================================================
.Chainsaw	%cmd($F29, $00, $04, Chainsaw, 0)
		%mark(Mechanism)
		db $FF
;===============================================================
.Mechanism	%cmd($F69, $00, $06, Mechanism, 0)
		%defaultpal(B)
		db $FF
;===============================================================
.StatueFireball	%src($F43, $00, $02, StatueFireball, 0)
;===============================================================
.LakituCloud	%src($F10, $08, $01, LakituCloud, 0)
;===============================================================
.BossFireball	%src($F50, $00, $08, BossFireball, 0)
;===============================================================
.SmallFireball	%cmd($F5E, $00, $01, SmallFireball, 0)
		%defaultpal(C)
		%super(!SD_Fireball8x8_offset)
		db $FF
;===============================================================
.ReznorFireball	%cmd($F5F, $00, $02, ReznorFireball, 0)
		%defaultpal(C)
		%super(!SD_Fireball16x16_offset)
		db $FF
;===============================================================
.Fireball32x32	%cmd($F00, $00, $08, Fireball32x32, 0)
		%super(!SD_Fireball32x32)
		db $FF
;===============================================================
.EnemyFireball	%cmd($F00, $00, $02, EnemyFireball, 0)
		%super(!SD_EnemyFireball)
		db $FF
;===============================================================
.LotusPollen	%cmd($F60, $00, $01, LotusPollen, 0)
		%defaultpal(C)
		db $FF
;===============================================================
.Baseball	%cmd($F61, $00, $01, Baseball, 0)
		%defaultpal(C)
		%super(!SD_Baseball_offset)
		db $FF
;===============================================================
.WaterEffects	%src($F62, $00, $05, WaterEffects, 0)
;===============================================================
.LavaEffects	%cmd($F63, $00, $02, LavaEffects, 0)
		%defaultpal(C)
		db $FF
;===============================================================
.LightningEffects
		%src(!File_Sprite_BG_1, $06, $06, LightningEffects, 0)
;===============================================================
.Parachute	%cmd($F68, $00, $04, Parachute, 0)
		%defaultpal(B)
		db $FF
;===============================================================
.Tray		%src($F03, $20, $08, Tray, 0)
;===============================================================
.PlantStalk	%cmd($F66, $00, $02, PlantStalk, 0)
		%defaultpal(D)
		db $FF
;===============================================================
.Wings		%cmd($F00, $48, $06, Wings, 0)
		%defaultpal(D)
		db $FF
;===============================================================
.AngelWings	%cmd($F6B, $00, $03, AngelWings, 0)
		%defaultpal(B)
		db $FF
;===============================================================
.Hammer		%cmd($F5D, $00, $02, Hammer, 0)
		%defaultpal(B)
		%super(!SD_Hammer_offset)
		db $FF
;===============================================================
.DinoFire	%cmd($F6A, $00, $10, DinoFire, 0)
		%defaultpal(A)
		%defaultpal(C)
		db $FF
;===============================================================
.SmushedKoopa	%src($F00, $40, $02, SmushedKoopa, 0)
;===============================================================
.Shell		%src($F00, $42, $06, Shell, 0)
;===============================================================
.FelMagic	%cmd($F83, $45, $0B, FelMagic, 0)
		%defaultpal(D)
		db $FF
;===============================================================
.Bone		%cmd($F65, $00, $04, Bone, 0)		; first tile is super-dynamic, second is static and used by dry bones tilemap
		%super(!SD_Bone_offset)
		db $FF
;===============================================================
.SkeletonRubble	%src($F64, $00, $06, SkeletonRubble, 0)
;===============================================================
.SlimeParticles	%src(!File_HappySlime, $4E, $01, SlimeParticles, 0)
;===============================================================
.SnoreZ		%src($F2E, $08, $02, SnoreZ, 0)
;===============================================================
.RexLegs1	%src($F4A, $40, $09, RexLegs1, 0)	; normal
;===============================================================
.RexLegs2	%src($F4A, $07, $09, RexLegs2, 0)	; holding bag
;===============================================================
.RexSmall	%src($F4A, $20, $0B, RexSmall, 0)	; small form
;===============================================================
.RexHat1	%cmd($F4A, $60, $02, RexHat1, 0)	; robin hood cap
		%defaultpal(D)
		db $FF
;===============================================================
.RexHat2	%cmd($F4A, $62, $02, RexHat2, 0)	; bow hat
		%defaultpal(C)
		db $FF
;===============================================================
.RexHat3	%src($F4A, $64, $02, RexHat3, 0)	; sun hat
;===============================================================
.RexHat4	%cmd($F4A, $66, $02, RexHat4, 0)	; fezlike
		%defaultpal(C)
		db $FF
;===============================================================
.RexHat5	%src($F4A, $68, $02, RexHat5, 0)	; bandit bandana
;===============================================================
.RexHat6	%cmd($F4A, $49, $04, RexHat6, 0)	; top hat + mustache
		%defaultpal(C)
		db $FF
;===============================================================
.RexHat7	%src($F4A, $2B, $02, RexHat7, 0)	; bandana
;===============================================================
.RexHelmet	%src($F4A, $02, $02, RexHelmet, 0)	; helmet
;===============================================================
.RexBag1	%cmd($F4A, $2D, $03, RexBag1, 0)	; sack
		%defaultpal(A)
		%mark(TinyCoin)
		db $FF
;===============================================================
.RexBag2	%cmd($F4A, $4D, $03, RexBag2, 0)	; food bag on stick
		%defaultpal(C)
		db $FF
;===============================================================
.RexBag3	%src($F4A, $6A, $03, RexBag3, 0)	; back pack
;===============================================================
.RexBag4	%src($F4A, $6D, $03, RexBag4, 0)	; box held in front
;===============================================================
.RexSword	%src($F4A, $04, $03, RexSword, 0)	; sword + wings
;===============================================================
.LuigiFireball	; no file
;===============================================================
.LeafParticle	%cmd($FA5, $00, $01, LeafParticle, 0)
		%defaultpal(D)
		db $FF
;===============================================================
.TinyCoin	%cmd($FA5, $01, $01, TinyCoin, 0)
		%defaultpal(A)
		db $FF
;===============================================================
.SmallNumbers	%src($FA5, $20, $05, SmallNumbers, 0)
;===============================================================






;============;
; -- sets -- ;
;============;
;===============================================================
.GoombaSlave	%cmd($F03, $08, $06, GoombaSlave, 0)
		%mark(Tray)
		%mark(Goomba)
		db $FF
;===============================================================
.ParaGoomba	%cmd($F03, $00, $04, ParaGoomba, 0)
		%mark(AngelWings)
		db $FF
;===============================================================
.PiranhaPlant	%cmd($F04, $00, $06, PiranhaPlant, 0)
		%mark(PlantStalk)
		%mark(SmallFireball)
		db $FF
;===============================================================
.Magikoopa	%src($F13, $00, $0C, Magikoopa, 0)
;===============================================================
.Blargg		%cmd($F21, $00, $10, Blargg, 0)
		%mark(LavaEffects)
		db $FF
;===============================================================
.VolcanoLotus	%cmd($F37, $00, $04, VolcanoLotus, 0)
		%mark(LotusPollen)
		db $FF
;===============================================================
.BooBlock	%cmd($F0C, $00, $20, BooBlock, 2)
		%include(Boo, $00)
		db $FF
;===============================================================
.BigBoo		%cmd($F3C, $00, $22, BigBoo, 2)
		%include(GasBubble, $00)
		db $FF
;===============================================================
.SumoBro	%cmd($F38, $00, $13, SumoBro, 2)
		%mark(SumoLightning)
		%mark(FlamePillar)
		db $FF
;===============================================================
.SumoLightning	%cmd($F33, $00, $01, SumoLightning, 0)
		%mark(FlamePillar)
		db $FF
;===============================================================
.BowserStatue	%cmd($F44, $00, $07, BowserStatue, 2)
		%mark(StatueFireball)
		db $FF
;===============================================================
.Chuck		%cmd($F47, $00, $38, Chuck, 2)
		%mark(Football)
		%mark(ChuckRock)
		%mark(Baseball)
		%super(!SD_Baseball_offset)
		db $FF
;===============================================================
.AmazingHammerBro
		%cmd($F48, $00, $05, AmazingHammerBro, 2)
		%mark(Hammer)
		db $FF
;===============================================================
.DinoRhino	%cmd($F4E, $00, $1A, DinoRhino, 2)
		%mark(DinoTorch)
		%mark(DinoFire)
		db $FF
;===============================================================
.DinoTorch	%cmd($F4F, $00, $0A, DinoTorch, 0)
		%mark(DinoFire)
		db $FF
;===============================================================
.ShellessKoopa	%cmd($F00, $20, $08, ShellessKoopa, 0)
		%mark(SmushedKoopa)			; load smushed koopa
		db $FF
;===============================================================
.KickerKoopa	%cmd($F00, $28, $08, KickerKoopa, 0)
		%mark(SmushedKoopa)			; load smushed koopa
		%defaultpal(B)
		db $FF
;===============================================================
.DryBonesThrower
		%cmd($F54, $00, $08, DryBones, 2)
		%include(DryBones, $00)
		%mark(SkeletonRubble)
		%mark(Bone)
		db $FF
;===============================================================
.BulletBillCardinals
		%cmd($F05, $00, $04, BulletBill, 0)
		%include(BulletBill, $00)
		%include(BulletBillUp, $02)
		db $FF
;===============================================================
.ParachuteGoomba
		%cmd($F8F, $00, $04, ParachuteGoomba, 2)
		%mark(Goomba)
		%mark(Parachute)
		db $FF
;===============================================================
.ParachuteBobomb
		%cmd($F90, $00, $04, ParachuteBobomb, 2)
		%mark(Bobomb)
		%mark(Parachute)
		db $FF

;===============================================================
.RipVanFish	%cmd($F2E, $00, $08, RipVanFish, 0)
		%mark(SnoreZ)
		db $FF
;===============================================================
.Blocks		%cmd($F09, $00, $02, Blocks, 0)
		%mark(AngelWings)
		db $FF
;===============================================================
.Rex		%cmd($F4A, $00, $02, Rex, 2)
		%mark(RexSmall)		; load small rex form (legs are handled by level scanner)
		db $FF
;===============================================================
.HammerRex	%cmd($F82, $00, $1F, HammerRex, 2)
		%mark(RexSmall)
		%mark(Hammer)
		db $FF
;===============================================================
.FlyingRex	%cmd($FA1, $00, $20, FlyingRex, 2)
		%mark(RexSmall)
		db $FF
;===============================================================
.Conjurex	%cmd($F83, $00, $35, Conjurex, 2)
		%include(FelMagic, $45)
		db $FF
;===============================================================
.MoleWizard	%cmd($F84, $00, $20, MoleWizard, 2)
		%include(MiniMole, $20)
		db $FF
;===============================================================
.KompositeKoopa	%src($F86, $00, $06, KompositeKoopa, 0)
;===============================================================
.CoinGolem	%cmd($F8C, $00, $10, CoinGolem, 2)
		%include(YoshiCoin, $00)
		db $FF
;===============================================================







;==================;
; -- super sets -- ;
;==================;
;===============================================================
.ParaKoopa	%cmd($F00, $00, $0C, ParaKoopa, 2)
		%include(Koopa, $00)
		%include(KoopaBlue, $00)
		%mark(Wings)
		%mark(Shell)
		%mark(ShellessKoopa)
		db $FF
;===============================================================
.Koopa		%cmd($F00, $00, $0C, Koopa, 2)
		%include(KoopaBlue, $00)
		%mark(Shell)
		%mark(ShellessKoopa)
		db $FF
;===============================================================
.KoopaBlue	%cmd($F00, $00, $0C, KoopaBlue, 2)
		%include(Koopa, $00)
		%mark(Shell)
		%mark(KickerKoopa)
		db $FF
;===============================================================
.SuperKoopaKicker
		%cmd($F36, $00, $0A, SuperKoopa, 3)
		%include(SuperKoopa, $00)
		%mark(KickerKoopa)
		db $FF
;===============================================================
.ParachuteGen	%cmd($F8F, $00, $04, ParachuteGoomba, 2)
		%include(ParachuteGoomba, $00)
		%mark(Goomba)
		%mark(Bobomb)
		%mark(Parachute)
		db $FF
;===============================================================
.CarrierBubble	%cmd($F57, $00, $03, CarrierBubble, 2)
		%mark(Bobomb)
		%mark(Goomba)
		%mark(Fish)
		db $FF
;===============================================================
.ExplodingBlock	; TO DO: ADD EXPLODING BLOCK
;===============================================================


macro filemark(name)
	STA.w !FileMark+!GFX_<name>_offset
endmacro


; $00 - acts like 00-3F pointer (lo byte)
; $03 - acts like 00-3F pointer (hi byte)
; $06 - acts like 40-7F pointer (lo byte)		\ we're actually using base $0000 for these because it makes the index calculation simpler
; $09 - acts like 40-7F pointer (hi byte)		/ (shoutout to lunar magic for actually doing something clever)
; $0C - scratch
; $0D - scratch
; $0E - scratch
; $0F - scratch

ReadLevelData:
		PHB
		PHP
		SEP #$20
		LDA.b #$41 : PHA			; push DB
		LDA #$00				;\
		STA.l !FileMark+0			; |
		STA.l !BG_Mark+0			; | set up clears
		STA.l !SD_Mark+0			; |
		STA.l !GFX_status+0			; |
		STA.l !CableUpdateData+0		;/
		REP #$30				; all regs 16-bit
		LDA #$07FE				;\
		LDX.w #!FileMark+0			; | wipe file mark
		LDY.w #!FileMark+1			; |
		MVN !FileMark>>16,!FileMark>>16		;/
		LDA #$01FE				;\
		LDX.w #!BG_Mark+0			; | wipe BG mark
		LDY.w #!BG_Mark+1			; |
		MVN !BG_Mark>>16,!BG_Mark>>16		;/
		LDA #$00FE				;\
		LDX.w #!SD_Mark+0			; | wipe SD mark
		LDY.w #!SD_Mark+1			; |
		MVN !SD_Mark>>16,!SD_Mark>>16		;/
		LDA #$05FE				;\
		LDX.w #!GFX_status+0			; | wipe GFX load status
		LDY.w #!GFX_status+1			; |
		MVN !GFX_status>>16,!GFX_status>>16	;/
		LDA.w #$0005*$0040-2			;\
		LDX.w #!CableUpdateData+0		; | clear cable data
		LDY.w #!CableUpdateData+1		; |
		MVN $40,$40				;/
		PLB					; set DB
		LDA.l !Map16ActsLike : STA $00		;\ acts like pointer 00-3F block (lo byte)
		LDA.l !Map16ActsLike+1 : STA $01	;/
		STA $04					; store bank of hi byte pointer
		LDA.l !Map16ActsLike			;\
		INC A					; | acts like pointer 00-3F block (hi byte)
		STA $03					;/
		LDA.l !Map16ActsLike40 : STA $06	;\
		LDA.l !Map16ActsLike40+1		; | acts like pointer 40-7F block (lo byte)
	;	ORA #$0080				; |
		STA $07					;/
		STA $0A					; store bank of hi byte pointer
		LDA.l !Map16ActsLike40			;\
	;	ORA #$8000				; | acts like pointer 40-7F block (hi byte)
		INC A					; |
		STA $09					;/


		STZ !BG_object_Index			; clear this to start at 0

		SEP #$20
		LDA #$00 : STA.l !BigRAM		; clear brick flag
		LDX #$0000

	.TileLoop
		LDA $40C800,x				;\
		ASL A					; |
		STA $0E					; |
		LDA $C800,x				; | get map16 tile (check if it's block 0x00-0x3F or 0x40-0x7F)
		ROL A					; |
		STA $0F					; |
		BMI ..40				;/

		..checkBG_object
		LDA $0F					;\
		CMP #$03*2 : BNE ..noBG_object		; |
		PHX					; |
		LDA #$00 : XBA				; |
		LDA $0E					; | check for BG object spawn
		LSR A : TAX				; |
		LDA.l .BG_objectList,x			; |
		PLX					; |
		CMP #$00 : BEQ ..noBG_object		; |
		CMP #$FF : BEQ ..noBG_object		;/
		CMP #$01 : BNE ..spawnBG_object		;\
		%filemark(LeafParticle)			; | load leaf particle for bush
		LDA #$01				;/
		..spawnBG_object			;\
		JSR SpawnBG_object			; | spawn BG object
		..noBG_object				;/

		..00					;\
		LDY $0E					; > = 16-bit map16 number * 2
		LDA [$03],y : BEQ +			; | check lo block
		LDA [$00],y : BRA .Page1		; |
	+	LDA [$00],y : BRA .Page0		;/

		..40					;\
		LDY $0E					; > = 16-bit map16 number * 2
		LDA [$09],y : BEQ +			; | check hi block
		LDA [$06],y : BRA .Page1		; |
	+	LDA [$06],y				;/


		.Page0					;\
		CMP #$04 : BCS ..nowater		; |
		LDA #$01 : %filemark(WaterEffects)	; > mark water effects for loading
		..nowater				;/
		CMP #$47 : BNE ..novine			;\
		%filemark(PiranhaPlant)			; | invisible vine block
		..novine				;/
		CMP #$48 : BNE ..nostar			;\
		%filemark(Starman)			; | invisible star block
		..nostar				;/
		JMP .NextTile				; go to next

		.Page1
		CMP #$14 : BCC ..noblock
		CMP #$40 : BEQ ..block
		CMP #$29 : BCS ..noblock
		..block
		XBA
		LDA #$01 : STA.l !PalsetA		; always load palset A if there are blocks
		XBA
		..noblock
		PHA
		CMP #$17 : BEQ ..pal			;\
		CMP #$18 : BEQ ..pal			; | mush/flower blocks load red and green
		CMP #$1F : BEQ ..pal			; |
		CMP #$20 : BEQ ..pal			;/
		CMP #$27 : BEQ ..palG			;\ shell blocks load green
		CMP #$28 : BEQ ..palG			;/
		CMP #$2A : BNE ..notpal			; mush/flower block loads red and green
	..pal	LDA #$01 : STA.l !PalsetC
	..palG	LDA #$01 : STA.l !PalsetD
		..notpal
		PLA
		CMP #$19 : BNE ..notstar		;
		..starman
		LDA #$01 : %filemark(Starman)		; > starman
		JMP .NextTile
		..notstar
		CMP #$1A : BNE ..nomulti
		TXA
		AND #$0F
	-	CMP #$03 : BCC +
		SBC #$03 : BRA -
	+	CMP #$01 : BEQ .NextTile		; 1-up doesn't need to be loaded
		CMP #$00 : BEQ ..starman
		LDA #$01 : %filemark(PiranhaPlant)	; > piranha plant
		BRA .NextTile				;
		..nomulti
		CMP #$1D : BNE ..nopswitch
		LDA #$01 : %filemark(PSwitch)		; > p-switch
		BRA .NextTile
		..nopswitch
		CMP #$1E : BNE ..nobrick
		LDA #$01 : STA.l !BigRAM		; set brick flag for magikoopa
		BRA .NextTile
		..nobrick
		CMP #$21 : BEQ ..starman
		CMP #$22 : BEQ ..starman
		CMP #$25 : BNE ..nomulti2
		TXA
		AND #$03 : BEQ ..key
		CMP #$01 : BEQ ..wings
		CMP #$02 : BEQ ..balloon
	..shell	LDA #$01 : %filemark(Shell)		; > shell
		BRA .NextTile
	..balloon
		LDA #$01 : %filemark(PBalloon)		; > balloon
		BRA .NextTile
	..wings	LDA #$01 : %filemark(Blocks)		; > blocks (including angel wings)
		BRA .NextTile
	..key	LDA #$01 : %filemark(Key)		; > key
		BRA .NextTile
		..nomulti2
		CMP #$27 : BEQ ..shell
		CMP #$28 : BEQ ..shell
	.NextTile
		INX					;\ loop through entire level
		CPX #$3800 : BCS $03 : JMP .TileLoop	;/


	.SpriteData
		LDX #$0000
		LDY #$0001
	.Loop	CPY #$0500 : BCS .Done
		SEP #$20
		LDA [$CE],y				; get byte
		CMP #$FF
		BEQ $03 : - : JMP .Normal		; special code if sprite starts with 0xFF
		LDA [$CE]				;\ commands only apply if new sprite system (LM 3.0+) is used
		AND #$20 : BEQ .Done			;/
		INY					;\ if next byte is positive, this is a command
		LDA [$CE],y : BMI +			;/
		INY : BRA .Loop
	+	CMP #$FE : BNE -			; if the next byte is 0xFE, there are no more sprites
							; otherwise, the sprite simply started with 0xFF and is 1 byte longer as a result
	.Done
		PEI ($CE)
		LDA $D0 : PHA
		LDA.b #!TempSpriteMark : STA $CE
		LDA.b #!TempSpriteMark>>8 : STA $CF
		LDA.b #!TempSpriteMark>>16 : STA $D0


		.P1HeldItem
		LDA.l !HeldItemP1_num
		CMP #$FF : BEQ ..done
		LDA.l !HeldItemP1_num : STA.w !TempSpriteMark+2
		XBA
		LDA.l !HeldItemP1_extra : STA.w !TempSpriteMark+0
		AND #$08 : BNE ..custom
		..vanilla
		LDA #$00
		BRA ..load
		..custom
		LDA.l !HeldItemP1_prop1 : STA.w !TempSpriteMark+3
		LDA.l !HeldItemP1_prop2 : STA.w !TempSpriteMark+4
		LDA #$01
		..load
		XBA
		REP #$20
		STA $0E
		ASL A
		TAX
		LDY #$0000
		PEA ..done-1
		BRA .MarkPalset
		..done

		.P2HeldItem
		SEP #$20
		LDA.l !HeldItemP2_num
		CMP #$FF : BEQ ..done
		LDA.l !HeldItemP2_num : STA.w !TempSpriteMark+2
		XBA
		LDA.l !HeldItemP2_extra : STA.w !TempSpriteMark+0
		AND #$08 : BNE ..custom
		..vanilla
		LDA #$00
		BRA ..load
		..custom
		LDA.l !HeldItemP2_prop1 : STA.w !TempSpriteMark+3
		LDA.l !HeldItemP2_prop2 : STA.w !TempSpriteMark+4
		LDA #$01
		..load
		XBA
		REP #$20
		STA $0E
		ASL A
		TAX
		LDY #$0000
		PEA ..done-1
		BRA .MarkPalset
		..done


		SEP #$20
		LDA.l !FileMark+!GFX_ShellessKoopa_offset : BEQ +		;\
		LDA.l !FileMark+!GFX_Shell_offset : BEQ +			; | if shelless and shell are both loaded, also load koopa
		%filemark(Koopa)						;/
	+	PLA : STA $D0
		REP #$20
		PLA : STA $CE


		PLP
		PLB
		RTL

	.Normal
		PEA .Loop-1
		AND #$08				;\
		LSR #3					; | custom bit acts as bit 8 of number
		XBA					; | (note that extra bits are shifted to 0x0C in level's sprite data)
		INY #2					; |
		LDA [$CE],y				;/
		REP #$20
		STA $0E					; save sprite num for later
		ASL A					; x2
		TAX					; X = index to sprite file correspondance table

		.MarkPalset
		PHX
		LDA $0E
		CMP #$0100 : BCC ..vanilla
		AND #$00FF
		ASL #2 : STA $08
		ASL A : ADC $08
		TAX
		LDA.l SpriteData+5,x : BRA ..shared
		..vanilla
		TAX
		LDA.l VanillaTweakerData_Tweaker5,x
		..shared
		AND #$0007
		INC A
		CMP #$0002 : BCC ..done			; don't mark palette 8-9
		CMP #$0006 : BCS ..done			; don't mark palette E-F
		TAX
		SEP #$20
		LDA #$01 : STA.l !Palset8,x		; mark defaultpal
		..done
		REP #$20
		PLX


		LDA.l SpriteGFXIndex,x : BPL +		;\
		CMP #$8000 : BNE ..cmd			; | 0x8000 = SD search
		JSR SuperDynamicFiles_Search		; | 0xFFFF = load nothing
		BRA ..cmd				; | anything else = mark that index
	+	TAX					; |
		LDA #$0001 : STA.w !FileMark,x		;/
		CPX.w #!GFX_Magikoopa_offset		;\
		BNE ..notmagikoopa			; |
		LDA.l !BigRAM : BEQ ..cmd		; | if the level has bricks, magikoopa will also load koopa and thwimp
		%filemark(Koopa)			; |
		%filemark(Thwimp)			;/
	..cmd	JMP .Command
		..notmagikoopa

		CPX.w #!GFX_SmallBird_offset		;\ check for small bird
		BNE ..notsmallbird			;/
		PHY					;\
		DEY					; |
		SEP #$20				; |
		LDA [$CE],y				; |
		PLY					; |
		LSR #4					; |
		EOR #$0F				; | load default palset based on xpos
		INC #2					; |
		PHX					; |
		TAX					; |
		LDA #$01 : STA.l !Palset8,x		; |
		PLX					; |
		REP #$20				; |
		..notsmallbird				;/

		CPX.w #!GFX_Rex_offset : BNE ..notrex	; check for rex
		PHY					;\
		INY					; |
		LDA [$CE],y				; | load normal legs if bag = 00
		AND #$00FF : BNE +			; |
		LDA #$0001 : %filemark(RexLegs1)	; |
		BRA ++					;/
	+	CMP #$00FF : BNE ..notgoldenbandit	;\
		LDA #$0001				; |
		%filemark(RexLegs2)			; |
		%filemark(YoshiCoin)			; | golden bandit config
		%filemark(RexBag1)			; |
		%filemark(RexHat5)			; |
		BRA +					;/
		..notgoldenbandit			;\
		PHX					; |
		ASL A					; |
		ADC.w #!GFX_RexBag1_offset-2		; |
		TAX					; | load carrying legs if bag != 00
		LDA #$0001				; |
		STA.w !FileMark,x			; |
		%filemark(RexLegs2)			; |
		PLX					;/
	++	INY					;\
		LDA [$CE],y				; |
		AND #$000F : BEQ +			; |
		PHX					; |
		ASL A					; |
		ADC.w #!GFX_RexHat1_offset-2		; | load hat
		TAX					; |
		LDA #$0001 : STA.w !FileMark,x		; |
		PLX					; |
	+	PLY					; |
		..notrex				;/

		CPX.w #!GFX_ExplodingBlock_offset	;\
		BNE ..notexplodingblock			; |
		LDA #$0000 : STA.w !FileMark,x		; > this is not a file, so don't load it
		PHY					; |
		DEY					; | we need to check position of exploding block
		LDA [$CE],y				; |
		AND #$00FF				; |
		PLY					;/
		LSR #4					;\
	-	CMP #$0004 : BCC +			; | get mod 4
		SBC #$0004 : BRA -			;/
	+	CMP #$0000 : BEQ ..fish			;\
		CMP #$0001 : BEQ ..goomb		; | 2 or 3 = koopa
	..koopa	LDA #$0001 : %filemark(Koopa)		; |
		BRA .Command				;/
	..goomb	LDA #$0001 : %filemark(Goomba)		;\ 1 = goomba
		BRA .Command				;/
	..fish	LDA #$0001 : %filemark(Fish)		;\ 0 = fish
		BRA .Command				;/
		..notexplodingblock

		CPX.w #!GFX_Sparky_offset		;\
		BNE ..notsparky				; |
		LDA $792B				; |
		AND #$00FF				; | on sprite tileset 0x02, sparky is replaced by fuzzy
		CMP #$0002 : BNE .Command		; |
		LDA #$0000 : %filemark(Sparky)		; |
		LDA #$0001 : %filemark(Fuzzy)		; |
		..notsparky				;/

	.Command
		INY					; next byte
		LDX $0E					;\
		CPX #$0100				; | custom sprites have 2 extra bytes
		BCC $02 : INY #2			;/
		;JMP .Loop				; loop
		RTS






; index = lo byte of map16 tile num

; key:
; 0x00 - part of a BG object, but not the origin (does nothing but signals that the tile is used)
; 0xFF - unused, does nothing
; any other number - BG object to spawn

	.BG_objectList

	; | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | A | B | C | D | E | F |
	db $01,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 0
	db $02,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 1
	db $00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 2
	db $03,$00,$03,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 3
	db $00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 4
	db $04,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 5
	db $05,$00,$06,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 6
	db $08,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 7
	db $00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 8
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; 9
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; A
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; B
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; C
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; D
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; E
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF	; F






	SpawnBG_object:
		PHY
		PHX
		PHA					; BG object num

		.Main
		XBA					;\
		LDA #$00 : XBA				; | mark BG object for loading
		TAY					; |
		STA.w !BG_Mark,y			;/

		REP #$20				;\
		TXA					; |
		LDX #$0000				; |
	-	CMP.l !LevelHeight : BCC ..thisscreen	; | X = screen num
		SBC.l !LevelHeight			; |
		INX					; |
		BRA -					;/

		..thisscreen
		PHA					; push Ypos (hi byte correct, lo byte should have lo nybble cleared)
		SEP #$30				; all regs 8-bit
		PHX					; push Xpos hi (8-bit)
	;	AND #$0F				;\
		ASL #4					; | push Xpos lo (8-bit)
		PHA					;/
		REP #$30				; all regs 16-bit

		LDX !BG_object_Index
		CPX.w #(!BG_object_Size)*(!BG_object_Count) : BCS ..fail
		..loop
		LDA.w !BG_object_Type,x
		AND #$00FF : BEQ ..thisone
		TXA
		CLC : ADC.w #!BG_object_Size
		TAX
		STX !BG_object_Index
		CPX.w #(!BG_object_Size)*(!BG_object_Count) : BCC ..loop

		..fail
		PLX					;\ pop coords
		PLX					;/
		PLA					; pop A
		PLX					; restore X
		PLY
		RTS

		..thisone
		STZ !BG_object_Timer,x
		PLA : STA !BG_object_X,x
		PLA
		AND #$FFF0 : STA !BG_object_Y,x

		SEP #$20
		PLA : STA !BG_object_Type,x
		CMP #$04 : BEQ .Cable
		PHX
		REP #$20
		AND #$00FF
		ASL A
		TAX
		LDA.l .Size-2,x
		PLX
		STA !BG_object_W,x
		SEP #$20
		PLX					; restore X
		PLY
		RTS




; ...yeah
; search all other slots for cables
; if any existing cable overlaps this spot, this cable can not spawn
		.Cable
		TXY					; Y = index to BG object
		REP #$20
		STY $0E					; $0E = slot we're trying to spawn into
		LDX #$0000
	-	CPX !BG_object_Index : BCS ++
		LDA !BG_object_Type,x			;\
		AND #$00FF				; | has to be cable
		CMP #$0004 : BNE +			;/
		LDA !BG_object_Y,x			;\ has to be on same Y position
		CMP !BG_object_Y,y : BNE +		;/
		LDA !BG_object_W,x			;\
		AND #$00FF				; |
		ASL #3					; | check for X overlap
		CLC : ADC !BG_object_X,x		; |
		CMP !BG_object_X,y : BCS ..fail		;/
	+	TXA
		CLC : ADC.w #!BG_object_Size
		TAX
		CPX.w #(!BG_object_Size)*(!BG_object_Count) : BCC -
		++

		SEP #$20
		PLX : PHX				; X = map16 index (but keep it on the stack)
		STZ $0E

	-	INC $0E
		INX
		TXA
		AND #$0F : BNE +
		REP #$20
		TXA
		SEC : SBC #$0010
		CLC : ADC.l !LevelHeight
		TAX
		SEP #$20
	+	LDA $C800,x
		CMP #$03 : BNE ..cut
		LDA $40C800,x
		CMP #$50 : BEQ -
		..cut
		LDA $0E
		CMP #$03 : BCC ..fail
		CMP #$10+1 : BCS ..fail
		ASL A
		STA !BG_object_W,y
		PLX					; restore X
		PLY : STY $0E				; restore Y + $0E
		RTS
		..fail
		SEP #$20
		TYX
		STZ !BG_object_Type,x
		PLX
		PLY : STY $0E
		RTS


		.Size
		db $04,$02	; bush
		db $04,$04	; window
		db $04,$04	; cannon
		db $10,$04	; cable
		db $04,$03	; pole, facing left
		db $04,$03	; pole, facing right
		db $10,$10	; keyhole (dummy values, actually spawned by sprite)
		db $02,$04	; trash can
		db $04,$04	; key block





BG_objectFiles:


	; which entry on the list each BG object has
	.Index
	db $00			; 00, EMPTY
	db $01			; 01, bush
	db $02			; 02, window
	db $03			; 03, cannon
	db $04			; 04, cable
	db $05			; 05, pole
	db $05			; 06, pole
	db $00			; 07, keyhole
	db $06			; 08, trashcan
	db $00			; 09, key block


	; pointers to upload data
	.List
	dw $0000		; 00, EMPTY
	dw .Bush		; 01
	dw .Window		; 02
	dw .Cannon		; 03
	dw .Cable		; 04
	dw .Pole		; 05
	dw .TrashCan		; 06


; format:
; first word is the (Ex)GFX num
; for each upload:
; - 1 byte tile count
; - 1 byte source tile in file
; exceptions:
; - if tile count is 0x00, end the file
; - if tile count is 0xFF, next byte is the !GFX_status offset of the part that the next tile string belongs to

	.Bush
	dw $020
	db $FF,!GFX_BushFrame1_offset
	db $04,$00
	db $04,$10
	db $FF,!GFX_BushFrame2_offset
	db $04,$04
	db $04,$14
	db $FF,!GFX_BushFrame3_offset
	db $04,$08
	db $04,$18
	db $00

	.Window
	dw $021
	db $FF,!GFX_Window_offset
	db $04,$44
	db $04,$54
	db $04,$64
	db $04,$74
	db $FF,!GFX_WindowBroken_offset
	db $04,$48
	db $04,$58
	db $04,$68
	db $04,$78
	db $00

	.Cannon
	dw $021
	db $FF,!GFX_CannonIdle_offset
	db $04,$00
	db $04,$10
	db $04,$20
	db $04,$30
	db $FF,!GFX_CannonTilt2_offset
	db $04,$04
	db $04,$14
	db $04,$24
	db $04,$34
	db $FF,!GFX_CannonFire1_offset
	db $04,$08
	db $04,$18
	db $04,$28
	db $04,$38
	db $FF,!GFX_CannonFire2_offset
	db $04,$0C
	db $04,$1C
	db $04,$2C
	db $04,$3C
	db $FF,!GFX_CannonTilt1_offset
	db $04,$40
	db $04,$50
	db $04,$60
	db $04,$70
	db $00

	.Cable
	dw $020
	db $FF,!GFX_CableTiles_offset
	db $40,$20
	db $00

	.Pole
	dw $020
	db $FF,!GFX_PoleFrame1_offset
	db $04,$60
	db $04,$70
	db $FF,!GFX_PoleFrame2_offset
	db $04,$64
	db $04,$74
	db $FF,!GFX_PoleFrame3_offset
	db $04,$68
	db $04,$78
	db $00

	.TrashCan
	dw $020
	db $FF,!GFX_TrashCan_offset
	db $02,$0C
	db $02,$1C
	db $02,$0E
	db $02,$1E
	db $02,$6C
	db $02,$7C
	db $00





; how does this work?
; if a sprite's GFX index is 0xFF (dynamic) this table will be searched for a sprite number match
; if one is found, that file is uploaded
; for files that aren't found by the sprite scanner, the match number should be set to 0xFFFF since that will never match

; process:
; - find target RAM
; - chunking:
;	- SA-1 outputs 1 chunk into !GFX_buffer
;	- chunk is moved to target RAM (through SNES DMA or SA-1 CPU)
;	- loop until all chunks are loaded
; - command processing:
;	- copy chunk that should be processed into !ImageCache
;	- execute GFX transformation code
;	- copy output image into target RAM
;	- loop until all chunks are processed
; - format conversion:
;	- copy a chunk into !ImageCache
;	- convert chunk to CHR format
;	- copy output image into target RAM (overwriting the planar version)
;	- loop until all chunks are converted
;



; !BigRAM:
; 00: bytes used in $40A000-$40C7FF (10 KB)
; 02: bytes used in $7EC800-$7EFFFF (14 KB)
; 04: bytes used in $7FC800-$7FFFFF (14 KB)
; 06: bytes used in $7F0000-$7F7FFF (32 KB)
; 08: bytes used in $410000-$417FFF (32 KB)
; 0A: bytes used in $7E2000-$7EACFF (35 KB)

	SuperDynamicFiles:
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDX.b #.RAMaddress-.RAMsize-1			;\
	-	STZ !BigRAM,x					; | mark all RAM areas as free
		DEX : BPL -					;/

		LDX #$00
	.Next	LDA !SD_Mark,x : BNE .Load
		INX
		BNE .Next
		PLP
		PLB
		RTS

	.Return
		PLX
		PLP
		PLB
		RTS

	.Load	
		REP #$20
		TXA
		ASL A
		TAY
		LDA .List,y : STA $00
		LDY #$02
		PHX
		LDX.b #.RAMaddress-.RAMsize-2

	-	LDA .RAMsize,x					;\
		SEC : SBC !BigRAM,x				; |
		BEQ .nextM					; |
		BCS .thisM					; | look for a good spot in memory
	.nextM	DEX #2 : BPL -					; |
		BRA .Return					; |
	.thisM	CMP ($00),y : BCC .nextM			;/
		LDA !BigRAM,x					;\
		CLC : ADC .RAMaddress,x				; | address to start uploading to (assume lo byte is always 0)
		STA !BigRAM+$10					;/
		STA !BigRAM+$74					; > store for later to use with linear -> planar conversion
		LDA ($00),y					;\
		CLC : ADC !BigRAM,x				; | mark memory as used
		STA !BigRAM,x					;/

		LDA !BigRAM+$11					;\
		AND #$00FF : STA $02				; > (note that this clear of $03 is necessary)
		LDA .RAMprop,x					; |
		LDY #$00					; |
		AND #$00FF					; |
		CMP #$007E : BEQ +				; |
		LDY #$01					; | ppppppbb
		CMP #$007F : BEQ +				; |
		LDY #$02					; |
		CMP #$0040 : BEQ +				; |
		LDY #$03					; |
	+	TYA						; |
		ORA $02						; |
		STA !BigRAM+$7E					;/

		STX $02						; RAM location index (SA-1 will need this)
		LDA !BigRAM+$10 : STA !BigRAM+$7A		; back this up

		LDA !BigRAM+$00 : PHA
		LDA !BigRAM+$02 : PHA
		LDA !BigRAM+$04 : PHA
		LDA !BigRAM+$06 : PHA
		LDA !BigRAM+$08 : PHA
		LDA !BigRAM+$0A : PHA

		REP #$30					;\
		PEI ($00)					; |
		PEI ($02)					; |
		LDY #$0004					; |
		LDA ($00),y					; | decompress file
		LDY.w #!DecompBuffer : STY $00			; | (only SNES can call this so it can't be done later)
		LDY.w #!DecompBuffer>>8 : STY $01		; |
		JSL !DecompressFile				; |
		PLA : STA $02					; |
		PLA : STA $00					;/
		LDA.w #.SA1 : STA $3180				;\
		LDA.w #.SA1>>8 : STA $3181			; | call SA-1
		SEP #$30					; |
		JSR $1E80					;/
		LDY #$06					;\
		LDA ($00),y : TAX				; | store ppppppbb
		LDA !BigRAM+$7E : STA !SD_status,x		;/

		REP #$20
		PLA : STA !BigRAM+$0A
		PLA : STA !BigRAM+$08
		PLA : STA !BigRAM+$06
		PLA : STA !BigRAM+$04
		PLA : STA !BigRAM+$02
		PLA : STA !BigRAM+$00
		PLX
		INX						; next index
		SEP #$20
		JMP .Next



	.SA1
		PHB : PHK : PLB
		PHP
		SEP #$20
		STZ $223F					; 4 bpp mode
		STZ $2250					; prepare multiplication

	; read header
		REP #$30					; all regs 16-bit
		LDY #$0007					;\
		LDA ($00),y					; |
		AND #$FF00					; |
		XBA : STA $2251					; |
		LDA ($00),y					; |
		AND #$00FF					; | byte count of chunk
		STA $2253					; |
		STA $08						; > store chunk width in $08
		NOP						; |
		LDA $2306					;/
		STA $04						; get byte count
		STZ !BigRAM+$7C					; reset number of chunks in memory

	; handle commands
		LDA !BigRAM+$74					;\
		STA $0A						; |
		STA $0D						; |
		SEP #$20					; | $0A = 24-bit read pointer
		LDX $02						; | $0D = 24-bit write pointer
		LDA .RAMprop,x					; |
		STA $0C						; |
		STA $0F						;/
		PEI ($02)					; preserve $02
		LDY #$0009					; Y = index to first command
		..nextcommand					;\
		REP #$20					; | read and prepare command
		LDA $0D : STA !BigRAM+$6C			; |
		SEP #$20					;/
		LDA ($00),y : BEQ ..LoadChunk			; 00 = load chunk
		CMP #$01 : BEQ ..RJump				; 01 = rotate
		CMP #$02 : BEQ ..SJump				; 02 = scale
		..commandsdone					; all other values just end
		PLY : STY $02					; restore $02

	; convert linear -> planar
		REP #$30					; all regs 16-bit
		LDX $02						;\
		LDA .RAMprop-1,x				; |
		AND #$FF00					; |
		STA $0C-1					; | RAM address
		STA $0F-1					; | (read = write)
		LDA !BigRAM+$7A					; |
		STA $0A						; |
		STA $0D						;/
		LDA !BigRAM+$7C : STA $06			; number of chunks
		..loop
		JSR ChunkToCache				; upload chunk to cache
		LDA.w #!V_cache : STA !BigRAM+$00		; image to convert
		LDA $08						;\
		ASL A						; | width of image
		STA !BigRAM+$02					;/
		LDA #$0004 : JSL TransformGFX			; convert to planar
		JSR DownloadChunk				; put converted chunk back in RAM
		DEC $06 : BEQ ..done				;\
		LDA $0A						; |
		CLC : ADC $04					; | loop through all chunks
		STA $0A						; |
		STA $0D						; |
		BRA ..loop					;/
		..done
		PLP
		PLB
		RTL




; 00 - 16-bit pointer to file
; 02 - RAM location index (used for various purposes during .Commands)
; 04 - byte count of chunk (later holds bbpppppp)
; 06 - loop counter for chunk loader
; 08 - chunk width
; 0A - 24-bit pointer to source GFX (read)
; 0D - 24-bit pointer to source GFX (write)
; !BigRAM	- keeps track of memory areas for SD graphics
; !BigRAM+$10	- upload address
; !BigRAM+$12	- UNUSED
; !BigRAM+$14	- UNUSED
; !BigRAM+$6C	- copy of $0D from start of operation
; !BigRAM+$6E	- total number of iterations
; !BigRAM+$70	- total copies for current iteration
; !BigRAM+$72	- base number of chunks in file
; !BigRAM+$74	- original upload address
; !BigRAM+$76	- current chunk for transformations
; !BigRAM+$78	- iterations left (used with transformations)
; !BigRAM+$7A	- base upload address
; !BigRAM+$7C	- total chunks
; !BigRAM+$7E	- ppppppbb




; NOTE: only SNES can call !DecompressFile, so it can't be done here


		..RJump
		JMP ..Rotate

		..SJump
		JMP ..Scale


	..LoadChunk
		REP #$20
		INY

		LDA.w #!DecompBuffer : STA $0A
		LDA.w #!DecompBuffer>>8 : STA $0B

		LDA ($00)				;\ check format
		CMP $08 : BEQ +				;/


	; WIDE FORMAT
		LDX #$0000				;\
	-	LSR A					; |
		INX					; | $02 = W/w
		CMP $08 : BNE -				; |
		LDA ...data-1,x				; |
		AND #$00FF : STA $02			;/


		LDX #$0000				;\
		LDA ($00),y				; |
		AND #$00FF				; | A = chunk num mod W/w
	-	CMP $02 : BCC ++			; | X = which chunk row is being read from
		SBC $02					; |
		INX : BRA -				; |
		++					;/

		STA $2251				;\ calc h offset
		LDA $08 : STA $2253			;/
		NOP
		LDA.w #!DecompBuffer			;\
		CLC : ADC $2306				; | update pointer to include h offset
		STA $0A					;/

		STX $2251				;\
		LDA $04 : STA $2253			; |
		STA $06					; > $06 = loop counter
		BRA $00					; | calc v offset (chunk row * W/w * chunk size)
		LDA $2306 : STA $2251			; |
		LDA $02 : STA $2253			;/
		BRA ++

		...data
		db $02,$04,$08,$10,$20,$40,$80


	; SLIM FORMAT
	+	LDA ($00),y
		AND #$00FF
		STA $2251
		LDA $04 : STA $2253
		STA $06					; $06 = loop counter

	++	INY
		LDA $08 : STA $02			; loop counter for row
		LDX #$0000				; index to cache
		PHY
		LDY $2306				; index to source GFX



	-	LDA [$0A],y : STA !GFX_buffer,x		;\
		INX #2					; | copy row
		INY #2					;/
		DEC $06 : DEC $06 : BEQ +		; > check for end of chunk
		DEC $02 : DEC $02 : BNE -		; > check for end of row
		TYA					;\
		SEC : SBC $08				; |
		CLC : ADC ($00)				; | get index to next row by adding width encoding
		TAY					; |
		LDA $08 : STA $02			; > reset row loop counter
		BRA -					;/
	; formatted chunk is now stored in cache
	+	PLY
		JSR DownloadChunk
		LDA $0D
		CLC : ADC $04
		STA $0D
		INC !BigRAM+$7C				; +1 total chunk
		JMP ..nextcommand


	..Rotate
		REP #$20				;\
		LDA $04 : STA $2251			; |
		INY					; |
		LDA ($00),y				; | get chunk address
		AND #$00FF				; |
		STA $2253				; |
		STA !BigRAM+$76				;/

		INY					;\
		LDA ($00),y				; |
		AND #$00FF				; | iterations
		STA !BigRAM+$78				; |
		STA !BigRAM+$6E				;/

	--	LDA $0F-1 : STA $0C-1			; read bank
		LDA !BigRAM+$7A				;\
		CLC : ADC $2306				; | get chunk
		STA $0A					; |
		JSR ChunkToCache			;/

		INY					;\
		LDA ($00),y				; |
		AND #$00FF				; | angle
		STA !BigRAM+$0E				; |
		STA $02					;/
		INY					;\
		LDA ($00),y				; | copies
		AND #$00FF				; |
		STA $06					;/
		STA !BigRAM+$70				; > total copies
		INY					; adjust index

		LDA !BigRAM+$78 : BEQ ..RotateDone	; check iterations
		DEC !BigRAM+$78				; start a new iteration

		LDA !BigRAM+$70				;\
		CLC : ADC !BigRAM+$7C			; | add copies to number of chunks
		STA !BigRAM+$7C				;/

	-	LDA $06 : BNE +				; check copies
		DEY #3					;\
		INC !BigRAM+$76				; |
		LDA !BigRAM+$76 : STA $2251		; | go to next iteration
		LDA $04 : STA $2253			; |
		BRA --					;/

	+	DEC $06					; start a new copy
		LDA.w #!V_cache : STA !BigRAM+$00	; image source
		LDA $08					;\
		ASL A					; | width
		STA !BigRAM+$02				;/
		LDA #$0020 : JSL TransformGFX		; rotate with fixed size


		; LDA !BigRAM+$70
		; SEC : SBC $06
		; STA $2251				; copy (current)
		; LDA !BigRAM+$72 : STA $2253		; x base number of chunks (in file)
		; LDA !BigRAM+$76				; + chunk (current)
		; CLC : ADC $2306
		; STA $2251
		; LDA $04 : STA $2253			; () x chunk size
		; NOP : BRA $00
		; LDA $2306
		; CLC : ADC !BigRAM+$74			; + base upload address
		; STA $0D


		JSR DownloadChunk			; get chunk from output buffer
		LDA $0D					;\
		CLC : ADC $04				; | adjust address
		STA $0D					;/
		LDA !BigRAM+$0E				;\
		CLC : ADC $02				; | adjust angle
		STA !BigRAM+$0E				;/
		BRA -					; next copy


	..RotateDone
		; LDA !BigRAM+$70 : STA $2251
		; LDA !BigRAM+$6E : STA $2253
		; NOP : BRA $00
		; LDA $2306 : STA $2251
		; LDA $04 : STA $2253
		; LDA !BigRAM+$6C
		; NOP
		; CLC : ADC $2306
		; STA $0D
		JMP ..nextcommand


	..Scale
		REP #$20				;\
		LDA $04 : STA $2251			; |
		INY					; |
		LDA ($00),y				; | get chunk address
		AND #$00FF				; |
		STA $2253				; |
		STA !BigRAM+$76				;/

		INY					;\
		LDA ($00),y				; | iterations
		AND #$00FF				; |
		STA !BigRAM+$78				;/

	-	LDA $0F-1 : STA $0C-1			; read bank
		LDA !BigRAM+$7A				;\
		CLC : ADC $2306				; | get chunk
		STA $0A					; |
		JSR ChunkToCache			;/

		INY					;\
		LDA ($00),y				; | x scaling
		AND #$00FF				; |
		STA !BigRAM+$06				;/
		INY					;\
		LDA ($00),y				; | y scaling
		AND #$00FF				; |
		STA !BigRAM+$08				;/
		INY					; adjust index
		LDA $08					;\
		STA !BigRAM+$0A				; | scaling center (remember that w is already halved here)
		STA !BigRAM+$0C				;/

		LDA !BigRAM+$78 : BEQ ..ScaleDone	; check iterations
		DEC !BigRAM+$78				; start a new iteration

	+	LDA.w #!V_cache : STA !BigRAM+$00	; image source
		LDA $08					;\
		ASL A					; | width
		STA !BigRAM+$02				; | + height
		STA !BigRAM+$04				;/
		LDA #$0080 : JSL TransformGFX		; scale
		JSR DownloadScaledChunk			; get chunk from output buffer
		LDA $0D					;\
		CLC : ADC $04				; | adjust address
		STA $0D					;/
		DEY #3					;\
		INC !BigRAM+$7C				; |
		INC !BigRAM+$76				; | go to next iteration
		LDA !BigRAM+$76 : STA $2251		; |
		LDA $04 : STA $2253			; |
		BRA -					;/

	..ScaleDone
		JMP ..nextcommand




	.RAMsize
		dw $3400
		dw $2800
		dw $3800
		dw $8000
		dw $8000
		dw $8D00	; 8D00 should be the size... ($2000-$ACFF)
	.RAMaddress
		dw $C800
		dw $A000
		dw $C800
		dw $0000
		dw $0000
		dw $2000
	.RAMprop		; lo byte = bank, hi byte = DMA allowed (0 = no, 1 = yes)
		dw $017E
		dw $0040
		dw $017F
		dw $017F
		dw $0041
		dw $017E



		.Lookup
		dw $10D : db !SD_PlantHead_offset		; plant head
		dw $110 : db !SD_Fireball32x32_offset		; kingking, fireball 32x32
		dw $110 : db !SD_EnemyFireball_offset		; kingking, enemy fireball 16x16
		..End


		.List
		dw .Hammer		; 00
		dw .PlantHead		; 01
		dw .Bone		; 02
		dw .Fireball8x8		; 03
		dw .Fireball16x16	; 04
		dw .Goomba		; 05
		dw .LuigiFireball	; 06
		dw .Baseball		; 07
		dw .KadaalSwim		; 08
		dw .Fireball32x32	; 09
		dw .EnemyFireball	; 0A
		..End


	.Search
		PHX
		PHP
		REP #$20
		TXA
		LSR A
		LDX #$0000
		..loop
		CMP.l .Lookup+0,x : BNE ..next
		..mark
		PHA
		PHX
		LDA.l .Lookup+2,x
		AND #$00FF
		TAX
		SEP #$20
		LDA #$01 : STA.w !SD_Mark,x
		REP #$20
		PLX
		PLA
		..next
		INX #3
		CPX.w #.Lookup_End-.Lookup : BCC ..loop
		..return
		PLP
		PLX
		RTS


; big fat note:
; chunk width has to be halved in the file entry due to packed format
; for example, a 16px wide chunk is marked as 8
; note: file size MUST be rounded up to closest KB ($400 B)


; commands:
;	00 = load chunk
;	01 = rotate
;	02 = scale
;	FF = end file, convert to SNES format



macro size(size)
	dw $0000|(((<size>)+$3FF)&$FC00)	; for some reason asar sets high byte to 0xFF without the $0000|
endmacro

macro loadchunk(chunk)
	db $00
	db <chunk>
endmacro

macro rotate(chunk, iterations, copies, angle)
	db $01
	db <chunk>
	db <iterations>
	db <angle>
	db <copies>
endmacro

macro scale(chunk, iterations, x, y)
	db $02
	db <chunk>
	db <iterations>
	db <x>
	db <y>
endmacro



.Hammer
..header
dw $0008				; width encoding
%size($80*16)				; size: 16 16x16 chunks
dw $E00					; source ExGFX
db !SD_Hammer_offset			; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.PlantHead
..header
dw $0040				; width encoding
%size($200*64)				; size: 64 32x32 chunks
dw $E01					; source ExGFX
db !SD_PlantHead_offset			; SD GFX status index
db $10,$20				; chunk dimensions (32x32)
..commands
%loadchunk($00)				; load chunk 0 (mouth closed)
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
%loadchunk($01)				; load chunk 1 (mouth open)
%rotate($10, 1, 15, $20)		; rotate: chunk 16, iterations 1, copies 15, angle $20
%scale($00, 16, $E0, $E0)		; scale: chunk 0, iterations 16, x 82%, y 82%
%scale($00, 16, $C0, $C0)		; scale: chunk 0, iterations 16, x 75%, y 75%
..end
db $FF					; end file

.Bone
..header
dw $0008				; width encoding
%size($80*16)				; size: 16 16x16 chunks
dw $E02					; source ExGFX
db !SD_Bone_offset			; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.Fireball8x8
..header
dw $0004				; width encoding
%size($20*16)				; size: 16 8x8 chunks
dw $E03					; source ExGFX
db !SD_Fireball8x8_offset		; SD GFX status index
db $04,$08				; chunk dimensions (8x8)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.Fireball16x16
..header
dw $0008				; width encoding
%size($80*16)				; size: 16 16x16 chunks
dw $E04					; source ExGFX
db !SD_Fireball16x16_offset		; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.Goomba
..header
dw $0008				; width encoding
%size($80*16)				; size: 16 16x16 chunks
dw $E05					; source ExGFX
db !SD_Goomba_offset			; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.LuigiFireball
..header
dw $0004				; width encoding
%size($20*16)				; size: 16 8x8 chunks
dw $E06					; source ExGFX
db !SD_LuigiFireball_offset		; SD GFX status index
db $04,$08				; chunk dimensions (8x8)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.Baseball
..header
dw $0004				; width encoding
%size($20*16)				; size: 16 8x8 chunks
dw $E07					; source ExGFX
db !SD_Baseball_offset			; SD GFX status index
db $04,$08				; chunk dimensions (8x8)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.KadaalSwim
..header
dw $0040				; width encoding
%size($80*20)				; size: 20 16x16 chunks
dw $E08					; source ExGFX
db !SD_KadaalLinear_offset		; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%loadchunk($01)				; load chunk 1
%loadchunk($02)				; load chunk 2
%loadchunk($03)				; load chunk 3
%rotate($00, 4, 1, $10)			; rotate: chunk 0, iterations 4 (chunks 0-3), copies 1, angle $10
%rotate($00, 4, 1, $20)			; rotate: chunk 0, iterations 4 (chunks 0-3), copies 1, angle $20
%rotate($00, 4, 1, $30)			; rotate: chunk 0, iterations 4 (chunks 0-3), copies 1, angle $30
%rotate($00, 4, 1, $40)			; rotate: chunk 0, iterations 4 (chunks 0-3), copies 1, angle $40
..end
db $FF					; end file

.Fireball32x32
..header
dw $0010				; width encoding
%size($200*16)				; size: 16 32x32 chunks
dw $E09					; source ExGFX
db !SD_Fireball32x32_offset		; SD GFX status index
db $10,$20				; chunk dimensions (32x32)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file

.EnemyFireball
..header
dw $0010				; width encoding
%size($80*16)				; size: 16 16x16 chunks
dw $E0A					; source ExGFX
db !SD_EnemyFireball_offset		; SD GFX status index
db $08,$10				; chunk dimensions (16x16)
..commands
%loadchunk($00)				; load chunk 0
%rotate($00, 1, 15, $20)		; rotate: chunk 0, iterations 1, copies 15, angle $20
..end
db $FF					; end file





; chunk copier routines below
; should be called by SA-1
; input:
;	$04 = byte count of chunk
;	$0A = 24-bit pointer to target RAM (read)
;	$0D = 24-bit pointer to target RAM (write)

	ChunkToCache:
		PHY
		LDA $0C-1				;\ 7E/7F = DMA
		CMP #$7E00 : BCC .CPU			;/ 40/41 = CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0A : STA $2181			; |
		LDX $0C : STX $2183			; |
		LDA #$8080 : STA $4300			; | DMA chunk
		LDA.w #!ImageCache : STA $4302		; |
		LDX.b #!ImageCache>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		PHB					;\
		SEP #$20				; | bank wrapper start
		LDA $0C : PHA : PLB			; |
		REP #$20				;/
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA ($0A),y : STA.l !ImageCache,x	; |
		DEX #2					; |
		TXY : BPL -				;/
		PLB					; bank wrapper end
		PLY					; restore command index
		RTS					; return


	DownloadChunk:
		PHY
		LDA $0F-1				;\ 7E/7F = DMA
		CMP #$7E00 : BCC .CPU			;/ 40/41 = CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0D : STA $2181			; |
		LDX $0F : STX $2183			; |
		LDA #$8000 : STA $4300			; | DMA chunk
		LDA.w #!GFX_buffer : STA $4302		; |
		LDX.b #!GFX_buffer>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		PHB					;\
		SEP #$20				; | bank wrapper start
		LDA $0F : PHA : PLB			; |
		REP #$20				;/
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA.l !GFX_buffer,x : STA ($0D),y	; |
		DEX #2					; |
		TXY : BPL -				;/
		PLB					; bank wrapper end
		PLY					; restore command index
		RTS					; return


	DownloadScaledChunk:
		PHY
		LDA $0F-1				;\ 7E/7F = DMA
		CMP #$7E00 : BCC .CPU			;/ 40/41 = CPU

	.DMA
		LDA.w #..SNES : STA $0183		;\
		PHP					; |
		SEP #$20				; |
		LDA.b #..SNES>>16 : STA $0185		; |
		LDA #$D0 : STA $2209			; | request SNES DMA, then return
	-	LDA $018A : BEQ -			; |
		STZ $018A				; |
		PLP					; |
		PLY					; |
		RTS					;/

		..SNES					; bank is already K
		PHP					;\
		REP #$20				; |
		SEP #$10				; |
		LDA $0D : STA $2181			; |
		LDX $0F : STX $2183			; |
		LDA #$8000 : STA $4300			; | DMA chunk
		LDA.w #!GFX_buffer+$800 : STA $4302	; |
		LDX.b #!GFX_buffer>>16 : STX $4304	; |
		LDA $04 : STA $4305			; |
		LDX #$01 : STX $420B			; |
		PLP					; |
		RTL					;/

	.CPU
		PHB					;\
		SEP #$20				; | bank wrapper start
		LDA $0F : PHA : PLB			; |
		REP #$20				;/
		LDX $04					;\
		DEX #2					; |
		TXY					; | transfer chunk
	-	LDA.l !GFX_buffer+$800,x : STA ($0D),y	; |
		DEX #2					; |
		TXY : BPL -				;/
		PLB					; bank wrapper end
		PLY					; restore command index
		RTS					; return





