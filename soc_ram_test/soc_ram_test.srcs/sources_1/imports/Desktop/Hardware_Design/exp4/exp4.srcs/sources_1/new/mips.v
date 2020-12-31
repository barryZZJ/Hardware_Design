`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips(
	input wire clk,
	input wire reset,
	input wire [31:0] instr,
	input wire [31:0] readdata,
	output wire memwriteM,
	output wire [31:0] pc,
	output wire [31:0] aluoutM, writedata,
	output wire [ 3:0] mem_wea,
	output wire debug_wb_rf_wen,
	output wire [ 4:0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
);
// Decode phase
wire [31:0] instrD;
wire regwriteD, memtoregD, memwriteD, branchD, alusrcD, regdstD, jumpD, pcsrcD, mfhiD, mfloD;
//  mthiD, mtloD;
wire [1:0] hidstD, lodstD;
wire [7:0] alucontrolD;
wire memenD, jalD, jrD, balD;


// Execution phase
wire regwriteE, memtoregE, memwriteE, alusrcE, regdstE, mfhiE, mfloE;
//  mthiE, mtloE;
wire [1:0] hidstE, lodstE;
wire [7:0] alucontrolE;
wire memenE, jalE, jrE, balE, jumpE;


// Mem phase
wire regwriteM, memtoregM;
//  mfhiM, mfloM, mthiM, mtloM; 
wire [1:0] hidstM, lodstM;
wire [7:0] alucontrolM;
wire hi_writeM, lo_writeM;
//memwriteM;

// WB phase
wire regwriteW, memtoregW;
//  mfhiW, mfloW, mthiW, mtloW;
wire [1:0] hidstW, lodstW;
wire [7:0] alucontrolW;
wire hi_writeW, lo_writeW;

// hazard
wire stallF, stallD, stallE, flushE;

// wire branchFlushD;

// fetch to decode flop for instr
flopenrc #(32) FD_instr (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(1'b0),
    .d(instr),
    .q(instrD)
);

//! 信号长度很容易出错，记得检查, alucontrol是8位, hidst, lodst都是2位
// Decode to Exe flop for signals
flopenrc #(26) DE_signals (
    .clk(clk),
    .rst(rst),
	.en(~stallE),
    .clear(flushE),
    .d({regwriteD, memtoregD, memwriteD, alucontrolD, alusrcD, regdstD, memenD, jumpD, jalD, jrD, balD, mfhiD, mfloD, hidstD, lodstD, hi_writeD, lo_writeD}),
    .q({regwriteE, memtoregE, memwriteE, alucontrolE, alusrcE, regdstE, memenE, jumpE, jalE, jrE, balE, mfhiE, mfloE, hidstE, lodstE, hi_writeE, lo_writeE})
);

// exe to Mem flop for signals
flopenr #(17) EM_signals (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({regwriteE, memtoregE, memwriteE, hidstE, lodstE, hi_writeE, lo_writeE, alucontrolE}),
    .q({regwriteM, memtoregM, memwriteM, hidstM, lodstM, hi_writeM, lo_writeM, alucontrolM})
);

// mem to wb flop for signals
flopenr #(16) MW_signals (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({regwriteM, memtoregM, hidstM, lodstM, hi_writeM, lo_writeM, alucontrolM}),
    .q({regwriteW, memtoregW, hidstW, lodstW, hi_writeW, lo_writeW, alucontrolW})
);

controller c(
	.op(instrD[31:26]),
	.funct(instrD[5:0]),
	.rt(instrD[20:16]),
	.memtoregD(memtoregD),
	.memwriteD(memwriteD),
	.alusrcD(alusrcD),
	.regdstD(regdstD),
	.regwriteD(regwriteD),
	.branchD(branchD),
	.jumpD(jumpD),
	.alucontrolD(alucontrolD),
	// jump and branch
	.memenD(memenD),
    .jalD(jalD),
    .jrD(jrD),
    .balD(balD),

	.mfhiD(mfhiD),
	.mfloD(mfloD),
	.hidstD(hidstD),
	.lodstD(lodstD),
	.hi_writeD(hi_writeD), 
	.lo_writeD(lo_writeD)
);

datapath dp(
	.clk(clk),
	.rst(rst),
	.instrD(instrD),
	.readdata(readdata),
	.regwriteE(regwriteE),
	.regwriteM(regwriteM),
	.regwriteW(regwriteW),
	.memtoregW(memtoregW),
	.memtoregE(memtoregE),
	.memtoregM(memtoregM),
	.alucontrolE(alucontrolE), .alucontrolW(alucontrolW),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.jumpD(jumpD),
	.jrD(jrD),
	.branchD(branchD),
	.mfhiE(mfhiE),
	.mfloE(mfloE),
	.hidstE(hidstE), .hidstW(hidstW),
	.lodstE(lodstE), .lodstW(lodstW),
	.hi_writeM(hi_writeM), 
	.hi_writeW(hi_writeW), 
	.lo_writeM(lo_writeM),
	.lo_writeW(lo_writeW),
	
	.pc(pc),
	.pcsrcD(pcsrcD),
	.aluoutM(aluoutM),
	.mem_WriteData(writedata),
	.mem_wea(mem_wea),
	.stallF(stallF),
	.stallD(stallD),
	.stallE(stallE),
	.flushE(flushE),
	// jump and branch
	.memenE(memenE),
    .jalE(jalE),
    .jrE(jrE),
	.jumpE(jumpE),
	.balE(balE),
    .balD(balD),
	// .branchFlushD(branchFlushD)

	// debug
	.debug_wb_rf_wen(debug_wb_rf_wen),
	.debug_wb_rf_wnum(debug_wb_rf_wnum),
	.debug_wb_rf_wdata(debug_wb_rf_wdata)
	

);
	
endmodule
