`timescale 1ns / 1ps
`include "defines.vh"
module controller(input [5:0] op,
                  input [5:0] funct,
                  output regwriteD,
                  output memtoregD,
                  output memwriteD,
                  output branchD,
                  output [7:0]alucontrolD,
                  output alusrcD,
                  output regdstD,
                  output jumpD,
                  output mfhiD,
                  output mfloD,
                  output mthiD,
                  output mtloD,
                  output mulD,
                  output divD
                  );



main_decoder main_decoder(
    .op(op),
    .regdst(regdstD),
    .regwrite(regwriteD),
    .alusrc(alusrcD),
    .memwrite(memwriteD),
    .memtoreg(memtoregD),
    .branch(branchD),
    .jump(jumpD),
	.mfhi(mfhiD),
	.mflo(mfloD),
	.mthi(mthiD),
	.mtlo(mtloD),
	.mul(mulD),
	.div(divD)
);

aludec aludec(
    .funct(funct),
    .op(op),
    .alucontrol(alucontrolD)
);

endmodule
