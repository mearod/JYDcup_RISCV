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
    input   [`CORE_XLEN-1:0] rd_dat_ex_forward,
    input   [`CORE_RFIDX_WIDTH-1:0] rd_idx_ls_forward,
    input   rd_wen_ls_forward,
    input   [`CORE_XLEN-1:0] rd_dat_ls_forward,
    input   [`CORE_RFIDX_WIDTH-1:0] rd_idx_wb_forward,
    input   rd_wen_wb_forward,
    input   [`CORE_XLEN-1:0] rd_dat_wb_forward,

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
    output  [`CORE_CSR_INST_WIDTH-1:0] o_csr_inst_bus
);


//pipline related//////
wire pipeline_update = valid_in & ready_in;

wire valid_out_next  = valid_in & ~i_pipe_flush_req;

assign ready_in      = (ready_out | ~valid_out) ;




wire raw_ex_rs1_conflict = ((rd_idx_ex_forward == o_rs1_idx) & (rd_idx_ex_forward != 0)) & rd_wen_ex_forward & o_rs1_ren;
wire raw_ls_rs1_conflict = ((rd_idx_ls_forward == o_rs1_idx) & (rd_idx_ls_forward != 0)) & rd_wen_ls_forward & o_rs1_ren;
wire raw_wb_rs1_conflict = ((rd_idx_wb_forward == o_rs1_idx) & (rd_idx_wb_forward != 0)) & rd_wen_wb_forward & o_rs1_ren;

wire raw_ex_rs2_conflict = ((rd_idx_ex_forward == o_rs2_idx) & (rd_idx_ex_forward != 0)) & rd_wen_ex_forward & o_rs2_ren;
wire raw_ls_rs2_conflict = ((rd_idx_ls_forward == o_rs2_idx) & (rd_idx_ls_forward != 0)) & rd_wen_ls_forward & o_rs2_ren;
wire raw_wb_rs2_conflict = ((rd_idx_wb_forward == o_rs2_idx) & (rd_idx_wb_forward != 0)) & rd_wen_wb_forward & o_rs2_ren;

gnrl_dffr #(1, 1'b0) idu_valid_out(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(valid_out_next),
    .dout  	(valid_out )
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
    .o_csr_inst_bus    	(o_csr_inst_bus     )
);

assign o_pc = pc_reg;
assign o_branch_predict = branch_predict_reg;

assign o_rs1_dat =  raw_ex_rs1_conflict ? rd_dat_ex_forward : 
                    raw_ls_rs1_conflict ? rd_dat_ls_forward : 
                    raw_wb_rs1_conflict ? rd_dat_wb_forward : 
                    rs1_dat;

assign o_rs2_dat =  raw_ex_rs2_conflict ? rd_dat_ex_forward : 
                    raw_ls_rs2_conflict ? rd_dat_ls_forward : 
                    raw_wb_rs2_conflict ? rd_dat_wb_forward : 
                    rs2_dat;

endmodule
