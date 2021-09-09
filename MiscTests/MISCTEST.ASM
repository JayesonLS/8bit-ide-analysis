; Small app to run various small tests.

.MODEL  TINY
.286
.CODE
SMART
ORG     100h


Start:
		mov	dx, offset WelcomeMsg
		call PrintString

		mov	al, ds:[80h]		; Check that length of command line is 2 (leading space plus option).
		cmp	al, 2				
		jnz  BadCommandLine

		; Super simple parsing - tests are numbered 0 through 9.
		mov	al, ds:[82h]
		cmp	al, '0'
		jb	BadCommandLine
		cmp al, '9'
		ja	BadCommandLine

		; Jump to relevant operation handling code.
		sub al, '0'
		xor	ah,ah
		shl ax,1
		mov si, ax
		jmp	OpTable[si]

BadCommandLine:
		mov	dx, offset HelpMsg
		call PrintString

		jmp	TerminateProgram

TerminateProgram:
		mov	ah, 04Ch
		int	021h


Rapid320Write:
		mov	dx, offset ForeverMsg
		call PrintString
.Rapid320WriteLoop:
			
		jmp	.Rapid320WriteLoop


Rapid320Read:
		mov	dx, offset ForeverMsg
		call PrintString
.Rapid320ReadLoop:
			
		jmp	.Rapid320ReadLoop


Rapid320RepnzWrite:
		mov	dx, offset ForeverMsg
		call PrintString
.Rapid320RepnzWriteLoop:
		mov	cx, 16
.Rapid320RepnzWriteInnerLoop:

		loop .Rapid320RepnzWriteInnerLoop
		jmp .Rapid320RepnzWriteLoop


Rapid320RepnzRead:
		mov	dx, offset ForeverMsg
		call PrintString
.Rapid320RepnzReadLoop:
		mov	cx, 16
.Rapid320RepnzReadInnerLoop:

		loop .Rapid320RepnzReadInnerLoop
		jmp .Rapid320RepnzReadLoop

		; Print $ terminated string pointed to by dx
PrintString proc near
		push ax
		mov	ah, 9
		int	021h
		pop ax
		ret
		endp

OpTable dw	Rapid320Write		; 0
		dw	Rapid320Read		; 1
		dw	Rapid320RepnzWrite	; 2
		dw	Rapid320RepnzRead	; 3
		dw	BadCommandLine		; 4
		dw	BadCommandLine		; 5
		dw	BadCommandLine		; 6
		dw	BadCommandLine		; 7
		dw	BadCommandLine		; 8
		dw	BadCommandLine		; 9

ReadWriteBuffer db	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

WelcomeMsg	db	"Misc Tests v 0.1", 10, 13, '$'

HelpMsg		db	"Usage: misctest <option> where <option> is 0 through 9", 10, 13
			db	"       misctest 0 - Do 6 rapid 0x320 writes forever", 10, 13
			db	"       misctest 1 - Do 6 rapid 0x320 reads forever", 10, 13
			db	"       misctest 2 - Do 16 rapid 0x320 repnz writes forever", 10, 13
			db	"       misctest 3 - Do 16 rapid 0x320 repnz reads forever", 10, 13
			db	'$'

ForeverMsg	db "Note: This operation will run forever (locks system)", 10, 13, '$'

		end     Start
