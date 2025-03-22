//load_enable,rst_n dff
module gnrl_dfflr #(
    WIDTH = 1,
    RESET_VAL = 0
) (
    input     clk,
    input     rst_n,

    input     [WIDTH-1:0] din,
    output    [WIDTH-1:0] dout,
    input     wen
);

always @(posedge clk or negedge rst_n) 
begin:
    if (rst_n == 1'b0) 
        dout <= RESET_VAL;
    else if (wen == 1'b1)
        dout <= din;
end

endmodule

//load_enable dff
module gnrl_dffl #(
    WIDTH = 1
) (
    input     clk,
    
    input     [WIDTH-1:0] din,
    output    [WIDTH-1:0] dout,
    input     wen
);

always @(posedge clk) 
begin:
    if (wen == 1'b1)
        dout <= din;
end

endmodule

//rst_n dff
module gnrl_dffr #(
    WIDTH = 1,
    RESET_VAL = 0
) (
    input     clk,
    input     rst_n,
    
    input     [WIDTH-1:0] din,
    output    [WIDTH-1:0] dout,
);

always @(posedge clk or negedge rst_n) 
begin:
    if (rst_n == 1'b0) 
        dout <= RESET_VAL;
    else
        dout <= din;
end

endmodule