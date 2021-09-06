PortHandler     proc    near
		cmp     ah,0EEh
		je      OutDX_AL
		cmp     ah,0E6h
		je      Out@@_AL
		cmp     ah,0ECh
		je      InAL_DX
		cmp     ah,0E4h
		je      InAL_@@
		jmp     TooBad		; Nothing we can do if we don't recognise the instruction.

OutDX_AL:       push    dx

WritePort:      
		cbw
		add     [ebp],ax
		mov     al,byte ptr [ebp-4]

		cmp		dx, [ss:StartPort]
		jb		@Other

		cmp		dx, [ss:EndPort]
		ja		@Other

		out		80h, al	; Write to POST port.

		; TODO: Properly log write here.
		push ds
		push ax
		mov ax, 18h
		mov ds, ax
		pop ax
		mov ds:[0B8000h], al 
		pop ds

@Other:
		out     dx,al
		jmp     @@AllRight

Out@@_AL:       
		push    dx
		movzx   dx,byte ptr [ebx]
		inc     al
		jmp     WritePort


InAL_DX:       
		push    dx

ReadPort:
		cbw
		add     [ebp],ax
		in      al,dx
		mov     byte ptr [ebp-4],al

		cmp		dx, [ss:StartPort]
		jb		@Other

		cmp		dx, [ss:EndPort]
		ja		@Other

		out		80h, al	; Write to POST port.

		; TODO: Properly log read here.
		push ds
		push ax
		mov ax, 18h
		mov ds, ax
		pop ax
		mov ds:[0B8000h], al 
		pop ds

		jmp     @@AllRight

InAL_@@:        
		push    dx
		inc     al
		movzx   dx,byte ptr [ebx]
		jmp     ReadPort


@@AllRight:     
		pop     dx
		pop     ebp
		pop     ds
		pop     ebx
		pop     eax
		iretd

TooBad:

PortHandler     endp
