; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -mtriple=amdgcn-amd-amdhsa -passes=separate-const-offset-from-gep \
; RUN: -S < %s | FileCheck %s


; Test a simple case of xor to or disjoint transformation
define half @test_basic_transformation(ptr %ptr, i64 %input) {
; CHECK-LABEL: define half @test_basic_transformation(
; CHECK-SAME: ptr [[PTR:%.*]], i64 [[INPUT:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[BASE:%.*]] = and i64 [[INPUT]], -8192
; CHECK-NEXT:    [[ADDR1:%.*]] = xor i64 [[BASE]], 32
; CHECK-NEXT:    [[ADDR2_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 2048
; CHECK-NEXT:    [[ADDR3_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 4096
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR1]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR2_OR_DISJOINT]]
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR3_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL1:%.*]] = load half, ptr [[GEP1]], align 2
; CHECK-NEXT:    [[VAL2:%.*]] = load half, ptr [[GEP2]], align 2
; CHECK-NEXT:    [[VAL3:%.*]] = load half, ptr [[GEP3]], align 2
; CHECK-NEXT:    [[VAL1_F:%.*]] = fpext half [[VAL1]] to float
; CHECK-NEXT:    [[VAL2_F:%.*]] = fpext half [[VAL2]] to float
; CHECK-NEXT:    [[VAL3_F:%.*]] = fpext half [[VAL3]] to float
; CHECK-NEXT:    [[SUM1_F:%.*]] = fadd float [[VAL1_F]], [[VAL2_F]]
; CHECK-NEXT:    [[SUM_TOTAL_F:%.*]] = fadd float [[SUM1_F]], [[VAL3_F]]
; CHECK-NEXT:    [[RESULT_H:%.*]] = fptrunc float [[SUM_TOTAL_F]] to half
; CHECK-NEXT:    ret half [[RESULT_H]]
;
entry:
  %base = and i64 %input, -8192    ; Clear low bits
  %addr1 = xor i64 %base, 32
  %addr2 = xor i64 %base, 2080
  %addr3 = xor i64 %base, 4128
  %gep1 = getelementptr i8, ptr %ptr, i64 %addr1
  %gep2 = getelementptr i8, ptr %ptr, i64 %addr2
  %gep3 = getelementptr i8, ptr %ptr, i64 %addr3
  %val1 = load half, ptr %gep1
  %val2 = load half, ptr %gep2
  %val3 = load half, ptr %gep3
  %val1.f = fpext half %val1 to float
  %val2.f = fpext half %val2 to float
  %val3.f = fpext half %val3 to float
  %sum1.f = fadd float %val1.f, %val2.f
  %sum_total.f = fadd float %sum1.f, %val3.f
  %result.h = fptrunc float %sum_total.f to half
  ret half %result.h
}


; Test the decreasing order of offset xor to or disjoint transformation
define half @test_descending_offset_transformation(ptr %ptr, i64 %input) {
; CHECK-LABEL: define half @test_descending_offset_transformation(
; CHECK-SAME: ptr [[PTR:%.*]], i64 [[INPUT:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[BASE:%.*]] = and i64 [[INPUT]], -8192
; CHECK-NEXT:    [[ADDR3_DOM_CLONE:%.*]] = xor i64 [[BASE]], 32
; CHECK-NEXT:    [[ADDR1_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR3_DOM_CLONE]], 4096
; CHECK-NEXT:    [[ADDR2_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR3_DOM_CLONE]], 2048
; CHECK-NEXT:    [[ADDR3_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR3_DOM_CLONE]], 0
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR1_OR_DISJOINT]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR2_OR_DISJOINT]]
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR3_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL1:%.*]] = load half, ptr [[GEP1]], align 2
; CHECK-NEXT:    [[VAL2:%.*]] = load half, ptr [[GEP2]], align 2
; CHECK-NEXT:    [[VAL3:%.*]] = load half, ptr [[GEP3]], align 2
; CHECK-NEXT:    [[VAL1_F:%.*]] = fpext half [[VAL1]] to float
; CHECK-NEXT:    [[VAL2_F:%.*]] = fpext half [[VAL2]] to float
; CHECK-NEXT:    [[VAL3_F:%.*]] = fpext half [[VAL3]] to float
; CHECK-NEXT:    [[SUM1_F:%.*]] = fadd float [[VAL1_F]], [[VAL2_F]]
; CHECK-NEXT:    [[SUM_TOTAL_F:%.*]] = fadd float [[SUM1_F]], [[VAL3_F]]
; CHECK-NEXT:    [[RESULT_H:%.*]] = fptrunc float [[SUM_TOTAL_F]] to half
; CHECK-NEXT:    ret half [[RESULT_H]]
;
entry:
  %base = and i64 %input, -8192    ; Clear low bits
  %addr1 = xor i64 %base, 4128
  %addr2 = xor i64 %base, 2080
  %addr3 = xor i64 %base, 32
  %gep1 = getelementptr i8, ptr %ptr, i64 %addr1
  %gep2 = getelementptr i8, ptr %ptr, i64 %addr2
  %gep3 = getelementptr i8, ptr %ptr, i64 %addr3
  %val1 = load half, ptr %gep1
  %val2 = load half, ptr %gep2
  %val3 = load half, ptr %gep3
  %val1.f = fpext half %val1 to float
  %val2.f = fpext half %val2 to float
  %val3.f = fpext half %val3 to float
  %sum1.f = fadd float %val1.f, %val2.f
  %sum_total.f = fadd float %sum1.f, %val3.f
  %result.h = fptrunc float %sum_total.f to half
  ret half %result.h
}


; Test that %addr2 is not transformed to or disjoint.
define half @test_no_transfomation(ptr %ptr, i64 %input) {
; CHECK-LABEL: define half @test_no_transfomation(
; CHECK-SAME: ptr [[PTR:%.*]], i64 [[INPUT:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[BASE:%.*]] = and i64 [[INPUT]], -8192
; CHECK-NEXT:    [[ADDR1:%.*]] = xor i64 [[BASE]], 32
; CHECK-NEXT:    [[ADDR2:%.*]] = xor i64 [[BASE]], 64
; CHECK-NEXT:    [[ADDR3_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 2048
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR1]]
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR2]]
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR3_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL1:%.*]] = load half, ptr [[GEP1]], align 2
; CHECK-NEXT:    [[VAL2:%.*]] = load half, ptr [[GEP2]], align 2
; CHECK-NEXT:    [[VAL3:%.*]] = load half, ptr [[GEP3]], align 2
; CHECK-NEXT:    [[VAL1_F:%.*]] = fpext half [[VAL1]] to float
; CHECK-NEXT:    [[VAL2_F:%.*]] = fpext half [[VAL2]] to float
; CHECK-NEXT:    [[VAL3_F:%.*]] = fpext half [[VAL3]] to float
; CHECK-NEXT:    [[SUM1_F:%.*]] = fadd float [[VAL1_F]], [[VAL2_F]]
; CHECK-NEXT:    [[SUM_TOTAL_F:%.*]] = fadd float [[SUM1_F]], [[VAL3_F]]
; CHECK-NEXT:    [[RESULT_H:%.*]] = fptrunc float [[SUM_TOTAL_F]] to half
; CHECK-NEXT:    ret half [[RESULT_H]]
;
entry:
  %base = and i64 %input, -8192    ; Clear low bits
  %addr1 = xor i64 %base, 32
  %addr2 = xor i64 %base, 64  ; Should not be transformed
  %addr3 = xor i64 %base, 2080
  %gep1 = getelementptr i8, ptr %ptr, i64 %addr1
  %gep2 = getelementptr i8, ptr %ptr, i64 %addr2
  %gep3 = getelementptr i8, ptr %ptr, i64 %addr3
  %val1 = load half, ptr %gep1
  %val2 = load half, ptr %gep2
  %val3 = load half, ptr %gep3
  %val1.f = fpext half %val1 to float
  %val2.f = fpext half %val2 to float
  %val3.f = fpext half %val3 to float
  %sum1.f = fadd float %val1.f, %val2.f
  %sum_total.f = fadd float %sum1.f, %val3.f
  %result.h = fptrunc float %sum_total.f to half
  ret half %result.h
}


