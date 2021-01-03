`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 14:21:08
// Design Name: 
// Module Name: sram_like_top
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


module sram_like_top(

    );
    wire cpu_clk;
    reg cpu_resetn;
    //cpu inst sram
    wire        cpu_inst_en;
    wire [3 :0] cpu_inst_wen;
    wire [31:0] cpu_inst_addr;
    wire [31:0] cpu_inst_wdata;
    wire [31:0] cpu_inst_rdata;
    //cpu data sram
    wire        cpu_data_en;
    wire [3 :0] cpu_data_wen;
    wire [31:0] cpu_data_addr;
    wire [31:0] cpu_data_wdata;
    wire [31:0] cpu_data_rdata;
    //debug signals
    wire [31:0] debug_wb_pc;
    wire [3 :0] debug_wb_rf_wen;
    wire [4 :0] debug_wb_rf_wnum;
    wire [31:0] debug_wb_rf_wdata;
    //cpu
    top cpu(
        .clk              (~cpu_clk      ),
        .resetn           (~cpu_resetn  ),  //low active
        .int              (6'd0         ),  //interrupt,high active

        .inst_sram_en     (cpu_inst_en   ),
        .inst_sram_wen    (cpu_inst_wen  ),
        .inst_sram_addr   (cpu_inst_addr ),
        .inst_sram_wdata  (cpu_inst_wdata),
        .inst_sram_rdata  (cpu_inst_rdata),
        
        .data_sram_en     (cpu_data_en   ),
        .data_sram_wen    (cpu_data_wen  ),
        .data_sram_addr   (cpu_data_addr ),
        .data_sram_wdata  (cpu_data_wdata),
        .data_sram_rdata  (cpu_data_rdata),

        //debug
        .debug_wb_pc      (debug_wb_pc      ),
        .debug_wb_rf_wen  (debug_wb_rf_wen  ),
        .debug_wb_rf_wnum (debug_wb_rf_wnum ),
        .debug_wb_rf_wdata(debug_wb_rf_wdata)
    );
    inst_sram_like inst_sram_like(

    );
    data_sram_like data_sram_like(

    );

endmodule
