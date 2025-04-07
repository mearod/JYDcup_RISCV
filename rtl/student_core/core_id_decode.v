`include "core_defines.v"

module core_id_decode(
    input   [`CORE_INST_WIDTH-1:0] i_inst,

    output  o_rs1_ren,
    output  o_rs2_ren,
    output  o_rd_wen,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rs1_idx,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rs2_idx,
    output  [`CORE_RFIDX_WIDTH-1:0] o_rd_idx,

    output  [`CORE_XLEN-1:0] o_imm,

    output  [`CORE_BJ_DEC_INST_WIDTH-1:0] o_bj_dec_inst_bus,
    output  [`CORE_ALU_INST_WIDTH-1:0] o_alu_inst_bus,
    output  [`CORE_LSU_INST_WIDTH-1:0] o_lsu_inst_bus
);

wire opcode  = i_inst[6:0];
wire rs1 = i_inst[19:15];
wire rs2 = i_inst[24:20];
wire rd  = i_inst[11:7];
wire func3  = i_inst[14:12];
wire func7  = i_inst[31:25];

wire func3_000 = (func3 == 3'b000);
wire func3_001 = (func3 == 3'b001);
wire func3_010 = (func3 == 3'b010);
wire func3_011 = (func3 == 3'b011);
wire func3_100 = (func3 == 3'b100);
wire func3_101 = (func3 == 3'b101);
wire func3_110 = (func3 == 3'b110);
wire func3_111 = (func3 == 3'b111);

wire func7_0000000 = (func7 == 7'b0000000);
wire func7_0100000 = (func7 == 7'b0100000);



//opcode classify ///////////
wire opcode_1_0_11  = (opcode[1:0] == 2'b11);

wire opcode_lui     = (opcode[6:2] == 5'b01101) & opcode_1_0_11;
wire opcode_auipc   = (opcode[6:2] == 5'b00101) & opcode_1_0_11;
wire opcode_jal     = (opcode[6:2] == 5'b11011) & opcode_1_0_11;
wire opcode_jalr    = (opcode[6:2] == 5'b11001) & opcode_1_0_11;
wire opcode_branch  = (opcode[6:2] == 5'b11000) & opcode_1_0_11;
wire opcode_load    = (opcode[6:2] == 5'b00000) & opcode_1_0_11;
wire opcode_store   = (opcode[6:2] == 5'b01000) & opcode_1_0_11;
wire opcode_alu_i   = (opcode[6:2] == 5'b00100) & opcode_1_0_11;
wire opcode_alu_r   = (opcode[6:2] == 5'b01100) & opcode_1_0_11;
wire opcode_fence   = (opcode[6:2] == 5'b00011) & opcode_1_0_11;
wire opcode_system  = (opcode[6:2] == 5'b11100) & opcode_1_0_11;
/////////////


//U inst
wire rv_lui    = opcode_lui;
wire rv_auipc  = opcode_auipc;
/////////

//BJ inst
wire rv_jal    = opcode_jal;
wire rv_jalr   = opcode_jalr;

wire rv_beq    = opcode_branch & func3_000;
wire rv_bne    = opcode_branch & func3_001;
wire rv_blt    = opcode_branch & func3_100;
wire rv_bge    = opcode_branch & func3_101;
wire rv_bltu   = opcode_branch & func3_110;
wire rv_bgeu   = opcode_branch & func3_111;
//////////

//LS inst
wire rv_lb     = opcode_load & func3_000;
wire rv_lh     = opcode_load & func3_001;
wire rv_lw     = opcode_load & func3_010;
wire rv_lbu    = opcode_load & func3_100;
wire rv_lhu    = opcode_load & func3_101;

wire rv_sb     = opcode_store & func3_000;
wire rv_sh     = opcode_store & func3_001;
wire rv_sw     = opcode_store & func3_010;
//////////

//AL inst
wire rv_addi   = opcode_alu_i & func3_000;
wire rv_slti   = opcode_alu_i & func3_010;
wire rv_sltiu  = opcode_alu_i & func3_011;
wire rv_xori   = opcode_alu_i & func3_100;
wire rv_ori    = opcode_alu_i & func3_110;
wire rv_andi   = opcode_alu_i & func3_111;
wire rv_slli   = opcode_alu_i & func3_001 & func7_0000000;
wire rv_srli   = opcode_alu_i & func3_101 & func7_0000000;
wire rv_srai   = opcode_alu_i & func3_101 & func7_0100000;

wire rv_add    = opcode_alu_r & func3_000 & func7_0000000;
wire rv_sub    = opcode_alu_r & func3_000 & func7_0100000;
wire rv_sll    = opcode_alu_r & func3_001 & func7_0000000;
wire rv_slt    = opcode_alu_r & func3_010 & func7_0000000;
wire rv_sltu   = opcode_alu_r & func3_011 & func7_0000000;
wire rv_xor    = opcode_alu_r & func3_100 & func7_0000000;
wire rv_srl    = opcode_alu_r & func3_101 & func7_0000000;
wire rv_sra    = opcode_alu_r & func3_101 & func7_0100000;
wire rv_or     = opcode_alu_r & func3_110 & func7_0000000;
wire rv_and    = opcode_alu_r & func3_111 & func7_0000000;
///////////

//system inst
wire rv_fence      = opcode_fence & func3_000;
wire rv_fence_i    = opcode_fence & func3_001;

wire rv_ecall  = opcode_system & (i_inst[31:7] == 32'b0);
wire rv_ebreak = opcode_system & (i_inst[31:7] == 32'b0000000000010000000000000);

wire rv_csrrw  = opcode_system & func3_001;
wire rv_csrrs  = opcode_system & func3_010;
wire rv_csrrc  = opcode_system & func3_011;
wire rv_csrrwi = opcode_system & func3_101;
wire rv_csrrsi = opcode_system & func3_110;
wire rv_csrrci = opcode_system & func3_111;
///////////




//bj_dec inst bj decoder
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_JAL]  = rv_jal;
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_JALR] = rv_jalr;
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_BEQ]  = rv_beq;
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_BNE]  = rv_bne;
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_BLT]  = rv_blt | rv_bltu;
assign o_bj_dec_inst_bus[`CORE_BJ_DEC_INST_BGE]  = rv_bge | rv_bgeu;
////////////

