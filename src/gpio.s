@ Distributed under the terms of the GNU General Public License v2
.globl GPIO_ADDR
.globl GPIO_NB_PINS
.globl GPIO_NB_FUNCS
.globl GPIO_BLOCK_SIZE
.globl GPIO_PINS_PER_BLOCK
.globl GPIO_PIN_TURN_ON
.globl GPIO_PIN_TURN_OFF
.globl GPIO_PIN_INPUT
.globl GetGpioAddress
.globl SetGpioFunction
.globl SetGpio

.equiv GPIO_ADDR        , 0x20200000
.equiv GPIO_NB_PINS     , 54
.equiv GPIO_NB_FUNCS    , 8
.equiv GPIO_BLOCK_SIZE  , 4
.equiv GPIO_PINS_PER_BLOCK, 10
.equiv GPIO_PIN_TURN_ON , 28
.equiv GPIO_PIN_TURN_OFF, 40
.equiv GPIO_PIN_INPUT   , 52

@
@ Load the GPIO Address in memory.
@ => r0: GPIO Address
@ == r[1..3]
GetGpioAddress:
  ldr r0, =GPIO_ADDR
  mov pc, lr @ < Return

@
@ Apply a GPIO function to a pin.
@ ~> r0: The offset of the 3 bits of the function pin in the block
@ ~> r1: The pin function at the right offset in the block (content of the block)
@ ~> r2: The address of the block containing the given pin function.
@ ~> r3: The previous content of the block
SetGpioFunction:
  pinNum  .req r0 @ <- GPIO pin [0, GPIO_NB_PINS[
  pinFunc .req r1 @ <- Function [0, GPIO_NB_FUNCS[

  @ Check pre-conditions and break if not satisfied.
  cmp   pinNum, #[GPIO_NB_PINS-1]
  cmpls pinNum, #[GPIO_NB_FUNCS-1]
  movhi pc, lr @ <Return

  funcPinAddr .req r2
  ldr funcPinAddr, =GPIO_ADDR

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

  @ Set the pin function at the right offset
  lsl pinFunc, pinOffset

  @ Create a mask to keep other pins unchanged
  blockMask .req r3
  mov blockMask, #[GPIO_NB_FUNCS-1]
  lsl blockMask, pinOffset
  .unreq pinOffset
  mvn blockMask, blockMask

  @ Load the current value of the block and reset the function of the wanted pin
  blockValue .req r0
  ldr blockValue, [funcPinAddr]
  and blockValue, blockMask 
  .unreq blockMask

  @ Merge new pin function
  orr pinFunc, blockValue
  .unreq blockValue
  str pinFunc, [funcPinAddr]
  .unreq pinFunc
  .unreq funcPinAddr

  mov pc, lr @ <Return

@
@ Turn on/off a GPIO pin.
@
SetGpio:
  pinNum .req r0 @ <- GPIO pin [0, GPIO_NB_PINS[
  pinVal .req r1 @ <- 0: Turn OFF ; Else: Turn ON

  @ Check pre-conditions and break if not satisfied.
  cmp   pinNum, #[GPIO_NB_PINS-1]
  movhi pc, lr @ <Return

  gpioPinAddr .req r2
  ldr gpioPinAddr, =GPIO_ADDR

  @ Divide the GPIO pin number by 32 to get in which of the two sets of 4 bytes
  @ it is (0 or 1). And then multiply by 4 to get the address.
  pinBank .req r3
  lsr pinBank, pinNum, #5
  add gpioPinAddr, pinBank, lsl #2
  .unreq pinBank

  @ The bit to set at the given address is the nth bit where n is the remainder
  @ of the previous division by 32.
  and pinNum, #31
  setBit .req r3
  mov setBit, #1
  lsl setBit, pinNum
  .unreq pinNum

  @ Turn ON or OFF within pinVal
  teq pinVal, #0
  .unreq pinVal
  streq setBit,[gpioPinAddr,#GPIO_PIN_TURN_OFF]
  strne setBit,[gpioPinAddr,#GPIO_PIN_TURN_ON]
  .unreq setBit
  .unreq gpioPinAddr

  mov pc, lr @ <Return

