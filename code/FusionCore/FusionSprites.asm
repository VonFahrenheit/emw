

HandleEx:
namespace FusionSprite
	HandleEx:
		.CoinTimer
		LDA !CoinTimer					;\
		CMP #$02 : BCC ..done				; |
		LDA $9D : BNE ..done				; | coin timer code from $02902D
		DEC !CoinTimer					; |
		..done						;/

		LDX #!Ex_Amount-1				; full index
		LDA $64 : PHA					; preserve this

	.Loop
		STX !SpriteIndex				; store index

		.Dizzy						;\
		LDA !DizzyEffect : BEQ ..done			; |
		REP #$20					; |
		LDA !CameraBackupY : STA $1C			; |
		SEP #$20					; |
		LDA !Ex_XHi,x : XBA				; |
		LDA !Ex_XLo,x					; |
		REP #$20					; |
		SEC : SBC $1A					; |
		AND #$00FF					; |
		LSR #3						; | dizzy effect
		ASL A						; |
		PHX						; |
		TAX						; |
		LDA !DecompBuffer+$1040,x			; |
		AND #$01FF					; |
		CMP #$0100					; |
		BCC $03 : ORA #$FE00				; |
		STA $1C						; |
		PLX						; |
		SEP #$20					; |
		..done						;/

		LDA !Ex_Num,x
		AND #$7F : BNE .Call

		.Clear
		LDA #$FF : STA !Ex_Palset,x
		BRA .Next

	.Call
		TAX
		LDA.l .PalsetIndex,x : BMI ..palsetdone		; if index is negative, keep the current one
		JSL LoadPalset
		LDX $0F
		LDA !Palset_status,x
		ASL A
		LDX !SpriteIndex
	; this will sometimes store 0xFF!
		STA !Ex_Palset,x
		..palsetdone
		LDX !SpriteIndex
		LDA !Ex_Palset,x
		CMP #$FF : BEQ .Jump
		LDA $64
		AND #$F0
		ORA !Ex_Palset,x
		STA $64

		.Jump
		LDA !Ex_Num,x
		ASL A
		CMP.b #.FusionPtr_end-.FusionPtr : BCC ..valid
		STZ !Ex_Num,x : BRA .Clear
		..valid
		TAX
		PEA .Next-1					; return address
		JMP (.FusionPtr,x)

	.Next
		LDX !SpriteIndex
		DEX : BMI $03 : JMP .Loop

		REP #$20
		LDA !DizzyEffect
		AND #$00FF : BEQ +
		LDA !CameraBackupY : STA $1C
	+	SEP #$30
		PLA : STA $64					; restore this
		RTS



		.FusionPtr
		dw .EmptyPointer		; 00
		dw MarioFireball		; 01
		dw LuigiFireball		; 02
		dw .EmptyPointer		; 03
		dw .EmptyPointer		; 04
		dw .EmptyPointer		; 05
		dw .EmptyPointer		; 06
		dw .EmptyPointer		; 07
		dw MalleableExtendedSprite	; 08
		dw Hammer			; 09
		dw Bone				; 0A
		dw Baseball			; 0B
		dw SmallFireball		; 0C
		dw BigFireball			; 0D
		dw TinyFlame			; 0E
		dw VolcanoLotusFire		; 0F
		dw Glitter			; 10
		dw QuestionBlock		; 11
		dw Brick			; 12
		dw BlockHitbox			; 13
		dw CoinFromBlock		; 14
		dw Shooter			; 15
		dw TorpedoTedArm		; 16
		dw DizzyStar			; 17
		dw Explosion			; 18
		dw TurnToParticle		; 18
		..end

	.EmptyPointer
		RTS


	.PalsetIndex
		db $FF	; 00 - empty
		db $0A	; 01 - mario fireball, yellow
		db $02	; 02 - luigi fireball, luigi palset
		db $FF	; 03 - empty
		db $FF	; 04 - empty
		db $FF	; 05 - empty
		db $FF	; 06 - empty
		db $FF	; 07 - empty
		db $FF	; 08 - malleable extended sprite, should be set at spawn!
		db $0B	; 09 - hammer, blue
		db $0E	; 0A - bone, grey
		db $0C	; 0B - baseball, red
		db $0A	; 0C - piranha fireball, yellow
		db $0A	; 0D - reznor fireball, yellow
		db $0A	; 0E - tiny flame, yellow
		db $0C	; 0F - volcano lotus fire
		db $FF	; 10 - glitter, none
		db $0A	; 11 - question block, yellow
		db $0A	; 12 - brick, yellow
		db $FF	; 13 - block hitbox
		db $0A	; 14 - coin from block, yellow
		db $FF	; 15 - shooter
		db $0E	; 16 - torpedo ted arm, grey
		db $0A	; 17 - dizzy star, yellow
		db $FF	; 18 - explosion, ????
		db $FF	; 19 - turn to particle, ????
		..end


