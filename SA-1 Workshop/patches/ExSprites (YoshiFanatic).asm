header
sa1rom

Notes:
- The routine stored at $7F8000 is only called during a screen transition instead of every frame. Sprite tiles that belong to a sprite only get moved offscreen when the sprite that uses those tiles despawns.
- The !ax labels refer to RAM addresses $7E0000-$7E000F. Most of the other labels should be self explainatory
;================================================================

; This routine is run when a sprite despawns. In my hack, sprites store a pointer to their main/init routine to a table and the game jumps to that location when running a sprite's code. When a sprite despawns, the game sets the pointer to this routine to clean up some of the sprite's data that other sprites can use, like the OAM data.

EraseSprite:
	REP #$20
	STZ !RAM_SpriteRtPtr,X
	SEP #$20
.OffScrEraseSprite
	LDA !RAM_16BitSpriteNum,X
	CMP #$1F
	BNE .NotSprite001F
	STA !RAM_SpriteToRespawn
	LDA #$FF
	STA !RAM_TimeTillRespawn
.NotSprite001F
	LDA !RAM_SprStatus_SprState,X
	CMP #$02
	BEQ .OffScrKillSprite
	;CMP #!SprStatus_Normal
	;BCC .OffScrKillSprite
	LDY !RAM_SpriteRtPtrBNK_SprIndexInLvl+$1,X
	CPY #$FF
	BEQ .OffScrKillSprite
	LDA #$00
	STA !RAM_SprLoadStatus,Y
.OffScrKillSprite
	STZ !RAM_SprStatus_SprState,X

	LDY !RAM_15C4_DisSprCapeContact,X
	BMI .SprHasNoTileIndex
	LDA #$00
	STA !RAM_DynamicTileIndex,Y
.SprHasNoTileIndex
	LDA !RAM_SprOAMIndex_SpritePal,X	;
	BMI .SprHasNoOAMIndex
	PHX
	REP #$10
	LDY !RAM_16BitSpriteNum,X		; Load the current sprite number into Y
	TYX
	TAY
	LDA.l NormalSpriteTileAmount,X
	SEP #$10
	PLX
	STA !a1
	LDA #$00
	STA !RAM_DynamicOAMIndex,Y
	TYA
	DEC
	CLC
	ADC !a1
	TAY
	LDA #$00				;\ Store the number of tiles this sprite uses to the dynamic tile table
	STA !RAM_DynamicOAMIndex,Y		;/
	REP #$21
	PHX
	LDA !RAM_SprOAMIndex_SpritePal,X
	AND #$00FF
	ASL
	ASL
	ADC #!OAM_ExtendedDispY
	STA $8E
	SEP #$20
	LDY #$00
	LDX !a1
	DEX
.SpriteOAMEraseLoop
	LDA #$F0
	STA ($8E),Y
	INY
	INY
	INY
	INY
	DEX
	BPL .SpriteOAMEraseLoop
	PLX
.SprHasNoOAMIndex
	LDA #$FF
	STA !RAM_SprOAMIndex_SpritePal,X
	STA !RAM_15C4_DisSprCapeContact,X
	STA !RAM_SpriteRtPtrBNK_SprIndexInLvl+$1,X
	REP #$20
	STZ !RAM_16BitSpriteNum,X
	SEP #$20

	;JMP SkipSprite
	RTL

;================================================================

; This routine combines suboffscreen, getdrawinfo, and finishoamwrite into a single routine plus adds a few more things to it.

GenericSpriteGFXRt:
.Suboffscreen
	LDY #$00					;\ Set the Temp Offscreen flag to 0
	STY !a16					;/

	LDA !RAM_16BitSpriteXPos,X			;\ Subtract the layer 1 X position with the sprite X position and store it for later
	SEC						;|
	SBC !RAM_ScreenBndryXLo				;|
	STA !a1						;/
	LDA !RAM_16BitSpriteYPos,X			;\ Do the same for the Y position
	SEC						;|
	SBC !RAM_ScreenBndryYLo				;|
	STA !a3						;/

	LDA !RAM_IsVerticalLvl				;\ Is the current level a vertical level?
	LSR						;|
	BCS .VerticalLevel				;/ If so, we need to use different values to decide if the sprite should despawn
	LDA !RAM_16BitSpriteYPos,X			;
	CLC						;\ Check the sprite's vertical position in a horizontal level
	ADC #$0050					;|
	CMP #$0200					;|
	BPL .Return					;/ If it's far enough off screen vertically, erase the sprite
	LDA !RAM_Tweaker166E_167A+$1,X			;\ Is the sprite set to be processed off screen?
	AND #$0004					;|
	BNE .DoneSubOffScreen				;/ If so, then don't attempt to erase the sprite horizontally
							; Todo: Make the sprite despawn anyway if it leaves the horizontal borders of the level.

	LDA !a1						;\ Add 0x60 to the sprite's horizontal camera position and compare it with 0x01C0
	CLC						;|
	ADC #$0060					;|
	CMP #$01C0					;/ If the result is equal to or greater than 0x01C0, then the carry flag will be set
	BCC .DoneSubOffScreen				; If the carry flag is not set, then the sprite should not be deleted from memory 

