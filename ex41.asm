data segment
	match db 'MATCH$'
	NotMatch db 'NOT MATCH'
	string db 255,?,
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
code ends
end main
