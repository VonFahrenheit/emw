

; note:
;	the 32 and 64 sizes are in tiles
;	since layer 3 uses 8x8 tiles, that means that 32 tiles is equal to 256 pixels, and 64 tiles equal to 512 pixels
;	because of this, defining a tilemap as 32x32 (tiles) is the same as 256x256 (pixels)
;	units are not specified in the list, it is simply assumed that the smaller numbers are tiles and the larger numbers are pixels

;	also, before anyone asks...
;	it's not possible to use any sizes other than these, since this is what the SNES hardware supports
;	256x256 is the smallest possible layer 3 and 512x512 is the largest possible layer 3


	!32x32		=	0
	!64x32		=	1
	!32x64		=	2
	!64x64		=	3

	!256x256	=	0
	!512x256	=	1
	!256x512	=	2
	!512x512	=	3



	BG3_Resolution:
	.B00	db $FF		; mode 7 tilemap
	.B01	db !64x64
	.B02	db !32x64
	.B03	db !32x64
	.B04	db !32x32
	.B05	db !32x32
	.B06	db !64x64
	.B07	db !64x32
	.B08	db !64x64
	.B09	db !64x32
	.B0A	db !64x32
	.B0B	db !64x64
	.B0C	db !64x32
	.B0D	db !64x64
	.B0E	db !64x64
	.B0F	db !32x64

	.B10	db !64x64
	.B11	db !64x64
	.B12	db !64x64
	.B13	db !64x64
	.B14	db !64x64
	.B15	db !64x64
	.B16	db !64x64
	.B17	db !64x64
	.B18	db !64x64
	.B19	db !64x64
	.B1A	db !64x64
	.B1B	db !64x64
	.B1C	db !64x64
	.B1D	db !64x64
	.B1E	db !64x64
	.B1F	db !64x64

	.B20	db !64x64
	.B21	db !64x64
	.B22	db !64x64
	.B23	db !64x64
	.B24	db !64x64
	.B25	db !64x64
	.B26	db !64x64
	.B27	db !64x64
	.B28	db !64x64
	.B29	db !64x64
	.B2A	db !64x64
	.B2B	db !64x64
	.B2C	db !64x64
	.B2D	db !64x64
	.B2E	db !64x64
	.B2F	db !64x64

	.B30	db !64x64
	.B31	db !64x64
	.B32	db !64x64
	.B33	db !64x64
	.B34	db !64x64
	.B35	db !64x64
	.B36	db !64x64
	.B37	db !64x64
	.B38	db !64x64
	.B39	db !64x64
	.B3A	db !64x64
	.B3B	db !64x64
	.B3C	db !64x64
	.B3D	db !64x64
	.B3E	db !64x64
	.B3F	db !64x64

	.B40	db !64x64
	.B41	db !64x64
	.B42	db !64x64
	.B43	db !64x64
	.B44	db !64x64
	.B45	db !64x64
	.B46	db !64x64
	.B47	db !64x64
	.B48	db !64x64
	.B49	db !64x64
	.B4A	db !64x64
	.B4B	db !64x64
	.B4C	db !64x64
	.B4D	db !64x64
	.B4E	db !64x64
	.B4F	db !64x64

	.B50	db !64x64
	.B51	db !64x64
	.B52	db !64x64
	.B53	db !64x64
	.B54	db !64x64
	.B55	db !64x64
	.B56	db !64x64
	.B57	db !64x64
	.B58	db !64x64
	.B59	db !64x64
	.B5A	db !64x64
	.B5B	db !64x64
	.B5C	db !64x64
	.B5D	db !64x64
	.B5E	db !64x64
	.B5F	db !64x64

	.B60	db !64x64
	.B61	db !64x64
	.B62	db !64x64
	.B63	db !64x64
	.B64	db !64x64
	.B65	db !64x64
	.B66	db !64x64
	.B67	db !64x64
	.B68	db !64x64
	.B69	db !64x64
	.B6A	db !64x64
	.B6B	db !64x64
	.B6C	db !64x64
	.B6D	db !64x64
	.B6E	db !64x64
	.B6F	db !64x64

	.B70	db !64x64
	.B71	db !64x64
	.B72	db !64x64
	.B73	db !64x64
	.B74	db !64x64
	.B75	db !64x64
	.B76	db !64x64
	.B77	db !64x64
	.B78	db !64x64
	.B79	db !64x64
	.B7A	db !64x64
	.B7B	db !64x64
	.B7C	db !64x64
	.B7D	db !64x64
	.B7E	db !64x64
	.B7F	db !64x64

	.B80	db !64x64
	.B81	db !64x64
	.B82	db !64x64
	.B83	db !64x64
	.B84	db !64x64
	.B85	db !64x64
	.B86	db !64x64
	.B87	db !64x64
	.B88	db !64x64
	.B89	db !64x64
	.B8A	db !64x64
	.B8B	db !64x64
	.B8C	db !64x64
	.B8D	db !64x64
	.B8E	db !64x64
	.B8F	db !64x64

	.B90	db !64x64
	.B91	db !64x64
	.B92	db !64x64
	.B93	db !64x64
	.B94	db !64x64
	.B95	db !64x64
	.B96	db !64x64
	.B97	db !64x64
	.B98	db !64x64
	.B99	db !64x64
	.B9A	db !64x64
	.B9B	db !64x64
	.B9C	db !64x64
	.B9D	db !64x64
	.B9E	db !64x64
	.B9F	db !64x64

	.BA0	db !64x64
	.BA1	db !64x64
	.BA2	db !64x64
	.BA3	db !64x64
	.BA4	db !64x64
	.BA5	db !64x64
	.BA6	db !64x64
	.BA7	db !64x64
	.BA8	db !64x64
	.BA9	db !64x64
	.BAA	db !64x64
	.BAB	db !64x64
	.BAC	db !64x64
	.BAD	db !64x64
	.BAE	db !64x64
	.BAF	db !64x64

	.BB0	db !64x64
	.BB1	db !64x64
	.BB2	db !64x64
	.BB3	db !64x64
	.BB4	db !64x64
	.BB5	db !64x64
	.BB6	db !64x64
	.BB7	db !64x64
	.BB8	db !64x64
	.BB9	db !64x64
	.BBA	db !64x64
	.BBB	db !64x64
	.BBC	db !64x64
	.BBD	db !64x64
	.BBE	db !64x64
	.BBF	db !64x64

	.BC0	db !64x64
	.BC1	db !64x64
	.BC2	db !64x64
	.BC3	db !64x64
	.BC4	db !64x64
	.BC5	db !64x64
	.BC6	db !64x64
	.BC7	db !64x64
	.BC8	db !64x64
	.BC9	db !64x64
	.BCA	db !64x64
	.BCB	db !64x64
	.BCC	db !64x64
	.BCD	db !64x64
	.BCE	db !64x64
	.BCF	db !64x64

	.BD0	db !64x64
	.BD1	db !64x64
	.BD2	db !64x64
	.BD3	db !64x64
	.BD4	db !64x64
	.BD5	db !64x64
	.BD6	db !64x64
	.BD7	db !64x64
	.BD8	db !64x64
	.BD9	db !64x64
	.BDA	db !64x64
	.BDB	db !64x64
	.BDC	db !64x64
	.BDD	db !64x64
	.BDE	db !64x64
	.BDF	db !64x64

	.BE0	db !64x64
	.BE1	db !64x64
	.BE2	db !64x64
	.BE3	db !64x64
	.BE4	db !64x64
	.BE5	db !64x64
	.BE6	db !64x64
	.BE7	db !64x64

	; overworld files
	.BE8	db !32x32
	.BE9	db !32x32
	.BEA	db !32x32
	.BEB	db !32x32
	.BEC	db !32x32
	.BED	db !32x32
	.BEE	db !32x32
	.BEF	db !32x32
	.BF0	db !32x32
	.BF1	db !32x32
	.BF2	db !32x32
	.BF3	db !32x32
	.BF4	db !32x32
	.BF5	db !32x32
	.BF6	db !32x32
	.BF7	db !32x32
	.BF8	db !32x32
	.BF9	db !32x32
	.BFA	db !32x32
	.BFB	db !32x32
	.BFC	db !32x32
	.BFD	db !32x32
	.BFE	db !32x32
	.BFF	db !32x32


print "BG3 resolution data registered"








