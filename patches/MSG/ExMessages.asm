;=================;
;EXTENDED MESSAGES;
;=================;
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
;
; speeds:
; 0 - 1 row per frame
; 1 - 1 word per frame
; 2 - 7 characters per frame
; 3 - 6 characters per frame
; 4 - 5 characters per frame
; 5 - 4 characters per frame
; 6 - 3 characters per frame
; 7 - 2 characters per frame
; 8 - 1 character per frame
; 9 - 1 character every 2 frames
; A - 1 character every 3 frames
; B - 1 character every 4 frames
; C - 1 character every 5 frames
; D - 1 character every 6 frames
; E - 1 character every 7 frames
; F - 1 character every 8 frames
; 10+ - invalid, do not use
;
;
; NOTE!! If you are using a dialogue pointer, the message must end with $E8,$FF rather than just $FF!
;
ExMessage:

.L000	dw ..Survivor1			; 01
	dw ..Tinker1			; 02

	dw ..Mario1			; 03
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

	dw ..Alter1			; 1F
	dw ..Alter2			; 20
	dw ..Alter3			; 21
	dw ..Alter4			; 22
	dw ..Alter5			; 23
	dw ..Alter6			; 24
	dw ..Alter7			; 25

	dw ..Peach1			; 26
	dw ..Peach2			; 27
	dw ..Peach3			; 28
	dw ..Peach4			; 29
	dw ..Peach5			; 2A
	dw ..Peach6			; 2B
	dw ..Peach7			; 2C

	..Survivor1
	db $06,$00,$00,$47
	db "You have returned,",$FE
	db "hero! Feel free to",$FE
	db "stay as long as",$FE
	db "you like!",$FF

	..Tinker1
	db $07,$00,$03,$04,$00,$48
	db "Hoooi fam, how",$FE
	db "about you cough up",$FE
	db "some of those",$D1,$EF,$FE
	db "YOSHI COINS?",$D0,$E0,$FE
	db "   option 1",$FE
	db "   option 2",$FE
	db "   option 3",$E8,$FF

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
	..Alter1
	..Alter2
	..Alter3
	..Alter4
	..Alter5
	..Alter6
	..Alter7
	..Peach1
	..Peach2
	..Peach3
	..Peach4
	..Peach5
	..Peach6
	..Peach7
	db $00,$00,$00,$40
	db "UNUSED MESSAGE",$FF



	..SenkuControl
	db $00,$00,$00,$40
	db "This will let you "
	db "use your senku in "
	db "more directions!",$FF

	..AirSenku
	db $00,$00,$00,$40
	db "With this upgrade "
	db "you can use your  "
	db "senku in midair to"
	db "reach new places!",$FF

	..SenkuSmash
	db $00,$00,$00,$40
	db "Unleash a powerful"
	db "blow by pushing Y "
	db "when using your   "
	db "senku to pass by  "
	db "an enemy! This    "
	db "attack will also  "
	db "bounce you high in"
	db "the air!",$FF

	..ShellSpin
	db $00,$00,$00,$40
	db "Push Y while      "
	db "crouching to      "
	db "perform an        "
	db "invincible spin   "
	db "attack!",$FF

	..LandSlide
	db $00,$00,$00,$40
	db "This is my        "
	db "favorite! It will "
	db "let you slide in  "
	db "your shell by     "
	db "crouching while   "
	db "you have a lot of "
	db "speed!",$FF

	..ShellDrill
	db $00,$00,$00,$40
	db "Ever wanted to    "
	db "break a brick from"
	db "above? Push down  "
	db "and Y in midair to"
	db "perform a shell   "
	db "drill! This move  "
	db "can also be used  "
	db "as an attack!",$FF

	..SturdyShell
	db $00,$00,$00,$40
	db "Simple but        "
	db "effective! This   "
	db "upgrade to your   "
	db "shell will let you"
	db "tank an extra hit!",$FF


	..ComboSlash
	db $00,$00,$00,$40
	db "This technique    "
	db "lets you combo a  "
	db "ground attack into"
	db "a dash slash!",$FF

	..AirDash
	db $00,$00,$00,$40
	db "With this upgrade "
	db "you can dash in   "
	db "midair once per   "
	db "jump! Be careful, "
	db "you can't dash out"
	db "of a dash jump!",$FF

	..AirDashPlus
	db $00,$00,$00,$40
	db "Tired of          "
	db "limitations, huh? "
	db "Me too! Grab this "
	db "upgrade and you'll"
	db "be able to use    "
	db "your air dash even"
	db "out of a dash     "
	db "jump!",$FF

	..ComboAirSlash
	db $00,$00,$00,$40
	db "This advanced     "
	db "technique can be  "
	db "used to combo an  "
	db "air attack into a "
	db "flying dash slash!"
	db "Be careful with   "
	db "all that speed    "
	db "though!",$FF

	..HeroicCape
	db $00,$00,$00,$40
	db "This simple little"
	db "improvement to    "
	db "your cape will let"
	db "you slow your     "
	db "descent by holding"
	db "B.",$FF

	..DinoGrip
	db $00,$00,$00,$40
	db "With a little bit "
	db "of extra grip your"
	db "claws can be used "
	db "to scale walls and"
	db "even climb        "
	db "ceilings! Just    "
	db "imagine the places"
	db "you can explore!",$FF

	..StarStrike
	db $00,$00,$00,$40
	db "I have an idea for"
	db "an ultimate       "
	db "technique for     "
	db "you... but it     "
	db "seems you'll need "
	db "a stronger sword  "
	db "to learn it.",$FF


.L001	dw ..Sign1			; 01


	..Sign1
	db $00,$00,$00,$00
	db "This monument marks the highest point on Rex Island."
	db $FF

.L002	dw ..Sign1			; 01
	dw ..Sign2			; 02
	dw ..Rex1			; 03

	..Sign1
	db $00,$00,$00,$00
	db "REX VILLAGE",$FF

	..Sign2
	db $00,$00,$00,$00
	db "UNUSED MESSAGE",$FF

	..Rex1
	db $09,$00,$00,$08
	db "Have I seen you before?"
	db "I can't remember, non-Rex all look the same to me!"
	db "Anyways, you shouldn't be here."
	db "The area above ground is for Rex only!"
	db $FF



.L003	dw ..Sign1			; 01
	dw ..Sign2			; 02
	dw ..CaptainWarriorIntroA	; 03
	dw ..CaptainWarriorIntroB	; 04
	dw ..CaptainWarriorIntroC	; 05
	dw ..CaptainWarriorDefeated	; 06
	dw ..CaptainWarriorLeewayA	; 07
	dw ..CaptainWarriorLeewayB	; 08
	dw ..CaptainWarriorLeewayC	; 09
	dw ..CaptainWarriorLeewayD	; 0A
	dw ..CaptainWarriorLeewayE	; 0B


	..Sign1
	db $00,$00,$00,$00
	db "Ahead lie the domains of Captain Warrior, Champion of all Rex.",$FE
	db "Non-Rex are NOT welcome.",$FF

	..Sign2
	db $00,$00,$00,$00
	db "UNUSED MESSAGE",$FF

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
.L005	dw ..Sign1			; 01
	dw ..Sign2			; 02
	dw ..RexWarning1A		; 03
	dw ..RexWarning1B		; 04
	dw ..RexWarning2		; 05
	dw ..RexWarning3A		; 06
	dw ..RexWarning3B		; 07
	dw ..CaptainWarriorWarningA	; 08
	dw ..CaptainWarriorWarningB	; 09

	..Sign1
	db $00,$00,$00,$00
	db "Ahead lies Castle Rex, seat of our power and home to the Great Kingking, Lord of This Island and King of the Rex.",$FF

	..Sign2
	db $00,$00,$00,$00
	db "Throne room under renovation.",$FE
	db "Visitors may seek the King at the top of the Grand Tower.",$FF

	..RexWarning1A
	db $09,$04,$00,$02
	db "I saw you fight",$FE
	db "Captain Warrior",$FE
	db "so I know how",$FE
	db "strong you are.",$F7,$18,$FE
	db "But the King is",$FE
	db "the strongest",$FE
	db "there is! You",$FE
	db "can't beat him!",$FF
	..RexWarning1B
	db $09,$00,$00,$02
	db "Well... maybe the",$FE
	db "Dark Lord is",$FE
	db "stronger, but he's",$FE
	db "our ally now.",$FF

	..RexWarning2
	db $49,$00,$00,$02
	db "The strongest Rex",$FE
	db "has always been",$FE
	db "our leader, but",$FE
	db "since the pact",$FE
	db "with the Dark",$FE
	db "Lord, the King has",$FE
	db "been stronger than",$FE
	db "ever before!",$FF

	..RexWarning3A
	db $49,$07,$00,$02
	db "Captain Warrior",$FE
	db "told me I can't",$FE
	db "beat you, so I",$FE
	db "won't fight.",$FF
	..RexWarning3B
	db $49,$00,$00,$02
	db "Still, I'm not",$FE
	db "worried, because",$FE
	db "the King will do",$FE
	db "what I can not!",$F6,$04,$FE
	db "That's what he",$FE
	db "always does, and",$FE
	db "it's why we rule",$FE
	db "this Island today.",$FF

	..CaptainWarriorWarningA
	db $0A,$09,$00,$03
	db "There you are.",$F6,$01,$FE
	db "The King is on",$FE
	db "the other side",$FE
	db "of this door.",$F6,$04,$FE
	db "No, I won't try",$FE
	db "to stop you. I",$FE
	db "already know how",$FE
	db "that would go.",$FF
	..CaptainWarriorWarningB
	db $0A,$00,$00,$03
	db "I have faith in",$FE
	db "my King.",$FE
	db "He is far beyond",$FE
	db "even you.",$F6,$04,$FE
	db "So go, go and meet",$FE
	db "your end at the",$FE
	db "hand of the",$FE
	db "Dragon King!",$FF

.L006
.L007	dw ..MountainKingA		; 01
	dw ..MountainKingB		; 02
	dw ..MountainKing1		; 03
	dw ..MountainKing2		; 04
	dw ..MountainKing3		; 05
	dw ..MountainKing4		; 06
	dw ..MountainKing5		; 07
	dw ..MountainKing6		; 08

	..MountainKingA
	db $00,$00,$00,$04
	db "WHO DARES STEAL FROM THE MOUNTAIN KING?",$FF

	..MountainKingB
	db $00,$00,$00,$04
	db "PHEW! THAT WAS THE LAST OF THOSE FIENDS!",$FE
	db "YOU MAY EXIT MY GUT BY JUMPING INTO MY NICE PIT OF STOMACH ACID.",$FF

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




.L00E	dw ..Sign1			; 01
	dw ..Sign2			; 02
	dw ..LakituLoversIntro		; 03
	dw ..LakituLoversImpress1	; 04
	dw ..LakituLoversAlmost1	; 05
	dw ..LakituLoversEnrage1	; 06
	dw ..LakituLoversRespect	; 07
	dw ..LakituLoversImpress2	; 08
	dw ..LakituLoversAlmost2	; 09
	dw ..LakituLoversEnrage2	; 0A
	dw ..LakituLoversDeath		; 0B

	..Sign1
	db $00,$00,$00,$00
	db " - DANCE MACHINE -",$FE
	db $FE
	db "   - SAFETY OFF",$FE
	db "   - LEADERBOARD:",$FE
	db "       LAKITA",$FE
	db "       LAKITO",$FE
	db "       DARK LORD",$FF

	..Sign2
	db $00,$00,$00,$00
	db "This is the high level dance practice hall. Only the Lakitu Lords are skilled enough to make it to the top!",$FF

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
.L010
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
.L13B	dw ..EasyMode
	dw ..NormalMode
	dw ..InsaneMode
	dw ..NightmareMode

	dw ..TimeAttackMode
	dw ..RankMode
	dw ..CriticalMode


	dw ..IronmanMode

	..EasyMode
	db "This mode will give you an easier time."
	db "Perfect as a relaxing way to experience the game!"
	db "Enemies lose some abilities."
	db "Enemies tend to be less durable."
	db "Enemies are less aggressive."
	db "Bottomless pits are no longer instant death."
	db "Powerups are more common."

	..NormalMode
	db "This is the standard difficulty setting."
	db "Enemies have all their abilities."
	db "Bottomless pits are instant death."

	..InsaneMode
	db "This is a challenging mode for the toughest players!"
	db "Bosses have new abilities."
	db "Enemies are more durable."
	db "Enemies are more aggressive."
	db "Powerups are less common."

	..NightmareMode
	db "This ultimate challenge might change how the story plays out..."

	..TimeAttackMode
	db "Most levels will have a strict time limit for clearing them."
	db "Your fastest clear time for each level will be saved."

	..RankMode
	db "At the end of each level, you will be given a rank based on how well you did."
	db "You highest rank for each level will be saved."

	..CriticalMode
	db "Enemies will always kill you in one hit."

	..IronmanMode
	db "If one player dies, the other one dies as well."
	db "There's no continuing on your own in this mode!"
	db "(only applies in multiplayer)"




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
