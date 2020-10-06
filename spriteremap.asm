;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Standard sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Green koopa, no shell
org $019B8C : db $2C : org $07F3FE : db $0A                                       ; Walking 1
org $019B8D : db $2E : org $07F3FE : db $0A                                       ; Walking 2
org $019B8E : db $2E : org $07F3FE : db $0A                                       ; Walking 3
org $019B8F : db $2E : org $07F3FE : db $0A                                       ; Unused?
org $019B90 : db $2E : org $07F3FE : db $0A                                       ; Kicking
org $019B91 : db $28 : org $07F3FE : db $0A                                       ; Sliding 1
org $019B92 : db $2A : org $07F3FE : db $0A                                       ; Sliding 2
org $0189F5 : db $28 : org $07F3FE : db $0A                                       ; Sliding 3
org $01E729 : db $12 : org $07F3FE : db $0A : org $01E753 : db $00                ; Flattened


;;; Red koopa, no shell
org $019B8C : db $2C : org $07F3FF : db $08                                       ; Walking 1
org $019B8D : db $2E : org $07F3FF : db $08                                       ; Walking 2
org $019B8E : db $2E : org $07F3FF : db $08                                       ; Walking 3
org $019B8F : db $2E : org $07F3FF : db $08                                       ; Unused?
org $019B90 : db $2E : org $07F3FF : db $08                                       ; Kicking
org $019B91 : db $28 : org $07F3FF : db $08                                       ; Sliding 6
org $019B92 : db $2A : org $07F3FF : db $08                                       ; Sliding 7
org $0189F5 : db $28 : org $07F3FF : db $08                                       ; Sliding 8
org $01E729 : db $12 : org $07F3FE : db $0A : org $01E753 : db $00                ; Flattened


;;; Blue koopa, no shell
org $019B93 : db $4A : org $07F400 : db $06                                       ; Walking 1
org $019B94 : db $4C : org $07F400 : db $06                                       ; Walking 2
org $019B95 : db $4C : org $07F400 : db $06                                       ; Walking 3
org $019B96 : db $2E : org $07F400 : db $06                                       ; Unused?
org $019B97 : db $00 : org $07F400 : db $06                                       ; Kicking
org $019B98 : db $28 : org $07F400 : db $06                                       ; Sliding 6
org $019B99 : db $2A : org $07F400 : db $06                                       ; Sliding 7
org $0189ED : db $48 : org $07F400 : db $06                                       ; Sliding 8
org $01E729 : db $12 : org $07F3FE : db $0A : org $01E753 : db $00                ; Flattened


;;; Yellow koopa, no shell
org $019B8C : db $2C : org $07F401 : db $04                                       ; Walking 1
org $019B8D : db $2E : org $07F401 : db $04                                       ; Walking 2
org $019B8E : db $2E : org $07F401 : db $04                                       ; Walking 3
org $019B8F : db $2E : org $07F401 : db $04                                       ; Unused?
org $019B90 : db $2E : org $07F401 : db $04                                       ; Kicking
org $019B91 : db $28 : org $07F401 : db $04                                       ; Sliding 6
org $019B92 : db $2A : org $07F401 : db $04                                       ; Sliding 7
org $0189F5 : db $28 : org $07F401 : db $04                                       ; Sliding 8
org $01E729 : db $12 : org $07F3FE : db $0A : org $01E753 : db $00                ; Flattened


;;; Green koopa
org $019B83 : db $20 : org $07F402 : db $0A                                       ; Head 1
org $019B84 : db $40 : org $07F402 : db $0A                                       ; Body 1
org $019B85 : db $22 : org $07F402 : db $0A                                       ; Head 2
org $019B86 : db $42 : org $07F402 : db $0A                                       ; Body 2
org $019B87 : db $24 : org $07F402 : db $0A                                       ; Head 3
org $019B88 : db $44 : org $07F402 : db $0A                                       ; Body 3
org $019B89 : db $02 : org $07F402 : db $0A                                       ; Shell 1
org $019B8A : db $00 : org $07F402 : db $0A                                       ; Shell 2
org $019B8B : db $04 : org $07F402 : db $0A                                       ; Shell 3
org $019881 : db $25                        : org $01989F : db $00                ; Open eye
org $019889 : db $25                        : org $01989F : db $00                ; Closed eye


;;; Red koopa
org $019B83 : db $20 : org $07F403 : db $08                                       ; Head 1
org $019B84 : db $40 : org $07F403 : db $08                                       ; Body 1
org $019B85 : db $22 : org $07F403 : db $08                                       ; Head 2
org $019B86 : db $42 : org $07F403 : db $08                                       ; Body 2
org $019B87 : db $24 : org $07F403 : db $08                                       ; Head 3
org $019B88 : db $44 : org $07F403 : db $08                                       ; Body 3
org $019B89 : db $02 : org $07F403 : db $08                                       ; Shell 1
org $019B8A : db $00 : org $07F403 : db $08                                       ; Shell 2
org $019B8B : db $04 : org $07F403 : db $08                                       ; Shell 3
org $019881 : db $25                        : org $01989F : db $00                ; Open eye
org $019889 : db $25                        : org $01989F : db $00                ; Closed eye


;;; Blue koopa
org $019B83 : db $20 : org $07F404 : db $06                                       ; Head 1
org $019B84 : db $40 : org $07F404 : db $06                                       ; Body 1
org $019B85 : db $22 : org $07F404 : db $06                                       ; Head 2
org $019B86 : db $42 : org $07F404 : db $06                                       ; Body 2
org $019B87 : db $24 : org $07F404 : db $06                                       ; Head 3
org $019B88 : db $44 : org $07F404 : db $06                                       ; Body 3
org $019B89 : db $02 : org $07F404 : db $06                                       ; Shell 1
org $019B8A : db $00 : org $07F404 : db $06                                       ; Shell 2
org $019B8B : db $04 : org $07F404 : db $06                                       ; Shell 3
org $019881 : db $25                        : org $01989F : db $00                ; Open eye
org $019889 : db $25                        : org $01989F : db $00                ; Closed eye


;;; Yellow koopa
org $019B83 : db $20 : org $07F405 : db $04                                       ; Head 1
org $019B84 : db $40 : org $07F405 : db $04                                       ; Body 1
org $019B85 : db $22 : org $07F405 : db $04                                       ; Head 2
org $019B86 : db $42 : org $07F405 : db $04                                       ; Body 2
org $019B87 : db $24 : org $07F405 : db $04                                       ; Head 3
org $019B88 : db $44 : org $07F405 : db $04                                       ; Body 3
org $019B89 : db $02 : org $07F405 : db $04                                       ; Shell 1
org $019B8A : db $00 : org $07F405 : db $04                                       ; Shell 2
org $019B8B : db $04 : org $07F405 : db $04                                       ; Shell 3
org $019881 : db $25                        : org $01989F : db $00                ; Open eye
org $019889 : db $25                        : org $01989F : db $00                ; Closed eye


;;; Green flying parakoopa
org $019B83 : db $20 : org $07F406 : db $0A                                       ; Head 1
org $019B84 : db $40 : org $07F406 : db $0A                                       ; Body 1
org $019B85 : db $22 : org $07F406 : db $0A                                       ; Head 2
org $019B86 : db $42 : org $07F406 : db $0A                                       ; Body 2
org $019B87 : db $24 : org $07F406 : db $0A                                       ; Head 3
org $019B88 : db $44 : org $07F406 : db $0A                                       ; Body 3
org $019E1C : db $02 : org $019E20 : db $46 : org $019E24 : db $02                ; Wings 1
org $019E1D : db $00 : org $019E21 : db $46 : org $019E25 : db $02                ; Wings 2
org $019E1E : db $02 : org $019E22 : db $06 : org $019E26 : db $02                ; Wings 3
org $019E1F : db $00 : org $019E23 : db $06 : org $019E27 : db $02                ; Wings 4


;;; Green bouncing parakoopa
org $019B83 : db $20 : org $07F407 : db $0A                                       ; Head 1
org $019B84 : db $40 : org $07F407 : db $0A                                       ; Body 1
org $019B85 : db $22 : org $07F407 : db $0A                                       ; Head 2
org $019B86 : db $42 : org $07F407 : db $0A                                       ; Body 2
org $019B87 : db $24 : org $07F407 : db $0A                                       ; Head 3
org $019B88 : db $44 : org $07F407 : db $0A                                       ; Body 3
org $019E1C : db $02 : org $019E20 : db $46 : org $019E24 : db $02                ; Wings 1
org $019E1D : db $00 : org $019E21 : db $46 : org $019E25 : db $02                ; Wings 2
org $019E1E : db $02 : org $019E22 : db $06 : org $019E26 : db $02                ; Wings 3
org $019E1F : db $00 : org $019E23 : db $06 : org $019E27 : db $02                ; Wings 4


;;; Red vertical parakoopa
org $019B83 : db $20 : org $07F408 : db $08                                       ; Head 1
org $019B84 : db $40 : org $07F408 : db $08                                       ; Body 1
org $019B85 : db $22 : org $07F408 : db $08                                       ; Head 2
org $019B86 : db $42 : org $07F408 : db $08                                       ; Body 2
org $019B87 : db $24 : org $07F408 : db $08                                       ; Head 3
org $019B88 : db $44 : org $07F408 : db $08                                       ; Body 3
org $019E1C : db $02 : org $019E20 : db $46 : org $019E24 : db $02                ; Wings 1
org $019E1D : db $00 : org $019E21 : db $46 : org $019E25 : db $02                ; Wings 2
org $019E1E : db $02 : org $019E22 : db $06 : org $019E26 : db $02                ; Wings 3
org $019E1F : db $00 : org $019E23 : db $06 : org $019E27 : db $02                ; Wings 4


;;; Red horizontal parakoopa
org $019B83 : db $20 : org $07F409 : db $08                                       ; Head 1
org $019B84 : db $40 : org $07F409 : db $08                                       ; Body 1
org $019B85 : db $22 : org $07F409 : db $08                                       ; Head 2
org $019B86 : db $42 : org $07F409 : db $08                                       ; Body 2
org $019B87 : db $24 : org $07F409 : db $08                                       ; Head 3
org $019B88 : db $44 : org $07F409 : db $08                                       ; Body 3
org $019E1C : db $02 : org $019E20 : db $46 : org $019E24 : db $02                ; Wings 1
org $019E1D : db $00 : org $019E21 : db $46 : org $019E25 : db $02                ; Wings 2
org $019E1E : db $02 : org $019E22 : db $06 : org $019E26 : db $02                ; Wings 3
org $019E1F : db $00 : org $019E23 : db $06 : org $019E27 : db $02                ; Wings 4


;;; Yellow parakoopa
org $019B83 : db $20 : org $07F40A : db $04                                       ; Head 1
org $019B84 : db $40 : org $07F40A : db $04                                       ; Body 1
org $019B85 : db $22 : org $07F40A : db $04                                       ; Head 2
org $019B86 : db $42 : org $07F40A : db $04                                       ; Body 2
org $019B87 : db $24 : org $07F40A : db $04                                       ; Head 3
org $019B88 : db $44 : org $07F40A : db $04                                       ; Body 3
org $019E1C : db $02 : org $019E20 : db $46 : org $019E24 : db $02                ; Wings 1
org $019E1D : db $00 : org $019E21 : db $46 : org $019E25 : db $02                ; Wings 2
org $019E1E : db $02 : org $019E22 : db $06 : org $019E26 : db $02                ; Wings 3
org $019E1F : db $00 : org $019E23 : db $06 : org $019E27 : db $02                ; Wings 4


;;; Bob-omb
org $019BBA : db $00 : org $07F40B : db $16                                       ; Walking 1
org $019BBB : db $02 : org $07F40B : db $16                                       ; Walking 2
org $019BBC : db $00 : org $07F40B : db $16                                       ; Walking 3
org $01A1F0 : db $00 : org $07F40B : db $16                                       ; Stunned


;;; Keyhole
org $01E251 : db $00 : org $01E25B : db $30 : org $01E263 : db $00                ; Key hole top
org $01E256 : db $10 : org $01E25B : db $30 : org $01E263 : db $00                ; Key hole bottom


;;; Goomba
org $019BA8 : db $02 : org $07F40D : db $04                                       ; Frame 1
org $019BA9 : db $00 : org $07F40D : db $04                                       ; Frame 2
org $019BAA : db $00 : org $07F40D : db $04                                       ; Frame 3
org $019BAB : db $02 : org $07F40D : db $04                                       ; Frame 4


;;; Para-goomba (hopping)
org $019BA8 : db $02 : org $07F40E : db $04                                       ; Frame 1
org $019BA9 : db $00 : org $07F40E : db $04                                       ; Frame 2
org $019BAA : db $00 : org $07F40E : db $04                                       ; Frame 3
org $019BAB : db $02 : org $07F40E : db $04                                       ; Frame 4
org $018DE1 : db $C6 : org $018DE0 : db $06 : org $018DE5 : db $02                ; Wing 1
org $018DE2 : db $C6 : org $018DE0 : db $06 : org $018DE6 : db $02                ; Wing 2
org $018DE3 : db $5D : org $018DE0 : db $06 : org $018DE7 : db $00                ; Wing 3
org $018DE4 : db $5D : org $018DE0 : db $06 : org $018DE8 : db $00                ; Wing 4


;;; Buzzy beetle
org $019BDD : db $00 : org $07F40F : db $1C                                       ; Walking 1
org $019BDE : db $02 : org $07F40F : db $1C                                       ; Walking 2
org $019BDF : db $00 : org $07F40F : db $1C                                       ; Walking 3
org $019BE3 : db $04 : org $07F40F : db $1C                                       ; Shell 1
org $019BE4 : db $06 : org $07F40F : db $1C                                       ; Shell 2
org $019BE5 : db $08 : org $07F40F : db $1C                                       ; Shell 3


;;; Null


;;; Spiny
org $019BCE : db $00 : org $07F411 : db $08                                       ; Walking 1
org $019BCF : db $02 : org $07F411 : db $08                                       ; Walking 2
org $019BD0 : db $00 : org $07F411 : db $08                                       ; Walking 3


;;; Spiny egg
org $019BD1 : db $04 : org $07F412 : db $08                                       ; Egg 1, 1
org $019BD2 : db $04 : org $07F412 : db $08                                       ; Egg 1, 2
org $019BD3 : db $04 : org $07F412 : db $08                                       ; Egg 1, 3
org $019BD4 : db $04 : org $07F412 : db $08                                       ; Egg 1, 4
org $019BD5 : db $06 : org $07F412 : db $08                                       ; Egg 2, 1
org $019BD6 : db $06 : org $07F412 : db $08                                       ; Egg 2, 2
org $019BD7 : db $06 : org $07F412 : db $08                                       ; Egg 2, 3
org $019BD8 : db $06 : org $07F412 : db $08                                       ; Egg 2, 4


;;; Cheep cheep, horizontal
org $019C0D : db $00 : org $07F413 : db $44                                       ; Swimming 1
org $019C0E : db $02 : org $07F413 : db $44                                       ; Swimming 2
org $019C0F : db $04                                                              ; Flopping 2
org $019C10 : db $06                                                              ; Flopping 2


;;; Cheep cheep, vertical
org $019C0D : db $00 : org $07F414 : db $45                                       ; Swimming 1
org $019C0E : db $02 : org $07F414 : db $45                                       ; Swimming 2
org $019C0F : db $04                                                              ; Flopping 2
org $019C10 : db $06                                                              ; Flopping 2


;;; Cheep cheep, flying
org $019C0D : db $00 : org $07F415 : db $85                                       ; Frame 1
org $019C0E : db $02 : org $07F415 : db $85                                       ; Frame 2


;;; Cheep cheep, jumping
org $019C0D : db $00 : org $07F416 : db $85                                       ; Frame 1
org $019C0E : db $02 : org $07F416 : db $85                                       ; Frame 2


;;; Null


;;; Piranha plant
org $019BBD : db $00 : org $07F418 : db $08                                       ; Head 1
org $019BBE : db $04 : org $018E92 : db $08                                       ; Stem 1
org $019BBF : db $02 : org $07F418 : db $08                                       ; Head 2
org $019BC0 : db $04 : org $018E92 : db $08                                       ; Stem 2


;;; Football
org $019BC9 : db $00 : org $07F419 : db $00                                       ; Tile


;;; Bullet bill
org $019BCA : db $00 : org $018FC7 : db $42                                       ; Right
org $019BCA : db $00 : org $018FC8 : db $02                                       ; Left
org $019BCB : db $02 : org $018FC9 : db $02                                       ; Up
org $019BCB : db $02 : org $018FCA : db $82                                       ; Down
org $019BCC : db $04 : org $018FCB : db $02                                       ; Down left
org $019BCC : db $04 : org $018FCC : db $42                                       ; Up left
org $019BCD : db $06 : org $018FCD : db $02                                       ; Up right
org $019BCD : db $06 : org $018FCE : db $42                                       ; Down right


;;; Hopping flame
org $019BEC : db $00 : org $07F41B : db $14                                       ; Frame 1
org $019BED : db $02 : org $07F41B : db $14                                       ; Frame 1
org $02A217 : db $04 : org $02A24C : db $04                                       ; Remnant flame 1
org $02A218 : db $14 : org $02A24C : db $04                                       ; Remnant flame 2


;;; Lakitu
org $019BEE : db $00 : org $07F41C : db $08                                       ; Normal (head)
org $019BEF : db $06 : org $07F41C : db $08                                       ; Normal (body)
org $019BF0 : db $04 : org $07F41C : db $08                                       ; Dead (head)
org $019BF1 : db $06 : org $07F41C : db $08                                       ; Dead (body)
org $019BF2 : db $02 : org $07F41C : db $08                                       ; Throwing (head)
org $019BF3 : db $06 : org $07F41C : db $08                                       ; Throwing (body)
org $02E6A8 : db $AA : org $02E6B2 : db $35 : org $02E6BE : db $02                ; Fishing rod
org $02E707 : db $89 : org $02E70C : db $35 : org $02E71B : db $00                ; Fishing line
org $02E6AD : db $24 : org $02E6B7 : db $3A : org $02E6BE : db $02                ; Bait


;;; Magikoopa
org $019BF6 : db $06 : org $07F41D : db $4E                                       ; Frame 1
org $019BF7 : db $00 : org $07F41D : db $4E                                       ; Frame 2
org $019BF8 : db $06 : org $07F41D : db $4E                                       ; Frame 3
org $019BF9 : db $00 : org $07F41D : db $4E                                       ; Frame 4
org $019BFA : db $08 : org $07F41D : db $4E                                       ; Frame 5
org $019BFB : db $04 : org $07F41D : db $4E                                       ; Frame 6
org $019BFC : db $08 : org $07F41D : db $4E                                       ; Frame 7
org $019BFD : db $04 : org $07F41D : db $4E                                       ; Frame 8
org $019BFE : db $06 : org $07F41D : db $4E                                       ; Frame 9
org $019BFF : db $00 : org $07F41D : db $4E                                       ; Frame 10
org $019C00 : db $06 : org $07F41D : db $4E                                       ; Frame 11
org $019C01 : db $00 : org $07F41D : db $4E                                       ; Frame 12
org $01BF05 : db $98 : org $01BF05 : db $98                                       ; Wand


