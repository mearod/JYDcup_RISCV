`include "core_defines.v"

module core_ex_lsu_test(
    input   clk,
    input   rst_n,

    input   valid_in,
    output  valid_out,
    output  ready_in,

    input   [`CORE_LSU_INST_WIDTH-1:0] i_lsu_inst_bus,

    input   [`CORE_XLEN-1:0] i_mem_addr,
    input   [`CORE_XLEN-1:0] i_write_data,

    output  [`CORE_LSU_WMASK_WIDTH-1:0]wmask,
    output  flag_unalign_write,
    output  [`CORE_XLEN-1:0] read_data,

    output  [`CORE_XLEN-1:0] biu_pmem_addr,
    input   [`CORE_XLEN-1:0] biu_pmem_read,
    output  [`CORE_XLEN-1:0] biu_pmem_write,
    output  biu_pmem_write_en
);

///state machine////
localparam ISU_IDLE = 1'b0;
localparam ISU_WORK = 1'b1;

wire isu_state_nxt;
wire isu_state;
gnrl_dffr #(1,1'b0)isu_state_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(isu_state_nxt    ),
    .dout  	(isu_state   )
);

///next state: 
assign isu_state_nxt = 
    valid_out ? 
        ISU_IDLE:
    ready_in & valid_in & 
    (i_lsu_inst_bus[`CORE_LSU_INST_LOAD] | i_lsu_inst_bus[`CORE_LSU_INST_STORE]) ?
        ISU_WORK:
        isu_state
;
///////////////



/////////align module
reg  [`CORE_XLEN-1:0] read_data_unaligned;
wire [`CORE_XLEN-1:0] write_data_aligned;

core_ex_lsu_align u_core_ex_lsu_align(
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


wire lsu_wen = (isu_state == ISU_WORK) & lsu_inst_bus[`CORE_LSU_INST_STORE];
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
assign read_data_unaligned = biu_data_in;
`endif
////////////////////



//assume it take only 1 tick to access mem in test module.
assign valid_out    = (isu_state == ISU_WORK);
assign ready_in     = (isu_state == ISU_IDLE);



///pipeline reg///
wire [`CORE_LSU_INST_WIDTH-1:0] lsu_inst_bus;
gnrl_dfflr #(`CORE_LSU_INST_WIDTH,`CORE_LSU_INST_WIDTH'b0)lsu_inst_bus_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_inst_bus    ),
    .dout  	(lsu_inst_bus   ),
    .wen   	(ready_in    )
);

wire [`CORE_XLEN-1:0] mem_addr;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)mem_addr_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_mem_addr    ),
    .dout  	(mem_addr   ),
    .wen   	(ready_in    )
);

wire [`CORE_XLEN-1:0] write_data;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)write_data_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_write_data    ),
    .dout  	(write_data   ),
    .wen   	(ready_in    )
);
//////////////

endmodule
