    title   Web Link
    type    8521

    program

    include weblink.inc

    global  func_advance
    global  main_loop
    global  uart_setup
    global  uart_recv
    global  uart_send

    db      02h         ; Unknown
    db      20h         ; Program entry bank
    dw      entry       ; Program entry address
    db      00001011b   ; Flags - compressed icon, program, slot 1+2
    dm      'TigerDMGC' ; Cartridge string
    db      22h         ; Icon bank
    dw      7b00h       ; Icon address
    dm      'PCConnect' ; Program string
    dw      0           ; Program ID
    db      0a5h        ; Checksum
    db      0           ; Padding
    dw      0

; -------------------
; Program entry point
; 
; Inputs:
; r2 = entry code
;
; Entry codes:
;     0: ini
;     1: exe
;     2: close
;     3: reset
;
; Returns:
; r0 = exit code
; -------------------
entry:
    ; If not exe, continue
    dbnz    r2,entry_2
    ; Jump to function
    jmp     @jmp_addr

; Advances to next function
func_advance:
    ; Go to next function in array
    addw    func_ptr,#2
func_set:
    ; Set jump address to function address
    movw    rr2,func_ptr
    movw    rr0,@rr2
    movw    jmp_addr,rr0
    ; Initialise animation frame
    movw    anim_frame,#0
    ; Clear speech control bit 6
    bclr    sp_control,#6
    ; Set up keys
    mov     r0,#kctrl_membrane ; flags
    call    CTRL_KBD
    ; Return 0
    clr     r0
    ret

entry_2:
    ; If init, handle
    cmp     r2,#0ffh
    jmp     eq,init
    ; If >reset, handle
    dbnz    r2,reset
close:
    ; Stop audio output
    call    stop_speech
    call    stop_melody
    ; Restore original TMR1 ISR
    call    restore_isr
    ; Presumably commented out code here
    bbc     mem_c9,#0,stub0
stub0:
    ; Clean memory
    call    mem_clean
    ret
reset:
    ; If not reset, bad entry code
    dbnz    r2,bad_entry
    ; Clean memory
    call    mem_clean
    ret
bad_entry:
    ; Return 3
    mov     r0,#3
    ret
init:
    ; Initialise TMR1 ISR
    call    init_isr
    ; Set up MMU banks
    mov     mmu3,#21h
    mov     mmu4,#22h
    ; Initialise function pointer
    movw    func_ptr,#link_steps
    ; Set function jump address
    call    func_set
    ; Set up display
    call    Disp_setup
    ; Set graphics mode (compound)
    call    set_gfx_mode
    ; Return 0
    clr     r0
    ret

; Cleans user memory regions
mem_clean:
    ; Clean non-zero page region (0x208-0x37f)
    movw    rr0,#0
    movw    rr2,#208h
c_lower:
    movw    (rr2)+,rr0
    cmpw    rr2,#380h
    br      ne,c_lower
    ; Clean zero page region (0xbe-0xff)
    mov     r2,#0beh
c_upper:
    mov     (r2)+,#0
    cmp     r2,r0
    br      ne,c_upper
    ret

lbl_4093h:
    mov     r15,#1
    br      lbl_409bh
    mov     r15,#0
lbl_409bh:
    bbs     cur_page,#0,lbl_40a0h
    bset    r15,#1
lbl_40a0h:
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    mov     r1,@rr4
    mov     r14,r1
    jmp     Fi_graph
    mov     r15,#0
    bbs     cur_page,#0,lbl_40b3h
    bset    r15,#1
lbl_40b3h:
    mov     r0,(rr6)+
lbl_40b5h:
    movw    rr4,(rr6)+
    push    r0
    pushw   rr8
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    movw    rr0,(rr6)+
    addw    rr8,rr0
    mov     r0,@rr4
    mov     r14,r0
    pushw   rr6
    push    r15
    call    Fi_graph
    pop     r15
    popw    rr6
    popw    rr8
    pop     r0
    dbnz    r0,lbl_40b5h
    ret

lbl_40dah:
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    mov     r1,@rr4
    mov     r14,r1
    mov     r15,#8
    bbs     cur_page,#0,lbl_40eah
    bset    r15,#1
