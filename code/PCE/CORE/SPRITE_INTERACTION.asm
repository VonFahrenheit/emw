;===================;
;INTERACTION ROUTINE;
;===================;
; --Info--
; Interaction 00 means the sprite has no set interaction.
; Interaction 01 is for Shelless Koopas (#$00-#$03) and Sliding Koopa (#$BD).
; Interaction 02 is for Koopas (#$04-#$07), Buzzy Beetle (#$11), Koopa Shells (#$DA-#$DD and #$DF) and
; MechaKoopa (#$A2).
; Interaction 03 is for Parakoopas (#$08-#$0C).
; Interaction 04 is for Bob-omb (#$0D) and Parabomb (#$40).
; Interaction 05 is for Goomba (#$0F).
; Interaction 06 is for Bouncing Paragoomba (#$10) and Paragoomba (#$3F).

; Interaction 07 is for Spiny (#$13), Falling Spiny (#$14), Hopping Fireball (#$1D),
; Magikoopa's Magic (#$20), Thwomp (#$26), Thwimp (#$27), Big Boo (#$28), Pirahna Plants (#$2A and #$4F-#$50),
; Sumo Brother's Lightning (#$2B), Spike Top (#$2E), Fireball Vertical (#$33), Boss Fireball Stationary (#$34),
; Boo (#$37), Eeries (#$38-#$39), Urchins (#$3A-#$3C), Rip Van Fish (#$3D), Torpedo Ted (#$44),
; Diggin' Chuck's Rock (#$48), Chainsaws (#$65-66), Grinder Line-guided (#$67), Fuzzball Line-guided (#$68),
; Volcano Lotus (#$99), Sumo Brother (#$9A), Ball and Chain (#$9E), Bowser's Bowling Ball (#$A1),
; Floating Spike Ball (#$A4), Sparky/Fuzzball (#$A5), Hothead (#$A6), Blargg (#$A8), Reznor (#$A9),
; Fishbone (#$AA), Reflecting Stream of Boo Buddies (#$B0), Falling Spike (#$B2), Bowser Statue Fireball (#$B3),
; Grinder non-line-guided (#$B4), Reflecting Fireball (#$B6), Blurp Fish (#$C2), Porcu-Puffer Fish (#$C3),
; Big Boo Boss (#$C5), Group of 5 Eeries wave motion (#$DE) .

; Interaction 08 is for Fish (#$15-#$16 and #$18).
; Interaction 09 is for Bouncing Football (#$1B), Bullet Bill (#$1C), Lakitus (#$1E and #$4B), Magikoopa (#$1F), Ninji (#$51),
; Hammerbrother (#$9B) and Swooper Bat (#$BE).
; Interaction 0A is for completely solid objects.
; Interaction 0B is for Moving Coin (#$21).
; Interaction 0C is for Net Koopas (#$22-#$25).
; Interaction 0D is for Portable Springboard (#$2F) and POW (#$3E).
; Interaction 0E is for Dry Bones (#$30 and #$32) and Bony Beetle (#$31).
; Interaction 0F is for Dolphins (#$41-#$43), Growing/shrinking Pipe End (#$49) and Timed Lift (#$BA),
; Grey Moving Castle Block Horizontal (#$BB), Grey platform on lava (#$C0), Grey platform that falls (#$C4).
; Interaction 10 is for Chucks (#$46, #$91-#$95, #$97 and #$98).
; Interaction 11 is for Goal Point Sphere (#$4A).
; Interaction 12 is for Monty Mole (#$4D and #$4E).
; Interaction 13 is for Dino Rhino (#$6E) and Dino Torch (#$6F).
; Interaction 14 is for Banzai Bill (#$9F).
; Interaction 15 is for Rex (#$AB).
; Interaction 16 is for Boo Block (#$AC).
; Interaction 17 is for Carrot Top Platforms (#$B7-#$B8).
; Interaction 18 is for Mega Mole (#$BF).
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!Interaction 19 is unused!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; Interaction 1A is for powerups (#$74-#$78).


SPRITE_INTERACTION:

		LDA !P2Character
		CMP #$02 : BNE +
		STZ !P2SenkuSmash		; > Clear senku smash flag
		+

		STZ !P2Platform			; > Cancel platform
		LDA !CurrentPlayer : BNE +	; > Get current player
		LDA !P2Anim : STA $F0
		REP #$20
		LDA !P2XPosLo : STA $08
		LDA !P2YPosLo : STA $02
		PHK : PEA .Start-1		; > JSL return
		PHX				; > X
		PHB				; > Bank
		PEA PlayerClipping_End-1	; > JSR return
		REP #$10			; > Index 16-bit
		LDA !Characters			;\
		AND #$00F0			; | Y = char index
		LSR #3				; |
		TAY				;/
		JML PlayerClipping_ReadData	; > Get clipping
	+	CLC : JSL PlayerClipping	; > Simply this for P2


		.Start
		LDA $00 : STA !P2Hurtbox+0	;\
		LDA $01 : STA !P2Hurtbox+2	; |
		LDA $02 : STA !P2Hurtbox+4	; | Back up player hurtbox
		LDA $03 : STA !P2Hurtbox+5	; |
		LDA $08 : STA !P2Hurtbox+1	; |
		LDA $09 : STA !P2Hurtbox+3	;/

		LDX #$0F			; > Highest sprite index
		LDA !CurrentPlayer		;\
		BEQ +				; |
		LDA !Characters			; |
		AND #$0F			; | $F6 = character ID
		BRA ++				; |
	+	LDA !Characters			; |
		LSR #4				; |
	++	STA $F6				;/

		.Loop
		STZ $0F				; clear carry item flag
		LDA $3230,x			;\
		CMP #$02 : BEQ .Valid		; | Loop if sprite is in an invalid state
		CMP #$08 : BCC .End		;/
	.Valid	LDA !CurrentPlayer		;\
		BNE +				; |
		LDA $32E0,x : BNE .End		; | Loop if sprite has player interaction disabled
		BRA ++				; |
	+	LDA $35F0,x : BNE .End		;/
	++	CPX #$08			;\
		BCS +				; |
		LDA !P2IndexMem1		; |
		BRA ++				; | Check index memory
	+	LDA !P2IndexMem2		; |
	++	AND BITS,x			; |
		BNE .End			;/

		JSL $03B69F			; Get sprite A clipping values
		JSL !CheckContact		; Check for contact
		BCC .End

		LDA !P2Character
		CMP #$01 : BNE .NoCarry
		LDA $3230,x
		CMP #$09 : BNE .NoCarry
		LDA !P2Carry : BNE .NoCarry
		BIT $6DA3 : BVC .NoCarry
		JSR LuigiCarry
		BRA .Return
		.NoCarry


		LDA !ExtraBits,x		;\
		AND #$08			; | Determine if it's a custom sprite
		BEQ .FirstBlock			;/
		LDA !NewSpriteNum,x : TAY	;\
		LDA.w INTERACTION_TABLE+$100,y	; | Get custom sprite interaction
		BRA .Shared			;/

		.FirstBlock
		LDY $3200,x			;\ Get vanilla sprite interaction
		LDA.w INTERACTION_TABLE,y	;/

		.Shared
		STX $7695			; > $7695 = sprite index
		CMP #$0A : BEQ .Process		; > Block ignores senku

		LDX $F6				;\ Special checks for Kadaal
		CPX #$02 : BEQ .Kadaal		;/

		.Process
		XBA				;\
		LDA $3230,x			; | Don't actually run this routine in state 2
		CMP #$02 : BEQ .Return		; | (but still let Kadaal senku smash)
		XBA				;/
		ASL A				;\
		TAX				; | Execute routine
		JSR (INTERACTION_POINTER,x)	;/

		.Return
		LDX $7695			; > Reload sprite index

		.End
		DEX : BMI ..R
		JMP .Loop			; > Loop
	..R	RTS				; > Return


	.Kadaal
		LDY !P2Kick			;\
		BMI +				; | 
		BEQ +				; | Invulnerable during spin attack
		LDY !P2Invinc : BNE +		; |
		LDY #$01 : STY !P2Invinc	;/

	+	LDY !P2Senku : BEQ .Process	; > Check for senku
		CPY #$20 : BCS .Process		; > 20+ are valid
		CMP #$0B : BEQ .Process		;\
		CMP #$0F : BEQ .Process		; | 0B, 0F, 11 are valid
		CMP #$11 : BEQ .Process		;/
		CMP #$16 : BCC .SenkuSmash	;\ 16-1A are valid
		CMP #$1B : BCS .SenkuSmash	;/
		BRA .Process

		.SenkuSmash
		INC !P2SenkuSmash		;\ Set senku smash flag
		BRA .End			;/


INTERACTION_POINTER:	dw SPRITE_INTERACTION_Return	; No interaction
			dw INT_01			; Shelless Koopas
			dw INT_02			; Koopas and Buzzy Beetle
			dw INT_03			; Parakoopas
			dw INT_04			; Bobomb and Parabomb
			dw INT_05			; Goomba
			dw INT_06			; Paragoombas
			dw INT_07			; Sprites that simply hurt player 2
			dw INT_08			; Fish
			dw INT_09			; Bullet Bill
			dw INT_0A			; Lakitus, Magikoopa, Ninji and Hammer Brother
			dw INT_0B			; Coins
			dw INT_0C			; Net Koopas (STILL UNFINISHED!!)
			dw INT_0D			; POW and Springboard (USES A MODIFIED DISASSEMBLY!!)
			dw INT_0E			; Dry Bones and Bony Beetle
			dw INT_0F			; Solid Sprites (FIX Y OFFSET!!)
			dw INT_10			; Chucks
			dw INT_11			; Goal
			dw INT_12			; Monty Mole
			dw INT_13			; Dinos
			dw INT_14			; Banzai Bill
			dw INT_15			; Rex
			dw INT_16			; Boo Block
			dw INT_17			; Carrot Top Platforms (STILL UNFINISHED!!)
			dw INT_18			; Mega Mole
			dw INT_19			; Player 2 upgrade 1
			dw INT_1A			; Powerups
			dw INT_1B			; Captain Warrior
			dw INT_1C			; Adept Shaman

STOMPSOUND_TABLE:	db $13,$14,$15,$16		; Indexed with consecutive kills
			db $17,$18,$19,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; --Interaction subroutine manual--
;
; All interaction routines should start with:
;
; LDX $7695
;
; This loads the sprite index.
; Most interaction routines should follow this up with:
;
; LDA $3230,x
; CMP #$08
; BEQ .Process
; RTS
; .Process
;
; This makes sure that interaction will only happen if sprite B status is 08 (normal).
;
; 
; --Commonly called subroutines--
;
; - COMPARE_Y:
;
;	Loads 16 bit Ypos of player 2 and subtracts 16 bit Ypos of sprite B.
;	Usually called immediatedly after .Process. Should be followed by:
;
;	CLC : ADC #$XX
;	BMI .Top
;	.Side
;
;	CMP can be used instead of ADC, but will use negative numbers and can be confusing.
;	(because the SNES starts the Y-axis at the top of the screen, rather than the bottom)
;
; - COMPARE_X:
;
;	Loads 16 bit Xpos of player 2 and subtracts 16 bit Xpos of sprite B.
;	Not used nearly as much as COMPARE_Y, but still deserves a mention.
;
; - HURT:
;
;	Simply hurts player 2. Should be called like this:
;
;	LDA $32B0,x
;	BNE .Return
;	LDA #$08
;	STA $3300,y
;	JMP HURT
;
;	$1564 disables sprite interaction. Setting it to 08 prevents player 2 from stomping right after being hit.
;
; - INCREMENT_KILLS:
;
;	Spawns a score sprite and increments player 2's kill count. X and Y are not changed by this routine.
;
; - BOUNCE:
;
;	Gives player 2 some Yspeed. Holding B will give additional floatiness.
;
; - CONTACTGFX:
;
;	Displays the contact star (that Mario usually uses).
;	Should be called like this:
;
;	LDA #$XX
;	LDY #$XX
;	JSR CONTACTGFX
;
;	A and Y determine where the smoke sprite spawns. They are offsets in pixels.
;	X is used as a sprite table index (instead of $60) so it can be spawned at other sprites, too.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GenJump:
	JSR StompSFX

	.NoSFX
	JSR Bounce
	LDA #$00
	LDY #$08
	JMP ContactGFX

GenSide:
	LDA !P2Invinc : BNE CompareY_Return
	LDA #$08 : JSR DontInteract
	BRA Hurt

CompareY:
	STA $00
	STZ $01
	LDA $3240,x
	XBA
	LDA $3210,x
	REP #$20
	SEC : SBC !P2YPosLo
	BPL $03 : LDA #$0000
	CMP $00
	SEP #$20

	.Return
	RTS


SUB_HORZ_POS:
	LDY #$00
	LDA !P2XPosLo
	SEC : SBC $3220,x
	LDA !P2XPosHi
	SBC $3250,x
	BPL $01 : INY
	RTS

	.Rev
	LDY #$01
	LDA !P2XPosLo
	SEC : SBC $3220,x
	LDA !P2XPosHi
	SBC $3250,x
	BPL $01 : DEY
	RTS


DontInteract:
	STA $00				; > Preserve value
	LDA !CurrentPlayer : BNE .P2	;\
.P1	LDA $00 : STA $32E0,x		; |
	RTS				; | Set proper "don't interact" registers
.P2	LDA $00 : STA $35F0,x		; |
	RTS				;/


Hurt:
	JMP HURT


Bounce:
	LDY !P2Character		;\
	LDA .BounceSpeed,y		; |
	BIT !P2YSpeed : BPL +		; | set Y speed
	CMP !P2YSpeed : BCS ++		; |
+	STA !P2YSpeed			;/
++	STZ !P2SenkuUsed		; > reset air Senku
	RTS

.BounceSpeed	db $FF,$C0,$A8,$A8,$00,$00	; Mario, Luigi, Kadaal, Leeway, Alter, Peach



StompSFX:
	LDA !P2KillCount
	CMP #$06
	BEQ $03 : INC !P2KillCount
	TAY
	LDA STOMPSOUND_TABLE,y
	STA !SPC1
	RTS


ContactGFX:
	STA $00
	STZ $01
	STY $02
	STZ $03
	LDA $00
	BPL $02 : DEC $01
	LDA $02
	BPL $02 : DEC $03
	LDA !P2Offscreen
	BNE .Return
	LDY #!Ex_Amount-1
-	LDA !Ex_Num,y : BEQ +
	DEY : BPL -
	RTS
+	LDA #$02+!SmokeOffset : STA !Ex_Num,y	; > Smoke type
	LDA !P2XPosLo				;\
	CLC : ADC $00				; | Smoke Xpos lo
	STA !Ex_XLo,y				;/
	LDA !P2XPosHi				;\
	ADC $01					; | Smoke Xpos hi
	STA !Ex_XHi,y				;/
	LDA !P2YPosLo				;\
	CLC : ADC $02				; | Smoke Ypos lo
	STA !Ex_YLo,y				;/
	LDA !P2YPosHi				;\
	ADC $03					; | Smoke Ypos hi
	STA !Ex_YHi,y				;/
	LDA #$08 : STA !Ex_Data1,y		; > Smoke timer

	.Return
	RTS


BashKill:
	LDA #$02 : STA $3230,x
	LDA #$08
	STA $00
	STA $01
	LDA #$03 : STA !SPC1
	BRA ContactGFX


Crush:
	LDA #$04 : STA $3230,x		;\ Crush sprite
	LDA #$1F : STA $32D0,x		;/
	LDA #$08 : STA !SPC1		; > Crush SFX
	RTS				; > Return


StarKill:
	LDA #$02 : STA $3230,x
	LDA $78D2
	CMP #$07
	BEQ $03 : INC $78D2
	TAY
	DEY
	LDA STOMPSOUND_TABLE,y
	STA !SPC1
	RTS


LuigiKick:
	LDA !P2Character
	CMP #$01 : BNE .Return
	LDA #$08 : STA !P2Kick
	STZ !P2AnimTimer
.Return	RTS


LuigiCarry:
	TXA
	INC A
	STA !P2Carry
	LDA #08 : STA !P2PickUp

.Return	RTS





; This should be a fairly standard interaction. The only deviation from the norm is the kick, which can be performed
; while sprite B is lying face down.

	INT_01:
		LDX $7695
		LDA $3230,x
		CMP #$08			; Only process interaction if sprite B status = 08
		BEQ .Process
.Return		RTS

.Process	LDA $7490			;\ Close enough to branch
		BNE StarKill			;/

.NoStar		LDA $3420,x			;\ Check if sprite is stunned
		BEQ .NoKick			;/
		LDA #$03 : STA !SPC1		; > Kick sound
		LDA #$02 : STA $3230,x		; > Status = knocked out
		LDA #$E8 : STA $9E,x		; > Knock it up a bit
		JMP LuigiKick			; kick if Luigi

.NoKick		LDA #$04 : JSR CompareY
		BCS .Top

.Side		LDA !P2Invinc			;\
		ORA $32B0,x			; | Don't interact if these are set
		ORA $3420,x			; |
		BNE .Return			;/
		LDA #$08 : JSR DontInteract	; > Set don't interact timer
		JMP Hurt			; > Hurt player

.Top		LDA #$30 : STA $32D0,x		; > Set sprite smushed timer to #$30 frames
		LDA #$03 : STA $3230,x		; > Set sprite status to smushed
		JMP GenJump


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KOOPA_XSPEED:	db $3F,$C0
		db $32,$CE

KICK_DISP:	db $10,$F0

;SOURCE: GeneralResetSpr ($0196E1 in all.log)


;SHELLESS KOOPA RAM USAGE:
;
;	$00C2,x			; The Koopa (the one WITH the shell) uses this as a timer
;	$3230,x			; Status is 08 (normal) the entire time
;	$3280,x			; Unused
;	$3290,x			; Unused
;	$32A0,x			; Briefly set to 20 when the koopa slides out of the shell, set to 01 when it gets up from the ground
;	$32B0,x			; Set to 16 while the koopa is sliding
;	$32C0,x			; Briefly set to 20 when the koopa slides out of the shell
;	$32D0,x			; Used as a stun-timer (CAN YOU IMAGINE!?), starts at 16
;	$32E0,x			; Unused
;	$32F0,x			; Unused
;	$3300,x			; Used as a timer (same as $32D0,x?)
;	$3310,x			; Timer for how long the koopa will remain lying on the ground, set to 1 while it is sliding
;	$3320,x			; Sprite direction, does not reset when sprite dies
;	$3340,x			; Set to 06 when the koopa enters a shell, not reset when it dies
;	$3350,x			; Briefly set to 20 when the koopa slides out of the shell
;	$3360,x			; Set to 8 when sprite walks into a wall, then decrements until it hits 0
;	$33A0,x			; Seemingly unused
;	$33D0,x			; Seems to be an index for a graphics table
;	$33E0,x			; Briefly set to 20 when the koopa slides out of the shell
;	$3420,x			; A timer that starts at 255 when the koopa stops sliding, set to 0 when the koopa gets up from the ground and never finishes

	INT_02:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BCC .Return
		CMP #$0B : BCC .Process
.Return		RTS					; Return if sprite B status is greater than 0x0A

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA $3230,x
		CMP #$08 : BEQ .Normal
		CMP #$09 : BEQ .Stunned

.Kicked		LDA #$06 : JSR CompareY
		BCS $03 : JMP .Side
		JMP .TopKicked

.Stunned	LDA $3200,x				;\
		CMP #$A2				; | Check for Mecha Koopa
		BNE .Kick				;/
.Mecha		JSR INT_04_Stunned			;\
		LDA #$FF				; | Mecha Koopa routine
		STA $32D0,x				; |
		RTS					;/

.Kick		LDA !CurrentPlayer			;\
		INC A					; | Specify owner
		STA $34F0,x				;/
		LDA #$03 : STA !SPC1			; > Kick sound
		LDA #$18 : JSR DontInteract		; > Set don't interact timer
		LDA #$0A : STA $3230,x			; > Status: kicked

		JSR SUB_HORZ_POS_Rev			;\
		TYA : STA $3320,x			; |
		LDA KOOPA_XSPEED+2,y : STA $AE,x	; | Send sprite to the side
		LDA KICK_DISP,y				; |
		LDY #$00				; |
		JSR ContactGFX				;/
		JMP LuigiKick				; Luigi kick

.Side		LDA !P2Invinc : BNE .Return
		JSR Hurt
		LDA #$08 : JMP DontInteract

.Normal		LDA #$06 : JSR CompareY
		BCC .Side

.Top		LDA $3200,x
		CMP #$08 : BCS .TopKicked

		JSL $02A9DE			; Get new sprite number into Y
		BMI .TopKicked			; If there are no empty slots, don't spawn

		LDA $3200,x
		SEC : SBC #$04
		STA $3200,y			; Store sprite number for new sprite
		LDA #$08 : STA $3230,y		; > Status: normal
		LDA $3220,x			;\
		STA $3220,y			; |
		LDA $3250,x			; |
		STA $3250,y			; | Set positions
		LDA $3210,x			; |
		STA $3210,y			; |
		LDA $3240,x			; |
		STA $3240,y			;/
		PHX				;\
		TYX				; | Reset tables for new sprite
		JSL $07F7D2			; |
		PLX				;/
		LDA #$10			;\
		STA $32B0,y			; | Some sprite tables that SMW normally sets
		STA $32D0,y			; |
		LDA #$01 : STA $3310,y		;/

		TYX				;\
		LDA #$10 : JSR DontInteract	; | Temporarily disable player interaction for new sprite
		LDX $7695			;/
		LDA $3430,x			;\ Copy "is in water" flag from sprite
		STA $3430,y			;/
		LDA #$02 : STA $32D0,y		;\ Some sprite tables
		LDA #$01 : STA $30BE,y		;/

		PHY				;\
		JSR SUB_HORZ_POS_Rev		; |
		TYA				; |
		PHX				; | Have new sprite face away from player
		STA $3320,y			; |
		TAX				; |
		LDA KOOPA_XSPEED,x		; |
		PLX				; |
		PLY				; |
		STA $30AE,y			;/
		BRA +

.TopKicked	LDA $3200,x			;\
		CMP #$07 : BNE +		; | Shiny shell reacts differently
		LDA #$02 : STA !SPC1		; |
		BRA ++				;/
	+	LDA #$09 : STA $3230,x		; > Stun sprite
		LDA $3200,x			;\
		CMP #$08			; | Check if sprite is a Koopa
		BCC .DontStun			;/
		LDA #$FF : STA $32D0,x		; > Stun if not

.DontStun	LDA #$08 : JSR DontInteract	; Prevent interaction
		JSR StompSFX			; Play enemy stomp sound

		STZ $9E,x			; Yspeed = 0x00
		STZ $AE,x			; Xspeed = 0x00
	++	LDA #$00
		LDY #$08
		JSR ContactGFX
		JMP Bounce


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PARAKOOPACOLOR:	db $04,$04,$05,$05,$07		; This table determines what sprite the parakoopa will turn into

	INT_03:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA $3200,x			; Load sprite number
		SEC : SBC #$08			; Subtract base number of Parakoopa sprite numbers
		TAY
		LDA PARAKOOPACOLOR,y		; Load new sprite number
		STA $3200,x			; Set new sprite number
		LDA #$08 : STA $3230,x		; > Don't run INIT
		LDA #$08 : JSR DontInteract	; > Set "don't interact"-timer for sprite
		JMP GenJump


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BOBOMBXSPEED:	db $2C,$D4

	INT_04:
		LDX $7695
		LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA $3440,x : BEQ .Side		; Branch if sprite b is exploding
		LDA $3230,x
		CMP #$09 : BEQ .Stunned
		CMP #$08 : BEQ .Normal
.Return		RTS

.Stunned	LDA #$03 : STA !SPC1		; > Kick shell sound
		LDA #$40 : STA $32D0,x		; > Set stun timer

		JSR LuigiKick			; Luigi kick

		JSR SUB_HORZ_POS_Rev
		LDA BOBOMBXSPEED,y
		STA $AE,x
		LDA #$10 : JMP DontInteract

.Side		JMP GenSide

.Normal		LDA #$06 : JSR CompareY
		BCC .Side

		LDA #$08 : JSR DontInteract	; > Prevent interaction
		LDA $3200,x
		CMP #$40 : BEQ .ParaBomb
		LDA #$09			;\
		STA $3230,x			; | Regular Bobomb code (stuns it)
		BRA .Shared			;/

.ParaBomb	LDA #$0D : STA $3200,x		; > Sprite = Bobomb
		LDA #$01 : STA $3230,x		; > Initialize sprite
		JSL $07F7D2			; > Reset sprite tables

.Shared		STZ $9E,x			; Yspeed = 0x00
		STZ $AE,x			; Xspeed = 0x00
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GOOMBAXSPEED:	db $2C,$D4

	INT_05:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Normal
		CMP #$09 : BEQ .Stunned
.Return		RTS

.Stunned	LDA $7490 : BEQ .NoStar
.Star		JMP StarKill

.NoStar		LDA #$03 : STA !SPC1		; > Kick enemy sound
		JSR LuigiKick			; Luigi kick
		JSR SUB_HORZ_POS_Rev
		LDA GOOMBAXSPEED,y
		STA $AE,x
		LDA #$F0 : STA $9E,x		; > Y speed
		LDA #$FF : STA $32D0,x		; > Stun sprite
		LDA #$10 : JMP DontInteract	; > Prevent some interaction

.Normal		LDA $7490 : BNE .Star

		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$08 : JSR DontInteract	; > Prevent interaction
		LDA #$09 : STA $3230,x
		LDA #$FF : STA $32D0,x
		STZ $9E,x			; Yspeed = 0x00
		STZ $AE,x			; Xspeed = 0x00
		JMP GenJump


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_06:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$08 : JSR DontInteract	; > Prevent interaction

		LDA #$06 : JSR CompareY
		BCS .Top

.Side		LDA !P2Invinc : BNE .Return
		JMP Hurt

.Top		LDA #$0F : STA $3200,x		; Set new sprite number
		LDA #$01 : STA $3230,x		; Initialize sprite
		JSL $07F7D2			; Reset sprite tables
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_07:
		LDX $7695			;\
		LDA !NewSpriteNum,x		; | Check for custom projectile
		CMP #$05			; |
		BNE .NoCustomShot		;/
		LDA $BE,x			;\ Don't destroy unless fireball
		BNE .NoCustomShot		;/
		LDA #$04			;\
		STA $3230,x			; |
		LDA #$1F			; | Destroy custom projectile
		STA $32D0,x			; |
		JSR DontInteract		;/
.NoCustomShot	LDA !P2Invinc			;\ Don't hurt player 2 while invulnerable
		BNE .Return			;/
		JMP Hurt			; > Hurt player
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_08:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA $3200,x
		CMP #$18 : BEQ .Water
		LDA $3430,x : BNE .Water
		LDA #$03 : STA !SPC1		; > Kick enemy sound
		LDA #$02 : STA $3230,x		; > Sprite status: knocked out
		JMP LuigiKick			; Luigi kick

.Water		JMP GenSide

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_09:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$10 : JSR DontInteract
		LDA #$02 : STA $3230,x		; Status: knocked out
		STZ $9E,x			; Yspeed = 0x00
		STZ $AE,x			; Xspeed = 0x00
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0A:
		LDX $7695
		LDA #$08 : JSR CompareY
		BCS $03 : JMP INT_0D_Side	; > Solid on the side
		JMP INT_0F_Main			; > Platform if touching on top

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0B:
		LDX $7695
		STZ $3230,x
		JSR SET_GLITTER
		LDA $3210,x : STA !Ex_YLo,y
		LDA $3220,x : STA !Ex_XLo,y
		LDA #$01 : STA !SPC4		; Play "collect coin"-sound
		LDA $3200,x
		CMP #$7E : BEQ .5		; check for flying red coin
		LDA !ExtraBits,x
		AND #$04 : BEQ .1

	.100	LDA !CurrentPlayer
		TAX
		LDA !P1CoinIncrease,x
		CLC : ADC #$64			; worth 100 coins with extra bit
		STA !P1CoinIncrease,x
		RTS

	.5	LDA !CurrentPlayer
		TAX
		LDA !P1CoinIncrease,x
		CLC : ADC #$05
		STA !P1CoinIncrease,x
		RTS

	.1	LDA !CurrentPlayer		;\
		TAX				; | Increase coins
		INC !P1CoinIncrease,x		;/
		RTS				; > Just return since sprite index will be reloaded anyway

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0C:
		LDX $7695
		LDA $3410,x : BNE .Return	; Don't process interaction while sprite B is behind scenery
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$05 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$02 : STA $3230,x		; > Status: knocked out
		STZ $9E,x
		STZ $AE,x
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0D:
		LDX $7695
		LDA $3230,x
		CMP #$0B : BEQ .Return
		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JSR SUB_HORZ_POS_Rev
		TYA : INC A
		TSB !P2Blocked
		LDA !P2XSpeed
		AND #$80
		CMP.w .SpeedBit,y
		BNE .Return
		STZ !P2XSpeed
		RTS

.Top		BIT !P2YSpeed : BMI .Return
		LDA $3200,x
		CMP #$3E : BEQ .POW

		LDA !CurrentPlayer : BNE .P2
.P1		LDA $3360,x : BNE .Return
		LDA #$11 : STA $3360,x		; > Process player 1 PCE interaction
		BRA +
.P2		LDA $3420,x : BNE .Return
		LDA #$11 : STA $3420,x		; > Process player 2 PCE interaction
	+	LDA #$08 : STA !SPC4		; > Play springboard sound
.Return		RTS

.POW		LDA $3230,x
		CMP #$09 : BNE .Return
		LDA $3420,x : BNE .Return
		STZ !P2YSpeed
		LDA #$1F : STA $3420,x		; > Push P switch
		JSR DontInteract		; > Disable interaction
		LDA #$0B : STA !SPC1		; > Switch sound
		LDA #$0E : STA !SPC3		; > Switch music

		LDA $33C0,x
		CMP #$02 : BEQ .Silver
		LDA #$B0 : STA $74AD		; > P timer
		RTS

.Silver		LDA #$B0 : STA $74AE		; > Silver timer
		RTS

.SpeedBit	db $00,$80

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SKELETON_HITBOX:	db $06,$04,$06

	INT_0E:
		LDX $7695
		LDA $32C0,x : BNE INT_0D_Return
		LDA $3230,x
		CMP #$08 : BNE INT_0D_Return
		LDA $3200,x			;\
		CMP #$31 : BNE .Process		; | Always get hurt when touching Bony Beetle with spikes out
		LDA $32D0,x : BEQ .Process	; |
		CMP #$6E : BCC .Side		;/

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA $3200,x
		SEC : SBC #$30
		TAY
		LDA SKELETON_HITBOX,y
		JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$01 : STA $32C0,x
		LDA #$FF : STA $32D0,x
		LDA #$07 : STA !SPC1
		JMP GenJump_NoSFX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_0F:
		LDX $7695
		LDA #$08 : JSR CompareY
		BCC .Return			; Don't interact if touching from side

.Main		BIT !P2YSpeed			;\ Return if going up
		BMI .Return			;/

	; MIGHT HAVE TO ADD A SPEED COMPARISON HERE!!!

		LDA !P2Platform
		BMI .Return			; Return if priority bit is set
		STX !P2Platform			; tttt bits = platform index

		LDA $3210,x			;\
		SEC : SBC #$0E			; |
		STA !P2YPosLo			; | Player 2 Ypos = solid sprite Ypos - 14
		LDA $3240,x			; |
		SBC #$00			; |> This subtracts 01 if carry is clear
		STA !P2YPosHi			;/
		LDA #$04			;\ Set player 2 blocked from beneath
		TSB !P2Blocked			;/
		LDA $3200,x			;\
		CMP #$57 : BEQ .Vertical	; | Check for vertical platforms
		CMP #$58 : BEQ .Vertical	;/
		CMP #$BA : BEQ .Timed
		CMP #$5B : BEQ .Floating
		CMP #$C4 : BEQ .Falling
		CMP #$61 : BNE .RetRet
		LDA #$0C : STA $78BC		; start skull raft
		REP #$20
		INC !P2YPosLo
		INC !P2YPosLo
		SEP #$20

.RetRet		RTS

.Vertical	LDA #$40			;\ Direction = vertical
		TSB !P2Platform			;/
		RTS

.Timed		LDA #$01			;\
		STA $32B0,x			; |
		LDA #$10			; | Start plaform (source: $038DBB in all.log)
		STA $BE,x			; |
		STA $AE,x			;/
		RTS

.Return		STZ !P2Platform			; Reset pd--iiii
		RTS

.Floating	LDA !P2PrevPlatform
		BNE .RetRet
		LDA !P2YSpeed
		CMP #$20 : BCC .RetRet
		LSR A
		STA $9E,x
		INC $32A0,x
		RTS

.Falling	LDA $9E,x : BNE .RetRet
		LDA #$03 : STA $9E,x
		LDA #$18 : STA $32D0,x
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


CHUCK_PUSH:	db $20,$E0

	INT_10:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process		; Only interact if status is normal
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$0C : JSR CompareY
		BCS .Top

.Side		JSR GenSide

.Top		LDA #$05 : JSR DontInteract	; > Prevent interaction
		LDA #$02 : STA !SPC1		; > Spin jump on spiky sound
		JSR GenJump_NoSFX

		STZ $3420,x			; Reset unknown sprite table
		LDA $BE,x			;\
		CMP #$03			; |
		BEQ .Return			;/> Return if sprite is still recovering from a stomp
		INC $32B0,x			; Increment sprite stomp count
		LDA $32B0,x
		CMP #$03 : BCS .Kill
		LDA #$28 : STA !SPC4		; Enemy stomp sound
		LDA #$03 : STA $BE,x		; Stun sprite
		LDA #$03 : STA $32D0,x		; Set sprite stunned timer to 3 frames
		STZ $3310,x			; Reset follow player timer
		JSR SUB_HORZ_POS
		LDA CHUCK_PUSH,y
		STA !P2XSpeed
		RTS

.Kill		STZ $9E,x			; Reset sprite Y speed
		STZ $AE,x			; Reset sprite X speed
		LDA #$02 : STA $3230,x		; Status: knocked out
		LDA #$03 : STA !SPC1		; Kicked shell sound
		JMP LuigiKick			; Luigi kick

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_11:
		LDX $7695			; > X = goal sprite index
		JSL $00FA80			; > Run goal sprite code
		STZ $3230,x			; > Erase goal sprite
		STZ $71				; > Clear Mario animation
		STZ $7490			; > Clear star timer
		LDA $3200,x			;\
		CMP #$4E			; | I don't know if this is necessary, might be
		BNE .NoSphere			;/
		BRA .NoSecret			; > Spheres don't activate secrets
.NoSphere	LDA $34A0,x			;\
		LSR #2				; | Set secret exit flag
		STA $741C			;/
.NoSecret	LDA #$04 : STA !SPC3		; > Change music
		LDA #$FF			;\
		STA $6DDA			; | Set music backup and end level timer
		STA $7493			;/
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_12:
		LDX $7695			; X = sprite index
		LDA $3230,x
		CMP #$08 : BNE .Return		; Only interact if sprite status is normal
		LDA $BE,x : BEQ .Return		;\ Only interact if sprite has emerged from the ground
		LDA $32D0,x : BEQ .Process	;/
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$02 : STA $3230,x		; Status: knocked out
		STZ $9E,x			; Yspeed = 0x00
		STZ $AE,x			; Xspeed = 0x00
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	DINO_HITBOX:	db $14,$06

	INT_13:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA $3200,x
		SEC : SBC #$6E
		TAY
		LDA DINO_HITBOX,y
		JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		LDA $3200,x
		CMP #$6E : BEQ .Large

.Small		LDA #$03 : STA $3230,x		;\ Status: smushed for 48 frames
		LDA #$30 : STA $32D0,x		;/
		BRA .Shared

.Large		LDA #$6F : STA $3200,x		; Sprite num
		LDA #$01 : STA $3230,x		; Init sprite
		JSL $07F7D2			; Reset sprite tables
		LDA #$02 : STA $BE,x		; Action: fire breath up

.Shared		STZ $9E,x
		STZ $AE,x
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_14:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		TDC : JSR CompareY		; A = 0x00
		BCS .Top

.Side		JMP GenSide

.Top		LDA #$02 : STA $3230,x		; Status: knocked out
		STZ $9E,x
		STZ $AE,x
		JMP GenJump

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	REX_HITBOX:	db $06,$06

	INT_15:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BNE .Return
		LDA $32F0,x : BEQ .Process	; Return if smush timer is set
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$06 : JSR CompareY
		BCS .Top

.Side		JMP GenSide

.Top		BIT $3280,x : BVC .NoChase	;\
		BIT $3340,x : BVS .NoChase	; |
		LDA !CurrentPlayer		; |
		CLC : ROL #4			; | Aggro off of being hit
		ORA #$40			; |
		ORA $3340,x			; |
		STA $3340,x			;/

.NoChase	LDA $3280,x			;\ Check for brute
		AND #$04 : BEQ .NotAggro	;/

.Aggro		LDA $35D0,x : BNE .Invinc
		LDA #$40 : STA $35D0,x		; Set invinc
		LDA $BE,x
		INC A
		STA $BE,x
		CMP #$03
		BCS .Small
		LDA #$18 : STA $34D0,x
		LDA #$20 : STA !SPC1
		BRA .End

.Invinc		LDA #$02 : STA !SPC1		; Just use contact SFX if invinc
		BRA .End

.NotAggro	LDA $BE,x
		BNE .Small

.Large		LDA #$01 : STA $BE,x		; Number of hits taken
		LDA #$0C : STA $34D0,x		; Half smush timer
		LDA $3280,x			;\
		AND.b #$08^$FF			; | Clear movement disable
		STA $3280,x			;/
		BRA .Shared

.Small		LDA #$02 : STA $BE,x		; Number of hits taken
		LDA #$1F : STA $32F0,x		; Smush timer
		LDA #$0C : STA $33D0,x		; Animation index
		STZ $3310,x			; Animation timer

.Shared		JSR StompSFX

.End		LDA #$08 : JSR DontInteract	; Prevent interaction
		LDA #$00
		LDY #$08
		JSR ContactGFX
		JMP Bounce

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_16:
		LDX $7695
		LDA $33D0,x : BEQ .Hurt

		LDA #$08 : JSR CompareY
		BCC .ReturnPlat			; Don't interact if touching from side

	; MIGHT NEED A SPEED COMPARISON HERE!!!

		BIT !P2YSpeed
		BMI .ReturnPlat
		STX !P2Platform			; tttt bits = platform index
		LDA $3210,x			;\
		SEC : SBC #$0D			; |
		STA !P2YPosLo			; | Player 2 Ypos = solid sprite Ypos - 14
		LDA $3240,x			; |
		SBC #$00			; |> This subtracts 01 if carry is clear
		STA !P2YPosHi			;/
		LDA #$04 : TSB !P2Blocked	; > Set player 2 blocked from beneath
		RTS

.Hurt		JMP Hurt

.ReturnPlat	STZ !P2Platform			; Reset pd--iiii
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	CARROT_PLAT1:		db $20,$1E,$1C,$1A,$18,$16,$14,$12
				db $10,$0E,$0C,$0A,$08,$06,$04,$02
				db $00,$00,$00,$00,$00,$00,$00,$00

	INT_17:
		LDX $7695
		LDA #$08 : JSR CompareY
		BCC .Return
		BIT !P2YSpeed
		BMI .Return
		STX !P2Platform			; iiii -bits = platform index

		LDA $3250,x
		XBA
		LDA $3220,x
		REP #$20
		SEC : SBC !P2XPosLo
		EOR #$FFFF : INC A
		CLC : ADC #$0004
		SEP #$20
		BCC .Pos
.Neg		LDA #$00			; Don't accept negative values
.Pos		LSR A
		TAY
		LDA CARROT_PLAT1,y
		CLC : ADC $3210,x
		STA !P2YPosLo
		LDA $3240,x
		ADC #$00
		STA !P2YPosHi
		REP #$20
		LDA !P2YPosLo
		SEC : SBC #$0010
		STA !P2YPosLo
		SEP #$20
		LDA #$04 : TSB !P2Blocked	; > Set player 2 blocked from beneath
.Return		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_18:
		LDX $7695
		LDA $3230,x
		CMP #$08 : BEQ .Process
.Return		RTS

.Process	LDA $7490 : BEQ .NoStar
		JMP StarKill

.NoStar		LDA #$14 : JSR CompareY
		BCS .Top

.Side		JMP Hurt

.Top		BIT !P2YSpeed
		BMI .Return
		STX !P2Platform
		LDA $3210,x
		SEC : SBC #$1A
		STA !P2YPosLo
		LDA $3240,x
		SBC #$00
		STA !P2YPosHi
		LDA #$04 : TSB !P2Blocked
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_19:
		RTS				; > Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_1A:
		LDX $7695
		LDA $32D0,x : BEQ .Process
		RTS

		.Process
		STZ $01				; > Don't include kill count
		STZ $3230,x			; Erase powerup
		LDA $3200,x
		CMP #$78 : BEQ .1UP		; > Branch if 1-up
		CMP #$7F : BEQ .1UP
		CMP #$76 : BNE .Powerup		; > Branch unless star
		LDA #$FF : STA $7490		; > Set star timer
		BRA .Shared

.Powerup	LDA !P2HP			;\
		CMP #$03			; | Give HP
		BCS .Shared			; |
		INC !P2HP			;/

.Shared		LDA #$0A : STA !SPC1
		RTS

.1UP		LDA #$0D : STA $00
		LDA !P2MaxHP : STA !P2HP	; Full heal
		LDA !CurrentPlayer		;\
		TAY				; | Increase coins
		LDA !P1CoinIncrease,y		; |
		CLC : ADC #$64			; |
		STA !P1CoinIncrease,y		;/
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_1B:
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	INT_1C:
		LDX $7695
		LDA $3280,x
		AND #$03
		CMP #$01 : BEQ .Process
		RTS

.Process	LDA #$08 : JSR CompareY
		BCS .Top
		JMP Hurt

.Top		LDA $BE,x
		AND #$0F
		ORA #$C0
		STA $BE,x
		LDA #$0C : JSR DontInteract
		JMP GenJump



;===================;
;GET_SPRITE_CLIPPING;
;===================;
;This routine checks for contact with other sprites. If there is contact, offsets will be stored to scratch RAM.
;interaction value will be stored to $00.

;$00: Low byte of sprite B's clipping X displacement. If contact is detected, interaction number is stored here.
;$01: Low byte of sprite B's clipping Y displacement.
;$02: Sprite B's clipping width.
;$03: Sprite B's clipping height.
;$04: Low byte of sprite A's clipping X displacement.
;$05: Low byte of sprite A's clipping Y displacement.
;$06: Sprite A's clipping width.
;$07: Sprite A's clipping height.
;$08: High byte of sprite B's clipping X displacement.
;$09: High byte of sprite B's clipping Y displacement.
;$0A: High byte of sprite A's clipping X displacement.
;$0B: High byte of sprite A's clipping Y displacement.
;$0C: $08-$0A
;$0D:
;$0E:
;$0F: $04+$06-$00

;			   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			|
;	LO NYBBLE	   |YY0|YY1|YY2|YY3|YY4|YY5|YY6|YY7|YY8|YY9|YYA|YYB|YYC|YYD|YYE|YYF|	HI NYBBLE	|
;	--->		   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |			V

INTERACTION_TABLE:	db $01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$03,$04,$00,$05	;| 00X
			db $06,$02,$00,$07,$07,$08,$08,$00,$08,$00,$00,$09,$09,$07,$09,$09	;| 01X
			db $07,$0B,$0C,$0C,$0C,$0C,$07,$07,$07,$00,$07,$07,$00,$00,$07,$0D	;| 02X
			db $0E,$0E,$0E,$07,$07,$00,$00,$07,$07,$07,$07,$07,$07,$07,$0D,$06	;| 03X
			db $04,$0F,$0F,$0F,$07,$00,$10,$00,$07,$0F,$11,$09,$00,$12,$12,$07	;| 04X
			db $07,$09,$00,$00,$00,$0F,$0F,$0F,$0F,$00,$00,$0F,$0F,$0F,$0F,$00	;| 05X
			db $00,$0F,$0F,$0F,$00,$07,$07,$07,$07,$00,$00,$00,$00,$00,$13,$13	;| 06X
			db $00,$09,$09,$09,$1A,$1A,$1A,$1A,$1A,$00,$00,$11,$00,$00,$0B,$1A	;| 07X
			db $00,$00,$00,$0F,$0F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 08X
			db $00,$10,$10,$10,$10,$10,$00,$10,$10,$07,$07,$09,$0F,$00,$07,$14	;| 09X
			db $00,$07,$02,$00,$07,$07,$07,$00,$07,$07,$07,$15,$00,$00,$07,$16	;| 0AX
			db $07,$00,$07,$07,$07,$00,$07,$17,$17,$00,$0F,$0F,$00,$01,$09,$18	;| 0BX
			db $0F,$00,$07,$07,$0F,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$02,$02,$02,$07,$02	;| 0DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 0FX

			db $00,$00,$15,$15,$15,$15,$1C,$07,$1B,$00,$00,$00,$00,$00,$00,$0A	;| 10X
			db $00,$00,$00,$00,$00,$07,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 11X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 12X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 13X
			db $19,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 14X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 15X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 16X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 17X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 18X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 19X
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1AX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1BX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1CX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1DX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1EX
			db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| 1FX


