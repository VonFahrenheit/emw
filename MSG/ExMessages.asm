;=================;
;EXTENDED MESSAGES;
;=================;
; --Manual--
;
; For levels that use ExMessages, start with 16-bit pointers to all the messages.
; Start each ExMessage with its header (4 bytes).
; Each line should be 18 characters long. End message with an 0xFF byte.
;
ExMessage:

.L000	dw ..Mario1			; 03
	dw ..Mario2			; 04
	dw ..Mario3			; 05
	dw ..Mario4			; 06
	dw ..Mario5			; 07
	dw ..Mario6			; 08
	dw ..Mario7			; 09

	dw ..Luigi1			; 0A
	dw ..Luigi2			; 0B
	dw ..Luigi3			; 0C
	dw ..Luigi4			; 0D
	dw ..Luigi5			; 0E
	dw ..Luigi6			; 0F
	dw ..Luigi7			; 10

	dw ..SenkuControl		; 11
	dw ..AirSenku			; 12
	dw ..SenkuSmash			; 13
	dw ..ShellSpin			; 14
	dw ..LandSlide			; 15
	dw ..ShellDrill			; 16
	dw ..SturdyShell		; 17

	dw ..ComboSlash			; 18
	dw ..AirDash			; 19
	dw ..AirDashPlus		; 1A
	dw ..ComboAirSlash		; 1B
	dw ..HeroicCape			; 1C
	dw ..DinoGrip			; 1D
	dw ..StarStrike			; 1E


	..Mario1
	..Mario2
	..Mario3
	..Mario4
	..Mario5
	..Mario6
	..Mario7
	..Luigi1
	..Luigi2
	..Luigi3
	..Luigi4
	..Luigi5
	..Luigi6
	..Luigi7
	db $07,$00,$00,$40
	db "UNUSED MESSAGE",$FF



	..SenkuControl
	db $07,$00,$00,$40
	db "This will let you "
	db "use your senku in "
	db "more directions!",$FF

	..AirSenku
	db $07,$00,$00,$40
	db "With this upgrade "
	db "you can use your  "
	db "senku in midair to"
	db "reach new places!",$FF

	..SenkuSmash
	db $07,$00,$00,$40
	db "Unleash a powerful"
	db "blow by pushing Y "
	db "when using your   "
	db "senku to pass by  "
	db "an enemy! This    "
	db "attack will also  "
	db "bounce you high in"
	db "the air!",$FF

	..ShellSpin
	db $07,$00,$00,$40
	db "Push Y while      "
	db "crouching to      "
	db "perform an        "
	db "invincible spin   "
	db "attack!",$FF

	..LandSlide
	db $07,$00,$00,$40
	db "This is my        "
	db "favorite! It will "
	db "let you slide in  "
	db "your shell by     "
	db "crouching while   "
	db "you have a lot of "
	db "speed!",$FF

	..ShellDrill
	db $07,$00,$00,$40
	db "Ever wanted to    "
	db "break a brick from"
	db "above? Push down  "
	db "and Y in midair to"
	db "perform a shell   "
	db "drill! This move  "
	db "can also be used  "
	db "as an attack!",$FF

	..SturdyShell
	db $07,$00,$00,$40
	db "Simple but        "
	db "effective! This   "
	db "upgrade to your   "
	db "shell will let you"
	db "tank an extra hit!",$FF


	..ComboSlash
	db $07,$00,$00,$40
	db "This technique    "
	db "lets you combo a  "
	db "ground attack into"
	db "a dash slash!",$FF

	..AirDash
	db $07,$00,$00,$40
	db "With this upgrade "
	db "you can dash in   "
	db "midair once per   "
	db "jump! Be careful, "
	db "you can't dash out"
	db "of a dash jump!",$FF

	..AirDashPlus
	db $07,$00,$00,$40
	db "Tired of          "
	db "limitations, huh? "
	db "Me too! Grab this "
	db "upgrade and you'll"
	db "be able to use    "
	db "your air dash even"
	db "out of a dash     "
	db "jump!",$FF

	..ComboAirSlash
	db $07,$00,$00,$40
	db "This advanced     "
	db "technique can be  "
	db "used to combo an  "
	db "air attack into a "
	db "flying dash slash!"
	db "Be careful with   "
	db "all that speed    "
	db "though!",$FF

	..HeroicCape
	db $07,$00,$00,$40
	db "This simple little"
	db "improvement to    "
	db "your cape will let"
	db "you slow your     "
	db "descent by holding"
	db "B.",$FF

	..DinoGrip
	db $07,$00,$00,$40
	db "With a little bit "
	db "of extra grip your"
	db "claws can be used "
	db "to scale walls and"
	db "even climb        "
	db "ceilings! Just    "
	db "imagine the places"
	db "you can explore!",$FF

	..StarStrike
	db $07,$00,$00,$40
	db "I have an idea for"
	db "an ultimate       "
	db "technique for     "
	db "you... but it     "
	db "seems you'll need "
	db "a stronger sword  "
	db "to learn it.",$FF


