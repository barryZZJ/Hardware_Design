`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [7:0] op,
             output[WIDTH-1:0] res,
             output zero);
// ! 在这里添加
always @(*) begin
    case (op)
        // 逻辑运算指令
        `EXE_AND_OP : res = a & b;
        `EXE_OR_OP  : res = a | b;
        `EXE_XOR_OP : res = a ^ b;
        `EXE_NOR_OP : res = ~(a | b);
        `EXE_ANDI_OP: res = a & b;
        `EXE_XORI_OP: res = a ^ b;
        // 将 16 位立即数 imm 写入寄存器 rt 的高 16 位，寄存器 rt 的低 16 位置 0
        `EXE_LUI_OP : res = {b[15:0], 16'b0};
        `EXE_ORI_OP : res = a | b;

        `EXE_ADD_OP : res = a + b;
        `EXE_SUB_OP : res = a - b;
        `EXE_SLT_OP : res = (a<b) ? 1 : 0;
        default: 
            res = 8'b0;
    endcase
end

assign zero = ((a-b) == 0);
    
endmodule
