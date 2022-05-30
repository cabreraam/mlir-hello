// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py UTC_ARGS: --check-globals
// RUN: %clang_cc1 -std=c++11 -triple x86_64-unknown-linux-gnu \
// RUN:   --offload-new-driver -emit-llvm -o - -x cuda  %s | FileCheck \
// RUN:   --check-prefix=HOST %s

#include "Inputs/cuda.h"

//.
// HOST: @x = internal global i32 undef, align 4
// HOST: @.omp_offloading.entry_name = internal unnamed_addr constant [8 x i8] c"_Z3foov\00"
// HOST: @.omp_offloading.entry._Z3foov = weak constant %struct.__tgt_offload_entry { ptr @_Z18__device_stub__foov, ptr @.omp_offloading.entry_name, i64 0, i32 0, i32 0 }, section "cuda_offloading_entries", align 1
// HOST: @.omp_offloading.entry_name.1 = internal unnamed_addr constant [8 x i8] c"_Z3barv\00"
// HOST: @.omp_offloading.entry._Z3barv = weak constant %struct.__tgt_offload_entry { ptr @_Z18__device_stub__barv, ptr @.omp_offloading.entry_name.1, i64 0, i32 0, i32 0 }, section "cuda_offloading_entries", align 1
// HOST: @.omp_offloading.entry_name.2 = internal unnamed_addr constant [2 x i8] c"x\00"
// HOST: @.omp_offloading.entry.x = weak constant %struct.__tgt_offload_entry { ptr @x, ptr @.omp_offloading.entry_name.2, i64 4, i32 0, i32 0 }, section "cuda_offloading_entries", align 1
//.
// HOST-LABEL: @_Z18__device_stub__foov(
// HOST-NEXT:  entry:
// HOST-NEXT:    [[TMP0:%.*]] = call i32 @cudaLaunch(ptr @_Z18__device_stub__foov)
// HOST-NEXT:    br label [[SETUP_END:%.*]]
// HOST:       setup.end:
// HOST-NEXT:    ret void
//
__global__ void foo() {}
// HOST-LABEL: @_Z18__device_stub__barv(
// HOST-NEXT:  entry:
// HOST-NEXT:    [[TMP0:%.*]] = call i32 @cudaLaunch(ptr @_Z18__device_stub__barv)
// HOST-NEXT:    br label [[SETUP_END:%.*]]
// HOST:       setup.end:
// HOST-NEXT:    ret void
//
__global__ void bar() {}
__device__ int x = 1;