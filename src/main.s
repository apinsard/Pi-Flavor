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

@ Main loop
mainloop$:

  @ Turn off the pin to turn on the ACT LED
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #0
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  @ Wait ~1/20 second
  nbUsec .req r0
  mov nbUsec, #1
  lsl nbUsec, #16
  bl Wait
  .unreq nbUsec

  @ Turn on the pin to turn off the ACT LED
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #1
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  @ Wait ~1/2 second
  nbUsec .req r0
  mov nbUsec, #1
  lsl nbUsec, #19
  bl Wait
  .unreq nbUsec

  b   mainloop$

