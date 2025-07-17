`include "core_defines.v"
//`include "../general/gnrl_dffs.v"
module core_id_regfile(
    input   clk,
    input   rst_n,

    input   [`CORE_RFIDX_WIDTH-1:0] rd_src1_idx,
    input   [`CORE_RFIDX_WIDTH-1:0] rd_src2_idx,
    output  [`CORE_XLEN-1:0] read_src1_dat,
    output  [`CORE_XLEN-1:0] read_src2_dat,

    input   wb_dest_wen,
    input   [`CORE_RFIDX_WIDTH-1:0] wb_dest_idx,
    input   [`CORE_XLEN-1:0] wb_dest_dat
);

wire [`CORE_XLEN-1:0] rf_r [`CORE_RF_NUM-1:0];
wire [`CORE_RF_NUM-1:0] rf_wen;

genvar i;
generate
    for (i=0;i<`CORE_RF_NUM;i=i+1) begin:regfile
        if(i == 0) begin:rf0 //rf0:unable to write,always 0.
            assign rf_wen[i] = 1'b0;
            assign rf_r[i] = `CORE_XLEN'b0;
        end
        else begin:rfno0
            assign rf_wen[i] = wb_dest_wen & (wb_dest_idx == i);
            gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'h0)rf(
                .clk   	(clk    ),
                .rst_n 	(rst_n  ),
                .din   	(wb_dest_dat    ),
                .dout  	(rf_r[i]   ),
                .wen   	(rf_wen[i]    )
            );
        end
    end
endgenerate

assign read_src1_dat = rf_r[rd_src1_idx];
assign read_src2_dat = rf_r[rd_src2_idx];

endmodule