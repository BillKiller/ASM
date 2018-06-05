; by Tach  
  
data segment  
    Esc_key equ 1bh ;退出  
    win_ulc equ 30 ;左列  
    win_ulr equ 8   ;上行  
    win_lrc equ 50   ;右列  
    win_lrr equ 16   ;下行  
    win_width equ 20  ;宽度  
    board_shift equ 48h  ;光标上移  
    board_down equ 50h   ;光标下移  
    board_left equ 4Bh   ;光标左移  
    board_right equ 4Dh  ;光标右移  
    board_back equ 08h   ;退格键   
    string db "Tach's notepad!$"  
      
data ends  
  
stack segment  
    dw   128  dup(0)  
stack ends  
  
code segment  
    assume cs:code,ds:data
start:     
; set segment registers:  
    mov ax, data  
    mov ds, ax  
    mov es, ax  
      
 ;----------输出标题------------------   
    mov ah,2   
    mov dh,win_ulr-1  
    mov dl,win_ulc+2   
    mov bh,0   
    int 10h   
    lea dx, string  
    mov ah, 9  
    int 21h        ; output string at ds:dx   
  ;-------------------------------------  
 locate:  
 ;-----设置光标初始位置-----------  
    mov ah,2   
    mov dh,win_ulr  
    mov dl,win_ulc   
    push dx  
    mov bh,0   
    int 10h   
  ;--------------------------------    
    
  ;----初始化屏幕------------------  
    mov ah,6    
    mov ch,win_ulr  
    mov cl,win_ulc  
    mov dh,win_lrr  
    mov dl,win_lrc   
      
    mov bh,0F4h ;白底红字  
    int 10h   
    pop dx    
   ;----------------------------  
      
 get_char:  
    mov ah,0   ;16h 0号功能，ah中放扫描码，al中放ascii码  
    int 16h  
    cmp al,0   ;if 功能键 then al=0  
    je  K    
  ;-----利用ascii码判断-----------------------  
    cmp al,Esc_key  
    je far ptr exit  
    cmp al,0dh  
    je far ptr enter   
    cmp al,board_back  
    je far ptr back  
      
  ;---读取当前光标位置---------------   
    mov ah,3  
    mov bh,0  
    int 10h   
  ;---------------------    
    push dx   ;保护变量  
    cmp dl,win_lrc   ;输入字符时是否越过右列值  
    jge NK  
    jmp far ptr N   
NK:    
    inc dh  
    mov dl,win_ulc   
    push dx   
  ;--------------------  
    mov bh,0 ;重新设置光标位置  
    mov ah,2  
    int 10h    
  ;-------------------  
  N:  
    cmp  dh,win_lrr  
    jge  roll    ;是否越过下界，上卷  
 Next:  
    mov dl,al   ;输出输入的字符  
    mov ah,2  
    int 21h   
    pop dx   
  
    jmp far ptr get_char     
  ;-------对功能键（扫描码）的处理---------------  
 K:    
    cmp ah,board_shift    
    jz shift   
    cmp ah,board_down  
    je down   
    cmp ah,board_left  
    je left  
    cmp ah,board_right   
    je right     
    jmp far ptr  get_char  
;-------------上卷一行---------------------  
 roll:  
    mov ah,6   
    push ax  
    mov al,1  
    mov ch,win_ulr  
    mov cl,win_ulc  
    mov dh,win_lrr  
    mov dl,win_lrc  
    mov bh,0F4h  
    int 10h   
    pop ax   
    pop dx  
  
    cmp dh,win_lrr  
    jbe KK   
        
    dec dh    
      
 KK:    
    dec dh   ;上卷之后，dh随之自减  
    mov bh,0  
    mov ah,2  
    int 10h   
    push dx  
    jmp far ptr far Next  
 ;---------------------------------  
 ;---------处理换行--------------------    
 enter:  
    mov ah,3  
    mov bh,0  
    int 10h   
    inc dh  
    mov dl,win_ulc    
    mov bh,0  
    mov ah,2  
    int 10h  
    jmp far ptr get_char  
 ;--------------------------------  
 ;---------光标上移-----------------------  
 shift:   
    mov ah,3  
    mov bh,0  
    int 10h  
    dec dh   
    cmp dh,win_ulr  
    jge S    
    inc dh  
 S:  
    mov bh,0  
    mov ah,2  
    int 10h  
    jmp far ptr far get_char   
 ;------------光标下移------------------------  
 down:   
    mov ah,3  
    mov bh,0  
    int 10h  
    inc dh   
    cmp dh,win_lrr  
    jbe D   
    dec dh  
 D:  
    mov bh,0  
    mov ah,2  
    int 10h  
    jmp far ptr get_char  
 ;------------------------------------  
 ;-------------光标左移--------------------     
 left:  
    mov ah,3  
    mov bh,0  
    int 10h  
    dec dl   
    cmp dl,win_ulc  
    jge L  
    inc dl   
    dec dh   
    cmp dh,win_ulr  
    jge L  
    inc dh  
 L:  
    mov bh,0  
    mov ah,2  
    int 10h  
    jmp far ptr get_char  
;-----------------------------  
;------------光标右移-----------------   
 right:    
    mov ah,3  
    mov bh,0  
    int 10h  
    inc dl  
    cmp dl,win_lrc  
    jbe R  
    dec dl   
    inc dh  
    cmp dh,win_lrr   
    jbe R  
    dec dh  
 R:  
    mov bh,0  
    mov ah,2  
    int 10h  
    jmp far ptr get_char   
 ;-------------------------  
 ;---------退格键---------------     
 back:  
    mov ah,3  
    mov bh,0  
    int 10h   
      
    dec dl    
    cmp dl,win_ulc  
    jge B  
    mov dl,win_lrc  
    dec dh   
    cmp dh,win_ulr  
    jge B  
    inc dh   
  B:   
    mov bh,0  
    mov ah,2  
    int 10h   
      
    push dx   
    mov dl,20h  
    mov ah,2  
    int 21h   
    pop dx  
      
    mov bh,0  
    mov ah,2  
    int 10h  
      
    jmp far ptr get_char   
 ;-----------退出程序------------------------    
 exit:  
    mov ax, 4c00h ; exit to operating system.  
    int 21h      
code ends  
  
end start ; set entry point and stop the assembler.  