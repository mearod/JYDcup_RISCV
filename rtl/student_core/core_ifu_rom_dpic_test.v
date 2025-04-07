`include "core_defines.v"

module core_ifu_rom_dpic_test(
    input   [`CORE_PC_WIDTH-1:0] pc,
    output  [`CORE_INST_WIDTH-1:0] inst
);

/////////DPI_C:for verilator test
`ifdef DPI_C
always @(*)begin
        inst = pmem_read(pc);
end
`endif
////////////////////

endmodule