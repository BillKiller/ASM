data segment
	grade dw 1,2,3,4,5,6,6,8,8,10
	count equ ($-grade)/2
	rank dw 50 dup(?)
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
	mov cx,count
	loop1:
		mov bx,grade[si]
		call getCnt
		mov rank[si],dx
		add si,2
		loop loop1
	mov ax,4c00h
	int 21h
main endp
getCnt proc near
	push ax
	push bx
	push cx
	mov di,0
	mov cx,count
	mov dx,0
	loop2:
		cmp bx,grade[di]
		jna continue
		inc dx
	continue:	
	add di,2
	loop loop2
	inc dx
	pop cx
	pop bx
	pop ax
	ret
getCnt endp
code ends
end main
