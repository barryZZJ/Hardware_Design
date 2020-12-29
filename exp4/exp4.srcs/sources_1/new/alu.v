`include "defines.vh"
module alu #(WIDTH = 32)
            (
             input clk,rst,
             input [WIDTH-1:0] a,//操作数1
             input [WIDTH-1:0] b,//操作数2
             input [7:0] op,
             input [4:0] sa,
             input [63:0] hilo_i,//乘除法hilo寄存器：输入
             output reg [63:0] hilo_o,//乘除法hilo寄存器：输出
             output reg [WIDTH-1:0] res,
             output reg overflow,//算术运算溢出
             output wire stall_div,
             output zero);

           //中间变量
           reg [WIDTH-1:0] numa,numb;//考虑溢出情况算术运算，中间变量
           reg [31:0]nresult;//有溢出的算术运算的中间变量结果
           reg [63:0]hilo_tempu;
           wire[31:0] mult_a,mult_b;
           wire [63:0]hilo_temp,result_div;
           wire div_ready,sign_div,start_div;
        //乘法
         assign mult_a = ((op ==`EXE_MULT_OP)&&(a[31]==1'b1))?(~a+1):a;
         assign mult_b = ((op ==`EXE_MULT_OP)&&(b[31]==1'b1))?(~b+1):b;
         assign hilo_temp = ((op ==`EXE_MULT_OP)&&(a[31] ^ b[31] == 1'b1))?~(mult_a * mult_b)+1:mult_a*mult_b;  
        //除法
        assign signed_div = (op ==`EXE_DIV_OP)?1:0;
        assign start_div= (op ==`EXE_DIV_OP | op ==`EXE_DIVU_OP)?1'b1:1'b0;
        assign div_ready=~stall_div;
    div div(~clk, rst, a, b, start_div, signed_div, stall_div, result_div);   
        always@(*)begin
            
      
         case(op)

            `EXE_AND_OP : res <= a & b;
            `EXE_OR_OP  : res <= a | b;
            `EXE_ADD_OP : res <= a + b;
            `EXE_SUB_OP : res <= a - b;
            `EXE_SLT_OP : res <= (a<b) ? 1 : 0;

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
         //算术运算指令
          `EXE_ADD_OP: //考虑溢出情况：有符号加法
              begin
                  nresult <= a + b;
                  overflow <= (a[31]&b[31]&~nresult[31])|(~a[31]&~b[31]&nresult[31]);
                  if (overflow == 1'b1)
                      begin
                          res <= 32'b0;
                      end
                  else begin
                      res <= a + b;
                  end
              end
         `EXE_ADDU_OP: res<= a + b;//无符号加法
         `EXE_SUB_OP: //考虑溢出情况，有符号减法
              begin
                   numa <= a;
                   numb <= ~b+1;
                   nresult <= numa + numb;
                   overflow <= (numa[31] & numb[31] & ~nresult[31]) | (~numa[31] & ~numb[31] & nresult[31]);
                   if (overflow == 1'b1) 
                       begin
                           res <= 32'b0;
                       end
                   else  begin
                       res <= numa + numb; 
                   end
              end
         `EXE_SUBU_OP://无符号减法
              begin
                  numa <= a;
                  numb <= ~b+1;
                  res <= numa + numb;
              end
         `EXE_SLT_OP://判断第一个操作数是否小于第二个操作数
              begin  //如果小于，置1，否则置0
                  numa <= a;
                  numb <= ~b+1;
                  nresult <= numa + numb;
                  if(nresult[31] == 0)
                    begin
                       res <= 32'b0;
                    end
                  else res <= 32'b1;
         
              end
         `EXE_SLTU_OP: 
              begin
                if(a < b) res <= 32'b1;
                else   res <= 32'b0 ;
              end

         `EXE_ADDI_OP://立即数加法
              begin
                 nresult <= a + b ;
                 overflow <= (a[31]&b[31]&~nresult[31])|(~a[31]&~b[31]&nresult[31]);
                 if(overflow == 1'b1) res <= 32'b0;
                 else res <= a + b;
              end

         `EXE_ADDIU_OP: //立即数无符号加法
             begin
                 res <= a + b;
             end
         
         `EXE_SLTI_OP:
            begin
                numa <= a;
                numb <= ~b+1;
                nresult <= numa + numa;
                if (nresult[31]==0) res <=32'b0;
                else res <= 32'b1;
            end

         `EXE_SLTIU_OP:
            begin
                if(a<b)
                res <= 32'b1;
                else res <= 32'b0;
            end
          //乘法
             `EXE_MULT_OP:hilo_o = hilo_temp;
            `EXE_MULTU_OP:begin
                numa = a;
                numb = b;
                hilo_tempu = numa * numb;
                hilo_o = hilo_tempu;
            end
          //除法
            `EXE_DIV_OP:hilo_o <= result_div;
            `EXE_DIVU_OP:hilo_o <= result_div;

          //访存指令
            `EXE_LB_OP:res <= a + b;
            `EXE_LBU_OP:res <= a + b;
            `EXE_LH_OP:res <= a + b;
            `EXE_LHU_OP:res <= a + b;
            `EXE_LW_OP:res <= a + b;
            `EXE_SW_OP:res <= a + b;      
            `EXE_SB_OP:res <= a + b;
            `EXE_SH_OP:res <= a + b;
          
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

            default:begin
                res <= 32'b0;
            end
         endcase
        
        end
  
assign zero = ((a-b) == 0);
    
endmodule
