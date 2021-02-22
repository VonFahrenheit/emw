;
; This patch adds GFX options to vanilla sprites.
;
; about palsets...
; pal E sprites:
;	x eerie (38, 39) needs generic_ghost_blue (0F)
;	x fishin boo (AE) needs generic_ghost_blue (0F)
;	x big boo (28, C5) needs generic_ghost_blue (0F)
;	x rock (48) uses vanilla dark grey palette E:00
;	x bowling ball (A1) uses vanilla dark grey palette E:00
;	x porcu puffer (C3) uses vanilla palette E:03
;	x buzzy beetle (11) uses vanilla dark green palette E:04
; pal F sprites:
;	x dino rhino/torch (6E, 6F) uses vanilla dark green gradient F:00
;	x boo block (AF) uses vanilla ghost palette F:05
;	x boo stream (B0) uses vanilla ghost palette F:05
;
; recode tweaker 3:
;	- 0 = generic_brown
;	- 2 = generic_grey
;	- 4 = default_yellow
;	- 6 = default_blue
;	- 8 = default_red
;	- A = default_green
;	- C = generic_ghost_blue
;	- E = generic_darkgrey
;

!GenericTilemap	= $9B83
!GenericProp	= $9CDB


	SlideFix:		; fix initial frame when koopa slides out of shell
	pushpc
	org $0189F2
		JSL .Fix	; source: BEQ $02 : LDA #$28 (0x86 in vanilla, sliding koopa tile)
		LDY $33B0,x
	pullpc
	.Fix
		BEQ $02 : LDA #$28
		CLC : ADC !SpriteTile,x
		RTL


	OffScreenFix:
	pushpc
	org $01A3E8
		PHA
		TYA				; this is much better than setting the tile to X = 0x180
		ASL #2
		TAX
		LDA #$F0 : STA !OAM+$101,x
		PLA
		BRA +
		NOP #3
	warnpc $01A3F8
	org $01A3F8
		+
	org $01A3FB
		TYA
		ASL #2
		TAX
		LDA #$F0 : STA !OAM+$105,x
		BRA +
		NOP #3
	warnpc $01A409
	org $01A409
		+
	pullpc


	StunFix:
	pushpc
	org $01A1F1
		BRA .ReRoute	; source: BRA $2F ($01A222)
	org $01A1FB
		BRA .ReRoute	; source: BRA $25 ($01A222)
	org $01A220
	.ReRoute
	pullpc



	GenericTiles:
	pushpc
	org $019D39
		JSL .Remap01	; offset 0 tile 1
		NOP #2
	org $019D8F
		JSL .Remap01	; offset 0 tile 1
		NOP #2
	org $019D95
		JSL .Remap12	; offset 1 tile 2
		NOP #2
	org $019DF3
		JSL .Remap02	; offset 0 tile 2
		NOP #2
	org $019DF9
		JSL .Remap11	; offset 1 tile 1
		NOP #2
	org $019F24
		JSL .Remap01	; offset 0 tile 1

	org $019BA8
		db $02,$04,$04,$02	; stunned goomba tiles

	org $01B10A
		BRA 16 : NOP #16
	warnpc $01B11C
	org $01B122
		RTS			; remove sprite palette write from some sprites
		NOP #6
		RTS
	warnpc $01B12A

	pullpc

	.Remap01
		LDA !GenericTilemap,x
		PHX
		LDX !SpriteIndex
		XBA
		LDA $3200,x
		CMP #$0F : BNE ..Normal

	;	CMP #$0F : BEQ ..GoombaState
	;	BRA ..Normal

		..GoombaState
		LDA $3230,x
		CMP #$08 : BEQ ..Goomba
		CMP #$02 : BEQ ..RollingGoomba
		CMP #$0B : BEQ ..Normal
		LDA $3330,x
		AND #$04 : BNE ..Normal

		..RollingGoomba
		LDA #$00
		BRA ..Shared

		..Goomba
		LDA $3310,x
		LSR #3
		AND #$03
		CMP #$03
		BNE $02 : LDA #$01
		INC A
		ASL A
		BRA ..Shared

		..Normal
		XBA

		..Shared
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		PLX
		RTL

	.Remap12
		LDA !GenericTilemap+1,x
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		PLX
		RTL

	.Remap02
		LDA !GenericTilemap,x
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		PLX
		RTL

	.Remap11
		LDA !GenericTilemap+1,x
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		PLX
		RTL


	GenericProp:
	pushpc
	org $019D46
		JSL .Remap1		; source: LDA !GenericProp,x : ORA $03
		NOP

	org $019DBE
		JSL .Remap2		; source: ORA $64 : STA !OAM+$103,y
		NOP
	org $019F46
		JSL .Remap2		; source: ORA $64 : STA !OAM+$103,y
		NOP

	pullpc
	.Remap1
		LDA !GenericProp,x
		ORA $03
		AND #$F0
		PHX
		LDX !SpriteIndex
		ORA !SpriteProp,x
		ORA $33C0,x
		PLX
		RTL

	.Remap2
		ORA $64
		AND #$F0
		ORA !SpriteProp,x
		ORA $33C0,x
		STA !OAM+$103,y
		RTL


	SpecificSimple:
	pushpc
	org $018E90
		JSL .PlantStalk		; source: AND #$F1 : ORA #$0B
		BRA $01 : NOP		; source: STA !OAM+$10B,y

	org $019BC1
		db $05,$05,$04,$04	; piranha plant propeller
		db $05,$05,$14,$14
	org $01C197
		JSL .GrowingVine	;\ source: LDA $14 : LSR #4 : LDA #$AC
		NOP #4			;/
		BCC $02 : INC #2	; source: BCC $02 : LDA #$AE

	org $019BEB
		db $0A			; spike top second diagonal tile		

	org $019C02
		db $6E			; throw block tile

	org $019C09
		db $0A,$04,$0A,$04	; extra net koopa tiles not included in STEAR

	org $019C2D
		db $02,$00,$06,$04	; bony beetle tile table
	org $01E453
		JSL .SkeletonRubble	; source: LDA #$48 : CPY #$10
	org $01E45D
		LDA $0F			; source: LDA #$2E
	org $03C3CF
		db $00,$02,$00,$00	; dry bones tile table
		db $04,$0A,$00,$06
	org $03C43C
		JSL .DryBones		; source: INY #4 (dry bones)

	org $019C5A
		db $00,$02		; eerie tiles


	org $019C5C
		db $02,$00,$04,$06,$08,$0A,$00,$02,$04,$0A,$08,$00,$06	; boo tiles that STEAR won't find
	org $028CB8
		db $02,$04,$08,$00	; boo stream tiles
		db $06,$0A,$02,$04	; (minor exsprite)
		db $08,$00,$06,$0A
	org $028D23
	;	JSL .BooStream1		; source: LDA $8CB8,x : STA !OAM+$002,y
	;	NOP #2
	org $028D38
	;	JSL .BooStream2		; source: TYA : LSR #2 : TAY


	org $019E10
		db $FF,$F7,$09,$09
		db $FF,$FF,$00,$00
		db $FC,$F4,$FC,$F4

	org $019E1C
		db $02,$00,$02,$00	; angel wing tile table
	org $019E24
		db $00,$02,$00,$02	; angel wing tile size table
	org $019E89
		JSL .AngelWings		; source: TYA : LSR #2 : TAY

	org $01B77D
		LDA #$6E		; brick bridge tile
	org $01B78E
		JSL .BrickBridge	; source: LDA $64 : STA !OAM+$10F,y
		NOP
	org $07F3FE+$59
		db $E0,$E0		; brick bridge tweaker 3

	org $07F3FE+$11
		db $1A			; buzzy beetle tweaker 3

	org $01BAB7
		db $00,$02,$00,$00,$02,$00,$04,$06	; climbing net door tiles
		db $04,$08,$0A,$08,$08,$0A,$08,$00
		db $00,$00,$0C,$0E,$0C
	org $01BBC3
		JSL .ClimbingDoor	; source: INY #4
	org $01BBD2
		ORA $0F					; read prop from RAM


	org $07F3FE+$C3
		db $CA		; porcu puffer tweaker 3

	org $019C65		; rip van fish tiles
		db $04,$06,$00,$02

	org $01C999
		JSL .ChainPlatform1	; INY #4 (rotating chain platform thing)
	org $01C9BB
		db $00,$01,$01,$02	; chain platform tiles
	org $07F3FE+$5F
		db $E0			; chain platform tweaker 3

	org $01E23D
	.Keyhole
		LDA $00 : STA !OAM+$100,y
		LDA $01 : STA !OAM+$101,y
		LDA !SpriteTile,x
		INC #2
		STA !OAM+$102,y
		LDA #$30
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDY #$02
		LDA #$00
		JMP $B7BB
	warnpc $01E26A
	org $01A1F9
		JML .Key		; source: LDA #$XX : BRA $25 ($01A222)


	org $07F3FE+$A4
		db $F0			; spiky ball tweaker 3

	org $07F3FE+$3E
		db $36			; pswitch tweaker 3 should mark palset B
	org $018459			; prevent pswitch GARBAGE
		BRA $05 : NOP #5	; source: TAY : LDA $8466,y : STA $33C0,x
	org $01A220
		JSL .PSwitch		; source: LDA #42 : LDY $33B0,x
		NOP
	org $01E74E
		JSL .Smushed		; source: TYA : LSR #2 : TAY

	org $01AF8F
		JSL .Thwomp		; source: STA !OAM+$102,y : INY

	org $01AE75
		LDA #$6C
		BCC $02 : LDA #$00	; remap tile numbers of flying block
		JML .FlyingBlocks	; source: STA !OAM+$102,y : RTS


	org $01B32D
		BRA +
	org $01B344
	+	LDA !SpriteTile,x : STA !OAM+$102,y
		INC A
		STA !OAM+$106,y
		STA !OAM+$10A,y
		STA !OAM+$10E,y
		INC A
		STA !OAM+$112,y
		STA $0F
		JML .Plat
	org $01B36D
	.ReturnPlat
	org $01B371
		LDA $0F			; read tile from RAM

	org $01B3FD
		JSL .OrangePlat		; source: LDA $B383,x : STA !OAM+$102,y
		NOP #2
	org $01B42E
		LDA $0E			; read from RAM
	org $01B433
		LDA $0F
	org $01B43A
		LDA $0E
	org $01B43F
		LDA $0F


	org $01B690
		JSL .Remap		; source: INY #4

	org $01BD74
		JSL .MagikoopaMagic	; source: LDA $33C0,x : ORA $64
		NOP
	org $01BD82
		LDA $00			; load tiles from RAM
	org $01BD87
		LDA $01
	org $01BD8C
		LDA $02
	org $01BF01
		JSL .MagikoopaWand	; source: STA !OAM+$10B,y : LDA #$99
		NOP


	org $01C613
		db $45,$40		; flying red coin and flying rainbow shroom tiles

	org $01C6DA
		JSL .Powerups		; source: STA !OAM+$102,y : LDX !SpriteIndex
		NOP #2


	org $01D446
		db $00,$02,$04,$06	; boss fireball tiles
	org $01D496
		LDY $33B0,x		; get rid of hard-coded index
		BRA $02 : NOP #2
	warnpc $01D49D
	org $01D4D8
		JSL .Remap		; source: INY #4 (boss fireball)


	org $019B9A
		db $00,$02,$02,$02	; parachute goomba tile table
		db $02,$02,$02,$02
		db $02,$02,$02,$02
	org $019BA6
		db $00,$02		; parachute tiles
	org $019BB8
		db $00,$02		; parachute tiles
	org $019BAC
		db $00,$02,$02,$02	; parachute bobomb tile table
		db $02,$02,$02,$02
		db $02,$02,$02,$02
	org $01D5F1
		JSL .Parachute		; source: STA $3320,x : JSR $9F0D
		NOP #2
	org $01D650
		JSL .ParachuteBody	; source: LDA $D5B0,y : JSR $9CF3
		NOP #2

	org $07F3FE+$67			; grinder tweaker 3
		db $02
	org $07F3FE+$B4			; grinder tweaker 3
		db $02
	org $01DB9E
		db $32,$72,$B2,$F2	; grinder prop (set priority)
	org $01DBBE
		NOP #2			; source: ORA #$6C (grinder tile)
	org $01DBC9
		JSL .Remap		; source: INY #4 (grinder)
	org $01DC27
		NOP #2			; source: ORA #$6C (grinder tile)
	org $01DC32
		JSL .Remap		; source: INY #4 (grinder)


	org $01DBF4
		JSL .Fuzzy		; source: LDA #$C8 : STA !OAM+$102,y
		NOP
	org $01DBFC
		ORA $0F


	org $01DC4C
		db $00,$00,$00,$00	; rope tile table
		db $00,$00,$00,$00
	org $01DCB0
		JSL .RemapMechanism	; source: INY #4
	org $01DCB9
		LDA $0F			; remap end of rope tile to RAM
	org $07F3FE+$64
		db $A0			; rope tweaker 3


	org $028113
		LDA #$00		; source: LDA #$BC (base bomb star tile number)
	org $02811E
		JSL .Explosion		; source: SEC : ROL A : ORA $64

	org $02DB90
		JSL .HammerBroIndex	; source: LDA $3240,x : SBC #$00
		NOP
	org $02DC1F
		db $6E,$6E,$00,$00	; hammer bro platform tile table, first row open wing second row closed wing
		db $6E,$6E,$02,$02
	org $02DCA3
		JSL .WingedPlatform	; source: INY #4 (hammer bro platform)
	org $07F3FE+$9C
		db $32			; winged platform tweaker 3


	org $07F3FE+$AF
		db $0C			; boo block tweaker 3
	org $01FA23
		JML .BooBlock		; source: TAX : LDA $FA37,x
	org $01FA32
	.ReturnBooBlock


	org $028E63
	;	JSL .Z			; source: LDA $8DD7,x
	;	NOP #2

	org $029E73
	;	ORA #$12		; remove T bit
	org $029E78
	;	JSL .TorpedoArm		; source: TYA : LSR #2 : TAY
	org $02B947
		JSL .TorpedoTed		; source: LDA #$01 : LDY #$02

	org $02A339
	;	JSL .Hammer		; source: TYA : LSR #2 : TAX (note the TAX over TAY)

	org $02B79B
		JSL .Remap		; pokey?

	org $02BC62
		JML .Dolphin		; source: LDA $BC0E,x : STA !OAM+$102,y
		NOP #2
	org $02BC74
	.ReturnDolphin
	org $02BC78
		ORA $0F			; get prop from RAM
	org $07F659+$43
		db $25			; mark vertical dolphin as 2 tiles tall in tweaker table


	org $02BE4C
		db $04,$44		; remove lowest bit of fuzzy prop
	org $02BE6A
		JSL .Fuzzy		; source: LDA #$C8 : STA !OAM+$102,y
		NOP
		LDA $BE4C,x
		ORA $0F			; source: ORA $64
	warnpc $02BE74

	org $02BE79
		LDA !SpriteTile,x : STA !OAM+$102,y	; sparky tile
		JSL .Sparky
		ASL #3
		EOR !OAM+$103,y
		STA !OAM+$103,y
		RTS
	warnpc $02BE8D


	org $02BEEF
		JSL .Remap		; source: INY #4 (hothead part 1)
	org $02BF0A
		JSL .Hothead		; source: LDA #$09 : LDY $32F0,x
		NOP
		BEQ $02 : ADC #$10	; open/closed eye tile
	org $02BF3A
		ORA $0F			; prop from RAM

	org $02BFB1
		JSL .Urchin		; source: STA !OAM+$102,y : INY

	org $02CF2B
		LDA #$54		; source: LDA #$3D (remap pea bouncer)

	org $018FF2			; prevent bullet bill FAIL code
		JSL .BulletBillAntiFail	; source: LDA $8FC7,y : STA $33C0,x
		NOP #2

	org $07F3FE+$9F
		db $02			; banzai bill tweaker 3
	org $02D608
		JSL .Remap		; source: INY #4 (Banzai Bill)

	org $02E919
		LDA !SpriteTile,x
		STA !OAM+$102,y
		INC #2
		STA !OAM+$106,y
		LDA $33C0,x
		ORA $64
		JML .Pipe
	warnpc $02E92E
	org $02E92E
	.ReturnPipe

	org $07F3FE+$9E			; ball and chain tweaker 3
		db $02
	org $02D7A2
		JSL .BallAndChain1	; source: TAX : LDA #$E8 : CPX #$9E
		NOP
	org $02D7BE
		LDA $0F			; recode hardwired prop to RAM
	org $02D82B
		JML .BallAndChain2
		NOP #8
	warnpc $02D837
	.ReturnBall

	org $01E935
		JSL .LakituCloud	; source: LDA $64 : STA !OAM+$103,y
		NOP
	org $01E94A
		JSL .LakituCloudSize	; source: LDY #$02 : LDA #$01
	org $01E957
		JSL .LakituCloudSize	; source: LDY #$02 : LDA #$01
	org $01E969
		JSL .LakituCloudFace	; source: STA !OAM+$008 (no index) : LDA $74B2
		LDA !Tile_LakituCloud : STA !OAM+$002,y
		LDA #$38
		ORA !Prop_LakituCloud : STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		LDA #$00 : STA !OAMhi,y
		RTS
	warnpc $01E985
	org $01E985
		db $5E,$64,$62,$60	; lakitu cloud tiles ($60 -> $5E)
	org $02E6A7
		LDA #$09		; lakitu fishing pole tile
	org $02E6AC
		LDA #$45		; lakitu bait tile
	org $02E6B6
		LDA #$34		; lakitu bait prop
	org $02E6BB
		JSL .LakituRod		; org: LDA #$01 : LDY #$02
	org $02E706
		LDA #$18		; lakitu fishing line tile
	org $02E710
		JSL .Remap		; org: INY #4 (lakitu fishing line)

	org $02D689
		LDA $04				; fix ball n chain
		STZ $2250
		STA $2251
		STZ $2252
		LDA $34A0,x
		LDY $05
		BNE .CODE_02D6A3		; repair
		STA $2253
		STZ $2254
		NOP
		BRA $00
		ASL $2306
		LDA $2307
		ADC #$00
	.CODE_02D6A3
		LSR $01
		BCC .CODE_02D6AA
		EOR #$FF
		INC A
	.CODE_02D6AA
		STA $04
		LDA $06
		STA $2251
		LDA $34A0,x
		LDY $07
		BNE .CODE_02D6C6
		JML .MultiplyFix
		db $00
	.CODE_02D6C6
	warnpc $02D6C6
	org $02D881
		LDA $34A0,x		; repair


	org $02D7F1
		JSL .ChainPlatform2	; source: INY #4 (gray chain platform)




	org $02D8A1			; tiles of what bubble is carrying
		db $80,$80,$84,$C0	; highest bit signals that it's not a bubble tile
		db $82,$82,$86,$C0
	org $02D9C3			; bubble carrier tile table
		db $00,$00,$00,$00,$02
	org $02DA2E
		LDA #$62
		BCS $02 : LDA #$64	; remap splash tiles
	org $02DA43
		JSL .BubbleCarrier	; source: INY #4 (bubble)
	org $02D8E8
		JSL .BubbleCarrierCargo	; source: LDA $32C0,x : CMP #$60
		NOP

					; 98 -> 12
					; 99 -> 13
					; A7 -> 0D
					; A8 -> 0E
					; AA -> 20
					; AB -> 21
					; 8A -> 23
					; 66 -> 25
					; EE -> 04
					; 80 -> 00
					; C1 -> 06
					; C3 -> 08
					; C5 -> 0A
					; C6 -> 0B
	org $02DE0E			; sumo bro tile table
		db $12,$13,$0D,$0E,$12,$13,$20,$21
		db $8A,$66,$20,$21,$04,$04,$0A,$0B
		db $00,$00,$06,$08,$00,$00,$06,$08
	org $02DE7E
		CMP #$66		; remap 0x66 tile??????
	org $02DE97
		JSL .Remap		; source: INY #4 (sumo bro)

	org $02E372			; green gas bubble tile table
		db $00,$02,$04,$06,$08,$0A,$0C,$0E
		db $08,$0A,$0C,$0E,$00,$02,$04,$06
	org $02E408
		JSL .Remap		; source: INY #4 (gas bubble)


	org $02E657
		JSL .Remap		; source: INY #4 (moving ledge)
	org $02E66A
		db $01,$00,$00,$01	; moving ledge tiles

	org $02EA06
		JML .PipeLakitu		; source: TAX : LDA $E9A6,x
	org $02EA1C
	.ReturnPipeLakitu

	org $029D2F
		JML .WigglerFlower	; source: LDA #$98 : STA !OAM+$002,y
		NOP
	org $029D36
	.ReturnWigglerFlower

	org $029B93
		LDA #$00		; lotus fire tile 1
	org $029B97
		LDA #$10		; lotus fire tile 2
	org $029B9C
		JSL .LotusFire		; source: TYA : LSR #2 : TAY
	org $02E061
		JSL .VolcanoLotus	; source: LDA $33B0,x : CLC

	org $02D844
		db $04,$00,$01,$02	; castle platform tiles
	org $07F3FE+$BB
		db $02			; castle platform tweaker 3
	org $02D867
		JSL .Remap		; source: INY #4

	org $02DB3D
		JSL .Remap		; source: INY #4 (hammer bro)

	org $02E598
		JSL .ScalePlat		; source: LDA #$80 : STA !OAM+$102,y
		NOP
	org $02E5A3
		ORA $0F


					; C0 -> 00
					; D0 -> 10
					; E0 -> 05
					; E1 -> 06
					; F2 -> 17
					; C8 -> 01
					; C9 -> 02
					; CA -> 03
					; CB -> 04
					; D8 -> 11
					; D9 -> 12
					; DA -> 13
					; DB -> 14
					; E4 -> 08
					; E5 -> 09
					; F4 -> 18
					; F5 -> 19
					; CF -> 07 (empty tile)
	org $02EC72			; super koopa tile table
		db $01,$11,$10,$4A	; values 0x40+ signify that it's a normal koopa tile (E0 -> 4A, E2 -> 4C)
		db $02,$12,$00,$4C
		db $08,$09,$17,$05
		db $18,$19,$17,$05
		db $13,$03,$05,$4A
		db $14,$04,$05,$4A
		db $08,$09,$4A,$07
		db $18,$19,$4C,$07
		db $08,$09,$4C,$07
	warnpc $02EC96
	org $02ED6B
		JSL .RemapSuperKoopa	; source: INY #4 (super koopa)





	org $02EDFD
		LDA $14			; skull tile
		AND #$10
		LSR #3
		CLC
		JSL .Skull
	warnpc $02EE09


	org $02F16D
		JSL .Wiggler		; source: LDA #$8C : CPX #$00
	org $02F176
		dw !BigRAM		; tilemap pointer
	org $02F1BD
		LDA $0F			; read eye tile from RAM
	org $02F1E3
		LDA $0E			; read flower tile from RAM


	org $02F3DB
		db $10,$11,$00,$01,$02	; small bird tilemap
	org $02F31A
		JML .BirdINIT		; source: BEQ $05 : LDA #$04
	org $02F324
		JSL !SpriteApplySpeed
		JML .BirdMAIN
	.BirdFlyX
		db $40,$C0
		NOP #3
	warnpc $02F331
	org $02F331
		.ReturnBirdMAIN
	org $02F351
		LDA $3330,x
		AND #$04 : BEQ +
		BRA ++
		NOP
	warnpc $02F35B
		++
	org $02F370
	+	RTS
	org $02F3E2
		db $0A,$08,$06,$04	; remap bird palettes to standard order (GRBY)
	org $02F3EA
		LDA $3280,x		; remap bird palette index to RAM rather than sprite ID
	org $02F3F9
		JML .BirdGFX		; LDA $F3E6,y : TAY
	org $02F422
		TYA : LSR #2 : TAY



	org $0384B3
		JSL .Remap		; source: INY #4 (falling grey platform)

	org $0384D1
		JML .Blurp		; source: LDA $3014 : LSR A
	org $0384E2
	.ReturnBlurp

	org $0385E3
		JSL .Remap		; source: INY #4

	org $03875D
		JSL .Remap		; source: INY #4 (sinking rock platform)

	org $07F3FE+$48
		db $1A			; chuck rock tweaker 3


	org $01E369
		JSL .MoleAntiFail	; source: ORA #$31 (VERY BAD) : STA $33C0,x
		NOP

	org $03888F
		JSL .Remap		; source: INY #4 (mega mole)

	org $0388B2
		JML .Swooper		; source: STA !OAM+$102,y : PLX
	.ReturnSwooper
	org $07F3FE+$BE
		db $08			; swooper tweaker 3

	org $018314
		JML .StatueFix		; source: INC $3320,x : JSR $83A4
		NOP #2
		.ReturnStatue
	org $018320
		RTS			; source: LDA #$01 : STA $33C0,x
		NOP #4

	org $038B97
		JSL .Remap		; source: INY #4 (bowser statue)

	org $038ED9
		JSL .Remap		; source: INY #4

	org $07F3FE+$B3
		db $38			; statue fireball tweaker 3
	org $038F5C
		JSL .Remap		; source: INY #4 (statue fireball)

	org $038F6D			; boo stream tile table (sprite)
		db $02,$00,$06,$02,$08,$06,$02,$00
	org $038F9C
		JSL .BooStreamHead	; source: TAX : LDA $8F6D,x
	org $07F3FE+$B0
		db $3C			; boo stream tweaker 3

	org $039010
		LDA !SpriteTile,x : STA !OAM+$102,y
		LDA !OAM+$103,y
		JSL .BouncingPodoboo
		RTS
	warnpc $03901F

					; 60 -> 60
					; 64 -> 00
					; 8A -> 02
					; AC -> 04
					; CC -> 06
					; CE -> 08
	org $039160			; fishing boo tile table
		db $60,$60,$00,02
		db $60,$60,$04,$04
		db $04,$08
	org $039174			; fishing boo fire tile table
		db $06,$08,$06,$08
	org $0391E6
		JSL .FishingBoo		; org: INY #4 (fishing boo)


	org $03921B
		JSL .Spike		; source: LDA #$E0 : STA !OAM+$102,y
		NOP

	org $03929A
		JSL .EatingBlock	; source: AND #$3F : STA !OAM+$103,y
		NOP

	org $07F3FE+$AC
		db $30,$30		; wooden spikes tweaker 3
	org $039501
		JSL .Remap		; source: INY #4 (wooden spike)

	org $03979E
		JML .Fishbone		; source: STA !OAM+$102,y : JSR $B760
		NOP #2
	org $0397D4
		LDA !BigRAM,x		; read prop from RAM
	org $0397E1
		LDA !BigRAM+4,x		; read tile from RAM




	org $03B171
		JSL !GetSpriteClipping04
		JSL .BowserBall
		JSL !SpriteApplySpeed
		BRA +
		NOP #11
	org $03B18A
		+
	org $03B18E
		LDA $3330,x
		AND #$04 : BEQ +
		NOP #8
	org $03B1C5
		+
					; 45 -> 00
					; 47 -> 02
					; 65 -> 04
					; 66 -> 05
					; 63 -> 07
					; 38 -> 09
					; 39 -> 19
	org $03B1ED			; bowser ball tile able
		db $00,$02,$00,$04
		db $05,$04,$00,$02
		db $00,$19,$09,$07
	org $03B221
		BRA $03 : NOP #3	; don't force OAM
	org $03B258
		JSL .Remap		; source: INY #4 (bowser bowling ball)
	org $07F3FE+$A1
		db $FA			; bowser bowling ball tweaker 3


					; 00 -> 00
					; 01 -> 01
					; 10 -> 10
					; 0A -> 03
					; 0C -> 05
					; 0E -> 07
					; 40 -> 09
					; 51 -> 0B
					; 42 -> 0D
					; 60 -> 0E
					; 70 -> 1D
					; 71 -> 1E
					; 72 -> 1F
	org $03B32F			; mechakoopa tile table
		db $09,$0D,$0E,$0B
		db $09,$0D,$0E,$03
		db $09,$0D,$0E,$05
		db $09,$0D,$0E,$07
		db $00,$02,$10,$01
		db $00,$02,$10,$01
	org $03B3DB
		JSL .Mechakoopa		; source: DEY #4
	org $03B3F3
		db $1D,$1E,$1F,$1E	; mechakoopa key tiles
	org $03B433
		JSL .MechakoopaKey	; source: LDY #$00 : LDA #$00




	org $07F3FE+$6E
		db $3A,$0A		; dino rhino and dino torch tweaker 3
	org $019B07
		JSL .DinoSmushed	; source: LDY $33B0,x : LDA #$AC (smushed tile)
		NOP
					; 0xF0+ will signify that it's the flame tile
	org $039E12			; dino fire tile table
		db $F0,$F2,$F4,$F6
		db $FF			; unused?
		db $F8,$FA,$FC,$FE
		db $FF			; unused?
					; C4 -> 04
					; C6 -> 06
					; AA -> 02
					; EA -> 00
					; AC -> 08
	org $039E21			; dino torch tile table
		db $00,$02,$04,$06
					; C0 -> 00
					; C2 -> 02
					; E0 -> 04
					; E2 -> 06
					; E4 -> 08
					; E6 -> 0A
					; C8 -> 0C
					; CA -> 0E
					; E8 -> 20
					; CC -> 22
					; CE -> 24
					; EC -> 26
					; EE -> 28
	org $039E39			; dino rhino tile table
		db $00,$02,$08,$0A
		db $00,$02,$04,$06
		db $0C,$0E,$20,$06
		db $22,$24,$26,$28
	org $039E96
		JSL .Remap		; source: INY #4 (dino rhino)
	org $039F1B
		JSL .RemapDinoFire	; source: INY #4 (dino torch)

	org $03A0D4
		JML .Blargg		; source: STA !OAM+$102,y : LDX $02
		NOP
	org $03A0DC
	.ReturnBlargg

	org $03C247
		LDA #$6C : STA !OAM+$102,y	; use tile 0x06E for spotlight switch
		LDA !OAM+$103,y
		AND #$BE

	org $03C2B3
		JSL .Chainsaw		; source: LDA $C25B,x : STA !OAM+$102,y
		NOP #2
	org $03C2BA
		NOP #2
		STA !OAM+$106,y
		DEC #2
		STA !OAM+$10A,y
		LDA $0F

	org $03C4CD
		JSL .Remap2		; source: TYA : LSR #2 : TAY (spotlight)

	org $038D54
		JSL .Remap		; source: INY #4 (carrot platform)

	org $038E60
		JSL .Remap		; source: INY #4 (timed platform)

	pullpc
	.Remap
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLX
		INY #4
		RTL

	.Remap2
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLX
		TYA
		LSR #2
		TAY
		RTL

	.Remap3		; uses hi prio OAM
		PHX
		LDX !SpriteIndex
		LDA !OAM+$002,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$003,y
		PLX
		TYA
		LSR #2
		TAY
		RTL


	.PlantStalk
		AND #$C0
		ORA #$1A
		ORA !Prop_PlantStalk
		STA !OAM+$107,y
		LDA !Tile_PlantStalk
		STA !OAM+$106,y
		LDA $3200,x
		CMP #$1A : BEQ +
		LDA !OAM+$108,y : STA !OAM+$104,y
		LDA !OAM+$109,y : STA !OAM+$105,y
		PHY
		TYA
		LSR #2
		TAY
		LDA !OAMhi+$42,y : STA !OAMhi+$41,y
		PLY
		LDA #$F0 : STA !OAM+$109,y

	+	RTL

	.GrowingVine
		LDA $14
		LSR #4
		PHP
		LDA !OAM+$103,y
		AND #$CE
		ORA #$20
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !OAM+$101,y
		SEC : SBC #$04
		STA !OAM+$101,y
		LDA !SpriteTile,x
		PLP
		RTL


	.DryBones
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CMP #$0A : BNE +
		LDA !Tile_Bone
		INC #2
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		ORA !Prop_Bone
		BRA ++

	+	CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
	++	STA !OAM+$103,y
		PLX
		INY #4
		RTL


	.SkeletonRubble
		PHY
		LDY $33B0,x
		LDA !OAM+$103,y
		AND #$FE
		ORA !Prop_SkeletonRubble
		STA !OAM+$103,y
		PLY
		LDA !Tile_SkeletonRubble
		CLC : ADC #$04			; extra +1 because of how tiles are ordered
		STA $0F				; store this in RAM for later
		SEC : SBC #$03
		CPY #$10
		RTL



	.StatueFix
		JSR SUB_HORZ_POS
		TYA : STA $3320,x
		PEA.w .ReturnStatue-1
		JML $0183A4



	.BooStream1
		PHX
		TXA
		AND #$0B
		TAX
		LDA $8CB8,x : STA !OAM+$002,y
		PLX
		RTL

	.BooStream2
		LDA !GFX_Boo
		ASL A
		ROL A
		AND #$01
		STA $00
		LDA !GFX_Boo
		AND #$70
		ASL A
		STA $01
		LDA !GFX_Boo
		AND #$0F
		ORA $01
		CLC : ADC !OAM+$002,y
		STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$F0
		ORA !Ex_Palset,x
		ORA $00
		STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		RTL

	.BooStreamHead
		TAX
		LDA $8F6D,x
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		PLX
		RTL

	.BrickBridge
		LDA $64
		ORA $33C0,x
		STA !OAM+$10F,y
		RTL


	.AngelWings
		LDA !OAM+$102,y
		CLC : ADC !Tile_AngelWings
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !Prop_AngelWings
		STA !OAM+$103,y
		TYA
		LSR #2
		TAY
		RTL

	.ClimbingDoor
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !SpriteProp,x
		ORA #$08
		STA $0F
		LDA $06 : BEQ +			; idk why but i have to manually remove extra tiles here
		LDX $07
		CMP #$02 : BEQ ++
		CPX #$03 : BCS +
		BRA +++
	++	CPX #$06 : BCS +
	+++	LDA #$F0 : STA !OAM+$101,y

	+	PLX
		INY #4
		RTL

	.ChainPlatform1
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA #$30
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLX
		INY #4
		RTL

	.Key
		LDY $33B0,x
		LDA !OAM+$102,y
		CMP #$FF : BNE +
		LDY !OAMindex
		LDA !SpriteTile,x : STA !OAM-2,y
		JML $01A228

	+	LDA !SpriteTile,x : STA !OAM+$102,y
		JML $01A228

	.PSwitch
		LDY $33B0,x		; see Fe26 carryable item fix and SpriteSubRoutines for more info
		LDA !OAM+$102,y
		CMP #$FF : BNE +
		PHY
		LDY !OAMindex
		LDA !SpriteTile,x
		STA !OAM-$02,y
		PLY
		RTL

	+	LDA !SpriteTile,x
		RTL

	.Smushed
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !OAM+$107,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$107,y
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$106,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		TYA
		LSR #2
		TAY
		RTL


	.Thwomp
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA !SpriteProp,x
		ORA $33C0,x
		STA !OAM+$103,y
		PLX
		INY
		RTL

	.FlyingBlocks
		CMP #$00 : BEQ +
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		BRA ++
	+	LDA !SpriteTile,x : STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
	++	STA !OAM+$103,y
		JML $01AE90		; go to RTS


	.Plat
		LDA $33C0,x : BNE +
	;	ORA !Pal8
	+	ORA $64
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		STA !OAM+$107,y
		STA !OAM+$10B,y
		STA !OAM+$10F,y
		STA !OAM+$113,y
		JML .ReturnPlat


	.OrangePlat
		LDA $B383,x
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA #$01 : TRB $03
		LDA !SpriteProp,x
		TSB $03

		LDA !SpriteTile,x : STA $0E	; save numbers in RAM for later
		CLC : ADC #$03
		STA $0F
		PLX
		RTL

	.MagikoopaMagic
		LDA !SpriteTile,x		;\
		CLC : ADC #$0A : STA $00	; |
		INC A				; | tile numbers in RAM
		STA $01				; |
		CLC : ADC #$0F			; |
		STA $02				;/
		LDA $33C0,x			;\
		ORA $64				; | get prop
		AND #$FE			; |
		ORA !SpriteProp,x		;/
		RTL
	.MagikoopaWand
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$10B,y
		LDA #$1B
		CLC : ADC !SpriteTile,x
		RTL


	.Powerups
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$103,y
		RTL


	.Parachute
		STA $3320,x
		LDA !SpriteTile,x : PHA
		LDA !SpriteProp,x : PHA
		LDA !Tile_Parachute : STA !SpriteTile,x
		LDA !Prop_Parachute : STA !SpriteProp,x
		JSL $0190B2					; wrapper for JSR $9F0D
		PLA : STA !SpriteProp,x
		PLA : STA !SpriteTile,x
		RTL
	.ParachuteBody
		LDA $D5B0,y
		JML $0190B2


	.Explosion
		SEC
		ROL A
		ORA $64
		AND #$FE
		ORA !Prop_BombStar
		PHA
		LDA !OAM+$102,y
		CLC : ADC !Tile_BombStar
		STA !OAM+$102,y
		PLA
		RTL


	.HammerBroIndex
		LDA !SpriteTile,y : STA !SpriteTile,x
		LDA !SpriteProp,y : STA !SpriteProp,x
		LDA $3240,x
		SBC #$00
		RTL


	.WingedPlatform
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CMP #$6E : BEQ ..block
		CMP #$02 : BNE +
		PHA
		LDA !OAM+$100,y
		SEC : SBC #$04
		STA !OAM+$100,y
		BRA ++
	+	PHA
		LDA !OAM+$101,y
		CLC : ADC #$06
		STA !OAM+$101,y
	++	PLA
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA #$0A			; demon wings always use green palset
		ORA !SpriteProp,x
		STA !OAM+$103,y
	+	PLX
		INY #4
		RTL

		..block
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		STA !OAM+$103,y
		PLX
		INY #4
		RTL

	.BooBlock
		PHA
		LDA !SpriteProp,x
		ORA $33C0,x
		STA $00
		LDA !SpriteTile,x
		PLX
		CLC : ADC $FA37,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
	;	ORA $FA3A,x
		ORA $00
		JML .ReturnBooBlock

	.Z
		LDA !GFX_RipVanFish
		ASL A
		ROL A
		AND #$01
		ORA !OAM+$003,y
		STA !OAM+$003,y
		LDA !GFX_RipVanFish
		AND #$70
		ASL A
		STA $00
		LDA !GFX_RipVanFish
		AND #$0F
		ORA $00
		CLC : ADC $8DD7,x
		STA !OAM+$002,y
		RTL

	.TorpedoArm
		LDA !GFX_TorpedoTed
		ASL A
		ROL A
		AND #$01
		ORA !OAM+$003,y
		AND #$F1
		ORA !Ex_Palset,x
		STA !OAM+$003,y
		LDA !GFX_TorpedoTed
		AND #$70
		ASL A
		STA $00
		LDA !GFX_TorpedoTed
		AND #$0F
		ORA $00
		CLC : ADC !OAM+$002,y
		STA !OAM+$002,y
		TYA
		LSR #2
		TAY
		RTL
	.TorpedoTed
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$106,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		STA !OAM+$107,y
		LDA #$01
		LDY #$02
		RTL

	.Hammer
		LDA !Tile_Hammer : STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$3E
		PHX
		LDX $7698
		BIT !Ex_Data3,x
		BPL $02 : ORA #$C0
		BVC $02 : EOR #$40
		PLX
		ORA !Prop_Hammer
		STA !OAM+$003,y
		TYA
		LSR #2
		TAX
		RTL

	.Dolphin
		PHX
		LDX !SpriteIndex
		LDA !SpriteTile,x
		STA $00
		LDA !SpriteProp,x
		ORA $64
		STA $0F
		PLX
		LDA $BC0E,x
		CLC : ADC $00
		STA !OAM+$102,y
		LDA $BC10,x
		CLC : ADC $00
		STA !OAM+$106,y
		LDA $BC12,x
		CLC : ADC $00
		STA !OAM+$10A,y
		JML .ReturnDolphin


	.Fuzzy
		PHX
		LDX !SpriteIndex
		LDA !SpriteTile,x : STA !OAM+$102,y
		LDA !SpriteProp,x
		ORA $64
		STA $0F
		PLX
		RTL

	.Sparky
		LDA $14
		AND #$0C
		ASL A
		RTL

	.Hothead
		LDA !SpriteProp,x
		ORA #$04
		STA $0F
		LDA !SpriteTile,x
		LDY $32F0,x
		CLC
		RTL


	.Urchin
		PHX
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLX
		INY
		RTL

	.BulletBillAntiFail
		PHY
		LDA #$0E : JSL LoadPalset
		PLY
		LDA $8FC7,y
		AND #$40
		LSR A
		ORA !GFX_status+$18E
		ASL A
		STA $33C0,x
		RTL


	.Pipe
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		STA !OAM+$107,y
		JML .ReturnPipe

	.BallAndChain1
		PHA
		LDA !SpriteProp,x
		ORA $33C0,x
		ORA #$30
		STA $0F
		LDA !SpriteTile,x
		PLX
		CPX #$9E
		RTL
	.BallAndChain2
		LDA $D80F,x
		AND #$F0
		PHX
		LDX !SpriteIndex
		ORA !SpriteProp,x
		ORA $33C0,x
		STA !OAM+$103,y
		LDA #$02
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		PLX
		JML .ReturnBall

	.LakituCloud
		LDA $64
		AND #$FE
		STA !OAM+$103,y
		RTL
	.LakituCloudSize
		LDA $32D0,x : BEQ ++
		CMP #$08 : BCS ++
		LDY $33B0,x
		CPY #$F8 : BNE +
		DEY #4
	+	LDA !OAM+$100,y
		CLC : ADC #$04
		STA !OAM+$100,y
		LDA !OAM+$104,y
		CLC : ADC #$04
		STA !OAM+$104,y
		LDA !OAM+$101,y
		CLC : ADC #$04
		STA !OAM+$101,y
		LDA !OAM+$105,y
		CLC : ADC #$04
		STA !OAM+$105,y
		LDY #$00
		LDA #$01
		RTL
	++	LDY #$02
		LDA #$01
		RTL
	.LakituCloudFace
		LDY !OAMindex
		STA !OAM+$000,y
		TYA
		CLC : ADC #$0C
		STA !OAMindex
		LDA $74B2
		CLC : ADC #$07
		STA !OAM+$001,y
		PHY
		PHX
		LDX $78B6
		LDA !OAM+$100,x : STA !OAM+$004,y
		LDA !OAM+$101,x : STA !OAM+$005,y
		LDA !OAM+$102,x : STA !OAM+$006,y
		LDA !OAM+$103,x : STA !OAM+$007,y
		LDA !OAM+$104,x : STA !OAM+$008,y
		LDA !OAM+$105,x : STA !OAM+$009,y
		LDA !OAM+$106,x : STA !OAM+$00A,y
		LDA !OAM+$107,x : STA !OAM+$00B,y
		LDA #$F0
		STA !OAM+$101,x
		STA !OAM+$105,x
		TXA
		LSR #2
		TAX
		TYA
		LSR #2
		TAY
		LDA !OAMhi+$40,x : STA !OAMhi+$01,y
		LDA !OAMhi+$41,x : STA !OAMhi+$02,y
		PLX
		PLY
		RTL
	.PipeLakitu
		PHA
		LDA !SpriteTile,x
		PLX
		PHA
		CLC : ADC $E9E6,x
		STA !OAM+$102,y
		PLA
		CLC : ADC $E9E9,x
		STA !OAM+$106,y
		PLX
		LDA $3320,x
		LSR A
		ROR A
		LSR A
		EOR #$5B
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
		JML .ReturnPipeLakitu
	.LakituRod
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA #$08
		STA !OAM+$103,y
		LDA #$01
		LDY #$02
		RTL




	.MultiplyFix
		STA $2253
		STZ $2254
		NOP
		BRA $00
		ASL $2306
		LDA $2307
		ADC #$00
		JML .CODE_02D6C6

	.ChainPlatform2
		PHX
		LDX !SpriteIndex
		LDA $3200,x
		CMP #$A3 : BNE +
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
	+	PLX
		INY #4
		RTL



	.BubbleCarrier
		LDA !OAM+$102,y
		CMP #$03 : BCS +
		JMP .Remap
	+	LDA !OAM+$103,y
		AND #$FE
		STA !OAM+$103,y
		INY #4
		RTL
	.BubbleCarrierCargo
		PHX
		LDA $BE,x : TAX
		LDA.l ..statustable,x : TAX
		LDA !GFX_status,x
		AND #$70
		ASL A
		STA $0F
		LDA !GFX_status,x
		AND #$0F
		TSB $0F
		LDA !OAM+$102,y
		AND #$7F
		CLC : ADC $0F
		STA !OAM+$102,y
		LDA !GFX_status,x
		ASL A
		ROL A
		AND #$01
		STA $0F
		LDA !OAM+$103,y
		AND #$FE
		ORA $0F
		STA !OAM+$103,y
		PLX
		LDA $32C0,x
		CMP #$60
		RTL

		..statustable
		db $03,$01,$45,$FE



	.Skull
		ADC !SpriteTile,x
		PHA
		LDA !OAM+$103,y
		AND #$F0
		LSR A
		ORA !GFX_status+$18E
		ASL A
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLA
		RTL

	.RemapSuperKoopa
		LDA !OAM+$102,y
		CMP #$40 : BCS +
		JMP .Remap
	+	LDA !GFX_Koopa
		ASL A
		AND #$F0
		STA $0F
		LDA !GFX_Koopa
		AND #$0F
		ORA $0F
		CLC : ADC !OAM+$102,y
		STA !OAM+$102,y
		LDA !GFX_Koopa
		ASL A
		ROL A
		AND #$01
		STA $0F
		LDA !OAM+$103,y
		AND #$FE
		ORA $0F
		STA !OAM+$103,y
		INY #4
		RTL


	.WigglerFlower
		LDA !GFX_Wiggler
		AND #$70
		ASL A
		STA $00
		LDA !GFX_Wiggler
		AND #$0F
		ORA $00
		CLC : ADC #$18
		STA !OAM+$002,y
		LDA !GFX_Wiggler
		ASL A
		ROL A
		AND #$01
		ORA $64
		JML .ReturnWigglerFlower
	.Wiggler
		PHX
		LDX !SpriteIndex
		LDA $07				;\
		AND #$FE			; | set prop
		ORA !SpriteProp,x		; |
		STA $07				;/
		LDA !SpriteTile,x		;\ set up loop
		PHA				;/
		CLC : ADC #$08			;\ store eye tile for later
		STA $0F				;/
		CLC : ADC #$10			;\ store flower tile for later
		STA $0E				;/
		LDX #$03			;\
	-	PLA : PHA			; | build tilemap in RAM
		CLC : ADC $F10C,x		; |
		STA !BigRAM,x			; |
		DEX : BPL -			; |
		PLA				;/
		PLX				;
		CPX #$00			; overwritten code
		RTL

	.LotusFire
		LDA !Tile_LotusPollen
		CLC : ADC !OAM+$002,y
		STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$F0
		ORA !Ex_Palset,x
		ORA !Prop_LotusPollen
		STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		RTL
	.VolcanoLotus
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$106,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		LDA !OAM+$10A,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$10A,y
		LDA !OAM+$10E,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$10E,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !OAM+$107,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$107,y
		LDA !OAM+$10B,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$10B,y
		LDA !OAM+$10F,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$10F,y
		LDA $33B0,x
		CLC
		RTL

	.ScalePlat
		LDA !SpriteProp,x
		ORA $64
		STA $0F
		LDA !SpriteTile,x : STA !OAM+$102,y
		RTL

	.BirdINIT
		PHA
		LDA !ExtraBits,x : BMI ..main
		ORA #$80
		STA !ExtraBits,x
		LDA $3220,x
		LSR #4
		AND #$03		; set color based on initial Xpos
		STA $3280,x
		TXA
		ASL #3
		CLC : ADC !RNG
		AND #$1F
		ORA #$20
		STA $35A0,x		; max panic timer
		STA $35B0,x		; panic timer
		..main
		PLA : BEQ .02F321
		LDA #$04
	.02F31E	JML $02F31E
	.02F321	JML $02F321

	.BirdMAIN
		LDA $35D0,x : BNE ..panic
		LDA $35B0,x : BEQ ..panic
		CMP $35A0,x : BEQ ..normal
		DEC $35B0,x
		JMP ..notseen

		..panic
		LDA #$01 : STA $35D0,x
		JSR SUB_HORZ_POS
		TYA
		EOR #$01
		STA $3320,x
		TAY
		LDA.w .BirdFlyX,y : BPL ..pos
	..neg	BIT $AE,x : BPL ..dec
		CMP $AE,x : BEQ ..good
		BCC ..dec
		BRA ..inc
	..pos	BIT $AE,x : BMI ..inc
		CMP $AE,x : BEQ ..good
		BCS ..inc
	..dec	DEC $AE,x : DEC $AE,x
	..inc	INC $AE,x
	..good	LDA #$F0 : STA $9E,x
		TXA
		CLC : ADC $14
		AND #$04
		LSR #2
		ORA #$02
		STA $33D0,x

		..return
		JML $02F33B		; go to RTS

		..normal
		LDA $3220,x
		SEC : SBC #$40
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$40
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$80
		STA $06
		STA $07
		SEC : JSL !PlayerClipping
		BCS ..seen
		JSR FireballContact
		BCS ..seen
		LDA $3200,x : STA !BigRAM
		PHX
		LDX #$0F
	-	CPX !SpriteIndex : BEQ +
		LDA $3200,x
		CMP !BigRAM : BEQ +
		LDA $3230,x
		CMP #$02 : BEQ ++
		CMP #$08 : BCC +
	++	JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC +
		PLX
		BRA ..seen
	+	DEX : BPL -
		PLX
		BRA ..notseen
		..seen
		LDY #$0F		; start the panic for nearby birds
	-	CPY !SpriteIndex : BEQ +
		LDA $3200,y
		CMP $3200,x : BNE +
		LDA $3230,y
		CMP #$08 : BNE +
		LDA $35B0,y
		DEC A
		STA $35B0,y
	+	DEY : BPL -
		JMP ..panic
		..notseen
		JML .ReturnBirdMAIN

	.BirdGFX
		REP #$20
		LDA #$0004 : STA !BigRAM+$00
		LDA.w #!BigRAM : STA $04
		LDA #$0800 : STA !BigRAM+$03
		SEP #$20
		LDY $33D0,x
		LDA $F3DB,y
		CLC : ADC !SpriteTile,x
		STA !BigRAM+$05
		LDA $02
		AND #$3E
		ORA !SpriteProp,x
		STA !BigRAM+$02
		JSR LOAD_TILEMAP_HiPrio
		LDA !OAMindex
		LSR #2
		DEC A
		TAY
		LDA !OAMhi,y
		AND #$01
		STA !OAMhi,y
		JSR SPRITE_OFF_SCREEN		; despawn if necessary
		JML $02F42B			; go to RTS

	.Blurp
		LDA !OAM+$103,y
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA $14
		AND #$10
		BEQ $02 : LDA #$02
		CLC : ADC !SpriteIndex
		AND #$02
		ADC !SpriteTile,x
		JML .ReturnBlurp

	.MoleAntiFail
		ORA #$30
		LSR A
		ORA !GFX_status+$190
		ASL A
		STA $33C0,x
		RTL


	.Swooper
		PLX
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !OAM+$101,y
		DEC A
		STA !OAM+$101,y
		JML .ReturnSwooper


	.BouncingPodoboo
		AND #$30
		ORA $00
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		RTL


	.FishingBoo
		LDA !OAM+$102,y
		CMP #$60 : BEQ +
		JMP .Remap
	+	INY #4
		RTL


	.Spike
		LDA !SpriteTile,x : STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA $33C0,x
		ORA !SpriteProp,x
		STA !OAM+$103,y
		RTL

	.EatingBlock
		AND #$3E
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !SpriteTile,x : STA !OAM+$102,y
		RTL

	.Fishbone
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !SpriteTile,x : STA $0E	;\
		LDA !SpriteProp,x : STA $0F	; |
		PHX				; |
		LDX #$03			; |
	-	LDA $9784,x			; |
		AND #$FE			; | build tilemap in RAM
		ORA $0F				; |
		STA !BigRAM,x			; |
		LDA $9788,x			; |
		CLC : ADC $0E			; |
		STA !BigRAM+4,x			; |
		DEX : BPL -			; |
		PLX				;/
		PEA.w $97A4-1
		JML $03B760

	.BowserBall
		PHX
		LDX #$0F
	-	CPX !SpriteIndex : BEQ +
		LDA $3230,x
		CMP #$08 : BNE +
		LDA $3470,x
		AND #$02 : BNE +
		JSL !GetSpriteClipping00
		JSL !CheckContact
		BCC +
		LDA #$04 : STA $3230,x
		LDA #$1F : STA $32D0,x
		LDA #$08 : STA !SPC1
	+	DEX : BPL -
		PLX
		RTL

	.Mechakoopa
		PHX
		LDX !SpriteIndex
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		PLX
		DEY #4
		RTL
	.MechakoopaKey
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDY #$00
		LDA #$00
		RTL


	.DinoSmushed
		LDY $33B0,x
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !SpriteTile,x
		CLC : ADC #$08
		RTL

	.RemapDinoFire
		LDA !OAM+$102,y
		CMP #$F0 : BCS +
		JMP .Remap		; remap dino torch normally
	+	AND #$0F
		CLC : ADC !Tile_DinoFire
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !Prop_DinoFire
		STA !OAM+$103,y
		INY #4
		RTL


	.Blargg
		LDX !SpriteIndex
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !SpriteProp,x
		LDX $02
		ORA $A09B,x
		JML .ReturnBlargg


	.RemapMechanism
		CPX #$00 : BEQ +
		JMP .Remap
	+	LDA !OAM+$102,y
		CLC : ADC !Tile_Mechanism
		STA !OAM+$102,y
		LDA !OAM+$103,y
		AND #$F0
		ORA #$06			; mechanism always uses blue palset
		ORA !Prop_Mechanism
		STA !OAM+$103,y
		PHX
		LDX !SpriteIndex
		LDA !SpriteTile,x
		INC #2
		STA $0F
		PLX
		INY #4
		RTL
	.Chainsaw
		LDA $C25B,x
		PHX
		CLC : ADC !Tile_Mechanism
		LDX !SpriteIndex
		STA !OAM+$102,y
		LDA #$36
		ORA !Prop_Mechanism
		STA $0F
		LDA #$0F : TRB $04
		LDA !SpriteProp,x
		ORA $33C0,x
		TSB $04
		LDA !SpriteTile,x
		INC #2
		PLX
		RTL


	Chuck:
	pushpc
	org $02BFC3			; reroute this so we can hijack $02C829 for the chuck tilemap
		JML .Remap_02C82B	; source: LDY #$02 : JMP $C82B
		NOP


	org $02C829
		JSL .Main		; source: LDY #$FF : LDA #$04


				; 06 -> 00
				; 0A -> 02
				; 0E -> 04
				; 4B -> 06
	org $02C87E		; chuck head tile table
		db $00,$02,$04,$02
		db $00,$06,$06
	warnpc $02C885
				; 20 -> 08
				; 21 -> 09
				; 23 -> 0B
				; 24 -> 0C
				; 26 -> 0E
				; 28 -> 20
				; 29 -> 21
				; 2D -> 23
				; 40 -> 25
				; 42 -> 27
				; 44 -> 29
				; 4E -> 2E
				; 64 -> 40
				; A0 -> 42
				; A2 -> 44
				; A4 -> 46
				; AE -> 48
				; CB -> 4A
				; CC -> 4B
				; E7 -> 64
				; E8 -> 65
				; 82 -> 4D
				; 83 -> 4E
				; 0C -> 2B
				; 0D -> 2C
				; 1C -> 3B
				; 1D -> 3C
				; BD -> 2D
				; 5D -> 3D
	org $02C98B		; chuck body tile table 1
		db $2C,$1C,$1D,$0E,$23,$20,$25,$27
		db $3D,$23,$40,$40,$40,$40,$64,$20
		db $4D,$4A,$0B,$08,$2C,$2B,$3D,$2D
		db $2D,$3D
	org $02C9A5		; chuck body tile table 2
		db $2E,$2B,$0A,$0E,$23,$21,$25,$27
		db $48,$23,$40,$40,$40,$40,$65,$21
		db $4E,$4B,$0C,$09,$2E,$42,$42,$44
		db $46,$48
	warnpc $02C9BF
	org $02CA97		; clappin chuck tile table
		db $2B,$29
	org $02CAFA
		db $4B,$0B	; arm prop (use same palette as rest of chuck)
	org $02CB16
		LDA #$3B	; chuck arm tile 1
	org $02CB7B
		LDA #$67	; (non-dynamic) baseball is tile 0x67 in chuck's file
	org $02CB9B		; diggin chuck tile table
		db $77,$62,$60
	pullpc
	.Remap_02C82B
		LDY #$02	; overwritten code
		LDA #$04	;\ code from $02C82B, which is hijacked by chuck
		JML $02B7A7	;/

	.Main
		LDY $33B0,x
		LDA !OAM+$102,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$102,y
		LDA !OAM+$106,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$106,y
		LDA !OAM+$10A,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$10A,y
		LDA !OAM+$10E,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$10E,y
		LDA !OAM+$112,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$112,y
		LDA !OAM+$116,y
		CLC : ADC !SpriteTile,x
		STA !OAM+$116,y
		LDA !OAM+$103,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$103,y
		LDA !OAM+$107,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$107,y
		LDA !OAM+$10B,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$10B,y
		LDA !OAM+$10F,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$10F,y
		LDA !OAM+$113,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$113,y
		LDA !OAM+$117,y
		AND #$FE
		ORA !SpriteProp,x
		STA !OAM+$117,y
		LDY #$FF
		LDA #$04
		RTL

		; face
		; C0 -> 20
		; C2 -> 22
		; E0 -> 24
		; E2 -> 26
		; body
		; 80 -> 00
		; 82 -> 02
		; 84 -> 04
		; 86 -> 06
		; A0 -> 08
		; A2 -> 0A
		; A4 -> 0C
		; A6 -> 0E
		; C4 -> 28
		; C6 -> 2A
		; E4 -> 2C
		; E6 -> 2E
		; hand
		; E8 -> 40
	pushpc
	org $0382F8		; big boo tile table
		db $20,$24,$40,$00,$08,$08,$00,$02
		db $0A,$0A,$02,$04,$0C,$28,$2C,$06
		db $0E,$2A,$2E,$40,$20,$24,$40,$00
		db $08,$08,$00,$02,$0A,$0A,$02,$04
		db $0C,$28,$2C,$06,$0E,$2A,$2E,$40
		db $20,$24,$40,$00,$08,$08,$00,$02
		db $0A,$0A,$02,$04,$0C,$0C,$04,$06
		db $0E,$0E,$06,$40,$40,$40,$22,$26
		db $00,$08,$08,$00,$02,$0A,$0A,$02
		db $04,$0C,$28,$2C,$06,$0E,$2A,$2E
	warnpc $038348		; don't go into prop table
	org $038422
		JSL SpecificSimple_Remap	; source: INY #4 (big boo)
	org $07F3FE+$28
		db $0C			; big boo tweaker 3
	org $07F3FE+$C5
		db $0C			; big boo boss tweaker 3
	pullpc


	Smushed:
	pushpc
	org $01E728
		LDA #$12
		CPX #$BD
	pullpc




	Extended:
;	pushpc
;	org $02A240
;		JSL .TinyFlame		; source: LDA $A217,x : STA !OAM+$002,y
;		RTS
;		NOP
;
;	pullpc
;	.TinyFlame
;		LDA !GFX_HoppingFlame
;		PHP
;		PHA
;		AND #$70
;		ASL A
;		STA $00
;		PLA
;		AND #$0F
;		ORA $00
;		CLC : ADC $A217,x
;		STA !OAM+$002,y
;		LDA !OAM+$003,y
;		LDX $75E9
;		AND #$30
;		ORA !Ex_Palset,x
;		PLP
;		BPL $02 : ORA #$01
;		STA !OAM+$003,y
;		RTL


	Pal8Remap:

	pushpc
	org $019F48
		;JML .Generic		; Org:
		;STA !OAM+$103,y : TYA
	.ReturnMonty

	org $01B359
		;JML .Platforms		; Org:
		;LDA $64 : ORA $33C0,x
		;NOP
	.ReturnPlatforms

	org $01C65C
		;JML .Coin		; Org:
		;STA $6303,y : TXA
	.ReturnCoin

	org $02901D
		;JML .Brick		; Org:
		;STA !OAM+$003,y : LDX $7698
		;NOP #2
	.ReturnBrick



	org $029246
		;JML .Bounce		; Org:
		;LDA $7901,x : ORA $64
		;NOP
	.ReturnBounce

	org $07F790
		;LDA $07F3FE,x

	org $07F7B3
		;LDA $07F3FE,x


	FusionCoreRemap:
	; -- minor extended --
	org $028B84
		db $44,$54,$54,$44,$44,$54,$54,$44	; brick tiles that STEAR won't find
	org $029023
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (brick piece)
	org $028F21
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (small sparkle)
	org $028F7D
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (fire particle)
	org $028E69
	;	JSL .Remap2				; source: TYA : LSR #2 : TAY (Z)
	org $028DC6
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (water splash)
	org $028D38
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (boo stream)


	; -- extended --
	;org $02A3A1
	;	JSL .Remap2				; source: TYA : LSR #2 : TAY (puff of smoke)
	;org $02A199
	;	JSL .RemapReznorFireball		; source: TYA : LSR #2 : TAX (reznor fireball)
	;	LDA #$02 : STA !OAMhi+$00,y		; use Y instead of X
	;org $02A2B5
	;	JSL .Baseball				; source: TYA : LSR #2 : TAY (baseball)
	;org $029C9C
	;	JSL .SpinJumpStar			; source: LDA !Ex_Data2,x : LSR A


	; -- smoke --
	;org $029995
	;	JSL .Remap				; source: TYA : LSR #2 : TAY (turn smoke)


	; -- bounce --
	org $029258
		JSL .Remap2				; source : TYA : LSR #2 : TAY (bounce)


	; -- coin --
	org $029A5A
		JSL .Remap				; source: TYA : LSR #2 : TAY (coin)


	pullpc
	.Remap		; works for TYA : LSR #2 : TAY hooks, though X must be the sprite index
		LDA !OAM+$003,y
		AND #$F0
		ORA !Ex_Palset,x
		STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		RTL

	.Remap2		; works for TYA : LSR #2 : TAY hooks, ignores input X
		PHX
		LDX $7698
		LDA !OAM+$003,y
		AND #$F1
		ORA !Ex_Palset,x
		STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		PLX
		RTL

	.RemapReznorFireball
		LDX $7698
		TXA
		AND #$01
		BEQ $02 : LDA #$C0
		BIT !Ex_XSpeed,x
		BMI $02 : EOR #$40
		ORA !Ex_Palset,x
		ORA !Prop_ReznorFireball
		STA !OAM+$003,y
		LDA !Tile_ReznorFireball : STA !OAM+$002,y
		TYA
		LSR #2
		TAY
		RTL

	.Baseball
		LDA !Tile_Baseball : STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$F0
		ORA !Ex_Palset,x
		ORA !Prop_Baseball
		STA !OAM+$003,y
		TYA
		LSR #2
		TAY
		RTL

	.SpinJumpStar
		LDA !OAM+$003,y
		AND #$F0
		ORA !Ex_Palset,x
		STA !OAM+$003,y
		LDA !Ex_Data2,x
		LSR A
		RTL




	GoombaWings:
	pushpc
	org $018E2E
		JML .Main		; org: STA !OAM+$102,y : PHY
	.Return
	org $018E36
		LDA $8DE5,x		; org: LDA $8DE5,x
	org $018E42
		LDA $0F			;\ org: LDA $8DDF,x
		NOP			;/
	pullpc
	.Main
		CMP #$C0
		LDA !Tile_AngelWings
		BCS $02 : INC #2
		STA !OAM+$102,y
		PHX
		LDX $03
		LDA $8DDF,x
		AND #$FE
		ORA !Prop_AngelWings
		STA $0F
		PLX
		PHY
		JML .Return






