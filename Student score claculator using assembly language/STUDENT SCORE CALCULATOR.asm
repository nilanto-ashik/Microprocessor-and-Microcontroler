.model small
.stack 100h
.data
menu_msg db 0dh, 0ah, '=== STUDENT SCORE CALCULATOR ===', 0dh, 0ah
         db 'Select the operation:', 0dh, 0ah
         db '1) Calculate Average of 3 Subjects', 0dh, 0ah
         db '2) Calculate Weighted Average', 0dh, 0ah
         db '3) Calculate Grade Points (GPA)', 0dh, 0ah
         db '4) Determine Letter Grade', 0dh, 0ah
         db '5) Calculate Percentage', 0dh, 0ah
         db '6) Exit', 0dh, 0ah
         db 'Enter your choice (1-6): $'

prompt1 db 0dh, 0ah, 'Enter first subject score (00-99): $'
prompt2 db 0dh, 0ah, 'Enter second subject score (00-99): $'
prompt3 db 0dh, 0ah, 'Enter third subject score (00-99): $'
prompt_total db 0dh, 0ah, 'Enter total obtained marks (000-999): $'
prompt_max db 0dh, 0ah, 'Enter maximum marks (000-999): $'
prompt_weight1 db 0dh, 0ah, 'Enter weight for subject 1 (01-99): $'
prompt_weight2 db 0dh, 0ah, 'Enter weight for subject 2 (01-99): $'
prompt_weight3 db 0dh, 0ah, 'Enter weight for subject 3 (01-99): $'

avg_msg db 0dh, 0ah, 'Average Score = $'
weighted_msg db 0dh, 0ah, 'Weighted Average = $'
gpa_msg db 0dh, 0ah, 'GPA (out of 4.0) = $'
grade_msg db 0dh, 0ah, 'Letter Grade: $'
percent_msg db 0dh, 0ah, 'Percentage = $'
percent_sign db '%$'

grade_a db 'A (Excellent)$'
grade_b db 'B (Good)$'
grade_c db 'C (Average)$'
grade_d db 'D (Below Average)$'
grade_f db 'F (Fail)$'

error_msg db 0dh, 0ah, 'Error: Invalid input!$'
newline db 0dh, 0ah, '$'

score1 db 0
score2 db 0
score3 db 0
weight1 db 0
weight2 db 0
weight3 db 0
total_marks dw 0
max_marks dw 0
result dw 0
operation db 0

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
    je calc_average
    cmp al, '2'
    je calc_weighted
    cmp al, '3'
    je calc_gpa
    cmp al, '4'
    je calc_letter_grade
    cmp al, '5'
    je calc_percentage
    cmp al, '6'
    je exit
    jmp error

calc_average:
    mov operation, '1'
    call read_three_scores
    ; Calculate average: (score1 + score2 + score3) / 3
    mov al, score1
    add al, score2
    add al, score3
    mov ah, 0
    mov bl, 3
    div bl
    mov result, ax
    lea dx, avg_msg
    jmp show_result

calc_weighted:
    mov operation, '2'
    call read_three_scores
    call read_weights
    ; Calculate weighted average
    mov al, score1
    mul weight1
    mov bx, ax
    mov al, score2
    mul weight2
    add bx, ax
    mov al, score3
    mul weight3
    add bx, ax
    ; Divide by sum of weights
    mov al, weight1
    add al, weight2
    add al, weight3
    mov cl, al
    mov ax, bx
    div cl
    mov result, ax
    lea dx, weighted_msg
    jmp show_result

calc_gpa:
    mov operation, '3'
    call read_three_scores
    ; Calculate GPA (assuming 90-100=4, 80-89=3, 70-79=2, 60-69=1, <60=0)
    mov al, score1
    add al, score2
    add al, score3
    mov ah, 0
    mov bl, 3
    div bl  ; Average in AL
    
    cmp al, 90
    jae gpa_4
    cmp al, 80
    jae gpa_3
    cmp al, 70
    jae gpa_2
    cmp al, 60
    jae gpa_1
    mov result, 0
    jmp gpa_done
gpa_4:
    mov result, 4
    jmp gpa_done
gpa_3:
    mov result, 3
    jmp gpa_done
gpa_2:
    mov result, 2
    jmp gpa_done
gpa_1:
    mov result, 1
gpa_done:
    lea dx, gpa_msg
    jmp show_result

calc_letter_grade:
    mov operation, '4'
    call read_three_scores
    ; Calculate average first
    mov al, score1
    add al, score2
    add al, score3
    mov ah, 0
    mov bl, 3
    div bl
    
    cmp al, 90
    jae show_grade_a
    cmp al, 80
    jae show_grade_b
    cmp al, 70
    jae show_grade_c
    cmp al, 60
    jae show_grade_d
    jmp show_grade_f

