data segment
	MEM dw 100 dup(?)
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
	xor bx,bx
	xor di,di
	loop1:
		cmp MEM[bx],0
		je fish
		mov ax,MEM[bx]
		mov MEM[di],ax
		add di,2
	fish:
		add bx,2
	loop loop1
	
	mov ax,4c00h
	int 21h
main endp
code ends
end main
