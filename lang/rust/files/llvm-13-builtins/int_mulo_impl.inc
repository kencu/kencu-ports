/*
 * Source: https://github.com/llvm/llvm-project/blob/llvmorg-13.0.0/compiler-rt/lib/builtins/int_mulo_impl.inc
 *
 * The goal of this code is only allow to run binary
 * which was linked against macOS 10.8 on macOS 10.7 and below.
 *
 * Such binaries are used to boostrap rust on stage0 only.
 */

//===-- int_mulo_impl.inc - Implement __mulo[sdt]i4 ---------------*- C -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Helper used by __mulosi4, __mulodi4 and __muloti4.
//
//===----------------------------------------------------------------------===//

#include "int_lib.h"

// Returns: a * b

// Effects: sets *overflow to 1  if a * b overflows

static __inline fixint_t __muloXi4(fixint_t a, fixint_t b, int *overflow) {
  const int N = (int)(sizeof(fixint_t) * CHAR_BIT);
  const fixint_t MIN = (fixint_t)1 << (N - 1);
  const fixint_t MAX = ~MIN;
  *overflow = 0;
  fixint_t result = a * b;
  if (a == MIN) {
    if (b != 0 && b != 1)
      *overflow = 1;
    return result;
  }
  if (b == MIN) {
    if (a != 0 && a != 1)
      *overflow = 1;
    return result;
  }
  fixint_t sa = a >> (N - 1);
  fixint_t abs_a = (a ^ sa) - sa;
  fixint_t sb = b >> (N - 1);
  fixint_t abs_b = (b ^ sb) - sb;
  if (abs_a < 2 || abs_b < 2)
    return result;
  if (sa == sb) {
    if (abs_a > MAX / abs_b)
      *overflow = 1;
  } else {
    if (abs_a > MIN / -abs_b)
      *overflow = 1;
  }
  return result;
}
