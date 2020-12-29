`timescale 1ns / 1ps


module top(
	input wire clk,rst,
    output [31:0] instr, pc,
	output wire [31:0] writedata, dataadr,
	output wire memwrite
);

wire [31:0] readdata; 

mips mips(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.readdata(readdata),

	.memwriteM(memwrite),
	.pc(pc),
	.aluoutM(dataadr),
	.writedata(writedata)
);

inst_ram inst_ram(
	.clka(~clk),
	.ena(1'b1),      // input wire ena
	.wea(4'b0000),      // input wire [3 : 0] wea
	.addra({2'b0, pc[7:2]}),
	.dina(32'b0),    // input wire [31 : 0] dina
	.douta(instr)
);

data_ram data_ram(
	.clka(~clk),
	.ena(1'b1),
	.wea({4{memwrite}}),
	.addra(dataadr),
	.dina(writedata),	 // 要写入存储器中的数据
	.douta(readdata)	 // 从存储器中读出的数据
);

endmodule
