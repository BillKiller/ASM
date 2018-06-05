data segment
	HANDLE DW ?
	TEMP_HANDLE DW ?

	OtherName db 255 dup(0)
	OtherNameBuf db 255,?,255 dup(0)

	FileName db 'in.txt',0
	FileBackup db 'out.txt',0
	FileNameBuf db 255,?,255 dup(0)
	BUF DB 10000 DUP(0)
	BUFLEN DW 0
	editBuf db 	10000 dup(0)
	ERROR_err db "Program error!!!$"
	OPEN_ERR db "Open File failed Error$"
	Save_ERR db "Sava File Failed error$"
	FileExsited_Err db "File exsited error$"
	read_Err db "File read error$"
	creat_err db "create error!$"
	write_err db "file write error$"
 	cr db 0dh,0ah,'$'
	isEnd DW 0
	isExit dw 0
	blank db '                    $'
	esc_key equ 1bh
	win_ulc equ 0
	win_ulr  equ 0
	win_lrc equ 79
	win_lrr equ 24
	win_width equ 79

	baseLine dw 0
	;keyboard
	KEYCODE_W db 48h
	KEYCODE_S db 50h
	KEYCODE_A db 4bh
	KEYCODE_D db 4dh
	KEYCODE_BS db 08h
data ends

stack segment stack

	dw 30h dup(?)
	top label word
stack ends

code segment
	assume cs:code,ss:stack,ds:data
main proc far
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	lea sp,top
	call Open
	xor bx,bx
	xor dx,dx
	mov cx,10
	mov BUFLEN,0
	call clear_screen
	call read
	call create
	call edit
	call Save
	call closeFile
	mov ax,4c00h
	int 21h
main endp


keyevent proc near
	call testCode
	mov ah,0
	int 16h
	call getCursor
	cmp al,0dh
	je is_cr
	cmp ah,KEYCODE_W
	je is_up
	cmp ah,KEYCODE_S
	je is_down
	cmp ah,KEYCODE_A
	je is_left
	cmp ah,KEYCODE_D
	je is_right
	cmp al,KEYCODE_BS
	je is_BS
 	jmp isOther
is_cr:
	call getRealCursor
	mov buf[si],0dh
	call next_line
	jmp key_exit
is_up:
	call keyUP
	jmp key_exit
is_down:
	call KeyDown 
	jmp key_exit
is_left:
	call keyLeft
	jmp key_exit
is_right:
	call keyRight
	jmp key_exit
is_BS:
	call KeyBS
	jmp key_exit
isOther:
	cmp dl,78
	jne NotnewLine
	call getRealCursor
	mov buf[si],0dh
	call next_line
	NotnewLine:
	call getRealCursor
	mov buf[si],al
	mov dl,al
	call putchar
key_exit:
	;call testCode
	ret
keyevent endp

KeyBS proc near
	push ax
	push bx
	push cx
	push dx
	push si
	call getCursor
	call getPos
	cmp si,0
	je bs_exit
	cmp dl,0
	jne bs_back
	cmp dh,0
	jne	if_keybs
	call scrollDown
	mov dh,1
	if_keybs:
	;call delLine
	call line_end
	bs_back:
	call backchar
	bs_exit:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
KeyBS endp
keyUP proc near
	call getCursor
	cmp dh,0;view move	
	jne UpMove
	cmp baseLine,0
	je exitUP
	call scrollDown
	inc dh
UpMove:
	mov ax,dx
	dec dh
	xor dl,dl
	call getPos
	call find_end
	cmp dl,al
	jb doUpMove
	xchg dl,al
doUpMove:
	call setCursor
exitUP:
	ret
keyUP endp

KeyDown proc near
	call getCursor
	push dx
	cmp dh,24;view move	
	jne keyMove
	mov dh,25
	mov dl,0
	call getPos
	cmp buf[si],0
	je exitDown
	mov dh,24
	call scrollUp
	dec dh
keyMove:
	mov ax,dx
	inc dh
	xor dl,dl
	call getPos
	cmp buf[si],0
	je exitDown
	call find_end
	cmp dl,al
	jb doMove
	xchg dl,al
doMove:
	call setCursor
exitDown:
	pop dx
	ret
KeyDown endp


keyLeft proc near
	call getCursor
	cmp dl,0
	je exitLeft
	dec dl
	call setCursor
	exitLeft:
	ret
keyLeft endp

keyRight proc near
	call getCursor
	cmp dl,78
	jae exitRight
	call getPos
	cmp buf[si],0dh
	je exitRight
	cmp buf[si],0
	je exitRight
	inc dl
	call setCursor
	exitRight:
	ret
keyRight endp
Open proc near
	mov ah,3dh
	mov al,02
	lea dx,FileName
	int 21h
	jc openerr
	mov HANDLE,ax
	jmp openEnd
	ret
openerr:
	mov isEnd,1
	lea dx,open_err
	call errm
openEnd:
	ret
Open endp

Create proc near
	mov ah,3ch
	mov cx,00
	lea dx,FileName
	int 21h
	jc createrr
	mov HANDLE,ax
	jmp crt_exit
