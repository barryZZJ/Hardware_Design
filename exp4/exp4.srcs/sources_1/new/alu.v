`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [4:0] sa,
             input [7:0] op,
             output reg [WIDTH-1:0] res,
             output zero);
    always @(*) begin
        case(op)
            `EXE_AND_OP : res <= a & b;
            `EXE_OR_OP  : res <= a | b;
            `EXE_ADD_OP : res <= a + b;
            `EXE_SUB_OP : res <= a - b;
            `EXE_SLT_OP : res <= (a<b) ? 1 : 0;

            /////////////////////////////////////
            ///             移位指令            //
            /////////////////////////////////////
            // 操作数 sa:shamt b:rt
            // sxx rd,rt,shamt
            // 逻辑移位，空位填零
            // sll
            `EXE_SLL_OP : res <= b << sa;
            // srl
            `EXE_SRL_OP : res <= b >> sa;
            // 算术右移，空位填符号位
            // sra
            `EXE_SRA_OP : begin
                // equals : res =  ({b, 1'b0} << ~sa) | (b >> sa) ;
                res = ({32{b[31]}} << (6'd32 - {1'b0, sa})) | (b >> sa) ;
            end
            // 操作数 a:rs b:rt
            // sxxv rd,rs,rt
            // sllv
            `EXE_SLLV_OP: res <= b << a[4:0];
            // srlv
            `EXE_SRLV_OP: res <= b >> a[4:0];
            // srav
            `EXE_SRAV_OP: begin
                res = ({32{b[31]}} << (6'd32 - {1'b0, a[4:0]})) | (b >> a[4:0]) ;
            end
            ////////////////////////////////////////
            //              分支跳转指令            //
            ////////////////////////////////////////
            // jr
            // jalr
            // j
            // jal
            // beq
            // bgtz
            // blez
            // bne
            // bltz
            // bltzal
            // bgez
            // bgezal

            default: begin
                res <= 8'b0000_0000;
            end

        endcase
    end
/*assign res = (op == `EXE_AND_OP) ? a & b:
             (op == `EXE_OR_OP) ? a | b:
             (op == `EXE_ADD_OP) ? a + b:
             (op == `EXE_SUB_OP) ? a - b:
             (op == `EXE_SLT_OP) ? (a<b) ? 1 : 0 :
             8'b0;
*/
assign zero = ((a-b) == 0);
    
endmodule
