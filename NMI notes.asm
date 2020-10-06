

; VR3 plan:
;	- have sa-1 generate RAM code for VR2 uploads
;	- all tile updates should use DMA mode 4 (2 bytes to $2116, 2 bytes to $2118)
;	- layer scrolling should use DMA mode 2 (64 bytes, 2115 set to 81 for horizontal, 72 bytes, 2115 set to 80 for vertical)
;	- remove all unnecessary codes left over from vanilla SMW
;	- completely remove stripe image uploads
;	- expand !AnimToggle functionality to allow for things like ExAnimation
;	- code around LM hijacks so they can be called at will
;	- have dynamic BG3 change its tilemap location rather than tilemap data (this should be faster and even work on ZSNES)
;		- 64 bytes in the first 2bpp GFX file will then be taken by the status bar, but not be usable as tiles
;		- rearrange 2bpp GFX to be more useful
;	- include optimized CCDMA code
;
; expanded JSR list:
;	- $98A9: VRAM DMA routine, purpose unknown (only run on "special" levels)
;	- $A488: palette update code
;	- $A7C2: Mario/Luigi Start! / Game Over etc. graphics uploader (hijacked by LevelIntros.asm)
;	- $A300: Mario GFX DMA
;	- $A390: dynamic sprite GFX DMA for Yoshi, Podoboo etc. (hijacked to $97A160 (replaces), which is a massive GFX DMA routine)
;	- $A436: another dynamic sprite GFX DMA routine, disabled by unknown source
;	- $A529: Mario OW GFX DMA
;	- $A4E3: BG1/BG2 tile/palette animation routine
;
; JML list:
;	- $81E2: JML $80AC1A (Lunar Magic code, labeled "VRAM modification", likely ExAnimation)
;	- $82A4: JML $129009 (VR2 JML NMI)
;	- $82BC: JML $129000 (VR2 JML ReturnNMI)
;	- $8375: JML $108A4E (SA1 JML IRQStart)
;	- $838F: JML $129072 (VR2 JML IRQ)
;	- $83B2: JML $129000 (VR2 JML ReturnNMI)
;
; JSL list (stinky):
;	- $8203: JSL $0C9567 (DMA to BG1 tilemap at VRAM $30C0 or $34C0, supposedly writes initial screen at level load)
;		unused in preliminary testing
;	- $8209: JSL $80ADB3 (GFX+2 code)
;	- $828C: JSL $139B83 (disables HDMA during game mode 0x11)
;	- $82B6: JSL $139B71 (disables HDMA during game mode 0x11)
;
; what i need:
;	- start NMI (SEI, push everything, read $4210, disable HDMA)
;	- music ports (make sure I respect AMK here)
;	- register mirroring
;	- go to RAM code
;		- layer 1/2 scrolling tilemap update
;		- block updates
;		- VR2 uploads (GFX + palette)
;		- adapted SMW DMA (GFX + palettes)
;	- update OAM
;	- call ExAnimation
;	- set HDMA
;
;	!AnimToggle: uuuubesv
;		v: disable vanilla animations
;		s: disable scrolling tilemap update
;		e: disable ExAnimation
;		b: disable block update
;		uuuu: upload size / 512 allowed per NMI (0-7.5KB, but only ~6KB is feasible)
;
label_0C9567:
	SEP #$30
	PHB
	PHK
	PLB
	LDA #$80
	STA $2115
	LDA #$C0
	STA $2116
	LDA #$30
	STA $2117
	LDY #$06

label_0C957D:
	LDA $9559,Y
	STA $4310,Y
	DEY
	BPL label_0C957D
	LDA $7928
	ASL A
	ASL A
	ASL A
	ORA $4313
	STA $4313
	LDA #$02
	STA $420B
	LDA #$80
	STA $2115
	LDA #$C0
	STA $2116
	LDA #$34
	STA $2117
	LDY #$06

label_0C95A8:
	LDA $9560,Y
	STA $4310,Y
	DEY
	BPL label_0C95A8
	LDA $7928
	ASL A
	ASL A
	ASL A
	ORA $4313
	STA $4313
	LDA #$02
	STA $420B
	STZ $7FFE
	PLB
	RTL



label_80AC1A:
	BEQ label_80AC20
	JML $00827A

label_80AC20:
	JML $008275
	STZ $743A
	JSR label_80AC2E
	JML $00A5A8