;;; Magikoopa's magic
org $01BD83 : db $0A : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (circle), 1
org $01BD83 : db $0A : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (circle), 2
org $01BD83 : db $0A : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (circle), 3
org $01BD83 : db $0A : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (circle), 4
org $01BD88 : db $0B : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (square), 1
org $01BD88 : db $0B : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (square), 2
org $01BD88 : db $0B : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (square), 3
org $01BD88 : db $0B : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (square), 4
org $01BD8D : db $1A : org $01BC34 : db $04 : org $01BD92 : db $00                ; Magic (triangle), 1
org $01BD8D : db $1A : org $01BC35 : db $06 : org $01BD92 : db $00                ; Magic (triangle), 2
org $01BD8D : db $1A : org $01BC36 : db $08 : org $01BD92 : db $00                ; Magic (triangle), 3
org $01BD8D : db $1A : org $01BC37 : db $0A : org $01BD92 : db $00                ; Magic (triangle), 4


;;; Moving coin
org $01C653 : db $00 : org $07F41F : db $24                                       ; Frame 1
org $01C66D : db $02 : org $07F41F : db $24                                       ; Frame 2
org $01C66E : db $12 : org $07F41F : db $24                                       ; Frame 3
org $01C66F : db $02 : org $07F41F : db $24                                       ; Frame 4
org $029A4F : db $00 : org $029A54 : db $04 : org $029A5F : db $02                ; Coin from ? block 1
org $029A6E : db $02 : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 2
org $029A6F : db $12 : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 3
org $029A70 : db $02 : org $029A54 : db $04 : org $029A9F : db $00                ; Coin from ? block 4


;;; Green vertical climbing net koopa
org $019C03 : db $06 : org $07F420 : db $0A                                       ; Frame 1
org $019C04 : db $00 : org $07F420 : db $0A                                       ; Frame 2
org $019C05 : db $08 : org $07F420 : db $0A                                       ; Frame 3
org $019C06 : db $02 : org $07F420 : db $0A                                       ; Frame 4
org $019C07 : db $0A : org $07F420 : db $0A                                       ; Frame 5
org $019C08 : db $04 : org $07F420 : db $0A                                       ; Frame 6


;;; Red vertical climbing net koopa
org $019C03 : db $06 : org $07F421 : db $08                                       ; Frame 1
org $019C04 : db $00 : org $07F421 : db $08                                       ; Frame 2
org $019C05 : db $08 : org $07F421 : db $08                                       ; Frame 3
org $019C06 : db $02 : org $07F421 : db $08                                       ; Frame 4
org $019C07 : db $0A : org $07F421 : db $08                                       ; Frame 5
org $019C08 : db $04 : org $07F421 : db $08                                       ; Frame 6


;;; Green horizontal climbing net koopa
org $019C03 : db $06 : org $07F422 : db $0A                                       ; Frame 1
org $019C04 : db $00 : org $07F422 : db $0A                                       ; Frame 2
org $019C05 : db $08 : org $07F422 : db $0A                                       ; Frame 3
org $019C06 : db $02 : org $07F422 : db $0A                                       ; Frame 4
org $019C07 : db $0A : org $07F422 : db $0A                                       ; Frame 5
org $019C08 : db $04 : org $07F422 : db $0A                                       ; Frame 6


;;; Red horizontal climbing net koopa
org $019C03 : db $06 : org $07F423 : db $08                                       ; Frame 1
org $019C04 : db $00 : org $07F423 : db $08                                       ; Frame 2
org $019C05 : db $08 : org $07F423 : db $08                                       ; Frame 3
org $019C06 : db $02 : org $07F423 : db $08                                       ; Frame 4
org $019C07 : db $0A : org $07F423 : db $08                                       ; Frame 5
org $019C08 : db $04 : org $07F423 : db $08                                       ; Frame 6


;;; Thwomp
org $01AF4A : db $00 : org $01AF4F : db $02                                       ; Top left
org $01AF4B : db $00 : org $01AF50 : db $42                                       ; Top right
org $01AF4C : db $02 : org $01AF51 : db $02                                       ; Bottom left
org $01AF4D : db $02 : org $01AF52 : db $42                                       ; Bottom right
org $01AF4E : db $04 : org $01AF53 : db $02                                       ; Suspicious face
org $01AF8D : db $06 : org $01AF53 : db $02                                       ; Angry face


;;; Thwimp
org $019C13 : db $00 : org $07F425 : db $32                                       ; Thwimp 1
org $019C14 : db $00 : org $07F425 : db $32                                       ; Thwimp 2
org $019C15 : db $10 : org $07F425 : db $32                                       ; Thwimp 3
org $019C16 : db $10 : org $07F425 : db $32                                       ; Thwimp 4


;;; Big boo
org $0382F8 : db $08 : org $07F426 : db $FD                                       ; Tile 1
org $0382F9 : db $28 : org $07F426 : db $FD                                       ; Tile 2
org $0382FA : db $23 : org $07F426 : db $FD                                       ; Tile 3
org $0382FB : db $00 : org $07F426 : db $FD                                       ; Tile 4
org $0382FC : db $20 : org $07F426 : db $FD                                       ; Tile 5
org $0382FD : db $20 : org $07F426 : db $FD                                       ; Tile 6
org $0382FE : db $00 : org $07F426 : db $FD                                       ; Tile 7
org $0382FF : db $02 : org $07F426 : db $FD                                       ; Tile 8
org $038300 : db $21 : org $07F426 : db $FD                                       ; Tile 9
org $038301 : db $21 : org $07F426 : db $FD                                       ; Tile 10
org $038302 : db $02 : org $07F426 : db $FD                                       ; Tile 11
org $038303 : db $04 : org $07F426 : db $FD                                       ; Tile 12
org $038304 : db $A4 : org $07F426 : db $FD                                       ; Tile 13
org $038305 : db $C4 : org $07F426 : db $FD                                       ; Tile 14
org $038306 : db $E4 : org $07F426 : db $FD                                       ; Tile 15
org $038307 : db $86 : org $07F426 : db $FD                                       ; Tile 16
org $038308 : db $A6 : org $07F426 : db $FD                                       ; Tile 17
org $038309 : db $C6 : org $07F426 : db $FD                                       ; Tile 18
org $03830A : db $E6 : org $07F426 : db $FD                                       ; Tile 19
org $03830B : db $E8 : org $07F426 : db $FD                                       ; Tile 20
org $03830C : db $C0 : org $07F426 : db $FD                                       ; Tile 21
org $03830D : db $E0 : org $07F426 : db $FD                                       ; Tile 22
org $03830E : db $E8 : org $07F426 : db $FD                                       ; Tile 23
org $03830F : db $80 : org $07F426 : db $FD                                       ; Tile 24
org $038310 : db $A0 : org $07F426 : db $FD                                       ; Tile 25
org $038311 : db $A0 : org $07F426 : db $FD                                       ; Tile 26
org $038312 : db $80 : org $07F426 : db $FD                                       ; Tile 27
org $038313 : db $82 : org $07F426 : db $FD                                       ; Tile 28
org $038314 : db $A2 : org $07F426 : db $FD                                       ; Tile 29
org $038315 : db $A2 : org $07F426 : db $FD                                       ; Tile 30
org $038316 : db $82 : org $07F426 : db $FD                                       ; Tile 31
org $038317 : db $84 : org $07F426 : db $FD                                       ; Tile 32
org $038318 : db $A4 : org $07F426 : db $FD                                       ; Tile 33
org $038319 : db $C4 : org $07F426 : db $FD                                       ; Tile 34
org $03831A : db $E4 : org $07F426 : db $FD                                       ; Tile 35
org $03831B : db $86 : org $07F426 : db $FD                                       ; Tile 36
org $03831C : db $A6 : org $07F426 : db $FD                                       ; Tile 37
org $03831D : db $C6 : org $07F426 : db $FD                                       ; Tile 38
org $03831E : db $E6 : org $07F426 : db $FD                                       ; Tile 39
org $03831F : db $E8 : org $07F426 : db $FD                                       ; Tile 40
org $038320 : db $C0 : org $07F426 : db $FD                                       ; Tile 41
org $038321 : db $E0 : org $07F426 : db $FD                                       ; Tile 42
org $038322 : db $E8 : org $07F426 : db $FD                                       ; Tile 43
org $038323 : db $80 : org $07F426 : db $FD                                       ; Tile 44
org $038324 : db $A0 : org $07F426 : db $FD                                       ; Tile 45
org $038325 : db $A0 : org $07F426 : db $FD                                       ; Tile 46
org $038326 : db $80 : org $07F426 : db $FD                                       ; Tile 47
org $038327 : db $82 : org $07F426 : db $FD                                       ; Tile 48
org $038328 : db $A2 : org $07F426 : db $FD                                       ; Tile 49
org $038329 : db $A2 : org $07F426 : db $FD                                       ; Tile 50
org $03832A : db $82 : org $07F426 : db $FD                                       ; Tile 51
org $03832B : db $84 : org $07F426 : db $FD                                       ; Tile 52
org $03832C : db $A4 : org $07F426 : db $FD                                       ; Tile 53
org $03832D : db $A4 : org $07F426 : db $FD                                       ; Tile 54
org $03832E : db $84 : org $07F426 : db $FD                                       ; Tile 55
org $03832F : db $86 : org $07F426 : db $FD                                       ; Tile 56
org $038330 : db $A6 : org $07F426 : db $FD                                       ; Tile 57
org $038331 : db $A6 : org $07F426 : db $FD                                       ; Tile 58
org $038332 : db $86 : org $07F426 : db $FD                                       ; Tile 59
org $038333 : db $E8 : org $07F426 : db $FD                                       ; Tile 60
org $038334 : db $E8 : org $07F426 : db $FD                                       ; Tile 61
org $038335 : db $E8 : org $07F426 : db $FD                                       ; Tile 62
org $038336 : db $C2 : org $07F426 : db $FD                                       ; Tile 63
org $038337 : db $E2 : org $07F426 : db $FD                                       ; Tile 64
org $038338 : db $80 : org $07F426 : db $FD                                       ; Tile 65
org $038339 : db $A0 : org $07F426 : db $FD                                       ; Tile 66
org $03833A : db $A0 : org $07F426 : db $FD                                       ; Tile 67
org $03833B : db $80 : org $07F426 : db $FD                                       ; Tile 68
org $03833C : db $82 : org $07F426 : db $FD                                       ; Tile 69
org $03833D : db $A2 : org $07F426 : db $FD                                       ; Tile 70
org $03833E : db $A2 : org $07F426 : db $FD                                       ; Tile 71
org $03833F : db $82 : org $07F426 : db $FD                                       ; Tile 72
org $038340 : db $84 : org $07F426 : db $FD                                       ; Tile 73
org $038341 : db $A4 : org $07F426 : db $FD                                       ; Tile 74
org $038342 : db $C4 : org $07F426 : db $FD                                       ; Tile 75
org $038343 : db $E4 : org $07F426 : db $FD                                       ; Tile 76
org $038344 : db $86 : org $07F426 : db $FD                                       ; Tile 77
org $038345 : db $A6 : org $07F426 : db $FD                                       ; Tile 78
org $038346 : db $C6 : org $07F426 : db $FD                                       ; Tile 79
org $038347 : db $E6 : org $07F426 : db $FD                                       ; Tile 80


;;; Koopalings


;;; Upside-down piranha plant
org $019BBD : db $00 : org $07F428 : db $08                                       ; Head 1
org $019BBE : db $04 : org $018E93 : db $0B                                       ; Stem 1
org $019BBF : db $02 : org $07F428 : db $08                                       ; Head 2
org $019BC0 : db $04 : org $018E93 : db $0B                                       ; Stem 2


;;; Sumo Bros. lightning
org $019C79 : db $00 : org $07F429 : db $34                                       ; Lightning 1
org $019C7A : db $10 : org $07F429 : db $34                                       ; Lightning 2
org $019C7B : db $00 : org $07F429 : db $34                                       ; Lightning 3
org $019C7C : db $10 : org $07F429 : db $34                                       ; Lightning 4
org $02F904 : db $03 : org $02F98F : db $04                                       ; Flame 1
org $02F905 : db $05 : org $02F98F : db $04                                       ; Flame 2
org $02F906 : db $01 : org $02F98F : db $04                                       ; Flame 3
org $02F907 : db $03 : org $02F98F : db $04                                       ; Flame 4
org $02F908 : db $01 : org $02F98F : db $04                                       ; Flame 5
org $02F909 : db $05 : org $02F98F : db $04                                       ; Flame 6
org $02F90A : db $01 : org $02F98F : db $04                                       ; Unused?
org $02F90B : db $01 : org $02F98F : db $04                                       ; Flame 7


;;; Yoshi Egg
org $01F794 : db $00 : org $07F42A : db $3B                                       ; Normal
org $01F761 : db $02 : org $01F75D : db $01                                       ; Tile 1
org $01F762 : db $02 : org $01F75E : db $01                                       ; Tile 2
org $01F763 : db $00 : org $01F75F : db $01                                       ; Tile 3
org $028EB2 : db $6F : org $028EBC : db $03                                       ; Egg shard


;;; Baby Yoshi


;;; Spike top
org $019BE6 : db $00 : org $07F42C : db $18                                       ; Horizontal walking 1
org $019BE7 : db $02 : org $07F42C : db $18                                       ; Horizontal walking 2
org $019BE8 : db $06 : org $07F42C : db $18                                       ; Vertical walking 1
org $019BE9 : db $08 : org $07F42C : db $18                                       ; Vertical walking 2
org $019BEA : db $04 : org $07F42C : db $18                                       ; Diagonal 1
org $019BEB : db $04 : org $07F42C : db $18                                       ; Diagonal 2


;;; Portable Springboard
org $019C1D : db $00 : org $07F42D : db $3A                                       ; Frame 1, 1
org $019C1E : db $00 : org $07F42D : db $3A                                       ; Frame 1, 2
org $019C1F : db $00 : org $07F42D : db $3A                                       ; Frame 1, 3
org $019C20 : db $00 : org $07F42D : db $3A                                       ; Frame 1, 4
org $019C21 : db $01 : org $07F42D : db $3A                                       ; Frame 2, 1
org $019C22 : db $01 : org $07F42D : db $3A                                       ; Frame 2, 2
org $019C23 : db $01 : org $07F42D : db $3A                                       ; Frame 2, 3
org $019C24 : db $01 : org $07F42D : db $3A                                       ; Frame 2, 4
org $019C25 : db $11 : org $07F42D : db $3A                                       ; Frame 3, 1
org $019C26 : db $11 : org $07F42D : db $3A                                       ; Frame 3, 2
org $019C27 : db $10 : org $07F42D : db $3A                                       ; Frame 3, 3
org $019C28 : db $10 : org $07F42D : db $3A                                       ; Frame 3, 4


;;; Dry bones (throws bones)
org $03C3CE : db $00 : org $07F42E : db $13                                       ; Unused 1
org $03C3CF : db $64 : org $07F42E : db $13                                       ; Walking 1 (head)
org $03C3D0 : db $66 : org $07F42E : db $13                                       ; Walking 1 (body)
org $03C3D1 : db $00 : org $07F42E : db $13                                       ; Unused 2
org $03C3D2 : db $64 : org $07F42E : db $13                                       ; Walking 2 (head)
org $03C3D3 : db $68 : org $07F42E : db $13                                       ; Walking 2 (body)
org $03C3D4 : db $82 : org $07F42E : db $13                                       ; Throwing (bone)
org $03C3D5 : db $64 : org $07F42E : db $13                                       ; Throwing (head)
org $03C3D6 : db $E6 : org $07F42E : db $13                                       ; Throwing (body)
org $01E454 : db $48 : org $07F42E : db $13                                       ; Crumbling 1
org $01E45E : db $2E : org $07F42E : db $13                                       ; Crumbling 2
org $02A2CC : db $80 : org $02A2DA : db $02                                       ; Thrown bone 1
org $02A2D0 : db $82 : org $02A2DA : db $02                                       ; Thrown bone 2


;;; Bony beetle
org $019C2D : db $8C : org $07F42F : db $13                                       ; Walking 1
org $019C2E : db $AA : org $07F42F : db $13                                       ; Walking 2
org $019C2F : db $86 : org $07F42F : db $13                                       ; Shielding 1
org $019C30 : db $84 : org $07F42F : db $13                                       ; Shielding 2
org $01E454 : db $48 : org $07F42F : db $13                                       ; Crumbling 1
org $01E45E : db $2E : org $07F42F : db $13                                       ; Crumbling 2


;;; Dry bones (stays on ledges)
org $03C3CE : db $00 : org $07F430 : db $13                                       ; Unused 1
org $03C3CF : db $64 : org $07F430 : db $13                                       ; Walking 1 (head)
org $03C3D0 : db $66 : org $07F430 : db $13                                       ; Walking 1 (body)
org $03C3D1 : db $00 : org $07F430 : db $13                                       ; Unused 2
org $03C3D2 : db $64 : org $07F430 : db $13                                       ; Walking 2 (head)
org $03C3D3 : db $68 : org $07F430 : db $13                                       ; Walking 2 (body)
org $03C3D4 : db $82 : org $07F430 : db $13                                       ; Throwing (bone)
org $03C3D5 : db $64 : org $07F430 : db $13                                       ; Throwing (head)
org $03C3D6 : db $E6 : org $07F430 : db $13                                       ; Throwing (body)
org $01E454 : db $48 : org $07F430 : db $13                                       ; Crumbling 1
org $01E45E : db $2E : org $07F430 : db $13                                       ; Crumbling 2
org $02A2CC : db $80 : org $02A2DA : db $02                                       ; Thrown bone 1
org $02A2D0 : db $82 : org $02A2DA : db $02                                       ; Thrown bone 2


;;; Podoboo
org $019C35 : db $00 : org $07F431 : db $34                                       ; Frame 1
org $019C36 : db $00 : org $07F431 : db $34                                       ; Frame 2
org $019C37 : db $10 : org $07F431 : db $34                                       ; Frame 3
org $019C38 : db $10 : org $07F431 : db $34                                       ; Frame 4
org $019C39 : db $01 : org $07F431 : db $34                                       ; Frame 5
org $019C3A : db $01 : org $07F431 : db $34                                       ; Frame 6
org $019C3B : db $11 : org $07F431 : db $34                                       ; Frame 7
org $019C3C : db $11 : org $07F431 : db $34                                       ; Frame 8
org $019C3D : db $10 : org $07F431 : db $34                                       ; Frame 9
org $019C3E : db $10 : org $07F431 : db $34                                       ; Frame 10
org $019C3F : db $00 : org $07F431 : db $34                                       ; Frame 11
org $019C40 : db $00 : org $07F431 : db $34                                       ; Frame 12
org $019C41 : db $11 : org $07F431 : db $34                                       ; Frame 13
org $019C42 : db $11 : org $07F431 : db $34                                       ; Frame 14
org $019C43 : db $01 : org $07F431 : db $34                                       ; Frame 15
org $019C44 : db $01 : org $07F431 : db $34                                       ; Frame 16


;;; Ludwig's fireball
org $01D446 : db $4A : org $07F432 : db $39                                       ; Frame 1, 1
org $01D447 : db $4C : org $07F432 : db $39                                       ; Frame 1, 2
org $01D448 : db $6A : org $07F432 : db $39                                       ; Frame 2, 1
org $01D449 : db $6C : org $07F432 : db $39                                       ; Frame 2, 2


;;; Yoshi
org $01F08B : db $3F : org $01F097 : db $01                                       ; Yoshi's throat
org $01F488 : db $76 : org $01F494 : db $09                                       ; Yoshi's tongue, middle
org $01F48C : db $66 : org $01F494 : db $09                                       ; Yoshi's tongue, end
org $02BB17 : db $5D : org $02BB1B : db $46 : org $02BB1F : db $00                ; Yoshi's wings 1
org $02BB18 : db $C6 : org $02BB1C : db $46 : org $02BB20 : db $02                ; Yoshi's wings 2
org $02BB19 : db $5D : org $02BB1D : db $06 : org $02BB21 : db $00                ; Yoshi's wings 3
org $02BB1A : db $C6 : org $02BB1E : db $06 : org $02BB22 : db $02                ; Yoshi's wings 4


