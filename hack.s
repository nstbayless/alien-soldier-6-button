.macro PATCH_BEGIN label
    PATCH_BEGIN_\label:
.endm

.macro PATCH_END label
    PATCH_END_\label:
.endm

.macro COOLKID_NOP
    .byte 0x4E
    .byte 0x71
.endm

CTRL0_DOWN = 0xFFF706
CTRL1_DOWN = 0xFFF707
CTRL1_DATA = 0x00A10003
CTRL1_CTRL = 0x00A10009

.org 0x36C
    PATCH_BEGIN skip_checksum_death
    nop
    nop
    PATCH_END skip_checksum_death

.org 0x33a8
    PATCH_BEGIN read_controller_init
    jsr 0x05CB78 /*InitSubroutine*/
    PATCH_END read_controller_init

/* skip reading p2 input */
.org 0x33C8
    PATCH_BEGIN skip_p2_read
    nop
    nop
    PATCH_END skip_p2_read

.org 0x3440
PATCH_BEGIN jump_to_subroutine
    jsr 0x05CC28 /*SUBROUTINE*/
    nop
PATCH_END jump_to_subroutine

.org 0x05CB78
PATCH_BEGIN_injected_code:

/* It's okay to clobber a1, d1, d0 here */
InitSubroutine:
    move.b #0x40,(CTRL1_CTRL)
    
    move.b #0x00,(CTRL1_DOWN)
    
    /* 1 + TH high */
    lea CTRL1_DATA,%a1
    nop
    nop
    
    /* 2 + TH low */
    move.b #0x00,(%a1)
    nop
    nop
    
    /* 3 + TH high */
    move.b #0x40,(%a1)
    nop
    nop
    
    /* 4 + TH low */
    move.b #0x00,(%a1)
    nop
    nop
    
    /* 5 + TH high */
    move.b #0x40,(%a1)
    nop
    nop
    
    /* 6 + TH high */
    move.b #0x00,(%a1)
    nop
    nop
    move.b (%a1),%d0
    
    cmpi.b #0b00110011,%d0
    beq.s skip
    
    move.b #0x80,(CTRL1_DOWN)
skip:
    rts
PATCH_END_injected_code:

.org 0x05CC28

Subroutine:
PATCH_BEGIN_injected_code_2:
    /* copied from detour site */
    andi.b #0x3F,%d1
    or.b %d1,%d0
    not.b %d0

    /*move.b d1,(CTRL1_DOWN+2)
    
    move.b (CTRL1_DOWN),d1
    tst.b d1
    
    move.b (CTRL1_DOWN+2),d1*/
    
    rts
    
PATCH_END_injected_code_2:
