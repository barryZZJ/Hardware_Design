`timescale 1ns / 1ps

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
            // beq
            6'b000100: begin
                jump     <= 1'b0;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b1;
                memwrite <= 1'b0;
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
            // j
            6'b000010: begin
                jump     <= 1'b1;
                regwrite <= 1'b0;
                regdst   <= 1'b0;
                alusrc   <= 1'b0;
                branch   <= 1'b0;
                memwrite <= 1'b0;
                memtoreg <= 1'b0;
            end

            /////////////////////////////////////
            ///             移位指令            //
            /////////////////////////////////////

            // sll

            // srl

            // sra

            // sllv

            // srlv

            // srav
            ////////////////////////////////////////
            //              分支跳转指令            //
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