;;; Null


;;; Boo
org $019C5C : db $02 : org $07F435 : db $F2                                       ; Boo 1, 1
org $019C5D : db $00 : org $07F435 : db $F2                                       ; Boo 1, 2
org $019C5E : db $02 : org $07F435 : db $F2                                       ; Boo 2, 1
org $019C5F : db $06 : org $07F435 : db $F2                                       ; Boo 2, 2
org $019C60 : db $08 : org $07F435 : db $F2                                       ; Boo 3, 1
org $019C61 : db $06 : org $07F435 : db $F2                                       ; Boo 3, 2
org $019C52 : db $04 : org $07F435 : db $F2                                       ; Unused?
org $019C63 : db $02 : org $07F435 : db $F2                                       ; Unknown 1
org $019C64 : db $02 : org $07F435 : db $F2                                       ; Unknown 2


;;; Eerie
org $019C5A : db $6A : org $07F436 : db $FD                                       ; Frame 1
org $019C5B : db $ED : org $07F436 : db $FD                                       ; Frame 2


;;; Eerie, wave motion
org $019C5A : db $6A : org $07F437 : db $FD                                       ; Frame 1
org $019C5B : db $ED : org $07F437 : db $FD                                       ; Frame 2


;;; Urchin 1
org $02BF58 : db $00 : org $02BF53 : db $36                                       ; Body 1
org $02BF59 : db $02 : org $02BF54 : db $36                                       ; Body 2
org $02BF5A : db $04 : org $02BF55 : db $76                                       ; Body 3
org $02BF5B : db $02 : org $02BF56 : db $B6                                       ; Body 4
org $02BFA3 : db $06 : org $02BF57 : db $F6                                       ; Eyes 1
org $02BFA9 : db $08 : org $02BF57 : db $F6                                       ; Eyes 2


;;; Urchin 2
org $02BF58 : db $00 : org $02BF53 : db $36                                       ; Body 1
org $02BF59 : db $02 : org $02BF54 : db $36                                       ; Body 2
org $02BF5A : db $04 : org $02BF55 : db $76                                       ; Body 3
org $02BF5B : db $02 : org $02BF56 : db $B6                                       ; Body 4
org $02BFA3 : db $06 : org $02BF57 : db $F6                                       ; Eyes 1
org $02BFA9 : db $08 : org $02BF57 : db $F6                                       ; Eyes 2


;;; Urchin 3
org $02BF58 : db $00 : org $02BF53 : db $36                                       ; Body 1
org $02BF59 : db $02 : org $02BF54 : db $36                                       ; Body 2
org $02BF5A : db $04 : org $02BF55 : db $76                                       ; Body 3
org $02BF5B : db $02 : org $02BF56 : db $B6                                       ; Body 4
org $02BFA3 : db $06 : org $02BF57 : db $F6                                       ; Eyes 1
org $02BFA9 : db $08 : org $02BF57 : db $F6                                       ; Eyes 2


;;; Rip van fish
org $019C65 : db $04 : org $07F43B : db $C6                                       ; Swimming 1
org $019C66 : db $06 : org $07F43B : db $C6                                       ; Swimming 2
org $019C67 : db $00 : org $07F43B : db $C6                                       ; Slepping 1
org $019C68 : db $02 : org $07F43B : db $C6                                       ; Slepping 2
org $028DDA : db $08 : org $028E44 : db $02                                       ; z
org $028DD9 : db $09 : org $028E44 : db $02                                       ; Z
org $028DD8 : db $18 : org $028E44 : db $02                                       ; Z!!
org $028DD7 : db $19 : org $028E44 : db $02                                       ; *pop*


;;; P-switch
org $01A221 : db $00 : org $018466 : db $06                                       ; Blue P-switch, normal
org $01E723 : db $12 : org $018466 : db $06                                       ; Blue P-switch, flattened
org $01A221 : db $00 : org $018467 : db $02                                       ; Silver P-switch, normal
org $01E723 : db $12 : org $018467 : db $02                                       ; Silver P-switch, flattened


;;; Para-goomba (parachute)
org $019B9A : db $A3 : org $07F43D : db $05                                       ; Frame 1
org $019B9B : db $A3 : org $07F43D : db $05                                       ; Frame 2
org $019B9C : db $B3 : org $07F43D : db $05                                       ; Frame 3
org $019B9D : db $B3 : org $07F43D : db $05                                       ; Frame 4
org $019B9E : db $E9 : org $07F43D : db $05                                       ; Frame 5
org $019B9F : db $E8 : org $07F43D : db $05                                       ; Frame 6
org $019BA0 : db $F9 : org $07F43D : db $05                                       ; Frame 7
org $019BA1 : db $F8 : org $07F43D : db $05                                       ; Frame 8
org $019BA2 : db $E8 : org $07F43D : db $05                                       ; Frame 9
org $019BA3 : db $E9 : org $07F43D : db $05                                       ; Frame 10
org $019BA4 : db $F8 : org $07F43D : db $05                                       ; Frame 11
org $019BA5 : db $F9 : org $07F43D : db $05                                       ; Frame 12
org $019BA6 : db $E2 : org $01D5E1 : db $06                                       ; Parachute 1
org $019BA7 : db $E6 : org $01D5E1 : db $06                                       ; Parachute 2


;;; Para-bomb
org $019BAC : db $A2 : org $07F43E : db $15                                       ; Frame 1
org $019BAD : db $A2 : org $07F43E : db $15                                       ; Frame 2
org $019BAE : db $B2 : org $07F43E : db $15                                       ; Frame 3
org $019BAF : db $B2 : org $07F43E : db $15                                       ; Frame 4
org $019BB0 : db $C3 : org $07F43E : db $15                                       ; Frame 5
org $019BB1 : db $C2 : org $07F43E : db $15                                       ; Frame 6
org $019BB2 : db $D3 : org $07F43E : db $15                                       ; Frame 7
org $019BB3 : db $D2 : org $07F43E : db $15                                       ; Frame 8
org $019BB4 : db $C2 : org $07F43E : db $15                                       ; Frame 9
org $019BB5 : db $C3 : org $07F43E : db $15                                       ; Frame 10
org $019BB6 : db $D2 : org $07F43E : db $15                                       ; Frame 11
org $019BB7 : db $D3 : org $07F43E : db $15                                       ; Frame 12
org $019BA6 : db $E2 : org $01D5E1 : db $06                                       ; Parachute 1
org $019BA7 : db $E6 : org $01D5E1 : db $06                                       ; Parachute 2


;;; Dolphin, horizontal 1
org $02BC0E : db $00 : org $07F43F : db $36                                       ; Head 1
org $02BC0F : db $05 : org $07F43F : db $36                                       ; Head 2
org $02BC10 : db $02 : org $07F43F : db $36                                       ; Body 1
org $02BC11 : db $07 : org $07F43F : db $36                                       ; Body 2
org $02BC12 : db $03 : org $07F43F : db $36                                       ; Tail 1
org $02BC13 : db $08 : org $07F43F : db $36                                       ; Tail 2


;;; Dolphin, horizontal 2
org $02BC0E : db $00 : org $07F440 : db $36                                       ; Head 1
org $02BC0F : db $05 : org $07F440 : db $36                                       ; Head 2
org $02BC10 : db $02 : org $07F440 : db $36                                       ; Body 1
org $02BC11 : db $07 : org $07F440 : db $36                                       ; Body 2
org $02BC12 : db $03 : org $07F440 : db $36                                       ; Tail 1
org $02BC13 : db $08 : org $07F440 : db $36                                       ; Tail 2


;;; Dolphin, vertical
org $019C69 : db $0A : org $07F441 : db $36                                       ; Tile 1
org $019C6A : db $0C : org $07F441 : db $36                                       ; Tile 2


;;; Torpedo ted
org $02B92D : db $00 : org $07F442 : db $32                                       ; Body
org $02B937 : db $02 : org $07F442 : db $32                                       ; Propeller 1
org $02B93F : db $04 : org $07F442 : db $32                                       ; Propeller 2
org $02B943 : db $02 : org $07F442 : db $32                                       ; Propeller 3
org $029E66 : db $06 : org $029E74 : db $12 : org $029E7D : db $02                ; Dispenser arm (hand closed)
org $029E6A : db $08 : org $029E74 : db $12 : org $029E7D : db $02                ; Dispenser arm (hand open)


;;; Directional coins
org $01C653 : db $00 : org $07F443 : db $30                                       ; Frame 1
org $01C66D : db $02 : org $07F443 : db $30                                       ; Frame 2
org $01C66E : db $12 : org $07F443 : db $30                                       ; Frame 3
org $01C66F : db $02 : org $07F443 : db $30                                       ; Frame 4


;;; Diggin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Cheep cheep, swims and jumps
org $019C0D : db $00 : org $07F445 : db $85                                       ; Swimming 1
org $019C0E : db $02 : org $07F445 : db $85                                       ; Swimming 2


;;; Diggin' Chuck's rock
org $019C6B : db $00 : org $07F446 : db $1C                                       ; Frame 1
org $019C6C : db $02 : org $07F446 : db $1C                                       ; Frame 2


;;; Pipe end
org $02E91A : db $00 : org $07F447 : db $3A                                       ; Left tile
org $02E91F : db $02 : org $07F447 : db $3A                                       ; Right tile


;;; Goal point sphere
org $019C70 : db $06 : org $07F448 : db $3B                                       ; Tile


;;; Pipe lakitu
org $02E9E6 : db $00 : org $02EA1B : db $5A                                       ; Normal (head)
org $02E9E7 : db $02 : org $02EA1B : db $5A                                       ; Throwing (head)
org $02E9E8 : db $04 : org $02EA1B : db $5A                                       ; Dead (head)
org $02E9E9 : db $06 : org $02EA1B : db $5A                                       ; Normal (body)
org $02E9EA : db $06 : org $02EA1B : db $5A                                       ; Throwing (body)
org $02E9EB : db $06 : org $02EA1B : db $5A                                       ; Dead (body)


;;; Exploding block
org $019C02 : db $84 : org $07F44A : db $34                                       ; Tile


;;; Ground-dwelling monty mole
org $019C6D : db $00 : org $07F44B : db $00                                       ; Walking 1
org $019C6E : db $02 : org $07F44B : db $00                                       ; Walking 2
org $019C6F : db $04 : org $07F44B : db $00                                       ; Jumping
org $019C71 : db $18 : org $07F44B : db $00                                       ; Dirt 1
org $019C72 : db $18 : org $07F44B : db $00                                       ; Dirt 2
org $019C73 : db $08 : org $07F44B : db $00                                       ; Dirt 3
org $019C74 : db $09 : org $07F44B : db $00                                       ; Dirt 4
org $019C75 : db $18 : org $07F44B : db $00                                       ; Dirt 5
org $019C76 : db $18 : org $07F44B : db $00                                       ; Dirt 6
org $019C77 : db $09 : org $07F44B : db $00                                       ; Dirt 7
org $019C78 : db $08 : org $07F44B : db $00                                       ; Dirt 8


;;; Ledge-dwelling monty mole
org $019C6D : db $00 : org $07F44C : db $00                                       ; Walking 1
org $019C6E : db $02 : org $07F44C : db $00                                       ; Walking 2
org $019C6F : db $04 : org $07F44C : db $00                                       ; Jumping
org $019C70 : db $06 : org $07F44C : db $00                                       ; Dirt


;;; Jumpin' piranha plant
org $019BBD : db $00 : org $07F44D : db $08                                       ; Head 1
org $019BBF : db $02 : org $07F44D : db $08                                       ; Head 2
org $019BC1 : db $04 : org $07F44D : db $08                                       ; Propeller Leaves 1
org $019BC2 : db $14 : org $07F44D : db $08                                       ; Propeller Leaves 2
org $019BC3 : db $14 : org $07F44D : db $08                                       ; Propeller Leaves 3
org $019BC4 : db $04 : org $07F44D : db $08                                       ; Propeller Leaves 4
org $019BC5 : db $14 : org $07F44D : db $08                                       ; Propeller Leaves 5
org $019BC6 : db $14 : org $07F44D : db $08                                       ; Propeller Leaves 6
org $019BC7 : db $04 : org $07F44D : db $08                                       ; Propeller Leaves 7
org $019BC8 : db $04 : org $07F44D : db $08                                       ; Propeller Leaves 8


;;; Jumpin' fire-spitting piranha plant
org $019BBD : db $00 : org $07F44E : db $08                                       ; Head 1
org $019BBF : db $02 : org $07F44E : db $08                                       ; Head 2
org $019BC1 : db $04 : org $07F44E : db $08                                       ; Propeller Leaves 1
org $019BC2 : db $14 : org $07F44E : db $08                                       ; Propeller Leaves 2
org $019BC3 : db $14 : org $07F44E : db $08                                       ; Propeller Leaves 3
org $019BC4 : db $04 : org $07F44E : db $08                                       ; Propeller Leaves 4
org $019BC5 : db $14 : org $07F44E : db $08                                       ; Propeller Leaves 5
org $019BC6 : db $14 : org $07F44E : db $08                                       ; Propeller Leaves 6
org $019BC7 : db $04 : org $07F44E : db $08                                       ; Propeller Leaves 7
org $019BC8 : db $04 : org $07F44E : db $08                                       ; Propeller Leaves 8


;;; Ninji
org $019C7D : db $00 : org $07F44F : db $08                                       ; Frame 1
org $019C7E : db $02 : org $07F44F : db $08                                       ; Frame 2


;;; Moving ledge
org $02E66A : db $EB : org $02E66E : db $71 : org $02E662 : db $02                ; Tile 1
org $02E66B : db $EA : org $02E66F : db $31 : org $02E662 : db $02                ; Tile 2
org $02E66C : db $EA : org $02E670 : db $31 : org $02E662 : db $02                ; Tile 3
org $02E66D : db $EB : org $02E671 : db $31 : org $02E662 : db $02                ; Tile 4


;;; Throw block
org $019C02 : db $84 : org $07F44A : db $34                                       ; Tile


;;; Climbing net door
org $01BAB7 : db $00 : org $01BBD2 : db $09                                       ; Tile 1
org $01BAB8 : db $10 : org $01BBD2 : db $09                                       ; Tile 2
org $01BAB9 : db $00 : org $01BBD2 : db $09                                       ; Tile 3
org $01BABA : db $00 : org $01BBD2 : db $09                                       ; Tile 4
org $01BABB : db $10 : org $01BBD2 : db $09                                       ; Tile 5
org $01BABC : db $00 : org $01BBD2 : db $09                                       ; Tile 6
org $01BABD : db $01 : org $01BBD2 : db $09                                       ; Tile 7
org $01BABE : db $11 : org $01BBD2 : db $09                                       ; Tile 8
org $01BABF : db $01 : org $01BBD2 : db $09                                       ; Tile 9
org $01BAC0 : db $05 : org $01BBD2 : db $09                                       ; Tile 10
org $01BAC1 : db $15 : org $01BBD2 : db $09                                       ; Tile 11
org $01BAC2 : db $05 : org $01BBD2 : db $09                                       ; Tile 12
org $01BAC3 : db $05 : org $01BBD2 : db $09                                       ; Tile 13
org $01BAC4 : db $15 : org $01BBD2 : db $09                                       ; Tile 14
org $01BAC5 : db $05 : org $01BBD2 : db $09                                       ; Tile 15
org $01BAC6 : db $00 : org $01BBD2 : db $09                                       ; Tile 16
org $01BAC7 : db $00 : org $01BBD2 : db $09                                       ; Tile 17
org $01BAC8 : db $00 : org $01BBD2 : db $09                                       ; Tile 18
org $01BAC9 : db $03 : org $01BBD2 : db $09                                       ; Tile 19
org $01BACA : db $13 : org $01BBD2 : db $09                                       ; Tile 20
org $01BACB : db $03 : org $01BBD2 : db $09                                       ; Tile 21


;;; Checkerboard platform, horizontal
org $01B32E : db $00 : org $07F453 : db $E2                                       ; Left tile
org $01B333 : db $01 : org $07F453 : db $E2                                       ; Middle tile
org $01B33E : db $02 : org $07F453 : db $E2                                       ; Right tile


;;; Flying rock platform, horizontal
org $01B38C : db $00 : org $07F454 : db $E2                                       ; Top left
org $01B38D : db $03 : org $07F454 : db $E2                                       ; Bottom left
org $01B38E : db $01 : org $07F454 : db $E2                                       ; Middle top
org $01B38F : db $04 : org $07F454 : db $E2                                       ; Middle bottom
org $01B390 : db $01 : org $07F454 : db $E2                                       ; Middle top
org $01B391 : db $04 : org $07F454 : db $E2                                       ; Middle bottom
org $01B392 : db $01 : org $07F454 : db $E2                                       ; Middle top
org $01B393 : db $03 : org $07F454 : db $E2                                       ; Bottom right
org $01B394 : db $00 : org $07F454 : db $E2                                       ; Top right


;;; Checkerboard platform, vertical
org $01B32E : db $00 : org $07F455 : db $E2                                       ; Left tile
org $01B333 : db $01 : org $07F455 : db $E2                                       ; Middle tile
org $01B33E : db $02 : org $07F455 : db $E2                                       ; Right tile


;;; Flying rock platform, horizontal
org $01B38C : db $00 : org $07F456 : db $E2                                       ; Top left
org $01B38D : db $03 : org $07F456 : db $E2                                       ; Bottom left
org $01B38E : db $01 : org $07F456 : db $E2                                       ; Middle top
org $01B38F : db $04 : org $07F456 : db $E2                                       ; Middle bottom
org $01B390 : db $01 : org $07F456 : db $E2                                       ; Middle top
org $01B391 : db $04 : org $07F456 : db $E2                                       ; Middle bottom
org $01B392 : db $01 : org $07F456 : db $E2                                       ; Middle top
org $01B393 : db $03 : org $07F456 : db $E2                                       ; Bottom right
org $01B394 : db $00 : org $07F456 : db $E2                                       ; Top right


;;; Turn block bridge, horizontal and vertical
org $01B77E : db $40 : org $07F457 : db $E3                                       ; Tile


;;; Turn block bridge, horizontal
org $01B77E : db $40 : org $07F458 : db $E3                                       ; Tile


;;; Buoyant wooden platform
org $01B345 : db $00 : org $07F459 : db $E0                                       ; Left tile
org $01B34A : db $01 : org $07F459 : db $E0                                       ; Middle tile
org $01B355 : db $02 : org $07F459 : db $E0                                       ; Right tile


;;; Buoyant checkerboard platform
org $01B32E : db $00 : org $07F45A : db $E0                                       ; Left tile
org $01B333 : db $01 : org $07F45A : db $E0                                       ; Middle tile
org $01B33E : db $02 : org $07F45A : db $E0                                       ; Right tile


;;; Buoyant grassy orange platform
org $01B383 : db $00 : org $07F45B : db $EA                                       ; Top left
org $01B384 : db $03 : org $07F45B : db $EA                                       ; Bottom left
org $01B385 : db $01 : org $07F45B : db $EA                                       ; Middle top
org $01B386 : db $04 : org $07F45B : db $EA                                       ; Middle bottom
org $01B387 : db $01 : org $07F45B : db $EA                                       ; Middle top
org $01B388 : db $04 : org $07F45B : db $EA                                       ; Middle bottom
org $01B389 : db $01 : org $07F45B : db $EA                                       ; Middle top
org $01B38A : db $02 : org $07F45B : db $EA                                       ; Bottom right
org $01B38B : db $00 : org $07F45B : db $EA                                       ; Top right


