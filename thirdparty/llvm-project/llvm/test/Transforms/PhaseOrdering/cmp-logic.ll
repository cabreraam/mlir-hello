; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes='default<O1>' -S < %s | FileCheck %s

define i32 @PR38781(i32 noundef %a, i32 noundef %b) {
; CHECK-LABEL: @PR38781(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[B:%.*]], [[A:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp sgt i32 [[TMP1]], -1
; CHECK-NEXT:    [[AND:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[AND]]
;
  %cmp = icmp sge i32 %a, 0
  %conv = zext i1 %cmp to i32
  %cmp1 = icmp sge i32 %b, 0
  %conv2 = zext i1 %cmp1 to i32
  %and = and i32 %conv, %conv2
  ret i32 %and
}

define i1 @PR54692_a(i8 noundef signext %c) #0 {
; CHECK-LABEL: @PR54692_a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP5:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[OR1:%.*]] = or i1 [[TMP0]], [[CMP5]]
; CHECK-NEXT:    ret i1 [[OR1]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  br i1 %cmp, label %land.rhs, label %land.end

land.rhs:
  %conv1 = sext i8 %c to i32
  %cmp2 = icmp sle i32 %conv1, 31
  br label %land.end

land.end:
  %0 = phi i1 [ false, %entry ], [ %cmp2, %land.rhs ]
  %conv3 = zext i1 %0 to i32
  %conv4 = sext i8 %c to i32
  %cmp5 = icmp eq i32 %conv4, 127
  %conv6 = zext i1 %cmp5 to i32
  %or = or i32 %conv3, %conv6
  %tobool = icmp ne i32 %or, 0
  ret i1 %tobool
}

define i1 @PR54692_b(i8 noundef signext %c) {
; CHECK-LABEL: @PR54692_b(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP6:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[OR2:%.*]] = or i1 [[TMP0]], [[CMP6]]
; CHECK-NEXT:    ret i1 [[OR2]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  %conv1 = zext i1 %cmp to i32
  %conv2 = sext i8 %c to i32
  %cmp3 = icmp sle i32 %conv2, 31
  %conv4 = zext i1 %cmp3 to i32
  %and = and i32 %conv1, %conv4
  %conv5 = sext i8 %c to i32
  %cmp6 = icmp eq i32 %conv5, 127
  %conv7 = zext i1 %cmp6 to i32
  %or = or i32 %and, %conv7
  %tobool = icmp ne i32 %or, 0
  ret i1 %tobool
}

define i1 @PR54692_c(i8 noundef signext %c) {
; CHECK-LABEL: @PR54692_c(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp ult i8 [[C:%.*]], 32
; CHECK-NEXT:    [[CMP6:%.*]] = icmp eq i8 [[C]], 127
; CHECK-NEXT:    [[T0:%.*]] = or i1 [[TMP0]], [[CMP6]]
; CHECK-NEXT:    ret i1 [[T0]]
;
entry:
  %conv = sext i8 %c to i32
  %cmp = icmp sge i32 %conv, 0
  %conv1 = zext i1 %cmp to i32
  %conv2 = sext i8 %c to i32
  %cmp3 = icmp sle i32 %conv2, 31
  %conv4 = zext i1 %cmp3 to i32
  %and = and i32 %conv1, %conv4
  %tobool = icmp ne i32 %and, 0
  br i1 %tobool, label %lor.end, label %lor.rhs

lor.rhs:
  %conv5 = sext i8 %c to i32
  %cmp6 = icmp eq i32 %conv5, 127
  br label %lor.end

lor.end:
  %t0 = phi i1 [ true, %entry ], [ %cmp6, %lor.rhs ]
  ret i1 %t0
}