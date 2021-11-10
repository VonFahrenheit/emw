


; misc:
;	f---2121
;	f	has fired flag
;	2/1	which players are currently inside cannon (bits 08/04)
;	2/1	which players are currently entering cannon (bits 02/01)

	Cannon:
		LDX $00						; X = BG object index

		LDA !BG_object_Timer,x				;\
		AND #$00FF					; | see which code to run
		STA.l !BigRAM					; > save this here for interaction check
		BEQ .Interact					;/
		CMP.w #.TilePointer_fire-.TilePointer-2 : BNE .HandleAnimation
		SEP #$20
		PHB : PHK : PLB
		LDA #$09 : STA !SPC4
		LDA #$01
		STA !P2Direction-$80
		STA !P2Direction
		STA !MarioDirection
		LDA #$FF
		STA !P2SlantPipe-$80
		STA !P2SlantPipe
		STZ !P2Stasis-$80
		STZ !P2Stasis
		PLB
		REP #$20
		JSR .SpawnParticle


		.HandleAnimation				;\
		LDA !VRAMbase+!TileUpdateTable			; |
		CMP #$00C0 : BCC .Valid				; | check if animation can be done
		.Return						; |
		RTS						;/

		.Valid						;\
		DEC !BG_object_Timer,x				; |
		PHX						; |
		LDA.w #.TilePointer_end-.TilePointer-2
		SEC : SBC !BG_object_Timer,x			; |
		AND #$00FE					; | get pointer to tile data
		TAX						; |
		LDA.l .TilePointer,x : STA $00			; |
		PLX						;/

		JMP TileUpdate


		.Interact
		LDA !BG_object_Misc,x
		AND #$00FF
		CMP #$0080 : BCS .Return
		STA.l !BigRAM+2
		LDA #$0000 : STA.l !BigRAM+4
		LDA !BG_object_Y,x
		SEC : SBC #$0018
		STA $05
		STA $0A
		LDA #$1002 : STA $06
		LDA !BG_object_X,x
		CLC : ADC #$000E
		STA $09
		PHB : PHK : PLB
		PHX
		SEP #$30
		STA $04
		SEC : JSL !PlayerClipping
		BCC ..nocontact
		LSR A : BCC ..nop1
		..p1
		PHA
		LDX #$00 : JSR .InteractPlayer
		PLA
		..nop1
		LSR A : BCC ..nocontact
		..p2
		LDX #$80 : JSR .InteractPlayer
		..nocontact
		REP #$10
		PLX
		LDA !BigRAM+4
		ORA $410000+!BG_object_Misc,x
		STA $410000+!BG_object_Misc,x

		.ProcessPlayers
		STA $00
		LDA $05
		CLC : ADC #$28
		STA $05
		LDA $0B
		ADC #$00
		STA $0B
		LSR $00 : BCC ..nop1
		..p1
		LDY #$0000 : JSR .EnterPlayer
		..nop1
		LSR $00 : BCC ..nop2
		..p2
		LDY #$0080 : JSR .EnterPlayer
		..nop2
		PLB

		LDA !MultiPlayer : BEQ ..singleplayer
		..multiplayer
		LDA.l !P2Status-$80 : BEQ +			;\ don't fire if both players are dead
		LDA.l !P2Status : BNE ..done			;/
		LDA !BG_object_Misc,x				;\
		ORA #$04					; | if P1 only is dead, add P1 to cannon
		STA !BG_object_Misc,x				;/
	+	LDA.l !P2Status : BEQ +				;\
		LDA !BG_object_Misc,x				; | if P2 only is dead, add P2 to cannon
		ORA #$08					; |
		STA !BG_object_Misc,x				;/
	+	LDA !BG_object_Misc,x
		CMP #$0C : BCS ..fire
		BRA ..done

		..singleplayer
		LDA !BG_object_Misc,x
		CMP #$04 : BCC ..done
		..fire
		LDA #$80 : STA !BG_object_Misc,x
		LDA.b #.TilePointer_end-.TilePointer-1 : STA !BG_object_Timer,x
		LDA #$00
		STA.l !P2Pipe-$80
		STA.l !P2Pipe
		LDA #$FF
		STA.l !P2Stasis-$80
		STA.l !P2Stasis

		..done
		REP #$30
		RTS


		.InteractPlayer
		TXY
		BEQ $02 : LDY #$01
		LDA $6DA2,y
		AND !P2Blocked-$80,x
		AND #$04 : BEQ ..return
		TYA
		INC A
		AND !BigRAM+2 : BNE ..return
		..initplayerenter
		TYA
		INC A
		STA !BigRAM+4
		..return
		RTS


		.EnterPlayer
		LDA #$DF : STA !P2Pipe-$80,y
		LDA !P2YPosLo-$80,y
		CMP $05
		LDA !P2YPosHi-$80,y
		SBC $0B : BCC ..nolock
		..lock
		LDA #$9F : STA !P2Pipe-$80,y
		TYA
		BEQ $02 : LDA #$01
		INC A
		ASL #2
		ORA $410000+!BG_object_Misc,x
		STA $410000+!BG_object_Misc,x
		..nolock
		RTS


		.SpawnParticle					;\
		LDA !BG_object_X,x : STA $00			; |
		LDA !BG_object_Y,x : STA $02			; |
		PHX						; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
		LDA #$0017 : STA !Particle_Timer,x		; |
		LDA $00						; |
		CLC : ADC #$0018				; |
		STA !Particle_XLo,x				; |
		LDA $02 : STA !Particle_YLo,x			; |
		STZ !Particle_XSpeed,x				; |
		STZ !Particle_YSpeed,x				; |
		LDA.w #!prt_smoke16x16 : STA !Particle_Type,x	; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
		LDA #$0017 : STA !Particle_Timer,x		; |
		LDA $00						; |
		CLC : ADC #$0014				; |
		STA !Particle_XLo,x				; |
		LDA $02
		SEC : SBC #$0004
		STA !Particle_YLo,x				; |
		LDA #$FF80 : STA !Particle_XSpeed,x		; |
		LDA #$FF80 : STA !Particle_YSpeed,x		; |
		LDA.w #!prt_smoke16x16 : STA !Particle_Type,x	; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
		LDA #$0017 : STA !Particle_Timer,x		; |
		LDA $00						; |
		CLC : ADC #$001C				; |
		STA !Particle_XLo,x				; |
		LDA $02
		SEC : SBC #$0004
		STA !Particle_YLo,x				; |
		LDA #$0080 : STA !Particle_XSpeed,x		; |
		LDA #$FF80 : STA !Particle_YSpeed,x		; |
		LDA.w #!prt_smoke16x16 : STA !Particle_Type,x	; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
		LDA #$0017 : STA !Particle_Timer,x		; |
		LDA $00						; |
		CLC : ADC #$0014				; |
		STA !Particle_XLo,x				; |
		LDA $02
		CLC : ADC #$0004
		STA !Particle_YLo,x				; |
		LDA #$FF80 : STA !Particle_XSpeed,x		; |
		LDA #$0080 : STA !Particle_YSpeed,x		; |
		LDA.w #!prt_smoke16x16 : STA !Particle_Type,x	; |
		JSL !GetParticleIndex				; > (returns with 16-bit A)
		LDA #$0017 : STA !Particle_Timer,x		; |
		LDA $00						; |
		CLC : ADC #$001C				; |
		STA !Particle_XLo,x				; |
		LDA $02
		CLC : ADC #$0004
		STA !Particle_YLo,x				; |
		LDA #$0080 : STA !Particle_XSpeed,x		; |
		LDA #$0080 : STA !Particle_YSpeed,x		; |
		LDA.w #!prt_smoke16x16 : STA !Particle_Type,x	; |
		PLX						; |
		..done						; |
		RTS						;/



		.TilePointer
		dw .CannonIdle
		dw .CannonTilt1
		dw .CannonTilt1
		dw .CannonTilt1
		dw .CannonTilt2
		dw .CannonTilt2
		dw .CannonTilt2
		dw .CannonFire1
		dw .CannonFire1
		dw .CannonFire1
		dw .CannonFire1
		dw .CannonFire1
		dw .CannonFire1
		..fire
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonFire2
		dw .CannonTilt2
		..end



		.CannonIdle
		dw $2800,$2801,$2802,$2803
		dw $2810,$2811,$2812,$2813
		dw $2820,$2821,$2822,$2823
		dw $2830,$2831,$2832,$2833
		.CannonTilt1
		dw $2840,$2841,$2842,$2843
		dw $2850,$2851,$2852,$2853
		dw $2860,$2861,$2862,$2863
		dw $2870,$2871,$2872,$2873
		.CannonTilt2
		dw $2804,$2805,$2806,$2807
		dw $2814,$2815,$2816,$2817
		dw $2824,$2825,$2826,$2827
		dw $2834,$2835,$2836,$2837
		.CannonFire1
		dw $2808,$2809,$280A,$280B
		dw $2818,$2819,$281A,$281B
		dw $2828,$2829,$282A,$282B
		dw $2838,$2839,$283A,$283B
		.CannonFire2
		dw $280C,$280D,$280E,$280F
		dw $281C,$281D,$281E,$281F
		dw $282C,$282D,$282E,$282F
		dw $283C,$283D,$283E,$283F


