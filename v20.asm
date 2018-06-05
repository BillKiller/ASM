data segment
	A dw 1
	B dw 2
	C dw 0
	D dw ?
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
	cmp A,0
	je hasZero
	cmp B,0
	je hasZero
	cmp C,0
	je hasZero
	mov ax,A
	add ax,B
	add ax,C
	mov D,AX
	jmp exit
	hasZero:
	call clear
	exit:	
	mov ax,4c00h
	int 21h
main endp
clear proc near
	mov A,0
	mov B,0
	mov C,0
	ret
clear endp
code ends
end main
