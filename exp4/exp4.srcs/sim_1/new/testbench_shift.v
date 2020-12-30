`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/29 21:24:23
// Design Name: 
// Module Name: testbench_shift
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


module testbench_shift();

reg clk;
reg rst;

initial begin
    clk = 1'b0;
    forever # 10 clk = ~clk;
end

initial begin
    rst = 1;
    #200 rst= 0;
    #1000 $stop;
end


top dut(
    .clk(clk),
    .rst(rst),
    .instr(), 
    .pc(),
	.writedata(),
    .dataadr(),
	.memwrite()
);

endmodule
