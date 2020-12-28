`timescale 1ns / 1ps


module datapath(
    input clk,rst,
    input [31:0]instrD, readdata, // ���ݴ洢������������
    input regwriteE,
    input regwriteM,
    input regwriteW,
    input memtoregW,
    input memtoregE,
    input memtoregM,
    input [2:0]alucontrolE,
    input alusrcE,
    input regdstE,
    input jumpD,
    input branchD,
    
    output wire [31:0] pc, aluoutM, mem_WriteData, resultW,
    output pcsrcD,
    output wire stallF, stallD, flushE
);
    

//�ֱ�Ϊ��pc+4, ��·ѡ���֧֮���pc, ��һ������Ҫִ�е�ָ���pc
wire [31:0] pc_branched, pc_realnext;

//ALU������ԴA��B���Ĵ�����д�����ݣ�����2λ�����������
wire [31:0] ALUsrcA, ALUsrcB1, ALUsrcB2, sl2_imm, sl2_j_addr, jump_addr;
    // resultW, 


// Fetch phase
wire [31:0] pc_4F;

// Decode phase
// pc_4: pc+4, pcbranch: pc+4 + imm<<2
wire [31:0] pcF, pc_4D, pcbranchD, rd1D, rd2D, extend_immD;
wire [ 4:0] rsD, rtD, rdD;
    //wire pcsrcD;

// Execute phase
wire [31:0] pc_4E, rd1E, rd2E, extend_immE, aluoutE, writedataE;
wire [ 4:0] rsE, rtE, rdE, writeregE; // д��Ĵ����ѵĵ�ַ

// Mem phase
wire [31:0] writedataM;
    // aluoutM;
wire [ 4:0] writeregM;

// WB phase 
wire [31:0] aluoutW, readdataW;
wire [ 4:0] writeregW;

// hazard
wire [1:0] forwardAE, forwardBE;
wire forwardAD, forwardBD;
    // wire stallF, stallD, flushE;
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

//PC+4�ӷ���
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

//jumpָ�������2λ
sl2 sl2_2(
    .a({6'b0, instrD[25:0]}),
    .y(sl2_j_addr)
);

assign jump_addr = {pc_4D[31:28], sl2_j_addr[27:0]};

assign rsD = instrD[25:21];
assign rtD = instrD[20:16];
assign rdD = instrD[15:11];

//�Ĵ�����
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

//������չ
signext sign_extend(
    .a(instrD[15:0]),
    .y(extend_immD)
);

//������������2λ
sl2 sl2_1(
    .a(extend_immD),
    .y(sl2_imm)
);

//branch��ת��ַ�ӷ���
adder pc_branch_adder (
	.a(pc_4D),
	.b(sl2_imm),
	.y(pcbranchD)
);

//mux, PCָ��ѡ��, PC+4(0), pc_src(1)
// pc_branched: ������jump��ַ��ѡһ��
mux2 #(32) mux_pcbranch(
	.a(pcbranchD),//�������ݴ洢��
	.b(pc_4F),//���Լӷ���������
	.s(pcsrcD),
	.y(pc_branched)
);

//mux, ѡ���֧֮���pc��jump_addr
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

// ALU,A������ֵ��rd1E(00),resultW(01)��aluoutM(10)
mux3 #(32) mux_ALUAsrc(
    .a(rd1E),
    .b(resultW),
    .c(aluoutM),
    .s(forwardAE),
    .y(ALUsrcA)
);
// ALU, B������ֵ��rd1E(00),resultW(01)��aluoutM(10)
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
    .y(ALUsrcB2) // B����ڶ���ѡ����֮��Ľ��
);

//ALU
alu alu(
    .a(ALUsrcA),
    .b(ALUsrcB2),
    .op(alucontrolE),
    
    .res(aluoutE)
);

assign writedataE = ALUsrcB1; // B�����һ��ѡ����֮��Ľ��

// �Ĵ�����д���ַ writereg

mux2 #(5) mux_WA3(
	.a(rdE), //instr[15:11]
	.b(rtE), //instr[20:16]
	.s(regdstE),
	.y(writeregE)
); 

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

// ----------------------------------------
// Write Back 

//mux, �Ĵ�����д���������Դ洢�� or ALU ��memtoReg
mux2 #(32) mux_WD3(
	.a(readdataW),//�������ݴ洢��
	.b(aluoutW),//����ALU������
	.s(memtoregW),
	.y(resultW)
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
    
    .forwardAE(forwardAE),
    .forwardBE(forwardBE),
    .forwardAD(forwardAD),
    .forwardBD(forwardBD),
    .stallF(stallF),
    .stallD(stallD),
    .flushE(flushE)
);


endmodule
