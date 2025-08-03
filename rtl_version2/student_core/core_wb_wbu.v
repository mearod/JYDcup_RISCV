`include "core_defines.v"

module core_wb_wbu(

    input   clk,
    input   rst_n,

    output  difftest_end,

    input   valid_in,
    output  valid_out,
    output  ready_in,
    input   ready_out,

    input   [`CORE_RFIDX_WIDTH-1:0] i_rd_idx,
    input   i_rd_wen,

    input   i_lsu_used,
    input   lsu_valid,


    input   [`CORE_XLEN-1:0] i_alu_result,
    input   [`CORE_XLEN-1:0] i_lsu_result,

    output  wb_en,
    output  [`CORE_XLEN-1:0] wb_data,


    output  [`CORE_RFIDX_WIDTH-1:0] rd_idx_wb_forward,
    output  rd_wen_wb_forward,
    output  [`CORE_XLEN-1:0] rd_dat_wb_forward,

    input   [`CORE_PC_WIDTH-1:0] ls_pc,
    output  [`CORE_PC_WIDTH-1:0] wb_pc
);


//pipeline related////

wire pipeline_update = ((pipeline_state == PIPE_IDLE) & valid_in & ready_in) || 
                        ((pipeline_state == PIPE_COMMITING) & valid_out & ready_out & valid_in & ready_in);

localparam PIPE_IDLE = 1'b0;
localparam PIPE_COMMITING = 1'b1;

wire pipeline_state;
wire pipeline_next_state;

assign pipeline_next_state = (pipeline_state == PIPE_IDLE) ? 
                            (valid_in & ready_in) :
                            ~(valid_out & ready_out & ~(valid_in & ready_in));

assign valid_out = pipeline_state == PIPE_COMMITING ;
assign ready_in = 1'b1;

gnrl_dffr #(1, 1'b0) pipeline_state_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(pipeline_next_state),
    .dout  	(pipeline_state )
);


/////////////////////////



//pipeline regs//////////
wire lsu_used;
gnrl_dfflr #(1,1'b0)lsu_used_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_used    ),
    .dout  	(lsu_used   ),
    .wen   	(pipeline_update    )
);



wire [`CORE_XLEN-1:0] alu_result;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)alu_result_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_alu_result    ),
    .dout  	(alu_result   ),
    .wen   	(pipeline_update    )
);

wire [`CORE_XLEN-1:0] lsu_result;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)lsu_result_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(i_lsu_result    ),
    .dout  	(lsu_result   ),
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

gnrl_dfflr #(`CORE_PC_WIDTH,`CORE_PC_WIDTH'b0)pc_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(ls_pc    ),
    .dout  	(wb_pc   ),
    .wen   	(pipeline_update    )
);

///////////////////////


assign wb_data  = lsu_used ? lsu_result : 
                alu_result;

assign wb_en    = rd_wen & valid_out;


assign difftest_end = valid_out;




assign rd_idx_wb_forward  = rd_idx;
assign rd_wen_wb_forward = rd_wen;
assign rd_dat_wb_forward  = wb_data;
endmodule