;	MarioFireball:
;	pushpc
;	org $02A080
;		JSL .Main
;	org $02A087
;		LDA #$00				;\ org: LDA $A15F,x
;		NOP					;/
;	org $02A1E8
;		JSL .Main
;	org $02A1EF
;		LDA #$00				;\ org: LDA $A15F,x
;		NOP					;/
;	pullpc
;	.Main
;		PHA
;		LDA !Ex_Num,x				;\
;		AND #$7F				; | bubble
;		CMP #$12+!ExtendedOffset : BEQ .Nope	;/
;
;		TXA
;		AND #$01
;		BEQ $02 : LDA #$C0
;		ORA !Prop_SmallFireball
;		BIT !Ex_XSpeed,x
;		BPL $02 : EOR #$40
;		STA $00
;		PLX
;		LDA !Tile_SmallFireball
;		RTL
;
;	.Nope	PLX
;		LDA $A15B,x
;		RTL

;	Bone:
;	pushpc
;	org $02A2C9
;		JSL .Main	;\
;		STA !OAM+$002,y	; | source: CMP #$26 : LDA #$80 : BCS $02 : LDA #$82 (not good due to remap)
;		RTS		;/
;	pullpc
;	.Main
;		TXA
;		AND #$01
;		BEQ $02 : LDA #$C0
;		BIT !Ex_XSpeed,x
;		BMI $02 : EOR #$40
;		ORA !Ex_Palset,x
;		ORA !Prop_Bone
;		ORA $64
;		STA !OAM+$003,y
;		LDA #$00 : STA $0F
;		CLC : ADC !Tile_Bone
;		RTL

	TinySparkle:
	pushpc
	org $028ECC
		db $5D,$5A,$58
	pullpc


