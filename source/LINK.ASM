    title   Web Link linking routines
    type    8521

    program

    include weblink.inc

    global  link_steps

; Array of functions - ran in order
link_steps:
    dw      link_init
    dw      link_intro
    dw      link_menu
    dw      lbl_60fah
    dw      lbl_614dh
    dw      lbl_618ah

; Initialisation for link procedure
link_init:
    ; Set animation bank/address
    mov     anim_bank,#anim_start_bank
    movw    anim_addr,#anim_start_addr-anim_frame_len
    ; Control keyboard
    mov     r0,#kctrl_membrane ; flags
    call    CTRL_KBD
    ; Advance function
    jmp     func_advance

; Web Link intro animation
link_intro:
    ; Start playing music
    call    play_melody
    mov     r8,#3
    ; Read animation address
    movw    rr12,anim_addr
    ; Check if all frames played
    mov     r3,anim_frame
    cmp     r3,#13
    ; Nope, draw next frame
    br      ne,intro_draw
    mov     r0,anim_bank
    mov     mem_d1,r0
    ; 
    addw    rr12,#anim_frame_len
    bbc     r12,#7,lbl_603ch
    inc     anim_bank
    subw    rr12,#bank_len
lbl_603ch:
    movw    mem_ce,rr12
    jmp     func_advance
intro_draw:
    movw    rr8,#0a0c8h ; height, width
    mov     r10,#8 ; flags - no compression
    bbs     cur_page,#0,intro_page_a
    bset    r10,#0 ; flags - page B
intro_page_a:
    addw    rr12,#anim_frame_len
    bbc     r12,#7,lbl_605ah
    inc     anim_bank
    subw    rr12,#bank_len
lbl_605ah:
    movw    anim_addr,rr12
    mov     r11,anim_bank
    movw    rr14,#0
    call    Fi_graph2
    call    Swap_page
    inc     anim_frame
    movw    rr2,#6000h
intro_delay:
    decw    rr2
    br      nz,intro_delay
    jmp     main_loop

; Web Link menu screen
link_menu:
    ; Start playing melody
    call    play_melody
    ; Start if 'A' key pressed
    cmp     last_key,#key_a
    br      eq,menu_start
    ;
    ; Check if screen touched within bounds
    ;
    ; Out of bounds, draw next animation frame
    cmp     last_key,#7*13+5
    br      lt,menu_draw
    cmp     last_key,#8*13+8
    br      gt,menu_draw
    ; In bounds, start linking
    cmp     last_key,#7*13+9
    br      lt,menu_start
    cmp     last_key,#8*13+5
    br      gt,menu_start
    ;
menu_draw:
    movw    rr8,#0a0c8h ; height, width (160x200)
    mov     r10,#8 ; flags - no compression
    bbs     cur_page,#0,menu_page_a
    bset    r10,#0 ; flags - page B
menu_page_a:
    mov     r11,mem_d1 ; bank
    movw    rr12,anim_addr ; address
    bbs     anim_frame,#2,no_reset
    mov     r11,anim_bank ; bank
    movw    rr12,mem_ce ; address
no_reset:
    movw    rr14,#0000h ; x, y
    call    Fi_graph2
    call    Swap_page
    inc     anim_frame
    jmp     main_loop
menu_start:
    call    stop_melody
    call    uart_setup
    mov     recv_checksum,#1
    jmp     func_advance

; Searches for high score entry (savegame) in SRAM
find_hiscr:
    ; Set search start address (0xfc23)
    movw    rr2,#hiscr_data_start-hiscr_entry_length+hiscr_str_offset
    ; Search for 10 entries (+1 for dbnz)
    mov     r6,#hiscr_num_entries+1
next_entry:
    ; Check next entry if not exhausted
    dbnz    r6,find_next
    ; Entry not found - set carry flag
    setc
    ret
find_next:
    ; Advance to next high score entry (length 64)
    addw    rr2,#hiscr_entry_length
    ; Set addresses
    movw    rr10,rr2
    movw    rr8,#tmp_hiscr_str
    ; Compare up to 11 characters (+1 for dbnz)
    mov     r7,#hiscr_str_length+1
str_loop:
    ; Compare character in high score to temp
    mov     r1,(rr10)+
    cmp     r1,(rr8)+
    ; If characters not equal, check next entry
    br      ne,next_entry
    ; Check for string end marker (1)
    cmp     r1,#hiscr_str_end
    ; If end marker, check ID
    br      eq,check_id
    ; Check next character if not exhausted
    dbnz    r7,str_loop
