data segment
	HANDLE DW ?
	TEMP_HANDLE DW ?

	OtherName db 255 dup(0)
	OtherNameBuf db 255,?,255 dup(0)

	;FileName db 'in.txt',0
	FileName db 100 dup(0)
	FileBackup db 'out.txt',0
	
	BUF DB 10000 DUP(0)
	BUFLEN DW 0
	editBuf db 	10000 dup(0)

	cmdBUF db 1000 dup(0)
	ERROR_err db "Program error!!!$"
	OPEN_ERR db "Open File failed Error$"
	Save_ERR db "Sava File Failed error$"
	FileExsited_Err db "File exsited error$"
	read_Err db "File read error$"
	creat_err db "create error!$"
	write_err db "file write error$"
	commmand_err db 'wrong command$'
	quit_err db 'save before you quit$'
 	cr db 0dh,0ah,'$'
	isEnd DW 0
	isExit dw 0
	blank db '                    $'
	esc_key equ 81h
	win_ulc equ 0
	win_ulr  equ 0
	win_lrc equ 79
	win_lrr equ 23
	win_width equ 79

	baseLine dw 0
	;keyboard
	KEYCODE_W db 48h
	KEYCODE_S db 50h
	KEYCODE_A db 4bh
	KEYCODE_D db 4dh
	KEYCODE_BS db 08h
	KEYCODE_DEL DB 53H
	KEYCODE_TAB db 0fh
	KEYCODE_ESC db 01h
	KEYCODE_F1 db 3bh
	KEYCODE_I db 17h
	;mode
	MODE_NOW DW ?
	MODE_NORMAL dw 0
	MODE_INSERT dw 1
	MODE_CODE dw 2
	MODE_VISIAL dw 3
	MODE_EXIT DW 4
	string_insert db '- - insert - -','$'
	string_normal db '- - normal - -','$'
	;state
	STATE_COMMAND dw 0
	W_COMMAND dw 0
	Q_command dw 0
	WQ_COMMAND DW 0
	WRONG_COMMAND DW 0
	isChange dw 0
	hasName dw 0

	err_open dw 0
	err_read dw 0
	err_save dw 0
	err_create dw 0
	;
	op db ?,?,'$'
	FileNameBuf db 255 dup(0)
	;

data ends

stack segment stack
	dw 6000h dup(?)
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

	xor bx,bx
	xor dx,dx
	mov cx,10
	mov BUFLEN,0
	call getFileName
	call init
	call clear_screen
	call read
	call Running
	call Save
	call closeFile

	mov ax,4c00h
	int 21h
main endp

MODE_COMMAND proc near
	push ax
	push bx
	push cx
	push dx
	call getCursor
	push dx
	mov dh,24
	mov dl,1
	call setCursor
	call clear_Line
	call printMouse
	mov bx,0
loop_mode_cmd:
	mov ah,0
	int 16h
	cmp ah,KEYCODE_ESC
	je exit_mode_cmd
	cmp al,0dH
	je mode_cmd_cr
	cmp al,08h
	je mode_cmd_bs
	mov cmdBUF[bx],al
	mov dl,al
	call putchar
	inc bx
	jmp loop_mode_cmd
mode_cmd_bs:
	cmp bx,0
	je loop_mode_cmd
	mov cmdBUF[bx],0
	dec bx
	call backspace
	jmp loop_mode_cmd
mode_cmd_cr:
	mov cmdBUF[bx],' '
	call compire
	call sloveCompire
exit_mode_cmd:
	pop dx
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
MODE_COMMAND endp
sloveCompire proc near
	push ax
	push bx
	push cx
	push dx
	cmp W_COMMAND,1
	je SC_W_COMMAND
	cmp Q_command,1
	je SC_Q_COMMAND
	cmp  WQ_COMMAND,1
	je SC_WQ_COMMAND
	cmp WRONG_COMMAND,1
	je SC_WA_COMMAND
SC_W_COMMAND:
	call save
	jmp exit_slove
SC_Q_COMMAND:
	call quitProgram
	jmp exit_slove
SC_WQ_COMMAND:
	call save
	call quitProgram
	jmp exit_slove
SC_WA_COMMAND:
	lea dx,commmand_err
	call Information
	jmp exit_slove
exit_slove:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
sloveCompire endp

init proc near
	push ax
	push bx
	push cx
	push dx
	push si
	cmp hasName,0
	je exit_init
	call Open
