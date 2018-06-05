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
	;input decimal output 
	mov bx,0abcdh
	call binToHex
	;
	mov ax,4c00h
	int 21h
main endp
;inpur binary in bx
inputB proc near
	xor bx,bx
	mov cx,4
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
	ret
inputD endp
;输入16进制
inputH proc near
	ret
inputH endp

;以16进制输出bx内容
binToHex proc near
	mov cx,4
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

print proc near
	mov ah,02h
	int 21h
	ret
print endp

cin proc near
	mov ah,01h
	int 21h
	ret
cin endp
code ends
end main
