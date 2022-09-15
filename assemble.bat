@echo off

asar.exe code\EMW.asm emw.smc

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

emw.smc