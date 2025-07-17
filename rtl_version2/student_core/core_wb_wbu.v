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
    output  [`CORE_XLEN-1:0] rd_dat_wb_forward
);


//pipeline related////
wire pipeline_update = valid_in & ready_in;

wire valid_out_next  = valid_in;

assign ready_in      = 1'b1 ;

gnrl_dffr #(1, 1'b0) idu_valid_out(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(valid_out_next),
    .dout  	(valid_out )
);


/////////////////////



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
///////////////////////


assign wb_data  = lsu_used ? lsu_result : 
                alu_result;

assign wb_en    = rd_wen & valid_out;


assign difftest_end = valid_out;




assign rd_idx_wb_forward  = rd_idx;
assign rd_wen_wb_forward = rd_wen;
assign rd_dat_wb_forward  = wb_data;
endmodule

