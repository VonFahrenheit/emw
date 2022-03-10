


; before going through with this:
;	- transcribe mario physics and move them to PCE
;	- patch out sprite <-> mario interactions and move them to PCE






; proposed remap:
;	$E0 - X1
;	$E2 - Y1
;	$E4 - W1
;	$E6 - H1
;	$E8 - X2
;	$EA - Y2
;	$EC - W2
;	$EE - H2

	; $03B65C - $03B75B (0x100 bytes) used for GetMarioClipping, GetSpriteClipping04, GetSpriteClipping00, and CheckForContact
	org $03B65C


; SMW CheckForContact:
;	- called 31 times in vanilla
;	- probably called even more in EMW code...
;	- there are a bunch of hard-to-detect references to its scratch RAM ($00-$0B), so it will be troublesome to actually remap everything to 16-bit

; SMW: 49 bytes long
; loop turbo: 35 bytes long
; unrolled turbo: 41 bytes long			(this is the way to go 100%)
	TurboContact:
		REP #$20
		LDA $E0
		CLC : ADC $E4
		CMP $E8 : BCC .Return
		LDA $E8
		CLC : ADC $EC
		CMP $E0 : BCC .Return
		LDA $E2
		CLC : ADC $E6
		CMP $EA : BCC .Return
		LDA $EA
		CLC : ADC $EE
		CMP $E2 : BCC .Return
		.Return
		SEP #$20
		RTL

; alt entries: 16 bytes long
; can be called to use 8-bit W/H entries for one or both hitboxes
	.ClearBoth
		STZ $ED
		STZ $EF
	.Clear1
		STZ $E5
		STZ $E7
		BRA TurboContact
	.Clear2
		STZ $ED
		STZ $EF
		BRA TurboContact


; SMW GetMarioClipping (00)
;	- called 12 times in vanilla
;	- called a few times in EMW code
;
; SMW: 67 bytes long (counting the Y/H data)
; turbo: 51 bytes long (counting the Y/H data)
	TurboMarioHurtbox:
		PHX
		LDX #$00
		LDA !MarioDucking
		ORA $19
		BEQ $02 : LDX #$02
		REP #$20
		LDA !MarioXPosLo
		INC #2
		STA $E0
		LDA #$000C : STA $E4
		LDA !MarioYPosLo
		CLC : ADC.l .DispY,x
		STA $E2
		LDA.l .H,x : STA $E6
		SEP #$20
		PLX
		RTL

	.DispY	dw $0006,$0014
	.H	dw $001A,$000C


; SMW GetSpriteClippingA (04)
;	- called 18 times in vanilla
;	- called many times in EMW code

; SMW GetSpriteClippingB (00)
;	- called 9 times in vanilla)
;	- called a few times in EMW code

; SMW: 70 bytes long
; turbo: 74 bytes long
; bank wrap turbo: 71 bytes long

	TurboSpriteClipping04:
	TurboSpriteClippingA:
		PHY						;\ push X/Y
		PHX						;/
		TXY						;\
		LDA !SpriteTweaker2,x				; | X = clipping index, Y = sprite index
		AND #$3F : TAX					;/
		LDA.l SpriteDispX,x				;\
		STZ $E9						; |
		BPL $02 : DEC $E9				; |
		CLC : ADC !SpriteXlo,y				; | x coord
		STA $E8						; |
		LDA $E9						; |
		ADC !SpriteXHi,y				; |
		STA $E9						;/
		LDA.l SpriteDispY,x				;\
		STZ $EB						; |
		BPL $02 : DEC $EB				; |
		CLC : ADC !SpriteYlo,y				; | y coord
		STA $EA						; |
		LDA $EB						; |
		ADC !SpriteYHi,y				; |
		STA $EB						;/
		LDA.l SpriteW,x : STA $EC			;\ w
		STZ $ED						;/
		LDA.l SpriteH,x : STA $EE			;\ h
		STZ $EF						;/
		PLX						;\ pull X/Y
		PLY						;/
		RTL						; return


	TurboSpriteClipping00:
	TurboSpriteClippingB:
		PHY						;\ push X/Y
		PHX						;/
		TXY						;\
		LDA !SpriteTweaker2,x				; | X = clipping index, Y = sprite index
		AND #$3F : TAX					;/
		LDA.l SpriteDispX,x				;\
		STZ $E1						; |
		BPL $02 : DEC $E1				; |
		CLC : ADC !SpriteXlo,y				; | x coord
		STA $E0						; |
		LDA $E1						; |
		ADC !SpriteXHi,y				; |
		STA $E1						;/
		LDA.l SpriteDispY,x				;\
		STZ $E3						; |
		BPL $02 : DEC $E3				; |
		CLC : ADC !SpriteYlo,y				; | y coord
		STA $E2						; |
		LDA $E3						; |
		ADC !SpriteYHi,y				; |
		STA $E3						;/
		LDA.l SpriteW,x : STA $E4			;\ w
		STZ $E5						;/
		LDA.l SpriteH,x : STA $E6			;\ h
		STZ $E7						;/
		PLX						;\ pull X/Y
		PLY						;/
		RTL						; return

