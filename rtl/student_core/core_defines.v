`include "verilator_dpi-c_defines.v"
//cpu information
`define CORE_XLEN 32
`define CORE_INST_WIDTH 32
`define CORE_PC_WIDTH 32

//ex_regfile
`define CORE_RFIDX_WIDTH 5
`define CORE_RF_NUM 32

//alu_inst
`define CORE_ALU_INST_WIDTH 17
`define CORE_ALU_INST_ADD 0
`define CORE_ALU_INST_SUB 1
`define CORE_ALU_INST_CMP 2
`define CORE_ALU_INST_CMP_U 3
`define CORE_ALU_INST_XOR 4
`define CORE_ALU_INST_SLL 5
`define CORE_ALU_INST_SRL 6
`define CORE_ALU_INST_SRA 7
`define CORE_ALU_INST_OR 8
`define CORE_ALU_INST_AND 9
`define CORE_ALU_INST_OP1_PC 10
`define CORE_ALU_INST_OP2_IMM 11
`define CORE_ALU_INST_RS2ADR 16:12

//bj_dec inst
`define CORE_BJ_DEC_INST_WIDTH 6
`define CORE_BJ_DEC_INST_JAL 0
`define CORE_BJ_DEC_INST_JALR 1
`define CORE_BJ_DEC_INST_BEQ 2
`define CORE_BJ_DEC_INST_BNE 3
`define CORE_BJ_DEC_INST_BLT 4
`define CORE_BJ_DEC_INST_BGE 5

//lsu inst
`define CORE_LSU_INST_WIDTH 6
`define CORE_LSU_INST_LOAD 0
`define CORE_LSU_INST_STORE 1
`define CORE_LSU_INST_B 2
`define CORE_LSU_INST_H 3
`define CORE_LSU_INST_W 4
`define CORE_LSU_INST_LU 5


//LSU
`define CORE_LSU_WMASK_WIDTH 8

