.psp

.relativeinclude on

NEUTRAL_CAM equ 0x089EBCA0
CAM_YAW     equ 0x09B47960
HOOK_ADD    equ 0x088E5970
PATCH_ADD   equ 0x088E594C
INPUT_HOOK  equ 0x088A339C

HOR_PWR     equ 4

.createfile "../bin/psp.bin", 0
.include "main.asm"
.close
