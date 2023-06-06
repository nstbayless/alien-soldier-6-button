/* Before you ask -- I could not get m68k-linux-gnu-as to assemble jmp/jsr to absolute addresses
   by label. That's why you'll se a lot of jsr 0x05CB78 and so on in this code. */

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
PISS_MODE = 0xFFA22A /* word; in bit 1 */

/* queue is in sets of 0x10-length entries sent to 0xC00004
   from routine at 0x000DB2. To add to the queue, prepend/decrement!
   (grows downward from 0xFFF3F0?). */
DMA_QUEUE = 0xFFF70C

/* arbitrary data for DMA. Grows upward from 0xFFF400. */
DMA_DATA = 0xFFF70E

CTRL1_DATA = 0x00A10003
CTRL1_CTRL = 0x00A10009

/* disable checksum check */
.org 0x36C
    PATCH_BEGIN skip_checksum_death
    nop
    nop
    PATCH_END skip_checksum_death

/* disable region lock */    
.org 0x4CE
    PATCH_BEGIN skip_region_lock
    nop
    PATCH_END skip_region_lock

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
    jmp 0x5CF90
PATCH_END air_hang_piss_mode_check

.org 0x1654E
PATCH_BEGIN reverse_crouch_dash_jump_check
    jmp 0x5D1A0
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

.ifdef MODE_TOGGLE
.org 0x16C90
PATCH_BEGIN piss_mode_yellow_xor_x
    /*jsr 0x5D500*/
PATCH_END piss_mode_yellow_xor_x
.endif

.org 0x1f3e6
PATCH_BEGIN test_screen_patch
    jmp 0x5D3B0
PATCH_END test_screen_patch

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
    /* d0 <- directly read input */
    move.b (CTRL0_B6_RELEASED),%d0
    btst #7,%d0
    beq .skipToRts2
    
    .ifdef MODE_TOGGLE
        /* check if x pressed OR released */
        move.b (CTRL0_B6_DOWN),%d1
        eor.b %d0,%d1
        andi.b #0x4,%d1
        lsl.b #2,%d1
        move.b %d1,(CTRL0_B6_PRESSED)
    .endif
    
    move.b (CTRL0_B6_DOWN),%d1
    move.b %d0,(CTRL0_B6_DOWN)
    eor.b #0xFF,%d1
    and.b %d0,%d1
    and #0x0F,%d1
    
    /* _PRESSED now contains xyzm buttons pressed this frame. */
    .ifdef MODE_TOGGLE
        or.b %d1,(CTRL0_B6_PRESSED)
    .else
        move.b %d1,(CTRL0_B6_PRESSED)
    .endif
    
    /* clear released */
    clr.b (CTRL0_B6_RELEASED)

.skipToRts2:
    /* shortly after this, control goes to MyCopyControls */
    /* (but during demo, will go to DemoInput instead! ) */
    rts

.org 0x05CCF0
MyPissModeCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonpissmode
    
.sixbuttonpissmode:
/* check mode */
    btst #3,(CTRL0_B6_RELEASED)
.ifndef MODE_TOGGLE
    bne .yespissmode
    
/* check x */
    btst #2,(CTRL0_B6_RELEASED)
    beq .nopissmode
.else
    beq .nopissmode
.endif
    
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

    clr.b (CTRL0_B6_RELEASED)    
    btst #7,(CTRL0_B6_DOWN)
    beq .skipcopyb6
    
    /* RELEASED is where we will check for PRESSED from now on, stupidly. */
    move.b (CTRL0_B6_PRESSED),(CTRL0_B6_RELEASED)
    
    /* transfer bit 7 of _DOWN to _RELEASED, to mark 6-button and not in cutscene */
    move.b %d0, (CTRL0_B6_PRESSED)
    
    .ifdef MODE_TOGGLE
        /* if holding X down, mark that in CTRL0_B6_RELEASED*/
        move.b (CTRL0_B6_DOWN),%d0
        andi.b #0x04,%d0
        lsl.b #3,%d0
        or.b %d0,(CTRL0_B6_RELEASED)
        
        /* toggle piss mode */
        btst #4,(CTRL0_B6_RELEASED)
        beq .skiptogglepiss
        eori.b #0x2,(PISS_MODE+1)
    .skiptogglepiss:
    .endif
    
    move.b (CTRL0_B6_DOWN),%d0
    andi.b #0x80, %d0
    or.b %d0,(CTRL0_B6_RELEASED)
    
    /* Y */
    btst #1,(CTRL0_B6_RELEASED)
    beq .nocounterforcestop
.counterforcestop:
    /* this is to fix a bug that happens if you parry while walking backward.
       stop moving left/right if you press parry. */
    andi.b #0xF3,0x69(%a5)

.nocounterforcestop:
    move.b (CTRL0_B6_PRESSED), %d0
.skipcopyb6:
    rts
    
.org 0x5CF90
MyHangPissModeCheck:
    btst #7,(CTRL0_B6_RELEASED)
    beq .threebuttonhangpissmode
    
.sixbuttonhangpissmode:
    /* mode */
    btst #3,(CTRL0_B6_RELEASED)
    bne .yeshangpissmode
    
.ifndef MODE_TOGGLE
    /* X */
    btst #2,(CTRL0_B6_RELEASED)
    bne .yeshangpissmode
.endif
    
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
.ifndef MODE_TOGGLE
    btst #2,(CTRL0_B6_RELEASED)
    bne .yespissmodec
.endif
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
    
.org 0x5D1A0
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
    
.org 0x5D1E0
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
    
.org 0x5D360

