;=====================;
; JOINT CLUSTER CODES ;
;=====================;

; input:
;	A = angle (0-1023 is a full rotation)
; output:
;	A = sine value
	macro Trig()
		PHX
		ASL #2
		AND #$03FF
		CMP #$0200
		PHP
		AND #$01FF
		TAX
		LDA.l !TrigTable,x
		PLP
		BCC $04 : EOR #$FFFF : INC A
		PLX
	endmacro

; input:
;	cache1 = coordinate 1
;	cache2 = coordinate 2
;	cache3 = coordinate 3
;	cache4 = coordinate 4
;	cache5 = angle
;
; output:
;	cache7 = coordinate 1
;	cache8 = coordinate 2
	macro Apply3DRotation()
		PHB : PHK : PLB
		LDA !3D_Cache5
		PHA
		CLC : ADC #$0040
		%Trig()
		STA !3D_Cache6			; cache2 = cos(a)
		PLA
		%Trig()
		STA !3D_Cache5			; cache1 = sin(a)

		LDA !3D_Cache6 : STA $2251
		LDA !3D_Cache1 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $06
		LDA !3D_Cache5 : STA $2251
		LDA !3D_Cache2 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $08
		LDA $06
		CLC : ADC $08
		STA !3D_Cache7			; cache7 = coordinate 1 (X or Y)

		LDA !3D_Cache5 : STA $2251
		LDA !3D_Cache3 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $06
		LDA !3D_Cache6 : STA $2251
		LDA !3D_Cache4 : STA $2253
		NOP : BRA $00
		LDA $2307 : STA $08
		LDA $06
		CLC : ADC $08
		STA !3D_Cache8			; cache8 = coordinate 2 (Y or Z)
		PLB
	endmacro