.Return
	REP #$20					; Set A to 16-bit
	LDA.w #EraseSprite				;\ Set the sprite routine pointer to the erase sprite routine
	STA !RAM_SpriteRtPtr,X				;| (Note: My hack handles the sprite status differently from normal SMW)
	SEP #$20					;| (Instead of using $14C8 to determine where to go to handle a sprite, my hack stores a pointer to the routine that X sprite goes to).
	LDA.b #EraseSprite>>16				;| (My hack still uses $14C8 though, specifically for how the sprite is treated in other routines)
	STA !RAM_SpriteRtPtrBNK_SprIndexInLvl,X		;/
	LDA #$FF					;\ Tell the game that the sprite graphics routine should be skipped for the current sprite
	STA !a16					;/
.Return2
	RTL						; Return

.VerticalLevel
	LDA !RAM_16BitSpriteXPos,X			;\ Check the sprite's horizontal position in a vertical level
	CLC						;|
	ADC #$0050					;|
	CMP #$0200					;|
	BPL .Return					;/ If it's far enough off screen horizontally, erase the sprite

	LDA !RAM_Tweaker166E_167A+$1,X			;\ Is the sprite set to be processed off screen?
	AND #$0004					;|
	BNE .DoneSubOffScreen				;/ If so, then don't attempt to erase the sprite vertically

	LDA !a3						;\ Add 0x60 to the sprite's vertical camera position and compare it with 0x01C0
	CLC						;|
	ADC #$0060					;|
	CMP #$01C0					;/ If the result is equal to or greater than 0x01C0, then the carry flag will be set
	BCS .Return					; If the carry flag is not set, then the sprite should not be deleted from memory 

.DoneSubOffScreen
	SEP #$20					; Set A to 8-bit
	LDA !a10					;\ If the number of tiles set to be drawn is negative, exit the routine
	BMI .Return2					;/ This is here so that only the "SubOffscreen" part of this routine can get executed if need be

.GetDrawInfo
	REP #$21					; Set A to 16-bit and clear the carry flag
	STZ !RAM_OffscreenHorz_OffscreenVert,X		; Reset the sprite's offscreen flags
	LDA !a1						;\ Add 0x0010 to the sprite's horizontal camera position
	ADC #$0010					;/
	CMP #$0110					; Is the sprite off screen horizontally by 16 or more pixels?
	BCC .SpriteOnScreenHorz				; If not, then don't set the horizontal off screen flag
	INC !RAM_OffscreenHorz_OffscreenVert,X		; Otherwise, set that flag
.SpriteOnScreenHorz
	LDA !a3						;\ Do the same for the vertical camera position
	CLC						;|
	ADC #$0010					;/
	CMP #$0100					; Is the sprite off screen vertically by 16 or more pixels?
	BCC .SpriteOnScreenVert				; If not, then don't set the vertical off screen flag
	INC !RAM_OffscreenHorz_OffscreenVert+$1,X	; Otherwise, set that flag
.SpriteOnScreenVert
	LDA !a1						;\ This checks to see if the sprite is horizontally offscreen enough for it to simply skip the graphics routine
	CLC						;|
	ADC #$0040					;|
	CMP #$0180					;|
	SEP #$20					;|
	ROL						;|
	AND #$01					;|
	BNE .Return2					;/

	LDA !a10					;\ If the number of tiles set to be drawn is negative, exit the routine
	BMI .Return2					;/ This is here so that only the "Get Draw Info" part of this routine can get executed if need be


	LDA !RAM_15C4_DisSprCapeContact,X		; Does the current sprite have a tile index?
	BPL .SprHasTileIndex				; If so, don't get an index for the sprite
	JSL SetDynamicTileIndex				; Otherwise, get a tile index
	BRA .SprHasNoIndex				; Then skip the graphics routine
.SprHasTileIndex
	STA !a13					; Otherwise, store the tile index into scratch RAM
	LDA !RAM_SprOAMIndex_SpritePal,X		; Does the sprite have an OAM index?
	BPL .SprHasOAMIndex				; If so, don't get an index for the sprite
	JSL SetDynamicOAMIndexLow			; Otherwise, get an OAM index then skip the rest of the graphics routine
							; Todo: JSL to a routine that determines what priority this sprite's tiles need to have, then jump to the appropriate routine
.SprHasNoIndex
	SEP #$20					; Set A to 8-bit
	LDX !RAM_SprProcessIndex			; Restore X so it can be used as the sprite table index again
	LDA #$FF					;\
	STA !a16					;/ Tell the game to skip the rest of the graphics routine
	RTL						; Return

.SprHasOAMIndex
	STA !a7						; Store the OAM index to scratch RAM
	REP #$21					; Set A to 16-bit and clear the carry flag
	AND #$00FF					; Clear the high byte of A as it is garbage
	ASL						;\ Quadruple the value in A, then add 0x0200 to it
	ASL						;|
	ADC #!OAM_ExtendedDispX				;/
	STA $8E						; Then store the result into the temp OAM index RAM
	LDY #$00					; Load 0 into Y
.Entry2
	LDX !a9						; Load the sprite direction into X
	LDA.l FlipSpriteTBL,x				; Load a value based on what direction the sprite is facing
	STA !a5						; Then store it back to scratch RAM for later
	LDX #$FF					; Load 0xFF into X
	PHX						;\ Then store that to 3 stack locations
	PHX						;|
	PHX						;/
.GenericGFXLoop
	LDA (!a11)				;\ Is the current tile set to be uploaded the null tile (0x0000)?
	CMP.w #NullGFX				;/
	BNE .NotNull				; If not, then allow the game to update the tile
	INC !a14				;\ Otherwise, increment the tile properties pointer twice
	INC !a14				;/
	INY					; Increment Y
	JMP .NullTile				; Then jump to the null tile routine to prevent this tile from updating.

