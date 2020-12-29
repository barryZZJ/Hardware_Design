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
              input branchD,
              input mfhiE, mfhiM, mfhiW,
              input mfloE, mfloM, mfloW,
              
              output [1:0] forwardAE,
              output [1:0] forwardBE,
              output forwardAD,
              output forwardBD,
              output wire stallF, stallD, flushE
              );

// --------------------------------
// 数据冒险

// forward
assign forwardAE = ((rsE != 0) && (rsE == writeregM) && (regwriteM | mfhiM | mfloM)) ? 2'b10 :
                   ((rsE != 0) && (rsE == writeregW) && (regwriteW | mfhiW | mfloW)) ? 2'b01 :
                   2'b00;
assign forwardBE = ((rtE != 0) && (rtE == writeregM) && (regwriteM | mfhiM | mfloM)) ? 2'b10 :
                   ((rtE != 0) && (rtE == writeregW) && (regwriteW | mfhiW | mfloW)) ? 2'b01 :
                   2'b00;

assign forwardAD = ((rsD != 0) && (rsD == writeregM) && (regwriteM | mfhiM | mfloM));
assign forwardBD = ((rtD != 0) && (rtD == writeregM) && (regwriteM | mfhiM | mfloM));

// --------------------------------
// stall
wire lwstall;
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE; // 判断 D 阶段 rs 或 rt 的寄存器号是不是E阶段 lw 指令要写入的寄存器号；
assign mfhilostall = ((rsD == rtE) || (rtD == rtE)) && (mfhiE | mfloE); // 判断 D 阶段 rs 或 rt 的寄存器号是不是E阶段 mfhi/lo 指令要写入的寄存器号；
assign branchstall = branchD && regwriteE && 
                       (writeregE == rsD || writeregE == rtD) ||
                       branchD && memtoregM &&
                       (writeregM == rsD || writeregM == rtD);

assign stallF = lwstall || branchstall || mfhilostall;
assign stallD = lwstall || branchstall || mfhilostall;
assign flushE = lwstall || branchstall || mfhilostall;



endmodule
