`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/30 17:36:51
// Design Name: 
// Module Name: oldTest
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


module oldTest();
	reg clk;
	reg rst;

	wire [31:0] instr, pc, resultW;
	wire [4:0] rs, rt, rd;
	wire [31:0] writedata,dataadr;
	wire memwrite;
	wire stallF, stallD, flushE;

	top dut(
		clk,
		rst,
		instr, 
		pc, 
		writedata, 
		dataadr, 
		memwrite
	);

	initial begin 
		rst <= 1;
		#200;
		rst <= 0;
	end

	always begin
		clk <= 1;
		#10;
		clk <= 0;
		#10;
	
	end

	always @(negedge clk) begin
		if(memwrite) begin
			/* code */
			if(dataadr === 84 & writedata === 7) begin
				/* code */
				$display("Simulation succeeded");
				$stop;
			end else if(dataadr !== 80) begin
				/* code */
				$display("Simulation Failed");
				$stop;
			end
		end
	end
endmodule
