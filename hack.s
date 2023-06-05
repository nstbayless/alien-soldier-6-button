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

LILB = 0xFF2020

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
PATCH_BEGIN jump_dash_check
    jmp 0x5CD60
PATCH_END jump_dash_check

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
    jmp 0x5CF60
PATCH_END air_hang_piss_mode_check

.org 0x1654E
PATCH_BEGIN reverse_crouch_dash_jump_check
    jmp 0x5D360
PATCH_END reverse_crouch_dash_jump_check

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

.org 0x1F404
PATCH_BEGIN alternate_control_lilb
    jsr 0x5D320
PATCH_END alternate_control_lilb

.org 0x1f464
PATCH_BEGIN alternate_control_view
    nop
    nop
    jsr 0x5D1E0
PATCH_END alternate_control_view

.org 0x23D7A
PATCH_BEGIN demo_input
    jsr 0x5D150
PATCH_END demo_input

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
    
    btst #7,(CTRL0_B6_DOWN)
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
    
    /* very shortly after this, control goes to B6Pressed */
    rts

.org 0x05CCA0
B6Pressed:
    move.b (CTRL0_B6_RELEASED),%d0
    btst #7,%d0
    beq .skipToRts2
    
    move.b (CTRL0_B6_DOWN),%d1
    move.b %d0,(CTRL0_B6_DOWN)
    eor.b #0xFF,%d1
    and.b %d0,%d1
    and #0x0F,%d1
    
    /* _PRESSED now contains xyzm buttons pressed this frame. */
    move.b %d1,(CTRL0_B6_PRESSED)
    
    /* clear released */
    clr.b (CTRL0_B6_RELEASED)

.skipToRts2:
    /* shortly after this, control goes to MyCopyControls */
    /* (but during demo, will first go to DemoInput ) */
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
    bra SixButtonJumpOrDrop
    /*jmp 0x00015BF2*/

.sixbuttondodash:
    /* skip the on-platform check here; go straight to dash. */
    jmp 0x15936

.threebuttonjumpdash:
    btst #5,0x006A(%a5)
    jmp 0x00015BBE
    
.org 0x5CE00
MyAirJumpDashCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonairjumpdash
    
.sixbuttonairjumpdash:

    /* check piss mode, too */
    jsr 0x5CFF0 /*CheckPissMode*/

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
    
    btst #6,(CTRL0_B6_PRESSED)
    bne .skipcopyb6
    
    /* RELEASED is where we will check for PRESSED from now on, stupidly. */
    move.b (CTRL0_B6_PRESSED),(CTRL0_B6_RELEASED)
    
    /* transfer bit 7 of _DOWN to _RELEASED, to mark 6-button and not in cutscene */
    move.b %d0, (CTRL0_B6_PRESSED)
    move.b (CTRL0_B6_DOWN),%d0
    andi.b #0x80, %d0
    or.b %d0,(CTRL0_B6_RELEASED)
    move.b (CTRL0_B6_PRESSED), %d0
.skipcopyb6:
    rts
    
.org 0x5CF60
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
    
.org 0x5CFF0
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

.org 0x5D150
DemoInput:
    move.b 0xFFFF52,(CTRL0_DOWN)
    ori.b #0x40,(CTRL0_B6_PRESSED)
    rts
    
SixButtonJumpOrDrop:
    /* holding down? */
    btst #1,0x0069(%a5)
    beq .regularjump
    
    /* unknown */
    btst #6,0xFF8245
    bne .regularjump
    
    /* unknown */
    btst #2,0x6(%a5)
    beq .regularjump
    
.drop:
    jmp 0x15bea
    
.regularjump:
    jmp 0x15BF2
    
/* safe to clobber: a0, a1, d0 */
.org 0x5D1E0
AlternateControlView:
    btst #7,(CTRL0_B6_DOWN)
    beq .skipAlternateControlView
    btst #7,(LILB)
    beq .skipAlternateControlView
    clr.b (LILB)
    
    lea 0xC00004,%a1
    lea 0xC00000,%a0

    /* disable interrupts */
    move    #0x2700,%sr
    
    move.w #(0x8000 + (15 << 8) + 0x02),(%a1)   /*Auto-Increment*/
    
    /* cram 0 */
    /*move.l #(0xC07C0000),(%a1)
    move.l #00, (%a0)*/
    
    /* blank screen */
    /*move.w #(0x8000 + (1 << 8) + 0x2C),(%a1)*/

    move.l #(0x67b00003),(%a1) /* 0xe7b0 */    

    move.l #(0x67b00003),(%a1) /* 0xe7b0 */
    bsr .write4z
    move.l #(0x68300003),(%a1) /* 0xe830 */
    bsr .write4z
    move.l #(0x69300003),(%a1) /* 0xe930 */
    bsr .write4z
    move.l #(0x69B00003),(%a1) /* 0xe9B0 */
    bsr .write4z
    move.l #(0x6A300003),(%a1) /* 0xeA30 */
    bsr .write4z
    move.l #(0x6AB00003),(%a1) /* 0xeAB0 */
    bsr .write4z
    
    move    #0x2700,%sr
    
    /* wait for vblank */
.waitloop:
    move.w (%a1),%d0
    btst #3,%d0
    beq .waitloop
    
    move    #0x2300,%sr
    
    /* okay, now let's add new sprites in... */
    move.l #(0x40200000),(%a1) /* 0x0020 */
    move.l #4*4*6-1,%d0

    lea 0x5D3E0, %a1
.loop:
    move.l (%a1)+,(%a0)
    /*add.w #4,%a1*/
    dbra %d0, .loop
    
    /* update tilemap to show x/y/z buttons */
    lea 0xC00004,%a1
    
    /* x */
    move.l #(0x67b00003),(%a1) /* 0xe7b0 */
    move.l #0xA001A003,(%a0)
    move.l #(0x68300003),(%a1) /* 0xe830 */
    move.l #0xA002A004,(%a0)
    
    /* z */
    move.l #(0x69300003),(%a1) /* 0xe7b0 */
    move.l #0xA009A00B,(%a0)
    move.l #(0x69b00003),(%a1) /* 0xe830 */
    move.l #0xA00AA00C,(%a0)

    /* y */
    move.l #(0x6A300003),(%a1) /* 0xe7b0 */
    move.l #0xA005A007,(%a0)
    move.l #(0x6AB00003),(%a1) /* 0xe830 */
    move.l #0xA006A008,(%a0)
    
    /* unblank screen */
    /*move.w #(0x8000 + (1 << 8) + 0x6C),(%a1)*/
    
    /* enable interrupts */
    move    #0x2300,%sr
   
.skipAlternateControlView:
    /* original code */
    jsr 0x1f784
    btst #7,0xfff708
    rts
    
 .write4z:
    move.l #00, (%a0)
    move.l #00, (%a0)
    move.l #00, (%a0)
    move.l #00, (%a0)
    rts

.org 0x5D320
SetLilB:
    btst #7,(CTRL0_B6_DOWN)
    beq .lilborgcode
    ori.b #0x80, (LILB)
    
    /* okay to clobber %a1 */
    /*
    move.l 0xC00004,%a1
    
    move    #0x2700,%sr
    move.w #(0x8000 + (15 << 8) + 0x02),(%a1)
    
    move.l #(0xC07C0000),(%a1)
    move.l 0xC00000,%a1
    move.l #00, (%a1)
    
    move    #0x2300,%sr
    */
    
.lilborgcode:
    /* original code */
    jmp 0x4614

.org 0x5D360
ReverseCrouchAirDash:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonreversecrouchdashcheck

.sixbuttonreversecrouchdashcheck:
    /* check z */
    btst #0,(CTRL0_B6_RELEASED)
    bne .reversecrouchdash

    btst #5,0x006A(%a5)
    bne .reversecrouchjump
    
.noreversecrouchjump:
    jmp 0x16564
    
.reversecrouchjump:
    jmp 0x15C72

.reversecrouchdash:
    jmp 0x16560

.threebuttonreversecrouchdashcheck:
    btst #5,0x006A(%a5)
    jmp 0x16554
    
.org 0x5D3E0
Sprites:

/* (X) - top left */
    .long 0x00000000
    .long 0x000000EE
    .long 0x0000EE11
    .long 0x000E1211
    
    .long 0x00E11211
    .long 0x00E11211
    .long 0x0E111121
    .long 0x0E111112
    
/* (X) - bottom left */
    .long 0x0E111121
    .long 0x0E111211
    .long 0x0DE11211
    .long 0x00E11211
    
    .long 0x00DE1111
    .long 0x000DEE11
    .long 0x0000DDEE
    .long 0x000000DD

/* (X) - top right */    
    .long 0x00000000
    .long 0xEE000000
    .long 0x11EE0000
    .long 0x1211E000

    .long 0x12111E00
    .long 0x12111E00
    .long 0x211111E0
    .long 0x111111E0

/* (X) - bottom right */    
    .long 0x211111E0
    .long 0x121111E0
    .long 0x12111ED0
    .long 0x12111E00
    
    .long 0x1111ED00
    .long 0x11EED000
    .long 0xEEDD0000
    .long 0xDD000000

/* (Y) - top left */
    .long 0x00000000
    .long 0x000000EE
    .long 0x0000EE11
    .long 0x000E1211
    
    .long 0x00E11211
    .long 0x00E11211
    .long 0x0E111121
    .long 0x0E111112
    
/* (Y) - bottom left */
    .long 0x0E111112
    .long 0x0E111112
    .long 0x0DE11112
    .long 0x00E11112
    
    .long 0x00DE1111
    .long 0x000DEE11
    .long 0x0000DDEE
    .long 0x000000DD

/* (Y) - top right */    
    .long 0x00000000
    .long 0xEE000000
    .long 0x11EE0000
    .long 0x1211E000

    .long 0x12111E00
    .long 0x12111E00
    .long 0x211111E0
    .long 0x111111E0

/* (Y) - bottom right */    
    .long 0x111111E0
    .long 0x111111E0
    .long 0x11111ED0
    .long 0x11111E00
    
    .long 0x1111ED00
    .long 0x11EED000
    .long 0xEEDD0000
    .long 0xDD000000

/* (Z) - top left */
    .long 0x00000000
    .long 0x000000EE
    .long 0x0000EE11
    .long 0x000E1222
    
    .long 0x00E11111
    .long 0x00E11111
    .long 0x0E111111
    .long 0x0E111112
    
/* (Z) - bottom left */
    .long 0x0E111121
    .long 0x0E111211
    .long 0x0DE11211
    .long 0x00E11222
    
    .long 0x00DE1111
    .long 0x000DEE11
    .long 0x0000DDEE
    .long 0x000000DD

/* (Z) - top right */    
    .long 0x00000000
    .long 0xEE000000
    .long 0x11EE0000
    .long 0x2211E000

    .long 0x12111E00
    .long 0x12111E00
    .long 0x211111E0
    .long 0x111111E0

/* (Z) - bottom right */    
    .long 0x111111E0
    .long 0x111111E0
    .long 0x11111ED0
    .long 0x22111E00
    
    .long 0x1111ED00
    .long 0x11EED000
    .long 0xEEDD0000
    .long 0xDD000000

PATCH_END_injected_code:
