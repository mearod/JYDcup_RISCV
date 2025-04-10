`include "core_defines.v"

module core_ex_alu(
    input   [`CORE_ALU_INST_WIDTH-1:0] alu_inst_bus,

    input   [`CORE_XLEN-1:0] rs1,
    input   [`CORE_XLEN-1:0] rs2,
    input   [`CORE_XLEN-1:0] pc,
    input   [`CORE_XLEN-1:0] imm,    

    output  zero_flag,
    output  less_flag,
    output  [`CORE_XLEN-1:0] alu_result
);

//op select///
wire [`CORE_XLEN-1:0] op1 = alu_inst_bus[`CORE_ALU_INST_OP1_PC] ? pc : 
                            alu_inst_bus[`CORE_ALU_INST_OP1_0] ? 0 :
                            rs1;
wire [`CORE_XLEN-1:0] op2 = alu_inst_bus[`CORE_ALU_INST_OP2_IMM] ? imm :
                            alu_inst_bus[`CORE_ALU_INST_OP1_PC] ? `CORE_XLEN'h4 : rs2;
/////////////


//comparetor//
wire low_comp = op1[`CORE_XLEN-2:0] < op2[`CORE_XLEN-2:0]; 

wire signed_comp_less = 
    ( (~(op1[`CORE_XLEN-1]^op2[`CORE_XLEN-1])) & low_comp) | (op1[`CORE_XLEN-1] & ~op2[`CORE_XLEN-1]);

wire unsigned_comp_less = 
    ( (~(op1[`CORE_XLEN-1]^op2[`CORE_XLEN-1])) & low_comp) | (~op1[`CORE_XLEN-1] & op2[`CORE_XLEN-1]);
///////////


/////adder//
wire sub_flag = alu_inst_bus[`CORE_ALU_INST_SUB];
wire [`CORE_XLEN-1:0] op2_xor_mask = {`CORE_XLEN{sub_flag}};
wire [`CORE_XLEN-1:0] op2_modified = op2 ^ op2_xor_mask;
wire [`CORE_XLEN-1:0]adder_result = op1 + op2_modified + {{(`CORE_XLEN-1){1'b0}},sub_flag};
/////////


//////shifter/////
wire [4:0]shamt = op2[4:0];
wire [`CORE_XLEN-1:0]L_L_shift  = op1 << shamt;
wire [`CORE_XLEN-1:0]R_L_shift  = op1 >> shamt;
wire [`CORE_XLEN-1:0]R_A_shift  = $signed(op1) >>> shamt;
/////////////


////logic////
wire [`CORE_XLEN-1:0]or_result  = op1 | op2;
wire [`CORE_XLEN-1:0]and_result = op1 & op2;
wire [`CORE_XLEN-1:0]xor_result = op1 ^ op2;
////////////

///alu result mux
assign alu_result = 
      ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_ADD] | alu_inst_bus[`CORE_ALU_INST_SUB]}} & adder_result) 
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_CMP]}} & {{(`CORE_XLEN-1){1'b0}}, {signed_comp_less}})
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_CMP_U]}} & {{(`CORE_XLEN-1){1'b0}}, {unsigned_comp_less}})
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_SLL]}} & L_L_shift)
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_SRL]}} & R_L_shift)
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_SRA]}} & R_A_shift)
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_OR]}} & or_result)
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_AND]}} & and_result)
    | ({`CORE_XLEN{alu_inst_bus[`CORE_ALU_INST_XOR]}} & xor_result)
    ;

//output assign
assign zero_flag = (op1 == op2);
assign less_flag = alu_inst_bus[`CORE_ALU_INST_CMP_U] ? unsigned_comp_less : signed_comp_less;
///////

endmodule
