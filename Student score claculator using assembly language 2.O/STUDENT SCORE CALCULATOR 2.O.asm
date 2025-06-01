                               .model small
.stack 100h
.data
header_msg db 0dh, 0ah, '+----------------------------------------+', 0dh, 0ah
           db '¦        ADVANCED GRADE CALCULATOR       ¦', 0dh, 0ah
           db '+----------------------------------------+', 0dh, 0ah, '$'

menu_msg db 0dh, 0ah, 'Choose Calculator Mode:', 0dh, 0ah
         db '1) Semester GPA Calculator', 0dh, 0ah
         db '2) Credit Hours Weighted Average', 0dh, 0ah
         db '3) Test Score Analyzer', 0dh, 0ah
         db '4) Grade Improvement Calculator', 0dh, 0ah
         db '5) Pass/Fail Checker', 0dh, 0ah
         db '6) Class Rank Calculator', 0dh, 0ah
         db '7) Attendance Impact Calculator', 0dh, 0ah
         db '8) Exit Program', 0dh, 0ah
         db 'Select option (1-8): $'

; Prompts for different modes
prompt_courses db 0dh, 0ah, 'Enter number of courses (1-5): $'
prompt_course_name db 0dh, 0ah, 'Course $'
prompt_score db ': Enter score (00-99): $'
prompt_credits db ': Enter credit hours (1-9): $'
prompt_current_avg db 0dh, 0ah, 'Enter current average (00-99): $'
prompt_target_grade db 0dh, 0ah, 'Enter target grade (00-99): $'
prompt_final_weight db 0dh, 0ah, 'Enter final exam weight % (10-99): $'
prompt_passing_grade db 0dh, 0ah, 'Enter passing grade (00-99): $'
prompt_total_students db 0dh, 0ah, 'Enter total students in class (01-99): $'
prompt_your_score db 0dh, 0ah, 'Enter your score (00-99): $'
prompt_attendance db 0dh, 0ah, 'Enter attendance % (00-99): $'
prompt_min_attendance db 0dh, 0ah, 'Enter minimum required % (00-99): $'

; Test analyzer prompts
prompt_test1 db 0dh, 0ah, 'Enter Test 1 score (00-99): $'
prompt_test2 db 0dh, 0ah, 'Enter Test 2 score (00-99): $'
prompt_test3 db 0dh, 0ah, 'Enter Test 3 score (00-99): $'
prompt_quiz1 db 0dh, 0ah, 'Enter Quiz 1 score (00-99): $'
prompt_quiz2 db 0dh, 0ah, 'Enter Quiz 2 score (00-99): $'

; Result messages
result_gpa db 0dh, 0ah, '? Semester GPA: $'
result_weighted db 0dh, 0ah, '? Weighted Average: $'
result_needed db 0dh, 0ah, '? Score needed on final: $'
result_status db 0dh, 0ah, '? Status: $'
result_rank db 0dh, 0ah, '? Your class rank: $'
result_percentile db 0dh, 0ah, '? You scored better than $'
result_attendance db 0dh, 0ah, '? Attendance impact: $'

; Status messages
status_pass db 'PASS ?$'
status_fail db 'FAIL ?$'
status_excellent db 'EXCELLENT$'
status_good db 'GOOD$'
status_satisfactory db 'SATISFACTORY$'
status_needs_improvement db 'NEEDS IMPROVEMENT$'
status_impossible db 'IMPOSSIBLE TO ACHIEVE$'
status_achievable db 'ACHIEVABLE$'

; Analysis messages
analysis_header db 0dh, 0ah, '--- PERFORMANCE ANALYSIS ---', 0dh, 0ah, '$'
strongest_subject db 0dh, 0ah, '? Strongest area: Course $'
weakest_subject db 0dh, 0ah, '? Weakest area: Course $'
improvement_msg db 0dh, 0ah, '? Improvement needed: $'
points_msg db ' points$'
percent_sign db '%$'
of_students db '% of students$'

error_msg db 0dh, 0ah, '? ERROR: Invalid input! Try again.$'
continue_msg db 0dh, 0ah, 'Press any key to continue...$'

