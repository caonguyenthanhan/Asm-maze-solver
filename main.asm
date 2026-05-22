.MODEL SMALL
.STACK 100h

.DATA
    MAX_COLS EQU 20

    ; Me cung luu bang mang 1 chieu: index = y * cols + x.
    cols   DW 10
    rows   DW 10

    maze   DB '1111111111'
           DB '1S00000001'
           DB '1111111101'
           DB '1000000101'
           DB '1011110101'
           DB '1010000101'
           DB '1010111101'
           DB '1010000001'
           DB '10111111E1'
           DB '1111111111'

    currX  DW 0
    currY  DW 0

    ; Duong di demo chi de test phan animation cua SV1.
    pathX  DB 2,3,4,5,6,7,8,8,8,8,8,8,8,8
    pathY  DB 1,1,1,1,1,1,1,2,3,4,5,6,7,8
    PATH_LEN EQU 14

    msgTitle DB 'Demo SV1: ve me cung va animation$'
    msgDone  DB 'Xong. Nhan phim bat ky de thoat.$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX

    CALL ClearScreen

    MOV DL, 0
    MOV DH, 12
    CALL GotoXY
    LEA DX, msgTitle
    MOV AH, 09h
    INT 21h

    CALL DrawFullMaze
    CALL DemoAnimation

    MOV DL, 0
    MOV DH, 14
    CALL GotoXY
    LEA DX, msgDone
    MOV AH, 09h
    INT 21h

    ; Cho nhan phim bat ky roi moi thoat ve DOS.
    MOV AH, 07h
    INT 21h

    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ---------------------------------------------------------
; ClearScreen
; Xoa man hinh bang cach dat lai text mode 03h.
; ---------------------------------------------------------
ClearScreen PROC
    PUSH AX

    MOV AH, 00h
    MOV AL, 03h
    INT 10h

    POP AX
    RET
ClearScreen ENDP

; ---------------------------------------------------------
; GotoXY
; Dau vao: DL = cot X, DH = hang Y
; ---------------------------------------------------------
GotoXY PROC
    PUSH AX
    PUSH BX

    MOV AH, 02h
    MOV BH, 0
    INT 10h

    POP BX
    POP AX
    RET
GotoXY ENDP

; ---------------------------------------------------------
; DrawChar
; Dau vao: DL = X, DH = Y, AL = ky tu can ve
; Ve 1 ky tu khong delay. Dung cho DrawFullMaze.
; ---------------------------------------------------------
DrawChar PROC
    PUSH AX
    PUSH DX

    CALL GotoXY

    POP DX
    POP AX
    PUSH AX
    PUSH DX

    MOV DL, AL
    MOV AH, 02h
    INT 21h

    POP DX
    POP AX
    RET
DrawChar ENDP

; ---------------------------------------------------------
; DrawCell
; Dau vao: DL = X, DH = Y, AL = ky tu can ve
; Ve 1 o va delay de tao animation.
; Day la ham chinh de SV3 goi khi chay DFS.
; ---------------------------------------------------------
DrawCell PROC
    CALL DrawChar
    CALL Delay
    RET
DrawCell ENDP

; ---------------------------------------------------------
; Delay
; Delay bang vong lap de tuong thich emu8086/DOSBox.
; Neu debug bang single step thi se thay lap o DelayInner rat nhieu lan.
; Khi test binh thuong hay bam Run/Emulate, khong bam single step tung lenh.
; ---------------------------------------------------------
Delay PROC
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CX, 0001h
DelayOuter:
    MOV DX, 0800h
DelayInner:
    DEC DX
    JNZ DelayInner
    LOOP DelayOuter

    POP DX
    POP CX
    POP AX
    RET
Delay ENDP

; ---------------------------------------------------------
; DrawFullMaze
; Dau vao: maze, rows, cols trong .DATA
; Ve toan bo me cung, khong delay tung o.
; ---------------------------------------------------------
DrawFullMaze PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV SI, OFFSET maze
    MOV currY, 0

DrawRows:
    MOV AX, currY
    CMP AX, rows
    JAE DrawMazeDone

    MOV currX, 0

DrawCols:
    MOV AX, currX
    CMP AX, cols
    JAE NextRow

    MOV DL, BYTE PTR currX
    MOV DH, BYTE PTR currY
    MOV AL, [SI]
    CALL DrawChar

    INC SI
    INC currX
    JMP DrawCols

NextRow:
    INC currY
    JMP DrawRows

DrawMazeDone:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
DrawFullMaze ENDP

; ---------------------------------------------------------
; DemoAnimation
; Test tam cho SV1. Sau nay SV3 se thay bang DFS.
; ---------------------------------------------------------
DemoAnimation PROC
    PUSH AX
    PUSH DX
    PUSH SI

    MOV SI, 0

DemoLoop:
    CMP SI, PATH_LEN
    JAE DemoDone

    MOV DL, pathX[SI]
    MOV DH, pathY[SI]

    CMP SI, PATH_LEN - 1
    JE DrawEndMark

    MOV AL, '.'
    JMP DrawDemoCell

DrawEndMark:
    MOV AL, '*'

DrawDemoCell:
    CALL DrawCell
    INC SI
    JMP DemoLoop

DemoDone:
    POP SI
    POP DX
    POP AX
    RET
DemoAnimation ENDP

END MAIN
