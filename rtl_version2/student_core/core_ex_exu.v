`include "core_defines.v"

module core_ex_exu(
    output difftest_end,

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

    output  [`CORE_LSU_INST_WIDTH-1:0] lsu_inst_bus,
    output  [`CORE_XLEN-1:0] exu_result,
    output  [`CORE_XLEN-1:0] rs2_dat,
    output  rd_wen,

    output  [`CORE_RFIDX_WIDTH-1:0] rd_idx_ex_forward,
    output  rd_wen_ex_forward,
    output  [`CORE_XLEN-1:0] rd_dat_ex_forward,


    output  rv_ebreak_sim
);



assign rv_ebreak_sim = csr_inst_bus_reg[`CORE_CSR_INST_EBREAK];

//pipeline related////
wire pipeline_update = valid_in & ready_in;
wire valid_out_next  = valid_in & (~cmt_pipeline_flush_req) & ~load_used_wait_next_state;


assign ready_in      = (ready_out | ~valid_out) & 
                        (~flag_load_used | (~load_used_wait_next_state & load_used_wait_state));


gnrl_dffr #(1, 1'b0) exu_valid_out(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(valid_out_next),
    .dout  	(valid_out )
);

//load used related state machine
wire load_used_wait_state;
wire load_used_wait_next_state;
gnrl_dffr #(1, 1'b0) exu_load_used_wait_state(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(load_used_wait_next_state),
    .dout  	(load_used_wait_state )
);

wire    flag_load_used =           lsu_inst_bus_reg[`CORE_LSU_INST_LOAD] 
                                & (rd_idx_ex_forward == i_rs1_idx | rd_idx_ex_forward == i_rs2_idx)
                                & rd_wen;

assign  load_used_wait_next_state = load_used_wait_state ?
                                    ~ready_out : 
                                    flag_load_used;

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




///output assign//////
assign lsu_inst_bus = lsu_inst_bus_reg;
assign exu_result = csr_alu_wr_en ? csr_alu_wr_dat : alu_result;
assign rs2_dat = rs2_dat_reg;

assign cmt_pipeline_flush_req = cmt_pipeline_flush_req_tmp & valid_out;

assign rd_wen = rd_wen_reg;
assign rd_idx_ex_forward  = rd_idx_reg;
assign rd_wen_ex_forward = rd_wen_reg & ~lsu_inst_bus_reg[`CORE_LSU_INST_LOAD] & valid_out; //if load is used, rd_wen_ex_forward is invalid.
assign rd_dat_ex_forward  = exu_result;
/////////////////////

endmodule
