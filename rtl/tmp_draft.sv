always @(*) begin
    case(test)
        3'h0:begin
            alu_result = 32'h0;
        end
        3'h1:begin
            alu_result = 32'h1;
        end
        3'h2:begin
            alu_result = 32'h2;
        end
        3'h3:begin
            alu_result = 32'h3;
        end
        default:begin
            alu_result = 32'h4;
        end
    endcase
end


