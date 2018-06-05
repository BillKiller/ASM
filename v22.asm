data segment
	words dw 0
	dight dw 0
	others dw 0
	flag dw 0
	wordmeg db 'words number is$'
	numbermeg db 'digit number is $' 
	othersmeg db 'other number is$'
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
	mov ax,stack
	mov ss,ax
	lea sp,top
	loop1:
		call getchar
		cmp al ,0dh
		je exit
		mov flag,0
		call isDight
		call isWord
		call isOther
		jmp loop1
exit:
	lea dx,wordmeg
	call cout
	mov bx,words
	call outDec
	lea dx,numbermeg
	call cout
	mov bx,dight
	call outDec
	lea dx,othersmeg
	call cout
	mov bx,others
	call outDec
	mov ax,4c00h
	int 21h
main endp
isDight proc near
	cmp al,'0'
	jb digitEnd
	cmp al,'9'
	ja digitEnd
	inc dight
	mov flag,1
digitEnd:
	ret
isDight endp

isWord proc near
	cmp al,'A'
	jb wordsEnd
	cmp al,'Z'
	jna isOk
	cmp al,'a'
	jb wordsEnd
	cmp al,'z'
	jna isOk
	jmp wordsEnd
isOk:
	inc words
	mov flag,1
	jmp wordsEnd
wordsEnd:
	ret
isWord endp

isOther proc near
	cmp flag,0
	jne otherEnd
	inc others
	otherEnd:
	ret
isOther endp
cout proc near
	push ax
	mov ah,09h
	int 21h
	pop ax
	ret
cout endp

outDec proc near
	push ax
	push bx
	push cx
	push dx
	mov ax,bx
	xor cx,cx
	decLoop:
		xor dx,dx
		mov bx,10
		div bx
		push dx
		inc cx
		cmp ax,0
		je decOut
		jmp decLoop
	decOut:
		pop dx
		add dx,30h
		call putchar
		loop decOut
	lea dx,cr
	call cout
	pop dx
	pop cx
	pop bx
	pop ax
	ret
outDec endp
getchar proc near
	mov ah,01h
	int 21h
	ret
getchar endp
putchar proc near
	push ax
	mov ah,02h
	int 21h
	pop ax
	ret
putchar endp
code ends
end main
