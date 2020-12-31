`timescale 1ns / 1ps


module top(
	input wire clk,
	input wire resetn,
	input wire [5:0] int,					// not use
	//////////////////////////////////////////
	// inst ram ports
	output wire 	   inst_sram_en   ,		// not use
	output wire [ 3:0] inst_sram_wen  ,		// not use
	output wire [31:0] inst_sram_addr ,
	output wire [31:0] inst_sram_wdata,		// not use
	output wire [31:0] inst_sram_rdata,
	//////////////////////////////////////////
	// data ram ports
	output wire        data_sram_en   ,
	output wire [ 3:0] data_sram_wen  ,
	output wire [31:0] data_sram_addr ,
	output wire [31:0] data_sram_wdata,
	output wire [31:0] data_sram_rdata,
	//////////////////////////////////////////
	// debug ports
	output wire [31:0] debug_wb_pc      ,	// pc
	output wire 	   debug_wb_rf_wen  ,	// regfile write enable
	output wire [ 4:0] debug_wb_rf_wnum ,	// regfile write number
	output wire [31:0] debug_wb_rf_wdata	// regfile write data
	
);

mips mips(
	.clk			(clk),
	.reset			(resetn),
	.pc				(inst_sram_addr	),
	.instr			(inst_sram_rdata),

	.readdata		(data_sram_rdata),
	.memwriteM		(data_sram_en	),
	.aluoutM		(data_sram_addr	),
	.writedata		(data_sram_wdata),
	.mem_wea		(data_sram_wen	),
	// debug
	.debug_wb_rf_wen(debug_wb_rf_wen)	,
	.debug_wb_rf_wnum(debug_wb_rf_wnum)	,
	.debug_wb_rf_wdata(debug_wb_rf_wdata)
);
assign debug_wb_pc = inst_sram_addr;
assign inst_sram_en = 1'b1;
assign inst_sram_wen = 4'b0000;
assign inst_sram_wdata = 32'b0;

/*inst_ram inst_ram(
	.clka(~clk),
	.addra(pc),
	.douta(instr)
);*/

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

/*data_ram data_ram(
	.clka(~clk),
	.ena(memwrite),
	.wea(mem_wea),
	.addra(dataadr),
	.dina(writedata),	 // Ҫд��洢���е�����
	.douta(readdata)	 // �Ӵ洢���ж���������
);*/

endmodule
