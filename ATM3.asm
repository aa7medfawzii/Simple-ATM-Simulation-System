; ============================================
;      ATM SIMULATOR (8086 Assembly - TASM)
; ============================================
; Features:
; ✔ Password Login (1234, 3 attempts)
; ✔ Multi-digit Deposit
; ✔ Multi-digit Withdrawal
; ✔ Balance Display
; ============================================

.MODEL small
.STACK 100h

.DATA
; ---------- Messages ----------
msg_title     db 13,10,"=== SIMPLE ATM ===",13,10,'$'
msg_menu      db "1) Check Balance",13,10,\
                "2) Deposit",13,10,\
                "3) Withdraw",13,10,\
                "4) Exit",13,10,\
                "Choose: $"

msg_balance   db 13,10,"Balance = $"
msg_depos     db 13,10,"Enter Deposit Amount: $"
msg_with      db 13,10,"Enter Withdrawal Amount: $"
msg_no_fund   db 13,10,"Not enough balance!",13,10,"$"
msg_ok        db 13,10,"Operation successful!",13,10,"$"
msg_bye       db 13,10,"Goodbye!",13,10,"$"

msg_pass       db 13,10,"Enter Password: $"
msg_pass_ok    db 13,10,"Access Granted!",13,10,"$"
msg_pass_fail  db 13,10,"Wrong Password!",13,10,"$"
msg_pass_denied db 13,10,"Access Denied!",13,10,"$"

; ---------- Variables ----------
balance       dw 1000

input_buf     db 6,0,6 dup(0)      ; for deposit/withdraw input
pass_buf      db 6,0,6 dup(0)      ; for password input
correct_pass  db '1234'            ; password (NO $ !!!)


.CODE
MAIN PROC
    mov ax,@data
    mov ds,ax

; ============================================
;          PASSWORD LOGIN (FIXED)
; ============================================
    mov cx,3         ; 3 attempts
pw_try:
    lea dx,msg_pass
    mov ah,09h
    int 21h

    lea dx,pass_buf
    mov ah,0Ah       ; buffered input
    int 21h

    ; Must be length 4
    mov al,pass_buf+1
    cmp al,4
    jne pw_wrong

    ; Compare 4 digits
    lea si,pass_buf+2
    lea di,correct_pass
    mov cx,4
pw_cmp:
    mov al,[si]
    cmp al,[di]
    jne pw_wrong
    inc si
    inc di
    loop pw_cmp

    ; SUCCESS
    lea dx,msg_pass_ok
    mov ah,09h
    int 21h
    jmp start_menu

pw_wrong:
    lea dx,msg_pass_fail
    mov ah,09h
    int 21h
    loop pw_try

    lea dx,msg_pass_denied
    mov ah,09h
    int 21h
    mov ax,4C00h
    int 21h

; ============================================
;                MAIN MENU
; ============================================
start_menu:
    lea dx,msg_title
    mov ah,09h
    int 21h

    lea dx,msg_menu
    mov ah,09h
    int 21h

    mov ah,1
    int 21h
    sub al,'0'

    cmp al,1
    je show_balance
    cmp al,2
    je deposit
    cmp al,3
    je withdraw
    cmp al,4
    je exit_prog
    jmp start_menu

; ============================================
;             SHOW BALANCE
; ============================================
show_balance:
    lea dx,msg_balance
    mov ah,09h
    int 21h

    mov ax,balance
    call print_number
    jmp wait_key

; ============================================
;                 DEPOSIT
; ============================================
deposit:
    lea dx,msg_depos
    mov ah,09h
    int 21h

    call read_number
    add balance,ax

    lea dx,msg_ok
    mov ah,09h
    int 21h
    jmp wait_key

; ============================================
;                 WITHDRAW
; ============================================
withdraw:
    lea dx,msg_with
    mov ah,09h
    int 21h

    call read_number  ; AX = amount entered

    mov bx,balance
    cmp bx,ax
    jb no_money

    sub balance,ax
    lea dx,msg_ok
    mov ah,09h
    int 21h
    jmp wait_key

no_money:
    lea dx,msg_no_fund
    mov ah,09h
    int 21h
    jmp wait_key

; ============================================
;       READ MULTI-DIGIT NUMBER (INT 21h 0Ah)
; ============================================
read_number PROC
    lea dx,input_buf
    mov ah,0Ah
    int 21h

    mov cl,input_buf+1     ; number of digits
    mov si,offset input_buf+2
    xor ax,ax              ; result = 0

convert_loop:
    mov bl,[si]
    sub bl,'0'
    mov bh,0

    mov dx,ax
    mov ax,10
    mul dx                ; ax *= 10
    add ax,bx             ; ax += digit

    inc si
    loop convert_loop
    ret
read_number ENDP

; ============================================
;              WAIT FOR KEY
; ============================================
wait_key:
    mov ah,1
    int 21h
    jmp start_menu

; ============================================
;                 EXIT
; ============================================
exit_prog:
    lea dx,msg_bye
    mov ah,09h
    int 21h

    mov ax,4C00h
    int 21h

; ============================================
;            PRINT NUMBER ROUTINE
; ============================================
print_number PROC
    push ax
    push bx
    push cx
    push dx

    xor cx,cx
pn_loop:
    xor dx,dx
    mov bx,10
    div bx
    add dl,'0'
    push dx
    inc cx
    cmp ax,0
    jne pn_loop

print_loop:
    pop dx
    mov ah,02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_number ENDP

MAIN ENDP
END MAIN
