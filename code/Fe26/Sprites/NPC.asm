NPC:

	namespace NPC

		!ID		=	$BE,x
		!Talking	=	$32B0,x
		!TalkTimer	=	$32E0,x


; NPC list:
;	00 - mario NPC
;	01 - luigi NPC
;	02 - kadaal NPC
;	03 - leeway NPC
;	04 - alter NPC
;	05 - peach NPC
;	06 - survivor
;	07 - tinker
;	08 - rally yoshi
;	09 - big yoshi
;	0A - painter yoshi
;	0B - old yoshi
;	0C - reserved for yoshi NPC
;	0D - reserved for yoshi NPC
;	0E - reserved for yoshi NPC
;	0F - reserved for yoshi NPC
;	10 - toad
;	11 - reserved for captain toad
;
;



	INIT:
		PHB : PHK : PLB
		LDA !ExtraProp1,x
		ASL A
		CMP.b #.InitPtr_End-.InitPtr : BCS .Return
		TAX
		JSR (.InitPtr,x)
		.Return
		PLB
		RTL


		.InitPtr
		dw .Mario		; 00
		dw .Luigi		; 01
		dw .Kadaal		; 02
		dw .Leeway		; 03
		dw .Alter		; 04
		dw .Peach		; 05
		dw .Survivor		; 06
		dw .Tinker		; 07
		dw .RallyYoshi		; 08
		dw .BigYoshi		; 09
		dw .PainterYoshi	; 0A
		dw .OldYoshi		; 0B
		dw .Unused		; 0C
		dw .Unused		; 0D
		dw .Unused		; 0E
		dw .Unused		; 0F
		dw .Toad		; 10
		dw .Unused		; 11
		..End


		.Mario
		LDX !SpriteIndex
		RTS

		.Luigi
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_luigi : JSL LoadPalset
		LDX $0F
		LDA !GFX_status+$180,x
		ASL A
		LDX !SpriteIndex
		STA $33C0,x
		RTS


		.Kadaal
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_kadaal : JSL LoadPalset
		LDX $0F
		LDA !GFX_status+$180,x
		ASL A
		LDX !SpriteIndex
		STA $33C0,x
		RTS



		.Leeway
		LDX !SpriteIndex
		RTS

		.Alter
		LDX !SpriteIndex
		RTS

		.Peach
		LDX !SpriteIndex
		RTS

		.Survivor
		LDX !SpriteIndex
		RTS

		.Tinker
		LDX !SpriteIndex
		RTS

		.RallyYoshi
		LDX !SpriteIndex
		RTS

		.BigYoshi
		LDX !SpriteIndex
		RTS

		.PainterYoshi
		LDX !SpriteIndex
		RTS

		.OldYoshi
		LDX !SpriteIndex
		RTS

		.Toad
		LDX !SpriteIndex
		RTS

		.Unused
		LDX !SpriteIndex
		RTS



	MAIN:
		LDA !GameMode
		CMP #$14 : BEQ .Process
		RTL

		.Process
		PHB : PHK : PLB
		LDA !ExtraProp1,x
		ASL A
		CMP.b #.MainPtr_End-.MainPtr : BCS .Return
		TAX
		JSR (.MainPtr,x)
		.Return
		PLB
		RTL


		.MainPtr
		dw Mario		; 00
		dw Luigi		; 01
		dw Kadaal		; 02
		dw Leeway		; 03
		dw Alter		; 04
		dw Peach		; 05
		dw Survivor		; 06
		dw Tinker		; 07
		dw RallyYoshi		; 08
		dw BigYoshi		; 09
		dw PainterYoshi		; 0A
		dw OldYoshi		; 0B
		dw Unused		; 0C
		dw Unused		; 0D
		dw Unused		; 0E
		dw Unused		; 0F
		dw Toad			; 10
		dw Unused		; 11
		..End


	Mario:
		LDX !SpriteIndex
		RTS

	Luigi:
		LDX !SpriteIndex				; X = sprite index
		JSR CheckPlayer					;\ check for matching player
		BNE $01 : RTS					;/
		JSR CheckSwap					; check for swap
		REP #$30					;\
		LDY.w #!File_Luigi				; |
		LDA.w #.KnockedOutDyn : STA $0C			; |
		JSL LOAD_SQUARE_DYNAMO				; | draw
		LDA.w #Tilemap_32x16 : STA $04			; |
		SEP #$30					; |
		JSL SETUP_SQUARE				; |
		JSL LOAD_DYNAMIC				;/
		RTS


		.KnockedOutDyn
		dw ..End-..Start
		..Start
		%SquareDyn($22A)
		%SquareDyn($22C)
		..End



	Kadaal:
		LDX !SpriteIndex				; X = sprite index
		JSR CheckPlayer					;\ check for matching player
		BNE $01 : RTS					;/
		JSR CheckSwap					; check for swap
		LDA !SpriteAnimIndex				;\
		ASL #2						; |
		TAY						; | process anim timer
		LDA !SpriteAnimTimer				; |
		INC A						; |
		CMP .AnimTable+2,y : BNE +			;/
		LDA .AnimTable+3,y : STA !SpriteAnimIndex	;\
		REP #$30					; |
		LDA .AnimTable+0,y : STA $0C			; |
		LDY.w #!File_Kadaal				; | process dynamic tiles
		JSL LOAD_SQUARE_DYNAMO				; |
		SEP #$30					; |
		LDA #$00					;/
	+	STA !SpriteAnimTimer				; update anim timer
		REP #$20					;\
		LDA.w #Tilemap_16x32 : STA $04			; |	
		SEP #$20					; | draw to OAM
		JSL SETUP_SQUARE				; |
		JSL LOAD_DYNAMIC				;/
		RTS

		.AnimTable
		dw .Idle00 : db $04,$01
		dw .Idle01 : db $04,$02
		dw .Idle00 : db $04,$03
		dw .Idle02 : db $04,$00


		.Idle00
		dw ..End-..Start
		..Start
		%SquareDyn($000)
		%SquareDyn($020)
		..End

		.Idle01
		dw ..End-..Start
		..Start
		%SquareDyn($002)
		%SquareDyn($022)
		..End

		.Idle02
		dw ..End-..Start
		..Start
		%SquareDyn($004)
		%SquareDyn($024)
		..End





	Leeway:
		LDX !SpriteIndex
		RTS

	Alter:
		LDX !SpriteIndex
		RTS

	Peach:
		LDX !SpriteIndex
		RTS

	Survivor:
		LDX !SpriteIndex
		RTS

	Tinker:
		LDX !SpriteIndex
		RTS

	RallyYoshi:
		LDX !SpriteIndex
		RTS

	BigYoshi:
		LDX !SpriteIndex
		RTS

	PainterYoshi:
		LDX !SpriteIndex
		RTS

	OldYoshi:
		LDX !SpriteIndex
		RTS

	Toad:
		LDX !SpriteIndex
		RTS

	Unused:
		LDX !SpriteIndex
		RTS



	Tilemap:

	.16x32
	dw $0008
	db $3E,$00,$F0,$00
	db $3E,$00,$00,$01

	.32x16
	dw $0008
	db $3E,$F8,$00,$00
	db $3E,$08,$00,$01







		LDA !ExtraBits,x : BMI .Main

		.Init
		ORA #$80 : STA !ExtraBits,x
		REP #$20				; > A 16-bit
		LDA.l !NPC_ID+1				;\
		AND #$FF00				; | Check for a defined NPC table
		BNE .TableFound				;/
		LDA.l !NPC_ID+1				;\
		BNE .TableFound				; | If there's no defined NPC table, use the default one
		LDA.w #DEFAULT+0 : STA !NPC_ID+0	; |
		LDA.w #DEFAULT>>8 : STA !NPC_ID+1	;/

		.TableFound
		STA $01					;\
		LDA.l !NPC_ID+0				; | Set up pointer
		STA $00					;/
		LDA.l !NPC_ID+0				;\
		INC A					; | Increment pointer for next NPC
		STA.l !NPC_ID+0				;/
		SEP #$20				; > A 8-bit
		LDA [$00]				;\ Store ID to sprite table
		STA !ID					;/
		TAY					;\ Set idle frame
		LDA ID_Frame,y : STA !SpriteAnimIndex	;/
		BNE +
		LDA #$10 : STA $32D0,x
		+

		.Main
		LDA $9D
		BNE $03 : JMP PHYSICS
		JMP GRAPHICS



