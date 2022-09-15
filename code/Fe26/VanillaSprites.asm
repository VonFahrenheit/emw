

	HandleVanilla:

		.Main
		PHB : PHK : PLB
		REP #$30
		LDA $3200,x
		AND #$00FF
		CMP #$00C9 : BCS .InvalidNum
		ASL A : TAY
		LDA.w VanillaMainList,y : BRA .Call

		.Init
		PHB : PHK : PLB
		REP #$30
		LDA $3200,x
		AND #$00FF
		CMP #$00C9 : BCS .InvalidNum
		ASL A : TAY
		LDA.w VanillaInitList,y

		.Call
		STA $00
		SEP #$30
		BEQ .InvalidNum
		LDA #$01 : PHA : PLB			; B = $01
		PEA .Return-1 : JMP ($3000)		; faux JSR call

		.InvalidNum
		SEP #$30
		STZ $3230,x

		.Return
		PLB
		RTL


VanillaInitList:
	%ListVanillaInit(Koopa)			; 00
	%ListVanillaInit(Koopa)			; 01
	%ListVanillaInit(Koopa)			; 02
	%ListVanillaInit(Koopa)			; 03
	%ListVanillaInit(Koopa)			; 04
	%ListVanillaInit(Koopa)			; 05
	%ListVanillaInit(Koopa)			; 06
	%ListVanillaInit(Koopa)			; 07
	%ListVanillaInit(Koopa)			; 08
	%ListVanillaInit(Koopa)			; 09
	%ListVanillaInit(Koopa)			; 0A
	%ListVanillaInit(Koopa)			; 0B
	%ListVanillaInit(Koopa)			; 0C
	%ListVanillaInit(BobOmb)		; 0D
	%ListVanillaInit(Keyhole)		; 0E
	%ListVanillaInit(Goomba)		; 0F
	%ListVanillaInit(Paragoomba)		; 10
	%ListVanillaInit(BuzzyBeetle)		; 11
	dw $0000				; 12
	%ListVanillaInit(Spiny)			; 13
	%ListVanillaInit(Spiny)			; 14
	%ListVanillaInit(Fish)			; 15
	%ListVanillaInit(Fish)			; 16
	%ListVanillaInit(Fish)			; 17
	%ListVanillaInit(Fish)			; 18
	%ListVanillaInit(DisplayTextCommand)	; 19
	%ListVanillaInit(PiranhaPlant)		; 1A
	%ListVanillaInit(ChuckProjectile)	; 1B
	%ListVanillaInit(BulletBill)		; 1C
	%ListVanillaInit(HoppingFlame)		; 1D
	%ListVanillaInit(Lakitu)		; 1E
	%ListVanillaInit(Magikoopa)		; 1F
	%ListVanillaInit(MagikoopaMagic)	; 20
	%ListVanillaInit(MovingCoin)		; 21
	%ListVanillaInit(NetKoopa)		; 22
	%ListVanillaInit(NetKoopa)		; 23
	%ListVanillaInit(NetKoopa)		; 24
	%ListVanillaInit(NetKoopa)		; 25
	%ListVanillaInit(Thwomp)		; 26
	%ListVanillaInit(Thwimp)		; 27
	%ListVanillaInit(BigBoo)		; 28
	dw $0000				; 29
	%ListVanillaInit(PiranhaPlant)		; 2A
	%ListVanillaInit(SumoBroLightning)	; 2B
	dw $0000				; 2C
	dw $0000				; 2D
	%ListVanillaInit(SpikeTop)		; 2E
	%ListVanillaInit(SpringBoard)		; 2F
	%ListVanillaInit(DryBones)		; 30
	%ListVanillaInit(BonyBeetle)		; 31
	%ListVanillaInit(DryBones)		; 32
	%ListVanillaInit(LavaFireball)		; 33
	%ListVanillaInit(BossFireball)		; 34
	dw $0000				; 35
	dw $0000				; 36
	%ListVanillaInit(Boo)			; 37
	%ListVanillaInit(Eerie)			; 38
	%ListVanillaInit(Eerie)			; 39
	%ListVanillaInit(Urchin)		; 3A
	%ListVanillaInit(Urchin)		; 3B
	%ListVanillaInit(Urchin)		; 3C
	%ListVanillaInit(RipVanFish)		; 3D
	%ListVanillaInit(POW)			; 3E
	%ListVanillaInit(Parachute)		; 3F
	%ListVanillaInit(Parachute)		; 40
	%ListVanillaInit(Dolphin)		; 41
	%ListVanillaInit(Dolphin)		; 42
	%ListVanillaInit(Dolphin)		; 43
	%ListVanillaInit(TorpedoTed)		; 44
	%ListVanillaInit(DirectionalCoins)	; 45
	%ListVanillaInit(Chuck)			; 46
	%ListVanillaInit(Fish)			; 47
	%ListVanillaInit(ChuckProjectile)	; 48
	%ListVanillaInit(GrowingShrinkingPipe)	; 49
	dw $0000				; 4A
	%ListVanillaInit(Lakitu)		; 4B
	%ListVanillaInit(ExplodingBlock)	; 4C
	%ListVanillaInit(MontyMole)		; 4D
	%ListVanillaInit(MontyMole)		; 4E
	%ListVanillaInit(JumpingPiranhaPlant)	; 4F
	%ListVanillaInit(JumpingPiranhaPlant)	; 50
	%ListVanillaInit(Ninji)			; 51
	%ListVanillaInit(MovingLedge)		; 52
	%ListVanillaInit(ThrowBlock)		; 53
	dw $0000				; 54
	%ListVanillaInit(Platform)		; 55
	%ListVanillaInit(Platform)		; 56
	%ListVanillaInit(Platform)		; 57
	%ListVanillaInit(Platform)		; 58
	%ListVanillaInit(BrickBridge)		; 59
	%ListVanillaInit(BrickBridge)		; 5A
	%ListVanillaInit(Platform)		; 5B
	%ListVanillaInit(Platform)		; 5C
	%ListVanillaInit(Platform)		; 5D
	%ListVanillaInit(Platform)		; 5E
	%ListVanillaInit(BrownPlatformOnChain)	; 5F
	dw $0000				; 60
	%ListVanillaInit(FloatingSkull)		; 61
	%ListVanillaInit(LineGuidedPlatform)	; 62
	%ListVanillaInit(LineGuidedPlatform)	; 63
	%ListVanillaInit(RopeMechanism)		; 64
	%ListVanillaInit(ChainsawMechanism)	; 65
	%ListVanillaInit(ChainsawMechanism)	; 66
	%ListVanillaInit(LineGuidedHitbox)	; 67
	%ListVanillaInit(LineGuidedHitbox)	; 68
	dw $0000				; 69
	dw $0000				; 6A
	dw $0000				; 6B
	dw $0000				; 6C
	dw $0000				; 6D
	%ListVanillaInit(DinoRhino)		; 6E
	%ListVanillaInit(DinoRhino)		; 6F
	%ListVanillaInit(Pokey)			; 70
	%ListVanillaInit(SuperKoopa)		; 71
	%ListVanillaInit(SuperKoopa)		; 72
	%ListVanillaInit(SuperKoopa)		; 73
	%ListVanillaInit(Powerup)		; 74
	%ListVanillaInit(Powerup)		; 75
	%ListVanillaInit(Powerup)		; 76
	%ListVanillaInit(Powerup)		; 77
	%ListVanillaInit(Powerup)		; 78
	%ListVanillaInit(GrowingVine)		; 79
	dw $0000				; 7A
	dw $0000				; 7B
	dw $0000				; 7C
	dw $0000				; 7D
	%ListVanillaInit(FlyingRedCoin)		; 7E
	%ListVanillaInit(FlyingGoldMushroom)	; 7F
	%ListVanillaInit(Key)			; 80
	dw $0000				; 81
	dw $0000				; 82
	%ListVanillaInit(FlyingQuestionBlock)	; 83
	%ListVanillaInit(FlyingQuestionBlock)	; 84
	dw $0000				; 85
	%ListVanillaInit(Wiggler)		; 86
	%ListVanillaInit(LakituCloud)		; 87
	dw $0000				; 88
	dw $0000				; 89
	%ListVanillaInit(TinyBird)		; 8A
	dw $0000				; 8B
	dw $0000				; 8C
	dw $0000				; 8D
	dw $0000				; 8E
	%ListVanillaInit(ScalePlatforms)	; 8F
	%ListVanillaInit(LargeGreenGasBubble)	; 90
	%ListVanillaInit(Chuck)			; 91
	%ListVanillaInit(Chuck)			; 92
	%ListVanillaInit(Chuck)			; 93
	%ListVanillaInit(Chuck)			; 94
	%ListVanillaInit(Chuck)			; 95
	%ListVanillaInit(Chuck)			; 96
	%ListVanillaInit(Chuck)			; 97
	%ListVanillaInit(Chuck)			; 98
	%ListVanillaInit(VolcanoLotus)		; 99
	%ListVanillaInit(SumoBro)		; 9A
	%ListVanillaInit(AmazingHammerBro)	; 9B
	%ListVanillaInit(HammerBroPlatform)	; 9C
	%ListVanillaInit(CarrierBubble)		; 9D
	%ListVanillaInit(BallAndChain)		; 9E
	%ListVanillaInit(BanzaiBill)		; 9F
	dw $0000				; A0
	%ListVanillaInit(BowserBowlingBall)	; A1
	%ListVanillaInit(MechaKoopa)		; A2
	%ListVanillaInit(GreyPlatformOnChain)	; A3
	%ListVanillaInit(FloatingSpikeBall)	; A4
	%ListVanillaInit(FuzzballSparky)	; A5
	%ListVanillaInit(Hothead)		; A6
	dw $0000				; A7
	%ListVanillaInit(Blargg)		; A8
	%ListVanillaInit(Reznor)		; A9
	%ListVanillaInit(Fishbone)		; AA
	dw $0000				; AB
	%ListVanillaInit(WoodenSpike)		; AC
	%ListVanillaInit(WoodenSpike)		; AD
	%ListVanillaInit(FishingBoo)		; AE
	%ListVanillaInit(BooBlock)		; AF
	%ListVanillaInit(BooStream)		; B0
	%ListVanillaInit(CreatingEatingBlock)	; B1
	%ListVanillaInit(FallingSpike)		; B2
	%ListVanillaInit(BowserStatueFireball)	; B3
	%ListVanillaInit(Grinder)		; B4
	dw $0000				; B5
	%ListVanillaInit(ReflectingFireball)	; B6
	%ListVanillaInit(CarrotPlatform)	; B7
	%ListVanillaInit(CarrotPlatform)	; B8
	dw $0000				; B9
	%ListVanillaInit(TimedPlatform)		; BA
	%ListVanillaInit(CastleBlockPlatform)	; BB
	%ListVanillaInit(BowserStatue)		; BC
	dw $0000				; BD
	%ListVanillaInit(SwooperBat)		; BE
	%ListVanillaInit(MegaMole)		; BF
	%ListVanillaInit(Platform)		; C0
	%ListVanillaInit(FlyingBrick)		; C1
	%ListVanillaInit(BlurpFish)		; C2
	%ListVanillaInit(PorcuPuffer)		; C3
	%ListVanillaInit(Platform)		; C4
	dw $0000				; C5
	dw $0000				; C6
	%ListVanillaInit(InvisibleMushroom)	; C7
	dw $0000				; C8




