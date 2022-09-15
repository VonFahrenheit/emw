;================;
; PARTICLE CODES ;
;================;
; input: void
; output:
;	X = particle index
;	B = particle bank (0x41)
;	all regs 16-bit
	GetParticleIndex:
		SEP #$20
		LDA #$41
		PHA : PLB
		REP #$30
		PHY
		LDY.w #!Particle_Count-1
		LDA.l !Particle_Index : TAX

	.CheckIndex
		LDA !Particle_Type,x
		AND #$007F : BEQ .ThisOne

	.SearchForward
		TXA
		CLC : ADC.w #!Particle_Size
		CMP.w #!Particle_Size*!Particle_Count
		BCC $03 : LDA #$0000
		TAX
		DEY : BPL .CheckIndex

	.ThisOne
		TXA : STA.l !Particle_Index			; save index so we don't repeatedly check slots we have already confirmed are in use
		STZ.w !Particle_Timer,x				; kill timer by default
		PLY
		RTL


; input:
;	A = particle num
;	$98 = Y position
;	$9A = Y position
;	$00 = X speed (particle format)
;	$02 = Y speed (particle format)
;	$04 = X acc
;	$05 = Y acc
;	$06 = tile
;	$07 = prop (S-PPCCCT, S is size bit, PP is mirrored to top 2 bits for layer prio + OAM prio)
; output:
;	$0E = index to spawned particle
;	mirrors the PP bits of $07 to the upper 2 bits, but the rest of $00-$07 remain
	SpawnParticleBlock:
		PHP
		SEP #$30
		STA $0F						; $0F = particle num
		LDA $07						;\
		ROL #3						; | $0E = size bit
		AND #$02					; |
		STA $0E						;/
		LDA #$C0 : TRB $07				;\
		LDA $07						; |
		AND #$30					; | mirror PP bits
		ASL #2						; |
		TSB $07						;/
		PHB						; push bank
		JSL GetParticleIndex				; X = 16-bit particle index, bank = $41
		LDA $9A : STA !Particle_XLo,x			;\ particle coords
		LDA $98 : STA !Particle_YLo,x			;/
		LDA $06 : STA !Particle_Tile,x			; particle tile/prop
		LDA $00 : STA !Particle_XSpeed,x		; particle X speed
		LDA $02 : STA !Particle_YSpeed,x		; particle Y speed
		SEP #$20					; A 8-bit
		LDA $04 : STA !Particle_XAcc,x			;\ particle acc
		LDA $05 : STA !Particle_YAcc,x			;/
		LDA $0E : STA !Particle_Layer,x			; particle size bit
		LDA $0F : STA !Particle_Type,x			; particle num

		STX $0E						; save this index
		PLB						; restore bank
		PLP
		RTL						; return

; input:
;	A = particle num
;	hitboxes loaded in both slots (E0 and E8)
;	$02 = X speed (sprite format)
;	$03 = Y speed (sprite format)
;	$04 = X acc
;	$05 = Y acc
;	$06 = tile
;	$07 = prop (S-PPCCCT, S is size bit, PP is mirrored to top 2 bits for layer prio + OAM prio)
; output:
;	$0E = index to spawned particle
;	mirrors the PP bits of $07 to the upper 2 bits, but the rest of $00-$07 remain
	SpawnParticleContact:
		PHX
		PHP
		SEP #$30
		STA $0F						; $0F = particle num
		LDA $07						;\
		ROL #3						; | $0E = size bit
		AND #$02					; |
		STA $0E						;/
		LDA #$C0 : TRB $07				;\
		LDA $07						; |
		AND #$30					; | mirror PP bits
		ASL #2						; |
		TSB $07						;/
		PHB						; push bank
		JSL GetParticleIndex				; X = 16-bit particle index, bank = $41

		CLC						;\
		LDA $E0						; |
		ADC $E8						; |
		ADC $E4						; | X position
		ADC $EC						; |
		LSR A						; |
		SBC #$0010					; |
		STA !Particle_X,x				;/
		CLC						;\
		LDA $E2						; |
		ADC $EA						; |
		ADC $E6						; | Y position
		ADC $EE						; |
		LSR A						; |
		SBC #$0010					; |
		STA !Particle_Y,x				;/

		LDA $06 : STA !Particle_Tile,x			; particle tile/prop
		LDA $02						;\
		AND #$00FF					; |
		ASL #4						; | particle X speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_XSpeed,x				;/
		LDA $03						;\
		AND #$00FF					; |
		ASL #4						; | particle Y speed
		CMP #$0800					; |
		BCC $03 : ORA #$F000				; |
		STA !Particle_YSpeed,x				;/
		SEP #$20					; A 8-bit
		LDA $04 : STA !Particle_XAcc,x			;\ particle acc
		LDA $05 : STA !Particle_YAcc,x			;/
		LDA $0E : STA !Particle_Layer,x			; particle size bit
		LDA $0F : STA !Particle_Type,x			; particle num

		STX $0E						; save this index
		PLB						; restore bank
		PLP						; restore P
		PLX						; restore X
		RTL						; return


