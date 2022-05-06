; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s  -loop-vectorize -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7-avx -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

@c = common global [2048 x i32] zeroinitializer, align 16
@b = common global [2048 x i32] zeroinitializer, align 16
@d = common global [2048 x i32] zeroinitializer, align 16
@a = common global [2048 x i32] zeroinitializer, align 16

; The program below gathers and scatters data. We better not vectorize it.
define void @cost_model_1() nounwind uwtable noinline ssp {
; CHECK-LABEL: @cost_model_1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; CHECK-NEXT:    [[TMP0:%.*]] = shl nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2048 x i32], [2048 x i32]* @c, i64 0, i64 [[TMP0]]
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[IDXPROM1:%.*]] = sext i32 [[TMP1]] to i64
; CHECK-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds [2048 x i32], [2048 x i32]* @b, i64 0, i64 [[IDXPROM1]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX2]], align 4
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds [2048 x i32], [2048 x i32]* @d, i64 0, i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32* [[ARRAYIDX4]], align 4
; CHECK-NEXT:    [[IDXPROM5:%.*]] = sext i32 [[TMP3]] to i64
; CHECK-NEXT:    [[ARRAYIDX6:%.*]] = getelementptr inbounds [2048 x i32], [2048 x i32]* @a, i64 0, i64 [[IDXPROM5]]
; CHECK-NEXT:    store i32 [[TMP2]], i32* [[ARRAYIDX6]], align 4
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], 256
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END:%.*]], label [[FOR_BODY]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %0 = shl nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds [2048 x i32], [2048 x i32]* @c, i64 0, i64 %0
  %1 = load i32, i32* %arrayidx, align 8
  %idxprom1 = sext i32 %1 to i64
  %arrayidx2 = getelementptr inbounds [2048 x i32], [2048 x i32]* @b, i64 0, i64 %idxprom1
  %2 = load i32, i32* %arrayidx2, align 4
  %arrayidx4 = getelementptr inbounds [2048 x i32], [2048 x i32]* @d, i64 0, i64 %indvars.iv
  %3 = load i32, i32* %arrayidx4, align 4
  %idxprom5 = sext i32 %3 to i64
  %arrayidx6 = getelementptr inbounds [2048 x i32], [2048 x i32]* @a, i64 0, i64 %idxprom5
  store i32 %2, i32* %arrayidx6, align 4
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 256
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body
  ret void
}

; This function uses a stride that is generally too big to benefit from vectorization without
; really good support for a gather load. But if we don't vectorize the pointer induction,
; then we don't need to extract the pointers out of vector of pointers,
; and the vectorization becomes profitable.

