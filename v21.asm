data segment
	ARRAY DW 1,1,1
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
	mov ax,ARRAY
	mov bx,ARRAY+2
	mov cx,ARRAY+4
	xor dx,dx
	cmp ax,bx
	jne BC
	inc dx
BC:
	cmp bx,cx
	jne AC
	inc dx
AC:
	cmp ax,cx
	jne exit
	inc dx
	cmp dx,3
	jne exit
	mov dx,2
exit:
	add dx,30h
	mov ah,02h
	int 21h
	mov ax,4c00h
	int 21h
main endp
code ends
end main