lbl_40eah:
    jmp     Fi_graph
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    mov     r15,#1
    bbs     cur_page,#0,lbl_40f9h
    bset    r15,#1
lbl_40f9h:
    jmp     Fi_graph

lbl_40fch:
    bbs     cur_page,#0,lbl_4101h
    bset    r15,#1
lbl_4101h:
    bbs     r0,#0,lbl_4120h
    mov     r1,@rr4
    mov     r14,r1
    jmp     Fi_graph
    bbs     cur_page,#0,lbl_4111h
    jmp     clear_B
lbl_4111h:
    jmp     clear_A
    mov     r15,#1
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    bbs     cur_page,#0,lbl_4120h
    bset    r15,#1
lbl_4120h:
    pushw   rr8
    pushw   rr12
    pushw   rr10
    mov     r1,@rr4
    mov     r14,r1
    pushw   rr14
    call    Fi_graph
    popw    rr14
    inc     r14
    xor     r15,#8
    popw    rr10
    popw    rr12
    popw    rr8
    jmp     Fi_graph
    bclr    dmvp,#1
    bbs     cur_page,#0,lbl_4146h
    bset    dmvp,#1
lbl_4146h:
    push    dmpl
    bmov    bf,r8,#0
    bmov    r8,#2,bf
    bmov    bf,r8,#1
    bmov    r8,#3,bf
    mov     r0,r8
    swap    r0
    or      r0,r8
    mov     dmpl,r0
    mov     dmdx,#0a0h
    mov     dmdy,#0c8h
    clr     dmx2
    clr     dmy2
    push    ps1
    bbc     sp_control,#0,lbl_416fh
lbl_416ch:
    bbs     0b1h,#5,lbl_416ch
lbl_416fh:
    di
    mov     r0,ie0
    mov     r1,ie1
    mov     ie0,#80h
    clr     ie1
    mov     dmc,#83h
    halt
    bclr    ir0,#7
    bset    0b1h,#5
    mov     ie1,r1
    mov     ie0,r0
    pop     ps1
    pop     dmpl
    ret

; Selects graphics mode (always compound)
set_gfx_mode:
    clr     r8 ; mode (compound)
    ; Presumably commented out code here
    br      stub1
    mov     r8,#1 ; mode (overwrite)
stub1:
    jmp     Select_mode

;
lbl_4193h:
    mov     r15,#1
    mov     r0,#1
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    cmp     r8,r12
    br      nc,lbl_41adh
    bbs     r15,#6,lbl_41aah
    sub     r10,r8
    add     r10,r12
lbl_41aah:
    mov     r12,r8
lbl_41adh:
    cmp     r9,r13
    br      nc,lbl_41beh
    bbs     r15,#7,lbl_41bbh
    sub     r11,r9
    add     r11,r13
lbl_41bbh:
    mov     r13,r9
lbl_41beh:
    subw    rr8,rr12
    jmp     lbl_40fch
    mov     r15,#1
    mov     r0,#1
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    push    r8
    add     r8,r12
    br      c,lbl_41d9h
    cmp     r8,#0c8h
    br      c,lbl_41eeh
lbl_41d9h:
    pop     r8
    mov     r1,r12
    mov     r12,#0c8h
    sub     r12,r8
    bbc     r15,#6,lbl_41f0h
    add     r10,r1
    sub     r10,r12
    br      lbl_41f0h
lbl_41eeh:
    pop     r8
lbl_41f0h:
    cmp     r9,r13
    br      nc,lbl_4201h
    bbs     r15,#7,lbl_41feh
    sub     r11,r9
    add     r11,r13
lbl_41feh:
    mov     r13,r9
lbl_4201h:
    sub     r9,r13
    jmp     lbl_40fch
    mov     r15,#1
    mov     r0,#1
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    cmp     r8,r12
    br      nc,lbl_4221h
    bbs     r15,#6,lbl_421eh
    sub     r10,r8
    add     r10,r12
lbl_421eh:
    mov     r12,r8
lbl_4221h:
    push    r9
    add     r9,r13
    br      c,lbl_422dh
    cmp     r9,#0a0h
    br      c,lbl_4242h
