`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [5:0] op,
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
                    output reg jump,
                    output reg mfhi, //TODO
                    output reg mflo, //TODO
                    output reg mthi, //TODO
                    output reg mtlo, //TODO
                    output reg mul, //TODO
                    output reg div //TODO
                    );
    
    always @(*) begin
        case (op)
            // R-type
            6'b000000: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;
                regdst   <= 1'b1;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // lw
            6'b100011: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;
                regdst   <= 1'b0;
                alusrc   <= 1'b1;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b1;
            end
            // sw
            6'b101011: begin
                jump     <= 1'b0;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b1;
                branch   <= 1'b0;
                memwrite <= 1'b1;
                memtoreg <= 1'b0;
            end
            // addi
            6'b001000: begin
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
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
                memen    <= 1'b0;
                jal      <= 1'b0;
                jr       <= 1'b1;
                bal      <= 1'b0;
            end
            // jalr : 需要写寄存器
            `EXE_JALR: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;
                regdst   <= 1'b1;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
                memen    <= 1'b0;
                jal      <= 1'b0;
                jr       <= 1'b1;
                bal      <= 1'b0;
            end
            // j
            `EXE_J: begin
                jump     <= 1'b1;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
                memen    <= 1'b0;
                jal      <= 1'b0;
                jr       <= 1'b0;
                bal      <= 1'b0;
            end
            // jal : 需要写寄存器
            `EXE_JAL: begin
                jump     <= 1'b1;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
                memen    <= 1'b0;
                jal      <= 1'b1;
                jr       <= 1'b0;
                bal      <= 1'b0;
            end
            // beq
            `EXE_BEQ: begin
                jump     <= 1'b0;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b1;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // bgtz
            // blez
            // bne
            // bltz
            // bltzal
            // bgez
            // bgezal


            default: begin
                jump     <= 1'b0;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
                memen    <= 1'b0;
                jal      <= 1'b0;
                jr       <= 1'b0;
                bal      <= 1'b0;
            end
        endcase
    end
    
endmodule
