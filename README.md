# 8080daa

The instruction of a 8080 that seems hardest to emulate correctly is the DAA
(Decimal Adjust) instruction that converts a value in the A register to a
two-digit BCD value.

This program does an exhaustive test of all 1024 combinations of the input
value plus Carry (CY) and HalfCarry/AuxiliaryCarry (AC) and prints the input
and resulting values.

Results currently are pending.


## Making a com file for CP/M

```
asmx -C 8080 -b -e -l daa.lst -o daa.bin -- daa.asm
dd if=daa.bin of=daa.com bs=1 skip=256 status=none
```

The software uses the CP/M BDOS Conout (B=2 CALL 5) to send characters to
the console.

If the OS in the machine is not CP/M the easist way of modifying this would
probably be to patch in some code for the console output at location 0005h.

My 8080 emulator simply accepts any OUT intruction as something that should
be sent to the terminal. So I can simple patch in `D3 00 C9` there. This
corresponds to OUT 0 and a RET. 

```
printf '\xD3\x00\xC9' | dd of=daa.bin bs=1 seek=5 count=3 conv=notrunc status=none
```


## Tools

The assembler used is "asmx multi-assembler version 2.0.0" by Bruce Tomlin.


 