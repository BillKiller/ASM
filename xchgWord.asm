data segment
	PATH db '1.txt',0
	HANDLE DW ?
	openMeg db '*****open error*****$'
	readMeg db '*****read error*****$'
	writeMeg db '*****writerror*****$'
	buf dw ?
	isEnd dw 0
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
	call openFile
	loop1:
		call readFile
		cmp isEnd,1
		je finish
		call move
		call xchgWord
		call writeFile
		jmp loop1
	finish:
	mov ax,4c00h
	int 21h
main endp
openFile proc near
	mov ah,3dh
	mov al,02
	lea dx,PATH
	int 21h
	jc openerr
	mov HANDLE,ax
	jmp openEnd
	ret
openerr:
	mov isEnd,1
	lea dx,openMeg
	call errm
openEnd:
	ret
openFile endp

readFile proc near
	mov ah,3fh
	mov bx,HANDLE
	mov cx,1
	lea dx,buf
	mov isEnd,0
	int 21h
	jc readerr
	cmp ax,0
	je readEnd
	ret
readerr:
	lea dx,readMeg
	call errm
readEnd:
	mov isEnd,1
exit:
	ret
readFile endp

move proc near
	mov bx,HANDLE
	mov cx,0
	mov dx,-1
	cmp dx,0
	jge Point
	not cx
	Point:
	mov al,1
	mov ah,42h
	int 21h
	jc moveErr
	RET
moveErr:
	mov isEnd,1
	RET
move endp
closeFile proc near
	mov ah,3eh
	mov bx,HANDLE
	int 21h
closeFile endp
writeFile proc near
	mov ah,40h
	mov bx,HANDLE
	mov cx,1
	lea dx,buf
	int 21h
	jc writerror
	cmp ax,1
	jne writeEnd
	ret
writerror:
	lea dx,writeMeg
	call errm
writeEnd:
	mov isEnd,1
	ret
writeFile endp

xchgWord proc near
	push ax
	mov ax,buf
	cmp buf,'A'
	jb exitt
	cmp buf,'Z'
	jna uper
	cmp buf,'a'
	jb exitt
	cmp buf,'z'
	jna lower
	jmp exitt
lower:
	sub ax,32
	jmp exitt
uper:
	add ax,32
	jmp exitt
exitt:
	mov buf,ax
	pop ax
	ret
xchgWord endp
errm proc near
	mov ah,09h
	int 21h
	ret
errm endp
code ends
end main
