`timescale 1ns / 1ps
`include "defines.vh"

module except(input clk, rst,
              input mtc0M, // 是否是mtc0指令(是否写cp0)
              input eretM,
              input [4:0] rdM, // 写cp0的索引
              input [4:0] rdE, // 读cp0的索引
              input [31:0] write_cp0_dataM, // 写cp0对应索引的数据 
              input stallD, stallE, stallM, stallW,
              input flushD, flushE, flushM, flushW,

              input adelM,
              input riM,
              input overflowM,
              input breakM,
              input syscallM,
              input adesM,

              input [31:0] pcM,
              input is_in_delayslotM,
              input [31:0] l_s_bad_addr_iM, // load或store指令的虚地址

              output [31:0] read_cp0_dataE,
              output reg [31:0] newpcM,
              output flushExcept
              );

// 异常处理模块
// 异常发生时只是做标记，在M阶段统一处理。
// ! 异常指令及后面的指令无效，即不能对寄存器、HILO等CPU状态造成影响。
// ! （清空指令、关闭寄存器写使能、存储器写使能。特别的，停止乘除法运算）
// - flush
// - regfile
// - hilo
// - data_ram 
// - div

// 暂定在M阶段写回cp0，写cp0的数据要前推

// mfc0 解析成 (regwrite=1,regdst=0)，可以保证寄存器堆数据被前推，下一条读了rt的指令取出来的是被前推的数据
// mtc0: GPR[rt] == aluoutE, rd == rdE

// 异常处理模块

wire [`RegBus] epc_o, status_o, cause_o;

//写cp0的同时判断是不是修改了cause寄存器的值，判断是否产生了软件中断，相当于前推了。
wire [31:0] new_cause;
assign new_cause = rdM == `CP0_REG_CAUSE ? write_cp0_dataM : cause_o;

wire int; // 是否发生中断
assign int = !status_o[1] & status_o[0] & (|(status_o[15:8] & new_cause[15:8]));
// assign int = !status_o[1] & status_o[0] & (|(status_o[15:8] & cause_o[15:8]));

wire [31:0] except_typeM;

wire pcErrorM;
assign pcErrorM = pcM[1:0] != 2'b00;

assign except_typeM = int                ? `ExceptType_Int  :
                      (adelM | pcErrorM) ? `ExceptType_AdEL :
                      riM                ? `ExceptType_RI   :
                      overflowM          ? `ExceptType_Ov   :
                      breakM             ? `ExceptType_Bp   :
                      syscallM           ? `ExceptType_Sys  :
                      adesM              ? `ExceptType_AdES :
                      eretM              ? `ExceptType_Eret :
                      32'b0;

assign flushExcept = except_typeM != 32'b0;

wire [31:0] bad_addr_iM;
assign bad_addr_iM = pcErrorM ? pcM : l_s_bad_addr_iM;

cp0_reg cp0reg(
    .clk(clk), .rst(rst),
    .we_i(mtc0M),
    .waddr_i(rdM),
    .raddr_i(rdE), // E阶段读cp0
    .data_i(write_cp0_dataM), // 要写入的数据
    .int_i(6'b0), // 不知道怎么用，负责写入cause的ip7~ip2
    .excepttype_i(except_typeM),
    .current_inst_addr_i(pcM),
    .is_in_delayslot_i(is_in_delayslotM),
    .bad_addr_i(bad_addr_iM), // 存取指令计算出的地址
    
    .data_o(read_cp0_dataE), // 读出的cp0对应索引的数据
    .epc_o(epc_o),
    .status_o(status_o),
    .cause_o(cause_o)
);


always @(*) begin
    case (except_typeM)
        `ExceptType_Int: begin
            // 中断
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_AdEL: begin
            // addr error load
            // 地址错例外（读数据或取指令）
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_AdES: begin
            // addr error store
            // 地址错例外（写数据）
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_Sys: begin
            // 系统调用例外 syscall
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_Bp: begin
            // 断点例外 break
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_RI: begin
            // 保留指令例外 invalid instruction
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_Ov: begin
            // 算术溢出例外
            newpcM     <= `EXC_ENTRY_POINT;
        end
        `ExceptType_Eret: begin
            // eret作为异常处理
            newpcM     <= epc_o;
        end

        default: begin
            newpcM     <= pcM;
        end
    endcase
end

endmodule
