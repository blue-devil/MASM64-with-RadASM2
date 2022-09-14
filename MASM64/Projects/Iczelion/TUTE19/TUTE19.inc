_mask equ <imask>

TVITEMW STRUCT
  _mask             DWORD  ?
  hItem             DWORD  ?
  state             DWORD  ?
  stateMask         DWORD  ?
  pszText           DWORD  ?
  cchTextMax        DWORD  ?
  iImage            DWORD  ?
  iSelectedImage    DWORD  ?
  cChildren         DWORD  ?
  lParam            DWORD  ?
TVITEMW ENDS

TVITEMA STRUCT
  _mask             DWORD  ?
  hItem             DWORD  ?
  state             DWORD  ?
  stateMask         DWORD  ?
  pszText           DWORD  ?
  cchTextMax        DWORD  ?
  iImage            DWORD  ?
  iSelectedImage    DWORD  ?
  cChildren         DWORD  ?
  lParam            DWORD  ?
TVITEMA ENDS

IFDEF __UNICODE__
  TVITEM equ <TVITEMW>
ELSE
  ;TVITEM equ <TVITEMA>
ENDIF

TV_ITEM  equ <TVITEM>
TV_ITEMA equ <TVITEM>
TV_ITEMW equ <TVITEM>

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
    hParent         DWORD ?  
    hInsertAfter    DWORD ?
                    ITEMTYPE <>
TV_INSERTSTRUCT ENDS

TV_HITTESTINFO STRUCT
    pt        POINT <>
    flags     DWORD ?
    hItem     DWORD ?
TV_HITTESTINFO ENDS