

NPC:

	namespace NPC

		;!TalkAnim	=	$BE		; which anim will be started when the NPC starts talking (0 = no anim change)
		!PrevAnim	=	$3280
		!ToadCarry	=	$3290
		!Talking	=	$32A0		; 0 = this NPC is not currently talking, 1 = this NPC is currently talking
		!TalkTimer	=	$32D0

		!SwapWaitTimer	=	$32F0
		!SparkleTimer	=	$3300


		!TalkAnim1	=	$3500		; triggers once, then eats flag
		!TalkAnim2	=	$3510		; triggers once, then sets highest bit in talk flag to know it has been triggered
		!TalkAnim3	=	$3520		; default reaction animation, plays once when NPC is talked to
		!TalkAnim4	=	$3530		; default talking animation, lowest priority




; extra prop 1: which NPC this is (see list)
; extra prop 2: behavior/command to execute, can be sent by other sprites, players, or level code (or set internally)




; how to feed MSG entries to NPCs?
; approach 1: commands in MSG (no, either way too many mostly duplicate MSG entries or too many cycles spent looping over NPC_Talk)
; approach 2: set by level code (this is done already for the base table but requires clunky codes to update tables)
; approach 3: default is always to increment 1 after each talk, but each NPC_Talk entry also has a "cap" entry that it won't go past (is this the best one?)





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
;	10 - toad 1
;	11 - toad 2
;	12 - toad 3
;	13 - toad 4
;	14 - toad 5
;	15 - toad 7
;	16 - toad 6
;	17 - toad 8
;	18 - reserved for captain toad
;	19 - melody
;
;



	INIT:
		PHB : PHK : PLB
		LDA #$FF : STA !PrevAnim,x
		LDA !ExtraProp1,x
		ASL A
		CMP.b #.InitPtr_end-.InitPtr : BCS .Return
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
		dw .Tinkerer		; 07
		dw .RallyYoshi		; 08
		dw .BigYoshi		; 09
		dw .PainterYoshi	; 0A
		dw .OldYoshi		; 0B
		dw .Unused		; 0C (reserved for yoshi)
		dw .Unused		; 0D (reserved for yoshi)
		dw .Unused		; 0E (reserved for yoshi)
		dw .Unused		; 0F (reserved for yoshi)
		dw .Toad		; 10 (toad 1)
		dw .Toad		; 11 (toad 2)
		dw .Toad		; 12 (toad 3)
		dw .Toad		; 13 (toad 4)
		dw .Toad		; 14 (toad 5)
		dw .Toad		; 15 (toad 6)
		dw .Toad		; 16 (toad 7)
		dw .Toad		; 17 (toad 8)
		dw .Unused		; 18 (reserved for captain toad)
		dw .Melody		; 19
		..end


		.Mario
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_mario
		BRA .FinishPalset

		.Luigi
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_luigi
		BRA .FinishPalset

		.Kadaal
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_kadaal
		BRA .FinishPalset

		.Leeway
		LDX !SpriteIndex
		LDA #$04 : JSL GET_SQUARE
		LDA.b #!palset_leeway
		BRA .FinishPalset

		.Alter
		LDX !SpriteIndex
		RTS

		.Peach
		LDX !SpriteIndex
		RTS

		.FinishPalset
		JSL LoadPalset
		LDX $0F
		LDA !Palset_status,x
		ASL A
		LDX !SpriteIndex
		STA $33C0,x
		RTS

		.Survivor
		LDX !SpriteIndex
		LDA #$03 : JSL GET_SQUARE
		LDA #$08 : STA $33C0,x
		LDA #$04
		STA !TalkAnim1,x
		STA !TalkAnim2,x
		RTS

		.Tinkerer
		LDX !SpriteIndex
		LDA #$03 : JSL GET_SQUARE
		LDA #$0A : STA $33C0,x
		LDA #$08
		STA !TalkAnim1,x
		STA !TalkAnim2,x
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
		LDA #$03 : JSL GET_SQUARE
		LDA #$06 : STA $33C0,x
		RTS

		.Toad
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_special_toad
		BRA .FinishPalset

		.Melody
		LDX !SpriteIndex
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_special_melody
		BRA .FinishPalset


		.Unused
		LDX !SpriteIndex
		RTS



	MAIN:
		PHB : PHK : PLB
		LDA !GameMode
		CMP #$14 : BEQ .Process
		.Fail
		PLB
		RTL

		.Process
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BNE ..windowopen

		..cantalk
		STZ !Talking,x					; no one is currently talking
		LDA !TalkTimer,x
		CMP #$01 : BEQ ..starttalk
		JMP ..talkdone

		..starttalk					;\
		REP #$30					; |
		LDA !ExtraProp1,x				; |
		AND #$00FF					; | get MSG value
		ASL A						; |
		TAX						; |
		LDA !NPC_Talk,x : STA !MsgTrigger		; |
		BPL ..global					;/
		..level						;\
		CMP !NPC_TalkCap,x : BCS ..noincrement		; | check for level message increment
		BRA ..increment					;/
		..global					;\
		STA $00						; |
		LDA !NPC_TalkCap,x : BMI ..noincrement		; | check for global message increment
		LDA $00						; |
		CMP !NPC_TalkCap,x : BCS ..noincrement		;/
		..increment					;\
		INC A						; | increment message
		STA !NPC_Talk,x					; |
		..noincrement					;/

		SEP #$30					;\ restore regs
		LDX !SpriteIndex				;/
		LDA #$01 : STA !Talking,x			; this NPC is currently talking
		..talkanim3					;\
		LDA #$00 : STA $400000+!MsgTalk			; | go into talk start animation
		LDA !TalkAnim3,x : BEQ ..talkdone		; | (eats flag)
		BRA ..setanim					;/
		..windowopen					;\
		LDA !Talking,x : BEQ ..talkdone			; |
		LDA $400000+!MsgTalk : BEQ ..talkdone		; |
		CMP #$01 : BEQ ..talkanim1			; | check for talk flags
		CMP #$02 : BEQ ..talkanim2			; |
		CMP #$03 : BEQ ..talkanim3			; |
		CMP #$04 : BNE ..talkdone			;/
		..talkanim4					;\
		LDA #$00 : STA $400000+!MsgTalk			; | go into looping talk animation
		LDA !TalkAnim4,x : BEQ ..talkdone		; | (eats flag)
		BRA ..setanim					;/
		..talkanim2					;\
		ORA #$80 : STA $400000+!MsgTalk			; | go into special reaction animation
		LDA !TalkAnim2,x : BEQ ..talkdone		; | (sets highest bit of flag)
		BRA ..setanim					;/
		..talkanim1					;\
		LDA #$00 : STA $400000+!MsgTalk			; | go into normal reaction animation
		LDA !TalkAnim1,x : BEQ ..talkdone		;/ (eats flag)
		..setanim					;\
		STA !SpriteAnimIndex				; | set anim reg
		STZ !SpriteAnimTimer				; |
		..talkdone					;/


		LDY #$00
		LDA !P2Character-$80,y
		CMP #$03 : BEQ ..leewaypose
		LDY #$80
		LDA !P2Character-$80,y
		CMP #$03 : BNE ..noleeway
		..leewaypose
		LDA !P2ExternalAnimTimer-$80,y
		CMP #$18 : BCS ..noleeway
		LDA #!Lee_Victory+1 : STA !P2ExternalAnim-$80,y
		..noleeway


		LDA !SparkleTimer,x
		AND #$01 : BEQ ..nosparkle
		LDA !RNG
		AND #$0F
		ASL A
		SBC #$0C
		STA $00
		LDA #$08 : STA $01
		STZ $02
		LDA #$F0 : STA $03
		STZ $04
		LDA #$E8 : STA $05
		LDA !RNG
		LSR #4
		STA $06
		LDA.b #!prt_sparkle : JSL SpawnParticle
		..nosparkle


		JSR CheckPlayer : BEQ .BadCharacter

		LDA !ExtraProp2,x
		AND #$3F
		CMP #$3E							;\ 0x3E -> swap p1
		BNE $02 : LDA.b #((.CommandPtr_end-.CommandPtr)/2)-2		;/
		CMP #$3F							;\ 0x3F -> swap p2
		BNE $02 : LDA.b #((.CommandPtr_end-.CommandPtr)/2)-1		;/
		ASL A
		CMP.b #.CommandPtr_end-.CommandPtr : BCS .BadCommand
		TAX
		JSR (.CommandPtr,x)
		JSL !SpriteApplySpeed
		.BadCommand

		LDA !ExtraProp1,x
		ASL A
		CMP.b #.MainPtr_end-.MainPtr : BCS .BadCharacter
		TAX
		JSR (.MainPtr,x)
		.BadCharacter

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
		dw Tinkerer		; 07
		dw RallyYoshi		; 08
		dw BigYoshi		; 09
		dw PainterYoshi		; 0A
		dw OldYoshi		; 0B
		dw Unused		; 0C (reserved for yoshi)
		dw Unused		; 0D (reserved for yoshi)
		dw Unused		; 0E (reserved for yoshi)
		dw Unused		; 0F (reserved for yoshi)
		dw Toad			; 10 (toad 1)
		dw Toad			; 11 (toad 2)
		dw Toad			; 12 (toad 3)
		dw Toad			; 13 (toad 4)
		dw Toad			; 14 (toad 5)
		dw Toad			; 15 (toad 6)
		dw Toad			; 16 (toad 7)
		dw Toad			; 17 (toad 8)
		dw Unused		; 18 (reserved for captain toad)
		dw Melody		; 19
		..end


		.CommandPtr
		dw FacePlayer		; 00
		dw Talkable		; 01
		dw TalkableSwap		; 02
		dw Follow		; 03
		dw FollowTalkable	; 04
		dw Guard		; 05
		dw IntroGuard		; 06
		dw SwapP1		; last-1
		dw SwapP2		; last
		..end




	Mario:
		LDX !SpriteIndex
		REP #$30
		LDY.w #!File_Mario
		LDA.w #.IdleDyn : STA $0C
		JSL LOAD_SQUARE_DYNAMO
		LDA.w #Tilemap_16x32 : STA $04
		SEP #$30
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS

		.IdleDyn
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($020)
		..end


	Luigi:
		LDX !SpriteIndex				; X = sprite index
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
		dw ..end-..start
		..start
		%SquareDyn($22A)
		%SquareDyn($22C)
		..end



	Kadaal:
		LDX !SpriteIndex				; X = sprite index
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
		dw .Idle00 : db $06,$01
		dw .Idle01 : db $06,$02
		dw .Idle02 : db $06,$03
		dw .Idle03 : db $06,$00


		.Idle00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($020)
		..end
		.Idle01
		dw ..end-..start
		..start
		%SquareDyn($002)
		%SquareDyn($022)
		..end
		.Idle02
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($024)
		..end
		.Idle03
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($026)
		..end





	Leeway:
		LDX !SpriteIndex				; X = sprite index
		LDA !SpriteAnimIndex				;\
		ASL #2						; |
		TAY						; | process anim timer
		LDA !SpriteAnimTimer				; |
		INC A						; |
		CMP .AnimTable+2,y : BNE +			;/
		LDA .AnimTable+3,y : STA !SpriteAnimIndex	;\
		REP #$30					; |
		LDA .AnimTable+0,y : STA $0C			; |
		LDY.w #!File_Leeway				; | process dynamic tiles
		JSL LOAD_SQUARE_DYNAMO				; |
		SEP #$30					; |
		LDA #$00					;/
	+	STA !SpriteAnimTimer				; update anim timer
		REP #$20					;\
		LDA.w #Tilemap_Leeway : STA $04			; |	
		SEP #$20					; | draw to OAM
		JSL SETUP_SQUARE				; |
		JSL LOAD_DYNAMIC				;/
		RTS

		.AnimTable
		dw .Idle00 : db $08,$01
		dw .Idle01 : db $08,$02
		dw .Idle02 : db $08,$00


		.Idle00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($020)
		%SquareDyn($021)
		%SquareFile(!File_Leeway_Sword)
		%SquareDyn($008)
		%SquareDyn($009)
		..end
		.Idle01
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($023)
		%SquareDyn($024)
		%SquareFile(!File_Leeway_Sword)
		%SquareDyn($008)
		%SquareDyn($009)
		..end
		.Idle02
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($026)
		%SquareDyn($027)
		%SquareFile(!File_Leeway_Sword)
		%SquareDyn($008)
		%SquareDyn($009)
		..end


	Alter:
		LDX !SpriteIndex
		RTS

	Peach:
		LDX !SpriteIndex
		RTS


	Survivor:
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		ASL A
		ADC !SpriteAnimIndex
		ASL A
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .AnimTable+4,y : BNE .SameAnim

		.NewAnim
		LDA .AnimTable+5,y : STA !SpriteAnimIndex
		ASL A
		ADC !SpriteAnimIndex
		ASL A
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA .AnimTable+0,y : STA $04
		LDA .AnimTable+2,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !PrevAnim,x : BEQ ..skipupload
		LDY.b #!File_NPC_Survivor : JSL LOAD_SQUARE_DYNAMO
		..skipupload
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS


		.AnimTable
		dw Tilemap_24x32,.Idle00 : db $80,$01		; 00
		dw Tilemap_24x32,.Idle01 : db $08,$02		; 01
		dw Tilemap_24x32,.Idle02 : db $10,$03		; 02
		dw Tilemap_24x32,.Idle01 : db $08,$00		; 03

		dw Tilemap_24x32,.Bow00 : db $08,$05		; 04
		dw Tilemap_32x32forward,.Bow01 : db $10,$06	; 05
		dw Tilemap_24x32,.Bow00 : db $08,$00		; 06


		.Idle00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($001)
		%SquareDyn($020)
		%SquareDyn($021)
		..end
		.Idle01
		dw ..end-..start
		..start
		%SquareDyn($003)
		%SquareDyn($004)
		%SquareDyn($023)
		%SquareDyn($024)
		..end
		.Idle02
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($007)
		%SquareDyn($026)
		%SquareDyn($027)
		..end

		.Bow00
		dw ..end-..start
		..start
		%SquareDyn($009)
		%SquareDyn($00A)
		%SquareDyn($029)
		%SquareDyn($02A)
		..end
		.Bow01
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($00E)
		%SquareDyn($02C)
		%SquareDyn($02E)
		..end




	Tinkerer:
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .AnimTable+2,y : BNE .SameAnim

		.NewAnim
		LDA .AnimTable+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w #Tilemap_32x32 : STA $04
		LDA .AnimTable+0,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !PrevAnim,x : BEQ ..skipupload
		LDY.b #!File_NPC_Tinkerer : JSL LOAD_SQUARE_DYNAMO
		..skipupload
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS



		.AnimTable
		dw .Idle00 : db $1D,$01		; 00
		dw .Idle01 : db $05,$02		; 01
		dw .Idle02 : db $05,$03		; 02
		dw .Idle03 : db $05,$04		; 03
		dw .Idle04 : db $05,$05		; 04
		dw .Idle05 : db $05,$06		; 05
		dw .Idle06 : db $1D,$07		; 06
		dw .Idle01 : db $05,$00		; 07

		dw .Laugh00 : db $06,$09	; 08
		dw .Laugh01 : db $06,$0A	; 09
		dw .Laugh02 : db $06,$0B	; 0A
		dw .Laugh03 : db $06,$08	; 0B



		.Idle00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($002)
		%SquareDyn($020)
		%SquareDyn($022)
		..end
		.Idle01
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($006)
		%SquareDyn($024)
		%SquareDyn($026)
		..end
		.Idle02
		dw ..end-..start
		..start
		%SquareDyn($008)
		%SquareDyn($00A)
		%SquareDyn($028)
		%SquareDyn($02A)
		..end
		.Idle03
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($00E)
		%SquareDyn($02C)
		%SquareDyn($02E)
		..end
		.Idle04
		dw ..end-..start
		..start
		%SquareDyn($040)
		%SquareDyn($042)
		%SquareDyn($060)
		%SquareDyn($062)
		..end
		.Idle05
		dw ..end-..start
		..start
		%SquareDyn($044)
		%SquareDyn($046)
		%SquareDyn($064)
		%SquareDyn($066)
		..end
		.Idle06
		dw ..end-..start
		..start
		%SquareDyn($048)
		%SquareDyn($04A)
		%SquareDyn($068)
		%SquareDyn($06A)
		..end

		.Laugh00
		dw ..end-..start
		..start
		%SquareDyn($04C)
		%SquareDyn($04E)
		%SquareDyn($06C)
		%SquareDyn($06E)
		..end
		.Laugh01
		dw ..end-..start
		..start
		%SquareDyn($080)
		%SquareDyn($082)
		%SquareDyn($0A0)
		%SquareDyn($0A2)
		..end
		.Laugh02
		dw ..end-..start
		..start
		%SquareDyn($084)
		%SquareDyn($086)
		%SquareDyn($0A4)
		%SquareDyn($0A6)
		..end
		.Laugh03
		dw ..end-..start
		..start
		%SquareDyn($088)
		%SquareDyn($08A)
		%SquareDyn($0A8)
		%SquareDyn($0AA)
		..end




	RallyYoshi:
		LDX !SpriteIndex
		RTS

	BigYoshi:
		LDX !SpriteIndex
		RTS

	PainterYoshi:
		LDX !SpriteIndex
		RTS



	!Temp = 0
	%def_anim(OldYoshi_Idle, 4)
	%def_anim(OldYoshi_Walk, 4)
	%def_anim(OldYoshi_Shock, 6)
	%def_anim(OldYoshi_Talk, 2)


	OldYoshi:
		LDX !SpriteIndex
		LDA #!OldYoshi_Shock
		STA !TalkAnim1,x
		STA !TalkAnim2,x
		LDA #!OldYoshi_Talk : STA !TalkAnim4,x

	.Movement
		LDA !SpriteAnimIndex
		CMP #!OldYoshi_Shock : BCC ..walkdone

		..nowalk
		LDA !SpriteXSpeed,x
		EOR #$FF : INC A
		STA !SpriteVectorX,x
		LDA #$01 : STA !SpriteVectorTimerX,x
		STZ !SpriteVectorAccX,x
		..walkdone

	.Animation
		LDY !SpriteAnimIndex

		LDA !Talking,x : BEQ ..notalk
		CPY #!OldYoshi_Shock+3 : BNE ..nopop
		LDA $400000+!MsgTalk : BPL ..nopop
		DEC !SpriteAnimTimer
		..nopop

		CPY #!OldYoshi_Shock : BCC +		; yes, shock
		CPY #!OldYoshi_Talk_over : BCC ..done
	+	LDA #!OldYoshi_Talk : BRA ..setanim
		..notalk

		CPY #!OldYoshi_Shock : BCC ..normal
		CPY #!OldYoshi_Shock_over : BCC ..done


	; walk/idle animation
		..normal
		LDA !SpriteXSpeed,x : BEQ ..idle
		..walk
		CLC : ADC #$11
		CMP #$22 : BCS +
		LDA $14
		LSR A : BCC +
		DEC !SpriteAnimTimer
	+	CPY #!OldYoshi_Walk : BCC +
		CPY #!OldYoshi_Walk_over : BCC ..done
	+	LDA #!OldYoshi_Walk : BRA ..setanim
		..idle
		CPY #!OldYoshi_Idle_over : BCC ..done
		LDA #!OldYoshi_Idle
		..setanim
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..done

	.Graphics
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .AnimTable+2,y : BNE .SameAnim

		.NewAnim
		LDA .AnimTable+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w #Tilemap_32x32 : STA $04
		LDA .AnimTable+0,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !PrevAnim,x : BEQ ..skipupload
		LDY.b #!File_NPC_OldYoshi : JSL LOAD_SQUARE_DYNAMO
		..skipupload
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS


		.AnimTable
		dw .IdleDyn00 : db $C8,!OldYoshi_Idle+1
		dw .IdleDyn01 : db $0C,!OldYoshi_Idle+2
		dw .IdleDyn02 : db $28,!OldYoshi_Idle+3
		dw .IdleDyn01 : db $0C,!OldYoshi_Idle+0

		dw .WalkDyn00 : db $05,!OldYoshi_Walk+1
		dw .WalkDyn01 : db $05,!OldYoshi_Walk+2
		dw .WalkDyn00 : db $05,!OldYoshi_Walk+3
		dw .WalkDyn02 : db $05,!OldYoshi_Walk+0

		dw .ShockDyn00 : db $0C,!OldYoshi_Shock+1
		dw .ShockDyn01 : db $0C,!OldYoshi_Shock+2
		dw .ShockDyn02 : db $04,!OldYoshi_Shock+3
		dw .ShockDyn03 : db $28,!OldYoshi_Shock+4
		dw .ShockDyn01 : db $0C,!OldYoshi_Shock+5
		dw .ShockDyn00 : db $0C,!OldYoshi_Idle

		dw .TalkDyn00 : db $0C,!OldYoshi_Talk+1
		dw .TalkDyn01 : db $0C,!OldYoshi_Talk+0



		.TalkDyn00
		.WalkDyn00
		.IdleDyn00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($002)
		%SquareDyn($020)
		%SquareDyn($022)
		..end
		.ShockDyn00
		.IdleDyn01
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($00E)
		%SquareDyn($02C)
		%SquareDyn($02E)
		..end
		.ShockDyn01
		.IdleDyn02
		dw ..end-..start
		..start
		%SquareDyn($040)
		%SquareDyn($042)
		%SquareDyn($04C)
		%SquareDyn($04E)
		..end

		.WalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($006)
		%SquareDyn($024)
		%SquareDyn($026)
		..end
		.WalkDyn02
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($006)
		%SquareDyn($028)
		%SquareDyn($02A)
		..end

		.ShockDyn02
		dw ..end-..start
		..start
		%SquareDyn($044)
		%SquareDyn($046)
		%SquareDyn($04C)
		%SquareDyn($04E)
		..end
		.ShockDyn03
		dw ..end-..start
		..start
		%SquareDyn($048)
		%SquareDyn($04A)
		%SquareDyn($04C)
		%SquareDyn($04E)
		..end

		.TalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($008)
		%SquareDyn($002)
		%SquareDyn($00A)
		%SquareDyn($022)
		..end



	!Temp = 0
	%def_anim(Toad_Idle, 1)
	%def_anim(Toad_Walk, 4)
	%def_anim(Toad_Jump, 1)
	%def_anim(Toad_Pull, 1)
	%def_anim(Toad_IdleCarry, 1)
	%def_anim(Toad_WalkCarry, 4)
	%def_anim(Toad_JumpCarry, 1)
	%def_anim(Toad_Throw, 1)
	%def_anim(Toad_Bow, 2)
	%def_anim(Toad_Cheer, 3)
	%def_anim(Toad_Cower, 1)
	%def_anim(Toad_Yell, 4)
	%def_anim(Toad_Dead, 1)



	Toad:
		LDX !SpriteIndex
		LDA #!Toad_Yell
		STA !TalkAnim1,x
		STA !TalkAnim3,x
		LDA #!Toad_Cheer : STA !TalkAnim2,x
		LDA #!Toad_Bow : STA !TalkAnim4,x

	.Movement
		LDY !SpriteAnimIndex
		CPY #!Toad_Pull : BEQ ..nowalk
		CPY #!Toad_Throw : BCC ..walkdone
		..nowalk
		LDA !SpriteXSpeed,x
		EOR #$FF : INC A
		STA !SpriteVectorX,x
		LDA #$01 : STA !SpriteVectorTimerX,x
		STZ !SpriteVectorAccX,x
		..walkdone
		LDA $3330,x
		AND #$04 : BEQ ..done
		CPY #!Toad_Yell+2 : BEQ ..resetanim
		CPY #!Toad_Cheer+1 : BNE ..done
		..resetanim
		INC !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..done

	.Animation
		LDA !Talking,x : BEQ ..notalk
		CPY #!Toad_Throw : BCC ..processtalk
		CPY #!Toad_Cower : BCS ..done

		..processtalk
		LDA $400000+!MsgTalk : BMI ..done
		CPY #!Toad_Cower : BCS ..done
		CPY #!Toad_Bow : BCC +
		CPY #!Toad_Bow_over : BCC ..done
	+	LDA #!Toad_Bow : BRA ..setanim
		..notalk

		LDA $3330,x
		AND #$04 : BNE ..ground
		LDA #!Toad_Jump : BRA ..setanim

		..ground
		LDA #$10 : STA !SpriteYSpeed,x
		LDA !SpriteXSpeed,x : BEQ ..idle
		..walk
		CLC : ADC #$11
		CMP #$22 : BCS +
		LDA $14
		LSR A : BCC +
		DEC !SpriteAnimTimer
	+	CPY #!Toad_Walk : BCC +
		CPY #!Toad_Walk_over : BCC ..done
	+	LDA #!Toad_Walk : BRA ..setanim
		..idle
		LDA #!Toad_Idle
		..setanim
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..done

	.Graphics
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .AnimTable+2,y : BNE .SameAnim

		.NewAnim
		LDA .AnimTable+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY

		CMP.b #(!Toad_Yell+2)*4 : BEQ ..jump
		CMP.b #(!Toad_Cheer+1)*4 : BNE ..nojump
		..jump
		LDA #$E0 : STA !SpriteYSpeed,x
		..nojump
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		LDA !SpriteAnimIndex
		CMP #!Toad_Throw : BCS ..nocarry
		LDA !ToadCarry,x : BEQ ..nocarry
		TYA
		CLC : ADC.b #((!Toad_IdleCarry)-(!Toad_Idle))*4
		TAY
		..nocarry

		REP #$20
		LDA.w #Tilemap_16x32 : STA $04
		LDA .AnimTable+0,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !PrevAnim,x : BEQ ..skipupload
		LDY.b #!File_NPC_Toad : JSL LOAD_SQUARE_DYNAMO
		..skipupload
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS


		.AnimTable
		; idle
		dw .IdleDyn : db $FF,!Toad_Idle
		; walk
		dw .WalkDyn00 : db $05,!Toad_Walk+1
		dw .WalkDyn01 : db $05,!Toad_Walk+2
		dw .WalkDyn00 : db $05,!Toad_Walk+3
		dw .WalkDyn02 : db $05,!Toad_Walk+0
		; jump
		dw .JumpDyn : db $FF,!Toad_Jump
		; pull
		dw .PullDyn : db $FF,!Toad_Pull
		; idle carry
		dw .IdleCarryDyn : db $FF,!Toad_Idle
		; walk carry
		dw .WalkCarryDyn00 : db $05,!Toad_Walk+1
		dw .WalkCarryDyn01 : db $05,!Toad_Walk+2
		dw .WalkCarryDyn00 : db $05,!Toad_Walk+3
		dw .WalkCarryDyn02 : db $05,!Toad_Walk+0
		; jump carry
		dw .JumpCarryDyn : db $FF,!Toad_Jump
		; throw
		dw .ThrowDyn : db $08,!Toad_Idle
		; bow
		dw .BowDyn00 : db $07,!Toad_Bow+1
		dw .BowDyn01 : db $07,!Toad_Bow+0
		; cheer
		dw .CheerDyn00 : db $07,!Toad_Cheer+1
		dw .CheerDyn01 : db $FF,!Toad_Cheer+1
		dw .CheerDyn00 : db $07,!Toad_Cheer+0
		; cower
		dw .CowerDyn : db $FF,!Toad_Cower
		; yell
		dw .YellDyn00 : db $07,!Toad_Yell+1
		dw .YellDyn01 : db $07,!Toad_Yell+2
		dw .YellDyn02 : db $FF,!Toad_Yell+2
		dw .YellDyn00 : db $07,!Toad_Idle
		; dead
		dw .DeadDyn : db $FF,!Toad_Dead


		.IdleDyn
		.WalkDyn00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($020)
		..end
		.WalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($002)
		%SquareDyn($022)
		..end
		.JumpDyn
		.WalkDyn02
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($024)
		..end

		.PullDyn
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($026)
		..end

		.IdleCarryDyn
		.WalkCarryDyn00
		dw ..end-..start
		..start
		%SquareDyn($040)
		%SquareDyn($060)
		..end
		.WalkCarryDyn01
		dw ..end-..start
		..start
		%SquareDyn($042)
		%SquareDyn($062)
		..end
		.JumpCarryDyn
		.WalkCarryDyn02
		dw ..end-..start
		..start
		%SquareDyn($044)
		%SquareDyn($064)
		..end

		.ThrowDyn
		dw ..end-..start
		..start
		%SquareDyn($046)
		%SquareDyn($066)
		..end

		.CowerDyn
		.YellDyn00
		dw ..end-..start
		..start
		%SquareDyn($008)
		%SquareDyn($028)
		..end
		.YellDyn01
		dw ..end-..start
		..start
		%SquareDyn($00A)
		%SquareDyn($02A)
		..end
		.YellDyn02
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($02C)
		..end

		.CheerDyn00
		dw ..end-..start
		..start
		%SquareDyn($048)
		%SquareDyn($068)
		..end
		.CheerDyn01
		dw ..end-..start
		..start
		%SquareDyn($04A)
		%SquareDyn($06A)
		..end

		.BowDyn00
		dw ..end-..start
		..start
		%SquareDyn($04C)
		%SquareDyn($06C)
		..end
		.BowDyn01
		dw ..end-..start
		..start
		%SquareDyn($04E)
		%SquareDyn($06E)
		..end

		.DeadDyn
		dw ..end-..start
		..start
		%SquareDyn($00E)
		%SquareDyn($02E)
		..end





	!Temp = 0
	%def_anim(Melody_Idle, 4)
	%def_anim(Melody_Walk, 4)
	%def_anim(Melody_Talk, 3)

	Melody:
		LDX !SpriteIndex
		LDA #!Melody_Talk
		STA !TalkAnim1,x
		STA !TalkAnim2,x

	.Movement
		LDA !SpriteAnimIndex
		CMP #!Melody_Talk : BCC ..walkdone

		..nowalk
		LDA !SpriteXSpeed,x
		EOR #$FF : INC A
		STA !SpriteVectorX,x
		LDA #$01 : STA !SpriteVectorTimerX,x
		STZ !SpriteVectorAccX,x
		..walkdone

	.Animation
		LDA !SpriteAnimIndex
		CMP #!Melody_Talk : BCS ..done
		LDA #$10 : STA !SpriteYSpeed,x
		LDA !SpriteXSpeed,x : BEQ ..idle
		..walk
		CLC : ADC #$11
		CMP #$22 : BCS +
		LDA $14
		LSR A : BCC +
		DEC !SpriteAnimTimer
	+	LDA !SpriteAnimIndex
		CMP #!Melody_Walk : BCC +
		CMP #!Melody_Walk_over : BCC ..done
	+	LDA #!Melody_Walk : BRA ..setanim
		..idle
		LDA !SpriteAnimIndex
		CMP #!Melody_Idle_over : BCC ..done
		LDA #!Melody_Idle
		..setanim
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..done

	.Graphics
		LDX !SpriteIndex
		LDA !SpriteAnimIndex
		ASL #2
		TAY
		LDA !SpriteAnimTimer
		INC A
		CMP .AnimTable+2,y : BNE .SameAnim

		.NewAnim
		LDA .AnimTable+3,y : STA !SpriteAnimIndex
		ASL #2
		TAY
		LDA #$00

		.SameAnim
		STA !SpriteAnimTimer
		REP #$20
		LDA.w #Tilemap_16x24 : STA $04
		LDA .AnimTable+0,y : STA $0C
		SEP #$20
		LDA !SpriteAnimIndex
		CMP !PrevAnim,x : BEQ ..skipupload
		LDY.b #!File_NPC_Melody : JSL LOAD_SQUARE_DYNAMO
		..skipupload
		JSL SETUP_SQUARE
		JSL LOAD_DYNAMIC
		RTS


		.AnimTable
		dw .IdleDyn00 : db $0C,!Melody_Idle+1
		dw .IdleDyn01 : db $18,!Melody_Idle+2
		dw .IdleDyn00 : db $0C,!Melody_Idle+3
		dw .IdleDyn02 : db $18,!Melody_Idle+0

		dw .WalkDyn00 : db $05,!Melody_Walk+1
		dw .WalkDyn01 : db $05,!Melody_Walk+2
		dw .WalkDyn00 : db $05,!Melody_Walk+3
		dw .WalkDyn02 : db $05,!Melody_Walk+0

		dw .TalkDyn00 : db $08,!Melody_Talk+1
		dw .TalkDyn01 : db $20,!Melody_Talk+2
		dw .TalkDyn00 : db $08,!Melody_Idle


		.IdleDyn00
		dw ..end-..start
		..start
		%SquareDyn($000)
		%SquareDyn($010)
		..end
		.IdleDyn01
		dw ..end-..start
		..start
		%SquareDyn($002)
		%SquareDyn($012)
		..end
		.IdleDyn02
		dw ..end-..start
		..start
		%SquareDyn($004)
		%SquareDyn($014)
		..end

		.WalkDyn00
		dw ..end-..start
		..start
		%SquareDyn($006)
		%SquareDyn($016)
		..end
		.WalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($008)
		%SquareDyn($018)
		..end
		.WalkDyn02
		dw ..end-..start
		..start
		%SquareDyn($00A)
		%SquareDyn($01A)
		..end

		.TalkDyn00
		dw ..end-..start
		..start
		%SquareDyn($00C)
		%SquareDyn($01C)
		..end
		.TalkDyn01
		dw ..end-..start
		..start
		%SquareDyn($00E)
		%SquareDyn($01E)
		..end






	Unused:
		LDX !SpriteIndex
		RTS



	Tilemap:
		.16x24
		dw $0008
		db $3E,$00,$F8,$00
		db $3E,$00,$00,$01

		.16x32
		dw $0008
		db $3E,$00,$F0,$00
		db $3E,$00,$00,$01

		.32x16
		dw $0008
		db $3E,$F8,$00,$00
		db $3E,$08,$00,$01

		.24x32
		dw $0010
		db $3E,$FC,$F0,$00
		db $3E,$04,$F0,$01
		db $3E,$FC,$00,$02
		db $3E,$04,$00,$03

		.32x32forward
		dw $0010
		db $3E,$F4,$F0,$00
		db $3E,$04,$F0,$01
		db $3E,$F4,$00,$02
		db $3E,$04,$00,$03

		.32x32
		dw $0010
		db $3E,$F8,$F0,$00
		db $3E,$08,$F0,$01
		db $3E,$F8,$00,$02
		db $3E,$08,$00,$03

		.Leeway
		dw $0014
		db $3E,$F1,$08,$03
		db $3E,$F9,$08,$04
		db $3E,$FC,$F0,$00
		db $3E,$FC,$00,$01
		db $3E,$04,$00,$02


	DATA:
		.XSpeed
		db $10,$F0

		.Talkbox
		dw $FFE8,$0000 : db $30,$10

		.FollowBox
		dw $FFE0,$FFE0 : db $40,$30

		.VictoryPose
		db $26,!Lui_Victory,!Kad_Victory,!Lee_Victory,$00,$00





