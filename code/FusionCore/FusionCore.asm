

print "-- FusionCore --"



; PLAN:
; claim bank 02
;	$8000	- core bits
;	$8008	- drop item from reserve box code
;	$8072	- bomb explosion code + data
;	$8178	- unknown OAM data + code ($827D)
;	$83CC	- koopa kid code
;	$8528	- get extended sprite slot routine
;	$858F	- spawn lava splash routine
;	$8663	- shatter block routine
;	$86BF	- yoshi stomp routine
;	$86ED	- sprite interact with bounce sprite routine
;	LOTS OF FUSION SPRITE CODES HERE
;	$A773	- old load sprite from level codes + data
;	$AFFE	- "CallGenerator", might be used?
;	$B387	- shooter code
;	$B5EC	- sprite codes (a few sprites have code in bank 02)
;		  aaaaand that's it, the rest of the bank is just sprite codes


; new list:
;	00 -- EMPTY --
;	01 mario fireball
;	02 luigi fireball
;	03 ----				;\
;	04 ----				; |
;	05 ----				; | reserved for more player options
;	06 ----				; |
;	07 ----				;/
;	08 malleable extended sprite
;	09 hammer
;	0A bone
;	0B baseball
;	0C small fireball
;	0D big fireball
;	0E tiny flame
;	0F volcano lotus fire
;	10 glitter
;	11 ?-block (bouncing)
;	12 brick (bouncing)
;	13 coin from block
;	14 shooter
;	15 torpedo ted launcher
;	16 torpedo ted arm
;	17 dizzy star
;	18 explosion

	FusionCore:
		PHB : PHK : PLB
		JSR HandleEx
		JSR ParticleMain		; execute particle code
		JSR BG_OBJECTS			; execute BG_object code
		PLB
		RTL


incsrc "FusionSprites.asm"
incsrc "ParticleSystem.asm"
incsrc "BG_objects.asm"




print " - Ex_Num mapped to ........$", hex(!Ex_Num), " - $", hex(!Ex_Num+!Ex_Amount-1)
print " - Ex_Data1 mapped to ......$", hex(!Ex_Data1), " - $", hex(!Ex_Data1+!Ex_Amount-1)
print " - Ex_Data2 mapped to ......$", hex(!Ex_Data2), " - $", hex(!Ex_Data2+!Ex_Amount-1)
print " - Ex_Data3 mapped to ......$", hex(!Ex_Data3), " - $", hex(!Ex_Data3+!Ex_Amount-1)
print " - Ex_YLo mapped to ........$", hex(!Ex_YLo), " - $", hex(!Ex_YLo+!Ex_Amount-1)
print " - Ex_XLo mapped to ........$", hex(!Ex_XLo), " - $", hex(!Ex_XLo+!Ex_Amount-1)
print " - Ex_YHi mapped to ........$", hex(!Ex_YHi), " - $", hex(!Ex_YHi+!Ex_Amount-1)
print " - Ex_XHi mapped to ........$", hex(!Ex_XHi), " - $", hex(!Ex_XHi+!Ex_Amount-1)
print " - Ex_YSpeed mapped to .....$", hex(!Ex_YSpeed), " - $", hex(!Ex_YSpeed+!Ex_Amount-1)
print " - Ex_XSpeed mapped to .....$", hex(!Ex_XSpeed), " - $", hex(!Ex_XSpeed+!Ex_Amount-1)
print " - Ex_YFraction mapped to ..$", hex(!Ex_YFraction), " - $", hex(!Ex_YFraction+!Ex_Amount-1)
print " - Ex_XFraction mapped to ..$", hex(!Ex_XFraction), " - $", hex(!Ex_XFraction+!Ex_Amount-1)
print "Number of ExSprites allowed: ", dec(!Ex_Amount), " (0x", hex(!Ex_Amount), ")"
print "Number of ExSprite types: ", dec(FusionSprite_HandleEx_PalsetIndex_end-FusionSprite_HandleEx_PalsetIndex), " (0x", hex(FusionSprite_HandleEx_PalsetIndex_end-FusionSprite_HandleEx_PalsetIndex), ")"
print " "