.NotNull
	SEP #$20
	LDX #$00				; Set X to 0x00
	LDA (!a14)				; Load the first byte of the properties table into A
	BPL .PositiveXPos			; If the value is positive, then don't decrement X
	DEX					; Otherwise, decrement X
.PositiveXPos
	XBA					; Set X to be the high byte of A
	TXA					; Transfer X to A
	XBA					; Set X to be the high byte of A
	REP #$21				; Set A to 16-bit and clear the carry flag
	ADC !a1					; Add the result to the sprite's X position on camera
	STA ($8E),Y				; Then store it to the current tile's X disp byte
	INY					; Increment Y
	PHA					; Preserve A for later
	CLC					;\
	ADC #$0010				;/ Add 0x0010 to it
	CMP #$0110				; Is the tile 16 or more pixels offscreen horizontally?
	INC !a14				; Increment the tile properties pointer
	PLA					; Pull A from the stack
	BCC .SpriteTileOnScreenHoriz		; If not, then allow the tile to update
	INC !a14				; Otherwise, increment the tile properties pointer
	JMP .NullTile				; Then jump to the null tile routine to prevent this tile from updating.

.SpriteTileOnScreenHoriz
	SEP #$20				; Set A to 8-bit
	XBA					; If the high byte of A is 1, then the tile is partially offscreen horizontally and the OAM high X position bit needs to be set later
	AND #$01				; Clear out most of A except this one bit
.NoHighByte
	STA !a6					; Store A into scratch RAM for later

	LDX #$00				; Load 0x00 into X
	LDA (!a14)				; Load the second byte of the properties table into A
	BPL .PositiveYPos			; If the value is positive, then don't decrement X
	DEX					; Otherwise, decrement X
.PositiveYPos
	XBA
	TXA					; Transfer X into A
	XBA					; Set X to be the high byte of A		
	REP #$21				; Set A to 16-bit and clear the carry flag
	ADC !a3					;\ Add the result to the sprite's Y position on camera, then add another 0x0010 to it
	STA ($8E),Y				; Then store it to the current tile's Y disp byte
	CLC					;|
	ADC #$0010				;/
	CMP #$0100				; Is the tile 16 or more pixels offscreen vertically?
	INC !a14				; Increment the Tile properties pointer
	BCC .SpriteTileOnScreenVert		; If not, allow the tile to update
.NullTile
	SEP #$20				; Set A to 8-bit
	LDA #$F0				;\ Force the tile to be below the screen so it can't be seen.
	STA ($8E),Y				;/
	INY					;\ Increment Y twice so we can index the next tile
	INY					;/
	BRA .SpriteTileOffScreen		; Skip over the pointer updating code and the properties setting code.

.SpriteTileOnScreenVert
	INY					; Increment Y
	LDA (!a11)				;\ Is the current tile set to be uploaded the same tile that was loaded on the previous loop?
	CMP $01,S				;/
	SEP #$20				; Set A to 8-bit
	BNE .NotSameTile			; If not, allow the game to update the pointer to the graphics
	LDA $03,S				;\ Otherwise, load the OAM index used for the tile that the current tile duplicates into X so that the current duplicate tile uses the same graphics
	TAX					;/ Doing this saves V-Blank time by not uploading duplicates of the same tile drawn by a single sprite (assuming that the duplicates are processed one after another)
	LDA.l DynamicVRAMOAMTileTBL,x		;\ Load the tile number to use for this tile and store it into the tile OAM byte
	STA ($8E),Y				;/
	BRA .DontUpdateTile			; Then, skip over the code that updates the pointer to the graphics

