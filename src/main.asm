.word 1 ;  Main Block
.word @main_block_end - @main_block
.ascii "FRCM"
@main_block:

.func handle_input
    addiu   sp, sp, -0x10
    sw      ra, 0x0(sp)
    swc1    f0, 0x4(sp)
    swc1    f1, 0x8(sp)
    swc1    f2, 0xC(sp)
    
    bal     @@get_offset
    nop
@@get_offset:
    addiu   ra, ra, CURRENT_VALUE - @@get_offset

;  vertical control

    lbu     at, 0x17 + 0x10(sp)
    addiu   at, at, -0x80
    seh     at, at
    mtc1    at, f0
    cvt.s.w f0, f0

    ;  Apply Sensibility
    lwc1    f1, 0xC(ra)
    mul.s   f0, f0, f1
    
    lwc1    f1, 0x0(ra)
    add.s   f0, f1, f0

; clamp
    lwc1    f1, 0x10(ra) ; min
    c.lt.s  f0, f1
    bc1f    @@clamp_max
    nop
    b       @@clamp_done
    mov.s   f0, f1

@@clamp_max:
    lwc1    f1, 0x14(ra) ; max
    c.lt.s  f1, f0
    bc1f    @@clamp_done
    nop
    mov.s   f0, f1

@@clamp_done:

    swc1    f0, 0x0(ra)

;  horizontal control
    lbu     at, 0x16 + 0x10(sp)
    addiu   at, at, -0x80
    sub     at, zero, at
    
    lw      v0, 0x18(ra)
    mult    v0, at
    mflo    at

    lh      v0, CAM_YAW
    addu    v0, v0, at
    li      at, CAM_YAW
    sh      v0, 0x0(at)
    
    lw      ra, 0x0(sp)
    lwc1    f0, 0x4(sp)
    lwc1    f1, 0x8(sp)
    lwc1    f2, 0xC(sp)
    addiu   sp, sp, 0x10
    
    j       INPUT_HOOK + 8
    lbu     v0, 0x14(sp)
.endfunc

.func update_values
    addiu   sp, sp, -0x14
    sw      ra, 0x0(sp)
    swc1    f0, 0x4(sp)
    swc1    f1, 0x8(sp)
    swc1    f2, 0xC(sp)
    sw      a0, 0x10(sp)

    bal     @@get_offset
    nop
@@get_offset:
    addiu   at, ra, CURRENT_VALUE - @@get_offset

    lwc1    f0, 0x0(at)
    lwc1    f2, 0x4(at)
    lwc1    f1, 0x8(at)

    li      at, NEUTRAL_CAM
    swc1    f0, 0x0(at)

    ; if f0 < 3: f0 += f0
    c.lt.s  f0, f1
    bc1f    @@normal
    abs.s   f0, f0
    add.s   f0, f0
@@normal:
    div.s   f0, f0, f1
    sub.s   f0, f2, f0
    swc1    f0, 0x4(at)

    lw      ra, 0x0(sp)
    lwc1    f0, 0x4(sp)
    lwc1    f1, 0x8(sp)
    lwc1    f2, 0xC(sp)
    lw      a0, 0x10(sp)
    jr      a0
    addiu   sp, sp, 0x14
.endfunc

CURRENT_VALUE:
.float 185
.float 520 ;  Base Distance/FOV
.float 3 ;  Distance Scale
.float 0.3 ;  Sens
.float -160 ;  Min
.float 560 ;  Max
.word 8

@main_block_end:

.word 2 ;  Hook Block
.word HOOK_ADD
.halfword update_values - @main_block
.byte 8
.byte 1

.word 2 ;  Hook Block
.word INPUT_HOOK
.halfword handle_input - @main_block
.byte 8
.byte 0

.word 0 ;  Patch Block
.word PATCH_ADD
.word 4
    li      a1, 3
