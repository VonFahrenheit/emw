;
; this sprite uses two extra bytes that should be set when the sprite is placed with lunar magic
; extra byte 1: color
;		00 - green
;		01 - red
;		02 - blue
;		03 - yellow
; extra byte 2: spawn state
;		---- xxxx
;		00 - normal
;		01 - empty shell
;		02 - naked
;		03 - naked, sliding on slope (like vanilla blue koopa)
;		04 - normal, winged
;		05 - winged shell
;		06 - naked, winged
;		07 - unused
;		08 - special, slide out of shell
; this sprite also uses the extra bit
; setting the extra bit enables that version's alternate behavior
; this uses the second column in the color settings defines


;
; programmer notes for future modification
;	capearmor inserts a conditional at CheckFireballs, a routine that is called for all sprite states that are able to interact
;	firearmor inserts a conditional at CheckFireballs, after fireballs touching the sprite have been destroyed
;	shellarmor inserts a conditional at Interaction_NoContact, altering what happens when the sprite is hit by a thrown object
;	spinarmor inserts a conditional at CheckStomp and Interaction_Stationary
;	stararmor inserts a conditional at CheckStomp and Interaction_Stationary
;	rainbowcape changes a CMP in CheckFireballs
;	rainbowfire inserts a conditional in CheckFireballs
;	yoshifireballs changes a pretty big chunk of code in CheckFireballs
;
; NOTE: red yoshi does not work with this sprite, as it will transform the giga shell into 3 fireballs before the shell has a chance to revert back to normal
;	a method that directly writes to yoshi's regs also does not work due to spawn/index ordering being very inconsistent
;	because of this, i went with the method that only fails with red yoshi
;	if you want a perfect solution you'll need a patch or uberasm code. to support this i added the !yoshipowers toggle, set that to 0 if you want an external source to handle powers
;