VanillaMainList:
	%ListVanillaMain(Koopa)			; 00
	%ListVanillaMain(Koopa)			; 01
	%ListVanillaMain(Koopa)			; 02
	%ListVanillaMain(Koopa)			; 03
	%ListVanillaMain(Koopa)			; 04
	%ListVanillaMain(Koopa)			; 05
	%ListVanillaMain(Koopa)			; 06
	%ListVanillaMain(Koopa)			; 07
	%ListVanillaMain(Koopa)			; 08
	%ListVanillaMain(Koopa)			; 09
	%ListVanillaMain(Koopa)			; 0A
	%ListVanillaMain(Koopa)			; 0B
	%ListVanillaMain(Koopa)			; 0C
	%ListVanillaMain(BobOmb)		; 0D
	%ListVanillaMain(Keyhole)		; 0E
	%ListVanillaMain(Goomba)		; 0F
	%ListVanillaMain(Paragoomba)		; 10
	%ListVanillaMain(BuzzyBeetle)		; 11
	dw $0000				; 12
	%ListVanillaMain(Spiny)			; 13
	%ListVanillaMain(Spiny)			; 14
	%ListVanillaMain(Fish)			; 15
	%ListVanillaMain(Fish)			; 16
	%ListVanillaMain(Fish)			; 17
	%ListVanillaMain(Fish)			; 18
	%ListVanillaMain(DisplayTextCommand)	; 19
	%ListVanillaMain(PiranhaPlant)		; 1A
	%ListVanillaMain(ChuckProjectile)	; 1B
	%ListVanillaMain(BulletBill)		; 1C
	%ListVanillaMain(HoppingFlame)		; 1D
	%ListVanillaMain(Lakitu)		; 1E
	%ListVanillaMain(Magikoopa)		; 1F
	%ListVanillaMain(MagikoopaMagic)	; 20
	%ListVanillaMain(MovingCoin)		; 21
	%ListVanillaMain(NetKoopa)		; 22
	%ListVanillaMain(NetKoopa)		; 23
	%ListVanillaMain(NetKoopa)		; 24
	%ListVanillaMain(NetKoopa)		; 25
	%ListVanillaMain(Thwomp)		; 26
	%ListVanillaMain(Thwimp)		; 27
	%ListVanillaMain(BigBoo)		; 28
	dw $0000				; 29
	%ListVanillaMain(PiranhaPlant)		; 2A
	%ListVanillaMain(SumoBroLightning)	; 2B
	dw $0000				; 2C
	dw $0000				; 2D
	%ListVanillaMain(SpikeTop)		; 2E
	%ListVanillaMain(SpringBoard)		; 2F
	%ListVanillaMain(DryBones)		; 30
	%ListVanillaMain(BonyBeetle)		; 31
	%ListVanillaMain(DryBones)		; 32
	%ListVanillaMain(LavaFireball)		; 33
	%ListVanillaMain(BossFireball)		; 34
	dw $0000				; 35
	dw $0000				; 36
	%ListVanillaMain(Boo)			; 37
	%ListVanillaMain(Eerie)			; 38
	%ListVanillaMain(Eerie)			; 39
	%ListVanillaMain(Urchin)		; 3A
	%ListVanillaMain(Urchin)		; 3B
	%ListVanillaMain(Urchin)		; 3C
	%ListVanillaMain(RipVanFish)		; 3D
	%ListVanillaMain(POW)			; 3E
	%ListVanillaMain(Parachute)		; 3F
	%ListVanillaMain(Parachute)		; 40
	%ListVanillaMain(Dolphin)		; 41
	%ListVanillaMain(Dolphin)		; 42
	%ListVanillaMain(Dolphin)		; 43
	%ListVanillaMain(TorpedoTed)		; 44
	%ListVanillaMain(DirectionalCoins)	; 45
	%ListVanillaMain(Chuck)			; 46
	%ListVanillaMain(Fish)			; 47
	%ListVanillaMain(ChuckProjectile)	; 48
	%ListVanillaMain(GrowingShrinkingPipe)	; 49
	dw $0000				; 4A
	%ListVanillaMain(Lakitu)		; 4B
	%ListVanillaMain(ExplodingBlock)	; 4C
	%ListVanillaMain(MontyMole)		; 4D
	%ListVanillaMain(MontyMole)		; 4E
	%ListVanillaMain(JumpingPiranhaPlant)	; 4F
	%ListVanillaMain(JumpingPiranhaPlant)	; 50
	%ListVanillaMain(Ninji)			; 51
	%ListVanillaMain(MovingLedge)		; 52
	%ListVanillaMain(ThrowBlock)		; 53
	dw $0000				; 54
	%ListVanillaMain(Platform)		; 55
	%ListVanillaMain(Platform)		; 56
	%ListVanillaMain(Platform)		; 57
	%ListVanillaMain(Platform)		; 58
	%ListVanillaMain(BrickBridge)		; 59
	%ListVanillaMain(BrickBridge)		; 5A
	%ListVanillaMain(Platform)		; 5B
	%ListVanillaMain(Platform)		; 5C
	%ListVanillaMain(Platform)		; 5D
	%ListVanillaMain(Platform)		; 5E
	%ListVanillaMain(BrownPlatformOnChain)	; 5F
	dw $0000				; 60
	%ListVanillaMain(FloatingSkull)		; 61
	%ListVanillaMain(LineGuidedPlatform)	; 62
	%ListVanillaMain(LineGuidedPlatform)	; 63
	%ListVanillaMain(RopeMechanism)		; 64
	%ListVanillaMain(ChainsawMechanism)	; 65
	%ListVanillaMain(ChainsawMechanism)	; 66
	%ListVanillaMain(LineGuidedHitbox)	; 67
	%ListVanillaMain(LineGuidedHitbox)	; 68
	dw $0000				; 69
	dw $0000				; 6A
	dw $0000				; 6B
	dw $0000				; 6C
	dw $0000				; 6D
	%ListVanillaMain(DinoRhino)		; 6E
	%ListVanillaMain(DinoRhino)		; 6F
	%ListVanillaMain(Pokey)			; 70
	%ListVanillaMain(SuperKoopa)		; 71
	%ListVanillaMain(SuperKoopa)		; 72
	%ListVanillaMain(SuperKoopa)		; 73
	%ListVanillaMain(Powerup)		; 74
	%ListVanillaMain(Powerup)		; 75
	%ListVanillaMain(Powerup)		; 76
	%ListVanillaMain(Powerup)		; 77
	%ListVanillaMain(Powerup)		; 78
	%ListVanillaMain(GrowingVine)		; 79
	dw $0000				; 7A
	dw $0000				; 7B
	dw $0000				; 7C
	dw $0000				; 7D
	%ListVanillaMain(FlyingRedCoin)		; 7E
	%ListVanillaMain(FlyingGoldMushroom)	; 7F
	%ListVanillaMain(Key)			; 80
	dw $0000				; 81
	dw $0000				; 82
	%ListVanillaMain(FlyingQuestionBlock)	; 83
	%ListVanillaMain(FlyingQuestionBlock)	; 84
	dw $0000				; 85
	%ListVanillaMain(Wiggler)		; 86
	%ListVanillaMain(LakituCloud)		; 87
	dw $0000				; 88
	dw $0000				; 89
	%ListVanillaMain(TinyBird)		; 8A
	dw $0000				; 8B
	dw $0000				; 8C
	dw $0000				; 8D
	dw $0000				; 8E
	%ListVanillaMain(ScalePlatforms)	; 8F
	%ListVanillaMain(LargeGreenGasBubble)	; 90
	%ListVanillaMain(Chuck)			; 91
	%ListVanillaMain(Chuck)			; 92
	%ListVanillaMain(Chuck)			; 93
	%ListVanillaMain(Chuck)			; 94
	%ListVanillaMain(Chuck)			; 95
	%ListVanillaMain(Chuck)			; 96
	%ListVanillaMain(Chuck)			; 97
	%ListVanillaMain(Chuck)			; 98
	%ListVanillaMain(VolcanoLotus)		; 99
	%ListVanillaMain(SumoBro)		; 9A
	%ListVanillaMain(AmazingHammerBro)	; 9B
	%ListVanillaMain(HammerBroPlatform)	; 9C
	%ListVanillaMain(CarrierBubble)		; 9D
	%ListVanillaMain(BallAndChain)		; 9E
	%ListVanillaMain(BanzaiBill)		; 9F
	dw $0000				; A0
	%ListVanillaMain(BowserBowlingBall)	; A1
	%ListVanillaMain(MechaKoopa)		; A2
	%ListVanillaMain(GreyPlatformOnChain)	; A3
	%ListVanillaMain(FloatingSpikeBall)	; A4
	%ListVanillaMain(FuzzballSparky)	; A5
	%ListVanillaMain(Hothead)		; A6
	dw $0000				; A7
	%ListVanillaMain(Blargg)		; A8
	%ListVanillaMain(Reznor)		; A9
	%ListVanillaMain(Fishbone)		; AA
	dw $0000				; AB
	%ListVanillaMain(WoodenSpike)		; AC
	%ListVanillaMain(WoodenSpike)		; AD
	%ListVanillaMain(FishingBoo)		; AE
	%ListVanillaMain(BooBlock)		; AF
	%ListVanillaMain(BooStream)		; B0
	%ListVanillaMain(CreatingEatingBlock)	; B1
	%ListVanillaMain(FallingSpike)		; B2
	%ListVanillaMain(BowserStatueFireball)	; B3
	%ListVanillaMain(Grinder)		; B4
	dw $0000				; B5
	%ListVanillaMain(ReflectingFireball)	; B6
	%ListVanillaMain(CarrotPlatform)	; B7
	%ListVanillaMain(CarrotPlatform)	; B8
	dw $0000				; B9
	%ListVanillaMain(TimedPlatform)		; BA
	%ListVanillaMain(CastleBlockPlatform)	; BB
	%ListVanillaMain(BowserStatue)		; BC
	dw $0000				; BD
	%ListVanillaMain(SwooperBat)		; BE
	%ListVanillaMain(MegaMole)		; BF
	%ListVanillaMain(Platform)		; C0
	%ListVanillaMain(FlyingBrick)		; C1
	%ListVanillaMain(BlurpFish)		; C2
	%ListVanillaMain(PorcuPuffer)		; C3
	%ListVanillaMain(Platform)		; C4
	dw $0000				; C5
	dw $0000				; C6
	%ListVanillaMain(InvisibleMushroom)	; C7
	dw $0000				; C8



