;*********************************************************
; Bubble Demo 
;
;  Written in Assembly x64
; 
;  By Toby Opferman  2017
;
;*********************************************************


;*********************************************************
; Assembly Options
;*********************************************************


;*********************************************************
; Included Files
;*********************************************************
include ksamd64.inc
include demovariables.inc
include master.inc
include vpal_public.inc
include font_public.inc

extern LocalAlloc:proc
extern LocalFree:proc

PARAMFRAME struct
    Param1         dq ?
    Param2         dq ?
    Param3         dq ?
    Param4         dq ?
    Param5         dq ?
    Param6         dq ?
PARAMFRAME ends

SAVEREGSFRAME struct
    SaveRdi        dq ?
    SaveRsi        dq ?
    SaveRbx        dq ?
    SaveR10        dq ?
    SaveR11        dq ?
    SaveR12        dq ?
    SaveR13        dq ?
SAVEREGSFRAME ends

FUNC_PARAMS struct
    ReturnAddress  dq ?
    Param1         dq ?
    Param2         dq ?
    Param3         dq ?
    Param4         dq ?
    Param5         dq ?
    Param6         dq ?
    Param7         dq ?
FUNC_PARAMS ends

BUBBLE_DEMO_STRUCTURE struct
   ParameterFrame PARAMFRAME      <?>
   SaveFrame      SAVEREGSFRAME   <?>
BUBBLE_DEMO_STRUCTURE ends

BUBBLE_DEMO_STRUCTURE_FUNC struct
   ParameterFrame PARAMFRAME      <?>
   SaveFrame      SAVEREGSFRAME   <?>
   FuncParams     FUNC_PARAMS     <?>
BUBBLE_DEMO_STRUCTURE_FUNC ends


BUBBLE_MOVER struct
   X          dq ?
   Y          dq ?
   VelX       dq ?
   VelY       dq ?
   Radius     dq ?
   Color      dw ?
BUBBLE_MOVER  ends

public Bubble_Init
public Bubble_Demo
public Bubble_Free

extern time:proc
extern srand:proc
extern rand:proc

MAX_COLORS EQU <256+256+256+256+256+256>
.DATA

DoubleBuffer   dq ?
VirtualPallete dq ?
FrameCountDown dd 2800
Red            db 0h
Blue           db 0h
Green          db 0h
Bubbles        BUBBLE_MOVER 100 DUP(<0>)


.CODE

;*********************************************************
;   Bubble_Init
;
;        Parameters: Master Context
;
;        Return Value: TRUE / FALSE
;
;
;*********************************************************  
NESTED_ENTRY Bubble_Init, _TEXT$00
 alloc_stack(SIZEOF BUBBLE_DEMO_STRUCTURE)
 save_reg rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi
 save_reg rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx
 save_reg rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi
 save_reg r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12
.ENDPROLOG 
  MOV RSI, RCX

  MOV [VirtualPallete], 0

  MOV RAX,  MASTER_DEMO_STRUCT.ScreenHeight[RSI]
  MOV R9,  MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MUL R9
  MOV RDX, RAX
  SHL RDX, 1    ; Turn Buffer into WORD values
  MOV ECX, 040h ; LMEM_ZEROINIT
  CALL LocalAlloc
  MOV [DoubleBuffer], RAX
  TEST RAX, RAX
  JZ @PalInit_Failed

  MOV RCX, MAX_COLORS
  CALL VPal_Create
  TEST RAX, RAX
  JZ @PalInit_Failed

  MOV [VirtualPallete], RAX

  XOR R12, R12

@PopulatePallete:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  INC [Blue]

  INC R12
  CMP R12, 256
  JB @PopulatePallete

  DEC [Blue]

@PopulatePallete2:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  INC [Red]

  INC R12
  CMP R12, 256+256
  JB @PopulatePallete2

  DEC [RED]
  @PopulatePallete3:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  INC [Green]

  INC R12
  CMP R12, 256+256+256
  JB @PopulatePallete3

  DEC [Green]

 @PopulatePallete4:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  DEC [Blue]

  INC R12
  CMP R12, 256+256+256+256
  JB @PopulatePallete4
  MOV [Blue], 0
 @PopulatePallete5:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  DEC [Red]

  INC R12
  CMP R12, 256+256+256+256+256
  JB @PopulatePallete5

  MOV [Red], 0

 @PopulatePallete6:

  XOR EAX, EAX

 ; Red
  MOV AL, BYTE PTR [Red]  
  SHL EAX, 16

  ; Green
  MOV AL, BYTE PTR [Green]
  SHL AX, 8

  ; Blue
  MOV AL, BYTE PTR [Blue]

  MOV R8, RAX
  MOV RDX, R12
  MOV RCX, [VirtualPallete]
  CALL VPal_SetColorIndex

  DEC [Green]
  INC [Red]

  INC R12
  CMP R12, 256+256+256+256+256+256
  JB @PopulatePallete6


  XOR R12, R12
  LEA R10, [Bubbles]