.L001
.L002

; Rex:
; Have I seen you before?
; I can't remember,
; non-Rex all look the same to me!
; Anyways, you shouldn't be here.
; The area above the ground is
; for Rex only!


.L003	dw ..CaptainWarriorIntroA	; 03
	dw ..CaptainWarriorIntroB	; 04
	dw ..CaptainWarriorIntroC	; 05
	dw ..CaptainWarriorDefeated	; 06
	dw ..CaptainWarriorLeewayA	; 07
	dw ..CaptainWarriorLeewayB	; 08
	dw ..CaptainWarriorLeewayC	; 09
	dw ..CaptainWarriorLeewayD	; 0A
	dw ..CaptainWarriorLeewayE	; 0B

	..CaptainWarriorIntroA
	db $0A,$04,$00,$03
	db "Halt! On order of",$F3
	db "our great King,",$F3,"  "
	db "civilians may not",$F3
	db "pass here.",$F6,$04,$F3,"     "
	db "Wait a minute!",$F7,$20,$F3," "
	db "You're not even",$F3,"  "
	db "Rex!",$FF

	..CaptainWarriorIntroB
	db $0A,$05,$00,$03
	db "Yet you",$F0,$08,"DARE",$F3,"    "
	db "COME HERE!!",$F0,$03,$F7,$20,$F3,"  "
	db "In the name of",$F3,"   "
	db "the great King of",$F3
	db "the Rex, I,",$F3,"      "
	db "Captain Warrior,",$F3," "
	db "sentence you",$F3,"     "
	db "to die!",$FF

	..CaptainWarriorIntroC
	db $0A,$00,$00,$03
	db "All troops,",$F7,$10,$F3,"    "
	db "attack!",$FF

	..CaptainWarriorDefeated
	db $0A,$00,$00,$08
	db "Huff..",$F7,$20,"Huff..",$F7,$20,$F0,$03
	db "I can't believe",$F3,"  "
	db "how strong you",$F3,"   "
	db "are...",$F6,$04,"          "
	db "All troops",$F3,"       "
	db "withdraw at once.",$F3
	db "We must warn",$F3,"     "
	db "the King.",$FF

	..CaptainWarriorLeewayA
	db $0A,$08,$00,$03
	db "Halt!",$F3,"            "
	db "Wait... Leeway?",$FF

	..CaptainWarriorLeewayB
	db $44,$09,$00,$03
	db "Oh yes!",$F3,"          "
	db "I have returned",$F3,"  "
	db "Captain.",$FF

	..CaptainWarriorLeewayC
	db $0A,$0A,$00,$03
	db "I don't see",$F3,"      "
	db "Rexcalibur on",$F3,"    "
	db "you...",$F3,"           "
	db "Have you returned",$F3
	db "merely to report",$F3," "
	db "your failure?",$FF

	..CaptainWarriorLeewayD
	db $44,$0B,$00,$03
	db "I bring not the",$F3,"  "
	db "Dragon King's",$F3,"    "
	db "sword, nor do I",$F3,"  "
	db "come in defeat.",$F6,$04," "
	db "I am here...",$F0,$06,$F3,"   "
	db "to relieve the",$F3,"   "
	db "King of his crown.",$FF

	..CaptainWarriorLeewayE
	db $0A,$05,$00,$08
	db "LEEWAY YOU",$F3,"       "
	db "DAMNABLE TRAITOR!",$FF


