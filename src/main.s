@ Distributed under the terms of the GNU General Public License v2
.section .init
.globl _start

_start:
  b main

.section .text

main:
  mov sp,#0x8000

  pinNum .req r0
  pinFunc .req r1

  mov pinNum, #16 @ ACT LED
  mov pinFunc, #1 @ Enable output
  bl SetGpioFunction
  .unreq pinNum
  .unreq pinFunc

  @ Load the pattern
  ptrn .req r4
  ldr ptrn, =pattern
  ldr ptrn, [ptrn]

  @ Pattern position cursor
  seq .req r5
  mov seq, #0

@ Main loop
mainloop$:

  @ Turn on or off the ACT LED according to the pattern
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #1
  lsl pinVal, seq
  and pinVal, ptrn
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  @ Wait ~1/2 second
  nbUsec .req r0
  mov nbUsec, #1
  lsl nbUsec, #19
  bl Wait
  .unreq nbUsec

  @ Increment the cursor
  add seq, #1
  cmp seq, #31
  movhi seq, #0

  b   mainloop$

.section .data
.align 2
pattern:
  .int 0b11111111101010100010001000101010