.NotSameTile
	LDX !a13				; Load the tile index of the sprite into X
	LDA.l DynamicVRAMOAMTileTBL,x		;\  Load the tile number to use for this tile and store it into the tile OAM byte
	STA ($8E),Y				;/
	TXA					; Transfer the OAM index into A
	STA $03,S				; Store it into scratch RAM in case the next tile is a duplicate of the current tile
	ASL					; Double the value of the OAM index
	TAX					; Transfer the result into X
	REP #$20				; Set A to 16-bit
	LDA (!a11)				;\ Check to see if the low and high byte of pointer to the graphics stored in the pointer table is the same as the current tile's pointer
	CMP !RAM_MarioSpriteDMAPtrs,x		;/
	BNE .NotSameGFX				; If not, then upload the new tile
	SEP #$20				; Otherwise, set A to 8-bit
	LDA !a8					;\ Then check the bank byte of the pointer
	CMP !RAM_MarioSpriteDMAPtrs2,x		;/
	BEQ .SameGFX				; If it's identical, then don't update the pointer
						; (No need to waste V-Blank time uploading graphics into X VRAM slot when the graphics it's uploading are already present in X VRAM slot)
	REP #$20				; Set A to 16-bit		
	LDA (!a11)				; Load the current tile's low and high byte of its graphics pointer into A
.NotSameGFX
	STA $01,S				; Store the pointer to scratch RAM in case the next tile is a duplicate of the current tile
	ORA #$0002				; Set the upload flag for this tile
	STA !RAM_MarioSpriteDMAPtrs,x		; Then store the result to the pointer table
	SEP #$20				; Set A to 8-bit
	AND #$01				; Clear out A except for the lowest bit
	PHX					;\ Preserve X, then transer A into X
	TAX					;/
	LDA.l TileSizeBytesTBL,X		; Load the number of bytes to transfer for the sprite DMA routine into A (either 0x40 or 0x20)
	PLX					; Pull X from the stack
	STA !RAM_MarioSpriteDMAPtrs2+$1,x	; Then store the result into the this table for later
	LDA !a8					;\ Load the bank byte of the graphics pointer into A then store it to the graphics pointer table.
	STA !RAM_MarioSpriteDMAPtrs2,x		;/
.SameGFX
.DontUpdateTile
	INY					; Increment Y
	LDA !a13				;\ Check to see if the tile index for this tile is greater than 40 (64th tile)
	CMP #$40				;/ If it is, then the carry flag will be set

	LDA (!a14)				; Load the property byte of the current tile
	AND #$FE				; Clear out the first bit, as that's used for the tile size of the tile rather than the page number
	EOR !a5					; Flip the tile based on what direction the sprite is facing
	ADC #$00				; Add the carry flag to set the page number property bit if necessary
	STA ($8E),Y				; Then, store the result to the sprite's OAM property byte

	LDA (!a14)				; Load the property byte again for this tile again
	ASL					; Double it
	AND #$02				; Clear out all but the second lowest bit (which was originally the lowest bit)
	ORA !a6					; Set the OAM high X position bit if necessary
	LDX !a7					; Load the index for the OAM table at $0420 into X
	STA $0420,X				; Then store A into the table.

.SpriteTileOffScreen
	INY					; Increment Y
	INC !a13				; Increment the current tile's tile index
	INC !a7					; Increment the index for the OAM table at $0420
	DEC !a10				; Decrement the number of tiles being drawn
	BMI .GenericGFXDone			; Have all the tiles been drawn? If so, exit the loop
	REP #$20				; Otherwise, Set A to 16-bit
	INC !a14				; Increment the tile properties pointer
	INC !a11				;\ Increment the graphics pointer twice
	INC !a11				;/
	JMP .GenericGFXLoop			; Jump back to the start of the loop

.GenericGFXDone
	PLX					;\ Pull the 3 stack bytes that were pushed earlier
	PLX					;|
	PLX					;/
	SEP #$20				; Set A to 8-bit
	LDX !RAM_SprProcessIndex		; Restore X so it can be used as the sprite table index again
	STZ !a16				; Tell the game that the sprite has been drawn this frame
	RTL					; Return

FlipSpriteTBL:
	db $40,$00,$C0,$80

TileSizeBytesTBL:
	db $40,$20

DynamicVRAMOAMTileTBL:
	db $00,$02,$04,$06,$08,$0A,$0C,$0E
	db $20,$22,$24,$26,$28,$2A,$2C,$2E
	db $40,$42,$44,$46,$48,$4A,$4C,$4E
	db $60,$62,$64,$66,$68,$6A,$6C,$6E
	db $80,$82,$84,$86,$88,$8A,$8C,$8E
	db $A0,$A2,$A4,$A6,$A8,$AA,$AC,$AE
	db $C0,$C2,$C4,$C6,$C8,$CA,$CC,$CE
	db $E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE

	db $00,$02,$04,$06,$08,$0A,$0C,$0E
	db $20,$22,$24,$26,$28,$2A,$2C,$2E
	db $40,$42,$44,$46,$48,$4A,$4C,$4E
	db $60,$62,$64,$66,$68,$6A,$6C,$6E
	db $80,$82,$84,$86,$88,$8A,$8C,$8E
	db $A0,$A2,$A4,$A6,$A8,$AA,$AC,$AE
	db $C0,$C2,$C4,$C6,$C8,$CA,$CC,$CE
	db $E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE

;================================================================

; This routine searches the dynamic tile table to find a large enough space for the current sprite's tiles.
; If there isn't enough room, the game will try again the next frame and the sprite will be invisible until it finds a valid index.
; This is handled with a linked list, where the game adds the values stored at X locations to jump further into the table until the pointer = 7F or an empty spot is found.

SetDynamicIndexMarioEntry:
	PHX
	LDA #$01
	STA !a16
	LDA #$08
	STA !a1
	BRA SetDynamicTileIndex_Entry2

SetDynamicTileIndex:
	STZ !a16
	PHX					; Preserve the sprite table index
	REP #$10
	LDY !RAM_16BitSpriteNum,X		; Load the current sprite number into Y
	TYX					; Then immediately transfer it into X, since long tables can't be indexed with Y
	LDA.l NormalSpriteTileAmount,X		;\ Get the max number of slots the current sprite can use and store it to scratch RAM
	STA !a1					;/
	SEP #$10
.Entry2
	STZ !a3					; Set the dynamic tile number index scratch RAM to 00
	LDY #$00				; Do the same for the dynamic tile table index
.SetDynamicIndexLoop
	STZ !a2					; Clear the number of free slots index
	LDA !RAM_DynamicTileIndex,Y		;\ Check the current dynamic tile slot. Is this slot free?
	BEQ .UnusedSlot				;/ If so, then we will see if there is enough room for this sprite in this space
.SetDynamicIndexLoop2
	;BNE .DontIncrementCounter		; If a zero is not stored in this entry, then the slot is being used
	;LDA #$FF				;\ Otherwise, free up this entry and go to the next one
	;STA !RAM_DynamicTileIndex,Y		;|
	;LDA #$01				;/
.DontIncrementCounter
	CLC					;\ Otherwise, add the amount of slots the sprite that uses this slot uses to the dynamic tile number index
	ADC !a3					;|
	STA !a3					;/
	TAY					; Also transfer the result into Y so we can skip checking the slots that sprite uses
	CMP #$7F				;\ If all 128 slots have not been checked, check more slots
	BCC .SetDynamicIndexLoop		;/
.NotEnoughFreeSlots
	PLX					;\ Otherwise, exit the routine and try again on the next frame
	RTL					;/

.UnusedSlot
	TYA					;\ Preserve the first unused index in case there is enough room for this sprite
	STA !a4					;/
.UnusedSlotLoop
	LDA !a3					;\ If we're on slot 129 (which doesn't exist), then give up on finding an index on this frame
	BMI .NotEnoughFreeSlots			;/
	INC !a2					; Increment the free slots counter
	LDA !a2					;\ Is the number of free slots checked equal to the number of slots the sprite needs?
	CMP !a1					;|	
	BEQ .FoundDynamicIndex			;/ If so, then we found our index
	INC !a3					; Otherwise, increment the dynamic tile number index
	INY					; Increment the dynamic tile table index
	LDA !RAM_DynamicTileIndex,Y		;\ Is the currently checked slot being used?
	BEQ .UnusedSlotLoop			;/ If not, then check if the next slot is free as well
	BRA .SetDynamicIndexLoop2		; If not, then we need to look elsewhere for the free slots