.L004
.L005	dw ..RexWarning1A
	dw ..RexWarning1B
	dw ..RexWarning2
	dw ..RexWarning3A
	dw ..RexWarning3B
	dw ..CaptainWarriorWarningA
	dw ..CaptainWarriorWarningB

	..RexWarning1A
	db $09,$04,$00,$02
	db "I saw you fight",$F3,"  "
	db "Captain Warrior",$F3,"  "
	db "so I know how",$F3,"    "
	db "strong you are.",$F7,$18,$F3
	db "But the King is",$F3,"  "
	db "the strongest",$F3,"    "
	db "there is! You",$F3,"    "
	db "can't beat him!",$FF
	..RexWarning1B
	db $09,$00,$00,$02
	db "Well... maybe the",$F3
	db "Dark Lord is",$F3,"     "
	db "stronger, but he's"
	db "our ally now.",$FF

	..RexWarning2
	db $49,$00,$00,$02
	db "The strongest Rex",$F3
	db "has always been",$F3,"  "
	db "our leader, but",$F3,"  "
	db "since the pact",$F3,"   "
	db "with the Dark",$F3,"    "
	db "Lord, the King has"
	db "been stronger than"
	db "ever before!",$FF

	..RexWarning3A
	db $49,$07,$00,$02
	db "Captain Warrior",$F3,"  "
	db "told me I can't",$F3,"  "
	db "beat you, so I",$F3,"   "
	db "won't fight.",$FF
	..RexWarning3B
	db $49,$00,$00,$02
	db "Still, I'm not",$F3,"   "
	db "worried, because",$F3," "
	db "the King will do",$F3," "
	db "what I can not!",$F6,$04,$F3
	db "That's what he",$F3,"   "
	db "always does, and",$F3," "
	db "it's why we rule",$F3," "
	db "this Island today.",$FF

	..CaptainWarriorWarningA
	db $0A,$09,$00,$03
	db "There you are.",$F6,$01,$F3," "
	db "The King is on",$F3,"   "
	db "the other side",$F3,"   "
	db "of this door.",$F6,$04,$F3,"  "
	db "No, I won't try",$F3,"  "
	db "to stop you. I",$F3,"   "
	db "already know how",$F3," "
	db "that would go.",$FF
	..CaptainWarriorWarningB
	db $0A,$00,$00,$03
	db "I have faith in",$F3,"  "
	db "my King.",$F3,"         "
	db "He is far beyond",$F3," "
	db "even you.",$F6,$04,$F3,"      "
	db "So go, go and meet"
	db "your end at the",$F3,"  "
	db "hand of the",$F3,"      "
	db "Dragon King!",$FF

.L006
.L007	dw ..MountainKing1
	dw ..MountainKing2
	dw ..MountainKing3
	dw ..MountainKing4
	dw ..MountainKing5
	dw ..MountainKing6

	..MountainKing1
	db $00,$00,$00,$04
	db "YOU SEE, MY BELLY",$F3
	db "HAS BEEN INFESTED",$F3
	db "BY TINY FIENDS.",$F6,$03," "
	db "ENTER MY SWEET BOD"
	db "THROUGH THE CROWN",$F3
	db "ON MY HEAD.",$FA,$04,$FF

	..MountainKing2
	db $00,$00,$00,$04
	db "THEN DESTROY ALL",$F3," "
	db "THE FIENDS WITHOUT"
	db "MERCY.",$F6,$03,"          "
	db "THAT WOULD MAKE",$F3,"  "
	db "YOU THE WORTHIEST",$F3
	db "OF MY TREASURE.",$FF

	..MountainKing3
	db $00,$00,$00,$04
	db "ADVENTURER, HAVE",$F3," "
	db "YOU COME TO PROVE",$F3
	db "YOURSELF WORTHY OF"
	db "MY TREASURE?",$F7,$20,$F0,$06,$F3," "
	db "MY STOMACH FEELS",$F3," "
	db "AWFUL... PLEASE...",$FF

	..MountainKing4
	db $00,$00,$00,$04
	db "WELL DONE, HERO!",$F3," "
	db "I COULD NOT HAVE",$F3," "
	db "DONE IT WITHOUT",$F3,"  "
	db "YOU, BECAUSE I AM",$F3
	db "A MOUNTAIN AND CAN"
	db "NOT MOVE.",$FA,$07,$FF

	..MountainKing5
	db $00,$00,$00,$04
	db "IT KIND OF SUCKS,",$F3
	db "REALLY.",$FF

	..MountainKing6
	db $00,$00,$00,$04
	db "MAN, NO ONE",$F3,"      "
	db "APPRECIATES",$F3,"      "
	db "MOUNTAINS THESE",$F3,"  "
	db "DAYS.",$FF


.L008
.L009
.L00A
.L00B
.L00C
.L00D



	.L010



