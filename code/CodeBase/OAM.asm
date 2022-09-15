;===========;
; OAM CODES ;
;===========;

macro oamtable(source)
		LDA.w !OAMindex_<source> : BEQ ?next
		CMP $00 : BCC ?notcapped
		LDA $00
		STZ $00
		BRA ?go
	?notcapped:
		LDA $00
		SEC : SBC.w !OAMindex_<source>
		STA $00
		LDA.w !OAMindex_<source>
	?go:
		DEC A
		LDX.w #!OAM_<source>
		PHB
		MVN $00,!OAM_<source>>>16
		PLB
	?next:
endmacro

macro oamtablehi(source)
		LDA.w !OAMindex_<source> : BEQ ?next
		LSR #2
		STA $02
		CMP $00 : BCC ?notcapped
		LDA $00
		STZ $00
		BRA ?go
	?notcapped:
		LDA $00
		SEC : SBC $02
		STA $00
		LDA $02
	?go:
		DEC A
		LDX.w #!OAMhi_<source>
		PHB
		MVN $00,!OAMhi_<source>>>16
		PLB
	?next:
endmacro

macro clearOAM(tile)
		..tile_<tile>
		STA.w !OAM+($<tile>*4)+1
endmacro


; input: void
; output: void
	KillOAM:
		TSC
		XBA
		CMP #$37 : BEQ .SA1
		LDA.b #.SA1 : STA $3180
		LDA.b #.SA1>>8 : STA $3181
		LDA.b #.SA1>>16 : STA $3182
		JSR $1E80
		RTL

		.SA1
		PHB : PHK : PLB
		PHP
		SEP #$30
		LDA #$F0 : JSR BuildOAM_Clear_tile_000
		REP #$20
		LDA #$0000
		STA !OAMindex
		STA !OAMindex_p0
		STA !OAMindex_p1
		STA !OAMindex_p2
		STA !OAMindex_p3
		PLP
		PLB
		RTL