; Data storage
num_courses db 0
course_scores db 5 dup(0)
credit_hours db 5 dup(0)
current_avg db 0
target_grade db 0
final_weight db 0
test_scores db 5 dup(0)
total_students db 0
your_score db 0
attendance_pct db 0
min_attendance db 0
result dw 0
temp_result dw 0

.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Display header
    mov ah, 09h
    lea dx, header_msg
    int 21h
    
main_loop:
    call display_menu
    
    ; Read menu choice
    mov ah, 01h
    int 21h
    
    cmp al, '1'
    je mode_gpa
    cmp al, '2'
    je mode_weighted
    cmp al, '3'
    je mode_analyzer
    cmp al, '4'
    je mode_improvement
    cmp al, '5'
    je mode_pass_fail
    cmp al, '6'
    je mode_rank
    cmp al, '7'
    je mode_attendance
    cmp al, '8'
    je exit
    jmp error

mode_gpa:
    call semester_gpa_calculator
    jmp continue_program

mode_weighted:
    call credit_weighted_calculator
    jmp continue_program

mode_analyzer:
    call test_score_analyzer
    jmp continue_program

mode_improvement:
    call grade_improvement_calculator  
    jmp continue_program

mode_pass_fail:
    call pass_fail_checker
    jmp continue_program

mode_rank:
    call class_rank_calculator
    jmp continue_program

mode_attendance:
    call attendance_calculator
    jmp continue_program

continue_program:
    call pause_program
    jmp main_loop

error:
    mov ah, 09h
    lea dx, error_msg
    int 21h
    jmp main_loop

exit:
    mov ah, 4ch
    int 21h

main endp

; -------------------------------------------
; PROCEDURE: Display Menu
; -------------------------------------------
display_menu proc
    mov ah, 09h
    lea dx, menu_msg
    int 21h
    ret
display_menu endp

; -------------------------------------------
; PROCEDURE: Semester GPA Calculator
; -------------------------------------------
semester_gpa_calculator proc
    ; Get number of courses
    mov ah, 09h
    lea dx, prompt_courses
    int 21h
    call read_single_digit
    cmp al, 0
    je sgc_error
    cmp al, 5
    ja sgc_error
    mov num_courses, al
    
    ; Read course scores
    mov cl, num_courses
    mov si, 0
    mov bl, 1  ; Course counter
    
sgc_loop:
    push cx
    push bx
    
    ; Display course prompt
    mov ah, 09h
    lea dx, prompt_course_name
    int 21h
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    mov ah, 09h
    lea dx, prompt_score
    int 21h
    
    call read_number
    cmp al, 0ffh
    je sgc_error
    mov course_scores[si], al
    
    inc si
    pop bx
    inc bl
    pop cx
    loop sgc_loop
    
    ; Calculate GPA
    call calculate_gpa
    mov ah, 09h
    lea dx, result_gpa
    int 21h
    call display_number
    call display_grade_status
    ret
    
sgc_error:
    jmp error
semester_gpa_calculator endp

; -------------------------------------------
; PROCEDURE: Credit Hours Weighted Calculator
; -------------------------------------------
credit_weighted_calculator proc
    ; Get number of courses
    mov ah, 09h
    lea dx, prompt_courses
    int 21h
    call read_single_digit
    cmp al, 0
    je cwc_error
    cmp al, 5
    ja cwc_error
    mov num_courses, al
    
    ; Read course scores and credits
    mov cl, num_courses
    mov si, 0
    mov bl, 1
    
cwc_loop:
    push cx
    push bx
    
    ; Get score
    mov ah, 09h
    lea dx, prompt_course_name
    int 21h
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    mov ah, 09h
    lea dx, prompt_score
    int 21h
    
    call read_number
    cmp al, 0ffh
    je cwc_error
    mov course_scores[si], al
    
    ; Get credit hours
    mov ah, 09h
    lea dx, prompt_course_name
    int 21h
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h
    mov ah, 09h
    lea dx, prompt_credits
    int 21h
    
    call read_single_digit
    cmp al, 0
    je cwc_error
    mov credit_hours[si], al
    
    inc si
    pop bx
    inc bl
    pop cx
    loop cwc_loop
    
    ; Calculate weighted average
    call calculate_weighted_average
    mov ah, 09h
    lea dx, result_weighted
    int 21h
    call display_number
    ret
    