;;; Flying grassy orange platform
org $01B383 : db $00 : org $07F45C : db $EA                                       ; Top left
org $01B384 : db $03 : org $07F45C : db $EA                                       ; Bottom left
org $01B385 : db $01 : org $07F45C : db $EA                                       ; Middle top
org $01B386 : db $04 : org $07F45C : db $EA                                       ; Middle bottom
org $01B387 : db $01 : org $07F45C : db $EA                                       ; Middle top
org $01B388 : db $04 : org $07F45C : db $EA                                       ; Middle bottom
org $01B389 : db $01 : org $07F45C : db $EA                                       ; Middle top
org $01B38A : db $02 : org $07F45C : db $EA                                       ; Bottom right
org $01B38B : db $00 : org $07F45C : db $EA                                       ; Top right


;;; Brown chained platform
org $01C7EA : db $04 : org $01C7EF : db $30                                       ; Chain "ball" 1
org $01C871 : db $04 : org $01C876 : db $30                                       ; Chain "ball" 2
org $01C8C7 : db $04 : org $01C8CC : db $30                                       ; Chain "ball" 3
org $01C8D3 : db $04 : org $01C8FB : db $30                                       ; Chain "ball" 4
org $01C9BB : db $00 : org $01C8FB : db $30                                       ; Platform 1
org $01C9BC : db $01 : org $01C8FB : db $30                                       ; Platform 2
org $01C9BD : db $01 : org $01C8FB : db $30                                       ; Platform 3
org $01C9BE : db $02 : org $01C8FB : db $30                                       ; Platform 4


;;; Flattened switch palace switch
org $02CD45 : db $00                                                              ; Tile 1
org $02CD46 : db $01                                                              ; Tile 2
org $02CD47 : db $01                                                              ; Tile 3
org $02CD48 : db $00                                                              ; Tile 4
org $02CD49 : db $10                                                              ; Tile 5
org $02CD4A : db $11                                                              ; Tile 6
org $02CD4B : db $11                                                              ; Tile 7
org $02CD4C : db $10                                                              ; Tile 8


;;; Skull raft
org $02EE04 : db $00 : org $07F45F : db $E2                                       ; Tile 1
org $02EE08 : db $02 : org $07F45F : db $E2                                       ; Tile 2


;;; Line-guided wooden platform
org $01B345 : db $00 : org $07F460 : db $E0                                       ; Left tile
org $01B34A : db $01 : org $07F460 : db $E0                                       ; Middle tile
org $01B355 : db $02 : org $07F460 : db $E0                                       ; Right tile


;;; Line-guided checkerboard/wooden platform
org $01B32E : db $00 : org $07F461 : db $E0                                       ; Left tile
org $01B333 : db $01 : org $07F461 : db $E0                                       ; Middle tile
org $01B33E : db $02 : org $07F461 : db $E0                                       ; Right tile


;;; Line-guided rope
org $01DC47 : db $00 : org $01DCA6 : db $36                                       ; Motor tile 1
org $01DC48 : db $02 : org $01DCA6 : db $36                                       ; Motor tile 2
org $01DC49 : db $04 : org $01DCA6 : db $36                                       ; Motor tile 3
org $01DC4A : db $02 : org $01DCA6 : db $36                                       ; Motor tile 4
org $01DC4B : db $00 : org $01DCAC : db $30                                       ; Unused?
org $01DC4C : db $06 : org $01DCAC : db $30                                       ; Rope tile 1
org $01DC4D : db $06 : org $01DCAC : db $30                                       ; Rope tile 2
org $01DC4E : db $06 : org $01DCAC : db $30                                       ; Rope tile 3
org $01DC4F : db $06 : org $01DCAC : db $30                                       ; Rope tile 4
org $01DC50 : db $06 : org $01DCAC : db $30                                       ; Rope tile 5
org $01DC51 : db $06 : org $01DCAC : db $30                                       ; Rope tile 6
org $01DC52 : db $06 : org $01DCAC : db $30                                       ; Rope tile 7
org $01DC53 : db $06 : org $01DCAC : db $30                                       ; Rope tile 8


;;; Line-guided chainsaw
org $03C25B : db $00 : org $03C2C5 : db $36                                       ; Motor tile 1
org $03C25C : db $02 : org $03C2C5 : db $36                                       ; Motor tile 2
org $03C25D : db $04 : org $03C2C5 : db $36                                       ; Motor tile 3
org $03C25E : db $02 : org $03C2C5 : db $36                                       ; Motor tile 4
org $03C2BB : db $06 : org $03C261 : db $32                                       ; Blade 1
org $03C2C0 : db $08 : org $03C261 : db $32                                       ; Blade 2


;;; Upside-down line-guided chainsaw
org $03C25B : db $00 : org $03C2C5 : db $36                                       ; Motor tile 1
org $03C25C : db $02 : org $03C2C5 : db $36                                       ; Motor tile 2
org $03C25D : db $04 : org $03C2C5 : db $36                                       ; Motor tile 3
org $03C25E : db $02 : org $03C2C5 : db $36                                       ; Motor tile 4
org $03C2BB : db $06 : org $03C262 : db $B2                                       ; Blade 1
org $03C2C0 : db $08 : org $03C262 : db $B2                                       ; Blade 2


;;; Line-guided grinder
org $01DC28 : db $00 : org $01DC43 : db $32                                       ; Top left
org $01DC28 : db $00 : org $01DC44 : db $72                                       ; Top right
org $01DC28 : db $00 : org $01DC45 : db $B2                                       ; Bottom left
org $01DC28 : db $00 : org $01DC46 : db $F2                                       ; Bottom right


;;; Line-guided fuzzy
org $01DBF5 : db $00 : org $01DC09 : db $04                                       ; Tile 1
org $01DBF5 : db $00 : org $01DC0A : db $44                                       ; Tile 2


;;; Null


;;; Coin game cloud
org $02EF2E : db $60 : org $02EF3A : db $30                                       ; Cloud
org $02EF56 : db $4D : org $02EF5B : db $39 : org $02EF60 : db $00                ; Face


;;; Pea bouncer, left wall
org $02CF2C : db $00 : org $02CF33 : db $0A                                       ; Tile


;;; Pea bouncer, right wall
org $02CF2C : db $00 : org $02CF33 : db $0A                                       ; Tile


;;; Invisible solid block


;;; Dino Rhino
org $039E39 : db $C0 : org $039E2D : db $2F                                       ; Walking 1, top left, facing left
org $039E3A : db $C2 : org $039E2E : db $2F                                       ; Walking 1, top right, facing left
org $039E3B : db $E4 : org $039E2F : db $2F                                       ; Walking 1, bottom left, facing left
org $039E3C : db $E6 : org $039E30 : db $2F                                       ; Walking 1, bottom right, facing left
org $039E3D : db $C0 : org $039E2D : db $2F                                       ; Walking 2, top left, facing left
org $039E3E : db $C2 : org $039E2E : db $2F                                       ; Walking 2, top right, facing left
org $039E3F : db $E0 : org $039E2F : db $2F                                       ; Walking 2, bottom left, facing left
org $039E40 : db $E2 : org $039E30 : db $2F                                       ; Walking 2, bottom right, facing left
org $039E41 : db $C8 : org $039E2D : db $2F                                       ; Fire 1, top left, facing left
org $039E42 : db $CA : org $039E2E : db $2F                                       ; Fire 1, top right, facing left
org $039E43 : db $E8 : org $039E2F : db $2F                                       ; Fire 1, bottom left, facing left
org $039E44 : db $E2 : org $039E30 : db $2F                                       ; Fire 1, bottom right, facing left
org $039E45 : db $CC : org $039E2D : db $2F                                       ; Fire 2, top left, facing left
org $039E46 : db $CE : org $039E2E : db $2F                                       ; Fire 2, top right, facing left
org $039E47 : db $EC : org $039E2F : db $2F                                       ; Fire 2, bottom left, facing left
org $039E48 : db $EE : org $039E30 : db $2F                                       ; Fire 2, bottom right, facing left
org $039E39 : db $C0 : org $039E31 : db $6F                                       ; Walking 1, top left, facing left
org $039E3A : db $C2 : org $039E32 : db $6F                                       ; Walking 1, top right, facing left
org $039E3B : db $E4 : org $039E33 : db $6F                                       ; Walking 1, bottom left, facing left
org $039E3C : db $E6 : org $039E34 : db $6F                                       ; Walking 1, bottom right, facing left
org $039E3D : db $C0 : org $039E31 : db $6F                                       ; Walking 2, top left, facing left
org $039E3E : db $C2 : org $039E32 : db $6F                                       ; Walking 2, top right, facing left
org $039E3F : db $E0 : org $039E33 : db $6F                                       ; Walking 2, bottom left, facing left
org $039E40 : db $E2 : org $039E34 : db $6F                                       ; Walking 2, bottom right, facing left
org $039E41 : db $C8 : org $039E31 : db $6F                                       ; Fire 1, top left, facing left
org $039E42 : db $CA : org $039E32 : db $6F                                       ; Fire 1, top right, facing left
org $039E43 : db $E8 : org $039E33 : db $6F                                       ; Fire 1, bottom left, facing left
org $039E44 : db $E2 : org $039E34 : db $6F                                       ; Fire 1, bottom right, facing left
org $039E45 : db $CC : org $039E31 : db $6F                                       ; Fire 2, top left, facing left
org $039E46 : db $CE : org $039E32 : db $6F                                       ; Fire 2, top right, facing left
org $039E47 : db $EC : org $039E33 : db $6F                                       ; Fire 2, bottom left, facing left
org $039E48 : db $EE : org $039E34 : db $6F                                       ; Fire 2, bottom right, facing left


;;; Dino Torch
org $039E21 : db $EA : org $07F46D : db $0F                                       ; Walking 1
org $039E22 : db $AA : org $07F46D : db $0F                                       ; Walking 2
org $039E23 : db $C4 : org $07F46D : db $0F                                       ; Fire 1
org $039E24 : db $C6 : org $07F46D : db $0F                                       ; Fire 1
org $019B0B : db $AC : org $07F46D : db $0F                                       ; Smushed
org $039E12 : db $80                                                              ; Horizontal flame 1
org $039E13 : db $82                                                              ; Horizontal flame 2
org $039E14 : db $84                                                              ; Horizontal flame 3
org $039E15 : db $86                                                              ; Horizontal flame 4
org $039E16 : db $00                                                              ; Unused?
org $039E17 : db $88                                                              ; Vertical flame 6
org $039E18 : db $8A                                                              ; Vertical flame 7
org $039E19 : db $8C                                                              ; Vertical flame 8
org $039E1A : db $8E                                                              ; Vertical flame 9
org $039E1B : db $00                                                              ; Unused?


;;; Pokey
org $02B790 : db $00 : org $07F46E : db $34                                       ; Head
org $02B68D : db $00 : org $07F46E : db $34                                       ; Head (while being eaten)
org $02B78C : db $02 : org $07F46E : db $34                                       ; Body
org $02B691 : db $02 : org $07F46E : db $34                                       ; Body


;;; Super koopa, green
org $02EC72 : db $C8 : org $02EC96 : db $03 : org $02ECBA : db $00                ; Take-off 1, cape 1
org $02EC73 : db $D8 : org $02EC97 : db $03 : org $02ECBB : db $00                ; Take-off 1, cape 2
org $02EC74 : db $D0 : org $02EC98 : db $03 : org $02ECBC : db $00                ; Take-off 1, cape 3
org $02EC75 : db $E0 : org $02EC99 : db $00 : org $02ECBD : db $02                ; Take-off 1, body
org $02EC76 : db $C9 : org $02EC9A : db $03 : org $02ECBE : db $00                ; Take-off 2, cape 1
org $02EC77 : db $D9 : org $02EC9B : db $03 : org $02ECBF : db $00                ; Take-off 2, cape 2
org $02EC78 : db $C0 : org $02EC9C : db $03 : org $02ECC0 : db $00                ; Take-off 2, cape 3
org $02EC79 : db $E2 : org $02EC9D : db $00 : org $02ECC1 : db $02                ; Take-off 2, body
org $02EC7A : db $E4 : org $02EC9E : db $03 : org $02ECC2 : db $00                ; Flying 1, cape 1
org $02EC7B : db $E5 : org $02EC9F : db $03 : org $02ECC3 : db $00                ; Flying 1, cape 2
org $02EC7C : db $F2 : org $02ECA0 : db $01 : org $02ECC4 : db $00                ; Flying 1, foot
org $02EC7D : db $E0 : org $02ECA1 : db $01 : org $02ECC5 : db $02                ; Flying 1, body
org $02EC7E : db $F4 : org $02ECA2 : db $03 : org $02ECC6 : db $00                ; Flying 2, cape 1
org $02EC7F : db $F5 : org $02ECA3 : db $03 : org $02ECC7 : db $00                ; Flying 2, cape 2
org $02EC80 : db $F2 : org $02ECA4 : db $01 : org $02ECC8 : db $00                ; Flying 2, foot
org $02EC81 : db $E0 : org $02ECA5 : db $01 : org $02ECC9 : db $02                ; Flying 2, body
org $02EC82 : db $DA : org $02ECA6 : db $83 : org $02ECCA : db $00                ; Stomped 1, cape 1
org $02EC83 : db $CA : org $02ECA7 : db $83 : org $02ECCB : db $00                ; Stomped 1, cape 2
org $02EC84 : db $E0 : org $02ECA8 : db $80 : org $02ECCC : db $02                ; Stomped 1, body
org $02EC85 : db $CF : org $02ECA9 : db $00 : org $02ECCD : db $00                ; Stomped 1, empty
org $02EC86 : db $DB : org $02ECAA : db $83 : org $02ECCE : db $00                ; Stomped 2, cape 1
org $02EC87 : db $CB : org $02ECAB : db $83 : org $02ECCF : db $00                ; Stomped 2, cape 2
org $02EC88 : db $E0 : org $02ECAC : db $80 : org $02ECD0 : db $02                ; Stomped 2, body
org $02EC89 : db $CF : org $02ECAD : db $00 : org $02ECD1 : db $00                ; Stomped 2, empty
org $02EC8A : db $E4 : org $02ECAE : db $03 : org $02ECD2 : db $00                ; Take-off 3, cape 1
org $02EC8B : db $E5 : org $02ECAF : db $03 : org $02ECD3 : db $00                ; Take-off 3, cape 2
org $02EC8C : db $E0 : org $02ECB0 : db $00 : org $02ECD4 : db $02                ; Take-off 3, body
org $02EC8D : db $CF : org $02ECB1 : db $01 : org $02ECD5 : db $00                ; Take-off 3, empty
org $02EC8E : db $F4 : org $02ECB2 : db $03 : org $02ECD6 : db $00                ; Take-off 4, cape 1
org $02EC8F : db $F5 : org $02ECB3 : db $03 : org $02ECD7 : db $00                ; Take-off 4, cape 2
org $02EC90 : db $E2 : org $02ECB4 : db $00 : org $02ECD8 : db $02                ; Take-off 4, body
org $02EC91 : db $CF : org $02ECB5 : db $01 : org $02ECD9 : db $00                ; Take-off 4, empty
org $02EC92 : db $E4 : org $02ECB6 : db $03 : org $02ECDA : db $00                ; Take-off 5, cape 1
org $02EC93 : db $E5 : org $02ECB7 : db $03 : org $02ECDB : db $00                ; Take-off 5, cape 2
org $02EC94 : db $E2 : org $02ECB8 : db $00 : org $02ECDC : db $02                ; Take-off 5, body
org $02EC95 : db $CF : org $02ECB9 : db $01 : org $02ECDD : db $00                ; Take-off 5, empty


;;; Super koopa, red
org $02EC72 : db $C8 : org $02EC96 : db $03 : org $02ECBA : db $00                ; Take-off 1, cape 1
org $02EC73 : db $D8 : org $02EC97 : db $03 : org $02ECBB : db $00                ; Take-off 1, cape 2
org $02EC74 : db $D0 : org $02EC98 : db $03 : org $02ECBC : db $00                ; Take-off 1, cape 3
org $02EC75 : db $E0 : org $02EC99 : db $00 : org $02ECBD : db $02                ; Take-off 1, body
org $02EC76 : db $C9 : org $02EC9A : db $03 : org $02ECBE : db $00                ; Take-off 2, cape 1
org $02EC77 : db $D9 : org $02EC9B : db $03 : org $02ECBF : db $00                ; Take-off 2, cape 2
org $02EC78 : db $C0 : org $02EC9C : db $03 : org $02ECC0 : db $00                ; Take-off 2, cape 3
org $02EC79 : db $E2 : org $02EC9D : db $00 : org $02ECC1 : db $02                ; Take-off 2, body
org $02EC7A : db $E4 : org $02EC9E : db $03 : org $02ECC2 : db $00                ; Flying 1, cape 1
org $02EC7B : db $E5 : org $02EC9F : db $03 : org $02ECC3 : db $00                ; Flying 1, cape 2
org $02EC7C : db $F2 : org $02ECA0 : db $01 : org $02ECC4 : db $00                ; Flying 1, foot
org $02EC7D : db $E0 : org $02ECA1 : db $01 : org $02ECC5 : db $02                ; Flying 1, body
org $02EC7E : db $F4 : org $02ECA2 : db $03 : org $02ECC6 : db $00                ; Flying 2, cape 1
org $02EC7F : db $F5 : org $02ECA3 : db $03 : org $02ECC7 : db $00                ; Flying 2, cape 2
org $02EC80 : db $F2 : org $02ECA4 : db $01 : org $02ECC8 : db $00                ; Flying 2, foot
org $02EC81 : db $E0 : org $02ECA5 : db $01 : org $02ECC9 : db $02                ; Flying 2, body
org $02EC82 : db $DA : org $02ECA6 : db $83 : org $02ECCA : db $00                ; Stomped 1, cape 1
org $02EC83 : db $CA : org $02ECA7 : db $83 : org $02ECCB : db $00                ; Stomped 1, cape 2
org $02EC84 : db $E0 : org $02ECA8 : db $80 : org $02ECCC : db $02                ; Stomped 1, body
org $02EC85 : db $CF : org $02ECA9 : db $00 : org $02ECCD : db $00                ; Stomped 1, empty
org $02EC86 : db $DB : org $02ECAA : db $83 : org $02ECCE : db $00                ; Stomped 2, cape 1
org $02EC87 : db $CB : org $02ECAB : db $83 : org $02ECCF : db $00                ; Stomped 2, cape 2
org $02EC88 : db $E0 : org $02ECAC : db $80 : org $02ECD0 : db $02                ; Stomped 2, body
org $02EC89 : db $CF : org $02ECAD : db $00 : org $02ECD1 : db $00                ; Stomped 2, empty
org $02EC8A : db $E4 : org $02ECAE : db $03 : org $02ECD2 : db $00                ; Take-off 3, cape 1
org $02EC8B : db $E5 : org $02ECAF : db $03 : org $02ECD3 : db $00                ; Take-off 3, cape 2
org $02EC8C : db $E0 : org $02ECB0 : db $00 : org $02ECD4 : db $02                ; Take-off 3, body
org $02EC8D : db $CF : org $02ECB1 : db $01 : org $02ECD5 : db $00                ; Take-off 3, empty
org $02EC8E : db $F4 : org $02ECB2 : db $03 : org $02ECD6 : db $00                ; Take-off 4, cape 1
org $02EC8F : db $F5 : org $02ECB3 : db $03 : org $02ECD7 : db $00                ; Take-off 4, cape 2
org $02EC90 : db $E2 : org $02ECB4 : db $00 : org $02ECD8 : db $02                ; Take-off 4, body
org $02EC91 : db $CF : org $02ECB5 : db $01 : org $02ECD9 : db $00                ; Take-off 4, empty
org $02EC92 : db $E4 : org $02ECB6 : db $03 : org $02ECDA : db $00                ; Take-off 5, cape 1
org $02EC93 : db $E5 : org $02ECB7 : db $03 : org $02ECDB : db $00                ; Take-off 5, cape 2
org $02EC94 : db $E2 : org $02ECB8 : db $00 : org $02ECDC : db $02                ; Take-off 5, body
org $02EC95 : db $CF : org $02ECB9 : db $01 : org $02ECDD : db $00                ; Take-off 5, empty