; input: void
; output: void
	BuildOAM:
		TSC
		XBA
		CMP #$37 : BEQ .Assemble
		LDA.b #.Assemble : STA $3180
		LDA.b #.Assemble>>8 : STA $3181
		LDA.b #.Assemble>>16 : STA $3182
		JSR $1E80
		RTL


		.Assemble
		PHB
		PHP
		SEP #$30
		LDA #$41
		PHA : PLB
		REP #$30
		LDA #$0200 : STA $00				; lo table size
		LDY.w #!OAM					; dest address (lo table)
		%oamtable(p3)					;\ prio 3 lo table
		LDA $00 : BNE $03 : JMP ..hitable		;/
		%oamtable(p2)					;\ prio 2 lo table
		LDA $00 : BEQ ..hitable				;/
		%oamtable(p1)					;\ prio 1 lo table
		LDA $00 : BEQ ..hitable				;/
		%oamtable(p0)					; prio 0 lo table

		LDA $00 : BEQ ..hitable				;\
		SEC : SBC #$0200				; |
		EOR #$FFFF : INC A				; |
		LSR A						; | move unused tiles off-screen
		TAX						; |
		PHB : PHK : PLB					; |
		LDA #$00F0 : JSR (.Clear,x)			; |
		PLB						;/

		..hitable
		LDA #$0080 : STA $00				; hi table size
		LDY.w #!OAMhi					; dest address (hi table)
	..p3	%oamtablehi(p3)					;\ prio 3 hi table
		LDA $00 : BEQ ..finish				;/
	..p2	%oamtablehi(p2)					;\ prio 2 hi table
		LDA $00 : BEQ ..finish				;/
	..p1	%oamtablehi(p1)					;\ prio 1 hi table
		LDA $00 : BEQ ..finish				;/
	..p0	%oamtablehi(p0)					; prio 0 hi table

		..finish
		LDA.l !OAMindex_p0 : STA.l !OAMindex_p0_prev	;\
		LDA.l !OAMindex_p1 : STA.l !OAMindex_p1_prev	; | store these for next frame
		LDA.l !OAMindex_p2 : STA.l !OAMindex_p2_prev	; |
		LDA.l !OAMindex_p3 : STA.l !OAMindex_p3_prev	;/
		LDA #$0000					;\
		STA.l !OAMindex					; |
		STA.l !OAMindex_p0				; | clear indexes
		STA.l !OAMindex_p1				; |
		STA.l !OAMindex_p2				; |
		STA.l !OAMindex_p3				;/
		SEP #$30					; all regs 8-bit
		LDA #$00					;\ bank 0x00
		PHA : PLB					;/
		LDY #$1E					; > start loop at 0x1E to reach all tiles (32 bytes)
	-	LDX.w $8475,y					;\
		LDA.w !OAMhi+3,x				; |
		ASL #2						; |
		ORA.w !OAMhi+2,x				; |
		ASL #2						; |
		ORA.w !OAMhi+1,x				; |
		ASL #2						; |
		ORA.w !OAMhi+0,x				; | assemble hi OAM table
		STA.w !OAM+$200,y				; |
		LDA.w !OAMhi+7,x				; |
		ASL #2						; |
		ORA.w !OAMhi+6,x				; |
		ASL #2						; |
		ORA.w !OAMhi+5,x				; |
		ASL #2						; |
		ORA.w !OAMhi+4,x				; |
		STA.w !OAM+$201,y				; |
		DEY #2						; |
		BPL -						;/
		PLP						;\ pull stuff
		PLB						;/
		RTL						; > return

	; pointers to optimize OAM clear
		.Clear
		dw ..tile_000
		dw ..tile_001
		dw ..tile_002
		dw ..tile_003
		dw ..tile_004
		dw ..tile_005
		dw ..tile_006
		dw ..tile_007
		dw ..tile_008
		dw ..tile_009
		dw ..tile_00A
		dw ..tile_00B
		dw ..tile_00C
		dw ..tile_00D
		dw ..tile_00E
		dw ..tile_00F
		dw ..tile_010
		dw ..tile_011
		dw ..tile_012
		dw ..tile_013
		dw ..tile_014
		dw ..tile_015
		dw ..tile_016
		dw ..tile_017
		dw ..tile_018
		dw ..tile_019
		dw ..tile_01A
		dw ..tile_01B
		dw ..tile_01C
		dw ..tile_01D
		dw ..tile_01E
		dw ..tile_01F
		dw ..tile_020
		dw ..tile_021
		dw ..tile_022
		dw ..tile_023
		dw ..tile_024
		dw ..tile_025
		dw ..tile_026
		dw ..tile_027
		dw ..tile_028
		dw ..tile_029
		dw ..tile_02A
		dw ..tile_02B
		dw ..tile_02C
		dw ..tile_02D
		dw ..tile_02E
		dw ..tile_02F
		dw ..tile_030
		dw ..tile_031
		dw ..tile_032
		dw ..tile_033
		dw ..tile_034
		dw ..tile_035
		dw ..tile_036
		dw ..tile_037
		dw ..tile_038
		dw ..tile_039
		dw ..tile_03A
		dw ..tile_03B
		dw ..tile_03C
		dw ..tile_03D
		dw ..tile_03E
		dw ..tile_03F
		dw ..tile_040
		dw ..tile_041
		dw ..tile_042
		dw ..tile_043
		dw ..tile_044
		dw ..tile_045
		dw ..tile_046
		dw ..tile_047
		dw ..tile_048
		dw ..tile_049
		dw ..tile_04A
		dw ..tile_04B
		dw ..tile_04C
		dw ..tile_04D
		dw ..tile_04E
		dw ..tile_04F
		dw ..tile_050
		dw ..tile_051
		dw ..tile_052
		dw ..tile_053
		dw ..tile_054
		dw ..tile_055
		dw ..tile_056
		dw ..tile_057
		dw ..tile_058
		dw ..tile_059
		dw ..tile_05A
		dw ..tile_05B
		dw ..tile_05C
		dw ..tile_05D
		dw ..tile_05E
		dw ..tile_05F
		dw ..tile_060
		dw ..tile_061
		dw ..tile_062
		dw ..tile_063
		dw ..tile_064
		dw ..tile_065
		dw ..tile_066
		dw ..tile_067
		dw ..tile_068
		dw ..tile_069
		dw ..tile_06A
		dw ..tile_06B
		dw ..tile_06C
		dw ..tile_06D
		dw ..tile_06E
		dw ..tile_06F
		dw ..tile_070
		dw ..tile_071
		dw ..tile_072
		dw ..tile_073
		dw ..tile_074
		dw ..tile_075
		dw ..tile_076
		dw ..tile_077
		dw ..tile_078
		dw ..tile_079
		dw ..tile_07A
		dw ..tile_07B
		dw ..tile_07C
		dw ..tile_07D
		dw ..tile_07E
		dw ..tile_07F

		%clearOAM(000)
		%clearOAM(001)
		%clearOAM(002)
		%clearOAM(003)
		%clearOAM(004)
		%clearOAM(005)
		%clearOAM(006)
		%clearOAM(007)
		%clearOAM(008)
		%clearOAM(009)
		%clearOAM(00A)
		%clearOAM(00B)
		%clearOAM(00C)
		%clearOAM(00D)
		%clearOAM(00E)
		%clearOAM(00F)
		%clearOAM(010)
		%clearOAM(011)
		%clearOAM(012)
		%clearOAM(013)
		%clearOAM(014)
		%clearOAM(015)
		%clearOAM(016)
		%clearOAM(017)
		%clearOAM(018)
		%clearOAM(019)
		%clearOAM(01A)
		%clearOAM(01B)
		%clearOAM(01C)
		%clearOAM(01D)
		%clearOAM(01E)
		%clearOAM(01F)
		%clearOAM(020)
		%clearOAM(021)
		%clearOAM(022)
		%clearOAM(023)
		%clearOAM(024)
		%clearOAM(025)
		%clearOAM(026)
		%clearOAM(027)
		%clearOAM(028)
		%clearOAM(029)
		%clearOAM(02A)
		%clearOAM(02B)
		%clearOAM(02C)
		%clearOAM(02D)
		%clearOAM(02E)
		%clearOAM(02F)
		%clearOAM(030)
		%clearOAM(031)
		%clearOAM(032)
		%clearOAM(033)
		%clearOAM(034)
		%clearOAM(035)
		%clearOAM(036)
		%clearOAM(037)
		%clearOAM(038)
		%clearOAM(039)
		%clearOAM(03A)
		%clearOAM(03B)
		%clearOAM(03C)
		%clearOAM(03D)
		%clearOAM(03E)
		%clearOAM(03F)
		%clearOAM(040)
		%clearOAM(041)
		%clearOAM(042)
		%clearOAM(043)
		%clearOAM(044)
		%clearOAM(045)
		%clearOAM(046)
		%clearOAM(047)
		%clearOAM(048)
		%clearOAM(049)
		%clearOAM(04A)
		%clearOAM(04B)
		%clearOAM(04C)
		%clearOAM(04D)
		%clearOAM(04E)
		%clearOAM(04F)
		%clearOAM(050)
		%clearOAM(051)
		%clearOAM(052)
		%clearOAM(053)
		%clearOAM(054)
		%clearOAM(055)
		%clearOAM(056)
		%clearOAM(057)
		%clearOAM(058)
		%clearOAM(059)
		%clearOAM(05A)
		%clearOAM(05B)
		%clearOAM(05C)
		%clearOAM(05D)
		%clearOAM(05E)
		%clearOAM(05F)
		%clearOAM(060)
		%clearOAM(061)
		%clearOAM(062)
		%clearOAM(063)
		%clearOAM(064)
		%clearOAM(065)
		%clearOAM(066)
		%clearOAM(067)
		%clearOAM(068)
		%clearOAM(069)
		%clearOAM(06A)
		%clearOAM(06B)
		%clearOAM(06C)
		%clearOAM(06D)
		%clearOAM(06E)
		%clearOAM(06F)
		%clearOAM(070)
		%clearOAM(071)
		%clearOAM(072)
		%clearOAM(073)
		%clearOAM(074)
		%clearOAM(075)
		%clearOAM(076)
		%clearOAM(077)
		%clearOAM(078)
		%clearOAM(079)
		%clearOAM(07A)
		%clearOAM(07B)
		%clearOAM(07C)
		%clearOAM(07D)
		%clearOAM(07E)
		%clearOAM(07F)
		RTS




