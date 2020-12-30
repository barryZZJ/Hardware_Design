`timescale 1ns / 1ps

`include "defines.vh"
module aludec(input [5:0] funct,
              input [5:0] op,
              output reg [7:0] alucontrol);
    
    always @(*) begin
        case (op)
            // 逻辑运算指令
            `EXE_ANDI	: alucontrol <= `EXE_ANDI_OP;
            `EXE_ORI	: alucontrol <= `EXE_ORI_OP ;
            `EXE_XORI	: alucontrol <= `EXE_XORI_OP;
            `EXE_LUI	: alucontrol <= `EXE_LUI_OP ;

            // 算术运算指令
            `EXE_SLTI   : alucontrol <= `EXE_SLTI_OP ;
            `EXE_SLTIU  : alucontrol <= `EXE_SLTIU_OP;
            `EXE_ADDI   : alucontrol <= `EXE_ADDI_OP ;
            `EXE_ADDIU  : alucontrol <= `EXE_ADDIU_OP;

            // // 分支跳转指令
            // `EXE_J      : alucontrol <= `EXE_J_OP     ;
            // `EXE_JAL    : alucontrol <= `EXE_JAL_OP   ;
            // `EXE_BEQ    : alucontrol <= `EXE_BEQ_OP   ;
            // `EXE_BGEZ   : alucontrol <= `EXE_BGEZ_OP  ; 
            // `EXE_BGEZAL : alucontrol <= `EXE_BGEZAL_OP;
            // `EXE_BGTZ   : alucontrol <= `EXE_BGTZ_OP  ;
            // `EXE_BLEZ   : alucontrol <= `EXE_BLEZ_OP  ;
            // `EXE_BLTZ   : alucontrol <= `EXE_BLTZ_OP  ;
            // `EXE_BLTZAL : alucontrol <= `EXE_BLTZAL_OP;
            // `EXE_BNE    : alucontrol <= `EXE_BNE_OP   ;

            // 访存指令
            `EXE_LB     : alucontrol <= `EXE_LB_OP ;
            `EXE_LBU    : alucontrol <= `EXE_LBU_OP;
            `EXE_LH     : alucontrol <= `EXE_LH_OP ;
            `EXE_LHU    : alucontrol <= `EXE_LHU_OP;
            `EXE_LW     : alucontrol <= `EXE_LW_OP ;
            `EXE_SB     : alucontrol <= `EXE_SB_OP ;
            `EXE_SH     : alucontrol <= `EXE_SH_OP ;
            `EXE_SW     : alucontrol <= `EXE_SW_OP ;

            `EXE_NOP: begin
                case (funct)
                // 逻辑运算指令
                    `EXE_AND 	: alucontrol <= `EXE_AND_OP ;
                    `EXE_OR 	: alucontrol <= `EXE_OR_OP  ;
                    `EXE_XOR 	: alucontrol <= `EXE_XOR_OP ;
                    `EXE_NOR	: alucontrol <= `EXE_NOR_OP ;
                // 移位指令
                    `EXE_SLL	: alucontrol <= `EXE_SLL_OP ;
                    `EXE_SLLV	: alucontrol <= `EXE_SLLV_OP;
                    `EXE_SRL 	: alucontrol <= `EXE_SRL_OP ;
                    `EXE_SRLV 	: alucontrol <= `EXE_SRLV_OP;
                    `EXE_SRA 	: alucontrol <= `EXE_SRA_OP ;
                    `EXE_SRAV 	: alucontrol <= `EXE_SRAV_OP;
                // 数据移动指令
                    `EXE_MFHI  	: alucontrol <= `EXE_MFHI_OP;
                    `EXE_MTHI  	: alucontrol <= `EXE_MTHI_OP;
                    `EXE_MFLO  	: alucontrol <= `EXE_MFLO_OP;
                    `EXE_MTLO  	: alucontrol <= `EXE_MTLO_OP;
                // 算术运算指令
                    `EXE_ADD    : alucontrol <= `EXE_ADD_OP  ;
                    `EXE_ADDU   : alucontrol <= `EXE_ADDU_OP ;
                    `EXE_SUB    : alucontrol <= `EXE_SUB_OP  ;
                    `EXE_SUBU   : alucontrol <= `EXE_SUBU_OP ;
                    `EXE_MULT   : alucontrol <= `EXE_MULT_OP ;
                    `EXE_MULTU  : alucontrol <= `EXE_MULTU_OP;
                    `EXE_DIV    : alucontrol <= `EXE_DIV_OP  ;
                    `EXE_DIVU   : alucontrol <= `EXE_DIVU_OP ;
                    `EXE_SLT    : alucontrol <= `EXE_SLT_OP  ;
                    `EXE_SLTU   : alucontrol <= `EXE_SLTU_OP ;
                // 分支跳转指令
                    `EXE_JALR   : alucontrol <= `EXE_JALR_OP ;
                    `EXE_JR     : alucontrol <= `EXE_JR_OP   ;
                // 内陷指令
                    `EXE_SYSCALL: alucontrol <= `EXE_SYSCALL_OP;
                    `EXE_BREAK  : alucontrol <= `EXE_BREAK_OP  ;
                    default: alucontrol <= 8'bx;
                endcase
            end
            default: begin
                alucontrol <= `EXE_NOP_OP;
            end
        endcase
    end
    
    
endmodule
