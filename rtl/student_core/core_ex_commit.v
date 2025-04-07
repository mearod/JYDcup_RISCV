`include "core_defines.v"

module core_ex_commit(
    input   branch_predict,
    input   branch_jump,
    output  pipeline_flush_req,

    input   [`CORE_PC_WIDTH-1:0] pc,
    input   [`CORE_PC_WIDTH-1:0] bj_pc,
    output  [`CORE_PC_WIDTH-1:0] flush_pc
);

assign pipeline_flush_req = branch_predict ^ branch_jump;

assign flush_pc = branch_jump ? bj_pc : (pc + `CORE_PC_WIDTH'h4);

endmodule