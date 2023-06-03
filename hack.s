.macro PATCH_BEGIN label
    PATCH_BEGIN_\label:
.endm

.macro PATCH_END label
    PATCH_END_\label:
.endm

.org 0x36C
    PATCH_BEGIN skip_checksum_death
    nop
    nop
    PATCH_END skip_checksum_death

.org 0x33C8
    PATCH_BEGIN skip_p2_read
    nop
    nop
    PATCH_END skip_p2_read

/*
.org 0x3440
PATCH_BEGIN jump_to_subroutine
    jsr Subroutine
PATCH_END jump_to_subroutine

.org 0x3462
subsubroutine:

.org 0x05CB78
PATCH_BEGIN_injected_code:
Subroutine:
    /* copied from detour site */
    or.b %d1, %d0
    andi.b #$3F,%d1
    or.b %d1,%d0
    not.b %d0
    
    /*andi.b #$BF,%d0*/
    
    jsr subsubroutine
    rts
PATCH_END_injected_code:

*/
