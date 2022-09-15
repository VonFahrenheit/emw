
	QuestionBlock:
	Brick:
	BlockHitbox:
		LDX !SpriteIndex
		LDA !Ex_Num,x : BMI .Main

		.Init
		ORA #$80 : STA !Ex_Num,x
		STZ !Ex_XFraction,x
		STZ !Ex_YFraction,x
		LDA #$08 : STA !Ex_Data3,x
		LDA !Ex_Data1,x
		AND #$03 : TAY
		LDA .InitXSpeed,y : STA !Ex_XSpeed,x
		LDA .InitYSpeed,y : STA !Ex_YSpeed,x
		LDA !Ex_Num,x
		CMP #!BlockHitbox_Num|$80 : BEQ ..done
		LDA !Ex_XLo,x : STA $9A
		LDA !Ex_XHi,x : STA $9B
		LDA !Ex_YLo,x : STA $98
		LDA !Ex_YHi,x : STA $99
		REP #$20
		LDA #$0152 : JSL ChangeMap16
		SEP #$30
		LDX !SpriteIndex
		..done

		.Main
		LDA !Ex_Data1,x
		AND #$03 : TAY
		LDA !Ex_XSpeed,x
		CLC : ADC .XAcc,y
		STA !Ex_XSpeed,x
		LDA !Ex_YSpeed,x
		CLC : ADC .YAcc,y
		STA !Ex_YSpeed,x
		JSR ApplySpeed

		; $029130: code for mario standing on note block
		; $02915E: code for mario bouncing on note block

		.UpdateTile
		LDA !Ex_Data3,x : BEQ ..solidify
		DEC !Ex_Data3,x : BRA ..done
		..solidify
		LDA !Ex_Num,x
		CMP #!BlockHitbox_Num|$80 : BEQ ..despawn
		LDA !Ex_Data2,x : STA $9C
		LDA !Ex_XLo,x : STA $9A
		LDA !Ex_XHi,x : STA $9B
		LDA !Ex_YLo,x : STA $98
		LDA !Ex_YHi,x : STA $99
		JSL ChangeMap16_Hijack00BEB0
		..despawn
		STZ !Ex_Num,x
		RTS
		..done


		LDA !Ex_Num,x
		AND #$7F
		CMP #!QuestionBlock_Num : BEQ .QuestionBlock
		CMP #!Brick_Num : BNE .Return

		.Brick
		JSR DrawExSprite
		dw $0000		; use SP1
		db $6E,$32
		RTS

		.QuestionBlock
		JSR DrawExSprite
		dw $0000		; use SP1
		db $6C,$32

		.Return
		RTS


	; direction:
	; 00 = up
	; 01 = right
	; 02 = left
	; 03 = down

		.InitXSpeed
		db $00,$50,$B0,$00
		.XAcc
		db $00,$F0,$10,$00

		.InitYSpeed
		db $B0,$00,$00,$50
		.YAcc
		db $10,$00,$00,$F0