label_80AC2E:
	STZ $2133
	STZ $2106
	LDA #$31
	STA $2107
	LDA #$39
	STA $2108
	LDA #$53
	STA $2109
	LDA #$00
	STA $210B
	LDA #$04
	STA $210C
	STZ $41
	STZ $42
	STZ $43
	STZ $212A
	STZ $212B
	STZ $212E
	STZ $212F
	LDA #$02
	STA $44
	LDA #$80
	STA $211A
	RTS
	SEP #$20
	LDA $6100
	CMP #$14
	BEQ label_80AC86
	CMP #$07
	BEQ label_80AC86
	CMP #$13
	BEQ label_80AC86
	CMP #$05
	BEQ label_80AC86
	REP #$20
	LDA $03
	JML $008755

label_80AC86:
	REP #$20
	LDA $03
	AND #$7000
	CMP #$2000
	BNE label_80ACFA
	LDA $03
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$001F
	STA $0B
	LDA $03
	AND #$0800
	XBA
	ASL A
	ASL A
	TSB $0B
	LDA $1C
	LSR A
	LSR A
	LSR A
	DEC A
	DEC A
	AND #$003F
	STA $09
	SEP #$20
	LDA $09
	CLC
	ADC #$20
	BIT #$40
	BNE label_80ACD4
	LDA $0B
	CMP $09
	BCS label_80ACC8
	JMP label_80AD70

label_80ACC8:
	LDA $09
	CLC
	ADC #$20
	CMP $0B
	BCS label_80ACEA
	JMP label_80AD70

label_80ACD4:
	LDA $0B
	CMP $09
	BCC label_80ACDC
	BRA label_80ACEA

label_80ACDC:
	LDA $09
	CLC
	ADC #$20
	AND #$3F
	CMP $0B
	BCS label_80ACEA
	JMP label_80AD70

label_80ACEA:
	REP #$20
	LDA $03
	AND #$07FF
	ORA #$3000
	STA $03
	JML $008755

label_80ACFA:
	AND #$7000
	CMP #$3000
	BNE label_80AD6A
	LDA $03
	LSR A
	LSR A
	LSR A
	LSR A
	LSR A
	AND #$001F
	STA $0B
	LDA $03
	AND #$0800
	XBA
	ASL A
	ASL A
	TSB $0B
	LDA $20
	LSR A
	LSR A
	LSR A
	DEC A
	DEC A
	AND #$003F
	STA $09
	SEP #$20
	LDA $09
	CLC
	ADC #$20
	BIT #$40
	BNE label_80AD44
	LDA $0B
	CMP $09
	BCS label_80AD38
	JMP label_80AD70

label_80AD38:
	LDA $09
	CLC
	ADC #$20
	CMP $0B
	BCS label_80AD5A
	JMP label_80AD70

label_80AD44:
	LDA $0B
	CMP $09
	BCC label_80AD4C
	BRA label_80AD5A

label_80AD4C:
	LDA $09
	CLC
	ADC #$20
	AND #$3F
	CMP $0B
	BCS label_80AD5A
	JMP label_80AD70

label_80AD5A:
	REP #$20
	LDA $03
	AND #$07FF
	ORA #$3800
	STA $03
	JML $008755

label_80AD6A:
	LDA $03
	JML $008755

label_80AD70:
	REP #$20
	LDA $05
	BEQ label_80AD80
	INY
	INY
	INY
	INY
	SEP #$20
	JML $008726

label_80AD80:
	LDA [$00],Y
	INY
	INY
	XBA
	AND #$FF
	AND $03851A,X
	TYA
	CLC
	ADC $03
	TAY
	SEP #$20
	JML $008726
	REP #$20
	LDA #$0000
	STA $7F8183
	STA $7F8187
	STA $7F8185
	STA $7F8189
	PLP
	RTL







; 816A
NMI:		SEI
		PHP
		REP #$30
		PHA
		PHX
		PHY
		PHB : PHK : PLB
		SEP #$20
		LDA $4210



		LDA !SPC3 : BNE .NoSongUpdate
		LDY $2142
		CPY $7DFF : BNE .MusicDone
		.NoSongUpdate
		STA $2142				;  | ; APU I/O Port
		STA $7DFF				;  | 
		STZ $7DFB				;  | 
		.MusicDone
		LDA !SPC1 : STA $2140
		LDA $7DFA : STA $2141
		LDA $7DFC : STA $2143
		STZ $7DF9
		STZ $7DFA
		STZ $7DFC



		LDA #$80 : STA $2100
		STZ $420C
		LDA $41 : STA $2123
		LDA $42 : STA $2124
		LDA $43 : STA $2125
		LDA $44 : STA $2130



		LDA $6D9B : BPL .Normal				;\
		JMP .82C4					; | check level type (go to $0082C4)
		.Normal						;/

		LDA $40
		AND #$FB
		STA $2132
		LDA #$09 : STA $2105
		LDA $10 : BEQ .NoLag
		LDA $6D9B
		LSR A : BEQ .
		JMP .827A


		.NoLag
		INC $10						; set "processing frame" flag



		.Special