.FoundDynamicIndex
	PLX
	LDY !a4					;\ Load the value of the oldest free slot and store it to a sprite table
	LDA !a16
	BEQ .NormalSprite
	STY !RAM_MarioTileIndex
	BRA .MarioSprite
.NormalSprite
	TYA
	STA !RAM_15C4_DisSprCapeContact,X	;/
.MarioSprite
	LDA !a1					;\ Store the number of tiles this sprite uses to the dynamic tile table
	STA !RAM_DynamicTileIndex,Y		;/
	RTL

;================================================================

; This routine functions like the above tile index routine, except this one is for the OAM.
; This routine finds an index starting from the start of the OAM and works its way up.

SetDynamicOAMIndexHigh:
	PHX					; Preserve the sprite table index
	REP #$10
	LDY !RAM_16BitSpriteNum,X		; Load the current sprite number into Y
	TYX					; Then immediately transfer it into X, since long tables can't be indexed with Y
	LDA.l NormalSpriteTileAmount,X		;\ Get the max number of slots the current sprite can use and store it to scratch RAM
	STA !a1					;/
	SEP #$10
.Entry2
	STZ !a3					; Set the dynamic tile number index scratch RAM to 00
	LDY #$00				; Do the same for the dynamic tile table index
.SetDynamicIndexLoop
	STZ !a2					; Clear the number of free slots index
	LDA !RAM_DynamicOAMIndex,Y		;\ Check the current dynamic tile slot. Is this slot free?
	BEQ .UnusedSlot				;/ If so, then we will see if there is enough room for this sprite in this space
.SetDynamicIndexLoop2
	CLC					;\ Otherwise, add the amount of slots the sprite that uses this slot uses to the dynamic tile number index
	ADC !a3					;|
	STA !a3					;/
	TAY					; Also transfer the result into Y so we can skip checking the slots that sprite uses
	LDA !a3
	CMP #$7F				;\ If all 128 slots have not been checked, check more slots
	BCC .SetDynamicIndexLoop		;/
.NotEnoughFreeSlots
	PLX					;\ Otherwise, exit the routine and try again on the next frame
	RTL					;/

.UnusedSlot
	TYA					;\ Preserve the first unused index in case there is enough room for this sprite
	STA !a4					;/
.UnusedSlotLoop
	LDA !a3					;\ If we're on slot 129 (which doesn't exist), then give up on finding an index on this frame
	BMI .NotEnoughFreeSlots			;/
	INC !a2					; Increment the free slots counter
	LDA !a2					;\ Is the number of free slots checked equal to the number of slots the sprite needs?
	CMP !a1					;|	
	BEQ .FoundDynamicIndex			;/ If so, then we found our index
	INC !a3					; Otherwise, increment the dynamic tile number index
	INY					; Increment the dynamic tile table index
	LDA !RAM_DynamicOAMIndex,Y		;\ Is the currently checked slot being used?
	BEQ .UnusedSlotLoop			;/ If not, then check if the next slot is free as well
	BRA .SetDynamicIndexLoop2		; If not, then we need to look elsewhere for the free slots

.FoundDynamicIndexLow
	TYA					;\ Preserve the first unused index in case there is enough room for this sprite
	STA !a4					;/

.FoundDynamicIndex
	PLX
	LDY !a4
	TYA					;\ Load the value of the oldest free slot and store it to a sprite table
	STA !RAM_SprOAMIndex_SpritePal,X	;/
	LDA !a1					;\ Store the number of tiles this sprite uses to the dynamic tile table
	STA !RAM_DynamicOAMIndex,Y		;/
	TYA
	DEC
	CLC
	ADC !a1
	TAY
	LDA !a1					;\ Store the number of tiles this sprite uses to the dynamic tile table
	STA !RAM_DynamicOAMIndex,Y		;/	
	RTL

;================================================================

; This routine functions like SetDynamicOAMIndexHigh, except it starts from the end of the OAM and works its way down.