; extra prop 1 determines what to do in yoshi's mouth
;	it is set to 0x00 at spawn
;	it is set to a backup of yoshi's' CCC bits when the sprite is inside yoshi's mouth
;	when the sprite leaves yoshi's mouth, it refreshes his CCC bits
;	highest bit signals that it's a rainbow shell


	; sprite tables

	!movementflags	= $BE
		; format:
		; lfffnnss
		; l - ledge flag
		; f - flight pattern
		; n - naked pattern
		; s - shell pattern
	!attackflags	= $3280
		; format:
		; csssssss
		; c - chase
		; s - shove power

	!coins		= $3290			; how many coins the sprite has
	!state		= $32A0			; used to cheat smw's state system
						; 0 = normal
						; 1 = shell, stationary
						; 2 = shell, carried
						; 3 = shell, kicked
						; 4 = shell, freefall
						; 5 = shell, rainbow power
						; 6 = naked
						; 7 = naked, sliding (out of shell)
						; 8 = jumping (end of slide)
						; 9 = naked, sliding on slope
						; A = smushed
						; B = dead shell (similar to sprite state 02)
						; C = normal, flying

	!hp		= $32B0			; starts at 0 and counts up, used for fireball health
	!flipped	= $32C0			; nonzero means that the sprite is upside down, used with cape spin
	!turntimer	= $32D0			; while nonzero, sprite can not turn to face the player
	!batteringtimer	= $34E0			; set to 128 each time the shell is used as a battering ram, if it hits 0 the kill count is reset
	!flytimer	= $34F0			; 

	; 3500 used for spawned sprite

	!Map16ActsLike	= $06F624|!BankB	; don't change this, just set !actslike to 0 if you don't want to use it


	; toggles
	!actslike	= 1			; 0 = use raw map16 numbers, 1 = use acts like setting
	!score		= 1			; 0 = no score when jumping on sprite, 1 = score when jumping on sprite
	!breakblocks	= 1			; 0 = shell does not break blocks, 1 = shell breaks blocks listed in BreakableTiles
	!priority	= 0			; 0 = shell retains color when fusing, 1 = naked koopa retains color when fusing
	!spawnnaked	= 1			; 0 = does not spawn naked koopa, 1 = spawns naked koopa


	!matchingbonus	= 1			; 0 = no match bonus, 1 = if yoshi has a giga shell that matches his color, he gets all shell powers (unless he's green)
	!rainbowbonus	= 1			; 0 = giga rainbow shell gives all powers, 1 = giga rainbow shell also gives the player star power

	!capearmor	= 1			; 0 = koopa is knocked out by cape, 1 = koopa laughs at your pitiful cape
						; note: shell can always be caped, this toggle affects big koopa and shelless koopa
	!firearmor	= 1			; 0 = koopa takes damage from fireballs, 1 = koopa pities your weak flames
	!shellarmor	= 1			; 0 = koopa is knocked out by shells, 1 = koopa tanks them shells
	!spinarmor	= 1			; 0 = koopa is crushed by spin jumps, 1 = spin jumps work like normal jumps
	!stararmor	= 0			; 0 = koopa dies to star, 1 = koopa has went even further beyond

	!rainbowcape	= 0			; 0 = rainbow shell can not be caped, 1 = rainbow shell can be caped
	!rainbowfire	= 0			; 0 = rainbow shell immune to fire, 1 = rainbow shell affected by fire (requires !firearmor to be set to 0)

	!yoshifireballs	= 1			; 0 = ignore yoshi fireballs, 1 = interact with yoshi fireballs in the same way as mario fireballs
	!yoshipowers	= 1			; 0 = no yoshi powers from shells, 1 = yoshi powers from shells (does not work with red yoshi)
	!flashred	= 0			; 0 = red not included in rainbow flash, 1 = red included in rainbow flash (breaks compatibility with rainbow shells)

	; numeric defines
	!firehealth	= 5			; how many fireballs are needed to kill koopa, only used if !firearmor is set to 0


	if !breakblocks
	; you can add or remove values from this table, but don't remove any labels!
	; if !breakblocks is enabled, any value entered here (like the dw $0130) will allow the corresponding block to be broken by giga koopa shells
	; use the acts like setting for more options
	; NOTE: this sprite will not interact with ?-blocks like normal shells do, even if you remove those blocks from this list
	; NOTE: !breakblocks must be enabled for shell to interact with triangle blocks and 45 degree slopes
	BreakableTiles:
		dw $0111
		dw $0112
		dw $0113
		dw $0114
		dw $0115
		dw $0116
		dw $0117
		dw $0118
		dw $0119
		dw $011A
		dw $011B
		dw $011C
		dw $011D
		dw $011E
		dw $011F
		dw $0120
		dw $0121
		dw $0122
		dw $0123
		dw $0124
		dw $0125
		dw $0126
		dw $0127
		dw $0128
		dw $0129
		dw $012A
		dw $012B
		dw $012C
		dw $012D
		dw $012E
		dw $0130
		dw $0132
		.End
	endif




;================;
; COLOR SETTINGS ;
;================;
; this is the maini way you customize the different versions of the giga koopa
; if you want something other than the default behaviors, you should carefully go through this section
; variables should be explained pretty well, but feel free to experiment!

			; speed, unit is 1/16th px per frame (same as all smw sprites)
			; speed1 is for walking/normal state
			; speed2 is for flight (note that flight pattern determines how this value is used)
			; speed3 is for naked/shelless state
			; speed4 is for kicked shell and naked sliding states
			; first value is for extra bit clear, second value is for extra bit set
	!green_speed1	= 16,32
	!red_speed1	= 16,32
	!blue_speed1	= 24,48
	!yellow_speed1	= 24,48

	!green_speed2	= 16,16
	!red_speed2	= 28,28
	!blue_speed2	= 24,24
	!yellow_speed2	= 24,48

	!green_speed3	= 16,32
	!red_speed3	= 16,32
	!blue_speed3	= 24,32
	!yellow_speed3	= 24,48

	!green_speed4	= 48,48
	!red_speed4	= 48,48
	!blue_speed4	= 48,48
	!yellow_speed4	= 48,48

			; 0 = walk off ledges, 1 = turn around at ledges (with and without extra bit, respectively)
	!green_ledge	= 0,0
	!red_ledge	= 1,1
	!blue_ledge	= 1,1
	!yellow_ledge	= 0,0

			; 0 = walk forward, turn at walls (and ledges if enabled), 1 = chase player
	!green_chase	= 0,0
	!red_chase	= 0,0
	!blue_chase	= 0,0
	!yellow_chase	= 1,1

			; shove power of koopa in big form (with and without extra bit, respectively)
			; if nonzero, the koopa will shove mario upon contact
			; higher values give a stronger shove, maximum is 127
	!green_shove	= 32,64
	!red_shove	= 0,0
	!blue_shove	= 32,64
	!yellow_shove	= 0,0

			; for flight, each color should have 2 values
			; the first is used with extra bit clear, second is used with extra bit set
			; values are:
			;	- 0: fly horizontally, ignores walls
			;	- 1: bounce, height depends on how high above ground sprite is placed
			;	- 2: fly horizontally back and forth, ignores blocks (max speed = 31, starts by going left)
			;	- 3: fly vertically up and down, ignores blocks (max speed = 31, starts by going up)
			;	- 4: fly clockwise, ignores blocks
			;	- 5: fly counterclockwise, ignores blocks
			;	- 6: chase on feet, use wings to jump and glide
			;	- 7: chase by flight (similar to a phanto), ignores blocks
	!green_flight	= 0,1
	!red_flight	= 2,3
	!blue_flight	= 4,5
	!yellow_flight	= 6,7

			; pattern used for naked koopa
			; values are:
			;	- 0: walk, turn at walls (and ledges if enabled)
			;	- 1: chase player
			;	- 2: move toward nearest shell
	!green_naked	= 0,2
	!red_naked	= 0,2
	!blue_naked	= 0,2
	!yellow_naked	= 1,2

			; how to interact with shells when naked
			; values are:
			;	- 0: can't manipulate, dies to kicked/thrown shells
			;	- 1: enter large shells, use small shells as helmet
			;	- 2: kick large and small shells
			;	- 3: rainbow form in large shells, use small shell as helmet
	!green_shell	= 1,1
	!red_shell	= 1,1
	!blue_shell	= 2,2
	!yellow_shell	= 3,3

			; how many coins each sprite carries
			; when the sprite is knocked out of its shell, it drops its coins
			; max 4, unless you expand the tables under DropCoins
	!green_coins	= 0
	!red_coins	= 0
	!blue_coins	= 0
	!yellow_coins	= 4




;=====================;
; GFX MAPPING OPTIONS ;
;=====================;
; note that sizes can't be easily changed and is not supported
; if you want to change the size of something you'll have to figure that out yourself


	; cheat sheet for easily remapping graphics:
			; tiles 000-07F is SP1
			; tiles 080-0FF is SP2
			; tiles 100-17F is SP3
			; tiles 180-1FF is SP4
	!wing1		= $05D	; 8x8
	!wing2		= $0C6	; 16x16
	; these two are the vanilla wing tiles, don't change them unless you remapped them

	!head1		= $180	; 24x16
	!head2		= $188	; 24x16
	!body1		= $1A0	; 32x32
	!body2		= $1A4	; 32x32
	!body3		= $1A8	; 32x32

	!shell1		= $18C	; 16x24
	!shell2		= $1BC	; 24x24
	!shell3		= $18E	; 16x24

	!small_head1	= $186	; 16x16
	!small_head2	= $1E4	; 16x16
	!small_head3	= $1BF	; 8x24
	!small_head4	= $1D3	; 8x24
	!small_body1	= $183	; 24x16
	!small_body2	= $1E0	; 24x16
	!small_body3	= $1E6	; 24x16
	!small_body4	= $1E9	; 16x16
	!small_legs1	= $1EB	; 16x16
	!small_legs2	= $1ED	; 16x16

	!smushed1	= $18B	; 8x8
	!smushed2	= $19B	; 8x8



;==================;
; MAIN DATA TABLES ;
;==================;

	; don't change anything here, use the defines above instead!
	FlagTable:
	.Ledge		db !green_ledge,!red_ledge,!blue_ledge,!yellow_ledge
	.Chase		db !green_chase,!red_chase,!blue_chase,!yellow_chase
	.Shove		db !green_shove,!red_shove,!blue_shove,!yellow_shove
	.Naked		db !green_naked,!red_naked,!blue_naked,!yellow_naked
	.Shell		db !green_shell,!red_shell,!blue_shell,!yellow_shell
	.Flight		db !green_flight,!red_flight,!blue_flight,!yellow_flight
	SpeedTable:
	.Normal		db !green_speed1,!red_speed1,!blue_speed1,!yellow_speed1
	.Flight		db !green_speed2,!red_speed2,!blue_speed2,!yellow_speed2
	.Naked		db !green_speed3,!red_speed3,!blue_speed3,!yellow_speed3
	.Shell		db !green_speed4,!red_speed4,!blue_speed4,!yellow_speed4
	Palette:
	.Green		db $0A
	.Red		db $08
	.Blue		db $06
	.Yellow		db $04
	Coins:
	.Green		db !green_coins
	.Red		db !red_coins
	.Blue		db !blue_coins
	.Yellow		db !yellow_coins



;====================;
; KOOPA INIT ROUTINE ;
;====================;
; note: INIT and MAIN both have to be called on the first frame, but I still need INIT to be a routine that can be called upon naked shell fusion
; that is why the code is structured this way and the INIT pointer is found below the actual INIT routine
	INIT:
		LDA #$00 : STA !extra_prop_1,x			; sprite is not in yoshi's mouth at spawn

		LDA !extra_byte_1,x
		AND #$03
		TAY
		LDA Palette,y : STA !15F6,x
		LDA Coins,y : STA !coins,x
		TYA
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04
		BEQ $01 : INY
		LDA FlagTable_Chase,y
		ROR #2
		AND #$80
		ORA FlagTable_Shove,y
		STA !attackflags,x
		LDA FlagTable_Ledge,y
		AND #$01
		ASL #3
		ORA FlagTable_Flight,y
		ASL #2
		ORA FlagTable_Naked,y
		ASL #2
		ORA FlagTable_Shell,y
		STA !movementflags,x

		LDA #$FF : STA $3500,x				; there is no owned sprite initially

		JSL SUB_HORZ_POS
		TYA : STA $3320,x
		LDA !extra_byte_2,x
		AND #$0F
		CMP #$03 : BEQ .Slope
		CMP #$08 : BEQ .Slide
		CMP #$04 : BNE .Normal

	.Fly
		LDA !movementflags,x
		AND #$70
		CMP #$20 : BEQ .static
		CMP #$30 : BNE .Normal
	.static	STZ !157C,x
		JSR ReadSpeed_Flight
		ASL #2
		STA !flytimer,x
		LDA #$01 : STA !157C,x
		RTS

	.Slide
		TYA
		EOR #$01
		STA !157C,x
		JSR ReadSpeed_Shell : STA !sprite_speed_x,x
		.Slope
		LDA #$07 : STA !state,x
		LDA #$0D : STA !SpriteAnimIndex
		RTS

	.Normal
		TYA : STA !157C,x

	.Return
		RTS

	print "INIT ", pc
		PHB : PHK : PLB
		JSR INIT
		PLB
	; actual INIT call should flow into MAIN so GFX are displayed properly on the first frame when a level is loaded


;=========================;
; GIGA KOOPA MAIN ROUTINE ;
;=========================;

	print "MAIN ", pc
	MAIN:
		PHB : PHK : PLB					; > start of bank wrapper

		LDA !15D0,x : BEQ .NoTongue			;\
		LDA !state,x : BEQ .NoTongue			; |
		CMP #$06 : BCS .NoTongue			; | shells becomes stationary on yoshi's tongue
		JSR CheckStomp_Stop				; |
		.NoTongue					;/

		LDA !sprite_status,x				;\ special code when sprite is in yoshi's mouth
		CMP #$07 : BEQ .InMouth				;/
		JMP .NotInMouth

	.InMouth
		LDA #$80 : TSB $18AC|!Base2			; yoshi can not swallow giga koopa
		LDA !extra_prop_1,x				;\ see if a backup already exists
		AND #$7F : BNE .NoBackup			;/
		LDA !extra_prop_1,x				;\
		AND #$80					; |
		STA $00						; | backup yoshi's CCC bits
		LDA $13C7|!Base2				; |
		ORA $00						; |
		STA !extra_prop_1,x				;/
		.NoBackup

	if !yoshipowers == 1
		LDA !extra_prop_1,x : BPL .NotRainbow
	if !rainbowbonus == 1
		LDA $187A|!Base2 : BEQ +			; only get star power while riding yoshi
		LDA #$08 : TSB $1490|!Base2			; true rainbow shell gives star power
		+
	endif
		.RainbowPower
		LDA #$07 : STA !sprite_num,x			;\ transform into rainbow shell
		STZ !15F6,x					;/
		LDY $18E2|!Base2
		DEY
		LDA $14
		LSR A
		AND #$06
		CLC : ADC #$04
	if !flashred == 0					;\
		CMP #$08					; | if red flash is disabled, replace it with yellow
		BNE $02 : LDA #$04				; |
	endif							;/
		STA !15F6,y
		PLB
		RTL

		.NotRainbow
	if !matchingbonus == 1
		LDA !extra_byte_1,x : BEQ .NoMatch		;\
		TAY						; |
		LDA .YoshiColor,y				; | receive rainbow power anyway with matching shell
		CMP !extra_prop_1,x : BEQ .RainbowPower		; | (unless it's green)
		.NoMatch					;/
	endif


		LDA !extra_prop_1,x				;\
		CMP #$04 : BEQ +				; |
		CMP #$06 : BNE ++				; | if yoshi is green or red, sprite num = 0x3E
	+	LDA #$04 : STA !sprite_num,x			; |
		BRA +++						; | if yoshi is blue or yellow, sprite num = 0x04
	++	LDA #$3E : STA !sprite_num,x			; |
		+++						;/

		LDA !extra_byte_1,x
		CMP #$02 : BEQ .Wing
		CMP #$03 : BEQ .Quake
		.Flash
		LDY $18E2|!Base2
		DEY
		LDA $14
		LSR #2
		LDA !15F6,y
		AND #$F0
		BCC +
		ORA !extra_prop_1,x
		BRA ++
	+	ORA !15F6,x
	++	STA !15F6,y
		PLB
		RTL
		.Wing
		LDA #$06 : STA !sprite_num,x
		BRA .Flash
		.Quake
		LDA #$07 : STA !sprite_num,x
		BRA .Flash

	if !matchingbonus == 1
		.YoshiColor
		db $0A,$08,$06,$04
	endif

	else
		PLB	;\ just return if !yoshipowers == 0
		RTL	;/
	endif		; close if !yoshipowers

	.NotInMouth
		LDA !extra_prop_1,x
		AND #$7F : BNE $03
	-	JMP .NoYoshi
		LDY $18E2|!Base2 : BEQ -			; handle backup yoshi color
		DEY
		STA !15F6,y
		STA $13C7|!Base2
		JSR UpdateState_Shell_ConvertBack
		JSR UpdateState_Shell_Kick
	;	LDA #$01 : STA !extra_byte_2,x
		LDA #$FF : STA $3500,x				; remove owned sprite

	if !yoshipowers == 1
		LDA !extra_prop_1,x : BMI .Fire
		CMP #$08 : BEQ .Fire
		LDA !extra_byte_1,x
	if !matchingbonus == 1
		BEQ .Spit
		CMP #$01 : BEQ .Fire
		TAY
		LDA !extra_prop_1,x
		CMP .YoshiColor,y : BNE .Spit
	else
		CMP #$01 : BNE .Spit
	endif
		.Fire
		STZ !sprite_status,x
		STZ $1DF9|!Base2				; clear this sfx
		LDA #$17 : STA $1DFC|!Base2			; fire sfx
		LDA #$20 : STA $1887|!Base2			; shake the screen
		LDY #$04
	-	STZ $00
		STZ $01
		LDA !157C,x
		PHP
		LDA .BigFireX,y
		PLP
		BEQ $03 : EOR #$FF : INC A
		STA $02
		LDA .BigFireY,y : STA $03
		LDA #$11
		PHY
		JSR SpawnExtended
		BCS +
		LDA #$A0 : STA $176F|!Base2,y
	+	PLY
		DEY : BPL -
		PLB
		RTL

		.BigFireX
		db $28,$27,$27,$24,$24

		.BigFireY
		db $00,$F8,$08,$EF,$11
	endif		; close if !yoshipowers

		.Spit
		LDA #$00 : STA !extra_prop_1,x
		LDA #$20 : STA $1DF9|!Base2			; yoshi spit sfx
		.NoYoshi

		LDA $9D : BNE .Lock

	.Process
		LDA !SpriteAnimTimer : BEQ +
		DEC !SpriteAnimTimer
		+
		LDA !batteringtimer,x : BEQ +
		DEC !batteringtimer,x
		+

		LDA !SpriteAnimIndex					; despawn when image 0x0F hits frame 1
		CMP #$0F : BNE .Alive
		LDA !SpriteAnimTimer
		CMP #$01 : BNE .Lock
		STZ !sprite_status,x
		PLB
		RTL

		.Alive
		LDA !SpriteAnimTimer : BNE +
		LDY !SpriteAnimIndex
		LDA Tilemap_Next,y : STA !SpriteAnimIndex
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
		+

	.Main
		JSR UpdateState
		JSR Physics
		JSR Interaction
	.Lock	JSR Graphics

		.Return
		PLB
		RTL


	UpdateState:
		LDA !1686,x					;\
		ORA #$01					; | make sure sprite can't be eaten by yoshi unless the specific state makes it so
		STA !1686,x					;/

		LDA !state,x
		CMP #$0B : BNE .NotDead
		RTS
		.NotDead
		LDA !extra_byte_2,x
		AND #$0F
		ASL A
		CMP.b #.End-.Ptr
		BCC $02 : LDA #$00
		PHX
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Normal		; 00
		dw .Shell		; 01
		dw .Naked		; 02
		dw .NakedSlope		; 03
		dw .Winged		; 04
		dw .WingedShell		; 05
		dw .WingedNaked		; 06
		dw .DiveBomb		; 07	(unused)
		dw .SlideOutOfShell	; 08
		.End

	.Normal
		PLX
		STZ !state,x
		RTS

	.WingedShell
	.Shell
		PLX
		LDA !1686,x					;\
		AND #$FC					; | shell can be eaten by yoshi
		ORA #$02					; |
		STA !1686,x					;/
		LDA $187A|!Base2 : BEQ ..noyoshi
		LDA !state,x
		CMP #$03 : BEQ ..noyoshi
		CMP #$05 : BEQ ..noyoshi
		LDA #$02 : STA !154C,x				; disable normal sprite contact while mario is on yoshi
		..noyoshi

		STZ $01
		LDA !turntimer,x : BEQ ++
		CMP #$10 : BNE +
		LDA !state,x
		CMP #$05 : BNE ..stand
		JSR ..ConvertBack
		LDA #$05 : STA !state,x
		BRA ++
	..stand	JSR ..ConvertBack
		LDA !extra_byte_2,x
		AND #$04
		STA !extra_byte_2,x
		STZ !SpriteAnimIndex
		BRA .Normal+1
	+	AND #$02
		ASL A
		DEC #2
		STA $00
		BPL $02 : DEC $01
		LDA !sprite_x_low,x
		CLC : ADC $00
		STA !sprite_x_low,x
		LDA !sprite_x_high,x
		ADC $01
		STA !sprite_x_high,x
		++

		LDA !state,x
		CMP #$05 : BEQ ..Return
		CMP #$04 : BEQ ..Freefall
		CMP #$03 : BEQ ..Return
		CMP #$02 : BNE ..NoKick
		LDA !sprite_status,x
		CMP #$0B : BNE ..Kick
		..NoKick
		LDA !sprite_status,x
		CMP #$08 : BEQ ..ConvertToShell
		CMP #$09 : BEQ ..Stationary
		CMP #$0B : BNE ..Stationary

		..Carried
		LDA #$02 : STA !state,x
		RTS

		..Freefall
		LDA !sprite_status,x
		CMP #$0B : BEQ ..Carried
		RTS

		..ConvertToShell
		LDA #$40 : STA !extra_prop_2,x
		LDA #$3E : STA !sprite_num,x
		LDA #$09 : STA !sprite_status,x
		LDA !167A,x
		AND #$7F
		STA !167A,x

		..Stationary
		LDA #$01 : STA !state,x
		..Return
		RTS


		..Kick
		LDA #$20 : STA !154C,x
		LDA !state,x
		CMP #$01 : BEQ +
		LDA $15
		AND #$0C : BEQ +
		CMP #$08 : BCC ..Drop
		LDA #$04 : STA !state,x				; go into freefall when going up
		RTS

		..Drop
		JSR ..ConvertToShell
		LDY !157C,x
		LDA ..DropSpeed,y : STA !sprite_speed_x,x
		STZ !sprite_speed_y,x
		RTS

		..DropSpeed
		db $10,$F0

	+	LDA #$03 : STA $1DF9|!Base2
		..ConvertBack
		LDA #$03 : STA !state,x
		LDA #$00 : STA !extra_prop_2,x
		LDA #$36 : STA !sprite_num,x
		LDA #$08 : STA !sprite_status,x
		LDA !167A,x
		ORA #$80
		STA !167A,x
		LDA #$03 : STA !SpriteAnimIndex
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
		RTS


	.WingedNaked
	.Naked
		PLX
		LDA !1686,x					;\
		AND #$FC					; | can be eaten while naked
		STA !1686,x					;/

		LDA !state,x : BEQ +
		LDY !turntimer,x : BNE ..return
		CMP #$07 : BEQ ..convert
		CMP #$08 : BNE ..return

		..jumping
		LDA !1588,x
		AND #$04 : BEQ ..return
	+	LDA #$06 : BRA ..walk

		..convert
		JSL SUB_HORZ_POS
		TYA : STA !157C,x
		LDA #$E0 : STA !sprite_speed_y,x
		STZ !sprite_speed_x,x
		LDA !extra_byte_1,x
		CMP #$02 : BNE ..calm
		..angry
		LDA #$09 : STA !SpriteAnimIndex
		BRA ..setanim
		..calm
		LDA #$07 : STA !SpriteAnimIndex
		..setanim
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
		LDA #$08
		..walk
		STA !state,x
		..return
		RTS


	.NakedSlope
		PLX
		LDA !1686,x					;\
		AND #$FC					; | can be eaten while naked
		STA !1686,x					;/
		LDA #$06 : STA !state,x
		LDA !sprite_speed_x,x : BEQ +
		LDA #$C0 : STA !1540,x
		LDA #$0D : STA !SpriteAnimIndex
	+	LDA !1540,x
		CMP #$01 : BNE ..return
		STA !turntimer,x
		LDA #$02 : STA !extra_byte_2,x
		LDA #$07 : STA !state,x
		..return
		RTS


	.DiveBomb
	.Winged
		PLX
		LDA #$0C : STA !state,x
		RTS


	.SlideOutOfShell
		PLX
		LDA !1686,x					;\
		AND #$FC					; | can be eaten while naked
		STA !1686,x					;/
		LDA #$07 : STA !state,x
		LDA #$0D : STA !SpriteAnimIndex
		LDA !sprite_speed_x,x
		BPL $03 : EOR #$FF : INC A
		INC A
		STA !SpriteAnimTimer
		LDA #$C0 : STA !turntimer,x
		LDA #$02 : STA !extra_byte_2,x
		RTS


	Rainbow:
		LDA !extra_prop_1,x				;\
		ORA #$80					; | set rainbow shell flag
		STA !extra_prop_1,x				;/
		JSL SUB_HORZ_POS
		TYA : STA !157C,x
		JSR ReadSpeed_Shell
		BPL .right
		.left
		CMP !sprite_speed_x,x : BEQ ++
		BIT !sprite_speed_x,x : BPL .accL
		BRA +
		.right
		CMP !sprite_speed_x,x : BEQ ++
		BIT !sprite_speed_x,x : BMI .accR
	+	BCC .accL
	.accR	INC !sprite_speed_x,x : BRA ++
	.accL	DEC !sprite_speed_x,x
	++	LDA !1588,x
		AND #$03 : BEQ +
		LDA !sprite_speed_x,x
		EOR #$FF : INC A
		STA !sprite_speed_x,x
		+
	if !breakblocks
		JMP ShellSpeed
	else
		JSL $01802A|!BankB
		RTS
	endif


	Physics:
		LDA !state,x : BNE $03 : JMP .Normal
		CMP #$03 : BEQ .Shell
		CMP #$05 : BEQ Rainbow
		CMP #$06 : BEQ .Naked
		CMP #$07 : BNE $03 : JMP .Slide
		CMP #$08 : BEQ .Jump
		CMP #$0B : BEQ .Dead
		CMP #$0C : BNE .R
		JMP Fly

	.R	RTS

	.Dead
		LDA !1686,x
		ORA #$80
		STA !1686,x
		LDA !extra_byte_2,x
		CMP #$02 : BEQ +
		CMP #$06 : BEQ +
		LDA #$03
		STA !SpriteAnimIndex
	+	STA !SpriteAnimTimer
		JSL $01802A|!BankB
		RTS


	.Jump
		INC !SpriteAnimTimer
		JSL $01802A|!BankB
		RTS


	.Shell
		LDA !1588,x
		AND #$03 : BEQ +
		LDA !157C,x
		EOR #$01
		STA !157C,x
		LDA #$FF : STA $3500,x				; remove spawn protection
		LDA #$01 : STA $1DF9|!Base2
	+	JSR ReadSpeed_Shell : STA !sprite_speed_x,x
	if !breakblocks
		JMP ShellSpeed
	else
		JSL $01802A|!BankB
	endif
	.R2	RTS


	.Naked
		LDA !extra_byte_2,x				;\ check for sliding koopa
		CMP #$03 : BEQ .Slide				;/
		LDY !SpriteAnimIndex
		CPY #$0B : BEQ ..Catch
		CPY #$0C : BNE ..NoCatch
		..Catch
		JMP Catch
		..NoCatch
		CPY #$07 : BCS +
		LDY #$07
		LDA !extra_byte_1,x
		CMP #$02
		BNE $02 : LDY #$09
		TYA : STA !SpriteAnimIndex
	+	JSR Chase
		JSR ShellSight
		JSR ReadSpeed_Naked : STA !sprite_speed_x,x
		BRA .ProcessSpeed

	.Slide
		LDA !1588,x
		AND #$03 : BEQ +
		STZ !sprite_speed_x,x
	+	LDA !1588,x
		AND #$04 : BNE ..ground
		INC !turntimer,x
		BRA +
		..ground
		LDA !15B8,x : BEQ ..noslope			;\
		BMI ..left					; |
	..right	LDA !sprite_speed_x,x : BMI ..inc		; |
		CMP #$30 : BCS ..dec				; | slope acceleration
		BRA ..inc					; |
	..left	LDA !sprite_speed_x,x : BPL ..dec		; |
		CMP #$D0 : BCC ..inc				; |
		BRA ..dec					;/
	..noslope
		LDA !sprite_speed_x,x : BEQ +
		BPL ..dec
	..inc	INC #2
	..dec	DEC A
		STA !sprite_speed_x,x : BEQ +			;\
		STZ !157C,x					; | face forward while sliding
		BPL +						; |
		INC !157C,x					;/
	+	LDA !1588,x
		AND #$04 : BEQ +
		LDA #$10 : STA !sprite_speed_y,x
	+	JSL $01802A|!BankB
		RTS

	.Normal
		LDA !SpriteAnimIndex
		CMP #$02 : BNE ..NotTurning
		STZ !sprite_speed_x,x
		LDA !SpriteAnimTimer
		CMP #$08 : BNE .ProcessSpeed
		LDA !157C,x
		EOR #$01
		STA !157C,x
		BRA .ProcessSpeed
		..NotTurning

		JSR Chase
		JSR ReadSpeed_Normal : STA !sprite_speed_x,x

	.ProcessSpeed
		LDA !1588,x
		AND #$03 : BNE .Turn
		LDA !1588,x
		AND #$04
		PHA
		BEQ .Air
	.Speed
		JSL $01802A|!BankB
		PLA : BEQ .Return
		EOR !1588,x
		AND #$04 : BEQ .Ground
		LDA !movementflags,x : BPL .Return
		LDA !state,x
		CMP #$08 : BEQ .Return			; if sprite jumped, it did not hit a ledge
		STZ !sprite_speed_y,x
	.Turn	LDA !sprite_speed_x,x
		EOR #$FF : INC A
		STA !sprite_speed_x,x
		LDA #$20 : STA !turntimer,x		; > 32 frame cooldown on turn
		JSL $01802A|!BankB			; reverse speed application to get sprite back on ledge or away from wall
		LDA !state,x : BEQ .Anim		;\
		LDA !157C,x				; |
		EOR #$01				; | instantly turn whn small
		STA !157C,x				; |
		RTS					;/

	.Anim	LDA #$02 : STA !SpriteAnimIndex			;\
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer	;/ turn animation when big

	.Return
		RTS

	.Ground
		LDA #$10 : STA !sprite_speed_y,x
		RTS

	.Air
		LDA !extra_byte_2,x
		AND #$04 : BEQ .Speed
		LDA !sprite_speed_y,x : BMI .Speed
		CMP #$10 : BCC .Speed
		PEA.w .Speed-1
		BRA .Ground


	Catch:
		LDY $3500,x : BMI .Fail
		LDA !sprite_status,y
		CMP #$08 : BCC .Fail
		CMP #$0B : BCS .Fail

		LDY !157C,x
		LDA !sprite_x_low,x
		CLC : ADC .XDisp,y
		STA $00
		LDA !sprite_x_high,x
		ADC .XDisp+2,y
		STA $01
		LDY $3500,x
		LDA $00 : STA !sprite_x_low,y
		LDA $01 : STA !sprite_x_high,y
		LDA !sprite_speed_x,x : BEQ .Stop
		BPL .DEC
	.INC	INC #2
	.DEC	DEC A
		STA !sprite_speed_x,x
		JSL $01802A|!BankB
		INC !SpriteAnimTimer
		LDA $14
		AND #$07 : BNE .Return
		RTS

		.Stop
		LDA !SpriteAnimIndex
		CMP #$0C : BNE .Return
		PHX
		TYX
		JSR UpdateState_Shell_ConvertBack
		JSR UpdateState_Shell_Kick
		STZ !154C,x
		LDA $15E9|!Base2 : STA $3500,x
		PLX
		LDY $3500,x
		LDA !157C,x : STA !157C,y
		LDA #$FF : STA $3500,x

		.Wait
		JSL $01802A|!BankB

		.Return
		RTS

		.Fail
		LDA !SpriteAnimIndex
		CMP #$0C : BEQ .Wait
		LDA #$FF : STA $3500,x
		LDY #$07
		LDA !extra_byte_1,x
		CMP #$02
		BNE $02 : LDY #$09
		TYA
		STA !SpriteAnimIndex
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
		JMP Physics_Naked_NoCatch

	.XDisp
		db $14,$EC
		db $00,$FF



	Chase:
		LDA !1588,x				; can't turn around in midair
		AND #$04 : BEQ .NoTurn
		BIT !attackflags,x : BPL .NoTurn	; only face player with chase enabled
	.force	LDA !turntimer,x : BNE .NoTurn
		JSL SUB_HORZ_POS
		TYA
		CMP !157C,x : BEQ .NoTurn
		LDA #$20 : STA !turntimer,x		; 32 frame cooldown on turn
		LDA !state,x : BEQ .Anim
		CMP #$0C : BEQ .Anim
	.Now	LDA !movementflags,x			; shelless can only chase when naked pattern is 1
		AND #$0C
		CMP #$08 : BNE .NoTurn
		TYA : STA !157C,x
		RTS

	.Anim	LDA #$02 : STA !SpriteAnimIndex
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer
		.NoTurn
		RTS



	; this replaces the normal physics module during flight
	Fly:
		LDA !flytimer,x				; special timer reduction that leaves highest bit intact
		AND #$80 : STA $00
		LDA !flytimer,x
		AND #$7F : BEQ +
		DEC A
		ORA $00
		STA !flytimer,x
		+

		LDA !movementflags,x
		AND #$70
		LSR #3
		CMP.b #.End-.Ptr
		BCC $02 : LDA #$00
		PHX
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Advance			; 0
		dw .Bounce			; 1
		dw .HorizontalPatrol		; 2
		dw .VerticalPatrol		; 3
		dw .Clockwise			; 4
		dw .CounterClockwise		; 5
		dw .GroundedChase		; 6
		dw .AerialChase			; 7
		.End

		.Wave
		db $00,$01,$02,$03,$04,$03,$02,$01
		db $00,$FF,$FE,$FD,$FC,$FD,$FE,$FF

	.Advance
		PLX
		LDA !turntimer,x
		ORA #$80
		STA !turntimer,x
		LSR #3
		AND #$0F
		TAY
		LDA .Wave,y : STA !sprite_speed_y,x
		JSR ReadSpeed_Flight : STA !sprite_speed_x,x
		JSL $01801A|!BankB
		JSL $018022|!BankB
		RTS

	.Bounce
		PLX
		LDA !SpriteAnimIndex
		CMP #$02 : BNE ..NotTurning
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..move
		LDA !157C,x
		EOR #$01
		STA !157C,x
		BRA ..move
		..NotTurning
		LDA !1588,x
		AND #$04 : BEQ ..speed
		LDA !sprite_speed_y,x
		EOR #$FF
		INC A
		STA !sprite_speed_y,x
		..speed
		JSR ReadSpeed_Flight : STA !sprite_speed_x,x
		..move
		JSL $01802A|!BankB
		LDA !1588,x
		AND #$03 : BEQ ..return
		LDA #$02 : STA !SpriteAnimIndex
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer
		LDA !sprite_speed_x,x
		EOR #$FF
		INC A
		STA !sprite_speed_x,x
		..return
		RTS


	; timer usage:
	;	hi bit: 0 = accelerating, 1 = slowing down
	;	timer bits: time left until hi bit should swap
	;	when hi bit goes 1 -> 0, sprite uses the turn animation

	.HorizontalPatrol
		PLX
		LDA !SpriteAnimIndex				; turn animation
		CMP #$02 : BNE ..NotTurning
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..NotTurning
		LDA !157C,x
		EOR #$01
		STA !157C,x
		..NotTurning

		LDA !turntimer,x			; y speed
		ORA #$80
		STA !turntimer,x
		LSR #3
		AND #$0F
		TAY
		LDA .Wave,y : STA !sprite_speed_y,x

		LDA !flytimer,x				; x speed
		AND #$03 : BNE +
		LDA !flytimer,x : BMI ..slow
	..acc	JSR ReadSpeed_Flight
		CMP !sprite_speed_x,x : BEQ +
		LDA !157C,x
		EOR #$01
		ASL A
		DEC A
		CLC : ADC !sprite_speed_x,x
		BRA ++
	..slow	LDA !sprite_speed_x,x : BEQ +
		BPL ...dec
	...inc	INC #2
	...dec	DEC A
	++	STA !sprite_speed_x,x
	+	LDA !flytimer,x
		AND #$7F : BNE ..speed
		JSR ReadSpeed_Flight
		BPL $03 : EOR #$FF : INC A
		ASL #2
		STA $00
		LDA !flytimer,x
		EOR #$80
		ORA $00
		STA !flytimer,x
		BMI ..speed
		LDA #$02 : STA !SpriteAnimIndex
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer

		..speed
		JSL $01801A|!BankB			; move
		JSL $018022|!BankB
		RTS

	.VerticalPatrol
		PLX
		LDA !SpriteAnimIndex
		CMP #$02 : BNE ..NotTurning
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..NotTurning
		LDA !157C,x
		EOR #$01
		STA !157C,x
		..NotTurning

		LDA !flytimer,x				; x speed
		AND #$03 : BNE +
		LDA !flytimer,x : BMI ..slow
	..acc	JSR ReadSpeed_Flight
		CMP !sprite_speed_y,x : BEQ +
		LDA !157C,x
		EOR #$01
		ASL A
		DEC A
		CLC : ADC !sprite_speed_y,x
		BRA ++
	..slow	LDA !sprite_speed_y,x : BEQ +
		BPL ...dec
	...inc	INC #2
	...dec	DEC A
	++	STA !sprite_speed_y,x
	+	LDA !flytimer,x
		AND #$7F : BNE ..speed
		JSR ReadSpeed_Flight
		BPL $03 : EOR #$FF : INC A
		ASL #2
		STA $00
		LDA !flytimer,x
		EOR #$80
		ORA $00
		STA !flytimer,x
		BMI ..speed
		LDA #$02 : STA !SpriteAnimIndex
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer

		..speed
		STZ !sprite_speed_x,x
		JSL $01801A|!BankB			; move
		JSL $018022|!BankB
		RTS

	.Clockwise
	.CounterClockwise
		PLX
		LDA !SpriteAnimIndex				; turn animation
		CMP #$02 : BNE ..NotTurning
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..NotTurning
		LDA !157C,x
		EOR #$01
		STA !157C,x
		..NotTurning

		LDA !flytimer,x : BEQ ..swap
		CMP #$80 : BNE ..noswap
		..swap
		DEC A
		STA !flytimer,x
		..noswap
		ASL A
		STA $04
		ROL A
		AND #$01
		STA $05
		JSR ReadSpeed_Flight
		BPL $03 : EOR #$FF : INC A
		STA $06
		%CircleX()
		%CircleY()
		LDA $07 : STA !sprite_speed_x,x
		LDA $09 : STA !sprite_speed_y,x

		LDA !turntimer,x : BNE ..speed
		JSL SUB_HORZ_POS
		TYA
		CMP !157C,x : BEQ ..speed
		LDA #$02 : STA !SpriteAnimIndex
		LDA Tilemap_Time+2 : STA !SpriteAnimTimer
		LDA #$18 : STA !turntimer,x

		..speed
		LDA !movementflags,x
		AND #$70
		CMP #$50 : BEQ +
		LDA !sprite_speed_x,x
		EOR #$FF : INC A
		STA !sprite_speed_x,x
	+	JSL $01801A|!BankB			; move
		JSL $018022|!BankB
		RTS

	.GroundedChase
		PLX
		LDA !SpriteAnimIndex
		CMP #$02 : BNE ..NotTurning
		STZ !sprite_speed_x,x
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..speed
		LDA !157C,x
		EOR #$01
		STA !157C,x
		BRA ..speed
		..NotTurning

		JSR Chase

		..speed
		LDA !1588,x
		AND #$04 : BEQ ..air

		..ground
		LDA !1588,x
		AND #$03 : BEQ +
		LDA #$C0 : STA !sprite_speed_y,x
		BRA ..air
	+	JSR ReadSpeed_Flight : STA !sprite_speed_x,x
		LDA #$10 : STA !sprite_speed_y,x
		LDA !SpriteAnimIndex : BEQ ..12
		CMP #$01 : BEQ ..13
		CMP #$14 : BEQ ..12
		CMP #$15 : BEQ ..13
		BRA ..move
	..12	LDA #$12 : BRA ..set
	..13	LDA #$13 : BRA ..set

		..air
		DEC !sprite_speed_y,x
		LDA !1588,x
		AND #$08 : BEQ +
		STZ !sprite_speed_y,x
	+	LDA !sprite_speed_y,x : BMI +
		CMP #$10 : BCC +
		LDA #$10 : STA !sprite_speed_y,x
	+	LDA !SpriteAnimIndex : BEQ ..14
		CMP #$01 : BEQ ..15
		CMP #$12 : BEQ ..14
		CMP #$13 : BEQ ..15
		BRA ..move
	..14	LDA #$14 : BRA ..set
	..15	LDA #$15
	..set	STA !SpriteAnimIndex
	..move	LDA !1588,x
		AND #$04 : PHA
		LDA !sprite_x_low,x : PHA
		JSL $01802A|!BankB
		PLA : STA $00
		LDA !1588,x
		AND #$03 : BEQ +
		LDA $00 : STA !sprite_x_low,x
	+	PLA : BEQ ..return
		AND !1588,x : BNE ..return
		JSL SUB_VERT_POS
		CPY #$00 : BEQ ..return
		LDA #$C0 : STA !sprite_speed_y,x

		..return
		RTS

	.AerialChase
		PLX

		JSR Chase_force
		LDA !SpriteAnimIndex
		CMP #$02 : BNE ..notturning
		LDA !SpriteAnimTimer
		CMP #$08 : BNE ..notturning
		LDA !157C,x
		EOR #$01
		STA !157C,x
		..notturning

		LDA !sprite_x_low,x : STA $00
		LDA !sprite_x_high,x : STA $01
		LDA !sprite_y_high,x : XBA
		LDA !sprite_y_low,x
		REP #$20
		SEC : SBC #$0010
		SEC : SBC $96
		STA $02
		LDA $00
		SEC : SBC $94
		STA $00
		SEP #$20
		JSR ReadSpeed_Flight
		BPL $03 : EOR #$FF : INC A
		%Aiming()

		LDA $00 : BPL ..right
		..left
		CMP !sprite_speed_x,x : BEQ ++
		BIT !sprite_speed_x,x : BPL ..accL
		BRA +
		..right
		CMP !sprite_speed_x,x : BEQ ++
		BIT !sprite_speed_x,x : BMI ..accR
	+	BCC ..accL
	..accR	INC !sprite_speed_x,x : BRA ++
	..accL	DEC !sprite_speed_x,x
	++	LDA $02 : BPL ..down
		..up
		CMP !sprite_speed_y,x : BEQ ..move
		BIT !sprite_speed_y,x : BPL ..accU
		BRA +
		..down
		CMP !sprite_speed_y,x : BEQ ..move
		BIT !sprite_speed_y,x : BMI ..accD
	+	BCC ..accU
	..accD	INC !sprite_speed_y,x : BRA ..move
	..accU	DEC !sprite_speed_y,x

		..move
		JSL $01801A|!BankB
		JSL $018022|!BankB

		RTS



	Interaction:
		LDA !15D0,x : BEQ .Allow		; no interaction while sprite is on yoshi's tongue
		.Forbid
		LDA #$20 : STA !154C,x
		RTS

		.Allow
		LDA !state,x
		ASL A
		CMP.b #.End-.Ptr
		BCC $02 : LDA #$00
		PHX
		TAX
		JMP (.Ptr,x)

		.Ptr
		dw .Normal		; 00
		dw .Stationary		; 01
		dw .Carried		; 02
		dw .Kicked		; 03
		dw .Freefall		; 04
		dw .Rainbow		; 05
		dw .Naked		; 06
		dw .NakedSliding	; 07
		dw .NakedJump		; 08
		dw .NakedSlope		; 09
		dw .Smushed		; 0A
		dw .Dead		; 0B
		.End


	.Normal
		PLX
		JSR LoadHitbox_Big
		JSR CheckFireballs
		LDA !154C,x : BNE .NoContact
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCC .NoContact
		JSR CheckStomp

		.NoContact
		LDY.b #!SprSize
	-	LDA !sprite_status,y
		CMP #$0A : BEQ ++
		CMP #$09 : BNE +
		LDA !1588,y
		AND #$04 : BNE +
	++	PHY
		PHX
		TYX
		JSL $03B6E5|!BankB
		JSL $03B72B|!BankB
		LDA !new_sprite_num,x
		PLX
		PLY
		BCC +
		CMP !new_sprite_num,x : BEQ +
	if !shellarmor == 1
		LDA.w !sprite_speed_x,y
		JSR Halve
		EOR #$FF : INC A
		STA.w !sprite_speed_x,y
		LDA #$C0 : STA.w !sprite_speed_y,y
		LDA #$02 : STA !sprite_status,y
		LDA !1686,y
		ORA #$80
		STA !1686,y
		LDA #$02 : STA $1DF9|!Base2
		PHX
		TYX
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
		PLX
	else
		LDA.w !sprite_speed_x,y
		JSR Halve
		STA !sprite_speed_x,x
		LDA #$D8 : STA !sprite_speed_y,x
		JSR UpdateState_Shell_ConvertBack
		LDA #$0B : STA !state,x
		JSR SetDeathImage
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
	if !score == 1
		PHX
		TYX
		LDA !1626,x					;\
		INC A						; |
		CMP #$08					; |
		BCC $02 : LDA #$08				; |
		STA !1626,x					; |
		PLX						; | give score
		PHA						; |
		JSL $02ACE5|!BankB				; |
		LDY !1626,x					; |
		PLY						; |
		LDA GiveScore_ScoreSFX,y : STA $1DF9|!Base2	;/
	else
		LDA #$03 : STA $1DF9|!Base2			; kick SFX
	endif
		RTS
	endif
	+	DEY : BPL -
		RTS



	.Stationary
		PLX

		LDA !1588,x
		AND #$04 : BEQ ..air
		..ground
		STZ !1626,x					; clear consecutive kills on the ground
		BRA +
		..air
		JSR LoadHitbox_Small				; hitbox against other sprites while in the air
		JSR ShellHitbox_Main
		+

	..2	LDA #$03 : STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
		LDA $77
		AND #$04 : BNE ..interact
		REP #$20
		LDA $96
		PHA
		CLC : ADC #$0008
		STA $96
		SEP #$20
		JSL SUB_VERT_POS
		REP #$20
		PLA : STA $96
		SEP #$20
		CPY #$00 : BEQ ..interact
		..nointeract
	if !spinarmor == 0
		JSR LoadHitbox_Small
		JSR CheckFireballs
		LDA $140D|!Base2
		ORA $187A|!Base2
		BEQ +
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCS ..spinkill
		+
	else
		JSR LoadHitbox_Small
		JSR CheckFireballs
	endif
		LDA #$02 : STA !154C,x
	-	JMP .NoContact
		..interact
		LDA $187A|!Base2 : BNE +		; interact anyway if riding yoshi
		LDA !154C,x : BNE -
	+	JSR LoadHitbox_Small
		JSR CheckFireballs
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCC ..nocontact
	if !stararmor == 0
		LDA $1490|!Base2 : BEQ +
		JMP CheckStomp_StarKill
		+
	endif
		LDA $1470|!Base2			;\
		ORA $187A|!Base2			; | if mario is holding something or riding yoshi, he always kicks on contact
		BNE ..kick				;/
		BIT $15 : BVS ..nocontact
		LDA #$0C : STA $149A|!Base2
	..kick
	if !spinarmor == 0
		LDA $140D|!Base2
		ORA $187A|!Base2
		BEQ +
		..spinkill
		JSL $01AB99+5|!BankB			; bounce and contact gfx
		JSL $01AA33|!BankB
		LDA #$04 : STA !sprite_status,x
		LDA #$1F : STA !1540,x
		LDA #$00				; make damn sure the sprite is crushed
		STA !new_sprite_num,x
		STA !extra_bits,x
		STZ !sprite_num,x
		LDA #$08 : STA $1DF9|!Base2		; spin kill sfx
		LDA !coins,x : BEQ ++
		JSR DropCoins
	++	JSL $07FC3B|!BankB
		JMP BigPuff
		+
	endif
		JSL SUB_HORZ_POS
		TYA
		EOR #$01
		STA !157C,x
		LDA #$FF : STA $3500,x			; remove spawn protection
		JMP UpdateState_Shell_Kick
		..nocontact
		JMP .NoContact

	.Carried
		PLX
		LDA !extra_byte_2,x
		AND #$04 : BEQ ..nofloat
		LDA !SpriteAnimIndex
		CMP #$10 : BEQ +
		CMP #$11 : BEQ +
		LDA #$10 : STA !SpriteAnimIndex
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer	; SHOUTOUT TO SMW CODE COOLNESS FACTOR (TM)!!!!!!!!!!!!!!!!!!
	+	LDA $77
		AND #$04 : BNE ..nofloat
		LDA $7D : BMI ..nofloat
		CMP #$10 : BCC ..nofloat
		LDA #$10 : STA $7D
		..nofloat


		STZ !turntimer,x
		LDA #$FF : STA $3500,x			; remove spawn protection
		LDA $7B
		BPL $02 : EOR #$FF
		CMP #$20 : BCS +
		STZ !1626,x				; mario must maintain high horizontal speed to keep battering ram kill count
		+

		LDA $7B : BEQ +
		JSR ShellHitbox
	+	LDA !extra_byte_2,x
		AND #$04 : BNE ++
		LDA #$04
		LDY $1499|!Base2
		BEQ $02 : LDA #$03
		STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
	++	LDA $76
		EOR #$01
		STA !157C,x
		BIT $15 : BVS +
		LDA #$0A : STA !sprite_status,x
		+
		RTS

	.Kicked
	.Rainbow
		PLX
		STZ !turntimer,x
		JSR ShellHitbox
		LDA !154C,x : BNE +
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCC $03 : JSR CheckStomp
	+	JMP .NoContact

	.Freefall
		PLX
		STZ !turntimer,x
		JSR ShellHitbox
		JSR .Stationary_2			; skip PLX and 1626 clear
		LDA !1588,x
		AND #$04 : BEQ ..R
		LDA !sprite_speed_x,x : BNE ..R
		LDA #$01 : STA !state,x			; return to stationary state when speed hits 0
	..R	RTS


	.Naked
	.NakedSliding
	.NakedJump
	.NakedSlope
		PLX
		LDA !state,x
		CMP #$08 : BNE ..nofuse
		JSR LoadHitbox_Small
		LDA !new_sprite_num,x : STA $1695|!Base2
		LDA !extra_byte_2,x
		AND #$04
		BEQ $02 : LDA #$80
		TSB $1695|!Base2
		PHX
		LDX.b #!SprSize
	-	LDA !sprite_status,x
		CMP #$08 : BCC ..next
		LDA $1695|!Base2
		AND #$7F
		CMP !new_sprite_num,x : BNE ..next
		LDA !extra_bits,x
		AND #$08 : BEQ ..next
		LDA !state,x
		CMP #$01 : BNE ..next
		JSR LoadHitbox_Small00
		JSL $03B72B|!BankB
		BCC ..next
		..fuse
		LDA #$01				; fusion code goes here!
		BIT $1695|!Base2
		BPL $02 : ORA #$04
		STA !extra_byte_2,x
	if !priority == 0
		JSR INIT
	else
		PHX
		LDX $15E9|!Base2
		LDA !extra_bits,x : XBA
		LDA !extra_byte_1,x
		PLX
		STA !extra_byte_1,x
		XBA : STA !extra_bits,x
		JSR INIT
	endif
		JSR UpdateState_Shell_ConvertBack
		LDA #$30 : STA !turntimer,x
		LDA #$01 : STA !state,x
		STZ !flipped,x				; reset vertical flip
		PLY
		LDA.w !movementflags,y			;\
		AND #$03				; | check for rainbow power
		CMP #$03 : BNE +			; |
		LDA #$05 : STA !state,x			;/
	+	TYX
		STZ !sprite_status,x
		JMP Graphics_ReloadSprite

		..next
		DEX : BPL -
		PLX
		..nofuse


		LDA !154C,x : BNE +
		JSR LoadHitbox_Small
		JSR CheckFireballs
		JSL $03B664|!BankB
		JSL $03B72B|!BankB
		BCC +
		JSR CheckStomp
	+	JMP .NoContact
		RTS

	.Smushed
	.Dead
		PLX
		LDA #$20 : STA !154C,x
		RTS



	LoadHitbox:
		.Big
		LDA !sprite_x_low,x
		SEC : SBC #$04
		STA $04
		LDA !sprite_x_high,x
		SBC #$00
		STA $0A
		LDA !sprite_y_low,x
		SEC : SBC #$08
		STA $05
		LDA !sprite_y_high,x
		SBC #$00
		STA $0B
		LDA #$18
		STA $06
		STA $07
		RTS

		.Small
		LDA !sprite_x_low,x
		SEC : SBC #$04
		STA $04
		LDA !sprite_x_high,x
		SBC #$00
		STA $0A
		LDA !sprite_y_low,x : STA $05
		LDA !sprite_y_high,x : STA $0B
		LDA #$18 : STA $06
		LDA #$0A : STA $07
		RTS

		.Big00
		LDA !sprite_x_low,x
		SEC : SBC #$04
		STA $00
		LDA !sprite_x_high,x
		SBC #$00
		STA $08
		LDA !sprite_y_low,x
		SEC : SBC #$08
		STA $01
		LDA !sprite_y_high,x
		SBC #$00
		STA $09
		LDA #$18
		STA $02
		STA $03
		RTS

		.Small00
		LDA !sprite_x_low,x
		SEC : SBC #$04
		STA $00
		LDA !sprite_x_high,x
		SBC #$00
		STA $08
		LDA !sprite_y_low,x : STA $01
		LDA !sprite_y_high,x : STA $09
		LDA #$18 : STA $02
		LDA #$0A : STA $03
		RTS


	CheckStomp:
	if !stararmor == 0
		LDA $1490|!Base2 : BEQ +
		.StarKill
		LDA $7B
		JSR Halve
		STA !sprite_speed_x,x
		LDA #$D8 : STA !sprite_speed_y,x
		JSR UpdateState_Shell_ConvertBack
		LDA #$0B : STA !state,x
		LDA !coins,x : BEQ ++
		JSR DropCoins
		++
	if !score == 1
		JSR SetDeathImage
		JMP GiveScore
	else
		JMP SetDeathImage
	endif
		+
	endif
		LDA #$04 : STA !154C,x
		LDA $77
		AND #$04 : BNE .HurtMario
		LDA $01
		CMP $05
		LDA $09
		SBC $0B
		BCC .Stomp

		.HurtMario
		LDA !state,x				;\
		CMP #$07 : BEQ .Return			; > can't hurt mario while sliding out of shell
		CMP #$03 : BNE +			; |
		JSL SUB_HORZ_POS			; |
		TYA					; | shell can only hurt mario when moving toward him
		LSR A					; |
		ROR A					; |
		EOR !sprite_speed_x,x			; |
		BPL +					;/
		RTS

	+	JSR HurtPlayer
		JSR Shove
	.Return	RTS

		.Stomp
		JSR Shove				; apply shove
		LDA $7D : BMI .Return			; no stomp if mario is moving up
		STZ !flytimer,x				; delet this
		JSL $01AB99+5|!BankB			; bounce and contact gfx
		JSL $01AA33|!BankB
	if !spinarmor == 0
		LDA $140D|!Base2
		ORA $187A|!Base2
		BEQ +
		LDA #$04 : STA !sprite_status,x
		LDA #$1F : STA !1540,x
		LDA #$08 : STA $1DF9|!Base2
		LDA !coins,x : BEQ ++
		JSR DropCoins
	++	JSL $07FC3B|!BankB
		JMP BigPuff
		+
	endif
		LDA !state,x : BEQ .Spawn
		CMP #$05 : BNE +			; shove power for rainbow shell???
		LDA #$02 : STA $1DF9|!Base2		; sfx
		RTS
	+	CMP #$06 : BCC .Stop
		CMP #$09 : BCC .Kill
		CMP #$0C : BNE .Stop

		.WingClip
		STZ !state,x
		STZ !SpriteAnimIndex
		STZ !SpriteAnimTimer
		LDA #$00 : STA !extra_byte_2,x
		BRA .NoCoins

		.Kill
		LDA #$0A : STA !state,x
		LDA #$0F : STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
		BRA .NoCoins

		.Spawn
	if !spawnnaked == 1
		STZ $00
		STZ $01
		STZ $02
		STZ $03
		SEC : LDA !new_sprite_num,x
		%SpawnSprite()
		BCS .Stop
		PHX
		LDA !extra_byte_1,x
		TYX
		STA !extra_byte_1,x
		LDA #$08 : STA !extra_byte_2,x
		LDA #$01 : STA !sprite_status,x
		TXA
		PLX
		STA $3500,x				; save index
	endif
		.Stop
		LDA !extra_byte_2,x			;\ winged shell doesn't lose wings
		CMP #$05 : BEQ +			;/
		LDA #$01 : STA !extra_byte_2,x		; turn to shell
	+	STZ !turntimer,x
		LDA #$01 : STA !state,x
		LDA #$03 : STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
		LDA !coins,x : BEQ .NoCoins
		JSR DropCoins
		.NoCoins
	if !score == 1
	GiveScore:
		LDA !15D0,x : BNE .Return
	if !stararmor == 0
		LDA $1490|!Base2 : BEQ +
		LDA $18D2|!Base2			;\
		INC A					; |
		CMP #$08				; | increment number consecutive enemies killed by star
		BCC $02 : LDA #$08			; |
		STA $18D2|!Base2			;/
		JSL $02ACE5|!BankB			; give mario points
		LDY $18D2|!Base2			;\ get index and go to shared code
		BRA .Give				;/
		+
	endif
		LDA $1697|!Base2			;\
		INC A					; |
		CMP #$08				; | increment number consecutive enemies stomped
		BCC $02 : LDA #$08			; |
		STA $1697|!Base2			;/
		JSL $02ACE5|!BankB			; give mario points
		LDY $1697|!Base2			;\ score SFX
	.Give	LDA .ScoreSFX,y : STA $1DF9|!Base2	;/
	else
		LDA #$02 : STA $1DF9|!Base2
	endif
	.Return	RTS

	if !score == 1
	.ScoreSFX	db $00,$13,$14,$15,$16,$17,$18,$19,$03
	endif


	CheckFireballs:
		JSR CheckQuake
		BCS .CapeHit

		LDA !154C,x : BNE .NCJmp
		LDA $13E8|!Base2 : BNE .ProcessCape	;\ check cape active flag
	.NCJmp	JMP .NoCape				;/
		.ProcessCape				;\
		LDA $13E9|!Base2			; |
		SEC : SBC #$02				; |
		STA $00					; |
		LDA $13EA|!Base2			; |
		SBC #$00				; |
		STA $08					; |
		LDY #$00				; |
		LDA $13DF|!Base2			; |
		CMP #$07				; | check for cape contact
		BCC $01 : INY				; |
		LDA $13EB|!Base2			; |
		SEC : SBC .CapeY,y			; |
		STA $01					; |
		LDA $13EC|!Base2			; |
		SBC #$00				; |
		STA $09					; |
		LDA #$14 : STA $02			; |
		LDA #$10 : STA $03			; |
		JSL $03B72B|!BankB			; |
	; cape kill on naked koopas, only with cape armor off
	if !capearmor == 0
		BCC .NCJmp				; |
	else
		BCS .CapeHit2				; |
		JMP .NoCape				;/
	endif
	.CapeHit
		LDA !state,x : BEQ .FlipShell
		CMP #$06 : BCC .CapeHit2
		CMP #$0A : BCS .CapeHit2
		LDA #$0B : STA !state,x
		JSR SetDeathImage
		LDA #$D8 : STA !sprite_speed_y,x
		BRA .CapeContact
	.CapeHit2
		LDA !state,x
		CMP #$01 : BCC .NoCape			;\
		CMP #$02 : BEQ .NoCape			; | states 1-4 (but not 2) can be caped
	if !rainbowcape == 0				; \
		CMP #$05 : BCS .NoCape			;  | rainbow shell check
	else						;  |
		CMP #$06 : BCS .NoCape			; /
	endif						;/
		.FlipShell
		JSL SUB_HORZ_POS
		TYA
		LDA .CapeKnockback,y : STA !sprite_speed_x,x
		LDA #$B0 : STA !sprite_speed_y,x
		LDA !extra_byte_2,x			;\ winged shell does not flip or lose wings
		CMP #$05 : BEQ +			;/
		LDA #$01 : STA !flipped,x		;\ flip upside down
		LDA #$01 : STA !extra_byte_2,x		;/ and turn to shell
	+	STZ !turntimer,x
		LDA #$01 : STA !state,x
		LDA #$03 : STA !SpriteAnimIndex
		LDA #$40 : STA !SpriteAnimTimer
		LDA !coins,x : BEQ .CapeContact
		JSR DropCoins
		.CapeContact
		LDA #$10 : STA !154C,x			; disable player/cape interaction for 16 frames
		LDA #$03 : STA $1DF9|!Base2		; cape hit sfx
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
	; caping an enemy is always worth 100 points
	if !score == 1
		LDA $1697|!Base2 : PHA
		STZ $1697|!Base2
		JSL $02ACE5|!BankB
		PLA : STA $1697|!Base2
		BRA .NoCape
	else
		BRA .NoCape
	endif
	.CapeY
		db $00,$10
	.CapeKnockback
		db $F0,$10
		.NoCape

		LDA #$08				;\
		STA $02					; | hitbox size
		STA $03					;/
	if !yoshifireballs == 0
		LDY #$01				; > how many mario fireball slots there are
	-	LDA $170B+8|!Base2,y			; |
		CMP #$05 : BNE +			; |
		LDA $171F+8|!Base2,y : STA $00		; | look for contact with mario fireballs
		LDA $1733+8|!Base2,y : STA $08		; |
		LDA $1715+8|!Base2,y : STA $01		; |
		LDA $1729+8|!Base2,y : STA $09		; |
		PHY					; |
		JSL $03B72B|!BankB			; |
		PLY					; |
		BCC +					;/
		LDA #$01 : STA $170B+8|!Base2,y		;\
		LDA #$0F : STA $176F+8|!Base2,y		; | destroy mario fireballs on contact
		LDA #$01 : STA $1DF9|!Base2		;/
	else
		LDY #$09				; > how many extended sprite slots there are
	-	LDA $170B|!Base2,y			; |
		CMP #$05 : BEQ ++			; |
		CMP #$11 : BNE +			; |
	++	LDA $171F|!Base2,y : STA $00		; | look for contact with fireballs
		LDA $1733|!Base2,y : STA $08		; |
		LDA $1715|!Base2,y : STA $01		; |
		LDA $1729|!Base2,y : STA $09		; |
		PHY					; |
		JSL $03B72B|!BankB			; |
		PLY					; |
		BCC +					;/
		LDA #$01 : STA $170B|!Base2,y		;\
		LDA #$0F : STA $176F|!Base2,y		; | destroy fireballs on contact
		LDA #$01 : STA $1DF9|!Base2		;/
	endif
	if !firearmor == 0
	if !rainbowfire == 0				;\
		LDA !state,x				; | see if rainbow shell can be affected by fire
		CMP #$05 : BEQ +			; |
	endif						;/
		LDA !hp,x
		INC A
		STA !hp,x
		CMP.b #!firehealth : BCC +
		PHY
		JSR UpdateState_Shell_ConvertBack
		LDA #$0B : STA !state,x
		JSR SetDeathImage
		STZ !sprite_speed_x,x
		LDA #$D8 : STA !sprite_speed_y,x
		LDA #$02 : STA $1DF9|!Base2		; kill enemy sfx
		JSR BigPuff
		LDA !coins,x : BEQ .NoCoins
		JSR DropCoins
		.NoCoins
		PLY
	if !score == 1
		LDA $1697|!Base2 : PHA
		LDA #$02 : STA $1697|!Base2
		JSL $02ACE5|!BankB
		PLA : STA $1697|!Base2
	endif
		RTS
	endif
	+	DEY : BPL -				; loop
		RTS


	Shove:
		LDA !state,x : BEQ .Valid
		CMP #$05 : BNE .NoShove
	.Valid	REP #$20
		LDA $94 : PHA
		SEC : SBC #$0008
		STA $94
		SEP #$20
		JSL SUB_HORZ_POS
		REP #$20
		PLA : STA $94
		SEP #$20
		STY $00
		LDA !state,x
		CMP #$05 : BNE +			;\ rainbow shell always has 64 shove power
		LDA #$40 : BRA ++			;/
	+	LDA !attackflags,x
		AND #$7F : BEQ .NoShove
	++	LDY $00
		BEQ $03 : EOR #$FF : INC A
		CLC : ADC $7B
		CMP #$C0 : BCS +
		CMP #$40 : BCC +
		PHP
		LDA #$40
		PLP
		BPL $02 : LDA #$C0
	+	STA $7B
		.NoShove
		RTS


	DropCoins:
		DEC !coins,x : BMI .Return
		LDY !coins,x
		CPY.b #.YSpeed-.XDisp
		BCC $02 : LDY #$00
		LDA .XDisp,y : STA $00
		STZ $01
		STZ $02
		LDA .YSpeed,y : STA $03
		LDA .Dir,y : PHA
		CLC : LDA #$21
		%SpawnSprite()
		PLA
		BCS .Return
		STA !157C,y
		LDA #$20 : STA !154C,y
		LDA #$08 : STA !sprite_status,y
		BRA DropCoins

	.Return
		STZ !coins,x
		RTS

	.XDisp	db $F0,$10,$00,$00
	.YSpeed	db $E8,$E8,$D0,$D0
	.Dir	db $01,$00,$01,$00


	ShellHitbox:
		JSR LoadHitbox_Small
		JSR CheckFireballs
	.Main	LDY.b #!SprSize
	.Loop	STY $1695|!Base2
		TYA
	if !sa1 == 0
		EOR $14
		LSR A : BCC .NJmp				; SNES optimizer: alternate sprites every frame
		TYA
	endif
		CMP $3500,x : BEQ .NJmp				; can't knock out spawned sprite
		CPY $15E9|!Base2 : BNE .Process			; can't knock out itself
	.NJmp	JMP .Next
	.Process
		LDA !sprite_status,y				;\ sprite must be state 8 or higher
		CMP #$08 : BCC .NJmp				;/
		CMP #$0C : BEQ .NJmp				; > but not if they are state C
		LDA !15D0,y : BNE .NJmp				; > can't be on yoshi's tongue
		LDA !new_sprite_num,x				;\
		PHX						; |
		TYX						; |
		CMP !new_sprite_num,x : BNE .NoTrade		; | look for other giga koopas
		LDA !extra_bits,x				; |
		AND #$08 : BNE .Mirror				; |
		.NoTrade					; |
		PLX						;/
		LDA !167A,y					;\
		AND #$02					; |
		ORA !15D0,y					; | check for immunity and other things
		ORA !1632,y					; |
		BNE .Next					;/
		PHX						;\
		TYX						; |
		JSL $03B6E5|!BankB				; | check for contact
		JSL $03B72B|!BankB				; |
		PLX						; |
		LDY $1695|!Base2				; |
		BCC .Next					;/
		PHY						;\
		PHX						; |
		TYX						; |
		JSL SUB_HORZ_POS				; | knockout code
		LDA .XSpeed,y : STA !sprite_speed_x,x		; |
		LDA #$E0 : STA !sprite_speed_y,x		; |
		LDA #$02 : STA !sprite_status,x			;/
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
		PLX
	.HandleScore
	if !score == 1
		LDA !state,x					;\
		CMP #$02 : BNE +				; | when shell is used as a battering ram, only keep kill count if a sprite is hit at least every 128 frames
		LDA !batteringtimer,x : BNE +			; |
		STZ !1626,x					;/
	+	LDA !1626,x					;\
		INC A						; |
		CMP #$08					; |
		BCC $02 : LDA #$08				; | give score
		STA !1626,x					; |
		JSL $02ACE5|!BankB				; |
		LDY !1626,x					; |
		LDA GiveScore_ScoreSFX,y : STA $1DF9|!Base2	;/
		LDA #$80 : STA !batteringtimer,x		; battering ram timer (128 frames)
	else
		LDA #$03 : STA $1DF9|!Base2			; kick SFX
	endif
		PLY

	.Next	DEY
		BMI $03 : JMP .Loop
		RTS

	.Mirror							; this code handles giga shell -> giga koopa interaction
		LDA !state,x : BEQ ..Big
		CMP #$0A : BEQ ..Next2
		CMP #$0B : BEQ ..Next2
		CMP #$0C : BEQ ..Big
	..Small	JSR LoadHitbox_Small00
		BRA ..Comp
	..Big	JSR LoadHitbox_Big00
	..Comp	JSL $03B72B|!BankB
		BCC ..Next2
		LDA !state,x : BEQ ..Kill
		CMP #$01 : BEQ ..Kill
		CMP #$06 : BCS $03 : JMP ..Trade
		CMP #$0A : BCC ..CatchMaybe
		CMP #$0C : BEQ ..Kill
	..Next2	PLX
		BRA .Next

		..CatchMaybe
		LDA !movementflags,x
		AND #$03
		CMP #$02 : BNE ..Kill
		STZ $00
		PLY : PHY
		LDA !sprite_x_low,y
		CMP !sprite_x_low,x
		LDA !sprite_x_high,y
		SBC !sprite_x_high,y
		BPL $02 : INC $00
		LDA !157C,x
		CMP $00 : BNE ..Kill
		TYA : STA $3500,x		; catch shell if facing it
		LDA !sprite_speed_x,y : STA !sprite_speed_x,x
		LDA #$0B : STA !SpriteAnimIndex		; change to kick animation
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
		LDA #$06 : STA !state,x
		PLX
		LDA #$01 : STA !state,x
		RTS

		..Kill
		JSR UpdateState_Shell_ConvertBack
		LDA #$0B : STA !state,x
		JSR SetDeathImage
		TXY
		PLX
		PHY
		LDA !sprite_status,x
		CMP #$0B : BNE ..safe
		PHY
		JSR UpdateState_Shell_ConvertBack
		PLY
		BRA ..Trade2
	..safe	LDA !sprite_x_low,y
		CMP !sprite_x_low,x
		LDA !sprite_x_high,y
		SBC !sprite_x_high,x
		BPL ..R
	..L	LDA #$F0 : BRA ..bump
	..R	LDA #$10
	..bump	STA !sprite_speed_x,y
		LDA #$E0 : STA !sprite_speed_y,y
		JMP .HandleScore

		..Trade
		JSR UpdateState_Shell_ConvertBack
		LDA #$0B : STA !state,x
		JSR SetDeathImage
		TXY
		PLX
		PHY
		..Trade2
		LDA #$0B : STA !state,x
		LDA !sprite_x_low,y
		CMP !sprite_x_low,x
		LDA !sprite_x_high,y
		SBC !sprite_x_high,x
		BPL ..LR
	..RL	LDA #$10 : BRA ..set
	..LR	LDA #$F0
	..set	STA !sprite_speed_x,x
		EOR #$FF : INC A
		STA !sprite_speed_x,y
		LDA #$E0
		STA !sprite_speed_y,x
		STA !sprite_speed_y,y
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
		JMP .HandleScore

	.XSpeed
		db $F0,$10

	SetDeathImage:
		LDA !extra_byte_2,x
		CMP #$06 : BEQ .Death
		CMP #$02 : BNE .Return
	.Death	LDA !extra_byte_1,x
		CMP #$02 : BEQ .Blue
		LDA #$07 : STA !SpriteAnimIndex
		RTS
	.Blue	LDA #$09 : STA !SpriteAnimIndex
	.Return	RTS


	ShellSight:
		LDA !movementflags,x
		AND #$03 : BEQ .Return
		CMP #$02 : BEQ .CatchHitbox
		LDY !157C,x
		LDA !sprite_x_low,x
		CLC : ADC .XDisp,y
		STA $04
		LDA !sprite_x_high,x
		ADC .XDisp+2,y
		STA $0A
		LDA !sprite_y_low,x : STA $05
		LDA !sprite_y_high,x : STA $0B
		LDA #$10
		STA $06
		STA $07
		BRA .Search

		.CatchHitbox
		JSR LoadHitbox_Small

		.Search
		LDA !new_sprite_num,x : STA $1695|!Base2
		PHX
		LDX.b #!SprSize
	-	LDA !sprite_status,x
		CMP #$08 : BCC .Next
		CMP #$0C : BEQ .Next
		LDA !extra_bits,x
		AND #$08 : BEQ .Next
		LDA $1695|!Base2
		CMP !new_sprite_num,x : BNE .Next
		LDA !state,x
		CMP #$01 : BNE .Next
		JSR LoadHitbox_Small00
		JSL $03B72B|!BankB
		BCC .Next
		TXY
		PLX
		LDA !movementflags,x
		AND #$03
		CMP #$02 : BNE .Jump

		.Catch
		TYA : STA $3500,x
		LDA #$0B : STA !SpriteAnimIndex
		TAY
		LDA Tilemap_Time,y : STA !SpriteAnimTimer
	.Return
		RTS

		.Jump
		LDA #$D8 : STA !sprite_speed_y,x
		LDY !157C,x
		LDA .XSpeed,y : STA !sprite_speed_x,x
		LDA #$08 : STA !state,x
		RTS

	.Next	DEX : BPL -
		PLX
		RTS


	.XDisp
		db $10,$F0
		db $00,$FF

	.XSpeed
		db $10,$F0






; Graphics scratch RAM guide:
; $00: 16-bit xpos of sprite on screen
; $02: 16-bit ypos of sprite on screen
; $04: x and ccc bits of sprite
; $05: $04 combined with y, x, and t bits of tile
; $06: draw wings flag (0 = skip wing tiles, 4 = draw wing tiles)
; $07: 
; $08: loop counter (number of tiles -1)
; $09: highest bit is a copy of s bit from hi OAM table
; $0A: 
; $0B: 
; $0C: 
; $0D: 
; $0E: 16-bit xpos of tile on screen

	Graphics:
		LDA !SpriteAnimIndex
		CMP #$0F : BNE +
		LDA !SpriteAnimTimer
		AND #$02 : BEQ +
		RTS
		+

		STZ !sprite_off_screen,x
		STZ $0F
		LDA !sprite_y_low,x : STA $02
		LDA !sprite_y_high,x : STA $03
		LDA !sprite_x_high,x : XBA
		LDA !sprite_x_low,x
		REP #$20
		SEC : SBC $1A
		CMP #$0180 : BCC +
		CMP #$FF80 : BCS +
		INC $0F
	+	CMP #$0100 : BCC +
		INC !sprite_off_screen,x
	+	STA $00
		LDA $02
		SEC : SBC $1C
		CMP #$0180 : BCC +
		CMP #$FF80 : BCS +
		INC $0F
	+	CMP #$00E0 : BCC +
		INC !sprite_off_screen,x
	+	STA $02
		SEP #$20
		LDA $0F : BEQ .Go				;\ despawn if too far offscreen
		STZ !sprite_status,x				;/
		LDA !state,x					;\
		CMP #$0A : BEQ +				; |
		CMP #$0B : BEQ +				; |
		.ReloadSprite					; |
		PHX						; |
		LDA !sprite_index_in_level,x : TAX		; | mark for reload
		LDA #$00 : STA !sprite_load_table,x		; | (unless dead)
		PLX						; |
	+	RTS						;/


		.Go
		LDA !sprite_off_screen,x : BNE ..nosmoke	; smoke effect when sliding
		LDA !SpriteAnimIndex
		CMP #$0B : BEQ ..smoke
		CMP #$0C : BEQ ..smoke
		CMP #$0D : BEQ ..smoke
		CMP #$0E : BNE ..nosmoke
		..smoke
		LDA !sprite_speed_x,x : BEQ ..nosmoke
		LDA !1588,x
		AND #$04 : BEQ ..nosmoke
		LDA $14
		AND #$07 : BNE ..nosmoke
		LDY #$03
	-	LDA $17C0|!Base2,y : BEQ +
		DEY : BPL -
		BRA ..nosmoke
	+	LDA #$03 : STA $17C0|!Base2,y
		LDA !sprite_x_low,x : STA $17C8|!Base2,y
		LDA !sprite_y_low,x
		CLC : ADC #$0A
		STA $17C4|!Base2,y
		LDA #$13 : STA $17CC|!Base2,y
		..nosmoke

		LDA !157C,x
		BEQ $02 : LDA #$40
		EOR #$40
		STA $04
		LDA !flipped,x : BNE ++
		LDA !state,x
		CMP #$0B : BNE +
	++	LDA #$80 : TSB $04				; vertical flip is sprite is dead or flipped
		LDA $02						;\
		SEC : SBC #$08					; |
		STA $02						; | move sprite 8px up if vertically flipped
		LDA $03						; |
		SBC #$00					; |
		STA $03						;/
	+	LDA !15F6,x
		LDY !state,x
		CPY #$05
		BNE $02 : LDA $14
		AND #$0E
		TSB $04

		LDY !sprite_oam_index,x
		LDA !extra_byte_2,x
		AND #$04
		STA $06

		PHX
		LDA !SpriteAnimIndex
		TAX
		LDA Tilemap_Tiles,x : STA $08
		LDA Tilemap_IndexHi,x : XBA
		LDA Tilemap_Index,x
		PHP
		REP #$10
		TAX

	.Loop	LDA Tilemap+3,x					;\
		AND #$04 : BEQ .Draw				; |
		AND $06 : BNE .Draw				; | check for wing tile and wing status
		INX #4						; |
		DEC $08 : BPL .Loop				;/
		JMP .Return					;

	.Draw	LDA Tilemap+3,x
		AND #$C1
		EOR $04
		STA $05
		LDA Tilemap+3,x
		AND #$02
		BEQ $02 : LDA #$80
		STA $09
		REP #$20
		LDA Tilemap,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		BIT $05-1 : BVC +				;\
		EOR #$FFFF : INC A				; | horizontal flip
		BIT $09-1					; |
		BMI $04 : CLC : ADC #$0008			;/
	+	CLC : ADC $00
		STA $0300|!Base2,y
		STA $0E
		INX
		CMP #$0100 : BCC +
		CMP #$FFF0 : BCC .BadY
	+	LDA Tilemap,x
		AND #$00FF
		CMP #$0080
		BCC $03 : ORA #$FF00
		BIT $05-1 : BPL + 				;\
		EOR #$FFFF : INC A				; | vertical flip
		BIT $09-1					; |
		BMI $04 : CLC : ADC #$0008			;/
	+	CLC : ADC $02
		CMP #$00E0 : BCC +
		CMP #$FFF0 : BCS +
	.BadY	LDA #$00E0
	+	STA $0301|!Base2,y
		INX
		SEP #$20

		LDA Tilemap,x : STA $0302|!Base2,y
		INX

		LDA Tilemap,x					;\ check wing flag
		AND #$04 : BEQ .NotWing				;/
		.Wing						;\
		LDA $05						; |
		ORA $64						; | wing always uses palette B
		AND.b #$0E^$FF					; |
		ORA #$06					; |
		BRA +						;/
		.NotWing					;\
		LDA $05						; | store YXPPCCCT byte
		ORA $64						; |
	+	STA $0303|!Base2,y				;/

		PHY
		REP #$20
		TYA
		LSR #2
		TAY
		SEP #$20
		LDA $0F
		AND #$01
		BIT $09
		BPL $02 : INC #2
		STA $0460|!Base2,y
		PLY
		INX
		INY #4
		DEC $08 : BMI .Return
		JMP .Loop

	.Return
		PLP
		PLX

		RTS



Tilemap:

	; format:
	; - xdisp
	; - ydisp
	; - tile number
	; - prop: yx---wst
	;		y: y bit of YXPPCCCT
	;		x: x bit of YXPPCCCT
	;		w: wing, if set then this tile is only drawn if sprite has wings (this tile will always use palette B)
	;		s: size bit of hi OAM table
	;		t: t bit of YXPPCCCT
	; repeat for each tile
	.walk1
	db $0A,$F2,!wing1,$04|(!wing1>>8)
	db $F8,$E0,!head1+$00,$02|(!head1>>8)
	db $00,$E0,!head1+$01,$02|(!head1>>8)
	db $F8,$F0,!body1+$00,$02|(!body1>>8)
	db $08,$F0,!body1+$02,$02|(!body1>>8)
	db $08,$F8,!body1+$12,$02|(!body1>>8)
	db $00,$00,!body1+$21,$02|(!body1>>8)

	.walk2
	db $0A,$E6,!wing2,$06|(!wing2>>8)
	db $F8,$DE,!head1+$00,$02|(!head1>>8)
	db $00,$DE,!head1+$01,$02|(!head1>>8)
	db $F8,$EE,!body2+$00,$02|(!body2>>8)
	db $08,$EE,!body2+$02,$02|(!body2>>8)
	db $F8,$FE,!body2+$20,$02|(!body2>>8)
	db $08,$FE,!body2+$22,$02|(!body2>>8)

	.wingrun1		; for wing run with open wing, alternate this with .walk2
	db $0A,$E8,!wing2,$06|(!wing2>>8)
	db $F8,$E0,!head1+$00,$02|(!head1>>8)
	db $00,$E0,!head1+$01,$02|(!head1>>8)
	db $F8,$F0,!body1+$00,$02|(!body1>>8)
	db $08,$F0,!body1+$02,$02|(!body1>>8)
	db $08,$F8,!body1+$12,$02|(!body1>>8)
	db $00,$00,!body1+$21,$02|(!body1>>8)

	.wingrun2		; for wing run with closed wing, alternate this with .walk1
	db $0A,$F0,!wing1,$04|(!wing1>>8)
	db $F8,$DE,!head1+$00,$02|(!head1>>8)
	db $00,$DE,!head1+$01,$02|(!head1>>8)
	db $F8,$EE,!body2+$00,$02|(!body2>>8)
	db $08,$EE,!body2+$02,$02|(!body2>>8)
	db $F8,$FE,!body2+$20,$02|(!body2>>8)
	db $08,$FE,!body2+$22,$02|(!body2>>8)

	.turn
	db $F8,$E0,!head2+$00,$02|(!head2>>8)
	db $00,$E0,!head2+$01,$02|(!head2>>8)
	db $F8,$F0,!body3+$00,$02|(!body3>>8)
	db $08,$F0,!body3+$02,$02|(!body3>>8)
	db $F8,$00,!body3+$20,$02|(!body3>>8)
	db $08,$00,!body3+$22,$02|(!body3>>8)
	db $0C,$EB,!wing2,$06|(!wing2>>8)

	.shell1
	db $FC,$F8,!shell1+$00,$02|(!shell1>>8)
	db $FC,$F8,!shell1+$00,$42|(!shell1>>8)
	db $FC,$00,!shell1+$10,$02|(!shell1>>8)
	db $FC,$00,!shell1+$10,$42|(!shell1>>8)
	db $0D,$F8,!wing1,$44|(!wing1>>8)
	db $0D,$F8,!wing1,$04|(!wing1>>8)

	.shell2
	db $09,$F8,!wing1,$04|(!wing1>>8)
	db $FC,$F8,!shell2+$00,$02|(!shell2>>8)
	db $04,$F8,!shell2+$01,$02|(!shell2>>8)
	db $FC,$00,!shell2+$10,$02|(!shell2>>8)
	db $04,$00,!shell2+$11,$02|(!shell2>>8)

	.shell3
	db $0D,$F8,!wing1,$44|(!wing1>>8)
	db $0D,$F8,!wing1,$04|(!wing1>>8)
	db $FC,$F8,!shell3+$00,$02|(!shell3>>8)
	db $FC,$F8,!shell3+$00,$42|(!shell3>>8)
	db $FC,$00,!shell3+$10,$02|(!shell3>>8)
	db $FC,$00,!shell3+$10,$42|(!shell3>>8)

	.shell4
	db $09,$F8,!wing1,$44|(!wing1>>8)
	db $FC,$F8,!shell2+$00,$42|(!shell2>>8)
	db $04,$F8,!shell2+$01,$42|(!shell2>>8)
	db $FC,$00,!shell2+$10,$42|(!shell2>>8)
	db $04,$00,!shell2+$11,$42|(!shell2>>8)

	.small_walk1
	db $05,$00,!wing1,$04|(!wing1>>8)
	db $F8,$F0,!small_head1,$02|(!small_head1>>8)
	db $F8,$00,!small_body1+$00,$02|(!small_body1>>8)
	db $00,$00,!small_body1+$01,$02|(!small_body1>>8)

	.small_walk2
	db $05,$F4,!wing2,$06|(!wing2>>8)
	db $F8,$F1,!small_head1,$02|(!small_head1>>8)
	db $F8,$00,!small_body2+$00,$02|(!small_body2>>8)
	db $00,$00,!small_body2+$01,$02|(!small_body2>>8)

	.small_angry_walk1
	db $05,$00,!wing1,$04|(!wing1>>8)
	db $F8,$F0,!small_head2,$02|(!small_head2>>8)
	db $F8,$00,!small_body1+$00,$02|(!small_body1>>8)
	db $00,$00,!small_body1+$01,$02|(!small_body1>>8)

	.small_angry_walk2
	db $05,$F4,!wing2,$06|(!wing2>>8)
	db $F8,$F1,!small_head2,$02|(!small_head2>>8)
	db $F8,$00,!small_body2+$00,$02|(!small_body2>>8)
	db $00,$00,!small_body2+$01,$02|(!small_body2>>8)

	.small_angry_kick
	db $FA,$F1,!small_head2,$02|(!small_head2>>8)
	db $F8,$00,!small_body3+$00,$02|(!small_body3>>8)
	db $00,$00,!small_body3+$01,$02|(!small_body3>>8)
	db $07,$F6,!wing2,$06|(!wing2>>8)

	.small_angry_slide1
	db $04,$03,!wing1,$04|(!wing1>>8)
	db $F8,$F8,!small_head3+$00,$00|(!small_head3>>8)
	db $F8,$00,!small_head3+$10,$00|(!small_head3>>8)
	db $F8,$08,!small_head3+$20,$00|(!small_head3>>8)
	db $00,$00,!small_body4,$02|(!small_body4>>8)
	db $00,$F0,!small_legs1,$02|(!small_legs1>>8)

	.small_angry_slide2
	db $04,$F7,!wing2,$06|(!wing2>>8)
	db $F8,$F8,!small_head4+$00,$00|(!small_head4>>8)
	db $F8,$00,!small_head4+$10,$00|(!small_head4>>8)
	db $F8,$08,!small_head4+$20,$00|(!small_head4>>8)
	db $00,$00,!small_body4,$02|(!small_body4>>8)
	db $00,$F0,!small_legs2,$02|(!small_legs2>>8)

	.smushed
	db $FC,$08,!smushed1,$00|(!smushed1>>8)
	db $04,$08,!smushed2,$00|(!smushed2>>8)
	db $FC,$08,!smushed1,$40|(!smushed1>>8)

	.shellflap1
	db $FC,$F8,!shell1+$00,$02|(!shell1>>8)
	db $FC,$F8,!shell1+$00,$42|(!shell1>>8)
	db $FC,$00,!shell1+$10,$02|(!shell1>>8)
	db $FC,$00,!shell1+$10,$42|(!shell1>>8)
	db $0D,$F8,!wing1,$44|(!wing1>>8)
	db $0D,$F8,!wing1,$04|(!wing1>>8)

	.shellflap2
	db $FC,$F8,!shell1+$00,$02|(!shell1>>8)
	db $FC,$F8,!shell1+$00,$42|(!shell1>>8)
	db $FC,$00,!shell1+$10,$02|(!shell1>>8)
	db $FC,$00,!shell1+$10,$42|(!shell1>>8)
	db $0D,$F0,!wing2,$46|(!wing2>>8)
	db $0D,$F0,!wing2,$06|(!wing2>>8)



	.Index
	db .walk1-Tilemap			; 00
	db .walk2-Tilemap			; 01
	db .turn-Tilemap			; 02
	db .shell1-Tilemap			; 03
	db .shell2-Tilemap			; 04
	db .shell3-Tilemap			; 05
	db .shell4-Tilemap			; 06
	db .small_walk1-Tilemap			; 07
	db .small_walk2-Tilemap			; 08
	db .small_angry_walk1-Tilemap		; 09
	db .small_angry_walk2-Tilemap		; 0A
	db .small_angry_walk1-Tilemap		; 0B
	db .small_angry_kick-Tilemap		; 0C
	db .small_angry_slide1-Tilemap		; 0D
	db .small_angry_slide2-Tilemap		; 0E
	db .smushed-Tilemap			; 0F
	db .shellflap1-Tilemap			; 10
	db .shellflap2-Tilemap			; 11
	db .walk1-Tilemap			; 12 \ closed wing
	db .wingrun2-Tilemap			; 13 /
	db .wingrun1-Tilemap			; 14 \ open wing
	db .walk2-Tilemap			; 15 /



	; hi byte complements because the tilemap table got bigger than 256 bytes
	.IndexHi
	db (.walk1-Tilemap)>>8			; 00
	db (.walk2-Tilemap)>>8			; 01
	db (.turn-Tilemap)>>8			; 02
	db (.shell1-Tilemap)>>8			; 03
	db (.shell2-Tilemap)>>8			; 04
	db (.shell3-Tilemap)>>8			; 05
	db (.shell4-Tilemap)>>8			; 06
	db (.small_walk1-Tilemap)>>8		; 07
	db (.small_walk2-Tilemap)>>8		; 08
	db (.small_angry_walk1-Tilemap)>>8	; 09
	db (.small_angry_walk2-Tilemap)>>8	; 0A
	db (.small_angry_walk1-Tilemap)>>8	; 0B
	db (.small_angry_kick-Tilemap)>>8	; 0C
	db (.small_angry_slide1-Tilemap)>>8	; 0D
	db (.small_angry_slide2-Tilemap)>>8	; 0E
	db (.smushed-Tilemap)>>8		; 0F
	db (.shellflap1-Tilemap)>>8		; 10
	db (.shellflap2-Tilemap)>>8		; 11
	db (.walk1-Tilemap)>>8			; 12
	db (.wingrun2-Tilemap)>>8		; 13
	db (.wingrun1-Tilemap)>>8		; 14
	db (.walk2-Tilemap)>>8			; 15


	.Tiles
	db $06					; 00
	db $06					; 01
	db $06					; 02
	db $05					; 03
	db $04					; 04
	db $05					; 05
	db $04					; 06
	db $03					; 07
	db $03					; 08
	db $03					; 09
	db $03					; 0A
	db $03					; 0B
	db $03					; 0C
	db $05					; 0D
	db $05					; 0E
	db $02					; 0F
	db $05					; 10
	db $05					; 11
	db $06					; 12
	db $06					; 13
	db $06					; 14
	db $06					; 15

	.Time
	db $08					; 00
	db $08					; 01
	db $10					; 02
	db $04					; 03
	db $04					; 04
	db $04					; 05
	db $04					; 06
	db $08					; 07
	db $08					; 08
	db $08					; 09
	db $08					; 0A
	db $20					; 0B
	db $10					; 0C
	db $0C					; 0D
	db $0C					; 0E
	db $FF					; 0F
	db $08					; 10
	db $08					; 11
	db $08					; 12
	db $08					; 13
	db $08					; 14
	db $08					; 15

	.Next
	db $01					; 00
	db $00					; 01
	db $00					; 02
	db $04					; 03
	db $05					; 04
	db $06					; 05
	db $03					; 06
	db $08					; 07
	db $07					; 08
	db $0A					; 09
	db $09					; 0A
	db $0C					; 0B
	db $09					; 0C
	db $0E					; 0D
	db $0D					; 0E
	db $0F					; 0F
	db $11					; 10
	db $10					; 11
	db $13					; 12
	db $12					; 13
	db $15					; 14
	db $14					; 15


	Halve:
		BPL .pos
	.neg	EOR #$FF
		LSR A
		EOR #$FF
		RTS
	.pos	LSR A
		RTS


	WithinBounds:
	.Y	LDA $98 : BMI ..0
		CMP $13D7|!Base2 : BCC .X
		LDA $13D7|!Base2
		SEC : SBC #$0010
		BRA ..W

	..0	LDA #$0000
	..W	STA $98

	.X	LDA $9A : BMI ..0
		SEP #$20
		XBA
		CMP $5E : BCC .R
		DEC A
		XBA
		LDA #$F0
		REP #$20
		STA $9A
		RTS
	..0	STZ $9A
		RTS

	.R	REP #$20
		RTS


	ReadSpeed:
		.Normal
		LDA !extra_byte_1,x
		AND #$03
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04
		BEQ $01 : INY
		LDA SpeedTable_Normal,y
		LDY !157C,x
		BEQ $03 : EOR #$FF : INC A
		RTS

		.Flight
		LDA !extra_byte_1,x
		AND #$03
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04
		BEQ $01 : INY
		LDA SpeedTable_Flight,y
		LDY !157C,x
		BEQ $03 : EOR #$FF : INC A
		RTS

		.Naked
		LDA !extra_byte_1,x
		AND #$03
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04
		BEQ $01 : INY
		LDA SpeedTable_Naked,y
		LDY !157C,x
		BEQ $03 : EOR #$FF : INC A
		RTS

		.Shell
		LDA !extra_byte_1,x
		AND #$03
		ASL A
		TAY
		LDA !extra_bits,x
		AND #$04
		BEQ $01 : INY
		LDA SpeedTable_Shell,y
		LDY !157C,x
		BEQ $03 : EOR #$FF : INC A
		RTS

	if !breakblocks
	ShellSpeed:
		PHP
		JSR .Blocks
		PLP
		LDA !15B8,x					;\
		CMP #$03 : BEQ .Slope				; |
		CMP #$FD : BNE .NoSlope				; |
		.Slope						; |
		EOR !sprite_speed_x,x : BMI .Bounce		; |
		.SlideDown					; | 45 degree slopes, baby!
		LDA #$40 : STA !sprite_speed_y,x		; |
		BRA .NoSlope					; |
		.Bounce						; |
		LDA #$C0 : STA !sprite_speed_y,x		; |
		.NoSlope					;/
		JSL $01802A|!BankB
		RTS


	.Blocks
		LDA !sprite_speed_x,x
		ASL A
		ROL A
		AND #$01
		TAY
		LDA !sprite_x_low,x
		CLC : ADC .BlockDispX,y
		STA $9A
		LDA !sprite_x_high,x
		ADC .BlockDispX+2,y
		STA $9B
		LDA !sprite_y_low,x
		SEC : SBC #$08
		STA $98
		LDA !sprite_y_high,x
		SBC #$00
		STA $99
		STZ $1933|!Base2
		REP #$20
		JSR WithinBounds
	if !actslike == 1
		JSR GetTile
	else
		%GetMap16()
	endif
		CMP #$01B4 : BEQ +			;\ look for triangle blocks
		CMP #$01B5 : BNE ++			;/
	+	JSR .TriangleBounce			; speed
		BRA +++
	++	JSR .HandleBlock			; if not triangle block, handle it
	+++	LDA $98
		CLC : ADC #$0010
		STA $98
		JSR WithinBounds
	if !actslike == 1
		JSR GetTile
	else
		%GetMap16()
	endif
		CMP #$01B4 : BEQ .TriangleBounce
		CMP #$01B5 : BEQ .TriangleBounce
	.HandleBlock
		LDY.b #BreakableTiles_End-BreakableTiles
	-	DEY #2 : BMI +
		CMP BreakableTiles,y : BEQ .BreakBlock
		BRA -
	+	RTS

	.TriangleBounce
		PHP
		SEP #$20
		LDA #$C0 : STA !sprite_speed_y,x
		PLP
		RTS

	.BreakBlock
		PHP
		SEP #$20
		LDA #$0F : STA $1887|!Base2	; shake screen a bit
		LDA #$07 : STA $1DFC|!Base2	; SFX
		LDA #$00 : XBA			;\ map16 tile number (empty space)
		LDA #$25			;/
		%ChangeMap16()			; generate
		PHB				;\
		LDA #$02			; |
		PHA				; | bank wrapper
		PLB				; |
		LDA #$00			; |> normal shatter (01 will spawn rainbow brick pieces)
		JSL $028663|!BankB		; |> shatter block
		PLB				;/
		PLP
		RTS

	.BlockDispX
		db $14,$FC
		db $00,$FF
	endif

	if !actslike == 1
	GetTile:
		%GetMap16()
		PHP
		REP #$30
		AND #$3FFF
		ASL A
		TAY
		LDA.l !Map16ActsLike : STA $00
		LDA.l !Map16ActsLike+1 : STA $01
		LDA [$00],y
		PLP
		RTS
	endif


	if !spinarmor&!firearmor == 0
	BigPuff:
		LDY #$03
	-	LDA .PuffData,y : STA $00
		LDA .PuffData+4,y : STA $01
		STZ $02
		STZ $03
		LDA #$01
		PHY
		JSR SpawnExtended
		BCS +
		LDA #$0F : STA $176F|!Base2,y
	+	PLY
		DEY : BPL -
		RTS
	.PuffData
		db $F8,$08,$F8,$08
		db $F8,$F8,$08,$08
	endif

	SpawnExtended:
		; pixi macros are in fact not based
		XBA						; num to B
		LDY #$07					; loop over 8 extra sprite slots (last 2 are for fireballs)
	.loop	LDA $170B|!Base2,y : BEQ .thisone		; check slots
		DEY : BPL .loop					;
	.failed	SEC						; set carry if none is spawned
		RTL						;
	.thisone
		XBA : STA $170B|!Base2,y 			;
		LDA $00						;\
		CLC : ADC !E4,x					; |
		STA $171F|!Base2,y				; |
		LDA #$00					; | get x position
		BIT $00 : BPL +					; |
		DEC						; |
	+	ADC !14E0,x					; |
		STA $1733|!Base2,y				;/
		LDA $01						;\ 
		CLC : ADC !D8,x					; |
		STA $1715|!Base2,y				; |	
		LDA #$00					; | get y position
		BIT $01 : BPL +					; |
		DEC						; |
	+	ADC !14D4,x					; |
		STA $1729|!Base2,y				;/
		LDA $02 : STA $1747|!Base2,y			;\ speeds
		LDA $03 : STA $173D|!Base2,y			;/
		CLC						; successful return
		RTS


	HurtPlayer:
		LDA $187A|!Base2 : BEQ .NoYoshi
		LDA $1490|!Base2 : BNE .Return
		LDY $18E2|!Base2 : BEQ .NoYoshi
		DEY
		LDA #$10 : STA !163E,y
		LDA #$03 : STA $1DFA|!Base2			; disable yoshi drums
		LDA #$13 : STA $1DFC|!Base2			; lose yoshi sfx
		LDA #$02 : STA.w !C2|!Base1,y
		STZ $187A|!Base2
		STZ $7B
		LDA #$C0 : STA $7D
		PHX
		TYX
		JSL SUB_HORZ_POS
		PHX
		TYX
		LDA.l $01EBBE,x
		PLX
		STA !sprite_speed_x,x
		STZ !1594,x
		STZ !151C,x
		STZ $18AE|!Base2
		STZ $0DC1|!Base2
		LDA #$30 : STA $1497|!Base2

		LDA !sprite_y_low,x
		SEC : SBC #$04
		STA $96
		STA $D3
		LDA !sprite_y_high,x
		SBC #$00
		STA $97
		STA $D4
		PLX

		.Return
		RTS

		.NoYoshi
		JSL $00F5B7|!BankB
		RTS


	CheckQuake:
		LDA $07 : PHA
		CLC : ADC #$08
		STA $07
		LDA #$10
		STA $02
		STA $03
		LDY #$03
	-	LDA $16CD|!Base2,y : BEQ +
		LDA $16D1|!Base2,y : STA $00
		LDA $16D5|!Base2,y : STA $08
		LDA $16D9|!Base2,y : STA $01
		LDA $16DD|!Base2,y : STA $09
		JSL $03B72B|!BankB
		BCS .Return
	+	DEY : BPL -
		CLC
	.Return	PLA : STA $07
		RTS