;	WaterSplash:
;	pushpc
;	org $028DB6
;		JSL .Main		;\ source: LDA $8D42,x : LDX $7698
;		NOP #2			;/
;		STA !OAM+$002,y
;		LDA $64
;		ORA $0F			; source: ORA #$02
;		STA !OAM+$003,y
;		TYA
;		LSR #2
;		TAY
;		LDA $0E			; source: LDA #$02
;	org $028D42			; water splash tile table
;		db $00,$00,$02,$02,$02	; $68 -> $00, $6A -> $02
;	pullpc
;	.Main
;		LDA #$02 : STA $0E	; tile size = 16x16
;		STZ $0F
;		CPX #$05 : BCS +	; some tiles are in SP1
;		LDA !Prop_WaterEffects
;		STA $0F
;	+	LDA $8D42,x
;		LDX $7698		; overwritten code
;		CMP #$66 : BNE +	;\
;		LDA !OAM+$000,y		; |
;		CLC : ADC #$04		; |
;		STA !OAM+$000,y		; | replace tile 0x66 with an 8x8 version
;		LDA !OAM+$001,y		; |
;		CLC : ADC #$04		; |
;		STA !OAM+$001,y		; |
;		LDA #$5E		;/
;		STZ $0E			; tile size = 8x8
;		RTL
;	+	CMP #$60 : BCS +
;		ADC !Tile_WaterEffects	; only add offset for the actual water tiles
;	+	RTL


	Bubble:
	pushpc
	org $029F5B
		JSL .Main		; source: LDA #$1C : STA !OAM+$002,y
		RTS
	pullpc
	.Main
		LDA #$04
		CLC : ADC !Tile_WaterEffects
		STA !OAM+$002,y
		LDA !OAM+$003,y
		AND #$F0
		PHX
		LDX $7698
		ORA !Ex_Palset,x
		PLX
		ORA !Prop_WaterEffects
		STA !OAM+$003,y
		RTL


;	LavaSplash:
	pushpc
;	org $028F6C
;		JSL .Main		; source: TAX : LDA $8F2B,x
;		STA !OAM+$002,y
;		LDA $64
;		ORA $0F
;	org $028F2B			; lava splash tile table
;		db $11,$10,$01,$00
;	org $029ECB
;		JSL .Main		; source: TAX : LDA $9E82,x
;		STA !OAM+$002,y
;		LDA $64
;		ORA $0F			; source: ORA #$05
	org $029E82			; lava splash tile table
		db $11,$10,$01,$00
	pullpc
;	.Main
;		TAX
;		LDA !Prop_LavaEffects
;		STA $0F			; store in RAM for later
;		LDA $9E82,x
;		CLC : ADC !Tile_LavaEffects
;		RTL


;	SmokeAnimation:
;	pushpc
;	org $029740
;		JSL .Main		; source: TYA : LSR #2 : TAY
;		NOP #2			; source: LDA #$02
;	warnpc $029746
;	org $029789
;		JSL .Main		; same as above
;		NOP #2
;	warnpc $02978F
;	pullpc
;	.Main
;		CMP #$66 : BNE .16
;	.8	LDA !OAM+$000,y
;		CLC : ADC #$04
;		STA !OAM+$000,y
;		LDA !OAM+$001,y
;		CLC : ADC #$04
;		STA !OAM+$001,y
;		LDA #$5E : STA !OAM+$002,y
;		TYA
;		LSR #2
;		TAY
;		LDA #$00
;		RTL
;
;	.16	TYA
;		LSR #2
;		TAY
;		LDA #$02
;		RTL


