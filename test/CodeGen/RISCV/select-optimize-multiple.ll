; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+d -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I
; RUN: llc -mtriple=riscv64 -mattr=+d -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I

; Selects of wide values are split into two selects, which can easily cause
; unnecessary control flow. Here we check some cases where we can currently
; emit a sequence of selects with shared control flow.

define i64 @cmovcc64(i32 signext %a, i64 %b, i64 %c) nounwind {
; RV32I-LABEL: cmovcc64:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    addi a5, zero, 123
; RV32I-NEXT:    beq a0, a5, .LBB0_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    mv a2, a4
; RV32I-NEXT:    mv a1, a3
; RV32I-NEXT:  .LBB0_2: # %entry
; RV32I-NEXT:    mv a0, a1
; RV32I-NEXT:    mv a1, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovcc64:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    addi a3, zero, 123
; RV64I-NEXT:    beq a0, a3, .LBB0_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    mv a1, a2
; RV64I-NEXT:  .LBB0_2: # %entry
; RV64I-NEXT:    mv a0, a1
; RV64I-NEXT:    ret
entry:
  %cmp = icmp eq i32 %a, 123
  %cond = select i1 %cmp, i64 %b, i64 %c
  ret i64 %cond
}

define i128 @cmovcc128(i64 signext %a, i128 %b, i128 %c) nounwind {
; RV32I-LABEL: cmovcc128:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    xori a1, a1, 123
; RV32I-NEXT:    or a1, a1, a2
; RV32I-NEXT:    beqz a1, .LBB1_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    addi a1, a4, 4
; RV32I-NEXT:    addi a2, a4, 8
; RV32I-NEXT:    addi a5, a4, 12
; RV32I-NEXT:    mv a3, a4
; RV32I-NEXT:    j .LBB1_3
; RV32I-NEXT:  .LBB1_2:
; RV32I-NEXT:    addi a1, a3, 4
; RV32I-NEXT:    addi a2, a3, 8
; RV32I-NEXT:    addi a5, a3, 12
; RV32I-NEXT:  .LBB1_3: # %entry
; RV32I-NEXT:    lw a4, 0(a5)
; RV32I-NEXT:    sw a4, 12(a0)
; RV32I-NEXT:    lw a2, 0(a2)
; RV32I-NEXT:    sw a2, 8(a0)
; RV32I-NEXT:    lw a1, 0(a1)
; RV32I-NEXT:    sw a1, 4(a0)
; RV32I-NEXT:    lw a1, 0(a3)
; RV32I-NEXT:    sw a1, 0(a0)
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovcc128:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    addi a5, zero, 123
; RV64I-NEXT:    beq a0, a5, .LBB1_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    mv a2, a4
; RV64I-NEXT:    mv a1, a3
; RV64I-NEXT:  .LBB1_2: # %entry
; RV64I-NEXT:    mv a0, a1
; RV64I-NEXT:    mv a1, a2
; RV64I-NEXT:    ret
entry:
  %cmp = icmp eq i64 %a, 123
  %cond = select i1 %cmp, i128 %b, i128 %c
  ret i128 %cond
}

define i64 @cmov64(i1 %a, i64 %b, i64 %c) nounwind {
; RV32I-LABEL: cmov64:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    bnez a0, .LBB2_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    mv a2, a4
; RV32I-NEXT:    mv a1, a3
; RV32I-NEXT:  .LBB2_2: # %entry
; RV32I-NEXT:    mv a0, a1
; RV32I-NEXT:    mv a1, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmov64:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    bnez a0, .LBB2_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    mv a1, a2
; RV64I-NEXT:  .LBB2_2: # %entry
; RV64I-NEXT:    mv a0, a1
; RV64I-NEXT:    ret
entry:
  %cond = select i1 %a, i64 %b, i64 %c
  ret i64 %cond
}

