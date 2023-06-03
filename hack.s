.macro PATCH_BEGIN label
    PATCH_BEGIN_\label:
.endm

.macro PATCH_END label
    PATCH_END_\label:
.endm

.org 0x33C8
    PATCH_BEGIN skip_p2_read
    nop
Interrupt:
    nop
    PATCH_END skip_p2_read