CODE_0081CE:        A5 40         LDA $40                   ; \ Get the CGADSUB byte... 
CODE_0081D0:        29 FB         AND.B #$FB                ;  |Get the Add/Subtract Select and Enable part... 
CODE_0081D2:        8D 31 21      STA.W $2131               ; / ...and store it to the A/SSaE register... ; Add/Subtract Select and Enable
CODE_0081D5:        A9 09         LDA.B #$09                ; \ 8x8 tiles, Graphics mode 1 
CODE_0081D7:        8D 05 21      STA.W $2105               ; /  ; BG Mode and Tile Size Setting
CODE_0081DA:        A5 10         LDA $10                   ; \ If there isn't any lag, 
CODE_0081DC:        F0 09         BEQ CODE_0081E7           ; / branch to $81E7 
CODE_0081DE:        AD 9B 0D      LDA.W $0D9B               ; \  
CODE_0081E1:        4A            LSR                       ;  |If not on a special level, branch to NMINotSpecialLv 
CODE_0081E2:        F0 62         BEQ NMINotSpecialLv       ; /  
CODE_0081E4:        4C 7A 82      JMP.W CODE_00827A         

CODE_0081E7:        E6 10         INC $10                   
CODE_0081E9:        20 88 A4      JSR.W CODE_00A488         
CODE_0081EC:        AD 9B 0D      LDA.W $0D9B               
CODE_0081EF:        4A            LSR                       
CODE_0081F0:        D0 30         BNE CODE_008222           
CODE_0081F2:        B0 03         BCS CODE_0081F7           
CODE_0081F4:        20 AC 8D      JSR.W DrawStatusBar       
CODE_0081F7:        AD C6 13      LDA.W $13C6               ; \  
CODE_0081FA:        C9 08         CMP.B #$08                ;  |If the current cutscene isn't the ending, 
CODE_0081FC:        D0 0B         BNE CODE_008209           ; / branch to $8209 
CODE_0081FE:        AD FE 1F      LDA.W $1FFE               ; \  
CODE_008201:        F0 17         BEQ CODE_00821A           ;  |Related to reloading the palettes when switching 
CODE_008203:        22 67 95 0C   JSL.L CODE_0C9567         ;  |to another background during the credits. 
CODE_008207:        80 11         BRA CODE_00821A           ; /  

CODE_008209:        22 AD 87 00   JSL.L CODE_0087AD         
CODE_00820D:        AD 3A 14      LDA.W $143A               
CODE_008210:        F0 05         BEQ CODE_008217           
CODE_008212:        20 C2 A7      JSR.W CODE_00A7C2         
CODE_008215:        80 26         BRA CODE_00823D           

CODE_008217:        20 90 A3      JSR.W CODE_00A390         
CODE_00821A:        20 36 A4      JSR.W CODE_00A436         
CODE_00821D:        20 00 A3      JSR.W MarioGFXDMA         
CODE_008220:        80 1B         BRA CODE_00823D           

CODE_008222:        AD D9 13      LDA.W $13D9               
CODE_008225:        C9 0A         CMP.B #$0A                
CODE_008227:        D0 0E         BNE CODE_008237           
CODE_008229:        AC E8 1D      LDY.W $1DE8               
CODE_00822C:        88            DEY                       
CODE_00822D:        88            DEY                       
CODE_00822E:        C0 04         CPY.B #$04                
CODE_008230:        B0 05         BCS CODE_008237           
CODE_008232:        20 29 A5      JSR.W CODE_00A529         
CODE_008235:        80 0C         BRA CODE_008243           