check_id:
    ; Go to start (ID section) of high score entry (-3)
    subw    rr2,#hiscr_str_offset
    ; OR the two program ID bytes together
    mov     r1,@rr2
    or      r1,1(rr2)
    ; If either byte is not 0, it's a valid ID
    br      nz,valid_id
    ; Go to string section of high score entry (+3)
    addw    rr2,#hiscr_str_offset
    ; Check next entry
    br      next_entry
valid_id:
    ; Entry found - clear carry flag
    clrc
    ret

lbl_60fah:
    cmp     recv_checksum,#1
    jmp     ne,func_advance
    mov     r8,#3
    movw    rr12,anim_addr
    movw    rr8,#0a0c8h
    mov     r10,#8
    bbs     cur_page,#0,lbl_6111h
    bset    r10,#0
lbl_6111h:
    bbc     anim_frame,#0,lbl_6121h
    addw    rr12,#1f40h
    bbc     r12,#7,lbl_6121h
    inc     mem_d1
    subw    rr12,#2000h
lbl_6121h:
    movw    anim_addr,rr12
    mov     r11,mem_d1
    movw    rr14,#0000h
    call    Fi_graph2
    call    Swap_page
    inc     anim_frame
    cmp     anim_frame,#21
    br      ne,lbl_6147h
    mov     r0,#6
    mov     anim_frame,r0
    movw    rr12,#7340h
    movw    anim_addr,rr12
    mov     r11,#33h
    mov     mem_d1,r11
lbl_6147h:
    call    check_cmd
    jmp     main_loop

lbl_614dh:
    mov     r8,#3
    movw    rr12,anim_addr
    movw    rr8,#0a0c8h ; height, width
    mov     r10,#8
    bbs     cur_page,#0,lbl_615eh
    bset    r10,#0
lbl_615eh:
    bbc     anim_frame,#0,lbl_616eh
    addw    rr12,#1f40h
    bbc     r12,#7,lbl_616eh
    inc     mem_d1
    subw    rr12,#2000h
lbl_616eh:
    movw    anim_addr,rr12
    mov     r11,mem_d1
    movw    rr14,#0000h
    call    Fi_graph2
    call    Swap_page
    inc     anim_frame
    cmp     mem_d1,#3eh
    br      z,lbl_6187h
    jmp     main_loop
lbl_6187h:
    jmp     z,func_advance

lbl_618ah:
    mov     r0,last_key
    cmp     r0,#key_menu
    br      ne,lbl_61aeh
    call    Disp_setup
    movw    rr12,#6b00h
    movw    rr8,#0a0c8h
    mov     r10,#8
    bbs     cur_page,#0,lbl_61a2h
    bset    r10,#0
lbl_61a2h:
    mov     r11,#3eh
    movw    rr14,#0
    call    Fi_graph2
    call    Swap_page
lbl_61aeh:
    call    check_cmd
    jmp     main_loop

; Check and handle command received
check_cmd:
    ; Try and receive byte from PC
    call    Receive_a_byte
    br      c,no_recv
lbl_61b9h:
    mov     r1,recv_checksum
    movw    rr4,#0
lbl_61beh:
    cmp     r0,numbers(rr4)
    br      eq,lbl_61cch
    addw    rr4,#2
    dbnz    r1,lbl_61beh
    setc
    ret
lbl_61cch:
    xor     r0,#0ffh
    push    r0
    clr     r0
    movw    rr14,#2000h
lbl_61d6h:
    decw    rr14
    br      z,lbl_61f3h
    pushw   rr14
    call    Receive_a_byte
    popw    rr14
    br      c,lbl_61d6h
    pop     r1
    cmp     r0,r1
    br      nz,lbl_61b9h
    mov     send_checksum,#0
    mov     recv_checksum,#0ffh
    jmp     @cmd_funcs(r5)
lbl_61f3h:
    pop     r0
no_recv:
    setc
    ret

lbl_61f7h:
    mov     recv_checksum,#6
    br      lbl_6207h

lbl_61fch:
    mov     recv_checksum,#1
    call    lbl_6207h
    popw    rr2
    mov     r0,#2
    ret

lbl_6207h:
    mov     r0,num_2(rr4)
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    movw    rr8,#020fh
    movw    rr12,str_table(rr4)
    clrc
    ret

lbl_621dh:
    mov     r0,num_2(rr4)
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    movw    rr8,#020fh
    movw    rr12,str_table(rr4)
    movw    rr4,#0fc60h
    movw    rr8,#0280h
lbl_6237h:
    mov     r0,(rr4)+
    call    uart_send
    decw    rr8
    br      nz,lbl_6237h
    jmp     lbl_62ach

