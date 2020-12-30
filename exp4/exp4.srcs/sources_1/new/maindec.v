`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [5:0] op,
                    input [5:0] funct,
                    // input [4:0] rt, //暂时没用
                    output reg regdst,
                    output reg regwrite,
                    output [1:0] hidst,
                    output [1:0] lodst,
                    output hi_write,
                    output lo_write,
                    output reg mfhi,
                    output reg mflo,

                    output reg alusrc,
                    output reg branch,

                    output reg memwrite,
                    output reg memtoreg,
                    output reg memen,

                    output reg jal,
                    output reg jr,
                    output reg bal,
                    output reg jump
                    );

wire mul, div;
assign mul = op == `EXE_NOP & (funct == `EXE_MULT | funct == `EXE_MULTU);
assign div = op == `EXE_NOP & (funct == `EXE_DIV | funct == `EXE_DIVU);

wire mthi, mtlo;
assign mthi = op == `EXE_NOP & funct == `EXE_MTHI;
assign mtlo = op == `EXE_NOP & funct == `EXE_MTLO;

assign hidst = {mul, div, mthi} == 3'b100 ? 2'b01 :
               {mul, div, mthi} == 3'b010 ? 2'b10 :
               {mul, div, mthi} == 3'b001 ? 2'b11 :
               2'b00;
               
assign lodst = {mul, div, mtlo} == 3'b100 ? 2'b01 :
               {mul, div, mtlo} == 3'b010 ? 2'b10 :
               {mul, div, mtlo} == 3'b001 ? 2'b11 :
               2'b00;
assign hi_write = mul | div | mthi;
assign lo_write = mul | div | mtlo;


    always @(*) begin
        // 全初始化为0，下面的case中符合条件的改成1
        regdst   <= 1'b0;
        regwrite <= 1'b0;
        alusrc   <= 1'b0;
        branch   <= 1'b0;
        memwrite <= 1'b0;
        memtoreg <= 1'b0;
        memen    <= 1'b0;
        jal      <= 1'b0;
        jr       <= 1'b0;
        bal      <= 1'b0;
        jump     <= 1'b0;
        mfhi     <= 1'b0;
        mflo     <= 1'b0;
        case (op)
            ////////////////////////////////////////
            // R-type
            // 逻辑运算指令（非立即数部分）
            // 移位指令
            // 数据移动指令
            // 算术运算指令（非立即数部分）
            ////////////////////////////////////////
            `EXE_NOP: begin
                regwrite <= 1'b1;
                regdst   <= 1'b1;
                case (funct)
                    `EXE_MFHI: mfhi <= 1'b1;
                    `EXE_MFLO: mflo <= 1'b1;
                    `EXE_MTHI: regwrite <= 1'b0; // 写hilo寄存器指令，不用写寄存器堆
                    `EXE_MTLO: regwrite <= 1'b0;
                endcase
            end

            ////////////////////////////////////////
            // 逻辑运算指令（立即数部分）
            ////////////////////////////////////////
            `EXE_ANDI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;

            end
            `EXE_XORI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            `EXE_LUI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            `EXE_ORI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end



            ////////////////////////////////////////
            // 
            // 访存指令
            //
            ////////////////////////////////////////
            // lb
            `EXE_LB: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
                memen    <= 1'b1;
            end
            // lbu
            `EXE_LBU: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
                memen    <= 1'b1;
            end
            // lh
            `EXE_LH: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
                memen    <= 1'b1;
            end
            // lhu
            `EXE_LHU: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
                memen    <= 1'b1;
            end
            // lw
            `EXE_LW: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
                memtoreg <= 1'b1;
                memen    <= 1'b1;
            end
            // sb
           `EXE_SB: begin
                alusrc   <= 1'b1;
                memwrite <= 1'b1;
                memen    <= 1'b1;
            end
            // sh
           `EXE_SH: begin
                alusrc   <= 1'b1;
                memwrite <= 1'b1;
                memen    <= 1'b1;
            end
            // sw
            `EXE_SW: begin
                alusrc   <= 1'b1;
                memwrite <= 1'b1;
                memen    <= 1'b1;
            end

            ////////////////////////////////////////
            //
            // 算术运算指令
            //
            ////////////////////////////////////////


            `EXE_ADDI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            `EXE_ADDIU: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            `EXE_SLTI: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end
            `EXE_SLTIU: begin
                regwrite <= 1'b1;
                alusrc   <= 1'b1;
            end

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
                branch   <= 1'b1;
            end
            // bgtz
            // blez
            // bne
            // bltz
            // bltzal
            // bgez
            // bgezal

        endcase
    end
    
endmodule