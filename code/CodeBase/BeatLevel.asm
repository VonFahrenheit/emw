
; input:
;	!LevelToBeat = level to mark as beat
;	!Translevel = translevel to beat
; output: beats the current level
	BeatLevel:
		SEP #$20
		LDA #$02 : STA $73CE			; set this
		LDA #$80				;\ fade music
		STA !SPC3				;/
		STA $6DD5				; set exit

		.GetIndex
		LDX !Translevel				;\ > intro level does not count
		LDA !LevelTable1,x : BMI ..beaten	; |
		LDA !LevelsBeaten			; |
		INC A					; |
		STA !LevelsBeaten			; > you've now beaten one more level (only once/level)
		LDA !LevelTable1,x			; |
		ORA #$80				; | Set clear, remove midway
		..beaten				; |
		AND.b #$60^$FF				; > clear checkpoint
		STA !LevelTable1,x			;/
		STZ !LevelTable2,x			; > clear checkpoint level
		STZ $73CE				; > clear midway flag
		..leveldone

		.SaveTime				;\
		LDA !Difficulty_full			; | only save time on time mode
		AND.b #!TimeMode : BEQ ..nosave		;/
		LDA !LevelTable3,x			;\
		ORA !LevelTable4,x			; |
		ORA !LevelTable5,x			; | always store time if there is none
		AND #$3F : BEQ ..storetime		; |
		..compare				;/
		LDA !LevelTable5,x			;\
		AND #$3F				; |
		CMP !TimeElapsedMinutes			; | check minutes
		BEQ ..checkseconds			; |
		BCS ..storetime				; |
		BCC ..nosave				;/
		..checkseconds				;\
		LDA !LevelTable4,x			; |
		AND #$3F				; |
		CMP !TimeElapsedSeconds			; | check seconds
		BEQ ..checkframes			; |
		BCS ..storetime				; |
		BCC ..nosave				;/
		..checkframes				;\
		LDA !LevelTable3,x			; | check frames
		AND #$3F				; |
		CMP !TimeElapsedFrames : BCC ..nosave	;/
		..storetime				;\
		LDA !LevelTable3,x			; |
		AND #$C0 : STA $00			; |
		LDA !LevelTable4,x			; |
		AND #$C0 : STA $01			; |
		LDA !LevelTable5,x			; |
		AND #$C0 : STA $02			; |
		LDA !TimeElapsedFrames			; |
		AND #$3F				; |
		ORA $00					; | store new fastest time
		STA !LevelTable3,x			; |
		LDA !TimeElapsedSeconds			; |
		AND #$3F				; |
		ORA $01					; |
		STA !LevelTable4,x			; |
		LDA !TimeElapsedMinutes			; |
		AND #$3F				; |
		ORA $02					; |
		STA !LevelTable5,x			; |
		..nosave				;/

		.UnlockNextLevel			;\
		REP #$30				; |
		LDX !LevelToBeat			; |
		LDA.l LevelData_Unlock,x		; |
		AND #$00F : TAX				; | unlock level
		SEP #$30				; |
		LDA !LevelTable4,x			; |
		ORA #$80				; |
		STA !LevelTable4,x			;/

		LDA #$0B : STA !GameMode		; load overworld

		RTL					; return





