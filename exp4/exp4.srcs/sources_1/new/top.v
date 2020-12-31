`timescale 1ns / 1ps


module top(
	input wire clk,rst,
    output [31:0] instr, pc,
	output wire [31:0] writedata, dataadr,
	output wire memwrite
);

wire [31:0] readdata; 
wire [3:0]  mem_wea;

mips mips(
	.clk(clk),
	.rst(rst),
	.instr(instr),
	.readdata(readdata),

	.memwriteM(memwrite),
	.pc(pc),
	.aluoutM(dataadr),
	.writedata(writedata),
	.mem_wea(mem_wea)
);

inst_ram inst_ram(
	.clka(~clk),
	.addra(pc),
	.douta(instr)
);

// ��ˣ��͵�ַ�ڸ��ֽ�
// ena Ϊ 0������
// wea Ϊ 4'b0000

// ena Ϊ 1��д��
// wea Ϊ:
// SW:
// 4'b1111
// SH:
// addr[1:0] == 2'b00 ? 4'b1100
// addr[1:0] == 2'b10 ? 4'b0011
// SB:
// addr[1:0] == 2'b00 ? 4'b1000
// addr[1:0] == 2'b01 ? 4'b0100
// addr[1:0] == 2'b10 ? 4'b0010
// addr[1:0] == 2'b11 ? 4'b0001

data_ram data_ram(
	.clka(~clk),
	.ena(memwrite),
	.wea(mem_wea),
	.addra(dataadr),
	.dina(writedata),	 // Ҫд��洢���е�����
	.douta(readdata)	 // �Ӵ洢���ж���������
);

endmodule
