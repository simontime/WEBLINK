    title   Speech routines
    type    8521
    
    program

    include weblink.inc

    global  start_speech
    global  start_chan0
    global  start_chan1
    global  stop_speech
    global  play_melody
    global  stop_melody
	global  start_pcm_speech
	global  start_sg_speech
	global  stop_speech1
    global  init_isr
    global  restore_isr

; Speech playback ISR + ADPCM decoder (OL)
sp_timer:
    bclr    0b1h,#5
    dec     SP_CTR1
    br      z,sp_timer1
    jmp     end_TMR1_isr
sp_timer1:
    mov     SP_CTR1,#3
    mov     r15,mmu3
    mov     mmu3,r4
    mov     sgda,PVOICE
    bbc     sp_control,#2,process_low_nibble
    bclr    sp_control,#2
    mov     r0,(rr2)+
    bbc     r2,#7,adpcm4
    inc     r4
    mov     r2,#60h
adpcm4:
    swap    r0
    jmp     adpcm3
process_low_nibble:
    bset    sp_control,#2
    mov     r0,@rr2
adpcm3:
    srl     r0
    movm    r0,#7,r1
    mov     r13,r0
    br      c,vslope_down
    sll     r13
    clr     r12
    movw    rr0,SlopeTable(rr12)
    add     PVOICE,r0
    jmp     nc,adpcm1
    mov     PVOICE,#0ffh
adpcm1:
    mov     mmu3,r15
    cmp     r4,r8
    br      eq,sp_timerxx
sp_timer3:
    dec     SP_CTR2
    jmp     nz,end_TMR1_isr
    mov     SP_CTR2,#28h
    jmp     normal_timerx
sp_timerxx:
    cmpw    rr2,rr6
    jmp     c,sp_timer3
    call    stop_speech
    mov     r0,#0a0h
    call    STUFFKEY
    jmp     sp_timer3
vslope_down:
    sll     r13
    clr     r12
    movw    rr0,SlopeTable(rr12)
    sub     PVOICE,r0
    jmp     nc,adpcm1
    clr     PVOICE
    jmp     adpcm1

; Timer handling (OL)
normal_timerx:
    bclr    0b1h,#5
    push    STPID
    push    r14
    mov     PS0,#N_TIMER1ISR_RP
    ei
    dec     ScanTMR
    br      nz,tmr19
    mov     ScanTMR,#SCANFREQ
    bset    KBDFLAG,#3
    bbc     KBDFLAG,#5,tmr20
    mov     r0,KBDTMR
    dec     r0
    mov     KBDTMR,r0
    br      NZ,tmr20
    bclr    KBDFLAG,#5
tmr20:
    bbc     KBDFLAG,#6,tmr19
    mov     r0,KBDTMR
    dec     r0
    mov     KBDTMR,r0
    br      nz,tmr19
    bclr    KBDFLAG,#6
    bset    KBDFLAG,#5
    mov     r0,#40
    mov     KBDTMR,r0
tmr19:
    btst    sp_control,#90h
    br      nz,tmr14x
    mov     r0,DMG_timer
    inc     r0
    mov     DMG_timer,r0
    dec     UT_clk
    br      nz,tmr14
    mov     UT_clk,#UT_CLK_
    movw    rr2,#UTimer1C
    mov     r4,#MAX_UT
tmr13:
    mov     r0,@rr2
    cmp     r0,#UT_RUN
    br      eq,tmr12
tmr15:
    addw    rr2,#3
    dbnz    r4,tmr13
    br      tmr14
tmr12:
    movw    rr0,1(rr2)
    decw    rr0
    movw    1(rr2),rr0
    br      nz,tmr15
    push    r4
    neg     r4
    and     r4,#7
    or      r4,#90h
    mov     r0,r4
    cmp     r0,#97h
    br      ne,tmr_17
    mov     r0,#UT_STOP
    mov     @rr2,r0
    call    disp_tmrovr
    pop     r4
    br      tmr15
tmr_17:
    clr     r1
    call    STUFFKEY
    br      nc,tmr16
    movw    rr0,#1
    movw    1(rr2),rr0
    pop     r4
    br      tmr15
tmr16:
    pop     r4
    mov     r0,#0
    mov     @rr2,r0
    br      tmr15
tmr14x:
    bbc     SYSFLAG,#4,tmr18