; input:
;	$00 = x offset
;	$01 = y offset
;	$02 = 16-bit tilemap pointer (X, Y, T, P)
;	$04 = sprite offset (default version zeroes this)
;	$0D = size bit (same for all tiles)
;	$0E = byte count of tilemap

; tilemap format:
;	+00	X
;	+01	Y
;	+02	tile
;	+03	prop
	DrawSpriteHUD:
		PHP
		SEP #$20
		STZ $0F					; cap tilemap at 256 bytes
		REP #$30
		STZ $04					; default version does not include GFX offset
		BRA .Main

		.IncludeOffset
		PHP
		SEP #$20
		STZ $0F					; cap tilemap at 256 bytes
		REP #$30

		.Main
		LDY #$0000
		LDA !OAMindex_p3 : TAX
		..loop
		LDA ($02),y
		CLC : ADC $00				; this works as long as X coord doesn't overflow
		BCC ..draw				; only draw if there's no overflow on Y
		INY #4
		BRA ..next
		..draw
		SEP #$20
		LDA ($02),y
		CLC : ADC $00
		STA !OAM_p3+$000,x
		LDA #$01 : TRB $0D
		BCC $02 : TSB $0D
		INY
		LDA ($02),y
		CLC : ADC $01
		STA !OAM_p3+$001,x
		INY
		REP #$20
		LDA ($02),y
		CLC : ADC $04				; just adds 0 on default version
		STA !OAM_p3+$002,x
		INY #2
		PHX
		TXA
		LSR #2
		TAX
		LDA $0D
		AND #$0003
		STA !OAMhi_p3+$00,x
		PLX
		INX #4
		..next
		CPY $0E : BCC ..loop
		TXA : STA !OAMindex_p3
		PLP
		RTL


