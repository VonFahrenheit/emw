;==========================;
;HEADERS FOR LEVEL MESSAGES;
;==========================;
; --Manual--
;
; Headers contain general settings for messages.
; They are always applied at the start of message load.
; The format is quite simple:
;
;	- Portrait index
;	- Message sequence
;	- Dialogue
;	- Text speed + !MsgMode
;
; Portrait index is written to !MsgPortrait.
; Adding 0x40 to the index xflips the portrait and puts it on the left side of the window.
; Adding 0x80 to the index activates cinematic mode.
;
; Message sequence is written to !MsgSequence and sets !MsgCounter to 0x01.
; If the value is 0x00, no write takes place.
;
; Dialogue is written to !MsgOptions.
; If this is nonzero, it should be followed by 2 bytes; 1 for !MsgOptionRow and 1 for !MsgDestination
;
; Text speed is written to !MsgSpeed.
; It defines how many frames should pass between each character being written.
; Setting this to 0x00 writes the entire message at once (does not account for commands other than FF).
; The highest two bits are written to !MsgMode.

HEADER:


.000a	db $06,$00,$00,$43
.000b	db $07,$00,$03,$04,$00,$43

.001a	db $00,$00,$00,$00
.001b	db $00,$00,$00,$00

.002a	db $09,$00,$00,$02
.002b	db $09,$00,$00,$02

.003a	db $00,$00,$00,$00
.003b	db $00,$00,$00,$00

.004a	db $00,$00,$00,$00
.004b	db $00,$00,$00,$00

.005a	db $00,$00,$00,$00
.005b	db $00,$00,$00,$00

.006a
.006b

.007a	db $00,$03,$00,$04
.007b	db $00,$00,$00,$04

.008a
.008b

.009a
.009b

.00Aa
.00Ab

.00Ba
.00Bb

.00Ca
.00Cb

.00Da
.00Db

.00Ea	db $00,$00,$00,$00
.00Eb	db $00,$00,$00,$02

.00Fa
.00Fb

.010a
.010b

.011a
.011b

.012a
.012b

.013a
.013b

.014a
.014b

.015a
.015b

.016a	db $00,$00,$00,$08
.016b	db $00,$00,$00,$08

.017a
.017b

.018a
.018b

.019a
.019b

.01Aa	db $01,$00,$00,$08
.01Ab	db $01,$00,$00,$08

.01Ba	db $01,$00,$00,$08
.01Bb	db $01,$00,$00,$08

.01Ca	db $01,$00,$00,$08
.01Cb	db $01,$00,$00,$08

.01Da	db $01,$00,$00,$08
.01Db	db $01,$00,$00,$08

.01Ea
.01Eb

.01Fa
.01Fb

.020a
.020b

.021a
.021b

.022a
.022b

.023a
.023b

.024a
.024b

.101a
.101b

.102a
.102b

.103a
.103b

.104a
.104b

.105a
.105b

.106a	db $01,$00,$00,$00
.106b

.107a
.107b

.108a
.108b

.109a
.109b

.10Aa
.10Ab

.10Ba
.10Bb

.10Ca
.10Cb

.10Da
.10Db

.10Ea
.10Eb

.10Fa
.10Fb	db $00,$00,$00,$08

.110a
.110b

.111a
.111b

.112a	db $00,$00,$00,$08
.112b	db $00,$00,$00,$08

.113a	db $01,$00,$00,$08
.113b	db $00,$00,$00,$08

.114a	db $02,$00,$00,$08
.114b	db $02,$00,$00,$08

.115a	db $02,$00,$00,$08
.115b	db $02,$00,$00,$08

.116a	db $01,$00,$00,$08
.116b	db $01,$00,$00,$08

.117a	db $01,$00,$00,$08
.117b	db $01,$00,$00,$08

.118a	db $01,$00,$00,$08
.118b	db $01,$00,$00,$08

