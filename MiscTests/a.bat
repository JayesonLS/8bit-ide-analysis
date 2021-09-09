@echo off
rem This batch file compiles using TASM 5 and DOSBOX
rem Put these lines in the [autoexec] section of dosbox conf file.
rem
rem mount c c:\dev\img\dosbox-c-drive
rem mount e c:\dev\8bit-ide-analysis\MiscTests
rem e:
rem
rem TASM 5 should be installed to dosbox-c-device\TASM

echo Assembling...
c:\tasm\bin\tasm MiscTest MiscTest MiscTest
if not ERRORLEVEL 0 goto exit

echo Linking...
c:\tasm\bin\tlink /Tdc /3 MiscTest.obj
if not ERRORLEVEL 0 goto exit

echo.
echo Copying to floppy image...
imgmount a c:\dev\img\dos622_144_boot.img -t floppy
copy MiscTest.com a:
imgmount -u a

echo.
echo Exiting...
:exit