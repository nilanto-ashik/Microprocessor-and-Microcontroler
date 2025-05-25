.model small
.stack 100h

.data
menu_msg db 0dh, 0ah, 'Select the operation:', 0dh, 0ah
         db '1) Addition', 0dh, 0ah
         db '2) Subtraction', 0dh, 0ah
         db '3) Multiplication', 0dh, 0ah
         db '4) Division', 0dh, 0ah
         db '5) Exit', 0dh, 0ah
         db 'Enter your choice between (1-5): $'

prompt1 db 0dh, 0ah, 'Enter first number (00-99): $'
prompt2 db 0dh, 0ah, 'Enter second number (00-99): $'

add_msg db 0dh, 0ah, 'The Result of Addition is = $'
sub_msg db 0dh, 0ah, 'The Result of Subtraction is = $'
mul_msg db 0dh, 0ah, 'The Result of Multiplication is = $'
div_msg db 0dh, 0ah, 'The Result of Division is = $'

error_msg db 0dh, 0ah, 'Error: Invalid input or division by zero$'

num1 db 0
num2 db 0
operator db 0
result dw 0

.code
main proc
    mov ax, @data
    mov ds, ax

main_loop:
    call display_menu

    ; Read menu choice
    mov ah, 01h
    int 21h
    cmp al, '1'
    je set_add
    cmp al, '2'
    je set_sub
    cmp al, '3'
    je set_mul
    cmp al, '4'
    je set_div
    cmp al, '5'
    je exit
    jmp error

set_add:
    mov operator, '+'
    jmp read_inputs
set_sub:
    mov operator, '-'
    jmp read_inputs
set_mul:
    mov operator, '*'
    jmp read_inputs
set_div:
    mov operator, '/'
    jmp read_inputs

read_inputs:
    ; Read first number
    mov ah, 09h
    lea dx, prompt1
    int 21h
    call read_number
    cmp al, 0ffh
    je error
    mov num1, al

    ; Read second number
    mov ah, 09h
    lea dx, prompt2
    int 21h
    call read_number
    cmp al, 0ffh
    je error
    mov num2, al

    ; Perform calculation
    mov al, num1
    mov bl, num2
    cmp operator, '+'
    je do_add
    cmp operator, '-'
    je do_sub
    cmp operator, '*'
    je do_mul
    cmp operator, '/'
    je do_div
    jmp error

do_add:
    add al, bl
    mov ah, 0
    mov result, ax
    lea dx, add_msg
    jmp show_result

do_sub:
    sub al, bl
    cbw
    mov result, ax
    lea dx, sub_msg
    jmp show_result

do_mul:
    mov ah, 0
    mul bl
    mov result, ax
    lea dx, mul_msg
    jmp show_result

do_div:
    cmp bl, 0
    je error
    mov ah, 0
    div bl
    mov result, ax
    lea dx, div_msg
    jmp show_result

error:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp main_loop

show_result:
    mov ah, 09h
    int 21h
    call display_number
    jmp main_loop

exit:
    mov ah, 4ch
    int 21h
main endp

; ----- Procedure: Display menu -----
display_menu proc
    mov ah, 09h
    lea dx, menu_msg
    int 21h
    ret
display_menu endp

; ----- Procedure: Read 2-digit number -----
read_number proc
    push bx
    push cx

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja invalid
    mov bl, al
    mov cl, 10
    mul cl
    mov bh, al

    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja invalid
    add al, bh
    jmp done

invalid:
    mov al, 0ffh

done:
    pop cx
    pop bx
    ret
read_number endp

; ----- Procedure: Display number -----
display_number proc
    push ax
    push bx
    push cx
    push dx

    mov ax, result
    cmp ax, 0
    jge skip_neg
    mov ah, 02h
    mov dl, '-'
    int 21h
    neg ax

skip_neg:
    mov bx, 10
    mov cx, 0

next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz next_digit

print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits

    ; Print newline
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_number endp

end main
