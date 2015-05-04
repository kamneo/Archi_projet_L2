#/* $begin seq-all-hcl */
#/* $begin seq-plus-all-hcl */
####################################################################
#  HCL Description of Control for Single Cycle Y86 Processor SEQ   #
#  Copyright (C) Randal E. Bryant, David R. O'Hallaron, 2002       #
####################################################################

####################################################################
#    C Include's.  Don't alter these                               #
####################################################################

quote '#include <stdio.h>'
quote '#include "isa.h"'
quote '#include "sim.h"'
quote 'int sim_main(int argc, char *argv[]);'
quote 'int gen_pc(){return 0;}'
quote 'int main(int argc, char *argv[])'
quote '  {plusmode=0;return sim_main(argc,argv);}'

####################################################################
#    Declarations.  Do not change/remove/delete any of these       #
####################################################################

##### Symbolic representation of Y86 Instruction Codes #############
intsig NOP 	'I_NOP'
intsig HALT	'I_HALT'
intsig RRMOVL	'I_RRMOVL'
intsig IRMOVL	'I_IRMOVL'
intsig RMMOVL	'I_RMMOVL'
intsig MRMOVL	'I_MRMOVL'
intsig OPL	'I_ALU'
intsig IOPL	'I_ALUI'
intsig JXX	'I_JXX'
intsig PUSHLCALL	'I_PUSHLCALL'
intsig POPLRET	'I_POPLRET'
#intsig JMEM	'I_JMEM'
#intsig JREG	'I_JREG'
intsig LEAVE	'I_LEAVE'
# Exercice 3.1
intsig ENTER	'I_ENTER'
#Exercice 3.2
intsig MUL	'I_MUL'
#Exercice 3.3
intsig STOS	'I_STOS'
intsig REPSTOS	'I_REPSTOS'

intsig REDI		'REG_EDI'
intsig RECX		'REG_ECX'
intsig REAX		'REG_EAX'
intsig cc 'cc'	

##### Symbolic representation of Y86 Registers referenced explicitly #####
intsig RESP     'REG_ESP'    	# Stack Pointer
intsig REBP     'REG_EBP'    	# Frame Pointer
intsig RNONE    'REG_NONE'   	# Special value indicating "no register"

##### ALU Functions referenced explicitly                            #####
intsig ALUADD	'A_ADD'		# ALU should add its arguments

##### Signals that can be referenced by control logic ####################

##### Fetch stage inputs		#####
intsig pc 'pc'				# Program counter
##### Fetch stage computations		#####
intsig icode	'icode'			# Instruction control code
intsig ifun	'ifun'			# Instruction function
intsig rA	'ra'			# rA field from instruction
intsig rB	'rb'			# rB field from instruction
intsig valC	'valc'			# Constant from instruction
intsig valP	'valp'			# Address of following instruction

##### Decode stage computations		#####
intsig valA	'vala'			# Value from register A port
intsig valB	'valb'			# Value from register B port

##### Execute stage computations	#####
intsig valE	'vale'			# Value computed by ALU
boolsig Bch	'bcond'			# Branch test

##### Memory stage computations		#####
intsig valM	'valm'			# Value read from memory


####################################################################
#    Control Signal Definitions.                                   #
####################################################################

################ Fetch Stage     ###################################

# Does fetched instruction require a regid byte?
bool need_regids =
	icode in { RRMOVL, OPL, RMMOVL, MRMOVL, MUL } ||
	icode in { PUSHLCALL, POPLRET } && ifun == 0;

# Does fetched instruction require a constant word?

	#Exercice 1 question 2 :
bool need_valC =
	icode in { RMMOVL, MRMOVL, JXX, PUSHLCALL, IOPL, IRMOVL };

bool instr_valid = icode in 
	{ NOP, HALT, RRMOVL, IRMOVL, RMMOVL, MRMOVL,
	       MUL, OPL, IOPL, JXX, PUSHLCALL, POPLRET, ENTER, STOS, REPSTOS};

#Exercice 3 question 2:
int instr_next_ifun = [
	icode == REPSTOS && ifun == 1 : 0;
	icode in { ENTER, MUL } && ifun == 0 || icode == MUL && ifun == 2 && cc != 2 || icode == REPSTOS && ifun == 0 && cc != 2 : 1;
 	icode in { MUL } && ifun == 1 : 2;
    1 : -1;
];


################ Decode Stage    ###################################

## What register should be used as the A source?
int srcA = [
	#Exercice 3 question 2:
	icode == ENTER : REBP;
	#Exercice 3.3 :
	icode == STOS || icode == REPSTOS && ifun == 1 : REAX;
	icode in { RRMOVL, RMMOVL, OPL, PUSHLCALL } || icode == MUL && ifun == 2 : rA;
	icode == POPLRET : RESP;
	icode == REPSTOS && ifun == 0 : RECX;
	1 : RNONE; # Don't need register
];

