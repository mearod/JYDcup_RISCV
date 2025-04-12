`include "core_defines.v"

module core_ex_csr(
    input   clk,
    input   rst_n,

    input   csr_wr_en,
    input   [11:0] csr_idx,
    input   [`CORE_XLEN-1:0] wr_csr_dat,

    input   cmt_mstatus_en,
    input   cmt_mcause_en,
    input   cmt_mepc_en,
    input   [`CORE_XLEN-1:0] cmt_mstatus,
    input   [`CORE_XLEN-1:0] cmt_mcause,
    input   [`CORE_XLEN-1:0] cmt_mepc,

    output   [`CORE_XLEN-1:0] csr_mstatus_r,
    output   [`CORE_XLEN-1:0] csr_mtvec_r,
    output   [`CORE_XLEN-1:0] csr_mcause_r,
    output   [`CORE_XLEN-1:0] csr_mepc_r,

    output  [`CORE_XLEN-1:0] rd_csr_dat
);

wire rd_mstatus     = (csr_idx == 12'h300);
wire rd_mtvec       = (csr_idx == 12'h305);
wire rd_mepc        = (csr_idx == 12'h341);
wire rd_mcause      = (csr_idx == 12'h342);
wire rd_mvendorid   = (csr_idx == 12'hF11);
wire rd_marchid     = (csr_idx == 12'hF12);

assign rd_csr_dat   = `CORE_XLEN'b0
                    | ({`CORE_XLEN{rd_mstatus   }} & csr_mstatus)
                    | ({`CORE_XLEN{rd_mtvec     }} & csr_mtvec)
                    | ({`CORE_XLEN{rd_mepc      }} & csr_mepc)
                    | ({`CORE_XLEN{rd_mcause    }} & csr_mcause)
                    | ({`CORE_XLEN{rd_mvendorid }} & csr_mvendorid)
                    | ({`CORE_XLEN{rd_marchid   }} & csr_marchid)
                    ;

//csr regs////
wire [`CORE_XLEN-1:0] csr_mstatus;
wire [`CORE_XLEN-1:0]csr_mstatus_next   = cmt_mstatus_en ? cmt_mstatus : wr_csr_dat;
wire csr_mstatus_wr_en  = rd_mstatus & csr_wr_en | cmt_mstatus_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_mstatus_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(csr_mstatus_next    ),
    .dout  	(csr_mstatus   ),
    .wen   	(csr_mstatus_wr_en    )
);

wire [`CORE_XLEN-1:0] csr_mtvec;
wire csr_mtvec_wr_en = rd_mtvec & csr_wr_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_mtvec_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(wr_csr_dat    ),
    .dout  	(csr_mtvec   ),
    .wen   	(csr_mtvec_wr_en    )
);

wire [`CORE_XLEN-1:0] csr_mepc;
wire [`CORE_XLEN-1:0]csr_mepc_next   = cmt_mepc_en ? cmt_mepc : wr_csr_dat;
wire csr_mepc_wr_en = rd_mepc & csr_wr_en | cmt_mepc_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_mepc_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(csr_mepc_next    ),
    .dout  	(csr_mepc   ),
    .wen   	(csr_mepc_wr_en    )
);

wire [`CORE_XLEN-1:0] csr_mcause;
wire [`CORE_XLEN-1:0]csr_mcause_next   = cmt_mcause_en ? cmt_mcause : wr_csr_dat;
wire csr_mcause_wr_en = rd_mcause & csr_wr_en | cmt_mcause_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_mcause_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(csr_mcause_next    ),
    .dout  	(csr_mcause   ),
    .wen   	(csr_mcause_wr_en    )
);

wire [`CORE_XLEN-1:0] csr_mvendorid;
wire csr_mvendorid_wr_en = rd_mvendorid & csr_wr_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_mvendorid_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(wr_csr_dat    ),
    .dout  	(csr_mvendorid   ),
    .wen   	(csr_mvendorid_wr_en    )
);

wire [`CORE_XLEN-1:0] csr_marchid;
wire csr_marchid_wr_en = rd_marchid & csr_wr_en;
gnrl_dfflr #(`CORE_XLEN,`CORE_XLEN'b0)csr_marchid_reg(
    .clk   	(clk    ),
    .rst_n 	(rst_n  ),
    .din   	(wr_csr_dat    ),
    .dout  	(csr_marchid   ),
    .wen   	(csr_marchid_wr_en    )
);
//////////

assign csr_mstatus_r    = csr_mstatus;
assign csr_mtvec_r      = csr_mtvec;
assign csr_mcause_r     = csr_mcause;
assign csr_mepc_r       = csr_mepc;
endmodule