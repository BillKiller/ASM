data segment
	A dw 2
	B dw 1
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
	mov ax,A
	mov bx,B
	mov cx,ax
	mov dx,bx
	and cx,1
	and dx,1
	add cx,dx
	cmp cx,2
	je case2
	cmp cx,1
	je case1
	cmp cx,0
	je exit
case2:
	inc ax
	inc bx
	jmp exit	
case1:
	cmp dx,1
	jne exit
	xchg ax,bx
exit:
	mov A,ax
	mov B,bx
	mov ax,4c00h
	int 21h
main endp
code ends
end main
