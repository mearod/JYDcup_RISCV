`include "core_defines.v"

module core_if_bpu(
    input   [`CORE_PC_WIDTH-1:0] current_pc,

//pre decoder//
    input   flag_jal,
    input   flag_jalr,
    input   flag_branch,
    input   [`CORE_XLEN-1:0] bj_imm,
///////////////

    output  bju_pc_bj_predict,
    output  [`CORE_PC_WIDTH-1:0] bju_pc_offset
);

assign bju_pc_bj_predict = (bj_imm[`CORE_XLEN-1] & flag_branch) | flag_jal;//if offset < 0 then jump;else don't jump.

assign bju_pc_offset = bj_imm;

endmodule