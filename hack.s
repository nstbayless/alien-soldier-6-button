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

/* disable region lock */
.org 0x34E
    PATCH_BEGIN skip_region_lock
    nop
    PATCH_END skip_region_lock

/* disable checksum check */
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

.org 0x155B0
PATCH_BEGIN piss_mode_check
    jmp 0x05CCF0 /*MyPissModeCheck*/
PATCH_END piss_mode_check

.org 0x15BB8
PATCH_BEGIN no_jump_4
    jmp 0x5CD40
PATCH_END no_jump_4

.org 0x15d6A
PATCH_BEGIN air_dash_check
    jmp 0x5CE00
PATCH_END air_dash_check

.org 0x160E2
PATCH_BEGIN air_hang_dash_check
    jmp 0x5CE50
PATCH_END air_hang_dash_check

.org 0x16B0A
PATCH_BEGIN copy_controls
    nop
    jmp 0x5CF00
PATCH_END copy_controls


.org 0x16B24
PATCH_BEGIN counterforce_check
    jmp 0x5CEA0
PATCH_END counterforce_check

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
    
    /* write 0 to released */
    andi.b #0x00, %d1
    move.b %d1,(CTRL0_B6_RELEASED)

.skipToRts2:
    rts

.org 0x05CCF0
MyPissModeCheck:
    btst #7,(CTRL0_B6_DOWN)
    beq .threebuttonpissmode
    
.sixbuttonpissmode:
/* check x */
    btst #2,(CTRL0_B6_RELEASED)
    beq .nopissmode
    jmp 0x15632
    
.threebuttonpissmode:
    /* original code */
    btst     #6,0x006A(%a5)
    jmp 0x155B6

.nopissmode:
    btst     #6,0x006A(%a5)
    beq .noAButton
    jmp 0x155C2
    
.noAButton:
    jmp 0x155C8
    
.org 0x5CD40
MyJumpDashCheck:
    btst #7,(CTRL0_B6_DOWN)
    beq .threebuttonjumpdash

.sixbuttonjumpdash:
    /* check z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .sixbuttondodash
    btst #5,0x006A(%a5)
    bne .sixbuttonjump
    jmp 0x015C1E

.sixbuttonjump:
    jmp 0x00015BF2

.sixbuttondodash:
    jmp 0x15BCA

.threebuttonjumpdash:
    btst #5,0x006A(%a5)
    jmp 0x00015BBE
    
.org 0x5CE00
MyAirJumpDashCheck:
    btst #7,(CTRL0_B6_DOWN)
    beq .threebuttonairjumpdash
    
.sixbuttonairjumpdash:
    /* Z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .sixbuttonairdash
    btst #5,0x006A(%a5)
    bne .sixbuttonairjump
    jmp 0x00015D8E
    
.sixbuttonairjump:
    jmp 0x15D7A
    
.sixbuttonairdash:
    jmp 0x00015D84
   
.threebuttonairjumpdash:
    btst #5,0x006A(%a5)
    jmp 0x00015D70
   
.org 0x5CE50
MyHangDashJumpCheck:
    btst #7,(CTRL0_B6_DOWN)
    beq .threebuttonhangjumpdash
    
.sixbuttonhangjumpdash:
    /* Z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .sixbuttonhangdash
    btst #5,0x006A(%a5)
    bne .sixbuttonhangjump
    jmp 0x16116
    
.sixbuttonhangjump:
    jmp 0x160FA
    
.sixbuttonhangdash:
    jmp 0x00015936
   
.threebuttonhangjumpdash:
    btst #5,0x006A(%a5)
    jmp 0x160E8

.org 0x5CEA0
MyCounterforce:
    btst #7,(CTRL0_B6_DOWN)
    beq .threebuttoncounterforce
    
    /* cool kid counterforce */
    /* Y */
    btst #1,(CTRL0_B6_RELEASED)
    beq .nocounterforce
    jmp 0x00016B32
    
.threebuttoncounterforce:
    subq.w #1,0x826A
    bmi .nocounterforce
    jmp 0x16B2a

.nocounterforce:
    jmp 0x16B3A
   
.org 0x5CF00
MyCopyControls:
    move.b 0xFFF706,0x69(%a5)
    move.b 0xFFF708,0x6A(%a5)
    move.b (CTRL0_B6_PRESSED),(CTRL0_B6_RELEASED)
    rts
   
PATCH_END_injected_code:
