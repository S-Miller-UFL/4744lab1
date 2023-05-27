;************************************************************************
;  File name: lab1.asm
;  Author:  Christopher Crary
;  Last Modified By: Steven Miller
;  Last Modified On: 25 May 2023
;  Description: To filter data stored within a predefined input table 
;				based on a set of given conditions and store 
;				a subset of filtered values into an output table.
;************************************************************************
;*********************************INCLUDES*******************************
.include "ATxmega128a1udef.inc"
;***********END OF INCLUDES******************************
;*********************************EQUATES********************************
; potentially useful expressions
.equ NULL = 0
.equ ThirtySeven = 3*7 + 37/3 - (3-7)  ; 21 + 12 + 4
;***********END OF EQUATES*******************************

;*********************************DEFS********************************
.def tabval = r16
;***********END OF DEFS*******************************

;***********MEMORY CONFIGURATION*************************
; program memory constants (if necessary)
.cseg
.org 0xf123 ;keep in mind this is a word
IN_TABLE:
.db 178, 0xd2, '#',041,'6',043,0x24,0b11111010,0xce,073,'<',0b00111111,0x00,0b00100100

; label below is used to calculate size of input table
IN_TABLE_END:

; data memory allocation (if necessary)
.dseg
; initialize the output table starting address
.org 0x3737
OUT_TABLE:
.byte (IN_TABLE_END - IN_TABLE)
;***********END OF MEMORY CONFIGURATION***************


;***********MAIN PROGRAM*******************************
.cseg
; configure the reset vector 
;	(ignore meaning of "reset vector" for now)
.org 0x0000
	rjmp MAIN

; place main program after interrupt vectors 
;	(ignore meaning of "interrupt vectors" for now)
.org 0x0100
MAIN:
; point appropriate indices to input/output tables (is RAMP needed?)

;initialize Z pointer using ramp register
ldi ZH, byte3(in_table<<1)
out CPU_RAMPZ, ZH
ldi Zl, byte1(in_table<<1)
ldi ZH, byte2(in_table<<1)

;initialize x pointer
ldi XH, high(out_table)
ldi XL, low(out_table)

;were golden

; loop through input table, performing filtering and storing conditions
LOOP:
	; load value from input table into an appropriate register
	elpm tabval, z+
	; determine if the end of table has been reached (perform general check)
	cpi tabval, null
	; if end of table (EOT) has been reached, i.e., the NULL character was 
	; encountered, the program should branch to the relevant label used to
	; terminate the program (e.g., DONE)
	st x, tabval
	breq done
	; if EOT was not encountered, perform the first specified 
	; overall conditional check on loaded value (CONDITION_1)
CHECK_1:
	; check if the CONDITION_1 is met (bit 7 of # is set); 
	sbrs tabval, 7
	;   if not, branch to FAILED_CHECK1
	rjmp failed_check1
	; since the CONDITION_1 is met, perform the specified operation
	;   (divide # by 2)
	lsr tabval
	; check if CONDITION_1a is met (result < 126); if so, then 
	;   jump to LESS_THAN_126; else store nothing and go back to LOOP
	cpi tabval, 126 ;tabval - 126
	;if negative bit clear, then tabval is greater
	;if negative bit set, then tabval is lesser
	brlo less_than_126
	rjmp LOOP

LESS_THAN_126:
	; subtract 6 and store the result
	subi tabval, 6
	st x+, tabval
	rjmp LOOP
	
FAILED_CHECK1:
	; since the CONDITION_1 is NOT met (bit 7 of # is not set, 
	;    i.e., clear), perform the second specified operation 
	;    (multiply by 2 [unsigned])
	lsl tabval
	; check if CONDITION_2b is met (result >= 75); if so, jump to
	;    GREATER_EQUAL_75 (and do the next specified operation);
	;    else store nothing and go back to LOOP	
	cpi tabval, 75; tabval-75
	;if n flag is clear, then tabval is greater
	;if n flag is set, then tabval is lesser
	brsh GREATER_EQUAL_75
	rjmp LOOP
	
GREATER_EQUAL_75:
	; subtract 4 and store the result 
	subi tabval, 4
	st x+, tabval
	;go back to LOOP
	rjmp LOOP
	
; end of program (infinite loop)
DONE: 
	rjmp DONE
;***********END OF MAIN PROGRAM **********************