@PlotCircles:
  MOV RDX, R10
  MOV RCX, RSI
  CALL Bubble_DrawRandomCircle
  INC R12
  ADD R10, SIZE BUBBLE_MOVER
  CMP R12, 100
  JB @PlotCircles
 
  MOV RSI, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
  MOV RDI, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
  MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]
  MOV r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12[RSP]
  ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
  MOV EAX, 1
  RET

@PalInit_Failed:
  MOV RSI, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
  MOV RDI, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
  MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]
  MOV r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12[RSP]
  ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
  XOR RAX, RAX
  RET
NESTED_END Bubble_Init, _TEXT$00



;*********************************************************
;  Bubble_DrawRandomCircle
;
;        Parameters: Master Context, Bubble Structure
;
;       
;
;
;*********************************************************  
NESTED_ENTRY Bubble_DrawRandomCircle, _TEXT$00
 alloc_stack(SIZEOF BUBBLE_DEMO_STRUCTURE)
 save_reg rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi
 save_reg rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi
 save_reg rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx
 save_reg r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10
 save_reg r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11
 save_reg r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12
 save_reg r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13
.ENDPROLOG
  MOV RSI, RCX
  MOV RDI, RDX

  CALL rand
  MOV RCX, 700
  DIV RCX
  MOV R10, RDX ; Y
  ADD R10, 10
  MOV BUBBLE_MOVER.Y[RDI], R10

  CALL rand
  MOV RCX, 1000
  DIV RCX
  MOV R11, RDX ; X
  ADD R11, 10
  MOV BUBBLE_MOVER.X[RDI], R11

  CALL rand

  MOV R13, 1024
  SUB R13, R11
  CMP R13, R11
  JB @NextCompareY

  MOV R13, R11

@NextCompareY:
  MOV RCX, 768
  SUB RCX, R10
  CMP RCX, R10
  JB @NextCompareXandY
  MOV RCX, R10

@NextCompareXandY:
  CMP R13, RCX
  JB @GetRaidus

  MOV R13, RCX
@GetRaidus:
  CALL rand
  CMP R13, 200
  JB @PerformRadius
  MOV R13, 200
@PerformRadius:
  DIV R13
  MOV R12, RDX


  CMP R12, 0
  JA @GetColors

  INC R12

@GetColors:
  MOV BUBBLE_MOVER.Radius[RDI], R12
  CALL rand
  MOV RCX, MAX_COLORS
  DIV RCX
   
  MOV BUBBLE_MOVER.Color[RDI], DX

  CALL Rand

  MOV RCX, 2
  DIV RCX
  INC RDX
  MOV BUBBLE_MOVER.VelX[RDI], RDX
  CALL Rand
  TEST RAX, 1
  JE @VelocityY
  NEG BUBBLE_MOVER.VelX[RDI]

@VelocityY:
  CALL Rand

  MOV RCX, 2
  DIV RCX
  INC RDX
  MOV BUBBLE_MOVER.VelY[RDI], RDX
  CALL Rand
  TEST RAX, 1
  JE @DrawBubble
  NEG BUBBLE_MOVER.VelY[RDI]

@DrawBubble:

  MOV DX, BUBBLE_MOVER.Color[RDI]
  MOV BUBBLE_DEMO_STRUCTURE.ParameterFrame.Param5[RSP], RDX ; Random Color
  MOV R9, R12
  MOV R8, R10
  MOV RDX, R11
  MOV RCX, RSI
  CALL Bubble_DrawCircle   

   MOV rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
   MOV rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
   MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]

   MOV r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10[RSP]
   MOV r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11[RSP]
   MOV r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12[RSP]
   MOV r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13[RSP]

   ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
   RET
NESTED_END Bubble_DrawRandomCircle, _TEXT$00


;*********************************************************
;  Bubble_Demo
;
;        Parameters: Master Context
;
;       
;
;
;*********************************************************  
NESTED_ENTRY Bubble_Demo, _TEXT$00
 alloc_stack(SIZEOF BUBBLE_DEMO_STRUCTURE)
 save_reg rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi
 save_reg rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi
 save_reg rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx
 save_reg r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10
 save_reg r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11
 save_reg r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12
 save_reg r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13

.ENDPROLOG 
  MOV RDI, RCX

  ;
  ; Update the screen with the buffer
  ;  
  MOV RSI, MASTER_DEMO_STRUCT.VideoBuffer[RDI]
  MOV r13, [DoubleBuffer]

  XOR R9, R9
  XOR r12, r12

