data segment
	x dw 1234
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

	mov ax,x
	mov bx,10
	mov cx,0
loop1: 
	xor dx,dx
	div bx
	push dx
	inc cx
	cmp ax,0
	jne loop1
loop2:
	pop dx
	cmp dx,10
	jb l2
	add dx,07h
l2:add dx,30h
	call print
	loop loop2
	mov ax,4c00h
	int 21h
main endp
print proc near
	mov ah,02h
	int 21h
	ret 
print endp
code ends
end main