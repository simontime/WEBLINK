@echo off

REM Make temp directory
rd /s /q output
mkdir output

REM Copy tools, images and code to temp directory
xcopy /s tools output
xcopy /s source output
xcopy /s images output

cd output

REM Build code and generate ROM
msdos ASM8521 -s16 WEBLINK.ASM
msdos ASM8521 -s16 LINK.ASM
msdos ASM8521 -s16 SYSCALL.ASM
msdos ASM8521 -s16 SPEECH.ASM
msdos ASM8521 -s16 MELODY.ASM
msdos LINK8521 @WEBLINK.LNK
msdos HEX8521 -P -F -B 020,021,022 WEBLINK
msdos HEX2BIN WEBLINK.HEX WEBLINK.BIN /0

REM Pad ROM
msdos STUFF WEBLINK.BIN 23296 00

REM Encode and add icon to ROM
gcimagetool encode icon.png icon.bin -c
copy /b WEBLINK.BIN + icon.bin WEBLINK.BIN

REM Pad ROM
msdos STUFF WEBLINK.BIN 24576 00

REM Encode and add frames to ROM
for /l %%i in (0,1,28) do (
	gcimagetool encode frame%%i.png frame.bin -n
	copy /b WEBLINK.BIN + frame.bin WEBLINK.BIN
)

REM Pad ROM to final output size
msdos STUFF WEBLINK.BIN 262144 0

REM Delete all files except WEBLINK.BIN
attrib +r WEBLINK.BIN
del /q *.*