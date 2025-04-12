`include "core_defines.v"

module core_ex_wbu(
    `ifdef DPI_C
        output difftest_end,
    `endif

    input   rd_wen,

    input   lsu_used,
    input   lsu_valid,

    input   csr_alu_wr_en,

    input   [`CORE_XLEN-1:0] alu_result,
    input   [`CORE_XLEN-1:0] lsu_result,
    input   [`CORE_XLEN-1:0] csr_alu_result,

    output  wb_en,
    output  [`CORE_XLEN-1:0] wb_data
);

assign wb_data  = lsu_used ? lsu_result : 
                csr_alu_wr_en ? csr_alu_result : 
                alu_result;

assign wb_en    = (lsu_used ? lsu_valid : 1'b1) & rd_wen;

`ifdef DPI_C
assign difftest_end = lsu_used ? lsu_valid : 1'b1;
`endif
endmodule