CODE_008237:        20 E3 A4      JSR.W CODE_00A4E3         
CODE_00823A:        20 00 A3      JSR.W MarioGFXDMA         
CODE_00823D:        20 D2 85      JSR.W LoadScrnImage       
CODE_008240:        20 49 84      JSR.W DoSomeSpriteDMA     
CODE_008243:        20 50 86      JSR.W ControllerUpdate    
NMINotSpecialLv:    A5 1A         LDA RAM_ScreenBndryXLo    ; \  
CODE_008248:        8D 0D 21      STA.W $210D               ;  |Set BG 1 Horizontal Scroll Offset ; BG 1 Horizontal Scroll Offset
CODE_00824B:        A5 1B         LDA RAM_ScreenBndryXHi    ;  |to X position of screen boundry  
CODE_00824D:        8D 0D 21      STA.W $210D               ; /  ; BG 1 Horizontal Scroll Offset
CODE_008250:        A5 1C         LDA RAM_ScreenBndryYLo    ; \  
CODE_008252:        18            CLC                       ;  | 
CODE_008253:        6D 88 18      ADC.W RAM_Layer1DispYLo   ;  |Set BG 1 Vertical Scroll Offset 
CODE_008256:        8D 0E 21      STA.W $210E               ;  |to Y position of screen boundry + Layer 1 disposition ; BG 1 Vertical Scroll Offset
CODE_008259:        A5 1D         LDA RAM_ScreenBndryYHi    ;  | 
CODE_00825B:        6D 89 18      ADC.W RAM_Layer1DispYHi   ;  | 
CODE_00825E:        8D 0E 21      STA.W $210E               ; /  ; BG 1 Vertical Scroll Offset
CODE_008261:        A5 1E         LDA $1E                   ; \  
CODE_008263:        8D 0F 21      STA.W $210F               ;  |Set BG 2 Horizontal Scroll Offset ; BG 2 Horizontal Scroll Offset
CODE_008266:        A5 1F         LDA $1F                   ;  |to X position of Layer 2 
CODE_008268:        8D 0F 21      STA.W $210F               ; /  ; BG 2 Horizontal Scroll Offset
CODE_00826B:        A5 20         LDA $20                   ; \  
CODE_00826D:        8D 10 21      STA.W $2110               ;  |Set BG 2 Vertical Scroll Offset ; BG 2 Vertical Scroll Offset
CODE_008270:        A5 21         LDA $21                   ;  |to Y position of Layer 2 
CODE_008272:        8D 10 21      STA.W $2110               ; /  ; BG 2 Vertical Scroll Offset
CODE_008275:        AD 9B 0D      LDA.W $0D9B               ; \ If in a normal (not special) level, branch 
CODE_008278:        F0 18         BEQ CODE_008292           ; /  
CODE_00827A:        A9 81         LDA.B #$81                
CODE_00827C:        AC C6 13      LDY.W $13C6               ; \  
CODE_00827F:        C0 08         CPY.B #$08                ;  |If not playing ending movie, branch to $82A1 
CODE_008281:        D0 1E         BNE CODE_0082A1           ; /  
CODE_008283:        AC AE 0D      LDY.W $0DAE               ; \  
CODE_008286:        8C 00 21      STY.W $2100               ; / Set brightness to $0DAE ; Screen Display Register
CODE_008289:        AC 9F 0D      LDY.W $0D9F               ; \  
CODE_00828C:        8C 0C 42      STY.W $420C               ; / Set HDMA channel enable to $0D9F ; H-DMA Channel Enable
CODE_00828F:        4C 8C 83      JMP.W IRQNMIEnding        

CODE_008292:        A0 24         LDY.B #$24                ; \  ; IRQ timer, at which scanline the IRQ will be fired.
CODE_008294:        AD 11 42      LDA.W $4211               ;  |(i.e. below the status bar) ; IRQ Flag By H/V Count Timer
CODE_008297:        8C 09 42      STY.W $4209               ;  | ; V-Count Timer (Upper 8 Bits)
CODE_00829A:        9C 0A 42      STZ.W $420A               ; /  ; V-Count Timer MSB (Bit 0)
CODE_00829D:        64 11         STZ $11                   
CODE_00829F:        A9 A1         LDA.B #$A1                
CODE_0082A1:        8D 00 42      STA.W $4200               ; NMI, V/H Count, and Joypad Enable
CODE_0082A4:        9C 11 21      STZ.W $2111               ; \  ; BG 3 Horizontal Scroll Offset- Write twice register
CODE_0082A7:        9C 11 21      STZ.W $2111               ;  |Set Layer 3 horizontal and vertical ; BG 3 Horizontal Scroll Offset
CODE_0082AA:        9C 12 21      STZ.W $2112               ;  |scroll to x00 ; BG 3 Vertical Scroll Offset ; Write twice register
CODE_0082AD:        9C 12 21      STZ.W $2112               ; /  ; BG 3 Vertical Scroll Offset
CODE_0082B0:        AD AE 0D      LDA.W $0DAE               ; \  
CODE_0082B3:        8D 00 21      STA.W $2100               ; / Set brightness to $0DAE ; Screen Display Register
CODE_0082B6:        AD 9F 0D      LDA.W $0D9F               ; \  
CODE_0082B9:        8D 0C 42      STA.W $420C               ; / Set HDMA channel enable to $0D9F ; H-DMA Channel Enable
CODE_0082BC:        C2 30         REP #$30                  ; \ Pull all ; Index (16 bit) Accum (16 bit) 
CODE_0082BE:        AB            PLB                       ;  | 
CODE_0082BF:        7A            PLY                       ;  | 
CODE_0082C0:        FA            PLX                       ;  | 
CODE_0082C1:        68            PLA                       ;  | 
CODE_0082C2:        28            PLP                       ; /  
CODE_0082C3:        40            RTI                       ; And return 

