`timescale 1ns / 1ps
`include "defines.vh"
module controller(input [31:0] instr,
                  input [5:0] op,
                  input [5:0] funct,
                  input [4:0] rs,
                  input [4:0] rt,

                  output regwriteD,
                  output memtoregD,
                  output memreadD,
                  output memwriteD,
                  output branchD,
                  output [7:0]alucontrolD,
                  output alusrcD,
                  output regdstD,
                  output jumpD,
                  
                  output jalD,
                  output jrD,
                  output balD,
                  
                  output mfhiD,
                  output mfloD,
                  output [1:0] hidstD,
                  output [1:0] lodstD,
                  output hi_writeD,
                  output lo_writeD,
                  output riD,
                  output breakD,
                  output syscallD,
                  output mtc0D,
                  output mfc0D,
                  output eretD

                  );



main_decoder main_decoder(
    .instr(instr),
    .op(op),
    .funct(funct),
    .rs(rs),
    .rt(rt),

    .regdst(regdstD),
    .regwrite(regwriteD),
	.hidst(hidstD),
	.lodst(lodstD),
    .hi_write(hi_writeD), 
	.lo_write(lo_writeD),
	.mfhi(mfhiD),
	.mflo(mfloD),
    .break(breakD),
    .syscall(syscallD),
    .mtc0(mtc0D),
    .mfc0(mfc0D),
    .eret(eretD),

    .alusrc(alusrcD),
    .branch(branchD),

    .memread(memreadD),
    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    
    .jump(jumpD),

    .jal(jalD),
    .jr(jrD),
    .bal(balD),

    .ri(riD)
    
);


aludec aludec(
    .funct(funct),
    .op(op),
    .mtc0(mtc0D),
    .mfc0(mfc0D),
    .eret(eretD),
    .alucontrol(alucontrolD)
);

endmodule
