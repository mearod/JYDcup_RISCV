`include "core_defines.v"

module core_if_pc(
    input   clk,
    input   rst_n,

    input   pc_update_en,

    input   pipe_flush_req,
    input   bju_pc_bj_predict,

    input   [`CORE_PC_WIDTH-1:0] bju_pc_offset,
    input   [`CORE_PC_WIDTH-1:0] exu_pipe_flush_pc,

    output  [`CORE_PC_WIDTH-1:0]pc_current,
    output  branch_jump_predict//did predicted next_pc branch or jump?
);

//pc reg////////
wire [`CORE_PC_WIDTH-1:0]pc_next;

gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_RESET_VALUE)pc(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(pc_next    ),
    .dout  	(pc_current   ),
    .wen   	(pc_update_en    )
);
///////////////

wire [`CORE_PC_WIDTH-1:0]pc_predict_add_op1 = bju_pc_bj_predict ?
                                            bju_pc_offset 
                                            : `CORE_PC_WIDTH'h4;

wire [`CORE_PC_WIDTH-1:0]pc_predict = pc_predict_add_op1 + pc_current;


assign pc_next  = pipe_flush_req ? exu_pipe_flush_pc : pc_predict;

assign branch_jump_predict = bju_pc_bj_predict;

endmodule