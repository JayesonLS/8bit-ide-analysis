PortHandler     proc    near
		cmp     ah,0EEh
		je      OutDX_AL
		cmp     ah,0E6h
		je      Out@@_AL
		cmp     ah,0ECh
		je      InAL_DX
		cmp     ah,0E4h
		je      InAL_@@
		jmp     TooBad

OutDX_AL:       push    dx

CheckPort:      
		cbw
		add     [ebp],ax
		mov     al,byte ptr [ebp-4]

		cmp     dx,0C7h		;Tandy ports C0h-C7h
		jbe     @TandyPort

		cmp     dx,205h         ;PS/1 sound port 205h
		je      @PS1





@Other:
		out     dx,al
		jmp     @@AllRight


@@AllRight:     
		pop     dx
		pop     ebp
		pop     ds
		pop     ebx
		pop     eax
		iretd

@TandyPort:
		cmp	[ss:StartPort],0   ;No redirecting?
		je	@Other
		cmp	[ss:OutPort],0
		je	@Other

		cmp     dx,0C0h
		je      .CheckC0
		cmp     dx,0C0h
		ja      .CheckC0C7

		jmp     @Other

		.CheckC0:
		cmp     [ss:StartPort],205h
		je      @Other
		jmp     .doit

		.CheckC0C7:
		cmp     [ss:StartPort],0C7h
		jne     @Other

		sub     dx,0C0h   ;Füⁿr Matze - !!!
		add     dx,[ss:OutPort]
		out     dx,al

		jmp	@@AllRight


.doit:
		mov 	dx,[ss:OutPort]
		out     dx,al

		jmp	@@AllRight



@PS1:           
		cmp     [ss:StartPort],205h
		je      .doit
		jmp     @Other




Out@@_AL:       
		push    dx
		movzx   dx,byte ptr [ebx]
		inc     al
		jmp     CheckPort


InAL_DX:       
		push    dx

ReadPort:
		cbw
		add     [ebp],ax
		in      al,dx
		mov     byte ptr [ebp-4],al
		jmp     @@AllRight

InAL_@@:        
		push    dx
		inc     al
		movzx   dx,byte ptr [ebx]
		jmp     ReadPort

TooBad:

PortHandler     endp