; here, X indexes the current joint and Y indexes the parent joint
; before calling, store pointers to the tilemaps at !3D_TilemapCache and load A with $3320,x
	Update2DCluster:

		LSR A						;\
		ROR A						; |
		LSR A						; | xflip flag
		AND #$40					; |
		STA !BigRAM+$7F					;/

		PHB : PHB					;\ bank on stack and in cache
		PLA : STA.l !3D_BankCache			;/
		PHX						;\ back up X/P
		PHP						;/
		STZ $2250					; prepare multiplication
		LDA.b #!3D_Base>>16				;\ bank
		PHA : PLB					;/
		REP #$30					; all regs 16-bit
		STZ $06						; clear tilemap continue flag

		LDX #$0000					;\
		LDY #$0000					; |
	.Loop	LDA.w !2D_Slot,x				; | search for joints
		AND #$00FF : BNE .Process			; |
		JMP .Next					; |
		.Process					;/
		LDY.w !2D_Attachment,x				;\
		STY $00						; | core has no parent joint
		CPX $00 : BNE .Joint				; |
		JMP .Core					;/

	.Joint	SEP #$20					; A 8-bit
		LDA.w !2D_Rotation,y				;\
		CLC : ADC.w !2D_Angle,x				; | get total rotation
		STA.w !2D_Rotation,x				;/
		PHB : PHK : PLB					; start of bank wrapper
		REP #$20					; A 16-bit
		AND #$00FF					;\ full angle
		ASL #2						;/
		PHA						; preserve
		CLC : ADC #$0040				;\ cosine
		%Trig()						;/
		STA $2251					;\
		LDA !2D_Distance,x : STA $2253			; | X offset
		BRA $00 : NOP					; |
		LDA $2307 : STA $00				;/
		PLA						;\ sine
		%Trig()						;/
		STA $2251					;\
		LDA !2D_Distance,x : STA $2253			; | Y offset
		BRA $00 : NOP					; |	
		LDA $2307					;/
		PLB						; restore bank
		CLC : ADC.w !2D_Y,y				;\ store Y offset of joint
		STA.w !2D_Y,x					;/
		LDA $00						;\
		CLC : ADC.w !2D_X,y				; | store X offset of joint
		STA.w !2D_X,x					;/
		BRA .AppendTilemap				; go to tilemap code

	.Core	SEP #$20					;\
		LDA.w !2D_Angle,x : STA.w !2D_Rotation,x	; | save angle as total rotation
		REP #$20					;/

	.AppendTilemap
	; add tilemap to !BigRAM here
		LDA.w !2D_X,x					;\
		SEC : SBC.w !2D_X,y				; |
		STA $00						; |
		LDA.w !2D_Y,x					; | tilemap transcription parameters
		SEC : SBC.w !2D_Y,y				; |
		STA $01						; |
		STZ $02						;/
		LDA.w !2D_Tilemap,x				; A = tilemap index
		PHB : PHK : PLB					; start of bank wrapper
		PHX						; push X
		PHP						; push P
		SEP #$10					; index 8-bit
		REP #$20					; A 16-bit
		AND #$00FF					;\
		ASL A						; | get tilemap location
		TAX						; |
		LDA !3D_TilemapCache,x				;/
		LDX $06 : BNE .NotInit				;\
		STZ !BigRAM+0					; | check init
		.NotInit					;/
		STA $04						;\
		LDY #$00					; |
		LDA ($04)					; |
		AND #$00FF					; |
		STA $08						; |
		CLC : ADC !BigRAM+0				; | set up tilemap read and check for alt GFX index
		STA !BigRAM+0					; |
		INC $04						; |
		LDA ($04)					; |
		INC $04						; |
		SEP #$20					; |
		CMP #$00 : BEQ .LoopTM				;/

		PEI ($00)					;\ back these up
		PHX						;/
		TAX						;\
		LDA !GFX_status,x				; |
		STZ $00						; |
		STA $01						; |
		AND #$70					; | unpack tile number offset
		ASL A						; |
		STA $00						; |
		LDA $01						; |
		AND #$0F					; |
		ORA $00						;/
		CLC : ADC $03					;\ store new tile number offset
		STA $03						;/
		LDA $01						;\
		ASL A						; |
		ROL A						; | store new property bits
		AND #$01					; |
		EOR $02						; |
		STA $02						;/
		PLX						;\
		REP #$20					; | restore these
		PLA : STA $00					; |
		SEP #$20					;/

	.LoopTM	LDA ($04),y					;\
		EOR $02						; | prop
		STA !BigRAM+2,x					; |
		INY						;/
		LDA $00						;\
		BIT !BigRAM+$7F					; |
		BVC $02 : EOR #$FF				; > extra xflip to account for tilemap loader
		CLC : ADC ($04),y				; | X
		STA !BigRAM+3,x					; |
		INY						;/
		LDA ($04),y					;\
		CLC : ADC $01					; | Y
		STA !BigRAM+4,x					; |
		INY						;/
		LDA ($04),y					;\
		CLC : ADC $03					; | tile
		STA !BigRAM+5,x					; |
		INY						;/
		INX #4						;\ loop
		CPY $08 : BCC .LoopTM				;/
		STX $06						; save index
		PLP						; restore P
		PLX						; restore X
		PLB						; end of bank wrapper

	.Next	TXA						;\
		CLC : ADC #$000C				; |
		TAX						; | loop through entire table
		CPX #$0200 : BCS .Return			; |
		JMP .Loop					;/
		.Return						;\
		PLP						; |
		PLX						; | restore stuff and return
		PLB						; |
		RTL						;/






Update3DCluster:

	; can only be called by SA-1

	; input: A = xflip bit (usually just sprite direction, 0 to not use)


; RAM use
; $00-$01: parent X position (16-bit)
; $02-$03: parent Y position (16-bit)
; $04-$05: parent Z position (16-bit)
; $06-$07: calculating X position (16-bit)
; $08-$09: calculating Y position (16-bit)
; $0A-$0B: calculating Z position (16-bit)


; each parent position is pushed on the stack, then loaded into $06-$0B