## What register should be used as the B source?
int srcB = [
	#Exercice 3 question 2:
	icode in { OPL, IOPL, RMMOVL, MRMOVL } || icode == MUL && ifun == 1 : rB;
	icode == MUL && ifun == 2 : REAX;
	icode in { PUSHLCALL, POPLRET, ENTER } : RESP;
	icode == STOS || icode == REPSTOS && ifun == 1 : REDI;
	icode == REPSTOS && ifun == 0 : RECX;
	1 : RNONE;  # Don't need register
];

## What register should be used as the E destination?
int dstE = [
	#Exercice 3 question 2:
	icode == ENTER && ifun == 1 : REBP;
	icode in { RRMOVL, IRMOVL, OPL, IOPL } : rB;
	#Exercice 3 question 2:
	icode == MUL && ifun == 0 : REAX;
	icode == MUL && ifun == 2 && cc != 2 : REAX;
	icode == MUL && ifun == 1 : rB;
	icode in { PUSHLCALL, POPLRET, ENTER } : RESP;
	icode == STOS || icode == REPSTOS && ifun == 1 : REDI;
	icode == REPSTOS && ifun == 0 : RECX;
	1 : RNONE;  # Don't need register
];

## What register should be used as the M destination?
int dstM = [
	icode in { MRMOVL } || icode == POPLRET && ifun == 0 : rA;
	1 : RNONE;  # Don't need register
];

################ Execute Stage   ###################################

## Select input A to ALU
int aluA = [
	#Exercice 1 question 2 :
	icode in { IRMOVL, IOPL } && rA == RNONE : valC;
	icode in { RRMOVL, OPL, IOPL } || icode == MUL && ifun == 2 : valA;
	icode in { RMMOVL, MRMOVL } : valC;
	#Exercice 3 question 2:
	icode == ENTER && ifun == 0 : -4;
	icode == MUL && ifun == 1 || icode == REPSTOS && ifun == 0 : -1;
	icode == ENTER && ifun == 1 || icode == MUL && ifun == 0 : 0;
	icode == PUSHLCALL  : -4;
	#Exercice 3 question 3:
	icode in { POPLRET, STOS } || icode == REPSTOS && ifun == 1 : 4;
	# Other instructions don't need ALU
];

## Select input B to ALU
int aluB = [
	icode in { RMMOVL, MRMOVL, OPL, IOPL ,PUSHLCALL, POPLRET, STOS, ENTER } || icode == REPSTOS && ifun == 1 || icode == MUL && ifun in { 1, 2 } || icode == REPSTOS && ifun == 0 : valB;
	icode in { RRMOVL, IRMOVL } || icode == MUL && ifun == 0 : 0;
	# Other instructions don't need ALU
];

## Set the ALU function
int alufun = [
	icode in { OPL, IOPL } : ifun;
	1 : ALUADD;
];

## Should the condition codes be updated?
bool set_cc = 	icode == OPL ||
				icode == MUL && ifun in {0, 1} ||
				icode == REPSTOS && ifun == 0;

################ Memory Stage    ###################################

## Set read control signal
bool mem_read = icode in { MRMOVL, POPLRET };

## Set write control signal
#Exercice 3 question 2:
bool mem_write = icode in { RMMOVL, PUSHLCALL, STOS } || icode == ENTER && ifun == 0|| icode == REPSTOS && ifun == 1;

## Select memory address
int mem_addr = [
	#Exercice 3 question 2:
	icode == ENTER && ifun == 0 : valE;
	icode in { RMMOVL, PUSHLCALL, MRMOVL } : valE;
	icode in { POPLRET } : valA;
	icode == STOS || icode == REPSTOS && ifun == 1 : valB;
	# Other instructions don't need address
];

## Select memory input data
int mem_data = [
	#Exercice 3 question 2:
	icode in { ENTER, PUSHLCALL } && ifun == 0 || icode == REPSTOS && ifun == 1: valA;
	# Value from register
	icode in { RMMOVL, STOS } : valA;
	# Return PC
	icode == PUSHLCALL && ifun == 1: valP;
	# Default: Don't write anything
];

################ Program Counter Update ############################

## What address should instruction be fetched at

int new_pc = [
	# Call.  Use instruction constant
	icode == PUSHLCALL && ifun == 1 : valC;
	# Taken branch.  Use instruction constant
	icode == JXX && Bch : valC;
	# Completion of RET instruction.  Use value from stack
	icode == POPLRET : valM;
	# Default: Use incremented PC
	1 : valP;
];
#/* $end seq-plus-all-hcl */
#/* $end seq-all-hcl */