;	SmokeExtended:
;	pushpc
;	org $02A38B
;		JSL .Main		; source: TAX : LDA $A347,x
;	org $02A3A5
;		LDA $0F			; remap tile size to RAM
;	pullpc
;	.Main
;		TAX
;		LDA #$02 : STA $0F
;		LDA $A347,x
;		CMP #$66 : BNE +	; remap tile 0x66 to 8x8 version
;		LDA !OAM+$000,y
;		LDA !OAM+$000,y
;		CLC : ADC #$04
;		STA !OAM+$000,y
;		LDA !OAM+$001,y
;		CLC : ADC #$04
;		STA !OAM+$001,y
;		LDA #$5E
;		STZ $0F
;	+	RTL


;	ContactAnimation:
;	pushpc
;	org $0297EA
;		LDA #$00		; remove x-flip from contact animation
;	org $029803
;		PHX
;		LDA !Ex_Data1,x : TAX
;		LDA.l .Tiles,x
;		PLX
;		STA !OAM+$002,y
;		BRA +
;	warnpc $029815
;	org $029825
;	+	LDA !Ex_Palset,x
;		ORA #$30
;		STA !OAM+$003,y
;		TYA
;		LSR #2
;		TAY
;		LDA #$02 : STA !OAMhi,y
;		RTS
;	warnpc $029837
;	pullpc
;	.Tiles
;		db $6A,$6A,$6A,$68,$68,$68,$66,$66







