`include "core_defines.v"

module core_ex_exu(
    `ifdef DPI_C
        output difftest_end,
    `endif

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
    input   [`CORE_CSR_INST_WIDTH-1:0] i_csr_inst_bus,

    output  cmt_pipeline_flush_req,
    output  [`CORE_PC_WIDTH-1:0] cmt_flush_pc,

    output  wb_en,
    output  [`CORE_RFIDX_WIDTH-1:0] wb_idx,
    output  [`CORE_XLEN-1:0] wb_data,


    output  exu_busy,
    output  [`CORE_RFIDX_WIDTH-1:0] rd_idx_ex_forward,
    output  rd_wen_ex_forward,
    output  [`CORE_XLEN-1:0] rd_dat_ex_forward
);

//pipeline related////
wire pipeline_update = ready_in & valid_in;
assign valid_out     = wb_en;

wire ready_in_tmp;
wire ready_in_next   = lsu_used & lsu_valid_out 
                     | (~(valid_in & ready_in) & ready_in_tmp);
assign ready_in      = ~lsu_used | ready_in_tmp;

wire flush_state;
wire flush_state_next = pipeline_update;
assign cmt_pipeline_flush_req = cmt_pipeline_flush_req_tmp & flush_state;

wire exu_busy_next   = pipeline_update | ~difftest_end;

gnrl_dffr #(1, 1'b1) exu_ready_in(
    .clk   	(clk     ),
    .rst_n 	(rst_n   ),
    .din   	(ready_in_next),
    .dout  	(ready_in_tmp )
);

gnrl_dffr #(1, 1'b0) exu_flush_state(
    .clk   	(clk     ),
    .rst_n 	(rst_n   ),
    .din   	(flush_state_next),
    .dout  	(flush_state)
);

gnrl_dffr #(1, 1'b0) exu_busy_state(
    .clk   	(clk     ),
    .rst_n 	(rst_n   ),
    .din   	(exu_busy_next),
    .dout  	(exu_busy     )
);
/////////////////////

//pipeline regs//////////
wire branch_predict_reg;
gnrl_dfflr #(1,1'b0)branch_predict_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_branch_predict    ),
    .dout  	(branch_predict_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_PC_WIDTH-1:0]pc_reg;
gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_WIDTH'b0)pc_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_pc    ),
    .dout  	(pc_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0]rs1_dat_reg;
gnrl_dffl #(`CORE_XLEN)rs1_dat_ex(
    .clk   	(clk    ),
    .din   	(i_rs1_dat    ),
    .dout  	(rs1_dat_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0]rs2_dat_reg;
gnrl_dffl #(`CORE_XLEN)rs2_dat_ex(
    .clk   	(clk    ),
    .din   	(i_rs2_dat    ),
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

wire [`CORE_RFIDX_WIDTH-1:0]rs1_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rs1_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rs1_idx    ),
    .dout  	(rs1_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_RFIDX_WIDTH-1:0]rs2_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rs2_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rs2_idx    ),
    .dout  	(rs2_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_RFIDX_WIDTH-1:0]rd_idx_reg;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rd_idx_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rd_idx    ),
    .dout  	(rd_idx_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0]imm_reg;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)imm_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_imm    ),
    .dout  	(imm_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_BJ_DEC_INST_WIDTH-1:0]bj_dec_inst_bus_reg;
gnrl_dfflr #(`CORE_BJ_DEC_INST_WIDTH,`CORE_BJ_DEC_INST_WIDTH'b0)bj_dec_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_bj_dec_inst_bus    ),
    .dout  	(bj_dec_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_ALU_INST_WIDTH-1:0]alu_inst_bus_reg;
gnrl_dfflr #(`CORE_ALU_INST_WIDTH,`CORE_ALU_INST_WIDTH'b0)alu_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_alu_inst_bus    ),
    .dout  	(alu_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_LSU_INST_WIDTH-1:0]lsu_inst_bus_reg;
gnrl_dfflr #(`CORE_LSU_INST_WIDTH,`CORE_LSU_INST_WIDTH'b0)lsu_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_inst_bus    ),
    .dout  	(lsu_inst_bus_reg   ),
    .wen   	(pipeline_update    )
);


wire [`CORE_CSR_INST_WIDTH-1:0]csr_inst_bus_reg;
gnrl_dfflr #(`CORE_CSR_INST_WIDTH,`CORE_CSR_INST_WIDTH'b0)csr_inst_bus_ex(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_csr_inst_bus    ),
    .dout  	(csr_inst_bus_reg   ),
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

wire lsu_valid_in_next = pipeline_update | (~lsu_ready_in & lsu_valid_in);
wire lsu_valid_in;
gnrl_dffr u_gnrl_dffr(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(lsu_valid_in_next    ),
    .dout  	(lsu_valid_in   )
);

// output declaration of module core_ex_lsu_dpic_test
wire lsu_valid_out;
wire lsu_ready_in;
wire [7:0] wmask;
wire flag_unalign_write;
wire [`CORE_XLEN-1:0] lsu_result;

core_ex_lsu_dpic_test u_core_ex_lsu_dpic_test(
    .clk                	(clk                 ),
    .rst_n              	(rst_n               ),
    .valid_in               (lsu_valid_in),
    .valid_out          	(lsu_valid_out           ),
    .ready_in           	(lsu_ready_in            ),
    .i_lsu_inst_bus     	(lsu_inst_bus_reg      ),
    .i_mem_addr         	(alu_result          ),
    .i_write_data       	(rs2_dat_reg        ),
    .wmask              	(wmask               ),
    .flag_unalign_write 	(flag_unalign_write  ),
    .read_data          	(lsu_result           )
);


////////////////////////////////////


//commit///////////

wire cmt_pipeline_flush_req_tmp;
wire cmt_mstatus_en;
wire cmt_mcause_en;
wire cmt_mepc_en;
wire [`CORE_XLEN-1:0] cmt_mstatus;
wire [`CORE_XLEN-1:0] cmt_mcause;
wire [`CORE_XLEN-1:0] cmt_mepc;

core_ex_commit u_core_ex_commit(
    .branch_predict     	(branch_predict_reg      ),
    .branch_jump        	(branch_jump         ),
    .pipeline_flush_req 	(cmt_pipeline_flush_req_tmp  ),
    .pc                 	(pc_reg                  ),
    .bj_pc              	(bj_pc               ),
    .flush_pc           	(cmt_flush_pc            ),
    .csr_mstatus_r      	(csr_mstatus_r       ),
    .csr_mtvec_r        	(csr_mtvec_r         ),
    .csr_mcause_r       	(csr_mcause_r        ),
    .csr_mepc_r         	(csr_mepc_r          ),
    .csr_inst_bus       	(csr_inst_bus_reg        ),
    .cmt_mstatus_en     	(cmt_mstatus_en      ),
    .cmt_mcause_en      	(cmt_mcause_en       ),
    .cmt_mepc_en        	(cmt_mepc_en         ),
    .cmt_mstatus        	(cmt_mstatus         ),
    .cmt_mcause         	(cmt_mcause          ),
    .cmt_mepc           	(cmt_mepc            )
);

/////////////////////

//csr alu//////////
wire csr_alu_wr_en;
wire [`CORE_XLEN-1:0] csr_alu_wr_dat;

core_ex_csr_alu u_core_ex_csr_alu(
    .csr_inst_bus   	(csr_inst_bus_reg    ),
    .zimm           	(rs2_idx_reg            ),
    .rs1            	(rs1_dat_reg             ),
    .rd_csr_dat     	(rd_csr_dat      ),
    .csr_alu_wr_en  	(csr_alu_wr_en   ),
    .csr_alu_wr_dat 	(csr_alu_wr_dat  )
);
/////////////

//////csr///////////
wire [11:0]csr_idx  = imm_reg[11:0]; 
// output declaration of module core_ex_csr
wire [`CORE_XLEN-1:0] csr_mstatus_r;
wire [`CORE_XLEN-1:0] csr_mtvec_r;
wire [`CORE_XLEN-1:0] csr_mcause_r;
wire [`CORE_XLEN-1:0] csr_mepc_r;
wire [`CORE_XLEN-1:0] rd_csr_dat;

core_ex_csr u_core_ex_csr(
    .clk            	(clk             ),
    .rst_n          	(rst_n           ),
    .csr_wr_en      	(csr_alu_wr_en       ),
    .csr_idx        	(csr_idx         ),
    .wr_csr_dat     	(csr_alu_wr_dat      ),
    .cmt_mstatus_en 	(cmt_mstatus_en  ),
    .cmt_mcause_en  	(cmt_mcause_en   ),
    .cmt_mepc_en    	(cmt_mepc_en     ),
    .cmt_mstatus    	(cmt_mstatus     ),
    .cmt_mcause     	(cmt_mcause      ),
    .cmt_mepc       	(cmt_mepc        ),
    .csr_mstatus_r  	(csr_mstatus_r   ),
    .csr_mtvec_r    	(csr_mtvec_r     ),
    .csr_mcause_r   	(csr_mcause_r    ),
    .csr_mepc_r     	(csr_mepc_r      ),
    .rd_csr_dat     	(rd_csr_dat      )
);
////////////

// output declaration of module core_ex_wbu
core_ex_wbu u_core_ex_wbu(
    `ifdef DPI_C
    .difftest_end   (difftest_end),
    `endif
    .rd_wen     	(rd_wen_reg      ),
    .lsu_used   	(lsu_used    ),
    .lsu_valid  	(lsu_valid_out   ),
    .alu_result 	(alu_result  ),
    .lsu_result 	(lsu_result  ),
    .wb_en      	(wb_en       ),
    .wb_data    	(wb_data     )
);



wire lsu_used = lsu_inst_bus_reg[`CORE_LSU_INST_LOAD] | lsu_inst_bus_reg[`CORE_LSU_INST_STORE];

///output assign//////
assign wb_idx = rd_idx_reg;

assign rd_idx_ex_forward  = rd_idx_reg;
assign rd_wen_ex_forward = rd_wen_reg;
assign rd_dat_ex_forward  = wb_data;
/////////////////////

endmodule
