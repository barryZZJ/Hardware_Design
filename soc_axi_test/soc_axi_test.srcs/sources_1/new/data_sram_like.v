`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/03 00:44:10
// Design Name: 
// Module Name: data_sram_like
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


module data_sram_like(
    // input from cpu
    input wire        cpu_data_en   ,
    input wire [3 :0] cpu_data_wen  ,
    input wire [31:0] cpu_data_addr ,
    input wire [31:0] cpu_data_wdata,
    // output to cpu
    output wire [31:0] cpu_data_rdata,
    // output to bridge
    output wire        data_req    ,
    output wire        data_wr     ,
    output wire [1 :0] data_size   ,
    output wire [31:0] data_addr   ,
    output wire [31:0] data_wdata  ,
    // input from brige
    input wire [31:0] data_rdata   ,
    input wire        data_addr_ok ,
    input wire        data_data_ok
    );
endmodule
