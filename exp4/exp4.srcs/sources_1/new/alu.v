`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [7:0] op,
             output[WIDTH-1:0] res,
             output zero);
// ! ���������
always @(*) begin
    case (op)
        // �߼�����ָ��
        `EXE_AND_OP : res = a & b;
        `EXE_OR_OP  : res = a | b;
        `EXE_XOR_OP : res = a ^ b;
        `EXE_NOR_OP : res = ~(a | b);
        `EXE_ANDI_OP: res = a & b;
        `EXE_XORI_OP: res = a ^ b;
        // �� 16 λ������ imm д��Ĵ��� rt �ĸ� 16 λ���Ĵ��� rt �ĵ� 16 λ�� 0
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
