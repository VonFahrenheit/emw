; This is a slightly altered DMA remapper by me, Von Fahrenheit.
; It does pretty much what the original by wiiqwertyuiop does, but is fully compatible with my other patches.
; Meant to be assembled from VR3.asm.

;================================;
;Move HDMA channel 7 to channel 2;
;================================;

org $009255
STA $4320,x

org $00925D
STA $4327

org $0092A0
LDA #$04

org $0092D7
STA $4320,x

org $0092E5
STA $4327

org $0092E8
LDA #$64

org $00CB0A
LDA #$04

org $03C50F
LDA #$04

;org $04DB97
;LDA #$04

org $0CAB96
LDA #$04

;=====================;
;Move DMA to channel 1;
;=====================;

; --008XXX

org $008449
STZ $4310

org $008454
STA $4311

org $00845A
STA $4313

org $008460
STA $4315

org $008463
LDY #$02

org $008611
STA $4310,x

org $008617
LDY #$02

org $008632
STA $4310,x

org $00863A
STA $4311

org $008720
STA $4314

org $00873E
STA $4311

org $00874E
STA $4310

org $008766
STA $4312

org $008769
STX $4315

org $008777
LDA #$02

org $00877E
STA $4311

org $00878C
STA $4312

org $00878F
STX $4315

org $0087A5
LDA #$02

org $0087D6
STA $4310,X

org $0087DC
LDA #$02

org $0087F8
STA $4310,X

org $0087FE
LDA #$02

org $008818
STA $4310,X

org $00881E
LDA #$02

org $00883B
STA $4310,X

org $008841
LDA #$02

org $00885F
STA $4310,X

org $008865
LDA #$02

org $008881
STA $4310,X

org $008889
STA $4315

org $00888C
LDA #$02

org $0088A8
STA $4310,X

org $0088AE
LDA #$02

org $0088CD
STA $4310,X

org $0088D5
STA $4315

org $0088D8
LDA #$02

org $008909
STA $4310,X

org $00890F
LDA #$02

org $00892B
STA $4310,X

org $008931
LDA #$02

org $00894B
STA $4310,X

org $008951
LDA #$02

org $00896E
STA $4310,X

org $008974
LDA #$02

org $008992
STA $4310,X

org $008998
LDA #$02

org $0089B4
STA $4310,X

org $0089BC
STA $4315

org $0089BF
LDA #$02

org $0089DB
STA $4310,X

org $0089E1
LDA #$02

org $008A00
STA $4310,X

org $008A08
STA $4315

org $008A0B
LDA #$02

org $008D13
STA $4310,X

org $008D19
LDA #$02

org $008D32
STA $4310,X

org $008D38
LDA #$02

org $008D51
STA $4310,X

org $008D57
LDA #$02

org $008D70
STA $4310,X

org $008D76
LDA #$02

; --009XXX

org $00923D
STA $4310,x

org $009243
LDA #$02

org $0098C0
STA $4310

org $0098CD
STA $4312

org $0098D2
STA $4314

org $0098D8
STA $4315

org $0098DB
LDY #$02

org $0098FC
STA $4310

org $009901
STA $4314

org $009904
LDX #$02

org $00990E
STA $4312

org $009918
STA $4315

; --00AXXX

org $00A302
LDX #$02

org $00A311
STA $4310

org $00A317
STA $4312

org $00A31C
STY $4314

org $00A322
STA $4315

org $00A330
STA $4310

org $00A33C
STA $4312

org $00A341
STY $4314

org $00A347
STA $4315

org $00A358
STA $4312

org $00A35E
STA $4315

org $00A361
LDY #$02

org $00A378
STA $4312

org $00A37E
STA $4315

org $00A381
LDY #$02

; these are overwritten by lunar magic and GFX_Loader
;org $00A39A
;STA $4310

;org $00A39F
;STY $4314

;org $00A3A2
;LDX #$02

org $00A3AF
STA $4312

org $00A3B5
STA $4315

org $00A3C6
STA $4312

org $00A3CC
STA $4315

org $00A3E2
STA $4312

org $00A3E8
STA $4315

org $00A3F3
STA $4312

org $00A3F9
STA $4315

org $00A40C
STA $4312

org $00A412
STA $4315

org $00A44E
STA $4310

org $00A454
STA $4312

org $00A459
STY $4314

org $00A45F
STA $4315

org $00A462
LDX #$02

org $00A470
STA $4312

org $00A476
STA $4315

org $00A4A4
STX $4314

org $00A4A7
STA $4315

org $00A4AC
STZ $4316

org $00A4BA
STA $4310

org $00A4BF
STA $4312

org $00A4C8
LDA #$02

org $00A4F3
STY $4310

org $00A4F9
STY $4312

org $00A4FC
STZ $4314

org $00A502
STY $4315

org $00A505
LDA #$02

org $00A7D2
STA $4310

org $00A7D8
STA $4312

org $00A7DD
STX $4314

org $00A7E3
STA $4315

org $00A7E6
LDX #$02

org $00A7F4
STA $4312

org $00A7FA
STA $4315

org $00A809
STA $4312

org $00A80F
STA $4315

org $00A81E
STA $4312

org $00A824
STA $4315

org $00A53F
STA $4310,X

org $00A552
STA $4313

org $00A555
LDA $4313

org $00A55C
STA $4313

org $00A55F
LDA #$02

org $00A57A
STA $4310,X

org $00A580
LDA #$02

; --04DXXX

;org $04D754
;STA $4310,x

;org $04D767
;STA $4313

;org $04D76A
;LDA #$02

; --0C9XXX

org $0C9580
STA $4310,Y

org $0C958C
ORA $4313

org $0C958F
STA $4313

org $0C9592
LDA #$02

org $0C95AB
STA $4310,Y

org $0C95B7
ORA $4313

org $0C95BA
STA $4313

org $0C95BD
LDA #$02

; -- Lunar Magic Map16 transfer

org $0FFA4C
STA $4312

org $0FFA52
STA $4315

org $0FFA5D
STA $4310

org $0FFA62
STX $4314

org $0FFA65
LDX #$02

;======================;
;Fix Lunar Magic hijack;
;======================;

if read3($00A390+1) != $00A020

   org read3($00A390+1)
   STZ $4316     
   REP #$20	
   LDA #$42F0  
   
   org read3($00A390+1)+$17            
   LDX #$02

endif
