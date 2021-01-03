`timescale 1ns / 1ps


module mips_top(
	input wire clk,
	input wire resetn,
	input wire [5:0] int,					// not use
	//////////////////////////////////////////
	// inst ram ports
	output wire 	   inst_sram_en   ,		// not use
	output wire [ 3:0] inst_sram_wen  ,		// not use
	output wire [31:0] inst_sram_addr ,
	output wire [31:0] inst_sram_wdata,		// not use
	input  wire [31:0] inst_sram_rdata,
	//////////////////////////////////////////
	// data ram ports
	output wire        data_sram_en   ,
	output wire [ 3:0] data_sram_wen  ,
	output wire [31:0] data_sram_addr ,
	output wire [31:0] data_sram_wdata,
	input  wire [31:0] data_sram_rdata,
	//////////////////////////////////////////
	// debug ports
	output wire [31:0] debug_wb_pc      ,	// pc
	output wire [ 3:0] debug_wb_rf_wen  ,	// regfile write enable
	output wire [ 4:0] debug_wb_rf_wnum ,	// regfile write number
	output wire [31:0] debug_wb_rf_wdata	// regfile write data
	
);

wire [31:0] inst_addr;
wire [31:0] data_addr;

// wire data_sram_en;
assign data_sram_en = 1'b1;
addrtrans address_transfer(
	.inst_vaddr(inst_addr),
	.inst_paddr(inst_sram_addr),
	.data_vaddr(data_addr),
	.data_paddr(data_sram_addr)
);

mips mips(
	.clk			(clk),
	.rst			(resetn),
	.pc				(inst_addr		),	// 未映射地址
	.instr			(inst_sram_rdata),

	.readdata		(data_sram_rdata),
	// .memenM		    (data_sram_en	),
	.aluoutM		(data_addr		),	// 未映射地址
	.writedata		(data_sram_wdata),
	.mem_wea		(data_sram_wen	),
	// debug
	.debug_wb_pc		(debug_wb_pc		),
	.debug_wb_rf_wen	(debug_wb_rf_wen	),
	.debug_wb_rf_wnum	(debug_wb_rf_wnum	),
	.debug_wb_rf_wdata	(debug_wb_rf_wdata	)
);
assign inst_sram_en = 1'b1;
assign inst_sram_wen = 4'b0000;
assign inst_sram_wdata = 32'b0;


// 物理地址映射


/*inst_ram inst_ram(
	.clka(~clk),
	.addra(pc),
	.douta(instr)
);*/

// 大端，低地址在高字节
// ena 为 0：读，
// wea 为 4'b0000

// ena 为 1：写，
// wea 为:
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
	.dina(writedata),	 // 要写的地址
	.douta(readdata)	 // 读出的地址
);*/

endmodule
