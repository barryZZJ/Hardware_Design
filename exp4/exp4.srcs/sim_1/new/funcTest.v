`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/30 16:15:15
// Design Name: 
// Module Name: funcTest
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


module funcTest(

    );
    reg clock_50;
    reg rst;
    wire [31:0] instr, pc;
	wire [31:0] writedata,dataadr;
	wire memwrite;
    top dut(
		clock_50,
		rst,
		instr, 
		pc, 
		writedata, 
		dataadr, 
		memwrite
	);

    initial begin
        clock_50 = 1'b0;
        forever # 10 clock_50 = ~clock_50;
    end

    initial begin
        rst = 1;
        #200 rst= 0;
        #1500 $stop;
    end

endmodule
