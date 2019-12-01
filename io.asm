;rbx , rbp , rsp , or r12-r15 - callee saved -change back if changed

global	 _start

section .data


section .text

exit:
	mov 	rax, 60
	syscall
	ret	

string_length:
	xor 	rax, rax
.L1:
	cmp 	byte[rdi + rax], 0				;comparing string character with null character
	je		.ex
	inc		rax
	jmp 	.L1
.ex:
	ret

print_string:
	call 	string_length
	mov 	rdx, rax 		;move to number of characters to be printed
	mov 	rax, 1			;syscall number is 1
	mov		rsi, rdi		;move string to be printed to proper reg
	mov		rdi, 1			;file descriptor
	syscall
	ret

print_char:
	push 	rdi
	mov 	rsi, rsp	;pointer to where character was pushed to
	mov 	rax, 1		;syscall number for printing on stdout
	mov 	rdi, 1		;file descriptor for stdout
	mov 	rdx, 1		;number of characters to be printed
	syscall			
	pop rdi
	ret

print_newline:
	mov 	rdi, 10
	call 	print_char
	ret


print_uint:
    mov rax, rdi
    mov rdi, rsp
    push 0
    sub rsp, 16
    
    dec rdi
    mov r8, 10

.loop:
    xor rdx, rdx
    div r8
    or  dl, 0x30
    dec rdi 
    mov [rdi], dl
    test rax, rax
    jnz .loop 
   
    call print_string
    
    add rsp, 24
    ret

print_int:
	cmp		rdi, 0
	jge		.positive
	push 	rdi
	mov		rdi, '-'
	call 	print_char
	pop		rdi
	neg 	rdi
.positive:
	call print_uint	

	ret

read_char:
	sub 	rsp, 8
	xor		rax, rax
	xor		rdi, rdi
	mov 	rsi, rsp
	mov 	rdx, 1
	syscall
	pop 	rax	
	ret



read_word:
	push 	r13
	xor		r13, r13
.L1:
	cmp		r13, rsi
	je		.err
	push	rdi
	push	rsi
	call 	read_char
	pop		rsi
	pop		rdi

	cmp		rax, ' '
	je		.done	
	cmp		rax, 13
	je		.done
	cmp		rax, 10
	je		.done
	cmp		rax, 9
	je		.done

	mov		byte[rdi + r13], al

	inc 	r13
	jmp		.L1
	
.err:
	xor		rax, rax
	jmp		exit
.done:
	mov		byte[rdi + r13], 0
	mov 	rax, rdi
.exit:
	pop 	r13
	ret

;rdi - null terminated string
parse_uint:
	mov 	rcx, rdi
	xor 	rax, rax
	mov 	r8, 1
.L1:
	cmp 	byte[rcx], 0
	je		.L2	
	inc 	rcx	
	jmp		.L1
	
.L2:	
	dec 	rcx
	mov		rdx, [rcx]
	and		rdx, 0xf
	imul	rdx, r8
	add		rax, rdx
	imul	r8, 10
	cmp 	rcx, rdi
	jg		.L2	
	
.done:
	ret

parse_int:
	cmp		byte[rdi], '-'
	jne		.uint
	inc		rdi
	call	parse_uint
	neg		rax
	jmp		.done
.uint:
	call 	parse_uint
.done:	
	ret

string_equals:
	xor		rcx, rcx
.L1:
	mov 	r8b, [rdi + rcx] 
	cmp		r8b, byte[rsi + rcx]
	jne		.false
	cmp		r8b, 0	;if equal check if end of string (null terminator)
	je		.true
	inc		rcx
	jmp		.L1
.true:
	mov		rax, 1
	jmp 	.done
.false:
	xor		rax, rax
.done:
	ret

;rdi - src, rsi - dest, rdx - count
string_copy:
	xor 	rcx, rcx
.L1:
	cmp		rdx, rcx	
	jb		.err
	mov 	r8b, byte[rdi + rcx]
	mov		byte[rsi + rcx], r8b
	inc 	rcx	
	test	r8b, r8b
	jnz		.L1	
		
	mov		rax, rsi
	jmp		.done
.err:
	xor		rax, rax
.done:
	ret

_start:
	sub		rsp, 24
	mov		rdi, rsp
	mov		rsi, 24
	call 	read_word
	mov		rdi, rax
	call 	print_string
	call 	print_newline
	add		rsp, 24

	xor		rdi, rdi
	call 	exit