cwc_error:
    jmp error
credit_weighted_calculator endp

; -------------------------------------------
; PROCEDURE: Test Score Analyzer
; -------------------------------------------
test_score_analyzer proc
    ; Read test scores
    mov ah, 09h
    lea dx, prompt_test1
    int 21h
    call read_number
    cmp al, 0ffh
    je tsa_error
    mov test_scores[0], al
    
    mov ah, 09h
    lea dx, prompt_test2
    int 21h
    call read_number
    cmp al, 0ffh
    je tsa_error
    mov test_scores[1], al
    
    mov ah, 09h
    lea dx, prompt_test3
    int 21h
    call read_number
    cmp al, 0ffh
    je tsa_error
    mov test_scores[2], al
    
    mov ah, 09h
    lea dx, prompt_quiz1
    int 21h
    call read_number
    cmp al, 0ffh
    je tsa_error
    mov test_scores[3], al
    
    mov ah, 09h
    lea dx, prompt_quiz2
    int 21h
    call read_number
    cmp al, 0ffh
    je tsa_error
    mov test_scores[4], al
    
    ; Analyze performance
    call analyze_test_performance
    ret
    
tsa_error:
    jmp error
test_score_analyzer endp

; -------------------------------------------
; PROCEDURE: Grade Improvement Calculator
; -------------------------------------------
grade_improvement_calculator proc
    ; Get current average
    mov ah, 09h
    lea dx, prompt_current_avg
    int 21h
    call read_number
    cmp al, 0ffh
    je gic_error
    mov current_avg, al
    
    ; Get target grade
    mov ah, 09h
    lea dx, prompt_target_grade
    int 21h
    call read_number
    cmp al, 0ffh
    je gic_error
    mov target_grade, al
    
    ; Get final exam weight
    mov ah, 09h
    lea dx, prompt_final_weight
    int 21h
    call read_number
    cmp al, 0ffh
    je gic_error
    mov final_weight, al
    
    ; Calculate needed score
    call calculate_needed_score
    ret
    
gic_error:
    jmp error
grade_improvement_calculator endp

; -------------------------------------------
; PROCEDURE: Pass/Fail Checker
; -------------------------------------------
pass_fail_checker proc
    ; Get passing grade
    mov ah, 09h
    lea dx, prompt_passing_grade
    int 21h
    call read_number
    cmp al, 0ffh
    je pfc_error
    mov bl, al  ; Store passing grade
    
    ; Get your score
    mov ah, 09h
    lea dx, prompt_your_score
    int 21h
    call read_number
    cmp al, 0ffh
    je pfc_error
    mov your_score, al
    
    ; Check pass/fail
    mov ah, 09h
    lea dx, result_status
    int 21h
    
    cmp al, bl
    jae pfc_pass
    lea dx, status_fail
    jmp pfc_show
pfc_pass:
    lea dx, status_pass
pfc_show:
    mov ah, 09h
    int 21h
    ret
    
pfc_error:
    jmp error
pass_fail_checker endp

; -------------------------------------------
; PROCEDURE: Class Rank Calculator
; -------------------------------------------
class_rank_calculator proc
    ; Get total students
    mov ah, 09h
    lea dx, prompt_total_students
    int 21h
    call read_number
    cmp al, 0ffh
    je crc_error
    mov total_students, al
    
    ; Get your score
    mov ah, 09h
    lea dx, prompt_your_score
    int 21h
    call read_number
    cmp al, 0ffh
    je crc_error
    mov your_score, al
    
    ; Calculate percentile (simplified)
    mov al, your_score
    mov bl, 100
    mul bl
    div total_students
    mov result, ax
    
    mov ah, 09h
    lea dx, result_percentile
    int 21h
    call display_number
    mov ah, 09h
    lea dx, of_students
    int 21h
    ret
    
crc_error:
    jmp error
class_rank_calculator endp

