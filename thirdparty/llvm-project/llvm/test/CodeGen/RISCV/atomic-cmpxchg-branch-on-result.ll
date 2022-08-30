; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+a -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefixes=CHECK,RV32IA %s
; RUN: llc -mtriple=riscv64 -mattr=+a -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefixes=CHECK,RV64IA %s

; Test cmpxchg followed by a branch on the cmpxchg success value to see if the
; branch is folded into the cmpxchg expansion.

define void @cmpxchg_and_branch1(i32* %ptr, i32 signext %cmp, i32 signext %val) nounwind {
; CHECK-LABEL: cmpxchg_and_branch1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:  .LBB0_1: # %do_cmpxchg
; CHECK-NEXT:    # =>This Loop Header: Depth=1
; CHECK-NEXT:    # Child Loop BB0_3 Depth 2
; CHECK-NEXT:  .LBB0_3: # %do_cmpxchg
; CHECK-NEXT:    # Parent Loop BB0_1 Depth=1
; CHECK-NEXT:    # => This Inner Loop Header: Depth=2
; CHECK-NEXT:    lr.w.aqrl a3, (a0)
; CHECK-NEXT:    bne a3, a1, .LBB0_1
; CHECK-NEXT:  # %bb.4: # %do_cmpxchg
; CHECK-NEXT:    # in Loop: Header=BB0_3 Depth=2
; CHECK-NEXT:    sc.w.aqrl a4, a2, (a0)
; CHECK-NEXT:    bnez a4, .LBB0_3
; CHECK-NEXT:  # %bb.5: # %do_cmpxchg
; CHECK-NEXT:  # %bb.2: # %exit
; CHECK-NEXT:    ret
entry:
  br label %do_cmpxchg
do_cmpxchg:
  %0 = cmpxchg i32* %ptr, i32 %cmp, i32 %val seq_cst seq_cst
  %1 = extractvalue { i32, i1 } %0, 1
  br i1 %1, label %exit, label %do_cmpxchg
exit:
  ret void
}

define void @cmpxchg_and_branch2(i32* %ptr, i32 signext %cmp, i32 signext %val) nounwind {
; CHECK-LABEL: cmpxchg_and_branch2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:  .LBB1_1: # %do_cmpxchg
; CHECK-NEXT:    # =>This Loop Header: Depth=1
; CHECK-NEXT:    # Child Loop BB1_3 Depth 2
; CHECK-NEXT:  .LBB1_3: # %do_cmpxchg
; CHECK-NEXT:    # Parent Loop BB1_1 Depth=1
; CHECK-NEXT:    # => This Inner Loop Header: Depth=2
; CHECK-NEXT:    lr.w.aqrl a3, (a0)
; CHECK-NEXT:    bne a3, a1, .LBB1_5
; CHECK-NEXT:  # %bb.4: # %do_cmpxchg
; CHECK-NEXT:    # in Loop: Header=BB1_3 Depth=2
; CHECK-NEXT:    sc.w.aqrl a4, a2, (a0)
; CHECK-NEXT:    bnez a4, .LBB1_3
; CHECK-NEXT:  .LBB1_5: # %do_cmpxchg
; CHECK-NEXT:    # in Loop: Header=BB1_1 Depth=1
; CHECK-NEXT:    beq a3, a1, .LBB1_1
; CHECK-NEXT:  # %bb.2: # %exit
; CHECK-NEXT:    ret
entry:
  br label %do_cmpxchg
do_cmpxchg:
  %0 = cmpxchg i32* %ptr, i32 %cmp, i32 %val seq_cst seq_cst
  %1 = extractvalue { i32, i1 } %0, 1
  br i1 %1, label %do_cmpxchg, label %exit
exit:
  ret void
}

