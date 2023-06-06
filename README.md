# 6-Button Controller Support for Alien Soldier

*By NaOH, with contributions from TwistC and MiniMacro*

## Functionality

This hack adds support for 6-button controllers, while retaining legacy support for 3-button controllers. Depending on whether a 3-button or 6-button controller is inserted into the console, a different control scheme will be used.

There are two different versions of the patch; `alien-soldier-6-button-hold.ips` is recommended if you are using a controller with trigger buttons, whereas `alien-soldier-6-button-toggle.ips` is recommended if you are using a standard 6-button controller.

- You can now dash by pressing Z. (Down+C no longer dashes in 6-button mode.)
- You can now perform the "Counter Force" parry manoeuvre by pressing Y. (Double-tap B no longer parries in 6-button mode.)
- You can now toggle shoot modes by pressing X or Mode at any time. In the "hold" variation, instead of pressing X, you must hold X to temporarily toggle shoot modes (but the Mode button still toggles shoot modes on press). (Down+A no longer swaps shoot mode in 6-button mode.)
- The new controls are displayed in the "control test" screen, assuming a 6-button controller is inserted.
- On the password input screen, pressing up now increments the number and down decrements.
- Bypasses internal checksum verification. However, the internal region lock is not bypassed (see below).

## Patching Instructions

Only the Japanese ROM is supported. Please verify the ROM's hash before patching, which is listed below.

You can apply the patch using FLIPS or any other IPS patcher.

If you wish to play the Japanese ROM on a US console, you'll need to bypass the region lock with a Game Genie. You can find a suitable Game Genie code here: https://etherealgames.com/sega-genesis/a/alien-soldier/game-genie-codes/

## Source Code

The assembly and build scripts for this hack are available on GitHub. Please take a look: https://github.com/nstbayless/alien-soldier-6-button

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
