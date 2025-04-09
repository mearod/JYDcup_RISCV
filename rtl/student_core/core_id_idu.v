`include "core_defines.v"

module core_id_idu(
    input clk,
    input rst_n,

    input   valid_in,
    output   ready_in,
    
    output  valid_out,
    input   ready_out,

    input   [`CORE_XLEN-1:0] rs1_dat,
    input   [`CORE_XLEN-1:0] rs2_dat,

    input   [`CORE_PC_WIDTH-1:0] i_pc,
    input   [`CORE_INST_WIDTH-1:0] i_inst,
    input   i_branch_predict,

    input   [`CORE_RFIDX_WIDTH-1:0] rd_idx_ex_forward,
	input   rd_wen_ex_forward,

	input   i_pipe_flush_req,

    output  [`CORE_XLEN-1:0] o_rs1_dat,
    output  [`CORE_XLEN-1:0] o_rs2_dat,

    output  [`CORE_PC_WIDTH-1:0] o_pc,
    output  o_branch_predict,

    output  o_rs1_ren,
    output  o_rs2_ren,
    output  o_rd_wen,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rs1_idx,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rs2_idx,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rd_idx,

    output  [`CORE_XLEN-1:0] o_imm,

    output  [`CORE_BJ_DEC_INST_WIDTH-1:0] o_bj_dec_inst_bus,
    output  [`CORE_ALU_INST_WIDTH-1:0] o_alu_inst_bus,
    output  [`CORE_LSU_INST_WIDTH-1:0] o_lsu_inst_bus,

    input   exu_busy,

	output  rv_ebreak_sim
);


//pipline related//////
wire pipeline_update = valid_in & ready_in;
wire valid_out_next  = (pipeline_update | ~ready_out & valid_out) & ~i_pipe_flush_req;
wire raw_conflict    = (o_rs1_ren & (o_rs1_idx == rd_idx_ex_forward) 
                     | o_rs2_ren & (o_rs2_idx == rd_idx_ex_forward))
										 & (rd_idx_ex_forward != 0) & rd_wen_ex_forward & (~ready_out | exu_busy);
assign ready_in      = ~raw_conflict & (ready_out | ~valid_out);

wire valid_out_tmp;
assign valid_out = valid_out_tmp & ~i_pipe_flush_req;

gnrl_dffr #(1, 1'b0) idu_valid_out(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(valid_out_next),
    .dout  	(valid_out_tmp )
);
////////////////////


////pipeline regs//////
wire branch_predict_reg;
gnrl_dfflr #(1,1'b0)branch_predict_id(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_branch_predict    ),
    .dout  	(branch_predict_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_PC_WIDTH-1:0]pc_reg;
gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_WIDTH'b0)pc_id(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_pc    ),
    .dout  	(pc_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_INST_WIDTH-1:0]inst_reg;
gnrl_dfflr #(`CORE_INST_WIDTH,`CORE_INST_WIDTH'b0)inst_id(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_inst    ),
    .dout  	(inst_reg   ),
    .wen   	(pipeline_update    )
);

////////////////////

core_id_decode inst_decoder(
    .i_inst          	(inst_reg           ),
    .o_rs1_ren       	(o_rs1_ren        ),
    .o_rs2_ren       	(o_rs2_ren        ),
    .o_rd_wen        	(o_rd_wen         ),
    .o_rs1_idx       	(o_rs1_idx        ),
    .o_rs2_idx       	(o_rs2_idx        ),
    .o_rd_idx        	(o_rd_idx         ),
    .o_imm           	(o_imm            ),
    .o_bj_dec_inst_bus 	(o_bj_dec_inst_bus  ),
    .o_alu_inst_bus    	(o_alu_inst_bus     ),
    .o_lsu_inst_bus    	(o_lsu_inst_bus     ),
		.rv_ebreak_sim    (rv_ebreak_sim )
);

assign o_pc = pc_reg;
assign o_branch_predict = branch_predict_reg;

assign o_rs1_dat =  rs1_dat;
assign o_rs2_dat =  rs2_dat;

endmodule
