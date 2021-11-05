
	macro LightPoint(X, Y, R, G, B, S, Level)
		dw <X>*16
		dw <Y>*16
		dw <R>
		dw <G>
		dw <B>
		dw <S>
		dw <Level>
	endmacro



; note:
;	X and Y are pixel coordinates, the first 2 digits are screen number and the second 2 digits are coordinates on that screen
;	R, G, B and size are fractions! The first digit is the whole, the last 2 digits are decimals (or "hexa-decimals", i suppose)
;		for example, $100 = $1.00, meaning 1.00
;		$080 = $0.80, meaning one half, or 0.5
;		$200 = $2.00, meaning 2.0, and so on

	LightPoints:
		;	    --X--	--Y--		R     G     B    size  level
		%LightPoint(43,		24,		$180, $080, $080, $100, $02A)
		%LightPoint(104,	22,		$180, $080, $080, $180, $02A)





		.End
