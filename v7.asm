datas segment
	DATA dw 100 dup(?)
datas ends
stack segment stack
	dw 30h dup(?)
	top label word
stack ends

code segment
	assume cs:code,ss:stack,ds:datas
main proc far
	mov ax,datas
	mov ds,ax
	mov ax,stack
	mov ss,ax
	mov ch,8
	mov bx,0
	loop1:
		push cx
		mov cx,2
		rol ax,cl
		mov dx,ax
		and dx,03h
		test dx,3
		jne e
		inc bx
		e:loop loop1
	mov ax,4c00h
	int 21h
main endp
code ends
end main