define i128 @cmov128(i1 %a, i128 %b, i128 %c) nounwind {
; RV32I-LABEL: cmov128:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    andi a1, a1, 1
; RV32I-NEXT:    bnez a1, .LBB3_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    addi a1, a3, 4
; RV32I-NEXT:    addi a4, a3, 8
; RV32I-NEXT:    addi a5, a3, 12
; RV32I-NEXT:    mv a2, a3
; RV32I-NEXT:    j .LBB3_3
; RV32I-NEXT:  .LBB3_2:
; RV32I-NEXT:    addi a1, a2, 4
; RV32I-NEXT:    addi a4, a2, 8
; RV32I-NEXT:    addi a5, a2, 12
; RV32I-NEXT:  .LBB3_3: # %entry
; RV32I-NEXT:    lw a3, 0(a5)
; RV32I-NEXT:    sw a3, 12(a0)
; RV32I-NEXT:    lw a3, 0(a4)
; RV32I-NEXT:    sw a3, 8(a0)
; RV32I-NEXT:    lw a1, 0(a1)
; RV32I-NEXT:    sw a1, 4(a0)
; RV32I-NEXT:    lw a1, 0(a2)
; RV32I-NEXT:    sw a1, 0(a0)
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmov128:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    bnez a0, .LBB3_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    mv a2, a4
; RV64I-NEXT:    mv a1, a3
; RV64I-NEXT:  .LBB3_2: # %entry
; RV64I-NEXT:    mv a0, a1
; RV64I-NEXT:    mv a1, a2
; RV64I-NEXT:    ret
entry:
  %cond = select i1 %a, i128 %b, i128 %c
  ret i128 %cond
}

define float @cmovfloat(i1 %a, float %b, float %c, float %d, float %e) nounwind {
; RV32I-LABEL: cmovfloat:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    bnez a0, .LBB4_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    fmv.w.x ft0, a4
; RV32I-NEXT:    fmv.w.x ft1, a2
; RV32I-NEXT:    j .LBB4_3
; RV32I-NEXT:  .LBB4_2:
; RV32I-NEXT:    fmv.w.x ft0, a3
; RV32I-NEXT:    fmv.w.x ft1, a1
; RV32I-NEXT:  .LBB4_3: # %entry
; RV32I-NEXT:    fadd.s ft0, ft1, ft0
; RV32I-NEXT:    fmv.x.w a0, ft0
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovfloat:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    bnez a0, .LBB4_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    fmv.w.x ft0, a4
; RV64I-NEXT:    fmv.w.x ft1, a2
; RV64I-NEXT:    j .LBB4_3
; RV64I-NEXT:  .LBB4_2:
; RV64I-NEXT:    fmv.w.x ft0, a3
; RV64I-NEXT:    fmv.w.x ft1, a1
; RV64I-NEXT:  .LBB4_3: # %entry
; RV64I-NEXT:    fadd.s ft0, ft1, ft0
; RV64I-NEXT:    fmv.x.w a0, ft0
; RV64I-NEXT:    ret
entry:
  %cond1 = select i1 %a, float %b, float %c
  %cond2 = select i1 %a, float %d, float %e
  %ret = fadd float %cond1, %cond2
  ret float %ret
}

define double @cmovdouble(i1 %a, double %b, double %c) nounwind {
; RV32I-LABEL: cmovdouble:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw a3, 8(sp)
; RV32I-NEXT:    sw a4, 12(sp)
; RV32I-NEXT:    fld ft0, 8(sp)
; RV32I-NEXT:    sw a1, 8(sp)
; RV32I-NEXT:    sw a2, 12(sp)
; RV32I-NEXT:    fld ft1, 8(sp)
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    bnez a0, .LBB5_2
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    fmv.d ft1, ft0
; RV32I-NEXT:  .LBB5_2: # %entry
; RV32I-NEXT:    fsd ft1, 8(sp)
; RV32I-NEXT:    lw a0, 8(sp)
; RV32I-NEXT:    lw a1, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovdouble:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    bnez a0, .LBB5_2
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    fmv.d.x ft0, a2
; RV64I-NEXT:    fmv.x.d a0, ft0
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB5_2:
; RV64I-NEXT:    fmv.d.x ft0, a1
; RV64I-NEXT:    fmv.x.d a0, ft0
; RV64I-NEXT:    ret
entry:
  %cond = select i1 %a, double %b, double %c
  ret double %cond
}

