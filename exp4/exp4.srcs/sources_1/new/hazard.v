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
              input hi_writeM, hi_writeW,
              input lo_writeM, lo_writeW,
              
              output [1:0] forwardAE,
              output [1:0] forwardBE,
              output [2:0] forwardHLE,
              output forwardAD,
              output forwardBD,
              output wire stallF, stallD, flushE
              // output wire branchFlushD
              );

// --------------------------------
// 数据冒险

// forward
assign forwardAE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                   ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;
assign forwardBE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                   ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;

// 检查hilo冒险：如果E阶段正在读hilo(mf)，且发现M或W阶段要写hilo(hi_write, lo_write)，则把对应的hi_i, lo_i前推，否则直接输出hi_o, lo_o
assign forwardHLE = mfhiE ? (hi_writeM ? 3'b011 : 
                             hi_writeW ? 3'b101 :
                             3'b001) :
                    mfloE ? (lo_writeM ? 3'b100 :
                             lo_writeW ? 3'b110 :
                             3'b010) :
                    3'b000;

assign forwardAD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
assign forwardBD = ((rtD != 0) && (rtD == writeregM) && regwriteM);

// --------------------------------
// stall
wire lwstall;
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE; // 判断 D 阶段 rs 或 rt 的寄存器号是不是E阶段 lw 指令要写入的寄存器号；
assign branchstall = branchD && regwriteE && 
                       (writeregE == rsD || writeregE == rtD) ||
                       branchD && memtoregM &&
                       (writeregM == rsD || writeregM == rtD);

assign stallF = lwstall || branchstall;
assign stallD = lwstall || branchstall;
assign flushE = lwstall || branchstall;
// 可能有bug
// assign #1 flushE = lwstall | jumpD | branchD;
//
// assign branchFlushD = (branchD && !balD);

endmodule
