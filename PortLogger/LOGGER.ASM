; TSR to log  port access

.MODEL  TINY
.386P		;We need 386 instructions for the protected mode routines
.CODE
SMART
ORG     100h


;======================= Code to stay resident ===========================

		PortHandler     equ     <port.asm> ;Set port handler to its routine

Start:
		jmp	Init		;Skip data

		;Variables for Port values:

		StartPort		dw 0    ; Start of port range to log
		EndPort			dw 0	; End of port range to log
		OutPort			dw 0    ; Port to redirect access to
	
		;Include protected mode routines:
		include 386pdef.asm          ; Definitions first
		include 386pdata.asm         ; Then data segment
		include 386plib.asm          ; PM library
		include 386pint.asm          ; ISR's
		include 386pdt.asm           ; Descriptor tables




;============================== Non resident code ============================



Setup_IOmap  proc near             ;Sets bits in IO map for Tandy, PS/2 and sound card ports
		push cs
		pop es

		push ax
		push bx
		push cx
		push dx
		push si

		mov bx, StartPort
.loop:
		mov ax,bx
		xor dx,dx
		mov cx, 8
		div cx

		add ax, offset IOportMap
		mov si, ax

		mov al, 1
		mov cl, dl
		shl al, cl

		or [si], al

		inc bx
		cmp bx, EndPort
		jbe .loop

		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		retn
		endp


Init:
		mov ax,03
		int 10h

		mov si,offset TitleMsg
		call write_string

		xor ax,ax
		mov si,80h
		lodsb
		cmp al,0
		je  NoValidCmd          ;There are no parameters

		mov cx,ax               ;Get Commandline
		mov di,offset CmdLine

.GetCmdString:
		lodsb
		stosb
		loop .GetCmdString
		xor al,al
		stosb

Check_Options:
		mov ax,offset CmdLine
		call string_uppercase  ;make command line uppercase
		mov si,ax
		call string_parse      ;Parse different strings

		; AX and BX should have options, CX and DX should not
		or ax,ax
		jz NoValidCmd
		or bx,bx
		jz NoValidCmd
		or cx,cx
		jnz NoValidCmd
		or dx,dx
		jnz NoValidCmd

		; Parse start port
		call string_to_int_hex
		jnc NoValidCmd
		mov	StartPort, ax

		; Parse end port
		mov ax,bx
		call string_to_int_hex
		jnc NoValidCmd
		mov	EndPort, ax

		cmp ax, StartPort
		jb NoValidCmd

Start_V86:
		clc
		call 	CheckCPU
		call	Setup_IOmap
		call    SwitchToPM
		call    SwitchToVM86

		mov 	si,offset V86SuccessMsg
		call    write_string

		mov		si,offset LoggingMsg
		call    write_string
		mov		ax,StartPort
		call	print_int_hex
		mov		si, offset Hyphen
		call    write_string
		mov		ax,EndPort
		call	print_int_hex
		mov		si, offset Return
		call    write_string

		mov dx, offset Setup_IOmap   ;Everything that should remain memory resident stands before Setup_IOmap
		int 27h                      ;TSR

NoValidCmd:
		mov si,offset BadOption
		call write_string

		mov ah,4Ch
		int 21h

		include 386rdata.asm         ; Real-mode data
		include 386preal.asm         ; Real-mode subroutines
		include strings.inc          ; String handling routines


;Data:

		TitleMsg  	db 'I/O Port Access Logger ',10,13,0

		Space		db ' ',0

		Hyphen		db '-',0

		Return		db 10,13,0

		V86SuccessMsg	db 'V86 mode successfully installed.',10,13,0

		LoggingMsg	db 'Port logging installed for range ',0

		InvalidHex	db 'Invalid hex number specified.',10,13,0

		BadOption	db 10,13,'Usage: ',10,13
					db 'LOGGER.COM <start port> <end port>',10,13
					db 10,13
					db 'Example: ',10,13
					db 'LOGGER.COM 320 323',10,13
					db 'to log access to all ports fron 320h to 323h inclusive.',10,13,0

		CmdLine		db 10 dup(0)

		end     Start
