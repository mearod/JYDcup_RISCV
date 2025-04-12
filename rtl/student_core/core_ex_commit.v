`include "core_defines.v"

module core_ex_commit(
    input   branch_predict,
    input   branch_jump,
    output  pipeline_flush_req,

    input   [`CORE_PC_WIDTH-1:0] pc,
    input   [`CORE_PC_WIDTH-1:0] bj_pc,
    output  [`CORE_PC_WIDTH-1:0] flush_pc,

    //csr read
    input   [`CORE_XLEN-1:0] csr_mstatus_r,
    input   [`CORE_XLEN-1:0] csr_mtvec_r,
    input   [`CORE_XLEN-1:0] csr_mcause_r,
    input   [`CORE_XLEN-1:0] csr_mepc_r,

    //excp cmt
    input   [`CORE_CSR_INST_WIDTH-1:0]csr_inst_bus,
    output  cmt_mstatus_en,
    output  cmt_mcause_en,
    output  cmt_mepc_en,
    output  [`CORE_XLEN-1:0] cmt_mstatus,
    output  [`CORE_XLEN-1:0] cmt_mcause,
    output  [`CORE_XLEN-1:0] cmt_mepc
);

wire ebreak = csr_inst_bus[`CORE_CSR_INST_EBREAK];
wire ecall  = csr_inst_bus[`CORE_CSR_INST_ECALL];
wire mret   = csr_inst_bus[`CORE_CSR_INST_MRET];

assign pipeline_flush_req   = (branch_predict ^ branch_jump) 
                            | irq_flush_req
                            | mret;

assign flush_pc = irq_flush_req ? csr_mtvec_r :
                mret ? csr_mepc_r :
                branch_jump ? bj_pc : (pc + `CORE_PC_WIDTH'h4);

// output declaration of module core_ex_excp
wire irq_flush_req;

core_ex_excp u_core_ex_excp(
    .current_pc     	(pc      ),
    .excp_ebreak    	(ebreak     ),
    .excp_ecall     	(ecall      ),
    .cmt_mstatus_en 	(cmt_mstatus_en  ),
    .cmt_mcause_en  	(cmt_mcause_en   ),
    .cmt_mepc_en    	(cmt_mepc_en     ),
    .cmt_mstatus    	(cmt_mstatus     ),
    .cmt_mcause     	(cmt_mcause      ),
    .cmt_mepc       	(cmt_mepc        ),
    .irq_flush_req  	(irq_flush_req   )
);


endmodule