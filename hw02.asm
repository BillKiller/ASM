data segment
	STRING1 db 255,?,255 dup('$')
	STRING2 db 255,?,255 dup('$')
	STRING3 db 'MATCH$'
	STRING4 db 'NOT MATCH$'
	cr db 0dh,0ah,'$'
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
	mov es,ax
	mov ax,stack
	mov ss,ax
	lea sp,top
	lea dx,STRING1
	call cin
	lea dx,cr
	call cout
	lea dx,STRING2
	call cin
	
	lea dx,cr
	call cout

	mov cl,[STRING1+1]
	mov al,[STRING1+1]
	cmp cl,al
	jne notmatch


	mov cl,[STRING1+1]
	xor ch,ch
	lea si,STRING1+2
	lea di,STRING2+2	

	cld
	repe cmpsb
	jnz notmatch
match:
	lea dx,STRING3
	jmp finish
notmatch:
	lea dx,STRING4
finish:
	call cout
	mov ax,4c00h
	int 21h
main endp
cin proc near
	mov ah,0ah
	int 21h
	ret 
cin endp
cout proc near
	mov ah,09h
	int 21h
	ret
cout endp
code ends
end main
