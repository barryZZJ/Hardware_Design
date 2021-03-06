`timescale 1ns / 1ps

module hazard(input [4:0] rsD,
              input [4:0] rtD,
              input [4:0] rsE,
              input [4:0] rtE,
              input [4:0] rdE,
              input [4:0] rdM,
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
              input jalD,
              input jrD,

              input mfhiE,
              input mfloE,
              input hi_writeM, hi_writeW,
              input lo_writeM, lo_writeW,
              input divstallE,
              input mfc0E,
              input mtc0M,

              input inst_stall,
              input data_stall,

              // 异常部分
              input flushExcept,
              
              output [1:0] forwardAE,
              output [1:0] forwardBE,
              output [1:0] forwardC0E,
              output [2:0] forwardHLE,
              output forwardAD,
              output forwardBD,
              output stallF, stallD, stallE, stallM, stallW,
              output flushF, flushD, flushE, flushM, flushW,
              output longest_stall
              );

// --------------------------------
// 数据冒险

// forward
//execute stage
//
//
assign forwardAE = ((rsE != 0) && (rsE == writeregM) && regwriteM) ? 2'b10 :
                   ((rsE != 0) && (rsE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;
assign forwardBE = ((rtE != 0) && (rtE == writeregM) && regwriteM) ? 2'b10 :
                   ((rtE != 0) && (rtE == writeregW) && regwriteW) ? 2'b01 :
                   2'b00;
assign forwardC0E = mfc0E ? (rdE == rdM && mtc0M ? 2'b10 
                                                 : 2'b01) :
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


// stall
wire lwstall; // lw的下一条指令 在D阶段判断是否需要等待和刷新
//stallF, stallD, flushE;
wire branchstall;
assign lwstall = ((rsD == rtE) || (rtD == rtE)) && memtoregE; // 判断 D 阶段 rs 或 rt 的寄存器号是不是E阶段 lw 指令要写入的寄存器号；
assign branchstall = branchD && regwriteE && 
                       (writeregE == rsD || writeregE == rtD) ||
                       branchD && memtoregM &&
                       (writeregM == rsD || writeregM == rtD);
// 有异常时不能stall，否则newpcM可能因为pc寄存器stall而没法正确赋值
//（except上升沿更新时flushExcept与stall同时更新，条件用不上，下降沿更新时flushEXcept早到，&&~flushExcept可以防止stall置1）。
///////////
wire jrstall;
assign jrstall =  (jrD && regwriteE)  && (writeregE == rsD) 
                || (jrD && memtoregM) && (writeregM == rsD);

// 取指和访存都暂停所有阶段
// TODO 可能有雷
assign stallF = (inst_stall || data_stall || lwstall || branchstall || divstallE || jrstall) && ~flushExcept;
assign stallD = (inst_stall || data_stall || lwstall || branchstall || divstallE || jrstall) && ~flushExcept;
assign stallE = (inst_stall || data_stall || divstallE) && ~flushExcept;
// TODO 可能要都加上divstall
assign stallM = (inst_stall || data_stall) && ~flushExcept; 
assign stallW = (inst_stall || data_stall) && ~flushExcept; 

// 只要有一个在stall，CPU就处于stall状态
//TODO 可能还要改
assign longest_stall = (inst_stall || data_stall || divstallE) && ~flushExcept;

// 除法要么stallM，要么flushM，如果是stall的话，就是前一条指令在M一直写memory，如果是flush就正常清空了
// TODO 要不要把每个flush信号都带上~inst_stall
assign flushF = flushExcept; // 没有连在信号上
assign flushD = flushExcept;
assign flushE = flushExcept || (lwstall || branchstall) & ~inst_stall;
assign flushM = flushExcept || divstallE & ~inst_stall;
// posedge
assign flushW = flushExcept; // 例外在M阶段处理，W阶段是没问题的指令，但寄存器也是下降沿更新，flushExcept影响不到前一条W阶段的指令

endmodule
