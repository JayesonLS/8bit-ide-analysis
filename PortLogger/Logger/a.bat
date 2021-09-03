@echo off
rem This batch file compiles using TASM 5 and DOSBOX
rem Put these lines in the [autoexec] section of dosbox conf file.
rem
rem mount c c:\dev\img\dosbox-c-drive
rem mount d c:\dev\8bit-ide-analysis\PortLogger
rem d:
rem cd Logger
rem
rem TASM 5 should be installed to dosbox-c-device\TASM

echo Assembling...
c:\tasm\bin\tasm logger
if not ERRORLEVEL 0 goto exit

echo Linking...
c:\tasm\bin\tlink /Tdc /3 logger.obj
if not ERRORLEVEL 0 goto exit

echo.
echo Copying to floppy image...
imgmount a c:\dev\img\dos622_144_boot.img -t floppy
copy logger.com a:
imgmount -u a

echo.
echo Exiting...
:exit