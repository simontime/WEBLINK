    title   Web Link melody
    type    8521
    
    include melody.inc

    global  melody

NLH   equ 1fh
NLL   equ 1fh
A_LEN equ 5

melody:
    db      D5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      G5,NLH,A_LEN*16/8
    db      C4,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*16/8
    db      D5,NLH,A_LEN*16/8
    db      C4,NLH,A_LEN*32/8
    db      D5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      A5,NLH,A_LEN*16/8
    db      C4,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*16/8
    db      D5,NLH,A_LEN*16/8
    db      A5,NLH,A_LEN*32/8
    db      D5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      G5,NLH,A_LEN*16/8
    db      C4,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*16/8
    db      D5,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*32/8
    db      D5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      A5,NLH,A_LEN*16/8
    db      C4,NLH,A_LEN*16/8
    db      A4,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      A4,NLH,A_LEN*32/8
    db      D5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      A4,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      A4,NLH,A_LEN*32/8
    db      C5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      G4,NLH,A_LEN*32/8
    db      C5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      F4,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      E5,NLH,A_LEN*16/8
    db      C5,NLH,A_LEN*16/8
    db      F4,NLH,A_LEN*32/8
    db      C5,NLH,A_LEN*16/8
    db      D5,NLH,A_LEN*16/8
    db      B4,NLH,A_LEN*32/8
    db      C5,NLH,A_LEN*32/8
    db      D5,NLH,A_LEN*32/8
    db      0,0,0

    end
