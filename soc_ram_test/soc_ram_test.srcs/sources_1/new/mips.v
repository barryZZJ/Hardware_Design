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
	input wire rst,
	input wire [31:0] instr,
	input wire [31:0] readdata,
	output wire memwriteD,
	output wire memwriteE,
	output wire memwriteM,
	output wire [31:0] pc,
	output wire [31:0] aluoutM, writedata,
	output wire [ 3:0] mem_wea,
	output wire [31:0] debug_wb_pc,
	output wire [ 3:0] debug_wb_rf_wen,
	output wire [ 4:0] debug_wb_rf_wnum,
	output wire [31:0] debug_wb_rf_wdata
);

// Fetch phase
wire is_in_delayslotF;

// Decode phase
wire [31:0] instrD;
wire regwriteD, memtoregD, branchD, alusrcD, regdstD, jumpD, pcsrcD, mfhiD, mfloD;
//  mthiD, mtloD;
wire [1:0] hidstD, lodstD;
wire [7:0] alucontrolD;
wire hi_writeD, lo_writeD;
wire memenD, jalD, jrD, balD;
wire riD;
wire breakD;
wire syscallD;
wire is_in_delayslotD;
wire mtc0D;
wire mfc0D;
wire eretD;

wire [31:0] pcD;
// Execution phase
wire regwriteE, memtoregE, alusrcE, regdstE, mfhiE, mfloE;
//  mthiE, mtloE;
wire [1:0] hidstE, lodstE;
wire [7:0] alucontrolE;
wire hi_writeE, lo_writeE;
wire memenE, jalE, jrE, balE, jumpE;

wire [31:0] pcE;
wire is_in_delayslotE;
wire mtc0E;
wire mfc0E;

// Mem phase
wire regwriteM, memtoregM;
//  mfhiM, mfloM, mthiM, mtloM; 
wire [1:0] hidstM, lodstM;
wire [7:0] alucontrolM;
wire hi_writeM, lo_writeM;

wire [31:0] pcM;
wire is_in_delayslotM;
wire mtc0M;
//memwriteM;

// WB phase
wire regwriteW, memtoregW;
//  mfhiW, mfloW, mthiW, mtloW;
wire [1:0] hidstW, lodstW;
wire [7:0] alucontrolW;
wire hi_writeW, lo_writeW;

wire [31:0] pcW;
// hazard
wire stallF, stallD, stallE, stallM;
wire flushF, flushD, flushE, flushM, flushW;

// wire branchFlushD;

assign is_in_delayslotF = jumpD | branchD | jalD | jrD | balD;

assign debug_wb_pc = pcW;
// fetch to decode flop for instr
flopenrc #(32) FD_instr (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(flushD),
    .d(instr),
    .q(instrD)
);

flopenrc #(32) FD_pc (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(flushD),
    .d(pc),
    .q(pcD)
);
flopenrc #(1) FD_signal (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(flushD),
    .d(is_in_delayslotF),
    .q(is_in_delayslotD)
);

//! 信号长度很容易出错，记得检查, alucontrol是8位, hidst, lodst都是2位
// Decode to Exe flop for signals
flopenrc #(8) DE_signals_aluctrl (
    .clk(clk),
    .rst(rst),
	.en(~stallE),
    .clear(flushE),
    .d(alucontrolD),
    .q(alucontrolE)
);
flopenrc #(4) DE_signals_hilodst (
    .clk(clk),
    .rst(rst),
	.en(~stallE),
    .clear(flushE),
    .d({hidstD, lodstD}),
    .q({hidstE, lodstE})
);

flopenrc #(17) DE_signals (
    .clk(clk),
    .rst(rst),
	.en(~stallE),
    .clear(flushE),
    .d({regwriteD, memtoregD, memwriteD,        alusrcD, 		  regdstD, 
	       memenD, 	   jumpD,      jalD,            jrD,   		     balD, 
			mfhiD, 	   mfloD, hi_writeD,      lo_writeD, is_in_delayslotD,
			mtc0D,     mfc0D}),
    .q({regwriteE, memtoregE, memwriteE,        alusrcE, 		  regdstE, 
	       memenE, 	   jumpE,      jalE,            jrE, 		     balE, 
			mfhiE, 	   mfloE, hi_writeE, 	  lo_writeE, is_in_delayslotE,
			mtc0E,     mfc0E})
);

flopenrc #(32) DE_pc (
    .clk(clk),
    .rst(rst),
    .en(~stallE),
    .clear(1'b0),
    .d(pcD),
    .q(pcE)
);

// exe to Mem flop for signals
flopenrc #(8) EM_signals_aluctrl (
    .clk(clk),
    .rst(rst),
	.en(~stallM),
    .clear(flushM),
    .d(alucontrolE),
    .q(alucontrolM)
);
flopenrc #(4) EM_signals_hilodst (
    .clk(clk),
    .rst(rst),
	.en(~stallM),
    .clear(flushM),
    .d({hidstE, lodstE}),
    .q({hidstM, lodstM})
);

flopenrc #(7) EM_signals (
    .clk(clk),
    .rst(rst),
    .en(~stallM),
	.clear(flushM),
    .d({regwriteE, memtoregE, memwriteE, hi_writeE, lo_writeE, is_in_delayslotE, mtc0E}),
    .q({regwriteM, memtoregM, memwriteM, hi_writeM, lo_writeM, is_in_delayslotM, mtc0M})
);

flopenrc #(32) EM_pc (
    .clk(clk),
    .rst(rst),
    .en(~stallM),
    .clear(1'b0),
    .d(pcE),
    .q(pcM)
);
// mem to wb flop for signals
flopenrc #(8) MW_aluctrl (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
	.clear(flushW),
    .d(alucontrolM),
    .q(alucontrolW)
);

flopenrc #(4) MW_hilodst (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
	.clear(flushW),
    .d({hidstM, lodstM}),
    .q({hidstW, lodstW})
);

flopenrc #(4) MW_signals (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
	.clear(flushW),
    .d({regwriteM, memtoregM, hi_writeM, lo_writeM}),
    .q({regwriteW, memtoregW, hi_writeW, lo_writeW})
);
flopenrc #(32) MW_pc (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .clear(flushW),
    .d(pcM),
    .q(pcW)
);
controller c(
	.instr(instrD),
	.op(instrD[31:26]),
	.funct(instrD[5:0]),
	.rs(instrD[25:21]),
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
	.lo_writeD(lo_writeD),
	.riD(riD),
	.breakD(breakD),
	.syscallD(syscallD),
	.mtc0D(mtc0D),
	.mfc0D(mfc0D),
	.eretD(eretD)

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
	// .branchFlushD(branchFlushD)

	.mfhiE(mfhiE),
	.mfloE(mfloE),
	.hidstE(hidstE), .hidstW(hidstW),
	.lodstE(lodstE), .lodstW(lodstW),
	.hi_writeM(hi_writeM), 
	.hi_writeW(hi_writeW), 
	.lo_writeM(lo_writeM),
	.lo_writeW(lo_writeW),
	.riD(riD),
	.is_in_delayslotM(is_in_delayslotM),
	.breakD(breakD),
	.syscallD(syscallD),
	.mtc0M(mtc0M),
	.mfc0E(mfc0E),
	.eretD(eretD),

	.pc(pc),
	.pcsrcD(pcsrcD),
	.aluoutM(aluoutM),
	.mem_WriteData(writedata),
	.mem_wea(mem_wea),
	.stallF(stallF),
	.stallD(stallD),
	.stallE(stallE),
	.stallM(stallM),
	.flushF(flushF),
	.flushD(flushD),
    .flushE(flushE),
    .flushM(flushM),
    .flushW(flushW),
	// jump and branch
	.memenE(memenE),
    .jalE(jalE),
    .jrE(jrE),
	.jumpE(jumpE),
	.balE(balE),
    .balD(balD),
	.jalD(jalD),
	// .branchFlushD(branchFlushD)

	// debug
	.debug_wb_rf_wen(debug_wb_rf_wen),
	.debug_wb_rf_wnum(debug_wb_rf_wnum),
	.debug_wb_rf_wdata(debug_wb_rf_wdata)
	
);
	
endmodule
