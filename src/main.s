# Distributed under the terms of the GNU General Public License v2
.section .init
.globl _start

_start:

# Put the GPIO address in a registry
# TODO this one should rather be a constant defined thanks to the preprocessor.
# This would save up one actual instruction.
ldr r0,=0x20200000

# Enable output to the 16th GPIO pin
# => 2^18 stored at 0x20200004
# The 16th GPIO pin is represented by the 6th set of 3 bits (#18=3×6) of the
# second set of 4 bytes (#4=4×1).
# Finally, we want to put #1 in the selected set of 3 bits to enable output
mov r1,#1
lsl r1,#18
str r1,[r0,#4]

# Preselect the 16th pin (#16) of the GPIO to turn on/off the ACT LED.
#mov r1,#1  // These two lines can be factorised in `lsr r1,#2`
#lsl r1,#16 // since r1 currently contains 2^18
lsr r1,#2

# Main loop
main$:

# Turn off (#40) the pin to turn on the ACT LED
str r1,[r0,#40]

# Wait a few time
mov r2,#0x3F0000
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$

# Turn on (#28) the pin to turn off the ACT LED
str r1,[r0,#28]

# Wait a few time
mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$

b   main$

