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

/* just so you know, the B6_ names are meaningless now. Ignore the names. */

CTRL0_DOWN = 0xFFF706
CTRL0_B6_DOWN = 0xFFF707
CTRL0_PRESSED = 0xFFF708
CTRL0_B6_PRESSED = 0xFFF709
CTRL0_RELEASED = 0xFFF70A
CTRL0_B6_RELEASED = 0xFFF70B

CTRL1_DATA = 0x00A10003
CTRL1_CTRL = 0x00A10009

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

.org 0xA60C
    PATCH_BEGIN fix_password_dir_up
    moveq #1,%d0
    PATCH_END fix_password_dir_up

.org 0xA622
    PATCH_BEGIN fix_password_dir_down
    moveq #-1,%d0
    PATCH_END fix_password_dir_down

.org 0x15168
PATCH_BEGIN pit_mode_buttons
    jmp 0x5D020
PATCH_END pit_mode_buttons

.org 0x155B0
PATCH_BEGIN piss_mode_check
    jmp 0x05CCF0 /*MyPissModeCheck*/
PATCH_END piss_mode_check

.org 0x15BB8
PATCH_BEGIN no_jump_4
    jmp 0x5CD40
PATCH_END no_jump_4

.org 0x15C20
PATCH_BEGIN reverse_dash_check
    jmp 0x5D0E0
PATCH_END reverse_dash_check

.org 0x15d6A
PATCH_BEGIN air_dash_check
    jmp 0x5CE00
PATCH_END air_dash_check

.org 0x160E2
PATCH_BEGIN air_hang_dash_check
    jmp 0x5CE50
PATCH_END air_hang_dash_check

.org 0x1615C
PATCH_BEGIN air_hang_piss_mode_check
    jmp 0x5CF50
PATCH_END air_hang_piss_mode_check

.org 0x166EA
PATCH_BEGIN reverse_piss_check  
    jmp 0x5D080
PATCH_END reverse_piss_check

.org 0x16B0A
PATCH_BEGIN copy_controls
    nop
    jmp 0x5CF00
PATCH_END copy_controls

.org 0x16B24
PATCH_BEGIN counterforce_check
    jmp 0x5CEA0
PATCH_END counterforce_check

.org 0x16DA6
PATCH_BEGIN pit_remove
    
PATCH_END pit_remove

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
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonpissmode
    
.sixbuttonpissmode:
/* check mode */
    btst #3,(CTRL0_B6_RELEASED)
    bne .yespissmode
/* check x */
    btst #2,(CTRL0_B6_RELEASED)
    beq .nopissmode
    
.yespissmode:
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
    
.org 0x5CD60
MyJumpDashCheck:
    btst #7,(CTRL0_B6_RELEASED)
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
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonairjumpdash
    
.sixbuttonairjumpdash:

    /* check piss mode, too */
    jsr 0x5CFE0 /*CheckPissMode*/

    /* Z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .sixbuttonairdash
    btst #5,0x006A(%a5)
    bne .sixbuttonairjump
    /* no air jump */
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
    btst #7,(CTRL0_B6_RELEASED)
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
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttoncounterforce
    
    /* cool kid counterforce */
    /* Y */
    btst #1,(CTRL0_B6_RELEASED)
    beq .nocounterforce
    jmp 0x00016B32
    
.threebuttoncounterforce:
    subq.w #1,0xff826A
    bmi .nocounterforce
    jmp 0x16B2a

.nocounterforce:
    jmp 0x16B3A
   
.org 0x5CF00
MyCopyControls:
    move.b 0xFFF706,0x69(%a5)
    move.b 0xFFF708,0x6A(%a5)
    move.b (CTRL0_B6_PRESSED),(CTRL0_B6_RELEASED)
    
    /* transfer bit 7 of _DOWN to _RELEASED, to mark 6 button and not in cutscene */
    move.b %d0, (CTRL0_B6_PRESSED)
    move.b (CTRL0_B6_DOWN),%d0
    andi.b #0x80, %d0
    or.b %d0,(CTRL0_B6_RELEASED)
    move.b (CTRL0_B6_PRESSED), %d0
    rts
    
.org 0x5CF50
MyHangPissModeCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonhangpissmode
    
.sixbuttonhangpissmode:
    /* mode */
    btst #3,(CTRL0_B6_RELEASED)
    bne .yeshangpissmode
    /* X */
    btst #2,(CTRL0_B6_RELEASED)
    bne .yeshangpissmode
    
.nohangpissmode:
    btst #6,0x006A(%a5)
    beq .nohangpisswitch
    jmp 0x16174
    
.nohangpisswitch:
    jmp 0x16170
    
.yeshangpissmode:
    jmp 0x1616C
    
.threebuttonhangpissmode:
    btst #6,0x006A(%a5)
    jmp 0x16162
    
.org 0x5CFE0
CheckPissMode:
    /* mode */
    btst #3,(CTRL0_B6_RELEASED)
    bne .yespissmodec
    btst #2,(CTRL0_B6_RELEASED)
    bne .yespissmodec
    rts
.yespissmodec:
   jmp 0x15638
   
.org 0x5D020
CheckPitButtons:
    move.b (CTRL0_B6_RELEASED),%d0
    and #0x7,%d0
    bne .pressedpitbutton
    move.b 0x006a(%a5),%d0
    andi.w #0x70,%d0
    bne .pressedpitbutton

.nopitbutton:
    jmp 0x15182

.pressedpitbutton:
    jmp 0x15172

.org 0x5D080
ReversePissCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonreversepisscheck

.sixbuttonreversepisscheck:
    bsr CheckPissMode
    btst #6,0x6A(%a5)
    bne .reversepissmenu
    jmp 0x16702
    
.reversepissmenu:
    jmp 0x166FC

.threebuttonreversepisscheck:
    btst #6,0x6A(%a5)
    jmp 0x166F0

.org 0x5D0E0
ReverseDashCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonreversedashcheck

.sixbuttonreversedashcheck:
    /* check z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .reversedash

    btst #5,0x006A(%a5)
    bne .reversejump
    
.noreversejump:
    jmp 0x15C1E
    
.reversejump:
    jmp 0x15C32

.reversedash:
    jmp 0x1592E

.threebuttonreversedashcheck:
    btst #5,0x006A(%a5)
    jmp 0x15C26

PATCH_END_injected_code:
