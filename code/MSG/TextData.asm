
;
; known bugs:
;	- using the delay command immediately after the linebreak command causes the text to momentarily glitch up
;		to get around this, just place the delay command before the linebreak command
;		this has the same effect but without the glitch
;




	.DebugMessage
;	%border(0)
	%color(0)
	%speed(10)
	%mode(1)
	%cinematic(2)
	%portrait(1, 1)
	db "Message..."
	%linebreak()
	db "[FILLER TEXT][FILLER TEXT][FILLER TEXT][FILLER TEXT][FILLER TEXT][FILLER TEXT]"
	%linebreak()
	db "[FILLER TEXT]"
	%linebreak()
	db "[FILLER TEXT]"
	%linebreak()
	db "[FILLER TEXT]"
	%linebreak()
	db "Press ",$50,"!"
	%endmessage()



	.Survivor_Talk_1
	%portrait(6, 0)
	%speed(7)
	%mode(1)
	db "You have returned, hero! Feel free to stay as long as you like!"
	%endmessage()

	.Tinker_Talk_1
	%portrait(7, 0)
	%speed(8)
	%mode(1)
	db "Hoooi fam, how about you cough up some of those "
	%talk(1)
	%speed(15)
	db "YOSHI COINS?"
	%talk(0)
	%speed(0)
	%linebreak()
	db "    option 1"
	%linebreak()
	db "    option 2"
	%linebreak()
	db "    option 3"
	%dialogue(3, 0, 3)
	%endmessage()

	.Mario_Upgrade_1
	.Mario_Upgrade_2
	.Mario_Upgrade_3
	.Mario_Upgrade_4
	.Mario_Upgrade_5
	.Mario_Upgrade_6
	.Mario_Upgrade_7
	.Luigi_Upgrade_1
	.Luigi_Upgrade_2
	.Luigi_Upgrade_3
	.Luigi_Upgrade_4
	.Luigi_Upgrade_5
	.Luigi_Upgrade_6
	.Luigi_Upgrade_7
	.Alter_Upgrade_1
	.Alter_Upgrade_2
	.Alter_Upgrade_3
	.Alter_Upgrade_4
	.Alter_Upgrade_5
	.Alter_Upgrade_6
	.Alter_Upgrade_7
	.Peach_Upgrade_1
	.Peach_Upgrade_2
	.Peach_Upgrade_3
	.Peach_Upgrade_4
	.Peach_Upgrade_5
	.Peach_Upgrade_6
	.Peach_Upgrade_7
	db $00,$00,$00,$40
	db "UNUSED MESSAGE",$FF



	.Kadaal_Upgrade_SenkuControl
	db $00,$00,$00,$40
	db "This will let you "
	db "use your senku in "
	db "more directions!",$FF

	.Kadaal_Upgrade_AirSenku
	db $00,$00,$00,$40
	db "With this upgrade "
	db "you can use your  "
	db "senku in midair to"
	db "reach new places!",$FF

	.Kadaal_Upgrade_SenkuSmash
	db $00,$00,$00,$40
	db "Unleash a powerful"
	db "blow by pushing Y "
	db "when using your   "
	db "senku to pass by  "
	db "an enemy! This    "
	db "attack will also  "
	db "bounce you high in"
	db "the air!",$FF

	.Kadaal_Upgrade_ShellSpin
	db $00,$00,$00,$40
	db "Push Y while      "
	db "crouching to      "
	db "perform an        "
	db "invincible spin   "
	db "attack!",$FF

	.Kadaal_Upgrade_LandSlide
	db $00,$00,$00,$40
	db "This is my        "
	db "favorite! It will "
	db "let you slide in  "
	db "your shell by     "
	db "crouching while   "
	db "you have a lot of "
	db "speed!",$FF

	.Kadaal_Upgrade_ShellDrill
	db $00,$00,$00,$40
	db "Ever wanted to    "
	db "break a brick from"
	db "above? Push down  "
	db "and Y in midair to"
	db "perform a shell   "
	db "drill! This move  "
	db "can also be used  "
	db "as an attack!",$FF

	.Kadaal_Upgrade_SturdyShell
	db $00,$00,$00,$40
	db "Simple but        "
	db "effective! This   "
	db "upgrade to your   "
	db "shell will let you"
	db "tank an extra hit!",$FF


	.Leeway_Upgrade_ComboSlash
	db $00,$00,$00,$40
	db "This technique    "
	db "lets you combo a  "
	db "ground attack into"
	db "a dash slash!",$FF

	.Leeway_Upgrade_AirDash
	db $00,$00,$00,$40
	db "With this upgrade "
	db "you can dash in   "
	db "midair once per   "
	db "jump! Be careful, "
	db "you can't dash out"
	db "of a dash jump!",$FF

	.Leeway_Upgrade_AirDashPlus
	db $00,$00,$00,$40
	db "Tired of          "
	db "limitations, huh? "
	db "Me too! Grab this "
	db "upgrade and you'll"
	db "be able to use    "
	db "your air dash even"
	db "out of a dash     "
	db "jump!",$FF

	.Leeway_Upgrade_ComboAirSlash
	db $00,$00,$00,$40
	db "This advanced     "
	db "technique can be  "
	db "used to combo an  "
	db "air attack into a "
	db "flying dash slash!"
	db "Be careful with   "
	db "all that speed    "
	db "though!",$FF

	.Leeway_Upgrade_HeroicCape
	db $00,$00,$00,$40
	db "This simple little"
	db "improvement to    "
	db "your cape will let"
	db "you slow your     "
	db "descent by holding"
	db "B.",$FF

	.Leeway_Upgrade_DinoGrip
	db $00,$00,$00,$40
	db "With a little bit "
	db "of extra grip your"
	db "claws can be used "
	db "to scale walls and"
	db "even climb        "
	db "ceilings! Just    "
	db "imagine the places"
	db "you can explore!",$FF

	.Leeway_Upgrade_StarStrike
	db $00,$00,$00,$40
	db "I have an idea for"
	db "an ultimate       "
	db "technique for     "
	db "you.. but it     "
	db "seems you'll need "
	db "a stronger sword  "
	db "to learn it.",$FF



	.MushroomGorge_Sign_1
	db $00,$00,$00,$00
	db "This monument marks the highest point on Rex Island."
	db $FF




	.RexVillage_Sign_1
	db $00,$00,$00,$00
	db "REX VILLAGE",$FF

	.RexVillage_Sign_2
	db $00,$00,$00,$00
	db "UNUSED MESSAGE",$FF

	.RexVillage_Rex_1
	db $09,$00,$00,$08
	db "Have I seen you before?"
	db "I can't remember, non-Rex all look the same to me!"
	db "Anyways, you shouldn't be here."
	db "The area above ground is for Rex only!"
	db $FF



	.DinolordsDomain_Sign_1
	db $00,$00,$00,$00
	db "Ahead lie the domains of Captain Warrior, Champion of all Rex.",$FE
	db "Non-Rex are NOT welcome.",$FF

	.DinolordsDomain_Sign_2
	db $00,$00,$00,$00
	db "UNUSED MESSAGE",$FF

	.CaptainWarrior_Fight1_Intro_1
	db $0A,$04,$00,$03
	db "Halt! On order of",$F3
	db "our great King,",$F3,"  "
	db "civilians may not",$F3
	db "pass here.",$F6,$04,$F3,"     "
	db "Wait a minute!",$F7,$20,$F3," "
	db "You're not even",$F3,"  "
	db "Rex!",$FF

	db "Yet you",$F0,$08,"DARE",$F3,"    "
	db "COME HERE!!",$F0,$03,$F7,$20,$F3,"  "
	db "In the name of",$F3,"   "
	db "the great King of",$F3
	db "the Rex, I,",$F3,"      "
	db "Captain Warrior,",$F3," "
	db "sentence you",$F3,"     "
	db "to die!",$FF

	.CaptainWarrior_Fight1_Intro_2
	db "All troops,",$F7,$10,$F3,"    "
	db "attack!",$FF

	.CaptainWarrior_Fight1_Defeated
	db $0A,$00,$00,$08
	db "Huff..",$F7,$20,"Huff..",$F7,$20,$F0,$03
	db "I can't believe",$F3,"  "
	db "how strong you",$F3,"   "
	db "are...",$F6,$04,"          "
	db "All troops",$F3,"       "
	db "withdraw at once.",$F3
	db "We must warn",$F3,"     "
	db "the King.",$FF

	.CaptainWarrior_Fight1_Leeway
	db $0A,$08,$00,$03
	db "Halt!",$F3,"            "
	db "Wait... Leeway?",$FF

	db "Oh yes!",$F3,"          "
	db "I have returned",$F3,"  "
	db "Captain.",$FF

	db "I don't see",$F3,"      "
	db "Rexcalibur on",$F3,"    "
	db "you...",$F3,"           "
	db "Have you returned",$F3
	db "merely to report",$F3," "
	db "your failure?",$FF

	db "I bring not the",$F3,"  "
	db "Dragon King's",$F3,"    "
	db "sword, nor do I",$F3,"  "
	db "come in defeat.",$F6,$04," "
	db "I am here...",$F0,$06,$F3,"   "
	db "to relieve the",$F3,"   "
	db "King of his crown.",$FF

	db "LEEWAY YOU",$F3,"       "
	db "DAMNABLE TRAITOR!",$FF


	.CastleRex_Sign_1
	db $00,$00,$00,$00
	db "Ahead lies Castle Rex, seat of our power and home to the Great Kingking, Lord of This Island and King of the Rex.",$FF

	.CastleRex_Sign_2
	db $00,$00,$00,$00
	db "Throne room under renovation.",$FE
	db "Visitors may seek the King at the top of the Grand Tower.",$FF

	.CastleRex_Rex_Warning_1
	db $09,$04,$00,$02
	db "I saw you fight",$FE
	db "Captain Warrior",$FE
	db "so I know how",$FE
	db "strong you are.",$F7,$18,$FE
	db "But the King is",$FE
	db "the strongest",$FE
	db "there is! You",$FE
	db "can't beat him!",$FF

	db "Well... maybe the",$FE
	db "Dark Lord is",$FE
	db "stronger, but he's",$FE
	db "our ally now.",$FF

	.CastleRex_Rex_Warning_2
	db $49,$00,$00,$02
	db "The strongest Rex",$FE
	db "has always been",$FE
	db "our leader, but",$FE
	db "since the pact",$FE
	db "with the Dark",$FE
	db "Lord, the King has",$FE
	db "been stronger than",$FE
	db "ever before!",$FF

	.CastleRex_Rex_Warning_3
	db $49,$07,$00,$02
	db "Captain Warrior",$FE
	db "told me I can't",$FE
	db "beat you, so I",$FE
	db "won't fight.",$FF

	db "Still, I'm not",$FE
	db "worried, because",$FE
	db "the King will do",$FE
	db "what I can not!",$F6,$04,$FE
	db "That's what he",$FE
	db "always does, and",$FE
	db "it's why we rule",$FE
	db "this Island today.",$FF

	.CaptainWarrior_Warning
	db $0A,$09,$00,$03
	db "There you are.",$F6,$01,$FE
	db "The King is on",$FE
	db "the other side",$FE
	db "of this door.",$F6,$04,$FE
	db "No, I won't try",$FE
	db "to stop you. I",$FE
	db "already know how",$FE
	db "that would go.",$FF

	db "I have faith in",$FE
	db "my King.",$FE
	db "He is far beyond",$FE
	db "even you.",$F6,$04,$FE
	db "So go, go and meet",$FE
	db "your end at the",$FE
	db "hand of the",$FE
	db "Dragon King!",$FF

	.MountainKingA
	db $00,$00,$00,$04
	db "WHO DARES STEAL FROM THE MOUNTAIN KING?",$FF

	.MountainKingB
	db $00,$00,$00,$04
	db "PHEW! THAT WAS THE LAST OF THOSE FIENDS!",$FE
	db "YOU MAY EXIT MY GUT BY JUMPING INTO MY NICE PIT OF STOMACH ACID.",$FF

	.MountainKing1
	db $00,$00,$00,$04
	db "YOU SEE, MY BELLY",$F3
	db "HAS BEEN INFESTED",$F3
	db "BY TINY FIENDS.",$F6,$03," "
	db "ENTER MY SWEET BOD"
	db "THROUGH THE CROWN",$F3
	db "ON MY HEAD.",$FA,$04,$FF

	.MountainKing2
	db $00,$00,$00,$04
	db "THEN DESTROY ALL",$F3," "
	db "THE FIENDS WITHOUT"
	db "MERCY.",$F6,$03,"          "
	db "THAT WOULD MAKE",$F3,"  "
	db "YOU THE WORTHIEST",$F3
	db "OF MY TREASURE.",$FF

	.MountainKing3
	db $00,$00,$00,$04
	db "ADVENTURER, HAVE",$F3," "
	db "YOU COME TO PROVE",$F3
	db "YOURSELF WORTHY OF"
	db "MY TREASURE?",$F7,$20,$F0,$06,$F3," "
	db "MY STOMACH FEELS",$F3," "
	db "AWFUL... PLEASE...",$FF

	.MountainKing4
	db $00,$00,$00,$04
	db "WELL DONE, HERO!",$F3," "
	db "I COULD NOT HAVE",$F3," "
	db "DONE IT WITHOUT",$F3,"  "
	db "YOU, BECAUSE I AM",$F3
	db "A MOUNTAIN AND CAN"
	db "NOT MOVE.",$FA,$07,$FF

	.MountainKing5
	db $00,$00,$00,$04
	db "IT KIND OF SUCKS,",$F3
	db "REALLY.",$FF

	.MountainKing6
	db $00,$00,$00,$04
	db "MAN, NO ONE",$F3,"      "
	db "APPRECIATES",$F3,"      "
	db "MOUNTAINS THESE",$F3,"  "
	db "DAYS.",$FF


	.TowerOfStorms_Sign_1
	db $00,$00,$00,$00
	db " - DANCE MACHINE -",$FE
	db $FE
	db "   - SAFETY OFF",$FE
	db "   - LEADERBOARD:",$FE
	db "       LAKITA",$FE
	db "       LAKITO",$FE
	db "       DARK LORD",$FF

	.TowerOfStorms_Sign_2
	db $00,$00,$00,$00
	db "This is the high level dance practice hall. Only the Lakitu Lords are skilled enough to make it to the top!",$FF

	.LakituLovers_Intro
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

	.LakituLovers_Impress_1
	db $80,$00,$00,$80
	db "Impressive moves!",$FE
	db "But can you keep up with our",$FE
	db "next attack?",$FC,$20,$F8
	db "En garde!"
	db $FC,$40,$FF

	.LakituLovers_Impress_2
	db $80,$00,$00,$80
	db "Absolutely sublime!",$FE
	db "Let us step up our game,",$FE
	db "darling.",$FC,$20,$F8
	db "Yes, love, let's."
	db $FC,$40,$FF

	.LakituLovers_Almost_1
	db $80,$00,$00,$80
	db "Very close!",$FE
	db "That was but a modicum of",$FE
	db "error, within reason for a",$FE
	db "beginner, certainly!"
	db $FC,$40,$FF

	.LakituLovers_Almost_2
	db $80,$00,$00,$80
	db "Touche, but not quite there.",$FC,$20,$FE
	db "You'll have to do better",$FE
	db "than that to impress us!"
	db $FC,$40,$FF

	.LakituLovers_Enrage_1
	db $80,$00,$00,$80
	db "THOSE MOVES ARE FAR TOO",$FE
	db "AMATEURISH!",$FC,$40,$F8
	db "YOU INSULT ALL THINGS THAT",$FE
	db "POSSESS CLASS!"
	db $FC,$40,$FF

	.LakituLovers_Enrage_2
	db $80,$00,$00,$80
	db "UNACCEPTABLE!!",$FC,$20,$FE
	db "YOU BRING INSULT TO HIGH-",$FE
	db "RANKING INDIVIDUALS SUCH",$FE
	db "AS OURSELVES WITH YOUR LACKING"
	db "STYLE AND ELEGANCE!!"
	db $FC,$60,$FF

	.LakituLovers_Respect
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


	.LakituLovers_Death
	db $80,$00,$00,$80
	db "OH GOODNESS, NO!",$FC,$20,$FE
	db "MY LOVE! ",$FC,$20,"ARE YOU ALL RIGHT!?",$FC,$40,$F9,$02,$F8
	db "We are finished, darling...",$FC,$40,$F9,$04,$F8
	db "I...",$FE
	db "Huff... huff...",$FC,$40,$F8
	db "The void calls us, my love...",$FC,$60,$FF






	.FoundLuigi
	%portrait(3, 0)
	db "I will take it from here!"
	%endmessage()









	.Menu_EasyMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "A relaxing way to experience the game."
	%linebreak()
	db "Enemies are weaker and less aggressive."
	%linebreak()
	db "Bottomless pits are not instant death."
	%linebreak()
	db "Powerups are more common."
	%endmessage()

	.Menu_NormalMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "This is the standard difficulty setting."
	%linebreak()
	db "Enemies have all their abilities."
	%linebreak()
	db "Bottomless pits are instant death."
	%endmessage()

	.Menu_InsaneMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "This is a challenging mode for master gamers!"
	%linebreak()
	db "Bosses have new abilities."
	%linebreak()
	db "Some enemies are more durable."
	%linebreak()
	db "Enemies are more aggressive."
	%endmessage()

	.Menu_TimeMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "Most levels will have a strict time limit for clearing them. Your fastest clear time for each level will be saved."
	%endmessage()

	.Menu_RankMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "At the end of each level, you will be given a rank based on how well you did. Your highest rank for each level will be saved."
	%endmessage()

	.Menu_CriticalMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "Enemies will always kill you in one hit."
	%endmessage()

	.Menu_IronmanMode
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "If one player dies, the other one dies as well. There's no continuing on your own in this mode!"
	%linebreak()
	db "(only applies in multiplayer)"
	%endmessage()

	.Menu_Hardcore
	%border(0)
	%cinematic(2)
	%speed(0)
	%mode(2)
	%important(2)
	%color(0)
	%clearbox()
	%linebreak()
	db "This challenge is reserved for those mad enough to face death. In this mode, there are no continues. Once you die, that's it."
	%endmessage()




