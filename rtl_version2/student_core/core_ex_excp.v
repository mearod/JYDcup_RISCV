`include "core_defines.v"

module core_ex_excp(
    input   [`CORE_PC_WIDTH-1:0] current_pc,
    input   excp_ebreak,
    input   excp_ecall,

    output   cmt_mstatus_en,
    output   cmt_mcause_en,
    output   cmt_mepc_en,
    output  [`CORE_XLEN-1:0] cmt_mstatus,
    output  [`CORE_XLEN-1:0] cmt_mcause,
    output  [`CORE_XLEN-1:0] cmt_mepc,

    output  irq_flush_req
);

assign  cmt_mstatus_en  = 0;
assign  cmt_mcause_en   = excp_ecall;
assign  cmt_mepc_en     = excp_ecall;

assign  cmt_mstatus     = excp_ecall ? 0 : 0; //to do
assign  cmt_mcause      = excp_ecall ? 32'd11 : 0;
assign  cmt_mepc        = excp_ecall ? current_pc : 0;

assign  irq_flush_req   = excp_ecall;

endmodule