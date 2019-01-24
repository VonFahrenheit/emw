@includefrom sa1.asm
; Remap:
; $7E:C800-$7E:FFFF to $40:C800-$40:FFFF,
; $7F:C800-$7F:FFFF to $41:C800-$41:FFFF.

if read1($0DE04F) == $7F
	ORG $0DE04E
		MVN $41,$41
	ORG $0DE039
		MVN $40,$40
endif

if read1($00BAD8+2) != $40

ORG $00BF2A+1
	db $40
ORG $00F4CF+1
	db $40
ORG $019523+1
	db $40
ORG $01D989+1
	db $40
ORG $02931A+1
	db $40
ORG $02960D+1
	db $40
ORG $02A6DB+1
	db $40
ORG $02BA95+1
	db $40
ORG $02D1AD+1
	db $40
ORG $00A58D
	db $01,$18,$00,$E4,$40,$00,$08
ORG $04DC60
	MVN $40,$0C
	
ORG $04D7F9
	LDA #$00
	STA $0D
	LDA #$D0
	STA $0E
	LDA #$40
	STA $0F
	LDA #$00
	STA $0A
	LDA #$D8
	STA $0B
	LDA #$40
	STA $0C
	LDA #$00
	STA $04
	LDA #$C8
	STA $05
	LDA #$40
ORG $04DA7D
	LDA #$40
ORG $04EEAC
	LDA #$40
ORG $04ED83
	LDA #$40
ORG $04EC78
	LDA #$40
ORG $04E690
	LDA #$40

ORG $00BAD8
DATA_00BAD8:
	db $00,$C8,$40,$B0,$C9,$40,$60,$CB
	db $40,$10,$CD,$40,$C0,$CE,$40,$70
	db $D0,$40,$20,$D2,$40,$D0,$D3,$40
	db $80,$D5,$40,$30,$D7,$40,$E0,$D8
	db $40,$90,$DA,$40,$40,$DC,$40,$F0
	db $DD,$40,$A0,$DF,$40,$50,$E1,$40
DATA_00BB08:
	db $00,$E3,$40,$B0,$E4,$40,$60,$E6
	db $40,$10,$E8,$40,$C0,$E9,$40,$70
	db $EB,$40,$20,$ED,$40,$D0,$EE,$40
	db $80,$F0,$40,$30,$F2,$40,$E0,$F3
	db $40,$90,$F5,$40,$40,$F7,$40,$F0
	db $F8,$40,$A0,$FA,$40,$50,$FC,$40
DATA_00BB38:
	db $00,$C8,$40,$00,$CA,$40,$00,$CC
	db $40,$00,$CE,$40,$00,$D0,$40,$00
	db $D2,$40,$00,$D4,$40,$00,$D6,$40
	db $00,$D8,$40,$00,$DA,$40,$00,$DC
	db $40,$00,$DE,$40,$00,$E0,$40,$00
	db $E2,$40

DATA_00BB62:
	db $00,$E3,$40,$B0,$E4,$40,$60,$E6
	db $40,$10,$E8,$40,$C0,$E9,$40,$70
	db $EB,$40,$20,$ED,$40,$D0,$EE,$40
	db $80,$F0,$40,$30,$F2,$40,$E0,$F3
	db $40,$90,$F5,$40,$40,$F7,$40,$F0
	db $F8,$40,$A0,$FA,$40,$50,$FC,$40
DATA_00BB92:
	db $00,$C8,$40,$B0,$C9,$40,$60,$CB
	db $40,$10,$CD,$40,$C0,$CE,$40,$70
	db $D0,$40,$20,$D2,$40,$D0,$D3,$40
	db $80,$D5,$40,$30,$D7,$40,$E0,$D8
	db $40,$90,$DA,$40,$40,$DC,$40,$F0
	db $DD,$40,$A0,$DF,$40,$50,$E1,$40
DATA_00BBC2:
	db $00,$E4,$40,$00,$E6,$40,$00,$E8
	db $40,$00,$EA,$40,$00,$EC,$40,$00
	db $EE,$40,$00,$F0,$40,$00,$F2,$40
	db $00,$F4,$40,$00,$F6,$40,$00,$F8
	db $40,$00,$FA,$40,$00,$FC,$40,$00
	db $FE,$40
DATA_00BBEC:
	db $00,$C8,$40,$00,$CA,$40,$00,$CC
	db $40,$00,$CE,$40,$00,$D0,$40,$00
	db $D2,$40,$00,$D4,$40,$00,$D6,$40
	db $00,$D8,$40,$00,$DA,$40,$00,$DC
	db $40,$00,$DE,$40,$00,$E0,$40,$00
	db $E2,$40
