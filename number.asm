data segment
	baseLine dw 0
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
	call clear_screen
	call showNumber
	mov ax,4c00h
	int 21h
main endp

setCursor proc near
	push ax
	push bx
	push dx
	push cx
	mov ah,02h
	mov bh,0
	int 10h
	pop cx
	pop dx
	pop bx
	pop ax
	ret
setCursor endp

getCursor proc near
	push ax
	push bx
	mov ah,03h
	mov bh,0
	int 10h
	pop bx
	pop ax
	ret
getCursor endp
clear_screen proc near
	push ax
	push bx
	push cx
	push dx
	;clear_screen
	mov ah,6
	mov al,0
	mov bh,1eh
	mov ch,0
	mov cl,0
	mov dh,24
	mov dl,79
	int 10h

	;locate cursor
	mov dx,0
	mov bx,0
	mov ah,2
	int 10h
	;restore registers
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clear_screen endp
output proc near
	push ax
	push bx
	push cx
	push dx
	mov ax,bx
	xor cx,cx
	cmp bx,20
	ja decLoop
	call printZero
	decLoop:
		xor dx,dx
		mov bx,10
		div bx
		push dx
		inc cx
		cmp ax,0
		je decOut
		jmp decLoop
	decOut:
		pop dx
		add dx,30h
		call putchar
		loop decOut
	pop dx
	pop cx
	pop bx
	pop ax
	ret
output endp
showNumber proc near
	push ax
	push bx
	push cx
	push dx
	mov bx,baseLine
	inc bx
	mov cx,23
	mov dh,0
	mov dl,0
loop_showNumber:
	call output
	inc dh		
	call setCursor
	inc bx
	loop loop_showNumber
	pop dx
	pop cx
	pop bx
	pop ax
	ret
showNumber endp

printZero proc near
	push ax
	push dx
	mov ah,02h
	mov dl,'0'
	int 21h
	pop dx
	pop ax
	ret
printZero endp
cout proc near
	push ax
	push dx
	lea dx,cr
	mov ah,09h
	int 21h
	pop dx
	pop ax
	ret
cout endp

putchar proc near
	push ax
	push dx
	mov ah,02h
	int 21h
	pop dx
	pop ax
	ret
putchar endp
code ends
end main
