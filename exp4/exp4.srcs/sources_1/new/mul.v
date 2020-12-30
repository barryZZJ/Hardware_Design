`timescale 1ns / 1ps

module mul#(WIDTH = 32)
           (input [WIDTH-1:0] a,
            input [WIDTH-1:0] b,
            input [7:0] op, // 判断是否有符号
            output reg [WIDTH*2-1:0] res
            );

wire [WIDTH-1:0] nega, negb;
assign nega = -a;
assign negb = -b;

always @(*) begin
    if (op == `EXE_MULTU_OP) 
        // 无符号
        res <= a * b;
    else if (op == `EXE_MULT_OP) begin
        // 有符号
        if (!a[31] & !b[31])
            res <= nega * negb;
        else if (a[31] & !b[31])
            res <= -(a * negb);
        else if (!a[31] & b[31])
            res <= -(nega * negb);
        else
            res <= a * b;
    end
end

endmodule
