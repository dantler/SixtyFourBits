;*********************************************************
; Demo Entry Code
;
;  Written in Assembly x64
; 
;  By Toby Opferman  2/24/2010-2017
;
;*********************************************************



;*********************************************************
; Included Files
;*********************************************************
include ksamd64.inc
include init_public.inc
include worm_public.inc
include star_public.inc
include plasma_public.inc
include Fire_public.inc
include  bubble_public.inc

extern ExitProcess:proc

;*********************************************************
; Structures
;*********************************************************
PARAMFRAME struct
    Param1         dq ?
    Param2         dq ?
    Param3         dq ?
    Param4         dq ?
PARAMFRAME ends

extern MessageBoxA:proc

WINMAIN_FRAME struct
   ParamFrameArea        PARAMFRAME       <?>
   InitializationStruct  INIT_DEMO_STRUCT <?>
WINMAIN_FRAME ends

.DATA

;*********************************************************
; Global Data
;*********************************************************

GlobalDemoStructure  dq Fire_Init
                     dq Fire_Demo
                     dq Fire_Free

                     dq StarDemo_Init
                     dq StarDemo_Demo
                     dq StarDemo_Free

                     dq WormHole_Init
                     dq WormHole_Demo
                     dq WormHole_Free

					 dq Bubble_Init
                     dq Bubble_Demo
                     dq Bubble_Free

                     dq PlasmaDemo_Init
                     dq PlasmaDemo_Demo
                     dq PlasmaDemo_Free
;
; End Tag
;
                     dq 0
                     dq 0
                     dq 0

pszWindowClass       db 'TemplateClassWindow', 0
pszWindowTitle       db 'Template Demo', 0

pszMsgCpt       db 'x64 Assembly Demo', 0
pszMsgTxt       db 'Do you want to view in full screen?', 0

.CODE

;*********************************************************
; WinMain
;
;  The main entry point to the application.
;
;
;
;*********************************************************
NESTED_ENTRY WinMain, _TEXT$00
  alloc_stack(SIZEOF WINMAIN_FRAME)
.ENDPROLOG 
  
  ;
  ; TODO: The resolution is hard coded, should it be input or 
  ;       should it change to use the plaform's current resolution.
  ;
  MOV WINMAIN_FRAME.InitializationStruct.BitsPerPixel[RSP], 20h
  MOV WINMAIN_FRAME.InitializationStruct.ScreenWidth[RSP],  1024
  MOV WINMAIN_FRAME.InitializationStruct.ScreenHeight[RSP], 768

  LEA RCX, [pszWindowTitle]
  MOV WINMAIN_FRAME.InitializationStruct.pszWindowTitle[RSP], RCX
  LEA RCX, [pszWindowClass]
  MOV WINMAIN_FRAME.InitializationStruct.pszWindowClass[RSP], RCX
  LEA RCX, [GlobalDemoStructure]    
  MOV WINMAIN_FRAME.InitializationStruct.GlobalDemoStructure[RSP], RCX

  MOV R9, 24h ; MB_YESNO | MB_ICONQUESTION
  LEA R8, [pszMsgCpt]
  LEA RDX, [pszMsgTxt]
  XOR RCX, RCX
  CALL MessageBoxA
  CMP RAX, 6
  SETE AL
  MOV WINMAIN_FRAME.InitializationStruct.FullScreen[RSP], RAX

  LEA RCX, WINMAIN_FRAME.InitializationStruct[RSP]
  CALL Initialization_Demo

@Entry_Exit:
  XOR RCX, RCX
  CALL ExitProcess

NESTED_END WinMain, _TEXT$00

END