lbl_422dh:
    pop     r9
    mov     r1,r13
    mov     r13,#0a0h
    sub     r13,r9
    bbc     r15,#7,lbl_4244h
    add     r11,r1
    sub     r11,r13
    br      lbl_4244h
lbl_4242h:
    pop     r9
lbl_4244h:
    sub     r8,r12
    jmp     lbl_40fch
    mov     r15,#1
    mov     r0,#1
    movw    rr12,(rr4)+
    movw    rr10,(rr4)+
    push    r8
    add     r8,r12
    br      c,lbl_425fh
    cmp     r8,#0c8h
    br      c,lbl_4274h
lbl_425fh:
    pop     r8
    mov     r1,r12
    mov     r12,#0c8h
    sub     r12,r8
    bbc     r15,#6,lbl_4276h
    add     r10,r1
    sub     r10,r12
    br      lbl_4276h
lbl_4274h:
    pop     r8
lbl_4276h:
    push    r9
    add     r9,r13
    br      c,lbl_4282h
    cmp     r9,#0a0h
    br      c,lbl_4297h
lbl_4282h:
    pop     r9
    mov     r1,r13
    mov     r13,#0a0h
    sub     r13,r9
    bbc     r15,#7,lbl_4299h
    add     r11,r1
    sub     r11,r13
    br      lbl_4299h
lbl_4297h:
    pop     r9
lbl_4299h:
    jmp     lbl_40fch

; Unsure what this does, but a slightly modified version appears in the Fighters Megamix source code (OL)
scan_3B:
    cmp     r0,#3bh
    br      eq,more_scan
    ret
more_scan:
    mov     p2,#0feh
    bset    p3,#4
    or      p1,#0fch
    mov     r0,#20
ddloop:
    dbnz    r0,ddloop
    mov     r0,p0
    bbc     p0,#4,is_key3b
    clr     r0
    br      portk_oout
is_key3b:
    mov     r0,#3bh
portk_oout:
    mov     p2,#0ffh
    ret

main_loop:
    call    SCAN_KEY
    mov     last_key,r0
    bclr    sp_control,#5
    cmp     r0,#0a8h
    br      ne,lbl_42c9h
    clr     r0
lbl_42c9h:
    cmp     r0,#87h
    br      ne,lbl_431bh
    push    r0
    call    stop_melody
    call    stop_speech
    bclr    mem_c9,#4
    cmp     cur_page,#1
    br      nz,lbl_42efh
    movw    rr8,#0
    movw    rr10,#0c8a0h
    movw    rr12,#0
    mov     r14,#0
    mov     r15,#1
    call    Blk_mov_2
lbl_42efh:
    call    Short_Beep
    call    restore_isr
    clr     r2
    call    quit_box
lbl_42fah:
    mov     r2,#1
    call    quit_box
    br      c,lbl_42fah
    push    r0
    call    init_isr
    pop     r0
    cmp     r0,#0
    br      z,lbl_4313h
    pop     r0
    clr     r0
    br      lbl_431bh
lbl_4313h:
    call    disable_pause
    pop     r0
    mov     r0,#2
    ret
lbl_431bh:
    cmp     r0,#87h
    br      c,lbl_4340h
    cmp     r0,#8ah
    br      ugt,lbl_4340h
    br      nz,lbl_4329h
    bset    sp_control,#5
lbl_4329h:
    bclr    mem_c9,#4
    push    r0
    call    stop_melody
    call    stop_speech
    call    restore_isr
    pop     r0
    call    SysKeyHandler
    call    init_isr
    clr     r0
lbl_4340h:
    mov     r1,r0
    mov     r0,#1
    ret

lbl_4345h:
    clr     r4
    movw    rr2,rr4
    sll     r5
    bbs     r3,#7,lbl_4361h
    addw    rr4,rr2
    addw    rr4,#adpcm_samples
    mov     r1,(rr4)+
    movw    rr2,(rr4)+
    call    SND_ADDR
    mov     r0,#5
    jmp     CTRL_SP