exit_init:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
init endp

compire proc near
	;无入口参数
	;出口参数
	;W_COMMAND 
	;Q_command 
	;WQ_COMMAND 
	;WRONG_COMMAND 
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx,-1
loop_compire_bs:
	inc bx
	cmp cmdBUF[bx],' '
	je loop_compire_bs
	xor si,si
loop_compire_op:
	cmp cmdBUF[bx],' '
	je loop_compire_mid_bs
	cmp cmdBUF[bx],0
	je compire_op
	mov al,cmdBUF[bx]
	cmp si,2
	jae wrong_compire
	mov op[si],al
	inc bx
	inc si
	jmp loop_compire_op
loop_compire_mid_bs:
	inc bx
	cmp cmdBUF[bx],0
	je compire_op
	cmp cmdBUF[bx],' '
	je loop_compire_mid_bs
	mov si,0
loop_compire_fileName:
	cmp cmdBUF[bx],' '
	je  compire_op
	cmp cmdBUF[bx],0
	je compire_op
	mov al,cmdBUF[bx]
	mov FileNameBuf[si],al
	inc si
	inc bx
	jmp loop_compire_fileName
wrong_compire:
	mov WQ_COMMAND,0
	mov W_COMMAND,0
	mov Q_command,0
	mov WRONG_COMMAND,1
	jmp exit_compire
compire_op:
	mov FileNameBuf[si],'$'
	xor si,si
	mov al,op[si]
	cmp al,'w'
	je compire_is_w
	cmp al,'q'
	je compire_is_q
	jmp wrong_compire
compire_is_w:
	mov al,op[si+1]
	cmp al,'q'
	je compire_is_wq
	cmp al,0
	jne wrong_compire
	mov WQ_COMMAND,0
	mov W_COMMAND,1
	mov Q_command,0
	mov WRONG_COMMAND,0
	jmp exit_compire
compire_is_q:
	mov al,op[si+1]
	cmp al,0
	jne wrong_compire
	mov WQ_COMMAND,0
	mov W_COMMAND,0
	mov Q_command,1
	mov WRONG_COMMAND,0
	jmp exit_compire
compire_is_wq:
	mov WQ_COMMAND,1
	mov W_COMMAND,0
	mov Q_command,0
	mov WRONG_COMMAND,0
	jmp exit_compire
exit_compire:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
compire endp

Running proc near
	push ax
	push bx
	push cx
	push dx
	xor bx,bx
	mov dx,03
	call setCursor
loop_running:
	mov bx,MODE_NOW
	cmp bx,MODE_NORMAL
	je running_mode_normal
	cmp bx,MODE_INSERT
	je running_mode_insert
	cmp bx,MODE_EXIT
	je running_mode_exit
running_mode_normal:
	call normalKeyevent
	jmp loop_running
running_mode_insert:
	cmp isChange,1
	je running_next
	call create
running_next:
	mov isChange,1
	call keyevent
	jmp loop_running
running_mode_exit:

	jmp exit_running
exit_running:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
Running endp

normalKeyevent proc near
	call showNumber
	call testPOS
	mov ah,0
	int 16h
	call getCursor
	cmp ah,KEYCODE_I
	je nr_is_insert
	cmp ah,KEYCODE_W
	je nr_is_up
	cmp ah,KEYCODE_S
	je nr_is_down
	cmp ah,KEYCODE_A
	je nr_is_left
	cmp ah,KEYCODE_D
	je nr_is_right
	cmp ah,KEYCODE_F1
	je nr_is_shfit
	jmp nr_key_exit
nr_is_insert:
	mov MODE_NOW,1
	jmp nr_key_exit
nr_is_up:
	call keyUP
	jmp nr_key_exit
nr_is_down:
	call KeyDown 
	jmp nr_key_exit
nr_is_left:
	call keyLeft
	jmp nr_key_exit
nr_is_right:
	call keyRight
	jmp nr_key_exit
nr_is_shfit:
	call MODE_COMMAND
	jmp nr_key_exit
nr_key_exit:
	ret
normalKeyevent endp


keyevent proc near
	call showNumber
	call testPOS
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
	cmp ah,KEYCODE_DEL
	je is_del
	cmp ah,KEYCODE_TAB
	je is_TAb
	cmp ah,KEYCODE_ESC
	je is_esc
 	jmp isOther