; Check that selects with dependencies on previous ones aren't incorrectly
; optimized.

define i32 @cmovccdep(i32 signext %a, i32 %b, i32 %c, i32 %d) nounwind {
; RV32I-LABEL: cmovccdep:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    addi a4, zero, 123
; RV32I-NEXT:    bne a0, a4, .LBB6_3
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    mv a2, a1
; RV32I-NEXT:    bne a0, a4, .LBB6_4
; RV32I-NEXT:  .LBB6_2: # %entry
; RV32I-NEXT:    add a0, a1, a2
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB6_3: # %entry
; RV32I-NEXT:    mv a1, a2
; RV32I-NEXT:    mv a2, a1
; RV32I-NEXT:    beq a0, a4, .LBB6_2
; RV32I-NEXT:  .LBB6_4: # %entry
; RV32I-NEXT:    mv a2, a3
; RV32I-NEXT:    add a0, a1, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovccdep:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    addi a4, zero, 123
; RV64I-NEXT:    bne a0, a4, .LBB6_3
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    mv a2, a1
; RV64I-NEXT:    bne a0, a4, .LBB6_4
; RV64I-NEXT:  .LBB6_2: # %entry
; RV64I-NEXT:    add a0, a1, a2
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB6_3: # %entry
; RV64I-NEXT:    mv a1, a2
; RV64I-NEXT:    mv a2, a1
; RV64I-NEXT:    beq a0, a4, .LBB6_2
; RV64I-NEXT:  .LBB6_4: # %entry
; RV64I-NEXT:    mv a2, a3
; RV64I-NEXT:    add a0, a1, a2
; RV64I-NEXT:    ret
entry:
  %cmp = icmp eq i32 %a, 123
  %cond1 = select i1 %cmp, i32 %b, i32 %c
  %cond2 = select i1 %cmp, i32 %cond1, i32 %d
  %ret = add i32 %cond1, %cond2
  ret i32 %ret
}

; Check that selects with different conditions aren't incorrectly optimized.

define i32 @cmovdiffcc(i1 %a, i1 %b, i32 %c, i32 %d, i32 %e, i32 %f) nounwind {
; RV32I-LABEL: cmovdiffcc:
; RV32I:       # %bb.0: # %entry
; RV32I-NEXT:    andi a1, a1, 1
; RV32I-NEXT:    beqz a1, .LBB7_3
; RV32I-NEXT:  # %bb.1: # %entry
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    beqz a0, .LBB7_4
; RV32I-NEXT:  .LBB7_2: # %entry
; RV32I-NEXT:    add a0, a2, a4
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB7_3: # %entry
; RV32I-NEXT:    mv a4, a5
; RV32I-NEXT:    andi a0, a0, 1
; RV32I-NEXT:    bnez a0, .LBB7_2
; RV32I-NEXT:  .LBB7_4: # %entry
; RV32I-NEXT:    mv a2, a3
; RV32I-NEXT:    add a0, a2, a4
; RV32I-NEXT:    ret
;
; RV64I-LABEL: cmovdiffcc:
; RV64I:       # %bb.0: # %entry
; RV64I-NEXT:    andi a1, a1, 1
; RV64I-NEXT:    beqz a1, .LBB7_3
; RV64I-NEXT:  # %bb.1: # %entry
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    beqz a0, .LBB7_4
; RV64I-NEXT:  .LBB7_2: # %entry
; RV64I-NEXT:    add a0, a2, a4
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB7_3: # %entry
; RV64I-NEXT:    mv a4, a5
; RV64I-NEXT:    andi a0, a0, 1
; RV64I-NEXT:    bnez a0, .LBB7_2
; RV64I-NEXT:  .LBB7_4: # %entry
; RV64I-NEXT:    mv a2, a3
; RV64I-NEXT:    add a0, a2, a4
; RV64I-NEXT:    ret
entry:
  %cond1 = select i1 %a, i32 %c, i32 %d
  %cond2 = select i1 %b, i32 %e, i32 %f
  %ret = add i32 %cond1, %cond2
  ret i32 %ret
}
