;小写变大写
data segment
string db 255 dup(?)
CR  db 0ah,0dh,'$'
data ends

code segment
assume cs:code,ds:data
main proc far
start:
	mov ax,data
	mov ds,ax
	mov al,'$'
	lea bx,string
	add bx,3
	mov dl,'$'
	mov [bx],dl
	dec bx
	mov cx,3
	lp1:
		mov ah,01h
		int 21h
		mov [bx],al
		dec bx
	loop lp1

	lea dx,string
	mov ah,09h
	int 21h

	mov ax,4c00h
	int 21h

main endp
code ends
end start
