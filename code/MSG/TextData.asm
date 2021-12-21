
;
; known bugs:
;	- using the commands delay, waitforinput, and scroll/scrollfull in that exact sequence causes a graphical glitch
;	  there is no real reason to use delay and waitforinput after each other though, so just don't do that
;
;	- using the scroll/scrollfull command without a delay or waitforinput command just before can cause a line to be skipped if the player is holding B
;	  this can be circumvented by placing a %delay(1) command just before, which will pause the text for 1 frame
;
;	- entering a single word that is wider than the text box will cause major graphical errors
;	  make sure to place spaces and line breaks at the appropriate locations to circumvent this


	!Temp = 1			; index 0 doesn't count since it means no message

	if !CompileText = 2
		.MainPtr
	endif

;====================================================================================================;
%insertMSG(DebugMessage)
if !CompileText = 1
	%mode(1)
	db "You're a real whippersnapper!"
	%waitforinput()
	%talk(2)
	%scrollfull()
	db "AND I MEAN IT!!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Wakeup)
if !CompileText = 1
	%mode(1)
	db "We're about to arrive!"
	%waitforinput()
	%scrollfull()
	db "Please see Captain Toad in the command bridge!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Guard1)
if !CompileText = 1
	db "Sorry, I can't let you pass! If you mess any more with the treasury I'll lose my job!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Guard2)
if !CompileText = 1
	db "It's stormy outside! Please understand!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Training_1)
if !CompileText = 1
	%mode(1)
	db "Will you be taking on the MIGHTY TRAINING COURSE?"
	%linebreak()
	%dialogue(1, 0)
	db "   Yes"
	%linebreak()
	db "   No"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Training_2)
if !CompileText = 1
	db "LET'S GOOOOOOO"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_Training_3)
if !CompileText = 1
	db "Coward."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_IntroLevel_1)
if !CompileText = 1
	db "Are you ready to embark?"
	%linebreak()
	%dialogue(1, 0)
	db "   Yes"
	%linebreak()
	db "   No"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_IntroLevel_2)
if !CompileText = 1
	db "Off you go!"
	%setexit($C6, $04)
	%triggerexit()
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad_IntroLevel_3)
if !CompileText = 1
	db "Very well. Come back when you're ready!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(MeetKadaal_1)
if !CompileText = 1
	%portrait(Kadaal, 0)
	db "I will take it from here."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Survivor_Talk_1)
if !CompileText = 1
	%portrait(Survivor, 0)
	%speed(7)
	%mode(1)
	db "You have returned, hero! Feel free to stay as long as you like!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(MarioSwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Mario, 0)
	%speed(7)
	db "It's-a go time!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LuigiSwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Luigi, 0)
	%speed(7)
	db "Go-igi!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(KadaalSwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Kadaal, 0)
	%speed(7)
	db "...very well."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LeewaySwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Leeway, 0)
	%speed(7)
	db "I knew you'd need me for this one!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(AlterSwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Alter, 0)
	%speed(7)
	db "[PLACEHOLDER]"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(PeachSwitch)
if !CompileText = 1
	%mode(1)
	%portrait(Peach, 0)
	%speed(7)
	db "[PLACEHOLDER]"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad1)
if !CompileText = 1
	%mode(1)
	db "TOOOOOOOOAAAAAAAD!!!! "
	%waitforinput()
	%talk(2)
	%scrollfull()
	db "whatever"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Toad2)
if !CompileText = 1
	%mode(1)
	db "Bruh..."
	%linebreak()
	db "I already talked to you."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Tinker_Talk_1)
if !CompileText = 1
	%portrait(Tinkerer, 0)
	%speed(8)
	%mode(1)
	db "Hoooi fam, how about you cough up some of those "
	%talk(1)
	%speed(15)
	db "YOSHI COINS?"
	%talk(0)
	%speed(0)
	%linebreak()
	%dialogue(3, 0)
	db "    option 1"
	%linebreak()
	db "    option 2"
	%linebreak()
	db "    option 3"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Mario_Upgrade_1)
