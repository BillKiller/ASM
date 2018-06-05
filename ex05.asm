data segment

string db 255,?,255 dup('$')

CTRF db 0ah,0dh,'$'

data ends

code segment
assume cs:code
main proc far 
start:
	mov ax,data
	mov ds,ax

	lea dx,string
	mov ah,0ah
	int 21h

	lea dx,CTRF
	mov ah,09h
	int 21h
	lea si,string+1
	lea bx,string+1
	mov dl,[bx]
	mov cl,0
loop1:
	cmp dl,0
	je s
	dec dl
	inc si
	mov al,[si]
	cmp al,'0'
	jb loop1
	cmp al,'9'
	ja loop1
	mov cl,1
s:
	mov dl,cl
	add dl,'0'
	mov ah,02h
	int 21h
	mov ax,4c00h

	int 21h
main endp
code ends
end start