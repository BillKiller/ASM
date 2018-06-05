data segment
	mem dw 0,0,1,2,3,4,5,6,7,8
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
	mov si,0
	mov cx,100
	mov dx,0
	mov bx,10
	mov di,0
	loop1:
		mov ax,mem[si]
		cmp ax,0
		jne continue
		call delet
		inc dx
		dec bx
	continue:
		add si,2
		inc di
		loop loop1
	mov si,99
	loop3:		
			mov ax,0
			mov mem[si],ax
			sub si,2
			loop loop3
	mov ax,4c00h
	int 21h
main endp
delet proc near
	push ax
	push bx
	push cx
	push dx
	push si
	mov cx,di
	loop2:
		mov ax,[si+2]
		mov [si],ax
		cmp cx,bx
		je exit 
	exit:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
delet
code ends
end main