%insertMSG(Mario_Upgrade_2)
%insertMSG(Mario_Upgrade_3)
%insertMSG(Mario_Upgrade_4)
%insertMSG(Mario_Upgrade_5)
%insertMSG(Mario_Upgrade_6)
%insertMSG(Mario_Upgrade_7)
%insertMSG(Luigi_Upgrade_1)
%insertMSG(Luigi_Upgrade_2)
%insertMSG(Luigi_Upgrade_3)
%insertMSG(Luigi_Upgrade_4)
%insertMSG(Luigi_Upgrade_5)
%insertMSG(Luigi_Upgrade_6)
%insertMSG(Luigi_Upgrade_7)
%insertMSG(Kadaal_Upgrade_1)
%insertMSG(Kadaal_Upgrade_2)
%insertMSG(Kadaal_Upgrade_3)
%insertMSG(Kadaal_Upgrade_4)
%insertMSG(Kadaal_Upgrade_5)
%insertMSG(Kadaal_Upgrade_6)
%insertMSG(Kadaal_Upgrade_7)
%insertMSG(Leeway_Upgrade_1)
%insertMSG(Leeway_Upgrade_2)
%insertMSG(Leeway_Upgrade_3)
%insertMSG(Leeway_Upgrade_4)
%insertMSG(Leeway_Upgrade_5)
%insertMSG(Leeway_Upgrade_6)
%insertMSG(Leeway_Upgrade_7)
%insertMSG(Alter_Upgrade_1)
%insertMSG(Alter_Upgrade_2)
%insertMSG(Alter_Upgrade_3)
%insertMSG(Alter_Upgrade_4)
%insertMSG(Alter_Upgrade_5)
%insertMSG(Alter_Upgrade_6)
%insertMSG(Alter_Upgrade_7)
%insertMSG(Peach_Upgrade_1)
%insertMSG(Peach_Upgrade_2)
%insertMSG(Peach_Upgrade_3)
%insertMSG(Peach_Upgrade_4)
%insertMSG(Peach_Upgrade_5)
%insertMSG(Peach_Upgrade_6)
%insertMSG(Peach_Upgrade_7)
if !CompileText = 1
	db "UNUSED MESSAGE"
	%endmessage()
endif


;====================================================================================================;
%insertMSG(RexVillage_Sign_1)
if !CompileText = 1
	db "Closed due to unexpected appearance of basement."
	%linebreak()
	db "Please understand."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Sign_2)
if !CompileText = 1
	db "Home of the awesome Chilli Pepper Clan. Enter at your own peril... (coward)"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Rex1)
if !CompileText = 1
	%portrait(Rex, 0)
	db "Have I seen you before? I can't remember, non-Rex all look the same to me!"
	%waitforinput()
	%scrollfull()
	db "Anyways, you shouldn't be here. The area above ground is for Rex only!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Aristocrat1)
if !CompileText = 1
	%portrait(Rex, 0)
	db "Fetch me my golden mushrooms! Hurry it up, you fools!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Aristocrat2)
if !CompileText = 1
	%important(2)
	%portrait(Rex, 0)
	%speed(15)
	db "YOU THIEF!!!"
	%linebreak()
	db "I'LL DESTROY YOU!!!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Shop1)
if !CompileText = 1
	%portrait(Rex, 1)
	db "Buy somethin' will ya!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Shop2)
if !CompileText = 1
	%portrait(Rex, 1)
	%mode(1)
	db "Thank you for your patronage!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Shop3)
if !CompileText = 1
	%portrait(Rex, 1)
	db "Boy, this is really expensive!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_ShopHurt)
if !CompileText = 1
	%portrait(Rex, 1)
	db "Ouch! This is assault!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_ShopRegret)
if !CompileText = 1
	%important(2)
	db "Visiting this place reminds you of your terrible deeds..."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Mayor1)
if !CompileText = 1
	%portrait(Rex, 0)
	db "Yes, taxes! I love collecting taxes!"
	%linebreak()
	db "All for the King, of course..."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Catacombs)
if !CompileText = 1
	%portrait(Rex, 0)
	db "I don't recall this place ever being here..."
	%linebreak()
	db "Can a basement really appear out of nowhere?"
	%waitforinput()
	%scrollfull()
	%portrait(Rex, 1)
	db "I don't know. Who knows where basements come from anyway?"
	%waitforinput()
	%scrollfull()
	%portrait(Rex, 0)
	db "There's something strange going on..."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Negotiator1)
if !CompileText = 1
	%portrait(Rex, 0)
	db "You look tough..."
	%waitforinput()
	%scrollfull()
	db "Very well, let's negotiate! You leave me alone and you let me live. Deal?"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Negotiator2)