; input:
;	$00 = x offset
;	$01 = y offset
;	$02 = 16-bit tilemap pointer (X, Y, T, P)
;	$04 = sprite offset (default version zeroes this)
;	$0D = size bit (same for all tiles)
;	$0E = byte count of tilemap

; tilemap format:
;	+00	X
;	+01	Y
;	+02	tile
;	+03	prop
	DrawSpriteBG:
		PHP
		SEP #$20
		STZ $0F
		REP #$30
		STZ $04
		BRA .Main

		.IncludeOffset
		PHP
		SEP #$20
		STZ $0F
		REP #$30

		.Main
		LDY #$0000
		LDA !OAMindex_p0 : TAX
		..loop
		LDA ($02),y
		CLC : ADC $00				; this works as long as X coord doesn't overflow
		BCC ..draw				; only draw if there's no overflow on Y
		INY #4
		BRA ..next
		..draw
		SEP #$20
		LDA ($02),y
		CLC : ADC $00
		STA !OAM_p0+$000,x
		LDA #$01 : TRB $0D
		BCC $02 : TSB $0D
		INY
		LDA ($02),y
		CLC : ADC $01
		STA !OAM_p0+$001,x
		INY
		REP #$20
		LDA ($02),y : STA !OAM_p0+$002,x
		INY #2
		PHX
		TXA
		LSR #2
		TAX
		LDA $0D
		AND #$0003
		STA !OAMhi_p0+$00,x
		PLX
		INX #4
		..next
		CPY $0E : BCC ..loop
		TXA : STA !OAMindex_p0
		PLP
		RTL
