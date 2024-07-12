
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
;	X and Y are tile coordinates, which can be obtained by mousing over a location in Lunar Magic
;	R, G, B and size are fractions! The first digit is the whole, the last 2 digits are decimals (or "hexa-decimals", i suppose)
;		for example, $100 = $1.00, meaning 1.00
;		$080 = $0.80, meaning one half, or 0.5
;		$200 = $2.00, meaning 2.0... and so on
;
; hex fractions:
;	unless you go absurdly high, the first digit is the same as in decimal
;	0 = 0.xx, 1 = 1.xx, 2 = 2.xx and so on
;	the following two digits must be thought of in hex though, but you can use this cheat sheet:
;
;		hex	dec
;		00	.00
;		10	.06
;		20	.13
;		30	.19
;		40	.25
;		50	.31
;		60	.38
;		70	.44
;		80	.50
;		90	.56
;		A0	.63
;		B0	.69
;		C0	.75
;		D0	.81
;		E0	.88
;		F0	.94
;
;		dec	hex
;		.05	0D
;		.10	1A
;		.15	26
;		.20	33
;		.25	40
;		.30	4D
;		.35	5A
;		.40	66
;		.45	73
;		.50	80
;		.55	8D
;		.60	9A
;		.65	A6
;		.70	B3
;		.75	C0
;		.80	CD
;		.85	DA
;		.90	E6
;		.95	F3

		;	    --X--	--Y--		R     G     B    size  level
		%LightPoint(43,		34,		$140, $0C0, $080, $100, $02A)
		%LightPoint(103,	22,		$140, $0C0, $080, $180, $02A)
		%LightPoint(145,	17,		$140, $0C0, $080, $100, $02A)
		%LightPoint(200,	19,		$140, $0C0, $080, $360, $02A)





		..end
		; don't mess with this label

