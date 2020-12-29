`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [7:0] op,
             output[WIDTH-1:0] res,
             output zero);
    
assign res = (op == `EXE_AND_OP) ? a & b:
             (op == `EXE_OR_OP) ? a | b:
             (op == `EXE_ADD_OP) ? a + b:
             (op == `EXE_SUB_OP) ? a - b:
             (op == `EXE_SLT_OP) ? (a<b) ? 1 : 0 :
             8'b0;

assign zero = ((a-b) == 0);
    
endmodule