; Test case with xor instructions in different basic blocks
define half @test_dom_tree(ptr %ptr, i64 %input, i1 %cond) {
; CHECK-LABEL: define half @test_dom_tree(
; CHECK-SAME: ptr [[PTR:%.*]], i64 [[INPUT:%.*]], i1 [[COND:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    [[BASE:%.*]] = and i64 [[INPUT]], -8192
; CHECK-NEXT:    [[ADDR1:%.*]] = xor i64 [[BASE]], 16
; CHECK-NEXT:    [[GEP1:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR1]]
; CHECK-NEXT:    [[VAL1:%.*]] = load half, ptr [[GEP1]], align 2
; CHECK-NEXT:    br i1 [[COND]], label %[[THEN:.*]], label %[[ELSE:.*]]
; CHECK:       [[THEN]]:
; CHECK-NEXT:    [[ADDR2_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 32
; CHECK-NEXT:    [[GEP2:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR2_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL2:%.*]] = load half, ptr [[GEP2]], align 2
; CHECK-NEXT:    br label %[[MERGE:.*]]
; CHECK:       [[ELSE]]:
; CHECK-NEXT:    [[ADDR3_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 96
; CHECK-NEXT:    [[GEP3:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR3_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL3:%.*]] = load half, ptr [[GEP3]], align 2
; CHECK-NEXT:    br label %[[MERGE]]
; CHECK:       [[MERGE]]:
; CHECK-NEXT:    [[VAL_FROM_BRANCH:%.*]] = phi half [ [[VAL2]], %[[THEN]] ], [ [[VAL3]], %[[ELSE]] ]
; CHECK-NEXT:    [[ADDR4_OR_DISJOINT:%.*]] = or disjoint i64 [[ADDR1]], 224
; CHECK-NEXT:    [[GEP4:%.*]] = getelementptr i8, ptr [[PTR]], i64 [[ADDR4_OR_DISJOINT]]
; CHECK-NEXT:    [[VAL4:%.*]] = load half, ptr [[GEP4]], align 2
; CHECK-NEXT:    [[VAL1_F:%.*]] = fpext half [[VAL1]] to float
; CHECK-NEXT:    [[VAL_FROM_BRANCH_F:%.*]] = fpext half [[VAL_FROM_BRANCH]] to float
; CHECK-NEXT:    [[VAL4_F:%.*]] = fpext half [[VAL4]] to float
; CHECK-NEXT:    [[SUM_INTERMEDIATE_F:%.*]] = fadd float [[VAL1_F]], [[VAL_FROM_BRANCH_F]]
; CHECK-NEXT:    [[FINAL_SUM_F:%.*]] = fadd float [[SUM_INTERMEDIATE_F]], [[VAL4_F]]
; CHECK-NEXT:    [[RESULT_H:%.*]] = fptrunc float [[FINAL_SUM_F]] to half
; CHECK-NEXT:    ret half [[RESULT_H]]
;
entry:
  %base = and i64 %input, -8192   ; Clear low bits
  %addr1 = xor i64 %base,16
  %gep1 = getelementptr i8, ptr %ptr, i64 %addr1
  %val1 = load half, ptr %gep1
  br i1 %cond, label %then, label %else

then:
  %addr2 = xor i64 %base, 48
  %gep2 = getelementptr i8, ptr %ptr, i64 %addr2
  %val2 = load half, ptr %gep2
  br label %merge

else:
  %addr3 = xor i64 %base, 112
  %gep3 = getelementptr i8, ptr %ptr, i64 %addr3
  %val3 = load half, ptr %gep3
  br label %merge

merge:
  %val_from_branch = phi half [ %val2, %then ], [ %val3, %else ]
  %addr4 = xor i64 %base, 240
  %gep4 = getelementptr i8, ptr %ptr, i64 %addr4
  %val4 = load half, ptr %gep4
  %val1.f = fpext half %val1 to float
  %val_from_branch.f = fpext half %val_from_branch to float
  %val4.f = fpext half %val4 to float
  %sum_intermediate.f = fadd float %val1.f, %val_from_branch.f
  %final_sum.f = fadd float %sum_intermediate.f, %val4.f
  %result.h = fptrunc float %final_sum.f to half
  ret half %result.h
}

