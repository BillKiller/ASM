data segment
	PATHNAME DB 'EX1.txt',0
	PATHNAME2 DB 'EX2.ASM',0
	HANDLE DW ?
	HANDLE2 DW ?
	BUFF DB  256 DUP(?)
	isEnd db 0
	openerr db '****open error*********',0dh,0ah,'$'
	readerr db '****read error*********',0dh,0ah,'$'
	writerr db '****writeeroor*********',0dh,0ah,'$'
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
	call openFile
	call createFile
	continue:
			call readFile
			cmp isEnd,1
			je mainendp
			call writeFile
			jmp continue
	mainendp:
	call closeFile
	mov ax,4c00h
	int 21h
main endp

openFile proc near
	mov ah,3dh
	mov al,0
	lea dx,PATHNAME
	int 21h
	jc b1
	mov HANDLE,ax
	ret
b1:
		mov isEnd,1
		lea dx,openerr
		call errm
		ret
openFile endp

createFile proc near
		mov ah,3ch
		mov cx,00
		lea dx,PATHNAME2
		int 21h
		jc ctf
		mov HANDLE2,ax
		jmp ctfend
ctf:
		mov isEnd ,1
		lea dx,writerr
		call errm
ctfend:
		ret
createFile endp

readFile proc near
		mov ah,3fh
		mov bx,HANDLE
		mov cx,256
		lea dx,BUFF
		int 21h
		jc c1
		cmp ax,0
		je c2
		ret
c1:
		lea dx,readerr
		call errm
c2:
		mov isEnd,1
		ret
readFile endp
writeFile proc near
		mov ah,40h
		mov bx,HANDLE2
		mov cx,256
		lea dx,BUFF
		int 21h
		jc d1
		cmp ax,256
		jne d2
		ret
d1:
		lea dx,writerr
		call errm
d2:
		mov isEnd ,1
		ret
writeFile endp
closeFile proc near
		cmp isEnd,1
		je cfe
		mov ah,3eh
		mov bx,HANDLE2
		int 21h
cfe:
		ret
closeFile endp

errm proc near
		mov ah,40h
		mov bx,01
		mov cx,20
		int 21h
		ret
errm endp
code ends
end main
