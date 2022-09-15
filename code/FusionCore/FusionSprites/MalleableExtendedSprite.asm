
; Use of ExSprite data:
;
;	!Ex_Palset:		YXPPCCCT byte
;	!Ex_Data1:		this is the GFX tile, as well as its hitbox mode:
;				tttHtttt
;				H - hitbox: if this is set, the ExSprite hurts players upon contact
;				t - tile (lowest bit in hi nybble is clear because of 8x16 block format)
;	!Ex_Data2:		life timer, reduced every other frame
;	!Ex_Data3:		Dso--GGG
;				D - die upon contact with player
;				s - tile size (0 = 8x8, 1 = 16x16)
;				o - offscreen (0 = despawn, 1 = keep going)
;				G - gravity value, added to Y speed every frame


	MalleableExtendedSprite:
		LDX !SpriteIndex

		RTS














