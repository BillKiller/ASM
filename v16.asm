datas segment
	data dw 100h dup(?)
	sumH dw ? 
	sumL dw ?
	i dw 0
	cr db 0dh,0ah,'$'
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
	lea sp,top
	mov cx,100h
	xor si,si
	xor ax,ax
	xor bx,bx
	loop1:
		mov ax,data[si]
		cwd 
		add bx,ax
		adc di,dx
		add si,2
		loop loop1
	mov ax,bx
	mov dx,di
	mov cx,100h
	idiv cx
	xor si,si
	xor bx,bx
	loop2:
		cmp ax,data[si]
		jnl continue
		inc bx
		continue:
		add si,2
		loop loop2
	exit:
	mov ax,4c00h
	int 21h
main endp
code ends
end main
