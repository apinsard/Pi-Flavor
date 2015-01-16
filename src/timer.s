@ Distributed under the terms of the GNU General Public License v2
.globl TIMER_ADDR
.globl GetCounterValue
.globl Wait

.equiv TIMER_ADDR       , 0x20003000

@
@ Load the counter value in memory
@ => r0: 4 lowest bits
@ => r1: 4 highest bits
@ == r[2..3]
GetCounterValue:
  counterValLo .req r0
  counterValHi .req r1
  ldr r0, =TIMER_ADDR
  ldrd counterValLo, counterValHi, [r0,#4]
  mov pc, lr @ < Return

@
@ Wait for nbUsec microseconds
@ == r3
Wait:
  nbUsec .req r0 @ <- number of microseconds to wait [0, 2^32[

  push {lr}

  @ Retrieve the current value of the counter
  push {nbUsec}
  .unreq nbUsec
  bl GetCounterValue
  nbUsec .req r1
  pop {nbUsec}
  counterVal .req r0

  @ Set the gap to wait
  gapToWait .req r2
  add gapToWait, counterVal, nbUsec
  .unreq nbUsec

  @ And finally, wait
waitLoop$:
  bl GetCounterValue
  cmp counterVal, gapToWait
  bls waitLoop$

  pop {pc} @ < Return

