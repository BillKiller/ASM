data segment
	hehe db 'heheheheheh',0dh,0ah,'$'
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
fin:
	call cin
	cmp al,'0'
	jb fin
	cmp al,'9'
	ja fin
	sub al,30h
	mov cl,al
	xor ch,ch
	loop1:
		mov dl,07
		call cout
		loop loop1
	mov ax,4c00h
	int 21h
main endp
cin proc near
	mov ah,01h
	int 21h
	ret
cin endp
cout proc near
	mov ah,02h
	int 21h
	ret
cout endp
debug proc near
	push dx
	lea dx,hehe
	mov ah,09h
	int 21h
	pop dx
	ret
debug endp
code ends
end main
