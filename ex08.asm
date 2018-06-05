
stack segment
	dw 30 dup(?)
	top label word
stack ends
code segment
assume cs:code,ds:data,ss:stack
main proc far
start:
	mov ax,data
	mov ds,ax

	mov ax,stack
	mov ss,ax
	loop1:
		mov ah,01h
		int 21h
		xor ah,ah
		push ax
	loop loop1
	
	mov cx,3
	loop2:
		pop dx
		mov ah,02h
		int 21h
		loop loop2

	mov ax,4c00h
	int 21h
main endp
code ends
end start