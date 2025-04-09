`include "core_defines.v"

module core_if_pre_decode(
    input   [`CORE_INST_WIDTH-1:0] i_inst,

    output  flag_jal,
    output  flag_jalr,
    output  flag_branch,
    output  [`CORE_XLEN-1:0] bj_imm
);

wire [6:0]opcode  = i_inst[6:0];

//opcode classify ///////////
wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

assign flag_jal     = (opcode[6:2] == 5'b11011) & opcode_1_0_11;
assign flag_jalr    = (opcode[6:2] == 5'b11001) & opcode_1_0_11;
assign flag_branch  = (opcode[6:2] == 5'b11000) & opcode_1_0_11;
/////////////


//imm decode
wire [`CORE_XLEN-1:0] imm_i = {{20{i_inst[31]}},i_inst[31:20]};
wire [`CORE_XLEN-1:0] imm_b = {{20{i_inst[31]}},i_inst[7],i_inst[30:25],i_inst[11:8], 1'b0};
wire [`CORE_XLEN-1:0] imm_j = {{12{i_inst[31]}},i_inst[19:12],i_inst[20],i_inst[30:21], 1'b0};

//imm sel signal
wire sel_imm_i = flag_jalr;
wire sel_imm_b = flag_branch;
wire sel_imm_j = flag_jal;

//final assign
assign bj_imm = 
      ({32{sel_imm_i}} & imm_i) 
    | ({32{sel_imm_b}} & imm_b)
    | ({32{sel_imm_j}} & imm_j) ;

endmodule