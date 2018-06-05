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
cin:
	mov ah,01h
	int 21h
	cmp al,0dh
	je last
	cmp al,'z'
	ja  cin
	cmp al,'a'
	jb cin
	sub al,32
	mov dl,al
	mov ah,02h
	int 21h
	jmp cin
last:
	mov ax,4c00h
	int 21h

main endp
code ends
end main
