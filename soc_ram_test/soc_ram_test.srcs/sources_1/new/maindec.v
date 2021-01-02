`timescale 1ns / 1ps
`include "defines.vh"
module main_decoder(input [31:0] instr,
                    input [5:0] op,
                    input [5:0] funct,
                    input [4:0] rs,
                    input [4:0] rt,
                    output reg regdst,
                    output reg regwrite,
                    output [1:0] hidst,
                    output [1:0] lodst,
                    output hi_write,
                    output lo_write,
                    output reg mfhi,
                    output reg mflo,
                    output reg break,
                    output reg syscall,
                    output reg mtc0,
                    output reg mfc0,
                    output reg eret,

                    output reg alusrc,
                    output reg branch,

                    output reg memwrite,
                    output reg memtoreg,
                    output reg memen,

                    output reg jal,
                    output reg jr,
                    output reg bal,
                    output reg jump,
                    output reg ri // 保留指令例外
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
        if (instr == `EXE_ERET)
            eret <= 1'b1;
        else
            eret <= 1'b0;
    end

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
        break    <= 1'b0;
        syscall  <= 1'b0;
        ri       <= 1'b0;
        mtc0     <= 1'b0;
        mfc0     <= 1'b0;
        case (op)
            ////////////////////////////////////////
            // R-type
            // 逻辑运算指令（非立即数部分）
            // 移位指令
            // 数据移动指令
            // 算术运算指令（非立即数部分）
            // 分支跳转 jr and jalr
            ////////////////////////////////////////
            `EXE_NOP: begin
                regwrite <= 1'b1;
                regdst   <= 1'b1;
                if (funct == `EXE_MFHI) begin
                    regwrite <= 1'b1;
                    regdst   <= 1'b1;
                    mfhi <= 1'b1;
                end else if (funct == `EXE_MFLO) begin 
                    regwrite <= 1'b1;
                    regdst   <= 1'b1;
                    mflo <= 1'b1;
                end else if (funct == `EXE_MTHI) begin
                    regwrite <= 1'b0; // 写hilo寄存器指令，不用写寄存器堆
                    regdst   <= 1'b1;
                end else if (funct == `EXE_MTLO) begin
                    regwrite <= 1'b0;
                    regdst   <= 1'b1;
                //////////////////////////////////////////////
                // jump    
                end else if (funct == `EXE_JR) begin
                    regwrite <= 1'b0;
                    // regdst   <= 1'b0;
                    jump     <= 1'b1;
                    jr       <= 1'b1;
                end else if (funct == `EXE_JALR) begin
                    // jump     <= 1'b1;
                    // regdst   <= 1'b0;
                    // jal      <= 1'b1;
                    jr       <= 1'b1;
                end else if (funct == `EXE_SYSCALL) begin
                    // syscall 和 break 不是寄存器指令
                    break    <= 1'b1;
                    regwrite <= 1'b0;
                    regdst   <= 1'b0;
                end else if (funct == `EXE_BREAK) begin
                    syscall  <= 1'b1;
                    regwrite <= 1'b0;
                    regdst   <= 1'b0;
                end
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
            // j
            `EXE_J: begin
                jump     <= 1'b1;
            end
            // jal : 需要写寄存器
            `EXE_JAL: begin
                regwrite <= 1'b1;
                jal      <= 1'b1;
                // jump     <= 1'b1;
            end
            
            // 所有分支指令的第0-15bit存储的都是offset
            // 如果发生转移，那么将offset左移2位，并符号扩展至32位
            // 然后与延迟槽指令的地址相加，加法的结果就是转移目的地址
            // beq
            // if rs = rt then branch
            `EXE_BEQ: begin
                branch   <= 1'b1;
            end
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
            `EXE_REGIMM_INST: begin
                case (rt)
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
                        regwrite <= 1'b1;
                        branch   <= 1'b1;
                        bal      <= 1'b1;
                    end
                    // bgezal
                    // if rs >= 0 then branch
                    `EXE_BGEZAL: begin
                        regwrite <= 1'b1;
                        branch   <= 1'b1;
                        bal      <= 1'b1;
                    end
                endcase
            end

            // 特权指令
            6'b010000:
                case (rs)
                    5'b00100: begin
                        mtc0     <= 1'b1;
                        regwrite <= 1'b0;
                        regdst   <= 1'b0;
                    end
                    5'b00000: begin
                    // mfc0 解析成 (regwrite=1,regdst=0)，可以保证寄存器堆数据被前推，下一条读了rt的指令取出来的是被前推的数据
                        mfc0     <= 1'b1;
                        regwrite <= 1'b1;
                        regdst   <= 1'b0;
                    end
                    default: begin
                        mtc0 <= 1'b0;
                        mfc0 <= 1'b0;
                    end
                endcase

            default: begin
                // 没有匹配的op则触发保留指令例外
                //FIXME 只有op不匹配时才触发保留指令，有没有可能op匹配也是保留指令呢
                ri <= 1'b1;
            end
        endcase
    end
    
endmodule