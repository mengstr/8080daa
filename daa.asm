        ORG 0100H           ; CP/M .COM programs start at address 0100H

;--------------------------------------------------------------------
; Start: Main program entry point.
; Initializes a counter variable ("count") and then loops through
; all 256 possible values. For each value, it tests DAA with four
; combinations of incoming CY and AC flags.
;--------------------------------------------------------------------
Start:
    mvi a,1ah
    daa

    ; Initialize the count variable to 0.
    MVI A, 00H          ; Set A = 0
    STA count           ; Store A into memory location "count"

Loop:
    ; For each value in "count", perform four tests:
    ; Test 1: CY=0, AC=0
    MVI C, 00H          ; Load immediate 0 into C (flags: CY=0, AC=0)
    CALL Process        ; Process DAA test with current flags

    ; Test 2: CY=0, AC=1
    MVI C, 01H          ; Load immediate 01H (flags: CY=0, AC=1)
    CALL Process

    ; Test 3: CY=1, AC=0
    MVI C, 10H          ; Load immediate 10H (flags: CY=1, AC=0)
    CALL Process

    ; Test 4: CY=1, AC=1
    MVI C, 11H          ; Load immediate 11H (flags: CY=1, AC=1)
    CALL Process

    ; Increment the counter ("count")
    LDA count           ; Load the current count into A
    INR A               ; Increment A by 1
    STA count           ; Store the new value back into "count"

    ; Check if the counter has wrapped around to 0 (i.e., reached 256)
    CPI 00H             ; Compare A with 0 (if it wrapped around, A will be 0)
    JNZ Loop            ; If A is not zero, repeat the loop

    RET                 ; End of program

;--------------------------------------------------------------------
; Process: Runs the DAA test for a single test case.
;
; It assumes:
;   - The test value is in memory "count".
;   - The flag combination (CY and AC) is preset in register C.
;
; It does the following:
;   1. Loads the flags from C into the PSW (via push/pop) so that
;      the DAA instruction uses these as its incoming flags.
;   2. Prints the current flag combination.
;   3. Prints the current count value (in hex) before DAA.
;   4. Calls DAA.
;   5. Prints the adjusted count (in hex) after DAA.
;   6. Prints the flags after DAA.
;   7. Prints a newline.
;--------------------------------------------------------------------
Process:
    ; Transfer the desired flags (in C) into the PSW.
    ; Here we push B twice then pop PSW.
    PUSH B            ; Save register B (placeholder)
    PUSH B            ; Push again to create a double word on the stack
    POP PSW           ; Pop into PSW: This sets A and the flags (CY and AC)
    
    CALL PrintFlg     ; Print the current flag combination (pre-DAA)

    ; Print the current count value (the original value) in hex.
    LDA count         ; Load "count" into A
    CALL PrintHex     ; Print A as a two-digit hex value
    CALL PrintArw     ; Print an arrow " --> " to separate pre and post values

    POP B             ; Restore register B (cleanup from flag transfer)
    LDA count         ; Load "count" again (original value)

    DAA               ; Execute the DAA instruction

    ; Print the adjusted value after DAA.
    PUSH PSW          ; Save the new A and flags (post-DAA)
    CALL PrintHex     ; Print the adjusted A in hex
    MVI A, ' '        ; Print a space
    CALL PrintChr
    POP PSW           ; Restore previous flags from PSW
    CALL PrintFlg     ; Print the updated flag combination

    CALL PrintNL     ; Print a newline
    RET

;--------------------------------------------------------------------
; PrintArw: Prints a decorative arrow to separate values.
;--------------------------------------------------------------------
PrintArw:
    MVI A, ' '       ; Print a leading space
    CALL PrintChr
    MVI A, '-'       ; Print a hyphen
    CALL PrintChr
    MVI A, '-'       ; Print another hyphen
    CALL PrintChr
    MVI A, '>'       ; Print the 'greater-than' symbol (arrow tip)
    CALL PrintChr
    MVI A, ' '       ; Print a trailing space
    CALL PrintChr
    RET

;--------------------------------------------------------------------
; PrintHex: Prints the value in A as a two-digit hexadecimal number.
; It uses the PSW to save/restore registers.
;--------------------------------------------------------------------
PrintHex:
        PUSH PSW                ; Save A and flags
        RRC                     ; Rotate right: shift high nibble into low bits
        RRC
        RRC
        RRC                     ; Now, the high nibble is in the low 4 bits
        CALL PrintNib           ; Print high nibble (as a hex digit)
        POP PSW                 ; Restore original A (with flags intact)
        CALL PrintNib           ; Print low nibble (by masking A)
        RET

;--------------------------------------------------------------------
; PrintNib: Prints the lower 4 bits of A as a hexadecimal digit.
;--------------------------------------------------------------------
PrintNib:
        ANI 0FH                 ; Mask off upper 4 bits
        CPI 10                  ; Compare to 10
        JM  PrintDig            ; If less than 10, jump to PrintDig
        ADI 'A' - 10            ; Otherwise, convert nibble 10-15 to 'A'-'F'
        JMP PrintChr            ; Jump to print the character
PrintDig:
        ADI '0'                 ; Convert nibble (0-9) to ASCII ('0'-'9')
PrintChr:
        MOV E, A                ; Move the character from A to E
        MVI C, 2                ; BDOS function 2: Print character
        CALL 5                  ; Call BDOS
        RET

;--------------------------------------------------------------------
; PrintNL: Prints a Carriage Return and Line Feed.
;--------------------------------------------------------------------
PrintNL:
        MVI A, 0DH              ; Carriage Return
        CALL PrintChr
        MVI A, 0AH              ; Line Feed
        CALL PrintChr
        RET

;--------------------------------------------------------------------
; PrintFlg: Prints the current flag settings as "CY=?" and "AC=?".
;
; This routine extracts the flags from the PSW that was loaded
; via a previous PUSH PSW / POP B sequence.
;--------------------------------------------------------------------
PrintFlg:
        ; Save the PSW (which holds A and flags) twice
        PUSH PSW
        PUSH PSW

        ; Print "CY="
        MVI A, 'C'
        CALL PrintChr
        MVI A, 'Y'
        CALL PrintChr
        MVI A, '='
        CALL PrintChr

        ; Pop one copy of PSW into B; now register C holds the flags byte.
        POP B
        MOV A, C              ; A now contains the flags byte
        ANI 01H               ; Isolate bit 0 (CY flag)
        ORI 30H               ; Convert 0 or 1 to ASCII '0' or '1'
        CALL PrintChr

        MVI A, ' '           ; Print a space
        CALL PrintChr
        ; Print "AC="
        MVI A, 'A'
        CALL PrintChr
        MVI A, 'C'
        CALL PrintChr
        MVI A, '='
        CALL PrintChr

        ; Pop the second copy of PSW into B to get the original flags again.
        POP B
        MOV A, C              ; A now contains the flags byte again
        ; To extract the AC flag (bit 4), shift it right 4 times.
        RRC                   ; Rotate right, shifting bit 0 into CY; do this 4 times.
        RRC
        RRC
        RRC
        ANI 01H               ; Isolate the resulting bit (original bit 4)
        ORI 30H               ; Convert to ASCII '0' or '1'
        CALL PrintChr

        MVI A, ' '           ; Print a trailing space
        CALL PrintChr

        RET


;---------------------------
; Data Section
;---------------------------
count:  DB 00H            ; 8-bit counter variable