;;; Super koopa, blue
org $02EC72 : db $C8 : org $02EC96 : db $03 : org $02ECBA : db $00                ; Take-off 1, cape 1
org $02EC73 : db $D8 : org $02EC97 : db $03 : org $02ECBB : db $00                ; Take-off 1, cape 2
org $02EC74 : db $D0 : org $02EC98 : db $03 : org $02ECBC : db $00                ; Take-off 1, cape 3
org $02EC75 : db $E0 : org $02EC99 : db $00 : org $02ECBD : db $02                ; Take-off 1, body
org $02EC76 : db $C9 : org $02EC9A : db $03 : org $02ECBE : db $00                ; Take-off 2, cape 1
org $02EC77 : db $D9 : org $02EC9B : db $03 : org $02ECBF : db $00                ; Take-off 2, cape 2
org $02EC78 : db $C0 : org $02EC9C : db $03 : org $02ECC0 : db $00                ; Take-off 2, cape 3
org $02EC79 : db $E2 : org $02EC9D : db $00 : org $02ECC1 : db $02                ; Take-off 2, body
org $02EC7A : db $E4 : org $02EC9E : db $03 : org $02ECC2 : db $00                ; Flying 1, cape 1
org $02EC7B : db $E5 : org $02EC9F : db $03 : org $02ECC3 : db $00                ; Flying 1, cape 2
org $02EC7C : db $F2 : org $02ECA0 : db $01 : org $02ECC4 : db $00                ; Flying 1, foot
org $02EC7D : db $E0 : org $02ECA1 : db $01 : org $02ECC5 : db $02                ; Flying 1, body
org $02EC7E : db $F4 : org $02ECA2 : db $03 : org $02ECC6 : db $00                ; Flying 2, cape 1
org $02EC7F : db $F5 : org $02ECA3 : db $03 : org $02ECC7 : db $00                ; Flying 2, cape 2
org $02EC80 : db $F2 : org $02ECA4 : db $01 : org $02ECC8 : db $00                ; Flying 2, foot
org $02EC81 : db $E0 : org $02ECA5 : db $01 : org $02ECC9 : db $02                ; Flying 2, body
org $02EC82 : db $DA : org $02ECA6 : db $83 : org $02ECCA : db $00                ; Stomped 1, cape 1
org $02EC83 : db $CA : org $02ECA7 : db $83 : org $02ECCB : db $00                ; Stomped 1, cape 2
org $02EC84 : db $E0 : org $02ECA8 : db $80 : org $02ECCC : db $02                ; Stomped 1, body
org $02EC85 : db $CF : org $02ECA9 : db $00 : org $02ECCD : db $00                ; Stomped 1, empty
org $02EC86 : db $DB : org $02ECAA : db $83 : org $02ECCE : db $00                ; Stomped 2, cape 1
org $02EC87 : db $CB : org $02ECAB : db $83 : org $02ECCF : db $00                ; Stomped 2, cape 2
org $02EC88 : db $E0 : org $02ECAC : db $80 : org $02ECD0 : db $02                ; Stomped 2, body
org $02EC89 : db $CF : org $02ECAD : db $00 : org $02ECD1 : db $00                ; Stomped 2, empty
org $02EC8A : db $E4 : org $02ECAE : db $03 : org $02ECD2 : db $00                ; Take-off 3, cape 1
org $02EC8B : db $E5 : org $02ECAF : db $03 : org $02ECD3 : db $00                ; Take-off 3, cape 2
org $02EC8C : db $E0 : org $02ECB0 : db $00 : org $02ECD4 : db $02                ; Take-off 3, body
org $02EC8D : db $CF : org $02ECB1 : db $01 : org $02ECD5 : db $00                ; Take-off 3, empty
org $02EC8E : db $F4 : org $02ECB2 : db $03 : org $02ECD6 : db $00                ; Take-off 4, cape 1
org $02EC8F : db $F5 : org $02ECB3 : db $03 : org $02ECD7 : db $00                ; Take-off 4, cape 2
org $02EC90 : db $E2 : org $02ECB4 : db $00 : org $02ECD8 : db $02                ; Take-off 4, body
org $02EC91 : db $CF : org $02ECB5 : db $01 : org $02ECD9 : db $00                ; Take-off 4, empty
org $02EC92 : db $E4 : org $02ECB6 : db $03 : org $02ECDA : db $00                ; Take-off 5, cape 1
org $02EC93 : db $E5 : org $02ECB7 : db $03 : org $02ECDB : db $00                ; Take-off 5, cape 2
org $02EC94 : db $E2 : org $02ECB8 : db $00 : org $02ECDC : db $02                ; Take-off 5, body
org $02EC95 : db $CF : org $02ECB9 : db $01 : org $02ECDD : db $00                ; Take-off 5, empty


;;; Mushroom
org $01C609 : db $40 : org $07F472 : db $08                                       ; Normal
org $008DFA : db $40 : org $008E02 : db $08 : org $0090CC : db $02                ; In reserve box


;;; Fire flower
org $01C60A : db $42 : org $07F473 : db $0A                                       ; Normal
org $008DFB : db $42 : org $008E03 : db $0A : org $0090CC : db $02                ; In reserve box


;;; Star
org $01C60B : db $44 : org $07F474 : db $20                                       ; Normal
org $008DFC : db $44 : org $008E04 : db $00 : org $0090CC : db $02                ; In reserve box


;;; Feather
org $01C60C : db $0E : org $07F475 : db $24                                       ; Normal
org $008DFD : db $0E : org $008E05 : db $04 : org $0090CC : db $02                ; In reserve box


;;; 1-UP mushroom
org $01C60D : db $40 : org $07F476 : db $0A                                       ; Tile


;;; Growing vine
org $01C19E : db $AC : org $07F477 : db $3A                                       ; Frame 1
org $01C1A2 : db $AE : org $07F477 : db $3A                                       ; Frame 2


;;; Firework
org $03C9B9 : db $36 : org $03CAC0 : db $31                                       ; Frame 1
org $03C9BA : db $35 : org $03CAC0 : db $31                                       ; Frame 2
org $03C9BB : db $C7 : org $03CAC0 : db $31                                       ; Frame 3
org $03C9BC : db $34 : org $03CAC0 : db $31                                       ; Frame 4
org $03C9BD : db $34 : org $03CAC0 : db $31                                       ; Frame 5
org $03C9BE : db $34 : org $03CAC0 : db $31                                       ; Frame 6
org $03C9BF : db $34 : org $03CAC0 : db $31                                       ; Frame 7
org $03C9C0 : db $24 : org $03CAC0 : db $31                                       ; Frame 8
org $03C9C1 : db $03 : org $03CAC0 : db $31                                       ; Frame 9
org $03C9C2 : db $03 : org $03CAC0 : db $31                                       ; Frame 10
org $03C9C3 : db $36 : org $03CAC0 : db $31                                       ; Frame 11
org $03C9C4 : db $35 : org $03CAC0 : db $31                                       ; Frame 12
org $03C9C5 : db $C7 : org $03CAC0 : db $31                                       ; Frame 13
org $03C9C6 : db $34 : org $03CAC0 : db $31                                       ; Frame 14
org $03C9C7 : db $34 : org $03CAC0 : db $31                                       ; Frame 15
org $03C9C8 : db $24 : org $03CAC0 : db $31                                       ; Frame 16
org $03C9C9 : db $24 : org $03CAC0 : db $31                                       ; Frame 17
org $03C9CA : db $24 : org $03CAC0 : db $31                                       ; Frame 18
org $03C9CB : db $24 : org $03CAC0 : db $31                                       ; Frame 19
org $03C9CC : db $03 : org $03CAC0 : db $31                                       ; Frame 20
org $03C9CD : db $36 : org $03CAC0 : db $31                                       ; Frame 21
org $03C9CE : db $35 : org $03CAC0 : db $31                                       ; Frame 22
org $03C9CF : db $C7 : org $03CAC0 : db $31                                       ; Frame 23
org $03C9D0 : db $34 : org $03CAC0 : db $31                                       ; Frame 24
org $03C9D1 : db $34 : org $03CAC0 : db $31                                       ; Frame 25
org $03C9D2 : db $34 : org $03CAC0 : db $31                                       ; Frame 26
org $03C9D3 : db $24 : org $03CAC0 : db $31                                       ; Frame 27
org $03C9D4 : db $24 : org $03CAC0 : db $31                                       ; Frame 28
org $03C9D5 : db $03 : org $03CAC0 : db $31                                       ; Frame 29
org $03C9D6 : db $24 : org $03CAC0 : db $31                                       ; Frame 30
org $03C9D7 : db $36 : org $03CAC0 : db $31                                       ; Frame 31
org $03C9D8 : db $35 : org $03CAC0 : db $31                                       ; Frame 32
org $03C9D9 : db $C7 : org $03CAC0 : db $31                                       ; Frame 33
org $03C9DA : db $34 : org $03CAC0 : db $31                                       ; Frame 34
org $03C9DB : db $24 : org $03CAC0 : db $31                                       ; Frame 35
org $03C9DC : db $24 : org $03CAC0 : db $31                                       ; Frame 36
org $03C9DD : db $24 : org $03CAC0 : db $31                                       ; Frame 37
org $03C9DE : db $24 : org $03CAC0 : db $31                                       ; Frame 38
org $03C9DF : db $24 : org $03CAC0 : db $31                                       ; Frame 39
org $03C9E0 : db $03 : org $03CAC0 : db $31                                       ; Frame 40


;;; Goal tape
org $01C158 : db $D4 : org $01C164 : db $32 : org $01C16F : db $00                ; Tile


;;; Princess Peach


;;; P-balloon
org $01C612 : db $00 : org $07F47B : db $20                                       ; Tile


;;; Flying red coin
org $01C613 : db $E8 : org $07F47C : db $28                                       ; Tile


;;; Flying 1-UP
org $01C614 : db $24 : org $07F47D : db $20                                       ; Tile


;;; Key
org $01A1FA : db $02 : org $07F47E : db $20                                       ; Tile


;;; Changing powerup


;;; Bonus game
org $01DF8D : db $E4 : org $01DFA4 : db $01                                       ; Background tile
org $01DEE3 : db $58 : org $01DF07 : db $04                                       ; Tile 1
org $01DEE4 : db $59 : org $01DF07 : db $04                                       ; Tile 2
org $01DEE5 : db $83 : org $01DF07 : db $04                                       ; Tile 3
org $01DEE6 : db $83 : org $01DF07 : db $04                                       ; Tile 4
org $01DEE7 : db $48 : org $01DF08 : db $04                                       ; Tile 5
org $01DEE8 : db $49 : org $01DF08 : db $04                                       ; Tile 6
org $01DEE9 : db $58 : org $01DF08 : db $04                                       ; Tile 7
org $01DEEA : db $59 : org $01DF08 : db $04                                       ; Tile 8
org $01DEEB : db $83 : org $01DF09 : db $04                                       ; Tile 9
org $01DEEC : db $83 : org $01DF09 : db $04                                       ; Tile 10
org $01DEED : db $48 : org $01DF09 : db $04                                       ; Tile 11
org $01DEEE : db $49 : org $01DF09 : db $04                                       ; Tile 12
org $01DEEF : db $34 : org $01DF0A : db $08                                       ; Tile 13
org $01DEF0 : db $35 : org $01DF0A : db $08                                       ; Tile 14
org $01DEF1 : db $83 : org $01DF0A : db $08                                       ; Tile 15
org $01DEF2 : db $83 : org $01DF0A : db $08                                       ; Tile 16
org $01DEF3 : db $24 : org $01DF0B : db $08                                       ; Tile 17
org $01DEF4 : db $25 : org $01DF0B : db $08                                       ; Tile 18
org $01DEF5 : db $34 : org $01DF0B : db $08                                       ; Tile 19
org $01DEF6 : db $35 : org $01DF0B : db $08                                       ; Tile 20
org $01DEF7 : db $83 : org $01DF0C : db $08                                       ; Tile 21
org $01DEF8 : db $83 : org $01DF0C : db $08                                       ; Tile 22
org $01DEF9 : db $24 : org $01DF0C : db $08                                       ; Tile 23
org $01DEFA : db $25 : org $01DF0C : db $08                                       ; Tile 24
org $01DEFB : db $36 : org $01DF0D : db $0A                                       ; Tile 25
org $01DEFC : db $37 : org $01DF0D : db $0A                                       ; Tile 26
org $01DEFD : db $83 : org $01DF0D : db $0A                                       ; Tile 27
org $01DEFE : db $83 : org $01DF0D : db $0A                                       ; Tile 28
org $01DEFF : db $26 : org $01DF0E : db $0A                                       ; Tile 29
org $01DE00 : db $B9 : org $01DF0E : db $0A                                       ; Tile 30
org $01DF01 : db $36 : org $01DF0E : db $0A                                       ; Tile 31
org $01DF02 : db $37 : org $01DF0E : db $0A                                       ; Tile 32
org $01DF03 : db $83 : org $01DF0F : db $0A                                       ; Tile 33
org $01DF04 : db $83 : org $01DF0F : db $0A                                       ; Tile 34
org $01DF05 : db $26 : org $01DF0F : db $0A                                       ; Tile 35
org $01DF06 : db $27 : org $01DF0F : db $0A                                       ; Tile 36


;;; Flying ? Block, left
org $01AE76 : db $80 : org $07F481 : db $20                                       ; ? block
org $01AE7A : db $82 : org $07F481 : db $20                                       ; Hit


;;; Flying ? Block, back and forth
org $01AE76 : db $80 : org $07F482 : db $20                                       ; ? block
org $01AE7A : db $82 : org $07F482 : db $20                                       ; Hit


;;; Null


;;; Wiggler
org $02F16E : db $00 : org $07F484 : db $F4                                       ; Head 1
org $02F10C : db $02 : org $07F484 : db $F4                                       ; Body 1
org $02F10D : db $04 : org $07F484 : db $F4                                       ; Body 2
org $02F10E : db $06 : org $07F484 : db $F4                                       ; Body 3
org $02F10F : db $04 : org $07F484 : db $F4                                       ; Body 4
org $02F1BE : db $08 : org $07F484 : db $F4                                       ; Angry eyes
org $029D30 : db $18 : org $029D35 : db $0A : org $029D40 : db $00                ; Wiggler's flower


;;; Lakitu's cloud
org $01E985 : db $66 : org $07F485 : db $20                                       ; Cloud 1
org $01E986 : db $64 : org $07F485 : db $20                                       ; Cloud 2
org $01E987 : db $62 : org $07F485 : db $20                                       ; Cloud 3
org $01E988 : db $60 : org $07F485 : db $20                                       ; Cloud 4
org $01E976 : db $08 : org $01E97B : db $38                                       ; Face


;;; Winged cage


;;; Layer 3 smash


;;; Birds on Yoshi's house
org $02F3DB : db $00                                                              ; Tile 1
org $02F3DC : db $01                                                              ; Tile 2
org $02F3DD : db $10                                                              ; Tile 3
org $02F3DE : db $11                                                              ; Tile 4
org $02F3DF : db $02                                                              ; Tile 5


;;; Yoshi's house smoke
org $02F4AF : db $C5 : org $02F4B7 : db $05                                       ; Tile


;;; Side exit enable


;;; Ghost house exit
org $02F5BC : db $9C : org $02F5C6 : db $23                                       ; Sign 1
org $02F5BD : db $9E : org $02F5C7 : db $23                                       ; Sign 2
org $02F5BE : db $A0 : org $02F5C8 : db $2D                                       ; Door 1
org $02F5BF : db $B0 : org $02F5C9 : db $2D                                       ; Door 2
org $02F5C0 : db $B0 : org $02F5CA : db $AD                                       ; Door 3
org $02F5C1 : db $A0 : org $02F5CB : db $AD                                       ; Door 4
org $02F5C2 : db $A0 : org $02F5CC : db $6D                                       ; Door 5
org $02F5C3 : db $B0 : org $02F5CD : db $6D                                       ; Door 6
org $02F5C4 : db $B0 : org $02F5CE : db $ED                                       ; Door 7
org $02F5C5 : db $A0 : org $02F5CF : db $ED                                       ; Door 8


;;; Invisible "warp hole"


;;; Mushroom scale platforms
org $02E599 : db $00 : org $07F48D : db $3A                                       ; Tile


;;; Large gas bubble
org $02E372 : db $80 : org $02E382 : db $3B : org $02E411 : db $02                ; Tile 1
org $02E373 : db $82 : org $02E383 : db $3B : org $02E411 : db $02                ; Tile 2
org $02E374 : db $84 : org $02E384 : db $3B : org $02E411 : db $02                ; Tile 3
org $02E375 : db $86 : org $02E385 : db $3B : org $02E411 : db $02                ; Tile 4
org $02E376 : db $A0 : org $02E386 : db $3B : org $02E411 : db $02                ; Tile 5
org $02E377 : db $A2 : org $02E387 : db $3B : org $02E411 : db $02                ; Tile 6
org $02E378 : db $A4 : org $02E388 : db $3B : org $02E411 : db $02                ; Tile 7
org $02E379 : db $A6 : org $02E389 : db $3B : org $02E411 : db $02                ; Tile 8
org $02E37A : db $A0 : org $02E38A : db $BB : org $02E411 : db $02                ; Tile 9
org $02E37B : db $A2 : org $02E38B : db $BB : org $02E411 : db $02                ; Tile 10
org $02E37C : db $A4 : org $02E38C : db $BB : org $02E411 : db $02                ; Tile 11
org $02E37D : db $A6 : org $02E38D : db $BB : org $02E411 : db $02                ; Tile 12
org $02E37E : db $80 : org $02E38E : db $BB : org $02E411 : db $02                ; Tile 13
org $02E37F : db $82 : org $02E38F : db $BB : org $02E411 : db $02                ; Tile 14
org $02E380 : db $84 : org $02E390 : db $BB : org $02E411 : db $02                ; Tile 15
org $02E381 : db $86 : org $02E391 : db $BB : org $02E411 : db $02                ; Tile 16


