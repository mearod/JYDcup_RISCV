`include "core_defines.v"

module core_ex_lsu_align (
    input   [`CORE_LSU_INST_WIDTH-1:0] lsu_inst_bus,
    input   [1:0] low_addr,

    input   [`CORE_XLEN-1:0] i_read_data,
    input   [`CORE_XLEN-1:0] i_write_data,

    output  [`CORE_XLEN-1:0] read_data_aligned,
    output  [`CORE_XLEN-1:0] write_data_aligned,
    output  [`CORE_LSU_WMASK_WIDTH-1:0] wmask,
    output  flag_unalign_write
); //to do: set flag for non-aligned mem access 

/////wirte align
wire [`CORE_XLEN-1:0]addr00_aligned = i_write_data;
wire [`CORE_XLEN-1:0]addr01_aligned = {i_write_data[23:0],8'b0};
wire [`CORE_XLEN-1:0]addr10_aligned = {i_write_data[15:0],16'b0};
wire [`CORE_XLEN-1:0]addr11_aligned = {i_write_data[7:0],24'b0};
/////////

/////read align
wire [`CORE_XLEN-1:0]lb_aligned   = {{24{i_read_data[7]}},i_read_data[7:0]};
wire [`CORE_XLEN-1:0]lh_aligned   = {{16{i_read_data[15]}},i_read_data[15:0]};
wire [`CORE_XLEN-1:0]lw_aligned   = i_read_data;
wire [`CORE_XLEN-1:0]lbu_aligned  = {24'b0,i_read_data[7:0]};
wire [`CORE_XLEN-1:0]lhu_aligned  = {16'b0,i_read_data[15:0]};
//////////

////low addr reuse signal
wire low_addr_00 = low_addr[1:0] == 2'b00;
wire low_addr_01 = low_addr[1:0] == 2'b01;
wire low_addr_10 = low_addr[1:0] == 2'b10;
wire low_addr_11 = low_addr[1:0] == 2'b11;
////////////////////////

////wmask align
wire wmask_1111 = lsu_inst_bus[`CORE_LSU_INST_W];
wire wmask_0011 = lsu_inst_bus[`CORE_LSU_INST_H] & low_addr_00;
wire wmask_1100 = lsu_inst_bus[`CORE_LSU_INST_H] & low_addr_10;
wire wmask_0001 = lsu_inst_bus[`CORE_LSU_INST_B] & low_addr_00;
wire wmask_0010 = lsu_inst_bus[`CORE_LSU_INST_B] & low_addr_01;
wire wmask_0100 = lsu_inst_bus[`CORE_LSU_INST_B] & low_addr_10;
wire wmask_1000 = lsu_inst_bus[`CORE_LSU_INST_B] & low_addr_11;
////////

///flag_unalign_write
assign flag_unalign_write = ~(wmask_1111 | wmask_0011 | wmask_1100 | wmask_0001 | wmask_0010 | wmask_0100 | wmask_1000);
/////

//output assign
assign wmask = 
      ({`CORE_LSU_WMASK_WIDTH{wmask_1111}} & `CORE_LSU_WMASK_WIDTH'b1111)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_0011}} & `CORE_LSU_WMASK_WIDTH'b0011)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_1100}} & `CORE_LSU_WMASK_WIDTH'b1100)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_0001}} & `CORE_LSU_WMASK_WIDTH'b0001)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_0010}} & `CORE_LSU_WMASK_WIDTH'b0010)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_0100}} & `CORE_LSU_WMASK_WIDTH'b0100)
    | ({`CORE_LSU_WMASK_WIDTH{wmask_1000}} & `CORE_LSU_WMASK_WIDTH'b1000)
;
////////////


assign write_data_aligned  =
      ({`CORE_XLEN{low_addr_00}} & addr00_aligned)
    | ({`CORE_XLEN{low_addr_01}} & addr01_aligned)
    | ({`CORE_XLEN{low_addr_10}} & addr10_aligned)
    | ({`CORE_XLEN{low_addr_11}} & addr11_aligned)
;

assign read_data_aligned  = lsu_inst_bus[`CORE_LSU_INST_LU] ? 
(
      ({`CORE_XLEN{lsu_inst_bus[`CORE_LSU_INST_B]}} & lbu_aligned)
    | ({`CORE_XLEN{lsu_inst_bus[`CORE_LSU_INST_H]}} & lhu_aligned)
)
:
(
      ({`CORE_XLEN{lsu_inst_bus[`CORE_LSU_INST_B]}} & lb_aligned)
    | ({`CORE_XLEN{lsu_inst_bus[`CORE_LSU_INST_H]}} & lh_aligned)
    | ({`CORE_XLEN{lsu_inst_bus[`CORE_LSU_INST_W]}} & lw_aligned)
);
//////////

endmodule