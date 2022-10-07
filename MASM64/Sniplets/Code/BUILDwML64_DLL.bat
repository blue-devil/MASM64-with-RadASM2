@echo off

REM Clean command prompt screen
cls

echo " #######################################################################"
echo " #                                                                     #"
echo " #   -=[                ASSEMBLE and LINK SCRIPT                ]=-    #"
echo " #     _______ _______ _______                                         #"
echo " #    |    ...|    ...|    ...|  Author : Blue DeviL                   #"
echo " #    |  _____|    .__|_   .._|  E-mail : bluedevil.SCT@gmail.com      #"
echo " #    | |_____|   .|    |  .|    Date   : 23/09/2022                   #"
echo " #    |_____.:|   :|    |  :|    WEB    : github.com/blue-devil        #"
echo " #     _____|:|   :|__  |  :|                                          #"
echo " #    |    .::|   .:::| |  :|  --/   Freedom, doesn't come from   \--  #"
echo " #    |_______|_______| |___|  --\_     second-hand thoughts.    _/--  #"
echo " #                                                                     #"
echo " #######################################################################"


set dllname=OURDLLNAME

REM Delete compiled files if exists
if exist %dllname%.dll del %dllname%.dll
if exist %dllname%.lib del %dllname%.lib
if exist %dllname%.exp del %dllname%.exp
if exist %dllname%.res del %dllname%.res
if exist %dllname%.obj del %dllname%.obj

REM Compile resource file
REM \masm64\bin64\rc.exe /v %dllname%.rc
REM If an object file needed from compiled resource uncomment the line below
REM \masm64\bin64\Cvtres.exe /machine:x64 %dllname%.res

REM Assemble
\masm64\bin64\ml64.exe /c %dllname%.asm
REM Link
\masm64\bin64\link.exe /DLL /DEF:%dllname%.def /ENTRY:DllMain /SUBSYSTEM:WINDOWS /LARGEADDRESSAWARE %dllname%.obj

dir %dllname%.dll

pause