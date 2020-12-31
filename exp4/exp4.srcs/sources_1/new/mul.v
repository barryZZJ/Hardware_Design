`timescale 1ns / 1ps
`include "defines.vh"
module mul#(WIDTH = 32)
           (input [WIDTH-1:0] a,
            input [WIDTH-1:0] b,
            input [7:0] op, // 判断是否有符号
            output reg [WIDTH*2-1:0] res
            );

// TODO 是否需要改进成IP核？
wire [WIDTH-1:0] nega, negb;
assign nega = -a;
assign negb = -b;

always @(*) begin
    if (op == `EXE_MULTU_OP) 
        // 无符号
        res <= a * b;
    else if (op == `EXE_MULT_OP) begin
        // 有符号
        if (a[31] == 1'b1 & b[31] == 1'b1)
            // a负，b负
            res <= nega * negb;
        else if (a[31] == 1'b0 & b[31] == 1'b1)
            // a正，b负
            res <= -(a * negb);
        else if (a[31] == 1'b1 & b[31] == 1'b0)
            // a负，b正
            res <= -(nega * b);
        else
            // a正，b正
            res <= a * b;
    end else begin
        res <= 64'bx;
    end
end

endmodule
