`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [5:0] op,
                    input [5:0] funct,
                    input [4:0] rt,
                    output reg regdst,
                    output reg regwrite,

                    output reg alusrc,
                    output reg branch,

                    output reg memwrite,
                    output reg memtoreg,
                    output reg memen,

                    output reg jal,
                    output reg jr,
                    output reg bal,
                    output reg jump);
    
    always @(*) begin
        regwrite <= 1'b0;
        regdst   <= 1'b0;
        alusrc   <= 1'b0;
        
        memwrite <= 1'b0;
        memtoreg <= 1'b0;
        memen    <= 1'b0;

        jump     <= 1'b0;
        jal      <= 1'b0;
        jr       <= 1'b0;
        branch   <= 1'b0;
        bal      <= 1'b0;
        case (op)
            // R-type
            `EXE_NOP: begin
                regwrite <= 1'b1;
                regdst   <= 1'b1;
            end
            // lw
            `EXE_LW: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
            end
            // sw
            `EXE_SW: begin
                alusrc   <= 1'b1;
                memwrite <= 1'b1;
            end
            // addi
            `EXE_ADDI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            
            ////////////////////////////////////////
            //
            // 移位指令
            //
            ////////////////////////////////////////

            // 均为 R - Type

            ////////////////////////////////////////
            //
            // 分支跳转指令
            //
            ////////////////////////////////////////
            // jr
            `EXE_JR: begin
                jump     <= 1'b1;
                jr       <= 1'b1;
            end
            // jalr : 需要写寄存器
            `EXE_JALR: begin
                regwrite <= 1'b1;
                regdst   <= 1'b1;
                jr       <= 1'b1;
            end
            // j
            `EXE_J: begin
                jump     <= 1'b1;
            end
            // jal : 需要写寄存器
            `EXE_JAL: begin
                jump     <= 1'b1;
                jal      <= 1'b1;
            end
            // beq
            // if rs = rt then branch
            `EXE_BEQ: begin
                jal      <= 1'b1;
                branch   <= 1'b1;
            end

            // 所有分支指令的第0-15bit存储的都是offset
            // 如果发生转移，那么将offset左移2位，并符号扩展至32位
            // 然后与延迟槽指令的地址相加，加法的结果就是转移目的地址
            // bgtz
            // if rs > 0 then branch
            `EXE_BGTZ: begin
                branch   <= 1'b1;
            end
            // blez
            // if rs <= 0 then branch
            `EXE_BLEZ: begin
                branch   <= 1'b1;
            end
            // bne
            // if rs != rt then branch
            `EXE_BNE: begin
                branch   <= 1'b1;
            end
            // bltz
            // if rs < 0 then branch
            `EXE_BLTZ: begin
                branch   <= 1'b1;
            end
            // bgez
            // if rs >= 0 then branch
            `EXE_BGEZ: begin
                branch   <= 1'b1;
            end
            // bltzal
            // if rs < 0 then branch
            `EXE_BLTZAL: begin
                branch   <= 1'b1;
                bal      <= 1'b1;
            end
            // bgezal
            // if rs >= 0 then branch
                `EXE_BGEZAL: begin
                branch   <= 1'b1;
                bal      <= 1'b1;
            end
            default: begin
                
            end
        endcase
    end
    
endmodule