define float @PR27826(float* nocapture readonly %a, float* nocapture readonly %b, i32 %n) {
; CHECK-LABEL: @PR27826(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       preheader:
; CHECK-NEXT:    [[T0:%.*]] = sext i32 [[N]] to i64
; CHECK-NEXT:    [[TMP0:%.*]] = add nsw i64 [[T0]], -1
; CHECK-NEXT:    [[TMP1:%.*]] = lshr i64 [[TMP0]], 5
; CHECK-NEXT:    [[TMP2:%.*]] = add nuw nsw i64 [[TMP1]], 1
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i64 [[TMP2]], 16
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_MOD_VF:%.*]] = urem i64 [[TMP2]], 16
; CHECK-NEXT:    [[N_VEC:%.*]] = sub i64 [[TMP2]], [[N_MOD_VF]]
; CHECK-NEXT:    [[IND_END:%.*]] = mul i64 [[N_VEC]], 32
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP119:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI1:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP120:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI2:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP121:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[VEC_PHI3:%.*]] = phi <4 x float> [ zeroinitializer, [[VECTOR_PH]] ], [ [[TMP122:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[OFFSET_IDX:%.*]] = mul i64 [[INDEX]], 32
; CHECK-NEXT:    [[TMP3:%.*]] = add i64 [[OFFSET_IDX]], 0
; CHECK-NEXT:    [[TMP4:%.*]] = add i64 [[OFFSET_IDX]], 32
; CHECK-NEXT:    [[TMP5:%.*]] = add i64 [[OFFSET_IDX]], 64
; CHECK-NEXT:    [[TMP6:%.*]] = add i64 [[OFFSET_IDX]], 96
; CHECK-NEXT:    [[TMP7:%.*]] = add i64 [[OFFSET_IDX]], 128
; CHECK-NEXT:    [[TMP8:%.*]] = add i64 [[OFFSET_IDX]], 160
; CHECK-NEXT:    [[TMP9:%.*]] = add i64 [[OFFSET_IDX]], 192
; CHECK-NEXT:    [[TMP10:%.*]] = add i64 [[OFFSET_IDX]], 224
; CHECK-NEXT:    [[TMP11:%.*]] = add i64 [[OFFSET_IDX]], 256
; CHECK-NEXT:    [[TMP12:%.*]] = add i64 [[OFFSET_IDX]], 288
; CHECK-NEXT:    [[TMP13:%.*]] = add i64 [[OFFSET_IDX]], 320
; CHECK-NEXT:    [[TMP14:%.*]] = add i64 [[OFFSET_IDX]], 352
; CHECK-NEXT:    [[TMP15:%.*]] = add i64 [[OFFSET_IDX]], 384
; CHECK-NEXT:    [[TMP16:%.*]] = add i64 [[OFFSET_IDX]], 416
; CHECK-NEXT:    [[TMP17:%.*]] = add i64 [[OFFSET_IDX]], 448
; CHECK-NEXT:    [[TMP18:%.*]] = add i64 [[OFFSET_IDX]], 480
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr inbounds float, float* [[A:%.*]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP20:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP21:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP5]]
; CHECK-NEXT:    [[TMP22:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP6]]
; CHECK-NEXT:    [[TMP23:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP7]]
; CHECK-NEXT:    [[TMP24:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP8]]
; CHECK-NEXT:    [[TMP25:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP26:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP10]]
; CHECK-NEXT:    [[TMP27:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP11]]
; CHECK-NEXT:    [[TMP28:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP12]]
; CHECK-NEXT:    [[TMP29:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP13]]
; CHECK-NEXT:    [[TMP30:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP14]]
; CHECK-NEXT:    [[TMP31:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP15]]
; CHECK-NEXT:    [[TMP32:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP16]]
; CHECK-NEXT:    [[TMP33:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP17]]
; CHECK-NEXT:    [[TMP34:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[TMP18]]
; CHECK-NEXT:    [[TMP35:%.*]] = load float, float* [[TMP19]], align 4
; CHECK-NEXT:    [[TMP36:%.*]] = load float, float* [[TMP20]], align 4
; CHECK-NEXT:    [[TMP37:%.*]] = load float, float* [[TMP21]], align 4
; CHECK-NEXT:    [[TMP38:%.*]] = load float, float* [[TMP22]], align 4
; CHECK-NEXT:    [[TMP39:%.*]] = insertelement <4 x float> poison, float [[TMP35]], i32 0
; CHECK-NEXT:    [[TMP40:%.*]] = insertelement <4 x float> [[TMP39]], float [[TMP36]], i32 1
; CHECK-NEXT:    [[TMP41:%.*]] = insertelement <4 x float> [[TMP40]], float [[TMP37]], i32 2
; CHECK-NEXT:    [[TMP42:%.*]] = insertelement <4 x float> [[TMP41]], float [[TMP38]], i32 3
; CHECK-NEXT:    [[TMP43:%.*]] = load float, float* [[TMP23]], align 4
; CHECK-NEXT:    [[TMP44:%.*]] = load float, float* [[TMP24]], align 4
; CHECK-NEXT:    [[TMP45:%.*]] = load float, float* [[TMP25]], align 4
; CHECK-NEXT:    [[TMP46:%.*]] = load float, float* [[TMP26]], align 4
; CHECK-NEXT:    [[TMP47:%.*]] = insertelement <4 x float> poison, float [[TMP43]], i32 0
; CHECK-NEXT:    [[TMP48:%.*]] = insertelement <4 x float> [[TMP47]], float [[TMP44]], i32 1
; CHECK-NEXT:    [[TMP49:%.*]] = insertelement <4 x float> [[TMP48]], float [[TMP45]], i32 2
; CHECK-NEXT:    [[TMP50:%.*]] = insertelement <4 x float> [[TMP49]], float [[TMP46]], i32 3
; CHECK-NEXT:    [[TMP51:%.*]] = load float, float* [[TMP27]], align 4
; CHECK-NEXT:    [[TMP52:%.*]] = load float, float* [[TMP28]], align 4
; CHECK-NEXT:    [[TMP53:%.*]] = load float, float* [[TMP29]], align 4
; CHECK-NEXT:    [[TMP54:%.*]] = load float, float* [[TMP30]], align 4
; CHECK-NEXT:    [[TMP55:%.*]] = insertelement <4 x float> poison, float [[TMP51]], i32 0
; CHECK-NEXT:    [[TMP56:%.*]] = insertelement <4 x float> [[TMP55]], float [[TMP52]], i32 1
; CHECK-NEXT:    [[TMP57:%.*]] = insertelement <4 x float> [[TMP56]], float [[TMP53]], i32 2
; CHECK-NEXT:    [[TMP58:%.*]] = insertelement <4 x float> [[TMP57]], float [[TMP54]], i32 3
; CHECK-NEXT:    [[TMP59:%.*]] = load float, float* [[TMP31]], align 4
; CHECK-NEXT:    [[TMP60:%.*]] = load float, float* [[TMP32]], align 4
; CHECK-NEXT:    [[TMP61:%.*]] = load float, float* [[TMP33]], align 4
; CHECK-NEXT:    [[TMP62:%.*]] = load float, float* [[TMP34]], align 4
; CHECK-NEXT:    [[TMP63:%.*]] = insertelement <4 x float> poison, float [[TMP59]], i32 0
; CHECK-NEXT:    [[TMP64:%.*]] = insertelement <4 x float> [[TMP63]], float [[TMP60]], i32 1
; CHECK-NEXT:    [[TMP65:%.*]] = insertelement <4 x float> [[TMP64]], float [[TMP61]], i32 2
; CHECK-NEXT:    [[TMP66:%.*]] = insertelement <4 x float> [[TMP65]], float [[TMP62]], i32 3
; CHECK-NEXT:    [[TMP67:%.*]] = getelementptr inbounds float, float* [[B:%.*]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP68:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP4]]
; CHECK-NEXT:    [[TMP69:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP5]]
; CHECK-NEXT:    [[TMP70:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP6]]
; CHECK-NEXT:    [[TMP71:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP7]]
; CHECK-NEXT:    [[TMP72:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP8]]
; CHECK-NEXT:    [[TMP73:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP9]]
; CHECK-NEXT:    [[TMP74:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP10]]
; CHECK-NEXT:    [[TMP75:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP11]]
; CHECK-NEXT:    [[TMP76:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP12]]
; CHECK-NEXT:    [[TMP77:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP13]]
; CHECK-NEXT:    [[TMP78:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP14]]
; CHECK-NEXT:    [[TMP79:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP15]]
; CHECK-NEXT:    [[TMP80:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP16]]
; CHECK-NEXT:    [[TMP81:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP17]]
; CHECK-NEXT:    [[TMP82:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[TMP18]]
; CHECK-NEXT:    [[TMP83:%.*]] = load float, float* [[TMP67]], align 4
; CHECK-NEXT:    [[TMP84:%.*]] = load float, float* [[TMP68]], align 4
; CHECK-NEXT:    [[TMP85:%.*]] = load float, float* [[TMP69]], align 4
; CHECK-NEXT:    [[TMP86:%.*]] = load float, float* [[TMP70]], align 4
; CHECK-NEXT:    [[TMP87:%.*]] = insertelement <4 x float> poison, float [[TMP83]], i32 0
; CHECK-NEXT:    [[TMP88:%.*]] = insertelement <4 x float> [[TMP87]], float [[TMP84]], i32 1
; CHECK-NEXT:    [[TMP89:%.*]] = insertelement <4 x float> [[TMP88]], float [[TMP85]], i32 2
; CHECK-NEXT:    [[TMP90:%.*]] = insertelement <4 x float> [[TMP89]], float [[TMP86]], i32 3
; CHECK-NEXT:    [[TMP91:%.*]] = load float, float* [[TMP71]], align 4
; CHECK-NEXT:    [[TMP92:%.*]] = load float, float* [[TMP72]], align 4
; CHECK-NEXT:    [[TMP93:%.*]] = load float, float* [[TMP73]], align 4
; CHECK-NEXT:    [[TMP94:%.*]] = load float, float* [[TMP74]], align 4
; CHECK-NEXT:    [[TMP95:%.*]] = insertelement <4 x float> poison, float [[TMP91]], i32 0
; CHECK-NEXT:    [[TMP96:%.*]] = insertelement <4 x float> [[TMP95]], float [[TMP92]], i32 1
; CHECK-NEXT:    [[TMP97:%.*]] = insertelement <4 x float> [[TMP96]], float [[TMP93]], i32 2
; CHECK-NEXT:    [[TMP98:%.*]] = insertelement <4 x float> [[TMP97]], float [[TMP94]], i32 3
; CHECK-NEXT:    [[TMP99:%.*]] = load float, float* [[TMP75]], align 4
; CHECK-NEXT:    [[TMP100:%.*]] = load float, float* [[TMP76]], align 4
; CHECK-NEXT:    [[TMP101:%.*]] = load float, float* [[TMP77]], align 4
; CHECK-NEXT:    [[TMP102:%.*]] = load float, float* [[TMP78]], align 4
; CHECK-NEXT:    [[TMP103:%.*]] = insertelement <4 x float> poison, float [[TMP99]], i32 0
; CHECK-NEXT:    [[TMP104:%.*]] = insertelement <4 x float> [[TMP103]], float [[TMP100]], i32 1
; CHECK-NEXT:    [[TMP105:%.*]] = insertelement <4 x float> [[TMP104]], float [[TMP101]], i32 2
; CHECK-NEXT:    [[TMP106:%.*]] = insertelement <4 x float> [[TMP105]], float [[TMP102]], i32 3
; CHECK-NEXT:    [[TMP107:%.*]] = load float, float* [[TMP79]], align 4
; CHECK-NEXT:    [[TMP108:%.*]] = load float, float* [[TMP80]], align 4
; CHECK-NEXT:    [[TMP109:%.*]] = load float, float* [[TMP81]], align 4
; CHECK-NEXT:    [[TMP110:%.*]] = load float, float* [[TMP82]], align 4
; CHECK-NEXT:    [[TMP111:%.*]] = insertelement <4 x float> poison, float [[TMP107]], i32 0
; CHECK-NEXT:    [[TMP112:%.*]] = insertelement <4 x float> [[TMP111]], float [[TMP108]], i32 1
; CHECK-NEXT:    [[TMP113:%.*]] = insertelement <4 x float> [[TMP112]], float [[TMP109]], i32 2
; CHECK-NEXT:    [[TMP114:%.*]] = insertelement <4 x float> [[TMP113]], float [[TMP110]], i32 3
; CHECK-NEXT:    [[TMP115:%.*]] = fadd fast <4 x float> [[TMP42]], [[VEC_PHI]]
; CHECK-NEXT:    [[TMP116:%.*]] = fadd fast <4 x float> [[TMP50]], [[VEC_PHI1]]
; CHECK-NEXT:    [[TMP117:%.*]] = fadd fast <4 x float> [[TMP58]], [[VEC_PHI2]]
; CHECK-NEXT:    [[TMP118:%.*]] = fadd fast <4 x float> [[TMP66]], [[VEC_PHI3]]
; CHECK-NEXT:    [[TMP119]] = fadd fast <4 x float> [[TMP115]], [[TMP90]]
; CHECK-NEXT:    [[TMP120]] = fadd fast <4 x float> [[TMP116]], [[TMP98]]
; CHECK-NEXT:    [[TMP121]] = fadd fast <4 x float> [[TMP117]], [[TMP106]]
; CHECK-NEXT:    [[TMP122]] = fadd fast <4 x float> [[TMP118]], [[TMP114]]
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i64 [[INDEX]], 16
; CHECK-NEXT:    [[TMP123:%.*]] = icmp eq i64 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP123]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[BIN_RDX:%.*]] = fadd fast <4 x float> [[TMP120]], [[TMP119]]
; CHECK-NEXT:    [[BIN_RDX4:%.*]] = fadd fast <4 x float> [[TMP121]], [[BIN_RDX]]
; CHECK-NEXT:    [[BIN_RDX5:%.*]] = fadd fast <4 x float> [[TMP122]], [[BIN_RDX4]]
; CHECK-NEXT:    [[TMP124:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float -0.000000e+00, <4 x float> [[BIN_RDX5]])
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i64 [[TMP2]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[LOOPEXIT:%.*]], label [[SCALAR_PH]]
; CHECK:       scalar.ph:
; CHECK-NEXT:    [[BC_RESUME_VAL:%.*]] = phi i64 [ [[IND_END]], [[MIDDLE_BLOCK]] ], [ 0, [[PREHEADER]] ]
; CHECK-NEXT:    [[BC_MERGE_RDX:%.*]] = phi float [ 0.000000e+00, [[PREHEADER]] ], [ [[TMP124]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR:%.*]]
; CHECK:       for:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[BC_RESUME_VAL]], [[SCALAR_PH]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR]] ]
; CHECK-NEXT:    [[S_02:%.*]] = phi float [ [[BC_MERGE_RDX]], [[SCALAR_PH]] ], [ [[ADD4:%.*]], [[FOR]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[A]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[T1:%.*]] = load float, float* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds float, float* [[B]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    [[T2:%.*]] = load float, float* [[ARRAYIDX3]], align 4
; CHECK-NEXT:    [[ADD:%.*]] = fadd fast float [[T1]], [[S_02]]
; CHECK-NEXT:    [[ADD4]] = fadd fast float [[ADD]], [[T2]]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 32
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i64 [[INDVARS_IV_NEXT]], [[T0]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[FOR]], label [[LOOPEXIT]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       loopexit:
; CHECK-NEXT:    [[ADD4_LCSSA:%.*]] = phi float [ [[ADD4]], [[FOR]] ], [ [[TMP124]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    [[S_0_LCSSA:%.*]] = phi float [ 0.000000e+00, [[ENTRY:%.*]] ], [ [[ADD4_LCSSA]], [[LOOPEXIT]] ]
; CHECK-NEXT:    ret float [[S_0_LCSSA]]
;
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %preheader, label %for.end

preheader:
  %t0 = sext i32 %n to i64
  br label %for

for:
  %indvars.iv = phi i64 [ 0, %preheader ], [ %indvars.iv.next, %for ]
  %s.02 = phi float [ 0.0, %preheader ], [ %add4, %for ]
  %arrayidx = getelementptr inbounds float, float* %a, i64 %indvars.iv
  %t1 = load float, float* %arrayidx, align 4
  %arrayidx3 = getelementptr inbounds float, float* %b, i64 %indvars.iv
  %t2 = load float, float* %arrayidx3, align 4
  %add = fadd fast float %t1, %s.02
  %add4 = fadd fast float %add, %t2
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 32
  %cmp1 = icmp slt i64 %indvars.iv.next, %t0
  br i1 %cmp1, label %for, label %loopexit

loopexit:
  %add4.lcssa = phi float [ %add4, %for ]
  br label %for.end

for.end:
  %s.0.lcssa = phi float [ 0.0, %entry ], [ %add4.lcssa, %loopexit ]
  ret float %s.0.lcssa
}
