@echo off

REM Clean command prompt screen
cls

echo " #######################################################################"
echo " #                                                                     #"
echo " #   -=[                ASSEMBLE and LINK SCRIPT                ]=-    #"
echo " #     _______ _______ _______                                         #"
echo " #    |    ...|    ...|    ...|  Author : Blue DeviL                   #"
echo " #    |  _____|    .__|_   .._|  E-mail : bluedevil.SCT@gmail.com      #"
echo " #    | |_____|   .|    |  .|    Date   : 16/09/2022                   #"
echo " #    |_____.:|   :|    |  :|    WEB    : github.com/blue-devil        #"
echo " #     _____|:|   :|__  |  :|                                          #"
echo " #    |    .::|   .:::| |  :|  --/   Freedom, doesn't come from   \--  #"
echo " #    |_______|_______| |___|  --\_     second-hand thoughts.    _/--  #"
echo " #                                                                     #"
echo " #######################################################################"

set libname=OURLIBNAME

REM Delete compiled files if exists
if exist %libname%.lib del %libname%.lib
if exist %libname%.res del %libname%.res
if exist %libname%.obj del %libname%.obj

REM Compile resource file
REM \masm64\bin64\rc.exe /v %libname%.rc
REM If an object file needed from compiled resource uncomment the line below
REM \masm64\bin64\Cvtres.exe /machine:x64 OURAPPNAME.res

REM Assemble
\masm64\bin64\ml64.exe /c Modules\LIBMODULE_1.asm
\masm64\bin64\ml64.exe /c Modules\LIBMODULE_2.asm

REM Compile object files into lib
\masm64\bin64\LIB.EXE *.obj /out:%libname%.lib

dir %libname%.lib

pause