; wrapper cost:
;	PHK : PLB
;	(costs 7 cycles + 2 bytes)
; wrapper exchange:
;	PHX : PLX -> PHB : PLB
; wrapper benefit:
;	don't need TXY, save 4 cycles by using LDA.w,y instead of LDA.l,x
;	(total: save 6 cycles + 5 bytes)
;
;	in total, wrapper method costs 1 cycle but saves 3 bytes of ROM
;	because of this the no-wrapper method is better, since the goal is to save cycles not free up ROM



	warnpc $03B75C

macro TurboContact(addr)
	org <addr>
		JSL TurboContact
endmacro

macro TurboMarioClipping(addr)
	org <addr>
		JSL TurboMarioHurtbox
endmacro

macro TurboGetSpriteClippingA(addr)
	org <addr>
		JSL TurboGetSpriteClippingA
endmacro

macro TurboGetSpriteClippingB(addr)
	org <addr>
		JSL TurboGetSpriteClippingB
endmacro



	; CONFIRMED GOOD (ALL.LOG + SHEX)
	; 31 total, these should require no adjustment

	%TurboMarioClipping($01A824)
	%TurboGetSpriteClippingA($01A828)
	%TurboContact($01A82C)

	%TurboMarioClipping($01E1ED)

	%TurboGetSpriteClippingA($03ADCC)
	%TurboMarioClipping($03ADD0)
	%TurboContact($03ADD4)

	%TurboGetSpriteClippingA($018AB8)
	%TurboGetSpriteClippingB($018ABE)
	%TurboContact($018AC3)

	%TurboGetSpriteClippingB($01E1FC)
	%TurboGetSpriteClippingA($01E201)
	%TurboContact($01E205)

	%TurboGetSpriteClippingB($01F66A)
	%TurboGetSpriteClippingA($01F66F)
	%TurboContact($01F673)

	%TurboGetSpriteClippingB($028152)
	%TurboGetSpriteClippingA($028157)
	%TurboContact($02815B)

	%TurboGetSpriteClippingB($02B7C2)
	%TurboGetSpriteClippingA($02B7C7)
	%TurboContact($02B7CB)

	%TurboGetSpriteClippingB($02E618)
	%TurboGetSpriteClippingA($02E61F)
	%TurboContact($02E623)

	%TurboGetSpriteClippingB($02EA8C)
	%TurboGetSpriteClippingA($02EA91)
	%TurboContact($02EA95)

	%TurboGetSpriteClippingB($0381F7)
	%TurboGetSpriteClippingA($0381FC)
	%TurboContact($038200)






	; HEAVILY ALTERED, PROCEED WITH CAUTION
	; 5 in total, though only 3 seem to remain
	; these will require careful programming to still work with SA-1 patch
	%TurboGetSpriteClippingB($03B0F5)
	%TurboGetSpriteClippingA($03B0FF)
	%TurboContact($03B103)
	%TurboGetSpriteClippingA($03B10C)
	%TurboContact($03B110)





	; WILL NEED MORE WORK
	; 34 in total, these will require thorough documentation before they can be remapped

	; $01B8FF -> hitbox generation routine
	%TurboMarioClipping($01B933)
	%TurboContact($01B937)

	; $01CA9C -> hitbox generation routine
	%TurboMarioClipping($01CAC2)
	%TurboContact($01CAC6)

	; NOTE: used with $01D40B (JSR, sprite hitbox)
	%TurboMarioClipping($01D2BD)
	%TurboContact($01D2C4)

	; $01ED0C -> hitbox generation routine
	%TurboMarioClipping($01ED2E)
	%TurboContact($01ED32)

	; $028CC8 -> hitbox generation routine (minor extended)
	%TurboMarioClipping($028CEC)
	%TurboContact($028CF0)

	; NOTE: used with $02A519 (JSR), which generates a hitbox
	%TurboMarioClipping($02A3FE)
	%TurboContact($02A405)

	; $02F9BC -> hitbox generation routine (cluster sprite)
	%TurboMarioClipping($02F9E6)
	%TurboContact($02F9EA)

	; $0390F3 -> hitbox generation routine (sprite)
	%TurboMarioClipping($03911F)
	%TurboContact($039123)

	; NOTE: used with $039DB6 (JSR DinoFlameClipping), which generates a hitbox
	%TurboMarioClipping($039D8A)
	%TurboContact($039D8E)

	; NOTE: used with $038CE4 (JSR, special mario hitbox)
	%TurboGetSpriteClippingA($038C6C)
	%TurboContact($038C70)

	; $0188AC (HandleJumpOver), generates a hitbox
	%TurboGetSpriteClippingA($0188CD)
	%TurboContact($0188D1)

	; NOTE: used with $01BC1D (JSR), which generates a hitbox
	%TurboGetSpriteClippingA($01BAFD)
	%TurboContact($01BB04)

	; NOTE: called from $01F531->TryEatSprite, generates a hitbox
	%TurboGetSpriteClippingA($01F590)
	%TurboContact($01F595)

	; cape x block
	; NOTE: used with $029696 (JSR, cape) AND $029663 (JSR, block), both of which generate hitboxes
	%TurboGetSpriteClippingA($0293DE)
	%TurboContact($0293EE)

	; NOTE: used with $02A547 (JSR, mario fireball), which generates a hitbox
	%TurboGetSpriteClippingA($02A0D4)
	%TurboContact($02A0DB)

	; NOTE: used with $01D3B1 (JSR, extended sprite) AND $01D40B (JSR, sprite)
	%TurboContact($01D3E3)

	; NOTE: used with $01FC62 (flowed to from), which generates 2 (two!) hitboxes
	%TurboContact($01FCBA)

	; NOTE:  used with $01FD0A (flowed to from), which generates a hitbox
	%TurboContact($01FD30)

	; extended sprite x cape
	; NOTE: used with $02A519 (JSR, extended sprite) AND $029696 (JSR, cape)
	%TurboContact($029643)




; other hitbox generation:
; 17 in total

	; called from
	;	$01B8FF		1 sprite
	;	$01CA9C		2 brown chained platform?
	;	$01ED0C		1 sprite
	;	$028CC8		1 minor extended sprite
	;	$02F9BC		1 cluster sprite
	;	$0390F3		1 sprite
	;	$0188AC		1 HandleJumpOver, jumping over or into shell


	; list of unknown JSRs
	;	$01D40B		2 sprite
	;	$02A519		2 extended sprite
	;	$039DB6		1 DinoFlameClipping
	;	$038CE4		1 special mario hitbox, slimmer and offset 0x30 pixels down
	;	$01BC1D		1 special mario hitbox, 16x16 with offset 0,0
	;	$029696		2 cape hitbox
	;	$02A547		1 mario fireball
	;	$01D3B1		1 extended sprite hitbox


	; flows
	;	$01FC62		1 brown chained platform?
	;	$01FD0A		1 camera hitbox x extended sprite hitbox?



