define void @cmpxchg_masked_and_branch1(i8* %ptr, i8 signext %cmp, i8 signext %val) nounwind {
; RV32IA-LABEL: cmpxchg_masked_and_branch1:
; RV32IA:       # %bb.0: # %entry
; RV32IA-NEXT:    andi a3, a0, -4
; RV32IA-NEXT:    slli a4, a0, 3
; RV32IA-NEXT:    li a0, 255
; RV32IA-NEXT:    sll a0, a0, a4
; RV32IA-NEXT:    andi a1, a1, 255
; RV32IA-NEXT:    sll a1, a1, a4
; RV32IA-NEXT:    andi a2, a2, 255
; RV32IA-NEXT:    sll a2, a2, a4
; RV32IA-NEXT:  .LBB2_1: # %do_cmpxchg
; RV32IA-NEXT:    # =>This Loop Header: Depth=1
; RV32IA-NEXT:    # Child Loop BB2_3 Depth 2
; RV32IA-NEXT:  .LBB2_3: # %do_cmpxchg
; RV32IA-NEXT:    # Parent Loop BB2_1 Depth=1
; RV32IA-NEXT:    # => This Inner Loop Header: Depth=2
; RV32IA-NEXT:    lr.w.aqrl a4, (a3)
; RV32IA-NEXT:    and a5, a4, a0
; RV32IA-NEXT:    bne a5, a1, .LBB2_1
; RV32IA-NEXT:  # %bb.4: # %do_cmpxchg
; RV32IA-NEXT:    # in Loop: Header=BB2_3 Depth=2
; RV32IA-NEXT:    xor a5, a4, a2
; RV32IA-NEXT:    and a5, a5, a0
; RV32IA-NEXT:    xor a5, a4, a5
; RV32IA-NEXT:    sc.w.aqrl a5, a5, (a3)
; RV32IA-NEXT:    bnez a5, .LBB2_3
; RV32IA-NEXT:  # %bb.5: # %do_cmpxchg
; RV32IA-NEXT:  # %bb.2: # %exit
; RV32IA-NEXT:    ret
;
; RV64IA-LABEL: cmpxchg_masked_and_branch1:
; RV64IA:       # %bb.0: # %entry
; RV64IA-NEXT:    andi a3, a0, -4
; RV64IA-NEXT:    slliw a4, a0, 3
; RV64IA-NEXT:    li a0, 255
; RV64IA-NEXT:    sllw a0, a0, a4
; RV64IA-NEXT:    andi a1, a1, 255
; RV64IA-NEXT:    sllw a1, a1, a4
; RV64IA-NEXT:    andi a2, a2, 255
; RV64IA-NEXT:    sllw a2, a2, a4
; RV64IA-NEXT:  .LBB2_1: # %do_cmpxchg
; RV64IA-NEXT:    # =>This Loop Header: Depth=1
; RV64IA-NEXT:    # Child Loop BB2_3 Depth 2
; RV64IA-NEXT:  .LBB2_3: # %do_cmpxchg
; RV64IA-NEXT:    # Parent Loop BB2_1 Depth=1
; RV64IA-NEXT:    # => This Inner Loop Header: Depth=2
; RV64IA-NEXT:    lr.w.aqrl a4, (a3)
; RV64IA-NEXT:    and a5, a4, a0
; RV64IA-NEXT:    bne a5, a1, .LBB2_1
; RV64IA-NEXT:  # %bb.4: # %do_cmpxchg
; RV64IA-NEXT:    # in Loop: Header=BB2_3 Depth=2
; RV64IA-NEXT:    xor a5, a4, a2
; RV64IA-NEXT:    and a5, a5, a0
; RV64IA-NEXT:    xor a5, a4, a5
; RV64IA-NEXT:    sc.w.aqrl a5, a5, (a3)
; RV64IA-NEXT:    bnez a5, .LBB2_3
; RV64IA-NEXT:  # %bb.5: # %do_cmpxchg
; RV64IA-NEXT:  # %bb.2: # %exit
; RV64IA-NEXT:    ret
entry:
  br label %do_cmpxchg
do_cmpxchg:
  %0 = cmpxchg i8* %ptr, i8 %cmp, i8 %val seq_cst seq_cst
  %1 = extractvalue { i8, i1 } %0, 1
  br i1 %1, label %exit, label %do_cmpxchg
exit:
  ret void
}

