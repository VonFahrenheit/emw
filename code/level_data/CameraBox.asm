
macro regbox(ID, bool)
	if <bool> = 0
		dl $000000
	else
		dl level<ID>_RoomPointers
	endif
endmacro


BoxTable:
%regbox(0, 0)
%regbox(1, 0)
%regbox(2, 0)
%regbox(3, 0)
%regbox(4, 0)
%regbox(5, 0)
%regbox(6, 0)
%regbox(7, 0)
%regbox(8, 0)
%regbox(9, 0)
%regbox(A, 0)
%regbox(B, 0)
%regbox(C, 0)
%regbox(D, 0)
%regbox(E, 0)
%regbox(F, 0)
%regbox(10, 0)
%regbox(11, 0)
%regbox(12, 0)
%regbox(13, 0)
%regbox(14, 1)
%regbox(15, 0)
%regbox(16, 0)
%regbox(17, 0)
%regbox(18, 0)
%regbox(19, 0)
%regbox(1A, 0)
%regbox(1B, 0)
%regbox(1C, 0)
%regbox(1D, 0)
%regbox(1E, 0)
%regbox(1F, 0)
%regbox(20, 0)
%regbox(21, 0)
%regbox(22, 0)
%regbox(23, 0)
%regbox(24, 0)
%regbox(25, 0)
%regbox(26, 0)
%regbox(27, 1)
%regbox(28, 0)
%regbox(29, 0)
%regbox(2A, 0)
%regbox(2B, 0)
%regbox(2C, 0)
%regbox(2D, 0)
%regbox(2E, 0)
%regbox(2F, 1)
%regbox(30, 0)
%regbox(31, 0)
%regbox(32, 0)
%regbox(33, 0)
%regbox(34, 1)
%regbox(35, 1)
%regbox(36, 0)
%regbox(37, 0)
%regbox(38, 1)
%regbox(39, 1)
%regbox(3A, 0)
%regbox(3B, 0)
%regbox(3C, 0)
%regbox(3D, 0)
%regbox(3E, 0)
%regbox(3F, 0)
%regbox(40, 0)
%regbox(41, 0)
%regbox(42, 0)
%regbox(43, 0)
%regbox(44, 0)
%regbox(45, 0)
%regbox(46, 0)
%regbox(47, 0)
%regbox(48, 0)
%regbox(49, 0)
%regbox(4A, 0)
%regbox(4B, 0)
%regbox(4C, 0)
%regbox(4D, 0)
%regbox(4E, 0)
%regbox(4F, 0)
%regbox(50, 0)
%regbox(51, 0)
%regbox(52, 0)
%regbox(53, 0)
%regbox(54, 0)
%regbox(55, 0)
%regbox(56, 0)
%regbox(57, 0)
%regbox(58, 0)
%regbox(59, 0)
%regbox(5A, 0)
%regbox(5B, 0)
%regbox(5C, 0)
%regbox(5D, 0)
%regbox(5E, 0)
%regbox(5F, 0)
%regbox(60, 0)
%regbox(61, 0)
%regbox(62, 0)
%regbox(63, 0)
%regbox(64, 0)
%regbox(65, 0)
%regbox(66, 0)
%regbox(67, 0)
%regbox(68, 0)
%regbox(69, 0)
%regbox(6A, 0)
%regbox(6B, 0)
%regbox(6C, 0)
%regbox(6D, 0)
%regbox(6E, 0)
%regbox(6F, 0)
%regbox(70, 0)
%regbox(71, 0)
%regbox(72, 0)
%regbox(73, 0)
%regbox(74, 0)
%regbox(75, 0)
%regbox(76, 0)
%regbox(77, 0)
%regbox(78, 0)
%regbox(79, 0)
%regbox(7A, 0)
%regbox(7B, 0)
%regbox(7C, 0)
%regbox(7D, 0)
%regbox(7E, 0)
%regbox(7F, 0)
%regbox(80, 0)
%regbox(81, 0)
%regbox(82, 0)
%regbox(83, 0)
%regbox(84, 0)
%regbox(85, 0)
%regbox(86, 0)
%regbox(87, 0)
%regbox(88, 0)
%regbox(89, 0)
%regbox(8A, 0)
%regbox(8B, 0)
%regbox(8C, 0)
%regbox(8D, 0)
%regbox(8E, 0)
%regbox(8F, 0)
%regbox(90, 0)
%regbox(91, 0)
%regbox(92, 0)
%regbox(93, 0)
%regbox(94, 0)
%regbox(95, 0)
%regbox(96, 0)
%regbox(97, 0)
%regbox(98, 0)
%regbox(99, 0)
%regbox(9A, 0)
%regbox(9B, 0)
%regbox(9C, 0)
%regbox(9D, 0)
%regbox(9E, 0)
%regbox(9F, 0)
%regbox(A0, 0)
%regbox(A1, 0)
%regbox(A2, 0)
%regbox(A3, 0)
%regbox(A4, 0)
%regbox(A5, 0)
%regbox(A6, 0)
%regbox(A7, 0)
%regbox(A8, 0)
%regbox(A9, 0)
%regbox(AA, 0)
%regbox(AB, 0)
%regbox(AC, 0)
%regbox(AD, 0)
%regbox(AE, 0)
%regbox(AF, 0)
%regbox(B0, 0)
%regbox(B1, 0)
%regbox(B2, 0)
%regbox(B3, 0)
%regbox(B4, 0)
%regbox(B5, 0)
%regbox(B6, 0)
%regbox(B7, 0)
%regbox(B8, 0)
%regbox(B9, 0)
%regbox(BA, 0)
%regbox(BB, 0)
%regbox(BC, 0)
%regbox(BD, 0)
%regbox(BE, 0)
%regbox(BF, 0)
%regbox(C0, 0)
%regbox(C1, 0)
%regbox(C2, 0)
%regbox(C3, 0)
%regbox(C4, 0)
%regbox(C5, 0)
%regbox(C6, 0)
%regbox(C7, 0)
%regbox(C8, 0)
%regbox(C9, 0)
%regbox(CA, 0)
%regbox(CB, 0)
%regbox(CC, 0)
%regbox(CD, 0)
%regbox(CE, 0)
%regbox(CF, 0)
%regbox(D0, 0)
%regbox(D1, 0)
%regbox(D2, 0)
%regbox(D3, 0)
%regbox(D4, 0)
%regbox(D5, 0)
%regbox(D6, 0)
%regbox(D7, 0)
%regbox(D8, 0)
%regbox(D9, 0)
%regbox(DA, 0)
%regbox(DB, 0)
%regbox(DC, 0)
%regbox(DD, 0)
%regbox(DE, 0)
%regbox(DF, 0)
%regbox(E0, 0)
%regbox(E1, 0)
%regbox(E2, 0)
%regbox(E3, 0)
%regbox(E4, 0)
%regbox(E5, 0)
%regbox(E6, 0)
%regbox(E7, 0)
%regbox(E8, 0)
%regbox(E9, 0)
%regbox(EA, 0)
%regbox(EB, 0)
%regbox(EC, 0)
%regbox(ED, 0)
%regbox(EE, 0)
%regbox(EF, 0)
%regbox(F0, 0)
%regbox(F1, 0)
%regbox(F2, 0)
%regbox(F3, 0)
%regbox(F4, 0)
%regbox(F5, 0)
%regbox(F6, 0)
%regbox(F7, 0)
%regbox(F8, 0)
%regbox(F9, 0)
%regbox(FA, 0)
%regbox(FB, 0)
%regbox(FC, 0)
%regbox(FD, 0)
%regbox(FE, 0)
%regbox(FF, 0)
%regbox(100, 0)
%regbox(101, 0)
%regbox(102, 0)
%regbox(103, 0)
%regbox(104, 0)
%regbox(105, 0)
%regbox(106, 0)
%regbox(107, 0)
%regbox(108, 0)
%regbox(109, 0)
%regbox(10A, 0)
%regbox(10B, 0)
%regbox(10C, 0)
%regbox(10D, 0)
%regbox(10E, 0)
%regbox(10F, 0)
%regbox(110, 0)
%regbox(111, 0)
%regbox(112, 0)
%regbox(113, 0)
%regbox(114, 0)
%regbox(115, 0)
%regbox(116, 0)
%regbox(117, 0)
%regbox(118, 0)
%regbox(119, 0)
%regbox(11A, 0)
%regbox(11B, 0)
%regbox(11C, 0)
%regbox(11D, 0)
%regbox(11E, 0)
%regbox(11F, 0)
%regbox(120, 0)
%regbox(121, 0)
%regbox(122, 0)
%regbox(123, 0)
%regbox(124, 0)
%regbox(125, 0)
%regbox(126, 0)
%regbox(127, 0)
%regbox(128, 0)
%regbox(129, 0)
%regbox(12A, 0)
%regbox(12B, 0)
%regbox(12C, 0)
%regbox(12D, 0)
%regbox(12E, 0)
%regbox(12F, 0)
%regbox(130, 0)
%regbox(131, 0)
%regbox(132, 0)
%regbox(133, 0)
%regbox(134, 0)
%regbox(135, 0)
%regbox(136, 0)
%regbox(137, 0)
%regbox(138, 0)
%regbox(139, 0)
%regbox(13A, 0)
%regbox(13B, 1)
%regbox(13C, 0)
%regbox(13D, 0)
%regbox(13E, 0)
%regbox(13F, 0)
%regbox(140, 0)
%regbox(141, 0)
%regbox(142, 0)
%regbox(143, 0)
%regbox(144, 0)
%regbox(145, 0)
%regbox(146, 0)
%regbox(147, 0)
%regbox(148, 0)
%regbox(149, 0)
%regbox(14A, 0)
%regbox(14B, 0)
%regbox(14C, 0)
%regbox(14D, 0)
%regbox(14E, 0)
%regbox(14F, 0)
%regbox(150, 0)
%regbox(151, 0)
%regbox(152, 0)
%regbox(153, 0)
%regbox(154, 0)
%regbox(155, 0)
%regbox(156, 0)
%regbox(157, 0)
%regbox(158, 0)
%regbox(159, 0)
%regbox(15A, 0)
%regbox(15B, 0)
%regbox(15C, 0)
%regbox(15D, 0)
%regbox(15E, 0)
%regbox(15F, 0)
%regbox(160, 0)
%regbox(161, 0)
%regbox(162, 0)
%regbox(163, 0)
%regbox(164, 0)
%regbox(165, 0)
%regbox(166, 0)
%regbox(167, 0)
%regbox(168, 0)
%regbox(169, 0)
%regbox(16A, 0)
%regbox(16B, 0)
%regbox(16C, 0)
%regbox(16D, 0)
%regbox(16E, 0)
%regbox(16F, 0)
%regbox(170, 0)
%regbox(171, 0)
%regbox(172, 0)
%regbox(173, 0)
%regbox(174, 0)
%regbox(175, 0)
%regbox(176, 0)
%regbox(177, 0)
%regbox(178, 0)
%regbox(179, 0)
%regbox(17A, 0)
%regbox(17B, 0)
%regbox(17C, 0)
%regbox(17D, 0)
%regbox(17E, 0)
%regbox(17F, 0)
%regbox(180, 0)
%regbox(181, 0)
%regbox(182, 0)
%regbox(183, 0)
%regbox(184, 0)
%regbox(185, 0)
%regbox(186, 0)
%regbox(187, 0)
%regbox(188, 0)
%regbox(189, 0)
%regbox(18A, 0)
%regbox(18B, 0)
%regbox(18C, 0)
%regbox(18D, 0)
%regbox(18E, 0)
%regbox(18F, 0)
%regbox(190, 0)
%regbox(191, 0)
%regbox(192, 0)
%regbox(193, 0)
%regbox(194, 0)
%regbox(195, 0)
%regbox(196, 0)
%regbox(197, 0)
%regbox(198, 0)
%regbox(199, 0)
%regbox(19A, 0)
%regbox(19B, 0)
%regbox(19C, 0)
%regbox(19D, 0)
%regbox(19E, 0)
%regbox(19F, 0)
%regbox(1A0, 0)
%regbox(1A1, 0)
%regbox(1A2, 0)
%regbox(1A3, 0)
%regbox(1A4, 0)
%regbox(1A5, 0)
%regbox(1A6, 0)
%regbox(1A7, 0)
%regbox(1A8, 0)
%regbox(1A9, 0)
%regbox(1AA, 0)
%regbox(1AB, 0)
%regbox(1AC, 0)
%regbox(1AD, 0)
%regbox(1AE, 0)
%regbox(1AF, 0)
%regbox(1B0, 0)
%regbox(1B1, 0)
%regbox(1B2, 0)
%regbox(1B3, 0)
%regbox(1B4, 0)
%regbox(1B5, 0)
%regbox(1B6, 0)
%regbox(1B7, 0)
%regbox(1B8, 0)
%regbox(1B9, 0)
%regbox(1BA, 0)
%regbox(1BB, 0)
%regbox(1BC, 0)
%regbox(1BD, 0)
%regbox(1BE, 0)
%regbox(1BF, 0)
%regbox(1C0, 0)
%regbox(1C1, 0)
%regbox(1C2, 0)
%regbox(1C3, 0)
%regbox(1C4, 0)
%regbox(1C5, 0)
%regbox(1C6, 0)
%regbox(1C7, 0)
%regbox(1C8, 0)
%regbox(1C9, 0)
%regbox(1CA, 0)
%regbox(1CB, 0)
%regbox(1CC, 0)
%regbox(1CD, 0)
%regbox(1CE, 0)
%regbox(1CF, 0)
%regbox(1D0, 0)
%regbox(1D1, 0)
%regbox(1D2, 0)
%regbox(1D3, 0)
%regbox(1D4, 0)
%regbox(1D5, 0)
%regbox(1D6, 0)
%regbox(1D7, 0)
%regbox(1D8, 0)
%regbox(1D9, 0)
%regbox(1DA, 0)
%regbox(1DB, 0)
%regbox(1DC, 0)
%regbox(1DD, 0)
%regbox(1DE, 0)
%regbox(1DF, 0)
%regbox(1E0, 0)
%regbox(1E1, 0)
%regbox(1E2, 0)
%regbox(1E3, 0)
%regbox(1E4, 0)
%regbox(1E5, 0)
%regbox(1E6, 0)
%regbox(1E7, 0)
%regbox(1E8, 0)
%regbox(1E9, 0)
%regbox(1EA, 0)
%regbox(1EB, 0)
%regbox(1EC, 0)
%regbox(1ED, 0)
%regbox(1EE, 0)
%regbox(1EF, 0)
%regbox(1F0, 0)
%regbox(1F1, 1)
%regbox(1F2, 0)
%regbox(1F3, 0)
%regbox(1F4, 0)
%regbox(1F5, 0)
%regbox(1F6, 0)
%regbox(1F7, 1)
%regbox(1F8, 0)
%regbox(1F9, 0)
%regbox(1FA, 0)
%regbox(1FB, 0)
%regbox(1FC, 0)
%regbox(1FD, 0)
%regbox(1FE, 0)
%regbox(1FF, 0)


