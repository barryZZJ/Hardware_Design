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

reg clock_50;
reg rst;

initial begin
    clock_50 = 1'b0;
    forever # 10 clock_50 = ~clock_50;
end

initial begin
    rst = 0;
    #200 rst= 1;
    #1000 $stop;
end


mycpuTop top(
    .clk(clock_50),
    .rst(rst),
    .instr(), 
    .pc(),
	.writedata(),
    .dataadr(),
	.memwrite()
);

endmodule
