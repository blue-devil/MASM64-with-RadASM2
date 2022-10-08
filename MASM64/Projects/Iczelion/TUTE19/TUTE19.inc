;
; Unfortunately MASM64 SDK does not include TreeView constants, structure and
; needed stuff. CommCtrl.inc is unfortunatel insufficient for this tutorial
; That is why i have include this file
;

; _________________________________________________________________________
; MASM64 macros

    include \masm64\include64\win64.inc     ; main include file
    include \masm64\macros64\vasily.inc     ; main macro file
    include \masm64\macros64\macros64.inc   ; auxillary macro file

    STACKFRAME                              ; create a default stack frame

; _________________________________________________________________________
; include files

    include \masm64\include64\kernel32.inc
    include \masm64\include64\user32.inc
    include \masm64\include64\gdi32.inc
    include \masm64\include64\comctl32.inc

; _________________________________________________________________________
; libraries

    includelib \masm64\lib64\kernel32.lib
    includelib \masm64\lib64\user32.lib
    includelib \masm64\lib64\gdi32.lib
    includelib \masm64\lib64\comctl32.lib

; _________________________________________________________________________
; function prototypes

    WndProc             PROTO   :HWND,:UINT,:WPARAM,:LPARAM

; _________________________________________________________________________
; constant variables

.const
    IDB_TREE	        equ 4006
    ; Tree view next item types
    TVGN_ROOT	            EQU 0
    TVGN_NEXT	            EQU 1
    TVGN_PREVIOUS	        EQU 2
    TVGN_PARENT	            EQU 3
    TVGN_CHILD	            EQU 4
    TVGN_FIRSTVISIBLE       EQU 5
    TVGN_NEXTVISIBLE        EQU 6
    TVGN_PREVIOUSVISIBLE    EQU 7
    TVGN_DROPHILITE         EQU 8
    TVGN_CARET	            EQU 9
    
    ; Treeview Control styles
    TVS_HASBUTTONS	        EQU 0001h
    TVS_HASLINES	        EQU 0002h
    TVS_LINESATROOT         EQU 0004h
    TVS_EDITLABELS	        EQU 0008h
    TVS_DISABLEDRAGDROP     EQU 0010h
    TVS_SHOWSELALWAYS       EQU 0020h
    TVS_RTLREADING	        EQU 0040h
    TVS_NOTOOLTIPS	        EQU 0080h
    TVS_CHECKBOXES	        EQU 0100h
    TVS_TRACKSELECT         EQU 0200h
    TVS_SINGLEEXPAND        EQU 0400h
    TVS_INFOTIP             EQU 0800h
    TVS_FULLROWSELECT       EQU 1000h
    TVS_NOSCROLL	        EQU 2000h
    TVS_NONEVENHEIGHT       EQU 4000h
    
    TVI_ROOT                EQU 0FFFF0000h
    TVI_FIRST               EQU 0FFFF0001h
    TVI_LAST                EQU 0FFFF0002h
    TVI_SORT                EQU 0FFFF0003h
    
    TVIF_TEXT	            EQU 0001h
    TVIF_IMAGE	            EQU 0002h
    TVIF_PARAM	            EQU 0004h
    TVIF_STATE	            EQU 0008h
    TVIF_HANDLE	            EQU 0010h
    TVIF_SELECTEDIMAGE      EQU 0020h
    TVIF_CHILDREN	        EQU 0040h
    TVIF_DI_SETITEM         EQU 1000h

; _________________________________________________________________________
; initialized variables

.data
    ClassName           db "TreeViewWin64Class", 0    ; the name of our window class
    AppName             db "Tree View Demo x64", 0    ; the name of our window
    TreeViewClass 	    db "SysTreeView32",0
    Parent		        db "Parent Item",0
    Child1		        db "child1",0
    Child2		        db "child2",0
    DragMode            dd FALSE

; _________________________________________________________________________
; uninitialized variables

.data?
    CommandLine         LPSTR ?
    hInstance           HINSTANCE ?
    hIcon               HICON ?
    hCursor             HCURSOR ?
    hTreeView	        HANDLE ?
    hParent		        HANDLE ?
    hImageList	        HANDLE ?
    hDragImageList		HANDLE ?


TV_ITEM STRUCT
  imask		 DWORD ?,?
  hItem 	 QWORD ?
  state 	 DWORD ?
  stateMask	 DWORD ?
  pszText	 QWORD ?
  cchTextMax	 DWORD ?
  iImage	 DWORD ?
  iSelectedImage DWORD ?
  cChildren	 DWORD ?
  lParam	 DWORD ?
TV_ITEM ENDS

TV_ITEMEX STRUCT
  imask             DWORD      ?
  hItem             DWORD      ?
  state             DWORD      ?
  stateMask         DWORD      ?
  pszText           DWORD      ?
  cchTextMax        DWORD      ?
  iImage            DWORD      ?
  iSelectedImage    DWORD      ?
  cChildren         DWORD      ?
  lParam            DWORD      ?
  iIntegral         DWORD      ?
TV_ITEMEX ENDS

ITEMTYPE UNION
        itemex TVITEMEX <>
        item TVITEM <>
ITEMTYPE ENDS


TV_INSERTSTRUCT STRUCT
  hParent      QWORD ?
  hInsertAfter QWORD ?
  item	       TV_ITEM <>
TV_INSERTSTRUCT ENDS

TV_HITTESTINFO STRUCT
    pt        POINT <>
    flags     DWORD ?
    hItem     DWORD ?
TV_HITTESTINFO ENDS