define void @cmpxchg_masked_and_branch2(i8* %ptr, i8 signext %cmp, i8 signext %val) nounwind {
; RV32IA-LABEL: cmpxchg_masked_and_branch2:
; RV32IA:       # %bb.0: # %entry
; RV32IA-NEXT:    andi a3, a0, -4
; RV32IA-NEXT:    slli a4, a0, 3
; RV32IA-NEXT:    li a0, 255
; RV32IA-NEXT:    sll a0, a0, a4
; RV32IA-NEXT:    andi a1, a1, 255
; RV32IA-NEXT:    sll a1, a1, a4
; RV32IA-NEXT:    andi a2, a2, 255
; RV32IA-NEXT:    sll a2, a2, a4
; RV32IA-NEXT:  .LBB3_1: # %do_cmpxchg
; RV32IA-NEXT:    # =>This Loop Header: Depth=1
; RV32IA-NEXT:    # Child Loop BB3_3 Depth 2
; RV32IA-NEXT:  .LBB3_3: # %do_cmpxchg
; RV32IA-NEXT:    # Parent Loop BB3_1 Depth=1
; RV32IA-NEXT:    # => This Inner Loop Header: Depth=2
; RV32IA-NEXT:    lr.w.aqrl a4, (a3)
; RV32IA-NEXT:    and a5, a4, a0
; RV32IA-NEXT:    bne a5, a1, .LBB3_5
; RV32IA-NEXT:  # %bb.4: # %do_cmpxchg
; RV32IA-NEXT:    # in Loop: Header=BB3_3 Depth=2
; RV32IA-NEXT:    xor a5, a4, a2
; RV32IA-NEXT:    and a5, a5, a0
; RV32IA-NEXT:    xor a5, a4, a5
; RV32IA-NEXT:    sc.w.aqrl a5, a5, (a3)
; RV32IA-NEXT:    bnez a5, .LBB3_3
; RV32IA-NEXT:  .LBB3_5: # %do_cmpxchg
; RV32IA-NEXT:    # in Loop: Header=BB3_1 Depth=1
; RV32IA-NEXT:    and a4, a4, a0
; RV32IA-NEXT:    beq a1, a4, .LBB3_1
; RV32IA-NEXT:  # %bb.2: # %exit
; RV32IA-NEXT:    ret
;
; RV64IA-LABEL: cmpxchg_masked_and_branch2:
; RV64IA:       # %bb.0: # %entry
; RV64IA-NEXT:    andi a3, a0, -4
; RV64IA-NEXT:    slliw a4, a0, 3
; RV64IA-NEXT:    li a0, 255
; RV64IA-NEXT:    sllw a0, a0, a4
; RV64IA-NEXT:    andi a1, a1, 255
; RV64IA-NEXT:    sllw a1, a1, a4
; RV64IA-NEXT:    andi a2, a2, 255
; RV64IA-NEXT:    sllw a2, a2, a4
; RV64IA-NEXT:  .LBB3_1: # %do_cmpxchg
; RV64IA-NEXT:    # =>This Loop Header: Depth=1
; RV64IA-NEXT:    # Child Loop BB3_3 Depth 2
; RV64IA-NEXT:  .LBB3_3: # %do_cmpxchg
; RV64IA-NEXT:    # Parent Loop BB3_1 Depth=1
; RV64IA-NEXT:    # => This Inner Loop Header: Depth=2
; RV64IA-NEXT:    lr.w.aqrl a4, (a3)
; RV64IA-NEXT:    and a5, a4, a0
; RV64IA-NEXT:    bne a5, a1, .LBB3_5
; RV64IA-NEXT:  # %bb.4: # %do_cmpxchg
; RV64IA-NEXT:    # in Loop: Header=BB3_3 Depth=2
; RV64IA-NEXT:    xor a5, a4, a2
; RV64IA-NEXT:    and a5, a5, a0
; RV64IA-NEXT:    xor a5, a4, a5
; RV64IA-NEXT:    sc.w.aqrl a5, a5, (a3)
; RV64IA-NEXT:    bnez a5, .LBB3_3
; RV64IA-NEXT:  .LBB3_5: # %do_cmpxchg
; RV64IA-NEXT:    # in Loop: Header=BB3_1 Depth=1
; RV64IA-NEXT:    and a4, a4, a0
; RV64IA-NEXT:    beq a1, a4, .LBB3_1
; RV64IA-NEXT:  # %bb.2: # %exit
; RV64IA-NEXT:    ret
entry:
  br label %do_cmpxchg
do_cmpxchg:
  %0 = cmpxchg i8* %ptr, i8 %cmp, i8 %val seq_cst seq_cst
  %1 = extractvalue { i8, i1 } %0, 1
  br i1 %1, label %do_cmpxchg, label %exit
exit:
  ret void
}

define void @cmpxchg_and_irrelevant_branch(i32* %ptr, i32 signext %cmp, i32 signext %val, i1 zeroext %bool) nounwind {
; CHECK-LABEL: cmpxchg_and_irrelevant_branch:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:  .LBB4_1: # %do_cmpxchg
; CHECK-NEXT:    # =>This Loop Header: Depth=1
; CHECK-NEXT:    # Child Loop BB4_3 Depth 2
; CHECK-NEXT:  .LBB4_3: # %do_cmpxchg
; CHECK-NEXT:    # Parent Loop BB4_1 Depth=1
; CHECK-NEXT:    # => This Inner Loop Header: Depth=2
; CHECK-NEXT:    lr.w.aqrl a4, (a0)
; CHECK-NEXT:    bne a4, a1, .LBB4_5
; CHECK-NEXT:  # %bb.4: # %do_cmpxchg
; CHECK-NEXT:    # in Loop: Header=BB4_3 Depth=2
; CHECK-NEXT:    sc.w.aqrl a5, a2, (a0)
; CHECK-NEXT:    bnez a5, .LBB4_3
; CHECK-NEXT:  .LBB4_5: # %do_cmpxchg
; CHECK-NEXT:    # in Loop: Header=BB4_1 Depth=1
; CHECK-NEXT:    beqz a3, .LBB4_1
; CHECK-NEXT:  # %bb.2: # %exit
; CHECK-NEXT:    ret
entry:
  br label %do_cmpxchg
do_cmpxchg:
  %0 = cmpxchg i32* %ptr, i32 %cmp, i32 %val seq_cst seq_cst
  %1 = extractvalue { i32, i1 } %0, 1
  br i1 %bool, label %exit, label %do_cmpxchg
exit:
  ret void
}