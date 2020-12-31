`timescale 1ns / 1ps


module datapath(
    input clk,rst,
    input [31:0]instrD, readdata, // 数据存储器读出的数据
    input regwriteE,
    input regwriteM,
    input regwriteW,
    input memtoregW,
    input memtoregE,
    input memtoregM,
    input [7:0]alucontrolE, alucontrolW,
    input alusrcE,
    input regdstE,
    input jumpD,
    input jrD,
    input branchD,

    input memenE,
    input jalE,
    input jrE,
    input jumpE,
    input balD,
    input balE,

    input mfhiE,
    input mfloE,
    input [1:0] hidstE, hidstW,
    input [1:0] lodstE, lodstW,
    input hi_writeM, hi_writeW,
    input lo_writeM, lo_writeW,
    
    output wire [31:0] pc, aluoutM, mem_WriteData,
    output [3:0] mem_wea,
    output pcsrcD,
    output wire stallF, stallD, stallE, flushE,

    // debug
    output wire debug_wb_rf_wen  , 
    output wire [ 4:0] debug_wb_rf_wnum ,
    output wire [31:0] debug_wb_rf_wdata
);

//////////////////////////////////////
// soc debug
assign debug_wb_rf_wen = regwriteW;
assign debug_wb_rf_wnum = writeregW;
assign debug_wb_rf_wdata = resultW;

/////////////////////////////////////
// for debug:
wire [31:0] instrE, instrM, instrW;
flopenrc #(32) DE_instr (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d(instrD),
    .q(instrE)
);
flopenr #(32) EM_instr (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(instrE),
    .q(instrM)
);
flopenr #(32) MF_instr (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(instrM),
    .q(instrW)
);
/////////////////////////////////////
    

//分别为：pc+4, 多路选择分支之后的pc, 下一条真正要执行的指令的pc
wire [31:0] pc_branched, pc_realnext;

//ALU数据来源A、B，寄存器堆写入数据，左移2位后的立即数，
wire [31:0] ALUsrcA1, ALUsrcA2, ALUsrcB1, ALUsrcB2, sl2_imm, sl2_j_addr, jump_addr, resultW;


// Fetch phase
wire [31:0] pc_4F,pc_8F;

// Decode phase
// pc_4: pc+4, pcbranch: pc+4 + imm<<2
wire [31:0] pcF, pc_4D, pc_8D, pcbranchD, rd1D, rd2D, extend_immD;
wire [ 4:0] rsD, rtD, rdD, saD;
wire [ 5:0] opD;

wire [31:0]pc_jump;
// wire pcsrcD;

// Execute phase
wire [31:0] rd1E, rd2E, extend_immE, aluoutE, writedataE, finalwritedataE;
wire [ 4:0] rsE, rtE, rdE, writeregE; // 写入寄存器堆的地址
wire [31:0] hi_iE, lo_iE; // hilo input
wire [ 4:0] saE;
wire [ 3:0] selE;
wire [ 1:0] offsetE;
wire [31:0] pcplus8E;

// Mem phase
wire [31:0] writedataM;
    // aluoutM;
wire [ 4:0] writeregM;
wire [31:0] hi_iM, lo_iM; // hilo input
wire [ 3:0] selM;
wire [ 1:0] offsetM;

// WB phase 
wire [31:0] aluoutW, readdataW;
wire [ 4:0] writeregW;
wire [ 1:0] offsetW;
wire [31:0] finalreaddataW;

// hilo寄存器
wire [31:0] hi_iW, lo_iW; // hilo input
wire [31:0] hi_oW, lo_oW; // hilo output

// hazard
wire [1:0] forwardAE, forwardBE;
wire [2:0] forwardHLE;
wire forwardAD, forwardBD;
wire equalD;
wire [31:0] equalsrc1, equalsrc2;

// branch and jump
wire [4:0]writereg2E;
wire [31:0] aluout2E;
// ----------------------------------------
// Fetch 

//pc
flopenr #(32) pc_module(
	.clk(clk),
	.rst(rst),
    .en(~stallF),
    .d(pc_realnext),
    .q(pc)
);

assign pcF = pc;

//PC+4加法器
adder pc_4_adder (
    .a(pcF),
    .b(32'h4),
    .y(pc_4F)
);
//PC+8加法器
adder pc_8_adder (
    .a(pcF),
    .b(32'h8),
    .y(pc_8F)
);

// ----------------------------------------
// fetech to decode memory flops 

// pc_4
flopenrc #(32) FD_pc_4 (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(1'b0),
    .d(pc_4F),
    .q(pc_4D)
);
// pc_8
flopenrc #(32) FD_pc_8 (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(pcsrcD),
    .d(pc_8F),
    .q(pc_8D)
);




// ----------------------------------------
// Decode 

//jump指令的左移2位
sl2 sl2_2(
    .a({6'b0, instrD[25:0]}),
    .y(sl2_j_addr)
);

assign jump_addr = {pc_4D[31:28], sl2_j_addr[27:0]};

assign opD = instrD[31:26];
assign rsD = instrD[25:21];
assign rtD = instrD[20:16];
assign rdD = instrD[15:11];
assign saD = instrD[10: 6];



//寄存器堆
regfile regfile(
	.clk(~clk),
	.rst(rst),
	.we3(regwriteW),
	.ra1(instrD[25:21]),
	.ra2(instrD[20:16]),
	.wa3(writeregW),
	.wd3(resultW),

	.rd1(rd1D),
	.rd2(rd2D)
);

mux2 #(32) mux_equalsrc1(
    .a(aluoutM),
    .b(rd1D),
    .s(forwardAD),
    .y(equalsrc1)
);

mux2 #(32) mux_equalsrc2(
    .a(aluoutM),
    .b(rd2D),
    .s(forwardBD),
    .y(equalsrc2)
);

// assign equalD = (equalsrc1 == equalsrc2);
// equalD : compare模块判断是否满足跳转条件
// branchD
assign pcsrcD = branchD & equalD;

//符号拓展
signext sign_extend(
    .a(instrD[15:0]),
    .type(instrD[29:28]),
    .y(extend_immD)
);

//立即数的左移2位
sl2 sl2_1(
    .a(extend_immD),
    .y(sl2_imm)
);

//branch跳转地址加法器
adder pc_branch_adder (
	.a(pc_4D),
	.b(sl2_imm),
	.y(pcbranchD)
);

// mux, PC指向选择, PC+4(0), pc_src(1)
// pc_branched: 用来跟jump地址再选一次
mux2 #(32) mux_pcbranch(
	.a(pcbranchD),  //来自数据存储器
	.b(pc_4F),      //来自加法器计算结果
	.s(pcsrcD),
	.y(pc_branched)
);
// equalsrc1是rd1的前推结果
assign pc_jump = (jrD == 1'b1) ? equalsrc1 : {pc_4D[31:28],instrD[25:0],2'b00};
//mux, 选择分支之后的pc与jump_addr
mux2 #(32) mux_pcnext(
	.a(pc_jump),
	.b(pc_branched),
	.s(jumpD | jrD),        // 这里信号量配置不一样
	.y(pc_realnext)
);

// branch指令判断
eqcmp eqcmp(
    .a(equalsrc1),
    .b(equalsrc2),
    .op(opD),
    .rt(rtD),
    .y(equalD)
);


// ----------------------------------------
// decode to execution flops

// rd1
flopenrc #(32) DE_rd1 (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d(rd1D),
    .q(rd1E)
);

// rd2
flopenrc #(32) DE_rd2 (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d(rd2D),
    .q(rd2E)
);

// rs, rt, rd
flopenrc #(15) DE_rt_rd (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d({rsD, rtD, rdD}),
    .q({rsE, rtE, rdE})
);

// sa 
flopenrc #(5) DE_sa (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d(saD),
    .q(saE)
);

// extend_imm
flopenrc #(32) DE_imm (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(flushE),
    .d(extend_immD),
    .q(extend_immE)
);

floprc #(32) DE_pc (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d(pc_8D),
    .q(pcplus8E)
);

// ----------------------------------------
// Exe 

// ALU,A端输入值，rd1E(00),resultW(01)，aluoutM(10)
mux3 #(32) mux_ALUAsrc(
    .a(rd1E),
    .b(resultW),
    .c(aluoutM),
    .s(forwardAE),
    .y(ALUsrcA1)
);
// ALU, B端输入值，rd1E(00),resultW(01)，aluoutM(10)
mux3 #(32) mux_ALUBsrc1(
    .a(rd2E),
    .b(resultW),
    .c(aluoutM),
    .s(forwardBE),
    .y(ALUsrcB1)
);

mux2 #(32) mux_ALUBsrc2(
    .a(extend_immE),
    .b(ALUsrcB1),
    .s(alusrcE),
    .y(ALUsrcB2) // B输入第二个选择器之后的结果
);


// jump and branch

// 控制是否将返回地址写入31号寄存器
/*mux2 #(5) wrmux2 (
	.a(5'b11111),
	.b(writeregE),
	.s(jalE | balE),
	.y(writereg2E)
);*/
assign writereg2E = (jumpE == 1'b0 && jrE == 1'b1 && rdE == 5'b00000) ? 5'b11111 :
                    (jumpE == 1'b0 && jrE == 1'b1 && rdE != 5'b00000) ? rdE : 
                    (balE == 1'b1 | jalE == 1'b1) ? 5'b11111 :
                    writeregE; 

// 控制被写数据是否为PC+8
mux2 #(32) wrmux3 (
	.a(pcplus8E),
	.b(aluoutE),
	.s(jalE | balE),
	.y(aluout2E)
);
// 如果是mfhi/lo指令，则ALU A应该输入hi/lo寄存器的值，B输入的是0，同时要考虑转发。
assign ALUsrcA2 = forwardHLE == 3'b000 ? ALUsrcA1 :
                  forwardHLE == 3'b001 ? hi_oW :
                  forwardHLE == 3'b010 ? lo_oW :
                  forwardHLE == 3'b011 ? hi_iM :
                  forwardHLE == 3'b100 ? lo_iM :
                  forwardHLE == 3'b101 ? hi_iW :
                  forwardHLE == 3'b110 ? lo_iW :
                  32'bx;

//ALU
alu alu(
    .a(ALUsrcA2),
    .b(ALUsrcB2),
    .sa(saE),
    .op(alucontrolE),
    .writedata(writedataE),
    
    .res(aluoutE),
    .sel(selE),
    .finalwritedata(finalwritedataE),
    .offset(offsetE)
);

// 乘法器
wire [63:0] mul_result;
mul mul(
    .a(ALUsrcA2),
    .b(ALUsrcB2),
    .op(alucontrolE),
    
    .res(mul_result)
);

// 除法器
wire [63:0] div_result;
wire divstallE; //除法发出的stall信号
divWrapper div(
    .clk(clk), .rst(rst),
    .a(ALUsrcA2),
    .b(ALUsrcB2),
    .op(alucontrolE),

    .div_result(div_result),
    .divstall(divstallE)
);

assign writedataE = ALUsrcB1; // B输入第一个选择器之后的结果

// 寄存器堆写入地址 writereg
mux2 #(5) mux_WA3(
	.a(rdE), //instr[15:11]
	.b(rtE), //instr[20:16]
	.s(regdstE),
	.y(writeregE)
); 

// hilo
assign hi_iE = hidstE == 2'b01 ? mul_result[63:32] :
               hidstE == 2'b10 ? div_result[63:32] :
               hidstE == 2'b11 ? ALUsrcA1 :
               32'bx;

assign lo_iE = lodstE == 2'b01 ? mul_result[31:0] :
               lodstE == 2'b10 ? div_result[31:0] :
               lodstE == 2'b11 ? ALUsrcA1 :
               32'bx;

// ----------------------------------------
// execution to Mem flops

// aluout
flopenr #(32) EM_aluout (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(aluout2E),
    .q(aluoutM)
);

// writedata
flopenr #(32) EM_writedata (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(finalwritedataE),
    .q(writedataM)
);

// writereg
flopenr #(5) EM_writereg (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(writereg2E),
    .q(writeregM)
);

// hilo
flopenr #(64) EM_hilo (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({hi_iE, lo_iE}),
    .q({hi_iM, lo_iM})
);

// sel
flopenr #(4) EM_sel (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(selE),
    .q(selM)
);

// offset
flopenr #(2) EM_offset (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(offsetE),
    .q(offsetM)
);

// ----------------------------------------
// Mem 
assign mem_WriteData = writedataM;
assign mem_wea = selM;

// ----------------------------------------
// Mem to wb flops

// aluout
flopenr #(32) MF_aluout (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(aluoutM),
    .q(aluoutW)
);

// readdata from data memory
flopenr #(32) MF_readdata (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(readdata),
    .q(readdataW)
);

// writereg
flopenr #(5) MW_writereg (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(writeregM),
    .q(writeregW)
);

// hilo
flopenr #(64) MW_hilo (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({hi_iM, lo_iM}),
    .q({hi_iW, lo_iW})
);

flopenr #(2) MW_offset (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(offsetM),
    .q(offsetW)
);

// ----------------------------------------
// Write Back 

// 根据load指令类型不同得到真正的readdata
readdata_format rdf(
    .op(alucontrolW),
    .offset(offsetW),
    .readdata(readdataW),
    .finalreaddata(finalreaddataW)
);


//mux, 寄存器堆写入数据来自存储器 or ALU ，memtoReg
mux2 #(32) mux_WD3(
	.a(finalreaddataW),//来自数据存储器
	.b(aluoutW),//来自ALU计算结果
	.s(memtoregW),
	.y(resultW)
);

//hilo寄存器
hilo_reg hilo(
    .clk(clk), .rst(rst), 
    .weh(hi_writeW),
    .wel(lo_writeW),
    .hi(hi_iW), .lo(lo_iW),
    .hi_o(hi_oW), .lo_o(lo_oW)
);

// ----------------------------------------
// hazard

hazard hazard(
    .rsD(rsD),
    .rtD(rtD),
    .rsE(rsE),
    .rtE(rtE),
    .writeregE(writeregE),
    .writeregM(writeregM),
    .writeregW(writeregW),
    .regwriteE(regwriteE),
    .regwriteM(regwriteM),
    .regwriteW(regwriteW),
    .memtoregE(memtoregE),
    .memtoregM(memtoregM),
    .branchD(branchD),
    .mfhiE(mfhiE),
	.mfloE(mfloE),
    .hi_writeM(hi_writeM), .hi_writeW(hi_writeW),
    .lo_writeM(lo_writeM), .lo_writeW(lo_writeW),
    .divstallE(divstallE),
    
    .forwardAE(forwardAE),
    .forwardBE(forwardBE),
    .forwardHLE(forwardHLE),
    .forwardAD(forwardAD),
    .forwardBD(forwardBD),

    .stallF(stallF),
    .stallD(stallD),
    .stallE(stallE),
    .flushE(flushE),
    // jump and branch
    .jumpD(jumpD),
    .balD(balD)
    
    
);


endmodule