DATA_00BC16:
	db $00,$E4,$40,$00,$E6,$40,$00,$E8
	db $40,$00,$EA,$40,$00,$EC,$40,$00
	db $EE,$40,$00,$F0,$40,$00,$F2,$40
	db $00,$F4,$40,$00,$F6,$40,$00,$F8
	db $40,$00,$FA,$40,$00,$FC,$40,$00
	db $FE,$40
DATA_00BC40:
	db $00,$C8,$41,$B0,$C9,$41,$60,$CB
	db $41,$10,$CD,$41,$C0,$CE,$41,$70
	db $D0,$41,$20,$D2,$41,$D0,$D3,$41
	db $80,$D5,$41,$30,$D7,$41,$E0,$D8
	db $41,$90,$DA,$41,$40,$DC,$41,$F0
	db $DD,$41,$A0,$DF,$41,$50,$E1,$41
DATA_00BC70:
	db $00,$E3,$41,$B0,$E4,$41,$60,$E6
	db $41,$10,$E8,$41,$C0,$E9,$41,$70
	db $EB,$41,$20,$ED,$41,$D0,$EE,$41
	db $80,$F0,$41,$30,$F2,$41,$E0,$F3
	db $41,$90,$F5,$41,$40,$F7,$41,$F0
	db $F8,$41,$A0,$FA,$41,$50,$FC,$41
DATA_00BCA0:
	db $00,$C8,$41,$00,$CA,$41,$00,$CC
	db $41,$00,$CE,$41,$00,$D0,$41,$00
	db $D2,$41,$00,$D4,$41,$00,$D6,$41
	db $00,$D8,$41,$00,$DA,$41,$00,$DC
	db $41,$00,$DE,$41,$00,$E0,$41,$00
	db $E2,$41
DATA_00BCCA:
	db $00,$E3,$41,$B0,$E4,$41,$60,$E6
	db $41,$10,$E8,$41,$C0,$E9,$41,$70
	db $EB,$41,$20,$ED,$41,$D0,$EE,$41
	db $80,$F0,$41,$30,$F2,$41,$E0,$F3
	db $41,$90,$F5,$41,$40,$F7,$41,$F0
	db $F8,$41,$A0,$FA,$41,$50,$FC,$41
DATA_00BCFA:
	db $00,$C8,$41,$B0,$C9,$41,$60,$CB
	db $41,$10,$CD,$41,$C0,$CE,$41,$70
	db $D0,$41,$20,$D2,$41,$D0,$D3,$41
	db $80,$D5,$41,$30,$D7,$41,$E0,$D8
	db $41,$90,$DA,$41,$40,$DC,$41,$F0
	db $DD,$41,$A0,$DF,$41,$50,$E1,$41
DATA_00BD2A:
	db $00,$E4,$41,$00,$E6,$41,$00,$E8
	db $41,$00,$EA,$41,$00,$EC,$41,$00
	db $EE,$41,$00,$F0,$41,$00,$F2,$41
	db $00,$F4,$41,$00,$F6,$41,$00,$F8
	db $41,$00,$FA,$41,$00,$FC,$41,$00
	db $FE,$41
DATA_00BD54:
	db $00,$C8,$41,$00,$CA,$41,$00,$CC
	db $41,$00,$CE,$41,$00,$D0,$41,$00
	db $D2,$41,$00,$D4,$41,$00,$D6,$41
	db $00,$D8,$41,$00,$DA,$41,$00,$DC
	db $41,$00,$DE,$41,$00,$E0,$41,$00
	db $E2,$41
DATA_00BD7E:
	db $00,$E4,$41,$00,$E6,$41,$00,$E8
	db $41,$00,$EA,$41,$00,$EC,$41,$00
	db $EE,$41,$00,$F0,$41,$00,$F2,$41
	db $00,$F4,$41,$00,$F6,$41,$00,$F8
	db $41,$00,$FA,$41,$00,$FC,$41,$00
	db $FE,$41
	
ORG $009A24
	dl $40C800
ORG $009A42
	dl $40C800
ORG $03D7A2
	dl $40C800
ORG $048E95
	dl $40C800
ORG $049028
	dl $40C800
ORG $0492EA
	dl $40C800
ORG $0495D8
	dl $40C800
ORG $04DCEB
	dl $40C800
ORG $04EA57
	dl $40C800
ORG $04EDCD
	dl $40C800
ORG $0582C9
	dl $40C800
ORG $009A28
	dl $40C9B0
ORG $009A46
	dl $40C9B0
ORG $009A2C
	dl $41C800
