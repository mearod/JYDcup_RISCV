`include "core_defines.v"

module core_ex_exu(
    input clk,
    input rst_n,

    input   valid_in,
    output   ready_in,
    
    output  valid_out,
    input   ready_out,

    input   [`CORE_PC_WIDTH-1:0] i_pc,
    input   i_branch_predict,

    input   [`CORE_XLEN-1:0] i_rs1_dat,
    input   [`CORE_XLEN-1:0] i_rs2_dat,

    input   i_rs1_ren,
    input   i_rs2_ren,
    input   i_rd_wen,
    input   [`CORE_RFIDX_WIDTH-1:0] i_rs1_idx,
    input   [`CORE_RFIDX_WIDTH-1:0] i_rs2_idx,
    input   [`CORE_RFIDX_WIDTH-1:0] i_rd_idx,

    input   [`CORE_XLEN-1:0] i_imm,

    input   [`CORE_BJ_DEC_INST_WIDTH-1:0] i_bj_dec_inst_bus,
    input   [`CORE_ALU_INST_WIDTH-1:0] i_alu_inst_bus,
    input   [`CORE_LSU_INST_WIDTH-1:0] i_lsu_inst_bus,

    output   [`CORE_RFIDX_WIDTH-1:0] i_rs1_idx,
    output   [`CORE_RFIDX_WIDTH-1:0] i_rs2_idx,

    output  [`CORE_PC_WIDTH-1:0] cmt_flush_pc,

    output  wb_en,
    output  [`CORE_XLEN-1:0] wb_data


    output  [`CORE_RFIDX_WIDTH-1:0] rd_idx_forward,

    output  [`CORE_XLEN-1:0] rd_dat_forward
);

//pipeline related////
wire pipeline_update = ready_in & valid_in;
assign valid_out     = wb_en;
wire ready_in_next   = wb_en | ~valid_in & ready_in;

gnrl_dffr #(1, 1'b1) exu_ready_in(
    .clk   	(clk     ),
    .rst_n 	(rst_n   ),
    .din   	(ready_in_next),
    .dout  	(ready_in     ),
);
/////////////////////

//pipeline regs//////////
wire branch_predict_reg;
gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_WIDTH'b0)branch_predict_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_branch_predict    ),
    .dout  	(branch_predict_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_PC_WIDTH-1:0]pc;
gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_WIDTH'b0)pc_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_pc    ),
    .dout  	(pc_reg   ),
    .wen   	(pipeline_update    )
);

wire rs1_dat_reg;
gnrl_dffl #(`CORE_XLEN)rs1_dat_ex(
    .clk   	(clk    ),
    .din   	(i_rs1_dat    ),
    .dout  	(rs1_dat_reg   ),
    .wen   	(pipeline_update    )
);

wire rs2_dat_reg;
gnrl_dffl #(`CORE_XLEN)rs2_dat_ex(
    .clk   	(clk    ),
    .din   	(i_rs1_dat    ),
    .dout  	(rs2_dat_reg   ),
    .wen   	(pipeline_update    )
);

wire rd_wen_reg;
gnrl_dfflr #(1,1'b0)rd_wen_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rd_wen    ),
    .dout  	(rd_wen_reg   ),
    .wen   	(pipeline_update    )
);

wire rs1_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rs1_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rs1_idx    ),
    .dout  	(rs1_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire rs2_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rs2_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rs2_idx    ),
    .dout  	(rs2_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire rd_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rd_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_i_rd_idx    ),
    .dout  	(rd_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire imm_reg;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)imm_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_imm    ),
    .dout  	(imm_reg   ),
    .wen   	(pipeline_update    )
);

wire bj_dec_inst_bus_reg;
gnrl_dfflr #(`CORE_BJ_DEC_INST_WIDTH,`CORE_BJ_DEC_INST_WIDTH'b0)bj_dec_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_bj_dec_inst_bus    ),
    .dout  	(bj_dec_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);

