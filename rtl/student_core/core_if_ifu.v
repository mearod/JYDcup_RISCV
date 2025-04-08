`include "core_defines.v"

module core_if_ifu(
    input   clk,
    input   rst_n,

    input   valid_in,
    output  ready_in,
    
    output  valid_out,
    input   ready_out,

    input   [`CORE_INST_WIDTH-1:0]inst_fecthed,
    input   i_pipe_flush_req,
    input   [`CORE_PC_WIDTH-1:0] i_exu_pipe_flush_pc,

    output  [`CORE_INST_WIDTH-1:0] o_inst,
    output  [`CORE_PC_WIDTH-1:0] o_pc,
    output  o_branch_jump_predict//did predicted next_pc branch or jump?
);

//pipeline related////
wire pipeline_update = valid_out & ready_out;
assign valid_out     = 1'b1;//rvalid; //TODO: rvalid not defined
assign ready_in      = ready_out | ~valid_out;
/////////////////////


// output declaration of module core_if_pre_decode
wire flag_jal;
wire flag_jalr;
wire flag_branch;
wire [`CORE_XLEN-1:0] bj_imm;

core_if_pre_decode u_core_if_pre_decode(
    .i_inst      	(inst_fecthed       ),
    .flag_jal    	(flag_jal     ),
    .flag_jalr   	(flag_jalr    ),
    .flag_branch 	(flag_branch  ),
    .bj_imm      	(bj_imm       )
);


// output declaration of module core_if_bpu
wire bju_pc_bj_predict;
wire [`CORE_PC_WIDTH-1:0] bju_pc_offset;

core_if_bpu u_core_if_bpu(
    .current_pc        	(o_pc         ),
    .flag_jal          	(flag_jal           ),
    .flag_jalr         	(flag_jalr          ),
    .flag_branch       	(flag_branch        ),
    .bj_imm            	(bj_imm             ),
    .bju_pc_bj_predict 	(bju_pc_bj_predict  ),
    .bju_pc_offset     	(bju_pc_offset      )
);

// output declaration of module core_if_pc
wire [`CORE_PC_WIDTH-1:0] pc_current;
wire branch_jump_predict;

core_if_pc u_core_if_pc(
    .clk                 	(clk                  ),
    .rst_n               	(rst_n                ),
    .pc_update_en        	(pipeline_update      ),
    .pipe_flush_req      	(i_pipe_flush_req       ),
    .bju_pc_bj_predict   	(bju_pc_bj_predict    ),
    .bju_pc_offset       	(bju_pc_offset        ),
    .exu_pipe_flush_pc   	(i_exu_pipe_flush_pc    ),
    .pc_current          	(o_pc           ),
    .branch_jump_predict 	(o_branch_jump_predict  )
);

assign  o_inst = inst_fecthed;

endmodule
