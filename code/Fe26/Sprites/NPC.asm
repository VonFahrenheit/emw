

NPC:

	namespace NPC

		!TalkAnim	=	$BE
		!PrevAnim	=	$3280
		!TalkTimer	=	$32D0
		!SwapWaitTimer	=	$32F0
		!SparkleTimer	=	$3300


; extra prop 1: which NPC this is (see list)
; extra prop 2: behavior/command to execute, can be sent by other sprites, players, or level code (or set internally)




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
		dw .Tinker		; 07
		dw .RallyYoshi		; 08
		dw .BigYoshi		; 09
		dw .PainterYoshi	; 0A
		dw .OldYoshi		; 0B
		dw .Unused		; 0C
		dw .Unused		; 0D
		dw .Unused		; 0E
		dw .Unused		; 0F
		dw .Toad		; 10 (toad 1)
		dw .Toad		; 11 (toad 2)
		dw .Toad		; 12 (toad 3)
		dw .Toad		; 13 (toad 4)
		dw .Toad		; 14 (toad 5)
		dw .Toad		; 15 (toad 6)
		dw .Toad		; 16 (toad 7)
		dw .Toad		; 17 (toad 8)
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
		LDA #$01 : JSL GET_SQUARE
		LDA.b #!palset_special_toad
		BRA .FinishPalset

		.Unused
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



	MAIN:
		PHB : PHK : PLB
		LDA !GameMode
		CMP #$14 : BEQ .Process
		.Fail
		PLB
		RTL

		.Process
		LDA !TalkTimer,x
		CMP #$01 : BNE ..notalk
		LDA !ExtraProp1,x : TAX
		LDA !NPC_Talk,x : STA !MsgTrigger
		LDX !SpriteIndex
		LDA !TalkAnim,x : BEQ ..notalk
		STA !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..notalk

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


		JSR CheckPlayer : BEQ .Fail

		LDA !ExtraProp1,x
		ASL A
		CMP.b #.MainPtr_end-.MainPtr : BCS .BadCharacter
		TAX
		JSR (.MainPtr,x)
		.BadCharacter

		LDA !ExtraProp2,x
		AND #$3F
		ASL A
		CMP.b #.CommandPtr_end-.CommandPtr : BCS .BadCommand
		TAX
		JSR (.CommandPtr,x)
		.BadCommand
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
		dw Toad			; 10 (toad 1)
		dw Toad			; 11 (toad 2)
		dw Toad			; 12 (toad 3)
		dw Toad			; 13 (toad 4)
		dw Toad			; 14 (toad 5)
		dw Toad			; 15 (toad 6)
		dw Toad			; 16 (toad 7)
		dw Toad			; 17 (toad 8)
		..end


		.CommandPtr
		dw FacePlayer		; 00
		dw SwapP1		; 01
		dw SwapP2		; 02
		dw Talkable		; 03
		dw TalkableSwap		; 04
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


	!Temp = 0
	%def_anim(Toad_Idle, 1)
	%def_anim(Toad_Walk, 3)
	%def_anim(Toad_Jump, 1)
	%def_anim(Toad_Pull, 1)
	%def_anim(Toad_IdleCarry, 1)
	%def_anim(Toad_WalkCarry, 3)
	%def_anim(Toad_JumpCarry, 1)
	%def_anim(Toad_Throw, 1)
	%def_anim(Toad_Cower, 1)
	%def_anim(Toad_Yell, 4)
	%def_anim(Toad_Cheer, 3)
	%def_anim(Toad_Bow, 2)
	%def_anim(Toad_Dead, 1)



	Toad:
		LDX !SpriteIndex

		.Movement
		JSL !SpriteApplySpeed
		LDA $3330,x
		AND #$04 : BEQ ..done
		LDA !SpriteAnimIndex
		CMP #!Toad_Yell+2 : BEQ ..resetanim
		CMP #!Toad_Cheer+1 : BNE ..done
		..resetanim
		INC !SpriteAnimIndex
		STZ !SpriteAnimTimer
		..done


		LDA #!Toad_Yell : STA !TalkAnim,x

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
		dw .WalkCarryDyn02 : db $05,!Toad_Walk+0
		; jump carry
		dw .JumpCarryDyn : db $FF,!Toad_Jump
		; throw
		dw .ThrowDyn : db $08,!Toad_Idle
		; cower
		dw .CowerDyn : db $FF,!Toad_Cower
		; yell
		dw .YellDyn00 : db $07,!Toad_Yell+1
		dw .YellDyn01 : db $07,!Toad_Yell+2
		dw .YellDyn02 : db $FF,!Toad_Yell+2
		dw .YellDyn00 : db $07,!Toad_Idle
		; cheer
		dw .CheerDyn00 : db $07,!Toad_Cheer+1
		dw .CheerDyn01 : db $FF,!Toad_Cheer+1
		dw .CheerDyn00 : db $07,!Toad_Idle
		; bow
		dw .BowDyn00 : db $07,!Toad_Bow+1
		dw .BowDyn01 : db $07,!Toad_Bow+0
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

		.24x32
		dw $0010
		db $3E,$FC,$F0,$00
		db $3E,$04,$F0,$01
		db $3E,$FC,$00,$02
		db $3E,$04,$00,$03

		.Leeway
		dw $0014
		db $3E,$F1,$08,$03
		db $3E,$F9,$08,$04
		db $3E,$FC,$F0,$00
		db $3E,$FC,$00,$01
		db $3E,$04,$00,$02




; if return with z = 0, this NPC should run
; if return with z = 1, this NPC should be disabled
	CheckPlayer:
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
		STA !ExtraProp2,x
		LDA #$04 : STA !SwapWaitTimer,x

		.Return
		RTS


	SwapP1:
		LDX !SpriteIndex
		LDA !SwapWaitTimer,x : BNE .Return
	LDA !MsgTrigger : BNE .Return

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
	LDA !MsgTrigger : BNE SwapP1_Return
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





	DATA:
		.XSpeed
		db $10,$F0
		db $08,$F8

		.Talkbox
		dw $FFE8,$0000 : db $30,$10

		.VictoryPose
		db $26,!Lui_Victory,!Kad_Victory,!Lee_Victory,$00,$00


	namespace off