;=================;
; SHARED ROUTINES ;
;=================;

; input: void
; output: void
	ApplySpeed:
		.X
		LDA !Ex_XSpeed,x : BEQ ..done
		ASL #4
		CLC : ADC !Ex_XFraction,x
		STA !Ex_XFraction,x
		PHP
		LDY #$00
		LDA !Ex_XSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC !Ex_XLo,x : STA !Ex_XLo,x
		TYA
		ADC !Ex_XHi,x : STA !Ex_XHi,x
		..done

		.Y
		LDA !Ex_YSpeed,x : BEQ ..done
		ASL #4
		CLC : ADC !Ex_YFraction,x
		STA !Ex_YFraction,x
		PHP
		LDY #$00
		LDA !Ex_YSpeed,x
		LSR #4
		CMP #$08
		BCC $03 : ORA #$F0 : DEY
		PLP
		ADC !Ex_YLo,x : STA !Ex_YLo,x
		TYA
		ADC !Ex_YHi,x : STA !Ex_YHi,x
		..done

		RTS



; input: void
; output: void
	DestroyAtWall:
		LDA !Ex_XLo,x : STA $9A
		LDA !Ex_XHi,x : STA $9B
		LDA !Ex_YLo,x
		CLC : ADC #$08
		STA $98
		LDA !Ex_YHi,x
		ADC #$00
		STA $99
		LDA !Ex_XSpeed,x
		PHX
		REP #$30
		BPL .Plus
		.Minus
		LDA #$0002 : BRA +
		.Plus
		LDA #$000E
	+	CLC : ADC $9A
		STA $9A
		JSL GetMap16_Tile
		PLX

		CMP #$0111 : BCC TurnToSmoke_Return
		CMP #$016E : BCS TurnToSmoke_Return

	TurnToSmoke:
		SEP #$20
		LDA !Ex_XLo,x : STA $9A
		LDA !Ex_XHi,x : STA $9B
		LDA !Ex_YLo,x : STA $98
		LDA !Ex_YHi,x : STA $99
		STZ !Ex_Num,x
		PHX
		JSL GetParticleIndex
		LDA $9A : STA !Particle_X,x
		LDA $98 : STA !Particle_Y,x
		SEP #$20
		LDA.b #!prt_smoke16x16 : STA !Particle_Type,x
		LDA #$F0 : STA !Particle_Prop,x			; max prio
		SEP #$10
		PLX
		PHK : PLB

		.Return
		SEP #$30
		RTS