tmr14:
    mov     r0,Melody_Register
    btst    r0,#11h
    br      z,tmr18
    bbs     sp_control,#0,tmr18
    call    updatemelody
tmr18:
    di
    mov     ps0,#SP_TIMER1ISR_RP
    pop     r14
    pop     STPID
    jmp     end_TMR1_isr

; Start speech playback
start_speech:
    bbc     sp_control,#6,lbl_47C5h
    push    ps0
    movm    ps0,#7,#SP_TIMER1ISR_RP
    call    stop_speech1
    pop     ps0
lbl_47C5h:
    push    ps1
    di
    mov     PVOICE,r0
    push    ps0
    movm    ps0,#7,#SP_TIMER1ISR_RP
    bbs     sp_control,#0,lbl_47DAh
    movw    rr10,TMR1_new_isr
    mov     r9,TMR1_new_ibank
lbl_47DAh:
    movw    rr0,#sp_timer
    movw    TMR1_new_isr,rr0
    mov     r0,mmu2
    mov     TMR1_new_ibank,r0
    mov     tm1d,#SP_TMR1_VAL
    mov     tm1c,#80h
    bset    SYSFLAG,#6
    mov     SP_CTR1,#SP_CTR1_VAL
    mov     SP_CTR2,#SP_CTR2_VAL
    mov     PVOICE,#80h
    pop     ps0
    bbs     SYSFLAG,#5,lbl_4829h
    btst    sgc,#88h
    br      nz,lbl_4826h
    push    r0
    mov     sgc,#88h
    clr     r0
lbl_4807h:
    mov     sgda,r0
    pushw   rr0
    popw    rr0
    pushw   rr0
    popw    rr0
    inc     r0
    bbc     r0,#7,lbl_4807h
    pushw   rr0
    movw    rr0,#0c000h
lbl_481Bh:
    decw    rr0
    br      nz,lbl_481Bh
    popw    rr0
    pop     r0
    mov     sgda,#80h
lbl_4826h:
    mov     sgc,#88h
lbl_4829h:
    bset    sp_control,#0
    pop     ps1
    ret

; Stop speech playback (OL)
stop_speech:
    bclr    0b1h,#05h
    push    ps1
    push    ps0
    di
    and     sp_control,#0f8h
    mov     tm1d,#24
    mov     tm1c,#81h
    movm    ps0,#7,#SP_TIMER1ISR_RP
    mov     TMR1_new_ibank,r9
    movw    TMR1_new_isr,rr10
    and     SYSFLAG,#0bfh
    mov     r0,Melody_Register
    btst    r0,#11h
    br      z,stop_sp1
    mov     r1,sgc
    movm    r1,#80h,#8
    bbc     r0,#3,stop_sp4
    bset    r0,#0
stop_sp4:
    bbc     r0,#7,stop_sp5
    bset    r0,#1
stop_sp5:
    mov     sgc,r1
    mov     sgda,#80h
    mov     sg0l,#0
    mov     sg1l,#0
    mov     r0,#0
    mov     Tone0content,r0
    mov     Tone1content,r0
    br      stop_sp11
stop_sp1:
    call    ramp_down
    clr     sgc
stop_sp11:
    pop     ps0
    pop     ps1
    ret

; Ramps down (fades out) to silence (OL)
ramp_down:
    push    r0
    mov     r0,sgda
stop_sp3:
    cmp     r0,#0
    br      eq,stop_sp2
    dec     r0
    push    r0
    pop     r0
    push    r0
    pop     r0
    push    r0
    pop     r0
    push    r0
    pop     r0
    mov     sgda,r0
    br      stop_sp3
sec: ; Security byte
    db      0,0,5bh
stop_sp2:
    pop     r0
    ret

; Update melody (OL)
updatemelody:
    di
    mov     r0,Melody_timer
    cmp     r0,#0
    jmp     ne,upmel1
upmel2:
    mov     r0,#5
    mov     Melody_timer,r0
    mov     r1,Melody_Register
    bbc     r1,#0,upmel3
    mov     r0,ToneLength0
    dec     r0
    mov     ToneLength0,r0
    br      nz,upmel3
    push    mmu4
    mov     mmu4,#22h
    movw    rr2,Mel_address0
    addw    rr2,#3
    movw    Mel_address0,rr2
    call    start_melody0
    pop     mmu4