.ifdef MODE_TOGGLE
    TextTemporaryAiming:
        /* copied from 0x1FB8B ... 0x1FBA7 */
        .long 0x1D121919 /*; SHOO*/
        .long 0x1E001719 /*; T MO*/
        .long 0x0E0F0012 /*; DE H*/
        .long 0x19160E00 /*; OLD */
        .long 0x2E000102 /*; - ()*/
        .byte 0xFF /*; \  */
.else

    TextShootModeChange:
        /* copied from 0x1FB8B ... 0x1FBA7 */
        .long 0x1D121919 /*; SHOO*/
        .long 0x1E001719 /*; T MO*/
        .long 0x0E0F000D /*; DE C*/
        .long 0x120B1811 /*; HANG*/
        .long 0x0F002E00 /*; E - */
        .long 0x0102FF00
.endif
    
/* could add "shoot mode toggle" btw */
.org 0x5D378
TextZeroTeleport:
    /* copied from 0x1FBA7 ... 0x1FBBF */
    .long 0x240F1C19 /*; ZERO*/
    .long 0x001E0F16 /*;  TEL*/
    .long 0x0F1A191C /*; EPOR*/
    .long 0x1E002E00 /*; T - */
    .long 0x0506FF00

.org 0x5D38C
TextCounterForce:
    /* copied from 0x1FBBf ... 0x1FBD7 */
    .long 0x0D191F18 /*; COUN*/
    .long 0x1E0F1C00 /*; TER */
    .long 0x10191C0D /*; FORC */
    .long 0x0F002E00 /*; E - */
    .long 0x0304FF00


.org 0x5D3B0
CustomTestScreenTransfer:
    addq.w #2,0xffa29c
    clr.w 0xff8040
    btst #7,(CTRL0_B6_DOWN)
    beq .orgScreenTransfer
    
.transferloop:
    lea TextTransferList(%pc),%a1
    move.w 0xff8040,%d1
    move.w 0x00(%a1,%d1.w),%d0
    move.w 0x02(%a1,%d1.w),%d4
    move.l 0x04(%a1,%d1.w),%a0
    jsr 0x4614
    addi.w #0x8,0xff8040
    .ifdef MODE_TOGGLE
    cmpi.w #0x48,0xff8040
    .else
    cmpi.w #0x40,0xff8040
    .endif
    bne .transferloop
    
    /* our own DMA -- this should be no. 0x10-length entries minus 1 */
    moveq #0, %d0
    lea ScreenDMAListEnd(%pc),%a0
    movea.w (DMA_QUEUE),%a1
.adddmaloop:
    move.l -(%a0),-(%a1)
    move.l -(%a0),-(%a1)
    move.l -(%a0),-(%a1)
    move.l -(%a0),-(%a1)
    dbra %d0,.adddmaloop
    move.w %a1,(DMA_QUEUE)
    
    jmp 0x1f418

.orgScreenTransfer:
    jmp 0x1F3EE
    
TextTransferList:
    .word 0x8100
    .word 0x629C
    .long 0x1FB57
    
    .word 0xA100
    .word 0x6410
    .long 0x1FB64
    
    .word 0xA100
    .word 0x6522
    .long 0x1FB77
    
    .word 0xA100
    .word 0x6622
    .long 0x1FB81
    
    .ifdef MODE_TOGGLE
        .word 0xA100
        .word 0x680C
        .long 0x5D360 /* TextTemporaryAiming*/
        
        .word 0xA100
        .word 0x6708
        .long 0x5D4A0 /* TextShootModeToggle*/
    .else
        .word 0xA100
        .word 0x6788
        .long 0x5D360 /* TextShootModeChange*/
    .endif
    
    .word 0xA100
    .word 0x6910
    .long 0x5D38C /* TextCounterForce */
    
    .word 0xA100
    .word 0x6A10
    .long 0x5D378 /* TextZeroTeleport*/
    
    .word 0xA100
    .word 0x6B1A
    .long 0x1FBD7
    
ScreenDMAList:
TileDataDMA:
    /* length of data (Sprites) */
    .long 0x940093C0
    
    /* address of Sprites divided by 2. */
    .long 0x8F029702 /* auto-increment: 2; addr hi: 0x02*/
    .long 0x96e895f0 /* addr med: 0xe8; lo: f0*/
    .long 0x60400080 /* vram dst addr and execute DMA */
    
PatchDataShootModeDMA:
    /*.long 0x94009302 /* length (4) */
    
    /* address of PatchDataShootMode/2 */
    /*.long 0x8F029702 /* auto-inc: 2; hi: 0x02 */
    /*.long 0x96ea9540 /* med: 0xea; lo: 0x40*/
    /*.long 0x67b00083 /* vram dst addr (e7b0) and execute DMA */

ScreenDMAListEnd:
    .long 0x94009304
    
.ifdef MODE_TOGGLE        
    .org 0x5D4A0
    TextShootModeToggle:
        .long 0x1D121919 /*; SHOO*/
        .long 0x1E001719 /*; T MO*/
        .long 0x0E0F001E /*; DE T*/
        .long 0x19111116 /*; OGGL*/
        .long 0x0F002E00 /*; E - */
        .long 0x17190E0F /*; MODE*/
        .byte 0xFF
        
    .org 0x5D500
    CheckPissColour:
        tst.w (PISS_MODE)
        rts
        
        btst #7,(CTRL0_B6_RELEASED)
        beq .orgCheckPissColour
        btst #5,(CTRL0_B6_RELEASED)
        beq .orgCheckPissColour
        tst.w (PISS_MODE)
        bne .getbe
    
    .getbne:
        btst #7,(CTRL0_B6_RELEASED) /* guaranteed ne*/
        rts
        
    .getbe:
        btst #6,(CTRL0_B6_RELEASED) /* guaranteed eq*/
        rts
        
    .orgCheckPissColour:
        tst.w (PISS_MODE)
        rts
.endif
PATCH_END_injected_code:
