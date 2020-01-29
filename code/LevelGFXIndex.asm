

	GFXIndex:
		PHY
		PHP
		REP #$30
		LDX !Level
		LDA LevelIndex,x
		AND #$00FF
		CMP #$00FF : BNE .Upload
		JMP .Return


		.Upload
		ASL A
		TAX
		SEP #$20
		LDA #$80 : STA $2115		; VRAM increment
		STZ $4200			; disable interrupt
		REP #$20			;
		LDA IndexTable,x : STA $0E	;
		LDA ($0E) : STA $02		;\
		INC $0E				; | Set upload starting address
		INC $0E				;/
		LDY #$0000			;

	--	LDA ($0E),y			;\
		AND #$00FF			; | Read index table
		CMP #$00FF : BNE .Ready		; |
		JMP .UploadDone			;/

		.Ready
		ASL A				;\
		TAX				; |
		LDA GraphicsTable,x : STA $0C	; |
		LDA ($0C) : STA $00		; |
		INC $0C				; | Set up dynamo upload
		INC $0C				; |
		PHY
		SEP #$10
		LDA ($0C) : TAY
		BEQ +
		LDA $02
		SEC : SBC #$6000
		LSR #4
		CPY #$01 : BEQ .Koopa		; note: if BEQ triggers, carry is always set
		CPY #$02 : BEQ .Plant		; all of these have base tiles that are not 0x00
		CPY #$05 : BEQ .Hammer
		CPY #$0A : BEQ .LotusF
		CPY #$0B : BEQ .Bump
		CPY #$10 : BEQ .Goomba
		CPY #$12 : BEQ .Monty
		CPY #$16 : BEQ .FireB
		CPY #$17 : BEQ .x2

	.x1	SEC : SBC #$0100
		BRA .stat

	.Koopa	SBC #$00A0
		CMP #$0060 : BCC .x2
		ORA #$0100 : BRA .x2
	.Plant	SBC #$00AC : BRA .x2
	.Hammer	SBC #$014C : BRA .x2
	.LotusF	SBC #$01A6 : BRA .x2
	.Bump	SBC #$0100 : BRA .x2
	.Goomba	SBC #$00A8 : BRA .x2
	.Monty	SBC #$0182 : BRA .x2
	.FireB	SBC #$0008

	.x2	LSR A
	.stat	SEP #$20
		STA !GFX_status,y
	+	REP #$30
		INC $0C

		LDY #$0000			;/
	-	LDA ($0C),y : STA $4305		;\
		INY #2				; |
		LDA ($0C),y : STA $4302		; |
		INY				; |
		LDA ($0C),y : STA $4303		; |
		INY #2				; | Loop and upload GFX
		LDA $02 : STA $2116		; |
		CLC : ADC ($0C),y		; | update VRAM destination
		STA $02				; |
		INY #2				; |
		LDA #$1801 : STA $4300		; |
		LDA #$0001 : STA $420B		; |
		CPY $00 : BNE -			;/
		PLY				;\
		INY				; | Loop for each index table entry
		JMP --				;/

		.UploadDone
		SEP #$20
		LDA #$81 : STA $4200		; enable interrupt

		.Return
		PLP
		PLY
		RTS



	LevelIndex:
	db $FF		; level 000
	db $01		; level 001
	db $01		; level 002
	db $00		; level 003
	db $00		; level 004
	db $00		; level 005
	db $02		; level 006
	db $03		; level 007
	db $05		; level 008
	db $FF		; level 009
	db $06		; level 00A
	db $07		; level 00B
	db $FF		; level 00C
	db $FF		; level 00D
	db $FF		; level 00E
	db $FF		; level 00F
	db $09		; level 010
	db $0B		; level 011
	db $0F		; level 012
	db $0C		; level 013
	db $0E		; level 014
	db $FF		; level 015
	db $FF		; level 016
	db $FF		; level 017
	db $FF		; level 018
	db $FF		; level 019
	db $FF		; level 01A
	db $FF		; level 01B
	db $FF		; level 01C
	db $FF		; level 01D
	db $FF		; level 01E
	db $FF		; level 01F
	db $FF		; level 020
	db $FF		; level 021
	db $FF		; level 022
	db $FF		; level 023
	db $FF		; level 024
	db $FF		; level 025
	db $FF		; level 026
	db $FF		; level 027
	db $04		; level 028
	db $0A		; level 029
	db $00		; level 02A
	db $00		; level 02B
	db $00		; level 02C
	db $FF		; level 02D
	db $00		; level 02E
	db $01		; level 02F
	db $06		; level 030
	db $FF		; level 031
	db $0D		; level 032
	db $FF		; level 033
	db $FF		; level 034
	db $FF		; level 035
	db $FF		; level 036
	db $FF		; level 037
	db $FF		; level 038
	db $FF		; level 039
	db $FF		; level 03A
	db $FF		; level 03B
	db $FF		; level 03C
	db $FF		; level 03D
	db $FF		; level 03E
	db $FF		; level 03F
	db $FF		; level 040
	db $FF		; level 041
	db $FF		; level 042
	db $FF		; level 043
	db $FF		; level 044
	db $FF		; level 045
	db $FF		; level 046
	db $FF		; level 047
	db $FF		; level 048
	db $FF		; level 049
	db $FF		; level 04A
	db $FF		; level 04B
	db $FF		; level 04C
	db $FF		; level 04D
	db $FF		; level 04E
	db $FF		; level 04F
	db $FF		; level 050
	db $FF		; level 051
	db $FF		; level 052
	db $FF		; level 053
	db $FF		; level 054
	db $FF		; level 055
	db $FF		; level 056
	db $FF		; level 057
	db $FF		; level 058
	db $FF		; level 059
	db $FF		; level 05A
	db $FF		; level 05B
	db $FF		; level 05C
	db $FF		; level 05D
	db $FF		; level 05E
	db $FF		; level 05F
	db $FF		; level 060
	db $FF		; level 061
	db $FF		; level 062
	db $FF		; level 063
	db $FF		; level 064
	db $FF		; level 065
	db $FF		; level 066
	db $FF		; level 067
	db $FF		; level 068
	db $FF		; level 069
	db $FF		; level 06A
	db $FF		; level 06B
	db $FF		; level 06C
	db $FF		; level 06D
	db $FF		; level 06E
	db $FF		; level 06F
	db $FF		; level 070
	db $FF		; level 071
	db $FF		; level 072
	db $FF		; level 073
	db $FF		; level 074
	db $FF		; level 075
	db $FF		; level 076
	db $FF		; level 077
	db $FF		; level 078
	db $FF		; level 079
	db $FF		; level 07A
	db $FF		; level 07B
	db $FF		; level 07C
	db $FF		; level 07D
	db $FF		; level 07E
	db $FF		; level 07F
	db $FF		; level 080
	db $FF		; level 081
	db $FF		; level 082
	db $FF		; level 083
	db $FF		; level 084
	db $FF		; level 085
	db $FF		; level 086
	db $FF		; level 087
	db $FF		; level 088
	db $FF		; level 089
	db $FF		; level 08A
	db $FF		; level 08B
	db $FF		; level 08C
	db $FF		; level 08D
	db $FF		; level 08E
	db $FF		; level 08F
	db $FF		; level 090
	db $FF		; level 091
	db $FF		; level 092
	db $FF		; level 093
	db $FF		; level 094
	db $FF		; level 095
	db $FF		; level 096
	db $FF		; level 097
	db $FF		; level 098
	db $FF		; level 099
	db $FF		; level 09A
	db $FF		; level 09B
	db $FF		; level 09C
	db $FF		; level 09D
	db $FF		; level 09E
	db $FF		; level 09F
	db $FF		; level 0A0
	db $FF		; level 0A1
	db $FF		; level 0A2
	db $FF		; level 0A3
	db $FF		; level 0A4
	db $FF		; level 0A5
	db $FF		; level 0A6
	db $FF		; level 0A7
	db $FF		; level 0A8
	db $FF		; level 0A9
	db $FF		; level 0AA
	db $FF		; level 0AB
	db $FF		; level 0AC
	db $FF		; level 0AD
	db $FF		; level 0AE
	db $FF		; level 0AF
	db $FF		; level 0B0
	db $FF		; level 0B1
	db $FF		; level 0B2
	db $FF		; level 0B3
	db $FF		; level 0B4
	db $FF		; level 0B5
	db $FF		; level 0B6
	db $FF		; level 0B7
	db $FF		; level 0B8
	db $FF		; level 0B9
	db $FF		; level 0BA
	db $FF		; level 0BB
	db $FF		; level 0BC
	db $FF		; level 0BD
	db $FF		; level 0BE
	db $FF		; level 0BF
	db $FF		; level 0C0
	db $FF		; level 0C1
	db $FF		; level 0C2
	db $FF		; level 0C3
	db $FF		; level 0C4
	db $FF		; level 0C5
	db $FF		; level 0C6
	db $FF		; level 0C7
	db $FF		; level 0C8
	db $FF		; level 0C9
	db $FF		; level 0CA
	db $FF		; level 0CB
	db $FF		; level 0CC
	db $FF		; level 0CD
	db $FF		; level 0CE
	db $FF		; level 0CF
	db $FF		; level 0D0
	db $FF		; level 0D1
	db $FF		; level 0D2
	db $FF		; level 0D3
	db $FF		; level 0D4
	db $FF		; level 0D5
	db $FF		; level 0D6
	db $FF		; level 0D7
	db $FF		; level 0D8
	db $FF		; level 0D9
	db $FF		; level 0DA
	db $FF		; level 0DB
	db $FF		; level 0DC
	db $FF		; level 0DD
	db $FF		; level 0DE
	db $FF		; level 0DF
	db $FF		; level 0E0
	db $FF		; level 0E1
	db $FF		; level 0E2
	db $FF		; level 0E3
	db $FF		; level 0E4
	db $FF		; level 0E5
	db $FF		; level 0E6
	db $FF		; level 0E7
	db $FF		; level 0E8
	db $FF		; level 0E9
	db $FF		; level 0EA
	db $FF		; level 0EB
	db $FF		; level 0EC
	db $FF		; level 0ED
	db $FF		; level 0EE
	db $FF		; level 0EF
	db $FF		; level 0F0
	db $FF		; level 0F1
	db $FF		; level 0F2
	db $FF		; level 0F3
	db $FF		; level 0F4
	db $FF		; level 0F5
	db $FF		; level 0F6
	db $FF		; level 0F7
	db $FF		; level 0F8
	db $FF		; level 0F9
	db $FF		; level 0FA
	db $FF		; level 0FB
	db $FF		; level 0FC
	db $FF		; level 0FD
	db $FF		; level 0FE
	db $FF		; level 0FF
	db $FF		; level 100
	db $FF		; level 101
	db $FF		; level 102
	db $FF		; level 103
	db $FF		; level 104
	db $FF		; level 105
	db $FF		; level 106
	db $FF		; level 107
	db $FF		; level 108
	db $FF		; level 109
	db $FF		; level 10A
	db $FF		; level 10B
	db $FF		; level 10C
	db $FF		; level 10D
	db $FF		; level 10E
	db $FF		; level 10F
	db $FF		; level 110
	db $FF		; level 111
	db $FF		; level 112
	db $FF		; level 113
	db $FF		; level 114
	db $FF		; level 115
	db $FF		; level 116
	db $FF		; level 117
	db $FF		; level 118
	db $FF		; level 119
	db $FF		; level 11A
	db $FF		; level 11B
	db $FF		; level 11C
	db $FF		; level 11D
	db $FF		; level 11E
	db $FF		; level 11F
	db $FF		; level 120
	db $FF		; level 121
	db $FF		; level 122
	db $FF		; level 123
	db $FF		; level 124
	db $FF		; level 125
	db $FF		; level 126
	db $FF		; level 127
	db $FF		; level 128
	db $FF		; level 129
	db $FF		; level 12A
	db $FF		; level 12B
	db $FF		; level 12C
	db $FF		; level 12D
	db $FF		; level 12E
	db $FF		; level 12F
	db $FF		; level 130
	db $FF		; level 131
	db $FF		; level 132
	db $FF		; level 133
	db $FF		; level 134
	db $FF		; level 135
	db $FF		; level 136
	db $FF		; level 137
	db $FF		; level 138
	db $FF		; level 139
	db $FF		; level 13A
	db $FF		; level 13B
	db $FF		; level 13C
	db $FF		; level 13D
	db $FF		; level 13E
	db $FF		; level 13F
	db $FF		; level 140
	db $FF		; level 141
	db $FF		; level 142
	db $FF		; level 143
	db $FF		; level 144
	db $FF		; level 145
	db $FF		; level 146
	db $FF		; level 147
	db $FF		; level 148
	db $FF		; level 149
	db $FF		; level 14A
	db $FF		; level 14B
	db $FF		; level 14C
	db $FF		; level 14D
	db $FF		; level 14E
	db $FF		; level 14F
	db $FF		; level 150
	db $FF		; level 151
	db $FF		; level 152
	db $FF		; level 153
	db $FF		; level 154
	db $FF		; level 155
	db $FF		; level 156
	db $FF		; level 157
	db $FF		; level 158
	db $FF		; level 159
	db $FF		; level 15A
	db $FF		; level 15B
	db $FF		; level 15C
	db $FF		; level 15D
	db $FF		; level 15E
	db $FF		; level 15F
	db $FF		; level 160
	db $FF		; level 161
	db $FF		; level 162
	db $FF		; level 163
	db $FF		; level 164
	db $FF		; level 165
	db $FF		; level 166
	db $FF		; level 167
	db $FF		; level 168
	db $FF		; level 169
	db $FF		; level 16A
	db $FF		; level 16B
	db $FF		; level 16C
	db $FF		; level 16D
	db $FF		; level 16E
	db $FF		; level 16F
	db $FF		; level 170
	db $FF		; level 171
	db $FF		; level 172
	db $FF		; level 173
	db $FF		; level 174
	db $FF		; level 175
	db $FF		; level 176
	db $FF		; level 177
	db $FF		; level 178
	db $FF		; level 179
	db $FF		; level 17A
	db $FF		; level 17B
	db $FF		; level 17C
	db $FF		; level 17D
	db $FF		; level 17E
	db $FF		; level 17F
	db $FF		; level 180
	db $FF		; level 181
	db $FF		; level 182
	db $FF		; level 183
	db $FF		; level 184
	db $FF		; level 185
	db $FF		; level 186
	db $FF		; level 187
	db $FF		; level 188
	db $FF		; level 189
	db $FF		; level 18A
	db $FF		; level 18B
	db $FF		; level 18C
	db $FF		; level 18D
	db $FF		; level 18E
	db $FF		; level 18F
	db $FF		; level 190
	db $FF		; level 191
	db $FF		; level 192
	db $FF		; level 193
	db $FF		; level 194
	db $FF		; level 195
	db $FF		; level 196
	db $FF		; level 197
	db $FF		; level 198
	db $FF		; level 199
	db $FF		; level 19A
	db $FF		; level 19B
	db $FF		; level 19C
	db $FF		; level 19D
	db $FF		; level 19E
	db $FF		; level 19F
	db $FF		; level 1A0
	db $FF		; level 1A1
	db $FF		; level 1A2
	db $FF		; level 1A3
	db $FF		; level 1A4
	db $FF		; level 1A5
	db $FF		; level 1A6
	db $FF		; level 1A7
	db $FF		; level 1A8
	db $FF		; level 1A9
	db $FF		; level 1AA
	db $FF		; level 1AB
	db $FF		; level 1AC
	db $FF		; level 1AD
	db $FF		; level 1AE
	db $FF		; level 1AF
	db $FF		; level 1B0
	db $FF		; level 1B1
	db $FF		; level 1B2
	db $FF		; level 1B3
	db $FF		; level 1B4
	db $FF		; level 1B5
	db $FF		; level 1B6
	db $FF		; level 1B7
	db $FF		; level 1B8
	db $FF		; level 1B9
	db $FF		; level 1BA
	db $FF		; level 1BB
	db $FF		; level 1BC
	db $FF		; level 1BD
	db $FF		; level 1BE
	db $FF		; level 1BF
	db $FF		; level 1C0
	db $FF		; level 1C1
	db $FF		; level 1C2
	db $FF		; level 1C3
	db $FF		; level 1C4
	db $FF		; level 1C5
	db $FF		; level 1C6
	db $FF		; level 1C7
	db $FF		; level 1C8
	db $FF		; level 1C9
	db $FF		; level 1CA
	db $FF		; level 1CB
	db $FF		; level 1CC
	db $FF		; level 1CD
	db $FF		; level 1CE
	db $FF		; level 1CF
	db $FF		; level 1D0
	db $FF		; level 1D1
	db $FF		; level 1D2
	db $FF		; level 1D3
	db $FF		; level 1D4
	db $FF		; level 1D5
	db $FF		; level 1D6
	db $FF		; level 1D7
	db $FF		; level 1D8
	db $FF		; level 1D9
	db $FF		; level 1DA
	db $FF		; level 1DB
	db $FF		; level 1DC
	db $FF		; level 1DD
	db $FF		; level 1DE
	db $FF		; level 1DF
	db $FF		; level 1E0
	db $FF		; level 1E1
	db $FF		; level 1E2
	db $FF		; level 1E3
	db $FF		; level 1E4
	db $FF		; level 1E5
	db $FF		; level 1E6
	db $FF		; level 1E7
	db $FF		; level 1E8
	db $FF		; level 1E9
	db $FF		; level 1EA
	db $FF		; level 1EB
	db $FF		; level 1EC
	db $FF		; level 1ED
	db $FF		; level 1EE
	db $FF		; level 1EF
	db $FF		; level 1F0
	db $FF		; level 1F1
	db $FF		; level 1F2
	db $FF		; level 1F3
	db $FF		; level 1F4
	db $FF		; level 1F5
	db $FF		; level 1F6
	db $FF		; level 1F7
	db $FF		; level 1F8
	db $FF		; level 1F9
	db $FF		; level 1FA
	db $FF		; level 1FB
	db $FF		; level 1FC
	db $FF		; level 1FD
	db $FF		; level 1FE
	db $FF		; level 1FF


	IndexTable:
	dw .RexLevel			; index 00
	dw .VillageRexLevel		; index 01
	dw .Shaman			; index 02
	dw .HammerRexKoopaMonty		; index 03
	dw .MagicMoleMonty		; index 04
	dw .Rex				; index 05
	dw .ThunderPlant		; index 06
	dw .PlantHeadHammerRex		; index 07
	dw .Empty			; index 08
	dw .Thif			; index 09
	dw .RexPlant			; index 0A
	dw .TerrainPlatform		; index 0B
	dw .EliteKoopaRex		; index 0C
	dw .ShamanKoopa			; index 0D
	dw .CoinGolemEliteBooHoo	; index 0E
	dw .FlamePillar			; index 0F


	.Empty
	dw $0000
	db $FF

	.RexLevel
	dw !SP3
	db $00,$02,$0B			; Rex, Hammer Rex, Piranha Plant
	db $FF

	.VillageRexLevel
	dw !SP3
	db $01,$02,$0B			; Villager Rex, Hammer Rex, Piranha Plant
	db $FF

	.Shaman
	dw !SP3
	db $06,$0B			; Novice Shaman, Piranha Plant
	db $FF

	.HammerRexKoopaMonty
	dw !SP3
	db $02,$03,$0B,$11,$13		; Hammer Rex, Koopa Renegade, Piranha Plant, Hammer, Monty
	db $FF

	.MagicMoleMonty
	dw !SP3
	db $09,$13,$0B			; Magic Mole, Monty, Piranha Plant
	db $FF

	.Rex
	dw !SP3
	db $00,$10,$17			; Rex, Lotus fire, Mario Fire
	db $FF

	.ThunderPlant
	dw !SP4
	db $12,$0B			; Thunder, Piranha Plant
	db $FF

	.PlantHeadHammerRex
	dw !SP3
	db $04,$02			; Hammer Rex, Plant Head
	db $FF

	.GoombaSlave
	dw !SP3
	db $07				; Goomba Slave
	db $FF

	.Thif
	dw !SP3
	db $05				; Thif
	db $FF

	.RexPlant
	dw !SP3
	db $00,$0B			; Rex, Piranha Plant
	db $FF

	.TerrainPlatform
	dw !SP3
	db $03,$02,$14,$0B,$11		; Koopa, Hammer Rex, Terrain platform, Piranha Plant, Hammer
	db $FF

	.EliteKoopaRex
	dw !SP2+$200
	db $03,$18,$02,$11,$15,$17	; Koopa, Elite Koopa, Hammer Rex, Hammer, Yoshi Coin, Mario Fire
	db $FF

	.ShamanKoopa
	dw !SP3
	db $06,$03			; Novice Shaman, Koopa Renegade
	db $FF

	.CoinGolemEliteBooHoo
	dw !SP3
	db $18,$08,$15,$16,$17		; Elite Koopa, Boo Hoo, Sprite Yoshi Coin, Coin Golem, Mario fire
	db $FF

	.FlamePillar
	dw !SP4
	db $19				; Flame Pillar
	db $FF



	GraphicsTable:
	dw .Rex			; file 00
	dw .VillagerRex		; file 01
	dw .HammerRex		; file 02
	dw .KoopaRenegade	; file 03
	dw .PlantHead		; file 04
	dw .Thif		; file 05
	dw .NoviceShaman	; file 06
	dw .GoombaSlave		; file 07
	dw .BooHoo		; file 08
	dw .MagicMole		; file 09
	dw .Monkey		; file 0A
	dw .PiranhaPlant	; file 0B
	dw .Goomba		; file 0C
	dw .KompositeKoopa	; file 0D
	dw .Bumper		; file 0E
	dw .SlimeBumper		; file 0F
	dw .LotusFire		; file 10
	dw .Hammer		; file 11
	dw .Thunder		; file 12
	dw .Monty		; file 13
	dw .TerrainPlatform	; file 14
	dw .SpriteYoshiCoin	; file 15
	dw .CoinGolem		; file 16
	dw .MarioFire		; file 17
	dw .EliteKoopa		; file 18
	dw .FlamePillar		; file 19




; format:
; first 2 byte is header, which indicates how large the dynamo is
; third byte is what !GFX_status slot will be updated (00 = no change)
; then, for each upload:
;	2 bytes for upload size
;	3 bytes for GFX location
;	2 bytes for upload offset, indicating where the next upload should start


	.Rex
	dw ..End-..Start
	db $03
	..Start
	dw $0C00
	dl $308008
	dw $0600
	..End

	.VillagerRex
	dw ..End-..Start
	db $03
	..Start
	dw $0C00
	dl $308C08
	dw $0600
	..End

	.HammerRex
	dw ..End-..Start
	db $04
	..Start
	dw $0C00
	dl $309808
	dw $0600
	..End

	.KoopaRenegade
	dw ..End-..Start
	db $01
	..Start
	dw $0C00
	dl $30A408
	dw $0600
	..End

	.PlantHead
	dw ..End-..Start
	db $06
	..Start
	dw $0C00
	dl $30B008
	dw $0600
	..End

	.Thif
	dw ..End-..Start
	db $08
	..Start
	dw $0400
	dl $30BC08
	dw $0200
	..End

	.NoviceShaman
	dw ..End-..Start
	db $0C
	..Start
	dw $1000
	dl $30C408
	dw $0800
	..End

	.GoombaSlave
	dw ..End-..Start
	db $07
	..Start
	dw $0800
	dl $30D408
	dw $0400
	..End

	.BooHoo
	dw ..End-..Start
	db $18
	..Start
	dw $0400
	dl $31C000
	dw $0200
	..End

	.MagicMole
	dw ..End-..Start
	db $0E
	..Start
	dw $0800
	dl $30E608
	dw $0400
	..End

	.Monkey
	dw ..End-..Start
	db $0F
	..Start
	dw $0C00
	dl $30ECA8
	dw $0600
	..End

	.SpriteBG1
	dw ..End-..Start
	db $00
	..Start
	dw $1000
	dl $31DC00
	dw $0800
	..End

	.ExSP4
	dw ..End-..Start
	db $00
	..Start
	dw $1000
	dl $31EC00
	dw $0800
	..End

	.PiranhaPlant
	dw ..End-..Start
	db $02
	..Start
	dw $00C0
	dl $31EC00
	dw $0100
	dw $0080
	dl $31EE00
	dw $FF60		; -0x100 + 0x60
	..End

	.Goomba
	dw ..End-..Start
	db $10
	..Start
	dw $0080
	dl $31F000
	dw $0100
	dw $0080
	dl $31F200
	dw $FF40		; -0x100 + 0x40
	..End

	.KompositeKoopa
	dw ..End-..Start
	db $11
	..Start
	dw $00C0
	dl $31F400
	dw $0100
	dw $00C0
	dl $31F600
	dw $FF60		; -0x100 + 0x60
	..End

	.Bumper
	dw ..End-..Start
	db $0B
	..Start
	dw $0040
	dl $31F4C0
	dw $0100
	dw $0040
	dl $31F6C0
	dw $FF20		; -0x100 + 0x20
	..End

	.SlimeBumper
	dw ..End-..Start
	db $0B
	..Start
	dw $0040
	dl $31F500
	dw $0100
	dw $0040
	dl $31F700
	dw $FF20		; -0x100 + 0x20
	..End

	.LotusFire
	dw ..End-..Start
	db $0A
	..Start
	dw $0020
	dl $31ECC0
	dw $0100
	dw $0020
	dl $31EEC0
	dw $FF20		; -0x100 + 0x20 (needs a full 16x16)
	..End

	.Hammer
	dw ..End-..Start
	db $05
	..Start
	dw $0080
	dl $308988
	dw $0100
	dw $0080
	dl $308B88
	dw $FF40		; -0x100 + 0x40
	..End

	.Thunder
	dw ..End-..Start
	db $00
	..Start
	dw $00C0
	dl $31DCC0
	dw $0100
	dw $00C0
	dl $31DEC0
	dw $FF60		; -0x100 + 0x60
	..End

	.Monty
	dw ..End-..Start
	db $12
	..Start
	dw $0180
	dl $31F800
	dw $0100
	dw $0180
	dl $31FA00
	dw $FFC0		; -0x100 + 0xC0
	..End

	.TerrainPlatform
	dw ..End-..Start
	db $13
	..Start
	dw $0400
	dl $30C008
	dw $0200
	..End

	.SpriteYoshiCoin
	dw ..End-..Start
	db $15
	..Start
	dw $0080
	dl $30F8A8
	dw $0100
	dw $0080
	dl $30FAA8
	dw $FF40		; -0x100 + 0x40
	..End

	.CoinGolem
	dw ..End-..Start
	db $15
	..Start
	dw $02C0
	dl $30F8A8
	dw $0200
	..End

	.MarioFire
	dw ..End-..Start
	db $16
	..Start
	dw $0040
	dl $31EC00+$280
	dw $0020
	..End

	.EliteKoopa
	dw ..End-..Start
	db $17
	..Start
	dw $1000
	dl $32E1F8
	dw $0800
	..End

	.FlamePillar
	dw ..End-..Start
	db $19
	..Start
	dw $0080
	dl $31F080
	dw $0100
	dw $0080
	dl $31F280
	dw $FF40		; -0x100 + 0x40
	..End