if !CompileText = 1
	%portrait(Rex, 0)
	db "No no, help yourself to my lunch, that's ok..."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_BullyGuard)
if !CompileText = 1
	%portrait(Rex, 1)
	db "Hey, Goomba! Why don't you try to escape through the window?"
	%waitforinput()
	%scrollfull()
	db "Oh right, you can't reach!"
	%waitforinput()
	%scrollfull()
	db "AHAHAHAHAHAHA!!"
	%waitforinput()
	%scrollfull()
	db "Oh I slay myself!"
	%waitforinput()
	%scrollfull()
	db "..."
	%waitforinput()
	%scrollfull()
	db "(I wish I had a more fulfilling job.)"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Mayor2)
if !CompileText = 1
	%portrait(Rex, 0)
	%important(2)
	%speed(10)
	db "Bury me with my money..."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_SkyScraper1)
if !CompileText = 1
	%portrait(Rex, 0)
	db "Go ahead."
	%waitforinput()
	%scrollfull()
	db "Buy it."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_SkyScraper2)
if !CompileText = 1
	%portrait(Rex, 0)
	db "Aaaagh! You'll regret this!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_SkyScraper3)
if !CompileText = 1
	%portrait(Rex, 0)
	db "They tryin to steal our treasure! Get em, boys!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(RexVillage_Library)
if !CompileText = 1
	%portrait(Rex, 0)
	db "According to the legends, no Rex has been able to use magic since the times of the Dragon King."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(DinolordsDomain_Sign_1)
if !CompileText = 1
	db "Ahead lie the domains of Captain Warrior, Champion of all Rex."
	%linebreak()
	db "Non-Rex are NOT welcome."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(DinolordsDomain_Sign_2)
if !CompileText = 1
	db "UNUSED MESSAGE"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CaptainWarrior_Fight1_Intro)
if !CompileText = 1
	%mode(1)
	%portrait(CaptainWarrior, 0)
	db "Halt! On order of our great King, civilians may not pass here."
	%waitforinput()
	%scrollfull()
	db "Wait a minute! You're not even Rex!"
	%waitforinput()
	%scrollfull()
	db "Yet you "
	%speed(15)
	db "DARE COME HERE!!"
	%speed(8)
	%waitforinput()
	%scrollfull()
	db "In the name of the great King of the Rex, I, Captain Warrior, sentence you to die!"
	%waitforinput()
	%scrollfull()
	db "All troops, "
	%delay(16)
	db "attack!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CaptainWarrior_Fight1_Defeated)
if !CompileText = 1
	%mode(1)
	%portrait(CaptainWarrior, 0)
	%speed(15)
	db "Huff.. "
	%delay(16)
	db "Huff.. "
	%delay(16)
	%speed(8)
	%linebreak()
	db "I can't believe how strong you are..."
	%waitforinput()
	%scrollfull()
	db "All troops withdraw at once."
	%linebreak()
	db "We must warn the King."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CaptainWarrior_Fight1_Leeway)
if !CompileText = 1
	%mode(1)
	%portrait(CaptainWarrior, 0)
	db "Halt!"
	%linebreak()
	db "Wait... Leeway?"
	%waitforinput()
	%scrollfull()
	%portrait(Leeway, 1)
	db "Oh yes! I have returned, Captain."
	%waitforinput()
	%scrollfull()
	%portrait(CaptainWarrior, 0)
	db "I don't see Rexcalibur on you..."
	%linebreak()
	db "Have you returned merely to report your failure?"
	%waitforinput()
	%scrollfull()
	%portrait(Leeway, 1)
	db "I bring not the Dragon King's sword, nor do I come in defeat."
	%linebreak()
	%waitforinput()
	db "I am here... "
	%speed(12)
	db "to relieve the King of his crown..."
	%waitforinput()
	%scrollfull()
	%portrait(CaptainWarrior, 0)
	%speed(15)
	db "LEEWAY YOU DAMNABLE TRAITOR!"
	%speed(8)
	%waitforinput()
	%linebreak()
	db "All troops, "
	%delay(16)
	db "attack!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(MushroomGorge_Sign_1)
if !CompileText = 1
	db "This monument marks the highest point on Rex Island."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CastleRex_Sign_1)
if !CompileText = 1
	db "Ahead lies Castle Rex, seat of our power and home to the Great Kingking, Lord of This Island and King of the Rex."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CastleRex_Sign_2)