CODE_0082C4:        A5 10         LDA $10                   ; \ If there is lag, ; Index (8 bit) Accum (8 bit) 
CODE_0082C6:        D0 2F         BNE CODE_0082F7           ; / branch to $82F7 
CODE_0082C8:        E6 10         INC $10                   
CODE_0082CA:        AD 3A 14      LDA.W $143A               ; \ If Mario Start! graphics shouldn't be loaded, 
CODE_0082CD:        F0 05         BEQ CODE_0082D4           ; / branch to $82D4 
ADDR_0082CF:        20 C2 A7      JSR.W CODE_00A7C2         
ADDR_0082D2:        80 14         BRA CODE_0082E8           

CODE_0082D4:        20 36 A4      JSR.W CODE_00A436         
CODE_0082D7:        20 00 A3      JSR.W MarioGFXDMA         
CODE_0082DA:        2C 9B 0D      BIT.W $0D9B               
CODE_0082DD:        50 09         BVC CODE_0082E8           
CODE_0082DF:        20 A9 98      JSR.W CODE_0098A9         
CODE_0082E2:        AD 9B 0D      LDA.W $0D9B               
CODE_0082E5:        4A            LSR                       
CODE_0082E6:        B0 03         BCS CODE_0082EB           
CODE_0082E8:        20 AC 8D      JSR.W DrawStatusBar       
CODE_0082EB:        20 88 A4      JSR.W CODE_00A488         
CODE_0082EE:        20 D2 85      JSR.W LoadScrnImage       
CODE_0082F1:        20 49 84      JSR.W DoSomeSpriteDMA     
CODE_0082F4:        20 50 86      JSR.W ControllerUpdate    
CODE_0082F7:        A9 09         LDA.B #$09                
CODE_0082F9:        8D 05 21      STA.W $2105               ; BG Mode and Tile Size Setting
CODE_0082FC:        A5 2A         LDA $2A                   
CODE_0082FE:        18            CLC                       
CODE_0082FF:        69 80         ADC.B #$80                
CODE_008301:        8D 1F 21      STA.W $211F               ; Mode 7 Center Position X
CODE_008304:        A5 2B         LDA $2B                   
CODE_008306:        69 00         ADC.B #$00                
CODE_008308:        8D 1F 21      STA.W $211F               ; Mode 7 Center Position X
CODE_00830B:        A5 2C         LDA $2C                   
CODE_00830D:        18            CLC                       
CODE_00830E:        69 80         ADC.B #$80                
CODE_008310:        8D 20 21      STA.W $2120               ; Mode 7 Center Position Y
CODE_008313:        A5 2D         LDA $2D                   
CODE_008315:        69 00         ADC.B #$00                
CODE_008317:        8D 20 21      STA.W $2120               ; Mode 7 Center Position Y
CODE_00831A:        A5 2E         LDA $2E                   
CODE_00831C:        8D 1B 21      STA.W $211B               ; Mode 7 Matrix Parameter A
CODE_00831F:        A5 2F         LDA $2F                   
CODE_008321:        8D 1B 21      STA.W $211B               ; Mode 7 Matrix Parameter A
CODE_008324:        A5 30         LDA $30                   
CODE_008326:        8D 1C 21      STA.W $211C               ; Mode 7 Matrix Parameter B
CODE_008329:        A5 31         LDA $31                   
CODE_00832B:        8D 1C 21      STA.W $211C               ; Mode 7 Matrix Parameter B
CODE_00832E:        A5 32         LDA $32                   
CODE_008330:        8D 1D 21      STA.W $211D               ; Mode 7 Matrix Parameter C
CODE_008333:        A5 33         LDA $33                   
CODE_008335:        8D 1D 21      STA.W $211D               ; Mode 7 Matrix Parameter C
CODE_008338:        A5 34         LDA $34                   
CODE_00833A:        8D 1E 21      STA.W $211E               ; Mode 7 Matrix Parameter D
CODE_00833D:        A5 35         LDA $35                   
CODE_00833F:        8D 1E 21      STA.W $211E               ; Mode 7 Matrix Parameter D
CODE_008342:        20 16 84      JSR.W SETL1SCROLL         
CODE_008345:        AD 9B 0D      LDA.W $0D9B               
CODE_008348:        4A            LSR                       
CODE_008349:        90 11         BCC CODE_00835C           
CODE_00834B:        AD AE 0D      LDA.W $0DAE               
CODE_00834E:        8D 00 21      STA.W $2100               ; Screen Display Register
CODE_008351:        AD 9F 0D      LDA.W $0D9F               
CODE_008354:        8D 0C 42      STA.W $420C               ; H-DMA Channel Enable
CODE_008357:        A9 81         LDA.B #$81                
CODE_008359:        4C F3 83      JMP.W CODE_0083F3         

