`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,
             input [WIDTH-1:0] b,
             input [4:0] sa,
             input [7:0] op,
             input [31:0] writedata,
             
             output reg [WIDTH-1:0] res,
             output reg [3:0] sel,
             output reg [31:0] finalwritedata,
             output [1:0] addr, // 存取地址的后两位
             output overflow, //算术运算溢出
             output reg adel, // 取内存地址错误
             output reg ades, // 存内存地址错误
             output zero);
// ! 在这里添加
wire [WIDTH-1:0] negb; //用于计算溢出
assign negb = -b;

assign overflow = (op == `EXE_ADD_OP | op == `EXE_ADDI_OP) & (a[31] & b[31] & ~res[31] | ~a[31] & ~b[31] & res[31]) |
                  op == `EXE_SUB_OP & (a[31] & !b[31] & !res[31] | !a[31] & b[31] & res[31]);

always @(*) begin
    sel <= 4'b0000;
    finalwritedata <= writedata;
    adel <= 1'b0;
    ades <= 1'b0;
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
        `EXE_LB_OP : begin 
            res  <= a + b;
            sel  <= 4'b0000;
            adel <= 1'b0;
            ades <= 1'b0;
        end
        `EXE_LBU_OP: begin 
            res  <= a + b;
            sel  <= 4'b0000;
            adel <= 1'b0;
            ades <= 1'b0;
        end
        `EXE_LH_OP : begin 
            res  <= a + b;
            sel  <= 4'b0000;
            adel <= (addr[1:0] != 2'b00) & (addr[1:0] != 2'b10);
            ades <= 1'b0;
        end
        `EXE_LHU_OP: begin 
            res  <= a + b;
            sel  <= 4'b0000;
            adel <= (addr[1:0] != 2'b00) & (addr[1:0] != 2'b10);
            ades <= 1'b0;
        end
        `EXE_LW_OP : begin 
            res  <= a + b;
            sel  <= 4'b0000;
            adel <= addr[1:0] != 2'b00;
            ades <= 1'b0;
        end
        `EXE_SB_OP : begin 
            res <= a + b;
            finalwritedata <= {writedata[7:0], writedata[7:0], writedata[7:0], writedata[7:0]};
            adel <= 1'b0;
            ades <= 1'b0;
            case (addr[1:0])
                2'b00 :   sel <= 4'b0001;
                2'b01 :   sel <= 4'b0010;
                2'b10 :   sel <= 4'b0100;
                2'b11 :   sel <= 4'b1000;
                default : sel <= 4'b0000;
            endcase 
        end
        `EXE_SH_OP : begin 
            res <= a + b;
            finalwritedata <= {writedata[15:0], writedata[15:0]};
            adel <= 1'b0;
            ades <= (addr[1:0] != 2'b00) & (addr[1:0] != 2'b10);
            case (addr[1:0])
                2'b00 :   sel <= 4'b0011;
                2'b10 :   sel <= 4'b1100;
                default : sel <= 4'b0000;
            endcase
        end
        `EXE_SW_OP : begin 
            res  <= a + b;      
            finalwritedata <= writedata;
            adel <= 1'b0;
            ades <= addr[1:0] != 2'b00;
            sel  <= 4'b1111;
        end

        // 内陷指令，什么都不做
        `EXE_BREAK_OP:
            res <= 32'b0;
        `EXE_SYSCALL_OP:
            res <= 32'b0;
        
        // eret，什么都不做
        `EXE_ERET_OP:
            res <= 32'b0;

        // 存Cp0寄存器需要reg[rt]，接在b
        `EXE_MTC0_OP:
            res <= b;
        
        // 取Cp0寄存器,cp0_o(或前推的co0_o)接在b，输出后存回寄存器堆reg[rt]
        `EXE_MFC0_OP:
            res <= b;

        `EXE_NOP_OP:
            res <= 32'b0;


        default: begin 
            res <= 32'b0;
            sel <= 4'b0000;
            finalwritedata <= writedata;
            adel <= 1'b0;
            ades <= 1'b0;
        end
    endcase
end


// base+[addr/4] （a + {b[31:2], 2'b0}）找到要读/写的那个字的地址，这个地址可以不是按字对齐，
// addr mod 4的结果（b[1:0]）相当于指定修改这个字里的哪个字节/半字，用这个数得到对应的sel
assign addr = a[1:0]+b[1:0];


assign zero = ((a-b) == 0);
    
endmodule