createrr:
	mov isEnd,1
	lea dx,creat_err
	call errm
crt_exit:
	ret
Create endp

read proc near
	push ax
	push bx
	push cx
	push dx
	xor dx,dx
	readRow:
		mov dl,0
		;mov bx,233
		;call output
		readCol:
		call getPos
		call readByte
		cmp isEnd,1
		je exitRead
		push dx
		mov dl,buf[si]
		cmp dh,24
		jb printChar
		je if_read_24
		ja notprint
		if_read_24:
		cmp buf[si],0DH
		je notprint
		cmp buf[si],0ah
		je notprint
		printChar:
		call putchar
		notprint:
		pop dx
		cmp buf[si],0dh
		je readNextRow
		inc dl
		cmp dl,80
		je readNextRow
		jmp readCol
	readNextRow:
		call cout
		inc dh
		jmp readRow
	exitRead:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
read endp

readByte proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,3fh
	mov bx,HANDLE
	mov cx,1
	lea dx,buf[si]
	mov isEnd,0
	int 21h
	jc readerr
	cmp ax,0
	je readEnd
	pop dx
	pop cx
	pop bx
	pop ax
	ret
readerr:
	lea dx,read_Err
	call errm
readEnd:
	mov isEnd,1
exit:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
readByte endp
save proc near
	push ax
	push bx
	push cx
	push dx
	xor dx,dx
	call movHead
	xor dh,dh
	mov baseLine,0
	loopRow:
		mov dl,0
	loopcol:
		call getPos
		cmp buf[si],0
		jne DoSave
		cmp dl,0
		je lastLine
		jmp nextRow
	DoSave:
		call SaveByte
		inc dl
		cmp buf[si],0dh 
		je loopcol
		cmp dl,80
		jne loopcol
	nextRow:
		inc dh
		jmp loopRow
	lastLine:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
save endp
SaveByte proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,40h
	mov bx,HANDLE
	mov cx,1
	lea dx,buf[si]
	int 21h
	jc writerror
	cmp ax,1
	jne writeEnd
	pop dx
	pop cx
	pop bx
	pop ax
	ret
writerror:
	lea dx,write_err
	call errm
writeEnd:
	mov isEnd,1
	pop dx
	pop cx
	pop bx
	pop ax
	ret
SaveByte endp
clear_screen proc near
	push ax
	push bx
	push cx
	push dx
	;clear_screen
	mov ah,6
	mov al,0
	mov bh,1eh
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	int 10h

	;locate cursor
	mov dx,0
	mov bx,0
	mov ah,2
	int 10h
	;restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clear_screen endp

edit proc near
	xor bx,bx
	mov dx,0
	call setCursor
	edit_loop:
		call keyevent
		call getCursor
		cmp al,'#'
		jne Continue
		mov isExit,1
	Continue:
		cmp isExit,1
		je exit_edit
		jmp edit_loop
	exit_edit:
	mov BUFLEN,100
	ret
edit endp
SaveAs proc near
	ret
SaveAs endp

quitProgram proc near
	ret
quitProgram endp

closeFile proc near
	mov ah,3eh
	mov bx,HANDLE
	int 21h
	ret
closeFile endp

errm proc near
	mov ah,09h
	int 21h
	ret
errm endp

setNumber proc near
	push cx
	push dx
	push bx
	push ax
	pop ax
	pop bx
	pop dx	
	pop cx
	ret
setNumber endp
output proc near
	push ax
	push bx
	push cx
	push dx
	mov ax,bx
	xor cx,cx
	decLoop:
		xor dx,dx
		mov bx,10
		div bx
		push dx
		inc cx
		cmp ax,0
		je decOut
		jmp decLoop
	decOut:
		pop dx
		add dx,30h
		call putchar
		loop decOut
	pop dx
	pop cx
	pop bx
	pop ax
	ret
output endp
printLine proc near
	;入口参数dh
	;输出dh行对应的数据
	call getCursor
	push dx
	mov dl,0
	call setCursor
	loop_PrL:
		call getPos
		cmp buf[si],0
		je exit_prl
		cmp buf[si],0DH
		je exit_prl
		push dx
		mov dl,buf[si]
		call putchar
		pop dx
		inc dl
		jmp loop_PrL
	exit_prl:
	pop dx
	call setCursor
	ret
printLine endp
putchar proc near
	push ax
	push dx
	mov ah,02h
	int 21h
	pop dx
	pop ax
	ret
putchar endp
getchar proc near
	mov ah,01h
	int 21h
	ret
getchar endp

next_line proc near
	push ax
	push dx
	call getCursor
	cmp dh,24
	je viewEnd
	mov dl,0
	inc dh
	call setCursor
	jmp NL_exit
viewEnd:
	mov dl,0
	call setCursor
	call next_line_scroll
NL_exit:
	pop dx
	pop ax
	ret
next_line endp

line_end proc near
	;read cursor locatation
	push ax
	push bx
	push cx
	push dx
	push si
	xor bx,bx
	xor si,si
	xor cx,cx
	call getCursor
	cmp dh,0
	je line_exit
	dec dh
	call find_end
	call setCursor
	line_exit:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
