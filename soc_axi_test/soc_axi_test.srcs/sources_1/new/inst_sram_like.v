`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 14:27:06
// Design Name: 
// Module Name: inst_sram_like
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


module inst_sram_like(
    // input from cpu
    input wire        cpu_inst_en   ,
    input wire [3 :0] cpu_inst_wen  ,
    input wire [31:0] cpu_inst_addr ,
    input wire [31:0] cpu_inst_wdata,
    // output to cpu
    output wire [31:0] cpu_inst_rdata,
    // output to bridge
    output wire        inst_req    ,
    output wire        inst_wr     ,
    output wire [1 :0] inst_size   ,
    output wire [31:0] inst_addr   ,
    output wire [31:0] inst_wdata  ,
    // input from brige
    input wire [31:0] inst_rdata   ,
    input wire        inst_addr_ok ,
    input wire        inst_data_ok
    );
endmodule
