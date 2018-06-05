
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
	mov ah ,02h
	mov dl,07h
	int 21h
	mov ax,4c00h
	int 21h
main endp
code ends
end main
