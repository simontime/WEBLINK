    title   System calls
    type    8521

    program

System_Call equ 20f1h

    global  Str_abs_i
    global  Ch_abs_i
    global  Fill_blk_colr
    global  Disp_setup
    global  Dsp_ch
    global  Ch_abs
    global  Str_abs
    global  Cur_pos
    global  Set_win
    global  Cls_scn
    global  Sel_font
    global  Set_colr
    global  Def_font
    global  Scn_colr
    global  Fi_patt
    global  Fi_graph
    global  set_line_color
    global  Blk_rev
    global  Blk_cls
    global  Draw_line_v
    global  Draw_line_h
    global  clear_A
    global  clear_B
    global  Dsp_ch_sp
    global  Select_mode
    global  SCAN_KEY
    global  CTRL_KBD
    global  SET_TMR
    global  CTRL_TMR
    global  SND_ADDR
    global  CTRL_SPX
    global  CTRL_SP
    global  READTIME
    global  Switch_bank
    global  Setup_Melody
    global  Control_Melody
    global  MemoryBlkReq
    global  Short_Beep
    global  Speech_Stop
    global  Check_Timer
    global  Delay_Timer
    global  disp_tmrovr
    global  Fi_graph2
    global  Swap_page
    global  Blk_mov_2
    global  Text_in_A
    global  Text_in_B
    global  SysKeyHandler
    global  quit_box
    global  enable_timeout
    global  disable_timeout
    global  call_appl
    global  restart_timeout
    global  Req_RAM_Block
    global  yn_box
    global  enable_pause
    global  disable_pause
    global  Str_abs_n
    global  UART_setup
    global  UART_enable
    global  Reset_UART_queue
    global  Send_a_byte
    global  Receive_a_byte

    global  init_new_uart
    global  restore_uart
    global  new_uartisr

; All syscall names original

Str_abs_i:
    pushw   rr6
    mov     r7,#0bh
    br      System_Call1

Ch_abs_i:
    pushw   rr6
    mov     r7,#4
    br      System_Call1

Fill_blk_colr:
    pushw   rr6
    mov     r7,#2eh
    br      System_Call1

Disp_setup:
    pushw   rr6
    mov     r7,#0
    br      System_Call1

Dsp_ch:
    pushw   rr6
    mov     r7,#1
    br      System_Call1

Ch_abs:
    pushw   rr6
    mov     r7,#3
    br      System_Call1

Str_abs:
    pushw   rr6
    mov     r7,#9
    br      System_Call1

Cur_pos:
    pushw   rr6
    mov     r7,#10h
    br      System_Call1

Set_win:
    pushw   rr6
    mov     r7,#11h
System_Call1:
    jmp     System_Call

Cls_scn:
    pushw   rr6
    mov     r7,#17h
    br      System_Call2

Sel_font:
    pushw   rr6
    mov     r7,#18h
    br      System_Call2

Set_colr:
    pushw   rr6
    mov     r7,#19h
    br      System_Call2

Def_font:
    pushw   rr6
    mov     r7,#1ah
    br      System_Call2

Scn_colr:
    pushw   rr6
    mov     r7,#1bh
    br      System_Call2

Fi_patt:
    pushw   rr6
    mov     r7,#1ch
    br      System_Call2

Fi_graph:
    pushw   rr6
    mov     r7,#1dh
    br      System_Call2

set_line_color:
    pushw   rr6
    mov     r7,#21h
    br      System_Call2

Blk_rev:
    pushw   rr6
    mov     r7,#22h
    br      System_Call2

Blk_cls:
    pushw   rr6
    mov     r7,#23h
System_Call2:
    br      System_Call1

Draw_line_v:
    pushw   rr6
    mov     r7,#26h
    br      System_Call3

Draw_line_h:
    pushw   rr6
    mov     r7,#27h
    br      System_Call3

clear_A:
    pushw   rr6
    mov     r7,#28h
    br      System_Call3

clear_B:
    pushw   rr6
    mov     r7,#29h
    br      System_Call3

Dsp_ch_sp:
    pushw   rr6
    mov     r7,#2ah
    br      System_Call3

Select_mode:
    pushw   rr6
    mov     r7,#2ch
    br      System_Call3

SCAN_KEY:
    pushw   rr6
    mov     r7,#2fh
    br      System_Call3

CTRL_KBD:
    pushw   rr6
    mov     r7,#30h
    br      System_Call3

SET_TMR:
    pushw   rr6
    mov     r7,#31h
    br      System_Call3

CTRL_TMR:
    pushw   rr6
    mov     r7,#32h
System_Call3:
    jmp     System_Call

SND_ADDR:
    pushw   rr6
    mov     r7,#33h
    br      System_Call4

