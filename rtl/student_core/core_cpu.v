`include "core_defines.v"

module core_cpu(
    input   clk,
    input   rst_n,
		output  rv_ebreak_sim
);

// output declaration of module core_ifu_rom_dpic_test
wire [`CORE_INST_WIDTH-1:0] rom_inst;

core_ifu_rom_dpic_test u_core_ifu_rom_dpic_test(
    .pc   	(ifu_pc    ),
    .inst 	(rom_inst  )
);

// output declaration of module core_if_ifu
wire valid_if_id;
wire [`CORE_INST_WIDTH-1:0] ifu_inst;
wire [`CORE_PC_WIDTH-1:0] ifu_pc;
wire ifu_branch_jump_predict;

core_if_ifu u_core_if_ifu(
    .clk                   	(clk                    ),
    .rst_n                 	(rst_n                  ),
    .valid_in              	(1'b1               ),
    .ready_in              	(               ),
    .valid_out             	(valid_if_id              ),
    .ready_out             	(ready_if_id              ),
    .inst_fecthed          	(rom_inst           ),
    .i_pipe_flush_req      	(cmt_pipeline_flush_req       ),
    .i_exu_pipe_flush_pc   	(cmt_flush_pc    ),
    .o_inst                	(ifu_inst                 ),
    .o_pc                  	(ifu_pc                   ),
    .o_branch_jump_predict 	(ifu_branch_jump_predict  )
);


// output declaration of module core_id_idu
wire ready_if_id;
wire valid_id_ex;
wire [`CORE_XLEN-1:0] idu_rs1_dat;
wire [`CORE_XLEN-1:0] idu_rs2_dat;
wire [`CORE_PC_WIDTH-1:0] idu_pc;
wire idu_branch_jump_predict;
wire idu_rs1_ren;
wire idu_rs2_ren;
wire idu_rd_wen;
wire [`CORE_RFIDX_WIDTH-1:0] idu_rs1_idx;
wire [`CORE_RFIDX_WIDTH-1:0] idu_rs2_idx;
wire [`CORE_RFIDX_WIDTH-1:0] idu_rd_idx;
wire [`CORE_XLEN-1:0] idu_imm;
wire [`CORE_BJ_DEC_INST_WIDTH-1:0] idu_bj_dec_inst_bus;
wire [`CORE_ALU_INST_WIDTH-1:0] idu_alu_inst_bus;
wire [`CORE_LSU_INST_WIDTH-1:0] idu_lsu_inst_bus;

core_id_idu u_core_id_idu(
    .clk               	(clk                ),
    .rst_n             	(rst_n              ),
    .valid_in          	(valid_if_id           ),
    .ready_in          	(ready_if_id           ),
    .valid_out         	(valid_id_ex          ),
    .ready_out         	(ready_id_ex          ),
    .rs1_dat           	(read_src1_dat            ),
    .rs2_dat           	(read_src2_dat            ),
    .i_pc              	(ifu_pc               ),
    .i_inst            	(ifu_inst             ),
    .i_branch_predict  	(ifu_branch_jump_predict   ),
    .rd_idx_ex_forward 	(rd_idx_ex_forward  ),
    .rd_wen_ex_forward 	(rd_wen_ex_forward  ),
    .i_pipe_flush_req  	(cmt_pipeline_flush_req   ),
    .o_rs1_dat         	(idu_rs1_dat          ),
    .o_rs2_dat         	(idu_rs2_dat          ),
    .o_pc              	(idu_pc               ),
    .o_branch_predict  	(idu_branch_jump_predict   ),
    .o_rs1_ren         	(idu_rs1_ren          ),
    .o_rs2_ren         	(idu_rs2_ren          ),
    .o_rd_wen          	(idu_rd_wen           ),
    .o_rs1_idx         	(idu_rs1_idx          ),
    .o_rs2_idx         	(idu_rs2_idx          ),
    .o_rd_idx          	(idu_rd_idx           ),
    .o_imm             	(idu_imm              ),
    .o_bj_dec_inst_bus 	(idu_bj_dec_inst_bus  ),
    .o_alu_inst_bus    	(idu_alu_inst_bus     ),
    .o_lsu_inst_bus    	(idu_lsu_inst_bus     ),
		.rv_ebreak_sim      (rv_ebreak_sim        )
);


// output declaration of module core_id_regfile
wire [`CORE_XLEN-1:0] read_src1_dat;
wire [`CORE_XLEN-1:0] read_src2_dat;

core_id_regfile u_core_id_regfile(
    .clk           	(clk            ),
    .rst_n         	(rst_n          ),
    .rd_src1_idx   	(idu_rs1_idx    ),
    .rd_src2_idx   	(idu_rs2_idx    ),
    .read_src1_dat 	(read_src1_dat  ),
    .read_src2_dat 	(read_src2_dat  ),
    .wb_dest_wen   	(wb_en    ),
    .wb_dest_idx   	(wb_idx    ),
    .wb_dest_dat   	(wb_data    )
);

// output declaration of module core_ex_exu
wire ready_id_ex;
wire valid_ex;
wire cmt_pipeline_flush_req;
wire [`CORE_PC_WIDTH-1:0] cmt_flush_pc;
wire wb_en;
wire [`CORE_RFIDX_WIDTH-1:0] wb_idx;
wire [`CORE_XLEN-1:0] wb_data;
wire [`CORE_RFIDX_WIDTH-1:0] rd_idx_ex_forward;
wire rd_wen_ex_forward;
wire [`CORE_XLEN-1:0] rd_dat_ex_forward;

core_ex_exu u_core_ex_exu(
    .clk                    	(clk                     ),
    .rst_n                  	(rst_n                   ),
    .valid_in               	(valid_id_ex                ),
    .ready_in               	(ready_id_ex                ),
    .valid_out              	(valid_ex               ),
    .ready_out              	(1'b1               ),
    .i_pc                   	(idu_pc                    ),
    .i_branch_predict       	(idu_branch_jump_predict        ),
    .i_rs1_dat              	(idu_rs1_dat               ),
    .i_rs2_dat              	(idu_rs2_dat               ),
    .i_rs1_ren              	(idu_rs1_ren               ),
    .i_rs2_ren              	(idu_rs2_ren               ),
    .i_rd_wen               	(idu_rd_wen                ),
    .i_rs1_idx              	(idu_rs1_idx               ),
    .i_rs2_idx              	(idu_rs2_idx               ),
    .i_rd_idx               	(idu_rd_idx                ),
    .i_imm                  	(idu_imm                   ),
    .i_bj_dec_inst_bus      	(idu_bj_dec_inst_bus       ),
    .i_alu_inst_bus         	(idu_alu_inst_bus          ),
    .i_lsu_inst_bus         	(idu_lsu_inst_bus          ),
    .cmt_pipeline_flush_req 	(cmt_pipeline_flush_req  ),
    .cmt_flush_pc           	(cmt_flush_pc            ),
    .wb_en                  	(wb_en                   ),
    .wb_idx                  	(wb_idx                   ),
    .wb_data                	(wb_data                 ),
    .rd_idx_ex_forward         	(rd_idx_ex_forward          ),
    .rd_wen_ex_forward         	(rd_wen_ex_forward          ),
    .rd_dat_ex_forward         	(rd_dat_ex_forward          )
);






endmodule
