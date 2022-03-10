@echo off

asar.exe code\VR3\VR3.asm emw.smc
asar.exe code\FusionCore\FusionCore.asm emw.smc
asar.exe code\SpriteEngines.asm emw.smc
asar.exe code\SP_Patch.asm emw.smc
asar.exe code\MSG\MSG.asm emw.smc
asar.exe code\SP_Level.asm emw.smc
asar.exe code\SP_Menu.asm emw.smc
asar.exe code\SP_Files.asm emw.smc

if exist smw.smc (
COPY emw.smc bps
COPY smw.smc bps
cd bps
del emw.bps
flips.exe -c "smw.smc" "emw.smc" "emw.bps"
del smw.smc
del emw.smc
cd ..
)

if exist "..\..\Dropbox\temp backup\code" (XCOPY "code" "C:\Users\46739\Dropbox\temp backup\code" /e /y)
if exist "..\..\Dropbox\temp backup" (COPY "bps\emw.bps" "C:\Users\46739\Dropbox\temp backup" /y)

emw.smc