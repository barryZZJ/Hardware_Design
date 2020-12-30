`timescale 1ns / 1ps
`include "defines.vh"
module controller(input [5:0] op,
                  input [5:0] funct,
                  input [4:0] rt,

                  output regwriteD,
                  output memtoregD,
                  output memwriteD,
                  output branchD,
                  output [7:0]alucontrolD,
                  output alusrcD,
                  output regdstD,
                  output jumpD,
                  
                  output memenD,
                  output jalD,
                  output jrD,
                  output balD,
                  
                  output mfhiD,
                  output mfloD,
                //   output mthiD,
                //   output mtloD,
                  output [1:0] hidstD,
                  output [1:0] lodstD,
                  output hi_writeD,
                  output lo_writeD

                  );



main_decoder main_decoder(
    .op(op),
    .funct(funct),
    .rt(rt),

    .regdst(regdstD),
    .regwrite(regwriteD),

    .alusrc(alusrcD),

    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    .branch(branchD),
    .jump(jumpD),
    .memen(memenD),
    .jal(jalD),
    .jr(jrD),
    .bal(balD),
    .mfhi(mfhiD),
	.mflo(mfloD),
	// .mthi(mthiD),
	// .mtlo(mtloD),
	.hidst(hidstD),
	.lodst(lodstD),
    .hi_write(hi_writeD), 
	.lo_write(lo_writeD)
    
    );


aludec aludec(
    .funct(funct),
    .op(op),
    .alucontrol(alucontrolD)
);

endmodule
