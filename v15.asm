data segment
	max_num dw ?
	max_abs dw 0
	now_num dw ?
	M dw  1,2,3,4,-5,6,2,9,1,2
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
	mov cx,10
	xor bx,bx
	loop1:
			mov ax,M[bx]
			mov dx,ax
			call abss
			cmp dx,max_abs
			jb	next
			mov max_num,ax
			mov max_abs,dx
	next:
			add bx,2
			loop loop1
	mov bx,max_num
	call outdec
	mov ax,4c00h
	int 21h
main endp
outdec proc near
push ax
push bx
push cx
push dx
mov ax,bx
xor cx,cx
cmp bx ,0
jg loop2

mov dl,'-'
mov ah,02h
int 21h
mov ax,bx
neg ax
loop2:
		xor dx,dx
		mov bx,10
		div bx
		push dx
		inc cx
		cmp ax,0
		je loop3
		jmp loop2
loop3:
		pop dx
		add dx,30h
		call cout
		loop loop3
		pop dx
		pop cx
		pop bx
		pop ax
		ret
outdec endp
abss proc near
	cmp dx,0
	jg exit
	neg dx
	exit:
	ret
abss endp
cout proc near
	push ax
	mov ah,02h
	int 21h
	pop ax
	ret
cout endp
code ends
end main