is_esc:
	mov MODE_NOW,0
	jmp key_exit
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
is_del:
	call delLine
	mov dl,3
	call setCursor
	jmp key_exit
is_Tab:
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
	cmp dl,3
	jne bs_back
	cmp dh,0
	jne	if_keybs
	cmp si,3
	je bs_back
	call scrollDown
	mov dh,1
	if_keybs:
	call backchar
	call getRealCursor
	cmp buf[si],0
	jne bs_exit
	call delLine
	call line_end
	jmp bs_exit
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
	mov dl,3
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
	mov dl,3
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
	mov dl,3
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
	cmp dl,3
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
	mov err_open,1
	call create
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
	mov isChange,1
	mov hasName,1
	jmp crt_exit
createrr:
	mov isEnd,1
	lea dx,creat_err
	call Information
crt_exit:
	ret
Create endp

backspace proc near
	push ax
	push dx
	mov dl,08
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	mov dl,08
	mov ah,02h
	int 21h
	pop dx
	pop ax
	ret
backspace endp
read proc near
	push ax
	push bx
	push cx
	push dx
	xor dx,dx
	readRow:
		mov dl,3
		;mov bx,233
		;call output
		call setCursor
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
	mov err_read,1
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
	cmp isChange,0
	je exit_save
	call movHead
	xor dh,dh
	mov ax,baseLine
	push ax
	mov baseLine,0
	loopRow:
		mov dl,3
	loopcol:
		call getPos
		cmp buf[si],0
		jne DoSave
		cmp dl,3
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
	pop ax
	mov baseLine,ax
	mov isChange,0
	call closeFile
	exit_save:
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
Information proc near
	push ax
	push bx
	push cx
	push dx
	call getCursor
	mov bx,dx
	mov dh,24
	mov dl,3
	call setCursor
	pop dx
	call errm
	mov dx,bx
	call setCursor
	pop cx
	pop bx
	pop ax
	ret
Information endp

quitProgram proc near
	cmp isChange,1
	je exit_wrong
	mov MODE_NOW,4
	JMP Exit_quit
exit_wrong:
	lea dx,quit_err
	call Information
Exit_quit:
	ret
quitProgram endp

closeFile proc near
	mov ah,3eh
	mov bx,HANDLE
	int 21h
	ret
closeFile endp

errm proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
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
	cmp bx,9
	ja decLoop
	call printZero
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
	mov dl,3
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
	cmp dh,23
	je viewEnd
	mov dl,3
	inc dh
	call setCursor
	jmp NL_exit
viewEnd:
	mov dl,3
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
	
	;call getRealCursor
	;mov buf[si],0
	call delChar
	;call printLine
	;inc dh
	;call printLine
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
	push cx
	push dx

	mov ah,02h
	mov bh,0
	int 10h
	pop dx
	pop cx
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
		cmp buf[si],0
		jne end_line
		inc cx
		dec dl
		cmp cx,75
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

testPOS proc near
	;入口参数 NONE
	;在24行0列输出当前光标位置
	push ax
	push bx
	push cx
	push dx
	push si
	call getCursor
	push dx
	mov ax,dx
	push ax
	mov dh,24
	mov dl,0
	call setCursor
	call clear_Line
	mov dh,24
	mov dl,0
	call setCursor
	mov ax,MODE_NOW
	cmp ax,MODE_INSERT
	jne normal
	lea dx,string_insert
	jmp showInformation 
normal:
	lea dx,string_normal
	jmp showInformation
showInformation:
	call errm
	mov dh,24
	mov dl,60
	call setCursor
	xor bh,bh
	pop ax
	mov bl,ah
	inc bl
	call output
	call printWave
	mov bl,al
	sub bl,2
	call output
	pop dx
	call setCursor
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
testPOS endp
findLastLine proc near
	;无入口参数
	;出口参数dh代表最后一行位置
	push ax
	push bx
	push cx
	push si
	mov ax,baseLine
	mov baseLine,0
	mov dh,124
	mov dl,3
	loop_find:
		call getPos
		cmp buf[si],0
		jne find_exit
		dec dh
		jnz loop_find
	find_exit:
	mov baseLine,ax
	pop si
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
	push dx
	mov ah,6
	mov al,0
	mov bh,1eh
	mov ch,dh
	mov cl,0
	mov dl,79
	int 10h

	;locate cursor
	mov dx,0
	mov bx,0
	mov ah,2
	int 10h
	;restore registers
	pop dx
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clear_Line endp

