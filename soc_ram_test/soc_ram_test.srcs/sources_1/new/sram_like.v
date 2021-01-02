`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/01/02 18:03:53
// Design Name: 
// Module Name: sram_like
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


module sram_like(
    /////////////////////////////////////////
    // input from cpu
    //inst sram-like 
    input [31:0] inst_rdata   ,
    input        inst_addr_ok ,
    input        inst_data_ok ,
    //data sram-like 
    input [31:0] data_rdata   ,
    input        data_addr_ok ,
    input        data_data_ok ,

    /////////////////////////////////////////
    // output to SRAM - AXI bridge
    output         inst_req     ,
    output         inst_wr      ,
    output  [1 :0] inst_size    ,
    output  [31:0] inst_addr    ,
    output  [31:0] inst_wdata   ,

    output         data_req     ,
    output         data_wr      ,
    output  [1 :0] data_size    ,
    output  [31:0] data_addr    ,
    output  [31:0] data_wdata   ,
    );
    /////////////////////////////////////////////////////////////////////////////////////
    // clk      1       input 时钟
    // req      1       master—>slave 请求信号，为 1 时有读写请求，为 0 时无读写请求
    // wr       1       master—>slave 该次请求是写
    // size     [1:0]   master—>slave 该次请求传输的字节数，0: 1byte；1: 2bytes；2: 4bytes。
    // addr     [31:0]  master—>slave 该次请求的地址
    // wdata    [31:0]  master—>slave 该次请求的写数据
    // addr_ok  1       slave—>master 该次请求的地址传输 OK，读：地址被接收；写：地址和数据被接收
    // data_ok  1       slave—>master 该次请求的数据传输 OK，读：数据返回；写：数据写入完成。
    // rdata    [31:0]  slave—>master 该次请求返回的读数据。
    /////////////////////////////////////////////////////////////////////////////////////

    
endmodule