; if return with z = 0, this NPC should run
; if return with z = 1, this NPC should be disabled
	CheckPlayer:
		LDA !ExtraProp1,x
		CMP #$06 : BCS .Return

		ASL #2
		ADC !ExtraProp1,x
		ASL A
		TAX
		LDA !CharacterData,x : BNE .Unlocked
		LDX !SpriteIndex
		LDA #$00
		RTS

		.Unlocked
		LDX !SpriteIndex
		LDA !MultiPlayer : BEQ .P1
	.P2	LDA !P2Character
		CMP !ExtraProp1,x : BEQ .Return
	.P1	LDA !P2Character-$80
		CMP !ExtraProp1,x
	.Return	RTS




	FacePlayer:
		LDX !SpriteIndex
		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		RTS


	Talkable:
		JSR FacePlayer

		.Main
		REP #$20
		LDA.w #DATA_Talkbox : JSL LOAD_HITBOX
		SEC : JSL !PlayerClipping
		STA $00
		BCC .NoTalk
		LSR A : BCC .P2

		.P1
		PHA
		LDA !P2Status-$80 : BNE ..fail
		LDA !P2Blocked-$80
		AND #$04 : BEQ ..fail
		LDA $6DA6
		AND #$08 : BEQ ..fail
		LDA #$03 : STA !TalkTimer,x
		..fail
		PLA

		.P2
		LDA !P2Status : BNE ..fail
		LDA !P2Blocked
		AND #$04 : BEQ ..fail
		LDA $6DA7
		AND #$08 : BEQ ..fail
		LDA #$03 : STA !TalkTimer,x
		..fail

		.NoTalk
		RTS


	TalkableSwap:
		JSR FacePlayer
		LDX !SpriteIndex
		LDA !TalkTimer,x : BNE .Return
		JSR Talkable_Main
		LDA !TalkTimer,x : BEQ .Return
		LDA $00 : BEQ .Return
		CMP #$03 : BEQ .Return
		CLC : ADC.b #((MAIN_CommandPtr_end-MAIN_CommandPtr)/2)-3
		STA !ExtraProp2,x
		LDA #$04 : STA !SwapWaitTimer,x

		.Return
		RTS



	FollowTalkable:
		JSR Talkable
		BRA Follow_Main

	Follow:
		JSR FacePlayer

		.Main
		REP #$20
		LDA.w #DATA_FollowBox : JSL LOAD_HITBOX
		SEC : JSL !PlayerClipping
		BCS .Stop

		LDY $3320,x
		LDA DATA_XSpeed,y : JSL AccelerateX
		RTS

		.Stop
		LDA #$00 : JSL AccelerateX
		RTS



	IntroGuard:
		LDX !SpriteIndex
		LDA !LevelTable1+$5E : BPL Guard_Main

		.Despawn
		STZ $3230,x
		RTS


	Guard:
		LDX !SpriteIndex

		.Main
		JSR Talkable
		LDA !SpriteXLo,x : STA $00
		LDA !SpriteXHi,x : STA $01
		LDA !SpriteYHi,x : XBA
		LDA !SpriteYLo,x

		REP #$30
		SEC : SBC $1C
		CMP #$0010 : BCC .Air
		CMP #$00D8 : BCS .Air
		LDA $00
		SEC : SBC $1A
		CMP #$0100 : BCS .Air

		.Solid
		LDA #$0008
		LDY #$FFF0
		JSL !GetMap16Sprite
		SEP #$30
		LDY #$10
		LDA #$01
		STA [$05]
		STA [$05],y
		DEC $07
		LDA #$30
		STA [$05]
		STA [$05],y
		RTS

		.Air
		LDA #$0008
		LDY #$FFF0
		JSL !GetMap16Sprite
		SEP #$30
		LDY #$10
		LDA #$00
		STA [$05]
		STA [$05],y
		DEC $07
		LDA #$25
		STA [$05]
		STA [$05],y
		RTS



	SwapP1:
		LDX !SpriteIndex
		LDA !SwapWaitTimer,x : BNE .Return
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BNE .Return

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

		.Return
		RTS

	SwapP2:
		LDX !SpriteIndex
		LDA !SwapWaitTimer,x : BNE SwapP1_Return
		LDA !MsgTrigger
		ORA !MsgTrigger+1
		BNE SwapP1_Return
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
		LDA #$04 : STA !ExtraProp2,x			; become talkable (swap)
		LDA !ExtraProp1,x : STA !P2Character-$80,y	; write to PCE reg
		LDA #$00 : STA !P2Init-$80,y			; init flag
		LDA #$02 : STA !P2HP-$80,y			; HP
		LDA $3220,x : STA !P2XPosLo-$80,y		;\
		LDA $3250,x : STA !P2XPosHi-$80,y		; | set coords
		LDA $3210,x : STA !P2YPosLo-$80,y		; |
		LDA $3240,x : STA !P2YPosHi-$80,y		;/

		PHY
		LDA !P2Character-$80,y : TAY
		LDA DATA_VictoryPose,y
		PLY
		STA !P2ExternalAnim-$80,y
		LDA #$20
		STA !P2ExternalAnimTimer-$80,y
		STA !P2Stasis-$80,y
		STA !SparkleTimer,x

		LDA !P2Character-$80,y : BNE .NotMario		;\
		STZ !MarioXSpeed				; |
		STZ !MarioYSpeed				; |
		LDA $3230,x : STA !MarioDirection		; |
		LDA $3220,x : STA !MarioXPosLo			; |
		LDA $3250,x : STA !MarioXPosHi			; |
		LDA $3210,x					; |
		SEC : SBC #$10					; |
		STA !MarioYPosLo				; |
		LDA $3240,x					; | mario stuff
		SBC #$00					; |
		STA !MarioYPosHi				; |
		STZ !MarioAnim					; |
		STZ !P1Dead					; |
		TYA						; |
		ASL A						; |
		ROL A						; |
		INC A						; |
		STA !CurrentMario				; |
		.NotMario					;/


		LDA #$00					;\
		STA !P2XSpeed-$80,y				; | clear speeds
		STA !P2YSpeed-$80,y				;/
		LDA $3230,x : STA !P2Direction-$80,y		; dir

		LDA !P2Character-$80 : STA $00
		LDA #$FF : STA $01
		LDA !MultiPlayer : BEQ +
		LDA !P2Character : STA $01
		+


		LDA #$00
		STA !P2Anim-$80,y
		STA !P2Anim2-$80,y
		STA !P2AnimTimer-$80,y

		REP #$20					;\
		TYA						; |
		AND #$0080					; |
		CLC : ADC.w #!P2Custom-$80			; |
		STA $0E						; | clear custom data
		SEP #$20					; |
		LDY.b #$7F-((!P2Custom)-(!P2Base))		; |
		LDA #$00					; |
	-	STA ($0E),y					; |
		DEY : BPL -					;/


	; unload characters that are no longer in play
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




	namespace off





