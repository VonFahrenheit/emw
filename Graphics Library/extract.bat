@echo off

cd ..
if not exist Graphics (mkdir Graphics)
if not exist ExGraphics (mkdir ExGraphics)
cd ExGraphics
del *.bin
cd ..
if not exist RawGraphics (mkdir RawGraphics)
cd RawGraphics
del /f /q /s *.* > NUL
cd ..
rmdir /q /s RawGraphics
mkdir RawGraphics
cd "Graphics Library"

if not exist temp (mkdir temp)
XCOPY "source\Vanilla GFX" "temp"
cd temp
ren *.bin ?????.bin
cd ..
XCOPY "temp" "..\Graphics" /y
cd temp
del /f /q /s *.bin > NUL
cd ..
rmdir /q temp

XCOPY "source\Static Sprite GFX" "..\ExGraphics"
XCOPY "source\Alt ExGFX" "..\ExGraphics"
cd ..\ExGraphics
ren *.bin ???????.bin
cd "..\Graphics Library"

XCOPY "source\Foreground GFX" "..\ExGraphics"
XCOPY "source\Background GFX" "..\ExGraphics"
XCOPY "source\AN2" "..\ExGraphics"
XCOPY "source\2bpp" "..\ExGraphics"
XCOPY "source\Tilemaps" "..\ExGraphics"
XCOPY "source\Misc Format GFX" "..\ExGraphics"
XCOPY "source\Linear GFX" "..\ExGraphics"
XCOPY "source\Sprite GFX" "..\ExGraphics"
cd ..\ExGraphics
ren *.bin ????????.bin
cd "..\Graphics Library"

ROBOCOPY "source\Uncompressed GFX" "..\RawGraphics" /e /np /nfl /ndl /njh /njs

pause