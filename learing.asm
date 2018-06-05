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
	loop1:
		mov ah,01h
		int 21h
		cmp al,'w'
		je up
		call scrollDown
		jmp loop1
	up:	
		call scrollUp
		jmp loop1
		mov ax,4c00h
		int 21h
main endp

hello proc near
	locate:
		mov ah,2
		mov dh,0
		mov dl,0
		mov bh,0
		int 10h
		mov cx,win_width
	get_char:
		mov ah,1
		int 21h
		cmp al,esc_key
		jz exit
		loop get_char
		;
		mov ah,6
		mov al,1
		mov ch,win_ulr
		mov cl,win_ulc
		mov dh,win_lrr
		mov dl,win_lrc
		mov bh,1eh
		int 10h
		jmp locate
	exit:
	ret
hello endp

scrollUp proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,6
	mov al,1
	mov ch,win_ulr
	mov cl,win_ulc
	mov dh,win_lrr
	mov dl,win_lrc
	mov bh,1eh
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
scrollUp endp

scrollDown proc near
	push ax
	push bx
	push cx
	push dx
	mov ah,7
	mov al,1
	mov ch,win_ulc
	mov cl,win_ulc
	mov dh,win_lrr
	mov dl,win_lrc
	mov bh,1eh
	int 10h
	pop dx
	pop cx
	pop bx
	pop ax
	ret
scrollDown endp
code ends
end main
