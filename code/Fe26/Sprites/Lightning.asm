

Lightning:

	namespace Lightning


	!LightningState		= $BE

	!PrevAnim		= $3280
	!LightningWarningYLo	= $3290
	!LightningWarningYHi	= $32A0
	!LightningTimer		= $32D0



	INIT:
		PHB : PHK : PLB						; bank wrapper start
		LDY #$0F						;\
	-	CPY !SpriteIndex : BEQ +				; |
		LDA $3230,y : BEQ +					; | don't spawn if there already is a lightning bolt
		LDA !NewSpriteNum,y					; |
		CMP !NewSpriteNum,x : BEQ .Fail				; |
	+	DEY : BPL -						;/

		LDA #$03 : JSL GET_SQUARE : BCS .Return
		.Fail
		STZ $3230,x
		.Return
		LDA #$FF : STA !PrevAnim,x

		LDA.b #.ZapDynamo : STA $0C
		LDA.b #.ZapDynamo>>8 : STA $0D
		LDY.b #!File_Sprite_BG_1 : CLC : JSL !UpdateFromFile

		PLB							; bank wrapper end
		RTL


		.ZapDynamo
		dw ..end-..start
		..start
		dw $06*$20
		dl $06*$20
		dw $7EA0
		dw $06*$20
		dl $16*$20
		dw $7FA0
		..end

	MAIN:
		PHB : PHK : PLB

		LDA !LightningState,x
		ASL A
		CMP.b #.Ptr_end-.Ptr
		BCC $02 : LDA #$00
		TAX
		JSR (.Ptr,x)
		PLB							; bank wrapper end
		RTL							; return



		.Ptr
		dw .FindTarget
		dw .Warning
		dw .FindGround
		dw .Strike
		..end


	.FindTarget
		LDX !SpriteIndex					; X = sprite index
		LDA !LightningState,x : BMI ..main
		..init							;\
		ORA #$80 : STA !LightningState,x			; | init: set timer
		LDA #$3C : STA !LightningTimer,x			;/
		..main
		LDA !LightningTimer,x : BNE ..return			;\ go into warning once timer runs out
		LDA #$01 : STA !LightningState,x			;/
		LDA !RNG						;\
		AND #$80 : TAY						; | target a random player
		LDA !P2XPosLo-$80,y : STA !SpriteXLo,x			; |
		LDA !P2XPosHi-$80,y : STA !SpriteXHi,x			;/
		STZ !SpriteYLo,x					;\ spawn at the top of the level (Y = 0)
		STZ !SpriteYHi,x					;/
		..return						;
		RTS							;


	.Warning
		LDX !SpriteIndex
		LDA !LightningState,x : BMI ..main
		..init
		ORA #$80 : STA !LightningState,x
		LDA #$28 : STA !LightningTimer,x
		LDA $1C
		CLC : ADC #$28
		STA !LightningWarningYLo,x
		LDA $1D
		ADC #$00
		STA !LightningWarningYHi,x
		..main
		LDA !LightningTimer,x : BEQ ..end
		JMP .Graphics
		..end
		LDA #$02 : STA !LightningState,x
		..return
		RTS


	.FindGround
		LDX !SpriteIndex
		LDA !LightningState,x : BMI ..main
		..init
		ORA #$80 : STA !LightningState,x
		LDA #$28 : STA !LightningTimer,x
		..main
		LDA !LightningTimer,x : BNE ..findground
		LDA #$03 : STA !LightningState,x
		..return
		RTS

		..findground
		REP #$30						;\
		LDA #$0008						; |
		LDY #$0000						; |
		JSL !GetMap16Sprite					; | check map16 for ground
		CMP #$0100						; |
		SEP #$20						; |
		BCS ..return						;/
		LDA !SpriteYLo,x					;\
		CLC : ADC #$10						; |
		STA !SpriteYLo,x					; | move 16px down if ground hasn't been found yet
		LDA !SpriteYHi,x					; |
		ADC #$00						; |
		STA !SpriteYHi,x					;/
		RTS


	.Strike
		LDX !SpriteIndex
		LDA !LightningState,x : BMI ..main
		..init							;\
		ORA #$80 : STA !LightningState,x			; | set timer for strike
		LDA #$17 : STA !LightningTimer,x			;/
	; HERE: run ..main first so sprites can block brick destruction
	JSR ..main
		LDA #$18 : STA !SPC4					; thunder SFX
		LDA #$FF						;\
		STA !LightR+1						; | super bright flash
		STA !LightG+1						; |
		STA !LightB+1						;/
		JSR .SpawnSparks					; spark particles
		REP #$30						;\
		LDA #$0008						; |
		LDY #$0000						; |
		JSL !GetMap16Sprite					; | check for brick
		CMP #$011E						; |
		SEP #$20						; |
		BNE ..main						;/
		JSR .BreakBrick						; > break brick on strike init
		..main

		; check contact with sprites (adjust hitbox)
		; check contact with players (do not adjust hitbox)
		; check water contact
		;	- zap sprites
		;	- zap players
		;	- load zap tilemap



		JSR .LoadHitbox						; load hitbox

		..zapsprites						;\ check all sprites
		LDX #$0F						;/
		..loop							;\ lightning can't zap itself
		CPX !SpriteIndex : BEQ ..nextsprite			;/
		LDA $3230,x						;\
		CMP #$08 : BCC ..nextsprite				; | interact with states 08-0B
		CMP #$0C : BCS ..nextsprite				;/
		LDA !SpriteTweaker3,x					;\
		AND #$30						; |
		CMP #$30 : BEQ ..nextsprite				; | check tweaker for what lightning can destroy
		LDA !SpriteTweaker4,x					; |
		AND #$02 : BNE ..nextsprite				;/
		..checkspritecontact					;\
		JSL !GetSpriteClipping00				; | check for contact
		JSL !Contact16 : BCC ..nextsprite			;/
		..destroysprite						;\
		LDA #$04 : STA $3230,x					; | destroy sprite
		LDA #$1F : STA $32D0,x					;/
		LDY !SpriteIndex					;\
		LDA $01 : STA !SpriteYLo,y				; | move lightning tip up
		LDA $09 : STA !SpriteYHi,y				;/
		..nextsprite						;\ loop
		DEX : BPL ..loop					;/
		LDX !SpriteIndex					; X = sprite index

		JSR .LoadHitbox						; reload hitbox

		SEC : JSL !PlayerClipping : BCC ..nocontact		;\
		JSL !HurtPlayers					; | hurt players upon contact
		..nocontact						;/

		LDA !3DWater : BNE $03 : JMP ..nowaterzap		;\
		LDA !SpriteYHi,x : XBA					; |
		LDA !SpriteYLo,x					; |
		REP #$20						; |
		CMP !Level+2						; |
		SEP #$20						; | use !BigRAM as water zap flag (if lightning bolt tip is below 3D water)
		BCC ..nowaterzap					; |
		LDA !P2Water-$80					; |
		BEQ $02 : LDA #$01					; |
		STA $00							; |
		LDA !P2Water						; |
		BEQ $02 : LDA #$02					; |
		ORA $00							; |
		JSL !HurtPlayers					;/

		LDY #$0F						;\
	-	LDA $3230,y						; |
		CMP #$08 : BCC +					; |
		CMP #$0C : BCS +					; |
		LDA !SpriteWater,y : BEQ +				; |
		LDA !SpriteTweaker3,y					; |
		AND #$30						; | zap underwater sprites
		CMP #$30 : BEQ +					; |
		LDA !SpriteTweaker4,y					; |
		AND #$02 : BNE +					; |
		LDA #$04 : STA $3230,y					; |
		LDA #$1F : STA $32D0,y					; |
	+	DEY : BPL -						;/

		LDA #$02 : STA $0D					;\
		LDA $14							; |
		AND #$02 : TAY						; |
		REP #$20						; |
		LDA .WaterZapPtr,y : STA $02				; |
		LDA ($02) : STA $0E					; |
		INC $02							; |
		INC $02							; |
		LDA !Level+2						; | load water zap tilemap as sprite HUD
		SEC : SBC #$0010					; |
		SEC : SBC $1C						; |
		BMI ..nowaterzap					; |
		CMP #$00D8 : BCS ..nowaterzap				; |
		XBA : AND #$FF00					; |
		STA $00							; |
		SEP #$20						; |
		JSL !SpriteHUD						; |
		LDX !SpriteIndex					; > X = sprite index
		..nowaterzap						;/
		SEP #$20

		LDA !LightningTimer,x : BEQ ..end			;\
		CMP #$10 : BNE .Graphics				; |
		LDA #$01						; |
		STA !LightR+1						; | restore light
		STA !LightG+1						; |
		STA !LightB+1						; |
		BRA .Graphics						;/
		..end							;\ back to search for target when timer runs out
		STZ !LightningState,x					;/
		RTS							; return





	.Graphics
		LDA !SpriteYLo,x : PHA					;\ push Ypos
		LDA !SpriteYHi,x : PHA					;/

		LDA !LightningState,x
		AND #$7F
		CMP #$01 : BNE ..nowarning
		LDA !LightningWarningYLo,x : STA !SpriteYLo,x
		LDA !LightningWarningYHi,x : STA !SpriteYHi,x
		..nowarning



		LDA !LightningTimer,x					;\
		LSR #3							; |
		CMP #$03 : BCS ..return					; |
		CMP !PrevAnim,x : BEQ ..noupdate			; |
		STA !PrevAnim,x						; |
		ASL A							; | load dynamo
		TAY							; |
		REP #$20						; |
		LDA .Anim,y : STA $0C					; |
		SEP #$20						; |
		LDY.b #!File_Sprite_BG_1 : JSL LOAD_SQUARE_DYNAMO	; |
		..noupdate						;/


		JSL SETUP_SQUARE					; get dynamic tiles
		REP #$20						;\
		LDA.w #.TipTilemap : STA $04				; | draw tip
		SEP #$20						; |
		JSL LOAD_DYNAMIC_p3					;/

		..loop							;\
		LDA !SpriteYHi,x : XBA					; |
		LDA !SpriteYLo,x					; |
		REP #$20						; |
		CMP $1C : BMI ..return					; |
		SEC : SBC #$0030					; |
		SEP #$20						; | loop to extend main tilemap to the top of the screen
		STA !SpriteYLo,x					; |
		XBA : STA !SpriteYHi,x					; |
		REP #$20						; |
		LDA.w #.MainTilemap : STA $04				; |
		SEP #$20						; |
		JSL LOAD_DYNAMIC_p3					; |
		BRA ..loop						;/

		..return						;\
		SEP #$20						; | restore Ypos
		PLA : STA !SpriteYHi,x					; |
		PLA : STA !SpriteYLo,x					;/

		RTS							; return






	.Anim
	dw .Dyn03
	dw .Dyn02
	dw .Dyn01
	dw .Dyn00


		.TipTilemap
		dw $0004
		db $32,$00,$00,$03

		.MainTilemap
		dw $000C
		db $32,$00,$00,$00
		db $32,$00,$10,$01
		db $32,$00,$20,$02

		.WaterZapPtr
		dw .WaterZapTilemap1
		dw .WaterZapTilemap2

		.WaterZapTilemap1
		dw ..end-..start
		..start
		db $00,$00,$EA,$37
		db $20,$00,$EE,$37
		db $40,$00,$EC,$37
		db $60,$00,$EA,$37
		db $80,$00,$EE,$37
		db $A0,$00,$EC,$37
		db $C0,$00,$EA,$37
		db $E0,$00,$EE,$37
		..end

		.WaterZapTilemap2
		dw ..end-..start
		..start
		db $10,$00,$EC,$37
		db $30,$00,$EA,$37
		db $50,$00,$EE,$37
		db $70,$00,$EC,$37
		db $90,$00,$EA,$37
		db $B0,$00,$EE,$37
		db $D0,$00,$EC,$37
		db $F0,$00,$EA,$37
		..end


		.Dyn00
		dw ..end-..start
		..start
		%SquareDyn($020)
		%SquareDyn($022)
		%SquareDyn($024)
		%SquareDyn($026)
		..end

		.Dyn01
		dw ..end-..start
		..start
		%SquareDyn($028)
		%SquareDyn($02A)
		%SquareDyn($02C)
		%SquareDyn($02E)
		..end

		.Dyn02
		dw ..end-..start
		..start
		%SquareDyn($040)
		%SquareDyn($042)
		%SquareDyn($044)
		%SquareDyn($046)
		..end

		.Dyn03
		dw ..end-..start
		..start
		%SquareDyn($048)
		%SquareDyn($04A)
		%SquareDyn($04C)
		..end


	.LoadHitbox
		REP #$20						;\
		LDA.w #.HITBOX : JSL LOAD_HITBOX			; |
		LDA !SpriteYHi,x : XBA					; |
		LDA !SpriteYLo,x					; |
		REP #$20						; |
		SEC : SBC $1C						; |
		BPL $03 : LDA #$0000					; | load hitbox
		CMP #$00FF						; |
		BCC $03 : LDA #$00FF					; |
		SEP #$20						; |
		STA $07							; |
		LDA $1C : STA $05					; |
		LDA $1D : STA $0B					;/
		RTS							; return


	.BreakBrick
		; keep AND #$F0 here as it speeds up fusion sprite generation
		..break							;\
		LDA !SpriteXLo,x					; |
		CLC : ADC #$08						; |
		AND #$F0 : STA $9A					; |
		LDA !SpriteXHi,x					; |
		ADC #$00						; |
		STA $9B							; | break brick upon contact with strike
		LDA !SpriteYLo,x					; |
		AND #$F0 : STA $98					; |
		LDA !SpriteYHi,x : STA $99				; |
		REP #$20						; |
		LDA #$0025 : JSL !ChangeMap16				; |
		SEP #$30						;/

		LDY #$03						;\
		..loop							; |
		%Ex_Index_X()						; |
		LDA $9A							; |
	;	AND #$F0						; > already cleared
		CLC : ADC ..xdisp,y					; |
		STA !Ex_XLo,x						; |
		LDA $9B							; |
		ADC #$00						; |
		STA !Ex_XHi,x						; |
		LDA $98							; |
	;	AND #$F0						; > already cleared
		CLC : ADC ..ydisp,y					; |
		STA !Ex_YLo,x						; | spawn brick pieces
		LDA $99							; |
		ADC #$00						; |
		STA !Ex_YHi,x						; |
		LDA.b #$01+!MinorOffset : STA !Ex_Num,x			; |
		LDA ..xspeed,y : STA !Ex_XSpeed,x			; |
		LDA ..yspeed,y : STA !Ex_YSpeed,x			; |
		STZ !Ex_Data1,x						; |
		STZ !Ex_Data2,x						; |
		STZ !Ex_Data3,x						; |
		DEY : BPL ..loop					;/

		LDX !SpriteIndex					; X = sprite index
		RTS							; return


		..xdisp
		db $00,$08,$00,$08
		..ydisp
		db $00,$00,$08,$08
		..xspeed
		db $FF,$01,$FF,$01
		..yspeed
		db $FB,$FB,$FD,$FD


	.SpawnSparks
		LDY #$0F
		..loop
		LDA ..particlex,y : STA $00
		LDA ..particley,y : STA $01
		LDA !RNGtable,y
		AND #$0F
		ADC ..particlexspeed,y
		STA $02
		LDA !RNGtable+$10,y
		AND #$0F
		ADC ..particleyspeed,y
		STA $03
		STZ $04
		STZ $05
		LDA #$5A : STA $06
		LDA #$36 : STA $07
		LDA ..particletype,y
		PHY
		JSL SpawnParticle
		PLY
		DEY : BPL ..loop
		RTS

		..particlex
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		db $00,$00,$08,$08
		..particley
		db $04,$04,$04,$04
		db $FC,$FC,$FC,$FC
		db $FC,$FC,$FC,$FC
		db $04,$04,$04,$04
		..particlexspeed
		db $E8-8,$EA-8,$EC-8,$EE-8
		db $FA-8,$FC-8,$FE-8,$00-8
		db $00-8,$02-8,$04-8,$06-8
		db $12-8,$14-8,$16-8,$18-8
		..particleyspeed
		db $E0,$E2,$E4,$E6
		db $E8,$EA,$EC,$EE
		db $EE,$EC,$EA,$E8
		db $E6,$E4,$E2,$E0
		..particletype
		db !prt_flash,!prt_flash,!prt_flash,!prt_flash
		db !prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8
		db !prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8,!prt_smoke8x8
		db !prt_flash,!prt_flash,!prt_flash,!prt_flash


	.HITBOX
		dw $0002,$FFFF : db $0C,$FF



	namespace off





