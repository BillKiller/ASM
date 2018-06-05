data segment
	string db 0dh,0ah,'$'
	a dw ?
	b dw ?	
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
	;input decimal output 
	call inputH
	mov a,bx
	call cr
	call binToHex
	call cr
	call inputH
	call binToHex
	call cr
	mov b,bx
	add bx,a
	call binToHex
	;
	mov ax,4c00h
	int 21h
main endp

;inpur binary in bx

inputB proc near
	xor bx,bx
	mov cx,16
	loop4:
		rol bx,1
		call cin
		shr al,1
		adc bx,0
		loop loop4
	ret
inputB endp
;输入十进制
inputD proc near
	xor bx,bx
	xor cx,cx
	mov si,0
	loop6:
		call cin 
		cmp al,0dh
		je dEND
		cmp al,'+'
		je loop6
		cmp al,'-'
		jne num
		mov si,1
		jmp loop6
	num:
		mov dx,10
		mov cl,al
		sub cl,'0'
		mov ax,bx
		mul dx
		add ax,cx
		mov bx,ax
		jmp loop6
	
	dEND:
		cmp si,1
		jne NEGE
		neg bx
	NEGE:
	ret
inputD endp
;输入16进制
inputH proc near
	mov cx,4
	xor bx,bx
	loop5:
		push cx
		mov cl,4
		call cin
		rol bx,cl
		cmp al,'9'
		jna s
	AToZ:
		sub al,'A'
		add al,10
		add al,30h
		mov dl,al
		xor dh,dh
		call print
	s:
		sub al,30h
		add bl,al
		pop cx
		loop loop5
	bEND:
	ret
inputH endp

;以16进制输出bx内容
binToHex proc near
	mov cx,4
	cmp bx,0
	jnl loop1
	mov dl,'-'
	call print
	neg bx
	loop1:
		push cx
		mov cx,4
		rol bx,cl
		mov dx,bx
		and dx,0Fh
		cmp dx,10
		jb hex
		add dx,07h
	hex:
		add dx,30h
		call print 
		pop cx
		loop loop1
	ret
binToHex endp

bintoDec proc near

	mov ax,10
	xchg ax,bx
	mov cx,0
	loop2:
		xor dx,dx
		div bx
		push dx
		inc cx
		cmp ax,0
		jne loop2
	loop3:
		pop dx
		add dx ,30h
		call print
		loop loop3
		ret 	
bintoDec endp
;换行
cr proc near
	lea dx,string
	mov ah,09h
	int 21h
	ret
cr endp 
print proc near
	push ax
	mov ah,02h
	int 21h
	pop ax
	ret
print endp

cin proc near
	mov ah,01h
	int 21h
	ret
cin endp
code ends
end main