delchar proc near
	push ax
	push bx
	push cx
	push dx
	call getRealCursor
	cmp buf[si],0dh
	je endofLine
	cmp buf[si],0
	jne NotNone 
	cmp dl,3
	je exit_delchar
endofLine:
	mov buf[si-1],0
	mov buf[si],0
	dec dl
NotNone:
	;del an item in list
	loop_delchar:
		mov al,buf[si+1]
		mov buf[si],al
		cmp buf[si],0dH
		je exit_delchar
		cmp buf[si],0
		je exit_delchar
		inc si
		jmp loop_delchar
exit_delchar:
	call clear_Line
	call printLine
exit_end_here:
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delchar endp

delChar1 proc near
	push ax
	push bx
	push cx
	push dx
	call getCursor
	push dx
	call getRealCursor
	mov bx,si
	cmp buf[si],0
	je delchar_end
loop_delchar1:
		mov al,buf[si+1]
		mov buf[si],al
		cmp buf[si],0dH
		je exit_delchar
		cmp buf[si],0
		je exit_delchar
		inc si
		jmp loop_delchar1
delchar_end:
	cmp dl,0
	je exit_delchar
	mov buf[si-1],0
	call clear_Line
	call printLine
	pop dx
	dec dl
	jmp exit_delchar2
exit_delchar1:
	inc si
	mov buf[si],0
	call clear_Line
	call printLine
	pop dx
exit_delchar2:
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delChar1 endp
delLine proc near
	;入口参数dh代表要删除的那一行
	push ax
	push bx
	push cx
	push dx
	call getCursor
	push dx
	mov ax,dx
	call findLastLine
	mov cl,dh
	sub cl,ah
	mov dh,ah
	xor ch,ch
	push cx
	cmp cl,0
	jge if_del_Zero
	mov cl,0
if_del_Zero:
	inc cl 
loop_delLine:
	push cx
	mov cx,80
	xor dl,dl
loop_del_col:
	call getPos
	mov bl,buf[si+80]
	mov buf[si],bl
	inc dl
	loop loop_del_col
	call clear_Line
	call printLine
	inc dh
	pop cx
	loop loop_delLine
	pop cx
	pop dx
	cmp cl,0
	jne back_line
	cmp dh,0
	je back_line
	dec dh
back_line:
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delLine endp
showNumber proc near
	push ax
	push bx
	push cx
	push dx
	call getCursor
	push dx
	mov dx,0
	call setCursor
	mov bx,baseLine
	inc bx
	mov cx,25
	call findLastLine
	mov al,dh
	inc al
	mov dh,0
	mov dl,0
loop_showNumber:
	cmp bl,al
	jbe ifNumber
	call printWave
	JMP SN_NEXT
ifNumber:
	call output
SN_NEXT:
	inc dh		
	xor dl,dl
	call printSpace
	call setCursor
	inc bx
	loop loop_showNumber
	pop dx
	call setCursor
	pop dx
	pop cx
	pop bx
	pop ax
	ret
showNumber endp
printSpace proc near
	push ax
	push dx
	mov ah,02h
	mov dl,' '
	int 21h
	pop dx
	pop ax
	ret
printSpace endp

printZero proc near
	push ax
	push dx
	mov ah,02h
	mov dl,'0'
	int 21h
	pop dx
	pop ax
	ret
printZero endp

printWave proc near
	push ax
	push dx
	mov dl,'~'
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	pop dx
	pop ax
	ret
printWave endp
printMouse proc near
	push ax
	push dx
	mov dl,':'
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	pop dx
	pop ax
	ret
printMouse endp

getFileName proc near
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx,80h
	mov cl,es:[bx]
	cmp cl,0
	je exit_getFile_nofind
	mov hasName,1
	inc bx
	loop_getName_bs:
		mov al,es:[bx]
		mov dl,al
		cmp al,20h
		jne loop_getName
		inc bx
		loop loop_getName_bs
	jmp exit_getFile
	xor si,si
	loop_getName:
		mov al,es:[bx]
		cmp al,0dh
		je exit_getFile
		mov FileName[si],al
		inc si
		inc bx
		loop loop_getName
	exit_getFile:
	mov FileName[si],0
	mov FileName[si+1],'$'
 	exit_getFile_nofind:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
getFileName endp
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