; if return with z = 0, this NPC should run
; if return with z = 1, this NPC should be disabled
	CheckPlayer:
		LDA !MultiPlayer : BEQ .P1
	.P2	LDA !P2Character
		CMP !ExtraProp1,x : BEQ .Return
	.P1	LDA !P2Character-$80
		CMP !ExtraProp1,x
	.Return	RTS


	CheckSwap:
		LDA !ExtraProp2,x
		CMP #$01 : BEQ SwapP1
		CMP #$02 : BEQ SwapP2
		RTS

	SwapP1:
		LDA !ExtraProp1,x				;\
		ASL #4						; |
		STA $00						; |
		LDA !Characters					; | write to main reg
		AND #$0F					; |
		ORA $00						; |
		STA !Characters					;/
		LDA !ExtraProp1,x : STA !Palset8		; reload palset
		LDY #$00
		BRA Unload

	SwapP2:
		LDA !ExtraProp1,x				;\
		AND #$0F					; |
		STA $00						; |
		LDA !Characters					; | write to main reg
		AND #$F0					; |
		ORA $00						; |
		STA !Characters					;/
		LDA !ExtraProp1,x : STA !Palset9		; reload palset
		LDY #$80

	Unload:
		STZ $3230,x					; despawn this sprite

		LDA !ExtraProp1,x : STA !P2Character-$80,y	; write to PCE reg
		LDA #$00 : STA !P2Init-$80,y			; init flag
		LDA #$02 : STA !P2HP-$80,y			; HP
		LDA $3220,x : STA !P2XPosLo-$80,y		;\
		LDA $3250,x : STA !P2XPosHi-$80,y		; | set coords
		LDA $3210,x : STA !P2YPosLo-$80,y		; |
		LDA $3240,x : STA !P2YPosHi-$80,y		;/
		LDA #$00					;\
		STA !P2XSpeed-$80,y				; | clear speeds
		STA !P2YSpeed-$80,y				;/
		LDA $3230,x : STA !P2Direction-$80,y		; dir

		LDA !P2Character-$80 : STA $00
		LDA #$FF : STA $01
		LDA !MultiPlayer : BEQ +
		LDA !P2Character : STA $01
		+

		LDA $00 : BEQ .MarioDone
		LDA $01 : BEQ .MarioDone
		.UnloadMario
		LDA #$00 : STA !GFX_ReznorFireball
		LDA #$01 : STA !P1Dead
		LDA #$09 : STA !MarioAnim
		LDA #$00 : STA !CurrentMario
		.MarioDone
		LDA #$01
		CMP $00 : BEQ .LuigiDone
		CMP $01 : BEQ .LuigiDone
		.UnloadLuigi
		LDA #$00 : STA !GFX_LuigiFireball
		.LuigiDone

		RTS





	DATA:
		.XSpeed
		db $10,$F0
		db $08,$F8

	ID:
		.Frame
		db $00,$07,$13

		.TalkFrame
		db $04,$0F,$1B

		.TalkTime
		db $40,$78,$40

		.TalkStart
		db $01,$00,$01


	PHYSICS:
		LDA $32D0,x
		CMP #$01 : BNE +
		JSL !GetVRAM
		REP #$20
		LDA #$0800 : STA.l !VRAMbase+!VRAMtable+$00,x
		LDA.w #$8008 : STA.l !VRAMbase+!VRAMtable+$02,x
		LDA.w #$3880 : STA.l !VRAMbase+!VRAMtable+$03,x
		LDA #$7000 : STA.l !VRAMbase+!VRAMtable+$05,x
		SEP #$20
		LDX !SpriteIndex
		+

		JSL SUB_HORZ_POS
		TYA
		STA $3320,x

		LDA !TalkTimer					;\
		CMP #$01 : BNE .NoTalk				; |
		LDY !ID						; | End talk animation when timer runs out
		LDA ID_Frame,y : STA !SpriteAnimIndex		; |
		STZ !SpriteAnimTimer				; |
		.NoTalk						;/

		LDA !MsgTrigger					;\ Check if there's a message up right now
		BNE .Msg					;/
		STZ !Talking					; > Stop talking when the message is over
		BRA .NoMsg					; > Then skip talk code

		.Msg
		LDA !Talking : BEQ .NoMsg			; > Check if this NPC is the one talking
		LDA $400000+!MsgTalk : BEQ .NoMsg		;\ Check and clear talk anim flag from MSG
		LDA #$00 : STA $400000+!MsgTalk			;/
		JSR Talk_Anim					; > Trigger talk anim
		.NoMsg


	INTERACTION:
		LDA $3220,x
		SEC : SBC #$20
		STA $04
		LDA $3250,x
		SBC #$00
		STA $0A
		LDA $3210,x
		SEC : SBC #$30
		STA $05
		LDA $3240,x
		SBC #$00
		STA $0B
		LDA #$50 : STA $06
		LDA #$40 : STA $07
		SEC : JSL !PlayerClipping
		BCC .NoTalk
		LSR A : BCC .P2Check
		PHA
		LDA !P2Blocked-$80
		ASL A
		AND $6DA6
		AND #$08
		BEQ .P2
		JSR Talk
	.P2	PLA

		.P2Check
		LSR A : BCC .NoTalk
		LDA !P2Blocked
		ASL A
		AND $6DA7
		AND #$08
		BEQ .NoTalk
		JSR Talk
		.NoTalk




	GRAPHICS:

		.ProcessAnim
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP.w ANIM+2,y
		BNE .SameAnim

		.NewAnim
		LDA ANIM+3,y
		STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA.w ANIM+0,y : STA $04
		LDA.w ANIM+1,y : STA $05

		LDA !ID
		CMP #$01 : BNE .Tilemap

	; tinker code
		LDA !Level+1 : BNE .NoSpecial		; have tinker go down with screen
		LDA !Level
		CMP #$25 : BNE .NoSpecial
		LDA !Level+4 : BEQ .NoSpecial
		LDA $3210,x : PHA
		LDA $3240,x : PHA
		LDA $6DF6
		CLC : ADC $3210,x
		STA $3210,x
		LDA $3240,x
		ADC #$00
		STA $3240,x
		REP #$20
		LDA.w #ANIM_32x32TM : STA $04
		SEP #$20
		JSL LOAD_PSUEDO_DYNAMIC
		PLA : STA $3240,x
		PLA : STA $3210,x
		PLB
		RTL
		.NoSpecial
		REP #$30
		LDA $04 : STA $0C
		LDY.w #!File_NPC_Tinkerer
		JSL !UpdateFromFile
		LDA.w #ANIM_32x32TM : STA $04
		SEP #$30

	; not tinker code
		.Tilemap
		JSL LOAD_PSUEDO_DYNAMIC

		PLB
		RTL


	DEFAULT:
		db $00,$01,$02,$03,$04,$05,$06,$07
		db $08,$09,$0A,$0B,$0C,$0D,$0E,$0F


	Talk:
		LDA #$01 : STA !Talking			; > This NPC is the one talking
		LDY !ID					;\
		TYA					; | Set message
		INC A					; |
		STA !MsgTrigger				;/
		LDA ID_TalkStart,y			;\ Return if talk at start is not set
		BEQ .Return				;/

		.Anim
		LDY !ID					;\
		LDA ID_TalkFrame,y			; |
		STA !SpriteAnimIndex			; | Load animation data based on ID
		STZ !SpriteAnimTimer			; |
		LDA ID_TalkTime,y : STA !TalkTimer	;/

		.Return
		RTS


	ANIM:

	; Survivor's GFX is really small
	; He's not dynamic
		dw .SurvivorIdle0 : db $FF,$01		; 00
		dw .SurvivorIdle1 : db $08,$02		; 01
		dw .SurvivorIdle2 : db $08,$03		; 02
		dw .SurvivorIdle1 : db $08,$00		; 03

		dw .SurvivorTalk0 : db $03,$05		; 04
		dw .SurvivorTalk1 : db $0C,$06		; 05
		dw .SurvivorTalk0 : db $03,$00		; 06

	; Tinkerer's pointers are actually dynamos
	; His tilemap is always the same 32x32
		dw .TinkererIdle0 : db $1D,$08		; 07
		dw .TinkererIdle1 : db $05,$09		; 08
		dw .TinkererIdle2 : db $05,$0A		; 09
		dw .TinkererIdle3 : db $05,$0B		; 0A
		dw .TinkererIdle4 : db $05,$0C		; 0B
		dw .TinkererIdle5 : db $05,$0D		; 0C
		dw .TinkererIdle6 : db $1D,$0E		; 0D
		dw .TinkererIdle1 : db $05,$07		; 0E

		dw .TinkererTalk0 : db $06,$10		; 0F
		dw .TinkererTalk1 : db $06,$11		; 10
		dw .TinkererTalk2 : db $06,$12		; 11
		dw .TinkererTalk3 : db $06,$0F		; 12

	; Melody has a tiny GFX so she gets non-dynamic tilemaps
		dw .MelodyIdle0 : db $08,$14		; 13
		dw .MelodyIdle1 : db $06,$15		; 14
		dw .MelodyIdle0 : db $08,$16		; 15
		dw .MelodyIdle2 : db $06,$13		; 16

		dw .MelodyWalk0 : db $08,$18		; 17
		dw .MelodyWalk1 : db $08,$19		; 18
		dw .MelodyWalk0 : db $08,$1A		; 19
		dw .MelodyWalk2 : db $08,$17		; 1A

		dw .MelodyTalk0 : db $08,$1C		; 1B
		dw .MelodyTalk1 : db $1E,$1D		; 1C
		dw .MelodyTalk0 : db $08,$13		; 1D


	.32x32TM
		dw $0010
		db $3C,$F8,$F0,$00
		db $3C,$08,$F0,$02
		db $3C,$F8,$00,$20
		db $3C,$08,$00,$22

	.SurvivorIdle0
		dw $000C
		db $39,$F8,$F0,$00
		db $39,$F8,$00,$20
		db $39,$00,$00,$21
	.SurvivorIdle1
		dw $0010
		db $39,$F8,$F0,$03
		db $39,$00,$F0,$04
		db $39,$F8,$00,$23
		db $39,$00,$00,$24
	.SurvivorIdle2
		dw $000C
		db $39,$F8,$F0,$06
		db $39,$F8,$00,$26
		db $39,$00,$00,$27
	.SurvivorTalk0
		dw $0010
		db $39,$F7,$F0,$09	; 1px to the left since I moved it in the GFX file
		db $39,$FF,$F0,$0A
		db $39,$F7,$00,$29
		db $39,$FF,$00,$2A
	.SurvivorTalk1
		dw $0010
		db $39,$F0,$F0,$0C
		db $39,$00,$F0,$0E
		db $39,$F0,$00,$2C
		db $39,$00,$00,$2E


