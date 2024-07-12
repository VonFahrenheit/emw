

	!BooTarget	= $BE
	!BooTongue	= $3280
	!BooOscillation	= $3290
	!BooCounter	= $32A0
	!BooIdleTimer	= $32B0
	; 32D0 is laugh timer

	INIT:
	MAIN:

	.Oscillation
		INC !BooCounter,x
		LDA !BooCounter,x
		REP #$30
		AND #$00FF
		ASL A
		TAX
		LDA.l !TrigTable,x
		LSR #3
		SEP #$30
		LDX !SpriteIndex
		SEC : SBC #$0A
		STA !BooOscillation,x


; $F0 = which players to ignore eye contact from
; $F1 = which sides are blocked
; $F2 = direction of P1
; $F3 = direction of P2
; check which sides are blocked by player sight
	.CheckSight
		STZ !SpriteAnimIndex,x
		LDA #$15 : JSL GetSpriteClippingE8_A			;\
		JSL PlayerContact					; | mark players outside general sight
		EOR #$03 : STA $F0					;/
		LDA #$14 : JSL GetSpriteClippingE8_A			;\
		JSL PlayerContact					; | mark players in vertical line sight
		TSB $F0							;/ (dead/inactive players are always marked by first check)
		STZ $F1							; clear blocked

	.CheckP1
		JSL SUB_HORZ_POS_P1
		STY $F2
		LSR $F0 : BCS ..done
		CPY !P2Dir-$80 : BNE ..done				; player looking away from sprite
		INY : STY $F1
		..done

	.CheckP2
		JSL SUB_HORZ_POS_P2
		STY $F3
		LSR $F0 : BCS ..done
		CPY !P2Dir : BNE ..done					; player looking away from sprite
		INY : TYA : TSB $F1
		..done

	.DetermineTarget
		LDA $F1 : BEQ ..closest					; if no sides are blocked, just target closest
		LSR A : BCS ..leftonly
		..rightonly
		LDA $F2 : BNE +
		LDA $F3 : BEQ ..closest
		..p1
		LDA #$00 : BRA ..settarget
	+	LDA $F3 : BEQ ..p2
		BRA ..done

		..leftonly
		LSR A : BCS ..done
		LDA $F3 : BEQ +
		LDA $F2 : BNE ..closest
		..p2
		LDA #$80 : BRA ..settarget
	+	LDA $F2 : BNE ..p1
		BRA ..done

		..closest
		JSL CLOSEST_PLAYER
		TYA
		..settarget
		STA !BooTarget,x
		LDA #$02 : STA !SpriteAnimIndex,x
		..done



	.TongueTimer
		LDA !BooTongue,x : BEQ ..done
		DEC !BooTongue,x
		LSR A
		AND #$02
		ORA #$04
		STA !SpriteAnimIndex,x
		..done


	.LaughTimer
		LDA $32D0,x : BEQ ..done
		LSR A
		AND #$02
		ORA #$08
		STA !SpriteAnimIndex,x
		..done


	.Physics
		LDY !BooTarget,x : JSL SUB_HORZ_POS_Target
		TYA : STA !SpriteDir,x
		LDA !SpriteAnimIndex,x : BEQ ..stop
		LDA !BooTongue,x : BNE ..stop
		STZ !BooIdleTimer,x
		LDA !SpriteXSpeed,x
		EOR DATA_XSpeed,y : BMI ..fast
		LDA $14
		AND #$03 : BNE ..move
		..fast
		LDA !Difficulty
		ASL A : ORA !SpriteDir,x
		TAY
		LDA DATA_XSpeed,y : JSL AccelerateX_Unlimit1
		LDA !BooOscillation,x
		LDY !BooTarget,x
		JSL SUB_VERT_POS_Target					; A + Y input
		LDA DATA_YSpeed,y : JSL AccelerateY_Unlimit1
		BRA ..move
		..stop
		JSL AccelerateX_Friction2
		JSL AccelerateY_Friction
		INC !BooIdleTimer,x : BNE ..move
		LDA #$30 : STA !BooTongue,x
		..move
		JSL APPLY_SPEED_X
		JSL APPLY_SPEED_Y


	.Interaction
		JSL GetSpriteClippingE8
		JSL P2Standard
		LDA $02 : BEQ ..done
		LDY !Difficulty
		LDA DATA_LaughTime,y : STA $32D0,x
		..done


	.Graphics
		LDY !SpriteAnimIndex,x : JSL DRAW_SIMPLE_Main
		RTS



	DATA:
	.XSpeed
		db $0C,$F4
		db $10,$F0
		db $18,$E8

	.YSpeed
		db $10,$F0

	.LaughTime
		db $40,$60,$80