;;; Chargin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Splittin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Bouncin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Whistlin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Clappin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Clone'd Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Puntin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Pitchin' Chuck
org $02CA97 : db $0C : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 1
org $02CA98 : db $44 : org $07F444 : db $8B                                       ; Clappin' Chuck's hand 2
org $02CB17 : db $1C : org $07F444 : db $8B                                       ; Chargin' Chuck's arm
org $02CB7C : db $AD : org $07F444 : db $8B                                       ; Pitchin' Chuck's held baseball
org $02CB98 : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shoulder
org $02CB99 : db $00 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 1
org $02CB9A : db $F8 : org $07F444 : db $8B                                       ; Diggin' Chuck's shovel 2
org $02C87E : db $06 : org $07F444 : db $8B                                       ; Head, looking right
org $02C87F : db $0A : org $07F444 : db $8B                                       ; Head, looking aside right
org $02C880 : db $0E : org $07F444 : db $8B                                       ; Head, facing camera
org $02C881 : db $0A : org $07F444 : db $8B                                       ; Head, looking aside left
org $02C882 : db $06 : org $07F444 : db $8B                                       ; Head, looking left
org $02C883 : db $4B : org $07F444 : db $8B                                       ; Head, looking up left
org $02C884 : db $4B : org $07F444 : db $8B                                       ; Head, looking up right
org $02C98B : db $0D : org $07F444 : db $8B                                       ; Pitchin' body (1)
org $02C9A5 : db $4E : org $07F444 : db $8B                                       ; Pitchin' body (2)
org $02C98C : db $34 : org $07F444 : db $8B                                       ; Unknown 1 (1)
org $02C9A6 : db $0C : org $07F444 : db $8B                                       ; Unknown 1 (2)
org $02C98D : db $35 : org $07F444 : db $8B                                       ; Unknown 2 (1)
org $02C9A7 : db $22 : org $07F444 : db $8B                                       ; Unknown 2 (2)
org $02C98E : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (1)
org $02C9A8 : db $26 : org $07F444 : db $8B                                       ; Squatting 1 (2)
org $02C98F : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9A9 : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C990 : db $28 : org $07F444 : db $8B                                       ; About to run 2 (1)
org $02C9AA : db $29 : org $07F444 : db $8B                                       ; About to run 1 (2)
org $02C991 : db $40 : org $07F444 : db $8B                                       ; Jumping (1)
org $02C9AB : db $40 : org $07F444 : db $8B                                       ; Jumping (2)
org $02C992 : db $42 : org $07F444 : db $8B                                       ; Clapping body (1)
org $02C9AC : db $42 : org $07F444 : db $8B                                       ; Clapping body (2)
org $02C993 : db $5D : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (1)
org $02C9AD : db $AE : org $07F444 : db $8B                                       ; Pitchin' chuck about to throw (2)
org $02C994 : db $2D : org $07F444 : db $8B                                       ; About to jump (1)
org $02C9AE : db $2D : org $07F444 : db $8B                                       ; About to jump (2)
org $02C995 : db $64 : org $07F444 : db $8B                                       ; Jumped on (1)
org $02C9AF : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C996 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C9B0 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C997 : db $64 : org $07F444 : db $8B                                       ; Jumped on (3)
org $02C9B1 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C998 : db $64 : org $07F444 : db $8B                                       ; Jumped on (4)
org $02C9B2 : db $64 : org $07F444 : db $8B                                       ; Jumped on (2)
org $02C999 : db $E7 : org $07F444 : db $8B                                       ; Digging 1 (1)
org $02C9B3 : db $E8 : org $07F444 : db $8B                                       ; Digging 1 (2)
org $02C99A : db $28 : org $07F444 : db $8B                                       ; Digging 2 (1)
org $02C9B4 : db $29 : org $07F444 : db $8B                                       ; Digging 2 (2)
org $02C99B : db $82 : org $07F444 : db $8B                                       ; Digging 3 (1)
org $02C9B5 : db $83 : org $07F444 : db $8B                                       ; Digging 3 (2)
org $02C99C : db $CB : org $07F444 : db $8B                                       ; Punting 1 (1)
org $02C9B6 : db $CC : org $07F444 : db $8B                                       ; Punting 1 (2)
org $02C99D : db $23 : org $07F444 : db $8B                                       ; Charging 1 (1)
org $02C9B7 : db $24 : org $07F444 : db $8B                                       ; Charging 1 (2)
org $02C99E : db $20 : org $07F444 : db $8B                                       ; Charging 2 (1)
org $02C9B8 : db $21 : org $07F444 : db $8B                                       ; Charging 2 (2)
org $02C99F : db $0D : org $07F444 : db $8B                                       ; Pitching 1 (1)
org $02C9B9 : db $4E : org $07F444 : db $8B                                       ; Pitching 1 (2)
org $02C9A0 : db $0C : org $07F444 : db $8B                                       ; Pitching 2 (1)
org $02C9BA : db $A0 : org $07F444 : db $8B                                       ; Pitching 2 (2)
org $02C9A1 : db $5D : org $07F444 : db $8B                                       ; Pitching 3 (1)
org $02C9BB : db $A0 : org $07F444 : db $8B                                       ; Pitching 3 (2)
org $02C9A2 : db $BD : org $07F444 : db $8B                                       ; Pitching 4 (1)
org $02C9BC : db $A2 : org $07F444 : db $8B                                       ; Pitching 4 (2)
org $02C9A3 : db $BD : org $07F444 : db $8B                                       ; Pitching 5 (1)
org $02C9BD : db $A4 : org $07F444 : db $8B                                       ; Pitching 5 (2)
org $02C9A4 : db $5D : org $07F444 : db $8B                                       ; Pitching 6 (1)
org $02C9BE : db $AE : org $07F444 : db $8B                                       ; Pitching 6 (2)
org $02C9BF : db $00 : org $07F444 : db $8B                                       ; Unused?
org $02C9C0 : db $00 : org $07F444 : db $8B                                       ; Unused?


;;; Volcano lotus
org $02E012 : db $00 : org $02E01F : db $0A                                       ; Base
org $02E008 : db $02 : org $02E056 : db $38                                       ; Bud 1 (red)
org $02E008 : db $02 : org $02E05A : db $34                                       ; Bud 1 (yellow)
org $02E009 : db $12 : org $02E056 : db $38                                       ; Bud 2 (red)
org $02E009 : db $12 : org $02E05A : db $34                                       ; Bud 2 (yellow)
org $02E00A : db $04 : org $02E056 : db $38                                       ; Bud 3 (red)
org $02E00A : db $04 : org $02E05A : db $34                                       ; Bud 3 (yellow)
org $029B94 : db $10 : org $029B84 : db $A8 : org $029BA1 : db $00                ; Fireball 1
org $029B98 : db $11 : org $029B84 : db $A8 : org $029BA1 : db $00                ; Fireball 2


;;; Sumo bros.
org $02DE0E : db $98 : org $07F498 : db $93 : org $02DE26 : db $00                ; Tile 1
org $02DE0F : db $99 : org $07F498 : db $93 : org $02DE27 : db $00                ; Tile 2
org $02DE10 : db $A7 : org $07F498 : db $93 : org $02DE28 : db $02                ; Tile 3
org $02DE11 : db $A8 : org $07F498 : db $93 : org $02DE29 : db $02                ; Tile 4
org $02DE12 : db $98 : org $07F498 : db $93 : org $02DE2A : db $00                ; Tile 5
org $02DE13 : db $99 : org $07F498 : db $93 : org $02DE2B : db $00                ; Tile 6
org $02DE14 : db $AA : org $07F498 : db $93 : org $02DE2C : db $02                ; Tile 7
org $02DE15 : db $AB : org $07F498 : db $93 : org $02DE2D : db $02                ; Tile 8
org $02DE16 : db $8A : org $07F498 : db $93 : org $02DE2E : db $02                ; Tile 9
org $02DE17 : db $66 : org $07F498 : db $93 : org $02DE2F : db $02                ; Tile 10
org $02DE18 : db $AA : org $07F498 : db $93 : org $02DE30 : db $02                ; Tile 11
org $02DE19 : db $AB : org $07F498 : db $93 : org $02DE31 : db $02                ; Tile 12
org $02DE1A : db $EE : org $07F498 : db $93 : org $02DE32 : db $02                ; Tile 13
org $02DE1B : db $EE : org $07F498 : db $93 : org $02DE33 : db $02                ; Tile 14
org $02DE1C : db $C5 : org $07F498 : db $93 : org $02DE34 : db $02                ; Tile 15
org $02DE1D : db $C6 : org $07F498 : db $93 : org $02DE35 : db $02                ; Tile 16
org $02DE1E : db $80 : org $07F498 : db $93 : org $02DE36 : db $02                ; Tile 17
org $02DE1F : db $80 : org $07F498 : db $93 : org $02DE37 : db $02                ; Tile 18
org $02DE20 : db $C1 : org $07F498 : db $93 : org $02DE38 : db $02                ; Tile 19
org $02DE21 : db $C3 : org $07F498 : db $93 : org $02DE39 : db $02                ; Tile 20
org $02DE22 : db $80 : org $07F498 : db $93 : org $02DE3A : db $02                ; Tile 21
org $02DE23 : db $80 : org $07F498 : db $93 : org $02DE3B : db $02                ; Tile 22
org $02DE24 : db $C1 : org $07F498 : db $93 : org $02DE3C : db $02                ; Tile 23
org $02DE25 : db $C3 : org $07F498 : db $93 : org $02DE3D : db $02                ; Tile 24


;;; Hammer bros.
org $02DAF1 : db $14 : org $02DB1F : db $36 : org $02DAF9 : db $00                ; Helmet 1, 1
org $02DAF2 : db $04 : org $02DB1F : db $36 : org $02DAFA : db $00                ; Helmet 2, 1
org $02DAF3 : db $00 : org $02DB1F : db $36 : org $02DAFB : db $02                ; Body 1, 1
org $02DAF4 : db $02 : org $02DB1F : db $36 : org $02DAFC : db $02                ; Body 2, 1
org $02DAF5 : db $04 : org $02DB1F : db $36 : org $02DAF9 : db $00                ; Helmet 1, 2
org $02DAF6 : db $14 : org $02DB1F : db $36 : org $02DAFA : db $00                ; Helmet 2, 2
org $02DAF7 : db $02 : org $02DB1F : db $36 : org $02DAFB : db $02                ; Body 1, 2
org $02DAF8 : db $00 : org $02DB1F : db $36 : org $02DAFC : db $02                ; Body 2, 2
org $02A2DF : db $00 : org $02A2E7 : db $46 : org $02A33E : db $02                ; Hammer 1
org $02A2E0 : db $02 : org $02A2E8 : db $46 : org $02A33E : db $02                ; Hammer 2
org $02A2E1 : db $02 : org $02A2E9 : db $06 : org $02A33E : db $02                ; Hammer 3
org $02A2E2 : db $00 : org $02A2EA : db $06 : org $02A33E : db $02                ; Hammer 4
org $02A2E3 : db $00 : org $02A2EB : db $86 : org $02A33E : db $02                ; Hammer 5
org $02A2E4 : db $02 : org $02A2EC : db $86 : org $02A33E : db $02                ; Hammer 6
org $02A2E5 : db $02 : org $02A2ED : db $C6 : org $02A33E : db $02                ; Hammer 7
org $02A2E6 : db $00 : org $02A2EE : db $C6 : org $02A33E : db $02                ; Hammer 8


;;; Hammer bros. platform
org $02DC1F : db $84 : org $02DC27 : db $32 : org $02DC2F : db $02                ; Frame 1, block 1
org $02DC20 : db $84 : org $02DC28 : db $32 : org $02DC30 : db $02                ; Frame 1, block 2
org $02DC21 : db $AA : org $02DC29 : db $72 : org $02DC31 : db $02                ; Frame 1, wing 1
org $02DC22 : db $AA : org $02DC2A : db $32 : org $02DC32 : db $02                ; Frame 1, wing 2
org $02DC23 : db $84 : org $02DC2B : db $32 : org $02DC33 : db $02                ; Frame 2, block 1
org $02DC24 : db $84 : org $02DC2C : db $32 : org $02DC34 : db $02                ; Frame 2, block 2
org $02DC25 : db $AC : org $02DC2D : db $72 : org $02DC35 : db $02                ; Frame 2, wing 1
org $02DC26 : db $AC : org $02DC2E : db $32 : org $02DC36 : db $02                ; Frame 2, wing 2


;;; Bubble
org $02D9C3 : db $A0 : org $02D9C8 : db $07 : org $02D9CD : db $02                ; Bubble 1
org $02D9C4 : db $A0 : org $02D9C9 : db $47 : org $02D9CE : db $02                ; Bubble 2
org $02D9C5 : db $A0 : org $02D9CA : db $87 : org $02D9CF : db $02                ; Bubble 3
org $02D9C6 : db $A0 : org $02D9CB : db $C7 : org $02D9D0 : db $02                ; Bubble 4
org $02D9C7 : db $99 : org $02D9CC : db $03 : org $02D9D1 : db $00                ; Bubble 5
org $02D8A1 : db $A8 : org $02D8A9 : db $84                                       ; Goomba 1
org $02D8A5 : db $AA : org $02D8A9 : db $84                                       ; Goomba 2
org $02D8A2 : db $CA : org $02D8AA : db $85                                       ; Bob-omb 1
org $02D8A6 : db $CC : org $02D8AA : db $85                                       ; Bob-omb 2
org $02D8A3 : db $67 : org $02D8AB : db $05                                       ; Cheep-cheep 1
org $02D8A7 : db $69 : org $02D8AB : db $05                                       ; Cheep-cheep 2
org $02D8A4 : db $24 : org $02D8AC : db $08                                       ; Mushroom 1
org $02D8A8 : db $24 : org $02D8AC : db $08                                       ; Mushroom 2


;;; Ball 'n chain
org $02D7A4 : db $00 : org $02D7BF : db $32                                       ; Chain


;;; Banzai bill
org $02D5C4 : db $00 : org $02D5D4 : db $32                                       ; Tile 1
org $02D5C5 : db $02 : org $02D5D5 : db $32                                       ; Tile 2
org $02D5C6 : db $04 : org $02D5D6 : db $32                                       ; Tile 3
org $02D5C7 : db $06 : org $02D5D7 : db $32                                       ; Tile 4
org $02D5C8 : db $08 : org $02D5D8 : db $32                                       ; Tile 5
org $02D5C9 : db $0A : org $02D5D9 : db $32                                       ; Tile 6
org $02D5CA : db $0C : org $02D5DA : db $32                                       ; Tile 7
org $02D5CB : db $0E : org $02D5DB : db $32                                       ; Tile 8
org $02D5CC : db $20 : org $02D5DC : db $32                                       ; Tile 9
org $02D5CD : db $22 : org $02D5DD : db $32                                       ; Tile 10
org $02D5CE : db $0C : org $02D5DE : db $32                                       ; Tile 11
org $02D5CF : db $0E : org $02D5DF : db $32                                       ; Tile 12
org $02D5D0 : db $24 : org $02D5E0 : db $32                                       ; Tile 13
org $02D5D1 : db $26 : org $02D5E1 : db $32                                       ; Tile 14
org $02D5D2 : db $04 : org $02D5E2 : db $B2                                       ; Tile 15
org $02D5D3 : db $06 : org $02D5E3 : db $B2                                       ; Tile 16


;;; Bowser scene activator


;;; Bowser's bowling ball
org $03B1ED : db $45 : org $03B1F9 : db $0D : org $03B205 : db $02                ; Tile 1
org $03B1EE : db $47 : org $03B1FA : db $0D : org $03B206 : db $02                ; Tile 2
org $03B1EF : db $45 : org $03B1FB : db $4D : org $03B207 : db $02                ; Tile 3
org $03B1F0 : db $65 : org $03B1FC : db $0D : org $03B208 : db $02                ; Tile 4
org $03B1F1 : db $66 : org $03B1FD : db $0D : org $03B209 : db $02                ; Tile 5
org $03B1F2 : db $65 : org $03B1FE : db $4D : org $03B20A : db $02                ; Tile 6
org $03B1F3 : db $45 : org $03B1FF : db $8D : org $03B20B : db $02                ; Tile 7
org $03B1F4 : db $47 : org $03B200 : db $8D : org $03B20C : db $02                ; Tile 8
org $03B1F5 : db $45 : org $03B201 : db $CD : org $03B20D : db $02                ; Tile 9
org $03B1F6 : db $39 : org $03B202 : db $0D : org $03B20E : db $00                ; Tile 10
org $03B1F7 : db $38 : org $03B203 : db $0D : org $03B20F : db $00                ; Tile 11
org $03B1F8 : db $63 : org $03B204 : db $0D : org $03B210 : db $02                ; Tile 12


;;; Mechakoopa
org $03B32F : db $40 : org $07F4A0 : db $BB : org $03B34F : db $02                ; Tile 1
org $03B330 : db $42 : org $07F4A0 : db $BB : org $03B350 : db $00                ; Tile 2
org $03B331 : db $60 : org $07F4A0 : db $BB : org $03B351 : db $00                ; Tile 3
org $03B332 : db $51 : org $07F4A0 : db $BB : org $03B352 : db $02                ; Tile 4
org $03B333 : db $40 : org $07F4A0 : db $BB : org $03B34F : db $02                ; Tile 5
org $03B334 : db $42 : org $07F4A0 : db $BB : org $03B350 : db $00                ; Tile 6
org $03B335 : db $60 : org $07F4A0 : db $BB : org $03B351 : db $00                ; Tile 7
org $03B336 : db $0A : org $07F4A0 : db $BB : org $03B352 : db $02                ; Tile 8
org $03B337 : db $40 : org $07F4A0 : db $BB : org $03B34F : db $02                ; Tile 9
org $03B338 : db $42 : org $07F4A0 : db $BB : org $03B350 : db $00                ; Tile 10
org $03B339 : db $60 : org $07F4A0 : db $BB : org $03B351 : db $00                ; Tile 11
org $03B33A : db $0C : org $07F4A0 : db $BB : org $03B352 : db $02                ; Tile 12
org $03B33B : db $40 : org $07F4A0 : db $BB : org $03B34F : db $02                ; Tile 13
org $03B33C : db $42 : org $07F4A0 : db $BB : org $03B350 : db $00                ; Tile 14
org $03B33D : db $60 : org $07F4A0 : db $BB : org $03B351 : db $00                ; Tile 15
org $03B33E : db $0E : org $07F4A0 : db $BB : org $03B352 : db $02                ; Tile 16
org $03B3F3 : db $70 : org $03B3F1 : db $4D : org $03B434 : db $00                ; Key 1, left
org $03B3F4 : db $71 : org $03B3F1 : db $4D : org $03B434 : db $00                ; Key 2, left
org $03B3F5 : db $72 : org $03B3F1 : db $4D : org $03B434 : db $00                ; Key 3, left
org $03B3F6 : db $71 : org $03B3F1 : db $4D : org $03B434 : db $00                ; Key 4, left
org $03B3F3 : db $70 : org $03B3F2 : db $0D : org $03B434 : db $00                ; Key 1, right
org $03B3F4 : db $71 : org $03B3F2 : db $0D : org $03B434 : db $00                ; Key 2, right
org $03B3F5 : db $72 : org $03B3F2 : db $0D : org $03B434 : db $00                ; Key 3, right
org $03B3F6 : db $71 : org $03B3F2 : db $0D : org $03B434 : db $00                ; Key 4, right


;;; Gray platform on chain
org $02D7AA : db $04 : org $02D7BF : db $32                                       ; Chain


;;; Floating spike ball
org $01B686 : db $00 : org $01B662 : db $30                                       ; Top left
org $01B686 : db $00 : org $01B663 : db $70                                       ; Top right
org $01B686 : db $00 : org $01B664 : db $A0                                       ; Bottom left
org $01B686 : db $00 : org $01B665 : db $F0                                       ; Bottom right


;;; Wall fuzzy/sparky
org $02BE6B : db $00 : org $02BE4C : db $04                                       ; Fuzzy 1
org $02BE6B : db $00 : org $02BE4B : db $6A                                       ; Fuzzy 2
org $02BE7A : db $00 : org $07F4A3 : db $34                                       ; Sparky 1
org $02BE7A : db $00 : org $07F4A3 : db $34                                       ; Sparky 2


