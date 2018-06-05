data segment
		TABLE DW 100 dup(?),1
		max_num dw ?
 		max_count dw ?
 		now_num dw ?
 		now_count dw ?
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
	mov cx,100
	loop4:
		mov ax,TABLE[bx] 
		cmp ax,now_num
		jne newNum
		mov ax,now_count
		jmp continue
	newNum:
		mov ax,max_count
		cmp ax,now_count
		ja solve
		mov ax,now_count ;当前数目
		mov max_count,ax ;更新最大数目
		mov ax,now_num ;更新最大数字
		mov max_num,ax ;更新
		mov now_count,0 ;
		mov ax,TABLE[bx]
		mov now_num,ax
		xor ax,ax

		jmp continue
	solve:
		mov ax,TABLE[bx]
		mov now_num,ax
		mov now_count,0
	 continue:
	 	mov ax,now_count
	 	inc ax
	 	add bx,2
		mov now_count,ax
	 loop loop4
	 		mov ax,max_count

	cmp ax,now_count
	ja exit
	mov ax,now_count ;当前数目
	mov max_count,ax ;更新最大数目
	mov ax,now_num ;更新最大数字
	mov max_num,ax ;更新
	mov now_count,0 ;
	mov ax,TABLE[bx]
	mov now_num,ax
	xor ax,ax
exit:

	mov bx,max_num	
	call decOut
	mov bx,max_count
	call decOut
	mov ax,4c00h
	int 21h
main endp

decOut proc near
	push ax
	push bx
	push cx
	push dx
	mov ax,bx
	xor dx,dx
	xor cx,cx
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
	lea dx,cr
	mov ah,09h
	int 21h
	pop dx
	pop cx
	pop bx
	pop ax
	ret 
decOut endp
cout proc near
	push ax
	mov ah,02h
	int 21h
	pop ax
	ret
cout endp
code ends
end main