lbl_6243h:
    movw    rr2,#6000h
lbl_6246h:
    decw    rr2
    br      nz,lbl_6246h
    mov     r6,#11
    movw    rr2,#tmp_hiscr_str
lbl_624fh:
    call    uart_recv
    br      c,lbl_6276h
    mov     (rr2)+,r0
    cmp     r0,#1
    br      z,lbl_6269h
    dbnz    r6,lbl_624fh
    call    uart_recv
    br      c,lbl_6276h
    mov     (rr2)+,r0
    cmp     r0,#1
    br      nz,lbl_6276h
lbl_6269h:
    call    Receive_a_byte
    br      c,lbl_6276h
    xor     r0,#0ffh
    cmp     r0,recv_checksum
    br      z,lbl_6283h
lbl_6276h:
    mov     r0,#15
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    setc
    ret
lbl_6283h:
    call    find_hiscr
    jmp     c,lbl_6309h
    movw    mem_cc,rr2
    mov     r0,num_2(rr4)
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    movw    rr8,#020fh
    movw    rr12,str_table(rr4)
    mov     r1,#40h
    movw    rr2,mem_cc
lbl_62a5h:
    mov     r0,(rr2)+
    call    uart_send
    dbnz    r1,lbl_62a5h
    
lbl_62ach:
    mov     r0,send_checksum
    xor     r0,#0ffh
    call    uart_send
    clrc
    ret

lbl_62b6h:
    movw    rr2,#0
lbl_62b9h:
    decw    rr2
    br      nz,lbl_62b9h
    mov     r6,#40h
    movw    rr2,#0fa00h
lbl_62c2h:
    call    uart_recv
    br      c,lbl_6276h
    mov     (rr2)+,r0
    dbnz    r6,lbl_62c2h
    call    Receive_a_byte
    br      c,lbl_6276h
    xor     r0,#0ffh
    cmp     r0,recv_checksum
    br      nz,lbl_6276h
    movw    rr2,#0fa03h
    movw    rr8,#tmp_hiscr_str
    mov     r1,#12
lbl_62e0h:
    mov     r0,(rr2)+
    mov     (rr8)+,r0
    dbnz    r1,lbl_62e0h
    call    find_hiscr
    br      c,lbl_6309h
    movw    rr12,#0fa00h
    mov     r0,#40h
lbl_62f0h:
    mov     r1,(rr12)+
    mov     (rr2)+,r1
    dbnz    r0,lbl_62f0h
    movw    rr8,#020fh
    movw    rr12,str_table(rr4)
    mov     r0,#12
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    ret
lbl_6309h:
    mov     r0,#10
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    setc
    ret

lbl_6316h:
    movw    rr2,#0
lbl_6319h:
    decw    rr2
    br      nz,lbl_6319h
    clr     r6
    movw    rr2,#0fa00h
lbl_6322h:
    call    uart_recv
    jmp     c,lbl_6276h
    cmp     r0,#1
    br      z,lbl_6339h
    mov     (rr2)+,r0
    inc     r6
    cmp     r6,#0fah
    br      c,lbl_6322h
    jmp     lbl_6276h
lbl_6339h:
    call    Receive_a_byte
    jmp     c,lbl_6276h
    xor     r0,#0ffh
    cmp     r0,recv_checksum
    jmp     nz,lbl_6276h
    clr     r0
    mov     @rr2,r0
    movw    rr8,#0
    movw    rr12,#0fa00h
    call    Str_abs
    mov     r0,num_2(rr4)
    call    uart_send
    xor     r0,#0ffh
    call    uart_send
    clrc
    ret

numbers:
    db      1
    
num_2:
    db      2,3,4,5,6,7,8,9,10,11,12

cmd_funcs:
    dw      lbl_61f7h
    dw      lbl_61fch
    dw      lbl_621dh
    dw      lbl_6243h
    dw      lbl_62b6h
    dw      lbl_6316h

str_table:
    dw      str_established
    dw      str_terminated
    dw      str_list_sent
    dw      str_data_sent
    dw      str_overwrite
    dw      str_write_text

str_established:
    dm      'Link Established.   '
    db      0

str_terminated:
    dm      'Link Terminated.    '
    db      0

str_list_sent:
    dm      'Full List Sent.     '
    db      0

str_data_sent:
    dm      'One game data sent. '
    db      0

str_overwrite:
    dm      'Overwrite game data.'
    db      0

str_write_text:
    dm      'Write text message. '
    db      0

str_start:
    dm      'START'
    db      0

    end
