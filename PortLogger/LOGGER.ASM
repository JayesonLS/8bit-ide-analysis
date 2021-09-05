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

		InPort	    	        dw 0    ;Original port
		OutPort			dw 0    ;Port to redirect access to
		LPT			db 0    ;use parallel port?
		FoundOption		db 0
		int15_old_handler       dw 0    ;Handler for int 15
		int15_old_handler_seg   dw 0
		int11_equipment  	dw 0	;Equipment bits returned by int 11h


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
		mov     IOportMap[042h/8],00000100b  ;Port 42h
		mov     IOportMap[0C0h/8],11111111b  ;Port 0C0-C07h
		mov     IOportMap[205h/8],00100000b  ;Port 205h
		mov	IOportMap[388h/8],00000011b  ;Port 388h / 389h
		mov	IOportMap[220h/8],01001111b  ;Port 220-223h,226h
		mov	IOportMap[228h/8],01010100b  ;Port 22Ah,22Ch,22Eh
		retn
	       endp

Delay	     proc near		;Just a small delay (in: AX = delay in ms)
		pusha
		mov bx,1000
		mul bx
		mov cx,dx
		mov dx,ax
		xor al,al
		mov ah,86h
		int 15h
		popa
		retn
	      endp


Write_to_LPT  proc near
		 pusha
		 mov 	dx,[ss:OutPort]
		 out 	dx,al

		 inc     dx             ;Ctrl Port
		 inc 	dx

		 mov	al,0Ch
		 out	dx,al

		 dec     dx             ;Status port
		 mov     cx,18h

		Not_ready:

		 in      al,dx
		 test	al,01000000b
		 loopnz  Not_ready

		 cmp     cx,0
		 je      LPT_done

		 mov     cx,18h

		ready:

		in 	al,dx
		test	al,01000000b
		loopz	ready

		LPT_done:
		inc dx
		mov al,9
		out dx,al
		popa
		retn
endp






Handle_Options	proc near
		;In: AX = offset of string to test; Out: FoundOption = 1 if found
		pusha

		clc

		; Check for options here. See original TNDY code for how.

		jmp Options_End

Options_End:
		popa
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

		push ax

		mov ax,dx               ;Test string in dx for known options
		call Handle_Options

		mov ax,cx               ;Test string in cx for known options
		call Handle_Options

		mov ax,bx               ;Test string in bx for known options
		call Handle_Options

		pop ax                  ;Test string in ax for known options
		call Handle_Options


		cmp bx,0		; There is only one parameter?
		je .OnlyOne 		; If so, there is nothing else to do here


		clc

		mov si,ax
		mov di,offset SC0
		call string_compare
		jc .isC0

		mov si,ax
		mov di,offset SC0alt
		call string_compare
		jc .isC0

		mov si,ax
		mov di,offset SC0C7
		call string_compare
		jc .isC0C7

		mov si,ax
		mov di,offset S205
		call string_compare
		jc .is205

		jmp .OnlyOne


	.isC0:
		mov InPort,0C0h
		jmp .DoDestParam

	.isC0C7:
		mov InPort,0C7h
		jmp .DoDestParam

	.is205:
		mov InPort,205h
		jmp .DoDestParam

.OnlyOne:
		cmp  FoundOption,1      ;ist the paramter an option?
		je   Continue           ;Yes, the proceed
		jmp  NoValidCmd         ;Else command is not valid

.DoDestParam:

		mov si,bx
		mov di,offset S2E0
		call string_compare
		jc .is2E0

		mov si,bx
		mov di,offset S2C0
		call string_compare
		jc .is2C0

		mov si,bx
		mov di,offset S1E0
		call string_compare
		jc .is1E0

		mov si,bx
		mov di,offset SE0
		call string_compare
		jc .is0E0

		mov si,bx
		mov di,offset SE0alt
		call string_compare
		jc .is0E0

		mov si,bx
		mov di,offset SC0
		call string_compare
		jc .is0C0

		mov si,bx
		mov di,offset SC0alt
		call string_compare
		jc .is0C0

		jmp .OnlyOne

		.is2E0:
		mov OutPort,2E0h
		jmp Continue

		.is2C0:
		mov OutPort,2C0h
		jmp Continue

		.is1E0:
		mov OutPort,1E0h
		jmp Continue

		.is0E0:
		mov OutPort,0E0h
		jmp Continue

		.is0C0:
		mov OutPort,0C0h
		jmp Continue

Continue:
		cmp    OutPort,0
		je     .NoRD
		cmp    InPort,0
		je     .NoRD

		jmp    .StartV86

.NoRD:
		cmp     FoundOption,0  ;No valid ports, no valid options -> quit here
		je	NoValidCmd


.StartV86:
		clc
		call 	CheckCPU
		call	Setup_IOmap
		call    SwitchToPM
		call    SwitchToVM86

		mov 	si,offset V86SuccessMsg
		call    write_string

		cmp     OutPort,0
		je	.NoRDMsg
		cmp	InPort,0
		je	.NoRDMsg

		mov	si,offset LoggingMsg
		call    write_string

.NoRDMsg:
		mov dx, offset Setup_IOmap   ;Everything that should remain memory resident stands before Setup_IOmap
		int 27h                      ;TSR

		include 386rdata.asm         ; Real-mode data
		include 386preal.asm         ; Real-mode subroutines
		include strings.inc          ; String handling routines




;Data:

		TitleMsg  	db 'I/O Port Access Logger ',10,13,0

		Return		db 10,13,0

		V86SuccessMsg	db 'V86 mode successfully installed.',10,13,0

		LoggingMsg	db 'Port logging installed.',10,13,0

		NoLPTMsg	db 10,13,'ERROR: Parallel port not found!',10,13,0

		EmuMSG		db 'Int 15h and Int 11h changed to report a',0

		SBMSG		db 'Sound Blaster disabled.',10,13,0

		OPLMSG		db 'FM-Chip disabled.',10,13,0


		BadOption       db 10,13,'Specify port addresses to redirect port access: ',10,13
				db 'LOGGER.COM <Tandy port> <Port of the TNDY or TLPT> (Option 1) (Option 2)',10,13
				db 10,13
				db 'Possible Tandy ports (in Hex): ',10,13
				db '0C0, C0-C7, 205',10,13
				db 'Possible ports for TNDY or TLPT (in Hex): ',10,13
				db 'C0, E0, 1E0, 2C0, 2E0, LPT1, LPT2, LPT3',10,13,10,13
				db 10,13
				db 'Example: ',10,13
				db 'LOGGER.COM 0C0 2C0',10,13
				db 'All access to port 0C0h will be redirected to port 2C0h.',10,13,0

		SC0             db 'C0',0
		SC0alt		db '0C0',0
		SE0		db 'E0',0
		SE0alt		db '0E0',0
		SC0C7           db 'C0-C7',0
		S205            db '205',0
		S1E0            db '1E0',0
		S2C0            db '2C0',0
		S2E0		db '2E0',0

		CmdLine		db 10 dup(0)

NoValidCmd:
		mov si,offset BadOption
		call write_string

		mov ah,4Ch
		int 21h


		end     Start
