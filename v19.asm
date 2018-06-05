data segment
	A dw 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	B dw 1,2,3,5,7,11,13,15,17,19,23,29,31,33,37,39,43,47,51,53
	H dw 0ffffh
	C dw 20 dup(?)
	isOK db 0
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
	mov cx,15
	xor si,si
	mov dx,0
	loop1:
		mov bx,A[si]
		call isContain
		cmp isOK,1
		jne next
		mov C[di],bx
		add di,2
		next:
		add si,2
		loop loop1
	mov ax,4c00h
	int 21h
main endp
isContain proc near
	push ax
	push bx
	push cx
	push di
	mov cx,20
	xor di,di
	mov isOK,0
	loop2:
		cmp bx,B[di]
		jne continue
		mov isOK,1
	continue:
		add di,2
	loop loop2
	pop di
	pop cx
	pop bx
	pop ax
	ret
isContain endp
code ends
end main
