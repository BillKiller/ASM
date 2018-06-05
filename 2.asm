data segment 
	s db 'hello world$'
data ends
code segment
assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	mov ah,01h
	int 21h
	cmp al,'a'
	jb s2
upper:
	sub al,32
s2:
	mov dl,al
	mov ah,02h
	int 21h
	mov ax,4c00h
	int 21h
code ends
end start
