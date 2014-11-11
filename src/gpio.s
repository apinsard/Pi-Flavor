@ Distributed under the terms of the GNU General Public License v2
.globl GetGpioAddress
.globl SetGpioFunction
.globl SetGpio

@ Load the GPIO Address
@ r0 <- GPIO Address
GetGpioAddress:
  ldr r0, =0x20200000
  mov pc, lr

@ Apply a GPIO function to a pin
@ r0: GPIO pin [0..53]
@ r1: Function to apply [0..7]
SetGpioFunction:
  cmp   r0, #53
  cmpls r1, #7
  movhi pc, lr @ Break if pre-cond not satisfied

  push {lr}
  mov  r2, r0
  bl   GetGpioAddress

  functionLoop$:
    cmp   r2, #9
    subhi r2, #10
    addhi r0, #4
    bhi   functionLoop$

  add r2, r2, lsl #1
  lsl r1, r2
  str r1, [r0]
  pop {pc}

@ Turn on/off a GPIO pin.
@ r0: GPIO pin [0..53]
@ r1: Turn off? (0) or turn on? (any other value)
SetGpio:
  pinNum .req r0
  pinVal .req r1

  cmp   pinNum, #53
  movhi pc, lr @ Break if pre-cond not satisfied
  
  push {lr}
  mov  r2, pinNum
  .unreq pinNum
  pinNum .req r2
  bl GetGpioAddress
  gpioAddr .req r0

  pinBank .req r3
  lsr pinBank, pinNum, #5
  lsl pinBank, #2
  add gpioAddr, pinBank
  .unreq pinBank

  and pinNum, #31
  setBit .req r3
  mov setBit, #1
  lsl setBit, pinNum
  .unreq pinNum

  teq pinVal, #0
  .unreq pinVal
  streq setBit,[gpioAddr,#40]
  strne setBit,[gpioAddr,#28]
  .unreq setBit
  .unreq gpioAddr
  pop {pc}

