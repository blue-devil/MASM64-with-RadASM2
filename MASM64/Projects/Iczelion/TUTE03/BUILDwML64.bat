@echo off

REM Clean command prompt screen
cls

echo " #######################################################################"
echo " #                                                                     #"
echo " #   -=[                ASSEMBLE and LINK SCRIPT                ]=-    #"
echo " #     _______ _______ _______                                         #"
echo " #    |    ...|    ...|    ...|  Author : Blue DeviL                   #"
echo " #    |  _____|    .__|_   .._|  E-mail : bluedevil.SCT@gmail.com      #"
echo " #    | |_____|   .|    |  .|    Date   : 24/09/2022                   #"
echo " #    |_____.:|   :|    |  :|    WEB    : github.com/blue-devil        #"
echo " #     _____|:|   :|__  |  :|                                          #"
echo " #    |    .::|   .:::| |  :|  --/   Freedom, doesn't come from   \--  #"
echo " #    |_______|_______| |___|  --\_     second-hand thoughts.    _/--  #"
echo " #                                                                     #"
echo " #######################################################################"


set appname=TUTE03

REM Delete compiled files if exists
if exist %appname%.exe del %appname%.exe
if exist %appname%.res del %appname%.res
if exist %appname%.obj del %appname%.obj

REM Compile resource file
REM \masm64\bin64\rc.exe /v %appname%.rc
REM If an object file needed from compiled resource uncomment the line below
REM \masm64\bin64\Cvtres.exe /machine:x64 TUTE03.res

REM Assemble
\masm64\bin64\ml64.exe /c %appname%.asm
REM Link
\masm64\bin64\link.exe /SUBSYSTEM:WINDOWS /LARGEADDRESSAWARE %appname%.obj

dir %appname%.exe

pause