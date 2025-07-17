`include "core_defines.v"

module core_cpu(
    input   clk,
    input   rst_n,

    output  [`CORE_XLEN-1:0] biu_irom_addr,
    output  [`CORE_XLEN-1:0] biu_irom_inst,
    output  [`CORE_XLEN-1:0] biu_pmem_addr,
    input   [`CORE_XLEN-1:0] biu_pmem_read,
    output  [`CORE_XLEN-1:0] biu_pmem_write,
    output  [`CORE_LSU_WMASK_WIDTH-1:0] biu_pmem_wmask,
    output  biu_pmem_write_en,

    output  rv_ebreak_sim,
	output  inst_end
);

assign inst_end = difftest_end;
assign biu_irom_addr = ifu_pc;
assign biu_irom_inst = rom_inst;

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
wire [`CORE_CSR_INST_WIDTH-1:0] idu_csr_inst_bus;

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
    .rd_dat_ex_forward 	(rd_dat_ex_forward  ),
    .rd_idx_ls_forward 	(rd_idx_ls_forward  ),
    .rd_wen_ls_forward 	(rd_wen_ls_forward  ),
    .rd_dat_ls_forward 	(rd_dat_ls_forward  ),
    .rd_wen_wb_forward 	(rd_wen_wb_forward  ),
    .rd_idx_wb_forward 	(rd_idx_wb_forward  ),
    .rd_dat_wb_forward 	(rd_dat_wb_forward  ),
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
    .o_csr_inst_bus    	(idu_csr_inst_bus     )
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
    .wb_dest_idx   	(rd_idx_wb_forward    ),
    .wb_dest_dat   	(wb_data    )
);

// output declaration of module core_ex_exu
wire ready_id_ex;
wire valid_ex_ls;
wire cmt_pipeline_flush_req;
wire [`CORE_PC_WIDTH-1:0] cmt_flush_pc;
wire [`CORE_XLEN-1:0] wb_data;
wire [`CORE_RFIDX_WIDTH-1:0] rd_idx_ex_forward;
wire rd_wen_ex_forward;
wire [`CORE_XLEN-1:0] rd_dat_ex_forward;
wire [`CORE_LSU_INST_WIDTH-1:0] ex_ls_lsu_inst_bus;
wire [`CORE_XLEN-1:0] ex_ls_exu_result;
wire [`CORE_XLEN-1:0] ex_ls_rs2_dat;
wire ex_ls_rd_wen;

`ifdef DPI_C
wire difftest_end;    
`endif
core_ex_exu u_core_ex_exu(
    `ifdef DPI_C
    .difftest_end               (),
    `endif
    .clk                    	(clk                       ),
    .rst_n                  	(rst_n                     ),
    .valid_in               	(valid_id_ex               ),
    .ready_in               	(ready_id_ex               ),
    .valid_out              	(valid_ex_ls                  ),
    .ready_out              	(ready_ex_ls                      ),
    .i_pc                   	(idu_pc                    ),
    .i_branch_predict       	(idu_branch_jump_predict   ),
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
    .i_csr_inst_bus         	(idu_csr_inst_bus          ),
    .cmt_pipeline_flush_req 	(cmt_pipeline_flush_req    ),
    .cmt_flush_pc           	(cmt_flush_pc              ),
    .lsu_inst_bus           	(ex_ls_lsu_inst_bus        ), 
    .exu_result                 (ex_ls_exu_result          ),
    .rs2_dat                    (ex_ls_rs2_dat             ),
    .rd_wen               	    (ex_ls_rd_wen         ),
    .rd_idx_ex_forward       	(rd_idx_ex_forward         ),
    .rd_wen_ex_forward       	(rd_wen_ex_forward         ),
    .rd_dat_ex_forward       	(rd_dat_ex_forward         ),
    


    .rv_ebreak_sim      (rv_ebreak_sim        )

);

// output declaration of module core_ls_lsu_test
wire valid_ls_wb;
wire ready_ex_ls;
wire flag_unalign_write;
wire [`CORE_XLEN-1:0] ls_read_data;
wire ls_flag_mem_to_reg;
wire ls_flag_csr_to_reg;
wire [`CORE_XLEN-1:0] ls_alu_result;
wire [`CORE_XLEN-1:0] ls_csr_alu_result;
wire [`CORE_RFIDX_WIDTH-1:0] rd_idx_ls_forward;
wire rd_wen_ls_forward;
wire [`CORE_XLEN-1:0] rd_dat_ls_forward;

core_ls_lsu_test u_core_ls_lsu_test(
    .clk                	(clk                 ),
    .rst_n              	(rst_n               ),
    .valid_in           	(valid_ex_ls            ),
    .valid_out          	(valid_ls_wb           ),
    .ready_in           	(ready_ex_ls            ),
    .ready_out          	(ready_ls_wb                 ),
    .i_lsu_inst_bus     	(ex_ls_lsu_inst_bus      ),
    .i_mem_addr         	(ex_ls_exu_result          ),
    .i_write_data       	(ex_ls_rs2_dat        ),
    .i_flag_csr_to_reg  	(0   ),
    .i_csr_alu_result   	(0   ),
    .wmask              	(biu_pmem_wmask         ),
    .flag_unalign_write 	(flag_unalign_write  ),
    .read_data          	(ls_read_data           ),
    .biu_pmem_addr      	(biu_pmem_addr       ),
    .biu_pmem_read      	(biu_pmem_read       ),
    .biu_pmem_write     	(biu_pmem_write      ),
    .biu_pmem_write_en  	(biu_pmem_write_en   ),
    .i_rd_idx           	(rd_idx_ex_forward            ),
    .i_rd_wen           	(ex_ls_rd_wen            ),
    .flag_mem_to_reg    	(ls_flag_mem_to_reg     ),
    .flag_csr_to_reg    	(ls_flag_csr_to_reg     ),
    .alu_result         	(ls_alu_result          ),
    .csr_alu_result     	(ls_csr_alu_result      ),
    .rd_idx_ls_forward  	(rd_idx_ls_forward   ),
    .rd_wen_ls_forward  	(rd_wen_ls_forward   ),
    .rd_dat_ls_forward  	(rd_dat_ls_forward   )
);


wire ready_ls_wb;
wire wb_en;
wire [`CORE_XLEN-1:0] wb_data;
wire [`CORE_RFIDX_WIDTH-1:0] rd_idx_wb_forward;
wire rd_wen_wb_forward;
wire [`CORE_XLEN-1:0] rd_dat_wb_forward;
core_wb_wbu core_wb_wbu_instance(
    .clk(clk),
    .rst_n(rst_n),
    .difftest_end(difftest_end),
    .valid_in(valid_ls_wb),
    .valid_out(),
    .ready_in(ready_ls_wb),
    .ready_out(1'b1),
    .i_rd_idx(rd_idx_ls_forward),
    .i_rd_wen(rd_wen_ls_forward),
    .i_lsu_used(ls_flag_mem_to_reg),
    .lsu_valid(valid_ls_wb),
    .i_alu_result(ls_alu_result),
    .i_lsu_result(ls_read_data),
    .wb_en(wb_en),
    .wb_data(wb_data),
    .rd_idx_wb_forward(rd_idx_wb_forward),
    .rd_wen_wb_forward(rd_wen_wb_forward),
    .rd_dat_wb_forward(rd_dat_wb_forward)
);




endmodule
