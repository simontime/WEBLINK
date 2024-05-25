; UART equates
uart_config equ 00100000b ; 8-N-1, 9600 baud
uart_enable equ 00111111b ; Use application TX/RX queues

STPID        equ    0a4h    
TMR1_new_ibank  equ     0a6h
SP_CTR1 equ     0ach
SP_CTR2 EQU     0ADH
PVOICE  EQU     0B0H
UT_clk    equ    0b4h
ScanTMR equ     0b5h
SYSFLAG    EQU    0BCH
KBDFLAG    EQU    0BDH
TMR1_new_isr    equ    102h
DMG_timer    equ    112h
UTimer1C    equ    150h        ;-------------------------

Melody_Register equ  169h
Mel_address0    equ  16ah
Mel_address1    equ  16ch
Tone0content    equ  171h ;amplitdue control for channel 0
Tone1content    equ  172h ;amplitude control for channel 1
ToneLength0     equ  173h ;length of the tone in channel 0
ToneLength1     equ  174h ;length of the tone in channel 1
Melody_timer    equ  176h ;count = 10 --> 49ms per unit
KBDTMR        EQU    17FH

mel_counter     equ  1a8h
mel_counter1    equ  1a9h
mel_flag        equ  1aah
mel_flag1       equ  1abh
melodyupdate    equ  1ach

MAX_UT        equ    8
SP_TIMER1ISR_RP    equ    38h
N_TIMER1ISR_RP    equ    48h
SCANFREQ    equ    20/5        ;10ms
REPEATTM        equ     10              ;500ms
DEBOU_TM    equ    16
ALARM_ALERT_KEY    equ    0a4h
COMM_ERROR    equ    0a5h
WARN_BEEP    equ    0a8h
UT_CLK_        equ    50/5    ;49.152 ms per count
UT_STOP         equ     00h
UT_RUN        equ    01h
SP_CTR1_VAL    equ    3    ;41.6us*3 == 124.8us (8013Hz)
SP_CTR2_VAL    equ    40    ;118    ;4.91ms
;
SP_TMR1_VAL    equ    208

STUFFKEY        equ 22fah
SlopeTable      equ 36d4h
end_TMR1_isr    equ 2142h


cur_page   equ  94h
sp_control equ 0a8h
anim_frame     equ 0c4h
func_ptr  equ 0c6h
mem_c9     equ 0c9h
mem_cc equ 0cch
mem_ce equ 0ceh
anim_bank equ 0d0h
mem_d1 equ 0d1h
anim_addr equ 0d2h
last_key     equ 0d4h
send_checksum equ 0dah
recv_checksum equ 0dbh
jmp_addr   equ 208h

tmp_hiscr_str equ 0cah

;
; Banks
;
bank_program0 equ 20h
bank_program1 equ 21h
bank_melody   equ 22h
bank_anim     equ 23h

;
; Key equates
;
key_up    equ 83h
key_down  equ 84h
key_left  equ 85h
key_right equ 86h
key_menu  equ 87h
key_onoff equ 88h
key_mute  equ 89h
key_pause equ 8ah
key_a     equ 8bh
key_b     equ 8ch
key_c     equ 8dh
key_d     equ 8eh

;
; KEY_CTRL equates
;
kctrl_touch    equ 0 ; Scan touch screen
kctrl_membrane equ 1 ; Scan membrane (A, B, C, D, etc.)

;
; High score equates
;
hiscr_data_start   equ 0fc60h ; Starting memory location of high score data
hiscr_entry_length equ 64     ; Length of high score entry
hiscr_num_entries  equ 10     ; Number of high score entries
hiscr_str_offset   equ 3      ; Offset of high score entry string (past ID marker)
hiscr_str_length   equ 11     ; Length of high score entry string, including end marker
hiscr_str_end      equ 1      ; End marker for high score entry string

;
; Defaults
;
anim_start_bank equ 23h
anim_start_addr equ 6000h
anim_frame_len  equ 1f40h ; (200*160)/4
bank_len        equ 2000h
