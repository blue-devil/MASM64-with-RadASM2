# Changelog

## [2022.09.02] - 02-09-2022
### Added
* Added Base WndProc Sniplet
* OPENFILENAMEW added to MASM64ApiStruct.api
* Some interger types from Windows base types added to MASM64.ini:
  * INT, INT8, INT16, INT32, INT64, INT_PTR
  * UINT8, UINT16, UINT32, UINT64, UINT_PTR
* `MapViewOfFileExNuma` prototype added to MASM64ApiCall.api
* `MapViewOfFileExNuma`, `MapViewOfFileEx`, `MapViewOfFile` functions' `dwDesiredAccess` parameters added to `MASM64ApiConst.api`
* New winapi function protoypes added to `MASM64ApiCall.api`
  * CreateFileMappingNumaW, CreateFileMappingNumaA, CreateFileMappingNuma
  * CreateFileMappingW, CreateFileMappingA
* `flProtect` parameters added:
  * PAGE_EXECUTE_READ, PAGE_EXECUTE_READWRITE, PAGE_EXECUTE_WRITECOPY, PAGE_READONLY, PAGE_READWRITE, PAGE_WRITECOPY
  * SEC_COMMIT,SEC_IMAGE,SEC_IMAGE_NO_EXECUTE,SEC_LARGE_PAGES,SEC_NOCACHE,SEC_RESERVE,SEC_WRITECOMBINE
  * NUMA_NO_PREFERRED_NODE
* OPENFILENAME struc's flags added to `MASM64ApiWord.api`
  * OFN_*
* WM_SIZE message wParam parameters added to `MASM64ApiWord.api`
* STARTUPINFOW, STARTUPINFOEX{A/W}, added to `MASM64ApiWord.api`
  * `STARTF_*` flag parameters added to MASM64ApiWord.api
* GetStartupInfoA and GetStartupInfoW, CreateProcessA and CreateProcessW added to `MASM64ApiCall.api`
* **Process Creation Flags** added to `MASM64ApiWord.api`
* DialogWithManifest sample project added
* ADDED: TUTE14 - Process
* ADDED: LoadImage, CreateThread and CreateFont Constants
* FIX: LoadCursor and LoadIcon apis shouldn't get hInst as parameter. They should get null.
* FIX: Some apis mistakenly get 0 instead of null
* FIX: Some cosmetic changes has been made
* ADDED: two new code sniplet added: DialogBoxParam and CreateDialogParam
* ADDED: TUTE15
* ADDED: TUTE16
* ADDED: `BOOL`, `BOOLEAN` to MASM64.ini
* ADDED: DLL reason flags to api files
* ADDED: TUTE17
* ADDED: Common Control style constants to api files
* ADDED: TUTE 18
* ADDED: MASM64StructConst.api (not working rn)
* ADDED: MASM64ApiMacroCall.api
* ADDED: HDC and HBITMAP to MASM64.ini for color hiliting
* ADDED: TUTE20, TUTE21, TUTE22
* Added: SetWindowHookEx first parameters added to MASM64ApiConst.api
* Added: Hook Codes added to MASM64ApiWord.api
* Added: GetClassLongPtr and SetClassLongPtr 2nd parameteres to MASM64ApiConst.api
* Added: SetClassLongPtr, GetClassLongPtr to MASM64ApiCall.api
* ADDED: ULONG,ULONGLONG,ULONG_PTR,ULONG32,ULONG64 to MASM64.ini
* ADDED: MSLLHOOKSTRUCT and constants
* ADDED: NOTIFYICONDATA and constants
* ADDED: TUTE28


### Changes
* Update: version
* In Win64 3 parameters added to OPENFILENAME: pvReserved,dwReserved,FlagsEx. Those parameters added to OPENFILENAME and OPENFILENAMEA
* FIX: Taskbar constants edited
* UPDATE: MASM64ApiWord.api common controls updated
* UPDATE: Cosmetic
* FIX: Wrong LIB64 parameters fixed in MASM64.ini
* FIX: WindowFromPoint proto fixed in MASM64ApiCall.api
* FIX: added SetClassLong 2nd parameter
* FIX: TUTE24
* UPDATE: MASM64.ini Windows DataTypes are updated
* UPDATE: According to [Directives Reference](https://learn.microsoft.com/en-us/cpp/assembler/masm/directives-reference?view=msvc-170) MASM64.ini updated
* UPDATE: [Symbols reference](https://learn.microsoft.com/en-us/cpp/assembler/masm/symbols-reference?view=msvc-170) checked and MASM64.ini updated

## [2022.09.01] - 01-09-2022
### Added
* New data types added to MASM64Type.api
* Modal and Modeless DialogApp Templates added.
* RGB macro snippet added
* Some handle values added to MASM64.ini (HICON, HCURSOR, HMENU)

### Changes
* Using [Windows Data Types][web-msdocs-windows-data-types] all data types inside MASM64Type.api checked and fixed
* Window Class Styles moved from MASM64Message.api to MASM64ApiWord.api

## [2022.08.25] - 25-08-2022
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