line_end endp
backchar proc near
	push dx
	push ax
	mov dl,08
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	mov dl,08
	mov ah,02h
	int 21h
	call getRealCursor
	mov buf[si],0
	pop ax
	pop dx
	ret
backchar endp
next_line_scroll proc near
	push ax
	push bx
	push cx
	push dx
	inc baseLine
	mov ah,6
	mov al,1
	mov ch,win_ulr
	mov cl,win_ulc
	mov dh,win_lrr
	mov dl,win_lrc
	mov bh,1eh
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
next_line_scroll endp
scrollUp proc near
	push ax
	push bx
	push cx
	push dx
	push dx
	inc baseLine
	mov ah,6
	mov al,1
	mov ch,win_ulr
	mov cl,win_ulc
	mov dh,win_lrr
	mov dl,win_lrc
	mov bh,1eh
	int 10h
	mov dh,24
	call printLine
	pop dx
	mov dh,23
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
scrollUp endp

scrollDown proc near
	push ax
	push bx
	push cx
	push dx
	push dx
	dec baseLine
	mov ah,7
	mov al,1
	mov ch,win_ulc
	mov cl,win_ulc
	mov dh,win_lrr
	mov dl,win_lrc
	mov bh,1eh
	int 10h
	mov dh,0
	call printLine
	pop dx
	mov dh,1
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
scrollDown endp

getCursor proc near
	push ax
	push bx
	mov ah,03h
	mov bh,0
	int 10h
	pop bx
	pop ax
	ret
getCursor endp

movHead proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,42h
	mov al,00
	mov bx,HANDLE
	mov cx,00
	mov dx,00
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
movHead endp
setCursor proc near
	push ax
	push bx
	mov ah,02h
	mov bh,0
	int 10h
	pop bx
	pop ax
	ret
setCursor endp

getRealCursor proc near
	call getCursor
	call getPos
	ret
getRealCursor endp 

getPos proc near
	;通过dh,dl得到二维坐标的地址
	push ax
	push bx
	push cx
	push dx
	push di
	xor si,si
	xor bx,bx
	mov bl,dh
	mov si,dx
	and si,0ffh
	add bx,baseLine
	mov ax,bx
	mov bx,80
	mul bx
	add si,ax
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
getPos endp

find_end proc near
	;in: dh,dl
	;out: dl
	mov dl,78
	xor cx,cx
	line_loop:
		call getPos
		cmp buf[si],0DH
		je end_line
		inc cx
		dec dl
		cmp cx,78
		jne line_loop
	end_line:
	ret
find_end endp
testCode proc near
	;入口参数 al
	;在24行0列输出al的字符
	push ax
	push bx
	push cx
	push dx
	push si

	call getCursor
	push dx
	call getRealCursor
	mov dh,24
	mov dl,0
	call setCursor
	lea dx,blank
	call errm
	mov dh,24
	mov dl,0
	call setCursor
	mov bl,buf[si]
	xor bh,bh
	call output
	mov dl,'|'
	call putchar
	mov bx,si
	call output
	pop dx
	call setCursor
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
testCode endp
findLastLine proc near
	;无入口参数
	;出口参数dh代表最后一行位置
	push ax
	push bx
	push cx
	mov ax,baseLine
	mov baseLine,0
	mov dh,124
	mov dl,0
	loop_find:
		call getPos
		cmp buf[si],0
		jne find_exit
		dec dh
		jnz loop_find
	find_exit:
	mov baseLine,ax
	pop cx
	pop bx
	pop ax
	ret
findLastLine endp

clear_Line proc near
	;入口参数dh代表要清空哪一行
	push ax
	push bx
	push cx
	push dx
	;clear_screen
	mov ah,6
	mov al,0
	mov bh,1eh
	mov ch,dh
	mov cl,0
	inc dh
	mov dl,79
	int 10h

	;locate cursor
	mov dx,0
	mov bx,0
	mov ah,2
	int 10h
	;restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clear_Line endp
delLine proc near
	;入口参数dh代表要删除的那一行
	push ax
	push bx
	push cx
	push dx
	mov dl,dh
	mov ax,baseLine
	push ax
	add dl,al
	mov baseLine,0
	call findLastLine
	xchg dh,dl
	mov ax,dx
	;dh 是要删除的那一行
	;dl 是最后的一行
	;ah 
	loop_del:
		cmp dh,al ;如果现在的行数等于最后一行
		je exit_del
		mov cx,80
		xor dl,dl
	loop_del_col:
		call getPos
		mov bx,si
		add si,80
		;覆盖数据
		push ax
		mov al,buf[si]
		mov buf[bx],al
		push dx
		mov dx,ax
		call putchar
		pop dx
		pop ax
		inc dl
		loop loop_del_col
		call printLine
		inc dh
		jmp loop_del
	exit_del:
	mov cx,80
	mov dl,0
	loop_del2:
		call getPos
		mov buf[si],0
		inc dl
		loop loop_del2
	pop ax
	mov baseLine,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delLine endp
cout proc near
	push ax
	push dx
	lea dx,cr
	mov ah,09h
	int 21h
	pop dx
	pop ax
	ret
cout endp
code ends
end main
