# Distributed under the terms of the GNU General Public License v2
.section .init
.globl _start

_start:

# Put the GPIO address in a registry
ldr r0,=0x20200000

# Enable output to the 16th GPIO pin
# => 2^18 stored at 0x20200004
# The 16th GPIO pin is represented by the 6th set of 3 bits (#18=3×6) of the
# second set of 4 bytes (#4=4×1).
# Finally, we want to put #1 in the selected set of 3 bits to enable output
mov r1,#1
lsl r1,#18
str r1,[r0,#4]

# Turn off (#40) the 16th pin (#16) of the GPIO to turn on the ACT LED.
mov r1,#1
lsl r1,#16
str r1,[r0,#40]

# End
loop$:
b   loop$

