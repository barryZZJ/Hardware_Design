`timescale 1ns / 1ps
`include "defines.vh"

module except_handler(input [31:0] curr_instr_addr,
                      input is_in_delayslot,
                      );
// 异常处理模块
// ! 异常发生时只是做标记，在M阶段统一处理。
// ! 异常指令及后面的指令无效，即不能对寄存器、HILO等CPU状态造成影响。（清空指令、关闭寄存器写使能。特别的，停止乘除法运算）
wire [31:0] except_type;

reg [31:0] CP0[CP0_CNT-1:0];

wire [31:0] badVAddr, status, cause, epc;
assign badVAddr = CP0[CP0_REG_BADVADDR];
assign status   = CP0[CP0_REG_STATUS];
assign cause    = CP0[CP0_REG_CAUSE];
assign epc      = CP0[CP0_REG_EPC];



always @(*) begin
    CP0[CP0_REG_STATUS][STATUS_EXL] <= 1'b1;
    case (except_type)
        ExcCode_Int: begin
            // 中断
            if (is_in_delayslot) begin
                epc <= curr_instr_addr - 4;
                cause[CAUSE_BD] <= 1'b1;
            end else begin
                epc <= curr_instr_addr;
                cause[CAUSE_BD] <= 1'b0;
            end
            status[STATUS_EXL] <= 1'b1;
            cause[CAUSE_EXECODE] <= 
        end
        ExcCode_AdEL: begin
            // addr error load
            // 地址错例外（读数据或取指令）
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_AdES: begin
            // addr error store
            // 地址错例外（写数据）
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Sys: begin
            // 系统调用例外 syscall
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Bp: begin
            // 断点例外 break
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_RI: begin
            // 保留指令例外 invalid instruction
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end
        ExcCode_Ov: begin
            // 算术溢出例外
            if (is_in_delayslot) begin
                
            end else begin
                
            end
        end

        default: 
    endcase
end

endmodule
