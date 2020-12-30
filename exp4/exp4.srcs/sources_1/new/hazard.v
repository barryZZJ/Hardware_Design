`timescale 1ns / 1ps

module hazard(
              //fetch stage
              output stallF, 

              //decode stage
              input [4:0] rsD,
              input [4:0] rtD,
              input branchD,
              output forwardAD,
              output forwardBD,
              output stallD, 

              //execute stage
              input [4:0] rsE,
              input [4:0] rtE,
              input [4:0] writeregE,
              input regwriteE,
              input memtoregE,
              input divstallE,
              output [1:0] forwardAE,
              output [1:0] forwardBE,
              output [1:0] forward_hiloE,
              output flushE,
              output stallE,

              //mem stage
              input [4:0] writeregM,
              input regwriteM,
              input hilowriteM,
              input memtoregM,

              //write back stage
              input regwriteW,
              input [4:0] writeregW
     );




// forward
//execute stage����ǰ��
//
//
assign forwardAE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                   ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;
assign forwardBE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                   ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;

//decode stage����ǰ��
assign forwardAD = ((rsD != 0) && (rsD == writeregM) && regwriteM);
assign forwardBD = ((rtD != 0) && (rtD == writeregM) && regwriteM);


//��������������ͣ��д��stall����
// stall
wire lwstall;
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE; ////ȡ�ֵ��µ�������ͣ(ֻͣһ������,���������Ժ���WriteBack��ǰ��)
assign branchstall = branchD && regwriteE && 
                       (writeregE == rsD || writeregE == rtD) ||
                       branchD && memtoregM &&
                       (writeregM == rsD || writeregM == rtD);

assign stallF = lwstall || branchstall || divstallE;
assign stallD = lwstall || branchstall || divstallE;
assign stallE = divstallE;

assign flushE = lwstall || branchstall;
assign flushM = divstallE;



endmodule
