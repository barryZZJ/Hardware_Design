`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [4:0] sa,
             input [7:0] op,
             output reg [WIDTH-1:0] res,
             output overflow, //算术运算溢出
             output zero);
// ! 在这里添加
wire [WIDTH-1:0] negb; //用于计算溢出
assign negb = -b;

assign overflow = (op == `EXE_ADD_OP | op == `EXE_ADDI_OP) & (a[31] & b[31] & ~res[31] | ~a[31] & ~b[31] & res[31]) |
                  op == `EXE_SUB_OP & (a[31] & !b[31] & !res[31] | !a[31] & b[31] & res[31]);

always @(*) begin
    case (op)
        // 逻辑运算指令
        `EXE_AND_OP : res <= a & b;
        `EXE_OR_OP  : res <= a | b;
        `EXE_XOR_OP : res <= a ^ b;
        `EXE_NOR_OP : res <= ~(a | b);
        `EXE_ANDI_OP: res <= a & b;
        `EXE_XORI_OP: res <= a ^ b;
        // 将 16 位立即数 imm 写入寄存器 rt 的高 16 位，寄存器 rt 的低 16 位置 0
        `EXE_LUI_OP : res <= {b[15:0], 16'b0};
        `EXE_ORI_OP : res <= a | b;

        // 数据移动指令
        `EXE_MFHI_OP: res <= a + b;
        `EXE_MFLO_OP: res <= a + b;
        // 存hilo寄存器不用其他计算
        `EXE_MTHI_OP : res <= 32'b0;
        `EXE_MTLO_OP : res <= 32'b0;

        ////////////////////////////////////////
        //
        // 移位指令
        //
        ////////////////////////////////////////
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
        //
        // 分支跳转指令
        //
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

        // 算术运算指令
        // + - 是无符号，但是结果有符号
        //考虑溢出情况：有符号加法
        `EXE_ADD_OP:   res <= a + b;
        `EXE_ADDU_OP:  res <= a + b; //无符号加法
        //考虑溢出情况，有符号减法
        `EXE_SUB_OP:   res <= a - b;
        //无符号减法
        `EXE_SUBU_OP:  res <= a - b;
        
        // > < 是无符号判断
        // 有符号置位
        `EXE_SLT_OP :  res <=  a[31] & !b[31] ? 1 : // a[31]: a<0
                              !a[31] &  b[31] ? 0 :
                               a < b;
        // 无符号
        `EXE_SLTU_OP:  res <= (a < b) ? 1 : 0;


        //有符号乘法



        `EXE_ADDI_OP:  res <= a + b;
        `EXE_ADDIU_OP: res <= a + b;
        `EXE_SLTI_OP:  res <=  a[31] & !b[31] ? 1 :
                              !a[31] &  b[31] ? 0 :
                               a < b;
        `EXE_SLTIU_OP: res <= (a < b) ? 1 : 0;


        ////////////////////////////////////////
        //
        // 移位指令
        //
        ////////////////////////////////////////
        // 操作量 sa:shamt b:rt
        // sxx rd,rt,shamt
        // 逻辑移位，空位填量
        // sll
        `EXE_SLL_OP : res <= b << sa;
        // srl
        `EXE_SRL_OP : res <= b >> sa;
        // 算术右移，空位填符号量
        // sra
        `EXE_SRA_OP :
            // equals : res =  ({b, 1'b0} << ~sa) | (b >> sa) ;
            res = ({32{b[31]}} << (6'd32 - {1'b0, sa})) | (b >> sa) ;
        
        // 操作量 a:rs b:rt
        // sxxv rd,rs,rt
        // sllv
        `EXE_SLLV_OP: res <= b << a[4:0];
        // srlv
        `EXE_SRLV_OP: res <= b >> a[4:0];
        // srav
        `EXE_SRAV_OP: 
            res <= ({32{b[31]}} << (6'd32 - {1'b0, a[4:0]})) | (b >> a[4:0]) ;
        

        ///////////
        //访存指令//
        ////////////
        `EXE_LB_OP : res <= a + b;
        `EXE_LBU_OP: res <= a + b;
        `EXE_LH_OP : res <= a + b;
        `EXE_LHU_OP: res <= a + b;
        `EXE_LW_OP : res <= a + b;
        `EXE_SW_OP : res <= a + b;      
        `EXE_SB_OP : res <= a + b;
        `EXE_SH_OP : res <= a + b;
        
        ////////////////////////////////////////
        //
        // 分支跳转指令
        //
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



        default: res <= 32'b0;
    endcase
end

assign zero = ((a-b) == 0);
    
endmodule