macro TinkererDyn(TileCount, SourceTile, DestVRAM)
	dw <TileCount>*$20
	dl <SourceTile>*$20
	dw <DestVRAM>*$10+$6000
endmacro


	.TinkererIdle0
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $000, $000)
		%TinkererDyn(4, $010, $010)
		%TinkererDyn(4, $020, $020)
		%TinkererDyn(4, $030, $030)
		..End
	.TinkererIdle1
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $004, $000)
		%TinkererDyn(4, $014, $010)
		%TinkererDyn(4, $024, $020)
		%TinkererDyn(4, $034, $030)
		..End
	.TinkererIdle2
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $008, $000)
		%TinkererDyn(4, $018, $010)
		%TinkererDyn(4, $028, $020)
		%TinkererDyn(4, $038, $030)
		..End
	.TinkererIdle3
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $00C, $000)
		%TinkererDyn(4, $01C, $010)
		%TinkererDyn(4, $02C, $020)
		%TinkererDyn(4, $03C, $030)
		..End
	.TinkererIdle4
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $040, $000)
		%TinkererDyn(4, $050, $010)
		%TinkererDyn(4, $060, $020)
		%TinkererDyn(4, $070, $030)
		..End
	.TinkererIdle5
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $044, $000)
		%TinkererDyn(4, $054, $010)
		%TinkererDyn(4, $064, $020)
		%TinkererDyn(4, $074, $030)
		..End
	.TinkererIdle6
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $048, $000)
		%TinkererDyn(4, $058, $010)
		%TinkererDyn(4, $068, $020)
		%TinkererDyn(4, $078, $030)
		..End
	.TinkererTalk0
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $04C, $000)
		%TinkererDyn(4, $05C, $010)
		%TinkererDyn(4, $06C, $020)
		%TinkererDyn(4, $07C, $030)
		..End
	.TinkererTalk1
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $080, $000)
		%TinkererDyn(4, $090, $010)
		%TinkererDyn(4, $0A0, $020)
		%TinkererDyn(4, $0B0, $030)
		..End
	.TinkererTalk2
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $084, $000)
		%TinkererDyn(4, $094, $010)
		%TinkererDyn(4, $0A4, $020)
		%TinkererDyn(4, $0B4, $030)
		..End
	.TinkererTalk3
		dw ..End-..Start
		..Start
		%TinkererDyn(4, $088, $000)
		%TinkererDyn(4, $098, $010)
		%TinkererDyn(4, $0A8, $020)
		%TinkererDyn(4, $0B8, $030)
		..End


	.MelodyIdle0
		dw $0008
		db $38,$00,$F8,$00
		db $38,$00,$00,$10
	.MelodyIdle1
		dw $0008
		db $38,$00,$F8,$02
		db $38,$00,$00,$12
	.MelodyIdle2
		dw $0008
		db $38,$00,$F8,$04
		db $38,$00,$00,$14
	.MelodyWalk0
		dw $0008
		db $38,$00,$F8,$06
		db $38,$00,$00,$16
	.MelodyWalk1
		dw $0008
		db $38,$00,$F8,$08
		db $38,$00,$00,$18
	.MelodyWalk2
		dw $0008
		db $38,$00,$F8,$0A
		db $38,$00,$00,$1A
	.MelodyTalk0
		dw $0008
		db $38,$00,$F8,$0C
		db $38,$00,$00,$1C
	.MelodyTalk1
		dw $0008
		db $38,$00,$F8,$0E
		db $38,$00,$00,$1E




	namespace off