CODE_00835C:        A0 24         LDY.B #$24                
CODE_00835E:        2C 9B 0D      BIT.W $0D9B               
CODE_008361:        50 0E         BVC CODE_008371           
CODE_008363:        AD FC 13      LDA.W $13FC               
CODE_008366:        0A            ASL                       
CODE_008367:        AA            TAX                       
CODE_008368:        BD E8 F8      LDA.W DATA_00F8E8,X       
CODE_00836B:        C9 2A         CMP.B #$2A                
CODE_00836D:        D0 02         BNE CODE_008371           
CODE_00836F:        A0 2D         LDY.B #$2D                
CODE_008371:        4C 94 82      JMP.W CODE_008294         

IRQHandler:         78            SEI                       ; Set Interrupt flag so routine can start 
IRQStart:           08            PHP                       ; \ Save A/X/Y/P/B 
CODE_008376:        C2 30         REP #$30                  ;  |P = Processor Flags, B = bank number for all $xxxx operations ; Index (16 bit) Accum (16 bit) 
CODE_008378:        48            PHA                       ;  |Set B to 0$0 
CODE_008379:        DA            PHX                       ;  | 
CODE_00837A:        5A            PHY                       ;  | 
CODE_00837B:        8B            PHB                       ;  | 
CODE_00837C:        4B            PHK                       ;  | 
CODE_00837D:        AB            PLB                       ; /  
CODE_00837E:        E2 30         SEP #$30                  ; Index (8 bit) Accum (8 bit) 
CODE_008380:        AD 11 42      LDA.W $4211               ; Read the IRQ register, 'unapply' the interrupt ; IRQ Flag By H/V Count Timer
CODE_008383:        10 2D         BPL CODE_0083B2           ; If "Timer IRQ" is clear, skip the next code block 
CODE_008385:        A9 81         LDA.B #$81                
CODE_008387:        AC 9B 0D      LDY.W $0D9B               
CODE_00838A:        30 2E         BMI CODE_0083BA           ; If Bit 7 (negative flag) is set, branch to a different IRQ mode 
IRQNMIEnding:       8D 00 42      STA.W $4200               ; Enable NMI Interrupt and Automatic Joypad reading ; NMI, V/H Count, and Joypad Enable
CODE_00838F:        A0 1F         LDY.B #$1F                
CODE_008391:        20 3B 84      JSR.W WaitForHBlank       
CODE_008394:        A5 22         LDA $22                   ; \ Adjust scroll settings for layer 3 
CODE_008396:        8D 11 21      STA.W $2111               ;  | ; BG 3 Horizontal Scroll Offset
CODE_008399:        A5 23         LDA $23                   ;  | 
CODE_00839B:        8D 11 21      STA.W $2111               ;  | ; BG 3 Horizontal Scroll Offset
CODE_00839E:        A5 24         LDA $24                   ;  | 
CODE_0083A0:        8D 12 21      STA.W $2112               ;  | ; BG 3 Vertical Scroll Offset
CODE_0083A3:        A5 25         LDA $25                   ;  | 
CODE_0083A5:        8D 12 21      STA.W $2112               ; /  ; BG 3 Vertical Scroll Offset
CODE_0083A8:        A5 3E         LDA $3E                   ; \Set the layer BG sizes, L3 priority, and BG mode 
CODE_0083AA:        8D 05 21      STA.W $2105               ; /(Effectively, this is the screen mode) ; BG Mode and Tile Size Setting
CODE_0083AD:        A5 40         LDA $40                   ; \Write CGADSUB 
CODE_0083AF:        8D 31 21      STA.W $2131               ; / ; Add/Subtract Select and Enable
CODE_0083B2:        C2 30         REP #$30                  ; \ Pull everything back ; Index (16 bit) Accum (16 bit) 
CODE_0083B4:        AB            PLB                       ;  | 
CODE_0083B5:        7A            PLY                       ;  | 
CODE_0083B6:        FA            PLX                       ;  | 
CODE_0083B7:        68            PLA                       ;  | 
CODE_0083B8:        28            PLP                       ; / 
EmptyHandler:       40            RTI                       ; And Return 

