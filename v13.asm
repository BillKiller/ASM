data segment
		string db 10,'abcdeasdba'
		hasNumber db 0
		msg db 'find a number',0dh,0ah,'$'
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
	mov cx,10
	xor bx,bx
	loop1:
		call isNumber
		add bx,2
		cmp hasNumber,1
		je  has
		loop loop1
		jmp noHas
has:
		xor cl,cl
		or cl,00100000b
noHas:
	mov ax,4c00h
	int 21h
main endp
isNumber proc near
	cmp string[bx],'0'
	jb exit
	cmp string[bx],'9'
	ja exit
	mov hasNumber,1
	lea dx,msg
	mov ah,09h
	int 21h
exit:
	ret
isNumber endp

cout endp
code ends
end main