lbl_4361h:
    and     r3,#7fh
    addw    rr4,rr2
    addw    rr4,#pcm_samples
    mov     r1,(rr4)+
    movw    rr2,@rr4
    mov     r4,r1
    incw    rr2
    pushw   rr6
    push    mmu3
    mov     mmu3,r4
    movw    rr6,(rr2)+
    pop     mmu3
    subw    rr6,#3
    bset    sp_control,#6
    call    start_pcm_speech
    popw    rr6
    ret

lbl_4389h:
    bbs     cur_page,#0,lbl_4392h
lbl_438Ch:
    jmp     Text_in_B
    bbs     cur_page,#0,lbl_438Ch
lbl_4392h:
    jmp     Text_in_A
    bbs     cur_page,#0,lbl_439Bh
    jmp     clear_B
lbl_439Bh:
    jmp     clear_A
    movw    rr0,#10
    jmp     Delay_Timer
    mov     r1,#3
    mov     r8,#0f9h
    mov     DMG_timer,r0
    push    dmpl
    mov     dmpl,r8
    mov     r15,#1
    bbs     cur_page,#0,lbl_43BBh
    mov     r15,#2
lbl_43BBh:
    clr     r0
    movw    rr8,#0000h
    mov     r10,#0c8h
    mov     r11,#0a0h
    mov     r12,r0
    mov     r13,r0
    mov     r14,#0
    call    Blk_mov_2
    call    Swap_page
    xor     r15,#3
    mov     r0,#0a0h
    mov     DMG_timer,r0
lbl_43DCh:
    mov     r0,DMG_timer
    cmp     r0,#0
    br      ne,lbl_43DCh
    dbnz    r1,lbl_43BBh
    pop     dmpl
    ret
lbl_43EAh:
    pop     r0
    ret

; Set up UART
uart_setup:
    mov     r0,#uart_config ; config
    call    UART_setup
    call    init_new_uart
    mov     r0,#uart_enable ; config
    movw    rr2,#020fh  ; TX queue
    movw    rr8,#0008h  ; TX queue length
    movw    rr4,#0218h  ; RX queue
    movw    rr10,#0050h ; RX queue length
    call    UART_enable
    call    Reset_UART_queue
    ret

; Send a byte via UART
uart_send:
    ; 
    call    Send_a_byte
    ; Infinite loop until carry flag set
    br      c,uart_send
    push    r0
    add     r0,send_checksum
    mov     send_checksum,r0
    mov     r0,#5ah
    mov     012fh,r0
    pop     r0
    ret

; Receive a byte via UART
; Clears carry flag if byte received
uart_recv:
    call    Receive_a_byte
    br      c,recv_no_byte
    push    r0
    add     r0,recv_checksum
    mov     recv_checksum,r0
    pop     r0
    clrc
recv_no_byte:
    ret

; ADPCM sample locations (unused and data non-existent)
adpcm_samples:
    db      8
    dw      0000h
    ;
    db      8
    dw      0cf4h
    ;
    db      8
    dw      28b1h
    ;
    db      8
    dw      4663h
    ;
    db      8
    dw      47d7h
    ;
    db      8
    dw      50b3h
    ;
    db      8
    dw      63fbh
    ;
    db      8
    dw      6fa2h
    ;
    db      8
    dw      72d8h
    ;
    db      8
    dw      78f2h

; PCM sample locations (unused and data non-existent)
pcm_samples:
    db      45h
    dw      6000h
    ;
    db      46h
    dw      6eb8h
    ;
    db      47h
    dw      7ff5h
    ;
    db      49h
    dw      649bh
    ;
    db      4ah
    dw      7815h
    ;
    db      4bh
    dw      7363h
    ;
    db      4dh
    dw      76afh
    ;
    db      4fh
    dw      6be8h
    ;
    db      51h
    dw      7319h
    ;
    db      52h
    dw      7fc0h
    ;
    db      55h
    dw      72e3h
    ;
    db      57h
    dw      72f1h
    ;
    db      58h
    dw      63d4h
    ;
    db      58h
    dw      65bfh
    ;
    db      59h
    dw      615ah
    ;
    db      5ah
    dw      75f2h

    end