; insert vanilla sprite source code
	%VanillaSprite(Koopa)			; 00
	%VanillaSprite(BobOmb)			; 0D
	%VanillaSprite(Keyhole)			; 0E
	%VanillaSprite(Goomba)			; 0F
	%VanillaSprite(Paragoomba)		; 10
	%VanillaSprite(BuzzyBeetle)		; 11
	%VanillaSprite(Spiny)			; 13
	%VanillaSprite(Fish)			; 15
	%VanillaSprite(DisplayTextCommand)	; 19
	%VanillaSprite(PiranhaPlant)		; 1A
	%VanillaSprite(ChuckProjectile)		; 1B
	%VanillaSprite(BulletBill)		; 1C
	%VanillaSprite(HoppingFlame)		; 1D
	%VanillaSprite(Lakitu)			; 1E
	%VanillaSprite(Magikoopa)		; 1F
	%VanillaSprite(MagikoopaMagic)		; 20
	%VanillaSprite(MovingCoin)		; 21
	%VanillaSprite(NetKoopa)		; 22
	%VanillaSprite(Thwomp)			; 26
	%VanillaSprite(Thwimp)			; 27
	%VanillaSprite(BigBoo)			; 28
	%VanillaSprite(SumoBroLightning)	; 2B
	%VanillaSprite(SpikeTop)		; 2E
	%VanillaSprite(SpringBoard)		; 2F
	%VanillaSprite(DryBones)		; 30
	%VanillaSprite(BonyBeetle)		; 31
	%VanillaSprite(LavaFireball)		; 33
	%VanillaSprite(BossFireball)		; 34
	%VanillaSprite(Boo)			; 37
	%VanillaSprite(Eerie)			; 38
	%VanillaSprite(Urchin)			; 3A
	%VanillaSprite(RipVanFish)		; 3D
	%VanillaSprite(POW)			; 3E
	%VanillaSprite(Parachute)		; 3F
	%VanillaSprite(Dolphin)			; 41
	%VanillaSprite(TorpedoTed)		; 44
	%VanillaSprite(DirectionalCoins)	; 45
	%VanillaSprite(Chuck)			; 46
	%VanillaSprite(GrowingShrinkingPipe)	; 49
	%VanillaSprite(ExplodingBlock)		; 4C
	%VanillaSprite(MontyMole)		; 4D
	%VanillaSprite(JumpingPiranhaPlant)	; 4F
	%VanillaSprite(Ninji)			; 51
	%VanillaSprite(MovingLedge)		; 52
	%VanillaSprite(ThrowBlock)		; 53
	%VanillaSprite(Platform)		; 55
	%VanillaSprite(BrickBridge)		; 59
	%VanillaSprite(BrownPlatformOnChain)	; 5F
	%VanillaSprite(FloatingSkull)		; 61
	%VanillaSprite(LineGuidedPlatform)	; 62
	%VanillaSprite(RopeMechanism)		; 64
	%VanillaSprite(ChainsawMechanism)	; 65
	%VanillaSprite(LineGuidedHitbox)	; 67
	%VanillaSprite(DinoRhino)		; 6E
	%VanillaSprite(Pokey)			; 70
	%VanillaSprite(SuperKoopa)		; 71
	%VanillaSprite(Powerup)			; 74
	%VanillaSprite(GrowingVine)		; 79
	%VanillaSprite(FlyingRedCoin)		; 7E
	%VanillaSprite(FlyingGoldMushroom)	; 7F
	%VanillaSprite(Key)			; 80
	%VanillaSprite(FlyingQuestionBlock)	; 83
	%VanillaSprite(Wiggler)			; 86
	%VanillaSprite(LakituCloud)		; 87
	%VanillaSprite(TinyBird)		; 8A
	%VanillaSprite(ScalePlatforms)		; 8F
	%VanillaSprite(LargeGreenGasBubble)	; 90
	%VanillaSprite(VolcanoLotus)		; 99
	%VanillaSprite(SumoBro)			; 9A
	%VanillaSprite(AmazingHammerBro)	; 9B
	%VanillaSprite(HammerBroPlatform)	; 9C
	%VanillaSprite(CarrierBubble)		; 9D
	%VanillaSprite(BallAndChain)		; 9E
	%VanillaSprite(BanzaiBill)		; 9F
	%VanillaSprite(BowserBowlingBall)	; A1
	%VanillaSprite(MechaKoopa)		; A2
	%VanillaSprite(GreyPlatformOnChain)	; A3
	%VanillaSprite(FloatingSpikeBall)	; A4
	%VanillaSprite(FuzzballSparky)		; A5
	%VanillaSprite(Hothead)			; A6
	%VanillaSprite(Blargg)			; A8
	%VanillaSprite(Reznor)			; A9
	%VanillaSprite(Fishbone)		; AA
	%VanillaSprite(WoodenSpike)		; AC
	%VanillaSprite(FishingBoo)		; AE
	%VanillaSprite(BooBlock)		; AF
	%VanillaSprite(BooStream)		; B0
	%VanillaSprite(CreatingEatingBlock)	; B1
	%VanillaSprite(FallingSpike)		; B2
	%VanillaSprite(BowserStatueFireball)	; B3
	%VanillaSprite(Grinder)			; B4
	%VanillaSprite(ReflectingFireball)	; B6
	%VanillaSprite(CarrotPlatform)		; B7
	%VanillaSprite(TimedPlatform)		; BA
	%VanillaSprite(CastleBlockPlatform)	; BB
	%VanillaSprite(BowserStatue)		; BC
	%VanillaSprite(SwooperBat)		; BE
	%VanillaSprite(MegaMole)		; BF
	%VanillaSprite(FlyingBrick)		; C1
	%VanillaSprite(BlurpFish)		; C2
	%VanillaSprite(PorcuPuffer)		; C3
	%VanillaSprite(InvisibleMushroom)	; C7





