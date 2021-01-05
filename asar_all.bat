@echo off
asar.exe patches\VR3\VR3.asm emw.smc
asar.exe patches\Fe26\FusionCore.asm emw.smc
asar.exe patches\PCE\PCE.asm emw.smc
asar.exe patches\Fe26\Fe26.asm emw.smc
asar.exe patches\SP_Patch.asm emw.smc
asar.exe patches\MSG\MSG.asm emw.smc
asar.exe patches\SP_Level.asm emw.smc
asar.exe patches\SP_Files.asm emw.smc
emw.smc