//alu inst
assign o_alu_inst_bus[`CORE_ALU_INST_ADD]     = rv_lui | rv_auipc | rv_jal | rv_jalr | opcode_load | opcode_store | rv_addi | rv_add;
assign o_alu_inst_bus[`CORE_ALU_INST_SUB]     = rv_sub;
assign o_alu_inst_bus[`CORE_ALU_INST_CMP]     = rv_slt | rv_slti | rv_beq | rv_bne | rv_blt | rv_bge;
assign o_alu_inst_bus[`CORE_ALU_INST_CMP_U]   = rv_sltu | rv_sltui | rv_bltu | rv_bgeu;
assign o_alu_inst_bus[`CORE_ALU_INST_XOR]     = rv_xor | xori;
assign o_alu_inst_bus[`CORE_ALU_INST_SLL]     = rv_sll | rv_slli;
assign o_alu_inst_bus[`CORE_ALU_INST_SRL]     = rv_srl | rv_srli;
assign o_alu_inst_bus[`CORE_ALU_INST_SRA]     = rv_sra | rv_srai;
assign o_alu_inst_bus[`CORE_ALU_INST_OR ]     = rv_or  | rv_ori;
assign o_alu_inst_bus[`CORE_ALU_INST_AND]     = rv_and | rv_andi;
assign o_alu_inst_bus[`CORE_ALU_INST_OP1_PC]  = rv_jal | rv_jalr; //is op1 pc?
assign o_alu_inst_bus[`CORE_ALU_INST_OP2_IMM] = need_imm; //is op2 imm?
assign o_alu_inst_bus[`CORE_ALU_INST_RS2ADR]  = rs2; //rs2 address
///////////

//lsu inst
assign o_lsu_inst_bus[`CORE_LSU_INST_LOAD]    = opcode_load;
assign o_lsu_inst_bus[`CORE_LSU_INST_STORE]   = opcode_store;
assign o_lsu_inst_bus[`CORE_LSU_INST_B]       = rv_lb | rv_sb;
assign o_lsu_inst_bus[`CORE_LSU_INST_H]       = rv_lh | rv_sh;
assign o_lsu_inst_bus[`CORE_LSU_INST_W]       = rv_lw | rv_sw;
assign o_lsu_inst_bus[`CORE_LSU_INST_LU]      = rv_lbu | rv_lhu;
///////////

//mul inst:reserve

//imm decode
wire [`CORE_XLEN-1:0] imm_i = {{20{inst[31]}},inst[31:20]};
wire [`CORE_XLEN-1:0] imm_s = {{20{inst[31]}},inst[31:25],inst[11:7]};
wire [`CORE_XLEN-1:0] imm_b = {{20{inst[31]}},inst[7],inst[30:25],inst[11:8], 1'b0};
wire [`CORE_XLEN-1:0] imm_u = {inst[31:12],12'b0};
wire [`CORE_XLEN-1:0] imm_j = {{12{inst[31]}},inst[19:12],inst[20],inst[30:21], 1'b0};

//imm sel signal
wire sel_imm_i = opcode_jalr | opcode_load | opcode_alu_i | opcode_fence | opcode_system;
wire sel_imm_s = opcode_store;
wire sel_imm_b = opcode_branch;
wire sel_imm_u = opcode_lui | opcode_auipc;
wire sel_imm_j = opcode_jal;

//final assign
assign o_imm = 
      ({32{sel_imm_i}} & imm_i) 
    | ({32{sel_imm_s}} & imm_s)
    | ({32{sel_imm_b}} & imm_b)
    | ({32{sel_imm_u}} & imm_u)
    | ({32{sel_imm_j}} & imm_j) ;

wire need_imm = 
    sel_imm_i
    | sel_imm_s
    | sel_imm_b
    | sel_imm_u
    | sel_imm_j;    
//////////////////////////



//rs1,rs2,rd en
assign o_rs1_ren = 1;
assign o_rs2_ren = 1;  //reserve
assign o_rd_wen = opcode_lui | opcode_auipc | opcode_jal | opcode_jalr | opcode_load | opcode_alu_i | opcode_alu_r 
| rv_csrrw | rv_csrrs | rv_csrrc | rv_csrrwi | rv_csrrsi | rv_csrrci; 
////////////

//final assgin
assign o_rs1_idx = rs1;
assign o_rs2_idx = rs2;
assign o_rd_idx = rd;
////

endmodule