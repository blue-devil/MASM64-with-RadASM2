# MASM64 with RadASM2

This project consists of related and needed files for using MASM64 SDK with RadASM2.

![](https://img.shields.io/badge/Assembler-MASM64%20v14.xx-green.svg?style=flat-square&logo=visual-studio-code&logoColor=white&colorB=1CC887) [![](https://img.shields.io/badge/RadASM%20-v2.2.2.x%20-red.svg?style=flat-square&colorB=C94C1E&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAgCAYAAAASYli2AAACcklEQVR42tWVXWiPURzHz/FyQZOiVuatuFEoKzfKSCs35EJeCqFcEEa5s2heNrXiApuXFDYveUlKSywlIRfczM0WjZvJlGKTRLb5fHvOU6fT+T/PY3bj1Kff8z8vn+f8znPO+dshihnBYv8L4awRcl2FRTarBy8bQzgEjdbabzl9nxCW2IwOFYTrsBTKEH7PET4lLLYlGpcTrkC5qxqL8HeO8CVhoQ0qRxMOw34Y5TVVIPyYI+whTLVehZ9iWgZAL1mN8G6GbArhA/TZEilqKx2HCbADXkAV0oESwhOEfdChbXOUh1ovxS+wlcH3aNvC82VX3wx7Qyl9NhEugXZEU7ixX8E6Br13nTVDPU927R3QCl0wTX2h2rUNQqUv/ATLkHUGM1hLuBF8pFipZ+zBcIZKpw1O0vjYk24mnIXxEZHGNMIBxgxJ2M2P2PF7DafhGh1/0G8Gzzv1cWASfIZn0EJ7VzpIQqWyUguulFUXiDXwApxhYE9O2ibc2PMJNbAxkp5Oyh3NGvHzQkJPrK/aANtLjNNuOAU3kf/KFTrpGsJtaIdxbu3C0gvn4Dzi3qLCI3Su4/cCnnfDBvcCv/yEW0a7o6gwWI5tJvniMwutYZbQa9elsUqzgun/JKStjKAzvAvmDXuG1M1xqerkTAyG6Cy3FREeM8k2kag6MomvcBGaefG7LOF6k1wK6SUbFl0iOpqt/v+NjYjmEva4NQpPi9K6b5JN/UiXQTg+vbF1nlc4USytPpNcok1Iuk1G0eWgS0Hnd3akXbeIbuqWvP9lXxhOW2k9cOvzMJZWUWG/Sf4/lNbbv5GEwjeSSIaof7iitPwBoSgbVud1Jo0AAAAASUVORK5CYII=)](http://www.softpedia.com/get/Programming/File-Editors/RadASM.shtml)

## Setup
* Extract [RadASM2][web-github-radasm2-release] to wherever you want.
* Unzip [MASM64 SDK Package][web-masm64-sdk] under `C:\`
* Unzip this project inside your RadASM2 folder.
* Open `RadASM.ini` with your fav editor and add `MASM64` under `Assembler` section; look at the sample below:
```
[Assembler]
Assembler=MASM64,masm,UASM32,UASM64,nasm,mingw,MINGW32,MINGW64
```
**NOTE**: You don't have to write that much programming languages like me. But you must add at least one programming language to run RadASM2.


## Notes
For a seamless work via **MASM64 with RadASM2**, you must be sure that you've installed **MASM64 SDK** properly. 

Your folder structure should look like below:
```
C:\masm64
C:\masm64\bin64
C:\masm64\include64
C:\masm64\lib64
C:\masm64\macros64
```

Creators of MASM64 SDK cannot distribute Microsoft binaries; me neither. So you have to install a Windows SDK to your machine and copy some binaries under `c:\masm64\bin64` and `c:\masm64\bin64\1033`

Inside [MASM64 SDK archive][web-masm64-sdk] there is a `bin64\FileList.txt` file specifies which binaries should be istalled to where:
```
**********************************************
Files that must be obtained from Microsoft
Usually this is from a Visual Studio download.
**********************************************

------------------------------------------------------
This is a link to the community edition of build tools
------------------------------------------------------
https://visualstudio.microsoft.com/downloads/?q=build+tools

-----------------
Files in => bin64
-----------------
cvtres.exe
dumpbin.exe
editbin.exe
lib.exe
link.exe
link.exe.config
ml64.exe
msobj140.dll
mspdb140.dll
mspdbcmf.exe
mspdbcore.dll
mspdbsrv.exe
mspdbst.dll
mspft140.dll
msvcdis140.dll
msvcp140.dll
nmake.exe
tbbmalloc.dll

----------------------
Files in => bin64\1033
----------------------
atlprovui.dll
bscmakeui.dll
clui.dll
cvtresui.dll
linkui.dll
LocalESPCui.dll
mspdbcmfui.dll
mspft140ui.dll
nmakeui.dll
pgort140ui.dll
pgoui.dll
```

## Resources
* [MASM64 Beta Version 2 Forum Topic][web-masm64-forum-topic]
* [MASM64 Beta Version 2 Download Link][web-masm64-sdk]
* [Visual Studio Build Tools][web-ms-vs-build-tools]
* [MASM32 SDK][web-masm32-sdk]
* [RadASM2][web-github-radasm2]
* [RadASM2 v2.2.2.4][web-github-radasm2-release]

## Contributors
* [Blue DeviL // SCT][web-github-bluedevil]

## License
This project is under GPLv3 license.

[web-github-bluedevil]: https://github.com/blue-devil
[web-win-sdk-archive]: https://developer.microsoft.com/en-us/windows/downloads/sdk-archive
[web-masm32-sdk]: http://www.masm32.com/download.htm
[web-masm64-sdk]: http://www.masm32.com/download/masm64.zip
[web-masm64-forum-topic]: https://masm32.com/board/index.php?topic=10052.0
[web-ms-vs-build-tools]: https://visualstudio.microsoft.com/downloads/?q=build+tools
[web-github-radasm2-release]: https://github.com/blue-devil/RadASM2/blob/master/Release/RadASM-2.2.2.4-FullPackage.zip
[web-github-radasm2]: https://github.com/mrfearless/RadASM2