upmel3:
    mov     r1,Melody_Register
    btst    r1,#10h
    br      z,upmel6
    mov     r0,ToneLength1
    dec     r0
    br      nz,upmel4
    push    mmu4
    mov     mmu4,#22h
    movw    rr2,Mel_address1
    addw    rr2,#3
    movw    Mel_address1,rr2
    call    start_melody1
    pop     mmu4
upmel6:
    ret
upmel4:
    mov     ToneLength1,r0
    ret
upmel1:
    dec     r0
    jmp     z,upmel2
    mov     Melody_timer,r0
    mov     r0,Melody_Register
    bbs     r0,#0,upadsr00_1
    jmp     upadsr10
upadsr00_1:
    mov     r0,mel_flag
    cmp     r0,#1
    br      eq,test_end1
    clr     r2
    mov     r3,mel_counter
    pushw   rr4
    pushw   rr2
    clr     r2
    mov     r3,Melody_Register
    and     r3,#6
    movw    rr4,Instru_pointer(rr2)
    popw    rr2
    addw    rr4,rr2
    mov     r0,@rr4
    popw    rr4
    cmp     r0,#0
    br      eq,test_end
    add     r3,#3
    br      c,test_pre
    mov     mel_counter,r3
test_pre:
    br      under_ff_0
test_end:
    mov     r0,#1
    mov     mel_flag,r0
test_end1:
    mov     r0,#0
    br      under_ff_0x
under_ff_0:
    sub     r0,#80h
    sll     r0
    cmp     r0,#0
    br      ne,under_ff_0x
    mov     r1,#1
    mov     mel_flag,r1
under_ff_0x:
    mov     Tone0content,r0
    push    mmu4
    mov     mmu4,#22h
    movw    rr2,Mel_address0
    mov     r1,1(rr2)
    call    mixer0
    pop     mmu4
upadsr10:
    mov     r0,Melody_Register
    bbc     r0,#4,upadsr_ret
    mov     r0,mel_flag1
    cmp     r0,#1
    br      eq,test_end1w
    clr     r2
    mov     r3,mel_counter1
    pushw   rr4
    pushw   rr2
    clr     r2
    mov     r3,Melody_Register
    swap    r3
    and     r3,#6
    movw    rr4,Instru_pointer(rr2)
    popw    rr2
    addw    rr4,rr2
    mov     r0,@rr4
    popw    rr4
    cmp     r0,#0
    br      eq,test_endw
    add     r3,#3
    br      c,test_prew
    mov     mel_counter1,r3
test_prew:
    br      under_ff_1
test_endw:
    mov     r0,#1
    mov     mel_flag1,r0
test_end1w:
    mov     r0,#0
    br      under_ff_0xw
under_ff_1:
    sub     r0,#80h
    sll     r0
    cmp     r0,#0
    br      ne,under_ff_0xw
    mov     r1,#1
    mov     mel_flag1,r1
under_ff_0xw:
    mov     Tone1content,r0
    push    mmu4
    mov     mmu4,#22h
    movw    rr2,Mel_address1
    mov     r1,1(rr2)
    call    mixer1
    pop     mmu4
upadsr_ret:
    ret

; Mixer for melody channel 0 (OL)
mixer0:
    clr     r0
    mov     r3,Tone0content
    clr     r2
    mult    rr0,r3
    movw    rr2,#0ffh
    div     rr0,rr2
    cmp     r1,#1fh
    br      c,mixer0_1
    mov     r1,#1fh
mixer0_1:
    srl     r1
    mov     sg0l,r1
    ret

; Mixer for melody channel 1 (OL)
mixer1:
    clr     r0
    mov     r3,Tone1content
    clr     r2
    mult    rr0,r3
    movw    rr2,#0ffh
    div     rr0,rr2
    cmp     r1,#1fh
    br      c,mixer1_1
    mov     r1,#1fh
mixer1_1:
    srl     r1
    mov     sg1l,r1
    ret

; Instruments (OL)
Instru_pointer:
    dw      0
    dw      PianoSound
    dw      OrganSound
    dw      PureTone

OrganSound:
    db      0

