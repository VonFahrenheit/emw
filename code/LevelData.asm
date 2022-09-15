

	LevelData:

	.Unlock
	incsrc "level_data/Level_Unlock.asm"

	.VRAM_map
	incsrc "level_data/VRAM_map.asm"

	.MegaLevelID
	incsrc "level_data/MegaLevelID.asm"

	.YoshiCoins
	incsrc "level_data/YoshiCoins.asm"

	.TimeLimits
	incsrc "level_data/TimeLimits.asm"

	.LightPoints
	incsrc "level_data/LevelLightPoints.asm"

	.CameraBox
	incsrc "level_data/CameraBox.asm"

	.BG3_Resolution
	incsrc "level_data/BG3_resolution.asm"


;==============================;
; LAYER PRIORITY DOCUMENTATION ;
;==============================;
; these are indexed by level mode setting
; 00 - horizontal level, layer 2 background
; 01 - horizontal level, layer 2 level (no interaction)
; 02 - horizontal level, layer 2 level (with interaction)
; 03 - 
; 04 - 
; 05 - 
; 06 - 
; 07 - vertical level, layer 2 level (no interaction)
; 08 - vertical level, layer 2 level (with interaction)
; 09 - BOSS
; 0A - vertical level, layer 2 background
; 0B - BOSS
; 0C - dark horizontal level, layer 2 background
; 0D - dark vertical level, layer 2 background
; 0E - ???
; 0F - ???
; 10 - BOSS
; 11 - dark horizontal level, layer 2 background
; 12 - 
; 13 - 
; 14 - 
; 15 - 
; 16 - 
; 17 - 
; 18 - 
; 19 - 
; 1A - 
; 1B - 
; 1C - 
; 1D - 
; 1E - translucent horizontal level, layer 2 background
; 1F - translucent horizontal level, layer 2 level (with interaction)

; the most commonly used one is 00
; after that, 01 and 02 are useful for a more detailed layer 2
; vertical layouts are obsolete due to LM 3.0+ flexible level sizes
; the ones marked BOSS are useless
; the dark and translucent ones might be useful, or it might be better to use custom setups...

pushpc
	org $058417	; level mode table (don't use)
	org $058437	; main screen table
		db $1D
	org $058457	; sub screen table
		db $02
	org $058477	; CGADSUB table (2131)
		db $20
	org $058497	; used to be special table ($6D9B) but we don't use that
	org $0584B7	; OAM priority table ($64)

	org $0584FF
		LDA.l $058437,x : STA !MainScreen
		LDA.l $058457,x : STA !SubScreen
		LDA.l $058477,x : STA !2131
		LDA.l $0584B7,x : STA $64
		LDA.l $058417,x : STA !RAM_ScreenMode	; this one has to go last
		BRA +
	warnpc $058526
	org $058526 : +
pullpc







