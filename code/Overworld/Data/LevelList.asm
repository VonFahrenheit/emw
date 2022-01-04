
macro level(X, Y, W, H, num)
	dw <X>
	dw <Y>
	if <W> = 0
		db 8
	else
		db <W>
	endif
	if <H> = 0
		db 8
	else
		db <H>
	endif
	if <num> < $24
		db <num>
	else
		db <num>-$DC
	endif
endmacro


; to enter a level:
;	- use the %level() macro on the correct screen (after .Screen, before ..end)
;	- enter, in order:
;		X (on-screen X coordinate)
;		Y (on-screen Y coordinate)
;		W (width)
;		H (height)
;		num (level number, has to be a translevel num)



LevelList:
	.Screen11
	; levels here
	..end
	.Screen12
	; levels here
	..end
	.Screen13
	; levels here
	..end
	.Screen14
	; levels here
	..end
	.Screen15
	; levels here
	..end
	.Screen16
	; levels here
	..end

	.Screen21
	; levels here
	..end
	.Screen22
	; levels here
	..end
	.Screen23
	; levels here
	..end
	.Screen24
	; levels here
	..end
	.Screen25
	; levels here
	..end
	.Screen26
	; levels here
	..end

	.Screen31
		%level(208, 760, 32, 32,	$002)	; rex village
		%level(320, 816, 64, 64,	$00C)	; rex reef beach
		%level(350, 740, 32, 32, 	$003)	; dinolord's domain
		%level(296, 688, 32, 32, 	$001)	; mushroom gorge
		%level(336, 616, 0, 0,		$005)	; castle rex
		%level(160, 668, 64, 28, 	$004)	; fuzzy's ridge
		%level(246, 638, 0, 0,	 	$006)	; evernight temple
	..end
	.Screen32
		%level(208, 760, 32, 32,	$002)	; rex village
		%level(320, 816, 64, 64,	$00C)	; rex reef beach
		%level(350, 740, 32, 32, 	$003)	; dinolord's domain
		%level(296, 688, 32, 32, 	$001)	; mushroom gorge
		%level(336, 616, 0, 0,		$005)	; castle rex
		%level(160, 668, 64, 28, 	$004)	; fuzzy's ridge
		%level(246, 638, 0, 0,	 	$006)	; evernight temple
	..end
	.Screen33
	; levels here
	..end
	.Screen34
	; levels here
	..end
	.Screen35
	; levels here
	..end
	.Screen36
	; levels here
	..end

	.Screen41
		%level(208, 760, 32, 32,	$002)	; rex village
		%level(320, 816, 64, 64,	$00C)	; rex reef beach
		%level(350, 740, 32, 32, 	$003)	; dinolord's domain
		%level(296, 688, 32, 32, 	$001)	; mushroom gorge
		%level(336, 616, 0, 0,		$005)	; castle rex
		%level(160, 668, 64, 28, 	$004)	; fuzzy's ridge
		%level(246, 638, 0, 0,	 	$006)	; evernight temple
	..end
	.Screen42
		%level(208, 760, 32, 32,	$002)	; rex village
		%level(320, 816, 64, 64,	$00C)	; rex reef beach
		%level(350, 740, 32, 32, 	$003)	; dinolord's domain
		%level(296, 688, 32, 32, 	$001)	; mushroom gorge
		%level(336, 616, 0, 0,		$005)	; castle rex
		%level(160, 668, 64, 28, 	$004)	; fuzzy's ridge
		%level(246, 638, 0, 0,	 	$006)	; evernight temple
	..end
	.Screen43
	; levels here
	..end
	.Screen44
	; levels here
	..end
	.Screen45
	; levels here
	..end
	.Screen46
	; levels here
	..end















