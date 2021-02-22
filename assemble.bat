@echo off

asar.exe code\VR3\VR3.asm emw.smc
asar.exe code\Fe26\FusionCore.asm emw.smc
asar.exe code\PCE\PCE.asm emw.smc
asar.exe code\Fe26\Fe26.asm emw.smc
asar.exe code\SP_Patch.asm emw.smc
asar.exe code\MSG\MSG.asm emw.smc
asar.exe code\SP_Level.asm emw.smc
asar.exe code\SP_Menu.asm emw.smc
asar.exe code\SP_Files.asm emw.smc

emw.smc