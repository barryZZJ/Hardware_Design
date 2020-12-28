`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [5:0] op,
                    input [5:0] funct,
                    input [4:0] rt,
                    output reg regdst,regwrite,
                    output reg memwrite,memtoreg,memen,
                    output reg branch,alusrc,
                    output reg jump,jal,jr,bal,
                    output reg [1:0] hilo_write //hilo寄存器控制信号
                    );
        reg [10:0] controls;
        assign {regwrite,regdst,alusrc,branch,memen,memtoreg,jump,jal,jr,bal,memwrite} = controls;
                    `EXE_SPECIAL_INST:
                case (funct)                
                    `EXE_JR:controls <= 11'b0_0_0_0_0_0_1_0_1_0_0;
                    `EXE_JALR:controls <= 11'b1_1_0_0_0_0_0_0_1_0_0;
                    //数据移动
                    `EXE_MFHI:begin//HI寄存器至通用寄存器
                        controls <= 11'b1_1_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b00;
                        end
                    `EXE_MFLO:begin//LO寄存器至通用寄存器
                        controls <= 11'b1_1_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b00;
                        end
                    `EXE_MTHI:begin//通用寄存器至HI寄存器
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b10;
                        end
                    `EXE_MTLO:begin//通用寄存器至LO寄存器
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b01;
                        end
                    `EXE_MULT:begin
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b10;
                    end
                    `EXE_MULTU:begin
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b10;
                    end
                    `EXE_DIV:begin
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b10;                
                    end
                    `EXE_DIVU:begin
                        controls <= 11'b0_0_0_0_0_0_0_0_0_0_0;
                        hilo_write <= 2'b10;                
                    end
                    //R型指令
                    default:controls <= 11'b1_1_0_0_0_0_0_0_0_0_0;
                endcase
            `EXE_REGIMM_INST://bltz bltzal bgez bgezal
                case (rt)
                    `EXE_BLTZAL:controls <= 11'b1_0_0_1_0_0_0_0_0_1_0;
                    `EXE_BGEZAL:controls <= 11'b1_0_0_1_0_0_0_0_0_1_0;
                    default:controls <= 11'b0_0_0_1_0_0_0_0_0_0_0;
                endcase
            //逻辑运算
            `EXE_ANDI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_XORI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_LUI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_ORI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            //算术运算
            `EXE_ADDI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_ADDIU:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_SLTI:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            `EXE_SLTIU:controls <= 11'b1_0_1_0_0_0_0_0_0_0_0;
            //分支跳转
            `EXE_J:controls <= 11'b0_0_0_0_0_0_1_0_0_0_0;
            `EXE_JAL:controls <= 11'b1_0_0_0_0_0_0_1_0_0_0;
            `EXE_BEQ:controls <= 11'b0_0_0_1_0_0_0_0_0_0_0;
            `EXE_BGTZ:controls <= 11'b0_0_0_1_0_0_0_0_0_0_0;
            `EXE_BLEZ:controls <= 11'b0_0_0_1_0_0_0_0_0_0_0;
            `EXE_BNE:controls <= 11'b0_0_0_1_0_0_0_0_0_0_0;
            //访存指令 
            `EXE_LB:controls <= 11'b1_0_1_0_1_1_0_0_0_0_0;
            `EXE_LBU:controls <= 11'b1_0_1_0_1_1_0_0_0_0_0;
            `EXE_LH:controls <= 11'b1_0_1_0_1_1_0_0_0_0_0;
            `EXE_LHU:controls <= 11'b1_0_1_0_1_1_0_0_0_0_0;
            `EXE_LW:controls <= 11'b1_0_1_0_1_1_0_0_0_0_0;
            `EXE_SW:controls <= 11'b0_0_1_0_1_0_0_0_0_0_1;      
            `EXE_SB:controls <= 11'b0_0_1_0_1_0_0_0_0_0_1;
            `EXE_SH:controls <= 11'b0_0_1_0_1_0_0_0_0_0_1;
            //测试
            `EXE_EQUAL:controls <= 11'b1_1_0_0_0_0_0_0_0_0_0;
            default:controls <= 11'bxxxxxxxxxxx;
    always @(*) begin
        case (op)
           

        endcase
    end
    
endmodule
