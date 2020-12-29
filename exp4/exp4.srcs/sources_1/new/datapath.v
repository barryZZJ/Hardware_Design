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
    input [7:0]alucontrolE,
    input alusrcE,
    input regdstE,
    input jumpD,
    input branchD,
    input mfhiE, mfhiW, 
    input mfloE, mfloW, 
    input mthiE, mthiW, 
    input mtloE, mtloW, 
    input mulE, mulW,
    input divE, divW,
    
    output wire [31:0] pc, aluoutM, mem_WriteData,
    output pcsrcD,
    output wire stallF, stallD, flushE
);
    

//分别为：pc+4, 多路选择分支之后的pc, 下一条真正要执行的指令的pc
wire [31:0] pc_branched, pc_realnext;

//ALU数据来源A、B，寄存器堆写入数据，左移2位后的立即数，
wire [31:0] ALUsrcA, ALUsrcB1, ALUsrcB2, sl2_imm, sl2_j_addr, jump_addr, resultW;


// Fetch phase
wire [31:0] pc_4F;

// Decode phase
// pc_4: pc+4, pcbranch: pc+4 + imm<<2
wire [31:0] pcF, pc_4D, pcbranchD, rd1D, rd2D, extend_immD;
wire [ 4:0] rsD, rtD, rdD;
    //wire pcsrcD;

// Execute phase
wire [31:0] pc_4E, rd1E, rd2E, extend_immE, aluoutE, writedataE;
wire [ 4:0] rsE, rtE, rdE, writeregE; // 写入寄存器堆的地址
wire [31:0] hi_iE, lo_iE; // input


// Mem phase
wire [31:0] writedataM;
    // aluoutM;
wire [ 4:0] writeregM;
wire [31:0] hi_iM, lo_iM; // input

// WB phase 
wire [31:0] aluoutW, readdataW;
wire [ 4:0] writeregW;

// hilo寄存器
wire hi_writeW, lo_writeW;
wire [31:0] hi_iW, lo_iW; // input
wire [31:0] hi_oW, lo_oW; // output

// hazard
wire [1:0] forwardAE, forwardBE;
wire forwardAD, forwardBD;
wire equalD;
wire [31:0] equalsrc1, equalsrc2;

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

// ----------------------------------------
// fetech to decode memory flops 

// pc_4
flopenrc #(32) FD_pc_4 (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(pcsrcD),
    .d(pc_4F),
    .q(pc_4D)
);

// ----------------------------------------
// Decode 

//jump指令的左移2位
sl2 sl2_2(
    .a({6'b0, instrD[25:0]}),
    .y(sl2_j_addr)
);

assign jump_addr = {pc_4D[31:28], sl2_j_addr[27:0]};

assign rsD = instrD[25:21];
assign rtD = instrD[20:16];
assign rdD = instrD[15:11];

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

assign equalD = (equalsrc1 == equalsrc2);
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

//mux, PC指向选择, PC+4(0), pc_src(1)
// pc_branched: 用来跟jump地址再选一次
mux2 #(32) mux_pcbranch(
	.a(pcbranchD),//来自数据存储器
	.b(pc_4F),//来自加法器计算结果
	.s(pcsrcD),
	.y(pc_branched)
);

//mux, 选择分支之后的pc与jump_addr
mux2 #(32) mux_pcnext(
	.a(jump_addr),
	.b(pc_branched),
	.s(jumpD),
	.y(pc_realnext)
);

// ----------------------------------------
// decode to execution flops

// rd1
floprc #(32) DE_rd1 (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d(rd1D),
    .q(rd1E)
);

// rd2
floprc #(32) DE_rd2 (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d(rd2D),
    .q(rd2E)
);

// rs, rt, rd
floprc #(15) DE_rt_rd (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d({rsD, rtD, rdD}),
    .q({rsE, rtE, rdE})
);

// extend_imm
floprc #(32) DE_imm (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d(extend_immD),
    .q(extend_immE)
);

// ----------------------------------------
// Exe 

// ALU,A端输入值，rd1E(00),resultW(01)，aluoutM(10)
mux3 #(32) mux_ALUAsrc(
    .a(rd1E),
    .b(resultW),
    .c(aluoutM),
    .s(forwardAE),
    .y(ALUsrcA)
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

//ALU
alu alu(
    .a(ALUsrcA),
    .b(ALUsrcB2),
    .op(alucontrolE),
    
    .res(aluoutE)
);

assign writedataE = ALUsrcB1; // B输入第一个选择器之后的结果

// 寄存器堆写入地址 writereg

assign writeregE = {mfhiE | mfloE, regdstE} == 2'b00 ? rtE : rdE;

// mux2 #(5) mux_WA3(
// 	.a(rdE), //instr[15:11]
// 	.b(rtE), //instr[20:16]
// 	.s(regdstE),
// 	.y(writeregE)
// ); 

// hilo
//TODO 等乘除法器写好
// assign hi_iE = {mulE, divE, mthiE} == 3'b100 ? 乘法hi :
//                {mulE, divE, mthiE} == 3'b010 ? 除法hi :
//                {mulE, divE, mthiE} == 3'b001 ? rd2E  :
//                                                32'b0;
// assign lo_iE = {mulE, divE, mtloE} == 3'b100 ? 乘法lo :
//                {mulE, divE, mtloE} == 3'b010 ? 除法lo :
//                {mulE, divE, mtloE} == 3'b001 ? rd2E  :
//                                                32'b0;

// ----------------------------------------
// execution to Mem flops

// aluout
flopenr #(32) EM_aluout (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(aluoutE),
    .q(aluoutM)
);

// writedata
flopenr #(32) EM_writedata (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(writedataE),
    .q(writedataM)
);

// writereg
flopenr #(5) EM_writereg (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d(writeregE),
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



// ----------------------------------------
// Mem 
assign mem_WriteData = writedataM;

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

// ----------------------------------------
// Write Back 

//mux, 寄存器堆写入数据来自存储器 or ALU ，memtoReg
// mux2 #(32) mux_WD3(
// 	.a(readdataW),//来自数据存储器
// 	.b(aluoutW),//来自ALU计算结果
// 	.s(memtoregW),
// 	.y(resultW)
// );
assign resultW = {mfhiW, mfloW} == 2'b00 ? (memtoregW == 1'b1 ? readdataW : aluoutW) : 
                 {mfhiW, mfloW} == 2'b10 ? hi_oW :
                 {mfhiW, mfloW} == 2'b01 ? lo_oW :
                 32'b0;

//hilo寄存器
assign hi_writeW = mulW | divW | mthiW;
assign lo_writeW = mulW | divW | mtloW;
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
    .mfhiE(mfhiE), .mfhiM(mfhiM), .mfhiW(mfhiW),
	.mfloE(mfloE), .mfloM(mfloM), .mfloW(mfloW),
	.mthiE(mthiE), .mthiM(mthiM), .mthiW(mthiW),
	.mtloE(mtloE), .mtloM(mtloM), .mtloW(mtloW),
    
    .forwardAE(forwardAE),
    .forwardBE(forwardBE),
    .forwardAD(forwardAD),
    .forwardBD(forwardBD),
    .stallF(stallF),
    .stallD(stallD),
    .flushE(flushE)
);


endmodule
