module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [2:0] op,
             output[WIDTH-1:0] res,
             output zero);
    
assign res = (op == 3'b000) ? a & b:
             (op == 3'b001) ? a | b:
             (op == 3'b010) ? a + b:
             (op == 3'b110) ? a - b:
             (op == 3'b111) ? (a<b) ? 1 : 0 :
             8'b0; // 未使用端口默认输出0

assign zero = ((a-b) == 0);
    
endmodule