ORG $03D7A8
	dl $41C800
ORG $04D771
	dl $41C800
ORG $04DCF3
	dl $41C800
ORG $05833B
	dl $41C800
ORG $009A30
	dl $41C9B0
ORG $04D775
	dl $41C9B0
ORG $00A051
	dl $40E300
ORG $048E13
	dl $40D000
ORG $048E7B
	dl $40D000
ORG $048F46
	dl $40D000
ORG $048F64
	dl $40D000
ORG $049221
	dl $40D000
ORG $04929A
	dl $40D000
ORG $04930A
	dl $40D000
ORG $049543
	dl $40D000
ORG $0496C1
	dl $40D000
ORG $049951
	dl $40D000
ORG $0582D9
	dl $40D000
ORG $05D89C
	dl $40D000
ORG $049240
	dl $40D800
ORG $04993B
	dl $40D800
ORG $0582E9
	dl $40D800
ORG $04D779
	dl $41CB60
ORG $04D77D
	dl $41CD10
ORG $04D781
	dl $41CEC0
ORG $04D785
	dl $41D070
ORG $04D789
	dl $41D220
ORG $04D78D
	dl $41D3D0
ORG $04D791
	dl $41D580
ORG $04D795
	dl $41D730
ORG $04D799
	dl $41D8E0
ORG $04D79D
	dl $41DA90
ORG $04D7A1
	dl $41DC40
ORG $04D7A5
	dl $41DDF0
ORG $04D7A9
	dl $41DFA0
ORG $04D7AD
	dl $41E150
ORG $04D7B1
	dl $41E300
ORG $04D7B5
	dl $41E4B0
ORG $04D7B9
	dl $41E660
ORG $04D7BD
	dl $41E810
ORG $04D7C1
	dl $41E9C0
ORG $04D7C5
	dl $41EB70
ORG $04D7C9
	dl $41ED20
ORG $04D7CD
	dl $41EED0
ORG $04D7D1
	dl $41F080
ORG $04D7D5
	dl $41F230
ORG $04D7D9
	dl $41F3E0
ORG $04D7DD
	dl $41F590
ORG $04D7E1
	dl $41F740
ORG $04D7E5
	dl $41F8F0
ORG $04D7E9
	dl $41FAA0
ORG $04D7ED
	dl $41FC50
ORG $04DD16
	dl $40E400
ORG $058301
	dl $40E400
ORG $04DD1E
	dl $40E440
ORG $04DD26
	dl $40E402
ORG $04DD2E
	dl $40E442
ORG $0582CD
	dl $40CA00
ORG $0582D1
	dl $40CC00
ORG $0582D5
	dl $40CE00
ORG $0582DD
	dl $40D200
ORG $0582E1
	dl $40D400
ORG $0582E5
	dl $40D600
ORG $0582ED
	dl $40DA00
ORG $0582F1
	dl $40DC00
ORG $0582F5
	dl $40DE00
ORG $0582F9
	dl $40E000
ORG $0582FD
	dl $40E200
ORG $058305
	dl $40E600
ORG $058309
	dl $40E800
ORG $05830D
	dl $40EA00
ORG $058311
	dl $40EC00
ORG $058315
	dl $40EE00
ORG $058319
	dl $40F000
ORG $05831D
	dl $40F200
ORG $058321
	dl $40F400
ORG $058325
	dl $40F600
ORG $058329
	dl $40F800
ORG $05832D
	dl $40FA00
ORG $058331
	dl $40FC00
ORG $058335
	dl $40FE00
ORG $05833F
	dl $41CA00
ORG $058343
	dl $41CC00
ORG $058347
	dl $41CE00
ORG $05834B
	dl $41D000
ORG $05834F
	dl $41D200
ORG $058353
	dl $41D400
ORG $058357
	dl $41D600
ORG $05835B
	dl $41D800
ORG $05835F
	dl $41DA00
ORG $058363
	dl $41DC00
ORG $058367
	dl $41DE00
ORG $05836B
	dl $41E000
ORG $05836F
	dl $41E200
ORG $058373
	dl $41E400
ORG $058377
	dl $41E600
ORG $05837B
	dl $41E800
ORG $05837F
	dl $41EA00
ORG $058383
	dl $41EC00
ORG $058387
	dl $41EE00
ORG $05838B
	dl $41F000
ORG $05838F
	dl $41F200
ORG $058393
	dl $41F400
ORG $058397
	dl $41F600
ORG $05839B
	dl $41F800
ORG $05839F
	dl $41FA00
ORG $0583A3
	dl $41FC00
ORG $0583A7
	dl $41FE00

endif