wire alu_inst_bus_reg;
gnrl_dfflr #(`CORE_BJ_DEC_INST_WIDTH,`CORE_BJ_DEC_INST_WIDTH'b0)alu_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_alu_inst_bus    ),
    .dout  	(alu_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);

wire lsu_inst_bus_reg;
gnrl_dfflr #(`CORE_BJ_DEC_INST_WIDTH,`CORE_BJ_DEC_INST_WIDTH'b0)lsu_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_inst_bus    ),
    .dout  	(lsu_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);
///////////////////////

// output declaration of module core_ex_alu
wire alu_zero_flag;
wire alu_less_flag;
wire [`CORE_XLEN-1:0] alu_result;

core_ex_alu u_core_ex_alu(
    .alu_inst_bus 	(alu_inst_bus_reg  ),
    .rs1          	(rs1_dat_reg           ),
    .rs2          	(rs2_dat_reg           ),
    .pc           	(pc_reg            ),
    .imm          	(imm_reg           ),
    .zero_flag    	(alu_zero_flag     ),
    .less_flag    	(alu_less_flag     ),
    .alu_result   	(alu_result    )
);


// output declaration of module core_ex_bj_dec
wire branch_jump;
wire [`CORE_PC_WIDTH-1:0] bj_pc;

core_ex_bj_dec u_core_ex_bj_dec(
    .bj_dec_inst_bus 	(bj_dec_inst_bus_reg  ),
    .pc              	(pc_reg               ),
    .imm             	(imm_reg              ),
    .rs1             	(rs1_dat_reg          ),
    .alu_zero_flag   	(alu_zero_flag    ),
    .alu_less_flag   	(alu_less_flag    ),
    .branch_jump     	(branch_jump      ),
    .bj_pc           	(bj_pc            )
);

//lsu related/////////////////
// output declaration of module core_ex_lsu_dpic_test
wire lsu_valid_out;
wire lsu_ready_in;
wire [7:0] wmask;
wire flag_unalign_write;
wire [`CORE_XLEN-1:0] lsu_result;

core_ex_lsu_dpic_test u_core_ex_lsu_dpic_test(
    .clk                	(clk                 ),
    .rst_n              	(rst_n               ),
    .valid_out          	(lsu_valid_out           ),
    .ready_in           	(lsu_ready_in            ),
    .i_lsu_inst_bus     	(lsu_inst_bus_reg      ),
    .i_mem_addr         	(alu_result          ),
    .i_write_data       	(alu_result        ),
    .wmask              	(wmask               ),
    .flag_unalign_write 	(flag_unalign_write  ),
    .read_data          	(lsu_result           )
);


////////////////////////////////////


//pc_commit///////////
core_ex_commit u_core_ex_commit(
    .branch_predict     	(branch_predict_reg      ),
    .branch_jump        	(branch_jump         ),
    .pipeline_flush_req 	(cmt_pipeline_flush_req  ),
    .pc                 	(pc_reg                  ),
    .bj_pc              	(bj_pc               ),
    .flush_pc           	(cmt_flush_pc            )
);
/////////////////////


// output declaration of module core_ex_wbu
wire wb_en;
wire [`CORE_XLEN-1:0] wb_data;

core_ex_wbu u_core_ex_wbu(
    .rd_wen     	(rd_wen_reg      ),
    .lsu_used   	(lsu_used    ),
    .lsu_valid  	(lsu_valid_out   ),
    .alu_result 	(alu_result  ),
    .lsu_result 	(lsu_result  ),
    .wb_en      	(wb_en       ),
    .wb_data    	(wb_data     )
);



wire    lsu_used = i_lsu_inst_bus[`CORE_LSU_INST_LOAD] | i_lsu_inst_bus[`CORE_LSU_INST_STORE];

///output assign//////
assign rd_idx_forward  = rd_idx_reg;

assign rd_dat_forward  = wb_data;
/////////////////////
endmodule
