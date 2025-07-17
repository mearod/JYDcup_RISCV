`include "core_defines.v"


module core_ls_lsu_test(
    input   clk,
    input   rst_n,

    input   valid_in,
    output  valid_out,
    output  ready_in,
    input   ready_out,

    input   [`CORE_LSU_INST_WIDTH-1:0] i_lsu_inst_bus,

    input   [`CORE_XLEN-1:0] i_mem_addr,
    input   [`CORE_XLEN-1:0] i_write_data,

    //csr bypass signals
    input   i_flag_csr_to_reg,
    input   [`CORE_XLEN-1:0] i_csr_alu_result,

    output  [`CORE_LSU_WMASK_WIDTH-1:0]wmask,
    output  flag_unalign_write,
    output  [`CORE_XLEN-1:0] read_data,

    output  [`CORE_XLEN-1:0] biu_pmem_addr,
    input   [`CORE_XLEN-1:0] biu_pmem_read,
    output  [`CORE_XLEN-1:0] biu_pmem_write,
    output  biu_pmem_write_en,

    input   [`CORE_RFIDX_WIDTH-1:0] i_rd_idx,
    input   i_rd_wen,
    output  flag_mem_to_reg,
    output  flag_csr_to_reg,
    output  [`CORE_XLEN-1:0] alu_result,
    output  [`CORE_XLEN-1:0] csr_alu_result,

    output  [`CORE_RFIDX_WIDTH-1:0] rd_idx_ls_forward,
    output  rd_wen_ls_forward,
    output  [`CORE_XLEN-1:0] rd_dat_ls_forward,

    input   ex_ebreak_sim,
    output  ls_ebreak_sim
);

//pipeline related////
wire pipeline_update = valid_in & ready_in;

wire valid_out_next  = valid_in;//no memory access delay

assign ready_in      = (ready_out | ~valid_out) ;

gnrl_dffr #(1, 1'b0) idu_valid_out(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(valid_out_next),
    .dout  	(valid_out )
);

/////////////////////


/////////align module
reg  [`CORE_XLEN-1:0] read_data_unaligned;
wire [`CORE_XLEN-1:0] write_data_aligned;

core_ls_lsu_align u_core_ls_lsu_align(
    .lsu_inst_bus       	(lsu_inst_bus        ),
    .low_addr           	(mem_addr[1:0]            ),
    .i_read_data        	(read_data_unaligned         ),
    .i_write_data       	(write_data        ),
    .read_data_aligned  	(read_data   ),
    .write_data_aligned 	(write_data_aligned  ),
    .wmask                  (wmask),
    .flag_unalign_write     (flag_unalign_write)
);
/////////////////


wire lsu_wen = lsu_inst_bus[`CORE_LSU_INST_STORE];
assign biu_pmem_write_en    = lsu_wen;
assign biu_pmem_addr        = mem_addr;
assign biu_pmem_write       = write_data_aligned;
/////////DPI_C:for verilator test
`ifdef DPI_C

always @(*)begin
    if (lsu_inst_bus[`CORE_LSU_INST_LOAD]) begin 
        read_data_unaligned = pmem_read(mem_addr);
    end
    else begin
        read_data_unaligned = 0;
    end

end

always @(posedge clk) begin
    if (lsu_wen) begin 
        pmem_write(mem_addr, write_data_aligned, wmask);
    end
    else begin
    end
end
`else
assign read_data_unaligned = biu_pmem_read;
`endif
////////////////////







///pipeline reg///
wire [`CORE_LSU_INST_WIDTH-1:0] lsu_inst_bus;
gnrl_dfflr #(`CORE_LSU_INST_WIDTH,`CORE_LSU_INST_WIDTH'b0)lsu_inst_bus_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_inst_bus    ),
    .dout  	(lsu_inst_bus   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0] mem_addr;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)mem_addr_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_mem_addr    ),
    .dout  	(mem_addr   ),
    .wen   	(pipeline_update    )
);

assign alu_result   = mem_addr;

gnrl_dfflr #(1,1'b0)flag_csr_to_reg_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_flag_csr_to_reg    ),
    .dout  	(flag_csr_to_reg   ),
    .wen   	(pipeline_update    )
);

gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_alu_result_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_csr_alu_result    ),
    .dout  	(csr_alu_result   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0] write_data;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)write_data_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_write_data    ),
    .dout  	(write_data   ),
    .wen   	(pipeline_update    )
);

wire rd_wen;
gnrl_dfflr #(1,1'b0)rd_wen_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rd_wen    ),
    .dout  	(rd_wen   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_RFIDX_WIDTH-1:0]rd_idx;
gnrl_dfflr #(`CORE_RFIDX_WIDTH,`CORE_RFIDX_WIDTH'b0)rd_idx_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_rd_idx    ),
    .dout  	(rd_idx   ),
    .wen   	(pipeline_update    )
);


gnrl_dfflr #(1,1'b0)ebreak_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(ex_ebreak_sim    ),
    .dout  	(ls_ebreak_sim   ),
    .wen   	(pipeline_update    )
);
//////////////

assign flag_mem_to_reg = lsu_inst_bus[`CORE_LSU_INST_LOAD];

assign rd_idx_ls_forward  = rd_idx;
assign rd_wen_ls_forward = rd_wen & valid_out;
assign rd_dat_ls_forward  = lsu_inst_bus[`CORE_LSU_INST_LOAD] ? read_data : alu_result;

endmodule