@FillScreen:
      ;
      ; Get the Virtual Pallete Index for the pixel on the screen
      ;
      XOR EDX, EDX
      MOV DX, WORD PTR [r13] ; Get Virtual Pallete Index
	;  MOV WORD PTR [r13], 0  ; Clear Screen
	  XOR EAX, EAX
	  CMP DX, 0
	  JE @PlotAsZero
      MOV RCX, [VirtualPallete]
      CALL VPal_GetColorIndex 
@PlotAsZero:
      ; Plot Pixel
      MOV DWORD PTR [RSI], EAX

      ; Increment to the next location
      ADD RSI, 4
      Add R13, 2
  
      INC r12

      CMP r12, MASTER_DEMO_STRUCT.ScreenWidth[RDI]
      JB @FillScreen

   ; Calcluate Pitch
   MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RDI]
   SHL RAX, 2
   MOV EBX, MASTER_DEMO_STRUCT.Pitch[RDI]
   SUB RBX, RAX
   ADD RSI, RBX

   ; Screen Height Increment

   XOR r12, r12
   INC R9

   CMP R9, MASTER_DEMO_STRUCT.ScreenHeight[RDI]
   JB @FillScreen

   ;
   ; Rotate the pallete by 1.  This is the only animation being performed.
   ;
   MOV RDX, 5
   MOV RCX, [VirtualPallete]
   CALL  VPal_Rotate
   
  XOR R12, R12
  LEA R10, [Bubbles]


@PlotCircles:
  MOV RCX, BUBBLE_MOVER.VelX[R10]
  ADD BUBBLE_MOVER.X[R10], RCX
  MOV RDX, BUBBLE_MOVER.Radius[R10]
  ADD RDX, BUBBLE_MOVER.X[R10]

  CMP RDX, 1022
  JL @NextTest

  MOV RDX, 990
  SUB RDX, BUBBLE_MOVER.Radius[R10]
  MOV BUBBLE_MOVER.X[R10], RDX
  NEG BUBBLE_MOVER.VelX[R10]
  JMP @NextTest_Y

@NextTest:
  MOV RDX, BUBBLE_MOVER.X[R10]
  SUB RDX, BUBBLE_MOVER.Radius[R10]

  CMP RDX, 10
  JG @NextTest_Y
  
  MOV RDX, BUBBLE_MOVER.Radius[R10]
  ADD RDX, 20
  MOV BUBBLE_MOVER.X[R10], RDX
  NEG BUBBLE_MOVER.VelX[R10]
  

@NextTest_Y:


  MOV RCX, BUBBLE_MOVER.VelY[R10]
  ADD BUBBLE_MOVER.Y[R10], RCX
  MOV RDX, BUBBLE_MOVER.Radius[R10]
  ADD RDX, BUBBLE_MOVER.Y[R10]

  CMP RDX, 766
  JL @NextY_Test

  MOV RDX, 690
  SUB RDX, BUBBLE_MOVER.Radius[R10]
  MOV BUBBLE_MOVER.Y[R10], RDX
  NEG BUBBLE_MOVER.VelY[R10]

  JMP @DoneTesting
@NextY_Test:
  MOV RDX, BUBBLE_MOVER.Y[R10]
  SUB RDX, BUBBLE_MOVER.Radius[R10]

  CMP RDX, 10
  JG @DoneTesting

  MOV RDX, BUBBLE_MOVER.Radius[R10]
  ADD RDX, 20
  MOV BUBBLE_MOVER.Y[R10], RDX
  NEG BUBBLE_MOVER.VelY[R10]

@DoneTesting:

  MOV DX, BUBBLE_MOVER.Color[R10]
  MOV BUBBLE_DEMO_STRUCTURE.ParameterFrame.Param5[RSP], RDX 
  MOV R9, BUBBLE_MOVER.Radius[R10]
  MOV R8, BUBBLE_MOVER.Y[R10]
  MOV RDX, BUBBLE_MOVER.X[R10]
  MOV RCX, RDI
  CALL Bubble_DrawCircle   

  INC R12
  ADD R10, SIZE BUBBLE_MOVER
  CMP R12, 100
  JB @PlotCircles

@DemoExit:
    
   MOV rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
   MOV rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
   MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]

   MOV r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10[RSP]
   MOV r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11[RSP]
   MOV r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12[RSP]
   MOV r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13[RSP]

   ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
  
   DEC [FrameCountDown]
   MOV EAX, [FrameCountDown]
   RET
NESTED_END Bubble_Demo, _TEXT$00



;*********************************************************
;  Bubble_Free
;
;        Parameters: Master Context
;
;       
;
;
;*********************************************************  
NESTED_ENTRY Bubble_Free, _TEXT$00
 alloc_stack(SIZEOF BUBBLE_DEMO_STRUCTURE)
 save_reg rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi
 save_reg rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi
  save_reg rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx
.ENDPROLOG 

 MOV RCX, [VirtualPallete]
 CALL VPal_Free

  MOV RCX, [DoubleBuffer]
  TEST RCX, RCX
  JZ @SkipFreeingMem

  CALL LocalFree
 @SkipFreeingMem:
  MOV rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
  MOV rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
  MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]

  ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
  RET
NESTED_END Bubble_Free, _TEXT$00






;*********************************************************
;  Bubble_DrawCircle
;
;        Parameters: Master Context, X, Y, Radius, Color
;
;       
;
;
;*********************************************************  
NESTED_ENTRY Bubble_DrawCircle, _TEXT$00
 alloc_stack(SIZEOF BUBBLE_DEMO_STRUCTURE)
 save_reg rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi
 save_reg rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi
 save_reg rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx
 save_reg r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10
 save_reg r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11
 save_reg r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12
 save_reg r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13
.ENDPROLOG 
 
 MOV RSI, RCX
 MOV R10, R9 ; Radius
 MOV R11, R8  ; Y Center
 MOV R12, RDX ; X Center
 
 XOR RDI, RDI ; y Increment
 MOV RBX, R10
 DEC RBX      ; x Increment

 MOV BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param1[RSP], 1 ; Change in X
 MOV BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param2[RSP], 1 ; Change in Y
 
 MOV R13, 1
 MOV RAX, R10
 SHL RAX, 1
 SUB R13, RAX   ; Error Correction

@PlotQudrant_Pixels:
;
; Quadrant 1.1
;
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  ADD RCX, RDI
  MUL RCX
  ADD RAX, R12
  ADD RAX, RBX
  SHL RAX, 1
  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

 ;
 ; Quadrant 1.2
 ; 
 @PlotQudrant_1_2_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  ADD RCX, RBX
  MUL RCX
  ADD RAX, R12
  ADD RAX, RDI
  SHL RAX, 1
  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

 ;
 ; Quadrant 2.1
 ; 
 @PlotQudrant_2_1_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  ADD RCX, RBX
  MUL RCX
  ADD RAX, R12
  SUB RAX, RDI
  SHL RAX, 1
  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX


 ;
 ; Quadrant 2.2
 ; 
 @PlotQudrant_2_2_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  ADD RCX, RDI
  MUL RCX

  ADD RAX, R12
  SUB RAX, RBX
  SHL RAX, 1

  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

 ;
 ; Quadrant 3.1
 ; 
 @PlotQudrant_3_1_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  SUB RCX, RDI
  MUL RCX

  ADD RAX, R12
  SUB RAX, RBX
  SHL RAX, 1

  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

 ;
 ; Quadrant 3.2
 ; 
 @PlotQudrant_3_2_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  SUB RCX, RBX
  MUL RCX

  ADD RAX, R12
  SUB RAX, RDI
  SHL RAX, 1

  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX


 ;
 ; Quadrant 4.1
 ; 
 @PlotQudrant_4_1_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  SUB RCX, RBX
  MUL RCX

  ADD RAX, R12
  ADD RAX, RDI
  SHL RAX, 1

  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

 ;
 ; Quadrant 4.2
 ; 
  @PlotQudrant_4_2_Pixel:
  MOV RAX, MASTER_DEMO_STRUCT.ScreenWidth[RSI]
  MOV RCX, R11
  SUB RCX, RDI
  MUL RCX

  ADD RAX, R12
  ADD RAX, RBX
  SHL RAX, 1

  ADD RAX,[DoubleBuffer]
  MOV RCX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param5[RSP]
  MOV WORD PTR [RAX], CX

  ;
  ; Error Checks
  ;
  CMP R13, 0
  JG @Check_Second_Error
  INC RDI
  ADD R13, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param2[RSP]
  ADD BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param2[RSP], 2
  
 @Check_Second_Error:  
  CMP R13, 0
  JLE @Check_Loop_Condition

  DEC RBX
  ADD BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param1[RSP], 2
  MOV RAX, R10
  SHL RAX, 1
  NEG RAX
  ADD RAX, BUBBLE_DEMO_STRUCTURE_FUNC.FuncParams.Param1[RSP]
  ADD R13, RAX
  
@Check_Loop_Condition:
  CMP RBX, RDI
  JGE @PlotQudrant_Pixels
  
  MOV rdi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRdi[RSP]
  MOV rsi, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRsi[RSP]
  MOV rbx, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveRbx[RSP]
  MOV r10, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR10[RSP]
  MOV r11, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR11[RSP]
  MOV r12, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR12[RSP]
  MOV r13, BUBBLE_DEMO_STRUCTURE.SaveFrame.SaveR13[RSP]
  ADD RSP, SIZE BUBBLE_DEMO_STRUCTURE
  RET
NESTED_END Bubble_DrawCircle, _TEXT$00





END