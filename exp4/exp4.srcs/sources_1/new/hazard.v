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

              output [1:0] forwardAE,
              output [1:0] forwardBE,
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

assign forwardAD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
assign forwardBD = ((rtD != 0) && (rtD == writeregM) && regwriteM);

// --------------------------------
// stall
wire lwstall;
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE; // . �ж� decode �׶� rs �� rt �ĵ�ַ�Ƿ��� lw ָ��Ҫд��ĵ�ַ��
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
