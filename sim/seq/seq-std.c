char simname[] = "Y86 Processor: seq-std.hcl";
#include <stdio.h>
#include "isa.h"
#include "sim.h"
int sim_main(int argc, char *argv[]);
int gen_pc(){return 0;}
int main(int argc, char *argv[])
  {plusmode=0;return sim_main(argc,argv);}
int gen_need_regids()
{
    return ((icode) == (I_RRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_MUL));
}

int gen_need_valC()
{
    return ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_JXX)||(icode) == (I_CALL)||(icode) == (I_ALUI)||(icode) == (I_IRMOVL));
}

int gen_instr_valid()
{
    return ((icode) == (I_NOP)||(icode) == (I_HALT)||(icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_MUL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_JXX)||(icode) == (I_CALL)||(icode) == (I_RET)||(icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_ENTER)||(icode) == (I_STOS)||(icode) == (I_REPSTOS));
}

int gen_instr_next_ifun()
{
    return ((((icode) == (I_REPSTOS)) & ((ifun) == 1)) ? 0 : (((((icode) == (I_ENTER)||(icode) == (I_MUL)) & ((ifun) == 0)) | ((((icode) == (I_MUL)) & ((ifun) == 2)) & ((cc) != 2))) | ((((icode) == (I_REPSTOS)) & ((ifun) == 0)) & ((cc) != 2))) ? 1 : (((icode) == (I_MUL)) & ((ifun) == 1)) ? 2 : 1 ? -1 : 0);
}

int gen_srcA()
{
    return (((icode) == (I_ENTER)) ? (REG_EBP) : (((icode) == (I_STOS)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? (REG_EAX) : (((icode) == (I_RRMOVL)||(icode) == (I_RMMOVL)||(icode) == (I_ALU)||(icode) == (I_PUSHL)) | (((icode) == (I_MUL)) & ((ifun) == 2))) ? (ra) : ((icode) == (I_POPL)||(icode) == (I_RET)) ? (REG_ESP) : (((icode) == (I_REPSTOS)) & ((ifun) == 0)) ? (REG_ECX) : 1 ? (REG_NONE) : 0);
}

int gen_srcB()
{
    return ((((icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)) | (((icode) == (I_MUL)) & ((ifun) == 1))) ? (rb) : (((icode) == (I_MUL)) & ((ifun) == 2)) ? (REG_EAX) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_CALL)||(icode) == (I_RET)||(icode) == (I_ENTER)) ? (REG_ESP) : (((icode) == (I_STOS)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? (REG_EDI) : (((icode) == (I_REPSTOS)) & ((ifun) == 0)) ? (REG_ECX) : 1 ? (REG_NONE) : 0);
}

int gen_dstE()
{
    return ((((icode) == (I_ENTER)) & ((ifun) == 1)) ? (REG_EBP) : ((icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)) ? (rb) : (((icode) == (I_MUL)) & ((ifun) == 0)) ? (REG_EAX) : ((((icode) == (I_MUL)) & ((ifun) == 2)) & ((cc) != 2)) ? (REG_EAX) : (((icode) == (I_MUL)) & ((ifun) == 1)) ? (rb) : ((icode) == (I_PUSHL)||(icode) == (I_POPL)||(icode) == (I_CALL)||(icode) == (I_RET)||(icode) == (I_ENTER)) ? (REG_ESP) : (((icode) == (I_STOS)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? (REG_EDI) : (((icode) == (I_REPSTOS)) & ((ifun) == 0)) ? (REG_ECX) : 1 ? (REG_NONE) : 0);
}

int gen_dstM()
{
    return (((icode) == (I_MRMOVL)||(icode) == (I_POPL)) ? (ra) : 1 ? (REG_NONE) : 0);
}

int gen_aluA()
{
    return ((((icode) == (I_IRMOVL)||(icode) == (I_ALUI)) & ((ra) == (REG_NONE))) ? (valc) : (((icode) == (I_RRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)) | (((icode) == (I_MUL)) & ((ifun) == 2))) ? (vala) : ((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)) ? (valc) : (((icode) == (I_ENTER)) & ((ifun) == 0)) ? -4 : ((((icode) == (I_MUL)) & ((ifun) == 1)) | (((icode) == (I_REPSTOS)) & ((ifun) == 0))) ? -1 : ((((icode) == (I_ENTER)) & ((ifun) == 1)) | (((icode) == (I_MUL)) & ((ifun) == 0))) ? 0 : ((icode) == (I_CALL)||(icode) == (I_PUSHL)) ? -4 : (((icode) == (I_RET)||(icode) == (I_POPL)||(icode) == (I_STOS)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? 4 : 0);
}

int gen_aluB()
{
    return ((((((icode) == (I_RMMOVL)||(icode) == (I_MRMOVL)||(icode) == (I_ALU)||(icode) == (I_ALUI)||(icode) == (I_CALL)||(icode) == (I_PUSHL)||(icode) == (I_RET)||(icode) == (I_STOS)||(icode) == (I_ENTER)||(icode) == (I_POPL)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) | (((icode) == (I_MUL)) & ((ifun) == 1||(ifun) == 2))) | (((icode) == (I_REPSTOS)) & ((ifun) == 0))) ? (valb) : (((icode) == (I_RRMOVL)||(icode) == (I_IRMOVL)) | (((icode) == (I_MUL)) & ((ifun) == 0))) ? 0 : 0);
}

int gen_alufun()
{
    return (((icode) == (I_ALU)||(icode) == (I_ALUI)) ? (ifun) : 1 ? (A_ADD) : 0);
}

int gen_set_cc()
{
    return ((((icode) == (I_ALU)) | (((icode) == (I_MUL)) & ((ifun) == 0||(ifun) == 1))) | (((icode) == (I_REPSTOS)) & ((ifun) == 0)));
}

int gen_mem_read()
{
    return ((icode) == (I_MRMOVL)||(icode) == (I_POPL)||(icode) == (I_RET));
}

int gen_mem_write()
{
    return ((((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_CALL)||(icode) == (I_STOS)) | (((icode) == (I_ENTER)) & ((ifun) == 0))) | (((icode) == (I_REPSTOS)) & ((ifun) == 1)));
}

int gen_mem_addr()
{
    return ((((icode) == (I_ENTER)) & ((ifun) == 0)) ? (vale) : ((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_CALL)||(icode) == (I_MRMOVL)) ? (vale) : ((icode) == (I_POPL)||(icode) == (I_RET)) ? (vala) : (((icode) == (I_STOS)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? (valb) : 0);
}

int gen_mem_data()
{
    return (((((icode) == (I_ENTER)) & ((ifun) == 0)) | (((icode) == (I_REPSTOS)) & ((ifun) == 1))) ? (vala) : ((icode) == (I_RMMOVL)||(icode) == (I_PUSHL)||(icode) == (I_STOS)) ? (vala) : ((icode) == (I_CALL)) ? (valp) : 0);
}

int gen_new_pc()
{
    return (((icode) == (I_CALL)) ? (valc) : (((icode) == (I_JXX)) & (bcond)) ? (valc) : ((icode) == (I_RET)) ? (valm) : 1 ? (valp) : 0);
}

