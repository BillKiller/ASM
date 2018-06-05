data segment
	w dw 1234
data ends

stack segment stack
	30 dw dup(?)
	top label word
stack ends

code segment 
	assume cs:code,ss:stack,ds:data
	main proc far
start:
	;---init------
	mov ax,data
	mov ds,ax
	mov ax,stack
	mov ss,ax
	lea sp,top
	;---init------

	mov bx,w
	

	main endp
code ends
end start