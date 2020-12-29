`timescale 1ns / 1ps

`include "defines.vh"
module main_decoder(input [5:0] op,
                    output reg regdst,
                    output reg regwrite,
                    output reg alusrc,
                    output reg memwrite,
                    output reg memtoreg,
                    output reg branch,
                    output reg jump);
    
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
            
            /////////////////////////////////////
            ///             移位指令            //
            /////////////////////////////////////

            // sll
            `EXE_SLL: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b0;   // rd 15:11
                alusrc   <= 1'b1;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // srl
            `EXE_SRL: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b0;   // rd 15:11
                alusrc   <= 1'b1;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // sra
            `EXE_SRL: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b0;   // rd 15:11
                alusrc   <= 1'b1;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // sllv
            `EXE_SLLV: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b1;   // rd 15:11
                alusrc   <= 1'b0;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // srlv
            `EXE_SRLV: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b1;   // rd 15:11
                alusrc   <= 1'b0;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // srav
            `EXE_SRAV: begin
                jump     <= 1'b0;
                regwrite <= 1'b1;   //
                regdst   <= 1'b1;   // rd 15:11
                alusrc   <= 1'b0;   //
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            ////////////////////////////////////////
            //              分支跳转指令            //
            ////////////////////////////////////////
            // jr
            // jalr
            // j
            `EXE_J: begin
                jump     <= 1'b1;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end
            // jal
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
            end
        endcase
    end
    
endmodule
