data segment
	mem db ?,?,?,?
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
	mov cx,4
	mov si,3
	mov ax,2a49h
	loop1:
		push cx
		mov cl,4
		rol ax,cl
		mov bx,ax
		and bx,0fh
		cmp bx,0ah
		jb isdight
		add bx,37h
		jmp continue
	isdight:
		add bx,30h
	continue:
		mov mem[si],bl
		dec si
		pop cx
		loop loop1
	mov ax,4c00h
	int 21h
main endp
code ends
end main