SetDynamicOAMIndexLow:
	PHX					; Preserve the sprite table index
	REP #$10
	LDY !RAM_16BitSpriteNum,X		; Load the current sprite number into Y
	TYX					; Then immediately transfer it into X, since long tables can't be indexed with Y
	LDA.l NormalSpriteTileAmount,X		;\ Get the max number of slots the current sprite can use and store it to scratch RAM
	STA !a1					;/
	SEP #$10
.Entry2
	LDA #$7F
	STA !a3					; Set the dynamic tile number index scratch RAM to 00
	TAY					; Do the same for the dynamic tile table index
.SetDynamicIndexLoop
	STZ !a2					; Clear the number of free slots index
	LDA !RAM_DynamicOAMIndex,Y		;\ Check the current dynamic tile slot. Is this slot free?
	BEQ .UnusedSlot				;/ If so, then we will see if there is enough room for this sprite in this space
.SetDynamicIndexLoop2
	EOR #$FF
	INC
	CLC					;\ Otherwise, add the amount of slots the sprite that uses this slot uses to the dynamic tile number index
	ADC !a3					;|
	STA !a3					;/
	TAY					; Also transfer the result into Y so we can skip checking the slots that sprite uses
	BPL .SetDynamicIndexLoop		;/
.NotEnoughFreeSlots
	PLX					;\ Otherwise, exit the routine and try again on the next frame
	RTL					;/

.UnusedSlot
.UnusedSlotLoop
	LDA !a3					;\ If we're on slot 129 (which doesn't exist), then give up on finding an index on this frame
	BMI .NotEnoughFreeSlots			;/
	INC !a2					; Increment the free slots counter
	LDA !a2					;\ Is the number of free slots checked equal to the number of slots the sprite needs?
	CMP !a1					;|	
	BEQ SetDynamicOAMIndexHigh_FoundDynamicIndexLow			;/ If so, then we found our index
	DEC !a3					; Otherwise, increment the dynamic tile number index
	DEY					; Increment the dynamic tile table index
	LDA !RAM_DynamicOAMIndex,Y		;\ Is the currently checked slot being used?
	BEQ .UnusedSlotLoop			;/ If not, then check if the next slot is free as well
	BRA .SetDynamicIndexLoop2		; If not, then we need to look elsewhere for the free slots

;================================================================

; A random graphics routine to give context for what is in the RAM addresses in GenericSpriteGFXRt

HoppingFlame_GFX:
	LDA !RAM_SpriteDir_SprObjStatus,X
	STA !a9
	STZ !a10
	LDA !RAM_1602_160ETBLs,X
	ASL
	REP #$21
	AND #$00FF
	ADC.w #HoppingFlame_AnimationFrameTBL
	STA !a11
	LDA.w #HoppingFlame_TilePropTBL
	STA !a14
	LDY.b #HoppingFlameGFX>>16
	STY !a8
	JMP GenericSpriteGFXRt

HoppingFlame_AnimationFrameTBL:
	dw HoppingFlameGFX+$140
	dw HoppingFlameGFX+$100

HoppingFlame_TilePropTBL:
	dl $250000

;================================================================

; This determines the max number of tiles a sprite can use at a time. Used for the OAM/tile stuff. Mario gets 8 tiles reserved for him in my hack, but 5 should be enough for the average hack.