CODE_0083BA:        2C 9B 0D      BIT.W $0D9B               ; Get bit 6 of $0D9B ; Index (8 bit) Accum (8 bit) 
CODE_0083BD:        50 24         BVC CODE_0083E3           ; If clear, skip the next code section 
CODE_0083BF:        A4 11         LDY $11                   ; \Skip if $11 = 0 
CODE_0083C1:        F0 0D         BEQ CODE_0083D0           ; / 
CODE_0083C3:        8D 00 42      STA.W $4200               ; #$81 -> NMI / Controller Enable reg ; NMI, V/H Count, and Joypad Enable
CODE_0083C6:        A0 14         LDY.B #$14                
CODE_0083C8:        20 3B 84      JSR.W WaitForHBlank       
CODE_0083CB:        20 16 84      JSR.W SETL1SCROLL         
CODE_0083CE:        80 D8         BRA CODE_0083A8           

CODE_0083D0:        E6 11         INC $11                   ; $11++ 
CODE_0083D2:        AD 11 42      LDA.W $4211               ; \ Set up the IRQ routine for layer 3 ; IRQ Flag By H/V Count Timer
CODE_0083D5:        A9 AE         LDA.B #$AE                ;  |-\  
CODE_0083D7:        38            SEC                       ;  |  |Vertical Counter trigger at 174 - $1888 
CODE_0083D8:        ED 88 18      SBC.W RAM_Layer1DispYLo   ;  |-/ Oddly enough, $1888 seems to be 16-bit, but the 
CODE_0083DB:        8D 09 42      STA.W $4209               ;  |Store to Vertical Counter Timer ; V-Count Timer (Upper 8 Bits)
CODE_0083DE:        9C 0A 42      STZ.W $420A               ; / Make the high byte of said timer 0 ; V-Count Timer MSB (Bit 0)
CODE_0083E1:        A9 A1         LDA.B #$A1                ; A = NMI enable, V count enable, joypad automatic read enable, H count disable 
CODE_0083E3:        AC 93 14      LDY.W $1493               ; if $1493 = 0 skip down 
CODE_0083E6:        F0 0B         BEQ CODE_0083F3           
CODE_0083E8:        AC 95 14      LDY.W $1495               ; \ If $1495 is <#$40 
CODE_0083EB:        C0 40         CPY.B #$40                ;  | 
CODE_0083ED:        90 04         BCC CODE_0083F3           ; / Skip down 
CODE_0083EF:        A9 81         LDA.B #$81                
CODE_0083F1:        80 99         BRA IRQNMIEnding          ; Jump up to IRQNMIEnding 

CODE_0083F3:        8D 00 42      STA.W $4200               ; A -> NMI/Joypad Auto-Read/HV-Count Control Register ; NMI, V/H Count, and Joypad Enable
CODE_0083F6:        20 39 84      JSR.W CODE_008439         
CODE_0083F9:        EA            NOP                       ; \Not often you see NOP, I think there was a JSL here at one point maybe 
CODE_0083FA:        EA            NOP                       ; / 
CODE_0083FB:        A9 07         LDA.B #$07                ; \Write Screen register 
CODE_0083FD:        8D 05 21      STA.W $2105               ; / ; BG Mode and Tile Size Setting
CODE_008400:        A5 3A         LDA $3A                   ; \ Write L1 Horizontal scroll 
CODE_008402:        8D 0D 21      STA.W $210D               ;  | ; BG 1 Horizontal Scroll Offset
CODE_008405:        A5 3B         LDA $3B                   ;  | 
CODE_008407:        8D 0D 21      STA.W $210D               ; /  ; BG 1 Horizontal Scroll Offset
CODE_00840A:        A5 3C         LDA $3C                   ; \ Write L1 Vertical Scroll 
CODE_00840C:        8D 0E 21      STA.W $210E               ;  | ; BG 1 Vertical Scroll Offset
CODE_00840F:        A5 3D         LDA $3D                   ;  | 
CODE_008411:        8D 0E 21      STA.W $210E               ; /  ; BG 1 Vertical Scroll Offset
CODE_008414:        80 9C         BRA CODE_0083B2           ; And exit IRQ 

