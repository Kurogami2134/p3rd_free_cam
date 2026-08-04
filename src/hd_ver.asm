.psp

.relativeinclude on

NEUTRAL_CAM equ 0x089F1CB0
CAM_YAW     equ 0x09F4E3A0
HOOK_ADD    equ 0x088E7394
PATCH_ADD   equ 0x088E7370
INPUT_HOOK  equ 0x088A4A08

PATCH2      equ 0x088E77E8
PATCH3      equ 0x088E6EA0
PATCH4      equ 0x088E6E64

.createfile "../bin/hd.bin", 0
.include "main.asm"

;  disable normal stick functionality

.word 0
.word PATCH2
.word 4
.word 0

.word 0
.word PATCH4
.word 4
.word 0

.word 0
.word PATCH4
.word 4
.word 0

.close
