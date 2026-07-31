.psp

.relativeinclude on

NEUTRAL_CAM equ 0x089F1CB0
CAM_YAW     equ 0x09F4E3A0
HOOK_ADD    equ 0x088E7394
PATCH_ADD   equ 0x088E7370
INPUT_HOOK  equ 0x088A4A08

HOR_PWR     equ 3

.createfile "../bin/hd.bin", 0
.include "main.asm"
.close