if !CompileText = 1
	db "Throne room under renovation."
	%linebreak()
	db "Visitors may seek the King at the top of the Grand Tower."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CastleRex_Rex_Warning_1)
if !CompileText = 1
	db "I saw you fight Captain Warrior so I know how strong you are."
	%delay(24)
	%linebreak()
	db "But the King is the strongest there is! You can't beat him!"
	%waitforinput()
	db "Well... maybe the Dark Lord is stronger, but he's our ally now."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CastleRex_Rex_Warning_2)
if !CompileText = 1
	db "The strongest Rex has always been our leader, but since the pact with the Dark Lord, the King has been stronger than ever before!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CastleRex_Rex_Warning_3)
if !CompileText = 1
	db "Captain Warrior told me I can't beat you, so I won't fight."
	%waitforinput()
	db "Still, I'm not worried, because the King will do what I can not!"
	%waitforinput()
	db "That's what he always does, and it's why we rule this Island today."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(CaptainWarrior_Warning)
if !CompileText = 1
	db "There you are."
	%waitforinput()
	db "The King is on the other side of this door."
	%waitforinput()
	db "No, I won't try to stop you. I already know how that would go."
	%waitforinput()
	db "I have faith in my King. He is far beyond even you."
	%waitforinput()
	db "So go!"
	%delay(16)
	db "Go and meet your end at the hand of the Dragon King!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(KingKing_Intro)
if !CompileText = 1
	%portrait(KingKing, 0)
	db "FIGHT START TEXT"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(KingKing_Defeated)
if !CompileText = 1
	%portrait(KingKing, 0)
	db "DEFEAT TEXT"
	%endmessage()
endif
;====================================================================================================;
if !CompileText = 1

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

endif
;====================================================================================================;
%insertMSG(TowerOfStorms_Sign_1)
if !CompileText = 1
	%speed(0)
	db " - DANCE MACHINE -"
	%linebreak()
	db "   - SAFETY OFF"
	%linebreak()
	db "   - LEADERBOARD:"
	%linebreak()
	db "       LAKITA"
	%linebreak()
	db "       LAKITO"
	%linebreak()
	db "       DARK LORD"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(TowerOfStorms_Sign_2)
if !CompileText = 1
	%speed(0)
	db "This is the high level dance practice hall. Only the Lakitu Lords are skilled enough to make it to the top!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Intro)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Ho ho ho ho..."
	%delay(48)
	db "Someone made it to the top, love."
	%delay(16)
	db "Only the Dark Lord has made it this far before."
	%delay(64)
	%scroll($FF)
	db "Oh my! What should we do with them, darling?"
	%delay(64)
	%scroll($FF)
	db "I think you already know, love. We shall do the old you-know-what!"
	%delay(64)
	%scroll($FF)
	db "Oh goodness, I thought you'd never suggest it!"
	%delay(64)
	%scroll($FF)
	%speed(12)
	db "LET US DANCE THEM FABULOUSLY INTO THE VOID!!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Impress_1)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Impressive moves! But can you keep up with our next attack?"
	%delay(32)
	%linebreak()
	db "En garde!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Impress_2)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Absolutely sublime! Let us step up our game, darling."
	%delay(32)
	%linebreak()
	db "Yes, love, let's."
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Almost_1)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Very close! That was but a modicum of error, within reason for a beginner, certainly!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Almost_2)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Touche, but not quite there."
	%delay(32)
	db "You'll have to do better than that to impress us!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Enrage_1)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "THOSE MOVES ARE FAR TOO AMATEURISH!"
	%delay(64)
	%scroll($FF)
	db "YOU INSULT ALL THINGS THAT POSSESS CLASS!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Enrage_2)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "UNACCEPTABLE!!"
	%delay(32)
	%linebreak()
	db "YOU BRING INSULT TO HIGH- RANKING INDIVIDUALS SUCH AS OURSELVES WITH YOUR LACK OF STYLE AND ELEGANCE!!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Respect)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "Such elegance!"
	%delay(32)
	%linebreak()
	db "Such class!"
	%delay(32)
	%scroll($FF)
	db "We swore allegiance to the lord of darkness as we thought his dancing to be without equal."
	%delay(32)
	%scroll($FF)
	db "But you..."
	%delay(32)
	%linebreak()
	db "You outclass even him! Your dancing is unrivaled in this realm and all others!"
	%delay(32)
	%scroll($FF)
	db "We simply cannot accept you as an enemy any longer. Please, accept our apology and eternal allegiance."
	%delay(32)
	%scroll($FF)
	db "We hereby renounce the Dark Lord and profess undying loyalty to your cause, hero!"
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(LakituLovers_Death)
if !CompileText = 1
	%cinematic(1)
	%mode(1)
	db "OH GOODNESS, NO!"
	%delay(32)
	%linebreak()
	db "MY LOVE! "
	%delay(32)
	db "ARE YOU ALL RIGHT!?"
	%delay(64)
	%scroll($FF)
	db "We are finished, "
	%delay(32)
	db "darling..."
	%delay(64)
	%scroll($FF)
	db "I..."
	%delay(32)
	db "Huff... huff..."
	%delay(64)
	%linebreak()
	db "The void calls us, my love..."
	%delay(64)
	%endmessage()
