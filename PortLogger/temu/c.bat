@echo off
rem This batch file compiles using TASM 5 and DOSBOX
rem Put these lines in the [autoexec] section of dosbox conf file.
rem
rem mount c c:\dev\img\dosbox-c-drive
rem mount d c:\dev\8bit-ide-analysis\PortLogger
rem d:
rem
rem TASM 5 should be installed to dosbox-c-device\TASM

c:\tasm\bin\tasm temu
c:\tasm\bin\tlink /Tdc /3 temu.obj
imgmount a c:\dev\img\dos622_144_boot.img -t floppy
copy temu.com a:
imgmount -u a