.119a	db $01,$00,$00,$08
.119b	db $01,$00,$00,$08

.11Aa	db $01,$00,$00,$08
.11Ab	db $01,$00,$00,$08

.11Ba
.11Bb

.11Ca
.11Cb

.11Da
.11Db

.11Ea
.11Eb

.11Fa
.11Fb

.120a
.120b

.121a
.121b

.122a
.122b

.123a
.123b

.124a
.124b

.125a
.125b

.126a
.126b

.127a
.127b

.128a
.128b

.129a
.129b

.12Aa
.12Ab

.12Ba
.12Bb

.12Ca
.12Cb

.12Da
.12Db

.12Ea
.12Eb

.12Fa
.12Fb

.130a
.130b

.131a
.131b

.132a
.132b

.133a
.133b

.134a
.134b

.135a
.135b

.136a
.136b

.137a
.137b

.138a
.138b

.139a
.139b

.13Aa
.13Ab

.13Ba
.13Bb


.Ptr	dw .000a,.000b
	dw .001a,.001b
	dw .002a,.002b
	dw .003a,.003b
	dw .004a,.004b
	dw .005a,.005b
	dw .006a,.006b
	dw .007a,.007b
	dw .008a,.008b
	dw .009a,.009b
	dw .00Aa,.00Ab
	dw .00Ba,.00Bb
	dw .00Ca,.00Cb
	dw .00Da,.00Db
	dw .00Ea,.00Eb
	dw .00Fa,.00Fb
	dw .010a,.010b
	dw .011a,.011b
	dw .012a,.012b
	dw .013a,.013b
	dw .014a,.014b
	dw .015a,.015b
	dw .016a,.016b
	dw .017a,.017b
	dw .018a,.018b
	dw .019a,.019b
	dw .01Aa,.01Ab
	dw .01Ba,.01Bb
	dw .01Ca,.01Cb
	dw .01Da,.01Db
	dw .01Ea,.01Eb
	dw .01Fa,.01Fb
	dw .020a,.020b
	dw .021a,.021b
	dw .022a,.022b
	dw .023a,.023b
	dw .024a,.024b

	dw .101a,.101b
	dw .102a,.102b
	dw .103a,.103b
	dw .104a,.104b
	dw .105a,.105b
	dw .106a,.106b
	dw .107a,.107b
	dw .108a,.108b
	dw .109a,.109b
	dw .10Aa,.10Ab
	dw .10Ba,.10Bb
	dw .10Ca,.10Cb
	dw .10Da,.10Db
	dw .10Ea,.10Eb
	dw .10Fa,.10Fb
	dw .110a,.110b
	dw .111a,.111b
	dw .112a,.112b
	dw .113a,.113b
	dw .114a,.114b
	dw .115a,.115b
	dw .116a,.116b
	dw .117a,.117b
	dw .118a,.118b
	dw .119a,.119b
	dw .11Aa,.11Ab
	dw .11Ba,.11Bb
	dw .11Ca,.11Cb
	dw .11Da,.11Db
	dw .11Ea,.11Eb
	dw .11Fa,.11Fb
	dw .120a,.120b
	dw .121a,.121b
	dw .122a,.122b
	dw .123a,.123b
	dw .124a,.124b
	dw .125a,.125b
	dw .126a,.126b
	dw .127a,.127b
	dw .128a,.128b
	dw .129a,.129b
	dw .12Aa,.12Ab
	dw .12Ba,.12Bb
	dw .12Ca,.12Cb
	dw .12Da,.12Db
	dw .12Ea,.12Eb
	dw .12Fa,.12Fb
	dw .130a,.130b
	dw .131a,.131b
	dw .132a,.132b
	dw .133a,.133b
	dw .134a,.134b
	dw .135a,.135b
	dw .136a,.136b
	dw .137a,.137b
	dw .138a,.138b
	dw .139a,.139b
	dw .13Aa,.13Ab
	dw .13Ba,.13Bb