NormalSpriteTileAmount:
db $01	; 00 - Green Koopa, no shell 
db $01	; 01 - Red Koopa, no shell 
db $01	; 02 - Blue Koopa, no shell 
db $01	; 03 - Yellow Koopa, no shell 
db $02	; 04 - Green Koopa 
db $02	; 05 - Red Koopa 
db $02	; 06 - Blue Koopa 
db $02	; 07 - Yellow Koopa 
db $03	; 08 - Green Koopa, flying left 
db $03	; 09 - Green bouncing Koopa 
db $03	; 0A - Red vertical flying Koopa 
db $03	; 0B - Red horizontal flying Koopa 
db $03	; 0C - Yellow Koopa with wings 
db $04	; 0D - Bob-omb 
db $01	; 0E - Keyhole 
db $01	; 0F - Goomba 
db $03	; 10 - Bouncing Goomba with wings 
db $01	; 11 - Buzzy Beetle 
db $00	; 12 - Unused 
db $01	; 13 - Spiny 
db $01	; 14 - Spiny falling 
db $01	; 15 - Fish, horizontal 
db $01	; 16 - Fish, vertical 
db $01	; 17 - Fish, created from generator 
db $01	; 18 - Surface jumping fish 
db $00	; 19 - Display text from level Message Box #1 
db $02	; 1A - Classic Piranha Plant 
db $01	; 1B - Bouncing football in place 
db $01	; 1C - Bullet Bill 
db $01	; 1D - Hopping flame 
db $08	; 1E - Lakitu 
db $03	; 1F - Magikoopa 
db $03	; 20 - Magikoopa's magic 
db $01	; 21 - Moving coin 
db $02	; 22 - Green vertical net Koopa 
db $02	; 23 - Red vertical net Koopa 
db $02	; 24 - Green horizontal net Koopa 
db $02	; 25 - Red horizontal net Koopa 
db $05	; 26 - Thwomp 
db $01	; 27 - Thwimp 
db $14	; 28 - Big Boo 
db $00	; 29 - Koopa Kid 
db $02	; 2A - Upside down Piranha Plant 
db $01	; 2B - Sumo Brother's fire lightning 
db $01	; 2C - Yoshi egg 
db $01	; 2D - Baby green Yoshi 
db $01	; 2E - Spike Top 
db $01	; 2F - Portable spring board 
db $03	; 30 - Dry Bones, throws bones 
db $02	; 31 - Bony Beetle 
db $03	; 32 - Dry Bones, stay on ledge 
db $01	; 33 - Fireball 
db $02	; 34 - Boss fireball 
db $02	; 35 - Green Yoshi 
db $00	; 36 - Unused 
db $01	; 37 - Boo 
db $01	; 38 - Eerie 
db $01	; 39 - Eerie, wave motion 
db $05	; 3A - Urchin, fixed 
db $05	; 3B - Urchin, wall detect 
db $05	; 3C - Urchin, wall follow 
db $01	; 3D - Rip Van Fish 
db $01	; 3E - POW 
db $02	; 3F - Para-Goomba 
db $02	; 40 - Para-Bomb 
db $03	; 41 - Dolphin, horizontal 
db $03	; 42 - Dolphin2, horizontal 
db $02	; 43 - Dolphin, vertical 
db $02	; 44 - Torpedo Ted 
db $01	; 45 - Directional coins 
db $04	; 46 - Diggin' Chuck 
db $01	; 47 - Swimming/Jumping fish 
db $01	; 48 - Diggin' Chuck's rock 
db $02	; 49 - Growing/shrinking pipe end 
db $01	; 4A - Goal Point Question Sphere 
db $02	; 4B - Pipe dwelling Lakitu 
db $01	; 4C - Exploding Block 
db $01	; 4D - Ground dwelling Monty Mole 
db $01	; 4E - Ledge dwelling Monty Mole 
db $03	; 4F - Jumping Piranha Plant 
db $03	; 50 - Jumping Piranha Plant, spit fire 
db $01	; 51 - Ninji 
db $03	; 52 - Moving ledge hole in ghost house 
db $01	; 53 - Throw block sprite 
db $04	; 54 - Climbing net door 
db $05	; 55 - Checkerboard platform, horizontal 
db $05	; 56 - Flying rock platform, horizontal 
db $05	; 57 - Checkerboard platform, vertical 
db $05	; 58 - Flying rock platform, vertical 
db $05	; 59 - Turn block bridge, horizontal and vertical 
db $05	; 5A - Turn block bridge, horizontal 
db $03	; 5B - Brown platform floating in water 
db $05	; 5C - Checkerboard platform that falls 
db $05	; 5D - Orange platform floating in water 
db $09	; 5E - Orange platform, goes on forever 
db $05	; 5F - Brown platform on a chain 
db $02	; 60 - Flat green switch palace switch 
db $01	; 61 - Floating skulls 
db $03	; 62 - Brown platform, line-guided 
db $05	; 63 - Checker/brown platform, line-guided 
db $09	; 64 - Rope mechanism, line-guided 
db $03	; 65 - Chainsaw, line-guided 
db $03	; 66 - Upside down chainsaw, line-guided 
db $04	; 67 - Grinder, line-guided 
db $01	; 68 - Fuzz ball, line-guided 
db $00	; 69 - Unused 
db $02	; 6A - Coin game cloud 
db $05	; 6B - Spring board, left wall 
db $05	; 6C - Spring board, right wall 
db $01	; 6D - Invisible solid block 
db $04	; 6E - Dino Rhino 
db $04	; 6F - Dino Torch 
db $05	; 70 - Pokey 
db $04	; 71 - Super Koopa, red cape 
db $04	; 72 - Super Koopa, yellow cape 
db $04	; 73 - Super Koopa, feather 
db $01	; 74 - Mushroom 
db $01	; 75 - Flower 
db $01	; 76 - Star 
db $01	; 77 - Feather 
db $01	; 78 - 1-Up 
db $01	; 79 - Growing Vine 
db $00	; 7A - Firework 
db $02	; 7B - Goal Point 
db $00	; 7C - Princess Peach 
db $01	; 7D - Balloon 
db $03	; 7E - Flying Red coin 
db $03	; 7F - Flying yellow 1-Up 
db $03	; 80 - Key 
db $01	; 81 - Changing item from translucent block 
db $05	; 82 - Bonus game sprite 
db $03	; 83 - Left flying question block 
db $03	; 84 - Flying question block 
db $00	; 85 - Unused (Pretty sure) 
db $07	; 86 - Wiggler 
db $05	; 87 - Lakitu's cloud 
db $00	; 88 - Unused (Winged cage sprite) 
db $00	; 89 - Layer 3 smash 
db $01	; 8A - Bird from Yoshi's house 
db $02	; 8B - Puff of smoke from Yoshi's house 
db $02	; 8C - Fireplace smoke/exit from side screen 
db $0A	; 8D - Ghost house exit sign and door 
db $00	; 8E - Invisible "Warp Hole" blocks 
db $02	; 8F - Scale platforms 
db $0F	; 90 - Large green gas bubble 
db $04	; 91 - Chargin' Chuck 
db $04	; 92 - Splittin' Chuck 
db $04	; 93 - Bouncin' Chuck 
db $04	; 94 - Whistlin' Chuck 
db $04	; 95 - Clapin' Chuck 
db $00	; 96 - Unused (Chargin' Chuck clone) 
db $04	; 97 - Puntin' Chuck 
db $04	; 98 - Pitchin' Chuck 
db $03	; 99 - Volcano Lotus 
db $04	; 9A - Sumo Brother 
db $03	; 9B - Hammer Brother 
db $04	; 9C - Flying blocks for Hammer Brother 
db $06	; 9D - Bubble with sprite 
db $06	; 9E - Ball and Chain 
db $0F	; 9F - Banzai Bill 
db $00	; A0 - Activates Bowser scene 
db $0C	; A1 - Bowser's bowling ball 
db $04	; A2 - MechaKoopa 
db $04	; A3 - Grey platform on chain 
db $04	; A4 - Floating Spike ball 
db $01	; A5 - Fuzzball/Sparky, ground-guided 
db $05	; A6 - HotHead, ground-guided 
db $01	; A7 - Iggy's ball 
db $05	; A8 - Blargg 
db $00	; A9 - Reznor 
db $03	; AA - Fishbone 
db $02	; AB - Rex 
db $05	; AC - Wooden Spike, moving down and up 
db $05	; AD - Wooden Spike, moving up/down first 
db $0A	; AE - Fishin' Boo 
db $01	; AF - Boo Block 
db $01	; B0 - Reflecting stream of Boo Buddies 
db $01	; B1 - Creating/Eating block 
db $01	; B2 - Falling Spike 
db $02	; B3 - Bowser statue fireball 
db $04	; B4 - Grinder, non-line-guided 
db $01	; B5 - Sinking fireball used in boss battles 
db $01	; B6 - Reflecting fireball 
db $03	; B7 - Carrot Top lift, upper right 
db $03	; B8 - Carrot Top lift, upper left 
db $01	; B9 - Info Box 
db $03	; BA - Timed lift 
db $04	; BB - Grey moving castle block 
db $03	; BC - Bowser statue 
db $01	; BD - Sliding Koopa without a shell 
db $01	; BE - Swooper bat 
db $04	; BF - Mega Mole 
db $03	; C0 - Grey platform on lava 
db $05	; C1 - Flying grey turnblocks 
db $01	; C2 - Blurp fish 
db $04	; C3 - Porcu-Puffer fish 
db $04	; C4 - Grey platform that falls 
db $14	; C5 - Big Boo Boss 
db $01	; C6 - Dark room with spot light 
db $00	; C7 - Invisible mushroom 
db $01	; C8 - Light switch block for dark room
db $01	; C9 - Bullet Bill Shooter
db $01	; CA - Torpedo Ted Launcher
db $00	; CB - Eerie Generator
db $00	; CC - Null Sprite
db $00	; CD - Null Sprite
db $00	; CE - Null Sprite
db $00	; CF - Null Sprite
db $00	; D0 - Null Sprite
db $00	; D1 - Null Sprite
db $00	; D2 - Null Sprite
db $00	; D3 - Null Sprite
db $00	; D4 - Null Sprite
db $00	; D5 - Null Sprite
db $00	; D6 - Null Sprite
db $00	; D7 - Null Sprite
db $00	; D8 - Null Sprite
db $00	; D9 - Null Sprite
db $00	; DA - Null Sprite
db $00	; DB - Null Sprite
db $00	; DC - Null Sprite
db $00	; DD - Null Sprite
db $00	; DE - Null Sprite
db $00	; DF - Null Sprite
db $00	; E0 - Null Sprite
db $00	; E1 - Null Sprite
db $00	; E2 - Null Sprite
db $00	; E3 - Null Sprite
db $00	; E4 - Null Sprite
db $00	; E5 - Null Sprite
db $00	; E6 - Null Sprite
db $00	; E7 - Null Sprite
db $00	; E8 - Null Sprite
db $00	; E9 - Null Sprite
db $00	; EA - Null Sprite
db $00	; EB - Null Sprite
db $00	; EC - Null Sprite
db $00	; ED - Null Sprite
db $00	; EE - Null Sprite
db $00	; EF - Null Sprite
db $00	; F0 - Null Sprite
db $00	; F1 - Null Sprite
db $00	; F2 - Null Sprite
db $00	; F3 - Null Sprite
db $00	; F4 - Null Sprite
db $00	; F5 - Null Sprite
db $00	; F6 - Null Sprite
db $00	; F7 - Null Sprite
db $00	; F8 - Null Sprite
db $00	; F9 - Null Sprite
db $00	; FA - Null Sprite
db $00	; FB - Null Sprite
db $00	; FC - Null Sprite
db $00	; FD - Null Sprite
db $00	; FE - Null Sprite
db $00	; FF - Null Sprite
db $01 	; 100 - Egg Shell Piece Effect
db $01	; 101 - Blood Splatter Effect
db $01	; 102 - Lava Splash Effect
db $01	; 103 - Smoke Puff Effect
db $01	; 104 - Rip Van Fish Z Effect
db $01	; 105 - Yoshi's House Fireplace Effect
db $01	; 106 - Mario Fireball
db $01	; 107 - Turn Around Smoke Effect
db $01	; 108 - Hammer Bro Hammer
db $01	; 109 - Hopping Flame Fire
db $01	; 10A - Bounce Sprite
db $01	; 10B - Water Bubble
db $01	; 10C - Thrown Bone/Baseball
db $02	; 10D - Score Sprite
db $01	; 10E - Boo Stream (Extended)
db $01	; 10F - Water Splash Effect
db $01	; 110 - Rip Van Fish Z
db $01	; 111 - Star Sparkle
db $01	; 112 - Podoboo Fire
db $01	; 113 - Brick Piece
db $04	; 114 - Contact Effect
db $01	; 115 - Volcano Lotus Fireball
db $00	; 116 - Arbritrary Code Sprite

;================================================================