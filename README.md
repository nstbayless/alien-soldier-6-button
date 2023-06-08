# 6-Button Controller Support for Alien Soldier (v1.3)

*By NaOH, with contributions from TwistC and MiniMacro*

## Functionality

This hack adds support for 6-button controllers, while retaining legacy support for 3-button controllers. Depending on whether a 3-button or 6-button controller is inserted into the console, a different control scheme will be used.

The recommended variant is `alien-soldier-6-button-toggle.ips`, but if you are particular, then there are two different configuration decisions to make (see "Variants," below.)

- You can now dash by pressing Z. (Down+C no longer dashes in 6-button mode.)
- You can now perform the "Counter Force" parry manoeuvre by pressing Y. (Double-tap B no longer parries in 6-button mode.)
- You can now toggle shoot modes by pressing X or Mode at any time. (Down+A no longer swaps shoot mode in 6-button mode.)
- The new controls are displayed in the "control test" screen, assuming a 6-button controller is inserted.
- On the password input screen, pressing up now increments the number and down decrements. Furthermore, A, B, or C can now all be used to confirm password.
- Bypasses internal checksum verification and region lock.

## Variants

- "Hold" vs "Toggle": In the "Hold" variant of the hack, the shoot mode is only temporarily changed by holding X. (It can still be toggled with the Mode button, however.) This is useful if your controller has shoulder buttons, or for some keyboard layouts. However, it's inconvenient for standard 6-button controllers.
- "Hybrid" variants accept the original 3-button control combo-inputs in addition to the new 6-button controls. This is useful for those with strong muscle memory of the original game. However, it is not recommended for most players due to the likelihood of accidentally triggering an unintended input.

## Patching Instructions

Only the Japanese ROM is supported. Please verify the ROM's hash before patching, which is listed below.

You can apply the patch using FLIPS or any other IPS patcher.

## Source Code

The assembly and build scripts for this hack are available on GitHub. Please take a look: https://github.com/nstbayless/alien-soldier-6-button

## Changelog

v1.3

    - fixed demo (was broken in v1.1)
    - password entry can confirm with a, b, or c (instead of just c as in the base game)

v1.2

    - corrected hybrid counterforce text in controls menu

v1.1:

    - added hybrid variant
    - fixed a bug in the hold variant where pressing or releasing X during hitstun toggles shoot mode like pressing Mode would.
    - fixed dash and shoot mode inputs in certain late-game sections

## ROM Hashes

JP ROM:
    MD5: fd04c4616bb559e646937effdd343a09
    SHA256: 5613637d267cf8d0bf3ff1e396d7929526cd5221cb8af06349528c8bedced1a0
    CRC32: 90fa1539

## Credits

- ASM Hacking: NaOH
- Graphics: MiniMacro
- Design: TwistC
- Beta Testing: TwistC, Smedis2
- Hardware Testing: TwistC
