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
CTRL0_B6_DOWN = 0xFFF707
CTRL0_PRESSED = 0xFFF708
CTRL0_B6_PRESSED = 0xFFF709
CTRL0_RELEASED = 0xFFF70A
CTRL0_B6_RELEASED = 0xFFF70B

CTRL1_DATA = 0x00A10003
CTRL1_CTRL = 0x00A10009

.org 0x36C
    PATCH_BEGIN skip_checksum_death
    nop
    nop
    PATCH_END skip_checksum_death

.org 0x33a8
    PATCH_BEGIN read_controller_init
    jsr  0x05CB78 /*SubroutineInit*/
    PATCH_END read_controller_init

/* skip reading p2 input */

/*
.org 0x33C8
    PATCH_BEGIN skip_p2_read
    nop
    nop
    PATCH_END skip_p2_read
*/

.org 0x3408
    PATCH_BEGIN b6_pressed_release
    jmp 0x05CCA0 /*B6Pressed*/
    PATCH_END b6_pressed_release

.org 0x3440
PATCH_BEGIN jump_to_subroutine
    jsr 0x05CC20 /*SUBROUTINE*/
    nop
PATCH_END jump_to_subroutine

.org 0x05CB78
PATCH_BEGIN_injected_code:

/* It's okay to clobber a1, d1, d0 here */
InitSubroutine:
    move.b #0x40,(CTRL1_CTRL)
    
    move.b #0x00,(CTRL0_B6_DOWN)
    
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
    
    move.b #0x80,(CTRL0_B6_DOWN)
skip:
    rts

.org 0x05CC20
Subroutine:
    /* copied from detour site */
    andi.b #0x3F,%d1
    or.b %d1,%d0
    not.b %d0

    move.b %d1,(CTRL0_B6_PRESSED)
    
    move.b (CTRL0_B6_DOWN),%d1
    tst.b %d1
    beq .skipToRts
    
    move.b #0x40,(%a2)
    nop
    nop
    move.b #0x00,(%a2)
    nop
    nop
    move.b #0x40,(%a2)
    nop
    nop
    move.b #0x00,(%a2)
    nop
    nop
    move.b #0x40,(%a2)
    nop
    nop
    move.b (%a2),%d1
    not.b %d1
    andi.b #0x0F,%d1
    ori.b #0x80,%d1

    /* store inputs that were read */
    move.b %d1, (CTRL0_B6_RELEASED)
    
.skipToRts:
    move.b (CTRL0_B6_PRESSED),%d1
    
    rts

.org 0x05CCA0
B6Pressed:
    move.b (CTRL0_B6_RELEASED),%d0
    andi.b #0x80,%d0
    tst.b %d0
    beq .skipToRts2
    
    move.b (CTRL0_B6_RELEASED),%d0
    move.b (CTRL0_B6_DOWN),%d1
    move.b %d0,(CTRL0_B6_DOWN)
    eor.b #0xFF,%d1
    and.b %d0,%d1
    move.b %d1,(CTRL0_B6_PRESSED)

.skipToRts2:
    rts
    
PATCH_END_injected_code:
