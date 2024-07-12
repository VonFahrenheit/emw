

; input: !Level+2 = dizzy effect timer
; output:
;	$0C = 0 if a dizzy star is attached to P1, -1 if not
;	$0D = 0 if a dizzy star is attached to P2, -1 if not
;	$E0 = list (indexed by sprite num) of which dizzy star each sprite is paired with
	DIZZY_STARS:
		PHB : PHK : PLB


		; delete duplicates, only allow one star attached to each sprite
		; $E0 = list (indexed by sprite num) of which dizzy star each sprite is paired with
		.DizzyStarList
		REP #$20
		LDA #$FFFF
		STA $E0
		STA $E0+2
		STA $E0+4
		STA $E0+6
		STA $E0+8
		STA $E0+10
		STA $E0+12
		STA $E0+14
		STA $0C					; for players
		SEP #$20
		LDY #!Ex_Amount-1
		..loop
		LDA !Ex_Num,y
		CMP #!DizzyStar_Num : BNE ..next
		LDA !Ex_Data2,y
		CMP #$55 : BCS +
		ADC #$55 : STA !Ex_Data2,y
	+	LDA !Ex_Data1,y
		CMP #$10 : BCS ..player
		..sprite
		TAX
		LDA $E0,x : BPL ..delete
		TYA : STA $E0,x
		BRA ..next
		..player
		CMP #$20 : BEQ +
		STZ $0C : BRA ++
	+	STZ $0D
	++	LDA !Level+2
		ORA !Level+3
		BNE ..next
		..delete
		LDA #$00 : STA !Ex_Num,y
		..next
		DEY : BPL ..loop


		.SpawnDizzyStarsPlayers
		LDA !Level+2
		ORA !Level+3
		BEQ ..done
		..p1
		LDA !P2Status-$80 : BNE ..p2
		LDA $0C : BPL ..p2
		JSL GetExIndex_Y
		LDA #!DizzyStar_Num : STA !Ex_Num,y
		LDA #$10 : STA !Ex_Data1,y
		LDA #$F0 : STA !Ex_Data3,y
		..p2
		LDA $0D : BPL ..done
		LDA !P2Status : BNE ..done
		JSL GetExIndex_Y
		LDA #!DizzyStar_Num : STA !Ex_Num,y
		LDA #$20 : STA !Ex_Data1,y
		LDA #$F0 : STA !Ex_Data3,y
		..done

		.SpawnDizzyStarsSprites
		LDX #$0F
		..loop
		JSL SeekSpriteRange_Vanilla
			db $04,$08
			BMI ..done
		LDA !SpriteStatus,x
		CMP #$08 : BNE ..checkdespawn
		LDA !ExtraBits,x
		AND #$04 : BNE ..dancer
		..checkdespawn
		LDY $E0,x : BMI ..next
		LDA #$00 : STA !Ex_Num,y
		BRA ..next
		..dancer
		LDY $E0,x : BPL ..next
		LDA #!DizzyStar_Num : JSL SpawnExSprite
		TXA : STA !Ex_Data1,y
		LDA #$F0 : STA !Ex_Data3,y
		..next
		DEX : BPL ..loop
		..done

		PLB
		RTL












