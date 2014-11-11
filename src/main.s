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

  @ Wait a few time
  mov r2,#0x3F0000
  wait1$:
    sub r2,#1
    cmp r2,#0
    bne wait1$

  @ Turn on the pin to turn off the ACT LED
  pinNum .req r0
  pinVal .req r1
  mov pinNum, #16
  mov pinVal, #1
  bl SetGpio
  .unreq pinNum
  .unreq pinVal

  @ Wait a few time
  mov r2,#0x3F0000
  wait2$:
    sub r2,#1
    cmp r2,#0
    bne wait2$

  b   mainloop$