.L00E	dw ..LakituLoversIntro		; 03
	dw ..LakituLoversImpress1	; 04
	dw ..LakituLoversAlmost1	; 05
	dw ..LakituLoversEnrage1	; 06
	dw ..LakituLoversRespect	; 07
	dw ..LakituLoversImpress2	; 08
	dw ..LakituLoversAlmost2	; 09
	dw ..LakituLoversEnrage2	; 0A
	dw ..LakituLoversDeath		; 0B

	..LakituLoversIntro
	db $80,$00,$00,$85
	db "Ho ho ho ho...",$FC,$30,$F9,$00,$FE
	db "Someone made it to the top,",$FE
	db "love. ",$FC,$18,"Only the Dark Lord has",$FE
	db "made it this far before.",$FB,$F8
	db "Oh my! What should we do with",$FE
	db "them, darling?",$FB,$F8
	db "I think you already know,",$FE
	db "love. We shall do the old",$FE
	db "you-know-what!",$FB,$F8
	db "Oh goodness, I thought you'd",$FE
	db "never suggest it!",$FB,$F8,$F7,$80,$F9,$04
	db "LET US DANCE THEM FABULOUSLY",$FE
	db "INTO THE VOID!!",$FB,$FF

	..LakituLoversImpress1
	db $80,$00,$00,$80
	db "Impressive moves!",$FE
	db "But can you keep up with our",$FE
	db "next attack?",$FC,$20,$F8
	db "En garde!"
	db $FC,$40,$FF

	..LakituLoversImpress2
	db $80,$00,$00,$80
	db "Absolutely sublime!",$FE
	db "Let us step up our game,",$FE
	db "darling.",$FC,$20,$F8
	db "Yes, love, let's."
	db $FC,$40,$FF

	..LakituLoversAlmost1
	db $80,$00,$00,$80
	db "Very close!",$FE
	db "That was but a modicum of",$FE
	db "error, within reason for a",$FE
	db "beginner, certainly!"
	db $FC,$40,$FF

	..LakituLoversAlmost2
	db $80,$00,$00,$80
	db "Touche, but not quite there.",$FC,$20,$FE
	db "You'll have to do better",$FE
	db "than that to impress us!"
	db $FC,$40,$FF

	..LakituLoversEnrage1
	db $80,$00,$00,$80
	db "THOSE MOVES ARE FAR TOO",$FE
	db "AMATEURISH!",$FC,$40,$F8
	db "YOU INSULT ALL THINGS THAT",$FE
	db "POSSESS CLASS!"
	db $FC,$40,$FF

	..LakituLoversEnrage2
	db $80,$00,$00,$80
	db "UNACCEPTABLE!!",$FC,$20,$FE
	db "YOU BRING INSULT TO HIGH-",$FE
	db "RANKING INDIVIDUALS SUCH",$FE
	db "AS OURSELVES WITH YOUR LACKING"
	db "STYLE AND ELEGANCE!!"
	db $FC,$60,$FF


	..LakituLoversRespect
	db $80,$00,$00,$40
	db "Such elegance!",$FC,$20,$FE
	db "Such class!",$FB,$F8
	db "We swore allegiance to the",$FE
	db "lord of darkness as we thought"
	db "his dancing to be without",$FE
	db "equal.",$FB,$FE
	db "But you...",$FC,$20,$FE
	db "You outclass even him!",$FE
	db "Your dancing is unrivaled in",$FE
	db "this realm and all others!",$FB,$F8
	db "We simply cannot accept you",$FE
	db "as an enemy any longer.",$FB,$FE
	db "Please, accept our apology and"
	db "eternal allegiance.",$FE
	db "We hereby renounce the Dark",$FE
	db "Lord and profess undying",$FE
	db "loyalty to your cause, hero!"
	db $FB,$FF


	..LakituLoversDeath
	db $80,$00,$00,$80
	db "OH GOODNESS, NO!",$FC,$20,$FE
	db "MY LOVE! ",$FC,$20,"ARE YOU ALL RIGHT!?",$FC,$40,$F9,$02,$F8
	db "We are finished, darling...",$FC,$40,$F9,$04,$F8
	db "I...",$FE
	db "Huff... huff...",$FC,$40,$F8
	db "The void calls us, my love...",$FC,$60,$FF


.L00F
;.L010
.L011
.L012
.L013
.L014
.L015
.L016
.L017
.L018
.L019
.L01A
.L01B
.L01C
.L01D
.L01E
.L01F
.L020
.L021
.L022
.L023
.L024