; input:
;	JSR here, with JSR followed by GFX input
;	format:
;		16-bit !GFX_status index
;		8-bit tile num
;		8-bit prop (YXPP--sr)
;		s = size bit
;		r = rotation (if set, 0xC0 is EOR'd to prop for odd index)
;		PP bits are also used to determine OAM prio
; output:
;	$00 = 16-bit X position on screen
;	$02 = 16-bit Y position on screen
;	despawns if more than 32 px off-screen
;	returns to after table

	DrawExSprite:
		LDA !Ex_XLo,x : STA $00			;\
		LDA !Ex_XHi,x : STA $01			; | get coords
		LDA !Ex_YLo,x : STA $02			; |
		LDA !Ex_YHi,x : STA $03			;/
		STZ $06					; clear lo byte

		REP #$20
		LDA $01,s				;\ pointer
		INC A : STA $04				;/
		INC #3 : STA $01,s			; increase return address (+4)
		SEP #$20

		.GetProp
		LDA !Ex_Palset,x			;\ ccc bits
		AND #$0E : STA $07			;/
		LDY #$03				;\
		LDA ($04),y				; | YXPP bits
		AND #$F0 : TSB $07			;/
		AND #$30				;\
		LSR #3 : STA $0E			; | index to OAM data
		STZ $0F					;/
		LDA ($04),y				;\
		LSR A : BCC ..rotatedone		; |
		TXA					; |
		LSR A : BCC ..rotatedone		; | rotation
		LDA $07					; |
		EOR #$C0 : STA $07			; |
		..rotatedone				;/
		LDA !Ex_XSpeed,x : BPL ..done		;\
		LDA $07					; | xflip based on speed
		EOR #$40 : STA $07			; |
		..done					;/



		.Status
		REP #$30
		LDA ($04) : BEQ ..done			; check GFX status (0 = use SP1)
		TAX					;\
		LDA !GFX_status,x : TSB $06		; | set tile + prop
		..done					;/

		LDA $00					;\
		SEC : SBC $1A				; |
		STA $00					; | check if on-screen (X)
		CMP #$FFF0 : BCS .GoodX			; |
		CMP #$0100 : BCC .GoodX			;/

		.BadCoord				;\
		LDA $00					; |
		CMP #$FFE0 : BCS ..okx			; |
		CMP #$0120 : BCS ..kill			; |
		..okx					; |
		LDA $02					; |
		CMP #$FFE0 : BCS .Return		; | despawn if off-screen by 32px or more
		CMP #$0100 : BCC .Return		; |
		..kill					; |
		SEP #$30				; |
		LDX !SpriteIndex			; |
		STZ !Ex_Num,x				; |
		RTS					;/

		.GoodX					;\
		LDA $02					; |
		SEC : SBC $1C				; | check if on-screen (Y)
		STA $02					; |
		CMP #$FFF0 : BCS .GoodY			; |
		CMP #$00E0 : BCS .BadCoord		;/

		.GoodY					;\

		LDX $0E
		TXY
		LDA !OAMindex_p0,x
		CMP #$0200 : BCS .BadCoord
		CLC : ADC !OAMindex_offset,y
		TAX

		LDA $00 : STA !OAM_p0+$000,x		; |
		LDA $02 : STA !OAM_p0+$001,x		;/
		LDY #$0002				;\
		LDA ($04),y				; |
		AND #$00FF				; | write tile + prop
		CLC : ADC $06				; |
		STA !OAM_p0+$002,x			;/

		TXA					;\
		LSR #2					; |
		TAX					; |
		SEP #$20				; |
		LDA $01					; | write hi byte
		AND #$01 : STA $08			; |
		LDY #$0003				; |
		LDA ($04),y				; |
		AND #$02				; |
		ORA $08 : STA !OAMhi_p0,x		;/
		REP #$20				;\
		INX					; |
		TXA					; | update OAM index
		ASL #2					; |

		LDX $0E
		SEC : SBC !OAMindex_offset,x
		STA !OAMindex_p0,x			;/

		.Return
		SEP #$30
		LDX !SpriteIndex
		RTS




;================;
; FUSION SPRITES ;
;================;
incsrc "FusionSprites/MarioFireball.asm"
incsrc "FusionSprites/LuigiFireball.asm"
incsrc "FusionSprites/MalleableExtendedSprite.asm"
incsrc "FusionSprites/Hammer.asm"
incsrc "FusionSprites/Bone.asm"
incsrc "FusionSprites/Baseball.asm"
incsrc "FusionSprites/SmallFireball.asm"
incsrc "FusionSprites/BigFireball.asm"
incsrc "FusionSprites/TinyFlame.asm"
incsrc "FusionSprites/VolcanoLotusFire.asm"
incsrc "FusionSprites/Glitter.asm"
incsrc "FusionSprites/BouncingBlock.asm"
incsrc "FusionSprites/CoinFromBlock.asm"
incsrc "FusionSprites/Shooter.asm"
incsrc "FusionSprites/TorpedoTedArm.asm"
incsrc "FusionSprites/DizzyStar.asm"
incsrc "FusionSprites/Explosion.asm"
incsrc "FusionSprites/TurnToParticle.asm"



;==============;
; JSL ROUTINES ;
;==============;


; input:
;	none
; output:
;	X = free index (if using X version)
;	Y = free index (if using Y version)
;	!Ex_Index = free index that was just found
;	the unused index reg is unchanged
;	if there is no index free, it will default to 00 and that exsprite will be overwritten
	Ex_GetIndex:

		.Y
		PHX
		LDX.b #!Ex_Amount-1		; loop counter
		LDY !Ex_Index			; starting index
	..loop	LDA !Ex_Num,y : BEQ ..thisone	;\
		DEY				; | search table
		BPL $02 : LDY.b #!Ex_Amount-1	; |
		DEX : BPL ..loop		;/
		LDY #$00			; default index = 00
	..thisone
		PLX
		STY !Ex_Index			; update index
		CPY #$00			; update P
		RTL

		.X
		PHY
		LDY.b #!Ex_Amount-1		; Y = loop counter
		LDX !Ex_Index			; X = starting index
	..loop	LDA !Ex_Num,x : BEQ ..thisone	;\
		DEX				; | search table
		BPL $02 : LDX.b #!Ex_Amount-1	; |
		DEY : BPL ..loop		;/
		LDX #$00			; default index = 00
	..thisone
		PLY
		STX !Ex_Index			; update index
		CPX #$00			; update P
		RTL






namespace off



