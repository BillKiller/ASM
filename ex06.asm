;小写变大写
data segment
string db 255,?,255 dup(?)
CR  db 0ah,0dh,'$'
data ends

code segment
assume cs:code,ds:data
main proc far
start:
	 mov ax,data
	 mov ds,ax

	 lea dx,string
	 mov ah,0ah
	 int 21h

	 lea dx,CR
	 mov ah,09h
	 int 21h

	 lea bx,string+1
	 mov cl,[bx]
	 lea si,string+1
loop1:
	inc si
	cmp cl,0
	je s 
	dec cl
	mov dl,[si]
	cmp dl,'a'
	jb output  
	cmp dl ,'z'
	ja output
	sub dl,32
output:
	mov ah,02h
	int 21h
	jmp loop1
s:
	mov ax,4c00h
	int 21h
main endp
code ends
end start
