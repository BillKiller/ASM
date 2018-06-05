data segment
	list db 0,0,0,0,0,0,0,0,0,0
		 db 1,2,3,4,5,6,7,8,9,10
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
	
	mov ax,4c00h
	int 21h
main endp
delOneLine proc near
	 
	ret
delOneLine endp
code ends
end main