show_grade_a:
    mov ah, 09h
    lea dx, grade_msg
    int 21h
    lea dx, grade_a
    int 21h
    jmp main_loop
show_grade_b:
    mov ah, 09h
    lea dx, grade_msg
    int 21h
    lea dx, grade_b
    int 21h
    jmp main_loop
show_grade_c:
    mov ah, 09h
    lea dx, grade_msg
    int 21h
    lea dx, grade_c
    int 21h
    jmp main_loop
show_grade_d:
    mov ah, 09h
    lea dx, grade_msg
    int 21h
    lea dx, grade_d
    int 21h
    jmp main_loop
show_grade_f:
    mov ah, 09h
    lea dx, grade_msg
    int 21h
    lea dx, grade_f
    int 21h
    jmp main_loop

calc_percentage:
    mov operation, '5'
    ; Read total marks obtained
    mov ah, 09h
    lea dx, prompt_total
    int 21h
    call read_three_digit_number
    cmp ax, 0ffffh
    je error
    mov total_marks, ax
    
    ; Read maximum marks
    mov ah, 09h
    lea dx, prompt_max
    int 21h
    call read_three_digit_number
    cmp ax, 0ffffh
    je error
    mov max_marks, ax
    
    ; Calculate percentage: (total/max) * 100
    mov ax, total_marks
    mov bx, 100
    mul bx
    div max_marks
    mov result, ax
    
    mov ah, 09h
    lea dx, percent_msg
    int 21h
    call display_number
    mov ah, 09h
    lea dx, percent_sign
    int 21h
    jmp main_loop

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

; ----- Procedure: Read three scores -----
read_three_scores proc
    ; Read first score
    mov ah, 09h
    lea dx, prompt1
    int 21h
    call read_number
    cmp al, 0ffh
    je rs_error
    mov score1, al
    
    ; Read second score
    mov ah, 09h
    lea dx, prompt2
    int 21h
    call read_number
    cmp al, 0ffh
    je rs_error
    mov score2, al
    
    ; Read third score
    mov ah, 09h
    lea dx, prompt3
    int 21h
    call read_number
    cmp al, 0ffh
    je rs_error
    mov score3, al
    ret
rs_error:
    jmp error
read_three_scores endp

; ----- Procedure: Read weights -----
read_weights proc
    ; Read first weight
    mov ah, 09h
    lea dx, prompt_weight1
    int 21h
    call read_number
    cmp al, 0ffh
    je rw_error
    mov weight1, al
    
    ; Read second weight
    mov ah, 09h
    lea dx, prompt_weight2
    int 21h
    call read_number
    cmp al, 0ffh
    je rw_error
    mov weight2, al
    
    ; Read third weight
    mov ah, 09h
    lea dx, prompt_weight3
    int 21h
    call read_number
    cmp al, 0ffh
    je rw_error
    mov weight3, al
    ret
rw_error:
    jmp error
read_weights endp

; ----- Procedure: Read 2-digit number -----
read_number proc
    push bx
    push cx
    
    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja rn_invalid
    mov bl, al
    mov cl, 10
    mul cl
    mov bh, al
    
    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja rn_invalid
    add al, bh
    jmp rn_done
    
rn_invalid:
    mov al, 0ffh
    
rn_done:
    pop cx
    pop bx
    ret
read_number endp

; ----- Procedure: Read 3-digit number -----
read_three_digit_number proc
    push bx
    push cx
    push dx
    
    mov cx, 3
    mov bx, 0
    mov dx, 1
    
rtdn_loop:
    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja rtdn_invalid
    
    mov ah, 0
    mul dx
    add bx, ax
    
    mov ax, dx
    mov dx, 10
    mul dx
    mov dx, ax
    
    loop rtdn_loop
    
    mov ax, bx
    jmp rtdn_done
    
rtdn_invalid:
    mov ax, 0ffffh
    
rtdn_done:
    pop dx
    pop cx
    pop bx
    ret
read_three_digit_number endp

; ----- Procedure: Display number -----
display_number proc
    push ax
    push bx
    push cx
    push dx
    
    mov ax, result
    cmp ax, 0
    jge dn_skip_neg
    mov ah, 02h
    mov dl, '-'
    int 21h
    neg ax
    
dn_skip_neg:
    mov bx, 10
    mov cx, 0
    
dn_next_digit:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz dn_next_digit
    
dn_print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop dn_print_digits
    
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