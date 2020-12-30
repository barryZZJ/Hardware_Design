`timescale 1ns / 1ps

module hazard(input [4:0] rsD,
              input [4:0] rtD,
              input [4:0] rsE,
              input [4:0] rtE,
              input [4:0] writeregE,
              input [4:0] writeregM,
              input [4:0] writeregW,
              input regwriteE,
              input regwriteM,
              input regwriteW,
              input memtoregE,
              input memtoregM,


              // 分支跳转部分
              input branchD,
              input balD,
              input jumpD,

              input mfhiE,
              input mfloE,  

              output [1:0] forwardAE,
              output [1:0] forwardBE,
              output [2:0] forwardHLE,
              output forwardAD,
              output forwardBD,
              output wire stallF, stallD, flushE,
              output wire branchFlushD
              );

// --------------------------------
// ����ð��

// forward
assign forwardAE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                   ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;
assign forwardBE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                   ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;

assign forwardHLE = {forwardBE, mfhiE, mfloE} == 4'b0000 ? 3'b000 :
                    {forwardBE, mfhiE, mfloE} == 4'b0010 ? 3'b001 :
                    {forwardBE, mfhiE, mfloE} == 4'b0001 ? 3'b010 :
                    {forwardBE, mfhiE, mfloE} == 4'b1010 ? 3'b011 :
                    {forwardBE, mfhiE, mfloE} == 4'b1001 ? 3'b100 :
                    {forwardBE, mfhiE, mfloE} == 4'b0110 ? 3'b101 :
                    {forwardBE, mfhiE, mfloE} == 4'b0101 ? 3'b110 :
                    3'bxxx;

assign forwardAD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
assign forwardBD = ((rtD != 0) && (rtD == writeregM) && regwriteM);

// --------------------------------
// stall
wire lwstall;
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE;  // 判断 D 阶段 rs 或 rt 的寄存器号是不是E阶段 lw 指令要写入的寄存器号；
assign branchstall = branchD && regwriteE && 
                       (writeregE == rsD || writeregE == rtD) ||
                       branchD && memtoregM &&
                       (writeregM == rsD || writeregM == rtD);

assign stallF = lwstall || branchstall;
assign stallD = lwstall || branchstall;
// assign flushE = lwstall || branchstall;
// 可能有bug
assign #1 flushE = lwstall | jumpD | branchD;
//
assign branchFlushD = (branchD && !balD);

endmodule
