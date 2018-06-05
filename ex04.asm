
code segment
assume cs:code
main proc far 
start:
	mov cl,0
input:
	  mov ah,01h
	  int  21h
	  mov dl,al
	  cmp dl,'#'
	  je s
	  cmp dl,'0'
	  jb  count
	  cmp dl,'9'
	  ja  count
	  jmp input
count:
	inc cl
	jmp input
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