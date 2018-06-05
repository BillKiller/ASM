data segment
	x  db 1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,-1,-1
	p  db  20 dup(?)
	n  db 20 dup(?)
	str1 db 'x_Num1:$'
	str2 db 'n_Num2:$'
	cr db 0dh,0ah,'$'
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
	mov cx,20
	xor bx,bx
	xor di,di
	xor si,si
	xor dx,dx
	lea bx,x
	lea di,p
	lea si,n
	loop3:
		mov ax,[bx]
		inc bx
		cmp ax,0
		je e
		jg G
	L:
		mov [di],ax
		inc dl
		inc di
		jmp e
	G:
		mov [si],ax
		inc dh
		inc si
	e:
	loop loop3

	xor bx,bx
	mov cx,dx
	lea dx, str1
	call puts
	mov bl,ch
	call outputD
	lea dx,cr
	call puts

	lea dx,str2
	call puts
	mov bl,cl
	call outputD

	mov ax,4c00h
	int 21h
main endp

outputD proc near
	push ax
	push bx
	push cx
	push dx
	mov ax,bx
	xor dx,dx
	mov cx,0
loop1:
	mov bx,10	
	div bx
	push dx
	xor dx,dx
	inc cx
	cmp ax,0
	jne loop1
loop2:
	pop dx
	add dx,30h
	call cout
	loop loop2
	pop dx
	pop cx
	pop bx
	pop ax
	ret
outputD endp
cin proc near
	mov ah,01h
	int 21h
	ret
cin endp

cout proc near
	push ax
	mov ah,02h
	int 21h
	pop ax
	ret
cout endp

puts proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
puts endp
code ends
end main