;;; Hothead
org $02BE95 : db $01 : org $02BE9D : db $04                                       ; Tile 1
org $02BE96 : db $03 : org $02BE9E : db $04                                       ; Tile 2
org $02BE97 : db $03 : org $02BE9F : db $C4                                       ; Tile 3
org $02BE98 : db $01 : org $02BEA0 : db $C4                                       ; Tile 4
org $02BE99 : db $03 : org $02BEA1 : db $44                                       ; Tile 5
org $02BE9A : db $01 : org $02BEA2 : db $44                                       ; Tile 6
org $02BE9B : db $01 : org $02BEA3 : db $84                                       ; Tile 7
org $02BE9C : db $03 : org $02BEA4 : db $84                                       ; Tile 8
org $02BF0B : db $00 : org $02BF3A : db $A8 : org $02BF43 : db $00                ; Open eyes
org $02BF12 : db $10 : org $02BF3A : db $A8 : org $02BF43 : db $00                ; Closed eyes


;;; Iggy's ball
org $01FA4E : db $4A : org $01FA52 : db $35                                       ; Frame 1
org $01FA4F : db $4C : org $01FA53 : db $35                                       ; Frame 2
org $01FA50 : db $4A : org $01FA54 : db $F5                                       ; Frame 3
org $01FA51 : db $4C : org $01FA55 : db $F5                                       ; Frame 4


;;; Blargg
org $03A075 : db $00 : org $07F4A6 : db $34                                       ; Eyes, looking
org $03A091 : db $02 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Top left, left
org $03A092 : db $04 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Top right, left
org $03A093 : db $08 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Bottom left 1, left
org $03A094 : db $0A : org $03A09B : db $44 : org $03A0E9 : db $02                ; Bottom right, left
org $03A095 : db $06 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Back, left
org $03A096 : db $02 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Top left, left
org $03A097 : db $04 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Top right, left
org $03A098 : db $0C : org $03A09B : db $44 : org $03A0E9 : db $02                ; Bottom left 2, left
org $03A099 : db $0E : org $03A09B : db $44 : org $03A0E9 : db $02                ; Bottom right, left
org $03A09A : db $06 : org $03A09B : db $44 : org $03A0E9 : db $02                ; Back, left
org $03A091 : db $02 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Top left, right
org $03A092 : db $04 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Top right, right
org $03A093 : db $08 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Bottom left 1, right
org $03A094 : db $0A : org $03A09C : db $04 : org $03A0E9 : db $02                ; Bottom right 1, right
org $03A095 : db $06 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Back, right
org $03A096 : db $02 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Top left, right
org $03A097 : db $04 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Top right, right
org $03A098 : db $0C : org $03A09C : db $04 : org $03A0E9 : db $02                ; Bottom left 2, right
org $03A099 : db $0E : org $03A09C : db $04 : org $03A0E9 : db $02                ; Bottom right 2, right
org $03A09A : db $06 : org $03A09C : db $04 : org $03A0E9 : db $02                ; Back, right


;;; Reznor
org $039B5D : db $40 : org $039B69 : db $3F : org $039BD1 : db $02                ; Normal 1
org $039B5E : db $42 : org $039B6A : db $3F : org $039BD1 : db $02                ; Normal 2
org $039B5F : db $60 : org $039B6B : db $3F : org $039BD1 : db $02                ; Normal 3
org $039B60 : db $62 : org $039B6C : db $3F : org $039BD1 : db $02                ; Normal 4
org $039B61 : db $44 : org $039B6D : db $3F : org $039BD1 : db $02                ; Shooting fire 1
org $039B62 : db $46 : org $039B6E : db $3F : org $039BD1 : db $02                ; Shooting fire 2
org $039B63 : db $64 : org $039B6F : db $3F : org $039BD1 : db $02                ; Shooting fire 3
org $039B64 : db $66 : org $039B70 : db $3F : org $039BD1 : db $02                ; Shooting fire 4
org $039B65 : db $28 : org $039B71 : db $7F : org $039BD1 : db $02                ; Turning 1
org $039B66 : db $28 : org $039B72 : db $3F : org $039BD1 : db $02                ; Turning 2
org $039B67 : db $48 : org $039B73 : db $7F : org $039BD1 : db $02                ; Turning 3
org $039B68 : db $48 : org $039B74 : db $3F : org $039BD1 : db $02                ; Turning 4
org $02A163 : db $26 : org $02A167 : db $35 : org $02A19E : db $02                ; Fireball 1
org $02A164 : db $2A : org $02A168 : db $35 : org $02A19E : db $02                ; Fireball 2
org $02A165 : db $26 : org $02A169 : db $F5 : org $02A19E : db $02                ; Fireball 3
org $02A166 : db $2A : org $02A16A : db $F5 : org $02A19E : db $02                ; Fireball 4


;;; Fishbone
org $039799 : db $00 : org $07F4A8 : db $7C                                       ; Body 1
org $03979D : db $02 : org $07F4A8 : db $7C                                       ; Body 2
org $039788 : db $04 : org $07F4A8 : db $7C                                       ; Tail 1
org $039789 : db $04 : org $07F4A8 : db $7C                                       ; Tail 2
org $03978A : db $14 : org $07F4A8 : db $7C                                       ; Tail 3
org $03978B : db $14 : org $07F4A8 : db $7C                                       ; Tail 4


;;; Rex
org $039670 : db $8A : org $03967C : db $47 : org $0396E0 : db $02                ; Head 1, right
org $039671 : db $AA : org $03967C : db $47 : org $0396E0 : db $02                ; Body 1, right
org $039672 : db $8A : org $03967C : db $47 : org $0396E0 : db $02                ; Head 2, right
org $039673 : db $AC : org $03967C : db $47 : org $0396E0 : db $02                ; Body 2, right
org $039674 : db $8A : org $03967C : db $47 : org $0396E0 : db $02                ; Head half squished, right
org $039675 : db $AA : org $03967C : db $47 : org $0396E0 : db $02                ; Body half squished, right
org $039676 : db $8C : org $03967C : db $47 : org $0396E0 : db $02                ; Walking half squished 1, right
org $039677 : db $8C : org $03967C : db $47 : org $0396E0 : db $02                ; Walking half squished 2, right
org $039678 : db $A8 : org $03967C : db $47 : org $0396E0 : db $02                ; Walking half squished 3, right
org $039679 : db $A8 : org $03967C : db $47 : org $0396E0 : db $02                ; Walking half squished 4, right
org $03967A : db $A2 : org $03967C : db $47 : org $0396DC : db $00                ; Squished left, right
org $03967B : db $B2 : org $03967C : db $47 : org $0396DC : db $00                ; Squished right, right
org $039670 : db $8A : org $03967D : db $07 : org $0396E0 : db $02                ; Head 1, left
org $039671 : db $AA : org $03967D : db $07 : org $0396E0 : db $02                ; Body 1, left
org $039672 : db $8A : org $03967D : db $07 : org $0396E0 : db $02                ; Head 2, left
org $039673 : db $AC : org $03967D : db $07 : org $0396E0 : db $02                ; Body 2, left
org $039674 : db $8A : org $03967D : db $07 : org $0396E0 : db $02                ; Head half squished, left
org $039675 : db $AA : org $03967D : db $07 : org $0396E0 : db $02                ; Body half squished, left
org $039676 : db $8C : org $03967D : db $07 : org $0396E0 : db $02                ; Walking half squished 1, left
org $039677 : db $8C : org $03967D : db $07 : org $0396E0 : db $02                ; Walking half squished 2, left
org $039678 : db $A8 : org $03967D : db $07 : org $0396E0 : db $02                ; Walking half squished 3, left
org $039679 : db $A8 : org $03967D : db $07 : org $0396E0 : db $02                ; Walking half squished 4, left
org $03967A : db $A2 : org $03967D : db $07 : org $0396DC : db $00                ; Squished left, left
org $03967B : db $B2 : org $03967D : db $07 : org $0396DC : db $00                ; Squished right, left


;;; Upside-down wooden spike
org $0394BB : db $02 : org $0394C5 : db $80 : org $03950B : db $02                ; Pole 1
org $0394BC : db $02 : org $0394C6 : db $80 : org $03950B : db $02                ; Pole 2
org $0394BD : db $02 : org $0394C7 : db $80 : org $03950B : db $02                ; Pole 3
org $0394BE : db $02 : org $0394C8 : db $80 : org $03950B : db $02                ; Pole 4
org $0394BF : db $00 : org $0394C9 : db $80 : org $03950B : db $02                ; Spike


;;; Wooden spike
org $0394C0 : db $02 : org $0394CA : db $00 : org $03950B : db $02                ; Pole 1
org $0394C1 : db $02 : org $0394CB : db $00 : org $03950B : db $02                ; Pole 2
org $0394C2 : db $02 : org $0394CC : db $00 : org $03950B : db $02                ; Pole 3
org $0394C3 : db $02 : org $0394CD : db $00 : org $03950B : db $02                ; Pole 4
org $0394C4 : db $00 : org $0394CE : db $00 : org $03950B : db $02                ; Spike


;;; Fishin' Boo
org $039160 : db $02 : org $03916A : db $04 : org $03920C : db $02                ; Cloud 1
org $039161 : db $60 : org $03916B : db $04 : org $03920C : db $02                ; Cloud 2
org $039162 : db $64 : org $03916C : db $0D : org $03920C : db $02                ; Head 1
org $039163 : db $8A : org $03916D : db $09 : org $03920C : db $02                ; Fishing rod
org $039164 : db $60 : org $03916E : db $04 : org $03920C : db $02                ; Cloud 3
org $039165 : db $60 : org $03916F : db $04 : org $03920C : db $02                ; Cloud 4
org $039166 : db $AC : org $039170 : db $0D : org $03920C : db $02                ; Fishing line 1
org $039167 : db $AC : org $039171 : db $0D : org $03920C : db $02                ; Fishing line 2
org $039168 : db $AC : org $039172 : db $0D : org $03920C : db $02                ; Fishing line 3
org $039169 : db $CE : org $039173 : db $07 : org $03920C : db $02                ; Flame (unused?)
org $039174 : db $CC : org $039173 : db $07 : org $03920C : db $02                ; Flame 1
org $039175 : db $CE : org $039173 : db $07 : org $03920C : db $02                ; Flame 2
org $039176 : db $CC : org $039173 : db $07 : org $03920C : db $02                ; Flame 3
org $039177 : db $CE : org $039173 : db $07 : org $03920C : db $02                ; Flame 4


;;; Boo block
org $01FA37 : db $00 : org $07F4AD : db $3E                                       ; Normal
org $01FA38 : db $0C : org $07F4AD : db $3E                                       ; Solidifying
org $01FA39 : db $0E : org $07F4AD : db $3E                                       ; Block


;;; Boo stream
org $038F6D : db $02 : org $07F4AE : db $3E                                       ; Tile 1
org $038F6E : db $00 : org $07F4AE : db $3E                                       ; Tile 2
org $038F6F : db $06 : org $07F4AE : db $3E                                       ; Tile 3
org $038F70 : db $02 : org $07F4AE : db $3E                                       ; Tile 4
org $038F71 : db $08 : org $07F4AE : db $3E                                       ; Tile 5
org $038F72 : db $06 : org $07F4AE : db $3E                                       ; Tile 6
org $038F73 : db $02 : org $07F4AE : db $3E                                       ; Tile 7
org $038F74 : db $00 : org $07F4AE : db $3E                                       ; Tile 8


;;; Creating/eating block
org $039293 : db $82 : org $07F4AF : db $30 : org $0392A0 : db $02                ; Tile


;;; Falling spike
org $03921C : db $00 : org $07F4B0 : db $30                                       ; Tile


;;; Bowser statue fireball
org $038F0B : db $00 : org $038F13 : db $08 : org $038F65 : db $00                ; Frame 1, tile 1
org $038F0C : db $01 : org $038F14 : db $08 : org $038F65 : db $00                ; Frame 1, tile 2
org $038F0D : db $10 : org $038F15 : db $08 : org $038F65 : db $00                ; Frame 2, tile 1
org $038F0E : db $11 : org $038F16 : db $08 : org $038F65 : db $00                ; Frame 2, tile 2
org $038F0F : db $00 : org $038F17 : db $88 : org $038F65 : db $00                ; Frame 3, tile 1
org $038F10 : db $01 : org $038F18 : db $88 : org $038F65 : db $00                ; Frame 3, tile 2
org $038F11 : db $10 : org $038F19 : db $88 : org $038F65 : db $00                ; Frame 4, tile 1
org $038F12 : db $11 : org $038F1A : db $88 : org $038F65 : db $00                ; Frame 4, tile 2


;;; Grinder
org $01DBBF : db $00 : org $01DB9E : db $02                                       ; Top left
org $01DBBF : db $00 : org $01DB9F : db $42                                       ; Top right
org $01DBBF : db $00 : org $01DBA0 : db $82                                       ; Bottom left
org $01DBBF : db $00 : org $01DBA1 : db $C2                                       ; Bottom right


;;; Bowser fireball
org $01E190 : db $2A : org $01E194 : db $05                                       ; Frame 1
org $01E191 : db $2C : org $01E195 : db $05                                       ; Frame 2
org $01E192 : db $2A : org $01E196 : db $45                                       ; Frame 3
org $01E193 : db $2C : org $01E197 : db $45                                       ; Frame 4


;;; Reflecting podoboo
org $039011 : db $00 : org $07F4B4 : db $34                                       ; Tile


;;; Carrot top lift, upper right
org $038D18 : db $04 : org $038D1E : db $0A                                       ; Top right
org $038D19 : db $00 : org $038D1F : db $0A                                       ; Bottom right
org $038D1A : db $02 : org $038D20 : db $0A                                       ; Bottom left


;;; Carrot top lift, upper left
org $038D1B : db $04 : org $038D21 : db $4A                                       ; Top right
org $038D1C : db $00 : org $038D22 : db $4A                                       ; Bottom right
org $038D1D : db $02 : org $038D23 : db $4A                                       ; Bottom left


;;; Info box
org $038DB0 : db $00 : org $07F4B7 : db $36                                       ; Tile


;;; Timed lift
org $038E05 : db $02 : org $038E08 : db $0A : org $038E0B : db $02                ; Platform left
org $038E06 : db $02 : org $038E09 : db $4A : org $038E0C : db $02                ; Platform right
org $038E0E : db $11 : org $038E0A : db $0A : org $038E0D : db $00                ; 1
org $038E0F : db $10 : org $038E0A : db $0A : org $038E0D : db $00                ; 2
org $038E10 : db $01 : org $038E0A : db $0A : org $038E0D : db $00                ; 3
org $038E11 : db $00 : org $038E0A : db $0A : org $038E0D : db $00                ; 4


;;; Moving castle block
org $038EB0 : db $00 : org $038ED3 : db $02 : org $038EE2 : db $02                ; Top left
org $038EB1 : db $02 : org $038ED3 : db $02 : org $038EE2 : db $02                ; Top right
org $038EB2 : db $04 : org $038ED3 : db $02 : org $038EE2 : db $02                ; Bottom left
org $038EB3 : db $06 : org $038ED3 : db $02 : org $038EE2 : db $02                ; Bottom right


;;; Bowser statue
org $038B2E : db $06 : org $07F4BA : db $32 : org $038B34 : db $00                ; Foot
org $038B2F : db $00 : org $07F4BA : db $32 : org $038B35 : db $02                ; Head, standing
org $038B30 : db $02 : org $07F4BA : db $32 : org $038B36 : db $02                ; Body, standing
org $038B31 : db $06 : org $07F4BA : db $32 : org $038B34 : db $00                ; Foot
org $038B32 : db $00 : org $07F4BA : db $32 : org $038B35 : db $02                ; Head, jumping
org $038B33 : db $04 : org $07F4BA : db $32 : org $038B36 : db $02                ; Body, jumping


;;; Sliding blue koopa
org $038984 : db $C8 : org $07F4BB : db $06                                       ; Sliding
org $038988 : db $EA : org $07F4BB : db $06                                       ; Standing


;;; Swooper
org $0388A0 : db $00 : org $07F4BC : db $0A                                       ; Sleeping
org $0388A1 : db $02 : org $07F4BC : db $0A                                       ; Flying 1
org $0388A2 : db $04 : org $07F4BC : db $0A                                       ; Flying 2


;;; Mega mole
org $038837 : db $00 : org $038882 : db $00 : org $038898 : db $02                ; Frame 1, top left
org $038838 : db $02 : org $038882 : db $00 : org $038898 : db $02                ; Frame 1, top right
org $038839 : db $04 : org $038882 : db $00 : org $038898 : db $02                ; Frame 1, bottom left
org $03883A : db $06 : org $038882 : db $00 : org $038898 : db $02                ; Frame 1, bottom right
org $03883B : db $08 : org $038882 : db $00 : org $038898 : db $02                ; Frame 2, top left
org $03883C : db $0A : org $038882 : db $00 : org $038898 : db $02                ; Frame 2, top right
org $03883D : db $0C : org $038882 : db $00 : org $038898 : db $02                ; Frame 2, bottom left
org $03883E : db $0E : org $038882 : db $00 : org $038898 : db $02                ; Frame 2, bottom right


;;; Gray sinking platform
org $038734 : db $00 : org $038737 : db $42 : org $038766 : db $02                ; Left
org $038735 : db $01 : org $038738 : db $02 : org $038766 : db $02                ; Middle
org $038736 : db $00 : org $038739 : db $02 : org $038766 : db $02                ; Right


;;; Flying turn block platform
org $03868A : db $40 : org $038694 : db $32 : org $03869E : db $02                ; Block 1, frame 1
org $03868B : db $40 : org $038695 : db $32 : org $03869F : db $02                ; Block 2, frame 1
org $03868C : db $40 : org $038696 : db $32 : org $0386A0 : db $02                ; Block 3, frame 1
org $03868D : db $C6 : org $038697 : db $72 : org $0386A1 : db $02                ; Wing 1, frame 1
org $03868E : db $C6 : org $038698 : db $32 : org $0386A2 : db $02                ; Wing 2, frame 1
org $03868F : db $40 : org $038699 : db $32 : org $0386A3 : db $02                ; Block 1, frame 2
org $038690 : db $40 : org $03869A : db $32 : org $0386A4 : db $02                ; Block 2, frame 2
org $038691 : db $40 : org $03869B : db $32 : org $0386A5 : db $02                ; Block 3, frame 2
org $038692 : db $5D : org $03869C : db $72 : org $0386A6 : db $00                ; Wing 1, frame 2
org $038693 : db $5D : org $03869D : db $32 : org $0386A7 : db $00                ; Wing 2, frame 2


;;; Blurp
org $0384DD : db $00 : org $07F4C0 : db $CA                                       ; Frame 1
org $0384E1 : db $02 : org $07F4C0 : db $CA                                       ; Frame 2


;;; Porcu-puffer
org $038593 : db $00 : org $03859B : db $0C : org $0385EC : db $02                ; Top left, frame 1
org $038594 : db $02 : org $03859C : db $0C : org $0385EC : db $02                ; Top right, frame 1
org $038595 : db $04 : org $03859D : db $0C : org $0385EC : db $02                ; Top left, frame 1
org $038596 : db $08 : org $03859E : db $0C : org $0385EC : db $02                ; Top right, frame 1
org $038597 : db $00 : org $03859F : db $4C : org $0385EC : db $02                ; Bottom left, frame 2
org $038598 : db $02 : org $0385A0 : db $4C : org $0385EC : db $02                ; Bottom right, frame 2
org $038599 : db $04 : org $0385A1 : db $4C : org $0385EC : db $02                ; Bottom left, frame 2
org $03859A : db $06 : org $0385A2 : db $4C : org $0385EC : db $02                ; Bottom right, frame 2


