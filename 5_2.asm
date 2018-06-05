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
	
	mov ah,01h
	int 21h

	mov bl,al
	mov bh,al
	mov cl,al
	dec bl
	inc bh
	cmp al,'a'
	jne IFZ
	mov bl,'z'
IFZ:
	cmp al,'z'
	jne print
	mov bh,'a' 
print:
	mov dl,bl
	mov ah,02h
	int 21h

	mov dl,al
	mov ah,02h
	int 21h

	mov dl,bh
	mov ah,02h
	int 21h
	mov ax,4c00h
	int 21h
main endp
code ends
end main
