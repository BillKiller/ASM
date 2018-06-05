data segment

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
	

	mov ax,1234h
	mov cl,4
	rol ax,cl

	mov bx,ax
	rol bx,cl
	and ax,0fH
	mov si,bx
	rol si,cl
	and bx,0fH
	mov dx,si
	rol dx,cl
	and si,0fH
	and dx,0fH
	mov cx,si

	mov ax,4c00h
	int 21h
main endp
code ends
end main
