# 8080daa

The instruction of a 8080 that seems hardest to emulate correctly is the DAA
(Decimal Adjust) instruction that converts a value in the A register to a
two-digit BCD value.

This program does an exhaustive test of all 1024 combinations of the input
value plus Carry (CY) and HalfCarry/AuxiliaryCarry (AC) and prints the input
and resulting values.

## Making a com file for cp/m

asmx -C 8080 -b -e -l daa.lst -o daa.tmp -- daa.asm
dd if=daa.tmp of=daa.com bs=1 skip=256 status=none
rm daa.tmp

## Tools

The assembler used is `asmx multi-assembler version 2.0.0` by Bruce Tomlin.


 