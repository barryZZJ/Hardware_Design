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
	input wire clk,rst,
	input wire[31:0] instr,
	input wire[31:0] readdata,
	output wire memwriteM,
	output wire[31:0] pc,
	output wire[31:0] aluoutM, writedata
);
	
// Decode phase
wire [31:0] instrD;
wire regwriteD, memtoregD, memwriteD, branchD, alusrcD, regdstD, jumpD, pcsrcD;
wire [7:0] alucontrolD;

// Execution phase
wire regwriteE, memtoregE, memwriteE, alusrcE, regdstE;
wire [7:0] alucontrolE;

// Mem phase
wire regwriteM, memtoregM; 
//memwriteM;

// WB phase
wire regwriteW, memtoregW;

// hazard
wire stallF, stallD, flushE;

// fetch to decode flop for instr
flopenrc #(32) FD_instr (
    .clk(clk),
    .rst(rst),
    .en(~stallD),
    .clear(pcsrcD),
    .d(instr),
    .q(instrD)
);

// Decode to Exe flop for signals
floprc #(13) DE_signals (
    .clk(clk),
    .rst(rst),
    .clear(flushE),
    .d({regwriteD, memtoregD, memwriteD, alucontrolD, alusrcD, regdstD}),
    .q({regwriteE, memtoregE, memwriteE, alucontrolE, alusrcE, regdstE})
);

// exe to Mem flop for signals
flopenr #(3) EM_signals (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({regwriteE, memtoregE, memwriteE}),
    .q({regwriteM, memtoregM, memwriteM})
);

// mem to wb flop for signals
flopenr #(2) MW_signals (
    .clk(clk),
    .rst(rst),
    .en(1'b1),
    .d({regwriteM, memtoregM}),
    .q({regwriteW, memtoregW})
);

controller c(
	.op(instrD[31:26]),
	.funct(instrD[5:0]),

	.memtoregD(memtoregD),
	.memwriteD(memwriteD),
	.alusrcD(alusrcD),
	.regdstD(regdstD),
	.regwriteD(regwriteD),
	.branchD(branchD),
	.jumpD(jumpD),
	.alucontrolD(alucontrolD)
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
	.alucontrolE(alucontrolE),
	.alusrcE(alusrcE),
	.regdstE(regdstE),
	.jumpD(jumpD),
	.branchD(branchD),
	
	.pc(pc),
	.pcsrcD(pcsrcD),
	.aluoutM(aluoutM),
	.mem_WriteData(writedata),
	.stallF(stallF),
	.stallD(stallD),
	.flushE(flushE)
);
	
endmodule
