
	LuigiFireball:
		LDX !SpriteIndex
		INC !Ex_Data1,x
		LDA !Ex_Data1,x
		CMP #$40 : BNE .Process
		JMP TurnToSmoke

		.Process
		STZ !Ex_YSpeed,x
		JSR ApplySpeed
		JSR DestroyAtWall

		JSR DrawExSprite
		dw !GFX_LuigiFireball_offset
		db $00,$31

		RTS