; method:
;	- start processing from index 0 and go all the way up to the final index
;	- the core has to be the first (lowest index) object of each cluster
;	- only the core has a true X/Y/Z coordinate (core is defined as a node that is its own parent)
;	- when an attachment is processed, its X/Y/Z coordinates are written based on the parent's X/Y/Z coordinates
;	- therefore, each attachment must be processed after its parent

		LSR A					;\
		ROR A					; |
		LSR A					; | xflip flag
		AND #$40				; |
		STA !BigRAM+$7F				;/

		PHB : PHB				;\ bank on stack and in cache
		PLA : STA.l !3D_BankCache		;/
		PHX					;\ back up X/P
		PHP					;/
		STZ $2250				; prepare multiplication
		LDA.b #!3D_Base>>16			;\ DB
		PHA : PLB				;/
		REP #$30				; all regs 16-bit


	; processing, step 1
	; here go through the tree of joints, calculating the coordinates of each one
	; core rotation is not yet applied

		LDX #$0000				;\
		LDY #$0000				; |
	-	LDA.w !3D_Slot,y			; |
		AND #$00FF : BEQ .Next			; | search for non-core joints
		TYA					; |
		CMP.w !3D_Attachment,y : BEQ .Core	; |
		LDX.w !3D_Attachment,y			;/
		JSR .UpdateJoint			; process joint
		BRA .Next				; then go to the next one
		.Core					;\
		PHY					; |
		LDA.w !3D_X,y : PHA			; | store core coordinates on the stack
		LDA.w !3D_Y,y : PHA			; |
		LDA.w !3D_Z,y : PHA			;/
		.Next					;\
		TYA					; |
		CLC : ADC #$0010			; | get next joint
		TAY					; |
		CPY #$0200 : BCC -			;/


	; processing, step 2
	; here, we go through the tree of joints again
	; this time we only apply core rotation

		PLA : STA $04
		PLA : STA $02
		PLA : STA $00
		PLX
		LDA.w !3D_AngleXY,x : BNE +		;\ skip rotation if no angles are set
		LDA.w !3D_AngleXZ,x : BEQ ++		;/
	+	JSR Transform3DCluster			; rotate around axes
	++

		STZ $0C
		LDX #$0000
		LDY #$0000
		STZ.w !3D_AssemblyCache			; how many objects will be added to tilemap
	-	LDA.w !3D_Slot,y : BEQ +
		LDA.w !3D_X,y
		SEC : SBC $00
		STA.w !3D_AssemblyCache+$02,x
		LDA.w !3D_Y,y
		SEC : SBC $02
		STA.w !3D_AssemblyCache+$03,x
		LDA.w !3D_Z,y
		AND #$00FF
		STA.w !3D_AssemblyCache+$04,x
		LDA.w !3D_Extra,y : STA.w !3D_AssemblyCache+$06,x
		INX #8
		STX.w !3D_AssemblyCache			; increment header
		INC $0C					; increment object count

	+	TYA
		CLC : ADC #$0010
		TAY
		CPY #$0200 : BCC -


	; processing, step 3
	; now all objects are in !3D_AssemblyCache
	; first 2 bytes is header
	; X is written to X+0
	; Y is written to X+1
	; Z is written to X+2
	; X+3 is clear (nonzero signals that this has been taken)
	; X+4 and X+5 is tilemap data
	; now we sort by Z value and transcribe the tilemaps from highest to lowest


	; key:
	; $0B = highest Z found so far
	; $0C = how many objects there are
	; $0D = how many objects have been transcribed
	; $0E = index of currently highest Z

		LDX #$0000
		LDY #$0000
		SEP #$20
		STZ $0B
		STZ $06						; for tilemap assembly

	.Loop	LDA.w !3D_AssemblyCache+$05,y : BNE +
		LDA.w !3D_AssemblyCache+$04,y
		CMP $0B : BCC +
		STA $0B
		STY $0E

	+	INY #8
		CPY.w !3D_AssemblyCache : BCC .Loop

	.Z	LDY $0E
		REP #$20
		LDA.w !3D_AssemblyCache+$02,y : STA $00		; X/Y offset
		STZ $02						; tile/prop data
		PHY
		LDA.w !3D_AssemblyCache+$06,y
		AND #$00FF
		ASL A
		TAY
		LDA.w !3D_TilemapPointer : STA $08
		SEP #$20
		PHB
		LDA.w !3D_BankCache : PHA : PLB
		REP #$20
		LDA ($08),y

	; add tilemap to !BigRAM here
		PHX
		PHP
		SEP #$10
		REP #$20
		LDX $06 : BNE .NotInit
		STZ !BigRAM+0
		.NotInit
		STA $04
		LDY #$00
		LDA ($04)
		AND #$00FF			; tilemap can not be larger than 256 bytes
		STA $08
		CLC : ADC !BigRAM+0
		STA !BigRAM+0
		INC $04
		LDA ($04)			; > get hi byte of header (GFX status to add)
		INC $04
		SEP #$20
		CMP #$00 : BEQ .LoopTM		; if index is 0, just start

		PEI ($00)			;\ back these up
		PHX				;/
		TAX				;\
		LDA !GFX_status,x		; |
		STZ $00				; |
		STA $01				; |
		AND #$70			; | unpack tile number offset
		ASL A				; |
		STA $00				; |
		LDA $01				; |
		AND #$0F			; |
		ORA $00				;/
		CLC : ADC $03			;\ store new tile number offset
		STA $03				;/
		LDA $01				;\
		ASL A				; |
		ROL A				; | store new property bits
		AND #$01			; |
		EOR $02				; |
		STA $02				;/
		PLX				;\
		REP #$20			; | restore these
		PLA : STA $00			; |
		SEP #$20			;/

	.LoopTM	LDA ($04),y			;\
		EOR $02				; | Prop
		STA !BigRAM+2,x			; |
		INY				;/
		LDA $00				;\
		BIT !BigRAM+$7F			; |
		BVC $02 : EOR #$FF		; > extra xflip to account for tilemap loader
		CLC : ADC ($04),y		; | X
		STA !BigRAM+3,x			; |
		INY				;/
		LDA ($04),y			;\
		CLC : ADC $01			; | Y
		STA !BigRAM+4,x			; |
		INY				;/
		LDA ($04),y			;\
		CLC : ADC $03			; | Tile
		STA !BigRAM+5,x			; |
		INY				;/
		INX #4
		CPY $08 : BCC .LoopTM
		STX $06
		PLP
		PLX

		PLB
		PLY
		SEP #$20
		STZ $0B
		INX #4
		LDA #$FF : STA.w !3D_AssemblyCache+$05,y
		LDY #$0000
		INC $0D
		LDA $0D
		CMP $0C : BEQ $03 : JMP .Loop

		.Return
		PLP
		PLX
		PLB
		RTL

