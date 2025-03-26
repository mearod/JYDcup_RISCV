`include "core_defines.v"

module core_ex_bj_dec(
    input   [`CORE_ALU_INST_WIDTH-1:0] bj_dec_inst_bus,

    input   [`CORE_XLEN-1:0] pc,
    input   [`CORE_XLEN-1:0] imm,    
    input   [`CORE_XLEN-1:0] rs1,

    input   alu_zero_flag,
    input   alu_less_flag,

    output  branch_jump,
    output  [`CORE_PC_WIDTH-1:0] bj_pc
);

wire [`CORE_XLEN-1:0]op1 = bj_dec_inst_bus[CORE_BJ_DEC_INST_JALR] ? rs1 : pc;

//output assign
assign branch_jump = 
    bj_dec_inst_bus[CORE_BJ_DEC_INST_JAL]
    | bj_dec_inst_bus[CORE_BJ_DEC_INST_JALR]
    | (bj_dec_inst_bus[CORE_BJ_DEC_INST_BEQ] & alu_zero_flag)
    | (bj_dec_inst_bus[CORE_BJ_DEC_INST_BNE] & ~alu_zero_flag)
    | (bj_dec_inst_bus[CORE_BJ_DEC_INST_BLT] & alu_less_flag)
    | (bj_dec_inst_bus[CORE_BJ_DEC_INST_BGE] & ~alu_less_flag);

assign bj_pc = op1 + imm;
///////////

endmodule
