/* Distributed under the terms of the GNU General Public License v2 */

SECTIONS {
  /* Init section at 0x8000 according to the bootloader expectations. */
  .init 0x8000 : {
    *(.init)
  }

  /* Then comes the rest of the code */
  .text : {
    *(.text)
  }

  /DISCARD/ : {
    *(*)
  }
}