; process:
;
; z = d * cos(v)
; r = d * sin(v)
; x = r * cos(h)
; y = r * sin(h)
;
; add offsets to parent coordinates to get attachment coordinates

		.UpdateJoint
		LDA.w !3D_X,x : STA $00			;\
		LDA.w !3D_Y,x : STA $02			; | parent coordinates
		LDA.w !3D_Z,x : STA $04			;/
		PHY					;\
		PHP					; |
		SEP #$20				; |
		STZ $0D					; |
		STZ $0E					; | search for parent joint
		STZ $0F					; |
	-	STY $08					; |
		LDX.w !3D_Attachment,y			; |
		CPX $08 : BEQ +				;/
		STX $08					;\
		LDY.w !3D_Attachment,x			; | if parent is core, ignore its rotations for now
		CPY $08 : BEQ +				;/
		LDA.w !3D_AngleH,x			;\
		CLC : ADC $0E				; |
		STA $0E					; |
		LDA.w !3D_AngleV,x			; | add parent rotations...
		CLC : ADC $0F				; | ...and keep going up the tree all the way to the core
		STA $0F					; | this way we will get the full rotations no matter how long the chain is
		TXY					; |
		BRA -					;/
	+	PLP					;\ prepare index
		PLY					;/

		PHX					;\ preserve X and swap with Y so we can use more effective DB
		TYX					;/

		PHB : PHK : PLB				; bank wrapper start

		LDA !3D_AngleV,x			;\
		CLC : ADC $0F				; |
		PHA					; | get cosine of v
		CLC : ADC #$0040			; |
		%Trig()					;/
		STA $2251				;\
		LDA !3D_Distance,x : STA $2253		; | distance on XY plane
		NOP : BRA $00				; |
		LDA $2307 : STA $08			;/
		PLA					;\ get sine of v
		%Trig()					;/
		STA $2251				;\
		LDA !3D_Distance,x : STA $2253		; | Z coordinate
		NOP : BRA $00				; |
		LDA $2308 : STA $0A			;/

		LDA !3D_AngleH,x			;\
		CLC : ADC $0E				; |
		PHA					; | get cosine of h
		CLC : ADC #$0040			; |
		%Trig()					;/
		STA $2251				;\
		LDA $08 : STA $2253			; | X coordinate
		NOP : BRA $00				; |
		LDA $2308 : STA $06			;/

		PLA					;\ get sine of h
		%Trig()					;/
		STA $2251				;\
		LDA $08 : STA $2253			; | Y coordinate
		NOP : BRA $00				; |
		LDA $2308 : STA $08			;/

		PLB					; bank wrapper end
		LDA $06					;\
		CLC : ADC $00				; |
		STA.w !3D_X,y				; |
		LDA $08					; |
		CLC : ADC $02				; | add parent coords to offsets to get joint coords
		STA.w !3D_Y,y				; | (Y is unchanged so this is fine)
		LDA $0A					; |
		CLC : ADC $04				; |
		STA.w !3D_Z,y				;/
		PLX					; restore X
		RTS					; return




	Transform3DCluster:

		LDY #$0000

	.Loop	STY $0E
		CPX $0E : BNE .Process
		JMP .Next

		.Process
		LDA.w !3D_X,y
		SEC : SBC $00
		STA.w !3D_X,y
		LDA.w !3D_Y,y
		SEC : SBC $02
		STA.w !3D_Y,y
		LDA.w !3D_Z,y
		SEC : SBC $04
		STA.w !3D_Z,y
		LDA.w !3D_AngleXY,x			;\
		AND #$00FF : BNE .CalcXY		; |
		JMP .SkipXY				; |
		.CalcXY					; |
		LDA.w !3D_X,y				; |
		STA !3D_Cache1				; |
		STA !3D_Cache3				; |
		LDA.w !3D_Y,y				; |
		STA !3D_Cache4				; | rotation around z axis
		EOR #$FFFF : INC A			; |
		STA !3D_Cache2				; |
		LDA.w !3D_AngleXY,x : STA !3D_Cache5	; |
		%Apply3DRotation()			; |
		LDA !3D_Cache7 : STA.w !3D_X,y		; |
		LDA !3D_Cache8 : STA.w !3D_Y,y		; |
		.SkipXY					;/

		LDA.w !3D_AngleYZ,x			;\
		AND #$00FF : BNE .CalcYZ		; |
		JMP .SkipYZ				; |
		.CalcYZ					; |
		LDA.w !3D_Y,y				; |
		STA !3D_Cache1				; |
		STA !3D_Cache3				; |
		LDA.w !3D_Z,y				; |
		STA !3D_Cache4				; | rotation around x axis
		EOR #$FFFF : INC A			; |
		STA !3D_Cache2				; |
		LDA.w !3D_AngleYZ,x : STA !3D_Cache5	; |
		%Apply3DRotation()			; |
		LDA !3D_Cache7 : STA.w !3D_Y,y		; |
		LDA !3D_Cache8 : STA.w !3D_Z,y		; |
		.SkipYZ					;/

		LDA.w !3D_AngleXZ,x			;\
		AND #$00FF : BNE .CalcXZ		; |
		JMP .SkipXZ				; |
		.CalcXZ					; |
		LDA.w !3D_X,y				; |
		STA !3D_Cache1				; |
		EOR #$FFFF : INC A			; |
		STA !3D_Cache3				; |
		LDA.w !3D_Z,y				; | rotation around y axis
		STA !3D_Cache2				; |
		STA !3D_Cache4				; |
		LDA.w !3D_AngleXZ,x : STA !3D_Cache5	; |
		%Apply3DRotation()			; |
		LDA !3D_Cache7 : STA.w !3D_X,y		; |
		LDA !3D_Cache8 : STA.w !3D_Z,y		; |
		.SkipXZ					;/

		LDA.w !3D_X,y
		CLC : ADC $00
		STA.w !3D_X,y
		LDA.w !3D_Y,y
		CLC : ADC $02
		STA.w !3D_Y,y
		LDA.w !3D_Z,y
		CLC : ADC $04
		STA.w !3D_Z,y

		.Next
		TYA
		CLC : ADC #$0010
		TAY
		CPY #$0200 : BCS .Return
		JMP .Loop

		.Return
		RTS

