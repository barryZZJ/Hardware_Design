
`include "defines.vh"
module alu #(WIDTH = 32)
            (input [WIDTH-1:0] a,//操作数1
             input [WIDTH-1:0] b,//操作数2
             input [7:0] op,
             input [63:0] hilo_i,//乘除法hilo寄存器：输入
             output [63:0] hilo_o,//乘除法hilo寄存器：输出
             output reg [WIDTH-1:0] res,
             output reg overflow,//算术运算溢出
             output zero);

           reg [WIDTH-1:0] numa,numb;//考虑溢出情况算术运算，中间变量
           reg [31:0]nresult;//有溢出的算术运算的中间变量结果

        //乘法
        //除法
        
        always@(*)
         case(op)
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
          //除法

          //访存指令
            `EXE_LB_OP:res <= a + b;
            `EXE_LBU_OP:res <= a + b;
            `EXE_LH_OP:res <= a + b;
            `EXE_LHU_OP:res <= a + b;
            `EXE_LW_OP:res <= a + b;
            `EXE_SW_OP:res <= a + b;      
            `EXE_SB_OP:res <= a + b;
            `EXE_SH_OP:res <= a + b;
         endcase
        


    
endmodule
