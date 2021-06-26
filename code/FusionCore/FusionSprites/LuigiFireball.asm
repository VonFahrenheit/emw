
	print "Luigi Fireball inserted at $", pc
	LuigiFireball:
		LDX $75E9

		LDA !Ex_YLo,x : PHA
		LDA !Ex_YHi,x : PHA
		STZ !Ex_YSpeed,x

		PHK : PEA.w .Return-1
		PEA $8B66-1			; point to RTL
		JML $029FAF

		.Return
		PLA : STA !Ex_YHi,x
		PLA : STA !Ex_YLo,x
		RTS