`include "core_defines.v"

module core_ex_csr_alu(
    input   [`CORE_CSR_INST_WIDTH-1:0] csr_inst_bus,

    input   [4:0] zimm,
    input   [`CORE_XLEN-1:0] rs1,

    input   [`CORE_XLEN-1:0] rd_csr_dat,

    output  csr_alu_wr_en,
    output  [`CORE_XLEN-1:0] csr_alu_wr_dat
);

wire [`CORE_XLEN-1:0]zimm_ext   = {27'b0,zimm};

wire [`CORE_XLEN-1:0]op = csr_inst_bus[`CORE_CSR_INST_ZIMM] ? zimm_ext :
                        rs1 ;

assign csr_alu_wr_dat   = csr_inst_bus[`CORE_CSR_INST_W] ? op :
                        csr_inst_bus[`CORE_CSR_INST_C_S] ?
                        rd_csr_dat & ~op : rd_csr_dat | op
                        ;
                    

assign csr_alu_wr_en    = csr_inst_bus[`CORE_CSR_INST_R]
                        | csr_inst_bus[`CORE_CSR_INST_W]
                        ;


endmodule