endif
;====================================================================================================;
%insertMSG(FoundLuigi)
if !CompileText = 1
	%portrait(Luigi, 0)
	db "I will take it from here!"
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Menu_EasyMode)
if !CompileText = 1
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
	db "Enemies take contact damage upon touching you."
	%linebreak()
	db "Bottomless pits are not instant death."
	%linebreak()
	db "Powerups are more common."
	%endmessage()
endif
;====================================================================================================;
%insertMSG(Menu_NormalMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_InsaneMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_TimeMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_RankMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_CriticalMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_IronmanMode)
if !CompileText = 1
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
endif
;====================================================================================================;
%insertMSG(Menu_HardcoreMode)
if !CompileText = 1
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
endif
;====================================================================================================;



if !CompileText = 2


.LevelPtr
; levels 000-024
dw .L000
dw .L001
dw .L002
dw .L003
dw .L004
dw .L005
dw .L006
dw .L007
dw .L008
dw .L009
dw .L00A
dw .L00B
dw .L00C
dw .L00D
dw .L00E
dw .L00F
dw .L010
dw .L011
dw .L012
dw .L013
dw .L014
dw .L015
dw .L016
dw .L017
dw .L018
dw .L019
dw .L01A
dw .L01B
dw .L01C
dw .L01D
dw .L01E
dw .L01F
dw .L020
dw .L021
dw .L022
dw .L023
dw .L024
; levels 101-13B
dw .L101
dw .L102
dw .L103
dw .L104
dw .L105
dw .L106
dw .L107
dw .L108
dw .L109
dw .L10A
dw .L10B
dw .L10C
dw .L10D
dw .L10E
dw .L10F
dw .L110
dw .L111
dw .L112
dw .L113
dw .L114
dw .L115
dw .L116
dw .L117
dw .L118
dw .L119
dw .L11A
dw .L11B
dw .L11C
dw .L11D
dw .L11E
dw .L11F
dw .L120
dw .L121
dw .L122
dw .L123
dw .L124
dw .L125
dw .L126
dw .L127
dw .L128
dw .L129
dw .L12A
dw .L12B
dw .L12C
dw .L12D
dw .L12E
dw .L12F
dw .L130
dw .L131
dw .L132
dw .L133
dw .L134
dw .L135
dw .L136
dw .L137
dw .L138
dw .L139
dw .L13A
dw .L13B



;===================;
;LEVEL TEXT POINTERS;
;===================;

.L000	dw !MSG_DebugMessage
.L001	dw !MSG_MushroomGorge_Sign_1
.L002	dw !MSG_RexVillage_Sign_1
	dw !MSG_RexVillage_Sign_2
.L003	dw !MSG_DinolordsDomain_Sign_1
	dw !MSG_DinolordsDomain_Sign_2
.L004
.L005	dw !MSG_CastleRex_Sign_1
	dw !MSG_CastleRex_Sign_2
.L006
.L007
.L008
.L009
.L00A
.L00B
.L00C
.L00D
.L00E
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

.L13A	dw !MSG_Toad_Guard1

.L13B	dw !MSG_Menu_EasyMode
	dw !MSG_Menu_NormalMode
	dw !MSG_Menu_InsaneMode
	dw !MSG_Menu_TimeMode
	dw !MSG_Menu_RankMode
	dw !MSG_Menu_CriticalMode
	dw !MSG_Menu_IronmanMode
	dw !MSG_Menu_HardcoreMode



endif