; -------------------------------------------
; PROCEDURE: Attendance Impact Calculator
; -------------------------------------------
attendance_calculator proc
    ; Get attendance percentage
    mov ah, 09h
    lea dx, prompt_attendance
    int 21h
    call read_number
    cmp al, 0ffh
    je ac_error
    mov attendance_pct, al
    
    ; Get minimum required
    mov ah, 09h
    lea dx, prompt_min_attendance
    int 21h
    call read_number
    cmp al, 0ffh
    je ac_error
    mov min_attendance, al
    
    ; Calculate impact
    mov al, attendance_pct
    sub al, min_attendance
    cbw
    mov result, ax
    
    mov ah, 09h
    lea dx, result_attendance
    int 21h
    call display_number
    mov ah, 09h
    lea dx, points_msg
    int 21h
    ret
    
ac_error:
    jmp error
attendance_calculator endp

; -------------------------------------------
; HELPER PROCEDURES
; -------------------------------------------

calculate_gpa proc
    ; Simple GPA calculation - average of all courses
    mov al, 0
    mov cl, num_courses
    mov si, 0
    
cgpa_loop:
    add al, course_scores[si]
    inc si
    loop cgpa_loop
    
    mov ah, 0
    mov bl, num_courses
    div bl
    mov result, ax
    ret
calculate_gpa endp

calculate_weighted_average proc
    ; Weighted average calculation
    mov ax, 0  ; Total points
    mov bx, 0  ; Total credits
    mov cl, num_courses
    mov si, 0
    
cwa_loop:
    push ax
    push bx
    
    mov al, course_scores[si]
    mul credit_hours[si]
    pop bx
    add bx, ax
    
    pop ax
    mov al, credit_hours[si]
    mov ah, 0
    add ax, bx
    mov bx, ax
    
    inc si
    loop cwa_loop
    
    ; Now AX has total weighted points, BX has total credits
    mov ax, bx
    mov bl, num_courses
    div bl
    mov result, ax
    ret
calculate_weighted_average endp

calculate_needed_score proc
    ; Calculate score needed on final exam
    mov al, target_grade
    mov bl, 100
    mul bl
    mov bx, ax  ; Target * 100
    
    mov al, current_avg
    mov cl, 100
    sub cl, final_weight
    mul cl
    
    sub bx, ax
    mov ax, bx
    div final_weight
    
    cmp ax, 100
    jbe cns_achievable
    mov ah, 09h
    lea dx, result_needed
    int 21h
    lea dx, status_impossible
    int 21h
    ret
    
cns_achievable:
    mov result, ax
    mov ah, 09h
    lea dx, result_needed
    int 21h
    call display_number
    mov ah, 09h
    lea dx, status_achievable
    int 21h
    ret
calculate_needed_score endp

analyze_test_performance proc
    ; Calculate average of test scores
    mov al, test_scores[0]
    add al, test_scores[1]
    add al, test_scores[2]
    add al, test_scores[3]
    add al, test_scores[4]
    mov ah, 0
    mov bl, 5
    div bl
    mov result, ax
    
    mov ah, 09h
    lea dx, analysis_header
    int 21h
    mov ah, 09h
    lea dx, result_gpa
    int 21h
    call display_number
    call display_grade_status
    ret
analyze_test_performance endp

display_grade_status proc
    mov ax, result
    cmp ax, 90
    jae dgs_excellent
    cmp ax, 80
    jae dgs_good
    cmp ax, 70
    jae dgs_satisfactory
    lea dx, status_needs_improvement
    jmp dgs_show
dgs_excellent:
    lea dx, status_excellent
    jmp dgs_show
dgs_good:
    lea dx, status_good
    jmp dgs_show
dgs_satisfactory:
    lea dx, status_satisfactory
dgs_show:
    mov ah, 09h
    int 21h
    ret
display_grade_status endp

pause_program proc
    mov ah, 09h
    lea dx, continue_msg
    int 21h
    mov ah, 01h
    int 21h
    ret
pause_program endp

read_single_digit proc
    mov ah, 01h
    int 21h
    sub al, '0'
    cmp al, 9
    ja rsd_invalid
    ret
rsd_invalid:
    mov al, 0
    ret
read_single_digit endp

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
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
display_number endp

end main