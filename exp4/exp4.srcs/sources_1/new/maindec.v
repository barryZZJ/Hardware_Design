`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [5:0] op,
                    // input [5:0] funct,
                    // input [4:0] rt,
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
                jump     <= 1'b0;
                regwrite <= 1'b1;
                regdst   <= 1'b0;
                alusrc   <= 1'b1;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b1;
            end
            // sw
            `EXE_SW: begin
                jump     <= 1'b0;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b1;
                branch   <= 1'b0;
                memwrite <= 1'b1;
                memtoreg <= 1'b0;
            end
            // addi
            `EXE_ADDI: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;
                regdst   <= 1'b0;
                alusrc   <= 1'b1;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
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
            `EXE_BEQ: begin
                jal      <= 1'b1;
                branch   <= 1'b1;
            end
            // bgtz
            // blez
            // bne
            // bltz
            // bgez
            
            // bltzal
            `EXE_BLTZAL: begin
                branch   <= 1'b1;
                bal      <= 1'b1;
            end
            // bgezal


            default: begin
                
            end
        endcase
    end
    
endmodule
