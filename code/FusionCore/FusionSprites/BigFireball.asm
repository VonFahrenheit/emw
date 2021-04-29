
	print "Big Fireball inserted at $",pc
	BigFireball:
		LDX $75E9
		PHK : PEA.w .Return-1
		PEA $8B66-1
		JML $02A16B			; enemy fireball code
		.Return
		RTS