PianoSound:
    db      0b0h
    db      0fdh
    db      0fdh
    db      0feh
    db      0feh
    db      0ffh
    db      0fdh
    db      0fah
    db      0f7h
    db      0f4h
    db      0f1h
    db      0eeh
    db      0ebh
    db      0e8h
    db      0e5h
    db      0e2h
    db      0dfh
    db      0dch
    db      0d9h
    db      0d6h
    db      0d3h
    db      0d0h
    db      0cdh
    db      0cah
    db      0c7h
    db      0c4h
    db      0c1h
    db      0bfh
    db      0bdh
    db      0bch
    db      0bah
    db      0b9h
    db      0b7h
    db      0b6h
    db      0b4h
    db      0b3h
    db      0b1h
    db      0b0h
    db      0aeh
    db      0adh
    db      0abh
    db      0aah
    db      0a8h
    db      0a7h
    db      0a6h
    db      0a5h
    db      0a4h
    db      0a3h
    db      0a2h
    db      0a1h
    db      0a0h
    db      09fh
    db      09eh
    db      09dh
    db      09ch
    db      09bh
    db      09ah
    db      099h
    db      098h
    db      097h
    db      096h
    db      095h
    db      094h
    db      093h
    db      092h
    db      090h
    db      08fh
    db      08eh
    db      08dh
    db      08ch
    db      08bh
    db      08ah
    db      089h
    db      089h
    db      088h
    db      087h
    db      086h
    db      086h
    db      085h
    db      084h
    db      083h
    db      083h
    db      082h
    db      081h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      080h
    db      0

PureTone:
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0f0h
    db      0

; Start playback of melody channel 0 (OL)
start_chan0:
    movw    Mel_address0,rr2
    mov     r0,Melody_Register
    movm    r0,#0f0h,#2
    mov     Melody_Register,r0
start_melody0:
    push    ps1
    di
    mov     r1,#0
    mov     mel_counter,r1
    mov     mel_flag,r1
    clr     r1
    mov     Tone0content,r1
    mov     r0,2(rr2)
    mov     ToneLength0,r0
    mov     r0,@rr2
    cmp     r0,#0
    br      eq,stop_m0
    cmp     r0,#80h
    br      eq,no_toneout0
    call    translate_note
    mov     sg0th,r0
    mov     sg0tl,r1
    mov     r6,#80h
    mov     sgda,r6
    mov     r6,sgc
    or      r6,#9
    bbs     SYSFLAG,#5,mute_music
    bset    r6,#7
mute_music:
    mov     r1,1(rr2)
    call    mixer0
    mov     r0,Melody_Register
    movm    r0,#0f6h,#9
no_toneout00:
    mov     Melody_Register,r0
    mov     sgc,r6
start_mel0_ret:
    pop     ps1
    ret
no_toneout0:
    mov     r0,#80h
    mov     sgda,r0
    mov     r6,sgc
    and     r6,#0feh
    mov     r0,Melody_Register
    movm    r0,#0f6h,#1
    br      no_toneout00
stop_m0:
    mov     r0,Melody_Register
    and     r0,#0f6h
    mov     Melody_Register,r0
    mov     r0,sgc
    and     r0,#0fch
    br      stop_m00
    mov     r0,#0
stop_m00:
    mov     sgc,r0
    br      start_mel0_ret

; Start playback of melody channel 1 (OL)
start_chan1:
    movw    Mel_address1,rr2
    mov     r0,Melody_Register
    movm    r0,#0fh,#20h
    mov     Melody_Register,r0
start_melody1:
    push    ps1
    di
    mov     r1,#0
    mov     mel_counter1,r1
    mov     mel_flag1,r1
    clr     r1
    mov     Tone1content,r1
    mov     r0,2(rr2)
    mov     ToneLength1,r0
    mov     r0,@rr2
    cmp     r0,#0
    br      eq,stop_m1
    cmp     r0,#80h
    br      eq,no_toneout1
    call    translate_note
    mov     sg1th,r0
    mov     sg1tl,r1
    mov     r6,sgc
    bset    r6,#1
    mov     r1,1(rr2)
    call    mixer1
    bbs     SYSFLAG,#5,mute_music1
    or      r6,#88h
mute_music1:
    mov     r0,Melody_Register
    movm    r0,#6fh,#90h
no_toneout10:
    mov     Melody_Register,r0
    mov     sgc,r6
start_mel1_ret:
    pop     ps1
    ret
no_toneout1:
    mov     r6,sgc
    bclr    r6,#1
    mov     r0,Melody_Register
    movm    r0,#6fh,#10h
    br      no_toneout10
