
macro level(X, Y, W, H, num)
	dw !TempX*256+(<X>&$00FF)&$FFF8
	dw !TempY*256+(<Y>&$00FF)&$FFF8
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
	!TempY = 0
	!TempX = 0
	.Screen11
	..end
	!TempX = 1
	.Screen12
	..end
	!TempX = 2
	.Screen13
	..end
	!TempX = 3
	.Screen14
	..end
	!TempX = 4
	.Screen15
	..end
	!TempX = 5
	.Screen16
	..end

	!TempY = 1
	!TempX = 0
	.Screen21
	..end
	!TempX = 1
	.Screen22
	..end
	!TempX = 2
	.Screen23
	..end
	!TempX = 3
	.Screen24
	..end
	!TempX = 4
	.Screen25
	..end
	!TempX = 5
	.Screen26
	..end

	!TempY = 2
	!TempX = 0
	.Screen31
		%level($F0, $90, 0, 0, 5)	; castle rex

		%level($80, $F0, 0, 0, 1)
		%level($98, $F0, 0, 0, 2)
		%level($B0, $F0, 0, 0, 3)
		%level($C8, $F0, 0, 0, 4)
		%level($E0, $F0, 0, 0, 6)
		%level($F8, $F0, 0, 0, $0C)

	..end
	!TempX = 1
	.Screen32
	..end
	!TempX = 2
	.Screen33
	..end
	!TempX = 3
	.Screen34
	..end
	!TempX = 4
	.Screen35
	..end
	!TempX = 5
	.Screen36
	..end

	!TempY = 3
	!TempX = 0
	.Screen41
	..end
	!TempX = 1
	.Screen42
	..end
	!TempX = 2
	.Screen43
	..end
	!TempX = 3
	.Screen44
	..end
	!TempX = 4
	.Screen45
	..end
	!TempX = 5
	.Screen46
	..end