CTRL_SPX:
    pushw   rr0
    and     r0,#3
    cmp     r0,#1
    br      ne,not_start
is_start:
    bbs     0bch,#5,delay_200
    mov     sgda,r0
    mov     sgc,#88h
    inc     r0
    pushw   rr0
    popw    rr0
    pushw   rr0
    popw    rr0
    pushw   rr0
    popw    rr0
    pushw   rr0
    popw    rr0
    bbc     r0,#7,is_start
delay_200:
    movw    rr0,#0f000h
delay_200ms:
    decw    rr0
    br      nz,delay_200ms
not_start:
    popw    rr0

CTRL_SP:
    bbc     r0,#0,ctrl_sp1
    jmp     start_speech

ctrl_sp1:
    pushw   rr6
    mov     r7,#34h
    br      System_Call4

READTIME:
    pushw   rr6
    mov     r7,#35h
System_Call4:
    jmp     System_Call

Switch_bank:
    pushw   rr6
    mov     r7,#45h
    br      System_Call5

Setup_Melody:
    pushw   rr6
    mov     r7,#48h
    br      System_Call5

Control_Melody:
    pushw   rr6
    mov     r7,#49h
    br      System_Call5

MemoryBlkReq:
    pushw   rr6
    mov     r7,#4ch
    br      System_Call5

Short_Beep:
    pushw   rr6
    mov     r7,#4eh
    br      System_Call5

Speech_Stop:
    pushw   rr6
    mov     r7,#4fh
    br      System_Call5

Check_Timer:
    pushw   rr6
    mov     r7,#50h
    br      System_Call5

Delay_Timer:
    pushw   rr6
    mov     r7,#51h
System_Call5:
    jmp     System_Call

disp_tmrovr:
    pushw   rr6
    mov     r7,#52h
    br      System_Call5

Fi_graph2:
    pushw   rr6
    mov     r7,#56h
    br      System_Call5

Swap_page:
    pushw   rr6
    mov     r7,#57h
    br      System_Call5

Blk_mov_2:
    pushw   rr6
    mov     r7,#58h
    br      System_Call5

Text_in_A:
    pushw   rr6
    mov     r7,#6ch
System_Call6:
    jmp     System_Call

Text_in_B:
    pushw   rr6
    mov     r7,#6dh
    br      System_Call6

SysKeyHandler:
    pushw   rr6
    mov     r7,#78h
    br      System_Call6

quit_box:
    pushw   rr6
    mov     r7,#79h
    br      System_Call6

enable_timeout:
    pushw   rr6
    mov     r7,#7ch
System_Call7:
    jmp     System_Call

disable_timeout:
    pushw   rr6
    mov     r7,#7dh
    br      System_Call7

call_appl:
    pushw   rr6
    mov     r7,#7eh
    br      System_Call7

restart_timeout:
    pushw   rr6
    mov     r7,#7fh
    br      System_Call7

Req_RAM_Block:
    pushw   rr6
    mov     r7,#80h
    br      System_Call7

yn_box:
    pushw   rr6
    mov     r7,#81h
    br      System_Call7

enable_pause:
    pushw   rr6
    mov     r7,#82h
    br      System_Call7

disable_pause:
    pushw   rr6
    mov     r7,#83h
    br      System_Call7

Str_abs_n:
    pushw   rr6
    mov     r7,#0ah
    br      System_Call7

UART_setup:
    pushw   rr6
    mov     r7,#3ch
    br      System_Call7

UART_enable:
    pushw   rr6
    mov     r7,#3dh
    br      System_Call7

Reset_UART_queue:
    pushw   rr6
    mov     r7,#3eh
    br      System_Call7

Send_a_byte:
    pushw   rr6
    mov     r7,#3fh
    br      System_Call7

Receive_a_byte:
    pushw   rr6
    mov     r7,#40h
    br      System_Call7

; Unsure why these functions use 0xfc/0x2bc as UART ISR bank/address instead of the designated kernel RAM addresses (OL)
init_new_uart:
    push    ps1
    di
    push    ps0
    movm    ps0,#7,#28h
    movw    rr10,02bch
    mov     r9,0fch
    movw    rr0,#new_uartisr
    movw    02bch,rr0
    mov     r0,mmu2
    mov     0fch,r0
    pop     ps0
    pop     ps1
    ret

restore_uart:
    push    ps1
    di
    push    ps0
    movm    ps0,#7,#28h
    mov     0fch,r9
    movw    02bch,rr10
    pop     ps0
    pop     ps1
    ret

new_uartisr:
    push    ps0
    movm    ps0,#7,#28h
    mov     r7,uarts
    mov     0208h,r7
    movw    rr2,rr10
    addw    rr2,#8
    jmp     @rr2

    end
