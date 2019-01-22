PlantHead:

	namespace PlantHead


	INIT:
		PHB : PHK : PLB
		PLB


	MAIN:
		PHB : PHK : PLB
		JSR SPRITE_OFF_SCREEN
		LDA $3230,x
		SEC : SBC #$08
		ORA $9D
		BEQ PHYSICS
		JMP GRAPHICS

	DATA:


	PHYSICS:


	INTERACTION:


	GRAPHICS:

		.Return
		PLB
		RTL


	ANIM:


	namespace off





