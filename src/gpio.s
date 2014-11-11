@ Distributed under the terms of the GNU General Public License v2
.globl GPIO_ADDR
.globl GPIO_NB_PINS
.globl GPIO_NB_FUNCS
.globl GPIO_BLOCK_SIZE
.globl GPIO_PINS_PER_BLOCK
.globl GetGpioAddress
.globl SetGpioFunction
.globl SetGpio

.equiv GPIO_ADDR,       0x20200000
.equiv GPIO_NB_PINS,    54
.equiv GPIO_NB_FUNCS,   8
.equiv GPIO_BLOCK_SIZE, 4
.equiv GPIO_PINS_PER_BLOCK, 10

@
@ Load the GPIO Address in memory.
@ => r0: GPIO Address
@ == r[1..3]
GetGpioAddress:
  ldr r0, =GPIO_ADDR
  mov pc, lr

@
@ Apply a GPIO function to a pin.
@ ~> r0: The previous content of the block
@ ~> r1: The pin function at the right offset in the block (content of the block)
@ ~> r2: The address of the block containing the given pin function.
@ == r3
SetGpioFunction:
  pinNum  .req r0 @ <- GPIO pin [0, GPIO_NB_PINS[
  pinFunc .req r1 @ <- Function [0, GPIO_NB_FUNCS[

  @ Check pre-conditions and break if not satisfied.
  cmp   pinNum, #[GPIO_NB_PINS-1]
  cmpls pinNum, #[GPIO_NB_FUNCS-1]
  movhi pc, lr @ <Return

  ldr r2, =GPIO_ADDR
  funcPinAddr .req r2

  @ Calculate the function pin address (which block of 4 bytes?) in funcPinAddr
  @ and which set of 3 bits in pinNum.
  funcCalcLoop$:
    cmp   pinNum, #[GPIO_PINS_PER_BLOCK-1]
    subhi pinNum, #GPIO_PINS_PER_BLOCK
    addhi funcPinAddr, #GPIO_BLOCK_SIZE
  bhi funcCalcLoop$

  @ Multiply pinNum by 3 to get the offset of the given set of 3 bits.
  add pinNum, pinNum, lsl #1
  .unreq pinNum
  pinOffset .req r0

  @ Set the pin function
  lsl pinFunc, pinOffset
  .unreq pinOffset
  blockValue .req r0
  ldr blockValue, [funcPinAddr]
  orr pinFunc, blockValue
  .unreq blockValue
  str pinFunc, [funcPinAddr]
  .unreq pinFunc
  .unreq funcPinAddr

  mov pc, lr @ <Return

@ Turn on/off a GPIO pin.
@ r0: GPIO pin [0, GPIO_NB_PINS-1[
@ r1: Turn off? (0) or turn on? (any other value)
SetGpio:
  pinNum .req r0
  pinVal .req r1

  cmp   pinNum, #[GPIO_NB_PINS-1]
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

