# Changelog

## [20220901] - 01-09-2022
### Added
* New data types added to MASM64Type.api
* Modal and Modeless DialogApp Templates added.
* RGB snippet added

### Changes
* Using [Windows Data Types][web-msdocs-windows-data-types] all data types inside MASM64Type.api checked and fixed
* Window Class Styles moved from MASM64Message.api to MASM64ApiWord.api

## [202208825] - 25-08-2022
### Added
* .SKIP .UNTILCXZD .UNTILCXZE .UNTILCXZNE .UNTILCXZED .UNTILCXZNED .ENDF keyword added to MASM64.ini for keyword highlighting
* Window class styles added to MASM64Message.api. Three of them deprecated and one is new. ([Source][web-msdocs-windows-class-styles])
  * CS_VREDRAW,equ 1h
  * CS_HREDRAW,equ 2h
  * CS_KEYCVTWINDOW,equ 4h      // deprecated?
  * CS_DBLCLKS,equ 8h
  * CS_OWNDC,equ 20h
  * CS_CLASSDC,equ 40h
  * CS_PARENTDC,equ 80h
  * CS_NOKEYCVT,equ 100h        // deprecated?
  * CS_NOCLOSE,equ 200h
  * CS_SAVEBITS,equ 800h
  * CS_BYTEALIGNCLIENT,equ 1000h
  * CS_BYTEALIGNWINDOW,equ 2000h
  * CS_PUBLICCLASS,equ 4000h    // deprecated?
  * CS_GLOBALCLASS,equ CS_PUBLICCLASS
  * CS_IME,equ 10000h
  * CS_DROPSHADOW,equ 20000h    // new
* CW_USEDEFAULT value added to MASM64Message.api
  * CW_USEDEFAULT,equ 80000000h


[web-msdocs-windows-data-types]: https://docs.microsoft.com/en-us/windows/win32/winprog/windows-data-types
[web-msdocs-windows-class-styles]: https://docs.microsoft.com/en-us/windows/win32/winmsg/window-class-styles