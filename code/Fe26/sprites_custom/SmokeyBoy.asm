

SmokeyBoy:

	namespace SmokeyBoy

	INIT:
		LDA #$E8 : STA $32A0,x

	MAIN:
		PHB : PHK : PLB

		LDA $3280,x : PHA
		LDA $3290,x : PHA
		LDA $32A0,x : STA $3280,x
		LDA $32B0,x : STA $3290,x
		JSR .DrawSmoke
		LDA $3290,x : STA $32B0,x
		LDA $3280,x : STA $32A0,x
		PLA : STA $3290,x
		PLA : STA $3280,x
		JSR .DrawSmoke
		.Return
		PLB
		RTL

		.DrawSmoke
		DEC $3280,x
		LDA $3280,x
		CMP #$C0 : BNE .Draw
		.Reset
		SEC : ROR A
		STA $01
		LDA $3290,x : STA $00
		STZ $02
		LDA #$F0 : STA $03
		STZ $04
		STZ $05
		STZ $07
		LDA.b #!prt_smoke16x16 : JSL SpawnParticle
		LDA #$FF : STA $3280,x

		.Draw
		LDA #$01 : STA $3320,x
		REP #$20
		LDA #$0004 : STA !BigRAM+0
		LDA #$0814 : STA !BigRAM+2
		LDA #$6000 : STA !BigRAM+4
		LDA.w #!BigRAM : STA $04
		SEP #$20

		LDA $3280,x
		SEC : ROR A
		STA !BigRAM+4
		LDA $3280,x
		LSR #2
		AND #$0F
		SEC : SBC #$08
		BPL $02 : EOR #$FF
		CLC : ADC #$08
		STA !BigRAM+3
		STA $3290,x

		JSL LOAD_TILEMAP
		RTS




	namespace off

