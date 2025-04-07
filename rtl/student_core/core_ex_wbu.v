`include "core_defines.v"

module core_ex_wbu(
    input   rd_wen,

    input   lsu_used,
    input   lsu_valid,

    input   [`CORE_XLEN-1:0] alu_result,
    input   [`CORE_XLEN-1:0] lsu_result,

    output  wb_en,
    output  [`CORE_XLEN-1:0] wb_data
);

assign wb_data  = lsu_used ? lsu_result : alu_result;

assign wb_en    = (lsu_used ? lsu_valid : 1'b1) & rd_wen;

endmodule