;;; Gray falling platform
org $03848E : db $00 : org $0384AD : db $02 : org $0384BC : db $02                ; Tile 1
org $03848F : db $01 : org $0384AD : db $02 : org $0384BC : db $02                ; Tile 2
org $038490 : db $01 : org $0384AD : db $02 : org $0384BC : db $02                ; Tile 3
org $038491 : db $02 : org $0384AD : db $02 : org $0384BC : db $02                ; Tile 4


;;; Big boo boss
org $0382F8 : db $08 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 1
org $0382F9 : db $28 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 2
org $0382FA : db $23 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 3
org $0382FB : db $00 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 4
org $0382FC : db $20 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 5
org $0382FD : db $20 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 6
org $0382FE : db $00 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 7
org $0382FF : db $02 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 8
org $038300 : db $21 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 9
org $038301 : db $21 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 10
org $038302 : db $02 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 11
org $038303 : db $04 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 12
org $038304 : db $A4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 13
org $038305 : db $C4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 14
org $038306 : db $E4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 15
org $038307 : db $86 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 16
org $038308 : db $A6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 17
org $038309 : db $C6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 18
org $03830A : db $E6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 19
org $03830B : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 20
org $03830C : db $C0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 21
org $03830D : db $E0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 22
org $03830E : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 23
org $03830F : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 24
org $038310 : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 25
org $038311 : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 26
org $038312 : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 27
org $038313 : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 28
org $038314 : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 29
org $038315 : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 30
org $038316 : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 31
org $038317 : db $84 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 32
org $038318 : db $A4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 33
org $038319 : db $C4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 34
org $03831A : db $E4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 35
org $03831B : db $86 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 36
org $03831C : db $A6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 37
org $03831D : db $C6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 38
org $03831E : db $E6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 39
org $03831F : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 40
org $038320 : db $C0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 41
org $038321 : db $E0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 42
org $038322 : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 43
org $038323 : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 44
org $038324 : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 45
org $038325 : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 46
org $038326 : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 47
org $038327 : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 48
org $038328 : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 49
org $038329 : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 50
org $03832A : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 51
org $03832B : db $84 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 52
org $03832C : db $A4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 53
org $03832D : db $A4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 54
org $03832E : db $84 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 55
org $03832F : db $86 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 56
org $038330 : db $A6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 57
org $038331 : db $A6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 58
org $038332 : db $86 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 59
org $038333 : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 60
org $038334 : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 61
org $038335 : db $E8 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 62
org $038336 : db $C2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 63
org $038337 : db $E2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 64
org $038338 : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 65
org $038339 : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 66
org $03833A : db $A0 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 67
org $03833B : db $80 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 68
org $03833C : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 69
org $03833D : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 70
org $03833E : db $A2 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 71
org $03833F : db $82 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 72
org $038340 : db $84 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 73
org $038341 : db $A4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 74
org $038342 : db $C4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 75
org $038343 : db $E4 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 76
org $038344 : db $86 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 77
org $038345 : db $A6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 78
org $038346 : db $C6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 79
org $038347 : db $E6 : org $07F4C3 : db $3F : org $03844E : db $02                ; Tile 80


;;; Disco ball
org $03C493 : db $00 : org $03C49C : db $30 : org $03C4D2 : db $02                ; Frame 1
org $03C494 : db $02 : org $03C49D : db $32 : org $03C4D2 : db $02                ; Frame 2
org $03C495 : db $04 : org $03C49E : db $34 : org $03C4D2 : db $02                ; Frame 3
org $03C496 : db $06 : org $03C49F : db $36 : org $03C4D2 : db $02                ; Frame 4
org $03C497 : db $08 : org $03C4A0 : db $30 : org $03C4D2 : db $02                ; Frame 5
org $03C498 : db $0A : org $03C4A1 : db $32 : org $03C4D2 : db $02                ; Frame 6
org $03C499 : db $0C : org $03C4A2 : db $34 : org $03C4D2 : db $02                ; Frame 7
org $03C49A : db $0E : org $03C4A3 : db $36 : org $03C4D2 : db $02                ; Frame 8
org $03C49B : db $0E : org $03C4A4 : db $38 : org $03C4D2 : db $02                ; Frame 9


;;; Invisible mushroom


;;; Light switch
org $03C248 : db $2A : org $07F4C6 : db $38                                       ; Tile


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Cluster sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Bonus game 1-UPs
org $02FE5E : db $24 : org $02FE63 : db $3A : org $02FE6C : db $02                ; Tile


;;; Null


;;; Boo from boo ceiling
org $02FBBF : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 1
org $02FBC0 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 2
org $02FBC1 : db $A8 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 3
org $02FBC2 : db $8E : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 4
org $02FBC3 : db $AA : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 5
org $02FBC4 : db $AE : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 6
org $02FBC5 : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 7
org $02FBC6 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 8


;;; Boo from boo ring
org $02FBBF : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 1
org $02FBC0 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 2
org $02FBC1 : db $A8 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 3
org $02FBC2 : db $8E : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 4
org $02FBC3 : db $AA : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 5
org $02FBC4 : db $AE : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 6
org $02FBC5 : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 7
org $02FBC6 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 8


;;; Castle flames
org $02FA0E : db $E2 : org $02FA12 : db $09 : org $02FA5A : db $02                ; Frame 1
org $02FA0F : db $E4 : org $02FA13 : db $09 : org $02FA5A : db $02                ; Frame 2
org $02FA10 : db $E2 : org $02FA14 : db $49 : org $02FA5A : db $02                ; Frame 3
org $02FA11 : db $E4 : org $02FA15 : db $49 : org $02FA5A : db $02                ; Frame 4


;;; Sumo bros. lightning
org $02F904 : db $03 : org $02F98F : db $04                                       ; Flame 1
org $02F905 : db $05 : org $02F98F : db $04                                       ; Flame 2
org $02F906 : db $01 : org $02F98F : db $04                                       ; Flame 3
org $02F907 : db $03 : org $02F98F : db $04                                       ; Flame 4
org $02F908 : db $01 : org $02F98F : db $04                                       ; Flame 5
org $02F909 : db $05 : org $02F98F : db $04                                       ; Flame 6
org $02F90A : db $01 : org $02F98F : db $04                                       ; Unused?
org $02F90B : db $01 : org $02F98F : db $04                                       ; Flame 7


;;; Boo from boo cloud
org $02FBBF : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 1
org $02FBC0 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 2
org $02FBC1 : db $A8 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 3
org $02FBC2 : db $8E : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 4
org $02FBC3 : db $AA : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 5
org $02FBC4 : db $AE : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 6
org $02FBC5 : db $88 : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 7
org $02FBC6 : db $8C : org $02FD82 : db $31 : org $02FD8D : db $02                ; Tile 8


;;; Death bat ceiling
org $02FDB8 : db $AE : org $02FDB2 : db $37 : org $02FD8D : db $02                ; Sleeping 1
org $02FDB9 : db $AE : org $02FDB2 : db $37 : org $02FD8D : db $02                ; Sleeping 2
org $02FDBA : db $C0 : org $02FDB2 : db $37 : org $02FD8D : db $02                ; Flying 1
org $02FDBB : db $EB : org $02FDB2 : db $37 : org $02FD8D : db $02                ; Flying 2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Bounce sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Turn block with item
org $0291F1 : db $84 : org $028789 : db $00 : org $02925D : db $02                ; Tile


;;; Note block
org $0291F2 : db $6B : org $02878A : db $03 : org $02925D : db $02                ; Tile


;;; ? block
org $0291F3 : db $80 : org $02878B : db $00 : org $02925D : db $02                ; Tile


;;; Side turn block
org $0291F4 : db $84 : org $02878C : db $00 : org $02925D : db $02                ; Tile


;;; Glass block
org $0291F5 : db $EA : org $02878D : db $01 : org $02925D : db $02                ; Tile


;;; ON/OFF block
org $0291F6 : db $8A : org $02878E : db $07 : org $02925D : db $02                ; Tile


;;; Turn block
org $0291F7 : db $84 : org $02878F : db $00 : org $02925D : db $02                ; Tile


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Extended sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Dust cloud
org $02A347 : db $66 : org $02A34B : db $00 : org $02A3A6 : db $02                ; Frame 1
org $02A348 : db $64 : org $02A34C : db $40 : org $02A3A6 : db $02                ; Frame 2
org $02A349 : db $60 : org $02A34D : db $C0 : org $02A3A6 : db $02                ; Frame 3
org $02A34A : db $62 : org $02A34E : db $80 : org $02A3A6 : db $02                ; Frame 4


;;; Reznor fireball
org $02A163 : db $26 : org $02A167 : db $35 : org $02A19E : db $02                ; Frame 1
org $02A164 : db $2A : org $02A168 : db $35 : org $02A19E : db $02                ; Frame 2
org $02A165 : db $26 : org $02A169 : db $F5 : org $02A19E : db $02                ; Frame 3
org $02A166 : db $2A : org $02A16A : db $F5 : org $02A19E : db $02                ; Frame 4


;;; Hopping flame remnant
org $02A217 : db $04 : org $02A24C : db $04                                       ; Frame 1
org $02A218 : db $14 : org $02A24C : db $04                                       ; Frame 2


;;; Hammer
org $02A2DF : db $00 : org $02A2E7 : db $46 : org $02A33E : db $02                ; Frame 1
org $02A2E0 : db $02 : org $02A2E8 : db $46 : org $02A33E : db $02                ; Frame 2
org $02A2E1 : db $02 : org $02A2E9 : db $06 : org $02A33E : db $02                ; Frame 3
org $02A2E2 : db $00 : org $02A2EA : db $06 : org $02A33E : db $02                ; Frame 4
org $02A2E3 : db $00 : org $02A2EB : db $86 : org $02A33E : db $02                ; Frame 5
org $02A2E4 : db $02 : org $02A2EC : db $86 : org $02A33E : db $02                ; Frame 6
org $02A2E5 : db $02 : org $02A2ED : db $C6 : org $02A33E : db $02                ; Frame 7
org $02A2E6 : db $00 : org $02A2EE : db $C6 : org $02A33E : db $02                ; Frame 8


;;; Mario fireball
org $02A15B : db $08 : org $02A15F : db $04 : org $02A0A1 : db $00                ; Frame 1
org $02A15C : db $09 : org $02A160 : db $04 : org $02A0A1 : db $00                ; Frame 2
org $02A15D : db $08 : org $02A161 : db $C4 : org $02A0A1 : db $00                ; Frame 3
org $02A15E : db $09 : org $02A162 : db $C4 : org $02A0A1 : db $00                ; Frame 4


;;; Dry bones thrown bone
org $02A2CC : db $80 : org $02A2DA : db $02 : org $02A33E : db $02                ; Frame 1
org $02A2D0 : db $82 : org $02A2DA : db $02 : org $02A33E : db $02                ; Frame 2


;;; Lava splash
org $028F2B : db $D7 : org $028F76 : db $05 : org $028F82 : db $00                ; Frame 1
org $028F2C : db $C7 : org $028F76 : db $05 : org $028F82 : db $00                ; Frame 2
org $028F2D : db $D6 : org $028F76 : db $05 : org $028F82 : db $00                ; Frame 3
org $028F2E : db $C6 : org $028F76 : db $05 : org $028F82 : db $00                ; Frame 4


;;; Torpedo Ted dispenser arm
org $029E66 : db $06 : org $02A2DA : db $02 : org $029E7D : db $02                ; Hand closed
org $029E6A : db $08 : org $029E74 : db $12 : org $029E7D : db $02                ; Hand open


;;; Unused
org $029D92 : db $69                                                              ; Frame 1
org $029D93 : db $29                                                              ; Frame 2
org $029D94 : db $29                                                              ; Frame 3
org $029D95 : db $00                                                              ; Frame 4
org $029D96 : db $00                                                              ; Frame 5
org $029D97 : db $02                                                              ; Frame 6
org $029D98 : db $02                                                              ; Frame 7
org $029D99 : db $9E                                                              ; Frame 8
org $029D9A : db $0B                                                              ; Frame 9
org $029D9B : db $77                                                              ; Frame 10
org $029D9C : db $60                                                              ; Frame 11
org $029D9D : db $A5                                                              ; Frame 12


;;; Spin jump star
org $029C94 : db $4F : org $029C8F : db $34                                       ; Tile


;;; Yoshi fireball
org $029F7A : db $04 : org $029F8B : db $35 : org $029F94 : db $02                ; Frame 1
org $029F7E : db $2B : org $029F8B : db $35 : org $029F94 : db $02                ; Frame 2


;;; Water bubble
org $029F5C : db $59                                                              ; Tile


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Minor extended sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Broken brick piece
org $028B84 : db $4A : org $028B8C : db $00 : org $029028 : db $00                ; Frame 1
org $028B85 : db $4B : org $028B8D : db $00 : org $029028 : db $00                ; Frame 2
org $028B86 : db $4B : org $028B8E : db $80 : org $029028 : db $00                ; Frame 3
org $028B87 : db $4A : org $028B8F : db $80 : org $029028 : db $00                ; Frame 4


;;; Tiny sparkle
org $028ECC : db $66 : org $028F1A : db $06 : org $028F26 : db $00                ; Smallest
org $028ECD : db $7F : org $028F1A : db $06 : org $028F26 : db $00                ; Small
org $028ECE : db $5F : org $028F1A : db $06 : org $028F26 : db $00                ; Largest


;;; Yoshi egg fragment
org $028EB2 : db $6F : org $028EBC : db $03 : org $028EC7 : db $00                ; Tile


;;; Podoboo lava trail
org $028F2B : db $D7 : org $028F76 : db $05 : org $028F82 : db $00                ; Smallest
org $028F2C : db $C7 : org $028F76 : db $05 : org $028F82 : db $00                ; Small
org $028F2D : db $D6 : org $028F76 : db $05 : org $028F82 : db $00                ; Large
org $028F2E : db $C6 : org $028F76 : db $05 : org $028F82 : db $00                ; Largest


;;; Invincibility sparkles
org $028ECF : db $7E : org $028F1A : db $06 : org $028F26 : db $00                ; Smallest
org $028ED0 : db $6F : org $028F1A : db $06 : org $028F26 : db $00                ; Small
org $028ED1 : db $6E : org $028F1A : db $06 : org $028F26 : db $00                ; Largest


;;; Rip van fish Z effect
org $028DDA : db $08 : org $028E44 : db $02                                       ; z
org $028DD9 : db $09 : org $028E44 : db $02                                       ; Z
org $028DD8 : db $18 : org $028E44 : db $02                                       ; Z!!
org $028DD7 : db $19 : org $028E44 : db $02                                       ; *pop*


;;; Water splash
org $028D42 : db $68 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 1
org $028D43 : db $68 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 2
org $028D44 : db $6A : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 3
org $028D45 : db $6A : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 4
org $028D46 : db $6A : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 5
org $028D47 : db $62 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 6
org $028D48 : db $62 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 7
org $028D49 : db $62 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 8
org $028D4A : db $64 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 9
org $028D4B : db $64 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 10
org $028D4C : db $64 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 11
org $028D4D : db $64 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 12
org $028D4E : db $66 : org $028DC2 : db $02 : org $028DCB : db $02                ; Frame 13


;;; Rip van fish Z effect 2
org $028DDA : db $08 : org $028E44 : db $02                                       ; z
org $028DD9 : db $09 : org $028E44 : db $02                                       ; Z
org $028DD8 : db $18 : org $028E44 : db $02                                       ; Z!!
org $028DD7 : db $19 : org $028E44 : db $02                                       ; *pop*


;;; Rip van fish Z effect 3
org $028DDA : db $08 : org $028E44 : db $02                                       ; z
org $028DD9 : db $09 : org $028E44 : db $02                                       ; Z
org $028DD8 : db $18 : org $028E44 : db $02                                       ; Z!!
org $028DD7 : db $19 : org $028E44 : db $02                                       ; *pop*


;;; Boo stream follower
org $028CB8 : db $88 : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 1
org $028CB9 : db $A8 : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 2
org $028CBA : db $AA : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 3
org $028CBB : db $8C : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 4
org $028CBC : db $8E : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 5
org $028CBD : db $AE : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 6
org $028CBE : db $88 : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 7
org $028CBF : db $A8 : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 8
org $028CC0 : db $AA : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 9
org $028CC1 : db $8C : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 10
org $028CC2 : db $8E : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 11
org $028CC3 : db $AE : org $028D34 : db $0F : org $028D3D : db $02                ; Tile 12


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Smoke sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Puff of smoke
org $0296D8 : db $66 : org $029724 : db $00 : org $029745 : db $02                ; Frame 1
org $0296D9 : db $66 : org $029724 : db $00 : org $029745 : db $02                ; Frame 2
org $0296DA : db $64 : org $029724 : db $00 : org $029745 : db $02                ; Frame 3
org $0296DB : db $62 : org $029724 : db $00 : org $029745 : db $02                ; Frame 4
org $0296DC : db $60 : org $029724 : db $00 : org $029745 : db $02                ; Frame 5
org $0296DD : db $62 : org $029724 : db $00 : org $029745 : db $02                ; Frame 6
org $0296DE : db $60 : org $029724 : db $00 : org $029745 : db $02                ; Frame 7


;;; Contact
org $029804 : db $6C                        : org $02982A : db $02                ; Frame 1, tile 1+4
org $02980C : db $7D                        : org $02982A : db $02                ; Frame 1, tile 2+3
org $029816 : db $7D                        : org $02982A : db $02                ; Frame 2, tile 1+4
org $02981E : db $7C                        : org $02982A : db $02                ; Frame 2, tile 2+3


;;; Skid smoke
org $029922 : db $66                        : org $02999A : db $00                ; Frame 1
org $029923 : db $66                        : org $02999A : db $00                ; Frame 2
org $029924 : db $64                        : org $02999A : db $00                ; Frame 3
org $029925 : db $62                        : org $02999A : db $00                ; Frame 4
org $029926 : db $62                        : org $02999A : db $00                ; Frame 5


;;; Null


;;; Glitter


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Score sprits
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; 10
org $02AD4D : db $9F : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD63 : db $88 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 20
org $02AD4E : db $9F : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD64 : db $98 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 40
org $02AD4F : db $9F : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD65 : db $8A : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 80
org $02AD50 : db $9F : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD66 : db $8B : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 100
org $02AD51 : db $88 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD67 : db $89 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 200
org $02AD52 : db $98 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD68 : db $89 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 400
org $02AD53 : db $8A : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD69 : db $89 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 800
org $02AD54 : db $8B : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6A : db $89 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 1000
org $02AD55 : db $88 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6B : db $99 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 2000
org $02AD56 : db $98 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6C : db $99 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 4000
org $02AD57 : db $8A : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6D : db $99 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 8000
org $02AD58 : db $8B : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6E : db $99 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 1UP
org $02AD59 : db $9A : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD6F : db $9B : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 2UP
org $02AD5A : db $29 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD70 : db $57 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 3UP
org $02AD5B : db $39 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD71 : db $57 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; 5UP
org $02AD5C : db $38 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD72 : db $57 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; Coin x 5
org $02AD5D : db $5E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD73 : db $4E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; Coin x 10
org $02AD5E : db $5E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD74 : db $44 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; Coin x 15
org $02AD5F : db $5E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD75 : db $4F : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; Coin x 20
org $02AD60 : db $5E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD76 : db $54 : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


;;; Coin x 25
org $02AD61 : db $5E : org $02AEE1 : db $30 : org $02AEED : db $00                ; Left
org $02AD77 : db $5D : org $02AEE1 : db $30 : org $02AEED : db $00                ; Right