stop_m1:
    mov     r0,Melody_Register
    and     r0,#0f6h
    mov     Melody_Register,r0
    mov     r0,sgc
    bclr    r0,#1
    mov     sgc,r0
    br      start_mel1_ret

; Translate note to frequency (OL)
translate_note:
    pushw   rr2
    mov     r3,r0
    clr     r2
    subw    rr2,#10h
    br      c,error_note
    cmpw    rr2,#46h
    br      nc,error_note
has_note:
    sll     r3
    movw    rr0,freq_table(rr2)
    popw    rr2
    ret
error_note:
    clr     r2
    clr     r3
    br      has_note

freq_table:
    dw      0fb2h
    dw      0ed0h
    dw      0dfbh
    dw      0d32h
    dw      0c75h
    dw      0bc2h
    dw      0b19h
    dw      0a79h
    dw      09e3h
    dw      0955h
    dw      08cfh
    dw      0850h
    dw      07d9h
    dw      0768h
    dw      06feh
    dw      0699h
    dw      063ah
    dw      05e1h
    dw      058ch
    dw      053dh
    dw      04f1h
    dw      04aah
    dw      0467h
    dw      0428h
    dw      03ech
    dw      03b4h
    dw      037fh
    dw      034dh
    dw      031dh
    dw      02f0h
    dw      02c6h
    dw      029eh
    dw      0277h
    dw      0255h
    dw      0234h
    dw      0214h
    dw      01f6h
    dw      01dah
    dw      01bfh
    dw      01a6h
    dw      018fh
    dw      0178h
    dw      0163h
    dw      014fh
    dw      013ch
    dw      012bh
    dw      011ah
    dw      010ah
    dw      00fbh
    dw      00edh
    dw      00e0h
    dw      00d3h
    dw      00c7h
    dw      00bch
    dw      00b2h
    dw      00a8h
    dw      009eh
    dw      0095h
    dw      008dh
    dw      0085h
    dw      007eh
    dw      0077h
    dw      0070h
    dw      006ah
    dw      0064h
    dw      005eh
    dw      0059h
    dw      0054h
    dw      004fh
    dw      004bh

start_pcm_speech:
    push    ps1
    di
    push    ps0
    pushw   rr2
    push    r4
    pushw   rr6
    movm    ps0,#7,#SP_TIMER1ISR_RP
    popw    rr6
    pop     r4
    popw    rr2
    mov     r8,#5eh
	; Branch if already playing
    bbs     sp_control,#0,pcm_playing
    movw    rr0,TMR1_new_isr
    movw    rr10,rr0
    mov     r9,TMR1_new_ibank
pcm_playing:
    movw    rr0,#pcm_isr
    movw    TMR1_new_isr,rr0
    mov     TMR1_new_ibank,mmu2
    or      sp_control,#43h
    mov     tm1d,#0ffh
    mov     tm1c,#80h
    mov     sgda,#80h
    mov     r0,#8
    bbs     SYSFLAG,#5,lbl_4cfah
    bset    r0,#7
lbl_4cfah:
    mov     sgc,r0
    pop     ps0
    pop     ps1
    ret

start_sg_speech:
    push    ps1
    di
    push    ps0
    pushw   rr2
    push    r4
    pushw   rr6
    movm    ps0,#7,#SP_TIMER1ISR_RP
    popw    rr6
    pop     r4
    popw    rr2
    bbs     sp_control,#0,lbl_4d22h
    movw    rr0,TMR1_new_isr
    movw    rr10,rr0
    mov     r9,TMR1_new_ibank
lbl_4d22h:
    movw    rr0,#sg_isr
    movw    TMR1_new_isr,rr0
    mov     TMR1_new_ibank,mmu2
    or      sp_control,#43h
    mov     tm1d,#15h
    mov     tm1c,#81h
    mov     sg0l,#1fh
    mov     sg1l,#02h
    movw    46h,#0280h
    movw    48h,#0280h
    mov     sgda,#80h
    mov     r0,#08h
    bbs     SYSFLAG,#5,lbl_4d4dh
    bset    r0,#7
lbl_4d4dh:
    mov     sgc,r0
    pop     ps0
    pop     ps1
    ret

stop_speech1:
    bclr    0b1h,#5
    push    ps1
    di
    and     sp_control,#0b8h
    mov     tm1d,#24
    mov     tm1c,#81h
    mov     TMR1_new_ibank,r9
    movw    TMR1_new_isr,rr10
    and     SYSFLAG,#0bfh
    mov     r0,sgc
    and     r0,#0fch
    mov     sgc,r0
    call    sg0_init
    call    sg1_init
    mov     sgda,#80h
    mov     sg0l,#0
    mov     sg1l,#0
    mov     r0,#0
    mov     Tone0content,r0
    mov     Tone1content,r0
    mov     r0,#1
    mov     mel_flag,r0
    mov     mel_flag1,r0
    mov     r0,Melody_Register
    btst    r0,#11h
    br      nz,lbl_4da4h
    clr     sgc
    pop     ps1
    ret
lbl_4da4h:
    mov     sgda,#80h
    mov     r1,#8
    bbc     r0,#3,lbl_4daeh
    bset    r1,#0
lbl_4daeh:
    bbc     r0,#7,lbl_4db3h
    bset    r1,#1
lbl_4db3h:
    bbs     SYSFLAG,#5,lbl_4db8h
    bset    r1,#7
lbl_4db8h:
    mov     sgc,r1
    pop     ps1
    ret

lbl_4dbdh:
    and     sgc,#0fch
    call    stop_speech1
    bclr    sp_control,#0
    jmp     sg_jmp_tmr
pcm_isr:
    bbs     r8,#0,lbl_4de7h
    bbc     sp_control,#1,lbl_4dbdh
    mov     r12,mmu3
    mov     mmu3,r4
    mov     r0,(rr2)+
    bbc     r2,#7,lbl_4ddch
    inc     r4
    mov     r2,#60h
lbl_4ddch:
    mov     mmu3,r12
    mov     sgda,r0
    decw    rr6
    br      nz,lbl_4de7h
    bclr    sp_control,#1
lbl_4de7h:
    dec     r8
    jmp     nz,end_TMR1_isr
    mov     r8,#5eh
    jmp     normal_timerx

sg_isr:
    bclr    0b1h,#5
    bbc     sp_control,#1,lbl_4dbdh
    mov     r0,#88h
    bbc     SYSFLAG,#5,lbl_4dfeh
    mov     r0,#8
lbl_4dfeh:
    mov     sgc,r0
    mov     sgda,r8
    mov     r12,mmu3
    mov     r13,mmu4
    mov     mmu3,r4
    mov     r0,r4
    inc     r0
    mov     mmu4,r0
    movw    rr0,(rr2)+
    movw    60h,rr0
    movw    rr0,(rr2)+
    movw    62h,rr0
    movw    rr0,(rr2)+
    movw    64h,rr0
    movw    rr0,(rr2)+
    movw    66h,rr0
    movw    rr0,(rr2)+
    movw    68h,rr0
    movw    rr0,(rr2)+
    movw    6ah,rr0
    movw    rr0,(rr2)+
    movw    6ch,rr0
    movw    rr0,(rr2)+
    movw    6eh,rr0
    movw    rr0,(rr2)+
    movw    70h,rr0
    movw    rr0,(rr2)+
    movw    72h,rr0
    movw    rr0,(rr2)+
    movw    74h,rr0
    movw    rr0,(rr2)+
    movw    76h,rr0
    movw    rr0,(rr2)+
    movw    78h,rr0
    movw    rr0,(rr2)+
    movw    7ah,rr0
    movw    rr0,(rr2)+
    movw    7ch,rr0
    movw    rr0,(rr2)+
    movw    7eh,rr0
    movw    rr0,(rr2)+
    mov     r8,r1
    bbc     r2,#7,lbl_4e6ah
    inc     r4
lbl_4e6ah:
    movm    r2,#1fh,#60h
    mov     r1,sp_control
    decw    rr6
    br      nz,lbl_4e76h
    bclr    r1,#01h
lbl_4e76h:
    mov     sp_control,r1
    mov     r1,#0eh
lbl_4e7ah:
    dbnz    r1,lbl_4e7ah
    nop
    nop
    mov     mmu3,r12
    mov     mmu4,r13
    mov     r1,sgc
    or      r1,#0bh
    mov     sgc,r1
    mov     sgda,r0
    mov     r1,#3eh
lbl_4e8fh:
    dbnz    r1,lbl_4e8fh
    nop
    nop
    mov     sgda,#88h
sg_jmp_tmr:
    jmp     normal_timerx

; Initialise SG0 with default values
sg0_init:
    pushw   rr2
    push    r0
    movw    rr2,#sg_default
    mov     r0,(rr2)+
    mov     sg0w0,r0
    mov     r0,(rr2)+
    mov     sg0w1,r0
    mov     r0,(rr2)+
    mov     sg0w2,r0
    mov     r0,(rr2)+
    mov     sg0w3,r0
    mov     r0,(rr2)+
    mov     sg0w4,r0
    mov     r0,(rr2)+
    mov     sg0w5,r0
    mov     r0,(rr2)+
    mov     sg0w6,r0
    mov     r0,(rr2)+
    mov     sg0w7,r0
    mov     r0,(rr2)+
    mov     sg0w8,r0
    mov     r0,(rr2)+
    mov     sg0w9,r0
    mov     r0,(rr2)+
    mov     sg0w10,r0
    mov     r0,(rr2)+
    mov     sg0w11,r0
    mov     r0,(rr2)+
    mov     sg0w12,r0
    mov     r0,(rr2)+
    mov     sg0w13,r0
    mov     r0,(rr2)+
    mov     sg0w14,r0
    mov     r0,(rr2)+
    mov     sg0w15,r0
    pop     r0
    popw    rr2
    ret

; Initialise SG1 with default values
sg1_init:
    pushw   rr2
    push    r0
    movw    rr2,#sg_default
    mov     r0,(rr2)+
    mov     sg1w0,r0
    mov     r0,(rr2)+
    mov     sg1w1,r0
    mov     r0,(rr2)+
    mov     sg1w2,r0
    mov     r0,(rr2)+
    mov     sg1w3,r0
    mov     r0,(rr2)+
    mov     sg1w4,r0
    mov     r0,(rr2)+
    mov     sg1w5,r0
    mov     r0,(rr2)+
    mov     sg1w6,r0
    mov     r0,(rr2)+
    mov     sg1w7,r0
    mov     r0,(rr2)+
    mov     sg1w8,r0
    mov     r0,(rr2)+
    mov     sg1w9,r0
    mov     r0,(rr2)+
    mov     sg1w10,r0
    mov     r0,(rr2)+
    mov     sg1w11,r0
    mov     r0,(rr2)+
    mov     sg1w12,r0
    mov     r0,(rr2)+
    mov     sg1w13,r0
    mov     r0,(rr2)+
    mov     sg1w14,r0
    mov     r0,(rr2)+
    mov     sg1w15,r0
    pop     r0
    popw    rr2
    ret

; Default values for sound generator
sg_default:
    db      021h,054h,066h,077h,077h,066h,045h,012h
    db      0efh,0bch,0aah,099h,099h,0aah,0cbh,0feh

; Play melody (or what they laughingly refer to as one - it's a bit shit...)
play_melody:
    bbc     0c9h,#4,mel_start
    bbs     sp_control,#0,mel_playing
    mov     r0,Melody_Register
    bbs     r0,#0,mel_playing
mel_start:
    bset    0c9h,#4
    push    mmu4
    mov     mmu4,#bank_melody
    movw    rr2,#melody
    call    start_chan0
    movw    rr2,#melody
    call    start_chan1
    pop     mmu4
mel_playing:
    ret

; Initialise TMR1 ISR (OL)
init_isr:
    di
    push    ps0
    movm    ps0,#7,#68h
    mov     r2,TMR1_new_ibank
    movw    rr0,TMR1_new_isr
    pop     ps0
    mov     TMR1_new_ibank,mmu2
    movw    rr0,#normal_timerx
    movw    TMR1_new_isr,rr0
    ei
    ret

; Restore TMR1 ISR (OL)
restore_isr:
    di
    push    ps0
    movm    ps0,#7,#68h
    mov     TMR1_new_ibank,r2
    movw    TMR1_new_isr,rr0
    pop     ps0
    ei
    ret    

; Stop melody playback (OL)
stop_melody:
    mov     r0,#0
    mov     Melody_Register,r0
    mov     r0,sgc
    bbs     sp_control,#0,stop_mel1
    clr     r0
    mov     sgc,r0
    ret
stop_mel1:
    and     r0,#0fch
    mov     sgc,r0
    ret
    
    end