.L101
.L102
.L103
.L104
.L105
.L106
.L107
.L108
.L109
.L10A
.L10B
.L10C
.L10D
.L10E
.L10F
.L110
.L111
.L112
.L113
.L114
.L115
.L116
.L117
.L118
.L119
.L11A
.L11B
.L11C
.L11D
.L11E
.L11F
.L120
.L121
.L122
.L123
.L124
.L125
.L126
.L127
.L128
.L129
.L12A
.L12B
.L12C
.L12D
.L12E
.L12F
.L130
.L131
.L132
.L133
.L134
.L135
.L136
.L137
.L138
.L139
.L13A
.L13B


;==================;
;HEADERS FOR LEVELS;
;==================;
; --Manual--
;
; Level headers define how many messages are used by each level.
; Or, rather, it defines how many ExMessages each level has.
; ExMessages are inserted manually and not by Lunar Magic.
; Writing 1 or 2 to !MsgTrigger always uses the two messages defined by Lunar Magic.
; Writing 3 will use ExMessage 1 if it exists, otherwise it behaves as usual (first message from next level).
; If a level has, say, 2 ExMessages, and you write 5, then that will work as a 3 for a level without ExMessages.
; It's pretty simple.

.H000	db $1C : .H001	db $00
.H002	db $00 : .H003	db $09
.H004	db $00 : .H005	db $07
.H006	db $00 : .H007	db $06
.H008	db $00 : .H009	db $00
.H00A	db $00 : .H00B	db $00
.H00C	db $00 : .H00D	db $00
.H00E	db $09 : .H00F	db $00
.H010	db $08 : .H011	db $00
.H012	db $00 : .H013	db $00
.H014	db $00 : .H015	db $00
.H016	db $00 : .H017	db $00
.H018	db $00 : .H019	db $00
.H01A	db $00 : .H01B	db $00
.H01C	db $00 : .H01D	db $00
.H01E	db $00 : .H01F	db $00
.H020	db $00 : .H021	db $00
.H022	db $00 : .H023	db $00
.H024	db $00

.H101	db $00 : .H102	db $00
.H103	db $00 : .H104	db $00
.H105	db $00 : .H106	db $00
.H107	db $00 : .H108	db $00
.H109	db $00 : .H10A	db $00
.H10B	db $00 : .H10C	db $00
.H10D	db $00 : .H10E	db $00
.H10F	db $00 : .H110	db $00
.H111	db $00 : .H112	db $00
.H113	db $00 : .H114	db $00
.H115	db $00 : .H116	db $00
.H117	db $00 : .H118	db $00
.H119	db $00 : .H11A	db $00
.H11B	db $00 : .H11C	db $00
.H11D	db $00 : .H11E	db $00
.H11F	db $00 : .H120	db $00
.H121	db $00 : .H122	db $00
.H123	db $00 : .H124	db $00
.H125	db $00 : .H126	db $00
.H127	db $00 : .H128	db $00
.H129	db $00 : .H12A	db $00
.H12B	db $00 : .H12C	db $00
.H12D	db $00 : .H12E	db $00
.H12F	db $00 : .H130	db $00
.H131	db $00 : .H132	db $00
.H133	db $00 : .H134	db $00
.H135	db $00 : .H136	db $00
.H137	db $00 : .H138	db $00
.H139	db $00 : .H13A	db $00
.H13B	db $00


;==========================;
;MAIN POINTER (DON'T TOUCH);
;==========================;
.MainPtr
dw .L000,.L001
dw .L002,.L003
dw .L004,.L005
dw .L006,.L007
dw .L008,.L009
dw .L00A,.L00B
dw .L00C,.L00D
dw .L00E,.L00F
dw .L010,.L011
dw .L012,.L013
dw .L014,.L015
dw .L016,.L017
dw .L018,.L019
dw .L01A,.L01B
dw .L01C,.L01D
dw .L01E,.L01F
dw .L020,.L021
dw .L022,.L023
dw .L024

dw .L101,.L102
dw .L103,.L104
dw .L105,.L106
dw .L107,.L108
dw .L109,.L10A
dw .L10B,.L10C
dw .L10D,.L10E
dw .L10F,.L110
dw .L111,.L112
dw .L113,.L114
dw .L115,.L116
dw .L117,.L118
dw .L119,.L11A
dw .L11B,.L11C
dw .L11D,.L11E
dw .L11F,.L120
dw .L121,.L122
dw .L123,.L124
dw .L125,.L126
dw .L127,.L128
dw .L129,.L12A
dw .L12B,.L12C
dw .L12D,.L12E
dw .L12F,.L130
dw .L131,.L132
dw .L133,.L134
dw .L135,.L136
dw .L137,.L138
dw .L139,.L13A
dw .L13B