SETL1SCROLL:        A9 59         LDA.B #$59                ; \ 
CODE_008418:        8D 07 21      STA.W $2107               ; /Write L1 GFX source address ; BG 1 Address and Size
CODE_00841B:        A9 07         LDA.B #$07                ; \Write L1/L2 Tilemap address 
CODE_00841D:        8D 0B 21      STA.W $210B               ; / ; BG 1 & 2 Tile Data Designation
CODE_008420:        A5 1A         LDA RAM_ScreenBndryXLo    ; \ Write L1 Horizontal scroll 
CODE_008422:        8D 0D 21      STA.W $210D               ;  | ; BG 1 Horizontal Scroll Offset
CODE_008425:        A5 1B         LDA RAM_ScreenBndryXHi    ;  | 
CODE_008427:        8D 0D 21      STA.W $210D               ; / ; BG 1 Horizontal Scroll Offset
CODE_00842A:        A5 1C         LDA RAM_ScreenBndryYLo    ; \ $1C + $1888 -> L1 Vert scroll 
CODE_00842C:        18            CLC                       ;  |$1888 = Some sort of vertioffset 
CODE_00842D:        6D 88 18      ADC.W RAM_Layer1DispYLo   ;  | 
CODE_008430:        8D 0E 21      STA.W $210E               ; / ; BG 1 Vertical Scroll Offset
CODE_008433:        A5 1D         LDA RAM_ScreenBndryYHi    ; \Other half of L1 vert scroll 
CODE_008435:        8D 0E 21      STA.W $210E               ; / ; BG 1 Vertical Scroll Offset
Return008438:       60            RTS                       ; Return 

CODE_008439:        A0 20         LDY.B #$20                ; <<- Could this be just to waste time? 
WaitForHBlank:      2C 12 42      BIT.W $4212               ; So... LDY gets set with 20 if there is a H-Blank...? ; H/V Blank Flags and Joypad Status
CODE_00843E:        70 F9         BVS CODE_008439           ; if in H-Blank, make Y #$20 and try again 
CODE_008440:        2C 12 42      BIT.W $4212               ; Now wait until not in H-Blank ; H/V Blank Flags and Joypad Status
CODE_008443:        50 FB         BVC CODE_008440           
CODE_008445:        88            DEY                       ;  |Y = 0 
CODE_008446:        D0 FD         BNE CODE_008445           ; / ...wait a second... why didn't they just do LDY #$00? ...waste more time? 
Return008448:       60            RTS                       ; return 

DoSomeSpriteDMA:    9C 00 43      STZ.W $4300               ; Parameters for DMA Transfer
CODE_00844C:        C2 20         REP #$20                  ; Accum (16 bit) 
CODE_00844E:        9C 02 21      STZ.W $2102               ; OAM address ; Address for Accessing OAM
CODE_008451:        A9 04 00      LDA.W #$0004              
CODE_008454:        8D 01 43      STA.W $4301               ; Dest. address = $2104 (data write to OAM) ; B Address
CODE_008457:        A9 02 00      LDA.W #$0002              
CODE_00845A:        8D 03 43      STA.W $4303               ; Source address = $00:0200 ; A Address (High Byte)
CODE_00845D:        A9 20 02      LDA.W #$0220              
CODE_008460:        8D 05 43      STA.W $4305               ; $0220 bytes to transfer ; Number Bytes to Transfer (Low Byte) (DMA)
CODE_008463:        A0 01         LDY.B #$01                
CODE_008465:        8C 0B 42      STY.W $420B               ; Start DMA ; Regular DMA Channel Enable
CODE_008468:        E2 20         SEP #$20                  ; Accum (8 bit) 
CODE_00846A:        A9 80         LDA.B #$80                ; \  
CODE_00846C:        8D 03 21      STA.W $2103               ;  | 
CODE_00846F:        A5 3F         LDA $3F                   ;  |Change the OAM read/write address to #$8000 + $3F 
CODE_008471:        8D 02 21      STA.W $2102               ; /  ; Address for Accessing OAM
Return008474:       60            RTS                       ; Return 