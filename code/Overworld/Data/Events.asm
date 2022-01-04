



	EventTable:

	macro reg_event(name)
		dw .<name>
		!event_<name> := !Temp
		!Temp := !Temp+1
	endmacro



	.Ptr
		!Temp = 1
		%reg_event(CrashedAirship)
		%reg_event(BeachOpen)
		%reg_event(DomainOpen)
		%reg_event(GorgeOpen)
		%reg_event(CastleOpen)
		%reg_event(CastleClosed)
		%reg_event(RidgeOpen)
		%reg_event(TempleOpen)


	; these events trigger if the corresponding level is CLEARED
		.ClearEvents
		db !event_CrashedAirship	; level 000
		db $00				; level 001
		db $00				; level 002
		db $00				; level 003
		db $00				; level 004
		db !event_CastleClosed		; level 005
		db $00				; level 006
		db $00				; level 007
		db $00				; level 008
		db $00				; level 009
		db $00				; level 00A
		db $00				; level 00B
		db $00				; level 00C
		db $00				; level 00D
		db $00				; level 00E
		db $00				; level 00F
		db $00				; level 010
		db $00				; level 011
		db $00				; level 012
		db $00				; level 013
		db $00				; level 014
		db $00				; level 015
		db $00				; level 016
		db $00				; level 017
		db $00				; level 018
		db $00				; level 019
		db $00				; level 01A
		db $00				; level 01B
		db $00				; level 01C
		db $00				; level 01D
		db $00				; level 01E
		db $00				; level 01F
		db $00				; level 020
		db $00				; level 021
		db $00				; level 022
		db $00				; level 023
		db $00				; level 101
		db $00				; level 102
		db $00				; level 103
		db $00				; level 104
		db $00				; level 105
		db $00				; level 106
		db $00				; level 107
		db $00				; level 108
		db $00				; level 109
		db $00				; level 10A
		db $00				; level 10B
		db $00				; level 10C
		db $00				; level 10D
		db $00				; level 10E
		db $00				; level 10F
		db $00				; level 110
		db $00				; level 111
		db $00				; level 112
		db $00				; level 113
		db $00				; level 114
		db $00				; level 115
		db $00				; level 116
		db $00				; level 117
		db $00				; level 118
		db $00				; level 119
		db $00				; level 11A
		db $00				; level 11B
		db $00				; level 11C
		db $00				; level 11D
		db $00				; level 11E
		db $00				; level 11F
		db $00				; level 120
		db $00				; level 121
		db $00				; level 122
		db $00				; level 123
		db $00				; level 124
		db $00				; level 125
		db $00				; level 126
		db $00				; level 127
		db $00				; level 128
		db $00				; level 129
		db $00				; level 12A
		db $00				; level 12B
		db $00				; level 12C
		db $00				; level 12D
		db $00				; level 12E
		db $00				; level 12F
		db $00				; level 130
		db $00				; level 131
		db $00				; level 132
		db $00				; level 133
		db $00				; level 134
		db $00				; level 135
		db $00				; level 136
		db $00				; level 137
		db $00				; level 138
		db $00				; level 139
		db $00				; level 13A
		db $00				; level 13B
		db $00				; level 13C


	; these events trigger if the corresponding level is UNLOCKED
		.UnlockEvents
		db $00				; level 000
		db !event_GorgeOpen		; level 001
		db $00				; level 002
		db !event_DomainOpen		; level 003
		db !event_RidgeOpen		; level 004
		db !event_CastleOpen		; level 005
		db !event_TempleOpen		; level 006
		db $00				; level 007
		db $00				; level 008
		db $00				; level 009
		db $00				; level 00A
		db $00				; level 00B
		db !event_BeachOpen		; level 00C
		db $00				; level 00D
		db $00				; level 00E
		db $00				; level 00F
		db $00				; level 010
		db $00				; level 011
		db $00				; level 012
		db $00				; level 013
		db $00				; level 014
		db $00				; level 015
		db $00				; level 016
		db $00				; level 017
		db $00				; level 018
		db $00				; level 019
		db $00				; level 01A
		db $00				; level 01B
		db $00				; level 01C
		db $00				; level 01D
		db $00				; level 01E
		db $00				; level 01F
		db $00				; level 020
		db $00				; level 021
		db $00				; level 022
		db $00				; level 023
		db $00				; level 101
		db $00				; level 102
		db $00				; level 103
		db $00				; level 104
		db $00				; level 105
		db $00				; level 106
		db $00				; level 107
		db $00				; level 108
		db $00				; level 109
		db $00				; level 10A
		db $00				; level 10B
		db $00				; level 10C
		db $00				; level 10D
		db $00				; level 10E
		db $00				; level 10F
		db $00				; level 110
		db $00				; level 111
		db $00				; level 112
		db $00				; level 113
		db $00				; level 114
		db $00				; level 115
		db $00				; level 116
		db $00				; level 117
		db $00				; level 118
		db $00				; level 119
		db $00				; level 11A
		db $00				; level 11B
		db $00				; level 11C
		db $00				; level 11D
		db $00				; level 11E
		db $00				; level 11F
		db $00				; level 120
		db $00				; level 121
		db $00				; level 122
		db $00				; level 123
		db $00				; level 124
		db $00				; level 125
		db $00				; level 126
		db $00				; level 127
		db $00				; level 128
		db $00				; level 129
		db $00				; level 12A
		db $00				; level 12B
		db $00				; level 12C
		db $00				; level 12D
		db $00				; level 12E
		db $00				; level 12F
		db $00				; level 130
		db $00				; level 131
		db $00				; level 132
		db $00				; level 133
		db $00				; level 134
		db $00				; level 135
		db $00				; level 136
		db $00				; level 137
		db $00				; level 138
		db $00				; level 139
		db $00				; level 13A
		db $00				; level 13B
		db $00				; level 13C



; tile
; width
; height
; index to DecompressionMap
; index to tilemap


macro event(x, y, w, h, t)
	dw <t>
	if <w> != 0
		dw <w>
	else
		dw 1
	endif
	if <h> != 0
		dw <h>
	else
		dw 1
	endif
	dw (((<y>/256)*6)+(<x>/256))*4
	dw ((<y>/8)&$001F*$20+((<x>/8)&$001F))*2
endmacro


.CrashedAirship	%event($0B8, $368, 4, 4, $120)
.BeachOpen	%event($110, $330, 3, 1, $128)
.DomainOpen	%event($160, $318, 2, 3, $126)
.GorgeOpen	%event($150, $2D8, 3, 2, $12D)
.CastleOpen	%event($150, $2A8, 2, 2, $13A)
.CastleClosed	%event($150, $268, 2, 1, $12B)
.RidgeOpen	%event($0B0, $2C0, 2, 2, $138)
.TempleOpen	%event($0E8, $290, 2, 2, $138)












