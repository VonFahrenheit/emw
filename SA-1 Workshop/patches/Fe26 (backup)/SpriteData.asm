; Each sprite type has 16 bytes, the format is as follows:
; $00 - New code flag (really just a leftover from sprite tool)
; $01 - Sprite number		($3200)
; $02 - Tweaker 1		($3440)
; $03 - Tweaker 2		($3450)
; $04 - Tweaker 3		($3460 + $33C0)
; $05 - Tweaker 4		($3470)
; $06 - Tweaker 5		($3480)
; $07 - Tweaker 6		($34B0)
; $08 - 24-bit INIT pointer
; $0B - 24-bit MAIN pointer
; $0E - Extra property 1	($35A0)
; $0F - Extra property 2	($35B0)

SpriteData:

; -- Sprite 00 --
db $01,$36
db $00,$00,$47,$81,$00,$00
dl HappySlime_INIT
dl HappySlime_MAIN
db $00,$00

; -- Sprite 01 --
db $01,$36
db $00,$00,$47,$81,$00,$00
dl GoombaSlave_INIT
dl GoombaSlave_MAIN
db $00,$00

; -- Sprite 02 --
db $01,$36
db $00,$00,$47,$81,$00,$00
dl REX_INIT
dl REX_MAIN
db $00,$00

; -- Sprite 03 --
db $01,$36
db $00,$00,$4B,$81,$00,$00
dl HAMMERREX_INIT
dl HAMMERREX_MAIN
db $00,$00

; -- Sprite 04 --
db $01,$36
db $00,$00,$59,$81,$11,$04
dl AGGROREX_INIT
dl AGGROREX_MAIN
db $00,$00

; -- Sprite 05 --
db $01,$36
db $00,$00,$4B,$81,$00,$00
dl NOVICESHAMAN_INIT
dl NOVICESHAMAN_MAIN
db $00,$00

; -- Sprite 06 --
db $01,$36
db $00,$00,$59,$85,$11,$04
dl ADEPTSHAMAN_INIT
dl ADEPTSHAMAN_MAIN
db $00,$00

; -- Sprite 07 --
db $01,$36
db $00,$00,$30,$A6,$31,$46
dl Projectile_INIT
dl Projectile_MAIN
db $00,$00

; -- Sprite 08 --
db $01,$36
db $00,$00,$59,$81,$11,$04
dl CaptainWarrior_INIT
dl CaptainWarrior_MAIN
db $00,$00

; -- Sprite 09 --
db $01,$36
db $00,$00,$57,$85,$00,$00
dl TarCreeper_INIT
dl TarCreeper_MAIN
db $00,$00

; -- Sprite 0A --
db $01,$36
db $00,$00,$57,$81,$00,$00
dl MiniMech_INIT
dl MiniMech_MAIN
db $00,$00

; -- Sprite 0B --
db $01,$36
db $00,$00,$47,$81,$00,$00
dl MoleWizard_INIT
dl MoleWizard_MAIN
db $00,$00

; -- Sprite 0C --
db $01,$36
db $00,$00,$47,$81,$00,$04
dl MiniMole_INIT
dl MiniMole_MAIN
db $00,$00





