;String handling routines
;v 1.0 - June 2000 by Jan Knipperts
;Note: Strings must be 0 terminated


; ==================================================================
; string_length - Return length of a string
;
; IN: AX = string location
;
; OUT: AX = length (other regs preserved)
; ==========================7========================================
string_length:
	push gs 			; The GS register can be used as temp store (386+)
	pusha

	mov bx, ax			; Move location of string to BX

	xor cx, cx			; Counter CX = 0

.l_more:
	xor al,al
	cmp byte [bx], al        	; Zero (end of string) yet?
	je .l_done
	inc bx				; If not, keep adding
	inc cx
	jmp .l_more

.l_done:
	mov gs, cx			; Store count before restoring other registers
	popa

	mov ax, gs			; Put count back into AX before returning
	pop gs
	ret

; ==================================================================
; string_uppercase - Convert zero-terminated string to upper case
;
; IN: AX = string location
;
; OUT: AX = string location
; ==================================================================
string_uppercase:
	pusha
	mov si, ax			; Use SI to access string

.u_more:
	mov al,0
	cmp byte [si], al		; Zero-termination of string?
	je .done			; If so, quit

	mov al,'a'
	cmp byte [si], al		; In the lower case A to Z range?
	jb .noatoz
	mov al,'z'
	cmp byte [si], al
	ja .noatoz

	mov al,20h
	sub byte [si], al		; If so, convert input char to upper case

	inc si
	jmp .u_more

.noatoz:
	inc si
	jmp .u_more

.done:
	popa
	ret


; ------------------------------------------------------------------
; string_parse -- Take string (eg "run foo bar baz") and return
; pointers to zero-terminated strings (eg AX = "run", BX = "foo" etc.)
; IN: SI = string; OUT: AX, BX, CX, DX = individual strings

string_parse:
	push si

	mov ax, si			; AX = start of first string

	lodsb				; Get a byte
	cmp al,0			; End of string?
	je .finish
	cmp al, ' '			; A space?
	jne .clear_adr
	mov ax,si			; Update start of first string

.clear_adr:
	xor bx, bx			; By default, other strings start empty
	xor cx, cx			; Therefore we set BX, CX and DX to 0
	xor dx, dx

	push ax 			; Save to retrieve at end

.loop1:
	lodsb				; Get a byte
	cmp al,0			; End of string?
	je .finish
	cmp al, ' '			; A space?
	jne .loop1
	sub si,2
	mov al,0
	mov byte [si],al		; If so, zero-terminate this bit of the string

	add si,2  			; Store start of next string in BX
	mov bx, si

.loop2: 				; Repeat the above for CX and DX...
	lodsb
	cmp al,0
	je .finish
	cmp al, ' '
	jne .loop2
	sub si,2
	mov al,0
	mov byte [si], al

	add si,2
	mov cx, si

.loop3:
	lodsb
	cmp al,0
	je .finish
	cmp al,' '
	jne .loop3
	sub si,2
	mov al,0
	mov byte [si], al
	add si,2
	mov dx, si

.finish:
	pop ax

	pop si
	ret


; ------------------------------------------------------------------
; write_string -- Writes 0 terminated string to the screen and returns
; IN: SI = string;

write_string:
  push dx
  push cx
  push ax

  xor cx,cx
  Length_Loop:
      lodsb
      inc cx
      cmp al,0
      jne Length_Loop
  sub si,cx

 Write_Loop:
   lodsb
   mov dl,al
   mov ah,2
   int 21h
 loop Write_Loop

 pop dx
 pop cx
 pop ax

ret

; ------------------------------------------------------------------
; string_compare -- See if two strings match
; IN: SI = string one, DI = string two
; OUT: carry set if same, clear if different

string_compare:
	pusha

.c_more:
	mov al, [si]			; Retrieve string contents
	mov bl, [di]

	cmp al, bl			; Compare characters at current location
	jne .not_same

	cmp al, 0			; End of first string? Must also be end of second
	je .terminated

	inc si
	inc di
	jmp .c_more

.not_same:				; If unequal lengths with same beginning, the byte
	popa				; comparison fails at shortest string terminator
	clc				; Clear carry flag
	ret

.terminated:				; Both strings terminated at the same position
	popa
	stc				; Set carry flag
	ret

; ------------------------------------------------------------------
; string_to_int_hex -- Parse hex format string
; IN: SI = string one
; OUT: carry set if valid, int in AX; carry clear on parse error

string_to_int_hex:
	push bx
	xor bx,bx

.string_to_int_hex_next_char:
	mov al, [si]
	inc si

	cmp al, 0		; Check for string termination
	je .string_to_int_hex_done

	cmp al, ' '		; Skip whitespace
	je .string_to_int_hex_next_char

	cmp al, '0'		; Match digits
	jb .string_to_int_hex_not_digit
	cmp al, '9'
	ja .string_to_int_hex_not_digit
	sub al,'0'
	jmp .string_to_int_hex_append

.string_to_int_hex_not_digit:
	cmp al, 'a'		; Match lower case A-F
	jb .string_to_int_hex_not_lower
	cmp al, 'f'
	ja .string_to_int_hex_not_lower
	sub al,'a' - 10
	jmp .string_to_int_hex_append

.string_to_int_hex_not_lower:
	cmp al, 'A'		; Match lower case A-F
	jb .string_to_int_hex_not_upper
	cmp al, 'F'
	ja .string_to_int_hex_not_upper
	sub al,'A' - 10
	jmp .string_to_int_hex_append

.string_to_int_hex_not_upper:
	jmp .string_to_int_hex_error	; Unhandled character

.string_to_int_hex_append:
	cmp bx, 0FFFh
	ja .string_to_int_hex_error	; Overflow

	shl	bx, 4
	add bx, ax
	jmp .string_to_int_hex_next_char

.string_to_int_hex_done:
	mov ax, bx
	pop bx
	stc
	ret

.string_to_int_hex_error:
    pop bx
	clc
	ret


